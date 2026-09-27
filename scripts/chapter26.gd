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
##   26.1 Son kare çekildi · 26.2 Son kare çekilmedi ("bazı şeyler tanıkla kaydedilir")
##   --autotest[=nophoto]   (varsayılan: 26.1)

const WELL := LandWalls.DEPOT + Vector3(-4.2, 0.0, 1.6)
const POSTERN := Vector3(LandWalls.DEPOT.x + 3.5, 0.0, LandWalls.INNER_Z1 + 0.6)
const BLOCKS := [Vector3(12.6, 0.0, 3.2), Vector3(14.6, 0.0, 2.2)]
const BANNER_TOWER := Vector3(16.0, LandWalls.OUTER_H + 3.0, LandWalls.OUTER_Z1 + 1.0)
const AYA := Vector3(-14.0, 0.0, -82.0)

var walls: LandWalls
var city: ByzCity
var bureau: Bureau
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
	add_child(giust)
	giust.look_target = player
	for i in 6:
		var d := Person.new({"coat": [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96")][i % 3], "pants": Color("3a2a22"), "hat": "helm",
			"beard": i % 2 == 0, "mustache": true})
		d.set_meta("no_talk", true)
		d.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-3.2 + i * 1.3, 0, -1.6 - (i % 2) * 0.8))
		d.rotation.y = 0.0
		add_child(d)
		defenders.append(d)
	# Su fıçısı (kuyu): kova buradan doldurulur
	Props.cyl(self, 0.55, 1.1, WELL + Vector3(0, 0.55, 0), Color("6a4a2c"), Vector3.ZERO, 12)
	Props.cyl(self, 0.5, 0.04, WELL + Vector3(0, 1.1, 0), Color("4a78a8"), Vector3.ZERO, 12)
	for k in 3:
		Props.cyl(self, 0.16, 0.3, WELL + Vector3(0.8, 0.15, -0.3 + k * 0.35), Color("8a6440"), Vector3.ZERO, 8, 0.19)
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
	for i in 5:
		var l := Ladder.new(9.0, 16.0)
		l.position = Vector3(-14.0 + i * 6.5, 0, LandWalls.OUTER_Z1 + 2.6)
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
	await _wave1()
	await _wave2()
	await _wave3()
	await _aya()
	await _epilogue()
	await _end_chapter()


func _wave_start(n: int) -> void:
	Audio.sfx("crowd_camp", 0.0, 0.8 + n * 0.1)
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
	while is_inside_tree() and phase == wave:
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
		s.position = Vector3(randf_range(-16, 20), 0, randf_range(40, 70))
		s.rotation.y = PI
		add_child(s)
		attackers.append(s)


func _wave1() -> void:
	phase = "wave1"
	_wave_start(1)
	await hud.say("SPK_GIUST", "D26_G_WAVE1")
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		for i in 3:
			_on_interact("well")
			_on_interact("breach")
			await get_tree().process_frame
	while water < 3:
		await get_tree().process_frame
	player.frozen = true
	_drop()
	await _repelled("D26_G_REPELLED_1")


func _wave2() -> void:
	phase = "wave2"
	_wave_start(2)
	# Urban'ın topu barikatı yıkar
	walls.fire_flash()
	Audio.sfx("cannon", 0.0, 0.8)
	await get_tree().create_timer(1.1).timeout
	walls.impact(LandWalls.BREACH + Vector3(0, 2.0, 0.6))
	Audio.sfx("explosion_big", -2.0)
	player.shake(0.8)
	walls.set_repair(LandWalls.STAGES - 4)
	await hud.say("SPK_GIUST", "D26_G_WAVE2")
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
	player.frozen = true
	_drop()
	await _repelled("D26_G_REPELLED_2")


