class_name FigCostume
extends RefCounted
## Zaman Bürosu'ndaki tarihî figürlerin kostümleri (v0.99.101). Kullanıcı: "Cengiz Han havalı durmalı", "Kleopatra'nın
## kıyafeti çok kötü", "Gagarin kötü", "Sezar Putin'e benzemiş", "Kanuni'nin kıyafetinde hata var" ve "fes Tolga'ya
## özel kalsın". Her parça kişinin gövdesine (_body), başına (_head) ya da koluna takılır: oturunca, nefes alınca,
## dönünce onunla gider (kişiye takılan kuşak ve yaka oturunca yerinde kalıyordu).
## Kişi +z'ye bakar. Gövde: 0,69..1,31 m kapsül (yarıçap 0,225), omuzlar 1,28 m (kollar x ±0,3), baş 1,58 m (r 0,2).

const GOLD := Color("d4a640")
const GOLD_DK := Color("a87c2a")
const STEEL := Color("8c949c")
const FUR := Color("5a4030")


static func dress(id: String, p: Person) -> void:
	match id:
		"nap":
			_napoleon(p)
		"cae":
			_caesar(p)
		"cle":
			_cleopatra(p)
		"gen":
			_genghis(p)
		"hit":
			_hitler(p)
		"sul":
			_suleyman(p)
		"gag":
			_gagarin(p)
		"shk":
			_shakespeare(p)
		"col":
			_columbus(p)
		"moz":
			_mozart(p)
		"cur":
			_curie(p)
		"gal":
			_galileo(p)
		"ein":
			_einstein(p)
		"tes":
			_tesla(p)
		"edi":
			_edison(p)
		"sok":
			_socrates(p)
		"dio":
			_diogenes(p)
		"new":
			_newton(p)
		"evl":
			_evliya(p)


static func _knee(p: Person, side: int) -> Node3D:
	return p._knee_l if side < 0 else p._knee_r


static func _elbow(p: Person, side: int) -> Node3D:
	var arm: Node3D = p._arm_l if side < 0 else p._arm_r
	return arm.find_child("Elbow", true, false) as Node3D


# ---------------------------------------------------------------- Napolyon

static func _napoleon(p: Person) -> void:
	var b: Node3D = p._body
	var h: Node3D = p._head
	# Yan giyilen iki köşeli şapka: ortası yüksek, iki ucu sivri; altın şerit ve üç renkli kokart
	var hat := Node3D.new()
	hat.position = Vector3(0, 0.2, -0.01)
	h.add_child(hat)
	var black := Color("141418")
	Props.box(hat, Vector3(0.34, 0.2, 0.13), Vector3(0, 0.08, 0), black)
	Props.ball(hat, 0.13, Vector3(0, 0.17, 0), black, Vector3(1.35, 0.6, 0.55), 10)
	for sx: float in [-1.0, 1.0]:
		Props.cyl(hat, 0.07, 0.22, Vector3(sx * 0.25, 0.05, 0), black, Vector3(0, 0, sx * -72.0), 8, 0.012)
	Props.box(hat, Vector3(0.62, 0.018, 0.135), Vector3(0, -0.02, 0), GOLD_DK)
	Props.cyl(hat, 0.045, 0.012, Vector3(-0.1, 0.1, 0.07), Color("2a4ab0"), Vector3(90, 0, 0), 10)
	Props.cyl(hat, 0.03, 0.014, Vector3(-0.1, 0.1, 0.077), Color("f2f0ea"), Vector3(90, 0, 0), 10)
	Props.cyl(hat, 0.016, 0.016, Vector3(-0.1, 0.1, 0.083), Color("c42a22"), Vector3(90, 0, 0), 8)
	# Kırmızı yaka, beyaz yelek, iki sıra altın düğme, altın apoletler
	Props.cyl(b, 0.1, 0.06, Vector3(0, 1.33, 0), Color("b8262a"), Vector3.ZERO, 12)
	Props.box(b, Vector3(0.2, 0.36, 0.03), Vector3(0, 1.06, 0.215), Color("f2efe6"))
	for k in 4:
		for sx: float in [-1.0, 1.0]:
			Props.ball(b, 0.016, Vector3(sx * 0.13, 1.2 - k * 0.1, 0.205), GOLD, Vector3.ONE, 6)
	for sx: float in [-1.0, 1.0]:
		Props.ball(b, 0.07, Vector3(sx * 0.27, 1.33, 0), GOLD, Vector3(1.3, 0.35, 1.0), 8)
		for k in 4:
			Props.cyl(b, 0.008, 0.07, Vector3(sx * (0.3 + 0.02 * k), 1.29, -0.04 + 0.03 * k), GOLD_DK, Vector3.ZERO, 4)
	# Diz boyu siyah süvari çizmesi
	for side: int in [-1, 1]:
		var kn := _knee(p, side)
		if kn:
			Props.cyl(kn, 0.1, 0.36, Vector3(0, -0.16, 0.0), Color("121214"), Vector3.ZERO, 10, 0.095)


