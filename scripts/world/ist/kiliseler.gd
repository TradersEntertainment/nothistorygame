class_name IstKiliseler
extends RefCounted
## İstanbul 1453 / kiliseler: genel kilise-manastır tipleri ve küçük anıtlar.
## Eksen: yapının uzun ekseni z boyunca, apsis -z (yon_derece = apsisin kuzeyden saat yönündeki açısı; gerçek
## kiliselerde apsis doğuya bakar → yön 90). Yerleştirici host'u rotation_degrees.y = -yon_derece ile döndürür
## (yon_derece 0 = apsis kuzeyde, yani kurulduğu gibi).
## Konumlar (dogu_m / kuzey_m) KESTİRİMDİR: tip örnekleri; yerleştirici gerçek yerleri CityGeo.load_places'ten alır.
## Çoklu çeşitlenme: host.set_meta("tohum", int) ve host.set_meta("latin", true) (bazilikada çan kulesi).

const IDS := ["kilise_kucuk", "kilise_orta", "bazilika", "sapel", "manastir", "ayazma", "munzevi_kulesi", "ikona_nisi", "mezarlik", "nymphaion", "harabe_tonoz", "harabe_kemer", "harabe_sutun", "harabe_mozaik", "harabe_sarmasik"]

static func _run(id: String, host: Node3D, k: float, lod: int, dry := false) -> IstKB:
	var b := IstKB.new(host, k, lod, id, dry)
	match id:
		"kilise_kucuk":
			IstKiliseTipleri.kucuk(b)
		"kilise_orta":
			IstKiliseTipleri.orta(b)
		"bazilika":
			IstKiliseTipleri.bazilika(b)
		"sapel":
			IstKiliseTipleri.sapel(b)
		"manastir":
			IstKiliseManastir.manastir(b)
		"ayazma":
			IstKiliseManastir.ayazma(b)
		"munzevi_kulesi":
			IstKiliseManastir.kule(b)
		"ikona_nisi":
			IstKiliseManastir.nisi(b)
		"mezarlik":
			IstKiliseHarabe.mezarlik(b)
		"nymphaion":
			IstKiliseHarabe.nymphaion(b)
		"harabe_tonoz":
			IstKiliseHarabe.tonoz(b)
		"harabe_kemer":
			IstKiliseHarabe.kemer(b)
		"harabe_sutun":
			IstKiliseHarabe.sutun(b)
		"harabe_mozaik":
			IstKiliseHarabe.mozaik(b)
		"harabe_sarmasik":
			IstKiliseHarabe.sarmasik(b)
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
		_e("kilise_orta", "Dört sütunlu orta kilise (narteks, üç apsis)", -1900, 1450, Vector3(17.0, 18.0, 26.0), 0, "saglam", "kilise", true),
		_e("bazilika", "Üç nefli bazilika (ahşap çatı)", -3375, -924, Vector3(18.0, 13.0, 34.0), 0, "saglam", "kilise", true),
		_e("sapel", "Şapel", -2600, 2000, Vector3(5.0, 6.5, 10.0), 0, "saglam", "kilise", false),
		_e("manastir", "Manastır külliyesi", -2300, 900, Vector3(70.0, 15.0, 80.0), 0, "saglam", "kilise", true),
		_e("ayazma", "Ayazma (kutsal pınar)", -1500, 600, Vector3(6.0, 5.0, 8.0), 0, "saglam", "kilise", false),
		_e("munzevi_kulesi", "Münzevi kulesi", -4200, 1800, Vector3(5.0, 14.0, 5.0), 0, "saglam", "kilise", false),
		_e("ikona_nisi", "Yol kenarı ikona nişi (proskynetarion)", -900, 300, Vector3(2.8, 3.0, 2.2), 0, "saglam", "ayrinti", false),
		_e("mezarlik", "Mezarlık ve lahitler", -3800, 500, Vector3(16.0, 6.0, 14.0), 0, "saglam", "ayrinti", false),
		_e("nymphaion", "Çeşme / nymphaion kalıntısı", -1100, 150, Vector3(9.0, 5.0, 8.0), 0, "harap", "anit", false),
		_e("harabe_tonoz", "Yıkık tonoz", -600, -150, Vector3(9.0, 7.0, 12.0), 0, "harap", "anit", false),
		_e("harabe_kemer", "Tek ayakta kalmış kemer", -3300, 1400, Vector3(7.0, 7.0, 2.0), 0, "harap", "anit", false),
		_e("harabe_sutun", "Sütun sırası", -400, -250, Vector3(6.0, 6.0, 18.0), 0, "harap", "anit", false),
		_e("harabe_mozaik", "Mozaik döşeme parçası", -235, -312, Vector3(8.0, 1.2, 10.0), 0, "harap", "ayrinti", false),
		_e("harabe_sarmasik", "Sarmaşıklı duvar", -2800, 300, Vector3(11.0, 5.0, 3.0), 0, "harap", "ayrinti", false)
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


