class_name IstOrdugahYerleske
extends RefCounted
## Eksik yerleşkeler (ORDUGÂH-4, docs/ORDUGAH_1453.md §2.2, §4.5–4.6, §7e-6/7): paşa çadırları (kırmızı/bordo, tuğlu),
## dökümhane ve demirciler, barut çukurları (çadırdan uzak, kapaklı), esir çadırı, tercüman/kâtip çadırı, koyun–manda
## ağılı, kuşatma kulesinin hazırlığı (tarihten önce kereste), lağım ağzı (tarih kapılı); mescit, pazar ve at bağına kişiler.
## Yerel çerçeve: zemin y = 0 (K.gy ile arazi), ön = +z (sura).

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const B = K.Bld
const Y = preload("res://scripts/world/ist/ordugah_yapi.gd")
const KS = preload("res://scripts/world/ist/ordugah_kisi.gd")
const OB = preload("res://scripts/world/ist/ordugah_oba.gd")


static func _zemin(kisi: Array) -> Array:
	for kk: Array in kisi:
		var p: Vector3 = kk[0]
		p.y = K.gy(p.x, p.z)
		kk[0] = p
	return kisi


## Paşa çadırı: çok direkli bordo/kırmızı çatma (12 × 8), önünde sayebân, tuğ (1–3) ve paşa sancağı, nöbetçiler, kâtip
static func build_pasa(host: Node3D, k: float, lod: int, tohum := 1, tug := 2) -> void:
	var r := K.rr(tohum)
	var c := B.new("plaster")
	var w := B.new("wood")
	var f := B.new()
	c.no_climb = true
	var y0 := K.gy(0, 0)
	c.box(Vector3(0, y0 + 1.4, 0), Vector3(12.0, 2.8, 8.0), K.KIRMIZI2)
	c.prism(B.xf(Vector3(0, y0 + 2.8, 0)), Vector3(12.6, 2.4, 8.6), K.KIRMIZI2.lightened(0.04))
	c.box(Vector3(0, y0 + 2.82, 0), Vector3(12.7, 0.12, 0.25), K.ALTIN)
	for sx in [-4.0, 0.0, 4.0]:
		c.cylp(Vector3(sx, y0 + 5.6, 0), 0.08, 0.8, K.ALTIN, 5)
		c.sph(Vector3(sx, y0 + 6.05, 0), 0.14, K.ALTIN, 4)
	c.box(Vector3(0, y0 + 1.2, 4.03), Vector3(2.2, 2.4, 0.08), K.KOYU)
	c.solid_box(Vector3(0, y0 + 2.4, 0), Vector3(12.2, 4.8, 8.2))
	# sayebân
	for sx2 in [-3.0, 3.0]:
		w.cylp(Vector3(sx2, y0 + 1.6, 8.0), 0.07, 3.2, K.AHSAP2, 5)
	c.box(Vector3(0, y0 + 3.15, 6.0), Vector3(6.4, 0.08, 4.4), Color("e8dcc0"), 0.0, Vector3(-6, 0, 0))
	c.box(Vector3(0, y0 + 3.0, 8.15), Vector3(6.4, 0.35, 0.04), K.KIRMIZI2)
	c.box(Vector3(0, y0 + 0.05, 6.0), Vector3(4.0, 0.04, 3.0), K.LACI)
	for i in tug:
		OB._sancak(w, f, Vector3(-5.5 + i * 1.3, y0, 9.5), 6.0, K.KIRMIZI, lod, true)
	OB._sancak(w, f, Vector3(5.5, y0, 9.5), 7.0, OB._sec(r, OB.SANCAK), lod, false)
	c.done(host, "bez")
	w.done(host, "ahsap")
	f.done(host, "flama")
	var kisi := [[Vector3(-1.6, 0, 9.0), 0.0, "nobet"], [Vector3(1.6, 0, 9.0), 0.0, "nobet"], [Vector3(-1.0, 0, 6.0), 0.0, "katip"],
		[Vector3(1.4, 0, 6.4), PI, "sipahi"], [Vector3(2.4, 0, 5.6), -PI * 0.7, "sipahi"], [Vector3(-7.5, 0, 2.0), PI / 2.0, "nobet"]]
	KS.kur(host, _zemin(kisi), lod)


