// Alev ve ışık halesi (Flame): kameraya dönen dörtgen üstünde yumuşak kenarlı, titreyen, aşağıdan yukarı incelen alev
// (mode 0) ya da yuvarlak sıcak hale (mode 1). Saydam karışım (eskiden toplamalıydı): karanlıkta aynı görünür, gündüz
// parlak gökte ya da duvarda beyaza dönmez (26'da Fatih'in girişinde surdaki yangın bembeyaz bir lekeydi).
// Çoklu ağda (MultiMesh) her örneğin evresi dünyadaki yerinden gelir: yan yana iki alev aynı anda titremez.
// Alev yukarıdan bakılınca (uçan Nihat, kuşbakışı) dik kalan dörtgen kenarından görünüp çizgiye/kareye dönüyordu: bakış
// dikleştikçe dörtgen kameraya yatar, alevin ortasına taşınır ve biçim dil dil yanan yuvarlak bir ateşe (çevresi kızıl
// diller, ortası sarı kor) geçer.
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled, skip_vertex_transform;

uniform int mode = 0;
uniform vec4 core_color : source_color = vec4(1.0, 0.93, 0.62, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 0.42, 0.08, 1.0);
uniform float energy = 1.6;
uniform float speed = 1.0;
uniform float flicker = 0.25;
// Parçacıklarda (CPUParticles3D renk eğrisi): örnek rengi alevi boyar ve sönümler
uniform bool use_color = false;
// Gün ışığı (0 gece, 1 gündüz; Flame.update_day gökyüzünden yazar): duran haleler gündüz söner (gün ışığında ateşin
// halesi görünmez). Parçacıklar (patlamanın ateş topu) sönmez.
uniform float day = 0.0;

varying float v_phase;
varying float v_top;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
	vec3 sc = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz));
	vec3 o = MODEL_MATRIX[3].xyz;
	v_phase = hash(o.xz * 0.37 + vec2(o.y));
	vec3 cam_r = INV_VIEW_MATRIX[0].xyz;
	vec3 cam_u = INV_VIEW_MATRIX[1].xyz;
	vec3 w;
	if (mode == 0) {
		// Yandan: dik kalır, yalnız kendi ekseninde kameraya döner. Yukarıdan: kameraya yatar, alevin ortasına oturur.
		vec3 to_cam = normalize(INV_VIEW_MATRIX[3].xyz - (o + vec3(0.0, sc.y * 0.4, 0.0)));
		float top = smoothstep(0.5, 0.9, to_cam.y);
		v_top = top;
		vec3 hr = vec3(cam_r.x, 0.0, cam_r.z);
		vec3 right = length(hr) > 1e-4 ? normalize(hr) : vec3(1.0, 0.0, 0.0);
		vec3 up = normalize(mix(vec3(0.0, 1.0, 0.0), cam_u, top));
		float hy = mix(sc.y, sc.x * 1.25, top);
		float wx = mix(sc.x, sc.x * 1.25, top);
		w = o + right * VERTEX.x * wx + up * (VERTEX.y - 0.5 * top) * hy + vec3(0.0, sc.y * 0.3 * top, 0.0);
	} else {
		v_top = 0.0;
		w = o + cam_r * VERTEX.x * sc.x + cam_u * VERTEX.y * sc.y;
	}
	VERTEX = (VIEW_MATRIX * vec4(w, 1.0)).xyz;
}

void fragment() {
	float t = TIME * speed + v_phase * 17.0;
	float glow = 1.0 - flicker + flicker * (0.6 * noise(vec2(t * 3.1, v_phase * 9.0)) + 0.4 * noise(vec2(t * 7.3, 2.0)));
	vec2 uv = UV;
	if (mode == 0) {
		float y = 1.0 - uv.y;                     // 0 dip, 1 uç
		float x = uv.x - 0.5;
		// Rüzgârda salınım (uca doğru artar) ve yukarı akan dil dil kıvrım
		x += (noise(vec2(t * 0.9, y * 1.5)) - 0.5) * 0.22 * y * y;
		float n = noise(vec2(x * 5.0, y * 3.0 - t * 2.4));
		// Damla biçimi: gövde dipte yuvarlak (merkez y 0,26), yukarı doğru incelerek sivrilir
		float cy = 0.26;
		float ry = y < cy ? cy : (1.0 - cy) * (0.82 + 0.18 * glow);
		float rx = mix(0.36, 0.05, smoothstep(cy, 1.0, y));
		vec2 q = vec2(x / rx, (y - cy) / ry);
		float d = length(q) + (n - 0.5) * 0.55 * smoothstep(0.1, 0.9, y);
		float a = smoothstep(1.0, 0.45, d);
		float core = smoothstep(0.62, 0.0, length(vec2(x / (rx * 0.55), (y - cy * 0.9) / (ry * 0.5))));
		vec3 col = mix(edge_color.rgb, core_color.rgb, core);
		// Uçta kızıla döner, ince is
		col = mix(col, edge_color.rgb * vec3(0.9, 0.5, 0.35), smoothstep(0.55, 1.0, y) * 0.6);
		// Yukarıdan: yuvarlak ateş, çevresinde dönen kızıl diller, ortada sarı kor
		vec2 p = (UV - vec2(0.5)) * 2.0;
		float r = length(p);
		float ang = atan(p.y, p.x);
		vec2 cs = vec2(cos(ang), sin(ang));
		float tn = noise(cs * 2.2 + vec2(t * 1.3, v_phase * 7.0)) * 0.65 + noise(cs * 4.5 + vec2(-t * 2.1, 3.0)) * 0.35;
		float rr = r * (0.8 + 0.55 * tn) * (0.92 + 0.08 * glow);
		float a_top = smoothstep(0.95, 0.45, rr);
		float core_top = smoothstep(0.6, 0.0, r * (0.9 + 0.3 * tn));
		vec3 col_top = mix(edge_color.rgb * vec3(0.95, 0.6, 0.45), edge_color.rgb, smoothstep(0.95, 0.55, rr));
		col_top = mix(col_top, core_color.rgb, core_top);
		col = mix(col, col_top, v_top);
		a = mix(a * (0.75 + 0.25 * core), a_top * (0.8 + 0.2 * core_top), v_top);
		ALBEDO = col * energy * glow;
		ALPHA = clamp(a, 0.0, 1.0);
		if (use_color) {
			ALBEDO *= mix(vec3(1.0), COLOR.rgb * 1.3, 0.6);
			ALPHA *= COLOR.a;
		}
	} else {
		float r = length(uv - vec2(0.5)) * 2.0;
		float a = exp(-r * r * 4.0) * (1.0 - smoothstep(0.85, 1.0, r));
		float hot = exp(-r * r * 30.0);
		// Parlaklık saydamlıkta: karanlıkta eski toplamalı hale ile aynı (renk × parlaklık), aydınlıkta yalnız ılık bir pus
		ALBEDO = mix(edge_color.rgb, core_color.rgb, hot);
		ALPHA = clamp(a * energy * glow, 0.0, 1.0);
		if (use_color) {
			ALBEDO *= mix(vec3(1.0), COLOR.rgb * 1.3, 0.7);
			ALPHA *= COLOR.a;
		} else {
			ALPHA *= 1.0 - 0.85 * day;
		}
	}
}
