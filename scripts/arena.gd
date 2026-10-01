extends Node3D
## Sonsuz Kuşatma (tekrar oynanır mod): Mesoteichion gediği, dalga dalga kılıç dövüşü.
##   Bizans tarafı ("B"): Sur Savunması — gediği tut; Osmanlılar moloz yamacından iner.
##   Osmanlı tarafı ("O"): Hücum — yamacın tepesindesin; savunucular içeriden gelir.
## Her dalgada rakip sayısı ve ustalığı artar; dalga arasında can biraz dolar. Rekor kalıcıdır (GameState.stats).
##   --autotest[=osm]   (bot üç dalga oynar)

const WAVE_BREAK := 3.0

var walls: LandWalls
var player: Player
var hud: Hud
var duel: Duel
var side := "B"
var wave := 0
var kills := 0
var best := 0
var over := false
var _spawn_line: Array[Vector3] = []
var _start: Vector3
var _face: Vector3
## Her üç dalgada bir değiştirici: "fatigue" (dayanıklılık yavaş dolar), "veterans" (rakip usta, darben ağır),
## "shahi" (dalga boyunca Şahi topu gediğe atar: düştüğü yerde durma)
const MODS := ["fatigue", "veterans", "shahi"]
var mod := ""


func _ready() -> void:
	side = String(GameState.flags.get("arena_side", "B"))
	if GameState.autotest and GameState.autotest_variant == "osm":
		side = "O"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arena="):
			side = a.trim_prefix("--arena=")
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(side == "O")
	hud.set_signal(0)
	walls = LandWalls.new()
	add_child(walls)
	walls.set_repair(3)
	walls.make_dawn(0.01)
	# Oyun alanı: gedik önü ve peribolos; sınırlar görünmez duvar
	var zc := LandWalls.BREACH.z
	for spec in [[Vector3(0.4, 6, 30), Vector3(-9.0, 3, zc - 4.0)], [Vector3(0.4, 6, 30), Vector3(9.0, 3, zc - 4.0)],
			[Vector3(18, 6, 0.4), Vector3(0, 3, zc - 16.0)], [Vector3(18, 6, 0.4), Vector3(0, 3, zc + 6.5)]]:
		var b := Props.solid(self, spec[0], spec[1], Color.WHITE)
		b.get_child(0).visible = false
		b.set_meta("no_climb", true)
	if side == "B":
		_start = Vector3(0, 0.05, zc - 6.0)
		_face = LandWalls.BREACH + Vector3(0, 2.0, 0)
		_spawn_line = [Vector3(-2.5, 0, zc + 3.5), Vector3(0, 0, zc + 4.0), Vector3(2.5, 0, zc + 3.5)]
	else:
		_start = Vector3(0, 0.05, zc - 5.5)
		_face = Vector3(0, 1.5, zc - 14.0)
		_spawn_line = [Vector3(-3.0, 0, zc - 12.0), Vector3(0, 0, zc - 13.0), Vector3(3.0, 0, zc - 12.0)]
	duel = Duel.new()
	hud.add_child(duel)
	duel.finished.connect(_on_finished)
	best = int(GameState.stats.get("arena_best_" + side, 0))
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
		return
	_run()


func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_ARENA_TITLE_" + side), 44, Color("f2e6c9")], [tr("UI_ARENA_SUB") % best, 20, Color(1, 1, 1, 0.7)]], 2.4)
	hud.clear_card()
	player.global_position = _start
	player.face(_face)
	if not GameState.autotest:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await hud.fade_to(0.0, 0.8)
	hud.bark("SPK_NIHAT", "D_ARENA_N_" + side, 4.0)
	player.frozen = false
	while not over:
		wave += 1
		await _wave()
		if over:
			break
		if GameState.autotest and wave >= 3:
			_report(true)
			return
		duel.hp = minf(100.0, duel.hp + 30.0)
		await hud.card([[tr("UI_ARENA_WAVE_DONE") % wave, 28, Color("ffd070")]], WAVE_BREAK)
		hud.clear_card()
	await _game_over()


