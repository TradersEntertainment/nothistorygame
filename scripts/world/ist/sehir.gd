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
const ESER := preload("res://scripts/world/ist/sehir_eser.gd")
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
	"arkadius": {"e": -3419.0, "n": -678.0},       # Cerrahpaşa 41,0025 / 28,9395 (dizindeki n −956 kıyıya düşüyordu)
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


func _build(it: Dictionary, lod: int, bol := false) -> void:
	if it["have"][lod] != null:
		return
	if lod == 0 and it.has("pis_n"):
		_pis(it)
		return
	if lod == 0 and (it.has("sub") or (bol and v2 and _pencereli(it))):
		_pencere_is(it)
		return
	# Ön-pişirilmiş katman (v2: açılışta kurulmuş, ağaçtan ayrık bekler): yalnız ağaca bağlanır
	if it.has("pre") and it["pre"][lod] != null:
		var t1 := Time.get_ticks_usec()
		var pn: Node3D = it["pre"][lod]
		it["pre"][lod] = null
		(it["holder"] as Node3D).add_child(pn)
		it["have"][lod] = pn
		_show(it)
		var bms := (Time.get_ticks_usec() - t1) / 1000.0
		stats["bagla_ms_max"] = maxf(float(stats.get("bagla_ms_max", 0.0)), bms)
		_cost["%s/%d" % [String(it.get("mod", "")), lod]] = bms
		return
	var n := Node3D.new()
	n.name = "L%d" % lod
	(it["holder"] as Node3D).add_child(n)
	var t0 := Time.get_ticks_usec()
	if it.has("make"):
		(it["make"] as Callable).call(n, lod)
	else:
		(it["script"] as GDScript).call("build_" + String(it["id"]), n, float(it["k"]), lod)
		if v2 and MANASTIR.has(String(it["id"])):
			var mv: Vector2 = MANASTIR[String(it["id"])]
			ESER.manastir(n, lod, mv.x, mv.y, String(it["id"]).hash())
	if v2 and not it.has("hat") and String(it.get("mod", "")) != "doku":
		_kursun(n)
	if v2 and _paletli(it):
		# ÇEVRE-4: eser paleti (kalite notu 21; sehir_eser.gd başındaki tablo)
		stats["palet_n"] = int(stats.get("palet_n", 0)) + ESER.palet(n)
	if v2 and lod == 0 and it.has("glen"):
		var hw0 := float(IstSurlar.dims(K_SUR)["HW"])
		_kapi_gecit(n, hw0 - 0.35, hw0 + 0.35)
	elif v2 and lod == 0 and it.has("hat") and it.has("len"):
		_kapi_gecit_hat(it, n)
	var t_kur := Time.get_ticks_usec()
	if bol and v2 and lod == 0:
		# Zaman dilimi (kalite notu 8 / görev 7): yakın katmanın kurulması ve pişirilmesi iki ayrı iş (ayrı karelerde)
		n.visible = false
		it["pis_n"] = n
		var kms := (Time.get_ticks_usec() - t0) / 1000.0
		_cost["%s/0" % String(it.get("mod", ""))] = kms
		_yavas_say(it, "0k", kms, 0.0)
		return
	if lod > 0:
		_bake_lod(n, lod >= 2)
		if v2:
			_cizgisiz(n)
		for c in n.find_children("*", "GeometryInstance3D", true, false):
			c.set_meta("no_walk", true)
		# Orta/uzak katmanın çarpışması yok: gizliyken de fizikte duran kaba kütleler (dolu kule bloğu, kapısız
		# gövde) lod 0'ın kapılarını ve yürüme yollarını kapatıyordu (sur üstü yürüyüş sınamasında bulundu)
		if v2:
			for c in n.find_children("*", "CollisionObject3D", true, false):
				c.get_parent().remove_child(c)
				c.free()
	elif v2:
		# v2 yakın katman: görüntü doku başına pişirilir (çizim sayısı), çarpışma gövdeleri olduğu gibi kalır
		_bake_lod(n, false)
	# Süre: kurma + pişirme (tek işin toplamı; ISTYAVAS)
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	var pis_ms := (Time.get_ticks_usec() - t_kur) / 1000.0
	stats["kur_ms_max"] = maxf(stats["kur_ms_max"], ms)
	stats["kur_n"] += 1
	_cost["%s/%d" % [String(it.get("mod", "")), lod]] = ms
	_yavas_say(it, str(lod), ms, pis_ms)
	it["have"][lod] = n
	_show(it)


## Eser paletine giren öğeler: surlar, sur kapıları (SUR-4), ordugâh, gemiler, yaşam ve hub (bölümün kendi şehri) hariç
const PALETSIZ := ["surlar", "surlar_kapi", "surlar_ayrinti", "marmara_sur", "marmara_kit", "halic_sur", "galata_sur",
	"ordugah", "gemiler", "hayat"]

func _paletli(it: Dictionary) -> bool:
	if it.has("hat") or it.has("glen") or it.get("tek", false):
		return false
	var mod := String(it.get("mod", ""))
	if String(it.get("id", "")) in ["hub_sehir", "zincir"]:
		return false
	for p: String in PALETSIZ:
		if mod.begins_with(p):
			return false
	return true


## İkinci iş: bekleyen yakın katmanın pişirilmesi ve gösterilmesi
func _pis(it: Dictionary) -> void:
	var n: Node3D = it["pis_n"]
	it.erase("pis_n")
	if not is_instance_valid(n):
		return
	var t0 := Time.get_ticks_usec()
	_bake_lod(n, false)
	n.visible = true
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	_cost["%s/0" % String(it.get("mod", ""))] = ms
	_yavas_say(it, "0p", ms, ms)
	it["have"][0] = n
	_show(it)


## Pencereyle (kurucunun x penceresi) kurulan uzun sur dilimleri: kara suru (IstSurlar) ve deniz surları (IstMk)
const PENCERE_M := 7.0

func _pencereli(it: Dictionary) -> bool:
	if not it.has("hat") or not it.has("len"):
		return false
	var kur := String(HAT.get(String(it["hat"]), {}).get("kur", ""))
	return kur == "kara" or it.get("mk", false)


## Yakın katmanın bir penceresi (kur + pişir); hepsi bitince katman görünür olur
func _pencere_is(it: Dictionary) -> void:
	var L := float(it["len"])
	var N := maxi(1, ceili(L / PENCERE_M))
	if not it.has("sub"):
		var n0 := Node3D.new()
		n0.name = "L0"
		n0.visible = false
		(it["holder"] as Node3D).add_child(n0)
		it["sub"] = {"n": n0, "i": 0, "N": N}
	var sb: Dictionary = it["sub"]
	var i := int(sb["i"])
	var t0 := Time.get_ticks_usec()
	var x0 := -1e9 if i == 0 else -L * 0.5 + L * i / N
	var x1 := 1e9 if i == N - 1 else -L * 0.5 + L * (i + 1) / N
	var w := Node3D.new()
	w.name = "W%d" % i
	(sb["n"] as Node3D).add_child(w)
	IstSurlar.pencere = Vector2(x0, x1)
	IstMk.pencere = Vector2(x0, x1)
	(it["make"] as Callable).call(w, 0)
	IstSurlar.pencere = Vector2(-1e9, 1e9)
	IstMk.pencere = Vector2(-1e9, 1e9)
	_kapi_gecit_hat(it, w)
	_bake_lod(w, false)
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	_cost["%s/0" % String(it.get("mod", ""))] = ms
	_yavas_say(it, "0w", ms, 0.0)
	if ms > float(stats.get("pencere_ms", 0.0)):
		stats["pencere_ms"] = ms
		stats["pencere_en"] = "%s i=%d/%d" % [String(it["id"]), i, N]
	sb["i"] = i + 1
	if i + 1 >= N:
		it.erase("sub")
		(sb["n"] as Node3D).visible = true
		it["have"][0] = sb["n"]
		_show(it)


func _yavas_say(it: Dictionary, lk: String, ms: float, pis_ms: float) -> void:
	stats["kur_ms_max"] = maxf(stats["kur_ms_max"], ms)
	if ms <= 6.0:
		return
	if not stats.has("yavas"):
		stats["yavas"] = {}
	var mk := String(it["mod"])
	if mk == "v2":
		mk = String(it["id"]).get_slice("_", 0)
	elif mk == "doku":
		mk = "doku_" + String(it["id"]).get_slice("_", 1)
	var key := "%s/%s" % [mk, lk]
	stats["yavas"][key] = maxf(float(stats["yavas"].get(key, 0.0)), ms)
	if not stats.has("yavas_pis"):
		stats["yavas_pis"] = {}
	stats["yavas_pis"][key] = maxf(float(stats["yavas_pis"].get(key, 0.0)), pis_ms)


## Deniz surları: yürüme yolu kule tepelerine basamakla çıkar; kule tepe korkuluğu yolu enine kesiyordu
func _kapi_gecit_hat(it: Dictionary, n: Node3D) -> void:
	var kur := String(HAT.get(String(it["hat"]), {}).get("kur", ""))
	if not kur in ["marmara", "halic"]:
		return
	var dm := IstMarmaraSur.dims(K_SUR)
	var hh := float(dm["H"])
	var top := float(dm["TH"])
	if kur == "halic" and absf(float(it["len"]) - float(IstHalicSur.dims(K_SUR)["L"])) < 0.05:
		hh = float(IstHalicSur.dims(K_SUR)["H"])
		top = hh + float(IstHalicSur.dims(K_SUR)["TH"])
	var lo_y := float(it["walk"]) - float(it["pos"].y) - hh
	_kapi_gecit(n, hh + lo_y - 0.35, top + lo_y + 0.35)


## Kurşun kubbe ve çatılar (kalite notu 3; docs/ISTANBUL_GORUNUS.md: mat kurşun gri #6E7276): parçaların açık mavi-gri
## kurşun tonları güneş ve gök ışığında açık maviye kaçıyor, ufukta ev çatılarının arasında kayboluyordu. Mavimsi açık griler
## koyu kurşuna çevrilir, hafif metal parıltı (silüette seçilsin). Malzeme önbellekli (pişirmede tek yüzeyde birleşir).
static var _kursun_mat := {}
const KURSUN := Color("6a7078")          # ŞEHİR-3: #4C525A toon ışıkta lacivert-siyah görünüyordu (Khora, Pammakaristos)

