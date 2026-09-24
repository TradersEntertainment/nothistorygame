class_name Rig
extends RefCounted
## Yordamsal karakter animasyonu (Person, Hikmet, Soldier ortak).
## Yürüme hızı konumun kareler arası değişiminden ölçülür: tween'le taşınan (uçan, yürütülen) karakterler
## de kendiliğinden yürür. Boşta nefes, bakınma, göz kırpma; konuşurken baş sallama ve kol jestleri.
## emote() tepki animasyonlarını oynatır; o sırada ve lock > 0 iken uzuvlara dokunulmaz.

var owner: Node3D
var body: Node3D
var head: Node3D
var arm_l: Node3D
var arm_r: Node3D
var leg_l: Node3D
var leg_r: Node3D
var eyes: Node3D          # isteğe bağlı: göz kırpma
var brows: Node3D         # isteğe bağlı: kaş
var arm_rest_z := 0.1     # kolların gövdeden açıklığı (dinlenme)
var lock := 0
var speed := 0.0
## Sürekli iş hareketi: "" (yok), "sit" (tabureye), "sit_ground" (yere bağdaş), "stir" (kazan karıştırır),
## "hammer" (çekiç), "chop" (doğrar), "write" (yere oturmuş yazar), "paint" (fırça), "carry" (önünde yük; yürürken de).
## Konuşurken el işleri durur (oturuşlar sürer), konuşma bitince devam eder.
var activity := ""

var _t := 0.0
var _last_pos := Vector3.INF
var _walk_phase := 0.0
var _blink_t := 2.0
var _look_t := 1.0
var _look_yaw := 0.0
var _look_pitch := 0.0
var _gesture_t := 0.0
var _gesture := Vector4.ZERO      # sağ kol x, sağ kol z, sol kol x, sol kol z
var _brow_y0 := 0.0


func _init(p_owner: Node3D, parts: Dictionary) -> void:
	owner = p_owner
	body = parts.get("body")
	head = parts.get("head")
	arm_l = parts.get("arm_l")
	arm_r = parts.get("arm_r")
	leg_l = parts.get("leg_l")
	leg_r = parts.get("leg_r")
	eyes = parts.get("eyes")
	brows = parts.get("brows")
	arm_rest_z = parts.get("arm_rest_z", 0.1)
	if brows:
		_brow_y0 = brows.position.y
	_t = randf() * 10.0
	_blink_t = randf_range(0.5, 4.0)


