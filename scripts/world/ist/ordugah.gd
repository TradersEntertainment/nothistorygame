class_name IstOrdugah
extends RefCounted
## İstanbul v2, Nisan 1453: Osmanlı kuşatma düzeni (sur dışı). Giriş noktaları:
##   IstOrdugah.attach(dunya, gece)       v2 dünyasına gerçek yerinde kurar (akışlı lod 2→1→0)
##   IstOrdugah.catalog()                 gerçek koordinatlı kayıt
##   build_x(host, k, lod) / perches_x(k) / climbs_x(k)    tekil yapılar (x: otag, batarya, sahi_top, mancinik, kule,
##                                         mescit, pazar, mutfak, ahir, siper, diplokionion, kizak, fici_kopru)
##   build_kanat(host, alan_cokgen, tur, k, lod, tohum)    alan doldurucu (çadır kanatları)
## YEREL ÇERÇEVE: zemin y = 0; +x doğu, −z kuzey (yon_derece = 0). Tabya, top, otağ kapısı ve siper önü yerel +z'ye bakar
## (v2'de +z, kara surlarının yönünü gösterir). Çadır, top, kule, mancınık, kazan gibi gereçler GERÇEK boyda kalır (k
## yalnız alan ve kütle ölçülerini etkiler).
##
## Konum esası (docs/ISTANBUL_1453.md [WP-Fall]): Sultan'ın otağı Mesoteikhion/Aziz Romanos Kapısı karşısında; Karaca Paşa
## (Rumeli) kuzey yarısı, İshak Paşa (Anadolu) güney yarısı; Zağanos Paşa Haliç ötesi; Şahi topu Topkapı karşısında.
## Bütün konumlar IstGeo.yol("kara_suru") hattından (ark uzunluğu u, dış yön d) türetilir: kestirimdir.

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const Y = preload("res://scripts/world/ist/ordugah_yapi.gd")
const Y2 = preload("res://scripts/world/ist/ordugah_yapi2.gd")
const DN = preload("res://scripts/world/ist/ordugah_donanma.gd")
const KN = preload("res://scripts/world/ist/ordugah_kanat.gd")
const S := 0.5

static var _plan: Array = []
static var _arcs := PackedFloat32Array()
static var _wall := PackedVector2Array()
static var _len := 0.0


# ------------------------------------------------------------------ sur hattı yardımcıları (dünya x,z)

static func _wall_init() -> void:
	if not _wall.is_empty():
		return
	_wall = IstGeo.yol("kara_suru")
	var acc := 0.0
	_arcs.append(0.0)
	for i in _wall.size() - 1:
		acc += _wall[i].distance_to(_wall[i + 1])
		_arcs.append(acc)
	_len = acc


## u: plan ark uzunluğu (S = 0,5 için yazıldı: kara suru ~3 130 m). Dünya ölçeği IstGeo.S ile oranlanır (ŞEHİR-3:
## S = 0,35'te 2 190 m'lik hattın sonundaki ~900 m'lik plan kuzey ucunda tek noktaya yığılıyordu)
static func wpt(u: float) -> Vector2:
	_wall_init()
	u = clampf(u * IstGeo.S / 0.5, 0.0, _len)
	for i in _wall.size() - 1:
		if u <= _arcs[i + 1]:
			return _wall[i].lerp(_wall[i + 1], (u - _arcs[i]) / maxf(0.001, _arcs[i + 1] - _arcs[i]))
	return _wall[_wall.size() - 1]


## Dış yön (şehirden uzağa, batı)
static func wn(u: float) -> Vector2:
	var a := wpt(u - 30.0)
	var b := wpt(u + 30.0)
	var t := (b - a).normalized()
	var n := Vector2(-t.y, t.x)
	if n.x > 0.0:
		n = -n
	return n


static func at(u: float, d: float) -> Vector2:
	return wpt(u) + wn(u) * d


## Yerel +z'yi surun yönüne çeviren dönüş (Node3D.rotation.y)
static func yaw_sura(u: float) -> float:
	var n := wn(u)
	return atan2(-n.x, -n.y)


static func band(u0: float, u1: float, d0: float, d1: float) -> PackedVector2Array:
	var p := PackedVector2Array()
	var um := (u0 + u1) * 0.5
	p.append(at(u0, d0)); p.append(at(um, d0)); p.append(at(u1, d0))
	p.append(at(u1, d1)); p.append(at(um, d1)); p.append(at(u0, d1))
	return p