# ---------------------------------------------------------------- Sezar

static func _caesar(p: Person) -> void:
	var b: Node3D = p._body
	# Toga: soldan sağ kalçaya çapraz düşen kumaş, mor bordür; sırtta kırmızı pelerin (paludamentum); sandalet
	var toga := Color("f2ede0")
	var purple := Color("5a2a6a")
	Props.box(b, Vector3(0.12, 0.85, 0.5), Vector3(0.02, 1.02, 0.0), toga, Vector3(0, 0, 28))
	Props.box(b, Vector3(0.124, 0.85, 0.06), Vector3(0.02, 1.02, 0.235), purple, Vector3(0, 0, 28))
	Props.box(b, Vector3(0.14, 0.5, 0.42), Vector3(-0.2, 1.05, 0.0), toga, Vector3(0, 0, -8))
	Props.box(b, Vector3(0.5, 1.05, 0.04), Vector3(0, 0.82, -0.25), Color("9a1f24"), Vector3(-6, 0, 0))
	Props.ball(b, 0.035, Vector3(-0.2, 1.3, 0.16), GOLD, Vector3.ONE, 6)     # pelerin iğnesi
	for side: int in [-1, 1]:
		var kn := _knee(p, side)
		if kn:
			for k in 3:
				Props.cyl(kn, 0.088, 0.018, Vector3(0, -0.24 - k * 0.1, 0), Color("6a4a2a"), Vector3.ZERO, 8)


# ---------------------------------------------------------------- Kleopatra

static func _cleopatra(p: Person) -> void:
	var b: Node3D = p._body
	var h: Node3D = p._head
	# Kahküller (alında düz kesik), sürmeli gözler, altın küpeler
	Props.box(h, Vector3(0.36, 0.09, 0.08), Vector3(0, 0.15, 0.15), Color("121010"), Vector3(-12, 0, 0))
	for sx: float in [-1.0, 1.0]:
		Props.box(h, Vector3(0.07, 0.008, 0.01), Vector3(sx * 0.105, 0.03, 0.18), Color("101014"), Vector3(0, sx * -30.0, sx * 14.0))
		Props.ball(h, 0.022, Vector3(sx * 0.2, -0.08, 0.02), GOLD, Vector3(1, 1.6, 1), 6)
	# Tacın önünde yükselen altın kobra (uraeus)
	Props.cyl(h, 0.016, 0.1, Vector3(0, 0.2, 0.2), GOLD, Vector3(-10, 0, 0), 6)
	Props.ball(h, 0.03, Vector3(0, 0.26, 0.21), GOLD, Vector3(1.3, 0.9, 1.0), 6)
	# Geniş renkli gerdanlık (usekh): omuzlara yayılan altın, lacivert, turkuaz, kırmızı halkalar
	var bands := [[0.29, GOLD], [0.25, Color("2a4a9a")], [0.21, Color("2ab0a0")], [0.17, Color("b8322a")], [0.13, GOLD]]
	for i in bands.size():
		var bd: Array = bands[i]
		Props.cyl(b, float(bd[0]), 0.025, Vector3(0, 1.32 - i * 0.004, 0.02), bd[1], Vector3(8, 0, 0), 20)
	# Elbise: dikey pliseler, altın-mavi kuşak ve önden sarkan uç
	for k in 5:
		Props.box(b, Vector3(0.012, 0.55, 0.01), Vector3(-0.14 + k * 0.07, 0.5, 0.27), Color("ddd4bc"), Vector3(-6, 0, 0))
	Props.cyl(b, 0.235, 0.06, Vector3(0, 0.74, 0), Color("2a4a9a"), Vector3.ZERO, 16)
	Props.cyl(b, 0.238, 0.02, Vector3(0, 0.76, 0), GOLD, Vector3.ZERO, 16)
	Props.box(b, Vector3(0.1, 0.5, 0.02), Vector3(0, 0.48, 0.27), Color("2a4a9a"), Vector3(-6, 0, 0))
	Props.box(b, Vector3(0.1, 0.03, 0.025), Vector3(0, 0.25, 0.3), GOLD, Vector3(-6, 0, 0))
	# Kollarda altın bilezikler
	for side: int in [-1, 1]:
		var arm: Node3D = p._arm_l if side < 0 else p._arm_r
		Props.cyl(arm, 0.075, 0.04, Vector3(0, -0.12, 0), GOLD, Vector3.ZERO, 10)