func update(delta: float, talking: bool, busy: bool) -> void:
	_t += delta
	var k := clampf(delta * 8.0, 0.0, 1.0)
	var gp := owner.global_position
	if _last_pos != Vector3.INF and delta > 0.0:
		var dist := Vector2(gp.x - _last_pos.x, gp.z - _last_pos.z).length()
		if dist < 2.0:   # daha büyük sıçrama ışınlanmadır, yürüme sayılmaz
			speed = lerpf(speed, minf(dist / delta, 8.0), clampf(delta * 6.0, 0.0, 1.0))
	_last_pos = gp
	# Göz kırpma
	if eyes:
		_blink_t -= delta
		if _blink_t <= 0.0:
			_blink_t = randf_range(2.2, 5.5)
			eyes.scale.y = 0.12
		elif eyes.scale.y < 1.0:
			eyes.scale.y = minf(1.0, eyes.scale.y + delta * 9.0)
	if brows and lock == 0:
		var by := 0.012 * absf(sin(_t * 2.3)) if talking else 0.0
		brows.position.y = lerpf(brows.position.y, _brow_y0 + by, k)
	if lock > 0 or busy:
		return
	if speed > 0.35:
		_walk_phase += delta * (3.0 + speed * 1.6)
		var amp := clampf(speed / 3.0, 0.35, 1.0)
		var sw := sin(_walk_phase)
		if leg_l:
			leg_l.rotation.x = sw * 0.55 * amp
		if leg_r:
			leg_r.rotation.x = -sw * 0.55 * amp
		if arm_l:
			arm_l.rotation.x = -sw * 0.45 * amp
			arm_l.rotation.z = lerpf(arm_l.rotation.z, -arm_rest_z - 0.02, k)
		if arm_r:
			arm_r.rotation.x = sw * 0.45 * amp
			arm_r.rotation.z = lerpf(arm_r.rotation.z, arm_rest_z + 0.02, k)
		body.position.y = absf(sw) * 0.035 * amp
		body.rotation.x = lerpf(body.rotation.x, 0.06 * amp, k)
		if head:
			head.rotation = head.rotation.lerp(Vector3.ZERO, k)
		if activity == "carry" and arm_l and arm_r:
			arm_r.rotation = arm_r.rotation.lerp(Vector3(-1.25, 0, 0.18), k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-1.25, 0, -0.18), k)
		return
	if activity != "" and _activity(delta, talking, k):
		return
	# Durunca bacaklar toplanır, beden dikleşir; nefes (oturanlarda oturuş korunur)
	if not activity in ["sit", "sit_ground", "write"]:
		if leg_l:
			leg_l.rotation.x = lerpf(leg_l.rotation.x, 0.0, k)
		if leg_r:
			leg_r.rotation.x = lerpf(leg_r.rotation.x, 0.0, k)
		body.position.y = lerpf(body.position.y, sin(_t * 1.8) * 0.006, k)
		body.rotation.x = lerpf(body.rotation.x, 0.0, k)
	# Bakınma; konuşurken başını sallar
	if head:
		_look_t -= delta
		if _look_t <= 0.0:
			_look_t = randf_range(2.0, 5.0)
			_look_yaw = randf_range(-0.45, 0.45) if randf() < 0.6 else 0.0
			_look_pitch = randf_range(-0.12, 0.08)
		var ht := Vector3(_look_pitch, _look_yaw, 0.0)
		if talking:
			ht = Vector3(sin(_t * 5.2) * 0.07, sin(_t * 1.3) * 0.12, sin(_t * 2.1) * 0.04)
		head.rotation = head.rotation.lerp(ht, clampf(delta * 4.0, 0.0, 1.0))
	if arm_l == null or arm_r == null:
		return
	# Kollar: konuşurken jest (öne uzatma, açma, havaya kaldırma), boşta hafif salınım
	if talking:
		_gesture_t -= delta
		if _gesture_t <= 0.0:
			_gesture_t = randf_range(0.9, 2.0)
			match randi() % 5:
				0: _gesture = Vector4(-0.9, 0.25, 0.0, -0.1)
				1: _gesture = Vector4(-0.5, 0.6, -0.5, -0.6)
				2: _gesture = Vector4(0.0, 0.1, -0.8, -0.3)
				3: _gesture = Vector4(-1.3, 0.1, 0.0, -0.1)
				_: _gesture = Vector4(-0.2, 0.15, -0.2, -0.15)
		var bob := sin(_t * 6.0) * 0.08
		var g := clampf(delta * 5.0, 0.0, 1.0)
		arm_r.rotation.x = lerpf(arm_r.rotation.x, _gesture.x + bob, g)
		arm_r.rotation.z = lerpf(arm_r.rotation.z, _gesture.y, g)
		arm_l.rotation.x = lerpf(arm_l.rotation.x, _gesture.z - bob, g)
		arm_l.rotation.z = lerpf(arm_l.rotation.z, _gesture.w, g)
	else:
		var sway := sin(_t * 1.8) * 0.03
		arm_r.rotation.x = lerpf(arm_r.rotation.x, sway, k * 0.5)
		arm_r.rotation.z = lerpf(arm_r.rotation.z, arm_rest_z, k * 0.5)
		arm_l.rotation.x = lerpf(arm_l.rotation.x, -sway, k * 0.5)
		arm_l.rotation.z = lerpf(arm_l.rotation.z, -arm_rest_z, k * 0.5)


## İş hareketi; true dönerse normal boşta/konuşma animasyonu atlanır.
func _activity(delta: float, talking: bool, k: float) -> bool:
	var sitting := activity in ["sit", "sit_ground", "write"]
	if sitting:
		var drop := -0.22 if activity == "sit" else -0.56
		body.position.y = lerpf(body.position.y, drop, k)
		body.rotation.x = lerpf(body.rotation.x, 0.08 if activity == "write" else 0.0, k)
		if leg_l:
			leg_l.rotation = leg_l.rotation.lerp(Vector3(-1.45, 0, -0.18 if activity != "sit" else 0.0), k)
		if leg_r:
			leg_r.rotation = leg_r.rotation.lerp(Vector3(-1.45, 0, 0.18 if activity != "sit" else 0.0), k)
	if talking or arm_l == null or arm_r == null:
		# Konuşurken oturuş sürer, kollar ve baş normal konuşma jestine döner
		return false
	var t := _t
	match activity:
		"sit", "sit_ground":
			arm_r.rotation = arm_r.rotation.lerp(Vector3(-0.7, 0, 0.15), k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.7, 0, -0.15), k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(sin(t * 0.5) * 0.05, sin(t * 0.37) * 0.3, 0), clampf(delta * 2.0, 0.0, 1.0))
		"write":
			arm_r.rotation = arm_r.rotation.lerp(Vector3(-1.05 + sin(t * 11.0) * 0.04, 0, 0.12 + sin(t * 2.3) * 0.08), k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.9, 0, -0.1), k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(0.38, sin(t * 0.4) * 0.08, 0), k)
		"stir":
			arm_r.rotation = Vector3(-1.05 + sin(t * 3.0) * 0.22, 0, 0.3 + cos(t * 3.0) * 0.22)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.75, 0, -0.2), k)
			body.rotation.x = lerpf(body.rotation.x, 0.14, k)
			body.position.y = lerpf(body.position.y, sin(t * 3.0) * 0.01, k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(0.3, sin(t * 0.6) * 0.15, 0), k)
		"chop":
			arm_r.rotation = Vector3(-1.0 - absf(sin(t * 8.0)) * 0.35, 0, 0.2)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.85, 0, -0.1), k)
			body.rotation.x = lerpf(body.rotation.x, 0.1, k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(0.35, sin(t * 0.5) * 0.1, 0), k)
		"hammer":
			var ph := fmod(t * 1.4, 1.0)
			var swing := -2.5 + pow(ph, 3.0) * 1.9 if ph < 0.85 else -0.6 - (ph - 0.85) / 0.15 * 1.9
			arm_r.rotation = Vector3(swing, 0, 0.15)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.8, 0, -0.25), k)
			body.rotation.x = lerpf(body.rotation.x, 0.18, k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(0.35, 0, 0), k)
		"paint":
			arm_r.rotation = Vector3(-1.45 + sin(t * 2.2) * 0.25, 0, 0.3 + sin(t * 1.3) * 0.15)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.5, 0, -0.35), k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(-0.05, sin(t * 0.5) * 0.1, sin(t * 0.8) * 0.1), k)
		"carry":
			arm_r.rotation = arm_r.rotation.lerp(Vector3(-1.25, 0, 0.18), k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-1.25, 0, -0.18), k)
			return false if head == null else _idle_head(delta)
		_:
			return false
	return true


