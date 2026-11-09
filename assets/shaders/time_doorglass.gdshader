// Zaman Bürosu koridoru: buzlu kapı camı. Kapının ardında yılın ışığı yanar.
// Ucuz: UV tabanlı, 2 gürültü örneği + 1 zaman gürültüsü. Doku yok.
// QuadMesh/PlaneMesh üzerinde kullan, +Z (ön) koridora baksın.
shader_type spatial;
render_mode unshaded, fog_disabled;

uniform vec4 era_color : source_color = vec4(1.0, 0.45, 0.12, 1.0);   // 1453: ateş turuncusu, 2150: camgöbeği
uniform float flicker : hint_range(0.0, 1.0) = 0.3;                    // titreme miktarı (ateş: 0.7, steril 2150: 0.05)
uniform float flicker_speed = 9.0;
uniform float intensity : hint_range(0.0, 3.0) = 1.0;                  // oyundan tween et: kapı yaklaşınca parlasın
uniform vec4 frost_color : source_color = vec4(0.72, 0.78, 0.80, 1.0);
uniform float frost_scale = 38.0;
uniform vec2 light_center = vec2(0.5, 0.62);                           // kapının ardındaki ışık kaynağı (UV)

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec2 uv = UV;
	float f1 = vnoise(uv * vec2(frost_scale, frost_scale * 1.6));
	float f2 = vnoise(uv * frost_scale * 3.1 + 7.0);
	float frost = f1 * 0.65 + f2 * 0.35;

	vec2 c = (uv - light_center) * vec2(1.6, 1.0);
	float glow = exp(-dot(c, c) * 3.2) * (0.75 + 0.5 * frost);

	// titreme: yumuşak gürültü + ara sıra ani düşüş
	float fl = vnoise(vec2(TIME * flicker_speed, 3.7));
	float dip = step(0.93, vnoise(vec2(TIME * 1.3, 9.1)));
	float k = 1.0 - flicker * (fl * 0.7 + dip * 0.5);

	vec3 base = frost_color.rgb * 0.10 * (0.7 + 0.6 * frost);
	vec3 col = base + era_color.rgb * glow * intensity * k * (0.55 + 0.9 * frost);
	col += vec3(1.0) * pow(glow, 4.0) * 0.15 * k * intensity;   // sıcak/soğuk çekirdek

	float edge = max(abs(uv.x - 0.5), abs(uv.y - 0.5)) * 2.0;
	col *= 1.0 - smoothstep(0.75, 1.0, edge) * 0.5;

	float fr = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 3.0);
	col += frost_color.rgb * fr * 0.15;
	ALBEDO = max(col, vec3(0.0));
}