# ---------------------------------------------------------------- Cengiz Han

static func _genghis(p: Person) -> void:
	var b: Node3D = p._body
	var h: Node3D = p._head
	# Kürk kenarlı, parlak çelik sivri miğfer; tepede kırmızı at kılı püskül, enseye inen deri-zırh siper
	var hat := Node3D.new()
	hat.position = Vector3(0, 0.12, -0.01)
	h.add_child(hat)
	Props.ball(hat, 0.215, Vector3(0, 0.03, 0), FUR, Vector3(1.12, 0.42, 1.12), 14)
	Props.cyl(hat, 0.2, 0.19, Vector3(0, 0.155, 0), STEEL, Vector3.ZERO, 14, 0.06)
	Props.cyl(hat, 0.205, 0.022, Vector3(0, 0.08, 0), GOLD_DK, Vector3.ZERO, 14)
	Props.cyl(hat, 0.065, 0.03, Vector3(0, 0.26, 0), GOLD, Vector3.ZERO, 8)
	Props.cyl(hat, 0.012, 0.08, Vector3(0, 0.31, 0), GOLD, Vector3.ZERO, 6)
	var red := Color("a8182a")
	for k in 6:
		var a := TAU * k / 6.0
		Props.cyl(hat, 0.014, 0.2, Vector3(sin(a) * 0.06, 0.3, cos(a) * 0.06), red, Vector3(cos(a) * 55.0, 0, -sin(a) * 55.0), 4)
	# Ense siperi: kürk astarlı deri, başın arkasına oturur (kutu pullar dışarı taşıyordu)
	Props.ball(hat, 0.19, Vector3(0, -0.13, -0.09), Color("3a2a1c"), Vector3(1.08, 0.85, 0.75), 12)
	# İnce, uçları aşağı sarkan bıyık (dudak üstünde yatay, uçlar çeneye doğru)
	var mus := Color("15100c")
	Props.box(h, Vector3(0.11, 0.014, 0.02), Vector3(0, -0.085, 0.19), mus)
	for sx: float in [-1.0, 1.0]:
		Props.cyl(h, 0.008, 0.13, Vector3(sx * 0.065, -0.145, 0.185), mus, Vector3(-6, 0, sx * -14.0), 4)
	# Lacivert, altın kenarlı deel; göğüste lake deri zırh ve parlak bronz ayna (toli); kürk omuzluk; geniş kemer
	var deel := Color("223050")
	Props.cyl(b, 0.31, 0.62, Vector3(0, 0.45, 0), deel, Vector3.ZERO, 16, 0.24)
	Props.cyl(b, 0.315, 0.04, Vector3(0, 0.15, 0), GOLD_DK, Vector3.ZERO, 16)
	var lac := Color("5a1a18")
	Props.box(b, Vector3(0.44, 0.4, 0.05), Vector3(0, 1.04, 0.205), lac)
	Props.box(b, Vector3(0.44, 0.4, 0.05), Vector3(0, 1.04, -0.205), lac)
	for r in 3:
		Props.box(b, Vector3(0.445, 0.018, 0.055), Vector3(0, 0.88 + r * 0.13, 0.205), GOLD_DK)
		Props.box(b, Vector3(0.445, 0.018, 0.055), Vector3(0, 0.88 + r * 0.13, -0.205), GOLD_DK)
	Props.cyl(b, 0.085, 0.02, Vector3(0, 1.07, 0.236), Color("c89a4a"), Vector3(90, 0, 0), 16, -1.0, 0.25)
	Props.cyl(b, 0.095, 0.014, Vector3(0, 1.07, 0.232), GOLD_DK, Vector3(90, 0, 0), 16)
	for sx: float in [-1.0, 1.0]:
		Props.ball(b, 0.13, Vector3(sx * 0.24, 1.3, 0), FUR, Vector3(1.25, 0.6, 1.2), 10)
	Props.cyl(b, 0.245, 0.08, Vector3(0, 0.8, 0), Color("2a1a10"), Vector3.ZERO, 16)
	Props.box(b, Vector3(0.1, 0.08, 0.03), Vector3(0, 0.8, 0.245), GOLD)
	# Belde kavisli kılıç (sol yan)
	var sab := Node3D.new()
	sab.position = Vector3(-0.27, 0.62, 0.05)
	sab.rotation_degrees = Vector3(18, 0, 10)
	b.add_child(sab)
	Props.box(sab, Vector3(0.04, 0.62, 0.06), Vector3(0, -0.1, 0), Color("2a1a10"))
	Props.box(sab, Vector3(0.12, 0.025, 0.04), Vector3(0, 0.22, 0), GOLD)
	Props.cyl(sab, 0.016, 0.12, Vector3(0, 0.3, 0), Color("4a2a1a"), Vector3.ZERO, 6)
	# Sırtta çapraz duran çifte kavisli yay (düzgün yay: 12 parça) ve kirişi; yanında okluk
	var bow := Node3D.new()
	bow.position = Vector3(0, 1.0, -0.27)
	bow.rotation_degrees = Vector3(0, 0, 32)
	b.add_child(bow)
	var n := 12
	for k in n:
		var a := deg_to_rad(-62.0 + (k + 0.5) * 124.0 / n)
		var rr := 0.4 + (0.03 if absf(a) > 0.9 else 0.0)
		Props.box(bow, Vector3(0.022, 0.075, 0.022), Vector3(sin(a) * rr, -cos(a) * rr + 0.4, 0), Color("4a2a14"), Vector3(0, 0, rad_to_deg(a)))
	Props.box(bow, Vector3(0.004, 0.72, 0.004), Vector3(0, 0.21, 0.0), Color("e8e0c8"))
	Props.cyl(b, 0.055, 0.42, Vector3(0.17, 0.95, -0.27), Color("4a2a14"), Vector3(0, 0, -14), 8)
	for k in 4:
		Props.box(b, Vector3(0.008, 0.06, 0.03), Vector3(0.21 + k * 0.012 - 0.03, 1.2 + k * 0.006, -0.27 + (k % 2) * 0.02), Color("e8e0c8"), Vector3(0, 0, -14))
	# Ucu kalkık deri çizmeler
	for side: int in [-1, 1]:
		var kn := _knee(p, side)
		if kn:
			Props.cyl(kn, 0.098, 0.3, Vector3(0, -0.2, 0), Color("2a1a10"), Vector3.ZERO, 10, 0.092)


