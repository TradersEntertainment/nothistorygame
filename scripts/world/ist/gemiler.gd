class_name IstGemiler
extends RefCounted
## İstanbul v2: Nisan 1453'te sudaki her şey. Gemiler gerçek boyda (1:1, k yalnız tek gemi kurucusunda kütleyi ölçekler).
## Arayüz (dondurulmuş kalıp, docs/_ajan/gorev/_istanbul_ortak.md):
##   catalog() → filolar; build_<tip>(host, k, lod) tek gemi (yürünür güverte); perches_<tip>; climbs_<tip>
##   build_filo_<ad>(host, lod, tohum) dünya koordinatında filo (IstGeo); attach(dunya, gece) hepsini v2'ye kurar.
## Kaynak özeti: docs/_kanit_ist_gemiler/rapor.md. Mesh: IstGemilerMesh (gemiler_mesh.gd).
##
## Filo lod: 0 = örnek başına çarpışma (yürünür güverte) + mesafeye göre ağ ayrıntısı; 1 = çarpışmasız; 2 = yalnız siluet.
## Her filo, deniz kontrolüne (IstGeo.su) göre DOĞRULANMIŞ yerleşimle kurulur; kara ya da sur üstüne düşen tekne atılır.

const M = preload("res://scripts/world/ist/gemiler_mesh.gd")

## Yürünür gemi tipleri (çarpışma). Kayık ve balıkçı teknesi yalnız gövde kutusu.
const YURUNUR := ["karaka", "kog", "kadirga", "kalyata", "fusta", "parandarya"]
## Çarpışma katmanı: oyuncunun zemin maskesi için varsayılan katman (1)
const KATMAN := 1

static var enabled := true
static var tohum_varsayilan := 1453
static var _plan_onbellek := {}


# ====================================================================== katalog

static func catalog() -> Array:
	return [
		{"id": "zincir_filosu", "ad": "Zincirin arkasındaki Hristiyan filosu (26 savaş gemisi)", "dogu_m": -640.0, "kuzey_m": 1180.0,
			"gercek_olcu": Vector3(260.0, 36.0, 900.0), "yon_derece": 355.0, "durum": "saglam", "tur": "liman",
			"bakis": Vector3(-320.0, 40.0, -590.0), "bakis_r": 120.0, "gorev": true},
		{"id": "haliç_iskeleleri", "ad": "Haliç iskelelerindeki tüccar gemileri", "dogu_m": -700.0, "kuzey_m": 960.0,
			"gercek_olcu": Vector3(520.0, 30.0, 160.0), "yon_derece": 300.0, "durum": "saglam", "tur": "liman"},
		{"id": "galata_rihtimi", "ad": "Galata rıhtımındaki Ceneviz gemileri", "dogu_m": -250.0, "kuzey_m": 1560.0,
			"gercek_olcu": Vector3(900.0, 30.0, 140.0), "yon_derece": 90.0, "durum": "saglam", "tur": "liman"},
		{"id": "osmanli_cifte_sutunlar", "ad": "Osmanlı donanması: Çifte Sütunlar (Diplokionion)", "dogu_m": 2352.0, "kuzey_m": 3825.0,
			"gercek_olcu": Vector3(900.0, 30.0, 700.0), "yon_derece": 20.0, "durum": "saglam", "tur": "liman",
			"bakis": Vector3(1180.0, 70.0, -1912.0), "bakis_r": 160.0, "gorev": true},
		{"id": "osmanli_bogaz_agzi", "ad": "Osmanlı donanması: Boğaz ağzı (Tophane–Kabataş, Üsküdar)", "dogu_m": 1700.0, "kuzey_m": 1800.0,
			"gercek_olcu": Vector3(1800.0, 30.0, 1400.0), "yon_derece": 30.0, "durum": "saglam", "tur": "liman"},
		{"id": "balikci_kayiklari", "ad": "Haliç, Marmara ve Boğaz'da balıkçı kayıkları ve sandallar", "dogu_m": -1200.0, "kuzey_m": 1200.0,
			"gercek_olcu": Vector3(4000.0, 12.0, 4000.0), "yon_derece": 0.0, "durum": "saglam", "tur": "ayrinti"},
		{"id": "marmara_limanlari", "ad": "Marmara limanlarındaki gemiler (Bukoleon, Kontoskalion, Theodosios)", "dogu_m": -900.0, "kuzey_m": -1700.0,
			"gercek_olcu": Vector3(2400.0, 20.0, 400.0), "yon_derece": 270.0, "durum": "saglam", "tur": "liman"},
		{"id": "nisan20", "ad": "20 Nisan: dört büyük Ceneviz gemisi (isteğe bağlı sahne)", "dogu_m": 1500.0, "kuzey_m": 650.0,
			"gercek_olcu": Vector3(900.0, 36.0, 900.0), "yon_derece": 35.0, "durum": "saglam", "tur": "anit",
			"bakis": Vector3(720.0, 60.0, -330.0), "bakis_r": 150.0, "gorev": true},
	]


# ====================================================================== tek gemi kurucuları

static func _olcek_ana(tip: String, k: float) -> float:
	return clampf(k, 0.35, 1.0) if k < 1.0 else 1.0


## Tek gemi (yürünür güverte). k: 1 = gerçek boy; <1 gövde ve donanım küçülür, güverte yüksekliği ve bordalar gerçek kalır.
static func build_gemi(host: Node3D, tip: String, bay: String, k := 1.0, lod := 0, acik := false) -> Node3D:
	var root := Node3D.new()
	root.name = "Gemi_" + tip
	host.add_child(root)
	var mi := MeshInstance3D.new()
	mi.name = "Govde"
	mi.mesh = M.mesh(tip, bay, 0 if lod == 0 else (1 if lod == 1 else 2), acik)
	mi.material_override = M.malzeme()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(mi)
	if lod <= 1 and tip != "":
		root.add_child(carpisma_govdesi(tip))
	# k < 1: gemi ölçeklenir; çarpışma da aynı ölçekle (güverte yüksekliği k × D). İnsan boyu gerçek kalır.
	if k < 0.999:
		root.scale = Vector3.ONE * clampf(k, 0.35, 1.0)
	return root


