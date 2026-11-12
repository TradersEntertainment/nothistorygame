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

# ================================================================ AYAR (zorluk ve tempo: sahibin kararı; hepsi burada)
const BATTERY := 14.0              # telefonun pili (%)
const DRAIN := 1.0 / 6.5           # % / sn (fener açık ve oyuncu denetimdeyken; konuşmada akmaz): 14 % ≈ 90 sn
const LIGHTER_ON := 6.0            # çakmak bir yakışta kaç sn yanar
const LIGHTER_COOL := 2.0          # sonra kaç sn soğur
const QUAKE_TIME := 95.0           # sarsıntı evresinin süresi (dolarsa karanlıkta kalınır, Yakovos çeker: kayıp yok)
const YAKOVOS_BAY := Vector2i(13, 7)   # Yakovos'un meşalesi: düşüş kuyusundan ~45 m (kürekle 25–50 sn)
const ROW1_EVENTS := [0.2, 0.45, 0.7]  # ilk kürek evresinde olaylar yolun bu kesirlerinde: balık sürüsü, uzak top, şıpırtı
const SHOT_GAP_START := 8.0        # sarsıntı evresinde top atışları arası (sn): başta
const SHOT_GAP_END := 4.5          # … sonda (sıklaşır)
const WARN_SECS := 1.6             # düşüşten önce toz sütunu, gölge ve halka uyarısı (sn)
const HIT_RADIUS := 1.5            # küçük parça kayığa bu kadar yakın düşerse isabet (m)
const HIT_DARK_SECS := 2.5         # isabette ışık elden kayar: karanlık panik anı (sn)
const HIT_SLOW := 0.1              # her isabette kayık su alır: en yüksek hız bu kadar düşer (en çok 3 kez)
const BIG_SIDE_MIN := 2.0          # büyük tonoz parçası kayığın yanına en az … (m; isabet etmez, kayığı sallar)
const BIG_SIDE_MAX := 3.0          # … en çok
const WAVE_PUSH := 0.8             # her atışta dalga kayığı yana iter (m/sn, sönerek)
const COLLAPSE_AHEAD := 3          # tonoz gözü kayığın kaç göz önünde çöker (rota üstünde)
const COLLAPSE_LATEST := 32.0      # kayık rotada değilse en geç bu saniyede çöker
const GAP := 1.8                   # çöken gözün batı kemerinde kalan geçidin açıklığı (m; kayığın eni 1,24)
const CURRENT_SPEED := 0.4         # çöküşün ardından suyun dalgası kayığı çöküş yerinden uzağa iter (m/sn)
const CURRENT_SECS := 12.0         # … bu kadar sürer (sönerek)
const FLICKER_SECS := 1.6          # çöküş anında fener titrer
const SUN_PEAK := 5.0              # tonoz yarığından giren gün ışığının tepe parlaklığı (ışık enerjisi)
const SUN_PEAK_SECS := 3.5         # sütun ormanını boydan boya aydınlattığı süre (sn)
const SUN_REST := 1.3              # sonra yarıktan kalıcı huzme (ışık enerjisi)
const AMBIENT_DARK := 0.08         # gözler alışmadan ortam ışığı
const AMBIENT_LIT := 0.75          # gözler alışınca (fener konisinin dışı tam siyah olmasın)
const MEDUSA_STOP := 3.3           # kayık Medusa'lı iki sütunun kaç m güneyinde durur (iki yüz aynı kadrajda)
const MEDUSA_FOV := 36.0           # tespit karesi ve yakın bakış: telefonun kamerası yakınlaştırır (görüş açısı, derece)
const CLIMB_SECS := 6.5            # ip merdiven + demir basamaklar, sudan kilere

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
var _bat_label: Label
var _qt := 0.0                      # sarsıntı evresinde geçen süre
var _next_shot := 3.0
var _shot_n := 0
var _wave := Vector3.ZERO           # atışın dalgası (kayığı yana iter)
var _roll := 0.0                    # kayığın yalpası (atış, düşen parça)
var _current := Vector3.ZERO        # çöküşün suyu
var _current_t := 0.0
var _collapsed := false
var _collapse_at := Vector3.ZERO
var _gap_route: Array[Vector3] = []
var _flicker := 0.0
var _sun: Dictionary = {}
var _sun_light: OmniLight3D
var _dark_left := 0.0               # isabetten sonra ışık elden kaymış (sn)
var _bilge := 0                     # kayığın aldığı su (isabet sayısı, en çok 3)
var _bilge_mesh: MeshInstance3D
var _hen_seen := false
var _row1_done: Array[bool] = [false, false, false]
var events: Array[String] = []      # olay günlüğü (test raporu)
var _max_lights := 0                # test: sarnıçta aynı anda görünür Omni/Spot ışık sayısının en yükseği
var _max_lights_at := ""
var _light_probe := 0.0
var _look_seq := 0


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


## İniş: Tolga kuyunun bileziğine çıkar, ipe tutunur. Kamera bacanın içinde: önce yukarı bakar (gün ışığı dairesi ve
## ip, indikçe küçülür), sonra aşağı döner (örme taş, ıslaklık, dipte genişleyen ağız ve altında açılan karanlık); ağız
## tonoza açılınca ip kopar, düşüş, karanlık su.
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
	player.global_position = Vector3(fw.x - 0.14, crown + 3.7 - player.eye_height, fw.z + 0.05)
	player.rotation.y = 0.0
	player.camera.rotation.x = deg_to_rad(68.0)
	_set_ambient(0.0)
	cis.call("well_mouth_light", true)
	var fw_well := Vector2i(CisternLevel.WELLS[0][0], CisternLevel.WELLS[0][1])
	cis.call("beam_visible", fw_well, false)
	await hud.fade_to(0.0, 0.5)
	Audio.sfx("wood_creak", -8.0, 0.8)
	if not GameState.autotest or GameState.pace:
		# Yukarı bakarak iner: ağzın ışığı küçülür
		var tw := create_tween()
		tw.tween_property(player, "global_position:y", crown + 1.3 - player.eye_height, 3.4).set_trans(Tween.TRANS_SINE)
		# Aşağı dönüş dik değil (-34°): ağzın altında sütun sıraları ve su çizgisi birlikte görünür; dik bakışta gövdeler
		# zeminsiz, boşlukta yatık çubuklar gibi okunuyordu (denetim 2, D4)
		tw.parallel().tween_property(player.camera, "rotation:x", deg_to_rad(-34.0), 2.2).set_delay(2.0).set_trans(Tween.TRANS_SINE)
		for k in 4:
			get_tree().create_timer(0.9 * k + 0.4, false).timeout.connect(Audio.sfx.bind("wood_creak", -14.0, 0.7 + 0.05 * k))
		await tw.finished
		# Aşağı bakarken ağız genişler, tonozun karanlığı açılır (replik bu sırada)
		var tw2 := create_tween()
		tw2.tween_property(player, "global_position:y", crown - 1.1 - player.eye_height, 5.0).set_trans(Tween.TRANS_SINE)
		# Ağzın altında karanlık açılırken kuyunun ışığı suya ve sütun diplerine biraz yayılır: sütunlar suyun üstünde
		# durur, boşlukta asılı gibi değil (denetim 2, D4). Suya düşünce gözler yeniden karanlıkta (hayranlık anı korunur).
		create_tween().tween_method(_set_ambient, 0.0, 0.38, 3.0).set_delay(1.0)
		# Ağız tonoza açılınca bakış ufka döner (-12°): sütunlar dik bakışta zeminsiz, yatık çubuklar gibiydi
		create_tween().tween_property(player.camera, "rotation:x", deg_to_rad(-12.0), 2.4).set_delay(1.6).set_trans(Tween.TRANS_SINE)
		await hud.say("SPK_TOLGA", "D44B_T_DOWN")
		if tw2.is_running():
			await tw2.finished
	else:
		await hud.say("SPK_TOLGA", "D44B_T_DOWN")
	Audio.sfx("paper_tear", -4.0, 0.5)          # ipin lifleri kopar
	player.shake(0.25)
	var fall := create_tween()
	fall.tween_property(player, "global_position:y", CisternLevel.WATER_Y - 1.25, 0.05 if GameState.autotest else 0.75).set_ease(Tween.EASE_IN)
	await fall.finished
	Audio.sfx("splash", -2.0, 0.8)
	_set_ambient(0.0)
	cis.call("beam_visible", fw_well, true)
	cis.call("ring", fw + Vector3(1.2, 0, 0.4), 1.6, 1.8)
	cis.call("ring", fw + Vector3(-0.8, 0, 1.3), 1.2, 1.5)
	_soft_wet(2.6)
	player.camera.rotation.x = deg_to_rad(4.0)
	player.floating = true
	player.fall_guard = false


