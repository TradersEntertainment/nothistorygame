// İstanbul v2: baca/fırın/demirci dumanı (MultiMesh dörtgenleri, kameraya döner). Her sütun dört kabarcık (evre aralıklı).
// Örnek dönüşümü: baca ağzı; ölçek = kabarcık boyu. Özel veri: x = evre, y = yükselme boyu (m), z = süre (sn), w = tür (0 ocak, 1 fırın, 2 demirci).
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled, skip_vertex_transform;

uniform vec3 ruzgar = vec3(1.7, 0.0, -0.9);
uniform float gece = 0.0;

varying float v_t;
varying float v_tur;
varying float v_ph;

void vertex() {
	vec4 cd = INSTANCE_CUSTOM;
	float t = fract(TIME / cd.z + cd.x);
	v_t = t;
	v_tur = cd.w;
	v_ph = cd.x * 13.0;
	vec3 sc = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), 1.0);
	vec3 o = MODEL_MATRIX[3].xyz;
	o += vec3(0.0, t * cd.y, 0.0) + ruzgar * (t * t * cd.y * 0.45 + t * 0.6);
	o.x += sin(t * 6.0 + cd.x * 20.0) * 0.4 * t;
	float size = sc.x * (0.5 + 1.7 * t);
	vec3 cr = INV_VIEW_MATRIX[0].xyz;
	vec3 cu = INV_VIEW_MATRIX[1].xyz;
	vec3 w = o + cr * VERTEX.x * size + cu * VERTEX.y * size;
	VERTEX = (VIEW_MATRIX * vec4(w, 1.0)).xyz;
}

void fragment() {
	vec2 q = UV - 0.5;
	float d = length(q) * 2.0;
	float a = smoothstep(1.0, 0.25, d) * smoothstep(0.0, 0.1, v_t) * (1.0 - v_t);
	a *= 0.6 + 0.4 * sin(atan(q.y, q.x) * 3.0 + v_ph);
	vec3 c = vec3(0.78, 0.77, 0.74);
	float k = 0.58;
	if (v_tur > 1.5) { c = vec3(0.2, 0.19, 0.19); k = 0.7; }
	else if (v_tur > 0.5) { c = vec3(0.95, 0.94, 0.92); k = 0.62; }
	c *= mix(1.0, 0.32, gece);
	ALBEDO = c;
	ALPHA = a * k;
}
