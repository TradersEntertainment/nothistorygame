class_name EdirnePalace
extends Node3D
## Ara bölüm "Arıza" (v0.99.6): Edirne Eski Sarayı'nın (Saray-ı Atik; bugünkü Selimiye'nin yeri) has bahçesi, 1444 yazı.
## Şehzade Mehmed on iki yaşında; hocası Molla Gürânî; Eflak'ın rehine prensleri Vlad ve Radu (docs/SIEGE.md §Edirne).
##   Ortada fıskiyeli mermer havuz (Tolga'nın düştüğü yer), köşelerde çınarlar, kenarlarda gül tarhları ve serviler.
##   Kuzeyde Dershâne köşkü: yükseltilmiş ahşap döşeme, rahleler, minderler; hocanın değneği duvarda asılı.
##   Doğuda kütüphane köşkü: raflar, açık İskendernâme, Rumca kitap, usturlap, dünya haritası.
##   Batıda rehinelerin avlusu: odun kütüğü ve sivriltilmiş sopalar, mangal, nişan tahtası, rehine odalarının kapıları.
##   Güneyde saray kapısı (Halil Paşa ve muhafızlar buradan gelir).
##   Duvarların ardında: Eski Cami (1414, bitmiş), Muradiye (1436, tepede), Üç Şerefeli (1438–1447: yapımda, iskeleli
##   kubbe ve yarım kalmış üç şerefeli minare). Yeni Saray 1450'de başlar: bu manzarada yoktur.
## Ortam make_env() ile verilir: Büro'nun WorldEnvironment'ı değiştirilir (sahnede tek ortam kalsın, Bölüm 26'daki gibi).
## Bütün konumlar yereldir (seviye uzakta, Büro'dan ayrı kurulur).

const POOL := Vector3(0.0, 0.0, 0.0)
const POOL_SIZE := Vector2(6.0, 4.0)
const RIM_H := 0.36             # havuz kenarı: basamak boyu (çıkılabilir)
const WATER_Y := 0.27
## Şehzade çınarın altında okur (yere serili halı)
const READ_SPOT := Vector3(6.1, 0.0, 4.4)
const TREES := [Vector3(8.0, 0.0, 6.0), Vector3(-8.0, 0.0, 6.0), Vector3(8.0, 0.0, -6.0), Vector3(-8.0, 0.0, -6.0)]
## Dershâne: yükseltilmiş döşeme (0,3 m), güneye açık
const DERS := Vector3(0.0, 0.0, 14.5)
const DERS_SIZE := Vector2(9.0, 6.0)
const FLOOR_H := 0.3
const HOCA_SPOT := Vector3(0.0, FLOOR_H, 16.5)
const MEHMED_DERS := Vector3(0.7, FLOOR_H, 13.6)
const TOLGA_DERS := Vector3(-1.3, FLOOR_H, 12.7)
## Kütüphane köşkü (doğu): batıya açık
const LIB := Vector3(15.5, 0.0, 3.0)
const LIB_SIZE := Vector2(5.0, 6.0)
const LIB_TABLE := Vector3(15.9, FLOOR_H, 3.0)
const MEHMED_LIB := Vector3(15.9, FLOOR_H, 2.0)
const TOLGA_LIB := Vector3(14.0, FLOOR_H, 3.2)
## Rehinelerin avlusu (batı)
const LOG := Vector3(-15.0, 0.0, -3.4)
const VLAD_SPOT := Vector3(-15.0, 0.0, -2.8)      # kütüğün arkasında, sopaları yontar (yüzü kütüğe)
const RADU_SPOT := Vector3(-13.6, 0.0, -2.2)
const BRAZIER := Vector3(-16.4, 0.0, -4.9)
const BUTT := Vector3(-19.0, 0.0, -11.0)
const MEHMED_AVLU := Vector3(-12.2, 0.0, -2.9)
const TOLGA_AVLU := Vector3(-13.0, 0.0, -4.4)
## Kapı (güney) ve duvarlar
const GATE := Vector3(0.0, 0.0, -18.4)
const WALL_X := 22.0
const WALL_Z0 := -19.0
const WALL_Z1 := 20.5
const WALL_H := 4.6

const C_STONE := Color("d6c8ac")
const C_STONE_DARK := Color("b8a888")
const C_WOOD := Color("7a5232")
const C_WOOD_DARK := Color("4e321e")
const C_TILE := Color("a84a32")
const C_LAWN := Color("6f9a4a")
const C_PATH := Color("dccfb2")
const C_MARBLE := Color("eeeae0")
const C_LEAD := Color("6e7884")

