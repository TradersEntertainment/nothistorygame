class_name CannonCrew
extends Node3D
## Topu ELLE doldur, gerçekten nişan al, ateşle (kuşatmanın top bölümleri: 17o, 18b, 20o).
##   1) Barut fıçısından torba al (E) → namluya götür, sür (E): torba namluya kayar, toz çıkar.
##   2) Tapa (saman) ve 3) gülle (ağır: yavaş yürürsün) aynı şekilde.
##   4) Tokmağı al, namluda ritimle sıkıştır: işaret yeşildeyken E (3 iyi vuruş); tokmak içeri girip çıkar.
##   5) Topun arkasına geç, nişan al: fare / A-D yön, W-S yükseklik; namludan uzanan nişan çizgisi.
##   6) Ateş (E): fitil cızırdar, alev, duman, geri tepme, sarsıntı; gülle balistik uçar (yerçekimi), hedefe değerse
##      isabet, suya/yere düşerse sıçrama; "kısa / uzun / yandan N m" bilgisi. Sonuç GunDrill.fired(acc) ile gider.
## Otomatik testte adımlar kendiliğinden yapılır, nişan hedefe göre hesaplanır.
##
## Kurulum: pivot (muylu ekseni; namlu parçaları çocukları), muzzle (namlu ağzında, -Z dışarı bakar), yerler.

signal finished(acc: float)

const G := 9.8
const RAM_GOOD := 3
const ITEMS := ["powder", "wad", "ball"]

var player: Player
var hud: Node
var drill: GunDrill
var pivot: Node3D
var muzzle: Node3D
var recoil_node: Node3D          # geri teper (topun kökü)
var aim_spot := Vector3.ZERO      # nişan alırken oyuncunun durduğu yer (dünya)
var supplies := {}                # "powder" | "wad" | "ball" | "rammer" -> Vector3 (dünya)
var target: Callable              # () -> Vector3 hedefin şu anki yeri
var hit_radius := 6.0
var tolerance := 30.0             # bu kadar ıskada doğruluk 0
var ground_y := 0.0               # güllenin düştüğü düzlem (deniz / zemin)
var load_radius := 2.8
var yaw_limit := 25.0
var pitch_min := -6.0
var pitch_max := 28.0
var design_elev := 9.0            # doğru atış yaklaşık bu yükseklikte olsun: hız buna göre ayarlanır
var power := 1.0                  # barut miktarı (18b: az barut = kısa atış)
var aim_back := 4.2               # nişan alırken göz namlu ağzının bu kadar gerisinde
var spawn: Array = []             # sahnede görünür karşılığı olmayan malzemeler: bunlar için model konur
var before_fire: Callable         # ateşten hemen önce (ör. Urban'ın topunda ahşap siper indirilir)
var after_fire: Callable

var state := "idle"               # powder | wad | ball | ram | aim | fly | done | idle
var carrying := ""
var last_impact := Vector3.INF
var feedback := ""                # ekrandaki kısa bilgi (erken/geç, kısa/uzun)
var _feedback_t := 0.0
var ram_phase := 0.0
var ram_good := 0
var yaw := 0.0                    # derece, dinlenmeye göre
var elev := 0.0                   # derece, yatayla
var speed := 60.0
var _held: Node3D
var _rammer_prop: Node3D
var _marker: MeshInstance3D
var _sight: MeshInstance3D
var _ball: Node3D
var _vel := Vector3.ZERO
var _fly_t := 0.0
var _trail_t := 0.0
var _rest_fwd := Vector3.FORWARD
var _corr := Basis.IDENTITY
var _rest_pivot := Basis.IDENTITY
var _rest_root := Vector3.ZERO
var _aiming := false
var _cooldown := 0.0


