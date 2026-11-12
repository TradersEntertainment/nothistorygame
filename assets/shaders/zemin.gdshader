// ZEMİN: oyunun ortak zemin malzemesi (scripts/level/zemin.gd). Tek geçiş, gl_compatibility.
// Köşe rengi yalnız İPUCU: "burada ne var" (yeşil → ot, kahve → toprak, açık bej → kum/yol, gri → taş). Görünen renk
// yöre paletinden gelir (Nisan sonu Trakya'sı: solgun bahar yeşili, sarımsı kuru ot, sıcak toprak, gri-bej çakıl,
// koyu çamur). Üç ölçek, hepsi dünya uzayında ve döşeme tekrarı seçilmeyecek biçimde (iki ayrı ölçek, döndürülmüş):
//   makro (20–60 m): kuruluk ve nem, ton değişimi;
//   orta (2–8 m): ot ↔ kuru ot ↔ çıplak toprak ↔ çamur ↔ çakıl öbekleri; sınırlar gürültüyle bükülmüş (köşe renginin
//                 doğrusal geçişleri de bu eşikle düzensiz, yumuşak kenara döner: cetvelle kesilmiş çokgen kalmaz);
//   mikro (< 0,5 m): ot sapı/tutam beneği, çakıl taneleri (gölgeli), kuru toprakta çatlak; uzakta söner (mip + uzaklık).
// Eğim (dik yer toprak/kaya), su kıyısı (ıslak koyu bant, kum/çakıl şeridi, köpük çizgisi), aşınma maskesi
// (R yol/çiğnenmiş, G çamur/tekerlek izi, B ocak isi, A yapı dibi temas kararması + toprak eteği).
shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform sampler2D gurultu : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D asinma : hint_default_black, filter_linear, repeat_disable;
uniform vec4 asinma_alan = vec4(0.0, 0.0, 1.0, 1.0);    // x0, z0, genişlik, derinlik (dünya m)
uniform float asinma_acik = 0.0;

uniform vec4 c_ot : source_color = vec4(0.47, 0.53, 0.33, 1.0);      // solgun bahar yeşili
uniform vec4 c_ot2 : source_color = vec4(0.40, 0.47, 0.29, 1.0);     // gölgeli/yoğun ot
uniform vec4 c_kuru : source_color = vec4(0.62, 0.58, 0.40, 1.0);    // sarımsı kuru ot
uniform vec4 c_toprak : source_color = vec4(0.52, 0.42, 0.31, 1.0);  // sıcak toprak
uniform vec4 c_camur : source_color = vec4(0.30, 0.25, 0.19, 1.0);   // koyu çamur
uniform vec4 c_cakil : source_color = vec4(0.58, 0.55, 0.49, 1.0);   // gri-bej çakıl
uniform vec4 c_kum : source_color = vec4(0.72, 0.65, 0.50, 1.0);     // kıyı kumu
uniform vec4 c_kaya : source_color = vec4(0.50, 0.48, 0.44, 1.0);    // yamaç kayası
uniform float kuruluk = 0.35;       // 0 sulak çayır … 1 kurak (Trakya yolu, ordugâh)
uniform float cignenme = 0.0;       // genel çiğnenmişlik (ordugâh, kuşatma alanı): çıplak toprak öbekleri artar
uniform float ot_carpan = 1.0;      // otun üst sınırı (sokak: seyrek ot, yalnız kenarda)
uniform float ipucu_guc = 1.0;      // köşe renginin toprak/kum tonunu ne kadar koruduğu (0: yalnız palet)
uniform float su_y = -10000.0;      // su yüzeyi (dünya y); kıyı bantları
uniform float kar = 0.0;            // Edirne avlusu (Şubat): karla örtü
uniform float olcek = 1.0;          // desen ölçeği (1 = dünya metresi)
uniform vec4 ipucu : source_color = vec4(1.0);   // köşe rengi olmayan ağlar için ipucu (köşe rengiyle çarpılır)

uniform vec2 yama_boyut = vec2(1.0);    // yama türevi: düzlemin boyutu (m)
uniform float yama_kenar = 2.0;          // yama türevi: kenarın gürültüyle eridiği genişlik (m)

varying vec3 wpos;
varying float ly;
varying vec3 wnor;

vec3 to_lin(vec3 c) { return c * c * (c * 0.305306 + 0.682171) + 0.012523 * c; }
float lum(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnor = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	ly = VERTEX.y;
}

// iki ölçekte, döndürülmüş örnek: döşeme tekrarı seçilmez
vec4 n2(vec2 p, float s1, float s2) {
	vec2 q = vec2(p.x * 0.8 - p.y * 0.6, p.x * 0.6 + p.y * 0.8);
	return (texture(gurultu, p / s1) + texture(gurultu, q / s2 + 0.37)) * 0.5;
}