## Dökümhane / demirci / ok yapıcı: açık sundurmalar, ocak, körük, örs; top kalıbı ve kömür yığını; işçiler (çekiç, balta)
static func build_dokumhane(host: Node3D, k: float, lod: int, tohum := 1) -> void:
	var r := K.rr(tohum)
	var w := B.new("wood")
	var t := B.new("rubble")
	var m := B.new("")
	var kisi: Array = []
	var fires: Array = []
	for i in 3:
		var p := Vector3(-9.0 + i * 9.0, K.gy(-9.0 + i * 9.0, 0), 0)
		for sx in [-2.8, 2.8]:
			for sz in [-2.0, 2.0]:
				w.cylp(p + Vector3(sx, 1.4, sz), 0.1, 2.8, K.AHSAP2, 5)
		w.box(p + Vector3(0, 2.95, 0), Vector3(6.4, 0.12, 4.8), Color("4a3e30"), 0.0, Vector3(8, 0, 0))     # is kaplı kıl örtü
		t.box(p + Vector3(-1.2, 0.5, -0.8), Vector3(1.6, 1.0, 1.4), K.TAS.darkened(0.2))                      # ocak
		t.box(p + Vector3(-1.2, 1.02, -0.8), Vector3(0.9, 0.06, 0.8), Color("2a1a10"))
		w.box(p + Vector3(-2.4, 0.6, -0.8), Vector3(0.7, 0.5, 1.0), K.DERI.darkened(0.2))                      # körük
		m.box(p + Vector3(0.8, 0.55, 0.4), Vector3(0.5, 0.3, 0.3), K.DEMIR)                                   # örs
		w.cylp(p + Vector3(0.8, 0.2, 0.4), 0.25, 0.4, K.AHSAP2, 6)
		t.solid_box(p + Vector3(-1.2, 0.5, -0.8), Vector3(1.6, 1.0, 1.4))
		fires.append(Vector2(p.x - 1.2, p.z - 0.8))
		kisi.append([p + Vector3(0.8, 0, 1.2), PI, "bileyen"])
		kisi.append([p + Vector3(-2.6, 0, 0.6), PI * 0.8, "manivela"])
	# top kalıbı (toprak höyük + tahta çember) ve kömür, odun
	t.sph(Vector3(0, K.gy(0, -9.0), -9.0), 2.4, K.TOPRAK2, 8, Vector3(1.6, 0.6, 1.0))
	for i in 5:
		w.cylp(Vector3(-2.4 + i * 1.2, K.gy(0, -9.0) + 0.6, -9.0), 1.25, 0.12, K.AHSAP, 10, -1.0, Vector3(0, 0, 90))
	t.sph(Vector3(10.0, K.gy(10.0, -8.0), -8.0), 1.8, Color("1e1c1a"), 7, Vector3(1.3, 0.5, 1.0))
	for i in 8:
		w.cylp(Vector3(-11.0 + (i % 4) * 0.3, K.gy(-11.0, -8.0) + 0.15 + (i / 4) * 0.28, -8.0), 0.12, 2.2, K.AHSAP_A, 5, -1.0, Vector3(90, 0, 0))
	m.done(host, "demir")
	t.done(host, "ocak")
	w.done(host, "ahsap")
	kisi.append([Vector3(-4.0, 0, -7.2), 0.0, "kazma"])
	kisi.append([Vector3(-11.0, 0, -6.0), PI, "balta"])
	KS.kur(host, _zemin(kisi), lod)
	K.ateslar(host, fires, lod, 1.05, true, 0.35, 0.45)


