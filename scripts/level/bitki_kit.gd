extends RefCounted
## Ortak bitki kiti (BİTKİ, 4. tur): Nisan sonu İstanbul'unun ağaçları GERÇEK biçimli.
## class_name YOK (yeni class_name yasağı): `const BitkiKit := preload("res://scripts/level/bitki_kit.gd")`.
##
## Sahibinin sözü: "ağaçlar beyaz", "şu kare kare sevdandan vazgeç", "oyuncak ağaçlar". Bu yüzden:
##  - Gövde incelen, hafif eğri bir boru; 3–6 ana dal; dal uçlarında taç öbekleri (düz silindir + tek blok YOK).
##  - Taç 5–12 düzensiz, YUMUŞAK normalli (köşesiz) yaprak öbeğinden örülür; aralarında boşluk kalır; öbek başına ton
##    farkı (güneş alan üst açık, alt ve iç koyu), siluet kenarı pürüzlü.
##  - Çiçekli ağaçlar (badem, erik, kiraz, ayva) dalları görünür, çiçek kırık beyaz/açık pembe, gölgede grileşir;
##    parlaklık tavanı (V ≤ PARLAK_TAVAN) ile güneşte patlamaz. Hiçbir köşe rengi saf beyaz/saf yeşil değildir.
##  - Katman: lod 0 yakın (≤ 900 üçgen), lod 1 orta (≤ 180), lod 2 uzak (≤ 40; siluet yine gövde + düzensiz taç).
##  - Rüzgâr: köşe rengi alfası salınım ağırlığıdır (1 = kıpırdamaz; 0,5 = tam). Gölgelendirici ucuz (iki sinüs).
##  - Yer teması: gövde dibi kök çıkıntılı, taban zeminin 0,25 m altına iner (yamaçta havada kalmaz).
## Ağaçlar köşe renkli TEK ağdır (tek yüzey, tek malzeme): MultiMesh, pişirme (SurfaceTool.append_from) uyumlu.

const SURUM := 10
const PARLAK_TAVAN := 0.86          # köşe rengi en büyük bileşeni (V) bu sınırı aşmaz: ISTBITKI beyaz=0
const UCGEN_SINIR := [900, 180, 40]

static var _cache := {}
static var _mat: ShaderMaterial

