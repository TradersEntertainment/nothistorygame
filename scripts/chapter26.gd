extends Node3D
## Bölüm 26 — Şafak (Tolga · 29 Mayıs 1453). docs/SIEGE.md §3. Perde IV'ün son bölümü ve kapanışı.
##
## Gece 01.30'da son hücum üç dalga halinde gelir (Barbaro, Kritovoulos): azaplar, Anadolu askeri, yeniçeriler.
## Tolga Mesoteichion'da Giustiniani'nin adamlarına yardım eder:
##   1. dalga: kuyudan gediğe su taşır · 2. dalga: Urban'ın topu barikatı yıkar, Tolga yeniden örer (top uyarısı) ·
##   3. dalga: Giustiniani yaralanır; Tolga poterna yolundaki fıçıları çeker, adamları onu gemiye taşır.
## Burçta sancak (Ulubatlı Hasan; uzaktan, saygıyla), İmparator'un son görüntüsü (arkası dönük, dumana yürür).
## Öğleden sonra Fatih Ayasofya'ya girer, taşa zarar veren bir askeri durdurur. Son kare: çekilir ya da çekilmez.
## Kapanış (Çarşamba): Nihat dosyayı imzalar; ofiste müdür hafta sonunu sorar.
##   3. dalgada, şafak: gediğin ağzında bir tüfekçi Giustiniani'ye nişan alır. ⏱ Tolga uyarır ya da susar (tespit).
##   Perde II'de İmparator'un güvenini kazanan Tolga (Direniş ≥ 1) uyarırsa, ya da powerbank "zırh ısıtıcısı" komutanın
##   omzundaysa, Giustiniani vurulmaz: hücum püskürtülür, şehir o sabah düşmez (26.3; Siege.resolve → W10/W11/W12).
##   26.1 Son kare çekildi · 26.2 Son kare çekilmedi ("bazı şeyler tanıkla kaydedilir") · 26.3 Hücum püskürtüldü
##   Bölüm 21'deki sorguda sözüne güvenilen lağımcıbaşı Kasım (siege21_talk) şehir düşünce serbesttir: tezkire
##   yoksa Isidoros'u kafileden o çıkarır. Bölüm 25'te yakılan mum (siege_candle) öğleden sonra Ayasofya'da hâlâ yanar.
##   10H'de "sağ omzunuza dikkat edin" dendiyse (giust_warned) Giustiniani bunu anar (_WARNED replikleri).
##   Dallanma v3: 25'te otağın arkasında meclis sonuna kadar dinlendiyse (25.1) Tolga hücumun sırasını Giustiniani'ye
##   söyler: ilk dalga azaplardır, merdiven dibine yağ ilk dalgaya dökülür, merdivenden bir azap az çıkar. Nöbetçiye
##   yakalanıp sonu kaçırdıysa (25.2) söyleyecek bir şeyi yoktur; iki azap çıkar.
##   --autotest[=nophoto|hold|hold_box|hold23|hold3|warn_notrust|lighter|isidore|kasim|candle|council_ok|council_bad]   (varsayılan: 26.1)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const WELL := LandWalls.DEPOT + Vector3(-4.2, 0.0, 1.6)
const POSTERN := Vector3(LandWalls.DEPOT.x + 3.5, 0.0, LandWalls.INNER_Z1 + 0.6)
const BLOCKS := [Vector3(12.6, 0.0, 3.2), Vector3(14.6, 0.0, 2.2)]
const BANNER_TOWER := Vector3(16.0, LandWalls.OUTER_H + 3.0, LandWalls.OUTER_Z1 + 1.0)
const AYA := Vector3(-14.0, 0.0, -82.0)

var walls: LandWalls
var city: ByzCity
var player: Player
var hud: Hud
var giust: Person
var assault: Assault
var emperor: Person
var bearers: Array[Person] = []
var defenders: Array[Person] = []
var fight: WallFight
var attackers: Array[Node3D] = []
var ladders: Array[Node3D] = []
var banner: Node3D
var fatih: Person
var axeman: Node3D
var phase := "intro"
var gun_shots := 0
var gunner_shots := 0
var gunner_dodged := 0
var gun_hits := 0
var _gun_missed := 0
var _outcome := ""
var water := 0
var repaired := 0
var carrying := ""
var _carry: Node3D
var _cleared := 0
var _gun_t := 99.0
var _warn := false
var _knocks := 0
var _photo := ""
var cam: TespitCam
var _t := 0.0
var _fx_t := 0.0


func _ready() -> void:
	GameState.snapshot(26)
	_apply_autotest_setup()
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	walls = LandWalls.new()
	walls.assault_mode = true
	add_child(walls)
	walls.set_repair(LandWalls.STAGES)
	_build_walls_scene()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build_walls_scene() -> void:
	giust = Person.new({"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
		"beard": true, "skin": Color("e0b08a")})
	giust.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-4.2, 0, -3.0))     # savunucu sırasının ve taşıyıcı şeritlerinin dışında
	giust.set_meta("no_yield", true)     # komutan yerinde durur (itilip siperin arkasına geçmesin)
	add_child(giust)
	giust.look_target = player
	for i in 6:
		var d := Person.new({"coat": [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96")][i % 3], "pants": Color("3a2a22"), "hat": "helm",
			"beard": i % 2 == 0, "mustache": true})
		d.set_meta("no_talk", true)
		d.set_meta("spk", "SPK_DEFENDER")   # "Komutan vuruldu!", "Gemiye!": kartta yanındaki savunucu
		d.set_meta("no_yield", true)     # sırada yerinde durur: geçenler itip Giustiniani'nin önüne, yamacın içine sokmasın
		# Barikatın (toprak tabya) arkasında: eskiden tabyanın içinde, beline kadar toprağa gömülü duruyorlardı
		d.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-3.2 + i * 1.3, 0, -2.7 - (i % 2) * 0.35))
		d.rotation.y = 0.0
		add_child(d)
		defenders.append(d)
	# Ok deposu: açık sandık ve üst üste ok demetleri (29 Mayıs gecesi gedikteki okçuların oku tükeniyordu; demetler
	# buradan alınıp okçulara taşınır). Etkileşim adı eskisi gibi "well".
	Props.solid(self, Vector3(1.2, 0.6, 0.8), WELL + Vector3(0, 0.3, 0), Color("6a4a2c"))      # sandığın içinden yürünmesin
	Props.box(self, Vector3(1.24, 0.06, 0.84), WELL + Vector3(0, 0.62, 0), Color("4a3422"))
	for k in 5:
		var bd := BattleExtras.arrow_bundle(self)
		bd.position = WELL + Vector3(-0.4 + (k % 3) * 0.4, 0.72 + floorf(k / 3.0) * 0.14, 0.0)
		bd.rotation = Vector3(0, 0.1 * k, 0)
	for k in 3:
		var bd := BattleExtras.arrow_bundle(self)
		bd.position = WELL + Vector3(0.85, 0.3, -0.3 + k * 0.3)
		bd.rotation = Vector3(-1.2, 0, 0)
	Props.interactable(self, "well", Vector3(1.8, 1.6, 1.8), WELL + Vector3(0.2, 0.8, 0))
	# Poterna yolunu kapatan fıçılar (3. dalgada çekilir)
	for i in BLOCKS.size():
		var b := Node3D.new()
		b.name = "Block%d" % i
		b.position = BLOCKS[i]
		add_child(b)
		Props.cyl(b, 0.42, 1.0, Vector3(0, 0.5, 0), Color("6a4a2c"), Vector3.ZERO, 10)
		Props.cyl(b, 0.43, 0.06, Vector3(0, 0.85, 0), Color("3a3634"), Vector3.ZERO, 10)
		var s := Props.solid(b, Vector3(0.9, 1.0, 0.9), Vector3(0, 0.5, 0), Color.WHITE)
		s.get_child(0).visible = false
		Props.interactable(b, "block_%d" % i, Vector3(1.2, 1.4, 1.2), Vector3(0, 0.7, 0))
	# Dış surun önüne dayanan merdivenler (hücumda görünür)
	# Dış sur kulelerinin (x ±13.5–18.5) ve gediğin kırık kenarının (x ±6.5) dışında (eskiden biri kulenin, biri
	# gediğin içindeydi)
	var lx := [-10.5, 9.5, -24.0, 22.0, 28.0]
	for i in 5:
		var l := Ladder.new(9.0, 16.0)
		l.position = Vector3(lx[i], 0, LandWalls.OUTER_Z1 + 2.6)
		l.visible = false
		add_child(l)
		ladders.append(l)
	# Surların önündeki hücum: ova boyunca sancaklı ordu, sura koşan dalgalar, merdivenlerde tırmananlar,
	# ateş eden bataryalar (Bizans tarafından, surdan görülür). Oyuncunun alanı surların içi.
	if assault == null and get_script().resource_path.ends_with("chapter26.gd"):
		assault = Assault.new()
		assault.keep = Rect2(-40.0, -10.0, 80.0, 36.0)
		assault.live_span = 30.0
		add_child(assault)
		assault.build()
		# Surda canlı savunanlar (gediğin iki yanında; sancağın çıkacağı burç boş), peribolosta yedek bölükler
		Garrison.land_walls(self, [Vector2(13.0, 19.0), Vector2(-10.4, -6.8), Vector2(6.8, 10.4)], [Vector2(-30.0, 30.0)], [], 26, 30.0, false)
		# Gediğin iki yanında kaynar yağ kazanları; peribolosta gediği ayakta tutan onarım ekibi
		fight = WallFight.new()
		add_child(fight)
		for sx: float in [-1.0, 1.0]:
			fight.add_cauldron(Vector3(sx * 8.6, LandWalls.OUTER_H, 15.0), 2640 + int(sx))
		fight.add_carriers(LandWalls.DEPOT + Vector3(-2.6, 0, 2.6), LandWalls.BREACH + Vector3(0, 0, -3.4), 4, 2650)
		fight.add_builders(LandWalls.BREACH + Vector3(0, 0, -2.6), 2, 2660)
		Garrison.squad(self, Vector3(-18.0, 0, 8.0), 5, 2, 0.0, 2610)
		Garrison.squad(self, Vector3(22.5, 0, 9.0), 4, 2, 0.0, 2620)
		# Gerçek savaş (Bölüm 0'daki gibi): kalkanını başına kaldırıp koşanlar, ok yiyip devrilenler, yerde yatanlar,
		# enkaz; oyuncunun ok deposu–gedik yolunu ve poterna fıçılarını kesmeyen şeritlerde
		for lane: Array in [[Vector3(-17.5, 0, 2.4), Vector3(3.0, 0, 2.4), 1.4, 7, 4, 0], [Vector3(9.0, 0, 12.6), Vector3(26, 0, 12.6), 1.2, 6, 3, 0],
				[Vector3(-26, 0, 12.6), Vector3(-6.5, 0, 12.6), 1.2, 6, 3, 0]]:
			var bx := BattleExtras.new()
			add_child(bx)
			bx.assault = assault
			bx.hit_every = 2.2
			bx.populate(lane[0], lane[1], lane[2], lane[3], lane[4], lane[5], 2600 + int(lane[0].x))
	# Burçtaki sancak (Ulubatlı Hasan): başta görünmez, 3. dalgada yükselir
	banner = Node3D.new()
	banner.position = BANNER_TOWER + Vector3(0, -4.0, 0)
	banner.visible = false
	add_child(banner)
	Props.cyl(banner, 0.05, 4.0, Vector3(0, 2.0, 0), Color("5a3e26"), Vector3.ZERO, 5)
	Props.box(banner, Vector3(0.04, 1.2, 1.8), Vector3(0, 3.3, 0.92), Color("b3262d"))
	emperor = Person.new({"coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "stemma", "face": "emperor", "beard": true,
		"mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")})
	emperor.visible = false
	add_child(emperor)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH26_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH26_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = LandWalls.SPAWN
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.2)
	await hud.say("SPK_NIHAT", "D26_N_01")
	await hud.say("SPK_TOLGA", "D26_T_01")
	await hud.say("SPK_GIUST", "D26_G_01")
	await _council_memory()
	await _wave1()
	await _wave2()
	await _wave3()
	if _outcome != "26.3":
		await _aya()
	await _end_chapter()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	var f := GameState.flags
	var o := GameState.chapter_outcomes
	match GameState.autotest_variant:
		"hold", "hold23", "hold3", "hold_lose":
			f["siege_side"] = "B"
			f["direnc"] = 1
			if GameState.autotest_variant == "hold23":
				o[23] = "23.2"
			if GameState.autotest_variant == "hold3":
				o[20] = "20.2"
				o[21] = "21.1"
				o[22] = "22.1"
		"hold_box":
			f["siege_side"] = "B"
			f["direnc"] = 2
			f["giust_armored"] = true
		"warn_notrust":
			f["siege_side"] = "B"
			f["direnc"] = 0
		"lighter":
			# 6b'de Giustiniani çakmağı aldı ("Ama alırım."), kitabı da okudu; çantada yer var
			f["given"] = {"lighter": "giustiniani", "book": "giustiniani"}
			GameState.bag.erase("lighter")
			GameState.bag.erase("book")
			if GameState.bag.size() >= GameState.BAG_MAX:
				GameState.bag.pop_back()        # kuşatmanın sonunda çantada bir göz boş
		"isidore":
			# 12'de Fatih'in verdiği tezkire cepte: esir kafilesindeki Isidoros'u çıkarır
			GameState.pocket_add("tezkire", "tezkire_12")
		"kasim":
			# 21'deki sorguda Kasım Tolga'nın sözüne güvenip konuştu; tezkire yok
			f["siege21_talk"] = "talk"
			f["giust_warned"] = true           # 10H: "Sağ omzunuza dikkat edin"
		"candle":
			f["siege_candle"] = true           # 25: son ayinde mum yakıldı
		"council_ok", "council_bad":
			f["siege_side"] = "B"
			o[25] = "25.2" if GameState.autotest_variant == "council_bad" else "25.1"


func _wave_start(n: int) -> void:
	Audio.sfx("crowd_camp", 0.0, 0.8 + n * 0.1)
	Audio.intensity(mini(n, 2), "walls_night")
	for i in ladders.size():
		ladders[i].visible = i < n + 2
	_spawn_attackers(4 + n * 3, n)
	hud.bark("SPK_LOOKOUT", "D26_L_WAVE_%d" % n, 3.5)
	_pour_loop("wave%d" % n)


