class_name Duel
extends Control
## Kılıç ve kalkan dövüşü (Mount & Blade'in sade hâli), birinci şahıs. Kamera serbesttir (kilit yok).
##   Vuruş yönü hareket tuşundan: A basılıyken soldan, D basılıyken sağdan, ikisi de değilse yukarıdan (ekrandaki ok).
##   Sol tık (RT): vur. Rakibin mavi yayı o taraftaysa (muhafız) vuruş seker: başka yönden vur.
##   Sağ tık basılı (LT): kalkanı kaldır. Önden gelen her darbeyi tutar (dayanıklılık yer).
##   Rakibin kırmızı oku dolarken son anda (PARRY_WIN) kalkan kalkarsa → kalkanla karşılama: rakip sendeler, açık kalır.
##   Dayanıklılık biterse kalkan düşer (bir süre kaldırılamaz).
## Autotest: bot doğru yönde savuşturur ve açık rakibe muhafızsız yönden vurur.
## Tekme ve bitirici hissi (beklenti → darbe → takip; donma, sarsıntı, katmanlı ses, öldürme kamerası): docs/COMBAT_FEEL.md

signal finished(won: bool)

enum P { IDLE, WINDUP, STRIKE, RECOVER, STAGGER, KICK, FINISH }
const PARRY_WIN := 0.28      # normal zorluk; gerçek pencere parry_win (zorluğa göre)
var parry_win := PARRY_WIN
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
## Tekme (F): sersemletir, kalkanı açar. Bitirici (E): sersemleyen rakibe tek darbe.
const KICK_CD := 2.5
const KICK_COST := 20.0
const KICK_REACH := 2.6     # adım + bacak: rakipler 2,4 m mesafede durur
var _kick_cd := 0.0
## Arena değiştiricileri: dayanıklılık dolum hızı ve oyuncu darbesi çarpanı
var stamina_regen := 1.0
var dmg_mult := 1.0
var kicks := 0
var finishers := 0
## Tekme zaman çizelgesi (sn): geriye yaslanıp bacağı toplama → darbe → bacak geri
const K_WIND := 0.14
const K_TOTAL := 0.5
var _kick_e: Duelist
var _kick_hit := false
var _cam_off := 0.0          # tekmenin kameraya eklediği eğim (rad); her karede farkı uygulanır, sonunda sıfırlanır
## Bitirici (öldürme kamerası, Skyrim/Assassin's Creed gibi): üçüncü şahıs yan açı, ağır çekim, kısa (~1,5 sn).
## Saldırı/tekme/E tuşu atlar. Hareket hassasiyeti ayarı (fx 0) ya da dar yer: birinci şahısta oynanır.
var killcam := false
var _fin_skip := false
var _fin_cam: Camera3D
var _fin_was_frozen := false
var _fin_hud_cine := false
var _fin_e: Duelist
var _fin_pose := ""          # birinci şahıs bitiricide kılıç pozu
var _double: Person          # oyuncunun üçüncü şahıs ikizi (öldürme kamerasında görünür)
var _double_anim: LimbAnim
var last_finisher := ""


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
	parry_win = GameState.diff("parry")
	stamina = 100.0
	pstate = P.IDLE
	active = true
	visible = true
	player.combat = true
	player.show_remote(false)
	add_to_group("active_duel")
	_build_sword()
	_make_double()
	_retarget()


func stop() -> void:
	_end_killcam()
	_reset_kick()
	active = false
	visible = false
	if is_in_group("active_duel"):
		remove_from_group("active_duel")
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
	GameState.combat_add("kills")
	_say_msg(tr("UI_DUEL_YIELD") if d.has_meta("yield") else tr("UI_DUEL_DOWN"), Color("ffd070"))
	if alive_enemies().is_empty() and reserve <= 0:
		# Bitirici kamerası bitmeden zafer akışı başlamaz (bölüm kamerayı devralmasın)
		while killcam and active and is_inside_tree():
			await get_tree().process_frame
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
	if killcam and active:
		# Öldürme kamerası atlanır (kısa, ama hiç beklemek istemeyen için)
		if event.is_action_pressed("sword_attack") or event.is_action_pressed("sword_kick") or event.is_action_pressed("sword_finish") \
				or event.is_action_pressed("continue"):
			_fin_skip = true
			get_viewport().set_input_as_handled()
		return
	if not active or player == null or player.frozen:
		return
	if event.is_action_pressed("sword_attack"):
		attack(aim)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("sword_block"):
		_block_t0 = _now
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("sword_kick"):
		kick()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("sword_finish") and _finish_ready():
		finish()
		get_viewport().set_input_as_handled()


## Vuruş yönü: A soldan, D sağdan, yoksa yukarıdan (kolda sol çubuk).
func _aim_from_keys() -> int:
	var x := Input.get_axis("move_left", "move_right")
	if x < -0.4:
		return Duelist.DIR_LEFT
	if x > 0.4:
		return Duelist.DIR_RIGHT
	return Duelist.DIR_TOP