static func build_karaka(host: Node3D, k := 1.0, lod := 0) -> void: build_gemi(host, "karaka", "ceneviz", k, lod)
static func build_kog(host: Node3D, k := 1.0, lod := 0) -> void: build_gemi(host, "kog", "venedik", k, lod)
static func build_kadirga(host: Node3D, k := 1.0, lod := 0) -> void: build_gemi(host, "kadirga", "venedik", k, lod)
static func build_kalyata(host: Node3D, k := 1.0, lod := 0) -> void: build_gemi(host, "kalyata", "osmanli", k, lod)
static func build_fusta(host: Node3D, k := 1.0, lod := 0) -> void: build_gemi(host, "fusta", "osmanli_yesil", k, lod)
static func build_parandarya(host: Node3D, k := 1.0, lod := 0) -> void: build_gemi(host, "parandarya", "osmanli", k, lod)
static func build_balikci(host: Node3D, k := 1.0, lod := 0) -> void: build_gemi(host, "balikci", "balik", k, lod)
static func build_sandal(host: Node3D, k := 1.0, lod := 0) -> void: build_gemi(host, "sandal", "balik", k, lod)

## Konma noktaları: Nihat'ın konabileceği yerler (direk gabyası değil; güvertedeki kasara üstü / baş sahanlığı) — çarpışmalı
static func perches_tip(tip: String, k := 1.0) -> Array:
	var d: Dictionary = M.TIPLER[tip]
	var yd: float = d["D"]
	var L: float = d["L"]
	var out: Array = []
	for kas: Dictionary in M._kasaralar(tip):
		var c: Vector3 = kas["c"]
		var s: Vector3 = kas["s"]
		out.append((c + Vector3(0, s.y * 0.5 + 0.2, 0)) * k)
	if out.is_empty():
		out.append(Vector3(0, yd + 0.3, L * 0.1) * k)
	return out


static func perches_karaka(k := 1.0) -> Array: return perches_tip("karaka", k)
static func perches_kog(k := 1.0) -> Array: return perches_tip("kog", k)
static func perches_kadirga(k := 1.0) -> Array: return perches_tip("kadirga", k)
static func perches_kalyata(k := 1.0) -> Array: return perches_tip("kalyata", k)
static func perches_fusta(k := 1.0) -> Array: return perches_tip("fusta", k)
static func perches_parandarya(k := 1.0) -> Array: return perches_tip("parandarya", k)
static func perches_balikci(k := 1.0) -> Array: return perches_tip("balikci", k)
static func perches_sandal(k := 1.0) -> Array: return perches_tip("sandal", k)


## Tırmanış: gemi güvertesine kıyıdan tahta köprü (rampa) iskele ağzında; gemi bordası üstünden direğe tırmanış YOK.
## Alt: rıhtım yüzünde (yerelde gemi yanı), üst: güverte. "iskele" türü (tahta köprü).
static func climbs_tip(tip: String, k := 1.0) -> Array:
	var d: Dictionary = M.TIPLER[tip]
	var yd: float = d["D"]
	var B: float = d["B"]
	return [[Vector3(B * 0.5 + 6.0, 0.4, 0.0) * k, Vector3(B * 0.5 * 0.86, yd, 0.0) * k, "iskele"]]


static func climbs_karaka(k := 1.0) -> Array: return climbs_tip("karaka", k)
static func climbs_kog(k := 1.0) -> Array: return climbs_tip("kog", k)
static func climbs_kadirga(k := 1.0) -> Array: return climbs_tip("kadirga", k)
static func climbs_kalyata(k := 1.0) -> Array: return climbs_tip("kalyata", k)
static func climbs_fusta(k := 1.0) -> Array: return climbs_tip("fusta", k)
static func climbs_parandarya(k := 1.0) -> Array: return climbs_tip("parandarya", k)
static func climbs_balikci(k := 1.0) -> Array: return climbs_tip("balikci", k)
static func climbs_sandal(k := 1.0) -> Array: return climbs_tip("sandal", k)


# ====================================================================== çarpışma

static var _sekil_onbellek := {}


