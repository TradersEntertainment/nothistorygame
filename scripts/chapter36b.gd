extends Node3D
## Bölüm 36 (Bizans tarafı) — Huruç (Tolga · 9 Nisan 1453, şafaktan önce, Mesoteichion'un önü). docs/SIEGE.md §3.
##
## Kuşatmanın ilk günlerinde, büyük bombardıman başlamadan, savunucular geceleri surdan çıkıp hendeğin önünde siper
## kazan Osmanlı öncülerine baskın yaptı. Kayıplar karşılanamayacak kadar ağır gelince İmparator ve Giustiniani
## huruçları yasakladı: adamlar bir daha surun dışına çıkmadı (Runciman; Leonardo di Chio). Tolga, Giustiniani'nin
## Cenevizlileriyle poternadan çıkar:
##   1. kalas köprüden hendeği geç · 2. siperdeki kazıcılarla çarpış (WaveRunner) · 3. meşaleyle üç ahşap siperi yak ·
##   tespit karesi: yanan siperler · 4. davullar: sipahiler gelir, geri çekil. Yolda okla vurulmuş Leon yatar:
##   kaldırılırsa omzuna dayanıp yavaş yürür; bırakılırsa poterna onsuz kapanır.
## Gece bölüm boyunca kademe kademe ağarır (siyah perde arkasında bir anda sabah olmaz); dönüşte şafak.
##   36.1 Herkes döndü (Leon da) · 36.2 Leon dışarıda kaldı
## Dallanma: Bölüm 20 (Gedik) Leon'u hatırlar (36.1: gedikte Tolga'nın yanındadır; 36.2: Giustiniani adını anar).
##   --autotest[=leave]   (varsayılan: 36.1; leave: Leon kaldırılmaz)

const LANE_X := -24.0
const POSTERN := Vector3(LANE_X, 0.0, LandWalls.OUTER_Z1)       # dış surun ova yüzündeki gizli kapı
const RETURN := Vector3(LANE_X, 0.0, 17.2)                      # kapının önü (sur dibindeki set)
const BRIDGE_Z0 := 18.6
const BRIDGE_Z1 := 36.9
const BRIDGE_Y := 1.6
const MANTLETS := [Vector3(LANE_X - 7.0, 0.0, 47.0), Vector3(LANE_X, 0.0, 50.0), Vector3(LANE_X + 7.0, 0.0, 47.0)]
const TRENCH_Z := 54.0
const LEON_AT := Vector3(LANE_X + 3.2, 0.0, 45.2)
const RIDE_TIME := 34.0

var walls: LandWalls
var player: Player
var hud: Hud
var giust: Person
var leon: Person
var men: Array[Person] = []
var diggers: Array[Person] = []
var riders: Array[Node3D] = []
var _mantlets: Array[Node3D] = []
var _burned: Array[bool] = [false, false, false]
var burned := 0
var phase := "intro"
var _outcome := ""
var _photo := ""
var cam: TespitCam
var _torch: Node3D
var _leon_follow := false
var _trail: Array[Vector3] = []
var _ride_t := 0.0
var _fights_won := 0
var _kills := 0
var _walks: Array[Tween] = []      # köprü yürüyüşleri (içeri geçerken durdurulur: yarım kalan yürüyüş adamı dışarı çekmesin)


func _ready() -> void:
	GameState.snapshot(36)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(false)
	hud.set_signal(0)
	walls = LandWalls.new()
	walls.intact = true                 # 9 Nisan: bombardıman başlamadı, sur bütün
	walls.field_keep = [Rect2(LANE_X - 14.0, 36.0, 28.0, 60.0)]     # baskının alanı: ova eşyası konmaz
	add_child(walls)
	walls.set_repair(LandWalls.STAGES)
	walls.dawn_to(0.05, 0.01)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ kurulum

