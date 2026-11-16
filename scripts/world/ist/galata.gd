class_name IstGalata
extends RefCounted
## İstanbul 1453 — GALATA (Pera), Ceneviz kolonisi. Giriş noktası: katalog + her yapı için build/perches/climbs.
## Yapılar: Christea Turris (Galata Kulesi), kara suru (kapı + burçlar + hendek), dört kilise (San Domenico,
## San Francesco, San Michele, San Benedetto), Palazzo del Comune, loca, Ceneviz evi, rıhtım, ambar, tersane,
## bağ ve mezarlık. Ayrıntı: docs/_kanit_ist_galata/rapor.md. Yerel koordinat: merkez tabanın ortası, y=0 zemin,
## +x doğu, -z kuzey, yon_derece = 0. Kütle k ile ölçeklenir; insan ölçüleri (kapı, basamak, korkuluk) sabit.

const O := preload("res://scripts/world/ist/galata_ortak.gd")
const IDS := ["galata_kulesi", "galata_sur", "san_domenico", "san_francesco", "san_michele", "san_benedetto",
	"palazzo_comune", "galata_loca", "ceneviz_evi", "galata_rihtim", "galata_ambar", "galata_tersane",
	"galata_bag", "galata_mezarlik"]


static func catalog() -> Array:
	return [
		{"id": "galata_kulesi", "ad": "Christea Turris (Galata Kulesi)", "dogu_m": -504.0, "kuzey_m": 1892.0,
			"gercek_olcu": Vector3(16.5, 67.0, 16.5), "yon_derece": 0.0, "durum": "saglam", "tur": "anit",
			"bakis": Vector3(0, 75.0, 0), "bakis_r": 70.0, "gorev": true},
		{"id": "galata_sur", "ad": "Galata kara surları ve kapısı", "dogu_m": -480.0, "kuzey_m": 2010.0,
			"gercek_olcu": Vector3(120.0, 14.0, 30.0), "yon_derece": 80.0, "durum": "saglam", "tur": "sur",
			"bakis": Vector3(0, 24.0, 0), "bakis_r": 50.0, "gorev": true},
		{"id": "san_domenico", "ad": "San Domenico kilisesi", "dogu_m": -545.0, "kuzey_m": 1646.0,
			"gercek_olcu": Vector3(18.0, 40.0, 38.0), "yon_derece": 0.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 48.0, 0), "bakis_r": 40.0, "gorev": true},
		{"id": "san_francesco", "ad": "San Francesco kilisesi", "dogu_m": -600.0, "kuzey_m": 1720.0,
			"gercek_olcu": Vector3(14.0, 22.0, 28.0), "yon_derece": 10.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 32.0, 0), "bakis_r": 30.0},
		{"id": "san_michele", "ad": "San Michele kilisesi", "dogu_m": -430.0, "kuzey_m": 1760.0,
			"gercek_olcu": Vector3(12.0, 18.0, 24.0), "yon_derece": -8.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 28.0, 0), "bakis_r": 28.0},
		{"id": "san_benedetto", "ad": "San Benedetto kilisesi", "dogu_m": -535.0, "kuzey_m": 1940.0,
			"gercek_olcu": Vector3(11.0, 20.0, 22.0), "yon_derece": 0.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 30.0, 0), "bakis_r": 28.0},
		{"id": "palazzo_comune", "ad": "Palazzo del Comune (podestà sarayı)", "dogu_m": -425.0, "kuzey_m": 1600.0,
			"gercek_olcu": Vector3(26.0, 17.0, 16.0), "yon_derece": 0.0, "durum": "saglam", "tur": "anit",
			"bakis": Vector3(0, 27.0, 0), "bakis_r": 36.0, "gorev": true},
		{"id": "galata_loca", "ad": "Ceneviz locası (tüccar revakı)", "dogu_m": -470.0, "kuzey_m": 1530.0,
			"gercek_olcu": Vector3(18.0, 10.0, 11.0), "yon_derece": 0.0, "durum": "saglam", "tur": "anit",
			"bakis": Vector3(0, 18.0, 0), "bakis_r": 24.0},
		{"id": "ceneviz_evi", "ad": "Ceneviz taş-ahşap evi", "dogu_m": -500.0, "kuzey_m": 1800.0,
			"gercek_olcu": Vector3(7.0, 10.0, 8.0), "yon_derece": 0.0, "durum": "saglam", "tur": "ev",
			"bakis": Vector3(0, 16.0, 0), "bakis_r": 14.0},
		{"id": "galata_rihtim", "ad": "Galata rıhtımı ve iskeleler", "dogu_m": -470.0, "kuzey_m": 1470.0,
			"gercek_olcu": Vector3(70.0, 8.0, 24.0), "yon_derece": 0.0, "durum": "saglam", "tur": "liman",
			"bakis": Vector3(0, 16.0, 0), "bakis_r": 40.0},
		{"id": "galata_ambar", "ad": "Ceneviz taş ambarı", "dogu_m": -380.0, "kuzey_m": 1520.0,
			"gercek_olcu": Vector3(30.0, 11.0, 12.0), "yon_derece": 0.0, "durum": "saglam", "tur": "ev",
			"bakis": Vector3(0, 18.0, 0), "bakis_r": 22.0},
		{"id": "galata_tersane", "ad": "Galata tersanesi (kızak ve atölye)", "dogu_m": -250.0, "kuzey_m": 1690.0,
			"gercek_olcu": Vector3(40.0, 14.0, 34.0), "yon_derece": 0.0, "durum": "saglam", "tur": "liman",
			"bakis": Vector3(0, 22.0, 0), "bakis_r": 30.0},
		{"id": "galata_bag", "ad": "Galata bağları (sur dışı yamaç)", "dogu_m": -300.0, "kuzey_m": 2150.0,
			"gercek_olcu": Vector3(50.0, 4.0, 40.0), "yon_derece": 0.0, "durum": "bostan", "tur": "bitki"},
		{"id": "galata_mezarlik", "ad": "Galata mezarlığı (sur dışı)", "dogu_m": -450.0, "kuzey_m": 2230.0,
			"gercek_olcu": Vector3(36.0, 6.0, 30.0), "yon_derece": 0.0, "durum": "saglam", "tur": "ayrinti"},
	]