## Dalga sürerken kazanlar sırayla sur dibine kaynar yağ döker (merdiven dipleri ve gedik önü); saldıranlar tutuşur.
func _pour_loop(wave: String) -> void:
	if fight == null or fight.cauldrons.is_empty():
		return
	await get_tree().create_timer(2.0).timeout
	var k := 0
	while is_inside_tree() and phase == wave and is_instance_valid(fight):
		var d: Dictionary = fight.cauldrons[k % fight.cauldrons.size()]
		fight.pour(d, Vector3((d["pos"] as Vector3).x + randf_range(-1.0, 1.0), 0.0, 18.0), 2)
		if assault:
			assault.volley(LandWalls.BREACH + Vector3(randf_range(-8, 8), 0, 24.0), 5.0, 24)
		k += 1
		await get_tree().create_timer(randf_range(4.5, 7.0)).timeout


func _spawn_attackers(count: int, wave: int) -> void:
	for a in attackers:
		a.queue_free()
	attackers.clear()
	var coat: Color = [Color("8a6a4a"), Color("6a4a3a"), Color("2f5fa8")][wave - 1]
	for i in count:
		var s := Soldier.new(coat, "stand", "bork" if wave == 3 else "turban")
		# Kendi şeridinde (hepsi hendekte z 24'te durur: rastgele x'te ikisi aynı yere varıp iç içe duruyordu)
		s.position = Vector3(lerpf(-16.0, 20.0, (i + 0.5) / count) + randf_range(-0.5, 0.5), 0, randf_range(40, 70))
		s.rotation.y = PI
		add_child(s)
		attackers.append(s)


## Dallanma v3: 25'in izi (bkz. başlık). Kaç azap merdivenden çıkar: 25.1'de bir, yoksa iki.
var ladder_foes := 2
var _council_said := ""

func _council_memory() -> void:
	var o := String(GameState.chapter_outcomes.get(25, ""))
	if o == "" or GameState.flags.get("siege_side", "B") == "O":
		return
	if o == "25.1":
		_council_said = "ok"
		await hud.say("SPK_TOLGA", "D26_T_25_OK")
		await hud.say("SPK_GIUST", "D26_G_25_OK")
		ladder_foes = 1
	else:
		_council_said = "bad"
		await hud.say("SPK_TOLGA", "D26_T_25_BAD")
		await hud.say("SPK_GIUST", "D26_G_25_BAD")


func _wave1() -> void:
	phase = "wave1"
	_wave_start(1)
	await hud.say("SPK_GIUST", "D0_G_ARROWS")
	Lore.scatter(self, "26")
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		for i in 3:
			_on_interact("well")
			_on_interact("breach")
			await get_tree().process_frame
	while water < 3:
		await get_tree().process_frame
	_drop()
	# Kaynar yağa rağmen iki azap merdivenden sura çıkar: kılıçla karşılanır
	await hud.say("SPK_GIUST", "D26_G_LADDER")
	player.frozen = false
	var r1: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": _foe_specs(ladder_foes, "azap", _ladder_heads()), "max_active": 2, "skill": 0.35, "limit": 45.0}], "spathion")
	_fights_won += int(r1["won"])
	player.frozen = true
	await _repelled("D26_G_REPELLED_1")


func _wave2() -> void:
	phase = "wave2"
	_wave_start(2)
	# Urban'ın topu barikatı yıkar: ateşten önce zaman ağırlaşır, bakış topa döner
	hud.bark("SPK_LOOKOUT", "D20_L_WARN_1", 2.5)
	Audio.stinger("warn", -6.0)
	player.face(LandWalls.CANNON + Vector3(0, 2.0, 0))
	Fx.slowmo(0.3, 1.2, 0.4)
	await get_tree().create_timer(0.5).timeout
	walls.fire_flash()
	Audio.sfx("cannon", 0.0, 0.8)
	await get_tree().create_timer(1.1).timeout
	walls.impact(LandWalls.BREACH + Vector3(0, 2.0, 0.6))
	Audio.sfx("explosion_big", -2.0)
	player.shake(0.8)
	walls.set_repair(LandWalls.STAGES - 4)
	await hud.say("SPK_GIUST", "D26_G_WAVE2")
	Lore.scatter(self, "26")
	player.frozen = false
	_gun_t = 20.0
	_update_objective()
	if GameState.autotest:
		for i in 3:
			_pick("barrel")
			_deliver()
			await get_tree().process_frame
	while repaired < 3:
		await get_tree().process_frame
	_gun_t = 99.0
	_warn = false
	hud.set_qte("")
	_drop()
	# Barikat kapanırken gediğin ağzından bir bölük dalar; iki savunucu yanında çarpışır. Komutanın haykırışına döner.
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_GIUST", "D26_G_BREACH_FIGHT")
	var r2: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": _foe_specs(3, "azap", _ladder_heads()),
		"max_active": 2, "skill": 0.4, "allies": 2, "limit": 55.0}], "spathion")
	_fights_won += int(r2["won"])
	player.frozen = true
	await _repelled("D26_G_REPELLED_2")


func _repelled(key: String) -> void:
	hud.set_objective("")
	Audio.intensity(0)
	Audio.stinger("victory", -5.0)
	for i in 3:
		Vfx.explosion(walls, Vector3(randf_range(-10, 12), 2.0, 26.0), 0.6)
		Audio.sfx("explosion_small", -6.0)
		await get_tree().create_timer(0.3).timeout
	for a in attackers:
		# Geri çekilirken zemini izler (hendekten ovaya çıkar; eskiden hendeğin yüksekliğinde kalıp ovanın toprağına gömülüyordu)
		var z0: float = a.position.z
		var tw := a.create_tween()
		tw.tween_method(func(z: float):
			a.position.z = z
			a.position.y = Assault.ground_y(a.position.x, z), z0, z0 + 40.0, 3.0)
	# Komutana döner; aradaki onarımcılar görüşten çekilir (taş dizen biri tam araya düşüyordu)
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	_clear_line(player.camera.global_position, [giust])
	await hud.say("SPK_GIUST", key)


func _janissary_duel() -> void:
	var p := player.global_position
	var to := LandWalls.BREACH - p
	to.y = 0.0
	to = to.normalized() if to.length() > 0.1 else Vector3(0, 0, 1)
	var side := to.cross(Vector3.UP).normalized()
	var specs := []
	for k in 2:
		specs.append({"pos": p + to * 3.8 + side * (-1.0 + k * 2.0), "blade": "kilij", "shield": k == 0,
			"name": "SPK_JANISSARY", "look": {"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork",
			"mustache": true, "beard": k == 1}})
	await hud.say("SPK_GIUST", "D26_G_DUEL")
	player.frozen = false
	# İki yeniçeri, ardından gediği dolduran son bölük (dört kişi, aynı anda ikisi): dayanmak gerek
	var last := _foe_specs(4 + mini(_gun_missed, 2), "janissary", _ladder_heads())
	if _gun_missed > 0:
		print("GUN extra=%d" % mini(_gun_missed, 2))
	# Gedik ağzında bir tüfekçi: nişan alınca yer değiştir ya da siper al
	var gn := Gunner.spawn(self, LandWalls.on_rubble(LandWalls.BREACH + Vector3(2.2, 0, 1.4)), player, hud, 6.0)
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": specs, "max_active": 2, "skill": 0.45, "limit": 60.0},
		{"specs": last, "max_active": 2, "skill": 0.45, "allies": 2, "limit": 70.0,
		"intro": func():
			# Dövüşün ortasında haykırış (Tolga kılıç sallarken komutana dönmez)
			hud.bark("SPK_GIUST", "D26_G_LAST_WAVE", 3.5)
			await get_tree().create_timer(1.5).timeout}], "spathion")
	await gn.settle_test()
	gunner_shots += gn.shots
	gunner_dodged += gn.dodged
	gn.stop()
	_duel_won = r["won"]
	player.frozen = true
	# Önce komutana döner, sonra konuşur: dövüş biterken sur dibinde duvara dönük kalabiliyordu (VISAUDIT wall)
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_TOLGA", "D26_T_DUEL" if _duel_won else "D26_T_LOST")


## Şafak tüfeği: Giustiniani tüfeği yeniden verir (Bölüm 20'de kullandıysa "yine sen"). Tolga dış surun yürüyüş
## yolundan hendeği geçip gediğe koşan dört yeniçeriye ateş eder; sonra gedikteki yerine döner.
func _gun_dawn() -> void:
	var back := player.global_position
	# Giustiniani bağırarak verir (kalabalık arasından: konuşma kamerası gerekmez)
	hud.bark("SPK_GIUST", "D26_G_GUN_AGAIN" if GameState.flags.get("gun_used", false) else "D26_G_GUN", 4.0)
	await get_tree().create_timer(2.5).timeout
	await hud.fade_to(1.0, 0.35)
	player.global_position = Vector3(-10.0, LandWalls.OUTER_H + 0.05, 15.3)
	var runners: Array = []
	for i in 4:
		var x0 := -4.5 + i * 3.0
		runners.append({"coat": Color("2f5fa8"), "hat": "bork",
			"path": [Vector3(x0, 0, 35.5), Vector3(x0 * 0.4, 0, 25.0), Vector3(x0 * 0.15, 0, 17.6)], "delay": i * 1.9})
	player.face(Vector3(0, -1.0, 28.0))
	await hud.fade_to(0.0, 0.35)
	var res: Dictionary = await GunRange.run(self, hud, player, {"runners": runners, "ground": LandWalls.outside_y,
		"speed": 2.4, "objective": tr("UI_OBJ26_GUN") % 4, "look": Vector3(0, -1.0, 28.0)})
	gun_shots = res["shots"]
	gun_hits = res["hits"]
	_gun_missed = res["missed"]
	GameState.flags["gun_used"] = true
	await hud.say("SPK_TOLGA", "D20_T_GUN_GOOD" if gun_hits >= 2 else "D20_T_GUN_BAD")
	await hud.fade_to(1.0, 0.35)
	player.global_position = back
	player.face(LandWalls.BREACH + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.35)