## Geminin çarpışma şekilleri (yerel): gövde (üstü güverte düzlemi), bordalar (kutular), kasaralar.
## Döner: [{"s": Shape3D, "t": Transform3D}]
static func sekiller(tip: String) -> Array:
	if _sekil_onbellek.has(tip):
		return _sekil_onbellek[tip]
	var d: Dictionary = M.TIPLER[tip]
	var yd: float = d["D"]
	var st := M.istasyon(tip)
	var out: Array = []
	# Gövde: istasyon noktalarının dışbükey kabuğu (üst yüz = güverte düzlemi)
	var pts := PackedVector3Array()
	for s_: Array in st:
		var z: float = s_[0]
		var w: float = s_[1]
		var yb: float = s_[3]
		for sx: float in [-1.0, 1.0]:
			pts.append(Vector3(sx * w * 0.9, yd, z))
			pts.append(Vector3(sx * w * 0.8, yb * 0.35, z))
		pts.append(Vector3(0, yb, z))
	var hull := ConvexPolygonShape3D.new()
	hull.points = pts
	out.append({"s": hull, "t": Transform3D.IDENTITY})
	# Bordalar: ardışık iki istasyon arası eğik kutu (kalınlık 0,3; yükseklik = bordanın en yükseği)
	if tip != "sandal" and tip != "balikci":
		var gruplar := [[0, 2], [2, 4], [4, 6], [6, 8], [8, 10]]
		for g: Array in gruplar:
			var a: Array = st[g[0]]
			var b: Array = st[g[1]]
			var tmax := 0.0
			for q in range(g[0], g[1] + 1):
				tmax = maxf(tmax, (st[q][2] as float))
			var h := tmax - yd
			for sx: float in [-1.0, 1.0]:
				var p0 := Vector3(sx * (a[1] as float) * 0.92, 0.0, a[0] as float)
				var p1 := Vector3(sx * (b[1] as float) * 0.92, 0.0, b[0] as float)
				# orta noktadaki dış kenar (dışbükey yay): kutuyu yayın dışına doğru biraz it
				var mid_w := (st[(g[0] + g[1]) / 2][1] as float) * 0.92
				var mid := (p0 + p1) * 0.5
				var len := p0.distance_to(p1)
				var yaw := atan2(p1.x - p0.x, p1.z - p0.z)
				var kutu := BoxShape3D.new()
				kutu.size = Vector3(0.34, h, len + 0.2)
				var cx := mid.x + sx * (maxf(mid_w - absf(mid.x), 0.0)) * 0.5
				out.append({"s": kutu, "t": Transform3D(Basis(Vector3.UP, yaw), Vector3(cx, yd + h * 0.5, mid.z))})
	# Kasaralar (üst plaka 0,2 m dahil) ve çıkış basamakları
	for kas: Dictionary in M._kasaralar(tip):
		var kutu2 := BoxShape3D.new()
		var ks: Vector3 = kas["s"]
		kutu2.size = Vector3(ks.x + 0.4, ks.y + 0.2, ks.z + 0.4)
		out.append({"s": kutu2, "t": Transform3D(Basis(), (kas["c"] as Vector3) + Vector3(0, 0.1, 0))})
	for y: Dictionary in M._yuk_kutular(tip):
		var kutu4 := BoxShape3D.new()
		kutu4.size = y["s"]
		out.append({"s": kutu4, "t": Transform3D(Basis(), y["c"])})
	for b: Dictionary in M._basamaklar(tip):
		var kutu3 := BoxShape3D.new()
		kutu3.size = b["s"]
		out.append({"s": kutu3, "t": Transform3D(Basis(), b["c"])})
	_sekil_onbellek[tip] = out
	return out


## Tek gemi için çarpışma gövdesi (StaticBody3D, adı "Carpisma")
static func carpisma_govdesi(tip: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = "Carpisma"
	body.collision_layer = KATMAN
	body.collision_mask = 0
	body.set_meta("gemi", tip)
	for e: Dictionary in sekiller(tip):
		var cs := CollisionShape3D.new()
		cs.shape = e["s"]
		cs.transform = e["t"]
		body.add_child(cs)
	return body


## Kıyıdaki iniş noktasından (dünya, geminin konumuna göre kayık) güverteye tahta köprü: çarpışma + görsel (gövdeye eklenir)
static func tahta_koy(body: StaticBody3D, tip: String, inis_goreli: Vector3, yaw: float) -> void:
	var d: Dictionary = M.TIPLER[tip]
	var yd: float = d["D"]
	var B: float = d["B"]
	var L: float = d["L"]
	var loc := Basis(Vector3.UP, yaw).inverse() * inis_goreli
	var a := Vector3(signf(loc.x) * B * 0.5 * 0.8, yd, clampf(loc.z, -L * 0.2, L * 0.2))
	var b := Vector3(loc.x, loc.y + 0.05, loc.z)
	var dv := b - a
	var len := dv.length()
	if len < 1.0 or len > 22.0:
		return
	var basis := Basis.looking_at(dv.normalized(), Vector3.UP)
	var mid := (a + b) * 0.5
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.6, 0.14, len)
	cs.shape = bs
	cs.transform = Transform3D(basis, mid)
	body.add_child(cs)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = bs.size
	mi.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("7a5a38")
	mat.roughness = 0.9
	mi.material_override = mat
	mi.transform = Transform3D(basis, mid)
	mi.name = "Tahta"
	body.add_child(mi)


# ====================================================================== yerleşim yardımcıları

## Gemi dikdörtgenleri çakışıyor mu (yönlü kutu; dönen eksen ayırma). pay: ek boşluk
static func _obb(p: Vector2, yaw: float, hl: float, hw: float) -> Array:
	var f := Vector2(sin(yaw), cos(yaw))        # baş yönü (x, z)
	var r := Vector2(f.y, -f.x)
	return [p, f, r, hl, hw]


static func _cakisir(a: Array, b: Array, pay := 0.0) -> bool:
	var pa: Vector2 = a[0]
	var pb: Vector2 = b[0]
	var d := pb - pa
	if d.length() > (a[3] as float) + (b[3] as float) + 12.0:
		return false
	for ax: Vector2 in [a[1], a[2], b[1], b[2]]:
		var ra: float = absf(ax.dot(a[1] as Vector2)) * (a[3] as float) + absf(ax.dot(a[2] as Vector2)) * (a[4] as float)
		var rb: float = absf(ax.dot(b[1] as Vector2)) * (b[3] as float) + absf(ax.dot(b[2] as Vector2)) * (b[4] as float)
		if absf(d.dot(ax)) > ra + rb + pay:
			return false
	return true


## Gemi ayak izi tamamen denizde mi (bayrak tabanı + ızgara; pay: kıyıdan en az uzaklık)
static func suda(p: Vector2, yaw: float, L: float, B: float, pay := 3.0) -> bool:
	var f := Vector2(sin(yaw), cos(yaw))
	var r := Vector2(f.y, -f.x)
	for u: float in [-1.0, -0.5, 0.0, 0.5, 1.0]:
		for v: float in [-1.0, 0.0, 1.0]:
			var q := p + f * (u * (L * 0.5 + pay)) + r * (v * (B * 0.5 + 3.5 + pay))
			if not IstGeo.su(q.x, q.y) or IstGeo.sehir_ici(q.x, q.y) or IstGeo.galata_ici(q.x, q.y):
				return false
	return true