func setup() -> void:
	_rest_pivot = pivot.global_basis
	_rest_fwd = (-muzzle.global_basis.z).normalized()
	_corr = Basis.looking_at(_rest_fwd, Vector3.UP).inverse() * _rest_pivot
	if recoil_node:
		_rest_root = recoil_node.position
	elev = rad_to_deg(asin(clampf(_rest_fwd.y, -1.0, 1.0)))
	# Ek donatı: sahnede olmayan malzemeler (barut fıçısı, gülle yığını, tapa sepeti), tokmak, hedef halkası
	for k in spawn:
		if supplies.has(k) and k != "rammer":
			_spawn_supply(k, supplies[k])
	if supplies.has("rammer"):
		# Tokmak sehpası: iki direk ve üst kiriş; tokmak kirişe yaslı
		var st := Node3D.new()
		get_parent().add_child(st)
		var rp: Vector3 = supplies["rammer"]
		st.global_position = Vector3(rp.x, _floor_y(rp) if player else rp.y, rp.z)
		for sx: float in [-0.45, 0.45]:
			Props.cyl(st, 0.05, 1.5, Vector3(sx, 0.75, 0.35), Color("5a4028"), Vector3.ZERO, 6)
		Props.cyl(st, 0.04, 1.1, Vector3(0, 1.45, 0.35), Color("5a4028"), Vector3(0, 0, 90), 6)
		_rammer_prop = _rammer_mesh()
		get_parent().add_child(_rammer_prop)
		_rammer_prop.global_position = supplies["rammer"] + Vector3(0, 1.4, 0)
		_rammer_prop.rotation = Vector3(deg_to_rad(15), 0, 0)
	_marker = MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.55
	tm.outer_radius = 0.7
	_marker.mesh = tm
	_marker.material_override = Props.mat(Color("ffd060"), 1.2, false, "", false)
	_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_marker.visible = false
	get_parent().add_child(_marker)
	_sight = MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.04, 0.04, 40.0)
	_sight.mesh = bm
	var sm := Props.mat(Color("ffe6a0"), 1.5, true, "", false)
	sm.albedo_color.a = 0.35
	_sight.material_override = sm
	_sight.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_sight.visible = false
	get_parent().add_child(_sight)


## Doğru yüksekliği design_elev civarına oturtan namlu hızı (hedef uzaklığına göre).
func _tune_speed() -> void:
	var t: Vector3 = target.call()
	var m := muzzle.global_position
	var d := maxf(Vector2(t.x - m.x, t.z - m.z).length(), 5.0)
	var dy := t.y - m.y
	var th := deg_to_rad(design_elev)
	var den := 2.0 * cos(th) * cos(th) * (d * tan(th) - dy)
	speed = sqrt(G * d * d / den) if den > 0.1 else sqrt(G * d / sin(deg_to_rad(2.0 * maxf(design_elev, 5.0))))


func begin(p_power := 1.0) -> void:
	power = p_power
	state = "powder"
	carrying = ""
	ram_good = 0
	yaw = 0.0
	_aiming = false
	last_impact = Vector3.INF
	_tune_speed()
	player.frozen = false
	player.speed_mult = 1.0
	_update_marker()
	if GameState.autotest:
		_auto.call_deferred()


func end() -> void:
	state = "idle"
	_aiming = false
	if _held and is_instance_valid(_held):
		_held.queue_free()
	_held = null
	carrying = ""
	if _marker:
		_marker.visible = false
	if _sight:
		_sight.visible = false
	if hud:
		hud.set_prompt("")
	if player:
		player.speed_mult = 1.0
	if _rammer_prop and supplies.has("rammer"):
		_rammer_prop.global_position = supplies["rammer"] + Vector3(0, 1.4, 0)
		_rammer_prop.rotation = Vector3(deg_to_rad(15), 0, 0)
		_rammer_prop.visible = true


func step_index() -> int:
	return ["powder", "wad", "ball", "ram", "aim"].find(state) if state in ["powder", "wad", "ball", "ram", "aim"] else 5


## Şu anki adımın açıklaması (GunDrill ekranda gösterir).
func hint() -> String:
	match state:
		"powder", "wad", "ball":
			if carrying == "":
				return tr("UI_CREW_TAKE_" + state.to_upper())
			return tr("UI_CREW_LOAD")
		"ram":
			if carrying != "rammer":
				return tr("UI_CREW_TAKE_RAMMER")
			return tr("UI_CREW_RAM") + "  %d/%d" % [ram_good, RAM_GOOD]
		"aim":
			if _aiming:
				return tr("UI_CREW_AIM_KEYS")
			return tr("UI_CREW_GO_AIM")
	return ""


