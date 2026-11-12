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
const WARRANTY_WARN_S := 30.0      # 36'ydı: uyarıdan bitişe 4,6 sn, basılı tutma 3 sn sürüyor (şimdi 5,4 sn)
const WARRANTY_END_S := 70.0      # Hikmet'in "garanti bitti"si kızağın ucundaki "yokuş bitiyor"dan önce bitsin
const RED_HOLD_SECONDS := 3.0

var level: Slipway
var player: Player
var hud: Hud

var _underwater := false
var _dive_uw := false       # suya çarpış anından yüzeye dönene dek: kamera yüzeyde dururken de sualtı sisi/tonu açık (ilk karede beyaz dip görünüyordu)
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
## Yakalayan askerlerin durduğu yer (oyuncuya göre: ileri, yan) ve bkz. _seize
const SEIZE_AHEAD := 1.0
const SEIZE_SIDE := 0.55
var _arrow_hits := 0
var _shore_props: Array = []
var _priority_until := 0.0   # önemli telsiz satırı (garanti) bitene dek tökezleme repliği onu kesmez
var _stowed := false
var _rumble_t := 0.0


func _stow(on: bool) -> void:
	if on != _stowed:
		_stowed = on
		player.stow_hands(on)


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
	player.face(level.s_to_world(ship_s + BOW, 0.0, 5.6))     # güverte, tayfa ve direk fesin kenarının altında kalsın
	# Göz kadırgaya kilitlenir (dar bakış, kamera yerinde): 13 m yukarıdaki kadırga kadrajın üçte birini doldurur;
	# eskiden yokuşun tepesinde küçücük görünüyordu, "üstüme geliyor" tehdidi okunmuyordu (tur 3). Kontrol gelmeden
	# önce bakış olağan genişliğine döner.
	_intro_zoom(0.6, 1.4)

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
	# Hedef ve tuşlar kontrol gelmeden önce görünür (33 sn donuk girişin sonunda, "KOŞ!" ile aynı karede çıkıyordu:
	# oyuncu okuyamadan ilk halat geliyordu). Tuş satırı koşu boyunca köşede kalır.
	hud.set_objective(tr("UI_OBJ_RUN"))
	hud.show_controls(true, "UI_RUN_HINT")
	await _t("D2_T_05")
	await _say("SPK_SOLDIER", "D2_S_06")
	hud.bark("SPK_HIKMET", "D2_H_07", 1.5)

	# Kızak kaçışı
	_intro_zoom(1.0, 0.5)
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
	while phase in ["run", "caught"]:
		await get_tree().process_frame
	if phase == "done":
		return
	await _swim()
	await _end_chapter()


var _zoom_tw: Tween


