extends Node3D
## Bölüm 33 (yalnız Osmanlı tarafı) — Boğazkesen (Tolga · 31 Ağustos ve 26 Kasım 1452). docs/OTTOMAN_NEW_A.md §1.
##
##   1a. İskele: merdivenle 2. kata; ikinci merdiven önde tırmanan işçinin altında kırılır, dikme demetinden serbest
##       tırmanış (yukarıdan kova ve keser düşer: önce kırmızı halka). Tepede çatırdayan kalaslar (1,5 sn'de düşer).
##   1b. Çıkrık: dört taş; taş yükselirken salınır, kılavuz ipiyle (A/D) tut, yeşilde E: "İndir!". Kırmızıda
##       indirilen taş duvara çarpar; üç çarpışta kıskaç açılır. Bora. Ezana kadar 4 dk.
##   2.  Gümrük (Kasım): akıntıya karşı kürek (RowMeter; kayalar), bordada ip merdiven (yalpada dur, yoksa suya),
##       ambarda beşinci kalem (saklı arbalet okları), hediye seçimi.
##   3.  Uyarı atışı: Rizzo'nun gemisinin burnunun önündeki halkaya küçük topla (75 sn).
##   4.  Büyük top: tokmak, öne nişan; ateşten önce topun arkasından çekil. Tespit: yatan direk ve kule.
##   5.  Kıyı: sandal rıhtıma çıkar; kapanış.
##   33O.1 uyarı yerinde ve büyük top isabet · 33O.2 aksi
##   --autotest[=wide|fall]   (varsayılan 33O.1)

const STONES := 4
const CRANE_TIME := 240.0
const ROW_TIME := 60.0
const HOLD_TIME := 40.0
const WARN_TIME := 75.0
const SHIP_Z := 170.0
const SHIP_SPEED := 5.0
const GENOA := Vector3(-70.0, 0.0, 120.0)

var level: Bogaz
var player: Player
var hud: Hud
var meter: RowMeter
var balance: BalanceMeter
var drill: GunDrill
var crew: CannonCrew
var cam: TespitCam
var phase := "intro"
var _outcome := ""
var _photo := ""
var _strokes: Array = []

var mason: Person
var firuz: Person
var urban: Person
var genoese: Person
var climber: Person

# skor
var scaffold_falls := 0
var stones_set := 0
var crane_hits := 0
var water_falls := 0
var hidden_found := false
var gift := ""
var warn := "miss"
var big := false
var _acc := 0.0


func _ready() -> void:
	GameState.snapshot(33)
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
	balance.visible = false
	hud.add_child(balance)
	balance.place_bottom()
	drill = GunDrill.new()
	hud.add_child(drill)
	drill.fired.connect(func(a: float): _acc = a)
	level = Bogaz.new()
	add_child(level)
	_build_people()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _variant() -> String:
	return GameState.autotest_variant if GameState.autotest else ""


