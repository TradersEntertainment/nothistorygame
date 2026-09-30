extends "res://scripts/chapter26.gd"
## Bölüm 26 (Osmanlı tarafı) — Şafak (Tolga · 29 Mayıs 1453, hendeğin önü).
##
## Son hücumun dışarıdan görünüşü. Tolga sakadır (sucu): hendek kıyısında bekleyen askerlere su taşır.
##   1. dalga (azaplar): fıçıdan kıyıdaki üç bölüğe su · 2. dalga (Anadolu askeri): merdiven yığınından kıyıya üç merdiven;
##   surdan ok yağarken "Siper!" · 3. dalga (yeniçeriler, şafak): Hasan'a su verilir; Hasan sancakla gediğe koşar.
##   Tespit: burçtaki sancak. Öğleden sonra Ayasofya ve kapanış Bölüm 26 ile ortaktır (sonuçlar 26.1 / 26.2).
##   --autotest[=nophoto]   (varsayılan: 26.1)

const EDGE_Z := 37.4
const O_WATER := Vector3(9.0, 0.0, 50.0)
const O_LADDERS := Vector3(-11.0, 0.0, 51.0)
const SQUADS := [Vector3(-8.0, 0.0, 39.0), Vector3(0.0, 0.0, 39.0), Vector3(8.0, 0.0, 39.0)]
const O_COVERS := [Vector3(-5.0, 0.0, 44.0), Vector3(4.0, 0.0, 44.0), Vector3(9.0, 0.0, 50.0), Vector3(-11.0, 0.0, 51.0)]
const VOLLEY_EVERY := 20.0
const VOLLEY_WARN := 3.0

var hasan: Person
var squads: Array = []
var o_ladders := 0
var arrows := 0
var _volley := VOLLEY_EVERY
var _vwarn := -1.0
var hasan_water := false
var banner_photo := ""
var banner_done := false