static func _poly_center(p: PackedVector2Array) -> Vector2:
	return K.centroid(p)


static func _item(kind: String, id: String, ad: String, pos: Vector2, yaw: float, r: float, olcu: Vector3, tur := "ordugah", durum := "ordugah", args := {}) -> Dictionary:
	return {"kind": kind, "id": id, "ad": ad, "pos": pos, "yaw": yaw, "r": r, "olcu": olcu, "tur": tur, "durum": durum,
		"args": args, "tohum": hash(id) & 0xffff}


static func _cells(out: Array, u0: float, u1: float, d0: float, d1: float, du: float, dd: float, tur: String, pre: String, ad: String) -> void:
	var nu := maxi(int(round((u1 - u0) / du)), 1)
	var nd := maxi(int(round((d1 - d0) / dd)), 1)
	for iu in nu:
		for idd in nd:
			var a0 := u0 + (u1 - u0) * iu / nu
			var a1 := u0 + (u1 - u0) * (iu + 1) / nu
			var b0 := d0 + (d1 - d0) * idd / nd
			var b1 := d0 + (d1 - d0) * (idd + 1) / nd
			var pl := band(a0, a1, b0, b1)
			var c := _poly_center(pl)
			var rad := 0.0
			for p in pl:
				rad = maxf(rad, p.distance_to(c))
			var id := "%s_%d_%d" % [pre, iu, idd]
			var it := _item("kanat", id, ad, c, 0.0, rad, Vector3(a1 - a0, 4.0, b1 - b0) * 2.0, "ordugah", "ordugah", {"alan": pl, "tur": tur, "kanat": pre})
			out.append(it)