func _spot() -> Vector3:
	match state:
		"powder", "wad", "ball":
			return muzzle.global_position if carrying != "" else supplies.get(state, muzzle.global_position)
		"ram":
			return muzzle.global_position if carrying == "rammer" else supplies.get("rammer", muzzle.global_position)
		"aim":
			return aim_spot
	return muzzle.global_position


func _update_marker() -> void:
	if _marker == null:
		return
	var on := state in ["powder", "wad", "ball", "ram", "aim"] and not _aiming
	_marker.visible = on
	if on:
		var sp := _spot()
		if sp.is_equal_approx(muzzle.global_position):
			# Namlu ağzının çevresinde halka (namlu eksenine dik)
			var fwd := -muzzle.global_basis.z
			_marker.global_transform = Transform3D(Basis.looking_at(fwd, Vector3.UP) * Basis(Vector3.RIGHT, PI * 0.5) * Basis.from_scale(Vector3.ONE * 0.42), muzzle.global_position + fwd * 0.05)
		else:
			_marker.global_transform = Transform3D(Basis.IDENTITY, Vector3(sp.x, _floor_y(sp) + 0.06, sp.z))
		if hud:
			hud.set_objective(hint(), sp + Vector3(0, 1.0, 0))


func _floor_y(p: Vector3) -> float:
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 2.0, 0), p + Vector3(0, -6.0, 0))
	q.exclude = [player.get_rid()]
	var h := space.intersect_ray(q)
	return (h["position"] as Vector3).y if not h.is_empty() else p.y


func _near(p: Vector3, r: float) -> bool:
	var e := player.global_position + Vector3(0, 1.0, 0)
	return Vector2(e.x - p.x, e.z - p.z).length() < r and absf(e.y - p.y) < 3.0


func _process(delta: float) -> void:
	if _feedback_t > 0.0:
		_feedback_t -= delta
		if _feedback_t <= 0.0:
			feedback = ""
	_cooldown = maxf(0.0, _cooldown - delta)
	if state == "idle" or state == "done" or GameState.autotest:
		if state == "fly":
			_fly(delta)
		return
	if state == "fly":
		_fly(delta)
		return
	if _marker and _marker.visible and not _spot().is_equal_approx(muzzle.global_position):
		_marker.rotate_y(delta * 1.5)
	var pressed := Input.is_action_just_pressed("interact") and _cooldown <= 0.0
	match state:
		"powder", "wad", "ball":
			if carrying == "":
				var sp: Vector3 = supplies.get(state, muzzle.global_position)
				var near := _near(sp, 2.0)
				hud.set_prompt(("[E] " + tr("UI_CREW_TAKE_" + state.to_upper())) if near else "")
				if near and pressed:
					_take(state)
			else:
				var near := _near(muzzle.global_position, load_radius)
				hud.set_prompt(("[E] " + tr("UI_CREW_LOAD")) if near else "")
				if near and pressed:
					_load()
		"ram":
			if carrying != "rammer":
				var sp: Vector3 = supplies.get("rammer", muzzle.global_position)
				var near := _near(sp, 2.0)
				hud.set_prompt(("[E] " + tr("UI_CREW_TAKE_RAMMER")) if near else "")
				if near and pressed:
					_take("rammer")
			else:
				var near := _near(muzzle.global_position, load_radius)
				ram_phase = fmod(ram_phase + delta * 0.9, 1.0) if near else 0.0
				hud.set_prompt("" if near else "[E] " + tr("UI_CREW_LOAD"))
				if near and pressed:
					_ram_stroke()
		"aim":
			if not _aiming:
				var near := _near(aim_spot, 1.8)
				hud.set_prompt(("[E] " + tr("UI_CREW_GO_AIM")) if near else "")
				if near and pressed:
					_start_aim()
			else:
				var yi := Input.get_axis("move_left", "move_right")
				var pi := Input.get_axis("move_back", "move_forward")
				yaw = clampf(yaw - yi * 14.0 * delta, -yaw_limit, yaw_limit)
				elev = clampf(elev + pi * 7.0 * delta, pitch_min, pitch_max)
				_apply_aim()
				if pressed or Input.is_action_just_pressed("sword_attack"):
					_fire()
	if drill:
		drill.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if state == "aim" and _aiming and event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var m := event as InputEventMouseMotion
		yaw = clampf(yaw - m.relative.x * 0.06, -yaw_limit, yaw_limit)
		elev = clampf(elev - m.relative.y * 0.04, pitch_min, pitch_max)
		get_viewport().set_input_as_handled()


