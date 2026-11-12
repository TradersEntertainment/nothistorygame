class_name IstHalic
extends RefCounted
## Haliç güney kıyısı (Nisan 1453): deniz suru, Eugenios kulesi ve zincir, Venedik/Pisa/Amalfi/Ceneviz/Yahudi
## mahalleleri, iskeleler, Neorion limanı, balık pazarı, Petrion ve Fener kapıları.
## Dondurulmuş arayüz: catalog(), build_<id>(host, k, lod), perches_<id>(k), climbs_<id>(k) (id'ler aşağıda).
## Koordinat: Ayasofya kubbesi (0,0); kuzey +, doğu +. Haliç güney kıyısı kuzeybatı-güneydoğu eğik; yön_derece buna göre.
## Konumlar KESTİRİMDİR (Van Millingen sırası: batıdan doğuya Drungarii, Perama, San Marco, Hicanatissa, Neorion, Eugenios).

const IDS := ["sur", "eugenios", "venedik", "pisa_amalfi", "ceneviz", "yahudi", "neorion", "iskele", "balik", "petrion", "fener"]


static func catalog() -> Array:
	return [
		{"id": "halic_sur", "ad": "Haliç deniz suru ve kapıları", "dogu_m": -330.0, "kuzey_m": 760.0, "gercek_olcu": Vector3(5.0, 14.0, 96.0), "yon_derece": 60.0, "durum": "saglam", "tur": "sur", "bakis": Vector3(0, 16, 0), "bakis_r": 40.0, "gorev": true},
		{"id": "halic_eugenios", "ad": "Eugenios Kulesi ve Zincir", "dogu_m": 470.0, "kuzey_m": 640.0, "gercek_olcu": Vector3(14.0, 22.0, 120.0), "yon_derece": 0.0, "durum": "saglam", "tur": "anit", "bakis": Vector3(0, 30, 0), "bakis_r": 50.0, "gorev": true},
		{"id": "halic_venedik", "ad": "Venedik mahallesi (bailo evi, San Marco, loca, ambarlar)", "dogu_m": -120.0, "kuzey_m": 700.0, "gercek_olcu": Vector3(120.0, 20.0, 80.0), "yon_derece": 60.0, "durum": "saglam", "tur": "ev", "bakis": Vector3(0, 28, 0), "bakis_r": 45.0, "gorev": true},
		{"id": "halic_pisa_amalfi", "ad": "Pisa ve Amalfi mahalleleri", "dogu_m": 120.0, "kuzey_m": 690.0, "gercek_olcu": Vector3(100.0, 16.0, 60.0), "yon_derece": 60.0, "durum": "saglam", "tur": "ev"},
		{"id": "halic_ceneviz", "ad": "Ceneviz'in eski mahallesi (terk edilmiş)", "dogu_m": 260.0, "kuzey_m": 680.0, "gercek_olcu": Vector3(70.0, 12.0, 50.0), "yon_derece": 60.0, "durum": "harap", "tur": "ev"},
		{"id": "halic_yahudi", "ad": "Yahudi iskelesi ve Vigla debbağ mahallesi", "dogu_m": -280.0, "kuzey_m": 730.0, "gercek_olcu": Vector3(70.0, 9.0, 40.0), "yon_derece": 60.0, "durum": "saglam", "tur": "ev"},
		{"id": "halic_neorion", "ad": "Neorion limanı (kısmen kumlanmış)", "dogu_m": 190.0, "kuzey_m": 650.0, "gercek_olcu": Vector3(80.0, 6.0, 60.0), "yon_derece": 60.0, "durum": "harap", "tur": "liman"},
		{"id": "halic_iskele", "ad": "Ticaret iskeleleri, vinçler ve demirli gemi", "dogu_m": 0.0, "kuzey_m": 680.0, "gercek_olcu": Vector3(110.0, 22.0, 60.0), "yon_derece": 60.0, "durum": "saglam", "tur": "liman", "bakis": Vector3(0, 28, 0), "bakis_r": 45.0},
		{"id": "halic_balik", "ad": "Balık pazarı", "dogu_m": -200.0, "kuzey_m": 740.0, "gercek_olcu": Vector3(40.0, 6.0, 30.0), "yon_derece": 60.0, "durum": "saglam", "tur": "ayrinti"},
		{"id": "halic_petrion", "ad": "Petrion kapısı (Haliç yakası)", "dogu_m": -520.0, "kuzey_m": 800.0, "gercek_olcu": Vector3(14.0, 14.0, 12.0), "yon_derece": 60.0, "durum": "saglam", "tur": "kapi", "bakis": Vector3(0, 20, 0), "bakis_r": 30.0, "gorev": true},
		{"id": "halic_fener", "ad": "Fener (Phanarion) kapısı", "dogu_m": -440.0, "kuzey_m": 790.0, "gercek_olcu": Vector3(14.0, 14.0, 12.0), "yon_derece": 60.0, "durum": "saglam", "tur": "kapi", "bakis": Vector3(0, 20, 0), "bakis_r": 30.0},
	]