static func plan() -> Array:
	if not _plan.is_empty():
		return _plan
	_wall_init()
	var o: Array = []
	# --- Sultan'ın otağı (Maltepe): Mesoteikhion karşısı, surdan ~330 m (dünya)
	var uo := 1500.0
	o.append(_item("otag", "otag", "II. Mehmed'in otağı", at(uo, 330.0), yaw_sura(uo), 60.0, Vector3(110, 12, 110), "ordugah", "ordugah"))
	# --- Şahi topu (Urban) bataryası: Aziz Romanos (Topkapı) karşısı
	o.append(_item("sahi_top", "sahi_top", "Şahi topu bataryası (Urban)", at(1500.0, 136.0), yaw_sura(1500.0), 24.0, Vector3(46, 7, 34), "ordugah", "ordugah"))
	# --- 13 batarya daha (toplam 14)
	var bu := [260.0, 520.0, 790.0, 1020.0, 1200.0, 1340.0, 1420.0, 1610.0, 1700.0, 1830.0, 2010.0, 2220.0, 2400.0]
	var bn := [2, 3, 2, 3, 4, 2, 3, 3, 2, 3, 2, 3, 2]
	for i in bu.size():
		var u: float = bu[i]
		o.append(_item("batarya", "batarya_%02d" % (i + 1), "Batarya %d" % (i + 1), at(u, 128.0), yaw_sura(u), 26.0,
			Vector3(float(bn[i]) * 8.5 + 8.0, 4, 18), "ordugah", "ordugah", {"n": bn[i]}))
	# --- Mancınık ve kuşatma kuleleri
	for u in [1180.0, 1460.0, 1700.0, 1930.0]:
		o.append(_item("mancinik", "mancinik_%d" % int(u), "Mancınık", at(u, 150.0), yaw_sura(u), 12.0, Vector3(9, 12, 16)))
	for u in [1300.0, 1585.0, 2300.0]:
		o.append(_item("kule", "kule_%d" % int(u), "Kuşatma kulesi (hazırlık)", at(u, 160.0), yaw_sura(u), 10.0, Vector3(5, 14, 5)))
	# --- Servis alanları (otağ çevresi)
	o.append(_item("mescit", "mescit", "Mescit çadırı", at(1380.0, 285.0), yaw_sura(1380.0), 13.0, Vector3(15, 6, 10)))
	o.append(_item("pazar", "pazar", "Ordugâh pazarı", at(1300.0, 235.0), yaw_sura(1300.0), 22.0, Vector3(40, 3, 24)))
	o.append(_item("mutfak", "mutfak_otag", "Yeniçeri kazanları", at(1640.0, 255.0), yaw_sura(1640.0), 16.0, Vector3(34, 3, 12)))
	o.append(_item("mutfak", "mutfak_anadolu", "Anadolu kazanları", at(640.0, 230.0), yaw_sura(640.0), 16.0, Vector3(34, 3, 12)))
	o.append(_item("mutfak", "mutfak_rumeli", "Rumeli kazanları", at(2150.0, 220.0), yaw_sura(2150.0), 16.0, Vector3(34, 3, 12)))
	o.append(_item("ahir", "ahir_otag", "At ve deve bağı", at(1740.0, 330.0), yaw_sura(1740.0), 18.0, Vector3(34, 3, 8)))
	o.append(_item("ahir", "ahir_anadolu", "At ve deve bağı (Anadolu)", at(880.0, 300.0), yaw_sura(880.0), 18.0, Vector3(34, 3, 8)))
	o.append(_item("ahir", "ahir_rumeli", "At ve deve bağı (Rumeli)", at(2500.0, 280.0), yaw_sura(2500.0), 18.0, Vector3(34, 3, 8)))
	o.append(_item("pazar", "pazar_rumeli", "Rumeli pazarı", at(2000.0, 300.0), yaw_sura(2000.0), 22.0, Vector3(40, 3, 24)))
	o.append(_item("mescit", "mescit_anadolu", "Anadolu mescidi", at(520.0, 280.0), yaw_sura(520.0), 13.0, Vector3(15, 6, 10)))
	o.append(_item("mescit", "mescit_rumeli", "Rumeli mescidi", at(2200.0, 270.0), yaw_sura(2200.0), 13.0, Vector3(15, 6, 10)))
	# --- Siper hattı: u 80–2500, d = 112, 100 m'lik dilimler
	var su_ := 80.0
	while su_ < 2500.0:
		var ue := minf(su_ + 100.0, 2500.0)
		var pts := PackedVector2Array()
		var um := (su_ + ue) * 0.5
		var c := at(um, 112.0)
		# yön: d = (−n.y, n.x) (önü sura bakar); yönle aynı sırada u artarsa ileri, değilse geri
		var nn := wn(um)
		var dd := Vector2(-nn.y, nn.x)
		var tt := (wpt(um + 10.0) - wpt(um - 10.0)).normalized()
		var fwd := dd.dot(tt) > 0.0
		var steps := 8
		for i in steps + 1:
			var uu := lerpf(su_, ue, float(i) / steps) if fwd else lerpf(ue, su_, float(i) / steps)
			pts.append(at(uu, 112.0))
		o.append(_item("siper", "siper_%d" % int(su_), "Siper hattı", c, 0.0, 62.0, Vector3(100, 2, 12), "ordugah", "ordugah", {"line": pts}))
		su_ = ue
	# --- Çadır kanatları
	_cells(o, 120.0, 1250.0, 175.0, 455.0, 113.0, 140.0, "anadolu", "anadolu", "Anadolu askeri (İshak Paşa)")
	_cells(o, 1250.0, 1720.0, 380.0, 520.0, 118.0, 140.0, "yeniceri", "yeniceri_arka", "Yeniçeri ve sipahi çadırları")
	_cells(o, 1250.0, 1720.0, 170.0, 380.0, 118.0, 105.0, "yeniceri", "yeniceri", "Yeniçeri çadırları")
	_cells(o, 1720.0, 2900.0, 175.0, 455.0, 118.0, 140.0, "rumeli", "rumeli", "Rumeli askeri (Karaca Paşa)")
	_cells(o, 200.0, 2800.0, 455.0, 600.0, 130.0, 145.0, "basibozuk", "basibozuk", "Başıbozuk ve cephe gerisi")
	# Zağanos Paşa: Haliç ötesi, Galata'nın arkası (enlem/boylam kutusu)
	var z0 := IstGeo.ll(41.0330, 28.9640)
	var z1 := IstGeo.ll(41.0420, 28.9940)
	for iz in 3:
		for jz in 3:
			var x0 := lerpf(z0.x, z1.x, iz / 3.0)
			var x1 := lerpf(z0.x, z1.x, (iz + 1) / 3.0)
			var zz0 := lerpf(z0.z, z1.z, jz / 3.0)
			var zz1 := lerpf(z0.z, z1.z, (jz + 1) / 3.0)
			var pl := PackedVector2Array([Vector2(x0, zz0), Vector2(x1, zz0), Vector2(x1, zz1), Vector2(x0, zz1)])
			var cc := _poly_center(pl)
			var rr_ := cc.distance_to(pl[0])
			o.append(_item("kanat", "zaganos_%d_%d" % [iz, jz], "Zağanos Paşa kolu", cc, 0.0, rr_, Vector3(300, 4, 300), "ordugah", "ordugah",
				{"alan": pl, "tur": "zaganos", "kanat": "zaganos"}))
	# --- Donanma: Çifte Sütunlar (Beşiktaş) ve kızak yolu, fıçı köprüsü
	var dp := IstGeo.ll(41.0430, 29.0085)
	var dpv := _kiyi_bul(Vector2(dp.x, dp.z))
	o.append(_item("diplokionion", "diplokionion", "Çifte Sütunlar donanma üssü (Diplokionion)", dpv[0], dpv[1], 50.0, Vector3(80, 10, 80), "liman", "ordugah"))
	var kz_pts := [IstGeo.ll(41.0268, 28.9826), IstGeo.ll(41.0305, 28.9770), IstGeo.ll(41.0332, 28.9748),
		IstGeo.ll(41.0352, 28.9738), IstGeo.ll(41.0345, 28.9700), IstGeo.ll(41.0300, 28.9668)]
	var kzp: Array = []
	for v in kz_pts:
		kzp.append(Vector2(v.x, v.z))
	for i in kzp.size() - 1:
		var a2: Vector2 = kzp[i]
		var b2: Vector2 = kzp[i + 1]
		var ln := a2.distance_to(b2)
		var np := maxi(int(ceil(ln / 80.0)), 1)
		for j in np:
			var pa := a2.lerp(b2, float(j) / np)
			var pb := a2.lerp(b2, float(j + 1) / np)
			var pls := PackedVector2Array([pa, pa.lerp(pb, 0.5), pb])
			o.append(_item("kizak", "kizak_%d_%d" % [i, j], "Gemilerin karadan yürütüldüğü yol (22 Nisan)", pa.lerp(pb, 0.5), 0.0, 45.0,
				Vector3(80, 1, 6), "ordugah", "iz", {"line": pls, "gemi": (i == 2 and j == 0)}))
	var fb := _fici_yeri()
	o.append(_item("fici_kopru", "fici_kopru", "Haliç fıçı köprüsü", fb[0], fb[1], fb[2] * 0.5 + 12.0, Vector3(fb[2], 3, 6), "liman", "ordugah", {"uzunluk": fb[2]}))
	_plan = o
	return o


