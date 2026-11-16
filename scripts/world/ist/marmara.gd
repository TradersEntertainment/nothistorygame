class_name IstMarmara
extends RefCounted
## Marmara deniz surları, limanlar, Bukoleon: kayıt + çağrı yönlendirici.
## Şehir kurucusu: IstMarmara.catalog() okur; her kayıt için build_<id>(host, k, lod), perches_<id>(k), climbs_<id>(k).
## Yön kuralı: öğeler GERÇEK pusula çerçevesinde kurulur (+x doğu, -z kuzey, +z güney = DENİZ). `yon_derece`,
## kurulumdaki ana eksenin kuzeyden saat yönü açısıdır (sur koşusu doğu-batı: 90). Şehir kurucusu hostu
## rotation_y = deg_to_rad(-(gerçek_yön - yon_derece)) ile döndürür.

const SUR := preload("res://scripts/world/ist/marmara_sur.gd")
const LIM := preload("res://scripts/world/ist/marmara_liman.gd")
const KIY := preload("res://scripts/world/ist/marmara_kiyi.gd")
const BUK := preload("res://scripts/world/ist/marmara_bukoleon.gd")

const MODS := {
	"msur": SUR,
	"bukoleon": BUK,
	"kontoskalion": LIM,
	"langa": LIM,
	"sophia": LIM,
	"mermerkule": KIY,
	"ahirkapi": KIY,
	"balikci": KIY,
	"kayikhane": KIY,
	"agsehpa": KIY,
	"kayalar": KIY,
}