## Tekme: menzil kısa (2,6 m: bir adım ve bacak), önde olmalı. Önce beklenti (oyuncu geriye yaslanır, bacağı toplar,
## kılıç dengede yukarı), K_WIND sonra darbe: kısa donma, sarsıntı, görüş darbesi, toz, katmanlı ses (gövde gümlemesi +
## bas + kalkanlıysa metal). Rakip sendeler ya da (saldırı hazırlığındaysa, sersemse, canı azsa) yere serilir.
func kick() -> void:
	if pstate != P.IDLE or blocking or _kick_cd > 0.0 or stamina < KICK_COST:
		return
	var e := target
	if e == null or not e.alive():
		return
	_kick_cd = KICK_CD
	stamina -= KICK_COST
	_kick_e = e
	_kick_hit = false
	pstate = P.KICK
	_pt = 0.0
	Audio.sfx("whoosh_fly", -11.0, 0.9)      # bacak toplanırken kumaş hışırtısı


## Tekme darbe anı.
func _kick_impact() -> void:
	_kick_hit = true
	var e := _kick_e
	Audio.sfx("whoosh_fly", -7.0, 1.5)
	if e == null or not is_instance_valid(e) or not e.alive():
		return
	var to := e.global_position - player.global_position
	to.y = 0.0
	var fwd := -player.global_transform.basis.z
	fwd.y = 0.0
	if to.length() > KICK_REACH + 0.35 or fwd.normalized().dot(to.normalized()) < 0.4:
		_say_msg(tr("UI_DUEL_KICK_MISS"), Color(1, 1, 1, 0.8))
		return
	var shielded := e.shield != null
	var r := e.kicked(player.global_position)
	if r == "":
		return
	kicks += 1
	var down := r == "down"
	if GameState.autotest:
		print("KICK result=%s" % r)
	# Katmanlı ses: gövdeye oturan tok darbe + bas (ağırlık) + kalkan tangırtısı
	Audio.sfx("land_thud", 0.0, 0.8 if down else 0.95)
	Audio.sfx("drum_boom", -9.0 if down else -12.0, 1.8)
	if shielded:
		Audio.sfx("kick_metal", -7.0, 0.85)
	Audio.duck(-6.0, 0.4)
	Fx.hitstop(0.09 if down else 0.07)
	Fx.trauma(0.5 if down else 0.35)
	Fx.fov_punch(6.0 if down else 4.0, 0.3)
	var sc := get_tree().current_scene as Node3D
	if sc:
		Vfx.dust(sc, e.global_position + Vector3(0, 1.0, 0) - to.normalized() * 0.3, 0.16)
		Vfx.dust(sc, e.global_position + Vector3(0, 0.05, 0), 0.22)
	# Oyuncu tekmeyle yarım adım öne
	var push := to.normalized() * 0.22
	if player.move_and_collide(push, true) == null:
		player.global_position += push
	if player.camera:
		player.camera.rotation.z += deg_to_rad(2.5)
	_say_msg(tr("UI_DUEL_KICK"), Color("ffd070"))


func _reset_kick() -> void:
	if player and is_instance_valid(player) and player.camera:
		player.camera.rotation.x -= _cam_off
		if player.leg:
			player.leg.visible = false
	_cam_off = 0.0


## Tekmenin kamera eğimi (rad, + yukarı bakış): beklentide geriye yaslanma, darbede öne silkinme, sonra sıfır.
func _kick_cam(u: float) -> float:
	if u < K_WIND:
		return 0.075 * smoothstep(0.0, K_WIND, u)
	if u < K_WIND + 0.08:
		return lerpf(0.075, -0.05, (u - K_WIND) / 0.08)
	return lerpf(-0.05, 0.0, smoothstep(K_WIND + 0.08, K_TOTAL, u))


## Bitirici darbe hazır mı: hedef sersemlemiş (savuşturma ya da tekmeyle) ya da yerde yatıyor, yakında ve önde
func _finish_ready() -> bool:
	var e := target
	if e == null or not e.alive() or pstate != P.IDLE or killcam:
		return false
	var down := e.state == Duelist.St.DOWN and e._t > 0.45 and e._t < Duelist.DOWN_LIE
	if e.state != Duelist.St.STAGGER and not down:
		return false
	var to := e.global_position - player.global_position
	to.y = 0.0
	# Tekme rakibi 1–2 m geri savurur: bitirici bir hamle öne atılarak o mesafeyi kapatır
	var reach := REACH + 1.6 if down else (REACH + 1.1 if e.stagger_kind == "kick" else REACH)
	return to.length() < reach


