// Low-poly su: köşeli (düz gölgeli) dalgalar, uzaklığa göre renk, kıyıda köpük.
shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx, cull_disabled;

uniform vec4 shallow_color : source_color = vec4(0.10, 0.50, 0.58, 1.0);
uniform vec4 deep_color : source_color = vec4(0.03, 0.20, 0.32, 1.0);
uniform vec4 foam_color : source_color = vec4(0.92, 0.96, 0.97, 1.0);
uniform float wave_height = 0.35;
uniform float shore_z = 0.0;
uniform float foam_width = 4.0;
uniform vec4 under_color : source_color = vec4(0.05, 0.30, 0.36, 1.0);
// Kameranın yakınında dalgalar yatışır: yüzerken dalga kameranın içinden geçmesin.
uniform float calm_inner = 5.0;
uniform float calm_outer = 28.0;
// Gök yansıması (Compatibility'de gerçek yansıma yok): yatay bakışta su gökyüzü rengine döner
uniform vec4 sky_tint : source_color = vec4(0.62, 0.78, 0.9, 1.0);
uniform float fresnel_strength = 0.5;
// İnce kırışıklık ve güneş pırıltısı
uniform float ripple = 0.25;
uniform float glint = 0.8;

varying vec3 world_pos;
varying float wave;

float waves(vec2 p, float t) {
	return sin(p.x * 0.13 + t * 1.1) * 0.5
		+ sin(p.y * 0.19 - t * 0.8) * 0.35
		+ sin((p.x + p.y) * 0.06 + t * 0.5) * 0.6
		+ sin((p.x - p.y) * 0.31 + t * 1.7) * 0.15;
}

void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wave = waves(w.xz, TIME);
	vec3 cam = INV_VIEW_MATRIX[3].xyz;
	float near = smoothstep(calm_inner, calm_outer, length(w.xz - cam.xz));
	VERTEX.y += wave * wave_height * mix(0.12, 1.0, near);
	world_pos = w;
}

void fragment() {
	// Düz gölgeleme: yüz normali ekran türevlerinden. Yukarı yönle karıştırılır ki
	// uzaktaki üçgenler çizgi çizgi değil, hafif köşeli görünsün.
	vec3 flat_n = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	vec3 up_n = normalize((VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
	if (dot(flat_n, up_n) < 0.0) {
		up_n = -up_n;
	}
	NORMAL = normalize(mix(flat_n, up_n, 0.55));
	// İnce kırışıklıklar: dünya koordinatında küçük dalgacıkların eğimi normale eklenir
	vec2 q = world_pos.xz;
	float t = TIME;
	float gx = cos(q.x * 1.7 + t * 2.0) * 1.7 + cos((q.x + q.y) * 1.1 + t * 1.3) * 1.1 + cos((q.x * 0.6 - q.y) * 2.9 + t * 2.6) * 1.7;
	float gz = -sin(q.y * 2.3 - t * 1.6) * 2.3 + cos((q.x + q.y) * 1.1 + t * 1.3) * 1.1 - cos((q.x * 0.6 - q.y) * 2.9 + t * 2.6) * 2.9;
	vec3 rip_w = normalize(vec3(-gx * 0.06, 1.0, -gz * 0.06));
	vec3 rip_v = normalize((VIEW_MATRIX * vec4(rip_w, 0.0)).xyz);
	NORMAL = normalize(mix(NORMAL, rip_v, ripple));
	if (!FRONT_FACING) {
		// Alttan bakınca (dalış): düz, bulanık yüzey
		ALBEDO = under_color.rgb;
		EMISSION = under_color.rgb * 0.6;
		ROUGHNESS = 1.0;
		SPECULAR = 0.0;
	} else {
		vec3 cam = INV_VIEW_MATRIX[3].xyz;
		float dist = clamp(length(world_pos.xz - cam.xz) / 220.0, 0.0, 1.0);
		vec3 col = mix(shallow_color.rgb, deep_color.rgb, dist);
		// Dalga tepeleri biraz açık
		col = mix(col, shallow_color.rgb * 1.25, smoothstep(0.6, 1.3, wave) * 0.5);
		// Kıyı köpüğü: kıyı çizgisine yakın, dalgayla titreşen şerit
		float to_shore = world_pos.z - shore_z;
		float foam = smoothstep(foam_width, 0.0, abs(to_shore + sin(world_pos.x * 0.4 + TIME * 1.5) * 0.8));
		col = mix(col, foam_color.rgb, foam * 0.85);
		// Fresnel: uzağa/yatay bakınca su gökyüzünü yansıtır, ayağımızın dibinde derin rengini gösterir
		float fr = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
		col = mix(col, sky_tint.rgb, fr * fresnel_strength * (1.0 - foam));
		// Güneş pırıltısı: seyrek, titreşen parlak noktalar (dalga tepelerinde daha çok)
		vec2 gq = world_pos.xz * 2.5 + vec2(sin(TIME * 0.7), cos(TIME * 0.6)) * 2.0;
		vec2 gp = floor(gq);
		float hsh = fract(sin(dot(gp, vec2(12.9898, 78.233))) * 43758.5453);
		// Hücrenin ortasında küçük yuvarlak nokta (kare değil)
		float dot_mask = smoothstep(0.18, 0.0, length(fract(gq) - 0.5));
		float spark = step(0.985 - smoothstep(0.4, 1.2, wave) * 0.01, hsh) * dot_mask * (0.5 + 0.5 * sin(TIME * 6.0 + hsh * 40.0));
		EMISSION = sky_tint.rgb * spark * glint * (0.3 + fr);
		ALBEDO = col;
		ROUGHNESS = 0.3;
		SPECULAR = 0.55;
	}
}