func _ready() -> void:
	GameState.snapshot(26)
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
	walls.assault_mode = true
	add_child(walls)
	walls.set_repair(LandWalls.STAGES - 3)
	_build_walls_scene()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build_walls_scene() -> void:
	# Hendeğin dışı: yürünebilir zemin ve alan sınırları (LandWalls'ın ovası yalnız görüntüdür)
	Props.solid(self, Vector3(64, 0.4, 42), Vector3(0, -0.2, 57.0), Color("3a3e2a")).get_child(0).visible = false
	for spec in [[Vector3(64, 6, 0.4), Vector3(0, 3, 36.4)], [Vector3(64, 6, 0.4), Vector3(0, 3, 78.0)],
			[Vector3(0.4, 6, 42), Vector3(-32, 3, 57.0)], [Vector3(0.4, 6, 42), Vector3(32, 3, 57.0)]]:
		var b := Props.solid(self, spec[0], spec[1], Color.WHITE)
		b.get_child(0).visible = false
		b.set_meta("no_climb", true)
	# Surda kaynar yağ kazanları: dalgalarda sur dibine, merdiven diplerine dökülür (yoldaşlar tutuşur, geri kaçar)
	fight = WallFight.new()
	add_child(fight)
	for x: float in [-20.6, -8.6, 8.6, 21.0]:      # kulelerin (x ±13.5..18.5) dışında: kazancı kulenin içine girmesin
		fight.add_cauldron(Vector3(x, LandWalls.OUTER_H, 15.0), 2690 + int(x))
	# Hendek kule önünde toprakla dolmuş (Bölüm 22o'nun sepetleri)
	Props.box(self, Vector3(10.0, 3.2, 16.0), FILL_C, Color("5a4630"))
	# Su fıçıları ve merdiven yığını
	for k in 2:
		Props.make_solid(Props.cyl(self, 0.55, 1.1, O_WATER + Vector3(k * 1.2, 0.55, 0), Color("6a4a2c"), Vector3.ZERO, 10))      # fıçı katı
		Props.cyl(self, 0.5, 0.05, O_WATER + Vector3(k * 1.2, 1.1, 0), Color("3a5a78"), Vector3.ZERO, 10)
	Props.interactable(self, "o_water", Vector3(2.8, 1.6, 1.8), O_WATER + Vector3(0.6, 0.8, 0))
	for k in 4:
		Props.make_solid(Props.box(self, Vector3(0.8, 0.12, 7.0), O_LADDERS + Vector3(0, 0.1 + k * 0.14, 0), Color("6a4a2c"), Vector3(0, k * 6.0, 0)))      # merdiven yığını katı
	Props.interactable(self, "o_ladder", Vector3(2.0, 1.4, 7.0), O_LADDERS + Vector3(0, 0.7, 0))
	for i in SQUADS.size():
		var g: Array = []
		for k in 3:
			var s := Soldier.new([Color("8a6a4a"), Color("6a4a3a"), Color("b3262d")][(i + k) % 3], "stand", "turban" if k % 2 == 0 else "bork")
			s.position = (SQUADS[i] as Vector3) + Vector3(-1.2 + k * 1.2, 0, 0.4 * (k % 2))
			s.rotation.y = PI
			add_child(s)
			s.equip(["spear", "sword_shield", "axe"][k])
			g.append(s)
		squads.append(g)
		Props.interactable(self, "squad_%d" % i, Vector3(4.0, 2.0, 2.0), (SQUADS[i] as Vector3) + Vector3(0, 1.0, 0))
	# Kıyıya dayanmayı bekleyen merdivenler (2. dalgada görünür)
	for i in 3:
		var l := Node3D.new()
		l.position = (SQUADS[i] as Vector3) + Vector3(0, 0, -1.6)
		l.rotation.x = deg_to_rad(88)
		l.visible = false
		add_child(l)
		for sx: float in [-0.35, 0.35]:
			Props.cyl(l, 0.05, 7.0, Vector3(sx, 3.5, 0), Color("6a4a2c"), Vector3.ZERO, 5)
		for k in 9:
			Props.box(l, Vector3(0.75, 0.05, 0.05), Vector3(0, 0.5 + k * 0.72, 0), Color("6a4a2c"))
		ladders.append(l)
	for x: float in [-14.0, -2.0, 12.0]:
		walls.lights.append(Night.torch(self, Vector3(x, 0, 47.0)))
	# Siperler: ok yağmurunda arkasına saklanılan büyük ahşap kalkanlar (pavez), yay şeklinde üçer tane
	for cp: Vector3 in [O_COVERS[0], O_COVERS[1]]:
		for k in 3:
			var a := -0.5 + k * 0.5
			var pv := Node3D.new()
			pv.position = cp + Vector3(sin(a) * 1.6, 0, -cos(a) * 1.6)
			pv.rotation = Vector3(deg_to_rad(-12), a, 0)
			add_child(pv)
			Props.solid(pv, Vector3(1.3, 2.1, 0.12), Vector3(0, 1.05, 0), Color("6a4a2c")).set_meta("no_climb", true)
			Props.box(pv, Vector3(1.35, 0.12, 0.16), Vector3(0, 1.7, 0.02), Color("4a3422"))
			Props.box(pv, Vector3(1.35, 0.12, 0.16), Vector3(0, 0.5, 0.02), Color("4a3422"))
			Props.box(pv, Vector3(0.45, 0.45, 0.02), Vector3(0, 1.2, -0.07), Color("b3262d"))
			Props.box(pv, Vector3(0.08, 1.6, 0.08), Vector3(0, 0.75, 0.5), Color("4a3422"), Vector3(-30, 0, 0))
	# Gerçek hücum: arkada ve yanlarda sancaklı ordu, sura koşan dalgalar, merdivenlerde tırmananlar,
	# ateş eden bataryalar, surda savunanlar, görünen ok yağmuru
	assault = Assault.new()
	assault.keep = Rect2(-32.0, 36.4, 64.0, 41.6)
	add_child(assault)
	assault.build()
	# Hendekte hasır kalkanını başına kaldırıp ilerleyen azaplar, yay ve mızrakla yeniçeri ve sipahiler; surdan inen
	# oklarla devrilenler; hendekte ve sur dibinde yatanlar (azaplar hücumun ilk dalgasıydı, kayıpları ağırdı)
	for lane: Array in [[Vector3(-26.0, 0, 27.5), Vector3(26.0, 0, 27.5), 5.0, 12, 8], [Vector3(-24.0, 0, 17.9), Vector3(24.0, 0, 17.9), 0.6, 0, 6]]:
		var bx := BattleExtras.new()
		bx.side = "osm"
		add_child(bx)
		bx.assault = assault
		bx.hit_every = 2.0
		bx.populate(lane[0], lane[1], lane[2], lane[3], lane[4], 0, 2700 + int(lane[0].z))
	# Çiğnenmiş çayır: ot öbekleri, taşlar
	Scenery.ground_detail(self, Rect2(-32.0, 36.5, 64.0, 41.0), 420, func(_x: float, _z: float) -> float: return 0.0, Color("3a4a2a"), 2651)
	# Bekleyen birlikler: silahlı, saf saf (yürünen alanın arkasında, geçitler açık)
	var kinds := ["spear", "sword_shield", "spear", "bow", "axe"]
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a"), Color("8a6a4a"), Color("6a4a3a")]
	for blk: Vector3 in [Vector3(-22, 0, 66), Vector3(-8, 0, 69), Vector3(8, 0, 69), Vector3(22, 0, 66), Vector3(-26, 0, 42), Vector3(26, 0, 44)]:
		for i in 4:
			for j in 3:
				var sd := Soldier.new(coats[(i + j) % coats.size()], "stand", "bork" if (i + j) % 2 == 0 else "turban")
				sd.set_meta("no_talk", true)
				sd.position = blk + Vector3(-2.4 + i * 1.6 + randf_range(-0.15, 0.15), 0, -1.4 + j * 1.4)
				sd.rotation.y = PI + randf_range(-0.2, 0.2)
				add_child(sd)
				sd.equip(kinds[(i * 3 + j) % kinds.size()], coats[(i + 2) % coats.size()])
	hasan = Person.new({"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")})
	hasan.set_meta("spk", "SPK_HASAN")
	hasan.position = Vector3(4.5, 0, 46.0)
	hasan.visible = false
	add_child(hasan)
	hasan.look_target = player
	Props.interactable(hasan, "hasan", Vector3(1.4, 2.0, 1.4), Vector3(0, 1.0, 0))
	banner = Node3D.new()
	banner.position = BANNER_TOWER + Vector3(0, -4.0, 0)
	banner.visible = false
	add_child(banner)
	Props.cyl(banner, 0.05, 4.0, Vector3(0, 2.0, 0), Color("5a3e26"), Vector3.ZERO, 5)
	Props.box(banner, Vector3(0.04, 1.2, 1.8), Vector3(0, 3.3, 0.92), Color("b3262d"))


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH26O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH26O_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = Vector3(6.0, 0.05, 52.0)
	player.face(Vector3(0, 6.0, LandWalls.OUTER_Z1))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.2)
	await hud.say("SPK_NIHAT", "D26O_N_01")
	await hud.say("SPK_TOLGA", "D26O_T_01")
	await _o_wave1()
	await _o_wave2()
	await _o_wave3()
	await _aya()
	if _outcome == "26.2" and banner_photo != "":
		Siege.record(26, banner_photo, "SIEGE_NOTE_26O_2")
	elif _outcome == "26.1":
		Siege.record(26, _photo, "SIEGE_NOTE_26O_1")
	await _end_chapter()


