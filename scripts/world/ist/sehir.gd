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
	# forum döşemeleri meydanda (CityPlan meydanı, CityLife sivilleri yürür): döşeme yüzeyi arazi hizasına iner
	# Konstantin: modülün sütun kaidesi eski sütunun (ByzCity.COLUMN) kaidesinden geniş, CityLife devriyesinin meydan yoluna
	# taşıyor (city_check: devriye "evin içinde"); bu turda eskisi kalır
	"konstantin": {"lm": "column", "quest": false, "skip": true, "dy": -1.0},
	"tauri": {"lm": "forum_tauri", "dy": -0.5},
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
	# Lykos köprüsü: haritada Lykos deresi yok; lod 1 çarpışması tutucunun dışına düşüyor (hub'da VISAUDIT), kurulmaz
	"kopru": {"skip": true},
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
var _cost := {}                          # "mod/lod" → son kurma süresi (ms)


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
	return {"pos": Vector3(w.x, y - 0.03 + float(fix.get("dy", 0.0)), w.y), "yaw": yaw, "k": k, "r": r}


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
		_perch_pad(it)
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
	_cost["%s/%d" % [String(it.get("mod", "")), lod]] = ms
	if ms > 6.0:
		if not stats.has("yavas"):
			stats["yavas"] = {}
		var key := "%s/%d" % [String(it["mod"]) if String(it["mod"]) != "v2" else String(it["id"]).get_slice("_", 0), lod]
		stats["yavas"][key] = maxf(float(stats["yavas"].get(key, 0.0)), ms)
	if lod > 0:
		_bake_lod(n, lod >= 2)
		for c in n.find_children("*", "GeometryInstance3D", true, false):
			c.set_meta("no_walk", true)
	elif v2:
		# v2 yakın katman: görüntü doku başına pişirilir (çizim sayısı), çarpışma gövdeleri olduğu gibi kalır
		_bake_lod(n, false)
	it["have"][lod] = n
	_show(it)


## Uzak/orta katmanın ilkel parçaları tek ağa pişirilir (World1453.bake: doku başına bir yüzey; uzakta tek yüzey):
## yüzlerce çizim yerine bir iki. Çarpışma gövdeleri ve MultiMesh'ler olduğu gibi kalır.
func _bake_lod(n: Node3D, flat: bool) -> void:
	var list: Array = []
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh != null and mi.visible and _bakeable(mi, n):
			list.append(mi)
	if list.size() < 3:
		return
	var holder := Node3D.new()
	var mi := World1453.bake(list, n, Transform3D.IDENTITY, holder, "Pismis", 0.05 if flat else 0.03, 0, flat)
	holder.remove_child(mi)
	holder.free()
	if mi.mesh == null:
		mi.free()
		return
	for c: MeshInstance3D in list:
		c.get_parent().remove_child(c)
		c.queue_free()
	n.add_child(mi)


## Pişiriciye girecek parça: gölgelendiricili, saydam, ışıklı, gizli ya da insan (Person) altındaki parçalar kalır
static func _bakeable(mi: MeshInstance3D, top: Node) -> bool:
	var cur: Node = mi
	while cur != null and cur != top:
		if cur is Person or (cur is Node3D and not (cur as Node3D).visible):
			return false
		cur = cur.get_parent()
	for si in mi.mesh.get_surface_count():
		var m := mi.get_active_material(si)
		if m is ShaderMaterial:
			return false
		if m is BaseMaterial3D:
			var bm := m as BaseMaterial3D
			if bm.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and bm.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR:
				return false
			if bm.emission_enabled and bm.emission_energy_multiplier > 0.5:
				return false
	return true


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
		var job: Array = _queue.front()
		# Ağır iş (önceki ölçümü bütçenin kalanını aşan) karenin başına ertelenir: aynı karede ikinci iş olmaz
		if Time.get_ticks_usec() - t0 > 0 and job[0] == "item":
			var key := "%s/%d" % [String(job[1]["mod"]), int(job[2])]
			if float(_cost.get(key, 0.0)) * 1000.0 > BUDGET_US - (Time.get_ticks_usec() - t0) and Time.get_ticks_usec() - t0 > 300:
				break
		_queue.pop_front()
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
		var r1 := float(it.get("r1", R1))
		var want := 0 if d < R0 else (1 if d < r1 else 2)
		it["want"] = want
		# Boşalt: payın ötesindeki ince katmanlar
		for l in 2:
			var lim := R0 if l == 0 else r1
			if it["have"][l] != null and d > lim + HYST and want > l:
				(it["have"][l] as Node3D).queue_free()
				it["have"][l] = null
		if want == 2 and it.get("no2", false):
			_show(it)
			continue
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
static var enabled := false            # eski dünyada (World1453) KAPALI: v2 kendi girişinden (attach_v2) açar

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
		var cell := {"c": Vector3(cx, _hh(cx, cz), cz), "groups": g0[ck], "mm": [], "col": null, "up": false}
		_cells0.append(cell)


## Grup anahtarı: "ev|örnek|tip" ya da "ag|tür" (IstBitki ağacı)
func _mesh_for(key: String, lod: int) -> Mesh:
	var p := key.split("|")
	if key == "kaide":
		if _kaide_mesh == null:
			_kaide_mesh = _unit_box(Color("d8ccb8"), "ashlar")
		return _kaide_mesh
	if key == "tas":
		if lod >= 2:
			return null
		if _tas_mesh == null:
			_tas_mesh = _unit_box(Color("b8ae9c"), "flagstone")
		return _tas_mesh
	if p[0] == "ev":
		return IstEvler.mesh(int(p[1]), p[2], lod)
	if p.size() > 1 and KITS.has(p[1]):
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
	if v2:
		# v2: evler, kaideler ve sokak taşları hücre başına tek ağ (malzeme başına bir yüzey); ağaçlar MultiMesh
		var mi := _merge_groups(c["groups"], 0, c["c"])
		if mi:
			mi.visibility_range_end = NEAR
			c["mm"].append(mi)
	for key: String in c["groups"]:
		if not (v2 and _mergeable(key)):
			var mm := _mm(_mesh_for(key, 0), c["groups"][key])
			mm.visibility_range_end = NEAR
			c["mm"].append(mm)
		if key == "kaide" or key == "tas":
			for xf: Transform3D in c["groups"][key]:
				var bcs := CollisionShape3D.new()
				var bb := BoxShape3D.new()
				bb.size = xf.basis.get_scale()
				bcs.shape = bb
				bcs.transform = Transform3D(xf.basis.orthonormalized(), xf.origin)
				body.add_child(bcs)
			continue
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


## Yan görev eserinin konma noktası her uzaklıkta katıdır (lod 0 kurulmadan Nihat konabilsin): noktanın altında ince,
## görünmez bir kapak (yapının kendi tepesinin içinde kalır)
func _perch_pad(it: Dictionary) -> void:
	if not (it["data"] as Dictionary).get("gorev", false):
		return
	var p := _perch_local(it)
	if p == Vector3.INF:
		return
	var body := StaticBody3D.new()
	body.name = "Konma_" + String(it["id"])
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.4, 0.3, 1.4)
	cs.shape = bs
	body.add_child(cs)
	body.position = (it["holder"] as Node3D).transform * p - Vector3(0, 0.15, 0)
	add_child(body)
	it["perch"] = (it["holder"] as Node3D).transform * p


func _perch_local(it: Dictionary) -> Vector3:
	if not it.has("script"):
		return Vector3.INF
	var fn := "perches_" + String(it["id"])
	var scr := it["script"] as GDScript
	var has := false
	for m: Dictionary in scr.get_script_method_list():
		if m["name"] == fn:
			has = true
			break
	if not has:
		return Vector3.INF
	var pts = scr.call(fn, float(it["k"]))
	if not (pts is Array) or (pts as Array).is_empty():
		return Vector3.INF
	var p0 = pts[0]
	if p0 is Array and (p0 as Array).size() > 0:
		p0 = p0[0]
	return p0 if p0 is Vector3 else Vector3.INF


## Parçaların konma noktaları (perches_<id>): [ad, nokta (field yereli), yarıçap]; nokta lod 0'ın çarpışmalı yüzeyinde
## (Nihat yaklaşınca lod 0 kurulur)
func perch_marks() -> Array:
	var out: Array = []
	for it: Dictionary in items:
		if it.has("perch"):
			out.append(["ist_" + String(it["id"]), it["perch"], 4.0])
	return out


# ================================================================ İSTANBUL v2 (yeni dünya; docs/_ajan/gorev/_ist2_ortak.md)
#
# Gerçek koordinat (Ayasofya 0,0) → IstGeo.w(e, n) (yarı ölçek, bükmesiz). Anıtlar k = 0,5; evler ve sokaklar 1:1.
# Eski dünyaya (World1453, CityPlan, CityGeo) bağlı hiçbir şey kullanılmaz; yükseklik IstGeo.h.