## Tür tanımları. Uzunluklar metre (gerçek boy). Renkler sRGB.
##  boy: toplam boy; gh: dalların ayrıldığı gövde boyu; gr: gövde yarıçapı (dipte); egik: gövde eğikliği (m)
##  dal: ana dal sayısı; aci: dal açısı (dikeyden derece); du: dal boyu; kok: çok gövdeli (dipten ayrılan gövde sayısı)
##  on: öbek sayısı (lod 0); orr: öbek yarıçapı; yas: öbek basıklığı (y/x); bicim: yayvan|oval|sutun|semsiye|calimsi
##  y1/y2: yaprak (alt-gölge / üst-güneş); kb: kabuk; ci1/ci2: çiçek (alt/üst); cio: çiçekli öbek oranı (0..1)
##  yy: yeni yaprak serpintisi (çiçekli ağaçta yeşil benek oranı)
const TUR := {
	"cinar": {"tc": 12.0, "tR": 7.0, "tH": 4.8, "ad": "Çınar", "boy": 18.0, "gh": 5.5, "gr": 0.62, "egik": 0.5, "dal": 5, "aci": 38.0, "du": 6.5,
		"kok": 1, "on": 11, "orr": 3.1, "yas": 0.72, "bicim": "yayvan",
		"y1": Color("4a6a30"), "y2": Color("a2bc5c"), "kb": Color("9a9480")},
	"servi": {"ad": "Servi", "boy": 12.0, "gh": 0.9, "gr": 0.2, "egik": 0.35, "dal": 0, "aci": 0.0, "du": 0.0,
		"kok": 1, "on": 10, "orr": 1.3, "yas": 1.6, "bicim": "sutun",
		"y1": Color("26422a"), "y2": Color("52784a"), "kb": Color("4a3a2c")},
	"fistik_cami": {"tc": 10.6, "tR": 5.8, "tH": 1.5, "ad": "Fıstık çamı", "boy": 13.0, "gh": 8.0, "gr": 0.36, "egik": 1.4, "dal": 5, "aci": 62.0,
		"du": 4.6, "kok": 1, "on": 9, "orr": 2.4, "yas": 0.42, "bicim": "semsiye",
		"y1": Color("324a28"), "y2": Color("6e8c46"), "kb": Color("7a5a40")},
	"zeytin": {"tc": 3.5, "tR": 3.0, "tH": 1.6, "ad": "Zeytin", "boy": 5.5, "gh": 1.5, "gr": 0.3, "egik": 0.6, "dal": 4, "aci": 48.0, "du": 2.2,
		"kok": 2, "on": 9, "orr": 1.25, "yas": 0.7, "bicim": "yayvan",
		"y1": Color("5a6650"), "y2": Color("aab494"), "kb": Color("6e6656")},
	"incir": {"tc": 3.2, "tR": 3.2, "tH": 1.6, "ad": "İncir", "boy": 5.0, "gh": 1.0, "gr": 0.2, "egik": 0.3, "dal": 5, "aci": 58.0, "du": 2.4,
		"kok": 3, "on": 8, "orr": 1.35, "yas": 0.65, "bicim": "yayvan",
		"y1": Color("56782e"), "y2": Color("aac462"), "kb": Color("8e877a")},
	"dut": {"tc": 4.7, "tR": 3.4, "tH": 2.3, "ad": "Dut", "boy": 7.0, "gh": 2.2, "gr": 0.26, "egik": 0.4, "dal": 4, "aci": 42.0, "du": 2.8,
		"kok": 1, "on": 9, "orr": 1.7, "yas": 0.75, "bicim": "yayvan",
		"y1": Color("4a6a2c"), "y2": Color("98b452"), "kb": Color("66503c")},
	"ihlamur": {"tc": 7.6, "tR": 4.0, "tH": 4.3, "ad": "Ihlamur", "boy": 12.0, "gh": 3.0, "gr": 0.4, "egik": 0.2, "dal": 5, "aci": 30.0, "du": 4.0,
		"kok": 1, "on": 11, "orr": 2.2, "yas": 0.85, "bicim": "oval",
		"y1": Color("466a2c"), "y2": Color("94b250"), "kb": Color("6a5e50")},
	"nar": {"tc": 2.2, "tR": 1.4, "tH": 1.2, "ad": "Nar", "boy": 3.4, "gh": 0.5, "gr": 0.1, "egik": 0.25, "dal": 4, "aci": 32.0, "du": 1.6,
		"kok": 3, "on": 7, "orr": 0.8, "yas": 0.85, "bicim": "oval",
		"y1": Color("50702e"), "y2": Color("a0b856"), "kb": Color("6a4e3a"), "ci1": Color("a8402c"),
		"ci2": Color("c8603a"), "cio": 0.0, "yy": 0.25},
	"ayva": {"tc": 3.0, "tR": 2.1, "tH": 1.4, "ad": "Ayva (çiçekte)", "boy": 4.5, "gh": 1.2, "gr": 0.15, "egik": 0.4, "dal": 4, "aci": 40.0, "du": 1.8,
		"kok": 1, "on": 8, "orr": 0.95, "yas": 0.75, "bicim": "yayvan",
		"y1": Color("4a6a2c"), "y2": Color("8eaa52"), "kb": Color("5a4434"), "ci1": Color("a8908e"),
		"ci2": Color("d8c0c0"), "cio": 0.35, "yy": 0.3},
	"erguvan": {"tc": 4.0, "tR": 2.9, "tH": 2.0, "ad": "Erguvan", "boy": 6.0, "gh": 1.6, "gr": 0.16, "egik": 0.6, "dal": 4, "aci": 44.0, "du": 2.3,
		"kok": 2, "on": 9, "orr": 1.25, "yas": 0.72, "bicim": "yayvan",
		"y1": Color("5a5a34"), "y2": Color("86964c"), "kb": Color("4a3428"), "ci1": Color("70445e"),
		"ci2": Color("a8789a"), "cio": 0.85, "yy": 0.15},
	"badem": {"tc": 3.4, "tR": 2.5, "tH": 1.6, "ad": "Badem (çiçekte)", "boy": 5.0, "gh": 1.4, "gr": 0.15, "egik": 0.5, "dal": 5, "aci": 42.0,
		"du": 2.1, "kok": 1, "on": 9, "orr": 0.95, "yas": 0.68, "bicim": "yayvan",
		"y1": Color("4e6a30"), "y2": Color("8aa456"), "kb": Color("4e3a2c"), "ci1": Color("9c8a8c"),
		"ci2": Color("dcc4ca"), "cio": 0.75, "yy": 0.3},
	"erik": {"tc": 3.1, "tR": 2.2, "tH": 1.5, "ad": "Erik (çiçekte)", "boy": 4.6, "gh": 1.3, "gr": 0.14, "egik": 0.4, "dal": 5, "aci": 40.0, "du": 1.9,
		"kok": 1, "on": 9, "orr": 0.9, "yas": 0.72, "bicim": "oval",
		"y1": Color("4e6a30"), "y2": Color("8aa456"), "kb": Color("4a3a30"), "ci1": Color("9a9490"),
		"ci2": Color("d8d0c8"), "cio": 0.7, "yy": 0.35},
	"kiraz": {"tc": 4.4, "tR": 2.8, "tH": 2.1, "ad": "Kiraz (çiçekte)", "boy": 6.5, "gh": 2.0, "gr": 0.18, "egik": 0.3, "dal": 5, "aci": 36.0,
		"du": 2.6, "kok": 1, "on": 10, "orr": 1.1, "yas": 0.7, "bicim": "oval",
		"y1": Color("4e6a30"), "y2": Color("8aa456"), "kb": Color("5a3e30"), "ci1": Color("a09090"),
		"ci2": Color("dccacc"), "cio": 0.7, "yy": 0.35},
	"defne": {"tc": 2.3, "tR": 1.6, "tH": 1.9, "ad": "Defne", "boy": 4.2, "gh": 0.4, "gr": 0.1, "egik": 0.2, "dal": 4, "aci": 22.0, "du": 1.8,
		"kok": 3, "on": 8, "orr": 0.95, "yas": 1.05, "bicim": "oval",
		"y1": Color("2a4626"), "y2": Color("5a7c42"), "kb": Color("4a3a2c")},
	"cali": {"ad": "Çalı (böğürtlen)", "boy": 1.3, "gh": 0.0, "gr": 0.05, "egik": 0.1, "dal": 0, "aci": 0.0,
		"du": 0.0, "kok": 0, "on": 7, "orr": 0.55, "yas": 0.7, "bicim": "calimsi",
		"y1": Color("344e26"), "y2": Color("74903e"), "kb": Color("4a3a2c")},
	"kutuk": {"ad": "Kütük (kesilmiş)", "boy": 0.6, "gh": 0.6, "gr": 0.32, "egik": 0.0, "dal": 0, "aci": 0.0,
		"du": 0.0, "kok": 1, "on": 0, "orr": 0.0, "yas": 1.0, "bicim": "kutuk",
		"y1": Color("4a5a30"), "y2": Color("6a7a40"), "kb": Color("6a5440")},
}

## Eski adlar → kit türü
const ESLEME := {"cypress": "servi", "selvi": "servi", "plane": "cinar", "olive": "zeytin", "fig": "incir",
	"pine": "fistik_cami", "cam": "fistik_cami", "meyve": "badem", "bush": "cali", "laurel": "defne"}


static func tur_ad(tur: String) -> String:
	if TUR.has(tur):
		return tur
	return String(ESLEME.get(tur, "dut"))