func _repelled(key: String) -> void:
	hud.set_objective("")
	for i in 3:
		Vfx.explosion(walls, Vector3(randf_range(-10, 12), 2.0, 26.0), 0.6)
		Audio.sfx("explosion_small", -6.0)
		await get_tree().create_timer(0.3).timeout
	for a in attackers:
		var tw := create_tween()
		tw.tween_property(a, "position:z", a.position.z + 40.0, 3.0)
	await hud.say("SPK_GIUST", key)


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
	# Yaralanma: yakın mesafeden atış (kaynaklarda göğüs zırhını delen kurşun)
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
	var fall := create_tween()
	fall.tween_method(func(k: float): _carry_pose(dir, 0.15, k), 0.0, 1.0, 0.55).set_ease(Tween.EASE_IN)
	await fall.finished
	Vfx.dust(self, giust.global_position, 0.6)
	await hud.say("SPK_DEFENDER", "D26_S_GIUST")
	await hud.say("SPK_GIUST", "D26_G_HURT")
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
		come.tween_property(bearers[i], "global_position", at, 1.0)
	await come.finished
	for i in 2:
		bearers[i].rotation.y = atan2(dir.x, dir.z) + (PI if i == 0 else 0.0)
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
	emperor.position = LandWalls.BREACH + Vector3(3.0, 0, -9.0)
	emperor.rotation.y = 0.0
	player.face(emperor.global_position + Vector3(0, 1.5, 0))
	await hud.say("SPK_EMPEROR", "D26_K_LAST")
	var walk := create_tween()
	# Yamacın dibine yürür, sonra molozun üstünden gediğe tırmanır
	walk.tween_property(emperor, "position", LandWalls.BREACH + Vector3(0.5, 0, -4.2), 2.8)
	walk.tween_property(emperor, "position", LandWalls.on_rubble(LandWalls.BREACH + Vector3(0.5, 0, -1.4)), 1.6)
	for i in 4:
		Vfx.dust(self, LandWalls.BREACH + Vector3(randf_range(-2, 2), 1.0, -1.0), 1.4)
	await walk.finished
	emperor.visible = false
	await hud.say("SPK_NIHAT", "D26_N_OUT")
	await hud.say("SPK_TOLGA", "D26_T_OUT")
	await hud.fade_to(1.0, 1.5, Color.WHITE)


## Yaralı Giustiniani'nin taşınma pozu. _carry_at: gövdenin ortası (yerde); dir: başın yönü (poterna).
## h: sırtın yerden yüksekliği; k: 0 ayakta → 1 sırt üstü yatmış. Gövde zeminin (moloz yamacı) eğimine yaslanır.
var _carry_at := Vector3.ZERO


func _carry_pose(dir: Vector3, h: float, k: float) -> void:
	var feet := _carry_at - dir * 0.9
	var head := _carry_at + dir * 0.9
	feet.y = LandWalls.rubble_y(feet.x, feet.z)
	head.y = LandWalls.rubble_y(head.x, head.z)
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
	return p


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
			Props.cyl(bp, 0.05, 5.0, Vector3(0, 2.5, 0), Color("4a3420"), Vector3.ZERO, 5)
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
	hud.set_objective("")
	var t := 0.0
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
	# Kafile yoluna devam eder, kapıdan çıkar
	var go := func() -> void:
		var tt := 0.0
		while tt < 60.0 and is_instance_valid(isidore):
			var dt := get_process_delta_time()
			tt += dt
			for p in column:
				if is_instance_valid(p):
					p.position.z += 0.9 * dt
					if p.position.z > -7.0:
						p.visible = false
			await get_tree().process_frame
	go.call()