static var v2 := false
static var sokak: IstSokak
const K2 := 0.5
## v2 orta katman yarıçapı (yarıçap eklenir): uzak siluetten orta katmana geçiş
const R1_V2 := 300.0
## v2'de kayıttan kurulmayan modüller: kiliseler tip örnekleridir (konumları kestirim; mahalle dokusunda kullanılır)
const MOD_SKIP2 := ["kiliseler", "kiliseler_kilise", "kiliseler_harabe", "kiliseler_manastir", "kiliseler_ortak"]
## Uzun hatlarla kurulanlar: tek kayıt olarak kurulmaz
const HAT_IDS := ["sur", "msur", "halic_sur", "mese", "bozdogan", "mesoteikhion"]

## v2 yer tablosu (gerçek doğu/kuzey metre). Modül dosyalarına dokunulmaz; sapmalar burada düzeltilir (gerekçe raporda,
## parça adıyla). "kiyi": kıyı suruna göre içeri oturt (dünya metresi), "hat": surun üstüne oturt ve yönünü surdan al,
## "skip": kurma (gerekçe yanında), "yon": yönü değiştir (derece).
static var YER2 := {
	# forumlar: dizindeki yerler (ISTANBUL_YERLER.csv) ve bilinen enlem/boylamlar (kestirim)
	"konstantin": {"e": -756.0, "n": -11.0},
	"tauri": {"e": -1554.0, "n": 211.0},
	"arkadius": {"e": -3444.0, "n": -956.0},
	"myrelaion": {"e": -1890.0, "n": -400.0},
	"philadelphion": {"e": -1739.0, "n": 545.0},
	"kapitolion": {"e": -1800.0, "n": 470.0},
	"anemodoulion": {"e": -1660.0, "n": 300.0},
	"amastrianon": {"e": -2370.0, "n": 100.0},
	"bovis": {"e": -2705.0, "n": -11.0},
	"markianos": {"e": -2560.0, "n": 900.0},
	# hipodrom: Hipodrom ve Milion, Küçük Ayasofya dizinden / enlem-boylamdan
	"hipodrom": {"e": -400.0, "n": -300.0},
	"milion": {"e": -250.0, "n": -25.0},
	"sergios": {"e": -487.0, "n": -657.0},
	"aya_irini": {"e": 70.0, "n": 95.0},
	# kemer: Fatih (Havariyun), Zeyrek (Pantokrator), Saraçhane (Polyeuktos), Fenari İsa (Lips), Vefa, Eski İmaret, Gül,
	# Aspar (Sultan Selim çukurbostanı)
	"havariyun": {"e": -2540.0, "n": 1210.0},
	"pantokrator": {"e": -2024.0, "n": 1414.0},
	"polyeuktos": {"e": -2285.0, "n": 801.0},
	"lips": {"e": -2957.0, "n": 1013.0},
	"vefa": {"e": -1571.0, "n": 880.0},
	"pantepoptes": {"e": -2075.0, "n": 1670.0},
	"gul": {"e": -2134.0, "n": 2126.0},
	"aspar": {"e": -2705.0, "n": 1915.0},
	# kuzeybati: Tekfur, Anemas, Ayazma (Blakhernai Meryem), Aetios (Karagümrük)
	"tekfur": {"e": -3335.0, "n": 2827.0},
	"anemas": {"e": -3251.0, "n": 3384.0},
	"blakhernai_kilise": {"e": -3170.0, "n": 3220.0},
	"aetios": {"e": -3420.0, "n": 1880.0},
	"kaligaria": {"e": -2980.0, "n": 2760.0},
	# guneybati: Studios (İmrahor) dizinden, Andreas (Koca Mustafa Paşa), Mokios (Altımermer), Samatya
	"studios": {"e": -4495.0, "n": -1790.0},
	"andreas": {"e": -3940.0, "n": -570.0},
	"mokios": {"e": -3600.0, "n": -450.0},
	"psamathia": {"e": -3377.0, "n": -1124.0},
	"peribleptos": {"e": -3050.0, "n": -1250.0},
	"diomedes": {"e": -4500.0, "n": -1550.0},
	"altinkapi": {"skip": true},                  # surlar/altin_kapi ile aynı yer: çifte yapı olurdu (surlarınki seçildi)
	"kopru": {"e": -3150.0, "n": -500.0},
	"degirmen": {"e": -3350.0, "n": -650.0},
	# marmara: Kadırga (Kontoskalion), Langa, Mermer Kule (kara surunun deniz ucu), Ahırkapı
	"kontoskalion": {"e": -941.0, "n": -650.0, "kiyi": "marmara_suru"},
	"langa": {"e": -2540.0, "n": -700.0, "kiyi": "marmara_suru"},
	"mermerkule": {"hat": "kara_suru", "uc": 0},
	"ahirkapi": {"e": 109.0, "n": -568.0, "kiyi": "marmara_suru"},
	"sophia": {"kiyi": "marmara_suru"},
	"bukoleon": {"e": -437.0, "n": -846.0, "kiyi": "marmara_suru"},
	"kayikhane": {"kiyi": "marmara_suru"},
	"balikci": {"e": -3600.0, "n": -1300.0, "kiyi": "marmara_suru"},
	"agsehpa": {"e": -3640.0, "n": -1290.0, "kiyi": "marmara_suru"},
	# halic: modülün konumları Sarayburnu'nda kümelenmişti (doğu −520…470); gerçek sırayla kıyı boyunca (kestirim)
	"halic_yahudi": {"e": -1193.0, "n": 957.0, "kiyi": "halic_suru"},
	"halic_iskele": {"e": -1025.0, "n": 900.0, "kiyi": "halic_suru"},
	"halic_venedik": {"e": -857.0, "n": 935.0, "kiyi": "halic_suru"},
	"halic_balik": {"e": -731.0, "n": 913.0, "kiyi": "halic_suru"},
	"halic_pisa_amalfi": {"e": -605.0, "n": 840.0, "kiyi": "halic_suru"},
	"halic_neorion": {"e": -479.0, "n": 801.0, "kiyi": "halic_suru"},
	"halic_ceneviz": {"e": -353.0, "n": 760.0, "kiyi": "halic_suru"},
	"halic_eugenios": {"e": -150.0, "n": 790.0, "kiyi": "halic_suru"},
	"halic_petrion": {"e": -2520.0, "n": 2046.0, "hat": "halic_suru"},
	"halic_fener": {"e": -2478.0, "n": 2213.0, "hat": "halic_suru"},
	"ayvansaray_iskele": {"kiyi": "halic_suru"},
	# surlar: kapılar dizindeki yerlerinden, kara surunun üstüne oturur
	"altin_kapi": {"e": -4797.0, "n": -1679.0, "hat": "kara_suru"},
	"ksylokerkos": {"e": -5000.0, "n": -1520.0, "hat": "kara_suru"},
	"pege": {"e": -5251.0, "n": -1401.0, "hat": "kara_suru"},
	"rhegion": {"e": -4873.0, "n": -512.0, "hat": "kara_suru"},
	"romanos": {"e": -4621.0, "n": 823.0, "hat": "kara_suru"},
	"pempton": {"e": -3906.0, "n": 1601.0, "hat": "kara_suru"},
	"kharisios": {"e": -3545.0, "n": 2413.0, "hat": "kara_suru"},
	"kerkoporta": {"e": -3300.0, "n": 2650.0, "hat": "blakherna_suru"},
	# galata
	"galata_sur": {"hat": "galata_suru"},
}

## Uzun hatların yapı türleri: kurucu, yürüme yolu yüksekliği, en çok dilim boyu
const HAT := {
	"kara_suru": {"kur": "kara", "max": 110.0},
	"blakherna_suru": {"kur": "blakherna", "max": 120.0},
	"marmara_suru": {"kur": "marmara", "max": 120.0},
	"halic_suru": {"kur": "halic", "max": 120.0},
	"galata_suru": {"kur": "marmara", "max": 90.0},
}

var gece := false
var hat_items: Array = []         # sur dilimleri (denetim)
var quest2: Dictionary = {}       # ilk dokuz eserin v2 yerleri: KİMLİK → {p: Vector3, r, perch}


static func _hh(x: float, z: float) -> float:
	return IstGeo.h(x, z) if v2 else World1453.surface_h(x, z)


## Yeni dünyaya bağlar (IstDunya.build çağırır). dunya: dünyanın kökü (yerel = dünya koordinatı).
static func attach_v2(dunya: Node3D, gece_ := false) -> void:
	v2 = true
	enabled = true
	var s := IstSehir.new()
	s.name = "IstSehir"
	s.gece = gece_
	dunya.add_child(s)
	active = s
	var t0 := Time.get_ticks_msec()
	s._place_v2()
	var t1 := Time.get_ticks_msec()
	s._hatlar_v2()
	s._hat_far_commit()
	s._basamak_ag()
	var t2 := Time.get_ticks_msec()
	s._sehir_dokusu_v2()
	print("ISTSEHIR2 yer=%d hat=%d kur_ms=%d hat_ms=%d doku_ms=%d" % [s.items.size(), s.hat_items.size(), t1 - t0, t2 - t1, Time.get_ticks_msec() - t2])


