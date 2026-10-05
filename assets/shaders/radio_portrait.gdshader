shader_type canvas_item;
// Telsizden konuşanın kartı (Hud): canlı kafa hafif yeşile çalan, tarama çizgili, cızırtılı bir görüntü olur.
// Konuşan sahnede değil, uzakta; ama yüzü yine oynar.

uniform float lines = 112.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	// Arada bir yatay kayma (sinyal zayıflaması)
	float band = step(0.985, hash(vec2(floor(TIME * 9.0), floor(uv.y * 24.0))));
	uv.x += band * 0.02 * sin(TIME * 40.0);
	vec4 c = texture(TEXTURE, uv);
	float g = dot(c.rgb, vec3(0.3, 0.59, 0.11));
	vec3 tint = mix(c.rgb, vec3(g) * vec3(0.78, 1.0, 0.86), 0.5);
	float scan = 0.84 + 0.16 * sin(uv.y * lines * 6.2832);
	float grain = (hash(uv * 224.0 + fract(TIME * 13.0)) - 0.5) * 0.09;
	float vig = smoothstep(0.78, 0.3, distance(uv, vec2(0.5)));
	COLOR = vec4((tint * scan + grain) * mix(0.62, 1.0, vig), c.a);
}
