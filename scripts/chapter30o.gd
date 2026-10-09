extends Node3D
## Bölüm 30 (Osmanlı tarafı) — Blakherna (Tolga · 12 Mayıs 1453, gece yarısı, saray önündeki sur).
##
## O gece Osmanlılar Blakherna sarayı önündeki tek sura büyük bir gece hücumu yaptı; İmparator bizzat geldi ve hücum
## püskürtüldü. Tolga Zağanos Paşa'nın askerleriyle:
##   1. merdiveni ekipçe sura taşı (karanlıkta, surdan ok yağar)
##   2. merdiveni daya, tırman: taş düşerken dur, sonra çık (26o'daki merdiven)
##   3. sur yolunda dövüş (WaveRunner, iki dalga; kuleden bir tüfekçi)
##   4. geri çekilme borusu: muhafızlar sur yolunda üstümüze yürür; merdivene koşup panikle inilir (merdiveni iterler:
##      yetişilmezse merdivenle birlikte devrilip çalıya uçulur). Sur dibinde yaralı bir azap; sırtına al, ateşlerin
##      hizasına getir
##   Tespit: sur yolunda meşalelerin arasında İmparator.
##   30O.1 Sur yolunda tutunuldu, düzenli çekilindi · 30O.2 Sur yolundan atıldın, yaralıyı yine getirdin
## Kaza rotası (30O.2, Dallanma v3 §3): gece yarısından sonra surun dibinde ölüler toplanırken bir Rum çıkışı topal
## kâtibi yakalar; Grant tercüman ister. Sıradaki sayfa Lağım (21), Bizans tarafında, esir olarak (Siege.DETOUR).
##   --autotest[=lose|sprint]   (varsayılan: 30O.1, merdivenle devrilir; sprint: koşarak iner, merdiven boş devrilir)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const CLIMB_X := 10.0
const TILT := 16.0
const START := Vector3(10.0, 0.0, 40.0)
const PLANT := Vector3(10.0, 0.0, 8.0)
const SAFE_Z := 34.0
const TOWER_X := 20.0                  # tüfekçinin kulesi (Blachernae.TOWERS)
## Düşülen çalı: merdivenin doğusunda, surdan birkaç adım açıkta (oradan İmparator mazgal aralığında görünür)
const BUSH := Vector3(CLIMB_X + 2.8, 0.0, Blachernae.WALL_Z1 + 7.4)
## Kuledeki tüfekçi: kılıca davrandığında da aynı kişi (Gunner.draw_sword)
const GUNNER_LOOK := {"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "helm", "mustache": true, "beard": true}

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
var extras: Node3D
var reinforcements: Array[Soldier] = []
## Panik inişi (_flee_down): nasıl inildi
var pushed := false            # muhafız merdiveni itti
var rode := false              # itilen merdivenle birlikte devrildi, çalıya uçtu
var made_it := false           # merdiven devrilmeden dibe yetişti
var shoved := false            # sur yolunda yakalandı, omuzlanıp çalıya atıldı
var _routs: Array[Rout] = []
var _late: Soldier             # geç kalan azap: tepeye varır, durumu görünce kayarak iner
var _flee_done := false
var _chasers_cache: Array = []
const CHASE_SPEED := 1.9       # muhafızların sur yolunda yürüyüşü (oyuncu koşarak kaçar)
const WOBBLE := 1.3            # itilen merdivenin sallanması (sn)
const SAFE_T := 1.6            # devrilirken bu basamağın altındaysa atlayıp kurtulur
const PUSH_AFTER := 3.0        # merdivene tutunduktan sonra itme (sallanma bitince karar: Shift'le inen yetişir)


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
	extras = bx
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
	var gn := Gunner.spawn(self, _gunner_spot(), player, hud, 6.0, Color("5a2a6a"), "helm", GUNNER_LOOK)
	# Zağanos'un azapları aynı merdivenden çıkıp yanına atlar; sur yolundaki nöbetçiler de kılıca davranır
	var al := {"base": ladder.point_at(0.0) + ladder.front_dir() * 0.35, "top": ladder.point_at(ladder.height - 0.3) + ladder.front_dir() * 0.3,
		"land": ladder.top_exit() - Vector3(0, 0.1, 0)}
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": specs, "max_active": 2, "skill": 0.45, "limit": 60.0, "allies": 2, "ally_ladder": al, "rally_foes": 1},
		{"specs": more, "max_active": 2, "skill": 0.48, "limit": 60.0, "allies": 2, "ally_ladder": al,
		"intro": func():
			# Haberi getiren savunucu dalgayla arkadan gelir: oyuncu sesine döner (yoksa kartta konuşan, ekranda kimse yok)
			var dw := hud.find_speaker("SPK_DEFENDER")
			# Yaklaşınca haykırır: girişten koşarken uzaktaydı, kazan başındaki askerin ardında kalıyordu (personhidden)
			var wt := 0.0
			while dw and is_instance_valid(dw) and dw.global_position.distance_to(player.global_position) > 5.5 and wt < 4.0:
				await get_tree().process_frame
				wt += get_process_delta_time()
				dw = hud.find_speaker("SPK_DEFENDER")
			if dw:
				player.face(LivePortrait.head_of(dw))
			await hud.say("SPK_DEFENDER", "D30O_D_EMPEROR")}], "kilij")
	await gn.settle_test()
	_duel_won = r["won"]
	player.frozen = true
	if _duel_won and is_instance_valid(gn) and gn.engaged:
		# Emir gelmeden kuleye çıkıldı: tüfekçi kılıca davranıp dövüşe katılmıştı (vurulup indirildiyse kule alındı)
		tower_won = gn.duelist == null or not is_instance_valid(gn.duelist) or not gn.duelist.alive()
		if tower_won:
			await hud.say("SPK_TOLGA", "D30O_T_TOWER_WON")
		if player.global_position.y > Blachernae.WALK_Y + 3.0:
			await hud.fade_to(1.0, 0.4)
			player.ladder = null
			player.global_position = tower_ladder.global_position + Vector3(-1.2, 0.05, 0.0)
			await hud.fade_to(0.0, 0.4)
	elif _duel_won:
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
	# Tüfeği yere atar, yerdeki kılıcı alır: aynı adam (eskiden silinip yerine başka kıyafetli biri geliyordu)
	var foe: Duelist = null
	if is_instance_valid(gn):
		gunner_shots = gn.shots
		gunner_dodged = gn.dodged
		at = gn.global_position + Vector3(0.6, 0.0, 1.2)
		foe = await gn.draw_sword({"skill": 0.5, "hp": 70.0, "name": "SPK_DEFENDER"})
		gn.stop()
	player.frozen = false
	var spec: Dictionary = {"duelist": foe} if foe else {"pos": at, "blade": "spathion", "shield": false,
		"name": "SPK_DEFENDER", "skill": 0.5, "hp": 70.0, "look": GUNNER_LOOK}
	var r: Dictionary = await StoryDuel.fight(self, hud, player, [spec], "kilij", 0.5, 60.0)
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
## lost false: dövüş kazanılmıştı, kaçarken muhafız omuzladı (yenilgi sayılmaz)
func _fall_off(lost := true) -> void:
	fell = fell or lost
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
## Neden geri çekiliniyor: sur yolu tutulmuşken kulelerin kapılarından bölük bölük saray muhafızı dökülür (İmparator'un
## çevresinde toplanırlar, öbür yandan da kuleden çıkarlar), mızraklar hücum edenlere doğrulur. Paşa boruyu bunun için
## çaldırır. Eskiden kazanılmış sur yolundan sebepsiz "geri!" deniyordu.
func _reinforce() -> void:
	var y := Blachernae.WALK_Y
	var zc := (Blachernae.WALL_Z0 + Blachernae.WALL_Z1) * 0.5
	var on_wall := absf(player.global_position.y - y) < 1.5
	var px := player.global_position.x if on_wall else CLIMB_X
	var taken: Array = [emperor.global_position, player.global_position]
	for g in guards:
		if is_instance_valid(g) and is_instance_valid(g.soldier) and g.soldier.visible:
			taken.append(g.soldier.global_position)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3031
	var coats := [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96"), Color("6a5a3a"), Color("5a2a6a")]
	# Batı kulesinden (x -20, doğu yüzü x -16) İmparator'un ardına; tüfekçinin kulesinden (x 20, batı yüzü x 16) oyuncuya
	# doğru. Kapıdan birer birer çıkarlar (sırayla, birbirinin içinden geçmeden), şeritlerine dağılırlar.
	var groups := [[Vector3(-15.5, y, zc), -5.6, -1.0, 9], [Vector3(15.5, y, zc), minf(14.2, maxf(px + 3.0, 11.0)), -1.0, 6]]
	var moves: Array = []
	for gr: Array in groups:
		var x0: float = gr[1]
		if float(gr[2]) < 0.0 and (gr[0] as Vector3).x > 0.0:
			x0 = minf(x0 + 1.1, 14.6)        # doğu bölüğü kapıdan geriye doğru dizilir (kuleye girmeden)
		var start_x := (gr[0] as Vector3).x
		for i in int(gr[3]):
			var to := Vector3.INF
			for k in 9:
				var row := i / 3 + k / 3
				var c := Vector3(x0 - float(row) * 1.1, y, zc + float((i + k) % 3 - 1) * 1.0)
				var clash := false
				for t: Vector3 in taken:
					if Vector2(t.x - c.x, t.z - c.z).length() < 0.9:
						clash = true
				# Sur yolundaysa doğu bölüğü oyuncunun doğusuna dizilir: kaçarken arkadan gelirler, merdivenle arasına girmezler
				var behind := not on_wall or start_x < 0.0 or c.x > px + 0.9
				if not clash and absf(c.x) < 15.0 and behind:
					to = c
					break
			if to == Vector3.INF:
				continue
			taken.append(to)
			var s := Soldier.new(coats[(i + reinforcements.size()) % coats.size()], "stand", "helm")
			s.set_meta("no_talk", true)
			s.set_meta("climber", true)
			add_child(s)
			s.equip("spear" if i % 3 != 2 else "sword_shield", Color("7a2a24"))
			var start: Vector3 = gr[0]
			s.global_position = start
			s.visible = false
			reinforcements.append(s)
			moves.append([s, start, to, float(i) * 0.38 + rng.randf_range(0.0, 0.08)])
	var look := emperor.global_position if on_wall else Vector3(CLIMB_X, y, zc)
	player.face(look + Vector3(0, 1.4, 0))
	Audio.sfx("war_cry", -2.0, 0.9)
	Audio.stinger("warn", -8.0)
	var t := 0.0
	var all_in := false
	while not all_in and t < 7.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		all_in = true
		for mv: Array in moves:
			var s := mv[0] as Soldier
			var a: Vector3 = mv[1]
			var b: Vector3 = mv[2]
			var k := clampf((t - float(mv[3])) * 4.2 / maxf(a.distance_to(b), 0.5), 0.0, 1.0)
			if k < 1.0:
				all_in = false
			if k <= 0.0:
				continue
			s.visible = true
			# Kapıdan önce düz çıkar, sonra şeridine kayar (yan yana koşanlar birbirinin içinden geçmesin)
			var p := Vector3(lerpf(a.x, b.x, k), y, lerpf(a.z, b.z, clampf(k * 3.0, 0.0, 1.0)))
			s.global_position = p
			s.face_toward(Vector3(b.x, y, b.z) + Vector3(signf(b.x - a.x), 0, 0))
			if s.rig:
				s.rig.activity = ("run_a" if fmod(t * 2.6 + float(mv[3]), 1.0) < 0.5 else "run_b") if k < 1.0 else "thrust_a"
			if k >= 1.0:
				s.face_toward(player.global_position if on_wall else Vector3(CLIMB_X, y, 40.0))
	await hud.say("SPK_TOLGA", "D30O_T_FLOOD")


func _retreat() -> void:
	phase = "retreat"
	if not fell and player.global_position.y > Blachernae.WALK_Y - 2.0:
		await _flee_down()
	else:
		await _retreat_fade()
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


## Hücum bitti: hendek önünde koşanlar dağılır (bozgun başlar)
func _clear_field() -> void:
	if is_instance_valid(extras):
		extras.visible = false
		extras.process_mode = Node.PROCESS_MODE_DISABLED


## Dövüş kaybedildiyse (oyuncu zaten sur dibindeki çalıda): boru, kararma; muhafızlar mazgallara dizilip aşağıya taş ve
## ok yağdırır, oyuncu yaralının yanında açar.
func _retreat_fade() -> void:
	await _reinforce()
	Audio.sfx("drum_boom", -2.0, 0.7)
	Audio.stinger("warn", -6.0)
	await hud.say("SPK_ZAGANOS", "D30O_Z_RETREAT")
	await hud.fade_to(1.0, 0.5)
	emperor.visible = false
	_clear_field()
	# Sur yolundaki herkes (yatan cesetler, nöbetçiler) dolu sayılır: muhafız boş mazgala geçer
	var busy: Array = []
	for n in get_tree().get_nodes_in_group("persons") + get_tree().get_nodes_in_group("soldiers"):
		var nd := n as Node3D
		if nd and nd.is_visible_in_tree() and not (nd is Soldier and nd in reinforcements) and absf(nd.global_position.y - Blachernae.WALK_Y) < 2.0:
			busy.append(nd.global_position)
	var mx := CLIMB_X - 16.0
	for i in reinforcements.size():
		var s := reinforcements[i]
		var spot := Vector3.INF
		while mx < 14.6 and spot == Vector3.INF:
			var c := Vector3(mx, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.45)
			mx += 1.4
			if busy.all(func(b: Vector3): return Vector2(b.x - c.x, b.z - c.z).length() > 1.0):
				spot = c
		if spot == Vector3.INF:
			s.visible = false
			continue
		s.global_position = spot
		s.face_toward(s.global_position + Vector3(0, 0, 5.0))
		if s.rig:
			s.rig.activity = "throw_down" if i % 3 == 0 else "lean_down"
	player.global_position = Vector3(CLIMB_X - 1.6, Blachernae.slope_y(Blachernae.WALL_Z1 + 2.4) + 0.05, Blachernae.WALL_Z1 + 2.4)
	wounded.visible = true
	_start_rout()
	player.face(wounded.global_position + Vector3(0, 0.3, 0))
	await hud.fade_to(0.0, 0.5)


# ================================================================ panik inişi

## 4a. Panik inişi (sur yolu tutulduysa): boru çalınca herkes merdivene. Saray muhafızları mızrakları indirip sur yolunda
## arkamızdan gelir; yakalarsa omuzlayıp mazgalın üstünden çalıya atar. Merdivene tepeden tutunulur (S ile inilir, Shift
## hızlı). Merdivendeyken tepeye varan muhafız merdiveni iter: merdiven sallanır; dibe yetişilemezse merdivenle birlikte
## ovaya devrilip çalıya savrulunur, yetişilirse boş merdiven yana yıkılır. Geç kalan bir azap tam o an tepeye varır,
## durumu görünce kayarak iner; dövüşte yanımıza çıkan azaplar da kaçar: biri mazgal aralığından atlar, öbürü önce yanlış
## yöne (İmparator'un muhafızlarına) koşar. Eskiden ekran kararıyor, oyuncu kendini sur dibinde buluyordu (kullanıcı:
## "iniş sahnemizi oynamamız lazım, panikle kaçmamız lazım, komedi").
func _flee_down() -> void:
	_late = _late_azap()
	await _reinforce()
	wounded.visible = true
	tower_ladder.remove_from_group("ladder")          # kuleye geri çıkılmaz
	var allies := _wall_allies()
	var crenels := _crenels(allies)
	# Kaçanların ordugâhta durduğu yerler (bozgundakiler buralara varmaz: iç içe durmasınlar)
	var ends: Array = [Vector3(CLIMB_X - 3.0, 0.0, SAFE_Z + 7.0)]
	for c: float in crenels:
		ends.append(Vector3(c, 0.0, SAFE_Z + 9.5))
	_clear_field()
	_start_rout(false, ends)
	Audio.sfx("drum_boom", -2.0, 0.7)
	Audio.stinger("warn", -6.0)
	_azap_pop(_late)
	await hud.say("SPK_ZAGANOS", "D30O_Z_RETREAT")
	while is_instance_valid(_late) and _late.has_meta("popping"):
		await get_tree().process_frame
	if is_instance_valid(_late):
		player.face(_late.global_position + Vector3(0, 1.5, 0))
		await hud.say("SPK_AZAP", "D30O_A_LATE")
		_azap_slide(_late, ends[0])
	var chasers := _chasers()
	for i in allies.size():
		_ally_flee(allies[i], crenels[i], i, ends[i + 1])
	hud.bark("SPK_DEFENDER", "D30O_D_CHASE", 1.6)
	Audio.sfx("war_cry", -6.0, 1.1)
	await get_tree().create_timer(0.5).timeout
	player.frozen = false
	player.ladder_no_top = true
	hud.set_objective(tr("UI_OBJ30O_FLEE"), ladder.point_at(ladder.height) + Vector3(0, 0.8, 0))
	get_tree().create_timer(1.2).timeout.connect(func():
		if player.ladder == null and not player.frozen:
			hud.bark("SPK_TOLGA", "D30O_T_PANIC", 2.2))
	await _flee_loop(chasers)
	for a in ["move_back", "sprint"]:
		Input.action_release(a)
	player.frozen = true
	player.ladder = null
	player.ladder_no_top = false
	hud.set_qte("")
	hud.set_objective("")
	for rt in _routs:
		if is_instance_valid(rt):
			rt.player = player
	# Muhafızlar mazgallara: aşağıya taş atar, bakar
	for i in chasers.size():
		var s := chasers[i][0] as Soldier
		if is_instance_valid(s):
			s.face_toward(s.global_position + Vector3(0, 0, 5.0))
			if s.rig:
				s.rig.activity = "throw_down" if i % 2 == 0 else "lean_down"
	if rode:
		await hud.say("SPK_TOLGA", "D30O_T_RIDE")
	elif shoved:
		await hud.say("SPK_TOLGA", "D30O_T_SHOVED")
	else:
		player.face(ladder.point_at(ladder.height * 0.5))
		await hud.say("SPK_TOLGA", "D30O_T_DOWN_OK")
	player.face(wounded.global_position + Vector3(0, 0.3, 0))


## Kaçış: muhafızlar yürür, merdivene tepeden tutunulur, tepeye varan muhafız merdiveni iter. Biri bitene dek (_flee_done).
func _flee_loop(chasers: Array) -> void:
	var t := 0.0
	var grab_t := -1.0
	var lead: Soldier = chasers[0][0]
	var push_spot := Vector3(CLIMB_X + 0.65, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 1.0)
	var sprint := GameState.autotest_variant == "sprint"
	_flee_done = false
	while not _flee_done:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var pp := player.global_position
		var on_walk := grab_t < 0.0 and player.ladder == null and pp.y > Blachernae.WALK_Y - 0.8 and not player.frozen
		# Merdivenin başına varınca tutunur (tepeden inilir; sur yolundan W ile tutunulamıyordu)
		if on_walk:
			var te := ladder.top_exit()
			if Vector2(pp.x - te.x, pp.z - te.z).length() < 1.25:
				_grab_ladder()
				grab_t = t
				on_walk = false
		if GameState.autotest and not player.frozen:
			if on_walk and t > 0.4:
				player.global_position = ladder.top_exit()
			var down := player.ladder == ladder
			if down:
				Input.action_press("move_back")
			else:
				Input.action_release("move_back")
			if down and sprint:
				Input.action_press("sprint")
			else:
				Input.action_release("sprint")
		# Muhafızlar: öndeki oyuncunun peşinde; oyuncu merdivendeyse öndeki merdivenin başına (iter), ötekiler arkasında
		var near := _walk_people(chasers)
		for c: Array in chasers:
			var s := c[0] as Soldier
			if not is_instance_valid(s):
				continue
			var want: Vector3
			if s == lead and grab_t >= 0.0:
				want = push_spot if not pushed else s.global_position
			elif grab_t >= 0.0 or player.frozen:
				want = s.global_position        # ötekiler yerinde kalır, mızrak dürter (merdivenin başına giden yolu kesmez)
			else:
				var wx := maxf(pp.x + 0.8, CLIMB_X + 1.3) + float(c[1])
				want = Vector3(wx, Blachernae.WALK_Y, clampf(pp.z, 0.8, 3.8) if s == lead else float(c[2]))
			_chase_step(c, want, dt, near, grab_t < 0.0 and not player.frozen)
		# Sur yolunda yakalandı (ya da merdivene hiç gitmedi)
		if on_walk and t > 1.2:
			var by: Soldier = null
			for c: Array in chasers:
				var s := c[0] as Soldier
				if is_instance_valid(s) and Vector2(s.global_position.x - pp.x, s.global_position.z - pp.z).length() < 0.85:
					by = s
			if by == null and t > (14.0 if GameState.autotest else 32.0):
				by = lead
			if by:
				await _shoved_off(by)
				return
		# Merdivenin başına varan muhafız iter (oyuncu tutunduktan PUSH_AFTER sn sonra: koşarak inen yetişir, ağır inen
		# merdivenle devrilir; dibe yetişmişse de boş iter)
		if grab_t >= 0.0 and not pushed and t - grab_t > PUSH_AFTER and is_instance_valid(lead) and lead.global_position.distance_to(push_spot) < 0.3:
			_push_ladder(lead)
		if grab_t >= 0.0 and not pushed and t - grab_t > 8.0:
			_push_ladder(null)          # muhafız takıldıysa merdiven yine itilir
		if grab_t >= 0.0 and not made_it and not rode and player.ladder == null and not player.frozen and pp.y < 2.0:
			made_it = true


## Sur yolundaki kişiler (kovalayanların çarpmaması için; yerde yatan ceset sayılmaz)
func _walk_people(chasers: Array) -> Array[Node3D]:
	var out: Array[Node3D] = []
	var mine: Array = chasers.map(func(c: Array): return c[0])
	for n in get_tree().get_nodes_in_group("persons") + get_tree().get_nodes_in_group("soldiers"):
		var nd := n as Node3D
		if nd == null or nd in mine or not nd.is_visible_in_tree() or nd.has_meta("corpse"):
			continue
		var q := nd.global_position
		if absf(q.y - Blachernae.WALK_Y) < 1.2 and q.x > CLIMB_X - 2.0 and q.x < TOWER_X:
			out.append(nd)
	return out


## Bir muhafızın adımı: hedefe yürür (önündekinin içine girmez), yürürken koşu adımı, durunca mızrağı ileri dürter
func _chase_step(c: Array, want: Vector3, dt: float, near: Array[Node3D], at_player: bool) -> void:
	var s := c[0] as Soldier
	var p := s.global_position
	var to := Vector3(want.x - p.x, 0.0, want.z - p.z)
	var d := to.length()
	var moving := false
	if d > 0.06:
		var nxt := p + to / d * minf(CHASE_SPEED * dt, d)
		var free := true
		var others: Array = near.duplicate()
		for o: Array in _chasers_cache:
			if o[0] != s and is_instance_valid(o[0]):
				others.append(o[0])
		for o in others:
			var q := (o as Node3D).global_position
			var dn := Vector2(q.x - nxt.x, q.z - nxt.z).length()
			if dn < 0.65 and dn < Vector2(q.x - p.x, q.z - p.z).length():
				free = false
				break
		if free:
			s.global_position = nxt
			c[3] = float(c[3]) + nxt.distance_to(p)
			moving = true
	var look := player.global_position if at_player else ladder.point_at(ladder.height)
	s.face_toward(Vector3(look.x, p.y, look.z))
	if s.rig:
		if moving:
			s.rig.activity = "run_a" if fmod(float(c[3]) * 1.3, 1.0) < 0.5 else "run_b"
		elif at_player and s.global_position.distance_to(player.global_position) < 2.6:
			s.rig.activity = "thrust_b" if fmod(_t * 1.7 + float(c[1]), 1.0) < 0.35 else "thrust_a"
		else:
			s.rig.activity = "thrust_a"


## Kovalayanlar: doğu bölüğü (kulenin kapısından gelip oyuncunun arkasında dizilmişler); azsa kapıdan iki muhafız daha
## çıkar. Her biri: [asker, öndekine göre x farkı, şeridi (z), yürüdüğü yol]
func _chasers() -> Array:
	var px := player.global_position.x
	var list: Array[Soldier] = []
	for s in reinforcements:
		if is_instance_valid(s) and s.visible and s.global_position.x > maxf(px, CLIMB_X) + 0.4:
			list.append(s)
	var zc := (Blachernae.WALL_Z0 + Blachernae.WALL_Z1) * 0.5
	for k in maxi(0, 2 - list.size()):
		var s := Soldier.new([Color("8a8e96"), Color("7a2a24")][k], "stand", "helm")
		s.set_meta("no_talk", true)
		s.set_meta("climber", true)
		add_child(s)
		s.equip("spear", Color("7a2a24"))
		s.global_position = Vector3(15.4, Blachernae.WALK_Y, zc + (float(k) - 0.5) * 1.3)
		reinforcements.append(s)
		list.append(s)
	# Öndeki: merdivenin başına en yakın olan (iterken ötekilerin önünden geçmez); ötekiler en az 0,9 m arkasında yürür
	var spot := Vector3(CLIMB_X, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 1.0)
	list.sort_custom(func(a: Soldier, b: Soldier) -> bool: return a.global_position.distance_to(spot) < b.global_position.distance_to(spot))
	list[0].set_meta("spk", "SPK_DEFENDER")
	var out: Array = []
	var x0 := list[0].global_position.x
	for i in list.size():
		var s := list[i]
		out.append([s, maxf(s.global_position.x - x0, i * 0.9), s.global_position.z, 0.0])
	_chasers_cache = out
	return out


## Merdivene tepeden tutunur: yüzü sura dönük, en üst basamaklarda; S ile inilir
func _grab_ladder() -> void:
	player.ladder = ladder
	player._ladder_t = ladder.height - 0.7
	player.ladder_side = 0.0
	player.velocity = Vector3.ZERO
	player.face(ladder.point_at(ladder.height - 2.6))
	hud.set_objective("")
	hud.set_qte(tr("UI_HINT30O_DOWN"))
	hud.bark("SPK_TOLGA", "D30O_T_DONTLOOK", 2.2)
	Audio.sfx("wood_creak", -10.0, 1.2)


## Muhafız merdivenin başını mızrağıyla iter: merdiven surdan ayrılıp geri çarpa çarpa sallanır, sonra devrilir.
## Oyuncu hâlâ yukarıdaysa merdivenle birlikte ovaya devrilir; son basamaklardaysa atlar, merdiven boş yıkılır.
func _push_ladder(g: Soldier) -> void:
	pushed = true
	_ladder_solid(false)
	if g:
		g.face_toward(Vector3(CLIMB_X, g.global_position.y, Blachernae.WALL_Z1 + 2.0))
	hud.bark("SPK_DEFENDER", "D30O_D_PUSH", 1.6)
	Audio.sfx("heave_shout", -4.0, 1.1)
	if player.ladder == ladder:
		get_tree().create_timer(0.6).timeout.connect(func():
			if player.ladder == ladder:
				hud.bark("SPK_TOLGA", "D30O_T_WOBBLE", 1.8))
	var w := 0.0
	var knocks := 0
	while w < WOBBLE:
		await get_tree().process_frame
		w += get_process_delta_time()
		var sw := sin(w * 8.0)
		ladder.rotation.x = absf(sw) * (0.04 + 0.11 * w / WOBBLE)
		if g and is_instance_valid(g) and g.rig:
			g.rig.activity = "thrust_b" if sw > 0.0 else "thrust_a"
		# Her geri çarpışta tahta taşa vurur
		if int(w * 8.0 / PI) > knocks:
			knocks = int(w * 8.0 / PI)
			Audio.sfx("wood_creak", -8.0, randf_range(0.8, 1.1))
	hud.set_qte("")
	if player.ladder == ladder and player._ladder_t > SAFE_T:
		await _ride()
	else:
		if player.ladder == ladder:
			player.ladder = null              # son basamaklardan atlar
			made_it = true
		await _topple_empty()
	_flee_done = true


## Merdivenle birlikte devrilir: merdiven ovaya doğru yıkılır (oyuncu tutunduğu basamakta, kamera surun tepesine, itip
## bakakalan muhafızlara dönük); yere yaklaşınca yana, çalıya savrulur; merdiven yanına çarpar.
func _ride() -> void:
	rode = true
	var t_on := clampf(player._ladder_t, 0.0, ladder.height - 0.5)
	player.frozen = true
	player.ladder = null
	Audio.sfx("fall_scream", -2.0, 1.0)
	Audio.sfx("whoosh_fly", -4.0, 0.6)
	var a0 := ladder.rotation.x
	var a1 := deg_to_rad(TILT + 89.6)
	var fling_at := deg_to_rad(TILT + 52.0)
	var land := _ride_land(t_on, deg_to_rad(52.0))
	_bush(land)                                # savrulacağı yerde çalı (kamera surda; arkada kalır)
	var k := 0.0
	var flung := false
	var fly: Tween
	while k < 1.0:
		await get_tree().process_frame
		k = minf(k + get_process_delta_time() / 1.8, 1.0)
		ladder.rotation.x = lerpf(a0, a1, k * k)
		if not flung:
			player.global_position = ladder.point_at(t_on) + ladder.front_dir() * 0.42
			# Bakış surun tepesine (muhafızlar uzaklaşır), biraz da merdivenin ucuna
			player.face(ladder.point_at(ladder.height).lerp(Vector3(CLIMB_X + 0.6, Blachernae.WALK_Y + 1.4, Blachernae.WALL_Z1 - 1.0), 0.75))
			if ladder.rotation.x >= fling_at:
				flung = true
				var from := player.global_position
				var top := from.lerp(land, 0.4) + Vector3(0, 0.9, 0)
				fly = create_tween()
				fly.tween_method(func(u: float):
					player.global_position = from.lerp(top, u).lerp(top.lerp(land + Vector3(0, 0.75, 0), u), u), 0.0, 1.0, 0.5)
	_crash_fx()
	if fly and fly.is_running():
		await fly.finished
	Audio.sfx("land_thud", 0.0, 0.8)
	Vfx.dust(self, land, 0.6)
	player.global_position = land + Vector3(0, 0.1, 0)
	player.shake(0.9)
	player.stagger(0.8)
	player.hurt(10.0, ladder.point_at(ladder.height), true)
	player.face(Vector3(CLIMB_X, Blachernae.WALK_Y + 1.2, Blachernae.WALL_Z1 - 0.6))


## Savrulma yeri: merdiven surdan r kadar ayrıldığında oyuncunun altının biraz yanı (merdivenin düştüğü çizginin dışı)
func _ride_land(t_on: float, r: float) -> Vector3:
	var p := ladder.global_position + Vector3(0, cos(r), sin(r)) * t_on + Vector3(0, -sin(r), cos(r)) * 0.42
	return Vector3(CLIMB_X + 1.9, 0.0, clampf(p.z + 0.8, Blachernae.WALL_Z1 + 6.0, 22.0))


## Boş merdiven yana (batıya, surun dibine) yıkılır
func _topple_empty() -> void:
	Audio.sfx("whoosh_fly", -6.0, 0.5)
	var tw := ladder.create_tween()
	tw.tween_property(ladder, "rotation:x", 0.0, 0.25)
	tw.tween_property(ladder, "rotation:z", deg_to_rad(89.0), 1.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tw.finished
	_crash_fx()


## Merdiven yere çarpar: boyunca toz, gümleme
func _crash_fx() -> void:
	Audio.sfx("land_thud", -2.0, 0.7)
	for u: float in [0.3, 0.6, 0.9]:
		var at := ladder.point_at(ladder.height * u)
		Vfx.dust(self, Vector3(at.x, 0.1, at.z), 0.5)
	if player.global_position.distance_to(ladder.global_position) < 14.0:
		player.shake(0.4)


## Devrilen merdiven: tutunulmaz, içinden geçilir (yerde yatan merdiven yürüyüşü kesmesin)
func _ladder_solid(on: bool) -> void:
	if not on and ladder.is_in_group("ladder"):
		ladder.remove_from_group("ladder")
	for cs in ladder.find_children("*", "CollisionShape3D", true, false):
		(cs as CollisionShape3D).set_deferred("disabled", not on)


## Sur yolunda yakalandı: muhafız mızrağının sapıyla omuzlar, oyuncu mazgalın üstünden çalıya uçar (yenilgi sayılmaz)
func _shoved_off(g: Soldier) -> void:
	shoved = true
	hud.set_objective("")
	if g and is_instance_valid(g):
		g.face_toward(player.global_position)
		if g.rig:
			g.rig.activity = "thrust_b"
	Audio.sfx("heave_shout", -3.0, 1.0)
	Audio.sfx("fall_scream", -3.0, 1.1)
	var from := g.global_position if g and is_instance_valid(g) else player.global_position
	await _fall_off(false)
	player.hurt(8.0, from, true)
	_flee_done = true


# ---------------------------------------------------------------- kaçan azaplar

## Geç kalan azap: merdivenin üst basamaklarında (sur yolundan görünmez), boruyla birlikte başını mazgaldan uzatır
func _late_azap() -> Soldier:
	var s := Soldier.new(Color("8a6a4a"), "stand", "azap")
	s.set_meta("spk", "SPK_AZAP")
	s.set_meta("no_talk", true)
	s.set_meta("climber", true)
	add_child(s)
	_on_ladder(s, ladder.height - 2.6)
	if s.rig:
		s.rig.activity = "climb_a"
	return s


## Merdivende (t: ellerin yüksekliği): yüzü sura dönük, ayakları basamakta. lift: en üstte göğsü mazgal aralığından görünsün
func _on_ladder(s: Node3D, t: float, lift := 0.0) -> void:
	var p := ladder.point_at(t) + ladder.front_dir() * 0.35 - Vector3(0, 0.9 - lift, 0)
	p.y = maxf(p.y, ladder.global_position.y)
	s.global_position = p
	s.global_rotation = Vector3(0, PI, 0)


func _azap_pop(s: Soldier) -> void:
	s.set_meta("popping", true)
	var t0 := ladder.height - 2.6
	var u := 0.0
	while u < 1.0:
		await get_tree().process_frame
		if not is_instance_valid(s):
			return
		u = minf(u + get_process_delta_time() / 1.3, 1.0)
		_on_ladder(s, lerpf(t0, ladder.height, u), 0.5 * u)
		if s.rig:
			s.rig.activity = "climb_a" if fmod(u * 6.0, 1.0) < 0.5 else "climb_b"
	s.remove_meta("popping")


## Durumu görür, kayarak iner (basamaklara basmadan), dipte sendeler, ordugâha koşar
func _azap_slide(s: Soldier, end: Vector3) -> void:
	Audio.sfx_at("whoosh_fly", s, -4.0)
	var t0 := ladder.height
	var u := 0.0
	if s.rig:
		s.rig.activity = "climb_a"
	while u < 1.0:
		await get_tree().process_frame
		if not is_instance_valid(s):
			return
		u = minf(u + get_process_delta_time() / 1.1, 1.0)
		_on_ladder(s, lerpf(t0, 0.9, u * u), 0.5 * (1.0 - u))
	Audio.sfx_at("land_thud", s, -6.0)
	Vfx.dust(self, s.global_position, 0.35)
	if s.rig:
		s.rig.activity = "lean_down"
	await get_tree().create_timer(0.35).timeout
	await _run_off(s, end, 4.2)


## Yerde bir noktaya koşar (koşu adımı), varınca soluklanır
func _run_off(s: Soldier, end: Vector3, speed: float) -> void:
	var walked := 0.0
	while is_instance_valid(s):
		await get_tree().process_frame
		var p := s.global_position
		var to := Vector3(end.x - p.x, 0.0, end.z - p.z)
		if to.length() < 0.15:
			break
		var st := to.limit_length(speed * get_process_delta_time())
		s.global_position = Vector3(p.x + st.x, Blachernae.slope_y(p.z + st.z), p.z + st.z)
		s.face_toward(end)
		walked += st.length()
		if s.rig:
			s.rig.activity = "run_a" if fmod(walked * 0.9, 1.0) < 0.5 else "run_b"
	if is_instance_valid(s) and s.rig:
		s.rig.activity = "lean_down"


## Dövüşte merdivenden yanımıza çıkan azaplar (Duelist dostlar): sur yolunda, ayakta olanlar
func _wall_allies() -> Array[Duelist]:
	var out: Array[Duelist] = []
	for n in get_tree().get_nodes_in_group("sight_dodgers"):
		var d := n as Duelist
		if d and d.team == 0 and d.alive() and d.is_visible_in_tree() and absf(d.global_position.y - Blachernae.WALK_Y) < 1.5 \
				and absf(d.global_position.x - CLIMB_X) < 12.0:
			out.append(d)
	# Mazgala yakın olan önce atlar; öbürü önce yanlış yöne koşar
	out.sort_custom(func(a: Duelist, b: Duelist) -> bool: return a.global_position.z > b.global_position.z)
	return out.slice(0, 2)


## Her dosta bir mazgal aralığı (mazgallar x = −59 + 1,9k; aralıkların ortası 0,95 kaydırılmış): merdivenin ve kazanın
## yanı değil, kulenin önü değil, ikisi aynı aralıktan değil
func _crenels(allies: Array[Duelist]) -> Array[float]:
	var out: Array[float] = []
	for d in allies:
		var best := INF
		var bx := d.global_position.x
		for k in 70:
			var cx := -58.05 + 1.9 * k
			if absf(cx - CLIMB_X) < 1.4 or absf(cx - (CLIMB_X - 6.0)) < 1.3 or cx > TOWER_X - 5.0 or cx in out:
				continue
			if absf(cx - bx) < absf(best - bx):
				best = cx
		out.append(best)
	return out


## Dost azap kaçar: mazgal aralığına koşar, atlar, iner, ordugâha topallar. i 1: önce İmparator'un muhafızlarına doğru
## koşar, durur, döner.
func _ally_flee(d: Duelist, cx: float, i: int, end: Vector3) -> void:
	await get_tree().create_timer(0.5 + 1.1 * i).timeout
	if not is_instance_valid(d) or not d.alive():
		return
	d.target = null
	d.run_speed = 4.2
	if i == 1:
		d.path = [Vector3(d.global_position.x - 2.6, Blachernae.WALK_Y, d.global_position.z)]
		await _path_done(d, 2.5)
		if not is_instance_valid(d):
			return
		if d.body:
			d.body.set_meta("spk", "SPK_AZAP")
		hud.bark("SPK_AZAP", "D30O_AZ_WRONG", 1.8)
		await get_tree().create_timer(0.8).timeout
		if not is_instance_valid(d):
			return
	d.path = [Vector3(cx, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.65)]
	await _path_done(d, 3.0)
	if not is_instance_valid(d) or not d.alive():
		return
	d.path.clear()
	d.set_process(false)
	d.rotation.y = 0.0
	if d.body:
		d.body.set_meta("airborne", true)
	Audio.sfx_at("fall_scream", d, -4.0)
	await _leap(d, cx)
	if not is_instance_valid(d):
		return
	if d.body:
		d.body.remove_meta("airborne")
	d.set_process(true)
	d.run_speed = 2.0
	d.path = [end]


func _path_done(d: Duelist, limit: float) -> void:
	var w := 0.0
	while is_instance_valid(d) and not d.path.is_empty() and w < limit:
		await get_tree().process_frame
		w += get_process_delta_time()


## Mazgal aralığından atlayış: kalkar, dışarıya doğru düşer (bacaklar boşlukta koşmaya devam eder), yere iner
func _leap(n: Node3D, cx: float) -> void:
	var from := n.global_position
	var peak := Vector3(cx, Blachernae.WALK_Y + 1.25, Blachernae.WALL_Z1 + 0.55)
	var land := Vector3(cx, Blachernae.slope_y(Blachernae.WALL_Z1 + 6.0), Blachernae.WALL_Z1 + 6.0)
	var tw := create_tween()
	tw.tween_method(func(u: float):
		if not is_instance_valid(n):
			return
		if u < 0.25:
			var k := u / 0.25
			n.global_position = from.lerp(peak, 1.0 - (1.0 - k) * (1.0 - k))
		else:
			var k := (u - 0.25) / 0.75
			n.global_position = Vector3(cx, lerpf(peak.y, land.y, k * k), lerpf(peak.z, land.z, k)), 0.0, 1.0, 1.3)
	await tw.finished
	if is_instance_valid(n):
		n.global_position = land
		Audio.sfx_at("land_thud", n, -4.0)
		Vfx.dust(self, land, 0.45)


## Bozgun: sur dibinden ordugâha dağınık koşanlar (dönüp bakan, topallayan, yaralı koltuklayan); surdan ok ve taş.
## Sağdaki bölük tüfekçinin kulesinin önünden çıkar (kule surdan 10 m öne taşar). at_player: oklar oyuncunun çevresine
## de iner (oyuncu sur dibindeyse; sur yolundayken oklar oradan atılıyor). avoid: başka kaçanların varış yerleri.
func _start_rout(at_player := true, more_avoid: Array = []) -> void:
	var gy := func(_x: float, z: float) -> float: return Blachernae.slope_y(z)
	var avoid: Array = [zaganos.global_position] + more_avoid
	for side: Array in [[Vector3(CLIMB_X - 17.0, 0, Blachernae.WALL_Z1 + 3.0), Vector3(CLIMB_X - 4.5, 0, Blachernae.WALL_Z1 + 3.0), 7, 3011],
			[Vector3(CLIMB_X + 5.0, 0, Blachernae.WALL_Z1 + 6.9), Vector3(CLIMB_X + 16.0, 0, Blachernae.WALL_Z1 + 6.9), 6, 3012]]:
		var rt := Rout.new()
		add_child(rt)
		_routs.append(rt)
		rt.player = player if at_player else null
		rt.wall_top = [Vector3(CLIMB_X - 16.0, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.3), Vector3(CLIMB_X + 12.0, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.3)]
		rt.setup(side[0], side[1], SAFE_Z + 4.0, side[2], side[3], gy, avoid)


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
	ok = ok and (fell if v == "lose" else tower_won)
	# Panik inişi: varsayılanda bot yavaş iner, muhafız merdiveni iter, merdivenle devrilir; sprint'te dibe yetişir, merdiven
	# boş devrilir. Yenilgide (çalıdan) iniş yok.
	if v == "":
		ok = ok and pushed and rode and not made_it and not shoved
	elif v == "sprint":
		ok = ok and pushed and made_it and not rode and not shoved
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
	var flee := "ride" if rode else ("made" if made_it else ("shoved" if shoved else "fade"))
	print("AUTOTEST %s chapter=30o variant=%s outcome=%s stones=%d/%d gunner=%d/%d tower=%s fell=%s guards=%d pokes=%d flee=%s pushed=%s" % ["PASS" if ok else "FAIL", v, _outcome,
		stones - stone_hits, stones, gunner_dodged, gunner_shots, tower_won, fell, guards.size(), guard_pokes, flee, pushed])
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
	# Tüfekçi: iki eliyle omzunda; sonra tüfeği yere atıp yerdeki kılıcı alır (aynı adam)
	var gn := Gunner.spawn(self, _gunner_spot(), player, hud, 99.0, Color("5a2a6a"), "helm", GUNNER_LOOK)
	player.global_position = _gunner_spot() + Vector3(2.4, 0.05, 2.6)
	await get_tree().create_timer(0.4).timeout
	gn._face(player.global_position)
	gn._pose()
	var gp := gn.soldier.global_position
	var fw := gn.soldier.global_basis.z
	cv.fov = 50.0
	cv.global_position = gp + fw * 2.6 + gn.soldier.global_basis.x * 0.9 + Vector3(0, 1.6, 0)
	cv.look_at(gp + Vector3(0, 1.3, 0), Vector3.UP)
	await _shot_png("c30o_gun_front.png")
	cv.global_position = gp + gn.soldier.global_basis.x * 2.4 + fw * 0.6 + Vector3(0, 1.5, 0)
	cv.look_at(gp + fw * 0.4 + Vector3(0, 1.3, 0), Vector3.UP)
	await _shot_png("c30o_gun_side.png")
	gn.draw_sword()
	await get_tree().create_timer(0.45).timeout
	cv.global_position = gp + fw * 2.8 + gn.soldier.global_basis.x * 1.4 + Vector3(0, 1.9, 0) if is_instance_valid(gn.soldier) else cv.global_position
	cv.look_at(gp + Vector3(0, 0.7, 0), Vector3.UP)
	await _shot_png("c30o_gun_drop.png")
	await get_tree().create_timer(1.2).timeout
	var d: Duelist = gn.duelist
	await _shot_png("c30o_gun_sword.png")
	if d:
		d.queue_free()
	gn.stop()
	# Takviye: kulelerin kapılarından sur yoluna dökülen muhafızlar
	player.global_position = Vector3(CLIMB_X, Blachernae.WALK_Y + 0.05, 2.3)
	emperor.visible = true
	_reinforce()
	await get_tree().create_timer(4.5).timeout
	cv.global_position = Vector3(CLIMB_X + 1.0, Blachernae.WALK_Y + 2.6, 4.6)
	cv.look_at(Vector3(CLIMB_X - 9.0, Blachernae.WALK_Y + 1.0, 2.3), Vector3.UP)
	await _shot_png("c30o_reinforce_west.png")
	cv.look_at(Vector3(CLIMB_X + 5.0, Blachernae.WALK_Y + 1.0, 2.3), Vector3.UP)
	await _shot_png("c30o_reinforce_east.png")
	# Panik inişi: geç kalan azap başını mazgaldan uzatır, muhafızlar yürür, azap kayarak iner, dost azap surdan atlar,
	# merdiven itilir, sallanır, oyuncuyla birlikte devrilir
	player.global_position = Vector3(13.3, Blachernae.WALK_Y + 0.05, 3.3)
	var az := _late_azap()
	_azap_pop(az)
	await get_tree().create_timer(1.5).timeout
	cv.fov = 60.0
	cv.global_position = Vector3(CLIMB_X - 1.6, Blachernae.WALK_Y + 1.6, 1.4)
	cv.look_at(az.global_position + Vector3(0.8, 1.0, -0.6), Vector3.UP)
	await _shot_png("c30o_flee_pop.png")
	var chasers := _chasers()
	var none: Array[Node3D] = []
	player.global_position = Vector3(11.6, Blachernae.WALK_Y + 0.05, 3.6)
	var tt := 0.0
	while tt < 1.2:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		tt += dt
		for c: Array in chasers:
			var cz: float = 3.6 if c == chasers[0] else float(c[2])
			_chase_step(c, Vector3(maxf(player.global_position.x + 0.8, CLIMB_X + 1.3) + float(c[1]), Blachernae.WALK_Y, cz), dt, none, true)
	cv.global_position = Vector3(CLIMB_X - 0.4, Blachernae.WALK_Y + 1.6, 3.9)
	cv.look_at(Vector3(CLIMB_X + 4.0, Blachernae.WALK_Y + 1.1, 2.4), Vector3.UP)
	await _shot_png("c30o_flee_chase.png")
	_azap_slide(az, Vector3(CLIMB_X - 3.0, 0.0, SAFE_Z + 7.0))
	await get_tree().create_timer(0.75).timeout
	cv.global_position = Vector3(CLIMB_X - 6.0, 3.0, 14.0)
	cv.look_at(Vector3(CLIMB_X, 5.0, 6.5), Vector3.UP)
	await _shot_png("c30o_flee_slide.png")
	var jumper := Soldier.new(Color("b3262d"), "stand", "bork")
	jumper.set_meta("no_talk", true)
	jumper.set_meta("climber", true)
	add_child(jumper)
	jumper.global_position = Vector3(8.45, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 0.65)
	jumper.rig.activity = "fall"
	_leap(jumper, 8.45)
	await get_tree().create_timer(0.55).timeout
	cv.global_position = Vector3(3.0, 1.7, 17.0)
	cv.look_at(Vector3(8.45, 8.5, 6.0), Vector3.UP)
	await _shot_png("c30o_flee_jump.png")
	var lead := chasers[0][0] as Soldier
	lead.global_position = Vector3(CLIMB_X + 0.65, Blachernae.WALK_Y, Blachernae.WALL_Z1 - 1.0)
	player.frozen = false
	_grab_ladder()
	player._ladder_t = 6.5
	await get_tree().create_timer(0.3).timeout
	_push_ladder(lead)
	await get_tree().create_timer(0.75).timeout
	cv.global_position = Vector3(CLIMB_X + 6.0, 2.2, 15.0)
	cv.look_at(Vector3(CLIMB_X, 9.0, 5.5), Vector3.UP)
	await _shot_png("c30o_flee_wobble.png")
	# Ekran görüntüsü kareleri yavaş: devrilme ağır çekimde (kare bekleme süresinde merdiven yere varmasın)
	await get_tree().create_timer(0.75).timeout
	Engine.time_scale = 0.15
	cv.global_position = Vector3(CLIMB_X - 9.0, 3.5, 13.0)
	cv.look_at(Vector3(CLIMB_X, 5.0, 11.0), Vector3.UP)
	await get_tree().create_timer(0.12).timeout
	await _shot_png("c30o_flee_ride_side.png")
	player.camera.make_current()
	await get_tree().create_timer(0.1).timeout
	await _shot_png("c30o_flee_ride_pov.png")
	cv.make_current()
	Engine.time_scale = 1.0
	await get_tree().create_timer(1.6).timeout
	cv.global_position = Vector3(CLIMB_X + 6.0, 2.0, 24.0)
	cv.look_at(Vector3(CLIMB_X, 3.0, 8.0), Vector3.UP)
	await _shot_png("c30o_flee_landed.png")
	player.frozen = true
	# Bozgun: sur dibinden ordugâha
	player.global_position = Vector3(CLIMB_X - 1.6, Blachernae.slope_y(Blachernae.WALL_Z1 + 2.4) + 0.05, Blachernae.WALL_Z1 + 2.4)
	_start_rout()
	await get_tree().create_timer(2.2).timeout
	cv.global_position = Vector3(CLIMB_X - 1.0, 2.2, Blachernae.WALL_Z1 + 1.2)
	cv.look_at(Vector3(CLIMB_X - 1.0, 0.8, 30.0), Vector3.UP)
	cv.fov = 60.0
	await _shot_png("c30o_rout.png")
	await get_tree().create_timer(1.6).timeout
	cv.global_position = Vector3(CLIMB_X + 2.0, 2.0, 22.0)
	cv.look_at(Vector3(CLIMB_X, 4.0, 4.0), Vector3.UP)
	await _shot_png("c30o_rout_back.png")
	get_tree().quit()