## Kaydın v2'deki yeri: {pos, yaw, k, r} ya da {} (kurulmaz)
func _place2_of(e: Dictionary) -> Dictionary:
	var data: Dictionary = e["data"]
	var id := String(e["id"])
	var fix: Dictionary = YER2.get(id, {})
	if fix.get("skip", false):
		return {}
	var real := Vector2(float(data.get("dogu_m", 0.0)), float(data.get("kuzey_m", 0.0)))
	if fix.has("e"):
		real = Vector2(float(fix["e"]), float(fix["n"]))
	var w := IstGeo.w2(real.x, real.y)
	var yaw := -deg_to_rad(float(fix.get("yon", data.get("yon_derece", 0.0))))
	var k := float(fix.get("k", K2))
	var s: Vector3 = data.get("gercek_olcu", Vector3(20, 10, 20))
	var r := maxf(s.x, s.z) * k * 0.5
	if fix.has("hat"):
		var pl := IstGeo.yol(String(fix["hat"]))
		if pl.size() >= 2:
			var sn := _snap(pl, w) if not fix.has("uc") else {"p": pl[0], "d": (pl[1] - pl[0]).normalized()}
			w = sn["p"]
			var d: Vector2 = sn["d"]
			yaw = _yaw_x(d, w, String(fix["hat"]))
			if String(e["mod"]).begins_with("halic"):
				yaw += PI            # Haliç kapıları: deniz −z
	elif fix.has("kiyi"):
		var pl := IstGeo.yol(String(fix["kiyi"]))
		if pl.size() >= 2:
			var sn := _snap(pl, w)
			var d: Vector2 = sn["d"]
			var o := _out(d, sn["p"], String(fix["kiyi"]))
			var tur := String(data.get("tur", ""))
			# liman suyun kenarına (sur dışı rıhtım), ötekiler surun içine (yarıçap + 10 m)
			var ic := -(r * 0.6) if tur == "liman" else r + 10.0
			w = sn["p"] - o * ic
			yaw = atan2(-o.x, -o.y) + PI        # yerel −z denize
			if String(e["mod"]).begins_with("halic"):
				yaw = atan2(o.x, o.y)
	# Suya düştüyse en yakın karaya (liman hariç)
	if String(data.get("tur", "")) != "liman" and IstGeo.su(w.x, w.y):
		w = _to_land(w)
	var hs: Array = []
	var u := Vector2(cos(-yaw), sin(-yaw))
	for o: Vector2 in [Vector2.ZERO, Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
		var q := w + Vector2(u.x * o.x * s.x * k * 0.45 - u.y * o.y * s.z * k * 0.45, u.y * o.x * s.x * k * 0.45 + u.x * o.y * s.z * k * 0.45)
		hs.append(IstGeo.h(q.x, q.y))
	hs.sort()
	var y: float = hs[2] if r > 25.0 else hs[0]
	if String(data.get("tur", "")) == "liman":
		y = maxf(y, 0.0)
	return {"pos": Vector3(w.x, y - 0.03 + float(fix.get("dy", 0.0)), w.y), "yaw": yaw, "k": k, "r": r}


static func _snap(pl: PackedVector2Array, p: Vector2) -> Dictionary:
	var best := {}
	var bd := INF
	var acc := 0.0
	for i in pl.size() - 1:
		var q := Geometry2D.get_closest_point_to_segment(p, pl[i], pl[i + 1])
		if q.distance_to(p) < bd:
			bd = q.distance_to(p)
			best = {"p": q, "d": (pl[i + 1] - pl[i]).normalized(), "s": acc + pl[i].distance_to(q), "i": i}
		acc += pl[i].distance_to(pl[i + 1])
	return best


## Hattın dış yanı (şehir dışı) birim normali
static func _out(d: Vector2, p: Vector2, ad: String) -> Vector2:
	var o := Vector2(-d.y, d.x)
	var inside := IstGeo.galata_ici(p.x + o.x * 20.0, p.y + o.y * 20.0) if ad == "galata_suru" else IstGeo.sehir_ici(p.x + o.x * 20.0, p.y + o.y * 20.0)
	return -o if inside else o


## Yerel +x hat boyunca, yerel +z dışarı bakacak yaw
static func _yaw_x(d: Vector2, p: Vector2, ad: String) -> float:
	var o := _out(d, p, ad)
	var dd := Vector2(o.y, -o.x)          # o = (−dd.y, dd.x) olacak biçimde hat yönü
	return atan2(-dd.y, dd.x)


static func _to_land(w: Vector2) -> Vector2:
	for r in range(1, 40):
		for k in 16:
			var q := w + Vector2.from_angle(k * TAU / 16.0) * r * 8.0
			if not IstGeo.su(q.x, q.y) and IstGeo.h(q.x, q.y) > 0.6:
				return q
	return w


func _place_v2() -> void:
	# Ayasofya: bölümün kendi dış kabuğu (ByzCity.aya_exterior + Ayasofya kabuğu), kubbe (0,0)'da
	var aw := IstGeo.w2(0, 0)
	var ay := IstGeo.h(aw.x, aw.y)
	IstGeo.duzle(aw, 34.0, ay)
	var ait := _v2_item("ayasofya", Vector3(aw.x, ay - 0.05, aw.y), -deg_to_rad(103.0), 40.0, _make_aya)
	# Kubbenin tepesindeki haçın 3,5 m yanı (kurşun kubbe yüzeyi): her uzaklıkta katı konma kapağı
	var ap := (ait["holder"] as Node3D).transform * Vector3(3.5, 19.5 + 11.1 * 0.42 * sqrt(1.0 - pow(3.5 / 11.1, 2.0)), 0)
	_pad(ap, "Konma_ayasofya")
	ait["perch_aya"] = ap
	# Blakherna Sarayı: Blachernae.shell_parts ("palace"), Blakherna suruna yaslı
	var bl := IstGeo.w2(-3402.0, 3436.0)
	var bpl := IstGeo.yol("blakherna_suru")
	var byaw := 0.0
	if bpl.size() >= 2:
		var sn := _snap(bpl, bl)
		var o := _out(sn["d"], sn["p"], "blakherna_suru")
		bl = (sn["p"] as Vector2) - o * 2.0
		byaw = _yaw_x(sn["d"], sn["p"], "blakherna_suru")
	_v2_item("blakherna", Vector3(bl.x, IstGeo.h(bl.x, bl.y) - 0.05, bl.y), byaw, 22.0, _make_blakherna)
	quest2["BLAKHERNA"] = {"p": Vector3(bl.x, IstGeo.h(bl.x, bl.y) + 26.0, bl.y), "r": 34.0}
	for e: Dictionary in catalog_all():
		var id := String(e["id"])
		var mod := String(e["mod"])
		if mod in MOD_SKIP2 or id in HAT_IDS:
			continue
		var pl := _place2_of(e)
		if pl.is_empty():
			continue
		var p: Vector3 = pl["pos"]
		# Yapının tabanı düzlenir (arazi ağı bu kayıtlardan sonra kurulur; IstGeo.duzle)
		# (kıyıdaki alçak yapılar düzlenmez: taban deniz düzeyine yakınsa arazi göl gibi suya iner)
		if float(pl["r"]) <= 130.0 and p.y > 2.0 and not String((e["data"] as Dictionary).get("tur", "")) in ["liman", "bitki"] and not (YER2.get(id, {}) as Dictionary).has("kiyi"):
			IstGeo.duzle(Vector2(p.x, p.z), float(pl["r"]) * 0.85, p.y + 0.03)
		var holder := Node3D.new()
		holder.name = "Ist_" + id
		holder.position = p
		holder.rotation.y = float(pl["yaw"])
		holder.set_meta("ist_id", id)
		add_child(holder)
		var it := {"id": id, "script": e["script"], "pos": p, "yaw": pl["yaw"], "k": pl["k"], "r": pl["r"],
			"have": [null, null, null], "holder": holder, "data": e["data"], "mod": mod, "r1": R1_V2}
		items.append(it)
		_build(it, 2)
		_perch_pad(it)


func _pad(p: Vector3, nm: String) -> void:
	var body := StaticBody3D.new()
	body.name = nm
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.4, 0.3, 1.4)
	cs.shape = bs
	body.add_child(cs)
	body.position = p - Vector3(0, 0.15, 0)
	add_child(body)


## Sur dilimlerinin uzak katmanı: 160 m'lik parçalarda tek ağ (dilim başına çizim yerine); parçanın merkezine 360 m'den
## yakınken gizlenir, dilimin kendi orta katmanı 420 m'de kurulur
const HAT_CELL := 160.0
const HAT_BEGIN := 360.0
var _hat_far := {}             # Vector2i → SurfaceTool
var _hat_mat: Material

