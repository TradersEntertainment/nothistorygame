extends Node3D
## Bölüm 30 (Osmanlı tarafı) — Blakherna (Tolga · 12 Mayıs 1453, gece yarısı, saray önündeki sur).
##
## O gece Osmanlılar Blakherna sarayı önündeki tek sura büyük bir gece hücumu yaptı; İmparator bizzat geldi ve hücum
## püskürtüldü. Tolga Zağanos Paşa'nın askerleriyle:
##   1. merdiveni ekipçe sura taşı (karanlıkta, surdan ok yağar)
##   2. merdiveni daya, tırman: taş düşerken dur, sonra çık (26o'daki merdiven)
##   3. sur yolunda dövüş (WaveRunner, iki dalga; kuleden bir tüfekçi)
##   4. geri çekilme borusu: sur yolundan inilir, sur dibinde yaralı bir azap; sırtına al, ateşlerin hizasına getir
##   Tespit: sur yolunda meşalelerin arasında İmparator.
##   30O.1 Sur yolunda tutunuldu, düzenli çekilindi · 30O.2 Sur yolundan atıldın, yaralıyı yine getirdin
## Kaza rotası (30O.2, Dallanma v3 §3): gece yarısından sonra surun dibinde ölüler toplanırken bir Rum çıkışı topal
## kâtibi yakalar; Grant tercüman ister. Sıradaki sayfa Lağım (21), Bizans tarafında, esir olarak (Siege.DETOUR).
##   --autotest[=lose]   (varsayılan: 30O.1)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const CLIMB_X := 10.0
const TILT := 16.0
const START := Vector3(10.0, 0.0, 40.0)
const PLANT := Vector3(10.0, 0.0, 8.0)
const SAFE_Z := 34.0
const TOWER_X := 20.0                  # tüfekçinin kulesi (Blachernae.TOWERS)
## Düşülen çalı: merdivenin doğusunda, surdan birkaç adım açıkta (oradan İmparator mazgal aralığında görünür)
const BUSH := Vector3(CLIMB_X + 2.8, 0.0, Blachernae.WALL_Z1 + 7.4)

var walls: Blachernae
var player: Player
var hud: Hud
var cam: TespitCam
var ladder: Ladder
var carriers: Array[Soldier] = []
var zaganos: Person
var emperor: Person
var wounded: Soldier
var phase := "intro"
var _outcome := ""
var stones := 0
var stone_hits := 0
var _stone_falling := false
var _duel_won := true
var climbed := false
var oil: OilHazard
var carried := false
var gunner_shots := 0
var gunner_dodged := 0
var _carry: Node3D
var _photo := ""
var _t := 0.0
var guards: Array[WallGuard] = []
var tower_ladder: Ladder
var tower_won := false
var fell := false
var guard_pokes := 0