func _kursun(n: Node3D) -> void:
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null:
			continue
		for si in mi.mesh.get_surface_count():
			var m := mi.get_active_material(si)
			if not (m is StandardMaterial3D):
				continue
			var sm := m as StandardMaterial3D
			if sm.vertex_color_use_as_albedo or sm.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or sm.emission_enabled:
				continue
			var col := sm.albedo_color
			if not (col.b >= col.r + 0.02 and col.s < 0.3 and col.get_luminance() > 0.38 and col.get_luminance() < 0.8):
				continue
			var key := sm.get_instance_id()
			if not _kursun_mat.has(key):
				var d := sm.duplicate() as StandardMaterial3D
				d.albedo_color = KURSUN.lerp(col, 0.1)
				d.rim_enabled = false
				d.metallic = 0.15
				d.metallic_specular = 0.5
				d.roughness = 0.55
				_kursun_mat[key] = d
			stats["kursun_n"] = int(stats.get("kursun_n", 0)) + 1
			# material_override yüzey başına malzemeden önce gelir
			if mi.material_override == m:
				mi.material_override = _kursun_mat[key]
			else:
				mi.set_surface_override_material(si, _kursun_mat[key])


## Kalite notu 16 (tam tepeden ve uzaktan siyah düz yüzeyler) — KÖK NEDEN: Props/Dressing malzemelerinin dış çizgi
## geçişi (next_pass: siyah, CULL_FRONT, grow, derinlik yazmaz). Uzakta (≥ 300 m) derinlik ara belleğinin çözünürlüğü
## ince levhanın (forum döşemesi 0,1 m, sarnıç tabanı, çatı levhası) üst yüzüyle büyütülmüş alt yüzünü ayıramaz:
## arka yüzlerin siyah çizgi kopyası üst yüzün önüne geçer (düz kenarlı yarım kara alanlar; yakında yok). Orta ve uzak
## katmanda dış çizgi zaten piksel altıdır: bu katmanların malzemelerinden söküldü (malzeme önbellekli).
static var _cizgisiz_mat := {}

static func _cizgisiz_of(m: Material) -> Material:
	if m == null:
		return m
	var vc := m is BaseMaterial3D and (m as BaseMaterial3D).vertex_color_use_as_albedo and not (m as BaseMaterial3D).vertex_color_is_srgb
	if m.next_pass == null and not vc:
		return m
	var key := m.get_instance_id()
	if not _cizgisiz_mat.has(key):
		var d := m.duplicate() as Material
		d.next_pass = null
		if vc:
			# pişmiş köşe rengi sRGB (albedo_color'dan): doğrusal sayılınca uzak katman yakınından açık görünüyordu
			(d as BaseMaterial3D).vertex_color_is_srgb = true
		_cizgisiz_mat[key] = d
	return _cizgisiz_mat[key]


static func _cizgisiz(n: Node) -> void:
	for c in n.find_children("*", "GeometryInstance3D", true, false):
		var gi := c as GeometryInstance3D
		if gi.material_override != null:
			gi.material_override = _cizgisiz_of(gi.material_override)
		var mesh: Mesh = null
		if gi is MeshInstance3D:
			mesh = (gi as MeshInstance3D).mesh
			if mesh != null:
				for si in mesh.get_surface_count():
					var om := (gi as MeshInstance3D).get_surface_override_material(si)
					var sm := om if om != null else mesh.surface_get_material(si)
					if sm != null and _cizgisiz_of(sm) != sm:
						(gi as MeshInstance3D).set_surface_override_material(si, _cizgisiz_of(sm))
		elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh and (gi as MultiMeshInstance3D).multimesh.mesh:
			mesh = (gi as MultiMeshInstance3D).multimesh.mesh
			if gi.material_override == null:
				for si in mesh.get_surface_count():
					var sm := mesh.surface_get_material(si)
					if sm != null and sm.next_pass != null:
						# MultiMesh paylaşılan ağ: yüzey malzemesi yerine örnek başına geçersiz kılma (tek yüzeyli ağlarda)
						if mesh.get_surface_count() == 1:
							gi.material_override = _cizgisiz_of(sm)


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
	if v2:
		mi.lod_bias = 128.0
		if flat:
			# Uzak katman: gölge düşürmez (tam tepeden ve uzaktan forum döşemesi, sarnıç tabanı, çatı levhası gölge
			# haritasının kaba çözünürlüğünde simsiyah kalıyordu); yatay yüzlerin normali yukarı
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.mesh = _yukari_normal(mi.mesh)
	n.add_child(mi)


static func _yukari_normal(m: Mesh) -> Mesh:
	if m == null:
		return m
	var am := ArrayMesh.new()
	for si in m.get_surface_count():
		var arr := m.surface_get_arrays(si)
		var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var ns = arr[Mesh.ARRAY_NORMAL]
		if not (ns is PackedVector3Array) or (ns as PackedVector3Array).size() != vs.size():
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
			am.surface_set_material(si, m.surface_get_material(si))
			continue
		var nn: PackedVector3Array = ns
		var ia = arr[Mesh.ARRAY_INDEX]
		var idx: PackedInt32Array = ia if ia is PackedInt32Array else PackedInt32Array()
		var cnt := idx.size() if idx.size() > 0 else vs.size()
		for t in range(0, cnt - 2, 3):
			var a: int = idx[t] if idx.size() > 0 else t
			var b: int = idx[t + 1] if idx.size() > 0 else t + 1
			var c: int = idx[t + 2] if idx.size() > 0 else t + 2
			var fnrm := (vs[b] - vs[a]).cross(vs[c] - vs[a])
			var L := fnrm.length()
			if L < 1e-6:
				continue
			fnrm /= L
			if absf(fnrm.y) > 0.7:
				var up := fnrm if fnrm.y > 0.0 else -fnrm
				for v: int in [a, b, c]:
					if nn[v].y < 0.3:
						nn[v] = up
		arr[Mesh.ARRAY_NORMAL] = nn
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		am.surface_set_material(si, m.surface_get_material(si))
	return am


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
			# Zaten köşe renkli pişmiş ağ (parçanın kendi Props.bake_static'i): World1453.bake köşe rengini malzemenin
			# beyaz albedo'suyla ezerdi (ŞEHİR-3: kara surlarında gri gürültü dokulu toprak şeritleri bembeyaz çıkıyordu)
			if bm.vertex_color_use_as_albedo:
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
			if int(job[2]) == 0 and (job[1] as Dictionary).has("sub") and Time.get_ticks_usec() - t0 > 300:
				break
			if float(_cost.get(key, 0.0)) * 1000.0 > BUDGET_US - (Time.get_ticks_usec() - t0) and Time.get_ticks_usec() - t0 > 300:
				break
		_queue.pop_front()
		if job[0] == "item":
			var it: Dictionary = job[1]
			if int(it["want"]) <= int(job[2]):
				_build(it, int(job[2]), true)
				# pencereli/iki işli yakın katman: kalan iş bir sonraki karede (sıranın başında)
				if int(job[2]) == 0 and (it.has("sub") or it.has("pis_n")):
					_queue.push_front(job)
					break
		elif job[0] == "cell":
			_cell_up(job[1], true)
			# çarpışma bir sonraki karede (sıranın başında)
			if (job[1] as Dictionary).get("col_bekle", false):
				_queue.push_front(["cellcol", job[1]])
				break
		elif job[0] == "cellcol":
			_cell_col(job[1])


func _plan(cp: Vector3) -> void:
	_queue.clear()
	var jobs: Array = []
	for it: Dictionary in items:
		if it.get("tek", false):
			continue
		var p: Vector3 = it["pos"]
		var d := Vector3(p.x - cp.x, (p.y - cp.y) * 1.3, p.z - cp.z).length() - float(it["r"])
		var r1 := float(it.get("r1", R1))
		var want := 0 if d < R0 else (1 if d < r1 else 2)
		it["want"] = want
		# Boşalt: payın ötesindeki ince katmanlar (yarım kalmış yakın katman da)
		if d > R0 + HYST and want > 0:
			for kk: String in ["pis_n", "sub"]:
				if it.has(kk):
					var pn0 = it[kk] if kk == "pis_n" else it[kk]["n"]
					it.erase(kk)
					if is_instance_valid(pn0):
						(pn0 as Node).queue_free()
		for l in 2:
			var lim := R0 if l == 0 else r1
			if it["have"][l] != null and d > lim + HYST and want > l:
				if it.has("pre"):
					# ön-pişirilmiş: ağaçtan ayrılır, bellekte bekler (yeniden yaklaşınca kurulmaz, bağlanır)
					var on: Node3D = it["have"][l]
					on.get_parent().remove_child(on)
					it["pre"][l] = on
				else:
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
		elif c.get("col_bekle", false):
			jobs.append([d - 1000.0, ["cellcol", c]])
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
func _cell_up(c: Dictionary, bol := false) -> void:
	if c["up"]:
		return
	c["up"] = true
	var t0 := Time.get_ticks_usec()
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
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	_hucre_say("ev_gorsel", ms)
	if v2 and bol:
		# çarpışma ayrı işte (sonraki kare; ŞEHİR-3 zaman dilimi): _plan bekleyen hücreyi öne alır
		c["col_bekle"] = true
	else:
		_cell_col(c)


## Hücrenin ev/kaide/taş çarpışması: gövde şekiller eklendikten SONRA ağaca bağlanır (ağaçtaki gövdeye her şekil
## eklenişi fizik sunucusunu güncelliyordu)
func _cell_col(c: Dictionary) -> void:
	c.erase("col_bekle")
	if not c["up"] or c["col"] != null:
		return
	var t0 := Time.get_ticks_usec()
	var body := StaticBody3D.new()
	body.name = "EvCarpisma"
	for key: String in c["groups"]:
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
	add_child(body)
	c["col"] = body
	_hucre_say("ev_carpisma", (Time.get_ticks_usec() - t0) / 1000.0)