## Kıyıda deniz yönünü bul: [pos, yaw] — yerel −z denize bakar
static func _kiyi_bul(p0: Vector2) -> Array:
	var best := p0
	var bestd := 1e9
	for r in range(0, 400, 20):
		for a in 16:
			var p := p0 + Vector2(r, 0).rotated(a * TAU / 16.0)
			if IstGeo.su(p.x, p.y):
				continue
			var hh := IstGeo.h(p.x, p.y)
			if hh > 4.5 or hh < 0.2:
				continue
			# komşuda su var mı
			for b in 16:
				var q := p + Vector2(40, 0).rotated(b * TAU / 16.0)
				if IstGeo.su(q.x, q.y):
					var dd := p.distance_to(p0)
					if dd < bestd:
						bestd = dd
						best = p
					break
	# deniz yönü
	var dir := Vector2.ZERO
	for b in 24:
		var v := Vector2(60, 0).rotated(b * TAU / 24.0)
		if IstGeo.su(best.x + v.x, best.y + v.y):
			dir += v.normalized()
	if dir.length() < 0.1:
		dir = Vector2(0, -1)
	dir = dir.normalized()
	# yerel −z denize: yerel +z yönü karaya = −dir → yaw = atan2(dx, dz) ile dir_kara
	var kara := -dir
	return [best, atan2(kara.x, kara.y)]


## Haliç'te Kasımpaşa ile karşı kıyı arasında köprü: [orta, yaw, uzunluk]
static func _fici_yeri() -> Array:
	var a := IstGeo.ll(41.0292, 28.9640)       # kuzey kıyı (Kasımpaşa) aranan nokta
	var b := IstGeo.ll(41.0245, 28.9590)       # güney kıyı (Cibali) aranan nokta
	var pa := _kara_yakin(Vector2(a.x, a.z), Vector2(b.x, b.z))
	var pb := _kara_yakin(Vector2(b.x, b.z), Vector2(a.x, a.z))
	var d := pb - pa
	var yaw := atan2(d.y, d.x)
	# yerel +x doğu: yaw = −atan2(−d.z...) ; Node3D yaw: yerel +x → (cos ψ, −sin ψ) (x,z)
	var psi := atan2(-d.y, d.x)
	return [(pa + pb) * 0.5, psi, d.length()]