## Bitirici: bağlama göre bir hamle seçilir (araştırma: docs/COMBAT_FEEL.md).
##   yerde yatan → "ground" (üstüne eğilip aşağı saplama) · tekmeyle sendeleyen → "thrust" (öne atılıp gövdeden saplama)
##   nişan solda/sağda → "slash" (o yandan boydan boya kesiş) · yukarıda → "bash" (kabzayla yüze vurup yere serme,
##   yerdeyken saplama). Hikâyede de rakip gerçekten ölür (bitiriciyi oyuncu seçti); ceset yerde kalır.
func finish() -> void:
	var e := target
	if not _finish_ready():
		return
	finishers += 1
	stamina = maxf(0.0, stamina - 10.0)
	var kind := "bash"
	if e.state == Duelist.St.DOWN:
		kind = "ground"
	elif e.stagger_kind == "kick":
		kind = "thrust"
	elif aim != Duelist.DIR_TOP:
		kind = "slash"
	last_finisher = kind
	_run_finisher(kind, e)


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
	_kick_cd = maxf(0.0, _kick_cd - delta)
	if not GameState.autotest:
		aim = _aim_from_keys()
	blocking = (Input.is_action_pressed("sword_block") or (GameState.shots_dir != "" and blocking)) and _guard_broken <= 0.0 and pstate == P.IDLE
	if GameState.autotest and not killcam:
		_bot()
	# Dayanıklılık yenilenir
	if pstate == P.IDLE and not blocking:
		stamina = minf(100.0, stamina + delta * 22.0 * stamina_regen)
	# Hedef: bakılan yöndeki en yakın rakip (kamera kilidi yok)
	if not killcam:
		_retarget_view()
	# Tekmenin kamera eğimi: yalnız fark uygulanır (fareyle bakış bozulmaz), tekme bitince sıfıra döner
	if player.camera:
		var want := _kick_cam(_pt) if pstate == P.KICK else 0.0
		player.camera.rotation.x += want - _cam_off
		_cam_off = want
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
		P.KICK:
			if not _kick_hit and _pt >= K_WIND:
				_kick_impact()
			if _pt >= K_TOTAL:
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
	var r := e.take_swing(_pdir, P_DAMAGE * dmg_mult)
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
	if blocking and facing and just <= parry_win:
		parries += 1
		GameState.combat_add("parries")
		GameState.bump_stat("parries_total")
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
	GameState.combat_add("hits_taken")
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


## Düello dışından gelen isabet (tüfekçi kurşunu): kalkan tutmaz, can düellonun canından gider
func external_hit(amount: float, from: Vector3) -> void:
	if not active:
		return
	hits_taken += 1
	GameState.combat_add("hits_taken")
	if link_player:
		player.hurt(amount, from, true)
		hp = player.hp
	else:
		hp -= amount * GameState.diff("hazard")
		Audio.stinger("hurt", -4.0)
		Fx.edge(Color("ff2a1a"), 0.7, 0.45)
	if god:
		hp = maxf(hp, 1.0)
	player.stagger(0.5)
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
	if e.state == Duelist.St.WINDUP and e.time_to_impact() < parry_win * 0.7:
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
	# Savuşturmayla sersemleyene tekme (bazen): yere serer, sonra yerdeki bitirici denenir
	if pstate == P.IDLE and e.state == Duelist.St.STAGGER and e.stagger_kind == "parry" and _kick_cd <= 0.0 and stamina > 30.0 \
			and e.global_position.distance_to(player.global_position) < KICK_REACH and kicks % 2 == 1:
		kick()
		return
	if _finish_ready() and randf() < 0.5:
		finish()
		return
	if pstate == P.IDLE and bool(e.get_meta("with_shield", false)) and e.state in [Duelist.St.IDLE, Duelist.St.RECOVER] \
			and _kick_cd <= 0.0 and stamina > 40.0 \
			and e.global_position.distance_to(player.global_position) < KICK_REACH and (kicks == 0 or randf() < 0.3):
		kick()
		return
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
	if pstate == P.FINISH:
		# Birinci şahıs bitirici (dar yerde ya da fx kapalıyken): saplama, kesiş, aşağı saplama
		match _fin_pose:
			"thrust_wind":
				return [Vector3(0.32, -0.3, -0.12), Vector3(-90, 0, 0)]
			"thrust":
				return [Vector3(0.04, -0.14, -0.9), Vector3(-90, 0, 0)]
			"slash_wind_l", "slash_wind_r":
				var s1 := -1.0 if _fin_pose.ends_with("l") else 1.0
				return [Vector3(s1 * 0.5, 0.1, -0.3), Vector3(20, 0, -s1 * 70)]
			"slash_l", "slash_r":
				var s2 := -1.0 if _fin_pose.ends_with("l") else 1.0
				return [Vector3(-s2 * 0.4, -0.25, -0.65), Vector3(-60, 0, s2 * 80)]
			"bash_wind", "bash":
				return [Vector3(0.45, -0.1, -0.35), Vector3(-20, 0, -40)]
			"down_wind":
				return [Vector3(0.1, 0.28, -0.3), Vector3(30, 0, 0)]
			"down":
				return [Vector3(0.05, -0.45, -0.7), Vector3(-150, 0, 0)]
	match pstate:
		P.KICK:
			# Denge: kılıç kolu yukarı ve yana açılır
			return [Vector3(0.52, -0.02, -0.42), Vector3(15, 0, -50)]
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
		if pstate == P.KICK:
			sp = Vector3(-0.55, -0.28, -0.5)
			sr = Vector3(-20, 60, 20)
		elif pstate == P.FINISH and _fin_pose.begins_with("bash"):
			sp = Vector3(-0.3, -0.2, -0.75) if _fin_pose == "bash_wind" else Vector3(-0.08, -0.12, -0.42)
			sr = Vector3(0, 20, 0)
		if _shield_hit > 0.0:
			sp += Vector3(0, 0, 0.08)
		var ks := clampf(delta * 16.0, 0.0, 1.0)
		shield_pivot.position = shield_pivot.position.lerp(sp, ks)
		shield_pivot.rotation_degrees = shield_pivot.rotation_degrees.lerp(sr, ks)
	_pose_leg()
	var pose := _sword_pose()
	var fast := pstate == P.STRIKE or (pstate == P.FINISH and _fin_pose in ["thrust", "slash_l", "slash_r", "down", "bash"])
	var k := clampf(delta * (28.0 if fast else 14.0), 0.0, 1.0)
	sword_pivot.position = sword_pivot.position.lerp(pose[0], k)
	var r: Vector3 = pose[1]
	sword_pivot.rotation_degrees = sword_pivot.rotation_degrees.lerp(r, k)


