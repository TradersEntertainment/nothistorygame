extends Node3D
## Bölüm 2 — Yağlı Kızaklar (CHAPTERS.md, Bölüm 2).
## Gökten düşüş → telsiz (Telsiz Bağı) → kızak kaçışı (şerit, zıplama, kadırga kovalar,
## iade garantisi geri sayar) → Haliç: kıyı mı zincir mi (süreli) → sonuç → akış şeması.
##
## Sonuçlar: 2.1 kıyıda yakalandı · 2.2 kıyıya gizlice çıktı (hiç tökezlemeden)
##           2.3 zincire ulaştı · 2.4 zincirden düştü · 2.5 kırmızı düğme (garanti içinde)
##
## Test: --chapter=2 --autotest[=perfect|chain|chainfail|red]

const RUN_SPEED := 7.4
const SHIP_SPEED := 6.6
const START_S := 14.0
const START_GAP := 13.0
const BOW := 9.9                 # kadırga merkezinden pruvaya
const CHECKPOINTS := [14.0, 50.0, 88.0]
const WARRANTY_WARN_S := 36.0
const WARRANTY_END_S := 70.0      # Hikmet'in "garanti bitti"si kızağın ucundaki "yokuş bitiyor"dan önce bitsin
const RED_HOLD_SECONDS := 3.0

var level: Slipway
var player: Player
var hud: Hud

var _underwater := false
var phase := "intro"        # intro, run, caught, swim, done
var lane := 1
var ship_s := 0.0
var stumble_t := 0.0
var hits := 0
var red_hold := 0.0
var warranty := true
var _warned := false
var _edge_said := false
var _after_warranty_said := false
var _stumble_i := 0
var _outcome := ""
var _arrow_hits := 0
var _shore_props: Array = []
var _priority_until := 0.0   # önemli telsiz satırı (garanti) bitene dek tökezleme repliği onu kesmez


func _ready() -> void:
	GameState.snapshot(2)
	level = Slipway.new()
	add_child(level)
	player = Player.new()
	add_child(player)
	hud = Hud.new()
	add_child(hud)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH2_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH2_SUB"), 20, Color(1, 1, 1, 0.7)]], 1.8)
	hud.clear_card()

	# Gökten düşüş
	ship_s = START_S - START_GAP - BOW
	level.set_ship_s(ship_s)
	player.global_position = level.s_to_world(START_S, 0.0, 6.0)
	player.face(level.s_to_world(START_S + 25.0, 0.0, -4.0))
	_capture_mouse()
	await hud.fade_to(0.0, 0.5)
	await _wait(0.8)
	player.shake(1.2)
	await _wait(0.3)
	player.face(level.s_to_world(ship_s + BOW, 0.0, 2.5))

	await _t("D2_T_01")
	await _h("D2_H_02")
	var radio := await hud.choose(["UI_CHOICE_RADIO_YES", "UI_CHOICE_RADIO_NO"], 4.0, 0)
	GameState.flags["ch2_radio_answered"] = radio == 0
	if radio == 0:
		GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
		hud.set_signal(GameState.telsiz_bag)
		await _h("D2_H_RADIO_YES")
	else:
		await _h("D2_H_RADIO_NO")
	await _t("D2_T_03")
	await _h("D2_H_04")
	await _t("D2_T_05")
	await _say("SPK_SOLDIER", "D2_S_06")
	hud.bark("SPK_HIKMET", "D2_H_07", 1.5)

	# Kızak kaçışı
	player.face(level.s_to_world(START_S + 40.0, 0.0, 1.0))
	# Yavaş makinede diyaloglar fizikten önce bitebilir: oyuncu yere inmeden koşu başlamasın
	var wait := 0
	while not player.is_on_floor() and wait < 120:
		await get_tree().physics_frame
		wait += 1
	phase = "run"
	player.move_mode = "script"
	player.frozen = false
	hud.set_objective(tr("UI_OBJ_RUN"))
	_flash_prompt(GameState.tr_pad("UI_RUN_HINT"), 6.0)
	while phase in ["run", "caught"]:
		await get_tree().process_frame
	if phase == "done":
		return
	await _swim()
	await _end_chapter()


# ================================================================ koşu

func _process(delta: float) -> void:
	if hud == null:
		return
	hud.fez.motion = player.horizontal_speed() * 0.6
	# Sualtı görünümü kameranın gerçek yüksekliğine bağlı (dalış, düşüş)
	var uw := player.camera.global_position.y < level.water_y - 0.02
	if uw != _underwater:
		_underwater = uw
		hud.set_underwater(uw)
		level.set_underwater(uw)
	if phase not in ["done"] and Input.is_action_just_pressed("fez"):
		var on: bool = not GameState.flags.get("fez", true)
		GameState.flags["fez"] = on
		hud.set_fez(on)
	if phase == "run":
		_run_step(delta)
		_red_button(delta)


## Fizik adımında: halatın üstünden havada geçildiyse işaretle (kare takılsa bile adil olsun);
## test botu da burada karar verir, yavaş makinede kare atlanınca engeli kaçırmasın.
func _physics_process(_delta: float) -> void:
	if phase != "run" or hud == null:
		return
	var s := level.world_to_s(player.global_position)
	if GameState.autotest:
		_auto_step(s)
	for o in level.obstacles:
		if not o["resolved"] and o["kind"] == "rope" and o["s"] - s <= 0.8 and o["s"] - s > -1.5 and not player.is_on_floor():
			o["cleared"] = true


func _run_step(delta: float) -> void:
	var s := level.world_to_s(player.global_position)
	var x := level.world_to_x(player.global_position)
	if Input.is_action_just_pressed("move_left"):
		lane = maxi(0, lane - 1)
	if Input.is_action_just_pressed("move_right"):
		lane = mini(2, lane + 1)
	stumble_t = maxf(0.0, stumble_t - delta)
	var speed := RUN_SPEED * (0.35 if stumble_t > 0.0 else 1.0)
	var side := level.track.global_transform.basis.x.normalized()
	var target_x: float = Slipway.LANES[lane]
	player.script_velocity = level.down_dir() * speed + side * (target_x - x) * 7.0

	# Kadırga: sabit hızla gelir, çok geride kalırsa yetişir
	ship_s += SHIP_SPEED * delta
	ship_s = maxf(ship_s, s - BOW - 22.0)
	level.set_ship_s(ship_s)
	var gap := s - (ship_s + BOW)
	hud.set_chase(tr("UI_CHASE"), 1.0 - clampf(gap / START_GAP, 0.0, 1.0))

	# Engeller
	var prompt := ""
	for o in level.obstacles:
		if o["resolved"]:
			continue
		var ds: float = o["s"] - s
		if ds <= 0.0:
			o["resolved"] = true
			var hit := false
			if o["kind"] == "rope":
				hit = player.is_on_floor() and not o.get("cleared", false)
			else:
				hit = lane in o["lanes"]
			if hit:
				_stumble(o)
		elif ds < 12.0 and prompt == "":
			# Halat: havada ~5.4 m gidilir; istem geçerli sıçrama aralığında çıkar (erken basan tökezlemesin)
			if o["kind"] == "rope":
				if ds < 6.0:
					prompt = GameState.tr_pad("UI_QTE_JUMP")
			elif lane in o["lanes"]:
				prompt = GameState.tr_pad("UI_QTE_DODGE")
	hud.set_qte(prompt)

	# İade garantisi
	if not _warned and s > WARRANTY_WARN_S:
		_warned = true
		hud.bark("SPK_HIKMET", "D2_H_WARRANTY", 3.5)
		_priority_until = _now() + _voice_len("D2_H_WARRANTY", 3.5)
	if warranty and s > WARRANTY_END_S:
		warranty = false
		hud.bark("SPK_HIKMET", "D2_H_WARRANTY_END", 3.0)
		_priority_until = _now() + _voice_len("D2_H_WARRANTY_END", 3.0)
		# Basılı tutma yarıda kaldıysa çubuk ve tetik görseli sıfırlansın
		red_hold = 0.0
		hud.set_red_progress(0.0)
		player.press_red(0.0)

	# Kızağın ucu: "Yokuş bitiyor... Yokuş bitti!" tam kenarda biter, çığlık havada başlar (_plunge)
	if not _edge_said and s >= Slipway.LENGTH - 1.0 - RUN_SPEED * _edge_lead():
		_edge_said = true
		if GameState.autotest:
			print("EDGELINE s=%.1f lead=%.2f" % [s, _edge_lead()])
		hud.bark("SPK_TOLGA", "D2_T_FALL", 1.6)

	if gap < 0.8:
		_caught(s)
	elif s >= Slipway.LENGTH - 1.0:
		phase = "swim"


