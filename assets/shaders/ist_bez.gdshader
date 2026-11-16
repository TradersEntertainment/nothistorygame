// İstanbul v2: sancak ve çamaşır (MultiMesh; rüzgârda dalgalanan bez). Mesh: üst kenar y = 0, aşağı −1, x ∈ [−0,5; 0,5].
// Özel veri: x = renk A, y = renk B (dizin), z = desen, w = 0 sancak (direk kenarı x = −0,5 sabit) / 1 çamaşır (üst kenar sabit).
shader_type spatial;
render_mode cull_disabled, diffuse_lambert, specular_disabled;

uniform float gece = 0.0;
const vec3 BOYA[12] = vec3[](
	vec3(0.78, 0.14, 0.12), vec3(0.95, 0.93, 0.88), vec3(0.88, 0.70, 0.16), vec3(0.45, 0.14, 0.40),
	vec3(0.12, 0.12, 0.14), vec3(0.20, 0.34, 0.60), vec3(0.85, 0.72, 0.52), vec3(0.34, 0.50, 0.30),
	vec3(0.70, 0.40, 0.30), vec3(0.92, 0.85, 0.60), vec3(0.55, 0.62, 0.70), vec3(0.20, 0.45, 0.42));

varying vec2 v_uv;
varying vec4 v_cd;

void vertex() {
	vec4 cd = INSTANCE_CUSTOM;
	v_cd = cd;
	v_uv = UV;
	float ph = MODEL_MATRIX[3].x * 0.37 + MODEL_MATRIX[3].z * 0.21;
	vec3 v = VERTEX;
	float amp = cd.w > 0.5 ? -v.y : (v.x + 0.5);
	float t = TIME;
	if (cd.w > 0.5) {
		v.z += sin(t * 1.9 + ph + v.x * 3.0) * 0.1 * amp + sin(t * 3.1 + ph) * 0.03 * amp;
		v.x += sin(t * 1.3 + ph) * 0.05 * amp;
	} else {
		v.z += sin(v.x * 7.0 - t * 5.5 + ph) * 0.16 * amp + sin(v.x * 3.0 - t * 3.0 + ph) * 0.1 * amp;
		v.y += sin(v.x * 5.0 - t * 4.0 + ph) * 0.05 * amp;
	}
	VERTEX = v;
}

float disc(vec2 p, vec2 c, float r) { return step(length(p - c), r); }

void fragment() {
	vec3 A = BOYA[int(mod(v_cd.x, 12.0))];
	vec3 B = BOYA[int(mod(v_cd.y, 12.0))];
	int pat = int(v_cd.z + 0.5);
	vec2 uv = v_uv;
	vec3 c = A;
	if (pat == 1) {            // haç (Cenova/Venedik tarzı)
		if (abs(uv.x - 0.5) < 0.09 || abs(uv.y - 0.5) < 0.13) c = B;
	} else if (pat == 2) {     // yatay iki renk
		if (uv.y > 0.5) c = B;
	} else if (pat == 3) {     // hilal
		float d1 = disc(uv * vec2(1.5, 1.0), vec2(0.62, 0.5), 0.27);
		float d2 = disc(uv * vec2(1.5, 1.0), vec2(0.72, 0.5), 0.22);
		if (d1 > 0.5 && d2 < 0.5) c = B;
		if (length(uv * vec2(1.5, 1.0) - vec2(0.95, 0.5)) < 0.07) c = B;
	} else if (pat == 4) {     // çamaşır: dikey çizgili
		if (fract(uv.x * 4.0) < 0.35) c = B;
	} else if (pat == 5) {     // Paleologos: orta alan ve haç/çakmak taşı
		float dd = abs(uv.x - 0.5) * 1.6 + abs(uv.y - 0.5);
		if (dd < 0.3) c = B;
		if (abs(uv.x - 0.5) < 0.04 && abs(uv.y - 0.5) < 0.3) c = A;
	} else if (pat == 6) {     // alaca (iki şerit dikey)
		if (uv.x > 0.5) c = B;
	}
	c *= mix(1.0, 0.35, gece);
	ALBEDO = c;
	ROUGHNESS = 1.0;
}
