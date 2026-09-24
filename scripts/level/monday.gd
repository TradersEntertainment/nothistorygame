class_name Monday
extends Node3D
## Bölüm 15: pazartesi sabahı. İki mekân:
##   Durak (x≈0): kaldırım, servis durağı, reklam panosu, dükkân tabelaları. Tabelalar dünya
##   sonucuna göre değişir (Leblebipolis, tavuk logolu sigorta, "düzeltildi" ama bir iz).
##   Ofis (x≈200): açık ofis, masalar, toplantı masası, beyaz tahta, müdür ve iş arkadaşları.

const STOP := Vector3(0.0, 0.0, 0.0)
const OFFICE := Vector3(200.0, 0.0, 0.0)
const TOLGA_DESK := Vector3(203.0, 0.0, -2.0)

var world := "W1"
var fixed := false
var manager: Person
var colleagues: Array = []
var bus: Node3D
var stop_sign: Label3D
var board: Label3D
var headline: Label3D


func _init(p_world := "W1", p_fixed := false) -> void:
	world = p_world
	fixed = p_fixed


func _ready() -> void:
	_build_env()
	_build_city()
	_build_stop()
	_build_office()


func _build_env() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("6a9ad0")
	sm.sky_horizon_color = Color("d8e0e4")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("8a94a4")
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.85
	e.fog_enabled = true
	e.fog_light_color = Color("d0d8e0")
	e.fog_density = 0.006
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 40, 0)
	sun.light_color = Color("fff0dc")
	sun.light_energy = 0.9
	sun.shadow_enabled = true
	add_child(sun)