## "Yokuş bitti!" kenarda bitsin diye replik kenardan bu kadar saniye önce başlar (kaydın uzunluğu).
func _edge_lead() -> float:
	var vs := hud.voice_stream("D2_T_FALL")
	return clampf(vs.get_length(), 1.0, 4.8) if vs else 1.4


func _stumble(o: Dictionary) -> void:
	hits += 1
	if GameState.autotest:
		print("STUMBLE kind=%s s=%.1f lanes=%s lane=%d floor=%s fps=%d" % [o["kind"], o["s"], o.get("lanes", []), lane, player.is_on_floor(), Engine.get_frames_per_second()])
	stumble_t = 0.9
	player.shake(1.0)
	player.flail(0.7)
	var lines := ["D2_T_STUMBLE_1", "D2_T_STUMBLE_2", "D2_T_STUMBLE_3"]
	var line: String = lines[_stumble_i % lines.size()]
	_stumble_i += 1
	# Garanti uyarısı sürerken üstüne konuşulmaz
	if _now() < _priority_until:
		return
	# Önce asker bağırır (halat, kütük, yol kesen asker), Tolga'nın repliği onun bitişine bağlanır
	var shout: String = {"rope": "D2_S_ROPE", "log": "D2_S_LOG", "block": "D2_S_BLOCK"}.get(o["kind"], "")
	if shout != "" and _stumble_i <= 2:
		hud.bark("SPK_SOLDIER", shout, 1.4)
		_delayed_bark(_voice_len(shout, 1.2) + 0.1, "SPK_TOLGA", line, 2.2)
	else:
		hud.bark("SPK_TOLGA", line, 2.2)


func _caught(s: float) -> void:
	phase = "caught"
	hits += 1
	player.frozen = true
	hud.set_qte("")
	await hud.fade_to(1.0, 0.3)
	await hud.card([[tr(GameState.line_variant("UI_CAUGHT_SHIP")), 24, Color(1, 1, 1, 0.9)]], 2.4)
	hud.clear_card()
	var cp: float = CHECKPOINTS[0]
	for c in CHECKPOINTS:
		if c <= s:
			cp = c
	player.global_position = level.s_to_world(cp, 0.0, 0.4)
	player.velocity = Vector3.ZERO
	player.face(level.s_to_world(cp + 30.0, 0.0, -2.0))
	ship_s = cp - START_GAP - BOW
	level.set_ship_s(ship_s)
	level.reset_obstacles_after(cp)
	lane = 1
	stumble_t = 0.0
	await hud.fade_to(0.0, 0.5)
	player.frozen = false
	phase = "run"


func _red_button(delta: float) -> void:
	var pressed := Input.is_action_pressed("red_button")
	if GameState.autotest and GameState.autotest_variant == "red" and level.world_to_s(player.global_position) > 30.0:
		pressed = true
	if not warranty:
		# Garanti sonrası basış: sinyal Hikmet'e bir kez gider (Bölüm 4 ile aynı bayrak; §2.2 "en fazla bir kez")
		if pressed and not _after_warranty_said:
			_after_warranty_said = true
			player.press_red(1.0)
			get_tree().create_timer(0.3, false).timeout.connect(func(): player.press_red(0.0))
			if GameState.flags.get("red_after_warranty", false):
				hud.bark("SPK_HIKMET", "D4_H_RED_AGAIN", 3.0)
			else:
				GameState.flags["red_after_warranty"] = true
				GameState.telsiz_bag = mini(5, GameState.telsiz_bag + 1)
				hud.set_signal(GameState.telsiz_bag)
				hud.bark("SPK_HIKMET", "D4_H_RED", 3.5)
		return
	if pressed:
		red_hold += delta
	else:
		red_hold = maxf(0.0, red_hold - delta * 2.0)
	hud.set_red_progress(red_hold / RED_HOLD_SECONDS)
	player.press_red(red_hold / RED_HOLD_SECONDS)
	if red_hold >= RED_HOLD_SECONDS:
		red_hold = 0.0
		_early_end()


func _early_end() -> void:
	phase = "done"
	player.frozen = true
	hud.set_red_progress(0.0)
	hud.set_qte("")
	hud.set_chase("", 0.0)
	hud.set_objective("")
	await hud.fade_to(1.0, 0.3, Color.WHITE)
	await _wait(0.6)
	await hud.fade_to(1.0, 0.4)
	await _h("D2_H_24")
	_outcome = "2.5"
	GameState.set_last_final("red_button")
	await hud.card([[tr("UI_EARLY_END"), 26, Color(1, 1, 1, 0.9)]], 3.0)
	hud.clear_card()
	await _end_chapter()


# ================================================================ Haliç

func _swim() -> void:
	player.frozen = true
	player.move_mode = "walk"
	player.gravity_on = false
	player.velocity = Vector3.ZERO
	hud.set_chase("", 0.0)
	hud.set_qte("")
	hud.set_objective("")
	hud.set_red_progress(0.0)
	await _plunge()
	_place_watchers()
	await _t("D2_T_08")
	await _h("D2_H_09")
	hud.set_objective(tr("UI_OBJ_SWIM"))
	var pick := 1 if GameState.autotest_variant in ["chain", "chainfail", "swimchain"] else 0
	var c := await hud.choose(["UI_CHOICE_SHORE", "UI_CHOICE_CHAIN"], 8.0, pick)
	hud.set_objective("")
	if c == -1:
		await _t("D2_T_CURRENT")
		c = 0
	if c == 0:
		await _to_shore()
	else:
		await _to_chain()


