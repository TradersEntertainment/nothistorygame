extends Node3D
## Bölüm 32 (yalnız Osmanlı tarafı) — Son Gün (Tolga · 28 Mayıs 1453, Lykos vadisi, hendeğin önü). docs/OTTOMAN_STORY.md §4.
##
## Meclisten (25) sonraki gün: Sultan 28 Mayıs'ı oruç ve dinlenme günü ilan etti, ama ordu bütün gün hücuma hazırlandı.
## Bölüm 25 ile 26o arasındaki boşluğu oynanır kılar: hazırlık, son bombardıman, ışıklar ve sükût.
##   0. Şafak: tellal hücumu ilan eder (yürürken).
##   1. Hendek: yığından çalı demeti al, hendeğe at; iki demette bir sepet toprak. Surdan ok yaylımı: mantonun arkasına.
##   2. Usta Mahmud: merdivene basamak çak (işaret ortadayken E), sonra mantoyu hendeğin kıyısına it (E basılı).
##   3. Topçubaşı Ali'nin bataryası: üç atış gedikteki barikata (GunDrill + CannonCrew), aralarda namluyu soğut.
##   4. Akşam: iftar, meşaleyle hattın ateşlerini yak; Sultan ateşlerin önünden geçer (tespit karesi); "Sükût!";
##      Hasan'ın ateşi: üç seçenek (26o'nun ilk Hasan repliği buna göre).
##   32O.1 Hendek doldu, barikat yarıldı · 32O.2 Hendek yarım kaldı, gece azaplar bitirdi
##   --autotest[=late]   (varsayılan: 32O.1; =late: dört demette durur, toplar ıskalar)

const BUNDLES := 6
const PILE := Vector3(-9.0, 0.0, 54.0)
const EARTH := Vector3(9.0, 0.0, 54.0)
const EDGE_Z := 37.4
const COVERS := [Vector3(-5.0, 0.0, 43.0), Vector3(5.0, 0.0, 43.0), Vector3(0.0, 0.0, 49.0)]
const VOLLEY_EVERY := 13.0
const VOLLEY_WARN := 2.6
const DITCH_TIME := 240.0
const BENCH := Vector3(-16.0, 0.0, 66.0)
const RUNGS := 6
const MANTLET_FROM := Vector3(14.0, 0.0, 64.0)
const MANTLET_TO := Vector3(14.0, 0.0, 41.0)
const SHOTS := 3
const COOL_TIME := 2.4
const FIRE_Z := 92.0
const GREEK_TIME := 15.0
const FIRES := 6
const KADRI_POT := Vector3(-4.0, 0.0, 99.0)
const HASAN_FIRE := Vector3(20.0, 0.0, 101.0)

var walls: LandWalls
var gun: Node3D
var player: Player
var hud: Hud
var drill: GunDrill
var gun_crew: CannonCrew
var cam: TespitCam
var assault: Assault
var herald: Person
var azap: Soldier
var usta: Person
var topcu: Person
var kadri: Person
var hasan: Person
var sultan: Person
var horse: Horse
var mantlet: Node3D
var phase := "intro"
var carrying := ""
var _carry: Node3D
var bundles := 0
var earth := 0
var arrows := 0
var rungs := 0
var bad_rungs := 0
var hits := 0
var cracks := 0
var fires_lit := 0
var torch_lit := false
var hasan_choice := ""
var _outcome := ""
var _photo := ""
var _acc := 0.0
var _cool := 0.0
var _volley := VOLLEY_EVERY
var _vwarn := -1.0
var _fire_spots: Array[Node3D] = []
var _fire_lights: Array = []
var _night_env := {}
var _carriers: Array = []        # [Soldier, demet, hedef] — yan bölük demet taşır
var _pushers: Array = []         # mantoyu iten iki asker
var _fire_t := -1.0              # Rum ateşi: hendekte yanan demetler (toprak dökülmezse)
var _fire_node: Node3D
var _fire_at := Vector3.ZERO
var fires_out := 0
var fires_lost := 0
var _hammer: Node3D
var _night_lights := {}
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(32)
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	walls = LandWalls.new()
	add_child(walls)
	_save_night()
	walls.make_day()
	walls.field.bombard = true
	walls.set_repair(LandWalls.STAGES - 2)       # gedikte gece örülmüş barikat
	gun = walls.build_great_gun()
	drill = GunDrill.new()
	hud.add_child(drill)
	drill.fired.connect(func(a: float): _acc = a)
	_setup_gun_crew()
	_build_field()
	_build_people()
	_build_camp()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


## LandWalls gece kurulur; gündüze geçmeden önce gecenin ayarları saklanır (akşam geri dönülür)
func _save_night() -> void:
	if walls.env == null:
		return
	var e := walls.env.environment
	var sm := e.sky.sky_material as ProceduralSkyMaterial
	_night_env = {"top": sm.sky_top_color, "hor": sm.sky_horizon_color, "gh": sm.ground_horizon_color,
		"amb": e.ambient_light_color, "amb_e": e.ambient_light_energy, "fog": e.fog_light_color, "fog_d": e.fog_density,
		"moon_c": walls.moon.light_color, "moon_e": walls.moon.light_energy, "moon_r": walls.moon.rotation_degrees}
	for l in walls.lights:
		if l is OmniLight3D:
			_night_lights[l] = (l as OmniLight3D).light_energy


func _make_night(t: float) -> void:
	if _night_env.is_empty():
		return
	var e := walls.env.environment
	var sm := e.sky.sky_material as ProceduralSkyMaterial
	var tw := create_tween().set_parallel()
	tw.tween_property(sm, "sky_top_color", _night_env["top"], t)
	tw.tween_property(sm, "sky_horizon_color", _night_env["hor"], t)
	tw.tween_property(sm, "ground_horizon_color", _night_env["gh"], t)
	tw.tween_property(e, "ambient_light_color", _night_env["amb"], t)
	tw.tween_property(e, "ambient_light_energy", _night_env["amb_e"], t)
	tw.tween_property(e, "fog_light_color", _night_env["fog"], t)
	tw.tween_property(e, "fog_density", _night_env["fog_d"], t)
	tw.tween_property(walls.moon, "light_color", _night_env["moon_c"], t)
	tw.tween_property(walls.moon, "light_energy", _night_env["moon_e"], t)
	tw.tween_property(walls.moon, "rotation_degrees", _night_env["moon_r"], t)
	for l in _night_lights:
		if is_instance_valid(l):
			tw.tween_property(l, "light_energy", _night_lights[l], t)
	walls.field.set_mode("night")


# ================================================================ yerleşim