func _hucre_say(k: String, ms: float) -> void:
	stats["kur_ms_max"] = maxf(stats["kur_ms_max"], ms)
	if v2 and ms > 6.0:
		if not stats.has("yavas"):
			stats["yavas"] = {}
		stats["yavas"][k] = maxf(float(stats["yavas"].get(k, 0.0)), ms)


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
## Ölçekler (ikinci tur SON AYAR, docs/_ajan/gorev/_ist2_ortak.md): dünya IstGeo.S (tek sabit; bütün konumlar IstGeo'dan
## türer); ünlü eserler ve yan görev eserleri k = 0,75; öteki anıt ve kiliseler 0,6; çok yer kaplayanlar 0,45–0,5;
## surların ve sur kapılarının kesiti 1:1 (k = 1,0; uzunluk hat boyunca S ile); Ayasofya: var olan model × 1,5.
const K_UNLU := 0.75
const K_OTEKI := 0.6
const K_SUR := 1.0
const AYA_K := 1.5
const K2 := K_OTEKI
## Ünlü eserler (k = 0,75); ayrıca catalog() kaydında "gorev": true olan her eser ve kapı türündeki her kayıt
## Manastır avlusuyla kurulan kiliseler (ŞEHİR-3; "küçük ve yalın" kusuru): kimlik → avlunun yarı eni/boyu (yerel m)
const MANASTIR := {"khora": Vector2(22.0, 24.0), "pammakaristos": Vector2(23.0, 24.0)}
const UNLU := ["konstantin", "arkadius", "iustinianus", "havariyun", "pantokrator", "khora", "pammakaristos", "studios",
	"aya_irini", "tekfur", "galata_kulesi", "tauri", "sergios", "theodosius", "markianos", "halic_eugenios"]
## Gerçek yerinden hiç kaymayanlar (silüetin çapaları; öbürleri bunların çevresinden itilir)
const SABIT_UNLU := ["galata_kulesi", "hipodrom", "konstantin", "havariyun", "pantokrator", "khora", "tekfur", "studios"]
## Çok yer kaplayanlar: kimlik → k (Hipodrom, Büyük Saray harabesi, limanlar, açık sarnıç bostanları, forum meydanları)
const GENIS := {"augustaion": 0.45, "zeuksippos": 0.5, "konstantin": 0.6, "tauri": 0.6, "hipodrom": 0.45, "buyuk_saray": 0.34, "bukoleon": 0.5, "kontoskalion": 0.45, "langa": 0.45, "sophia": 0.45,
	"aetios": 0.45, "aspar": 0.45, "mokios": 0.45, "philadelphion": 0.5, "kapitolion": 0.5, "amastrianon": 0.5, "bovis": 0.5,
	"myrelaion": 0.55, "anemodoulion": 0.5, "halic_neorion": 0.5, "halic_iskele": 0.5}


## Kaydın v2 ölçeği (YER2'deki "k" önceliklidir)
static func _k2(id: String, data: Dictionary) -> float:
	var fix: Dictionary = YER2.get(id, {})
	if fix.has("k"):
		return float(fix["k"])
	var tur := String(data.get("tur", ""))
	if fix.has("hat") and tur in ["kapi", "sur"]:
		return K_SUR
	if GENIS.has(id):
		return float(GENIS[id])
	if tur == "liman":
		return 0.5
	if id in UNLU or data.get("gorev", false) or tur == "kapi":
		return K_UNLU
	if tur in ["ev", "ayrinti", "bitki"]:
		return 1.0
	return K_OTEKI
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
	"arkadius": {"e": -3419.0, "n": -678.0},       # Cerrahpaşa 41,0025 / 28,9395 (dizindeki n −956 kıyıya düşüyordu)
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
	"anemas": {"e": -3170.0, "n": 3360.0},          # Blakherna Sarayı avlusuyla çakışmasın (ŞEHİR-3)
	"blakhernai_kilise": {"e": -3170.0, "n": 3220.0},
	"aetios": {"e": -3420.0, "n": 1880.0},
	"kaligaria": {"e": -2980.0, "n": 2760.0},
	# guneybati: Studios (İmrahor) dizinden, Andreas (Koca Mustafa Paşa), Mokios (Altımermer), Samatya
	"studios": {"e": -4368.0, "n": -1345.0},       # İmrahor 40,9965 / 28,9282 (dizindeki n −1790 deniz surunun dibi)
	"andreas": {"e": -3940.0, "n": -570.0},
	"mokios": {"e": -3600.0, "n": -450.0},
	"psamathia": {"e": -3671.0, "n": -1215.0},   # balıkçı iskelesiyle çakışmasın (kıyıdan 130 m içeri)
	"peribleptos": {"e": -3050.0, "n": -1250.0},
	"diomedes": {"e": -4600.0, "n": -1450.0},
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
	"balikci": {"e": -3700.0, "n": -1420.0, "kiyi": "marmara_suru"},
	"agsehpa": {"e": -3740.0, "n": -1410.0, "kiyi": "marmara_suru"},
	# halic: modülün konumları Sarayburnu'nda kümelenmişti (doğu −520…470); gerçek sırayla kıyı boyunca (kestirim)
	"halic_yahudi": {"e": -1193.0, "n": 957.0, "kiyi": "halic_suru"},
	"halic_iskele": {"e": -1025.0, "n": 900.0, "kiyi": "halic_suru"},
	"halic_venedik": {"e": -857.0, "n": 935.0, "kiyi": "halic_suru"},
	"halic_balik": {"e": -731.0, "n": 913.0, "kiyi": "halic_suru"},
	"halic_pisa_amalfi": {"e": -605.0, "n": 840.0, "kiyi": "halic_suru"},
	"halic_neorion": {"e": -479.0, "n": 801.0, "kiyi": "halic_suru"},
	"halic_ceneviz": {"e": -353.0, "n": 760.0, "kiyi": "halic_suru"},
	"halic_eugenios": {"e": -150.0, "n": 790.0, "kiyi": "halic_suru", "ic": 4.0},   # kule kıyıda, zincir ucu suda
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
	var t3 := Time.get_ticks_msec()
	s._on_pisir()
	var t4 := Time.get_ticks_msec()
	print("ISTONPISIR ms=%d adet=%d kursun=%d" % [t4 - t3, s.stats.get("on_pisir_n", 0), s.stats.get("kursun_n", 0)])
	t3 = t4
	s._parcalar_bagla(dunya, gece_)
	for r: Rect2 in s.oyun_alanlari():
		var rc := IstGeo.real(r.get_center().x, r.get_center().y)
		print("ISTOYUN alan dunya_merkez=(%.0f, %.0f) boyut=%s gercek=(%.0f, %.0f)" % [r.get_center().x, r.get_center().y, r.size, rc.x, rc.y])
	print("ISTSEHIR2 yer=%d hat=%d kur_ms=%d hat_ms=%d doku_ms=%d parca_ms=%d" % [s.items.size(), s.hat_items.size(), t1 - t0, t2 - t1, t3 - t2, Time.get_ticks_msec() - t3])


## Ön-pişirme (kalite notu 8: tek iş ≤ 6 ms): anıtların (modül kayıtları ve Mese dilimleri) orta katmanı (lod 1) açılışta
## kurulur (gizli bekler); yakın katmanı (lod 0) açılışta kurulup ölçülür: kurulumu ON_PISIR_MS'yi aşanlarınki ağaçtan ayrık
## bellekte bekler (yaklaşınca yalnız ağaca bağlanır), ötekiler boşaltılır (akışta kurulur; zaten ucuz).
static var on_pisirme := true
const ON_PISIR_MS := 4.0

func _on_pisir() -> void:
	if not on_pisirme:
		return
	var n := 0
	for it: Dictionary in items:
		var mod := String(it.get("mod", ""))
		var id := String(it["id"])
		var hat := it.has("hat") or id.begins_with("kose_")
		if not hat and mod == "v2" and not id.begins_with("mese_") and not id in ["ayasofya", "blakherna", "bozdogan", "zincir", "hub_sehir", "meydan_aya_cevre"]:
			continue
		var h := it["holder"] as Node3D
		_build(it, 1)
		if hat:
			# sur dilimi: orta katman açılışta (lod 0 akışta: dilim başına ön-pişirme bellek açısından çok pahalı)
			it["pre"] = [null, null, null]
			it["want"] = 2
			_show(it)
			continue
		var t0 := Time.get_ticks_usec()
		_build(it, 0)
		var ms := (Time.get_ticks_usec() - t0) / 1000.0
		var l0: Node3D = it["have"][0]
		it["have"][0] = null
		it["pre"] = [null, null, null]
		if ms > ON_PISIR_MS:
			h.remove_child(l0)
			it["pre"][0] = l0
			n += 1
		else:
			l0.free()
		it["want"] = 2
		_show(it)
	stats["on_pisir_n"] = n
	# Isınma: ev hücrelerindeki her örneğin yakın ağı (IstEvler.mesh lod 0) açılışta üretilir (ilk hücre 60–90 ms sürüyordu)
	var anahtar := {}
	for c: Dictionary in _cells0:
		for key: String in c["groups"]:
			anahtar[key] = true
	for key: String in anahtar:
		_mesh_for(key, 0)
	stats["isin_ev_n"] = anahtar.size()
	# Isınma: her sur kurucusunun yakın katmanı bir kez (desen dokuları, paylaşılan ağlar ve malzemeler önbelleğe girer;
	# oyunda ilk dilimin ilk penceresi bunları üretirken 40–70 ms sürüyordu). Kurulan atılır.
	var isin := {}
	for it: Dictionary in hat_items:
		var kur := String(HAT.get(String(it.get("hat", "")), {}).get("kur", ""))
		if kur == "" or isin.has(kur) or not it.has("len"):
			continue
		isin[kur] = true
		var tmp := Node3D.new()
		add_child(tmp)
		(it["make"] as Callable).call(tmp, 0)
		_bake_lod(tmp, false)
		tmp.free()
	# açılıştaki ölçümler oyun içi "yavaş iş" sayılmaz
	stats.erase("yavas")
	stats["kur_ms_max"] = 0.0


## İkinci turun yeni parçaları (dalları birleştirilmişse): Osmanlı ordugâhı (sur dışı), gemiler (su), yaşam katmanı
## (insan/hayvan/duman/gece ışıkları; sokak ağını IstSehir.sokak'tan okur, bu yüzden dokudan SONRA). Dosyası yoksa atlanır.
const PARCA_V2 := [["ordugah", "IstOrdugah"], ["gemiler", "IstGemiler"], ["hayat", "IstHayat"]]
static var parcalar_acik := true
var parca_durum := {}

