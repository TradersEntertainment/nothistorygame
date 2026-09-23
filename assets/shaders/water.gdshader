// Low-poly su: köşeli (düz gölgeli) dalgalar, uzaklığa göre renk, kıyıda köpük.
shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx, cull_back;

uniform vec4 shallow_color : source_color = vec4(0.10, 0.50, 0.58, 1.0);
uniform vec4 deep_color : source_color = vec4(0.03, 0.20, 0.32, 1.0);
uniform vec4 foam_color : source_color = vec4(0.92, 0.96, 0.97, 1.0);
uniform float wave_height = 0.35;
uniform float shore_z = 0.0;
uniform float foam_width = 4.0;

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
	VERTEX.y += wave * wave_height;
	world_pos = w;
}

void fragment() {
	// Düz gölgeleme: yüz normali ekran türevlerinden
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	vec3 cam = INV_VIEW_MATRIX[3].xyz;
	float dist = clamp(length(world_pos.xz - cam.xz) / 220.0, 0.0, 1.0);
	vec3 col = mix(shallow_color.rgb, deep_color.rgb, dist);
	// Dalga tepeleri biraz açık
	col = mix(col, shallow_color.rgb * 1.25, smoothstep(0.6, 1.3, wave) * 0.5);
	// Kıyı köpüğü: kıyı çizgisine yakın, dalgayla titreşen şerit
	float to_shore = world_pos.z - shore_z;
	float foam = smoothstep(foam_width, 0.0, abs(to_shore + sin(world_pos.x * 0.4 + TIME * 1.5) * 0.8));
	col = mix(col, foam_color.rgb, foam * 0.85);
	ALBEDO = col;
	ROUGHNESS = 0.3;
	SPECULAR = 0.55;
}
