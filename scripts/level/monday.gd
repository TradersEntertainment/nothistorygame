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


func _init(p_world := "W1", p_fixed := false) -> void:
	world = p_world
	fixed = p_fixed


func _ready() -> void:
	_build_env()
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


## Tabelalar: dünya sonucuna göre.
func _texts() -> Dictionary:
	var t := {"stop": "EMİNÖNÜ", "board": "GELECEĞİNİZİ GÜVENCEYE ALIN · Karınca Sigorta", "shop": "BÜFE · Simit, Çay", "logo": ""}
	var w := world
	if fixed:
		w = "W1"
	match w:
		"W2":
			t = {"stop": "LEBLEBİPOLİS · MERKEZ", "board": "LEBLEBİPOLİS BELEDİYESİ · Çıtır Bir Şehir", "shop": "BÜFE · Leblebi, Leblebi, Leblebi", "logo": ""}
		"W3":
			t["board"] = "TAVUK SİGORTA · Kuruluş: Galata, 1453"
			t["logo"] = "chicken"
		"W4":
			t["board"] = "ZAMAN TAMİR · 'Benden iyi tamir etmiş.'"
		"W5":
			t["stop"] = "GALATA"
			t["board"] = "GALATA ŞARAPÇILIK · Gülle geçirmez fıçılar · 1453'ten beri"
		"W5B":
			t["board"] = "ASKERÎ MÜZE · Urban'ın Büyük Topu (parçaları) · Olay yerinde bir fes bulunmuştur"
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
	# "Düzeltildi ama..." dünyası: tek bir iz kalır
	if fixed and world in ["W2", "W3", "W4", "W5", "W5B"]:
		var trace: String = {"W2": "LEBLEBİPOLİS ← 3 km", "W3": "Tavuk Sigorta · Şube", "W4": "Fatih Tamir Atölyesi · 1453'ten beri",
			"W5": "Galata Şarapçılık · Şube", "W5B": "Askerî Müze ← 800 m"}.get(world, "")
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