func _parcalar_bagla(dunya: Node3D, gece_: bool) -> void:
	if not parcalar_acik:
		return
	for pr: Array in PARCA_V2:
		var path := DIR + String(pr[0]) + ".gd"
		if not ResourceLoader.exists(path):
			parca_durum[pr[1]] = "yok"
			continue
		var scr := load(path) as GDScript
		if scr == null:
			parca_durum[pr[1]] = "yuklenemedi"
			continue
		var t0 := Time.get_ticks_msec()
		scr.call("attach", dunya, gece_)
		parca_durum[pr[1]] = "%d ms" % (Time.get_ticks_msec() - t0)
	print("ISTPARCA ", parca_durum)


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
	var k := _k2(id, data)
	var s: Vector3 = data.get("gercek_olcu", Vector3(20, 10, 20))
	var r := maxf(s.x, s.z) * k * 0.5
	if fix.has("hat"):
		var pl := _sade(IstGeo.yol(String(fix["hat"])))
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
			if fix.has("ic"):
				ic = float(fix["ic"])
			w = sn["p"] - o * ic
			yaw = atan2(o.x, o.y)               # Marmara parçaları: yerel +z denize
			if String(e["mod"]).begins_with("halic") or String(e["mod"]).begins_with("kuzeybati"):
				yaw = atan2(-o.x, -o.y)         # Haliç parçaları: yerel −z denize, +z şehre
	# Suya düştüyse en yakın karaya (liman hariç)
	if String(data.get("tur", "")) != "liman" and IstGeo.su(w.x, w.y):
		w = _to_land(w)
	var y := _taban_y(w, yaw, s, k, r, String(data.get("tur", "")))
	return {"pos": Vector3(w.x, y - 0.03 + float(fix.get("dy", 0.0)), w.y), "yaw": yaw, "k": k, "r": r,
		"sabit": fix.has("hat") or fix.has("kiyi"), "w0": w}


## Taban yüksekliği: küçük yapıda dört köşe + ortanın en alçağı, büyükte (r > 25 m) ortanca
static func _taban_y(w: Vector2, yaw: float, s: Vector3, k: float, r: float, tur: String) -> float:
	var hs: Array = []
	var u := Vector2(cos(-yaw), sin(-yaw))
	for o: Vector2 in [Vector2.ZERO, Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
		var q := w + Vector2(u.x * o.x * s.x * k * 0.45 - u.y * o.y * s.z * k * 0.45, u.y * o.x * s.x * k * 0.45 + u.x * o.y * s.z * k * 0.45)
		hs.append(IstGeo.h(q.x, q.y))
	hs.sort()
	var y: float = hs[2] if r > 25.0 else hs[0]
	if tur == "liman":
		y = maxf(y, 0.0)
	return y


## Çakışma çözümü (S küçülünce eserler birbirine yaklaşır): taban daireleri (yarıçap + PAY) kesişen iki eser, merkezlerini
## birleştiren doğru boyunca itilir (gerçek komşuluk sırası korunur: kimse komşusunun öbür yanına geçmez). Öncelik: yan görev /
## ünlü eserler (2) > öteki anıtlar (1); öncelik farkında yalnız düşük olan kayar; eşitte ikisi yarı yarıya. Hatta/kıyıya
## oturanlar (surlar, kapılar, limanlar), Ayasofya, Blakherna Sarayı ve oyun alanları SABİT engeldir. Kayan eser denize,
## sur dışına ya da sur bandına düşerse o adım geri alınır. Hiçbir eser atılmaz; kalan çakışmalar raporlanır.
const CAKISMA_PAY := 5.0
var cakisma_rapor: Array = []

func _coz_cakisma(c: Array) -> void:
	var n := c.size()
	for it in 80:
		var moved := false
		for i in n:
			var A: Dictionary = c[i]
			for j in range(i + 1, n):
				var B: Dictionary = c[j]
				if (A["sabit"] and B["sabit"]) or A.get("cozme", false) or B.get("cozme", false):
					continue
				var pa: Vector2 = A["w"]
				var pb: Vector2 = B["w"]
				var need := float(A["r"]) + float(B["r"]) + CAKISMA_PAY
				var d := pa.distance_to(pb)
				if d >= need:
					continue
				var dir := (pb - pa) / d if d > 0.01 else Vector2.from_angle(float(i * 7 + j))
				var gap := (need - d) * 0.55 + 0.5
				var wa := 0.5
				var wb := 0.5
				if A["sabit"] or int(A["prio"]) > int(B["prio"]):
					wa = 0.0
					wb = 1.0
				elif B["sabit"] or int(B["prio"]) > int(A["prio"]):
					wa = 1.0
					wb = 0.0
				if wa > 0.0 and not _kaydir(A, pa - dir * gap * wa):
					wb = 1.0
				if wb > 0.0 and not _kaydir(B, pb + dir * gap * wb) and wa == 0.0 and not A["sabit"]:
					_kaydir(A, pa - dir * gap)
				moved = true
		if not moved:
			break
	cakisma_rapor.clear()
	for i in n:
		var A: Dictionary = c[i]
		var sh := (A["w"] as Vector2).distance_to(A["w0"])
		if sh > 1.0:
			cakisma_rapor.append("%s kaydi=%.0f m" % [A["id"], sh])
		for j in range(i + 1, n):
			var B: Dictionary = c[j]
			if A.get("cozme", false) or B.get("cozme", false):
				continue
			if (A["w"] as Vector2).distance_to(B["w"]) < float(A["r"]) + float(B["r"]) - 2.0 and not (A["sabit"] and B["sabit"]):
				cakisma_rapor.append("KALAN %s~%s" % [A["id"], B["id"]])


## Kapı koşusunun yürüme yolunu enine kesen alçak korkuluklar (kapı kulesinin tepe çevresi yürüme yolu hizasında kalıyor):
## yürüme yolu şeridinde (yerel z ±2) bu korkuluklar kaldırılır, üstündeki mazgallar da (sur üstünde kesintisiz yürüyüş)
func _kapi_gecit(n: Node3D, ymin: float, ymax: float) -> void:
	var gone: Array = []
	for b in n.find_children("*", "StaticBody3D", true, false):
		var body := b as StaticBody3D
		for cs in body.get_children():
			if not (cs is CollisionShape3D and (cs as CollisionShape3D).shape is BoxShape3D):
				continue
			var sz := ((cs as CollisionShape3D).shape as BoxShape3D).size
			var root := n
			var lp := root.global_transform.affine_inverse() * (cs as Node3D).global_position if root.is_inside_tree() else body.position
			var bot := lp.y - sz.y * 0.5
			# korkuluk: tabanı bant içinde VE tepesi bandın üstünde (yürüme yolunun/kule tepesinin üstüne çıkan duvarcık).
			# Kule merdiveninin basamakları da ince, enine ve tabanı yürüme yolunda: tepeleri kule tepesini aşmaz, kalır
			# (ŞEHİR-3: önce ilk altı basamak siliniyordu, oyuncu yedinci basamağın dibinde kalıyordu)
			if sz.x < 0.7 and sz.y < 1.8 and sz.z > 2.0 and bot > ymin and bot < ymax and bot + sz.y > ymax and absf(lp.z) < sz.z * 0.5 - 0.6:
				gone.append(Rect2(lp.x - 0.6, lp.z - sz.z * 0.5, 1.2, sz.z))
				body.get_parent().remove_child(body)
				body.free()
				break
	if gone.is_empty():
		return
	for m in n.find_children("*", "MultiMeshInstance3D", true, false):
		var mmi := m as MultiMeshInstance3D
		var mm := mmi.multimesh
		if mm == null:
			continue
		var keep: Array = []
		for i in mm.instance_count:
			var t := mm.get_instance_transform(i)
			var lp2 := t.origin
			var hit := false
			for r: Rect2 in gone:
				if r.has_point(Vector2(lp2.x, lp2.z)) and lp2.y > ymin and lp2.y < ymax + 2.5:
					hit = true
			if not hit:
				keep.append(t)
		if keep.size() != mm.instance_count:
			var nm := MultiMesh.new()
			nm.transform_format = MultiMesh.TRANSFORM_3D
			nm.mesh = mm.mesh
			nm.instance_count = keep.size()
			for i in keep.size():
				nm.set_instance_transform(i, keep[i])
			mmi.multimesh = nm
	stats["kapi_gecit"] = int(stats.get("kapi_gecit", 0)) + gone.size()


## Hatta oturan kayıtlar (kapılar, kuleler) hat boyunca sıralanır: kapı koşusu GATE_L (modülün 150 m'si yerine), ardışık
## iki kaydın aralıkları üst üste binmez (sıra korunur: gerekirse bir sonraki ileri itilir), hattın uçlarından pay bırakılır.
const GATE_L := 60.0

func _hat_dizi(c: Array) -> void:
	var by_line := {}
	for A: Dictionary in c:
		if not A.has("e"):
			continue
		var fix: Dictionary = YER2.get(String(A["id"]), {})
		if not fix.has("hat"):
			continue
		if String(A["tur"]) == "sur":
			A["cozme"] = true
			continue
		var ad := String(fix["hat"])
		var pl := _sade(IstGeo.yol(ad))
		if pl.size() < 2:
			continue
		var sn := _snap(pl, A["w"])
		var g := float(A["r"]) * 1.4
		if String((A["e"] as Dictionary)["mod"]) == "surlar" and IstSurlar.OPTS.has(String(A["id"])):
			g = minf(GATE_L, IstSurlar._gate_len(String(A["id"]), K_SUR))
			A["glen"] = g
		A["s"] = float(sn["s"])
		A["g"] = g
		if not by_line.has(ad):
			by_line[ad] = [pl, []]
		by_line[ad][1].append(A)
	for ad: String in by_line:
		var pl: PackedVector2Array = by_line[ad][0]
		var list: Array = by_line[ad][1]
		var tot := 0.0
		for i in pl.size() - 1:
			tot += pl[i].distance_to(pl[i + 1])
		list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["s"]) < float(b["s"]))
		var prev_end := 4.0
		for A: Dictionary in list:
			var g := float(A["g"])
			var fix: Dictionary = YER2.get(String(A["id"]), {})
			if fix.has("uc"):
				prev_end = maxf(prev_end, float(A["s"]) + g * 0.5 + 6.0)
				continue
			var s0 := float(A["s"])
			var sv := clampf(maxf(s0, prev_end + g * 0.5 + 6.0), g * 0.5 + 10.0, tot - g * 0.5 - 10.0)
			prev_end = sv + g * 0.5
			if absf(sv - s0) > 0.5:
				var q := _hat_s(pl, sv)
				var d: Vector2 = q[1]
				A["w"] = q[0]
				var yaw := _yaw_x(d, q[0], ad)
				if String((A["e"] as Dictionary)["mod"]).begins_with("halic"):
					yaw += PI
				A["yaw"] = yaw
				print("ISTHATKAY %s %.0f m" % [A["id"], sv - s0])
		var sira: Array = []
		for A: Dictionary in list:
			sira.append(String(A["id"]))
		print("ISTHATDIZI %s %s" % [ad, ",".join(sira)])