## Suya düşüşün ıslaklığı: ekranın kenarlarında küçük, yumuşak (çerçevesiz) damlalar ve hafif mavi buğu. Ortak
## Hud.wet'in çerçeveli damlaları bu karanlık sahnede "balon" gibi okunuyordu (denetim K2).
func _soft_wet(secs: float) -> void:
	if GameState.autotest and not GameState.pace:
		return
	var layer := Control.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(layer)
	var fog := ColorRect.new()
	fog.set_anchors_preset(Control.PRESET_FULL_RECT)
	fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fog.color = Color(0.6, 0.75, 0.85, 0.08)
	layer.add_child(fog)
	var g := Gradient.new()
	g.set_color(0, Color(0.85, 0.92, 1.0, 0.5))
	g.set_color(1, Color(0.85, 0.92, 1.0, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 32
	tex.height = 32
	var vp := get_viewport().get_visible_rect().size
	for i in 12:
		var d := TextureRect.new()
		d.texture = tex
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		d.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		var r := randf_range(5.0, 11.0)
		d.size = Vector2(r, r * 1.2)
		var edge := randf_range(0.02, 0.2) if i % 2 == 0 else randf_range(0.8, 0.98)
		d.position = Vector2(vp.x * edge, randf_range(0.0, vp.y * 0.5))
		layer.add_child(d)
		var tw := d.create_tween()
		tw.tween_interval(randf_range(0.0, secs * 0.3))
		tw.tween_property(d, "position:y", d.position.y + randf_range(80.0, 240.0), secs * randf_range(0.5, 0.9)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var fade := layer.create_tween()
	fade.tween_interval(secs * 0.6)
	fade.tween_property(layer, "modulate:a", 0.0, secs * 0.4)
	fade.tween_callback(layer.queue_free)


func _build_cistern() -> void:
	cis = CisternLevel.new()
	add_child(cis)
	# Fener (telefon): kameraya bağlı, gölgeli; dolgu ışığı (suyun ve sütunların geri yansıttığı) zayıf, gölgesiz
	_spot = SpotLight3D.new()
	_spot.light_color = Color("f4f0ff")
	_spot.spot_angle_attenuation = 1.6
	_spot.spot_attenuation = 0.8
	# Gölgesiz: ışık kameranın 22 cm altından çıktığı için başlık yapraklarının gölgesi gövdelerde "alev gibi" siyah
	# lekeler olarak uzuyordu (denetim: sütun gövdelerindeki leke deseni); fenerin gölgesi zaten bakışın arkasına düşer
	_spot.shadow_enabled = false
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


## Ortam ışığı: 0 karanlık (gözler alışmadı), 1 alışmış (uzak sıralar sönük sise gömülür, su uzakta parlar),
## 1'in üstü: tonoz yarığından gün ışığı
func _set_ambient(k: float) -> void:
	if cis:
		cis.call("set_light", lerpf(AMBIENT_DARK, AMBIENT_LIT, k), k)


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
	cis.call("well_mouth_light", false)          # yalnız iniş ve karanlık anı için (ışık bütçesi)
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
	# Kararma yok: kamera 0,3 sn'de kayıktaki oturağa süzülür, bakış kayığın burnuna döner (denetim 2, D5)
	var was := player.frozen
	player.frozen = true
	var yaw0 := player.rotation.y
	var bd := 0.3 if (not GameState.autotest or GameState.pace) else 0.05
	var btw := create_tween().set_parallel()
	btw.tween_property(player, "global_position", boat.to_global(SEAT), bd).set_trans(Tween.TRANS_SINE)
	btw.tween_property(player, "rotation:y", yaw0 + wrapf(_boat_yaw - yaw0, -PI, PI), bd).set_trans(Tween.TRANS_SINE)
	btw.tween_property(player, "eye_height", 1.12, bd)
	btw.tween_property(player.camera, "rotation:x", deg_to_rad(-6.0), bd)
	await btw.finished
	player.pinned = true
	player.eye_height = 1.12
	_seat_player()
	player.rotation.y = _boat_yaw
	_player_yaw_last = player.rotation.y
	player.frozen = was


## İlk kürek evresi: Yakovos'un meşalesi ~45 m ötede. Yolda üç küçük olay (yolun kesirlerine bağlı; kürek çeken her
## oyuncu görür): balık sürüsü kayığın altından geçer, uzaktan ilk top ve tonozdan toz, karanlıkta bir şıpırtı (Nihat).
func _row_to_torch() -> void:
	phase = "row"
	yboat.visible = true
	_torch_light.visible = true
	meter.enabled = true
	hud.set_objective(GameState.tr_pad("UI_OBJ44_ROW"), yboat.global_position + Vector3(0, 1.6, 0))
	await hud.say("SPK_TOLGA", "D44B_T_BOAT")
	var target := yboat.global_position + Vector3(2.9, 0, 0)
	_route = _plan(boat.global_position, target)
	var d0 := _flat(boat.global_position - target)
	# Yakovos'un kayığının yanına (kürek boyu): konuşma yakın mesafede
	while _flat(boat.global_position - yboat.global_position) > 3.4:
		await get_tree().process_frame
		var prog := 1.0 - _flat(boat.global_position - target) / maxf(d0, 1.0)
		for k in ROW1_EVENTS.size():
			if not _row1_done[k] and prog >= float(ROW1_EVENTS[k]):
				_row1_done[k] = true
				match k:
					0: _ev_fish()
					1: _ev_far_shot()
					_: _ev_splash()
	meter.enabled = false
	hud.set_objective("")


func _flat(v: Vector3) -> float:
	return Vector2(v.x, v.z).length()


func _fwd() -> Vector3:
	return -Vector3(sin(_boat_yaw), 0, cos(_boat_yaw))


## Olay 1: bir sazan sürüsü pruvanın 3,5–4 m önünden soldan sağa geçer (sırtları suyu yarar, beşi sıçrar: fenerin
## konisinde gümüş gövdeler, halkalar, şıpırtı), sonra kayığa kıvrılıp altına dalar; Tolga'nın repliği geçtikten sonra.
## Balıklar yandan okunur gövdeli (yassı sazan: boyu 45 cm, eni 7 cm); eski düz üçgenler yatay bakışta ince çizgiydi
## (denetim 2, D9).
func _ev_fish() -> void:
	events.append("fish")
	var n := 14
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = cis.call("carp_mesh")
	mm.instance_count = n
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color("c8b88a")
	fm.metallic = 0.45
	fm.roughness = 0.3
	fm.emission_enabled = true
	fm.emission = Color("5e5640")
	fm.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = fm
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var f := _fwd()
	var side := Vector3(-f.z, 0, f.x)
	# Yol KAYIĞA GÖRE (her karede kayığın o anki yerinden): kayık 2–3 m/sn giderken dünyaya sabit yol sürüyü hemen
	# geride bırakıyordu. Soldan pruvanın 4 m önüne, ortada 3,6 m, sağda kayığa kıvrılıp altına.
	var pts := [f * 4.2 - side * 3.6, f * 3.8 - side * 0.6, f * 3.4 + side * 1.8, f * 0.6 + side * 0.6]
	var offs: Array[Vector3] = []
	for k in n:
		offs.append(Vector3(randf_range(-0.7, 0.7), 0.0, randf_range(-0.5, 0.5)))
	var leap_at := [0.18, 0.27, 0.36, 0.44, 0.52]          # yol kesri: sıçrayan beş balık
	var leap_k := [2, 7, 4, 11, 9]
	var dur := 4.2
	var t := 0.0
	var rang := 0.0
	var barked := false
	Audio.sfx("splash", -16.0, 1.9)
	while t < dur and is_instance_valid(mi):
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var k0 := t / dur
		var seg := minf(k0 * 3.0, 2.999)
		var si := int(seg)
		var c: Vector3 = boat.global_position + (pts[si] as Vector3).lerp(pts[si + 1], seg - si)
		var dir: Vector3 = ((pts[si + 1] as Vector3) - (pts[si] as Vector3)).normalized()
		var bs := Basis.looking_at(dir, Vector3.UP).rotated(Vector3.UP, PI)
		var dive := smoothstep(0.62, 1.0, k0)
		for k in n:
			var wob := side * sin(t * 6.0 + k) * 0.06
			var y := lerpf(-0.07, -0.55, dive) + sin(t * 4.0 + k * 1.7) * 0.03
			var b := bs.rotated(dir, sin(t * 11.0 + k) * 0.12)
			for q in leap_k.size():
				if leap_k[q] == k:
					var lk := (k0 - float(leap_at[q])) / 0.14
					if lk > 0.0 and lk < 1.0:
						y = 0.62 * 4.0 * lk * (1.0 - lk) - 0.05
						b = bs.rotated(bs.x, (0.5 - lk) * 1.6)
						if lk < dt / (0.14 * dur) * 1.5 or absf(lk - 1.0) < dt / (0.14 * dur) * 1.5:
							cis.call("ring", c + offs[k], 0.7, 1.1)
							Audio.sfx("splash", -14.0, 1.6 + randf() * 0.4)
			mm.set_instance_transform(k, Transform3D(b, Vector3(c.x, CisternLevel.WATER_Y + y, c.z) + offs[k] + wob))
		rang += dt
		if rang > 0.16 and dive < 0.5:
			rang = 0.0
			cis.call("ring", c + Vector3(randf_range(-0.8, 0.8), 0, randf_range(-0.6, 0.6)), 0.45, 0.9)
		if not barked and k0 > 0.74:
			barked = true
			_roll = 0.05
			hud.bark("SPK_TOLGA", "D44B_T_FISH", 3.5)
	if not barked:
		hud.bark("SPK_TOLGA", "D44B_T_FISH", 3.5)
	mi.queue_free()


## Olay 2: uzaktan ilk top; tonoz inler, öndeki gözlerden toz süzülür, damlalar
func _ev_far_shot() -> void:
	events.append("far_shot")
	Audio.sfx("cannon", -26.0, 0.5)
	await get_tree().create_timer(0.6, false).timeout
	Audio.sfx("rumble", -12.0, 0.7)
	player.shake(0.07)
	var f := _fwd()
	for k in 3:
		var at := boat.global_position + f * (5.0 + 3.5 * k) + Vector3(-f.z, 0, f.x) * randf_range(-2.0, 2.0)
		_dust(at, 2.2, 30)
		cis.call("ring", at, 0.5, 1.4)
	await get_tree().create_timer(0.5, false).timeout
	hud.bark("SPK_TOLGA", "D44B_T_FAR", 3.5)


## Olay 3: karanlıkta, solda bir şey suya girer (Yakovos'un zıpkını; henüz bilinmiyor); Nihat
func _ev_splash() -> void:
	events.append("splash")
	var f := _fwd()
	var at := boat.global_position + f * 3.0 - Vector3(-f.z, 0, f.x) * 6.5
	Audio.sfx("splash", -7.0, 1.2)
	cis.call("ring", at, 1.4, 1.6)
	cis.call("ring", at + Vector3(0.2, 0, 0.1), 0.7, 1.2)
	_roll = 0.03
	hud.bark("SPK_NIHAT", "D44B_N_SPLASH", 4.0)


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


## Sarsıntı: yukarıda kuşatma; her top atışında tavan inler, dalga kayığı yana iter, tonozdan parçalar düşer (önce toz
## sütunu, sudaki gölge ve halka; sonra parça, sütun gibi sıçrayan su). Büyük parçalar kayığın 2–3 m yanına düşer ve
## sallar; küçükler önüne (kaçılmazsa isabet: kayık su alır, ışık elden kayar). Rotada öndeki tonoz gözü çöker: batı
## kemerinde dar bir geçit kalır, yarıktan giren gün ışığı sütun ormanını boydan boya aydınlatır. Kuzeybatı köşede
## Medusa kuyusu. Süre dolarsa karanlıkta kalınır: Yakovos ipiyle çeker (kayıp yok).
func _quake() -> void:
	phase = "quake"
	await _tremor(0.6)
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 0.8)
	await hud.say("SPK_FISHMONGER", "D44B_Y_QUAKE")
	await hud.say("SPK_NIHAT", "D44B_N_QUAKE")
	# Kemer çöker, meşale suya düşer
	var fall_at := yboat.global_position + Vector3(1.6, 0, -0.6)
	_drop(fall_at, 8, true)
	await get_tree().create_timer(0.9, false).timeout
	_torch_flame.visible = false
	_torch_light.visible = false
	Audio.sfx("splash", -6.0, 1.3)
	cis.call("ring", yboat.global_position + Vector3(0.6, 0, 0.3), 1.0, 1.4)
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 0.8)
	await hud.say("SPK_FISHMONGER", "D44B_Y_TORCH")
	await hud.say("SPK_TOLGA", "D44B_T_LEAD")
	# Yakovos küçük kandilini yakar: ancak kendini gösterir; Tolga'nın ışığı söndüğünde yön budur
	yakovos.unequip("Spear")
	yakovos.equip("lamp")                # kandil eşyasının kendi küçük ışığı var
	await hud.say("SPK_FISHMONGER", "D44B_Y_LAMP")
	_yk_follow = true
	meter.enabled = true
	var goal: Vector3 = cis.get("exit_well")
	hud.set_objective(GameState.tr_pad("UI_OBJ44_CORNER"), goal + Vector3(0, 1.0, 0))
	player.frozen = false
	_route = _plan(boat.global_position, goal)
	_quake_left = QUAKE_TIME
	_qt = 0.0
	_next_shot = 2.5
	while true:
		await get_tree().process_frame
		if get_tree().paused:
			continue
		var dt := get_process_delta_time()
		_quake_left -= dt
		hud.set_chase(tr("UI_CH44_QUAKE") % ceili(maxf(_quake_left, 0.0)), 1.0 - _quake_left / QUAKE_TIME)
		if _flat(boat.global_position - goal) < 1.8:
			break
		if _quake_left <= 0.0:
			rescued = true
			break
	hud.set_chase("", 0.0)
	meter.enabled = false
	hud.set_objective("")
	if rescued:
		await _rescue(goal)


## Sarsıntı evresinin kare işleri: atışlar, düşen parçalar, çöküş ve gün ışığı, akıntı, gözyaşı sütunu
func _quake_tick(delta: float) -> void:
	_qt += delta
	_next_shot -= delta
	if _next_shot <= 0.0 and phase == "quake" and _yk_follow:
		var k := clampf(_qt / QUAKE_TIME, 0.0, 1.0)
		_next_shot = lerpf(SHOT_GAP_START, SHOT_GAP_END, k)
		_shot_n += 1
		_cannon_shot()
	_bricks_tick(delta)
	if not _collapsed and _yk_follow and phase == "quake":
		_check_collapse()
	if _current_t > 0.0:
		_current_t -= delta
	if not _hen_seen and phase == "quake":
		var he := CisternLevel.column(CisternLevel.HEN_EYE[0], CisternLevel.HEN_EYE[1])
		if _flat(boat.global_position - he) < 4.5:
			_hen_seen = true
			events.append("hen_eye")
			hud.bark("SPK_TOLGA", "D44B_T_HENEYE", 4.0)
			_glance(he + Vector3(0, 3.6, 0), 0.7)


## Bakışı kısa bir an bir noktaya çevirir (denetim en çok secs alınır; kayık yoluna devam eder)
func _glance(point: Vector3, secs: float) -> void:
	if player.frozen:
		return
	await _turn_to(point, secs)


## Top atışı: uzak gümbürtü, tavanın inlemesi, dalga (kayık yana itilir ve yalpalar), toz; bir parça düşer. Tek
## atışlar küçük parçayı kayığın önüne (kaçılmalı), çiftler büyük parçayı yanına (2–3 m; isabet etmez, sallar) atar.
func _cannon_shot() -> void:
	Audio.sfx("cannon", -18.0, 0.55)
	Audio.sfx("rumble", -7.0, 0.85)
	Audio.sfx("wood_creak", -10.0, 0.45)      # tonozun inlemesi
	player.shake(0.16)
	var f := _fwd()
	var side := Vector3(-f.z, 0, f.x) * (1.0 if randf() < 0.5 else -1.0)
	_wave = side * WAVE_PUSH
	_roll = 0.07 * signf(side.x + side.z + 0.001)
	for k in 3:
		_dust(boat.global_position + f * randf_range(2.0, 9.0) + side * randf_range(-4.0, 4.0), 1.4, 24)
	var spd := maxf(_boat_speed, 0.6)
	# Test (hit): bot ilk küçük parçanın altında durur: isabet yolu (su alma, karanlık, ışığın bulunması) sınanır
	if GameState.autotest and GameState.autotest_variant == "hit" and hits == 0 and _shot_n % 2 == 1:
		_bot_hold = WARN_SECS + 1.5
		_boat_speed = 0.0              # süzülüp parçanın altından çıkmasın (PACE'te gerçek hızda)
		_wave = Vector3.ZERO
		_drop(boat.global_position, 4)
		return
	if _shot_n % 2 == 1:
		var lat := Vector3(-f.z, 0, f.x) * randf_range(-0.8, 0.8)
		_drop(boat.global_position + f * randf_range(3.5, 6.0) * spd + lat, 4 + randi() % 3)
	else:
		var at := boat.global_position + f * (1.2 + spd * WARN_SECS * 0.8) + side * randf_range(BIG_SIDE_MIN, BIG_SIDE_MAX) * 1.0
		at += cis.call("push_out", at, 0.6) as Vector3
		_drop(at, 6, true)


## Çöküş: kayık hedef sırasına girip öndeki göze yaklaşınca (ya da en geç COLLAPSE_LATEST'te) kayığın COLLAPSE_AHEAD göz
## önündeki tonoz gözü çöker. Gözün kuzey ve güney kemeri tümüyle, batı kemeri kuzey ucunda GAP'lik bir geçit bırakarak
## suya iner (kırık kemer, devrilen bir sütun kasnağı, moloz). Yarıktan gün ışığı girer.
func _check_collapse() -> void:
	var goal: Vector3 = cis.get("exit_well")
	var gbx := int(floor((goal.x + CisternLevel.HALF_X) / CisternLevel.SX))
	var gbz := int(floor((goal.z + CisternLevel.HALF_Z) / CisternLevel.SZ))
	var p := boat.global_position
	var bx := int(floor((p.x + CisternLevel.HALF_X) / CisternLevel.SX))
	var bz := int(floor((p.z + CisternLevel.HALF_Z) / CisternLevel.SZ))
	var cbx := -1
	var cbz := gbz
	if bz == gbz and bx - COLLAPSE_AHEAD >= gbx + 2:
		cbx = bx - COLLAPSE_AHEAD
	elif _qt >= COLLAPSE_LATEST:
		var f := _fwd()
		cbx = clampi(bx + int(roundf(f.x * COLLAPSE_AHEAD)), gbx + 2, CisternLevel.NX - 2)
		cbz = clampi(bz + int(roundf(f.z * COLLAPSE_AHEAD)), 1, CisternLevel.NZ - 1)
	if cbx < 0:
		return
	_collapsed = true
	_collapse(cbx, cbz)


func _collapse(cbx: int, cbz: int) -> void:
	events.append("collapse")
	var c := CisternLevel.bay(cbx, cbz)
	_collapse_at = c
	var hx := CisternLevel.SX * 0.5
	var hz := CisternLevel.SZ * 0.5
	var sr := CisternLevel.SHAFT_R
	# Uyarı: tonoz çatırdar, gözün her yanından toz, fener titrer
	Audio.sfx("wood_creak", -4.0, 0.35)
	Audio.sfx("rumble", -2.0, 0.6)
	player.shake(0.3)
	_flicker = FLICKER_SECS
	for k in 6:
		_dust(c + Vector3(randf_range(-hx, hx), 0, randf_range(-hz, hz)), 1.6, 40)
	hud.bark("SPK_NIHAT", "D44B_N_COLLAPSE", 3.5)
	await get_tree().create_timer(1.4, false).timeout
	if cis == null:
		return
	# Kemerler ve kasnak suya iner (engeller önce: kayık içine düşemez, itilir)
	var slab_r := 0.42
	var nw := Vector3(c.x - hx, 0, c.z - hz)
	var sw := Vector3(c.x - hx, 0, c.z + hz)
	var ne := Vector3(c.x + hx, 0, c.z - hz)
	var se := Vector3(c.x + hx, 0, c.z + hz)
	var west_end := nw + Vector3(0, 0, sr + GAP + slab_r)
	cis.call("add_obstacle", sw, west_end, slab_r)
	cis.call("add_obstacle", nw + Vector3(sr + slab_r, 0, 0), ne - Vector3(sr + slab_r, 0, 0), slab_r)
	cis.call("add_obstacle", sw + Vector3(sr + slab_r, 0, 0), se - Vector3(sr + slab_r, 0, 0), slab_r)
	_gap_route = [Vector3(c.x - 0.4, 0, nw.z + sr + GAP * 0.5), Vector3(nw.x, 0, nw.z + sr + GAP * 0.5),
		Vector3(nw.x - 2.0, 0, nw.z + sr + GAP * 0.5), CisternLevel.bay(cbx - 1, cbz)]
	if GameState.autotest and not _route.is_empty():
		var rest: Array[Vector3] = []
		rest.append_array(_gap_route)
		rest.append_array(_plan(CisternLevel.bay(cbx - 1, cbz), cis.get("exit_well")))
		_route = rest
	_fall_slab(sw, west_end, Color("8a5034"))
	_fall_slab(nw + Vector3(sr, 0, 0), ne - Vector3(sr, 0, 0), Color("7a4a30"))
	_fall_slab(sw + Vector3(sr, 0, 0), se - Vector3(sr, 0, 0), Color("8a5a3a"))
	_fall_drum(c + Vector3(-hx + 0.6, 0, hz * 0.2))
	Audio.sfx("cannon", -6.0, 0.4)
	Audio.sfx("splash", 0.0, 0.6)
	player.shake(0.45)
	_roll = 0.12
	_current = (p_flat(boat.global_position) - Vector3(c.x, 0, c.z)).normalized() * CURRENT_SPEED
	_current_t = CURRENT_SECS
	await get_tree().create_timer(0.9, false).timeout
	if cis == null:
		return
	for k in 4:
		var at := c + Vector3(randf_range(-hx, hx), 0, randf_range(-hz, hz))
		cis.call("ring", at, 2.4, 1.8)
		_splash_column(at, 2.6)
	_sunburst(cbx, cbz)


func p_flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0, v.z)


