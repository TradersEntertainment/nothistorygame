extends Node3D
## Bölüm 24 — Alametler (Tolga · 24–25 Mayıs 1453, Konstantinopolis). docs/SIEGE.md §3.
##
## Hodegetria ikonası şehirde gezdirilir; fırtına ve dolu başlar, ikona taşıyıcısından kayar (kaynaklarda
## 23–24 Mayıs). Ertesi gün şehir sise gömülür, akşam Ayasofya'nın kubbesinde kızıl bir ışık görülür.
## Oynanış 1: Tolga sedyenin arka sırığını taşır; rüzgâra karşı denge (A/D). Ne yaparsa yapsın ikona bir an kayar
##   (tarih inatçıdır; bu espri konusu değildir). Sonra selde kalan bir çocuğu saçak altına götürür.
## Oynanış 2: Sisli şehir, tırmanma açık. Akşam kubbede ışık: tespit karesi. Tolga'nın feneri kapalıdır.
##   24.1 Çocuk saçağa alındı · 24.2 Çocuğa yetişilemedi, kendi koştu
## Perde II'de Niko'yla dost olunduysa (niko_friend) Niko alayda Tolga'nın yanında yürür: rüzgâr vurunca sırığa omuz
## verir (sendeleme azalır). Selde saçağın önüne kapı kanadı yatırır: su geç yükselir, çocuğa yetişme süresi uzar.
## 4b.3'te tutulmayı bir ay erken gören Tolga (eclipse_seen) iki gece önceki tutulmayı anar.
##   --autotest[=late|niko|niko_slow|eclipse]   (varsayılan: 24.1; niko_slow: çocuğa Niko'suz süre dolduktan sonra varılır)

const ROUTE_A := Vector3(0.0, 0.0, -24.0)
const ROUTE_B := Vector3(0.0, 0.0, 6.0)
const SLIP_AT := 0.72
const KID_POS := Vector3(-4.2, 0.0, 2.0)
const SHELTER := Vector3(3.3, 0.0, 3.5)      # doğudaki evin (cephesi x 4.5) önünde
const DOME_LIGHT := Vector3(-14.0, 34.0, -82.0)
const DOME_TOP := Vector3(-14.0, 22.5, -82.0)
const KID_TIME := 22.0
const NIKO_TIME := 7.0                         # Niko'nun kapı kanadı: selin saçağa varması gecikir
const NIKO_SIDE := Vector3(-1.5, 0.0, 1.2)     # sedyenin arka solu, Tolga'nın solunda (sedye kuzeye bakar)
const FOG_START := Vector3(-12.0, 0.05, -44.0)

var city: ByzCity
var player: Player
var hud: Hud
var litter: Node3D
var icon: Node3D
var bearers: Array[Person] = []
var crowd: Array[Person] = []
var _cleared: Array[Person] = []
var kid: Person
## Dost Niko (niko_friend): alayda Tolga'nın yanında, selde saçağın önünde
var niko: Person
var _niko_steadied := 0         # Niko'nun omuz verdiği sert rüzgârlar
var _kid_elapsed := 0.0
var _eclipse_again := false    # 4b.3'te bir ay erken görülen tutulma anıldı
var meter: BalanceMeter
var rain: CPUParticles3D
var splash: CPUParticles3D
var hail: CPUParticles3D
var dome_light: Node3D
var phase := "intro"
var _outcome := ""
var _route := 0.0
var _balance := 0.0
var _gust := 0.0
var _gust_t := 2.0
var stumbles := 0
var _kid_follow := false
var _kid_saved := false
var _photo := ""
var cam: TespitCam
var _flash_t := 3.0
var _t := 0.0
## Sel: sokağı kaplayan bulanık su (yükselir, akar), yüzeyinde yağmur halkaları; saçak altında kuru eşik taşı
var flood: Node3D
var _water: MeshInstance3D
var _water_mat: StandardMaterial3D
var _level := 0.0
const FLOOD_TOP := 0.42


