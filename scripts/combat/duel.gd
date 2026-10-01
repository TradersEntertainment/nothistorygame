class_name Duel
extends Control
## Kılıç ve kalkan dövüşü (Mount & Blade'in sade hâli), birinci şahıs. Kamera serbesttir (kilit yok).
##   Vuruş yönü hareket tuşundan: A basılıyken soldan, D basılıyken sağdan, ikisi de değilse yukarıdan (ekrandaki ok).
##   Sol tık (RT): vur. Rakibin mavi yayı o taraftaysa (muhafız) vuruş seker: başka yönden vur.
##   Sağ tık basılı (LT): kalkanı kaldır. Önden gelen her darbeyi tutar (dayanıklılık yer).
##   Rakibin kırmızı oku dolarken son anda (PARRY_WIN) kalkan kalkarsa → kalkanla karşılama: rakip sendeler, açık kalır.
##   Dayanıklılık biterse kalkan düşer (bir süre kaldırılamaz).
## Autotest: bot doğru yönde savuşturur ve açık rakibe muhafızsız yönden vurur.

signal finished(won: bool)

enum P { IDLE, WINDUP, STRIKE, RECOVER, STAGGER }
const PARRY_WIN := 0.28
const P_WINDUP := 0.3
const P_STRIKE := 0.12
const P_RECOVER := 0.3
const P_DAMAGE := 26.0
const REACH := 2.8

var player: Player
var hud: Hud
var enemies: Array[Duelist] = []
var target: Duelist
var active := false
var blade := "kilij"
var hp := 100.0
var stamina := 100.0
var aim := Duelist.DIR_TOP
var blocking := false
var _block_t0 := -10.0
var pstate := P.IDLE
var _pdir := Duelist.DIR_TOP
var _pt := 0.0
var _mouse := Vector2.ZERO
var _guard_broken := 0.0
var _flash := 0.0
var _flash_col := Color.RED
var _msg := ""
var _msg_t := 0.0
var _now := 0.0
var sword_pivot: Node3D
var sword: Node3D
var parries := 0
var shield_pivot: Node3D
var _shield_hit := 0.0
var hits_taken := 0
var kills := 0
var god := false             # öğretici / hikâye: oyuncu ölmez, en az 1 can kalır
## Hikâye: düellonun canı oyuncunun canıdır (darbeler player.hurt ile; can bitince düello kaybedilir, oyuncu yere
## düşer ama ölmez). Arena kendi canını tutar (link_player kapalı).
var link_player := false
## Dalga motoru: sırada bekleyen takviye sayısı. Son görünen rakip düşse de takviye varken düello bitmez.
var reserve := 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


## Dövüşü başlat. p: oyuncu, h: HUD (bu denetleyici onun çocuğu olur), list: rakipler.
func start(p: Player, list: Array[Duelist], p_blade := "kilij") -> void:
	player = p
	blade = p_blade
	enemies = list
	for e in enemies:
		e.duel = self
		e.target = player
		e.died.connect(_on_died)
	hp = player.hp if link_player else 100.0
	stamina = 100.0
	pstate = P.IDLE
	active = true
	visible = true
	player.combat = true
	player.show_remote(false)
	_build_sword()
	_retarget()


func stop() -> void:
	active = false
	visible = false
	if player:
		player.combat = false
		player.lock_target = null
	if sword_pivot:
		sword_pivot.queue_free()
		sword_pivot = null
	if shield_pivot:
		shield_pivot.queue_free()
		shield_pivot = null


func player_aim() -> int:
	return aim


## Rakip oyuncunun vuruş hazırlığını görünce kılıcını siper eder (görsel).
func blocking_visible_for(e: Duelist) -> bool:
	return pstate == P.WINDUP and target == e


func alive_enemies() -> Array[Duelist]:
	var out: Array[Duelist] = []
	for e in enemies:
		if e.alive():
			out.append(e)
	return out