## Kırık kemer: a–b boyunca suya inen tuğla kütlesi (yarısı suda)
func _fall_slab(a: Vector3, b: Vector3, col: Color) -> void:
	var mid := (a + b) * 0.5
	var len := _flat(b - a)
	var slab := Props.box(cis, Vector3(0.8, 0.7, len), Vector3(mid.x, CisternLevel.IMPOST_Y + 1.6, mid.z), col)
	slab.look_at_from_position(slab.position, Vector3(b.x, slab.position.y, b.z), Vector3.UP)
	slab.rotate_object_local(Vector3.FORWARD, randf_range(-0.25, 0.25))
	slab.rotate_object_local(Vector3.RIGHT, randf_range(-0.12, 0.12))
	slab.material_override = cis.call("brick_mat")          # örme tuğla (düz turuncu kutu değil)
	var tw := slab.create_tween()
	# Suya gömülür: yalnız sırtı (≈ 0,15 m) su üstünde kalır
	tw.tween_property(slab, "position:y", CisternLevel.WATER_Y - 0.2, 0.9).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	for k in 3:
		var bit := Props.box(cis, Vector3(0.4, 0.3, 0.5), a.lerp(b, randf()) + Vector3(randf_range(-0.6, 0.6), CisternLevel.WATER_Y - 0.02, randf_range(-0.6, 0.6)),
			col.lerp(Color("b8a890"), 0.4), Vector3(randf() * 40, randf() * 180, randf() * 40))
		bit.material_override = cis.call("brick_mat")
		bit.visible = false
		get_tree().create_timer(0.9, false).timeout.connect(func(): if is_instance_valid(bit): bit.visible = true)


