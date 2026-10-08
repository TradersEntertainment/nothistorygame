extends Node3D
## Bölüm 20 — Gedik (Tolga · 7 Mayıs 1453 gecesi, Mesoteichion). docs/SIEGE.md §3.
##
## Gündüz Urban'ın topu dış surda gedik açar; savunucular her gece fıçı, toprak ve kalasla kapatır (Barbaro,
## Kritovoulos). Tolga, Giustiniani'nin emrinde yük taşır: depodan istenen malzemeyi alır, gediğe götürür.
## Büyük top ateşlenmeden önce gözcü bağırır: tahta siperin arkasına geçmeyen devrilir, yükünü düşürür.
## Gecenin ortasında hücum: Tolga okçulara ok sandığı yetiştirir. Şafakta kapanmış gedik tespit edilir.
##   20.1 Gedik şafaktan önce kapandı · 20.2 Kapandı, Tolga koli bandıyla "sağlamlaştırdı" · 20.3 Yarım kaldı,
##   şafakta Giustiniani'nin adamları bitirdi (tarih yine aynı)
## Niko dostsa (niko_friend) taşıyıcıların arasındadır: gece boyunca belli aralıkla gediğe bir yük de o getirir
## (20.1'e, oradan Uzun Bekleyiş'e bir yol daha).
##   --autotest[=tape|late|hit|niko_idle|idle]   (varsayılan: 20.1; *idle: Tolga beş yük getirip yalnız okları taşır)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const NIGHT := 170.0
const ASSAULT_AT := 0.52       # gecenin bu oranında hücum
const ARCHERS := Vector3(-9.0, 0.0, 11.0)
const ARROWS := Vector3(6.2, 0.0, 0.2)
const NIKO_EVERY := 15.0       # Niko'nun bir yükü (gece 170 sn: dost taşıyıcı yarım gedik kadar getirir)

var walls: LandWalls
var player: Player
var hud: Hud
var giust: Person
var phase := "intro"
var _outcome := ""
var _time := NIGHT
var repair := 0
var carrying := ""
var _carry_node: Node3D
var _gun_t := 20.0
var _warn := false
var _knocks := 0
var _assault_done := false
var fight: WallFight
var chaos: SiegeChaos
var assault: Assault
var _arrows_ok := false
var _taped := false
var _photo := ""
## Gedik düellosu kazanıldı mı (yenilgi: gedik sabaha yetişmez, 20.3)
var _duel_won := true
var cam: TespitCam
var _t := 0.0
## Dost Niko (niko_friend): taşıyıcılardan biri o
var niko: Person
var _niko_t := NIKO_EVERY
var _niko_loads := 0
## Tüfek: gediğe koşan azaplardan vurulmayanlar gedik dövüşüne katılır (en çok 2)
var gun_shots := 0
var gunner_shots := 0
var gunner_dodged := 0
var gun_hits := 0
var _gun_missed := 0


