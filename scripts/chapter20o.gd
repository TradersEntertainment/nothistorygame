extends Node3D
## Bölüm 20 (Osmanlı tarafı) — Gedik (Tolga · 7 Mayıs 1453, gündüz, Urban'ın büyük topu).
##
## Aynı günün öbür yüzü: gündüz Urban'ın topu Mesoteichion'u döver, gece savunucular gediği kapatır.
## Tolga topun ekibindedir: doldur ve nişan al (GunDrill), sonra namluyu zeytinyağıyla soğut (E basılı tut).
## Soğutulmayan namlu çatlamaya başlar (Urban: "Tunç sabır ister"). Üç atış. Akşam: açılan gediğin karesi.
##   20O.1 Gedik açıldı (en az iki isabet) · 20O.2 Surlar dayandı, yarın yine
##   Gece yarısı hücumu: Urban'ın uzattığı tüfekle mazgaldakilere, sonra azaplarla gediğe (WaveRunner, surda tüfekçi).
## Sabırsızlığın bedeli: çatlayan namluya Urban yarım barut koyar, sonraki gülle kısa düşer (nişan yükseltilmeli).
## Topun çatlağı 6a'da ya da 10B'de Tolga'nın bandıyla sarıldıysa (cannon_taped) eski şerit ilk çatlağı tutar; değilse
## çantada bant varsa çatlak yeniden sarılabilir. Kalan çatlaklar 32o'da anılır: büyük top o gün susar.
## 10B'de ad konan topu Urban adıyla anar; döküm kötüyse (ch10b_quality < 2) top bir çatlakla başlar.
## Dallanma v3: Edirne'deki kısa deneme güllesi (34O.2) topu bir çatlakla başlatır; 28o'da kayan kızak (28O.2) yatağı eğri
## bırakır (nişan bandı dar), ilk seferde oturan kızak (28O.1) sağlam (bant geniş).
##   --autotest[=wide|lose|hot|hot_taped|hot_tape|named|flawed|edirne|edirne_ok]   (varsayılan: 20O.1; hot*: namlu hiç
##   soğutulmaz; edirne: 34O.2 + 28O.2, edirne_ok: 34O.1 + 28O.1)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const SHOTS := 3
const COOL_TIME := 2.4

