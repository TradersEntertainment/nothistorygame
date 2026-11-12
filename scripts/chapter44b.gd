extends Node3D
## Bölüm 44 (yalnız Bizans tarafı) — Sarnıç (Tolga · 26 Mayıs 1453, Ayasofya'nın batısı, toprağın altı).
## docs/BOLUM_YEREBATAN.md (araştırma ve tasarım).
##
## Iustinianus'un Bazilika Sarnıcı 1453'te unutulmuştur: üstündeki mahalleli evinin dibindeki "kuyu"dan su (ve balık)
## çeker, altında 336 sütunluk bir orman olduğunu bilmez (Gyllius, De Topographia II.20: "Ahali içine açılmış
## kuyulardan her gün su çektiği hâlde ondan en küçük bir şüphe duymuyordu"; 1540'larda bir evin içinden inip ev
## sahibinin kayığında meşale ışığında dolaşır, ev sahibi balık zıpkınlar). Medusa başları 1985–87'ye dek çamurdadır.
##   1 Avlu: Kyra Eudokia'nın kuyusu ("selden beri kuyumdan balık çıkıyor; kovamı biri aşağı çekti; cin var").
##     Tolga ipe tutunup iner, çürük ip kopar: karanlık su.
##   2 Karanlık: yalnız kuyu ağzından inen huzme. Fener (telefon; yoksa çakmak; o da yoksa kumandanın ekranı) açılınca
##     sütun ormanı (hayranlık anı; denetim oyuncuda). Pil %14'ten iner; çakmak 6 sn yanar, 2 sn soğur.
##   3 Kayık: sütun dibinde bağlı eski kayık. Kürek ritmi (RowMeter) + A/D dümen; sütuna çarpan durur. Uzaktaki meşaleye.
##   4 "Cin": meşale, zıpkınla balık tutan Yakovos'undur (kovaları o çeker). Medusa köşesindeki kuyu onun evine çıkar.
##   5 Sarsıntı (26 Mayıs bombardımanı): tonozdan düşen tuğlalar (önce toz ve halka, sonra taş), bir kemer çöker,
##     Yakovos'un meşalesi suya düşer: Tolga ışığıyla önden gider. Süre: sarsıntılar sıklaşır.
##   6 Medusa köşesi: ışık suya tutulunca dipte iki taş yüz (biri yan, biri ters). Tespit karesi. Kuyudan yukarı.
##   7 Avlu: "Cin var mı?" — sırrı koru ya da ağzından kaçır.
##   44.1 Sırrı korudu · 44.2 Ağzından kaçırdı ("altınızda saray var"; kimse inanmaz, Paradoks +5)
##   Süre dolarsa (karanlıkta kalınır) Yakovos ipiyle çekip köşeye götürür: cistern_rescued.
## Dallanma: 24.1 (siege_kid) ise selden kurtarılan Venedikli Marco annesiyle bu avluda kalıyordur; tahta atı da kuyuya
##   düşmüştür. Sonuç Bölüm 25'teki son
##   ayinde (Eudokia mumluğun yanında) ve Bölüm 15'in akıbet sayfasında (Yakovos) okunur.
##   --autotest[=blab|dark|kid|nophone]   (varsayılan: 44.1)

const CisternLevel := preload("res://scripts/level/cistern.gd")
const YARD := Vector3(-8.0, 0.0, -52.0)
const WELL := YARD + Vector3(0.0, 0.0, 0.6)
const EUDOKIA_AT := YARD + Vector3(1.6, 0.0, 1.3)
const HOUSE_DOOR := YARD + Vector3(-3.0, 0.0, -2.6)
const BATTERY := 14.0
const DRAIN := 1.0 / 6.5           # % / sn (fener açıkken): 14 % ≈ 90 sn
const LIGHTER_ON := 6.0
const LIGHTER_COOL := 2.0
const QUAKE_TIME := 95.0           # sarsıntı evresinin süresi (sonra kemer çöker, karanlıkta kalınır)
const SEAT := Vector3(0.0, 0.42, 0.35)
const BOAT_R := 0.62

var player: Player
var hud: Hud
var city: ByzCity
var cis: Node3D
var phase := "intro"
var _outcome := ""
var _photo := ""
var cam: TespitCam
var meter: RowMeter
var eudokia: Person
var kid: Person
var yakovos: Person
var neighbors: Array[Person] = []
var yard: Node3D
var boat: Node3D
var yboat: Node3D
var _yard_well: Node3D
var _torch_light: OmniLight3D
var _torch_flame: Node3D
var _spot: SpotLight3D
var _fill: OmniLight3D
var _lighter_l: OmniLight3D
var light_kind := "phone"          # phone | lighter | remote
var light_on := false
var battery := BATTERY
var _lighter_t := 0.0
var _lighter_cool := 0.0
var _boat_yaw := 0.0
var _boat_speed := 0.0
var _last_press := -9.0
var _t := 0.0
var _player_yaw_last := 0.0
var bumps := 0
var hits := 0
var _quake_left := QUAKE_TIME
var _quake_t := 0.0
var _next_brick := 6.0
var _bricks: Array[Dictionary] = []
var rescued := false
var _kid_on := false
var awe_seen := false
var _awe_t := 0.0
var _route: Array[Vector3] = []
var _bot_hold := 0.0
var _my_grip: OarGrip
var _oars: Array = []
var _yk_follow := false
var _battery_shown := false


func _ready() -> void:
	GameState.snapshot(44)
	var v := GameState.autotest_variant if GameState.autotest else ""
	if v == "kid":
		GameState.flags["siege_kid"] = true                # Bölüm 24: çocuk saçağa alındı
		GameState.chapter_outcomes[24] = "24.1"
	_kid_on = bool(GameState.flags.get("siege_kid", false))
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	meter = RowMeter.new()
	hud.add_child(meter)
	meter.stroke.connect(func(_good: bool): _last_press = _t)
	light_kind = "phone" if GameState.has_item("phone") else ("lighter" if GameState.has_item("lighter") else "remote")
	if v == "nophone":
		light_kind = "lighter" if GameState.has_item("lighter") else "remote"
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ avlu

func _build_city() -> void:
	if city:
		return
	city = ByzCity.new()
	city.part = "aya"
	add_child(city)
	if city.niko:
		city.niko.visible = false
	_build_yard()


func _free_city() -> void:
	if city:
		remove_child(city)
		city.queue_free()
		city = null
	if yard:
		yard.queue_free()
		yard = null
	for n in neighbors:
		if is_instance_valid(n):
			n.queue_free()
	neighbors.clear()


