extends Node3D
## Bölüm 3 — Vaka 1453-T (Nihat · Zaman Bürosu ve Hikmet'in garajı). CHAPTERS §7, Bölüm 3.
##
## Akış: Nihat'ın odası (pnömatik tüpten dosya, Form Z-1) → Başdenetçi Müfide Hanım'ın
## brifingi → kostüm deposu (fötr şapka) → saha asansörü → 2026, Hikmet'in garajı →
## Paradoks İzi (isteğe bağlı: leblebi kabukları, fes püskülü, koli bandı + tekmenin
## hologramı) → Hikmet'in sorgusu (doğruyu söyletme olasılığı %) → yalanı yakala ya da
## geç → ⏱ makineye ne yapılacak → 5 sonuç ve akış şeması.
##
## Sonuçlar: 3.1 el konuldu · 3.2 mühürlendi · 3.3 bırakıldı, kartvizit · 3.4 eli boş ·
## 3.5 çay içildi.
##   --autotest[=tea|confiscate|seal|lie|radio]   (varsayılan: 3.3)

const PERSUADE_BASE := 30.0
const TRACE_BONUS := 15.0
const REL_NAMES := {-2: "UI_REL_ENEMY", -1: "UI_REL_COLD", 0: "UI_REL_NEUTRAL", 1: "UI_REL_FRIEND", 2: "UI_REL_PARTNER"}

var bureau: Bureau
var garage: Garage
var hikmet: Hikmet
var player: Player
var hud: Hud
var phase := "intro"    # intro, office, bureau, garage, interro, done
var _outcome := ""
var _done: Dictionary = {}
var _clues: Dictionary = {}
var _approach := ""
var _persuade := PERSUADE_BASE
var _busy := false
var _flavor_idx: Dictionary = {}
var _clue_nodes: Dictionary = {}
var _lost: Dictionary = {}          # Hikmet'in süpürüp kararttığı ipuçları
var _clock := -1.0                  # Büro alarmı: asansöre kalan süre (sn); -1 kapalı
var _obj := ["", null, 1.6]         # geçerli hedef (süre eki için yeniden yazılır)
var _obj_tick := 0.0
var _alarm_lights: Array[OmniLight3D] = []
var _sab_on := false                # garajda Hikmet delil karartıyor
var _sab_tw: Tween
var _sab_target := ""
var _sab_cd := 0.0
var _radio: Node3D
var _hikmet_saw_fly := false        # Hikmet, Nihat'ı uçarken gördü (İkna +10)
var _eaves := false                 # görünmez Nihat, Hikmet'in kendi kendine söylendiğini duydu (yalan önceden bilinir)


func _ready() -> void:
	GameState.snapshot(3)
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	player.hand_style = "nihat"   # Nihat oynanır: Tolga'nın çantası elde olmaz
	add_child(player)
	player.interacted.connect(_on_interact)
	player.focus_changed.connect(_on_focus)
	player.frozen = true
	hud.set_nihat_mode(true)
	hud.set_fez(false)
	hud.meters.loyalty = _loyalty()
	hud.meters._shown_loyalty = _loyalty()
	_load_bureau()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _process(delta: float) -> void:
	# Büro alarmı: süre azalır, hedef satırında geri sayım; kırmızı ışıklar yanıp söner
	if _clock > 0.0:
		_clock = maxf(0.0, _clock - delta)
		_obj_tick -= delta
		if _obj_tick <= 0.0:
			_obj_tick = 0.5
			_show_objective()
	for i in _alarm_lights.size():
		var l := _alarm_lights[i]
		if is_instance_valid(l):
			l.light_energy = 6.0 if fmod(Time.get_ticks_msec() / 1000.0 + i * 0.3, 0.9) < 0.45 else 0.6
	# Delil karartma: Hikmet süpürürken yakalanırsa bırakır
	_sab_cd = maxf(0.0, _sab_cd - delta)
	if _sab_on and _sab_target != "" and hikmet and player and not _busy:
		var d := Vector2(player.global_position.x - hikmet.global_position.x, player.global_position.z - hikmet.global_position.z).length()
		if d < 1.7:
			_sab_caught()


func _objective(key: String, target: Variant = null, h := 1.6) -> void:
	_obj = [key, target, h]
	_show_objective()


func _show_objective() -> void:
	var text: String = tr(_obj[0]) if _obj[0] != "" else ""
	if text != "" and _clock >= 0.0 and phase in ["office", "bureau"]:
		text += "\n" + tr("UI_CH3_ALARM_CLOCK") % [int(_clock) / 60, int(_clock) % 60]
	hud.set_objective(text, _obj[1], _obj[2])


func _loyalty() -> float:
	return float(GameState.flags.get("sadakat", 60))


func _add_loyalty(d: int) -> void:
	GameState.flags["sadakat"] = clampi(int(_loyalty()) + d, 0, 100)
	hud.meters.set_loyalty(_loyalty())


func _set_persuade(v: float) -> void:
	_persuade = clampf(v, 0.0, 100.0)
	hud.meters.set_persuade(_persuade)


# ================================================================ sahneler

func _load_bureau() -> void:
	bureau = Bureau.new()
	add_child(bureau)
	player.global_position = Bureau.SPAWN_POS
	player.face(Vector3(0, 1.2, 4.3))
	bureau.mufide.look_target = player
	bureau.riza.look_target = player


func _load_garage() -> void:
	bureau.queue_free()
	bureau = null
	garage = Garage.new()
	add_child(garage)
	garage.spin = 0.3
	# Tolga'nın aldığı eşyalar raflarda yok
	for id in GameState.bag:
		if garage.items.has(id):
			garage.set_item_visible(id, false)
	for id in garage.items:
		(garage.items[id]["body"] as StaticBody3D).collision_layer = 0
	if GameState.flags.get("panel_cracked", false):
		garage.panel_screen.modulate = Color("ff5a4a")
	garage.panel_screen.text = "14:53"
	hikmet = Hikmet.new()
	hikmet.position = Garage.HIKMET_POS
	add_child(hikmet)
	hikmet.look_target = player
	_build_clues()
	player.global_position = Garage.SPAWN_POS + Vector3(0.6, 0, 0.3)
	player.face(hikmet.global_position + Vector3(0, 1.3, 0))


## Paradoks İzi ipuçları: leblebi kabukları, fes püskülü ipi, koli bandı parçaları.
func _build_clues() -> void:
	var shells := Node3D.new()
	shells.position = Vector3(-2.85, 0.0, 1.0)
	garage.add_child(shells)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	for i in 14:
		Props.ball(shells, 0.018, Vector3(rng.randf_range(-0.25, 0.25), 0.01, rng.randf_range(-0.2, 0.2)), Color("d9b98a"), Vector3(1.2, 0.5, 1.0), 5)
	_clue(shells, "clue:shells", Vector3(0.7, 0.4, 0.6))
	var tassel := Node3D.new()
	tassel.position = Garage.PLATFORM_POS + Vector3(0.45, 0.09, 0.35)
	garage.add_child(tassel)
	Props.cyl(tassel, 0.006, 0.22, Vector3(0.0, 0.006, 0), Color("141414"), Vector3(0, 30, 90), 4)
	Props.ball(tassel, 0.03, Vector3(0.11, 0.02, 0.06), Color("141414"), Vector3(1, 0.6, 1), 6)
	_clue(tassel, "clue:fez", Vector3(0.6, 0.4, 0.6))
	var tape := Node3D.new()
	tape.position = garage.panel_node.global_position + Vector3(-0.35, 0.0, 0.35)
	garage.add_child(tape)
	for i in 5:
		Props.box(tape, Vector3(0.09, 0.005, 0.04), Vector3(rng.randf_range(-0.15, 0.15), 0.003, rng.randf_range(-0.12, 0.12)), Garage.C_TAPE, Vector3(0, rng.randf_range(0, 180), 0))
	_clue(tape, "clue:tape", Vector3(0.7, 0.5, 0.7))


