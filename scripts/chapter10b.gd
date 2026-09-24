extends Node3D
## Bölüm 10B — Büyük Atış (Tolga · 25 Nisan 1453). CHAPTERS Bölüm 10, STORY_BRANCHES Son 6, EXPANSION §3.
##
## 9.2'de Urban'ın teklifi kabul edildi. Topçu sahasında bir gün:
##   1. Döküm: bronzu üç kalıba dök (güç çubuğu; yeşilde dur). Döküm kalitesi 0–3.
##   2. Topa ad koy (Pazartesi / Koli / Sigorta / Küp).
##   3. Fatih sahaya gelir. Çatlak bantlı değilse ve 📦 çantadaysa şimdi bantlanabilir.
##   4. Barut: normal / iki katı / iki katı + 🔋 powerbank.
##   5. ⏱ Açı: 📱 hesap makinesi (%1) · 👁 göz kararı · 🧊 Rubik küpü.
##   6. ⏱ Fitil: 🔥 çakmak / meşale / Urban yaksın.
## Risk = bantsız çatlak + zayıf döküm (<2) + iki katı barut (powerbank: +2). Risk ≥ 2 → Büyük Patlama.
##   10B.1 Gülle Galata'daki şarap fıçısına (W5) · 10B.2 Yirmi metre öteye (W5)
##   10B.3 Büyük Patlama: ağır çekimde herkes uçar, Tolga Fatih'in önüne düşer (W5B, Paradoks +40)
##   --autotest[=eye|boom|untaped|tape|next]   (varsayılan: 10B.1)

const CANNON := Vector3(3.0, 0.0, -21.0)
const URBAN_AT := Vector3(5.8, 0.0, -23.6)
const TOLGA_AT := Vector3(5.4, 0.0, -16.0)
const FATIH_AT := Vector3(11.0, 0.0, -16.2)
const FOUNDRY := Vector3(13.0, 0.0, -26.5)
const GOAT_TENT := Vector3(19.0, 0.0, -12.0)
const POUR_SPEED := 0.55
const SPEAKERS := {"urban": "SPK_URBAN", "fatih": "SPK_FATIH", "kadri": "SPK_KADRI", "rider": "SPK_RIDER",
	"hasan": "SPK_HASAN", "huseyin": "SPK_HUSEYIN"}

var day: CampDay
var player: Player
var hud: Hud
var phase := "intro"
var _outcome := ""
var _quality := 0              # döküm: yeşilde durdurulan kalıp sayısı
var _risk := 0
var _taped := false
var _powder := 0               # 0 normal · 1 iki katı · 2 powerbank
var _calc := "eye"             # phone / eye / cube
var _name := 0
var fatih: Person
var urban: Person
var hasan: Soldier
var huseyin: Soldier
var gunners: Array[Soldier] = []
var chicken: Chicken
var tolga_double: Person
var _crucible: Node3D
var _stream: MeshInstance3D
var _molds: Array[MeshInstance3D] = []
var _ball: MeshInstance3D
var _cine: Camera3D


func _ready() -> void:
	GameState.snapshot(10)
	_apply_autotest_setup()
	_taped = GameState.flags.get("cannon_taped", false)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.interacted.connect(_on_interact)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	day = CampDay.new()
	add_child(day)
	if day.ring_node:
		day.ring_node.queue_free()
	# Sahadaki Urban sahnenin Urban'ı olur
	urban = day.urban
	urban.position = URBAN_AT
	urban.look_target = player
	day.goat.chase = null
	day.goat.caught = true
	day.goat.position = CANNON + Vector3(-2.5, 0, -3.5)
	_build_field()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	GameState.chapter_outcomes[9] = "9.2"
	GameState.chapter_outcomes[6] = "6a.3"
	GameState.flags["cannon_taped"] = true
	for id in ["phone", "tape", "powerbank", "lighter"]:
		if not id in GameState.bag:
			GameState.bag.append(id)
	match GameState.autotest_variant:
		"untaped", "tape":
			GameState.flags["cannon_taped"] = false


func _d(sec: float) -> float:
	return 0.05 if GameState.autotest else sec


func _wait(sec: float) -> void:
	await get_tree().create_timer(_d(sec)).timeout


# ================================================================ sahne

func _cannon_dir() -> Vector3:
	return (day.cannon.global_transform.basis * Vector3(0, 0, 1)).normalized()