static func build_kilise_orta(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("kilise_orta", host, k, lod)


static func perches_kilise_orta(k: float = 0.5) -> Array:
	return _run("kilise_orta", null, k, 0, true).perches


static func climbs_kilise_orta(k: float = 0.5) -> Array:
	return _run("kilise_orta", null, k, 0, true).climbs


static func build_bazilika(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("bazilika", host, k, lod)


static func perches_bazilika(k: float = 0.5) -> Array:
	return _run("bazilika", null, k, 0, true).perches


static func climbs_bazilika(k: float = 0.5) -> Array:
	return _run("bazilika", null, k, 0, true).climbs


static func build_sapel(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("sapel", host, k, lod)


static func perches_sapel(k: float = 0.5) -> Array:
	return _run("sapel", null, k, 0, true).perches


static func climbs_sapel(k: float = 0.5) -> Array:
	return _run("sapel", null, k, 0, true).climbs


static func build_manastir(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("manastir", host, k, lod)


static func perches_manastir(k: float = 0.5) -> Array:
	return _run("manastir", null, k, 0, true).perches


static func climbs_manastir(k: float = 0.5) -> Array:
	return _run("manastir", null, k, 0, true).climbs


static func build_ayazma(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("ayazma", host, k, lod)


static func perches_ayazma(k: float = 0.5) -> Array:
	return _run("ayazma", null, k, 0, true).perches


static func climbs_ayazma(k: float = 0.5) -> Array:
	return _run("ayazma", null, k, 0, true).climbs


static func build_munzevi_kulesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("munzevi_kulesi", host, k, lod)


static func perches_munzevi_kulesi(k: float = 0.5) -> Array:
	return _run("munzevi_kulesi", null, k, 0, true).perches


static func climbs_munzevi_kulesi(k: float = 0.5) -> Array:
	return _run("munzevi_kulesi", null, k, 0, true).climbs


static func build_ikona_nisi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("ikona_nisi", host, k, lod)


static func perches_ikona_nisi(k: float = 0.5) -> Array:
	return _run("ikona_nisi", null, k, 0, true).perches


static func climbs_ikona_nisi(k: float = 0.5) -> Array:
	return _run("ikona_nisi", null, k, 0, true).climbs


static func build_mezarlik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("mezarlik", host, k, lod)


static func perches_mezarlik(k: float = 0.5) -> Array:
	return _run("mezarlik", null, k, 0, true).perches


static func climbs_mezarlik(k: float = 0.5) -> Array:
	return _run("mezarlik", null, k, 0, true).climbs


static func build_nymphaion(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("nymphaion", host, k, lod)


static func perches_nymphaion(k: float = 0.5) -> Array:
	return _run("nymphaion", null, k, 0, true).perches


static func climbs_nymphaion(k: float = 0.5) -> Array:
	return _run("nymphaion", null, k, 0, true).climbs


static func build_harabe_tonoz(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("harabe_tonoz", host, k, lod)


static func perches_harabe_tonoz(k: float = 0.5) -> Array:
	return _run("harabe_tonoz", null, k, 0, true).perches


static func climbs_harabe_tonoz(k: float = 0.5) -> Array:
	return _run("harabe_tonoz", null, k, 0, true).climbs


static func build_harabe_kemer(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("harabe_kemer", host, k, lod)


static func perches_harabe_kemer(k: float = 0.5) -> Array:
	return _run("harabe_kemer", null, k, 0, true).perches


static func climbs_harabe_kemer(k: float = 0.5) -> Array:
	return _run("harabe_kemer", null, k, 0, true).climbs


static func build_harabe_sutun(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("harabe_sutun", host, k, lod)


static func perches_harabe_sutun(k: float = 0.5) -> Array:
	return _run("harabe_sutun", null, k, 0, true).perches


static func climbs_harabe_sutun(k: float = 0.5) -> Array:
	return _run("harabe_sutun", null, k, 0, true).climbs


static func build_harabe_mozaik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("harabe_mozaik", host, k, lod)


static func perches_harabe_mozaik(k: float = 0.5) -> Array:
	return _run("harabe_mozaik", null, k, 0, true).perches


static func climbs_harabe_mozaik(k: float = 0.5) -> Array:
	return _run("harabe_mozaik", null, k, 0, true).climbs


static func build_harabe_sarmasik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run("harabe_sarmasik", host, k, lod)


static func perches_harabe_sarmasik(k: float = 0.5) -> Array:
	return _run("harabe_sarmasik", null, k, 0, true).perches


static func climbs_harabe_sarmasik(k: float = 0.5) -> Array:
	return _run("harabe_sarmasik", null, k, 0, true).climbs