func _clue(node: Node3D, id: String, size: Vector3) -> void:
	_clue_nodes[id] = node
	Props.interactable(node, id, size, Vector3(0, size.y / 2.0, 0))
	# Tarayıcı işareti: hafifçe parlayan halka
	var ring := Props.ring(node, 0.16, 0.2, Vector3(0, 0.01, 0), Color("6ff2c8"), Vector3.ZERO, 1.5)
	ring.name = "Marker"


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH3_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH3_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)

	# Nihat'ın odası: pnömatik tüp
	phase = "office"
	await _n("D3_N_01")
	bureau.capsule.visible = true
	var tw := create_tween()
	tw.tween_property(bureau.capsule, "position:y", 0.98, 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tw.finished
	player.shake(0.3)
	bureau.file_node.visible = true
	(bureau.file_node.get_child(bureau.file_node.get_child_count() - 1) as StaticBody3D).collision_layer = 2
	await _n("D3_N_02")
	player.frozen = false
	_objective("UI_OBJ3_FILE", hud.spot("file"), 0.3)
	await _step("file", _take_file)
	_objective("UI_OBJ3_MUFIDE", hud.spot("mufide"), 0.9)
	phase = "bureau"
	await _step("mufide", _briefing)
	_objective("UI_OBJ3_DEPOT", hud.spot("riza"), 0.9)
	await _step("riza", _depot)
	_objective("UI_OBJ3_LIFT", hud.spot("lift"), 0.6)
	await _step("lift", _lift)

	# 2026: garaj
	phase = "garage"
	await _garage_intro()
	hud.set_objective(tr("UI_OBJ3_TRACE") % _clues.size(), _trace_spot(), 0.4)
	player.frozen = false
	if not GameState.autotest:
		_sabotage()
	await _step("hikmet", _interrogation)
	await _end_chapter()


## Etkileşimle tamamlanan adım. Otomatik testte adım doğrudan oynatılır.
## Kalan ipuçlarından en yakını; hepsi tarandıysa Hikmet
func _trace_spot() -> Callable:
	var clues := hud.spot(["clue:shells", "clue:fez", "clue:tape"], func(id): return _clues.has(id) or _lost.has(id))
	var hik := hud.spot("hikmet")
	return func():
		var c = clues.call()
		return c if c else hik.call()


func _step(id: String, handler: Callable) -> void:
	if GameState.autotest:
		if id == "hikmet" and GameState.autotest_variant != "lie":
			for c in ["clue:shells", "clue:fez", "clue:tape"]:
				await _scan(c)
		await handler.call()
		return
	while not _done.has(id):
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame


# ---------------------------------------------------------------- Büro

func _take_file() -> void:
	_busy = true
	player.frozen = true
	bureau.file_node.visible = false
	(bureau.file_node.get_child(bureau.file_node.get_child_count() - 1) as StaticBody3D).collision_layer = 0
	await _n("D3_N_03")
	await _n("D3_N_04")
	await _alarm_start()
	player.frozen = false
	_done["file"] = true
	_busy = false


func _briefing() -> void:
	_busy = true
	player.frozen = true
	player.face(bureau.mufide.global_position + Vector3(0, 1.4, 0))
	await _m("D3_M_05")
	await _n("D3_N_06")
	await _m("D3_M_07")
	await _m("D3_M_08")
	var c := await hud.choose(["UI_CH3_TONE_RULE", "UI_CH3_TONE_SOFT"], 10.0, 0)
	if c == 1:
		_add_loyalty(-5)
		await _m("D3_M_09B")
	else:
		_add_loyalty(5)
		await _m("D3_M_09A")
	await bureau.mufide.stamp()
	await _m("D3_M_10")
	player.frozen = false
	_done["mufide"] = true
	_busy = false


func _depot() -> void:
	_busy = true
	player.frozen = true
	player.face(bureau.riza.global_position + Vector3(0, 1.4, 0))
	await _say("SPK_RIZA", "D3_R_11")
	bureau.fedora_node.visible = true
	await _n("D3_N_12")
	await _say("SPK_RIZA", "D3_R_13")
	var c := await hud.choose(["UI_CH3_TAKE_HAT", "UI_CH3_ASK_FEZ"], 10.0, 0)
	if c == 1:
		await _say("SPK_RIZA", "D3_R_14B")
	await _n("D3_N_14")
	bureau.fedora_node.visible = false
	hud.set_fez(true)
	GameState.flags["nihat_fedora"] = true
	await _say("SPK_RIZA", "D3_R_15")
	# Yeni yönetmelik paketi: Kaldırma Formu Z-9 (uçuş) ve Zaman Perdesi (görünmezlik)
	await _say("SPK_RIZA", "D3_R_KIT_1")
	await _n("D3_N_KIT_2")
	await _say("SPK_RIZA", "D3_R_KIT_3")
	var pw := player.enable_nihat_powers(3)
	pw.witnessed.connect(_on_witnessed)
	pw.eavesdrop.connect(_on_eavesdrop)
	pw.veil_changed.connect(_on_veil)
	GameState.flags["nihat_kit"] = true
	hud.bark("SPK_NIHAT", "D3_N_KIT_TRY", 4.0)
	player.frozen = false
	_done["riza"] = true
	_busy = false


func _lift() -> void:
	_busy = true
	player.frozen = true
	hud.set_objective("")
	if player.powers:
		player.powers.set_flying(false)
		player.powers.set_cloak(false)
	var late := _clock == 0.0
	_clock = -1.0
	if late:
		_add_loyalty(-5)
		await _m_remote("D3_M_LATE")
	elif not GameState.autotest:
		_add_loyalty(3)
		hud.bark("SPK_NIHAT", "D3_N_ONTIME", 2.5)
	for l in _alarm_lights:
		if is_instance_valid(l):
			l.queue_free()
	_alarm_lights.clear()
	await bureau.open_lift()
	await _n("D3_N_16")
	await hud.fade_to(1.0, 0.8, Color.WHITE)
	_load_garage()
	await hud.card([[tr("UI_CH3_GARAGE"), 30, Color("1d2330")]], 1.8)
	hud.clear_card()
	await _arrival()
	_done["lift"] = true
	_busy = false


# ---------------------------------------------------------------- garaj

## Nihat'ın garaja ışınlanması: Hikmet'in omzunun üstünden, ışık sütunu, genişleyen zaman halkaları, havada uçuşan
## formlar; ışık sönünce fötr şapkalı denetçi orada. Sonra birinci şahsa dönülür.
func _arrival() -> void:
	var at := player.global_position
	var cam := Camera3D.new()
	garage.add_child(cam)
	cam.fov = 58.0
	cam.global_position = Garage.HIKMET_POS + Vector3(-0.75, 2.05, -1.45)
	cam.look_at(at + Vector3(0, 1.1, 0))
	cam.current = true
	hikmet.look_target = null
	var nih := Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
		"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	garage.add_child(nih)
	nih.global_position = at
	nih.look_at_from_position(at, Vector3(hikmet.global_position.x, at.y, hikmet.global_position.z), Vector3.UP)
	nih.rotate_y(PI)
	nih.visible = false
	var fx := Node3D.new()
	garage.add_child(fx)
	fx.global_position = at
	var cyan := Color(0.55, 0.95, 1.0, 0.55)
	var pillar := Props.cyl(fx, 0.6, 3.2, Vector3(0, 1.6, 0), cyan, Vector3.ZERO, 20)
	pillar.material_override = Props.mat(cyan, 2.5, true, "", false)
	pillar.scale = Vector3(0.05, 1, 0.05)
	var rings: Array = []
	for i in 3:
		var r := Props.ring(fx, 0.5, 0.58, Vector3(0, 0.15 + i * 1.0, 0), Color("7ff2ff"), Vector3.ZERO, 3.0)
		r.material_override = Props.mat(Color("7ff2ff"), 3.0, false, "", false)
		r.scale = Vector3.ONE * 0.2
		rings.append(r)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 1.4, 0)
	light.light_color = Color("7ff2ff")
	light.light_energy = 0.0
	light.omni_range = 6.0
	fx.add_child(light)
	await hud.fade_to(0.0, 0.4, Color.WHITE)
	Audio.sfx("machine_spin", -4.0, 1.3)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(pillar, "scale", Vector3(1, 1, 1), 0.5).set_trans(Tween.TRANS_BACK)
	tw.tween_property(light, "light_energy", 5.0, 0.5)
	for i in rings.size():
		tw.tween_property(rings[i], "scale", Vector3.ONE * (2.2 + i * 0.4), 0.9).set_delay(0.15 * i)
	await tw.finished
	# Işık patlaması: denetçi belirir, havada formlar uçuşur
	Audio.sfx("machine_jump", 0.0)
	Audio.sfx("whoosh_fly", -4.0)
	nih.visible = true
	for i in 6:
		var paper := Props.box(fx, Vector3(0.21, 0.004, 0.29), Vector3(randf_range(-0.4, 0.4), 2.3 + randf() * 0.5, randf_range(-0.4, 0.4)),
			Color("f4f1e6"), Vector3(randf() * 40, randf() * 180, randf() * 40))
		var pt := create_tween().set_parallel(true)
		pt.tween_property(paper, "position", paper.position + Vector3(randf_range(-1.2, 1.2), -2.2, randf_range(-1.2, 1.2)), 1.6).set_trans(Tween.TRANS_SINE)
		pt.tween_property(paper, "rotation_degrees", paper.rotation_degrees + Vector3(randf_range(-200, 200), randf_range(-200, 200), 0), 1.6)
	var out := create_tween().set_parallel(true)
	out.tween_property(pillar, "scale", Vector3(0.02, 1.2, 0.02), 0.35)
	out.tween_property(light, "light_energy", 0.0, 0.8)
	for r in rings:
		out.tween_property(r, "scale", Vector3.ONE * 0.01, 0.4)
	hikmet.emote("surprise")
	await _wait(1.6)
	Audio.sfx("stamp", -10.0)
	await _wait(0.4)
	fx.queue_free()
	nih.queue_free()
	cam.queue_free()
	player.camera.current = true
	hikmet.look_target = player