func _build() -> void:
	# Poterna: dış surun dibinde alçak, demir kuşaklı meşe kapı (ova yüzünde), üstünde taş kemer
	var wood := Color("5a3e26")
	Props.box(self, Vector3(1.5, 2.2, 0.12), POSTERN + Vector3(0, 1.1, 0.07), wood.darkened(0.15))
	for y: float in [0.5, 1.1, 1.7]:
		Props.box(self, Vector3(1.52, 0.07, 0.03), POSTERN + Vector3(0, y, 0.145), Color("2e2a28"))
	Props.box(self, Vector3(2.0, 0.35, 0.2), POSTERN + Vector3(0, 2.38, 0.1), LandWalls.C_STONE.lightened(0.1))
	# Kapının önünden hendeğin karşı yakasına kalas köprü: önce set duvarının (korkuluk) üstüne rampa, sonra hendeğin
	# üstünden ovaya inen kalaslar; altında payandalar (havada durmaz)
	var ramp_len := Vector2(BRIDGE_Z0 - 16.2, BRIDGE_Y).length()
	var ramp_ang := rad_to_deg(atan2(BRIDGE_Y, BRIDGE_Z0 - 16.2))
	Props.make_solid(Props.box(self, Vector3(2.0, 0.18, ramp_len), Vector3(LANE_X, BRIDGE_Y * 0.5 - 0.05, (16.2 + BRIDGE_Z0) * 0.5),
		Color("7a5634"), Vector3(-ramp_ang, 0, 0)))
	var b_len := Vector2(BRIDGE_Z1 - BRIDGE_Z0, BRIDGE_Y - 0.04).length()
	var b_ang := rad_to_deg(atan2(BRIDGE_Y - 0.04, BRIDGE_Z1 - BRIDGE_Z0))
	Props.make_solid(Props.box(self, Vector3(2.0, 0.18, b_len), Vector3(LANE_X, (BRIDGE_Y + 0.04) * 0.5 - 0.05, (BRIDGE_Z0 + BRIDGE_Z1) * 0.5),
		Color("7a5634"), Vector3(b_ang, 0, 0)))
	for k in 12:
		var z := BRIDGE_Z0 + 0.8 + k * (BRIDGE_Z1 - BRIDGE_Z0 - 1.6) / 11.0
		Props.box(self, Vector3(2.04, 0.03, 0.12), Vector3(LANE_X, _bridge_y(z) + 0.05, z), Color("4a3422"))
	for z: float in [23.0, 28.0, 33.0]:
		var top := _bridge_y(z) - 0.14
		var bot := Assault.ground_y(LANE_X, z)
		for sx: float in [-0.85, 0.85]:
			Props.box(self, Vector3(0.18, top - bot, 0.18), Vector3(LANE_X + sx, (top + bot) * 0.5, z), wood)
	# Osmanlı öncülerinin işi: hendeğe 50 m'de kazılan siper (toprak set, sepetler) ve önünde üç tekerlekli ahşap
	# kalkan (mantelet). Kazıcılar gece çalışır, fenerleri yanar.
	var earth := Color("6a5a44")
	Props.solid(self, Vector3(26.0, 0.38, 1.6), Vector3(LANE_X, 0.19, TRENCH_Z - 1.2), earth)
	Props.box(self, Vector3(26.0, 0.04, 1.4), Vector3(LANE_X, 0.02, TRENCH_Z + 0.4), Color("2a241e"))     # kazılan hendek (koyu)
	for k in 9:
		var gx := LANE_X - 12.0 + k * 3.0
		var g := Props.cyl(self, 0.42, 0.9, Vector3(gx, 0.83, TRENCH_Z - 1.2), Color("8a7450"), Vector3.ZERO, 10)
		g.set_meta("gabion", true)
		Props.make_solid(g, 0.9)
		for r in 3:
			Props.cyl(self, 0.43, 0.03, Vector3(gx, 0.45 + r * 0.3, TRENCH_Z - 1.2), Color("5a4a30"), Vector3.ZERO, 10)
	for i in MANTLETS.size():
		_mantlets.append(_mantlet(MANTLETS[i], i))
	for k in 3:
		Night.torch(self, Vector3(LANE_X - 9.0 + k * 9.0, 0, TRENCH_Z + 1.4), 1.8, k == 1)
	# Kazıcılar (çarpışma başlayınca kalkıp kılıca sarılırlar: yerlerinden WaveRunner'ın rakipleri koşar)
	for i in 6:
		var dg := Person.new({"coat": [Color("8a6a4a"), Color("6a4a3a"), Color("7a5a3a")][i % 3], "pants": Color("e8e0d0"), "hat": "turban",
			"mustache": true, "beard": i % 2 == 0})
		dg.position = Vector3(LANE_X - 10.0 + i * 4.0, 0.0, TRENCH_Z + 0.6)
		dg.rotation.y = PI
		dg.set_meta("no_talk", true)
		add_child(dg)
		dg.set_activity("chop")
		diggers.append(dg)
	# Giustiniani ve adamları kapının önünde, setin üstünde (dışarı çıkmış, sessiz)
	giust = Person.new({"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
		"beard": true, "skin": Color("e0b08a")})
	giust.position = RETURN + Vector3(-1.6, 0, 0.2)
	giust.set_meta("no_yield", true)
	add_child(giust)
	giust.look_target = player
	for i in 5:
		var d := Person.new({"coat": [Color("8a8e96"), Color("7a2a24"), Color("5a6a7a")][i % 3], "pants": Color("3a2a22"), "hat": "helm",
			"beard": i % 2 == 0, "mustache": true})
		d.set_meta("no_talk", true)
		d.set_meta("spk", "SPK_DEFENDER")
		# Rampanın (x LANE_X ± 1) yanında, kenarından uzak: dibindeki adam rampanın kenarına itilip havada kalıyordu
		d.position = RETURN + Vector3(2.4 + (i % 3) * 1.0, 0, -0.3 + (i / 3) * 0.8)
		add_child(d)
		d.equip("spear_shield" if i % 2 == 0 else "sword", Color("5a2a24"))
		men.append(d)
	# Leon: Rum okçu, Giustiniani'nin bölüğünde. Baskının sonunda okla vurulup siperin önüne düşer.
	leon = Person.new({"coat": Color("5a6a7a"), "pants": Color("3a2a22"), "hat": "helm", "mustache": true, "beard": false})
	leon.set_meta("no_talk", true)
	leon.set_meta("spk", "SPK_DEFENDER")
	leon.position = RETURN + Vector3(4.0, 0, 1.0)
	add_child(leon)
	men.append(leon)
	# Surda okçular ve nöbetçiler (kapının iki yanında; dönerken örtü ateşi açarlar)
	Garrison.land_walls(self, [Vector2(LANE_X - 2.5, LANE_X + 2.5)], [Vector2(LANE_X - 12.0, LANE_X + 12.0)], [], 36)


