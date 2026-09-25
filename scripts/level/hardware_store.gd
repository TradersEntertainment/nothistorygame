class_name HardwareStore
extends Node3D
## Bölüm 8: gece açık tek hırdavatçı, "Nöbetçi Hırdavat · 7/24". 2026, pazartesi 05:00.
## Önde sokak, sokak lambası ve Zaman Bürosu'nun gri minibüsü; içeride üç reyon, arka duvarda
## anten askısı, sağda Cemil'in tezgâhı. Floresanlar titrer; reyonların arası loş (gizlilik için).
## Ajanların görüşünü kesen raflar SHELVES dikdörtgenleriyle tanımlıdır (x0, z0, x1, z1).

const SPAWN := Vector3(0.0, 0.0, 5.0)
const DOOR_Z := 0.0
const BACK_Z := -16.0
const HALF_W := 7.0
const CEMIL_POS := Vector3(6.2, 0.0, -2.6)
const COUNTER_POS := Vector3(5.0, 0.0, -2.6)
const SHELVES := [Rect2(-4.0, -13.0, 1.0, 8.0), Rect2(-0.5, -13.0, 1.0, 8.0), Rect2(3.0, -13.0, 1.0, 8.0)]
const VAN_POS := Vector3(-5.5, 0.0, 6.0)
## Ürün yerleri: parça kimliği -> konum
const PARTS := {
	"capacitor": Vector3(-2.95, 1.05, -10.0),
	"antenna": Vector3(-4.2, 1.3, -15.6),
	"glass": Vector3(2.95, 0.9, -7.0),
	"tape": Vector3(4.6, 0.95, -14.8),
	"cutter": Vector3(4.05, 0.7, -11.5),
	"laminator": Vector3(-5.9, 0.95, -2.2),
	"raincoat": Vector3(-6.4, 1.2, -5.0),
}

var cemil: Person
var part_nodes: Dictionary = {}
var lights: Array[OmniLight3D] = []
var tubes: Array[MeshInstance3D] = []
var _t := 0.0


func _ready() -> void:
	Audio.voice_space("room")
	_build_env()
	_build_street()
	_build_room()
	_build_shelves()
	_build_counter()
	_build_parts()


func _process(delta: float) -> void:
	_t += delta
	# Floresanlardan biri arada bir göz kırpar
	if lights.size() > 2:
		var on := fmod(_t, 5.3) > 0.18 and fmod(_t, 5.3) < 5.0 or fmod(_t, 5.3) > 5.12
		lights[2].light_energy = 0.9 if on else 0.1


func _build_env() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("0c1020")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("5a6480")
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.5
	e.fog_enabled = true
	e.fog_light_color = Color("1a2038")
	e.fog_density = 0.012
	env.environment = e
	add_child(env)


# ---------------------------------------------------------------- sokak

func _build_street() -> void:
	Props.solid(self, Vector3(60, 0.2, 30), Vector3(0, -0.1, 12.0), Color("2a2c30"))
	Props.box(self, Vector3(60, 0.12, 3.0), Vector3(0, 0.06, 1.5), Color("5a5c60"))
	for i in 8:
		Props.box(self, Vector3(1.6, 0.01, 0.15), Vector3(-21.0 + i * 6.0, 0.005, 9.0), Color("d8d0b0"))
	# Komşu dükkânlar: kepenkler inik
	for x in [-14.0, 14.0]:
		Props.solid(self, Vector3(12.0, 6.0, 8.0), Vector3(x, 3.0, -4.0), Color("4a4640"))
		for k in 8:
			Props.box(self, Vector3(8.0, 0.3, 0.05), Vector3(x, 0.25 + k * 0.34, 0.03), Color("7a808a") if k % 2 == 0 else Color("6d737c"))
	# Karşı apartmanlar
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	for i in 7:
		var x := -18.0 + i * 6.0
		var h := rng.randf_range(8.0, 13.0)
		Props.box(self, Vector3(5.6, h, 5.0), Vector3(x, h / 2.0, 22.0), Color("35332f"))
		for k in 6:
			var lit := rng.randf() < 0.25
			var win := Props.box(self, Vector3(0.8, 0.9, 0.05), Vector3(x - 1.3 + (k % 2) * 2.6, 1.8 + (k / 2) * 2.6, 19.47), Color("ffd08a"))
			win.material_override = Props.mat(Color("ffd08a") if lit else Color("1a1e28"), 1.2 if lit else 0.0, false, "", false)
	# Sokak lambası
	Props.cyl(self, 0.07, 5.0, Vector3(4.0, 2.5, 2.6), Color("3a3f48"), Vector3.ZERO, 6)
	Props.box(self, Vector3(0.6, 0.12, 0.3), Vector3(3.75, 5.0, 2.6), Color("3a3f48"))
	var sl := OmniLight3D.new()
	sl.position = Vector3(3.6, 4.8, 2.6)
	sl.light_color = Color("ffb870")
	sl.light_energy = 2.2
	sl.omni_range = 10.0
	add_child(sl)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-2.0, 5.0, 10.0)
	fill.light_color = Color("9fb4ff")
	fill.light_energy = 1.4
	fill.omni_range = 16.0
	add_child(fill)
	build_van(self, VAN_POS, 0.0)
	# Sokak kedisi (kutunun üstünde uyuyor)
	Props.box(self, Vector3(0.6, 0.5, 0.5), Vector3(8.5, 0.25, 1.2), Color("8a6a40"))
	Props.ball(self, 0.2, Vector3(8.5, 0.62, 1.2), Color("d8883a"), Vector3(1.5, 0.7, 1.0), 8)
	Props.ball(self, 0.1, Vector3(8.78, 0.7, 1.2), Color("d8883a"), Vector3.ONE, 6)


