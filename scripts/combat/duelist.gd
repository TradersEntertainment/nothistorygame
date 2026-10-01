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
var anim: LimbAnim
var _moving := 0.0
## Saldırı yönü → hazır animasyon (oyuncunun gözünden: soldan gelen darbe B, sağdan A, yukarıdan C)
const ATTACK_CLIP := {0: "Sword_Regular_B", 1: "Sword_Regular_A", 2: "Sword_Regular_C"}


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
	body.set_meta("no_chat", true)
	body.set_meta("no_yield", true)
	# Yerleştirildikten sonra zemine otur (StoryDuel konumu oyuncunun yüksekliğinden verir: moloz, set, basamak)
	(func(): global_position.y = _ground_y()).call_deferred()
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
		# Hazır iskelet animasyonları kendi eklemlerimize (LimbAnim): duruş, saldırı, siper, darbe, ölüm
		anim = LimbAnim.new()
		body.add_child(anim)
		anim.bind(body.rig)
		anim.play("Idle_Shield_Loop" if shield else "Sword_Idle")


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


## Tekme yedi: geri sendeler, kalkanı (muhafızı) açılır, saldırısı yarıda kalır.
func kicked(from: Vector3) -> void:
	if state == St.DEAD:
		return
	state = St.STAGGER
	_t = -0.2              # tekme sersemliği savuşturmadan biraz uzun
	var back := global_position - from
	back.y = 0.0
	back = back.normalized() if back.length() > 0.01 else -global_transform.basis.z
	var to := global_position + back * 0.9
	var tw := create_tween()
	tw.tween_method(func(k: float):
		global_position = global_position.lerp(to, k * 0.5)
		global_position.y = _ground_y(), 0.0, 1.0, 0.25)


## Savuşturuldu: sendeler, açık kalır.
func parried() -> void:
	state = St.STAGGER
	_t = 0.0


func _die() -> void:
	state = St.DEAD
	hp = 0.0
	if has_meta("yield"):
		# Hikâye düellosu: ölmez, kılıcını bırakıp geri çekilir
		if sword:
			var sw := sword
			var at := sw.global_transform
			sw.get_parent().remove_child(sw)
			get_parent().add_child(sw)
			sw.global_transform = at
			var st := sw.create_tween()
			st.tween_property(sw, "global_position:y", global_position.y + 0.05, 0.4).set_ease(Tween.EASE_IN)
			st.parallel().tween_property(sw, "rotation:z", PI / 2.0, 0.4)
		# Geri çekilme yolu: arkası (duvar, barikat, sandık) kapalıysa yana açılır, zemini izler (eskiden 7 m dümdüz
		# geriye kayıp surun ve barikatın içinden geçiyordu)
		var from := global_position
		var to := _retreat_target(global_transform.basis.z)
		var secs := 2.2 * clampf(from.distance_to(to) / 7.0, 0.35, 1.0)
		var tw := create_tween()
		tw.tween_method(func(k: float):
			global_position = from.lerp(to, k)
			global_position.y = _ground_y(), 0.0, 1.0, secs).set_delay(0.4)
		tw.parallel().tween_property(self, "scale", Vector3.ONE * 0.98, secs)
		tw.tween_callback(func(): visible = false)
		died.emit(self)
		return
	if anim:
		anim.play("Death01", 1.0, false)
	else:
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
	# Gövde hep düellocunun önüne (Person'un kendi sohbet/yürüme dönüşleri yüzünü rakipten çeviriyordu)
	body.rotation.y = 0.0
	body.position = Vector3(0.0, body.position.y, 0.0)
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
		_walk(v * delta)
		global_position.y = _ground_y()
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
	if anim:
		_anim_tick(delta)
	else:
		_pose(delta)


## Geri çekilme noktası: arkasına (dir) doğru en çok 7 m; kapalıysa ±35°, ±70°, ±105° dener, en açık yönü seçer.
func _retreat_target(dir: Vector3) -> Vector3:
	dir.y = 0.0
	dir = dir.normalized() if dir.length() > 0.01 else Vector3.BACK
	if not is_inside_tree():
		return global_position + dir * 7.0
	if _step_q == null:
		var cap := CapsuleShape3D.new()
		cap.radius = 0.26
		cap.height = 1.1
		_step_q = PhysicsShapeQueryParameters3D.new()
		_step_q.shape = cap
		_step_q.collision_mask = 1
	_step_q.exclude = _excl()
	var space := get_world_3d().direct_space_state
	var best := global_position
	var best_len := -1.0
	for a: float in [0.0, 0.6, -0.6, 1.2, -1.2, 1.8, -1.8]:
		var d := dir.rotated(Vector3.UP, a) * 7.0
		_step_q.transform = Transform3D(Basis(), global_position + Vector3(0, 1.05, 0))
		_step_q.motion = d
		var r := space.cast_motion(_step_q)
		var free := (r[0] if r.size() > 0 else 1.0) * 7.0 - 0.3
		if free > best_len + 0.5:
			best_len = free
			best = global_position + d.normalized() * maxf(free, 0.0)
		if free >= 6.5:
			break
	return best