# ------------------------------------------------------------------ malzeme
## Toon ışığa uygun köşe-renkli malzeme; rüzgârda tepe köşeleri salınır (alfa ağırlık).
static func mat() -> ShaderMaterial:
	if _mat == null:
		var sh := Shader.new()
		sh.code = """shader_type spatial;
render_mode diffuse_toon, specular_disabled, cull_disabled;
uniform float salinim = 1.0;
uniform float isik = 0.1;
varying vec3 vcol;
void vertex() {
	float w = clamp((1.0 - COLOR.a) * 2.0, 0.0, 1.0) * salinim;
	vec3 o = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float t = TIME * 1.15 + o.x * 0.061 + o.z * 0.043;
	VERTEX.x += sin(t) * 0.09 * w;
	VERTEX.z += sin(t * 1.37 + 1.7) * 0.06 * w;
	vec3 c = COLOR.rgb;
	vcol = mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}
void fragment() {
	ALBEDO = vcol;
	ROUGHNESS = 1.0;
	EMISSION = vcol * isik;      // yaprak geçirgenliği: gölge yüzü kapkara olmasın (gece 0'a yakın tutulur)
}
"""
		_mat = ShaderMaterial.new()
		_mat.shader = sh
	return _mat


# ------------------------------------------------------------------ ağ verisi
class Ag:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var c := PackedColorArray()

	## Sarım, verilen yumuşak normale göre düzeltilir (Godot ön yüzü: (c-a)×(b-a) yönü). Tutarsız sarım
	## cull_disabled ile arka yüz sayılıp normali çevriliyordu: yüz yüz koyu/açık "kristal" görünüm.
	func t(a: Vector3, b: Vector3, cc: Vector3, na: Vector3, nb: Vector3, nc: Vector3, ca: Color, cb: Color, ccol: Color) -> void:
		var fn := (cc - a).cross(b - a)
		if fn.dot(na + nb + nc) < 0.0:
			v.append(a); v.append(cc); v.append(b)
			n.append(na); n.append(nc); n.append(nb)
			c.append(ca); c.append(ccol); c.append(cb)
			return
		v.append(a); v.append(b); v.append(cc)
		n.append(na); n.append(nb); n.append(nc)
		c.append(ca); c.append(cb); c.append(ccol)

	func ucgen() -> int:
		return v.size() / 3


static func _h(a: float, b: float, s: int) -> float:
	return fposmod(sin(a * 12.9898 + b * 78.233 + float(s) * 4.1414) * 43758.5453, 1.0)


static func _ton(c: Color, k: float, sway: float) -> Color:
	## k: parlaklık çarpanı; sway: 0 (sabit) .. 1 (tam salınım) → alfa 1 .. 0,5
	var o := Color(c.r * k, c.g * k, c.b * k, 1.0 - clampf(sway, 0.0, 1.0) * 0.5)
	return o


## Polyline boyunca incelen boru (yumuşak normal). pts: Vector3 dizisi, rs: yarıçaplar. uc: tepe noktayla kapanır.
static func _boru(m: Ag, pts: Array, rs: Array, kenar: int, c0: Color, c1: Color, s0: float, s1: float, uc := true) -> void:
	var halkalar: Array = []
	var nrm: Array = []
	var np := pts.size()
	for i in np:
		var p: Vector3 = pts[i]
		var d: Vector3
		if i == 0:
			d = (pts[1] as Vector3) - p
		elif i == np - 1:
			d = p - (pts[i - 1] as Vector3)
		else:
			d = (pts[i + 1] as Vector3) - (pts[i - 1] as Vector3)
		d = d.normalized()
		var yan := d.cross(Vector3.FORWARD if absf(d.z) < 0.9 else Vector3.RIGHT).normalized()
		var yan2 := d.cross(yan).normalized()
		var halka: Array = []
		var hn: Array = []
		for k in kenar:
			var a := TAU * float(k) / kenar
			var u := yan * cos(a) + yan2 * sin(a)
			halka.append(p + u * float(rs[i]))
			hn.append(u)
		halkalar.append(halka)
		nrm.append(hn)
	for i in np - 1:
		var f0 := float(i) / float(np - 1)
		var f1 := float(i + 1) / float(np - 1)
		for k in kenar:
			var k2 := (k + 1) % kenar
			var sh0 := 0.85 + 0.15 * sin(float(k) * 2.1 + float(i))
			var sh1 := 0.85 + 0.15 * sin(float(k2) * 2.1 + float(i))
			var ca := _ton(c0.lerp(c1, f0), sh0, lerpf(s0, s1, f0))
			var cb := _ton(c0.lerp(c1, f0), sh1, lerpf(s0, s1, f0))
			var cc := _ton(c0.lerp(c1, f1), sh0, lerpf(s0, s1, f1))
			var cd := _ton(c0.lerp(c1, f1), sh1, lerpf(s0, s1, f1))
			var a: Vector3 = halkalar[i][k]
			var b: Vector3 = halkalar[i][k2]
			var c: Vector3 = halkalar[i + 1][k]
			var d: Vector3 = halkalar[i + 1][k2]
			m.t(a, b, d, nrm[i][k], nrm[i][k2], nrm[i + 1][k2], ca, cb, cd)
			m.t(a, d, c, nrm[i][k], nrm[i + 1][k2], nrm[i + 1][k], ca, cd, cc)
	if uc:
		var son: Vector3 = pts[np - 1]
		var dd := (son - (pts[np - 2] as Vector3)).normalized()
		var tepe := son + dd * float(rs[np - 1]) * 1.5
		var ct := _ton(c1, 0.95, s1)
		for k in kenar:
			var k2 := (k + 1) % kenar
			m.t(halkalar[np - 1][k], halkalar[np - 1][k2], tepe, nrm[np - 1][k], nrm[np - 1][k2], dd, ct, ct, ct)