func _idle_head(delta: float) -> bool:
	_look_t -= delta
	if _look_t <= 0.0:
		_look_t = randf_range(2.0, 5.0)
		_look_yaw = randf_range(-0.45, 0.45) if randf() < 0.6 else 0.0
	head.rotation = head.rotation.lerp(Vector3(0, _look_yaw, 0), clampf(delta * 4.0, 0.0, 1.0))
	return true


## Tepki animasyonları: "surprise", "laugh", "shrug", "wave", "nod", "facepalm", "cheer".
func emote(kind: String) -> void:
	if not owner.is_inside_tree() or arm_l == null or arm_r == null:
		return
	lock += 1
	var tw := owner.create_tween()
	match kind:
		"surprise":
			tw.set_parallel(true)
			tw.tween_property(arm_r, "rotation", Vector3(-2.6, 0, 0.5), 0.15)
			tw.tween_property(arm_l, "rotation", Vector3(-2.6, 0, -0.5), 0.15)
			tw.tween_property(body, "rotation:x", -0.12, 0.15)
			if head:
				tw.tween_property(head, "rotation:x", -0.2, 0.15)
			if brows:
				tw.tween_property(brows, "position:y", _brow_y0 + 0.03, 0.15)
			tw.set_parallel(false)
			tw.tween_interval(0.7)
		"laugh":
			for i in 6:
				tw.tween_property(body, "rotation:x", 0.12, 0.09)
				tw.tween_property(body, "rotation:x", -0.04, 0.09)
			if head:
				tw.parallel().tween_property(head, "rotation:x", -0.25, 0.3)
		"shrug":
			tw.set_parallel(true)
			tw.tween_property(arm_r, "rotation", Vector3(-0.4, 0, 0.9), 0.2)
			tw.tween_property(arm_l, "rotation", Vector3(-0.4, 0, -0.9), 0.2)
			if head:
				tw.tween_property(head, "rotation:z", 0.2, 0.2)
			if brows:
				tw.tween_property(brows, "position:y", _brow_y0 + 0.02, 0.2)
			tw.set_parallel(false)
			tw.tween_interval(0.6)
		"wave":
			tw.tween_property(arm_r, "rotation", Vector3(-2.7, 0, 0.3), 0.2)
			for i in 3:
				tw.tween_property(arm_r, "rotation:z", 0.7, 0.14)
				tw.tween_property(arm_r, "rotation:z", 0.1, 0.14)
		"nod":
			if head:
				for i in 2:
					tw.tween_property(head, "rotation:x", 0.3, 0.14)
					tw.tween_property(head, "rotation:x", -0.05, 0.14)
			else:
				tw.tween_interval(0.5)
		"facepalm":
			tw.tween_property(arm_r, "rotation", Vector3(-2.2, 0, -0.6), 0.25)
			if head:
				tw.parallel().tween_property(head, "rotation:x", 0.3, 0.25)
			tw.tween_interval(0.8)
		"cheer":
			var y0 := owner.position.y
			tw.set_parallel(true)
			tw.tween_property(arm_r, "rotation", Vector3(-2.9, 0, 0.2), 0.15)
			tw.tween_property(arm_l, "rotation", Vector3(-2.9, 0, -0.2), 0.15)
			tw.tween_property(owner, "position:y", y0 + 0.25, 0.15)
			tw.set_parallel(false)
			tw.tween_property(owner, "position:y", y0, 0.2)
			tw.tween_interval(0.3)
		_:
			tw.tween_interval(0.1)
	await tw.finished
	lock -= 1