static func catalog() -> Array:
	var out: Array = []
	out.append(msur_entry())
	out.append(bukoleon_entry())
	out.append({
		"id": "kontoskalion", "ad": "Kontoskalion limanı (Kadırga): kapalı havuz, mendirek, kadırga tezgâhları", "dogu_m": -1150.0, "kuzey_m": -1220.0,
		"gercek_olcu": Vector3(260.0, 14.0, 220.0), "yon_derece": 0.0, "durum": "saglam", "tur": "liman",
		"bakis": Vector3(0, 16.0, 0), "bakis_r": 70.0, "gorev": false, "kapi_onu": Vector3(0, 0, 60.0), "cukur": true,
	})
	out.append({
		"id": "langa", "ad": "Langa bostanları (dolmuş Eleutherios/Theodosius limanı)", "dogu_m": -2540.0, "kuzey_m": -1125.0,
		"gercek_olcu": Vector3(300.0, 5.0, 200.0), "yon_derece": 0.0, "durum": "bostan", "tur": "bitki",
		"bakis": Vector3(0, 14.0, 0), "bakis_r": 60.0, "gorev": false, "kapi_onu": Vector3(-20.0, 0, 30.0),
	})
	out.append({
		"id": "sophia", "ad": "Sophia (Iulianos) limanı kalıntısı", "dogu_m": -420.0, "kuzey_m": -930.0,
		"gercek_olcu": Vector3(150.0, 6.0, 90.0), "yon_derece": 0.0, "durum": "harap", "tur": "liman",
		"bakis": Vector3(0, 14.0, 0), "bakis_r": 50.0, "gorev": false, "kapi_onu": Vector3(5.0, 0, 20.0),
	})
	out.append({
		"id": "mermerkule", "ad": "Mermer Kule (kara ve deniz surlarının birleştiği köşe)", "dogu_m": -4790.0, "kuzey_m": -1560.0,
		"gercek_olcu": Vector3(14.0, 20.0, 14.0), "yon_derece": 0.0, "durum": "saglam", "tur": "kapi",
		"bakis": Vector3(0, 28.0, 0), "bakis_r": 50.0, "gorev": false, "kapi_onu": Vector3(-4.4, 0.0, 14.0),
	})
	out.append({
		"id": "ahirkapi", "ad": "Ahırkapı çevresi: küçük deniz kapısı, çeşme, kıyı", "dogu_m": 80.0, "kuzey_m": -880.0,
		"gercek_olcu": Vector3(116.0, 14.0, 14.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kapi",
		"bakis": Vector3(0, 22.0, 0), "bakis_r": 50.0, "gorev": false, "kapi_onu": Vector3(0.0, 0.0, 12.0),
	})
	out.append({
		"id": "balikci", "ad": "Balıkçı barınakları (kamış kulübeler, ateş, kayıklar)", "dogu_m": -4100.0, "kuzey_m": -1500.0,
		"gercek_olcu": Vector3(28.0, 4.0, 20.0), "yon_derece": 0.0, "durum": "saglam", "tur": "ev",
		"bakis": Vector3(0, 12.0, 0), "bakis_r": 30.0, "gorev": false, "kapi_onu": Vector3(0.5, 0.0, 8.0),
	})
	out.append({
		"id": "kayikhane", "ad": "Kayıkhane (taş-ahşap kayık sundurması)", "dogu_m": -900.0, "kuzey_m": -1180.0,
		"gercek_olcu": Vector3(18.0, 9.0, 9.0), "yon_derece": 90.0, "durum": "saglam", "tur": "ev",
		"bakis": Vector3(0, 16.0, 0), "bakis_r": 30.0, "gorev": false, "kapi_onu": Vector3(0.0, 0.0, 9.0),
	})
	out.append({
		"id": "agsehpa", "ad": "Ağ kurutma sehpaları", "dogu_m": -4050.0, "kuzey_m": -1490.0,
		"gercek_olcu": Vector3(18.0, 3.0, 8.0), "yon_derece": 90.0, "durum": "saglam", "tur": "ayrinti",
		"bakis": Vector3(0, 10.0, 0), "bakis_r": 20.0, "gorev": false, "kapi_onu": Vector3(0.0, 0.0, 9.0),
	})
	out.append({
		"id": "kayalar", "ad": "Kıyı kayaları", "dogu_m": -3000.0, "kuzey_m": -1250.0,
		"gercek_olcu": Vector3(24.0, 4.0, 14.0), "yon_derece": 0.0, "durum": "saglam", "tur": "ayrinti",
		"bakis": Vector3(0, 12.0, 0), "bakis_r": 25.0, "gorev": false, "kapi_onu": Vector3(-8.0, 0.0, 8.0),
	})
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


## Çukur dikdörtgenleri (yerel x, z): şehir kurucusu zemini bu alanlardan keser (havuz tabanı y = -2,4 yerel).
static func pits(id: String, k: float) -> Array:
	if id == "kontoskalion":
		return LIM.pits_kontoskalion(k)
	return []


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


static func build_kontoskalion(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	LIM.build_kontoskalion(host, k, lod)


static func perches_kontoskalion(k: float = 0.5) -> Array:
	return LIM.perches_kontoskalion(k)


static func climbs_kontoskalion(k: float = 0.5) -> Array:
	return LIM.climbs_kontoskalion(k)


static func build_langa(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	LIM.build_langa(host, k, lod)


static func perches_langa(k: float = 0.5) -> Array:
	return LIM.perches_langa(k)


static func climbs_langa(k: float = 0.5) -> Array:
	return LIM.climbs_langa(k)


static func build_sophia(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	LIM.build_sophia(host, k, lod)


static func perches_sophia(k: float = 0.5) -> Array:
	return LIM.perches_sophia(k)


static func climbs_sophia(k: float = 0.5) -> Array:
	return LIM.climbs_sophia(k)


static func build_mermerkule(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	KIY.build_mermerkule(host, k, lod)


static func perches_mermerkule(k: float = 0.5) -> Array:
	return KIY.perches_mermerkule(k)


static func climbs_mermerkule(k: float = 0.5) -> Array:
	return KIY.climbs_mermerkule(k)


static func build_ahirkapi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	KIY.build_ahirkapi(host, k, lod)


static func perches_ahirkapi(k: float = 0.5) -> Array:
	return KIY.perches_ahirkapi(k)


static func climbs_ahirkapi(k: float = 0.5) -> Array:
	return KIY.climbs_ahirkapi(k)


static func build_balikci(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	KIY.build_balikci(host, k, lod)


static func perches_balikci(k: float = 0.5) -> Array:
	return KIY.perches_balikci(k)


static func climbs_balikci(k: float = 0.5) -> Array:
	return KIY.climbs_balikci(k)


static func build_kayikhane(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	KIY.build_kayikhane(host, k, lod)


static func perches_kayikhane(k: float = 0.5) -> Array:
	return KIY.perches_kayikhane(k)


static func climbs_kayikhane(k: float = 0.5) -> Array:
	return KIY.climbs_kayikhane(k)


static func build_agsehpa(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	KIY.build_agsehpa(host, k, lod)


static func perches_agsehpa(k: float = 0.5) -> Array:
	return KIY.perches_agsehpa(k)


static func climbs_agsehpa(k: float = 0.5) -> Array:
	return KIY.climbs_agsehpa(k)


static func build_kayalar(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	KIY.build_kayalar(host, k, lod)


static func perches_kayalar(k: float = 0.5) -> Array:
	return KIY.perches_kayalar(k)


static func climbs_kayalar(k: float = 0.5) -> Array:
	return KIY.climbs_kayalar(k)