static func build(id: String, host: Node3D, k: float, lod: int) -> void:
	IstHalicKit.lod = lod
	var before := host.get_child_count()
	_build_inner(id, host, k, lod)
	IstHalicKit.lod = 0
	if lod == 1:
		for i in range(before, host.get_child_count()):
			_strip_lod1(host.get_child(i))


## lod 1: yalnız ana kütleler ve çatılar kalır; küçük ayrıntı, MultiMesh, alev, yazı ve çarpışma atılır.
static func _strip_lod1(n: Node) -> void:
	var kill: Array = []
	for c in n.find_children("*", "", true, false):
		if c is CollisionShape3D or c is MultiMeshInstance3D or c is Label3D:
			kill.append(c)
		elif c.has_meta("flame"):
			kill.append(c)
		elif c is MeshInstance3D:
			var mi := c as MeshInstance3D
			var sz := mi.mesh.get_aabb().size * mi.scale if mi.mesh != null else Vector3.ZERO
			if mi.name != "Tile" and maxf(sz.x, maxf(sz.y, sz.z)) < 2.6:
				kill.append(c)
	for c in kill:
		if is_instance_valid(c) and c.get_parent() != null:
			c.get_parent().remove_child(c)
			c.free()


static func _build_inner(id: String, host: Node3D, k: float, lod: int) -> void:
	match id:
		"sur": IstHalicSur.build(host, k, lod)
		"eugenios": IstHalicZincir.build(host, k, lod)
		"venedik": IstHalicMahalle.build_venedik(host, k, lod)
		"pisa_amalfi": IstHalicMahalle.build_pisa_amalfi(host, k, lod)
		"ceneviz": IstHalicMahalle.build_ceneviz(host, k, lod)
		"yahudi": IstHalicMahalle.build_yahudi(host, k, lod)
		"neorion": IstHalicLiman.build_neorion(host, k, lod)
		"iskele": IstHalicLiman.build_iskele(host, k, lod)
		"balik": IstHalicLiman.build_balik(host, k, lod)
		"petrion": IstHalicKapi.build(host, k, lod, "petrion")
		"fener": IstHalicKapi.build(host, k, lod, "fener")


static func perches(id: String, k: float) -> Array:
	match id:
		"sur": return IstHalicSur.perches(k)
		"eugenios": return IstHalicZincir.perches(k)
		"venedik": return IstHalicMahalle.perches_venedik(k)
		"pisa_amalfi": return IstHalicMahalle.perches_pisa_amalfi(k)
		"ceneviz": return IstHalicMahalle.perches_ceneviz(k)
		"yahudi": return IstHalicMahalle.perches_yahudi(k)
		"neorion": return IstHalicLiman.perches_neorion(k)
		"iskele": return IstHalicLiman.perches_iskele(k)
		"balik": return IstHalicLiman.perches_balik(k)
		"petrion", "fener": return IstHalicKapi.perches(k)
	return []


