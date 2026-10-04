extends Node3D
## Bölüm 39 (yalnız Osmanlı tarafı) — Emanet (Tolga · 29 Mayıs 1453 akşamı → gece, Petrion). docs/OTTOMAN_NEW_B.md §3.
##
## Şehrin çoğunda yağma sürer; teslim olan Petrion gibi birkaç mahalleye Sultan'ın adamları muhafız koyar. Tolga Sultan'ın
## çavuşu Davud'un tercümanıdır. Bölüm yağmayı göstermez ve süslemez; İmparator'un akıbeti bilinmez (gösterilmez).
##   1. Sancak yarışı: listedeki altı kapıya Sultan'ın sancağı (ipuçlarıyla); yağmacı tayfa listedeki kapılara koşar.
##      Moloz ve tek katlı evlerin damları kestirme (tırmanma).
##   2. Kilise kapısı: baltalı iki tayfa; kapı çubuğu azalır. Tezkire göster (2 kez), halka sorarak çavuşu bul, önden
##      koşarak getir; çubuk düşükse balta sapında çekişme (Space ritmi). Kimse yaralanmaz.
##   3. Yangın: kilisenin yanındaki evin damı tutuşur; cumbaya tırman, dumanda eğil (C), yaşlı adamı kolundan tut, pencereden
##      iple indir (E basılı + denge). Düşen kiremitler. Çatı sayacı.
##   4. Nöbet: ateş başında İmparator sorulur (seçim); tespit: kilisenin kapısında nöbet.
##   39O.1 Altı kapı emanette, kapı dayandı, adam zamanında indi · 39O.2 Bazı kapılar geç kaldı
##   --autotest[=late]   (varsayılan: 39O.1)

const FLAG_TIME := 180.0
const DOOR_RATE := 2.0
const ROOF_TIME := 90.0