func _ready() -> void:
	if GameState.autotest and GameState.autotest_variant.ends_with("idle"):
		GameState.flags["niko_friend"] = GameState.autotest_variant == "niko_idle"
	GameState.snapshot(20)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	hud.chase_music = "tension"
	walls = LandWalls.new()
	add_child(walls)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	giust = Person.new({"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
		"beard": true, "skin": Color("e0b08a")})
	giust.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-4.4, 0, -5.4))     # işçilerin ve taşıyıcı şeritlerinin dışında
	add_child(giust)
	giust.look_target = player
	# Yük taşıyan savunucular: WallFight.add_carriers (aşağıda). Ayrı bir işçi takımı yok: iki takımın yolları
	# kesişiyordu, adamlar birbirinin içinden geçiyordu. Her taşıyıcının kendi şeridi var.
	# Ok sandıkları (hücumda okçulara) ve okçular
	for i in 3:
		Props.make_solid(Props.box(self, Vector3(0.9, 0.45, 0.5), ARROWS + Vector3(0, 0.23 + i * 0.46, 0), Color("6a4a2c")))      # ok sandıkları katı
		for k in 5:
			Props.cyl(self, 0.012, 0.8, ARROWS + Vector3(-0.3 + k * 0.15, 0.55 + i * 0.46, 0), Color("c8b894"), Vector3(0, 0, 90), 4)
	Props.interactable(self, "pile_arrows", Vector3(1.2, 1.6, 1.0), ARROWS + Vector3(0, 0.8, 0))
	for i in 3:
		var a := Person.new({"coat": Color("7a2a24"), "pants": Color("3a2a22"), "hat": "helm", "beard": i == 1})
		a.set_meta("no_talk", true)
		a.position = ARCHERS + Vector3(-1.5 + i * 1.5, 0, 0.6)
		add_child(a)
	Props.interactable(self, "archers", Vector3(4.6, 2.4, 1.6), ARCHERS + Vector3(0, 1.2, 0.2))
	# Garnizon: dış surda ve kule tepelerinde nöbetçiler, iç surda sıra; peribolosun iki ucunda ateş başında
	# dinlenen yedekler (gediğin iş alanından uzak)
	Garrison.land_walls(self, [Vector2(-10.4, -6.8), Vector2(6.8, 10.4)], [Vector2(-32.0, 32.0)], [Vector2(-14.0, 14.0)], 20)
	# Gediğin iki yanında, dış surun yürüyüş yolunda kaynar yağ kazanları (hücumda sur dibine dökülür); peribolosta
	# Tolga'yla birlikte gediği onaran ekip: depodan toprak, fıçı, kalas taşıyanlar ve gedikte kazık çakanlar
	fight = WallFight.new()
	add_child(fight)
	for sx: float in [-1.0, 1.0]:
		fight.add_cauldron(Vector3(sx * 8.6, LandWalls.OUTER_H, 15.0), 2040 + int(sx))
	fight.add_carriers(LandWalls.DEPOT + Vector3(-2.6, 0, 2.6), LandWalls.BREACH + Vector3(0, 0, -3.4), 5, 2050)
	if GameState.flags.get("niko_friend", false):
		niko = fight.swap_carrier(4, Person.new({"face": "niko", "coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hair": Color("2a1e14"),
			"hat": "helm", "mustache": true, "beard": true, "skin": Color("d9a07a")}), "plank")
		niko.set_meta("spk", "SPK_NIKO")
	fight.add_builders(LandWalls.BREACH + Vector3(0, 0, -2.6), 4, 2060)
	fight.set_crew_active(false)
	# Önceki gecelerin bedeli: peribolosta yerde yatan oklanmış savunucular, düşmüş kalkanlar, surdan kopmuş taşlar,
	# kırık kılıçlar, dağılmış kalaslar (oyuncunun depo–gedik yolunu ve okçu sırasını kesmeyen yerlerde)
	for lane: Array in [[Vector3(-18.0, 0, 4.2), Vector3(-5.0, 0, 4.2), 1.6], [Vector3(8.0, 0, 12.9), Vector3(24.0, 0, 12.9), 0.8]]:
		var bx := BattleExtras.new()
		add_child(bx)
		bx.hit_every = 0.0
		bx.populate(lane[0], lane[1], lane[2], 0, 3, 0, 2000 + int(lane[0].x))
	# Hücum: gece yarısı ovadan gediğe ve surlara koşan, merdiven dayayan ordu (başta gizli; hücumda görünür)
	assault = Assault.new()
	assault.keep = Rect2(-40.0, -10.0, 80.0, 36.0)
	assault.with_defenders = false
	assault.intensity = 0.95       # 7 Mayıs gece hücumu (eskiden 0,7: ova boş görünüyordu)
	add_child(assault)
	assault.build()
	assault.visible = false
	assault.process_mode = Node.PROCESS_MODE_DISABLED
	for spec in [[Vector3(-22.0, 0, 8.5), 5], [Vector3(23.0, 0, 9.0), 5]]:
		walls.lights.append(Garrison.fire_ring(self, spec[0], spec[1], 2000 + int(spec[0].x)))
	# Hücumda sur içi kargaşa: yedekler gediğe ve merdivenlere koşar, halk taş taşır, yaralılar geri (Bölüm 26 gibi).
	# Koşanlar hücumla gelir, püskürtülünce çekilir; yerde yatan yaralılar ve dua edenler baştan beri orada (önceki geceler)
	chaos = SiegeChaos.new()
	chaos.player = player
	chaos.area = Rect2(-44.0, 1.4, 88.0, 10.6)
	chaos.static_clear_x = 12.0
	chaos.seed = 20
	chaos.n_run = 80
	chaos.n_static = 30
	chaos.start_active = false
	chaos.avoid = [[Vector3(0, 0, 14.0), 5.4], [LandWalls.DEPOT, 3.0], [ARROWS, 2.2], [ARCHERS, 3.4], [Vector3(-8.0, 0, 12.2), 1.8],
		[Vector3(8.0, 0, 12.2), 1.8], [LandWalls.SPAWN, 1.8], [Vector3(-22.0, 0, 8.5), 3.0], [Vector3(23.0, 0, 9.0), 3.0]]
	chaos.avoid_lines = [[LandWalls.DEPOT, LandWalls.BREACH + Vector3(0, 0, -3.4), 1.6], [ARROWS, ARCHERS, 1.4]]
	add_child(chaos)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH20_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH20_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = LandWalls.SPAWN
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D20_N_01")
	await hud.say("SPK_GIUST", "D20_G_01_KNOWN" if GameState.has_met("giustiniani") else "D20_G_01")   # Perde II'de tanıştılarsa
	await hud.say("SPK_TOLGA", "D20_T_01")
	await hud.say("SPK_GIUST", "D20_G_02")
	await hud.say("SPK_GIUST", "D20_G_03")
	# Huruçun (36, 9 Nisan) izi: omzunda dönen okçu Leon gedikte; dışarıda kalan Leon'un yeri boş
	match Siege.outcome(36):
		"36.1":
			await hud.say("SPK_GIUST", "D20_G_LEON_OK")
		"36.2":
			await hud.say("SPK_GIUST", "D20_G_LEON_LOST")
	Lore.scatter(self, "20")
	player.frozen = false
	phase = "work"
	_set_crew(true)
	_update_objective()
	if niko:
		hud.bark("SPK_NIKO", "D20_NK_01", 3.5)
	if GameState.autotest:
		_auto()
	while phase in ["work", "assault", "gun"]:
		await get_tree().process_frame
	await _dawn()
	await _end_chapter()


