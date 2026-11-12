extends RefCounted
## SUR-4: sur taşı gölgelendiricisi (kalite notu 27 ve sahibinin "tahta kaplama gibi" sözü).
## Props'un "ashlar" dokusu 1,8 m'de bir 1,3 m taş + 0,55 m tuğla şeridi tekrarlıyordu: uzaktan eşit kalınlıkta
## açık-koyu şerit = kereste yığını. Burada doku dünya konumundan yordamsal çizilir (UV gerekmez; yakın, orta ve uzak
## katmanda AYNI desen, pişmiş ağlarda da köşe rengiyle çalışır):
##   tur 0 kara (Theodosius, opus mixtum): ~2,1 m kireçtaşı blok kuşağı (dört sıra, derzler şaşırtmalı, blok blok ton)
##          + İNCE tuğla hatılı (5 sıra tuğla, kalın harç; ~0,42 m), dönem 2,5 m
##   tur 1 deniz (Marmara, Haliç): daha kaba ve gri, düzensiz moloz yamalı, hatıl seyrek (3 sıra, dönem 3,4 m)
##   tur 2 Galata (Ceneviz): düzgün kesme taş sıraları, tuğla hatılsız, sıcak gri
## Yıpranma: dikey yağmur akıntıları, is/kararma lekeleri, dipte koyulaşma ve yosun (yerel y = zeminden yükseklik),
## ince ayrıntı ekran türevine göre söner (uzakta titreşmez; tuğla hatılı ince kızıl çizgi olarak kalır).
## catalog() yok; class_name yok (preload ile kullanılır).

const DESEN := ["ashlar", "ashlar_far"]

static var _mats := {}
static var _sh: Shader
static var _tex_ids := {}


