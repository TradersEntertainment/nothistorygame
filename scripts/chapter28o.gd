extends Node3D
## Bölüm 28 (yalnız Osmanlı tarafı) — İlk Atış (Tolga · 6 ve 11–12 Nisan 1453, kara surlarının önü, Urban'ın bataryası).
##
## Ordu 6 Nisan'da surların önüne gelir; siper kazılır, önüne kazık çakılır. Urban'ın büyük topu (Şahi) Edirne'den
## öküzler ve yüzlerce adamla çekilmiştir; bataryasına yerleştirilir ve kara surları 11–12 Nisan'da dövülmeye başlar.
## Sur o gün henüz sağlamdır (LandWalls.intact).
##   1. 6 Nisan: kazık yığınından dört kazık, siperin ardındaki deliklere (surdan arada bir gülle düşer)
##   2. 11 Nisan: Şahi kızağın üstünde, makara kütükleri üzerinde mevziye arkadan çekilir. Davul vurunca Space: iki
##      sıra halatçı "hey—yap!" diye asılır, kızak bir adım ilerler. Kütükler kızaktan geri kalır; en arkadaki kızağın
##      altından çıkınca kızağın burnu boşta kalır (öne eğilir): kütüğü arkadan al (E), kızağın önüne koy (E).
##      Kütük konmadan çekilirse kızak burnunu toprağa gömüp geri kayar.
##   3. İlk atış: topu doldur ve nişan al (GunDrill + CannonCrew, 20o ile aynı), gülle sağlam sura iner. Tespit: ilk toz.
##   28O.1 Top ilk seferde yerine oturdu · 28O.2 Kızak kaydı, yeniden kuruldu
## Dallanma v3: Edirne yolu (35O.2: kütük sık, 35O.1: seyrek) ve Edirne'deki deneme atışı (34O.2: nişanı Urban alır,
## 34O.1: nişan bandı geniş) burada hatırlanır.
##   --autotest[=lose|edirne|edirne_ok]   (varsayılan: 28O.1; =lose: kütük beklemeden bir kez çekilir;
##   edirne: 34O.2 + 35O.2, edirne_ok: 34O.1 + 35O.1)

const STAKES := 4
const HAUL_FROM := -3.0       # kızağın x'i (bataryanın arkasındaki yol boyunca, +x'e çekilir)
const HAUL_TO := 9.0           # LandWalls.CANNON.x
## Kızak yolu mevzinin arka kenarında: barut fıçılarının (z ≤ 121,8) ve yan sepet duvarlarının (SiegeField.GUN_GATE_Z)
## gerisinden geçer. Eskiden z 122'deydi: kızak fıçıların, çeken bölük sepetlerin içinden geçiyordu.
const HAUL_Z := 124.5
const ROLLER_EVERY := 4.0
const STEP := 1.0              # iyi bir "hey-yap" başına kızağın yolu (m); tam vaktinde 1,3
const ROLLER_SLOTS := [-3.0, 0.0, 3.0]    # kızağın altındaki kütüklerin yerleri (kızağa göre x)

var walls: LandWalls
var player: Player
var hud: Hud
var meter: RowMeter
var drill: GunDrill
var gun_crew: CannonCrew
var cam: TespitCam
var gun: Node3D
var urban: Person
var horse: Horse
var sultan: Person
var sled: Node3D
var _rollers: Array[Node3D] = []      # kızağın altındakiler (arkadan öne)
var _free_roller: Node3D               # arkadan çıkmış, yerde bekleyen kütük
var _teams: Array[Soldier] = []
var _nose := 0.0                       # kızağın burnunun eğikliği (önde kütük yokken)
var phase := "intro"
var _outcome := ""
var stakes := 0
var carrying := ""
var _carry: Node3D
var _holes: Array[Node3D] = []
var haul_x := HAUL_FROM
var _next_roller := ROLLER_EVERY
## Dallanma v3: Edirne yolunun (35o) izi. Köprü kırıldıysa ya da araba kaydıysa (35O.2) kızağın kayağı çatlak: kütük
## sık gerekir; yol temiz geçtiyse (35O.1) öküzcüler Tolga'yı tanır, kütük seyrek.
var _roller_every := ROLLER_EVERY
var _master := false          # 34O.2: Urban nişanı Tolga'ya bırakmadı
var need_roller := false
var roller_held := false
var rollers_set := 0          # kızağın önüne konan kütük (35O.2: 4, 35O.1: 2, yoksa 3)
var slips := 0
var _acc := 0.0
var hit := false
var _photo := ""
var _focus := ""
var _ball_t := 4.0
var _t := 0.0
# yayma P4: halatçılar zeminin çocuğu (kızağın değil), kişi başına gecikmeyle kızağın ardından adım atar
var _haulers: Array[Dictionary] = []   # {"s": Soldier, "ox": kızağa göre x, "oz": z, "fx": izlediği kızak x'i, "wait": -1}
var _ropes: Array[MeshInstance3D] = []  # iki çekme halatı (dünya), uçları kızak halkasında ve sonda yerde kangal
var _coils: Array[MeshInstance3D] = []
var _on_rope := false                  # oyuncunun iki eli halatın ucunda
var _ox_teams: Array[Dictionary] = []  # yakın, canlı öküz takımları (koşumlu, kızak çekerek yürür)
var _herd: Array[Node3D] = []          # uzak, durağan öküz sıraları (çoklu ağ)
var _gyf := func(x: float, z: float) -> float: return SiegeField.ground(x, z)