## Yaprak öbeği: pürüzlü, yumuşak normalli elipsoid. Üst güneşli açık, alt ve iç koyu; köşe başına ton serpintisi.
## ic: 0..1 (taç merkezine yakınlık, koyulaştırır). seg/hal: çözünürlük.
static func _obek(m: Ag, c: Vector3, r: Vector3, seed: int, alt: Color, ust: Color, seg: int, hal: int, jit: float,
		sway: float, ic := 0.0, ciy := Color(0, 0, 0, 0), cio := 0.0) -> void:
	var noktalar: Array = []
	var normaller: Array = []
	var renkler: Array = []
	for j in hal + 1:
		var phi := PI * float(j) / hal
		var sat: Array = []
		var satn: Array = []
		var satc: Array = []
		var kk := seg if (j > 0 and j < hal) else 1
		for i in kk:
			var th := TAU * (float(i) + 0.5 * float(j % 2)) / seg + float(seed % 7) * 0.4
			var u := Vector3(sin(phi) * cos(th), cos(phi), sin(phi) * sin(th))
			var jj := 1.0 + (_h(float(i) + float(j) * 17.0, float(seed), seed) - 0.5) * 2.0 * jit
			if j == 0 or j == hal:
				jj = 1.0 - jit * 0.3
			var p := c + Vector3(u.x * r.x, u.y * r.y, u.z * r.z) * jj
			var nn := Vector3(u.x / r.x, u.y / r.y, u.z / r.z).normalized()
			# ışık: üst açık, alt koyu; iç taraf koyu; köşe serpintisi
			var up := u.y * 0.5 + 0.5
			# yumuşak dikey geçiş (üst güneşli, alt gölgeli); köşe gürültüsü düşük: yüz yüz mozaik/kristal okunmasın
			var col := alt.lerp(ust, clampf(smoothstep(0.0, 1.0, up) * 1.05 - ic * 0.3 + (_h(float(i), float(j), seed + 3) - 0.5) * 0.1, 0.0, 1.0))
			if cio > 0.0 and ciy.a > 0.0:
				# serpinti öbeğin bir yanına toplanır (yamalı ama mozaik değil)
				var yan := 0.5 + 0.5 * sin(th * 2.0 + float(seed % 13))
				if yan * 0.8 + _h(float(i) * 3.0, float(j) * 5.0, seed + 11) * 0.2 < cio:
					col = ciy.lerp(col, 0.2 + (1.0 - up) * 0.3)
			sat.append(p)
			satn.append(nn)
			satc.append(_ton(col, 1.0, sway * (0.6 + 0.4 * up)))
		noktalar.append(sat)
		normaller.append(satn)
		renkler.append(satc)
	for j in hal:
		for i in seg:
			var i2 := (i + 1) % seg
			if j == 0:
				m.t(noktalar[0][0], noktalar[1][i2], noktalar[1][i], normaller[0][0], normaller[1][i2], normaller[1][i],
					renkler[0][0], renkler[1][i2], renkler[1][i])
			elif j == hal - 1:
				m.t(noktalar[j][i], noktalar[j][i2], noktalar[hal][0], normaller[j][i], normaller[j][i2], normaller[hal][0],
					renkler[j][i], renkler[j][i2], renkler[hal][0])
			else:
				m.t(noktalar[j][i], noktalar[j][i2], noktalar[j + 1][i2], normaller[j][i], normaller[j][i2],
					normaller[j + 1][i2], renkler[j][i], renkler[j][i2], renkler[j + 1][i2])
				m.t(noktalar[j][i], noktalar[j + 1][i2], noktalar[j + 1][i], normaller[j][i], normaller[j + 1][i2],
					normaller[j + 1][i], renkler[j][i], renkler[j + 1][i2], renkler[j + 1][i])


## Küçük çiçek/yaprak kümesi (4 üçgenli dörtyüzlü), öbek yüzeyinin biraz dışında.
static func _benek(m: Ag, p: Vector3, s: float, col: Color, seed: int, sway: float) -> void:
	var a := float(seed) * 1.7
	var q0 := p + Vector3(cos(a), 0.35, sin(a)) * s
	var q1 := p + Vector3(cos(a + 2.1), 0.35, sin(a + 2.1)) * s
	var q2 := p + Vector3(cos(a + 4.2), 0.35, sin(a + 4.2)) * s
	var q3 := p + Vector3(0, -0.6, 0) * s
	var top := Vector3(0, 1, 0)
	var c1 := _ton(col, 1.0, sway)
	var c2 := _ton(col, 0.8, sway)
	m.t(q0, q1, q2, top, top, top, c1, c1, c1)
	m.t(q0, q3, q1, (q0 - p).normalized(), Vector3.DOWN, (q1 - p).normalized(), c2, c2, c2)
	m.t(q1, q3, q2, (q1 - p).normalized(), Vector3.DOWN, (q2 - p).normalized(), c2, c2, c2)
	m.t(q2, q3, q0, (q2 - p).normalized(), Vector3.DOWN, (q0 - p).normalized(), c2, c2, c2)


# ------------------------------------------------------------------ ağaç kurucu
## İskelet: [gövde noktaları, dal uçları (öbek merkezleri için), dal listesi]
static func _egri(a: Vector3, b: Vector3, bukum: Vector3, n: int) -> Array:
	var out: Array = []
	for i in n + 1:
		var f := float(i) / n
		out.append(a.lerp(b, f) + bukum * sin(f * PI))
	return out


static func agac(tur: String, lod: int) -> ArrayMesh:
	tur = tur_ad(tur)
	lod = clampi(lod, 0, 2)
	var key := "%s|%d" % [tur, lod]
	if _cache.has(key):
		return _cache[key]
	var d: Dictionary = TUR[tur]
	var m := Ag.new()
	var seed := (tur.hash() & 0xffff) + 13
	var bicim: String = d["bicim"]
	match bicim:
		"sutun":
			_servi(m, d, lod, seed)
		"calimsi":
			_cali(m, d, lod, seed)
		"kutuk":
			_kutuk(m, d, lod)
		_:
			_genel(m, d, lod, seed)
	var am := _bitir(m)
	am.set_meta("bitki_kit", tur)
	am.set_meta("ucgen", m.ucgen())
	_cache[key] = am
	return am