## Birinci şahıs tekme bacağı: toplanır (beklenti), hızla açılır (darbe), bir an tutulur (donma), geri iner.
func _pose_leg() -> void:
	var leg: Node3D = player.leg if player else null
	if leg == null:
		return
	leg.visible = pstate == P.KICK
	if not leg.visible:
		return
	var u := _pt
	# Bacak kalçadan (kameranın altı) öne-aşağı açılır: ayak rakibin karnı hizasında, görüşün alt yarısında kalır
	var rest := Vector3(0.12, -0.55, 0.15)
	var chamber := Vector3(0.11, -0.5, 0.12)
	var out := Vector3(0.07, -0.58, -0.08)
	if u < K_WIND:
		var a := smoothstep(0.0, K_WIND, u)
		leg.rotation_degrees.x = lerpf(5.0, -28.0, a)
		leg.position = rest.lerp(chamber, a)
	elif u < K_WIND + 0.06:
		var b := (u - K_WIND) / 0.06
		leg.rotation_degrees.x = lerpf(-28.0, 96.0, b * b)
		leg.position = chamber.lerp(out, b)
	elif u < 0.3:
		leg.rotation_degrees.x = 96.0
		leg.position = out
	else:
		var c := smoothstep(0.3, K_TOTAL, u)
		leg.rotation_degrees.x = lerpf(96.0, 5.0, c)
		leg.position = out.lerp(rest, c)


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
			col = Color("ff3a2a").lerp(Color("ffd070"), 1.0 if prog > 1.0 - parry_win / maxf(target.windup_time, 0.1) else 0.0)
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
		if target.state in [Duelist.St.STAGGER, Duelist.St.DOWN]:
			draw_string(font, tb.position + Vector2(260, -8), tr("UI_DUEL_OPEN"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffd070"))
			if _finish_ready():
				draw_string(font, c + Vector2(-120, 190), tr("UI_DUEL_FINISH_HINT"), HORIZONTAL_ALIGNMENT_CENTER, 240, 22, Color("ffd070"))
	# Görüş dışından gelen saldırı: ekran kenarında kırmızı ok (arkadan, yandan)
	var cam := player.camera
	for e in alive_enemies():
		if e == target or e.state != Duelist.St.WINDUP:
			continue
		var to := e.global_position - cam.global_position
		var local := cam.global_transform.basis.inverse() * to
		if -local.z > to.length() * 0.6:
			continue          # önde, görünüyor
		var ang := atan2(local.z, local.x)
		var dv := Vector2(cos(ang), sin(ang))
		var edge_p := c + dv * minf(c.x, c.y) * 0.85
		var pulse := 0.6 + 0.4 * sin(_now * 18.0)
		_chevron(edge_p, ang, 40.0, Color(1.0, 0.23, 0.16, pulse), true)
	if _msg_t > 0.0:
		draw_string(font, c + Vector2(-80, 150), _msg, HORIZONTAL_ALIGNMENT_CENTER, 160, 24, Color(_flash_col, clampf(_msg_t * 2.0, 0.0, 1.0)))
	if _flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, vs), Color(_flash_col, _flash * 0.18))
	draw_string(font, Vector2(40, vs.y - 104), tr("UI_DUEL_HINT"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, 0.6))
	draw_string(font, Vector2(40, vs.y - 122), tr("UI_DUEL_HINT2") + ("" if _kick_cd <= 0.0 else "  (%.0f)" % ceilf(_kick_cd)),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, 0.6))


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


# ================================================================ bitirici (öldürme kamerası)