static func _shader() -> Shader:
	if _sh != null:
		return _sh
	_sh = Shader.new()
	_sh.code = """
shader_type spatial;
render_mode diffuse_toon, specular_disabled;
uniform vec4 renk : source_color = vec4(1.0);
uniform float tur = 0.0;          // 0 kara, 1 deniz, 2 galata
uniform float yerel_dip = 1.0;    // 1: VERTEX.y zeminden yükseklik (dipte koyulaşma, yosun)
varying vec3 wpos;
varying vec3 wnrm;
varying float ly;

float h21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vn(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1.0, 0.0)), f.x), mix(h21(i + vec2(0.0, 1.0)), h21(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	ly = VERTEX.y;
}

void fragment() {
	vec3 base = pow(COLOR.rgb, vec3(2.2)) * renk.rgb;
	float lum = dot(base, vec3(0.3, 0.55, 0.15));
	// taş: soluk gri-krem (sıcak); taban rengin parlaklığı korunur
	float kat = clamp(lum / 0.42, 0.55, 1.0);
	vec3 tas = vec3(0.46, 0.42, 0.34);
	if (tur > 0.5 && tur < 1.5) { tas = vec3(0.43, 0.395, 0.335); }     // SUR-5: deniz suru sıcak gri (soğuk mavi-gri değil)
	if (tur > 1.5) { tas = vec3(0.45, 0.42, 0.36); }
	tas *= kat;
	vec3 tug = vec3(0.24, 0.12, 0.08) * clamp(kat, 0.7, 1.0);    // SUR-5: mat, koyu kiremit (parlak kırmızı şerit değil)
	vec3 harc = vec3(0.52, 0.48, 0.41) * kat;
	float dikey = 1.0 - step(0.6, abs(wnrm.y));
	vec2 t2 = normalize(vec2(-wnrm.z, wnrm.x) + vec2(1e-4, 0.0));
	float u = dot(wpos.xz, t2);
	float y = wpos.y;
	float fy = max(fwidth(y), 1e-4);
	float fu = max(fwidth(u), 1e-4);
	float fw = max(fy, fu);
	float ince = 1.0 - smoothstep(0.015, 0.07, fw);     // derz, taş sırası
	float ince_t = 1.0 - smoothstep(0.008, 0.017, fw);   // SUR-5: tek tek tuğla yalnız ~6 m'den yakında
	float orta = 1.0 - smoothstep(0.06, 0.25, fw);      // blok tonu
	float bant_g = 1.0 - smoothstep(0.30, 0.9, fy);    // tuğla hatılı
	vec3 c;
	// tuğla/kiremit/ahşap rengi yüzey (uzak pişmiş ağda köşe rengi): desen yok, yalnız yıpranma
	// (kızıllık oranı: tuğla r/g ≈ 1,9; koyu kesme taş r/g ≈ 1,1–1,25 — fark eşiği koyu taşı da tuğla sanıyordu)
	float duz = step(1.4 * COLOR.g * renk.g + 0.02, COLOR.r * renk.r);
	if (duz > 0.5) {
		c = base;
	} else if (dikey > 0.5) {
		float P = 2.5;
		float B = 0.42;
		float nk = 5.0;
		float kh = 0.42;    // taş sırası
		if (tur > 0.5 && tur < 1.5) { P = 3.4; B = 0.30; nk = 3.0; kh = 0.56; }
		if (tur > 1.5) { P = 1e6; B = 0.0; kh = 0.46; }
		float yy = y + 0.37;
		float per = floor(yy / P);
		float py = yy - per * P;
		bool bant = py < B;
		if (bant) {
			float r = py / (B / nk);
			float fr = fract(r);
			float bi = floor(r);
			float bl = 0.36;
			float off = mod(bi, 2.0) * 0.18;
			float bx = fract((u + off) / bl);
			float harc_m = max(step(fr, 0.34), step(bx, 0.05));
			float tt = 0.82 + 0.3 * h21(vec2(floor((u + off) / bl), bi + per * 7.0));
			vec3 bc = mix(tug * tt, harc, harc_m);
			vec3 ort = mix(mix(tug, harc, 0.5), tas, 0.3);      // SUR-5: uzaktan taşla aynı düzlemde mat bant
			c = mix(ort, bc, ince_t);
			c = mix(mix(tas, harc, 0.3), c, bant_g);
		} else {
			float sy = py - B;
			float si = floor(sy / kh);
			float sf = fract(sy / kh);
			float ci = si + per * 11.0;
			float bl = 0.85 + 0.75 * h21(vec2(ci, 3.1));
			if (tur > 1.5) { bl = 1.15; }
			float off = h21(vec2(ci, 9.7)) * bl;
			float bx = (u + off) / bl;
			float bid = floor(bx);
			float bf = fract(bx);
			float tn = h21(vec2(bid, ci));
			float tint = 0.84 + 0.24 * tn;
			vec3 tc = tas * tint;
			if (tn > 0.86) { tc *= vec3(1.04, 0.98, 0.86); }            // kumtaşı (sarımsı)
			if (tur > 0.5 && tur < 1.5) {
				// deniz: moloz yamaları (küçük düzensiz taş), daha gri
				float yama = vn(vec2(u * 0.12, y * 0.15) + 4.0);
				if (yama > 0.62) {
					vec2 q = vec2(u, y) * 3.2;
					float rt = h21(floor(q + vec2(floor(q.y) * 0.5, 0.0)));
					tc = tas * (0.72 + 0.3 * rt);
					vec2 fq = fract(q + vec2(floor(q.y) * 0.5, 0.0));
					float mj = max(step(fq.x, 0.12), step(fq.y, 0.14));
					tc = mix(tc, harc * 0.95, mj * ince);
				}
			}
			float jy = step(sf, 0.06 / kh * 0.5) + step(1.0 - 0.03 / kh, sf);
			float jx = step(bf, 0.035 / bl) ;
			float j = clamp(jy + jx, 0.0, 1.0);
			vec3 sc = mix(tc, harc * 0.92, j * 0.85);
			c = mix(tas * 0.96, tc, orta);
			c = mix(c, sc, ince);
		}
	} else {
		// yatay (yürüme yolu, kule terası): döşeme taşı
		vec2 q = wpos.xz / 0.9;
		float tn = h21(floor(q));
		vec2 fq = fract(q);
		float j = max(step(fq.x, 0.05), step(fq.y, 0.05));
		// SUR-5: sıcak, koyu kireçtaşı döşeme (gölgede gök ışığıyla camgöbeği karo okunuyordu); taş taş ton ve aşınma
		float tn2 = h21(floor(q) + 7.3);
		vec3 dos = tas * vec3(1.02, 0.9, 0.72) * (0.74 + 0.2 * tn + 0.06 * tn2);
		dos *= 1.0 - 0.18 * smoothstep(0.5, 0.9, vn(wpos.xz * 0.35));
		c = mix(dos, harc * vec3(0.8, 0.72, 0.6), j * ince);
	}
	// yıpranma: dikey akıntı, is lekesi, dipte koyulaşma ve yosun
	float aki = vn(vec2(u * 1.7, y * 0.09));
	aki = smoothstep(0.55, 0.95, aki) * dikey;
	float leke = vn(vec2(u * 0.07, y * 0.11) + vec2(wpos.x, wpos.z) * 0.013);
	float dip = yerel_dip > 0.5 ? ly : 50.0;
	float dipk = 1.0 - smoothstep(0.0, 3.2, dip);
	c *= 1.0 - aki * 0.16;
	c *= 1.0 - smoothstep(0.55, 0.9, leke) * 0.22;
	c *= 1.0 - dipk * 0.28;
	float yos = smoothstep(0.5, 0.85, vn(vec2(u * 0.4, y * 0.6) + 17.0)) * (1.0 - smoothstep(0.0, 2.4, dip));
	if (tur > 0.5 && tur < 1.5) { yos = max(yos, smoothstep(0.6, 0.9, vn(vec2(u * 0.3, y * 0.5) + 3.0)) * (1.0 - smoothstep(0.0, 4.0, dip))); }
	c = mix(c, vec3(0.20, 0.24, 0.12) * kat, yos * 0.35 * dikey);
	// uzak katman (pişmiş, köşe rengi açılmış): yakındaki derz/akıntı/dip kararmasının ortalaması kadar koyulaşır
	if (yerel_dip < 0.5) { c *= 0.84; }
	ALBEDO = c;
	ROUGHNESS = 0.95;
}
"""
	return _sh


