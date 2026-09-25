class_name OtagHall
extends Node3D
## Bölüm 12: Padişah'ın otağının içi. Yuvarlak, kırmızı-altın çadır; halılar, fenerler, orta direk,
## arka tarafta minderli taht, solda katip masası, iki yanda muhafızlar. Giriş +Z tarafında.

const RADIUS := 9.0
const THRONE := Vector3(0.0, 0.0, -6.2)
const ENTRY := Vector3(0.0, 0.0, 7.8)
const TOLGA_SPOT := Vector3(0.0, 0.0, -0.6)
const HIKMET_SPOT := Vector3(-1.5, 0.0, 0.3)
const NIHAT_SPOT := Vector3(1.5, 0.0, 0.3)
const LUTFI_SPOT := Vector3(2.8, 0.0, 1.8)

var fatih: Person
var scribe: Person
var guards: Array = []
var lights: Array = []
var _t := 0.0


func _ready() -> void:
	_build_env()
	_build_tent()
	_build_floor()
	_build_throne()
	_build_people()


func _process(delta: float) -> void:
	_t += delta
	Night.flicker(lights, _t)


func _build_env() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("1a0c08")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("a0603a")
	e.ambient_light_energy = 0.45
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.6
	env.environment = e
	add_child(env)
	# Tepeden süzülen gün ışığı (çadırın tepe açıklığı)
	var sun := SpotLight3D.new()
	sun.position = Vector3(0, 9.5, 0)
	sun.rotation_degrees = Vector3(-90, 0, 0)
	sun.spot_angle = 35.0
	sun.spot_range = 14.0
	sun.light_energy = 3.0
	sun.light_color = Color("ffe8c0")
	add_child(sun)


func _inside_mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


