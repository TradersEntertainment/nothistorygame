// Alev ve ışık halesi (Flame): kameraya dönen dörtgen üstünde yumuşak kenarlı, titreyen, aşağıdan yukarı incelen alev
// (mode 0) ya da yuvarlak sıcak hale (mode 1). Toplamalı karışım: üst üste binen alevler parlar, siyah kenar yok.
// Çoklu ağda (MultiMesh) her örneğin evresi dünyadaki yerinden gelir: yan yana iki alev aynı anda titremez.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;

uniform int mode = 0;
uniform vec4 core_color : source_color = vec4(1.0, 0.93, 0.62, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 0.42, 0.08, 1.0);
uniform float energy = 1.6;
uniform float speed = 1.0;
uniform float flicker = 0.25;
// Parçacıklarda (CPUParticles3D renk eğrisi): örnek rengi alevi boyar ve sönümler
uniform bool use_color = false;

varying float v_phase;

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
	mat4 bb;
	if (mode == 0) {
		// Dik kalır, yalnız kendi ekseninde kameraya döner
		vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz));
		vec3 fwd = normalize(cross(right, vec3(0.0, 1.0, 0.0)));
		bb = mat4(vec4(right, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(fwd, 0.0), vec4(o, 1.0));
	} else {
		bb = mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], vec4(o, 1.0));
	}
	MODELVIEW_MATRIX = VIEW_MATRIX * bb * mat4(vec4(sc.x, 0.0, 0.0, 0.0), vec4(0.0, sc.y, 0.0, 0.0), vec4(0.0, 0.0, sc.z, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
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
		ALBEDO = col * energy * glow;
		ALPHA = clamp(a * (0.75 + 0.25 * core), 0.0, 1.0);
		if (use_color) {
			ALBEDO *= mix(vec3(1.0), COLOR.rgb * 1.3, 0.6);
			ALPHA *= COLOR.a;
		}
	} else {
		float r = length(uv - vec2(0.5)) * 2.0;
		float a = exp(-r * r * 4.0) * (1.0 - smoothstep(0.85, 1.0, r));
		float hot = exp(-r * r * 30.0);
		ALBEDO = mix(edge_color.rgb, core_color.rgb, hot) * energy * glow;
		ALPHA = clamp(a, 0.0, 1.0);
		if (use_color) {
			ALBEDO *= mix(vec3(1.0), COLOR.rgb * 1.3, 0.7);
			ALPHA *= COLOR.a;
		}
	}
}