## Eudokia'nın avlusu: üç yanı alçak taş duvar, arkada evinin cephesi (kapı, kiremit saçak), ortada kuyu bileziği,
## üstünde ahşap çatkı ve makara; kopacak ip makaradan kuyuya iner. Yanda Yakovos'un evinin kapısı (kiler).
func _build_yard() -> void:
	yard = Node3D.new()
	yard.name = "Yard"
	add_child(yard)
	var stone := Color("b8aa90")
	for spec: Array in [[Vector3(-4.6, 1.0, 0.0), Vector3(0.5, 2.0, 7.4)], [Vector3(4.6, 1.0, 0.0), Vector3(0.5, 2.0, 7.4)],
			[Vector3(-2.9, 1.0, 3.7), Vector3(3.9, 2.0, 0.5)], [Vector3(2.9, 1.0, 3.7), Vector3(3.9, 2.0, 0.5)]]:
		Props.solid(yard, spec[1], YARD + spec[0], stone)
	# Ev cephesi (kuzey): iki katlı, sıvalı; kapı (Yakovos'un evi batıda, Eudokia'nınki doğuda)
	Props.solid(yard, Vector3(9.7, 5.2, 0.6), YARD + Vector3(0, 2.6, -3.9), Color("d8c8a8"))
	Props.box(yard, Vector3(10.2, 0.25, 1.4), YARD + Vector3(0, 5.3, -3.4), Color("9a4a32"), Vector3(-12, 0, 0))
	for dx: float in [-3.0, 2.6]:
		Props.box(yard, Vector3(1.1, 2.1, 0.08), YARD + Vector3(dx, 1.05, -3.58), Color("5a3a22"))
		Props.box(yard, Vector3(1.3, 0.14, 0.2), YARD + Vector3(dx, 2.18, -3.55), Color("8a7a60"))
	for dx: float in [-1.0, 1.0, 4.0]:
		Props.box(yard, Vector3(0.7, 0.8, 0.08), YARD + Vector3(dx, 3.6, -3.58), Color("3a3028"))
	# Çamaşır ipi, saksılar, yer döşemesi
	Props.cyl(yard, 0.012, 6.6, YARD + Vector3(3.9, 2.1, 0.0), Color("c8b898"), Vector3(90, 0, 0), 4)
	for k in 3:
		Props.box(yard, Vector3(0.02, 0.7, 0.6), YARD + Vector3(3.9, 1.72, -2.0 + k * 1.5), [Color("e8e0d0"), Color("7a8aa0"), Color("c8a070")][k])
	for p: Vector3 in [Vector3(3.6, 0, -3.0), Vector3(-3.8, 0, 2.9), Vector3(3.8, 0, 2.8)]:
		Props.cyl(yard, 0.22, 0.4, YARD + p + Vector3(0, 0.2, 0), Color("a0583a"), Vector3.ZERO, 8, 0.28)
		Props.ball(yard, 0.3, YARD + p + Vector3(0, 0.55, 0), Color("4a6a34"), Vector3(1, 0.8, 1), 6)
	Props.box(yard, Vector3(9.0, 0.04, 7.2), YARD + Vector3(0, 0.02, 0), Color("a89a80"))
	# Kuyu bileziği, çatkı, makara, ip (tepeden kuyuya)
	_yard_well = Node3D.new()
	_yard_well.position = WELL
	yard.add_child(_yard_well)
	Props.cyl(_yard_well, 0.75, 0.8, Vector3(0, 0.4, 0), Color("9a8e78"), Vector3.ZERO, 12)
	Props.cyl(_yard_well, 0.58, 0.05, Vector3(0, 0.81, 0), Color("0a0a0a"), Vector3.ZERO, 12)
	var curb := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 0.76
	cyl.height = 0.8
	cs.shape = cyl
	cs.position = Vector3(0, 0.4, 0)
	curb.add_child(cs)
	_yard_well.add_child(curb)
	for sx: float in [-0.7, 0.7]:
		Props.cyl(_yard_well, 0.06, 2.0, Vector3(sx, 1.0, 0), Color("6a4a2c"), Vector3.ZERO, 6)
	Props.cyl(_yard_well, 0.05, 1.6, Vector3(0, 1.95, 0), Color("6a4a2c"), Vector3(0, 0, 90), 6)
	Props.cyl(_yard_well, 0.12, 0.12, Vector3(0, 1.95, 0), Color("4a3422"), Vector3(0, 0, 90), 10)
	var rope := Props.cyl(_yard_well, 0.016, 1.6, Vector3(0.1, 1.15, 0), Color("8a7450"), Vector3.ZERO, 5)
	rope.name = "Rope"
	Props.interactable(yard, "well", Vector3(1.8, 1.6, 1.8), WELL + Vector3(0, 0.8, 0))
	eudokia = Person.new({"coat": Color("4a4a5a"), "pants": Color("3a3028"), "robe": Color("3a3a48"), "skirt": true,
		"hat": "scarf", "scarf": Color("2a2a30"), "hair": Color("b0aca4"), "skin": Color("e0b896")})
	eudokia.set_meta("spk", "SPK_WOMAN_BYZ")
	eudokia.position = EUDOKIA_AT
	add_child(eudokia)
	neighbors.append(eudokia)
	if _kid_on:
		kid = Person.new({"coat": Color("c8603a"), "pants": Color("3a3a5a"), "hair": Color("5a3a1e"), "skin": Color("f0c8a0"), "child": true})
		kid.scale = Vector3.ONE * 0.6
		kid.set_meta("spk", "SPK_KID")        # Venedikli Marco (Bölüm 24)
		kid.position = EUDOKIA_AT + Vector3(0.9, 0, 0.4)
		add_child(kid)
		neighbors.append(kid)


# ================================================================ akış

func _run() -> void:
	await get_tree().process_frame
	Audio.music("byzantium_evening")
	Audio.ambience("amb_city_day")
	Audio.step_surface = "stone"
	Audio.voice_space("outdoor")
	_build_city()
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH44B_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH44B_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	await get_tree().process_frame
	player.global_position = YARD + Vector3(0.4, 0.0, 3.0)
	player.face(WELL + Vector3(0, 1.0, 0))
	eudokia.look_target = player
	if kid:
		kid.look_target = player
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D44B_N_01")
	await hud.say("SPK_TOLGA", "D44B_T_01")
	eudokia.talking = true
	await hud.say("SPK_WOMAN_BYZ", "D44B_E_01")
	await hud.say("SPK_WOMAN_BYZ", "D44B_E_02")
	eudokia.talking = false
	await hud.say("SPK_TOLGA", "D44B_T_02")
	if kid:
		await hud.say("SPK_KID", "D44B_K_01")
		await hud.say("SPK_TOLGA", "D44B_T_KID")
	await hud.say("SPK_WOMAN_BYZ", "D44B_E_03")
	phase = "yard"
	player.frozen = false
	_capture_mouse()
	hud.set_objective(tr("UI_OBJ44_WELL"), WELL + Vector3(0, 1.2, 0))
	if GameState.autotest:
		_on_interact("well")
	while phase == "yard":
		await get_tree().process_frame
	await _descend()
	await _dark()
	await _to_boat()
	await _row_to_torch()
	await _meet_yakovos()
	await _quake()
	await _medusa()
	await _climb()
	await _yard_end()
	await _end_chapter()


func _on_focus(id: String) -> void:
	if id == "well" and phase == "yard":
		hud.set_prompt(tr("UI_PROMPT44_WELL"))
	elif id == "boat" and phase == "swim":
		hud.set_prompt(tr("UI_PROMPT44_BOAT"))
	elif id == "rungs" and phase == "exit":
		hud.set_prompt(tr("UI_PROMPT44_CLIMB"))
	else:
		hud.set_prompt("")


func _on_interact(id: String) -> void:
	if id == "well" and phase == "yard":
		phase = "descend"
		hud.set_prompt("")
		hud.set_objective("")
	elif id == "boat" and phase == "swim":
		phase = "board"
	elif id == "rungs" and phase == "exit":
		phase = "climb"