func _hat_far_add(it: Dictionary) -> void:
	var tmp := Node3D.new()
	(it["make"] as Callable).call(tmp, 2)
	var list: Array = []
	for c in tmp.find_children("*", "MeshInstance3D", true, false):
		list.append(c)
	if list.is_empty():
		tmp.free()
		return
	var holder := Node3D.new()
	var mi := World1453.bake(list, tmp, Transform3D.IDENTITY, holder, "HatUzak", 0.05, 0, true)
	var p: Vector3 = it["pos"]
	var ck := Vector2i(floori(p.x / HAT_CELL), floori(p.z / HAT_CELL))
	var cen := Vector3((ck.x + 0.5) * HAT_CELL, 0, (ck.y + 0.5) * HAT_CELL)
	if mi.mesh != null:
		if not _hat_far.has(ck):
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			_hat_far[ck] = st
		var xf := Transform3D(Basis(Vector3.UP, float(it["yaw"])), p - cen)
		for si in mi.mesh.get_surface_count():
			(_hat_far[ck] as SurfaceTool).append_from(mi.mesh, si, xf)
		if _hat_mat == null:
			_hat_mat = mi.material_override if mi.material_override else mi.mesh.surface_get_material(0)
	holder.free()
	tmp.free()


func _hat_far_commit() -> void:
	for ck: Vector2i in _hat_far:
		var mi := MeshInstance3D.new()
		mi.mesh = (_hat_far[ck] as SurfaceTool).commit()
		if _hat_mat:
			mi.material_override = _hat_mat
		mi.position = Vector3((ck.x + 0.5) * HAT_CELL, 0, (ck.y + 0.5) * HAT_CELL)
		mi.visibility_range_begin = HAT_BEGIN
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)
		add_child(mi)
	_hat_far.clear()


func _v2_item(id: String, p: Vector3, yaw: float, r: float, make: Callable, data := {}, far_merge := false) -> Dictionary:
	var holder := Node3D.new()
	holder.name = "Ist_" + id
	holder.position = p
	holder.rotation.y = yaw
	add_child(holder)
	var it := {"id": id, "pos": p, "yaw": yaw, "k": K2, "r": r, "have": [null, null, null], "holder": holder,
		"data": data, "mod": "v2", "make": make, "r1": R1_V2}
	items.append(it)
	if far_merge:
		it["no2"] = true
		it["r1"] = HAT_BEGIN + HAT_CELL * 0.75 - r
		_hat_far_add(it)
	else:
		_build(it, 2)
	return it


func _make_aya(n: Node3D, lod: int) -> void:
	var off := Node3D.new()
	off.position = -ByzCity.AYA
	n.add_child(off)
	ByzCity.aya_exterior(off)
	if lod <= 1:
		var inner := Node3D.new()
		inner.position = ByzCity.AYA
		off.add_child(inner)
		Ayasofya._shell_walls(inner)
		Ayasofya._narthex(inner)
		Ayasofya._apse(inner)
		Ayasofya._domes(inner)


func _make_blakherna(n: Node3D, lod: int) -> void:
	var merl: Array = []
	var emit := func(kind: String, size: Vector3, pos: Vector3, col: Color, pattern: String, solid: bool, tag: String) -> void:
		match kind:
			"merl":
				if lod == 0:
					Props.box(n, size, pos, col)
			"glass":
				Props.box(n, size, pos, col).material_override = Props.mat(Color("ffc070"), 2.2 if gece else 0.6, false, "", false)
			"dark":
				Props.box(n, size, pos, col)
			_:
				if solid and lod == 0:
					var b := Props.solid(n, size, pos, Color.WHITE)
					Props.set_pattern(b, col, pattern)
				else:
					Props.box(n, size, pos, col)
	Blachernae.shell_parts(emit, "palace")
	# Kabuğun üstü (havadan bakış: düz kutu kalmasın): kiremit beşik çatı, kulelerde mazgallı teras ve piramit külah,
	# arka cephede pencere sırası
	var tile := Color("b4532f")
	Props.prism(n, Vector3(10.8, 3.4, 26.8), Vector3(0, 16.0 + 1.7, -21.0), tile, Vector3(0, 90, 0))
	Props.box(n, Vector3(26.4, 0.35, 10.4), Vector3(0, 16.1, -21.0), Color("a8583a"))
	for ox: float in [-14.4, 14.4]:
		Props.prism(n, Vector3(5.4, 3.0, 5.4), Vector3(ox, 20.0 + 1.5, -20.0), tile.darkened(0.1), Vector3.ZERO)
		if lod == 0:
			for k in 4:
				for sd: float in [-1.0, 1.0]:
					Props.box(n, Vector3(0.7, 0.8, 0.5), Vector3(ox - 1.9 + k * 1.27, 20.4, -20.0 + sd * 2.3), Color("cdbd9e"))
	if lod <= 1:
		for row in 2:
			for k in 6:
				Props.box(n, Vector3(1.4, 2.0, 0.08), Vector3(-10.0 + k * 4.0, 7.6 + row * 4.6, -26.04), Color("1c1814"))
		Props.cyl(n, 0.12, 2.2, Vector3(0, 20.2, -21.0), Color("d8b040"), Vector3.ZERO, 6)
		Props.box(n, Vector3(1.2, 0.14, 0.14), Vector3(0, 20.7, -21.0), Color("d8b040"))


# ---------------------------------------------------------------- uzun hatlar

## Polyline'ı sadeleştir: < 7° kırıkları birleştir (köşe kulesi sayısı azalsın)
static func _sade(pl: PackedVector2Array) -> PackedVector2Array:
	if pl.size() < 3:
		return pl
	var out := PackedVector2Array([pl[0]])
	var last := pl[0]
	for i in range(1, pl.size() - 1):
		var a := (pl[i] - last).normalized()
		var b := (pl[i + 1] - pl[i]).normalized()
		if absf(a.angle_to(b)) > deg_to_rad(7.0) or last.distance_to(pl[i]) > 260.0:
			out.append(pl[i])
			last = pl[i]
	out.append(pl[pl.size() - 1])
	return out