## Devrilen sütun kasnağı: dik durur, ağır ağır yatar, suya gömülür
func _fall_drum(at: Vector3) -> void:
	var drum := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.36
	cm.bottom_radius = 0.38
	cm.height = 2.4
	cm.radial_segments = 12
	drum.mesh = cm
	drum.material_override = cis.call("marble_mat", Color("c8c2b4"))
	cis.add_child(drum)
	drum.global_position = Vector3(at.x, CisternLevel.WATER_Y + 2.6, at.z)
	var tw := drum.create_tween().set_parallel()
	tw.tween_property(drum, "rotation:x", PI * 0.5, 1.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(drum, "global_position:y", CisternLevel.WATER_Y - 0.14, 1.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)


## Doruk: çöken gözün yarığından gün ışığı. Geniş huzme, tozlar; güçlü bir ışık sütun ormanını boydan boya aydınlatır,
## sonra yarıktan kalıcı bir huzme kalır. Tolga ve Nihat.
func _sunburst(cbx: int, cbz: int) -> void:
	events.append("sun")
	_sun = cis.call("breach", cbx, cbz)
	_sun_light = OmniLight3D.new()
	_sun_light.light_color = Color("fff0d8")
	_sun_light.light_energy = 0.0
	_sun_light.omni_range = 46.0
	_sun_light.omni_attenuation = 0.55
	_sun_light.shadow_enabled = false
	_sun_light.name = "SunBurst"
	cis.add_child(_sun_light)
	_sun_light.global_position = (_sun["pos"] as Vector3) + Vector3(0, 6.5, 0)
	var card_mat := (_sun["card"] as MeshInstance3D).material_override as StandardMaterial3D
	var tw := create_tween()
	tw.tween_property(_sun_light, "light_energy", SUN_PEAK, 0.5)
	tw.parallel().tween_property(card_mat, "albedo_color:a", 0.95, 0.5)
	tw.parallel().tween_method(_set_ambient, 1.0, 2.2, 0.5)
	tw.tween_interval(SUN_PEAK_SECS)
	tw.tween_property(_sun_light, "light_energy", SUN_REST, 3.0)
	tw.parallel().tween_property(card_mat, "albedo_color:a", 0.5, 3.0)
	tw.parallel().tween_method(_set_ambient, 2.2, 1.0, 3.0)
	hud.bark("SPK_TOLGA", "D44B_T_SUN", 4.5)
	hud.bark("SPK_NIHAT", "D44B_N_SUN", 4.0)
	# Yarıktan arada bir parça düşmeye devam eder (geçidin yanında: geçerken de tetikte)
	for k in 3:
		get_tree().create_timer(5.0 + k * 6.0, false).timeout.connect(func():
			if cis and phase == "quake":
				_drop((_sun["pos"] as Vector3) + Vector3(randf_range(-1.2, 1.2), 0, randf_range(-1.2, 1.2)), 4, true))


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


## Medusa köşesi: kayık iki sütunun MEDUSA_STOP m güneyine yan yanaşır (kürekler içeride; iki taş yüz aynı kadrajda).
## Sarsıntı dipteki çamuru silkelemiştir; Yakovos kandilini suya eğer: yüzleri ilk kez o görür (denetim K6). Taş yüzü
## kayda geçir (tespit karesi).
func _medusa() -> void:
	phase = "medusa"
	player.frozen = true
	var heads: Array = cis.get("medusa")
	var head: Node3D = heads[0]
	var aim := head.get_node("Aim") as Node3D
	if not light_on:
		_toggle_light()
	_yk_follow = false
	for o: Node3D in _oars:
		o.visible = false
	var h2: Node3D = heads[1]
	var mid := (head.global_position + h2.global_position) * 0.5
	var stop := Vector3(mid.x, boat.global_position.y, mid.z + MEDUSA_STOP)
	var yaw1 := _boat_yaw + wrapf(-PI * 0.5 - _boat_yaw, -PI, PI)
	var d := 0.3 if GameState.autotest else 2.0
	var tw := create_tween().set_parallel()
	tw.tween_method(func(k: float):
		var y := lerpf(_boat_yaw, yaw1, k)
		player.rotation.y += y - _boat_yaw
		_boat_yaw = y
		boat.global_position = boat.global_position.lerp(stop, k), 0.0, 1.0, d)
	var side_at := stop + Vector3(2.2, 0, 1.4)
	tw.tween_property(yboat, "global_position", Vector3(side_at.x, yboat.global_position.y, side_at.z), d)
	await tw.finished
	# Yakovos'un kandili suya eğilir: ışık iki yüzün ARASINDA ve hemen önünde, yüzlere yandan (sıyırarak) vurur:
	# kaş, göz çukuru, burun ve dudak gölge verir (önden düz ışıkta yüz "yumurta" gibi okunuyordu: denetim 2, K4)
	var glow := OmniLight3D.new()
	glow.light_color = Color("ffbe78")
	glow.light_energy = 3.0
	glow.omni_range = 5.5
	glow.omni_attenuation = 1.3
	glow.shadow_enabled = false
	glow.name = "MedusaLamp"
	cis.add_child(glow)
	glow.global_position = Vector3(mid.x, CisternLevel.WATER_Y + 0.12, mid.z + 1.05)
	cis.call("clear_water", mid + Vector3(0, 0, 0.4), 4.4)
	var look_mid := Vector3(mid.x, CisternLevel.MEDUSA_Y - 0.1, mid.z + 0.4)
	var fov0 := player.camera.fov
	await _turn_to(look_mid, 1.4)
	await hud.say("SPK_FISHMONGER", "D44B_Y_STONE")
	hud.set_objective(GameState.tr_pad("UI_OBJ44_MEDUSA"), aim.global_position)
	player.frozen = false
	# Tespit: telefonun kamerası yakınlaştırır (yüz kadrajın beşte biri kadar: göz, burun, ağız seçilir)
	_zoom(MEDUSA_FOV, 0.6)
	cam = TespitCam.new(player, hud, aim, "siege44")
	hud.add_child(cam)
	cam.max_dist = 14.0
	cam.cone_deg = 14.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	if GameState.autotest:
		await _turn_to(aim.global_position, 0.6)
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 90.0):
		await get_tree().process_frame
		if get_tree().paused:
			continue
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true          # konuşma boyunca; tırmanma hedefi gelince yeniden serbest
	hud.set_objective("")
	# "Biri yan, biri ters": bakış önce yan yatık başa, sonra ters başa (yakın); ikinci replikte ikisi birden
	var face1 := head.to_global(Vector3(0, 0, 0.3))
	var face2 := h2.to_global(Vector3(0, 0, 0.3))
	await _turn_to(face1, 0.8)
	_look_seq += 1
	_turn_later(face2, 2.4, 0.9, _look_seq)
	await hud.say("SPK_TOLGA", "D44B_T_MEDUSA_1")
	_look_seq += 1
	_zoom(fov0, 0.8)
	await _turn_to(look_mid, 0.8)
	await hud.say("SPK_TOLGA", "D44B_T_MEDUSA_2")
	await _turn_to(yakovos.global_position + Vector3(0, 1.3, 0), 1.0)
	await hud.say("SPK_FISHMONGER", "D44B_Y_MEDUSA")
	await _turn_to(look_mid, 0.8)
	await hud.say("SPK_NIHAT", "D44B_N_MEDUSA")
	player.camera.fov = fov0
	glow.visible = false