func _on_died(d: Duelist) -> void:
	kills += 1
	_say_msg(tr("UI_DUEL_YIELD") if d.has_meta("yield") else tr("UI_DUEL_DOWN"), Color("ffd070"))
	if alive_enemies().is_empty() and reserve <= 0:
		# Son rakip düştü: ağır çekim ve zafer vurgusu
		Fx.slowmo(0.25, 0.9, 0.5)
		Audio.stinger("victory")
		await get_tree().create_timer(0.8).timeout
		if active:
			stop()
			finished.emit(true)
	else:
		_retarget()


## Düello sürerken yeni rakip katılır (dalga takviyesi).
func add_enemy(e: Duelist) -> void:
	enemies.append(e)
	e.duel = self
	e.target = player
	e.died.connect(_on_died)
	if target == null or not target.alive():
		_retarget()


func _retarget_view() -> void:
	var fwd := -player.camera.global_transform.basis.z
	var best: Duelist = null
	var bs := -INF
	for e in alive_enemies():
		var to := e.global_position + Vector3(0, 1.2, 0) - player.camera.global_position
		var d := to.length()
		var score := fwd.dot(to.normalized()) * 4.0 - d * 0.15
		if score > bs:
			bs = score
			best = e
	target = best


func _retarget() -> void:
	var best: Duelist = null
	var bd := INF
	for e in alive_enemies():
		var d := e.global_position.distance_to(player.global_position)
		if d < bd:
			bd = d
			best = e
	target = best


# ================================================================ girdi

func _input(event: InputEvent) -> void:
	if not active or player == null or player.frozen:
		return
	if event.is_action_pressed("sword_attack"):
		attack(aim)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("sword_block"):
		_block_t0 = _now
		get_viewport().set_input_as_handled()


## Vuruş yönü: A soldan, D sağdan, yoksa yukarıdan (kolda sol çubuk).
func _aim_from_keys() -> int:
	var x := Input.get_axis("move_left", "move_right")
	if x < -0.4:
		return Duelist.DIR_LEFT
	if x > 0.4:
		return Duelist.DIR_RIGHT
	return Duelist.DIR_TOP


func attack(d: int) -> void:
	if pstate != P.IDLE or stamina < 12.0 or blocking:
		return
	_pdir = d
	pstate = P.WINDUP
	_pt = 0.0
	stamina -= 16.0


func _process(delta: float) -> void:
	if not active:
		return
	_now += delta
	_flash = maxf(0.0, _flash - delta * 2.5)
	_msg_t = maxf(0.0, _msg_t - delta)
	_guard_broken = maxf(0.0, _guard_broken - delta)
	if not GameState.autotest:
		aim = _aim_from_keys()
	blocking = (Input.is_action_pressed("sword_block") or (GameState.shots_dir != "" and blocking)) and _guard_broken <= 0.0 and pstate == P.IDLE
	if GameState.autotest:
		_bot()
	# Dayanıklılık yenilenir
	if pstate == P.IDLE and not blocking:
		stamina = minf(100.0, stamina + delta * 22.0)
	# Hedef: bakılan yöndeki en yakın rakip (kamera kilidi yok)
	_retarget_view()
	_player_tick(delta)
	_pose_sword(delta)
	queue_redraw()


func _player_tick(delta: float) -> void:
	_pt += delta
	match pstate:
		P.WINDUP:
			if _pt >= P_WINDUP:
				pstate = P.STRIKE
				_pt = 0.0
				Audio.sfx("whoosh_fly", -8.0, 1.8)
				_resolve_player_swing()
		P.STRIKE:
			if _pt >= P_STRIKE:
				pstate = P.RECOVER
				_pt = 0.0
		P.RECOVER, P.STAGGER:
			if _pt >= (P_RECOVER if pstate == P.RECOVER else 0.6):
				pstate = P.IDLE
				_pt = 0.0


func _resolve_player_swing() -> void:
	var e := target
	if e == null or not e.alive():
		return
	var to := e.global_position - player.global_position
	to.y = 0.0
	var fwd := -player.global_transform.basis.z
	fwd.y = 0.0
	if to.length() > REACH or fwd.normalized().dot(to.normalized()) < 0.45:
		return
	var r := e.take_swing(_pdir, P_DAMAGE)
	match r:
		"blocked":
			_say_msg(tr("UI_DUEL_BLOCKED"), Color("9fb4ff"))
			pstate = P.STAGGER
			_pt = 0.0
			player.shake(0.15)
			Fx.hitstop(0.03)
		"hit":
			Audio.stinger("hit", -3.0)
			Fx.hitstop(0.06)
			Fx.trauma(0.25)
		"kill":
			# Son darbe: kısa donma, ağır çekim, görüş darbesi
			Audio.stinger("kill")
			Fx.hitstop(0.09)
			Fx.slowmo(0.3, 0.55, 0.35)
			Fx.fov_punch(8.0, 0.4)
			Fx.trauma(0.35)