## İniş: Tolga kuyunun bileziğine çıkar, ipe tutunur; kamera bacadan aşağı iner, ip kopar, düşüş, karanlık su.
func _descend() -> void:
	player.frozen = true
	player.face(WELL + Vector3(0, 0.4, 0))
	await hud.say("SPK_TOLGA", "D44B_T_ROPE")
	player.reach_grab(WELL + Vector3(0.1, 1.4, 0))
	await hud.fade_to(1.0, 0.6)
	player.release_grab()
	_free_city()
	_build_cistern()
	Audio.ambience("amb_tunnel")
	Audio.music("")
	Audio.voice_space("hall")
	var fw: Vector3 = cis.get("fall_well")
	var crown := CisternLevel.IMPOST_Y + CisternLevel.VAULT_H
	player.gravity_on = false
	player.global_position = Vector3(fw.x, crown + 1.6 - player.eye_height, fw.z)
	player.rotation.y = 0.0
	player.camera.rotation.x = deg_to_rad(-55.0)
	_set_ambient(0.0)
	await hud.fade_to(0.0, 0.5)
	Audio.sfx("wood_creak", -8.0, 0.8)
	if not GameState.autotest:
		var tw := create_tween()
		tw.tween_property(player, "global_position:y", crown - 0.4 - player.eye_height, 2.2).set_trans(Tween.TRANS_SINE)
		await tw.finished
	await hud.say("SPK_TOLGA", "D44B_T_DOWN")
	Audio.sfx("paper_tear", -4.0, 0.5)          # ipin lifleri kopar
	player.shake(0.25)
	var fall := create_tween()
	fall.tween_property(player, "global_position:y", CisternLevel.WATER_Y - 1.25, 0.05 if GameState.autotest else 0.75).set_ease(Tween.EASE_IN)
	await fall.finished
	Audio.sfx("splash", -2.0, 0.8)
	cis.call("ring", fw + Vector3(1.2, 0, 0.4), 1.6, 1.8)
	cis.call("ring", fw + Vector3(-0.8, 0, 1.3), 1.2, 1.5)
	hud.wet(3.0)
	player.camera.rotation.x = deg_to_rad(4.0)
	player.floating = true
	player.fall_guard = false


func _build_cistern() -> void:
	cis = CisternLevel.new()
	add_child(cis)
	# Fener (telefon): kameraya bağlı, gölgeli; dolgu ışığı (suyun ve sütunların geri yansıttığı) zayıf, gölgesiz
	_spot = SpotLight3D.new()
	_spot.light_color = Color("f4f0ff")
	_spot.spot_angle_attenuation = 1.6
	_spot.spot_attenuation = 0.8
	_spot.shadow_enabled = true
	_spot.position = Vector3(0.18, -0.22, -0.1)
	_spot.visible = false
	player.camera.add_child(_spot)
	_fill = OmniLight3D.new()
	_fill.light_color = Color("b8c8d8")
	_fill.omni_range = 16.0
	_fill.position = Vector3(0, 2.6, -4.0)
	_fill.visible = false
	player.camera.add_child(_fill)
	_lighter_l = OmniLight3D.new()
	_lighter_l.light_color = Color("ffb060")
	_lighter_l.light_energy = 1.6
	_lighter_l.omni_range = 7.0
	_lighter_l.position = Vector3(0.2, -0.2, -0.45)
	_lighter_l.visible = false
	player.camera.add_child(_lighter_l)
	_build_boats()


## Ortam ışığı: 0 karanlık (gözler alışmadı), 1 alışmış
func _set_ambient(k: float) -> void:
	var we := cis.get_node_or_null("CisternEnv") as WorldEnvironment
	if we:
		we.environment.ambient_light_energy = lerpf(0.08, 0.35, k)


## Karanlık: yalnız huzme. Fener açılınca hayranlık anı.
func _dark() -> void:
	phase = "dark"
	await hud.think("SPK_TOLGA", "D44B_T_DARK")
	player.frozen = false
	player.speed_mult = 0.0
	_capture_mouse()
	hud.set_objective(tr("UI_OBJ44_LIGHT_" + light_kind.to_upper()))
	var t := 0.0
	while not light_on:
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest and t > 0.6:
			_toggle_light()
	hud.set_objective("")
	# Gözler alışır: ortam ışığı yavaşça açılır, fener tam güce çıkar
	var tw := create_tween()
	tw.tween_method(_set_ambient, 0.0, 1.0, 2.5)
	Audio.music("tender")
	_awe_t = 0.0
	phase = "awe"
	await get_tree().create_timer(1.6, false).timeout
	await hud.think("SPK_TOLGA", "D44B_T_AWE_" + light_kind.to_upper())
	await hud.say("SPK_TOLGA", "D44B_T_AWE_2")
	await hud.say("SPK_NIHAT", "D44B_N_AWE")
	await hud.say("SPK_TOLGA", "D44B_T_AWE_3")
	awe_seen = true


## Sütunun dibinde bağlı kayık: yüzerek varılır
func _to_boat() -> void:
	phase = "swim"
	player.speed_mult = 0.42
	hud.set_objective(tr("UI_OBJ44_BOAT"), boat.global_position + Vector3(0, 0.6, 0))
	if GameState.autotest:
		player.global_position = boat.global_position + Vector3(1.2, CisternLevel.WATER_Y - 1.25 - boat.global_position.y, 0)
		_on_interact("boat")
	var t := 0.0
	while phase == "swim":
		await get_tree().process_frame
		t += get_process_delta_time()
		# Uzun süre yaklaşamayan: kayık yüzerek gelmez ama ip yanına uzanır (yaklaşınca biner)
		if player.global_position.distance_to(boat.global_position) < 2.0 and t > 1.0:
			phase = "board"
	hud.set_objective("")
	hud.set_prompt("")
	player.floating = false
	player.speed_mult = 1.0
	await hud.fade_to(1.0, 0.3)
	player.pinned = true
	player.eye_height = 1.12
	_seat_player()
	player.rotation.y = _boat_yaw
	_player_yaw_last = player.rotation.y
	await hud.fade_to(0.0, 0.3)


func _row_to_torch() -> void:
	phase = "row"
	yboat.visible = true
	_torch_light.visible = true
	meter.enabled = true
	hud.set_objective(GameState.tr_pad("UI_OBJ44_ROW"), yboat.global_position + Vector3(0, 1.6, 0))
	await hud.say("SPK_TOLGA", "D44B_T_BOAT")
	_route = _plan(boat.global_position, yboat.global_position + Vector3(2.9, 0, 0))
	# Yakovos'un kayığının yanına (kürek boyu): konuşma yakın mesafede
	while Vector2(boat.global_position.x - yboat.global_position.x, boat.global_position.z - yboat.global_position.z).length() > 3.4:
		await get_tree().process_frame
	meter.enabled = false
	hud.set_objective("")


func _meet_yakovos() -> void:
	phase = "yakovos"
	player.frozen = true          # konuşma; sarsıntı evresinin hedefi gelince serbest
	yakovos.look_target = player
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 1.2)
	await hud.say("SPK_FISHMONGER", "D44B_Y_01")
	await hud.say("SPK_TOLGA", "D44B_T_Y_01")
	await hud.say("SPK_FISHMONGER", "D44B_Y_02")
	await hud.say("SPK_TOLGA", "D44B_T_Y_02")
	await hud.say("SPK_FISHMONGER", "D44B_Y_03")
	await hud.say("SPK_TOLGA", "D44B_T_Y_03")
	await hud.say("SPK_FISHMONGER", "D44B_Y_04_KID" if _kid_on else "D44B_Y_04")
	await hud.say("SPK_TOLGA", "D44B_T_Y_04")
	await hud.say("SPK_FISHMONGER", "D44B_Y_05")


