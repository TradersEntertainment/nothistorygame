class_name IstKemer
extends RefCounted
## İstanbul, Nisan 1453: kemer parçası. Bozdoğan (Valens) Su Kemeri, Havariyun, Pantokrator, Lips, Kyriotissa (Kalenderhane),
## Vefa kilisesi, Pantepoptes, Gül (Aya Theodosia), Aspar açık sarnıcı, Polyeuktos harabesi.
## Arayüz (dondurulmuş): catalog(), build_<id>(host, k, lod), perches_<id>(k), climbs_<id>(k); ayrıca build(id, host, k, lod).
## Konum: gerçek metre, Ayasofya kubbesi (0,0), doğu/kuzey; çoğu KESTİRİM (±300 m), raporda işaretli.

const KIT := preload("res://scripts/world/ist/kemer_kit.gd")
const SU := preload("res://scripts/world/ist/kemer_su.gd")
const KIL := preload("res://scripts/world/ist/kemer_kilise.gd")
const HAR := preload("res://scripts/world/ist/kemer_harabe.gd")

const IDS := ["bozdogan", "havariyun", "pantokrator", "lips", "kalenderhane", "vefa", "pantepoptes", "gul", "aspar", "polyeuktos"]


static func catalog() -> Array:
	return [
		{"id": "bozdogan", "ad": "Bozdoğan (Valens) Su Kemeri", "dogu_m": -1990.0, "kuzey_m": 620.0,
			"gercek_olcu": Vector3(6.0, 29.0, 970.0), "yon_derece": 118.0, "durum": "saglam", "tur": "anit",
			"bakis": Vector3(0, 40.0, 0), "bakis_r": 90.0, "gorev": true},
		{"id": "havariyun", "ad": "Havariyun (Kutsal Havariler) Kilisesi", "dogu_m": -2520.0, "kuzey_m": 1225.0,
			"gercek_olcu": Vector3(78.0, 36.0, 78.0), "yon_derece": 90.0, "durum": "harap", "tur": "kilise",
			"bakis": Vector3(0, 46.0, 0), "bakis_r": 60.0, "gorev": true},
		{"id": "pantokrator", "ad": "Pantokrator Manastırı (üç kilise)", "dogu_m": -2050.0, "kuzey_m": 1085.0,
			"gercek_olcu": Vector3(34.0, 30.0, 56.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 40.0, 0), "bakis_r": 55.0, "gorev": true},
		{"id": "lips", "ad": "Lips Manastırı (Fenari İsa)", "dogu_m": -2750.0, "kuzey_m": 1230.0,
			"gercek_olcu": Vector3(26.0, 20.0, 34.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 30.0, 0), "bakis_r": 40.0},
		{"id": "kalenderhane", "ad": "Kyriotissa (Kalenderhane)", "dogu_m": -1880.0, "kuzey_m": 560.0,
			"gercek_olcu": Vector3(32.0, 26.0, 28.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 34.0, 0), "bakis_r": 40.0},
		{"id": "vefa", "ad": "Vefa Kilisesi (Aziz Theodoros)", "dogu_m": -1650.0, "kuzey_m": 700.0,
			"gercek_olcu": Vector3(18.0, 17.0, 14.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 25.0, 0), "bakis_r": 30.0},
		{"id": "pantepoptes", "ad": "Pantepoptes (Eski İmaret)", "dogu_m": -2020.0, "kuzey_m": 1280.0,
			"gercek_olcu": Vector3(20.0, 18.0, 17.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 26.0, 0), "bakis_r": 30.0},
		{"id": "gul", "ad": "Aya Theodosia (Gül)", "dogu_m": -2770.0, "kuzey_m": 1530.0,
			"gercek_olcu": Vector3(26.0, 22.0, 24.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 32.0, 0), "bakis_r": 35.0},
		{"id": "aspar", "ad": "Aspar Açık Sarnıcı (bostan)", "dogu_m": -3300.0, "kuzey_m": 1350.0,
			"gercek_olcu": Vector3(152.0, 10.0, 97.0), "yon_derece": 90.0, "durum": "bostan", "tur": "ayrinti",
			"bakis": Vector3(0, 24.0, 0), "bakis_r": 80.0},
		{"id": "polyeuktos", "ad": "Polyeuktos Harabesi", "dogu_m": -2005.0, "kuzey_m": 750.0,
			"gercek_olcu": Vector3(52.0, 12.0, 52.0), "yon_derece": 90.0, "durum": "harap", "tur": "anit",
			"bakis": Vector3(0, 20.0, 0), "bakis_r": 45.0},
	]