## Rakibin darbesi indi.
func enemy_strike(e: Duelist, d: int) -> void:
	if not active:
		return
	var dist := e.global_position.distance_to(player.global_position)
	if dist > REACH + 0.4:
		return
	var just := _now - _block_t0
	var to := e.global_position - player.global_position
	to.y = 0.0
	var fwd := -player.global_transform.basis.z
	fwd.y = 0.0
	var facing := fwd.normalized().dot(to.normalized()) > 0.35
	if blocking and facing and just <= PARRY_WIN:
		parries += 1
		e.parried()
		Audio.stinger("parry")
		Vfx.dust(get_tree().current_scene, e.global_position + Vector3(0, 1.4, 0), 0.2)
		# Parry: vuruş "oturur" (donma), rakip ağır çekimde sendeler, ekran kenarı altın
		Fx.hitstop(0.08)
		Fx.slowmo(0.4, 0.35, 0.25)
		Fx.edge(Color("ffc040"), 0.45, 0.35)
		Fx.fov_punch(4.0, 0.3)
		_say_msg(tr("UI_DUEL_PARRY"), Color("ffd070"))
		_flash = 0.6
		_flash_col = Color("ffd070")
		stamina = minf(100.0, stamina + 15.0)
		return
	if blocking and facing:
		stamina -= 14.0
		Audio.sfx("kick_metal", -6.0, 1.3)
		player.shake(0.2)
		_say_msg(tr("UI_DUEL_BLOCK"), Color("9fb4ff"))
		if stamina <= 0.0:
			stamina = 0.0
			_guard_broken = 1.2
			_say_msg(tr("UI_DUEL_GUARDBREAK"), Color("ff7a5a"))
		_shield_hit = 0.25
		return
	hits_taken += 1
	if link_player:
		player.hurt(e.damage, e.global_position, true)
		hp = player.hp
	else:
		hp -= e.damage
	if god:
		hp = maxf(hp, 1.0)
	player.shake(0.6)
	_flash = 1.0
	_flash_col = Color("ff3a2a")
	Fx.hitstop(0.05)
	if not link_player:          # bağlıyken kenar, ses ve yatışı player.hurt verir
		Audio.stinger("hurt", -4.0)
		Fx.edge(Color("ff2a1a"), 0.7, 0.45)
		_recoil(to)
	if pstate == P.WINDUP:
		pstate = P.STAGGER
		_pt = 0.0
	if hp <= 0.0:
		hp = 0.0
		stop()
		finished.emit(false)


## Yenen darbe: kamera darbenin geldiği yana yatar (~4°); oyuncu kamerası yatışı her karede kendiliğinden düzeltir.
func _recoil(to_enemy: Vector3) -> void:
	if player == null or player.camera == null or float(GameState.settings.get("fx", 1.0)) <= 0.0:
		return
	var right := player.global_transform.basis.x
	var side := signf(right.dot(to_enemy)) if to_enemy.length() > 0.01 else 1.0
	player.camera.rotation.z += deg_to_rad(4.0) * side


func _say_msg(t: String, c: Color) -> void:
	_msg = t
	_msg_t = 0.9
	_flash_col = c if _flash <= 0.0 else _flash_col