## Sarsıntı: top atışları tonozu sarsar, tuğlalar düşer; bir kemer çöker, meşale suya düşer. Tolga ışığıyla önden
## kuzeybatı köşeye (Medusa kuyusu) gider, Yakovos ardından. Süre dolarsa karanlıkta kalınır: Yakovos ipiyle çeker.
func _quake() -> void:
	phase = "quake"
	await _tremor(0.6)
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 0.8)
	await hud.say("SPK_FISHMONGER", "D44B_Y_QUAKE")
	await hud.say("SPK_NIHAT", "D44B_N_QUAKE")
	# Kemer çöker, meşale suya düşer
	var fall_at := yboat.global_position + Vector3(1.6, 0, -0.6)
	_drop_bricks(fall_at, 8, true)
	await get_tree().create_timer(0.7, false).timeout
	_torch_flame.visible = false
	_torch_light.visible = false
	Audio.sfx("splash", -6.0, 1.3)
	cis.call("ring", yboat.global_position + Vector3(0.6, 0, 0.3), 1.0, 1.4)
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 0.8)
	await hud.say("SPK_FISHMONGER", "D44B_Y_TORCH")
	await hud.say("SPK_TOLGA", "D44B_T_LEAD")
	_yk_follow = true
	meter.enabled = true
	var goal: Vector3 = cis.get("exit_well")
	hud.set_objective(GameState.tr_pad("UI_OBJ44_CORNER"), goal + Vector3(0, 1.0, 0))
	player.frozen = false
	_route = _plan(boat.global_position, goal)
	_quake_left = QUAKE_TIME
	_next_brick = 4.0
	while true:
		await get_tree().process_frame
		if get_tree().paused:
			continue
		var dt := get_process_delta_time()
		_quake_left -= dt
		hud.set_chase(tr("UI_CH44_QUAKE") % ceili(maxf(_quake_left, 0.0)), 1.0 - _quake_left / QUAKE_TIME)
		if Vector2(boat.global_position.x - goal.x, boat.global_position.z - goal.z).length() < 1.8:
			break
		if _quake_left <= 0.0:
			rescued = true
			break
	hud.set_chase("", 0.0)
	meter.enabled = false
	hud.set_objective("")
	if rescued:
		await _rescue(goal)


## Süre doldu: son büyük sarsıntı, fener de sönmüş; karanlıkta Yakovos'un sesi. İpini Tolga'nın kayığına bağlar,
## kendi kayığıyla sütunların arasından köşeye çeker (sayarak: "dokuz, on...").
func _rescue(goal: Vector3) -> void:
	player.frozen = true
	await _tremor(1.0)
	_light_off()
	cis.set("daylight", 0.25)
	await hud.say("SPK_TOLGA", "D44B_T_LOST")
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 1.0)
	await hud.say("SPK_FISHMONGER", "D44B_Y_RESCUE")
	await hud.fade_to(1.0, 0.8)
	_boat_place(goal, _boat_yaw)
	yboat.global_position = goal + Vector3(-2.4, 0, 0.3)
	_place_yakovos()
	cis.set("daylight", 1.0)
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 0.1)
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_FISHMONGER", "D44B_Y_RESCUE_2")


## Medusa köşesi: ışığı suya tut, dipteki taş yüzü kayda geçir (tespit karesi)
func _medusa() -> void:
	phase = "medusa"
	player.frozen = true
	var heads: Array = cis.get("medusa")
	var head: Node3D = heads[0]
	var aim := head.get_node("Aim") as Node3D
	if not light_on:
		_toggle_light()
	# Kayık köşeye yan yanaşır (burnu doğuya): taş yüzlere küpeşteden bakılır, burun ve kürekler kadrajı kapatmaz.
	# Yakovos kayığını arkaya (güneye) çeker.
	_yk_follow = false
	var h2: Node3D = heads[1]
	var mid := (head.global_position + h2.global_position) * 0.5
	var stop := Vector3(mid.x, boat.global_position.y, mid.z + 2.6)
	var yaw1 := _boat_yaw + wrapf(-PI * 0.5 - _boat_yaw, -PI, PI)
	var d := 0.3 if GameState.autotest else 2.0
	var tw := create_tween().set_parallel()
	tw.tween_method(func(k: float):
		var y := lerpf(_boat_yaw, yaw1, k)
		player.rotation.y += y - _boat_yaw
		_boat_yaw = y
		boat.global_position = boat.global_position.lerp(stop, k), 0.0, 1.0, d)
	var side_at := stop + Vector3(0.4, 0, 2.6)
	tw.tween_property(yboat, "global_position", Vector3(side_at.x, yboat.global_position.y, side_at.z), d)
	await tw.finished
	# Yakovos kuyusunun dibindeki taş rafta duran kandili yakıp suya eğer: taş yüzler sıcak ışıkta seçilir (fener bu
	# noktada çoğu zaman sönmüş ya da zayıftır; bölümün ödül anı karanlıkta kalmasın)
	yakovos.unequip("Spear")
	yakovos.equip("lamp")
	var glow := OmniLight3D.new()
	glow.light_color = Color("ffb868")
	glow.light_energy = 3.2
	glow.omni_range = 4.2
	glow.shadow_enabled = false
	glow.name = "MedusaLamp"
	cis.add_child(glow)
	glow.global_position = mid + Vector3(0, 1.05, 1.2)        # suyun hemen altında, yüzlerin önünde
	cis.call("clear_water", mid + Vector3(0, 0, 0.6), 3.4)
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 1.0)
	await hud.say("SPK_FISHMONGER", "D44B_Y_STONE")
	await _turn_to(aim.global_position, 1.2)
	hud.set_objective(GameState.tr_pad("UI_OBJ44_MEDUSA"), aim.global_position)
	player.frozen = false
	cam = TespitCam.new(player, hud, aim, "siege44")
	hud.add_child(cam)
	cam.max_dist = 14.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 90.0):
		await get_tree().process_frame
		if get_tree().paused:
			continue
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true          # konuşma boyunca; tırmanma hedefi gelince yeniden serbest
	hud.set_objective("")
	await hud.say("SPK_TOLGA", "D44B_T_MEDUSA_1")
	await hud.say("SPK_TOLGA", "D44B_T_MEDUSA_2")
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 1.0)
	await hud.say("SPK_FISHMONGER", "D44B_Y_MEDUSA")
	await hud.say("SPK_NIHAT", "D44B_N_MEDUSA")


## Bakışı yumuşakça bir noktaya çevirir (ani dönüş yok; denetim en çok secs saniye alınır)
func _turn_to(point: Vector3, secs: float) -> void:
	var was := player.frozen
	player.frozen = true
	var to := point - player.camera.global_position
	var yaw := atan2(-to.x, -to.z)
	var pitch := atan2(to.y, Vector2(to.x, to.z).length())
	var y0 := player.rotation.y
	var yaw1 := y0 + wrapf(yaw - y0, -PI, PI)
	var tw := create_tween().set_parallel()
	var d := 0.05 if GameState.autotest else secs
	tw.tween_property(player, "rotation:y", yaw1, d).set_trans(Tween.TRANS_SINE)
	tw.tween_property(player.camera, "rotation:x", pitch, d).set_trans(Tween.TRANS_SINE)
	await tw.finished
	player.frozen = was


func _climb() -> void:
	phase = "exit"
	var goal: Vector3 = cis.get("exit_well")
	var rungs := Props.interactable(cis, "rungs", Vector3(1.4, 2.4, 1.4), goal + Vector3(0, 1.2, 0))
	rungs.name = "Rungs"
	# Bacanın içinde demir basamaklar (Yakovos'un evinin kileri)
	for k in 12:
		Props.box(cis, Vector3(0.36, 0.035, 0.05), goal + Vector3(0, CisternLevel.IMPOST_Y - 2.2 + k * 0.5, -0.56), Color("3a3430"))
	hud.set_objective(tr("UI_OBJ44_CLIMB"), goal + Vector3(0, 2.0, 0))
	player.frozen = false
	if GameState.autotest:
		_on_interact("rungs")
	while phase == "exit":
		await get_tree().process_frame
	hud.set_objective("")
	hud.set_prompt("")
	meter.enabled = false
	player.pinned = false
	player.frozen = true
	player.global_position = Vector3(goal.x, CisternLevel.WATER_Y + 0.3, goal.z + 0.2)
	player.face(Vector3(goal.x, CisternLevel.WATER_Y + 12.0, goal.z - 0.6))
	if not GameState.autotest:
		var tw := create_tween()
		tw.tween_property(player, "global_position:y", CisternLevel.IMPOST_Y + 1.6, 3.2).set_trans(Tween.TRANS_SINE)
		for k in 6:
			get_tree().create_timer(0.5 * k, false).timeout.connect(Audio.sfx.bind("footstep_stone_%d" % (k % 4 + 1), -10.0, 0.8))
		await tw.finished
	await hud.say("SPK_TOLGA", "D44B_T_CLIMB")
	await hud.fade_to(1.0, 0.7)