func _hatlar_v2() -> void:
	# Kapı aralıkları: hattın üstüne oturan kayıtlar (yay boyu ± yarım genişlik)
	var gaps := {}
	for it: Dictionary in items:
		var fix: Dictionary = YER2.get(String(it["id"]), {})
		if fix.has("hat"):
			var ad := String(fix["hat"])
			if not gaps.has(ad):
				gaps[ad] = []
			var g := float(it["r"]) * 1.4
			if String(it["mod"]) == "surlar":
				g = IstSurlar._gate_len(String(it["id"]), K2)
			gaps[ad].append([Vector2(it["pos"].x, it["pos"].z), g])
	var seed := 0
	for ad: String in HAT:
		var pl := _sade(IstGeo.yol(ad))
		if pl.size() < 2:
			continue
		var cfg: Dictionary = HAT[ad]
		var cuts: Array = []
		for g: Array in gaps.get(ad, []):
			var sn := _snap(pl, g[0])
			cuts.append([float(sn["s"]) - float(g[1]) * 0.5, float(sn["s"]) + float(g[1]) * 0.5])
		var s_acc := 0.0
		for i in pl.size() - 1:
			var a := pl[i]
			var b := pl[i + 1]
			var L := a.distance_to(b)
			var d := (b - a) / L
			var corner := 4.5 if i > 0 else 0.0
			var end_c := 4.5 if i < pl.size() - 2 else 0.0
			# Bu kenarın kapılarla bölünmüş aralıkları
			var iv: Array = [[corner, L - end_c]]
			for c: Array in cuts:
				var c0 := float(c[0]) - s_acc
				var c1 := float(c[1]) - s_acc
				var nv: Array = []
				for v: Array in iv:
					if c1 <= v[0] or c0 >= v[1]:
						nv.append(v)
					else:
						if c0 > v[0]:
							nv.append([v[0], c0])
						if c1 < v[1]:
							nv.append([c1, v[1]])
				iv = nv
			for v: Array in iv:
				var span := float(v[1]) - float(v[0])
				if span < 6.0:
					continue
				var n := maxi(1, int(ceil(span / float(cfg["max"]))))
				# Eğimde kısa dilim: dilim boyunca 1,6 m'den fazla düşü olmasın
				var dh := absf(IstGeo.h(a.x + d.x * v[0], a.y + d.y * v[0]) - IstGeo.h(a.x + d.x * v[1], a.y + d.y * v[1]))
				n = maxi(n, mini(int(ceil(dh / 1.6)), int(span / 30.0)))
				var lens: Array = []
				var hl := float(IstHalicSur.dims(K2)["L"])
				if String(cfg["kur"]) == "halic" and dh < 2.5 and span >= hl:
					# Haliç: modülün 80 m'lik parçaları (kapı, rıhtım) + kalanı parametreli deniz suru
					var kk := int(span / hl)
					var rem := span - kk * hl
					if rem > 0.05 and rem < 8.0:
						kk -= 1
						rem += hl
					for q in kk:
						lens.append(hl)
					if rem > 0.05:
						lens.insert(kk / 2, rem)
				else:
					for q in n:
						lens.append(span / n)
				var s0 := float(v[0])
				for pl_len: float in lens:
					var mid := a + d * (s0 + pl_len * 0.5)
					seed += 1
					var pc := _hat_piece(ad, String(cfg["kur"]), mid, d, pl_len, seed)
					pc["s0"] = s_acc + s0
					pc["s1"] = s_acc + s0 + pl_len
					pc["a2"] = a + d * s0
					pc["b2"] = a + d * (s0 + pl_len)
					s0 += pl_len
			# Köşe kulesi (iç köşe ve dış köşedeki kopukluğu örter; tepesi yürüme yolu hizasında)
			if i > 0:
				var kc := _kose(ad, String(cfg["kur"]), a)
				kc["s0"] = s_acc - 4.5
				kc["s1"] = s_acc + 4.5
				kc["a2"] = a - (a - pl[i - 1]).normalized() * 4.5
				kc["b2"] = a + d * 4.5
			s_acc += L
		_basamaklar(ad, String(cfg["kur"]))
	# Bozdoğan (iki tepe arası, altından Mese kolu geçer)
	var bz := IstGeo.yol("bozdogan")
	if bz.size() >= 2:
		var a := bz[0]
		var b := bz[bz.size() - 1]
		var L := a.distance_to(b)
		var mid := (a + b) * 0.5
		var d := (b - a) / L
		var lo := INF
		for k in 9:
			var q := a.lerp(b, k / 8.0)
			lo = minf(lo, IstGeo.h(q.x, q.y))
		var brg := atan2(d.x, -d.y)
		var uz := L / K2
		var it := _v2_item("bozdogan", Vector3(mid.x, lo - 0.1, mid.y), -brg, L * 0.5,
			func(n: Node3D, lod: int) -> void: IstKemerSu.build_bozdogan(n, K2, lod, uz))
		it["data"] = {"gorev": true}
		hat_items.append(it)
		quest2["BOZDOGAN"] = {"p": Vector3(mid.x, lo + float(IstKemerSu.params(K2, uz)["hmax"]) + 9.0, mid.y), "r": 34.0}
	# Mese revaklı dilimleri: forumların arasında, ana Mese boyunca
	var mese := IstGeo.yol("mese")
	if mese.size() >= 2:
		for i in mese.size() - 1:
			var a := mese[i]
			var b := mese[i + 1]
			var L := a.distance_to(b)
			var d := (b - a) / L
			var n := maxi(1, int(L / 70.0))
			for k in n:
				var mid := a + d * ((k + 0.5) * L / n)
				if _near_item(mid, 6.0):
					continue
				var hl := minf(IstGeo.h(mid.x - d.x * L / n * 0.5, mid.y - d.y * L / n * 0.5), IstGeo.h(mid.x + d.x * L / n * 0.5, mid.y + d.y * L / n * 0.5))
				var ln := L / n - 2.0
				var it := _v2_item("mese_%d_%d" % [i, k], Vector3(mid.x, hl - 0.04, mid.y), -atan2(d.x, -d.y), ln * 0.5,
					func(nd: Node3D, lod: int) -> void: IstForumlar.build_mese(nd, ln, K2, lod))
				hat_items.append(it)
	# Zincir: Eugenios'tan Galata'ya yüzen kütükler üstünde (halic_eugenios kulesi kıyıda)
	var zc := IstGeo.yol("zincir")
	if zc.size() >= 2:
		var a := zc[0]
		var b := zc[zc.size() - 1]
		var mid := (a + b) * 0.5
		var d := (b - a).normalized()
		var L := a.distance_to(b)
		var it := _v2_item("zincir", Vector3(mid.x, 0.0, mid.y), -atan2(d.x, -d.y), L * 0.5, _make_zincir.bind(L))
		quest2["ZINCIR"] = {"p": Vector3(mid.x, 8.0, mid.y), "r": 45.0}
		hat_items.append(it)


## Tolga'nın şehir bölümlerinin v2'de oturacağı alanlar (dünya dikdörtgenleri): hub (6b, 7b, 10h, 12b, 23, 24) Romanos
## Kapısı'nın iç yanında, kapıdan Mese koluna giden cadde yönünde; Ayasofya meydanı (24, 25, 26, 31o) Ayasofya'nın batısında.
var _oyun: Array = []

func oyun_alanlari() -> Array:
	if not _oyun.is_empty():
		return _oyun
	for it: Dictionary in items:
		if String(it["id"]) == "romanos":
			var p: Vector3 = it["pos"]
			var h := it["holder"] as Node3D
			# kapının yerel −z'si şehir (surlar: dış yüz +z)
			var inn := (h.transform.basis * Vector3(0, 0, -1)).normalized()
			var c := Vector2(p.x, p.z) + Vector2(inn.x, inn.z) * 75.0
			_oyun.append(Rect2(c - Vector2(45, 45), Vector2(90, 90)))
	var aw := IstGeo.w2(0, 0)
	_oyun.append(Rect2(aw + Vector2(-95, -25), Vector2(55, 50)))
	return _oyun


func _near_item(p: Vector2, pad: float) -> bool:
	for it: Dictionary in items:
		if String(it["mod"]) == "v2":
			continue
		var q: Vector3 = it["pos"]
		if Vector2(q.x, q.z).distance_to(p) < float(it["r"]) + pad:
			return true
	return false


## Hat dilimi: kur türüne göre parçanın parametreli kurucusu
func _hat_piece(ad: String, kur: String, mid: Vector2, d: Vector2, L: float, seed: int) -> Dictionary:
	var yaw := _yaw_x(d, mid, ad)
	# Taban: hat boyunca örneklerin ortancası (kıyıda bir ucu denize, bir ucu yamaca düşen dilim gömülmesin); ortancanın
	# altında kalan yer taş temelle (dilim boyu, sur kalınlığı) doldurulur
	var hs: Array = []
	for k in 7:
		var q := mid + d * L * (k / 6.0 - 0.5)
		hs.append(IstGeo.h(q.x, q.y))
	hs.sort()
	var lo := maxf(float(hs[3]), -0.6)
	var dip := maxf(float(hs[0]), -2.5)
	var make: Callable
	match kur:
		"kara":
			make = func(n: Node3D, lod: int) -> void: IstSurlar.build_run(n, L, K2, lod, 1453 + seed)
		"blakherna":
			make = func(n: Node3D, lod: int) -> void: _blakherna_wall(n, L, lod)
		"halic":
			# Haliç suru: modülün 80 m'lik parçası (deniz −z) sığıyorsa; değilse parametreli deniz suru
			if absf(L - float(IstHalicSur.dims(K2)["L"])) < 0.05:
				yaw += PI
				make = func(n: Node3D, lod: int) -> void: IstHalicSur.build(n, K2, lod)
			else:
				kur = "marmara"
				make = func(n: Node3D, lod: int) -> void: IstMarmaraSur.build_run(n, L, K2, lod, {})
		_:
			make = func(n: Node3D, lod: int) -> void: IstMarmaraSur.build_run(n, L, K2, lod, {})
	if lo - dip > 0.3:
		var inner := make
		var tk := _walk_w(kur) + 1.6
		var drop := lo - dip + 0.4
		make = func(n: Node3D, lod: int) -> void:
			inner.call(n, lod)
			var fy := -drop * 0.5 + 0.05
			if lod == 0:
				Props.set_pattern(Props.solid(n, Vector3(L, drop, tk), Vector3(0, fy, 0), Color.WHITE), Color("b8a888"), "ashlar")
			else:
				Props.box(n, Vector3(L, drop, tk), Vector3(0, fy, 0), Color("b8a888"))
	var pos := Vector3(mid.x, lo - 0.05, mid.y)
	if kur == "blakherna":
		# Blakherna kabuğunun suru yerel z 0…4,6'da (dış yüz +z): sur ekseni hatta otursun
		var o := _out(d, mid, ad)
		pos -= Vector3(o.x, 0, o.y) * 2.3
	var it := _v2_item("%s_%d" % [ad, seed], pos, yaw, L * 0.5 + 6.0, make, {}, true)
	it["hat"] = ad
	it["len"] = L
	it["walk"] = lo - 0.05 + _walk_h(kur)
	hat_items.append(it)
	return it


## Blakherna suru dilimi: Blachernae.shell_parts("wall") 120 m'lik; L'ye göre x ekseninde ölçeklenmez, kırpılır
func _blakherna_wall(n: Node3D, L: float, lod: int) -> void:
	var emit := func(kind: String, size: Vector3, pos: Vector3, col: Color, pattern: String, solid: bool, tag: String) -> void:
		if absf(pos.x) - size.x * 0.5 > L * 0.5:
			return
		var sz := size
		var p := pos
		if size.x > L:
			sz.x = L
			p.x = 0.0
		if kind == "merl" and lod > 0:
			return
		if solid and lod == 0:
			var b := Props.solid(n, sz, p, Color.WHITE)
			Props.set_pattern(b, col, pattern)
		else:
			Props.box(n, sz, p, col)
	Blachernae.shell_parts(emit, "wall")


static func _walk_h(kur: String) -> float:
	match kur:
		"kara": return float(IstSurlar.dims(K2)["HW"])
		"blakherna": return Blachernae.WALK_Y
		"halic": return float(IstHalicSur.dims(K2)["H"])
	return float(IstMarmaraSur.dims(K2)["H"])


