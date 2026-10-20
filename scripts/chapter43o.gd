extends Node3D
## Bölüm 43 (yalnız Osmanlı tarafı) — Kuşbakışı (Tolga · 25 Mayıs 1453, Sultan'ın otağı, öğleden sonra).
##
## Büro'da kargaşa: Müfide Hanım'ın yıllık demirbaş sayımında saha deposunun kapısı yanlış tarihe açılır, dört alet
## 1453'e düşer. Biri Büro'nun keşif dronu (Z-DR1): Urban bulur, Sultan'a getirir. Kutunun yazısını okuyabilen tek
## kişi Tolga'dır. Sultan: "Uçurursan ihsan, uçuramazsan kelle." Nihat görünmezdir ve aynı anda engeller (kameranın
## önüne elini koyar, pili gevşetir); her aksaklıkta Tolga'nın bahanesi kelleyi kurtarır ya da Zağanos'u kışkırtır.
## Kullanıcı: "fatih dronela baksın hatta dronu sürmeyi tolgadan öğrensin tolga kellesi gitmemesi için yardım etmeye
## çalışsın nihat da aynı anda engel olmaya çalışsın".
##   1 Telsiz: Nihat Büro'daki kargaşayı anlatır; Tolga otağa yürür.
##   2 Otağın önü: Urban kutuyu getirir, Tolga okur ("Çocukların erişemeyeceği yerde saklayınız"); uçar mı? (seçim)
##   3 Tolga uçurur: kalkış (5 m), meydanın üstünden mutfağa (Nihat kamerayı kapatır: bahane seçimi), yüksel ve surlara dön.
##   4 Sultan öğrenir: üç soru (yükselme, dönme, ileri); yanlış cevapta kuş saçmalar. Sultan surlara uçurur ve görür:
##     surların üstü bomboş, Lykos gediği fıçı ve toprakla kapalı, içerisi bostan ve harabe (1453'te şehrin içi böyleydi).
##     Nihat pili gevşetir (görüntü karlanır: bahane seçimi). Büro kilidi kuşu surun üstüne geçirmez.
##   5 Tespit karesi: kumandanın başındaki Sultan.
##   6 Tehlike: Sultan Urban'a "bundan yüz tane yap" der. Tolga son bir uçuş ister; kuşu Kadri'nin kazanının üstüne
##     getirir, Nihat pili çeker: kuş mercimeğe düşer, çarkları erir. Yetişemezse Nihat kuşu görünmez taşır (Zağanos: cin!).
##   43O.1 Kelle yerinde (kötü bahane < 3) · 43O.2 Büyücü sanıldı, zincire vuruldu; gece Nihat çözdü
## Tarih bozulmaz: Sultan'ın gördüğü (az savunucu, gedik) zaten bilinen ve birkaç gün sonra divanda hücum kararını
## veren şeydir; kuş ordugâhta kalmaz. Sonda Nihat: Müfide Hanım bir eksik daha buldu, saha aydınlatma fişekleri, şehrin
## içinde (Bizans yarısı ve Ayasofya'daki ışık).
##   --autotest[=bad|miss]   (varsayılan: 43O.1; bad: bahanelerin hepsi kötü → 43O.2; miss: kazana yetişilmez, kuş "uçar")

const OTAG := CampDay.OTAG_POS
const STAGE := Vector3(0.0, 0.0, -47.0)            # halının ortası (sayebanın önü)
const FATIH_AT := Vector3(-1.4, 0.0, -50.6)
const ZAGANOS_AT := Vector3(-3.2, 0.0, -49.8)
const URBAN_AT := Vector3(2.4, 0.0, -48.6)
const PLAYER_AT := Vector3(1.0, 0.0, -44.4)
const CAULDRON := Vector3(-16.6, 0.0, -9.2)
## Kara surları ordugâhın yerel +z'sinde: hendek ≈ z 382, dış sur ≈ 400, iç sur ≈ 420 (World1453 "camp": dünya z =
## 418 − yerel z). Lykos vadisindeki gedik (Mesoteichion) yerel x ≈ 20. Kuşun baktığı nokta:
const WALLS_AT := Vector3(20.0, 10.0, 405.0)
## Büro kilidi: kuş hendeğin önünden (yerel z 370) öteye geçmez
const FENCE := Rect2(-160.0, -105.0, 320.0, 475.0)
const BAD_LIMIT := 3

var day: CampDay
var player: Player
var hud: Hud
var drone: Drone
var fatih: Person
var zaganos: Person
var urban: Person
var kadri: Person
var nihat: Node3D
var cam: TespitCam
var cut: Camera3D
var phase := "intro"
var _outcome := ""
var _photo := ""
var bad := 0
var lessons := 0
var soup := false
var _remote: Node3D