## Test botu: doğru yönde son anda siper (savuşturma), açık rakibe muhafızsız yönden vuruş.
var _bot_hold := 0.0
func _bot() -> void:
	# Test "lose": oyuncu savunmasız durur (yenilginin sonucu bozduğu denetlenir)
	if GameState.autotest_variant.ends_with("lose") and link_player:
		blocking = false
		return
	var e := target
	if e == null:
		e = alive_enemies()[0] if not alive_enemies().is_empty() else null
		target = e
	if e == null:
		return
	player.face(e.global_position + Vector3(0, 1.45, 0))
	if e.state == Duelist.St.WINDUP and e.time_to_impact() < PARRY_WIN * 0.7:
		if not blocking:
			aim = e.dir
			_block_t0 = _now
		blocking = true
		_bot_hold = 0.3
		return
	if _bot_hold > 0.0:
		_bot_hold -= get_process_delta_time()
		blocking = true
		return
	blocking = false
	if pstate == P.IDLE and e.state in [Duelist.St.STAGGER, Duelist.St.RECOVER, Duelist.St.IDLE] and stamina > 30.0:
		var d := (e.guard + 1) % 3
		aim = d
		attack(d)


# ================================================================ birinci şahıs kılıç

func _build_sword() -> void:
	if sword_pivot:
		sword_pivot.queue_free()
	sword_pivot = Node3D.new()
	player.camera.add_child(sword_pivot)
	sword = Blades.kilij(sword_pivot) if blade == "kilij" else Blades.spathion(sword_pivot)
	# Tutan el (yumruk)
	Props.ball(sword_pivot, 0.045, Vector3(0, -0.01, 0.0), Color("e6ad88"), Vector3(1.1, 1.3, 1.0), 8)
	Props.strip_outlines(sword_pivot)
	sword_pivot.scale = Vector3.ONE * 0.62
	sword_pivot.position = Vector3(0.28, -0.25, -0.55)
	# Kalkan: sol elde; sağ tıkla kalkar, yüzü ve gövdeyi örter
	shield_pivot = Node3D.new()
	player.camera.add_child(shield_pivot)
	var sh := Blades.shield(shield_pivot, Color("7a2a24") if blade == "spathion" else Color("2f5a4a"))
	sh.rotation_degrees = Vector3(0, 180, 0)
	Props.strip_outlines(shield_pivot)
	shield_pivot.scale = Vector3.ONE * 0.55
	shield_pivot.position = Vector3(-0.42, -0.42, -0.6)


## [konum, açı(derece)] kamera uzayında.
func _sword_pose() -> Array:
	var d := _pdir if pstate in [P.WINDUP, P.STRIKE] else aim
	var side := {Duelist.DIR_LEFT: -1.0, Duelist.DIR_RIGHT: 1.0}.get(d, 0.0) as float
	match pstate:
		P.WINDUP:
			if d == Duelist.DIR_TOP:
				return [Vector3(0.08, 0.22, -0.32), Vector3(40, 0, 0)]
			return [Vector3(side * 0.42, 0.06, -0.36), Vector3(20, 0, -side * 62)]
		P.STRIKE:
			if d == Duelist.DIR_TOP:
				return [Vector3(0.05, -0.34, -0.66), Vector3(-80, 0, 0)]
			return [Vector3(-side * 0.32, -0.22, -0.62), Vector3(-60, 0, side * 72)]
		P.STAGGER:
			return [Vector3(0.36, -0.4, -0.45), Vector3(-30, 0, -40)]
	if blocking:
		return [Vector3(0.42, -0.34, -0.5), Vector3(-30, 0, -20)]
	if d == Duelist.DIR_TOP:
		return [Vector3(0.4, -0.18, -0.55), Vector3(-10, 0, 22)]
	return [Vector3(side * 0.36, -0.3, -0.55), Vector3(-25, 0, -side * 35)]


func _pose_sword(delta: float) -> void:
	if sword_pivot == null:
		return
	if shield_pivot:
		_shield_hit = maxf(0.0, _shield_hit - delta)
		var up := blocking
		var sp := Vector3(-0.2, -0.2, -0.62) if up else Vector3(-0.42, -0.4, -0.6)
		var sr := Vector3(0, 25, 0) if up else Vector3(-35, 40, 10)
		if _shield_hit > 0.0:
			sp += Vector3(0, 0, 0.08)
		var ks := clampf(delta * 16.0, 0.0, 1.0)
		shield_pivot.position = shield_pivot.position.lerp(sp, ks)
		shield_pivot.rotation_degrees = shield_pivot.rotation_degrees.lerp(sr, ks)
	var pose := _sword_pose()
	var k := clampf(delta * (28.0 if pstate == P.STRIKE else 14.0), 0.0, 1.0)
	sword_pivot.position = sword_pivot.position.lerp(pose[0], k)
	var r: Vector3 = pose[1]
	sword_pivot.rotation_degrees = sword_pivot.rotation_degrees.lerp(r, k)