func _build_field() -> void:
	# Dökümhane: ocak, pota, üç toprak kalıp
	var f := FOUNDRY
	Props.box(self, Vector3(2.4, 0.9, 1.6), f + Vector3(0, 0.45, -1.2), Color("6a5040"))
	var glow := Props.box(self, Vector3(1.4, 0.2, 0.9), f + Vector3(0, 0.95, -1.2), Color("ff7a2a"), Vector3.ZERO, 2.0)
	glow.material_override = Props.mat(Color("ff7a2a"), 2.5, false, "", false)
	var fl := OmniLight3D.new()
	fl.position = f + Vector3(0, 1.6, -1.2)
	fl.light_color = Color("ff9a4a")
	fl.light_energy = 1.6
	fl.omni_range = 6.0
	add_child(fl)
	day.lights.append(fl)
	_crucible = Node3D.new()
	_crucible.position = f + Vector3(0, 1.5, -0.4)
	add_child(_crucible)
	Props.cyl(_crucible, 0.35, 0.6, Vector3(0, 0, 0), Color("4a4a50"), Vector3.ZERO, 10, 0.28)
	var melt := Props.cyl(_crucible, 0.3, 0.02, Vector3(0, 0.29, 0), Color("ffb040"), Vector3.ZERO, 10)
	melt.material_override = Props.mat(Color("ffb040"), 3.0, false, "", false)
	for sx in [-0.8, 0.8]:
		Props.cyl(self, 0.05, 1.6, f + Vector3(sx, 0.8, -0.4), Color("3a3a3e"), Vector3.ZERO, 5)
	Props.cyl(self, 0.03, 1.7, f + Vector3(0, 1.55, -0.4), Color("3a3a3e"), Vector3(0, 0, 90), 4)
	_stream = Props.cyl(self, 0.05, 1.0, Vector3.ZERO, Color("ffb040"), Vector3.ZERO, 6)
	_stream.material_override = Props.mat(Color("ffb040"), 3.0, false, "", false)
	_stream.visible = false
	for i in 3:
		var mp := f + Vector3(-1.4 + i * 1.4, 0, 1.4)
		Props.cyl(self, 0.45, 0.9, mp + Vector3(0, 0.45, 0), Color("8a6a4a"), Vector3.ZERO, 10)
		var fill := Props.cyl(self, 0.32, 0.02, mp + Vector3(0, 0.1, 0), Color("ffb040"), Vector3.ZERO, 10)
		fill.material_override = Props.mat(Color("ffb040"), 2.0, false, "", false)
		fill.visible = false
		_molds.append(fill)
	Props.label(self, "DÖKÜMHANE", f + Vector3(0, 2.6, -2.05), 30, Color("f2e6c9"), Vector3.ZERO, 2.4)
	# Topçular
	for i in 3:
		var g := Soldier.new(Color("7a5a2a"), "stand", "turban")
		g.position = CANNON + Vector3(-3.0 + i * 1.3, 0, -3.0 - (i % 2) * 0.8)
		g.rotation.y = PI * 0.2
		add_child(g)
		gunners.append(g)
	# Keçinin konacağı çadır
	Night.tent(self, GOAT_TENT, 2.0, Color("d8cbb0"), Color("3a6b3a"))
	# Sinerji: sahanın kenarında dolaşır
	chicken = Chicken.new()
	chicken.position = CANNON + Vector3(4.0, 0, 3.0)
	add_child(chicken)
	# Fatih ve muhafızları (sonradan gelir)
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "turban", "mustache": true, "robe": Color("c8323a"),
		"hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.scale = Vector3(1.06, 1.06, 1.06)
	fatih.visible = false
	add_child(fatih)
	Props.box(fatih, Vector3(0.06, 1.1, 0.02), Vector3(0, 0.95, 0.25), Color("d8b040"))
	hasan = Soldier.new(Color("b3262d"), "stand", "bork")
	huseyin = Soldier.new(Color("2f5fa8"), "stand", "bork")
	for g in [hasan, huseyin]:
		g.visible = false
		add_child(g)
	# Tolga'nın ikizi: geniş planda uçan Tolga (birinci şahıs kameranın dışından görünür)
	tolga_double = Person.new({"coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")})
	tolga_double.visible = false
	add_child(tolga_double)
	# Gülle
	_ball = Props.ball(self, 0.45, Vector3.ZERO, Color("4a4a50"), Vector3.ONE, 10)
	_ball.visible = false
	Props.interactable(self, "urban", Vector3(1.3, 2.2, 1.3), URBAN_AT + Vector3(0, 1.1, 0))


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH10B_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH10B_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = FOUNDRY + Vector3(-3.2, 0.1, 3.8)
	player.face(FOUNDRY + Vector3(0, 1.2, 0))
	urban.position = FOUNDRY + Vector3(-1.8, 0, -0.2)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await _say("SPK_URBAN", "D10B_U_01")
	await _t("D10B_T_02")
	await _say("SPK_URBAN", "D10B_U_03")
	await _cast()
	await _naming()
	await _fatih_arrives()
	await _prepare()
	await _fire()
	await _radio()
	await _end_chapter()