## Tarama efekti: tarayıcıdan ipucuna ışın, ipucunun çevresinde dönen yeşil halka, yukarı aşağı gezen tarama çizgisi.
func _scan_fx(node: Node3D) -> Node3D:
	var fx := Node3D.new()
	garage.add_child(fx)
	fx.global_position = node.global_position
	var green := Color("3aff9a")
	var ring := Props.ring(fx, 0.28, 0.32, Vector3(0, 0.02, 0), green, Vector3.ZERO, 3.0)
	ring.material_override = Props.mat(green, 3.0, false, "", false)
	var line := Props.box(fx, Vector3(0.7, 0.012, 0.7), Vector3.ZERO, Color(0.23, 1.0, 0.6, 0.35))
	line.material_override = Props.mat(Color(0.23, 1.0, 0.6, 0.35), 2.0, true, "", false)
	var beam := Props.box(fx, Vector3(0.012, 0.012, 1.0), Vector3.ZERO, Color(0.23, 1.0, 0.6, 0.6))
	beam.material_override = Props.mat(Color(0.23, 1.0, 0.6, 0.6), 3.0, true, "", false)
	beam.name = "Beam"
	var l := OmniLight3D.new()
	l.light_color = green
	l.light_energy = 1.2
	l.omni_range = 1.4
	l.position = Vector3(0, 0.3, 0)
	fx.add_child(l)
	var tw := fx.create_tween().set_loops()
	tw.tween_property(line, "position:y", 0.45, 0.35).set_trans(Tween.TRANS_SINE)
	tw.tween_property(line, "position:y", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
	var tr2 := fx.create_tween().set_loops()
	tr2.tween_property(ring, "scale", Vector3.ONE * 1.25, 0.3)
	tr2.tween_property(ring, "scale", Vector3.ONE, 0.3)
	return fx


func _scan_beam(fx: Node3D) -> void:
	var beam := fx.get_node_or_null("Beam") as Node3D
	if beam == null or player.hand == null:
		return
	var from := player.hand.global_position + player.camera.global_transform.basis * Vector3(0.0, 0.02, -0.12)
	var to := fx.global_position + Vector3(0, 0.12, 0)
	beam.global_position = (from + to) * 0.5
	beam.look_at(to, Vector3.UP)
	beam.scale = Vector3(1, 1, from.distance_to(to))

func _garage_intro() -> void:
	player.frozen = true
	await _h("D3_H_17")
	player.show_badge(3.2)
	await _n("D3_N_18")
	await _h("D3_H_19")
	await _n("D3_N_20")
	await _h("D3_H_21")
	await _h("D3_H_22")
	# Hikmet çay koymaya tezgâha gider: bu sırada iz taranabilir
	hikmet.look_target = null
	var tw := create_tween()
	hikmet.rotation.y = atan2(-1.9, 0.9)
	tw.tween_property(hikmet, "position", Vector3(-2.7, 0, -0.9), 1.6)       # tezgâhın önünde (içine girmeden)
	await tw.finished
	hikmet.rotation.y = -PI / 2
	_brew_tea()
	hud.bark("SPK_NIHAT", "D3_N_23", 4.0)
	# Görünmezliğin burada bir işi var: arkası dönük Hikmet kendi kendine konuşur, yalanını önceden duyarız
	if player.powers and player.powers.can_cloak:
		get_tree().create_timer(4.6).timeout.connect(func():
			if phase == "garage" and not _eaves and not hud.is_talking():
				hud.bark("SPK_NIHAT", "D3_N_EAVES_HINT", 6.0))


## Tezgâhta çay: ocak, çift demlik, buhar. "Çay koyayım" deyip boş el dönmesin.
const TEA_STOVE := Vector3(-3.7, 0.9, -1.75)
const TEA_TABLE := Vector3(-0.45, 0.0, 0.7)
var _tea: Array[Node3D] = []


func _brew_tea() -> void:
	if get_node_or_null("TeaStation"):
		return
	var st := Node3D.new()
	st.name = "TeaStation"
	st.position = TEA_STOVE
	add_child(st)
	Props.box(st, Vector3(0.3, 0.08, 0.3), Vector3(0, 0.04, 0), Color("3a3a40"))
	Props.cyl(st, 0.1, 0.02, Vector3(0, 0.09, 0), Color("ff7a2a"), Vector3.ZERO, 10, -1.0, 2.0)
	Props.cyl(st, 0.12, 0.16, Vector3(0, 0.18, 0), Color("c0c4cc"), Vector3.ZERO, 12, 0.1)
	Props.cyl(st, 0.08, 0.12, Vector3(0, 0.33, 0), Color("d8dce4"), Vector3.ZERO, 12, 0.06)
	Props.cyl(st, 0.012, 0.1, Vector3(0.1, 0.36, 0), Color("c0c4cc"), Vector3(0, 0, 60), 5)
	Vfx.steam(st, Vector3(0, 0.45, 0))
	for i in 2:
		var g := _tea_glass()
		g.position = TEA_STOVE + Vector3(0.18, 0.0, 0.25 + i * 0.12)
		add_child(g)
		_tea.append(g)
	Audio.sfx("land_pot", -14.0, 0.8)


func _tea_glass() -> Node3D:
	var g := Node3D.new()
	Props.cyl(g, 0.045, 0.006, Vector3(0, 0.003, 0), Color("e8e0d0"), Vector3.ZERO, 14)
	Props.cyl(g, 0.02, 0.07, Vector3(0, 0.04, 0), Color("9a2a14"), Vector3.ZERO, 10, 0.016)
	var glass := Props.cyl(g, 0.023, 0.085, Vector3(0, 0.048, 0), Color(1, 1, 1, 0.25), Vector3.ZERO, 12, 0.018)
	glass.material_override = Props.mat(Color(0.9, 0.95, 1.0, 0.25), 0.0, true, "", false)
	return g


## Sorgu masası: bir sandık, üstünde iki bardak; bardaklar tezgâhtan süzülerek gelir.
func _serve_tea() -> void:
	if _tea.is_empty():
		_brew_tea()
	Props.solid(self, Vector3(0.5, 0.45, 0.5), TEA_TABLE + Vector3(0, 0.225, 0), Color("8a6440"))
	for i in _tea.size():
		var g := _tea[i]
		var tw := create_tween()
		tw.tween_property(g, "position", TEA_TABLE + Vector3(-0.12 + i * 0.24, 0.45, 0), 0.9).set_trans(Tween.TRANS_SINE)


## Bir ipucunu tara: kısa bir tarama, Nihat'ın yorumu. Koli bandı tekmenin hologramını oynatır.
func _scan(id: String) -> void:
	if _clues.has(id) or _lost.has(id) or _busy:
		return
	_busy = true
	player.frozen = true
	var node: Node3D = _clue_nodes[id]
	player.face(node.global_position + Vector3(0, 0.1, 0))
	var fx := _scan_fx(node)
	player.set_scanner(1.0)
	for i in 5:
		hud.set_prompt(tr("UI_SCANNING") + " " + "▮".repeat(i + 1) + "▯".repeat(4 - i))
		Audio.sfx("radio_beep", -16.0, 1.0 + i * 0.12)
		var t := 0.0
		while t < 0.2:
			_scan_beam(fx)
			await get_tree().process_frame
			t += get_process_delta_time()
	hud.set_prompt("")
	# Bulundu: kısa bir parlama ve çıt sesi
	Audio.sfx("typewriter_bell", -10.0)
	var glow := Props.ball(garage, 0.2, node.global_position + Vector3(0, 0.1, 0), Color("aaffcc"), Vector3.ONE, 10, 3.0)
	glow.material_override = Props.mat(Color(0.67, 1.0, 0.8, 0.5), 3.0, true, "", false)
	var gt := create_tween()
	gt.tween_property(glow, "scale", Vector3.ONE * 3.0, 0.35)
	gt.tween_callback(glow.queue_free)
	fx.queue_free()
	player.set_scanner(0.0)
	_clues[id] = true
	var marker := node.get_node_or_null("Marker")
	if marker:
		marker.queue_free()
	match id:
		"clue:shells":
			await _n("D3_N_SHELLS" if "chickpeas" in GameState.bag else "D3_N_SHELLS_NO")
		"clue:fez":
			await _n("D3_N_FEZ")
		"clue:tape":
			await _n("D3_N_TAPE")
			await _replay_kick()
	hud.set_objective(tr("UI_OBJ3_TRACE") % _clues.size(), _trace_spot(), 0.4)
	if _clues.size() == 3:
		GameState.flags["ch3_trace"] = true
		_sab_stop()
		await _n("D3_N_TRACE_DONE")
		hud.set_objective(tr("UI_OBJ3_HIKMET"), hud.spot("hikmet"), 0.9)
	elif _clues.size() + _lost.size() == 3:
		_sab_stop()
		await _n("D3_N_TRACE_PARTIAL")
		hud.set_objective(tr("UI_OBJ3_HIKMET"), hud.spot("hikmet"), 0.9)
	player.frozen = false
	_busy = false


## Kalkış anının hologramı: Bölüm 1'de tekmeyi kim attıysa o.
func _replay_kick() -> void:
	var tolga_kicked: bool = GameState.chapter_outcomes.get(1, "1.1") == "1.2"
	var k := garage.panel_node.global_position
	var spot := k + Vector3(-0.75, 0, 0.35)
	var holo: Node3D
	if tolga_kicked:
		var p := Person.new({"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez"})
		holo = p
	else:
		holo = Hikmet.new()
	holo.position = spot
	add_child(holo)
	holo.rotation.y = atan2(k.x - spot.x, k.z - spot.z)
	await get_tree().process_frame
	Person.make_hologram(holo)
	_no_interact(holo)
	player.face(spot + Vector3(0.3, 0.9, 0))
	await _wait(0.4)
	if tolga_kicked:
		(holo as Person).kick_hit.connect(func(): player.shake(0.3), CONNECT_ONE_SHOT)
		hud.bark("SPK_NIHAT", "D3_N_HOLO_TOLGA", 3.5)
		await (holo as Person).kick()
	else:
		(holo as Hikmet).kick_hit.connect(func(): player.shake(0.3), CONNECT_ONE_SHOT)
		hud.bark("SPK_NIHAT", "D3_N_HOLO_HIKMET", 3.5)
		await (holo as Hikmet).kick(k, spot)
	await _wait(0.3)
	var tw := create_tween()
	tw.tween_property(holo, "scale", Vector3(1, 0.01, 1), 0.3)
	await tw.finished
	holo.queue_free()
	GameState.flags["ch3_holo"] = "tolga" if tolga_kicked else "hikmet"


# ---------------------------------------------------------------- sorgu

func _interrogation() -> void:
	_sab_stop()
	_busy = true
	phase = "interro"
	if player.powers:
		player.powers.set_flying(false)
		player.powers.set_cloak(false)
	player.frozen = true
	hud.set_objective("")
	var trace: bool = GameState.flags.get("ch3_trace", false)
	# Hikmet çayla gelir, karşılıklı otururlar: iki bardak sandığın üstüne
	var tw := create_tween()
	tw.tween_property(hikmet, "position", Vector3(-1.2, 0, 0.2), 1.0)
	_serve_tea()
	await tw.finished
	hikmet.look_target = player
	player.global_position = Vector3(0.3, 0, 1.2)
	player.face(hikmet.global_position + Vector3(0, 1.35, 0))
	_set_persuade(PERSUADE_BASE + (TRACE_BONUS if trace else 0.0))
	if trace:
		hud.bark("SPK_NIHAT", "D3_N_TRACE_BONUS", 2.5)
	await _h("D3_H_24")
	if _hikmet_saw_fly:
		await _h("D3_H_SAW_FLY_2")
		_set_persuade(_persuade + 10)
	player.show_prop("tea", 2.0)
	var pick: int = {"tea": 2, "confiscate": 0, "seal": 0}.get(GameState.autotest_variant, 1)
	var c := await hud.choose(["UI_CH3_APP_RULE", "UI_CH3_APP_KIND", "UI_CH3_APP_TEA"], 12.0, pick)
	if c == -1:
		await _n("D3_N_FREEZE")
		c = 0
	match c:
		0:
			_approach = "rule"
			_set_persuade(_persuade + 10)
			await _n("D3_N_RULE")
			await _h("D3_H_RULE")
			await _h("D3_H_LIE_RULE")
		1:
			_approach = "kind"
			_set_persuade(_persuade + 15)
			await _n("D3_N_KIND")
			await _h("D3_H_KIND")
			await _h("D3_H_LIE_KIND")
			await _n("D3_N_LIE_KIND_SLIP")
		_:
			_approach = "tea"
			_set_persuade(_persuade + 20)
			_add_loyalty(-15)
			await _n("D3_N_TEA")
			await _h("D3_H_TEA_1")
			await _h("D3_H_TEA_2")
			await _h("D3_H_TEA_3")
			_set_persuade(100)
			await _rule_7c()
			_outcome = "3.5"
			await _n("D3_N_END_35")
			await _h("D3_H_END_35")
			_busy = false
			return

	# Telsiz cızırdar: 1453'ten Tolga. Hikmet panikle "radyo tiyatrosu" der.
	var heard := await _radio_interrupt()
	if heard:
		_set_persuade(100)
	# Yalan: yakala ya da geç (⏱) · bıyık titrer, kalp atışı, kamera yaklaşır
	var caught := heard
	var call := 0
	if not heard:
		await _lie_zoom(true)
		var lie_pick := 1 if GameState.autotest_variant == "lie" else 0
		call = await hud.choose(["UI_CH3_CALL_LIE", "UI_CH3_ACCEPT_LIE"], 7.0, lie_pick)
		_lie_zoom(false)
	if call == 0 and not heard:
		if _eaves:
			await _n("D3_N_EAVES_CALL")
			caught = true
		elif trace:
			await _n("D3_N_EVIDENCE_" + ("TOLGA" if GameState.flags.get("ch3_holo", "hikmet") == "tolga" else "HIKMET"))
			caught = true
		else:
			var roll := randf() * 100.0
			if GameState.autotest:
				roll = 0.0
			caught = roll < _persuade
			await _n("D3_N_CALL")
		if not caught:
			await _h("D3_H_DOUBLE_DOWN")
	if not caught:
		_outcome = "3.4"
		GameState.flags["buro_baskisi"] = int(GameState.flags.get("buro_baskisi", 0)) + 1
		_set_persuade(-1)
		await _n("D3_N_END_34")
		await _h("D3_H_END_34")
		# Nihat gidince Hikmet telsize fısıldar
		player.face(hikmet.global_position + Vector3(0, 1.2, 0))
		await _h("D3_H_END_34B")
		_busy = false
		return

	_set_persuade(100)
	await _h("D3_H_CONFESS_1")
	await _h("D3_H_CONFESS_2")
	await _rule_7c()
	# ⏱ Makineye ne yapılacak?
	var keys := ["UI_CH3_CONFISCATE", "UI_CH3_SEAL"] if _approach == "rule" else ["UI_CH3_CARD", "UI_CH3_SEAL"]
	var dpick: int = {"confiscate": 0, "seal": 1}.get(GameState.autotest_variant, 0)
	var d := await hud.choose(keys, 8.0, dpick)
	var action := "seal"
	if d == 0:
		action = "confiscate" if _approach == "rule" else "card"
	match action:
		"confiscate":
			_outcome = "3.1"
			_add_loyalty(10)
			await _n("D3_N_END_31")
			await _machine_resists()
			await _confiscate_fx()
			await _h("D3_H_END_31")
			await _n("D3_N_END_31B")
		"card":
			_outcome = "3.3"
			_add_loyalty(-10)
			await _n("D3_N_END_33")
			await _h("D3_H_END_33")
			await _n("D3_N_END_33B")
		_:
			_outcome = "3.2"
			await _n("D3_N_END_32")
			await _machine_resists()
			await _seal_fx()
			await _h("D3_H_END_32")
	_busy = false


# ================================================================ heyecan: alarm, karartma, telsiz, direnen makine

## Büro'da kırmızı alarm: paradoks sızıntısı. Koridorda 1453'ten kaçmış bir tavuk, yanıp sönen kırmızı ışıklar,
## asansöre yetişmek için süre. Geç kalırsa Müfide Hanım hoparlörden laf sokar (Sadakat −5).
func _alarm_start() -> void:
	Audio.sfx("ear_ring", -14.0, 0.6)
	for z in [3.0, -2.0, -8.0, -14.0, -20.0, -26.0, -32.0]:
		var l := OmniLight3D.new()
		l.light_color = Color("ff2a1a")
		l.omni_range = 9.0
		l.omni_attenuation = 0.7
		l.position = Vector3(0, 2.9, z)
		# Tavanda dönen kırmızı çakar
		var b := Props.ball(bureau, 0.12, Vector3(0, 3.3, z), Color("ff2a1a"), Vector3(1, 0.6, 1), 8, 3.0)
		b.name = "AlarmBeacon"
		bureau.add_child(l)
		_alarm_lights.append(l)
	var ch := Chicken.new()
	bureau.add_child(ch)
	ch.position = Vector3(0.4, 0, -6.0)
	ch.yard = Rect2(Vector2(-1.5, -31.0), Vector2(3.0, 26.0))
	Props.interactable(ch, "bchicken", Vector3(0.5, 0.6, 0.5), Vector3(0, 0.3, 0))
	await _n("D3_N_ALARM")
	await _m_remote("D3_M_ALARM")
	_clock = 150.0 if not GameState.autotest else 999.0


## Müfide hoparlörden (Büro'da değilse yazı + ses yine çalar).
func _m_remote(key: String) -> void:
	if bureau and bureau.mufide:
		bureau.mufide.talking = true
	await hud.say("SPK_MUFIDE", key)
	if bureau and bureau.mufide:
		bureau.mufide.talking = false


## Garajda delil karartma: çay demlenirken Hikmet "ortalık dağınık" diye ipuçlarını süpürmeye gider. Önce tararsan
## ya da yanına varırsan (1.7 m) bırakır; varırsa ipucu kaybolur.
func _sabotage() -> void:
	_sab_on = true
	await _wait(7.0)
	for id in ["clue:shells", "clue:fez", "clue:tape"]:
		if not _sab_on:
			return
		if _clues.has(id) or _lost.has(id):
			continue
		while _busy and _sab_on:
			await get_tree().process_frame
		if not _sab_on:
			return
		var node: Node3D = _clue_nodes[id]
		var to := node.global_position + (hikmet.global_position - node.global_position).normalized() * 0.5
		to.y = 0.0
		_sab_target = id
		garage.occupied = id == "clue:fez"
		hikmet.look_target = null
		var dir := to - hikmet.global_position
		hikmet.rotation.y = atan2(dir.x, dir.z)
		hud.bark("SPK_HIKMET", "D3_H_SWEEP_" + str(randi() % 3 + 1), 3.0)
		hud.bark("SPK_NIHAT", "D3_N_SWEEP_WARN", 3.0)
		_sab_tw = create_tween()
		_sab_tw.tween_property(hikmet, "position", to, maxf(1.5, dir.length() / 0.9))
		await _sab_tw.finished
		if not _sab_on or _sab_target != id:
			continue
		# Süpürür: eğilip sallanır
		for k in 4:
			if not _sab_on or _sab_target != id or _clues.has(id):
				break
			Audio.sfx("paper_tear", -16.0, 0.6 + k * 0.1)
			await _wait(0.6)
		if _sab_on and _sab_target == id and not _clues.has(id) and not _busy:
			_lost[id] = true
			node.visible = false
			for c in node.get_children():
				if c is StaticBody3D:
					c.queue_free()
			hud.bark("SPK_HIKMET", "D3_H_SWEPT", 3.0)
			await _n("D3_N_CLUE_LOST")
			hud.set_objective(tr("UI_OBJ3_TRACE") % _clues.size(), _trace_spot(), 0.4)
			if _clues.size() + _lost.size() == 3:
				_sab_stop()
				await _n("D3_N_TRACE_PARTIAL")
				hud.set_objective(tr("UI_OBJ3_HIKMET"), hud.spot("hikmet"), 0.9)
				return
		_sab_target = ""
		garage.occupied = false
		# Ocağa döner, bir süre çay bahanesi
		var back := create_tween()
		back.tween_property(hikmet, "position", Vector3(-2.7, 0, -0.9), 1.6)
		await back.finished
		hikmet.look_target = player
		await _wait(5.0)


func _sab_caught() -> void:
	if _sab_cd > 0.0:
		return
	_sab_cd = 6.0
	var id := _sab_target
	_sab_target = ""
	garage.occupied = false
	if _sab_tw and _sab_tw.is_valid():
		_sab_tw.kill()
	hikmet.look_target = player
	hikmet.emote("surprise")
	hud.bark("SPK_HIKMET", "D3_H_SWEEP_CAUGHT", 3.5)
	_add_loyalty(2)
	if id != "":
		var back := create_tween()
		back.tween_property(hikmet, "position", Vector3(-2.7, 0, -0.9), 1.4)


func _sab_stop() -> void:
	if garage:
		garage.occupied = false
	_sab_on = false
	_sab_target = ""
	if _sab_tw and _sab_tw.is_valid():
		_sab_tw.kill()


## Sorgunun ortasında tezgâhtaki Telsiz-Kumanda cızırdar: 1453'ten Tolga. Hikmet "radyo tiyatrosu" diye atlar.
## Telsizi al → itiraf kendiliğinden gelir. Duymamış gibi yap → İkna +10, Sadakat −5, yalan sahnesi sürer.
func _radio_interrupt() -> bool:
	if _radio == null:
		_radio = Node3D.new()
		add_child(_radio)
		_radio.position = TEA_TABLE + Vector3(0.18, 0.45, -0.12)
		Props.box(_radio, Vector3(0.08, 0.14, 0.04), Vector3(0, 0.07, 0), Color("2a2a2a"))
		Props.cyl(_radio, 0.006, 0.18, Vector3(0.025, 0.22, 0), Color("444444"), Vector3.ZERO, 4)
		Props.ball(_radio, 0.015, Vector3(-0.02, 0.12, 0.022), Color("ff3a2a"), Vector3.ONE, 5, 2.0)
	Audio.sfx("radio_static", -6.0)
	var shake := create_tween()
	for k in 6:
		shake.tween_property(_radio, "rotation:z", 0.12 * (1 if k % 2 == 0 else -1), 0.05)
	shake.tween_property(_radio, "rotation:z", 0.0, 0.05)
	await hud.say("SPK_TOLGA", "D3_T_RADIO_1")
	# Hikmet telsize atılır
	hikmet.look_target = null
	var tw := create_tween()
	tw.tween_property(hikmet, "position", _radio.global_position + Vector3(-0.45, -0.45, 0.1), 0.35)
	await tw.finished
	await _h("D3_H_RADIO_2")
	hikmet.look_target = player
	var pick := 0 if GameState.autotest_variant == "radio" else 1
	var c := await hud.choose(["UI_CH3_RADIO_GRAB", "UI_CH3_RADIO_IGNORE"], 6.0, pick)
	if c == 0:
		player.face(_radio.global_position)
		await _n("D3_N_RADIO_GRAB")
		Audio.sfx("radio_beep", -8.0)
		await hud.say("SPK_TOLGA", "D3_T_RADIO_3")
		Audio.sfx("radio_static", -10.0, 0.7)
		await _h("D3_H_RADIO_4")
		player.face(hikmet.global_position + Vector3(0, 1.35, 0))
		GameState.flags["ch3_radio"] = true
		return true
	_set_persuade(_persuade + 10)
	_add_loyalty(-5)
	await _n("D3_N_RADIO_IGNORE")
	return false


## Yalan anı: kamera Hikmet'e yaklaşır, bıyığı titrer, kalp atışı.
func _lie_zoom(on: bool) -> void:
	if GameState.autotest or player.camera == null:
		return
	var tw := create_tween()
	tw.tween_property(player.camera, "fov", 42.0 if on else 75.0, 0.6 if on else 0.4).set_trans(Tween.TRANS_SINE)
	if on:
		for k in 3:
			get_tree().create_timer(0.35 * k).timeout.connect(func(): Audio.sfx("timer_tick", -6.0, 0.7))
		var wob := create_tween()
		for k in 8:
			wob.tween_property(hikmet, "rotation:z", 0.04 * (1 if k % 2 == 0 else -1), 0.07)
		wob.tween_property(hikmet, "rotation:z", 0.0, 0.07)
		await tw.finished


## El koyarken ya da mühürlerken makine direnir: kendi kendine döner, girdap açılır, 1453'ten bir tavuk ve bir ok
## fırlar. Nihat mührü (E) basılı tutarak basar.
func _machine_resists() -> void:
	garage.alarm = true
	garage.spin = 7.0
	Audio.sfx("machine_spin", -4.0)
	var pt := create_tween()
	pt.tween_property(garage, "portal", 0.85, 0.8)
	player.shake(0.4)
	await _wait(0.8)
	var core := Garage.PLATFORM_POS + Vector3(0, 1.3, 0)
	# Ok: girdaptan çıkar, arka duvara saplanır
	var arrow := Node3D.new()
	add_child(arrow)
	Props.cyl(arrow, 0.012, 0.7, Vector3.ZERO, Color("6a4a2c"), Vector3(90, 0, 0), 4)
	Props.prism(arrow, Vector3(0.05, 0.08, 0.05), Vector3(0, 0, 0.38), Color("8a8e96"), Vector3(90, 0, 0))
	arrow.global_position = core
	var hit := Vector3(2.6, 1.7, 2.95)
	arrow.look_at_from_position(core, hit, Vector3.UP)
	arrow.rotate_object_local(Vector3.UP, PI)
	Audio.sfx("whoosh_fly", -4.0, 1.4)
	var at := create_tween()
	at.tween_property(arrow, "global_position", hit - (hit - core).normalized() * 0.3, 0.25)
	at.tween_callback(func(): Audio.sfx("kick_metal", -8.0, 1.6))
	# Tavuk: girdaptan fırlar, garajda kaçışır
	var ch := Chicken.new()
	add_child(ch)
	ch.global_position = core
	ch.flapping = true
	var ct := create_tween()
	ct.tween_property(ch, "global_position", Vector3(-1.4, 0.0, 1.8), 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	ct.tween_callback(func():
		ch.yard = Rect2(Vector2(-3.4, -0.2), Vector2(4.5, 2.6))
		Audio.sfx("chicken", -4.0))
	await _n("D3_N_RESIST")
	# Mührü basılı tut
	if not GameState.autotest:
		var held := 0.0
		var t := 0.0
		while held < 1.6 and t < 10.0:
			var dt := get_process_delta_time()
			t += dt
			if Input.is_action_pressed("interact"):
				held += dt
				player.shake(0.05)
			else:
				held = maxf(0.0, held - dt * 0.5)
			var n := int(held / 1.6 * 10.0)
			hud.set_prompt(tr("UI_CH3_HOLD_STAMP") + "  " + "▮".repeat(n) + "▯".repeat(10 - n))
			await get_tree().process_frame
		hud.set_prompt("")
	Audio.sfx("stamp", 0.0)
	player.shake(0.5)
	var off := create_tween()
	off.tween_property(garage, "portal", 0.0, 0.5)
	garage.alarm = false
	garage.spin = 0.3
	await _h("D3_H_RESIST")


## Nihat uçarken görüldü: Hikmet görürse şaşırır, sorguda İkna +10 (uçan memura yalan zor).
func _on_witnessed(node: Node3D) -> void:
	if node == hikmet and not _hikmet_saw_fly and phase == "garage":
		_hikmet_saw_fly = true
		hikmet.emote("surprise")
		hud.bark("SPK_HIKMET", "D3_H_SAW_FLY", 4.0)


## Görünmez Nihat, Hikmet'in yanına sokuldu: Hikmet kendi kendine plan yapar; yalan önceden duyulur.
## Hikmet'in gözü önünde görünmez olunca: denetçi bir anda yok olmuştur (görünmezlik hissedilsin).
var _veil_seen := false


func _on_veil(on: bool) -> void:
	if not on or _veil_seen or phase != "garage" or hikmet == null or _busy:
		return
	if hikmet.global_position.distance_to(player.global_position) > 9.0:
		return
	_veil_seen = true
	hud.bark("SPK_HIKMET", "D3_H_VANISH", 4.0)


func _on_eavesdrop(node: Node3D) -> void:
	if node == hikmet and phase == "garage" and not _eaves:
		_eaves = true
		hud.bark("SPK_HIKMET", "D3_H_EAVES", 5.0)
		get_tree().create_timer(5.2).timeout.connect(func(): hud.bark("SPK_NIHAT", "D3_N_EAVES", 3.5))


## Hologramın etkileşim alanını kapatır (hologram Hikmet'e "konuş" denmesin).
func _no_interact(node: Node) -> void:
	for c in node.get_children():
		if c is StaticBody3D:
			(c as StaticBody3D).collision_layer = 0
		_no_interact(c)


func _rule_7c() -> void:
	await _n("D3_N_7C_1")
	await _n("D3_N_7C_2")
	await _h("D3_H_7C")
	await _n("D3_N_7C_3")


## 3.1: makineye "EL KONULDU" etiketi, parlayıp Büro deposuna ışınlanır.
func _confiscate_fx() -> void:
	var m := garage.get_node("Zamanator") as Node3D
	var tag := Props.label(m, tr("UI_CH3_TAG_CONFISCATED"), Vector3(0, 1.3, 1.05), 40, Color("ff5a4a"), Vector3.ZERO, 1.4)
	tag.outline_size = 8
	await _wait(0.6)
	var tw := create_tween()
	tw.tween_property(garage.machine_light, "light_energy", 12.0, 0.5)
	tw.parallel().tween_property(m, "scale", Vector3(0.01, 1.4, 0.01), 0.6).set_ease(Tween.EASE_IN)
	await tw.finished
	m.visible = false
	garage.panel_node.visible = false
	garage.machine_light.light_energy = 0.0
	player.shake(0.6)
	GameState.flags["machine"] = "confiscated"


## 3.2: halkalara çapraz kırmızı "MÜHÜRLÜDÜR" bantları.
func _seal_fx() -> void:
	var m := garage.get_node("Zamanator") as Node3D
	for a in [-35.0, 35.0]:
		Props.box(m, Vector3(2.3, 0.14, 0.02), Vector3(0, 1.25, 1.13), Color("c8323a"), Vector3(0, 0, a))
	var tag := Props.label(m, tr("UI_CH3_TAG_SEALED"), Vector3(0, 1.25, 1.16), 36, Color("fff3d8"), Vector3.ZERO, 1.0)
	tag.outline_size = 8
	garage.spin = 0.0
	player.shake(0.3)
	GameState.flags["machine"] = "sealed"
	await _wait(0.5)


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	hud.meters.set_persuade(-1)
	var rel: int = {"3.1": -2, "3.2": -1, "3.3": 0, "3.4": 0, "3.5": 1}[_outcome]
	GameState.flags["hn_rel"] = rel
	if not GameState.flags.has("machine"):
		GameState.flags["machine"] = "free"
	if _outcome in ["3.3", "3.5"]:
		GameState.flags["nihat_card"] = true
	GameState.set_outcome(3, _outcome)
	# Nihat raporunu daktiloya geçer
	await hud.fade_to(1.0, 0.8)
	var report := tr("UI_CH3_REPORT_" + _outcome.replace(".", "_"))
	await hud.card([[tr("UI_CH3_REPORT_HEAD"), 26, Color("f2e6c9")], [report, 20, Color(1, 1, 1, 0.85)]], 3.2)
	hud.clear_card()
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=3 -> 4 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter4.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter4.tscn")
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW3_TITLE")
	c.nodes = [
		{"id": "brief", "key": "FLOW3_BRIEF", "pos": Vector2(0.5, 0.16)},
		{"id": "depot", "key": "FLOW3_DEPOT", "pos": Vector2(0.5, 0.25)},
		{"id": "trace", "key": "FLOW3_TRACE", "pos": Vector2(0.36, 0.35)},
		{"id": "skip", "key": "FLOW3_SKIP", "pos": Vector2(0.64, 0.35)},
		{"id": "interro", "key": "FLOW3_INTERRO", "pos": Vector2(0.5, 0.45)},
		{"id": "rule", "key": "FLOW3_RULE", "pos": Vector2(0.3, 0.55)},
		{"id": "kind", "key": "FLOW3_KIND", "pos": Vector2(0.7, 0.55)},
		{"id": "3.1", "key": "FLOW_3_1", "pos": Vector2(0.1, 0.68), "outcome": true},
		{"id": "3.2", "key": "FLOW_3_2", "pos": Vector2(0.3, 0.68), "outcome": true},
		{"id": "3.4", "key": "FLOW_3_4", "pos": Vector2(0.5, 0.68), "outcome": true},
		{"id": "3.3", "key": "FLOW_3_3", "pos": Vector2(0.7, 0.68), "outcome": true},
		{"id": "3.5", "key": "FLOW_3_5", "pos": Vector2(0.9, 0.68), "outcome": true},
	]
	c.edges = [["brief", "depot"], ["depot", "trace"], ["depot", "skip"], ["trace", "interro"], ["skip", "interro"],
		["interro", "rule"], ["interro", "kind"], ["interro", "3.5"],
		["rule", "3.1"], ["rule", "3.2"], ["rule", "3.4"], ["kind", "3.3"], ["kind", "3.2"], ["kind", "3.4"]]
	for id in ["brief", "depot", "interro"]:
		c.taken[id] = true
	c.taken["trace" if GameState.flags.get("ch3_trace", false) else "skip"] = true
	if _approach in ["rule", "kind"]:
		c.taken[_approach] = true
	c.taken[_outcome] = true
	for id in ["3.1", "3.2", "3.3", "3.4", "3.5"]:
		if GameState.has_seen(id):
			c.seen[id] = true
	var rel: int = GameState.flags.get("hn_rel", 0)
	c.footer_lines = [
		tr("UI_FLOW3_STATS") % [int(_loyalty()), tr(REL_NAMES[rel]), int(GameState.flags.get("buro_baskisi", 0))],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW3_NEXT"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ etkileşim

func _on_focus(id: String) -> void:
	var p := ""
	if not _busy and phase in ["office", "bureau", "garage"]:
		if id == "file" and not _done.has("file"):
			p = tr("UI_PROMPT3_FILE")
		elif id == "mufide" and _done.has("file") and not _done.has("mufide"):
			p = tr("UI_PROMPT3_TALK") % tr("SPK_MUFIDE")
		elif id == "riza" and _done.has("mufide") and not _done.has("riza"):
			p = tr("UI_PROMPT3_TALK") % tr("SPK_RIZA")
		elif id == "lift" and _done.has("riza"):
			p = tr("UI_PROMPT3_LIFT")
		elif id.begins_with("clue:") and not _clues.has(id):
			p = tr("UI_PROMPT3_SCAN")
		elif id == "hikmet" and phase == "garage":
			p = tr("UI_PROMPT3_INTERRO")
		elif id in ["formz1", "clock", "window", "plant", "fezshelf", "bchicken"] or id.begins_with("door:"):
			p = tr("UI_PROMPT3_LOOK")
	hud.set_prompt(p)


func _on_interact(id: String) -> void:
	if _busy:
		return
	if id == "file" and not _done.has("file"):
		_take_file()
	elif id == "mufide" and _done.has("file") and not _done.has("mufide"):
		_briefing()
	elif id == "mufide" and _done.has("mufide"):
		hud.bark("SPK_MUFIDE", "D3_M_IDLE", 3.0)
	elif id == "riza" and _done.has("mufide") and not _done.has("riza"):
		_depot()
	elif id == "riza":
		hud.bark("SPK_RIZA", "D3_R_IDLE", 3.0)
	elif id == "lift" and _done.has("riza"):
		_lift()
	elif id == "lift":
		hud.bark("SPK_NIHAT", "D3_N_LIFT_EARLY", 3.0)
	elif id.begins_with("clue:"):
		_scan(id)
	elif id == "hikmet" and phase == "garage":
		_done["hikmet"] = true
		_interrogation()
	elif id == "bchicken":
		hud.bark("SPK_NIHAT", "D3_N_CHICKEN", 3.5)
	elif id.begins_with("door:"):
		var key := "D3_N_DOOR_" + id.trim_prefix("door:").replace(" ", "_")
		if tr(key) == key:
			key = "D3_N_DOOR"
		hud.bark("SPK_NIHAT", key, 3.5)
	elif id in ["formz1", "clock", "window", "plant", "fezshelf"]:
		hud.bark("SPK_NIHAT", "D3_N_LOOK_" + id.to_upper(), 4.5)
		if id == "formz1":
			GameState.flags["seen_z1"] = true
	_on_focus(player.focus_id)


# ================================================================ yardımcılar

func _n(key: String) -> void:
	await hud.say("SPK_NIHAT", key)


func _h(key: String) -> void:
	hikmet.talking = true
	await hud.say("SPK_HIKMET", key)
	hikmet.talking = false


func _m(key: String) -> void:
	bureau.mufide.talking = true
	await hud.say("SPK_MUFIDE", key)
	bureau.mufide.talking = false


func _say(speaker: String, key: String) -> void:
	var who: Person = bureau.riza if speaker == "SPK_RIZA" and bureau else null
	if who:
		who.talking = true
	await hud.say(speaker, key)
	if who:
		who.talking = false


func _wait(s: float) -> void:
	if GameState.autotest:
		await get_tree().process_frame
		return
	await get_tree().create_timer(s).timeout


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ================================================================ otomatik test

func _autotest_report() -> void:
	var expected: String = {"": "3.3", "next": "3.3", "tea": "3.5", "confiscate": "3.1", "seal": "3.2", "lie": "3.4", "radio": "3.3"}[GameState.autotest_variant]
	var ok := _outcome == expected
	if not ok:
		printerr("AUTOTEST: beklenen sonuç %s, gelen %s" % [expected, _outcome])
	if GameState.chapter_outcomes.get(3, "") != _outcome:
		ok = false
		printerr("AUTOTEST: bölüm sonucu kaydedilmedi")
	if GameState.autotest_variant == "radio" and not GameState.flags.get("ch3_radio", false):
		ok = false
		printerr("AUTOTEST: telsiz sahnesi oynanmadı")
	var trace_expected := GameState.autotest_variant != "lie"
	if GameState.flags.get("ch3_trace", false) != trace_expected:
		ok = false
		printerr("AUTOTEST: Paradoks İzi durumu yanlış")
	print("AUTOTEST %s chapter=3 variant=%s outcome=%s sadakat=%d rel=%d baski=%d machine=%s" % [
		"PASS" if ok else "FAIL", GameState.autotest_variant, _outcome, int(_loyalty()),
		int(GameState.flags.get("hn_rel", 0)), int(GameState.flags.get("buro_baskisi", 0)), GameState.flags.get("machine", "")])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(file_name: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file_name))
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	await get_tree().create_timer(0.6).timeout
	# 1. Nihat'ın odası: Form Z-1
	bureau.file_node.visible = true
	player.global_position = Vector3(0.6, 0, 2.2)
	player.face(Vector3(0, 1.7, 6.0))
	_objective("UI_OBJ3_FILE", hud.spot("file"), 0.3)
	hud.bark("SPK_NIHAT", "D3_N_LOOK_FORMZ1", 30.0)
	await _shot("c3_01_oda.png")
	# 2. Sonsuz koridor
	_objective("UI_OBJ3_MUFIDE", hud.spot("mufide"), 0.9)
	player.global_position = Vector3(0.9, 0, -2.0)
	player.face(Vector3(0, 1.4, -40.0))
	hud.bark("SPK_NIHAT", "D3_N_DOOR", 30.0)
	await _shot("c3_02_koridor.png")
	# 3. Başdenetçi
	player.global_position = Vector3(0.3, 0, Bureau.DESK_Z + 2.6)
	player.face(bureau.mufide.global_position + Vector3(0, 1.3, 0))
	hud.bark("SPK_MUFIDE", "D3_M_05", 30.0)
	await _shot("c3_03_mufide.png")
	# 4. Kostüm deposu
	hud.set_fez(true)
	bureau.fedora_node.visible = true
	player.global_position = Vector3(1.2, 0, -12.6)
	player.face(bureau.riza.global_position + Vector3(0.3, 1.2, -1.2))
	hud.bark("SPK_RIZA", "D3_R_13", 30.0)
	await _shot("c3_04_depo.png")
	# 5. Garaj: hologram tekme
	_load_garage()
	await get_tree().create_timer(0.3).timeout
	hud.set_objective(tr("UI_OBJ3_TRACE") % 2)
	var k := garage.panel_node.global_position
	var spot := k + Vector3(-0.75, 0, 0.35)
	var holo := Hikmet.new()
	holo.position = spot
	add_child(holo)
	holo.rotation.y = atan2(k.x - spot.x, k.z - spot.z)
	await get_tree().process_frame
	Person.make_hologram(holo)
	player.global_position = Vector3(-0.4, 0, 0.9)
	player.face(spot + Vector3(0.2, 0.8, 0))
	holo.kick(k, spot)
	await holo.kick_hit
	Engine.time_scale = 0.0
	hud.bark("SPK_NIHAT", "D3_N_HOLO_HIKMET", 30.0)
	await _shot("c3_05_iz.png")
	Engine.time_scale = 1.0
	holo.queue_free()
	# 6. Sorgu
	hud.set_objective("")
	hikmet.position = Vector3(-1.2, 0, 0.2)
	player.global_position = Vector3(0.3, 0, 1.2)
	player.face(hikmet.global_position + Vector3(0, 1.35, 0))
	_set_persuade(45)
	hud.meters.set_persuade(60)
	hud.choose(["UI_CH3_APP_RULE", "UI_CH3_APP_KIND", "UI_CH3_APP_TEA"], 12.0)
	await get_tree().create_timer(1.2).timeout
	await _shot("c3_06_sorgu.png")
	hud.choose_cancel()
	# 7. Mühür
	_seal_fx()
	hud.meters.set_persuade(-1)
	player.global_position = Vector3(0.9, 0, 1.4)
	player.face(Garage.PLATFORM_POS + Vector3(0, 1.2, 0))
	hud.bark("SPK_HIKMET", "D3_H_END_32", 30.0)
	await get_tree().create_timer(0.6).timeout
	await _shot("c3_07_muhur.png")
	# 8. Akış şeması
	_outcome = "3.3"
	_approach = "kind"
	GameState.flags["ch3_trace"] = true
	GameState.flags["hn_rel"] = 0
	GameState.seen_outcomes["3.5"] = true
	hud.set_fez(false)
	hud.add_child(_make_chart())
	await _shot("c3_08_akis.png")
	get_tree().quit()