func _build_field() -> void:
	# Ova (hendekten ordugâha) yürünür; sınırlar görünmez
	var pad := Props.solid(self, Vector3(84, 1.2, 76), Vector3(0, -0.6, 74.0), Color("3a3e2a"))
	pad.get_child(0).visible = false
	# Yalnız hendeğin kenarı; yanlar ve arka açık: ötesi dünyanın ovası (WorldWalk)
	for spec in [[Vector3(84, 6, 0.4), Vector3(0, 3, 36.4)]]:
		var b := Props.solid(self, spec[0], spec[1], Color.WHITE)
		b.get_child(0).visible = false
		b.set_meta("no_climb", true)
		b.set_meta("ball_through", true)
		if spec[1].z == 109.0:
			_back_bar = b
	Scenery.ground_detail(self, Rect2(-38.0, 37.0, 76.0, 70.0), 520, func(_x: float, _z: float) -> float: return 0.0, Color("3a4a2a"), 3201)
	# Çalı demeti yığını ve toprak sepetleri
	var rng := RandomNumberGenerator.new()
	rng.seed = 3202
	for i in 14:
		var p := PILE + Vector3(rng.randf_range(-1.6, 1.6), 0.25 + (i / 5) * 0.4, rng.randf_range(-1.0, 1.0))
		Props.cyl(self, 0.32, 1.8, p, Color("6a5636").darkened(rng.randf_range(0.0, 0.3)), Vector3(0, rng.randf_range(-30, 30), 90), 6)
	Props.interactable(self, "pile", Vector3(3.6, 1.8, 2.6), PILE + Vector3(0, 0.9, 0))
	for i in 5:
		var p := EARTH + Vector3(-1.6 + i * 0.8, 0.0, (i % 2) * 0.6)
		Props.cyl(self, 0.32, 0.5, p + Vector3(0, 0.25, 0), Color("8a6a3a"), Vector3.ZERO, 8, 0.8)
		Props.cyl(self, 0.28, 0.06, p + Vector3(0, 0.5, 0), Color("5a4630"), Vector3.ZERO, 8)
	Props.interactable(self, "earth", Vector3(4.0, 1.6, 2.0), EARTH + Vector3(0, 0.8, 0))
	# Hendek kıyısı: buraya atılır
	Props.interactable(self, "edge", Vector3(26.0, 1.8, 1.6), Vector3(0, 0.9, EDGE_Z))
	for x in [-12.0, -6.0, 0.0, 6.0, 12.0]:
		Props.cyl(self, 0.04, 1.2, Vector3(x, 0.6, EDGE_Z + 0.4), Color("b3262d"), Vector3.ZERO, 4)
	# Mantolar (tekerlekli ahşap perde): ok yaylımında arkasına geçilir
	for c: Vector3 in COVERS:
		_mantlet(c)
	mantlet = _mantlet(MANTLET_FROM)
	Props.interactable(mantlet, "mantlet", Vector3(3.0, 2.0, 2.4), Vector3(0, 1.0, 1.2))
	Props.cyl(self, 0.05, 1.6, MANTLET_TO + Vector3(1.6, 0.8, 0), Color("e8e0d0"), Vector3.ZERO, 4)
	# Usta Mahmud'un tezgâhı: sehpalar üstünde yarım merdiven, kalas ve çivi sandığı
	for sx: float in [-1.6, 1.6]:
		Props.make_solid(Props.box(self, Vector3(0.12, 0.8, 1.0), BENCH + Vector3(sx, 0.4, 0), Color("5a4028")))
	var lad := Node3D.new()
	lad.position = BENCH + Vector3(0, 0.85, 0)
	add_child(lad)
	for sz: float in [-0.35, 0.35]:
		Props.cyl(lad, 0.05, 5.0, Vector3(0, 0, sz), Color("6a4a2c"), Vector3(0, 0, 90), 5)
	_rung_root = lad
	Props.interactable(self, "bench", Vector3(5.0, 1.6, 2.4), BENCH + Vector3(0, 0.8, 0))
	for i in 4:
		Props.box(self, Vector3(0.8, 0.12, 6.0), BENCH + Vector3(-4.5, 0.1 + i * 0.14, 0), Color("6a4a2c"), Vector3(0, 90 + i * 5.0, 0))
	# Hendekte daha önce atılmış demetler (görüntü): az ve dağınık
	for i in 10:
		Props.cyl(self, 0.3, 1.8, Vector3(rng.randf_range(-24, 24), -2.65, rng.randf_range(22.0, 34.0)), Color("5a4630"),
			Vector3(0, rng.randf_range(-40, 40), 90), 6)
	# Sancaklı ordu, bataryalar, surda savunanlar (hücum yarın: koşan dalga ve merdiven yok)
	assault = Assault.new()
	assault.keep = Rect2(-40.0, 36.4, 80.0, 72.6)
	add_child(assault)
	assault.build_calm()
	Garrison.land_walls(self, [], [], [], 3210)


var _rung_root: Node3D
var _back_bar: Node3D      # ovanın arka sınırı: topun güllesinin yolunda, batarya fazında kalkar


func _mantlet(at: Vector3) -> Node3D:
	var m := Node3D.new()
	m.position = at
	add_child(m)
	Props.make_solid(Props.box(m, Vector3(2.4, 2.0, 0.14), Vector3(0, 1.25, 0), Color("6a4a2c")))
	for y: float in [0.6, 1.9]:
		Props.box(m, Vector3(2.45, 0.12, 0.18), Vector3(0, y, 0.02), Color("4a3422"))
	for sx: float in [-1.0, 1.0]:
		Props.cyl(m, 0.22, 0.1, Vector3(sx, 0.22, 0.4), Color("3a2a1a"), Vector3(0, 0, 90), 10)
		Props.box(m, Vector3(0.08, 0.08, 0.9), Vector3(sx, 0.3, 0.4), Color("4a3422"))
	Props.box(m, Vector3(0.5, 0.5, 0.02), Vector3(0, 1.3, -0.08), Color("b3262d"))
	return m