func _ready() -> void:
	GameState.snapshot(24)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	city = ByzCity.new()
	add_child(city)
	city.niko.visible = false
	if GameState.autotest and GameState.autotest_variant.begins_with("niko"):
		GameState.flags["niko_friend"] = true
	if GameState.autotest and GameState.autotest_variant == "eclipse":
		GameState.flags["eclipse_seen"] = true        # 4b.3: tutulma bir ay erken, Nisan'da görüldü
	_build()
	if GameState.flags.get("niko_friend", false):
		_build_niko()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	# Sedye: iki uzun sırık, üstünde kırmızı örtülü taht ve Hodegetria ikonası (Meryem ve Çocuk, altın zemin)
	litter = Node3D.new()
	add_child(litter)
	# Sırıklar taşıyıcıların sağ omzunda (omuz 1.43 m): eskiden 1.25 m'de gövdelerinin ortasından geçiyordu
	for sx: float in [-0.55, 0.55]:
		Props.cyl(litter, 0.05, 4.2, Vector3(sx, LITTER_Y, 0), Color("6a4a2c"), Vector3(90, 0, 0), 6)
	Props.box(litter, Vector3(1.3, 0.12, 1.4), Vector3(0, LITTER_Y + 0.05, 0), Color("7a1e24"))
	Props.box(litter, Vector3(1.32, 0.35, 1.42), Vector3(0, LITTER_Y - 0.05, 0), Color("c8a040"))
	icon = Node3D.new()
	icon.position = Vector3(0, ICON_Y, 0)
	litter.add_child(icon)
	_build_icon(icon)
	# Taşıyıcılar: üç keşiş (önde iki, arkada biri); arka sol Tolga'nın yeri. Her biri sırığı sağ omzunda taşır:
	# sırığın 0.3 m solunda durur, sağ eli sırıkta
	for spec in [Vector3(-0.55 - 0.3, 0, -1.8), Vector3(0.55 - 0.3, 0, -1.8), Vector3(0.55 - 0.3, 0, 1.8)]:
		var b := Person.new({"coat": Color("2a2226"), "pants": Color("2a2226"), "robe": Color("2a2226"), "beard": true,
			"hair": Color("3a3030"), "hat": "none"})
		b.position = spec
		b.set_meta("no_yield", true)
		b.set_meta("shoulder_load", true)
		b.set_activity("carry")
		litter.add_child(b)
		bearers.append(b)
		if spec.z > 0.0:
			b.set_meta("spk", "SPK_MONK")       # Tolga'nın yanındaki (arka sağ) keşiş konuşur
		else:
			b.set_meta("no_talk", true)
	# Alayı izleyen ve arkasından yürüyen halk
	var rng := RandomNumberGenerator.new()
	rng.seed = 24
	# Sıra sıra (4 sıra, sırada 3-4 kişi, 0.8 m arayla): alayın yolunda sedyenin 3-6 m ardından yürürler (_place_litter)
	# Litani sırası (Bizans): önde haç ve alay fenerleri, ardından buhurdanlı rahipler ve ilahi okuyan keşişler, sonra
	# ikona; halk ikonanın ardından yürür. slot.y > 0: sedyenin önü (yolun ilerisi), < 0: arkası.
	var clergy := [
		["cross", Vector2(0.0, 6.2), Color("e8e0cc")],
		["fanari", Vector2(-0.9, 5.4), Color("3a3040")], ["fanari", Vector2(0.9, 5.4), Color("3a3040")],
		["censer", Vector2(-0.55, 3.9), Color("7a2a24")], ["censer", Vector2(0.55, 3.6), Color("8a6a2e")],
		["", Vector2(-0.6, 4.7), Color("2a2226")], ["", Vector2(0.6, 4.7), Color("2a2226")],
	]
	for c: Array in clergy:
		var priest: bool = c[0] == "censer"
		var p := Person.new({"coat": c[2], "pants": Color("2a2226"), "robe": c[2], "beard": true,
			"hair": Color("3a3030").lerp(Color("8a8680"), rng.randf() * 0.6), "hat": "priest" if priest else ("none" if c[0] == "cross" else "hood")})
		p.set_meta("no_talk", true)
		p.set_meta("no_yield", true)
		p.set_meta("slot", c[1])
		add_child(p)
		if c[0] != "":
			p.equip(c[0])
		crowd.append(p)
	# Halk: tunik ve pelerin (erkek), uzun entari ve başörtüsü (kadın); yağmurda başlıklı
	var tunics := [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a"), Color("8a7a5a"), Color("4a4a5a"), Color("6a6040")]
	for i in 14:
		var woman := i % 3 == 0
		var t: Color = tunics[i % tunics.size()]
		var p := Person.new({"coat": t, "pants": Color("3a3028"), "robe": t.darkened(0.12), "skirt": woman,
			"hat": "scarf" if woman else ("hood" if i % 2 == 0 else "none"), "scarf": Color("5a4a3a").lerp(Color("8a6a5a"), (i % 4) / 3.0),
			"hair": Color("3a2a1e"), "mustache": i % 4 == 1, "beard": i % 5 == 2})
		p.set_meta("no_talk", true)
		p.set_meta("no_yield", true)      # yerini _place_litter verir
		var row := i / 4
		var in_row := mini(4, 14 - row * 4)
		p.set_meta("slot", Vector2((i % 4 - (in_row - 1) * 0.5) * 0.8 + rng.randf_range(-0.1, 0.1), -3.4 - row * 1.0 + rng.randf_range(-0.15, 0.15)))
		add_child(p)
		crowd.append(p)
	kid = Person.new({"coat": Color("c8603a"), "pants": Color("3a3a5a"), "hair": Color("5a3a1e"), "skin": Color("f0c8a0"), "child": true})
	kid.scale = Vector3.ONE * 0.6
	kid.position = KID_POS
	kid.visible = false
	kid.set_meta("no_talk", true)
	kid.set_meta("spk", "SPK_KID")
	add_child(kid)
	# Saçak (sığınak): tahta sundurma
	# Evin cephesine yaslanır: duvar tarafı yüksek, cadde tarafı alçak; iki direk cadde tarafında
	Props.box(self, Vector3(2.4, 0.12, 3.4), SHELTER + Vector3(0.1, 2.6, 0), Color("7a5634"), Vector3(0, 0, 10))
	for sz: float in [-1.5, 1.5]:
		Props.cyl(self, 0.07, 2.4, SHELTER + Vector3(-0.95, 1.2, sz), Color("5a3e26"), Vector3.ZERO, 5)
	# Kubbedeki ışık (25 Mayıs akşamı)
	dome_light = Node3D.new()
	dome_light.position = DOME_LIGHT
	dome_light.visible = false
	add_child(dome_light)
	var g := Props.ball(dome_light, 1.4, Vector3.ZERO, Color("ff3a2a"), Vector3(1.0, 0.7, 1.0), 10, 2.0)
	g.material_override = Props.mat(Color("ff3a2a"), 1.6, false, "", false)
	# Kubbeyi saran kızıl hale (ışık kubbenin üstünde görülür, sonra tepeye yükselir)
	var halo := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 8.0
	sm.height = 9.0
	halo.mesh = sm
	var hm := StandardMaterial3D.new()
	hm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hm.albedo_color = Color(1.0, 0.3, 0.2, 0.28)
	hm.cull_mode = BaseMaterial3D.CULL_DISABLED
	halo.material_override = hm
	halo.position = DOME_TOP - DOME_LIGHT
	halo.name = "Halo"
	dome_light.add_child(halo)
	var dl := OmniLight3D.new()
	dl.light_color = Color("ff5a40")
	dl.light_energy = 6.0
	dl.omni_range = 30.0
	dome_light.add_child(dl)
	meter = BalanceMeter.new()
	meter.name = "Balance"
	meter.label_text = tr("UI_CH24_BALANCE")
	meter.visible = false
	hud.add_child(meter)


## Dost Niko: şehirdeki nöbet yerinde değil (city.niko gizli kalır), alayda Tolga'nın yanında yürür.
func _build_niko() -> void:
	niko = Person.new({"face": "niko", "coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hair": Color("2a1e14"), "hat": "helm",
		"mustache": true, "beard": true, "skin": Color("d9a07a")})
	niko.set_meta("spk", "SPK_NIKO")
	niko.set_meta("no_yield", true)
	niko.set_meta("no_talk", true)
	add_child(niko)


## Niko alayda sedyenin arka solunda yürür; virajda bir evin köşesine girerse sedyeye doğru çekilir.
func _place_niko() -> void:
	var at := litter.to_global(NIKO_SIDE)
	at.y = litter.global_position.y
	var mid := litter.to_global(Vector3(-0.9, 0.0, 1.2))
	mid.y = at.y
	var prev := niko.global_position
	niko.global_position = at
	niko.global_rotation = Vector3(0, litter.global_rotation.y, 0)
	for step in 6:
		if not Unclip.in_solid(niko, niko.global_position):
			break
		niko.global_position = niko.global_position.move_toward(mid, 0.12)
	# Virajda evin köşesini kesmesin: önceki yerinden yeni yerine giden yol bir duvardan geçiyorsa sedyenin ardına
	# (alayın yoluna) geçer (WALKTHRU: niko_slow'da köşedeki evin içinden geçiyordu)
	if prev.distance_to(niko.global_position) < 1.5:
		var q := PhysicsRayQueryParameters3D.create(prev + Vector3(0, 1.0, 0), niko.global_position + Vector3(0, 1.0, 0), 1)
		var h := get_world_3d().direct_space_state.intersect_ray(q)
		if not h.is_empty() and h["collider"] is StaticBody3D and Unclip.visible_body(h["collider"]):
			niko.global_position = mid


## Hodegetria: yordamsal boyanmış pano (IconArt), iki yüzü de boyalı (alayda iki yandan görülür); yaldızlı çerçeve,
## kabaşon taşlar.
func _build_icon(root: Node3D) -> void:
	var gold := Color("c8a850")
	Props.box(root, Vector3(0.92, 1.22, 0.07), Vector3(0, 0.62, 0), Color("4a2e1c"))
	for y: float in [0.0, 1.24]:
		Props.box(root, Vector3(0.98, 0.07, 0.1), Vector3(0, y, 0), gold)
	for sx: float in [-0.47, 0.47]:
		Props.box(root, Vector3(0.07, 1.3, 0.1), Vector3(sx, 0.62, 0), gold)
	var gems := [Color("8a1a2a"), Color("1a5a4a"), Color("2a3a7a")]
	var spots := [Vector2(-0.47, 0.0), Vector2(0.47, 0.0), Vector2(-0.47, 1.24), Vector2(0.47, 1.24), Vector2(0.0, 1.24),
		Vector2(0.0, 0.0), Vector2(-0.47, 0.62), Vector2(0.47, 0.62)]
	for i in spots.size():
		for sz: float in [0.055, -0.055]:
			Props.ball(root, 0.028, Vector3(spots[i].x, spots[i].y, sz), gems[i % 3], Vector3(1, 1, 0.6), 6)
	var tex: ImageTexture = preload("res://scripts/level/icon_art.gd").hodegetria()
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.roughness = 0.45
	m.metallic_specular = 0.6
	m.emission_enabled = true
	m.emission_texture = tex
	m.emission_energy_multiplier = 0.2
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	for side: float in [1.0, -1.0]:
		var q := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(0.86, 1.14)
		q.mesh = qm
		q.material_override = m
		q.position = Vector3(0, 0.62, 0.037 * side)
		q.rotation.y = 0.0 if side > 0.0 else PI
		root.add_child(q)


## Islak zemin ve su birikintileri (fırtına): kaldırım koyulaşır ve parlar, alayın yolunda birikintiler.
var _puddles: Node3D


func _wet(on: bool) -> void:
	city.set_wet(1.0 if on else 0.0)
	if on and _puddles == null:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.2, 0.22, 0.26, 0.82)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.roughness = 0.04
		mat.metallic = 0.3
		mat.metallic_specular = 1.0
		_puddles = Node3D.new()
		add_child(_puddles)
		var rng := RandomNumberGenerator.new()
		rng.seed = 2405
		for i in 34:
			var z := rng.randf_range(-34.0, 12.0)
			var p := Vector3(_route_at(clampf((z - ROUTE_A.z) / (ROUTE_B.z - ROUTE_A.z), 0.0, 1.0)).x + rng.randf_range(-3.6, 3.6), 0.012, z)
			var d := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 1.0
			cm.bottom_radius = 1.0
			cm.height = 0.01
			cm.radial_segments = 14
			d.mesh = cm
			d.material_override = mat
			d.position = p
			var r := rng.randf_range(0.35, 1.1)
			d.scale = Vector3(r, 1.0, r * rng.randf_range(0.45, 0.85))
			d.rotation.y = rng.randf() * TAU
			d.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_puddles.add_child(d)
	if _puddles:
		_puddles.visible = on