func _wave3() -> void:
	phase = "wave3"
	await hud.fade_to(1.0, 0.6)
	walls.make_dawn(0.01)
	await hud.card([[tr("UI_CH26_DAWN"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	player.global_position = LandWalls.BREACH + Vector3(4.0, 0.05, -6.0)
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.8)
	_wave_start(3)
	await hud.say("SPK_GIUST", "D26_G_WAVE3")
	# Şafak: hendeği geçen yeniçerilere surdan tüfekle (vurulamayanlar gedik dövüşünün son bölüğüne katılır)
	await _gun_dawn()
	# Yeniçeriler gediğin moloz yamacını tırmanıp içeri dalar: göğüs göğüse (StoryDuel: ölüm yok)
	await _janissary_duel()
	# Şafak: gediğin ağzında bir tüfekçi nişan alır. Tolga bu sahneyi belgesellerden bilir.
	if await _dawn_shot():
		await _hold()
		return
	# Yaralanma: yakın mesafeden atış (kaynaklarda göğüs zırhını delen kurşun). Zaman ağırlaşır, müzik susar,
	# yalnız kalp atışı duyulur.
	# Kısa ağır çekim: uzun 0,2'lik çekim düşüşü ve koşanları beş kat yavaşlatıp "dondu" sandırıyordu
	Fx.slowmo(0.4, 0.7, 0.5)
	Audio.duck(-30.0, 3.0)
	Audio.stinger("heart", -2.0)
	Audio.sfx("cannon", -6.0, 1.6)
	Vfx.dust(self, giust.global_position + Vector3(0, 1.4, 0), 0.5)
	player.shake(0.3)
	# Sırt üstü yere düşer: başı poternaya dönük, gövdesi moloz yamacının eğimine yaslanır
	giust.look_target = null            # bakışı olan karakter kendini dikleştirir; yaralı yatar
	giust.set_meta("no_face_player", true)
	giust.talking = false
	var dir := (POSTERN - giust.global_position)
	dir.y = 0.0
	dir = dir.normalized()
	_carry_at = giust.global_position + dir * 0.9          # yatınca gövdenin ortası
	# Vuruş tepkisi: kurşunun yönünde yarım adım geri savrulur, eli göğsünde, dizleri çöker
	if is_instance_valid(gunner):
		var push := giust.global_position - gunner.global_position
		push.y = 0.0
		var hit := create_tween()
		hit.tween_property(giust, "global_position", giust.global_position + push.normalized() * 0.35, 0.12).set_ease(Tween.EASE_OUT)
		if giust._arm_l:
			giust._arm_l.rotation.x = -1.3
		Vfx.dust(self, giust.global_position + Vector3(0, 1.3, 0), 0.25)
		await hit.finished
		await get_tree().create_timer(0.25).timeout
		_carry_at = giust.global_position + dir * 0.9
	var fall := create_tween()
	fall.tween_method(func(k: float): _carry_pose(dir, 0.15, k), 0.0, 1.0, 0.55).set_ease(Tween.EASE_IN)
	await fall.finished
	Vfx.dust(self, giust.global_position, 0.6)
	await hud.say("SPK_DEFENDER", "D26_S_GIUST")
	await hud.say("SPK_GIUST", "D26_G_HURT")
	await _lighter_back()
	await hud.say("SPK_TOLGA", "D26_T_HURT")
	# İki adam koşup yanına diz çöker gibi eğilir: biri başında (koltuk altlarından), biri ayaklarında
	for i in 2:
		var d: Person = defenders[i]
		d.look_target = null
		d.set_meta("no_face_player", true)
		bearers.append(d)
	# Her biri kendisine yakın uca gider (yollarını çaprazlayıp birbirinin içinden geçmesinler)
	var s0 := _bearer_spot(dir, 0)
	var s1 := _bearer_spot(dir, 1)
	if bearers[0].global_position.distance_to(s1) + bearers[1].global_position.distance_to(s0) \
			< bearers[0].global_position.distance_to(s0) + bearers[1].global_position.distance_to(s1):
		bearers.reverse()
	var come := create_tween().set_parallel()
	for i in 2:
		var at := _bearer_spot(dir, i)
		var b0: Person = bearers[i]
		var from := b0.global_position
		# Moloz yamacının üstünden koşar: zemini izler (düz çizgide yamacın yarım metre üstünden süzülüyordu)
		come.tween_method(func(k: float):
			var q := from.lerp(at, k)
			var fy := _visible_floor(q)
			b0.global_position = Vector3(q.x, q.y if is_nan(fy) else fy, q.z), 0.0, 1.0, 1.0)
	await come.finished
	for i in 2:
		bearers[i].rotation.y = atan2(dir.x, dir.z) + (PI if i == 0 else 0.0)
	# Taşıyıcılar moloz basamağının kenarında bekler: kalabalıktan yana itilen basamaktan iner (havada kalıyordu).
	# Kaldırana dek (no_audit) her kare görünen zemine oturur
	var keep_grounded := func() -> void:
		while is_inside_tree() and bearers.size() == 2 and not bearers[0].has_meta("no_audit"):
			for b: Person in bearers:
				var fy := _visible_floor(b.global_position)
				if not is_nan(fy) and absf(fy - b.global_position.y) > 0.02:
					b.global_position.y = fy
			await get_tree().process_frame
	keep_grounded.call()
	Lore.scatter(self, "26")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ26_CLEAR") % [_cleared, BLOCKS.size()], POSTERN + Vector3(0, 1.2, 0))
	if GameState.autotest:
		for i in BLOCKS.size():
			_on_interact("block_%d" % i)
	while _cleared < BLOCKS.size():
		await get_tree().process_frame
	player.frozen = true
	hud.set_objective("")
	# Kaldırırlar (kollar önde, yük tutar gibi) ve poternaya taşırlar: ön adam geri geri yürür, arka adam ayaklardan
	for b: Person in bearers:
		b.set_activity("carry")
		b.set_meta("no_audit", true)      # poternadan içeri girer (kapı surun yüzünde)
	var lift := create_tween()
	lift.tween_method(func(h: float): _carry_pose(dir, h, 1.0), 0.15, 0.85, 0.8).set_ease(Tween.EASE_OUT)
	await lift.finished
	var from := _carry_at
	var to := Vector3(POSTERN.x, 0.0, POSTERN.z) - dir * 0.2
	# Taşıma yolu açılır: yolda duran (dövüşten sonra nefeslenen dost, savunucu) kenara çekilir. Eskiden taşıyıcılar
	# poternanın önünde birinin içinden geçiyordu (sur yüzüne yakın yerde yana itilemiyordu)
	var mark := Node3D.new()
	add_child(mark)
	mark.global_position = to
	var keep_out: Array = [mark]
	keep_out.append_array(bearers)
	_clear_line(from, keep_out)
	mark.queue_free()
	var carry := create_tween()
	carry.tween_method(func(k: float):
		_carry_at = from.lerp(to, k)
		_carry_pose(dir, 0.85, 1.0), 0.0, 1.0, from.distance_to(to) / 1.3)
	await hud.say("SPK_DEFENDER", "D26_S_SHIP")
	if carry.is_running():   # replik uzun okunduysa hareket çoktan bitmiştir (bitmiş tweeni beklemek sonsuza dek takılır)
		await carry.finished
	for n: Node3D in [giust] + bearers:
		n.visible = false
	await hud.say("SPK_TOLGA", "D26_T_GONE")
	# Burçta sancak
	banner.visible = true
	player.face(BANNER_TOWER + Vector3(0, 2.0, 0))
	Audio.sfx("crowd_gasp", -2.0)
	var up := create_tween()
	up.tween_property(banner, "position", BANNER_TOWER, 2.4).set_trans(Tween.TRANS_SINE)
	await up.finished
	await hud.say("SPK_LOOKOUT", "D26_L_BANNER")
	await hud.say("SPK_NIHAT", "D26_N_BANNER")
	# İmparator'un son görüntüsü: arkası dönük, gediğe ve dumana yürür
	emperor.visible = true
	# Boş bir yerde (dövüşten sonra nefeslenen dost askerlerin üstünde değil); aradakiler görüşten çekilir
	emperor.position = Person.clear_spot(get_tree(), LandWalls.BREACH + Vector3(3.0, 0, -9.0), emperor)
	emperor.rotation.y = 0.0
	player.face(emperor.global_position + Vector3(0, 1.5, 0))
	_clear_line(player.camera.global_position, [emperor])
	await hud.say("SPK_EMPEROR", "D26_K_LAST")
	var walk := create_tween()
	# Yamacın dibine yürür, sonra molozun üstünden gediğe tırmanır
	# Savunanların sırasındaki aralıktan (x −0,6 ile 0,7 arası) geçer: eskiden x 0,5'ten yürüyüp birinin içinden geçiyordu
	walk.tween_property(emperor, "position", LandWalls.BREACH + Vector3(0.05, 0, -4.2), 2.8)
	walk.tween_property(emperor, "position", LandWalls.on_rubble(LandWalls.BREACH + Vector3(0.05, 0, -1.4)), 1.6)
	for i in 4:
		Vfx.dust(self, LandWalls.BREACH + Vector3(randf_range(-2, 2), 1.0, -1.0), 1.4)
	await walk.finished
	emperor.visible = false
	await hud.say("SPK_NIHAT", "D26_N_OUT")
	await hud.say("SPK_TOLGA", "D26_T_OUT")
	await hud.fade_to(1.0, 1.5, Color.WHITE)


# ================================================================ şafak: tüfekçi ve hüküm

var gunner: Soldier
## Düello kazanıldı mı. Bizans: yenilirse Tolga yerdeyken tüfekçi ateş eder, uyaramaz (26.3 kapanır).
## Osmanlı (26o): yenilirse Fatih'in girişini kaçırır (kare yok, 26.2).
var _duel_won := true
## Dalga çarpışmalarından kazanılanlar (merdiven başı, gedik ağzı)
var _fights_won := 0


## 6b'de aldığı çakmak ("Ama alırım."): gemiye götürülmeden Tolga'nın avucuna bırakır. Çanta doluysa Tolga ona bırakır.
func _lighter_back() -> void:
	if GameState.given_to("lighter") != "giustiniani":
		return
	await hud.say("SPK_GIUST", "D26_G_LIGHTER_BACK")
	if GameState.gain("lighter", "giust_back_26"):
		player.show_prop("lighter", 2.0)
		await hud.say("SPK_TOLGA", "D26_T_LIGHTER_BACK")
	else:
		await hud.say("SPK_TOLGA", "D26_T_LIGHTER_KEEP")


## Gediğin ağzında fitilli tüfeğini Giustiniani'ye doğrultan yeniçeri. Tolga uyarır ya da susar.
## Giustiniani kurtulursa true (Siege.can_hold: Bizans tarafı ve İmparator'un güveni; ya da omzundaki ısınan kutu).
func _dawn_shot() -> bool:
	gunner = Soldier.new(Color("2f5fa8"), "stand", "bork")
	add_child(gunner)
	# Barikatın yıkılan ortasında, fıçı sırasının önünde (eskiden toprak tabyanın içinde duruyordu)
	walls.set_repair(3)
	gunner.global_position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(0.9, 0, -0.8))
	gunner.set_meta("no_chat", true)
	gunner.face_toward(giust.global_position)
	gunner.equip("handgun")
	var mid := (gunner.global_position + giust.global_position) * 0.5 + Vector3(0, 1.4, 0)
	player.global_position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-0.6, 0, -5.2)) + Vector3(0, 0.05, 0)
	_clear_line(player.global_position, [gunner, giust])
	player.face(gunner.global_position + Vector3(0, 1.4, 0))
	await hud.say("SPK_TOLGA", "D26_T_SEE_GUN")
	player.face(mid)
	var pick := 1 if GameState.autotest_variant == "hold_box" else 0
	var c := 1
	if _duel_won:
		c = await hud.choose(["UI_C26G_WARN", "UI_C26G_WATCH"], 4.0, pick)
	else:
		# Düelloda yere serilen Tolga daha kalkamadan tüfekçi nişan alır: uyaracak vakit yok
		await hud.say("SPK_TOLGA", "D26_T_TOO_LATE")
	var armored: bool = GameState.flags.get("giust_armored", false) and Siege.can_hold()
	var warned := c == 0
	GameState.flags["dawn_warned"] = warned
	if warned:
		await hud.say("SPK_TOLGA", "D26_T_WARN")
	var trusted := warned and Siege.can_hold()
	if warned and not trusted and not armored:
		await hud.say("SPK_GIUST", "D26_G_NOTRUST")
	# Ateş
	Audio.sfx("cannon", -6.0, 1.6)
	Vfx.gun_blast(self, gunner.global_position + gunner.global_basis.z * 1.0 + Vector3(0, 1.4, 0), 0.4)
	player.shake(0.3)
	if trusted:
		# Eğilir: kurşun omzunun üstünden surun taşına çarpar
		var dk := create_tween()
		dk.tween_property(giust, "position:y", giust.position.y - 0.45, 0.12)
		dk.tween_property(giust, "position:y", giust.position.y, 0.4)
		Vfx.dust(self, giust.global_position + Vector3(0, 2.2, -1.2), 0.4)
		await hud.say("SPK_GIUST", "D26_G_DUCK")
		return true
	if armored:
		Vfx.dust(self, giust.global_position + Vector3(0.2, 1.45, 0), 0.3)
		await hud.say("SPK_GIUST", "D26_G_BOX")
		return true
	return false


## Giustiniani kurtulduğu an Zaman Bürosu sarsılır: siren, kırmızı çakarlar, tavandan dökülen dosyalar, koridordaki
## "1453" kapısının yazısı titreyip değişir; Nihat elinde boşalan dosyayla koşar, Müfide hoparlörden anons eder.
## Tolga'nın sesi surdan gelir (Büro'da değildir). Sonra kamera sura döner.
var _alarm_on := false
## Büro sahnesindeki tweenler (sarsıntı, düşen kâğıt): Büro silinmeden önce durdurulur (silinen düğümü süren tween
## ve döngü, ara sıra motoru çökertiyordu)
var _alarm_tweens: Array[Tween] = []


func _bureau_alarm() -> void:
	var back_pos := player.global_position
	var look := giust.global_position + Vector3(0, 1.5, 0)
	Audio.sfx("machine_jump", -6.0, 1.3)
	await hud.fade_to(1.0, 0.2, Color.WHITE)
	var b := Bureau.new()
	b.position = Vector3(0, -400, 0)
	add_child(b)
	# Tek WorldEnvironment kalsın: surun ortamı Büro'nunkiyle değişir (sur gizlenir ama sahnede kalır, zamanlayıcıları sürer)
	var wall_env: Environment = walls.env.environment if walls.env else null
	for c in b.get_children():
		if c is WorldEnvironment:
			if walls.env:
				walls.env.environment = (c as WorldEnvironment).environment
			b.remove_child(c)
			c.queue_free()
	var hidden: Array[Node3D] = []
	for c in get_children():
		if c is Node3D and c != b and c != player and (c as Node3D).visible:
			(c as Node3D).visible = false
			hidden.append(c)
	var o := b.global_position
	player.global_position = o + Vector3(0, 0.05, -24.0)
	player.face(o + Vector3(0, 1.5, -4.0))
	# Kırmızı çakarlar; tavan lambaları söner
	var lights: Array[OmniLight3D] = []
	for z in [-2.0, -8.0, -14.0, -20.0, -26.0, -32.0]:
		var l := OmniLight3D.new()
		l.light_color = Color("ff2a1a")
		l.omni_range = 9.0
		l.position = Vector3(0, 2.9, z)
		b.add_child(l)
		lights.append(l)
		Props.ball(b, 0.12, Vector3(0, 3.3, z), Color("ff2a1a"), Vector3(1, 0.6, 1), 8, 3.0)
	for n in b.find_children("*", "OmniLight3D", true, false):
		if not (n in lights):
			(n as OmniLight3D).light_energy = 0.15
	# Kapılardaki "1453" yazıları
	var plates: Array[Label3D] = []
	for n in b.find_children("*", "Label3D", true, false):
		var lb := n as Label3D
		# Kameranın yanındaki kapılar da 1453 olur: yazının titreyip değiştiği görülsün
		if lb.text == "1453" or (lb.text.is_valid_int() and absf(lb.global_position.z - (o.z - 24.0)) < 3.0):
			lb.text = "1453"
			plates.append(lb)
	# Nihat koridorun başından koşarak gelir, elinde dosya
	var nihat := Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
		"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	b.add_child(nihat)
	nihat.position = Vector3(0.3, 0, -6.0)
	nihat.set_meta("no_chat", true)
	var file := Props.box(nihat, Vector3(0.32, 0.03, 0.24), Vector3(0.28, 1.1, 0.3), Color("d8b878"), Vector3(-60, 0, 0))
	_alarm_on = true
	_alarm_loop(b, lights, plates)
	await hud.fade_to(0.0, 0.25, Color.WHITE)
	var run := nihat.create_tween()
	_alarm_tweens.append(run)
	run.tween_property(nihat, "position", Vector3(0.1, 0, -20.5), _dd(2.2))
	nihat.rotation.y = PI
	await _al("SPK_MUFIDE", "D26_M_ALARM")
	nihat.face_toward(player.global_position)
	nihat.talking = true
	await _al("SPK_NIHAT", "D26_N_ALARM_1")
	nihat.talking = false
	await _al("SPK_TOLGA", "D26_T_ALARM")
	nihat.talking = true
	await _al("SPK_NIHAT", "D26_N_ALARM_2")
	nihat.talking = false
	file.visible = false
	for k in 5:
		_paper(b, nihat.position + Vector3(0.2, 1.2, 0.2), true)
	await _al("SPK_MUFIDE", "D26_M_ALARM_2")
	# Kapının yılı yeni dünyaya döner
	var year: String = {"W10": "1454", "W11": "1455", "W12": "14??"}.get(Siege.pending_world(true), "1454")
	for pl in plates:
		pl.text = year
		pl.modulate = Color("c8262f")
	if GameState.shots_dir != "":
		await get_tree().create_timer(0.8).timeout
		await _shot("c26_02b_alarm.png")
	nihat.talking = true
	await _al("SPK_NIHAT", "D26_N_ALARM_3")
	nihat.talking = false
	_alarm_on = false
	await hud.fade_to(1.0, 0.3, Color.WHITE)
	# Önce döngü bitsin ve Büro'yu süren tweenler dursun; sonra Büro görünmez olur ve bir kare sonra silinir
	for tw in _alarm_tweens:
		if tw and tw.is_valid():
			tw.kill()
	_alarm_tweens.clear()
	await get_tree().process_frame
	await get_tree().process_frame
	b.visible = false
	b.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().process_frame
	b.queue_free()
	for c in hidden:
		if is_instance_valid(c):
			c.visible = true
	if walls.env and wall_env:
		walls.env.environment = wall_env
	Audio.voice_space("outdoor")
	player.global_position = back_pos
	player.face(look)
	await hud.fade_to(0.0, 0.4, Color.WHITE)


