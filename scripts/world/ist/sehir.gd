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
static var YER := {
	# hipodrom (wip/ist-hipodrom): yan görev işaretleri ve bölümlerin anıt yerleri World1453.LANDMARKS'ta. Ayasofya
	# çevresi haritada sıkışık (gerçek 480 m → dünya 95 m): küçük anıtlar Ayasofya'nın, Hipodrom'un ve Augustaion'un
	# arasındaki boşluklara elle oturtuldu (gerçek sırayla: Milion ve Zeuksippos Augustaion ile Hipodrom arasında,
	# Khalke ve Nea sarayın önünde, Küçük Ayasofya Marmara'ya doğru).
	"hipodrom": {"lm": "hippodrome", "yaw_abs": 0.0, "quest": false},
	"buyuk_saray": {"lm": "great_palace"},
	"aya_irini": {"lm": "aya_irini"},
	"augustaion": {"lm": "augustaion"},
	"milion": {"x": -515.0, "z": -1405.0},
	"zeuksippos": {"x": -522.0, "z": -1352.0},
	"khalke": {"x": -511.0, "z": -1538.0},
	"nea": {"x": -508.0, "z": -1602.0},
	# forumlar (wip/ist-forumlar): modülün konumları araştırma dizininden 100–700 m sapıyordu (Arkadius ve Myrelaion
	# suya düşüyordu). Dizinde olanlar dizinden; olmayanlar bilinen yerinden (enlem/boylam, kestirim). Mese dilimi
	# CityPlan'ın Mese'sine hizalanmadan konmaz (sokağı kapatırdı).
	"mese": {"skip": true},
	"konstantin": {"lm": "column", "quest": false, "skip_regions": ["byz_aya"]},
	"tauri": {"lm": "forum_tauri"},
	"arkadius": {"e": -3444.0, "n": -956.0},
	"myrelaion": {"e": -1890.0, "n": -400.0},
	"markianos": {"e": -2243.0, "n": 902.0},
	"philadelphion": {"e": -1739.0, "n": 545.0},
	"kapitolion": {"e": -1800.0, "n": 480.0},
	"anemodoulion": {"e": -1700.0, "n": 330.0},
	"amastrianon": {"e": -2370.0, "n": 100.0},
	"bovis": {"e": -2705.0, "n": -11.0},
	# halic (wip/ist-halic): haritada Haliç kıyısı x −700'de düz bir çizgi; mahalleler kıyı surunun hemen içine, yerel +z
	# şehre (dünya +x) bakacak biçimde, gerçek sırayla (batıdan doğuya) dizildi. Kıyı suru, Eugenios/zincir, Petrion ve
	# Fener kapıları HornWorld'de duruyor (G6: kıyı suru değişimi sonraki tur): modülünkiler şimdilik kurulmaz.
	"halic_yahudi": {"x": -694.0, "z": -790.0, "yaw_abs": PI * 0.5},
	"halic_venedik": {"x": -694.0, "z": -905.0, "yaw_abs": PI * 0.5},
	"halic_balik": {"x": -694.0, "z": -1040.0, "yaw_abs": PI * 0.5},
	"halic_pisa_amalfi": {"x": -694.0, "z": -1180.0, "yaw_abs": PI * 0.5},
	"halic_neorion": {"x": -694.0, "z": -1290.0, "yaw_abs": PI * 0.5},
	"halic_iskele": {"x": -694.0, "z": -1370.0, "yaw_abs": PI * 0.5},
	"halic_ceneviz": {"x": -694.0, "z": -1452.0, "yaw_abs": PI * 0.5},
	# kemer (wip/ist-kemer): Bozdoğan modülü 970 m × k; haritadaki kemer (HornWorld) 156 m, uçları Havariyun ile üçüncü
	# tepe arasında: sığmıyor, bu turda HornWorld'ünki kalır. Aspar k 0,5 (gerçek 152 m).
	"bozdogan": {"skip": true},
	"havariyun": {"lm": "apostles", "quest": false},
	"pantokrator": {"lm": "pantokrator"},
	"aspar": {"k": 0.5},
	# kuzeybati (wip/ist-kuzeybati): Tekfur ve Anemas Blakherna surlarının üstünde (bölümün kendi surları ve sarayı
	# durur), bu turda kurulmaz. Aetios k 0,5.
	"khora": {"lm": "khora"},
	"pammakaristos": {"lm": "pammakaristos"},
	"tekfur": {"skip": true},
	"anemas": {"skip": true},
	"aetios": {"k": 0.5},
	# guneybati (wip/ist-guneybati): Studios eski yerinde; Altın Kapı kara surlarının parçası (surlar modülüyle birlikte)
	"studios": {"lm": "studios"},
	"altinkapi": {"skip": true},
	"halic_sur": {"skip": true},
	"halic_eugenios": {"skip": true},
	"halic_petrion": {"skip": true},
	"halic_fener": {"skip": true},
}