func _ready() -> void:
	GameState.snapshot(43)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	day = CampDay.new()
	add_child(day)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _gy(p: Vector3) -> Vector3:
	return Vector3(p.x, CampDay.height(p.x, p.z), p.z)


# ================================================================ kurulum

func _build() -> void:
	fatih = Person.new(PortraitLooks.LOOKS["SPK_FATIH"])
	fatih.set_meta("spk", "SPK_FATIH")
	fatih.set_meta("no_chat", true)
	add_child(fatih)
	fatih.global_position = _gy(FATIH_AT)
	zaganos = Person.new(PortraitLooks.LOOKS["SPK_ZAGANOS"])
	zaganos.set_meta("spk", "SPK_ZAGANOS")
	zaganos.set_meta("no_chat", true)
	add_child(zaganos)
	zaganos.global_position = _gy(ZAGANOS_AT)
	# Urban topçu alanında değil, kutuyla otağın önünde (ordugâhın kendi Urban'ı gizlenir: iki Urban olmasın)
	if day.urban:
		day.urban.visible = false
		day.urban.process_mode = Node.PROCESS_MODE_DISABLED
	urban = Person.new(PortraitLooks.LOOKS["SPK_URBAN"])
	urban.set_meta("spk", "SPK_URBAN")
	urban.set_meta("no_chat", true)
	add_child(urban)
	urban.global_position = _gy(URBAN_AT)
	kadri = day.kadri
	for p: Person in [fatih, zaganos, urban]:
		p.face_toward(_gy(PLAYER_AT))
	# Otağın önüne serilmiş halı ve dronun Büro kutusu
	var rug := Props.box(self, Vector3(3.2, 0.02, 2.2), _gy(STAGE) + Vector3(0, 0.01, 0), Color("8a2a2a"))
	rug.set_meta("no_audit", true)
	Props.box(self, Vector3(2.8, 0.021, 1.8), _gy(STAGE) + Vector3(0, 0.012, 0), Color("c89a48"))
	Props.box(self, Vector3(2.5, 0.022, 1.5), _gy(STAGE) + Vector3(0, 0.013, 0), Color("6a1e22"))
	var box := Props.box(self, Vector3(0.62, 0.22, 0.46), _gy(STAGE) + Vector3(0.9, 0.12, 0.3), Color("d8d4c8"))
	var tag := Label3D.new()
	tag.text = "ZAMAN BÜROSU\nZ-DR1 · 1453/7"
	tag.font_size = 22
	tag.pixel_size = 0.0022
	tag.modulate = Color("2a2a30")
	tag.outline_size = 0
	tag.position = Vector3(0, 0.111, 0)
	tag.rotation_degrees = Vector3(-90, 0, 0)
	box.add_child(tag)
	drone = Drone.new()
	drone.ground_fn = func(x: float, z: float) -> float: return CampDay.height(x, z)
	add_child(drone)
	drone.global_position = _gy(STAGE) + Vector3(-0.3, 0.12, 0.0)
	drone.yaw = PI                       # burnu otağa değil ordugâha (+z): kamera yerel -z'ye bakar
	drone.fence = FENCE
	Props.interactable(self, "drone", Vector3(1.2, 0.8, 1.2), _gy(STAGE) + Vector3(-0.3, 0.4, 0))
	# Nihat: görünmez; yalnız havanın kırılması (kenarları parlayan bir titreşim) seçilir
	nihat = _ghost()
	add_child(nihat)
	nihat.visible = false
	cut = Camera3D.new()
	cut.fov = 55.0
	add_child(cut)