var sun: DirectionalLight3D
var rod: Node3D                 # hocanın değneği (duvarda asılı; derste Gürânî'nin elinde)
var notebook: Node3D            # şehzadenin defteri (kütüphane masasında)
var sticks: Node3D              # Vlad'ın sivrilttiği sopalar (kütüğün yanında)
var brazier_fire: Node3D        # mangal (kebap seçilince yanar)
var fountain: Node3D
var _t := 0.0
var _jet: Array[MeshInstance3D] = []
var _tap_t := 3.0


func _ready() -> void:
	_ground()
	_walls()
	_pool()
	_garden()
	_dershane()
	_library()
	_courtyard()
	_skyline()
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, 150, 0)
	sun.light_color = Color("fff1d8")
	sun.light_energy = 1.05
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)
	SkyBody.attach(self, sun, false)


func _process(delta: float) -> void:
	_t += delta
	# Fıskiye: üst üste damlalar hafifçe iner kalkar
	for i in _jet.size():
		_jet[i].position.y = WATER_Y + 0.55 + i * 0.22 + sin(_t * 6.0 + i * 1.3) * 0.04
	# Üç Şerefeli'nin iskelesinde ustalar çalışıyor: ara sıra uzaktan keski sesi
	_tap_t -= delta
	if _tap_t <= 0.0:
		_tap_t = randf_range(2.5, 6.0)
		if is_visible_in_tree():
			Audio.sfx("pick_tap", -26.0, randf_range(0.8, 1.1))


## 1444 yazı: açık mavi gök, ılık ışık, hafif pus (Büro'nun WorldEnvironment'ına takılır).
static func make_env() -> Environment:
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("4f86c6")
	sm.sky_horizon_color = Color("cfe0ee")
	sm.ground_horizon_color = Color("c8c4b0")
	sm.ground_bottom_color = Color("8a8670")
	sm.sun_angle_max = 8.0
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("c8d2dc")
	e.ambient_light_energy = 0.75
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.0
	e.fog_enabled = true
	e.fog_light_color = Color("dfe6ec")
	e.fog_density = 0.0028
	e.fog_sky_affect = 0.2
	e.glow_enabled = true
	e.glow_intensity = 0.35
	return e


# ---------------------------------------------------------------- zemin ve duvarlar

func _ground() -> void:
	# Bahçenin dışı: toprak ve kuru ot (duvarların ardı yürünmez; manzara için)
	var outer := Props.box(self, Vector3(1400, 0.2, 1400), Vector3(0, -0.12, 0), Color("a89a72"))
	outer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Bahçe: çimen, katı zemin
	var lawn := Props.solid(self, Vector3(WALL_X * 2.0, 0.2, WALL_Z1 - WALL_Z0), Vector3(0, -0.1, (WALL_Z0 + WALL_Z1) * 0.5), C_LAWN)
	lawn.get_child(0).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Yollar: havuzdan dört yöne taş döşeme
	for p: Array in [[Vector3(0, 0.005, 8.0), Vector3(2.0, 0.02, 9.0)], [Vector3(0, 0.005, -11.0), Vector3(2.0, 0.02, 15.0)],
			[Vector3(8.5, 0.005, 1.0), Vector3(11.0, 0.02, 2.0)], [Vector3(-8.5, 0.005, -1.0), Vector3(11.0, 0.02, 2.0)],
			[Vector3(0, 0.004, 0), Vector3(POOL_SIZE.x + 3.0, 0.02, POOL_SIZE.y + 3.0)]]:
		var b := Props.box(self, p[1], p[0], C_PATH)
		Props.set_pattern(b, C_PATH, "flagstone")
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _walls() -> void:
	var x0 := -WALL_X
	var x1 := WALL_X
	var segs := [
		[Vector3(x1 - x0 + 1.6, WALL_H, 0.8), Vector3(0, WALL_H * 0.5, WALL_Z1)],                 # kuzey
		[Vector3(0.8, WALL_H, WALL_Z1 - WALL_Z0), Vector3(x0, WALL_H * 0.5, (WALL_Z0 + WALL_Z1) * 0.5)],   # batı
		[Vector3(0.8, WALL_H, WALL_Z1 - WALL_Z0), Vector3(x1, WALL_H * 0.5, (WALL_Z0 + WALL_Z1) * 0.5)],   # doğu
		[Vector3(x1 - 2.2 + 0.8, WALL_H, 0.8), Vector3((x1 + 2.2) * 0.5 + 0.2, WALL_H * 0.5, WALL_Z0)],     # güney, kapının doğusu
		[Vector3(x1 - 2.2 + 0.8, WALL_H, 0.8), Vector3(-(x1 + 2.2) * 0.5 - 0.2, WALL_H * 0.5, WALL_Z0)],    # güney, kapının batısı
	]
	for sg: Array in segs:
		var w := Props.solid(self, sg[0], sg[1], C_STONE)
		Props.set_pattern(w, C_STONE, "ashlar")
		w.set_meta("no_climb", true)
		# Duvar başlığı: kiremit sırtı
		var top: Vector3 = sg[1]
		var sz: Vector3 = sg[0]
		Props.box(self, Vector3(sz.x + 0.2, 0.25, sz.z + 0.2), Vector3(top.x, WALL_H + 0.12, top.z), C_TILE)
	# Kapı: kemerli, kalın ahşap iki kanat (kapalı; Halil ile muhafızlar içeriden açılmış gibi gelir)
	var g := GATE
	var arch := Props.box(self, Vector3(5.6, WALL_H + 1.6, 1.2), g + Vector3(0, (WALL_H + 1.6) * 0.5, -0.4), C_STONE_DARK)
	Props.set_pattern(arch, C_STONE_DARK, "ashlar")
	# Kapı kemerin önünde: iki kanat, üstte sivri kemerli alınlık, çivi sıraları
	var door := Props.solid(self, Vector3(3.6, 3.4, 0.25), g + Vector3(0, 1.7, 0.35), C_WOOD_DARK)
	door.set_meta("no_climb", true)
	Props.set_pattern(door, C_WOOD_DARK, "wood")
	Props.box(self, Vector3(0.06, 3.4, 0.27), g + Vector3(0, 1.7, 0.35), Color("2a1a10"))
	Props.prism(self, Vector3(3.6, 1.0, 0.24), g + Vector3(0, 3.9, 0.3), C_STONE_DARK.darkened(0.15))
	for row in 3:
		for k in 6:
			Props.ball(self, 0.05, g + Vector3(-1.4 + k * 0.56, 0.8 + row * 0.9, 0.49), Color("8a7a5a"), Vector3.ONE, 5)