static func _walk_w(kur: String) -> float:
	match kur:
		"kara": return float(IstSurlar.dims(K2)["T"]) - 1.0
		"blakherna": return 3.4
		"halic": return float(IstHalicSur.dims(K2)["T"]) - 0.9
	return float(IstMarmaraSur.dims(K2)["T"]) - 0.9


## Sur üstü yürüyüş: ardışık iki öğenin (dilim/köşe kulesi) yürüme yolları arasında > 0,35 m fark varsa alçak olanın
## ucuna 0,30 m'lik taş basamaklar (tek MultiMesh + tek çarpışma gövdesi; uzakta çizilmez)
var _bas_xf: Array = []
var _bas_body: StaticBody3D

func _basamaklar(ad: String, kur: String) -> void:
	var list: Array = []
	for it: Dictionary in hat_items:
		if String(it.get("hat", "")) == ad and it.has("s0") and it.has("walk"):
			list.append(it)
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["s0"]) < float(b["s0"]))
	if _bas_body == null:
		_bas_body = StaticBody3D.new()
		_bas_body.name = "SurBasamak"
		add_child(_bas_body)
	var ww := _walk_w(kur)
	for i in list.size() - 1:
		var A: Dictionary = list[i]
		var B: Dictionary = list[i + 1]
		if float(B["s0"]) - float(A["s1"]) > 1.5:
			continue
		var ya := float(A["walk"])
		var yb := float(B["walk"])
		var dh := absf(yb - ya)
		if dh < 0.35:
			continue
		var lowA := ya < yb
		var J: Vector2 = A["b2"] if lowA else B["a2"]
		var dir: Vector2 = ((A["b2"] as Vector2) - (A["a2"] as Vector2)).normalized()
		if not lowA:
			dir = ((B["a2"] as Vector2) - (B["b2"] as Vector2)).normalized()
		var y0 := minf(ya, yb)
		var n := int(ceil(dh / 0.3))
		for k in n:
			var top := y0 + (k + 1) * dh / n
			var c := J - dir * ((n - k - 0.5) * 0.45)
			var hgt := top - y0 + 0.05
			var bas := Basis(Vector3.UP, atan2(-dir.y, dir.x))
			var xf := Transform3D(bas.scaled(Vector3(0.46, hgt, ww)), Vector3(c.x, y0 - 0.05 + hgt * 0.5, c.y))
			_bas_xf.append(xf)
			var cs := CollisionShape3D.new()
			var bs := BoxShape3D.new()
			bs.size = Vector3(0.46, hgt, ww)
			cs.shape = bs
			cs.transform = Transform3D(bas, xf.origin)
			_bas_body.add_child(cs)


func _basamak_ag() -> void:
	if _bas_xf.is_empty():
		return
	var mm := _mm(_unit_box(Color("cdbd9e"), "ashlar"), _bas_xf)
	mm.visibility_range_end = 260.0


## Köşe kulesi: iki dilimin birleştiği yerde dolu kule; tepesi yürüme yolu hizasında (yürüyüş kesilmez)
func _kose(ad: String, kur: String, p: Vector2) -> Dictionary:
	var walk := 6.65
	var sz := 9.0
	match kur:
		"kara":
			walk = float(IstSurlar.dims(K2)["HW"])
			sz = float(IstSurlar.dims(K2)["T"]) + 6.0
		"blakherna":
			walk = Blachernae.WALK_Y
			sz = 9.0
		"halic":
			walk = float(IstHalicSur.dims(K2)["H"])
			sz = float(IstHalicSur.dims(K2)["T"]) + 5.0
		_:
			walk = float(IstMarmaraSur.dims(K2)["H"])
			sz = float(IstMarmaraSur.dims(K2)["T"]) + 5.0
	var lo := INF
	for o: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2.ZERO]:
		lo = minf(lo, IstGeo.h(p.x + o.x * sz * 0.4, p.y + o.y * sz * 0.4))
	lo = maxf(lo, -0.6)
	var make := func(n: Node3D, lod: int) -> void:
		var stone := Color("cdbd9e")
		if lod == 0:
			var b := Props.solid(n, Vector3(sz, walk, sz), Vector3(0, walk * 0.5, 0), Color.WHITE)
			Props.set_pattern(b, stone, "ashlar")
			for sd: Vector2 in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
				for t in 3:
					var off := (t - 1) * sz * 0.33
					var mp := Vector3(sd.x * (sz * 0.5 - 0.3) + absf(sd.y) * off, walk + 0.55, sd.y * (sz * 0.5 - 0.3) + absf(sd.x) * off)
					Props.box(n, Vector3(1.0 if sd.y != 0 else 0.6, 1.1, 0.6 if sd.y != 0 else 1.0), mp, stone.darkened(0.08))
			for y: float in [walk * 0.33, walk * 0.66]:
				Props.box(n, Vector3(sz + 0.06, 0.4, sz + 0.06), Vector3(0, y, 0), Color("a8583a"))
		else:
			Props.box(n, Vector3(sz, walk + 1.1, sz), Vector3(0, (walk + 1.1) * 0.5, 0), stone)
	var it := _v2_item("kose_%s_%d" % [ad, hat_items.size()], Vector3(p.x, lo - 0.05, p.y), 0.0, sz, make, {}, true)
	it["hat"] = ad
	it["walk"] = lo - 0.05 + walk
	hat_items.append(it)
	return it


func _make_zincir(n: Node3D, lod: int, L: float) -> void:
	# Yüzen kütükler (ahşap şamandıra) ve aralarında demir zincir; uçta Galata'nın Kastellion kulesi tarafına bağlanır
	var nlog := int(L / 6.0)
	for i in nlog:
		var z := -L * 0.5 + (i + 0.5) * L / nlog
		if lod >= 2 and i % 3 != 0:
			continue
		Props.cyl(n, 0.45, 4.6, Vector3(0, 0.15, z), Color("6a4a2e"), Vector3(0, 0, 90), 8 if lod == 0 else 5)
		if lod == 0:
			Props.box(n, Vector3(0.18, 0.18, L / nlog), Vector3(0, 0.62, z), Color("3a3a3e"))
	if lod == 0:
		var body := StaticBody3D.new()
		n.add_child(body)
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(1.0, 0.8, L)
		cs.shape = bs
		cs.position = Vector3(0, 0.3, 0)
		body.add_child(cs)


# ---------------------------------------------------------------- sokaklar, evler, doku