## Sorgularda sayılmayanlar: rakip (oyuncu) ve yalnız oyuncuyu durduran görünmez sınırlar ("player_only": gedik
## tepesindeki korkuluk gibi; düellocu gedikten içeri girebilmeli)
func _excl() -> Array[RID]:
	var ex: Array[RID] = []
	if target is CollisionObject3D:
		ex.append((target as CollisionObject3D).get_rid())
	for n in get_tree().get_nodes_in_group("player_only"):
		if n is CollisionObject3D:
			ex.append((n as CollisionObject3D).get_rid())
	return ex


## Bir adım: duvara, sandığa, surun içine yürümesin. Gövde boyu kapsül (dizden başa; alçak basamaklar engel değil)
## adım boyunca süpürülür; önü kapalıysa eksenlerden biri boyunca kayar, o da kapalıysa yerinde kalır.
var _step_q: PhysicsShapeQueryParameters3D
var _detour := 1.0         # engelin hangi yanından dolanılır

func _walk(d: Vector3) -> void:
	d.y = 0.0
	if d.length_squared() < 1e-10 or not is_inside_tree():
		return
	if _step_q == null:
		var cap := CapsuleShape3D.new()
		cap.radius = 0.26
		cap.height = 1.1
		_step_q = PhysicsShapeQueryParameters3D.new()
		_step_q.shape = cap
		_step_q.collision_mask = 1
	_step_q.exclude = _excl()
	var space := get_world_3d().direct_space_state
	# Önce doğrudan, sonra eksenler boyunca kayarak, sonra engelin yanından (45°, 90°) dolanarak. Her yön önce yerden,
	# sonra 0,3 m yukarıdan denenir: moloz basamağına, eşiğe çıkar (gedikteki 0,5 m'lik basamaklarda ve barikatın
	# önünde takılıp kalıyordu)
	var tries: Array[Vector3] = [d, Vector3(d.x, 0, 0), Vector3(0, 0, d.z)]
	for a: float in [0.8, 1.57]:
		tries.append(d.rotated(Vector3.UP, a * _detour))
		tries.append(d.rotated(Vector3.UP, -a * _detour))
	for i in tries.size():
		var m: Vector3 = tries[i]
		if m.length_squared() < 1e-10:
			continue
		for lift: float in [0.0, 0.3]:
			_step_q.transform = Transform3D(Basis(), global_position + Vector3(0, 1.05 + lift, 0))
			_step_q.motion = m
			var r := space.cast_motion(_step_q)
			if r.size() > 0 and r[0] >= 0.999:
				global_position += m
				if i >= 3 and (i - 3) % 2 == 1:
					_detour = -_detour      # öbür yandan dolandı: o yana devam etsin (sağa sola titremesin)
				return


## Ayağının altındaki zemin (1.5 m yukarıdan 4 m aşağıya ışın; kendi gövdesi ve oyuncu hariç). Bulamazsa son y.
func _ground_y() -> float:
	if not is_inside_tree():
		return _y
	var p := global_position
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 1.5, 0), p + Vector3(0, -4.0, 0), 1)
	q.exclude = _excl()
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if not hit.is_empty() and (hit["normal"] as Vector3).y > 0.6:
		_y = (hit["position"] as Vector3).y
	return _y


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


## Animasyon seçimi: saldırı darbe anı oyun mantığındaki STRIKE anına denk getirilir.
func _anim_tick(delta: float) -> void:
	var v := body.rig.speed if body.rig else 0.0
	_moving = lerpf(_moving, v, clampf(delta * 6.0, 0.0, 1.0))
	match state:
		St.WINDUP:
			var c: String = ATTACK_CLIP[dir]
			anim.fade = 0.08
			anim.scrub(c, LimbAnim.hit_time(c) * clampf(_t / windup_time, 0.0, 1.0))
		St.STRIKE, St.RECOVER:
			var c2: String = ATTACK_CLIP[dir]
			var tt := LimbAnim.hit_time(c2) + (_t if state == St.STRIKE else 0.18 + _t)
			anim.scrub(c2, minf(tt, LimbAnim.length(c2)))
		St.STAGGER:
			anim.play("Hit_Knockback", 1.0, false)
		St.FLINCH:
			anim.play("Hit_Chest", 1.4, false)
		St.IDLE:
			anim.fade = 0.2
			if _moving > 0.6:
				anim.play("Walk_Loop", clampf(_moving / 1.4, 0.6, 1.6))
			elif duel and duel.blocking_visible_for(self):
				anim.play("Sword_Block")
			else:
				anim.play("Idle_Shield_Loop" if shield else "Sword_Idle")


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