## Atı noktalar boyunca yürütür (adım hızında); maiyet izini takip eder. Oyuncu atın önüne çıkarsa bekler.
var _trail: Array[Vector3] = []
var _ride_done := false
var _ride_id := 0
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
					np.y = tp.y
					if r.position.distance_to(np) > 0.01:
						r.rotation.y = atan2(np.x - r.position.x, np.z - r.position.z)
					r.position = np
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
	add_child(city)
	city.niko.visible = false
	city.emperor.visible = false
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.position = AYA + Vector3(0, 0, 14.6)       # İmparator Kapısı'nın hemen içinde: eşikte eğilir
	fatih.rotation.y = PI
	add_child(fatih)
	axeman = Soldier.new(Color("2f5fa8"), "stand", "bork")
	axeman.position = AYA + Vector3(2.2, 0, 4.0)
	add_child(axeman)
	Props.cyl(axeman, 0.03, 1.0, Vector3(0.35, 0.9, 0.2), Color("5a3e26"), Vector3(0, 0, 40), 5)
	for i in 6:
		var s := Soldier.new([Color("2f5fa8"), Color("b3262d"), Color("6a4a3a")][i % 3], "stand", "bork" if i % 2 == 0 else "turban")
		s.position = AYA + Vector3(-5.0 + (i % 3) * 5.0, 0, 9.0 + (i / 3) * 3.0)
		s.rotation.y = PI
		add_child(s)
	_refugees()
	player.global_position = AYA + Vector3(-4.5, 0.05, 6.0)
	player.face(AYA + Vector3(0, 6.0, -6.0))
	await hud.card([[tr("UI_CH26_AYA"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.5, Color.WHITE)
	await hud.say("SPK_TOLGA", "D26_T_AYA")
	await hud.say("SPK_NIHAT", "D26_N_ANGEL")
	# Kapıda: eğilir, bir avuç toprak alıp sarığının üstüne serper (kaynaklar: Tanrı önünde alçakgönüllülük)
	player.face(fatih.global_position + Vector3(0, 1.4, 0))
	var earth := _fatih_earth()
	await hud.say("SPK_NIHAT", "D26_N_EARTH")
	if earth.is_running():
		await earth.finished
	var tw := create_tween()
	tw.tween_property(fatih, "position", AYA + Vector3(0.5, 0, 5.0), 5.0)
	player.face(fatih.global_position + Vector3(0, 1.6, 0))
	await tw.finished
	fatih.face_toward(axeman.global_position)
	await hud.say("SPK_FATIH", "D26_F_STOP")
	await hud.say("SPK_SOLDIER", "D26_S_AXE")
	await hud.say("SPK_FATIH", "D26_F_TRUST")
	fatih.face_toward(AYA + Vector3(0, 20, -10))
	await get_tree().create_timer(1.0).timeout
	await hud.say("SPK_NIHAT", "D26_N_AYA")
	var pick := await hud.choose(["UI_C26_PHOTO", "UI_C26_POCKET"], 0.0, 1 if GameState.autotest_variant == "nophoto" else 0)
	if pick == 0:
		var target := Node3D.new()
		add_child(target)
		target.global_position = fatih.global_position + Vector3(0, 2.0, -2.0)
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
func _epilogue() -> void:
	phase = "epilogue"
	city.queue_free()
	city = null
	fatih = null
	await get_tree().process_frame
	bureau = Bureau.new()
	add_child(bureau)
	var nihat := Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
		"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	nihat.position = Bureau.NIHAT_OFFICE_POS   # ofisin içinde, masanın yanında (eskiden koridordaydı: duvarın arkası)
	bureau.add_child(nihat)
	nihat.look_target = player
	var pages := Siege.page_count()
	var total := Siege.LAST - Siege.FIRST + 1
	var board := Node3D.new()
	board.position = Vector3(-2.9, 1.65, 1.0)
	board.rotation.y = PI / 2.0
	bureau.add_child(board)
	Props.box(board, Vector3(1.7, 1.2, 0.06), Vector3.ZERO, Color("f4f4f0"))
	Props.label(board, tr("PROP17_WIKI_TITLE"), Vector3(-0.35, 0.44, 0.035), 28, Color("202122"), Vector3.ZERO)
	var left := total - pages
	for i in 5:
		var y := 0.22 - i * 0.18
		Props.box(board, Vector3(0.9, 0.045, 0.005), Vector3(-0.3, y, 0.035), Color("a2a9b1"))
		if i < ceili(left * 5.0 / total):
			Props.label(board, tr("PROP17_WIKI_CN"), Vector3(0.46, y, 0.036), 13, Color("cc2a2a"), Vector3.ZERO)
	player.global_position = Bureau.SPAWN_POS + Vector3(0, 0.05, 0)
	player.face(nihat.global_position + Vector3(0, 1.5, 0))
	await hud.card([[tr("UI_CH26_WED"), 26, Color("f2e6c9")]], 2.0)
	hud.clear_card()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D26_N_EPI_1")
	await hud.say("SPK_NIHAT", "D26_N_EPI_ALL" if left == 0 else "D26_N_EPI_SOME")
	Audio.sfx("stamp", -2.0)
	await hud.say("SPK_TOLGA", "D26_T_EPI")
	await hud.say("SPK_NIHAT", "D26_N_EPI_2")
	await hud.say("SPK_NIHAT", "D26_N_RETURN")
	await hud.say("SPK_TOLGA", "D26_T_RETURN")
	GameState.flags["siege_done"] = true
	GameState.flags["act4_done"] = true
	await hud.fade_to(1.0, 1.0)
	Audio.sfx("machine_jump", -4.0)
	await hud.card([[tr("UI_ACT4_END"), 34, Color("f2e6c9")], [tr("UI_ACT4_END_SUB") % [pages, total], 18, Color(1, 1, 1, 0.75)]], 3.5)
	hud.clear_card()


# ================================================================ taşıma (1. ve 2. dalga)

func _update_objective() -> void:
	match phase:
		"wave1":
			if carrying == "water":
				hud.set_objective(tr("UI_OBJ26_WATER_GIVE") % [water, 3], LandWalls.BREACH + Vector3(0, 1.6, -2.0))
			else:
				hud.set_objective(tr("UI_OBJ26_WATER") % [water, 3], WELL + Vector3(0, 1.2, 0))
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
		Props.cyl(_carry, 0.2, 0.36, Vector3.ZERO, Color("8a6440"), Vector3.ZERO, 8, 0.24)
		Props.cyl(_carry, 0.22, 0.02, Vector3(0, 0.16, 0), Color("4a78a8"), Vector3.ZERO, 8)
	else:
		Props.cyl(_carry, 0.3, 0.8, Vector3.ZERO, LandWalls.C_WOOD, Vector3(90, 0, 0), 10)
	Props.strip_outlines(_carry)
	player.speed_mult = 0.8
	Audio.sfx("splash" if kind == "water" else "land_pot", -12.0, 1.2)
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
		hud.bark("SPK_DEFENDER", "D26_S_WATER_%d" % water, 2.2)
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
				a.position.z -= delta * 2.2
	if phase == "wave2" and not player.frozen:
		_gun_t -= delta
		if not _warn and _gun_t <= 4.0:
			_warn = true
			hud.bark("SPK_LOOKOUT", "D20_L_WARN_1", 3.0)
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
		if carrying != "":
			_drop()
			_update_objective()
		hud.bark("SPK_TOLGA", "D20_T_KNOCK_%d" % mini(_knocks, 3), 3.0)


func _on_focus(id: String) -> void:
	match id:
		"well":
			hud.set_prompt(tr("UI_PROMPT26_WATER") if phase == "wave1" and carrying == "" else "")
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
			var tw := create_tween()
			tw.tween_property(b, "position", b.position + Vector3(0, 0, 2.2), 0.5)
			tw.parallel().tween_property(b, "rotation:x", deg_to_rad(90), 0.5)
			Audio.sfx("land_thud", -6.0, 0.8)
			_cleared += 1
			hud.set_objective(tr("UI_OBJ26_CLEAR") % [_cleared, BLOCKS.size()], POSTERN + Vector3(0, 1.2, 0))


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
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
			GameState.change_scene(Siege.return_path())
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW26_TITLE")
	c.nodes = [
		{"id": "waves", "key": "FLOW26_WAVES", "pos": Vector2(0.5, 0.12)},
		{"id": "giust", "key": "FLOW26_GIUST", "pos": Vector2(0.5, 0.28)},
		{"id": "aya", "key": "FLOW26_AYA", "pos": Vector2(0.5, 0.44)},
		{"id": "26.1", "key": "FLOW_26_1", "pos": Vector2(0.3, 0.62), "outcome": true},
		{"id": "26.2", "key": "FLOW_26_2", "pos": Vector2(0.7, 0.62), "outcome": true},
	]
	c.edges = [["waves", "giust"], ["giust", "aya"], ["aya", "26.1"], ["aya", "26.2"]]
	for k in ["waves", "giust", "aya", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH26_STATS") % [Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "26.1", "nophoto": "26.2"}.get(v, "26.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("26", {})
	var ok: bool = _outcome == expected and not page.is_empty() and water == 3 and repaired == 3 and _cleared == 2 and GameState.flags.get("siege_done", false)
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (su=%d onarım=%d fıçı=%d)" % [expected, _outcome, water, repaired, _cleared])
	print("AUTOTEST %s chapter=26 variant=%s outcome=%s water=%d repaired=%d cleared=%d" % ["PASS" if ok else "FAIL", v, _outcome,
		water, repaired, _cleared])
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
	add_child(city)
	city.niko.visible = false
	fatih = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	fatih.position = AYA + Vector3(0.5, 0, 5.0)
	add_child(fatih)
	player.global_position = AYA + Vector3(-4.5, 0.05, 6.0)
	await get_tree().create_timer(1.5).timeout
	player.face(fatih.global_position + Vector3(0, 1.8, 0))
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