# ---------------------------------------------------------------- döküm

func _cast() -> void:
	phase = "cast"
	hud.set_objective(tr("UI_OBJ10B_CAST"))
	await _say("SPK_URBAN", "D10B_U_CAST_INTRO")
	var meter := KickMeter.new()
	hud.add_child(meter)
	var vp := get_viewport().get_visible_rect().size
	meter.position = Vector2((vp.x - meter.size.x) / 2.0, vp.y * 0.12)
	var auto_bad := GameState.autotest_variant == "untaped"
	for i in 3:
		meter.label_text = tr("UI_CH10B_POUR") % (i + 1)
		meter.visible = true
		var mold := _molds[i]
		player.face(mold.global_position + Vector3(0, 0.5, 0))
		_crucible.position.x = mold.global_position.x
		mold.visible = true
		var tilt := create_tween()
		tilt.tween_property(_crucible, "rotation:z", -0.9, _d(0.4))
		await tilt.finished
		_stream.visible = true
		var top := _crucible.global_position + Vector3(0, 0.1, 0)
		var bottom := mold.global_position
		_stream.global_position = (top + bottom) * 0.5
		_stream.scale = Vector3(1, top.y - bottom.y, 1)
		Audio.sfx("bronze_pour", -8.0)
		var t := 0.0
		var v := 0.0
		var auto_at := 0.3 if auto_bad else 0.7
		while true:
			t += get_process_delta_time()
			v = pingpong(t * POUR_SPEED * (1.0 + i * 0.25), 1.0)
			meter.value = v
			mold.position.y = FOUNDRY.y + 0.1 + v * 0.75
			if GameState.autotest and absf(v - auto_at) < 0.05:
				break
			if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("kick"):
				break
			await get_tree().process_frame
		meter.flash = 1.0
		_stream.visible = false
		var back := create_tween()
		back.tween_property(_crucible, "rotation:z", 0.0, _d(0.3))
		var z := KickMeter.zone(v)
		await _wait(0.2)
		meter.visible = false
		match z:
			"sweet":
				_quality += 1
				await _say("SPK_URBAN", "D10B_U_CAST_OK" if _quality == 1 else "D10B_U_CAST_OK2")
			"weak":
				await _say("SPK_URBAN", "D10B_U_CAST_COLD")
			_:
				Vfx.dust(self, mold.global_position + Vector3(0, 0.9, 0), 0.4)
				await _say("SPK_URBAN", "D10B_U_CAST_SPILL")
				await _t("D10B_T_CAST_SPILL")
	meter.queue_free()
	hud.set_objective("")
	GameState.flags["ch10b_quality"] = _quality
	await _say("SPK_URBAN", "D10B_U_CAST_GOOD" if _quality >= 2 else "D10B_U_CAST_BAD")


func _naming() -> void:
	await _say("SPK_URBAN", "D10B_U_NAME")
	var pick := 1
	_name = clampi(await hud.choose(["UI_CH10B_NAME_1", "UI_CH10B_NAME_2", "UI_CH10B_NAME_3", "UI_CH10B_NAME_4"], 0.0, pick), 0, 3)
	GameState.flags["cannon_name"] = _name
	await _say("SPK_URBAN", "D10B_U_NAME_%d" % (_name + 1))


# ---------------------------------------------------------------- Sultan sahada

func _fatih_arrives() -> void:
	await hud.fade_to(1.0, 0.6)
	urban.position = URBAN_AT
	player.global_position = TOLGA_AT + Vector3(0, 0.1, 0)
	player.face(CANNON + Vector3(0, 1.3, 0))
	await hud.fade_to(0.0, 0.8)
	await _t("D10B_T_ARRIVE")
	fatih.visible = true
	fatih.position = FATIH_AT + Vector3(6.0, 0, 4.0)
	fatih.look_at_from_position(fatih.position, CANNON, Vector3.UP)
	fatih.rotate_y(PI)
	hasan.visible = true
	huseyin.visible = true
	var tw := create_tween().set_parallel(true)
	tw.tween_property(fatih, "position", FATIH_AT, _d(2.2))
	hasan.position = FATIH_AT + Vector3(7.0, 0, 5.0)
	huseyin.position = FATIH_AT + Vector3(5.2, 0, 5.4)
	tw.tween_property(hasan, "position", FATIH_AT + Vector3(1.2, 0, 1.4), _d(2.2))
	tw.tween_property(huseyin, "position", FATIH_AT + Vector3(-0.6, 0, 1.8), _d(2.2))
	player.face(FATIH_AT + Vector3(3.0, 1.5, 2.0))
	await tw.finished
	for g in [hasan, huseyin]:
		g.look_at(CANNON, Vector3.UP)
		g.rotate_y(PI)
	fatih.look_target = player
	player.face(fatih.global_position + Vector3(0, 1.6, 0))
	await _say("SPK_URBAN", "D10B_U_BOW")
	await _say("SPK_FATIH", "D10B_F_01")
	await _say("SPK_URBAN", "D10B_U_TAPED" if _taped else "D10B_U_UNTAPED")
	await _say("SPK_FATIH", "D10B_F_02")