## Zaman Bürosu'nun gri minibüsü (Bölüm 5'tekinin aynısı), projektörüyle.
static func build_van(parent: Node3D, pos: Vector3, rot_y: float) -> Node3D:
	var van := Node3D.new()
	van.position = pos
	van.rotation_degrees.y = rot_y
	parent.add_child(van)
	Props.box(van, Vector3(1.9, 1.7, 4.4), Vector3(0, 1.25, 0), Color("8a8f96"))
	Props.box(van, Vector3(1.9, 0.9, 0.9), Vector3(0, 0.85, 2.6), Color("8a8f96"))
	Props.box(van, Vector3(1.8, 0.55, 0.05), Vector3(0, 1.75, 2.24), Color("1a2238"), Vector3(-20, 0, 0))
	for side in [-1, 1]:
		Props.box(van, Vector3(0.05, 0.5, 1.2), Vector3(side * 0.96, 1.6, 1.2), Color("1a2238"))
		for wz in [-1.5, 1.7]:
			Props.cyl(van, 0.36, 0.25, Vector3(side * 0.9, 0.36, wz), Color("15171c"), Vector3(0, 0, 90), 10)
		var tx := Props.label(van, "ZAMAN BÜROSU", Vector3(side * 0.97, 1.35, -0.4), 40, Color("1d2330"), Vector3(0, 90 * side, 0), 2.6)
		tx.double_sided = false
		Props.label(van, "Size zaman ayırıyoruz", Vector3(side * 0.97, 1.0, -0.4), 22, Color("3a3f48"), Vector3(0, 90 * side, 0), 2.2)
	for hx in [-0.65, 0.65]:
		var hl := Props.box(van, Vector3(0.3, 0.16, 0.05), Vector3(hx, 0.95, 3.06), Color("fff4d0"))
		hl.material_override = Props.mat(Color("fff4d0"), 3.0, false, "", false)
	Props.cyl(van, 0.2, 0.3, Vector3(0, 2.25, 0.6), Color("3a3f48"), Vector3(90, 0, 0), 10)
	Props.cyl(van, 0.04, 0.6, Vector3(-0.5, 2.4, -1.2), Color("3a3f48"), Vector3.ZERO, 6)
	Props.box(van, Vector3(0.12, 0.08, 0.2), Vector3(-0.5, 2.72, -1.15), Color("3a3f48"))
	var col := Props.solid(van, Vector3(1.9, 2.0, 5.4), Vector3(0, 1.0, 0.4), Color(0, 0, 0, 0))
	col.get_child(0).visible = false
	return van


# ---------------------------------------------------------------- dükkân