## Barut çukurları: kazılmış çukur (koyu), içinde kapaklı fıçılar, üstünde ıslak deri örtü; çevresinde nöbet, uzakta su fıçısı
static func build_barutcu(host: Node3D, k: float, lod: int, tohum := 1) -> void:
	var w := B.new("wood")
	var e := B.new("rubble")
	for i in 2:
		var p := Vector3(-4.0 + i * 8.0, 0, 0)
		var y := K.gy(p.x, p.z)
		e.box(Vector3(p.x, y + 0.03, p.z), Vector3(6.0, 0.06, 4.4), Color("3a3024"))
		Y.yamuk(e, p.x, p.z + 2.6, y, 0.7, 7.4, 1.6, 6.8, 0.8, K.TOPRAK2, true, 0.0)
		for q in 6:
			var fx := p.x - 2.0 + (q % 3) * 1.6
			var fz := p.z - 0.8 + (q / 3) * 1.4
			w.cylp(Vector3(fx, y + 0.42, fz), 0.42, 0.84, K.AHSAP, 8)
			w.cylp(Vector3(fx, y + 0.22, fz), 0.435, 0.06, K.DEMIR, 8)
			w.cylp(Vector3(fx, y + 0.64, fz), 0.435, 0.06, K.DEMIR, 8)
		e.box(Vector3(p.x, y + 0.95, p.z), Vector3(5.8, 0.06, 3.6), K.DERI.darkened(0.25), 0.0, Vector3(3, 0, -2))
	e.done(host, "toprak")
	w.done(host, "fici")
	var kisi := [[Vector3(-8.5, 0, 3.0), 0.0, "nobet"], [Vector3(8.5, 0, -3.0), PI, "nobet"], [Vector3(0.0, 0, 4.2), 0.0, "saka"]]
	KS.kur(host, _zemin(kisi), lod)


## Esir çadırı: kazıklı çit içinde bir çadır, oturan esirler, kapıda nöbetçi
static func build_esir(host: Node3D, k: float, lod: int, tohum := 1) -> void:
	var r := K.rr(tohum)
	var w := B.new("wood")
	var y0 := K.gy(0, 0)
	var n := 28
	for i in n:
		var a := TAU * i / n
		if absf(wrapf(a - PI / 2.0, -PI, PI)) < 0.15:
			continue
		var p := Vector3(cos(a) * 8.0, 0, sin(a) * 6.0)
		w.cylp(Vector3(p.x, K.gy(p.x, p.z) + 1.0, p.z), 0.08, 2.0, K.AHSAP2, 5)
		w.solid_cyl(Vector3(p.x, K.gy(p.x, p.z) + 1.0, p.z), 0.4, 2.0)
	for sd in [-1.0, 1.0]:
		w.box(Vector3(0, y0 + 0.9, sd * 6.0), Vector3(16.0, 0.08, 0.08), K.AHSAP)
	w.done(host, "cit")
	var tr: Array = [Transform3D(Basis().scaled(Vector3(2.4, 1.2, 2.4)), Vector3(0, y0 - 0.1, -2.5))]
	K.mm(host, K.tent_mesh("yuvarlak" if lod == 0 else "sade"), tr, [Color("8f8064")], "esir_cadir", "plaster", lod == 0)
	var kisi: Array = []
	for i in 9:
		var p2 := Vector3(-5.0 + (i % 5) * 2.4, 0, 1.0 + (i / 5) * 2.0)
		kisi.append([p2, r.randf_range(-1.0, 1.0), "esir"])
	kisi.append([Vector3(-1.4, 0, 6.9), 0.0, "nobet"])
	kisi.append([Vector3(1.4, 0, 6.9), 0.0, "nobet"])
	KS.kur(host, _zemin(kisi), lod)


