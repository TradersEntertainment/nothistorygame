// Çimen öbeği: sapların dibi koyu, ucu açık; uçlar rüzgârda salınır (dibi sabit).
// Köşe rengi (dip/uç tonu) x örnek rengi (MultiMesh) ile çarpılır. Çift yüzlü.
shader_type spatial;
render_mode cull_disabled, diffuse_lambert, specular_disabled;

uniform float wind = 0.08;
uniform float speed = 1.6;

float h(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float tip = clamp(VERTEX.y / 0.5, 0.0, 1.0);
	float ph = h(floor(w.xz * 0.5)) * 6.28;
	float s = sin(TIME * speed + w.x * 0.35 + w.z * 0.2 + ph) + 0.4 * sin(TIME * speed * 2.3 + w.z * 0.9);
	VERTEX.x += s * wind * tip * tip;
	VERTEX.z += s * wind * 0.5 * tip * tip;
}

void fragment() {
	ALBEDO = COLOR.rgb;
	// Arka yüz de ışık alsın (ince sap)
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	ROUGHNESS = 1.0;
	BACKLIGHT = vec3(0.25, 0.3, 0.15);
}