func _sehir_dokusu_v2() -> void:
	var foot: Array = []
	for it: Dictionary in items:
		var p: Vector3 = it["pos"]
		if it.has("hat"):
			continue
		var rr := float(it["r"]) + 4.0
		if String(it["id"]).begins_with("mese_"):
			rr = float(it["r"]) * 0.3
		foot.append(Vector3(p.x, rr, p.z))
	# Bölümlerin oynanış alanları (ayrı pakette bağlanacak): BOŞ bırakılır (ev/ağaç/doku yok)
	for a: Rect2 in oyun_alanlari():
		var c := a.get_center()
		foot.append(Vector3(c.x, a.size.length() * 0.5, c.y))
	var bands: Array = []
	for ad: String in HAT:
		var hw := 26.0 if ad == "kara_suru" else (16.0 if ad == "blakherna_suru" else 9.0)
		bands.append([IstGeo.yol(ad), hw])
	bands.append([IstGeo.yol("bozdogan"), 6.0])
	var gates: Array = []
	for it: Dictionary in items:
		var fix: Dictionary = YER2.get(String(it["id"]), {})
		var tur := String((it["data"] as Dictionary).get("tur", ""))
		if tur == "kapi" and fix.has("hat"):
			var p: Vector3 = it["pos"]
			var hat := String(fix["hat"])
			gates.append([Vector2(p.x, p.z), "halic" if hat == "halic_suru" else "kara"])
	# Dizindeki deniz kapıları (Haliç ve Marmara): yokuş başları
	for y: Dictionary in IstGeo.yerler():
		if String(y["tur"]) != "kapi":
			continue
		var w: Vector3 = y["w"]
		var hp := Vector2(w.x, w.z)
		for ad: String in ["halic_suru", "marmara_suru"]:
			var pl := IstGeo.yol(ad)
			if pl.size() < 2:
				continue
			var sn := _snap(pl, hp)
			if (sn["p"] as Vector2).distance_to(hp) < 120.0:
				gates.append([sn["p"], "halic" if ad == "halic_suru" else "marmara"])
	sokak = IstSokak.new()
	sokak.build(foot, bands, gates)
	print("ISTSOKAK ", sokak.stats)
	var g0 := {}
	var g1 := {}
	var g2 := {}
	var rng := RandomNumberGenerator.new()
	rng.seed = 29
	var n := 0
	for h: Dictionary in sokak.houses:
		var v := int(h["v"])
		var dm := IstEvler.dims(v)
		var c: Vector2 = h["c"]
		var yaw := float(h["yaw"])
		var fr: Vector2 = h["on"]
		var yf := IstGeo.h(fr.x, fr.y)
		var lo := yf
		var bas := Basis(Vector3.UP, yaw)
		for o: Vector3 in [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(-0.5, 0, 0.5), Vector3(0.5, 0, 0.5)]:
			var q := Vector3(c.x, 0, c.y) + bas * (o * Vector3(dm.x, 0, dm.z))
			lo = minf(lo, IstGeo.h(q.x, q.z))
		var y := yf - 0.04
		var xf := Transform3D(bas, Vector3(c.x, y, c.y))
		_add(g0, g1, g2, "ev|%d|%s" % [v, String(h["tip"])], xf)
		if y - lo > 0.15:
			var drop := y - lo + 0.3
			_add(g0, g1, g2, "kaide", Transform3D(bas.scaled(Vector3(dm.x, drop, dm.z)), Vector3(c.x, y - drop * 0.5 + 0.02, c.y)))
		n += 1
	# Sokak taşları ve basamaklar (yamaçta) — uzakta çizilmez
	for st: Dictionary in sokak.streets:
		if String(st["tur"]) != "basamak":
			continue
		var pl: PackedVector2Array = st["pts"]
		for i in pl.size() - 1:
			var a := pl[i]
			var b := pl[i + 1]
			var ha := IstGeo.h(a.x, a.y)
			var hb := IstGeo.h(b.x, b.y)
			var L := a.distance_to(b)
			var ns := int(absf(hb - ha) / 0.3)
			if ns < 2:
				continue
			var d := (b - a) / L
			var yaw := atan2(-d.x, -d.y)
			for k in ns:
				var t := (k + 0.5) / ns
				var q := a.lerp(b, t)
				var hy := lerpf(ha, hb, t)
				_add(g0, g1, g2, "tas", Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3(float(st["w"]) - 0.4, 0.3, L / ns + 0.05)), Vector3(q.x, hy - 0.12, q.y)))
	# Doku: bostan/bağ/tarla yamaları, harabe, mahalle kiliseleri, ağaçlık, bahçe
	var np := 0
	var far: Array = []
	for dk: Dictionary in sokak.doku:
		var tur := String(dk["tur"])
		var c: Vector2 = dk["c"]
		var alan: Vector2 = dk["alan"]
		var tohum := int(dk["tohum"])
		var hs := [IstGeo.h(c.x - alan.x * 0.4, c.y - alan.y * 0.4), IstGeo.h(c.x + alan.x * 0.4, c.y - alan.y * 0.4),
			IstGeo.h(c.x - alan.x * 0.4, c.y + alan.y * 0.4), IstGeo.h(c.x + alan.x * 0.4, c.y + alan.y * 0.4), IstGeo.h(c.x, c.y)]
		var lo: float = hs.min()
		var id := "doku_%s_%d" % [tur, np]
		np += 1
		if tur == "agaclik":
			for k in rng.randi_range(4, 10):
				var tp := c + Vector2(rng.randf_range(-alan.x * 0.45, alan.x * 0.45), rng.randf_range(-alan.y * 0.45, alan.y * 0.45))
				_add(g0, g1, g2, "ag|" + String(AGAC_SEYREK[rng.randi() % AGAC_SEYREK.size()]), Transform3D(Basis(Vector3.UP, rng.randf() * TAU), Vector3(tp.x, IstGeo.h(tp.x, tp.y) - 0.05, tp.y)))
			continue
		var it := {"id": id, "pos": Vector3(c.x, lo + 0.02, c.y), "yaw": float(dk["yaw"]), "k": 1.0, "r": alan.length() * 0.5,
			"have": [null, null, null], "data": {"tur": "bitki"}, "mod": "doku"}
		if tur in ["bostan", "bag", "bugday", "cayir", "bahce"] and KITS.has(tur):
			var scr: GDScript = KITS[tur]
			it["make"] = func(nd: Node3D, lod: int) -> void: scr.call("build_patch_" + tur, nd, alan, 1.0, lod, tohum)
		elif tur == "harabe":
			it["pos"] = Vector3(c.x, lo - 0.03, c.y)
			it["make"] = func(nd: Node3D, lod: int) -> void: IstEvler.build_harabe(nd, 1.0, lod, tohum)
		elif tur.begins_with("harabe_") or tur in ["kilise_kucuk", "sapel", "kilise_orta"]:
			var kk := 0.75 if tur == "kilise_orta" else 1.0
			it["data"] = {"tur": "kilise"}
			it["make"] = func(nd: Node3D, lod: int) -> void:
				nd.set_meta("tohum", tohum)
				IstKiliseler.build(tur, nd, kk, lod)
		else:
			continue
		# bahçe/bostan kenarında birkaç ağaç
		for k in rng.randi_range(1, 3):
			var tp := c + Vector2((alan.x * 0.5 + 1.5) * (1 if rng.randf() < 0.5 else -1), rng.randf_range(-alan.y * 0.4, alan.y * 0.4))
			if sokak.cell(tp.x, tp.y) in [0, 5]:
				_add(g0, g1, g2, "ag|" + String(AGAC_SIK[rng.randi() % AGAC_SIK.size()]), Transform3D(Basis(Vector3.UP, rng.randf() * TAU), Vector3(tp.x, IstGeo.h(tp.x, tp.y) - 0.05, tp.y)))
		_item_lazy(it)
		far.append([tur, c, alan, float(dk["yaw"]), lo])
	# Meydan: kuyu ya da çeşme ve çevresinde pazar köşesi
	var nm := 0
	for m: Dictionary in sokak.meydan:
		var c: Vector2 = m["c"]
		var tohum := int(m["tohum"])
		var it := {"id": "meydan_%d" % nm, "pos": Vector3(c.x, IstGeo.h(c.x, c.y) - 0.02, c.y), "yaw": float(m["yaw"]), "k": 1.0, "r": 7.0,
			"have": [null, null, null], "data": {"tur": "ayrinti"}, "mod": "doku"}
		var which := "kuyu" if tohum % 2 == 0 else "cesme"
		it["make"] = func(nd: Node3D, lod: int) -> void:
			if lod >= 2:
				return
			Ayrinti.build(which, nd, 1.0, lod)
		_item_lazy(it)
		nm += 1
	_layers2(g0, g1, g2)
	_far_doku(far)
	print("ISTEVLER2 ev=%d doku=%d meydan=%d hucre=%d" % [n, np, nm, _cells0.size()])


## Dokunun tekil öğesi (v2): uzakta kurulmaz (uzak görünüşü hücre başına birleşik ağda: _far_doku), 310 m'de orta katman
func _item_lazy(it: Dictionary) -> void:
	var holder := Node3D.new()
	holder.name = String(it["id"])
	holder.position = it["pos"]
	holder.rotation.y = float(it["yaw"])
	add_child(holder)
	it["holder"] = holder
	it["no2"] = true
	it["r1"] = 210.0
	items.append(it)


const FAR_DOKU_CELL := 144.0
const FAR_DOKU_BEGIN := 115.0
const DOKU_RENK := {"bostan": Color("7a7a3a"), "bag": Color("4a6a2a"), "bugday": Color("b8b060"), "cayir": Color("7a9a4a"),
	"bahce": Color("5a8a3a")}

## Doku öğelerinin uzak görünüşü: 144 m hücre başına tek ağ (yama: zemine yatık renkli dörtgen; kilise: gövde + çatı;
## harabe: alçak taş kütle). Hücrenin merkezine 200 m'den yakınken gizlenir (öğeler 310 m'de orta katmana geçer).
func _far_doku(far: Array) -> void:
	_far_doku_cells(far, FAR_DOKU_CELL, FAR_DOKU_BEGIN, MID)
	_far_doku_cells(far, CELL2, MID, 0.0)


func _far_doku_cells(far: Array, size: float, begin: float, end: float) -> void:
	var cells := {}
	for f: Array in far:
		var c: Vector2 = f[1]
		var ck := Vector2i(floori(c.x / size), floori(c.y / size))
		if not cells.has(ck):
			cells[ck] = []
		cells[ck].append(f)
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.roughness = 1.0
	for ck: Vector2i in cells:
		var cen := Vector3((ck.x + 0.5) * size, 0, (ck.y + 0.5) * size)
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for f: Array in cells[ck]:
			var tur := String(f[0])
			var c: Vector2 = f[1]
			var alan: Vector2 = f[2]
			var bas := Basis(Vector3.UP, float(f[3]))
			var lo := float(f[4])
			if DOKU_RENK.has(tur):
				var q: Array = []
				for o: Vector2 in [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.5, 0.5), Vector2(-0.5, 0.5)]:
					var lp := bas * Vector3(o.x * alan.x, 0, o.y * alan.y)
					var wx := c.x + lp.x
					var wz := c.y + lp.z
					q.append(Vector3(wx, IstGeo.h(wx, wz) + 0.25, wz) - cen)
				st.set_color(DOKU_RENK[tur])
				st.set_normal(Vector3.UP)
				for idx in [0, 1, 2, 0, 2, 3]:
					st.add_vertex(q[idx])
			else:
				var sz := Vector3(6, 2.0, 8)
				var col := Color("cfc2a6")
				if tur == "kilise_kucuk":
					sz = Vector3(10, 9, 15)
					col = Color("c88a6a")
				elif tur == "sapel":
					sz = Vector3(5, 5.5, 10)
					col = Color("c88a6a")
				elif tur == "kilise_orta":
					sz = Vector3(13, 12, 20)
					col = Color("c88a6a")
				_box_st(st, Vector3(c.x, lo, c.y) - cen, bas, sz, col)
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		mi.material_override = mat
		mi.position = cen
		mi.visibility_range_begin = begin
		mi.visibility_range_end = end
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)
		add_child(mi)