func _build_tent() -> void:
	var n := 24
	var red := _inside_mat(Color("a82830"))
	var red2 := _inside_mat(Color("8a2026"))
	var gold := _inside_mat(Color("d8b040"))
	for i in n:
		var a := TAU * (i + 0.5) / n
		var p := Vector3(sin(a) * RADIUS, 0, cos(a) * RADIUS)
		var w := TAU * RADIUS / n + 0.05
		# Giriş aralığı (+Z)
		if absf(a - TAU) < 0.2 or a < 0.2:
			continue
		var panel := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(w, 5.0, 0.1)
		panel.mesh = bm
		panel.position = p + Vector3(0, 2.5, 0)
		panel.rotation.y = a
		panel.material_override = red if i % 2 == 0 else red2
		add_child(panel)
		for y in [0.4, 4.3]:
			var band := MeshInstance3D.new()
			var bb := BoxMesh.new()
			bb.size = Vector3(w, 0.3, 0.12)
			band.mesh = bb
			band.position = p * 0.995 + Vector3(0, y, 0)
			band.rotation.y = a
			band.material_override = gold
			add_child(band)
		# Otağ içi aplike işleme: her panoda krem çerçeveli sivri kemer (mihrabiye), içinde lacivert zemin ve altın
		# çintemani/lale motifi; Topkapı'daki otağ ve çadırların iç yüzü gibi
		var rd := rad_to_deg(a)
		var ip := p * 0.975
		var cream := Color("f0e2c0")
		var navy := Color("223066") if i % 2 == 0 else Color("1e5a4a")
		Props.box(self, Vector3(w * 0.72, 2.4, 0.04), ip + Vector3(0, 2.1, 0), cream, Vector3(0, rd, 0))
		Props.box(self, Vector3(w * 0.51, w * 0.51, 0.04), ip + Vector3(0, 3.3, 0), cream, Vector3(0, rd, 45))
		Props.box(self, Vector3(w * 0.52, 2.1, 0.05), (p * 0.972) + Vector3(0, 2.0, 0), navy, Vector3(0, rd, 0))
		Props.box(self, Vector3(w * 0.37, w * 0.37, 0.05), (p * 0.972) + Vector3(0, 3.05, 0), navy, Vector3(0, rd, 45))
		var mp := p * 0.968
		if i % 2 == 0:
			for k in 3:  # çintemani: üç benek
				var off := Vector3(0.14 * (k - 1), 2.3 + (0.14 if k == 1 else 0.0), 0).rotated(Vector3.UP, a)
				Props.ball(self, 0.1, mp + off, Color("e0b848"), Vector3.ONE, 6)
		else:  # lale
			Props.ball(self, 0.16, mp + Vector3(0, 2.4, 0), Color("d84040"), Vector3(1, 1.4, 1), 8)
			Props.cyl(self, 0.03, 0.7, mp + Vector3(0, 1.9, 0), Color("4a8a4a"), Vector3.ZERO, 4)
	# Çarpışma: yuvarlak duvar yerine dört düz kutu yeter (oyuncu dışarı çıkmasın)
	for s in [-1, 1]:
		Props.solid(self, Vector3(0.3, 5, RADIUS * 2), Vector3(s * RADIUS * 0.9, 2.5, 0), Color(0, 0, 0, 0)).get_child(0).visible = false
	Props.solid(self, Vector3(RADIUS * 2, 5, 0.3), Vector3(0, 2.5, -RADIUS * 0.9), Color(0, 0, 0, 0)).get_child(0).visible = false
	# Tavan: koni, altından görünür
	var roof := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.bottom_radius = RADIUS + 0.2
	cm.top_radius = 0.6
	cm.height = 4.0
	cm.radial_segments = n
	roof.mesh = cm
	roof.position = Vector3(0, 7.0, 0)
	roof.material_override = _inside_mat(Color("c8a060"))
	add_child(roof)
	# İki taşıyıcı direk (ortadaki tek direk Sultan'ı kapatıyordu)
	for sx in [-2.6, 2.6]:
		Props.cyl(self, 0.16, 8.4, Vector3(sx, 4.2, -1.0), Color("d8b040"), Vector3.ZERO, 10)
		Props.ball(self, 0.28, Vector3(sx, 8.4, -1.0), Color("d8b040"), Vector3.ONE, 8)
	# Giriş perdesi (açık, iki yana toplanmış)
	for s in [-1, 1]:
		Props.box(self, Vector3(0.6, 4.6, 0.12), Vector3(s * 1.6, 2.3, RADIUS - 0.1), Color("6a1418"))
	# Dışarısı (girişten görünen gün ışığı)
	Props.box(self, Vector3(3.0, 4.6, 0.05), Vector3(0, 2.3, RADIUS + 1.5), Color("f4e8c8"), Vector3.ZERO, 1.2)
	# Asılı fenerler
	for k in 6:
		var a := TAU * k / 6.0 + 0.3
		var lp := Vector3(sin(a) * 5.5, 3.6, cos(a) * 5.5)
		Props.cyl(self, 0.01, 1.8, lp + Vector3(0, 0.9, 0), Color("3a3a3a"), Vector3.ZERO, 3)
		Props.cyl(self, 0.16, 0.36, lp, Color("d8b040"), Vector3.ZERO, 8)
		var glow := Props.ball(self, 0.13, lp, Color("ffc070"), Vector3.ONE, 8, 3.0)
		glow.material_override = Props.mat(Color("ffc070"), 3.0, false, "", false)
		var l := OmniLight3D.new()
		l.position = lp
		l.light_color = Color("ffb870")
		l.light_energy = 1.3
		l.omni_range = 7.0
		add_child(l)
		lights.append(l)


