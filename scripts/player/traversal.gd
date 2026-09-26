class_name Traversal
extends RefCounted
## Tırmanma (her dik yüzeye, nefesle sınırlı), kenardan çıkma ve alçak engelin üstünden atlama.
## Yalnız player.can_climb açıkken çalışır (serbest saat bölümleri); diğer bölümlerde hareket değişmez.
## Tırmanılmaz: no_climb işaretli gövdeler, ağı gizli gövdeler (görünmez sınırlar, korkuluklar),
## karakterler ve tavan altı (iç mekân: kançılarya odaları, zindan, kule içi).
##   Space: duvara tutun / tırmanırken yukarı sıçra · WASD: duvarda yürü · Shift: hızlı · C/Ctrl: bırak

const CLIMB_SPEED := 1.2
const CLIMB_FAST := 1.9
const DRAIN_MOVE := 0.12          # saniyede (dolu nefes ≈ 10 m yavaş tırmanış)
const DRAIN_FAST := 0.24
const DRAIN_IDLE := 0.02
const JUMP_COST := 0.22
const JUMP_TIME := 0.35
const JUMP_SPEED := 3.6
const REGEN := 0.55
const REGEN_DELAY := 0.45
const TIRED_MIN := 0.4            # nefes tükenince yeniden tutunmak için gereken
const REACH := 2.3                # ayaktan el ucuna: tutunulabilen kenar yüksekliği
const VAULT_MAX := 1.1
const STAGGER_FALL := 4.0
const WALL_GAP := 0.36            # tırmanırken gövde ekseninin duvara uzaklığı (kapsül yarıçapı 0.3)
const ROOF_Y := 1.5               # bunun üstündeyken oyun alanı sınırı uygulanır

var p: Player
var state := ""                   # "" | "climb" | "mantle"
var stamina := 1.0
var tired := false
var wall_n := Vector3.BACK
## Oyun alanı (XZ dikdörtgenleri): çatıdayken ya da tırmanırken dışarı çıkılmaz. Boşsa sınır yok.
var bounds: Array = []
var climbs := 0                   # bu bölümde kaç kez tutunuldu (ipucu ve test için)
var mantles := 0
var vaults := 0
var falls := 0
var _regen_wait := 0.0
var _jump_t := 0.0
var _grab_cool := 0.0
var _air_top := 0.0
var _was_floor := true
var _last_floor := Vector3.ZERO
var _last_inside := Vector3.ZERO
var _was_inside := false
var _phase := 0.0
var _hand_sign := 1.0
var _hands: Array[Node3D] = []
var _tired_line := 0
var _fall_line := 0
var _line_cool := 0.0
var _tween: Tween


func _init(player: Player) -> void:
	p = player
	_last_floor = p.global_position
	_air_top = p.global_position.y


## Oyuncunun fizik adımı: tırmanma ya da kenardan çıkma sürüyorsa hareketi bu yönetir (true döner).
func physics(delta: float) -> bool:
	_grab_cool = maxf(0.0, _grab_cool - delta)
	_line_cool = maxf(0.0, _line_cool - delta)
	match state:
		"mantle":
			_hud_stamina()
			return true
		"climb":
			_climb(delta)
			_hud_stamina()
			return true
	if not p.frozen and p.move_mode == "walk" and _try_start():
		_hud_stamina()
		return true
	_regen(delta)
	_hud_stamina()
	return false


## Normal yürüyüşten sonra: iniş (yüksekten düşme, tente), oyun alanı sınırı, boşluğa düşme koruması.
func after_walk(_delta: float) -> void:
	var pos := p.global_position
	var floor_now := p.is_on_floor()
	if floor_now:
		if not _was_floor:
			_land(_air_top - pos.y)
		_air_top = pos.y
		if _inside(pos):
			_last_floor = pos
	else:
		_air_top = maxf(_air_top, pos.y)
	_was_floor = floor_now
	_keep_inside()
	if pos.y < -25.0:
		p.global_position = _last_floor + Vector3.UP * 0.2
		p.velocity = Vector3.ZERO


## Ara sahne ya da ışınlama: tırmanma güvenle biter, Tolga altındaki zemine iner.
func cancel() -> void:
	if state == "":
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	state = ""
	_face_restore()
	_show_hands(false)
	p.velocity = Vector3.ZERO
	var from := p.global_position + Vector3.UP * 0.5
	var hit := _ray(from, from + Vector3.DOWN * 60.0)
	p.global_position = (hit["position"] as Vector3) + Vector3.UP * 0.02 if hit else _last_floor
	_air_top = p.global_position.y
	_was_floor = true