## Tek kapı: id'ye göre kur.
static func build(id: String, host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run(id, host, k, lod, {})


static func perches(id: String, k: float = 0.5) -> Array:
	var out := {"perches": [], "climbs": []}
	var tmp := Node3D.new()
	_run(id, tmp, k, 3, out)
	tmp.free()
	return out["perches"]


static func climbs(id: String, k: float = 0.5) -> Array:
	var out := {"perches": [], "climbs": []}
	var tmp := Node3D.new()
	_run(id, tmp, k, 3, out)
	tmp.free()
	return out["climbs"]


static func _run(id: String, host: Node3D, k: float, lod: int, out: Dictionary) -> void:
	if not out.has("perches"):
		out["perches"] = []
		out["climbs"] = []
	O.start(lod)
	match id:
		"galata_kulesi": IstGalataKule.build(host, k, lod, out)
		"galata_sur": IstGalataSur.build(host, k, lod, out)
		_: IstGalataYapi.build(id, host, k, lod, out)


# ---- Dondurulmuş arayüz: her yapı için üçlü ----
static func build_galata_kulesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("galata_kulesi", host, k, lod)
static func perches_galata_kulesi(k: float = 0.5) -> Array: return perches("galata_kulesi", k)
static func climbs_galata_kulesi(k: float = 0.5) -> Array: return climbs("galata_kulesi", k)
static func build_galata_sur(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("galata_sur", host, k, lod)
static func perches_galata_sur(k: float = 0.5) -> Array: return perches("galata_sur", k)
static func climbs_galata_sur(k: float = 0.5) -> Array: return climbs("galata_sur", k)
static func build_san_domenico(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("san_domenico", host, k, lod)
static func perches_san_domenico(k: float = 0.5) -> Array: return perches("san_domenico", k)
static func climbs_san_domenico(k: float = 0.5) -> Array: return climbs("san_domenico", k)
static func build_san_francesco(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("san_francesco", host, k, lod)
static func perches_san_francesco(k: float = 0.5) -> Array: return perches("san_francesco", k)
static func climbs_san_francesco(k: float = 0.5) -> Array: return climbs("san_francesco", k)
static func build_san_michele(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("san_michele", host, k, lod)
static func perches_san_michele(k: float = 0.5) -> Array: return perches("san_michele", k)
static func climbs_san_michele(k: float = 0.5) -> Array: return climbs("san_michele", k)
static func build_san_benedetto(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("san_benedetto", host, k, lod)
static func perches_san_benedetto(k: float = 0.5) -> Array: return perches("san_benedetto", k)
static func climbs_san_benedetto(k: float = 0.5) -> Array: return climbs("san_benedetto", k)
static func build_palazzo_comune(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("palazzo_comune", host, k, lod)
static func perches_palazzo_comune(k: float = 0.5) -> Array: return perches("palazzo_comune", k)
static func climbs_palazzo_comune(k: float = 0.5) -> Array: return climbs("palazzo_comune", k)
static func build_galata_loca(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("galata_loca", host, k, lod)
static func perches_galata_loca(k: float = 0.5) -> Array: return perches("galata_loca", k)
static func climbs_galata_loca(k: float = 0.5) -> Array: return climbs("galata_loca", k)
static func build_ceneviz_evi(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("ceneviz_evi", host, k, lod)
static func perches_ceneviz_evi(k: float = 0.5) -> Array: return perches("ceneviz_evi", k)
static func climbs_ceneviz_evi(k: float = 0.5) -> Array: return climbs("ceneviz_evi", k)
static func build_galata_rihtim(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("galata_rihtim", host, k, lod)
static func perches_galata_rihtim(k: float = 0.5) -> Array: return perches("galata_rihtim", k)
static func climbs_galata_rihtim(k: float = 0.5) -> Array: return climbs("galata_rihtim", k)
static func build_galata_ambar(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("galata_ambar", host, k, lod)
static func perches_galata_ambar(k: float = 0.5) -> Array: return perches("galata_ambar", k)
static func climbs_galata_ambar(k: float = 0.5) -> Array: return climbs("galata_ambar", k)
static func build_galata_tersane(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("galata_tersane", host, k, lod)
static func perches_galata_tersane(k: float = 0.5) -> Array: return perches("galata_tersane", k)
static func climbs_galata_tersane(k: float = 0.5) -> Array: return climbs("galata_tersane", k)
static func build_galata_bag(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("galata_bag", host, k, lod)
static func perches_galata_bag(k: float = 0.5) -> Array: return perches("galata_bag", k)
static func climbs_galata_bag(k: float = 0.5) -> Array: return climbs("galata_bag", k)
static func build_galata_mezarlik(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("galata_mezarlik", host, k, lod)
static func perches_galata_mezarlik(k: float = 0.5) -> Array: return perches("galata_mezarlik", k)
static func climbs_galata_mezarlik(k: float = 0.5) -> Array: return climbs("galata_mezarlik", k)