## En yakın kara: [uzaklık, kıyıdan denize bakan birim vektör]; maxd içinde kara yoksa [maxd, Vector2.ZERO]
static func kiyi_bilgi(p: Vector2, maxd := 90.0) -> Array:
	var best := maxd
	var acc := Vector2.ZERO
	for i in 24:
		var a := TAU * i / 24.0
		var dir := Vector2(cos(a), sin(a))
		var dd := 3.0
		while dd <= maxd:
			var q := p + dir * dd
			if not IstGeo.su(q.x, q.y):
				best = minf(best, dd)
				acc += dir * (1.0 / dd)
				break
			dd += 3.0
	if acc.length() < 0.0001:
		return [maxd, Vector2.ZERO]
	return [best, -acc.normalized()]


## Çokgen içinde nokta (dünya x,z)
static func _icinde(p: Vector2, poly: PackedVector2Array) -> bool:
	return Geometry2D.is_point_in_polygon(p, poly)


static func _dikdortgen(e0: float, n0: float, e1: float, n1: float) -> PackedVector2Array:
	return PackedVector2Array([IstGeo.w2(e0, n0), IstGeo.w2(e1, n0), IstGeo.w2(e1, n1), IstGeo.w2(e0, n1)])


static func _kutu_poly(poly: PackedVector2Array) -> Rect2:
	var r := Rect2(poly[0], Vector2.ZERO)
	for q in poly:
		r = r.expand(q)
	return r


static func _tip_boyut(tip: String) -> Vector2:
	var d: Dictionary = M.TIPLER[tip]
	return Vector2(d["L"], d["B"])


## Kıyıya göre yerleşim: poligon içinde rastgele noktalar; kıyıya uzaklık [dmin, dmax]; hiza: "paralel" | "dik" | "serbest".
## Dönen her kayıt {"tip", "bay", "p": Vector2, "yaw", "acik"}; mevcut: çakışma denetimi için önceki kayıtlar.
static func kiyi_yerlestir(poly: PackedVector2Array, tipler: Array, dmin: float, dmax: float, hiza: String, rng: RandomNumberGenerator,
		mevcut: Array, dislama: Array = [], deneme := 4000, pay := 2.0) -> Array:
	var sonuc: Array = []
	var kutu := _kutu_poly(poly)
	var sira := 0
	var den := 0
	while sira < tipler.size() and den < deneme:
		den += 1
		var tb: Array = tipler[sira]       # [tip, bay, acik]
		var tip: String = tb[0]
		var lb := _tip_boyut(tip)
		var p := Vector2(rng.randf_range(kutu.position.x, kutu.end.x), rng.randf_range(kutu.position.y, kutu.end.y))
		if not _icinde(p, poly):
			continue
		if not IstGeo.su(p.x, p.y):
			continue
		var kb := kiyi_bilgi(p, dmax + 30.0)
		var d: float = kb[0]
		if d < dmin or d > dmax:
			continue
		var n: Vector2 = kb[1]
		var yaw := 0.0
		match hiza:
			"paralel":
				var tvec := Vector2(-n.y, n.x)
				if rng.randf() < 0.5:
					tvec = -tvec
				yaw = atan2(tvec.x, tvec.y) + rng.randf_range(-0.05, 0.05)
			"dik":
				var bvec := n if rng.randf() < 0.5 else -n
				yaw = atan2(bvec.x, bvec.y) + rng.randf_range(-0.08, 0.08)
			_:
				yaw = rng.randf() * TAU
		var ok := true
		for dz: Array in dislama:
			if p.distance_to(dz[0] as Vector2) < (dz[1] as float):
				ok = false
				break
		if not ok:
			continue
		if not suda(p, yaw, lb.x, lb.y, 2.0):
			continue
		var ob := _obb(p, yaw, lb.x * 0.5 + 1.0, lb.y * 0.5 + 3.0)
		for m: Dictionary in mevcut:
			if _cakisir(ob, m["obb"] as Array, pay):
				ok = false
				break
		if not ok:
			continue
		for m: Dictionary in sonuc:
			if _cakisir(ob, m["obb"] as Array, pay):
				ok = false
				break
		if not ok:
			continue
		sonuc.append({"tip": tip, "bay": tb[1], "p": p, "yaw": yaw, "acik": tb[2], "obb": ob})
		sira += 1
	return sonuc


## Kıyı poligonundan, gerçek (e,n) dikdörtgeni içindeki en uzun ardışık hat (dünya x,z)
static func kiyi_hatti(poly: PackedVector2Array, e0: float, n0: float, e1: float, n1: float) -> PackedVector2Array:
	var en_iyi := PackedVector2Array()
	var cur := PackedVector2Array()
	var r := Rect2(Vector2(minf(e0, e1), minf(n0, n1)), Vector2(absf(e1 - e0), absf(n1 - n0)))
	for q in poly:
		var re := IstGeo.real(q.x, q.y)
		if r.has_point(re):
			cur.append(q)
		else:
			if cur.size() > en_iyi.size():
				en_iyi = cur
			cur = PackedVector2Array()
	if cur.size() > en_iyi.size():
		en_iyi = cur
	return en_iyi


## Hat boyunca (yay uzunluğu t) nokta ve birim teğet
static func _hat_nokta(hat: PackedVector2Array, t: float) -> Array:
	var acc := 0.0
	for i in hat.size() - 1:
		var sl := hat[i].distance_to(hat[i + 1])
		if t <= acc + sl and sl > 0.001:
			var u := (t - acc) / sl
			return [hat[i].lerp(hat[i + 1], u), (hat[i + 1] - hat[i]).normalized()]
		acc += sl
	return []


