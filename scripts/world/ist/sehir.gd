class_name IstSehir
extends Node3D
## İstanbul 1453 şehir kurucusu (docs/ISTANBUL_PLAN.md §6; arayüz docs/_ajan/gorev/_istanbul_ortak.md).
##
## 1. Parçalar: scripts/world/ist/<ad>*.gd modüllerinin catalog() kayıtları gerçek konumdan (Ayasofya 0,0; doğu/kuzey
##    metre) CityGeo.real_to_world ile dünyaya düşer; yön, dönüşümün o noktadaki kuzey yönünden; ölçek k (YER tablosu).
##    Her kayıt bir tutucu düğüm: uzakta lod 2 (siluet), yaklaşınca lod 1, yakında lod 0 (tam ayrıntı + çarpışma).
##    Kurma zaman dilimli (kare başına BUDGET_US), yeni katman kurulmadan eskisi gizlenmez (delik/birden belirme yok),
##    uzaklaşınca ince katman boşaltılır (kurma ve boşaltma eşikleri arasında HYST payı).
## 2. Evler: CityPlan'ın ev listesi (CityHouses'ın yerine) mektup bölümünün ev diliyle (IstEvler): hücre başına
##    örnek × katman MultiMesh; çarpışma oyuncunun çevresindeki hücrelerde (akışla).
## 3. Bölümlerin oynanış alanları (SiegeField.keep: bölge dikdörtgenleri ve FAR_REGIONS) boş kalır.
##
## Bağlantı: World1453.build → IstSehir.attach(f); CityHouses.build → IstSehir.houses(...) (ikisi de tek satır ekleme).

const DIR := "res://scripts/world/ist/"
const SELF := ["sehir", "evler"]
## Uzaklık eşikleri (parçanın yarıçapı eklenir): lod 0 < R0, lod 1 < R1, ötesi lod 2
const R0 := 90.0
const R1 := 520.0
const HYST := 25.0
const BUDGET_US := 6000
## Türe göre oyun ölçeği (yapının kütlesi; insan ölçüsü k'den bağımsız). Dünya gerçeğin ≈ 1/3,5'i (CityGeo): anıtlar
## yarı ölçekte (tanınır ve yürünür), sıradan yapılar tam boy.
const K_TUR := {"anit": 0.5, "kilise": 0.5, "kapi": 0.6, "sur": 0.5, "liman": 0.5, "ev": 1.0, "ayrinti": 1.0, "bitki": 1.0}
## Yerleştirme tablosu: kimlik → düzeltme. "k": ölçek, "lm": World1453.LANDMARKS anahtarına oturt (yan görev işareti ve
## eski konumla aynı yer), "dx"/"dz": dünya metresi kaydırma, "yaw": derece (dünya yönüne ek), "skip": kurma,
## "old": yerine geçtiği eski kaba yapı (Landmarks1453 anahtarı; yeni kurulunca eskisi kurulmaz)
static var YER := {}

## Eski kaba yapının (Landmarks1453) yerini alan kimlikler: anahtar → eski anahtar (modüller geldikçe doldurulur)
static var REPLACES := {}

static var active: IstSehir
static var _catalog: Array = []          # [{id, mod, data}]
static var _scanned := false

var field: Node3D
var keep: Array = []
var items: Array = []                    # {id, script, pos, yaw, k, r, have: [Node3D x3], want, data}
var _queue: Array = []
var _cells0: Array = []                  # ev hücreleri: {c: Vector3, mm: [MultiMeshInstance3D], col: StaticBody3D, list: []}
var _last_cam := Vector3.INF
var _t := 0.0
var stats := {"kur_ms_max": 0.0, "kur_n": 0}


# ---------------------------------------------------------------- modüller