## Bant, barut, açı: riski belirleyen üç karar.
func _prepare() -> void:
	player.face(CANNON + Vector3(0, 1.4, 0))
	var v := GameState.autotest_variant
	# Çatlak
	if not _taped and "tape" in GameState.bag:
		await _t("D10B_T_TAPE_Q")
		var c := await hud.choose(["UI_CH10B_TAPE_YES", "UI_CH10B_TAPE_NO"], 0.0, 0 if v == "tape" else 1)
		if c == 0:
			_taped = true
			GameState.flags["cannon_taped"] = true
			var crack := day.cannon.get_node_or_null("Crack")
			if crack:
				Props.box(day.cannon, Vector3(0.1, 0.62, 1.0), (crack as Node3D).position + Vector3(0.02, 0, 0), Color("c8a468"), Vector3(0, 0, 25))
			await _say("SPK_FATIH", "D10B_F_TAPE")
	# Barut
	await _say("SPK_URBAN", "D10B_U_POWDER")
	var keys := ["UI_CH10B_POWDER_1", "UI_CH10B_POWDER_2"]
	if "powerbank" in GameState.bag:
		keys.append("UI_CH10B_POWDER_3")
	var pp := 0
	if v == "boom":
		pp = 2
	elif v == "untaped":
		pp = 1
	_powder = clampi(await hud.choose(keys, 0.0, pp), 0, keys.size() - 1)
	await _say("SPK_URBAN", "D10B_U_POWDER_%d" % (_powder + 1))
	if _powder == 2:
		await _t("D10B_T_POWDER_3")
	# Açı
	await _say("SPK_URBAN", "D10B_U_CALC")
	var ckeys: Array = []
	var cids: Array = []
	if "phone" in GameState.bag and int(GameState.flags.get("ch9_trial_urban", 0)) != 2:
		ckeys.append("UI_CH10B_CALC_PHONE")
		cids.append("phone")
	ckeys.append("UI_CH10B_CALC_EYE")
	cids.append("eye")
	if "cube" in GameState.bag:
		ckeys.append("UI_CH10B_CALC_CUBE")
		cids.append("cube")
	var cp := cids.find("eye") if v == "eye" else 0
	var cc := await hud.choose(ckeys, 10.0, cp)
	_calc = "eye" if cc < 0 else String(cids[cc])
	await _t("D10B_T_CALC_" + _calc.to_upper())
	await _say("SPK_URBAN", "D10B_U_CALC_EYE" if _calc == "eye" else "D10B_U_CALC_OK")
	_risk = (0 if _taped else 1) + (1 if _quality < 2 else 0) + [0, 1, 2][_powder]
	GameState.flags["ch10b_risk"] = _risk


func _fire() -> void:
	await _say("SPK_URBAN", "D10B_U_FUSE")
	var keys: Array = []
	var ids: Array = []
	if "lighter" in GameState.bag:
		keys.append("UI_CH10B_FUSE_LIGHTER")
		ids.append("lighter")
	keys.append("UI_CH10B_FUSE_TORCH")
	ids.append("torch")
	keys.append("UI_CH10B_FUSE_URBAN")
	ids.append("urban")
	var c := await hud.choose(keys, 6.0, 0)
	var how: String = "urban" if c < 0 else String(ids[c])
	if how == "lighter":
		await _say("SPK_URBAN", "D10B_U_FUSE_LIGHTER")
	elif how == "urban":
		await _say("SPK_URBAN", "D10B_U_FUSE_URBAN")
	Audio.sfx("fuse_burn", -8.0)
	await _say("SPK_URBAN", "D10B_U_EARS")
	await _wait(1.0)
	if _risk >= 2:
		await _explosion()
	elif _calc == "eye":
		await _near_shot()
	else:
		await _galata_shot()


# ---------------------------------------------------------------- atış sonuçları

func _muzzle() -> Vector3:
	return CANNON + Vector3(0, 1.3, 0) + _cannon_dir() * 3.3


