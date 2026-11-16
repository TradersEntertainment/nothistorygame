// ZEMİN: oyunun ortak zemin malzemesi (scripts/level/zemin.gd). Tek geçiş, gl_compatibility.
// Köşe rengi yalnız İPUCU: "burada ne var" (yeşil → ot, kahve → toprak, açık bej → kum/yol, gri → taş). Görünen ot rengi
// yöre paletinden gelir (Nisan sonu Trakya'sı: solgun bahar yeşili, sarımsı kuru ot, sıcak toprak, gri-bej çakıl, koyu
// çamur); toprak/kum/yol tonunu ipucu korur. Üç ölçek, hepsi dünya uzayında, iki ayrı ölçekte döndürülmüş örnekle
// (döşeme tekrarı seçilmez):
//   makro (20–60 m): kuruluk ve nem, ton değişimi;
//   orta (1–8 m): ot ↔ kuru ot ↔ çıplak toprak ↔ çamur ↔ çakıl öbekleri; sınırlar gürültüyle bükülmüş (köşe renginin
//                 doğrusal geçişi de bu eşikle düzensiz, yumuşak kenara döner: cetvelle kesilmiş çokgen kalmaz);
//   mikro (< 0,5 m): ot tanesi, çakıl taneleri (hücresel, gölgeli), kuru toprakta çatlak ağı; uzakta söner.
// Eğim (dik yer toprak/kaya), su kıyısı (ıslak koyu bant, kum/çakıl şeridi, köpük çizgisi), aşınma maskesi
// (R yol/çiğnenmiş, G çamur/tekerlek izi, B ocak isi, A yapı dibi temas kararması + toprak eteği).
// Gürültü dokusu (assets/textures/zemin_gurultu.png, 256 px, döşemesiz): R, G yumuşak fbm; B hücresel uzaklık (F1);
// A hücre başına rastgele değer.
shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform sampler2D gurultu : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D asinma : hint_default_black, filter_linear, repeat_disable;
uniform vec4 asinma_alan = vec4(0.0, 0.0, 1.0, 1.0);    // x0, z0, genişlik, derinlik (dünya m)
uniform float asinma_acik = 0.0;
uniform float asinma_yerel = 0.0;   // 1: maske ağın kendi uzayında (v2: dünya kökü dönüşümlü bağlansa da)

uniform vec4 c_ot : source_color = vec4(0.49, 0.54, 0.35, 1.0);      // solgun bahar yeşili
uniform vec4 c_ot2 : source_color = vec4(0.41, 0.47, 0.29, 1.0);     // gölgeli/yoğun ot
uniform vec4 c_kuru : source_color = vec4(0.65, 0.60, 0.41, 1.0);    // sarımsı kuru ot
uniform vec4 c_toprak : source_color = vec4(0.54, 0.43, 0.31, 1.0);  // sıcak toprak
uniform vec4 c_camur : source_color = vec4(0.31, 0.25, 0.20, 1.0);   // koyu çamur
uniform vec4 c_cakil : source_color = vec4(0.58, 0.55, 0.49, 1.0);   // gri-bej çakıl
uniform vec4 c_kum : source_color = vec4(0.73, 0.66, 0.53, 1.0);     // kıyı kumu
uniform vec4 c_kaya : source_color = vec4(0.52, 0.49, 0.44, 1.0);    // yamaç kayası
uniform float kuruluk = 0.38;       // 0 sulak çayır … 1 kurak
uniform float cignenme = 0.0;       // genel çiğnenmişlik (ordugâh, kuşatma alanı): çıplak toprak öbekleri artar
uniform float ot_carpan = 1.0;      // otun üst sınırı (sokak: seyrek ot)
uniform float ipucu_guc = 1.0;      // köşe renginin toprak/kum tonunu ne kadar koruduğu (0: yalnız palet)
uniform float su_y = -10000.0;      // su yüzeyi (ağın kendi uzayında y); kıyı bantları
uniform float kar = 0.0;            // Edirne avlusu (Şubat): karla örtü
uniform float olcek = 1.0;          // desen ölçeği (1 = dünya metresi)
uniform vec4 ipucu : source_color = vec4(1.0);   // köşe rengi olmayan ağlar için ipucu (köşe rengiyle çarpılır)
uniform vec2 yama_boyut = vec2(1.0);    // yama türevi: düzlemin boyutu (m)
uniform float yama_kenar = 2.0;          // yama türevi: kenarın gürültüyle eridiği genişlik (m)

varying vec3 wpos;
varying vec3 wnor;
varying float ly;
varying vec2 lxz;

float lum(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnor = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	ly = VERTEX.y;
	lxz = VERTEX.xz;
}