## scripts/world/ist altındaki modüller (evler ve sehir hariç) ve kayıtları. Bir kez taranır.
static func catalog_all() -> Array:
	if _scanned:
		return _catalog
	_scanned = true
	var names: Array = []
	var d := DirAccess.open(DIR)
	if d == null:
		return _catalog
	for f in d.get_files():
		var nm := f.trim_suffix(".remap")
		if not nm.ends_with(".gd"):
			continue
		var base := nm.trim_suffix(".gd")
		if base in SELF or base in names:
			continue
		names.append(base)
	names.sort()
	for base: String in names:
		var scr := load(DIR + base + ".gd") as GDScript
		if scr == null:
			continue
		var methods := {}
		for m: Dictionary in scr.get_script_method_list():
			methods[m["name"]] = true
		if not methods.has("catalog"):
			continue
		var cat = scr.call("catalog")
		if not (cat is Array):
			continue
		for e in cat:
			if not (e is Dictionary) or not e.has("id"):
				continue
			var fn := "build_" + String(e["id"])
			if not methods.has(fn):
				continue
			_catalog.append({"id": e["id"], "mod": base, "script": scr, "data": e,
				"perch_fn": "perches_" + String(e["id"]) if methods.has("perches_" + String(e["id"])) else ""})
	return _catalog


