class_name Handgun
extends Node
## Fitilli el topu (tüfek), birinci şahıs: doldur, nişan al, ateş et. 1453'te iki taraf da kullandı (Giustiniani'nin
## Cenevizlileri, yeniçeriler). Kılıçtan farklı ritim: doldurma yavaş, atış tek ve ağır.
##   Doldur (R / pad Y): barut ve gülle kendiliğinden, harbiyle sıkıştırmada işaret ortadayken R (2 iyi vuruş).
##   Nişan (sağ tık / LT): görüş daralır, tüfek göz hizasına gelir; nefes salınımı (yürürken ve yaralıyken büyür).
##   Ateş (sol tık / RT): fitil falyaya iner (0,25 sn), patlama, duman, geri tepme.
## İsabet kameradan atılan ışınla: hedef gövdesi ışına 0,45 m'den yakınsa ve arada duvar yoksa vurulur.
## Hedefler `targets` ile verilir (düşmemiş Node3D listesi). Vurulan hedef `shot()` çağrısını alır; yoksa geriye devrilir.
## Otomatik testte bot doldurur, nişan alır, ateş eder (tohumlu küçük hata; arada bir bilerek ıskalar).

signal fired(hit: Node3D)

const AIM_SPREAD := 0.6          # derece
const HIP_SPREAD := 3.5
const RANGE := 80.0
const HIT_R := 0.45
const RAM_NEED := 2
const T_POWDER := 0.95
const T_BALL := 0.75
# Görünen tüfeğin yerelinde (namlu -Z): ağız, ellerin dinlenme yerleri, el çantası (ekranın altı), harbinin yuvası
const MUZ := Vector3(0, 0.035, -0.68)
const HL_REST := Vector3(0, -0.04, -0.2)
const HR_REST := Vector3(0.02, -0.07, 0.24)
const POUCH := Vector3(-0.17, -0.24, -0.1)
const ROD_STOW := Vector3(0, -0.014, -0.33)
const ROD_LEN := 0.5

var player: Player
var hud: Hud
var targets: Callable             # () -> Array (Node3D)
var active := false
var loaded := true
var shots := 0
var hits := 0
var state := "idle"               # idle | powder | ball | ram | fire
var ram_phase := 0.0
var ram_good := 0
var _t := 0.0
var _aim := 0.0                   # 0 kalça .. 1 nişan
var _base_fov := 72.0
var _vm: Node3D                   # görünen tüfek (kamera çocuğu)
var _muzzle: Node3D
var _rod: Node3D
var _match: MeshInstance3D
var _hand_l: Node3D
var _hand_r: Node3D
var _horn: Node3D
var _ball: Node3D
var _grains: Array = []
var _arms: Node3D                 # kollar (kameranın çocuğu): dirsekten ele
var _rt := 0.0                    # doldurma adımında geçen süre
var _rod_k := 0.0                 # harbi 0 yuvasında .. 1 namlunun ağzında
var _ram_depth := 0.0
var _kick := 0.0
var _sway_t := 0.0
var _rng := RandomNumberGenerator.new()
var _bot_wait := 0.0
var _bot_target: Node3D
var _bot_prev := Vector3.INF


func begin(p: Player, h: Hud) -> void:
	player = p
	hud = h
	_rng.seed = 1453
	active = true
	player.combat = true
	player.show_remote(false)
	_base_fov = float(GameState.settings.get("fov", 72.0))
	_build()
	_hint()


func end() -> void:
	active = false
	state = "idle"
	if is_instance_valid(player):
		player.combat = false
		if is_instance_valid(player.camera):
			player.camera.fov = _base_fov
	if is_instance_valid(_vm):
		_vm.queue_free()
	_vm = null
	if is_instance_valid(_arms):
		_arms.queue_free()
	_arms = null
	if hud:
		hud.set_qte("")


func alive_targets() -> Array:
	if not targets.is_valid():
		return []
	return (targets.call() as Array).filter(func(n): return is_instance_valid(n) and n.visible and not n.has_meta("gun_down") and not n.has_meta("ducked"))


# ---------------------------------------------------------------- görünüm

