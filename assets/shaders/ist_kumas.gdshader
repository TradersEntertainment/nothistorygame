// TUR-12 KUMAŞ: rüzgârda dalgalanan bayrak / sancak / flama, hafifçe nefes alan sarkık kumaş (tente, çadır perdesi,
// çamaşır, tuğ püskülü). Fizik gövdesi YOK: yalnız köşe gölgelendiricisi (bütçe: ağ başına birkaç ALU).
// Ağ verisi (scripts/world/ist/kumas.gd yazar):
//   UV.y  = kip: 0 sabit (direk, alem, ip: kıpırdamaz) · 1 bayrak · 2 sarkık kumaş
//   kip 1: UV.x = direkten uzaklık (m), UV2 = direk ekseninin yerel (x, z)'si. Bayrak gölgelendiricide DÜNYA rüzgâr
//          yönüne yeniden kurulur: direk kenarı (UV.x = 0) yerinde, serbest uç rüzgâr altında dalgalı, hafif sarkık.
//          Böylece aynı sahnedeki bütün bayraklar (kurucu hangi yöne kurmuş olursa olsun) aynı yöne uçar.
//   kip 2: UV.x = ağırlık (0 tutturulmuş kenar … 1 serbest), UV2.x = evre. Yüzey normali boyunca çok hafif nefes +
//          rüzgâr yönünde az salınım.
// Uzakta (lod_bas … lod_son m) dalga söner; bayrak rüzgâr altında durur. Gece/gündüz aynı (ışık sahnenin).
shader_type spatial;
render_mode cull_disabled, diffuse_toon, specular_disabled;

// rüzgârın estiği yön (dünya, yatay): bayraklar bu yöne uçar. Bütün kumaş malzemeleri aynı değeri kullanır.
uniform vec3 ruzgar = vec3(0.62, 0.0, 0.78);
uniform float guc = 1.0;
uniform float lod_bas = 55.0;
uniform float lod_son = 110.0;
// köşe rengi sRGB mi (Props kökenli bayraklar) yoksa doğrusal mı (ordugâh Bld: vmat ile aynı ayar, çarpan 0,78/0,76/0,72)
uniform bool renk_srgb = true;
uniform vec3 carpan = vec3(1.0);

void vertex() {
	float kip = UV.y;
	if (kip > 0.5) {
		vec3 W = normalize(vec3(ruzgar.x, 0.0, ruzgar.z) + vec3(1e-4, 0.0, 0.0));
		vec3 UP = vec3(0.0, 1.0, 0.0);
		vec3 P = normalize(cross(UP, W));
		mat4 inv = inverse(MODEL_MATRIX);
		if (kip < 1.5) {
			// ---- bayrak
			vec3 eks = (MODEL_MATRIX * vec4(UV2.x, 0.0, UV2.y, 1.0)).xyz;
			vec3 anc = (MODEL_MATRIX * vec4(UV2.x, VERTEX.y, UV2.y, 1.0)).xyz;
			float ph = eks.x * 0.37 + eks.z * 0.21;
			float cam = length(eks - CAMERA_POSITION_WORLD);
			float f = guc * (1.0 - smoothstep(lod_bas, lod_son, cam));
			float d = UV.x;
			float t = TIME;
			// esinti: sarkma açısı 0,16…0,34 rad arası yavaşça değişir
			float es = 0.5 + 0.5 * sin(t * 0.53 + ph) * sin(t * 0.31 + ph * 1.3);
			float dr = mix(0.34, 0.16, es * f + (1.0 - f) * 0.5);
			float kd = cos(dr);
			float sd = sin(dr);
			// dalga: direkten uca doğru büyür (direk kenarı sabit); 1,5 m'den sonra genlik doygun
			float amp = (0.10 + 0.05 * es) * min(d, 1.6) + 0.035 * max(d - 1.6, 0.0);
			float k1 = 2.6;
			float w1 = 5.2 + 1.4 * es;
			float s1 = sin(d * k1 - t * w1 + ph);
			float s2 = sin(d * 4.7 - t * 8.3 + ph * 1.7 + VERTEX.y * 1.3);
			float wav = (s1 * 0.8 + s2 * 0.2) * amp * f;
			float dwav = ((cos(d * k1 - t * w1 + ph) * k1 * 0.8 + cos(d * 4.7 - t * 8.3 + ph * 1.7 + VERTEX.y * 1.3) * 4.7 * 0.2) * amp
				+ (s1 * 0.8 + s2 * 0.2) * (d < 1.6 ? 0.10 + 0.05 * es : 0.035)) * f;
			// dalga boyunca kumaş kısalır (gerilmez): uç hafifçe direğe yaklaşır
			float kis = d * (1.0 - 0.04 * f * abs(s1));
			vec3 p = anc + W * (kis * kd) - UP * (kis * sd) + P * wav;
			vec3 dPdd = W * kd - UP * sd + P * dwav;
			vec3 nw = normalize(cross(-UP, dPdd));
			VERTEX = (inv * vec4(p, 1.0)).xyz;
			NORMAL = normalize((inv * vec4(nw, 0.0)).xyz);
		} else {
			// ---- sarkık kumaş (tente, perde, çamaşır, püskül): çok hafif nefes
			vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
			float cam = length(wp - CAMERA_POSITION_WORLD);
			float f = guc * (1.0 - smoothstep(lod_bas, lod_son, cam));
			float w = clamp(UV.x, 0.0, 1.0);
			float ph = UV2.x + wp.x * 0.23 + wp.z * 0.17;
			float t = TIME;
			float nef = sin(t * 1.15 + ph) * 0.6 + sin(t * 2.3 + ph * 1.9 + wp.y * 0.8) * 0.4;
			vec3 wm = (inv * vec4(W, 0.0)).xyz;
			VERTEX += NORMAL * (nef * 0.035 * w * f) + wm * ((0.5 + 0.5 * sin(t * 0.9 + ph)) * 0.05 * w * f);
		}
	}
}

void fragment() {
	vec3 c = COLOR.rgb;
	if (renk_srgb) {
		c = mix(pow((c + vec3(0.055)) * (1.0 / 1.055), vec3(2.4)), c * (1.0 / 12.92), lessThan(c, vec3(0.04045)));
	}
	ALBEDO = c * carpan;
	ROUGHNESS = 1.0;
	RIM = 0.2;
	RIM_TINT = 0.6;
}