# ---------------------------------------------------------------- başlama: tutun, çık, atla

func _try_start() -> bool:
	var jump := Input.is_action_just_pressed("jump")
	var inp := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var fwd := -p.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	if p.is_on_floor():
		if jump:
			var hit := _wall(fwd, 1.1, 0.6)
			if hit.is_empty():
				hit = _wall(fwd, 0.45, 0.6)
			if hit.is_empty():
				return false   # önünde duvar yok: normal zıplama
			var top := _top(hit, REACH)
			if not top.is_empty():
				if float(top["y"]) - p.global_position.y <= VAULT_MAX:
					return _vault(top)
				return _mantle(top)
			return _grab(hit)
		# Koşarken alçak engelin (≤ 1.1 m) üstünden kendiliğinden
		if Input.is_action_pressed("sprint") and inp.y < -0.5 and p.horizontal_speed() > 3.5:
			var low := _wall(fwd, 0.45, 0.4)
			if not low.is_empty() and _wall(fwd, 1.5, 0.6).is_empty():
				var top := _top(low, VAULT_MAX + 0.05)
				if not top.is_empty():
					return _vault(top)
		return false
	# Havada: ileri basılıyken önündeki kenara tutunup çık ya da duvara yapış (çatıdan kısa kalan atlayış)
	if inp.y < -0.3 and _grab_cool <= 0.0 and p.velocity.y > -12.0:
		var hit := _wall(fwd, 1.1, 0.35)
		if hit.is_empty():
			return false
		var top := _top(hit, REACH - 0.15)
		if not top.is_empty():
			return _mantle(top)
		return _grab(hit)
	return false


func _grab(hit: Dictionary) -> bool:
	if tired or stamina <= 0.02:
		return false
	wall_n = _flat(hit["normal"])
	if _ceiling():
		return false
	state = "climb"
	climbs += 1
	p.velocity = Vector3.ZERO
	_face_wall()
	_show_hands(true)
	_air_top = p.global_position.y
	Audio.sfx("footstep_stone", -18.0, 1.35)
	if climbs == 1 and not GameState.autotest:
		var hud := _hud()
		if hud:
			var hint := TranslationServer.translate("UI_CLIMB_HINT_PAD" if GameState.pad else "UI_CLIMB_HINT")
			hud.set_prompt(hint)
			p.get_tree().create_timer(6.0).timeout.connect(func():
				if is_instance_valid(hud) and hud._prompt.text == hint:
					hud.set_prompt(""))
	return true


# ---------------------------------------------------------------- tırmanış

func _climb(delta: float) -> void:
	if p.frozen:
		cancel()
		return
	if Input.is_action_just_pressed("dive"):
		_release(wall_n * 1.4)
		return
	var hit := _wall(-wall_n, 1.0, 0.6)
	if hit.is_empty():
		hit = _wall(-wall_n, 0.4, 0.6)
	if hit.is_empty():
		_release(Vector3.ZERO)   # duvar bitti (köşe, boşluk)
		return
	wall_n = wall_n.slerp(_flat(hit["normal"]), clampf(delta * 10.0, 0.0, 1.0)).normalized()
	_face_wall()
	var inp := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var fast := Input.is_action_pressed("sprint")
	var spd := CLIMB_FAST if fast else CLIMB_SPEED
	# Eller kenara yetişiyorsa yukarı çık
	if inp.y < -0.2 or _jump_t > 0.0:
		var top := _top(hit, REACH)
		if not top.is_empty():
			_mantle(top)
			return
	if Input.is_action_just_pressed("jump") and _jump_t <= 0.0 and stamina > 0.05:
		stamina = maxf(0.0, stamina - JUMP_COST)
		_jump_t = JUMP_TIME
		Audio.sfx("whoosh_fly", -20.0, 1.7)
	var up := -inp.y
	var side := inp.x
	var right := (-wall_n).cross(Vector3.UP).normalized()
	var v := Vector3.UP * up * spd + right * side * spd
	if _jump_t > 0.0:
		_jump_t -= delta
		v = Vector3.UP * JUMP_SPEED + right * side * spd * 0.5
	# Yanda duvar bitiyorsa o yöne gidilmez (köşeden boşluğa düşmesin)
	if absf(side) > 0.1:
		var probe := p.global_position + right * signf(side) * 0.45
		if _ray(probe + Vector3.UP * 1.0, probe + Vector3.UP * 1.0 - wall_n * 0.9).is_empty():
			v -= right * side * spd
	if up < -0.1 and p.is_on_floor():
		_release(Vector3.ZERO)
		return
	var hp: Vector3 = hit["position"]
	var gap := Vector2(hp.x - p.global_position.x, hp.z - p.global_position.z).length()
	v += -wall_n * (gap - WALL_GAP) * 6.0
	p.velocity = v
	p.move_and_slide()
	var moving := inp.length() > 0.1 or _jump_t > 0.0
	stamina -= ((DRAIN_FAST if fast else DRAIN_MOVE) if moving else DRAIN_IDLE) * delta
	# Eller sırayla uzanır; her tutunuşta hafif taş sesi
	_phase += delta * Vector2(v.x, v.z).length() * 3.0 + delta * absf(v.y) * 2.6
	var s := signf(sin(_phase))
	if s != 0.0 and s != _hand_sign:
		_hand_sign = s
		Audio.sfx("footstep_stone", -24.0, randf_range(1.25, 1.45))
	_pose_hands(sin(_phase), 0.0)
	if stamina <= 0.0:
		stamina = 0.0
		tired = true
		_release(wall_n * 0.6)
		_say_tired()