# ---------------------------------------------------------------- taşıma ve doldurma

func _take(item: String) -> void:
	carrying = item
	_cooldown = 0.2
	Audio.sfx("land_pot", -12.0, 1.2)
	if item == "rammer":
		if _rammer_prop:
			_rammer_prop.visible = false
		_held = _rammer_mesh()
		player.camera.add_child(_held)
		_held.position = Vector3(0.35, -0.45, -0.9)
		_held.rotation = Vector3(deg_to_rad(-70), deg_to_rad(10), 0)
	else:
		_held = _item_mesh(item)
		player.camera.add_child(_held)
		_held.position = Vector3(0.28, -0.42, -0.8)
	player.speed_mult = 0.6 if item == "ball" else 1.0
	_update_marker()


func _load() -> void:
	var item := carrying
	carrying = ""
	_cooldown = 0.3
	player.speed_mult = 1.0
	var n := _held
	_held = null
	# Eldeki nesne dünyaya geçer ve namluya kayar
	var gp := n.global_position
	n.get_parent().remove_child(n)
	get_parent().add_child(n)
	n.global_position = gp
	var fwd := -muzzle.global_basis.z
	var tw := create_tween()
	tw.tween_property(n, "global_position", muzzle.global_position + fwd * 0.15, 0.35).set_trans(Tween.TRANS_SINE)
	tw.tween_property(n, "global_position", muzzle.global_position - fwd * 0.9, 0.3)
	tw.parallel().tween_property(n, "scale", Vector3.ONE * 0.6, 0.3)
	tw.tween_callback(n.queue_free)
	Audio.sfx("land_pot" if item != "ball" else "land_thud", -8.0, [0.8, 1.1, 0.7][ITEMS.find(item)])
	if item == "powder":
		Vfx.dust(get_parent(), muzzle.global_position + fwd * 0.3, 0.25)
	_advance()


func _ram_stroke() -> void:
	_cooldown = 0.15
	var good := ram_phase > 0.38 and ram_phase < 0.62
	var fwd := -muzzle.global_basis.z
	if not good:
		_say(tr("UI_CREW_EARLY") if ram_phase <= 0.38 else tr("UI_CREW_LATE"))
		Audio.sfx("kick_metal", -14.0, 1.4)
		return
	ram_good += 1
	_say(tr("UI_CREW_GOOD"))
	_update_marker()
	Audio.sfx("land_thud", -6.0, 0.9 + ram_good * 0.1)
	player.shake(0.12)
	# Tokmak namluya girer, çıkar
	var r := _rammer_mesh()
	get_parent().add_child(r)
	r.global_position = muzzle.global_position + fwd * 1.2
	r.look_at(muzzle.global_position - fwd * 2.0, Vector3.UP)
	r.rotate_object_local(Vector3.RIGHT, -PI * 0.5)
	var tw := create_tween()
	tw.tween_property(r, "global_position", muzzle.global_position - fwd * 0.4, 0.15)
	tw.tween_property(r, "global_position", muzzle.global_position + fwd * 1.2, 0.25)
	tw.tween_callback(r.queue_free)
	if ram_good >= RAM_GOOD:
		if _held:
			_held.queue_free()
			_held = null
		carrying = ""
		if _rammer_prop:
			_rammer_prop.visible = true
		_advance()