var walls: LandWalls
var gun: Node3D
var player: Player
var hud: Hud
var urban: Person
var crew: Array[Soldier] = []
var drill: GunDrill
var gun_crew: CannonCrew
var cam: TespitCam
var phase := "intro"
var _outcome := ""
var hits := 0
var _acc := 0.0
var _cool := 0.0
var cracks := 0
var _tape_held := false       # namludaki eski şerit (6a/10B) bir çatlağı tuttu
var _taped_now := 0           # bu bölümde bantla sarılan çatlaklar
var _flawed := false           # 10B'nin kötü dökümü: top bir çatlakla başladı
var _edirne_crack := false     # 34O.2: Edirne'de deneme güllesi kısa düştü, tunç orada yoruldu (top bir çatlakla başlar)
var _bed := ""                 # 28o'da kızağın yatağı: "crooked" (28O.2, nişan bandı dar) / "sound" (28O.1, geniş)
var _photo := ""
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(20)
	var v := GameState.autotest_variant
	if GameState.autotest and v.begins_with("hot"):
		# hot: bantsız çanta, hot_taped: top 6a'da bantlandı (çantada bant yok), hot_tape: çantada bant
		GameState.flags["cannon_taped"] = v == "hot_taped"
		if v != "hot_tape":
			GameState.bag.erase("tape")
		elif not GameState.has_item("tape"):
			GameState.gain("tape", "test")
	if GameState.autotest and v.begins_with("edirne"):
		# Dallanma v3: topun geçmişi. edirne: 34O.2 + 28O.2 (kısa deneme, eğri yatak) · edirne_ok: 34O.1 + 28O.1
		var bad := v == "edirne"
		GameState.chapter_outcomes[34] = "34O.2" if bad else "34O.1"
		GameState.chapter_outcomes[28] = "28O.2" if bad else "28O.1"
	if GameState.autotest and v in ["named", "flawed"]:
		# 10B: topa ad kondu ('Pazartesi' / 'Koli'); flawed: döküm Sırp kalıplarıyla (kalite 1)
		GameState.flags["cannon_name"] = 0 if v == "named" else 1
		GameState.flags["ch10b_quality"] = 2 if v == "named" else 1
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	walls = LandWalls.new()
	add_child(walls)
	# Kuşatma sürerken şehir ve surlar arası Bizans'ın: oyuncu gedikten ya da açık bir kapıdan içeri girerse savunucular
	# yakalayıp dışarı atar (Trespass)
	Trespass.attach(self, player, hud)
	walls.make_day()
	walls.field.bombard = true          # bütün hat döver: sağda solda bataryalar ateş eder
	walls.set_repair(LandWalls.STAGES)
	gun = walls.build_great_gun()
	drill = GunDrill.new()
	hud.add_child(drill)
	drill.fired.connect(func(a: float): _acc = a)
	_setup_gun_crew()
	# 6a/10B'de sarılan şerit namlunun belinde, iki parçanın birleştiği yerde görünür
	if GameState.flags.get("cannon_taped", false):
		_tape_band(0.15)
	urban = Person.new({"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "kalpak", "face": "urban", "mustache": true, "beard": true,
		"hair": Color("8a5a2a"), "apron": Color("4a3020"), "skin": Color("e8b894")})
	# Urban topun kuyruğunun sağında: oyuncunun ilk bakışında namlu araya girmesin
	urban.position = gun.position + Vector3(4.8, 0, 4.4)
	add_child(urban)
	urban.look_target = player
	_build_tally()
	# Önceki hücumlardan kalanlar: hendekte ve sur dibinde yatan azaplar, düşmüş hasır kalkanlar
	for lane: Array in [[Vector3(-26.0, 0, 27.5), Vector3(26.0, 0, 27.5), 5.0], [Vector3(-24.0, 0, 17.9), Vector3(24.0, 0, 17.9), 0.6]]:
		var bx := BattleExtras.new()
		bx.side = "osm"
		add_child(bx)
		bx.hit_every = 0.0
		bx.populate(lane[0], lane[1], lane[2], 0, 5, 0, 2020 + int(lane[0].z))
	for i in 4:
		var s := Soldier.new([Color("b3262d"), Color("6a4a3a"), Color("2f5fa8"), Color("8a6a4a")][i], "stand", "bork" if i % 2 == 0 else "turban")
		s.position = gun.position + Vector3([-4.2, -2.0, 6.6, 8.2][i], 0, [3.2, 4.0, 2.4, 3.4][i])
		add_child(s)
		crew.append(s)
	# Topun çevresi boş kalmasın: iki yanda (setle topçu ordugâhı arasında) sancaklı bölükler, halat çitin ardında
	# topu seyreden askerler, karşıda surlarda Bizans nöbetçileri (uzak)
	for spec in [[Vector3(-40.0, 0, 123.0), Color("b3262d"), Color("2e6a3a")], [Vector3(-22.0, 0, 124.0), Color("2f5fa8"), Color("b3262d")],
			[Vector3(40.0, 0, 123.0), Color("6a4a3a"), Color("f0ece0")], [Vector3(58.0, 0, 124.0), Color("3a6b3a"), Color("b3262d")]]:
		walls.field.formation(spec[0], spec[1], 8, 5, spec[2])
	for i in 7:
		var o := Soldier.new([Color("8a6a4a"), Color("b3262d"), Color("6a4a3a"), Color("3a6b3a")][i % 4], "stand", ["bork", "turban"][i % 2])
		o.position = gun.position + Vector3(-7.5 + i * 2.6 + (i % 2) * 0.4, 0, 13.0 + (i % 3) * 0.5)
		o.rotation.y = PI + (i - 3) * 0.08
		add_child(o)
		if i % 3 == 1:
			o.equip("spear")
	Garrison.land_walls(self, [], [], [], 2010)
	# Karşıda gedikte Bizanslılar gündüz de onarır: kazık çakanlar, toprak ve kalas taşıyanlar (top vurdukça)
	var fight := WallFight.new()
	add_child(fight)
	fight.add_builders(LandWalls.BREACH + Vector3(0, 0, -1.4), 4, 2070)
	fight.add_carriers(LandWalls.DEPOT + Vector3(-2.6, 0, 2.6), LandWalls.BREACH + Vector3(0, 0, -2.6), 4, 2080)
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH20O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH20O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = gun.position + Vector3(1.8, 0.05, 9.2)
	player.face(urban.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D20O_N_01")
	await hud.say("SPK_URBAN", "D20O_U_01")
	await hud.say("SPK_TOLGA", "D20O_T_01")
	await hud.say("SPK_URBAN", "D20O_U_02")
	# Büyük top günde en çok yedi kez atabilirdi (her atıştan sonra soğuma, yeniden doldurma saatler sürerdi)
	urban.emote("nod")
	await hud.say("SPK_URBAN", "D20O_U_SEVEN")
	await _named_gun()
	await _gun_history()
	for shot in SHOTS:
		phase = "drill"
		player.global_position = gun.position + Vector3(3.0, 0.05, 6.0)
		player.face(LandWalls.BREACH + Vector3(0, 4.0, 0))
		hud.set_objective(tr("UI_OBJ20O_LOAD") % [shot + 1, SHOTS])
		var wide := GameState.autotest_variant == "wide"
		# Çatlak namluya tam barut konmaz: gülle kısa düşer
		drill.start(0.25 + shot * 0.1, 0.16, 1.0 - 0.1 * cracks)
		while drill.active:
			await get_tree().process_frame
		if GameState.autotest and wide:
			_acc = 0.2
		hud.set_objective("")
		await _fire()
		if shot < SHOTS - 1:
			await _cool_step()
	await _evening()
	# Gece yarısı hücumu (7 Mayıs gecesi azaplar gediğe yüklendi): Bölüm 20'nin Osmanlı aynası
	await _assault()
	await _end_chapter()


## Urban'ın topu: elle doldurma ve nişan (CannonCrew). Barut fıçıları ve gülle yığını topun yanında.
func _setup_gun_crew() -> void:
	gun_crew = CannonCrew.new()
	add_child(gun_crew)
	gun_crew.player = player
	gun_crew.hud = hud
	gun_crew.pivot = gun.get_node("Pivot")
	gun_crew.muzzle = gun.get_node("Pivot/Muzzle")
	gun_crew.recoil_node = gun
	gun_crew.aim_spot = gun.to_global(Vector3(0, 0, 8.5))
	gun_crew.aim_back = 13.5
	gun_crew.aim_side = 2.6          # namlunun yanında: dev namlu sura bakışı kapatmasın
	gun_crew.supplies = {"powder": gun.to_global(Vector3(-2.7, 0, 2.2)), "ball": gun.to_global(Vector3(3.8, 0, -0.5)),
		"wad": gun.to_global(Vector3(-2.8, 0, 5.6)), "rammer": gun.to_global(Vector3(2.8, 0, 5.6))}
	gun_crew.spawn = ["wad"]
	gun_crew.target = func() -> Vector3: return LandWalls.BREACH + Vector3(0, 4.0, 0)
	gun_crew.hit_radius = 5.0
	gun_crew.tolerance = 16.0
	gun_crew.ground_y = 0.0
	gun_crew.load_radius = 3.2
	gun_crew.design_elev = 5.0
	gun_crew.pitch_min = -2.0
	gun_crew.pitch_max = 14.0
	gun_crew.yaw_limit = 6.0
	# Nişana geçerken siperlik halatlarla kalkar: oyuncu hedefini (gediği) görür
	gun_crew.on_aim = func(): walls.gun_screen(true, 0.7 if not GameState.autotest else 0.02)
	gun_crew.before_fire = func():
		# Siperlik halatlarla kalkar, sonra ateş
		await get_tree().create_timer(walls.gun_screen(true, 0.7 if not GameState.autotest else 0.02)).timeout
		walls.fire_flash()
	gun_crew.after_fire = func():
		pass     # siperlik fire_flash'ten sonra kendiliğinden iner
	gun_crew.ball_cam = true       # ateşte kamera gülleyi sura kadar izler
	gun_crew.setup()
	drill.bind(gun_crew)


func _fire() -> void:
	if not drill.physical:
		walls.fire_flash()
		Audio.sfx("cannon", 2.0, 0.75)
		Vfx.explosion(self, gun.position + Vector3(0, 1.6, -5.0), 1.6)
		player.shake(1.0)
		var tw := create_tween()
		tw.tween_property(gun, "position:z", gun.position.z + 0.8, 0.12)
		tw.tween_property(gun, "position:z", gun.position.z, 1.2)
		await get_tree().create_timer(1.6).timeout
	var hit := _acc >= 0.5
	var at := LandWalls.BREACH + Vector3(randf_range(-1.5, 1.5) if hit else randf_range(-14, 14), 3.0 if hit else 1.0, 1.2 if hit else 6.0)
	if drill.physical and drill.last_impact != Vector3.INF:
		at = drill.last_impact
	walls.impact(at)
	Audio.sfx("explosion_big", -8.0)
	_tally_mark(hit)
	if hit:
		hits += 1
		walls.set_repair(maxi(0, LandWalls.STAGES - hits * 4))
		# Ekip ve Urban sevinir; seyreden askerler bağırır
		for c in crew:
			if is_instance_valid(c):
				c.emote("cheer")
		urban.emote("cheer")
		Audio.sfx("crowd_camp", -4.0, 1.15)
		await hud.say("SPK_URBAN", "D20O_U_HIT_%d" % mini(hits, 3))
	else:
		await hud.say("SPK_URBAN", "D20O_U_MISS")


## Atış tahtası: kara tahta bir direğe çakılı, üstünde "BUGÜN · 7 ATIŞ"; her atışta bir çizik (isabet kırmızı).
var _tally: Node3D
var _tally_n := 0


func _build_tally() -> void:
	_tally = Node3D.new()
	add_child(_tally)
	_tally.global_position = gun.position + Vector3(6.2, 0, 3.0)
	_tally.rotation.y = deg_to_rad(-35)
	Props.cyl(_tally, 0.07, 2.2, Vector3(0, 1.1, 0), Color("5a4028"), Vector3.ZERO, 6)
	Props.box(_tally, Vector3(1.3, 0.8, 0.06), Vector3(0, 1.85, 0.08), Color("2a2e2a"))
	Props.label(_tally, "BUGÜN · 7 ATIŞ", Vector3(0, 2.13, 0.12), 26, Color("f2eee0"), Vector3.ZERO, 1.15)


func _tally_mark(hit: bool) -> void:
	if _tally == null:
		return
	Props.box(_tally, Vector3(0.04, 0.34, 0.01), Vector3(-0.5 + _tally_n * 0.14, 1.8, 0.115), Color("d83a2a") if hit else Color("f2eee0"), Vector3(0, 0, 8))
	_tally_n += 1


## Namlunun çevresinde gri bir şerit (koli bandı): pivotun yerel z'sinde (namlu -z'ye bakar).
func _tape_band(z: float) -> void:
	var pv := gun.find_child("Pivot", true, false) as Node3D
	if pv:
		Props.cyl(pv, 1.075, 0.22, Vector3(0, 0, z), Color("9a9a94"), Vector3(90, 0, 0), 16)


## Bölüm 10B'de Tolga'nın ad koyduğu top (cannon_name): Urban onu adıyla anar. 10B.3'te (Büyük Patlama) o top patlamıştı;
## bu onun ağabeyidir. Döküm "Sırp kalıplarıyla" yapıldıysa (ch10b_quality < 2) tuncun karnında bir kabarcık vardır: top
## güne bir çatlakla başlar (barutu azalır; 32o'da iki çatlakla susar).
func _named_gun() -> void:
	if not GameState.flags.has("cannon_name"):
		return
	if GameState.flags.get("big_bang", false):
		await hud.say("SPK_URBAN", "D20O_U_NAME_GONE")
		return
	await hud.say("SPK_URBAN", "D20O_U_NAME_%d" % (clampi(int(GameState.flags["cannon_name"]), 0, 3) + 1))
	if int(GameState.flags.get("ch10b_quality", 2)) < 2:
		_flawed = true
		cracks = 1
		urban.emote("facepalm")
		await hud.say("SPK_URBAN", "D20O_U_FLAW")


## Dallanma v3 (docs/BRANCHING_V3.md §2.1): topun geçmişi burada hatırlanır. Ocak'ta Edirne'deki deneme güllesi kısa
## düştüyse (34O.2) tunç orada yorulmuştu: top güne bir çatlakla başlar (10B'nin kötü dökümü gibi; ikisi birden bir çatlak).
## 11 Nisan'da kızak kaydıysa (28O.2) topun yatağı eğri oturdu: nişan bandı dar; ilk seferde oturduysa (28O.1) geniş.
func _gun_history() -> void:
	match Siege.outcome(34):
		"34O.2":
			if cracks == 0:
				cracks = 1
				_edirne_crack = true
				urban.emote("facepalm")
				await hud.say("SPK_URBAN", "D20O_U_EDIRNE_SHORT")
		"34O.1":
			await hud.say("SPK_URBAN", "D20O_U_EDIRNE_OK")
	match Siege.outcome(28):
		"28O.2":
			_bed = "crooked"
			gun_crew.tolerance = 11.0
			await hud.say("SPK_URBAN", "D20O_U_BED_CROOKED")
		"28O.1":
			_bed = "sound"
			gun_crew.tolerance = 21.0
			await hud.say("SPK_URBAN", "D20O_U_BED_SOUND")


## Namluyu zeytinyağıyla soğut: E basılı tutulur (Urban'ın topu sıcakken yeniden atılamazdı).
func _cool_step() -> void:
	phase = "cool"
	_cool = 0.0
	player.frozen = false
	hud.set_objective(tr("UI_OBJ20O_COOL"), gun.global_position + Vector3(0, 2.4, 0))
	Lore.scatter(self, "20o")
	await hud.say("SPK_URBAN", "D20O_U_COOL")
	var t := 0.0
	var limit := 10.0
	while _cool < COOL_TIME and t < limit:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var near := player.global_position.distance_to(gun.global_position + Vector3(0, 0, -1.0)) < 5.0
		hud.set_prompt(tr("UI_PROMPT20O_COOL") if near else "")
		if (near and Input.is_action_pressed("interact")) or (GameState.autotest and not GameState.autotest_variant.begins_with("hot")):
			_cool += dt
			if fmod(_cool, 0.4) < dt:
				Vfx.steam(self, gun.global_position + Vector3(randf_range(-0.6, 0.6), 2.6, randf_range(-3.0, 1.0)))
		hud.set_chase(tr("UI_CH20O_COOL"), _cool / COOL_TIME)
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_objective("")
	player.frozen = true
	if _cool < COOL_TIME:
		Audio.sfx("kick_metal", -4.0, 0.6)
		player.face(urban.global_position + Vector3(0, 1.5, 0))      # tuncu dinleyen ustaya dönük
		if GameState.flags.get("cannon_taped", false) and not _tape_held:
			# 6a/10B'de sarılan şerit hâlâ namlunun belinde: kıl payı çatlağı o tutar
			_tape_held = true
			urban.emote("surprise")
			await hud.say("SPK_URBAN", "D20O_U_TAPED")
			return
		var use_tape := false
		if GameState.has_item("tape"):
			var c := await hud.choose(["UI_C20O_TAPE", "UI_C20O_NOTAPE"], 0.0, 0)
			use_tape = c == 0
		if use_tape:
			GameState.spend("tape", "cannon_20o")
			_taped_now += 1
			_tape_band(-2.6 + _taped_now * 0.9)
			player.show_prop("tape", 2.2)
			await hud.say("SPK_TOLGA", "D20O_T_TAPE")
			await hud.say("SPK_URBAN", "D20O_U_TAPE_NEW" if _taped_now == 1 else "D20O_U_TAPE_AGAIN")
			return
		cracks += 1
		await hud.say("SPK_URBAN", "D20O_U_CRACK")
		await hud.say("SPK_URBAN", "D20O_U_LESS")
	else:
		await hud.say("SPK_URBAN", "D20O_U_COOLED")


func _evening() -> void:
	phase = "evening"
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH20O_EVENING"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	walls.make_dawn(0.01)
	await hud.fade_to(0.0, 0.8)
	var target := Node3D.new()
	walls.add_child(target)
	target.position = LandWalls.BREACH + Vector3(0, 3.0, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ20O_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege20o")
	hud.add_child(cam)
	cam.max_dist = 140.0
	cam.cone_deg = 8.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	var opened := hits >= 2
	await hud.say("SPK_URBAN", "D20O_U_END_OPEN" if opened else "D20O_U_END_HOLD")
	await hud.say("SPK_TOLGA", "D20O_T_END")
	await hud.say("SPK_NIHAT", "D20O_N_END")
	_outcome = "20O.1" if opened else "20O.2"
	# 32o'da Topçubaşı Ali büyük topu anar: iki çatlaksa o gün susar, şeritliyse şeridiyle konuşur
	GameState.flags["gun_cracks"] = cracks
	GameState.flags["gun_tape_20o"] = _tape_held or _taped_now > 0
	Siege.record(20, _photo, "SIEGE_NOTE_20O_%s" % _outcome.split(".")[1])


var gun_shots := 0
var gun_hits := 0
var gunner_shots := 0
var gunner_dodged := 0
var _duel_won := true


## Gece yarısı: Urban bir tüfek uzatır (kendi dökümü değil). Önce hendeğin ötesinden surdaki savunuculara
## (mazgalda görünüp saklanırlar), sonra azaplarla gediğin molozuna: Cenevizliler ve savunucular, surda bir
## tüfekçi. Ölüm yok; kaybedilirse Tolga geri çekilir (sonuç topun açtığı gediğe bağlıdır, hücuma değil).
func _assault() -> void:
	phase = "assault"
	await hud.fade_to(1.0, 0.6)
	await hud.card([[tr("UI_CH20O_NIGHT"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	var y := LandWalls.OUTER_H
	# Yakın ova (hendeğin dış kıyısı) bu bölümde boş: hücumun toplandığı yere çiğnenmiş toprak
	if get_node_or_null("AssaultGround") == null:
		var g := Props.solid(self, Vector3(44.0, 0.4, 18.0), Vector3(0, -0.2, 45.2), Color("6a5a40"))
		g.name = "AssaultGround"
		Props.set_pattern(g, Color("6a5a40"), "dirt")
	player.global_position = Vector3(2.0, 0.05, 41.0)
	player.face(Vector3(0, y + 1.2, 15.3))
	urban.global_position = Vector3(4.2, 0, 42.5)
	urban.look_target = player
	await hud.fade_to(0.0, 0.6)
	Audio.intensity(2, "walls_night")
	await hud.say("SPK_URBAN", "D20O_U_GUN")
	var peek: Array = []
	var xs := [-10.0, -7.5, 7.5, 10.0]
	for i in 4:
		peek.append({"coat": [Color("7a2a24"), Color("8a8e96"), Color("5a6a7a"), Color("6a5a3a")][i], "hat": "helm",
			"pos": Vector3(LandWalls.walk_x(xs[i]), y, 15.25), "face": Vector3(xs[i], y, 40.0), "phase": i * 0.9})
	var res: Dictionary = await GunRange.run(self, hud, player, {"peek": peek, "limit": 28.0,
		"crowd_box": AABB(Vector3(0.0 - 32.0, LandWalls.OUTER_H - 1.5, LandWalls.INNER_Z0 - 3.0), Vector3(64.0, 11.5, 25.0)),
		"objective": tr("UI_OBJ20O_GUN") % 4, "look": Vector3(0, y + 1.2, 15.3)})
	gun_shots = res["shots"]
	gun_hits = res["hits"]
	await hud.say("SPK_TOLGA", "D20_T_GUN_GOOD" if gun_hits >= 2 else "D26O_T_GUN_BAD")
	# Gedik: moloz dilinin üstünde, azaplarla birlikte
	await hud.fade_to(1.0, 0.4)
	var at := LandWalls.BREACH + Vector3(0, 0, 4.6)
	at.y = LandWalls.outside_y(at.x, at.z)
	player.global_position = at + Vector3(0, 0.05, 0)
	player.face(LandWalls.BREACH + Vector3(0, 2.0, 0))
	await hud.fade_to(0.0, 0.4)
	await hud.say("SPK_URBAN", "D20O_U_CHARGE")
	var crest := LandWalls.on_rubble(LandWalls.BREACH + Vector3(0, 0, 1.2))
	var spots := [crest + Vector3(-1.2, 0, 0), crest + Vector3(1.2, 0, 0)]
	var specs := []
	for k in 2:
		specs.append({"pos": spots[k], "blade": "spathion", "shield": true, "name": "SPK_GENOESE",
			"look": {"coat": Color("8a8e96"), "pants": Color("3a2a22"), "hat": "helm", "mustache": true, "beard": k == 0}})
	var more := []
	var extra := 1 if gun_hits < 2 else 0          # mazgaldakiler susturulmadıysa gedik daha kalabalık
	for k in 3 + extra:
		more.append({"pos": spots[k % 2], "blade": "spathion", "shield": k % 2 == 0, "name": "SPK_DEFENDER",
			"look": {"coat": [Color("7a2a24"), Color("5a6a7a"), Color("6a5a3a")][k % 3], "pants": Color("3a2a22"), "hat": "helm",
			"mustache": true, "beard": k % 2 == 1}})
	player.frozen = false
	var gn := Gunner.spawn(self, Vector3(8.4, y, 15.4), player, hud, 6.0, Color("7a2a24"), "helm")
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": specs, "max_active": 2, "skill": 0.4, "limit": 60.0},
		{"specs": more, "max_active": 2, "skill": 0.45, "allies": 2, "limit": 60.0,
		"intro": func():
			# Dövüşün ortasında haykırış (Tolga kılıç sallarken Urban'a dönmez)
			hud.bark("SPK_URBAN", "D20O_U_MORE", 3.5)
			await get_tree().create_timer(1.5).timeout}], "kilij")
	await gn.settle_test()
	gunner_shots = gn.shots
	gunner_dodged = gn.dodged
	gn.stop()
	_duel_won = r["won"]
	if _duel_won:
		GameState.bump_stat("osm_breach", 1, true)
	player.frozen = true
	await hud.say("SPK_TOLGA", "D20O_T_DUEL" if _duel_won else "D20O_T_LOST")
	await hud.say("SPK_NIHAT", "D20O_N_NIGHT")


func _process(delta: float) -> void:
	_t += delta
	# Doldururken surdaki Bizans topçuları karşılık verir: küçük taş gülleler bataryanın çevresine düşer (oyuncuya
	# değmez; toprak fışkırır, ekip sinip başını kaldırır). Gerilim: top susmadan önce bir atış daha.
	if phase == "drill" and gun_crew and gun_crew.state in ["powder", "wad", "ball", "ram", "aim"]:
		_incoming_t -= delta
		if _incoming_t <= 0.0:
			_incoming_t = randf_range(2.8, 5.0)
			_incoming()


var _incoming_t := 1.5


## Karşı ateş: sur yönünden ıslıkla gelen küçük gülle, topun 7-15 m ötesine düşer (yan, ön ya da arka).
func _incoming() -> void:
	var a := randf_range(-PI, PI)
	var at := gun.position + Vector3(cos(a), 0, sin(a)) * randf_range(7.0, 15.0)
	at.y = 0.0
	if Vector2(at.x - player.global_position.x, at.z - player.global_position.z).length() < 5.0:
		at += (at - player.global_position).normalized() * 5.0
		at.y = 0.0
	Audio.sfx("whoosh_fly", -10.0, 1.6)
	await get_tree().create_timer(0.45).timeout
	if not is_inside_tree():
		return
	Vfx.dust(self, at + Vector3(0, 0.3, 0), 1.4)
	Vfx.explosion(self, at, 0.35)
	Audio.sfx("explosion_small", -6.0, randf_range(0.85, 1.1))
	Fx.trauma(clampf(0.5 - at.distance_to(player.global_position) / 40.0, 0.08, 0.35))
	for c in crew:
		if is_instance_valid(c) and c.global_position.distance_to(at) < 9.0:
			c.emote("surprise")


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
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW20O_TITLE")
	c.nodes = [
		{"id": "load", "key": "FLOW20O_LOAD", "pos": Vector2(0.5, 0.14)},
		{"id": "20O.1", "key": "FLOW_20O_1", "pos": Vector2(0.3, 0.38), "outcome": true},
		{"id": "20O.2", "key": "FLOW_20O_2", "pos": Vector2(0.7, 0.38), "outcome": true},
	]
	c.edges = [["load", "20O.1"], ["load", "20O.2"]]
	c.taken["load"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		Grade.finish("20o"),
		tr("UI_CH20O_STATS") % [hits, SHOTS, cracks, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "20O.1", "wide": "20O.2", "lose": "20O.1"}.get(v, "20O.1")
	# Soğutulmayan namlu: iki çatlak; 6a'nın şeridi birini tutar; çantadaki bant ikisini de sarar
	var want_cracks: int = {"hot": 2, "hot_taped": 1, "hot_tape": 0, "flawed": 1, "edirne": 1}.get(v, 0)
	var crack_ok: bool = cracks == want_cracks and _tape_held == (v == "hot_taped") and (_taped_now == 2) == (v == "hot_tape") \
		and _flawed == (v == "flawed") and _edirne_crack == (v == "edirne")
	# Kızağın yatağı (28o): eğri → bant dar, sağlam → geniş
	var want_tol: float = {"edirne": 11.0, "edirne_ok": 21.0}.get(v, 16.0)
	crack_ok = crack_ok and is_equal_approx(gun_crew.tolerance, want_tol) \
		and _bed == ({"edirne": "crooked", "edirne_ok": "sound"}.get(v, "") as String)
	if v == "hot_tape":
		crack_ok = crack_ok and GameState.last_use("tape") == "cannon_20o"
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("20", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done
	# Gece hücumu: tüfekle en az üç atış ve bir isabet, tüfekçi en az bir kez ateş etmiş; yenilgi testinde düşmüş olmalı
	ok = ok and gun_shots >= 3 and gun_hits >= 1 and gunner_shots >= 1 and crack_ok
	if v.ends_with("lose"):
		ok = ok and player.downs >= 1 and not _duel_won
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=20o variant=%s outcome=%s hits=%d cracks=%d gun=%d/%d gunner=%d/%d duel=%s bed=%s" % ["PASS" if ok else "FAIL",
		v, _outcome, hits, cracks, gun_hits, gun_shots, gunner_dodged, gunner_shots, _duel_won, _bed])
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
	player.global_position = gun.position + Vector3(3.0, 0.05, 6.0)
	await get_tree().create_timer(0.8).timeout
	player.face(LandWalls.BREACH + Vector3(0, 4.0, 0))
	drill.start(0.0, 0.16)
	drill.step = 4
	await _shot_png("c20o_01_aim.png")
	drill.stop()
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = gun.position + Vector3(9.0, 3.0, 7.0)
	cv.look_at(gun.position + Vector3(-1.0, 1.8, -8.0), Vector3.UP)
	cv.fov = 58.0
	cv.make_current()
	await get_tree().create_timer(0.25).timeout
	await _shot_png("c20o_cover.png")
	# Siperlik: kapak halatlarla kalkar, top ateşlenir (yandan)
	cv.global_position = gun.position + Vector3(15.0, 6.5, 3.0)
	cv.look_at(gun.position + Vector3(0.0, 3.0, -5.5), Vector3.UP)
	await _shot_png("c20o_02_closed.png")
	await get_tree().create_timer(walls.gun_screen(true, 0.4) + 0.1).timeout
	await _shot_png("c20o_03_open.png")
	get_tree().quit()