func _shot_fx() -> void:
	Audio.sfx("cannon", 0.0)
	player.shake(0.6)
	Vfx.explosion(self, _muzzle(), 0.45)
	var recoil := create_tween()
	var home := day.cannon.position
	recoil.tween_property(day.cannon, "position", home - _cannon_dir() * 0.8, _d(0.08))
	recoil.tween_property(day.cannon, "position", home, _d(0.9))


func _fly_ball(to: Vector3, peak: float, dur: float) -> void:
	var from := _muzzle()
	_ball.visible = true
	var tw := create_tween()
	tw.tween_method(func(k: float):
		var p := from.lerp(to, k)
		p.y += sin(k * PI) * peak
		_ball.global_position = p, 0.0, 1.0, _d(dur))
	await tw.finished


## 10B.1: hesap "tuttu": gülle surları aşar ve tarafsız Galata'ya, bir şarap fıçısına düşer.
func _galata_shot() -> void:
	_shot_fx()
	player.face(_muzzle() + _cannon_dir() * 30.0 + Vector3(0, 18, 0))
	await _fly_ball(_muzzle() + _cannon_dir() * 260.0 + Vector3(90, -10, 0), 70.0, 3.0)
	_ball.visible = false
	await _t("D10B_T_B1_1")
	player.face(urban.global_position + Vector3(0, 1.6, 0))
	await _say("SPK_URBAN", "D10B_U_B1_2")
	await _t("D10B_T_B1_3")
	await _wait(0.8)
	var rider := Person.new({"coat": Color("3a5a8a"), "pants": Color("2a2a30"), "hat": "turban", "mustache": true, "skin": Color("d9a07a")})
	rider.position = FATIH_AT + Vector3(8.0, 0, 6.0)
	add_child(rider)
	var tw := create_tween()
	tw.tween_property(rider, "position", FATIH_AT + Vector3(1.6, 0, 1.0), _d(1.2))
	await tw.finished
	player.face(rider.global_position + Vector3(0, 1.5, 0))
	rider.talking = true
	await hud.say("SPK_RIDER", "D10B_RIDER")
	rider.talking = false
	player.face(fatih.global_position + Vector3(0, 1.6, 0))
	await _say("SPK_FATIH", "D10B_F_B1_1")
	await _t("D10B_T_B1_4")
	await _say("SPK_FATIH", "D10B_F_B1_2")
	await _t("D10B_T_B1_5")
	await _say("SPK_FATIH", "D10B_F_B1_3")
	GameState.flags["merak"] = int(GameState.flags.get("merak", 0)) + 1
	GameState.paradox += 15
	GameState.flags["world10"] = "W5"
	_outcome = "10B.1"


## 10B.2: göz kararı: gülle yirmi metre öteye düşer.
func _near_shot() -> void:
	_shot_fx()
	var land := CANNON + _cannon_dir() * 22.0
	land.y = 0.3
	player.face(land + Vector3(0, 2.0, 0))
	await _fly_ball(land, 4.0, 1.0)
	Vfx.dust(self, land, 1.4)
	Audio.sfx("goat", -6.0)
	await _t("D10B_T_B2_1")
	player.face(urban.global_position + Vector3(0, 1.6, 0))
	await _say("SPK_URBAN", "D10B_U_B2_2")
	player.face(fatih.global_position + Vector3(0, 1.6, 0))
	await _say("SPK_FATIH", "D10B_F_B2_1")
	await _say("SPK_URBAN", "D10B_U_B2_3")
	await _say("SPK_FATIH", "D10B_F_B2_2")
	GameState.paradox += 5
	GameState.flags["world10"] = "W5"
	_outcome = "10B.2"