func _build_room() -> void:
	var wall := Color("c8c0a8")
	var d := -BACK_Z
	Props.solid(self, Vector3(HALF_W * 2, 0.1, d), Vector3(0, 0.0, BACK_Z / 2.0), Color("8a8478"))
	Props.set_pattern(Props.solid(self, Vector3(0.3, 3.4, d), Vector3(-HALF_W, 1.7, BACK_Z / 2.0), wall), wall, "wall")
	Props.set_pattern(Props.solid(self, Vector3(0.3, 3.4, d), Vector3(HALF_W, 1.7, BACK_Z / 2.0), wall), wall, "wall")
	Props.set_pattern(Props.solid(self, Vector3(HALF_W * 2, 3.4, 0.3), Vector3(0, 1.7, BACK_Z), wall), wall, "wall")
	Props.box(self, Vector3(HALF_W * 2 + 0.3, 0.2, d), Vector3(0, 3.45, BACK_Z / 2.0), Color("a8a090"))
	# Ön cephe: vitrin camları, cam kapı (aralık: x -1..1)
	for s in [-1, 1]:
		var cx: float = s * (HALF_W + 1.0) / 2.0
		Props.solid(self, Vector3(HALF_W - 1.0, 0.8, 0.3), Vector3(cx, 0.4, DOOR_Z), Color("5a5448"))
		var glass := Props.box(self, Vector3(HALF_W - 1.0, 2.2, 0.05), Vector3(cx, 1.9, DOOR_Z), Color("9fc4e0"))
		glass.material_override = Props.mat(Color(0.6, 0.8, 0.95, 0.18), 0.0, true, "", false)
		var col := Props.solid(self, Vector3(HALF_W - 1.0, 2.2, 0.1), Vector3(cx, 1.9, DOOR_Z), Color(0, 0, 0, 0))
		col.get_child(0).visible = false
		Props.box(self, Vector3(0.12, 3.0, 0.14), Vector3(s * 1.0, 1.5, DOOR_Z), Color("3a3f48"))
		# Vitrinde süpürge, kova, el arabası
		Props.cyl(self, 0.02, 1.4, Vector3(s * 4.5, 0.7, DOOR_Z - 0.4), Color("c8a060"), Vector3(0, 0, 15), 5)
		Props.cyl(self, 0.22, 0.35, Vector3(s * 5.5, 0.18, DOOR_Z - 0.5), Color("3a7ab8") if s < 0 else Color("d8b040"), Vector3.ZERO, 10, 0.28)
	Props.box(self, Vector3(HALF_W * 2, 0.5, 0.3), Vector3(0, 3.15, DOOR_Z), Color("5a5448"))
	# Neon tabela
	var sign_bg := Props.box(self, Vector3(6.4, 0.7, 0.1), Vector3(0, 3.8, DOOR_Z + 0.1), Color("1a1e28"))
	sign_bg.name = "SignBg"
	var neon := Props.label(self, "NÖBETÇİ HIRDAVAT", Vector3(0, 3.86, DOOR_Z + 0.17), 64, Color("ff5a8a"), Vector3.ZERO, 5.6)
	neon.modulate = Color(1.6, 0.6, 1.0)
	Props.label(self, "7/24 · VİDADAN ZAMANA HER ŞEY", Vector3(0, 3.55, DOOR_Z + 0.17), 26, Color("6ff2c8"), Vector3.ZERO, 4.0)
	var nl := OmniLight3D.new()
	nl.position = Vector3(0, 3.6, DOOR_Z + 1.2)
	nl.light_color = Color("ff5a8a")
	nl.light_energy = 1.2
	nl.omni_range = 5.0
	add_child(nl)
	# Floresanlar
	for z in [-3.0, -8.0, -13.0]:
		for x in [-3.5, 3.5]:
			var tube := Props.box(self, Vector3(1.4, 0.06, 0.12), Vector3(x, 3.3, z), Color("eef4ff"))
			tube.material_override = Props.mat(Color("eef4ff"), 2.0, false, "", false)
			tubes.append(tube)
		var l := OmniLight3D.new()
		l.position = Vector3(0, 3.0, z)
		l.light_color = Color("e4ecff")
		l.light_energy = 0.9
		l.omni_range = 8.0
		add_child(l)
		lights.append(l)
	# Duvar yazıları
	Props.label(self, "VERESİYE DEFTERİ 1981'DEN BERİ AÇIKTIR", Vector3(HALF_W - 0.16, 2.7, -8.0), 22, Color("5a2a2a"), Vector3(0, -90, 0), 5.0)
	Props.label(self, "ZAMAN MAKİNESİ PARÇASI SORMAYINIZ", Vector3(-HALF_W + 0.16, 2.7, -9.0), 22, Color("5a2a2a"), Vector3(0, 90, 0), 5.0)