func _flat(v: Vector3) -> Vector3:
	v.y = 0.0
	return v.normalized() if v.length() > 0.001 else -player.global_transform.basis.z


## Oyun zamanıyla bekler; atlanırsa ya da düello biterse hemen döner (kamera hiç takılı kalmaz).
func _wait(sec: float) -> void:
	var t := 0.0
	while t < sec and not _fin_skip and active and is_inside_tree():
		await get_tree().process_frame
		t += get_process_delta_time()


func _hud() -> Hud:
	return get_tree().get_first_node_in_group("hud") as Hud if is_inside_tree() else null


func _run_finisher(kind: String, e: Duelist) -> void:
	pstate = P.FINISH
	_pt = 0.0
	killcam = true
	_fin_skip = false
	_fin_e = e
	e.finishing = true
	e._kb = Vector3.ZERO
	_fin_was_frozen = player.frozen
	player.frozen = true
	var dir := _flat(e.global_position - player.global_position)
	player.face(e.global_position + Vector3(0, 1.1, 0))
	var third := _killcam_begin(e, dir)
	if GameState.autotest:
		print("FINISHER kind=%s cam=%s" % [kind, "third" if third else "first"])
	Audio.duck(-10.0, 1.4)
	Fx.slowmo(0.6, 0.3, 0.15)
	match kind:
		"thrust":
			await _fin_thrust(e, dir, third)
		"slash":
			await _fin_slash(e, dir, third, aim)
		"bash":
			await _fin_bash(e, dir, third)
		_:
			await _fin_ground(e, dir, third)
	await _wait(0.5)
	# Atlansa da (ya da düello bitse de) rakip ölü ve yerde olur
	if is_instance_valid(e):
		if e.alive():
			e.kill(true)
		if e._final_clip in ["", "?"]:
			e.collapse("Death01", 0.9, 1.4)
		e.finishing = false
	_end_killcam()
	_say_msg(tr("UI_DUEL_FINISH"), Color("ffd070"))