// iki ölçekte, döndürülmüş örnek (yalnız yumuşak kanallar R, G)
vec2 n2(vec2 p, float s1, float s2, float a) {
	vec2 q = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
	return (texture(gurultu, p / s1).rg + texture(gurultu, q / s2 + 0.37).gr) * 0.5;
}

void fragment() {
	vec2 p = wpos.xz / olcek;
	float dist = length(wpos - CAMERA_POSITION_WORLD);
	float mikro = 1.0 - smoothstep(16.0, 55.0, dist);     // mikro ayrıntı yakında
	float orta = 1.0 - smoothstep(320.0, 1100.0, dist);   // orta öbekler çok uzakta yumuşar
	float egim = 1.0 - clamp(wnor.y, 0.0, 1.0);

	// ---- ipucu: köşe rengi (Compatibility'de doğrusal gelir) → yaklaşık sRGB'de sınıfla
	vec3 h = COLOR.rgb * ipucu.rgb;
	vec3 hs = sqrt(max(h, vec3(0.0)));
	float L = lum(h);
	float yesil = clamp((hs.g - max(hs.r, hs.b)) * 12.0, 0.0, 1.0);
	float yesilimsi = clamp((hs.g - max(hs.r, hs.b)) * 25.0 + 0.2, 0.0, 1.0);   // toprağa yeşil ton taşınmasın
	float acik = smoothstep(0.42, 0.62, lum(hs));                       // açık bej: kum/yol/döşeme
	float doy = max(hs.r, max(hs.g, hs.b)) - min(hs.r, min(hs.g, hs.b));
	float gri = 1.0 - clamp(doy * 7.0, 0.0, 1.0);

	// ---- gürültüler (yumuşak; her biri ayrı ölçek ve açı)
	vec2 M = n2(p, 230.0, 141.0, 0.6);     // makro: x kuruluk, y nem
	vec2 O = n2(p, 37.0, 23.0, 1.1);       // orta öbek 1
	vec2 Q = n2(p, 17.0, 11.0, 2.3);       // orta öbek 2
	vec2 W = n2(p, 6.1, 3.7, 0.9);         // kenar bükme
	vec2 T = n2(p, 1.9, 1.15, 1.7);        // mikro tane
	float bukme = (W.x - 0.5) * 0.6 + (Q.y - 0.5) * 0.35 + (T.x - 0.5) * 0.15 * mikro;

	// ---- makro: kuruluk ve nem
	float kur = clamp(kuruluk + (M.x - 0.5) * 1.0, 0.0, 1.0);
	float nem = clamp((M.y - 0.5) * 1.6 + 0.4 - kuruluk * 0.45, 0.0, 1.0);
	// dipte nem: suya yakın alçak yerde (su_y tanımlıysa) toprak koyulaşır, ot gürleşir, çamur artar
	float dip = 1.0 - smoothstep(0.3, 4.0, ly - su_y);
	nem = clamp(nem + dip * 0.35, 0.0, 1.0);
	kur = clamp(kur - dip * 0.3, 0.0, 1.0);

	// ---- ot katmanı (paletten; ipucunun parlaklığına hafif uyar)
	vec3 ot = mix(c_ot2.rgb, c_ot.rgb, smoothstep(0.35, 0.65, O.y + (T.y - 0.5) * 0.3 * mikro));
	float uzak = smoothstep(60.0, 350.0, dist);
	ot = mix(ot, c_kuru.rgb, smoothstep(0.3, 0.85, kur + (Q.x - 0.5) * 0.8) * (1.0 - 0.5 * uzak));
	ot *= clamp(L / max(lum(c_ot.rgb), 0.01), 0.45, 1.04);    // koyu ipucu (gece bölümleri) koyu kalır
	ot *= vec3(1.04, 1.0, 0.88);                               // Nisan sıcaklığı (gök ışığında nane rengine kaçmasın)
	// ipucunun kendi yeşili (tarla parseli, bağ, koru): soldurulmuş hâliyle karışır; uzakta ağırlığı artar (makro renk kalır)
	vec3 ot_ip = mix(h, vec3(L), 0.4 - 0.15 * uzak) * vec3(1.02, 1.0, 0.86);
	ot = mix(ot, ot_ip, 0.25 + 0.55 * uzak);

	// ---- toprak katmanı: ipucunun tonu (yol, kum, taş) korunur; yeşil ipucunda palet toprağı
	vec3 topr = c_toprak.rgb * (0.9 + 0.2 * M.y);
	vec3 h_t = mix(h, c_toprak.rgb * clamp(L / max(lum(c_toprak.rgb), 0.01), 0.5, 1.4), yesilimsi);
	topr = mix(topr, h_t * (0.86 + 0.28 * Q.y) * (0.92 + 0.16 * O.x), ipucu_guc * (1.0 - yesil));
	// toprakta orta ölçek nem/kir lekesi (yumuşak, düzensiz): düz tek renk kalmaz
	topr *= 1.0 - 0.14 * smoothstep(0.55, 0.8, W.y * 0.5 + (1.0 - O.y) * 0.5) * (1.0 - acik * 0.4);
	topr = mix(topr, c_cakil.rgb * clamp(L / max(lum(c_cakil.rgb), 0.01), 0.6, 1.3), gri * (1.0 - yesil) * 0.25);

	// ---- ot ↔ toprak sınırı: ipucunun yeşilliği + bükme + çiğnenme + öbekler
	float otluk = yesil + bukme;
	otluk -= cignenme * 0.45 * smoothstep(0.4, 0.7, O.x);
	otluk -= cignenme * 0.3 * smoothstep(0.5, 0.72, Q.x + (W.y - 0.5) * 0.3);     // çiğnenmiş yerde küçük çıplak öbekler
	otluk -= smoothstep(0.6, 0.78, Q.x) * 0.5 * (1.0 - yesil * 0.5);           // otun içinde çıplak toprak öbekleri
	otluk += smoothstep(0.62, 0.8, O.y) * 0.45 * (1.0 - acik * 0.55) * (1.0 - cignenme * 0.5);   // toprakta ot öbekleri
	otluk -= smoothstep(0.25, 0.6, egim) * 0.9;                                  // dik yer: toprak/kaya
	float ot_m = smoothstep(0.44, 0.56, otluk);
	ot_m = mix(yesil, ot_m, orta) * ot_carpan;
	vec3 c = mix(topr, ot, ot_m);

	// ---- makro alaca (30–60 m): toprakta yer yer yeşillenen nadas/çayır lekesi, her yerde ton dalgası (uzaktan da düz
	//      renk okunmaz)
	float alaca = smoothstep(0.52, 0.72, M.y * 0.6 + O.y * 0.4);
	c = mix(c, mix(c, ot * 0.96, 0.5), (1.0 - ot_m) * alaca * (1.0 - cignenme * 0.7) * (1.0 - acik * 0.5));
	c *= 0.88 + 0.24 * smoothstep(0.25, 0.75, M.x * 0.6 + O.x * 0.4);

	// ---- çamur öbekleri (nemli dipte, çiğnenmiş yerde)
	float camur_m = smoothstep(0.66, 0.78, nem * 0.6 + (1.0 - Q.y) * 0.45 + cignenme * 0.12 + bukme * 0.25) * (1.0 - ot_m * 0.8);
	c = mix(c, mix(c_camur.rgb, c, 0.25), camur_m * orta);
	// ---- çakıl öbekleri (renk değil, taneleri sıklaşır; burada yalnız hafif gri ton)
	float cakil_m = smoothstep(0.66, 0.78, (1.0 - O.y) * 0.55 + W.y * 0.45 + gri * 0.25) * (1.0 - ot_m) * (1.0 - camur_m);
	c = mix(c, mix(c, c_cakil.rgb, 0.35), cakil_m * 0.5 * orta);
	// ---- dik yamaç kayası
	float kaya_m = smoothstep(0.45, 0.72, egim + (O.x - 0.5) * 0.3);
	c = mix(c, c_kaya.rgb * (0.85 + 0.3 * Q.x), kaya_m);

	// ---- aşınma maskesi
	vec4 a = vec4(0.0);
	if (asinma_acik > 0.5) {
		vec2 uv = (mix(wpos.xz, lxz, asinma_yerel) + (W - 0.5) * 1.6 - asinma_alan.xy) / asinma_alan.zw;
		if (uv.x > 0.0 && uv.y > 0.0 && uv.x < 1.0 && uv.y < 1.0) {
			a = texture(asinma, uv);
		}
		float yol = smoothstep(0.25, 0.6, a.r + bukme * 0.4);
		vec3 sik = mix(c_toprak.rgb * 1.06, c_cakil.rgb, 0.22) * (0.92 + 0.16 * O.y);
		c = mix(c, sik, yol);
		ot_m *= 1.0 - yol;
		float cam = smoothstep(0.25, 0.6, a.g + bukme * 0.3);
		c = mix(c, c_camur.rgb * (0.9 + 0.2 * T.y), cam * 0.9);
		ot_m *= 1.0 - cam;
		float is_m = smoothstep(0.2, 0.7, a.b + (T.x - 0.5) * 0.3);
		c = mix(c, vec3(0.085, 0.08, 0.075), is_m * 0.85);
		// temas: yapının dibinde toprak eteği + kararma
		c = mix(c, c_toprak.rgb * 0.82, smoothstep(0.3, 0.8, a.a) * 0.55);
		c *= 1.0 - 0.36 * smoothstep(0.45, 1.0, a.a);
	}

	// ---- su kıyısı: köpük çizgisi, ıslak koyu bant, kum/çakıl şeridi
	float dy = ly - su_y;          // ağın kendi uzayında (v2 dönüşümlü bağlansa da)
	if (dy > -0.6 && dy < 3.0) {
		float serit = 1.0 - smoothstep(0.05, 0.24 + O.x * 0.22 + (W.y - 0.5) * 0.1, dy);
		c = mix(c, mix(c_kum.rgb, c_cakil.rgb, smoothstep(0.55, 0.72, Q.y)), serit * (1.0 - kaya_m * 0.5));
		ot_m *= 1.0 - serit;
		float islak = 1.0 - smoothstep(0.03, 0.18 + W.x * 0.12, dy);
		c *= 1.0 - 0.4 * islak;
		float kopuk = (1.0 - smoothstep(0.0, 0.07, abs(dy - 0.04 - 0.04 * sin(TIME * 0.8 + p.x * 0.3 + W.y * 6.0))))
			* smoothstep(0.4, 0.6, W.x);
		c = mix(c, vec3(0.86, 0.87, 0.84), kopuk * 0.7);
	}

	// ---- mikro (uzakta söner)
	// ot: açık uçlar ve koyu aralar; çok yönlü tane (damga yok)
	float ince = texture(gurultu, vec2(p.x * 0.6 - p.y * 0.8, p.x * 0.8 + p.y * 0.6) / 0.41).r - 0.5;
	float ince2 = texture(gurultu, vec2(p.x * 0.8 + p.y * 0.6, -p.x * 0.6 + p.y * 0.8) / 0.17 + 0.61).g - 0.5;
	float tane = (T.x - 0.5) * 0.9;
	c *= 1.0 + mix(tane * 0.3 + ince2 * 0.25, ince * 0.75 + ince2 * 0.6 + tane * 0.3, ot_m) * mikro;
	// otta açık sap uçları ve koyu dip boşlukları (çok yönlü; damga yok)
	c = mix(c, c * vec3(1.12, 1.12, 0.92), smoothstep(0.12, 0.25, ince2) * ot_m * 0.5 * mikro);
	c *= 1.0 - smoothstep(0.1, 0.22, -ince) * ot_m * 0.22 * mikro;
	// toprak: çakıl taneleri (hücre başına rastgele boy ve ton: halka/yineleme yok), zemine yakın tonda, hafif gölgeli
	vec4 ct = texture(gurultu, p / 2.3 + 0.21);
	float tas_var = (1.0 - ot_m) * clamp(0.05 + cakil_m * 0.5 + kaya_m * 0.3 + gri * 0.1 - camur_m * 0.05, 0.0, 0.7);
	float secili = step(1.0 - tas_var, ct.a);
	float r0 = 0.1 + 0.13 * fract(ct.a * 7.31);
	float tas = (1.0 - smoothstep(r0 - 0.05, r0, ct.b)) * secili;
	float ton = fract(ct.a * 13.7);
	vec3 tas_c = mix(c, c_cakil.rgb * (L > 0.02 ? 1.0 : 0.5), 0.25 + 0.2 * ton) * (1.0 + 0.1 * ton) * (0.97 + 0.4 * clamp(r0 - ct.b, 0.0, 0.2));
	c = mix(c, tas_c, tas * mikro * 0.85);
	// taşın dibinde hafif gölge (halka değil: yalnız bir yanda)
	vec4 ct2 = texture(gurultu, p / 2.3 + 0.21 + vec2(0.0035, 0.0035));
	c *= 1.0 - (1.0 - smoothstep(r0 - 0.05, r0, ct2.b)) * secili * (1.0 - tas) * 0.18 * mikro;
	// kuru toprakta çatlak ağı (hücre sınırı; ~0,7 m'lik çokgenler)
	float cb = texture(gurultu, p / 16.0 + 0.53).b;
	float catlak = smoothstep(0.47, 0.53, cb) * (1.0 - ot_m) * (1.0 - camur_m) * smoothstep(0.45, 0.75, kur)
		* (1.0 - a.r) * (1.0 - cakil_m) * smoothstep(0.5, 0.65, Q.y);
	c *= 1.0 - catlak * 0.22 * mikro;

	// ---- kar (Edirne, Şubat)
	if (kar > 0.0) {
		float k = smoothstep(0.35, 0.55, kar + (O.x - 0.5) * 0.5 - a.r * 0.6 - a.g * 0.8 - egim * 0.6);
		c = mix(c, vec3(0.86, 0.88, 0.9) * (0.94 + 0.08 * T.x), k);
	}

	//YAMA_KENAR
	ALBEDO = clamp(c, vec3(0.0), vec3(1.0));
	ROUGHNESS = 1.0;
}