func _o_wave_start(n: int) -> void:
	Audio.sfx("crowd_camp", 0.0, 0.8 + n * 0.1)
	_spawn_attackers(4 + n * 3, n)
	for a in attackers:
		a.position.z = randf_range(52.0, 70.0)
	hud.bark("SPK_SOLDIER", "D26O_L_WAVE_%d" % n, 3.5)
	_pour_loop("o%d" % n)


func _o_wave1() -> void:
	phase = "o1"
	_o_wave_start(1)
	await hud.say("SPK_SOLDIER", "D26O_S_WAVE1")
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		for i in 3:
			_on_interact("o_water")
			_on_interact("squad_%d" % i)
			await get_tree().process_frame
	while water < 3:
		await get_tree().process_frame
	player.frozen = true
	_drop()
	hud.set_objective("")
	await hud.say("SPK_SOLDIER", "D26O_S_BACK1")


func _o_wave2() -> void:
	phase = "o2"
	_o_wave_start(2)
	walls.fire_flash()
	Audio.sfx("cannon", 0.0, 0.8)
	await get_tree().create_timer(1.1).timeout
	walls.impact(LandWalls.BREACH + Vector3(0, 2.0, 0.6))
	Audio.sfx("explosion_big", -2.0)
	walls.set_repair(LandWalls.STAGES - 6)
	await hud.say("SPK_SOLDIER", "D26O_S_WAVE2")
	player.frozen = false
	_volley = 8.0
	_update_objective()
	if GameState.autotest:
		for i in 3:
			_on_interact("o_ladder")
			_on_interact("squad_%d" % i)
			await get_tree().process_frame
	while o_ladders < 3:
		await get_tree().process_frame
	_vwarn = -1.0
	player.frozen = true
	_drop()
	hud.set_objective("")
	await hud.say("SPK_SOLDIER", "D26O_S_BACK2")