func _storm(on: bool, hail_on := false) -> void:
	if rain == null:
		# Sağanak: yoğun, uzun izli damlalar; yerde sıçrayan damlacıklar
		rain = _particles(2800, Vector3(0.02, 1.1, 0.02), Color(0.78, 0.84, 0.95, 0.55), -40.0, 1.0)
		rain.emission_box_extents = Vector3(16, 1, 16)
		hail = _particles(160, Vector3(0.06, 0.06, 0.06), Color("f4f6fa"), -30.0, 1.4)
		splash = _particles(520, Vector3(0.035, 0.035, 0.035), Color(0.86, 0.9, 0.98, 0.6), -9.0, 0.28)
		splash.position = Vector3(0, 0.03, 0)
		splash.emission_box_extents = Vector3(11, 0.01, 11)
		splash.direction = Vector3.UP
		splash.spread = 35.0
		splash.initial_velocity_min = 0.9
		splash.initial_velocity_max = 1.7
	rain.emitting = on
	splash.emitting = on
	hail.emitting = hail_on
	_wet(on)
	Audio.ambience("amb_rain" if on else "amb_city_day")
	var e := city.get("_env") as Environment
	var sm := city.get("_sky_mat") as ProceduralSkyMaterial
	if e and on:
		e.fog_enabled = true
		e.fog_light_color = Color("5a6070")
		e.fog_density = 0.02
		e.ambient_light_color = Color("8a90a0")
	if sm and on:
		sm.sky_top_color = Color("3a4050")
		sm.sky_horizon_color = Color("6a7080")
	var sun := city.get("_sun") as DirectionalLight3D
	if sun and on:
		sun.light_energy = 0.12
		sun.shadow_enabled = false       # bulut altında keskin güneş gölgesi olmaz
	if e and on:
		e.ambient_light_energy = 0.55
		e.fog_density = 0.028