func _build_people() -> void:
	herald = Person.new({"coat": Color("b3262d"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true, "skin": Color("d9a07a")})
	herald.set_meta("spk", "SPK_HERALD")
	herald.position = Vector3(-22.0, 0, 60.0)
	add_child(herald)
	azap = Soldier.new(Color("b3262d"), "stand", "azap")
	azap.set_meta("spk", "SPK_AZAP")
	azap.position = Vector3(2.0, 0, 46.0)
	azap.rotation.y = PI
	add_child(azap)
	usta = Person.new({"coat": Color("6a5a3a"), "pants": Color("3a3028"), "hat": "turban", "beard": true, "mustache": true,
		"hair": Color("5a5a5a"), "apron": Color("8a7050"), "skin": Color("d9a07a")})
	usta.set_meta("spk", "SPK_USTA")
	usta.position = BENCH + Vector3(0, 0, 1.6)
	usta.rotation.y = PI
	add_child(usta)
	usta.look_target = player
	topcu = Person.new({"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "bork", "mustache": true, "beard": true,
		"apron": Color("3a2a1a"), "skin": Color("c89070")})
	topcu.set_meta("spk", "SPK_TOPCU")
	topcu.position = gun.position + Vector3(4.8, 0, 4.4)
	add_child(topcu)
	topcu.look_target = player
	# Yan bölük: demet taşıyıp hendeğe atan azaplar (yürür, demet sırtında)
	for i in 4:
		var c := Soldier.new([Color("b3262d"), Color("8a6a4a"), Color("6a4a3a"), Color("b3262d")][i], "stand", "azap")
		var x: float = [-22.0, -17.0, 17.0, 22.0][i]
		c.position = Vector3(x, 0, 52.0 - i * 3.0)
		add_child(c)
		var b := Props.cyl(c, 0.28, 1.5, Vector3(0, 1.45, -0.1), Color("6a5636"), Vector3(0, 90, 90), 6)
		_carriers.append([c, b, Vector3(x, 0, EDGE_Z + 1.2)])
	for k in 2:
		var ps := Soldier.new(Color("8a6a4a"), "push", "turban" if k == 0 else "bork")
		add_child(ps)
		ps.visible = false
		_pushers.append(ps)
	for i in 3:
		var s := Soldier.new([Color("8a6a4a"), Color("6a4a3a"), Color("2f5fa8")][i], "stand", ["turban", "bork", "turban"][i])
		s.position = BENCH + Vector3(-1.4 + i * 1.4, 0, -1.4)
		add_child(s)
		s.set_activity("hammer") if s.has_method("set_activity") else null


func _build_camp() -> void:
	# Akşam yakılacak ateş yerleri: kütük yığını (sönük)
	for i in FIRES:
		var p := Vector3(-25.0 + i * 10.0, 0.0, FIRE_Z + (i % 2) * 2.0)
		var n := Node3D.new()
		n.position = p
		add_child(n)
		for k in 4:
			Props.cyl(n, 0.08, 1.0, Vector3(0, 0.12, 0), Color("4a3420"), Vector3(0, k * 45.0, 80), 5)
		Props.interactable(n, "fire_%d" % i, Vector3(1.8, 1.4, 1.8), Vector3(0, 0.7, 0))
		_fire_spots.append(n)
	kadri = Person.new({"coat": Color("e8e0d0"), "pants": Color("6a5a48"), "hat": "bork", "mustache": true, "apron": Color("f0ece0"),
		"skin": Color("d9a07a")})
	kadri.set_meta("spk", "SPK_KADRI")
	kadri.position = KADRI_POT + Vector3(1.2, 0, 0.4)
	add_child(kadri)
	kadri.look_target = player
	Props.cyl(self, 0.6, 0.7, KADRI_POT + Vector3(0, 0.55, 0), Color("2e2c2a"), Vector3.ZERO, 12, 0.8)
	_fire_lights.append(Night.campfire(self, KADRI_POT, 0.8))
	Props.interactable(self, "kadri", Vector3(2.4, 2.0, 2.4), KADRI_POT + Vector3(0, 1.0, 0))
	hasan = Person.new({"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")})
	hasan.set_meta("spk", "SPK_HASAN")
	hasan.position = HASAN_FIRE + Vector3(-1.3, 0, 0.6)
	hasan.visible = false
	add_child(hasan)
	hasan.look_target = player
	Props.interactable(hasan, "hasan", Vector3(1.4, 2.0, 1.4), Vector3(0, 1.0, 0))


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH32O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH32O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = Vector3(-14.0, 0.05, 72.0)
	player.face(Vector3(0, 4.0, 15.0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D32O_N_01")
	await hud.say("SPK_KADRI", "D32O_K_01")
	await hud.say("SPK_TOLGA", "D32O_T_01")
	await _herald()
	await _ditch()
	await _ladders()
	await _guns()
	await _evening()
	await _silence()
	await _end_chapter()


## 0. Tellal: Tolga azaba yürürken tellal hattın önünden geçer ve bağırır (yürüyüş durmaz)
func _herald() -> void:
	phase = "herald"
	player.frozen = false
	hud.set_objective(tr("UI_OBJ32O_WALK"), azap.global_position + Vector3(0, 2.0, 0))
	var tw := herald.create_tween()
	tw.tween_property(herald, "position:x", 22.0, 22.0)
	herald.rotation.y = PI * 0.5
	if herald.rig:
		herald.rig.activity = "walk"
	var t := 0.0
	var k := 0
	while player.global_position.distance_to(azap.global_position) > 3.2 or k < 3:
		await get_tree().process_frame
		t += get_process_delta_time()
		if k < 3 and t > 1.0 + k * 4.5:
			match k:
				0: hud.bark("SPK_HERALD", "D32O_TL_01", 4.2)
				1: hud.bark("SPK_HERALD", "D32O_TL_02", 4.2)
				_: hud.bark("SPK_HERALD", "D32O_TL_03", 4.2)
			k += 1
		if GameState.autotest and t > 14.0:
			player.global_position = azap.global_position + Vector3(0, 0.05, 2.4)
	hud.set_objective("")
	player.frozen = true
	player.face(azap.global_position + Vector3(0, 1.6, 0))
	await hud.say("SPK_TOLGA", "D32O_T_02")
	await hud.say("SPK_AZAP", "D32O_AZ_01")
	await hud.say("SPK_AZAP", "D32O_AZ_02")
	await hud.say("SPK_TOLGA", "D32O_T_03")


## 1. Hendek: demet ve toprak; ok yaylımında mantonun arkasına
func _ditch() -> void:
	phase = "ditch"
	_volley = 8.0
	player.frozen = false
	Lore.scatter(self, "32o")
	_update_objective()
	var t := 0.0
	var limit := DITCH_TIME
	var late := GameState.autotest_variant == "late"
	while (bundles < BUNDLES or _fire_t >= 0.0) and t < limit:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if GameState.autotest:
			await _bot_ditch(late)
			if late and bundles >= 4:
				t = limit
	_drop_carry()
	if _fire_t >= 0.0:
		_greek_fire_end(true)
	_vwarn = -1.0
	hud.set_chase("", 0.0)
	hud.set_objective("")
	player.frozen = true
	player.face(Vector3(0, -1.0, 28.0))
	if bundles >= BUNDLES:
		await hud.say("SPK_TOLGA", "D32O_T_DITCH")
	else:
		await hud.say("SPK_AZAP", "D32O_AZ_HALF")
	await hud.say("SPK_NIHAT", "D32O_N_DITCH")


## Bot: demet al → kıyıya at; iki demette bir toprak. Yaylım uyarısında en yakın mantonun arkasına geçer.
func _bot_ditch(late: bool) -> void:
	if _vwarn >= 0.0:
		var c: Vector3 = COVERS[0]
		player.global_position = c + Vector3(0, 0.05, 1.4)
		return
	if carrying == "":
		var need_earth := (bundles > 0 and bundles % 2 == 0 and earth < bundles / 2) or _fire_t >= 0.0
		player.global_position = (EARTH if need_earth else PILE) + Vector3(0, 0.05, -2.0)
		await get_tree().create_timer(0.4).timeout
		_on_interact("earth" if need_earth else "pile")
	else:
		player.global_position = Vector3(randf_range(-8, 8), 0.05, EDGE_Z + 1.4)
		await get_tree().create_timer(0.4).timeout
		_on_interact("edge")
	if late and bundles >= 4:
		return


func _update_objective() -> void:
	match phase:
		"ditch":
			var need_earth := (bundles > 0 and bundles % 2 == 0 and earth < bundles / 2) or _fire_t >= 0.0
			if carrying == "earth" and _fire_t >= 0.0:
				hud.set_objective(tr("UI_OBJ32O_FIRE"), _fire_at + Vector3(0, 2.6, 0))
			elif carrying == "bundle" or carrying == "earth":
				hud.set_objective(tr("UI_OBJ32O_DROP") % [bundles, BUNDLES] if carrying == "bundle" else tr("UI_OBJ32O_EARTH"), Vector3(0, 1.0, EDGE_Z))
			elif need_earth:
				hud.set_objective(tr("UI_OBJ32O_EARTH"), EARTH + Vector3(0, 1.2, 0))
			else:
				hud.set_objective(tr("UI_OBJ32O_BUNDLE") % [bundles, BUNDLES], PILE + Vector3(0, 1.4, 0))
		"rungs":
			hud.set_objective(tr("UI_OBJ32O_RUNG") % [rungs, RUNGS], BENCH + Vector3(0, 1.4, 0))
		"mantlet":
			hud.set_objective(tr("UI_OBJ32O_MANTLET"), mantlet.global_position + Vector3(0, 2.2, 0))
		"fires":
			if torch_lit:
				var nxt := _next_fire()
				hud.set_objective(tr("UI_OBJ32O_FIRES") % [fires_lit, FIRES], nxt.global_position + Vector3(0, 1.0, 0) if nxt else Vector3.INF)
			else:
				hud.set_objective(tr("UI_OBJ32O_IFTAR"), KADRI_POT + Vector3(0, 1.8, 0))


func _covered() -> bool:
	var p := player.global_position
	for c: Vector3 in COVERS:
		if Vector2(p.x - c.x, p.z - c.z).length() < 2.6 and p.z > c.z:
			return true
	if mantlet and Vector2(p.x - mantlet.global_position.x, p.z - mantlet.global_position.z).length() < 2.6 and p.z > mantlet.global_position.z:
		return true
	return false


func _pick(kind: String) -> void:
	if carrying != "":
		return
	carrying = kind
	_carry = Node3D.new()
	player.camera.add_child(_carry)
	match kind:
		"bundle":
			_carry.position = Vector3(0.45, -0.55, -0.9)
			Props.cyl(_carry, 0.3, 1.6, Vector3.ZERO, Color("6a5636"), Vector3(0, 70, 90), 6)
			for x: float in [-0.4, 0.4]:
				Props.cyl(_carry, 0.31, 0.06, Vector3(x * 0.34, 0, x), Color("8a7a50"), Vector3(0, 70, 90), 6)
			player.speed_mult = 0.7
			Audio.sfx("cloth", -8.0, 0.8)
		"earth":
			_carry.position = Vector3(0.35, -0.55, -0.8)
			Props.cyl(_carry, 0.26, 0.36, Vector3.ZERO, Color("8a6a3a"), Vector3.ZERO, 8, 0.8)
			Props.cyl(_carry, 0.22, 0.04, Vector3(0, 0.17, 0), Color("5a4630"), Vector3.ZERO, 8)
			player.speed_mult = 0.75
		"torch":
			_carry.position = Vector3(0.32, -0.42, -0.7)
			Props.cyl(_carry, 0.03, 0.6, Vector3.ZERO, Color("4a3020"), Vector3(-20, 0, 0), 5)
			var fl := Props.cyl(_carry, 0.07, 0.2, Vector3(0, 0.36, -0.1), Color("ffb030"), Vector3.ZERO, 5, 0.0)
			fl.material_override = Props.mat(Color("ffb030"), 3.0, false, "", false)
			var l := OmniLight3D.new()
			l.position = Vector3(0, 0.5, -0.1)
			l.light_color = Color("ff9a40")
			l.light_energy = 1.4
			l.omni_range = 7.0
			_carry.add_child(l)
	Props.strip_outlines(_carry)
	_update_objective()


func _drop_carry() -> void:
	if is_instance_valid(_carry):
		_carry.queue_free()
	_carry = null
	carrying = ""
	player.speed_mult = 1.0


## Hendeğe atılan demet/toprak: kıyıdan aşağı yuvarlanır, dipte kalır (hendek görünür biçimde dolar)
func _throw_in(kind: String) -> void:
	var x := clampf(player.global_position.x, -12.0, 12.0)
	var from := Vector3(x, 1.0, EDGE_Z - 0.4)
	var layer := (bundles + earth) / 6
	var to := Vector3(x + randf_range(-1.0, 1.0), -2.6 + layer * 0.35, randf_range(29.0, 34.0))
	var n: Node3D
	if kind == "bundle":
		n = Props.cyl(self, 0.32, 1.8, from, Color("6a5636").darkened(randf_range(0.0, 0.25)), Vector3(0, randf_range(-30, 30), 90), 6)
	else:
		n = Props.ball(self, 0.7, from, Color("6a5236"), Vector3(1.4, 0.35, 1.2), 7)
	var tw := n.create_tween()
	tw.tween_property(n, "position", to, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): Vfx.dust(self, to, 0.6))
	Audio.sfx("land_thud", -6.0, 0.8 if kind == "bundle" else 0.6)


func _on_focus(id: String) -> void:
	var k := ""
	match id:
		"pile":
			if phase == "ditch" and carrying == "":
				k = "UI_PROMPT32O_BUNDLE"
		"earth":
			if phase == "ditch" and carrying == "":
				k = "UI_PROMPT32O_EARTH"
		"edge":
			if phase == "ditch" and carrying != "":
				k = "UI_PROMPT32O_THROW"
		"bench":
			if phase == "rungs":
				k = "UI_PROMPT32O_RUNG"
		"mantlet":
			if phase == "mantlet":
				k = "UI_PROMPT32O_PUSH"
		"kadri":
			if phase == "fires" and not torch_lit:
				k = "UI_PROMPT32O_TORCH"
		"hasan":
			if phase == "hasan":
				k = "UI_PROMPT32O_HASAN"
		_:
			if id.begins_with("fire_") and phase == "fires" and torch_lit and not _fire_spots[int(id.trim_prefix("fire_"))].has_meta("lit"):
				k = "UI_PROMPT32O_FIRE"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	match id:
		"pile":
			if phase == "ditch" and carrying == "":
				var need_earth := (bundles > 0 and bundles % 2 == 0 and earth < bundles / 2) or _fire_t >= 0.0
				if need_earth:
					hud.bark("SPK_AZAP", "D32O_AZ_EARTH", 3.5)
					return
				_pick("bundle")
		"earth":
			if phase == "ditch" and carrying == "":
				_pick("earth")
		"edge":
			if phase == "ditch" and carrying != "":
				var kind := carrying
				_drop_carry()
				_throw_in(kind)
				if kind == "bundle":
					bundles += 1
					if (bundles == 3 or bundles == 5) and fires_out + fires_lost < 2:
						_greek_fire.call_deferred()
					if bundles == 1:
						hud.bark("SPK_AZAP", "D32O_AZ_B1", 3.5)
					elif bundles == 3:
						hud.bark("SPK_AZAP", "D32O_AZ_B3", 3.5)
					elif bundles == 6:
						hud.bark("SPK_AZAP", "D32O_AZ_B6", 3.5)
				elif _fire_t >= 0.0:
					_greek_fire_end(true)
				else:
					earth += 1
				_update_objective()
		"bench":
			if phase == "rungs":
				_rung_press = true
		"mantlet":
			pass
		"kadri":
			if phase == "fires" and not torch_lit:
				_drop_carry()
				_pick("torch")
				torch_lit = true
				Audio.sfx("fuse_burn", -8.0, 1.2)
				_update_objective()
		"hasan":
			if phase == "hasan":
				_hasan_go = true
		_:
			if id.begins_with("fire_") and phase == "fires" and torch_lit:
				var i := int(id.trim_prefix("fire_"))
				_light_fire(i)


func _light_fire(i: int) -> void:
	var n := _fire_spots[i]
	if n.has_meta("lit"):
		return
	n.set_meta("lit", true)
	_fire_lights.append(Night.campfire(self, n.global_position, 1.0))
	fires_lit += 1
	Audio.sfx("fuse_burn", -6.0, 0.9)
	if fires_lit == 1:
		hud.bark("SPK_TOLGA", "D32O_T_FIRE_1", 3.5)
	elif fires_lit == 3:
		hud.bark("SPK_TOLGA", "D32O_T_FIRE_3", 3.5)
		# Rüzgâr meşaleyi söndürür: Kadri'nin kazanının ateşinden yeniden yakılır
		torch_lit = false
		_drop_carry()
		Audio.sfx("whoosh_fly", -6.0, 0.6)
	elif fires_lit == FIRES:
		hud.bark("SPK_TOLGA", "D32O_T_FIRE_6", 3.5)
	_update_objective()


func _next_fire() -> Node3D:
	var best: Node3D = null
	var bd := INF
	for n in _fire_spots:
		if n.has_meta("lit"):
			continue
		var d := n.global_position.distance_to(player.global_position)
		if d < bd:
			bd = d
			best = n
	return best


func _process(delta: float) -> void:
	_t += delta
	if phase in ["herald", "ditch", "rungs", "mantlet"]:
		_update_carriers(delta)
	if phase == "mantlet" and mantlet:
		for k in _pushers.size():
			var ps: Soldier = _pushers[k]
			ps.visible = true
			ps.position = mantlet.position + Vector3(-1.6 + k * 3.2, 0, 1.0)
			ps.rotation.y = PI
	if phase != "ditch" or player.frozen:
		return
	if _fire_t >= 0.0:
		_fire_t += delta
		hud.set_qte(tr("UI_QTE32O_FIRE") % ceili(GREEK_TIME - _fire_t))
		if _fire_t >= GREEK_TIME:
			_greek_fire_end(false)
	# Ok yaylımı: uyarı → oklar oyuncunun çevresine iner; mantonun arkasında değilse yaralanır
	if _vwarn >= 0.0:
		var before := _vwarn
		_vwarn += delta
		if before < VOLLEY_WARN - Assault.VOLLEY_FLIGHT and _vwarn >= VOLLEY_WARN - Assault.VOLLEY_FLIGHT and assault:
			assault.volley(Vector3(player.global_position.x, 0.0, player.global_position.z), 7.0, 40)
		if _vwarn >= VOLLEY_WARN:
			_vwarn = -1.0
			_volley = VOLLEY_EVERY
			Audio.sfx("whoosh_fly", -4.0)
			hud.set_qte("")
			if not _covered():
				arrows += 1
				player.stagger(0.8)
				player.hurt(30.0, Vector3(player.global_position.x, 8.0, LandWalls.OUTER_Z1))
				hud.bark("SPK_TOLGA", "D32O_T_HIT_1" if arrows == 1 else "D32O_T_HIT_2", 3.0)
				if carrying == "bundle" and player.is_down:
					_drop_carry()
					hud.bark("SPK_AZAP", "D32O_AZ_DOWN", 3.0)
			else:
				hud.bark("SPK_AZAP", "D32O_AZ_SAFE", 2.5)
	else:
		_volley -= delta
		if _volley <= 0.0:
			_vwarn = 0.0
			hud.set_qte(tr("UI_OBJ32O_COVER"))
			hud.bark("SPK_AZAP", "D32O_AZ_VOLLEY", VOLLEY_WARN)


## Yan bölüğün demet taşıyanları: yığından kıyıya yürür, demeti atar (demet hendeğe yuvarlanır), boş döner
func _update_carriers(delta: float) -> void:
	for c: Array in _carriers:
		var s: Soldier = c[0]
		var bundle: Node3D = c[1]
		var goal: Vector3 = c[2]
		var d := goal - s.position
		d.y = 0.0
		if d.length() < 0.3:
			if bundle.visible:
				bundle.visible = false
				var n := Props.cyl(self, 0.3, 1.6, s.position + Vector3(0, 1.4, -0.6), Color("6a5636"), Vector3(0, randf_range(-30, 30), 90), 6)
				var to := Vector3(s.position.x + randf_range(-1, 1), -2.6, randf_range(29.0, 34.0))
				var tw := n.create_tween()
				tw.tween_property(n, "position", to, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				c[2] = Vector3(s.position.x, 0, 54.0)
			else:
				bundle.visible = true
				c[2] = Vector3(s.position.x, 0, EDGE_Z + 1.2)
			continue
		var step := d.normalized() * minf(d.length(), (1.3 if bundle.visible else 1.9) * delta)
		s.position += step
		s.rotation.y = atan2(step.x, step.z)


## Rum ateşi: surdan atılan çömlek hendekteki demetleri tutuşturur; GREEK_TIME içinde üstüne toprak dökülmezse
## son iki demet yanar (hendek geri boşalır)
func _greek_fire() -> void:
	if _fire_t >= 0.0:
		return
	_fire_t = 0.0
	_fire_at = Vector3(clampf(player.global_position.x, -10.0, 10.0), -2.4, 31.0)
	# Çömlek surdan yay çizerek gelir
	var pot := Props.ball(self, 0.22, Vector3(_fire_at.x, LandWalls.OUTER_H + 1.5, LandWalls.OUTER_Z1), Color("6a4a2a"), Vector3.ONE, 8)
	var tw := pot.create_tween()
	tw.tween_property(pot, "position", _fire_at, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		pot.queue_free()
		Audio.sfx("explosion_small", -4.0, 0.8)
		Vfx.explosion(self, _fire_at + Vector3(0, 0.4, 0), 0.7)
		_fire_node = Node3D.new()
		add_child(_fire_node)
		_fire_node.global_position = _fire_at
		for k in 3:
			Night.campfire(_fire_node, Vector3(-1.2 + k * 1.2, 0, randf_range(-0.6, 0.6)), 1.6)
		Vfx.smolder(self, _fire_at, 2.0, true))
	hud.bark("SPK_AZAP", "D32O_AZ_GREEKFIRE", 4.0)
	Audio.stinger("warn", -2.0)
	_update_objective()


func _greek_fire_end(out: bool) -> void:
	_fire_t = -1.0
	hud.set_qte("")
	if is_instance_valid(_fire_node):
		if out:
			Vfx.steam(self, _fire_at + Vector3(0, 0.6, 0))
			Vfx.dust(self, _fire_at, 1.2)
			_fire_node.queue_free()
		else:
			var tw := _fire_node.create_tween()
			tw.tween_interval(6.0)
			tw.tween_callback(_fire_node.queue_free)
	if out:
		fires_out += 1
		hud.bark("SPK_AZAP", "D32O_AZ_FIRE_OUT", 3.5)
	else:
		fires_lost += 1
		bundles = maxi(0, bundles - 2)
		hud.bark("SPK_AZAP", "D32O_AZ_FIRE_LOST", 3.5)
	_update_objective()


# ---------------------------------------------------------------- 2. merdiven ve manto

var _rung_press := false


func _ladders() -> void:
	await hud.fade_to(1.0, 0.5)
	player.global_position = BENCH + Vector3(0.4, 0.05, 4.0)
	player.face(usta.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.5)
	await hud.say("SPK_USTA", "D32O_U_01")
	await hud.say("SPK_TOLGA", "D32O_T_U1")
	await hud.say("SPK_USTA", "D32O_U_02")
	var limp: bool = String(GameState.chapter_outcomes.get(22, "")).ends_with("2") if "chapter_outcomes" in GameState else false
	hud.bark("SPK_SOLDIER", "D32O_S_CARP_LIMP" if limp else "D32O_S_CARP", 4.0)
	phase = "rungs"
	player.frozen = false
	_update_objective()
	var t := 0.0
	while rungs < RUNGS:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var near := player.global_position.distance_to(BENCH) < 4.5
		# İşaret: çivi yeri gidip gelir; ortadayken E
		var v := 0.5 + 0.5 * sin(t * 3.2)
		var good := absf(v - 0.5) < 0.14
		if near:
			hud.set_qte(tr("UI_QTE32O_RUNG") + "  " + _meter(v))
		else:
			hud.set_qte("")
		if GameState.autotest:
			_rung_press = good and fmod(t, 0.9) < dt * 3.0
		if _rung_press and near:
			_rung_press = false
			_swing_hammer()
			if good:
				Props.box(_rung_root, Vector3(0.05, 0.05, 0.75), Vector3(-2.2 + rungs * 0.85, 0.0, 0), Color("6a4a2c").darkened(0.1))
				rungs += 1
				Audio.sfx("pick_tap", -4.0, 1.0)
				if rungs == 3:
					hud.bark("SPK_USTA", "D32O_U_RUNG_OK", 3.0)
			else:
				bad_rungs += 1
				Audio.sfx("kick_metal", -8.0, 1.3)
				hud.bark("SPK_USTA", "D32O_U_RUNG_BAD", 3.0)
			_update_objective()
		_rung_press = false
	hud.set_qte("")
	if is_instance_valid(_hammer):
		_hammer.queue_free()
	player.frozen = true
	await hud.say("SPK_USTA", "D32O_U_CARRY")
	# Biten merdivenler bölükçe kıyıya taşınır (görüntü), sonra manto
	await hud.say("SPK_USTA", "D32O_U_MANTLET")
	await hud.say("SPK_TOLGA", "D32O_T_MANTLET")
	phase = "mantlet"
	player.frozen = false
	_update_objective()
	t = 0.0
	while mantlet.global_position.z > MANTLET_TO.z + 0.2:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var behind := player.global_position.z > mantlet.global_position.z and \
			Vector2(player.global_position.x - mantlet.global_position.x, player.global_position.z - mantlet.global_position.z).length() < 3.0
		hud.set_prompt(tr("UI_PROMPT32O_PUSH") if behind else "")
		if GameState.autotest:
			player.global_position = mantlet.global_position + Vector3(0, 0.05, 1.8)
			behind = true
		if behind and (Input.is_action_pressed("interact") or GameState.autotest):
			mantlet.global_position.z -= 1.4 * dt
			if fmod(t, 0.5) < dt:
				Audio.sfx("wood_creak", -10.0, randf_range(0.9, 1.1))
		hud.set_chase(tr("UI_CH32O_MANTLET"), 1.0 - (mantlet.global_position.z - MANTLET_TO.z) / (MANTLET_FROM.z - MANTLET_TO.z))
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_objective("")
	player.frozen = true
	for ps in _pushers:
		(ps as Soldier).pose = "stand"
	await hud.say("SPK_USTA", "D32O_U_END")


func _swing_hammer() -> void:
	if not is_instance_valid(_hammer):
		_hammer = Node3D.new()
		_hammer.position = Vector3(0.38, -0.42, -0.75)
		player.camera.add_child(_hammer)
		Props.cyl(_hammer, 0.025, 0.42, Vector3(0, 0.12, 0), Color("6a4a2c"), Vector3.ZERO, 5)
		Props.box(_hammer, Vector3(0.16, 0.07, 0.07), Vector3(0, 0.34, 0), Color("4a4a50"))
		Props.strip_outlines(_hammer)
	var tw := _hammer.create_tween()
	tw.tween_property(_hammer, "rotation:x", deg_to_rad(-70.0), 0.08)
	tw.tween_property(_hammer, "rotation:x", deg_to_rad(15.0), 0.07)
	tw.tween_property(_hammer, "rotation:x", 0.0, 0.18)
	player.shake(0.15)


func _meter(v: float) -> String:
	var n := 13
	var at := int(round(v * (n - 1)))
	var s := "["
	for i in n:
		if i == at:
			s += "●"
		elif i >= 5 and i <= 7:
			s += "▮"
		else:
			s += "·"
	return s + "]"


# ---------------------------------------------------------------- 3. son gülleler

func _setup_gun_crew() -> void:
	gun_crew = CannonCrew.new()
	add_child(gun_crew)
	gun_crew.player = player
	gun_crew.hud = hud
	gun_crew.pivot = gun.get_node("Pivot")
	gun_crew.muzzle = gun.get_node("Pivot/Muzzle")
	gun_crew.recoil_node = gun
	gun_crew.aim_spot = gun.to_global(Vector3(0, 0, 8.5))
	gun_crew.aim_back = 13.5
	gun_crew.supplies = {"powder": gun.to_global(Vector3(-2.7, 0, 2.2)), "ball": gun.to_global(Vector3(3.8, 0, -0.5)),
		"wad": gun.to_global(Vector3(-2.8, 0, 5.6)), "rammer": gun.to_global(Vector3(2.8, 0, 5.6))}
	gun_crew.spawn = ["wad"]
	gun_crew.target = func() -> Vector3: return LandWalls.BREACH + Vector3(0, 4.0, 0)
	gun_crew.hit_radius = 5.0
	gun_crew.tolerance = 16.0
	gun_crew.ground_y = 0.0
	gun_crew.load_radius = 3.2
	gun_crew.design_elev = 5.0
	gun_crew.pitch_min = -2.0
	gun_crew.pitch_max = 14.0
	gun_crew.yaw_limit = 6.0
	gun_crew.before_fire = func():
		await get_tree().create_timer(walls.gun_screen(true, 0.7 if not GameState.autotest else 0.02)).timeout
		walls.fire_flash()
	gun_crew.after_fire = func():
		pass
	gun_crew.setup()
	drill.bind(gun_crew)


func _guns() -> void:
	phase = "guns"
	await hud.fade_to(1.0, 0.6)
	await hud.card([[tr("UI_CH32O_AFTERNOON"), 26, Color("f2e6c9")]], 1.6)
	hud.clear_card()
	walls.make_dawn(0.01)
	if is_instance_valid(_back_bar):
		_back_bar.queue_free()
	player.global_position = gun.position + Vector3(1.8, 0.05, 9.2)
	player.face(topcu.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.6)
	await hud.say("SPK_TOPCU", "D32O_TP_01")
	await hud.say("SPK_TOLGA", "D32O_T_TP1")
	await hud.say("SPK_TOPCU", "D32O_TP_02")
	await hud.say("SPK_TOPCU", "D32O_TP_URBAN")
	var late := GameState.autotest_variant == "late"
	for shot in SHOTS:
		phase = "drill"
		player.global_position = gun.position + Vector3(3.0, 0.05, 6.0)
		player.face(LandWalls.BREACH + Vector3(0, 4.0, 0))
		hud.set_objective(tr("UI_OBJ32O_LOAD") % [shot + 1, SHOTS])
		drill.start(0.25 + shot * 0.1, 0.16)
		while drill.active:
			await get_tree().process_frame
		if GameState.autotest and late:
			_acc = 0.2
		hud.set_objective("")
		await _fire()
		if shot < SHOTS - 1:
			await _cool_step()
	await hud.say("SPK_TOPCU", "D32O_TP_END_OK" if hits >= 2 else "D32O_TP_END_BAD")
	await hud.say("SPK_TOLGA", "D32O_T_GUNS")


func _fire() -> void:
	if not drill.physical:
		walls.fire_flash()
		Audio.sfx("cannon", 2.0, 0.75)
		Vfx.explosion(self, gun.position + Vector3(0, 1.6, -5.0), 1.6)
		player.shake(1.0)
		await get_tree().create_timer(1.6).timeout
	var hit := _acc >= 0.5
	var at := LandWalls.BREACH + Vector3(randf_range(-1.5, 1.5) if hit else randf_range(-14, 14), 3.0 if hit else 1.0, 1.2 if hit else 6.0)
	if drill.physical and drill.last_impact != Vector3.INF:
		at = drill.last_impact
	walls.impact(at)
	Audio.sfx("explosion_big", -8.0)
	if hit:
		hits += 1
		walls.set_repair(maxi(0, LandWalls.STAGES - 2 - hits * 3))
		await hud.say("SPK_TOPCU", "D32O_TP_HIT_1" if hits == 1 else "D32O_TP_HIT_2")
	else:
		await hud.say("SPK_TOPCU", "D32O_TP_MISS")


func _cool_step() -> void:
	phase = "cool"
	_cool = 0.0
	player.frozen = false
	hud.set_objective(tr("UI_OBJ32O_COOL"), gun.global_position + Vector3(0, 2.4, 0))
	await hud.say("SPK_TOPCU", "D32O_TP_COOL")
	var t := 0.0
	while _cool < COOL_TIME and t < 10.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var near := player.global_position.distance_to(gun.global_position + Vector3(0, 0, -1.0)) < 5.0
		hud.set_prompt(tr("UI_PROMPT20O_COOL") if near else "")
		if (near and Input.is_action_pressed("interact")) or GameState.autotest:
			_cool += dt
			if fmod(_cool, 0.4) < dt:
				Vfx.steam(self, gun.global_position + Vector3(randf_range(-0.6, 0.6), 2.6, randf_range(-3.0, 1.0)))
		hud.set_chase(tr("UI_CH20O_COOL"), _cool / COOL_TIME)
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_objective("")
	player.frozen = true
	if _cool < COOL_TIME:
		cracks += 1
		Audio.sfx("kick_metal", -4.0, 0.6)
		await hud.say("SPK_URBAN", "D20O_U_CRACK")


# ---------------------------------------------------------------- 4. iftar, ateşler, Sultan

func _evening() -> void:
	phase = "fires"
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH32O_DUSK"), 26, Color("f2e6c9")]], 1.6)
	hud.clear_card()
	walls.field.bombard = false
	_make_night(0.01)
	player.global_position = KADRI_POT + Vector3(0, 0.05, -3.0)
	player.face(kadri.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_KADRI", "D32O_K_IFTAR")
	await hud.say("SPK_TOLGA", "D32O_T_IFTAR")
	hud.bark("SPK_HERALD", "D32O_TL_04", 4.0)
	player.frozen = false
	_update_objective()
	var t := 0.0
	var limit := 120.0
	while fires_lit < FIRES and t < limit:
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest and fmod(t, 0.8) < get_process_delta_time() * 3.0:
			if not torch_lit:
				_on_interact("kadri")
			else:
				var n := _next_fire()
				if n:
					player.global_position = n.global_position + Vector3(0, 0.05, 1.8)
					_on_interact("fire_%d" % _fire_spots.find(n))
	# Yakılmayanları yan bölük yakar
	for i in FIRES:
		if not _fire_spots[i].has_meta("lit"):
			_fire_spots[i].set_meta("lit", true)
			_fire_lights.append(Night.campfire(self, _fire_spots[i].global_position, 1.0))
	hud.set_objective("")
	_drop_carry()
	Audio.intensity(1, "walls_night")
	await hud.say("SPK_NIHAT", "D32O_N_LIGHTS")
	await _sultan()


func _sultan() -> void:
	phase = "sultan"
	horse = Horse.new(Color("e4e0d8"))
	add_child(horse)
	sultan = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	sultan.set_meta("spk", "SPK_FATIH")
	horse.mount(sultan)
	var from := Vector3(-34.0, 0.0, FIRE_Z - 3.5)
	var to := Vector3(34.0, 0.0, FIRE_Z - 3.5)
	horse.position = from
	horse.rotation.y = PI * 0.5
	var guards: Array = []
	for k in 2:
		var g := Soldier.new(Color("b3262d"), "stand", "bork")
		g.position = from + Vector3(-2.0 - k * 1.6, 0, -1.2 + k * 2.4)
		g.rotation.y = PI * 0.5
		add_child(g)
		g.equip("spear")
		guards.append(g)
	hud.bark("SPK_SOLDIER", "D32O_S_SULTAN", 3.0)
	var target := Node3D.new()
	sultan.add_child(target)
	target.position = Vector3(0, 1.4, 0)
	hud.set_objective(tr("UI_OBJ32O_PHOTO"), from + Vector3(0, 2.6, 0))
	cam = TespitCam.new(player, hud, target, "siege32o")
	hud.add_child(cam)
	cam.max_dist = 40.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var dur := 26.0
	var t := 0.0
	var said := 0
	horse.speed = 1.4
	while t < dur:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var p := from.lerp(to, t / dur)
		horse.position = p
		for k in guards.size():
			(guards[k] as Node3D).position = p + Vector3(-2.0 - k * 1.6, 0, -1.2 + k * 2.4)
		hud.set_objective(tr("UI_OBJ32O_PHOTO"), p + Vector3(0, 2.6, 0))
		if said == 0 and t > 4.0:
			hud.bark("SPK_FATIH", "D32O_F_01", 5.0)
			said = 1
		elif said == 1 and t > 11.0:
			hud.bark("SPK_FATIH", "D32O_F_02", 5.0)
			said = 2
		if GameState.autotest and t > 7.0 and not cam.done:
			player.global_position = p + Vector3(0, 0.05, 8.0)
			player.face(p + Vector3(0, 2.0, 0))
		if cam.done and t > 14.0:
			break
	horse.speed = 0.0
	cam.stop()
	hud.set_objective("")
	player.frozen = true
	if not _photo.is_empty():
		await hud.say("SPK_NIHAT", "D32O_N_PHOTO")
	var met: bool = "chapter_outcomes" in GameState and (GameState.chapter_outcomes as Dictionary).has(12)
	await hud.say("SPK_TOLGA", "D32O_T_SULTAN" if met else "D32O_T_SULTAN_ALT")
	for g in guards:
		g.queue_free()
	horse.queue_free()


var _hasan_go := false


## Sükût: ateşler kısılır, ordu susar. Hasan'ın ateşi; seçim 26o'nun ilk Hasan repliğini belirler.
func _silence() -> void:
	phase = "silence"
	await hud.say("SPK_JANISSARY", "D32O_J_SILENCE")
	var tw := create_tween().set_parallel()
	for l in _fire_lights:
		if is_instance_valid(l):
			tw.tween_property(l, "light_energy", (l as OmniLight3D).light_energy * 0.25, 2.5)
	Audio.intensity(0, "walls_night")
	Audio.sfx("church_bell", -18.0, 0.9)
	await hud.say("SPK_NIHAT", "D32O_N_SILENCE")
	_hasan_fire = Night.campfire(self, HASAN_FIRE, 0.7)
	hasan.visible = true
	hasan.set_activity("sit_ground")
	phase = "hasan"
	player.frozen = false
	hud.set_objective(tr("UI_OBJ32O_HASAN"), hasan.global_position + Vector3(0, 1.4, 0))
	var t := 0.0
	while not _hasan_go and player.global_position.distance_to(hasan.global_position) > 2.6:
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest and t > 1.0:
			player.global_position = hasan.global_position + Vector3(1.6, 0.05, 1.0)
	hud.set_objective("")
	hud.set_prompt("")
	player.frozen = true
	player.face(hasan.global_position + Vector3(0, 0.9, 0))
	await hud.say("SPK_HASAN", "D32O_H_01")
	await hud.say("SPK_TOLGA", "D32O_T_H1")
	await hud.say("SPK_HASAN", "D32O_H_02")
	await hud.say("SPK_HASAN", "D32O_H_03")
	# Cebinde leblebi yoksa leblebi seçeneği de yok
	var ids := ["water", "leb", "sit"] if "chickpeas" in GameState.bag else ["water", "sit"]
	var keys := []
	for id in ids:
		keys.append("UI_C32O_" + id.to_upper())
	var pick := await hud.choose(keys, 0.0, 0)
	hasan_choice = ids[clampi(pick, 0, ids.size() - 1)]
	GameState.flags["hasan_night"] = hasan_choice
	match hasan_choice:
		"water":
			await hud.say("SPK_TOLGA", "D32O_T_WATER")
			await hud.say("SPK_HASAN", "D32O_H_WATER")
		"leb":
			await hud.say("SPK_TOLGA", "D32O_T_LEB")
			await hud.say("SPK_HASAN", "D32O_H_LEB")
		_:
			await hud.say("SPK_TOLGA", "D32O_T_SIT")
			await hud.say("SPK_HASAN", "D32O_H_SIT")
	await hud.say("SPK_HASAN", "D32O_H_04")
	await hud.say("SPK_TOLGA", "D32O_T_END")
	await hud.say("SPK_HASAN", "D32O_H_GO")
	await hud.say("SPK_NIHAT", "D32O_N_END")
	var ok := bundles >= BUNDLES and hits >= 2
	_outcome = "32O.1" if ok else "32O.2"
	Siege.record(32, _photo, "SIEGE_NOTE_32O_%s" % _outcome.split(".")[1])


var _hasan_fire: OmniLight3D


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(32, _outcome)
	await Siege.show_page(hud, 32)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(32)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW32O_TITLE")
	c.nodes = [
		{"id": "herald", "key": "FLOW32O_HERALD", "pos": Vector2(0.5, 0.1)},
		{"id": "ditch", "key": "FLOW32O_DITCH", "pos": Vector2(0.5, 0.2)},
		{"id": "ladder", "key": "FLOW32O_LADDER", "pos": Vector2(0.5, 0.3)},
		{"id": "guns", "key": "FLOW32O_GUNS", "pos": Vector2(0.5, 0.4)},
		{"id": "lights", "key": "FLOW32O_LIGHTS", "pos": Vector2(0.5, 0.5)},
		{"id": "silence", "key": "FLOW32O_SILENCE", "pos": Vector2(0.5, 0.6)},
		{"id": "32O.1", "key": "FLOW_32O_1", "pos": Vector2(0.3, 0.72), "outcome": true},
		{"id": "32O.2", "key": "FLOW_32O_2", "pos": Vector2(0.7, 0.72), "outcome": true},
	]
	c.edges = [["herald", "ditch"], ["ditch", "ladder"], ["ladder", "guns"], ["guns", "lights"], ["lights", "silence"],
		["silence", "32O.1"], ["silence", "32O.2"]]
	for k in ["herald", "ditch", "ladder", "guns", "lights", "silence"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		Grade.finish("32o"),
		tr("UI_CH32O_STATS") % [bundles, BUNDLES, hits, SHOTS, arrows, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "32O.1", "late": "32O.2"}.get(v, "32O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("32", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	ok = ok and rungs == RUNGS and mantlet.global_position.z <= MANTLET_TO.z + 0.3 and fires_lit == FIRES
	ok = ok and hasan_choice == "water" and GameState.flags.get("hasan_night", "") == "water"
	if v == "":
		ok = ok and bundles == BUNDLES and earth >= 2 and arrows == 0 and hits >= 2 and fires_out == 2 and fires_lost == 0
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s basamak=%d ateş=%d demet=%d toprak=%d ok=%d isabet=%d)" % [expected, _outcome,
			not page.is_empty(), cam != null and cam.done, rungs, fires_lit, bundles, earth, arrows, hits])
	print("AUTOTEST %s chapter=32o variant=%s outcome=%s bundles=%d/%d earth=%d arrows=%d rungs=%d bad=%d hits=%d/%d fires=%d greek=%d/%d hasan=%s" % [
		"PASS" if ok else "FAIL", v, _outcome, bundles, BUNDLES, earth, arrows, rungs, bad_rungs, hits, SHOTS, fires_lit,
		fires_out, fires_out + fires_lost, hasan_choice])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot_png(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	phase = "ditch"
	player.global_position = PILE + Vector3(3.0, 0.05, -6.0)
	await get_tree().create_timer(0.8).timeout
	_pick("bundle")
	player.face(Vector3(0, 0.0, 30.0))
	_update_objective()
	await _shot_png("c32o_01_ditch.png")
	_drop_carry()
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(-10.0, 4.5, 50.0)
	cv.look_at(Vector3(2.0, 0.0, 30.0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await get_tree().create_timer(0.3).timeout
	await _shot_png("c32o_cover.png")
	# Gece: ateşler ve Sultan
	_make_night(0.01)
	walls.field.bombard = false
	for i in FIRES:
		_light_fire_quiet(i)
	horse = Horse.new(Color("e4e0d8"))
	add_child(horse)
	sultan = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	horse.mount(sultan)
	horse.position = Vector3(0.0, 0.0, FIRE_Z - 3.5)
	horse.rotation.y = PI * 0.5
	cv.global_position = Vector3(4.0, 1.7, FIRE_Z + 6.0)
	cv.look_at(Vector3(-1.0, 1.8, FIRE_Z - 3.5), Vector3.UP)
	await get_tree().create_timer(0.5).timeout
	await _shot_png("c32o_02_sultan.png")
	get_tree().quit()


func _light_fire_quiet(i: int) -> void:
	_fire_spots[i].set_meta("lit", true)
	_fire_lights.append(Night.campfire(self, _fire_spots[i].global_position, 1.0))