static func _bitir(m: Ag) -> ArrayMesh:
	var am := ArrayMesh.new()
	if m.v.is_empty():
		return am
	# parlaklık tavanı: hiçbir köşe saf beyaz değil (V ≤ PARLAK_TAVAN); saf yeşil yok (doygunluk ≤ 0,62)
	var cs := m.c
	for i in cs.size():
		var c := cs[i]
		var v := maxf(c.r, maxf(c.g, c.b))
		var a := c.a
		if v > PARLAK_TAVAN:
			c = Color(c.r * PARLAK_TAVAN / v, c.g * PARLAK_TAVAN / v, c.b * PARLAK_TAVAN / v, a)
		if c.s > 0.62:
			c = Color.from_hsv(c.h, 0.62, c.v, a)
		cs[i] = c
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = m.v
	arr[Mesh.ARRAY_NORMAL] = m.n
	arr[Mesh.ARRAY_COLOR] = cs
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	am.surface_set_material(0, mat())
	return am


static func _yon(seed: int, k: float) -> Vector3:
	var a := _h(k, 3.0, seed) * TAU
	return Vector3(cos(a), 0, sin(a))


## Yaprak döken / geniş taçlı genel ağaç (çınar, dut, ıhlamur, zeytin, incir, meyveler, erguvan, defne, çam).
## Taç bir zarf (merkez tc, yatay yarıçap tR, düşey yarı yükseklik tH) içinde birbirine geçen öbeklerden örülür:
## dallar zarfın içine uzanır, öbekler dal uçlarına ve zarf kabuğuna oturur; aralarda boşluk kalır.
static func _genel(m: Ag, d: Dictionary, lod: int, seed: int) -> void:
	var gh: float = d["gh"]
	var gr: float = d["gr"]
	var kb: Color = d["kb"]
	var y1: Color = d["y1"]
	var y2: Color = d["y2"]
	var bicim: String = d["bicim"]
	var egik := _yon(seed, 1.0) * float(d["egik"])
	var dal_n: int = d["dal"]
	var on: int = d["on"]
	var yas: float = d["yas"]
	var kok: int = maxi(1, int(d["kok"]))
	var tcy: float = d["tc"]
	var tR: float = d["tR"]
	var tH: float = d["tH"]
	var ciy: Color = d.get("ci2", Color(0, 0, 0, 0))
	var ciy1: Color = d.get("ci1", Color(0, 0, 0, 0))
	var cio: float = d.get("cio", 0.0)
	var yy: float = d.get("yy", 0.0)
	var cicekli := cio > 0.3
	var kenar: int = [5, 4, 3][lod]
	kok = mini(kok, [2, 1, 1][lod])
	var tc := Vector3(0, tcy, 0) + egik
	# öbek yarıçapı: çiçekli ağaçta küçük (dallar arada görünür)
	var orr := tR * (0.42 if cicekli else 0.5)
	if bicim == "semsiye":
		orr = tR * 0.4
	var uclar: Array = []
	for g in kok:
		var gy := _yon(seed, 10.0 + g) * (0.0 if kok == 1 else maxf(0.25, gr * 2.0))
		var b0 := Vector3(gy.x, -0.25, gy.z)
		var b1 := Vector3(0, gh, 0) + egik * (gh / maxf(tcy, 0.1)) + gy * 2.0
		if lod == 2:
			b1 = tc - Vector3(0, tH * 0.3, 0)
		var r0 := gr * (1.0 if kok == 1 else 0.72)
		var pts := _egri(b0, b1, _yon(seed, 20.0 + g) * maxf(gr * 1.5, 0.15), [3, 2, 1][lod])
		var rs: Array = []
		for i in pts.size():
			var f := float(i) / (pts.size() - 1)
			rs.append(r0 * 1.5 if i == 0 else r0 * lerpf(1.25, 0.72, f))
		_boru(m, pts, rs, kenar, kb.darkened(0.25), kb, 0.0, 0.1, false)
		if lod == 0 and g == 0:
			for k in 3:
				var ky := _yon(seed, 30.0 + k)
				_boru(m, [Vector3(0, gr * 1.2, 0), ky * gr * 2.6 + Vector3(0, -0.22, 0)], [r0 * 0.6, r0 * 0.12], 3,
					kb.darkened(0.3), kb.darkened(0.15), 0.0, 0.0, false)
		if lod == 2:
			continue
		var dn := dal_n if kok == 1 else maxi(2, int(ceil(float(dal_n) / kok)) + (1 if g == 0 else 0))
		if lod == 1:
			dn = mini(dn, 2)
		for i in dn:
			var az := TAU * (float(i) + 0.4 * _h(float(i), 6.0, seed + g)) / dn + float(g) * 1.3
			var el := lerpf(-0.35, 0.55, _h(float(i), 5.0, seed + g))
			if bicim == "semsiye":
				el = lerpf(-0.1, 0.25, _h(float(i), 5.0, seed + g))
			var hedef := tc + Vector3(cos(az) * tR * 0.72, el * tH, sin(az) * tR * 0.72)
			var s0 := b1 - Vector3(0, gh * 0.1 * _h(float(i), 8.0, seed), 0)
			var dpts := _egri(s0, hedef, Vector3(0, (hedef - s0).length() * 0.12, 0), 2 if lod == 0 else 1)
			var drs := []
			for k in dpts.size():
				drs.append(r0 * lerpf(0.55, 0.14, float(k) / (dpts.size() - 1)))
			_boru(m, dpts, drs, 4 if lod == 0 else 3, kb, kb.lightened(0.06), 0.1, 0.6, true)
			uclar.append(hedef)
			if lod == 0:
				# dalcık: dal ortasından yukarı-dışa (çiçekli ağaçta taçta seçilir)
				var m0: Vector3 = s0.lerp(hedef, 0.55)
				var dis := Vector3(hedef.x - tc.x, 0, hedef.z - tc.z).normalized()
				var me := m0 + (dis.rotated(Vector3.UP, 0.9 * (1.0 if i % 2 else -1.0)) * 0.8 + Vector3(0, 0.6, 0)) * tR * 0.55
				_boru(m, [m0, me], [r0 * 0.22, r0 * 0.06], 3, kb, kb.lightened(0.1), 0.4, 0.85, false)
				uclar.append(me)
	if lod == 2:
		# uzak: gövde taça girer + 3 düzensiz öbek (≤ 40 üçgen); siluet yine ağaç
		var ust := y2.darkened(0.12)
		var alt := y1
		if cicekli:
			ust = ust.lerp(ciy.darkened(0.1), 0.7)
			alt = alt.lerp(ciy1, 0.7)
		# iki kayık öbek (≤ 25 üçgen): tek top değil, yan yana iki kütle; siluet düzensiz
		_obek(m, tc + _yon(seed, 41.0) * tR * 0.25, Vector3(tR * 0.8, tH * 0.85, tR * 0.75), seed, alt, ust, 4, 2, 0.12, 0.6)
		_obek(m, tc + _yon(seed, 40.0) * tR * 0.45 + Vector3(0, tH * 0.3, 0), Vector3(tR, tH, tR) * 0.55, seed + 1,
			alt, ust, 4, 2, 0.12, 0.6)
		return
	# öbek merkezleri: tepe + dal uçları + zarf kabuğu (üst yarı ağırlıklı); lod 1'de az ama iri
	var hedef_n := mini(on, 7) if lod == 0 else 3
	var merkezler: Array = [tc + Vector3(0, tH * 0.45, 0)]
	for u: Vector3 in uclar:
		merkezler.append(u)
	var k := 0
	while merkezler.size() < hedef_n + 2 and k < 60:
		k += 1
		var az := _h(float(k), 50.0, seed) * TAU
		var el := lerpf(-0.5, 0.9, _h(float(k), 51.0, seed))
		var rr := lerpf(0.55, 0.85, _h(float(k), 52.0, seed))
		var q := tc + Vector3(cos(az) * sqrt(1.0 - el * el * 0.6) * tR * rr, el * tH * rr, sin(az) * sqrt(1.0 - el * el * 0.6) * tR * rr)
		var yakin := false
		for o: Vector3 in merkezler:
			if o.distance_to(q) < orr * 0.9:
				yakin = true
				break
		if not yakin:
			merkezler.append(q)
	if merkezler.size() > hedef_n:
		merkezler.resize(hedef_n)
	var seg := 6 if lod == 0 else 5
	var hal := 4 if lod == 0 else 3
	var olc := 1.0 if lod == 0 else 1.25
	# iç kütle: öbekler tek taç olarak okunsun (ayrık toplar değil); çiçekli ağaçta küçük, dallar görünsün
	var cek := 0.5 if cicekli else 0.72
	_obek(m, tc + Vector3(0, tH * 0.05, 0), Vector3(tR * cek, tH * cek, tR * cek * 0.92), seed + 99,
		y1.darkened(0.15), y1.lerp(y2, 0.45), seg if lod == 0 else 4, 4 if lod == 0 else 3, 0.1, 0.7, 0.8)
	var mi := 0
	for p: Vector3 in merkezler:
		var hf := clampf((p.y - (tc.y - tH)) / (2.0 * tH), 0.0, 1.0)
		var rr := orr * olc * (0.8 + 0.45 * _h(float(mi), 70.0, seed))
		var r := Vector3(rr, rr * yas, rr * (0.85 + 0.3 * _h(float(mi), 71.0, seed)))
		var icf := clampf(1.0 - Vector2(p.x - tc.x, p.z - tc.z).length() / maxf(tR, 0.1), 0.0, 1.0) * 0.5 + (1.0 - hf) * 0.5
		var alt := y1.darkened(0.12 * (1.0 - hf))
		var ust := y2.lerp(y1, 0.3 * (1.0 - hf))
		var cc := Color(0, 0, 0, 0)
		var co := 0.0
		if cio > 0.0:
			if _h(float(mi), 72.0, seed) < cio:
				alt = ciy1.lerp(y1, 0.2)            # gölgede gri-yeşile kaçan çiçek
				ust = ciy
				cc = y2
				co = yy
			else:
				cc = ciy
				co = 0.2
		_obek(m, p, r, seed + mi * 7, alt, ust, seg, hal, 0.13 if lod == 0 else 0.1, 1.0, icf, cc, co)
		mi += 1
	# yakında benekler: siluet kenarı pürüzlü (yaprak/çiçek kümeleri)
	if lod == 0:
		var bmax := 16 if cicekli else 6
		var bn := 0
		var kk := 0
		while bn < bmax and kk < 200 and m.ucgen() <= int(UCGEN_SINIR[0]) - 4:
			kk += 1
			var p: Vector3 = merkezler[kk % merkezler.size()]
			var u := Vector3(_h(float(kk), 80.0, seed) - 0.5, _h(float(kk), 81.0, seed) - 0.3, _h(float(kk), 82.0, seed) - 0.5)
			if u.length() < 0.1:
				continue
			u = u.normalized()
			var q := p + Vector3(u.x * orr, u.y * orr * yas, u.z * orr) * 1.0
			var col := y2 if not cicekli else (ciy if _h(float(kk), 83.0, seed) > yy else y2)
			col = col.darkened(0.25 * (0.5 - u.y * 0.5))
			_benek(m, q, orr * 0.3, col, seed + kk, 1.0)
			bn += 1