## Onarım ekibi (taşıyıcılar) giriş konuşmasında görünmez: kameranın önünden geçip konuşanı örtmesinler.
func _set_crew(on: bool) -> void:
	fight.set_crew_active(on)


func needed() -> String:
	if repair < 4:
		return "barrel"
	if repair < 6:
		return "earth"
	return "plank"


func _update_objective() -> void:
	if phase == "assault":
		hud.set_objective(tr("UI_OBJ20_ARROWS") if carrying != "arrows" else tr("UI_OBJ20_ARCHERS"),
			ARROWS + Vector3(0, 1.0, 0) if carrying != "arrows" else ARCHERS + Vector3(0, 1.6, 0))
		return
	if repair >= LandWalls.STAGES:
		hud.set_objective("")
		return
	var want := tr("UI_ITEM20_" + needed().to_upper())
	if carrying == "":
		hud.set_objective(tr("UI_OBJ20_FETCH") % [want, repair, LandWalls.STAGES], LandWalls.DEPOT + Vector3(0, 1.2, 0))
	else:
		hud.set_objective(tr("UI_OBJ20_BRING") % [tr("UI_ITEM20_" + carrying.to_upper()), repair, LandWalls.STAGES], LandWalls.BREACH + Vector3(0, 2.2, -1.2))


func _process(delta: float) -> void:
	_t += delta
	if phase != "work" and phase != "assault":
		return
	_time -= delta
	hud.set_chase(tr("UI_CH20_TIME") % _clock(), 1.0 - _time / NIGHT)
	if phase == "work":
		if not _assault_done and _time < NIGHT * (1.0 - ASSAULT_AT):
			_start_assault()
			return
		_gun_t -= delta
		if not _warn and _gun_t <= 4.0:
			_warn = true
			hud.bark("SPK_LOOKOUT", "D20_L_WARN_%d" % (randi() % 3 + 1), 3.0)
			Audio.stinger("warn", -9.0)
			Audio.sfx("church_bell", -10.0, 1.6)
			hud.set_qte(tr("UI_QTE20_COVER"))
			# Siper koşusu ağır çekimde: gülle gelene dek zaman yavaşlar (uyarıdan ateşe ~4 sn gerçek, daha uzun hissedilir)
			if _exposed():
				Fx.slowmo(0.55, 2.2, 0.6)
		if _gun_t <= 0.0:
			_fire()
		# Dost Niko kendi şeridinde yük getirir (Tolga'nın getirdiği sırayla: önce fıçı, sonra toprak, sonra kalas)
		if niko and repair < LandWalls.STAGES:
			_niko_t -= delta
			if _niko_t <= 0.0:
				_niko_t = NIKO_EVERY
				repair += 1
				_niko_loads += 1
				walls.set_repair(repair)
				Audio.sfx("land_thud", -10.0, 1.1)
				if _niko_loads == 1:
					hud.bark("SPK_NIKO", "D20_NK_DROP", 3.0)
				_update_objective()
		if repair >= LandWalls.STAGES:
			phase = "done"
	if _time <= 0.0:
		_time = 0.0
		# Hücum (çarpışma) sürerken gece bitse de bölüm yarıda kesilmez: hücum bitince "work"a dönülür, bir sonraki karede biter
		if phase == "work":
			phase = "done"


## Gece saati: 21.00'dan şafağa (05.00) doğru ilerler.
func _clock() -> String:
	var h := 21.0 + (1.0 - _time / NIGHT) * 8.0
	var hh := int(h) % 24
	return "%02d.%02d" % [hh, int(fmod(h, 1.0) * 60.0)]


func _fire() -> void:
	_warn = false
	_gun_t = randf_range(24.0, 30.0)
	hud.set_qte("")
	walls.fire_flash()
	Audio.sfx("cannon", 0.0, 0.8)
	await get_tree().create_timer(1.1).timeout
	var at := LandWalls.BREACH + Vector3(randf_range(-2.5, 2.5), 2.0, 0.6)
	walls.impact(at)
	Audio.sfx("explosion_big", -4.0)
	player.shake(0.5)
	if repair > 0 and repair < LandWalls.STAGES:
		repair -= 1
		walls.set_repair(repair)
		hud.bark("SPK_GIUST", "D20_G_LOSS", 2.5)
	if _exposed():
		_knock()
	_update_objective()


