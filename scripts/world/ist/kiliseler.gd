class_name IstKiliseler
extends RefCounted
## İstanbul 1453 / kiliseler: genel kilise-manastır tipleri ve küçük anıtlar.
## Eksen: yapının uzun ekseni z boyunca, apsis -z (yon_derece = apsisin kuzeyden saat yönündeki açısı; gerçek
## kiliselerde apsis doğuya bakar → yön 90). Yerleştirici host'u rotation_degrees.y = -yon_derece ile döndürür
## (yon_derece 0 = apsis kuzeyde, yani kurulduğu gibi).
## Konumlar (dogu_m / kuzey_m) KESTİRİMDİR: tip örnekleri; yerleştirici gerçek yerleri CityGeo.load_places'ten alır.
## Çoklu çeşitlenme: host.set_meta("tohum", int) ve host.set_meta("latin", true) (bazilikada çan kulesi).

const IDS := ["kilise_kucuk", "sapel"]

static func _run(id: String, host: Node3D, k: float, lod: int, dry := false) -> IstKB:
	var b := IstKB.new(host, k, lod, id, dry)
	match id:
		"kilise_kucuk":
			IstKiliseTipleri.kucuk(b)
		"sapel":
			IstKiliseTipleri.sapel(b)
	return b


static func _e(id: String, ad: String, e: float, n: float, olcu: Vector3, yon: float, durum: String, tur: String, gorev: bool) -> Dictionary:
	return {
		"id": id, "ad": ad, "dogu_m": e, "kuzey_m": n, "gercek_olcu": olcu, "yon_derece": yon, "durum": durum, "tur": tur,
		"yer_kaynak": "kestirim",
		"bakis": Vector3(0, olcu.y + 8.0, 0), "bakis_r": maxf(olcu.x, olcu.z) * 0.5 + 25.0, "gorev": gorev,
	}


## Kayıt: şehir kurucusu bunu okuyup yerleştirir. bakis: yerel (k = 1,0); k için bakis_k(id, k).
static func catalog() -> Array:
	return [
		_e("kilise_kucuk", "Kapalı Yunan haçı küçük kilise (tek kubbe)", -2150, 1250, Vector3(10.0, 12.0, 15.0), 0, "saglam", "kilise", false),
		_e("sapel", "Şapel", -2600, 2000, Vector3(5.0, 6.5, 10.0), 0, "saglam", "kilise", false)
	]


## Genel erişim (id ile): önizleme ve yerleştirici için.
static func build(id: String, host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run(id, host, k, lod)


static func perches(id: String, k: float = 0.5) -> Array:
	return _run(id, null, k, 0, true).perches


static func climbs(id: String, k: float = 0.5) -> Array:
	return _run(id, null, k, 0, true).climbs


## Yan görev işaretinin k ölçeğindeki yeri (tepenin 8 m üstü).
static func bakis_k(id: String, k: float) -> Vector3:
	var b := _run(id, null, k, 2, true)
	return Vector3(0, b.top_y + 8.0, 0)



static func build_kilise_kucuk(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("kilise_kucuk", host, k, lod)


static func perches_kilise_kucuk(k: float = 0.5) -> Array:
	return _run("kilise_kucuk", null, k, 0, true).perches


static func climbs_kilise_kucuk(k: float = 0.5) -> Array:
	return _run("kilise_kucuk", null, k, 0, true).climbs


static func build_sapel(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("sapel", host, k, lod)


static func perches_sapel(k: float = 0.5) -> Array:
	return _run("sapel", null, k, 0, true).perches


static func climbs_sapel(k: float = 0.5) -> Array:
	return _run("sapel", null, k, 0, true).climbs