## 10B.3: Büyük Patlama. Ağır çekim, herkes uçar, kimse yaralanmaz (çizgi film kuralı).
func _explosion() -> void:
	await _say("SPK_URBAN", "D10B_U_B3_1")
	await _t("D10B_T_B3_2")
	var slow := not GameState.autotest
	# Geniş plan: sinematik kamera (fragman karesi)
	_cine = Camera3D.new()
	add_child(_cine)
	_cine.global_position = CANNON + Vector3(-11.0, 3.4, 4.0)
	_cine.look_at(CANNON + Vector3(2.0, 3.6, -0.5), Vector3.UP)
	_cine.fov = 64.0
	_cine.make_current()
	tolga_double.visible = true
	tolga_double.global_position = TOLGA_AT
	tolga_double.look_at_from_position(TOLGA_AT, CANNON, Vector3.UP)
	tolga_double.rotate_y(PI)
	hud.set_cinematic(true)
	var center := CANNON + Vector3(0, 1.3, 0)
	_boom_sfx()
	hud.set_fade(0.95, Color.WHITE)
	hud.fade_to(0.0, 0.5, Color.WHITE)
	Vfx.explosion(self, center, 1.3)
	day.cannon.visible = false
	if slow:
		Engine.time_scale = 0.2
		Audio.music("explosion_slowmo", 0.1)
	_ear_ring(true)
	# Herkes uçar: nereden, nereye, ne kadar yükseğe, ne kadar döner
	var kitchen := Vector3(-13.0, 0, -8.8)
	var flights: Array = [
		[tolga_double, FATIH_AT + Vector3(-1.4, 0, -0.8), 9.0, 2.0],
		[hasan, kitchen + Vector3(-1.8, 0.45, 0), 12.0, 3.0],
		[huseyin, kitchen + Vector3(0.0, 0.45, 0), 12.5, -3.0],
		[urban, CANNON + Vector3(3.2, 0.4, 1.8), 7.0, 1.5],
		[day.goat, GOAT_TENT + Vector3(0, 2.75, 0), 10.0, 4.0],
		[chicken, CANNON + Vector3(-6.0, 0, 9.0), 14.0, 6.0],
	]
	for i in gunners.size():
		flights.append([gunners[i], CANNON + Vector3(-9.0 + i * 5.0, 0, -9.0 + i * 3.0), 8.0 + i * 2.0, 2.5])
	# Fatih'in muhafızları uçtuğu için Fatih yalnız kalır; yerinden kıpırdamaz
	var dur := 1.3
	for fl in flights:
		_fly(fl[0], fl[1], fl[2], fl[3], dur)
	Audio.sfx("whoosh_fly", -4.0)
	Audio.sfx("crowd_gasp", -8.0)
	hud.tolga_soot = true
	# Uçuşun ortasında Tolga'nın gözünden
	await get_tree().create_timer(dur * 0.45, true, false, false).timeout
	player.gravity_on = false
	player.global_position = TOLGA_AT + Vector3(0, 6.0, 0) + (FATIH_AT - TOLGA_AT) * 0.45
	player.face(FATIH_AT + Vector3(2.0, 1.0, 6.0))
	tolga_double.visible = false
	player.camera.make_current()
	var roll := create_tween()
	roll.tween_property(player.camera, "rotation:z", 1.2, dur * 0.5)
	hud.bark("SPK_TOLGA", "D10B_T_B3_AIR", 8.0)
	await get_tree().create_timer(dur * 0.25, true, false, false).timeout
	hud.bark("SPK_HIKMET", "D10B_H_B3_AIR", 8.0)
	var land := FATIH_AT + Vector3(-1.4, 0.1, -0.8)
	var tw := create_tween()
	tw.tween_property(player, "global_position", land, dur * 0.3)
	await tw.finished
	player.camera.rotation.z = 0.0
	player.gravity_on = true
	player.shake(0.5)
	Vfx.dust(self, land, 0.8)
	Audio.sfx("land_thud", -2.0)
	Audio.sfx("cartoon_boing", -10.0)
	Vfx.stars(self, land + Vector3(0, 1.9, 0))
	await get_tree().create_timer(dur * 0.3, true, false, false).timeout
	Engine.time_scale = 2.5 if GameState.autotest else 1.0
	hud.set_cinematic(false)
	_ear_ring(false)
	Audio.music("camp_day", 1.5)
	# Enkaz: topun yerinde kararmış bir krater, dağılmış tahtalar
	Props.cyl(self, 2.6, 0.04, CANNON + Vector3(0, 0.02, 0), Color("2a2420"), Vector3.ZERO, 14)
	for i in 6:
		var a := i * 1.1
		Props.box(self, Vector3(1.2, 0.12, 0.3), CANNON + Vector3(cos(a) * 4.0, 0.06, sin(a) * 4.0), Color("4a3020"), Vector3(0, rad_to_deg(a), 0))
	for p in [urban, hasan, huseyin] + gunners:
		Vfx.soot(p)
		if p.has_method("emote"):
			p.emote(["surprise", "facepalm", "shrug"][randi() % 3])
	# Fatih'in yüzünde tek bir is lekesi; kavuğu yerinde
	Vfx.soot(fatih, 1.62, false)
	player.face(fatih.global_position + Vector3(0, 1.6, 0))
	await _t("D10B_T_B3_3")
	Vfx.smoke_ring(self, player.global_position + Vector3(0, 1.55, 0) + (fatih.global_position - player.global_position).normalized() * 0.4)
	await _wait(0.8)
	await _say("SPK_FATIH", "D10B_F_B3_1")
	player.face(urban.global_position + Vector3(0, 1.0, 0))
	await _say("SPK_URBAN", "D10B_U_B3_4")
	player.face(fatih.global_position + Vector3(0, 1.6, 0))
	await _say("SPK_FATIH", "D10B_F_B3_2P" if _powder == 2 else "D10B_F_B3_2")
	await _say("SPK_FATIH", "D10B_F_B3_3")
	await _t("D10B_T_B3_4")
	await _say("SPK_FATIH", "D10B_F_B3_4")
	await _t("D10B_T_B3_5")
	await _say("SPK_FATIH", "D10B_F_B3_5")
	await _say("SPK_KADRI", "D10B_KADRI_B3")
	GameState.paradox += 40
	GameState.flags["world10"] = "W5B"
	GameState.flags["big_bang"] = true
	_outcome = "10B.3"