# ---------------------------------------------------------------- Hitler

static func _hitler(p: Person) -> void:
	var b: Node3D = p._body
	var h: Node3D = p._head
	# Alnına düşen perçem (yandan ayrılmış saç); kemer ve çapraz kayış (hiçbir işaret yok)
	Props.box(h, Vector3(0.16, 0.05, 0.05), Vector3(-0.05, 0.13, 0.17), Color("2a2018"), Vector3(-20, 0, -24))
	Props.cyl(b, 0.235, 0.06, Vector3(0, 0.8, 0), Color("2a1e14"), Vector3.ZERO, 16)
	Props.box(b, Vector3(0.07, 0.06, 0.02), Vector3(0, 0.8, 0.24), Color("9a9078"))
	Props.box(b, Vector3(0.045, 0.62, 0.48), Vector3(0, 1.05, 0), Color("2a1e14"), Vector3(0, 90, 34))


# ---------------------------------------------------------------- Kanuni

static func _suleyman(p: Person) -> void:
	var b: Node3D = p._body
	var h: Node3D = p._head
	# Meşhur iri beyaz kavuk: başa oturan sargı + kabarık gövde, önde sorguç (altın kılıf, yakut, iki tüy). Fes gibi
	# duran kırmızı tepelik yok.
	var cloth := Color("f4f0e4")
	Props.ring(h, 0.18, 0.25, Vector3(0, 0.13, -0.01), cloth.darkened(0.05), Vector3(-6, 0, 0))
	Props.ball(h, 0.27, Vector3(0, 0.33, -0.02), cloth, Vector3(1.25, 0.95, 1.2), 14)
	for k in 5:
		Props.ring(h, 0.26 + 0.006 * k, 0.28 + 0.006 * k, Vector3(0, 0.22 + k * 0.05, -0.02), cloth.darkened(0.08), Vector3(-6 + k * 3.0, 0, 0))
	Props.cyl(h, 0.022, 0.12, Vector3(0.05, 0.36, 0.26), GOLD, Vector3(-10, 0, 0), 6)
	Props.ball(h, 0.03, Vector3(0.05, 0.31, 0.27), Color("b0142a"), Vector3.ONE, 6)
	for k in 2:
		Props.box(h, Vector3(0.025, 0.22, 0.012), Vector3(0.05 + k * 0.03, 0.5, 0.24), [Color("f8f6f0"), Color("1a1a1e")][k], Vector3(-14, 0, -8 + k * 16.0))
	# Kaftan: altın brokar dış, önde açık; içteki yeşil entari ön şeritte görünür, iki yanında kürk kenar
	var green := Color("2f6a4a")
	Props.box(b, Vector3(0.16, 0.36, 0.02), Vector3(0, 1.12, 0.222), green)
	Props.box(b, Vector3(0.17, 0.8, 0.02), Vector3(0, 0.56, 0.29), green, Vector3(-5, 0, 0))
	for sx: float in [-1.0, 1.0]:
		Props.box(b, Vector3(0.05, 0.38, 0.035), Vector3(sx * 0.105, 1.12, 0.22), FUR)
		Props.box(b, Vector3(0.05, 0.82, 0.035), Vector3(sx * 0.11, 0.56, 0.285), FUR, Vector3(-5, 0, 0))
	Props.ball(b, 0.15, Vector3(0, 1.3, -0.02), FUR, Vector3(1.9, 0.5, 1.5), 10)
	# Mücevherli kuşak
	Props.cyl(b, 0.24, 0.07, Vector3(0, 0.85, 0), Color("8a1a24"), Vector3.ZERO, 16)
	for k in 3:
		Props.ball(b, 0.02, Vector3(-0.06 + k * 0.06, 0.85, 0.235), GOLD, Vector3.ONE, 6)