## Görünmez Nihat: gövde ve baş biçiminde, yalnız kenarları ışıyan saydam bir titreşim (Predator gibi).
func _ghost() -> Node3D:
	var g := Node3D.new()
	var sh := Shader.new()
	sh.code = """shader_type spatial;
render_mode unshaded, cull_back, depth_draw_never, blend_mix;
uniform float strength = 0.55;
void fragment() {
	float f = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	ALBEDO = vec3(0.85, 0.95, 1.0);
	ALPHA = f * strength * (0.7 + 0.3 * sin(TIME * 7.0 + VERTEX.y * 9.0));
}"""
	var m := ShaderMaterial.new()
	m.shader = sh
	for spec in [[CapsuleMesh.new(), Vector3(0, 0.95, 0), Vector3(1, 1, 1)], [SphereMesh.new(), Vector3(0, 1.62, 0), Vector3(0.22, 0.26, 0.22)]]:
		var mi := MeshInstance3D.new()
		mi.mesh = spec[0]
		if mi.mesh is CapsuleMesh:
			(mi.mesh as CapsuleMesh).radius = 0.24
			(mi.mesh as CapsuleMesh).height = 1.5
		else:
			(mi.mesh as SphereMesh).radius = 1.0
			(mi.mesh as SphereMesh).height = 2.0
		mi.scale = spec[2]
		mi.position = spec[1]
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		g.add_child(mi)
	# Fötr şapkanın kenarı da titrer
	var hat := MeshInstance3D.new()
	var cy := CylinderMesh.new()
	cy.top_radius = 0.2
	cy.bottom_radius = 0.2
	cy.height = 0.03
	hat.mesh = cy
	hat.position = Vector3(0, 1.82, 0)
	hat.material_override = m
	g.add_child(hat)
	return g


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH43O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH43O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	player.global_position = _gy(Vector3(0.6, 0, -27.0)) + Vector3(0, 0.05, 0)
	player.face(_gy(OTAG) + Vector3(0, 3.0, 0))
	await hud.fade_to(0.0, 1.2)
	Audio.sfx("radio_static", -14.0)
	await _radio_intro()
	await _walk_to_otag()
	await _box_scene()
	await _tolga_flies()
	await _sultan_learns()
	await _sultan_sees()
	await _photo_phase()
	await _last_flight()
	await _end_talk()
	await _end_chapter()


func _radio_intro() -> void:
	await hud.say("SPK_NIHAT", "D43O_N_01")
	await hud.say("SPK_NIHAT", "D43O_N_02")
	await hud.say("SPK_TOLGA", "D43O_T_01")
	await hud.say("SPK_NIHAT", "D43O_N_03")
	await hud.say("SPK_TOLGA", "D43O_T_02")
	await hud.say("SPK_NIHAT", "D43O_N_04")


func _walk_to_otag() -> void:
	phase = "walk"
	hud.set_objective(tr("UI_OBJ43O_OTAG"), _gy(STAGE) + Vector3(0, 1.0, 0))
	player.frozen = false
	_capture_mouse()
	var t := 0.0
	while true:
		await get_tree().process_frame
		t += get_process_delta_time()
		var d := Vector2(player.global_position.x - PLAYER_AT.x, player.global_position.z - PLAYER_AT.z).length()
		if d < 2.4:
			break
		if GameState.autotest and t > 0.8:
			player.global_position = _gy(PLAYER_AT) + Vector3(0, 0.05, 0)
			break
	hud.set_objective("")
	player.frozen = true
	player.global_position = _gy(PLAYER_AT) + Vector3(0, 0.05, 0)