## Siperin arkasında mı, depoda mı, gediğe uzak mı?
func _exposed() -> bool:
	var p := player.global_position
	if p.distance_to(LandWalls.BREACH) > 9.0 or p.distance_to(LandWalls.DEPOT) < 4.5:
		return false
	for m: Vector3 in LandWalls.MANTLETS:
		if absf(p.x - m.x) < 1.5 and p.z < m.z + 0.9 and p.z > m.z - 2.2:
			return false
	return true


func _knock() -> void:
	_knocks += 1
	player.stagger(1.2)
	player.hurt(40.0, LandWalls.BREACH + Vector3(0, 2.0, 30.0))
	Audio.sfx("land_thud", 0.0)
	if carrying != "":
		_drop()
	_time -= 5.0
	hud.bark("SPK_TOLGA", "D20_T_KNOCK_%d" % mini(_knocks, 3), 3.0)


func _start_assault() -> void:
	_assault_done = true
	phase = "assault"
	_warn = false
	hud.set_qte("")
	if carrying != "":
		_drop()
	Audio.sfx("crowd_camp", -2.0)
	hud.say("SPK_GIUST", "D20_G_ASSAULT")
	_update_objective()
	# Ordu görünür: ovadan koşanlar, merdivenler, arkada ateş eden bataryalar
	assault.visible = true
	assault.process_mode = Node.PROCESS_MODE_INHERIT
	chaos.set_active(true)
	var t := 0.0
	var limit := 30.0
	var pour_t := 2.5
	var side := 0
	while not _arrows_ok and t < limit:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		pour_t -= dt
		if pour_t <= 0.0:
			# Kazanlar sırayla gediğin önüne kaynar yağ döker; surdan ok yağar
			pour_t = randf_range(4.0, 6.0)
			var d: Dictionary = fight.cauldrons[side % fight.cauldrons.size()]
			fight.pour(d, Vector3((d["pos"] as Vector3).x, 0.0, 18.0), 2)
			# Surun boyunca (eskiden hep gediğin önünde aynı yere); ovadaki okçular da sura atar
			assault.volley(Vector3(randf_range(-30.0, 30.0), 0, randf_range(21.0, 33.0)), 6.0, 22)
			var wx := randf_range(-30.0, 30.0)
			if absf(wx - LandWalls.BREACH.x) > LandWalls.BREACH_W * 0.5 + 1.0 and absf(wx - player.global_position.x) > 4.0:
				assault.volley(Vector3(wx, LandWalls.OUTER_H, 15.0), 3.0, 12, true)
			side += 1
		if randf() < 0.02:
			Vfx.explosion(walls, Vector3(randf_range(-12, 12), 3.0, 24.0), 0.4)
			Audio.sfx("explosion_small", -12.0)
	if not _arrows_ok:
		hud.bark("SPK_GIUST", "D20_G_ARROWS_LATE", 3.0)
		if carrying == "arrows":
			_drop()
	for i in 4:
		Vfx.explosion(walls, Vector3(randf_range(-10, 10), 2.0, 26.0), 0.6)
		Audio.sfx("explosion_small", -6.0)
		await get_tree().create_timer(0.35).timeout
	await _gun_phase()
	await _breach_duel()
	await hud.say("SPK_GIUST", "D20_G_REPELLED")
	# Püskürtüldüler: ordu geri çekilir (ova yine sessiz)
	assault.visible = false
	assault.process_mode = Node.PROCESS_MODE_DISABLED
	chaos.set_active(false)
	phase = "work"
	_gun_t = 14.0
	_update_objective()