## Tercüman/kâtip çadırı: krem çatma, önünde alçak sehpa, yazan kâtipler
static func build_tercuman(host: Node3D, k: float, lod: int, tohum := 1) -> void:
	var c := B.new("plaster")
	var w := B.new("wood")
	var y0 := K.gy(0, 0)
	c.box(Vector3(0, y0 + 1.1, -1.0), Vector3(7.0, 2.2, 4.6), Color("e4d8b8"))
	c.prism(B.xf(Vector3(0, y0 + 2.2, -1.0)), Vector3(7.4, 1.7, 5.0), Color("d9ccaa"))
	c.solid_box(Vector3(0, y0 + 1.7, -1.0), Vector3(7.2, 3.4, 4.8))
	c.box(Vector3(0, y0 + 0.03, 2.6), Vector3(4.0, 0.04, 2.4), K.KIRMIZI2.darkened(0.2))
	w.box(Vector3(0, y0 + 0.3, 2.6), Vector3(1.6, 0.08, 0.7), K.AHSAP)
	c.done(host, "bez")
	w.done(host, "ahsap")
	var kisi := [[Vector3(-0.9, 0, 3.4), PI, "katip"], [Vector3(0.9, 0, 3.4), PI, "katip"], [Vector3(0, 0, 1.6), 0.0, "esir"], [Vector3(2.6, 0, 3.2), PI * 0.8, "nobet"]]
	KS.kur(host, _zemin(kisi), lod)


## Ağıl: çit (çatma dal), içinde koyun sürüsü, manda/öküz, çoban ve köpek
static func build_agil(host: Node3D, k: float, lod: int, tohum := 1) -> void:
	var r := K.rr(tohum)
	var w := B.new("wood")
	var an := B.new("")
	var hay := PackedVector3Array()
	var W := 26.0
	var D := 18.0
	var kose := [Vector2(-W / 2, -D / 2), Vector2(W / 2, -D / 2), Vector2(W / 2, D / 2), Vector2(-W / 2, D / 2)]
	for i in 4:
		var a: Vector2 = kose[i]
		var b: Vector2 = kose[(i + 1) % 4]
		var L := a.distance_to(b)
		for q in int(L / 2.0) + 1:
			if i == 2 and absf(q - int(L / 4.0)) < 1:
				continue          # kapı
			var p := a.lerp(b, q / (L / 2.0))
			var y := K.gy(p.x, p.y)
			w.cylp(Vector3(p.x, y + 0.6, p.y), 0.06, 1.2, K.AHSAP2, 5)
		var m := (a + b) * 0.5
		var yaw := -rad_to_deg(atan2(b.y - a.y, b.x - a.x))
		w.box(Vector3(m.x, K.gy(m.x, m.y) + 0.85, m.y), Vector3(L, 0.08, 0.06), K.AHSAP, yaw)
		w.box(Vector3(m.x, K.gy(m.x, m.y) + 0.45, m.y), Vector3(L, 0.08, 0.06), K.AHSAP, yaw)
		w.solid_box(Vector3(m.x, K.gy(m.x, m.y) + 0.6, m.y), Vector3(L, 1.2, 0.2), yaw)
	for i in 34:
		var q := Vector2(r.randf_range(-W / 2 + 1.5, W / 2 - 1.5), r.randf_range(-D / 2 + 1.5, 0.0))
		var y2 := K.gy(q.x, q.y)
		var col := Color("e4dccb").lerp(Color("7a6a56"), r.randf() * r.randf())
		var yw := r.randf() * 360.0
		# CANLI (kalite notu 32): koyun canli_kit'ten (yün hacimli, eklemli duruş); RNG tüketimi aynı
		const CK = preload("res://scripts/world/ist/canli_kit.gd")
		var hs := absi(int(q.x * 17.0 + q.y * 7.0))
		CK.bld_ekle(an, "koyun", Vector3(q.x, y2, q.y), yw, {"renk": col, "poz": ["otla", "dur", "otla", "yat", "otla"][hs % 5], "bas_yaw": float(hs % 5 - 2) * 15.0, "tohum": hs})
		hay.append(Vector3(q.x, y2, q.y))
	for i in 6:
		var q2 := Vector3(-8.0 + i * 3.2, 0, 4.5 + (i % 2) * 1.5)
		q2.y = K.gy(q2.x, q2.z)
		Y._okuz(an, q2, r.randf_range(-30, 30) + (180.0 if i % 2 == 0 else 0.0), r)
		hay.append(q2)
	var kp := Vector3(W / 2 + 2.0, 0, 3.0)
	kp.y = K.gy(kp.x, kp.z)
	OB._kopek(an, kp, 200.0, r)
	hay.append(kp)
	w.done(host, "cit")
	an.done(host, "hayvan")
	host.set_meta("hayvanlar", hay)
	var kisi := [[Vector3(W / 2 + 1.0, 0, 5.0), -PI / 2.0, "seyis"], [Vector3(0, 0, D / 2 + 1.5), PI, "saka"], [Vector3(-W / 2 - 1.0, 0, -2.0), PI / 2.0, "seyis"]]
	KS.kur(host, _zemin(kisi), lod)