func _advance() -> void:
	match state:
		"powder": state = "wad"
		"wad": state = "ball"
		"ball": state = "ram"
		"ram": state = "aim"
	if drill:
		drill.step = step_index()
		drill.step_done.emit(state)
	_update_marker()


# ---------------------------------------------------------------- nişan ve atış

func _start_aim() -> void:
	_aiming = true
	player.frozen = true
	hud.set_prompt("")
	_marker.visible = false
	_sight.visible = true
	_apply_aim()


func _dir() -> Vector3:
	var flat := Vector3(_rest_fwd.x, 0, _rest_fwd.z).normalized().rotated(Vector3.UP, deg_to_rad(yaw))
	var e := deg_to_rad(elev)
	return (flat * cos(e) + Vector3.UP * sin(e)).normalized()


func _apply_aim() -> void:
	var d := _dir()
	pivot.global_basis = Basis.looking_at(d, Vector3.UP) * _corr
	if _sight:
		_sight.global_position = muzzle.global_position + d * 20.3
		_sight.global_basis = Basis.looking_at(d, Vector3.UP)
	if _aiming:
		# Oyuncu topun arkasında, namlu boyunca bakar
		var flat := Vector3(d.x, 0, d.z).normalized()
		var eye := muzzle.global_position - flat * aim_back
		player.global_position = Vector3(eye.x, _floor_y(eye) + 0.05, eye.z)
		player.face(muzzle.global_position + d * 60.0)


func _fire() -> void:
	state = "fly"
	_aiming = false
	_sight.visible = false
	hud.set_prompt("")
	if drill:
		drill.step = 5
		drill.queue_redraw()
	if before_fire.is_valid():
		await before_fire.call()
	var fuse := Props.ball(get_parent(), 0.08, Vector3.ZERO, Color("ffd060"), Vector3.ONE, 6, 4.0)
	fuse.global_position = pivot.global_position + Vector3(0, 0.5, 0) - _dir() * 0.8
	Audio.sfx("fuse_burn", -6.0)
	await get_tree().create_timer(0.55).timeout
	fuse.queue_free()
	var d := _dir()
	Audio.sfx("cannon", 0.0)
	Vfx.explosion(get_parent(), muzzle.global_position + d * 2.2 + Vector3(0, 0.6, 0), 0.55)
	Vfx.dust(get_parent(), muzzle.global_position + d * 4.0 + Vector3(0, 1.5, 0), 0.5)
	player.shake(0.9)
	if recoil_node:
		var back := -Vector3(d.x, 0, d.z).normalized() * 0.7
		var tw := create_tween()
		tw.tween_property(recoil_node, "position", _rest_root + recoil_node.get_parent().global_basis.inverse() * back, 0.08)
		tw.tween_property(recoil_node, "position", _rest_root, 1.4).set_trans(Tween.TRANS_SINE)
	_ball = Props.ball(get_parent(), 0.2, Vector3.ZERO, Color("2a2624"), Vector3.ONE, 8)
	_trail_t = 0.0
	_ball.global_position = muzzle.global_position + d * 0.7
	_vel = d * speed * power
	_fly_t = 0.0


func _fly(delta: float) -> void:
	if _ball == null:
		return
	# Alt adımlarla ilerle (hızlı gülle hedefin içinden geçmesin)
	var n := 4
	for i in n:
		var dt := delta / n
		_vel.y -= G * dt
		var from := _ball.global_position
		_ball.global_position += _vel * dt
		_fly_t += dt
		var t: Vector3 = target.call()
		# Duvar, zemin, gemi gövdesi: katı bir şeye çarptıysa orada durur
		var q := PhysicsRayQueryParameters3D.create(from, _ball.global_position)
		q.exclude = [player.get_rid()]
		var h := get_world_3d().direct_space_state.intersect_ray(q)
		if not h.is_empty():
			_ball.global_position = h["position"]
			_impact(_ball.global_position.distance_to(t) < hit_radius * 1.5)
			return
		if _ball.global_position.distance_to(t) < hit_radius:
			_impact(true)
			return
		if _ball.global_position.y <= ground_y or _fly_t > 12.0:
			_impact(false)
			return
	# İz: gülle arkasında sönen duman benekleri (uzakta da görünsün)
	_trail_t -= delta
	if _trail_t <= 0.0 and _ball:
		_trail_t = 0.04
		var puff := Props.ball(get_parent(), 0.22, Vector3.ZERO, Color("d8d4cc"), Vector3.ONE, 5)
		puff.global_position = _ball.global_position
		puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var tw := puff.create_tween()
		tw.tween_property(puff, "scale", Vector3.ONE * 2.2, 0.9)
		tw.parallel().tween_property(puff, "position:y", puff.position.y + 0.8, 0.9)
		tw.tween_callback(puff.queue_free)