## Servi: ince, sık, koyu; düz koni değil, üst üste fıçı da değil: tek parça "iğ" gövde, yüzeyinde dikey yivler
## (fırça dokusu: yiv sırtı açık, oluğu koyu), tepesi hafif eğik ve sivri; dışında birkaç ince tutam.
static func _servi(m: Ag, d: Dictionary, lod: int, seed: int) -> void:
	var boy: float = d["boy"]
	var gr: float = d["gr"]
	var kb: Color = d["kb"]
	var y1: Color = d["y1"]
	var y2: Color = d["y2"]
	var orr: float = d["orr"]
	var egik := _yon(seed, 1.0) * float(d["egik"])
	var kenar: int = [5, 4, 3][lod]
	if lod == 2:
		_boru(m, [Vector3(0, -0.25, 0), Vector3(0, 1.4, 0)], [gr * 1.3, gr * 0.8], kenar, kb.darkened(0.2), kb, 0.0, 0.05, false)
	else:
		_boru(m, [Vector3(0, -0.25, 0), Vector3(0, 0.6, 0), Vector3(0, 1.4, 0) + egik * 0.05], [gr * 1.5, gr, gr * 0.8], kenar,
			kb.darkened(0.2), kb, 0.0, 0.05, false)
	var seg: int = [11, 7, 4][lod]
	var hal: int = [10, 6, 3][lod]
	var y0 := 0.9
	var noktalar: Array = []
	var normaller: Array = []
	var renkler: Array = []
	for j in hal + 1:
		var t := float(j) / hal
		var y := lerpf(y0, boy, t)
		# profil: dipte dolgun, ortada en geniş (~%35), tepeye sivrilir
		var pr := pow(sin(PI * clampf(t * 0.92 + 0.04, 0.0, 1.0)), 0.75) * (1.0 - 0.45 * t)
		if j == hal:
			pr = 0.0
		var dpr := (pow(sin(PI * clampf((t + 0.05) * 0.92 + 0.04, 0.0, 1.0)), 0.75) * (1.0 - 0.45 * (t + 0.05)) - pr) / 0.05
		var off := egik * pow(t, 2.2) + _yon(seed, 90.0 + j) * orr * 0.06 * (1.0 - t)
		var sat: Array = []
		var satn: Array = []
		var satc: Array = []
		for i in seg:
			var th := TAU * float(i) / seg + t * 0.9
			var yiv := 1.0 + (0.16 if lod < 2 else 0.06) * sin(th * 5.0 + float(j) * 0.7) + (_h(float(i), float(j), seed) - 0.5) * (0.18 if lod == 0 else 0.08)
			var r := orr * pr * yiv
			var u := Vector3(cos(th), 0, sin(th))
			sat.append(Vector3(0, y, 0) + off + u * r)
			satn.append((u - Vector3(0, dpr * orr / boy * 0.6, 0)).normalized())
			var sirt := clampf((yiv - 0.84) / 0.32, 0.0, 1.0)
			var col := y1.lerp(y2, clampf(0.25 + t * 0.45 + sirt * 0.35, 0.0, 1.0))
			satc.append(_ton(col, 1.0, t))
		noktalar.append(sat)
		normaller.append(satn)
		renkler.append(satc)
	for j in hal:
		for i in seg:
			var i2 := (i + 1) % seg
			m.t(noktalar[j][i], noktalar[j][i2], noktalar[j + 1][i2], normaller[j][i], normaller[j][i2], normaller[j + 1][i2],
				renkler[j][i], renkler[j][i2], renkler[j + 1][i2])
			if j < hal - 1:
				m.t(noktalar[j][i], noktalar[j + 1][i2], noktalar[j + 1][i], normaller[j][i], normaller[j + 1][i2],
					normaller[j + 1][i], renkler[j][i], renkler[j + 1][i2], renkler[j + 1][i])
	# alt kapak (gövdenin çıktığı yer koyu; uzakta görünmez)
	var alt := Vector3(0, y0 - 0.1, 0)
	for i in (seg if lod < 2 else 0):
		var i2 := (i + 1) % seg
		var ca := _ton(y1.darkened(0.3), 1.0, 0.0)
		m.t(noktalar[0][i2], noktalar[0][i], alt, Vector3.DOWN, Vector3.DOWN, Vector3.DOWN, ca, ca, ca)
	if lod == 0:
		# dışa taşan ince tutamlar: siluet pürüzlü
		for k in 18:
			var t := 0.12 + 0.72 * _h(float(k), 2.0, seed)
			var j := clampi(int(t * hal), 0, hal - 1)
			var i := int(_h(float(k), 3.0, seed) * seg) % seg
			var p: Vector3 = noktalar[j][i]
			var nn: Vector3 = normaller[j][i]
			var col := y2.darkened(0.1 + 0.2 * _h(float(k), 4.0, seed))
			var yan := nn.cross(Vector3.UP).normalized() * orr * 0.16
			var top := p + Vector3(0, 0.9, 0) + nn * 0.2
			var ca := _ton(col, 1.0, t)
			m.t(p - yan - nn * 0.1, p + yan - nn * 0.1, top, nn, nn, nn, ca, ca, _ton(col, 1.1, t))