static func _hat_uzun(hat: PackedVector2Array) -> float:
	var l := 0.0
	for i in hat.size() - 1:
		l += hat[i].distance_to(hat[i + 1])
	return l


## Kıyı hattına paralel sıralar: her sıra için kıyıdan uzaklık (mesafe); hiza "dik" (burun karaya) ya da "paralel";
## tipler sırayla sıralara dağıtılır; gemiler arası boşluk = en + aralik. Döner: kayıtlar (mevcut ile çakışma denetimli).
static func sira_yerlestir(hat: PackedVector2Array, tipler: Array, mesafeler: Array, hiza: String, aralik: float, rng: RandomNumberGenerator,
		mevcut: Array, dislama: Array = []) -> Array:
	var sonuc: Array = []
	if hat.size() < 2:
		return sonuc
	var toplam := _hat_uzun(hat)
	var sira := 0
	for md: float in mesafeler:
		var t := rng.randf_range(2.0, 12.0)
		while t < toplam - 4.0 and sira < tipler.size():
			var tb: Array = tipler[sira]
			var tip: String = tb[0]
			var lb := _tip_boyut(tip)
			var hp := _hat_nokta(hat, t)
			if hp.is_empty():
				break
			var q: Vector2 = hp[0]
			var tv: Vector2 = hp[1]
			var nv := Vector2(-tv.y, tv.x)
			if IstGeo.su(q.x + nv.x * 25.0, q.y + nv.y * 25.0) == false:
				nv = -nv
			var yer := md + (lb.x * 0.5 if hiza == "dik" else lb.y * 0.5)
			var p := q + nv * yer
			var yaw := 0.0
			if hiza == "dik":
				yaw = atan2(-nv.x, -nv.y) + rng.randf_range(-0.05, 0.05)
			else:
				yaw = atan2(tv.x, tv.y) + (PI if rng.randf() < 0.5 else 0.0) + rng.randf_range(-0.04, 0.04)
			var adim := (lb.y + aralik) if hiza == "dik" else (lb.x + aralik)
			var ok := suda(p, yaw, lb.x, lb.y, 2.0)
			if ok:
				for dz: Array in dislama:
					if p.distance_to(dz[0] as Vector2) < (dz[1] as float):
						ok = false
						break
			var kayit := _kayit(tip, tb[1], p, yaw, tb[2])
			if hiza == "paralel" and md <= 16.0 and tip in YURUNUR:
				var hy := IstGeo.h(q.x, q.y)
				if hy < 3.0:
					kayit["rampa"] = Vector3(q.x, maxf(hy, 0.0), q.y)
			if ok:
				for m: Dictionary in mevcut:
					if _cakisir(kayit["obb"] as Array, m["obb"] as Array, 0.8):
						ok = false
						break
			if ok:
				for m: Dictionary in sonuc:
					if _cakisir(kayit["obb"] as Array, m["obb"] as Array, 0.8):
						ok = false
						break
			if ok:
				sonuc.append(kayit)
				sira += 1
				t += adim
			else:
				t += 3.0
	return sonuc


static func _kayit(tip: String, bay: String, p: Vector2, yaw: float, acik := false) -> Dictionary:
	var lb := _tip_boyut(tip)
	return {"tip": tip, "bay": bay, "p": p, "yaw": yaw, "acik": acik, "obb": _obb(p, yaw, lb.x * 0.5 + 1.0, lb.y * 0.5 + 3.0)}


static func _liste(tip: String, bay: Variant, n: int, acik := false) -> Array:
	var a: Array = []
	for i in n:
		var b: String = bay if bay is String else (bay as Array)[i % (bay as Array).size()]
		a.append([tip, b, acik])
	return a