## Çizginin yay boyu sv'deki noktası ve yönü: [Vector2, Vector2]
static func _hat_s(pl: PackedVector2Array, sv: float) -> Array:
	var acc := 0.0
	for i in pl.size() - 1:
		var L := pl[i].distance_to(pl[i + 1])
		if acc + L >= sv or i == pl.size() - 2:
			var t := clampf((sv - acc) / L, 0.0, 1.0)
			return [pl[i].lerp(pl[i + 1], t), (pl[i + 1] - pl[i]) / L]
		acc += L
	return [pl[0], Vector2.RIGHT]


func _kaydir(A: Dictionary, q: Vector2) -> bool:
	if A["sabit"]:
		return false
	if String(A["tur"]) != "liman" and (IstGeo.su(q.x, q.y) or not (IstGeo.sehir_ici(q.x, q.y) or IstGeo.galata_ici(q.x, q.y))):
		return false
	var r := float(A["r"])
	for ad: String in ["kara_suru", "blakherna_suru", "marmara_suru", "halic_suru"]:
		var pl := IstGeo.yol(ad)
		if pl.size() >= 2 and IstGeo.cizgi_uzak(q, pl) < r * 0.8 + (14.0 if ad == "kara_suru" else 8.0):
			if IstGeo.cizgi_uzak(q, pl) < IstGeo.cizgi_uzak(A["w"], pl):
				return false
	# kayma payı: gerçek yerinden en çok yarıçapın 1,6 katı + 40 m
	if q.distance_to(A["w0"]) > r * 1.6 + 40.0:
		return false
	A["w"] = q
	return true


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
	IstGeo.duzle(aw, 34.0 * AYA_K, ay)
	var ait := _v2_item("ayasofya", Vector3(aw.x, ay - 0.05, aw.y), -deg_to_rad(103.0), 40.0 * AYA_K, _make_aya)
	ait["k"] = AYA_K
	ait["data"] = {"gercek_olcu": Vector3(54, 40, 54), "gorev": true}
	# Kubbenin tepesindeki haçın 3,5 m yanı (kurşun kubbe yüzeyi; model × AYA_K): her uzaklıkta katı konma kapağı
	var ap := (ait["holder"] as Node3D).transform * (Vector3(3.5, 19.5 + 11.1 * 0.42 * sqrt(1.0 - pow(3.5 / 11.1, 2.0)), 0) * AYA_K)
	_pad(ap, "Konma_ayasofya")
	ait["perch_aya"] = ap
	# Blakherna Sarayı: Blachernae.shell_parts ("palace"), Blakherna suruna yaslı
	var bl := IstGeo.w2(-3402.0, 3436.0)
	var bpl := IstGeo.yol("blakherna_suru")
	var byaw := 0.0
	var bin := Vector2.ZERO
	if bpl.size() >= 2:
		var sn := _snap(bpl, bl)
		var o := _out(sn["d"], sn["p"], "blakherna_suru")
		bin = -o
		bl = (sn["p"] as Vector2) - o * 2.0
		byaw = _yaw_x(sn["d"], sn["p"], "blakherna_suru")
	var bit := _v2_item("blakherna", Vector3(bl.x, IstGeo.h(bl.x, bl.y) - 0.05, bl.y), byaw, 46.0, _make_blakherna)
	# konma noktası: saray çatısının mahyası (katı kapak; ŞEHİR-3)
	var bpp: Vector3 = (bit["holder"] as Node3D).transform * Vector3(0, 20.0, -21.0)
	_pad(bpp, "Konma_blakherna")
	bit["perch"] = bpp
	quest2["BLAKHERNA"] = {"p": Vector3(bl.x, IstGeo.h(bl.x, bl.y) + 26.0, bl.y), "r": 34.0}
	var cand: Array = []
	# Sabit engeller: Ayasofya, Blakherna Sarayı, oyun alanları (hub alanı Romanos'tan sonra eklenir)
	cand.append({"id": "ayasofya", "w": aw, "w0": aw, "r": 40.0 * AYA_K * 0.8, "sabit": true, "prio": 3, "tur": "anit"})
	# saray + avlu sura yaslı, şehre doğru 44 m: engel dairesi gövdenin ortasında
	cand.append({"id": "blakherna", "w": bl + bin * 22.0, "w0": bl + bin * 22.0, "r": 27.0, "sabit": true, "prio": 3, "tur": "anit"})
	var mr := _meydan_rect()
	cand.append({"id": "oyun_meydan", "w": mr.get_center(), "w0": mr.get_center(), "r": mr.size.length() * 0.42, "sabit": true, "prio": 3, "tur": ""})
	for e: Dictionary in catalog_all():
		var id := String(e["id"])
		var mod := String(e["mod"])
		if mod in MOD_SKIP2 or id in HAT_IDS or mod.begins_with("ordugah") or mod.begins_with("gemiler") or mod.begins_with("hayat"):
			# ordugâh, gemiler, hayat kendi attach'ıyla kurulur (kayıttan da kurulursa çifte yapı olur)
			continue
		var pl := _place2_of(e)
		if pl.is_empty():
			continue
		var data: Dictionary = e["data"]
		var tur := String(data.get("tur", ""))
		pl["id"] = id
		pl["e"] = e
		pl["tur"] = tur
		pl["w"] = Vector2((pl["pos"] as Vector3).x, (pl["pos"] as Vector3).z)
		if MANASTIR.has(id):
			pl["r"] = (MANASTIR[id] as Vector2).length() + 1.0
		pl["prio"] = 3 if id in SABIT_UNLU else (2 if (id in UNLU or data.get("gorev", false) or tur == "kapi") else 1)
		# Hub (Romanos'un iç yanı) sabit engel
		if id == "romanos":
			var inn := -Vector2(sin(float(pl["yaw"])), cos(float(pl["yaw"])))
			var hc: Vector2 = pl["w"] + inn * 75.0
			cand.append({"id": "oyun_hub", "w": hc, "w0": hc, "r": 55.0, "sabit": true, "prio": 3, "tur": ""})
		cand.append(pl)
	_hat_dizi(cand)
	_coz_cakisma(cand)
	print("ISTCAKISMA ", " · ".join(cakisma_rapor))
	for pl: Dictionary in cand:
		if not pl.has("e"):
			continue
		var e: Dictionary = pl["e"]
		var id := String(e["id"])
		var mod := String(e["mod"])
		var data: Dictionary = e["data"]
		var wq: Vector2 = pl["w"]
		if wq.distance_to(pl["w0"]) > 0.5:
			var y := _taban_y(wq, float(pl["yaw"]), data.get("gercek_olcu", Vector3(20, 10, 20)), float(pl["k"]), float(pl["r"]), String(pl["tur"]))
			pl["pos"] = Vector3(wq.x, y - 0.03, wq.y)
		var p: Vector3 = pl["pos"]
		# Yapının tabanı düzlenir (arazi ağı bu kayıtlardan sonra kurulur; IstGeo.duzle)
		# (kıyıdaki alçak yapılar düzlenmez: taban deniz düzeyine yakınsa arazi göl gibi suya iner)
		if float(pl["r"]) <= 130.0 and p.y > 2.0 and not String((e["data"] as Dictionary).get("tur", "")) in ["liman", "bitki"] and not (YER2.get(id, {}) as Dictionary).has("kiyi") and not (YER2.get(id, {}) as Dictionary).has("hat"):
			IstGeo.duzle(Vector2(p.x, p.z), float(pl["r"]) * 0.85, p.y + 0.03)
		var holder := Node3D.new()
		holder.name = "Ist_" + id
		holder.position = p
		holder.rotation.y = float(pl["yaw"])
		holder.set_meta("ist_id", id)
		add_child(holder)
		var it := {"id": id, "script": e["script"], "pos": p, "yaw": pl["yaw"], "k": pl["k"], "r": pl["r"],
			"have": [null, null, null], "holder": holder, "data": e["data"], "mod": mod, "r1": R1_V2}
		if MANASTIR.has(id):
			# manastır avlusu evlerin taban damgasına girsin (IstSokak gercek_olcu × k'den damgalar)
			var mv: Vector2 = MANASTIR[id]
			var dd: Dictionary = (e["data"] as Dictionary).duplicate()
			var go: Vector3 = dd.get("gercek_olcu", Vector3(30, 20, 30))
			dd["gercek_olcu"] = Vector3(mv.x * 2.0 / float(pl["k"]), go.y, mv.y * 2.0 / float(pl["k"]))
			it["data"] = dd
		if pl.has("glen"):
			# Sur kapısı: modülün kapı koşusu kısaltılmış boyla (komşu kapılarla üst üste binmesin; kesit 1:1). Taban,
			# sur dilimleri gibi hat boyunca yedi örneğin ortancası (hendek yanına taşan örnekler kapıyı gömmesin/alçaltmasın)
			var gl := float(pl["glen"])
			var gd := Vector2(cos(-float(pl["yaw"])), sin(-float(pl["yaw"])))
			var ghs: Array = []
			for q in 7:
				var gq := Vector2(p.x, p.z) + gd * gl * (q / 6.0 - 0.5)
				ghs.append(IstGeo.h(gq.x, gq.y))
			ghs.sort()
			p.y = maxf(float(ghs[3]), -0.6) - 0.05
			holder.position = p
			it["pos"] = p
			var o: Dictionary = IstSurlar.OPTS[id]
			var sd := 1000 + id.hash() % 997
			it["make"] = func(nd: Node3D, lod: int) -> void: IstSurlar._run(nd, gl, K_SUR, lod, sd, o)
			it["glen"] = gl
			it["r"] = gl * 0.5 + 4.0
			it["walk"] = p.y + float(IstSurlar.dims(K_SUR)["HW"])
			var ad_h := String((YER2[id] as Dictionary)["hat"])
			var hpl := _sade(IstGeo.yol(ad_h))
			var hs := _snap(hpl, Vector2(p.x, p.z))
			var hd: Vector2 = hs["d"]
			it["s0"] = float(hs["s"]) - gl * 0.5
			it["s1"] = float(hs["s"]) + gl * 0.5
			it["a2"] = Vector2(p.x, p.z) - hd * gl * 0.5
			it["b2"] = Vector2(p.x, p.z) + hd * gl * 0.5
			it["kapi_hat"] = ad_h
		items.append(it)
		_build(it, 2)
		_perch_pad(it)

	# Ayasofya meydanı oyun alanı: döşeme, kenar taşı, çınarlar, tezgâhlar, çeşme (orta alan boş; ŞEHİR-3)
	var mr2 := _meydan_rect()
	var mc := mr2.get_center()
	var my := IstGeo.h(mc.x, mc.y)
	IstGeo.duzle(mc, mr2.size.length() * 0.5, my, 6.0)
	_v2_item("meydan_aya", Vector3(mc.x, my - 0.02, mc.y), 0.0, mr2.size.length() * 0.5,
		func(nd: Node3D, lod: int) -> void: ESER.meydan(nd, lod, mr2.size.x, mr2.size.y))
	# ÇEVRE-4: Ayasofya'nın dört yanı (atrium, vaftizhane, skeuophylakion, patrikhane, Khalke revakı, kuzey avlu duvarı,
	# döşeme; sehir_eser.gd aya_cevre). Kimlik "meydan_" ile başlar: DOKU'nun taban damgası onu ev engeli saymaz.
	var axf := Transform3D(Basis(Vector3.UP, float(ait["yaw"])), ait["pos"])
	var ainv := axf.affine_inverse()
	var bos: Array = []
	for o: Dictionary in items:
		var oid := String(o["id"])
		if oid == "ayasofya" or oid.begins_with("doku_") or oid.begins_with("mese_") or o.has("hat"):
			continue
		var op: Vector3 = o["pos"]
		var lo := ainv * op
		if Vector2(lo.x, lo.z).length() > 140.0:
			continue
		var orr := float(o["r"]) * (0.55 if oid == "meydan_aya" else 0.7)
		bos.append([Vector2(lo.x, lo.z), orr])
	var apy: Vector3 = ait["pos"]
	var ayh := func(x: float, z: float) -> float:
		var w := axf * Vector3(x, 0, z)
		return maxf(IstGeo.h(w.x, w.z), apy.y - 2.0) - apy.y
	_v2_item("meydan_aya_cevre", apy, float(ait["yaw"]), 70.0,
		func(nd: Node3D, lod: int) -> void: ESER.aya_cevre(nd, lod, ayh, bos))
	# Hub (mektup bölümünün şehri): zemini düzlenir (arazi ağı sonra kurulur)
	var hx := hub_xf()
	if hx != Transform3D():
		var hc := hx * Vector3(0, 0, -10)
		# bölümün kaldırımı (üstü yerel y 0) arazinin üstünde kalsın: arazi 12 cm aşağıda düzlenir
		IstGeo.duzle(Vector2(hc.x, hc.z), 48.0, hx.origin.y - 0.12, 10.0)
		# Hub şehri tek katmanlı öğe (kendi uzaklık katmanları var); BAĞLAMA bölümde (7b) alanı temizlerken kalkar
		_v2_item("hub_sehir", hx.origin, 0.0, 50.0, _make_hub)