func _impact(hit: bool) -> void:
	var p := _ball.global_position
	_ball.queue_free()
	_ball = null
	last_impact = p
	var t: Vector3 = target.call()
	var miss := Vector2(p.x - t.x, p.z - t.z).length()
	if GameState.autotest or GameState.shots_dir != "":
		print("CREW impact hit=%s at=%s target=%s t=%.2f speed=%.1f elev=%.1f yaw=%.1f" % [hit, p.snapped(Vector3.ONE * 0.1), t.snapped(Vector3.ONE * 0.1), _fly_t, speed, elev, yaw])
	var acc := 1.0 if hit else clampf(1.0 - (miss - hit_radius) / tolerance, 0.0, 0.8)
	if hit:
		_say(tr("UI_CREW_HIT"))
		# İsabet: kıymık ve toz patlaması, küçük alev
		Vfx.explosion(get_parent(), p, 0.7)
		Vfx.dust(get_parent(), p + Vector3(0, 0.5, 0), 1.0)
		Audio.sfx("explosion_small", -3.0)
	else:
		# Kısa mı uzun mu yandan mı: namlu hattına göre
		var m := muzzle.global_position
		var to_t := Vector2(t.x - m.x, t.z - m.z)
		var to_p := Vector2(p.x - m.x, p.z - m.z)
		var along := to_p.dot(to_t.normalized()) - to_t.length()
		var side := absf(to_t.normalized().cross(to_p))
		if side > absf(along):
			_say(tr("UI_CREW_WIDE") % int(side))
		elif along < 0.0:
			_say(tr("UI_CREW_SHORT") % int(-along))
		else:
			_say(tr("UI_CREW_LONG") % int(along))
		if p.y <= ground_y + 0.5:
			_splash(Vector3(p.x, ground_y, p.z))
			Audio.sfx("splash", -2.0)
		else:
			Vfx.dust(get_parent(), p, 1.2)
			Audio.sfx("explosion_small", -6.0, 0.8)
	state = "done"
	await get_tree().create_timer(0.6 if not GameState.autotest else 0.05).timeout
	if after_fire.is_valid():
		after_fire.call()
	finished.emit(acc)