## Diziyi karıştırarak ata (deterministik)
static func _karistir(a: Array, rng: RandomNumberGenerator) -> Array:
	var b := a.duplicate()
	for i in range(b.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = b[i]
		b[i] = b[j]
		b[j] = t
	return b


# ====================================================================== filolar (yerleşim planları)

## 1) Zincirin arkası: 26 savaş gemisi, burunları zincire dönük, iki sıra, yan yana
static func plan_zincir(tohum := 1453) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum
	var z := IstGeo.yol("zincir")
	var a := z[0]
	var b := z[1]
	var tv := (b - a).normalized()                  # güneyden kuzeye (dünyada −z)
	var nw := Vector2(-tv.y, tv.x)                  # zincire dik; Haliç içi = batı (−x)
	if nw.x > 0.0:
		nw = -nw
	var dizi: Array = []
	# Sıralar zincire paralel; burun zincire (−nw) bakar; 26 gemi dolana dek (en çok 4 sıra)
	var seq := ["kadirga", "karaka", "kadirga", "kadirga", "karaka", "kadirga", "kog", "kadirga", "karaka", "kadirga", "kadirga", "karaka", "kadirga"]
	var bays := ["venedik", "ceneviz", "bizans", "venedik", "ceneviz", "bizans", "katalan", "venedik", "ceneviz", "bizans", "venedik", "ceneviz", "bizans"]
	var yaw := atan2(-nw.x, -nw.y)
	var toplam := 0
	var zl := a.distance_to(b)
	for sira in 4:
		if toplam >= 26:
			break
		var t := (0.16 + 0.04 * (sira % 2)) * zl
		var geri := 17.0 + sira * 50.0
		for i in seq.size():
			if toplam >= 26:
				break
			var tip: String = seq[(i + sira * 5) % seq.size()]
			var lb := _tip_boyut(tip)
			var genis := lb.y + (10.0 if tip != "karaka" and tip != "kog" else 3.2)
			var yer: Variant = null
			var dene := 0
			while dene < 8 and t < zl * 0.92:
				var p := a + tv * t + nw * (geri + lb.x * 0.5)
				var yw := yaw + rng.randf_range(-0.04, 0.04)
				if suda(p, yw, lb.x, lb.y, 2.0):
					var ob := _obb(p, yw, lb.x * 0.5 + 0.5, lb.y * 0.5 + 2.0)
					var cakis := false
					for m: Dictionary in dizi:
						if _cakisir(ob, m["obb"] as Array, 0.5):
							cakis = true
							break
					if not cakis:
						yer = [p, yw]
						break
				t += 3.0
				dene += 1
			if yer != null:
				dizi.append(_kayit(tip, bays[(i + sira * 3) % bays.size()], yer[0], yer[1]))
				toplam += 1
				t += genis
	return dizi


## 2) Haliç iskeleleri (Venedik, Pisa, Amalfi): güney kıyıda kıyıya paralel demirli tüccar gemileri (iki sıra)
static func plan_halic_iskele(tohum := 1453) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum + 1
	var hat := kiyi_hatti(IstGeo.kiyi("yarimada"), -1150.0, 850.0, -430.0, 1150.0)
	var tl := _liste("karaka", ["venedik", "ceneviz", "bizans"], 3) + _liste("kog", ["venedik", "ceneviz", "katalan", "tuccar"], 9)
	return sira_yerlestir(hat, _karistir(tl, rng), [26.0, 62.0], "paralel", 4.0, rng, [])


## 3) Galata rıhtımı: Ceneviz'in gemileri kıyıya paralel demirli (rıhtım ve iskele ağzı dışı)
static func plan_galata(tohum := 1453) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum + 2
	var hat := kiyi_hatti(IstGeo.kiyi("galata"), -1000.0, 1480.0, 100.0, 1800.0)
	var tl := _liste("karaka", "ceneviz", 5) + _liste("kog", ["ceneviz", "ceneviz", "tuccar"], 6) + _liste("kadirga", "ceneviz", 2)
	var dis := [[IstGeo.w2(-470.0, 1470.0), 62.0]]
	return sira_yerlestir(hat, _karistir(tl, rng), [26.0, 62.0], "paralel", 4.0, rng, [], dis)


static func _osmanli_listesi(kad: int, kal: int, fus: int, par: int, rng: RandomNumberGenerator) -> Array:
	var tl: Array = []
	tl += _liste("kadirga", ["osmanli", "osmanli_yesil"], kad)
	tl += _liste("kalyata", ["osmanli", "osmanli_yesil", "osmanli"], kal)
	tl += _liste("fusta", ["osmanli", "osmanli_yesil"], fus)
	tl += _liste("parandarya", ["osmanli", "osmanli_yesil"], par)
	return _karistir(tl, rng)


## 4) Çifte Sütunlar (Beşiktaş koyu): ~90 Osmanlı gemisi, kıyı boyunca üç sıra dizili (burun karaya dönük; çekilmiş/demirli)
static func plan_cifte_sutunlar(tohum := 1453) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum + 3
	var hat := kiyi_hatti(IstGeo.kiyi("trakya"), 1500.0, 3000.0, 3200.0, 4300.0)
	var tl := _osmanli_listesi(8, 24, 40, 18, rng)
	# Büyük gemiler içte (kıyıya yakın sıra): kadırga, parandarya, kalyata; fusta dış sıralarda
	var buyuk: Array = []
	var kucuk: Array = []
	for tb: Array in tl:
		if tb[0] == "fusta" or tb[0] == "kalyata":
			kucuk.append(tb)
		else:
			buyuk.append(tb)
	return sira_yerlestir(hat, buyuk + kucuk, [30.0, 70.0, 110.0, 150.0], "dik", 2.5, rng, [])


## 5) Boğaz ağzı: ~50 Osmanlı gemisi, Avrupa kıyısı (Tophane–Kabataş) ve Üsküdar kıyısı
static func plan_bogaz_agzi(tohum := 1453) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum + 4
	var tl := _osmanli_listesi(6, 12, 20, 12, rng)
	var hat_a := kiyi_hatti(IstGeo.kiyi("trakya"), 100.0, 1900.0, 1900.0, 3300.0)
	var hat_u := kiyi_hatti(IstGeo.kiyi("anadolu"), 1800.0, 1200.0, 3300.0, 2600.0)
	var a: Array = sira_yerlestir(hat_a, tl.slice(0, 30), [32.0, 72.0], "dik", 2.5, rng, [])
	var b: Array = sira_yerlestir(hat_u, tl.slice(30), [32.0, 72.0], "dik", 2.5, rng, a)
	return a + b


## 6) Balıkçı kayıkları ve sandallar (Haliç, Marmara, Boğaz, Galata)
static func plan_balikci(tohum := 1453) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum + 5
	var bölgeler := [
		[_dikdortgen(-2500.0, 900.0, -600.0, 2300.0), 36, 12.0, 160.0],        # Haliç içi
		[_dikdortgen(-2800.0, -2500.0, -400.0, 400.0), 26, 14.0, 160.0],       # Marmara kıyısı
		[_dikdortgen(300.0, 1500.0, 1800.0, 3200.0), 18, 14.0, 160.0],         # Boğaz (Avrupa kıyısı)
		[_dikdortgen(-1400.0, 1360.0, 200.0, 1700.0), 16, 14.0, 120.0],        # Galata kıyısı
		[_dikdortgen(-300.0, -400.0, 1500.0, 900.0), 14, 30.0, 200.0],         # Sarayburnu çevresi
	]
	var out: Array = []
	for bg: Array in bölgeler:
		var tl: Array = []
		for i in (bg[1] as int):
			if i % 3 == 0:
				tl.append(["balikci", "balik", false])
			else:
				tl.append(["sandal", "balik", false])
		out += kiyi_yerlestir(bg[0] as PackedVector2Array, tl, bg[2] as float, bg[3] as float, "serbest", rng, out, [], 2500, 0.6)
	return out


## 7) Marmara limanları: Bukoleon, Kontoskalion (Kadırga), Theodosios (Yenikapı)
static func plan_marmara(tohum := 1453) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum + 6
	var out: Array = []
	# IstGeo Marmara kıyısı n ≈ −650…−790 (CSV konumları kestirim ve denizde); limanlar kıyıdan arandı
	var yerler := [
		[_dikdortgen(-300.0, -1000.0, 150.0, -560.0), 4],        # Bukoleon
		[_dikdortgen(-1150.0, -1000.0, -700.0, -560.0), 4],      # Kontoskalion (Kadırga limanı)
		[_dikdortgen(-2150.0, -1000.0, -1700.0, -560.0), 5],     # Theodosios / Yenikapı
	]
	for y: Array in yerler:
		var tl := _liste("kog", ["bizans", "tuccar", "venedik"], 2) + _liste("kalyata", "bizans", 1) + _liste("fusta", "bizans", 1)
		tl = tl.slice(0, y[1] as int)
		out += kiyi_yerlestir(y[0] as PackedVector2Array, tl, 14.0, 60.0, "paralel", rng, out, [], 2500, 1.0)
	return out


## 8) 20 Nisan (isteğe bağlı sahne): dört büyük Ceneviz gemisi, açık yelkenle Marmara'dan Haliç ağzına; çevresinde Osmanlı
static func plan_nisan20(tohum := 1453) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum + 7
	var out: Array = []
	# Gemiler Marmara'dan (Sarayburnu doğusu) kuzeybatıya, Haliç ağzına doğru; baş yönü: kuzey-kuzeybatı
	var hedef := IstGeo.w2(-420.0, 1156.0)
	var orta := IstGeo.w2(1100.0, 450.0)
	var yon := (hedef - orta).normalized()
	var yaw := atan2(yon.x, yon.y)
	var sag := Vector2(yon.y, -yon.x)
	var bayl := ["ceneviz", "ceneviz", "ceneviz", "bizans"]
	var dz := [Vector2(0, 0), Vector2(22, -26), Vector2(-24, -18), Vector2(4, -52)]
	for i in 4:
		var p: Vector2 = orta + sag * (dz[i] as Vector2).x + yon * (dz[i] as Vector2).y
		out.append(_kayit("karaka", bayl[i], p, yaw + rng.randf_range(-0.03, 0.03), true))
	# Osmanlı gemileri iki yayda: öne ve iki yana
	var osm := _osmanli_listesi(4, 14, 22, 5, rng)
	for i in osm.size():
		var tb: Array = osm[i]
		var ang := rng.randf_range(-1.35, 1.35)
		var rad := rng.randf_range(70.0, 190.0)
		var dirv := yon.rotated(ang)
		var p := orta + yon * 30.0 + dirv * rad
		var yw := atan2(-dirv.x, -dirv.y) + rng.randf_range(-0.35, 0.35)       # Cenevizlilere doğru
		var lb := _tip_boyut(tb[0])
		if not suda(p, yw, lb.x, lb.y, 2.0):
			continue
		var kayit := _kayit(tb[0], tb[1], p, yw, false)
		var ok := true
		for m: Dictionary in out:
			if _cakisir(kayit["obb"] as Array, m["obb"] as Array, 1.0):
				ok = false
				break
		if ok:
			out.append(kayit)
	return out


static func plan(ad: String, tohum := 1453) -> Array:
	var key := "%s#%d" % [ad, tohum]
	if _plan_onbellek.has(key):
		return _plan_onbellek[key]
	var r: Array = []
	match ad:
		"zincir": r = plan_zincir(tohum)
		"halic_iskele": r = plan_halic_iskele(tohum)
		"galata": r = plan_galata(tohum)
		"cifte_sutunlar": r = plan_cifte_sutunlar(tohum)
		"bogaz_agzi": r = plan_bogaz_agzi(tohum)
		"balikci": r = plan_balikci(tohum)
		"marmara": r = plan_marmara(tohum)
		"nisan20": r = plan_nisan20(tohum)
	_plan_onbellek[key] = r
	return r


# ====================================================================== filo kurucuları

const LOD0_SON := 260.0
const LOD1_SON := 820.0
const KUME := 280.0


## Filoyu kurar: örnekler tür×bayrak×küme başına MultiMesh (lod 0 / 1 / 2 ağları mesafeyle değişir), isteğe bağlı çarpışma.
## host: Node3D (dünya kökü); kayıtlar dünya koordinatındadır (host konumu sıfır varsayılır).
static func filo_kur(host: Node3D, kayitlar: Array, ad: String, lod := 0, carpisma := true) -> Node3D:
	var kok := Node3D.new()
	kok.name = "Filo_" + ad
	host.add_child(kok)
	var gruplar := {}
	for r: Dictionary in kayitlar:
		var p: Vector2 = r["p"]
		var kx := floori(p.x / KUME)
		var kz := floori(p.y / KUME)
		var key := "%s|%s|%d|%d|%d" % [r["tip"], r["bay"], 1 if r["acik"] else 0, kx, kz]
		if not gruplar.has(key):
			gruplar[key] = []
		gruplar[key].append(r)
	var mats := M.malzeme()
	for key: String in gruplar:
		var liste: Array = gruplar[key]
		var r0: Dictionary = liste[0]
		var xfs: Array = []
		for r: Dictionary in liste:
			var p2: Vector2 = r["p"]
			xfs.append(Transform3D(Basis(Vector3.UP, r["yaw"] as float), Vector3(p2.x, 0.0, p2.y)))
		var kume_merkez := Vector3.ZERO
		for xf: Transform3D in xfs:
			kume_merkez += xf.origin
		kume_merkez /= xfs.size()
		for lv in 3:
			if lod >= 2 and lv < 2:
				continue
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = M.mesh(r0["tip"], r0["bay"], lv, r0["acik"])
			mm.instance_count = xfs.size()
			for i in xfs.size():
				mm.set_instance_transform(i, (xfs[i] as Transform3D))
			var mmi := MultiMeshInstance3D.new()
			mmi.name = "%s_L%d" % [key.replace("|", "_"), lv]
			mmi.multimesh = mm
			mmi.material_override = mats
			mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if lv < 2 else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mmi.set_meta("no_walk", true)
			mmi.visibility_range_begin = 0.0 if lv == 0 else (LOD0_SON - 20.0 if lv == 1 else LOD1_SON - 30.0)
			mmi.visibility_range_end = (LOD0_SON if lv == 0 else (LOD1_SON if lv == 1 else 0.0))
			if lod >= 2:
				mmi.visibility_range_begin = 0.0
			elif lod == 1 and lv == 0:
				mmi.visibility_range_end = LOD0_SON
			kok.add_child(mmi)
	if carpisma and lod <= 1:
		var kb := Node3D.new()
		kb.name = "Carpisma"
		kok.add_child(kb)
		for r: Dictionary in kayitlar:
			if not (r["tip"] in YURUNUR):
				continue
			var p3: Vector2 = r["p"]
			var body := carpisma_govdesi(r["tip"])
			body.position = Vector3(p3.x, 0.0, p3.y)
			body.rotation.y = r["yaw"]
			kb.add_child(body)
			if r.has("rampa"):
				tahta_koy(body, r["tip"], (r["rampa"] as Vector3) - body.position, r["yaw"])
	kok.set_meta("kayitlar", kayitlar)
	kok.set_meta("gemi_sayisi", kayitlar.size())
	return kok


static func build_filo_zincir(host: Node3D, lod := 0, tohum := 1453) -> Node3D: return filo_kur(host, plan("zincir", tohum), "zincir", lod)
static func build_filo_halic_iskele(host: Node3D, lod := 0, tohum := 1453) -> Node3D: return filo_kur(host, plan("halic_iskele", tohum), "halic_iskele", lod)
static func build_filo_galata(host: Node3D, lod := 0, tohum := 1453) -> Node3D: return filo_kur(host, plan("galata", tohum), "galata", lod)
static func build_filo_cifte_sutunlar(host: Node3D, lod := 0, tohum := 1453) -> Node3D: return filo_kur(host, plan("cifte_sutunlar", tohum), "cifte_sutunlar", lod)
static func build_filo_bogaz_agzi(host: Node3D, lod := 0, tohum := 1453) -> Node3D: return filo_kur(host, plan("bogaz_agzi", tohum), "bogaz_agzi", lod)
static func build_filo_balikci(host: Node3D, lod := 0, tohum := 1453) -> Node3D: return filo_kur(host, plan("balikci", tohum), "balikci", lod, false)
static func build_filo_marmara(host: Node3D, lod := 0, tohum := 1453) -> Node3D: return filo_kur(host, plan("marmara", tohum), "marmara", lod)
static func build_filo_nisan20(host: Node3D, lod := 0, tohum := 1453) -> Node3D: return filo_kur(host, plan("nisan20", tohum), "nisan20", lod)


## Bölümde (IstBaglama etkin) filolar ilk karelerden sonra kurulur (yükleme süresi); gezi/önizlemede hemen
static var ertele := true

## Şehre bağlama: IstGemiler.attach(dunya, gece). İsteğe bağlı 20 Nisan sahnesi varsayılan KAPALI.
static func attach(dunya: Node3D, gece := false, nisan20 := false, lod := 0) -> Node3D:
	if not enabled:
		return null
	var kok := Node3D.new()
	kok.name = "IstGemiler"
	dunya.add_child(kok)
	var t0 := Time.get_ticks_usec()
	var tree := Engine.get_main_loop() as SceneTree
	if ertele and tree != null and IstBaglama.aktif():
		# DOKU-4 (yükleme): bölümde filolar ilk karelerden sonra, karede bir filo kurulur (bölüm kartı/kararma sırasında)
		var isler: Array = [build_filo_zincir, build_filo_halic_iskele, build_filo_galata, build_filo_cifte_sutunlar,
			build_filo_bogaz_agzi, build_filo_balikci, build_filo_marmara]
		if nisan20:
			isler.append(build_filo_nisan20)
		var adim: Array = []
		adim.append(func() -> void:
			if not is_instance_valid(kok):
				tree.process_frame.disconnect(adim[0])
				return
			if isler.is_empty():
				tree.process_frame.disconnect(adim[0])
				var top := 0
				for c in kok.get_children():
					top += int(c.get_meta("gemi_sayisi", 0))
				kok.set_meta("gemi_sayisi", top)
				print("ISTGEMILER gemi=%d ertelendi" % top)
				return
			(isler.pop_front() as Callable).call(kok, lod))
		kok.set_meta("gemi_sayisi", 0)
		tree.process_frame.connect(adim[0])
		print("ISTGEMILER ertelendi kurulum_ms=%.0f" % ((Time.get_ticks_usec() - t0) / 1000.0))
		return kok
	build_filo_zincir(kok, lod)
	build_filo_halic_iskele(kok, lod)
	build_filo_galata(kok, lod)
	build_filo_cifte_sutunlar(kok, lod)
	build_filo_bogaz_agzi(kok, lod)
	build_filo_balikci(kok, lod)
	build_filo_marmara(kok, lod)
	if nisan20:
		build_filo_nisan20(kok, lod)
	var toplam := 0
	for c in kok.get_children():
		toplam += int(c.get_meta("gemi_sayisi", 0))
	print("ISTGEMILER gemi=%d kurulum_ms=%.0f" % [toplam, (Time.get_ticks_usec() - t0) / 1000.0])
	kok.set_meta("gemi_sayisi", toplam)
	return kok