## Öldürme kamerası: dövüşün yanından (açık olan yandan), göğüs hizasında, darbeye doğru yavaşça yaklaşan kamera;
## oyuncunun ikizi görünür. Yer darsa ya da fx ayarı kapalıysa false (birinci şahıs bitirici).
func _killcam_begin(e: Duelist, dir: Vector3) -> bool:
	if float(GameState.settings.get("fx", 1.0)) <= 0.0 or _double == null or not is_instance_valid(_double):
		return false
	var a := player.global_position
	var b := e.global_position
	var mid := (a + b) * 0.5 + Vector3(0, 1.05, 0)
	var side := dir.cross(Vector3.UP).normalized()
	var best := Vector3.ZERO
	var best_c := 0.0
	for c: Vector3 in [(side - dir * 0.35).normalized(), (-side - dir * 0.35).normalized(), side, -side,
			(side - dir).normalized(), (-side - dir).normalized()]:
		var cl := _clearance(mid + Vector3(0, 0.25, 0), c, 3.3)
		if cl < 1.8 or cl <= best_c + 0.25:
			continue
		var p := mid + c * minf(cl - 0.4, 2.9) + Vector3(0, 0.3, 0)
		var aim_at := b + Vector3(0, 1.1, 0)
		if _clearance(p, (aim_at - p).normalized(), p.distance_to(aim_at)) < p.distance_to(aim_at) - 0.3:
			continue          # rakip kameradan görünmüyor (sütun, sandık)
		var hidden := false
		for o in alive_enemies():
			# Başka bir rakip kamerayla hedefin arasında duruyorsa o açı olmaz
			if o != e and Geometry3D.get_closest_point_to_segment(o.global_position + Vector3(0, 1.1, 0), p, aim_at).distance_to(o.global_position + Vector3(0, 1.1, 0)) < 0.55:
				hidden = true
		if hidden:
			continue
		best_c = cl
		best = c
	if best_c < 1.8:
		return false
	var dist := minf(best_c - 0.4, 2.9)
	var cam := Camera3D.new()
	cam.fov = 50.0
	cam.near = 0.05
	player.get_parent().add_child(cam)
	var p0 := mid + best * dist + Vector3(0, 0.3, 0)
	cam.global_position = p0
	cam.look_at(mid - Vector3(0, 0.15, 0), Vector3.UP)
	var tw := cam.create_tween()
	tw.tween_property(cam, "global_position", p0 - best * 0.4 - Vector3(0, 0.1, 0), 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	cam.make_current()
	_fin_cam = cam
	var hud := _hud()
	if hud:
		_fin_hud_cine = hud.cinematic
		hud.set_cinematic(true)
	visible = false
	if sword_pivot:
		sword_pivot.visible = false
	if shield_pivot:
		shield_pivot.visible = false
	_double.process_mode = Node.PROCESS_MODE_INHERIT
	_double.global_position = Vector3(a.x, _ground_at(a, a.y), a.z)
	# Oyuncunun kapsülü bir basamağın kenarına değerken ikizin gövdesi basamağın içinde kalabiliyordu: en yakın açık yere
	if Unclip.in_solid(_double, _double.global_position):
		for r: float in [0.15, 0.3, 0.45]:
			var moved := false
			for k in 8:
				var c := a + Vector3(sin(k * TAU / 8.0), 0, cos(k * TAU / 8.0)) * r
				c.y = _ground_at(c, a.y)
				if not Unclip.in_solid(_double, c):
					_double.global_position = c
					moved = true
					break
			if moved:
				break
	_double.rotation = Vector3(0, atan2(dir.x, dir.z), 0)
	_double.visible = true
	_double_anim.fade = 0.0
	_double_anim.play("Sword_Idle")
	return true


func _clearance(from: Vector3, d: Vector3, max_d: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(from, from + d * max_d, 1)
	q.exclude = [player.get_rid()]
	var hit := player.get_world_3d().direct_space_state.intersect_ray(q)
	return from.distance_to(hit["position"]) if hit else max_d


func _ground_at(p: Vector3, fallback: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 1.2, 0), p + Vector3(0, -3.0, 0), 1)
	q.exclude = [player.get_rid()]
	var hit := player.get_world_3d().direct_space_state.intersect_ray(q)
	return (hit["position"] as Vector3).y if hit and (hit["normal"] as Vector3).y > 0.5 else fallback


func _end_killcam() -> void:
	if not killcam:
		return
	killcam = false
	_fin_skip = false
	var pl_ok := player != null and is_instance_valid(player)
	if _fin_cam and is_instance_valid(_fin_cam):
		# Kamerayı yalnız hâlâ bizimkiyse geri ver (bölüm bu arada kendi kamerasına geçtiyse dokunma)
		if pl_ok and get_viewport().get_camera_3d() == _fin_cam:
			player.camera.make_current()
		_fin_cam.queue_free()
		var hud := _hud()
		if hud:
			hud.set_cinematic(_fin_hud_cine)
	_fin_cam = null
	if _double and is_instance_valid(_double):
		if _double.visible and pl_ok:
			# Oyuncu, ikizinin bitirdiği yerde kalır (duvarı dinleyerek)
			var d := _double.global_position - player.global_position
			d.y = 0.0
			if d.length() > 0.05:
				player.move_and_collide(d.limit_length(1.8))
		_double.visible = false
		_double.process_mode = Node.PROCESS_MODE_DISABLED
	if pl_ok:
		player.frozen = _fin_was_frozen
		if is_instance_valid(_fin_e):
			# Cesede doğru, ama dik aşağı değil: ceset görüşün altında, ufuk ortada (bakış hep ~20° aşağıda)
			var to := _flat(_fin_e.global_position - player.global_position)
			player.face(player.global_position + to * 2.6 + Vector3(0, 0.6, 0))
	if sword_pivot:
		sword_pivot.visible = true
	if shield_pivot:
		shield_pivot.visible = true
	_fin_pose = ""
	if pstate == P.FINISH:
		pstate = P.RECOVER
		_pt = 0.0
	visible = active
	_fin_e = null


func _exit_tree() -> void:
	_end_killcam()
	_reset_kick()
	if _double and is_instance_valid(_double):
		_double.queue_free()


## Oyuncunun üçüncü şahıs ikizi (fotoğraf/aynadaki model): kılıç sağ ön kolda, kalkan sol ön kolda, LimbAnim ile.
## Düello başında bir kez kurulur ve gizli bekler (bitirici anında takılma olmasın).
func _make_double() -> void:
	if _double and is_instance_valid(_double):
		return
	if not player.has_method("_me_person") or player.get_parent() == null:
		return
	var me: Person = player._me_person()
	for k in ["no_talk", "no_chat", "no_yield", "no_block"]:
		me.set_meta(k, true)
	# Bitiricide oyuncunun yerine görünen ikiz: kılıç rakibin gövdesine girerken ona sokulur (bitiricinin kurgusu);
	# kalabalık denetimi oyuncunun kendisini saymadığı gibi ikizini de saymaz
	me.set_meta("no_audit", true)
	me.visible = false
	player.get_parent().add_child(me)
	if me.rig == null:
		me.queue_free()
		return
	me.rig.lock = 1
	var mount := Node3D.new()
	mount.position = Vector3(0, -0.26, 0.02)
	mount.rotation_degrees = Vector3(90, 0, 0)
	me.rig.elbow_r.add_child(mount)
	var sw := Blades.kilij(mount) if blade == "kilij" else Blades.spathion(mount)
	sw.scale = Vector3.ONE * 1.25
	var sm := Node3D.new()
	sm.position = Vector3(0, -0.2, 0.08)
	me.rig.elbow_l.add_child(sm)
	Blades.shield(sm, Color("7a2a24") if blade == "spathion" else Color("2f5a4a"))
	_double_anim = LimbAnim.new()
	me.add_child(_double_anim)
	_double_anim.bind(me.rig)
	_double_anim.ground_mode = 1
	_double_anim.play("Sword_Idle")
	me.process_mode = Node.PROCESS_MODE_DISABLED
	_double = me


func _double_to(p: Vector3, sec: float) -> void:
	if _double == null or not _double.visible:
		return
	p.y = _ground_at(p, _double.global_position.y)
	_double.create_tween().tween_property(_double, "global_position", p, sec).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Birinci şahısta bitiricide oyuncu öne atılır (duvarı dinleyerek).
func _fp_lunge(v: Vector3) -> void:
	if player.move_and_collide(v, true) == null:
		player.global_position += v


## Kılıç vuruşu (saldırı klibi) darbe anı ikizin klibinde `lead` sn sonra gelsin
func _double_strike(clip: String, lead: float, speed := 1.0) -> void:
	if _double_anim == null or not _double.visible:
		return
	_double_anim.fade = 0.08
	_double_anim.play(clip, speed, false, maxf(0.0, LimbAnim.hit_time(clip) - lead * speed))


## Öldürme kamerasında kısa sarsıntı (kamera ofsetiyle; oyuncu kamerasına dokunmaz).
func _cam_shake(amount: float) -> void:
	if _fin_cam == null or not is_instance_valid(_fin_cam):
		Fx.trauma(amount)
		return
	var tw := _fin_cam.create_tween()
	for i in 4:
		var k := amount * (1.0 - i / 4.0) * 0.12
		tw.tween_property(_fin_cam, "h_offset", randf_range(-k, k), 0.03)
		tw.parallel().tween_property(_fin_cam, "v_offset", randf_range(-k, k), 0.03)
	tw.tween_property(_fin_cam, "h_offset", 0.0, 0.06)
	tw.parallel().tween_property(_fin_cam, "v_offset", 0.0, 0.06)


## Ölümcül darbe anı: donma, ağır çekim, katmanlı ses (davul + gövde + çelik), koyu kırmızı toon kan, ekran kenarı.
func _impact(e: Duelist, dir: Vector3, at: Vector3, third: bool, heavy := 1.0) -> void:
	Audio.stinger("kill", -9.0)
	Audio.sfx("land_thud", -3.0, 0.6)
	Audio.sfx("kick_metal", -15.0, 0.62)
	Fx.hitstop(0.1 * heavy)
	Fx.slowmo(0.28, 0.55, 0.45)
	Fx.edge(Color(0.4, 0.02, 0.03), 0.3, 0.5)
	if third:
		_cam_shake(0.5 * heavy)
	else:
		Fx.trauma(0.4 * heavy)
		Fx.fov_punch(10.0, 0.5)
	blood(get_tree().current_scene as Node3D, at, dir, 1.0)


## Toon kan: koyu kırmızı damlalar (yerçekimiyle düşer) ve kısa bir buğu. Abartısız, oyunun çizgi film diline uygun.
static func blood(parent: Node3D, pos: Vector3, dir: Vector3, size := 1.0) -> void:
	if parent == null:
		return
	var drop := Vfx._sphere(0.04 * size, Vfx._mat(Color.WHITE), 6)
	Vfx._burst(parent, pos, 18, drop, Vfx._grad([Color("9a141c"), Color("6a0c12"), Color(0.3, 0.02, 0.04, 0.0)]),
		0.75, Vector2(1.6, 4.2) * size, 30.0, Vector3(0, -9.0, 0), Vector2(0.5, 1.3), (dir + Vector3(0, 0.45, 0)).normalized())
	var mist := Vfx._sphere(0.13 * size, Vfx._mat(Color(1, 1, 1, 0.8)), 8)
	Vfx._burst(parent, pos, 6, mist, Vfx._grad([Color(0.5, 0.05, 0.07, 0.7), Color(0.3, 0.02, 0.04, 0.0)]),
		0.45, Vector2(0.4, 1.2) * size, 55.0, Vector3(0, -0.6, 0), Vector2(0.8, 1.7), dir)


func _chest(e: Duelist) -> Vector3:
	var rb: Node3D = e.body.rig.body if e.body and e.body.rig else null
	return rb.global_transform * Vector3(0, 1.0, 0) if rb else e.global_position + Vector3(0, 1.1, 0)


## Saplama (tekmeyle sendeleyene): öne atılış, kılıç gövdeden geçer; rakip kılıca saplı iki büklüm kalır, kılıç
## çekilince geriye yığılır.
func _fin_thrust(e: Duelist, dir: Vector3, third: bool) -> void:
	if third:
		_double_strike("Sword_Attack", 0.3)
		_double_to(e.global_position - dir * 1.15, 0.3)
	else:
		_fin_pose = "thrust_wind"
	await _wait(0.18)
	if not third:
		_fin_pose = "thrust"
		_fp_lunge(dir * 0.35)
	await _wait(0.12)
	_impact(e, dir, _chest(e), third)
	e.kill(true)
	if e.anim:
		e.anim.fade = 0.05
		e.anim.play("Hit_Chest", 0.5, false)
		e.anim.create_tween().tween_property(e.anim, "lean", 0.55, 0.15)
	e._kb = dir * 0.5
	await _wait(0.5)
	# Kılıç çekilir
	if third:
		_double_anim.fade = 0.25
		_double_anim.play("Sword_Idle")
		_double_to(_double.global_position - dir * 0.35, 0.35)
	else:
		_fin_pose = "thrust_wind"
	if is_instance_valid(e):
		blood(get_tree().current_scene as Node3D, _chest(e), -dir, 0.6)
		Audio.sfx("whoosh_fly", -12.0, 0.7)
		e.collapse("Death01", 0.9, 1.3)


## Kesiş (nişan yönünden): yandan boydan boya; rakip darbeyle döner, başı geri savrulur, dizleri bükülüp yığılır.
func _fin_slash(e: Duelist, dir: Vector3, third: bool, d: int) -> void:
	var sgn := 1.0 if d == Duelist.DIR_RIGHT else -1.0
	if third:
		_double_strike("Sword_Regular_A" if d == Duelist.DIR_RIGHT else "Sword_Regular_B", 0.28, 0.8)
		_double_to(e.global_position - dir * 1.35, 0.25)
	else:
		_fin_pose = "slash_wind_r" if sgn > 0.0 else "slash_wind_l"
	await _wait(0.2)
	if not third:
		_fin_pose = "slash_r" if sgn > 0.0 else "slash_l"
	await _wait(0.08)
	var across := dir.cross(Vector3.UP).normalized() * -sgn
	_impact(e, (across + dir * 0.4).normalized(), _chest(e) + Vector3(0, 0.15, 0), third)
	e.kill(true)
	if e.anim:
		e.anim.fade = 0.05
		e.anim.play("Hit_Head", 0.7, false)
		e.anim.create_tween().tween_property(e.anim, "lean", 0.25, 0.2)
	e.create_tween().tween_property(e, "rotation:y", e.rotation.y + sgn * 1.1, 0.45).set_ease(Tween.EASE_OUT)
	e._kb = (across * 0.6 + dir * 0.4) * 1.2
	await _wait(0.4)
	if is_instance_valid(e):
		e.collapse("Death01", 1.0, 1.35)


## Kabza ve kalkanla yüze vuruş, rakip sırtüstü düşer; yerdeyken aşağı saplama.
func _fin_bash(e: Duelist, dir: Vector3, third: bool) -> void:
	if third:
		_double_anim.fade = 0.06
		_double_anim.play("Melee_Hook", 1.0, false, maxf(0.0, LimbAnim.hit_time("Melee_Hook") - 0.2))
		_double_to(e.global_position - dir * 1.0, 0.2)
	else:
		_fin_pose = "bash_wind"
	await _wait(0.2)
	if not third:
		_fin_pose = "bash"
		_fp_lunge(dir * 0.3)
	# Birinci vuruş: yüze
	Audio.sfx("kick_metal", -4.0, 0.7)
	Audio.sfx("land_thud", -2.0, 1.0)
	Fx.hitstop(0.06)
	if third:
		_cam_shake(0.4)
	else:
		Fx.trauma(0.35)
	Vfx.dust(get_tree().current_scene as Node3D, e.global_position + Vector3(0, 1.5, 0) - dir * 0.2, 0.2)
	if e.anim:
		e.anim.fade = 0.05
		e.anim.body_amount = 1.0
		e.anim.play("Hit_Knockback", 1.15, false)
	e._kb = dir * 3.2
	e.drop_weapons(dir)
	await _wait(0.6)
	if not is_instance_valid(e):
		return
	# İkinci vuruş: yerdekine aşağı saplama
	if third:
		_double_strike("Sword_Regular_C", 0.3)
		_double_to(e.global_position - dir * 0.8, 0.25)
	else:
		_fin_pose = "down_wind"
		_fp_lunge(dir * 0.6)
	await _wait(0.3)
	if not third:
		_fin_pose = "down"
	_ground_stab(e, dir, third)


## Yerde yatana: üstüne eğilip aşağı saplama.
func _fin_ground(e: Duelist, dir: Vector3, third: bool) -> void:
	if third:
		_double_strike("Sword_Regular_C", 0.3)
		_double_to(e.global_position - dir * 0.85, 0.28)
	else:
		_fin_pose = "down_wind"
		_fp_lunge(dir * 0.4)
	await _wait(0.3)
	if not third:
		_fin_pose = "down"
	_ground_stab(e, dir, third)


func _ground_stab(e: Duelist, dir: Vector3, third: bool) -> void:
	if not is_instance_valid(e):
		return
	_impact(e, Vector3(0, 1, 0), _chest(e), third, 1.2)
	e._kb = Vector3.ZERO
	e.kill(true)
	if e.anim:
		var tw := e.anim.create_tween()
		tw.tween_property(e.anim, "lean", 0.18, 0.06)
		tw.tween_property(e.anim, "lean", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
	e.collapse("Hit_Knockback", 0.0, 1.15)