func _bridge_y(z: float) -> float:
	if z <= BRIDGE_Z0:
		return clampf((z - 16.2) / (BRIDGE_Z0 - 16.2), 0.0, 1.0) * BRIDGE_Y
	return lerpf(BRIDGE_Y, 0.04, clampf((z - BRIDGE_Z0) / (BRIDGE_Z1 - BRIDGE_Z0), 0.0, 1.0))


## Tekerlekli ahşap kalkan: dikine kalaslar, iki tekerlek, arkasında destek ayağı; atış delikleri
func _mantlet(p: Vector3, i: int) -> Node3D:
	var m := Node3D.new()
	m.name = "Mantlet%d" % i
	m.position = p
	add_child(m)
	var wood := Color("6a4a2c")
	for k in 7:
		Props.box(m, Vector3(0.36, 2.2, 0.1), Vector3(-1.08 + k * 0.36, 1.25, 0), wood.darkened(0.04 * (k % 3)))
	for y: float in [0.6, 1.9]:
		Props.box(m, Vector3(2.6, 0.14, 0.08), Vector3(0, y, -0.1), wood.darkened(0.2))
	Props.box(m, Vector3(0.22, 0.12, 0.12), Vector3(-0.5, 1.6, 0.03), Color("141010"))     # atış deliği
	Props.box(m, Vector3(0.22, 0.12, 0.12), Vector3(0.6, 1.6, 0.03), Color("141010"))
	for sx: float in [-1.0, 1.0]:
		Props.cyl(m, 0.32, 0.08, Vector3(sx * 1.1, 0.32, 0.2), Color("3a2a1a"), Vector3(0, 0, 90), 10)
	Props.box(m, Vector3(0.12, 0.12, 1.6), Vector3(0, 0.75, 0.7), wood.darkened(0.2), Vector3(35, 0, 0))   # destek ayağı
	var s := Props.solid(m, Vector3(2.6, 2.3, 0.4), Vector3(0, 1.15, 0.0), Color.WHITE)
	s.get_child(0).visible = false
	Props.interactable(m, "mantlet_%d" % i, Vector3(3.0, 2.4, 2.2), Vector3(0, 1.2, -0.9))
	return m


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH36B_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH36B_SUB"), 20, Color(1, 1, 1, 0.7)]], 3.0)
	hud.clear_card()
	player.global_position = RETURN + Vector3(1.5, 0.05, 0.3)      # rampanın yanında (eskiden rampanın içinde doğuyordu)
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.2)
	await hud.say("SPK_NIHAT", "D36_N_01")
	await hud.say("SPK_GIUST", "D36_G_01")
	await hud.say("SPK_TOLGA", "D36_T_01")
	await hud.say("SPK_GIUST", "D36_G_02")
	await hud.say("SPK_DEFENDER", "D36_L_01")
	# Çıkış: adamlar köprüden geçip siperin önüne yayılır; Tolga ardından
	phase = "cross"
	walls.dawn_to(0.12, 60.0)
	_advance_men()
	Lore.scatter(self, "36b")
	player.frozen = false
	hud.set_objective(tr("UI_OBJ36_CROSS"), Vector3(LANE_X, 1.2, 41.0))
	if GameState.autotest:
		player.global_position = Vector3(LANE_X + 1.0, 0.05, 41.5)
	while player.global_position.z < 40.0 or player.global_position.y < -0.5:
		await get_tree().process_frame
	await _fight()
	await _burn_phase()
	await _photo_phase()
	await _retreat()
	await _back_inside()
	await _end_chapter()