## Su sütunu: güllenin düştüğü yerde yükselip çöken beyaz su (uzaktan görünür).
func _splash(p: Vector3) -> void:
	var col := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.4
	cm.bottom_radius = 1.4
	cm.height = 1.0
	cm.radial_segments = 10
	col.mesh = cm
	col.material_override = Props.mat(Color("e8f2f8"), 0.6, false, "", false)
	col.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	get_parent().add_child(col)
	col.global_position = p
	col.scale = Vector3(1, 0.1, 1)
	var tw := col.create_tween()
	tw.tween_property(col, "scale", Vector3(1.2, 7.0, 1.2), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(col, "position:y", p.y + 3.5, 0.35)
	tw.tween_property(col, "scale", Vector3(2.2, 0.2, 2.2), 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(col, "position:y", p.y, 0.9)
	tw.tween_callback(col.queue_free)
	Vfx.dust(get_parent(), p + Vector3(0, 0.5, 0), 1.2)


func _say(text: String) -> void:
	feedback = text
	_feedback_t = 1.6
	if drill:
		drill.queue_redraw()


# ---------------------------------------------------------------- otomatik test

func _auto() -> void:
	for item in ITEMS:
		await get_tree().process_frame
		_take(item)
		_load()
	_take("rammer")
	for i in RAM_GOOD:
		ram_phase = 0.5
		_ram_stroke()
	await get_tree().process_frame
	_start_aim()
	_solve_aim()
	_apply_aim()
	await get_tree().process_frame
	_fire()


## Hedefe düşecek yükseklik ve yönü sayısal olarak bul (otomatik test ve ipucu için).
func _solve_aim() -> void:
	var t: Vector3 = target.call()
	var m := muzzle.global_position
	var flat_t := Vector3(t.x - m.x, 0, t.z - m.z)
	var rest_flat := Vector3(_rest_fwd.x, 0, _rest_fwd.z).normalized()
	yaw = clampf(rad_to_deg(rest_flat.signed_angle_to(flat_t.normalized(), Vector3.UP)), -yaw_limit, yaw_limit)
	var best := elev
	var best_err := INF
	var e := pitch_min
	while e <= pitch_max:
		var v := speed * power
		var th := deg_to_rad(e)
		var d := flat_t.length()
		var vx := v * cos(th)
		var tt := d / maxf(vx, 0.1)
		var y := m.y + v * sin(th) * tt - 0.5 * G * tt * tt
		var err := absf(y - t.y)
		if err < best_err:
			best_err = err
			best = e
		e += 0.1
	elev = best


# ---------------------------------------------------------------- modeller

func _item_mesh(item: String) -> Node3D:
	var n := Node3D.new()
	match item:
		"powder":
			Props.cyl(n, 0.14, 0.32, Vector3.ZERO, Color("d8c8a0"), Vector3(90, 0, 0), 8)
			Props.cyl(n, 0.05, 0.08, Vector3(0, 0, 0.2), Color("8a6a40"), Vector3(90, 0, 0), 6)
		"wad":
			Props.cyl(n, 0.16, 0.12, Vector3.ZERO, Color("c8b060"), Vector3(90, 0, 0), 8)
		"ball":
			Props.ball(n, 0.13, Vector3.ZERO, Color("4a4846"), Vector3.ONE, 10)
	for c in n.get_children():
		if c is GeometryInstance3D:
			(c as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return n


func _rammer_mesh() -> Node3D:
	var n := Node3D.new()
	Props.cyl(n, 0.035, 2.6, Vector3(0, 0, 0), Color("7a5a38"), Vector3.ZERO, 6)
	Props.cyl(n, 0.13, 0.22, Vector3(0, 1.3, 0), Color("5a4028"), Vector3.ZERO, 10)
	return n


func _spawn_supply(kind: String, p: Vector3) -> void:
	var b := Node3D.new()
	get_parent().add_child(b)
	b.global_position = Vector3(p.x, _floor_y(p) if is_inside_tree() and player else p.y, p.z)
	match kind:
		"wad":
			Props.cyl(b, 0.35, 0.45, Vector3(0, 0.22, 0), Color("a8844a"), Vector3.ZERO, 10, 1.15)
			for k in 5:
				Props.cyl(b, 0.14, 0.1, Vector3(-0.15 + (k % 3) * 0.15, 0.48, -0.1 + (k / 3) * 0.2), Color("c8b060"), Vector3(90, 0, 0), 8)
		"powder":
			for k in 2:
				Props.cyl(b, 0.3, 0.7, Vector3(-0.35 + k * 0.7, 0.35, 0), Color("3a3028"), Vector3.ZERO, 10)
				Props.cyl(b, 0.31, 0.05, Vector3(-0.35 + k * 0.7, 0.55, 0), Color("6a6460"), Vector3.ZERO, 10)
			for k in 3:
				Props.cyl(b, 0.14, 0.3, Vector3(-0.3 + k * 0.3, 0.1, 0.5), Color("d8c8a0"), Vector3(90, k * 30, 0), 8)
		"ball":
			for k in 6:
				Props.ball(b, 0.2, Vector3(-0.22 + (k % 3) * 0.22, 0.2 + (k / 3) * 0.3, (k / 3) * 0.1), Color("4e4c4a"), Vector3.ONE, 8)