## Kaydın dünyadaki yeri: {pos: Vector3, yaw: float (radyan, yerel −z'nin dünya yönü), k, r}
static func place_of(e: Dictionary) -> Dictionary:
	var data: Dictionary = e["data"]
	var id := String(e["id"])
	var fix: Dictionary = YER.get(id, {})
	var real := Vector2(float(data.get("dogu_m", 0.0)), float(data.get("kuzey_m", 0.0)))
	var w := CityGeo.real_to_world(real)
	var brg := deg_to_rad(float(data.get("yon_derece", 0.0)))
	var dirr := Vector2(sin(brg), cos(brg))
	var dw := CityGeo.real_to_world(real + dirr * 20.0) - w
	if fix.has("lm") and World1453.LANDMARKS.has(fix["lm"]):
		var lm: Vector3 = World1453.LANDMARKS[fix["lm"]]
		w = Vector2(lm.x, lm.z)
	w += Vector2(float(fix.get("dx", 0.0)), float(fix.get("dz", 0.0)))
	var yaw := atan2(-dw.x, -dw.y) + deg_to_rad(float(fix.get("yaw", 0.0)))
	var k := float(fix.get("k", K_TUR.get(String(data.get("tur", "anit")), 0.5)))
	var s: Vector3 = data.get("gercek_olcu", Vector3(20, 10, 20))
	var r := maxf(s.x, s.z) * k * 0.5
	# Taban: dört köşenin ve ortanın en alçağı (yamaçta havada kalmaz; yukarı yanı zemine gömülür)
	var y := INF
	var u := Vector2(cos(-yaw), sin(-yaw))
	for o: Vector2 in [Vector2.ZERO, Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
		var q := w + Vector2(u.x * o.x * s.x * k * 0.45 - u.y * o.y * s.z * k * 0.45, u.y * o.x * s.x * k * 0.45 + u.x * o.y * s.z * k * 0.45)
		y = minf(y, World1453.surface_h(q.x, q.y))
	return {"pos": Vector3(w.x, y - 0.03, w.y), "yaw": yaw, "k": k, "r": r}


# ---------------------------------------------------------------- kurulum

## Dünyaya bağlar (World1453.build): f dünyanın SiegeField'i (yerel = dünya koordinatı)
static func attach(f: Node3D) -> IstSehir:
	var s := IstSehir.new()
	s.name = "IstSehir"
	s.field = f
	s.keep = (f.get("keep") as Array).duplicate() if f.get("keep") != null else []
	f.add_child(s)
	s._place_all()
	active = s
	return s


func _blocked(p: Vector3, r: float) -> bool:
	for kr: Rect2 in keep:
		if kr.grow(r * 0.7).has_point(Vector2(p.x, p.z)):
			return true
	return false


func _place_all() -> void:
	var t0 := Time.get_ticks_usec()
	for e: Dictionary in catalog_all():
		var id := String(e["id"])
		var fix: Dictionary = YER.get(id, {})
		if fix.get("skip", false):
			continue
		var pl := place_of(e)
		var p: Vector3 = pl["pos"]
		var tur := String((e["data"] as Dictionary).get("tur", ""))
		if World1453.is_water(p.x, p.z) and tur != "liman" and not fix.get("water_ok", false):
			continue
		if _blocked(p, float(pl["r"])):
			continue
		var holder := Node3D.new()
		holder.name = "Ist_" + id
		holder.position = p
		holder.rotation.y = float(pl["yaw"])
		holder.set_meta("ist_id", id)
		add_child(holder)
		var it := {"id": id, "script": e["script"], "pos": p, "yaw": pl["yaw"], "k": pl["k"], "r": pl["r"],
			"have": [null, null, null], "holder": holder, "data": e["data"], "mod": e["mod"]}
		items.append(it)
		# Uzak siluet hemen (ucuz): her yerden bakınca şehir boşluksuz
		_build(it, 2)
	print("ISTSEHIR yer=%d kur_ms=%.1f" % [items.size(), (Time.get_ticks_usec() - t0) / 1000.0])


func _build(it: Dictionary, lod: int) -> void:
	if it["have"][lod] != null:
		return
	var n := Node3D.new()
	n.name = "L%d" % lod
	(it["holder"] as Node3D).add_child(n)
	var t0 := Time.get_ticks_usec()
	(it["script"] as GDScript).call("build_" + String(it["id"]), n, float(it["k"]), lod)
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	stats["kur_ms_max"] = maxf(stats["kur_ms_max"], ms)
	stats["kur_n"] += 1
	if lod > 0:
		for c in n.find_children("*", "GeometryInstance3D", true, false):
			c.set_meta("no_walk", true)
	it["have"][lod] = n
	_show(it)


## En ince kurulu katman görünür, ötekiler gizli (kurulmadan önce eskisi gizlenmez)
func _show(it: Dictionary) -> void:
	var want := int(it.get("want", 2))
	var best := -1
	for l in range(want, 3):
		if it["have"][l] != null:
			best = l
			break
	if best < 0:
		for l in range(want - 1, -1, -1):
			if it["have"][l] != null:
				best = l
				break
	for l in 3:
		var n: Node3D = it["have"][l]
		if n != null:
			n.visible = l == best
			# Çarpışma yalnız lod 0'da (görünmezken de dursun: üstünde duran oyuncu düşmesin, ama yalnız yakında kurulu)


func _cam_pos() -> Vector3:
	var vp := get_viewport()
	if vp == null:
		return Vector3.INF
	var cam := vp.get_camera_3d()
	if cam == null:
		return Vector3.INF
	return to_local(cam.global_position)


func _process(delta: float) -> void:
	var cp := _cam_pos()
	if cp == Vector3.INF:
		return
	_t -= delta
	if _t <= 0.0 or cp.distance_to(_last_cam) > 12.0:
		_t = 0.25
		_last_cam = cp
		_plan(cp)
	var t0 := Time.get_ticks_usec()
	while not _queue.is_empty() and Time.get_ticks_usec() - t0 < BUDGET_US:
		var job: Array = _queue.pop_front()
		if job[0] == "item":
			var it: Dictionary = job[1]
			if int(it["want"]) <= int(job[2]):
				_build(it, int(job[2]))
		elif job[0] == "cell":
			_cell_up(job[1])


func _plan(cp: Vector3) -> void:
	_queue.clear()
	var jobs: Array = []
	for it: Dictionary in items:
		var p: Vector3 = it["pos"]
		var d := Vector2(p.x - cp.x, p.z - cp.z).length() - float(it["r"])
		var want := 0 if d < R0 else (1 if d < R1 else 2)
		it["want"] = want
		# Boşalt: payın ötesindeki ince katmanlar
		for l in 2:
			var lim := R0 if l == 0 else R1
			if it["have"][l] != null and d > lim + HYST and want > l:
				(it["have"][l] as Node3D).queue_free()
				it["have"][l] = null
		if it["have"][want] == null:
			jobs.append([d, ["item", it, want]])
			if want == 0 and it["have"][1] == null:
				jobs.append([d - 0.1, ["item", it, 1]])
		_show(it)
	for c: Dictionary in _cells0:
		var cc: Vector3 = c["c"]
		var d := Vector2(cc.x - cp.x, cc.z - cp.z).length()
		if d < 150.0 and not c["up"]:
			jobs.append([d, ["cell", c]])
		elif d > 210.0 and c["up"]:
			_cell_down(c)
	jobs.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for j: Array in jobs:
		_queue.append(j[1])


# ---------------------------------------------------------------- evler (CityHouses'ın yerine)

const CELL0 := 48.0
const CELL1 := 144.0
const CELL2 := 400.0
const NEAR := 70.0
const MID := 430.0
static var houses_on := true

## CityHouses.build'in yerine: aynı ev listesi (CityPlan), aynı yerler, mektup bölümünün ev dili. true dönerse
## CityHouses kendi evlerini kurmaz.
static func houses(parent: Node3D, list: Array, surf: Callable, free: Callable, nd: Dressing) -> bool:
	if not houses_on:
		return false
	var host: IstSehir = null
	for c in parent.get_children():
		if c is IstSehir:
			host = c
	if host == null:
		host = IstSehir.new()
		host.name = "IstEvler"
		parent.add_child(host)
	host._houses(list, surf, free, nd)
	return true


func _houses(list: Array, surf: Callable, free: Callable, nd: Dressing) -> void:
	var t0 := Time.get_ticks_usec()
	var g0 := {}           # Vector2i hücre → {"v|tip": [xf]}
	var g1 := {}
	var g2 := {}
	var n := 0
	for h: Dictionary in list:
		var c: Vector2 = h["c"]
		var v: int = int(h.get("v", 0)) % IstEvler.variant_count()
		var dm := IstEvler.dims(v)
		var r := maxf(dm.x, dm.z) * 0.5
		if not free.call(c.x, c.y, r + 2.0):
			continue
		var away: Vector2 = h["away"]
		var yaw := atan2(-away.x, -away.y)            # yerel +z (cephe) sokağa
		var st := LowPoly.seat(c.x, c.y, r * 0.85, r * 0.85, surf)
		var y := st.x - 0.02
		# Yamaçta evin altında taş kaide: gövde zemine kadar iner (havada kalmaz)
		var tip := "dukkan" if (hash(Vector2i(int(c.x), int(c.y))) % 5 < 2 and dm.x >= 6.0) else "sira"
		var xf := Transform3D(Basis(Vector3.UP, yaw), Vector3(c.x, y, c.y))
		var key := "%d|%s" % [v, tip]
		for pair: Array in [[g0, CELL0], [g1, CELL1], [g2, CELL2]]:
			var g: Dictionary = pair[0]
			var ck := Vector2i(floori(c.x / pair[1]), floori(c.y / pair[1]))
			if not g.has(ck):
				g[ck] = {}
			if not g[ck].has(key):
				g[ck][key] = []
			g[ck][key].append(xf)
		if st.y > 0.3:
			_plinth(xf, dm, st.y)
		if n % 4 == 0:
			var f := c - away * (dm.z * 0.5 + 0.08)
			nd.at(Vector3(f.x, y + 2.3, f.y), yaw).glow(Vector3(0.1, 0.45, 0.32), Vector3.ZERO, Color("ffc870"))
		n += 1
	nd.at(Vector3.ZERO)
	# Uzak (lod 2) ve orta (lod 1): hemen; yakın (lod 0): ağı yaklaşınca pişirilir
	for ck: Vector2i in g2:
		for key: String in g2[ck]:
			var mm := _mm(IstEvler.mesh(int(key.get_slice("|", 0)), key.get_slice("|", 1), 2), g2[ck][key])
			mm.visibility_range_begin = MID
	for ck: Vector2i in g1:
		for key: String in g1[ck]:
			var mm := _mm(IstEvler.mesh(int(key.get_slice("|", 0)), key.get_slice("|", 1), 1), g1[ck][key])
			mm.visibility_range_begin = NEAR
			mm.visibility_range_end = MID
	for ck: Vector2i in g0:
		var cell := {"c": Vector3((ck.x + 0.5) * CELL0, 0, (ck.y + 0.5) * CELL0), "groups": g0[ck], "mm": [], "col": null, "up": false}
		_cells0.append(cell)
	print("ISTEVLER ev=%d hucre=%d kur_ms=%.1f" % [n, _cells0.size(), (Time.get_ticks_usec() - t0) / 1000.0])
	# Başlangıçta oyuncunun yakınındaki hücreler eşzamanlı (yükleme: bölge merkezi)
	var rp := Vector3.ZERO
	var sf := get_parent()
	while sf != null and not (sf is SiegeField):
		sf = sf.get_parent()
	if sf is SiegeField:
		rp = (sf as Node3D).transform.affine_inverse().origin
	for c: Dictionary in _cells0:
		var cc: Vector3 = c["c"]
		if Vector2(cc.x - rp.x, cc.z - rp.z).length() < 110.0:
			_cell_up(c)


## Yamaçta evin altındaki taş kaide (yalnız eğimli yerde)
func _plinth(xf: Transform3D, dm: Vector3, drop: float) -> void:
	var b := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(dm.x, drop + 0.4, dm.z)
	b.mesh = bm
	b.transform = xf * Transform3D(Basis.IDENTITY, Vector3(0, -(drop + 0.4) * 0.5 + 0.2, 0))
	b.material_override = Props.mat(Color("d8ccb8"), 0.0, false, "ashlar")
	b.visibility_range_end = MID
	add_child(b)


func _mm(m: Mesh, xfs: Array) -> MultiMeshInstance3D:
	var c := Vector3.ZERO
	for x: Transform3D in xfs:
		c += x.origin
	c /= xfs.size()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = m
	mm.instance_count = xfs.size()
	var local: Array = []
	for i in xfs.size():
		var lx := Transform3D((xfs[i] as Transform3D).basis, (xfs[i] as Transform3D).origin - c)
		local.append(lx)
		mm.set_instance_transform(i, lx)
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.position = c
	mi.set_meta("no_walk", true)
	mi.set_meta("xforms", local)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


## Yakın hücre: tam ayrıntılı ev ağı (MultiMesh) ve evlerin çarpışması
func _cell_up(c: Dictionary) -> void:
	if c["up"]:
		return
	c["up"] = true
	var t0 := Time.get_ticks_usec()
	var body := StaticBody3D.new()
	body.name = "EvCarpisma"
	add_child(body)
	for key: String in c["groups"]:
		var v := int(key.get_slice("|", 0))
		var tip := key.get_slice("|", 1)
		var mm := _mm(IstEvler.mesh(v, tip, 0), c["groups"][key])
		mm.visibility_range_end = NEAR
		c["mm"].append(mm)
		var shp := IstEvler.shapes(v, tip)
		for xf: Transform3D in c["groups"][key]:
			for s: Array in shp:
				var cs := CollisionShape3D.new()
				cs.shape = s[0]
				cs.transform = xf * (s[1] as Transform3D)
				body.add_child(cs)
	c["col"] = body
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	stats["kur_ms_max"] = maxf(stats["kur_ms_max"], ms)


func _cell_down(c: Dictionary) -> void:
	if not c["up"]:
		return
	c["up"] = false
	for mm: Node in c["mm"]:
		mm.queue_free()
	c["mm"] = []
	if c["col"] != null:
		(c["col"] as Node).queue_free()
		c["col"] = null


# ---------------------------------------------------------------- Nihat'ın yan görevi

## catalog() kayıtlarında "gorev": true olan eserler: [KİMLİK, dünya bakış noktası (field yereli), yarıçap]
func quest_marks() -> Array:
	var out: Array = []
	for it: Dictionary in items:
		var d: Dictionary = it["data"]
		if not d.get("gorev", false):
			continue
		var s: Vector3 = d.get("gercek_olcu", Vector3(20, 20, 20))
		var h := it["holder"] as Node3D
		out.append([String(it["id"]).to_upper(), h.transform * Vector3(0, s.y * float(it["k"]) + 8.0, 0), float(d.get("bakis_r", 30.0))])
	return out