static func climbs(id: String, k: float) -> Array:
	match id:
		"sur": return IstHalicSur.climbs(k)
		"eugenios": return IstHalicZincir.climbs(k)
		"venedik": return IstHalicMahalle.climbs_venedik(k)
		"pisa_amalfi": return IstHalicMahalle.climbs_pisa_amalfi(k)
		"ceneviz": return IstHalicMahalle.climbs_ceneviz(k)
		"yahudi": return IstHalicMahalle.climbs_yahudi(k)
		"neorion": return IstHalicLiman.climbs_neorion(k)
		"iskele": return IstHalicLiman.climbs_iskele(k)
		"balik": return IstHalicLiman.climbs_balik(k)
		"petrion", "fener": return IstHalicKapi.climbs(k)
	return []


# ---- Dondurulmuş arayüz: her öğe için ayrı statik işlevler ----
static func build_halic_sur(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("sur", host, k, lod)
static func perches_halic_sur(k: float = 0.5) -> Array: return perches("sur", k)
static func climbs_halic_sur(k: float = 0.5) -> Array: return climbs("sur", k)
static func build_halic_eugenios(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("eugenios", host, k, lod)
static func perches_halic_eugenios(k: float = 0.5) -> Array: return perches("eugenios", k)
static func climbs_halic_eugenios(k: float = 0.5) -> Array: return climbs("eugenios", k)
static func build_halic_venedik(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("venedik", host, k, lod)
static func perches_halic_venedik(k: float = 0.5) -> Array: return perches("venedik", k)
static func climbs_halic_venedik(k: float = 0.5) -> Array: return climbs("venedik", k)
static func build_halic_pisa_amalfi(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("pisa_amalfi", host, k, lod)
static func perches_halic_pisa_amalfi(k: float = 0.5) -> Array: return perches("pisa_amalfi", k)
static func climbs_halic_pisa_amalfi(k: float = 0.5) -> Array: return climbs("pisa_amalfi", k)
static func build_halic_ceneviz(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("ceneviz", host, k, lod)
static func perches_halic_ceneviz(k: float = 0.5) -> Array: return perches("ceneviz", k)
static func climbs_halic_ceneviz(k: float = 0.5) -> Array: return climbs("ceneviz", k)
static func build_halic_yahudi(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("yahudi", host, k, lod)
static func perches_halic_yahudi(k: float = 0.5) -> Array: return perches("yahudi", k)
static func climbs_halic_yahudi(k: float = 0.5) -> Array: return climbs("yahudi", k)
static func build_halic_neorion(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("neorion", host, k, lod)
static func perches_halic_neorion(k: float = 0.5) -> Array: return perches("neorion", k)
static func climbs_halic_neorion(k: float = 0.5) -> Array: return climbs("neorion", k)
static func build_halic_iskele(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("iskele", host, k, lod)
static func perches_halic_iskele(k: float = 0.5) -> Array: return perches("iskele", k)
static func climbs_halic_iskele(k: float = 0.5) -> Array: return climbs("iskele", k)
static func build_halic_balik(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("balik", host, k, lod)
static func perches_halic_balik(k: float = 0.5) -> Array: return perches("balik", k)
static func climbs_halic_balik(k: float = 0.5) -> Array: return climbs("balik", k)
static func build_halic_petrion(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("petrion", host, k, lod)
static func perches_halic_petrion(k: float = 0.5) -> Array: return perches("petrion", k)
static func climbs_halic_petrion(k: float = 0.5) -> Array: return climbs("petrion", k)
static func build_halic_fener(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("fener", host, k, lod)
static func perches_halic_fener(k: float = 0.5) -> Array: return perches("fener", k)
static func climbs_halic_fener(k: float = 0.5) -> Array: return climbs("fener", k)
