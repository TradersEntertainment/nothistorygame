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
uniform float gece = 0.0;         // TUR-10: sahnenin gece payı (0 gündüz … 1 gece; SurGeceIzle günceller)
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
	// TUR-7: kireçtaşı daha açık; büyük ölçekte soğuk (gri) / sıcak (bal) lekeler: sur, zemin ve çadırdan ayrışır
	// TUR-10: yakından (oyuncu gözü 0,5–3 m) "oyuncak": düz beyaz levha. Kireçtaşı bir ton koyu ve gri (yıpranmış taş),
	// ton farkı blok blok, kir/akıntı/yosun aşağıda daha güçlü.
	vec3 tas = vec3(0.465, 0.445, 0.40);   // TUR-7: gri-krem kireçtaşı; TUR-10: bir ton koyu (eski 0,51 0,49 0,44)
	if (tur > 0.5 && tur < 1.5) { tas = vec3(0.43, 0.395, 0.335); }     // SUR-5: deniz suru sıcak gri (soğuk mavi-gri değil)
	if (tur > 1.5) { tas = vec3(0.45, 0.42, 0.36); }
	tas *= kat;
	if (tur < 0.5) {
		float sl = vn(vec2(dot(wpos.xz, vec2(0.707, 0.707)) * 0.09, wpos.y * 0.13) + 31.0);
		tas = mix(tas * vec3(0.92, 0.95, 0.99), tas * vec3(1.04, 0.99, 0.91), smoothstep(0.25, 0.75, sl));
	}
	// TUR-7: hatıl belirgin kiremit kırmızısı (yayındaki bölümlerin sur görünüşü)
	// TUR-10: tuğla doygunluğu düşük (kahve-kiremit; eski 0,37 0,14 0,085 doygun kırmızı = Lego), harç kirli bej-gri
	vec3 tug = vec3(0.30, 0.165, 0.115) * clamp(kat, 0.7, 1.0);
	vec3 harc = vec3(0.40, 0.355, 0.31) * kat;     // kireç + tuğla tozu (Bizans harcı: kirli pembemsi bej-gri)
	// yakınlık (ekran türevi): yalnız yakında görünen ince ayrıntı (kenar pürüzü, taş/tuğla yüzü dokusu)
	float fwy = fwidth(wpos.y) + 1e-5;
	float yakin = 1.0 - smoothstep(0.003, 0.012, fwy);
	// TUR-8: desen yönü GEOMETRİK normalden (ekran türevi). Gölgelendirme normali yukarı yatırılmış yüzler (hendek iç
	// yüzü: fn + UP·0,9 → y 0,78) "yatay döşeme" sanılıyor, 0,9 m'lik xz ızgarası dik yüzde DİKEY ŞERİT (perde) çiziyordu.
	// Türev GÖRÜŞ uzayındaki konumdan (küçük sayılar): şehirde dünya x ≈ −1700'de float türevi gürültülü (yakın yüz
	// dikey parazit, desen sönüyordu)
	vec3 gnv = cross(dFdx(VERTEX), dFdy(VERTEX));
	vec3 gnr = normalize(mat3(INV_VIEW_MATRIX) * gnv + vec3(0.0, 1e-9, 0.0));
	float dikey = 1.0 - step(0.6, abs(gnr.y));
	// sıra yönü yumuşak normalin YATAY bileşeninden (yatırılmış normalde de doğru yön; türev normali 1700 m'lik
	// koordinatla çarpılınca u'yu titretir)
	vec2 t2 = normalize(vec2(-wnrm.z, wnrm.x) + vec2(1e-4, 0.0));
	float u = dot(wpos.xz, t2);
	float y = wpos.y;
	float fy = max(fwidth(y), 1e-4);
	float fu = max(fwidth(u), 1e-4);
	float fw = max(fy, fu);
	float ince = 1.0 - smoothstep(0.015, 0.07, fw);     // derz, taş sırası
	float orta = 1.0 - smoothstep(0.06, 0.25, fw);      // blok tonu
	float bant_g = 1.0 - smoothstep(0.30, 0.9, fy);    // tuğla hatılı
	vec3 c;
	// TUR-11: köşe alfası işareti (pişiricide korunur): < 0,75 döküntü taşı; 0,75–0,86 harpuşta (diş tepe taşı);
	// 0,86–0,95 ince taş örgü (mazgal dişi ve korkuluk: oyuncu 0,5–2 m'de; tuğla hatılı yok)
	float ca = COLOR.a * renk.a;
	float harp = step(0.75, ca) * (1.0 - step(0.86, ca));
	float orgu = step(0.86, ca) * (1.0 - step(0.95, ca));
	// TUR-11: sahte kabartma (taş kenarı yuvarlanmış, derz girintili): (u, y) yönünde normal eğimi; dik yüzde uygulanır
	vec2 egim2 = vec2(0.0);
	// TUR-14: türev kabartması (harpuşta, kesme taş, döşeme): yükseklik bh (m), görüş uzayında yüzey eğimi ile normal
	float bh = 0.0;
	float bk = 0.0;
	// tuğla/kiremit/ahşap rengi yüzey (uzak pişmiş ağda köşe rengi): desen yok, yalnız yıpranma
	// (kızıllık oranı: tuğla r/g ≈ 1,9; koyu kesme taş r/g ≈ 1,1–1,25 — fark eşiği koyu taşı da tuğla sanıyordu)
	float duz = step(1.4 * COLOR.g * renk.g + 0.02, COLOR.r * renk.r);
	if (duz > 0.5) {
		c = base;
	} else if (harp > 0.5 || (orgu > 0.5 && dikey < 0.5 && abs(gnr.y) < 0.97)) {
		// TUR-11: harpuşta (dişin tepe taşı; yıkık dişin kırık tepesi): TEK taş, derzsiz; kenar yuvarlanması geometride (pah).
		// TUR-14 ("yakında ve gölgede koyu, yeşilimsi, pürüzsüz kapak"; Mesoteikhion, Blakherna, deniz): sarımsı taş ×
		// mavi gök ışığı gölgede yeşile kaçıyordu, koyu liken + yosun (yeşil) üstte %55'e varıyordu, yüz pürüzsüzdü.
		// Şimdi: açık, sıcak gri kireçtaşı (kızıla çekik: gölgede yeşil değil), taş taş ton (köşe renginden), kaba yontu
		// (keski izi: paralel kısa oluklar), dane, çukurcuk, kılcal çatlak KABARTMA olarak (türev normali); liken seyrek ve
		// gri-sarı, yosun yalnız lekeler halinde ve zayıf. Gece duvardan az kararır (seçilsin). Aynı yol kemer kama taşı ve
		// iç poterna kesme taşında (köşe alfası 0,8).
		vec2 hp = vec2(wpos.x + wpos.y * 0.71, wpos.z - wpos.y * 0.63);
		float sid = h21(vec2(floor(COLOR.r * 211.0), floor(COLOR.b * 157.0 + COLOR.g * 89.0)));
		vec3 hcol = tas * vec3(1.13, 1.06, 0.97) * (0.9 + 0.16 * vn(hp * 1.7 + 3.0));
		hcol *= 0.88 + 0.22 * sid;
		hcol *= mix(vec3(0.97, 0.99, 1.02), vec3(1.04, 1.0, 0.93), h21(vec2(sid * 7.0, 2.0)));
		// kaba yontu: taştan taşa değişen yönde kısa paralel keski oluğu (yakında)
		float ya = sid * 3.1;
		vec2 yd = vec2(cos(ya), sin(ya));
		float yon = vn(vec2(dot(hp, yd) * 34.0, dot(hp, vec2(-yd.y, yd.x)) * 5.0) + sid * 19.0);
		float olk = smoothstep(0.55, 0.8, yon);
		float dane = vn(hp * 26.0);
		float cuk = smoothstep(0.66, 0.9, vn(hp * 9.0 + 11.0));
		hcol *= 1.0 + 0.16 * (dane - 0.5) * yakin;
		hcol *= 1.0 - 0.12 * olk * yakin;
		hcol *= 1.0 - 0.14 * cuk * ince;                                                    // çukurcuk
		float ust = smoothstep(0.5, 0.95, abs(gnr.y));
		float hl1 = smoothstep(0.66, 0.8, vn(hp * 5.3 + 7.0 + COLOR.r * 13.0));
		hcol = mix(hcol, tas * vec3(1.16, 1.1, 0.92), hl1 * (0.3 + 0.2 * ust) * orta);       // açık sarımsı gri liken
		float hl2 = smoothstep(0.76, 0.88, vn(hp * 11.0 + 23.0));
		hcol = mix(hcol, tas * vec3(0.66, 0.63, 0.6), hl2 * 0.3 * orta);                  // koyu liken (seyrek, gri)
		float hy = smoothstep(0.7, 0.86, vn(hp * 3.1 + 41.0)) * ust;
		hcol = mix(hcol, vec3(0.24, 0.24, 0.16) * kat, hy * 0.16 * orta);                 // yosun (lekeler, zayıf)
		// kılcal çatlak (yakında; kabartmada da)
		float catv = 1.0 - smoothstep(0.0, 0.03, abs(vn(hp * 2.2 + 61.0) - 0.5));
		float cat = catv * step(0.55, h21(floor(hp * 0.8)));
		hcol *= 1.0 - 0.3 * cat * yakin;
		// taşın alt yüzü (taşkın kenarın altı) gölgede: göz hizasında açık şerit okunmasın
		hcol *= mix(1.0, 0.55, smoothstep(-0.4, -0.8, gnr.y));
		c = hcol;
		bh = (dane - 0.5) * 0.004 - olk * 0.0035 - cuk * 0.004 - cat * 0.003;
		bk = yakin;
	} else if (dikey > 0.5 && orgu > 0.5) {
		// TUR-11: ince taş örgü (mazgal dişi, korkuluk): "dişin önü düz tek ton levha" (0,42 m'lik sur sırası 0,6 m'lik dişe hiç
		// derz düşürmüyordu; korkuluğa tuğla hatılı göz hizasında iri şerit). Sıra ≈ 0,2 m (dişte 3 sıra), blok 0,3–0,62 m,
		// derz 1,5–2,4 cm (girintili, koyu), blok blok ton, aşınmış kenar, kırık köşe, liken; kabartma normalle.
		float hf = 0.5 * fy;
		float hu = 0.5 * fu;
		float okh = 0.2;
		float odl = (vn(vec2(u * 2.3, y * 1.7) + 3.0) - 0.5) * 0.03 * ince;
		float osy = y + odl + 0.07;
		float osi = floor(osy / okh);
		float osf = fract(osy / okh);
		float obl = 0.3 + 0.32 * h21(vec2(osi, 5.1));
		float ooff = h21(vec2(osi, 2.7)) * obl;
		float obx = (u + ooff + (vn(vec2(u * 3.1, y * 4.3) + 1.0) - 0.5) * 0.025 * ince) / obl;
		float obid = floor(obx);
		float obf = fract(obx);
		float otn = h21(vec2(obid, osi));
		float otn2 = h21(vec2(obid + 4.1, osi + 1.9));
		vec3 tc = tas * (0.74 + 0.36 * otn);
		tc *= mix(vec3(0.95, 0.98, 1.04), vec3(1.06, 1.0, 0.9), h21(vec2(obid + 5.3, osi)));
		tc = mix(tc, tas * vec3(0.7, 0.7, 0.72), step(0.9, otn2) * 0.7);
		float okx = min(obf, 1.0 - obf) * obl;
		float oky = min(osf, 1.0 - osf) * okh;
		float opur = (vn(vec2(u * 11.0, y * 11.0) + osi) - 0.5) * 0.03;
		float oew = 0.025 + 0.045 * h21(vec2(obid + 2.9, osi + 1.7));
		tc *= mix(1.0, mix(0.72, 1.0, smoothstep(0.0, oew, min(okx, oky) + opur)), ince);
		float okh1 = h21(vec2(obid + 7.7, osi + 2.3));
		float okxs = (h21(vec2(obid, osi + 4.4)) > 0.5 ? obf : 1.0 - obf) * obl;
		float okys = (okh1 > 0.75 ? osf : 1.0 - osf) * okh;
		float okr = 0.04 + 0.08 * h21(vec2(obid + 3.3, osi + 8.1));
		tc = mix(tc, tc * vec3(0.62, 0.6, 0.57), step(okh1, 0.45) * (1.0 - smoothstep(okr * 0.75, okr, okxs + okys * 1.2 + opur)) * orta);
		tc *= 1.0 + 0.16 * (vn(vec2(u * 21.0, y * 21.0) + osi) - 0.5) * yakin;
		float olik = smoothstep(0.68, 0.84, vn(vec2(u * 4.1, y * 4.6) + 21.0 + osi * 0.37));
		tc = mix(tc, tc * vec3(1.07, 1.04, 0.96), olik * 0.4 * orta);
		tc *= vec3(1.03, 1.0, 0.96);     // gölgede gök ışığıyla yeşile kaçmasın (sıcak gri)
		tc *= 1.0 - 0.1 * smoothstep(0.7, 0.92, vn(vec2(u * 16.0, y * 17.0) + 41.0)) * ince;
		float ojw = 0.018 + 0.006 * h21(vec2(osi, 7.0));
		float ojy0 = osf * okh;
		float ocJ = clamp((min(ojy0 + hf, ojw * 0.5) - max(ojy0 - hf, -ojw * 0.5)) / fy, 0.0, 1.0)
			+ clamp((min(ojy0 + hf - okh, ojw * 0.5) - max(ojy0 - hf - okh, -ojw * 0.5)) / fy, 0.0, 1.0);
		ocJ = fy > okh * 0.6 ? ojw / okh : clamp(ocJ, 0.0, 1.0);
		float ojx0 = obf * obl;
		float ocX = clamp((min(ojx0 + hu, 0.008) - max(ojx0 - hu, -0.008)) / fu, 0.0, 1.0)
			+ clamp((min(ojx0 + hu - obl, 0.008) - max(ojx0 - hu - obl, -0.008)) / fu, 0.0, 1.0);
		ocX = fu > obl * 0.6 ? 0.016 / obl : clamp(ocX, 0.0, 1.0);
		float oj = clamp(ocJ + ocX * (1.0 - ocJ), 0.0, 1.0);
		vec3 ocs = mix(tas * 0.95, tc, orta);
		c = mix(ocs, harc * 0.62, oj * 0.85);
		float eb = oew * 1.6;
		egim2 = vec2(smoothstep(eb, 0.0, (1.0 - obf) * obl + opur) - smoothstep(eb, 0.0, obf * obl + opur),
			smoothstep(eb, 0.0, (1.0 - osf) * okh + opur) - smoothstep(eb, 0.0, osf * okh + opur)) * 0.75 * ince;
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
		// TUR-8: hatıl kapsaması piksel izdüşümüyle süzülür (kutu süzgeç): yakında keskin, ortada ince kızıl çizgi, uzakta
		// dönemin ortalaması. Eski eşikli "söndürme" (fy > 0,34) orta mesafede suru tek tona çeviriyordu.
		float hf = 0.5 * fy;
		float covB = 0.0;
		if (B > 0.0) {
			covB = clamp((min(py + hf, B) - max(py - hf, 0.0)) / fy, 0.0, 1.0)
				+ clamp((min(py + hf - P, B) - max(py - hf - P, 0.0)) / fy, 0.0, 1.0)
				+ clamp((min(py + hf + P, B) - max(py - hf + P, 0.0)) / fy, 0.0, 1.0);
			covB = fy > P * 0.6 ? B / P : clamp(covB, 0.0, 1.0);
		}
		// TUR-10: harç tuğla kalınlığında (Theodosius: ≈4–5 cm tuğla, aynı kalınlıkta harç) → uzak ortalama yarı yarıya
		vec3 uzak_b = mix(tug * 0.9, mix(harc, tug * 1.25, 0.22) * 0.88, 0.47);       // mat kiremit (orta/uzak; yakındaki ortalama)
		vec3 bcol = uzak_b;
		if (bant) {
			// TUR-9: tuğla örgüsü eşikle değil KUTU SÜZGEÇLE (c2: eğik bakışta yatay sıkışma fw'yi büyütüp tuğlaları x≈720'de
			// birden düz turuncu şeride çeviriyordu). Sıra derzi y'de (fy), dikey derz u'da (fu) ayrı süzülür: yan bakışta
			// sıra çizgileri kalır, dikey derzler ortalamaya söner; uzakta her ikisi ortalama (uzak_b ile aynı ton).
			// TUR-10 ("oyuncak gibi", Bölüm 25 an_01): doygun kırmızı, bembeyaz ince harç, birbirinin kopyası tuğla = Lego.
			// Şimdi: sıra 8,4 cm = ≈4,5 cm tuğla + ≈3,9 cm harç (tuğladan tuğlaya oynar); sıra kaydırması düzensiz; tuğla
			// tonu tek tek (soluk, koyu fazla pişmiş, sarımsı az pişmiş); harç kirli, yer yer oyulmuş, üst tuğlanın gölgesinde;
			// tuğla kenarı aşınmış (yakında pürüzlü).
			float rp = B / nk;
			float r = py / rp;
			float fr = fract(r);
			float bi = floor(r);
			float rid = bi + per * 7.0;
			float bl = 0.34;
			float off = h21(vec2(rid, 1.3)) * bl;
			float bxu = (u + off) / bl;
			float bx = fract(bxu);
			float bid = floor(bxu);
			float hb = h21(vec2(bid, rid));
			float hb2 = h21(vec2(bid + 3.7, rid * 1.31));
			float pur = (vn(vec2(u * 40.0, py * 40.0)) - 0.5) * yakin;      // kenar pürüzü (yakında)
			float mh = rp * (0.44 + 0.1 * hb2) + 0.005 * pur;     // yatay harç kalınlığı (m)
			float y0 = fr * rp;
			float cH = clamp((min(y0 + hf, mh) - max(y0 - hf, 0.0)) / fy, 0.0, 1.0)
				+ clamp((min(y0 + hf - rp, mh) - max(y0 - hf - rp, 0.0)) / fy, 0.0, 1.0);
			cH = fy > rp * 0.6 ? 0.47 : clamp(cH, 0.0, 1.0);
			float hu2 = 0.5 * fu;
			float mv = 0.03 + 0.012 * hb + 0.008 * pur;
			float x0 = bx * bl;
			float cV = clamp((min(x0 + hu2, mv) - max(x0 - hu2, 0.0)) / fu, 0.0, 1.0)
				+ clamp((min(x0 + hu2 - bl, mv) - max(x0 - hu2 - bl, 0.0)) / fu, 0.0, 1.0);
			cV = fu > bl * 0.6 ? mv / bl : clamp(cV, 0.0, 1.0);
			float harc_m = clamp(cH + cV * (1.0 - cH), 0.0, 1.0);
			float tsec = 1.0 - smoothstep(0.02, 0.09, fu);
			// tuğla tonu: parlaklık 0,7–1,1; %14 koyu (fazla pişmiş, mor-kahve), %16 sarımsı (az pişmiş)
			vec3 tcol = tug * (0.7 + 0.4 * hb);
			tcol = mix(tcol, vec3(0.31, 0.225, 0.155) * clamp(kat, 0.7, 1.0), step(0.84, hb2) * 0.75);
			tcol = mix(tcol, vec3(0.15, 0.085, 0.07) * clamp(kat, 0.7, 1.0), step(hb2, 0.14) * 0.8);
			tcol = mix(tug * 0.9, tcol, tsec);
			// yüz dokusu ve kenar aşınması (yakında): kenara doğru koyulaşır, köşesi yer yer kırık
			tcol *= 1.0 + 0.16 * (vn(vec2(u * 19.0, py * 23.0) + rid) - 0.5) * yakin;
			float ke = min(min(y0 - mh, rp - y0), min(x0 - mv, bl - x0));
			tcol *= mix(1.0, mix(0.78, 1.0, smoothstep(0.0, 0.014, ke + 0.006 * pur)), tsec);
			// harç: kirli bej-gri, lekeli, yer yer oyulmuş (koyu), üstündeki tuğlanın gölgesinde (girinti)
			// tuğla bandında harç tuğla tozuyla pembemsi ve tuğladan az açık (şerit şerit "Lego" değil); kumlu dane yakında
			vec3 hc = mix(harc, tug * 1.25, 0.22) * (0.82 + 0.2 * vn(vec2(u * 5.0, rid * 1.9)));
			hc *= 1.0 + 0.18 * (vn(vec2(u * 55.0, py * 60.0)) - 0.5) * yakin;
			float oy = smoothstep(0.6, 0.76, vn(vec2(u * 3.7 + 11.0, rid * 1.7)));
			hc *= 1.0 - 0.3 * oy * tsec;
			float glg = smoothstep(0.55, 1.0, clamp(y0 / max(mh, 1e-3), 0.0, 1.0)) * step(y0, mh);
			hc *= 1.0 - 0.18 * glg * (1.0 - smoothstep(0.004, 0.02, fy));
			vec3 bc = mix(tcol, hc, harc_m);
			bcol = mix(uzak_b, bc, 1.0 - smoothstep(0.06, 0.12, fy));
		}
		// taş kuşağı (hatıl içindeyken komşu sıranın değerleri: yalnız kenar karışımında kullanılır)
		// TUR-10: derzler cetvel değil (yakında ±2 cm dalgalanır: el ile yontulmuş blok)
		float dlg = (vn(vec2(u * 1.6, y * 1.4) + 5.0) - 0.5) * 0.045 * orta;
		float sy = py - B + dlg;
		if (sy < 0.0) { sy += P; }
		float si = floor(sy / kh);
		float sf = fract(sy / kh);
		float ci = si + per * 11.0;
		float bl = 0.85 + 0.75 * h21(vec2(ci, 3.1));
		if (tur > 1.5) { bl = 1.15; }
		float off = h21(vec2(ci, 9.7)) * bl;
		float bx = (u + off + (vn(vec2(u * 0.9, y * 2.1) + 9.0) - 0.5) * 0.05 * orta) / bl;
		float bid = floor(bx);
		float bf = fract(bx);
		float tn = h21(vec2(bid, ci));
		float tn3 = h21(vec2(bid + 1.1, ci + 0.7));
		// TUR-8: blok tonu parlaklık + hafif sıcak/soğuk (eski "kumtaşı" sarısı güneşte düz SARI DİKDÖRTGEN okunuyordu);
		// blok kenarı içe doğru yumuşak kararır (aşınmış taş, keskin kenarlı levha değil)
		// TUR-10: bloktan bloğa ton farkı iki katı (0,8–1,1; soğuk gri ↔ bal), yer yer onarım taşı (koyu gri)
		vec3 tc = tas * (0.8 + 0.3 * tn);
		tc *= mix(vec3(0.96, 0.985, 1.03), vec3(1.05, 1.0, 0.925), h21(vec2(bid + 5.3, ci)));
		tc = mix(tc, tas * vec3(0.78, 0.78, 0.8), step(0.93, tn3) * 0.8);
		// blok ölçeğinde yıpranma yaması: komşu bloklar birlikte koyulaşır (iri gürültü × blok tonu), kenarı yumuşak
		float yam = vn(vec2(u * 0.35, y * 0.55) + 13.0);
		tc *= 1.0 - 0.14 * smoothstep(0.5, 0.85, yam) * (0.6 + 0.4 * tn);
		float kx = min(bf, 1.0 - bf) * bl;
		float ky = min(sf, 1.0 - sf) * kh;
		// TUR-10: aşınmış, yuvarlanmış kenar: kenar bandı blok blok 4–14 cm, pürüzlü; kenara doğru koyulaşır
		float kpur = (vn(vec2(u * 7.0, y * 7.0) + ci) - 0.5) * 0.05;
		float ew = 0.04 + 0.1 * h21(vec2(bid + 2.9, ci + 1.7));
		tc *= mix(1.0, mix(0.76, 1.0, smoothstep(0.0, ew, min(kx, ky) + kpur)), ince);
		// TUR-10: kırık köşe: blokların %40'ında bir köşe yontulmuş (koyu, içe çökük)
		float kh1 = h21(vec2(bid + 7.7, ci + 2.3));
		float kxs = (h21(vec2(bid, ci + 4.4)) > 0.5 ? bf : 1.0 - bf) * bl;
		float kys = (kh1 > 0.7 ? sf : 1.0 - sf) * kh;
		float kr = 0.06 + 0.16 * h21(vec2(bid + 3.3, ci + 8.1));
		float kirik = step(kh1, 0.4) * (1.0 - smoothstep(kr * 0.8, kr, kxs + kys * 1.3 + kpur));
		tc = mix(tc, tc * vec3(0.66, 0.64, 0.6), kirik * orta);
		// TUR-10: taş yüzü (yakında): gözenek, liken lekesi (açık sarımsı gri) ve koyu benek
		tc *= 1.0 + 0.14 * (vn(vec2(u * 17.0, y * 17.0) + ci) - 0.5) * yakin;
		float lik = smoothstep(0.7, 0.86, vn(vec2(u * 3.4, y * 3.8) + 21.0 + ci * 0.37));
		tc = mix(tc, tc * vec3(1.06, 1.05, 0.9), lik * 0.35 * orta);
		float ben = smoothstep(0.7, 0.92, vn(vec2(u * 14.0, y * 15.0) + 41.0));
		tc *= 1.0 - 0.08 * ben * ince;
		// dökülmüş taş: yer yer blok yerinde yok (koyu oyuk, üst kenarında gölge); hendek yüzünde (yerel y < 0) sık
		float eh = h21(vec2(bid * 1.7 + 2.0, ci + 3.0));
		float ez = vn(vec2(u * 0.18, y * 0.3) + 7.0);
		// TUR-9: hendek yüzünde (A03, c5) oyuklar "koyu dikdörtgen yama" okunuyordu (blokların %12'si, tam koyu, keskin
		// kenar): seyrek (%5), ton farkı az, kenarı blok içinde yumuşak (aşınmış oyuk, yapıştırılmış levha değil)
		float eks = (yerel_dip > 0.5 && ly < -0.4) ? step(0.90, eh) * step(0.48, ez) : step(0.978, eh) * step(0.6, ez);
		float eyum = smoothstep(0.02, 0.16, min(kx, ky));
		tc = mix(tc, tc * mix(0.62, 0.8, sf) * vec3(0.97, 0.95, 0.92), eks * orta * eyum);
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
		// derzler kutu süzgeçli: yatay sıra derzi ortada ince çizgi olarak kalır (uzakta ortalama), dikey derz yakında
		float jw = 0.04;
		float jy0 = sf * kh;
		float covJ = clamp((min(jy0 + hf, jw * 0.5) - max(jy0 - hf, -jw * 0.5)) / fy, 0.0, 1.0)
			+ clamp((min(jy0 + hf - kh, jw * 0.5) - max(jy0 - hf - kh, -jw * 0.5)) / fy, 0.0, 1.0);
		covJ = fy > kh * 0.6 ? jw / kh : clamp(covJ, 0.0, 1.0);
		float hu = 0.5 * fu;
		float jx0 = bf * bl;
		float covX = clamp((min(jx0 + hu, 0.02) - max(jx0 - hu, -0.02)) / fu, 0.0, 1.0)
			+ clamp((min(jx0 + hu - bl, 0.02) - max(jx0 - hu - bl, -0.02)) / fu, 0.0, 1.0);
		covX = fu > bl * 0.6 ? 0.04 / bl : clamp(covX, 0.0, 1.0);
		float j = clamp(covJ + 0.55 * covX * (1.0 - covJ), 0.0, 1.0);
		vec3 cs = mix(tas * 0.98, tc, orta);
		cs = mix(cs, harc * 0.78, j * 0.75);
		c = mix(cs, bcol, covB);
		// TUR-11: taş kuşağında da kenar kabartması (yakında; hatılda yok)
		float eb2 = ew * 1.3;
		egim2 = vec2(smoothstep(eb2, 0.0, (1.0 - bf) * bl + kpur) - smoothstep(eb2, 0.0, bf * bl + kpur),
			smoothstep(eb2, 0.0, (1.0 - sf) * kh + kpur) - smoothstep(eb2, 0.0, sf * kh + kpur)) * 0.6 * ince * (1.0 - covB);
	} else {
		// yatay (yürüme yolu, kule terası, rıhtım): döşeme taşı
		// TUR-14 ("yakında kiremit-kahve, iri, düz kesme taş"; taşıma 9 ve 11 "hâlâ kötü" 3): 0,9 m'lik eşit kare ızgara,
		// gök ışığına karşı kızıla çekilmiş kahve ton (1,06 0,9 0,74), derz cetvel. Şimdi gerçek ölçü döşeme: sıra eni
		// 0,34–0,56 m (sıradan sıraya), taş boyu 0,4–0,95 m (sıra sıra; %30'u ikiye bölünmüş), şaşırtmalı derz 1–2,4 cm
		// (dalgalı, toz/toprak dolu, yer yer otlanmış), taş taş ton (solgun gri-bej; soğuk gri ↔ bal), aşınmış ve
		// yuvarlanmış kenar, kırık köşe, kılcal çatlak, ayak izi aşınması (açık yama) ve yağmur lekesi; kabartma türev
		// normaliyle (derz girintisi, kenar yuvarlanması).
		vec2 P = wpos.xz;
		float fwp = max(fwidth(P.x) + fwidth(P.y), 1e-4);
		float ince_d = 1.0 - smoothstep(0.02, 0.09, fwp);
		float orta_d = 1.0 - smoothstep(0.08, 0.3, fwp);
		// sıralar (değişken en): 4 sıralık dönem içinde birikimli
		float dlg2 = (vn(P * vec2(0.9, 1.7) + 3.0) - 0.5) * 0.05 * orta_d;
		float pz = P.y + dlg2;
		float donem = 1.84;
		float dn = floor(pz / donem);
		float pr = pz - dn * donem;
		float w0 = 0.34 + 0.22 * h21(vec2(dn, 1.1));
		float w1 = 0.34 + 0.22 * h21(vec2(dn, 2.2));
		float w2 = 0.34 + 0.22 * h21(vec2(dn, 3.3));
		float w3 = donem - w0 - w1 - w2;
		float ri = 0.0;
		float r0 = 0.0;
		float rw = w0;
		if (pr >= w0) { ri = 1.0; r0 = w0; rw = w1; }
		if (pr >= w0 + w1) { ri = 2.0; r0 = w0 + w1; rw = w2; }
		if (pr >= w0 + w1 + w2) { ri = 3.0; r0 = w0 + w1 + w2; rw = w3; }
		float rid = dn * 4.0 + ri;
		float ry = pr - r0;
		float tbl = 0.4 + 0.55 * h21(vec2(rid, 4.7));
		float px = P.x + h21(vec2(rid, 6.1)) * tbl + (vn(P * vec2(1.3, 0.8) + 9.0) - 0.5) * 0.05 * orta_d;
		float tid = floor(px / tbl);
		float tx = px - tid * tbl;
		float tw = tbl;
		// bazı taşlar ikiye bölünmüş (küçük parça)
		float bol = step(0.7, h21(vec2(tid, rid + 0.5)));
		float bk0 = tbl * (0.38 + 0.24 * h21(vec2(tid + 1.3, rid)));
		if (bol > 0.5) {
			if (tx < bk0) { tw = bk0; } else { tx -= bk0; tw = tbl - bk0; tid += 0.5; }
		}
		float kx = min(tx, tw - tx);
		float ky = min(ry, rw - ry);
		float kk = min(kx, ky);
		float tpur = (vn(P * 9.0 + rid) - 0.5) * 0.012;
		float jw2 = 0.005 + 0.007 * h21(vec2(tid + 2.0, rid + 7.0));
		float dj = smoothstep(jw2, jw2 + 0.006, kk + tpur);         // 0 derzde, 1 taşta
		dj = mix(0.9, dj, ince_d);
		float tn = h21(vec2(tid, rid));
		float tn2 = h21(vec2(tid + 7.3, rid + 1.9));
		// gri-bej ama gök ışığına karşı sıcak (nötr gri gölgede camgöbeği okunuyor; eski kahve 1,06 0,9 0,74 kadar değil)
		vec3 dos = tas * vec3(1.1, 0.985, 0.85) * (0.82 + 0.22 * tn);
		dos *= mix(vec3(0.98, 0.995, 1.01), vec3(1.04, 1.0, 0.94), tn2);
		dos = mix(dos, tas * vec3(0.86, 0.82, 0.76), step(0.92, h21(vec2(tid + 3.1, rid))) * 0.7);   // onarım taşı (koyu)
		// aşınmış kenar: kenara doğru hafif koyu ve yuvarlanmış
		float kenar = smoothstep(0.0, 0.05 + 0.04 * tn2, kk + tpur);
		dos *= mix(0.86, 1.0, kenar * ince_d + (1.0 - ince_d));
		// kırık köşe (taşların %35'i)
		float kc = step(h21(vec2(tid + 9.1, rid + 4.4)), 0.35);
		float kxs = (h21(vec2(tid, rid + 4.4)) > 0.5 ? tx : tw - tx);
		float kys = (h21(vec2(tid + 1.7, rid)) > 0.5 ? ry : rw - ry);
		float kr = 0.04 + 0.07 * tn2;
		float kirk = kc * (1.0 - smoothstep(kr * 0.75, kr, kxs + kys * 1.2 + tpur));
		dos = mix(dos, harc * vec3(0.78, 0.72, 0.62), kirk * 0.7 * orta_d);
		// yüz: dane, kılcal çatlak, ayak izi aşınması (açık yama), yağmur lekesi
		float dn2 = vn(P * 23.0 + tid);
		dos *= 1.0 + 0.12 * (dn2 - 0.5) * yakin;
		float cv = 1.0 - smoothstep(0.0, 0.025, abs(vn(P * vec2(2.7, 3.1) + tid * 3.7) - 0.5));
		float catd = cv * step(0.8, h21(vec2(tid + 5.5, rid + 2.2))) * ince_d * smoothstep(0.35, 0.6, vn(P * 1.3 + tid));
		dos *= 1.0 - 0.16 * catd;
		float iz = smoothstep(0.45, 0.8, vn(P * 0.6 + 17.0));
		dos = mix(dos, dos * vec3(1.07, 1.06, 1.03), iz * 0.6);
		dos *= 1.0 - 0.14 * smoothstep(0.5, 0.9, vn(P * 0.35));
		// TUR-10: eğik yüz (diş omzu, kırık tepe) döşeme değil yontulmuş taş
		float yat_y = smoothstep(0.86, 0.97, abs(gnr.y));
		// derz: toz/toprak dolu, yer yer otlanmış (yalnız derzde; döşemenin üstü yeşil değil)
		vec3 dz = mix(harc * vec3(0.74, 0.68, 0.58), vec3(0.2, 0.21, 0.13) * kat, smoothstep(0.62, 0.8, vn(P * 1.9 + 5.0)) * 0.55);
		vec3 dc = mix(dz, dos, dj);
		c = mix(tas * (0.8 + 0.2 * tn), dc, yat_y);
		bh = ((dj - 1.0) * 0.012 + (kenar - 1.0) * 0.006 + (dn2 - 0.5) * 0.002 - catd * 0.002 - kirk * 0.008) * yat_y;
		bk = yakin;
	}
	// TUR-10: döküntü taşı (köşe alfası 0,5; sur_kule._moloz_tas): yerde yatan yuvarlanmış taş. Duvar deseni (yerde tuğla
	// hatılı), dip kararması ve gece payı ona uygulanınca zeminde simsiyah leke okunuyordu (Bölüm 20 an_03): taş tonu, iri
	// lekeli, yıpranma yalnız hafif
	float moloz = 1.0 - step(0.75, COLOR.a);
	if (dikey > 0.5 && moloz < 0.5 && dot(egim2, egim2) > 1e-6) {
		vec3 tw = vec3(t2.x, 0.0, t2.y) * egim2.x + vec3(0.0, egim2.y, 0.0);
		NORMAL = normalize(NORMAL + mat3(VIEW_MATRIX) * tw);
	}
	if (bk > 0.001 && moloz < 0.5) {
		// TUR-14: türev kabartması (görüş uzayı): yükseklik alanının ekran türevlerinden yüzey eğimi
		vec3 dpx = dFdx(VERTEX);
		vec3 dpy = dFdy(VERTEX);
		vec3 nn0 = normalize(NORMAL);
		vec3 r1 = cross(dpy, nn0);
		vec3 r2 = cross(nn0, dpx);
		float det = dot(dpx, r1);
		vec3 grd = sign(det) * (dFdx(bh) * r1 + dFdy(bh) * r2);
		NORMAL = normalize(mix(nn0, normalize(abs(det) * nn0 - grd), clamp(bk, 0.0, 1.0)));
	}
	if (moloz > 0.5) {
		c = tas * vec3(1.0, 0.96, 0.9) * (0.7 + 0.25 * vn(wpos.xz * 2.7 + wpos.y * 1.9)) * (0.85 + 0.15 * h21(floor(wpos.xz * 1.3)));
	}
	// yıpranma: dikey akıntı, is lekesi, dipte koyulaşma ve yosun
	float aki = vn(vec2(u * 1.7, y * 0.09));
	aki = smoothstep(0.55, 0.95, aki) * dikey;
	float leke = vn(vec2(u * 0.07, y * 0.11) + vec2(wpos.x, wpos.z) * 0.013);
	float dip = yerel_dip > 0.5 ? ly : 50.0;
	float dipk = (1.0 - smoothstep(0.0, 3.2, dip)) * (1.0 - moloz);
	// TUR-10: akıntı ve is daha belirgin (yakında ince damar), dipte kir ve yosun daha yüksek
	float aki2 = smoothstep(0.6, 0.95, vn(vec2(u * 6.5, y * 0.35) + 2.0)) * dikey * orta;
	c *= 1.0 - aki * 0.2 - aki2 * 0.14;
	c *= 1.0 - smoothstep(0.55, 0.9, leke) * 0.26;
	c *= 1.0 - dipk * 0.32;
	float yos = smoothstep(0.5, 0.85, vn(vec2(u * 0.4, y * 0.6) + 17.0)) * (1.0 - smoothstep(0.0, 2.6, dip));
	if (tur > 0.5 && tur < 1.5) { yos = max(yos, smoothstep(0.6, 0.9, vn(vec2(u * 0.3, y * 0.5) + 3.0)) * (1.0 - smoothstep(0.0, 4.0, dip))); }
	// yosun yakında lekeli (düz yeşil boya değil)
	yos *= mix(1.0, 0.55 + 0.9 * vn(vec2(u * 9.0, y * 9.0) + 31.0), yakin);
	c = mix(c, vec3(0.17, 0.21, 0.10) * kat, clamp(yos * 0.42, 0.0, 0.6) * dikey * (1.0 - moloz));
	// uzak katman (pişmiş, köşe rengi açılmış): yakındaki derz/akıntı/dip kararmasının ortalaması kadar koyulaşır
	if (yerel_dip < 0.5) { c *= 1.08; }      // SUR-5: uzak katman yakından koyu-kahve okunuyordu (uzak_kara_400m)
	// TUR-10: gece sur kararır (ay ışığında yakın sur ordugâh ve gökten parlak, lila-beyaz okunuyordu); hafif sıcak
	// TUR-14: harpuşta/kesme taş gece daha az kararır (koyu ağır levha okunmasın; diş silueti seçilsin)
	c *= mix(vec3(1.0), vec3(0.68, 0.66, 0.63), gece * (1.0 - moloz) * (0.6 + 0.4 * dikey) * (1.0 - 0.55 * harp));
	ALBEDO = c;
	// TUR-14: yukarı bakan taş (döşeme, harpuşta tepesi) gölgede yalnız gök ışığı alıyor; doğrusal uzayda mavi baskın gök ×
	// gri-bej taş = yeşil/camgöbeği döşeme (taşıma 9/11 karelerinde "zeytin yeşili sur yolu"). Çevredeki güneşli taştan
	// sekip gelen sıcak ışık: küçük, sıcak, gece yok (yalnız yukarı bakan yüzde; dikey sur yüzü değişmez).
	float yukari = smoothstep(0.55, 0.95, abs(gnr.y)) * smoothstep(0.3, 0.6, wnrm.y) * (1.0 - moloz);
	EMISSION = c * vec3(0.24, 0.165, 0.09) * yukari * (1.0 - gece);
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
	m.set_shader_parameter("gece", _gece)
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
	gece_izle(n)
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