# ---------------------------------------------------------------- Gagarin

static func _gagarin(p: Person) -> void:
	var b: Node3D = p._body
	# Yüz görünür (kask koltuğun altında): turuncu SK-1 tulumu, boyun halkası, göğüste bağlantı paneli, kayışlar
	Props.cyl(b, 0.13, 0.06, Vector3(0, 1.33, 0), Color("d8dce0"), Vector3.ZERO, 14)
	Props.box(b, Vector3(0.2, 0.16, 0.04), Vector3(0, 1.0, 0.215), Color("e8e8e4"))
	for k in 3:
		Props.cyl(b, 0.018, 0.02, Vector3(-0.06 + k * 0.06, 1.02, 0.24), [Color("2a5ab0"), Color("c42a22"), Color("2a2a2e")][k], Vector3(90, 0, 0), 8)
	for sx: float in [-1.0, 1.0]:
		Props.box(b, Vector3(0.04, 0.55, 0.47), Vector3(sx * 0.1, 1.03, 0.0), Color("3a3a40"), Vector3(0, 0, sx * 4.0))
	# Beyaz kask, üstünde kırmızı "СССР": sol kolun altında, kalçaya dayalı
	var helm := Node3D.new()
	helm.position = Vector3(-0.4, 0.98, 0.1)
	helm.rotation_degrees = Vector3(0, -30, 0)
	b.add_child(helm)
	Props.ball(helm, 0.17, Vector3.ZERO, Color("f2f2ee"), Vector3.ONE, 12)
	Props.ball(helm, 0.12, Vector3(0, 0.0, 0.09), Color("2a3038"), Vector3(1.0, 0.8, 0.6), 10)
	Props.label(helm, "СССР", Vector3(0, 0.12, 0.12), 14, Color("c42a22"), Vector3(-40, 0, 0), 0.16)
	# Beyaz eldiven ve bot
	for side: int in [-1, 1]:
		var el := _elbow(p, side)
		if el:
			Props.cyl(el, 0.07, 0.08, Vector3(0, -0.22, 0), Color("f0f0ec"), Vector3.ZERO, 8)
		var kn := _knee(p, side)
		if kn:
			Props.cyl(kn, 0.1, 0.22, Vector3(0, -0.27, 0.0), Color("f0f0ec"), Vector3.ZERO, 10)