## p0'dan hedef doğrultusunda ilk kara→su geçişinden hemen önceki kara noktası (kıyı)
static func _kara_yakin(p0: Vector2, hedef: Vector2) -> Vector2:
	var dir := (hedef - p0).normalized()
	var p := p0
	var son_kara := p0
	var gordu_su := false
	for i in 400:
		p = p0 + dir * (i * 5.0)
		if IstGeo.su(p.x, p.y):
			gordu_su = true
			break
		son_kara = p
	if not gordu_su:
		# başlangıç suda ise karaya doğru ara
		for i in 400:
			p = p0 - dir * (i * 5.0)
			if not IstGeo.su(p.x, p.y):
				return p
	return son_kara


# ------------------------------------------------------------------ catalog

static func catalog() -> Array:
	var out: Array = []
	var wings := {}
	for it: Dictionary in plan():
		var kind: String = it["kind"]
		if kind == "kanat" or kind == "siper" or kind == "kizak":
			var key: String = it["args"].get("kanat", kind) if kind == "kanat" else kind
			if not wings.has(key):
				wings[key] = {"min": Vector2(1e9, 1e9), "max": Vector2(-1e9, -1e9), "n": 0, "ad": it["ad"], "tur": it["tur"]}
			var w: Dictionary = wings[key]
			var pp: Vector2 = it["pos"]
			w["min"] = Vector2(minf(w["min"].x, pp.x), minf(w["min"].y, pp.y))
			w["max"] = Vector2(maxf(w["max"].x, pp.x), maxf(w["max"].y, pp.y))
			w["n"] = int(w["n"]) + 1
			continue
		out.append(_kayit(it))
	for key in wings:
		var w2: Dictionary = wings[key]
		var c: Vector2 = (w2["min"] + w2["max"]) * 0.5
		var e := IstGeo.real(c.x, c.y)
		out.append({
			"id": "kanat_" + key, "ad": w2["ad"], "dogu_m": e.x, "kuzey_m": e.y,
			"gercek_olcu": Vector3((w2["max"].x - w2["min"].x) / S, 6.0, (w2["max"].y - w2["min"].y) / S),
			"yon_derece": 0.0, "durum": "ordugah", "tur": w2["tur"], "hucre": w2["n"], "bakis_r": 300.0,
		})
	return out


static func _kayit(it: Dictionary) -> Dictionary:
	var p: Vector2 = it["pos"]
	var e := IstGeo.real(p.x, p.y)
	var yaw_d := rad_to_deg(-it["yaw"]) if true else 0.0
	var ol: Vector3 = it["olcu"]
	var d := {
		"id": it["id"], "ad": it["ad"], "dogu_m": e.x, "kuzey_m": e.y,
		"gercek_olcu": Vector3(ol.x / S, ol.y, ol.z / S) if it["kind"] in ["otag", "sahi_top", "batarya"] else ol,
		"yon_derece": fposmod(yaw_d + 180.0, 360.0), "durum": it["durum"], "tur": it["tur"],
	}
	if it["kind"] in ["otag", "sahi_top", "diplokionion", "kule"]:
		d["gorev"] = true
		d["bakis"] = Vector3(0, 22.0 if it["kind"] == "otag" else 16.0, 0)
		d["bakis_r"] = 60.0 if it["kind"] == "otag" else 40.0
	else:
		d["bakis_r"] = 40.0
	return d


# ------------------------------------------------------------------ tekil kurucular (frozen arayüz)

static func build_otag(host: Node3D, k := 0.5, lod := 0) -> void:
	Y.build_otag(host, k, lod)

static func perches_otag(k := 0.5) -> Array:
	var kz := Y.kk(k)
	return [Vector3(0, 11.7, 0), Vector3(-17.0 * kz, 6.62, -14.0), Vector3(-7.5, 9.1, 17.5)]

static func climbs_otag(k := 0.5) -> Array:
	var kz := Y.kk(k)
	var a := Y.kule_merdiven_ucu(Vector3(-17.0 * kz, 0, -14.0), 6.4)
	return [[a[0], a[1], "basamak"]]