## Saldırının sonunda iki azap gediği aşıp Tolga'nın önüne düşer: kısa düello (StoryDuel: ölüm yok,
## yenilen kılıcını bırakıp geri çekilir). 7 Mayıs gecesi gedikte göğüs göğüse çarpışma oldu.
func _breach_duel() -> void:
	if carrying != "":
		_drop()
	var p := player.global_position
	var to := LandWalls.BREACH - p
	to.y = 0.0
	to = to.normalized() if to.length() > 0.1 else Vector3(0, 0, 1)
	var side := to.cross(Vector3.UP).normalized()
	var specs := []
	for k in 2:
		specs.append({"pos": p + to * 3.6 + side * (-1.1 + k * 2.2), "blade": "kilij", "shield": k == 1,
			"name": "SPK_AZAP", "look": {"coat": [Color("8a6a4a"), Color("b3262d")][k], "pants": Color("e8e0d0"),
			"hat": "turban", "mustache": true, "beard": k == 0}})
	player.face(giust.global_position + Vector3(0, 1.5, 0))     # komutu veren komutana döner (sonra düello rakibe çevirir)
	await hud.say("SPK_GIUST", "D20_G_DUEL")
	# İki azap, ardından gedikten iki tane daha; iki savunucu yanında çarpışır
	var more := []
	for k in 2:
		var s2: Dictionary = (specs[k] as Dictionary).duplicate(true)
		s2["pos"] = LandWalls.BREACH + Vector3(-1.4 + k * 2.8, 0, 1.2)
		(s2["look"] as Dictionary)["coat"] = [Color("6a4a3a"), Color("8a6a4a")][k]
		more.append(s2)
	# Tüfekle vurulamayan azaplar ikinci dalgaya katılır
	for k in mini(_gun_missed, 2):
		var s3: Dictionary = (specs[k] as Dictionary).duplicate(true)
		s3["pos"] = LandWalls.BREACH + Vector3(-0.6 + k * 1.2, 0, 2.2)
		(s3["look"] as Dictionary)["coat"] = Color("7a5a3a")
		more.append(s3)
	# Gedik ağzında bir tüfekçi: nişan alınca yer değiştir ya da siper al
	# Testte ilk atış erken: bot dalgaları hızlı bitirince tüfekçi hiç ateş etmeden duruyordu
	var gn := Gunner.spawn(self, LandWalls.on_rubble(LandWalls.BREACH + Vector3(2.2, 0, 1.4)), player, hud, 3.0 if GameState.autotest else 6.0)
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": specs, "max_active": 2, "skill": 0.35, "limit": 60.0},
		{"specs": more, "max_active": 2, "skill": 0.4, "allies": 2, "limit": 60.0,
		"intro": func():
			# Dövüşün ortasında haykırış (Tolga kılıç sallarken komutana dönmez)
			hud.bark("SPK_GIUST", "D20_G_SECOND", 3.5)
			await get_tree().create_timer(1.5).timeout}], "spathion")
	if _gun_missed > 0:
		print("GUN extra=%d" % mini(_gun_missed, 2))
	await gn.settle_test()
	gunner_shots += gn.shots
	gunner_dodged += gn.dodged
	gn.stop()
	_duel_won = r["won"]
	await hud.say("SPK_TOLGA", "D20_T_DUEL" if _duel_won else "D20_T_LOST")
	await _see_giust(p)     # Giustiniani konuşacak


