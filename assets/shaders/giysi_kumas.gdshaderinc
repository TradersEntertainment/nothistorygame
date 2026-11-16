// GİYSİ KUMAŞI: ortak köşe bükümü (giysi_kumas.gdshader ve dış hattı giysi_kumas_hat.gdshader)
// GİYSİ KUMAŞI (scripts/npc/kumas.gd): karakterin pişmiş (CharKit.bake) ağında kumaş köşeleri UV ile işaretlidir:
//   UV.x = h  (0: bağlandığı yer — bel, omuz, sarık; 1: etek ucu)   UV.y = kip (0 kumaş değil, 1 etek/kaftan, 2 pelerin,
//   3 sarkan uç: yen, sarık yatırtması, püskül)
// Kumaş olmayan köşeler ve örnek uniform'u yazılmamış örnekler (kalabalığın pişmiş kopyaları, uzaktakiler) dokunulmadan
// çizilir. Köşe uzayı: pişirildiği eklemin (gövde) uzayı.
//   Etek: ekseni (0, y, 0) çevresinde; yay salınımı (kk_sw.xy) h² ile bükülür (tek parça kutu gibi dönmez), dönüşte
//   gecikme (kk_sw.z) ve açılma (kk_sw.w), dalga (kk_dg); bacak zarfı: her yükseklikte etek iki bacağın (uyluk, baldır
//   kapsülleri) kesitini sarar (bacağın içinden geçmez); zemin düzlemleri (kk_zl, kk_zr): etek ucu yere oturur, girmez.
//   Pelerin: salınım + çırpınma, gövde ve bacak kapsüllerinin dışına itilir. Sarkan uç: salınım + dalga.
// Malzeme CharKit.vc_mat ile aynı ışık modeli (köşe rengi, lambert wrap, rim, gölge almaz).
instance uniform vec4 kk_ek = vec4(0.0);   // x: bölge yarıçapı, y: etkin (0: dinlenme), z: bacak yarıçapı, w: oturak yüksekliği (0: ayakta)
instance uniform vec4 kk_sw = vec4(0.0);   // etek ucunun salınımı (x, z; m), burulma (rad), açılma (oran)
instance uniform vec4 kk_dg = vec4(0.0);   // dalga: x, z yönü (birim değil: rüzgâr), genlik (m), evre (sn)
instance uniform vec4 kk_hp = vec4(-0.1, 0.66, 0.1, 0.66);   // kalça eklemleri (sol x, y; sağ x, y; z = 0)
instance uniform vec4 kk_ul = vec4(0.0);   // sol diz (gövde uzayı)
instance uniform vec4 kk_al = vec4(0.0);   // sol bilek
instance uniform vec4 kk_ur = vec4(0.0);   // sağ diz
instance uniform vec4 kk_ar = vec4(0.0);   // sağ bilek
instance uniform vec4 kk_zl = vec4(0.0, 1.0, 0.0, 10.0);   // sol ayağın zemin düzlemi (n.xyz, d: n·p + d = 0)
instance uniform vec4 kk_zr = vec4(0.0, 1.0, 0.0, 10.0);   // sağ ayağın zemin düzlemi

vec3 _yakin(vec3 p, vec3 a, vec3 b) {
	vec3 ab = b - a;
	float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0);
	return a + ab * t;
}

// Etek yarıçapını bacak kapsülünün kesitini saracak kadar büyüt (u: köşenin eksenden yönü, c: eksenin yeri)
float _zarf(float r, vec3 v, vec2 c, vec2 u, vec3 a, vec3 b, float lr) {
	vec3 q = _yakin(v, a, b);
	float dy = v.y - q.y;
	if (abs(dy) >= lr) {
		return r;
	}
	float req = dot(q.xz - c, u) + sqrt(lr * lr - dy * dy) + 0.012;
	return max(r, req);
}

// Kapsülün dışına it (pelerin)
vec3 _it(vec3 v, vec3 a, vec3 b, float lr) {
	vec3 q = _yakin(v, a, b);
	vec3 d = v - q;
	float l = length(d);
	if (l >= lr || l < 1e-5) {
		return v;
	}
	return q + d / l * lr;
}

vec3 _zemin(vec3 v, vec4 pl, vec3 merkez, float bolge) {
	if (length(v.xz - merkez.xz) > bolge) {
		return v;
	}
	float s = dot(pl.xyz, v) + pl.w;
	if (s < 0.015) {
		v += pl.xyz * (0.015 - s);
	}
	return v;
}