func _release(push: Vector3) -> void:
	state = ""
	p.velocity = push
	_grab_cool = 0.45
	_jump_t = 0.0
	_face_restore()
	_show_hands(false)
	_air_top = p.global_position.y
	_was_floor = p.is_on_floor()


## Kenardan çıkma: önce kenar hizasına, sonra üstüne. Hedefte ayakta durulacak yer olduğu _top'ta denetlendi.
func _mantle(top: Dictionary) -> bool:
	state = "mantle"
	mantles += 1
	_face_restore()
	_show_hands(true)
	_pose_hands(1.0, 0.0)
	var start := p.global_position
	var target: Vector3 = top["pos"]
	var rise := Vector3(start.x, target.y, start.z)
	var t1 := clampf((target.y - start.y) * 0.22, 0.18, 0.45)
	p.velocity = Vector3.ZERO
	Audio.sfx("land_thud", -20.0, 1.3)
	var tw := p.create_tween()
	_tween = tw
	tw.tween_property(p, "global_position", rise, t1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_method(func(k: float): _pose_hands(1.0 - k * 2.0, k), 0.0, 1.0, t1)
	tw.tween_property(p, "global_position", target, 0.22).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func():
		state = ""
		_show_hands(false)
		p.velocity = Vector3.ZERO
		_air_top = p.global_position.y
		_was_floor = true)
	return true


## Alçak engel: üstüne sıçrar, ileri hızla devam eder (ince duvarsa öbür yana iner).
func _vault(top: Dictionary) -> bool:
	state = "mantle"
	vaults += 1
	var n: Vector3 = top["n"]
	var start := p.global_position
	var up_to := Vector3(start.x, float(top["y"]) + 0.12, start.z) - n * 0.12
	var speed := maxf(3.4, p.horizontal_speed())
	p.velocity = Vector3.ZERO
	Audio.sfx("footstep_stone", -14.0, 0.9)
	var tw := p.create_tween()
	_tween = tw
	tw.tween_property(p, "global_position", up_to, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		state = ""
		p.velocity = -n * speed + Vector3.UP * 1.4
		_air_top = p.global_position.y
		_was_floor = false)
	return true


# ---------------------------------------------------------------- nefes, iniş, sınır

func _regen(delta: float) -> void:
	if not p.is_on_floor():
		_regen_wait = REGEN_DELAY
		return
	if _regen_wait > 0.0:
		_regen_wait -= delta
		return
	stamina = minf(1.0, stamina + REGEN * delta)
	if tired and stamina >= TIRED_MIN:
		tired = false