## Bir karakteri yay çizerek, dönerek uçurur (fizik yok; tween).
func _fly(node: Node3D, to: Vector3, peak: float, spin: float, dur: float) -> void:
	var from := node.global_position
	var rot0 := node.rotation
	var tw := create_tween()
	tw.tween_method(func(k: float):
		var p := from.lerp(to, k)
		p.y += sin(k * PI) * peak
		node.global_position = p
		node.rotation = Vector3(rot0.x + sin(k * TAU) * 0.6 * spin * (1.0 - k), rot0.y + k * spin * TAU * (1.0 - k * 0.5), rot0.z + k * spin * 1.4 * (1.0 - k)), 0.0, 1.0, dur)
	tw.tween_callback(func():
		node.rotation = rot0
		Vfx.dust(self, to, 0.5)
		if node == hasan or node == huseyin:
			Audio.sfx("land_pot", -4.0)
		else:
			Audio.sfx("land_thud", -8.0))


func _boom_sfx() -> void:
	if ResourceLoader.exists("res://assets/audio/sfx/explosion_big.ogg"):
		Audio.sfx("explosion_big", 2.0)
	else:
		Audio.sfx("cannon", 2.0, 0.55)
		Audio.sfx("cannon", 0.0, 0.8)


## Patlamadan sonra kulak çınlaması: bütün sesler boğuklaşır.
func _ear_ring(on: bool) -> void:
	var master := AudioServer.get_bus_index("Master")
	if on:
		var lp := AudioEffectLowPassFilter.new()
		lp.cutoff_hz = 500.0
		AudioServer.add_bus_effect(master, lp)
		Audio.sfx("ear_ring", -6.0)
	else:
		for i in range(AudioServer.get_bus_effect_count(master) - 1, -1, -1):
			if AudioServer.get_bus_effect(master, i) is AudioEffectLowPassFilter:
				AudioServer.remove_bus_effect(master, i)