## Avluya dönüş: Yakovos'un kilerinden çıkılır; Eudokia, komşular. Seçim: sırrı koru ya da ağzından kaçır.
func _yard_end() -> void:
	phase = "end"
	_light_off()
	if cis:
		remove_child(cis)
		cis.queue_free()
		cis = null
		boat = null
		yboat = null
	player.gravity_on = true
	player.floating = false
	player.fall_guard = true
	player.eye_height = Player.EYE
	Audio.ambience("amb_city_day")
	Audio.voice_space("outdoor")
	Audio.music("byzantium_evening")
	_build_city()
	await get_tree().process_frame
	player.global_position = HOUSE_DOOR + Vector3(0.3, 0, 1.4)
	player.face(WELL + Vector3(0, 1.0, 0))
	if kid:
		kid.position = HOUSE_DOOR + Vector3(1.7, 0, 2.9)      # oyuncunun önünde, Eudokia'nın görüş çizgisinin dışında
		kid.look_target = player
	yakovos = _make_yakovos()
	yakovos.position = HOUSE_DOOR + Vector3(-0.9, 0, 1.1)
	yakovos.look_target = player
	add_child(yakovos)
	neighbors.append(yakovos)
	for k in 2:
		var n := Person.new({"coat": [Color("6a5040"), Color("5a6a7a")][k], "pants": Color("3a3028"), "hat": "none" if k == 0 else "hood",
			"beard": k == 0, "mustache": true, "hair": Color("3a2a1e")})
		n.set_meta("spk", "SPK_TOWNSMAN")
		n.position = YARD + Vector3(2.8 - k * 1.1, 0, 2.4)
		n.look_target = player
		add_child(n)
		neighbors.append(n)
	await hud.fade_to(0.0, 0.8)
	eudokia.talking = true
	await hud.say("SPK_WOMAN_BYZ", "D44B_E_BACK")
	eudokia.talking = false
	await hud.say("SPK_FISHMONGER", "D44B_Y_BUCKET_KID" if _kid_on else "D44B_Y_BUCKET")
	if _kid_on:
		await hud.say("SPK_KID", "D44B_K_HORSE")
	await hud.say("SPK_TOWNSMAN", "D44B_TW_DJINN")
	var pick := 1 if GameState.autotest and GameState.autotest_variant == "blab" else 0
	var c := await hud.choose(["UI_CH44_KEEP", "UI_CH44_BLAB"], 0.0, pick)
	if c == 1:
		_outcome = "44.2"
		GameState.paradox += 5
		await hud.say("SPK_TOLGA", "D44B_T_BLAB")
		await hud.say("SPK_TOWNSMAN", "D44B_TW_LAUGH")
		await hud.say("SPK_WOMAN_BYZ", "D44B_E_BLAB")
		await hud.say("SPK_FISHMONGER", "D44B_Y_BLAB")
		await hud.say("SPK_NIHAT", "D44B_N_BLAB")
	else:
		_outcome = "44.1"
		await hud.say("SPK_TOLGA", "D44B_T_KEEP")
		await hud.say("SPK_WOMAN_BYZ", "D44B_E_KEEP")
		await hud.say("SPK_FISHMONGER", "D44B_Y_KEEP")
		await hud.say("SPK_NIHAT", "D44B_N_KEEP")
	await hud.say("SPK_TOLGA", "D44B_T_END")
	GameState.flags["cistern_rescued"] = rescued
	Siege.record(44, _photo, "SIEGE_NOTE_44_%s" % _outcome.split(".")[1])


# ================================================================ kayıklar

func _build_boats() -> void:
	var fw: Vector3 = cis.get("fall_well")
	boat = _skiff(Color("4a3422"))
	add_child(boat)
	# Düşüş kuyusunun 5 m batısında, sütuna bağlı (halat sütunun boynunda)
	var tie := CisternLevel.column(20, 7)
	_boat_yaw = PI * 0.5
	_boat_place(Vector3(tie.x + 1.05, 0, fw.z - 0.2), _boat_yaw)
	var rope := Props.cyl(boat, 0.014, 1.2, Vector3(0.0, 0.5, -1.7), Color("8a7450"), Vector3(70, 0, 0), 4)
	rope.name = "TieRope"
	Props.interactable(boat, "boat", Vector3(1.6, 1.4, 3.6), Vector3(0, 0.5, 0))
	var l := OarGrip.make_oar(boat, Vector3(-0.62, 0.62, 0.05), -1.0, 0.55, 1.5, 0.03, Vector2(0.42, 0.15), 0.12)
	var r := OarGrip.make_oar(boat, Vector3(0.62, 0.62, 0.05), 1.0, 0.55, 1.5, 0.03, Vector2(0.42, 0.15), 0.12)
	_oars = [l, r]
	_my_grip = OarGrip.phantom(boat, Transform3D(Basis(), SEAT + Vector3(0, 0, 0.0)), [[l, "auto"], [r, "auto"]], CisternLevel.WATER_Y, true)
	# Yakovos: batıda, uzakta, kayığında meşale ve zıpkın
	yboat = _skiff(Color("3a2a1c"))
	add_child(yboat)
	var yat := CisternLevel.bay(8, 6)
	yboat.global_position = Vector3(yat.x, CisternLevel.WATER_Y - 0.12, yat.z)
	yboat.rotation.y = -PI * 0.3
	yboat.visible = false
	_torch_flame = Node3D.new()
	yboat.add_child(_torch_flame)
	_torch_flame.position = Vector3(0.35, 1.7, -1.2)
	Props.cyl(yboat, 0.03, 1.4, Vector3(0.35, 1.05, -1.2), Color("5a3a22"), Vector3.ZERO, 5)
	Flame.blaze(_torch_flame, 0.16, 0.6, Vector3.ZERO)
	_torch_light = OmniLight3D.new()
	_torch_light.light_color = Color("ff9a40")
	_torch_light.light_energy = 2.4
	_torch_light.omni_range = 13.0
	_torch_light.shadow_enabled = false
	_torch_light.position = Vector3(0, 0.2, 0)
	_torch_light.visible = false
	_torch_flame.add_child(_torch_light)
	yakovos = _make_yakovos()
	yboat.add_child(yakovos)
	_place_yakovos()


func _make_yakovos() -> Person:
	var y := Person.new({"coat": Color("5a4a38"), "pants": Color("3a3028"), "hat": "hood", "beard": true, "mustache": true,
		"hair": Color("8a8478"), "skin": Color("d8a888")})
	y.set_meta("spk", "SPK_FISHMONGER")
	return y


func _place_yakovos() -> void:
	if yakovos.get_parent() != yboat:
		return
	yakovos.position = Vector3(-0.1, 0.35, 0.6)
	yakovos.set_meta("no_ground", true)
	yakovos.set_meta("no_yield", true)
	yakovos.equip("spear")