func _build_shelves() -> void:
	var names := ["REYON 1 · ELEKTRİK", "REYON 2 · BAĞLANTI", "REYON 3 · BAHÇE"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 8
	var box_cols := [Color("c8603a"), Color("3a7ab8"), Color("d8b040"), Color("5a9a4a"), Color("e8e0cc"), Color("8a3a5a"), Color("4a4a52")]
	for i in SHELVES.size():
		var r: Rect2 = SHELVES[i]
		var c := Vector3(r.position.x + r.size.x / 2.0, 0, r.position.y + r.size.y / 2.0)
		Props.solid(self, Vector3(r.size.x, 2.2, r.size.y), c + Vector3(0, 1.1, 0), Color("6a7078"))
		for y in [0.35, 0.95, 1.55, 2.15]:
			Props.box(self, Vector3(r.size.x + 0.12, 0.05, r.size.y), c + Vector3(0, y, 0), Color("8d949e"))
			# İki yüzde ürünler
			for s in [-1, 1]:
				var z := r.position.y + 0.3
				while z < r.end.y - 0.3:
					var w := rng.randf_range(0.2, 0.45)
					var h := rng.randf_range(0.18, 0.42)
					Props.box(self, Vector3(0.36, h, w), Vector3(c.x + s * 0.35, y + 0.03 + h / 2.0, z + w / 2.0), box_cols[rng.randi() % box_cols.size()])
					z += w + 0.05
		for s in [-1, 1]:
			var end_z: float = r.position.y - 0.02 if s < 0 else r.end.y + 0.02
			Props.box(self, Vector3(0.9, 0.3, 0.04), Vector3(c.x, 2.45, end_z), Color("20252e"))
			Props.label(self, names[i], Vector3(c.x, 2.45, end_z + s * 0.03), 20, Color("ffd08a"), Vector3(0, 0 if s > 0 else 180, 0), 0.86)
	# Arka duvar: anten askısı, halat makaraları, arka masa
	for k in 5:
		Props.cyl(self, 0.015, 1.2, Vector3(-5.6 + k * 0.5, 1.6, BACK_Z + 0.35), Color("c9ccd1"), Vector3(0, 0, 90), 5)
		Props.cyl(self, 0.01, 0.6, Vector3(-5.6 + k * 0.5, 1.9, BACK_Z + 0.35), Color("c9ccd1"), Vector3.ZERO, 4)
	for k in 4:
		Props.cyl(self, 0.3, 0.25, Vector3(0.5 + k * 0.7, 0.4, BACK_Z + 0.4), Color("d8b070"), Vector3(90, 0, 0), 10)
	Props.solid(self, Vector3(1.8, 0.9, 0.8), Vector3(4.6, 0.45, BACK_Z + 1.2), Color("6a4a30"))


func _build_counter() -> void:
	Props.solid(self, Vector3(1.0, 1.05, 3.2), COUNTER_POS + Vector3(0, 0.525, 0), Color("7a5a3a"))
	Props.box(self, Vector3(1.1, 0.06, 3.3), COUNTER_POS + Vector3(0, 1.08, 0), Color("5a4028"))
	# Yazar kasa, çay bardağı, semaver, veresiye defteri, sabit telefon
	Props.box(self, Vector3(0.4, 0.22, 0.4), COUNTER_POS + Vector3(0.1, 1.22, -0.9), Color("3a3f48"))
	Props.box(self, Vector3(0.3, 0.12, 0.02), COUNTER_POS + Vector3(-0.05, 1.37, -0.9), Color("6ff2c8"), Vector3(0, 90, 0), 0.8)
	Props.cyl(self, 0.035, 0.09, COUNTER_POS + Vector3(-0.1, 1.155, 0.3), Color("c8603a"), Vector3.ZERO, 6, 0.028)
	Props.cyl(self, 0.14, 0.45, COUNTER_POS + Vector3(0.25, 1.33, 1.2), Color("c9ccd1"), Vector3.ZERO, 10, 0.1)
	Props.box(self, Vector3(0.3, 0.05, 0.22), COUNTER_POS + Vector3(-0.15, 1.135, -0.1), Color("2a4a8a"))
	var phone := Node3D.new()
	phone.name = "Phone"
	phone.position = COUNTER_POS + Vector3(-0.2, 1.11, 0.85)
	add_child(phone)
	Props.box(phone, Vector3(0.22, 0.08, 0.2), Vector3(0, 0.04, 0), Color("c8323a"))
	Props.box(phone, Vector3(0.26, 0.05, 0.07), Vector3(0, 0.11, 0), Color("a82a30"))
	Props.interactable(self, "phone", Vector3(0.5, 0.5, 0.5), phone.position + Vector3(0, 0.1, 0))
	cemil = Person.new({"coat": Color("7a6a50"), "pants": Color("4a4a52"), "hair": Color("d8d8d8"), "glasses": true,
		"mustache": true, "apron": Color("2f5fa8"), "skin": Color("d9a07a")})
	cemil.position = CEMIL_POS
	cemil.rotation.y = -PI / 2.0
	add_child(cemil)
	Props.interactable(self, "cemil", Vector3(1.4, 2.0, 1.4), COUNTER_POS + Vector3(0.4, 1.0, 0))


## Ürünler: her biri parlayan bir etiketle işaretli, alınınca kaybolur.
func _build_parts() -> void:
	for id in PARTS:
		var n := Node3D.new()
		n.position = PARTS[id]
		add_child(n)
		match id:
			"capacitor":
				Props.cyl(n, 0.06, 0.16, Vector3.ZERO, Color("2f5fa8"), Vector3.ZERO, 10)
				Props.cyl(n, 0.061, 0.02, Vector3(0, 0.07, 0), Color("c9ccd1"), Vector3.ZERO, 10)
				Props.label(n, "1453 µF", Vector3(-0.065, 0, 0), 16, Color.WHITE, Vector3(0, -90, 0), 0.2)
			"antenna":
				Props.cyl(n, 0.02, 1.1, Vector3.ZERO, Color("c9ccd1"), Vector3(0, 0, 90), 5)
				for k in 4:
					Props.cyl(n, 0.012, 0.5 - k * 0.08, Vector3(-0.4 + k * 0.25, 0, 0), Color("c9ccd1"), Vector3(90, 0, 0), 4)
			"glass":
				var g := Props.box(n, Vector3(0.05, 0.3, 0.5), Vector3.ZERO, Color("bfe0f0"))
				g.material_override = Props.mat(Color(0.75, 0.9, 1.0, 0.6), 0.3, true, "", false)
			"tape":
				Props.box(n, Vector3(0.6, 0.3, 0.4), Vector3(0, -0.1, 0), Color("6a6e76"))
				Props.label(n, "MÜHÜR ÇANTASI", Vector3(0, -0.1, 0.205), 16, Color("ff5a4a"), Vector3.ZERO, 0.55)
				Props.cyl(n, 0.1, 0.07, Vector3(0.1, 0.09, 0), Color("c98a3a"), Vector3.ZERO, 12)
				Props.cyl(n, 0.05, 0.072, Vector3(0.1, 0.09, 0), Color("8a6440"), Vector3.ZERO, 10)
			"cutter":
				for s in [-1, 1]:
					Props.cyl(n, 0.02, 0.6, Vector3(0, 0, s * 0.04), Color("c8323a"), Vector3(0, 0, 90 + s * 5), 5)
				Props.box(n, Vector3(0.12, 0.04, 0.06), Vector3(-0.34, 0, 0), Color("8d949e"))
			"laminator":
				Props.box(n, Vector3(0.45, 0.12, 0.25), Vector3.ZERO, Color("e8e0cc"))
				Props.box(n, Vector3(0.3, 0.01, 0.02), Vector3(0, 0.02, 0.13), Color("1a1e28"))
				Props.box(n, Vector3(0.04, 0.02, 0.02), Vector3(0.18, 0.07, 0.08), Color("6ff2c8"), Vector3.ZERO, 1.2)
			"raincoat":
				Props.cyl(n, 0.015, 0.7, Vector3(0, 0.4, 0), Color("3a3f48"), Vector3(0, 0, 90), 4)
				Props.box(n, Vector3(0.5, 1.0, 0.18), Vector3(0, -0.15, 0), Color("6a6e76"))
		var mark := Props.ring(n, 0.12, 0.16, Vector3(0, 0.3, 0), Color("ffd060"), Vector3(90, 0, 0), 1.2)
		mark.name = "Marker"
		Props.interactable(n, "part:" + id, Vector3(0.8, 0.8, 0.8), Vector3.ZERO)
		part_nodes[id] = n


func take_part(id: String) -> void:
	if part_nodes.has(id):
		var n: Node3D = part_nodes[id]
		part_nodes.erase(id)
		var tw := n.create_tween()
		tw.tween_property(n, "scale", Vector3(0.01, 0.01, 0.01), 0.25)
		tw.tween_callback(n.queue_free)


func hide_part(id: String) -> void:
	if part_nodes.has(id):
		(part_nodes[id] as Node3D).queue_free()
		part_nodes.erase(id)


## Ajanların görüşünü raflar keser mi? (2B doğru parçası – dikdörtgen kesişimi)
static func blocked(a: Vector3, b: Vector3) -> bool:
	for r in SHELVES:
		var rect: Rect2 = r
		var steps := 12
		for i in range(1, steps):
			var t := float(i) / steps
			var p := Vector2(lerpf(a.x, b.x, t), lerpf(a.z, b.z, t))
			if rect.has_point(p):
				return true
	return false