func _ready() -> void:
	GameState.snapshot(28)
	if GameState.autotest and GameState.autotest_variant.begins_with("edirne"):
		var bad := GameState.autotest_variant == "edirne"
		GameState.chapter_outcomes[34] = "34O.2" if bad else "34O.1"
		GameState.chapter_outcomes[35] = "35O.2" if bad else "35O.1"
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	preload("res://scripts/level/huzur.gd").watch(self, hud, player)      # hükümdara el kaldırmak (SENARYO_KURAL_CIGNEME §6)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	meter = RowMeter.new()
	hud.add_child(meter)
	walls = LandWalls.new()
	walls.intact = true
	walls.gun_gate = true                                   # mevzinin yan sepet duvarları arkada açık: kızak oradan girer
	walls.field_keep = [Rect2(-18.0, 120.0, 48.0, 9.0)]     # kızak yolu ve çeken bölük: ova eşyası konmaz
	add_child(walls)
	# Kuşatma sürerken şehir ve surlar arası Bizans'ın: oyuncu gedikten ya da açık bir kapıdan içeri girerse savunucular
	# yakalayıp dışarı atar (Trespass)
	Trespass.attach(self, player, hud)
	walls.make_day()
	walls.set_repair(0)
	gun = walls.far_gun
	# Şahi henüz yolda: mevzi (döşeme, siperlik, sepetler, barut) hazır, namlu ve kızağı yok. Eskiden bütün model gizlenip
	# katı parçaları açık kalıyordu: kazık çakarken boş mevzide görünmez duvarlara çarpılıyordu.
	walls.gun_present(false)
	drill = GunDrill.new()
	hud.add_child(drill)
	drill.fired.connect(func(a: float): _acc = a)
	urban = Person.new({"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "kalpak", "face": "urban", "mustache": true, "beard": true,
		"hair": Color("8a5a2a"), "apron": Color("4a3020"), "skin": Color("e8b894")})
	urban.set_meta("spk", "SPK_URBAN")
	add_child(urban)
	urban.look_target = player
	# Bataryanın arkasındaki yol (kızağın çekildiği yer) yürünür: arazinin çarpışması yalnız topun çevresinde var
	var pad := Props.solid(self, Vector3(40.0, 0.4, 26.0), Vector3(3.0, -0.2, 121.0), Color.WHITE)
	pad.get_child(0).visible = false
	_build_stakes()
	_build_sled()
	_haul_show(false)        # Şahi 6 Nisan'da daha yolda: kızak ve çeken bölük 11 Nisan'da görünür (açılışta duruyordu)
	_build_oxen()
	_build_ground()
	horse = Horse.new(Color("e4e0d8"))
	add_child(horse)
	sultan = Person.new({"coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "face": "fatih", "mustache": true,
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")})
	sultan.set_meta("spk", "SPK_FATIH")
	horse.mount(sultan)
	horse.visible = false
	for spec in [[Vector3(-40.0, 0, 123.0), Color("b3262d"), Color("2e6a3a")], [Vector3(40.0, 0, 123.0), Color("6a4a3a"), Color("f0ece0")]]:
		walls.field.formation(spec[0], spec[1], 8, 4, spec[2])
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


static func gy(x: float, z: float) -> float:
	return SiegeField.ground(x, z)


# ================================================================ sahne

## Kazık yığını ve siperin ardında dört delik (kazık çit, setin hemen gerisinde)
func _build_stakes() -> void:
	var pile := Vector3(18.0, 0, 120.5)
	pile.y = gy(pile.x, pile.z)
	for i in 7:
		Props.cyl(self, 0.09, 2.2, pile + Vector3(-0.6 + (i % 4) * 0.4, 0.15 + (i / 4) * 0.2, 0), Color("8a6a44"), Vector3(90, 0, 90), 6)
	Props.interactable(self, "stakes", Vector3(2.0, 1.2, 1.4), pile + Vector3(0, 0.5, 0))
	for i in STAKES:
		var h := Node3D.new()
		add_child(h)
		var x := 2.5 + i * 4.2
		h.global_position = Vector3(x, gy(x, 114.6), 114.6)
		Props.cyl(h, 0.22, 0.04, Vector3(0, 0.02, 0), Color("3a2a1a"), Vector3.ZERO, 8)
		Props.interactable(h, "hole_%d" % i, Vector3(1.2, 1.2, 1.2), Vector3(0, 0.5, 0))
		_holes.append(h)


## Kızak: kalın kirişler, üstünde iki parçalı tunç namlu; altında üç makara kütüğü. +X yönüne çekilir.
func _build_sled() -> void:
	sled = Node3D.new()
	add_child(sled)
	var wood := Color("6a4a2c")
	Props.box(sled, Vector3(9.0, 0.45, 2.4), Vector3(0, 0.75, 0), wood)
	for x: float in [-3.6, 0.0, 3.6]:
		Props.box(sled, Vector3(0.4, 0.3, 2.8), Vector3(x, 1.0, 0), wood.darkened(0.25))
	var bronze := Color("8c5e26")
	Props.cyl(sled, 0.62, 4.6, Vector3(-1.9, 1.75, 0), bronze, Vector3(0, 0, 90), 14)
	Props.cyl(sled, 0.52, 3.8, Vector3(2.3, 1.68, 0), bronze.lightened(0.05), Vector3(0, 0, 90), 14, 0.48)
	Props.cyl(sled, 0.7, 0.3, Vector3(0.38, 1.75, 0), bronze.darkened(0.2), Vector3(0, 0, 90), 14)
	Props.ring(sled, 0.32, 0.52, Vector3(4.22, 1.68, 0), bronze.darkened(0.3), Vector3(0, 0, 90))
	for x: float in ROLLER_SLOTS:
		_rollers.append(_roller(sled, Vector3(x, 0.26, 0)))
	# Çeken bölükler: kızağın ön köşelerinden iki halat; adamlar iki halatın arasında, yüzleri kızağa dönük, kendi
	# yanlarındaki halatı iki elle tutar (Soldier "haul": eller halatın üstünde; halat dışta, iki yandan da görünür).
	# Eskiden kollar sabit açıdaydı, halat ellerin altından geçiyordu.
	var rope_col := Color("b89a6a")
	for side: float in [-1.0, 1.0]:
		var a := Vector3(4.45, 0.82, side * 1.05)
		var b := Vector3(17.8, 1.0, side * 1.75)
		Props.cyl(sled, 0.06, 0.5, a + Vector3(0.05, -0.05, 0), rope_col.darkened(0.2), Vector3(0, 0, 90), 6)   # kızağa bağlandığı halka
		# Halat (yayma P4): kızak halkasından halatçıların ellerinden geçer, sonda yere iner, ucu kangal. Eskiden kızağın
		# çocuğu iki düz krem çubuktu (Props.cyl), sarkmasız ve uçsuz.
		_ropes.append(Stage.rope(self, Vector3.ZERO, Vector3(0, 0.1, 0), 0.0, 0.036, rope_col))
		_coils.append(Stage.rope_coil(self, Vector3.ZERO, 0.34, 3.5, 0.036, rope_col))
		for k in 6:
			var s := Soldier.new([Color("b3262d"), Color("6a4a3a"), Color("e8e0d0"), Color("2f5fa8")][(k + int(side + 1.0)) % 4], "haul",
				["bork", "turban", "azap"][k % 3])
			s.set_meta("no_talk", true)
			s.set_meta("climber", true)
			var x := 6.6 + k * 1.8
			var on := a.lerp(b, (x - a.x) / (b.x - a.x))
			# Zeminin çocuğu: kızakla kaymaz, kendi adımıyla izler (halatın iç yanında, kızağa (−X) bakar)
			add_child(s)
			s.rotation.y = -PI * 0.5 + side * 0.25
			s.set("_t", randf() * 20.0)                              # her biri kendi soluğunda (aynı fazda sallanıyorlardı)
			_haulers.append({"s": s, "ox": x + 0.25 + randf_range(-0.15, 0.15), "oz": on.z - side * (0.32 + randf_range(-0.06, 0.08)),
				"fx": HAUL_FROM, "wait": -1.0, "side": side})
			_teams.append(s)
	Props.interactable(sled, "roller_front", Vector3(1.4, 1.2, 3.0), Vector3(5.3, 0.6, 0))
	# Kızağın kalası ve namlusu tek ağ (çizim sayısı; makara kütükleri ayrı döner)
	var still: Array = []
	for c in sled.get_children():
		if c is MeshInstance3D:
			still.append(c)
	Props.bake_static(sled, still)
	_place_sled()


## Makara kütüğü: ekseni kızağın enine (z); kabuğunda koyu bir şerit ve uçlarında demir bilezik (yuvarlandığı görünsün:
## düz silindir dönerken kıpırdamıyor gibiydi)
func _roller(parent: Node3D, pos: Vector3) -> Node3D:
	var r := Node3D.new()
	parent.add_child(r)
	r.position = pos
	Props.cyl(r, 0.26, 3.0, Vector3.ZERO, Color("8a6a44"), Vector3(90, 0, 0), 10)
	Props.box(r, Vector3(0.07, 0.05, 2.9), Vector3(0, 0.25, 0), Color("4a3622"))
	Props.box(r, Vector3(0.07, 0.05, 2.9), Vector3(0, -0.25, 0), Color("4a3622"))
	for z: float in [-1.42, 1.42]:
		Props.cyl(r, 0.275, 0.08, Vector3(0, 0, z), Color("3a3634"), Vector3(90, 0, 0), 10)
	if r.is_inside_tree():
		Props.bake_static(r, r.get_children())
	return r


func _set_nose(v: float) -> void:
	_nose = v
	_place_sled()


func _place_sled() -> void:
	sled.global_position = Vector3(haul_x, gy(haul_x, HAUL_Z), HAUL_Z)
	# Önde kütük yokken burun öne eğilir (ön ucu toprağa değer)
	sled.rotation.z = -_nose
	# Kütükler kızağın altında yuvarlanır
	for r in _rollers:
		if is_instance_valid(r) and r.get_parent() == sled:
			r.rotation = Vector3(0, 0, -haul_x / 0.26)
	_lay_ropes()


## Halatların yeri: kızak halkasından halatçıların elleri hizasında (Soldier.rope bu çizgi: eller ona uzanır) sona;
## oyuncu ucu tutuyorsa sonu oyuncunun iki elinde, oradan yere; tutmuyorsa son halatçının ardında yere iner, ucu kangal.
func _lay_ropes() -> void:
	if _ropes.size() < 2:
		return
	for i in 2:
		var side := -1.0 if i == 0 else 1.0
		var a := sled.to_global(Vector3(4.45, 0.82, side * 1.05))
		var b := sled.to_global(Vector3(17.8, 0.92, side * 1.75))
		var coil := sled.to_global(Vector3(19.4, 0, side * 2.4))
		coil.y = gy(coil.x, coil.z)
		_coils[i].global_position = coil
		var pts: Array
		if side > 0.0 and _on_rope:
			var hl := Vector3(0.0, -0.15, -0.64)
			var hr := Vector3(0.15, -0.2, -0.5)
			player.hold_both(hl, hr)
			var l := player.camera.to_global(hl)
			pts = Stage.sag_points(a, l, 0.02, 10)
			pts.append(player.camera.to_global(hr))
			var d1 := player.global_position + (player.global_position - a).normalized() * 0.5
			d1.y = gy(d1.x, d1.z) + 0.04
			pts.append_array([player.camera.to_global(hr + Vector3(0.05, -0.35, 0.15)), d1, coil + Vector3(0, 0.1, 0)])
			b = l
		else:
			pts = Stage.sag_points(a, b, 0.03, 10)
			var g := sled.to_global(Vector3(18.6, 0, side * 2.0))
			g.y = gy(g.x, g.z) + 0.04
			pts.append_array([g, coil + Vector3(0, 0.1, 0)])
		Stage.rope_to(_ropes[i], pts)
		for d: Dictionary in _haulers:
			if float(d["side"]) == side:
				(d["s"] as Soldier).rope = [a, b]


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH28O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH28O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	Audio.ambience("amb_wall_day")
	urban.global_position = Vector3(14.0, gy(14.0, 121.0), 121.0)
	player.global_position = Vector3(16.0, gy(16.0, 123.0) + 0.05, 123.0)
	player.face(urban.global_position + Vector3(0, 1.5, 0))
	player.show_remote(true)             # Tolga'nın eli açık (kazık ve kütük elsiz havada duruyordu)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	# Açılış sözleri oyuncu serbestken söylenir (kazık işi ekranda)
	hud.say_chain([["SPK_NIHAT", "D28O_N_01"], ["SPK_URBAN", "D28O_U_01"], ["SPK_TOLGA", "D28O_T_01"]])
	if GameState.autotest:
		while hud.chain_busy():      # test botu ışınlanır: konuşan görüşten çıkmasın
			await get_tree().process_frame
	await _stakes_phase()
	await _haul_phase()
	await _first_shot()
	await _end_chapter()


## 1. Kazıklar (6 Nisan). Arada surdan bir gülle düşer.
func _stakes_phase() -> void:
	phase = "stakes"
	player.frozen = false
	_update_objective()
	while stakes < STAKES:
		await get_tree().process_frame
		if GameState.autotest and not _hammering:      # bot tokmak inerken yeni kazık almaz
			if carrying == "":
				_on_interact("stakes")
			else:
				_on_interact("hole_%d" % stakes)
	# Son tokmak bitmeden kapanış başlamasın: tokmak 0,8 sn sonra oyuncuyu yeniden serbest bırakıyordu (replikler
	# sürerken hedefsiz serbest oyuncu)
	while _hammering:
		await get_tree().process_frame
	player.frozen = true
	_drop()
	hud.set_objective("")
	hud.set_prompt("")
	await hud.say("SPK_URBAN", "D28O_U_STAKES")
	await hud.say("SPK_TOLGA", "D28O_T_STAKES")


## 2. Şahi'yi çekmek (11 Nisan)
func _haul_phase() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH28O_HAUL"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	phase = "haul"
	_haul_show(true)
	# Oyuncu bölüğün yanında, biraz açıkta: kızağı, halatları ve çeken iki sırayı birlikte görür. Eldeki eşya cebe
	# (yayma P4: çekerken elinde koli bandı vardı); halatın ucuna (son halatçının ardı) yürürse iki eliyle tutar.
	# (Halat ucunda başlatmak denendi: görüş halatçı sırasıyla kapanıyor, çizim yükü %35 artıyordu.)
	var ps := Vector3(haul_x + 7.5, 0, HAUL_Z + 7.0)
	player.global_position = Vector3(ps.x, gy(ps.x, ps.z) + 0.05, ps.z)
	player.face(Vector3(haul_x + 5.5, 1.0, HAUL_Z))
	player.stow_hands(true)
	player.show_remote(false)            # 2. tur: eller görünmez (koli bandı gitmişti ama el boş havada açık duruyordu)
	_lay_ropes()
	# "Altmış öküz bunu Edirne'den getirdi": bakış replik boyunca öküzlere (kızak yolunun gerisinde, takımlar çekerek
	# gelir, ötede çiftler dinlenir); Urban o yanda konuşur. Replikten sonra bakış kızağa döner.
	urban.global_position = Vector3(haul_x + 1.0, gy(haul_x + 1.0, HAUL_Z + 6.0), HAUL_Z + 6.0)
	player.face(Vector3(-6.0, 0.5, HAUL_Z + 15.0))
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_URBAN", "D28O_U_HAUL")
	player.face(Vector3(haul_x + 5.5, 1.0, HAUL_Z))
	match Siege.outcome(35):
		"35O.2":
			_roller_every = 3.0
			urban.emote("facepalm")
			await hud.say("SPK_URBAN", "D28O_U_ROAD_BAD")
		"35O.1":
			_roller_every = 6.0
			await hud.say("SPK_URBAN", "D28O_U_ROAD_OK")
	_next_roller = _roller_every
	player.frozen = false
	meter.sound = ""
	meter.show_noise = false
	meter.stroke.connect(_on_stroke)
	meter.beat.connect(_on_beat)
	meter.enabled = true
	_update_objective()
	var bot := 0.0
	var lose := GameState.autotest and GameState.autotest_variant == "lose"
	while haul_x < HAUL_TO - 0.01:
		await get_tree().process_frame
		if get_tree().paused:      # duraklatmada sayaç akmaz
			continue
		var dt := get_process_delta_time()
		if GameState.autotest:
			# Bot: kütük gerekince ibreyi durdurur (çekmez), kütüğü arkadan alıp öne koyar. "lose": ilk seferde beklemeden çeker
			meter.enabled = not (need_roller and not (lose and slips == 0))
			bot -= dt
			if bot <= 0.0 and need_roller and not meter.enabled:
				bot = 0.5
				if not roller_held and _free_roller:
					player.global_position = _free_roller.global_position + Vector3(0, 0.05, 1.2)
					_on_interact("roller_back")
				elif roller_held:
					player.global_position = sled.to_global(Vector3(5.6, 0.05, 2.2))
					_on_interact("roller_front")
		elif Input.is_action_just_pressed("jump") and not player.frozen:
			meter.press()
		# Urban halatçı sırasının yanında yürür, davula göre bağırır
		urban.global_position = urban.global_position.lerp(_urban_spot(), minf(1.0, dt * 3.0))
		_rope_tick(dt)
	meter.enabled = false
	meter.stroke.disconnect(_on_stroke)
	meter.beat.disconnect(_on_beat)
	player.frozen = true
	_drop()
	_on_rope = false
	player.release_both()
	player.stow_hands(false)
	player.show_remote(true)
	_lay_ropes()
	hud.set_objective("")
	hud.set_prompt("")
	await hud.say("SPK_URBAN", "D28O_U_PLACED" if slips == 0 else "D28O_U_PLACED_SLIP")


## Davul: ibre yeşile girerken vurur (Space'e basma anı). Kütük beklenirken susar.
func _on_beat() -> void:
	if phase == "haul" and not need_roller:
		Audio.sfx("drum_boom", -9.0, randf_range(0.95, 1.05))


## İbreye basış (RowMeter.stroke): iyi vakitte bölük asılır; erken/geç basışta bölük ritmi kaçırır
func _on_stroke(good: bool) -> void:
	if phase != "haul":
		return
	if not good:
		meter.say(tr("UI_HAUL_EARLY") if meter.phase < RowMeter.WIN_A else tr("UI_HAUL_LATE"), Color("ff9a6a"))
		_stagger_heave(0.25)
		Audio.sfx("wood_creak", -16.0, 0.7)
		return
	var mid := (RowMeter.WIN_A + RowMeter.WIN_B) * 0.5
	var perfect := absf(meter.phase - mid) < (RowMeter.WIN_B - RowMeter.WIN_A) * 0.2
	_heave(true, perfect)


## Bir "hey-yap": bölük asılır, kızak ilerler (tam vaktinde daha çok). Kütük öne konmadan çekilirse kızak burnunu
## toprağa gömer, geri kayar.
func _heave(good: bool, perfect := false) -> void:
	if not good:
		return
	_stagger_heave(1.0)
	if _on_rope:
		player.shake(0.06)
	Audio.sfx("heave_shout", -4.0, randf_range(0.96, 1.04))
	if need_roller:
		slips += 1
		var back := maxf(HAUL_FROM, haul_x - 1.0)
		var tw0 := create_tween()
		tw0.tween_method(_set_haul, haul_x, back, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		Fx.trauma(0.45)
		Audio.sfx("land_thud", -2.0, 0.7)
		Audio.sfx("wood_creak", -6.0, 0.55)
		Vfx.dust(self, sled.to_global(Vector3(4.6, 0.1, 0)), 1.4)
		meter.say(tr("UI_HAUL_SLIP"), Color("ff5a4a"), 1.6)
		hud.bark("SPK_URBAN", "D28O_U_SLIP", 3.0)
		return
	var step := STEP * (1.3 if perfect else 1.0)
	var to := minf(haul_x + step, HAUL_TO)
	meter.say((tr("UI_HAUL_PERFECT") if perfect else tr("UI_HAUL_GOOD")) % (to - haul_x), Color("9fe08a") if perfect else Color("fff3d6"))
	Audio.sfx("ship_haul", -8.0, randf_range(0.9, 1.1))
	Fx.trauma(0.12)
	var tw := create_tween()
	tw.tween_method(_set_haul, haul_x, to, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Kızağın kayakları toz kaldırır
	for z: float in [-1.1, 1.1]:
		Vfx.dust(self, sled.to_global(Vector3(-4.2, 0.1, z)), 0.5)
	if to >= HAUL_FROM + _next_roller and to < HAUL_TO - 0.5:
		_next_roller += _roller_every
		need_roller = true
		tw.tween_callback(_roller_out)
	_update_objective()


func _set_haul(x: float) -> void:
	haul_x = x
	_place_sled()


## Kütükler kızaktan geri kalır: en arkadaki kızağın altından yuvarlanıp çıkar, öbür ikisi bir yer geri kayar; önde
## kütük kalmayınca kızağın burnu öne eğilir. Çıkan kütük yerde bekler (al: E).
func _roller_out() -> void:
	if _rollers.is_empty():
		return
	var r: Node3D = _rollers.pop_front()
	var tw := create_tween().set_parallel()
	tw.tween_property(r, "position:x", -5.4, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(r, "rotation:z", r.rotation.z + 9.0, 0.7)
	for i in _rollers.size():
		tw.tween_property(_rollers[i], "position:x", ROLLER_SLOTS[i], 0.7)
	tw.tween_method(_set_nose, _nose, 0.035, 0.7)
	tw.chain().tween_callback(func():
		# Yere düşen kütük: kızaktan ayrılır, dünyada kalır (kızak ilerlese de yerinde)
		var xf := r.global_transform
		sled.remove_child(r)
		add_child(r)
		r.global_transform = xf
		r.position.y = gy(r.position.x, r.position.z) + 0.26
		Props.interactable(r, "roller_back", Vector3(1.0, 1.0, 3.2), Vector3.ZERO)     # kütüğün ekseni yerel z
		_free_roller = r
		Audio.sfx("land_thud", -10.0, 1.3)
		hud.bark("SPK_URBAN", "D28O_U_ROLLER", 3.0)
		_update_objective())


## Kütük kızağın önüne konur: önden altına yuvarlanır, burun kalkar
func _roller_in(r: Node3D) -> void:
	r.visible = true
	if r.get_parent():
		r.get_parent().remove_child(r)
	sled.add_child(r)
	for c in r.get_children():
		if c is StaticBody3D:
			c.queue_free()                    # yerde alınma alanı: artık kızağın altında
	r.position = Vector3(5.8, 0.26, 0)
	r.rotation = Vector3.ZERO
	_rollers.append(r)
	var tw := create_tween().set_parallel()
	tw.tween_property(r, "position:x", ROLLER_SLOTS[_rollers.size() - 1], 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(r, "rotation:z", 7.0, 0.6)
	tw.tween_method(_set_nose, _nose, 0.0, 0.6)


## 3. İlk atış (12 Nisan): topu doldur, nişan al. Gülle sağlam sura iner; ilk toz bulutu tespit edilir.
func _first_shot() -> void:
	await hud.fade_to(1.0, 0.8)
	phase = "shot"
	_haul_show(false)
	if _free_roller:
		_free_roller.visible = false
	walls.gun_present(true)
	gun = walls.build_great_gun()
	# Mevzinin arkası açık (kızak oradan girdi): yanlarda ip çit; build_great_gun'ın görünmez sınırı artık görünür
	for sx: float in [-3.3, 21.3]:
		for i in 5:
			Props.cyl(self, 0.07, 1.2, Vector3(sx, 0.6, 121.4 + i * 2.05), Color("5a4630"), Vector3.ZERO, 6)
		for y: float in [0.55, 1.0]:
			Props.box(self, Vector3(0.035, 0.035, 8.3), Vector3(sx, y, 125.5), Color("8a7050"))
	_setup_gun_crew()
	urban.global_position = gun.position + Vector3(4.8, 0, 4.4)
	horse.visible = true
	horse.global_position = gun.position + Vector3(-6.0, 0, 9.0)
	horse.rotation.y = PI
	player.global_position = gun.position + Vector3(3.0, 0.05, 6.0)
	player.face(LandWalls.BREACH + Vector3(0, 4.0, 0))
	await hud.card([[tr("UI_CH28O_SHOT"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_FATIH", "D28O_F_01")
	await hud.say("SPK_URBAN", "D28O_U_SHOT")
	# Dallanma v3: Edirne'deki deneme atışının (34o) izi. Gülle kısa düştüyse Urban nişanı bırakmaz (Tolga yalnız doldurur);
	# direğin dibine indiyse nişan Tolga'nın, bant geniş.
	match Siege.outcome(34):
		"34O.2":
			_master = true
			gun_crew.master_aims = true
			urban.emote("shrug")
			await hud.say("SPK_URBAN", "D28O_U_EDIRNE_SHORT")
		"34O.1":
			gun_crew.tolerance = 24.0
			await hud.say("SPK_URBAN", "D28O_U_EDIRNE_OK")
	hud.set_objective(tr("UI_OBJ28O_LOAD_MASTER") if _master else tr("UI_OBJ28O_LOAD"))
	drill.start(0.25, 0.16)
	while drill.active:
		await get_tree().process_frame
	hud.set_objective("")
	if not drill.physical:
		walls.fire_flash()
		Audio.sfx("cannon", 2.0, 0.75)
		Vfx.explosion(self, gun.position + Vector3(0, 1.6, -5.0), 1.6)
		player.shake(1.0)
		await get_tree().create_timer(1.6, false).timeout
	hit = _acc >= 0.5
	var at := LandWalls.BREACH + Vector3(randf_range(-1.5, 1.5), 3.5, 1.2) if hit else LandWalls.BREACH + Vector3(randf_range(-10.0, 10.0), 0.8, 7.0)
	if drill.physical and drill.last_impact != Vector3.INF:
		at = drill.last_impact
	walls.impact(at)
	Audio.sfx("explosion_big", -8.0)
	if hit:
		_scar(at)
	await hud.say("SPK_URBAN", "D28O_U_HIT" if hit else "D28O_U_MISS")
	# Tespit: surdaki ilk toz bulutu (vurmadıysa da kaydedilir: ilk atış)
	var target := Node3D.new()
	add_child(target)
	target.global_position = at + Vector3(0, 1.5, 0)
	Vfx.dust(self, at, 2.2)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ28O_PHOTO" if hit else "UI_OBJ28O_PHOTO_MISS"), target.global_position)    # ıska: toz surda değil
	cam = TespitCam.new(player, hud, target, "siege28o")
	hud.add_child(cam)
	cam.max_dist = 140.0
	cam.cone_deg = 10.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 30.0):
		await get_tree().process_frame
		if not get_tree().paused:
			t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_FATIH", "D28O_F_02")
	# "Günde yedi atış"ı topun öbür ucundan değil yanında anlatır (6.5 m; sahneleme raporu SAYDIST)
	await Stage.walk_player(player, urban.global_position, 2.0, urban.global_position + Vector3(0, 1.5, 0), 3.0)
	await hud.say("SPK_URBAN", "D28O_U_SEVEN")
	await hud.say("SPK_TOLGA", "D28O_T_END")
	await hud.say("SPK_NIHAT", "D28O_N_END")
	if hit:
		GameState.bump_stat("first_shot", 1, true)
	_outcome = "28O.1" if slips == 0 else "28O.2"
	Siege.record(28, _photo, "SIEGE_NOTE_28O_%s%s" % [_outcome.split(".")[1], "" if hit else "M"])      # ıska: gülle hendekte


## Sağlam surda ilk gülle yarası: koyu oyuk, çatlaklar
func _scar(at: Vector3) -> void:
	var p := Vector3(at.x, clampf(at.y, 1.5, LandWalls.OUTER_H - 1.0), LandWalls.OUTER_Z1 + 0.02)
	Props.box(self, Vector3(1.8, 1.5, 0.03), p, Color("5e584e"), Vector3(0, 0, randf_range(-20, 20)))
	Props.box(self, Vector3(1.0, 0.9, 0.04), p + Vector3(0, 0, 0.01), Color("2e2a25"), Vector3(0, 0, 45))
	for k in 5:
		var a := randf_range(-PI, PI)
		Props.box(self, Vector3(0.06, randf_range(1.0, 2.2), 0.03), p + Vector3(cos(a) * 1.2, sin(a) * 1.2, 0.015), Color("2e2a25"), Vector3(0, 0, rad_to_deg(a) + 90.0))


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
	# Nişana geçerken siperlik halatlarla kalkar: oyuncu hedefini (suru) görür. Eskiden yalnız ateşten hemen önce
	# kalkıyordu; nişan alırken önü kapalıydı.
	gun_crew.on_aim = func(): walls.gun_screen(true, 0.7 if not GameState.autotest else 0.02)
	gun_crew.before_fire = func():
		await get_tree().create_timer(walls.gun_screen(true, 0.7 if not GameState.autotest else 0.02), false).timeout
		walls.fire_flash()
	gun_crew.after_fire = func():
		pass     # siperlik fire_flash'ten sonra kendiliğinden iner
	gun_crew.ball_cam = true       # ilk gülle: kamera gülleyi sura kadar izler
	gun_crew.setup()
	drill.bind(gun_crew)


# ================================================================ etkileşim

func _update_objective() -> void:
	match phase:
		"stakes":
			var look: Variant = null
			if carrying == "" :
				look = Vector3(18.0, gy(18.0, 120.5) + 1.0, 120.5)
			elif stakes < STAKES:
				# Henüz çakılmamış en yakın çukur (sıra numarasına göre gösteriliyordu: yakından başlayan oyuncuda işaret
				# bitmiş çukurda kalıyordu)
				var bd := INF
				for h: Node3D in _holes:
					if not h.has_meta("done"):
						var d := player.global_position.distance_to(h.global_position)
						if d < bd:
							bd = d
							look = h.global_position + Vector3(0, 1.0, 0)
			hud.set_objective(tr("UI_OBJ28O_STAKES") % [stakes, STAKES], look)
		"haul":
			if need_roller and roller_held:
				hud.set_objective(tr("UI_OBJ28O_ROLLER_PUT"), sled.to_global(Vector3(5.3, 0.8, 0)))
			elif need_roller:
				var at: Variant = _free_roller.global_position + Vector3(0, 0.6, 0) if _free_roller else sled.to_global(Vector3(-5.4, 0.8, 0))
				hud.set_objective(tr("UI_OBJ28O_ROLLER"), at)
			else:
				hud.set_objective(tr("UI_OBJ28O_HAUL") % maxi(0, ceili(HAUL_TO - haul_x)), sled.global_position + Vector3(0, 2.0, 0))


func _on_focus(id: String) -> void:
	_focus = id
	var k := ""
	match phase:
		"stakes":
			if id == "stakes" and carrying == "":
				k = "UI_PROMPT28O_TAKE"
			elif id.begins_with("hole_") and carrying == "stake" and not _holes[int(id.trim_prefix("hole_"))].has_meta("done"):
				k = "UI_PROMPT28O_PLANT"
		"haul":
			if id == "roller_back" and need_roller and not roller_held and _free_roller:
				k = "UI_PROMPT28O_ROLLER_TAKE"
			elif id == "roller_front" and roller_held:
				k = "UI_PROMPT28O_ROLLER_PUT"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	match phase:
		"stakes":
			if id == "stakes" and carrying == "":
				_pick("stake")
			elif id.begins_with("hole_") and carrying == "stake":
				var i := int(id.trim_prefix("hole_"))
				var h := _holes[i]
				if h.has_meta("done"):
					return
				h.set_meta("done", true)
				_drop()
				# Kazık deliğe dikilir, tokmakla üç vuruşta çakılır (eskiden E'ye basınca bir anda çakılı beliriyordu)
				# Kazık 1,8 m: tepesi bel hizasında (1,3 m) başlar, üç vuruşta 0,6 m gömülür (tokmak aşağı iner, vuruş seçilir)
				var st := Props.cyl(h, 0.06, 1.8, Vector3(0, 0.45, 0.15), Color("8a6a44"), Vector3(-18, 0, 0), 6, 0.02)
				stakes += 1
				await _hammer_in(st, 0.6)
				_update_objective()
		"haul":
			if id == "roller_back" and need_roller and not roller_held and _free_roller:
				roller_held = true
				_free_roller.visible = false
				for c in _free_roller.get_children():
					if c is StaticBody3D:
						c.queue_free()
				_pick("roller")
				_update_objective()
			elif id == "roller_front" and roller_held:
				roller_held = false
				need_roller = false
				rollers_set += 1
				_drop()
				_roller_in(_free_roller)
				_free_roller = null
				Audio.sfx("land_thud", -8.0, 1.2)
				meter.say(tr("UI_HAUL_ROLLER_OK"), Color("9fe08a"), 1.4)
				hud.bark("SPK_TOLGA", "D28O_T_ROLLER", 2.0)
				_update_objective()


## Tokmak elde (kameranın sağ altında), üç kez kalkıp iner; her vuruşta kazık bir parça gömülür, toz ve tok ses.
var _hammering := false


func _hammer_in(st: Node3D, depth: float) -> void:
	var was := player.frozen
	player.frozen = true
	_hammering = true
	# Kazık tokmağı (3. tur): önce kazığın başına yürünür (1 m), bakış kazığın tepesine. Tokmak gerçek ölçüde (sap
	# ~90 cm, baş 18x12 cm), sağ yumruk sapın ucunda, sol yumruk 28 cm yukarıda. Her vuruşta tokmağın başı kazığın
	# tepesine iner (eksen sağ yumruktan tepeye kurulur), kazık görünür biçimde gömülür, değme anında toz ve yonga.
	# Eskiden vuruş havayaydı: kazık metrelerce ötedeydi, baş hiçbir şeye değmiyordu.
	var top := st.to_global(Vector3(0, 0.9, 0))
	var base := Vector3(top.x, gy(top.x, top.z) + 0.55, top.z)
	await Stage.walk_player(player, Vector3(top.x, player.global_position.y, top.z), 0.8, base, 1.2)
	# 4. tur: bakış ani değil, 0,3 sn'de kazığın dibine doğru iner (eğim ~50°: sur ve sepet yığını kadrajın dışında
	# kalır; eskiden ani dönüşle bakış sura gidiyor, üçgen +%42'ydi)
	var cam_f := -player.camera.global_transform.basis.z
	var from := player.camera.global_position + cam_f * 2.0
	if Stage.fast():
		player.face(base)
	else:
		var lt := create_tween()
		lt.tween_method(func(k: float): player.face(from.lerp(base, k)), 0.0, 1.0, 0.3).set_trans(Tween.TRANS_SINE)
		await lt.finished
	var hm := Node3D.new()
	hm.set_meta("transient", true)
	player.camera.add_child(hm)
	var handle := Props.cyl(hm, 0.016, 1.0, Vector3(0, 0.5, 0), Color("6a4a2c"), Vector3.ZERO, 6)
	var head := Node3D.new()
	hm.add_child(head)
	Props.cyl(head, 0.06, 0.18, Vector3.ZERO, Color("8a6a44"), Vector3(0, 0, 90), 9)
	for sx: float in [-0.08, 0.08]:
		Props.cyl(head, 0.062, 0.02, Vector3(sx, 0, 0), Color("3a3634"), Vector3(0, 0, 90), 9)
	Props.strip_outlines(hm)
	hm.set_meta("handle", handle)
	hm.set_meta("head", head)
	player.stow_hands(true)
	_maul_pose(hm, 1.0, st)
	var f := Stage.fast()
	for k in 3:
		var tw := hm.create_tween()
		tw.tween_method(func(v: float): _maul_pose(hm, v, st), 0.0, 1.0, 0.03 if f else 0.32).set_trans(Tween.TRANS_SINE)
		tw.tween_method(func(v: float): _maul_pose(hm, v, st), 1.0, 0.0, 0.03 if f else 0.14).set_ease(Tween.EASE_IN)
		await tw.finished
		_maul_pose(hm, 0.0, st)
		if is_instance_valid(st):
			st.position.y -= depth / 3.0
			var tp := st.to_global(Vector3(0, 0.9, 0))
			Vfx.dust(self, tp + Vector3(0, 0.05, 0), 0.04)            # değme: tepeden küçük yonga tozu (büyüğü tokmağı örtüyordu)
			Vfx.dust(self, Vector3(tp.x, gy(tp.x, tp.z), tp.z), 0.07)  # dipte kabaran toprak
		Audio.sfx("pick_tap", -4.0, 0.75 + k * 0.08)
		player.shake(0.04)
		# Değme anında kısa duraklama (tokmak kazığın başında görünür)
		if not f:
			for n in 4:
				_maul_pose(hm, 0.0, st)
				await get_tree().process_frame
	player.release_both()
	player.stow_hands(false)
	hm.queue_free()
	player.frozen = was
	_hammering = false


## Tokmağın duruşu: v = 0 vuruş (baş kazığın tepesinde), v = 1 kalkık (baş omzun üstünde, geride). Sağ yumruk
## kameranın yerelinde iner kalkar; tokmak ekseni sağ yumruktan kazığın tepesine (vuruşta) ya da yukarı-geriye
## (kalkıkta) kurulur, sol yumruk sapın 28 cm yukarısına konur; sap boyu başı tam tepeye getirecek kadar.
func _maul_pose(hm: Node3D, v: float, st: Node3D) -> void:
	if not is_instance_valid(hm) or not is_instance_valid(st):
		return
	var cam := player.camera
	var rc := Vector3(0.1, -0.24, -0.38).lerp(Vector3(0.1, -0.02, -0.34), v)
	var rw := player.rig.socket.global_position + cam.global_transform.basis.y * 0.035 if player.rig else cam.to_global(rc)
	var top := st.to_global(Vector3(0, 0.96, 0))
	var strike := top - rw
	var d := clampf(strike.length(), 0.5, 1.4)
	var raised := (cam.global_transform.basis * Vector3(0.05, 0.8, 0.55)).normalized()
	var ax := strike.normalized().slerp(raised, clampf(v, 0.0, 1.0)).normalized()
	var lw := rw + ax * 0.28
	player.hold_both(cam.to_local(lw), rc)
	var x := ax.cross(Vector3.UP if absf(ax.y) < 0.95 else Vector3.FORWARD).normalized()
	hm.global_transform = Transform3D(Basis(x, ax, x.cross(ax)), rw)
	var handle: Node3D = hm.get_meta("handle")
	var head: Node3D = hm.get_meta("head")
	var dl := lerpf(d, 0.85, v)
	handle.scale = Vector3(1, dl + 0.1, 1)
	handle.position = Vector3(0, (dl - 0.1) * 0.5, 0)
	head.position = Vector3(0, dl, 0)


var _stake_sway := Vector3.ZERO
var _stake_yaw := INF


## Kazık taşıma (3. tur): sağ omuzda, iki el önde; Carry.attach'in ağırlık hissinin eşdeğeri (Carry sol eli free_hold
## ile yönettiği için iki elli tutuşla çakışıyordu): dönüşte yük geride kalıp yana yatar, adımda iner kalkar; eller
## bu salınımla birlikte gider, kazık her karede iki yumruğun içinden geçer.
func _stake_hold(delta: float) -> void:
	var yaw := player.camera.global_rotation.y
	if _stake_yaw == INF:
		_stake_yaw = yaw
	var dyaw := wrapf(yaw - _stake_yaw, -PI, PI)
	_stake_yaw = yaw
	var hv := Vector2(player.velocity.x, player.velocity.z).length()
	var bob := sin(_t * 9.0) * 0.012 * clampf(hv / 3.0, 0.0, 1.0)
	var want := Vector3(clampf(-dyaw / maxf(delta, 0.001) * 0.02, -0.06, 0.06), bob - 0.01 * clampf(hv / 3.0, 0.0, 1.0), 0)
	_stake_sway = _stake_sway.lerp(want, clampf(delta * 6.0, 0.0, 1.0)) if delta > 0.0 else want
	player.hold_both(Vector3(0.3, -0.14, -0.74) + _stake_sway * 0.7, Vector3(0.34, -0.22, -0.54) + _stake_sway)
	_fit_fists(_carry)


## Düğümün +Y eksenini sağ yumruktan sol yumruğa çevirir, kökü sağ yumruğa koyar (sap, kazık iki elin içinden geçer)
func _fit_fists(n: Node3D) -> void:
	if not is_instance_valid(n) or player.rig == null or player.free_rig == null:
		return
	var up := player.camera.global_transform.basis.y * 0.035      # avucun ortası (yuva avuç tabanında)
	var r: Vector3 = player.rig.socket.global_position + up
	var l: Vector3 = player.free_rig.socket.global_position + up
	var y := (l - r)
	if y.length() < 0.01:
		return
	y = y.normalized()
	var x := y.cross(Vector3.UP if absf(y.y) < 0.95 else Vector3.FORWARD).normalized()
	n.global_transform = Transform3D(Basis(x, y, x.cross(y)), r)


func _pick(what: String) -> void:
	if _on_rope:
		_on_rope = false
		player.release_both()
	carrying = what
	_carry = Node3D.new()
	_carry.position = Vector3(-0.3, -0.55, -1.0)
	player.camera.add_child(_carry)
	if what == "stake":
		# Kazık iki elde, göğsün önünde çapraz (yayma P4: sol elde kazık, sağ elde koli bandı duruyordu)
		# 2. tur: kazık (1,8 m, çap 10 cm) sağ omuzda, iki el önde tutar; arka ucu omzun ardında, ön ucu sağ kenarda
		# hafif yukarı (ekranı boydan boya kesmez)
		Props.cyl(_carry, 0.04, 1.5, Vector3(0, 0.6, 0), Color("8a6a44"), Vector3.ZERO, 6, 0.025)
		player.stow_hands(true)
		_stake_sway = Vector3.ZERO
		_stake_yaw = INF
		_stake_hold(0.0)
		_fit_fists(_carry)
		player.speed_mult = 0.85
	else:
		_carry.position = Vector3(0.0, -0.6, -1.0)
		Props.cyl(_carry, 0.22, 1.6, Vector3.ZERO, Color("8a6a44"), Vector3(0, 0, 90), 10)
		player.free_hold = Vector3(-0.45, -0.5, -0.9)      # kütüğün sol ucu sol elde
		player.speed_mult = 0.65
	Props.strip_outlines(_carry)
	if what != "stake":
		Carry.attach(player, _carry, {"weight": 0.95})
	Audio.sfx("land_pot", -10.0, 0.7)
	hud.set_prompt("")
	_update_objective()


func _drop() -> void:
	if carrying == "stake":
		player.release_both()
		player.stow_hands(false)
	carrying = ""
	player.free_hold = Vector3.INF
	player.speed_mult = 1.0
	if is_instance_valid(_carry):
		_carry.queue_free()
	_carry = null


func _process(delta: float) -> void:
	_t += delta
	_tick_haulers(delta)
	_tick_oxen(delta)
	if carrying == "stake" and is_instance_valid(_carry):
		_stake_hold(delta)
	# 6 Nisan: surdaki Bizans topları arada bir atar; gülle siperin önüne ya da ardına düşer
	if phase in ["stakes", "haul"] and not player.frozen and not hud.chain_busy():
		_ball_t -= delta
		if _ball_t <= 0.0:
			_ball_t = randf_range(6.0, 9.0)
			# Kızak çekilirken gülle bölüğün önüne/yanına iner (surdakiler kızağı görüyor)
			var at := player.global_position + Vector3(randf_range(-14.0, 14.0), 0, randf_range(-12.0, -5.0)) if phase == "stakes" \
				else sled.global_position + Vector3(randf_range(-6.0, 22.0), 0, randf_range(-9.0, -5.5))
			at.y = gy(at.x, at.z)
			hud.bark("SPK_SOLDIER", "D28O_S_BALL", 1.6)
			player.duck(0.3, 0.9)           # "Gülle! Eğil!": Tolga da eğilir
			get_tree().create_timer(1.2, false).timeout.connect(func():
				if is_inside_tree():
					Vfx.explosion(self, at, 0.6)
					Vfx.dust(self, at, 1.2)
					Audio.sfx("explosion_small", -6.0)
					Fx.trauma(0.25))


# ================================================================ halatçılar, halat, öküzler, zemin (yayma P4)

func _haul_show(on: bool) -> void:
	_herd_show(on)
	sled.visible = on
	for t in _teams:
		t.visible = on
	for r in _ropes:
		r.visible = on
	for c in _coils:
		c.visible = on


## Oyuncunun halattaki yeri: +z halatının ucunda, son halatçının ardında (halatın iç yanında)
func _rope_spot() -> Vector3:
	return Vector3(haul_x + 19.6, 0, HAUL_Z + 2.5)


## Urban halatçı sırasının yanında (dışında) yürür: oyuncuya 7 m, sıraya bakar
func _urban_spot() -> Vector3:
	var x := haul_x + 10.5
	return Vector3(x, gy(x, HAUL_Z + 3.6), HAUL_Z + 3.6)


var _rope_hx := INF


## Halat ucu: oyuncu yerindeyken iki eli halatta; kızak ilerleyince oyuncu da halatla bir adım geri gelir. Yerinden
## ayrılınca (kütüğe gidince) halat bırakılır, geri gelince (1 m) yeniden tutulur.
func _rope_tick(_dt: float) -> void:
	var spot := _rope_spot()
	var pp := player.global_position
	var d := Vector2(pp.x - spot.x, pp.z - spot.z).length()
	# 3. tur: oyuncuyu halatla birlikte kaydıran (kare kare ışınlayan) kısım kaldırıldı; halat ucunda tutma yok
	if _on_rope and (carrying != "" or d > 1.5):
		_on_rope = false
		player.release_both()
	_rope_hx = haul_x
	_lay_ropes()


func _stagger_heave(amp: float) -> void:
	for s in _teams:
		var dl := randf_range(0.0, 0.24)
		var am := amp * randf_range(0.78, 1.0)
		if dl < 0.03:
			s.heave = maxf(s.heave, am)
		else:
			get_tree().create_timer(dl, false).timeout.connect(func():
				if is_instance_valid(s):
					s.heave = maxf(s.heave, am))


## Halatçılar kızağı kendi adımlarıyla izler: kızak ilerleyince her biri kendi gecikmesiyle (0-0,3 sn) geri adım atar
## (adımda bacaklar "heave" ile oynar), tabanı her karede zemine basar. Eskiden kızağın çocuğuydular: kızakla birlikte
## ayakları yerde kayıyordu.
func _tick_haulers(delta: float) -> void:
	for d: Dictionary in _haulers:
		var s: Soldier = d["s"]
		if not is_instance_valid(s) or not s.visible:
			continue
		var fx: float = d["fx"]
		if absf(haul_x - fx) > 0.004:
			if not d.get("moving", false):
				if float(d["wait"]) < 0.0:
					d["wait"] = randf_range(0.02, 0.3)
				d["wait"] = float(d["wait"]) - delta
				if float(d["wait"]) <= 0.0:
					d["moving"] = true
					s.heave = maxf(s.heave, 0.85)       # adım: bacaklar oynar
			if d.get("moving", false):
				fx = move_toward(fx, haul_x, delta * 2.6)
				d["fx"] = fx
		else:
			d["moving"] = false
			d["wait"] = -1.0
		var p := Vector3(fx + float(d["ox"]), 0, HAUL_Z + float(d["oz"]))
		p.y = gy(p.x, p.z)
		s.global_position = p
		Stage.plant_feet(s, _gyf)


## "Altmış öküz bunu Edirne'den getirdi": topu getiren öküzler kızak yolunun gerisinde. Yakında iki canlı takım
## (boyunduruk, dikmeler, çeki zinciri, arkada kütük kızağı; sürücü üvendireyle yanında) yol boyunca ağır ağır
## çekerek bataryaya gelir; ötede koşumu çözülmemiş çiftler sıra sıra dinlenir (tek çoklu ağ). Toplam 60 öküz.
func _build_oxen() -> void:
	var coats := [Color("8a5a36"), Color("6a4a2a"), Color("b89868"), Color("4a3a2a"), Color("9a6a40")]
	for i in 2:
		var team := Node3D.new()
		add_child(team)
		team.rotation.y = PI * 0.5                    # yerel +Z → dünya +X (bataryaya doğru)
		var oxen: Array = []
		for sx: float in [-0.75, 0.75]:
			var o := Ox.new(coats[(i * 2 + int(sx > 0.0)) % coats.size()])
			team.add_child(o)
			o.position = Vector3(sx, 0, 0)
			_bake_ox(o)
			oxen.append(o)
		var still: Array = [Props.box(team, Vector3(2.0, 0.12, 0.14), Vector3(0, 1.62, 0.95), Color("5a3a22"))]
		for sx: float in [-0.75, 0.75]:
			for dx: float in [-0.27, 0.27]:
				still.append(Props.cyl(team, 0.025, 0.5, Vector3(sx + dx, 1.36, 0.95), Color("6a4a2c"), Vector3.ZERO, 4))
		# Kütük kızağı (arkada): iki kızak ayağı, çapraz kalaslar, üç kütük
		var sz := -3.9
		for kx: float in [-0.45, 0.45]:
			still.append(Props.box(team, Vector3(0.12, 0.16, 2.5), Vector3(kx, 0.08, sz), Color("5a3e26")))
		for p: Vector3 in [Vector3(-0.22, 0.42, sz), Vector3(0.22, 0.42, sz), Vector3(0, 0.72, sz)]:
			still.append(Props.cyl(team, 0.18, 2.3, p, Color("8a6a44"), Vector3(90, 0, 0), 8))
		Props.bake_static(team, still)
		Stage.chain(team, Vector3(0, 1.5, 0.95), Vector3(0, 0.3, sz + 1.3), 0.35, 0.08, Color("3a3a40"))
		var herder := Soldier.new(Color("7a5232"), "stand", "turban")
		herder.set_meta("no_talk", true)
		add_child(herder)
		_goad(herder)
		var x0 := -9.0 - i * 4.0
		var z := HAUL_Z + 8.5 + i * 3.6
		_ox_teams.append({"team": team, "oxen": oxen, "herder": herder, "x": x0, "z": z, "end": -3.0 - i * 4.0, "bellow": randf_range(3.0, 9.0)})
		_place_team(_ox_teams[-1])
	# Uzak sıralar (yayma P4, 5. tur): 28 boyunduruk çifti (56 öküz), çift başına tek düşük ayrıntılı ağ (iki öküz:
	# gövde, hörgüç, baş, dört bacak, iki boynuz kutusu + boyunduruk; öküz başına ~100 üçgen), tek çoklu ağ, gölgesiz.
	# Eskiden canlı öküz modeli (binlerce üçgen) uzakta siyah benek gibi okunuyordu ve çekmede üçgen +%11..28 idi.
	var pair := _herd_pair_mesh()
	var rng := RandomNumberGenerator.new()
	rng.seed = 2808
	var xs: Array = []
	var cs: Array = []
	var tints := [Color("f2e6d0"), Color("d8b890"), Color("b88a5c"), Color("e8d4b0")]
	for i in 28:
		var row := i / 7
		var col := i % 7
		var c := Vector3(-6.0 - col * 3.8 + rng.randf_range(-0.9, 0.9), 0, HAUL_Z + 17.0 + row * 3.8 + rng.randf_range(-0.7, 0.7))
		var yaw := PI * 0.5 + rng.randf_range(-0.5, 0.5) + (PI if row % 2 == 1 and rng.randf() < 0.3 else 0.0)
		c.y = gy(c.x, c.z)
		xs.append(Transform3D(Basis(Vector3.UP, yaw), c))
		cs.append(tints[rng.randi() % tints.size()])
	var hm := Scenery._vc_mat()
	hm.vertex_color_is_srgb = true
	hm.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mm := Scenery.scatter(self, pair, xs, cs, hm)
	mm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mm.visibility_range_end = 160.0
	_herd.append(mm)
	_herd_show(false)


## Uzak öküz çifti: iki düşük ayrıntılı öküz (+Z ileri, x ±0,75) ve boyunduruk; köşe rengi (açık gövde, koyu
## bacak/baş altı, krem boynuz); örnek rengi gövde tonunu çeşitlendirir. Öküz başına 8 kutu (96 üçgen).
func _herd_pair_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var box := func(c: Vector3, sz: Vector3, col: Color, tilt := 0.0) -> void:
		var b := Basis(Vector3.RIGHT, tilt)
		var h := sz * 0.5
		var faces := [[Vector3.UP, Vector3.RIGHT, Vector3.BACK], [Vector3.DOWN, Vector3.RIGHT, Vector3.FORWARD],
			[Vector3.RIGHT, Vector3.BACK, Vector3.UP], [Vector3.LEFT, Vector3.FORWARD, Vector3.UP],
			[Vector3.BACK, Vector3.LEFT, Vector3.UP], [Vector3.FORWARD, Vector3.RIGHT, Vector3.UP]]
		for f: Array in faces:
			var n: Vector3 = f[0]
			var u: Vector3 = f[1]
			var v: Vector3 = f[2]
			var o := n * h
			var du := u * h
			var dv := v * h
			var q := [o - du - dv, o + du - dv, o + du + dv, o - du + dv]
			var shade := 1.0 if n.y > 0.5 else (0.7 if n.y < -0.5 else 0.86)
			for k in [0, 2, 1, 0, 3, 2]:
				st.set_color(Color(col.r * shade, col.g * shade, col.b * shade))
				st.set_normal(b * n)
				st.add_vertex(c + b * (q[k] as Vector3))
	var coat := Color(1, 1, 1)
	var dark := Color(0.45, 0.36, 0.3)
	var horn := Color(1.25, 1.2, 1.05)
	for sx: float in [-0.75, 0.75]:
		box.call(Vector3(sx, 1.12, -0.05), Vector3(0.82, 0.82, 1.95), coat)              # gövde
		box.call(Vector3(sx, 1.55, 0.5), Vector3(0.5, 0.3, 0.55), coat)                  # hörgüç
		box.call(Vector3(sx, 1.25, 1.2), Vector3(0.4, 0.42, 0.6), coat, 0.5)             # baş (aşağı eğik)
		box.call(Vector3(sx, 1.05, 1.5), Vector3(0.3, 0.26, 0.2), dark)                 # burun
		for lz: float in [0.6, -0.7]:
			for lx: float in [-0.24, 0.24]:
				box.call(Vector3(sx + lx, 0.36, lz), Vector3(0.16, 0.72, 0.18), dark)      # bacak
		box.call(Vector3(sx, 1.55, 1.08), Vector3(0.95, 0.07, 0.07), horn)               # boynuzlar
	box.call(Vector3(0, 1.66, 0.95), Vector3(2.1, 0.13, 0.15), Color(0.55, 0.38, 0.24))  # boyunduruk
	st.index()
	var mesh := st.commit()
	return mesh


## Uzak sürü ve iki canlı takım yalnız 11 Nisan'da (çekme) görünür: 6 Nisan'da top henüz yolda, 12 Nisan atışında
## öküzler ordugâha çekilmiş (eskiden her evrede sahnedeydiler; kazık ve atış evrelerinde üçgen bütçesini yiyordu)
func _herd_show(on: bool) -> void:
	for h in _herd:
		h.visible = on
	for t: Dictionary in _ox_teams:
		(t["team"] as Node3D).visible = on
		(t["herder"] as Node3D).visible = on
		(t["herder"] as Node3D).process_mode = Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED


## Canlı öküzün parçaları (gövde, baş, bacaklar, kuyruk) kendi içinde tek ağ: canlandırma sürer, çizim azalır
func _bake_ox(o: Ox) -> void:
	var body: Node3D = o.get("_body")
	var parts: Array = [o.get("_head"), o.get("_tail")]
	parts.append_array(o.get("_legs"))
	for pn in parts:
		var part := pn as Node3D
		if part:
			Props.bake_static(part, part.get_children())
	var direct: Array = []
	for c in body.get_children():
		if c is MeshInstance3D:
			direct.append(c)
	Props.bake_static(body, direct)


func _place_team(t: Dictionary) -> void:
	var team: Node3D = t["team"]
	var x: float = t["x"]
	var z: float = t["z"]
	team.global_position = Vector3(x, gy(x, z), z)
	var herder: Soldier = t["herder"]
	var hp := team.to_global(Vector3(-1.7, 0, 0.2))
	herder.global_position = Vector3(hp.x, gy(hp.x, hp.z), hp.z)
	herder.rotation.y = PI * 0.5


## Takımlar kızak çekilirken bataryaya doğru yürür (0,55 m/sn), yolun sonunda durur; öküzler ara sıra böğürür
func _tick_oxen(delta: float) -> void:
	for t: Dictionary in _ox_teams:
		if phase == "haul" and float(t["x"]) < float(t["end"]):
			t["x"] = minf(float(t["end"]), float(t["x"]) + delta * 0.55)
			_place_team(t)
		t["bellow"] = float(t["bellow"]) - delta
		if float(t["bellow"]) <= 0.0:
			t["bellow"] = randf_range(6.0, 14.0)
			((t["oxen"] as Array).pick_random() as Ox).bellow()


## Sürücünün üvendiresi: sağ elde, ucunda küçük demir mıh (Bölüm 2 slipway._goad gibi)
func _goad(sol: Soldier) -> void:
	var el: Node3D = sol.rig.elbow_r if sol.rig else null
	if el == null:
		return
	var g := Node3D.new()
	el.add_child(g)
	g.position = Vector3(0, -0.28, 0.06)
	Props.cyl(g, 0.02, 1.9, Vector3(0, 0.55, 0), Color("6a4a2c"), Vector3.ZERO, 5)
	Props.cyl(g, 0.012, 0.08, Vector3(0, 1.53, 0), Color("4a4d52"), Vector3.ZERO, 4)


## Batarya zemini (yayma P4): siper dibinde kazık çukurlarının çamuru, kızak yolunda çamur ve ayak izi, gelinen yolda
## kızak ve toynak izi, kazık yığınının dibinde yonga. Her tür tek çoklu ağ. Eskiden düz petek taş levhaydı.
func _build_ground() -> void:
	Nature.ground_detail(self, Rect2(1.4, 113.7, 15.4, 1.8), "mud", 2.4, 2801, _gyf)
	Nature.ground_detail(self, Rect2(-24.0, HAUL_Z - 2.8, 52.0, 5.6), "mud", 0.5, 2802, _gyf)
	Nature.ground_detail(self, Rect2(-24.0, HAUL_Z - 3.4, 52.0, 6.8), "footprint", 0.55, 2803, _gyf)
	Nature.ground_detail(self, Rect2(16.4, 119.2, 3.4, 2.6), "chips", 3.0, 2804, _gyf)
	for rz: float in [-0.55, 0.55]:
		Nature.trail(self, [Vector3(-70.0, 0, HAUL_Z + rz), Vector3(HAUL_FROM - 4.6, 0, HAUL_Z + rz)], "wheel_ruts", _gyf, 1.0, 2805 + int(rz * 10.0), 0.05)
	Nature.trail(self, [Vector3(-70.0, 0, HAUL_Z + 4.0), Vector3(-14.0, 0, HAUL_Z + 4.0)], "hoofprint", _gyf, 0.5, 2807, 1.6)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(28, _outcome)
	await Siege.show_page(hud, 28)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(28)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			GameState.replay_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW28O_TITLE")
	c.nodes = [
		{"id": "stakes", "key": "FLOW28O_STAKES", "pos": Vector2(0.5, 0.12)},
		{"id": "28O.1", "key": "FLOW_28O_1", "pos": Vector2(0.3, 0.34), "outcome": true},
		{"id": "28O.2", "key": "FLOW_28O_2", "pos": Vector2(0.7, 0.34), "outcome": true},
		{"id": "shot", "key": "FLOW28O_SHOT", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["stakes", "28O.1"], ["stakes", "28O.2"], ["28O.1", "shot"], ["28O.2", "shot"]]
	for k in ["stakes", _outcome, "shot"]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH28O_STATS") % [slips, tr("UI_CH28O_HIT") if hit else tr("UI_CH28O_NOHIT"), Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		GameState.tr_pad("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "28O.1", "lose": "28O.2"}.get(v, "28O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("28", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and stakes == STAKES and haul_x >= HAUL_TO
	ok = ok and (slips >= 1 if v == "lose" else slips == 0)
	# Edirne'nin izi: kötü yolda kütük sık ve nişan Urban'da; iyi yolda kütük seyrek, nişan bandı geniş
	var want_every: float = {"edirne": 3.0, "edirne_ok": 6.0}.get(v, ROLLER_EVERY)
	ok = ok and _master == (v == "edirne") and is_equal_approx(_roller_every, want_every) \
		and is_equal_approx(gun_crew.tolerance, 24.0 if v == "edirne_ok" else 16.0)
	if v != "lose":
		ok = ok and rollers_set == {"edirne": 3, "edirne_ok": 1}.get(v, 2)
	if v == "edirne":
		ok = ok and hit           # Urban'ın nişanı tutar
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s foto=%s usta=%s kütük=%.1f)" % [expected, _outcome, not page.is_empty(),
			cam != null and cam.done, _master, _roller_every])
	print("AUTOTEST %s chapter=28o variant=%s outcome=%s stakes=%d slips=%d hit=%s master=%s roller_every=%.1f rollers=%d" % [
		"PASS" if ok else "FAIL", v, _outcome, stakes, slips, hit, _master, _roller_every, rollers_set])
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
	haul_x = -2.0
	_place_sled()
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(haul_x - 9.0, gy(haul_x, HAUL_Z) + 4.5, HAUL_Z + 11.0)
	cv.look_at(sled.global_position + Vector3(5.0, 1.5, -2.0), Vector3.UP)
	cv.fov = 55.0
	cv.make_current()
	await get_tree().create_timer(0.6, false).timeout
	await _shot_png("c28o_cover.png")
	get_tree().quit()