## Kule hazırlığı (18 Mayıs'tan önce): kereste istifi, yarım iskelet (ilk kat), deri balyaları, marangozlar
static func build_kule_hazirlik(host: Node3D, k: float, lod: int, tohum := 9) -> void:
	var r := K.rr(tohum)
	var w := B.new("wood")
	var y0 := K.gy(0, 0)
	var S := 4.6
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			w.box(Vector3(sx * S / 2, y0 + 2.4, sz * S / 2), Vector3(0.3, 4.8, 0.3), K.AHSAP2)
	for sd in [-1, 1]:
		w.box(Vector3(0, y0 + 4.7, sd * S / 2), Vector3(S + 0.3, 0.28, 0.2), K.AHSAP)
		w.box(Vector3(sd * S / 2, y0 + 4.7, 0), Vector3(0.2, 0.28, S + 0.3), K.AHSAP)
	w.box(Vector3(0, y0 + 0.4, 0), Vector3(S + 1.0, 0.5, S + 1.0), K.AHSAP2)
	w.solid_box(Vector3(0, y0 + 0.4, 0), Vector3(S + 1.0, 0.5, S + 1.0))
	for i in 10:
		w.box(Vector3(6.5, y0 + 0.15 + (i / 3) * 0.3, -1.4 + (i % 3) * 1.4), Vector3(7.0, 0.28, 0.3), K.AHSAP_A.darkened(0.05 * (i % 3)))
	w.solid_box(Vector3(6.5, y0 + 0.55, 0), Vector3(7.2, 1.1, 4.4))
	for i in 4:
		w.box(Vector3(-6.0, y0 + 0.3 + i * 0.25, -1.0 + (i % 2) * 0.4), Vector3(1.6, 0.25, 1.2), K.DERI.darkened(0.1 * (i % 2)))
	w.done(host, "kereste")
	var kisi := [[Vector3(4.0, 0, 2.6), 0.0, "balta"], [Vector3(1.8, 0, -3.4), PI, "bileyen"], [Vector3(-3.4, 0, 2.0), 0.3, "kazma"], [Vector3(8.4, 0, 2.4), PI, "saka"]]
	KS.kur(host, _zemin(kisi), lod)