## Gecikmeli bakış (replik sürerken ikinci başa döner); arada başka bir bakış başladıysa (seq değişti) yapılmaz
func _turn_later(point: Vector3, delay: float, secs: float, seq: int) -> void:
	await get_tree().create_timer(delay, false).timeout
	if seq == _look_seq and phase == "medusa":
		await _turn_to(point, secs)


## Görüş açısını yumuşakça değiştirir (Medusa'da telefonun yakınlaştırması)
func _zoom(fov: float, secs: float) -> void:
	var tw := create_tween()
	tw.tween_property(player.camera, "fov", fov, 0.05 if GameState.autotest and not GameState.pace else secs).set_trans(Tween.TRANS_SINE)


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


## Çıkış: Medusa sütunlarının güneyindeki tonoz gözünde Yakovos'un kuyusu. Sudan tonoza ip merdiven, bacada demir
## basamaklar; yukarıda kilerin ışığı ve açık kapıdan gün ışığı. Tırmanış görünür (kararma yok), kilerde replik, sonra
## kısa kararma ile avlu.
func _climb() -> void:
	phase = "exit"
	var goal: Vector3 = cis.get("exit_well")
	var rungs := Props.interactable(cis, "rungs", Vector3(1.4, 2.4, 1.4), goal + Vector3(0, 1.2, 0))
	rungs.name = "Rungs"
	cis.call("cellar_on", true, false)
	cis.call("ladder_down", 0.0 if GameState.autotest and not GameState.pace else 1.2)          # Yakovos ip merdiveni salar
	if _sun_light:
		_sun_light.visible = false          # ışık bütçesi: kilerin ışığı yanar, yarığın ışığı söner (uzakta kaldı)
	hud.set_objective(tr("UI_OBJ44_CLIMB"), goal + Vector3(0, 2.0, 0))
	player.frozen = false
	if GameState.autotest:
		_on_interact("rungs")
	while phase == "exit":
		await get_tree().process_frame
	phase = "climb"
	hud.set_objective("")
	hud.set_prompt("")
	meter.enabled = false
	player.pinned = false
	player.frozen = true
	var crown := CisternLevel.IMPOST_Y + CisternLevel.VAULT_H
	var floor_y := crown + 4.6
	player.eye_height = Player.EYE
	player.global_position = Vector3(goal.x, CisternLevel.WATER_Y + 0.25, goal.z + 0.12)
	player.rotation.y = 0.0            # merdiven kuzey yüzde: ona dönük
	player.camera.rotation.x = deg_to_rad(52.0)
	# Fener cebe: bacanın taşına 0,5 m'den vuran spot ekranda dev bir "yumurta" ışık lekesi yapıyordu (denetim 2, D3).
	# Bacayı yukarıdaki kilerin ışığı ve tavandaki ağızdan inen ışık kartı aydınlatır; basamaklar paslı demir, açık renk.
	_light_off()
	# Kilerde durulacak yer ve bakış: kuzeydoğudan güneybatıya; sağda raflar ve turşu küpleri, ortada kuyu bileziği ve
	# fıçı, solda içeri açılmış kapıdan avlunun ışığı (denetim 2, D2: eskiden düz duvara ve beyaz kapıya bakılıyordu)
	var stand := Vector3(goal.x + 1.3, floor_y, goal.z - 0.9)
	var look_dir := Vector3(-0.78, 0.0, 0.63).normalized()
	var stand_yaw := atan2(-look_dir.x, -look_dir.z)
	if not GameState.autotest or GameState.pace:
		var tw := create_tween()
		tw.tween_property(player, "global_position:y", floor_y + 0.05, CLIMB_SECS).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(player.camera, "rotation:x", deg_to_rad(20.0), CLIMB_SECS * 0.5).set_delay(CLIMB_SECS * 0.5)
		for k in int(CLIMB_SECS / 0.45):
			get_tree().create_timer(0.45 * k, false).timeout.connect(Audio.sfx.bind("footstep_stone_%d" % (k % 4 + 1), -10.0, 0.8))
		get_tree().create_timer(CLIMB_SECS * 0.6, false).timeout.connect(cis.call.bind("cellar_on", true, true))
		await tw.finished
		# Kilerin ağzından çıkar, bileziğin yanına basar, kileri görür
		var tw2 := create_tween().set_parallel()
		tw2.tween_property(player, "global_position", stand, 1.0).set_trans(Tween.TRANS_SINE)
		tw2.tween_property(player, "rotation:y", stand_yaw, 1.0).set_trans(Tween.TRANS_SINE)
		tw2.tween_property(player.camera, "rotation:x", deg_to_rad(-13.0), 1.0)
		await tw2.finished
	else:
		cis.call("cellar_on", true, true)
		player.global_position = stand
		player.rotation.y = stand_yaw
		player.camera.rotation.x = deg_to_rad(-13.0)
	await hud.say("SPK_TOLGA", "D44B_T_CLIMB")
	await hud.fade_to(1.0, 0.5)