## 2026 İstanbul'u: caddenin iki yanı bina dolu, arkada yüksek bloklar, ufukta köprü, kule ve kubbeler.
func _build_city() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var cols := [Color("a8745a"), Color("6f8496"), Color("c09a64"), Color("8a6a5e"), Color("b8a890"), Color("7a8a7a"), Color("c8b8a0")]
	var bx: Array = []
	var bc: Array = []
	# Caddenin iki yanı (durağın arkasındaki altı bina hariç), ikinci ve üçüncü sıra
	for row in [[-9.0, 6.0, 9.0, 16.0], [15.0, 6.0, 8.0, 14.0], [-24.0, 12.0, 16.0, 40.0], [30.0, 12.0, 14.0, 36.0], [-48.0, 20.0, 24.0, 70.0], [52.0, 20.0, 24.0, 60.0]]:
		var z: float = row[0]
		var x := -160.0
		while x < 160.0:
			var w := rng.randf_range(8.0, 14.0)
			if not (absf(z + 9.0) < 0.1 and x > -28.0 and x < 32.0):
				var h := rng.randf_range(row[2], row[3])
				bx.append(Scenery._t(Vector3(x + w * 0.5, 0, z), Vector3.ZERO, Vector3(w - 0.4, h, row[1])))
				bc.append(cols[rng.randi() % cols.size()])
			x += w
	Scenery.scatter(self, Scenery.merged([[Scenery._boxm(Vector3.ONE), Scenery._t(Vector3(0, 0.5, 0)), Color.WHITE]]), bx, bc)
	# Pencere şeritleri (yakındaki iki sıraya)
	var wx: Array = []
	for i in bx.size():
		var xf: Transform3D = bx[i]
		var sc := xf.basis.get_scale()
		if absf(xf.origin.z) > 20.0:
			continue
		var floors := int(sc.y / 3.0)
		var face := 1.0 if xf.origin.z < 0.0 else -1.0
		for f in floors:
			wx.append(Scenery._t(xf.origin + Vector3(0, 1.8 + f * 3.0, face * (sc.z * 0.5 + 0.03)), Vector3.ZERO, Vector3(sc.x * 0.8, 1.1, 0.05)))
	Scenery.scatter(self, Scenery.merged([[Scenery._boxm(Vector3.ONE), Scenery._t(Vector3.ZERO), Color("3a4a5a")]]), wx, [])
	# Karşı kaldırım, ağaçlar, sokak lambaları, park etmiş arabalar, yayalar
	Props.box(self, Vector3(320, 0.15, 4.0), Vector3(0, 0.07, 9.0), Color("9a968c"))
	Props.box(self, Vector3(320, 0.2, 60), Vector3(0, -0.12, 0), Color("4a4c52"))
	var tr: Array = []
	var lamps: Array = []
	var cars: Array = []
	var carc: Array = []
	var ppl: Array = []
	var pplc: Array = []
	var x2 := -150.0
	while x2 < 150.0:
		for z in [-4.6, 9.6]:
			if absf(x2) > 12.0 or z > 0.0:
				tr.append(Scenery._t(Vector3(x2, 0, z), Vector3(0, rng.randf() * TAU, 0), Vector3.ONE * rng.randf_range(0.7, 1.0)))
			lamps.append(Scenery._t(Vector3(x2 + 6.0, 0, z)))
		var cz := 7.2 if (rng.randf() < 0.5 or absf(x2) < 24.0) else -1.6
		if rng.randf() < 0.7:
			cars.append(Scenery._t(Vector3(x2 + 3.0, 0, cz), Vector3(0, PI / 2.0, 0)))
			carc.append([Color("c83a3a"), Color("e8e8e8"), Color("2a2a30"), Color("3a5a8a"), Color("c8b040")][rng.randi() % 5])
		for k in rng.randi_range(0, 2):
			ppl.append(Scenery._t(Vector3(x2 + rng.randf_range(0, 10), 0, rng.randf_range(8.0, 10.6) if rng.randf() < 0.6 else rng.randf_range(-4.8, -3.0)), Vector3(0, rng.randf() * TAU, 0)))
			pplc.append([Color("3a3a42"), Color("5a7a9a"), Color("9a5a6a"), Color("c8a060"), Color("2a4a3a")][rng.randi() % 5])
		x2 += 12.0
	Scenery.scatter(self, Scenery.plane_tree_mesh(), tr, [])
	Scenery.scatter(self, Scenery.merged([[Scenery._cyl(0.06, 5.0, -1.0, 5), Scenery._t(Vector3(0, 2.5, 0)), Color("4a4e56")],
		[Scenery._boxm(Vector3(0.9, 0.12, 0.3)), Scenery._t(Vector3(0.4, 5.0, 0)), Color("4a4e56")]]), lamps, [])
	Scenery.scatter(self, Scenery.merged([[Scenery._boxm(Vector3(1.8, 0.7, 4.2)), Scenery._t(Vector3(0, 0.6, 0)), Color.WHITE],
		[Scenery._boxm(Vector3(1.6, 0.6, 2.2)), Scenery._t(Vector3(0, 1.2, -0.2)), Color(0.6, 0.7, 0.8)],
		[Scenery._cyl(0.33, 0.25, -1.0, 8), Scenery._t(Vector3(0.9, 0.33, 1.3), Vector3(0, 0, PI / 2.0)), Color("1a1a1e")],
		[Scenery._cyl(0.33, 0.25, -1.0, 8), Scenery._t(Vector3(-0.9, 0.33, 1.3), Vector3(0, 0, PI / 2.0)), Color("1a1a1e")],
		[Scenery._cyl(0.33, 0.25, -1.0, 8), Scenery._t(Vector3(0.9, 0.33, -1.3), Vector3(0, 0, PI / 2.0)), Color("1a1a1e")],
		[Scenery._cyl(0.33, 0.25, -1.0, 8), Scenery._t(Vector3(-0.9, 0.33, -1.3), Vector3(0, 0, PI / 2.0)), Color("1a1a1e")]]), cars, carc)
	Scenery.scatter(self, Scenery.merged([[Scenery._cyl(0.22, 1.1, 0.18, 6), Scenery._t(Vector3(0, 0.95, 0)), Color.WHITE],
		[Scenery._ball(0.14), Scenery._t(Vector3(0, 1.65, 0)), Color("e0b08a")],
		[Scenery._cyl(0.08, 0.7, -1.0, 4), Scenery._t(Vector3(-0.08, 0.35, 0)), Color("2a2a30")],
		[Scenery._cyl(0.08, 0.7, -1.0, 4), Scenery._t(Vector3(0.08, 0.35, 0)), Color("2a2a30")]]), ppl, pplc)
	# Ufuk: tepeler, köprü, Galata Kulesi, cami kubbeleri ve minareler
	Scenery.hills(self, Vector3(0, 0, 0), 260.0, 26, Color("7a8a6a"), 9)
	var br := Vector3(-120.0, 0, -210.0)
	for t in [-70.0, 70.0]:
		Props.box(self, Vector3(4, 60, 4), br + Vector3(t, 30, 0), Color("c8c8cc"))
	Props.box(self, Vector3(260, 2.5, 6), br + Vector3(0, 30, 0), Color("b8b8c0"))
	for k in 12:
		Props.cyl(self, 0.2, 30.0, br + Vector3(-60 + k * 11.0, 45 - absf(k - 5.5) * 3.0, 0), Color("a8a8b0"), Vector3.ZERO, 4)
	var tw := Vector3(90.0, 0, -180.0)
	Props.cyl(self, 5.0, 40.0, tw + Vector3(0, 20, 0), Color("c8b8a0"), Vector3.ZERO, 12)
	Props.cyl(self, 5.4, 9.0, tw + Vector3(0, 44.5, 0), Color("6a7480"), Vector3.ZERO, 12, 0.2)
	for m in [Vector3(20.0, 22.0, -230.0), Vector3(-30.0, 20.0, 230.0), Vector3(150.0, 18.0, 210.0)]:
		Props.box(self, Vector3(34, 18, 34), m + Vector3(0, -9, 0), Color("d8ccb8"))
		Props.ball(self, 14.0, m + Vector3(0, 4, 0), Color("8a98a8"), Vector3(1, 0.6, 1), 14)
		for s in [-1, 1]:
			for q in [-1, 1]:
				Props.cyl(self, 1.2, 40.0, m + Vector3(s * 20.0, 6.0, q * 20.0), Color("e8e0d0"), Vector3.ZERO, 8)
				Props.cyl(self, 1.3, 5.0, m + Vector3(s * 20.0, 28.5, q * 20.0), Color("8a98a8"), Vector3.ZERO, 8, 0.05)


