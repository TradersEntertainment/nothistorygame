extends Node3D
## Bölüm 38 (yalnız Osmanlı tarafı) — Haliç Surları (Tolga · 29 Mayıs 1453, gece 01.30 → öğle). docs/OTTOMAN_NEW_B.md §2.
##
## Son hücumda Haliç'e karadan aşırılan gemiler de surlara merdiven dayadı; Haliç suru kara surları düşene kadar dayandı.
## Sabah şehir düşünce tayfa karaya dağıldı, Petrion teslim oldu; öğlen Hristiyan gemileri zinciri kesip kaçtı.
## Tolga 19o'nun devriye reisinin fustasında.
##   1. Kürek: Haliç'i surlara geç (RowMeter). Ok yaylımında C basılı: küpeşte kalkanının dibine çömel.
##   2. Merdiven: ayağını tut (BalanceMeter); çatal gelince Space ile bastır; güvertede ateş çömleği: kum kovası (8 sn);
##      sonra tırman: taş ve kaynar yağ (OilHazard, A/D ile yana sark). Reis geri çağırır.
##   3. Şafak: burçlarda sancak, tayfa karaya. Halatı rıhtımdaki babaya sar (E basılı, kırmızıda bırak); tekne ile rıhtım
##      arasına düşeni çek (E basılı, tekne vurunca bırak). Petrion'un ihtiyarları: çeviri seçimi.
##   4. Öğle: zincire inen gemilerin peşinden kürek; kıç topu: halka nerede, A/D. Tespit: kaçan gemiler.
##   38O.1 Merdiven tuttu, düşeni sen çektin · 38O.2 Düşeni yaşlı tayfa çekti
##   --autotest[=lose]   (varsayılan: 38O.1)

const WALL_Z := 62.0
const WALK_Y := 9.6
const DECK := SeaBattle.GALLEY_DECK
const ROW_FROM := Vector3(-6.0, 0.0, 10.0)
const ROW_TO := Vector3(-6.0, 0.0, 46.0)
const ROW_BEATS := 20
const HOLD_TIME := 45.0
const QUAY := Rect2(6.0, 57.4, 18.0, 2.8)      # x, z, w, d (üstü y 1.2)
const QUAY_Y := 1.2
const BOLLARD := Vector3(13.0, QUAY_Y, 58.4)
const GATE_X := 15.0

var player: Player
var hud: Hud
var meter: RowMeter
var balance: BalanceMeter
var galley: Node3D
var ladder: Ladder
var fight: WallFight
var oil: OilHazard
var cam: TespitCam
var reis: Person
var old_sailor: Person
var sailor: Person
var swimmer: Person
var elders: Array[Person] = []
var gate_l: Node3D
var gate_r: Node3D
var ships: Array[Node3D] = []
var env: Environment
var moon: DirectionalLight3D
var phase := "intro"
var _outcome := ""
var _photo := ""
var beats_good := 0
var beats_done := 0
var arrows := 0
var forks_braced := 0
var forks := 0
var fire_ok := false
var sail_burnt := false
var oil_hit := false
var tolga_pulled := false
var snaps := 0
var splashes := 0
var petrion_word := ""
var _strokes: Array = []
var _bal := 0.0
var _t := 0.0
var guards: Array[WallGuard] = []
var _guard_spots: Array[Transform3D] = []
var explored := 0.0            # surdan şehir tarafına en çok kaç metre gidildi
const EXPLORE_TIME := 75.0


func _ready() -> void:
	GameState.snapshot(38)
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
	meter = RowMeter.new()
	hud.add_child(meter)
	meter.stroke.connect(func(good: bool): _strokes.append(good))
	balance = BalanceMeter.new()
	balance.label_text = tr("UI_OBJ38O_HOLD")
	balance.visible = false
	hud.add_child(balance)
	balance.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	balance.position = Vector2(-210, -200)
	moon = Night.environment(self, 0.004)
	moon.rotation_degrees = Vector3(-30, 150, 0)
	for c in get_children():
		if c is WorldEnvironment:
			env = (c as WorldEnvironment).environment
	Horn.build(self, WALL_Z, Rect2(), Vector2(-24.0, 24.0), 3801, true, false, false)
	# Oynanış alanı surun iç yüzünde biter: arkası dünyanın şehri (yürünür; surdan inilip gezilir)
	World1453.build(self, "horn_wall_o", [Rect2(-Horn.WORLD_E, -12.0, Horn.WORLD_E * 2.0, WALL_Z + 14.0)], true)
	_build_wall()
	_build_boat()
	_build_ships()
	guards = WallGuard.spawn_all(self, _guard_spots, player)
	for g in guards:
		g.active = false
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ yerleşim

## Haliç surunun bu kesimi (18b'nin parçası gibi): gövde, yürüyüş yolu, mazgallar, kuleler; deniz kapısı ve rıhtım
func _build_wall() -> void:
	var c := Color("cdbd9e")
	Props.set_pattern(Props.solid(self, Vector3(48, WALK_Y, 4.0), Vector3(0, WALK_Y * 0.5, WALL_Z), Color.WHITE), c, "ashlar")
	Props.set_pattern(Props.solid(self, Vector3(48, 0.3, 4.4), Vector3(0, WALK_Y - 0.13, WALL_Z - 0.2), Color.WHITE), Color("b8a888"), "cobble")
	for i in 19:
		Props.set_pattern(Props.box(self, Vector3(1.2, 1.1, 0.5), Vector3(-22.5 + i * 2.5, WALK_Y + 0.55, WALL_Z - 2.15), Color.WHITE), Color("a89878"), "ashlar")
	for sx: float in [-1.0, 1.0]:
		Props.set_pattern(Props.solid(self, Vector3(6.2, WALK_Y + 5.0, 6.2), Vector3(sx * 21.0, (WALK_Y + 5.0) * 0.5, WALL_Z), Color.WHITE), Color("c8b898"), "ashlar")
	# Mazgallarda savunanlar (Venedikli ve Rum)
	for k in 7:
		var x := -16.0 + k * 4.4
		if absf(x - GATE_X) < 1.5:
			continue
		if absf(x - ROW_TO.x) < 2.6:
			continue          # merdivenin ağzı boş (oyuncu buraya çıkar)
		_guard_spots.append(Transform3D(Basis(Vector3.UP, PI), Vector3(x, WALK_Y, WALL_Z - 1.4)))
	# Deniz kapısı ve önündeki dar taş rıhtım (üstü y 1,2), iki demir baba
	Props.set_pattern(Props.solid(self, QUAY.size.x * Vector3(1, 0, 0) + Vector3(0, QUAY_Y + 1.0, QUAY.size.y),
		Vector3(QUAY.get_center().x, QUAY_Y * 0.5 - 0.5, QUAY.get_center().y), Color.WHITE), Color("b8a888"), "ashlar")
	for bx: float in [BOLLARD.x, BOLLARD.x + 7.0]:
		Props.make_solid(Props.cyl(self, 0.18, 0.7, Vector3(bx, QUAY_Y + 0.35, BOLLARD.z), Color("3a3a40"), Vector3.ZERO, 8))
	Props.box(self, Vector3(3.2, 4.2, 0.3), Vector3(GATE_X, QUAY_Y + 2.1, WALL_Z - 2.05), Color("1a1410"))
	gate_l = Node3D.new()
	gate_l.position = Vector3(GATE_X - 1.5, QUAY_Y, WALL_Z - 2.25)
	add_child(gate_l)
	Props.box(gate_l, Vector3(1.5, 4.0, 0.12), Vector3(0.75, 2.0, 0), Color("5a3e26"))
	gate_r = Node3D.new()
	gate_r.position = Vector3(GATE_X + 1.5, QUAY_Y, WALL_Z - 2.25)
	add_child(gate_r)
	Props.box(gate_r, Vector3(1.5, 4.0, 0.12), Vector3(-0.75, 2.0, 0), Color("4a3220"))
	Props.interactable(self, "bollard", Vector3(1.6, 1.6, 1.6), BOLLARD + Vector3(0, 0.6, 0))
	# Kazan: yürüyüş yolunun deniz kenarında, merdivenin yanında; denize döndürülür
	fight = WallFight.new()
	add_child(fight)
	var cd := fight.add_cauldron(Vector3(ROW_TO.x - 0.6, WALK_Y, WALL_Z - 1.3), 3802)
	(cd["node"] as Node3D).rotation.y = PI
	_cauldron = cd