func _build() -> void:
	_vm = Node3D.new()
	player.camera.add_child(_vm)
	var wood := Color("5a3a22")
	var iron := Color("2a2622")
	# Kundak (namlu -Z yönünde), demir namlu, ağızda kalınlaşma, arka gez
	Props.box(_vm, Vector3(0.06, 0.08, 0.5), Vector3(0, -0.02, 0.12), wood)
	Props.box(_vm, Vector3(0.05, 0.12, 0.16), Vector3(0, -0.06, 0.34), wood, Vector3(-12, 0, 0))
	Props.cyl(_vm, 0.022, 0.72, Vector3(0, 0.035, -0.3), iron, Vector3(90, 0, 0), 8)
	Props.cyl(_vm, 0.03, 0.05, Vector3(0, 0.035, -0.65), iron, Vector3(90, 0, 0), 8)
	Props.box(_vm, Vector3(0.012, 0.03, 0.012), Vector3(0, 0.068, 0.04), iron)
	Props.box(_vm, Vector3(0.008, 0.02, 0.008), Vector3(0, 0.062, -0.62), iron)
	# Falya ve S biçimli horoz; ucunda yanan fitil
	Props.box(_vm, Vector3(0.03, 0.015, 0.04), Vector3(0.035, 0.04, 0.06), iron)
	var serp := Node3D.new()
	serp.position = Vector3(0.04, 0.0, 0.14)
	_vm.add_child(serp)
	Props.box(serp, Vector3(0.012, 0.012, 0.09), Vector3(0, 0.03, -0.035), iron, Vector3(-40, 0, 0))
	Props.box(serp, Vector3(0.012, 0.07, 0.012), Vector3(0, -0.03, 0.01), iron)
	_match = Props.ball(serp, 0.009, Vector3(0, 0.065, -0.07), Color("ff9030"), Vector3.ONE, 6, 1.4)
	var smoke := CPUParticles3D.new()
	smoke.position = _match.position
	smoke.amount = 6
	smoke.lifetime = 1.4
	smoke.gravity = Vector3(0, 0.25, 0)
	smoke.initial_velocity_min = 0.02
	smoke.initial_velocity_max = 0.05
	smoke.scale_amount_min = 0.5
	smoke.scale_amount_max = 1.2
	var sm := SphereMesh.new()
	sm.radius = 0.003
	sm.height = 0.006
	var smat := StandardMaterial3D.new()
	smat.albedo_color = Color(0.85, 0.85, 0.85, 0.22)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = smat
	smoke.mesh = sm
	smoke.local_coords = false
	serp.add_child(smoke)
	serp.set_meta("rest", serp.rotation)
	serp.name = "Serpentine"
	# Eller: sol el namlunun altında, sağ el kundakta; doldururken sol el boynuzu ve gülleyi getirir, sağ el harbiyi
	# tutar. Kollar (kol yeni) dirsekten ele uzanır.
	_hand_l = Node3D.new()
	_hand_l.position = HL_REST
	_vm.add_child(_hand_l)
	Props.ball(_hand_l, 0.04, Vector3.ZERO, Color("e6ad88"), Vector3(1.1, 0.9, 1.4), 8)
	_hand_r = Node3D.new()
	_hand_r.position = HR_REST
	_vm.add_child(_hand_r)
	Props.ball(_hand_r, 0.042, Vector3.ZERO, Color("e6ad88"), Vector3(1.0, 1.2, 1.0), 8)
	# Barut boynuzu (sol elde; ucu öne), avuçtaki gülle, dökülen barut taneleri
	# (boynuz: kökü elde, sivri ucu -z yönünde 1 birim; her karede elden ağzın üstüne uzatılır)
	_horn = Node3D.new()
	_vm.add_child(_horn)
	Props.cyl(_horn, 0.04, 0.85, Vector3(0, 0, -0.45), Color("9a6a36"), Vector3(-90, 0, 0), 8, 0.012)
	Props.cyl(_horn, 0.042, 0.1, Vector3(0, 0, -0.02), Color("6a4a2a"), Vector3(-90, 0, 0), 8)
	Props.cyl(_horn, 0.012, 0.12, Vector3(0, 0, -0.92), Color("6a4a2a"), Vector3(-90, 0, 0), 5)
	_horn.visible = false
	_ball = Props.ball(_vm, 0.025, Vector3.ZERO, Color("a4a6b0"), Vector3.ONE, 8)
	_ball.visible = false
	for i in 7:
		var g := Props.ball(_vm, 0.007, Vector3.ZERO, Color("1c1a18"), Vector3.ONE, 4)
		g.visible = false
		_grains.append(g)
	# Harbi: namlunun altındaki yuvasında durur; doldururken çekilip ağızdan sokulur
	_rod = Node3D.new()
	_rod.position = ROD_STOW
	_vm.add_child(_rod)
	Props.cyl(_rod, 0.006, ROD_LEN, Vector3(0, 0, 0), Color("8a6440"), Vector3(90, 0, 0), 5)
	Props.cyl(_rod, 0.01, 0.025, Vector3(0, 0, -ROD_LEN * 0.5), Color("3a3634"), Vector3(90, 0, 0), 6)
	_arms = Node3D.new()
	player.camera.add_child(_arms)
	for i in 2:
		var sl := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.026
		cm.bottom_radius = 0.03
		cm.height = 1.0
		cm.radial_segments = 8
		sl.mesh = cm
		sl.material_override = Props.mat(Color("3a3a40"))
		sl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_arms.add_child(sl)
	_muzzle = Node3D.new()
	_muzzle.position = Vector3(0, 0.035, -0.68)
	_vm.add_child(_muzzle)
	Props.strip_outlines(_vm)
	Props.strip_outlines(_arms)
	_vm.scale = Vector3.ONE * 0.8
	for n in _vm.find_children("*", "GeometryInstance3D", true, false):
		(n as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Kamera uzayında [konum, açı(derece)]: kalça, nişan, doldurma pozları arasında
func _pose() -> Array:
	var hip := [Vector3(0.2, -0.2, -0.38), Vector3(2, 5, 0)]
	var aim := [Vector3(0.0, -0.09, -0.26), Vector3.ZERO]
	var pos: Vector3 = (hip[0] as Vector3).lerp(aim[0], _aim)
	var rot: Vector3 = (hip[1] as Vector3).lerp(aim[1], _aim)
	if state in ["powder", "ball", "ram"]:
		# Doldururken tüfek dik: dipçik aşağıda, namlunun ağzı ekranın ortasında (barut, gülle, harbi görünsün)
		pos = Vector3(0.14, -0.3, -0.5)
		rot = Vector3(35, 25, -30)
	pos.z += _kick * 0.12
	rot.x += _kick * 9.0
	var sw := _sway()
	rot.x += sw.y
	rot.y += sw.x
	return [pos, rot]


## Nefes salınımı (derece): nişandayken küçük, yürürken ve yaralıyken büyük; zorlukla ölçeklenir
func _sway() -> Vector2:
	var amp := 0.35 + (1.0 - _aim) * 0.9
	if player.horizontal_speed() > 0.5:
		amp *= 2.0
	if player.hp < 25.0:
		amp *= 1.5
	amp *= GameState.diff("gun_sway")
	if GameState.autotest:
		amp = 0.0
	return Vector2(sin(_sway_t * 1.1), sin(_sway_t * 1.7) * 0.6) * amp


# ---------------------------------------------------------------- döngü

func _process(delta: float) -> void:
	if not active or not is_instance_valid(_vm):
		return
	_t += delta
	_sway_t += delta
	_kick = maxf(_kick - delta * 4.0, 0.0)
	var want_aim := 0.0
	if state == "idle" and (Input.is_action_pressed("gun_aim") or (GameState.autotest and _bot_target != null)):
		want_aim = 1.0
	if state != "fire":                       # ateşlenirken duruş korunur (fitil gecikmesinde tüfek inmesin)
		_aim = move_toward(_aim, want_aim, delta * 5.0)
	player.camera.fov = lerpf(_base_fov, _base_fov * 0.66, _aim)
	var p := _pose()
	var follow := minf(delta * (8.0 if state in ["powder", "ball", "ram"] or _rod_k > 0.0 else 14.0), 1.0)
	_vm.position = _vm.position.lerp(p[0], follow)
	var r: Vector3 = p[1]
	_vm.rotation = _vm.rotation.lerp(Vector3(deg_to_rad(r.x), deg_to_rad(r.y), deg_to_rad(r.z)), follow)
	_load_anim(delta)
	if _match:
		_match.scale = Vector3.ONE * (0.85 + 0.25 * sin(_t * 9.0))
	match state:
		"ram":
			ram_phase = fmod(ram_phase + delta * 0.9, 1.0)
			hud.set_qte(tr("UI_GUN_RAM") + "  " + _gauge() + "  %d/%d" % [ram_good, RAM_NEED])
	if GameState.autotest:
		_bot(delta)
		return
	if player.frozen:
		return
	if Input.is_action_just_pressed("gun_reload"):
		if state == "idle" and not loaded:
			_reload()
		elif state == "ram":
			_ram_stroke()
	elif Input.is_action_just_pressed("gun_fire") and state == "idle":
		if loaded:
			_fire()
		else:
			Audio.sfx("pick_tap", -10.0, 1.6)
			_hint()


## Harbi ritmi göstergesi: işaret ortadaki bölmedeyken bas
func _gauge() -> String:
	var n := 13
	var k := clampi(int(ram_phase * n), 0, n - 1)
	var s := ""
	for i in n:
		var mid := i >= 5 and i <= 7
		s += ("●" if i == k else ("▮" if mid else "·"))
	return "[" + s + "]"


func _hint() -> void:
	if hud == null:
		return
	if state != "idle":
		return
	hud.set_qte(tr("UI_GUN_AIM") if loaded else tr("UI_GUN_RELOAD"))


func _reload() -> void:
	state = "powder"
	_rt = 0.0
	hud.set_qte(tr("UI_GUN_POWDER"))
	Audio.sfx("newspaper", -14.0, 1.8)
	await get_tree().create_timer(T_POWDER).timeout
	if not active:
		return
	state = "ball"
	_rt = 0.0
	hud.set_qte(tr("UI_GUN_BALL"))
	await get_tree().create_timer(0.3).timeout
	if not active:
		return
	Audio.sfx("pick_tap", -10.0, 0.8)        # gülle namluya düşer
	await get_tree().create_timer(T_BALL - 0.3).timeout
	if not active:
		return
	state = "ram"
	_rt = 0.0
	ram_phase = 0.0
	ram_good = 0


func _ram_stroke() -> void:
	var good := ram_phase > 0.38 and ram_phase < 0.62
	Audio.sfx("pick_tap", -8.0 if good else -12.0, 1.1 if good else 0.7)
	if good:
		ram_good += 1
	ram_phase = 0.0                           # harbi geri çekilir; yanlış anda vuruş sayılmaz
	if ram_good >= RAM_NEED:
		loaded = true
		state = "idle"
		_hint()


## Doldurma görünümü: adım adım eller, boynuz, gülle ve harbi (oyun mantığı _reload/_ram_stroke'ta; burası yalnız gösterir)
func _load_anim(delta: float) -> void:
	_rt += delta
	var hl := HL_REST
	var hr := HR_REST
	var pour := MUZ + Vector3(-0.13, 0.07, -0.16)
	var drop := MUZ + Vector3(-0.02, 0.05, -0.12)
	_horn.visible = false
	_ball.visible = false
	for g: Node3D in _grains:
		g.visible = false
	match state:
		"powder":
			# Çantadan boynuzu alır, ağzın üstüne getirir, döker, geri koyar
			hl = _keys(_rt, [[0.0, HL_REST], [0.22, POUCH], [0.45, pour], [0.75, pour], [0.95, POUCH]])
			_horn.visible = _rt > 0.2 and _rt < 0.93
			# Boynuzun ucu: taşırken elin önünde, dökerken namlunun ağzının hemen üstünde
			var tilt := smoothstep(0.38, 0.5, _rt) * (1.0 - smoothstep(0.74, 0.84, _rt))
			var tip := (hl + Vector3(0.1, -0.02, -0.14)).lerp(MUZ + Vector3(0, 0.012, -0.055), tilt)
			_aim_horn(hl, tip)
			if _rt > 0.48 and _rt < 0.76:
				for i in _grains.size():
					var k := fmod(_rt * 6.0 + i / float(_grains.size()), 1.0)
					var g: Node3D = _grains[i]
					g.visible = true
					g.position = tip.lerp(MUZ + Vector3(0, 0, 0.02), k) + Vector3(sin(i * 2.3) * 0.004, 0, 0)
		"ball":
			# Çantadan gülleyi alır, ağzın üstünde bırakır: gülle namluya düşer
			hl = _keys(_rt, [[0.0, POUCH], [0.3, drop], [0.42, drop], [0.75, HL_REST]])
			if _rt < 0.36:
				_ball.visible = _rt > 0.05
				_ball.position = hl + Vector3(0.03, 0.035, -0.08)
			elif _rt < 0.5:
				_ball.visible = true
				_ball.position = (drop + Vector3(0.03, 0.035, -0.08)).lerp(MUZ + Vector3(0, 0, 0.05), smoothstep(0.36, 0.5, _rt))
	# Harbi: sıkıştırırken namlunun ağzında, sıkıştırma evresiyle (ortada en dipte) inip çıkar; bitince yuvasına
	if state == "ram":
		_rod_k = move_toward(_rod_k, 1.0, delta / 0.35)
		var want := 0.5 - 0.5 * cos(ram_phase * TAU)
		_ram_depth = lerpf(_ram_depth, want, minf(delta * 18.0, 1.0))
	else:
		_rod_k = move_toward(_rod_k, 0.0, delta / 0.3)
		_ram_depth = lerpf(_ram_depth, 0.0, minf(delta * 10.0, 1.0))
	var at_muz := Vector3(0, MUZ.y, MUZ.z + 0.3 * _ram_depth - ROD_LEN * 0.5)
	var k := smoothstep(0.0, 1.0, _rod_k)
	_rod.position = ROD_STOW.lerp(at_muz, k) + Vector3(0, 0.07 * sin(PI * k), 0)
	if _rod_k > 0.0:
		hr = HR_REST.lerp(_rod.position + Vector3(0.0, 0.02, -ROD_LEN * 0.5 + 0.05), smoothstep(0.0, 0.6, _rod_k))
	var f := minf(delta * 16.0, 1.0)
	_hand_l.position = _hand_l.position.lerp(hl, f) if state != "powder" and state != "ball" else hl
	_hand_r.position = _hand_r.position.lerp(hr, f) if _rod_k <= 0.0 else hr
	_place_arms()


## Boynuzu kökü `base`ta, ucu `tip`te olacak biçimde yerleştir (tüfeğin yerelinde)
func _aim_horn(base: Vector3, tip: Vector3) -> void:
	var d := tip - base
	var ln := maxf(d.length(), 0.02)
	var zb := -d / ln
	var xb := Vector3.UP.cross(zb)
	xb = xb.normalized() if xb.length() > 0.01 else Vector3.RIGHT
	var yb := zb.cross(xb)
	_horn.transform = Transform3D(Basis(xb, yb, zb * ln * 1.08), base)


## Anahtar karelerden yumuşak geçiş: keys [[zaman, konum], ...]
static func _keys(t: float, keys: Array) -> Vector3:
	if t <= float(keys[0][0]):
		return keys[0][1]
	for i in keys.size() - 1:
		var a: Array = keys[i]
		var b: Array = keys[i + 1]
		if t <= float(b[0]):
			var u := smoothstep(float(a[0]), float(b[0]), t)
			return (a[1] as Vector3).lerp(b[1], u)
	return keys[-1][1]


## Önkollar: elden omuza doğru (ekranın altına ve geriye) 26 cm kol yeni
func _place_arms() -> void:
	if not is_instance_valid(_arms):
		return
	var cam := player.camera
	# Önkol elden aşağı ve biraz geriye iner (kameraya doğru uzansa ekranı kütük gibi kapatıyordu)
	var down := [Vector3(-0.3, -0.88, 0.36).normalized(), Vector3(0.3, -0.88, 0.36).normalized()]
	var hands := [_hand_l, _hand_r]
	for i in 2:
		var sl := _arms.get_child(i) as MeshInstance3D
		var h: Vector3 = cam.to_local((hands[i] as Node3D).global_position)
		var e: Vector3 = h + (down[i] as Vector3) * 0.27
		var d := h - e
		var ln := maxf(d.length() - 0.025, 0.01)
		var y := d.normalized()
		var x := y.cross(Vector3.FORWARD)
		x = x.normalized() if x.length() > 0.1 else Vector3.RIGHT
		var z := x.cross(y)
		sl.transform = Transform3D(Basis(x, y * ln, z), e + y * (ln * 0.5))


func _fire() -> void:
	state = "fire"
	loaded = false
	hud.set_qte("")
	# Horoz falyaya iner: fitil barutu tutuşturur, kısa cızırtı
	var serp := _vm.get_node_or_null("Serpentine") as Node3D
	if serp:
		var tw := serp.create_tween()
		tw.tween_property(serp, "rotation:x", deg_to_rad(-35.0), 0.12)
		tw.tween_property(serp, "rotation:x", 0.0, 0.3).set_delay(0.3)
	Audio.sfx("fuse_burn", -12.0, 1.8)
	_pan_flash()
	await get_tree().create_timer(0.25).timeout
	if not active:
		return
	var spread := lerpf(HIP_SPREAD, AIM_SPREAD, _aim)
	var cam := player.camera
	var from := cam.global_position
	var dir := -cam.global_transform.basis.z
	var sw := _sway()
	dir = dir.rotated(cam.global_transform.basis.y, deg_to_rad(sw.x)).rotated(cam.global_transform.basis.x, deg_to_rad(sw.y))
	var ang := _rng.randf() * TAU
	var off := deg_to_rad(spread) * sqrt(_rng.randf())
	var side := cam.global_transform.basis.x * cos(ang) + cam.global_transform.basis.y * sin(ang)
	dir = (dir + side * tan(off)).normalized()
	_blast()
	shots += 1
	GameState.combat_add("gun_shots")
	var hit := _trace(from, dir)
	_kick = 1.0
	cam.rotation.x = clampf(cam.rotation.x + deg_to_rad(3.5), deg_to_rad(-85), deg_to_rad(85))
	Fx.trauma(0.3)
	if hit:
		hits += 1
		GameState.combat_add("gun_hits")
		Fx.hitstop(0.05)
		Audio.stinger("kill", -6.0)
		_down(hit)
	fired.emit(hit)
	await get_tree().create_timer(0.5).timeout
	if active:
		state = "idle"
		_hint()


## Işın: en yakın hedef (gövde ya da baş), arada duvar yoksa
func _trace(from: Vector3, dir: Vector3) -> Node3D:
	var best: Node3D = null
	var best_d := RANGE
	for n in alive_targets():
		for part: Array in [[1.15, HIT_R], [1.6, 0.25]]:
			var c := (n as Node3D).global_position + Vector3(0, part[0], 0)
			var along := (c - from).dot(dir)
			if along < 0.5 or along > best_d:
				continue
			if (from + dir * along).distance_to(c) <= float(part[1]):
				best = n
				best_d = along
	var space := player.get_world_3d().direct_space_state
	# Namlu kameranın 1,3 m önünde (siperden sarkarak). Görünmez sınır duvarları mermiyi durdurmaz.
	var ex: Array[RID] = [player.get_rid()]
	for _i in 6:
		var q := PhysicsRayQueryParameters3D.create(from + dir * 1.3, from + dir * (best_d if best else RANGE))
		q.exclude = ex
		q.collision_mask = 1
		var r := space.intersect_ray(q)
		if r.is_empty():
			break
		var col := r["collider"] as Node
		if col is CollisionObject3D and _invisible(col):
			ex.append((col as CollisionObject3D).get_rid())
			continue
		var mine := best != null and col != null and (best.is_ancestor_of(col) or col == best)
		if not mine:
			Vfx.dust(player.get_parent(), r["position"], 0.25)
			return null
		break
	if best == null:
		# Iska: hedefin arkasındaki yere toz
		var g := from + dir * 40.0
		if dir.y < -0.01:
			g = from + dir * minf(40.0, -from.y / dir.y)
		Vfx.dust(player.get_parent(), g, 0.25)
	return best


## Görünmez gövde (sınır duvarı, korkuluk): görünen bir ağı yok
func _invisible(col: Node) -> bool:
	for c in col.get_children():
		if c is VisualInstance3D and (c as VisualInstance3D).visible:
			return false
	return true


## Vurulan hedef: kendi tepkisi varsa o; yoksa atıcıdan uzağa geriye devrilir, bir süre yatar, kaybolur
func _down(n: Node3D) -> void:
	n.set_meta("gun_down", true)
	if n.has_method("shot"):
		n.call("shot", player.global_position)
		return
	if "rig" in n and n.get("rig") != null:
		n.get("rig").set("activity", "fall")
	var away := n.global_position - player.global_position
	away.y = 0.0
	var head := n.global_position + Vector3(0, 1.6, 0)
	var axis := n.global_transform.basis.x
	var sgn := 1.0
	var a := Basis(axis, deg_to_rad(85.0)) * (head - n.global_position)
	var b := Basis(axis, deg_to_rad(-85.0)) * (head - n.global_position)
	if a.dot(away) < b.dot(away):
		sgn = -1.0
	var tw := n.create_tween()
	tw.tween_property(n, "rotation", (Basis(axis, deg_to_rad(85.0) * sgn) * n.global_transform.basis).get_euler(), 0.45).set_ease(Tween.EASE_IN)
	tw.tween_interval(2.0)
	tw.tween_property(n, "visible", false, 0.0)


func _pan_flash() -> void:
	var f := Props.ball(_vm, 0.03, Vector3(0.035, 0.06, 0.06), Color("fff0a0"), Vector3.ONE, 6, 4.0)
	var tw := f.create_tween()
	tw.tween_property(f, "scale", Vector3.ONE * 2.5, 0.2)
	tw.tween_callback(f.queue_free)


## Namlu ağzı: kısa alev, ışık, yoğun beyaz barut dumanı (dünyada kalır, oyuncu içinden geçer)
func _blast() -> void:
	var world := player.get_parent() as Node3D
	var at := _muzzle.global_position
	var fwd := -player.camera.global_transform.basis.z
	Audio.sfx("cannon", -4.0, 1.9)
	Audio.sfx("explosion_small", -12.0, 1.7)
	var fl := Props.ball(_vm, 0.06, _muzzle.position + Vector3(0, 0, -0.06), Color("ffe080"), Vector3(1, 1, 2.2), 8, 5.0)
	var tw := fl.create_tween()
	tw.tween_property(fl, "scale", Vector3.ONE * 1.8, 0.05)
	tw.tween_callback(fl.queue_free)
	blast_fx(world, at, fwd, 99.0)


## Namlu ağzı (oyuncu ve düşman tüfekçisi): kısa ışık, yoğun beyaz barut dumanı. sound_db 99: ses yok.
static func blast_fx(world: Node3D, at: Vector3, fwd: Vector3, sound_db := -6.0) -> void:
	if sound_db < 50.0:
		Audio.sfx("cannon", sound_db, 2.0)
	var l := OmniLight3D.new()
	l.light_color = Color("ffb050")
	l.light_energy = 4.0
	l.omni_range = 8.0
	world.add_child(l)
	l.global_position = at
	var lt := l.create_tween()
	lt.tween_property(l, "light_energy", 0.0, 0.15)
	lt.tween_callback(l.queue_free)
	# Duman namlunun önünde açılır, yükselip yana dağılır (gözün önünü bir an örter ama kapatmaz)
	var puff := Vfx._sphere(0.08, Vfx._mat(Color(1, 1, 1, 1)), 10)
	Vfx._burst(world, at + fwd * 1.2, 30, puff, Vfx._grad([Color(0.92, 0.9, 0.86, 0.32), Color(0.8, 0.78, 0.74, 0.2), Color(0.8, 0.8, 0.78, 0.0)]),
		2.2, Vector2(1.5, 5.0), 16.0, Vector3(0.4, 0.5, 0), Vector2(0.8, 2.4), fwd)


# ---------------------------------------------------------------- bot

func _bot(delta: float) -> void:
	if player.frozen and state == "idle":
		return
	match state:
		"idle":
			if not loaded:
				_reload()
				return
			# Mazgaldakilerden yalnız yeni belireni (siperin ardına çökmeden vurulabilecek olanı) seç
			var list := alive_targets().filter(func(n): return float(n.get_meta("up_t", 0.0)) < 0.9)
			if list.is_empty():
				_bot_target = null
				return
			if _bot_target == null or not list.has(_bot_target):
				_bot_target = list[0]
				for n in list:
					if (n as Node3D).global_position.distance_to(player.global_position) < _bot_target.global_position.distance_to(player.global_position):
						_bot_target = n
				_bot_wait = 0.7
				_bot_prev = Vector3.INF
			# Nişan: gövdeye; her dördüncü atışta bilerek 2,5° sapma (ıska yolu da denensin)
			# Koşan hedefe fitil gecikmesi kadar önden nişan
			var c := _bot_target.global_position + Vector3(0, 1.15, 0)
			var vel := Vector3.ZERO
			if _bot_prev != Vector3.INF and delta > 0.0:
				vel = (_bot_target.global_position - _bot_prev) / delta
			_bot_prev = _bot_target.global_position
			player.face(c + vel * 0.27)
			_bot_wait -= delta
			if _bot_wait <= 0.0 and _aim > 0.95:
				if shots % 4 == 3:
					player.camera.rotation.x += deg_to_rad(2.5)
				_fire()
				_bot_target = null
				_bot_prev = Vector3.INF
		"ram":
			if ram_phase > 0.45 and ram_phase < 0.55:
				_ram_stroke()