# ---------------------------------------------------------------- Shakespeare

static func _shakespeare(p: Person) -> void:
	var b: Node3D = p._body
	var h: Node3D = p._head
	# Kırma yaka (fırfır): üst üste iki dalgalı halka; altın küpe; siyah yelekte altın düğmeler; elinde kaz tüyü
	var lace := Color("f6f4ee")
	Props.cyl(b, 0.22, 0.06, Vector3(0, 1.35, 0), lace, Vector3.ZERO, 18)
	for k in 12:
		var a := TAU * k / 12.0
		Props.ball(b, 0.045, Vector3(sin(a) * 0.2, 1.35, cos(a) * 0.2), lace.darkened(0.04), Vector3(1, 0.9, 1), 6)
	Props.ball(h, 0.016, Vector3(0.2, -0.07, 0.0), GOLD, Vector3.ONE, 6)
	for k in 5:
		Props.ball(b, 0.014, Vector3(0, 1.22 - k * 0.09, 0.225), GOLD, Vector3.ONE, 6)
	var el := _elbow(p, 1)
	if el:
		Props.cyl(el, 0.006, 0.28, Vector3(0.0, -0.22, 0.06), Color("f2f0ea"), Vector3(40, 0, 0), 4)
		Props.box(el, Vector3(0.04, 0.16, 0.008), Vector3(0.0, -0.13, 0.13), Color("f8f6f0"), Vector3(40, 0, 0))


# ---------------------------------------------------------------- Kolomb

static func _columbus(p: Person) -> void:
	var el := _elbow(p, -1)
	# Koltuğunun altında rulo harita (Hindistan sanıyor)
	if el:
		Props.cyl(el, 0.045, 0.45, Vector3(0.0, -0.18, 0.08), Color("e8dcb8"), Vector3(70, 0, 0), 10)
		Props.cyl(el, 0.047, 0.03, Vector3(0.0, -0.18, 0.28), Color("8a2a2a"), Vector3(70, 0, 0), 10)


# ---------------------------------------------------------------- Mozart

static func _mozart(p: Person) -> void:
	var b: Node3D = p._body
	var h: Node3D = p._head
	# Dantel boyunbağı (jabot), altın düğmeler; pudralı peruğun ensesinde siyah kurdele
	Props.box(b, Vector3(0.1, 0.16, 0.05), Vector3(0, 1.22, 0.215), Color("f6f4ee"))
	Props.ball(b, 0.05, Vector3(0, 1.3, 0.2), Color("f6f4ee"), Vector3(1.3, 0.8, 0.8), 8)
	for k in 4:
		Props.ball(b, 0.014, Vector3(0.07, 1.12 - k * 0.09, 0.22), GOLD, Vector3.ONE, 6)
	Props.box(h, Vector3(0.12, 0.05, 0.03), Vector3(0, -0.05, -0.2), Color("141416"))
	Props.cyl(h, 0.035, 0.16, Vector3(0, -0.16, -0.2), Color("f0ece4"), Vector3.ZERO, 8)
	for sx: float in [-1.0, 1.0]:
		Props.ball(h, 0.05, Vector3(sx * 0.19, 0.0, -0.02), Color("f0ece4"), Vector3(0.7, 1.1, 1.3), 8)


