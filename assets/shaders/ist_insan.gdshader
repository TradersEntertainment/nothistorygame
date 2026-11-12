// İstanbul v2 yaşam katmanı: insan, hayvan ve tavuk (MultiMesh; tüm hareket GPU'da, CPU maliyeti yok).
// Örnek özel verisi (INSTANCE_CUSTOM):
//   x = renk dizini (tunik 0..15 + 16 * başlık 0..7) + evre (kesir)   [hayvanda: renk dizini 0..7]
//   y = yol boyu L (m; 0 = yerinde)      z = hız (m/sn)
//   w = davranış (0 yürü, 1 dur, 2 çalış, 3 eğil, 4 yük taşı, 5 otur) + 8 * alet + 0,5 + eğim (yükseklik/metre)
// Örnek dönüşümü: yolun BAŞI, ileri = yerel −z. Yol gidiş-dönüş (uçta dönüş); yürüyüş bacak ve kol salınımı köşe yüksekliğinden.
shader_type spatial;
render_mode cull_back, diffuse_lambert, specular_disabled;

uniform int mode = 0;           // 0 insan, 1 dört ayaklı, 2 tavuk
uniform float gece = 0.0;
// Yakında gerçek kişi katmanı (IstHayatYakin) varken: kameraya bu uzaklıktan (m) yakın figürler küçülerek kaybolur
// (yakin_bos .. yakin_bos + 10 m arasında boy 0 → 1; 0: kapalı). Küp figür yalnız uzakta ve havadan görünür.
uniform float yakin_bos = 0.0;

const vec3 TUNIK[16] = vec3[](
	vec3(0.55, 0.40, 0.27), vec3(0.78, 0.66, 0.45), vec3(0.24, 0.30, 0.50), vec3(0.62, 0.22, 0.18),
	vec3(0.42, 0.45, 0.25), vec3(0.88, 0.82, 0.66), vec3(0.16, 0.14, 0.13), vec3(0.28, 0.22, 0.17),
	vec3(0.45, 0.45, 0.46), vec3(0.70, 0.16, 0.14), vec3(0.52, 0.54, 0.58), vec3(0.92, 0.9, 0.84),
	vec3(0.20, 0.38, 0.55), vec3(0.58, 0.30, 0.50), vec3(0.50, 0.38, 0.22), vec3(0.18, 0.22, 0.38));
const vec3 SAPKA[8] = vec3[](
	vec3(0.30, 0.22, 0.15), vec3(0.88, 0.84, 0.72), vec3(0.12, 0.11, 0.10), vec3(0.72, 0.62, 0.34),
	vec3(0.55, 0.57, 0.60), vec3(0.62, 0.24, 0.20), vec3(0.80, 0.78, 0.70), vec3(0.20, 0.24, 0.40));
const vec3 HAYVAN[8] = vec3[](
	vec3(0.45, 0.40, 0.36), vec3(0.58, 0.45, 0.32), vec3(0.88, 0.86, 0.80), vec3(0.20, 0.17, 0.15),
	vec3(0.64, 0.52, 0.38), vec3(0.35, 0.26, 0.18), vec3(0.74, 0.66, 0.56), vec3(0.50, 0.50, 0.52));

varying vec3 v_col;