# ---------------------------------------------------------------- havuz ve bahçe

func _pool() -> void:
	var p := POOL
	var hx := POOL_SIZE.x * 0.5
	var hz := POOL_SIZE.y * 0.5
	# Dip: katı (içinde yürünür, su baldıra kadar), kenarlar alçak basamak
	Props.solid(self, Vector3(POOL_SIZE.x, 0.1, POOL_SIZE.y), p + Vector3(0, -0.05, 0), Color("6a8a8a"))
	for s: Array in [[Vector3(POOL_SIZE.x + 0.7, RIM_H, 0.35), Vector3(0, RIM_H * 0.5, hz + 0.17)],
			[Vector3(POOL_SIZE.x + 0.7, RIM_H, 0.35), Vector3(0, RIM_H * 0.5, -hz - 0.17)],
			[Vector3(0.35, RIM_H, POOL_SIZE.y), Vector3(hx + 0.17, RIM_H * 0.5, 0)],
			[Vector3(0.35, RIM_H, POOL_SIZE.y), Vector3(-hx - 0.17, RIM_H * 0.5, 0)]]:
		var r := Props.solid(self, s[0], p + (s[1] as Vector3), C_MARBLE)
		Props.set_pattern(r, C_MARBLE, "marble")
	var water := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = POOL_SIZE
	water.mesh = pm
	water.position = p + Vector3(0, WATER_Y, 0)
	var wm := CityPanorama.water_mat().duplicate() as StandardMaterial3D
	wm.albedo_color = Color("2e6f88")
	wm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wm.albedo_color.a = 0.82
	water.material_override = wm
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(water)
	# Fıskiye: ortada küçük mermer kâse ve yükselen su
	fountain = Node3D.new()
	fountain.position = p
	add_child(fountain)
	Props.cyl(fountain, 0.18, 0.6, Vector3(0, 0.3, 0), C_MARBLE, Vector3.ZERO, 8)
	Props.cyl(fountain, 0.45, 0.12, Vector3(0, 0.62, 0), C_MARBLE, Vector3.ZERO, 10, 0.55)
	var jm := StandardMaterial3D.new()
	jm.albedo_color = Color(0.85, 0.95, 1.0, 0.55)
	jm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	jm.emission_enabled = true
	jm.emission = Color("cfefff")
	jm.emission_energy_multiplier = 0.3
	for i in 4:
		var d := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.07 - i * 0.012
		sm.height = sm.radius * 3.0
		d.mesh = sm
		d.material_override = jm
		d.position = Vector3(0, WATER_Y + 0.55 + i * 0.22, 0)
		d.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		fountain.add_child(d)
		_jet.append(d)