func _wave() -> void:
	var n := mini(1 + wave / 2, 3)
	var skill := minf(0.25 + wave * 0.07, 0.92)
	mod = MODS[(wave / 3 - 1) % MODS.size()] if wave % 3 == 0 else ""
	if GameState.autotest and GameState.autotest_variant == "mods":
		mod = MODS[(wave - 1) % MODS.size()]      # test: üç dalgada üç değiştirici
	duel.stamina_regen = 0.55 if mod == "fatigue" else 1.0
	duel.dmg_mult = 1.3 if mod == "veterans" else 1.0
	if mod == "veterans":
		skill = minf(skill + 0.12, 0.95)
	if mod != "":
		await hud.card([[tr("UI_ARENA_MOD_" + mod.to_upper()), 26, Color("ff9a6a")]], 1.6)
		hud.clear_card()
	hud.set_objective(tr("UI_ARENA_WAVE") % [wave, n])
	Audio.sfx("crowd_camp", -2.0, 0.9 + wave * 0.02)
	var list: Array[Duelist] = []
	for i in n:
		var d := _make_enemy(skill)
		add_child(d)
		d.position = _spawn_line[i % _spawn_line.size()]
		d.rotation.y = PI if side == "B" else 0.0
		list.append(d)
	duel.start(player, list, "spathion" if side == "B" else "kilij")
	if mod == "shahi":
		_shahi_loop(wave)
	var won: bool = await duel.finished
	for d in list:
		var tw := create_tween()
		tw.tween_interval(1.5)
		tw.tween_callback(d.queue_free)
	kills += duel.kills
	duel.kills = 0
	hud.set_objective("")
	if not won:
		over = true


## Şahi dalgası: her 9-13 sn'de uyarı, ağır çekim, gülle oyuncunun 3 m yakınına iner; dibindeysen can gider.
func _shahi_loop(w: int) -> void:
	while is_inside_tree() and duel.active and wave == w:
		await get_tree().create_timer(randf_range(9.0, 13.0)).timeout
		if not duel.active or wave != w:
			return
		hud.bark("SPK_LOOKOUT", "D20_L_WARN_1", 2.0)
		Audio.stinger("warn", -6.0)
		Fx.slowmo(0.5, 1.4, 0.4)
		var at := player.global_position + Vector3(randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0))
		Vfx.dust(self, at + Vector3(0, 0.1, 0), 0.4)
		await get_tree().create_timer(1.6).timeout
		if not duel.active:
			return
		walls.fire_flash()
		walls.impact(at + Vector3(0, 0.6, 0))
		Audio.sfx("explosion_big", -3.0)
		if player.global_position.distance_to(at) < 2.2:
			duel.hp = maxf(0.0, duel.hp - 25.0)
			Fx.edge(Color("ff2a1a"), 0.8, 0.6)
			player.stagger(0.8)
			if duel.hp <= 0.0:
				duel.stop()
				duel.finished.emit(false)


func _make_enemy(skill: float) -> Duelist:
	var d: Duelist
	if side == "B":
		# Osmanlı: azap (sarık), Anadolu askeri, yeniçeri (börk); yüksek dalgalarda daha çok yeniçeri
		var jan := randf() < clampf((wave - 2) * 0.2, 0.0, 0.8)
		var coat: Color = Color("2f5fa8") if jan else [Color("8a6a4a"), Color("6a4a3a"), Color("b3262d")][randi() % 3]
		d = Duelist.new({"coat": coat, "pants": Color("e8e0d0"), "hat": "bork" if jan else "turban", "mustache": true, "beard": randf() < 0.4},
			"kilij", skill, false)
		d.name_key = "SPK_JANISSARY" if jan else "SPK_AZAP"
	else:
		var genoese := randf() < 0.35
		d = Duelist.new({"coat": Color("8a8e96") if genoese else [Color("7a2a24"), Color("5a6a7a"), Color("6a5a3a")][randi() % 3],
			"pants": Color("3a2a22"), "hat": "helm", "beard": randf() < 0.6, "mustache": true}, "spathion", skill, true)
		d.name_key = "SPK_GENOESE" if genoese else "SPK_DEFENDER"
	d.damage = 14.0 + wave * 1.5
	d.max_hp = 70.0 + wave * 6.0
	d.hp = d.max_hp
	return d