## Tek katmanlı öğe: kurucusu bir kez (açılışta) çalışır, kendi uzaklık katmanlarını ve çarpışmasını kendisi kurar
## (ByzCity.far_hub); akış ona lod 0/1 kurmaz, pişirmez, çarpışmasını sökmez.
func _v2_item_tek(id: String, p: Vector3, r: float, make: Callable) -> Dictionary:
	var holder := Node3D.new()
	holder.name = "Ist_" + id
	holder.position = p
	add_child(holder)
	var it := {"id": id, "pos": p, "yaw": 0.0, "k": 1.0, "r": r, "have": [null, null, null], "holder": holder,
		"data": {}, "mod": "v2", "make": make, "r1": R1_V2, "tek": true, "want": 2}
	items.append(it)
	var n := Node3D.new()
	n.name = "L2"
	holder.add_child(n)
	make.call(n, 2)
	it["have"][2] = n
	return it


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
const HAT_BEGIN := 200.0
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
		# mazgal dişleri (uzak silüet; kalite notu 11)
		stats["mazgal_uzak"] = int(stats.get("mazgal_uzak", 0)) + ESER.mazgal(_hat_far[ck], mi.mesh, xf, 6.0)
		if _hat_mat == null:
			_hat_mat = mi.material_override if mi.material_override else mi.mesh.surface_get_material(0)
	holder.free()
	tmp.free()


## Uzak sur ağı: düz pişirmede renk = taban rengi × dokunun ortalaması; kesme taş dokusu koyu olduğundan sur uzakta
## kahverengiye kaçıyordu (dışarıdan bakışta "alçak kahverengi çit"). Köşe renkleri açılır (kireçtaşı krem).
static func _acik(m: Mesh, f: float) -> Mesh:
	if m == null or m.get_surface_count() == 0:
		return m
	var am := ArrayMesh.new()
	for si in m.get_surface_count():
		var arr := m.surface_get_arrays(si)
		var cols = arr[Mesh.ARRAY_COLOR]
		if cols is PackedColorArray:
			var pc: PackedColorArray = cols
			var krem := Color("d2c3a3")
			for i in pc.size():
				var c := pc[i]
				if c.r > c.b + 0.18 and c.r > c.g + 0.1:
					# tuğla şeritleri ve kiremit: kızıl kalır, biraz açılır
					pc[i] = Color(minf(c.r * f, 1.0), minf(c.g * f, 1.0), minf(c.b * f, 1.0), c.a)
				else:
					# kesme taş, toprak, kule gövdesi: kireçtaşı kremi (parlaklık farkı korunur)
					var l := clampf(0.72 + c.get_luminance() * 0.55, 0.72, 1.1)
					pc[i] = Color(minf(krem.r * l, 1.0), minf(krem.g * l, 1.0), minf(krem.b * l, 1.0), c.a)
			arr[Mesh.ARRAY_COLOR] = pc
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		am.surface_set_material(si, m.surface_get_material(si))
	return am


func _hat_far_commit() -> void:
	for ck: Vector2i in _hat_far:
		var mi := MeshInstance3D.new()
		mi.mesh = _acik(( _hat_far[ck] as SurfaceTool).commit(), 1.3)
		# şeritli taş malzemesi (tuğla bantları dünya yüksekliğinden; kalite notu 11)
		mi.material_override = ESER.sur_uzak_mat()
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
	# Var olan model × AYA_K (taban ~54 m, kubbe tepesi ~40 m); kapı ve basamak da büyür (anıtsal kapı: kabul)
	var sc := Node3D.new()
	sc.scale = Vector3.ONE * AYA_K
	n.add_child(sc)
	var off := Node3D.new()
	off.position = -ByzCity.AYA
	sc.add_child(off)
	ByzCity.aya_exterior(off)
	if lod >= 2:
		# Uzak katmanda iç kabuk kurulmaz: gövdenin üstü (kubbeler arası kurşun çatı) yukarıdan boş görünüyordu
		Props.box(sc, Vector3(33.0, 0.4, 33.0), Vector3(0, 16.3, 0), Color("6c737c"))
	if lod <= 1:
		var inner := Node3D.new()
		inner.position = ByzCity.AYA
		off.add_child(inner)
		Ayasofya._shell_walls(inner)
		Ayasofya._narthex(inner)
		Ayasofya._apse(inner)
		Ayasofya._domes(inner)


## Hub şehri: mektup bölümünün kurucuları (ByzCity "walls": zemin, cadde ve evleri, kançılarya, iç sur ve Romanos kemeri,
## saray avlusu, kubbeli kiliseler, dolgu evler) — ByzCity.far_hub'ın kurduğu parçaların aynısı; ama şehrin katmanlı
## pişirmesiyle (ByzCity.far_hub'daki World1453.bake köşe renkli parçaların rengini silip bembeyaz bırakıyordu, ŞEHİR-3).
## Kişiler, yazılar atılır; ışıklar yalnız yakın katmanda.
func _make_hub(n: Node3D, lod: int) -> void:
	var t0 := Time.get_ticks_msec()
	var c := ByzCity.new()
	c.part = "walls"
	c._build_ground()
	c._build_street()
	c._build_chancery()
	c._build_walls()
	c._build_palace()
	c._build_small_skyline()
	c._build_fill()
	for ch in c.get_children():
		c.remove_child(ch)
		n.add_child(ch)
	c.free()
	for x in n.find_children("*", "", true, false):
		if not is_instance_valid(x):
			continue
		if x is Person or x is Label3D or x is Area3D or (x is Light3D and lod > 0):
			x.get_parent().remove_child(x)
			x.free()
	stats["hub_ms"] = Time.get_ticks_msec() - t0


func _make_blakherna(n: Node3D, lod: int) -> void:
	# Blakherna Sarayı (ŞEHİR-3): bölümün düz kutu kabuğu yerine saray gibi kurulur (Tekfur Sarayı dili: üç kat, kemerli
	# pencere sıraları, revak, balkon, kırma çatı, yan kuleler, şehir yanında avlu): scripts/world/ist/sehir_eser.gd
	ESER.palace(n, lod, gece)


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
			if it.has("glen"):
				g = float(it["glen"])
			elif String(it["mod"]) == "surlar":
				g = IstSurlar._gate_len(String(it["id"]), float(it["k"]))
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
		# Köşe kuleleri: hangi köşede (kapı koşusunun içine ya da önceki köşeye 15 m'den yakın düşen kurulmaz; ŞEHİR-3:
		# Altın Kapı kümesinde kapının yürüme yolunu 11 m'lik dolu kule kesiyordu). Kulesiz köşede dilimler uç uca biter.
		var kose_var := {}
		var sv := 0.0
		var son_kose := -INF
		for i in range(1, pl.size() - 1):
			sv += pl[i - 1].distance_to(pl[i])
			var kapida := false
			for c: Array in cuts:
				if sv > float(c[0]) - 6.0 and sv < float(c[1]) + 6.0:
					kapida = true
			if not kapida and sv - son_kose > 15.0:
				kose_var[i] = true
				son_kose = sv
		var s_acc := 0.0
		for i in pl.size() - 1:
			var a := pl[i]
			var b := pl[i + 1]
			var L := a.distance_to(b)
			var d := (b - a) / L
			var corner := 4.5 if kose_var.has(i) else 0.0
			var end_c := 4.5 if kose_var.has(i + 1) else 0.0
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
				# (ŞEHİR-3: en kısa dilim 30 → 12 m; Galata/Haliç yamacında dilimler arası 4–9 m'lik basamak kalıyordu)
				# (kara surunda kısa dilim kule kapılarını ve köşe sayısını artırıp yürüyüşü bozuyordu: kara 30 m'de kalır)
				n = maxi(n, mini(int(ceil(dh / 1.4)), int(span / (30.0 if String(cfg["kur"]) == "kara" else 12.0))))
				var lens: Array = []
				var hl := float(IstHalicSur.dims(K_SUR)["L"])
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
			# Köşe kulesi (iç köşe ve dış köşedeki kopukluğu örter; tepesi yürüme yolu hizasında). Kapı koşusunun içine
			# ya da bir önceki köşeye 15 m'den yakın düşen kurulmaz (ŞEHİR-3: Altın Kapı kümesinde kapının yürüme yolunu
			# 11 m'lik dolu kule kesiyordu)
			if kose_var.has(i):
				var kc := _kose(ad, String(cfg["kur"]), a, _son_walk(ad, s_acc - 4.5))
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
		var uz := L / K_UNLU
		var it := _v2_item("bozdogan", Vector3(mid.x, lo - 0.1, mid.y), -brg, L * 0.5,
			func(n: Node3D, lod: int) -> void: IstKemerSu.build_bozdogan(n, K_UNLU, lod, uz))
		it["data"] = {"gorev": true}
		hat_items.append(it)
		quest2["BOZDOGAN"] = {"p": Vector3(mid.x, lo + float(IstKemerSu.params(K_UNLU, uz)["hmax"]) + 9.0, mid.y), "r": 34.0}
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
				# dilimin hiçbir yeri bir anıtın (forum, sütun…) tabanına girmesin: beş noktada sına
				var hit := false
				for t in 5:
					if _near_item(a + d * ((k + t / 4.0) * L / n), 4.0):
						hit = true
				if hit:
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
	_oyun.append(_meydan_rect())
	return _oyun