var city: Petrion
var player: Player
var hud: Hud
var meter: RowMeter
var balance: BalanceMeter
var cam: TespitCam
var cavus: Person
var elder: Person
var priest: Person
var old_man: Person
var sailors: Array[Person] = []
var looters: Array[Person] = []
var townsfolk: Array[Person] = []
var guards: Array[Soldier] = []
var phase := "intro"
var _outcome := ""
var _photo := ""
var flags_done := 0
var flags_lost := 0
var wrong_doors := 0
var door_hp := 100.0
var door_broke := false
var tez_used := 0
var struggles_won := 0
var roof_left := 0.0
var roof_fell := false
var emperor_answer := ""
var _flagged: Dictionary = {}        # kapı indisi → "ours" / "theirs"
var _strokes: Array = []
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(39)
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
	balance.label_text = tr("UI_OBJ39O_LOWER")
	balance.visible = false
	hud.add_child(balance)
	balance.place_bottom()
	var moon := Night.environment(self, 0.006)
	moon.rotation_degrees = Vector3(-24, 140, 0)
	city = Petrion.new()
	add_child(city)
	_build_people()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build_people() -> void:
	cavus = Person.new({"coat": Color("6a1a1a"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true,
		"hair": Color("8a8a88"), "skin": Color("c89070")})
	cavus.set_meta("spk", "SPK_CAVUS")
	cavus.position = Vector3(0.6, 0, Petrion.GATE_Z - 2.6)
	cavus.rotation.y = PI
	add_child(cavus)
	cavus.look_target = player
	Props.interactable(cavus, "cavus", Vector3(1.4, 2.0, 1.4), Vector3(0, 1.0, 0))
	elder = Person.new({"coat": Color("4a4a58"), "pants": Color("2a2a30"), "beard": true, "hair": Color("c8c8c0"), "robe": Color("3a3a40"), "skin": Color("d8b090")})
	elder.set_meta("spk", "SPK_TOWNSMAN")
	elder.position = Vector3(-1.0, 0, Petrion.GATE_Z - 3.0)
	elder.rotation.y = PI * 0.8
	add_child(elder)
	elder.look_target = player
	priest = Person.new({"coat": Color("1a1a20"), "pants": Color("1a1a20"), "robe": Color("1a1a20"), "beard": true, "hair": Color("d0d0c8"),
		"hat": "kamelaukion", "skin": Color("d8b090")})
	priest.set_meta("spk", "SPK_PRIEST")
	# Kilisenin önünde, caddenin ortasına yakın: kapıdaki tayfalarla oyuncunun arasına girmesin
	priest.position = Vector3(-0.2, 0, Petrion.CHURCH_Z + 1.2)
	add_child(priest)
	priest.look_target = player
	# Kapılarda bekleyen halk (ikisi çavuşu görmüş: "?")
	for k in 4:
		var w := Person.new({"coat": [Color("6a5a48"), Color("4a5a6a"), Color("7a4a3a"), Color("5a5040")][k], "pants": Color("2a2a30"),
			"beard": k % 2 == 0, "skin": Color("d8b090")})
		w.set_meta("spk", "SPK_TOWNSMAN")
		w.position = Vector3([3.4, -3.4, 3.4, -3.4][k], 0, [-12.0, -22.0, -42.0, -60.0][k])
		w.rotation.y = PI * 0.5 * (1 if k % 2 == 0 else -1)
		add_child(w)
		w.look_target = player
		Props.interactable(w, "town_%d" % k, Vector3(1.4, 2.0, 1.4), Vector3(0, 1.0, 0))
		townsfolk.append(w)
	for i in city.doors.size():
		var d: Array = city.doors[i]
		var idx: int = d[0]
		Props.interactable(self, "door_%d" % idx, Vector3(1.6, 2.4, 1.8), (d[1] as Vector3) + Vector3(-signf(d[2]) * 0.4, 1.2, 0))


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH39O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH39O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = Vector3(0.0, 0.05, Petrion.GATE_Z - 0.6)
	player.face(cavus.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D39O_N_01")
	await hud.say("SPK_TOLGA", "D39O_T_01")
	await hud.say("SPK_CAVUS", "D39O_C_01")
	if GameState.flags.get("petrion_word", "") == "add":
		await hud.say("SPK_CAVUS", "D39O_C_01_ADD")
	await hud.say("SPK_CAVUS", "D39O_C_02")
	await hud.say("SPK_TOWNSMAN", "D39O_TW_01")
	await hud.say("SPK_TOLGA", "D39O_T_02")
	await _flags()
	await _church_door()
	await _fire()
	await _watch()
	await _end_chapter()


# ---------------------------------------------------------------- 1. sancak yarışı

var _flag_bundle: Node3D
var _planting := false
var _looter_runs: Array = []        # [Person, hedef kapı indisi, varış noktası]


func _flags() -> void:
	phase = "flags"
	player.frozen = false
	player.enable_climb([Rect2(-Petrion.HALF - 7.5, Petrion.END_Z, Petrion.HALF * 2.0 + 15.0, Petrion.GATE_Z - Petrion.END_Z)])
	Lore.scatter(self, "39o")
	_flag_bundle = Node3D.new()
	_flag_bundle.position = Vector3(0.36, -0.6, -0.55)
	player.camera.add_child(_flag_bundle)
	_refresh_bundle()
	var t := 0.0
	var looter_at := [50.0, 100.0, 150.0]
	var late := GameState.autotest_variant == "late"
	var bot_t := 0.0
	while flags_done + flags_lost < 6 and t < FLAG_TIME:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		_flag_objective(t)
		# Yağmacı tayfa listedeki sancaksız bir kapıya koşar ("Bu kapı benim!")
		if looter_at.size() > 0 and t >= looter_at[0]:
			looter_at.pop_front()
			_send_looter()
		for run: Array in _looter_runs.duplicate():
			var lp: Person = run[0]
			var goal: Vector3 = run[2]
			if not is_instance_valid(lp):
				_looter_runs.erase(run)
				continue
			var d := goal - lp.global_position
			d.y = 0.0
			if _flagged.has(run[1]):
				_looter_runs.erase(run)
				var tw := lp.create_tween()
				tw.tween_property(lp, "global_position", Vector3(lp.global_position.x, 0, Petrion.END_Z + 2.0), 6.0)
				tw.tween_callback(lp.queue_free)
				continue
			if d.length() < 0.4:
				_flagged[run[1]] = "theirs"
				flags_lost += 1
				_plant_flag(run[1], Color("6a6a6a"))
				hud.bark("SPK_SAILOR", "D39O_SA_FLAG", 3.0)
				hud.bark("SPK_CAVUS", "D39O_C_LATE", 4.0)
				_looter_runs.erase(run)
				continue
			lp.global_position += d.normalized() * minf(d.length(), 3.6 * dt)
			lp.rotation.y = atan2(d.x, d.z)
		# Bot: listedeki kapılara sırayla gider (=late: üçünden sonra yavaşlar)
		if GameState.autotest and not _planting:
			bot_t -= dt
			if bot_t <= 0.0:
				bot_t = 1.6 if not (late and flags_done >= 3) else 999.0
				for h in 6:
					var idx: int = Petrion.LISTED[h]
					if not _flagged.has(idx):
						player.global_position = city.door_pos(idx) + Vector3(-signf(city.door_pos(idx).x) * 1.2, 0.05, 0)
						_on_interact("door_%d" % idx)
						break
	hud.set_objective("")
	player.frozen = true
	if is_instance_valid(_flag_bundle):
		_flag_bundle.queue_free()
	await hud.say("SPK_TOLGA", "D39O_T_FLAGS")


func _flag_objective(_tt: float) -> void:
	var hints := ""
	for h in 6:
		var idx: int = Petrion.LISTED[h]
		var mark := "✓ " if _flagged.get(idx, "") == "ours" else ("✗ " if _flagged.has(idx) else "· ")
		hints += "\n" + mark + tr("UI_HINT39O_%d" % (h + 1))
	hud.set_objective(tr("UI_OBJ39O_FLAG") % [flags_done, 6] + hints)


func _refresh_bundle() -> void:
	for c in _flag_bundle.get_children():
		c.queue_free()
	for k in maxi(0, 6 - flags_done - flags_lost):
		# Kolun altında sarılı sancaklar: direkler eğik, bezler direğe sarılı
		Props.cyl(_flag_bundle, 0.012, 0.6, Vector3(k * 0.025, 0.08, 0), Color("6a4a2c"), Vector3(-25, 0, -8.0 + k * 3.0), 4)
		Props.cyl(_flag_bundle, 0.03, 0.2, Vector3(k * 0.025, 0.22, -0.07), Color("b3262d"), Vector3(-25, 0, -8.0 + k * 3.0), 6)
	Props.strip_outlines(_flag_bundle)


func _plant_flag(idx: int, col: Color) -> void:
	var p := city.door_pos(idx)
	var side := signf(p.x)
	var f := Node3D.new()
	add_child(f)
	f.position = Vector3(p.x - side * 0.15, 2.4, p.z + 0.7)
	Props.cyl(f, 0.03, 1.4, Vector3(-side * 0.3, 0, 0), Color("6a4a2c"), Vector3(0, 0, side * 60.0), 5)
	var cloth := Props.box(f, Vector3(0.03, 0.5, 0.7), Vector3(-side * 0.7, 0.15, 0.35), col)
	var tw := cloth.create_tween().set_loops()
	tw.tween_property(cloth, "rotation:y", 0.15, 0.6)
	tw.tween_property(cloth, "rotation:y", -0.15, 0.6)


func _send_looter() -> void:
	var free: Array = []
	for h in 6:
		var idx: int = Petrion.LISTED[h]
		if not _flagged.has(idx):
			free.append(idx)
	if free.is_empty():
		return
	# Oyuncudan en uzak sancaksız kapıya
	var best: int = free[0]
	var bd := -1.0
	for idx: int in free:
		var dd := city.door_pos(idx).distance_to(player.global_position)
		if dd > bd:
			bd = dd
			best = idx
	var lp := Person.new({"coat": Color("6a5040"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")})
	lp.set_meta("no_talk", true)
	add_child(lp)
	var from_end := city.door_pos(best).z < -32.0
	lp.global_position = Vector3(0.0, 0.0, Petrion.END_Z + 3.0 if from_end else Petrion.GATE_Z - 1.0)
	var torch := Props.cyl(lp, 0.04, 0.6, Vector3(0.3, 1.4, 0.2), Color("4a3020"), Vector3.ZERO, 5)
	var fl := Props.cyl(lp, 0.07, 0.18, Vector3(0.3, 1.8, 0.2), Color("ffb030"), Vector3.ZERO, 5, 0.0)
	fl.material_override = Props.mat(Color("ffb030"), 3.0, false, "", false)
	torch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	looters.append(lp)
	var goal := city.door_pos(best) + Vector3(-signf(city.door_pos(best).x) * 0.6, 0, 0)
	_looter_runs.append([lp, best, goal])
	hud.bark("SPK_SAILOR", "D39O_SA_FLAG", 2.5)
	Audio.sfx("crowd_gasp", -10.0, 0.9)


func _on_focus(id: String) -> void:
	var k := ""
	if id.begins_with("door_") and phase == "flags":
		k = "UI_PROMPT39O_FLAG"
	elif id.begins_with("town_") and phase == "door":
		k = "UI_PROMPT39O_ASK"
	elif id == "cavus" and phase == "door" and not _cavus_follow:
		k = "UI_PROMPT39O_CALL"
	elif id == "sailor" and phase == "door":
		k = "UI_PROMPT39O_SHOW" if tez_used < 2 else "UI_PROMPT39O_AXE"
	elif id == "oldman" and phase == "fire" and not _man_follow:
		k = "UI_PROMPT39O_ARM"
	elif id == "watchfire" and phase == "watch":
		k = "UI_PROMPT39O_SIT"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	if id.begins_with("door_") and phase == "flags" and not _planting:
		var idx := int(id.trim_prefix("door_"))
		if _flagged.has(idx):
			return
		if idx in Petrion.LISTED:
			_plant_mine(idx)
		else:
			wrong_doors += 1
			hud.bark("SPK_CAVUS", "D39O_C_FLAG_WRONG", 2.5)
			_peek(idx)
			player.stagger(0.4)
		return
	match id:
		"cavus":
			if phase == "door" and not _cavus_follow:
				_cavus_follow = true
				Audio.sfx("whistle", -8.0, 1.0)
		"sailor":
			if phase == "door":
				if tez_used < 2 and _tez_pause <= 0.0:
					tez_used += 1
					_tez_pause = 15.0
					_show_tez()
				elif door_hp < 25.0:
					_struggle_req = true
		"oldman":
			if phase == "fire" and not _man_follow:
				_man_follow = true
				Audio.sfx("cough", -8.0, 0.9)
		"watchfire":
			if phase == "watch":
				_sat = true
		_:
			if id.begins_with("town_") and phase == "door":
				_ask(int(id.trim_prefix("town_")))


func _plant_mine(idx: int) -> void:
	_planting = true
	player.frozen = true
	# 1 sn: direği kapı halkasına geçirip iki avuçla sıkıştırır
	Audio.sfx("pick_tap", -6.0, 1.2)
	await get_tree().create_timer(0.5).timeout
	Audio.sfx("pick_tap", -6.0, 1.0)
	await get_tree().create_timer(0.5).timeout
	_flagged[idx] = "ours"
	flags_done += 1
	_plant_flag(idx, Color("b3262d"))
	_refresh_bundle()
	hud.bark("SPK_CAVUS", "D39O_C_FLAG_OK", 2.0)
	# Bir yeniçeri o kapıya yürüyerek gelir, yanında durur
	var g := Soldier.new(Color("b3262d"), "stand", "bork")
	add_child(g)
	g.position = Vector3(0.0, 0.0, Petrion.END_Z + 1.5)
	g.equip("spear")
	var goal := city.door_pos(idx) + Vector3(-signf(city.door_pos(idx).x) * 0.7, 0, 1.2)
	var tw := g.create_tween()
	tw.tween_property(g, "position", goal, g.position.distance_to(goal) / 3.0)
	tw.tween_callback(func(): g.rotation.y = -signf(goal.x) * PI * 0.5)
	g.rotation.y = 0.0
	guards.append(g)
	player.frozen = false
	_planting = false


## Yanlış kapı: aralanır, korkmuş bir yüz görünür, kapanır
func _peek(idx: int) -> void:
	for d: Array in city.doors:
		if d[0] == idx:
			var door: Node3D = d[3]
			var tw := door.create_tween()
			tw.tween_property(door, "position:z", door.position.z + 0.5, 0.3)
			tw.tween_interval(0.6)
			tw.tween_property(door, "position:z", door.position.z, 0.3)
			Audio.sfx("door_open", -10.0, 1.3)


# ---------------------------------------------------------------- 2. kilise kapısı

var _cavus_follow := false
var _tez_pause := 0.0
var _struggle_req := false
var _asked := false


func _church_door() -> void:
	phase = "door"
	# Çavuş caddenin iki ucundan birinde (rastgele); sorulan halk yönü söyler
	var far := (randf() < 0.5 and not GameState.autotest) or GameState.autotest_variant == "late"
	# Kapı tarafında bölümün başındaki yerinde (x 1,6'da kuyunun/arabanın kenarının içinde kalıyordu)
	cavus.global_position = Vector3(1.6 if far else 0.6, 0.0, Petrion.END_Z + 4.0 if far else Petrion.GATE_Z - 3.0)
	await hud.fade_to(1.0, 0.4)
	player.global_position = Vector3(-1.0, 0.05, Petrion.CHURCH_Z + 6.0)
	player.face(Vector3(-Petrion.HALF, 1.5, Petrion.CHURCH_Z))
	for k in 2:
		var s := Person.new({"coat": [Color("6a5040"), Color("5a6a7a")][k], "pants": Color("e8e0d0"), "hat": "bork", "mustache": true,
			"beard": k == 1, "skin": Color("c89070")})
		s.set_meta("spk", "SPK_SAILOR")
		s.position = Vector3(-Petrion.HALF + 0.9, 0, Petrion.CHURCH_Z - 0.8 + k * 1.6)
		s.rotation.y = -PI * 0.5
		add_child(s)
		Props.cyl(s, 0.03, 0.9, Vector3(0.3, 1.2, 0.3), Color("6a4a2c"), Vector3(-30, 0, 0), 5)
		Props.box(s, Vector3(0.05, 0.2, 0.25), Vector3(0.3, 1.6, 0.55), Color("6a6a70"))
		Props.interactable(s, "sailor", Vector3(1.4, 2.0, 1.4), Vector3(0, 1.0, 0))
		sailors.append(s)
	await hud.fade_to(0.0, 0.4)
	await hud.say("SPK_PRIEST", "D39O_PR_01")
	await hud.say("SPK_TOLGA", "D39O_T_03")
	await hud.say("SPK_SAILOR", "D39O_SA_01")
	player.frozen = false
	var t := 0.0
	var axe_t := 0.0
	var far_said := false
	var late := GameState.autotest_variant == "late"
	while true:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		# Kapı: baltalar sırayla iner (tezkire gösterilmişse bekler)
		if _tez_pause > 0.0:
			_tez_pause -= dt
		else:
			door_hp = maxf(0.0, door_hp - DOOR_RATE * dt)
			axe_t -= dt
			if axe_t <= 0.0:
				axe_t = 0.9
				_axe_swing()
		city.set_door_damage(3 if door_hp <= 0.0 else (2 if door_hp < 35.0 else (1 if door_hp < 70.0 else 0)))
		hud.set_chase(tr("UI_CH39O_DOOR"), door_hp / 100.0)
		# Hedef
		if not _cavus_follow:
			hud.set_objective(tr("UI_OBJ39O_FIND") if _asked or tez_used > 0 else tr("UI_OBJ39O_DOOR"), cavus.global_position + Vector3(0, 2.2, 0) if _asked else Vector3.INF)
		else:
			hud.set_objective(tr("UI_OBJ39O_LEAD"), Vector3(-Petrion.HALF + 1.0, 2.0, Petrion.CHURCH_Z))
			# Çavuş uzun adımlarla izler; 12 m'den fazla açılırsan durur
			var d := player.global_position - cavus.global_position
			d.y = 0.0
			if d.length() > 12.0:
				if not far_said:
					far_said = true
					hud.bark("SPK_CAVUS", "D39O_C_FAR", 2.5)
			elif d.length() > 1.6:
				far_said = false
				# Kuyunun, arabanın içinden geçmez: önü kapalıysa yanından dolanır
				cavus.global_position += Unclip.free_step(cavus, d.normalized() * minf(d.length() - 1.6, 3.2 * dt))
				cavus.rotation.y = atan2(d.x, d.z)
			if cavus.global_position.distance_to(Vector3(-Petrion.HALF + 1.0, 0, Petrion.CHURCH_Z)) < 7.0:
				break
		# Çekişme: kapı çubuğu 25'in altındaysa balta sapını kavra
		if _struggle_req:
			_struggle_req = false
			await _struggle()
		if door_hp <= 0.0 and not door_broke:
			door_broke = true
			Audio.sfx("land_thud", -2.0, 0.8)
			Vfx.dust(self, Vector3(-Petrion.HALF, 1.2, Petrion.CHURCH_Z), 1.2)
		if door_broke and t > 40.0 and not _cavus_follow:
			# Çavuş gürültüyü duyup gelir (tarih değişmez)
			_cavus_follow = true
		# Bot
		if GameState.autotest:
			if late and not door_broke:
				pass
			elif tez_used < 2 and _tez_pause <= 0.0 and t > 1.0 and not late:
				_on_interact("sailor")
			elif not _asked:
				# Oyuncu gibi: kapıdaki adamın yanına gidip ona sorar (eskiden uzaktan, arkası dönük soruyordu)
				var tw: Node3D = townsfolk[1]
				player.global_position = tw.global_position + tw.global_transform.basis.z * 1.3 + Vector3(0, 0.05, 0)
				player.face(tw.global_position + Vector3(0, 1.5, 0))
				_ask(1)
			elif not _cavus_follow:
				player.global_position = cavus.global_position + Vector3(0, 0.05, 1.4)
				_on_interact("cavus")
			else:
				var goal := Vector3(-0.5, 0.05, Petrion.CHURCH_Z + 2.5)
				if player.global_position.distance_to(cavus.global_position) > 6.0:       # çavuşu geride bırakma: geri dön
					goal = Vector3(cavus.global_position.x, player.global_position.y, cavus.global_position.z)
				if absf(player.global_position.z - Petrion.RUBBLE_Z) < 3.0 and player.global_position.x < 3.2:
					goal = Vector3(3.6, player.global_position.y, player.global_position.z)        # molozun yanındaki aralıktan
				player.global_position = player.global_position.move_toward(goal, dt * 4.0)
				if player.global_position.distance_to(goal) > 0.5:
					player.face(goal + Vector3(0, 1.6, 0))
				if door_hp < 25.0 and struggles_won == 0 and not late:
					_struggle_req = true
		if t > 160.0:
			break
	hud.set_chase("", 0.0)
	hud.set_objective("")
	player.frozen = true
	cavus.global_position = Vector3(-Petrion.HALF + 1.7, 0.0, Petrion.CHURCH_Z + 2.0)
	player.global_position = Vector3(0.6, 0.05, Petrion.CHURCH_Z + 4.2)
	player.face(cavus.global_position + Vector3(0, 1.6, 0))
	await hud.say("SPK_CAVUS", "D39O_C_03")
	if door_broke:
		await hud.say("SPK_TOLGA", "D39O_T_DOOR_BROKE")
	await hud.say("SPK_SAILOR", "D39O_SA_02")
	for s in sailors:
		var tw := s.create_tween()
		tw.tween_property(s, "global_position:x", 1.0, 1.5)
	await hud.say("SPK_CAVUS", "D39O_C_04")
	await hud.say("SPK_TOLGA", "D39O_T_04")
	await hud.say("SPK_PRIEST", "D39O_PR_02")
	await hud.say("SPK_TOLGA", "D39O_T_05")


func _axe_swing() -> void:
	if sailors.is_empty():
		return
	var s: Person = sailors[randi() % sailors.size()]
	s.look_target = null
	s.rotation.y = -PI * 0.5
	if s.rig:
		s.rig.lock += 1
		var tw := s.create_tween()
		tw.tween_property(s.rig.arm_r, "rotation", Vector3(-2.6, 0, 0.2), 0.25)
		tw.tween_property(s.rig.arm_r, "rotation", Vector3(-0.6, 0, 0.1), 0.12)
		tw.tween_callback(func():
			if is_instance_valid(s) and s.rig:
				s.rig.lock = maxi(s.rig.lock - 1, 0))
	Audio.sfx("chop", -6.0, randf_range(0.9, 1.1))
	# Kıymık
	Props.ball(self, 0.05, Vector3(-Petrion.HALF + 0.1, randf_range(1.0, 2.2), Petrion.CHURCH_Z + randf_range(-0.6, 0.6)), Color("8a6a4a"), Vector3(1, 0.4, 2), 4)


func _show_tez() -> void:
	await hud.say("SPK_TOLGA", "D39O_T_TEZ")
	hud.bark("SPK_SAILOR", "D39O_SA_TEZ", 4.0)
	# Tezkire: elde kâğıt ve mühür (kısa)
	var paper := Node3D.new()
	paper.position = Vector3(0.1, -0.25, -0.5)
	player.camera.add_child(paper)
	Props.box(paper, Vector3(0.2, 0.26, 0.01), Vector3.ZERO, Color("e8dcc0"))
	Props.cyl(paper, 0.03, 0.01, Vector3(0, -0.08, 0.01), Color("b3262d"), Vector3(90, 0, 0), 10)
	Props.strip_outlines(paper)
	get_tree().create_timer(2.0).timeout.connect(paper.queue_free)


func _ask(k: int) -> void:
	if _asked:
		return
	_asked = true
	await hud.say("SPK_TOWNSMAN", "D39O_TW_POINT")


## Balta sapında çekişme: üç iyi çekiş = balta Tolga'da (+12 sn); kötü çekişte itilir (−15 can)
func _struggle() -> void:
	if struggles_won > 0:
		return
	hud.set_qte(tr("UI_OBJ39O_STRUGGLE"))
	_strokes.clear()
	meter.enabled = true
	var good := 0
	var t := 0.0
	while good < 3 and t < 10.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		if Input.is_action_just_pressed("jump"):
			meter.press()
		while _strokes.size() > 0:
			if _strokes.pop_front():
				good += 1
				Fx.trauma(0.2)
			else:
				player.hurt(15.0, sailors[0].global_position if sailors.size() > 0 else Vector3.INF)
				player.stagger(1.0)
				hud.bark("SPK_TOLGA", "D39O_T_STRUGGLE_BAD", 2.0)
	meter.enabled = false
	hud.set_qte("")
	if good >= 3:
		struggles_won += 1
		door_hp = minf(100.0, door_hp + 24.0)      # +12 sn
		hud.bark("SPK_TOLGA", "D39O_T_STRUGGLE_OK", 3.0)


# ---------------------------------------------------------------- 3. yangın

var _man_follow := false
var _lowered := false
var _tile_t := 6.0


func _fire() -> void:
	phase = "fire"
	await hud.say("SPK_PRIEST", "D39O_PR_FIRE")
	var fh := Petrion.FIRE_HOUSE
	var flames: Array = []
	for k in 3:
		flames.append(Vfx.fire(city, Vector3(fh.x - 3.0, 6.6, fh.z - 2.4 + k * 2.4), 1.2))
	flames.append(Vfx.fire(city, Vector3(fh.x + 0.4, 0.2, fh.z), 0.8))       # kapı alevli
	old_man = Person.new({"coat": Color("6a5a48"), "pants": Color("3a3028"), "beard": true, "hair": Color("e0e0d8"), "skin": Color("d8b090")})
	old_man.set_meta("spk", "SPK_TOWNSMAN")
	old_man.set_meta("climber", true)
	add_child(old_man)
	old_man.global_position = city.fire_room + Vector3(-1.0, 0.0, -1.6)
	old_man.set_activity("sit_ground")
	Props.interactable(old_man, "oldman", Vector3(1.4, 1.6, 1.4), Vector3(0, 0.8, 0))
	await hud.say("SPK_TOLGA", "D39O_T_FIRE")
	player.frozen = false
	roof_left = ROOF_TIME
	var smoke_in := false
	var lower_prog := 0.0
	var bal := 0.0
	var late := GameState.autotest_variant == "late"
	var e := _env()
	var fog0 := e.fog_density if e else 0.0
	while roof_left > 0.0 and not _lowered:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		roof_left -= dt
		var p := player.global_position
		var inside := p.y > Petrion.ROOM_Y - 0.3 and absf(p.x) > Petrion.HALF + 0.2 and absf(p.z - fh.z) < 3.8
		if inside != smoke_in:
			smoke_in = inside
			if e:
				create_tween().tween_property(e, "fog_density", 0.07 if inside else fog0, 0.6)
			if inside:
				hud.bark("SPK_TOLGA", "D39O_T_SMOKE", 3.0)
		if inside:
			var stoop := Input.is_action_pressed("dive") or GameState.autotest
			player.eye_height = lerpf(player.eye_height, 0.9 if stoop else Player.EYE, dt * 8.0)
			player.hurt((1.0 if stoop else 2.0) * dt * (0.5 if late else 1.0), Vector3.INF, true)
			if fmod(roof_left, 2.0) < dt:
				Audio.sfx("cough", -10.0, 0.8)
		else:
			player.eye_height = lerpf(player.eye_height, Player.EYE, dt * 8.0)
		hud.set_objective((tr("UI_OBJ39O_FIRE") % ceili(roof_left)) if not inside else (tr("UI_OBJ39O_SMOKE") if not _man_follow else tr("UI_OBJ39O_LOWER")),
			city.bay_top + Vector3(0, 1.2, 0) if not inside else (old_man.global_position + Vector3(0, 1.0, 0) if not _man_follow else city.lower_window + Vector3(0, 1.0, 0)))
		# Düşen kiremitler (evin önündeyken)
		if not inside and absf(p.z - fh.z) < 6.0 and absf(p.x - fh.x) < 4.0:
			_tile_t -= dt
			if _tile_t <= 0.0:
				_tile_t = randf_range(3.0, 4.5)
				_drop_tile(p)
		# Adam kolundan tutulunca yanında yürür
		if _man_follow:
			old_man.set_activity("")
			var to := player.global_position + (player.global_position - old_man.global_position).normalized() * -0.9
			old_man.global_position = old_man.global_position.move_toward(Vector3(to.x, Petrion.ROOM_Y, to.z), dt * 1.2)
			# Pencerede: iple indir (E basılı, denge)
			if player.global_position.distance_to(city.lower_window) < 1.8:
				var hold := Input.is_action_pressed("interact") or GameState.autotest
				balance.visible = true
				var input := Input.get_axis("move_left", "move_right")
				if GameState.autotest:
					input = -signf(bal) * 0.9 if absf(bal) > 0.1 else 0.0
				bal += (sin(roof_left * 2.1) * 0.5 + input * 1.4) * dt
				balance.value = bal
				if absf(bal) >= 1.0:
					bal = 0.0
					roof_left -= 3.0
					hud.bark("SPK_SAILOR", "D39O_SA_ROPE", 1.5)
				if hold:
					lower_prog += dt / 6.0
					var down := city.lower_window + Vector3(signf(city.lower_window.x) * -0.6, -lower_prog * Petrion.ROOM_Y, 0)
					old_man.global_position = down
				if lower_prog >= 1.0:
					_lowered = true
		# Bot
		if GameState.autotest:
			if not inside and not _man_follow:
				player.global_position = city.bay_top + Vector3(0, 0.05, 0)
				await get_tree().create_timer(0.3).timeout
				player.global_position = city.fire_room + Vector3(0, 0.05, 0)
			elif not _man_follow:
				player.global_position = old_man.global_position + Vector3(0.8, 0.05, 0.8)
				player.face(old_man.global_position + Vector3(0, 0.6, 0))
				await get_tree().create_timer(0.6 if not late else 25.0).timeout
				_on_interact("oldman")
			else:
				var wgoal := city.lower_window + Vector3(signf(city.lower_window.x) * 1.0, 0.05, 0)       # pencerenin iç tarafı
				player.global_position = player.global_position.move_toward(wgoal, dt * 3.0)
				player.face(city.lower_window + Vector3(-signf(city.lower_window.x) * 2.0, 0.2, 0))
	balance.visible = false
	if e:
		create_tween().tween_property(e, "fog_density", fog0, 0.6)
	player.eye_height = Player.EYE
	hud.set_objective("")
	player.frozen = true
	if not _lowered:
		roof_fell = true
		Audio.sfx("land_thud", 0.0, 0.5)
		Fx.trauma(0.8)
		await hud.say("SPK_JANISSARY", "D39O_J_ROOF")
	else:
		# İpi aşağıda tutan tayfa sokaktan seslenir (Tolga dumanlı odada, pencerenin içinde): döngüdeki gibi haykırış
		# (eskiden kilisenin önündeki tayfanın konuşması evin duvarının ardından geliyordu)
		hud.bark("SPK_SAILOR", "D39O_SA_ROPE", 2.5)
		await get_tree().create_timer(1.6).timeout
	await hud.fade_to(1.0, 0.5)
	for f in flames:
		if is_instance_valid(f):
			(f as Node3D).queue_free()
	Vfx.smolder(city, Vector3(fh.x - 3.0, 6.4, fh.z), 1.4, false)
	old_man.set_activity("sit_ground")
	old_man.global_position = Vector3(-1.5, 0.0, fh.z + 3.0)
	player.global_position = Vector3(0.6, 0.05, fh.z + 4.0)
	player.face(priest.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.5)
	await hud.say("SPK_PRIEST", "D39O_PR_03")


func _drop_tile(at: Vector3) -> void:
	hud.bark("SPK_SAILOR", "D39O_S_TILE", 1.4)
	var g := Props.cyl(self, 0.6, 0.02, Vector3(at.x, 0.03, at.z), Color(0, 0, 0), Vector3.ZERO, 12)
	g.material_override = Props.mat(Color(0.05, 0.05, 0.05), 0.0, false, "", false)
	var tile := Props.box(self, Vector3(0.4, 0.06, 0.3), Vector3(at.x, 7.0, at.z), Color("9a4a32"))
	var tw := tile.create_tween()
	tw.tween_property(tile, "position:y", 0.1, 1.0).set_ease(Tween.EASE_IN)
	await tw.finished
	if is_instance_valid(g):
		g.queue_free()
	Vfx.dust(self, Vector3(at.x, 0.1, at.z), 0.4)
	Audio.sfx("pick_tap", -4.0, 0.7)
	if is_instance_valid(tile):
		tile.queue_free()
	if Vector2(player.global_position.x - at.x, player.global_position.z - at.z).length() < 0.7 and phase == "fire":
		player.hurt(20.0, at + Vector3(0, 5, 0))


func _env() -> Environment:
	for c in get_children():
		if c is WorldEnvironment:
			return (c as WorldEnvironment).environment
	return null


# ---------------------------------------------------------------- 4. nöbet

var _sat := false


func _watch() -> void:
	phase = "watch"
	var fire_at := Vector3(-1.2, 0.0, Petrion.CHURCH_Z + 4.5)
	city.lights.append(Night.campfire(self, fire_at, 0.7))
	Props.interactable(self, "watchfire", Vector3(2.4, 1.4, 2.4), fire_at + Vector3(0, 0.6, 0))
	var jan := Soldier.new(Color("b3262d"), "stand", "bork")
	jan.set_meta("spk", "SPK_JANISSARY")
	add_child(jan)
	jan.position = fire_at + Vector3(1.2, 0, -0.6)
	jan.set_activity("sit") if jan.has_method("set_activity") else null
	var door_guard := Soldier.new(Color("b3262d"), "stand", "bork")
	add_child(door_guard)
	door_guard.position = Vector3(-Petrion.HALF + 0.8, 0, Petrion.CHURCH_Z - 1.6)
	door_guard.rotation.y = PI * 0.5
	door_guard.equip("spear")
	priest.global_position = Vector3(-Petrion.HALF + 0.6, 0, Petrion.CHURCH_Z + 0.4)
	var candle := Props.cyl(priest, 0.02, 0.12, Vector3(0.25, 1.15, 0.2), Color("f0e6c8"), Vector3.ZERO, 6)
	candle.material_override = Props.mat(Color("ffd890"), 2.5, false, "", false)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ39O_SIT"), fire_at + Vector3(0, 1.4, 0))
	var t := 0.0
	while not _sat and t < 60.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest and t > 0.5:
			_sat = true
	hud.set_objective("")
	player.frozen = true
	player.global_position = fire_at + Vector3(-1.0, 0.05, 0.6)
	player.eye_height = 0.95
	player.face(jan.global_position + Vector3(0, 1.0, 0))
	await hud.say("SPK_JANISSARY", "D39O_J_01")
	await hud.say("SPK_SAILOR", "D39O_SA_03")
	var pick := await hud.choose(["UI_C39O_KNOW", "UI_C39O_WALL", "UI_C39O_WRITE"], 0.0, 2)
	emperor_answer = ["know", "wall", "write"][clampi(pick, 0, 2)]
	GameState.flags["emperor_answer"] = emperor_answer
	await hud.say("SPK_JANISSARY", {"know": "D39O_J_KNOW", "wall": "D39O_J_WALL", "write": "D39O_J_WRITE"}[emperor_answer])
	await hud.say("SPK_NIHAT", "D39O_N_EMP")
	player.eye_height = Player.EYE
	# Tespit: kilisenin kapısında nöbet
	var target := Node3D.new()
	add_child(target)
	target.global_position = Vector3(-Petrion.HALF, 1.8, Petrion.CHURCH_Z)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ39O_PHOTO"), target.global_position + Vector3(0, 1.0, 0))
	hud.bark("SPK_NIHAT", "D39O_N_PHOTO", 4.0)
	cam = TespitCam.new(player, hud, target, "siege39o")
	hud.add_child(cam)
	cam.max_dist = 30.0
	cam.cone_deg = 14.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	t = 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 60.0):
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest:
			player.face(target.global_position)
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	if not _photo.is_empty():
		await hud.say("SPK_NIHAT", "D39O_N_PHOTO_OK")
	await hud.say("SPK_CAVUS", "D39O_C_END")
	await hud.say("SPK_TOLGA", "D39O_T_END")
	await hud.say("SPK_NIHAT", "D39O_N_END")
	var ok := flags_done >= 5 and not door_broke and not roof_fell
	_outcome = "39O.1" if ok else "39O.2"
	Siege.record(39, _photo, "SIEGE_NOTE_39O_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	player.disable_climb()
	GameState.set_outcome(39, _outcome)
	await Siege.show_page(hud, 39)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(39)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW39O_TITLE")
	c.nodes = [
		{"id": "gate", "key": "FLOW39O_GATE", "pos": Vector2(0.5, 0.1)},
		{"id": "flags", "key": "FLOW39O_FLAGS", "pos": Vector2(0.5, 0.22)},
		{"id": "door", "key": "FLOW39O_DOOR", "pos": Vector2(0.5, 0.34)},
		{"id": "fire", "key": "FLOW39O_FIRE", "pos": Vector2(0.5, 0.46)},
		{"id": "watch", "key": "FLOW39O_WATCH", "pos": Vector2(0.5, 0.58)},
		{"id": "39O.1", "key": "FLOW_39O_1", "pos": Vector2(0.3, 0.72), "outcome": true},
		{"id": "39O.2", "key": "FLOW_39O_2", "pos": Vector2(0.7, 0.72), "outcome": true},
	]
	c.edges = [["gate", "flags"], ["flags", "door"], ["door", "fire"], ["fire", "watch"], ["watch", "39O.1"], ["watch", "39O.2"]]
	for k in ["gate", "flags", "door", "fire", "watch"]:
		c.taken[k] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		Grade.finish("39o"),
		tr("UI_CH39O_STATS") % [flags_done, 6, int(door_hp), int(maxf(roof_left, 0.0)), Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "39O.1", "late": "39O.2"}.get(v, "39O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("39", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and emperor_answer == "write"
	if v == "":
		ok = ok and flags_done == 6 and wrong_doors == 0 and not door_broke and _lowered and cam.done
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s sancak=%d/%d kayıp=%d kapı=%.0f kırıldı=%s indi=%s çatı=%.0f foto=%s)" % [expected, _outcome,
			not page.is_empty(), flags_done, 6, flags_lost, door_hp, door_broke, _lowered, roof_left, cam != null and cam.done])
	print("AUTOTEST %s chapter=39o variant=%s outcome=%s flags=%d/6 lost=%d wrong=%d door=%.0f broke=%s tez=%d struggle=%d lowered=%s roof=%.0f answer=%s" % [
		"PASS" if ok else "FAIL", v, _outcome, flags_done, flags_lost, wrong_doors, door_hp, door_broke, tez_used, struggles_won, _lowered, roof_left, emperor_answer])
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
	player.global_position = Vector3(0.6, 0.05, -6.0)
	player.face(Vector3(0.0, 1.6, -30.0))
	_plant_flag(Petrion.LISTED[0], Color("b3262d"))
	await get_tree().create_timer(0.8).timeout
	await _shot_png("c39o_01_street.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(3.4, 1.7, Petrion.FIRE_HOUSE.z + 6.5)
	cv.look_at(Vector3(-Petrion.HALF - 1.0, 4.6, Petrion.FIRE_HOUSE.z - 2.0), Vector3.UP)
	cv.fov = 62.0
	cv.make_current()
	var fh := Petrion.FIRE_HOUSE
	for k in 3:
		Vfx.fire(city, Vector3(fh.x - 3.0, 6.6, fh.z - 2.4 + k * 2.4), 1.2)
	Vfx.fire(city, Vector3(fh.x + 0.4, 0.2, fh.z), 0.8)
	var man := Person.new({"coat": Color("6a5a48"), "pants": Color("3a3028"), "beard": true, "hair": Color("e0e0d8")})
	add_child(man)
	man.global_position = city.lower_window + Vector3(0.6, -1.4, 0)
	var rope := Props.cyl(self, 0.02, 1.6, city.lower_window + Vector3(0.5, 0.6, 0), Color("b89a6a"), Vector3.ZERO, 4)
	rope.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	await get_tree().create_timer(1.2).timeout
	await _shot_png("c39o_cover.png")
	get_tree().quit()