## Giustiniani konuşmadan önce görünür olsun: uzun dövüşte (zor zorlukta dalga süre dolana dek sürer) oyuncu gediğin
## yanındaki tahta siperin arkasına kadar itilip "Püskürttük"ü siperin ardından dinliyordu. Görüş kapalıysa kısa bir
## kararmayla dövüşün başladığı yere döner.
func _see_giust(back: Vector3) -> void:
	var head := giust.global_position + Vector3(0, 1.5, 0)
	var eye := player.camera.global_position if player.camera else player.global_position + Vector3(0, 1.6, 0)
	var q := PhysicsRayQueryParameters3D.create(eye, head, 1, [player.get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if not hit.is_empty() and hit["collider"] is StaticBody3D and Unclip.visible_body(hit["collider"]) \
			and eye.distance_to(hit["position"]) < eye.distance_to(head) - 0.4:
		await hud.fade_to(1.0, 0.25)
		player.global_position = back
		player.face(head)
		await hud.fade_to(0.0, 0.25)
	else:
		player.face(head)
	Unclip.clear_line(self, player.global_position, [giust], [player])


## Hücumun sonu: Giustiniani bir Ceneviz tüfeği verir; Tolga dış surun yürüyüş yolundan, gediğe koşan dört azabı
## vurmaya çalışır (4 atış, 25 sn). Vurulmayanlar gediğe varır ve gedik dövüşünün ikinci dalgasına katılır.
func _gun_phase() -> void:
	if carrying != "":
		_drop()
	var back := player.global_position
	# Tüfek sahnesinde gece saati durur (yoksa gedik onarımı sabaha yetişmeyebilir)
	var was := phase
	phase = "gun"
	await hud.say("SPK_GIUST", "D20_G_GUN")
	await hud.fade_to(1.0, 0.35)
	player.global_position = Vector3(-10.0, LandWalls.OUTER_H + 0.05, 15.3)
	var runners: Array = []
	for i in 4:
		var x0 := -4.0 + i * 2.6
		runners.append({"coat": [Color("8a6a4a"), Color("6a4a3a"), Color("b3262d"), Color("7a5a3a")][i], "hat": "turban",
			"path": [Vector3(x0, 0, 35.5), Vector3(x0 * 0.4, 0, 25.0), Vector3(x0 * 0.15, 0, 17.6)], "delay": i * 2.2})
	player.face(Vector3(0, -1.0, 28.0))
	await hud.fade_to(0.0, 0.35)
	hud.bark("SPK_GIUST", "D20_G_GUN_GO", 3.0)
	var res: Dictionary = await GunRange.run(self, hud, player, {"runners": runners, "ground": LandWalls.outside_y,
		"objective": tr("UI_OBJ20_GUN") % 4, "look": Vector3(0, -1.0, 28.0)})
	gun_shots = res["shots"]
	gun_hits = res["hits"]
	_gun_missed = res["missed"]
	GameState.flags["gun_used"] = true
	await hud.say("SPK_TOLGA", "D20_T_GUN_GOOD" if gun_hits >= 2 else "D20_T_GUN_BAD")
	await hud.fade_to(1.0, 0.35)
	player.global_position = back
	player.face(LandWalls.BREACH + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.35)
	phase = was


func _pick(kind: String) -> void:
	if carrying != "":
		hud.bark("SPK_TOLGA", "D20_T_FULL", 2.0)
		return
	if phase == "assault" and kind != "arrows":
		hud.bark("SPK_GIUST", "D20_G_ARROWS_FIRST", 2.5)
		return
	if phase == "work" and kind == "arrows":
		return
	carrying = kind
	_carry_node = Node3D.new()
	_carry_node.position = Vector3(0.3, -0.78, -1.05)
	_carry_node.scale = Vector3.ONE * 0.6
	player.camera.add_child(_carry_node)
	match kind:
		"barrel":
			Props.cyl(_carry_node, 0.3, 0.8, Vector3.ZERO, LandWalls.C_WOOD, Vector3(90, 0, 0), 10)
		"earth":
			Props.cyl(_carry_node, 0.26, 0.4, Vector3.ZERO, Color("9a7a48"), Vector3.ZERO, 8, 0.32)
			Props.ball(_carry_node, 0.24, Vector3(0, 0.2, 0), Color("5a4630"), Vector3(1, 0.5, 1), 6)
		"plank":
			Props.box(_carry_node, Vector3(0.24, 0.1, 2.6), Vector3(0.2, 0.1, -0.3), Color("8a6440"), Vector3(0, 12, 0))
		"arrows":
			Props.box(_carry_node, Vector3(0.8, 0.4, 0.45), Vector3.ZERO, Color("6a4a2c"))
	Props.strip_outlines(_carry_node)
	player.speed_mult = 0.75
	Audio.sfx("land_pot", -10.0, 0.8)
	_update_objective()


func _drop() -> void:
	carrying = ""
	if _carry_node:
		_carry_node.queue_free()
		_carry_node = null
	player.speed_mult = 1.0
	_update_objective()


func _deliver() -> void:
	if carrying == "" or carrying == "arrows":
		return
	if repair >= LandWalls.STAGES:
		return
	if carrying != needed():
		hud.bark("SPK_GIUST", "D20_G_WRONG_" + needed().to_upper(), 3.0)
		return
	_drop()
	repair += 1
	walls.set_repair(repair)
	Audio.sfx("land_thud", -6.0, 1.2)
	player.hand_gesture("reach")
	if repair in [4, 6, 8]:
		hud.bark("SPK_GIUST", "D20_G_STAGE_%d" % repair, 3.0)
	elif repair < LandWalls.STAGES:
		hud.bark("SPK_TOLGA", "D20_T_DROP_%d" % (repair % 3 + 1), 2.2)
	_update_objective()


func _dawn() -> void:
	phase = "dawn"
	player.frozen = true
	hud.set_chase("", 0.0)
	hud.set_qte("")
	hud.set_prompt("")
	hud.set_objective("")
	if carrying != "":
		_drop()
	# Düello kaybedildiyse ya da Tolga gece iki kez yere serildiyse gedik sabaha yetişmez
	var complete := repair >= LandWalls.STAGES and _duel_won and player.downs < 2
	Unclip.clear_line(self, player.global_position, [giust], [player])
	if complete:
		await hud.say("SPK_GIUST", "D20_G_DONE")
	else:
		await hud.say("SPK_GIUST", "D20_G_UNFINISHED")
	await hud.fade_to(1.0, 0.8)
	walls.make_dawn(0.01)
	repair = LandWalls.STAGES
	walls.set_repair(repair)
	player.global_position = LandWalls.BREACH + Vector3(1.5, 0.05, -7.5)
	player.face(LandWalls.BREACH + Vector3(0, 2.4, 0))
	await hud.card([[tr("UI_CH20_DAWN"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	await hud.fade_to(0.0, 1.0)
	if complete and not "tape" in GameState.bag:
		await hud.say_gone("tape")          # bant bittiyse gedik bantsız kalır: Tolga sonuncusunun nereye gittiğini söyler
	if complete and "tape" in GameState.bag:
		var pick := await hud.choose(["UI_C20_TAPE", "UI_C20_LEAVE"], 0.0, 0 if GameState.autotest_variant == "tape" else 1)
		if pick == 0:
			_taped = true
			GameState.spend("tape", "breach_20")
			Audio.sfx("paper_tear", -4.0, 0.7)
			var band := Props.box(walls, Vector3(LandWalls.BREACH_W - 0.6, 0.12, 0.02), LandWalls.BREACH + Vector3(0, 2.5, -0.9), Color("c98a3a"))
			band.rotation_degrees = Vector3(0, 0, 3)
			await hud.say("SPK_TOLGA", "D20_T_TAPE")
			await hud.say("SPK_GIUST", "D20_G_TAPE")
	# Tespit karesi: şafakta kapanmış gedik
	var target := Node3D.new()
	target.position = LandWalls.BREACH + Vector3(0, 2.4, -0.6)
	walls.add_child(target)
	hud.set_objective(tr("UI_OBJ20_PHOTO"), target.global_position)
	Lore.scatter(self, "20")
	player.frozen = false
	cam = TespitCam.new(player, hud, target, "siege20")
	hud.add_child(cam)
	cam.max_dist = 30.0
	cam.cone_deg = 14.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	Unclip.clear_line(self, player.global_position, [giust], [player])
	await hud.say("SPK_GIUST", "D20_G_END")
	await hud.say("SPK_TOLGA", "D20_T_END")
	await hud.say("SPK_NIHAT", "D20_N_END")
	_outcome = ("20.2" if _taped else "20.1") if complete else "20.3"
	GameState.flags["breach_night_taped"] = _taped
	Siege.record(20, _photo, "SIEGE_NOTE_20_%s" % _outcome.split(".")[1])


func _on_focus(id: String) -> void:
	match id:
		"pile_barrel", "pile_earth", "pile_plank":
			hud.set_prompt(tr("UI_PROMPT20_TAKE") % tr("UI_ITEM20_" + id.trim_prefix("pile_").to_upper()))
		"pile_arrows":
			hud.set_prompt(tr("UI_PROMPT20_TAKE") % tr("UI_ITEM20_ARROWS") if phase == "assault" else "")
		"breach":
			hud.set_prompt(tr("UI_PROMPT20_PUT") if carrying != "" and carrying != "arrows" else "")
		"archers":
			hud.set_prompt(tr("UI_PROMPT20_GIVE") if carrying == "arrows" else "")
		_:
			hud.set_prompt("")


func _on_interact(id: String) -> void:
	if phase != "work" and phase != "assault":
		return
	match id:
		"pile_barrel", "pile_earth", "pile_plank", "pile_arrows":
			_pick(id.trim_prefix("pile_"))
		"breach":
			_deliver()
		"archers":
			if carrying == "arrows":
				_drop()
				_arrows_ok = true
				hud.bark("SPK_TOLGA", "D20_T_ARROWS_2", 2.5)


func _auto() -> void:
	await get_tree().create_timer(0.3).timeout
	if GameState.autotest_variant == "hit":
		player.global_position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(0, 0, -3.0)) + Vector3(0, 0.05, 0)
		_gun_t = 0.05
		await get_tree().create_timer(2.0).timeout
	var idle := GameState.autotest_variant.ends_with("idle")
	var loads := 5 if GameState.autotest_variant == "late" or idle else LandWalls.STAGES
	while repair < loads and phase in ["work", "assault", "gun"]:
		if phase == "assault":
			if not _arrows_ok and carrying == "":
				_pick("arrows")
				_on_interact("archers")
			await get_tree().process_frame
			continue
		_pick(needed())
		_deliver()
		_gun_t = 30.0
		# Hücum da denensin: altıncı yükten sonra gece yarısına sar
		if repair == 6 and not _assault_done and GameState.autotest_variant != "late":
			_time = NIGHT * (1.0 - ASSAULT_AT) - 0.5
		await get_tree().create_timer(0.2).timeout
	if GameState.autotest_variant == "late":
		_time = 0.05
	# idle: Tolga beş yükten sonra bekler (hücum gelirse yalnız ok taşır); gece kendi hızında akar. Niko dostsa gedik
	# gece yarısından önce onunla kapanır, değilse yarım kalır.
	while idle and phase in ["work", "assault", "gun"]:
		if phase == "assault" and not _arrows_ok and carrying == "":
			_pick("arrows")
			_on_interact("archers")
		_gun_t = 30.0
		await get_tree().process_frame


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(20, _outcome)
	await Siege.show_page(hud, 20)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(20)
			if nxt != "":
				GameState.change_scene(nxt)
			else:
				hud.set_fade(1.0)
				await hud.card([[tr("UI_SIEGE_TBC"), 30, Color("f2e6c9")], [tr("UI_SIEGE_TBC_SUB"), 18, Color(1, 1, 1, 0.7)]], 3.5)
				GameState.change_scene("res://scenes/main.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW20_TITLE")
	c.nodes = [
		{"id": "carry", "key": "FLOW20_CARRY", "pos": Vector2(0.5, 0.14)},
		{"id": "arrows", "key": "FLOW20_ARROWS", "pos": Vector2(0.3, 0.32)},
		{"id": "noarrows", "key": "FLOW20_NOARROWS", "pos": Vector2(0.7, 0.32)},
		{"id": "20.1", "key": "FLOW_20_1", "pos": Vector2(0.2, 0.58), "outcome": true},
		{"id": "20.2", "key": "FLOW_20_2", "pos": Vector2(0.5, 0.58), "outcome": true},
		{"id": "20.3", "key": "FLOW_20_3", "pos": Vector2(0.8, 0.58), "outcome": true},
	]
	c.edges = [["carry", "arrows"], ["carry", "noarrows"]]
	for a in ["arrows", "noarrows"]:
		for o in ["20.1", "20.2", "20.3"]:
			c.edges.append([a, o])
	c.taken["carry"] = true
	c.taken["arrows" if _arrows_ok else "noarrows"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH20_STATS") % [_knocks, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	c.footer_lines.insert(0, Grade.finish("20"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "20.1", "tape": "20.2", "late": "20.3", "hit": "20.1", "lose": "20.3", "niko_idle": "20.1",
		"idle": "20.3"}.get(v, "20.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("20", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	# Yenilgi testi: oyuncu düelloda yere düşmüş ve düello kaybedilmiş olmalı
	if v.ends_with("lose"):
		ok = ok and player.downs >= 1 and not _duel_won
	if v == "hit":
		ok = ok and _knocks >= 1
	# niko_idle/idle: Tolga yalnız beş yük getirir; gediği Niko tamamlar (Niko'suz yarım kalır)
	ok = ok and (niko != null) == v.begins_with("niko")
	if v == "niko_idle":
		ok = ok and _niko_loads >= LandWalls.STAGES - 5
	# Tüfek (hücum sonuna kadar yaşanan varyantlarda; =late gece biter, =niko_idle gedik gece yarısından önce kapanır):
	# en az üç atış, en az bir isabet
	if v != "late" and v != "niko_idle":
		ok = ok and gun_shots >= 3 and gun_hits >= 1
		# Düşman tüfekçisi: en az bir atış; bot kaçar (=lose'da kaçmaz, yine de ateş edilmiş olmalı)
		ok = ok and gunner_shots >= 1 and (gunner_dodged >= 1 or v.ends_with("lose"))
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s, knocks=%d, duel=%s, downs=%d, repair=%d)" % [expected, _outcome, not page.is_empty(), _knocks, _duel_won, player.downs, repair])
	print("AUTOTEST %s chapter=20 variant=%s outcome=%s repair=%d knocks=%d arrows=%s gun=%d/%d gunner=%d/%d niko=%d" % ["PASS" if ok else "FAIL", v,
		_outcome, repair, _knocks, _arrows_ok, gun_hits, gun_shots, gunner_dodged, gunner_shots, _niko_loads])
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
	player.show_remote(false)
	phase = "work"
	repair = 5
	walls.set_repair(repair)
	player.global_position = LandWalls.DEPOT + Vector3(-3.0, 0.05, 4.0)
	await get_tree().create_timer(0.6).timeout
	player.face(LandWalls.BREACH + Vector3(0, 2.0, 0))
	_pick("earth")
	await _shot("c20_01_carry.png")
	_warn = true
	hud.set_qte(tr("UI_QTE20_COVER"))
	player.global_position = LandWalls.MANTLETS[0] + Vector3(0.3, 0.05, -1.6)
	player.face(LandWalls.CANNON)
	walls.fire_flash()
	await _shot("c20_02_cover.png")
	hud.set_qte("")
	var top := Camera3D.new()
	add_child(top)
	top.global_position = Vector3(18, 16, -8)
	top.look_at(LandWalls.BREACH + Vector3(-2, 0, 0), Vector3.UP)
	top.make_current()
	await _shot("c20_03_overview.png")
	walls.make_dawn(0.01)
	repair = LandWalls.STAGES
	walls.set_repair(repair)
	player.camera.make_current()
	_drop()
	player.global_position = LandWalls.BREACH + Vector3(1.5, 0.05, -7.5)
	player.face(LandWalls.BREACH + Vector3(0, 2.4, 0))
	await get_tree().create_timer(0.3).timeout
	await _shot("c20_04_dawn.png")
	hud.visible = false
	walls.set_repair(7)
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = LandWalls.BREACH + Vector3(4.5, 1.4, -6.5)
	cv.look_at(LandWalls.BREACH + Vector3(-1.0, 2.2, 0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	giust.global_position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-1.5, 0, -3.2))
	await _shot("c20_cover.png")
	get_tree().quit()