func _garden() -> void:
	# Çınarlar: büyük, gölgeli (şehzadenin okuduğu yer birinin altında)
	var xs: Array = []
	for tp: Vector3 in TREES:
		xs.append(Transform3D(Basis().scaled(Vector3(1.55, 1.7, 1.55)), tp))
	Scenery.scatter(self, Scenery.plane_tree_mesh(), xs, [], Scenery._vc_mat())
	for tp: Vector3 in TREES:
		Props.solid(self, Vector3(0.8, 4.0, 0.8), tp + Vector3(0, 2.0, 0), Color.WHITE).get_child(0).visible = false
	# Okuma halısı ve minder (çınarın altında)
	var rp := READ_SPOT
	Props.box(self, Vector3(1.8, 0.02, 1.3), rp + Vector3(0, 0.011, 0), Color("d8b040"))
	Props.box(self, Vector3(1.6, 0.025, 1.1), rp + Vector3(0, 0.013, 0), Color("8a1c24"))
	Props.box(self, Vector3(0.5, 0.18, 0.4), rp + Vector3(0.75, 0.09, 0.45), Color("2a3a6a"))
	# Gül tarhları ve serviler (duvar boyunca)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1444
	for side in [-1.0, 1.0]:
		for k in 5:
			var bed := Vector3(side * (4.2 + k * 3.3), 0.0, -14.5)
			if absf(bed.x) > WALL_X - 2.0:
				continue
			Props.box(self, Vector3(2.4, 0.22, 1.2), bed + Vector3(0, 0.11, 0), Color("5a7a3a"))
			for f in 7:
				Props.ball(self, 0.11, bed + Vector3(rng.randf_range(-1.0, 1.0), 0.3, rng.randf_range(-0.45, 0.45)),
					[Color("c8263a"), Color("e86a8a"), Color("f0d0d8")][f % 3], Vector3.ONE, 5)
	var cy: Array = []
	for k in 9:
		cy.append(Transform3D(Basis().scaled(Vector3.ONE * 0.95), Vector3(WALL_X - 1.6, 0, -16.0 + k * 4.4)))
		cy.append(Transform3D(Basis().scaled(Vector3.ONE * 0.95), Vector3(-WALL_X + 1.6, 0, 6.0 + k * 1.6)))
	Scenery.scatter(self, Scenery.cypress_slim_mesh(), cy, [], Scenery._vc_mat())


# ---------------------------------------------------------------- Dershâne

func _dershane() -> void:
	var c := DERS
	var hx := DERS_SIZE.x * 0.5
	var hz := DERS_SIZE.y * 0.5
	var fl := Props.solid(self, Vector3(DERS_SIZE.x, FLOOR_H, DERS_SIZE.y), c + Vector3(0, FLOOR_H * 0.5, 0), C_WOOD)
	Props.set_pattern(fl, C_WOOD, "wood")
	# Arka ve yan duvarlar (güney açık), sütunlar, saçaklı kiremit çatı
	var back := Props.solid(self, Vector3(DERS_SIZE.x, 3.2, 0.3), c + Vector3(0, FLOOR_H + 1.6, hz - 0.15), Color("efe6d2"))
	Props.set_pattern(back, Color("efe6d2"), "plaster")
	for s in [-1.0, 1.0]:
		var sw := Props.solid(self, Vector3(0.3, 3.2, DERS_SIZE.y * 0.55), c + Vector3(s * (hx - 0.15), FLOOR_H + 1.6, hz * 0.45), Color("efe6d2"))
		Props.set_pattern(sw, Color("efe6d2"), "plaster")
		Props.solid(self, Vector3(0.28, 3.2, 0.28), c + Vector3(s * (hx - 0.2), FLOOR_H + 1.6, -hz + 0.2), C_WOOD_DARK)
		Props.solid(self, Vector3(0.24, 3.2, 0.24), c + Vector3(s * 1.6, FLOOR_H + 1.6, -hz + 0.2), C_WOOD_DARK)
	Props.box(self, Vector3(DERS_SIZE.x + 1.6, 0.3, DERS_SIZE.y + 1.6), c + Vector3(0, FLOOR_H + 3.3, 0), C_WOOD_DARK)
	var roof := Props.prism(self, Vector3(DERS_SIZE.x + 2.0, 1.4, DERS_SIZE.y + 2.0), c + Vector3(0, FLOOR_H + 4.15, 0), C_TILE)
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	# Basamak (güney): döşemeye çıkış
	Props.solid(self, Vector3(2.4, FLOOR_H * 0.5, 0.5), c + Vector3(0, FLOOR_H * 0.25, -hz - 0.25), C_STONE)
	# Halı, minderler, rahleler
	Props.box(self, Vector3(6.6, 0.02, 4.2), c + Vector3(0, FLOOR_H + 0.011, 0.2), Color("d8b040"))
	Props.box(self, Vector3(6.2, 0.024, 3.8), c + Vector3(0, FLOOR_H + 0.013, 0.2), Color("7a1c22"))
	Props.box(self, Vector3(1.0, 0.04, 0.8), HOCA_SPOT + Vector3(0, 0.03, 0.1), Color("2a4a3a"))       # hocanın postu
	Props.box(self, Vector3(0.7, 0.04, 0.6), MEHMED_DERS + Vector3(0, 0.03, 0.0), Color("c8323a"))
	for rx in [0.7, -1.3]:
		_rahle(Vector3(rx, FLOOR_H, 14.6), 0.0)
	_rahle(HOCA_SPOT + Vector3(0, 0, -0.75), PI)
	# Duvarda: hat levhası, raf ve değnek (II. Murad'ın hocaya verdiği; rivayet)
	Props.box(self, Vector3(2.2, 0.7, 0.05), c + Vector3(0, FLOOR_H + 2.3, hz - 0.33), Color("1e3a30"))
	Props.label(self, "RABBİ ZİDNÎ İLMÂ", c + Vector3(0, FLOOR_H + 2.3, hz - 0.36), 26, Color("e8d090"), Vector3(0, 180, 0), 2.0)
	rod = Node3D.new()
	rod.position = c + Vector3(2.4, FLOOR_H + 1.8, hz - 0.36)
	rod.rotation_degrees = Vector3(0, 0, 70)
	add_child(rod)
	Props.cyl(rod, 0.014, 1.05, Vector3.ZERO, Color("8a6a40"), Vector3.ZERO, 5)
	Props.box(self, Vector3(0.12, 0.05, 0.1), c + Vector3(2.4, FLOOR_H + 1.78, hz - 0.33), C_WOOD_DARK)