func _on_finished(_won: bool) -> void:
	pass


func _game_over() -> void:
	player.frozen = true
	var survived := wave - 1
	if survived > best:
		best = survived
		GameState.bump_stat("arena_best_" + side, survived, true)
	await hud.fade_to(0.6, 0.8)
	await hud.card([[tr("UI_ARENA_OVER"), 40, Color("ff7a5a")],
		[tr("UI_ARENA_RESULT") % [survived, kills, duel.parries, best], 22, Color("f2e6c9")],
		[tr("UI_ARENA_AGAIN"), 18, Color(1, 1, 1, 0.7)]], 0.0)
	if GameState.autotest:
		_report(false)
		return
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("continue") or Input.is_action_just_pressed("advance"):
			get_tree().reload_current_scene()
			return
		if Input.is_action_just_pressed("pause"):
			GameState.skip_title = false
			GameState.change_scene("res://scenes/chapter1.tscn")
			return


func _report(ok: bool) -> void:
	Engine.time_scale = 1.0
	var pass_ := ok and wave >= 3 and kills >= 4
	# Osmanlı arenasında rakipler kalkanlı: bot tekmeyle kalkan açmayı denemiş olmalı
	if side == "O":
		pass_ = pass_ and duel.kicks >= 1
	if not pass_:
		printerr("AUTOTEST: dalga=%d öldürülen=%d can=%.0f" % [wave, kills, duel.hp])
	print("AUTOTEST %s arena side=%s waves=%d kills=%d parries=%d kicks=%d finishers=%d hp=%.0f" % ["PASS" if pass_ else "FAIL", side, wave,
		kills, duel.parries, duel.kicks, duel.finishers, duel.hp])
	get_tree().quit(0 if pass_ else 1)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.global_position = _start
	player.face(_face)
	var list: Array[Duelist] = []
	for i in 2:
		var d := _make_enemy(0.5)
		add_child(d)
		d.position = _spawn_line[i] + (Vector3(0, 0, -2.5) if side == "B" else Vector3(0, 0, 7.0))
		list.append(d)
	duel.start(player, list, "spathion" if side == "B" else "kilij")
	player.frozen = false
	await get_tree().create_timer(1.2).timeout
	list[0].state = Duelist.St.WINDUP
	list[0].dir = Duelist.DIR_RIGHT
	list[0]._t = 0.0
	list[0].windup_time = 3.0
	duel.aim = Duelist.DIR_LEFT
	player.face(list[0].global_position + Vector3(0, 1.4, 0))
	duel.blocking = true
	await get_tree().create_timer(1.6).timeout
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join("arena_%s_01.png" % side))
	print("shot: arena_%s_01.png" % side)
	duel.attack(Duelist.DIR_TOP)
	await get_tree().create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join("arena_%s_02.png" % side))
	print("shot: arena_%s_02.png" % side)
	if "--poses" in OS.get_cmdline_user_args():
		var e := list[0]
		e.global_position = player.global_position + (-player.global_transform.basis.z) * 2.4
		e.global_position.y = 0.0
		list[1].visible = false
		for st in ["guard", "windup"]:
			for dd in 3:
				if st == "guard":
					e.state = Duelist.St.IDLE
					e.guard = dd
					e._guard_want = dd
					duel.aim = dd
					e._think = 99.0
				else:
					e.state = Duelist.St.WINDUP
					e.dir = dd
					e._t = 0.0
					e.windup_time = 99.0
					e._feint = false
				await get_tree().create_timer(0.6).timeout
				await RenderingServer.frame_post_draw
				get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join("pose_%s_%d.png" % [st, dd]))
	get_tree().quit()