## Avluya dönüş: Yakovos'un kilerinden çıkılır; Eudokia, komşular. Seçim: sırrı koru ya da ağzından kaçır.
func _yard_end() -> void:
	phase = "end"
	_light_off()
	if cis:
		remove_child(cis)
		cis.queue_free()
		cis = null
		for n: Node3D in [boat, yboat]:
			if n and is_instance_valid(n):
				n.queue_free()
		boat = null
		yboat = null
		_sun_light = null
	player.gravity_on = true
	player.floating = false
	player.fall_guard = true
	player.eye_height = Player.EYE
	Audio.ambience("amb_city_day")
	Audio.voice_space("outdoor")
	Audio.music("byzantium_evening")
	_build_city()
	await get_tree().process_frame
	# Konuşanlar oyuncunun önünde, kuyunun SOLUNDA bir yay üstünde (oyuncudan 3–3,6 m): kuyunun çatkısının arkasında
	# kalmazlar (denetim 2, D8: Eudokia ve komşular kuyunun ardında, ayakları bileziğin arkasında kalıyordu). Kuyu
	# kadrajın sağ yanında; bakış yayın ortasına.
	var pp := HOUSE_DOOR + Vector3(0.3, 0, 1.4)
	player.global_position = pp
	var arc := func(deg: float, r: float) -> Vector3:
		return pp + Vector3(cos(deg_to_rad(deg)), 0, sin(deg_to_rad(deg))) * r
	player.face(arc.call(64.0, 3.2) + Vector3(0, 1.2, 0))
	eudokia.position = arc.call(56.0, 3.4)
	eudokia.look_target = player
	if kid:
		kid.position = arc.call(47.0, 2.2)      # oyuncunun önünde, kuyunun solunda (Eudokia'nın önünde değil, yanında)
		kid.look_target = player
	yakovos = _make_yakovos()
	yakovos.position = arc.call(69.0, 3.0)
	yakovos.look_target = player
	add_child(yakovos)
	neighbors.append(yakovos)
	for k in 2:
		var n := Person.new({"coat": [Color("6a5040"), Color("5a6a7a")][k], "pants": Color("3a3028"), "hat": "none" if k == 0 else "hood",
			"beard": k == 0, "mustache": true, "hair": Color("3a2a1e")})
		n.set_meta("spk", "SPK_TOWNSMAN")
		n.position = arc.call(82.0 + k * 13.0, 3.5)
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
	_bilge_mesh = boat.get_node("Bilge") as MeshInstance3D
	_my_grip = OarGrip.phantom(boat, Transform3D(Basis(), SEAT + Vector3(0, 0, 0.0)), [[l, "auto"], [r, "auto"]], CisternLevel.WATER_Y, true)
	# Yakovos: batıda, uzakta, kayığında meşale ve zıpkın
	yboat = _skiff(Color("3a2a1c"))
	add_child(yboat)
	var yat := CisternLevel.bay(YAKOVOS_BAY.x, YAKOVOS_BAY.y)
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
	var bilge := Props.box(g, Vector3(0.9, 0.02, 2.4), Vector3(0, 0.08, 0), Color("2a3028"))
	bilge.name = "Bilge"
	return g