static func _box_st(st: SurfaceTool, base: Vector3, bas: Basis, sz: Vector3, col: Color) -> void:
	st.set_color(col)
	var h := sz * 0.5
	var c := [Vector3(-h.x, 0, -h.z), Vector3(h.x, 0, -h.z), Vector3(h.x, 0, h.z), Vector3(-h.x, 0, h.z),
		Vector3(-h.x, sz.y, -h.z), Vector3(h.x, sz.y, -h.z), Vector3(h.x, sz.y, h.z), Vector3(-h.x, sz.y, h.z)]
	for f: Array in [[0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7], [4, 5, 6, 7]]:
		var a: Vector3 = base + bas * c[f[0]]
		var b: Vector3 = base + bas * c[f[1]]
		var cc: Vector3 = base + bas * c[f[2]]
		var d: Vector3 = base + bas * c[f[3]]
		st.set_normal((b - a).cross(d - a).normalized() * -1.0)
		for v: Vector3 in [a, cc, b, a, d, cc]:
			st.add_vertex(v)


## v2 katmanları: uzak (lod 2) hücre başına TEK ağ (bütün ev örnekleri birleşik), orta MultiMesh, yakın akışla
func _layers2(g0: Dictionary, g1: Dictionary, g2: Dictionary) -> void:
	for ck: Vector2i in g2:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var mat: Material = null
		var any := false
		var cen := Vector3((ck.x + 0.5) * CELL2, 0, (ck.y + 0.5) * CELL2)
		for key: String in g2[ck]:
			if not key.begins_with("ev|") and key != "kaide":
				continue
			var m2 := _mesh_for(key, 2)
			if m2 == null:
				continue
			if mat == null:
				mat = m2.surface_get_material(0)
			for xf: Transform3D in g2[ck][key]:
				var lx := Transform3D(xf.basis, xf.origin - cen)
				for si in m2.get_surface_count():
					st.append_from(m2, si, lx)
				any = true
		if not any:
			continue
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		if mat:
			mi.material_override = mat
		mi.position = cen
		mi.visibility_range_begin = MID
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)
		add_child(mi)
	for ck: Vector2i in g1:
		# Evler ve kaideler: hücre başına tek ağ (malzeme başına bir yüzey); ağaçlar MultiMesh
		var cen := Vector3((ck.x + 0.5) * CELL1, 0, (ck.y + 0.5) * CELL1)
		for key: String in g1[ck]:
			if _mergeable(key):
				continue
			var m1 := _mesh_for(key, 1)
			if m1 == null:
				continue
			var mm := _mm(m1, g1[ck][key])
			mm.visibility_range_begin = NEAR
			mm.visibility_range_end = MID * 0.5
		var mi := _merge_groups(g1[ck], 1, cen)
		if mi:
			mi.visibility_range_begin = NEAR
			mi.visibility_range_end = MID
	for ck: Vector2i in g0:
		var cx := (ck.x + 0.5) * CELL0
		var cz := (ck.y + 0.5) * CELL0
		_cells0.append({"c": Vector3(cx, _hh(cx, cz), cz), "groups": g0[ck], "mm": [], "col": null, "up": false})


static func _mergeable(key: String) -> bool:
	return key.begins_with("ev|") or key == "kaide" or key == "tas"


## Grupların (ev, kaide, taş) örneklerini tek ağa toplar: malzeme başına bir yüzey. cen: ağın dünya konumu.
func _merge_groups(groups: Dictionary, lod: int, cen: Vector3) -> MeshInstance3D:
	var by_mat := {}
	for key: String in groups:
		if not _mergeable(key):
			continue
		var m := _mesh_for(key, lod)
		if m == null:
			continue
		for si in m.get_surface_count():
			var sm: Material = m.surface_get_material(si)
			if sm == null and m is PrimitiveMesh:
				sm = (m as PrimitiveMesh).material
			if not by_mat.has(sm):
				var nst := SurfaceTool.new()
				nst.begin(Mesh.PRIMITIVE_TRIANGLES)
				by_mat[sm] = nst
			for xf: Transform3D in groups[key]:
				(by_mat[sm] as SurfaceTool).append_from(m, si, Transform3D(xf.basis, xf.origin - cen))
	if by_mat.is_empty():
		return null
	var am := ArrayMesh.new()
	for sm in by_mat:
		(by_mat[sm] as SurfaceTool).commit(am)
		am.surface_set_material(am.get_surface_count() - 1, sm)
	var mi := MeshInstance3D.new()
	mi.mesh = am
	mi.position = cen
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if lod > 0 else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	mi.set_meta("no_walk", true)
	add_child(mi)
	return mi


static var _kaide_mesh: Mesh
static var _tas_mesh: Mesh

static func _unit_box(col: Color, pat: String) -> Mesh:
	var bm := BoxMesh.new()
	bm.size = Vector3.ONE
	bm.material = Props.mat(col, 0.0, false, pat)
	return bm


# ---------------------------------------------------------------- Nihat'ın yan görevi (v2)

const ILK_DOKUZ := ["AYASOFYA", "HIPODROM", "KONSTANTIN", "HAVARIYUN", "BOZDOGAN", "ZINCIR", "GALATA", "BLAKHERNA", "SURLAR"]
const DOKUZ_ID := {"HIPODROM": "hipodrom", "KONSTANTIN": "konstantin", "HAVARIYUN": "havariyun", "GALATA": "galata_kulesi",
	"SURLAR": "romanos"}

## World1453.flight_data ile aynı biçim: landmarks [[KİMLİK, dünya noktası, yarıçap]], forms [[n, nokta]], perches
## [[ad, nokta, yarıçap]]. İlk dokuz aynı kimlik ve sırayla (v2'deki yerlerinde); ardından "gorev": true olan yeni eserler.
static func flight_data_v2(world: Node3D = null) -> Dictionary:
	var s := active
	if s == null:
		return {"landmarks": [], "forms": [], "perches": []}
	var g := func(p: Vector3) -> Vector3:
		return s.to_global(p) if s.is_inside_tree() else p
	var by := {}
	for it: Dictionary in s.items:
		by[String(it["id"])] = it
	var landmarks: Array = []
	var used := {}
	for q: String in ILK_DOKUZ:
		var p := Vector3.INF
		var r := 36.0
		if q == "AYASOFYA" and by.has("ayasofya"):
			var a: Vector3 = by["ayasofya"]["pos"]
			p = a + Vector3(0, World1453.AYA_DOME_TOP + 6.0, 0)
			r = 48.0
		elif s.quest2.has(q):
			p = s.quest2[q]["p"]
			r = float(s.quest2[q]["r"])
		elif DOKUZ_ID.has(q) and by.has(DOKUZ_ID[q]):
			var it: Dictionary = by[DOKUZ_ID[q]]
			p = _bakis_of(it)
			r = float((it["data"] as Dictionary).get("bakis_r", 36.0))
			used[DOKUZ_ID[q]] = true
		landmarks.append([q, g.call(p), r])
	for it: Dictionary in s.items:
		var d: Dictionary = it["data"]
		if not d.get("gorev", false) or used.has(it["id"]) or String(it["id"]) in ["bozdogan"]:
			continue
		landmarks.append([String(it["id"]).to_upper(), g.call(_bakis_of(it)), float(d.get("bakis_r", 30.0))])
	var forms: Array = []
	for i in landmarks.size():
		if i >= 12:
			break
		forms.append([i + 1, (landmarks[i][1] as Vector3) - Vector3(0, 4.0, 0)])
	var perches: Array = []
	if by.has("ayasofya"):
		perches.append(["aya", g.call(by["ayasofya"]["perch_aya"]), 5.0])
	for q: Array in s.perch_marks():
		perches.append([q[0], g.call(q[1]), q[2]])
	return {"landmarks": landmarks, "forms": forms, "perches": perches}


## Eserin yan görev işareti: kaydın "bakis" noktası (yerel) varsa ondan, yoksa tepesinin 8 m üstü
static func _bakis_of(it: Dictionary) -> Vector3:
	var d: Dictionary = it["data"]
	var h := it["holder"] as Node3D
	if d.has("bakis"):
		var b: Vector3 = d["bakis"]
		return h.transform * b
	var sz: Vector3 = d.get("gercek_olcu", Vector3(20, 20, 20))
	return h.transform * Vector3(0, sz.y * float(it["k"]) + 8.0, 0)