## Hikmet telsizden: pencere için hazırlanıyor.
func _radio() -> void:
	await _wait(0.6)
	await hud.say("SPK_HIKMET", "D10B_H_RADIO_1")
	await _t("D10B_T_RADIO_" + _outcome.substr(4, 1))
	await hud.say("SPK_HIKMET", "D10B_H_RADIO_3")
	if _outcome == "10B.3":
		await _t("D10B_T_RADIO_4")


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	Engine.time_scale = 1.0
	GameState.set_outcome(10, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=10b -> 11 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter11.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter11.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW10B_TITLE")
	c.nodes = [
		{"id": "cast", "key": "FLOW10B_CAST", "pos": Vector2(0.14, 0.14)},
		{"id": "name", "key": "FLOW10B_NAME", "pos": Vector2(0.38, 0.14)},
		{"id": "tape", "key": "FLOW10B_TAPE", "pos": Vector2(0.62, 0.14)},
		{"id": "powder", "key": "FLOW10B_POWDER", "pos": Vector2(0.86, 0.14)},
		{"id": "calc", "key": "FLOW10B_CALC", "pos": Vector2(0.5, 0.34)},
		{"id": "10B.1", "key": "FLOW_10B_1", "pos": Vector2(0.2, 0.56), "outcome": true},
		{"id": "10B.2", "key": "FLOW_10B_2", "pos": Vector2(0.5, 0.56), "outcome": true},
		{"id": "10B.3", "key": "FLOW_10B_3", "pos": Vector2(0.8, 0.56), "outcome": true},
	]
	c.edges = [["cast", "name"], ["name", "tape"], ["tape", "powder"], ["powder", "calc"], ["calc", "10B.1"], ["calc", "10B.2"],
		["calc", "10B.3"]]
	for id in ["cast", "name", "powder", "calc", _outcome]:
		c.taken[id] = true
	if _taped:
		c.taken["tape"] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH10B_STATS") % [_quality, _risk, GameState.paradox],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW10B_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim ve yardımcılar

func _on_interact(_id: String) -> void:
	pass


func _npc(speaker: String) -> Person:
	match speaker:
		"SPK_URBAN": return urban
		"SPK_FATIH": return fatih
	return null


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _say(speaker: String, key: String) -> void:
	var who := _npc(speaker)
	if who:
		who.talking = true
	await hud.say(speaker, key)
	if who and is_instance_valid(who):
		who.talking = false


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var expected: String = {"": "10B.1", "eye": "10B.2", "boom": "10B.3", "untaped": "10B.3", "tape": "10B.1",
		"next": "10B.1"}[GameState.autotest_variant]
	var ok: bool = _outcome == expected and GameState.chapter_outcomes.get(10, "") == _outcome
	if GameState.autotest_variant == "tape":
		ok = ok and _taped
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s" % [expected, _outcome])
	print("AUTOTEST %s chapter=10b variant=%s outcome=%s quality=%d risk=%d calc=%s paradox=%d" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, _outcome, _quality, _risk, _calc, GameState.paradox])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(file_name: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file_name))
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	await get_tree().create_timer(0.8).timeout
	# 1. Döküm
	urban.position = FOUNDRY + Vector3(-1.8, 0, -0.2)
	player.global_position = FOUNDRY + Vector3(-3.2, 0.1, 3.8)
	_molds[0].visible = true
	_molds[0].position.y += 0.5
	_crucible.position.x = _molds[1].global_position.x
	_crucible.rotation.z = -0.9
	_stream.visible = true
	var top := _crucible.global_position + Vector3(0, 0.1, 0)
	var bottom := _molds[1].global_position
	_molds[1].visible = true
	_stream.global_position = (top + bottom) * 0.5
	_stream.scale = Vector3(1, top.y - bottom.y, 1)
	player.face(_molds[1].global_position + Vector3(0, 0.6, 0))
	hud.bark("SPK_URBAN", "D10B_U_CAST_INTRO", 30.0)
	await _shot("c10b_01_dokum.png")
	_stream.visible = false
	# 2. Sultan sahada
	urban.position = URBAN_AT
	fatih.visible = true
	fatih.position = FATIH_AT
	fatih.look_target = player
	hasan.visible = true
	huseyin.visible = true
	hasan.position = FATIH_AT + Vector3(1.2, 0, 1.4)
	huseyin.position = FATIH_AT + Vector3(-0.6, 0, 1.8)
	player.global_position = TOLGA_AT + Vector3(0, 0.1, 0)
	player.face(fatih.global_position + Vector3(-1.5, 1.4, -1.5))
	hud.bark("SPK_FATIH", "D10B_F_02", 30.0)
	await get_tree().create_timer(0.3).timeout
	await _shot("c10b_02_sultan.png")
	# 3. Büyük Patlama: ağır çekim geniş plan (fragman karesi)
	hud.bark("", "", 0.01)
	_cine = Camera3D.new()
	add_child(_cine)
	_cine.global_position = CANNON + Vector3(-11.0, 3.4, 4.0)
	_cine.look_at(CANNON + Vector3(2.0, 3.6, -0.5), Vector3.UP)
	_cine.fov = 64.0
	_cine.make_current()
	hud.set_cinematic(true)
	day.cannon.visible = false
	tolga_double.visible = true
	tolga_double.global_position = TOLGA_AT
	Vfx.explosion(self, CANNON + Vector3(0, 1.3, 0), 1.3)
	var poses: Array = [[tolga_double, TOLGA_AT + Vector3(1.5, 5.0, 1.0), Vector3(0.5, 0.8, 1.2)],
		[hasan, CANNON + Vector3(-2.5, 7.0, 2.0), Vector3(1.4, 0.2, 0.6)], [huseyin, CANNON + Vector3(-3.6, 6.4, 2.6), Vector3(-1.0, 1.0, -0.8)],
		[urban, CANNON + Vector3(2.4, 4.2, -1.5), Vector3(0.3, 2.0, 1.6)], [day.goat, CANNON + Vector3(5.0, 6.5, 4.0), Vector3(1.2, 0.4, 2.2)],
		[chicken, CANNON + Vector3(-1.0, 9.0, 5.0), Vector3(0.4, 2.0, 0.3)]]
	for i in gunners.size():
		poses.append([gunners[i], CANNON + Vector3(-5.0 + i * 3.0, 4.0 + i * 1.2, -2.0 + i * 2.0), Vector3(i * 0.9, i * 1.3, 1.0)])
	for p in poses:
		(p[0] as Node3D).global_position = p[1]
		(p[0] as Node3D).rotation = p[2]
	fatih.look_target = null
	fatih.look_at(CANNON, Vector3.UP)
	fatih.rotate_y(PI)
	await get_tree().create_timer(0.35).timeout
	get_tree().paused = true
	await _shot("c10b_03_patlama.png")
	get_tree().paused = false
	get_tree().quit()