func _boat_place(p: Vector3, yaw: float) -> void:
	_boat_yaw = yaw
	boat.global_position = Vector3(p.x, CisternLevel.WATER_Y - 0.12 + sin(_t * 1.3) * 0.02 - 0.03 * _bilge + _roll * 0.9 * sin(_t * 4.2), p.z)
	# Yalpa: atışın dalgası, düşen parça (sönümlü salınım). Yan yatma (z) küçük tutulur: kürekler (ortak OarGrip)
	# dünya ekseninde durur, kayık 2°'den çok yan yatınca kürek mili borda tahtasının içinden geçiyor ve borda kameranın
	# önüne dev bir levha gibi kalkıyordu (denetim 2, D7). Sarsıntı baş-kıç salınımı ve dikey çalkantı olarak verilir.
	boat.rotation = Vector3(sin(_t * 0.9) * 0.01 + _roll * 0.7 * sin(_t * 5.0), yaw, sin(_t * 1.1) * 0.008 + minf(_roll, 0.02) * sin(_t * 4.2))


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
	_roll = move_toward(_roll, 0.0, delta * 0.05)
	if GameState.autotest and cis:
		_light_probe -= delta
		if _light_probe <= 0.0:
			_light_probe = 0.25
			var n := 0
			for l: Node in find_children("*", "Light3D", true, false):
				# HUD'un SubViewport'larındaki ışıklar ayrı dünyada: sahneyi aydınlatmaz, sayılmaz
				if (l is OmniLight3D or l is SpotLight3D) and (l as Light3D).is_visible_in_tree() and l.get_viewport() == get_viewport():
					n += 1
			if n > _max_lights:
				_max_lights = n
				_max_lights_at = phase
				var names: Array[String] = []
				for l: Node in find_children("*", "Light3D", true, false):
					if (l is OmniLight3D or l is SpotLight3D) and (l as Light3D).is_visible_in_tree() and l.get_viewport() == get_viewport():
						names.append(String(l.get_path()).get_slice("/", String(l.get_path()).get_slice_count("/") - 2) + "/" + l.name)
				print("LIGHTS44 %d %s %s" % [n, phase, ",".join(names)])
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
			# Sütunların içinden geçmez (pruva, orta, kıç). Çok geride kaldıysa (çöküşün ardında) karanlıkta kendi yolunu
			# bilir: engele takılmaz, hızlanır
			var yf := -yboat.global_transform.basis.z
			if d.length() > 8.0:
				yboat.global_position += d.normalized() * minf(d.length() - 8.0, 2.0 * delta)
			else:
				for off: float in [-1.5, 0.0, 1.5]:
					yboat.global_position += cis.call("push_out", yboat.global_position - yf * off, BOAT_R) as Vector3
	if phase == "quake":
		_quake_tick(delta)
	elif _bricks.size() > 0:
		_bricks_tick(delta)
	_animate_oars()


func _animate_oars() -> void:
	if phase in ["medusa", "exit", "climb", "end"]:
		player.oar_hold(null)          # kürekler içeri alındı: taş yüzlere bakarken kadrajı kapatmasın
		return
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
	target *= 1.0 - HIT_SLOW * _bilge
	_boat_speed = move_toward(_boat_speed, target, delta * (1.2 if rowing else 0.6))
	var turn := steer * delta * (0.9 + 0.25 * _boat_speed)
	_boat_yaw += turn
	if player.pinned:
		player.rotation.y += turn
	var fwd := -Vector3(sin(_boat_yaw), 0, cos(_boat_yaw))
	var p := boat.global_position + fwd * _boat_speed * delta
	# Dalga (atış) ve çöküşün suyu kayığı sürükler
	p += _wave * delta
	_wave = _wave.move_toward(Vector3.ZERO, delta * WAVE_PUSH * 0.6)
	if _current_t > 0.0:
		p += _current * delta * clampf(_current_t / CURRENT_SECS, 0.0, 1.0)
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
		if not b["fell"] and (b["at"] as Vector3).distance_to(p + (to - p).normalized() * 2.5) < 2.4 and GameState.autotest_variant != "hit":
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
	# Pil yazısı HUD'un sağ alt köşesinde (telsizin üstünde), yalnız kürek ve sarsıntı evrelerinde; ekranın ortasında
	# nişangâhla ve konuşan kişiyle üst üste geliyordu (denetim K8)
	var show := phase in ["row", "quake"] and light_kind == "phone"
	_battery_label(show)
	if phase in ["dark", "awe", "swim", "board", "row", "yakovos", "quake", "medusa", "exit"]:
		var want := Input.is_action_just_pressed("kick") and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not player.frozen
		if want and phase != "medusa" and _dark_left <= 0.0:
			_toggle_light()
	if not light_on:
		_lighter_cool = maxf(0.0, _lighter_cool - delta)
		if phase in ["row", "quake", "swim"] and not GameState.autotest and _dark_left <= 0.0 and int(_t) % 20 == 0 and fmod(_t, 1.0) < delta:
			hud.bark("SPK_TOLGA", "D44B_T_DARK_HINT", 2.5)
		return
	# Kritik anda (çöküş) fener titrer
	if _flicker > 0.0:
		_flicker -= delta
		var on := fmod(_t * 7.3, 1.0) > 0.35 or _flicker <= 0.0
		_spot.light_energy = (6.0 if light_kind == "phone" else 1.4) * (1.0 if on else 0.08)
		_lighter_l.light_energy = 1.6 * (1.0 if on else 0.15)
	match light_kind:
		"phone":
			if not player.frozen:
				battery = maxf(0.0, battery - DRAIN * delta)
			# %3'ün altında titrer
			if battery < 3.0 and _flicker <= 0.0:
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


## Pil göstergesi: sağ alt köşe, telsiz çubuklarının üstünde; %5'in altında sarı, %3'ün altında kırmızı
func _battery_label(show: bool) -> void:
	if _bat_label == null:
		if not show:
			return
		_bat_label = Label.new()
		_bat_label.add_theme_font_size_override("font_size", 22)
		_bat_label.add_theme_constant_override("outline_size", 6)
		_bat_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		_bat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_bat_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_bat_label.name = "Battery44"
		hud.add_child(_bat_label)
	_bat_label.visible = show and not hud.is_choosing()
	if not _bat_label.visible:
		return
	var vp := get_viewport().get_visible_rect().size
	_bat_label.size = Vector2(220, 30)
	_bat_label.position = Vector2(vp.x - 244, vp.y - 92)
	_bat_label.text = tr("UI_CH44_BATTERY") % ceili(battery)
	_bat_label.add_theme_color_override("font_color", Color("ff6a5a") if battery < 3.0 else (Color("ffd36a") if battery < 5.0 else Color("e8f0f0")))


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


## Tavandan süzülen toz sütunu (yumuşak zerreler; uyarı ve sarsıntı)
func _dust(at: Vector3, secs: float, amount := 40) -> void:
	if cis == null:
		return
	var d := CPUParticles3D.new()
	d.amount = amount
	d.lifetime = 1.6
	d.one_shot = false
	d.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	d.emission_sphere_radius = 0.35
	d.direction = Vector3.DOWN
	d.spread = 10.0
	d.gravity = Vector3(0, -5.0, 0)
	d.initial_velocity_min = 0.5
	d.initial_velocity_max = 1.5
	d.scale_amount_min = 1.0
	d.scale_amount_max = 2.0
	var q := QuadMesh.new()
	q.size = Vector2(0.05, 0.05)
	q.material = cis.call("dust_material")
	d.mesh = q
	d.position = Vector3(at.x, CisternLevel.IMPOST_Y + CisternLevel.VAULT_H - 0.6, at.z)
	d.visibility_aabb = AABB(Vector3(-1, -10, -1), Vector3(2, 11, 2))
	add_child(d)
	get_tree().create_timer(secs, false).timeout.connect(func():
		if is_instance_valid(d):
			d.emitting = false
			get_tree().create_timer(1.8, false).timeout.connect(d.queue_free))