## Adamlar köprüden geçip siperin önüne yayılır (yürüyerek; kendi şeritlerinde)
func _advance_men() -> void:
	var spots: Array[Vector3] = []
	for i in men.size():
		spots.append(Vector3(LANE_X - 6.0 + i * 2.2, 0.0, 42.5 + (i % 2) * 1.0))
	spots.append(Vector3(LANE_X - 2.0, 0.0, 41.0))     # Giustiniani
	var all: Array[Person] = men.duplicate()
	all.append(giust)
	for i in all.size():
		_walk_bridge(all[i], spots[i], 0.75 * i, false, -0.45 if i % 2 == 0 else 0.45)


## Köprü yolu: kapının önü → rampa → kalas → ova; sonra hedef. Adım hızında, kalasın üstünde.
func _walk_bridge(p: Person, to: Vector3, delay: float, back := false, side := 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	if not is_instance_valid(p) or phase == "home":
		return
	var pts: Array[Vector3] = []
	# Köprüde iki sıra (kalas iki metre): arka arkaya gidenler iç içe girmesin
	var lane := LANE_X + side
	if back:
		pts = [Vector3(lane, 0, BRIDGE_Z1 + 0.6), Vector3(lane, _bridge_y(BRIDGE_Z0), BRIDGE_Z0), Vector3(lane, 0, 16.6), to]
	else:
		pts = [Vector3(lane, 0, 16.6), Vector3(lane, _bridge_y(BRIDGE_Z0), BRIDGE_Z0), Vector3(lane, 0.04, BRIDGE_Z1 + 0.6), to]
	for q: Vector3 in pts:
		var from := p.global_position
		var d := from.distance_to(q)
		if d < 0.05:
			continue
		if phase == "home" and back:
			return
		var tw := p.create_tween()
		_walks.append(tw)
		tw.tween_method(func(k: float):
			var at := from.lerp(q, k)
			if at.z > 16.1 and at.z < BRIDGE_Z1 + 0.2 and absf(at.x - LANE_X) < 1.0:      # rampa ve kalas 2 m eninde
				at.y = _bridge_y(at.z)
			else:
				at.y = Assault.ground_y(at.x, at.z) if at.z > 16.1 else 0.0
			p.global_position = at
			if (q - from).length() > 0.1:
				p.look_at(p.global_position + Vector3(q.x - from.x, 0, q.z - from.z), Vector3.UP)
				p.rotate_y(PI), 0.0, 1.0, d / 2.6)
		await tw.finished


func _fight() -> void:
	phase = "fight"
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_GIUST", "D36_G_GO")
	Audio.sfx("war_cry", -4.0, 1.05)
	Audio.intensity(2, "walls_night")
	# Kazıcılar küreği bırakır; yerlerinden kılıçlılar koşar (WaveRunner)
	var from: Array = []
	for dg in diggers:
		from.append(dg.global_position + Vector3(0, 0, 1.5))
		dg.queue_free()
	diggers.clear()
	player.frozen = false
	var r: Dictionary = await WaveRunner.run(self, hud, player, [
		{"specs": _foe_specs(6, from), "max_active": 2, "skill": 0.3, "allies": 3, "limit": 75.0, "from": from, "rally": 0.0}], "spathion")
	_fights_won += int(r["won"])
	_kills += int(r.get("kills", 0))
	Audio.intensity(1, "walls_night")
	walls.dawn_to(0.3, 70.0)


func _foe_specs(n: int, spots: Array) -> Array:
	var out := []
	for i in n:
		out.append({"pos": spots[i % spots.size()], "blade": "kilij", "shield": i % 3 == 1, "name": "SPK_AZAP",
			"look": {"coat": [Color("8a6a4a"), Color("6a4a3a"), Color("7a5a3a")][i % 3], "pants": Color("e8e0d0"), "hat": "turban",
			"mustache": true, "beard": i % 2 == 0}})
	return out


## Meşale: adamlardan biri yakıp verir; üç kalkanı yak
func _burn_phase() -> void:
	phase = "burn"
	player.frozen = true
	await hud.say("SPK_GIUST", "D36_G_BURN")
	_take_torch()
	await hud.say("SPK_TOLGA", "D36_T_TORCH")
	player.frozen = false
	_update_objective()
	if GameState.autotest:
		for i in 3:
			player.global_position = (MANTLETS[i] as Vector3) + Vector3(0, 0.05, -2.2)
			await get_tree().process_frame
			_on_interact("mantlet_%d" % i)
	while burned < 3:
		await get_tree().process_frame
	hud.set_prompt("")
	_drop_torch()
	walls.dawn_to(0.45, 60.0)


func _take_torch() -> void:
	if _torch:
		return
	Audio.sfx("fire_crackle", -10.0)
	_torch = Node3D.new()
	_torch.set_meta("transient", true)
	player.camera.add_child(_torch)
	_torch.position = Vector3(0.32, -0.42, -0.62)
	_torch.rotation_degrees = Vector3(18, 0, -8)
	Props.cyl(_torch, 0.025, 0.6, Vector3(0, -0.1, 0), Color("4a3020"), Vector3.ZERO, 6)
	Props.cyl(_torch, 0.045, 0.12, Vector3(0, 0.22, 0), Color("2a2420"), Vector3.ZERO, 8)
	Flame.add(_torch, Vector3(0, 0.27, 0), 0.16, 0.32, 0.7)
	var l := OmniLight3D.new()
	l.light_color = Color("ff9a40")
	l.light_energy = 1.4
	l.omni_range = 7.0
	l.position = Vector3(0, 0.45, 0)
	_torch.add_child(l)


func _drop_torch() -> void:
	if _torch:
		_torch.queue_free()
		_torch = null


func _burn_mantlet(i: int) -> void:
	if _burned[i]:
		return
	_burned[i] = true
	burned += 1
	var m := _mantlets[i]
	Audio.sfx("fire_crackle", -4.0, 0.9 + i * 0.05)
	Vfx.fire(m, Vector3(0, 0.4, 0.1), 1.1)
	for c in m.get_children():
		if c is MeshInstance3D:
			var mi := c as MeshInstance3D
			var mat := mi.get_active_material(0)
			if mat is BaseMaterial3D:
				var dm := (mat as BaseMaterial3D).duplicate() as BaseMaterial3D
				dm.albedo_color = dm.albedo_color.darkened(0.55)
				mi.material_override = dm
	var it := m.get_node_or_null("Interact_mantlet_%d" % i)
	if it:
		it.queue_free()
	hud.bark("SPK_TOLGA", "D36_T_BURN_%d" % burned, 2.2)
	_update_objective()


func _photo_phase() -> void:
	phase = "photo"
	player.frozen = true
	await hud.say("SPK_NIHAT", "D36_N_PHOTO")
	player.frozen = false
	var target := Node3D.new()
	_mantlets[1].add_child(target)
	target.position = Vector3(0, 2.0, 0)
	hud.set_objective(tr("UI_OBJ36_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege36")
	hud.add_child(cam)
	cam.max_dist = 45.0
	cam.cone_deg = 22.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	hud.set_objective("")


## Davullar: sipahiler ordugâhtan çıkar. Geri çekil; Leon'u kaldır ya da bırak.
func _retreat() -> void:
	phase = "retreat"
	Audio.sfx("drum_boom", -2.0, 0.8)
	await get_tree().create_timer(0.4).timeout
	Audio.sfx("drum_boom", -2.0, 0.75)
	Audio.intensity(2, "walls_night")
	hud.bark("SPK_DEFENDER", "D36_D_RIDERS", 3.0)
	_spawn_riders()
	walls.dawn_to(0.7, RIDE_TIME + 10.0)
	# Leon okla vurulmuş, siperin önünde yatıyor
	_leon_down()
	player.frozen = true
	await hud.say("SPK_GIUST", "D36_G_BACK")
	await hud.say("SPK_DEFENDER", "D36_L_HELP")
	player.frozen = false
	for i in men.size():
		if men[i] != leon:
			_walk_bridge(men[i], RETURN + Vector3(2.4 + (i % 3) * 1.0, 0, -0.3 + (i / 3) * 0.8), 0.8 * i, true, -0.45 if i % 2 == 0 else 0.45)      # çıktıkları yere (rampanın üstünde durup yolu kapatmasınlar)
	_walk_bridge(giust, RETURN + Vector3(-2.6, 0, 0.5), 4.2, true, 0.45)
	hud.set_objective(tr("UI_OBJ36_BACK"), RETURN + Vector3(0, 1.6, 0))
	_ride_t = 0.0
	if GameState.autotest:
		if GameState.autotest_variant != "leave":
			player.global_position = LEON_AT + Vector3(0.8, 0.05, -0.6)
			await get_tree().process_frame
			_on_interact("leon")
		await get_tree().create_timer(0.5).timeout
		player.global_position = RETURN + Vector3(1.5, 0.05, 0.6)
		if _leon_follow:
			leon.global_position = RETURN + Vector3(2.2, 0.0, 1.4)
	while phase == "retreat":
		await get_tree().process_frame
	hud.set_chase("", 0.0)
	hud.set_objective("")


func _leon_down() -> void:
	leon.global_position = Vector3(LEON_AT.x, Assault.ground_y(LEON_AT.x, LEON_AT.z), LEON_AT.z)
	leon.rotation.y = 0.4
	leon.set_activity("dead")
	var arrow := Props.cyl(leon, 0.012, 0.7, Vector3(0.12, 1.2, -0.15), Color("6a5030"), Vector3(55, 0, 0), 4)
	arrow.set_meta("transient", true)
	Props.interactable(self, "leon", Vector3(1.6, 1.4, 1.6), LEON_AT + Vector3(0, 0.6, 0))


func _spawn_riders() -> void:
	for i in 6:
		var h := Horse.new([Color("5a3a24"), Color("2a2420"), Color("8a6a4a")][i % 3], [Color("b3262d"), Color("2e4a7a")][i % 2])
		h.position = Vector3(LANE_X - 9.0 + i * 3.6, 0.0, 84.0 + (i % 2) * 2.5)
		h.rotation.y = PI
		add_child(h)
		var rd := Person.new({"coat": [Color("2e4a7a"), Color("b3262d"), Color("3e4c68")][i % 3], "pants": Color("e8e0d0"), "hat": "helm",
			"mustache": true, "beard": i % 2 == 0})
		rd.set_meta("no_talk", true)
		add_child(rd)
		h.mount(rd)
		rd.equip("spear")
		Night.torch(h, Vector3(0.5, 1.2, 0.2), 1.2, i % 3 == 0)
		riders.append(h)


func _process(delta: float) -> void:
	if phase == "retreat":
		_ride_t += delta
		var k := clampf(_ride_t / RIDE_TIME, 0.0, 1.0)
		hud.set_chase(tr("UI_CH36_RIDERS"), k)
		for i in riders.size():
			var h := riders[i] as Horse
			if not is_instance_valid(h):
				continue
			var z0 := 84.0 + (i % 2) * 2.5
			# Okçuların menzili (z 58): atlılar burada durur, siperin gerisinde bekler
			var z := lerpf(z0, 58.5 + (i % 2) * 1.5, k)
			h.speed = 0.0 if k >= 1.0 else 4.0
			h.position = Vector3(h.position.x, 0.0, z)
		if k >= 1.0 and not _leon_follow and leon.visible:
			_leon_taken()
		_leon_step(delta)
		var pp := player.global_position
		if Vector2(pp.x - RETURN.x, pp.z - RETURN.z).length() < 2.6 and absf(pp.y - RETURN.y) < 1.0:
			_arrived()


## Leon Tolga'nın izinden yürür (oyuncunun geçtiği yerden: köprünün kenarından düşmesin), bir adım geride
func _leon_step(delta: float) -> void:
	if not _leon_follow or not is_instance_valid(leon):
		return
	var pp := player.global_position
	if _trail.is_empty() or _trail[_trail.size() - 1].distance_to(pp) > 0.3:
		_trail.append(pp)
	var lp := leon.global_position
	while _trail.size() > 1 and lp.distance_to(_trail[0]) < 0.35:
		_trail.remove_at(0)
	if _trail.is_empty() or lp.distance_to(pp) < 1.3:
		return
	var tgt: Vector3 = _trail[0]
	var step := (tgt - lp)
	var d := step.length()
	if d < 0.01:
		return
	var mv := step / d * minf(d, 3.0 * delta)
	leon.global_position = lp + mv
	var flat := Vector3(step.x, 0, step.z)
	if flat.length() > 0.05:
		leon.look_at(leon.global_position + flat, Vector3.UP)
		leon.rotate_y(PI)


func _leon_taken() -> void:
	# Atlılar siperin önüne varır: Leon'u alıp götürürler (esir). Kapı onsuz kapanacak.
	hud.bark("SPK_DEFENDER", "D36_D_LEON_TAKEN", 3.0)
	leon.visible = false
	var it := get_node_or_null("Interact_leon")
	if it:
		it.queue_free()


func _arrived() -> void:
	if phase != "retreat":
		return
	if _leon_follow and leon.global_position.distance_to(player.global_position) > 4.0:
		return       # Leon geride: onu beklemeden kapıdan girilmez (köprünün üstündeyken)
	phase = "home"
	_outcome = "36.1" if _leon_follow else "36.2"
	player.speed_mult = 1.0


func _back_inside() -> void:
	player.frozen = true
	Audio.sfx("door_open", -4.0, 0.8)
	await hud.fade_to(1.0, 0.6)
	for tw in _walks:
		if tw and tw.is_valid():
			tw.kill()
	_walks.clear()
	for h in riders:
		if is_instance_valid(h):
			h.queue_free()
	riders.clear()
	_leon_follow = false
	# İçeride: peribolos, kapının arkası. Adamlar sayılır.
	player.global_position = Vector3(LANE_X + 0.6, 0.05, 9.0)
	giust.global_position = Vector3(LANE_X - 1.2, 0.0, 10.2)
	giust.set_activity("")
	var i := 0
	for d in men:
		if d == leon and _outcome != "36.1":
			d.visible = false
			continue
		d.set_activity("sit_ground" if d == leon else "")
		d.global_position = Vector3(LANE_X + 1.6 + (i % 3) * 1.0, 0.0, 10.8 + (i / 3) * 0.9)
		i += 1
	player.face(giust.global_position + Vector3(0, 1.5, 0))
	walls.dawn_to(1.0, 20.0)
	Audio.intensity(0)
	await hud.fade_to(0.0, 0.8)
	if _outcome == "36.1":
		await hud.say("SPK_GIUST", "D36_G_ALL")
		await hud.say("SPK_DEFENDER", "D36_L_THANKS")
	else:
		await hud.say("SPK_GIUST", "D36_G_LEON")
		await hud.say("SPK_TOLGA", "D36_T_LEON")
	await hud.say("SPK_GIUST", "D36_G_ORDER")
	await hud.say("SPK_NIHAT", "D36_N_END")
	GameState.flags["leon_saved"] = _outcome == "36.1"
	Siege.record(36, _photo, "SIEGE_NOTE_36_%s" % _outcome.split(".")[1])


func _update_objective() -> void:
	if phase == "burn":
		hud.set_objective(tr("UI_OBJ36_BURN") % burned, _next_mantlet())


func _next_mantlet() -> Vector3:
	for i in _burned.size():
		if not _burned[i]:
			return (MANTLETS[i] as Vector3) + Vector3(0, 1.6, 0)
	return Vector3.INF


func _on_focus(id: String) -> void:
	if id.begins_with("mantlet_") and phase == "burn":
		hud.set_prompt(tr("UI_PROMPT36_BURN"))
	elif id == "leon" and phase == "retreat" and not _leon_follow:
		hud.set_prompt(tr("UI_PROMPT36_LEON"))
	else:
		hud.set_prompt("")


func _on_interact(id: String) -> void:
	if id.begins_with("mantlet_") and phase == "burn":
		_burn_mantlet(int(id.trim_prefix("mantlet_")))
	elif id == "leon" and phase == "retreat" and not _leon_follow and leon.visible:
		_leon_follow = true
		_trail.clear()
		leon.set_activity("")
		leon.global_position = player.global_position + player.global_transform.basis.z * 1.2
		player.speed_mult = 0.62
		hud.set_prompt("")
		var it := get_node_or_null("Interact_leon")
		if it:
			it.queue_free()
		hud.bark("SPK_DEFENDER", "D36_L_UP", 2.6)


func _end_chapter() -> void:
	player.frozen = true
	_drop_torch()
	GameState.set_outcome(36, _outcome)
	await Siege.show_page(hud, 36)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(36)
			if nxt != "":
				GameState.change_scene(nxt)
			else:
				GameState.change_scene(Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW36_TITLE")
	c.nodes = [
		{"id": "out", "key": "FLOW36_OUT", "pos": Vector2(0.5, 0.12)},
		{"id": "fire", "key": "FLOW36_FIRE", "pos": Vector2(0.5, 0.3)},
		{"id": "36.1", "key": "FLOW_36_1", "pos": Vector2(0.3, 0.56), "outcome": true},
		{"id": "36.2", "key": "FLOW_36_2", "pos": Vector2(0.7, 0.56), "outcome": true},
	]
	c.edges = [["out", "fire"], ["fire", "36.1"], ["fire", "36.2"]]
	c.taken["out"] = true
	c.taken["fire"] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH36_STATS") % [burned, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "36.1", "leave": "36.2"}.get(v, "36.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("36", {})
	var ok: bool = _outcome == expected and not page.is_empty() and burned == 3 and cam != null and cam.done
	ok = ok and bool(GameState.flags.get("leon_saved", false)) == (expected == "36.1")
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (yanan=%d sayfa=%s foto=%s)" % [expected, _outcome, burned, not page.is_empty(),
			cam != null and cam.done])
	print("AUTOTEST %s chapter=36 variant=%s outcome=%s burned=%d fights=%d kills=%d" % ["PASS" if ok else "FAIL", v, _outcome, burned,
		_fights_won, _kills])
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
	walls.dawn_to(0.35, 0.01)
	await get_tree().create_timer(1.0).timeout
	player.global_position = Vector3(LANE_X + 0.3, _bridge_y(18.0) + 0.05, 18.0)      # rampanın üstünden köprü ve ova
	player.face(Vector3(LANE_X, 1.0, 45.0))
	await _shot("c36b_01_bridge.png")
	_advance_men()
	await get_tree().create_timer(7.0).timeout
	for i in 3:
		_burn_mantlet(i)
	_spawn_riders()
	await get_tree().create_timer(1.5).timeout
	player.global_position = Vector3(LANE_X + 4.0, 0.05, 40.0)
	player.face(MANTLETS[1] + Vector3(0, 1.2, 0))
	await _shot("c36b_02_fire.png")
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(LANE_X + 9.0, 7.5, 33.0)
	cv.look_at(Vector3(LANE_X, 1.5, 49.0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c36b_cover.png")
	get_tree().quit()