func _land(fall: float) -> void:
	var soft := false
	for i in p.get_slide_collision_count():
		var c := p.get_slide_collision(i)
		var col := c.get_collider()
		if c.get_normal().y > 0.6 and col is Node and (col as Node).has_meta("soft_landing"):
			soft = true
	if soft and fall > 1.2:
		# Tente yaylanır: "inanç sıçraması"
		p.velocity.y = clampf(fall * 1.1, 3.0, 7.0)
		Audio.sfx("cartoon_boing", -8.0, randf_range(0.95, 1.1))
		if fall > STAGGER_FALL and _line_cool <= 0.0:
			_line_cool = 12.0
			_bark("D_CLIMB_LEAP", 3.5)
		return
	if fall > STAGGER_FALL:
		falls += 1
		p.shake(minf(0.9, 0.25 + fall * 0.06))
		p.stagger(0.7)
		Audio.sfx("land_thud", -6.0, 0.85)
		var hud := _hud()
		if hud and hud.fez.visible:
			hud.fez.knock(clampf(fall / 8.0, 0.5, 1.0))
		if _line_cool <= 0.0:
			_line_cool = 15.0
			_fall_line += 1
			_bark("D_CLIMB_FALL_%d" % ((_fall_line - 1) % 3 + 1), 3.0)
	elif fall > 1.2:
		Audio.sfx("land_thud", -16.0, 1.1)


func _say_tired() -> void:
	if _line_cool > 0.0:
		return
	_line_cool = 8.0
	_tired_line += 1
	_bark("D_CLIMB_TIRED_%d" % ((_tired_line - 1) % 3 + 1), 3.0)


func _inside(pos: Vector3) -> bool:
	if bounds.is_empty():
		return true
	for r in bounds:
		if (r as Rect2).has_point(Vector2(pos.x, pos.z)):
			return true
	return false


## Çatıdayken ya da havadayken oyun alanının dışına çıkılmaz (yerde seviyenin kendi duvarları var).
func _keep_inside() -> void:
	var pos := p.global_position
	if _inside(pos):
		_last_inside = pos
		_was_inside = true
		return
	if not _was_inside or (pos.y < ROOF_Y and state == ""):
		return
	p.global_position = Vector3(_last_inside.x, pos.y, _last_inside.z)
	p.velocity.x = 0.0
	p.velocity.z = 0.0


func _hud_stamina() -> void:
	var hud := _hud()
	if hud:
		hud.set_stamina(stamina, state == "climb" or stamina < 0.995, tired)


# ---------------------------------------------------------------- algılama

## Tırmanılabilir mi: yalnız durağan dünya (StaticBody3D, katman 1); no_climb ve görünmez gövdeler hariç.
static func climbable(c: Object) -> bool:
	if not (c is StaticBody3D):
		return false
	var b := c as StaticBody3D
	if b.has_meta("no_climb") or (b.collision_layer & 1) == 0:
		return false
	for ch in b.get_children():
		if ch is MeshInstance3D and not (ch as MeshInstance3D).visible:
			return false
	return true


func _ray(from: Vector3, to: Vector3) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(from, to, 1, [p.get_rid()])
	return p.get_world_3d().direct_space_state.intersect_ray(q)


## Ayaktan h yükseklikte, dir yönünde, kapsülün yüzeyinden reach kadar ileride tırmanılabilir dik yüzey.
func _wall(dir: Vector3, h: float, reach: float) -> Dictionary:
	var from := p.global_position + Vector3.UP * h
	var hit := _ray(from, from + dir * (0.3 + reach))
	if hit.is_empty() or absf((hit["normal"] as Vector3).y) > 0.4 or not climbable(hit["collider"]):
		return {}
	return hit


## Duvarın üst kenarı ayaktan en fazla max_h yukarıdaysa ve üstünde ayakta durulabiliyorsa:
## {"y": kenar yüksekliği, "pos": çıkılacak nokta, "n": duvar normali}. Yoksa {}.
func _top(hit: Dictionary, max_h: float) -> Dictionary:
	var n := _flat(hit["normal"])
	var feet := p.global_position.y
	var face: Vector3 = hit["position"]
	var probe := face - n * 0.12
	# Yukarıdan aşağı: duvarın içinden başlayan ışın o gövdeye çarpmaz, kenar erişimin üstündeyse boş döner
	var down := _ray(Vector3(probe.x, feet + max_h + 0.05, probe.z), Vector3(probe.x, feet + 0.3, probe.z))
	if down.is_empty() or (down["normal"] as Vector3).y < 0.7:
		return {}
	var y: float = (down["position"] as Vector3).y
	var target := Vector3(face.x, y + 0.12, face.z) - n * 0.45
	# Kenarın hemen üstünden hedefe açık yol (ince duvarın ardındaki odaya ışınlanılmasın)
	var eye := Vector3(p.global_position.x, y + 0.4, p.global_position.z)
	if not _ray(eye, target + Vector3.UP * 0.28).is_empty():
		return {}
	if not _fits(target):
		return {}
	return {"y": y, "pos": target, "n": n}