## Uyarılı düşüş: önce toz sütunu süzülür, suda koyu bir gölge büyür ve halkalar belirir (WARN_SECS), sonra parça düşer
func _drop(at: Vector3, n: int, big := false) -> void:
	var b := {"at": Vector3(at.x, CisternLevel.WATER_Y, at.z), "t": WARN_SECS, "fell": false, "n": n, "big": big}
	_bricks.append(b)
	_dust(at, WARN_SECS + 0.4, 60 if big else 40)
	cis.call("ring", at, 0.4, 1.0)
	# Gölge: suyun üstünde koyu, yumuşak kenarlı leke (düşecek yerin uyarısı)
	var sh := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2.ONE * (2.2 if big else 1.4)
	sh.mesh = qm
	sh.rotation_degrees = Vector3(-90, 0, 0)
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.7))
	g.set_color(1, Color(0, 0, 0, 0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0.0)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_texture = gt
	m.albedo_color = Color(1, 1, 1, 0.0)
	sh.material_override = m
	sh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sh)
	sh.global_position = Vector3(at.x, CisternLevel.WATER_Y + 0.03, at.z)
	sh.scale = Vector3.ONE * 0.4
	var tw := sh.create_tween().set_parallel()
	tw.tween_property(m, "albedo_color:a", 1.0, WARN_SECS)
	tw.tween_property(sh, "scale", Vector3.ONE, WARN_SECS)
	tw.chain().tween_property(m, "albedo_color:a", 0.0, 0.4)
	tw.chain().tween_callback(sh.queue_free)


func _bricks_tick(delta: float) -> void:
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


## Düşüş: tuğla ve harç parçaları tonozdan suya (büyükte iri tonoz parçası), suya çarpınca sütun gibi sıçrayan su,
## iç içe halkalar, kayık sallanır; küçük parça kayığa HIT_RADIUS'tan yakın düşerse isabet.
func _brick_fall(b: Dictionary) -> void:
	var at: Vector3 = b["at"]
	var big: bool = b["big"]
	var top := CisternLevel.IMPOST_Y + CisternLevel.VAULT_H - 0.5
	var dur := 0.85
	for k in int(b["n"]):
		var sz := Vector3(0.34, 0.06, 0.22) * 1.6
		if big:
			sz = Vector3(randf_range(0.5, 0.9), randf_range(0.22, 0.4), randf_range(0.35, 0.6)) if k < 3 else Vector3(0.4, 0.1, 0.3)
		var piece := Props.box(self, sz, Vector3(at.x + randf_range(-0.5, 0.5), top + k * 0.25, at.z + randf_range(-0.5, 0.5)),
			Color("8a5034").lerp(Color("b8a890"), randf() * 0.5), Vector3(randf() * 90, randf() * 180, randf() * 90))
		var tw := piece.create_tween()
		tw.tween_property(piece, "position:y", CisternLevel.WATER_Y - 0.6, dur).set_delay(k * 0.05).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(piece, "rotation", piece.rotation + Vector3(2.0, 1.0, 1.5), dur)
		tw.tween_callback(piece.queue_free)
	get_tree().create_timer(dur - 0.05, false).timeout.connect(func():
		if cis == null:
			return
		Audio.sfx("splash", -1.0 if big else -7.0, 0.75 if big else 0.95)
		cis.call("ring", at, 2.6 if big else 1.4, 1.7)
		_splash_column(at, 2.4 if big else 1.3)
		get_tree().create_timer(0.25, false).timeout.connect(func():
			if cis:
				cis.call("ring", at + Vector3(0.3, 0, -0.2), 1.3 if big else 0.7, 1.4))
		if boat == null or not is_instance_valid(boat):
			return
		var dist := _flat(boat.global_position - at)
		if big and dist < 4.0:
			_roll = 0.11
			_wave = p_flat(boat.global_position - at).normalized() * WAVE_PUSH * 1.2
			player.shake(0.3)
		if dist < HIT_RADIUS and not big:
			_hit())


## Suya çarpan parçanın sıçrattığı su sütunu: dikine, yukarıda incelen parlak bir kart; yükselir, çöker
func _splash_column(at: Vector3, h: float) -> void:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(0.9, 1.0)
	mi.mesh = q
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 0))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(0.5, Color(1, 1, 1, 1))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 32
	gt.height = 4
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_texture = gt
	m.albedo_color = Color(0.8, 0.88, 0.92, 0.75)
	m.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	mi.global_position = Vector3(at.x, CisternLevel.WATER_Y, at.z)
	mi.scale = Vector3(0.5, 0.05, 1)
	var tw := mi.create_tween()
	tw.tween_method(func(k: float):
		mi.scale = Vector3(0.5 + 0.7 * k, maxf(0.05, h * sin(k * PI)), 1)
		mi.global_position.y = CisternLevel.WATER_Y + mi.scale.y * 0.5
		m.albedo_color.a = 0.75 * (1.0 - k * k), 0.0, 1.0, 0.9)
	tw.tween_callback(mi.queue_free)


## İsabet: kayık su alır (yavaşlar), ışık elden kayar: kısa karanlık panik; bakış Yakovos'un kandiline döner; sonra
## ışık kayığın dibinde bulunur. Kayıp yok.
func _hit() -> void:
	hits += 1
	events.append("hit")
	_boat_speed = 0.0
	_roll = 0.14
	player.shake(0.4)
	Audio.sfx("land_thud", -3.0, 0.9)
	Audio.sfx("splash", -6.0, 1.4)
	_bilge = mini(_bilge + 1, 3)
	if _bilge_mesh:
		_bilge_mesh.position.y = 0.08 + 0.07 * _bilge
		_bilge_mesh.scale = Vector3(1.0, 1.0 + 3.0 * _bilge, 1.0)
	hud.bark("SPK_TOLGA", "D44B_T_HIT_%d" % mini(hits, 3), 2.5)
	if _dark_left > 0.0:
		return
	var was_on := light_on
	_light_off()
	_dark_left = HIT_DARK_SECS
	hud.bark("SPK_TOLGA", "D44B_T_DROP", 2.5)
	if yakovos and is_instance_valid(yakovos):
		_glance(yakovos.global_position + Vector3(0, 1.2, 0), 0.6)
	await get_tree().create_timer(HIT_DARK_SECS, false).timeout
	_dark_left = 0.0
	if phase == "quake" and was_on and not light_on:
		_toggle_light()
		events.append("found")
		hud.bark("SPK_TOLGA", "D44B_T_FOUND", 2.5)


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
	# Heyecan olayları gerçekten oldu mu: ilk kürekte üç olay, sarsıntıda çöküş + gün ışığı; rota gözyaşı sütunundan geçer
	for e: String in ["fish", "far_shot", "splash", "collapse", "sun"]:
		ok = ok and events.has(e)
	if v != "dark":
		ok = ok and events.has("hen_eye")
	if v == "hit":
		ok = ok and hits >= 1 and events.has("hit") and _bilge >= 1 and events.has("found")
	print("CISTERN44 events=%s qt=%.1f max_lights=%d (%s)" % [",".join(events), _qt, _max_lights, _max_lights_at])
	ok = ok and _max_lights <= 8
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s, foto=%s, hayranlık=%s, kurtarıldı=%s)" % [expected, _outcome,
			not page.is_empty(), cam != null and cam.done, awe_seen, rescued])
	print("AUTOTEST %s chapter=44 variant=%s outcome=%s light=%s battery=%.1f bumps=%d hits=%d rescued=%s kid=%s" % [
		"PASS" if ok else "FAIL", v, _outcome, light_kind, battery, bumps, hits, rescued, _kid_on])
	get_tree().quit(0 if ok else 1)