# ---------------------------------------------------------------- Curie

static func _curie(p: Person) -> void:
	# Elinde hafifçe ışıyan yeşil şişecik (radyum)
	var el := _elbow(p, 1)
	if el:
		Props.cyl(el, 0.025, 0.09, Vector3(0, -0.25, 0.06), Color("8af0a0"), Vector3.ZERO, 8, -1.0, 1.4)
		Props.cyl(el, 0.012, 0.03, Vector3(0, -0.19, 0.06), Color("6a5030"), Vector3.ZERO, 6)


# ---------------------------------------------------------------- Galileo

static func _galileo(p: Person) -> void:
	# Kucağında küçük pirinç dürbün
	var el := _elbow(p, 1)
	if el:
		Props.cyl(el, 0.03, 0.34, Vector3(0, -0.22, 0.1), Color("8a6a3a"), Vector3(80, 0, 0), 10, 0.024)
		Props.cyl(el, 0.034, 0.03, Vector3(0, -0.22, 0.26), GOLD, Vector3(80, 0, 0), 10)


# ---------------------------------------------------------------- Einstein

static func _einstein(p: Person) -> void:
	var h: Node3D = p._head
	# Dağınık beyaz saç
	for q in [Vector3(-0.19, 0.09, -0.04), Vector3(0.19, 0.09, -0.04), Vector3(-0.12, 0.17, -0.1), Vector3(0.12, 0.17, -0.1), Vector3(0, 0.2, -0.05), Vector3(0, 0.1, -0.19)]:
		Props.ball(h, 0.085, q, Color("f2f0ea"), Vector3(1.0, 0.8, 1.0), 8)


# ---------------------------------------------------------------- v0.99.105: yeni figürler

static func _tesla(p: Person) -> void:
	# Koyu takım, beyaz yaka ve papyon; elinde kablosuz yanan mavi-mor gaz tüpü (meşhur fotoğrafındaki gibi)
	var b: Node3D = p._body
	Props.box(b, Vector3(0.1, 0.05, 0.03), Vector3(0, 1.31, 0.215), Color("1a1a1e"))
	Props.box(b, Vector3(0.16, 0.06, 0.02), Vector3(0, 1.22, 0.225), Color("f0f0ec"))
	var el := _elbow(p, 1)
	if el:
		Props.cyl(el, 0.025, 0.36, Vector3(0, -0.3, 0.08), Color("b8a0ff"), Vector3(70, 0, 0), 10, -1.0, 2.2)
		Props.cyl(el, 0.03, 0.05, Vector3(0, -0.27, 0.0), Color("3a3a40"), Vector3(70, 0, 0), 8)


static func _edison(p: Person) -> void:
	# Gri yelekli takım, papyon; elinde sarı ışıyan akkor ampul
	var b: Node3D = p._body
	Props.box(b, Vector3(0.1, 0.05, 0.03), Vector3(0, 1.31, 0.215), Color("2a2a30"))
	for k in 3:
		Props.ball(b, 0.012, Vector3(0, 1.1 - k * 0.09, 0.23), Color("b8a060"), Vector3.ONE, 5)
	var el := _elbow(p, 1)
	if el:
		Props.ball(el, 0.055, Vector3(0, -0.33, 0.06), Color("ffe08a"), Vector3(1, 1.25, 1), 10, 2.0)
		Props.cyl(el, 0.03, 0.05, Vector3(0, -0.27, 0.06), Color("9a8a6a"), Vector3.ZERO, 8)


static func _socrates(p: Person) -> void:
	# Kaba yünden beyaz himation (bir omuzdan dolanır), yalınayak sandalet, dolaşan filozof asası
	var b: Node3D = p._body
	Props.box(b, Vector3(0.1, 0.72, 0.5), Vector3(0.0, 0.95, 0.0), Color("e8e0cc"), Vector3(0, 90, 32))
	for side: int in [-1, 1]:
		var kn := _knee(p, side)
		if kn:
			for k in 2:
				Props.cyl(kn, 0.086, 0.018, Vector3(0, -0.3 - k * 0.1, 0), Color("7a5a3a"), Vector3.ZERO, 8)
	var el := _elbow(p, -1)
	if el:
		Props.cyl(el, 0.018, 1.5, Vector3(0, -0.28, 0.06), Color("6a4a2a"), Vector3.ZERO, 6)