## Hub'ın (Romanos Kapısı'nın iç yanı; Bölüm 6b, 7b, 10h, 12b, 23, 24) ByzCity "walls" parçasının yerel → dünya dönüşümü.
## BAĞLAMA ile aynı kural (IstBaglama: v2 yalnız ötelenir, dönmez): bölümün çapası (ByzCity yerel HUB_ORTA = (−4, −13))
## oyun alanının ortasında; eksenler dünya eksenleri. Uçuşta görülen hub ile bölümde oynanan hub aynı yerde ve aynı.
const HUB_ORTA := Vector2(-4.0, -13.0)
var _hub_xf := Transform3D()

func hub_xf() -> Transform3D:
	if _hub_xf != Transform3D():
		return _hub_xf
	var ar := oyun_alanlari()
	if ar.size() < 2:
		return _hub_xf
	var c: Vector2 = (ar[0] as Rect2).get_center()
	var o := Vector3(c.x - HUB_ORTA.x, 0.0, c.y - HUB_ORTA.y)
	var g := o + Vector3(0, 0, -10)
	o.y = IstGeo.h(g.x, g.z)
	_hub_xf = Transform3D(Basis.IDENTITY, o)
	return _hub_xf


## Ayasofya meydanı oyun alanı (24, 25, 26, 31o): Ayasofya'nın batısında (narteks önü), 55 × 50 m
static func _meydan_rect() -> Rect2:
	var aw := IstGeo.w2(0, 0)
	return Rect2(aw + Vector2(-42.0 * AYA_K - 55.0, -25), Vector2(55, 50))


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
			make = func(n: Node3D, lod: int) -> void: IstSurlar.build_run(n, L, K_SUR, lod, 1453 + seed)
		"blakherna":
			make = func(n: Node3D, lod: int) -> void: _blakherna_wall(n, L, lod)
		"halic":
			# Haliç suru: modülün 80 m'lik parçası (deniz −z) sığıyorsa; değilse parametreli deniz suru
			if absf(L - float(IstHalicSur.dims(K_SUR)["L"])) < 0.05:
				yaw += PI
				make = func(n: Node3D, lod: int) -> void: IstHalicSur.build(n, K_SUR, lod)
			else:
				kur = "marmara"
				make = func(n: Node3D, lod: int) -> void: IstMarmaraSur.build_run(n, L, K_SUR, lod, {})
		_:
			make = func(n: Node3D, lod: int) -> void: IstMarmaraSur.build_run(n, L, K_SUR, lod, {})
	if lo - dip > 0.3:
		var inner := make
		var tk := _walk_w(kur) + 1.6
		var drop := lo - dip + 0.4
		make = func(n: Node3D, lod: int) -> void:
			inner.call(n, lod)
			if not IstSurlar._ic(0.0) or not IstMk._ic(0.0):
				return
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
	it["mk"] = kur == "marmara"
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
		"kara": return float(IstSurlar.dims(K_SUR)["HW"])
		"blakherna": return Blachernae.WALK_Y
		"halic": return float(IstHalicSur.dims(K_SUR)["H"])
	return float(IstMarmaraSur.dims(K_SUR)["H"])


static func _walk_w(kur: String) -> float:
	match kur:
		"kara": return float(IstSurlar.dims(K_SUR)["T"]) - 1.0
		"blakherna": return 3.4
		"halic": return float(IstHalicSur.dims(K_SUR)["T"]) - 0.9
	return float(IstMarmaraSur.dims(K_SUR)["T"]) - 0.9


## Sur üstü yürüyüş: ardışık iki öğenin (dilim/köşe kulesi) yürüme yolları arasında > 0,35 m fark varsa alçak olanın
## ucuna 0,30 m'lik taş basamaklar (tek MultiMesh + tek çarpışma gövdesi; uzakta çizilmez)
var _bas_xf: Array = []
var _bas_body: StaticBody3D

func _basamaklar(ad: String, kur: String) -> void:
	var list: Array = []
	for it: Dictionary in hat_items + items:
		if (String(it.get("hat", "")) == ad or String(it.get("kapi_hat", "")) == ad) and it.has("s0") and it.has("walk") and not list.has(it):
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
			# basma 0,6 m (oyuncunun basamak yoklaması 0,5 m ileriye bakar: daha dar basamakta takılıyordu)
			var c := J - dir * ((n - k - 0.5) * 0.6)
			var hgt := top - y0 + 0.05
			var bas := Basis(Vector3.UP, atan2(-dir.y, dir.x))
			var xf := Transform3D(bas.scaled(Vector3(0.61, hgt, ww)), Vector3(c.x, y0 - 0.05 + hgt * 0.5, c.y))
			_bas_xf.append(xf)
		# Çarpışma: basma ortalarından geçen tek rampa (ŞEHİR-3: kutu basamakların önünde takılma/düşme)
		var a3 := J - dir * (n * 0.6)
		var b3 := J - dir * 0.3
		var A3 := Vector3(a3.x, y0 + dh / n * 0.5, a3.y)
		var B3 := Vector3(b3.x, y0 + dh, b3.y)
		var rb := Basis.looking_at((B3 - A3).normalized(), Vector3.UP)
		var rcs := CollisionShape3D.new()
		var rbs := BoxShape3D.new()
		rbs.size = Vector3(ww, 0.3, A3.distance_to(B3))
		rcs.shape = rbs
		rcs.transform = Transform3D(rb, (A3 + B3) * 0.5 - rb.y * 0.15)
		_bas_body.add_child(rcs)


func _basamak_ag() -> void:
	if _bas_xf.is_empty():
		return
	var mm := _mm(_unit_box(Color("cdbd9e"), "ashlar"), _bas_xf)
	mm.visibility_range_end = 260.0


## Köşe kulesi: iki dilimin birleştiği yerde dolu kule; tepesi yürüme yolu hizasında (yürüyüş kesilmez)
## Hattın son kurulan diliminin yürüme yolu yüksekliği (yoksa NAN)
func _son_walk(ad: String, s_max := INF) -> float:
	# kapı koşuları da (ŞEHİR-3: köşe kulesi kapıyı görmüyor, eski bir dilimin yüksekliğini alıyordu: 4–8 m'lik basamak)
	var best := -INF
	var w := NAN
	for it: Dictionary in hat_items + items:
		var on_hat := String(it.get("hat", "")) == ad or String(it.get("kapi_hat", "")) == ad
		if on_hat and it.has("s1") and it.has("walk") and float(it["s1"]) <= s_max + 0.5 and float(it["s1"]) > best:
			best = float(it["s1"])
			w = float(it.get("walk", NAN))
	return w


func _kose(ad: String, kur: String, p: Vector2, walk_y := NAN) -> Dictionary:
	var walk := 6.65
	var sz := 9.0
	match kur:
		"kara":
			walk = float(IstSurlar.dims(K_SUR)["HW"])
			sz = float(IstSurlar.dims(K_SUR)["T"]) + 6.0
		"blakherna":
			walk = Blachernae.WALK_Y
			sz = 9.0
		"halic":
			walk = float(IstHalicSur.dims(K_SUR)["H"])
			sz = float(IstHalicSur.dims(K_SUR)["T"]) + 5.0
		_:
			walk = float(IstMarmaraSur.dims(K_SUR)["H"])
			sz = float(IstMarmaraSur.dims(K_SUR)["T"]) + 5.0
	var lo := INF
	for o: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2.ZERO]:
		lo = minf(lo, IstGeo.h(p.x + o.x * sz * 0.4, p.y + o.y * sz * 0.4))
	lo = maxf(lo, -0.6)
	# Köşe kulesinin tepesi önceki dilimin yürüme yoluyla aynı hizada (köşede basamak olmasın); temel zemine iner
	var dip := 0.0
	if not is_nan(walk_y):
		var nlo := walk_y + 0.05 - walk
		dip = maxf(0.0, nlo - lo) + 0.3
		lo = nlo
	var make := func(n: Node3D, lod: int) -> void:
		var stone := Color("cdbd9e")
		if dip > 0.0:
			if lod == 0:
				Props.set_pattern(Props.solid(n, Vector3(sz, dip, sz), Vector3(0, -dip * 0.5 + 0.02, 0), Color.WHITE), stone.darkened(0.1), "ashlar")
			else:
				Props.box(n, Vector3(sz, dip, sz), Vector3(0, -dip * 0.5 + 0.02, 0), stone.darkened(0.1))
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
	# Sur bandı (yarı genişlik): surun iç yüzü + 5 m savunma yolu (kalite notu 0b: evler surun iç yüzüne yaslı, arada
	# 4–6 m yol); kesit 1:1 olduğundan sur kalınlığından türer. Dış yan şehir dışıdır (sokak orada kurmaz).
	for ad: String in HAT:
		var kur := String(HAT[ad]["kur"])
		var hw := _walk_w(kur) * 0.5 + 0.6 + 5.0
		if ad == "blakherna_suru":
			hw = 10.0
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
		if gece and (n * 7 + v) % 5 < 2 and dm.y > IstEvler.GF + 0.5:
			# gece: üst katta yanan bir pencere (cephe +z, cumbanın yüzünde)
			var wx := (float((n * 13) % 3) - 1.0) * dm.x / 3.0
			var wp := xf * Vector3(wx, IstEvler.GF + IstEvler.UF * 0.5, dm.z * 0.5 + IstEvler.OVER + 0.06)
			var ck := Vector2i(floori(wp.x / CELL2), floori(wp.z / CELL2))
			if not _isik.has(ck):
				_isik[ck] = []
			_isik[ck].append(Transform3D(bas, wp))
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
	_isiklar()
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
			mi.material_override = _cizgisiz_of(mat)
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
			_cizgisiz(mm)
		var mi := _merge_groups(g1[ck], 1, cen)
		if mi:
			_cizgisiz(mi)
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
			# Aynı doku ve ölçekteki malzemeler (her ev örneğinin pişiricisi kendi kopyasını üretir) tek yüzeyde
			var mk := _mat_key(sm)
			if not by_mat.has(mk):
				var nst := SurfaceTool.new()
				nst.begin(Mesh.PRIMITIVE_TRIANGLES)
				by_mat[mk] = [nst, sm]
			for xf: Transform3D in groups[key]:
				(by_mat[mk][0] as SurfaceTool).append_from(m, si, Transform3D(xf.basis, xf.origin - cen))
	if by_mat.is_empty():
		return null
	var am := ArrayMesh.new()
	for mk in by_mat:
		(by_mat[mk][0] as SurfaceTool).commit(am)
		am.surface_set_material(am.get_surface_count() - 1, by_mat[mk][1])
	var mi := MeshInstance3D.new()
	mi.mesh = am
	mi.position = cen
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if lod > 0 else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	mi.set_meta("no_walk", true)
	add_child(mi)
	return mi