func _ready() -> void:
	GameState.snapshot(30)
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	walls = Blachernae.new()
	add_child(walls)
	walls.build_guards([CLIMB_X], false)
	# Merdivenin iki yanındaki sur yolu adamları canlı: oyuncuya döner, sokulana mızrak dürter
	walls.live_range = Vector2(CLIMB_X - 28.0, CLIMB_X + 30.0)
	walls.quiet_tower = TOWER_X
	walls.night_assault([CLIMB_X])
	_build()
	guards = WallGuard.spawn_all(self, walls.live_spots, player)
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	var lh := Blachernae.WALK_Y + 0.6
	ladder = Ladder.new(lh, TILT, Color("6a4a2c"))
	ladder.position = Vector3(CLIMB_X, 0.0, Blachernae.WALL_Z1 + lh * sin(deg_to_rad(TILT)) + 0.12)
	add_child(ladder)
	ladder.visible = false
	# Sur yolundan kulenin tepesine kısa merdiven (kulenin batı yüzüne dayalı; kule x 16…24, tepe y 17)
	var th := Blachernae.WALL_H + 5.0 - Blachernae.WALK_Y + 0.6
	tower_ladder = Ladder.new(th, 14.0, Color("5a3e26"))
	tower_ladder.position = Vector3(TOWER_X - 4.0 - th * sin(deg_to_rad(14.0)) - 0.12, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 1.3)
	tower_ladder.rotation.y = -PI * 0.5
	add_child(tower_ladder)
	_tower_fence()
	# Sur dibinde çalı (sur yolundan ya da kuleden düşen buraya düşer)
	_bush(BUSH)
	_bush(Vector3(TOWER_X + 1.0, 0.0, Blachernae.WALL_Z1 + 7.4))
	zaganos = Person.new({"coat": Color("2e6a3a"), "pants": Color("e8e0d0"), "hat": "turban", "beard": true, "mustache": true,
		"robe": Color("2e6a3a"), "skin": Color("d8a882")})
	zaganos.set_meta("spk", "SPK_ZAGANOS")
	zaganos.position = START + Vector3(-3.0, Blachernae.slope_y(START.z + 2.0), 2.0)
	zaganos.rotation.y = PI
	add_child(zaganos)
	zaganos.look_target = player
	# Merdiveni taşıyan bölük: oyuncunun önünde ve arkasında, merdiven omuzlarında
	for k in 3:
		var s := Soldier.new([Color("b3262d"), Color("6a4a3a"), Color("2f5fa8")][k], "stand", ["azap", "bork", "turban"][k])
		s.set_meta("no_talk", true)
		s.set_meta("climber", true)
		add_child(s)
		carriers.append(s)
	# Hücum kalabalığı: sura koşanlar, sur dibinde düşenler
	var bx := BattleExtras.new()
	bx.side = "osm"
	bx.flat = true
	add_child(bx)
	bx.hit_every = 3.5
	bx.populate(Vector3(-40.0, 0, 16.0), Vector3(40.0, 0, 16.0), 8.0, 10, 6, 0, 3005)
	emperor = Person.new({"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "stemma", "face": "emperor", "beard": true,
		"mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")})
	emperor.set_meta("spk", "SPK_EMPEROR")
	emperor.set_meta("climber", true)
	emperor.position = Vector3(-3.0, Blachernae.WALK_Y, Blachernae.WALL_Z0 + 2.4)
	emperor.rotation.y = 0.0
	add_child(emperor)
	emperor.visible = false
	wounded = Soldier.new(Color("b3262d"), "stand", "azap")
	wounded.set_meta("spk", "SPK_SOLDIER")
	wounded.set_meta("no_talk", true)
	wounded.set_meta("climber", true)
	wounded.position = Vector3(CLIMB_X + 2.4, 0.1, Blachernae.WALL_Z1 + 1.6)
	wounded.rotation = Vector3(deg_to_rad(-80), 0.6, 0)
	add_child(wounded)
	wounded.visible = false
	Props.interactable(wounded, "wounded", Vector3(1.6, 1.0, 1.6), Vector3(0, 0.3, 0))
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(func(id: String): hud.set_prompt(tr("UI_PROMPT30O_LIFT") if id == "wounded" and phase == "retreat" and not carried else ""))


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH30O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH30O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	Audio.ambience("amb_wall_night")
	Audio.intensity(2, "walls_night")
	player.global_position = START + Vector3(0, Blachernae.slope_y(START.z) + 0.05, 0)
	player.face(zaganos.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D30O_N_01")
	await hud.say("SPK_ZAGANOS", "D30O_Z_01")
	await hud.say("SPK_TOLGA", "D30O_T_01")
	await _carry_ladder()
	await _climb()
	await _wall_fight()
	await _retreat()
	await _end_chapter()


## 1. Merdiven taşıma: ekip oyuncuyla yürür; merdiven omuzlarda. Sura vardığında E ile dayanır.
func _carry_ladder() -> void:
	phase = "carry"
	_carry = Node3D.new()
	_carry.position = Vector3(0.5, -0.35, -1.6)
	player.camera.add_child(_carry)
	for sx: float in [-0.3, 0.3]:
		Props.cyl(_carry, 0.05, 6.0, Vector3(sx, 0, -2.0), Color("6a4a2c"), Vector3(90, 0, 0), 5)
	Props.strip_outlines(_carry)
	player.speed_mult = 0.7
	player.frozen = false
	hud.set_objective(tr("UI_OBJ30O_CARRY"), PLANT + Vector3(0, 1.0, 0))
	var arrows := 0.0
	while Vector2(player.global_position.x - PLANT.x, player.global_position.z - PLANT.z).length() > 2.2:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		if GameState.autotest:
			var to := PLANT - player.global_position
			to.y = 0.0
			player.global_position += to.normalized() * minf(to.length(), 6.0 * dt)
			player.global_position.y = Blachernae.slope_y(player.global_position.z) + 0.05
		# Taşıyanlar oyuncunun önünde ve arkasında
		var fwd := -player.global_transform.basis.z
		fwd.y = 0.0
		fwd = fwd.normalized()
		for k in carriers.size():
			var along: float = [2.4, -2.2, 4.6][k]
			var off: Vector3 = fwd * along + fwd.cross(Vector3.UP) * 0.5
			var p: Vector3 = player.global_position + off
			p.y = Blachernae.slope_y(p.z)
			carriers[k].global_position = p
			carriers[k].look_at(p + fwd, Vector3.UP)
			carriers[k].rotate_object_local(Vector3.UP, PI)
		arrows -= dt
		if arrows <= 0.0:
			arrows = randf_range(2.0, 3.4)
			var at := player.global_position + Vector3(randf_range(-6.0, 6.0), 0, randf_range(-4.0, 4.0))
			at.y = Blachernae.slope_y(at.z)
			Vfx.dust(self, at, 0.3)
			Audio.sfx("whoosh_fly", -14.0, 1.6)
	player.frozen = true
	hud.set_objective("")
	_carry.queue_free()
	player.speed_mult = 1.0
	await hud.say("SPK_ZAGANOS", "D30O_Z_PLANT")
	ladder.visible = true
	Audio.sfx("land_thud", -2.0, 0.8)
	for c in carriers:
		c.visible = false


## 2. Tırmanış: yukarıdan taş (merdivende oyuncunun 1,1 m üstüne iner)
func _climb() -> void:
	phase = "climb"
	player.global_position = ladder.global_position + Vector3(0, 0.05, 1.0)
	player.face(ladder.point_at(2.5))
	await hud.say("SPK_TOLGA", "D30O_T_CLIMB")
	hud.set_objective(tr("UI_OBJ30O_CLIMB"), ladder.point_at(ladder.height))
	player.frozen = false
	# Merdivenin yanındaki kazan: yarı yolda kaynar yağ
	var fight := WallFight.new()
	add_child(fight)
	var cd := fight.add_cauldron(Vector3(CLIMB_X - 6.0, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.9), 3012)
	oil = OilHazard.make(self, fight, cd, ladder, player, hud)
	var hz := 1.0
	var t := 0.0
	while not (player.ladder == null and player.global_position.y > Blachernae.WALK_Y - 0.3 and player.global_position.z < Blachernae.WALL_Z1):
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		if player.ladder == ladder and not _stone_falling and player._ladder_t > ladder.height * 0.4:
			oil.trigger()
		if player.ladder == ladder and not oil.active:
			hz -= dt
			if hz <= 0.0:
				hz = randf_range(1.4, 2.0)
				_drop_stone()
		if GameState.autotest:
			if _stone_falling or oil.active:
				Input.action_release("move_forward")
			else:
				Input.action_press("move_forward")
			player.face(ladder.point_at(clampf(player._ladder_t + 2.0, 0.0, ladder.height)))
			if t > 40.0:
				player.global_position = ladder.top_exit()
	if GameState.autotest:
		Input.action_release("move_forward")
	hud.set_qte("")
	hud.set_objective("")
	player.frozen = true
	climbed = true


func _drop_stone() -> void:
	var l := ladder
	var t_h: float = player._ladder_t + 1.1
	if t_h > l.height - 0.3 or stones >= 4:
		return
	stones += 1
	_stone_falling = true
	hud.set_qte(tr("UI_QTE26O_STONE"))
	var top := l.point_at(l.height) + l.front_dir() * 0.5 + Vector3(0, 1.2, 0)
	var at := l.point_at(t_h) + l.front_dir() * 0.4
	var stone := Props.ball(self, 0.24, top, Color("8a8478"), Vector3(1.0, 0.8, 1.1), 8)
	Audio.sfx("whoosh_fly", -6.0, 0.7)
	var tw := stone.create_tween()
	tw.tween_property(stone, "global_position", at, 0.8).set_ease(Tween.EASE_IN)
	await tw.finished
	if is_instance_valid(stone) and player.ladder == l and absf(player._ladder_t - t_h) < 0.75:
		stone_hits += 1
		player.hurt(30.0, top)
		Audio.sfx("land_thud", -2.0, 1.1)
	_stone_falling = false
	hud.set_qte("")
	if is_instance_valid(stone):
		var tw2 := stone.create_tween()
		tw2.tween_property(stone, "global_position", l.global_position + l.front_dir() * 1.4 + Vector3(0, 0.2, 0), 0.5).set_ease(Tween.EASE_IN)
		tw2.tween_callback(stone.queue_free)


## 3. Sur yolu: iki dalga, kuleden tüfekçi. Sonra İmparator meşalelerle gelir (tespit karesi).
func _wall_fight() -> void:
	phase = "fight"
	var y := Blachernae.WALK_Y
	var zc := (Blachernae.WALL_Z0 + Blachernae.WALL_Z1) * 0.5
	var east := [Vector3(CLIMB_X + 3.6, y, zc), Vector3(CLIMB_X + 2.4, y, zc - 0.6)]
	var west := [Vector3(CLIMB_X - 3.6, y, zc), Vector3(CLIMB_X - 2.4, y, zc + 0.4)]
	var specs := []
	for k in 2:
		specs.append({"pos": east[k], "blade": "spathion", "shield": true, "name": "SPK_DEFENDER",
			"look": {"coat": [Color("7a2a24"), Color("5a6a7a")][k], "pants": Color("3a2a22"), "hat": "helm", "mustache": true, "beard": k == 0}})
	var more := []
	for k in 3:
		more.append({"pos": west[k % 2], "blade": "spathion", "shield": k % 2 == 0, "name": "SPK_DEFENDER",
			"look": {"coat": [Color("5a2a6a"), Color("7a2a24"), Color("6a5a3a")][k], "pants": Color("3a2a22"), "hat": "helm",
			"mustache": true, "beard": k == 1}})
	player.face(east[0] + Vector3(0, 1.5, 0))
	await hud.say("SPK_TOLGA", "D30O_T_WALL")
	player.frozen = false
	var gn := Gunner.spawn(self, _gunner_spot(), player, hud, 6.0, Color("5a2a6a"), "helm")
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": specs, "max_active": 2, "skill": 0.45, "limit": 60.0},
		{"specs": more, "max_active": 2, "skill": 0.48, "limit": 60.0,
		"intro": func():
			# Haberi getiren savunucu dalgayla arkadan gelir: oyuncu sesine döner (yoksa kartta konuşan, ekranda kimse yok)
			var dw := hud.find_speaker("SPK_DEFENDER")
			if dw:
				player.face(LivePortrait.head_of(dw))
			await hud.say("SPK_DEFENDER", "D30O_D_EMPEROR")}], "kilij")
	await gn.settle_test()
	_duel_won = r["won"]
	player.frozen = true
	if _duel_won:
		await hud.say("SPK_TOLGA", "D30O_T_DUEL")
		await _tower_assault(gn)
	if is_instance_valid(gn):
		gunner_shots = gn.shots
		gunner_dodged = gn.dodged
		gn.stop()
	if not _duel_won:
		var on_tower := player.global_position.y > Blachernae.WALK_Y + 3.0
		await _fall_off()
		await hud.say("SPK_TOLGA", "D30O_T_LOST_TOWER" if on_tower else "D30O_T_LOST")
		# Aşağıdan görülsün: İmparator mazgalların arasından bakar
		emperor.position = Vector3(CLIMB_X + 0.35, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.3)
	# İmparator sur yolunda, meşalelerin arasında
	emperor.visible = true
	emperor.look_target = player
	player.face(emperor.global_position + Vector3(0, 1.6, 0))
	var target := Node3D.new()
	emperor.add_child(target)
	target.position = Vector3(0, 1.6, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ30O_PHOTO"), emperor.global_position + Vector3(0, 2.0, 0))
	cam = TespitCam.new(player, hud, target, "siege30o")
	hud.add_child(cam)
	cam.max_dist = 40.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 30.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_EMPEROR", "D30O_E_01")
	await hud.say("SPK_TOLGA", "D30O_T_EMPEROR")


func _gunner_spot() -> Vector3:
	return Vector3(TOWER_X - 1.6, Blachernae.WALL_H + 5.0, Blachernae.WALL_Z1 + 0.2)


## 3b. Dalgalar tutulunca: kulenin yanındaki kısa merdivenden tepeye çık, tüfekçiyi kılıçla sustur. Tırmanırken
## tüfekçi ateşe devam eder. Kaybedilirse oyuncu kuleden düşer (_duel_won false).
func _tower_assault(gn: Gunner) -> void:
	phase = "tower"
	player.face(tower_ladder.point_at(2.0))
	await hud.say("SPK_TOLGA", "D30O_T_TOWER")
	hud.set_objective(tr("UI_OBJ30O_TOWER"), tower_ladder.point_at(tower_ladder.height))
	player.frozen = false
	var top := Blachernae.WALL_H + 5.0
	var t := 0.0
	var walk := 0.0
	while not (player.ladder == null and player.global_position.y > top - 0.4):
		await get_tree().process_frame
		t += get_process_delta_time()
		if GameState.autotest:
			# Bot: merdivenin önüne yürür, tutunur, çıkar
			player.face(tower_ladder.point_at(clampf(player._ladder_t + 2.0, 0.0, tower_ladder.height)))
			Input.action_press("move_forward")
			walk += get_process_delta_time()
			if walk > 25.0:
				player.global_position = tower_ladder.top_exit()
	if GameState.autotest:
		Input.action_release("move_forward")
	hud.set_objective("")
	player.frozen = true
	# Tüfekçi tüfeği bırakır, kılıca davranır
	# "Yaklaşma! Bu tüfek dolu!" tüfekçinin kendisi: konuşurken ateş etmez, sonra kılıca davranır (eskiden önce siliniyor,
	# kart başka bir savunucunun kopyasını gösteriyordu)
	var at := _gunner_spot() + Vector3(1.4, 0.0, 1.6)
	if is_instance_valid(gn):
		gn.state = "done"
		if is_instance_valid(gn.soldier):
			gn.soldier.set_meta("spk", "SPK_DEFENDER")
	await hud.say("SPK_DEFENDER", "D30O_D_GUNNER")
	if is_instance_valid(gn):
		gunner_shots = gn.shots
		gunner_dodged = gn.dodged
		at = gn.global_position + Vector3(0.6, 0.0, 1.2)
		gn.stop()
	player.frozen = false
	var r: Dictionary = await StoryDuel.fight(self, hud, player, [{"pos": at, "blade": "spathion", "shield": false,
		"name": "SPK_DEFENDER", "skill": 0.5, "hp": 70.0,
		"look": {"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "helm", "mustache": true, "beard": true}}], "kilij", 0.5, 60.0)
	player.frozen = true
	tower_won = r["won"]
	_duel_won = tower_won
	if tower_won:
		await hud.say("SPK_TOLGA", "D30O_T_TOWER_WON")
		# Merdivenden sur yoluna iner: İmparator sur yolunda görünür
		await hud.fade_to(1.0, 0.4)
		player.ladder = null
		player.global_position = tower_ladder.global_position + Vector3(-1.2, 0.05, 0.0)
		await hud.fade_to(0.0, 0.4)


## Kaybedilen dövüş: oyuncu dış kenardan aşağı, sur dibindeki çalıya düşer (sur yolundan ya da kuleden).
func _fall_off() -> void:
	fell = true
	player.frozen = true
	var p := player.global_position
	var on_tower := p.y > Blachernae.WALK_Y + 3.0
	var face_z := Blachernae.WALL_Z1 + (8.0 + 0.6 if on_tower else 0.6)
	var land := Vector3(TOWER_X + 1.0, 0.0, Blachernae.WALL_Z1 + 7.4) if on_tower else BUSH
	# Önce dış kenara savrulur (mazgalın üstünden), sonra düşer
	var edge := Vector3(lerpf(p.x, land.x, 0.3), p.y + 0.8, face_z)
	player.face(land + Vector3(0, 0.5, 0))
	Audio.sfx("whoosh_fly", -2.0, 0.6)
	var tw := create_tween()
	tw.tween_property(player, "global_position", edge, 0.35).set_ease(Tween.EASE_OUT)
	tw.tween_property(player, "global_position", land + Vector3(0, 0.75, 0), 0.9 if on_tower else 0.75).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tw.finished
	Audio.sfx("land_thud", 0.0, 0.8)
	player.shake(0.8)
	player.stagger(0.8)
	player.global_position = land + Vector3(0, 0.1, 0)
	player.face(Vector3(land.x, Blachernae.WALK_Y + 1.5, Blachernae.WALL_Z0))


## Çalı: birkaç yeşil top ve dal (ayak bileği yüksekliğinde gövde yok; üstüne düşülür)
func _bush(at: Vector3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(at.x * 13.0 + at.z * 7.0)
	for k in 7:
		var off := Vector3(rng.randf_range(-0.8, 0.8), rng.randf_range(0.3, 0.7), rng.randf_range(-0.7, 0.7))
		Props.ball(self, rng.randf_range(0.45, 0.7), at + off, Color("2e4a24").lightened(rng.randf_range(0.0, 0.2)),
			Vector3(1.2, 0.8, 1.1), 8)
	for k in 4:
		Props.cyl(self, 0.03, 0.9, at + Vector3(rng.randf_range(-0.5, 0.5), 0.45, rng.randf_range(-0.5, 0.5)), Color("4a3420"),
			Vector3(rng.randf_range(-30, 30), 0, rng.randf_range(-30, 30)), 4)


## Kulenin tepesinde görünmez korkuluk (düello kuleden düşmekle bitmesin; batı yüzü merdiven tarafı açık)
func _tower_fence() -> void:
	var top := Blachernae.WALL_H + 5.0
	var zc := Blachernae.WALL_Z1 + 1.6
	for b: Array in [[Vector3(8.0, 2.0, 0.3), Vector3(TOWER_X, top + 1.0, zc + 4.0)],
			[Vector3(0.3, 2.0, 8.0), Vector3(TOWER_X + 4.0, top + 1.0, zc)],
			[Vector3(8.0, 2.0, 0.3), Vector3(TOWER_X, top + 1.0, zc - 4.0)],
			[Vector3(0.3, 2.0, 5.0), Vector3(TOWER_X - 4.0, top + 1.0, zc + 1.5)]]:
		var g := Props.solid(self, b[0], b[1], Color.WHITE)
		g.get_child(0).visible = false
		g.set_meta("no_climb", true)
	# Görünen alçak mazgallar (dış ve doğu kenar)
	for k in 4:
		Props.box(self, Vector3(1.1, 0.9, 0.5), Vector3(TOWER_X - 3.0 + k * 2.0, top + 0.45, zc + 3.75), Blachernae.C_STONE.darkened(0.1))
		Props.box(self, Vector3(0.5, 0.9, 1.1), Vector3(TOWER_X + 3.75, top + 0.45, zc - 3.0 + k * 2.0), Blachernae.C_STONE.darkened(0.1))


## 4. Geri çekilme: boru çalar; sur dibinde yaralı bir azap. Sırtına al, ateşlerin hizasına getir.
func _retreat() -> void:
	phase = "retreat"
	Audio.sfx("drum_boom", -2.0, 0.7)
	Audio.stinger("warn", -6.0)
	await hud.say("SPK_ZAGANOS", "D30O_Z_RETREAT")
	await hud.fade_to(1.0, 0.5)
	emperor.visible = false
	player.global_position = Vector3(CLIMB_X - 1.6, Blachernae.slope_y(Blachernae.WALL_Z1 + 2.4) + 0.05, Blachernae.WALL_Z1 + 2.4)
	wounded.visible = true
	player.face(wounded.global_position + Vector3(0, 0.3, 0))
	await hud.fade_to(0.0, 0.5)
	await hud.say("SPK_SOLDIER", "D30O_S_WOUNDED")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ30O_WOUNDED"), wounded.global_position + Vector3(0, 1.0, 0))
	while not carried:
		await get_tree().process_frame
		if GameState.autotest:
			_on_interact("wounded")
	hud.set_objective(tr("UI_OBJ30O_BACK"), Vector3(CLIMB_X, 1.0, SAFE_Z))
	while player.global_position.z < SAFE_Z:
		await get_tree().process_frame
		if GameState.autotest:
			player.global_position += Vector3(0, 0, 5.0 * get_process_delta_time())
			player.global_position.y = Blachernae.slope_y(player.global_position.z) + 0.05
	player.frozen = true
	hud.set_objective("")
	if is_instance_valid(_carry):
		_carry.queue_free()
	player.speed_mult = 1.0
	await hud.say("SPK_SOLDIER", "D30O_S_THANKS")
	await hud.say("SPK_ZAGANOS", "D30O_Z_END")
	await hud.say("SPK_NIHAT", "D30O_N_END")
	if not _duel_won:
		await _captured()
	_outcome = "30O.1" if _duel_won else "30O.2"
	if _duel_won:
		GameState.bump_stat("blachernae_held", 1, true)
	Siege.record(30, _photo, "SIEGE_NOTE_30O_%s" % _outcome.split(".")[1])


## Kaza rotası: surdan atılan, sonra yaralı taşıyan kâtip topallar. Gece ölüler toplanırken surdan bir Rum çıkışı
## olur, topal kâtip kaçamaz; Grant'in önüne getirilir (Türkçe bilen esir: tercüman).
func _captured() -> void:
	Audio.sfx("whoosh_fly", -6.0, 0.8)
	await hud.fade_to(1.0, 0.6)
	await hud.card([[tr("UI_CH30O_CAPTIVE"), 24, Color("f2e6c9")]], 2.4)
	hud.clear_card()
	# Kararmış ekranda konuşulmaz (eskiden Grant'in yüzü yoktu): surun dibi, meşale ışığı; çıkış kolunun iki mızraklısı
	# topal kâtibin iki yanında, Grant karşısında (21'deki gibi: önlüklü, sakallı mühendis).
	# Merdivenin solunda (sağda x 16'dan başlayan kule var: mızraklı kulenin içinde duruyordu)
	var at := Vector3(CLIMB_X - 4.0, Blachernae.slope_y(Blachernae.WALL_Z1 + 2.6), Blachernae.WALL_Z1 + 2.6)
	player.global_position = at + Vector3(0, 0.05, 0)
	var grant := Person.new({"coat": Color("5a5a62"), "pants": Color("3a3a40"), "hat": "none", "beard": true, "hair": Color("8a5a2a"),
		"apron": Color("3a3028"), "skin": Color("e8b894")})
	grant.set_meta("spk", "SPK_GRANT")
	add_child(grant)
	grant.global_position = Vector3(at.x - 0.3, at.y, at.z - 1.5)
	grant.look_target = player
	for k in 2:
		Garrison.man(self, Vector3(at.x - 1.0 + 2.0 * k, at.y, at.z + 0.4), PI, 3010 + k, "spear")
	Night.torch(self, Vector3(at.x - 2.4, at.y, at.z - 1.9), 2.0)      # yanda, biraz geride (kartın önüne girmesin)
	player.face(grant.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_GRANT", "D30O_G_CAPTIVE")
	await hud.say("SPK_TOLGA", "D30O_T_CAPTIVE")
	await hud.say("SPK_NIHAT", "D30O_N_CAPTIVE")


func _on_interact(id: String) -> void:
	if id == "wounded" and phase == "retreat" and not carried:
		carried = true
		wounded.visible = false
		hud.set_prompt("")
		_carry = Node3D.new()
		_carry.position = Vector3(0.0, -0.5, 0.25)
		player.camera.add_child(_carry)
		Props.box(_carry, Vector3(0.5, 0.3, 0.7), Vector3(0.45, 0.1, 0), Color("b3262d"))
		Props.strip_outlines(_carry)
		player.speed_mult = 0.6
		Audio.sfx("land_pot", -10.0, 0.6)


func _process(delta: float) -> void:
	_t += delta


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(30, _outcome)
	await Siege.show_page(hud, 30)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(30)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW30O_TITLE")
	c.nodes = [
		{"id": "ladder", "key": "FLOW30O_LADDER", "pos": Vector2(0.5, 0.12)},
		{"id": "30O.1", "key": "FLOW_30O_1", "pos": Vector2(0.3, 0.34), "outcome": true},
		{"id": "30O.2", "key": "FLOW_30O_2", "pos": Vector2(0.7, 0.34), "outcome": true},
		{"id": "retreat", "key": "FLOW30O_RETREAT", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["ladder", "30O.1"], ["ladder", "30O.2"], ["30O.1", "retreat"], ["30O.2", "retreat"]]
	for k in ["ladder", _outcome, "retreat"]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH30O_STATS") % [stones - stone_hits, stones, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	c.footer_lines.insert(0, Grade.finish("30o"))
	if Siege.detour_target(30) > 0:
		c.footer_lines.insert(1, tr("UI_FLOW_DETOUR_30O"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "30O.1", "lose": "30O.2"}.get(v, "30O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("30", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and climbed and carried
	ok = ok and stones >= 1 and gunner_shots >= 1
	# Kazanırsa kuleye çıkıp tüfekçiyi susturur; kaybederse çalıya düşer
	ok = ok and (tower_won if v == "" else fell)
	ok = ok and not guards.is_empty()
	# Kaynar yağ: bir kez döküldü; bot sarkıp kaçtı (=lose'da yandı)
	ok = ok and oil != null and oil.dodged + oil.hits == 1 and oil.hits == (1 if v == "lose" else 0)
	if v == "lose":
		ok = ok and player.downs >= 1 and not _duel_won
	# Kaza rotası: 30O.2'de sıradaki sayfa Bizans tarafının Lağım'ı (21), esir; 30O.1'de kendi sırası (21o)
	var nxt := Siege.next_path(30)
	ok = ok and nxt == ("res://scenes/chapter21.tscn" if v == "lose" else "res://scenes/chapter21o.tscn") and Siege.captive(21) == (v == "lose")
	if v == "lose":
		ok = ok and Siege.side() == "B" and Siege.home_side() == "O" and Siege.number("res://scenes/chapter21.tscn") == Siege.number_of(21, "O")
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s tırmandı=%s taşıdı=%s)" % [expected, _outcome, not page.is_empty(),
			cam != null and cam.done, climbed, carried])
	for g in guards:
		guard_pokes += g.pokes
	print("AUTOTEST %s chapter=30o variant=%s outcome=%s stones=%d/%d gunner=%d/%d tower=%s fell=%s guards=%d pokes=%d" % ["PASS" if ok else "FAIL", v, _outcome,
		stones - stone_hits, stones, gunner_dodged, gunner_shots, tower_won, fell, guards.size(), guard_pokes])
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
	ladder.visible = true
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(CLIMB_X + 9.0, 3.0, 26.0)
	cv.look_at(Vector3(CLIMB_X - 2.0, 8.0, 2.0), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await get_tree().create_timer(0.6).timeout
	await _shot_png("c30o_cover.png")
	# Tek harita denetimi: başlangıçtan sura, sur yolundan güneye (Theodosius surları) ve kuzeye (Haliç)
	for v: Array in [[START + Vector3(0, 1.7, 0), Vector3(0, 6.0, 0), "c30o_view_wall.png"],
			[Vector3(CLIMB_X, Blachernae.WALK_Y + 1.7, 2.0), Vector3(200.0, 4.0, 10.0), "c30o_view_south.png"],
			[Vector3(CLIMB_X, Blachernae.WALK_Y + 1.7, 2.0), Vector3(-200.0, 0.0, -60.0), "c30o_view_horn.png"],
			[Vector3(CLIMB_X, Blachernae.WALK_Y + 1.7, 2.0), Vector3(CLIMB_X, 0.0, 120.0), "c30o_view_field.png"]]:
		cv.global_position = v[0]
		cv.look_at(v[1], Vector3.UP)
		await get_tree().create_timer(0.5).timeout
		await _shot_png(v[2])
	get_tree().quit()