## Küçük kayık: gövde (LowPoly.hull), oturak tahtaları, dipte su, pruvada halka
func _skiff(col: Color) -> Node3D:
	var g := Node3D.new()
	g.add_child(LowPoly.hull([
		{"z": -1.9, "w": 0.08, "top": 0.75, "bottom": 0.35},
		{"z": -0.9, "w": 0.6, "top": 0.62, "bottom": 0.0},
		{"z": 0.4, "w": 0.66, "top": 0.6, "bottom": -0.05},
		{"z": 1.7, "w": 0.3, "top": 0.68, "bottom": 0.25},
	], col, col.lightened(0.15), 0.5))
	for z: float in [-0.9, 0.35, 1.2]:
		Props.box(g, Vector3(1.1, 0.05, 0.24), Vector3(0, 0.38, z), Color("8a6a44"))
	Props.box(g, Vector3(0.9, 0.02, 2.4), Vector3(0, 0.08, 0), Color("2a3028"))
	return g


func _boat_place(p: Vector3, yaw: float) -> void:
	_boat_yaw = yaw
	boat.global_position = Vector3(p.x, CisternLevel.WATER_Y - 0.12 + sin(_t * 1.3) * 0.02, p.z)
	boat.rotation = Vector3(sin(_t * 0.9) * 0.01, yaw, sin(_t * 1.1) * 0.015)


func _seat_player() -> void:
	player.global_position = boat.to_global(SEAT) - Vector3(0, 0.0, 0)


## Yol: tonoz gözlerinin ortasından geçen koridorlar (sütunlar köşelerde). Önce z koridorunda hedefin satırına, sonra x.
func _plan(from: Vector3, to: Vector3) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var bx0 := clampi(int(floor((from.x + CisternLevel.HALF_X) / CisternLevel.SX)), 0, CisternLevel.NX)
	var bz0 := clampi(int(floor((from.z + CisternLevel.HALF_Z) / CisternLevel.SZ)), 0, CisternLevel.NZ)
	var bx1 := clampi(int(floor((to.x + CisternLevel.HALF_X) / CisternLevel.SX)), 0, CisternLevel.NX)
	var bz1 := clampi(int(floor((to.z + CisternLevel.HALF_Z) / CisternLevel.SZ)), 0, CisternLevel.NZ)
	out.append(CisternLevel.bay(bx0, bz0))
	out.append(CisternLevel.bay(bx0, bz1))
	out.append(CisternLevel.bay(bx1, bz1))
	out.append(Vector3(to.x, CisternLevel.WATER_Y, to.z))
	return out


# ================================================================ kare kare

func _process(delta: float) -> void:
	_t += delta
	if cis:
		cis.set("focus", player.global_position)
	_light_tick(delta)
	if boat == null or not is_instance_valid(boat):
		return
	if phase in ["row", "quake"]:
		_row_tick(delta)
	elif phase in ["yakovos", "medusa", "exit", "board", "awe", "swim", "dark"]:
		_boat_speed = move_toward(_boat_speed, 0.0, delta * 1.5)
		_boat_place(boat.global_position, _boat_yaw)
	if player.pinned:
		_seat_player()
	if _yk_follow and yboat and is_instance_valid(yboat):
		var want := boat.global_position + boat.global_transform.basis.z * 4.2
		var d := want - yboat.global_position
		d.y = 0.0
		if d.length() > 0.3:
			yboat.global_position += d.normalized() * minf(d.length(), 2.0 * delta)
			yboat.rotation.y = lerp_angle(yboat.rotation.y, atan2(-d.x, -d.z), delta * 2.0)
			# Sütunların içinden geçmez (pruva, orta, kıç)
			var yf := -yboat.global_transform.basis.z
			for off: float in [-1.5, 0.0, 1.5]:
				yboat.global_position += cis.call("push_out", yboat.global_position - yf * off, BOAT_R) as Vector3
	if phase == "quake":
		_bricks_tick(delta)
	_animate_oars()


func _animate_oars() -> void:
	var rowing := meter.enabled and _t - _last_press < RowMeter.PERIOD * 1.3
	if _my_grip:
		_my_grip.phase = OarGrip.meter(meter.phase) if rowing else Rig.ROW_REST
	player.oar_hold(_my_grip if player.pinned else null)


## Kayık: kürek ritmi hız verir, A/D burnu çevirir; sütuna ya da duvara değen kayık durur (tok ses), oyuncunun bakışı
## kayıkla birlikte döner.
func _row_tick(delta: float) -> void:
	var bot := GameState.autotest
	var steer := 0.0
	var rowing := meter.enabled and _t - _last_press < RowMeter.PERIOD * 1.3
	if bot:
		steer = _bot_steer(delta)
		# dark: sarsıntıda bot kürek çekmez, süre dolar (Yakovos çeker)
		if GameState.autotest_variant == "dark" and phase == "quake":
			_bot_hold = 1.0
		if _bot_hold <= 0.0 and meter.enabled:
			_last_press = _t
			rowing = true
		else:
			rowing = false
	else:
		if not player.frozen and Input.is_action_just_pressed("jump") and meter.enabled:
			meter.press()
			_last_press = _t
		steer = Input.get_axis("move_right", "move_left")
	_bot_hold = maxf(0.0, _bot_hold - delta)
	var target := (0.8 + 2.4 * meter.speed_factor()) if rowing else 0.0
	if bot and rowing:
		target = 2.6
	_boat_speed = move_toward(_boat_speed, target, delta * (1.2 if rowing else 0.6))
	var turn := steer * delta * (0.9 + 0.25 * _boat_speed)
	_boat_yaw += turn
	if player.pinned:
		player.rotation.y += turn
	var fwd := -Vector3(sin(_boat_yaw), 0, cos(_boat_yaw))
	var p := boat.global_position + fwd * _boat_speed * delta
	# Çarpışma: pruva ve kıç noktaları
	var push := Vector3.ZERO
	for off: float in [-1.6, 0.0, 1.5]:
		push += cis.call("push_out", p - fwd * off, BOAT_R) as Vector3
	if push.length() > 0.001:
		p += push
		if _boat_speed > 0.6:
			bumps += 1
			Audio.sfx("land_thud", -10.0, 1.4)
			cis.call("ring", p + fwd * 1.6, 0.6, 1.0)
			player.shake(0.08)
		_boat_speed *= 0.2
	_boat_place(p, _boat_yaw)
	if rowing and fmod(_t, 1.5) < delta:
		cis.call("ring", p - fwd * 0.2 + Vector3(-fwd.z, 0, fwd.x) * 1.4, 0.5, 1.2)
		cis.call("ring", p - fwd * 0.2 - Vector3(-fwd.z, 0, fwd.x) * 1.4, 0.5, 1.2)


## Test botu: koridor yolunu izler (burnu sıradaki noktaya döndürür); düşen taşın uyarısı önündeyse durur
func _bot_steer(delta: float) -> float:
	if _route.is_empty():
		return 0.0
	var p := boat.global_position
	var to: Vector3 = _route[0]
	if Vector2(to.x - p.x, to.z - p.z).length() < 1.2 and _route.size() > 1:
		_route.pop_front()
		to = _route[0]
	var want := atan2(-(to.x - p.x), -(to.z - p.z))
	var diff := wrapf(want - _boat_yaw, -PI, PI)
	if absf(diff) > 0.5:
		_boat_speed = minf(_boat_speed, 0.5)
	for b: Dictionary in _bricks:
		if not b["fell"] and (b["at"] as Vector3).distance_to(p + (to - p).normalized() * 2.5) < 2.4:
			_bot_hold = 0.4
	return clampf(diff * 3.0, -1.0, 1.0)


# ================================================================ ışık