## Açılışta oyuncunun gözünün kadırgaya kilitlenmesi: bakış açısı ayarlanan değerin mult katına iner (kamera yerinde).
func _intro_zoom(mult: float, t: float) -> void:
	if _zoom_tw and _zoom_tw.is_valid():
		_zoom_tw.kill()
	var fov := float(GameState.settings.get("fov", 72.0)) * mult
	if t <= 0.0 or GameState.autotest and not GameState.pace:
		player.camera.fov = fov
		return
	_zoom_tw = create_tween()
	_zoom_tw.tween_property(player.camera, "fov", fov, t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# ================================================================ koşu

func _process(delta: float) -> void:
	if hud == null:
		return
	hud.fez.motion = player.horizontal_speed() * 0.6
	# Sualtı görünümü kameranın gerçek yüksekliğine bağlı (dalış, düşüş)
	var uw := _dive_uw or player.camera.global_position.y < level.water_y - 0.02
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
	_swim_fx(delta)
	_archers_tick(delta)
	_watchers_tick(delta)


## Yüzerken suyun tepkisi: oyuncunun çevresinde genişleyen halkalar (ilerlerken önünde, dururken seyrek), kulaç atan
## el suya her girişinde küçük halka ve damlalar. Eskiden yüzücünün çevresinde su kıpırdamıyordu.
var _wake_t := 0.0
var _wake_prev := Vector3.INF
var _stroke_k := 0


func _swim_fx(delta: float) -> void:
	if not player.floating or _underwater or level == null:
		_wake_prev = Vector3.INF
		return
	var p := player.global_position
	var spd := 0.0
	if _wake_prev != Vector3.INF and delta > 0.0:
		spd = Vector2(p.x - _wake_prev.x, p.z - _wake_prev.z).length() / delta
	_wake_prev = p
	if spd > 20.0:
		spd = 0.0     # ışınlanma (otomatik test, kararma)
	var fwd := -player.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	_wake_t -= delta
	if _wake_t <= 0.0:
		_wake_t = 0.4 if spd > 0.3 else 1.3
		level.ripple(p + fwd * 0.35, 0.35, 1.7 if spd > 0.3 else 1.0, 1.6, 0.45 if spd > 0.3 else 0.25)
	if spd > 0.3:
		var st: float = player.get("_stroke")
		var k := int(st / PI)
		if k != _stroke_k:
			_stroke_k = k
			# Kulaç: önce sol, sonra sağ el suya girer (elin ekrandaki yerinin önünde)
			var hand: Node3D = player.free_hand if k % 2 == 0 else player.hand
			if hand and hand.is_inside_tree():
				var hp := hand.global_position + fwd * 0.25
				level.ripple(hp, 0.1, 0.8, 0.9, 0.55)
				level.drops(hp, 6, 1.4, 0.016)      # gözün dibinde: küçük damlalar


## Fizik adımında: halatın üstünden havada geçildiyse işaretle (kare takılsa bile adil olsun);
## test botu da burada karar verir, yavaş makinede kare atlanınca engeli kaçırmasın.
var _air_t := 0.0


func _physics_process(delta: float) -> void:
	if phase != "run" or hud == null:
		return
	var s := level.world_to_s(player.global_position)
	if GameState.autotest:
		_auto_step(s)
	# Gerçek sıçrama: en az 0,3 sn havada (sıçrama ~0,96 sn sürer). Kızağın ek yerlerinde (s≈23,5 ve s≈95) koşan oyuncu
	# zıplamadan 0,2 sn havalanıyor; tek adımlık kopma da "halatı aştı" sayılıyordu (halat 24 m'ye alınınca ölçüldü)
	_air_t = 0.0 if player.is_on_floor() else _air_t + delta
	for o in level.obstacles:
		if not o["resolved"] and o["kind"] == "rope" and o["s"] - s <= 0.8 and o["s"] - s > -1.5 and _air_t >= 0.3:
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
	# Kadırga yaklaştıkça yer sarsılır (kütüklerin gümbürtüsü): kamera hafifçe titrer
	_rumble_t -= delta
	if gap < 12.0 and _rumble_t <= 0.0:
		_rumble_t = 0.25
		player.shake(0.05 + 0.2 * (1.0 - clampf(gap / 12.0, 0.0, 1.0)))
	level.chase_gap = gap
	# Omuz üstünden bakış (tur 4): ilk halat aşılınca bir kez, 0,56 sn; ekranlı oyunda (testte atlanır)
	if not _glanced and s >= 28.0 and not (GameState.autotest and not GameState.pace):
		_glance()

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
		# Hikmet "düğmeyi basılı tut" der ama hangi tuş, ne olur söylemez: süre dolana kadar köşede yazar
		hud.show_controls(true, "UI_WARRANTY_HINT")
		_priority_until = _now() + _voice_len("D2_H_WARRANTY", 3.5)
	if warranty and s > WARRANTY_END_S:
		warranty = false
		hud.bark("SPK_HIKMET", "D2_H_WARRANTY_END", 3.0)
		hud.show_controls(true, "UI_RUN_HINT")
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


var _glanced := false


## Omuz üstünden bakış: kamera 0,56 sn'de kadırgaya döner (dev pruva kadrajı doldurur), geri gelir. Kamera oyuncunun
## gözünde kalır; yalnız bakış döner (yürüyüş yönü ve şerit tuşları script_velocity ile sürdüğü için kontrol kaybı yok;
## fare dönüşü korunur: dönüş eklemeli uygulanır). Oynanışı, süreleri ve engel zamanlamasını değiştirmez.
func _glance() -> void:
	_glanced = true
	var turn := PI * 0.93
	var pitch := 0.24
	var last := {"e": 0.0}
	var apply := func(e: float) -> void:
		var d: float = e - float(last["e"])
		last["e"] = e
		if is_instance_valid(player):
			player.rotation.y += d * turn
			player.camera.rotation.x += d * pitch
	var tw := create_tween()
	tw.tween_method(apply, 0.0, 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.2)
	tw.tween_method(apply, 1.0, 0.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	player.shake(0.25)


## "Yokuş bitti!" kenarda bitsin diye replik kenardan bu kadar saniye önce başlar (kaydın uzunluğu).
func _edge_lead() -> float:
	var vs := hud.voice_stream("D2_T_FALL")
	return clampf(GameState.voice_len(vs), 1.0, 4.8) if vs else 1.4


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
	hud.show_controls(false)
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
	level.chase_gap = 99.0
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
	hud.show_controls(false)
	# İki el boş: kumanda fırlayışta cebe girer (düşerken, sualtında, yüzerken elde duruyordu); karaya çıkınca geri
	_stow(true)
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
	hud.bark("SPK_TOLGA", "D2_T_FALL_SCREAM", 3.0, true)
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
	_dive_uw = true
	hud.cut_voice()
	Audio.sfx("splash", -1.0, 0.85)
	level.splash(surf + fwd * 1.8, true)      # çarpış sütunu gözün dibinde değil, biraz önde (iri damlalar kameraya yapışıyordu)
	# Çarpışın halkaları: biri hızla, biri yavaşça açılır (köpük suyun yüzünde bir süre kalır)
	level.ripple(surf + fwd * 0.5, 0.4, 2.6, 1.1, 0.55)
	level.ripple(surf + fwd * 0.5, 0.3, 3.8, 1.9, 0.35)
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
	_dive_uw = false
	level.splash(surf + Vector3(0, 0, -0.6) - fwd * 0.2)
	level.ripple(surf, 0.4, 2.6, 1.8, 0.55)
	Audio.sfx("splash", -10.0, 1.3)
	var rise := create_tween()
	rise.tween_property(player, "global_position", _water(land), 0.3).set_ease(Tween.EASE_OUT)
	await rise.finished
	player.floating = true
	player.face(look)
	# Başı sudan çıktı: saçından gözünün önüne su damlar
	level.drips(player, 2.5, player.camera)


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
		_seize(guards, landing)
		await _say("SPK_SOLDIER", "D2_S_14" if GameState.flags.get("fez", true) else "D2_S_14_NOFEZ")
		await _t("D2_T_15")
		await _seize_done(guards)
		_grab_arms(guards, 4.0)
		player.shake(0.15)
		await _say("SPK_SOLDIER", "D2_S_16")
		await Handover.wait(self, 0.05 if Stage.fast() else 0.6)
		await _budget()
		player.free_hold = Vector3.INF
		for g in guards:
			g.queue_free()


## Kıyıya çıkış: oyuncu kuru zemine oturur ve yer çekimi açılır (suda kapalı kalmıştı). Sudan çıkan ıslaktır:
## giysisinden ve saçından su damlar, ayağının altında su birikir, sudan buraya ıslak ayak izleri uzanır (eskiden
## kararmadan kupkuru çıkıyordu).
func _land_on_shore() -> Vector3:
	var landing := _shore_landing()
	player.global_position = landing
	player.gravity_on = true
	_stow(false)
	level.drips(player, 9.0, player.camera)
	level.wet_spot(Vector3(landing.x, _ground_y(landing.x, landing.z), landing.z), Vector2(1.1, 0.8), randf() * TAU, 40.0)
	var from := _shore_water(landing)
	var dir := Vector3(landing.x - from.x, 0.0, landing.z - from.z)
	if dir.length() > 0.5:
		var n := dir.normalized()
		var lat := Vector3(-n.z, 0.0, n.x)
		var yaw := atan2(n.x, n.z)
		# Islak ayak izleri: çıplak ayak biçimi (topuk, taban, parmaklar), sol-sağ sırayla, adım 0,58 m, yürüyüş yönünde,
		# zemine yatık; sudan çıkış çizgisinden çıkış yerine, sonra kururlar
		var k := 0
		var ln := Vector3(landing.x - from.x, 0, landing.z - from.z).length()
		var d := 0.3
		while d < ln - 0.2:
			var q := from + n * d + lat * (0.1 if k % 2 == 0 else -0.1)
			var gy := _ground_y(q.x, q.z)
			if gy > level.water_y + 0.05:
				var nr := Vector3(_ground_y(q.x - 0.25, q.z) - _ground_y(q.x + 0.25, q.z), 0.5, _ground_y(q.x, q.z - 0.25) - _ground_y(q.x, q.z + 0.25)).normalized()
				level.wet_foot(Vector3(q.x, gy, q.z), yaw + (0.08 if k % 2 == 0 else -0.08), k % 2 == 0, 45.0, nr)
			k += 1
			d += 0.58
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
			if _ground_y_path(p.x, p.z) > level.water_y + 0.25:
				break
			p.z += 0.5
		p.z += 1.0
		p.y = _ground_y_path(p.x, p.z) + 0.05
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
		if _ground_y_path(p.x, p.z) < level.water_y - 0.6:
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
		# Hüseyin'in karıştırdığı küçük ateş: taş halka, kütükler, alev ve ince duman (Hasan suyu gözlerken)
		if _watch_fire == null:
			var f: Vector3 = pos[1] + (pos[0] - pos[1]).normalized().rotated(Vector3.UP, 1.2) * 0.75
			f.y = _ground_y(f.x, f.z)
			_watch_fire = Node3D.new()
			level.add_child(_watch_fire)
			_watch_fire.global_position = f
			for a in 6:
				var ang := TAU * a / 6.0
				Props.ball(_watch_fire, 0.09, Vector3(cos(ang) * 0.28, 0.04, sin(ang) * 0.28), Color("7a766c"), Vector3(1, 0.7, 1), 6)
			for a in 3:
				Props.cyl(_watch_fire, 0.04, 0.5, Vector3(0, 0.08, 0), Color("4a3422"), Vector3(80, a * 60.0, 0), 6)
			Props.bake_static(_watch_fire, _watch_fire.get_children())
			Flame.add(_watch_fire, Vector3(0, 0.12, 0), 0.28, 0.42)
			Vfx.smoke_wisp(_watch_fire, f + Vector3(0, 0.55, 0), 2.6)
			# Elinde ateşi karıştırdığı değnek (her karede elden közün içine)
			_watch_stick = Node3D.new()
			level.add_child(_watch_stick)
			Props.cyl(_watch_stick, 0.018, 0.95, Vector3(0, 0, 0), Color("5a3e26"), Vector3.ZERO, 5)
			_watch_stick.visible = false
	_place_archers(landing, fwd)
	# Kameranın ve karakterlerin durduğu yerlerden 1,3 m içinde ot/çalı kalmaz (tur 3: kameranın dibinde dev yaprak)
	if not _cleared:
		_cleared = true
		var pts: Array = [landing]
		var wat := _shore_water(landing)
		for i in 12:
			pts.append(wat.lerp(landing, i / 11.0))
		for i in 8:
			pts.append(landing + fwd * (0.8 * i))
		pts.append_array(pos)
		for a: Dictionary in _archers:
			pts.append((a["sol"] as Node3D).global_position)
		if _watch_fire:
			pts.append(_watch_fire.global_position)
		var n := level.clear_detail_near(pts, 1.3)
		if GameState.autotest:
			print("SHORE cleared %d grass" % n)


## Kıyıdaki okçular: kıyı yolunda suya düşen oklar bunların yayından çıkar. Çıkış yerinin iki yanında, yüzerken bakılan
## kıyıda, suyun kenarında dururlar. Atış: sadaktan ok çeker, oku kirişe takar, yay dik, sol kol hedefe uzanır, sağ el
## kirişi çenesine çeker (kiriş V olur), bırakınca ok elden kavisle uçar. Atış aralarında da sadağa uzanırlar.
## Eskiden yay yatay duruyor, ok yayın yanında asılı kalıyor, çeken el kirişe gitmiyordu.
var _archers: Array = []      # [{sol, bow, bow_xf, string, nock, ropes, state, t, at, dur, fetch}]


func _place_archers(landing: Vector3, fwd: Vector3) -> void:
	if not _archers.is_empty():
		return
	var space := get_world_3d().direct_space_state
	var coats := [Color("b3262d"), Color("3f7a3a"), Color("c98a3a"), Color("2f5fa8")]
	var k := 0
	for along: float in [-5.5, -8.5, 7.5, 10.5]:
		# Kumsalda, suyun 0,8 m gerisinde, görünen kuma basarak (tur 3: eskiden çarpışma yüzeyi görünen yamacın altında
		# kalıyordu, okçu yamaca gömülüp yalnız fesi görünüyordu); kumsal dar ya da doluysa kıyı boyunca kayar
		var ok := false
		var p := Vector3.ZERO
		for shift: float in [0.0, 1.2, -1.2, 2.4, -2.4, 3.6, -3.6, 4.8, -4.8]:
			var b0 := landing + fwd * (along + shift)
			p = Vector3(b0.x, 0.0, landing.z - 7.0)
			var wet := true
			for i in 50:
				if _ground_y(p.x, p.z) > level.water_y + 0.12:
					wet = false
					break
				p.z += 0.3
			if wet:
				continue
			p.z += 0.8
			p.y = _ground_y(p.x, p.z)
			var flat := true
			for o: Vector2 in [Vector2(0.45, 0), Vector2(-0.45, 0), Vector2(0, 0.45), Vector2(0, -0.45)]:
				if absf(_ground_y(p.x + o.x, p.z + o.y) - p.y) > 0.18:
					flat = false
			var sq := PhysicsShapeQueryParameters3D.new()
			var cap := SphereShape3D.new()
			cap.radius = 0.45
			sq.shape = cap
			sq.transform = Transform3D(Basis(), p + Vector3(0, 1.1, 0))
			sq.exclude = [player.get_rid()]
			if flat and space.intersect_shape(sq, 1).is_empty() and p.y - level.water_y < 0.9:
				ok = true
				break
		if not ok:
			continue
		var sol := Soldier.new(coats[k % coats.size()], "stand", "azap" if k % 2 == 0 else "bork")
		sol.set_meta("no_talk", true)
		level.add_child(sol)
		sol.global_position = p
		sol.equip("bow")
		var el: Node3D = sol.rig.elbow_l if sol.rig else null
		var bow: Node3D = el.get_child(el.get_child_count() - 1) if el else null
		var string: Node3D = bow.get_child(bow.get_child_count() - 1) if bow else null
		# Sırtta sadak: deri kılıf, ağzından tüyler görünür
		var qv := Node3D.new()
		sol.add_child(qv)
		qv.position = Vector3(0.14, 1.12, -0.2)
		qv.rotation_degrees = Vector3(-14, 0, -18)
		Props.cyl(qv, 0.07, 0.62, Vector3.ZERO, Color("6a4428"), Vector3.ZERO, 7)
		for f in 4:
			Props.box(qv, Vector3(0.012, 0.12, 0.05), Vector3((f % 2) * 0.04 - 0.02, 0.36, (f / 2) * 0.04 - 0.02), Color("efe6cf"))
		# Kirişe yatırılan ok ve çekili kirişin iki kolu (çekişte görünür)
		var nock := MeshInstance3D.new()
		nock.mesh = Assault.arrow_mesh()
		nock.material_override = Crowd.material()
		level.add_child(nock)
		nock.visible = false
		var ropes: Array = []
		for r in 2:
			var rp := Stage.rope(level, Vector3.ZERO, Vector3(0, 0.1, 0), 0.0, 0.008, Color("e8e0cc"))
			rp.visible = false
			ropes.append(rp)
		sol.face_toward(p + Vector3(0, 0, -10.0))
		_archers.append({"sol": sol, "bow": bow, "bow_xf": bow.transform if bow else Transform3D(), "string": string, "nock": nock,
			"ropes": ropes, "qv": qv, "state": "idle", "t": randf_range(1.0, 3.0), "at": Vector3.ZERO, "dur": 0.45, "fetch": 0.2})
		k += 1
	if GameState.autotest:
		var hs: Array = []
		for a: Dictionary in _archers:
			hs.append("%.1f" % ((a["sol"] as Node3D).global_position.y - level.water_y))
		print("ARCHERS n=%d above_water=%s" % [_archers.size(), hs])


## Ok at: en uygun boştaki okçu hedefe döner, sadaktan ok çeker, kirişe takıp gerer, fire saniye sonra bırakır; ok kavis
## çizip hedefe dur saniyede varır. Okçu yoksa false (eski düşen ok).
func _archer_shoot(at: Vector3, fire: float, dur: float) -> bool:
	var best: Dictionary = {}
	var bd := INF
	for a: Dictionary in _archers:
		var sol: Soldier = a["sol"]
		if a["state"] not in ["idle", "touch", "aim"] or not is_instance_valid(sol) or not sol.is_visible_in_tree():
			continue
		var d := sol.global_position.distance_to(at)
		if d < bd and d < 45.0:
			bd = d
			best = a
	if best.is_empty():
		return false
	var s: Soldier = best["sol"]
	s.face_toward(at)
	_archer_lock(best, true)
	# Gerip nişan alan okçu hemen bırakır (ok zaten kirişte); boştaki sadaktan çeker
	best["fetch"] = 0.0 if best["state"] == "aim" and float(best.get("drawn", 0.0)) > 0.0 else minf(0.22, fire * 0.35)
	best["state"] = "fetch"
	best["t"] = fire
	best["at"] = at
	best["dur"] = dur
	return true


func _archer_lock(a: Dictionary, on: bool) -> void:
	var sol: Soldier = a["sol"]
	if sol.rig == null or bool(a.get("locked", false)) == on:
		return
	a["locked"] = on
	if on:
		sol.rig.lock += 1
	else:
		sol.rig.lock = maxi(0, sol.rig.lock - 1)
		# Kollar ve yay kendi duruşuna döner (IK'nin yazdığı dönüşler kalmasın: T-pozu)
		for n: Node3D in [sol.rig.arm_l, sol.rig.arm_r, sol.rig.elbow_l, sol.rig.elbow_r]:
			if n:
				n.rotation = Vector3.ZERO
		if a["bow"]:
			(a["bow"] as Node3D).transform = a["bow_xf"]
		if a["string"]:
			(a["string"] as Node3D).visible = true
		(a["nock"] as Node3D).visible = false
		for rp: Node3D in a["ropes"]:
			rp.visible = false


## Okçunun çekiş duruşu (her kare): sol el hedefe uzanır, yay dik ve hedefe dönük; sağ el sadağa (fetch) ya da çeneye
## (draw); çekişte kiriş iki koldan ele gelir, ok kirişte.
func _archer_pose(a: Dictionary, draw: bool) -> void:
	var sol: Soldier = a["sol"]
	var rg := sol.rig
	if rg == null or rg.arm_l == null or rg.arm_r == null:
		return
	var at: Vector3 = a["at"]
	var flat := at - sol.global_position
	flat.y = 0.0
	var aim := flat.normalized() if flat.length() > 0.1 else -sol.global_basis.z
	var up := Vector3.UP
	var right := aim.cross(up).normalized()
	var aim_up := (aim + Vector3(0, 0.16, 0)).normalized()
	var sh_l := rg.arm_l.global_position
	var bow_hand := sh_l + aim_up * 0.6 + right * 0.08
	Rig.reach(rg.arm_l, rg.elbow_l, bow_hand, Vector3.DOWN - right)
	var head := sol.global_position + Vector3(0, 1.52, 0)
	var chin := head + aim * 0.06 + right * 0.03 - up * 0.06
	var hand_r: Vector3 = chin if draw else sol.to_global(Vector3(0.2, 1.62, -0.24))
	Rig.reach(rg.arm_r, rg.elbow_r, hand_r, Vector3.DOWN + right * 0.8)
	var bow: Node3D = a["bow"]
	if bow == null:
		return
	var palm := rg.elbow_l.to_global(rg.elbow_l.get_meta("hand", Vector3(0, -0.26, 0.01)))
	var bz := aim_up
	var by := (up - bz * up.dot(bz)).normalized()
	bow.global_transform = Transform3D(Basis(by.cross(bz), by, bz), palm)
	var nock: Node3D = a["nock"]
	var string: Node3D = a["string"]
	if draw:
		if string:
			string.visible = false
		var top := bow.to_global(Vector3(0, 0.46, -0.055))
		var bot := bow.to_global(Vector3(0, -0.46, -0.055))
		var hand := rg.elbow_r.to_global(rg.elbow_r.get_meta("hand", Vector3(0, -0.26, 0.01)))
		Stage.rope_to(a["ropes"][0], [level.to_local(top), level.to_local(hand)])
		Stage.rope_to(a["ropes"][1], [level.to_local(bot), level.to_local(hand)])
		for rp: Node3D in a["ropes"]:
			rp.visible = true
		var dir := (palm - hand).normalized()
		var ny := (up - dir * up.dot(dir)).normalized()
		nock.global_transform = Transform3D(Basis(ny.cross(dir), ny, dir), hand + dir * 0.42)
		nock.visible = true
	else:
		nock.visible = false


func _archers_tick(delta: float) -> void:
	for a: Dictionary in _archers:
		var sol: Soldier = a["sol"]
		if not is_instance_valid(sol):
			continue
		a["t"] = float(a["t"]) - delta
		match a["state"]:
			"fetch":
				# Sağ el sırttaki sadağa uzanır, bir ok çeker
				_archer_pose(a, false)
				a["fetch"] = float(a["fetch"]) - delta
				if float(a["fetch"]) <= 0.0:
					a["state"] = "draw"
			"draw":
				_archer_pose(a, true)
				if float(a["t"]) <= 0.0:
					var nock: Node3D = a["nock"]
					var from := nock.global_position + nock.global_basis.z * 0.3
					level.arrow_shot(from, a["at"], float(a["dur"]))
					Audio.sfx_at("whoosh_fly", sol, -8.0)
					a["state"] = "loose"
					a["t"] = 0.35
					nock.visible = false
					for rp: Node3D in a["ropes"]:
						rp.visible = false
					if a["string"]:
						(a["string"] as Node3D).visible = true
			"loose":
				if float(a["t"]) <= 0.0:
					_archer_lock(a, false)
					a["state"] = "idle"
					a["t"] = randf_range(2.5, 4.5)
			"touch":
				# Atış arası: sadaktan yedek ok yoklar
				_archer_pose(a, false)
				if float(a["t"]) <= 0.0:
					_archer_lock(a, false)
					a["state"] = "idle"
					a["t"] = randf_range(3.0, 6.0)
			"aim":
				# Yüzeni izleyip yayı gerer, nişanda bekler (ok kirişte, çeken el çenede), sonra gevşer: atış anı kısa
				# olduğundan oynanış karesinde germe pozu hiç görünmüyordu (tur 3)
				a["at"] = player.global_position
				sol.face_toward(player.global_position)
				a["drawn"] = float(a.get("drawn", 0.0)) + delta
				_archer_pose(a, float(a["drawn"]) > 0.25)
				if float(a["t"]) <= 0.0:
					_archer_lock(a, false)
					a["state"] = "idle"
					a["drawn"] = 0.0
					a["t"] = randf_range(0.8, 2.0)
			_:
				# Boştayken yüzen adamı gözler; çoğu zaman yayı gerip nişan alır, arada sadağa uzanır
				if float(a["t"]) <= 0.0 and player.floating:
					sol.face_toward(player.global_position)
					var r := randf()
					a["at"] = player.global_position
					if r < 0.6:
						_archer_lock(a, true)
						a["state"] = "aim"
						a["drawn"] = 0.0
						a["t"] = randf_range(1.6, 2.6)
					elif r < 0.85:
						_archer_lock(a, true)
						a["state"] = "touch"
						a["t"] = 0.5
					else:
						a["t"] = 0.6


var _watch_fire: Node3D
var _cleared := false
var _watch_stick: Node3D
var _watch_lock := false
var _watch_t := 0.0


## Kıyıdaki iki gözcü yüzerken iş başında (tur 3: eskiden hiç kıpırdamıyorlardı): Hasan sağ elini alnına siper edip
## suya, yüzene bakar, sol eli belinde; Hüseyin ateşin başında öne eğilmiş, değnekle közü karıştırır. Kıyıya çıkılınca
## (konuşma, yakalama) bırakırlar.
func _watchers_tick(delta: float) -> void:
	var w := _watchers()
	var on := player.floating and phase != "done" and w.size() >= 2 and _watch_fire != null and (w[0] as Node3D).is_visible_in_tree()
	if on != _watch_lock:
		_watch_lock = on
		for s: Soldier in w:
			if s.rig == null:
				continue
			if on:
				s.rig.lock += 1
			else:
				s.rig.lock = maxi(0, s.rig.lock - 1)
				for n: Node3D in [s.rig.arm_l, s.rig.arm_r, s.rig.elbow_l, s.rig.elbow_r]:
					if n:
						n.rotation = Vector3.ZERO
				if s.rig.body:
					s.rig.body.rotation = Vector3.ZERO
		if _watch_stick:
			_watch_stick.visible = on
		# İş başındayken birbirlerine dönmezler; bırakınca yine konuşmaya dönük
		if w.size() >= 2:
			w[0].look_target = null if on else w[1]
			w[1].look_target = null if on else w[0]
	if not on:
		return
	_watch_t += delta
	var h: Soldier = w[0]
	var u: Soldier = w[1]
	# Hasan: suya döner, eli alnında siper
	var to := player.global_position - h.global_position
	to.y = 0.0
	if to.length() > 0.5:
		h.global_rotation.y = lerp_angle(h.global_rotation.y, atan2(to.x, to.z), clampf(delta * 2.0, 0.0, 1.0))
	var hf := h.global_basis.z.normalized()
	var hr := Vector3.UP.cross(hf).normalized()
	var head := h.global_position + Vector3(0, 1.62, 0)
	if h.rig.arm_r and h.rig.elbow_r:
		Rig.reach(h.rig.arm_r, h.rig.elbow_r, head + hf * 0.2 - hr * 0.02 + Vector3(0, 0.12 + sin(_watch_t * 0.7) * 0.01, 0), Vector3.DOWN - hr)
	if h.rig.arm_l and h.rig.elbow_l:
		Rig.reach(h.rig.arm_l, h.rig.elbow_l, h.global_position + Vector3(0, 0.98, 0) + hr * 0.3 + hf * 0.04, hr - hf)
	if h.rig.body:
		h.rig.body.rotation.x = 0.06 + sin(_watch_t * 0.5) * 0.02
	# Hüseyin: ateşe dönük, öne eğik, değnekle közü karıştırır (küçük daireler)
	var fp := _watch_fire.global_position
	var tf := fp - u.global_position
	tf.y = 0.0
	if tf.length() > 0.2:
		u.global_rotation.y = lerp_angle(u.global_rotation.y, atan2(tf.x, tf.z), clampf(delta * 3.0, 0.0, 1.0))
	if u.rig.body:
		u.rig.body.rotation.x = 0.32
	var uf := tf.normalized() if tf.length() > 0.2 else u.global_basis.z
	var ur := Vector3.UP.cross(uf).normalized()
	var stir := Vector3(cos(_watch_t * 2.6), 0, sin(_watch_t * 2.6)) * 0.08
	var hand := u.global_position + uf * 0.42 + Vector3(0, 0.98, 0) + stir + ur * 0.08
	if u.rig.arm_r and u.rig.elbow_r:
		Rig.reach(u.rig.arm_r, u.rig.elbow_r, hand, Vector3.DOWN + ur)
	if u.rig.arm_l and u.rig.elbow_l:
		Rig.reach(u.rig.arm_l, u.rig.elbow_l, u.global_position + Vector3(0, 0.62, 0) + uf * 0.3 - ur * 0.16, Vector3.DOWN - ur)
	if _watch_stick and u.rig.elbow_r:
		var hp := u.rig.elbow_r.to_global(u.rig.elbow_r.get_meta("hand", Vector3(0, -0.26, 0.01)))
		var tip := fp + Vector3(0, 0.1, 0) + stir * 0.6
		var d := (tip - hp)
		if d.length() > 0.05:
			var dn := d.normalized()
			var side := dn.cross(Vector3.UP if absf(dn.y) < 0.95 else Vector3.RIGHT).normalized()
			_watch_stick.global_transform = Transform3D(Basis(side, dn, side.cross(dn)), hp + dn * 0.4)


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
		# Görünen arazi (kumsal dahil) çarpışma yüzeyinden yüksekse ona basılır: okçular yamaca gömülüyordu (tur 3)
		return maxf((hit["position"] as Vector3).y, level.surface_h(x, z))
	return level.surface_h(x, z)


## Çıkış yeri ve yüzme hedefi seçimi için zemin (tur 2'deki ölçümün aynısı: oynanış yolu değişmesin). Kumsal artık
## arazinin kendisi ve kum kutusunun yalnız çarpışması kaldı; eski ölçüm kutunun üstünü (suyun 20 cm üstü) görüyordu.
func _ground_y_path(x: float, z: float) -> float:
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
	var end := level.end_point()
	if absf(x - end.x) <= 40.0 and z >= end.z - 3.0 and z <= end.z + 7.0:
		return level.water_y + 0.2
	if absf(x - end.x) < 46.0 and z < end.z - 3.0 and z > end.z - 10.0:
		return level.water_y - 1.6
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
		if absf(_ground_y_path(p.x + o.x, p.z + o.z) - p.y) > 0.6:
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
## Yakalama: askerler bağırarak koşup gelir, biri Tolga'yı kolundan tutar (eskiden 2.6 m önde belirip bağırıyor,
## sonra göz önünde siliniyorlardı; QA_DERSLER "yakalama yüz yüze").
func _seize(guards: Array[Node3D], at: Vector3) -> void:
	var fwd := _shore_look(at) - at
	fwd.y = 0.0
	fwd = fwd.normalized()
	var side := Vector3(-fwd.z, 0.0, fwd.x)
	# Kol boyuna gelirler: ayakları her adımda kuma/çimene basar (eskiden doğrusal tween eğimde havada yürütüyordu, bazen
	# 6 m'de kalıp boşluğa uzanıyorlardı). Oyuncunun önünde, 1 m ileride ve 0,55 m yanda dururlar: yüzleri kadrajda,
	# yolları oyuncuya varmadan biter. Tur 4'te oyuncunun hizasında (0,3 m önde, 1,05 m yanda) duruyorlardı; tutarken
	# 0,4 rad eğilince başları kameranın 15 cm önüne ve 45 cm yanına, omuzları kameranın arkasına geçiyordu: fragmanda
	# askerler kameranın içinden geçiyordu (sonuç 2.1 ve 2.4; denetim _seize_audit).
	for i in guards.size():
		Stage.walk_on_ground(guards[i], at + fwd * SEIZE_AHEAD + side * (-SEIZE_SIDE if i == 0 else SEIZE_SIDE), _ground_y, 3.2, at + Vector3(0, 1.4, 0))
	await Handover.wait(self, 0.05 if Stage.fast() else 0.3)


## Askerler varana dek bekler (en çok 4 sn).
func _seize_done(guards: Array[Node3D]) -> void:
	var t := 0.0
	while t < 4.0:
		var busy := false
		for g in guards:
			if is_instance_valid(g) and g.get_meta("stage_walk", false):
				busy = true
		if not busy:
			return
		await get_tree().process_frame
		t += get_process_delta_time()


## İki asker Tolga'yı iki bileğinden tutar: Tolga'nın sol eli de görünür (yarı kalkık), sağdaki asker sağ bileği,
## soldaki sol bileği kavrar; askerler öne eğilir, eller bileklerin üstünde her karede yerinde kalır (Stage.grip_hold).
## Eskiden hedef kameranın önünde boşluktaydı: kol boşluğa uzanıyor, yumruk havada kalıyordu.
func _grab_arms(guards: Array[Node3D], hold: float, lean := 0.22) -> void:
	player.free_hold = Vector3(-0.24, -0.2, -0.45)
	if GameState.autotest:
		_seize_audit(guards, hold)
	for i in mini(2, guards.size()):
		var g := guards[i]
		if g is Soldier:
			(g as Soldier).pose = "stand"
		Stage.face(g, player.global_position)
		var hand: Node3D = player.free_hand if i == 0 else player.hand
		if hand:
			Stage.grip_hold(g, hand, [Vector3(0, 0.035, 0.07)], hold + 4.0, lean)


## Yakalayan askerin gövdesi kameranın içinden ya da yanından geçiyor mu (test). Baş, omuzlar ve dirsekler kameranın
## yerelinde: kameranın 25 cm önünden geride ve görüş ekseninden 0,8 m'den yakınsa asker kameranın içinde/yanındadır.
## Unclip.walk_audit (WALKTHRU) bunu göremez: yalnız görünen StaticBody3D'lere ışın atar (oyuncu CharacterBody3D) ve
## testte (PACE dışı) askerler yürümeden varır (Stage.fast); tutarken öne eğilme de yürüme sayılmaz.
func _seize_audit(guards: Array[Node3D], seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		await get_tree().process_frame
		t += get_process_delta_time()
		if not is_instance_valid(player) or player.camera == null:
			return
		for g in guards:
			if not is_instance_valid(g):
				continue
			var rg := Handover.rig_of(g)
			if rg == null:
				continue
			for part: Node3D in [rg.head, rg.arm_l, rg.arm_r, rg.elbow_l, rg.elbow_r]:
				if part == null:
					continue
				var lp := player.camera.to_local(part.global_position)
				if lp.z > -0.25 and Vector2(lp.x, lp.y).length() < 0.8:
					print("WALKTHRU scene=chapter2.tscn who=%s at=%s by=player/camera part=%s local=%s src=chapter2.gd:_seize" % [
						g.get_meta("speaker", g.name), part.global_position.snapped(Vector3.ONE * 0.1), part.name,
						lp.snapped(Vector3.ONE * 0.01)])
					return


## Kızaktan uzağa, kıyı boyunca bakar (kadırga arkada kalır).
func _shore_look(landing: Vector3) -> Vector3:
	var away := 1.0 if landing.x >= level.end_point().x else -1.0
	return Vector3(landing.x + away * 4.0, landing.y + Player.EYE - 0.45, landing.z - 0.4)


## Kıyıdaki iki asker, oyuncunun bakış yönünde 6.5 m önünde; kararma açılınca koşarak gelir (_seize).
func _shore_guards(at: Vector3, look_at_p: Vector3) -> Array[Node3D]:
	var out: Array[Node3D] = []
	var fwd := look_at_p - at
	fwd.y = 0.0
	fwd = fwd.normalized()
	var side := Vector3(-fwd.z, 0.0, fwd.x)
	for k: float in [-1.0, 1.0]:
		var p := at + fwd * 6.5 + side * (k * 1.6)
		var g := Soldier.new(Color("b3262d") if k < 0.0 else Color("2f5fa8"), "point", "bork" if k < 0.0 else "turban")
		g.set_meta("speaker", "SPK_SOLDIER")       # "Yakalayın!" diyen bu: portre ve sahneleme denetimi onu bulsun
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
		# Tur 4: kütük kadrajı kaplıyordu (2,3 m yanında, sonra %40 yaklaşıp 1,4 m'ye iniyordu): biraz geride ve yanda,
		# zincire çaprazdan bakar (pull %30 → son uzaklık ≈2,3 m); kütük sol altta, uzakta zincirin devamı kalır
		player.global_position = _water(cp + side * 2.8 - along * 1.8)
		player.face(Vector3(cp.x, level.water_y + 0.6, cp.z) + along * 12.0 - side * 1.0)
		await hud.fade_to(0.0, 0.6)
	else:
		player.face(cp + Vector3(20, 1.0, -60))
	# Zincire uzanıp tutunur: sol el kütüğü kavrar, Tolga kendini ona doğru çeker
	var to_me := Vector3(player.global_position.x - cp.x, 0.0, player.global_position.z - cp.z).normalized()
	var grip := Vector3(cp.x, level.water_y + 0.3, cp.z) + to_me * 0.45
	await player.reach_grab(grip)
	# El ıslak kütüğe şaplar: suda iki halka, sıçrayan damlalar, kütüğün çevresinde köpük (tur 3: belirgin)
	# (halkalar kütüğün oyuncu tarafında: kütüğün ardında kalınca görünmüyordu)
	var near_side := grip + to_me * 0.55
	level.ripple(near_side, 0.25, 2.2, 1.6, 0.75)
	level.ripple(near_side, 0.6, 3.6, 2.6, 0.45)
	level.drops(near_side, 14, 2.4)
	level.splash(grip + to_me * 0.3)
	var pull := player.global_position.lerp(Vector3(grip.x, player.global_position.y, grip.z), 0.3)
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
		# Suya gömülüş: büyük sıçrama, üç halka, kabarcıklar (tur 3: su tepkisi seçilmiyordu)
		var fwd0 := -player.global_transform.basis.z
		fwd0.y = 0.0
		var fall_at := player.global_position + fwd0.normalized() * 1.4
		level.splash(fall_at, true)
		level.ripple(player.global_position, 0.4, 2.6, 1.3, 0.55)
		level.ripple(player.global_position, 0.6, 3.8, 2.0, 0.35)
		level.ripple(grip, 0.3, 2.0, 1.4, 0.5)
		level.drops(fall_at, 18, 3.0)
		level.bubbles(Vector3(fall_at.x, level.water_y - 1.0, fall_at.z), 1.2)
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
		_seize(guards, landing)
		await _say("SPK_SOLDIER", "D2_S_23")
		await _seize_done(guards)
		_grab_arms(guards, 3.5)
		await Handover.wait(self, 0.15 if Stage.fast() else 1.65)     # eski tek kollu uzanışın süresi (0,35 + 1,0 + 0,3)
		await _budget()
		player.free_hold = Vector3.INF
		for g in guards:
			g.queue_free()


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
	_flash_prompt(_swim_hint(), 12.0)      # 6 sn'ydi: yüzme tuşlarının tek gösterildiği yer
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
			# Ok kıyıdaki bir okçunun yayından çıkar: 0,62 sn gerer, ok 0,45 sn uçar (halka sönerken suya saplanır)
			var shot := _archer_shoot(at, 0.62, 0.45)
			pending.append({"pos": at, "t": 1.1, "shot": shot})
		for a in pending.duplicate():
			a["t"] -= dt
			if a["t"] <= 0.0:
				pending.erase(a)
				var ap: Vector3 = a["pos"]
				if not a["shot"]:
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
	_stow(false)
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
			GameState.change_scene("res://scenes/chapter3.tscn")
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
	return GameState.voice_len(vs) if vs else fallback


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
	await get_tree().create_timer(0.6, false).timeout
	# 1. Varış: arkadaki kadırgaya bakış
	ship_s = START_S - START_GAP - BOW
	level.set_ship_s(ship_s)
	player.global_position = level.s_to_world(START_S, 0.0, 0.3)
	player.face(level.s_to_world(ship_s + BOW - 2.0, 0.0, 2.8))
	hud.bark("SPK_TOLGA", "D2_T_03", 30.0)
	await get_tree().create_timer(0.5, false).timeout
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
	await get_tree().create_timer(0.35, false).timeout
	await _shot("c2_09_ucus.png")

	# 3c. Sualtı
	player.global_position = Vector3(land.x, level.water_y - Player.EYE - 1.4, land.z)
	player.face(land + Vector3(-6, -0.4, -20))
	level.bubbles(player.global_position + Vector3(1.2, Player.EYE - 1.0, -4.0), 2.0)
	hud.bark("SPK_HIKMET", "D2_H_09", 30.0)
	await get_tree().create_timer(0.8, false).timeout
	await _shot("c2_10_sualti.png")
	# 3d. Sualtı: yosun ormanı, balıklar ve batık kadırga (zincir yolu)
	var cp0 := level.chain_point()
	var uw := land.lerp(cp0, 0.45)
	player.global_position = Vector3(uw.x, level.water_y - Player.EYE - 1.5, uw.z)
	var wk := land.lerp(cp0, 0.62) + Vector3(-4.0, 0, 3.0)
	player.face(Vector3(wk.x, level.water_y - 3.6, wk.z))
	level.bubbles(player.global_position + Vector3(0.5, Player.EYE - 0.6, -1.0), 2.0)
	hud.bark("SPK_TOLGA", "D2_T_AMPHORA", 30.0)
	await get_tree().create_timer(0.8, false).timeout
	await _shot("c2_11_batik.png")
	# 3e. Serbest yüzme: ok uyarısı, yüzen kütük, kayıp fes, demirli kadırgalar
	player.global_position = _water(land.lerp(level.shore_point(), 0.1))
	player.face(level.fez_float.global_position + Vector3(-2, 0.2, -6))
	level.arrow_warning(player.global_position + Vector3(-1.2, 0, -3.0), 5.0)
	hud.set_objective(tr("UI_OBJ_SWIM_SHORE"))
	hud.set_chase(tr("UI_SWIM_BREATH"), 0.7, false)
	hud.set_prompt(_swim_hint())
	await get_tree().create_timer(0.4, false).timeout
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
	await get_tree().create_timer(1.0, false).timeout
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