vec3 kumas_buk(vec3 v0, vec2 uv, float zaman) {
	float kip = uv.y;
	if (kip > 0.5 && kk_ek.y > 0.5) {
		vec3 v = v0;
		float h = clamp(uv.x, 0.0, 1.0);
		float h2 = h * h;
		float t = zaman + kk_dg.w;
		vec3 hl = vec3(kk_hp.x, kk_hp.y, 0.0);
		vec3 hr = vec3(kk_hp.z, kk_hp.w, 0.0);
		float lr = kk_ek.z;
		if (kip < 1.5) {
			// ETEK / KAFTAN
			vec2 rel = v.xz;
			float r = length(rel);
			vec2 u = r > 1e-4 ? rel / r : vec2(0.0, 1.0);
			float tw = kk_sw.z * h2;
			float cs = cos(tw);
			float sn = sin(tw);
			u = vec2(u.x * cs - u.y * sn, u.x * sn + u.y * cs);
			float ang = atan(u.x, u.y);
			// Dalga: kıvrımlar etek boyunca akar (rüzgâr yönüne göre rüzgâraltı tarafı daha çok)
			float ruz = 0.5 + 0.5 * dot(u, normalize(kk_dg.xy + vec2(1e-4)));
			float dalga = kk_dg.z * h * (0.6 + 0.8 * ruz) * sin(ang * 4.0 + t * 3.1 - h * 5.0)
				+ kk_dg.z * 0.5 * h * sin(ang * 7.0 - t * 4.3);
			r = r * (1.0 + kk_sw.w * h2) + dalga;
			vec2 c = kk_sw.xy * h2;
			// Sarkaç: salınan etek ucu yükselir (boy korunur, kabaca)
			v.y += dot(c, c) * 0.9 * h;
			// Bacak zarfı (iki uyluk, iki baldır)
			r = _zarf(r, v, c, u, hl, kk_ul.xyz, lr);
			r = _zarf(r, v, c, u, kk_ul.xyz, kk_al.xyz, lr);
			r = _zarf(r, v, c, u, hr, kk_ur.xyz, lr);
			r = _zarf(r, v, c, u, kk_ur.xyz, kk_ar.xyz, lr);
			v.xz = c + u * r;
			if (kk_ek.w > 0.0) {
				// Oturan: dizlerin gerisindeki kumaş oturağın üstünde kalır (oturağın içinden geçmez)
				float kz = min(kk_ul.z, kk_ur.z) - 0.12;
				if (v.z < kz && v.y < kk_ek.w) {
					v.y = kk_ek.w + (kk_ek.w - v.y) * 0.08;
				}
			}
		} else if (kip < 2.5) {
			// PELERİN: salınım + çırpınma; gövdenin ve bacakların dışında
			vec2 c = kk_sw.xy * h2;
			v.xz += c;
			v.y += dot(c, c) * 0.6 * h;
			v.z += kk_dg.z * 1.5 * h * sin(v.x * 9.0 + t * 5.0 - h * 4.0);
			v.x += kk_dg.z * 0.6 * h * sin(t * 3.7 + h * 3.0);
			v = _it(v, vec3(0.0, 0.8, 0.0), vec3(0.0, 1.3, 0.0), 0.25);
			v = _it(v, hl, kk_ul.xyz, lr + 0.02);
			v = _it(v, kk_ul.xyz, kk_al.xyz, lr + 0.02);
			v = _it(v, hr, kk_ur.xyz, lr + 0.02);
			v = _it(v, kk_ur.xyz, kk_ar.xyz, lr + 0.02);
		} else {
			// SARKAN UÇ (yen, yatırtma, püskül)
			vec2 c = kk_sw.xy * h2 * 0.8;
			v.xz += c;
			v.y += dot(c, c) * 0.8 * h;
			v.x += kk_dg.z * h * sin(t * 4.1 + h * 3.0);
			v.z += kk_dg.z * 0.7 * h * sin(t * 3.3 + 1.7);
		}
		if (kip < 2.5) {
			v = _zemin(v, kk_zl, kk_al.xyz, kk_ek.x);
			v = _zemin(v, kk_zr, kk_ar.xyz, kk_ek.x);
		}
		return v;
	}
	return v0;
}