func _build_people() -> void:
	mason = Person.new({"coat": Color("8a7a60"), "pants": Color("e8e0d0"), "hat": "turban", "beard": true, "hair": Color("b8b4a8"), "skin": Color("c89070")})
	mason.set_meta("spk", "SPK_MASON")
	add_child(mason)
	mason.position = Vector3(-6.0, Bogaz.QUAY_Y, -10.0)
	mason.look_target = player
	climber = Person.new({"coat": Color("6a5040"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")})
	climber.set_meta("no_talk", true)
	climber.set_meta("climber", true)
	add_child(climber)
	climber.position = Vector3(-6.5, Bogaz.DECK2_Y, -19.6)   # merdiven düzleminin (z -20.4) önünde, içinde değil
	climber.rotation.y = PI
	# Çıkrığı çeviren iki işçi (rıhtımda)
	for sx: float in [-1.0, 1.0]:
		var w := Person.new({"coat": Color("7a6a50"), "pants": Color("e8e0d0"), "hat": "turban", "mustache": true, "skin": Color("c89070")})
		w.set_meta("no_talk", true)
		add_child(w)
		w.position = Bogaz.DRUM + Vector3(sx * 1.6, 0, 0.0)
		w.rotation.y = -sx * PI * 0.5
		_turners.append(w)
	# Kule tepesinde iki usta (harç, tokmak)
	for k in 2:
		var u := Person.new({"coat": Color("8a6a4a"), "pants": Color("e8e0d0"), "hat": "turban", "beard": k == 0, "skin": Color("c89070")})
		u.set_meta("no_talk", true)
		add_child(u)
		u.position = Bogaz.TOWER + Vector3(-3.0 + k * 6.0, Bogaz.TOP_Y, Bogaz.TOWER_R - 2.6)
		u.rotation.y = 0.0
		u.set_activity("hammer")
		_masons_top.append(u)


var _turners: Array[Person] = []
var _masons_top: Array[Person] = []


func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH33O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH33O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = Vector3(-6.5, Bogaz.QUAY_Y + 0.05, -6.0)
	player.face(mason.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D33O_N_01")
	await hud.say("SPK_TOLGA", "D33O_T_01")
	await hud.say("SPK_MASON", "D33O_M_01")
	await hud.say("SPK_TOLGA", "D33O_T_02")
	await hud.say("SPK_MASON", "D33O_M_02")
	Lore.scatter(self, "33o", [Vector3(-14.0, Bogaz.QUAY_Y + 0.3, -9.0), Vector3(-9.0, Bogaz.DECK2_Y + 0.3, -21.0), Vector3(14.0, Bogaz.QUAY_Y + 0.3, -3.0)])
	await _scaffold()
	await _crane()
	await _toll()
	await _warn_shot()
	await _big_gun()
	await _coast()
	await _end_chapter()


# ================================================================ 1a. iskele

var _plank_t: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var _plank_gone: Array = [false, false, false, false, false, false]


func _scaffold() -> void:
	phase = "scaffold"
	player.frozen = false
	hud.set_objective(tr("UI_OBJ33O_CLIMB"), Bogaz.ARM_PIVOT)
	var stage := "ladder"
	var drop_t := 7.0
	var t := 0.0
	var bot_t := 0.0
	var fall_wait := _variant() == "fall"
	while true:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var p := player.global_position
		match stage:
			"ladder":
				if p.y > Bogaz.DECK2_Y - 0.3 and p.z < -19.0:
					stage = "break"
					# Önde tırmanan işçinin altında ikinci merdiven kırılır
					player.frozen = true
					var lt := climber.create_tween()
					# Merdiven boyunca (geriye yatık: her metrede ~0.1 m -z) basamak basamak tırmanır
					for i in 3:
						lt.tween_callback(climber.set_activity.bind("climb_a" if i % 2 == 0 else "climb_b"))
						lt.tween_property(climber, "position", Vector3(-6.5, Bogaz.DECK2_Y + 1.0 * (i + 1), -19.6 - 0.1 * (i + 1)), 0.4)
					await lt.finished
					_break_ladder()
					hud.bark("SPK_SOLDIER", "D33O_S_LADDER", 3.0)
					climber.set_activity("climb_a")
					var ct := climber.create_tween()
					ct.tween_property(climber, "position", Vector3(-2.0, Bogaz.DECK2_Y + 3.0, -20.2), 1.0)
					ct.tween_property(climber, "position:y", Bogaz.DECK2_Y, 0.6)
					ct.tween_callback(func(): climber.set_activity(""))
					await get_tree().create_timer(0.8).timeout
					hud.bark("SPK_TOLGA", "D33O_T_CLIMB", 3.0)
					player.enable_climb([Rect2(Bogaz.CLIMB_X - 1.4, -24.5, 2.8, 2.6)])
					player.frozen = false
					stage = "climb"
				if GameState.autotest:
					bot_t += dt
					if bot_t > 0.8:
						player.global_position = Vector3(-4.0, Bogaz.DECK2_Y + 0.05, -21.0)
			"climb":
				hud.set_objective(tr("UI_OBJ33O_CLIMB"), Vector3(Bogaz.CLIMB_X, Bogaz.WALK_Y + 1.0, Bogaz.WALK_Z))
				# Yukarıdan kova / keser
				drop_t -= dt
				if drop_t <= 0.0:
					drop_t = randf_range(6.0, 9.0)
					_drop_tool(p)
				if p.y > Bogaz.WALK_Y - 0.25:
					stage = "walk"
					player.disable_climb()
				if GameState.autotest:
					bot_t += dt
					if bot_t > 2.0:
						player.global_position = Vector3(Bogaz.WALK_X0 + 1.0, Bogaz.WALK_Y + 0.1, Bogaz.WALK_Z)
			"walk":
				hud.set_objective(tr("UI_OBJ33O_CLIMB"), Bogaz.ARM_PIVOT + Vector3(0, -2.0, 0))
				# Çatırdayan kalaslar: basılan kalas 1,5 sn sonra düşer
				var on := -1
				for i in 6:
					if _plank_gone[i]:
						continue
					var pl: Node3D = level.planks[i]
					if absf(p.x - pl.global_position.x) < 1.0 and absf(p.z - pl.global_position.z) < 0.9 and absf(p.y - Bogaz.WALK_Y) < 0.5:
						on = i
				if on >= 0:
					if _plank_t[on] == 0.0:
						hud.set_qte(tr("UI_HINT33O_PLANK"))
						hud.bark("SPK_TOLGA", "D33O_T_PLANK", 2.0)
						Audio.sfx("wood_creak", -4.0, 1.0)
						level.planks[on].position.y -= 0.02
						Vfx.dust(self, level.planks[on].global_position, 0.2)
					_plank_t[on] += dt
					if _plank_t[on] > 1.5:
						_drop_plank(on)
				else:
					hud.set_qte("")
				if p.y < Bogaz.WALK_Y - 1.5:
					# Düştü: 2. kata, yeniden tırmanış
					scaffold_falls += 1
					hud.set_qte("")
					player.hurt(15.0, Vector3.INF, true)
					hud.bark("SPK_MASON", "D33O_M_FALL", 3.0)
					_reset_planks()
					player.global_position = Vector3(-6.0, Bogaz.DECK2_Y + 0.1, -21.0)
					player.enable_climb([Rect2(Bogaz.CLIMB_X - 1.4, -24.5, 2.8, 2.6)])
					stage = "climb"
					bot_t = 0.0
					fall_wait = false
					continue
				if p.distance_to(Bogaz.ARM_PIVOT) < 5.5 and p.y > Bogaz.TOP_Y - 0.3:
					break
				if GameState.autotest:
					if fall_wait:
						pass             # =fall: kalasın üstünde bekler, düşer
					else:
						player.global_position = player.global_position.move_toward(Vector3(1.6, Bogaz.WALK_Y + 0.1, Bogaz.WALK_Z), dt * 4.5)
						if player.global_position.x > 1.4:
							player.global_position = Vector3(0.6, Bogaz.TOP_Y + 0.1, -25.0)
		if t > 240.0:
			player.global_position = Vector3(0.6, Bogaz.TOP_Y + 0.1, -25.0)
			break
	hud.set_qte("")
	hud.set_objective("")
	player.disable_climb()
	player.frozen = true


func _break_ladder() -> void:
	Audio.sfx("wood_creak", 0.0, 0.6)
	Audio.sfx("land_thud", -4.0, 1.2)
	var lad: Node3D = level.ladder2
	var parts := lad.get_children()
	for i in parts.size():
		var c := parts[i] as Node3D
		if i < 2 or i % 3 == 0:
			var tw := c.create_tween()
			tw.tween_property(c, "position", c.position + Vector3(randf_range(-1.0, 1.0), -Bogaz.DECK2_Y + 0.4 - c.position.y * 0.5, randf_range(0.5, 2.0)), 0.8).set_ease(Tween.EASE_IN)
			tw.parallel().tween_property(c, "rotation", Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5)), 0.8)
		else:
			c.visible = false
	Vfx.dust(self, lad.global_position + Vector3(0, 3.0, 0), 0.8)


## Yukarıdan kova ya da keser: 1,2 sn önce kırmızı halka ve uyarı; isabet −20 can, tutunma bırakılır
func _drop_tool(at: Vector3) -> void:
	hud.set_qte(tr("UI_HINT33O_ABOVE"))
	hud.bark("SPK_SOLDIER", "D33O_S_ABOVE", 1.6)
	var target := Vector3(at.x, at.y, at.z)
	var ring := Props.ring(self, 0.45, 0.6, target + Vector3(0, 0.05, 0.4), Color("ff3020"), Vector3(90, 0, 0), 1.0)
	var bucket := Node3D.new()
	add_child(bucket)
	bucket.position = target + Vector3(0, 8.0, 0.4)
	Props.cyl(bucket, 0.18, 0.3, Vector3.ZERO, Color("6a4a2c"), Vector3.ZERO, 8, 0.22)
	Props.cyl(bucket, 0.17, 0.02, Vector3(0, 0.15, 0), Color("a8a49a"), Vector3.ZERO, 8)
	await get_tree().create_timer(1.2).timeout
	var tw := bucket.create_tween()
	tw.tween_property(bucket, "position:y", target.y - 0.3, 0.6).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(bucket, "rotation:x", TAU, 0.6)
	await tw.finished
	if is_instance_valid(ring):
		ring.queue_free()
	hud.set_qte("")
	var p := player.global_position
	var dodge := 1.0 if not GameState.autotest else 0.0
	if Vector2(p.x - target.x, p.y - target.y).length() < 0.8 * dodge and phase == "scaffold":
		player.hurt(20.0, target + Vector3(0, 4, 0))
		Fx.trauma(0.4)
		player.global_position = Vector3(-6.0, Bogaz.DECK2_Y + 0.1, -21.0)
	Vfx.dust(self, bucket.global_position, 0.4)
	Audio.sfx("land_pot", -6.0, 1.0)
	var bt := bucket.create_tween()
	bt.tween_property(bucket, "position:y", Bogaz.QUAY_Y + 0.2, 0.5)
	bt.tween_interval(4.0)
	bt.tween_callback(bucket.queue_free)


func _drop_plank(i: int) -> void:
	_plank_gone[i] = true
	var pl: Node3D = level.planks[i]
	for c in pl.get_children():
		if c is StaticBody3D:
			(c as StaticBody3D).collision_layer = 0
	Audio.sfx("wood_creak", -2.0, 0.6)
	var tw := pl.create_tween()
	tw.tween_property(pl, "position:y", Bogaz.QUAY_Y + 0.1, 1.0).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(pl, "rotation:z", randf_range(-1.2, 1.2), 1.0)
	tw.tween_callback(func(): Vfx.dust(self, pl.global_position, 0.6))


func _reset_planks() -> void:
	for i in 6:
		_plank_t[i] = 0.0
		if _plank_gone[i]:
			# Ustalar yeni kalas çaktı
			_plank_gone[i] = false
			var pl: Node3D = level.planks[i]
			pl.position.y = Bogaz.WALK_Y - 0.08
			pl.rotation = Vector3.ZERO
			for c in pl.get_children():
				if c is StaticBody3D:
					(c as StaticBody3D).collision_layer = 1
		else:
			level.planks[i].position.y = Bogaz.WALK_Y - 0.08


# ================================================================ 1b. çıkrık

var _stone: Node3D
var _rope: MeshInstance3D
var _guide: MeshInstance3D
var _lower_req := false


func _crane() -> void:
	phase = "crane"
	hud.bark("SPK_ZAGANOS", "D33O_Z_01", 4.0)
	player.global_position = Vector3(0.0, Bogaz.TOP_Y + 0.1, -25.6)
	player.face(Bogaz.ARM_TIP + Vector3(0, -6.0, 0))
	_rope = Bogaz.make_rope(self)
	_guide = Bogaz.make_rope(self, Color("c8a878"), 0.02)
	var left := CRANE_TIME
	var theta := 0.0
	var omega := 0.0
	var lift := 0.0
	var hits_this := 0
	var gusts := [70.0, 160.0]
	var gust_warn := -1.0
	var gust := 0.0
	var drop_once := _variant() == "fall"
	var bark_wind := false
	_new_stone()
	player.frozen = true
	await get_tree().create_timer(0.4).timeout
	hud.bark("SPK_HALIL", "D33O_H_01", 4.0)
	while stones_set < STONES and left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		var elapsed := CRANE_TIME - left
		hud.set_objective(tr("UI_OBJ33O_CRANE") % [stones_set, STONES])
		# Tambur: işçiler kolu çevirir, taş yükselir
		if lift < 1.0:
			lift = minf(lift + dt / 6.0, 1.0)
			var drum := level.get_node("Drum") as Node3D
			drum.rotation.x += dt * 2.0
			for w in _turners:
				if w.rig:
					w.rig.lock = 1
					w.rig.arm_r.rotation = Vector3(-1.2 + sin(elapsed * 4.0) * 0.6, 0, 0.2)
					w.rig.arm_l.rotation = Vector3(-1.2 + cos(elapsed * 4.0) * 0.6, 0, -0.2)
		# Bora: 1 sn önce uyarı
		if gusts.size() > 0 and elapsed > float(gusts[0]) - 1.0 and gust_warn < 0.0:
			gust_warn = 1.0
			hud.set_qte(tr("UI_HINT33O_GUST"))
		if gust_warn > 0.0:
			gust_warn -= dt
			if gust_warn <= 0.0:
				gusts.pop_front()
				gust = 1.0
				gust_warn = -1.0
				hud.set_qte("")
				if not bark_wind:
					bark_wind = true
					hud.bark("SPK_TOLGA", "D33O_T_WIND", 2.5)
		gust = maxf(0.0, gust - dt * 0.8)
		# Sarkaç: rüzgâr iter (3–5 sn'de bir), kılavuz ipi (A/D) çeker ya da salar
		var input := Input.get_axis("move_left", "move_right")
		if GameState.autotest:
			input = clampf(-theta * 3.0 - omega * 1.2, -1.0, 1.0)
		var wind := sin(elapsed * 1.7) * 0.35 + sin(elapsed * 0.53) * 0.25 + gust * 2.4
		omega += (-theta * 3.2 + wind * 0.8 + input * 1.8 - omega * 0.25) * dt
		theta += omega * dt
		theta = clampf(theta, -1.2, 1.2)
		balance.visible = true
		balance.label_text = tr("UI_OBJ33O_CRANE") % [stones_set, STONES]
		balance.value = theta / 0.9
		var hang := Bogaz.ARM_TIP + Vector3(sin(theta) * 4.0, -lerpf(Bogaz.ARM_TIP.y - Bogaz.QUAY_Y - 1.2, 3.6, lift), 0)
		_stone.global_position = hang
		_stone.rotation.z = theta * 0.6
		Bogaz.rope(_rope, Bogaz.ARM_TIP, hang + Vector3(0, 0.45, 0))
		Bogaz.rope(_guide, hang + Vector3(0, 0.1, -0.3), player.global_position + Vector3(0.3, 1.2, 0.3))
		var ok := absf(theta) < 0.22
		hud.set_prompt(tr("UI_PROMPT33O_LOWER") if lift >= 1.0 else "")
		if lift >= 1.0 and (_lower_req or (GameState.autotest and (ok or (drop_once and crane_hits == 0 and absf(theta) > 0.3)))):
			_lower_req = false
			if ok and not (drop_once and crane_hits == 0):
				await _set_stone()
				stones_set += 1
				hud.bark("SPK_MASON", "D33O_M_STONE_1" if stones_set == 1 else "D33O_M_STONE_1", 2.5)
				if stones_set == 2:
					hud.bark("SPK_TOLGA", "D33O_T_STONE", 3.0)
				hits_this = 0
				if stones_set < STONES:
					_new_stone()
					lift = 0.0
					theta = 0.0
					omega = 0.0
			else:
				crane_hits += 1
				hits_this += 1
				drop_once = false
				left -= 6.0
				omega -= signf(theta) * 2.0
				Audio.sfx("land_thud", -2.0, 1.1)
				Fx.trauma(0.3)
				Vfx.dust(self, _stone.global_position, 0.6)
				for k in 3:
					var ch := Props.box(self, Vector3(0.2, 0.15, 0.2), _stone.global_position, Bogaz.C_STONE)
					var ct := ch.create_tween()
					ct.tween_property(ch, "position", ch.position + Vector3(randf_range(-2, 2), -12.0, randf_range(-1, 2)), 1.2).set_ease(Tween.EASE_IN)
					ct.tween_callback(ch.queue_free)
				hud.bark("SPK_MASON", "D33O_M_STONE_BAD", 2.5)
				if hits_this >= 3:
					# Kıskaç açılır: taş düşer, yeni taş
					hud.bark("SPK_MASON", "D33O_M_DROP", 3.0)
					var st := _stone
					var ft := st.create_tween()
					ft.tween_property(st, "global_position:y", Bogaz.QUAY_Y + 0.4, 1.0).set_ease(Tween.EASE_IN)
					ft.tween_callback(func(): Vfx.dust(self, st.global_position, 1.0))
					left -= 15.0
					hits_this = 0
					_new_stone()
					lift = 0.0
					theta = 0.0
					omega = 0.0
	balance.visible = false
	hud.set_qte("")
	hud.set_prompt("")
	hud.set_objective("")
	for w in _turners:
		if w.rig:
			w.rig.lock = 0
	if is_instance_valid(_stone) and stones_set < STONES:
		_stone.queue_free()
	_rope.visible = false
	_guide.visible = false
	await hud.say("SPK_MASON", "D33O_M_DONE" if stones_set >= STONES else "D33O_M_DONE_LATE")
	hud.bark("SPK_FATIH", "D33O_F_01", 4.0)
	await get_tree().create_timer(2.5).timeout
	await hud.say("SPK_TOLGA", "D33O_T_04")


var _sockets_used := 0


func _new_stone() -> void:
	_stone = Node3D.new()
	add_child(_stone)
	var b := Props.box(_stone, Vector3(1.2, 0.7, 0.9), Vector3.ZERO, Bogaz.C_STONE)
	b.set_meta("stone", true)
	# Kıskaç: taşın iki yanındaki oyuklara geçen demir kollar
	for sx: float in [-1.0, 1.0]:
		Props.box(_stone, Vector3(0.06, 0.6, 0.1), Vector3(sx * 0.62, 0.3, 0), Color("3a3a40"), Vector3(0, 0, sx * 15.0))
	_stone.global_position = Bogaz.ARM_TIP + Vector3(0, -(Bogaz.ARM_TIP.y - Bogaz.QUAY_Y - 1.2), 0)


## Taşı yuvaya indir: kol döner, taş yuvaya oturur, ustalar harç sürer ve tokmaklar
func _set_stone() -> void:
	var target: Vector3 = Bogaz.SOCKETS[_sockets_used % 4]
	_sockets_used += 1
	var st := _stone
	_rope.visible = false
	var tw := st.create_tween()
	tw.tween_property(level.arm, "rotation:y", deg_to_rad(8.0 * (1 if target.x > 0 else -1)), 0.6)
	tw.parallel().tween_property(st, "global_position", target + Vector3(0, 0.5, 0), 0.9)
	tw.tween_property(st, "global_position", target + Vector3(0, 0.35, 0), 0.3)
	tw.parallel().tween_property(st, "rotation", Vector3.ZERO, 0.3)
	await tw.finished
	for c in st.get_children():
		if not (c as Node).has_meta("stone"):
			(c as Node3D).visible = false
	Props.box(self, Vector3(1.3, 0.06, 1.0), target + Vector3(0, 0.0, 0), Color("b8b0a0"))      # taşan harç
	for u in _masons_top:
		Audio.sfx("pick_tap", -6.0, 0.9)
	level.arm.rotation.y = 0.0
	_rope.visible = true


# ================================================================ 2. gümrük (Kasım 1452)

var genoa: Node3D
var boat: Node3D
var _rowers: Array[Person] = []
var _ladder_side: Node3D
var _cargo: Dictionary = {}
var _inspected: Dictionary = {}
var _lift_bale := false


func _toll() -> void:
	phase = "toll"
	await hud.fade_to(1.0, 0.8)
	level.make_november()
	await hud.card([[tr("UI_CH33O_TOLL"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	# Firuz rıhtımda; Ceneviz gemisi yelkeni inik, akıntıyla sürükleniyor
	firuz = Person.new({"coat": Color("6a1a1a"), "pants": Color("e8e0d0"), "hat": "turban", "mustache": true, "beard": true, "skin": Color("c89070")})
	firuz.set_meta("spk", "SPK_FIRUZ")
	add_child(firuz)
	firuz.position = Vector3(8.0, Bogaz.QUAY_Y, -4.0)
	firuz.look_target = player
	genoa = SeaBattle.carrack(self, GENOA, -PI * 0.5, 6, 3301)
	genoese = Person.new({"coat": Color("2f4a6a"), "pants": Color("2a2226"), "hat": "berretta", "mustache": true, "beard": true})
	genoese.set_meta("spk", "SPK_GENOESE")
	genoa.add_child(genoese)
	genoese.position = Vector3(0.6, SeaBattle.CARRACK_DECK, 1.0)
	genoese.look_target = player
	_build_cargo()
	_build_boat()
	player.global_position = Vector3(10.0, Bogaz.QUAY_Y + 0.05, -2.6)
	player.face(firuz.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_FIRUZ", "D33O_FZ_01")
	await hud.say("SPK_TOLGA", "D33O_T_05")
	await _row()
	await _board()
	await _hold()


func _build_boat() -> void:
	boat = Node3D.new()
	add_child(boat)
	boat.position = Vector3(12.0, -0.15, 3.0)
	boat.add_child(LowPoly.hull([
		{"z": -3.4, "w": 0.1, "top": 0.95, "bottom": 0.4},
		{"z": -1.0, "w": 1.0, "top": 0.75, "bottom": -0.1},
		{"z": 1.4, "w": 0.95, "top": 0.75, "bottom": -0.1},
		{"z": 3.4, "w": 0.1, "top": 1.0, "bottom": 0.5},
	], Color("4a3422"), Color("6a4a2c"), 0.6))
	for k in 2:
		var r := Person.new({"coat": [Color("8a6a4a"), Color("6a5040")][k], "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")})
		r.set_meta("spk", "SPK_ROWER")
		r.set_meta("no_talk", true)
		boat.add_child(r)
		r.position = Vector3(0, 0.35, -1.6 + k * 1.4)
		r.rotation.y = PI
		r.set_activity("row")
		_rowers.append(r)
		for sx: float in [-1.0, 1.0]:
			Props.cyl(r, 0.03, 2.6, Vector3(sx * 0.9, 0.7, 0.1), Color("8a6a40"), Vector3(0, 0, sx * 70.0), 4)


func _row() -> void:
	hud.bark("SPK_ROWER", "D33O_R_01", 3.0)
	player.frozen = true
	meter.enabled = true
	_strokes.clear()
	var target := genoa.global_position + Vector3(0, 0, -5.5)       # iskele (sol) bordası
	var left := ROW_TIME
	var speed := 0.0
	var rocks := false
	var rock_t := 0.0
	var rock_good := 0
	var t := 0.0
	while boat.global_position.distance_to(Vector3(target.x, boat.global_position.y, target.z)) > 4.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		left -= dt
		target = genoa.global_position + Vector3(0, 0, -5.5)
		if Input.is_action_just_pressed("jump"):
			meter.press()
		while _strokes.size() > 0:
			var good: bool = _strokes.pop_front() or GameState.autotest
			if good:
				speed = minf(speed + 1.6, 6.5)
				if rocks:
					rock_good += 1
			else:
				speed *= 0.5
			Audio.sfx("splash", -14.0, 1.2)
		speed = maxf(0.0, speed - dt * 0.9)
		hud.set_objective(tr("UI_OBJ33O_ROW"), target + Vector3(0, 4.0, 0))
		var to := target - boat.global_position
		to.y = 0.0
		var dir := to.normalized()
		var current := Vector3(1.4, 0, 0)
		boat.global_position += (dir * speed + current) * dt
		boat.rotation.y = lerp_angle(boat.rotation.y, atan2(-dir.x, -dir.z), dt * 2.0)
		for r in _rowers:
			if r.rig:
				r.rig.row_phase = fmod(t * 0.9, 1.0)
		# Kayalar: güneye fazla kayarsan
		if boat.global_position.x > target.x + 40.0 and not rocks:
			rocks = true
			rock_t = 4.0
			rock_good = 0
			hud.set_qte(tr("UI_HINT33O_ROCKS"))
			hud.bark("SPK_ROWER", "D33O_R_ROCKS", 2.5)
		if rocks:
			rock_t -= dt
			if rock_good >= 2:
				rocks = false
				hud.set_qte("")
				boat.global_position.x -= 6.0
			elif rock_t <= 0.0:
				rocks = false
				hud.set_qte("")
				Audio.sfx("land_thud", 0.0, 0.7)
				Fx.trauma(0.6)
				var tw := boat.create_tween()
				tw.tween_property(boat, "rotation:y", boat.rotation.y + PI * 0.5, 0.6)
				left -= 10.0
				boat.global_position.x -= 14.0
		if left <= 0.0:
			# Firuz surdan boş barut atar: uyandırma
			hud.bark("SPK_FIRUZ", "D33O_FZ_LATE", 3.0)
			Audio.sfx("cannon", -6.0, 1.2)
			left = ROW_TIME
		player.global_position = boat.to_global(Vector3(0, 0.6, 1.6))
		player.face(target + Vector3(0, 3.0, 0))
		if t > 240.0:
			boat.global_position = Vector3(target.x, boat.global_position.y, target.z)
	meter.enabled = false
	hud.set_objective("")


## Bordada ip merdiven: W ile tırman; gemi 4 sn'de bir yalpalar (1 sn önce uyarı); yalpada tırmanmaya devam eden suya düşer
func _board() -> void:
	var lad_base := genoa.to_global(Vector3(-SeaBattle.RAIL_X - 0.15, 0.3, 1.5))
	_ladder_side = Node3D.new()
	add_child(_ladder_side)
	_ladder_side.global_position = lad_base
	for sx: float in [-0.25, 0.25]:
		Props.cyl(_ladder_side, 0.02, 5.6, Vector3(0, 2.8, sx), Color("b89a6a"), Vector3.ZERO, 4)
	for k in 13:
		Props.box(_ladder_side, Vector3(0.06, 0.05, 0.55), Vector3(0, 0.3 + k * 0.42, 0), Color("8a6440"))
	var s := 0.0
	var roll_t := 3.0
	var warn_on := false
	var t := 0.0
	var wf_once := _variant() == "fall"
	hud.set_objective(tr("UI_OBJ33O_BOARD"), genoa.to_global(Vector3(0, SeaBattle.CARRACK_DECK + 1.0, 0)))
	while s < 1.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		roll_t -= dt
		var climb := Input.is_action_pressed("move_forward")
		if roll_t < 1.0 and not warn_on:
			warn_on = true
			hud.set_qte(tr("UI_HINT33O_ROLL"))
			hud.bark("SPK_GENOESE", "D33O_G_ROLL", 1.5)
		if GameState.autotest:
			climb = not warn_on or wf_once
		var rolling := roll_t <= 0.0
		if rolling:
			genoa.rotation.z = sin(t * 6.0) * 0.06
			_ladder_side.rotation.x = 0.2
			if climb:
				# El kayar: suya
				water_falls += 1
				wf_once = false
				hud.set_qte("")
				Audio.sfx("splash", 0.0, 0.8)
				Vfx.dust(self, player.global_position, 0.6)
				player.global_position = lad_base + Vector3(-1.5, -0.6, 0)
				await get_tree().create_timer(1.5).timeout
				hud.bark("SPK_TOLGA", "D33O_T_WATER", 3.0)
				await get_tree().create_timer(3.5).timeout
				s = 0.0
				roll_t = 4.0
				warn_on = false
				genoa.rotation.z = 0.0
				_ladder_side.rotation.x = 0.0
				continue
			if roll_t < -0.6:
				roll_t = 4.0
				warn_on = false
				hud.set_qte("")
				genoa.rotation.z = 0.0
				_ladder_side.rotation.x = 0.0
		elif climb:
			s = minf(s + dt / 4.0, 1.0)
		player.global_position = lad_base + Vector3(-0.5, 0.2 + s * 5.4, 0)
		player.face(lad_base + Vector3(2.0, 0.2 + s * 5.4 + 0.5, 0))
		if t > 120.0:
			s = 1.0
	hud.set_qte("")
	player.global_position = genoa.to_global(Vector3(-1.2, SeaBattle.CARRACK_DECK + 0.1, 1.5))
	player.face(genoese.global_position + Vector3(0, 1.5, 0))
	hud.set_objective("")


func _build_cargo() -> void:
	var items := [["fish", Vector3(-1.4, 0, -2.0), "barrel"], ["hemp_1", Vector3(1.2, 0, -3.0), "bale"], ["hemp_2", Vector3(1.4, 0, -1.4), "bale"],
		["hemp_3", Vector3(-1.2, 0, -4.2), "bale"], ["honey", Vector3(-1.6, 0, 3.2), "jars"], ["wine", Vector3(1.4, 0, 3.4), "barrel"]]
	for it: Array in items:
		var n := Node3D.new()
		genoa.add_child(n)
		n.position = (it[1] as Vector3) + Vector3(0, SeaBattle.CARRACK_DECK, 0)
		match String(it[2]):
			"barrel":
				Props.cyl(n, 0.4, 0.95, Vector3(0, 0.48, 0), Color("6a4a2c"), Vector3.ZERO, 10)
			"bale":
				Props.box(n, Vector3(1.0, 0.7, 0.8), Vector3(0, 0.35, 0), Color("b8a060"))
				for k in 2:
					Props.box(n, Vector3(1.02, 0.05, 0.05), Vector3(0, 0.2 + k * 0.3, 0.41), Color("6a5030"))
			"jars":
				for k in 3:
					Props.cyl(n, 0.2, 0.5, Vector3(-0.4 + k * 0.4, 0.25, 0), Color("a8683a"), Vector3.ZERO, 8, 0.12)
		Props.interactable(n, it[0], Vector3(1.4, 1.2, 1.4), Vector3(0, 0.5, 0))
		_cargo[it[0]] = n
	# Saklı sandık: hafif balyanın altında
	var crate := Props.box(_cargo["hemp_2"], Vector3(0.9, 0.4, 0.7), Vector3(0, -0.15, 0), Color("5a3e26"))
	crate.visible = false
	crate.name = "Crate"
	for k in 5:
		Props.cyl(crate, 0.012, 0.6, Vector3(-0.3 + k * 0.15, 0.22, 0), Color("8a8a8a"), Vector3(90, 0, 0), 4)


func _hold() -> void:
	phase = "hold"
	await hud.say("SPK_GENOESE", "D33O_G_01")
	player.frozen = false
	var left := HOLD_TIME
	var drum_t := 0.0
	var bot_t := 0.0
	var order := ["fish", "hemp_1", "wine", "hemp_2"]
	while not hidden_found and left > 0.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		left -= dt
		drum_t -= dt
		if drum_t <= 0.0:
			drum_t = 1.0
			Audio.sfx("drum_boom", -18.0, 1.0)
		hud.set_objective(tr("UI_OBJ33O_HOLD") % ceili(left))
		if GameState.autotest and _variant() != "wide":
			bot_t += dt
			if bot_t > 1.0 and order.size() > 0:
				bot_t = 0.0
				var id: String = order.pop_front()
				player.global_position = (_cargo[id] as Node3D).global_position + Vector3(-1.0, 0.1, 0)
				_on_interact(id)
				if id == "hemp_2":
					_on_interact(id)
	player.frozen = true
	hud.set_objective("")
	if hidden_found:
		await hud.say("SPK_TOLGA", "D33O_T_FIFTH")
		await hud.say("SPK_GENOESE", "D33O_G_BRIBE")
	else:
		hud.bark("SPK_FIRUZ", "D33O_FZ_DRUM", 3.0)
		await hud.say("SPK_GENOESE", "D33O_G_HASTE")
	# Hediye: şarap şişesi uzatılır
	var bottle := Props.cyl(genoese, 0.07, 0.32, Vector3(0.3, 1.1, 0.35), Color("3a5a2a"), Vector3(-20, 0, 0), 8)
	var pick := await hud.choose(["UI_C33O_REFUSE", "UI_C33O_TAKE"], 0.0, 0)
	gift = ["refuse", "take"][clampi(pick, 0, 1)]
	GameState.flags["toll_hidden"] = hidden_found
	GameState.flags["toll_gift"] = gift
	if gift == "refuse":
		await hud.say("SPK_TOLGA", "D33O_T_REFUSE")
		await hud.say("SPK_GENOESE", "D33O_G_REFUSE")
		bottle.queue_free()
	else:
		await hud.say("SPK_TOLGA", "D33O_T_TAKE")
		bottle.reparent(player.camera)
		bottle.position = Vector3(0.3, -0.4, -0.6)
		hud.bark("SPK_NIHAT", "D33O_N_TAKE", 4.0)
		get_tree().create_timer(3.0).timeout.connect(bottle.queue_free)
	# Mühür: kâğıda kırmızı damga
	var paper := Node3D.new()
	paper.position = Vector3(0.0, -0.3, -0.55)
	player.camera.add_child(paper)
	Props.box(paper, Vector3(0.26, 0.2, 0.01), Vector3.ZERO, Color("e8dcc0"))
	var seal := Props.cyl(paper, 0.035, 0.01, Vector3(0.06, -0.04, 0.01), Color("b3262d"), Vector3(90, 0, 0), 10)
	seal.scale = Vector3(0.1, 1, 0.1)
	seal.create_tween().tween_property(seal, "scale", Vector3.ONE, 0.2)
	Audio.sfx("stamp", -4.0, 1.0)
	Props.strip_outlines(paper)
	await get_tree().create_timer(1.2).timeout
	paper.queue_free()


# ================================================================ 3. uyarı atışı (26 Kasım)

var rizzo: Node3D
var _ring: MeshInstance3D
var _ship_moving := false


func _rizzo_bow() -> Vector3:
	return rizzo.global_position + Vector3(12.5, 0, 0)


func _ring_pos() -> Vector3:
	return Vector3(rizzo.global_position.x + 12.5 + 38.0, 0.05, rizzo.global_position.z)


func _warn_shot() -> void:
	phase = "warn"
	await hud.fade_to(1.0, 0.8)
	if is_instance_valid(genoa):
		genoa.queue_free()
	if is_instance_valid(boat):
		boat.queue_free()
	if is_instance_valid(_ladder_side):
		_ladder_side.queue_free()
	await hud.card([[tr("UI_CH33O_RIZZO"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	rizzo = SeaBattle.carrack(self, Vector3(-130.0, 0.0, SHIP_Z), -PI * 0.5, 8, 3302)
	SeaBattle.fill_sails(rizzo, 1.0)
	# Aziz Markos sancağı (kırmızı-altın), kıç kasarasında Rizzo
	Props.box(rizzo, Vector3(0.05, 1.2, 1.8), Vector3(0, 10.0, 11.8), Color("b3262d"))
	Props.box(rizzo, Vector3(0.06, 0.5, 0.6), Vector3(0, 10.0, 11.6), Color("d8b040"))
	var rz := Person.new({"coat": Color("6a1a2a"), "pants": Color("2a2226"), "hat": "berretta", "mustache": true, "beard": true})
	rz.set_meta("spk", "SPK_RIZZO")
	rizzo.add_child(rz)
	rz.position = Vector3(0, 7.0, 9.4)
	rz.rotation.y = PI * 0.5
	_ring = Props.cyl(self, 5.0, 0.05, _ring_pos(), Color(1.0, 0.2, 0.15, 0.4), Vector3.ZERO, 24)
	_ring.material_override = Props.mat(Color(1.0, 0.2, 0.15, 0.35), 0.6, true, "", false)
	_ship_moving = true
	player.global_position = Bogaz.SMALL_GUN + Vector3(1.6, 0.05, -2.0)
	player.face(rizzo.global_position + Vector3(0, 6.0, 0))
	firuz.position = Bogaz.SMALL_GUN + Vector3(-2.0, 0, -1.5)
	await hud.fade_to(0.0, 0.8)
	hud.bark("SPK_FIRUZ", "D33O_FZ_SHIP", 3.0)
	await get_tree().create_timer(1.5).timeout
	hud.bark("SPK_RIZZO", "D33O_RZ_01", 3.5)
	await get_tree().create_timer(2.0).timeout
	hud.bark("SPK_FIRUZ", "D33O_FZ_WARN", 4.0)
	hud.bark("SPK_TOLGA", "D33O_T_WARN", 4.0)
	_setup_crew(level.small_gun, false)
	var left := WARN_TIME
	hud.set_objective(tr("UI_OBJ33O_WARN") % ceili(left))
	drill.start(0.3, 0.18)
	while drill.active and left > 0.0:
		await get_tree().process_frame
		left -= get_process_delta_time()
		hud.set_objective(tr("UI_OBJ33O_WARN") % ceili(maxf(left, 0.0)))
	hud.set_objective("")
	if drill.active:
		drill.stop()
		warn = "miss"
		Audio.sfx("cannon", -2.0, 1.1)
		hud.bark("SPK_FIRUZ", "D33O_FZ_WARN_MISS", 3.0)
	else:
		var at: Vector3 = drill.last_impact
		if _variant() == "wide":
			at = rizzo.global_position + Vector3(0, 2.0, 0)
		var ring := _ring_pos()
		if at != Vector3.INF and Vector2(at.x - rizzo.global_position.x, at.z - rizzo.global_position.z).length() < 12.0:
			warn = "hit"
		elif at != Vector3.INF and Vector2(at.x - ring.x, at.z - ring.z).length() < 9.0:
			warn = "ok"
		else:
			warn = "miss"
		if at != Vector3.INF:
			_splash(at, 6.0 if warn == "ok" else 2.5)
		hud.bark("SPK_FIRUZ", {"ok": "D33O_FZ_WARN_OK", "hit": "D33O_FZ_WARN_HIT", "miss": "D33O_FZ_WARN_MISS"}[warn], 3.5)
	print("WARN %s" % warn) if GameState.autotest else null
	await get_tree().create_timer(2.0).timeout
	hud.bark("SPK_RIZZO", "D33O_RZ_02", 3.0)
	_ring.visible = false
	await get_tree().create_timer(1.5).timeout


func _splash(at: Vector3, h: float) -> void:
	Audio.sfx("splash", 0.0, 0.7)
	var col := Props.cyl(self, 0.8, h, Vector3(at.x, h * 0.5, at.z), Color(0.9, 0.95, 1.0, 0.7), Vector3.ZERO, 10, 0.3)
	col.material_override = Props.mat(Color(0.9, 0.95, 1.0, 0.7), 0.2, true, "", false)
	var tw := col.create_tween()
	tw.tween_property(col, "scale", Vector3(1.6, 0.05, 1.6), 1.2)
	tw.tween_callback(col.queue_free)


func _setup_crew(gun: Node3D, is_big: bool) -> void:
	if is_instance_valid(crew):
		crew.queue_free()
	crew = CannonCrew.new()
	add_child(crew)
	crew.player = player
	crew.hud = hud
	crew.pivot = gun.get_node("Pivot")
	crew.muzzle = gun.get_node("Pivot/Muzzle")
	crew.recoil_node = gun
	crew.aim_spot = gun.to_global(Vector3(0, 0, 3.2 if not is_big else 6.5))
	crew.aim_back = 3.0 if not is_big else 6.0
	crew.supplies = {"powder": gun.to_global(Vector3(-3.0, 0, 2.0)), "ball": gun.to_global(Vector3(2.6, 0, 1.4)),
		"wad": gun.to_global(Vector3(-2.4, 0, 3.6)), "rammer": gun.to_global(Vector3(2.8, 0, 3.4))}
	crew.spawn = ["powder", "wad"] if not is_big else ["wad"]
	# Gemi fitil (0.55 sn), uçuş (~2.1 sn) ve büyük topta geri çekilme (2 sn) boyunca ilerler: öne nişan
	if is_big:
		crew.target = func() -> Vector3: return rizzo.global_position + Vector3(SHIP_SPEED * 4.8, 0.0, 0)
		crew.hit_radius = 9.0
	else:
		crew.target = func() -> Vector3: return _ring_pos() + Vector3(SHIP_SPEED * 2.65, 0, 0)
		crew.hit_radius = 5.0
	crew.tolerance = 30.0
	crew.ground_y = 0.0
	crew.load_radius = 2.6 if not is_big else 3.4
	crew.design_elev = 6.0
	crew.pitch_min = -6.0
	crew.pitch_max = 16.0
	crew.yaw_limit = 40.0
	if is_big:
		crew.before_fire = func():
			# Arkadan çekil: 2 sn içinde topun arkasındaki kırmızı alandan çık
			hud.set_qte(tr("UI_HINT33O_RECOIL"))
			hud.bark("SPK_URBAN", "D33O_U_BACK", 2.0)
			player.frozen = false
			if GameState.autotest:
				player.global_position = Bogaz.BIG_GUN + Vector3(4.0, 0.1, -2.0)
			await get_tree().create_timer(2.0).timeout
			hud.set_qte("")
			var p := player.global_position - Bogaz.BIG_GUN
			if absf(p.x) < 2.2 and p.z < 0.5 and p.z > -7.0:
				_recoil_hit = true
	crew.setup()
	drill.bind(crew)


var _recoil_hit := false


# ================================================================ 4. büyük top

func _big_gun() -> void:
	phase = "big"
	hud.bark("SPK_FIRUZ", "D33O_FZ_BIG", 3.0)
	urban = Person.new({"coat": Color("4a3a2a"), "pants": Color("3a2a22"), "hat": "kalpak", "beard": true, "mustache": true, "hair": Color("6a5040"), "face": "urban"})
	urban.set_meta("spk", "SPK_URBAN")
	add_child(urban)
	urban.position = Bogaz.BIG_GUN + Vector3(-2.6, 0, -1.0)
	urban.look_target = player
	player.global_position = Bogaz.BIG_GUN + Vector3(2.0, 0.05, -3.0)
	player.face(urban.global_position + Vector3(0, 1.5, 0))
	hud.bark("SPK_URBAN", "D33O_U_01", 4.5)
	await get_tree().create_timer(2.5).timeout
	hud.bark("SPK_TOLGA", "D33O_T_URBAN", 3.5)
	_setup_crew(level.big_gun, true)
	drill.start(0.3, 0.16)
	var t := 0.0
	while drill.active and t < 120.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	if drill.active:
		drill.stop()
	var at: Vector3 = drill.last_impact
	big = at != Vector3.INF and Vector2(at.x - rizzo.global_position.x, at.z - rizzo.global_position.z).length() < 12.0
	if _variant() == "wide":
		big = false
	if _recoil_hit:
		player.hurt(30.0, Bogaz.BIG_GUN + Vector3(0, 1, 2))
		player.stagger(1.5)
	print("BIG %s" % ("hit" if big else "miss")) if GameState.autotest else null
	if big:
		hud.bark("SPK_URBAN", "D33O_U_HIT", 3.0)
	else:
		hud.bark("SPK_URBAN", "D33O_U_MISS", 3.0)
		await get_tree().create_timer(2.0).timeout
		Audio.sfx("cannon", 0.0, 0.9)
		Vfx.explosion(self, Bogaz.BIG_GUN + Vector3(14.0, 2.0, 2.0), 1.4)
		await get_tree().create_timer(1.6).timeout
		hud.bark("SPK_URBAN", "D33O_U_SECOND", 3.0)
	_sink()
	# Tespit: yatan direk ve arkada kule
	player.frozen = false
	var target := Node3D.new()
	rizzo.add_child(target)
	target.position = Vector3(0, SeaBattle.CARRACK_DECK + 18.0, -1.0)
	hud.set_objective(tr("UI_OBJ33O_PHOTO"), target.global_position)
	hud.bark("SPK_TOLGA", "D33O_T_SINK", 4.0)
	cam = TespitCam.new(player, hud, target, "siege33o")
	hud.add_child(cam)
	cam.max_dist = 260.0
	cam.cone_deg = 10.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	t = 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 20.0):
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest:
			player.face(target.global_position)
	cam.stop()
	hud.set_objective("")
	player.frozen = true
	if not _photo.is_empty():
		hud.bark("SPK_NIHAT", "D33O_N_PHOTO", 2.0)


## Batış: gövdede delik (kalaslar dışarı açılır), su fışkırır; gemi 6 sn'de 25° yatar, direk iner, tayfa suya atlar,
## enkaz akıntıyla sürüklenir
func _sink() -> void:
	_ship_moving = false
	Fx.trauma(0.6)
	Audio.sfx("explosion_big", -4.0, 0.8)
	var hole := rizzo.to_global(Vector3(-SeaBattle.RAIL_X, 2.0, 0.0))
	for k in 8:
		var pl := Props.box(self, Vector3(0.2, 0.08, 1.2), hole, Color("4a3424"))
		var tw := pl.create_tween()
		tw.tween_property(pl, "position", hole + Vector3(randf_range(-3, -1), randf_range(0.5, 2.5), randf_range(-2, 2)), 0.6)
		tw.tween_property(pl, "position:y", 0.1, 0.8).set_ease(Tween.EASE_IN)
	_splash(hole, 4.0)
	var st := rizzo.create_tween()
	st.tween_property(rizzo, "rotation:z", deg_to_rad(25.0), 6.0)
	st.parallel().tween_property(rizzo, "position:y", -3.5, 9.0)
	for c: Person in rizzo.get_meta("crew", []):
		if is_instance_valid(c):
			var ct := c.create_tween()
			ct.tween_interval(randf_range(1.0, 4.0))
			ct.tween_callback(func():
				if is_instance_valid(c):
					var w := c.global_transform
					c.reparent(self)
					c.global_transform = w
					var jt := c.create_tween()
					jt.tween_property(c, "global_position", c.global_position + Vector3(randf_range(-2, 2), -c.global_position.y - 0.4, randf_range(-6, -3)), 0.9)
					jt.tween_callback(func(): Audio.sfx("splash", -8.0, 1.2))
					c.set_activity("swim"))


# ================================================================ 5. kıyı

func _coast() -> void:
	phase = "coast"
	await hud.fade_to(1.0, 0.8)
	if is_instance_valid(rizzo):
		rizzo.visible = false
	# Sandal rıhtıma yanaşır; askerler tayfayı alır, yokuştan yürüyerek giderler
	var sandal := Node3D.new()
	add_child(sandal)
	sandal.position = Vector3(30.0, -0.1, 30.0)
	sandal.add_child(LowPoly.hull([{"z": -2.6, "w": 0.1, "top": 0.8, "bottom": 0.3}, {"z": 0.0, "w": 0.9, "top": 0.6, "bottom": -0.1},
		{"z": 2.6, "w": 0.1, "top": 0.9, "bottom": 0.4}], Color("4a3422"), Color("6a4a2c"), 0.55))
	var crewmen: Array[Person] = []
	for k in 4:
		var c := Person.new({"coat": [Color("8a8e96"), Color("2f4a6a"), Color("6a2a24"), Color("5a6a7a")][k], "pants": Color("2a2226"), "hat": "berretta" if k == 0 else "",
			"mustache": true})
		c.set_meta("no_talk", true)
		sandal.add_child(c)
		c.position = Vector3(0, 0.35, -1.5 + k * 1.0)
		c.set_activity("sit")
		crewmen.append(c)
	player.global_position = Vector3(26.0, Bogaz.QUAY_Y + 0.05, -3.0)
	player.face(sandal.global_position + Vector3(0, 1.0, 0))
	firuz.position = Vector3(22.0, Bogaz.QUAY_Y, -4.0)
	await hud.fade_to(0.0, 0.8)
	var tw := sandal.create_tween()
	tw.tween_property(sandal, "position", Vector3(30.0, -0.1, 2.2), 6.0 if not GameState.autotest else 1.0)
	hud.bark("SPK_FIRUZ", "D33O_FZ_BOAT", 3.5)
	await tw.finished
	hud.bark("SPK_TOLGA", "D33O_T_BOAT", 4.0)
	# Tayfa iner, askerlerle yan yana yokuştan çıkar (arkaları dönük, uzaklaşır)
	for i in crewmen.size():
		var c := crewmen[i]
		var w := c.global_transform
		c.reparent(self)
		c.global_transform = w
		c.set_activity("")
		c.global_position = Vector3(28.0 + i * 0.8, Bogaz.QUAY_Y, -1.6)
		var s := Soldier.new(Color("b3262d"), "stand", "bork")
		add_child(s)
		s.position = c.position + Vector3(0.6, 0, -0.4)
		s.equip("spear")
		for n: Node3D in [c, s]:
			var to := Vector3(n.position.x - 12.0, 0, -60.0)
			to.y = Bogaz.ground_y(to.x, to.z)
			var wt := n.create_tween()
			wt.tween_interval(i * 0.6)
			wt.tween_property(n, "position", to, 18.0)
	await get_tree().create_timer(3.0).timeout
	await hud.say("SPK_NIHAT", "D33O_N_END")
	await hud.say("SPK_TOLGA", "D33O_T_END")
	_outcome = "33O.1" if warn == "ok" and big else "33O.2"
	urban.position = player.global_position + Vector3(-2.0, -0.05, -1.5)
	await hud.say("SPK_URBAN", "D33O_U_END_OK" if _outcome == "33O.1" else "D33O_U_END_BAD")
	Siege.record(33, _photo, "SIEGE_NOTE_33O_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	if _ship_moving and is_instance_valid(rizzo):
		rizzo.global_position.x += SHIP_SPEED * delta
		if is_instance_valid(_ring):
			_ring.global_position = _ring_pos()
	if phase == "toll" and is_instance_valid(genoa):
		genoa.global_position.x += 0.3 * delta


func _on_focus(id: String) -> void:
	var k := ""
	if phase == "hold" and _cargo.has(id):
		k = "UI_PROMPT33O_LIFT" if id == "hemp_2" and _inspected.has(id) else "UI_PROMPT33O_CARGO"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	if phase == "crane":
		_lower_req = true
		return
	if phase == "hold" and _cargo.has(id):
		if not _inspected.has(id):
			_inspected[id] = true
			Audio.sfx("cloth", -10.0, 1.0)
			var n: Node3D = _cargo[id]
			var tw := n.create_tween()
			tw.tween_property(n, "rotation:y", 0.15, 0.3)
			tw.tween_property(n, "rotation:y", 0.0, 0.3)
		elif id == "hemp_2" and not hidden_found:
			# Hafif balya: kaldırılır, altında sandık
			var n2: Node3D = _cargo[id]
			for c in n2.get_children():
				if c.name != "Crate" and c is MeshInstance3D:
					var t2 := (c as Node3D).create_tween()
					t2.tween_property(c, "position", (c as Node3D).position + Vector3(0.6, 0.9, 0.4), 0.4)
			n2.get_node("Crate").visible = true
			hidden_found = true
			Audio.sfx("door_open", -8.0, 1.3)


func _input(event: InputEvent) -> void:
	if phase == "crane" and event.is_action_pressed("interact"):
		_lower_req = true


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(33, _outcome)
	await Siege.show_page(hud, 33)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(33)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW33O_TITLE")
	c.nodes = [
		{"id": "scaffold", "key": "FLOW33O_SCAFFOLD", "pos": Vector2(0.5, 0.1)},
		{"id": "crane", "key": "FLOW33O_CRANE", "pos": Vector2(0.5, 0.22)},
		{"id": "toll", "key": "FLOW33O_TOLL", "pos": Vector2(0.5, 0.34)},
		{"id": "warn", "key": "FLOW33O_WARN", "pos": Vector2(0.5, 0.46)},
		{"id": "big", "key": "FLOW33O_BIG", "pos": Vector2(0.5, 0.58)},
		{"id": "33O.1", "key": "FLOW_33O_1", "pos": Vector2(0.3, 0.72), "outcome": true},
		{"id": "33O.2", "key": "FLOW_33O_2", "pos": Vector2(0.7, 0.72), "outcome": true},
	]
	c.edges = [["scaffold", "crane"], ["crane", "toll"], ["toll", "warn"], ["warn", "big"], ["big", "33O.1"], ["big", "33O.2"]]
	for k in ["scaffold", "crane", "toll", "warn", "big"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		Grade.finish("33o"),
		tr("UI_CH33O_STATS") % [stones_set, STONES, scaffold_falls, tr("UI_CH33O_WARN_" + warn.to_upper()), tr("UI_CH33O_BIG_HIT" if big else "UI_CH33O_BIG_MISS"),
			Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "33O.1", "wide": "33O.2", "fall": "33O.1"}.get(v, "33O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("33", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null
	match v:
		"":
			ok = ok and stones_set == STONES and crane_hits == 0 and hidden_found and gift == "refuse" and warn == "ok" and big and cam.done
		"wide":
			ok = ok and warn == "hit" and not big
		"fall":
			ok = ok and scaffold_falls >= 1 and water_falls >= 1 and crane_hits >= 1
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s taş=%d çarpma=%d düşüş=%d su=%d sandık=%s uyarı=%s büyük=%s foto=%s)" % [expected, _outcome,
			not page.is_empty(), stones_set, crane_hits, scaffold_falls, water_falls, hidden_found, warn, big, cam != null and cam.done])
	print("AUTOTEST %s chapter=33o variant=%s outcome=%s stones=%d hits=%d falls=%d water=%d hidden=%s gift=%s warn=%s big=%s" % [
		"PASS" if ok else "FAIL", v, _outcome, stones_set, crane_hits, scaffold_falls, water_falls, hidden_found, gift, warn, big])
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
	hud.visible = false
	player.show_remote(false)
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(26.0, 6.0, 22.0)
	cv.look_at(Vector3(-2.0, 10.0, -28.0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	_new_stone()
	_stone.global_position = Bogaz.ARM_TIP + Vector3(0.6, -6.0, 0)
	_rope = Bogaz.make_rope(self)
	Bogaz.rope(_rope, Bogaz.ARM_TIP, _stone.global_position + Vector3(0, 0.45, 0))
	await get_tree().create_timer(0.8).timeout
	await _shot_png("c33o_cover.png")
	cv.global_position = Vector3(-6.0, Bogaz.DECK2_Y + 1.7, -17.0)
	cv.look_at(Vector3(-8.0, Bogaz.WALK_Y, -22.6), Vector3.UP)
	await get_tree().create_timer(0.4).timeout
	await _shot_png("c33o_01_scaffold.png")
	rizzo = SeaBattle.carrack(self, Vector3(-20.0, 0.0, SHIP_Z), -PI * 0.5, 8, 3302)
	SeaBattle.fill_sails(rizzo, 1.0)
	cv.global_position = Bogaz.BIG_GUN + Vector3(-1.0, 3.0, -6.0)
	cv.look_at(rizzo.global_position + Vector3(0, 6.0, 0), Vector3.UP)
	await get_tree().create_timer(0.4).timeout
	await _shot_png("c33o_02_battery.png")
	get_tree().quit()