## tur: 0 kara, 1 deniz, 2 galata. renk: taban rengi (köşe rengi olan pişmiş ağda beyaz). yerel_dip: VERTEX.y zemin.
static func mat(tur: int, renk := Color.WHITE, yerel_dip := true) -> ShaderMaterial:
	var key := "%d|%s|%s" % [tur, renk.to_html(), yerel_dip]
	if _mats.has(key):
		return _mats[key]
	var m := ShaderMaterial.new()
	m.shader = _shader()
	m.set_shader_parameter("renk", renk)
	m.set_shader_parameter("tur", float(tur))
	m.set_shader_parameter("yerel_dip", 1.0 if yerel_dip else 0.0)
	_mats[key] = m
	return m


static func _desen_mi(m: Material) -> bool:
	if not (m is StandardMaterial3D):
		return false
	var sm := m as StandardMaterial3D
	if sm.albedo_texture == null:
		return false
	if _tex_ids.is_empty():
		for d: String in DESEN:
			_tex_ids[Props._pattern_tex(d).get_rid()] = true
	return _tex_ids.has(sm.albedo_texture.get_rid())


## Düğümün altındaki "ashlar" desenli bütün yüzeyleri sur taşı gölgelendiricisine çevirir (pişirmeden SONRA çağrılır:
## pişirici yalnız StandardMaterial3D birleştirir). Dönen: değişen yüzey sayısı.
static func uygula(n: Node, tur: int) -> int:
	var say := 0
	for c in n.find_children("*", "GeometryInstance3D", true, false):
		if c is MeshInstance3D:
			var mi := c as MeshInstance3D
			if mi.mesh == null:
				continue
			if mi.material_override != null:
				if _desen_mi(mi.material_override):
					var sm := mi.material_override as StandardMaterial3D
					mi.material_override = mat(tur, Color.WHITE if sm.vertex_color_use_as_albedo else sm.albedo_color)
					say += 1
				continue
			for si in mi.mesh.get_surface_count():
				var m := mi.mesh.surface_get_material(si)
				if _desen_mi(m):
					var sm2 := m as StandardMaterial3D
					mi.set_surface_override_material(si, mat(tur, Color.WHITE if sm2.vertex_color_use_as_albedo else sm2.albedo_color))
					say += 1
		elif c is MultiMeshInstance3D:
			var mm := c as MultiMeshInstance3D
			if mm.material_override != null and _desen_mi(mm.material_override):
				var sm3 := mm.material_override as StandardMaterial3D
				mm.material_override = mat(tur, sm3.albedo_color)
				say += 1
	return say


## Hat adı → tur
static func tur_of(hat: String) -> int:
	match hat:
		"galata_suru":
			return 2
		"marmara_suru", "halic_suru":
			return 1
	return 0