void fragment() {
	vec2 p = wpos.xz / olcek;
	float dist = length(wpos - CAMERA_POSITION_WORLD);
	float mikro = 1.0 - smoothstep(18.0, 60.0, dist);     // mikro ayrıntı yakında
	float orta = 1.0 - smoothstep(260.0, 900.0, dist);    // orta öbekler uzakta yumuşar
	float egim = 1.0 - clamp(wnor.y, 0.0, 1.0);

	// ---- ipucu: köşe rengi (Compatibility'de doğrusal gelir) → sRGB'de sınıfla
	vec3 h = COLOR.rgb * ipucu.rgb;
	vec3 hs = sqrt(max(h, vec3(0.0)));
	float L = lum(h);
	float yesil = clamp((hs.g - max(hs.r, hs.b)) * 7.0, 0.0, 1.0);
	float acik = smoothstep(0.30, 0.55, lum(hs));                            // açık bej: kum/yol/döşeme
	float gri = 1.0 - clamp((max(hs.r, max(hs.g, hs.b)) - min(hs.r, min(hs.g, hs.b))) * 6.0, 0.0, 1.0);

	// ---- gürültüler
	vec4 M = n2(p, 210.0, 137.0);        // makro (R: kuruluk, G: nem)
	vec4 O = n2(p, 31.0, 19.0);          // orta öbekler
	vec4 W = n2(p, 7.3, 4.1);            // kenar bükme
	vec4 Mi = n2(p, 2.9, 1.7);           // mikro tane
	float bukme = (W.r - 0.5) * 0.55 + (Mi.g - 0.5) * 0.18 * mikro;

	// ---- makro: kuruluk ve nem
	float kur = clamp(kuruluk + (M.r - 0.5) * 1.3, 0.0, 1.0);
	float nem = clamp((M.g - 0.5) * 1.6 + 0.35 - kuruluk * 0.4, 0.0, 1.0);

	// ---- ot katmanı (paletten; ipucunun parlaklığına hafif uyar)
	vec3 ot = mix(c_ot2.rgb, c_ot.rgb, smoothstep(0.3, 0.7, O.g));
	ot = mix(ot, c_kuru.rgb, smoothstep(0.35, 0.85, kur + (O.r - 0.5) * 0.7));
	ot *= clamp(L / max(lum(c_ot.rgb), 0.01), 0.82, 1.15);

	// ---- toprak katmanı: ipucunun tonu (yol, kum, taş) korunur, değilse palet toprağı
	vec3 topr = mix(c_toprak.rgb, c_toprak.rgb * vec3(1.08, 1.04, 0.95), M.b);
	vec3 ipucu_t = h * mix(1.0, 0.9 + 0.2 * O.b, 1.0);
	topr = mix(topr, ipucu_t, ipucu_guc * (1.0 - yesil));
	// açık bej ipucu: kum/yol tonunda kalır; gri: çakıl
	topr = mix(topr, mix(topr, c_cakil.rgb * (L / max(lum(c_cakil.rgb), 0.01)), 0.5), gri * (1.0 - yesil) * 0.6);

	// ---- ot ↔ toprak sınırı: ipucunun yeşilliği + bükme + çiğnenme
	float otluk = yesil + bukme;
	otluk -= cignenme * 0.35 * smoothstep(0.35, 0.65, O.r);
	otluk -= smoothstep(0.62, 0.8, 1.0 - O.b) * 0.45 * (1.0 - yesil * 0.4);   // otun içinde çıplak toprak öbekleri
	otluk += smoothstep(0.66, 0.85, O.g) * 0.4 * (1.0 - acik);                // toprağın içinde ot öbekleri
	otluk -= smoothstep(0.25, 0.6, egim) * 0.8;                                 // dik yer: toprak/kaya
	float ot_m = smoothstep(0.42, 0.58, otluk);
	ot_m = mix(yesil, ot_m, orta);
	ot_m *= ot_carpan;
	vec3 c = mix(topr, ot, ot_m);

	// ---- çamur öbekleri (nemli dipte, çiğnenmiş yerde)
	float camur_m = smoothstep(0.7, 0.82, nem * 0.7 + (1.0 - O.r) * 0.5 + cignenme * 0.15 + bukme * 0.3) * (1.0 - ot_m * 0.7);
	c = mix(c, c_camur.rgb, camur_m * 0.85 * orta);
	// ---- çakıl öbekleri
	float cakil_m = smoothstep(0.74, 0.84, O.a + bukme * 0.3 + gri * 0.2) * (1.0 - ot_m * 0.8) * (1.0 - camur_m);
	c = mix(c, c_cakil.rgb * (0.9 + 0.2 * Mi.r), cakil_m * 0.7 * orta);
	// ---- dik yamaç kayası
	float kaya_m = smoothstep(0.42, 0.7, egim + (O.b - 0.5) * 0.3);
	c = mix(c, c_kaya.rgb * (0.85 + 0.3 * O.r), kaya_m);

	// ---- aşınma maskesi
	vec4 a = vec4(0.0);
	if (asinma_acik > 0.5) {
		vec2 uv = (wpos.xz + (W.rg - 0.5) * 1.6 - asinma_alan.xy) / asinma_alan.zw;
		if (uv.x > 0.0 && uv.y > 0.0 && uv.x < 1.0 && uv.y < 1.0) {
			a = texture(asinma, uv);
		}
		float yol = smoothstep(0.25, 0.6, a.r + bukme * 0.4);
		vec3 sik = mix(c_toprak.rgb * 1.08, c_cakil.rgb, 0.25) * (0.92 + 0.16 * O.g);
		c = mix(c, sik, yol);
		ot_m *= 1.0 - yol;
		float cam = smoothstep(0.25, 0.6, a.g + bukme * 0.3);
		c = mix(c, c_camur.rgb * (0.9 + 0.2 * Mi.b), cam * 0.9);
		ot_m *= 1.0 - cam;
		float is = smoothstep(0.2, 0.7, a.b + (Mi.r - 0.5) * 0.3);
		c = mix(c, vec3(0.08, 0.075, 0.07), is * 0.85);
		// temas: yapının dibinde toprak eteği + kararma
		c = mix(c, c_toprak.rgb * 0.8, smoothstep(0.3, 0.8, a.a) * 0.6);
		c *= 1.0 - 0.38 * smoothstep(0.45, 1.0, a.a);
	}

	// ---- su kıyısı: köpük çizgisi, ıslak koyu bant, kum/çakıl şeridi
	float dy = ly - su_y;          // ağın kendi uzayında (v2 dönüşümlü bağlansa da)
	if (dy > -0.6 && dy < 3.0) {
		float serit = 1.0 - smoothstep(0.5, 1.6 + O.r * 0.8, dy);
		c = mix(c, mix(c_kum.rgb, c_cakil.rgb, smoothstep(0.55, 0.75, O.a)), serit * (1.0 - kaya_m * 0.5));
		ot_m *= 1.0 - serit;
		float islak = 1.0 - smoothstep(0.08, 0.5 + W.r * 0.3, dy);
		c *= 1.0 - 0.42 * islak;
		float kopuk = (1.0 - smoothstep(0.0, 0.07, abs(dy - 0.05 - 0.04 * sin(TIME * 0.8 + p.x * 0.3 + W.g * 6.0))))
			* smoothstep(0.35, 0.6, W.b);
		c = mix(c, vec3(0.86, 0.87, 0.84), kopuk * 0.75);
	}

	// ---- mikro: ot tanesi, çakıl taneleri, çatlak (uzakta söner)
	float tane = (Mi.r - 0.5) * 0.9 + (texture(gurultu, p / 0.83).g - 0.5) * 0.7;
	float ot_ince = texture(gurultu, vec2(p.x * 0.6 - p.y * 0.8, p.x * 0.8 + p.y * 0.6) / 0.37).r - 0.5;
	// ot: açık uçlar ve koyu aralar (yön birden çok, damga yok)
	c *= 1.0 + mix(tane * 0.14, (ot_ince * 0.55 + tane * 0.25), ot_m) * mikro;
	c = mix(c, c * vec3(1.06, 1.08, 0.86), smoothstep(0.62, 0.8, Mi.a) * ot_m * 0.5 * mikro);
	// çakıl taneleri: hücresel; yukarı bakan kenarı açık, dibi koyu
	vec4 ct = texture(gurultu, p / 3.3 + 0.21);
	float tas_var = (1.0 - ot_m) * (0.25 + cakil_m * 0.75 + kaya_m * 0.4);
	float tas = (1.0 - smoothstep(0.18, 0.3, ct.b)) * step(0.5, fract(ct.r * 7.0)) * tas_var;
	vec3 tas_c = mix(c_cakil.rgb, c_kaya.rgb, ct.g) * (0.95 + 0.25 * (0.3 - ct.b) * 3.0);
	c = mix(c, tas_c, tas * mikro);
	c *= 1.0 - (smoothstep(0.3, 0.38, ct.b) - smoothstep(0.38, 0.5, ct.b)) * tas * 0.35 * mikro;
	// kuru toprakta çatlak
	float catlak = (1.0 - smoothstep(0.0, 0.06, texture(gurultu, p / 4.7).a)) * (1.0 - ot_m) * (1.0 - camur_m)
		* smoothstep(0.4, 0.7, kur) * (1.0 - a.r);
	c *= 1.0 - catlak * 0.28 * mikro;

	// ---- kar (Edirne, Şubat)
	if (kar > 0.0) {
		float k = smoothstep(0.35, 0.55, kar + (O.r - 0.5) * 0.5 - a.r * 0.6 - a.g * 0.8 - egim * 0.6);
		c = mix(c, vec3(0.86, 0.88, 0.9) * (0.94 + 0.08 * Mi.r), k);
	}

	//YAMA_KENAR
	ALBEDO = clamp(c, vec3(0.0), vec3(1.0));
	ROUGHNESS = 1.0;
}