## Rahle: X biçimli alçak kitap sehpası, üstünde açık kitap.
func _rahle(at: Vector3, yaw: float) -> void:
	var n := Node3D.new()
	n.position = at
	n.rotation.y = yaw
	add_child(n)
	Props.box(n, Vector3(0.42, 0.03, 0.34), Vector3(0, 0.3, 0), C_WOOD, Vector3(-28, 0, 0))
	Props.box(n, Vector3(0.04, 0.32, 0.04), Vector3(-0.17, 0.16, 0.06), C_WOOD_DARK, Vector3(0, 0, 12))
	Props.box(n, Vector3(0.04, 0.32, 0.04), Vector3(0.17, 0.16, 0.06), C_WOOD_DARK, Vector3(0, 0, -12))
	Props.box(n, Vector3(0.36, 0.02, 0.26), Vector3(0, 0.33, -0.01), Color("efe6cf"), Vector3(-28, 0, 0))
	Props.box(n, Vector3(0.012, 0.025, 0.27), Vector3(0, 0.335, -0.01), Color("7a1c22"), Vector3(-28, 0, 0))


# ---------------------------------------------------------------- kütüphane köşkü

func _library() -> void:
	var c := LIB
	var hx := LIB_SIZE.x * 0.5
	var hz := LIB_SIZE.y * 0.5
	var fl := Props.solid(self, Vector3(LIB_SIZE.x, FLOOR_H, LIB_SIZE.y), c + Vector3(0, FLOOR_H * 0.5, 0), C_WOOD)
	Props.set_pattern(fl, C_WOOD, "wood")
	Props.solid(self, Vector3(0.5, FLOOR_H * 0.5, 2.2), c + Vector3(-hx - 0.25, FLOOR_H * 0.25, 0), C_STONE)
	# Doğu duvarı rafları; yan duvarlar; çatı
	var back := Props.solid(self, Vector3(0.3, 3.2, LIB_SIZE.y), c + Vector3(hx - 0.15, FLOOR_H + 1.6, 0), Color("efe6d2"))
	Props.set_pattern(back, Color("efe6d2"), "plaster")
	for s in [-1.0, 1.0]:
		var sw := Props.solid(self, Vector3(LIB_SIZE.x, 3.2, 0.3), c + Vector3(0, FLOOR_H + 1.6, s * (hz - 0.15)), Color("efe6d2"))
		Props.set_pattern(sw, Color("efe6d2"), "plaster")
		Props.solid(self, Vector3(0.26, 3.2, 0.26), c + Vector3(-hx + 0.15, FLOOR_H + 1.6, s * (hz - 0.15)), C_WOOD_DARK)
	Props.box(self, Vector3(LIB_SIZE.x + 1.4, 0.3, LIB_SIZE.y + 1.4), c + Vector3(0, FLOOR_H + 3.3, 0), C_WOOD_DARK)
	Props.prism(self, Vector3(LIB_SIZE.x + 1.8, 1.2, LIB_SIZE.y + 1.8), c + Vector3(0, FLOOR_H + 4.05, 0), C_TILE, Vector3(0, 90, 0))
	# Raflar: kitaplar yatık durur (Osmanlı kütüphanesi), sırtları değil ağızları dışarı
	var rng := RandomNumberGenerator.new()
	rng.seed = 1432
	var sx := c.x + hx - 0.45
	Props.solid(self, Vector3(0.5, 2.4, 4.6), Vector3(sx, FLOOR_H + 1.2, c.z), C_WOOD_DARK)
	for row in 4:
		var y := FLOOR_H + 0.35 + row * 0.55
		Props.box(self, Vector3(0.52, 0.04, 4.6), Vector3(sx - 0.02, y - 0.04, c.z), C_WOOD)
		var z := c.z - 2.1
		while z < c.z + 2.1:
			var h := rng.randf_range(0.05, 0.11)
			var stack := rng.randi_range(1, 4)
			for k in stack:
				Props.box(self, Vector3(0.36, h, rng.randf_range(0.24, 0.32)), Vector3(sx - 0.28, y + h * (k + 0.5), z),
					[Color("7a1c22"), Color("2a3a6a"), Color("3a5a3a"), Color("6a4a2c"), Color("8a6a2a")][rng.randi() % 5])
			z += rng.randf_range(0.34, 0.48)
	# Masa: açık İskendernâme, Rumca kitap, usturlap, defter
	var t := LIB_TABLE
	Props.solid(self, Vector3(1.6, 0.42, 0.9), t + Vector3(0, 0.21, 0), C_WOOD_DARK)
	Props.box(self, Vector3(0.5, 0.025, 0.36), t + Vector3(-0.3, 0.44, 0.0), Color("efe6cf"))
	Props.box(self, Vector3(0.012, 0.03, 0.37), t + Vector3(-0.3, 0.445, 0.0), Color("7a1c22"))
	Props.label(self, "İSKENDERNÂME", t + Vector3(-0.3, 0.46, 0.0), 10, Color("5a2a1a"), Vector3(-90, 90, 0), 0.4)
	Props.box(self, Vector3(0.3, 0.06, 0.22), t + Vector3(0.35, 0.46, 0.22), Color("2a3a6a"))
	Props.label(self, "ŞEHNÂME", t + Vector3(0.35, 0.495, 0.22), 9, Color("e8d090"), Vector3(-90, 90, 0), 0.26)
	var astro := Node3D.new()
	astro.position = t + Vector3(0.55, 0.62, -0.25)
	add_child(astro)
	for k in 3:
		Props.ring(astro, 0.13 - k * 0.025, 0.145 - k * 0.025, Vector3.ZERO, Color("c49a45"), Vector3(90 * (k % 2), k * 40, 0))
	Props.cyl(astro, 0.012, 0.2, Vector3(0, -0.15, 0), Color("8a6a2a"), Vector3.ZERO, 5)
	notebook = Node3D.new()
	notebook.position = t + Vector3(0.05, 0.45, -0.2)
	add_child(notebook)
	Props.box(notebook, Vector3(0.24, 0.02, 0.17), Vector3.ZERO, Color("c8b48a"))
	Props.box(notebook, Vector3(0.18, 0.004, 0.12), Vector3(0, 0.012, 0), Color("efe6cf"))
	# Dünya haritası (Batlamyus usulü), ayaklı çerçevede
	var mp := c + Vector3(-0.6, FLOOR_H, hz - 0.9)
	Props.box(self, Vector3(1.3, 0.9, 0.04), mp + Vector3(0, 1.35, 0), Color("d8c8a0"), Vector3(0, 200, 0))
	Props.ball(self, 0.32, mp + Vector3(0.05, 1.38, -0.03), Color("6a8a5a"), Vector3(1.2, 0.7, 0.05), 8)
	Props.box(self, Vector3(0.05, 1.0, 0.05), mp + Vector3(-0.5, 0.5, 0.1), C_WOOD_DARK)
	Props.box(self, Vector3(0.05, 1.0, 0.05), mp + Vector3(0.5, 0.5, 0.1), C_WOOD_DARK)
	Props.box(self, Vector3(2.4, 0.02, 1.8), c + Vector3(0.2, FLOOR_H + 0.011, 0), Color("2a3a6a"))