## Çalı (böğürtlen/maki): alçak, düzensiz öbek kümesi; dipte koyu, gövdesiz.
static func _cali(m: Ag, d: Dictionary, lod: int, seed: int) -> void:
	var orr: float = d["orr"]
	var y1: Color = d["y1"]
	var y2: Color = d["y2"]
	var n := 7 if lod == 0 else (4 if lod == 1 else 2)
	var seg := 6 if lod == 0 else (5 if lod == 1 else 4)
	for i in n:
		var a := TAU * float(i) / n + _h(float(i), 1.0, seed)
		var rr := orr * (0.7 + 0.5 * _h(float(i), 2.0, seed))
		var p := Vector3(cos(a), 0, sin(a)) * orr * (0.2 if i == 0 else 0.85) + Vector3(0, rr * 0.55, 0)
		if i == 0:
			rr *= 1.25
			p.y = rr * 0.7
		_obek(m, p, Vector3(rr, rr * 0.75, rr), seed + i * 3, y1, y2, seg, 3 if lod < 2 else 2, 0.25, 0.4, 0.3)
	if lod == 0:
		for k in 10:
			var a := _h(float(k), 5.0, seed) * TAU
			var p := Vector3(cos(a) * orr * 1.2, orr * (0.4 + 0.6 * _h(float(k), 6.0, seed)), sin(a) * orr * 1.2)
			var col := y2 if k % 3 else Color("e2d4d0").darkened(0.2)
			_benek(m, p, 0.12, col, seed + k, 0.5)