static func bat_dims(n: int, buyuk: bool) -> Vector2:
	return Vector2(n * (12.0 if buyuk else 8.5) + 8.0, 15.0 if buyuk else 11.0)

static func build_batarya(host: Node3D, k := 0.5, lod := 0, n := 3, tohum := 7) -> void:
	Y.build_batarya(host, k, lod, tohum, {"n": n})

static func perches_batarya(k := 0.5, n := 3) -> Array:
	var d := bat_dims(n, false)
	return [Vector3(-d.x / 2 + seg_x(n, false), 2.55, d.y / 2 - 2.2), Vector3(d.x * 0.5 - 1.2, 6.1, 0.5)]

static func seg_x(n: int, buyuk: bool) -> float:
	var d := bat_dims(n, buyuk)
	return ((d.x - n * 2.6) / (n + 1.0)) * 0.5

static func climbs_batarya(k := 0.5, n := 3) -> Array:
	var d := bat_dims(n, false)
	var fz := d.y / 2.0 - 2.2
	return [
		[Vector3(d.x * 0.5 - 3.0, 0, -d.y / 2.0 - 1.5), Vector3(d.x * 0.5 - 3.0, 1.0, -d.y / 2.0 + 3.0), "basamak"],
		[Vector3(-d.x * 0.5, 1.0, -d.y / 2.0 + 3.2), Vector3(-d.x * 0.5, 2.5, fz - 0.4), "basamak"],
	]

static func build_sahi_top(host: Node3D, k := 0.5, lod := 0) -> void:
	Y.build_sahi_top(host, k, lod)

static func perches_sahi_top(k := 0.5) -> Array:
	var d := bat_dims(1, true)
	return [Vector3(0, 3.7 + 1.0, d.y / 2.0 - 2.2), Vector3(d.x * 0.5 - 1.2, 6.1, 0.5)]

static func climbs_sahi_top(k := 0.5) -> Array:
	var d := bat_dims(1, true)
	var fz := d.y / 2.0 - 2.2
	return [
		[Vector3(d.x * 0.5 - 3.0, 0, -d.y / 2.0 - 1.5), Vector3(d.x * 0.5 - 3.0, 1.0, -d.y / 2.0 + 3.0), "basamak"],
		[Vector3(-d.x * 0.5, 1.0, -d.y / 2.0 + 3.2), Vector3(-d.x * 0.5, 3.6, fz - 0.4), "basamak"],
	]

static func build_mancinik(host: Node3D, k := 0.5, lod := 0) -> void:
	Y.build_mancinik(host, k, lod)

static func perches_mancinik(k := 0.5) -> Array:
	return [Vector3(1.1, 6.25, 0)]

static func climbs_mancinik(k := 0.5) -> Array:
	return [[Vector3(-3.4, 0, 3.0), Vector3(-2.7, 0.12, -0.2), "sandik"]]

static func build_kule(host: Node3D, k := 0.5, lod := 0) -> void:
	Y.build_kule(host, k, lod)

static func perches_kule(k := 0.5) -> Array:
	return [Vector3(0, 14.95, 0)]

static func climbs_kule(k := 0.5) -> Array:
	var S2 := 4.6
	var plat_y := 0.8 + 13.0 / 3.0 + 0.1
	var steps := int(ceil(plat_y / 0.27))
	return [[Vector3(-S2 / 2 - 1.8 - (steps - 1) * 0.34 - 0.4, 0, -S2 / 2 + 1.1), Vector3(-S2 / 2 - 0.9, plat_y, -S2 / 2 + 1.1), "basamak"]]

static func build_mescit(host: Node3D, k := 0.5, lod := 0) -> void:
	Y2.build_mescit(host, k, lod)

static func perches_mescit(k := 0.5) -> Array:
	return [Vector3(0, 5.05, 0), Vector3(7.6, 6.1, -4.9)]

static func climbs_mescit(k := 0.5) -> Array:
	return []

static func build_pazar(host: Node3D, k := 0.5, lod := 0) -> void:
	Y2.build_pazar(host, k, lod)

static func perches_pazar(k := 0.5) -> Array:
	var cols := int(clampf(4 + k * 4, 4, 8))
	return [Vector3((0 - (cols - 1) * 0.5) * 7.0, 0.95, -5.5)]

static func climbs_pazar(k := 0.5) -> Array:
	return []