## Alarm repliği (ekran görüntüsü modunda beklemeden geçer: orada kimse "devam"a basmaz).
func _al(spk: String, key: String) -> void:
	if GameState.shots_dir != "":
		await get_tree().create_timer(0.6).timeout
		return
	await hud.say(spk, key)


## Alarm sürerken: siren, çakarlar, sarsıntılar (yer sallanır), tavandan dökülen dosyalar, titreyen yıl yazıları.
func _alarm_loop(b: Node3D, lights: Array[OmniLight3D], plates: Array[Label3D]) -> void:
	var t := 0.0
	var siren := 0.0
	var quake := 0.4
	while _alarm_on and is_instance_valid(b):
		await get_tree().process_frame
		if not _alarm_on or not is_instance_valid(b):
			break
		var dt := get_process_delta_time()
		t += dt
		siren -= dt
		quake -= dt
		for i in lights.size():
			if is_instance_valid(lights[i]):
				lights[i].light_energy = 7.0 if fmod(t + i * 0.25, 0.8) < 0.4 else 0.5
		if siren <= 0.0:
			siren = 2.3
			Audio.sfx("alarm_klaxon", -8.0)
		if quake <= 0.0:
			quake = randf_range(1.1, 2.0)
			Audio.sfx("rumble", -3.0, randf_range(0.8, 1.1))
			player.shake(0.5)
			var jolt := b.create_tween()
			_alarm_tweens.append(jolt)
			jolt.tween_property(b, "position:x", randf_range(-0.06, 0.06), 0.06)
			jolt.tween_property(b, "position:x", 0.0, 0.1)
			for k in 3:
				_paper(b, Vector3(randf_range(-1.6, 1.6), 3.3, randf_range(-26.0, -16.0)))
		for pl in plates:
			if is_instance_valid(pl) and pl.modulate != Color("c8262f"):
				pl.text = ["1453", "14?3", "1 453", "145_"][int(t * 9.0) % 4]


## Tavandan (ya da Nihat'ın dosyasından) dökülen bir kâğıt: dönerek yere iner, orada kalır.
func _paper(b: Node3D, from: Vector3, scatter := false) -> void:
	var p := Props.box(b, Vector3(0.21, 0.004, 0.29), from, Color("efe9d8"), Vector3(randf_range(-40, 40), randf_range(0, 360), 0))
	var to := from + Vector3(randf_range(-1.2, 1.2) if scatter else randf_range(-0.4, 0.4), 0, randf_range(-1.2, 1.2) if scatter else 0.0)
	to.y = 0.02
	var tw := p.create_tween().set_parallel()
	_alarm_tweens.append(tw)
	tw.tween_property(p, "position", to, randf_range(1.0, 1.8)).set_ease(Tween.EASE_IN)
	tw.tween_property(p, "rotation", Vector3(0, randf_range(0, TAU), 0), 1.6)


## Oyuncudan hedeflere giden görüş çizgisindeki savunucuları kenara çeker (tüfekçiyi ve komutanı kimse örtmesin).
func _clear_line(from: Vector3, targets: Array) -> void:
	# Kenara çekildiği yer görünen zeminde (moloz yamacında yüksekliği değişir), bir katının ya da başkasının içi değil
	Unclip.clear_line(self, from, targets, [giust, emperor, player])


## Hücum püskürtülür: Giustiniani ayakta kalır, adamları gediği tutar, yeniçeriler geri çekilir. Şehir o sabah düşmez.
func _hold() -> void:
	gunner.queue_free()
	# Tarih kırıldı: aynı anda zamanın dışında, Büro'da kırmızı alarm
	await _bureau_alarm()
	await hud.say("SPK_GIUST", "D26_G_STAY")
	await hud.say("SPK_DEFENDER", "D26_S_STAY")
	for a in attackers:
		if is_instance_valid(a):
			var back := create_tween()
			back.tween_property(a, "global_position", a.global_position + Vector3(0, 0, 14.0), 3.0)
	await get_tree().create_timer(_dd(1.2)).timeout
	await hud.say("SPK_LOOKOUT", "D26_L_RETREAT")
	if assault:
		assault.victory()
	walls.make_dawn(0.3)
	# İmparator gediğe gelir, Giustiniani'nin yanında durur (dumana yürümez)
	emperor.visible = true
	# Yüksekliği yamaçtan (Giustiniani'ninkinden değil: yamaç orada daha alçak, havada duruyordu)
	emperor.position = LandWalls.on_rubble(Vector3(giust.position.x + 1.3, 0.0, giust.position.z - 0.8))
	emperor.look_target = player
	player.face(emperor.global_position + Vector3(0, 1.5, 0))
	var ans: String = GameState.chapter_outcomes.get(12, "")
	await hud.say("SPK_EMPEROR", "D26_K_HOLD_%s" % {"12B.2": "2", "12B.3": "3"}.get(ans, "1"))
	# Tespit karesi: gedikte ayakta kalan komutan ve İmparator
	var target := Node3D.new()
	add_child(target)
	target.global_position = (giust.global_position + emperor.global_position) * 0.5 + Vector3(0, 1.4, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ26_HOLD_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege26")
	hud.add_child(cam)
	cam.max_dist = 30.0
	cam.cone_deg = 16.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_NIHAT", "D26_N_HOLD")
	await hud.say("SPK_TOLGA", "D26_T_HOLD")
	await hud.say("SPK_NIHAT", "D26_N_HOLD_2")
	_outcome = "26.3"
	Siege.record(26, _photo, "SIEGE_NOTE_26_3")
	Siege.resolve(true)
	# Şehir düşmediği için Galata (27) ve Büro kapanışı yok: dönüş buradan (eskiden siege_done kurulmuyordu,
	# Bölüm 15'te müdürün "bir ay" sorusu bu yolda hiç gelmiyordu)
	await hud.say("SPK_NIHAT", "D26_N_RETURN")
	await hud.say("SPK_TOLGA", "D26_T_RETURN")
	GameState.flags["siege_done"] = true
	Audio.sfx("machine_jump", -4.0)
	await hud.fade_to(1.0, 1.5, Color.WHITE)
	await hud.card([[tr("UI_ACT4_END_HOLD"), 34, Color("f2e6c9")],
		[tr(GameState.line_variant("UI_ACT4_END_SUB")) % [Siege.page_count(), Siege.page_total()], 18, Color(1, 1, 1, 0.75)]], 3.5)
	hud.clear_card()


## Yaralı Giustiniani'nin taşınma pozu. _carry_at: gövdenin ortası (yerde); dir: başın yönü (poterna).
## h: sırtın yerden yüksekliği; k: 0 ayakta → 1 sırt üstü yatmış. Gövde zeminin (moloz yamacı) eğimine yaslanır.
var _carry_at := Vector3.ZERO


func _carry_pose(dir: Vector3, h: float, k: float) -> void:
	var feet := _carry_at - dir * 0.9
	var head := _carry_at + dir * 0.9
	# Görünen zemin (yamaç formülü gediğin iç yanında toprağın yarım metre üstündeydi: vurulan komutan havada duruyordu)
	feet.y = LandWalls.rubble_y(feet.x, feet.z)
	head.y = LandWalls.rubble_y(head.x, head.z)
	var ffy := _visible_floor(feet)
	if not is_nan(ffy):
		feet.y = ffy
	var hfy := _visible_floor(head)
	if not is_nan(hfy):
		head.y = hfy
	var along := (head - feet).normalized()
	# Ayakta (k 0): ayakları yerde dik; yatmış (k 1): ayaklardan başa uzanan çizgi boyunca, h kadar yukarıda
	var up_stand := Vector3.UP
	var lying_up := along                      # Person'un yerel +Y'si (ayaktan başa) gövde boyunca
	var up := up_stand.slerp(lying_up, k).normalized()
	var fwd_flat := Vector3(dir.x, 0, dir.z).normalized()
	var face := fwd_flat.slerp(Vector3.UP, k).normalized()      # yatınca yüzü göğe
	var x := up.cross(face).normalized()
	face = x.cross(up).normalized()
	var base := feet + Vector3.UP * lerpf(0.0, h, k)
	giust.global_transform = Transform3D(Basis(x, up, face), base)
	if bearers.size() == 2 and k >= 1.0:
		for i in 2:
			var b: Person = bearers[i]
			b.global_position = _bearer_spot(dir, i)
			b.rotation.y = atan2(dir.x, dir.z) + (0.0 if i == 1 else PI)


## Taşıyıcının yeri: 0 başta (koltuk altları; önde, geri geri yürür), 1 ayak ucunda (arkada).
func _bearer_spot(dir: Vector3, i: int) -> Vector3:
	var p := _carry_at + dir * (1.35 if i == 0 else -1.35)
	p.y = LandWalls.rubble_y(p.x, p.z)
	# Görünen zemin: gediğin iç yanında yamaç formülü (ve onun görünmez çarpışma kutusu) görünen toprağın yarım metre
	# üstünde kalıyordu (taşıyıcı havada). Yalnız görünen gövdeler sayılır (denetçinin ölçüsü)
	var fy := _visible_floor(p)
	if not is_nan(fy):
		p.y = fy
	return p


func _visible_floor(p: Vector3) -> float:
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 1.0, 0), p + Vector3(0, -1.6, 0), 1)
	for i in 6:
		var h := get_world_3d().direct_space_state.intersect_ray(q)
		if h.is_empty():
			break
		# Yalnız görünen sabit zemin (yerde yatan komutanın, taşıyanların gövdesi değil)
		if h["collider"] is StaticBody3D and Unclip.visible_body(h["collider"]):
			return (h["position"] as Vector3).y
		q.exclude = q.exclude + [(h["collider"] as CollisionObject3D).get_rid()]
	return NAN


## Girişin sahnesi: hendek dolgusu, iki yanda yeniçeriler, at ve Sultan, arkada vezirler.
func _entry_stage() -> Dictionary:
	# Hendek, gedik önünde toprakla doldurulmuş (atın yolu)
	Props.box(walls, Vector3(8.0, 3.0, 17.0), Vector3(0, -1.5, 28.0), Color("6a5a40"))
	var line: Array[Node3D] = []
	# Yolun iki yanı: hendek dolgusunun üstü (dışarıda) ve peribolos (içeride); moloz yamacında kimse durmaz
	var zs := [32.0, 28.5, 25.0, 21.5, 8.0, 4.5, 1.0]      # iç surun (z -4..-0.6) içinde kimse durmaz
	for i in zs.size() * 2:
		var side := -1.0 if i % 2 == 0 else 1.0
		var z: float = zs[i / 2]
		var s := Soldier.new(Color("2f5fa8") if i % 3 != 2 else Color("b3262d"), "stand", "bork")
		s.position = Vector3(side * 3.0, 0.0, z)
		s.position.y = _entry_ground(s.position)
		s.rotation.y = -side * PI * 0.5
		add_child(s)
		s.equip("spear")
		line.append(s)
	# Peribolos (surlar arası) ve şehir tarafı: iki yanda saf saf yeniçeriler, sancaklar; hepsi yola dönük
	for side: float in [-1.0, 1.0]:
		for row in 2:
			for k in 7:
				var z := 11.0 - k * 2.0
				var x := side * (4.4 + row * 1.3) + randf_range(-0.15, 0.15)
				if z < 0.0 or (side > 0.0 and z < 5.0):
					continue
				var s := Soldier.new([Color("2f5fa8"), Color("b3262d"), Color("3a6b3a"), Color("8a6a4a")][(row + k) % 4], "stand", "bork" if (row + k) % 3 != 0 else "turban")
				s.set_meta("no_talk", true)
				s.position = Vector3(x, 0.0, z + randf_range(-0.2, 0.2))
				s.rotation.y = -side * PI * 0.5 + randf_range(-0.2, 0.2)
				add_child(s)
				s.equip(["spear", "sword_shield", "spear"][(row + k) % 3])
				line.append(s)
		for k in 2:
			var bp := Node3D.new()
			bp.position = Vector3(side * 7.5, 0, 9.0 - k * 8.0)
			add_child(bp)
			Props.make_solid(Props.cyl(bp, 0.05, 5.0, Vector3(0, 2.5, 0), Color("4a3420"), Vector3.ZERO, 5))
			Props.ball(bp, 0.12, Vector3(0, 5.1, 0), Color("d8b040"), Vector3.ONE, 6)
			Props.box(bp, Vector3(0.03, 1.3, 2.0), Vector3(0, 4.2, -1.0 * side), Color("b3262d") if k == 0 else Color("2e6a3a"))
			line.append(bp)
	var horse := Horse.new(Color("e4e0d8"))
	add_child(horse)
	var sultan := Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	horse.mount(sultan)
	horse.position = Vector3(0, 0, 44.0)
	horse.rotation.y = PI
	var retinue: Array[Node3D] = []
	for i in 4:
		var v := Person.new({"coat": [Color("2f4a6a"), Color("3a6b3a"), Color("f0e8d8"), Color("6a4a2c")][i], "pants": Color("2a2a30"),
			"hat": "turban", "beard": true, "robe": [Color("2f4a6a"), Color("3a6b3a"), Color("f0e8d8"), Color("6a4a2c")][i]})
		v.set_meta("no_talk", true)
		v.set_meta("no_chat", true)      # yol boyundaki yeniçerilerle sohbete dönüp yanlış tarafa bakmasın
		v.position = Vector3(-1.0 + (i % 2) * 2.0, 0, 47.5 + (i / 2) * 1.6)
		v.rotation.y = PI
		add_child(v)
		retinue.append(v)
	return {"line": line, "horse": horse, "sultan": sultan, "retinue": retinue}