vec2 rot(vec2 p, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

void vertex() {
	vec4 cd = INSTANCE_CUSTOM;
	float idx = floor(cd.x);
	float ph = fract(cd.x);
	float L = cd.y;
	float spd = cd.z;
	float beh = mod(floor(cd.w), 8.0);
	float tool = floor(cd.w / 8.0);
	float slope = fract(cd.w) - 0.5;
	vec3 v = VERTEX;
	vec3 nn = NORMAL;
	float a = COLOR.a;
	bool walk = L > 0.05 && (beh < 0.5 || (beh > 3.5 && beh < 4.5));
	float u = 0.0;
	float s = 0.0;
	bool back = false;
	if (L > 0.05) {
		u = fract(TIME * spd / (2.0 * L) + ph);
		back = u >= 0.5;
		s = back ? 2.0 - u * 2.0 : u * 2.0;
	}
	float wt = TIME * spd * 4.6 + ph * 6.2832;
	if (mode == 0) {
		bool hasd = true;
		if (a > 0.2 && a < 0.3) {          // alet
			if (tool < 0.5) { v = vec3(0.0); hasd = false; }
		}
		if (hasd) {
			float swing = walk ? sin(wt) : 0.0;
			// bacaklar
			if (v.y < 0.8) {
				float sg = v.x > 0.0 ? 1.0 : -1.0;
				float ang = swing * sg * 0.62;
				vec2 q = rot(vec2(v.z, v.y - 0.8), ang);
				v.z = q.x;
				v.y = q.y + 0.8;
			}
			// kollar
			if (abs(v.x) > 0.215 && v.y > 0.7 && v.y < 1.45 && !(a > 0.2 && a < 0.3)) {
				float sg = v.x > 0.0 ? 1.0 : -1.0;
				float ang = -swing * sg * 0.5;
				if (beh > 1.5 && beh < 2.5) ang = (sin(TIME * 3.4 + ph * 6.2832) - 0.4) * 0.95;
				if (beh > 2.5 && beh < 3.5) ang = (sin(TIME * 1.7 + ph * 6.2832) - 0.9) * 0.8 - 0.5;
				if (beh > 3.5 && beh < 4.5) ang = -0.9;
				vec2 q = rot(vec2(v.z, v.y - 1.4), ang);
				v.z = q.x;
				v.y = q.y + 1.4;
			}
			// eğilme (çalışan, bostan, yük)
			float bend = 0.0;
			if (beh > 1.5 && beh < 2.5) bend = 0.28 + 0.1 * sin(TIME * 3.4 + ph * 6.2832);
			if (beh > 2.5 && beh < 3.5) bend = 0.95 + 0.08 * sin(TIME * 1.7 + ph * 6.2832);
			if (beh > 3.5 && beh < 4.5) bend = 0.3;
			if (bend > 0.0 && v.y > 0.88) {
				vec2 q = rot(vec2(v.z, v.y - 0.88), bend);
				v.z = q.x;
				v.y = q.y + 0.88;
			}
			// otur: boyu kıs
			if (beh > 4.5) v.y *= 0.6;
			// dururken hafif salınım
			if (beh > 0.5 && beh < 1.5) v.x += sin(TIME * 0.8 + ph * 40.0) * 0.012 * v.y;
			// yürürken hafif sekme
			if (walk) v.y += abs(sin(wt)) * 0.035;
		}
	} else if (mode == 1) {
		if (v.y < 0.64) {
			float sg = (v.x > 0.0) == (v.z > 0.0) ? 1.0 : -1.0;
			float ang = walk ? sin(wt * 0.9) * sg * 0.55 : 0.0;
			vec2 q = rot(vec2(v.z, v.y - 0.62), ang);
			v.z = q.x;
			v.y = q.y + 0.62;
		}
		if (beh > 1.5 && beh < 2.5 && v.z < -0.4 && v.y > 0.9) {   // otlama: baş yere
			float g = 0.5 + 0.5 * sin(TIME * 0.7 + ph * 30.0);
			vec2 q = rot(vec2(v.z + 0.4, v.y - 1.0), g * 0.9);
			v.z = q.x - 0.4;
			v.y = q.y + 1.0;
		}
		if (walk) v.y += abs(sin(wt * 0.9)) * 0.03;
	} else {
		if (beh > 1.5 || beh < 0.5) {      // gagalama
			float pk = max(0.0, sin(TIME * 2.4 * (0.7 + ph) + ph * 30.0) - 0.55) * 2.2;
			vec2 q = rot(vec2(v.z, v.y - 0.12), pk * 0.55);
			v.z = q.x;
			v.y = q.y + 0.12;
		}
		if (walk) v.y += abs(sin(wt * 2.0)) * 0.015;
	}
	if (back) {
		v.xz = -v.xz;
		nn.xz = -nn.xz;
	}
	v.z -= s * L;
	v.y += slope * s * L;
	if (yakin_bos > 0.0) {
		vec3 foot = vec3(0.0, slope * s * L, -s * L);
		vec3 wf = (MODEL_MATRIX * vec4(foot, 1.0)).xyz;
		float dc = distance(wf, INV_VIEW_MATRIX[3].xyz);
		float f = smoothstep(yakin_bos, yakin_bos + 10.0, dc);
		v = foot + (v - foot) * f;
	}
	VERTEX = v;
	NORMAL = nn;
	// renk
	vec3 col = COLOR.rgb;
	if (mode == 1 || mode == 2) {
		if (a > 0.9) col = HAYVAN[int(mod(idx, 8.0))] * COLOR.r;
	} else {
		if (a > 0.9) col = TUNIK[int(mod(idx, 16.0))] * COLOR.r;
		else if (a > 0.4 && a < 0.6) col = SAPKA[int(mod(floor(idx / 16.0), 8.0))] * COLOR.r;
	}
	v_col = col;
}

void fragment() {
	ALBEDO = v_col;
	ROUGHNESS = 1.0;
}