static func build_mutfak(host: Node3D, k := 0.5, lod := 0) -> void:
	Y2.build_mutfak(host, k, lod)

static func perches_mutfak(k := 0.5) -> Array:
	return [Vector3(-8.5, 2.05, 0)]

static func climbs_mutfak(k := 0.5) -> Array:
	return []

static func build_ahir(host: Node3D, k := 0.5, lod := 0) -> void:
	Y2.build_ahir(host, k, lod)

static func perches_ahir(k := 0.5) -> Array:
	return [Vector3(-6.0, 0.72, -3.6)]

static func climbs_ahir(k := 0.5) -> Array:
	return []

static func build_siper(host: Node3D, k := 0.5, lod := 0, line := PackedVector2Array()) -> void:
	Y2.build_siper(host, k, lod, 8, line)

static func perches_siper(k := 0.5) -> Array:
	return []

static func climbs_siper(k := 0.5) -> Array:
	return []

static func build_diplokionion(host: Node3D, k := 0.5, lod := 0) -> void:
	DN.build_diplokionion(host, k, lod)

static func perches_diplokionion(k := 0.5) -> Array:
	return [Vector3(-4.0, 10.1, 6.0), Vector3(4.0, 10.1, 6.0)]

static func climbs_diplokionion(k := 0.5) -> Array:
	return [[Vector3(0, 0, 9.0), Vector3(0, 0.68, 3.0), "basamak"]]

static func build_kizak(host: Node3D, k := 0.5, lod := 0, line := PackedVector2Array()) -> void:
	DN.build_kizak(host, k, lod, 10, line, true)

static func perches_kizak(k := 0.5) -> Array:
	return []

static func climbs_kizak(k := 0.5) -> Array:
	return []

static func build_fici_kopru(host: Node3D, k := 0.5, lod := 0) -> void:
	DN.build_fici_kopru(host, k, lod)

static func perches_fici_kopru(k := 0.5) -> Array:
	return [Vector3(0, 1.0, 0)]

static func climbs_fici_kopru(k := 0.5) -> Array:
	return []

static func build_kanat(host: Node3D, alan_cokgen: PackedVector2Array, tur: String, k := 0.5, lod := 0, tohum := 1) -> void:
	KN.build_kanat(host, alan_cokgen, tur, k, lod, tohum)


## Öğe (plan satırı) → host'a kur
static func uret(it: Dictionary, host: Node3D, lod: int) -> void:
	var pos: Vector2 = it["pos"]
	var args: Dictionary = it["args"]
	var seed_: int = it["tohum"]
	match String(it["kind"]):
		"otag": Y.build_otag(host, S, lod)
		"sahi_top": Y.build_sahi_top(host, S, lod, seed_)
		"batarya": Y.build_batarya(host, S, lod, seed_, args)
		"mancinik": Y.build_mancinik(host, S, lod, seed_)
		"kule": Y.build_kule(host, S, lod, seed_)
		"mescit": Y2.build_mescit(host, S, lod, seed_)
		"pazar": Y2.build_pazar(host, S, lod, seed_)
		"mutfak": Y2.build_mutfak(host, S, lod, seed_)
		"ahir": Y2.build_ahir(host, S, lod, seed_)
		"diplokionion": DN.build_diplokionion(host, S, lod, seed_)
		"fici_kopru": DN.build_fici_kopru(host, S, lod, seed_, float(args.get("uzunluk", 160.0)))
		"siper":
			var loc := PackedVector2Array()
			for p: Vector2 in args["line"]:
				loc.append(p - pos)
			Y2.build_siper(host, S, lod, seed_, loc)
		"kizak":
			var loc2 := PackedVector2Array()
			for p2: Vector2 in args["line"]:
				loc2.append(p2 - pos)
			DN.build_kizak(host, S, lod, seed_, loc2, bool(args.get("gemi", false)))
		"kanat":
			var loc3 := PackedVector2Array()
			for p3: Vector2 in args["alan"]:
				loc3.append(p3 - pos)
			KN.build_kanat(host, loc3, String(args["tur"]), S, lod, seed_)


# ------------------------------------------------------------------ v2'ye bağlama

static func attach(dunya: Node3D, gece := false) -> void:
	var m := IstOrdugahYonetici.new()
	m.name = "IstOrdugah"
	m.gece = gece
	dunya.add_child(m)
	m.kur(plan())