static func _diogenes(p: Person) -> void:
	# Fıçısında (pithos: yatık değil, dik duran büyük küp) bele kadar; elinde gündüz yanan fener, yamalı kahverengi pelerin
	var jar := Node3D.new()
	jar.name = "Pithos"
	p.add_child(jar)
	var clay := Color("b8683a")
	Props.cyl(jar, 0.42, 0.95, Vector3(0, 0.475, 0), clay, Vector3.ZERO, 16, 0.36)
	Props.cyl(jar, 0.37, 0.07, Vector3(0, 0.97, 0), clay.darkened(0.15), Vector3.ZERO, 16)
	for k in 2:
		Props.cyl(jar, 0.425 - k * 0.02, 0.03, Vector3(0, 0.3 + k * 0.35, 0), clay.darkened(0.25), Vector3.ZERO, 16)
	var b: Node3D = p._body
	Props.box(b, Vector3(0.48, 0.3, 0.06), Vector3(0, 1.15, -0.2), Color("6a4a30"), Vector3(-8, 0, 0))
	Props.box(b, Vector3(0.1, 0.1, 0.02), Vector3(-0.1, 1.05, 0.225), Color("8a6a40"))
	var el := _elbow(p, 1)
	if el:
		Props.cyl(el, 0.008, 0.12, Vector3(0, -0.3, 0.06), Color("3a3a3a"), Vector3.ZERO, 4)
		Props.cyl(el, 0.05, 0.12, Vector3(0, -0.42, 0.06), Color("ffd27a"), Vector3.ZERO, 8, 0.04, 1.6)
		Props.cyl(el, 0.055, 0.02, Vector3(0, -0.35, 0.06), Color("4a3a2a"), Vector3.ZERO, 8)


static func _newton(p: Person) -> void:
	# Uzun gri kıvırcık saç (omuzlara iner), boyunbağı (jabot); elinde kırmızı elma
	var h: Node3D = p._head
	var grey := Color("cfc8bc")
	for sx: float in [-1.0, 1.0]:
		for k in 3:
			Props.ball(h, 0.085, Vector3(sx * 0.19, -0.05 - k * 0.1, -0.03), grey, Vector3(0.8, 1.0, 1.0), 8)
	Props.ball(h, 0.21, Vector3(0, 0.07, -0.03), grey, Vector3(1.05, 0.9, 1.05), 10)
	var b: Node3D = p._body
	Props.box(b, Vector3(0.1, 0.16, 0.03), Vector3(0, 1.2, 0.225), Color("f4f0e6"))
	var el := _elbow(p, 1)
	if el:
		Props.ball(el, 0.045, Vector3(0, -0.31, 0.07), Color("c42a22"), Vector3(1, 0.95, 1), 8)
		Props.cyl(el, 0.005, 0.03, Vector3(0, -0.26, 0.07), Color("4a3020"), Vector3.ZERO, 4)


static func _evliya(p: Person) -> void:
	# Seyyah: kalın kuşak, omzunda heybe, elinde Seyahatname (deri ciltli kalın defter)
	var b: Node3D = p._body
	Props.cyl(b, 0.245, 0.07, Vector3(0, 0.84, 0), Color("b8322a"), Vector3.ZERO, 16)
	Props.box(b, Vector3(0.05, 0.62, 0.05), Vector3(0.05, 1.05, 0.0), Color("6a4a2a"), Vector3(0, 0, -34))
	Props.box(b, Vector3(0.26, 0.24, 0.12), Vector3(0.24, 0.78, -0.16), Color("8a5a3a"))
	var el := _elbow(p, -1)
	if el:
		Props.box(el, Vector3(0.05, 0.22, 0.17), Vector3(0, -0.27, 0.08), Color("5a2a1a"))
		Props.box(el, Vector3(0.052, 0.2, 0.155), Vector3(0.002, -0.27, 0.08), Color("efe6cc"))