func _toggle_light() -> void:
	if light_on:
		_light_off()
		return
	match light_kind:
		"phone":
			if battery <= 0.0:
				light_kind = "lighter" if GameState.has_item("lighter") else "remote"
				hud.bark("SPK_TOLGA", "D44B_T_BATTERY_0", 3.0)
				return
			light_on = true
			player.hold_now("phone")          # fener elde: telefon görünür
			_spot.visible = true
			_spot.light_energy = 6.0
			_spot.spot_range = 45.0
			_spot.spot_angle = 36.0
			_fill.visible = true
			_fill.light_energy = 0.5
			Audio.sfx("ui_select", -14.0, 1.6)
		"lighter":
			if _lighter_cool > 0.0:
				return
			light_on = true
			player.hold_now("lighter")
			_lighter_t = LIGHTER_ON
			_lighter_l.visible = true
			_fill.visible = true
			_fill.light_energy = 0.18
			Audio.sfx("fuse_burn", -16.0, 1.6)
		_:
			# Kumandanın ekranı: soluk mavi, kısa menzil
			light_on = true
			_spot.visible = true
			_spot.light_energy = 1.4
			_spot.spot_range = 12.0
			_spot.spot_angle = 50.0
			_spot.light_color = Color("a8c8ff")
			_fill.visible = true
			_fill.light_energy = 0.12


func _light_off() -> void:
	if light_on and player and player.held_item() in ["phone", "lighter"]:
		player.hold_default()
	light_on = false
	if _spot:
		_spot.visible = false
	if _fill:
		_fill.visible = false
	if _lighter_l:
		_lighter_l.visible = false


func _light_tick(delta: float) -> void:
	if _spot == null:
		return
	# Pil yazısı yalnız kürekte, konuşma ve etkileşim istemi yokken; evre değişince silinir
	var show := phase in ["row", "quake"] and player.focus_id == "" and light_kind == "phone" and light_on and not hud.is_talking()
	if show:
		hud.set_prompt(tr("UI_CH44_BATTERY") % ceili(battery))
	elif _battery_shown:
		hud.set_prompt("")
	_battery_shown = show
	if phase in ["dark", "awe", "swim", "board", "row", "yakovos", "quake", "medusa", "exit"]:
		var want := Input.is_action_just_pressed("kick") and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not player.frozen
		if want and phase != "medusa":
			_toggle_light()
	if not light_on:
		_lighter_cool = maxf(0.0, _lighter_cool - delta)
		if phase in ["row", "quake", "swim"] and not GameState.autotest and int(_t) % 20 == 0 and fmod(_t, 1.0) < delta:
			hud.bark("SPK_TOLGA", "D44B_T_DARK_HINT", 2.5)
		return
	match light_kind:
		"phone":
			battery = maxf(0.0, battery - DRAIN * delta)
			# %3'ün altında titrer
			if battery < 3.0:
				_spot.light_energy = 6.0 * (0.6 + 0.4 * absf(sin(_t * 23.0)))
			if battery <= 0.0:
				_light_off()
				hud.bark("SPK_TOLGA", "D44B_T_BATTERY_0", 3.5)
				light_kind = "lighter" if GameState.has_item("lighter") else "remote"
		"lighter":
			_lighter_t -= delta
			_lighter_l.light_energy = 1.6 * (0.85 + 0.15 * sin(_t * 31.0) * sin(_t * 7.0))
			if _lighter_t <= 0.0:
				_light_off()
				_lighter_cool = LIGHTER_COOL
				hud.bark("SPK_TOLGA", "D44B_T_THUMB", 2.0)


# ================================================================ sarsıntı ve düşen tuğlalar

## Top atışının sarsıntısı: uzak gümbürtü, kamera sarsılır, tavandan toz ve damla
func _tremor(power: float) -> void:
	Audio.sfx("cannon", -18.0, 0.6)
	await get_tree().create_timer(0.35, false).timeout
	Audio.sfx("rumble", -6.0 + power * 4.0, 0.9)
	player.shake(0.12 + 0.25 * power)
	for k in int(4 + power * 6):
		var p := player.global_position + Vector3(randf_range(-7, 7), 0, randf_range(-7, 7))
		cis.call("ring", p, randf_range(0.3, 0.6), 1.2)
		_dust(p, 1.2)
	await get_tree().create_timer(0.6, false).timeout


func _dust(at: Vector3, secs: float) -> void:
	var d := CPUParticles3D.new()
	d.amount = 40
	d.lifetime = 1.4
	d.one_shot = false
	d.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	d.emission_sphere_radius = 0.25
	d.direction = Vector3.DOWN
	d.spread = 8.0
	d.gravity = Vector3(0, -6.0, 0)
	d.initial_velocity_min = 0.5
	d.initial_velocity_max = 1.5
	var q := QuadMesh.new()
	q.size = Vector2(0.03, 0.03)
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.62, 0.55, 0.45, 0.8)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	q.material = m
	d.mesh = q
	d.position = Vector3(at.x, CisternLevel.IMPOST_Y + CisternLevel.VAULT_H - 0.6, at.z)
	add_child(d)
	get_tree().create_timer(secs, false).timeout.connect(func():
		if is_instance_valid(d):
			d.emitting = false
			get_tree().create_timer(1.6, false).timeout.connect(d.queue_free))


## Uyarılı düşüş: önce toz süzülür ve suda halkalar belirir (1,6 sn), sonra tuğla/harç parçaları düşer
func _drop_bricks(at: Vector3, n: int, big := false) -> void:
	var b := {"at": Vector3(at.x, CisternLevel.WATER_Y, at.z), "t": 1.6, "fell": false, "n": n, "big": big}
	_bricks.append(b)
	_dust(at, 1.6)
	cis.call("ring", at, 0.4, 1.0)


func _bricks_tick(delta: float) -> void:
	_quake_t += delta
	_next_brick -= delta
	if _next_brick <= 0.0 and phase == "quake":
		# Sarsıntılar sıklaşır: başta 9 sn, sonda 4 sn
		var k := clampf(1.0 - _quake_left / QUAKE_TIME, 0.0, 1.0)
		_next_brick = lerpf(9.0, 4.0, k)
		_tremor_light()
		var fwd := -Vector3(sin(_boat_yaw), 0, cos(_boat_yaw))
		var lat := Vector3(-fwd.z, 0, fwd.x) * randf_range(-0.8, 0.8)
		_drop_bricks(boat.global_position + fwd * randf_range(3.5, 6.0) * maxf(_boat_speed, 0.6) + lat, 4 + randi() % 3)
	for b: Dictionary in _bricks:
		if b["fell"]:
			continue
		b["t"] = float(b["t"]) - delta
		if fmod(float(b["t"]), 0.45) < delta:
			cis.call("ring", b["at"], 0.3, 0.8)
		if float(b["t"]) <= 0.0:
			b["fell"] = true
			_brick_fall(b)
	_bricks = _bricks.filter(func(x: Dictionary) -> bool: return not x["fell"])


func _tremor_light() -> void:
	Audio.sfx("cannon", -20.0, 0.55)
	Audio.sfx("rumble", -10.0, 1.0)
	player.shake(0.1)