## Lağım ağzı (16–25 Mayıs): toprak yığını, tomruk destekli giriş, kazı toprağı, sepetli taşıyıcılar
static func build_lagim(host: Node3D, k: float, lod: int, tohum := 5) -> void:
	var w := B.new("wood")
	var e := B.new("rubble")
	var y0 := K.gy(0, 0)
	Y.yamuk(e, 0, -1.0, y0, 1.6, 7.0, 6.0, 4.0, 3.0, K.TOPRAK2, true, 0.0)
	e.box(Vector3(0, y0 + 0.75, 2.05), Vector3(1.6, 1.5, 0.1), K.KOYU)
	for sx in [-0.9, 0.9]:
		w.box(Vector3(sx, y0 + 0.8, 2.15), Vector3(0.22, 1.6, 0.22), K.AHSAP2)
	w.box(Vector3(0, y0 + 1.65, 2.15), Vector3(2.2, 0.22, 0.24), K.AHSAP2)
	e.sph(Vector3(-4.5, y0, 3.5), 1.8, K.TOPRAK, 6, Vector3(1.2, 0.55, 1.0))
	e.done(host, "toprak")
	w.done(host, "destek")
	var kisi := [[Vector3(-1.2, 0, 3.0), PI, "kazma"], [Vector3(1.4, 0, 3.6), PI, "kazma"], [Vector3(-3.4, 0, 4.4), 2.4, "saka"], [Vector3(2.8, 0, 5.0), 0.0, "nobet"]]
	KS.kur(host, _zemin(kisi), lod)


# ---------------------------------------------------------------- var olan yapılara kişi

## Mescit: kıble yerel +z; halı üstünde saf (oturuş) ve abdest teknesinde
static func mescit_kisi(host: Node3D, lod: int) -> void:
	var kisi: Array = []
	for row in 2:
		for i in 7:
			kisi.append([Vector3(-5.4 + i * 1.8, 0.12, 1.2 - row * 1.5), 0.0, "namaz"])
	kisi.append([Vector3(-9.2, 0, -1.0), PI / 2.0, "saka"])
	kisi.append([Vector3(-9.2, 0, -2.4), PI / 2.0, "uyuyan"])
	for kk: Array in kisi:
		var p: Vector3 = kk[0]
		p.y = K.gy(p.x, p.z) + (0.12 if absf(p.x) < 7.0 and absf(p.z) < 4.2 else 0.0)
		kk[0] = p
	KS.kur(host, kisi, lod)


## Pazar: tezgâh başında tüccar, aralarda gezen asker
static func pazar_kisi(host: Node3D, k: float, lod: int, tohum := 21) -> void:
	var r := K.rr(tohum + 5)
	var cols := int(clampf(4 + k * 4, 4, 8))
	var kisi: Array = []
	for ri in 2:
		for ci in cols:
			var p := Vector3((ci - (cols - 1) * 0.5) * 7.0, 0, (ri - 0.5) * 11.0)
			var arka := -1.2 if ri == 0 else 1.2
			kisi.append([p + Vector3(r.randf_range(-0.8, 0.8), 0, arka), 0.0 if ri == 0 else PI, "tuccar"])
			if r.randf() < 0.8:
				kisi.append([p + Vector3(r.randf_range(-1.2, 1.2), 0, -arka * 1.6), PI if ri == 0 else 0.0, "alici"])
	for i in 6:
		kisi.append([Vector3(r.randf_range(-cols * 3.0, cols * 3.0), 0, r.randf_range(-1.5, 1.5)), r.randf() * TAU, "alici" if i % 2 == 0 else "sipahi"])
	KS.kur(host, _zemin(kisi), lod)


## At bağı: seyisler (tımar), su taşıyan
static func ahir_kisi(host: Node3D, lod: int) -> void:
	var kisi := [[Vector3(-7.5, 0, 2.6), PI, "seyis"], [Vector3(4.5, 0, 2.6), PI, "seyis"], [Vector3(-6.0, 0, -4.6), 0.0, "saka"]]
	var hay := PackedVector3Array()
	for i in 10:
		var x2 := (i - 5.0 + 0.5) * 3.0
		hay.append(Vector3(x2, K.gy(x2, 1.6), 1.6))
	host.set_meta("hayvanlar", hay)
	KS.kur(host, _zemin(kisi), lod)