## Tabelalar: dünya sonucuna göre.
## Dünyanın gazete ön sayfası (assets/art/newspapers/wN[_en].png); yoksa null (Label3D manşete düşülür).
func news_texture() -> Texture2D:
	var w := "W1" if fixed else world
	var base := "res://assets/art/newspapers/" + w.to_lower()
	var path := base + ("_en.png" if TranslationServer.get_locale().begins_with("en") else ".png")
	if not ResourceLoader.exists(path):
		path = base + ".png"
	return load(path) if ResourceLoader.exists(path) else null


func _texts() -> Dictionary:
	var t := {"stop": "EMİNÖNÜ", "board": "GELECEĞİNİZİ GÜVENCEYE ALIN · Karınca Sigorta", "shop": "BÜFE · Simit, Çay", "logo": "",
		"news": "HAFTAYA YAĞMUR BEKLENİYOR"}
	var w := world
	if fixed:
		w = "W1"
	match w:
		"W2":
			t = {"stop": "LEBLEBİPOLİS · MERKEZ", "board": "LEBLEBİPOLİS BELEDİYESİ · Çıtır Bir Şehir", "shop": "BÜFE · Leblebi, Leblebi, Leblebi", "logo": "",
				"news": "LEBLEBİPOLİS'TE LEBLEBİ FİYATLARI ZİRVEDE"}
		"W3":
			t["board"] = "TAVUK SİGORTA · Kuruluş: Galata, 1453"
			t["logo"] = "chicken"
			t["news"] = "TAVUK SİGORTA HALKA ARZ OLUYOR"
		"W4":
			t["board"] = "ZAMAN TAMİR · 'Benden iyi tamir etmiş.'"
			t["news"] = "FATİH'İN ZAMAN MAKİNESİ ÇİZİMLERİ SERGİDE"
		"W5":
			t["stop"] = "GALATA"
			t["board"] = "GALATA ŞARAPÇILIK · Gülle geçirmez fıçılar · 1453'ten beri"
			t["news"] = "GALATA'DA 573 YILLIK ŞARAP DAVASI SONUÇLANDI"
		"W5B":
			t["board"] = "ASKERÎ MÜZE · Urban'ın Büyük Topu (parçaları) · Olay yerinde bir fes bulunmuştur"
			t["news"] = "URBAN'IN TOPU MÜZEDE: OLAY YERİNDEN BİR FES"
		"W13":
			t["board"] = "YENİKAPI KAZISI · Marmaray · Ziyaretçi girişi"
			t["news"] = "MARMARAY KAZISINDA 573 YILLIK İKİ TÜNEL: ORTADA BİR PİKNİK ALANI"
		"W8":
			t["board"] = "BİZANS ARŞİVİ SERGİSİ · Renk kodlu 1453 dosyaları"
			t["news"] = "ARŞİVDE 573 YILLIK RENK KODLU DOSYA SİSTEMİ BULUNDU"
		"W6":
			t["board"] = "VENEDİK TURLARI · Calle del Turco col Capello Rosso'yu görün"
			t["news"] = "VENEDİK'TE 'KIRMIZI ŞAPKALI TÜRK SOKAĞI' 573 YAŞINDA"
		"W7":
			t["shop"] = "ESNAF LOKANTASI · Kadri Usulü Leblebili Pilav"
			t["board"] = "MATBAH-I ÂMİRE · 1453'ten beri aynı tarif"
			t["news"] = "SARAY MUTFAĞININ KAYIP TARİFİ BULUNDU: LEBLEBİLİ PİLAV"
		"W10":
			t["board"] = "FETİH 1454 · 572. YIL KUTLAMALARI"
			t["shop"] = "1454 SİMİT SARAYI"
			t["news"] = "İSTANBUL'UN FETHİ'NİN 572. YILI · 29 MAYIS 1454"
		"W11":
			t["board"] = "UZUN BEKLEYİŞ SERGİSİ · 1454–1455"
			t["news"] = "UZUN BEKLEYİŞ'İN 571. YILI ANILDI"
		"W12":
			t["board"] = "FETİH 570 YAŞINDA · Evrakı tamamdır"
			t["news"] = "FORM Z-1453'ÜN ASLI İLK KEZ SERGİLENDİ"
	return t