static var _mkeys := {}

static func _mat_key(m: Material) -> String:
	if m == null:
		return "null"
	if _mkeys.has(m):
		return _mkeys[m]
	var k := str(m.get_instance_id())
	if m is BaseMaterial3D:
		var bm := m as BaseMaterial3D
		k = "%s|%s|%s|%s|%s|%s" % [bm.albedo_texture.get_rid() if bm.albedo_texture else "-", bm.uv1_scale, bm.uv1_triplanar,
			bm.vertex_color_use_as_albedo, bm.albedo_color if not bm.vertex_color_use_as_albedo else Color.WHITE, bm.next_pass != null]
	_mkeys[m] = k
	return k


var _isik := {}

## Gece pencere ışıkları: 400 m hücre başına tek MultiMesh (ışıklı, gölgesiz; 900 m'ye kadar)
func _isiklar() -> void:
	if _isik.is_empty():
		return
	var bm := BoxMesh.new()
	bm.size = Vector3(0.8, 1.1, 0.04)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color("ffc070")
	m.emission_enabled = true
	m.emission = Color("ffb050")
	m.emission_energy_multiplier = 2.0
	bm.material = m
	for ck: Vector2i in _isik:
		var mm := _mm(bm, _isik[ck])
		mm.visibility_range_end = 900.0
	_isik.clear()


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
## İşaret: eserin kurulmuş ağının EN YÜKSEK kümesinin (tepedeki 3 m) tam üstünde + 8 m (kubbe haçı, sütun başı, kule külahı).
## Formlar (Z-9 kâğıtları, eski haritadaki on ikinin v2 karşılığı): o eserlerin tepe yüzeyinde (+0,6 m).
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
			p = s._ust_nokta(by["ayasofya"]) + Vector3(0, 6.0, 0)
			r = 60.0
		elif q == "ZINCIR" and s.quest2.has(q):
			p = s.quest2[q]["p"]
			r = float(s.quest2[q]["r"])
		elif q == "BOZDOGAN" and by.has("bozdogan"):
			p = s._ust_nokta(by["bozdogan"]) + Vector3(0, 9.0, 0)
			r = 34.0
		elif q == "BLAKHERNA" and by.has("blakherna"):
			p = s._ust_nokta(by["blakherna"]) + Vector3(0, 8.0, 0)
			r = 34.0
		elif DOKUZ_ID.has(q) and by.has(DOKUZ_ID[q]):
			var it: Dictionary = by[DOKUZ_ID[q]]
			p = s._ust_nokta(it) + Vector3(0, 8.0, 0)
			r = maxf(float((it["data"] as Dictionary).get("bakis_r", 36.0)), float(it["r"]) * 0.8)
			used[DOKUZ_ID[q]] = true
		elif s.quest2.has(q):
			p = s.quest2[q]["p"]
			r = float(s.quest2[q]["r"])
		landmarks.append([q, g.call(p), r])
	for it: Dictionary in s.items:
		var d: Dictionary = it["data"]
		if not d.get("gorev", false) or used.has(it["id"]) or String(it["id"]) in ["bozdogan", "ayasofya", "blakherna"]:
			continue
		landmarks.append([String(it["id"]).to_upper(), g.call(s._ust_nokta(it) + Vector3(0, 8.0, 0)),
			maxf(float(d.get("bakis_r", 30.0)), float(it["r"]) * 0.7)])
	var forms: Array = []
	var fe := ["ayasofya", "konstantin", "galata_kulesi", "hipodrom", "bozdogan", "havariyun", "blakherna", "halic_eugenios",
		"san_domenico", "", "romanos", ""]
	for i in fe.size():
		var p := Vector3.INF
		if i == 0 and by.has("ayasofya"):
			# kubbe yüzeyindeki konma kapağının 1 m yanı (katı)
			p = (by["ayasofya"]["perch_aya"] as Vector3) + Vector3(0.0, 0.5, 0.0)
		elif fe[i] != "" and by.has(fe[i]):
			var it: Dictionary = by[fe[i]]
			# Konma noktası varsa (çarpışmalı yüzey, ISTKONMA ile sınanır) onun üstü; yoksa en yüksek köşenin üstüne
			# katı bir konma kapağı konur (ŞEHİR-3: Bozdoğan/Blakherna formu görsel bir parçanın ucunda havada kalıyordu)
			if not it.has("perch"):
				var tp: Vector3 = s._tepe_nokta(it, 0.3)
				s._pad(tp, "Konma_form_" + String(fe[i]))
				it["perch"] = tp
			p = (it["perch"] as Vector3) + Vector3(0, 0.6, 0)
		elif i == 9:
			# Kız Kulesi adacığı (Damalis): adacığın zemini
			var kq := IstGeo.ll(41.0211, 29.0041)
			p = Vector3(kq.x, maxf(IstGeo.h(kq.x, kq.z), 0.0) + 0.6, kq.z)
		elif i == 11:
			# Üsküdar sırtı: zemin
			var u := IstGeo.w2(2900.0, 1900.0)
			p = Vector3(u.x, IstGeo.h(u.x, u.y) + 0.6, u.y)
		if p != Vector3.INF:
			if i == 9 or i == 11:
				# karşı kıyı: arazi çarpışması yalnız oyuncunun çevresinde akıyor; formun altında katı kapak
				if not s.has_node("Konma_form_%d" % i):
					s._pad(p - Vector3(0, 0.6, 0), "Konma_form_%d" % i)
			forms.append([i + 1, g.call(p)])
	var perches: Array = []
	if by.has("ayasofya"):
		perches.append(["aya", g.call(by["ayasofya"]["perch_aya"]), 5.0])
	for q: Array in s.perch_marks():
		perches.append([q[0], g.call(q[1]), q[2]])
	return {"landmarks": landmarks, "forms": forms, "perches": perches}


## Eserin tepe noktası (alan yereli): kurulu en ayrıntılı katmanın (lod 1, yoksa lod 2, yoksa ön-pişmiş lod 0) köşe
## noktalarından en yüksek 3 m'lik kümenin ortası (x, z) ve tepesi (y) + dy. Önbellekli.
func _ust_nokta(it: Dictionary, dy := 0.0) -> Vector3:
	if it.has("ust"):
		return (it["ust"] as Vector3) + Vector3(0, dy, 0)
	var holder := it["holder"] as Node3D
	var layer: Node3D = null
	for l: int in [1, 0, 2]:
		if it["have"][l] != null:
			layer = it["have"][l]
			break
		if it.has("pre") and it["pre"][l] != null:
			layer = it["pre"][l]
			break
	var top := -INF
	var tepe := Vector3(0, 10.0, 0)
	var pts: Array = []
	if layer != null:
		for c in layer.find_children("*", "MeshInstance3D", true, false):
			var mi := c as MeshInstance3D
			if mi.mesh == null:
				continue
			# katmanın yereli → holder yereli
			var xf := Transform3D.IDENTITY
			var cur: Node = mi
			while cur != null and cur != layer:
				xf = (cur as Node3D).transform * xf
				cur = cur.get_parent()
			xf = layer.transform * xf
			for si in mi.mesh.get_surface_count():
				var arr := mi.mesh.surface_get_arrays(si)
				var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				for v in vs:
					var w := xf * v
					if w.y > top - 3.0:
						pts.append(w)
						if w.y > top:
							top = w.y
							tepe = w
	var loc := Vector3(0, 10.0, 0)
	if not pts.is_empty():
		var acc := Vector3.ZERO
		var n := 0
		for w: Vector3 in pts:
			if w.y > top - 3.0:
				acc += Vector3(w.x, 0, w.z)
				n += 1
		loc = Vector3(acc.x / n, top, acc.z / n)
	var r: Vector3 = holder.transform * loc
	it["ust"] = r
	it["tepe"] = holder.transform * tepe
	return r + Vector3(0, dy, 0)


## Eserin en yüksek köşe noktası (alan yereli) + dy: formlar (kâğıt) gerçek bir yüzeyin üstünde dursun
func _tepe_nokta(it: Dictionary, dy := 0.0) -> Vector3:
	_ust_nokta(it)
	return (it["tepe"] as Vector3) + Vector3(0, dy, 0)


## Eserin yan görev işareti: kaydın "bakis" noktası (yerel) varsa ondan, yoksa tepesinin 8 m üstü
static func _bakis_of(it: Dictionary) -> Vector3:
	var d: Dictionary = it["data"]
	var h := it["holder"] as Node3D
	if d.has("bakis"):
		var b: Vector3 = d["bakis"]
		return h.transform * b
	var sz: Vector3 = d.get("gercek_olcu", Vector3(20, 20, 20))
	return h.transform * Vector3(0, sz.y * float(it["k"]) + 8.0, 0)