## Kızağın ucundan Haliç'e: fırlayış, havada süzülme, suya çarpma, sualtı, yüzeye çıkış.
## Kesme yok: kamera baştan sona oyuncunun gözünde kalır.
func _plunge() -> void:
	level.stop_haul()
	var p0 := player.global_position
	var fwd := level.down_dir()
	fwd.y = 0.0
	fwd = fwd.normalized()
	var land := level.swim_start()
	var surf := Vector3(land.x, level.water_y - Player.EYE, land.z)
	var under := surf + Vector3(0, -1.5, 0) + fwd * 1.2
	var peak := p0.lerp(surf, 0.35) + Vector3(0, 2.2, 0)
	# Çığlık kalkışta başlar, suya çarpınca yarıda kesilir; kollar havada savrulur
	hud.bark("SPK_TOLGA", "D2_T_FALL_SCREAM", 3.0)
	player.flail(1.4)
	# Kadırga da kızağın ucuna kadar gelir, burnu suyun üstünde durur
	var ship_tw := create_tween()
	ship_tw.tween_method(func(v: float):
		ship_s = v
		level.set_ship_s(v), ship_s, Slipway.LENGTH - BOW + 1.5, 2.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# Havada: yay çizerek düşer, kamera suya bakar
	var pitch0 := player.camera.rotation.x
	var air := create_tween()
	air.tween_method(func(t: float):
		var a := p0.lerp(peak, t)
		var b := peak.lerp(surf, t)
		player.global_position = a.lerp(b, t)
		player.camera.rotation.x = lerpf(pitch0, -0.8, smoothstep(0.1, 0.9, t)), 0.0, 1.0, 1.25).set_trans(Tween.TRANS_LINEAR)
	await air.finished
	# Şap! Çığlık suyla kesilir
	hud.cut_voice()
	Audio.sfx("splash", -1.0, 0.85)
	level.splash(surf + fwd * 0.5, true)
	player.shake(0.8)
	var down := create_tween()
	down.tween_property(player, "global_position", under, 0.45).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	down.parallel().tween_property(player.camera, "rotation:x", -0.2, 0.45)
	await down.finished
	level.bubbles(under + Vector3(0, Player.EYE, 0) + fwd * 0.6, 1.0)
	# Yüzeye dönerken şehre doğru döner
	var look := land + Vector3(-10, 1.5, -60)
	var to := look - surf
	var yaw := atan2(-to.x, -to.z)
	var yaw0 := player.rotation.y
	await _wait(0.7)
	var up := create_tween()
	up.tween_property(player, "global_position", surf + Vector3(0, -0.1, 0), 0.7).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	up.parallel().tween_method(func(t: float): player.rotation.y = lerp_angle(yaw0, yaw, t), 0.0, 1.0, 0.9)
	up.parallel().tween_property(player.camera, "rotation:x", 0.05, 0.9)
	await up.finished
	level.splash(surf + Vector3(0, 0, -0.6) - fwd * 0.2)
	Audio.sfx("splash", -10.0, 1.3)
	var rise := create_tween()
	rise.tween_property(player, "global_position", _water(land), 0.3).set_ease(Tween.EASE_OUT)
	await rise.finished
	player.floating = true
	player.face(look)


func _water(p: Vector3) -> Vector3:
	return Vector3(p.x, level.water_y - Player.EYE + 0.25, p.z)


func _swim_to(target: Vector3, seconds: float) -> void:
	player.face(Vector3(target.x, level.water_y + 1.0, target.z))
	if GameState.autotest:
		player.global_position = target
		await get_tree().process_frame
		return
	var tw := create_tween()
	tw.tween_property(player, "global_position", target, seconds).set_trans(Tween.TRANS_SINE)
	await tw.finished


func _to_shore() -> void:
	GameState.flags["ch2_route"] = "shore"
	var landing := _shore_landing()
	var goal := _water(_shore_water(landing))
	if _scripted_swim():
		await _swim_to(goal, 3.0)
	else:
		await _swim_free(goal, "shore")
	player.floating = false
	await hud.fade_to(1.0, 0.35)
	_land_on_shore()
	player.face(_shore_look(landing))
	if hits == 0:
		_outcome = "2.2"
		GameState.flags["ch2_sneaked"] = true
		# Hasan ile Hüseyin ilerde kendi aralarında konuşur (yüzerken de oradaydılar); Tolga'yı görmezler
		await hud.fade_to(0.0, 0.45)
		await _say("SPK_HASAN", "D2_HA_11")
		await _say("SPK_HUSEYIN", "D2_HU_12")
		await _say("SPK_HASAN", "D2_HA_13")
		await _t("D2_T_10")
	else:
		_outcome = "2.1"
		# Yakalayanlar kameranın önünde, yüzleri görünür: kıyıya çıkan oyuncunun 2-3 m önünde
		_show_watchers(false)
		var guards := _shore_guards(landing, _shore_look(landing))
		await hud.fade_to(0.0, 0.45)
		await _say("SPK_SOLDIER", "D2_S_14" if GameState.flags.get("fez", true) else "D2_S_14_NOFEZ")
		await _t("D2_T_15")
		await _say("SPK_SOLDIER", "D2_S_16")
		for g in guards:
			g.queue_free()
		await _budget()


## Kıyıya çıkış: oyuncu kuru zemine oturur ve yer çekimi açılır (suda kapalı kalmıştı).
func _land_on_shore() -> Vector3:
	var landing := _shore_landing()
	player.global_position = landing
	player.gravity_on = true
	return landing


var _landing := Vector3.INF

## Kıyıda çıkılacak yer (bir kez seçilir). Kızağın ucunun yanındaki kıyı dik ve tezgâhlarla dolu: suyun hemen
## üstündeki, düz, üstü ve önü boş ilk yer seçilir (eskiden su altındaki kuma, sonra yamaca ve tezgâh altına iniliyordu).
func _shore_landing() -> Vector3:
	if _landing != Vector3.INF:
		return _landing
	var sp := level.shore_point()
	var first := Vector3.INF
	for dx: float in [1.5, -1.5, 4.5, 7.5, 10.5, 13.5, 16.5, 19.5, -27.0, -30.0, -24.0, -33.0, -21.0, -36.0]:
		var p := Vector3(sp.x + dx, 0.0, sp.z + 3.2)
		for i in 60:
			if _ground_y(p.x, p.z) > level.water_y + 0.25:
				break
			p.z += 0.5
		p.z += 1.0
		p.y = _ground_y(p.x, p.z) + 0.05
		if first == Vector3.INF:
			first = p
		if _spot_clear(p):
			_landing = p
			break
	if _landing == Vector3.INF:
		_landing = first
	if GameState.autotest:
		print("SHORE landing=%s fallback=%s" % [_landing, _landing == first and not _spot_clear(first)])
	return _landing


## Çıkış yerinin önündeki su (yüzme hedefi): kıyıdan suya doğru (-z) yeterince derin ilk nokta.
func _shore_water(landing: Vector3) -> Vector3:
	var p := landing
	for i in 40:
		if _ground_y(p.x, p.z) < level.water_y - 0.6:
			break
		p.z -= 0.5
	return p + Vector3(0, 0, -1.5)


## Kıyıdaki Hasan ile Hüseyin (Slipway'in kıyı askerleri): çıkış yerinin 4-5 m önünde, birbirlerine dönük konuşur.
## Yüzerken de orada görünürler.
func _place_watchers() -> void:
	var landing := _shore_landing()
	var fwd := _shore_look(landing) - landing
	fwd.y = 0.0
	fwd = fwd.normalized()
	var side := Vector3(-fwd.z, 0.0, fwd.x)
	var pos: Array[Vector3] = []
	# Kıyı boyunca çapraz (aynı yükseklik çizgisine yakın): tam yan yana dururlarsa yamaçta biri ötekinin metrelerce altında kalıyordu
	for o: Vector2 in [Vector2(4.0, -0.45), Vector2(4.9, 0.85)]:
		var p := landing + fwd * o.x + side * o.y
		pos.append(Vector3(p.x, _ground_y(p.x, p.z), p.z))
	var w := _watchers()
	for i in mini(2, w.size()):
		w[i].global_position = pos[i]
		w[i].face_toward(pos[1 - i])
	# Konuşurken de birbirlerine bakarlar (HUD konuşanı oyuncuya çeviriyordu: "kimse görmedi" derken Tolga'ya bakıyorlardı)
	if w.size() >= 2:
		w[0].look_target = w[1]
		w[1].look_target = w[0]


func _watchers() -> Array[Node3D]:
	var out: Array[Node3D] = []
	for spk in ["SPK_HASAN", "SPK_HUSEYIN"]:
		for c in level.get_children():
			if c is Soldier and c.get_meta("spk", "") == spk:
				out.append(c)
				break
	return out


func _show_watchers(on: bool) -> void:
	for w in _watchers():
		w.visible = on


## Zeminin gerçek yüksekliği (çarpışma yüzeyi: kumsal döşemesi, tepe); bulunmazsa çizilen arazi.
## Görünmeyen çarpışma kutuları ve insanlar atlanır (zemin denetimi gibi: hud._ground_audit).
func _ground_y(x: float, z: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(Vector3(x, level.water_y + 40.0, z), Vector3(x, level.water_y - 6.0, z))
	q.exclude = [player.get_rid()]
	var space := get_world_3d().direct_space_state
	for tries in 8:
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			break
		var col = hit["collider"]
		if col is CollisionObject3D and (hud._is_person_part(col) or (not hud._is_visible_occluder(col) and not (col as Node).has_meta("ground"))):
			q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
			continue
		return (hit["position"] as Vector3).y
	return level.surface_h(x, z)


## Oyuncunun durduğu yerin üstü ve önündeki 5 m boş mu (tezgâh, çatı, ağaç yok).
func _spot_clear(p: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	var sq := PhysicsShapeQueryParameters3D.new()
	var ball := SphereShape3D.new()
	ball.radius = 0.8
	sq.shape = ball
	sq.transform = Transform3D(Basis(), p + Vector3(0, 1.4, 0))
	sq.exclude = [player.get_rid()]
	if not space.intersect_shape(sq, 1).is_empty():
		return false
	# Düz zemin: yamaçta askerler oyuncunun bir metre altında kalıyor, yamaç kadrajın yarısını kapatıyordu
	var fwd0 := _shore_look(p) - p
	fwd0.y = 0.0
	fwd0 = fwd0.normalized()
	var side0 := Vector3(-fwd0.z, 0.0, fwd0.x)
	for o: Vector3 in [fwd0 * 2.6 + side0 * 0.9, fwd0 * 2.6 - side0 * 0.9, fwd0 * 4.0 - side0 * 0.45, fwd0 * 4.9 + side0 * 0.85]:
		if absf(_ground_y(p.x + o.x, p.z + o.z) - p.y) > 0.6:
			return false
	# Önündeki askerlerin duracağı şerit: diz, bel ve göz hizasında, ortada ve iki yanda (tezgâh damı göz hizasının altında kalabiliyor)
	var fwd := _shore_look(p) - p
	fwd.y = 0.0
	fwd = fwd.normalized()
	var side := Vector3(-fwd.z, 0.0, fwd.x)
	for h: float in [0.5, 1.0, Player.EYE]:
		for k: float in [-1.0, 0.0, 1.0]:
			var from := p + Vector3(0, h, 0) + side * (k * 0.9)
			var q := PhysicsRayQueryParameters3D.create(from, from + fwd * 5.5)
			q.exclude = [player.get_rid()]
			if not space.intersect_ray(q).is_empty():
				return false
	# Çarpışması olmayan görünür nesneler (tezgâh damı, sundurma): önündeki 5 m'lik kutuya giren küçük bir model var mı
	var box := AABB(p + Vector3(0, 0.25, 0), Vector3.ZERO)
	for f: float in [0.6, 5.5]:
		for k: float in [-1.3, 1.3]:
			box = box.expand(p + fwd * f + side * k + Vector3(0, 0.25, 0))
			box = box.expand(p + fwd * f + side * k + Vector3(0, 2.3, 0))
	if _shore_props.is_empty():
		for n in level.find_children("*", "GeometryInstance3D", true, false):
			_shore_props.append(n)
	for n: GeometryInstance3D in _shore_props:
		if not n.is_visible_in_tree():
			continue
		var b := n.global_transform * n.get_aabb()
		# Arazi, su, kızak gibi büyük yüzeyler sayılmaz
		if b.size.x > 25.0 or b.size.z > 25.0:
			continue
		if b.intersects(box):
			return false
	return true


## Kıyıda bakılacak nokta: kıyı boyunca, göz hizasının biraz altı (eskiden göğe bakıyordu).
## Kızaktan uzağa, kıyı boyunca bakar (kadırga arkada kalır).
func _shore_look(landing: Vector3) -> Vector3:
	var away := 1.0 if landing.x >= level.end_point().x else -1.0
	return Vector3(landing.x + away * 4.0, landing.y + Player.EYE - 0.45, landing.z - 0.4)


## Kıyıdaki iki asker, oyuncunun bakış yönünde 2.6 m önünde, yanlara ayrılmış; yüzleri kameraya dönük.
func _shore_guards(at: Vector3, look_at_p: Vector3) -> Array[Node3D]:
	var out: Array[Node3D] = []
	var fwd := look_at_p - at
	fwd.y = 0.0
	fwd = fwd.normalized()
	var side := Vector3(-fwd.z, 0.0, fwd.x)
	for k: float in [-1.0, 1.0]:
		var p := at + fwd * 2.6 + side * (k * 0.9)
		var g := Soldier.new(Color("b3262d") if k < 0.0 else Color("2f5fa8"), "point", "bork" if k < 0.0 else "turban")
		level.add_child(g)
		g.global_position = Vector3(p.x, _ground_y(p.x, p.z), p.z)
		g.face_toward(at)
		out.append(g)
	return out


func _to_chain() -> void:
	GameState.flags["ch2_route"] = "chain"
	var start := level.swim_start()
	var cp := level.chain_point()
	var dived := false
	if _scripted_swim():
		dived = await _chain_scripted(start, cp)
	else:
		dived = await _swim_free(_water(cp + Vector3(1.5, 0, 1.5)), "chain")
	if level.in_world:
		# Zincir Haliç'in ağzında (dünyanın zinciri): kıyı boyunca uzun yüzüş, kararmayla geçilir
		await hud.fade_to(1.0, 0.6)
		cp = level.world_chain()
		# Zincirin (yüzen kütük hattının) yanında, ona çaprazdan bakarak: eskiden hattın tam içine konuyordu,
		# kamera kütüklerin oluşturduğu tüpün içinden karanlığa bakıyordu
		var along := level.world_chain_city() - cp
		along.y = 0.0
		along = along.normalized()
		var side := along.cross(Vector3.UP).normalized()
		player.global_position = _water(cp + side * 2.3)
		player.face(Vector3(cp.x, level.water_y + 0.9, cp.z) + along * 14.0)
		await hud.fade_to(0.0, 0.6)
	else:
		player.face(cp + Vector3(20, 1.0, -60))
	# Zincire uzanıp tutunur: sol el kütüğü kavrar, Tolga kendini ona doğru çeker
	var to_me := Vector3(player.global_position.x - cp.x, 0.0, player.global_position.z - cp.z).normalized()
	var grip := Vector3(cp.x, level.water_y + 0.3, cp.z) + to_me * 0.45
	await player.reach_grab(grip)
	var pull := player.global_position.lerp(Vector3(grip.x, player.global_position.y, grip.z), 0.4)
	if GameState.autotest:
		player.global_position = pull
	else:
		var tw := create_tween()
		tw.tween_property(player, "global_position", pull, 0.45).set_trans(Tween.TRANS_SINE)
		await tw.finished
	if dived:
		_outcome = "2.3"
		await _t("D2_T_18")
		await _h("D2_H_19")
		await _t("D2_T_20")
	else:
		_outcome = "2.4"
		GameState.flags["wet"] = true
		# Tutunduğu kütük döner, el kayar: kollar savrulur, Tolga suya gömülüp çıkar
		await _wait(0.5)
		player.release_grab()
		player.flail(1.0)
		player.shake(0.8)
		level.splash(player.global_position)
		Audio.sfx("splash", -6.0)
		await _t("D2_T_22")
		await hud.fade_to(1.0, 0.8)
		# Zincirden düşen oyuncu akıntıyla kıyıya sürüklenir: kararmada bu geçiş açıklanır
		await hud.card([[tr("UI_CH2_CURRENT_BACK"), 24, Color(1, 1, 1, 0.85)]], 2.0)
		hud.clear_card()
		player.floating = false
		var landing := _land_on_shore()
		player.face(_shore_look(landing))
		_show_watchers(false)
		var guards := _shore_guards(landing, _shore_look(landing))
		await hud.fade_to(0.0, 0.8)
		await _say("SPK_SOLDIER", "D2_S_23")
		for g in guards:
			g.queue_free()
		await _budget()


## Otomatik test: eski senaryolu zincir yolu (kayık yandan geçer, zamanında dalış).
func _chain_scripted(start: Vector3, cp: Vector3) -> bool:
	var mid := start.lerp(cp, 0.55)
	await _swim_to(_water(start.lerp(cp, 0.25)), 2.2)
	# Kayık yandan geçer: zamanında dal
	var side := (cp - start).cross(Vector3.UP).normalized()
	level.boat.global_position = Vector3(mid.x, level.water_y, mid.z) + side * 28.0
	level.boat.look_at(Vector3(mid.x, level.water_y, mid.z), Vector3.UP)
	var boat_tw := create_tween()
	boat_tw.tween_property(level.boat, "global_position", Vector3(mid.x, level.water_y, mid.z) - side * 28.0, 3.6)
	var swim_tw := create_tween()
	swim_tw.tween_property(player, "global_position", _water(mid), 3.6)
	var dived := false
	var t := 0.0
	while t < 3.6:
		var dt := get_process_delta_time()
		t += dt
		var in_window := t > 1.2 and t < 2.6
		hud.set_qte(_dive_prompt() if t > 0.9 and t < 2.6 else "")
		var want := Input.is_action_just_pressed("dive") or (GameState.autotest and GameState.autotest_variant == "chain")
		if in_window and want and not dived:
			dived = true
			hud.set_qte("")
			level.splash(player.global_position + Vector3(0, Player.EYE, 0))
			swim_tw.kill()
			var down := create_tween()
			down.tween_property(player, "global_position", _water(mid) + Vector3(0, -1.4, 0), 0.3)
			level.bubbles(_water(mid) + Vector3(0, Player.EYE - 1.2, 0), 1.2)
			await _wait(1.4)
			var up := create_tween()
			up.tween_property(player, "global_position", _water(mid) + Vector3(0, -0.35, 0), 0.3)
			await up.finished
			level.splash(_water(mid) + Vector3(0, Player.EYE, 0))
			var rise := create_tween()
			rise.tween_property(player, "global_position", _water(mid), 0.2)
			await rise.finished
			break
		await get_tree().process_frame
	hud.set_qte("")
	if not dived:
		player.shake(1.2)
		await _say("SPK_ROWER", "D2_R_21")
	await _swim_to(_water(cp + Vector3(1.5, 0, 1.5)), 2.6)
	return dived


# ================================================================ serbest yüzme

const SWIM_SPEED := 0.62         # WALK ile çarpılır: ≈2 m/sn
const CURRENT := Vector3(0.35, 0, 0.12)   # Haliç akıntısı, oyuncuyu yavaşça sürükler
const DIVE_SECONDS := 1.6

var _breath := 1.0
var _dive_t := 0.0
var _swim_found := {}


## Otomatik testte eski senaryolu yüzme; --autotest=swimshore / swimchain serbest yüzmeyi botla dener.
func _scripted_swim() -> bool:
	return GameState.autotest and not GameState.autotest_variant.begins_with("swim")


## Serbest yüzme: WASD yüz, Shift hızlan (nefes yer), CTRL dal (oklardan ve kayıktan korur).
## Kıyı yolunda askerler ok atar (suda halka uyarısı), zincir yolunda devriye kayığı geçer.
## Hedefe varınca döner. Dönüş: kayığa yakalanmadan geçti mi (zincir yolu için).
func _swim_free(goal: Vector3, route: String) -> bool:
	var surface_y := _water(goal).y
	player.floating = true
	player.gravity_on = false
	player.move_mode = "walk"
	player.speed_mult = SWIM_SPEED
	player.frozen = false
	_breath = 1.0
	_dive_t = 0.0
	_capture_mouse()
	hud.set_objective(tr("UI_OBJ_SWIM_SHORE" if route == "shore" else "UI_OBJ_SWIM_CHAIN"), goal + Vector3(0, 1.2, 0))
	_flash_prompt(_swim_hint(), 6.0)
	var start := player.global_position
	var total := Vector2(start.x - goal.x, start.z - goal.z).length()
	var arrow_in := 2.2
	var arrow_every := 2.4 if route == "shore" else 4.2
	var pending: Array = []         # [{pos, t}]
	var boat_state := "idle"        # idle, crossing, done
	var boat_t := 0.0
	var boat_from := Vector3.ZERO
	var boat_to := Vector3.ZERO
	var boat_hit := false
	var bump_cd := 0.0
	var elapsed := 0.0
	var help_said := false
	var bot := GameState.autotest
	if bot:
		Input.action_press("move_forward")
	while true:
		# Menü ya da harita açıkken yüzme durur (kayık, oklar, akıntı, nefes, yardım sayacı)
		if get_tree().paused:
			await get_tree().process_frame
			continue
		var dt := get_process_delta_time()
		if bot:
			var to := goal - player.global_position
			player.rotation.y = atan2(-to.x, -to.z)
			if boat_state == "crossing" and _dive_t <= 0.0 and Vector2(player.global_position.x - level.boat.global_position.x, player.global_position.z - level.boat.global_position.z).length() < 5.0:
				Input.action_press("dive")

		elapsed += dt
		bump_cd = maxf(0.0, bump_cd - dt)
		var pos := player.global_position
		var flat_d := Vector2(pos.x - goal.x, pos.z - goal.z).length()
		if flat_d < 2.6:
			break
		# Yardım: 70 sn sonra akıntı hedefe taşır
		if elapsed > 70.0:
			if not help_said:
				help_said = true
				hud.bark("SPK_HIKMET", "D2_H_SWIM_HELP", 3.5)
			player.global_position += (Vector3(goal.x, pos.y, goal.z) - pos).normalized() * 2.5 * dt
		# Nefes ve hız
		# Player Shift'te RUN kullanır: çarpan aynı kalır (≈3.2 m/sn); nefes bitince Shift yavaşlığa döner
		var shift := Input.is_action_pressed("sprint")
		var sprinting := shift and _breath > 0.08 and _dive_t <= 0.0
		player.speed_mult = SWIM_SPEED if (sprinting or not shift) else SWIM_SPEED * Player.WALK / Player.RUN
		if _dive_t > 0.0:
			_dive_t -= dt
			_breath = maxf(0.0, _breath - dt * 0.3)
			if _dive_t <= 0.0 or _breath <= 0.0:
				_dive_t = 0.0
				level.splash(player.global_position)
		elif sprinting:
			_breath = maxf(0.0, _breath - dt * 0.2)
		else:
			_breath = minf(1.0, _breath + dt * 0.14)
		hud.set_chase(tr("UI_SWIM_BREATH"), _breath, false)
		var dive_now := Input.is_action_just_pressed("dive") or (bot and Input.is_action_pressed("dive"))
		if bot:
			Input.action_release("dive")
		if dive_now and _dive_t <= 0.0:
			if _breath > 0.25:
				_dive_t = DIVE_SECONDS
				level.splash(player.global_position)
				level.bubbles(player.global_position + Vector3(0, Player.EYE - 1.4, 0), 1.2)
			else:
				hud.bark("SPK_TOLGA", "D2_T_SWIM_NOAIR", 2.0)
		# Akıntı ve derinlik
		player.global_position += CURRENT * dt
		var target_y := surface_y - (1.55 if _dive_t > 0.0 else 0.0)
		player.global_position.y = move_toward(player.global_position.y, target_y, dt * 5.0)
		# Oklar: önce halka, sonra ok (dalınca isabet etmez)
		arrow_in -= dt
		if route == "shore" and arrow_in <= 0.0:
			arrow_in = arrow_every * randf_range(0.8, 1.25)
			var fwd := -player.global_transform.basis.z
			fwd.y = 0.0
			var at := player.global_position + fwd.normalized() * randf_range(0.5, 3.5) + Vector3(randf_range(-1.6, 1.6), 0, randf_range(-1.6, 1.6))
			level.arrow_warning(at, 1.1)
			pending.append({"pos": at, "t": 1.1})
		for a in pending.duplicate():
			a["t"] -= dt
			if a["t"] <= 0.0:
				pending.erase(a)
				var ap: Vector3 = a["pos"]
				level.arrow_fall(ap)
				var d := Vector2(player.global_position.x - ap.x, player.global_position.z - ap.z).length()
				if d < 1.3 and _dive_t <= 0.0:
					hits += 1
					_arrow_hits += 1
					player.shake(0.6)
					Audio.sfx("land_thud", -6.0)
					hud.bark("SPK_TOLGA", "D2_T_ARROW_%d" % (randi() % 3 + 1), 2.2)
		# Yüzen kütük ve fıçılar: çarpınca geri iter
		for node in level.swim_debris:
			var dn := Vector2(player.global_position.x - node.global_position.x, player.global_position.z - node.global_position.z)
			if dn.length() < 1.25 and bump_cd <= 0.0 and _dive_t <= 0.0:
				bump_cd = 1.2
				player.global_position += Vector3(dn.x, 0, dn.y).normalized() * 0.8
				player.shake(0.35)
				Audio.sfx("land_thud", -10.0, 1.3)
				if not _swim_found.has("bump"):
					_swim_found["bump"] = true
					hud.bark("SPK_TOLGA", "D2_T_SWIM_BUMP", 2.2)
		# Kayıp fes
		if level.fez_float and level.fez_float.visible and not _swim_found.has("fez"):
			var fd := Vector2(player.global_position.x - level.fez_float.global_position.x, player.global_position.z - level.fez_float.global_position.z).length()
			if fd < 1.6:
				_swim_found["fez"] = true
				level.fez_float.visible = false
				Audio.sfx("ui_confirm", -6.0)
				# Tolga'nın kendi fesi başında ya da cebinde (H ile çıkarılır, kaybolmaz): bu yedek fes cebe girer
				# (4a'da Hüseyin'e verilebilir; docs/BRANCHING_V2.md §4)
				GameState.pocket_add("spare_fez", "fez_halic_2")
				hud.bark("SPK_TOLGA", "D2_T_FEZ_SPARE", 3.0)
		# Amfora: dalınca yakınındaysan
		if _dive_t > 0.0 and not _swim_found.has("amphora"):
			var am := level.amphora_spot
			if Vector2(player.global_position.x - am.x, player.global_position.z - am.z).length() < 3.0:
				_swim_found["amphora"] = true
				GameState.flags["amphora_seen"] = true
				hud.bark("SPK_TOLGA", "D2_T_AMPHORA", 3.5)
		# Zincir yolu: yolun yarısına gelince devriye kayığı önünden geçer
		if route == "chain":
			var prog := 1.0 - flat_d / maxf(total, 0.1)
			if boat_state == "idle" and prog > 0.32:
				boat_state = "crossing"
				boat_t = 0.0
				var to_goal := (Vector3(goal.x, 0, goal.z) - Vector3(pos.x, 0, pos.z)).normalized()
				var ahead := Vector3(pos.x, level.water_y, pos.z) + to_goal * 7.0
				var side := to_goal.cross(Vector3.UP).normalized()
				boat_from = ahead + side * 26.0
				# Karşı tarafa geçip kürek çekmeye devam eder, sisin içinde kaybolur (yolun ortasında durmaz)
				boat_to = ahead - side * 60.0
				level.boat.global_position = boat_from
				level.boat.look_at(boat_to, Vector3.UP)
				hud.bark("SPK_HIKMET", "D2_H_SWIM_BOAT", 2.5)
				_delayed_bark(_voice_len("D2_H_SWIM_BOAT", 2.5) + 0.2, "SPK_HIKMET", "D2_H_SWIM_BOAT_2", 3.0)
				# Kayığın üstünde uyarı: binilecek bir kayık değil, altından dalınacak devriye
				var tag := Label3D.new()
				tag.name = "PatrolTag"
				tag.text = tr("UI_BOAT_PATROL") % GameState.key_hint("CTRL")
				tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				tag.no_depth_test = true
				tag.fixed_size = true
				tag.pixel_size = 0.0016
				tag.font_size = 30
				tag.outline_size = 10
				tag.modulate = Color("ff5a4a")
				tag.position = Vector3(0, 2.6, 0)
				level.boat.add_child(tag)
			if boat_state == "crossing":
				boat_t += dt / 11.6
				level.boat.global_position = boat_from.lerp(boat_to, minf(boat_t, 1.0))
				var away := Vector3(player.global_position.x - level.boat.global_position.x, 0.0, player.global_position.z - level.boat.global_position.z)
				var bd := away.length()
				hud.set_qte(_dive_prompt() if bd < 7.0 and _dive_t <= 0.0 and not boat_hit else "")
				if bd < 2.4 and _dive_t <= 0.0 and not boat_hit:
					boat_hit = true
					player.shake(1.2)
					level.splash(player.global_position)
					Audio.sfx("splash", -4.0)
					hud.set_qte("")
					hud.bark("SPK_ROWER", "D2_R_21", 2.5)
				# Kayık oyuncunun içinden geçmesin (kamera gövdeye girip kayık "kayboluyordu"): suyun üstündeyken
				# gövdenin (5.6 m boy, küreklerle 3 m en) yanına it
				if _dive_t <= 0.0:
					var local := level.boat.global_transform.affine_inverse() * player.global_position
					if absf(local.z) < 3.2 and absf(local.x) < 1.7:
						local.x = 1.7 * (1.0 if local.x >= 0.0 else -1.0)
						var out := level.boat.global_transform * local
						player.global_position = Vector3(out.x, player.global_position.y, out.z)
				var tag_node := level.boat.get_node_or_null("PatrolTag")
				if tag_node:
					tag_node.visible = bd < 30.0 and not boat_hit
				if boat_t >= 1.0:
					boat_state = "done"
					level.boat.visible = false
					if tag_node:
						tag_node.queue_free()
					hud.set_qte("")
		await get_tree().process_frame
	if bot:
		Input.action_release("move_forward")
		print("SWIM route=%s hits=%d boat_hit=%s time=%.1f found=%s" % [route, hits, boat_hit, elapsed, _swim_found.keys()])
	player.frozen = true
	player.speed_mult = 1.0
	_dive_t = 0.0
	player.global_position.y = surface_y
	hud.set_chase("", 0.0)
	hud.set_qte("")
	hud.set_objective("")
	return not boat_hit


func _swim_hint() -> String:
	var t := tr("UI_SWIM_HINT")
	if GameState.pad:
		for k in ["WASD", "Shift", "CTRL"]:
			t = t.replace(k, GameState.key_hint(k))
	return t


## "CTRL: DAL!" kolda LT olarak görünür
func _dive_prompt() -> String:
	return tr("UI_QTE_DIVE").replace("CTRL", GameState.key_hint("CTRL"))


func _budget() -> void:
	await hud.fade_to(1.0, 0.6)
	_delayed_bark(1.2, "SPK_HIKMET", "D2_H_17", 3.0)
	await hud.budget_map(tr("UI_BUDGET_TITLE"), tr("UI_BUDGET_FROM"), tr("UI_BUDGET_TO"), 4.0)


func _delayed_bark(delay: float, speaker: String, key: String, seconds: float) -> void:
	await _wait(delay)
	hud.bark(speaker, key, seconds)


# ================================================================ son

func _end_chapter() -> void:
	player.frozen = true
	player.release_grab()
	hud.set_objective("")
	GameState.set_outcome(2, _outcome)
	GameState.flags["ch2_stumbles"] = hits
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, _outcome != "2.5")
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		# Bölüm geçişi testi: Bölüm 2'nin sonucuyla Bölüm 3'e geç
		print("AUTOTEST chapter=2 -> 3 outcome=%s" % _outcome)
		GameState.autotest_variant = ""
		get_tree().change_scene_to_file("res://scenes/chapter3.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			get_tree().change_scene_to_file("res://scenes/chapter3.tscn")
		"replay":
			GameState.replay_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW2_TITLE")
	c.nodes = [
		{"id": "fall", "key": "FLOW2_FALL", "pos": Vector2(0.5, 0.17)},
		{"id": "radio", "key": "FLOW2_RADIO", "pos": Vector2(0.5, 0.27)},
		{"id": "clean", "key": "FLOW2_CLEAN", "pos": Vector2(0.37, 0.38)},
		{"id": "stumble", "key": "FLOW2_STUMBLE", "pos": Vector2(0.63, 0.38)},
		{"id": "2.5", "key": "FLOW_2_5", "pos": Vector2(0.88, 0.38), "outcome": true},
		{"id": "horn", "key": "FLOW2_HORN", "pos": Vector2(0.5, 0.5)},
		{"id": "2.1", "key": "FLOW_2_1", "pos": Vector2(0.13, 0.63), "outcome": true},
		{"id": "2.2", "key": "FLOW_2_2", "pos": Vector2(0.38, 0.63), "outcome": true},
		{"id": "2.3", "key": "FLOW_2_3", "pos": Vector2(0.62, 0.63), "outcome": true},
		{"id": "2.4", "key": "FLOW_2_4", "pos": Vector2(0.87, 0.63), "outcome": true},
	]
	c.edges = [["fall", "radio"], ["radio", "clean"], ["radio", "stumble"], ["radio", "2.5"],
		["clean", "horn"], ["stumble", "horn"], ["horn", "2.1"], ["horn", "2.2"], ["horn", "2.3"], ["horn", "2.4"]]
	c.taken["fall"] = true
	c.taken["radio"] = true
	if _outcome != "2.5":
		c.taken["clean" if hits == 0 else "stumble"] = true
		c.taken["horn"] = true
	c.taken[_outcome] = true
	for id in ["2.1", "2.2", "2.3", "2.4", "2.5"]:
		if GameState.has_seen(id):
			c.seen[id] = true
	var fez_on: bool = GameState.flags.get("fez", true)
	c.footer_lines = [
		tr("UI_FLOW_STATS") % GameState.telsiz_bag + "     ·     " + tr("UI_STUMBLES") % (hits - _arrow_hits) + "     ·     " + tr("UI_FLOW_FEZ") % ("✓" if fez_on else "✗"),
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW2_NEXT") if _outcome != "2.5" else tr("UI_EARLY_END"),
		GameState.tr_pad("UI_FLOW_CONTINUE") if _outcome != "2.5" else GameState.tr_pad("UI_FLOW2_REPLAY"),
	]
	return c


# ================================================================ yardımcılar

func _h(key: String) -> void:
	await hud.say("SPK_HIKMET", key)


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _say(speaker: String, key: String) -> void:
	await hud.say(speaker, key)


func _wait(s: float) -> void:
	if GameState.autotest:
		await get_tree().process_frame
		return
	await get_tree().create_timer(s, false).timeout


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


## Replik sesinin süresi (yoksa verilen yedek süre).
func _voice_len(key: String, fallback: float) -> float:
	var vs := hud.voice_stream(GameState.line_variant(key))
	return vs.get_length() if vs else fallback


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _flash_prompt(text: String, seconds: float) -> void:
	hud.set_prompt(text)
	await _wait(seconds)
	if hud:
		hud.set_prompt("")


# ================================================================ otomatik test

## Test oyuncusu: engelleri görür, zıplar ya da şerit değiştirir.
## Varsayılan varyant ilk halatı bilerek kaçırır (en az bir tökezleme -> 2.1).
func _auto_step(s: float) -> void:
	for o in level.obstacles:
		if o["resolved"]:
			continue
		var ds: float = o["s"] - s
		if ds < 0.0 or ds > 8.0:
			continue
		if o["kind"] == "rope":
			var skip_first: bool = GameState.autotest_variant == "" and o["s"] == level.obstacles[0]["s"]
			# Havada ~5.4 m gidilir: 3 m kala zıplamak kare hızından bağımsız olarak halatı aşar
			if ds < 3.0 and not skip_first:
				player.jump()
		elif lane in o["lanes"]:
			for l in 3:
				if l not in o["lanes"]:
					lane = l
					break
		break


func _autotest_report() -> void:
	var expected: String = {"": "2.1", "perfect": "2.2", "chain": "2.3", "chainfail": "2.4", "red": "2.5"}.get(GameState.autotest_variant, "?")
	var ok := _outcome == expected
	# Serbest yüzmede oklar rastgele: kıyıda 2.1 ya da 2.2; zincirde bot kayığın altından dalar
	if GameState.autotest_variant == "swimshore":
		ok = _outcome in ["2.1", "2.2"]
	elif GameState.autotest_variant == "swimchain":
		ok = _outcome == "2.3"
	if not ok:
		printerr("AUTOTEST: beklenen sonuç %s, gelen %s" % [expected, _outcome])
	if GameState.autotest_variant == "perfect" and hits != 0:
		ok = false
		printerr("AUTOTEST: kusursuz koşuda %d tökezleme" % hits)
	if GameState.autotest_variant == "" and hits == 0:
		ok = false
		printerr("AUTOTEST: tökezleme bekleniyordu")
	if GameState.chapter_outcomes.get(2, "") != _outcome:
		ok = false
		printerr("AUTOTEST: bölüm sonucu kaydedilmedi")
	if GameState.chapter_outcomes.has(1) and GameState.bag.size() != 5:
		ok = false
		printerr("AUTOTEST: Bölüm 1'in çantası Bölüm 2'ye taşınmadı")
	print("AUTOTEST %s chapter=2 variant=%s outcome=%s stumbles=%d telsiz=%d" % ["PASS" if ok else "FAIL", GameState.autotest_variant, _outcome, hits, GameState.telsiz_bag])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(file_name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file_name))
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	await get_tree().create_timer(0.6).timeout
	# 1. Varış: arkadaki kadırgaya bakış
	ship_s = START_S - START_GAP - BOW
	level.set_ship_s(ship_s)
	player.global_position = level.s_to_world(START_S, 0.0, 0.3)
	player.face(level.s_to_world(ship_s + BOW - 2.0, 0.0, 2.8))
	hud.bark("SPK_TOLGA", "D2_T_03", 30.0)
	await get_tree().create_timer(0.5).timeout
	await _shot("c2_01_varis.png")

	# 1b. Kadırga yandan
	hud.bark("SPK_SOLDIER", "D2_S_06", 30.0)
	player.global_position = level.s_to_world(ship_s + 4.0, 4.2, 0.3)
	player.face(level.s_to_world(ship_s - 1.0, 0.0, 3.0))
	await _shot("c2_08_kadirga.png")

	# 2. Koşu: önde halat, kadırga yaklaşıyor
	player.global_position = level.s_to_world(48.0, 0.0, 0.3)
	player.face(level.s_to_world(70.0, 0.0, -1.4))
	hud.set_objective(tr("UI_OBJ_RUN"))
	hud.set_qte(tr("UI_QTE_JUMP"))
	hud.set_chase(tr("UI_CHASE"), 0.55)
	hud.bark("SPK_SOLDIER", "D2_S_ROPE", 30.0)
	await _shot("c2_02_kosu.png")

	# 3. Aşağıda Haliç ve karşıda şehir
	hud.set_qte("")
	player.global_position = level.s_to_world(110.0, 2.4, 0.3)
	player.face(level.end_point() + Vector3(10, 4, -120))
	hud.bark("SPK_HIKMET", "D2_H_WARRANTY_END", 30.0)
	await _shot("c2_03_halic.png")

	# 3a. Koşarken arkaya bakış: tepe, kızak yolu, solda Galata (tek harita)
	player.global_position = level.s_to_world(70.0, 0.0, 0.3)
	player.face(level.s_to_world(0.0, -30.0, 6.0))
	await _shot("c2_13_arka.png")
	# 3a'. Sudan kıyıya bakış: kızak, kıyıya çekilmiş kadırgalar, Galata
	player.global_position = _water(level.swim_start() + Vector3(-10.0, 0, -25.0))
	player.face(level.end_point() + Vector3(-40.0, 12.0, 30.0))
	await _shot("c2_14_sudan.png")
	# 3a''. Sudan Haliç'in ağzına: zincir, Galata, karşıda Ayasofya
	player.face(level.world_chain() + Vector3(0, 8.0, 0))
	await _shot("c2_15_agiz.png")

	# 3b. Kızağın ucundan Haliç'e uçuş
	hud.set_qte("")
	hud.set_objective("")
	hud.set_chase("", 0.0)
	var land := level.swim_start()
	var fly := level.end_point().lerp(land, 0.35) + Vector3(0, 2.4, 0)
	player.gravity_on = false
	player.global_position = fly
	player.face(land + Vector3(0, -1.0, -10))
	hud.bark("SPK_TOLGA", "D2_T_FALL_SCREAM", 30.0)
	await get_tree().create_timer(0.35).timeout
	await _shot("c2_09_ucus.png")

	# 3c. Sualtı
	player.global_position = Vector3(land.x, level.water_y - Player.EYE - 1.4, land.z)
	player.face(land + Vector3(-6, -0.4, -20))
	level.bubbles(player.global_position + Vector3(1.2, Player.EYE - 1.0, -4.0), 2.0)
	hud.bark("SPK_HIKMET", "D2_H_09", 30.0)
	await get_tree().create_timer(0.8).timeout
	await _shot("c2_10_sualti.png")
	# 3d. Sualtı: yosun ormanı, balıklar ve batık kadırga (zincir yolu)
	var cp0 := level.chain_point()
	var uw := land.lerp(cp0, 0.45)
	player.global_position = Vector3(uw.x, level.water_y - Player.EYE - 1.5, uw.z)
	var wk := land.lerp(cp0, 0.62) + Vector3(-4.0, 0, 3.0)
	player.face(Vector3(wk.x, level.water_y - 3.6, wk.z))
	level.bubbles(player.global_position + Vector3(0.5, Player.EYE - 0.6, -1.0), 2.0)
	hud.bark("SPK_TOLGA", "D2_T_AMPHORA", 30.0)
	await get_tree().create_timer(0.8).timeout
	await _shot("c2_11_batik.png")
	# 3e. Serbest yüzme: ok uyarısı, yüzen kütük, kayıp fes, demirli kadırgalar
	player.global_position = _water(land.lerp(level.shore_point(), 0.1))
	player.face(level.fez_float.global_position + Vector3(-2, 0.2, -6))
	level.arrow_warning(player.global_position + Vector3(-1.2, 0, -3.0), 5.0)
	hud.set_objective(tr("UI_OBJ_SWIM_SHORE"))
	hud.set_chase(tr("UI_SWIM_BREATH"), 0.7, false)
	hud.set_prompt(_swim_hint())
	await get_tree().create_timer(0.4).timeout
	await _shot("c2_12_yuzme.png")
	hud.set_prompt("")
	player.global_position = _water(land)

	# 4. Suda: karar
	hud.set_chase("", 0.0)
	hud.set_objective(tr("UI_OBJ_SWIM"))
	player.gravity_on = false
	player.global_position = _water(level.swim_start())
	player.face(level.swim_start() + Vector3(-12, 2.0, -60))
	hud.choose(["UI_CHOICE_SHORE", "UI_CHOICE_CHAIN"], 8.0)
	await get_tree().create_timer(1.0).timeout
	await _shot("c2_04_karar.png")

	# 5. Kayık geliyor: dal!
	hud.choose_cancel()
	hud.set_objective("")
	var cp := level.chain_point()
	var mid := level.swim_start().lerp(cp, 0.55)
	player.global_position = _water(level.swim_start().lerp(cp, 0.45))
	var far := level.swim_start().lerp(cp, 0.75)
	level.boat.visible = true
	level.boat.global_position = Vector3(far.x + 6, level.water_y, far.z + 2)
	level.boat.look_at(Vector3(far.x - 20, level.water_y, far.z), Vector3.UP)
	player.face(level.boat.global_position + Vector3(0, 0.3, 0))
	hud.bark("SPK_ROWER", "D2_R_21", 30.0)
	hud.set_qte(_dive_prompt())
	await _shot("c2_05_kayik.png")

	# 6. Bütçe haritası
	hud.set_qte("")
	var m := BudgetMap.new()
	m.title = tr("UI_BUDGET_TITLE")
	m.from_label = tr("UI_BUDGET_FROM")
	m.to_label = tr("UI_BUDGET_TO")
	m.progress = 1.0
	hud.add_child(m)
	hud.bark("SPK_HIKMET", "D2_H_17", 30.0)
	await _shot("c2_06_butce.png")
	m.queue_free()

	# 7. Akış şeması
	_outcome = "2.3"
	hits = 1
	GameState.seen_outcomes = {"2.1": true}
	var chart := _make_chart()
	hud.add_child(chart)
	await _shot("c2_07_akis.png")
	get_tree().quit()