# ---------------------------------------------------------------- rehinelerin avlusu

func _courtyard() -> void:
	# Rehine odaları: batı duvarına yaslı alçak yapı, iki kapı
	var hb := Props.solid(self, Vector3(3.0, 3.4, 12.0), Vector3(-WALL_X + 1.9, 1.7, -6.0), Color("e6dcc6"))
	Props.set_pattern(hb, Color("e6dcc6"), "plaster")
	Props.prism(self, Vector3(3.6, 1.0, 12.6), Vector3(-WALL_X + 1.9, 3.9, -6.0), C_TILE, Vector3(0, 90, 0))
	for dz in [-9.0, -3.0]:
		Props.box(self, Vector3(0.08, 2.1, 1.0), Vector3(-WALL_X + 3.42, 1.05, dz), C_WOOD_DARK)
		Props.box(self, Vector3(0.06, 0.5, 0.6), Vector3(-WALL_X + 3.43, 2.6, dz), Color("8a9aa0"))
	# Kütük ve sivriltilmiş sopalar (Vlad'ın işi)
	Props.solid(self, Vector3(0.9, 0.42, 0.5), LOG + Vector3(0, 0.21, 0), Color("6a5038"))
	Props.cyl(self, 0.24, 0.92, LOG + Vector3(0, 0.42, 0), Color("8a6a48"), Vector3(0, 0, 90), 8)
	sticks = Node3D.new()
	sticks.position = LOG + Vector3(-0.9, 0.0, -0.45)
	add_child(sticks)
	for k in 7:
		var st := Node3D.new()
		st.position = Vector3(k * 0.07, 0.05, k * 0.03)
		st.rotation_degrees = Vector3(0, 0, -78 + k * 2)
		sticks.add_child(st)
		Props.cyl(st, 0.018, 0.8, Vector3(0, 0.4, 0), Color("b89a6a"), Vector3.ZERO, 5)
		Props.cyl(st, 0.018, 0.1, Vector3(0, 0.85, 0), Color("e8d8b0"), Vector3.ZERO, 5, 0.001)
	# Talaş
	for k in 9:
		Props.box(self, Vector3(0.06, 0.008, 0.02), LOG + Vector3(randf_range(-0.6, 0.6), 0.005, randf_range(-0.6, 0.2)), Color("e8d8b0"),
			Vector3(0, randf() * 180, 0))
	# Mangal: bakır kazan, kömür; kebap seçilince yanar
	Props.cyl(self, 0.32, 0.5, BRAZIER + Vector3(0, 0.25, 0), Color("8a4a2a"), Vector3.ZERO, 10, 0.4)
	Props.solid(self, Vector3(0.6, 0.55, 0.6), BRAZIER + Vector3(0, 0.27, 0), Color.WHITE).get_child(0).visible = false
	Props.cyl(self, 0.36, 0.06, BRAZIER + Vector3(0, 0.53, 0), Color("b06a3a"), Vector3.ZERO, 10)
	for k in 5:
		Props.ball(self, 0.06, BRAZIER + Vector3(cos(k * 1.3) * 0.15, 0.55, sin(k * 1.3) * 0.15), Color("2a2420"), Vector3.ONE, 5)
	# Nişan tahtası ve ok sadağı
	Props.solid(self, Vector3(1.2, 1.2, 0.3), BUTT + Vector3(0, 0.9, 0), Color("c8b080"))
	for k in 3:
		Props.cyl(self, 0.45 - k * 0.14, 0.31, BUTT + Vector3(0, 1.0, 0.0), [Color("f0e8d8"), Color("a8262f"), Color("f0e8d8")][k],
			Vector3(90, 0, 0), 12)
	Props.ball(self, 0.08, BUTT + Vector3(0, 1.0, -0.17), Color("1a1a1a"), Vector3(1, 1, 0.3), 6)