## Eski kaba yapının (Landmarks1453 anahtarı) yerini alan kimlikler: yeni kurulunca eskisi kurulmaz (çifte yapı yok)
const REPLACES := {
	"hipodrom": "hippodrome", "buyuk_saray": "great_palace", "aya_irini": "aya_irini", "augustaion": "augustaion",
	"konstantin": "forum_constantine", "tauri": "forum_tauri",
	"halic_venedik": "quay_venice", "havariyun": "apostles", "pantokrator": "pantokrator", "khora": "khora",
	"pammakaristos": "pammakaristos", "studios": "studios", "halic_pisa_amalfi": "quay_amalfi", "halic_ceneviz": "quay_genoa",
}
## Modülün bütünü bu turda kurulmaz (gerekçe raporda): galata → GalataView (HornWorld) ile aynı yerde çifte şehir olurdu
## surlar → kara surları ve kapıları SiegeField/LandWalls'ta (bölümlerin oynanış alanı; P02 sur şeridi göçüyle değişir)
const MOD_SKIP := ["galata", "galata_kule", "galata_ortak", "galata_sur", "galata_yapi", "surlar", "surlar_kapi", "surlar_ayrinti"]


static func _skipped(id: String, mod: String, region: String) -> bool:
	if mod in MOD_SKIP:
		return true
	var fix: Dictionary = YER.get(id, {})
	return fix.get("skip", false) or region in (fix.get("skip_regions", []) as Array)


## Landmarks1453.build için: yeni parçası şehre yerleşen eski anahtarlar
static func replaced(region := "") -> Array:
	var out: Array = []
	if not enabled:
		return out
	for e: Dictionary in catalog_all():
		if REPLACES.has(e["id"]) and not _skipped(String(e["id"]), String(e["mod"]), region):
			out.append(REPLACES[e["id"]])
	return out

static var active: IstSehir
static var KITS := {}                    # konumsuz kit öğeleri: kimlik → betik (bitki, ayrıntı)
static var _ids := {}
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
			if not methods.has(fn) or _ids.has(e["id"]):
				continue
			# Konumsuz kitaplık öğeleri (bitki, ayrıntı: dogu/kuzey 0) yerleşmez; mahalle dokusunda kullanılır (KITS)
			var tur := String(e.get("tur", ""))
			if e.get("yama", false) or (tur in ["bitki", "ayrinti"] and float(e.get("dogu_m", 0.0)) == 0.0 and float(e.get("kuzey_m", 0.0)) == 0.0):
				KITS[String(e["id"])] = scr
				continue
			_ids[e["id"]] = true
			_catalog.append({"id": e["id"], "mod": base, "script": scr, "data": e,
				"perch_fn": "perches_" + String(e["id"]) if methods.has("perches_" + String(e["id"])) else ""})
	return _catalog


