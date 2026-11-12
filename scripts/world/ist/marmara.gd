class_name IstMarmara
extends RefCounted
## Marmara deniz surları, limanlar, Bukoleon: kayıt + çağrı yönlendirici.
## Şehir kurucusu: IstMarmara.catalog() okur; her kayıt için build_<id>(host, k, lod), perches_<id>(k), climbs_<id>(k).
## Yön kuralı: öğeler GERÇEK pusula çerçevesinde kurulur (+x doğu, -z kuzey, +z güney = DENİZ). `yon_derece`,
## kurulumdaki ana eksenin kuzeyden saat yönü açısıdır (sur koşusu doğu-batı: 90). Şehir kurucusu hostu
## rotation_y = deg_to_rad(-(gerçek_yön - yon_derece)) ile döndürür.

const SUR := preload("res://scripts/world/ist/marmara_sur.gd")
const BUK := preload("res://scripts/world/ist/marmara_bukoleon.gd")

const MODS := {
	"msur": SUR,
	"bukoleon": BUK,
}


static func catalog() -> Array:
	var out: Array = []
	out.append(msur_entry())
	out.append(bukoleon_entry())
	return out


static func msur_entry() -> Dictionary:
	return {
		"id": "msur", "ad": "Marmara deniz surları (tipik koşu)", "dogu_m": -1500.0, "kuzey_m": -1020.0,
		"gercek_olcu": Vector3(14.0, 12.0, 150.0), "yon_derece": 90.0, "durum": "saglam", "tur": "sur",
		"bakis": Vector3(0, 24.0, 0), "bakis_r": 80.0, "gorev": false,
	}


static func bukoleon_entry() -> Dictionary:
	return {
		"id": "bukoleon", "ad": "Bukoleon Sarayı deniz cephesi", "dogu_m": -290.0, "kuzey_m": -890.0,
		"gercek_olcu": Vector3(64.0, 17.0, 20.0), "yon_derece": 90.0, "durum": "harap", "tur": "anit",
		"bakis": Vector3(0, 24.0, 0), "bakis_r": 60.0, "gorev": false,
		"kapi_onu": Vector3(-19.0, 0.0, 14.0),
	}


static func build(id: String, host: Node3D, k: float, lod: int) -> void:
	MODS[id].call("build_" + id, host, k, lod)


static func perches(id: String, k: float) -> Array:
	return MODS[id].call("perches_" + id, k)


static func climbs(id: String, k: float) -> Array:
	return MODS[id].call("climbs_" + id, k)


static func build_msur(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	SUR.build_msur(host, k, lod)


static func perches_msur(k: float = 0.5) -> Array:
	return SUR.perches_msur(k)


static func climbs_msur(k: float = 0.5) -> Array:
	return SUR.climbs_msur(k)


static func build_bukoleon(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	BUK.build_bukoleon(host, k, lod)


static func perches_bukoleon(k: float = 0.5) -> Array:
	return BUK.perches_bukoleon(k)


static func climbs_bukoleon(k: float = 0.5) -> Array:
	return BUK.climbs_bukoleon(k)