## TUR-10: gece payı. Sur taşı gece ay ışığında yakından ordugâh ve gökten parlak (lila-beyaz) okunuyordu (Bölüm 25 an_01);
## ışığa (night.gd, look.gd) dokunmadan gölgelendiricinin `gece` uniformu sahnenin göğünden okunur: gök tepesi rengi
## karanlıksa 1, gündüz 0 (şafakta arada; bölüm ışığı değişince 0,25 s içinde izler). Sahne başına tek izleyici düğüm.
static var _izle: Node


static func gece_izle(n: Node) -> void:
	if n == null or not n.is_inside_tree():
		return
	if is_instance_valid(_izle) and _izle.is_inside_tree() and _izle.get_tree() == n.get_tree():
		return
	_izle = GeceIzle.new()
	_izle.name = "SurGeceIzle"
	n.add_child(_izle)


static func gece_payi(vp: Viewport) -> float:
	if vp == null:
		return 0.0
	var w := vp.find_world_3d()
	if w == null or w.environment == null:
		return 0.0
	var e := w.environment
	var c := Color(0.5, 0.6, 0.8)
	var en := 1.0
	if e.background_mode == Environment.BG_SKY and e.sky != null and e.sky.sky_material is ProceduralSkyMaterial:
		var sm := e.sky.sky_material as ProceduralSkyMaterial
		c = sm.sky_top_color.lerp(sm.sky_horizon_color, 0.35)
		en = sm.sky_energy_multiplier
	elif e.background_mode == Environment.BG_COLOR:
		c = e.background_color
		en = e.background_energy_multiplier
	var lum := (0.3 * c.r + 0.59 * c.g + 0.11 * c.b) * en
	return 1.0 - smoothstep(0.1, 0.32, lum)


static var _gece := 0.0


static func gece_ver(g: float) -> void:
	_gece = g
	for m: ShaderMaterial in _mats.values():
		m.set_shader_parameter("gece", g)


class GeceIzle extends Node:
	var _t := 0.0
	var _g := -1.0

	func _ready() -> void:
		_bak()

	func _process(dt: float) -> void:
		_t += dt
		if _t >= 0.25:
			_t = 0.0
			_bak()

	func _bak() -> void:
		var g := snappedf(load("res://scripts/world/ist/sur_doku.gd").gece_payi(get_viewport()), 0.01)
		if absf(g - _g) > 0.005:
			_g = g
			load("res://scripts/world/ist/sur_doku.gd").gece_ver(g)


## Hat adı → tur
static func tur_of(hat: String) -> int:
	match hat:
		"galata_suru":
			return 2
		"marmara_suru", "halic_suru":
			return 1
	return 0