func _box_scene() -> void:
	phase = "box"
	player.face(fatih.global_position + Vector3(0, 1.5, 0))
	urban.talking = true
	await hud.say("SPK_URBAN", "D43O_U_01")
	urban.talking = false
	await hud.say("SPK_ZAGANOS", "D43O_Z_01")
	await hud.say("SPK_FATIH", "D43O_F_01")
	player.face(_gy(STAGE) + Vector3(0.9, 0.2, 0.3))
	await hud.say("SPK_TOLGA", "D43O_T_READ")
	player.face(fatih.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_FATIH", "D43O_F_02")
	_ghost_at(player.global_position + Vector3(-0.9, 0, 0.7))
	await hud.say("SPK_NIHAT", "D43O_N_WHISPER")
	var pick := await hud.choose(["UI_C43O_Q1_A", "UI_C43O_Q1_B", "UI_C43O_Q1_C"], 0.0, 1 if GameState.autotest_variant == "bad" else 0)
	match pick:
		1:
			bad += 1
			urban.emote("point")
			await hud.say("SPK_URBAN", "D43O_U_LIE")
			await hud.say("SPK_ZAGANOS", "D43O_Z_LIE")
		2:
			await hud.say("SPK_FATIH", "D43O_F_UNSURE")
	await hud.say("SPK_FATIH", "D43O_F_03")
	await hud.say("SPK_ZAGANOS", "D43O_Z_03")
	await hud.say("SPK_TOLGA", "D43O_T_03")
	await hud.say("SPK_NIHAT", "D43O_N_05")


## Tolga kuşu çalıştırır ve uçurur: kalkış, meydanın üstünden mutfağa (Nihat kamerayı kapatır), yüksel ve surlara dön.
func _tolga_flies() -> void:
	phase = "power"
	hud.set_objective(tr("UI_OBJ43O_POWER"), drone.global_position + Vector3(0, 0.4, 0))
	player.frozen = false
	_capture_mouse()
	var t := 0.0
	while phase == "power":
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest and t > 0.6:
			_power_on()
	hud.set_objective("")
	player.frozen = true
	player.face(drone.global_position + Vector3(0, 0.5, 0))
	await get_tree().create_timer(0.8).timeout
	drone.pilot(true)
	_view_drone(true)
	_capture_mouse()
	hud.set_prompt(tr("UI_DRONE_HELP"))
	# 1 · kalkış
	var home := drone.global_position
	hud.set_objective(tr("UI_OBJ43O_HOVER"), home + Vector3(0, 5.0, 0), 0.0)
	await _until(func(): return drone.altitude() >= 4.5, home + Vector3(0, 5.2, 0))
	await hud.say("SPK_FATIH", "D43O_F_HOVER")
	await hud.say("SPK_ZAGANOS", "D43O_Z_HOVER")
	# 2 · meydanın üstünden mutfağa; yarı yolda Nihat'ın eli
	var kitchen := _gy(CAULDRON) + Vector3(4.0, 7.0, 3.0)
	hud.set_objective(tr("UI_OBJ43O_KITCHEN"), kitchen, 0.0)
	await _until(func(): return _hdist(drone.global_position, kitchen) < 14.0, kitchen)
	_ghost_at(player.global_position + Vector3(-0.7, 0, 0.5))
	drone.cover_lens(true)
	Audio.sfx("cloth", -6.0)
	await get_tree().create_timer(0.6).timeout
	hud.set_objective("")
	await hud.say("SPK_FATIH", "D43O_F_DARK")
	var pick := await hud.choose(["UI_C43O_DARK_A", "UI_C43O_DARK_B", "UI_C43O_DARK_C"], 0.0, 2 if GameState.autotest_variant == "bad" else 1)
	match pick:
		0:
			bad += 1
			await hud.say("SPK_FATIH", "D43O_F_DARK_A")
		1:
			fatih.emote("laugh")
			await hud.say("SPK_FATIH", "D43O_F_DARK_B")
		_:
			bad += 1
			await hud.say("SPK_ZAGANOS", "D43O_Z_DARK_C")
	await hud.say("SPK_TOLGA", "D43O_T_HAND")
	await hud.say("SPK_NIHAT", "D43O_N_HAND")
	drone.cover_lens(false)
	# 3 · yüksel ve surlara dön
	var high := Vector3(drone.global_position.x, CampDay.height(drone.global_position.x, drone.global_position.z) + 31.0, drone.global_position.z)
	hud.set_objective(tr("UI_OBJ43O_HIGH"), _gy(Vector3(WALLS_AT.x, 0, 400.0)) + Vector3(0, 14.0, 0), 0.0)
	await _until(func(): return drone.altitude() >= 28.0 and _facing_walls(), high, WALLS_AT)
	hud.set_objective("")
	await hud.say("SPK_FATIH", "D43O_F_WALLS")
	hud.set_prompt("")


## Sultan kumandayı alır: üç soru; doğru cevapta kuş ister gibi davranır, yanlışta saçmalar ve Tolga düzeltir.
func _sultan_learns() -> void:
	phase = "learn"
	drone.pilot(false)
	_view_drone(true)
	await hud.say("SPK_FATIH", "D43O_F_GIVE")
	await hud.say("SPK_TOLGA", "D43O_T_GIVE")
	await hud.say("SPK_FATIH", "D43O_F_GIVE2")
	var wrong := GameState.autotest_variant == "bad"
	# Yükselme
	var a := await hud.choose(["UI_C43O_UP_A", "UI_C43O_UP_B", "UI_C43O_UP_C"], 0.0, 1 if wrong else 0)
	var p := drone.global_position
	match a:
		0:
			lessons += 1
			await drone.fly_to(p + Vector3(0, 6.0, 0), 4.0, WALLS_AT)
			await hud.say("SPK_FATIH", "D43O_F_UP_OK")
		1:
			await drone.fly_to(p + Basis(Vector3.UP, drone.yaw) * Vector3(0, -8.0, -10.0), 9.0, WALLS_AT)
			await hud.say("SPK_FATIH", "D43O_F_UP_B")
			await hud.say("SPK_TOLGA", "D43O_T_FIX")
			await drone.fly_to(p + Vector3(0, 6.0, 0), 5.0, WALLS_AT)
		_:
			await get_tree().create_timer(1.0).timeout
			await hud.say("SPK_FATIH", "D43O_F_UP_C")
			await hud.say("SPK_TOLGA", "D43O_T_FIX")
			await drone.fly_to(p + Vector3(0, 6.0, 0), 5.0, WALLS_AT)
	# Dönme
	await hud.say("SPK_FATIH", "D43O_F_TURN")
	a = await hud.choose(["UI_C43O_TURN_A", "UI_C43O_TURN_B", "UI_C43O_TURN_C"], 0.0, 2 if wrong else 0)
	match a:
		0:
			lessons += 1
			await _spin(TAU, 1.6)
			await hud.say("SPK_FATIH", "D43O_F_TURN_OK")
		1:
			fatih.rotation.y += PI
			await get_tree().create_timer(0.8).timeout
			await hud.say("SPK_FATIH", "D43O_F_TURN_B")
			fatih.face_toward(player.global_position)
			await hud.say("SPK_TOLGA", "D43O_T_FIX")
			await _spin(TAU, 1.6)
		_:
			await get_tree().create_timer(0.8).timeout
			await hud.say("SPK_FATIH", "D43O_F_TURN_C")
			await hud.say("SPK_TOLGA", "D43O_T_FIX")
			await _spin(TAU, 1.6)
	# İleri: surlara
	await hud.say("SPK_FATIH", "D43O_F_FWD")
	a = await hud.choose(["UI_C43O_FWD_A", "UI_C43O_FWD_B", "UI_C43O_FWD_C"], 0.0, 1 if wrong else 0)
	var mid := _gy(Vector3(10.0, 0, 190.0)) + Vector3(0, 40.0, 0)
	match a:
		0:
			lessons += 1
			await hud.say("SPK_FATIH", "D43O_F_FWD_OK")
			await drone.fly_to(mid, 14.0, WALLS_AT)
		1:
			var off := drone.global_position + Vector3(32.0, 6.0, 30.0)
			await drone.fly_to(off, 15.0)
			await hud.say("SPK_FATIH", "D43O_F_FWD_B")
			await hud.say("SPK_TOLGA", "D43O_T_FIX")
			await drone.fly_to(mid, 14.0, WALLS_AT)
		_:
			await get_tree().create_timer(0.8).timeout
			await hud.say("SPK_FATIH", "D43O_F_FWD_C")
			await hud.say("SPK_TOLGA", "D43O_T_FIX")
			await drone.fly_to(mid, 14.0, WALLS_AT)
	if lessons >= 2:
		await hud.say("SPK_TOLGA", "D43O_T_PRO")


## Sultan şehri görür: surların önüne, Büro kilidine kadar; Nihat pili gevşetir (görüntü karlanır).
func _sultan_sees() -> void:
	phase = "see"
	var front := _gy(Vector3(2.0, 0, 352.0)) + Vector3(0, 50.0, 0)
	await drone.fly_to(front, 14.0, WALLS_AT)
	await hud.say("SPK_FATIH", "D43O_F_VIEW1")
	await hud.say("SPK_ZAGANOS", "D43O_Z_VIEW1")
	drone.fly_to(_gy(Vector3(24.0, 0, 356.0)) + Vector3(0, 44.0, 0), 4.0, WALLS_AT + Vector3(4.0, -6.0, 0))
	await hud.say("SPK_FATIH", "D43O_F_VIEW2")
	# Sultan surun üstüne geçmek ister: Büro kilidi
	drone.auto_target = Vector3.INF
	await drone.fly_to(drone.global_position + Vector3(0, 6.0, 40.0), 6.0, WALLS_AT + Vector3(0, -8.0, 60.0))
	drone.fenced = true
	await hud.say("SPK_FATIH", "D43O_F_FENCE")
	await hud.say("SPK_TOLGA", "D43O_T_FENCE")
	await hud.say("SPK_FATIH", "D43O_F_FENCE2")
	drone.pitch = deg_to_rad(-30.0)
	await hud.say("SPK_FATIH", "D43O_F_VIEW3")
	# Nihat pili gevşetir
	_ghost_at(fatih.global_position + Vector3(1.2, 0, 1.6))
	drone.set_static(0.65)
	Audio.sfx("radio_static", -10.0)
	await hud.say("SPK_FATIH", "D43O_F_STATIC")
	var pick := await hud.choose(["UI_C43O_ST_A", "UI_C43O_ST_B", "UI_C43O_ST_C"], 0.0, 1 if GameState.autotest_variant == "bad" else 0)
	match pick:
		0:
			await hud.say("SPK_FATIH", "D43O_F_ST_A")
		1:
			bad += 1
			await hud.say("SPK_FATIH", "D43O_F_ST_B")
		_:
			bad += 1
			await hud.say("SPK_ZAGANOS", "D43O_Z_ST_C")
	await hud.say("SPK_NIHAT", "D43O_N_STATIC")
	# Sultan kuşu otağın önüne geri yollar: kuş yolda, görüntü kumandadan çekilir (tespit karesi bu arada çekilir)
	drone.set_static(0.15)
	_view_drone(false)
	drone.fly_to(_gy(STAGE) + Vector3(0.0, 6.0, 4.0), 22.0)


func _photo_phase() -> void:
	phase = "photo"
	player.face(fatih.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_NIHAT", "D43O_N_PHOTO")
	_hold_remote(true)
	player.frozen = false
	_capture_mouse()
	hud.set_objective(tr("UI_OBJ43O_PHOTO"), fatih.global_position)
	cam = TespitCam.new(player, hud, fatih, "siege43o")
	add_child(cam)
	cam.max_dist = 14.0
	cam.cone_deg = 22.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	hud.set_objective("")
	player.frozen = true


## Sultan Urban'a "yüz tane yap" der; Tolga son bir uçuş ister ve kuşu Kadri'nin kazanının üstüne getirir.
func _last_flight() -> void:
	phase = "last"
	_hold_remote(false)
	while drone.auto_target != Vector3.INF:
		await get_tree().physics_frame
	await hud.say("SPK_FATIH", "D43O_F_URBAN")
	urban.talking = true
	await hud.say("SPK_URBAN", "D43O_U_URBAN")
	urban.talking = false
	await hud.say("SPK_NIHAT", "D43O_N_06")
	player.face(fatih.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_TOLGA", "D43O_T_LAST")
	await hud.say("SPK_FATIH", "D43O_F_LAST")
	drone.set_static(0.0)
	drone.battery = minf(drone.battery, 24.0)
	drone.drain = 0.45
	drone.pilot(true)
	_view_drone(true)
	_capture_mouse()
	hud.set_prompt(tr("UI_DRONE_HELP"))
	var over := _gy(CAULDRON) + Vector3(0, 3.2, 0)
	hud.set_objective(tr("UI_OBJ43O_CAULDRON"), _gy(CAULDRON) + Vector3(0, 1.2, 0), 0.0)
	var miss := GameState.autotest_variant == "miss"
	var t := 0.0
	var reached := false
	while true:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if GameState.autotest and drone.auto_target == Vector3.INF and t > 0.3:
			drone.fly_to(over if not miss else _gy(Vector3(24.0, 0, -30.0)) + Vector3(0, 8.0, 0), 10.0)
		if _hdist(drone.global_position, CAULDRON) < 1.4 and drone.altitude() < 8.0:
			reached = true
			break
		if drone.battery <= 0.0 or t > (14.0 if GameState.autotest else 70.0):
			break
	hud.set_objective("")
	hud.set_prompt("")
	if reached:
		# Nihat pili çeker; kuş kazana düşer
		drone.auto_target = Vector3.INF
		drone.global_position = Vector3(CAULDRON.x - 0.3, drone.global_position.y, CAULDRON.z)   # mutfak saçağının kenarından uzak
		drone.vel = Vector3.ZERO
		drone.kill()
		await get_tree().create_timer(0.4).timeout
		drone.pilot(false)
		_view_drone(false)
		_cut_to_kitchen()
		await _drone_landed(3.0)
		soup = true
		_soup_fx()
		await get_tree().create_timer(0.6).timeout
		kadri.face_toward(_gy(CAULDRON))
		kadri.emote("surprise")
		await hud.say("SPK_KADRI", "D43O_K_SOUP")
		_view_drone(false)
		fatih.emote("laugh")
		await hud.say("SPK_FATIH", "D43O_F_SOUP")
		await hud.say("SPK_URBAN", "D43O_U_SOUP")
	else:
		# Yetişemedi: Nihat kuşu havada görünmez taşır; ordugâh cin sanar
		bad += 1
		drone.kill()
		drone.pilot(false)
		_view_drone(false)
		await get_tree().create_timer(0.3).timeout
		drone.set_physics_process(false)
		var to := _gy(OTAG + Vector3(-18.0, 0, 6.0)) + Vector3(0, 3.0, 0)
		drone.global_position = _gy(STAGE) + Vector3(-4.0, 2.2, 2.0)
		_ghost_at(drone.global_position - Vector3(0, 1.8, 0))
		player.face(drone.global_position)
		var tw := create_tween()
		tw.tween_property(drone, "global_position", to, 4.0)
		tw.parallel().tween_property(nihat, "global_position", to - Vector3(0, 1.8, 0), 4.0)
		await hud.say("SPK_ZAGANOS", "D43O_Z_FLOAT")
		await hud.say("SPK_NIHAT", "D43O_N_FLOAT")
		if tw.is_running():
			await tw.finished
		drone.visible = false
		nihat.visible = false


func _end_talk() -> void:
	phase = "end"
	_outcome = "43O.2" if bad >= BAD_LIMIT else "43O.1"
	player.face(fatih.global_position + Vector3(0, 1.5, 0))
	if _outcome == "43O.1":
		await hud.say("SPK_FATIH", "D43O_F_END_OK")
		await hud.say("SPK_FATIH", "D43O_F_END_OK2")
	else:
		await hud.say("SPK_ZAGANOS", "D43O_Z_END_BAD")
		await hud.say("SPK_FATIH", "D43O_F_END_BAD")
		await hud.fade_to(1.0, 1.0)
		await get_tree().create_timer(0.6).timeout
		await hud.say("SPK_NIHAT", "D43O_N_END_BAD")
		await hud.fade_to(0.0, 0.8)
	Audio.sfx("radio_static", -14.0)
	await hud.say("SPK_NIHAT", "D43O_N_END")
	await hud.say("SPK_TOLGA", "D43O_T_END")
	await hud.say("SPK_NIHAT", "D43O_N_END2")


func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(43, _outcome)
	Siege.record(43, _photo, "SIEGE_NOTE_43O_%s" % _outcome.split(".")[1])
	await Siege.show_page(hud, 43)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(43)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			GameState.replay_scene()
		_:
			get_tree().quit()


# ================================================================ yardımcılar

func _on_focus(id: String) -> void:
	hud.set_prompt(tr("UI_PROMPT43O_POWER") if phase == "power" and id == "drone" else "")


func _on_interact(id: String) -> void:
	if phase == "power" and id == "drone":
		_power_on()


func _power_on() -> void:
	if phase != "power":
		return
	phase = "fly"
	hud.set_prompt("")
	drone.power(true)
	_hold_remote(true)
	Audio.sfx("radio_beep", -8.0)


## Tolga'nın elinde kumanda (Büro grisi, iki çubuk, ekranlı): birinci şahıs kameranın sağ altında.
func _hold_remote(on: bool) -> void:
	if on and _remote == null:
		_remote = Node3D.new()
		player.camera.add_child(_remote)
		_remote.position = Vector3(0.2, -0.25, -0.5)
		_remote.rotation_degrees = Vector3(32, -10, 0)
		_remote.scale = Vector3.ONE * 0.75
		Props.box(_remote, Vector3(0.2, 0.025, 0.1), Vector3.ZERO, Color("3a3c42"))
		Props.box(_remote, Vector3(0.12, 0.004, 0.07), Vector3(0, 0.014, -0.005), Color("1a2a3a"), Vector3.ZERO, 0.6)
		for sx in [-0.075, 0.075]:
			Props.cyl(_remote, 0.007, 0.03, Vector3(sx, 0.025, 0.02), Color("1e1e22"), Vector3.ZERO, 6)
		Props.cyl(_remote, 0.003, 0.12, Vector3(-0.08, 0.06, -0.04), Color("6a6e74"), Vector3(20, 0, 0), 4)
	if _remote:
		_remote.visible = on


## Oyuncu uçarken koşul sağlanana dek bekler; otomatik testte dronu hedefe kendisi götürür.
func _until(cond: Callable, auto_to: Vector3, auto_face := Vector3.INF) -> void:
	var t := 0.0
	while not cond.call():
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if GameState.autotest and drone.auto_target == Vector3.INF:
			drone.fly_to(auto_to, 10.0, auto_face)
		if t > 240.0:
			break
	drone.auto_target = Vector3.INF


func _facing_walls() -> bool:
	var fwd := -drone.cam.global_transform.basis.z
	var to := (WALLS_AT - drone.global_position)
	return absf(Vector2(fwd.x, fwd.z).angle_to(Vector2(to.x, to.z))) < deg_to_rad(35.0)


## Kumandanın ekranı (kuşun gözü) açılır ya da oyuncunun gözüne dönülür; ekrandayken Tolga'nın fesinin kenarı gizlenir.
func _view_drone(on: bool) -> void:
	drone.feed(on)
	hud.fez.visible = not on and bool(GameState.flags.get("fez", true))
	if not on:
		player.camera.make_current()


func _hdist(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _spin(angle: float, secs: float) -> void:
	var y0 := drone.yaw
	var tw := create_tween()
	tw.tween_method(func(v: float): drone.yaw = y0 + v, 0.0, angle, secs)
	await tw.finished


func _ghost_at(p: Vector3) -> void:
	nihat.global_position = Vector3(p.x, CampDay.height(p.x, p.z), p.z)
	nihat.look_at(Vector3(player.global_position.x, nihat.global_position.y, player.global_position.z) + Vector3(0.001, 0, 0), Vector3.UP)
	nihat.visible = true
	var tw := create_tween()
	tw.tween_interval(3.5)
	tw.tween_callback(func(): nihat.visible = false)


func _drone_landed(max_t: float) -> void:
	var t := 0.0
	var done := [false]
	var cb := func(_at: Vector3): done[0] = true
	drone.crashed.connect(cb)
	while not done[0] and t < max_t:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	drone.crashed.disconnect(cb)


## Kesme kamera: kazan, Kadri ve düşen kuş birlikte görünsün.
func _cut_to_kitchen() -> void:
	var c := _gy(CAULDRON)
	cut.global_position = c + Vector3(-4.6, 2.1, 1.8)
	cut.look_at(c + Vector3(0.6, 1.1, 0.2), Vector3.UP)
	cut.make_current()
	hud.fez.visible = false


func _soup_fx() -> void:
	var c := _gy(CAULDRON) + Vector3(0, 1.1, 0)
	Vfx.splash(self, c, 0.6)
	Audio.sfx("splash", -4.0)
	var tw := create_tween()
	tw.tween_property(drone, "global_position:y", drone.global_position.y - 0.45, 1.2)
	tw.tween_callback(func(): drone.visible = false)


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW43O_TITLE")
	c.nodes = [
		{"id": "box", "key": "FLOW43O_BOX", "pos": Vector2(0.5, 0.1)},
		{"id": "lesson", "key": "FLOW43O_LESSON", "pos": Vector2(0.5, 0.26)},
		{"id": "view", "key": "FLOW43O_VIEW", "pos": Vector2(0.5, 0.42)},
		{"id": "43O.1", "key": "FLOW_43O_1", "pos": Vector2(0.3, 0.62), "outcome": true},
		{"id": "43O.2", "key": "FLOW_43O_2", "pos": Vector2(0.7, 0.62), "outcome": true},
	]
	c.edges = [["box", "lesson"], ["lesson", "view"], ["view", "43O.1"], ["view", "43O.2"]]
	for k in ["box", "lesson", "view"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH43O_STATS") % [bad, lessons, int(drone.traveled), Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "43O.1", "bad": "43O.2", "miss": "43O.1"}.get(v, "43O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("43", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	ok = ok and drone.traveled > 80.0 and (soup if v == "" else true) and (not soup if v == "miss" else true)
	ok = ok and (lessons == 3 if v == "" else true)
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s çorba=%s ders=%d uçuş=%.0f)" % [expected, _outcome,
			not page.is_empty(), cam != null and cam.done, soup, lessons, drone.traveled])
	print("AUTOTEST %s chapter=43 variant=%s outcome=%s bad=%d lessons=%d soup=%s flown=%.0f battery=%.0f" % [
		"PASS" if ok else "FAIL", v, _outcome, bad, lessons, soup, drone.traveled, drone.battery])
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
	await get_tree().create_timer(2.5).timeout
	player.global_position = _gy(PLAYER_AT) + Vector3(0, 0.05, 0)
	player.face(_gy(STAGE) + Vector3(-0.8, 0.9, -1.6))
	await _shot("c43o_01_tent.png")
	drone.power(true)
	_hold_remote(true)
	drone.global_position = _gy(STAGE) + Vector3(0, 2.2, 1.2)
	player.face(drone.global_position)
	await get_tree().create_timer(0.5).timeout
	await _shot("c43o_02_hover.png")
	drone.global_position = _gy(Vector3(-4.0, 0, -20.0)) + Vector3(0, 9.0, 0)
	drone.yaw = PI
	drone.pitch = deg_to_rad(-40.0)
	drone.pilot(true)
	_view_drone(true)
	await get_tree().create_timer(0.5).timeout
	await _shot("c43o_03_feed_camp.png")
	drone.cover_lens(true)
	await _shot("c43o_04_hand.png")
	drone.cover_lens(false)
	drone.global_position = _gy(Vector3(2.0, 0, 352.0)) + Vector3(0, 50.0, 0)
	drone.yaw = PI
	drone.pitch = deg_to_rad(-24.0)
	await get_tree().create_timer(0.8).timeout
	await _shot("c43o_05_feed_walls.png")
	drone.set_static(0.6)
	await _shot("c43o_06_static.png")
	drone.set_static(0.0)
	drone.pilot(false)
	_view_drone(false)
	_ghost_at(player.global_position + Vector3(-1.2, 0, -1.6))
	player.face(nihat.global_position + Vector3(0, 1.2, 0))
	await _shot("c43o_07_ghost.png")
	drone.global_position = _gy(CAULDRON) + Vector3(0, 2.0, 0)
	_cut_to_kitchen()
	await _shot("c43o_08_cauldron.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = _gy(STAGE) + Vector3(-3.8, 1.9, 5.2)
	cv.look_at(_gy(STAGE) + Vector3(0.6, 1.5, -3.0), Vector3.UP)
	cv.fov = 60.0
	drone.global_position = _gy(STAGE) + Vector3(0.4, 2.6, 0.8)
	cv.make_current()
	await _shot("c43o_cover.png")
	get_tree().quit()