func _brick_fall(b: Dictionary) -> void:
	var at: Vector3 = b["at"]
	var top := CisternLevel.IMPOST_Y + CisternLevel.VAULT_H - 0.5
	for k in int(b["n"]):
		var piece := Props.box(self, Vector3(0.34, 0.06, 0.22) * (1.6 if b["big"] else 1.0), Vector3(at.x + randf_range(-0.5, 0.5), top, at.z + randf_range(-0.5, 0.5)),
			Color("8a5034").lerp(Color("b8a890"), randf() * 0.5), Vector3(randf() * 90, randf() * 180, randf() * 90))
		var tw := piece.create_tween()
		var dur := 0.75 + randf() * 0.15
		tw.tween_property(piece, "position:y", CisternLevel.WATER_Y - 0.5, dur).set_delay(k * 0.06).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(piece, "rotation", piece.rotation + Vector3(2.0, 1.0, 1.5), dur)
		tw.tween_callback(piece.queue_free)
	get_tree().create_timer(0.8, false).timeout.connect(func():
		if cis == null:
			return
		Audio.sfx("splash", -4.0 if b["big"] else -9.0, 0.9)
		cis.call("ring", at, 2.2 if b["big"] else 1.3, 1.6)
		# Köpük küresi yok (kameraya yakın düşüşte "buz kütlesi" gibi görünüyordu): iç içe halkalar
		get_tree().create_timer(0.25, false).timeout.connect(func():
			if cis:
				cis.call("ring", at + Vector3(0.3, 0, -0.2), 0.9 if b["big"] else 0.6, 1.3))
		if boat and is_instance_valid(boat) and Vector2(boat.global_position.x - at.x, boat.global_position.z - at.z).length() < 1.5 and not b["big"]:
			hits += 1
			_boat_speed = 0.0
			player.shake(0.35)
			Audio.sfx("land_thud", -4.0, 0.9)
			hud.bark("SPK_TOLGA", "D44B_T_HIT_%d" % mini(hits, 3), 2.5))


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(44, _outcome)
	await Siege.show_page(hud, 44)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(44)
			if nxt != "":
				GameState.change_scene(nxt)
			else:
				hud.set_fade(1.0)
				await hud.card([[tr("UI_SIEGE_TBC"), 30, Color("f2e6c9")], [tr("UI_SIEGE_TBC_SUB"), 18, Color(1, 1, 1, 0.7)]], 3.5)
				GameState.change_scene("res://scenes/main.tscn")
		"replay":
			GameState.replay_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW44_TITLE")
	c.nodes = [
		{"id": "well", "key": "FLOW44_WELL", "pos": Vector2(0.5, 0.1)},
		{"id": "forest", "key": "FLOW44_FOREST", "pos": Vector2(0.5, 0.25)},
		{"id": "rescued", "key": "FLOW44_RESCUED", "pos": Vector2(0.75, 0.4)},
		{"id": "medusa", "key": "FLOW44_MEDUSA", "pos": Vector2(0.4, 0.4)},
		{"id": "44.1", "key": "FLOW_44_1", "pos": Vector2(0.3, 0.6), "outcome": true},
		{"id": "44.2", "key": "FLOW_44_2", "pos": Vector2(0.7, 0.6), "outcome": true},
	]
	c.edges = [["well", "forest"], ["forest", "medusa"], ["forest", "rescued"], ["rescued", "medusa"], ["medusa", "44.1"], ["medusa", "44.2"]]
	c.taken["well"] = true
	c.taken["forest"] = true
	c.taken["medusa"] = true
	if rescued:
		c.taken["rescued"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH44_STATS") % [bumps, hits, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		GameState.tr_pad("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"blab": "44.2"}.get(v, "44.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("44", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and awe_seen
	ok = ok and rescued == (v == "dark")
	ok = ok and _kid_on == (v == "kid")
	if v == "nophone":
		ok = ok and light_kind != "phone"
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s, foto=%s, hayranlık=%s, kurtarıldı=%s)" % [expected, _outcome,
			not page.is_empty(), cam != null and cam.done, awe_seen, rescued])
	print("AUTOTEST %s chapter=44 variant=%s outcome=%s light=%s battery=%.1f bumps=%d hits=%d rescued=%s kid=%s" % [
		"PASS" if ok else "FAIL", v, _outcome, light_kind, battery, bumps, hits, rescued, _kid_on])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri (--shots)

func _shot(nm: String) -> void:
	for k in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(GameState.shots_dir.path_join(nm))
	print("SHOT %s draws=%d prims=%d" % [nm, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])


## Kanıt kareleri (sonda): hayranlık anı üç açıdan, kayıktan orman, Medusa yakın, huzme, telefon ve çakmak
func _run_shots() -> void:
	await get_tree().process_frame
	hud.visible = false
	_build_cistern()
	_set_ambient(1.0)
	await get_tree().process_frame
	player.pinned = false        # kayığa oturtulmasın (_process oturağa taşıyordu): yerinde donuk
	player.frozen = true
	player.gravity_on = false
	var fw: Vector3 = cis.get("fall_well")
	var shots := [
		["c44_awe_1.png", Vector3(fw.x, CisternLevel.WATER_Y + 0.35, fw.z + 0.6), Vector3(fw.x - 20, CisternLevel.WATER_Y + 1.2, fw.z - 3), "phone"],
		["c44_awe_2.png", Vector3(fw.x, CisternLevel.WATER_Y + 0.35, fw.z + 0.6), Vector3(fw.x - 3, CisternLevel.WATER_Y + 3.5, fw.z - 18), "phone"],
		["c44_awe_3.png", Vector3(fw.x, CisternLevel.WATER_Y + 0.35, fw.z + 0.6), Vector3(fw.x - 8, CisternLevel.WATER_Y + 7.0, fw.z + 6), "phone"],
		["c44_dark.png", Vector3(fw.x, CisternLevel.WATER_Y + 0.35, fw.z + 0.6), Vector3(fw.x - 20, CisternLevel.WATER_Y + 1.2, fw.z - 3), ""],
		["c44_lighter.png", Vector3(fw.x, CisternLevel.WATER_Y + 0.35, fw.z + 0.6), Vector3(fw.x - 20, CisternLevel.WATER_Y + 1.2, fw.z - 3), "lighter"],
	]
	var b2: Vector3 = CisternLevel.bay(17, 4)
	shots.append(["c44_beam.png", b2 + Vector3(0, 0.9, 7.6), b2 + Vector3(0, 2.6, 0), ""])
	shots.append(["c44_beam_lit.png", b2 + Vector3(0, 0.9, 7.6), b2 + Vector3(0, 2.6, 0), "phone"])
	shots.append(["c44_up.png", Vector3(fw.x + 0.3, CisternLevel.WATER_Y + 0.35, fw.z + 0.4), Vector3(fw.x - 0.6, 20.0, fw.z - 0.4), "phone"])
	var r0 := CisternLevel.bay(18, 6)
	shots.append(["c44_boat_row.png", r0 + Vector3(0, 0.9, 0), r0 + Vector3(-30, 1.5, 0), "phone"])
	var mc := CisternLevel.column(1, 1)
	shots.append(["c44_medusa.png", mc + Vector3(1.0, CisternLevel.WATER_Y + 0.9, 2.2), mc + Vector3(0, 0.9, 0.5), "phone"])
	var mc2 := CisternLevel.column(2, 1)
	shots.append(["c44_medusa_inv.png", mc2 + Vector3(-0.6, CisternLevel.WATER_Y + 0.9, 2.2), mc2 + Vector3(0, 0.9, 0.5), "phone"])
	var he := CisternLevel.column(9, 6)
	shots.append(["c44_heneye.png", he + Vector3(1.5, CisternLevel.WATER_Y + 0.6, 1.8), he + Vector3(0, 4.0, 0), "phone"])
	for s: Array in shots:
		player.global_position = (s[1] as Vector3) - Vector3(0, player.eye_height, 0)
		player.face(s[2])
		cis.set("focus", s[1])
		_light_off()
		if s[3] != "":
			light_kind = s[3]
			_lighter_cool = 0.0
			_toggle_light()
			_lighter_t = 99.0
		await _shot(s[0])
	# Bölüm kapağı (assets/art/covers/ch44b.png): hayranlık anı, el ve telefon görünmez
	player.stow_hands(true)
	player.global_position = Vector3(fw.x, CisternLevel.WATER_Y + 0.45, fw.z + 0.6) - Vector3(0, player.eye_height, 0)
	player.face(Vector3(fw.x - 3, CisternLevel.WATER_Y + 3.2, fw.z - 18))
	light_kind = "phone"
	_light_off()
	_toggle_light()
	player.stow_hands(true)
	await _shot("ch44b_cover.png")
	get_tree().quit()