func _genoese_duel() -> void:
	var p := player.global_position
	var to := LandWalls.BREACH - p
	to.y = 0.0
	to = to.normalized() if to.length() > 0.1 else Vector3(0, 0, -1)
	var side := to.cross(Vector3.UP).normalized()
	var specs := []
	for k in 2:
		specs.append({"pos": p + to * 3.8 + side * (-1.0 + k * 2.0), "blade": "spathion", "shield": true,
			"name": "SPK_GENOESE", "look": {"coat": Color("8a8e96"), "pants": Color("3a2a22"), "hat": "helm",
			"mustache": true, "beard": k == 0}})
	await hud.say("SPK_HASAN", "D26O_H_DUEL")
	player.frozen = false
	await StoryDuel.fight(self, hud, player, specs, "kilij", 0.45)
	player.frozen = true
	await hud.say("SPK_TOLGA", "D26O_T_DUEL")
	player.face(hasan.global_position + Vector3(0, 1.5, 0))


func _o_wave3() -> void:
	phase = "o3"
	await hud.fade_to(1.0, 0.6)
	walls.make_dawn(0.01)
	await hud.card([[tr("UI_CH26_DAWN"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	hasan.visible = true
	player.global_position = hasan.global_position + Vector3(2.0, 0.05, 3.0)
	player.face(hasan.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	_o_wave_start(3)
	await hud.say("SPK_HASAN", "D26O_H_01")
	await hud.say("SPK_TOLGA", "D26O_T_02")
	# Perde II'de Bizans'a yardım ettiyse: gediğin ağzında kendi bandını görür. Bu taraftan onu kimse uyarmaz.
	if Siege.has_claim():
		await hud.say("SPK_TOLGA", "D26O_T_TAPE")
		await hud.say("SPK_NIHAT", "D26O_N_TAPE")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ26O_HASAN"), hasan.global_position + Vector3(0, 1.8, 0))
	if GameState.autotest:
		_on_interact("o_water")
		_on_interact("hasan")
	while not hasan_water:
		await get_tree().process_frame
	player.frozen = true
	hud.set_objective("")
	_drop()
	await hud.say("SPK_HASAN", "D26O_H_02")
	await hud.say("SPK_TOLGA", "D26O_T_03")
	# Gedikten iki Cenevizli savunucu çıkar (Giustiniani'nin adamları sona kadar gedikteydi): göğüs göğüse
	await _genoese_duel()
	# Hasan gediğe koşar; bir süre sonra burçta sancak
	var run := create_tween()
	run.tween_property(hasan, "position", Vector3(BANNER_TOWER.x - 2.0, 0, EDGE_Z + 0.5), 2.5)
	await run.finished
	hasan.visible = false
	player.face(BANNER_TOWER + Vector3(0, 2.0, 0))
	await get_tree().create_timer(1.2).timeout
	banner.visible = true
	Audio.sfx("crowd_gasp", -2.0)
	var up := create_tween()
	up.tween_property(banner, "position", BANNER_TOWER, 2.4).set_trans(Tween.TRANS_SINE)
	await up.finished
	await hud.say("SPK_SOLDIER", "D26O_L_BANNER")
	# Tespit: burçtaki sancak
	var target := Node3D.new()
	banner.add_child(target)
	target.position = Vector3(0, 3.0, 0.9)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ26O_PHOTO"), target.global_position)
	var bcam := TespitCam.new(player, hud, target, "siege26o")
	hud.add_child(bcam)
	bcam.max_dist = 60.0
	bcam.cone_deg = 12.0
	bcam.taken.connect(func(path: String): banner_photo = path)
	bcam.start()
	var t := 0.0
	while not bcam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	bcam.stop()
	banner_done = bcam.done
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_NIHAT", "D26_N_BANNER")
	await hud.say("SPK_TOLGA", "D26O_T_BANNER")
	# Yeniçeriler gedikten içeri
	for a in attackers:
		var tw := create_tween()
		tw.tween_property(a, "position", Vector3(randf_range(-3.0, 3.0), 0, LandWalls.OUTER_Z1 + 2.0), 5.0)
	await hud.say("SPK_NIHAT", "D26O_N_IN")
	await hud.fade_to(1.0, 1.5, Color.WHITE)


func _update_objective() -> void:
	match phase:
		"o1":
			if carrying == "water":
				for i in 3:
					if not squads[i][0].has_meta("served1"):
						hud.set_objective(tr("UI_OBJ26O_GIVE") % [water, 3], (SQUADS[i] as Vector3) + Vector3(0, 1.8, 0))
						return
			hud.set_objective(tr("UI_OBJ26O_WATER") % [water, 3], O_WATER + Vector3(0.6, 1.2, 0))
		"o2":
			if carrying == "ladder":
				for i in 3:
					if not ladders[i].visible:
						hud.set_objective(tr("UI_OBJ26O_LADDER_PUT") % [o_ladders, 3], (SQUADS[i] as Vector3) + Vector3(0, 1.8, 0))
						return
			hud.set_objective(tr("UI_OBJ26O_LADDER") % [o_ladders, 3], O_LADDERS + Vector3(0, 1.2, 0))
		"o3":
			if carrying == "water":
				hud.set_objective(tr("UI_OBJ26O_HASAN"), hasan.global_position + Vector3(0, 1.8, 0))
			else:
				hud.set_objective(tr("UI_OBJ26O_WATER1"), O_WATER + Vector3(0.6, 1.2, 0))


func _covered() -> bool:
	var p := player.global_position
	for c: Vector3 in O_COVERS:
		if Vector2(p.x - c.x, p.z - c.z).length() < 3.0:
			return true
	return false


func _process(delta: float) -> void:
	super._process(delta)
	if walls == null or not phase in ["o1", "o2", "o3"]:
		return
	_fx_t -= delta
	if _fx_t <= 0.0:
		_fx_t = randf_range(0.8, 2.0)
		Vfx.explosion(walls, Vector3(randf_range(-14, 18), randf_range(2.0, 8.0), randf_range(14.0, 20.0)), randf_range(0.3, 0.6))
		Audio.sfx("explosion_small", -16.0, randf_range(0.8, 1.2))
	if phase == "o2" and not player.frozen and not GameState.autotest:
		if _vwarn >= 0.0:
			var before := _vwarn
			_vwarn += delta
			if before < VOLLEY_WARN - Assault.VOLLEY_FLIGHT and _vwarn >= VOLLEY_WARN - Assault.VOLLEY_FLIGHT and assault:
				# Oklar surdan kalkar: tam uyarı bitince oyuncunun çevresine yağar
				assault.volley(Vector3(player.global_position.x, 0.0, player.global_position.z), 7.0, 45)
			if _vwarn >= VOLLEY_WARN:
				_vwarn = -1.0
				_volley = VOLLEY_EVERY
				Audio.sfx("whoosh_fly", -4.0)
				if not _covered():
					arrows += 1
					player.stagger(0.8)
					hud.bark("SPK_TOLGA", "D22O_T_ARROW_%d" % mini(arrows, 3), 3.0)
		else:
			_volley -= delta
			if _volley <= 0.0:
				_vwarn = 0.0
				hud.bark("SPK_SOLDIER", "D26O_S_VOLLEY", VOLLEY_WARN)


func _pick_ladder() -> void:
	if carrying != "":
		return
	carrying = "ladder"
	_carry = Node3D.new()
	_carry.position = Vector3(0.5, -0.6, -1.4)
	player.camera.add_child(_carry)
	for sx: float in [-0.3, 0.3]:
		Props.cyl(_carry, 0.04, 3.0, Vector3(sx, 0, 0), Color("6a4a2c"), Vector3(90, 0, 0), 5)
	Props.strip_outlines(_carry)
	player.speed_mult = 0.7
	Audio.sfx("land_pot", -10.0, 0.7)
	_update_objective()


func _on_focus(id: String) -> void:
	var k := ""
	match id:
		"o_water":
			if carrying == "" and ((phase == "o1" and water < 3) or (phase == "o3" and not hasan_water)):
				k = "UI_PROMPT26O_WATER"
		"o_ladder":
			if phase == "o2" and carrying == "":
				k = "UI_PROMPT26O_LADDER"
		"hasan":
			if phase == "o3" and carrying == "water":
				k = "UI_PROMPT26O_HASAN"
		_:
			if id.begins_with("squad_") and carrying != "":
				k = "UI_PROMPT26O_GIVE" if carrying == "water" else "UI_PROMPT26O_PUT"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	match id:
		"o_water":
			if carrying == "" and ((phase == "o1" and water < 3) or (phase == "o3" and not hasan_water)):
				_pick("water")
		"o_ladder":
			if phase == "o2":
				_pick_ladder()
		"hasan":
			if phase == "o3" and carrying == "water":
				hasan_water = true
				Audio.sfx("splash", -12.0, 1.3)
		_:
			if not id.begins_with("squad_"):
				return
			var i := int(id.trim_prefix("squad_"))
			if phase == "o1" and carrying == "water" and not squads[i][0].has_meta("served1"):
				squads[i][0].set_meta("served1", true)
				_drop()
				water += 1
				hud.bark("SPK_SOLDIER", "D26O_S_WATER_%d" % water, 2.2)
			elif phase == "o2" and carrying == "ladder" and not ladders[i].visible:
				_drop()
				ladders[i].visible = true
				o_ladders += 1
				Audio.sfx("land_thud", -6.0, 1.0)
			_update_objective()


# ================================================================ bölüm sonu

func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW26O_TITLE")
	c.nodes = [
		{"id": "waves", "key": "FLOW26O_WAVES", "pos": Vector2(0.5, 0.12)},
		{"id": "banner", "key": "FLOW26O_BANNER", "pos": Vector2(0.5, 0.28)},
		{"id": "aya", "key": "FLOW26_AYA", "pos": Vector2(0.5, 0.44)},
		{"id": "26.1", "key": "FLOW_26_1", "pos": Vector2(0.3, 0.62), "outcome": true},
		{"id": "26.2", "key": "FLOW_26_2", "pos": Vector2(0.7, 0.62), "outcome": true},
	]
	c.edges = [["waves", "banner"], ["banner", "aya"], ["aya", "26.1"], ["aya", "26.2"]]
	for k in ["waves", "banner", "aya", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH26O_STATS") % [water, o_ladders, arrows, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "26.1", "nophoto": "26.2"}.get(v, "26.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("26", {})
	var ok: bool = _outcome == expected and not page.is_empty() and water == 3 and o_ladders == 3 and hasan_water \
		and banner_done
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (su=%d merdiven=%d sancak=%s)" % [expected, _outcome, water, o_ladders, banner_done])
	print("AUTOTEST %s chapter=26o variant=%s outcome=%s water=%d ladders=%d" % ["PASS" if ok else "FAIL", v, _outcome, water, o_ladders])
	get_tree().quit(0 if ok else 1)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	phase = "o2"
	_o_wave_start(2)
	ladders[0].visible = true
	player.global_position = Vector3(2.0, 0.05, 45.0)
	await get_tree().create_timer(1.0).timeout
	player.face(Vector3(0, 4.0, LandWalls.OUTER_Z1))
	_update_objective()
	await _shot("c26o_01_ladders.png")
	walls.make_dawn(0.01)
	banner.visible = true
	banner.position = BANNER_TOWER
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(8.0, 2.0, 44.0)
	cv.look_at(BANNER_TOWER + Vector3(-3.0, -2.0, 0), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await get_tree().create_timer(0.4).timeout
	await _shot("c26o_cover.png")
	get_tree().quit()


## Sultan'ın alayının yolundaki zemin: kulenin önündeki toprak dolgunun üstü (y 0.2) de sayılır (atı ve yol
## boyundaki yeniçeriler dolguya 0,2 m gömülüyordu).
const FILL_C := Vector3(-3.0, -1.4, 28.0)
func _entry_ground(p: Vector3) -> float:
	var g := super(p)
	if absf(p.x - FILL_C.x) <= 5.0 and absf(p.z - FILL_C.z) <= 8.0:
		g = maxf(g, FILL_C.y + 1.6)
	return g