## Mangalı yakar (kebap).
func light_brazier() -> void:
	if brazier_fire == null:
		brazier_fire = Vfx.fire(self, BRAZIER + Vector3(0, 0.58, 0), 0.16)


# ---------------------------------------------------------------- 1444 Edirne manzarası

func _skyline() -> void:
	var d := Dressing.new(1444)
	# Üç Şerefeli (yapımda): gövde, yarım kubbe ve iskele; en yüksek minare 2/3'te, kafes iskele ve çıkrık
	var u := Vector3(-55.0, 0.0, 150.0)
	d.box(Vector3(46.0, 15.0, 40.0), u + Vector3(0, 7.5, 0), Color("e0d8c8"))
	d.ball(12.5, u + Vector3(0, 15.0, 0), Color("b8b0a0"), Vector3(1.0, 0.55, 1.0), 14)
	for k in 4:
		d.ball(5.0, u + Vector3(-14.0 + (k % 2) * 28.0, 15.0, -12.0 + (k / 2) * 24.0), C_LEAD, Vector3(1.0, 0.7, 1.0), 10)
	var mins := [[Vector3(-26, 0, -22), 44.0, true], [Vector3(26, 0, -22), 52.0, false], [Vector3(-26, 0, 22), 30.0, true], [Vector3(26, 0, 22), 46.0, false]]
	for m: Array in mins:
		var mp: Vector3 = u + (m[0] as Vector3)
		var h: float = m[1]
		d.cyl(1.4, h, mp + Vector3(0, h * 0.5, 0), Color("e8e0d0"), Vector3.ZERO, 10)
		if m[2]:
			# Yapımda: iskele kafesi (dört direk, kuşaklar), tepede çıkrık
			for k in 4:
				var o := Vector3(cos(k * PI * 0.5 + 0.785), 0, sin(k * PI * 0.5 + 0.785)) * 2.4
				d.cyl(0.12, h + 6.0, mp + o + Vector3(0, (h + 6.0) * 0.5, 0), Color("8a6a40"), Vector3.ZERO, 4)
			var y := 4.0
			while y < h + 5.0:
				d.box(Vector3(5.0, 0.15, 0.15), mp + Vector3(0, y, 1.7), Color("8a6a40"))
				d.box(Vector3(5.0, 0.15, 0.15), mp + Vector3(0, y, -1.7), Color("8a6a40"))
				d.box(Vector3(0.15, 0.15, 5.0), mp + Vector3(1.7, y, 0), Color("8a6a40"))
				d.box(Vector3(0.15, 0.15, 5.0), mp + Vector3(-1.7, y, 0), Color("8a6a40"))
				y += 4.0
			d.box(Vector3(0.3, 4.0, 0.3), mp + Vector3(1.0, h + 8.0, 0), Color("6a4a2c"), Vector3(0, 0, 20))
			d.box(Vector3(0.3, 4.0, 0.3), mp + Vector3(-1.0, h + 8.0, 0), Color("6a4a2c"), Vector3(0, 0, -20))
		else:
			d.cyl(1.5, 6.0, mp + Vector3(0, h + 3.0, 0), Color("5a6470"), Vector3.ZERO, 10, 0.05)
			d.cyl(2.2, 0.8, mp + Vector3(0, h * 0.75, 0), Color("d8d0c0"), Vector3.ZERO, 10)
	# Kubbenin çevresinde iskele halkası
	for k in 16:
		var a := k * TAU / 16.0
		d.cyl(0.14, 10.0, u + Vector3(cos(a) * 13.5, 20.0, sin(a) * 13.5), Color("8a6a40"), Vector3.ZERO, 4)
	# Eski Cami (1414): dokuz kubbeli kare, bir minare
	var e := Vector3(70.0, 0.0, 120.0)
	d.box(Vector3(40.0, 13.0, 40.0), e + Vector3(0, 6.5, 0), Color("d8c8a8"))
	for k in 9:
		d.ball(6.0, e + Vector3(-12.5 + (k % 3) * 12.5, 13.0, -12.5 + (k / 3) * 12.5), C_LEAD, Vector3(1.0, 0.62, 1.0), 10)
	d.cyl(1.3, 40.0, e + Vector3(21.0, 20.0, -21.0), Color("e8e0d0"), Vector3.ZERO, 10)
	d.cyl(1.4, 5.0, e + Vector3(21.0, 42.5, -21.0), Color("5a6470"), Vector3.ZERO, 10, 0.05)
	d.cyl(2.0, 0.7, e + Vector3(21.0, 31.0, -21.0), Color("d8d0c0"), Vector3.ZERO, 10)
	# Muradiye (1436): doğuda tepede, iki kubbe ve minare
	var mu := Vector3(230.0, 26.0, -30.0)
	d.box(Vector3(28.0, 10.0, 18.0), mu + Vector3(0, 5.0, 0), Color("e0d4bc"))
	d.ball(6.0, mu + Vector3(-6.0, 10.0, 0), C_LEAD, Vector3(1.0, 0.65, 1.0), 10)
	d.ball(6.0, mu + Vector3(6.0, 10.0, 0), C_LEAD, Vector3(1.0, 0.65, 1.0), 10)
	d.cyl(1.1, 30.0, mu + Vector3(15.0, 15.0, 8.0), Color("e8e0d0"), Vector3.ZERO, 10)
	d.cyl(1.2, 4.0, mu + Vector3(15.0, 32.0, 8.0), Color("5a6470"), Vector3.ZERO, 10, 0.05)
	d.build(self)
	# Muradiye tepesi ve ufuktaki tepeler
	Props.ball(self, 70.0, Vector3(230.0, -38.0, -30.0), Color("8a9a62"), Vector3(1.6, 0.9, 1.3), 12)
	Scenery.hills(self, Vector3.ZERO, 520.0, 14, Color("8a9468"), 1444)
	# Şehir: damlar ve serviler (saray duvarlarının dışında)
	var xs: Array = []
	var cys: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 1432
	for i in 260:
		var p := Vector3(rng.randf_range(-330.0, 330.0), 0.0, rng.randf_range(-330.0, 330.0))
		if absf(p.x) < WALL_X + 14.0 and p.z > WALL_Z0 - 14.0 and p.z < WALL_Z1 + 14.0:
			continue
		if p.distance_to(u) < 40.0 or p.distance_to(e) < 34.0:
			continue
		if rng.randf() < 0.18:
			cys.append(Transform3D(Basis().scaled(Vector3.ONE * rng.randf_range(1.0, 1.4)), p))
		else:
			xs.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(4.0, 7.0)), p))
	Scenery.scatter(self, Scenery.house_mesh(), xs, [], Scenery._vc_mat())
	Scenery.scatter(self, Scenery.cypress_mesh(), cys, [], Scenery._vc_mat())
	for k in 4:
		Scenery.smoke_column(self, Vector3(rng.randf_range(-260.0, 260.0), 4.0, rng.randf_range(80.0, 280.0)))