func _fits(pos: Vector3) -> bool:
	var sq := PhysicsShapeQueryParameters3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.28
	cap.height = 1.66
	sq.shape = cap
	sq.transform = Transform3D(Basis(), pos + Vector3.UP * 0.88)
	sq.collision_mask = 1
	sq.exclude = [p.get_rid()]
	return p.get_world_3d().direct_space_state.intersect_shape(sq, 1).is_empty()


## İç mekân: duvarın yarım metre gerisinde başın üstünde tavan var mı (saçak ve cumba sayılmaz).
func _ceiling() -> bool:
	var from := p.global_position + wall_n * 0.5 + Vector3.UP * 1.6
	return not _ray(from, from + Vector3.UP * 3.4).is_empty()


static func _flat(n: Vector3) -> Vector3:
	var f := Vector3(n.x, 0.0, n.z)
	return f.normalized() if f.length_squared() > 0.0001 else Vector3.BACK


# ---------------------------------------------------------------- görünüm: yüz duvara, eller

## Gövde duvara döner; bakış yönü korunur (fare kamerayı duvardan ±75° çevirebilir).
func _face_wall() -> void:
	var yaw := atan2(wall_n.x, wall_n.z)
	var world := p.rotation.y + p.camera.rotation.y
	p.rotation.y = yaw
	p.camera.rotation.y = clampf(wrapf(world - yaw, -PI, PI), -1.3, 1.3)


func _face_restore() -> void:
	p.rotation.y += p.camera.rotation.y
	p.camera.rotation.y = 0.0


func _show_hands(on: bool) -> void:
	if on and _hands.is_empty():
		var nihat := p.hand_style == "nihat"
		var hikmet := p.hand_style == "hikmet"
		var coat := Color("4a4a52") if nihat else (Color("5b7fb3") if hikmet else Color("2b2f38"))
		var skin := Color("ecb892") if nihat else (Color("e0a57e") if hikmet else Color("e6ad88"))
		for s in [-1.0, 1.0]:
			var h := Node3D.new()
			h.visible = false
			p.camera.add_child(h)
			Props.cyl(h, 0.048, 0.34, Vector3(0, -0.2, 0.05), coat, Vector3(-18, 0, 0), 8)
			Props.cyl(h, 0.046, 0.03, Vector3(0, -0.03, 0.0), Color("f4f1ea"), Vector3(-18, 0, 0), 8)
			Props.ball(h, 0.052, Vector3(0, 0.03, -0.01), skin, Vector3(1.15, 1.2, 0.75), 8)
			for k in 4:
				Props.cyl(h, 0.011, 0.05, Vector3(-0.03 + k * 0.02, 0.08, -0.025), skin, Vector3(-30, 0, 0), 5)
			Props.strip_outlines(h)
			h.rotation_degrees = Vector3(0, 0, -s * 8.0)
			_hands.append(h)
	for h in _hands:
		h.visible = on
	if p.hand:
		p.hand.visible = p._hand_shown and not on


## a: -1..1 hangi el yukarıda; push: kenardan çıkarken eller aşağı iter (0..1).
func _pose_hands(a: float, push: float) -> void:
	if _hands.size() < 2:
		return
	var base_y := lerpf(-0.08, -0.42, push)
	_hands[0].position = Vector3(-0.24, base_y + a * 0.11 * (1.0 - push), -0.42)
	_hands[1].position = Vector3(0.24, base_y - a * 0.11 * (1.0 - push), -0.42)


func _hud() -> Hud:
	return p.get_tree().get_first_node_in_group("hud") as Hud if p.is_inside_tree() else null


func _bark(key: String, seconds: float) -> void:
	var hud := _hud()
	if hud == null or hud.is_talking():
		return
	hud.bark("SPK_NIHAT" if p.hand_style == "nihat" else ("SPK_HIKMET" if p.hand_style == "hikmet" else "SPK_TOLGA"), key, seconds)