func _build_floor() -> void:
	Props.solid(self, Vector3(RADIUS * 2 + 2, 0.1, RADIUS * 2 + 4), Vector3(0, -0.05, 1), Color("5a3a24"))
	var rugs := [[Vector3(0, 0.01, 0.5), Vector3(5.0, 0.02, 9.0), Color("8a1c24"), Color("d8b040")],
		[Vector3(-4.6, 0.012, 0), Vector3(2.8, 0.02, 5.0), Color("2a3a6a"), Color("c8a060")],
		[Vector3(4.6, 0.012, 0), Vector3(2.8, 0.02, 5.0), Color("2a5a4a"), Color("c8a060")]]
	for r in rugs:
		var pos: Vector3 = r[0]
		var size: Vector3 = r[1]
		Props.box(self, size, pos, r[3])
		Props.box(self, size - Vector3(0.4, -0.004, 0.4), pos + Vector3(0, 0.003, 0), r[2])
		Props.box(self, Vector3(size.x * 0.4, 0.028, size.z * 0.3), pos + Vector3(0, 0.006, 0), r[3])
	# Minderler
	for k in 6:
		var x := -3.0 + k * 1.2
		if absf(x) < 1.2:
			continue
		Props.box(self, Vector3(0.9, 0.25, 0.9), Vector3(x, 0.13, -3.6), Color("c8323a") if k % 2 == 0 else Color("d8b040"))


func _build_throne() -> void:
	var t := THRONE
	Props.solid(self, Vector3(4.2, 0.4, 2.0), t + Vector3(0, 0.2, -0.6), Color("6a3a24"))
	Props.box(self, Vector3(4.0, 0.3, 1.8), t + Vector3(0, 0.55, -0.6), Color("b3262d"))
	Props.box(self, Vector3(4.0, 1.2, 0.4), t + Vector3(0, 1.1, -1.4), Color("8a1c24"))
	for s in [-1, 1]:
		Props.box(self, Vector3(0.9, 0.5, 0.9), t + Vector3(s * 1.2, 0.95, -0.9), Color("d8b040"))
	# Arkada sancak ve tuğ
	Props.box(self, Vector3(3.0, 3.0, 0.05), t + Vector3(0, 2.8, -1.9), Color("8a1c24"))
	Props.ball(self, 0.5, t + Vector3(0, 3.0, -1.86), Color("d8b040"), Vector3(1, 1, 0.1), 10)
	Props.cyl(self, 0.04, 3.4, t + Vector3(2.4, 1.7, -1.6), Color("5a4028"), Vector3.ZERO, 5)
	Props.ball(self, 0.3, t + Vector3(2.4, 3.5, -1.6), Color("e8e0cc"), Vector3(1, 1.6, 1), 8)
	# Katip masası
	var d := Vector3(-4.2, 0, -2.5)
	Props.solid(self, Vector3(1.4, 0.5, 0.8), d + Vector3(0, 0.25, 0), Color("6a4a30"))
	Props.box(self, Vector3(0.5, 0.02, 0.35), d + Vector3(0, 0.51, 0), Color("efe6cf"), Vector3(0, 10, 0))
	Props.cyl(self, 0.05, 0.08, d + Vector3(0.4, 0.55, 0.1), Color("1a1a1e"), Vector3.ZERO, 6)


func _build_people() -> void:
	# Fatih: genç sultan, büyük kavuk, kırmızı-altın kaftan
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.position = THRONE + Vector3(0, 0.7, -0.5)
	fatih.scale = Vector3(1.08, 1.08, 1.08)
	add_child(fatih)
	scribe = Person.new({"coat": Color("3a4a3a"), "pants": Color("2a2a24"), "hat": "turban", "beard": true, "robe": Color("3a4a3a"), "skin": Color("d9a07a")})
	scribe.position = Vector3(-4.2, 0, -1.6)
	scribe.rotation.y = PI * 0.8
	add_child(scribe)
	for s in [-1, 1]:
		var g := Soldier.new(Color("b3262d") if s < 0 else Color("2f5fa8"), "stand", "bork")
		g.position = THRONE + Vector3(s * 3.0, 0, 0.6)
		add_child(g)
		guards.append(g)
