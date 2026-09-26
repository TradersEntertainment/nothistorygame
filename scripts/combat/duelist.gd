class_name Duelist
extends Node3D
## Kılıçlı rakip. Yönlü dövüş: sol / sağ / üst (oyuncunun bakışına göre: "sol" = oyuncunun solundan gelen).
## Muhafız (guard) bir yöndedir; oyuncunun nişan yönüne tepki süresiyle döner. Saldırıdan önce kolunu o yöne kaldırır
## (WINDUP: HUD'da kırmızı ok), sonra vurur (STRIKE anında Duel sonucu çözer). Savuşturulursa sendeler (STAGGER).
## Görünüş Person'dan; kollar dövüş sırasında elle sürülür (rig.lock).

signal died(d: Duelist)

enum St { IDLE, WINDUP, STRIKE, RECOVER, STAGGER, FLINCH, DEAD }
const DIR_LEFT := 0
const DIR_RIGHT := 1
const DIR_TOP := 2
const RANGE := 2.1

var body: Person
var sword: Node3D
var shield: Node3D
var duel: Node               # Duel denetleyicisi (vuruş çözümü)
var target: Node3D           # oyuncu
var hp := 100.0
var max_hp := 100.0
var skill := 0.5             # 0..1: muhafız tepkisi, saldırı hızı, aldatma
var damage := 18.0
var name_key := "SPK_SOLDIER"
var state := St.IDLE
var dir := DIR_TOP           # saldırı yönü (WINDUP/STRIKE)
var guard := DIR_TOP         # muhafız yönü
var windup_time := 0.8
var _t := 0.0                # durum sayacı
var _think := 1.4            # bir sonraki saldırıya kadar
var _guard_want := DIR_TOP
var _guard_t := 0.0
var _strafe := 1.0
var _strafe_t := 2.0
var _feint := false
var _y := 0.0


func _init(look: Dictionary, blade := "kilij", p_skill := 0.5, with_shield := false) -> void:
	skill = p_skill
	body = Person.new(look)
	body.set_meta("no_talk", true)
	add_child(body)
	windup_time = lerpf(0.95, 0.5, skill)
	set_meta("blade", blade)
	set_meta("with_shield", with_shield)


func _ready() -> void:
	_y = position.y
	# Kılıç sağ ön kola, kalkan sol ön kola
	var er: Node3D = body.rig.elbow_r if body.rig else null
	if er:
		var mount := Node3D.new()
		mount.position = Vector3(0, -0.26, 0.02)
		mount.rotation_degrees = Vector3(90, 0, 0)
		er.add_child(mount)
		sword = Blades.kilij(mount) if String(get_meta("blade")) == "kilij" else Blades.spathion(mount)
		sword.scale = Vector3.ONE * 1.25
	var el: Node3D = body.rig.elbow_l if body.rig else null
	if el and bool(get_meta("with_shield")):
		var sm := Node3D.new()
		sm.position = Vector3(0, -0.2, 0.08)
		sm.rotation_degrees = Vector3(0, 0, 0)
		el.add_child(sm)
		shield = Blades.shield(sm, Color("7a2a24"))
	if body.rig:
		body.rig.lock = 1


func alive() -> bool:
	return state != St.DEAD


## Saldırının ne kadarı doldu (HUD'daki kırmızı okun dolumu): 0..1, WINDUP dışında -1.
func windup_progress() -> float:
	return clampf(_t / windup_time, 0.0, 1.0) if state == St.WINDUP else -1.0


func time_to_impact() -> float:
	return windup_time - _t if state == St.WINDUP else 99.0


## Oyuncunun vuruşu geldi (Duel çağırır). true: isabet.
func take_swing(from_dir: int, dmg: float) -> String:
	if state == St.DEAD:
		return "miss"
	if state in [St.IDLE, St.RECOVER] and guard == from_dir:
		_t = 0.0
		Audio.sfx("kick_metal", -6.0, 1.5)
		return "blocked"
	var mult := 1.6 if state == St.STAGGER else 1.0
	hp -= dmg * mult
	Vfx.dust(get_parent_node_3d(), global_position + Vector3(0, 1.3, 0), 0.25)
	if hp <= 0.0:
		_die()
		return "kill"
	state = St.FLINCH
	_t = 0.0
	return "hit"


## Savuşturuldu: sendeler, açık kalır.
func parried() -> void:
	state = St.STAGGER
	_t = 0.0


func _die() -> void:
	state = St.DEAD
	hp = 0.0
	var tw := create_tween().set_parallel()
	tw.tween_property(body, "rotation:x", deg_to_rad(-88), 0.6).set_ease(Tween.EASE_IN)
	tw.tween_property(body, "position:y", 0.25, 0.6)
	died.emit(self)