## Öğle: Sultan Mehmed beyaz atıyla gedikten (Topkapı / Aziz Romanos Kapısı yanı) şehre girer. Yeniçeriler yolun iki
## yanında; vezirler ve ulema arkasında. Tolga moloz yamacının yanında, kalabalığın arasında izler.
func _entry() -> void:
	phase = "entry"
	for a in attackers:
		a.queue_free()
	attackers.clear()
	Duelist.dismiss_idle(self)      # sabahki çarpışmadan kalan dost düellocular yol boyu dizilen yeniçerilerin içinde kalmasın
	for n: Node3D in [giust, emperor, banner] + defenders + bearers + ladders:
		if n:
			n.visible = false
	walls.set_repair(0)
	walls.make_day()
	if assault:
		assault.victory()
	if walls.field:
		walls.field.victory()
	Garrison.clear(get_tree())
	# Savunanların merdivenleri kaldırıldı (içinden geçen olmasın)
	for l in get_tree().get_nodes_in_group("ladder"):
		(l as Node3D).visible = false
	# Sabah hücumundan kalanlar: kalkanlar devrilmiş
	for mn in get_tree().get_nodes_in_group("mantlet"):
		(mn as Node3D).rotation.x = deg_to_rad(-82)
		(mn as Node3D).position.y = -0.9
		# Yolun kenarına savrulmuş: yol boyunca dizilen yeniçeriler devrik kalkanın içinde durmasın
		(mn as Node3D).position.x = signf((mn as Node3D).position.x) * 10.5
	var st := _entry_stage()
	var line: Array[Node3D] = st["line"]
	var horse: Horse = st["horse"]
	var sultan: Person = st["sultan"]
	var retinue: Array[Node3D] = st["retinue"]
	# İç surun kapısı açık; ardında yıkık, yanık cadde (Mese'ye giden yol)
	walls.open_inner_gate()
	var city := FallenCity.new()
	city.field = walls.field
	add_child(city)
	FallenCity.mood(walls.env.environment, walls.moon)
	# Oyuncu yolun sağ kenarında, safların bittiği açıklıkta (arada yeniçeri yok): atı gedikten inerken önden görür
	player.global_position = Vector3(2.4, 0.05, 0.8)
	player.face(Vector3(0, 2.5, 15.0))
	hud.set_fez(true)   # Tolga fesini takar: kalabalıkta Bizanslı sanılmasın
	# At, konuşmalar sürerken yaklaşır (boş bekleme olmasın): hendek dolgusu → gediğin tepesi, orada durur
	horse.position = Vector3(0, 0, 36.0)
	for r in retinue:
		r.position.z -= 8.0
	_trail = [horse.position]
	await hud.card([[tr("UI_CH26_ENTRY"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	var outside := [Vector3(0, 0, 30.0), Vector3(0, 0.1, 20.0), Vector3(0, 2.3, 15.0)]
	var riding := _ride(horse, retinue, outside)
	await hud.fade_to(0.0, 1.2, Color.WHITE)
	Audio.sfx("crowd_camp", -4.0, 0.9)
	await hud.say("SPK_NIHAT", "D26_N_HIDE")
	await hud.say("SPK_TOLGA", "D26_T_HIDE")
	player.face(horse.global_position + Vector3(0, 2.4, 0))
	await hud.say("SPK_NIHAT", "D26_N_ENTRY")
	await hud.say("SPK_TOLGA", "D26_T_ENTRY")
	while not _ride_done:
		await get_tree().process_frame
	# Gediğin üstünde durur, şehre bakar
	await hud.say("SPK_NIHAT", "D26_N_ENTRY_2")
	await hud.say("SPK_TOLGA", "D26_T_ENTRY_2")
	# Serbest: alayın yanında yürü (gedikten geri çıkılmaz, yan sokaklar molozla kapalı)
	var back := Props.solid(self, Vector3(LandWalls.BREACH_W + 4.0, 6.0, 0.4), Vector3(0, 3.0, 12.6), Color.WHITE)
	back.get_child(0).visible = false
	back.set_meta("no_climb", true)
	Lore.scatter(self, "26")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ26_FOLLOW"), sultan, 2.6)
	var inside := [Vector3(0, 0.6, 9.5), Vector3(0, 0.0, 5.0), Vector3(0, 0, -2.0), Vector3(0, 0, -8.0), Vector3(0.5, 0, -24.0),
		Vector3(-0.3, 0, -44.0), FallenCity.STOP]
	riding = _ride(horse, retinue, inside)
	# Yol boyunca: kapıdan geçince şehir, sancaklı evler; sarayın önünde durur
	while horse.position.z > -3.0 and not _ride_done:
		await get_tree().process_frame
	await hud.say("SPK_NIHAT", "D26_N_CITY")
	await hud.say("SPK_TOLGA", "D26_T_CITY")
	while horse.position.z > -28.0 and not _ride_done:
		await get_tree().process_frame
	await hud.say("SPK_NIHAT", "D26_N_FLAGS")
	while horse.position.z > -36.0 and not _ride_done:
		await get_tree().process_frame
	await _isidore_column()
	await hud.say("SPK_NIHAT", "D26_N_GIUST")
	while not _ride_done:
		await get_tree().process_frame
	sultan.look_target = null
	await hud.say("SPK_FATIH", "D26_F_COUPLET")
	await hud.say("SPK_NIHAT", "D26_N_COUPLET")
	await hud.say("SPK_FATIH", "D26_F_ENTRY")
	# Ayasofya'ya doğru devam eder; ekran ağarır
	riding = _ride(horse, retinue, [Vector3(0.2, 0, -72.0), Vector3(0, 0, -80.0)])
	var t := 0.0   # oyuncu hâlâ serbest: "Padişahı izle" hedefi ve işareti ağarmaya dek kalır
	while not _ride_done and t < 14.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	player.frozen = true
	await hud.fade_to(1.0, 1.5, Color.WHITE)
	for n in line + retinue:
		n.queue_free()
	horse.queue_free()
	back.queue_free()
	city.queue_free()
	for n in _entry_extras:
		if is_instance_valid(n):
			n.queue_free()
	_entry_extras.clear()


## Esir kafilesi: bir asker önde, beş esir (elleri önde bağlı gibi) caddenin sol kenarından kapıya doğru yürür. Üçüncüsü
## yırtık kahverengi cüppeli, ak sakallı yaşlı adam: Kardinal Isidoros (kaynaklar: kırmızı şapkasını bir ölüye giydirip
## esirlerin arasında, tanınmadan şehirden çıktı). Yakında bir asker kırmızı kardinal şapkasını mızrağının ucunda
## sallar. Kafile oyuncunun yanında bir an durur; Isidoros Tolga'ya bakar, parmağını dudağına götürür.
var _entry_extras: Array[Node] = []

func _isidore_column() -> void:
	var z0 := minf(player.global_position.z, -36.0) - 9.0
	var column: Array[Person] = []
	var isidore: Person
	for i in 6:
		var spec := {"coat": [Color("6a5040"), Color("5a6a7a"), Color("6a5a48"), Color("7a6a4a"), Color("4a4a3a"), Color("5a4a3a")][i],
			"pants": Color("3a3028"), "hair": Color("3a2a1e"), "mustache": true, "n": 2980 + i}
		if i == 0:
			spec = {"coat": Color("b3262d"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a"), "n": 2980}
		elif i == 3:
			spec = {"coat": Color("5a4a3c"), "robe": Color("5a4a3c"), "beard": true, "hair": Color("e8e8e8"), "hat": "none", "skin": Color("e8c0a0"),
				"face": "cardinal", "n": 2983}
		var p := Person.new(spec)
		p.set_meta("no_talk", true)
		p.position = Vector3(-1.8, 0, z0 - i * 1.3)
		p.rotation.y = 0.0
		add_child(p)
		if i == 0:
			p.equip("spear")
			p.set_meta("spk", "SPK_SOLDIER")      # kafilenin başı: tezkireye / Kasım'a cevap veren
		else:
			p.set_activity("carry")          # eller önde, bağlı gibi
		if i == 3:
			isidore = p
			p.set_meta("spk", "SPK_ISIDORE")
		column.append(p)
		_entry_extras.append(p)
	# Mızrağın ucunda kırmızı kardinal şapkası (galero), asker gülüyor
	var mock := Person.new({"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a"), "n": 2990})
	mock.set_meta("no_talk", true)
	mock.position = Vector3(2.3, 0, z0 + 3.0)
	mock.rotation.y = -PI * 0.5
	add_child(mock)
	var pole := Node3D.new()
	pole.position = Vector3(1.9, 0, z0 + 3.0)
	pole.rotation_degrees = Vector3(0, 0, 8)
	add_child(pole)
	Props.cyl(pole, 0.03, 2.8, Vector3(0, 1.4, 0), Color("5a3e26"), Vector3.ZERO, 5)
	Props.cyl(pole, 0.36, 0.04, Vector3(0, 2.86, 0), Color("b3262d"), Vector3.ZERO, 14)
	Props.cyl(pole, 0.16, 0.14, Vector3(0, 2.95, 0), Color("b3262d"), Vector3.ZERO, 12)
	for sd: float in [-1.0, 1.0]:
		for k in 3:
			Props.box(pole, Vector3(0.05, 0.14, 0.05), Vector3(sd * (0.28 + k * 0.05), 2.72 - k * 0.1, 0), Color("8a1a20"))
	mock.emote("laugh")
	_entry_extras.append(mock)
	_entry_extras.append(pole)
	# Kafile kapıya doğru yürür; Isidoros oyuncunun 6 m yakınına gelince (ya da 12 sn sonra) durur
	var t := 0.0
	var walking := true
	while walking:
		var dt := get_process_delta_time()
		t += dt
		for p in column:
			p.position.z += 0.9 * dt
			p.position.y = _entry_ground(p.position)      # yana itilen esir görünen zeminde kalsın
		if GameState.autotest or t > 12.0 or isidore.global_position.distance_to(player.global_position) < 6.0:
			walking = false
		await get_tree().process_frame
	isidore.look_target = player
	await get_tree().create_timer(_dd(0.6)).timeout
	var met: bool = GameState.flags.get("met_isidore", false)
	player.face(isidore.global_position + Vector3(0, 1.5, 0))      # Tolga onu fark eder (sonra yine serbestçe bakılır)
	await hud.say("SPK_TOLGA", "D26_T_ISI" if met else "D26_T_ISI_O")
	# Parmağını dudağına götürür: sus
	if isidore.rig:
		isidore.rig.lock += 1
	var hush := create_tween()
	hush.tween_property(isidore._arm_r, "rotation", Vector3(-2.3, 0, 0.45), _dd(0.4))
	hush.parallel().tween_property(isidore._elbow_r, "rotation:x", -2.1, _dd(0.4))
	await hush.finished
	await hud.say("SPK_NIHAT", "D26_N_ISI" if met else "D26_N_ISI_O")
	var down := create_tween()
	down.tween_property(isidore._arm_r, "rotation", Vector3(-0.55, 0, 0.18), _dd(0.4))
	down.parallel().tween_property(isidore._elbow_r, "rotation:x", -1.1, _dd(0.4))
	await down.finished
	if isidore.rig:
		isidore.rig.lock = maxi(0, isidore.rig.lock - 1)
	isidore.look_target = null
	# Sultan'ın tezkiresi (Bölüm 12): Tolga kafilenin başındaki askere tuğrayı gösterir. Kaynaklar Isidoros'un kaçtığını
	# yazar, nasıl kaçtığını yazmaz: bu yolda Tolga'nın kâğıdıyla çıkar (tarih aynı kalır, Tolga'nın sayfası değişir)
	if GameState.in_pocket("tezkire"):
		var was_frozen := player.frozen
		player.frozen = true
		var c := await hud.choose(["UI_C26_TEZ_FREE", "UI_C26_TEZ_SILENT"], 0.0, 0 if GameState.autotest_variant == "isidore" else 1)
		if c == 0:
			await _free_isidore(column, isidore)
		player.frozen = was_frozen
	# Bölüm 21: 23 Mayıs sorgusunda Tolga'nın sözüyle konuşan lağımcıbaşı Kasım şehir düşünce serbest kaldı. Isidoros
	# hâlâ kafiledeyse kafilenin yanından geçen Kasım tanır; Tolga ondan ihtiyarı isteyebilir
	if not GameState.flags.get("isidore_freed", false) and str(GameState.flags.get("siege21_talk", "")) == "talk":
		var was_frozen := player.frozen
		player.frozen = true
		await _kasim_frees(column, isidore)
		player.frozen = was_frozen
	# Kafile yoluna devam eder, kapıdan çıkar
	var go := func() -> void:
		var tt := 0.0
		while tt < 60.0 and is_instance_valid(isidore):
			var dt := get_process_delta_time()
			tt += dt
			for p in column:
				if is_instance_valid(p):
					p.position.z += 0.9 * dt
					p.position.y = _entry_ground(p.position)
					if p.position.z > -7.0:
						p.visible = false
			await get_tree().process_frame
	go.call()


## Tezkireyle kafileden çıkarılan Isidoros: asker tuğrayı alnına götürür, "kâtibimi" alıp götürmesine izin verir. Eller
## çözülür; kardinal Tolga'ya fısıldar ve yan sokağa sapar (Bölüm 27'de Galata rıhtımında yeniden görülür).
func _free_isidore(column: Array[Person], isidore: Person) -> void:
	var leader: Person = column[0]
	player.face(leader.global_position + Vector3(0, 1.5, 0))
	player.show_prop("tezkire", 2.6)
	GameState.pocket_use("tezkire", "isidore_26")
	await hud.say("SPK_TOLGA", "D26_T_TEZ_FREE")
	leader.look_target = player
	await hud.say("SPK_SOLDIER", "D26_S_TEZ_FREE")
	leader.look_target = null
	column.erase(isidore)
	isidore.set_activity("")
	isidore.look_target = player
	player.face(isidore.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_ISIDORE", "D26_I_TEZ_FREE")
	GameState.flags["isidore_freed"] = true
	GameState.flags["isidore_by"] = "tezkire"
	isidore.leave(player.global_position + Vector3(4.0, 0, 0), 9.0, 4.0, true)
	await hud.say("SPK_NIHAT", "D26_N_TEZ_FREE")


## Lağımcıbaşı Kasım (Bölüm 21): kafilenin başındaki askerin yanına gelir, Tolga'yı tanır. Tolga isterse "bir söz de
## sen tut" der; Kasım askere kardinali "tercümanın kâtibi" diye bıraktırır.
func _kasim_frees(column: Array[Person], isidore: Person) -> void:
	var leader: Person = column[0]
	var kasim := Person.new({"coat": Color("4a5a3a"), "pants": Color("3a3028"), "hat": "turban", "beard": true, "mustache": true,
		"hair": Color("2a1e14"), "skin": Color("c89070"), "n": 2195})
	kasim.set_meta("spk", "SPK_KASIM")
	add_child(kasim)
	_entry_extras.append(kasim)
	kasim.global_position = leader.global_position + Vector3(1.3, 0, 0.6)
	kasim.look_target = player
	player.face(kasim.global_position + Vector3(0, 1.5, 0))
	kasim.talking = true
	# Bölüm 21: tünelde Mirko'yla kaçılıp ateş atıldıysa (siege21_tunnel "fight") Kasım onu da hatırlar
	await hud.say("SPK_KASIM", "D26_KS_1_FIRE" if str(GameState.flags.get("siege21_tunnel", "")) == "fight" else "D26_KS_1")
	kasim.talking = false
	var c := await hud.choose(["UI_C26_KASIM_ASK", "UI_C26_TEZ_SILENT"], 0.0, 0 if GameState.autotest_variant == "kasim" else 1)
	if c != 0:
		kasim.emote("nod")
		kasim.leave(player.global_position + Vector3(-4.0, 0, 0), 9.0, 4.0, true)
		return
	await hud.say("SPK_TOLGA", "D26_T_KASIM_ASK")
	kasim.face_toward(leader.global_position)
	leader.look_target = kasim
	kasim.talking = true
	await hud.say("SPK_KASIM", "D26_KS_FREE")
	kasim.talking = false
	await hud.say("SPK_SOLDIER", "D26_S_KASIM_FREE")
	leader.look_target = null
	column.erase(isidore)
	isidore.set_activity("")
	isidore.look_target = player
	player.face(isidore.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_ISIDORE", "D26_I_KASIM_FREE")
	GameState.flags["isidore_freed"] = true
	GameState.flags["isidore_by"] = "kasim"
	isidore.leave(player.global_position + Vector3(4.0, 0, 0), 9.0, 4.0, true)
	kasim.leave(player.global_position + Vector3(-4.0, 0, 0), 9.0, 4.0, true)
	await hud.say("SPK_NIHAT", "D26_N_KASIM_FREE")


## Atı noktalar boyunca yürütür (adım hızında); maiyet izini takip eder. Oyuncu atın önüne çıkarsa bekler.
var _trail: Array[Vector3] = []
var _ride_done := false
var _ride_id := 0


## Alayın yolundaki zemin: dışarıda hendek dolgusunun üstü (y 0), gedikte moloz katmanları ve iç yamaç, içeride
## peribolos ve cadde.
func _entry_ground(p: Vector3) -> float:
	return maxf(0.0, LandWalls.rubble_y(p.x, p.z))
var _blocked_t := 0.0

func _ride(horse: Horse, retinue: Array[Node3D], points: Array) -> int:
	_ride_id += 1
	var my := _ride_id
	_ride_done = false
	_ride_loop(horse, retinue, points, my)
	return my


func _ride_loop(horse: Horse, retinue: Array[Node3D], points: Array, my: int) -> void:
	var spd := 1.7
	for pt: Vector3 in points:
		while is_instance_valid(horse) and my == _ride_id:
			var to := pt - horse.position
			to.y = 0.0          # yükseklik yolun noktalarından değil zeminden gelir (_entry_ground)
			if to.length() < 0.08:
				break
			var dt := get_process_delta_time()
			var dir := to.normalized()
			# Oyuncu önündeyse durur
			var rel := player.global_position - horse.global_position
			rel.y = 0.0
			var ahead := rel.dot(Vector3(dir.x, 0, dir.z).normalized()) if Vector2(dir.x, dir.z).length() > 0.01 else 0.0
			var lateral := (rel - Vector3(dir.x, 0, dir.z).normalized() * ahead).length()
			if ahead > 0.0 and ahead < 2.8 and lateral < 1.3:
				horse.speed = 0.0
				_blocked_t += dt
				# Uzun süre yolda durulursa oyuncu yavaşça yana itilir (alay sonsuza dek beklemez)
				if _blocked_t > 3.0:
					var side_dir := Vector3(-dir.z, 0, dir.x).normalized()
					if side_dir.dot(rel) < 0.0:
						side_dir = -side_dir
					player.global_position += side_dir * 1.2 * dt
				await get_tree().process_frame
				continue
			_blocked_t = 0.0
			horse.speed = spd
			horse.position += dir * minf(to.length(), spd * dt)
			# Gediğin basamaklı molozunu çıkar, iç yamaçtan iner (eskiden noktalar arası düz çizgide: dış basamaklara
			# 0,8 m gömülüyor, iç yamacın üstünde 1 m havada yürüyordu)
			horse.position.y = lerpf(horse.position.y, _entry_ground(horse.position), clampf(dt * 14.0, 0.0, 1.0))
			var flat := Vector3(dir.x, 0, dir.z)
			if flat.length() > 0.01:
				horse.rotation.y = lerp_angle(horse.rotation.y, atan2(flat.x, flat.z), clampf(dt * 5.0, 0.0, 1.0))
			if _trail.is_empty() or _trail[-1].distance_to(horse.position) > 0.2:
				_trail.append(horse.position)
			# Maiyet: izin 2.6 m ve 4 m gerisinde, ikişer yan yana
			for i in retinue.size():
				var back := 13 + (i / 2) * 7
				if _trail.size() > back:
					var tp: Vector3 = _trail[_trail.size() - 1 - back]
					var side := Vector3(cos(horse.rotation.y), 0, -sin(horse.rotation.y)) * (-0.8 if i % 2 == 0 else 0.8)
					var r := retinue[i]
					var np := tp + side
					# Yumuşak takip (izin 20 cm'lik noktalarına zıplayınca titriyordu) ve atın yönüne bakış. Yükseklik
					# o anki yerin zemininden (hedefin zemininden alınınca molozun basamaklarında geride kalıp gömülüyordu).
					var cur := r.position.lerp(np, clampf(dt * 6.0, 0.0, 1.0))
					# Basamağa çıkarken hemen basar (gecikince molozun basamağına gömülü yürüyordu), inerken çabuk iner
					var gy := _entry_ground(cur)
					cur.y = gy if gy > r.position.y else lerpf(r.position.y, gy, clampf(dt * 30.0, 0.0, 1.0))
					r.position = cur
					r.rotation.y = lerp_angle(r.rotation.y, horse.rotation.y, clampf(dt * 4.0, 0.0, 1.0))
			await get_tree().process_frame
	if is_instance_valid(horse):
		horse.speed = 0.0
	if my == _ride_id:
		_ride_done = true


## Ayasofya'ya sığınanlar (kaynaklar: melek kehanetine inanıp binlerce kişi kiliseye kapandı): yan neflerde ve apsisin
## önünde yere oturmuş, birbirine sokulmuş aileler, çocuklar, dua eden bir papaz; ortalarında mumlar. Bazıları başını
## kaldırmış kubbeye bakar. Fetihten sonra kilisede Bizans muhafızı durmaz.
func _refugees() -> void:
	var inner := city.get_node_or_null("AyasofyaInterior")
	if inner:
		for n in inner.get_children():
			if n is Person:
				if str((n as Person).get("hat")) == "helm" or (n as Node3D).position.x > 9.0:
					(n as Node3D).visible = false
				else:
					(n as Person).set_activity("sit_ground")
	var rng := RandomNumberGenerator.new()
	rng.seed = 291453
	var coats := [Color("6a3a5a"), Color("5a4a3a"), Color("3a5a6a"), Color("7a6a4a"), Color("4a3a4a"), Color("6a5040"), Color("2a3a5a")]
	var groups := [[Vector3(-7.5, 0, 3.0), 4], [Vector3(-6.6, 0, -4.2), 3], [Vector3(7.4, 0, -2.0), 4], [Vector3(-2.8, 0, -7.2), 3],
		[Vector3(7.8, 0, 5.6), 2]]
	var k := 0
	for g in groups:
		var c: Vector3 = g[0]
		var n: int = g[1]
		for i in n:
			var a := TAU * i / n + rng.randf_range(-0.3, 0.3)
			var child := i == n - 1 and n >= 3
			var p := Person.new({"coat": coats[k % coats.size()], "robe": coats[k % coats.size()], "skirt": k % 2 == 0,
				"hat": ["hood", "none", "bun", "none"][k % 4], "beard": k % 3 == 1, "hair": [Color("3a2a1e"), Color("6a6a6a"), Color("5a3a1e")][k % 3],
				"child": child, "n": 2900 + k})
			p.set_meta("no_talk", true)
			p.set_meta("no_yield", true)
			if child:
				p.scale = Vector3.ONE * 0.6
			p.position = AYA + c + Vector3(cos(a), 0, sin(a)) * (0.55 if child else 0.8)
			p.rotation.y = atan2(-cos(a), -sin(a))        # ortaya (mumlara) dönük
			add_child(p)
			p.set_activity("sit_ground")
			if k % 4 == 1 and p.rig:
				p.rig.lock += 1
				p._head.rotation.x = -0.6                   # kubbeye bakar: melek bekler
			k += 1
		# Ortada mumlar
		for j in 3:
			var cp := AYA + c + Vector3(rng.randf_range(-0.2, 0.2), 0, rng.randf_range(-0.2, 0.2))
			Props.cyl(self, 0.025, 0.2 + j * 0.05, cp + Vector3(0, 0.1, 0), Color("f4ecd0"), Vector3.ZERO, 6)
			var fl := Props.ball(self, 0.02, cp + Vector3(0, 0.24 + j * 0.05, 0), Color("ffd070"), Vector3(1, 1.8, 1), 5, 3.0)
			fl.material_override = Props.mat(Color("ffd070"), 4.0, false, "", false)
		var l := OmniLight3D.new()
		l.position = AYA + c + Vector3(0, 0.6, 0)
		l.light_color = Color("ffb060")
		l.light_energy = 0.9
		l.omni_range = 3.0
		add_child(l)
	# Dua eden papaz: apsisin önünde, diz çökmüş
	var priest := Person.new({"coat": Color("1e1e22"), "robe": Color("1e1e22"), "beard": true, "hat": "kamelaukion", "hair": Color("c8c8c8"), "n": 2950})
	priest.set_meta("no_talk", true)
	priest.set_meta("no_yield", true)
	priest.position = AYA + Vector3(0.8, 0, -9.0)
	priest.rotation.y = PI
	add_child(priest)
	priest.set_activity("sit_ground")


## Sultan kapının eşiğinde eğilir, yerden bir avuç toprak alır ve sarığının üstüne serper.
func _fatih_earth() -> Tween:
	if fatih.rig:
		fatih.rig.lock += 1
	var tw := create_tween()
	tw.tween_property(fatih._body, "rotation:x", 0.85, _dd(0.9)).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(fatih._arm_r, "rotation", Vector3(-0.9, 0, 0.1), _dd(0.9))
	tw.tween_interval(_dd(0.4))
	tw.tween_property(fatih._body, "rotation:x", 0.0, _dd(0.9)).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(fatih._arm_r, "rotation", Vector3(-2.9, 0, 0.3), _dd(0.9))
	tw.tween_callback(func():
		Vfx.dust(self, fatih.global_position + Vector3(0.1, 2.0, 0), 0.25)
		# Avuçtan sarığa dökülen toprak taneleri
		for q in 8:
			var grain := Props.ball(self, 0.025, fatih.global_position + Vector3(randf_range(-0.12, 0.12), 2.15, randf_range(-0.12, 0.12)), Color("6a5236"), Vector3.ONE, 4)
			var fall := create_tween()
			fall.tween_property(grain, "global_position:y", fatih.global_position.y + 1.85, _dd(0.5 + q * 0.05)).set_ease(Tween.EASE_IN)
			fall.tween_callback(grain.queue_free))
	tw.tween_interval(_dd(0.6))
	tw.tween_property(fatih._arm_r, "rotation", Vector3.ZERO, _dd(0.7))
	tw.tween_callback(func():
		if fatih.rig:
			fatih.rig.lock = maxi(0, fatih.rig.lock - 1))
	return tw


## Ayasofya'nın içi: kapıda Fatih, zemine balta vuran asker, koridorun iki yanında yeniçeriler, sığınanlar, oyuncu.
func _aya_stage() -> void:
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.position = AYA + Vector3(0, 0, 14.6)       # İmparator Kapısı'nın hemen içinde: eşikte eğilir
	fatih.rotation.y = PI
	add_child(fatih)
	# Baltalı asker: yan dönük, mermer zemine balta indiriyor (Fatih'in "Dur!"u ona); oyuncu onu Fatih'le aynı
	# kadrajda görür
	axeman = Soldier.new(Color("2f5fa8"), "stand", "bork")
	axeman.set_meta("spk", "SPK_SOLDIER")       # "Sultanım... mermer..."
	axeman.position = AYA + Vector3(1.4, 0, 1.6)     # Fatih'in durduğu yerin önünde; kameradan Fatih'in arkasında kalmaz
	axeman.rotation.y = PI * 0.5
	add_child(axeman)
	(axeman as Soldier).equip("axe")
	_chop_on = true
	_chop_loop()
	# Yeniçeriler koridorun iki yanında, ortası açık (Fatih içlerinden geçmesin), yüzleri koridora
	for i in 6:
		var side := -1.0 if i % 2 == 0 else 1.0
		var s := Soldier.new([Color("2f5fa8"), Color("b3262d"), Color("6a4a3a")][i % 3], "stand", "bork" if i % 2 == 0 else "turban")
		s.position = AYA + Vector3(side * (3.6 + (i / 2) * 1.4), 0, 11.5 - (i / 2) * 1.3)
		s.rotation.y = -side * PI * 0.5
		add_child(s)
	_refugees()
	if GameState.flags.get("siege_candle", false):
		_candle_stand()
	# Oyuncu koridorun solunda, önü açık: kapıdaki Fatih'i de baltalı askeri de görür
	player.global_position = AYA + Vector3(-4.5, 0.05, 6.0)
	player.face(AYA + Vector3(0, 6.0, -6.0))


## Bölüm 25'in mumluğu (aynı yerde): dünkü mumlar dibine kadar yanıp sönmüş, ortadaki uzun mum (Tolga'nın) hâlâ yanıyor.
func _candle_stand() -> void:
	var stand := AYA + Vector3(-5.5, 0, 7.5)
	_candle_lit_here = true
	Props.cyl(self, 0.05, 1.0, stand + Vector3(0, 0.5, 0), Color("c8a040"), Vector3.ZERO, 6)
	Props.cyl(self, 0.5, 0.08, stand + Vector3(0, 1.02, 0), Color("c8a040"), Vector3.ZERO, 16)
	for k in 9:
		var a := k * TAU / 9.0
		Props.cyl(self, 0.014, 0.04, stand + Vector3(sin(a) * 0.35, 1.08, cos(a) * 0.35), Color("e8dcc0"), Vector3.ZERO, 5)
	Props.cyl(self, 0.012, 0.16, stand + Vector3(0, 1.14, 0), Color("f4ecd0"), Vector3.ZERO, 5)
	var fl := Props.ball(self, 0.022, stand + Vector3(0, 1.25, 0), Color("ffc860"), Vector3(1, 1.6, 1), 5, 3.0)
	fl.material_override = Props.mat(Color("ffc860"), 3.0, false, "", false)
	var cl := OmniLight3D.new()
	cl.position = stand + Vector3(0, 1.4, 0)
	cl.light_color = Color("ffc070")
	cl.light_energy = 0.6
	cl.omni_range = 2.5
	add_child(cl)


var _candle_lit_here := false


## Baltalı asker mermere vurur: çekiç hareketi, her inişte taş sesi ve kırıntı. _chop_on false olunca durur.
var _chop_on := false


func _chop_loop() -> void:
	var sd := axeman as Soldier
	if sd and sd.rig:
		sd.rig.activity = "hammer"
	while _chop_on and is_instance_valid(axeman):
		await get_tree().create_timer(0.75).timeout
		if not _chop_on or not is_instance_valid(axeman):
			break
		var hit := axeman.global_position + axeman.global_transform.basis.z * 0.75 + Vector3(0, 0.05, 0)
		Audio.sfx_at("pick_tap", axeman, 2.0)
		for k in 3:
			var chip := Props.box(self, Vector3(0.05, 0.03, 0.04), hit, Color("e8e0d0"))
			var ct := chip.create_tween()
			ct.tween_property(chip, "position", hit + Vector3(randf_range(-0.4, 0.4), randf_range(0.2, 0.5), randf_range(-0.4, 0.4)), 0.25)
			ct.tween_property(chip, "position:y", hit.y - 0.02, 0.25)
			ct.tween_callback(chip.queue_free)
	if sd and is_instance_valid(sd) and sd.rig:
		sd.rig.activity = ""


## Kamerayı yumuşakça bir noktaya çevir.
func _pan_to(p: Vector3, sec: float) -> void:
	var from := player.camera.global_position + (-player.camera.global_transform.basis.z) * 5.0
	var tw := create_tween()
	tw.tween_method(func(k: float): player.face(from.lerp(p, k)), 0.0, 1.0, _dd(sec)).set_trans(Tween.TRANS_SINE)
	await tw.finished


func _dd(sec: float) -> float:
	return 0.05 if GameState.autotest else sec


## Öğleden sonra: Ayasofya. Fatih girer; taşa zarar veren bir askeri durdurur. Son kare.
func _aya() -> void:
	await _entry()
	phase = "aya"
	if assault:
		assault.queue_free()
		assault = null
	walls.queue_free()
	walls = null
	for a in attackers:
		a.queue_free()
	attackers.clear()
	await get_tree().process_frame
	city = ByzCity.new()
	city.part = "aya"             # tek harita: Ayasofya'nın gerçek yeri
	add_child(city)
	_aya_stage()
	await hud.card([[tr("UI_CH26_AYA"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.5, Color.WHITE)
	if _candle_lit_here:
		# Bölüm 25: dün akşam yakılan mum
		player.face(AYA + Vector3(-5.5, 1.2, 7.5))
		await hud.say("SPK_TOLGA", "D26_T_AYA_CANDLE")
	else:
		await hud.say("SPK_TOLGA", "D26_T_AYA")
	await hud.say("SPK_NIHAT", "D26_N_ANGEL")
	# Kapıda: eğilir, bir avuç toprak alıp sarığının üstüne serper (kaynaklar: Tanrı önünde alçakgönüllülük)
	player.face(fatih.global_position + Vector3(0, 1.4, 0))
	var earth := _fatih_earth()
	await hud.say("SPK_NIHAT", "D26_N_EARTH")
	if earth.is_running():
		await earth.finished
	# Fatih koridordan yürür; kamera onu izler. Yolun sonunda balta sesi: kamera baltalı askere döner.
	var tw := create_tween()
	tw.tween_property(fatih, "position", AYA + Vector3(0.2, 0, 4.6), _dd(5.0))
	var follow := create_tween()
	follow.tween_method(func(_k: float):
		if is_instance_valid(fatih):
			player.face(fatih.global_position + Vector3(0, 1.6, 0)), 0.0, 1.0, _dd(5.0))
	await tw.finished
	fatih.face_toward(axeman.global_position)
	await _pan_to(axeman.global_position + Vector3(0, 1.2, 0), 0.6)
	await get_tree().create_timer(_dd(1.2)).timeout
	# İkisi de kadrajda: aradaki noktaya bak
	await _pan_to((fatih.global_position + axeman.global_position) * 0.5 + Vector3(0, 1.5, 0), 0.5)
	await hud.say("SPK_FATIH", "D26_F_STOP")
	_chop_on = false
	(axeman as Soldier).face_toward(fatih.global_position)
	await get_tree().create_timer(_dd(0.4)).timeout
	await hud.say("SPK_SOLDIER", "D26_S_AXE")
	await hud.say("SPK_FATIH", "D26_F_TRUST")
	fatih.face_toward(AYA + Vector3(0, 20, -10))
	await get_tree().create_timer(1.0).timeout
	await hud.say("SPK_NIHAT", "D26_N_AYA")
	var pick := 1
	if _duel_won or Siege.side() != "O":
		pick = await hud.choose(["UI_C26_PHOTO", "UI_C26_POCKET"], 0.0, 1 if GameState.autotest_variant == "nophoto" else 0)
	else:
		await hud.say("SPK_TOLGA", "D26_T_MISSED")
	if pick == 0:
		var target := Node3D.new()
		add_child(target)
		target.global_position = fatih.global_position + Vector3(0, 2.0, -2.0)
		Lore.scatter(self, "26")
		player.frozen = false
		hud.set_objective(tr("UI_OBJ26_PHOTO"), target.global_position)
		cam = TespitCam.new(player, hud, target, "siege26")
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
		await hud.say("SPK_TOLGA", "D26_T_PHOTO")
	else:
		await hud.say("SPK_TOLGA", "D26_T_POCKET")
	_outcome = "26.1" if pick == 0 and cam != null and cam.done else "26.2"
	Siege.record(26, _photo if _outcome == "26.1" else "", "SIEGE_NOTE_26_%s" % _outcome.split(".")[1])
	await hud.say("SPK_NIHAT", "D26_N_LIFT")
	Audio.sfx("machine_jump", -4.0)
	await hud.fade_to(1.0, 1.0)


## Kapanış: Çarşamba. Büro'da dosya imzalanır, ofiste müdür hafta sonunu sorar.
# ================================================================ taşıma (1. ve 2. dalga)

func _update_objective() -> void:
	match phase:
		"wave1":
			if carrying == "water":
				hud.set_objective(tr("UI_OBJ26_ARROWS_GIVE") % [water, 3], LandWalls.BREACH + Vector3(0, 1.6, -2.0))
			else:
				hud.set_objective(tr("UI_OBJ26_ARROWS") % [water, 3], WELL + Vector3(0, 1.2, 0))
		"wave2":
			if carrying != "":
				hud.set_objective(tr("UI_OBJ26_REPAIR_PUT") % [repaired, 3], LandWalls.BREACH + Vector3(0, 2.2, -1.2))
			else:
				hud.set_objective(tr("UI_OBJ26_REPAIR") % [repaired, 3], LandWalls.DEPOT + Vector3(0, 1.2, 0))


func _pick(kind: String) -> void:
	if carrying != "":
		return
	carrying = kind
	_carry = Node3D.new()
	_carry.position = Vector3(0.3, -0.78, -1.05)
	_carry.scale = Vector3.ONE * 0.6
	player.camera.add_child(_carry)
	if kind == "water":
		# Kolun altında iki ok demeti ("water" adı sayaçlar ve testler için korunur)
		_carry.position = Vector3(0.32, -0.5, -0.75)
		_carry.rotation = Vector3(0.2, 0.9, 0.35)
		_carry.scale = Vector3.ONE
		for k in 2:
			var bd := BattleExtras.arrow_bundle(_carry)
			bd.position = Vector3(k * 0.14, -k * 0.05, k * 0.06)
	else:
		Props.cyl(_carry, 0.3, 0.8, Vector3.ZERO, LandWalls.C_WOOD, Vector3(90, 0, 0), 10)
	Props.strip_outlines(_carry)
	player.speed_mult = 0.8
	Audio.sfx("land_thud" if kind == "water" else "land_pot", -12.0, 1.2)
	_update_objective()


func _drop() -> void:
	carrying = ""
	if _carry:
		_carry.queue_free()
		_carry = null
	player.speed_mult = 1.0


func _deliver() -> void:
	if phase == "wave1" and carrying == "water":
		_drop()
		water += 1
		hud.bark("SPK_DEFENDER", "D26_S_ARROWS_%d" % water, 2.2)
	elif phase == "wave2" and carrying != "" and carrying != "water":
		_drop()
		repaired += 1
		walls.set_repair(LandWalls.STAGES - 4 + repaired)
		Audio.sfx("land_thud", -6.0, 1.2)
	_update_objective()


func _process(delta: float) -> void:
	_t += delta
	if walls == null:
		return
	# Hücum sırasında surun ötesinde ateş, patlama, toz
	if phase in ["wave1", "wave2", "wave3"]:
		_fx_t -= delta
		if _fx_t <= 0.0:
			_fx_t = randf_range(0.8, 2.0)
			Vfx.explosion(walls, Vector3(randf_range(-14, 18), randf_range(1.0, 7.0), randf_range(22.0, 30.0)), randf_range(0.3, 0.6))
			Audio.sfx("explosion_small", -16.0, randf_range(0.8, 1.2))
		for a in attackers:
			if a.position.z > 24.0 and a.visible:
				# Hemen önünde (0,6 m içinde) duran biri varsa bekler (hendekte üst üste birikmesinler)
				var blocked := false
				for o in attackers:
					if o != a and o.visible and o.position.z < a.position.z and a.position.z - o.position.z < 0.6 \
							and absf(o.position.x - a.position.x) < 0.5:
						blocked = true
						break
				if blocked:
					continue
				a.position.z -= delta * 2.2
				# Hendeğe iner (eskiden hendeğin üstünde, havada yürüyorlardı)
				a.position.y = Assault.ground_y(a.position.x, a.position.z)
				# Görünen zemine basar (karşı duvarın dibinde eğri, görünen zeminin 0,3 m üstünde kalıyordu)
				var fy := _visible_floor(a.global_position)
				if not is_nan(fy):
					a.global_position.y = fy
	if phase == "wave2" and not player.frozen:
		_gun_t -= delta
		if not _warn and _gun_t <= 4.0:
			_warn = true
			hud.bark("SPK_LOOKOUT", "D20_L_WARN_1", 3.0)
			Audio.stinger("warn", -9.0)
			hud.set_qte(tr("UI_QTE20_COVER"))
		if _gun_t <= 0.0:
			_fire()


func _fire() -> void:
	_warn = false
	_gun_t = randf_range(22.0, 28.0)
	hud.set_qte("")
	walls.fire_flash()
	Audio.sfx("cannon", 0.0, 0.8)
	await get_tree().create_timer(1.1).timeout
	if walls == null:
		return
	walls.impact(LandWalls.BREACH + Vector3(randf_range(-2.5, 2.5), 2.0, 0.6))
	Audio.sfx("explosion_big", -4.0)
	player.shake(0.5)
	var p := player.global_position
	var safe := p.distance_to(LandWalls.BREACH) > 9.0 or p.distance_to(LandWalls.DEPOT) < 4.5
	for m: Vector3 in LandWalls.MANTLETS:
		if absf(p.x - m.x) < 1.5 and p.z < m.z + 0.9 and p.z > m.z - 2.2:
			safe = true
	if not safe:
		_knocks += 1
		player.stagger(1.2)
		player.hurt(40.0, LandWalls.BREACH + Vector3(0, 2.0, 30.0))
		if carrying != "":
			_drop()
			_update_objective()
		hud.bark("SPK_TOLGA", "D20_T_KNOCK_%d" % mini(_knocks, 3), 3.0)


func _on_focus(id: String) -> void:
	match id:
		"well":
			hud.set_prompt(tr("UI_PROMPT26_ARROWS") if phase == "wave1" and carrying == "" else "")
		"pile_barrel", "pile_earth", "pile_plank":
			hud.set_prompt(tr("UI_PROMPT20_TAKE") % tr("UI_ITEM20_" + id.trim_prefix("pile_").to_upper()) if phase == "wave2" and carrying == "" else "")
		"breach":
			hud.set_prompt(tr("UI_PROMPT26_GIVE") if carrying != "" else "")
		"block_0", "block_1":
			hud.set_prompt(tr("UI_PROMPT26_BLOCK") if phase == "wave3" else "")
		_:
			hud.set_prompt("")


func _on_interact(id: String) -> void:
	match id:
		"well":
			if phase == "wave1":
				_pick("water")
		"pile_barrel", "pile_earth", "pile_plank":
			if phase == "wave2":
				_pick(id.trim_prefix("pile_"))
		"breach":
			_deliver()
		"block_0", "block_1":
			if phase != "wave3":
				return
			var b := get_node_or_null("Block%s" % id.trim_prefix("block_")) as Node3D
			if b == null or b.has_meta("moved"):
				return
			b.set_meta("moved", true)
			for c in b.get_children():
				if c is StaticBody3D:
					c.queue_free()
			# Fıçı yana yatırılır: yan yatınca ekseni yataydır, yarıçapı (0,42) kadar yükselir (eskiden yarısı toprağa
			# gömülüyordu). Yattığı yerde katıdır.
			# Omuz verip devirir: önce sallanır (zorlanma), sonra yan yatıp yoldan yuvarlanır
			player.shake(0.18)
			Audio.sfx("land_thud", -10.0, 0.6)
			var tw := create_tween()
			tw.tween_property(b, "rotation:z", deg_to_rad(8), 0.12)
			tw.tween_property(b, "rotation:z", deg_to_rad(-5), 0.12)
			tw.tween_property(b, "rotation:z", 0.0, 0.08)
			tw.tween_property(b, "rotation:x", deg_to_rad(90), 0.35).set_ease(Tween.EASE_IN)
			tw.parallel().tween_property(b, "position", b.position + Vector3(0, 0.42, 0.6), 0.35)
			tw.tween_callback(func():
				Audio.sfx("land_thud", -4.0, 0.7)
				Vfx.dust(self, b.global_position, 0.6)
				player.shake(0.25))
			# Yuvarlanır (ekseni yatay: x'te döner) ve duvarın dibinde durur
			tw.tween_property(b, "position", b.position + Vector3(0, 0.42, 2.6), 0.7).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(b, "rotation:y", deg_to_rad(200), 0.7).set_ease(Tween.EASE_OUT)
			tw.tween_callback(func():
				for c in b.get_children():
					if c is MeshInstance3D and (c as MeshInstance3D).mesh is CylinderMesh and ((c as MeshInstance3D).mesh as CylinderMesh).height > 0.5:
						Props.make_solid(c as MeshInstance3D)
						break)
			Audio.sfx("land_thud", -6.0, 0.8)
			_cleared += 1
			hud.set_objective(tr("UI_OBJ26_CLEAR") % [_cleared, BLOCKS.size()], POSTERN + Vector3(0, 1.2, 0))
			if _cleared < BLOCKS.size():
				hud.bark("SPK_DEFENDER", "D26_S_CLEAR_1", 2.2)
			else:
				_open_postern()


## Yol açılınca poterna da açılır: içeriden fenerli bir nöbetçi kanatları çeker, sıcak ışık peribolosa düşer
func _open_postern() -> void:
	var door := Vector3(POSTERN.x, 0.0, LandWalls.INNER_Z1)
	var glow := OmniLight3D.new()
	glow.light_color = Color("ffb862")
	glow.light_energy = 0.0
	glow.omni_range = 7.0
	glow.position = door + Vector3(0, 1.8, 0.6)
	add_child(glow)
	for k: float in [-1.0, 1.0]:
		var hinge := Node3D.new()
		hinge.position = door + Vector3(k * 1.0, 0, 0.12)
		add_child(hinge)
		Props.box(hinge, Vector3(0.95, 3.0, 0.1), Vector3(-k * 0.48, 1.5, 0), Color("4a3220"))
		Props.box(hinge, Vector3(0.95, 0.12, 0.12), Vector3(-k * 0.48, 2.2, 0.06), Color("2a2622"))
		var tw := create_tween()
		tw.tween_interval(0.3)
		tw.tween_property(hinge, "rotation:y", k * deg_to_rad(-100), 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var lt := create_tween()
	lt.tween_interval(0.4)
	lt.tween_property(glow, "light_energy", 2.2, 0.8)
	Audio.sfx("door_metal", -6.0, 0.8)
	var keeper := Soldier.new(Color("5a6a7a"), "stand", "helm")
	keeper.position = door + Vector3(0.7, 0, 0.9)
	keeper.set_meta("no_talk", true)
	add_child(keeper)
	keeper.face_toward(giust.global_position)
	hud.bark("SPK_DEFENDER", "D26_S_CLEAR_2", 2.4)
	player.face(door + Vector3(0, 1.6, 0))


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	if _outcome != "26.3":
		Siege.resolve(false)
	GameState.set_outcome(26, _outcome)
	await Siege.show_page(hud, 26)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"replay":
			get_tree().reload_current_scene()
		"next":
			# Kuşatmanın son sayfası (Bölüm 27, Galata) ve Büro'daki kapanış
			var nxt := Siege.next_path(26)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW26_TITLE")
	c.nodes = [
		{"id": "waves", "key": "FLOW26_WAVES", "pos": Vector2(0.5, 0.12)},
		{"id": "dawn", "key": "FLOW26_DAWN", "pos": Vector2(0.5, 0.26)},
		{"id": "giust", "key": "FLOW26_GIUST", "pos": Vector2(0.3, 0.42)},
		{"id": "aya", "key": "FLOW26_AYA", "pos": Vector2(0.3, 0.58)},
		{"id": "26.1", "key": "FLOW_26_1", "pos": Vector2(0.16, 0.76), "outcome": true},
		{"id": "26.2", "key": "FLOW_26_2", "pos": Vector2(0.44, 0.76), "outcome": true},
		{"id": "26.3", "key": "FLOW_26_3", "pos": Vector2(0.76, 0.5), "outcome": true},
	]
	c.edges = [["waves", "dawn"], ["dawn", "giust"], ["dawn", "26.3"], ["giust", "aya"], ["aya", "26.1"], ["aya", "26.2"]]
	for k in (["waves", "dawn", "26.3"] if _outcome == "26.3" else ["waves", "dawn", "giust", "aya", _outcome]):
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH26_STATS") % [Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	c.footer_lines.insert(0, Grade.finish("26"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "26.1", "nophoto": "26.2", "hold": "26.3", "hold_box": "26.3", "hold23": "26.3", "hold3": "26.3",
		"hold_lose": "26.1"}.get(v, "26.1")
	var want_w: String = {"hold": "W10", "hold_box": "W10", "hold23": "W12", "hold3": "W11", "warn_notrust": "", "hold_lose": "W1"}.get(v, "")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("26", {})
	var ok: bool = _outcome == expected and not page.is_empty() and water == 3 and repaired == 3 \
		and (_cleared == 2 or _outcome == "26.3") and String(GameState.flags.get("world10", "")) == want_w
	# Yenilgi testi: oyuncu düelloda yere düşmüş ve düello kaybedilmiş olmalı
	if v.ends_with("lose"):
		ok = ok and player.downs >= 1 and not _duel_won
	# Şafak tüfeği: en az üç atış, en az bir isabet
	ok = ok and gun_shots >= 3 and gun_hits >= 1
	# Düşman tüfekçisi: en az bir atış; bot kaçar (=lose'da kaçmaz, yine de ateş edilmiş olmalı)
	# (=lose'da düello tüfekçinin ilk nişanından önce kaybedilebilir: atış beklenmez)
	ok = ok and (gunner_shots >= 1 or v.ends_with("lose")) and (gunner_dodged >= 1 or v.ends_with("lose"))
	if v == "lighter" and not ("lighter" in GameState.bag and GameState.given_to("lighter") == ""):
		printerr("AUTOTEST: yaralı Giustiniani çakmağı geri vermedi")
		ok = false
	# Tezkire Isidoros'u kafileden çıkarır; kâğıt cepte kalır (gösterildi, verilmedi)
	if v == "isidore" and not (GameState.flags.get("isidore_freed", false) and GameState.in_pocket("tezkire")):
		printerr("AUTOTEST: Isidoros kafileden çıkmadı (serbest=%s)" % GameState.flags.get("isidore_freed", false))
		ok = false
	if v == "kasim" and not (GameState.flags.get("isidore_freed", false) and GameState.flags.get("isidore_by", "") == "kasim"):
		printerr("AUTOTEST: Kasım Isidoros'u kafileden çıkarmadı")
		ok = false
	if (v == "candle") != _candle_lit_here:
		printerr("AUTOTEST: Ayasofya'daki mum=%s" % _candle_lit_here)
		ok = false
	if v == "council_ok" and not (_council_said == "ok" and ladder_foes == 1):
		ok = false
	if v == "council_bad" and not (_council_said == "bad" and ladder_foes == 2):
		ok = false
	if v == "hold" and Siege.next_path(26) != "":
		printerr("AUTOTEST: şehir düşmedi ama Bölüm 27 (ahitname) sırada")
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (su=%d onarım=%d fıçı=%d)" % [expected, _outcome, water, repaired, _cleared])
	print("AUTOTEST %s chapter=26 variant=%s outcome=%s water=%d repaired=%d cleared=%d world=%s gun=%d/%d gunner=%d/%d" % ["PASS" if ok else "FAIL", v, _outcome,
		water, repaired, _cleared, String(GameState.flags.get("world10", "")), gun_hits, gun_shots, gunner_dodged, gunner_shots])
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
	phase = "wave1"
	_wave_start(1)
	player.global_position = LandWalls.BREACH + Vector3(3.5, 0.05, -7.0)
	await get_tree().create_timer(1.0).timeout
	player.face(LandWalls.BREACH + Vector3(0, 2.5, 0))
	await _shot("c26_01_assault.png")
	walls.make_dawn(0.01)
	banner.visible = true
	banner.position = BANNER_TOWER
	emperor.visible = true
	emperor.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(1.5, 0, -4.0))
	player.face(BANNER_TOWER + Vector3(-6, 1.0, 0))
	await get_tree().create_timer(0.5).timeout
	await _shot("c26_02_banner.png")
	# Şafak: tüfekçi Giustiniani'ye nişan alıyor; ardından şehir düşmediyse gedikte komutan ve İmparator
	banner.visible = false
	emperor.visible = false
	gunner = Soldier.new(Color("2f5fa8"), "stand", "bork")
	add_child(gunner)
	# Barikatın yıkılan ortasında, fıçı sırasının önünde (eskiden toprak tabyanın içinde duruyordu)
	walls.set_repair(3)
	gunner.global_position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(0.9, 0, -0.8))
	gunner.set_meta("no_chat", true)
	gunner.face_toward(giust.global_position)
	gunner.equip("handgun")
	player.global_position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-0.6, 0, -5.2)) + Vector3(0, 0.05, 0)
	_clear_line(player.global_position, [gunner, giust])
	player.face((gunner.global_position + giust.global_position) * 0.5 + Vector3(0, 1.3, 0))
	await get_tree().create_timer(0.6).timeout
	await _shot("c26_02d_gunner.png")
	gunner.queue_free()
	emperor.visible = true
	# Yüksekliği yamaçtan (Giustiniani'ninkinden değil: yamaç orada daha alçak, havada duruyordu)
	emperor.position = LandWalls.on_rubble(Vector3(giust.position.x + 1.3, 0.0, giust.position.z - 0.8))
	player.face((giust.global_position + emperor.global_position) * 0.5 + Vector3(0, 1.4, 0))
	await get_tree().create_timer(0.4).timeout
	await _shot("c26_02h_hold.png")
	emperor.visible = false
	await _bureau_alarm()
	for l in ladders:
		l.visible = false
	banner.visible = false
	emperor.visible = false
	for a in attackers:
		a.queue_free()
	attackers.clear()
	walls.set_repair(0)
	walls.make_day()
	if assault:
		assault.victory()
	if walls.field:
		walls.field.victory()
	Garrison.clear(get_tree())
	# Savunanların merdivenleri kaldırıldı (içinden geçen olmasın)
	for l in get_tree().get_nodes_in_group("ladder"):
		(l as Node3D).visible = false
	# Sabah hücumundan kalanlar: kalkanlar devrilmiş
	for mn in get_tree().get_nodes_in_group("mantlet"):
		(mn as Node3D).rotation.x = deg_to_rad(-82)
		(mn as Node3D).position.y = -0.9
		# Yolun kenarına savrulmuş: yol boyunca dizilen yeniçeriler devrik kalkanın içinde durmasın
		(mn as Node3D).position.x = signf((mn as Node3D).position.x) * 10.5
	var st := _entry_stage()
	var hr: Horse = st["horse"]
	hr.position = Vector3(0, 2.3, 15.0)
	hr.speed = 1.6
	hud.visible = false
	var ec := Camera3D.new()
	add_child(ec)
	ec.global_position = Vector3(6.2, 1.7, 3.2)
	ec.look_at(Vector3(0, 3.6, 15.0), Vector3.UP)
	ec.fov = 60.0
	ec.make_current()
	await get_tree().create_timer(0.6).timeout
	await _shot("c26_05_entry.png")
	ec.global_position = Vector3(-4.0, 3.2, 21.0)
	ec.look_at(Vector3(0, 3.4, 15.0), Vector3.UP)
	await get_tree().create_timer(0.2).timeout
	await _shot("c26_06_entry_side.png")
	hud.visible = true
	phase = "aya"
	walls.queue_free()
	walls = null
	for a in attackers:
		a.queue_free()
	attackers.clear()
	await get_tree().process_frame
	city = ByzCity.new()
	city.part = "aya"
	add_child(city)
	_aya_stage()
	player.camera.make_current()     # giriş çekimlerinin kamerası hâlâ etkin kalıyordu
	await get_tree().create_timer(1.0).timeout
	await _shot("c26_03a_door.png")
	fatih.position = AYA + Vector3(0.2, 0, 4.6)
	fatih.face_toward(axeman.global_position)
	(axeman as Soldier).face_toward(fatih.global_position)
	player.face((fatih.global_position + axeman.global_position) * 0.5 + Vector3(0, 1.5, 0))
	hud.bark("SPK_FATIH", "D26_F_STOP", 30.0)
	await get_tree().create_timer(0.9).timeout
	await _shot("c26_03_aya.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = AYA + Vector3(-3.0, 1.7, 10.0)
	cv.look_at(AYA + Vector3(0.5, 4.0, 0.0), Vector3.UP)
	cv.fov = 62.0
	cv.make_current()
	await _shot("c26_cover.png")
	get_tree().quit()


## Dalga rakipleri: tür ("azap", "janissary", "genoese", "defender"), doğuş noktaları sırayla dağıtılır.
func _foe_specs(n: int, kind: String, spots: Array) -> Array:
	var out := []
	for i in n:
		var look: Dictionary
		var blade := "kilij"
		var shield := false
		var name := "SPK_AZAP"
		match kind:
			"janissary":
				look = {"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": i % 2 == 1}
				name = "SPK_JANISSARY"
				shield = i % 3 == 0
			"genoese":
				look = {"coat": Color("8a8e96"), "pants": Color("3a2a22"), "hat": "helm", "mustache": true, "beard": i % 2 == 0}
				blade = "spathion"
				shield = true
				name = "SPK_GENOESE"
			"defender":
				look = {"coat": [Color("7a2a24"), Color("5a6a7a"), Color("6a5a3a")][i % 3], "pants": Color("3a2a22"), "hat": "helm",
					"mustache": true, "beard": i % 2 == 1}
				blade = "spathion"
				shield = i % 2 == 0
				name = "SPK_DEFENDER"
			_:
				look = {"coat": [Color("8a6a4a"), Color("b3262d"), Color("6a4a3a")][i % 3], "pants": Color("e8e0d0"), "hat": "turban",
					"mustache": true, "beard": i % 2 == 0}
		out.append({"pos": spots[i % spots.size()], "blade": blade, "shield": shield, "name": name, "look": look})
	return out


## Merdivenden çıkıp gelenlerin doğduğu yer: oyuncunun gedik/sur tarafında, 4 m ötede iki yan (boş yer _free_spot'ta)
func _ladder_heads() -> Array:
	var p := player.global_position
	var to := LandWalls.BREACH - p
	to.y = 0.0
	to = to.normalized() if to.length() > 0.1 else Vector3(0, 0, 1)
	var side := to.cross(Vector3.UP).normalized()
	return [p + to * 4.5 + side * 1.6, p + to * 4.5 - side * 1.6]