var _cauldron: Dictionary


func _build_boat() -> void:
	galley = SeaBattle.war_galley(self, ROW_FROM, PI)
	# Oyuncunun oturduğu yerin çevresindeki kürekçi çıkarılır
	var keep: Array = []
	for r: Person in galley.get_meta("rowers"):
		# Oturulan yerin çevresi ve önü (görüşü kapatmasın)
		var rel := r.position - Vector3(1.0, DECK, 4.0)
		if rel.length() < 1.4 or (r.position.x > 0.0 and rel.z < 0.0 and rel.z > -3.2):
			r.queue_free()
		else:
			keep.append(r)
	galley.set_meta("rowers", keep)
	# Küpeşte kalkanları (siper), direk dibinde kum kovası
	for z: float in [-4.0, 0.0, 4.0]:
		Props.cyl(galley, 0.5, 0.06, Vector3(1.85, DECK + 0.7, z), Color("c8a868"), Vector3(0, 0, 90), 12)
	_sand = Node3D.new()
	_sand.position = Vector3(0.7, DECK, -1.8)
	galley.add_child(_sand)
	Props.cyl(_sand, 0.2, 0.36, Vector3(0, 0.18, 0), Color("6a4a2c"), Vector3.ZERO, 10, 0.85)
	Props.cyl(_sand, 0.18, 0.03, Vector3(0, 0.36, 0), Color("d8c08a"), Vector3.ZERO, 10)
	Props.interactable(_sand, "sand", Vector3(1.0, 1.2, 1.0), Vector3(0, 0.6, 0))
	reis = Person.new({"coat": Color("3a5a78"), "pants": Color("e8e0d0"), "hat": "turban", "mustache": true, "beard": true, "skin": Color("c89070")})
	reis.set_meta("spk", "SPK_PATROL")
	reis.position = Vector3(0, DECK, 7.4)
	galley.add_child(reis)
	reis.look_target = player
	old_sailor = Person.new({"coat": Color("6a5040"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true,
		"hair": Color("b0b0a8"), "skin": Color("c08868")})
	old_sailor.set_meta("spk", "SPK_SAILOR2")
	old_sailor.position = Vector3(-0.8, DECK, -5.0)
	galley.add_child(old_sailor)
	sailor = Person.new({"coat": Color("7a4a3a"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")})
	sailor.set_meta("spk", "SPK_SAILOR")
	sailor.position = Vector3(-0.8, DECK, -7.6)
	galley.add_child(sailor)


var _sand: Node3D


func _build_ships() -> void:
	# Kaçan Hristiyan gemileri (öğlene kadar Haliç'in doğusunda, zincire yakın): iki Ceneviz gemisi, üç Venedik kadırgası
	for i in 2:
		var s := SeaBattle.carrack(self, Vector3(70.0 + i * 16.0, 0, 34.0 + i * 6.0), -PI * 0.5, 6, 3810 + i)
		ships.append(s)
	for i in 3:
		var g := SeaBattle.war_galley(self, Vector3(60.0 + i * 12.0, 0, 22.0 + (i % 2) * 6.0), -PI * 0.5, false, false)
		Props.box(g, Vector3(0.04, 1.0, 1.6), Vector3(0, DECK + 9.4, -3.8), Color("c8a030"))      # Venedik: kırmızı-altın
		ships.append(g)
	for s in ships:
		s.visible = false


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH38O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH38O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.pinned = true
	player.show_remote(false)
	_seat()
	player.face(Vector3(-6.0, 8.0, WALL_Z))
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D38O_N_01")
	await hud.say("SPK_TOLGA", "D38O_T_01")
	await hud.say("SPK_PATROL", "D38O_R_01")
	await hud.say("SPK_TOLGA", "D38O_T_R1")
	await hud.say("SPK_PATROL", "D38O_R_02")
	hud.bark("SPK_SAILOR2", "D38O_S2_01", 4.0)
	await _row()
	await _ladder_phase()
	await _climb()
	await _dawn()
	await _rope_phase()
	await _rescue()
	await _petrion()
	await _chase()
	await _end_text()
	await _end_chapter()


func _seat() -> void:
	player.eye_height = 1.15
	player.global_position = galley.to_global(Vector3(1.0, DECK + 0.05, 4.0))


func _stand(local: Vector3) -> void:
	player.pinned = false
	player.eye_height = Player.EYE
	player.global_position = galley.to_global(local + Vector3(0, DECK + 0.05, 0))


# ---------------------------------------------------------------- 1. kürek

var _row_d := 0.0
var _row_speed := 0.0


func _row() -> void:
	phase = "row"
	_strokes.clear()
	meter.enabled = true
	player.frozen = false
	hud.set_objective(tr("UI_OBJ38O_ROW") % [0, ROW_BEATS], Vector3(-6.0, 6.0, WALL_Z))
	var warn := -1.0
	var next_volley := 9.0
	var crouch_pen := 0
	var t := 0.0
	var total := ROW_FROM.distance_to(ROW_TO)
	while _row_d < total - 0.05 and t < 150.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var crouch := Input.is_action_pressed("dive") or (GameState.autotest and warn >= 0.0)
		player.eye_height = lerpf(player.eye_height, 0.7 if crouch else 1.15, minf(1.0, dt * 10.0))
		if Input.is_action_just_pressed("jump") and not crouch:
			meter.press()
		while _strokes.size() > 0:
			var good: bool = _strokes.pop_front()
			if crouch:
				crouch_pen += 1
				continue        # çömelirken kürek bırakılır: vuruş sayılmaz
			beats_done += 1
			if good:
				beats_good += 1
				if beats_good % 6 == 0:
					hud.bark("SPK_PATROL", "D38O_R_ROW_OK", 2.0)
			else:
				Audio.sfx("kick_metal", -14.0, 0.7)       # kürekler çarpışır
				galley.rotation.z = 0.05
				hud.bark("SPK_PATROL", "D38O_R_ROW_BAD", 2.0)
			hud.set_objective(tr("UI_OBJ38O_ROW") % [beats_good, ROW_BEATS], Vector3(-6.0, 6.0, WALL_Z))
		var target := (1.0 + 1.6 * meter.speed_factor()) if not crouch else 0.3
		_row_speed = move_toward(_row_speed, target, dt * 1.2)
		_row_d = minf(_row_d + _row_speed * dt, total)
		galley.position = ROW_FROM.lerp(ROW_TO, _row_d / total) + Vector3(0, sin(_t * 1.3) * 0.05, 0)
		galley.rotation.z = lerpf(galley.rotation.z, 0.0, dt * 2.0)
		SeaBattle.row_oars(galley, meter.phase, true)
		_seat()
		# İki ok yaylımı (yarı yolda ve sura yakın)
		if warn < 0.0:
			next_volley -= dt
			if next_volley <= 0.0 and _row_d < total - 4.0:
				warn = 0.0
				hud.set_qte(tr("UI_OBJ38O_COVER"))
				hud.bark("SPK_SAILOR", "D38O_S_ARROW", 2.0)
		else:
			var before := warn
			warn += dt
			if before < 0.6 and warn >= 0.6:
				_arrows_at(galley.global_position, 16)
			if warn >= 2.2:
				warn = -1.0
				next_volley = 14.0
				hud.set_qte("")
				if not crouch:
					arrows += 1
					player.hurt(25.0, Vector3(galley.global_position.x, WALK_Y, WALL_Z))
	meter.enabled = false
	hud.set_qte("")
	hud.set_objective("")
	SeaBattle.row_oars(galley, 0.0, false)
	player.frozen = true
	player.eye_height = 1.15


## Surdan ok yağmuru: oklar yay çizip güverteye ve suya iner (suya düşen sıçrar, güverteye saplanan kalır)
func _arrows_at(c: Vector3, n: int) -> void:
	Audio.sfx("whoosh_fly", -6.0, 0.9)
	for i in n:
		var from := Vector3(c.x + randf_range(-10, 10), WALK_Y + 2.0, WALL_Z - 2.0)
		var to := c + Vector3(randf_range(-2.4, 2.4), DECK, randf_range(-8.0, 8.0))
		var on_deck := absf(to.x - c.x) < 1.6
		if not on_deck:
			to.y = 0.0
		var a := MeshInstance3D.new()
		a.mesh = Assault.arrow_mesh()
		add_child(a)
		a.global_position = from
		a.look_at(to, Vector3.UP)
		var tw := a.create_tween()
		tw.tween_property(a, "global_position", to, randf_range(1.0, 1.5)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		if on_deck:
			tw.tween_callback(func():
				if is_instance_valid(a) and is_instance_valid(galley):
					a.reparent(galley))
		else:
			tw.tween_callback(func():
				Vfx.dust(self, to, 0.15)
				a.queue_free())


# ---------------------------------------------------------------- 2. merdiven

var _fork_window := -1.0
var _fire_t := -1.0
var _pot_thrown := false
var _fires: Array = []
var _has_sand := false
var _holding := true


func _ladder_phase() -> void:
	phase = "ladder"
	await hud.say("SPK_PATROL", "D38O_R_03")
	# Merdiven pruvadan mazgala: ayağı güvertede (halatla bağlı), tepesi yürüyüş yolunun ağzında
	var foot := galley.to_global(Vector3(0, DECK, -9.4))
	var top := Vector3(foot.x, WALK_Y + 0.4, WALL_Z - 2.3)
	var d := top - foot
	var h := d.length()
	var tilt := rad_to_deg(atan2(d.z, d.y))
	ladder = Ladder.new(h, tilt, Color("6a4a2c"))
	ladder.position = foot
	ladder.rotation.y = PI
	add_child(ladder)
	Props.cyl(galley, 0.02, 1.2, Vector3(0, DECK + 0.3, -8.8), Color("b89a6a"), Vector3(70, 0, 0), 4)      # ayak halatı
	# Merdivende iki tayfa tırmanıyor
	var climbers: Array[Person] = []
	for k in 2:
		var cl := Person.new({"coat": [Color("7a4a3a"), Color("5a6a7a")][k], "pants": Color("e8e0d0"), "hat": "bork", "mustache": true})
		cl.set_meta("climber", true)
		cl.set_meta("no_talk", true)
		add_child(cl)
		cl.global_position = ladder.point_at(2.6 + k * 2.8) + ladder.front_dir() * 0.4
		cl.rotation.y = PI
		cl.set_activity("climb_a")
		climbers.append(cl)
	_stand(Vector3(0.0, 0, -7.8))
	player.face(ladder.point_at(h * 0.6))
	await hud.say("SPK_TOLGA", "D38O_T_02")
	balance.visible = true
	player.frozen = true
	hud.set_objective(tr("UI_OBJ38O_HOLD"))
	var t := 0.0
	var fork_at := [8.0, 18.0, 33.0]
	var pot_at := 25.0
	var lose := GameState.autotest_variant == "lose"
	var slips := 0
	while t < HOLD_TIME:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		# Dalga merdiveni sallar; A/D ile ibre ortada tutulur. Ateşe koşulurken ibre serbest kalır.
		var swell := sin(t * 1.1) * 0.35 + sin(t * 2.7 + 1.0) * 0.18
		var input := Input.get_axis("move_left", "move_right") if _holding else 0.0
		if GameState.autotest and _holding:
			input = -signf(_bal) * 0.9 if absf(_bal) > 0.1 else 0.0
		_bal += (swell * 0.4 + input * 1.4 + (randf_range(-0.6, 0.6) if not _holding else 0.0)) * dt
		balance.value = _bal
		ladder.rotation.z = _bal * 0.05
		for k in climbers.size():
			climbers[k].global_position = ladder.point_at(2.6 + k * 2.8) + ladder.front_dir() * 0.4
		if absf(_bal) >= 1.0:
			# Merdiven kayar: tırmanan iki tayfa güverteye düşer
			slips += 1
			_bal = 0.0
			Audio.sfx("land_thud", -2.0, 0.7)
			hud.bark("SPK_SAILOR", "D38O_S_BRACE_BAD", 2.5)
			Fx.trauma(0.4)
			for cl in climbers:
				cl.global_position = galley.to_global(Vector3(randf_range(-1, 1), DECK, -7.0))
			await get_tree().create_timer(1.2).timeout
		# Çatal: mazgaldan uzanır, merdivenin tepesini iter; 1,5 sn içinde Space = bastır
		if fork_at.size() > 0 and t >= fork_at[0]:
			fork_at.pop_front()
			forks += 1
			_fork_window = 0.0
			hud.set_qte(tr("UI_OBJ38O_BRACE") % [forks_braced, 3])
			hud.bark("SPK_SAILOR", "D38O_S_FORK", 1.6)
			_fork_visual(true)
		if _fork_window >= 0.0:
			_fork_window += dt
			var press := Input.is_action_just_pressed("jump") or (GameState.autotest and not lose and _fork_window > 0.4)
			if press and _fork_window <= 1.5:
				forks_braced += 1
				_fork_window = -1.0
				hud.set_qte("")
				hud.bark("SPK_SAILOR", "D38O_S_BRACE_OK", 2.0)
				Fx.trauma(0.2)
				_fork_visual(false)
			elif _fork_window > 1.5:
				_fork_window = -1.0
				hud.set_qte("")
				_bal += 0.7 * signf(_bal if _bal != 0.0 else 1.0)
				ladder.rotation.x = deg_to_rad(-5.0)
				create_tween().tween_property(ladder, "rotation:x", 0.0, 0.8)
				hud.bark("SPK_SAILOR", "D38O_S_BRACE_BAD", 2.0)
				_fork_visual(false)
		# Ateş çömleği güverteye
		if t >= pot_at and not _pot_thrown:
			_pot_thrown = true
			_start_deck_fire()
		if _fire_t >= 0.0:
			_fire_t += dt
			hud.set_qte(tr("UI_OBJ38O_POT"))
			if GameState.autotest:
				if lose and _fire_t < 8.5:
					pass
				elif not _has_sand:
					_on_interact("sand")
				else:
					_throw_sand()
			if _fire_t > 8.0 and not fire_ok:
				_fire_t = -1.0
				sail_burnt = true
				hud.set_qte("")
				hud.bark("SPK_SAILOR", "D38O_S_SAIL", 3.0)
				_end_deck_fire(false)
	balance.visible = false
	hud.set_qte("")
	hud.set_objective("")
	_holding = true
	player.frozen = true
	for cl in climbers:
		cl.queue_free()


func _fork_visual(on: bool) -> void:
	if on:
		_fork = Node3D.new()
		add_child(_fork)
		_fork.global_position = ladder.point_at(ladder.height) + Vector3(0, 0.6, 1.4)
		Props.cyl(_fork, 0.04, 3.0, Vector3(0, 0, -1.4), Color("6a4a2c"), Vector3(90, 0, 0), 5)
		for sx: float in [-0.12, 0.12]:
			Props.cyl(_fork, 0.02, 0.4, Vector3(sx, 0, -3.0), Color("3a3a40"), Vector3(90, 0, 0), 4)
		var tw := _fork.create_tween()
		tw.tween_property(_fork, "position:z", _fork.position.z - 0.8, 1.2)
	elif is_instance_valid(_fork):
		var f := _fork
		var tw := f.create_tween()
		tw.tween_property(f, "position:z", f.position.z + 1.4, 0.3)
		tw.tween_callback(f.queue_free)


var _fork: Node3D


func _start_deck_fire() -> void:
	_holding = false
	player.frozen = false
	hud.bark("SPK_SAILOR", "D38O_S_POT", 3.0)
	var at := galley.to_global(Vector3(0.0, DECK, -3.0))
	var pot := Props.ball(self, 0.18, Vector3(at.x, WALK_Y + 2.0, WALL_Z - 2.0), Color("8a5a3a"), Vector3.ONE, 8)
	var tw := pot.create_tween()
	tw.tween_property(pot, "global_position", at + Vector3(0, 0.2, 0), 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		pot.queue_free()
		Audio.sfx("explosion_small", -4.0, 1.1)
		for k in 3:
			_fires.append(Vfx.fire(galley, Vector3(-0.6 + k * 0.6, DECK, -3.0 + randf_range(-0.4, 0.4)), 0.7))
		_fire_t = 0.0)      # 8 sn çömlek güverteye düştüğünde başlar
	hud.set_objective(tr("UI_OBJ38O_POT"), galley.to_global(Vector3(0.7, DECK + 1.0, -1.8)))


func _throw_sand() -> void:
	if not _has_sand:
		return
	var at := galley.to_global(Vector3(0.0, DECK, -3.0))
	if player.global_position.distance_to(at) > 3.0 and not GameState.autotest:
		return
	_has_sand = false
	if is_instance_valid(_carry):
		_carry.queue_free()
	Vfx.dust(self, at + Vector3(0, 0.3, 0), 1.0)
	Vfx.steam(self, at + Vector3(0, 0.4, 0))
	fire_ok = true
	_fire_t = -1.0
	hud.set_qte("")
	hud.bark("SPK_TOLGA", "D38O_T_POT_OK", 3.0)
	_end_deck_fire(true)


func _end_deck_fire(out: bool) -> void:
	for f in _fires:
		if is_instance_valid(f):
			if out:
				(f as Node3D).queue_free()
	if not out:
		# Yelken tutuşur, iki tayfa kovayla söndürür: yelken kararır
		Vfx.smolder(galley, Vector3(0, DECK + 6.0, -2.0), 1.2, true)
		var tw := create_tween()
		tw.tween_interval(4.0)
		tw.tween_callback(func():
			for f in _fires:
				if is_instance_valid(f):
					(f as Node3D).queue_free())
	_fires.clear()
	_holding = true
	player.frozen = true
	_stand(Vector3(0.0, 0, -7.8))
	player.face(ladder.point_at(ladder.height * 0.6))
	hud.set_objective(tr("UI_OBJ38O_HOLD"))


var _carry: Node3D


# ---------------------------------------------------------------- 2d. tırman

var _stone_falling := false


func _climb() -> void:
	phase = "climb"
	await hud.say("SPK_PATROL", "D38O_R_UP")
	player.global_position = ladder.global_position + Vector3(0, 0.05, -1.0)
	player.face(ladder.point_at(2.5))
	player.frozen = false
	hud.set_objective(tr("UI_OBJ38O_CLIMB"), ladder.point_at(ladder.height))
	oil = OilHazard.make(self, fight, _cauldron, ladder, player, hud)
	var t := 0.0
	var stone_done := false
	while not (player.ladder == null and player.global_position.y > WALK_Y - 0.6) and t < 60.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if player.ladder == ladder:
			if not stone_done and player._ladder_t > ladder.height * 0.25 and not oil.active:
				stone_done = true
				_drop_stone()
			if stone_done and not _stone_falling and player._ladder_t > ladder.height * 0.5:
				if oil.trigger():
					hud.bark("SPK_SAILOR", "D38O_S_OIL", 2.0)
		if GameState.autotest:
			if _stone_falling or oil.active:
				Input.action_release("move_forward")
			else:
				Input.action_press("move_forward")
			player.face(ladder.point_at(clampf(player._ladder_t + 2.0, 0.0, ladder.height)))
			if t > 40.0:
				player.ladder = null
				player.global_position = ladder.top_exit()
	if GameState.autotest:
		Input.action_release("move_forward")
	oil_hit = oil.hits > 0
	player.frozen = true
	hud.set_objective("")
	await _explore()
	player.frozen = true
	await hud.say("SPK_TOLGA", "D38O_T_UP")
	await hud.say("SPK_PATROL", "D38O_R_BACK")
	await hud.fade_to(1.0, 0.4)
	player.ladder = null
	_stand(Vector3(0.6, 0, -6.0))
	ladder.queue_free()
	await hud.fade_to(0.0, 0.4)


## 2e. Surun üstü: mazgallar ele geçmedi ama oyuncu yukarıda. Arkada şehir (dünyanın şehri, yürünür): bakılır, inilir,
## sokaklarda gezilir. Sur yolundaki savunanlar canlı (yaklaşanı mızrakla dürter). Boru çalınca (ya da oyuncu
## merdivenin ağzına dönünce) geri.
func _explore() -> void:
	phase = "explore"
	await hud.say("SPK_TOLGA", "D38O_T_TOP")
	for g in guards:
		g.active = true
	_stair_down()
	player.frozen = false
	var t := 0.0
	var limit := 6.0 if GameState.autotest else EXPLORE_TIME
	var top := ladder.top_exit()
	while t < limit:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		hud.set_objective(tr("UI_OBJ38O_EXPLORE") % ceili(limit - t), top + Vector3(0, 1.0, 0))
		explored = maxf(explored, player.global_position.z - WALL_Z)
		if GameState.autotest:
			# Bot: şehir tarafına yürür (iç kenardan iner)
			player.face(player.global_position + Vector3(0, 0, 10.0))
			Input.action_press("move_forward")
		elif t > 8.0 and player.global_position.distance_to(top) < 1.6:
			break        # merdivene döndü
	if GameState.autotest:
		Input.action_release("move_forward")
	hud.set_objective("")
	for g in guards:
		g.active = false
	player.frozen = true
	Audio.stinger("warn", -6.0)
	await hud.say("SPK_PATROL", "D38O_R_HORN")


## Sur yolundan şehir tarafına taş merdiven: dünyanın zeminine iner (zemin yürüyüş yoluna yakınsa gerekmez)
func _stair_down() -> void:
	var x0 := ROW_TO.x - 4.0
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(Vector3(x0, WALK_Y + 20.0, WALL_Z + 8.0), Vector3(x0, -20.0, WALL_Z + 8.0))
	q.exclude = [player.get_rid()]
	var hit := space.intersect_ray(q)
	var gy: float = (hit["position"] as Vector3).y if not hit.is_empty() else QUAY_Y
	if gy > WALK_Y - 0.8:
		return
	var run := clampf((WALK_Y - gy) * 1.4, 3.0, 16.0)
	var st := Props.ramp(self, Vector3(x0, gy - 0.3, WALL_Z + 2.0 + run), Vector3(x0, WALK_Y, WALL_Z + 2.0), 2.2, Color.WHITE)
	Props.set_pattern(st, Color("b8a888"), "ashlar")


func _drop_stone() -> void:
	var t_h: float = player._ladder_t + 1.1
	_stone_falling = true
	hud.set_qte(tr("UI_QTE26O_STONE"))
	var top := ladder.point_at(ladder.height) + ladder.front_dir() * 0.5 + Vector3(0, 1.2, 0)
	var at := ladder.point_at(t_h) + ladder.front_dir() * 0.4
	var stone := Props.ball(self, 0.24, top, Color("8a8478"), Vector3(1.0, 0.8, 1.1), 8)
	Audio.sfx("whoosh_fly", -6.0, 0.7)
	var tw := stone.create_tween()
	tw.tween_property(stone, "global_position", at, 0.8).set_ease(Tween.EASE_IN)
	if tw.is_running():
		await tw.finished
	if is_instance_valid(stone) and player.ladder == ladder and absf(player._ladder_t - t_h) < 0.75:
		player.hurt(30.0, top)
	_stone_falling = false
	hud.set_qte("")
	if is_instance_valid(stone):
		var tw2 := stone.create_tween()
		tw2.tween_property(stone, "global_position", Vector3(at.x, 0.0, at.z - 1.0), 0.5).set_ease(Tween.EASE_IN)
		tw2.tween_callback(func():
			Vfx.dust(self, Vector3(at.x, 0.1, at.z - 1.0), 0.6)
			stone.queue_free())


# ---------------------------------------------------------------- 3. şafak, halat, kurtarma

func _dawn() -> void:
	phase = "dawn"
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH38O_DAWN"), 26, Color("f2e6c9")]], 1.6)
	hud.clear_card()
	_daylight(0.01, 0.55)
	# Uzakta batıda kara surlarının burçlarında sancaklar
	for k in 3:
		var p := Vector3(-160.0 - k * 22.0, 30.0 + k * 4.0, WALL_Z + 60.0 + k * 10.0)
		Props.cyl(self, 0.15, 7.0, p, Color("4a3420"), Vector3.ZERO, 5)
		Props.box(self, Vector3(0.1, 2.2, 3.6), p + Vector3(0, 2.6, 1.8), Color("b3262d"))
	# Fusta kapının önündeki rıhtıma yanaşır (sancak tarafı rıhtıma)
	galley.global_position = Vector3(GATE_X - 1.0, 0.0, QUAY.position.y - SeaBattle.GALLEY_RAIL_X - 0.5)
	galley.rotation = Vector3(0, -PI * 0.5, 0)
	_oars(false)          # yanaşınca kürekler içeri alınır (rıhtımın üstüne uzanmasın)
	_stand(Vector3(1.1, 0, 0.0))
	player.face(Vector3(-200.0, 30.0, WALL_Z + 60.0))
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_SAILOR2", "D38O_S2_02")
	await hud.say("SPK_NIHAT", "D38O_N_02")
	await hud.say("SPK_TOLGA", "D38O_T_03")
	# Surdakiler mazgalları bırakır, kapı açılır, tayfa karaya atlar
	for n in get_children():
		if (n is Person or n is WallGuard) and n.global_position.y > WALK_Y - 0.5:
			var tw := n.create_tween()
			tw.tween_property(n, "global_position:z", WALL_Z + 2.0, 1.2)
			tw.tween_callback(n.hide)
	var gt := create_tween().set_parallel()
	gt.tween_property(gate_l, "rotation:y", deg_to_rad(80.0), 1.4)
	gt.tween_property(gate_r, "rotation:y", deg_to_rad(-80.0), 1.4)
	Audio.sfx("door_open", -4.0, 0.7)
	await hud.say("SPK_SAILOR", "D38O_S_03")
	for r: Person in galley.get_meta("rowers", []):
		if is_instance_valid(r):
			var from := r.global_position
			r.reparent(self)
			var tw := r.create_tween()
			tw.tween_property(r, "global_position", Vector3(from.x, QUAY_Y + 0.6, QUAY.position.y + 0.8), 0.45).set_delay(randf_range(0.0, 1.2))
			tw.tween_property(r, "global_position:y", QUAY_Y, 0.15)
			tw.tween_property(r, "global_position", Vector3(GATE_X, QUAY_Y, WALL_Z), 2.0)
			tw.tween_callback(r.hide)
	galley.set_meta("rowers", [])
	await hud.say("SPK_PATROL", "D38O_R_04")


func _oars(out: bool) -> void:
	for o: Node3D in galley.get_meta("oars", []):
		o.visible = out


func _daylight(t: float, k: float) -> void:
	if env == null:
		return
	var sm := env.sky.sky_material as ProceduralSkyMaterial
	var tw := create_tween().set_parallel()
	tw.tween_property(sm, "sky_top_color", Color("0b1330").lerp(Color("4a86c8"), k), t)
	tw.tween_property(sm, "sky_horizon_color", Color("2a3560").lerp(Color("f0b080") if k < 0.9 else Color("c8dcec"), k), t)
	tw.tween_property(sm, "ground_horizon_color", Color("1c2238").lerp(Color("a89878"), k), t)
	tw.tween_property(env, "ambient_light_energy", lerpf(env.ambient_light_energy, 0.8, k), t)
	tw.tween_property(moon, "light_color", Color("fff4e0"), t)
	tw.tween_property(moon, "light_energy", lerpf(0.3, 1.2, k), t)
	tw.tween_property(moon, "rotation_degrees", Vector3(-10.0 - 38.0 * k, 120, 0), t)


## Halat: E basılı sarılır; gerilim kırmızıya girerken basılı tutulursa kopar (tekne sura vurur)
var _rope_hold := false
var _wraps := 0
var _rope: MeshInstance3D


func _rope_phase() -> void:
	phase = "rope"
	# Oyuncu rıhtıma atlar: babanın yanında, tekne arkasında (görüş açık)
	await hud.fade_to(1.0, 0.3)
	player.global_position = BOLLARD + Vector3(-1.5, 0.05, 0.9)
	player.face(BOLLARD + Vector3(0.0, 0.4, -1.0))
	await hud.fade_to(0.0, 0.3)
	player.frozen = true
	_rope = MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.025
	cm.bottom_radius = 0.025
	cm.height = 1.0
	_rope.mesh = cm
	_rope.material_override = Props.mat(Color("b89a6a"))
	add_child(_rope)
	# Tekneden babaya gergin halat (oyuncu elindeki ucu babaya sarar)
	var line := MeshInstance3D.new()
	line.mesh = cm
	line.material_override = _rope.material_override
	add_child(line)
	var deck_pt := galley.to_global(Vector3(1.6, DECK + 0.5, 0.0))
	var bt := BOLLARD + Vector3(0, 0.4, 0)
	line.global_transform = Transform3D(Basis(Quaternion(Vector3.UP, (bt - deck_pt).normalized())).scaled(Vector3(1, bt.distance_to(deck_pt), 1)), (bt + deck_pt) * 0.5)
	var t := 0.0
	var tension := 0.0
	var prog := 0.0
	while _wraps < 3 and t < 40.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		hud.set_objective(tr("UI_OBJ38O_ROPE") % _wraps, BOLLARD + Vector3(0, 1.0, 0))
		var hold := Input.is_action_pressed("interact")
		if GameState.autotest:
			hold = tension < 0.62
		var drift := 0.25 + 0.2 * sin(t * 1.7)
		if hold:
			tension += (0.35 + drift) * dt
			prog += dt / 2.2
		else:
			tension = maxf(0.0, tension - 0.6 * dt)
		hud.set_chase(tr("UI_CH38O_TENSION"), clampf(tension, 0.0, 1.0))
		hud.set_prompt(tr("UI_PROMPT38O_ROPE"))
		if tension >= 0.9 and hold:
			# Kopma: tekne sura vurur, küpeşte çatırdar
			snaps += 1
			tension = 0.0
			prog = 0.0
			Audio.sfx("wood_creak", -2.0, 0.6)
			Audio.sfx("land_thud", -2.0, 0.6)
			Fx.trauma(0.5)
			var tw := galley.create_tween()
			tw.tween_property(galley, "position:z", galley.position.z + 0.4, 0.2)
			tw.tween_property(galley, "position:z", galley.position.z, 0.6)
		if prog >= 1.0:
			prog = 0.0
			_wraps += 1
			Props.ring(self, 0.2, 0.25, BOLLARD + Vector3(0, 0.15 + _wraps * 0.12, 0), Color("b89a6a"), Vector3(90, 0, 0))
			Audio.sfx("cloth", -6.0, 0.8)
		# İp elden babaya: gergin olunca düz, gevşekken sarkık (iki parça)
		var hand := player.global_position + Vector3(0.3, 1.1, -0.3)
		var b := BOLLARD + Vector3(0, 0.4, 0)
		var d := b - hand
		var mid := (hand + b) * 0.5 - Vector3(0, (1.0 - clampf(tension, 0.0, 1.0)) * 0.25, 0)      # gevşekken sarkar
		_rope.global_transform = Transform3D(Basis(Quaternion(Vector3.UP, d.normalized())).scaled(Vector3(1, d.length(), 1)), mid)
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_objective("")
	_wraps = 3
	_rope.global_transform = Transform3D(Basis(Quaternion(Vector3.UP, (BOLLARD + Vector3(0, 0.4, 0) - galley.to_global(Vector3(1.6, DECK + 0.5, 0))).normalized())).scaled(
		Vector3(1, (BOLLARD + Vector3(0, 0.4, 0)).distance_to(galley.to_global(Vector3(1.6, DECK + 0.5, 0))), 1)),
		((BOLLARD + Vector3(0, 0.4, 0)) + galley.to_global(Vector3(1.6, DECK + 0.5, 0))) * 0.5)
	player.frozen = true


func _rescue() -> void:
	phase = "rescue"
	await hud.say("SPK_SAILOR2", "D38O_S2_FALL")
	# Suya düşen tayfa: tekne ile rıhtım arasında
	swimmer = Person.new({"coat": Color("6a5040"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true})
	swimmer.set_meta("no_talk", true)
	swimmer.set_meta("climber", true)
	add_child(swimmer)
	var water_at := Vector3(BOLLARD.x + 3.0, -1.0, QUAY.position.y - 0.25)
	# Oyuncu rıhtımın kenarında; tayfa küpeşteden suya düşer (görünür)
	player.global_position = Vector3(water_at.x - 0.6, QUAY_Y + 0.05, QUAY.position.y + 0.9)
	player.face(water_at + Vector3(0, 0.4, 0))
	player.frozen = true
	var rail := galley.to_global(Vector3(1.4, DECK + 0.6, 0.0))
	rail.x = water_at.x
	swimmer.global_position = rail
	swimmer.set_activity("stand")
	var ftw := swimmer.create_tween()
	ftw.tween_property(swimmer, "global_position", rail + Vector3(0, 0.6, 0.2), 0.25).set_ease(Tween.EASE_OUT)
	ftw.tween_property(swimmer, "global_position", water_at, 0.45).set_ease(Tween.EASE_IN)
	await ftw.finished
	swimmer.set_activity("swim")
	Audio.sfx("splash", -2.0, 0.9)
	Vfx.dust(self, water_at + Vector3(0, 1.0, 0), 0.6)
	var t := 0.0
	var prog := 0.0
	var bump := 5.0
	var lose := GameState.autotest_variant == "lose"
	hud.set_objective(tr("UI_OBJ38O_PULL"), water_at + Vector3(0, 1.0, 0))
	while prog < 1.0 and t < 30.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		bump -= dt
		var warn := bump < 0.8
		var hold := Input.is_action_pressed("interact")
		if GameState.autotest:
			hold = not lose and not warn
		hud.set_prompt(tr("UI_PROMPT38O_HAND"))
		hud.set_qte(tr("UI_QTE38O_BUMP") if warn else "")
		if hold:
			prog = minf(1.0, prog + dt / 5.0)
		swimmer.global_position = water_at + Vector3(0, prog * 1.6 + sin(t * 3.0) * 0.08, 0)
		hud.set_chase(tr("UI_CH38O_PULL"), prog)
		if bump <= 0.0:
			bump = 5.0
			# Tekne rıhtıma vurur: gıcırtı, toz, sarsıntı; o an tutuyorsan el kayar
			Audio.sfx("wood_creak", -2.0, 0.5)
			Fx.trauma(0.4)
			Vfx.dust(self, Vector3(water_at.x, QUAY_Y, QUAY.position.y), 0.6)
			var tw := galley.create_tween()
			tw.tween_property(galley, "position:z", galley.position.z + 0.3, 0.15)
			tw.tween_property(galley, "position:z", galley.position.z, 0.5)
			if hold:
				prog *= 0.5
				Audio.sfx("splash", -6.0, 1.2)
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_qte("")
	hud.set_objective("")
	tolga_pulled = prog >= 1.0
	if tolga_pulled:
		await hud.say("SPK_TOLGA", "D38O_T_PULL")
	else:
		await hud.say("SPK_SAILOR2", "D38O_S2_HOOK")
	# Rıhtıma çıkarılır, oturur
	swimmer.global_position = Vector3(water_at.x + 0.8, QUAY_Y, QUAY.position.y + 1.0)
	swimmer.set_activity("sit")
	await hud.say("SPK_SAILOR", "D38O_S_SAVED")


func _petrion() -> void:
	phase = "petrion"
	# Petrion'un ihtiyarları kapının ardından rıhtıma iner, ellerinde anahtar
	for k in 3:
		var e := Person.new({"coat": [Color("4a4a58"), Color("5a4a3a"), Color("3a3a48")][k], "pants": Color("2a2a30"), "beard": true,
			"hair": Color("c8c8c0"), "robe": Color("3a3a40"), "skin": Color("d8b090")})
		e.set_meta("spk", "SPK_TOWNSMAN")
		add_child(e)
		e.global_position = Vector3(GATE_X - 1.0 + k * 1.0, QUAY_Y, WALL_Z + 1.0)
		var tw := e.create_tween()
		tw.tween_property(e, "global_position", Vector3(GATE_X - 1.4 + k * 1.2, QUAY_Y, QUAY.position.y + 1.0), 2.4)
		e.look_target = player
		elders.append(e)
	Props.cyl(elders[1], 0.02, 0.2, Vector3(0.3, 1.1, 0.25), Color("c8a040"), Vector3(0, 0, 90), 5)       # anahtar
	await get_tree().create_timer(2.4 if not GameState.autotest else 0.9).timeout
	player.face(elders[1].global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_TOWNSMAN", "D38O_TW_01")
	await hud.say("SPK_PATROL", "D38O_R_05")
	var pick := await hud.choose(["UI_C38O_EXACT", "UI_C38O_ADD"], 0.0, 0)
	petrion_word = "exact" if pick == 0 else "add"
	GameState.flags["petrion_word"] = petrion_word
	await hud.say("SPK_TOLGA", "D38O_T_TR" if pick == 0 else "D38O_T_TR_ADD")
	await hud.say("SPK_PATROL", "D38O_R_06")


# ---------------------------------------------------------------- 4. kovalamaca

func _chase() -> void:
	phase = "chase"
	_oars(true)
	await hud.fade_to(1.0, 0.6)
	await hud.card([[tr("UI_CH38O_NOON"), 26, Color("f2e6c9")]], 1.4)
	hud.clear_card()
	_daylight(0.01, 1.0)
	for e in elders:
		e.queue_free()
	if is_instance_valid(_rope):
		_rope.queue_free()
	if is_instance_valid(swimmer):
		swimmer.queue_free()
	galley.global_position = Vector3(20.0, 0.0, 30.0)
	galley.rotation = Vector3(0, -PI * 0.5, 0)        # pruva doğuya (+x)
	for s in ships:
		s.visible = true
		SeaBattle.fill_sails(s, 1.0)
	player.pinned = true
	_seat()
	player.face(ships[0].global_position + Vector3(0, 6, 0))
	await hud.fade_to(0.0, 0.6)
	await hud.say("SPK_SAILOR2", "D38O_S2_03")
	await hud.say("SPK_PATROL", "D38O_R_07")
	_strokes.clear()
	meter.enabled = true
	player.frozen = false
	hud.set_objective(tr("UI_OBJ38O_CHASE"), ships[1].global_position + Vector3(0, 8, 0))
	var target := Node3D.new()
	ships[1].add_child(target)
	target.position = Vector3(0, 6.0, 0)
	cam = TespitCam.new(player, hud, target, "siege38o")
	hud.add_child(cam)
	cam.max_dist = 160.0
	cam.cone_deg = 14.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	hud.bark("SPK_NIHAT", "D38O_N_PHOTO", 5.0)
	var t := 0.0
	var gun_t := 6.0
	var ring_t := -1.0
	var ring_side := 0
	var ring: Node3D
	var lose := GameState.autotest_variant == "lose"
	var dodges := 0
	var shots := 0
	var lane := 0.0
	while t < 42.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if Input.is_action_just_pressed("jump"):
			meter.press()
		while _strokes.size() > 0:
			if _strokes.pop_front():
				beats_good += 1
		var speed := 3.0 + 3.0 * meter.speed_factor()
		galley.global_position.x += speed * dt
		galley.global_position.z = lerpf(galley.global_position.z, 30.0 + lane, dt * 2.0)
		for i in ships.size():
			ships[i].global_position.x += (8.5 if i < 2 else 7.5) * dt
		SeaBattle.row_oars(galley, meter.phase, true)
		_seat()
		if GameState.autotest and not cam.done and t > 4.0:
			player.face(target.global_position)
		# Kıç topu: ağız alevi, 2 sn sonra suda halka (sol ya da sağ); A/D ile reise yön söyle
		gun_t -= dt
		if gun_t <= 0.0 and ring_t < 0.0 and shots < 4:
			gun_t = randf_range(7.0, 9.0)
			shots += 1
			var muzzle := ships[1].to_global(Vector3(0, SeaBattle.CARRACK_DECK + 1.0, 9.0))
			Vfx.gun_blast(self, muzzle, 1.0)
			Audio.sfx("cannon", -6.0, 1.1)
			ring_side = -1 if randf() < 0.5 else 1
			ring_t = 0.0
			ring = Props.ring(self, 1.2, 1.6, galley.global_position + Vector3(6.0, 0.05, ring_side * 2.2), Color("f4f1ea"), Vector3.ZERO)
			hud.set_qte(tr("UI_OBJ38O_SPLASH"))
		if ring_t >= 0.0:
			ring_t += dt
			if is_instance_valid(ring):
				ring.global_position = galley.global_position + Vector3(6.0, 0.05, ring_side * 2.2)
				ring.scale = Vector3.ONE * (1.0 + ring_t * 0.4)
			var choice := 0
			if Input.is_action_just_pressed("move_left"):
				choice = 1        # sola kır: halkadan uzaklaş (halka sağdaysa doğru)
			elif Input.is_action_just_pressed("move_right"):
				choice = -1
			if GameState.autotest and ring_t > 0.6 and not lose:
				choice = -ring_side
			if choice != 0 and ring_t < 2.0 and lane == 0.0:
				lane = choice * 4.0
				hud.bark("SPK_PATROL", "D38O_R_LEFT" if choice > 0 else "D38O_R_RIGHT", 1.6)
			if ring_t >= 2.0:
				# Su sütunu
				var hit := (lane == 0.0) or signf(lane) == float(ring_side)
				var at := galley.global_position + Vector3(6.0, 0.0, ring_side * 2.2)
				Vfx.explosion(self, at + Vector3(0, 1.5, 0), 0.8)
				Vfx.dust(self, at + Vector3(0, 0.5, 0), 2.0)
				Audio.sfx("splash", 0.0, 0.6)
				if hit:
					splashes += 1
					player.hurt(15.0, at)
					Fx.trauma(0.5)
					hud.bark("SPK_SAILOR", "D38O_S_SPLASH", 2.0)
				else:
					dodges += 1
				if is_instance_valid(ring):
					ring.queue_free()
				ring_t = -1.0
				lane = 0.0
				hud.set_qte("")
	meter.enabled = false
	cam.stop()
	hud.set_qte("")
	hud.set_objective("")
	player.frozen = true
	if _photo.is_empty() and GameState.autotest:
		_photo = ""


func _end_text() -> void:
	await hud.say("SPK_NIHAT", "D38O_N_BOOM")
	await hud.say("SPK_NIHAT", "D38O_N_CRETE")
	await hud.say("SPK_PATROL", "D38O_R_END")
	await hud.say("SPK_TOLGA", "D38O_T_END")
	await hud.say("SPK_NIHAT", "D38O_N_END")
	var ok := forks_braced >= 2 and fire_ok and tolga_pulled
	_outcome = "38O.1" if ok else "38O.2"
	Siege.record(38, _photo, "SIEGE_NOTE_38O_%s" % _outcome.split(".")[1])


func _on_focus(id: String) -> void:
	var k := ""
	match id:
		"sand":
			if phase == "ladder" and _fire_t >= 0.0 and not _has_sand:
				k = "UI_PROMPT38O_SAND"
	if phase == "ladder" and _has_sand:
		k = "UI_PROMPT38O_THROW"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	match id:
		"sand":
			if phase == "ladder" and _fire_t >= 0.0 and not _has_sand:
				_has_sand = true
				_carry = Node3D.new()
				_carry.position = Vector3(0.35, -0.55, -0.8)
				player.camera.add_child(_carry)
				Props.cyl(_carry, 0.17, 0.3, Vector3.ZERO, Color("6a4a2c"), Vector3.ZERO, 10, 0.85)
				Props.cyl(_carry, 0.15, 0.02, Vector3(0, 0.14, 0), Color("d8c08a"), Vector3.ZERO, 10)
				Props.strip_outlines(_carry)
				return
	if phase == "ladder" and _has_sand:
		_throw_sand()


func _process(delta: float) -> void:
	_t += delta
	if phase == "ladder" and _has_sand and Input.is_action_just_pressed("interact"):
		_throw_sand()


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	player.pinned = false
	GameState.set_outcome(38, _outcome)
	await Siege.show_page(hud, 38)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(38)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW38O_TITLE")
	c.nodes = [
		{"id": "row", "key": "FLOW38O_ROW", "pos": Vector2(0.5, 0.1)},
		{"id": "ladder", "key": "FLOW38O_LADDER", "pos": Vector2(0.5, 0.22)},
		{"id": "news", "key": "FLOW38O_NEWS", "pos": Vector2(0.5, 0.34)},
		{"id": "petrion", "key": "FLOW38O_PETRION", "pos": Vector2(0.5, 0.46)},
		{"id": "chase", "key": "FLOW38O_CHASE", "pos": Vector2(0.5, 0.58)},
		{"id": "38O.1", "key": "FLOW_38O_1", "pos": Vector2(0.3, 0.72), "outcome": true},
		{"id": "38O.2", "key": "FLOW_38O_2", "pos": Vector2(0.7, 0.72), "outcome": true},
	]
	c.edges = [["row", "ladder"], ["ladder", "news"], ["news", "petrion"], ["petrion", "chase"], ["chase", "38O.1"], ["chase", "38O.2"]]
	for k in ["row", "ladder", "news", "petrion", "chase"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		Grade.finish("38o"),
		tr("UI_CH38O_STATS") % [beats_good, ROW_BEATS, forks_braced, 1 if oil_hit else 0, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "38O.1", "lose": "38O.2"}.get(v, "38O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("38", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and forks == 3 and _wraps == 3
	ok = ok and GameState.flags.get("petrion_word", "") == "exact"
	if v == "":
		ok = ok and explored > 4.0
		ok = ok and beats_good >= 10 and arrows == 0 and forks_braced == 3 and fire_ok and tolga_pulled and not oil_hit and cam.done
	else:
		ok = ok and forks_braced == 0 and not fire_ok and not tolga_pulled
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s kürek=%d ok=%d çatal=%d/%d ateş=%s çekti=%s yağ=%s sarım=%d foto=%s)" % [expected, _outcome,
			not page.is_empty(), beats_good, arrows, forks_braced, forks, fire_ok, tolga_pulled, oil_hit, _wraps, cam != null and cam.done])
	print("AUTOTEST %s chapter=38o variant=%s outcome=%s oars=%d arrows=%d forks=%d/%d fire=%s pulled=%s oil=%s snaps=%d splashes=%d explored=%.1f" % [
		"PASS" if ok else "FAIL", v, _outcome, beats_good, arrows, forks_braced, forks, fire_ok, tolga_pulled, oil_hit, snaps, splashes, explored])
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
	# Kürek: gece, sur ve mazgallar
	galley.position = ROW_FROM.lerp(ROW_TO, 0.6)
	player.pinned = true
	_seat()
	player.face(Vector3(-6.0, 7.0, WALL_Z))
	SeaBattle.row_oars(galley, 0.3, true)
	meter.enabled = true
	await get_tree().create_timer(0.8).timeout
	await _shot_png("c38o_01_row.png")
	meter.enabled = false
	# Merdiven pruvadan sura
	galley.position = ROW_TO
	var foot := galley.to_global(Vector3(0, DECK, -9.4))
	var top := Vector3(foot.x, WALK_Y + 0.4, WALL_Z - 2.3)
	ladder = Ladder.new((top - foot).length(), rad_to_deg(atan2((top - foot).z, (top - foot).y)), Color("6a4a2c"))
	ladder.position = foot
	ladder.rotation.y = PI
	add_child(ladder)
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(-16.0, 4.0, 40.0)
	cv.look_at(Vector3(-5.0, 4.5, 58.0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await get_tree().create_timer(0.5).timeout
	await _shot_png("c38o_cover.png")
	# Öğle: kaçan gemiler
	_daylight(0.01, 1.0)
	for s in ships:
		s.visible = true
		SeaBattle.fill_sails(s, 1.0)
	cv.global_position = Vector3(30.0, 4.0, 26.0)
	cv.look_at(Vector3(80.0, 6.0, 32.0), Vector3.UP)
	await get_tree().create_timer(0.5).timeout
	await _shot_png("c38o_02_chase.png")
	# Surun üstünden şehre (içeri) bakış
	cv.global_position = Vector3(-6.0, WALK_Y + 1.7, WALL_Z - 0.5)
	cv.look_at(Vector3(-6.0, 4.0, WALL_Z + 60.0), Vector3.UP)
	await get_tree().create_timer(0.5).timeout
	await _shot_png("c38o_03_city.png")
	get_tree().quit()