func _build_stop() -> void:
	var s := STOP
	Props.solid(self, Vector3(60, 0.2, 30), s + Vector3(0, -0.1, 0), Color("4a4c52"))
	Props.box(self, Vector3(60, 0.15, 4.0), s + Vector3(0, 0.07, -3.0), Color("9a968c"))
	for i in 10:
		Props.box(self, Vector3(1.8, 0.01, 0.15), s + Vector3(-27.0 + i * 6.0, 0.005, 3.0), Color("e8e4d8"))
	# Arkadaki binalar
	var cols := [Color("a8745a"), Color("6f8496"), Color("c09a64"), Color("8a6a5e")]
	for i in 6:
		var h := 9.0 + (i % 3) * 3.0
		Props.box(self, Vector3(8.5, h, 6.0), s + Vector3(-22.0 + i * 9.0, h / 2.0, -9.0), cols[i % 4])
		for k in 6:
			Props.box(self, Vector3(1.0, 1.2, 0.05), s + Vector3(-24.5 + i * 9.0 + (k % 3) * 2.5, 2.5 + (k / 3) * 3.0, -5.97), Color("3a4a5a"))
	# Durak: sundurma, bank, tabela
	var st := s + Vector3(-2.0, 0, -2.4)
	for sx in [-1.4, 1.4]:
		Props.cyl(self, 0.05, 2.5, st + Vector3(sx, 1.25, -0.4), Color("5a6068"), Vector3.ZERO, 6)
	Props.box(self, Vector3(3.2, 0.08, 1.4), st + Vector3(0, 2.5, 0), Color("3a5a8a"))
	var glass := Props.box(self, Vector3(3.0, 2.0, 0.04), st + Vector3(0, 1.3, -0.7), Color("9fc4e0"))
	glass.material_override = Props.mat(Color(0.6, 0.8, 0.95, 0.25), 0.0, true, "", false)
	Props.box(self, Vector3(2.4, 0.08, 0.5), st + Vector3(0, 0.5, -0.4), Color("6a4a30"))
	var tx := _texts()
	Props.cyl(self, 0.05, 3.0, st + Vector3(2.2, 1.5, 0.2), Color("5a6068"), Vector3.ZERO, 6)
	Props.box(self, Vector3(1.8, 0.5, 0.05), st + Vector3(2.2, 2.9, 0.2), Color("f4d040"))
	stop_sign = Props.label(self, tx["stop"], st + Vector3(2.2, 2.9, 0.23), 30, Color("1d2330"), Vector3.ZERO, 1.6)
	# Reklam panosu
	var bp := s + Vector3(6.5, 0, -4.2)
	for sx in [-1.8, 1.8]:
		Props.cyl(self, 0.08, 3.0, bp + Vector3(sx, 1.5, 0), Color("5a6068"), Vector3.ZERO, 6)
	Props.box(self, Vector3(4.6, 2.2, 0.1), bp + Vector3(0, 3.8, 0), Color("f4f1ea"))
	board = Props.label(self, (tx["board"] as String).replace(" · ", "\n"), bp + Vector3(0, 3.8, 0.06), 40, Color("b3262d"), Vector3.ZERO, 4.2)
	if tx["logo"] == "chicken":
		var c := Chicken.new()
		c.position = bp + Vector3(-1.6, 4.2, 0.2)
		c.scale = Vector3(1.6, 1.6, 1.6)
		add_child(c)
	# Büfe
	var kp := s + Vector3(-9.0, 0, -4.0)
	Props.solid(self, Vector3(3.0, 2.6, 2.0), kp + Vector3(0, 1.3, 0), Color("c8323a"))
	Props.box(self, Vector3(3.2, 0.5, 0.1), kp + Vector3(0, 2.9, 1.05), Color("f4f1ea"))
	Props.label(self, tx["shop"], kp + Vector3(0, 2.9, 1.11), 26, Color("1d2330"), Vector3.ZERO, 3.0)
	# W8: durakta fötr şapkalı, takım elbiseli bir adam (Büro'dan). Tolga selamı kendine sanmaz.
	if world == "W8" and not fixed:
		var agent := Person.new({"coat": Color("3a3a42"), "pants": Color("3a3a42"), "hat": "fedora", "mustache": true, "skin": Color("e0b08a")})
		agent.position = s + Vector3(-3.6, 0, -2.2)
		add_child(agent)
	# Gazete standı: manşet dünyaya göre (EXPANSION §2.4)
	var np := s + Vector3(-6.2, 0, -3.6)
	Props.solid(self, Vector3(1.6, 1.1, 0.7), np + Vector3(0, 0.55, 0), Color("2f5fa8"))
	Props.box(self, Vector3(1.7, 0.08, 0.9), np + Vector3(0, 1.9, 0.1), Color("2f5fa8"))
	for sx in [-0.78, 0.78]:
		Props.cyl(self, 0.03, 0.8, np + Vector3(sx, 1.5, 0.45), Color("5a6068"), Vector3.ZERO, 4)
	var paper := news_texture()
	if paper != null:
		# Kimi'nin gazete ön sayfası standa asılı
		var page := Sprite3D.new()
		page.texture = paper
		page.pixel_size = 0.85 / float(paper.get_height())
		page.shaded = false
		page.position = np + Vector3(0, 1.45, 0.38)
		page.rotation_degrees = Vector3(-12, 0, 0)
		add_child(page)
	else:
		Props.box(self, Vector3(1.1, 0.7, 0.03), np + Vector3(0, 1.45, 0.37), Color("f4f1ea"), Vector3(-12, 0, 0))
		Props.label(self, "GÜNDEM", np + Vector3(0, 1.72, 0.4), 22, Color("1d2330"), Vector3(-12, 0, 0), 0.9)
		headline = Props.label(self, tx["news"], np + Vector3(0, 1.42, 0.41), 16, Color("b3262d"), Vector3(-12, 0, 0), 1.0)
		headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		headline.width = 250.0
	# "Düzeltildi ama..." dünyası: tek bir iz kalır
	if fixed and world in ["W2", "W3", "W4", "W5", "W5B", "W6", "W7", "W13"]:
		var trace: String = {"W2": "LEBLEBİPOLİS ← 3 km", "W3": "Tavuk Sigorta · Şube", "W4": "Fatih Tamir Atölyesi · 1453'ten beri",
			"W5": "Galata Şarapçılık · Şube", "W5B": "Askerî Müze ← 800 m", "W7": "Leblebili Pilav · Günün Menüsü", "W6": "Venedik ✈ Kırmızı Şapkalı Türk Sokağı", "W13": "Kazı Alanı · Tünel Turu"}.get(world, "")
		Props.cyl(self, 0.04, 2.2, s + Vector3(-5.0, 1.1, -1.6), Color("5a6068"), Vector3.ZERO, 5)
		Props.box(self, Vector3(1.6, 0.35, 0.04), s + Vector3(-5.0, 2.1, -1.6), Color("2a6a3a"))
		Props.label(self, trace, s + Vector3(-5.0, 2.1, -1.57), 22, Color("f4f1ea"), Vector3.ZERO, 1.5)
	# Servis
	bus = Node3D.new()
	bus.position = s + Vector3(-30.0, 0, 1.2)
	add_child(bus)
	Props.box(bus, Vector3(8.0, 2.8, 2.4), Vector3(0, 1.6, 0), Color("e8e0cc"))
	Props.box(bus, Vector3(8.02, 0.5, 2.42), Vector3(0, 1.0, 0), Color("2f5fa8"))
	for k in 5:
		Props.box(bus, Vector3(1.2, 0.9, 2.44), Vector3(-3.0 + k * 1.5, 2.2, 0), Color("2a3a4a"))
	for wx in [-2.8, 2.8]:
		Props.cyl(bus, 0.45, 2.5, Vector3(wx, 0.45, 0), Color("15171c"), Vector3(90, 0, 0), 10)
	Props.label(bus, "SERVİS 14:53", Vector3(4.02, 2.4, 0), 36, Color("ffd060"), Vector3(0, 90, 0), 2.0)