func _particles(n: int, size: Vector3, col: Color, grav: float, life: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.amount = n
	p.lifetime = life
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(14, 1, 14)
	p.position = Vector3(0, 9, 0)
	p.direction = Vector3(0.15, -1, 0)
	p.spread = 4.0
	p.initial_velocity_min = 14.0
	p.initial_velocity_max = 18.0
	p.gravity = Vector3(0, grav, 0)
	var m := BoxMesh.new()
	m.size = size
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = col
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.material = mat
	p.mesh = m
	p.emitting = false
	player.add_child(p)
	return p


## Tek harita: alay sur tarafındaki caddedeydi; sisli gün Ayasofya'nın gerçek yerinde (hub'ın Ayasofya parçası).
## Eski parça hemen ağaçtan çıkar (dünyanın paylaşılan zemin ayarları yeni parçayla karışmasın).
func _to_ayasofya() -> void:
	if city.part == "aya":
		return
	var old := city
	remove_child(old)
	old.queue_free()
	city = ByzCity.new()
	city.part = "aya"
	add_child(city)


func _fog() -> void:
	_storm(false)
	var e := city.get("_env") as Environment
	if e:
		e.fog_enabled = true
		e.fog_light_color = Color("c8c8c8")
		e.fog_density = 0.045
		e.fog_sky_affect = 0.9
		e.ambient_light_color = Color("b0b0b0")
	var sun := city.get("_sun") as DirectionalLight3D
	if sun:
		sun.light_energy = 0.4


func _evening() -> void:
	var e := city.get("_env") as Environment
	if e:
		e.fog_density = 0.012
		e.fog_light_color = Color("4a4050")
		e.ambient_light_color = Color("6a6078")
	var sm := city.get("_sky_mat") as ProceduralSkyMaterial
	if sm:
		sm.sky_top_color = Color("2a2a48")
		sm.sky_horizon_color = Color("8a5a60")
	var sun := city.get("_sun") as DirectionalLight3D
	if sun:
		sun.light_energy = 0.15


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH24_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH24_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	_clear_route()
	_place_litter(0.0)
	player.pinned = true
	player.show_remote(false)
	_seat()
	if niko:
		_place_niko()             # alay başlamadan Tolga'nın yanında (eskiden ilk adıma kadar dünya merkezindeydi)
	player.face(litter.global_position + Vector3(0, 1.6, 4.0))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D24_N_01")
	await hud.say("SPK_TOLGA", "D24_T_01")
	player.face(bearers[2].global_position + Vector3(0, 1.55, 0))
	await hud.say("SPK_MONK", "D24_M_01")
	# Bölüm 4b.3: iki gece önceki tutulmayı Tolga bir ay erken, Nisan'da surların hücresinden görmüştü
	if GameState.flags.get("eclipse_seen", false):
		_eclipse_again = true
		await hud.say("SPK_TOLGA", "D24_T_ECLIPSE")
	if niko:
		player.face(niko.global_position + Vector3(0, 1.55, 0))
		niko.talking = true
		await hud.say("SPK_NIKO", "D24_NK_01")
		niko.talking = false
		await hud.say("SPK_TOLGA", "D24_T_NK_01")
		player.face(litter.global_position + Vector3(0, 1.6, -4.0))
	Lore.scatter(self, "24")
	player.frozen = false
	phase = "carry"
	meter.visible = true
	hud.set_objective(tr("UI_OBJ24_CARRY"))
	await get_tree().create_timer(2.0).timeout
	_storm(true)
	hud.bark("SPK_MONK", "D24_M_RAIN", 3.0)
	while phase == "carry":
		await get_tree().process_frame
	await _slip()
	await _kid_step()
	await _fog_day()
	await _end_chapter()


## Alayın yolu: cadde boyunca, meydandaki çeşmenin (0, -16) doğusundan kıvrılarak geçer.
const FOUNTAIN_Z := -16.0
const LITTER_Y := 1.48          # sırıkların yüksekliği (taşıyıcının omzu)
const ICON_Y := LITTER_Y + 0.15


func _route_at(k: float) -> Vector3:
	var p := ROUTE_A.lerp(ROUTE_B, k)
	var d := (p.z - FOUNTAIN_Z) / 6.0
	# Çeşme havuzu (r 2) ile alayın en içteki sırası (1.3) arasında boşluk kalsın; en dıştaki sıra da virajın başında
	# doğudaki son evin (x 4.5, z -13.75'e kadar) köşesini sıyırmasın
	p.x += 4.0 * exp(-d * d * 2.4)
	return p


func _place_litter(k: float) -> void:
	var p := _route_at(k)
	var ahead := _route_at(minf(k + 0.01, 1.0)) - _route_at(maxf(k - 0.01, 0.0))
	litter.global_position = p
	litter.rotation.y = atan2(ahead.x, ahead.z) + PI      # sedye kuzeye bakar: önü -z
	# Sedyenin taşıyıcıları virajın başında doğudaki evin köşesine girmesin: biri bir katının içindeyse sedye batıya kayar
	for step in 6:
		var hit := false
		for b in litter.get_children():
			if b is Person and Unclip.in_solid(b, (b as Node3D).global_position):
				hit = true
				break
		if not hit:
			break
		litter.global_position.x -= 0.12
	# Ardından yürüyen halk: yolun kendisinde, kendi sıralarında (sedyeye yapışık bir blok gibi virajda tezgâhlara girmesin)
	var route_len := ROUTE_A.distance_to(ROUTE_B)
	for c in crowd:
		if not is_instance_valid(c) or not c.has_meta("slot"):
			continue
		var slot: Vector2 = c.get_meta("slot")
		var kk := k + slot.y / route_len
		var at := _route_at(clampf(kk, 0.0, 1.0)) + Vector3(0, 0, (maxf(kk - 1.0, 0.0) + minf(kk, 0.0)) * route_len)
		# Herkes alayın gittiği yöne bakar ve yürür (geri geri yürüyen yok)
		var dir := (_route_at(clampf(kk + 0.01, 0.0, 1.0)) - _route_at(clampf(kk - 0.01, 0.0, 1.0))).normalized()
		if dir.length() < 0.5:
			dir = Vector3.BACK
		var side := dir.cross(Vector3.UP).normalized()
		c.global_position = at + side * slot.x
		c.rotation.y = atan2(dir.x, dir.z)
		# Virajın iç kenarında evin köşesine giren yolun ortasına doğru çekilir
		var mid := at
		for step in 6:
			if not Unclip.in_solid(c, c.global_position):
				break
			c.global_position = c.global_position.move_toward(Vector3(mid.x, c.global_position.y, mid.z), 0.3)
	# Virajda arka arkaya iki sıradakiler birbirinin içine girmesin: 0,55 m'den yakın ikisi ayrılır
	for it in 2:
		for i in crowd.size():
			var a: Node3D = crowd[i]
			if not is_instance_valid(a) or not a.has_meta("slot"):
				continue
			for j in range(i + 1, crowd.size()):
				var b: Node3D = crowd[j]
				if not is_instance_valid(b) or not b.has_meta("slot"):
					continue
				var d := Vector3(a.global_position.x - b.global_position.x, 0, a.global_position.z - b.global_position.z)
				var l := d.length()
				if l < 0.55:
					var n := d / l if l > 0.01 else Vector3.RIGHT
					a.global_position += n * (0.55 - l) * 0.5
					b.global_position -= n * (0.55 - l) * 0.5


## Alayın yolundaki (sedyenin ve ardındaki halkın geçtiği 2.6 m'lik şerit) şehir halkı kenara çekilir: alay geçerken
## yol açılır (içlerinden geçilmesin).
func _clear_route() -> void:
	for n in get_tree().get_nodes_in_group("persons"):
		var p := n as Person
		# Şehrin kendi Niko'su bu bölümde gizli kalır (sisli günde de sokağa dönmez)
		if p == null or p in crowd or p in bearers or p == kid or p == niko or p == city.niko or litter.is_ancestor_of(p):
			continue
		var z := p.global_position.z
		var k := (z - ROUTE_A.z) / (ROUTE_B.z - ROUTE_A.z)
		if k < -0.25 or k > 1.25:
			continue
		var rx := _route_at(clampf(k, 0.0, 1.0)).x
		if absf(p.global_position.x - rx) < 2.3:
			p.visible = false
			_cleared.append(p)


func _seat() -> void:
	# Arka sol sırık (sedye kuzeye bakar: arka taraf +z); sırık Tolga'nın sağ omzunda
	player.global_position = litter.to_global(Vector3(-0.55 - 0.35, 0.05, 1.8))


func _process(delta: float) -> void:
	_t += delta
	match phase:
		"carry":
			_route = minf(_route + delta / (12.0 if GameState.autotest else 38.0), 1.0)
			_place_litter(_route)
			_seat()
			if niko:
				_place_niko()
			_gust_t -= delta
			if _gust_t <= 0.0:
				_gust_t = randf_range(1.2, 2.6)
				_gust = randf_range(-1.0, 1.0) * (0.6 + _route)
				# Niko sert rüzgârda sırığa omuz verir: rüzgârın yarısını o karşılar
				if niko and absf(_gust) > 0.8:
					_niko_steadied += 1
					if _niko_steadied == 1:
						hud.bark("SPK_NIKO", "D24_NK_GUST", 2.2)
			var input := Input.get_axis("move_left", "move_right")
			if GameState.autotest:
				input = -signf(_balance) * 0.9
			_balance += (_gust * (0.3 if niko else 0.55) + input * 1.6) * delta
			_balance = lerpf(_balance, 0.0, delta * 0.15)
			meter.value = _balance
			litter.rotation.z = _balance * 0.12
			if absf(_balance) >= 1.0:
				stumbles += 1
				_balance = signf(_balance) * 0.5
				player.shake(0.4)
				hud.bark("SPK_MONK", "D24_M_STUMBLE", 2.0)
			if _route >= SLIP_AT:
				phase = "slip"
			_lightning(delta)
		"kid":
			_lightning(delta)
			if _water_mat:
				_water_mat.uv1_offset.y -= delta * 0.08      # su sokak boyunca akar
				_water_mat.uv1_offset.x = sin(_t * 0.3) * 0.02
			player.speed_mult = 0.72 if player.global_position.y < _level + 0.1 else 1.0
			if _kid_follow:
				var to := player.global_position - kid.global_position
				to.y = 0.0
				if to.length() > 1.4:
					kid.global_position += to.normalized() * minf(to.length() - 1.2, 4.2 * delta)
					kid.rotation.y = atan2(to.x, to.z)
					# Görünen zemin (eşik taşı, basamak): oyuncunun peşinde taşın içinden geçiyordu
					var fy := Unclip.floor_y(kid, kid.global_position, 0.6, 1.0)
					if not is_nan(fy):
						kid.global_position.y = fy
				if kid.global_position.distance_to(SHELTER) < 2.2:
					_kid_saved = true
	var m := meter
	var vs := get_viewport().get_visible_rect().size
	m.position = Vector2((vs.x - m.size.x) * 0.5, vs.y - 170.0)


func _lightning(delta: float) -> void:
	if rain == null or not rain.emitting:
		return
	_flash_t -= delta
	if _flash_t > 0.0:
		return
	_flash_t = randf_range(3.0, 7.0)
	var e := city.get("_env") as Environment
	if e == null:
		return
	var was := e.ambient_light_energy
	e.ambient_light_energy = 3.0
	create_tween().tween_property(e, "ambient_light_energy", was, 0.25)
	get_tree().create_timer(0.6).timeout.connect(func(): Audio.sfx("explosion_big", -20.0, 0.45))


## Dolu ve fırtınanın doruğu: ikona taşıyıcıdan kayar. Tolga'nın dengesiyle ilgisi yoktur.
func _slip() -> void:
	player.frozen = true
	meter.visible = false
	hud.set_objective("")
	_storm(true, true)
	Audio.sfx("crowd_gasp", -2.0)
	var tw := create_tween()
	tw.tween_property(icon, "rotation:x", deg_to_rad(-70), 0.35).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(icon, "position", Vector3(0, ICON_Y - 0.3, -0.9), 0.35)
	await tw.finished
	await hud.say("SPK_MONK", "D24_M_SLIP")
	await hud.say("SPK_TOLGA", "D24_T_SLIP")
	await hud.say("SPK_NIHAT", "D24_N_SLIP")
	var tw2 := create_tween()
	tw2.tween_property(icon, "rotation:x", 0.0, 1.2)
	tw2.parallel().tween_property(icon, "position", Vector3(0, ICON_Y, 0), 1.2)
	await hud.say("SPK_MONK", "D24_M_STOP")


## Sel: sokağın bütün genişliğinde bulanık, akan su; kaldırım taşlarını ve çocuğun bileklerini örter, yükselir.
func _build_flood() -> void:
	flood = Node3D.new()
	add_child(flood)
	_water = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(26.0, 60.0)
	pm.subdivide_width = 26
	pm.subdivide_depth = 60
	_water.mesh = pm
	_water_mat = StandardMaterial3D.new()
	_water_mat.albedo_color = Color(0.45, 0.36, 0.24, 0.84)
	_water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_water_mat.roughness = 0.06
	_water_mat.metallic = 0.25
	var nt := NoiseTexture2D.new()
	nt.seamless = true
	nt.as_normal_map = true
	nt.bump_strength = 6.0
	var fn := FastNoiseLite.new()
	fn.frequency = 0.05
	nt.noise = fn
	_water_mat.normal_enabled = true
	_water_mat.normal_texture = nt
	_water_mat.normal_scale = 0.3
	_water_mat.uv1_scale = Vector3(3.0, 7.0, 1.0)
	_water.material_override = _water_mat
	_water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_water.position = Vector3(0.0, 0.02, -6.0)
	flood.add_child(_water)
	# Yağmur damlalarının su üstünde açtığı halkalar
	var rings := CPUParticles3D.new()
	rings.amount = 260
	rings.lifetime = 0.7
	rings.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rings.emission_box_extents = Vector3(12.0, 0.01, 28.0)
	rings.direction = Vector3.UP
	rings.spread = 0.0
	rings.initial_velocity_min = 0.0
	rings.initial_velocity_max = 0.0
	rings.gravity = Vector3.ZERO
	var tm := TorusMesh.new()
	tm.inner_radius = 0.07
	tm.outer_radius = 0.09
	tm.rings = 10
	tm.ring_segments = 3
	var rm := StandardMaterial3D.new()
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rm.albedo_color = Color(0.8, 0.82, 0.86, 0.55)
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tm.material = rm
	rings.mesh = tm
	var sc := Curve.new()
	sc.add_point(Vector2(0, 0.3))
	sc.add_point(Vector2(1, 2.6))
	rings.scale_amount_curve = sc
	rings.position = Vector3(0, 0.03, -6.0)
	flood.add_child(rings)
	# Saçak altındaki kuru yer: kapı önünde yüksek eşik taşı
	Props.solid(flood, Vector3(1.8, 0.5, 1.3), SHELTER + Vector3(0.2, 0.25, 0.0), Color("a8a090"))


func _set_flood(k: float) -> void:
	_level = lerpf(0.06, FLOOD_TOP, k)
	if flood:
		flood.get_child(0).position.y = _level
		flood.get_child(1).position.y = _level + 0.01


func _kid_step() -> void:
	phase = "kid"
	player.pinned = false
	_build_flood()
	_set_flood(0.0)
	var total := KID_TIME + (NIKO_TIME if niko else 0.0)
	var rise := create_tween()
	rise.tween_method(_set_flood, 0.25, 1.0, total)
	if niko:
		# Niko saçağa koşar ve önüne bir kapı kanadı yatırır: su saçağa geç gelir (katı değil: eşiğe yürünür)
		var leaf := Props.box(flood, Vector3(0.09, 0.32, 2.2), SHELTER + Vector3(-1.25, 0.12, 0.2), Color("6a4a2c"), Vector3(0, 0, -12))
		Props.box(leaf, Vector3(0.11, 0.05, 2.0), Vector3(0.0, 0.08, 0.0), Color("4a3220"))
		niko.global_position = SHELTER + Vector3(-1.4, 0, -2.2)
		niko.global_rotation = Vector3(0, 0, 0)
		niko.look_target = player
		get_tree().create_timer(3.2).timeout.connect(_niko_door_bark)
	player.global_position = litter.to_global(Vector3(-1.4, 0.05, 2.2))
	kid.visible = true
	kid.set_activity("")
	Audio.sfx("crowd_gasp", -8.0, 1.4)
	hud.bark("SPK_KID", "D24_K_HELP", 3.0)
	player.face(kid.global_position + Vector3(0, 0.9, 0))
	var body := Props.interactable(kid, "kid", Vector3(1.0, 1.6, 1.0), Vector3(0, 0.8, 0))
	Lore.scatter(self, "24")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ24_KID"), KID_POS + Vector3(0, 1.0, 0))
	var t := total
	var slow := GameState.autotest and GameState.autotest_variant == "niko_slow"
	if GameState.autotest:
		if GameState.autotest_variant == "late":
			t = 0.2
		elif not slow:
			_on_interact("kid")
			kid.global_position = SHELTER + Vector3(0.0, 0, 2.0)     # saçağın önünde (eşik taşının içinde değil)
	while t > 0.0 and not _kid_saved:
		await get_tree().process_frame
		t -= get_process_delta_time()
		_kid_elapsed += get_process_delta_time()
		# niko_slow: Niko'suz sürenin bitiminden sonra varılır (yalnız kapı kanadı sayesinde yetişilir)
		if slow and not _kid_follow and _kid_elapsed > KID_TIME + 1.5:
			_on_interact("kid")
			kid.global_position = SHELTER + Vector3(0.0, 0, 2.0)
		hud.set_chase(tr("UI_CH24_TIME") % maxi(0, int(ceil(t))), 1.0 - t / total)
		if _kid_follow:
			hud.set_objective(tr("UI_OBJ24_SHELTER"), SHELTER + Vector3(0, 1.5, 0))
	hud.set_chase("", 0.0)
	hud.set_objective("")
	player.frozen = true
	if is_instance_valid(body):
		body.queue_free()
	_kid_follow = false            # kurtarıldı ya da kaçtı: artık oyuncunun peşinden gelmez
	if _kid_saved:
		kid.global_position = SHELTER + Vector3(0.2, 0.5, 0.0)     # eşik taşının üstünde, suyun dışında
		await hud.say("SPK_KID", "D24_K_THANKS")
		await hud.say("SPK_TOLGA", "D24_T_KID")
		if niko:
			niko.talking = true
			await hud.say("SPK_NIKO", "D24_NK_SAVED")
			niko.talking = false
	else:
		kid.leave(player.global_position, 8.0, 2.0, true)
		await hud.say("SPK_TOLGA", "D24_T_KID_RAN")
		if niko:
			niko.talking = true
			await hud.say("SPK_NIKO", "D24_NK_LATE")
			niko.talking = false


## Niko'nun kapı kanadı repliği: çocuğun "Anne!" çağrısından sonra (üstüne yazılmasın), çocuk henüz alınmadıysa.
func _niko_door_bark() -> void:
	if phase == "kid" and not _kid_saved and not _kid_follow:
		hud.bark("SPK_NIKO", "D24_NK_KID", 3.5)


func _fog_day() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH24_FOG"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	player.speed_mult = 1.0
	if flood:
		flood.queue_free()
		flood = null
		_water_mat = null
	litter.visible = false
	kid.visible = false
	if niko:
		niko.visible = false          # ertesi gün Niko surda, nöbette
	for c in crowd:
		c.visible = false
	for p in _cleared:
		if is_instance_valid(p):
			p.visible = true          # alay geçti: halk sokağa döner
	_to_ayasofya()
	_fog()
	player.global_position = FOG_START
	player.face(Vector3(-14.0, 12.0, -82.0))
	# Oyun alanı: şehir sokakları ve Ayasofya avlusu (rampa kulesi, çatı: kubbedeki ışık oradan tespit edilir)
	player.enable_climb([Rect2(-36, -58, 70, 76), Rect2(-37, -105, 46, 47)])
	await hud.fade_to(0.0, 1.2)
	await hud.say("SPK_TOLGA", "D24_T_FOG")
	await hud.say("SPK_NIHAT", "D24_N_FOG")
	phase = "fog"
	Lore.scatter(self, "24")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ24_WAIT"))
	await get_tree().create_timer(2.0 if GameState.autotest else 14.0).timeout
	_evening()
	# Işık kubbenin üstünden tepesine doğru yükselir (kaynaklarda: "tepeye çıktı ve kayboldu")
	dome_light.visible = true
	dome_light.position = DOME_LIGHT + Vector3(0, -8.0, 0)
	var rise := create_tween().set_parallel()
	rise.tween_property(dome_light, "position", DOME_LIGHT, 6.0).set_trans(Tween.TRANS_SINE)
	rise.tween_property(dome_light.get_node("Halo"), "position", DOME_TOP - DOME_LIGHT, 6.0).set_trans(Tween.TRANS_SINE)
	Audio.sfx("church_bell", -6.0, 0.8)
	await hud.say("SPK_MONK", "D24_M_LIGHT")
	hud.set_objective(tr("UI_OBJ24_PHOTO"), DOME_LIGHT)
	cam = TespitCam.new(player, hud, dome_light, "siege24")
	hud.add_child(cam)
	cam.max_dist = 160.0
	cam.cone_deg = 9.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 60.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	player.disable_climb()
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D24_T_PHONE")
	await hud.say("SPK_NIHAT", "D24_N_END")
	_outcome = "24.1" if _kid_saved else "24.2"
	GameState.flags["siege_kid"] = _kid_saved
	Siege.record(24, _photo, "SIEGE_NOTE_24_%s" % _outcome.split(".")[1])


func _on_focus(id: String) -> void:
	hud.set_prompt(tr("UI_PROMPT24_KID") if id == "kid" and not _kid_follow else "")


func _on_interact(id: String) -> void:
	if id == "kid" and phase == "kid" and not _kid_follow:
		_kid_follow = true
		kid.emote("nod")
		hud.bark("SPK_TOLGA", "D24_T_TAKE_KID", 2.5)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(24, _outcome)
	await Siege.show_page(hud, 24)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(24)
			if nxt != "":
				GameState.change_scene(nxt)
			else:
				hud.set_fade(1.0)
				await hud.card([[tr("UI_SIEGE_TBC"), 30, Color("f2e6c9")], [tr("UI_SIEGE_TBC_SUB"), 18, Color(1, 1, 1, 0.7)]], 3.5)
				GameState.change_scene("res://scenes/main.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW24_TITLE")
	c.nodes = [
		{"id": "procession", "key": "FLOW24_PROCESSION", "pos": Vector2(0.5, 0.12)},
		{"id": "slip", "key": "FLOW24_SLIP", "pos": Vector2(0.5, 0.28)},
		{"id": "24.1", "key": "FLOW_24_1", "pos": Vector2(0.3, 0.46), "outcome": true},
		{"id": "24.2", "key": "FLOW_24_2", "pos": Vector2(0.7, 0.46), "outcome": true},
		{"id": "light", "key": "FLOW24_LIGHT", "pos": Vector2(0.5, 0.64)},
	]
	c.edges = [["procession", "slip"], ["slip", "24.1"], ["slip", "24.2"], ["24.1", "light"], ["24.2", "light"]]
	c.taken["procession"] = true
	c.taken["slip"] = true
	c.taken["light"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH24_STATS") % [stumbles, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "24.1", "late": "24.2"}.get(v, "24.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("24", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	# Niko yalnız dostsa alayda; niko_slow'da çocuğa Niko'suz sürenin dolmasından sonra yetişildi
	ok = ok and (niko != null) == v.begins_with("niko")
	if v == "niko_slow":
		ok = ok and _kid_elapsed > KID_TIME
	ok = ok and _eclipse_again == (v == "eclipse")
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=24 variant=%s outcome=%s stumbles=%d kid=%s niko=%s steadied=%d kid_t=%.1f" % ["PASS" if ok else "FAIL", v, _outcome,
		stumbles, _kid_saved, niko != null, _niko_steadied, _kid_elapsed])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	_place_litter(0.4)
	player.pinned = true
	_seat()
	await get_tree().create_timer(0.5).timeout
	player.face(litter.global_position + Vector3(0, 1.6, 4.0))
	_storm(true, true)
	meter.visible = true
	meter.value = 0.4
	phase = "shots"
	await get_tree().create_timer(1.2).timeout
	await _shot("c24_01_storm.png")
	hud.visible = false
	meter.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	# Alayın önünden: haç, fenerler ve rahipler önde, ardından ikona, en arkada halk
	cv.global_position = litter.global_position + Vector3(2.3, 2.3, 9.0)
	cv.look_at(litter.global_position + Vector3(0, 1.6, 0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c24_cover.png")
	player.camera.make_current()
	hud.visible = true
	meter.visible = false
	_to_ayasofya()
	_fog()
	_evening()
	dome_light.visible = true
	player.pinned = false
	litter.visible = false
	player.global_position = FOG_START
	player.face(DOME_LIGHT)
	await get_tree().create_timer(0.5).timeout
	await _shot("c24_02_dome.png")
	get_tree().quit()