## Düğüm yerel koordinatından host koordinatına: kilise düğümleri kendi `rot`'unu taşır
static func build(id: String, host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	match id:
		"bozdogan": build_bozdogan(host, k, lod)
		"havariyun": build_havariyun(host, k, lod)
		"pantokrator": build_pantokrator(host, k, lod)
		"lips": build_lips(host, k, lod)
		"kalenderhane": build_kalenderhane(host, k, lod)
		"vefa": build_vefa(host, k, lod)
		"pantepoptes": build_pantepoptes(host, k, lod)
		"gul": build_gul(host, k, lod)
		"aspar": build_aspar(host, k, lod)
		"polyeuktos": build_polyeuktos(host, k, lod)


static func perches(id: String, k: float = 0.5) -> Array:
	match id:
		"bozdogan": return perches_bozdogan(k)
		"aspar": return perches_aspar(k)
		"polyeuktos": return perches_polyeuktos(k)
	return _info(id, k)["perches"]


static func climbs(id: String, k: float = 0.5) -> Array:
	match id:
		"bozdogan": return climbs_bozdogan(k)
		"aspar": return climbs_aspar(k)
		"polyeuktos": return climbs_polyeuktos(k)
	return _info(id, k)["climbs"]


# --- Bozdoğan ---------------------------------------------------------------------------------------------

static func build_bozdogan(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	SU.build_bozdogan(host, k, lod)


static func perches_bozdogan(k: float = 0.5) -> Array:
	var p := SU.params(k)
	var out: Array = []
	# yerel eksen x -> dünya -z (kök 90° döner): (x, y, z) -> (z, y, -x)
	for u in [0.5, 0.25, 0.75]:
		var x: float = (u - 0.5) * p["L"]
		out.append(Vector3(0, SU.deck_top(p, u) + 0.6 + 0.5, -x) + Vector3(DECK_Z(p), 0, 0))
	return out


static func DECK_Z(p: Dictionary) -> float:
	return -(SU.DECK_W * 0.5 - 0.75)       # yürüme yolunun ortası (parapet ile kanal arası)


static func climbs_bozdogan(k: float = 0.5) -> Array:
	var p := SU.params(k)
	var L: float = p["L"]
	var topv := SU.deck_top(p, 0.0)
	var n := int(ceil(topv / 0.28))
	var out: Array = []
	for e in [-1.0, 1.0]:
		# yerel x = e*(L/2 + 0.3 + 0.5*n) ... dünya (z, y, -x)
		var x0: float = e * (L * 0.5 + 0.3 + 0.5 * n + 0.8)
		var x1: float = e * (L * 0.5 + 0.3 + 0.5)
		out.append([Vector3(0, 0, -x0), Vector3(0, topv + 0.05, -x1), "basamak"])
	return out


# --- Kilise yardımcıları ---------------------------------------------------------------------------------

static func _merge(acc: Dictionary, r: Dictionary) -> void:
	acc["perches"].append_array(r.get("perches", []))
	acc["climbs"].append_array(r.get("climbs", []))
	acc["top"] = maxf(acc["top"], r.get("top", 0.0))


static var _cache := {}


## Yapıyı bir kez kurup (geçici düğüm) ipuçlarını önbellekler: perches/climbs `build` ile aynı sayıları verir.
static func _info(id: String, k: float) -> Dictionary:
	var key := "%s|%.3f" % [id, k]
	if _cache.has(key):
		return _cache[key]
	var tmp := Node3D.new()
	var acc := _layout(id, tmp, k, 0)
	tmp.free()
	_cache[key] = acc
	return acc


static func _layout(id: String, host: Node3D, k: float, lod: int) -> Dictionary:
	var acc := {"perches": [], "climbs": [], "top": 0.0}
	match id:
		"havariyun":
			var s := maxf(11.0 * k + 1.0, 3.2)
			var W := 3.0 * s / k
			_merge(acc, KIL.church(host, {"pos": Vector3.ZERO, "rot": 0.0, "W": W, "D": W, "Hc": 7.0, "ext": 5.0, "dome_d": 11.0,
				"narthex": 0.0, "col": KIT.BRICK, "roof": KIT.LEAD, "five": true, "ruin": 0.62, "seed": 1, "apses": 3, "tag": "Havariyun"}, k, lod))
			if lod == 0:
				HAR.build_heroon(host, Vector3(1.5 * s + 22.0 * k + 6.0, 0, -s * 0.2), k)
		"pantokrator":
			var W := 22.0
			var zs := (7.0 + 10.0) * k
			var zn := -(7.0 + 9.0) * k
			_merge(acc, KIL.church(host, {"pos": Vector3(0, 0, zs), "rot": 0.0, "W": W, "D": 20.0, "Hc": 9.0, "ext": 6.0, "dome_d": 7.0,
				"narthex": 0.0, "col": KIT.BRICK, "roof": KIT.LEAD, "ruin": 0.0, "seed": 2, "apses": 3, "tag": "GüneyKilise"}, k, lod))
			_merge(acc, KIL.church(host, {"pos": Vector3(0, 0, 0), "rot": 0.0, "W": W, "D": 14.0, "Hc": 8.0, "ext": 5.0, "dome_d": 9.0,
				"narthex": 0.0, "col": KIT.STONE.darkened(0.1), "roof": KIT.LEAD, "seed": 3, "apses": 1, "second": true, "tag": "OrtaKilise", "no_stair": true}, k, lod))
			_merge(acc, KIL.church(host, {"pos": Vector3(0, 0, zn), "rot": 0.0, "W": W, "D": 18.0, "Hc": 8.5, "ext": 5.5, "dome_d": 6.5,
				"narthex": 0.0, "col": KIT.BRICK, "roof": KIT.LEAD, "seed": 4, "apses": 3, "tag": "KuzeyKilise", "no_stair": true}, k, lod))
			# ortak narteks
			var nd := 6.0 * k
			var hn := 8.0 * k
			var D := 52.0 * k
			var nx := -W * k * 0.5 - nd * 0.5
			if lod == 0:
				KIT.blk(host, Vector3(nd, hn, D), Vector3(nx, 0, k), KIT.BRICK.lightened(0.12), "ashlar")
				HAR.build_pantokrator_court(host, k, -W * k * 0.5 - nd, lod)
			else:
				Props.box(host, Vector3(nd, hn, D), Vector3(nx, hn * 0.5, k), KIT.BRICK.lightened(0.12))
		"lips":
			_merge(acc, KIL.church(host, {"pos": Vector3(0, 0, 8.5 * k), "rot": 0.0, "W": 14.0, "D": 17.0, "Hc": 9.0, "ext": 5.0, "dome_d": 6.0,
				"narthex": 4.0, "col": KIT.BRICK, "roof": KIT.LEAD, "seed": 5, "apses": 3, "tag": "KuzeyKilise"}, k, lod))
			_merge(acc, KIL.church(host, {"pos": Vector3(0, 0, -8.5 * k), "rot": 0.0, "W": 14.0, "D": 17.0, "Hc": 8.0, "ext": 4.5, "dome_d": 5.5,
				"narthex": 4.0, "col": KIT.BRICK, "roof": KIT.TILE, "seed": 6, "apses": 1, "tag": "GüneyKilise", "no_stair": true}, k, lod))
		"kalenderhane":
			_merge(acc, KIL.church(host, {"pos": Vector3.ZERO, "rot": 0.0, "W": 22.0, "D": 24.0, "Hc": 10.0, "ext": 6.0, "dome_d": 9.0,
				"narthex": 5.0, "col": KIT.BRICK.lightened(0.05), "roof": KIT.LEAD, "seed": 7, "apses": 3, "tag": "Kyriotissa"}, k, lod))
		"vefa":
			_merge(acc, KIL.church(host, {"pos": Vector3.ZERO, "rot": 0.0, "W": 11.0, "D": 12.0, "Hc": 7.0, "ext": 4.0, "dome_d": 4.5,
				"narthex": 3.5, "col": KIT.BRICK, "roof": KIT.LEAD, "seed": 8, "apses": 3, "tag": "Vefa"}, k, lod))
		"pantepoptes":
			_merge(acc, KIL.church(host, {"pos": Vector3.ZERO, "rot": 0.0, "W": 13.0, "D": 15.0, "Hc": 8.0, "ext": 4.5, "dome_d": 5.5,
				"narthex": 4.0, "col": KIT.BRICK.lightened(0.04), "roof": KIT.LEAD, "seed": 9, "apses": 3, "tag": "Pantepoptes"}, k, lod))
		"gul":
			_merge(acc, KIL.church(host, {"pos": Vector3.ZERO, "rot": 0.0, "W": 17.0, "D": 21.0, "Hc": 9.0, "ext": 5.0, "dome_d": 8.0,
				"narthex": 4.5, "col": KIT.STONE.darkened(0.05), "roof": KIT.LEAD, "seed": 10, "apses": 3, "tag": "AyaTheodosia"}, k, lod))
	return acc


static func build_havariyun(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_layout("havariyun", host, k, lod)


static func build_pantokrator(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_layout("pantokrator", host, k, lod)


static func build_lips(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_layout("lips", host, k, lod)


static func build_kalenderhane(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_layout("kalenderhane", host, k, lod)


static func build_vefa(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_layout("vefa", host, k, lod)


static func build_pantepoptes(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_layout("pantepoptes", host, k, lod)


static func build_gul(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_layout("gul", host, k, lod)


static func build_aspar(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	HAR.build_aspar(host, k, lod)


static func build_polyeuktos(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	HAR.build_polyeuktos(host, k, lod)


static func perches_havariyun(k: float = 0.5) -> Array: return _info("havariyun", k)["perches"]
static func climbs_havariyun(k: float = 0.5) -> Array: return _info("havariyun", k)["climbs"]
static func perches_pantokrator(k: float = 0.5) -> Array: return _info("pantokrator", k)["perches"]
static func climbs_pantokrator(k: float = 0.5) -> Array: return _info("pantokrator", k)["climbs"]
static func perches_lips(k: float = 0.5) -> Array: return _info("lips", k)["perches"]
static func climbs_lips(k: float = 0.5) -> Array: return _info("lips", k)["climbs"]
static func perches_kalenderhane(k: float = 0.5) -> Array: return _info("kalenderhane", k)["perches"]
static func climbs_kalenderhane(k: float = 0.5) -> Array: return _info("kalenderhane", k)["climbs"]
static func perches_vefa(k: float = 0.5) -> Array: return _info("vefa", k)["perches"]
static func climbs_vefa(k: float = 0.5) -> Array: return _info("vefa", k)["climbs"]
static func perches_pantepoptes(k: float = 0.5) -> Array: return _info("pantepoptes", k)["perches"]
static func climbs_pantepoptes(k: float = 0.5) -> Array: return _info("pantepoptes", k)["climbs"]
static func perches_gul(k: float = 0.5) -> Array: return _info("gul", k)["perches"]
static func climbs_gul(k: float = 0.5) -> Array: return _info("gul", k)["climbs"]
static func perches_aspar(k: float = 0.5) -> Array: return HAR.perches_aspar(k)
static func climbs_aspar(k: float = 0.5) -> Array: return HAR.climbs_aspar(k)
static func perches_polyeuktos(k: float = 0.5) -> Array: return HAR.perches_polyeuktos(k)
static func climbs_polyeuktos(k: float = 0.5) -> Array: return HAR.climbs_polyeuktos(k)