func _build_office() -> void:
	var o := OFFICE
	Props.solid(self, Vector3(20, 0.2, 16), o + Vector3(0, -0.1, 0), Color("8a8a90"))
	Props.box(self, Vector3(20, 0.2, 16), o + Vector3(0, 3.3, 0), Color("e8e8e4"))
	for w in [[Vector3(0, 1.6, -8), Vector3(20, 3.2, 0.2)], [Vector3(-10, 1.6, 0), Vector3(0.2, 3.2, 16)], [Vector3(10, 1.6, 0), Vector3(0.2, 3.2, 16)], [Vector3(0, 1.6, 8), Vector3(20, 3.2, 0.2)]]:
		Props.solid(self, w[1], o + w[0], Color("dcdcd4"))
	# Pencere şeridi
	Props.box(self, Vector3(18, 1.4, 0.05), o + Vector3(0, 1.9, -7.88), Color("a8c8e0"), Vector3.ZERO, 0.5)
	for x in [-6.0, -2.0, 2.0, 6.0]:
		var l := Props.box(self, Vector3(1.6, 0.05, 0.3), o + Vector3(x, 3.18, 0), Color("f4f8ff"))
		l.material_override = Props.mat(Color("f4f8ff"), 0.8, false, "", false)
	var ol := OmniLight3D.new()
	ol.position = o + Vector3(0, 2.8, 0)
	ol.light_energy = 0.6
	ol.omni_range = 14.0
	add_child(ol)
	# Masalar ve ekranlar
	for i in 6:
		var dp := o + Vector3(-6.0 + (i % 3) * 4.5, 0, -2.0 + (i / 3) * 4.0)
		Props.solid(self, Vector3(1.6, 0.75, 0.8), dp + Vector3(0, 0.375, 0), Color("c8b898"))
		Props.box(self, Vector3(0.7, 0.45, 0.05), dp + Vector3(0, 1.0, -0.2), Color("1d2330"))
		Props.box(self, Vector3(0.64, 0.38, 0.02), dp + Vector3(0, 1.0, -0.17), Color("5a8ab0"), Vector3.ZERO, 0.6)
	# Tolga'nın masası: kupa, kalemlik, bir kaftan sandalyenin arkasında (W1: dolapta)
	Props.cyl(self, 0.05, 0.1, TOLGA_DESK + Vector3(0.5, 0.8, 0.1), Color("f4f1ea"), Vector3.ZERO, 8)
	Props.label(self, "DÜNYANIN EN İYİ SİGORTACISI", TOLGA_DESK + Vector3(0.5, 0.8, 0.16), 8, Color("b3262d"), Vector3.ZERO, 0.1)
	# Toplantı köşesi: masa, beyaz tahta
	var m := o + Vector3(5.5, 0, 4.5)
	Props.solid(self, Vector3(3.0, 0.75, 1.4), m + Vector3(0, 0.375, 0), Color("6a4a30"))
	Props.box(self, Vector3(3.2, 1.6, 0.05), o + Vector3(5.5, 1.7, 7.85), Color("f4f4f0"))
	Props.label(self, "PAZARTESİ TOPLANTISI · Q2 RİSK", o + Vector3(5.5, 2.2, 7.8), 26, Color("2a4a8a"), Vector3(0, 180, 0), 2.8)
	manager = Person.new({"coat": Color("3a3a42"), "pants": Color("2a2a30"), "glasses": true, "hair": Color("6a6a6a"), "mustache": true, "skin": Color("e0b08a")})
	manager.position = m + Vector3(0, 0, 1.4)
	manager.rotation.y = PI
	add_child(manager)
	for k in 2:
		var p := Person.new({"coat": [Color("5a7a9a"), Color("9a5a6a")][k], "pants": Color("2a2a30"), "skirt": k == 1, "hair": Color("3a2a1e"), "skin": Color("e8b894")})
		p.position = m + Vector3(-1.0 + k * 2.0, 0, -1.2)
		add_child(p)
		colleagues.append(p)