func _process(delta: float) -> void:
	if state == St.DEAD or target == null:
		return
	_t += delta
	var to := target.global_position - global_position
	to.y = 0.0
	var dist := to.length()
	# Yüzü hep hedefe
	if dist > 0.05:
		rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 8.0, 0.0, 1.0))
	# Mesafe ve yan adım (sendelerken ve vururken kıpırdamaz)
	if state in [St.IDLE, St.RECOVER]:
		var fwd := to.normalized() if dist > 0.01 else Vector3.FORWARD
		var side := fwd.cross(Vector3.UP)
		var v := Vector3.ZERO
		if dist > RANGE + 0.3:
			v += fwd * 2.4
		elif dist < RANGE - 0.5:
			v -= fwd * 1.4
		_strafe_t -= delta
		if _strafe_t <= 0.0:
			_strafe_t = randf_range(1.2, 2.8)
			_strafe = [-1.0, 0.0, 1.0][randi() % 3]
		v += side * _strafe * 0.7
		global_position += v * delta
		global_position.y = _y
		if body.rig:
			body.rig.speed = v.length()
	# Muhafız: oyuncunun nişanına tepki süresiyle döner
	var aim: int = duel.player_aim() if duel else DIR_TOP
	if aim != _guard_want:
		_guard_want = aim
		_guard_t = lerpf(0.75, 0.18, skill) + randf_range(0.0, 0.25)
	if guard != _guard_want:
		_guard_t -= delta
		if _guard_t <= 0.0:
			guard = _guard_want
	match state:
		St.IDLE:
			_think -= delta
			if _think <= 0.0 and dist < RANGE + 0.6:
				_start_attack()
		St.WINDUP:
			if _feint and _t > windup_time * 0.55:
				# Aldatma: kolu indirir, yeniden bekler
				state = St.IDLE
				_think = randf_range(0.3, 0.8)
				_t = 0.0
			elif _t >= windup_time:
				state = St.STRIKE
				_t = 0.0
				Audio.sfx("whoosh_fly", -10.0, 1.6)
				if duel:
					duel.enemy_strike(self, dir)
		St.STRIKE:
			if _t >= 0.18:
				state = St.RECOVER
				_t = 0.0
		St.RECOVER:
			if _t >= lerpf(0.7, 0.4, skill):
				state = St.IDLE
				_think = randf_range(lerpf(1.6, 0.6, skill), lerpf(2.8, 1.4, skill))
		St.STAGGER:
			if _t >= 1.0:
				state = St.IDLE
				_think = randf_range(0.8, 1.6)
		St.FLINCH:
			if _t >= 0.35:
				state = St.IDLE
				_think = maxf(_think, 0.5)
	_pose(delta)


func _start_attack() -> void:
	state = St.WINDUP
	_t = 0.0
	# Usta rakip oyuncunun nişan yönünden kaçınır (orası muhafızlı sayılır)
	var aim: int = duel.player_aim() if duel else -1
	var choices := [DIR_LEFT, DIR_RIGHT, DIR_TOP]
	if skill > 0.45 and randf() < skill:
		choices.erase(aim)
	dir = choices[randi() % choices.size()]
	_feint = skill > 0.6 and randf() < (skill - 0.55) * 0.5
	windup_time = lerpf(0.95, 0.5, skill) * randf_range(0.9, 1.15)


## Kol pozları (oyuncunun gözünden: "sağ" = rakibin +X yanı, kılıç kolunun yanı).
func _pose(delta: float) -> void:
	if body.rig == null:
		return
	var ar: Node3D = body.rig.arm_r
	var er: Node3D = body.rig.elbow_r
	var al: Node3D = body.rig.arm_l
	if ar == null:
		return
	var want := Vector3(-1.1, 0, 0.1)
	var elbow := -0.8
	var k := clampf(delta * 12.0, 0.0, 1.0)
	match state:
		St.IDLE, St.RECOVER, St.FLINCH:
			match guard:
				DIR_RIGHT:
					want = Vector3(-1.2, 0, 0.75)
					elbow = -1.25
				DIR_LEFT:
					want = Vector3(-1.35, 0, -0.75)
					elbow = -1.35
				_:
					want = Vector3(-2.2, 0, 0.3)
					elbow = -1.3
			if state == St.FLINCH:
				want.x += 0.5
		St.WINDUP:
			var p := windup_progress()
			match dir:
				DIR_RIGHT:
					want = Vector3(-2.3, 0, 1.7)
					elbow = -1.3
				DIR_LEFT:
					want = Vector3(-2.4, 0, -1.25)
					elbow = -1.5
				_:
					want = Vector3(-3.1, 0, 0.1)
					elbow = -1.2
			k = clampf(delta * (4.0 + p * 6.0), 0.0, 1.0)
		St.STRIKE:
			match dir:
				DIR_RIGHT:
					want = Vector3(-1.2, 0, -0.7)
				DIR_LEFT:
					want = Vector3(-1.2, 0, 1.0)
				_:
					want = Vector3(-0.8, 0, 0.1)
			elbow = -0.1
			k = clampf(delta * 30.0, 0.0, 1.0)
		St.STAGGER:
			want = Vector3(-0.4, 0, 0.9)
			elbow = -0.3
			body.rotation.x = lerpf(body.rotation.x, -0.15, k)
	if state != St.STAGGER:
		body.rotation.x = lerpf(body.rotation.x, 0.0, k)
	ar.rotation = ar.rotation.lerp(want, k)
	if er:
		er.rotation.x = lerpf(er.rotation.x, elbow, k)
	if al:
		al.rotation = al.rotation.lerp(Vector3(-0.9, 0, -0.25) if shield else Vector3(-0.2, 0, -0.2), k)