## Kaydın dünyadaki yeri: {pos: Vector3, yaw: float (radyan, yerel −z'nin dünya yönü), k, r}
static func place_of(e: Dictionary) -> Dictionary:
	var data: Dictionary = e["data"]
	var id := String(e["id"])
	var fix: Dictionary = YER.get(id, {})
	var real := Vector2(float(data.get("dogu_m", 0.0)), float(data.get("kuzey_m", 0.0)))
	if fix.has("e"):
		real = Vector2(float(fix["e"]), float(fix["n"]))
	var w := CityGeo.real_to_world(real)
	var brg := deg_to_rad(float(data.get("yon_derece", 0.0)))
	var dirr := Vector2(sin(brg), cos(brg))
	var dw := CityGeo.real_to_world(real + dirr * 20.0) - w
	if fix.has("lm") and World1453.LANDMARKS.has(fix["lm"]):
		var lm: Vector3 = World1453.LANDMARKS[fix["lm"]]
		w = Vector2(lm.x, lm.z)
	if fix.has("x"):
		w = Vector2(float(fix["x"]), float(fix["z"]))
	w += Vector2(float(fix.get("dx", 0.0)), float(fix.get("dz", 0.0)))
	var yaw := atan2(-dw.x, -dw.y) + deg_to_rad(float(fix.get("yaw", 0.0)))
	if fix.has("yaw_abs"):
		yaw = float(fix["yaw_abs"])
	var k := float(fix.get("k", K_TUR.get(String(data.get("tur", "anit")), 0.5)))
	var s: Vector3 = data.get("gercek_olcu", Vector3(20, 10, 20))
	var r := maxf(s.x, s.z) * k * 0.5
	# Taban: küçük yapıda dört köşenin ve ortanın en alçağı (yamaçta havada kalmaz; yukarı yanı zemine gömülür); büyük
	# yapıda (r > 25 m) ortanca (kıyıya taşan bir köşe bütün yapıyı denize indirmesin)
	var hs: Array = []
	var u := Vector2(cos(-yaw), sin(-yaw))
	for o: Vector2 in [Vector2.ZERO, Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
		var q := w + Vector2(u.x * o.x * s.x * k * 0.45 - u.y * o.y * s.z * k * 0.45, u.y * o.x * s.x * k * 0.45 + u.x * o.y * s.z * k * 0.45)
		hs.append(World1453.surface_h(q.x, q.y))
	hs.sort()
	var y: float = hs[2] if r > 25.0 else hs[0]
	return {"pos": Vector3(w.x, y - 0.03, w.y), "yaw": yaw, "k": k, "r": r}


# ---------------------------------------------------------------- kurulum

## Dünyaya bağlar (World1453.build): f dünyanın SiegeField'i (yerel = dünya koordinatı)
static func attach(f: Node3D) -> IstSehir:
	if not enabled:
		return null
	var s := IstSehir.new()
	s.name = "IstSehir"
	s.field = f
	s.keep = (f.get("keep") as Array).duplicate() if f.get("keep") != null else []
	f.add_child(s)
	s._place_all()
	s._doku()
	active = s
	return s


func _region() -> String:
	return String(field.get("region_name")) if field and field.get("region_name") != null else ""


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
		if _skipped(id, String(e["mod"]), _region()):
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
	if it.has("make"):
		(it["make"] as Callable).call(n, lod)
	else:
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
		var d := Vector3(p.x - cp.x, (p.y - cp.y) * 1.3, p.z - cp.z).length() - float(it["r"])
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
		var d := Vector2(cc.x - cp.x, cc.z - cp.z).length() + maxf(0.0, cp.y - cc.y - 20.0) * 1.5
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
## Bütün İstanbul 1453 katmanını kapatır (ÖNCE kareleri ve karşılaştırma için)
static var enabled := true

## CityHouses.build'in yerine: aynı ev listesi (CityPlan), aynı yerler, mektup bölümünün ev dili. true dönerse
## CityHouses kendi evlerini kurmaz.
static func houses(parent: Node3D, list: Array, surf: Callable, free: Callable, nd: Dressing) -> bool:
	if not houses_on or not enabled:
		return false
	var host: IstSehir = null
	for c in parent.get_children():
		if c is IstSehir:
			host = c
	if host == null:
		host = IstSehir.new()
		host.name = "IstEvler"
		parent.add_child(host)
	var sf: Node = parent
	while sf != null and not (sf is SiegeField):
		sf = sf.get_parent()
	var region := String(sf.get("region_name")) if sf else ""
	var foot := footprints(region)
	var free2 := func(x: float, z: float, m: float) -> bool:
		for fp: Vector3 in foot:
			if Vector2(x - fp.x, z - fp.z).length() < fp.y + m:
				return false
		return free.call(x, z, m)
	host._houses(list, surf, free2, nd)
	return true


## Parçaların tabanları (dünya x, yarıçap, z): evler ve doku bunlara girmez
static func footprints(region: String) -> Array:
	var out: Array = []
	for e: Dictionary in catalog_all():
		if _skipped(String(e["id"]), String(e["mod"]), region):
			continue
		var pl := place_of(e)
		var p: Vector3 = pl["pos"]
		out.append(Vector3(p.x, float(pl["r"]) + 2.0, p.z))
	return out


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
		var key := "ev|%d|%s" % [v, tip]
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
	_layers(g0, g1, g2)
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


## Hücre grupları → katmanlar: uzak ve orta MultiMesh hemen, yakın hücreler akışla (_cell_up)
func _layers(g0: Dictionary, g1: Dictionary, g2: Dictionary) -> void:
	for ck: Vector2i in g2:
		for key: String in g2[ck]:
			var m2 := _mesh_for(key, 2)
			if m2:
				_mm(m2, g2[ck][key]).visibility_range_begin = MID
	for ck: Vector2i in g1:
		for key: String in g1[ck]:
			var mm := _mm(_mesh_for(key, 1), g1[ck][key])
			mm.visibility_range_begin = NEAR
			mm.visibility_range_end = MID if key.begins_with("ev|") else MID * 0.75
	for ck: Vector2i in g0:
		var cx := (ck.x + 0.5) * CELL0
		var cz := (ck.y + 0.5) * CELL0
		var cell := {"c": Vector3(cx, World1453.surface_h(cx, cz), cz), "groups": g0[ck], "mm": [], "col": null, "up": false}
		_cells0.append(cell)


## Grup anahtarı: "ev|örnek|tip" ya da "ag|tür" (IstBitki ağacı)
func _mesh_for(key: String, lod: int) -> Mesh:
	var p := key.split("|")
	if p[0] == "ev":
		return IstEvler.mesh(int(p[1]), p[2], lod)
	if KITS.has(p[1]):
		if lod >= 2:
			return null                     # ağaçlar uzakta çizilmez (orta katman MID'in 3/4'ünde biter)
		return (KITS[p[1]] as GDScript).call("tree_mesh", p[1], lod)
	return null


func _shapes_for(key: String) -> Array:
	var p := key.split("|")
	if p[0] == "ev":
		return IstEvler.shapes(int(p[1]), p[2])
	var cy := CylinderShape3D.new()
	cy.radius = 0.25
	cy.height = 2.0
	return [[cy, Transform3D(Basis.IDENTITY, Vector3(0, 1.0, 0))]]


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
		var mm := _mm(_mesh_for(key, 0), c["groups"][key])
		mm.visibility_range_end = NEAR
		c["mm"].append(mm)
		var shp := _shapes_for(key)
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


# ---------------------------------------------------------------- mahalle dokusu

const DOKU_CELL := 26.0
## Sık mahalleler (ISTANBUL_PLAN §2, dünya dikdörtgenleri): çarşı, Haliç iskeleleri, Ayasofya çevresi, hub, Petrion
const SIK := [Rect2(-700, -1500, 100, 650), Rect2(-520, -1360, 280, 380), Rect2(-700, -1720, 300, 360),
	Rect2(-140, -330, 320, 326), Rect2(-700, -820, 180, 440), Rect2(-420, -900, 220, 280)]
const AGAC_SIK := ["erguvan", "badem", "kiraz", "incir", "nar", "servi", "defne", "dut"]
const AGAC_SEYREK := ["zeytin", "servi", "cinar", "badem", "erguvan", "incir", "dut"]
const YAMA := ["bostan", "bag", "bugday", "cayir", "bahce"]

## Anıtların, CityPlan evlerinin ve sokaklarının arasındaki boş hücreler mahalle karakterine göre dolar: sık yerde
## bitişik sıra evler (aralık 0), seyrek yerde bostan, bağ, tarla, harabe, ağaç kümeleri (Nisan 1453: şehrin çoğu seyrek).
func _doku() -> void:
	if not houses_on:
		return
	var t0 := Time.get_ticks_usec()
	var occ := {}
	for h: Dictionary in CityPlan.houses_in(-INF, INF):
		var c: Vector2 = h["c"]
		occ[Vector2i(floori(c.x / 16.0), floori(c.y / 16.0))] = true
	for it: Dictionary in items:
		var p: Vector3 = it["pos"]
		var r := float(it["r"]) + 8.0
		for i in range(floori((p.x - r) / 16.0), floori((p.x + r) / 16.0) + 1):
			for j in range(floori((p.z - r) / 16.0), floori((p.z + r) / 16.0) + 1):
				occ[Vector2i(i, j)] = true
	var g0 := {}
	var g1 := {}
	var g2 := {}
	var nh := 0
	var nt := 0
	var np := 0
	var free_fn := Callable(field, "_free") if field and field.has_method("_free") else Callable()
	for i in range(floori(-700.0 / DOKU_CELL), ceili(700.0 / DOKU_CELL)):
		for j in range(floori(-1720.0 / DOKU_CELL), 0):
			var c := Vector2((i + 0.5) * DOKU_CELL, (j + 0.5) * DOKU_CELL)
			if not World1453.in_city(c.x, c.y, 14.0):
				continue
			var ok := true
			for a in range(-1, 2):
				for b in range(-1, 2):
					if occ.has(Vector2i(floori(c.x / 16.0) + a, floori(c.y / 16.0) + b)):
						ok = false
			if WallRear.in_band(c.x, c.y, 10.0) or _blocked(Vector3(c.x, 0, c.y), 14.0) or (free_fn.is_valid() and not free_fn.call(c.x, c.y, 10.0, true)):
				continue
			var rng := RandomNumberGenerator.new()
			rng.seed = hash(Vector2i(i, j)) ^ 1453
			if not ok or CityPlan.blocked(c.x, c.y, 13.0):
				# Sokak evlerinin arkasındaki adanın içi: bahçe ağaçları (ev ve yama konmaz: kapalı cep olmasın)
				if CityPlan.blocked(c.x, c.y, 4.0):
					continue
				for k in rng.randi_range(1, 3):
					var tp := Vector2(c.x + rng.randf_range(-9, 9), c.y + rng.randf_range(-9, 9))
					if CityPlan.blocked(tp.x, tp.y, 2.5) or _blocked(Vector3(tp.x, 0, tp.y), 2.0):
						continue
					_add(g0, g1, g2, "ag|" + String(AGAC_SIK[rng.randi() % AGAC_SIK.size()]), Transform3D(Basis(Vector3.UP, rng.randf() * TAU), Vector3(tp.x, World1453.surface_h(tp.x, tp.y) - 0.05, tp.y)))
					nt += 1
				continue
			var sik := false
			for r: Rect2 in SIK:
				if r.has_point(c):
					sik = true
			var roll := rng.randf()
			var hs := [World1453.surface_h(c.x - 10, c.y - 10), World1453.surface_h(c.x + 10, c.y - 10),
				World1453.surface_h(c.x - 10, c.y + 10), World1453.surface_h(c.x + 10, c.y + 10)]
			var lo: float = hs.min()
			var slope: float = hs.max() - lo
			if (sik and roll < 0.75) or (not sik and roll < 0.22):
				# Bitişik sıra evler: ortak duvar (aralık 0); cephe bir yana, arkası avlu/bahçe
				var yaw := rng.randi_range(0, 3) * PI * 0.5
				var bas := Basis(Vector3.UP, yaw)
				var n := rng.randi_range(2, 4) if sik else rng.randi_range(1, 2)
				var vs: Array = []
				var total := 0.0
				for k in n:
					var v := rng.randi_range(0, IstEvler.variant_count() - 1)
					vs.append(v)
					total += IstEvler.dims(v).x
				var x := -total * 0.5
				for v: int in vs:
					var dm := IstEvler.dims(v)
					var lp := bas * Vector3(x + dm.x * 0.5, 0, -dm.z * 0.5 + 4.0)
					x += dm.x
					var y := INF
					for o: Vector3 in [Vector3(-1, 0, -1), Vector3(1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, 1)]:
						var q := Vector3(c.x, 0, c.y) + lp + bas * (o * Vector3(dm.x * 0.5, 0, dm.z * 0.5))
						y = minf(y, World1453.surface_h(q.x, q.z))
					var tip := "dukkan" if (sik and rng.randf() < 0.35 and dm.x >= 6.0) else "sira"
					var xf := Transform3D(bas, Vector3(c.x + lp.x, y - 0.03, c.y + lp.z))
					_add(g0, g1, g2, "ev|%d|%s" % [v, tip], xf)
					nh += 1
				# avluda bir iki ağaç
				for k in rng.randi_range(0, 2):
					var tp := Vector3(c.x, 0, c.y) + bas * Vector3(rng.randf_range(-total * 0.4, total * 0.4), 0, -9.0 - rng.randf() * 3.0)
					_add(g0, g1, g2, "ag|" + AGAC_SIK[rng.randi() % AGAC_SIK.size()], Transform3D(Basis(Vector3.UP, rng.randf() * TAU), Vector3(tp.x, World1453.surface_h(tp.x, tp.z) - 0.05, tp.z)))
					nt += 1
			elif roll < (0.9 if sik else 0.62) and slope < 1.2 and KITS.has(YAMA[0]):
				# Bostan / bağ / tarla yaması (kendi kenar duvarı ve öğeleriyle), köşesinde ağaç
				var tur: String = YAMA[rng.randi() % YAMA.size()]
				var alan := Vector2(rng.randf_range(16.0, 24.0), rng.randf_range(16.0, 24.0))
				var it := {"id": "yama_%s_%d_%d" % [tur, i, j], "pos": Vector3(c.x, lo + 0.02, c.y), "yaw": 0.0, "k": 1.0,
					"r": alan.length() * 0.5, "have": [null, null, null], "data": {"tur": "bitki"}, "mod": "doku"}
				var scr: GDScript = KITS[tur] if KITS.has(tur) else KITS[YAMA[0]]
				var tohum := i * 31 + j
				it["make"] = func(n: Node3D, lod: int) -> void: scr.call("build_patch_" + tur, n, alan, 1.0, lod, tohum)
				_item(it)
				np += 1
			elif roll < (0.95 if sik else 0.78):
				# Harabe (yıkık ev), çevresinde ot ve ağaç
				var it := {"id": "harabe_%d_%d" % [i, j], "pos": Vector3(c.x, lo - 0.03, c.y), "yaw": rng.randi_range(0, 3) * PI * 0.5,
					"k": 1.0, "r": 6.0, "have": [null, null, null], "data": {"tur": "ev"}, "mod": "doku"}
				var tohum := i * 17 + j
				it["make"] = func(n: Node3D, lod: int) -> void: IstEvler.build_harabe(n, 1.0, lod, tohum)
				_item(it)
				np += 1
			# Ağaç kümesi (her boş hücrede birkaç; seyrek yerde daha çok)
			var list: Array = AGAC_SIK if sik else AGAC_SEYREK
			for k in rng.randi_range(1, 2 if sik else 5):
				var tp := Vector2(c.x + rng.randf_range(-13, 13), c.y + rng.randf_range(-13, 13))
				if CityPlan.blocked(tp.x, tp.y, 2.0):
					continue
				_add(g0, g1, g2, "ag|" + String(list[rng.randi() % list.size()]), Transform3D(Basis(Vector3.UP, rng.randf() * TAU), Vector3(tp.x, World1453.surface_h(tp.x, tp.y) - 0.05, tp.y)))
				nt += 1
	_layers(g0, g1, g2)
	print("ISTDOKU ev=%d agac=%d yama=%d hucre=%d kur_ms=%.1f" % [nh, nt, np, _cells0.size(), (Time.get_ticks_usec() - t0) / 1000.0])


func _add(g0: Dictionary, g1: Dictionary, g2: Dictionary, key: String, xf: Transform3D) -> void:
	if key.begins_with("ag|") and not KITS.has(key.substr(3)):
		return
	for pair: Array in [[g0, CELL0], [g1, CELL1], [g2, CELL2]]:
		var g: Dictionary = pair[0]
		var ck := Vector2i(floori(xf.origin.x / pair[1]), floori(xf.origin.z / pair[1]))
		if not g.has(ck):
			g[ck] = {}
		if not g[ck].has(key):
			g[ck][key] = []
		g[ck][key].append(xf)


## Dokunun tekil öğesi (yama, harabe): anıtlar gibi akışla kurulur (uzakta lod 2)
func _item(it: Dictionary) -> void:
	var holder := Node3D.new()
	holder.name = String(it["id"])
	holder.position = it["pos"]
	holder.rotation.y = float(it["yaw"])
	add_child(holder)
	it["holder"] = holder
	items.append(it)
	_build(it, 2)


# ---------------------------------------------------------------- Nihat'ın yan görevi

## catalog() kayıtlarında "gorev": true olan eserler: [KİMLİK, dünya bakış noktası (field yereli), yarıçap]
func quest_marks() -> Array:
	var out: Array = []
	for it: Dictionary in items:
		var d: Dictionary = it["data"]
		if not d.get("gorev", false) or not (YER.get(it["id"], {}) as Dictionary).get("quest", true):
			continue
		var s: Vector3 = d.get("gercek_olcu", Vector3(20, 20, 20))
		var h := it["holder"] as Node3D
		out.append([String(it["id"]).to_upper(), h.transform * Vector3(0, s.y * float(it["k"]) + 8.0, 0), float(d.get("bakis_r", 30.0))])
	return out


## Parçaların konma noktaları (perches_<id>): [ad, nokta (field yereli), yarıçap]; nokta lod 0'ın çarpışmalı yüzeyinde
## (Nihat yaklaşınca lod 0 kurulur)
func perch_marks() -> Array:
	var out: Array = []
	for it: Dictionary in items:
		if not it.has("script"):
			continue
		var fn := "perches_" + String(it["id"])
		var scr := it["script"] as GDScript
		var has := false
		for m: Dictionary in scr.get_script_method_list():
			if m["name"] == fn:
				has = true
				break
		if not has:
			continue
		var pts = scr.call(fn, float(it["k"]))
		if not (pts is Array) or (pts as Array).is_empty():
			continue
		var p0 = pts[0]
		if p0 is Array and (p0 as Array).size() > 0:
			p0 = p0[0]
		if not (p0 is Vector3):
			continue
		out.append(["ist_" + String(it["id"]), (it["holder"] as Node3D).transform * (p0 as Vector3), 4.0])
	return out