## Kesilmiş ağaç kütüğü (ateş alanı): kısa, kesik yüzü açık.
static func _kutuk(m: Ag, d: Dictionary, lod: int) -> void:
	var gr: float = d["gr"]
	var kb: Color = d["kb"]
	var kenar: int = [7, 5, 4][lod]
	var h: float = d["boy"]
	_boru(m, [Vector3(0, -0.25, 0), Vector3(0, h * 0.5, 0), Vector3(0, h, 0.03)], [gr * 1.3, gr, gr * 0.95], kenar,
		kb.darkened(0.3), kb, 0.0, 0.0, false)
	var kesik := Color("b49a72")
	var up := Vector3.UP
	for k in kenar:
		var a0 := TAU * float(k) / kenar
		var a1 := TAU * float(k + 1) / kenar
		var c := Vector3(0, h + 0.02, 0.03)
		m.t(c, c + Vector3(cos(a1), 0, sin(a1)) * gr * 0.95, c + Vector3(cos(a0), 0, sin(a0)) * gr * 0.95, up, up, up,
			_ton(kesik, 1.0, 0), _ton(kesik, 0.85, 0), _ton(kesik, 0.9, 0))
	if lod == 0:
		for k in 3:
			var ky := _yon(17, 30.0 + k)
			_boru(m, [Vector3(0, 0.15, 0), ky * gr * 2.0 + Vector3(0, -0.15, 0)], [gr * 0.5, gr * 0.12], 3,
				kb.darkened(0.3), kb.darkened(0.2), 0.0, 0.0, false)


# ------------------------------------------------------------------ yerleştirme yardımcıları
## Tek ağaç düğümü: görsel + gövde çarpışması (taç çarpışmasız). lod 2'de çarpışma yok.
static func dugum(tur: String, lod := 0, olcek := 1.0, kati := true) -> Node3D:
	tur = tur_ad(tur)
	var d: Dictionary = TUR[tur]
	var root := Node3D.new()
	root.name = "bitki_" + tur
	var mi := MeshInstance3D.new()
	mi.name = "govde_tac"
	mi.mesh = agac(tur, lod)
	mi.scale = Vector3.ONE * olcek
	root.add_child(mi)
	if kati and lod <= 1 and float(d["gr"]) > 0.08 and String(d["bicim"]) != "calimsi":
		var body := StaticBody3D.new()
		body.name = "govde_katı"
		var cs := CollisionShape3D.new()
		var cy := CylinderShape3D.new()
		cy.radius = maxf(0.18, float(d["gr"]) * 1.15) * olcek
		cy.height = maxf(0.6, float(d["gh"])) * olcek
		cs.shape = cy
		cs.position = Vector3(0, cy.height * 0.5, 0)
		body.add_child(cs)
		root.add_child(body)
	return root


## Gövde çarpışma ölçüsü (r, h) — MultiMesh kullanan kurucular kendi şekillerini kurar.
static func govde_olcu(tur: String, olcek := 1.0) -> Vector2:
	var d: Dictionary = TUR[tur_ad(tur)]
	return Vector2(maxf(0.18, float(d["gr"]) * 1.15) * olcek, maxf(0.6, float(d["gh"])) * olcek)


## Sonda: bir ağdaki parlak (V > 0,92) köşe rengi sayısı.
static func beyaz_say(am: Mesh) -> int:
	if am == null or am.get_surface_count() == 0:
		return 0
	var cs: PackedColorArray = am.surface_get_arrays(0)[Mesh.ARRAY_COLOR]
	var n := 0
	for c in cs:
		if maxf(c.r, maxf(c.g, c.b)) > 0.92:
			n += 1
	return n


## Toplam boyu `boy` metre olacak biçimde ölçeklenmiş ağ (eski kurucuların boyunu korumak için; önbellekli).
static func agac_boy(tur: String, lod: int, boy: float) -> ArrayMesh:
	tur = tur_ad(tur)
	var key := "%s|%d|%.1f" % [tur, lod, snappedf(boy, 0.5)]
	if _cache.has(key):
		return _cache[key]
	var src := agac(tur, lod)
	var k := snappedf(boy, 0.5) / maxf(0.1, src.get_aabb().end.y)
	var arr := src.surface_get_arrays(0)
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	for i in vs.size():
		vs[i] = vs[i] * k
	arr[Mesh.ARRAY_VERTEX] = vs
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	am.surface_set_material(0, mat())
	am.set_meta("bitki_kit", tur)
	_cache[key] = am
	return am


## Görsel ağaç (çarpışmasız; çağıran kendi gövde çarpışmasını kurar). Aynı düğüme konan bütün kit ağaçları TEK
## ağda toplanır ("BitkiToplu"): eser/kilise pişiricileri gölgelendiricili ağı birleştirmediği için ağaç başına ayrı
## çizim olmasın (çizim sayısı artmaz). Konumlar sonda için "bitki_konum" iminde tutulur.
static func ornek(host: Node3D, tur: String, pos: Vector3, boy: float, lod := 0, yaw := 0.0) -> MeshInstance3D:
	var mi := host.get_node_or_null("BitkiToplu") as MeshInstance3D
	if mi == null:
		mi = MeshInstance3D.new()
		mi.name = "BitkiToplu"
		mi.set_meta("dekor", true)
		mi.set_meta("bitki_konum", [])
		host.add_child(mi)
	var src := agac_boy(tur, lod, boy)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	if mi.mesh != null and mi.mesh.get_surface_count() > 0:
		st.append_from(mi.mesh, 0, Transform3D.IDENTITY)
	st.append_from(src, 0, Transform3D(Basis(Vector3.UP, yaw), pos))
	var am := st.commit()
	am.surface_set_material(0, mat())
	am.set_meta("bitki_kit", tur_ad(tur))
	mi.mesh = am
	(mi.get_meta("bitki_konum") as Array).append([pos, tur_ad(tur)])
	return mi


## Gövde çarpışması (katı silindir; taç çarpışmasız). Eski kurucuların katı gövdesinin yerine.
static func govde(host: Node3D, pos: Vector3, r: float, h: float) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = "govde_kati"
	var cs := CollisionShape3D.new()
	var cy := CylinderShape3D.new()
	cy.radius = r
	cy.height = h
	cs.shape = cy
	body.position = pos + Vector3(0, h * 0.5, 0)
	body.add_child(cs)
	host.add_child(body)
	return body