# ================================================================ HUD

func _draw() -> void:
	if not active:
		return
	var vs := size
	var c := vs * 0.5
	var font := ThemeDB.fallback_font
	# Yön okları: oyuncunun nişanı (beyaz), hedefin muhafızı (mavi yay), gelen saldırı (kırmızı, dolarak)
	var inc := -1
	var prog := 0.0
	if target and target.state == Duelist.St.WINDUP:
		inc = target.dir
		prog = target.windup_progress()
	for d in 3:
		var ang: float = [PI, 0.0, -PI * 0.5][d]
		var dv := Vector2(cos(ang), sin(ang))
		var p := c + dv * 96.0
		var col := Color(1, 1, 1, 0.28)
		if d == aim:
			col = Color("fff3d6") if not blocking else Color("9fe0ff")
		if d == inc:
			col = Color("ff3a2a").lerp(Color("ffd070"), 1.0 if prog > 1.0 - PARRY_WIN / maxf(target.windup_time, 0.1) else 0.0)
		_chevron(p, ang, 30.0 + (10.0 if d == aim else 0.0), col, d == inc or d == aim)
		if d == inc:
			draw_arc(c, 128.0, ang - 0.45, ang - 0.45 + 0.9 * prog, 16, Color("ff3a2a"), 7.0)
		if target and target.alive() and d == target.guard and target.state in [Duelist.St.IDLE, Duelist.St.RECOVER]:
			draw_arc(c, 70.0, ang - 0.42, ang + 0.42, 10, Color("6fa8ff"), 6.0)
	# Can ve dayanıklılık (sol alt)
	var b := Rect2(Vector2(40, vs.y - 90), Vector2(300, 16))
	draw_rect(b.grow(3), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(b.position, Vector2(b.size.x * hp / 100.0, b.size.y)), Color("d83a2a"))
	var sb := Rect2(Vector2(40, vs.y - 64), Vector2(300, 8))
	draw_rect(sb.grow(2), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(sb.position, Vector2(sb.size.x * stamina / 100.0, sb.size.y)), Color("e0c040") if _guard_broken <= 0.0 else Color("806020"))
	# Hedefin canı (üst orta)
	if target and target.alive():
		var tb := Rect2(Vector2(c.x - 200, 60), Vector2(400, 12))
		draw_rect(tb.grow(3), Color(0, 0, 0, 0.5))
		draw_rect(Rect2(tb.position, Vector2(tb.size.x * target.hp / target.max_hp, tb.size.y)), Color("d83a2a"))
		draw_string(font, tb.position + Vector2(0, -8), tr(target.name_key), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f2e6c9"))
		if target.state == Duelist.St.STAGGER:
			draw_string(font, tb.position + Vector2(260, -8), tr("UI_DUEL_OPEN"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffd070"))
	if _msg_t > 0.0:
		draw_string(font, c + Vector2(-80, 150), _msg, HORIZONTAL_ALIGNMENT_CENTER, 160, 24, Color(_flash_col, clampf(_msg_t * 2.0, 0.0, 1.0)))
	if _flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, vs), Color(_flash_col, _flash * 0.18))
	draw_string(font, Vector2(40, vs.y - 104), tr("UI_DUEL_HINT"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, 0.6))


func _chevron(p: Vector2, ang: float, s: float, col: Color, filled: bool) -> void:
	var dv := Vector2(cos(ang), sin(ang))
	var nv := Vector2(-dv.y, dv.x)
	var tip := p + dv * s * 0.6
	var a := p - dv * s * 0.4 + nv * s * 0.6
	var b := p - dv * s * 0.4 - nv * s * 0.6
	if filled:
		draw_colored_polygon(PackedVector2Array([tip, a, b]), col)
	else:
		draw_polyline(PackedVector2Array([a, tip, b]), col, 4.0)
