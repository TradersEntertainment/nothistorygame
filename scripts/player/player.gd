class_name Player
extends CharacterBody3D
## Birinci şahıs oyuncu (Tolga). Yürür, koşar, zıplar, bakar ve
## E ile önündeki etkileşim alanıyla (katman 2) etkileşir.

signal interacted(id: String)
signal focus_changed(id: String)
## Elde tutulan eşya kullanıldı: target = bakılan etkileşim kimliği ("" = kendine/boşluğa)
signal item_used(target: String, item: String)

const WALK := 3.2
const RUN := 5.2
const JUMP := 3.6
const MOUSE_SENS := 0.0022
const EYE := 1.62

var frozen := false:
	set(v):
		var was := frozen
		frozen = v
		if v and traversal:
			traversal.cancel()
		if was and not v and is_inside_tree():
			_on_released.call_deferred()
## "walk": klavyeyle yürüme. "script": yatay hız bölüm betiğinden gelir (koşu, yüzme).
var move_mode := "walk"
var script_velocity := Vector3.ZERO
var gravity_on := true
## Suda: kamera dalgayla hafifçe iner kalkar ve yana yatar.
var floating := false
var _float_t := 0.0
var focus_id := ""
var camera: Camera3D
var _ray: RayCast3D
var _bob := 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _shake := 0.0
var hand: Node3D
var _thumb: Node3D
var _red_light: MeshInstance3D
## Yerine sabit (kayıkta kürekte): hareket ve zıplama kapalı, bakış açık; konumu bölüm verir, Space bölüme kalır.
var pinned := false
## Kılıç dövüşü (Duel): fare yalnız yön seçer, kamera lock_target'a kilitlenir; eşya ve tekme kapalı.
var combat := false
var lock_target: Node3D
## Merdivende: tutunulan merdiven ve üzerindeki yükseklik (m)
var ladder: Ladder
var _ladder_t := 0.0
var _ladder_cool := 0.0
## Merdivende yana sarkma (A/D, -1 sol … 1 sağ, metre): kaynar yağ ve taş merdivenin ortasından iner
var ladder_side := 0.0
var _hand_shown := false
var _hand_base := Vector3(0.24, -0.19, -0.4)
var _hand_tween: Tween
var leg: Node3D
## Birinci şahıs el görünümü: "tolga" (redingot) ya da "hikmet" (çizgili pijama).
var hand_style := "tolga"
## Göz yüksekliği ve hız çarpanı (Bölüm 16: tavuk yüksekliğinde kamera)
var eye_height := EYE
var speed_mult := 1.0
## Can (kuşatma): ok, gülle ve kılıç darbesi düşürür. Oyuncu ölmez: 0'da yere düşer, kısa kararmadan sonra 40 canla
## kalkar; bölüm `downed` sinyaliyle kendi cezasını uygular. Son darbeden 4 sn sonra yavaşça dolar (dövüşte dolmaz).
signal hurt_taken(amount: float)
signal downed
const MAX_HP := 100.0
var hp := MAX_HP
var is_down := false
var downs := 0
var _hurt_t := 99.0
var _heart_t := 0.0
var _hp_layer: CanvasLayer
var _hp_bar: ColorRect
var _hp_back: ColorRect
## Kendine bakış: fes/kaftan değişince ya da V tuşuyla kısa bir üçüncü şahıs çekimi (yalnızca Tolga)
var outfit_enabled := true
var _outfit_busy := false
var _outfit_pending := false
var _last_fez := -1
var _last_kaftan := -1
var _fez_key_t := 0.0
var scanner_screen: MeshInstance3D
## Elde tutulan: 0 = Telsiz-Kumanda, 1..5 = çantadaki eşya. Bölüm betiği item_handler ile
## bir eşya-karakter eşleşmesini kendisi işleyebilir (true dönerse genel tepki oynamaz).
var held := 0
var item_handler: Callable
## Serbest saat bölümlerinde tırmanma, kenardan çıkma, alçak engelin üstünden atlama (Traversal).
var can_climb := false
var traversal: Traversal
var _stagger := 0.0
var _nihat_refused := false
var _remote_model: Node3D
var _held_model: Node3D
var _item_busy := false
## Nihat'ın Büro donanımı (uçuş, görünmezlik): Nihat bölümleri enable_nihat_powers ile açar.
var powers: NihatPowers


func _ready() -> void:
	GameState.combat = {}
	add_to_group("player")      # yürüyen halk (Walker) oyuncunun içinden geçmesin diye onu bulur
	GameState.bag_changed.connect(_on_bag_changed)
	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.75
	shape.shape = cap
	shape.position.y = 0.875
	add_child(shape)
	collision_mask = 1

	camera = Camera3D.new()
	camera.position.y = eye_height
	camera.fov = float(GameState.settings.get("fov", 72.0))
	camera.near = 0.05
	add_child(camera)
	GameState.settings_changed.connect(func():
		if is_instance_valid(camera):
			camera.fov = float(GameState.settings.get("fov", 72.0)))
	camera.current = true

	_ray = RayCast3D.new()
	_ray.target_position = Vector3(0, 0, -2.4)
	_ray.collision_mask = 2
	_ray.collide_with_areas = false
	camera.add_child(_ray)
	_build_hand()
	_build_leg()
	# Görünen her arazi basılır: seviyelerin kendi arazilerinden çarpışması unutulanlar (Bölüm 33o'da yamaç yalnız
	# görüntüydü, iskeleden düşen haritanın altına iniyordu) burada kendiliğinden katılaşır
	_terrain_scan.call_deferred()
	if GameState.exitcheck and not get_tree().root.has_node("ExitCheck"):
		var ec: Node = load("res://tests/exit_check.gd").new()
		ec.name = "ExitCheck"
		get_tree().root.add_child.call_deferred(ec)


func _process(_delta: float) -> void:
	if hand_style != "tolga" or not outfit_enabled or GameState.autotest or GameState.shots_dir != "":
		return
	var fez := 1 if GameState.flags.get("fez", true) else 0
	var kaftan := 1 if GameState.flags.get("has_kaftan", false) else 0
	# Fes yalnızca oyuncu H'ye bastıysa (kovalamacada düşen fes kamerayı döndürmesin); kaftan her zaman
	if Input.is_action_just_pressed("fez"):
		_fez_key_t = 0.6
	_fez_key_t = maxf(0.0, _fez_key_t - _delta)
	if _last_fez >= 0 and ((fez != _last_fez and _fez_key_t > 0.0) or kaftan > _last_kaftan):
		_outfit_pending = true
	_last_fez = fez
	_last_kaftan = kaftan
	if _outfit_pending and not frozen and not _outfit_busy:
		_outfit_pending = false
		outfit_view()


func _unhandled_input(event: InputEvent) -> void:
	if _item_input(event):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("outfit") and not frozen and hand_style == "tolga" and not _outfit_busy:
		outfit_view(3.2)
		get_viewport().set_input_as_handled()
		return
	if frozen:
		# Konuşma sırasında yürünmez ama etrafa bakılır
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and _dialogue_look():
			var inv0 := -1.0 if GameState.settings.get("invert_y", false) else 1.0
			_yaw(-event.relative.x * MOUSE_SENS * float(GameState.settings["mouse"]))
			camera.rotation.x = clampf(camera.rotation.x - inv0 * event.relative.y * MOUSE_SENS * float(GameState.settings["mouse"]), deg_to_rad(-85), deg_to_rad(85))
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if combat and lock_target != null:
			return
		var inv := -1.0 if GameState.settings.get("invert_y", false) else 1.0
		_yaw(-event.relative.x * MOUSE_SENS * float(GameState.settings["mouse"]))
		camera.rotation.x = clampf(camera.rotation.x - inv * event.relative.y * MOUSE_SENS * float(GameState.settings["mouse"]), deg_to_rad(-85), deg_to_rad(85))
	elif event.is_action_pressed("interact") and focus_id != "":
		if powers:
			powers.before_interact(focus_id)
		hand_gesture("reach")
		if focus_id.begins_with("mg:"):
			_start_minigame(focus_id.trim_prefix("mg:"))
		elif focus_id.begins_with("npc:") or focus_id.begins_with("ev:"):
			SideEvents.interact(focus_id, get_tree().get_first_node_in_group("hud") as Hud)
		else:
			interacted.emit(focus_id)
		get_viewport().set_input_as_handled()


## Sahnedeki LowPoly arazilerinden çarpışmasız olanları katılaştırır (dünyanın WorldWalk'u kendi arazilerini zaten
## katılaştırır: onlar atlanır). Seviyeler oyuncudan sonra da kurulabildiği için birkaç saniyede bir yeniden bakılır.
func _terrain_scan() -> void:
	if not is_inside_tree():
		return
	if get_node_or_null("TerrainScan") == null:
		var tm := Timer.new()
		tm.name = "TerrainScan"
		tm.wait_time = 3.0
		tm.autostart = true
		tm.timeout.connect(_terrain_scan)
		add_child(tm)
	for n in get_tree().get_nodes_in_group("lp_terrain"):
		var mi := n as MeshInstance3D
		if mi == null or mi.has_meta("solid_terrain") or mi.has_meta("no_walk") or not mi.is_inside_tree():
			continue
		var has_body := false
		for c in mi.get_children():
			if c is StaticBody3D:
				has_body = true
		var in_world := false
		var a := mi.get_parent()
		while a != null and not in_world:
			if a.get_node_or_null("WorldWalk") != null:
				in_world = true
			a = a.get_parent()
		if has_body or in_world:
			mi.set_meta("solid_terrain", true)
			continue
		LowPoly.solid(mi)
		if GameState.autotest:
			print("TERRAIN_SOLIDIFIED scene=%s node=%s" % [get_tree().current_scene.scene_file_path.get_file() if get_tree().current_scene else "", mi.get_path()])


## Güvenlik ağı: harita dışına (boşluğa) düşen oyuncu son sağlam bastığı yere döner. Bölümlerin kasıtlı
## düşüşleri (denize düşme, lağıma ışınlama) etkilenmez: yalnız son zeminin 20 m altına hızla düşerken devreye girer.
var _safe_pos := Vector3.INF
## Haritadan düşme koruması (bölüm kendi düşüş mekaniğini yönetiyorsa kapatır: denize düşme, kayık)
var fall_guard := true
var _safe_t := 0.0
var _safe_hist: Array = []
## Haritadan düşüp güvenli yere geri konunca (bölüm isterse ceza/replik ekler)
signal fell_off


func _fall_guard(delta: float) -> void:
	if is_on_floor():
		_safe_t -= delta
		if _safe_t <= 0.0:
			_safe_t = 0.4
			_safe_pos = global_position + Vector3(0, 0.1, 0)
			# Son birkaç sağlam nokta: en sonuncunun altı gitmiş olabilir (düşen kalas, uzaklaşan kayık); bir öncekine dönülür
			if _safe_hist.is_empty() or (_safe_hist[-1] as Vector3).distance_to(_safe_pos) > 1.0:
				_safe_hist.append(_safe_pos)
				if _safe_hist.size() > 12:
					_safe_hist.pop_front()
		return
	if powers and (powers.flying or powers.landing):
		return
	if not fall_guard or _safe_pos == Vector3.INF or velocity.y > -8.0 or global_position.y > _safe_pos.y - 20.0:
		return
	# Altında hâlâ zemin olan en yeni güvenli nokta (kayık, gemi, düşen kalas gibi gitmiş olanlar atlanır).
	# Hiçbiri kalmamışsa düşüş sürer ama koruma vazgeçmez: yeni bir sağlam nokta görülünce yine çalışır.
	var space := get_world_3d().direct_space_state
	var back := Vector3.INF
	var cands: Array = [_safe_pos]
	for i in range(_safe_hist.size() - 1, -1, -1):
		cands.append(_safe_hist[i])
	for c: Vector3 in cands:
		var q := PhysicsRayQueryParameters3D.create(c + Vector3.UP * 0.3, c + Vector3.DOWN * 1.5)
		q.exclude = [get_rid()]
		var hit := space.intersect_ray(q)
		if not hit.is_empty() and not (hit["collider"] is Node and (hit["collider"] as Node).get_parent() is RigidBody3D):
			back = c
			break
	if back == Vector3.INF:
		return
	global_position = back
	velocity = Vector3.ZERO
	ladder = null
	fell_off.emit()
	print("FALL_GUARD scene=%s" % (get_tree().current_scene.scene_file_path.get_file() if get_tree().current_scene else ""))


## Konuşma/ara sahne sırasında (oyuncu donmuşken) altı boş bir yere ışınlanan oyuncu düşmesin: bölüm betiği
## yanlış bir noktaya koyduysa (rıhtımın dışı, arazinin kenarı) hikâye akarken boşluğa ya da suya düşülüyordu.
## Altında 60 m içinde zemin yoksa yerinde tutulur; testler WARN_VOID_TELEPORT ile yakalar.
func _frozen_void_hold() -> bool:
	# Yalnız ışınlamadan hemen sonra (bir karede 1.5 m'den fazla yer değiştirme): bölümlerin kasıtlı düşüşleri
	# (denize atlama, kayıktan düşme) zeminden başlar, ışınlama değildir
	if _last_pos.distance_to(global_position) > 1.5:
		_tp_hold = 1.5
		_unstick_in = 2      # yeni kurulan yerin çarpışması bir sonraki fizik karesinde gelir
	_last_pos = global_position
	if _unstick_in > 0:
		_unstick_in -= 1
		if _unstick_in == 0 and not frozen:
			_unstick()
	if _tp_hold <= 0.0:
		return false
	_tp_hold -= get_physics_process_delta_time()
	if not frozen or pinned or not fall_guard or not gravity_on or is_on_floor() or ladder != null:
		return false
	if powers and (powers.flying or powers.landing):
		return false
	# 60 m: gökten düşüş gibi kasıtlı ara sahne düşüşleri (altında zemin var) tutulmaz; yalnız gerçek boşluk (su, harita dışı)
	var q := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.2, global_position + Vector3.DOWN * 60.0)
	q.exclude = [get_rid()]
	if not get_world_3d().direct_space_state.intersect_ray(q).is_empty():
		_void_frames = 0
		return false
	# Aynı karede kurulan seviyenin çarpışması bir sonraki fizik karesinde gelir: kısa süreli boşluk uyarı sayılmaz
	_void_frames += 1
	if _void_frames > 6 and not _void_warned:
		_void_warned = true
		print("WARN_VOID_TELEPORT scene=%s pos=%s" % [get_tree().current_scene.scene_file_path.get_file() if get_tree().current_scene else "", global_position])
	velocity = Vector3.ZERO
	return true


var _void_warned := false
var _void_frames := 0
var _unstick_in := 0


## Işınlamadan (bölüm oyuncuyu bir yere koydu) ya da ara sahneden sonra gövde bir katının içindeyse en yakın boş yere
## alınır: çadırın, sandığın, duvarın içinde kalınmasın (Bölüm 24o'da fırtınada bir çadırın kenarının içinde
## başlanıyordu, hiçbir yöne gidilemiyordu). Birkaç santimlik sürtünme sayılmaz (yürüyünce çözülür); kürekte, suda,
## uçarken, merdivende ve tırmanırken yapılmaz. Yalnız ayağın altında zemin olan ve gövdenin sığdığı yere (en çok 3 m).
func _unstick() -> bool:
	if not is_inside_tree() or pinned or not gravity_on or move_mode != "walk" or ladder != null:
		return false
	if (powers and powers.flying) or (traversal and traversal.state != ""):
		return false
	var space := get_world_3d().direct_space_state
	var probe := CapsuleShape3D.new()
	probe.radius = 0.27
	probe.height = 1.7
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = probe
	q.collision_mask = collision_mask
	q.exclude = [get_rid()]
	var base := global_position
	q.transform = Transform3D(Basis(), base + Vector3(0, 0.9, 0))
	if space.intersect_shape(q, 1).is_empty():
		return false
	for r: float in [0.35, 0.7, 1.1, 1.6, 2.2, 3.0]:
		for k in 16:
			var a := TAU * k / 16.0
			var p := base + Vector3(sin(a), 0.0, cos(a)) * r
			var fh := space.intersect_ray(PhysicsRayQueryParameters3D.create(p + Vector3.UP * 0.6, p + Vector3.DOWN * 0.8, collision_mask, [get_rid()]))
			if fh.is_empty():
				continue
			var fp: Vector3 = fh["position"]
			q.transform = Transform3D(Basis(), fp + Vector3(0, 0.9, 0))
			if space.intersect_shape(q, 1).is_empty():
				global_position = fp + Vector3(0, 0.03, 0)
				velocity = Vector3.ZERO
				_last_pos = global_position
				return true
	return false
var _last_pos := Vector3.ZERO
var _tp_hold := 0.0


func _physics_process(delta: float) -> void:
	_health_tick(delta)
	_fall_guard(delta)
	if _frozen_void_hold():
		_after_move(delta)
		return
	if gravity_on and not is_on_floor():
		velocity.y -= _gravity * delta
	elif not gravity_on:
		velocity.y = 0.0
	if powers and powers.flying:
		powers.fly(delta)
		_after_move(delta)
		return
	if pinned:
		# Yerine sabit (kayıkta kürekte): yürümez, zıplamaz, ama etrafa bakar; konumu bölüm verir
		velocity = Vector3.ZERO
		_after_move(delta)
		return
	if can_climb and traversal and traversal.physics(delta):
		_after_move(delta)
		return
	if _ladder_physics(delta):
		_after_move(delta)
		return
	if move_mode == "script" and not frozen:
		velocity.x = script_velocity.x
		velocity.z = script_velocity.z
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP
		var was_floor := is_on_floor()
		move_and_slide()
		if was_floor:
			step_up(script_velocity, delta)
		if can_climb and traversal:
			traversal.after_walk(delta)
		_after_move(delta)
		return
	var dir := Vector3.ZERO
	if not frozen:
		var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		dir = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP
			if hand_style == "nihat" and not can_climb and not _nihat_refused:
				_nihat_wall()
	var speed := (RUN if Input.is_action_pressed("sprint") else WALK) * speed_mult * _wound_mult()
	if _stagger > 0.0:
		_stagger = maxf(0.0, _stagger - delta)
		speed *= lerpf(1.0, 0.3, clampf(_stagger / 0.5, 0.0, 1.0))
	velocity.x = move_toward(velocity.x, dir.x * speed, speed * delta * 10.0)
	velocity.z = move_toward(velocity.z, dir.z * speed, speed * delta * 10.0)
	var want := Vector3(velocity.x, 0.0, velocity.z)
	var on_floor := is_on_floor()
	move_and_slide()
	if on_floor and not frozen:
		step_up(want, delta)
	if not frozen and not pinned:
		_separate_from_persons()
	if can_climb and traversal:
		traversal.after_walk(delta)
	_after_move(delta)


## Alçak basamak (eşik, kaldırım, taş basamak, moloz, alçak sahanlık; en çok STEP_H) zıplamadan çıkılır. Önü kapanınca
## gövde basamak yüksekliği kadar kalkar, biraz ilerler ve basamağın üstüne iner; kamera yumuşakça yetişir. Üstte yer
## yoksa, yukarıda da önü kapalıysa (duvar) ya da basılan yüz yürünmeyecek kadar dikse bir şey yapmaz. (Eskiden yalnız
## ~9 cm'lik pürüz yürünüyordu: 15 cm'lik moloz basamağı ve 40 cm'lik kilise basamağı için her seferinde zıplamak
## gerekiyordu.) Tavuk boyunda (göz alçakken) basamak da oranla alçalır. Fizik denetiminin botu da bunu çağırır.
const STEP_H := 0.42
var _cam_dy := 0.0      # basamak çıkınca kameranın gövdeye göre geride kalan yüksekliği (sıfıra yumuşakça iner)


func step_up(want: Vector3, delta: float) -> bool:
	var sp := Vector2(want.x, want.z).length()
	if sp < 0.2 or velocity.y > 0.5:
		return false
	var blocked := false
	for i in get_slide_collision_count():
		var n := get_slide_collision(i).get_normal()
		if n.y < 0.7 and n.x * want.x + n.z * want.z < 0.0:
			blocked = true
			break
	if not blocked:
		return false
	var h := STEP_H * clampf(eye_height / EYE, 0.2, 1.0)
	var fwd := Vector3(want.x, 0.0, want.z) / sp * maxf(sp * delta, 0.12)
	var col := KinematicCollision3D.new()
	# Tam basamak boyu, sonra daha alçak kalkış: basamağın üstünde tavan varsa (alçak kapının eşiği) yüksek kalkışta
	# ileri gidilemez, alçakta gidilir
	for k: float in [1.0, 0.6, 0.35]:
		var xf := global_transform
		var lift := h * k
		if test_move(xf, Vector3.UP * lift, col):
			lift = col.get_travel().y - 0.01
			if lift < 0.06:
				continue
		xf.origin.y += lift
		if test_move(xf, fwd, col):
			continue
		xf.origin += fwd
		if not test_move(xf, Vector3.DOWN * (lift + 0.02), col):
			continue
		if col.get_normal().y < cos(floor_max_angle) + 0.01:
			continue
		var land := xf.origin + col.get_travel()
		var rise := land.y - global_position.y
		if rise < 0.04:
			continue
		# Uçurum kenarındaki alçak engelin (küpeşte, iskele kenarı, sur dişi arası) üstünden yürüyerek aşılmaz: basamağın
		# ötesinde (0,5 m) ayağın basacağı zemin yoksa çıkılmaz (zıplayarak yine aşılır)
		var ahead := land + fwd.normalized() * 0.5
		var rq := PhysicsRayQueryParameters3D.create(ahead + Vector3.UP * 0.5, ahead + Vector3.DOWN * 1.2, collision_mask, [get_rid()])
		if get_world_3d().direct_space_state.intersect_ray(rq).is_empty():
			return false
		global_position = land
		velocity = Vector3(want.x, 0.0, want.z)
		_cam_dy = maxf(_cam_dy - rise, -0.6)
		return true
	return false


## Kişilerin çarpışma gövdesi yok (kalabalıkta sıkışılmasın diye): yürürken birinin içine girilirse oyuncu yumuşakça
## dışarı itilir; itme duvarlara çarpar (move_and_collide), kimse oyuncuyu duvarın içine sokamaz.
const PERSON_R := 0.62
func _separate_from_persons() -> void:
	var here := global_position
	var push := Vector3.ZERO
	for n in get_tree().get_nodes_in_group("persons"):
		var o := n as Node3D
		if o == null or not o.is_visible_in_tree() or o.has_meta("no_block") or is_ancestor_of(o):
			continue
		var d := Vector3(here.x - o.global_position.x, 0, here.z - o.global_position.z)
		if absf(d.x) > PERSON_R or absf(d.z) > PERSON_R or absf(here.y - o.global_position.y) > 1.2:
			continue
		var dl := d.length()
		if dl >= PERSON_R:
			continue
		if dl < 0.001:
			d = -transform.basis.z
			dl = 0.001
		push += d / dl * (PERSON_R - dl)
	if push != Vector3.ZERO:
		move_and_collide(push.limit_length(0.12))


## Merdiven: alanında ileri basınca tutunur; W/S ile çıkar-iner, Space bırakır, tepede üste çıkar, dipte S ile iner.
func _ladder_physics(delta: float) -> bool:
	if frozen or pinned:
		if ladder:
			ladder = null
		return false
	var fwd_in := Input.get_axis("move_back", "move_forward")
	_ladder_cool = maxf(0.0, _ladder_cool - delta)
	if ladder == null:
		if fwd_in <= 0.3 or _ladder_cool > 0.0:
			return false
		for n in get_tree().get_nodes_in_group("ladder"):
			var l := n as Ladder
			if l == null or not l.is_visible_in_tree() or not l.has_body(self):
				continue
			# Merdivene dönük olmalı
			var look := -global_transform.basis.z
			if look.dot(-l.front_dir()) < 0.3:
				continue
			var rel := global_position - l.global_position
			# Tepede (merdivenden yeni çıkmış, surun üstünde): yeniden tutunup geri çekilmesin
			if rel.dot(l.up_dir()) > l.height - 1.0:
				continue
			ladder = l
			ladder_side = 0.0
			_ladder_t = clampf(rel.dot(l.up_dir()), 0.0, l.height - 0.5)
			velocity = Vector3.ZERO
			break
		if ladder == null:
			return false
	if Input.is_action_just_pressed("jump"):
		# Bırak: geriye küçük bir itiş
		velocity = ladder.front_dir() * 2.0 + Vector3.UP * 1.5
		ladder = null
		return false
	var spd := 2.2 * (1.5 if Input.is_action_pressed("sprint") else 1.0)
	_ladder_t += fwd_in * spd * delta
	if _ladder_t >= ladder.height - 0.2:
		# Tepede: yaslandığı yerin üstüne çık, biraz ileri adım at (merdivenin tutunma alanından çıksın)
		global_position = ladder.top_exit()
		var ahead := -ladder.front_dir()
		ahead.y = 0.0
		velocity = ahead.normalized() * 2.0
		ladder = null
		_ladder_cool = 0.8
		return true
	if _ladder_t <= 0.0 and fwd_in < 0.0:
		ladder = null
		return false
	_ladder_t = maxf(_ladder_t, 0.0)
	var side_in := Input.get_axis("move_left", "move_right")
	ladder_side = move_toward(ladder_side, side_in * 0.55, delta * 3.5)
	var right := ladder.global_transform.basis.x.normalized()
	global_position = ladder.point_at(_ladder_t) + ladder.front_dir() * 0.42 + right * ladder_side
	velocity = Vector3.ZERO
	_bob += delta * absf(fwd_in) * 6.0
	return true


## Serbest saat: tırmanma açılır. bounds: oyun alanı (XZ dikdörtgenleri); çatıdayken dışarı çıkılmaz.
func enable_climb(bounds: Array = []) -> void:
	can_climb = true
	if traversal == null:
		traversal = Traversal.new(self)
	traversal.bounds = bounds


func disable_climb() -> void:
	if traversal:
		traversal.cancel()
	can_climb = false


## Yüksekten düşünce kısa sendeleme: hız düşer, göz hizası bir an iner.
func stagger(seconds: float) -> void:
	_stagger = maxf(_stagger, seconds)
	if GameState.autotest or not is_inside_tree():
		return
	var tw := create_tween()
	tw.tween_property(self, "eye_height", EYE - 0.45, 0.12).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "eye_height", EYE, 0.5).set_trans(Tween.TRANS_SINE)


## Nihat duvara zıplarsa (tırmanma kapalı bölümlerde): bir kez yönetmelik repliği.
func _nihat_wall() -> void:
	var fwd := -global_transform.basis.z
	fwd.y = 0.0
	var from := global_position + Vector3.UP * 1.1
	var q := PhysicsRayQueryParameters3D.create(from, from + fwd.normalized() * 0.9, 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty() or absf((hit["normal"] as Vector3).y) > 0.4 or not Traversal.climbable(hit["collider"]):
		return
	var top := PhysicsRayQueryParameters3D.create(from + Vector3.UP * 1.4, from + Vector3.UP * 1.4 + fwd.normalized() * 0.9, 1, [get_rid()])
	if get_world_3d().direct_space_state.intersect_ray(top).is_empty():
		return   # alçak engel: yönetmelik buna bir şey demez
	_nihat_refused = true
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud and not hud.is_talking():
		hud.bark("SPK_NIHAT", "D_NIHAT_NO_CLIMB", 3.5)


## Kol: sağ çubukla bakış (fare hassasiyeti ayarı da uygulanır).
func _pad_look(delta: float) -> void:
	if (frozen and not _dialogue_look()) or (combat and lock_target != null):
		return
	var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look.length_squared() < 0.0001:
		return
	var sens := 2.6 * float(GameState.settings.get("pad_sens", 1.0)) * delta
	var inv := -1.0 if GameState.settings.get("invert_y", false) else 1.0
	_yaw(-look.x * sens * 1.2)
	camera.rotation.x = clampf(camera.rotation.x - inv * look.y * sens, deg_to_rad(-85), deg_to_rad(85))


## Oyuncu kilitliyken bakışa izin: bir replik ekrandayken, oyuncunun kamerası etkinken ve sahne bakışı kilitlememişse
## (look_lock: kamera yolu, sinematik çekim). Mini oyunlar ve nişan kendi fare hareketini kullanır; onlarda replik yoktur.
var look_lock := false

func _dialogue_look() -> bool:
	if look_lock or not camera.current:
		return false
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	return hud != null and hud.line_open and not hud._choice_box.visible


## Bakış (yatay): tırmanırken gövde duvara dönük kalır, yalnız kamera döner (±75°).
func _yaw(a: float) -> void:
	if traversal and traversal.state == "climb":
		camera.rotation.y = clampf(camera.rotation.y + a, -1.3, 1.3)
	else:
		rotate_y(a)


func _after_move(delta: float) -> void:
	_pad_look(delta)
	# Kafa sallanması ve sarsıntı
	var horiz := Vector2(velocity.x, velocity.z).length()
	var step_before := int(_bob * 2.0 / PI)
	# Adım sıklığı: yürürken saniyede ~2.6, koşarken ~4.3 adım (eskiden 4.5 / 7.3: şehirde "çın çın" diye koşturuyordu)
	_bob += delta * horiz * 1.3
	if int(_bob * 2.0 / PI) != step_before and is_on_floor() and horiz > 0.5:
		Audio.step(hand_style)
	var y := eye_height + sin(_bob * 2.0) * 0.03 * clampf(horiz / WALK, 0.0, 1.0)
	_cam_dy = lerpf(_cam_dy, 0.0, clampf(delta * 14.0, 0.0, 1.0))
	y += _cam_dy
	_shake = maxf(0.0, _shake - delta * 2.5)
	var roll := 0.0
	if floating:
		_float_t += delta
		y += sin(_float_t * 1.7) * 0.07
		roll = sin(_float_t * 1.1) * 0.035
	camera.rotation.z = lerpf(camera.rotation.z, roll, clampf(delta * 4.0, 0.0, 1.0))
	camera.position = Vector3(randf_range(-1, 1) * _shake * 0.05, y + randf_range(-1, 1) * _shake * 0.05, 0)

	_update_focus()
	if hand and hand.visible and _hand_shown and not (_hand_tween and _hand_tween.is_running()):
		var b := sin(_bob * 2.0) * 0.012 * clampf(horiz / WALK, 0.0, 1.0)
		hand.position = hand.position.lerp(_hand_base + Vector3(b * 0.5, b, 0), clampf(delta * 10.0, 0.0, 1.0))


## Koşu bölümü için zıplama (otomatik test de kullanır).
func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP


func _update_focus() -> void:
	var id := ""
	if not frozen and _ray.is_colliding():
		var c := _ray.get_collider()
		if c and c.has_meta("interact_id"):
			id = c.get_meta("interact_id")
	if id != focus_id:
		focus_id = id
		focus_changed.emit(id)
		if id.begins_with("mg:") or id.begins_with("npc:") or id.begins_with("ev:"):
			var hud := get_tree().get_first_node_in_group("hud") as Hud
			if hud:
				hud.set_prompt(tr("UI_PROMPT_MG_" + id.trim_prefix("mg:").to_upper()) if id.begins_with("mg:") else SideEvents.prompt(id))


func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


## Yaralanma: can düşer, ekran kenarı kızarır, darbe yönüne yatar. no_down: dövüşte yere düşmeyi Duel karar verir.
## Kılıç darbesi (no_down) rakibin zorluk ayarlı hasarıyla gelir; ok ve gülle burada zorlukla çarpılır.
func hurt(amount: float, from := Vector3.INF, no_down := false) -> void:
	if is_down or amount <= 0.0:
		return
	if not no_down:
		amount *= GameState.diff("hazard")
	hp = maxf(0.0, hp - amount)
	_hurt_t = 0.0
	hurt_taken.emit(amount)
	Fx.edge(Color("ff2a1a"), clampf(0.4 + amount / 80.0, 0.4, 0.9), 0.55)
	Fx.trauma(clampf(amount / 60.0, 0.2, 0.8))
	Audio.stinger("hurt", -4.0)
	if from != Vector3.INF and camera and float(GameState.settings.get("fx", 1.0)) > 0.0:
		var side := signf(global_transform.basis.x.dot(from - global_position))
		camera.rotation.z += deg_to_rad(5.0) * (side if side != 0.0 else 1.0)
	_show_hp()
	if hp <= 0.0 and not no_down:
		down()


## Yere düşme: ölüm yok. Kamera yere iner, ekran kararır, kalp atışı; 40 canla kalkılır. Bölüm `downed` ile ceza verir.
func down() -> void:
	if is_down:
		return
	is_down = true
	downs += 1
	GameState.combat_add("downs")
	hp = 0.0
	downed.emit()
	Audio.stinger("heart")
	var hud := get_tree().get_first_node_in_group("hud")
	if not GameState.autotest and is_inside_tree():
		var tw := create_tween()
		tw.tween_property(self, "eye_height", 0.45, 0.35).set_ease(Tween.EASE_IN)
	if hud and hud.has_method("fade_to"):
		await hud.fade_to(0.85, 0.5, Color(0.25, 0.0, 0.0))
	if hud and hud.has_method("bark"):
		hud.bark("SPK_NIHAT", "D_DOWNED_N_%d" % (1 + (downs - 1) % 3), 3.0)
	await get_tree().create_timer(1.2 if not GameState.autotest else 0.3).timeout
	if not is_inside_tree():
		return
	Audio.stinger("heart")
	if not GameState.autotest:
		var tw2 := create_tween()
		tw2.tween_property(self, "eye_height", EYE, 0.8).set_trans(Tween.TRANS_SINE)
	if hud and hud.has_method("fade_to"):
		await hud.fade_to(0.0, 0.8, Color(0.25, 0.0, 0.0))
	hp = 40.0
	_hurt_t = 0.0
	is_down = false
	_show_hp()


## Yerdeyken yürünmez; can 25'in altındayken ağır adım.
func _wound_mult() -> float:
	if is_down:
		return 0.0
	return 0.8 if hp < 25.0 else 1.0


## Can dolumu, düşük canda kalp atışı, can şeridi (yalnız can eksikken ve dövüş dışında görünür).
func _health_tick(delta: float) -> void:
	if is_down:
		return
	_hurt_t += delta
	if hp < MAX_HP and _hurt_t > 4.0 and not combat:
		hp = minf(MAX_HP, hp + 8.0 * GameState.diff("regen") * delta)
	if hp < 25.0:
		_heart_t -= delta
		if _heart_t <= 0.0:
			_heart_t = 1.3
			Audio.stinger("heart", -2.0)
	if _hp_layer:
		_hp_layer.visible = hp < MAX_HP - 0.5 and not combat
		_hp_bar.size.x = 220.0 * hp / MAX_HP
		_hp_bar.color = Color("d84a3a") if hp >= 25.0 else Color("ff2a1a").lerp(Color("ff8a6a"), 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.012))


func _show_hp() -> void:
	if _hp_layer == null:
		_hp_layer = CanvasLayer.new()
		_hp_layer.layer = 9
		add_child(_hp_layer)
		_hp_back = ColorRect.new()
		_hp_back.color = Color(0, 0, 0, 0.45)
		_hp_back.position = Vector2(22, 0)
		_hp_back.size = Vector2(224, 10)
		_hp_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_hp_layer.add_child(_hp_back)
		_hp_bar = ColorRect.new()
		_hp_bar.position = Vector2(24, 0)
		_hp_bar.size = Vector2(220, 6)
		_hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_hp_layer.add_child(_hp_bar)
	var vh := get_viewport().get_visible_rect().size.y
	_hp_back.position.y = vh - 40.0
	_hp_bar.position.y = vh - 38.0


## Nihat'ın Büro donanımını açar (Bölüm 3'te depodan sonra, 7 ve 11'de baştan). Döner: donanım düğümü.
func enable_nihat_powers(chapter: int) -> NihatPowers:
	if powers == null:
		powers = NihatPowers.new()
		powers.chapter = chapter
		add_child(powers)
	return powers


## Oyuncuyu bir noktaya bakacak şekilde çevirir (ara sahneler için).
func face(point: Vector3) -> void:
	var to := point - global_position
	rotation.y = atan2(-to.x, -to.z)
	var flat := Vector2(to.x, to.z).length()
	camera.rotation.x = atan2(to.y - eye_height, flat)


# ---------------------------------------------------------------- el ve Telsiz-Kumanda

## Birinci şahıs el: redingot kolu, el ve koli bandıyla birleştirilmiş telsiz + TV kumandası.
func _build_hand() -> void:
	hand = Node3D.new()
	hand.position = _hand_base + Vector3(0, -0.4, 0)
	hand.rotation_degrees = Vector3(12, -14, 0)
	hand.visible = false
	camera.add_child(hand)
	if hand_style == "nihat":
		_build_scanner()
		return
	# Redingot kolu ve beyaz manşet
	var hikmet := hand_style == "hikmet"
	Props.cyl(hand, 0.05, 0.16, Vector3(0.03, -0.07, 0.1), Color("5b7fb3") if hikmet else Color("2b2f38"), Vector3(90, 0, 0), 8)
	Props.cyl(hand, 0.047, 0.03, Vector3(0.03, -0.065, 0.02), Color("a9c1e3") if hikmet else Color("f4f1ea"), Vector3(90, 0, 0), 8)
	if hikmet:
		Props.cyl(hand, 0.051, 0.02, Vector3(0.03, -0.068, 0.12), Color("a9c1e3"), Vector3(90, 0, 0), 8)
	# El
	Props.ball(hand, 0.05, Vector3(0.02, -0.05, -0.02), Color("e0a57e") if hikmet else Color("e6ad88"), Vector3(1.1, 0.8, 1.2), 8)
	_remote_model = Node3D.new()
	hand.add_child(_remote_model)
	# TV kumandası (üstte) ve telsiz (altta)
	Props.box(_remote_model, Vector3(0.05, 0.022, 0.15), Vector3(0, -0.012, -0.07), Color("1f2229"))
	Props.box(_remote_model, Vector3(0.058, 0.035, 0.1), Vector3(0, -0.04, -0.06), Color("7d8794"))
	Props.cyl(_remote_model, 0.005, 0.12, Vector3(0.018, -0.02, -0.12), Color("2b2f3a"), Vector3(-60, 0, 0), 4)
	# Koli bandı
	Props.box(_remote_model, Vector3(0.064, 0.064, 0.022), Vector3(0, -0.026, -0.05), Color("c98a3a"))
	Props.box(_remote_model, Vector3(0.064, 0.064, 0.022), Vector3(0, -0.026, -0.1), Color("c98a3a"), Vector3(0, 0, 4))
	# Tuşlar ve kırmızı düğme
	for i in 3:
		Props.box(_remote_model, Vector3(0.008, 0.004, 0.008), Vector3(-0.012 + i * 0.012, 0.0, -0.035), Color("9aa0a8"))
	_red_light = Props.cyl(_remote_model, 0.011, 0.008, Vector3(0, 0.001, -0.125), Color("ff3b30"), Vector3.ZERO, 8, -1.0, 1.5)
	# Başparmak
	_thumb = Node3D.new()
	_thumb.position = Vector3(-0.028, 0.012, -0.02)
	hand.add_child(_thumb)
	Props.cyl(_thumb, 0.012, 0.07, Vector3(0.012, 0, -0.035), Color("e6ad88"), Vector3(90, -20, 0), 6)
	Props.strip_outlines(hand)


## Nihat'ın eli: gri takım elbise kolu ve Büro'nun pirinç Paradoks Tarayıcısı (yeşil ekran, anten).
func _build_scanner() -> void:
	Props.cyl(hand, 0.05, 0.16, Vector3(0.03, -0.07, 0.1), Color("4a4a52"), Vector3(90, 0, 0), 8)
	Props.cyl(hand, 0.047, 0.03, Vector3(0.03, -0.065, 0.02), Color("f4f1ea"), Vector3(90, 0, 0), 8)
	Props.ball(hand, 0.05, Vector3(0.02, -0.05, -0.02), Color("ecb892"), Vector3(1.1, 0.8, 1.2), 8)
	Props.box(hand, Vector3(0.09, 0.05, 0.13), Vector3(0, -0.02, -0.08), Color("a8864a"))
	Props.box(hand, Vector3(0.094, 0.012, 0.135), Vector3(0, 0.004, -0.08), Color("6a5230"))
	scanner_screen = Props.box(hand, Vector3(0.066, 0.004, 0.06), Vector3(0, 0.012, -0.095), Color("3aff9a"), Vector3.ZERO, 1.2)
	for i in 3:
		Props.cyl(hand, 0.007, 0.006, Vector3(-0.025 + i * 0.025, 0.012, -0.04), Color("d8b070"), Vector3.ZERO, 6)
	Props.cyl(hand, 0.004, 0.14, Vector3(0.035, 0.05, -0.13), Color("2b2f3a"), Vector3(-25, 0, 0), 4)
	Props.ball(hand, 0.01, Vector3(0.035, 0.115, -0.16), Color("ff5a4a"), Vector3.ONE, 5, 1.5)
	Props.label(hand, "Z", Vector3(0, -0.02, -0.0145 - 0.0005), 24, Color("4a3a1e"), Vector3(0, 0, 0), 0.04)
	_thumb = Node3D.new()
	_thumb.position = Vector3(-0.03, 0.012, -0.02)
	hand.add_child(_thumb)
	Props.cyl(_thumb, 0.012, 0.07, Vector3(0.012, 0, -0.035), Color("ecb892"), Vector3(90, -20, 0), 6)
	_red_light = Props.cyl(hand, 0.001, 0.001, Vector3(0, -0.05, 0), Color("000000"))
	Props.strip_outlines(hand)


## Tarayıcı ekranı: 0 (iz yok, sönük) .. 1 (iz çok yakın, parlak ve kırmızıya döner).
func set_scanner(v: float) -> void:
	if scanner_screen == null:
		return
	var c := Color("3aff9a").lerp(Color("ff5a4a"), clampf(v, 0.0, 1.0))
	var pulse := 0.6 + v * 3.0 * (0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * (3.0 + v * 14.0)))
	scanner_screen.material_override = Props.mat(c, pulse, false, "", false)


func show_remote(on: bool) -> void:
	if on == _hand_shown:
		return
	_hand_shown = on
	if on and hand_style == "tolga":
		(func():
			var hud := get_tree().get_first_node_in_group("hud") as Hud
			if hud:
				hud.set_held(held, held_item())).call_deferred()
	hand.visible = true
	hand.position = _hand_base + (Vector3(0, -0.4, 0) if on else Vector3.ZERO)
	var tw := create_tween()
	_hand_tween = tw
	tw.tween_property(hand, "position", _hand_base + (Vector3.ZERO if on else Vector3(0, -0.4, 0)), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if not on:
		tw.tween_callback(func(): hand.visible = false)


## Kırmızı düğmeye basılı tutma (0..1): başparmak iner, düğme parlar, el titrer.
func press_red(v: float) -> void:
	if _thumb == null:
		return
	if v > 0.0 and (held != 0 or hands_free):
		select_item(0)
	_thumb.rotation_degrees.x = -lerpf(0.0, 18.0, clampf(v * 4.0, 0.0, 1.0))
	_red_light.material_override = Props.mat(Color("ff3b30"), 1.5 + v * 6.0, false, "", false)
	if v > 0.0:
		hand.position += Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * 0.002 * v


# ---------------------------------------------------------------- tekme

## Birinci şahıs bacak: redingot pantolonu ve rugan ayakkabı. Tekme anında aşağıdan görüşe girer.
func _build_leg() -> void:
	leg = Node3D.new()
	leg.visible = false
	camera.add_child(leg)
	# Kalçadan dizine, dizden ayağa (kalça kameranın altında ve biraz sağında)
	Props.cyl(leg, 0.085, 0.55, Vector3(0, -0.275, 0), Color("454b59"), Vector3.ZERO, 8)
	Props.cyl(leg, 0.078, 0.5, Vector3(0, -0.78, 0), Color("454b59"), Vector3.ZERO, 8)
	Props.cyl(leg, 0.08, 0.06, Vector3(0, -1.02, 0), Color("f1ede2"), Vector3.ZERO, 8)
	Props.box(leg, Vector3(0.15, 0.12, 0.36), Vector3(0, -1.1, -0.1), Color("1d2027"))
	Props.box(leg, Vector3(0.152, 0.035, 0.37), Vector3(0, -1.16, -0.1), Color("7a4f33"))
	Props.box(leg, Vector3(0.1, 0.02, 0.12), Vector3(0, -1.04, -0.2), Color("30343d"))
	Props.strip_outlines(leg)


## Tekme: bacak aşağıdan öne savrulur, oyuncu hedefe doğru atılır. power 0..1:
## güçlü tekmede savrulma daha geniş ve sert. Darbe anında on_hit çağrılır.
func kick(target: Vector3, power: float, on_hit: Callable) -> void:
	var start := global_position
	var to := target - start
	to.y = 0.0
	# Ayak (~1.1 m önde) hedefin yüzeyinde dursun, içine girmesin
	var lunge := start + to.normalized() * maxf(0.0, to.length() - 1.62 + power * 0.06)
	leg.visible = true
	leg.position = Vector3(0.12, -0.3, 0.15)
	leg.rotation_degrees = Vector3(5, 0, 0)
	var swing := lerpf(82.0, 105.0, power)
	var dur := lerpf(0.2, 0.12, power)
	var tw := create_tween()
	tw.tween_property(leg, "rotation_degrees:x", -15.0, 0.14).set_ease(Tween.EASE_OUT)
	tw.tween_property(leg, "rotation_degrees:x", swing, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(leg, "position", Vector3(0.03, -0.2, -0.05), dur)
	tw.parallel().tween_property(self, "global_position", lunge, dur)
	tw.tween_callback(func():
		shake(0.3 + power)
		on_hit.call())
	tw.tween_interval(0.18)
	tw.tween_property(leg, "rotation_degrees:x", 5.0, 0.3).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(leg, "position", Vector3(0.12, -0.3, 0.15), 0.3)
	tw.parallel().tween_property(self, "global_position", start, 0.45).set_trans(Tween.TRANS_QUAD)
	await tw.finished
	leg.visible = false


## Tolga'nın kendine dışarıdan bakışı: yanına bir ikiz koyar, kamera önünde yay çizer, sonra geri döner.
func outfit_view(seconds := 2.6) -> void:
	if _outfit_busy or not is_inside_tree():
		return
	_outfit_busy = true
	var was_frozen := frozen
	frozen = true
	var me := _me_person()
	get_parent().add_child(me)
	me.global_position = global_position
	me.rotation.y = rotation.y + PI
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud:
		hud.set_cinematic(true)
	var cam := Camera3D.new()
	get_parent().add_child(cam)
	cam.fov = 55.0
	cam.make_current()
	var fwd := -global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var center := global_position + Vector3(0, 1.15, 0)
	# Kamera duvarın dışına çıkmasın: en açık yönü seç, mesafeyi ona göre kısalt
	var best := -1.0
	var best_dir := fwd
	for k in 8:
		var d := fwd.rotated(Vector3.UP, k * PI / 4.0)
		var clear := 99.0
		for a in [-0.8, 0.0, 0.8]:
			clear = minf(clear, _clearance(center + Vector3(0, 0.3, 0), d.rotated(Vector3.UP, a), 2.8))
		if clear > best + 0.05:
			best = clear
			best_dir = d
		if k == 0 and clear >= 2.6:
			break
	fwd = best_dir
	var dist := clampf(best - 0.35, 0.9, 2.3)
	var tw := create_tween()
	tw.tween_method(func(a: float):
		var dir := fwd.rotated(Vector3.UP, a)
		cam.global_position = center + dir * dist + Vector3(0, 0.3, 0)
		cam.look_at(center + Vector3(0, 0.2, 0), Vector3.UP), -0.8, 0.8, seconds)
	await tw.finished
	camera.make_current()
	cam.queue_free()
	me.queue_free()
	if hud:
		hud.set_cinematic(false)
	frozen = was_frozen
	_outfit_busy = false


func _clearance(from: Vector3, dir: Vector3, max_d: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(from, from + dir * max_d, 1)
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	return from.distance_to(hit["position"]) if hit else max_d


## Tolga şu an fesli mi (HUD'daki fes; HUD yoksa bayrak)
func wears_fez() -> bool:
	var hud: Hud = get_tree().get_first_node_in_group("hud") as Hud if is_inside_tree() else null
	return hud.tolga_wears_fez() if hud else bool(GameState.flags.get("fez", true))


## Oynanan karakterin üçüncü şahıs modeli (ayna, fotoğraf modu): Nihat, Hikmet ya da Tolga (kıyafet ve fes duruma göre).
## fez: -1 o anki hâli (wears_fez), 0/1 fotoğraf modunda oyuncunun seçtiği.
func _me_person(fez := -1) -> Person:
	if hand_style == "nihat":
		return Person.new({"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true,
			"hair": Color("3a2a1e"), "skin": Color("ecb892")})
	if hand_style == "hikmet":
		return Person.new({"face": {"wrinkles": true, "bags": true, "nose": "bulb", "brow_tilt": -6.0}, "coat": Color("7fa7d6"),
			"pants": Color("7fa7d6"), "glasses": true, "mustache": true, "hair": Color("e8e8e4"), "skin": Color("e0a57e")})
	var f := GameState.flags
	var kaftan: bool = f.get("has_kaftan", false)
	var opts := {"face": "tolga", "coat": Color("7a3a2a") if kaftan else Color("23262d"), "pants": Color("23262d"), "skin": Color("e6ad88"),
		"hat": "fez" if (wears_fez() if fez < 0 else fez == 1) else "none", "hair": Color("2a1e14")}
	if kaftan:
		opts["robe"] = Color("8a3a2a")
	return Person.new(opts)


## Kimlik kartı: Nihat, Zaman Bürosu kartını kameraya doğru uzatır, bir süre tutar, geri çeker.
func show_badge(hold := 2.6) -> void:
	var card := Node3D.new()
	camera.add_child(card)
	card.position = Vector3(0.08, -0.5, -0.42)
	card.rotation_degrees = Vector3(-10, 10, 5)
	Props.box(card, Vector3(0.21, 0.14, 0.012), Vector3.ZERO, Color("4a3020"))
	Props.box(card, Vector3(0.19, 0.12, 0.004), Vector3(0, 0, 0.007), Color("f2ead8"))
	Props.box(card, Vector3(0.19, 0.024, 0.005), Vector3(0, 0.048, 0.008), Color("2a4a8a"))
	# Vesikalık: gri zemin, yüz, fötr
	Props.box(card, Vector3(0.05, 0.06, 0.003), Vector3(-0.062, -0.012, 0.0095), Color("9aa4b4"))
	Props.ball(card, 0.013, Vector3(-0.062, -0.018, 0.011), Color("ecb892"), Vector3(1, 1.1, 0.4), 8)
	Props.box(card, Vector3(0.036, 0.008, 0.003), Vector3(-0.062, -0.002, 0.012), Color("3a3a42"))
	Props.box(card, Vector3(0.022, 0.012, 0.003), Vector3(-0.062, 0.006, 0.012), Color("3a3a42"))
	Props.box(card, Vector3(0.012, 0.003, 0.002), Vector3(-0.062, -0.024, 0.013), Color("3a2a1e"))
	# Altın mühür
	Props.cyl(card, 0.014, 0.003, Vector3(0.078, -0.036, 0.009), Color("d8b040"), Vector3(90, 0, 0), 12)
	# Yazılar kimliğin içine sığdırılır (max_width; vesikalığın sağındaki alan ~0.12 m)
	for spec in [["ZAMAN BÜROSU", Vector3(0, 0.048, 0.0112), Color("f2ead8"), 0.12], ["N. ZAMANOĞLU", Vector3(0.025, 0.012, 0.0102), Color("2a2a30"), 0.11],
			["DENETÇİ · SİCİL 1453", Vector3(0.025, -0.008, 0.0102), Color("5a5a64"), 0.1]]:
		Props.label(card, spec[0], spec[1], 32, spec[2], Vector3.ZERO, spec[3])
	Props.strip_outlines(card)
	Audio.sfx("paper_tear", -18.0, 1.6)
	var tw := create_tween()
	tw.tween_property(card, "position", Vector3(0.02, -0.04, -0.34), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(card, "rotation_degrees", Vector3(0, -4, 1), 0.35)
	tw.tween_interval(hold)
	tw.tween_property(card, "position", Vector3(0.08, -0.55, -0.42), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(card.queue_free)


## Elde bir eşya göster (kameraya uzatılır, bekler, geri çekilir): replikte geçen eşya gerçekten görünsün.
## kind: "badge" (Büro kimliği), "card" (kartvizit), "book" (tarih kitabı, 29 Mayıs sayfası),
## "letter" (mühürlü mektup), "cube" (Rubik küpü), "pole" (selfie çubuğu), "tea" (ince belli bardakta çay; yudumlanır),
## ya da başka bir çanta eşyası (Items.IDS: kendi modeli).
func show_prop(kind: String, hold := 2.4) -> void:
	if kind == "badge":
		show_badge(hold)
		return
	if not is_inside_tree() or camera == null:
		return
	var item := Node3D.new()
	camera.add_child(item)
	item.position = Vector3(0.08, -0.5, -0.42)
	item.rotation_degrees = Vector3(-10, 10, 5)
	var target := Vector3(0.02, -0.05, -0.36)
	match kind:
		"card":
			Props.box(item, Vector3(0.09, 0.055, 0.003), Vector3.ZERO, Color("f7f3ea"))
			Props.box(item, Vector3(0.09, 0.008, 0.0035), Vector3(0, 0.021, 0.0005), Color("2a4a8a"))
			# Yazılar kartın içine sığdırılır (max_width): yazı tipi çözünürlüğü iki katına çıkınca taşıyordu
			for spec in [["N. ZAMANOĞLU", Vector3(0, 0.004, 0.002), Color("2a2a30"), 0.072],
					["Denetçi · Zaman Bürosu", Vector3(0, -0.01, 0.002), Color("5a5a64"), 0.066],
					["Tel: —", Vector3(0, -0.021, 0.002), Color("8a8a94"), 0.022]]:
				Props.label(item, spec[0], spec[1], 32, spec[2], Vector3.ZERO, spec[3])
			target = Vector3(0.0, -0.035, -0.22)
		"book":
			for sx in [-1, 1]:
				Props.box(item, Vector3(0.1, 0.14, 0.006), Vector3(sx * 0.051, 0, 0), Color("f2ead8"), Vector3(0, -sx * 8, 0))
				for k in 6:
					Props.box(item, Vector3(0.075, 0.003, 0.001), Vector3(sx * 0.051, 0.03 - k * 0.012, 0.0045), Color("8a8a8a"))
			Props.box(item, Vector3(0.21, 0.15, 0.004), Vector3(0, 0, -0.004), Color("8a2b22"))
			Props.label(item, "29 MAYIS\n1453", Vector3(0.051, 0.05, 0.005), 32, Color("8a2b22"), Vector3.ZERO, 0.07)
			target = Vector3(0.0, -0.04, -0.3)
		"letter":
			Props.box(item, Vector3(0.14, 0.09, 0.004), Vector3.ZERO, Color("efe2c4"))
			Props.cyl(item, 0.014, 0.004, Vector3(0, -0.01, 0.003), Color("a8182a"), Vector3(90, 0, 0), 12)
			target = Vector3(0.0, -0.05, -0.3)
		"cube":
			var cols := [Color("c8323a"), Color("2f5fa8"), Color("3a8a4a"), Color("f2d040"), Color("f4f1ea"), Color("e8803a")]
			Props.box(item, Vector3(0.06, 0.06, 0.06), Vector3.ZERO, Color("1a1a1a"))
			for i in 9:
				Props.box(item, Vector3(0.017, 0.017, 0.002), Vector3(-0.02 + (i % 3) * 0.02, -0.02 + (i / 3) * 0.02, 0.031), cols[(i * 5) % 6])
			target = Vector3(0.0, -0.04, -0.25)
		"pole":
			Props.cyl(item, 0.008, 1.1, Vector3.ZERO, Color("8a8f99"), Vector3(0, 0, 90), 6)
			target = Vector3(0.0, -0.18, -0.45)
		"tea":
			var g := Node3D.new()
			item.add_child(g)
			Props.cyl(g, 0.045, 0.006, Vector3(0, -0.045, 0), Color("e8e0d0"), Vector3.ZERO, 14)
			Props.cyl(g, 0.02, 0.07, Vector3(0, -0.007, 0), Color("9a2a14"), Vector3.ZERO, 10, 0.016)
			var glass := Props.cyl(g, 0.023, 0.085, Vector3(0, 0.0, 0), Color(1, 1, 1, 0.25), Vector3.ZERO, 12, 0.018)
			glass.material_override = Props.mat(Color(0.9, 0.95, 1.0, 0.25), 0.0, true, "", false)
			item.rotation_degrees = Vector3(0, 0, 0)
			target = Vector3(0.05, -0.1, -0.3)
		_:
			# Çantadaki bir eşya (geri verilen çakmak gibi): kendi modeli, ele sığacak boyda. Cepteki kâğıtlar (izin,
			# tezkire) okunacak kadar büyük ve yakın tutulur
			if kind in Items.IDS or kind in Items.POCKET_IDS:
				var paper := kind in ["guest_pass", "tezkire"]
				var m := Items.build(kind)
				item.add_child(m)
				m.scale = Vector3.ONE * (0.5 if paper else 0.45)
				m.position = Vector3(0, -0.05 if paper else -0.04, 0)
				target = Vector3(0.07, -0.07, -0.3) if paper else Vector3(0.0, -0.06, -0.3)      # kâğıt sağ altta: konuşan görünür kalır
	Props.strip_outlines(item)
	Audio.sfx("paper_tear" if kind != "tea" else "land_pot", -18.0, 1.6)
	var tw := create_tween()
	tw.tween_property(item, "position", target, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(item, "rotation_degrees", Vector3(0, -4, 1) if kind != "tea" else Vector3.ZERO, 0.35)
	if kind == "tea":
		# Bir yudum: bardak ağıza doğru kalkar
		tw.tween_interval(hold * 0.4)
		tw.tween_property(item, "position", Vector3(0.0, -0.03, -0.16), 0.5).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(item, "rotation_degrees", Vector3(35, 0, 0), 0.5)
		tw.tween_callback(Audio.sfx.bind("tea_sip", -12.0, 1.0))
		tw.tween_interval(0.5)
		tw.tween_property(item, "position", target, 0.4)
		tw.parallel().tween_property(item, "rotation_degrees", Vector3.ZERO, 0.4)
		tw.tween_interval(hold * 0.3)
	else:
		tw.tween_interval(hold)
	tw.tween_property(item, "position", Vector3(0.08, -0.55, -0.42), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(item.queue_free)


## Selfie: Tolga arkasını döner, kamera kol mesafesinde; bakılan kişi Tolga'nın omzunun üstünden görünür.
func selfie_shot(hud: Hud, who: String) -> void:
	if _outfit_busy or not is_inside_tree() or GameState.autotest:
		return
	_outfit_busy = true
	var was_frozen := frozen
	frozen = true
	var fwd := -global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var side := fwd.cross(Vector3.UP).normalized()
	var me := _me_person()
	get_parent().add_child(me)
	me.global_position = global_position
	me.rotation.y = rotation.y
	# Selfie çubuğu: omuzdan kameraya uzanan ince çubuk
	var stick := Props.cyl(me, 0.015, 0.8, Vector3(0.3, 1.35, 0.35), Color("8a8f99"), Vector3(55, 0, 0), 5)
	stick.name = "SelfieStick"
	hud.set_cinematic(true)
	var cam := Camera3D.new()
	get_parent().add_child(cam)
	cam.fov = 62.0
	cam.global_position = global_position - fwd * 1.5 + side * 0.65 + Vector3(0, 1.75, 0)
	cam.look_at(global_position + fwd * 1.4 + side * 0.1 + Vector3(0, 1.4, 0), Vector3.UP)
	me.look_at_from_position(me.global_position, cam.global_position * Vector3(1, 0, 1) + Vector3(0, me.global_position.y, 0), Vector3.UP)
	me.rotate_y(PI)   # Person +Z'ye bakar
	cam.make_current()
	var pose := Person.nearest(get_tree(), global_position + fwd * 1.8 + Vector3(0, 1.0, 0), 3.0, me)
	if pose:
		pose.emote(["wave", "cheer"][randi() % 2])
	await get_tree().create_timer(0.35).timeout
	await hud.snap_photo(who)
	await get_tree().create_timer(0.5).timeout
	camera.make_current()
	cam.queue_free()
	me.queue_free()
	hud.set_cinematic(false)
	frozen = was_frozen
	_outfit_busy = false


# ---------------------------------------------------------------- elde eşya

## Eldeki eşyayı değiştirir: 0 = Telsiz-Kumanda, 1..5 = çanta sırası.
func select_item(i: int) -> void:
	if hand_style != "tolga" or _remote_model == null:
		return
	var n := GameState.bag.size()
	held = clampi(i, 0, n)
	hands_free = false
	var swap := func():
		if _held_model:
			_held_model.queue_free()
			_held_model = null
		_remote_model.visible = held == 0
		_held_id = ""
		if held > 0:
			var id: String = GameState.bag[held - 1]
			_held_id = id
			_held_model = Items.build(id)
			var g: Array = HOLD.get(id, [Vector3(0, -0.05, -0.07), Vector3.ZERO, 0.3])
			_held_model.position = g[0]
			_held_model.rotation_degrees = g[1]
			_held_model.scale = Vector3.ONE * float(g[2])
			hand.add_child(_held_model)
			Props.strip_outlines(_held_model)
	# Eşya değişirken el aşağı iner, yenisini alıp kalkar (anında belirmesin)
	if _hand_shown and hand.visible and not GameState.autotest and is_inside_tree():
		if _hand_tween and _hand_tween.is_running():
			_hand_tween.kill()
		_hand_tween = create_tween()
		_hand_tween.tween_property(hand, "position", _hand_base + Vector3(0.02, -0.32, 0.05), 0.12).set_ease(Tween.EASE_IN)
		_hand_tween.tween_callback(swap)
		_hand_tween.tween_property(hand, "position", _hand_base, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		swap.call()
	if not _hand_shown:
		show_remote(true)
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud:
		hud.set_held(held, held_item())
	Audio.sfx("ui_select", -14.0)


## Eşyaya göre tutuş (el düğümüne göre konum, açı, ölçek): telefon ekranı bakana dönük, çakmak parmak arasında,
## termos ve kolonya dik, bant rulosu dik, selfie çubuğu ileri ve biraz yukarı, küp avuçta.
const HOLD := {
	"phone": [Vector3(0.0, 0.0, -0.08), Vector3(62, 0, 0), 0.46],
	"lighter": [Vector3(0.0, -0.03, -0.065), Vector3(0, 20, -8), 0.46],
	"book": [Vector3(0.0, -0.005, -0.1), Vector3(55, 0, 0), 0.34],
	"chickpeas": [Vector3(0.0, -0.035, -0.075), Vector3(0, 20, 0), 0.38],
	"powerbank": [Vector3(0.0, -0.005, -0.085), Vector3(45, 0, 0), 0.42],
	"tape": [Vector3(0.0, -0.01, -0.085), Vector3(80, 0, 0), 0.38],
	"thermos": [Vector3(0.0, -0.08, -0.075), Vector3(0, 0, -6), 0.3],
	"selfie": [Vector3(0.0, -0.01, -0.05), Vector3(30, 90, 0), 0.34],
	"cologne": [Vector3(0.0, -0.055, -0.075), Vector3(0, 0, -6), 0.38],
	"cube": [Vector3(0.0, -0.03, -0.085), Vector3(20, 35, 0), 0.34],
}


func held_item() -> String:
	return "" if held <= 0 or held > GameState.bag.size() else String(GameState.bag[held - 1])


## Çanta değişti (bitti, verildi, kazanıldı): eldeki eşya gittiyse kumandaya dönülür, başka biri çıktıysa sıra kayar.
var _held_id := ""


func _on_bag_changed(_item: String, event: String, _use: String) -> void:
	if event in ["spend", "use"] or hand_style != "tolga" or _remote_model == null:
		return
	if _held_id == "" or held <= 0:
		return
	if not _held_id in GameState.bag:
		select_item(0)
		return
	held = GameState.bag.find(_held_id) + 1
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud:
		hud.set_held(held, held_item())


func _item_input(event: InputEvent) -> bool:
	if hand_style != "tolga" or frozen or _outfit_busy or combat:
		return false
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud and hud.is_bag_open():
		return false
	var n := GameState.bag.size()
	if event.is_action_pressed("item_next"):
		select_item((held + 1) % (n + 1))
		return true
	if event.is_action_pressed("item_prev"):
		select_item((held + n) % (n + 1))
		return true
	for k in range(1, 6):
		if event.is_action_pressed("choice_%d" % k) and k <= n:
			select_item(k if held != k else 0)
			return true
	if event.is_action_pressed("use_item"):
		_use_held()
		return true
	if event.is_action_pressed("hands_free"):
		toggle_hands_free()
		return true
	return false


## Eli boşalt: eldeki eşya (ya da kumanda) cebe girer, el iner. Yeniden basınca (ya da bir eşya seçilince) kumanda
## elde geri gelir. Bölümün sakladığı el (ara sahne) bununla açılmaz.
var hands_free := false


func toggle_hands_free() -> void:
	if hand_style != "tolga":
		return
	if _hand_shown:
		hands_free = true
		if held != 0:
			held = 0
			if _held_model:
				_held_model.queue_free()
				_held_model = null
			_remote_model.visible = true
		show_remote(false)
		Audio.sfx("ui_select", -16.0, 0.8)
		var hud := get_tree().get_first_node_in_group("hud") as Hud
		if hud:
			hud.set_held(-1, "")
	elif hands_free:
		hands_free = false
		show_remote(true)


## Eldekini kullan: bir kişiye bakılıyorsa gösterilir, yoksa eşyanın kendi eylemi.
func _use_held() -> void:
	if _item_busy:
		return
	var item := held_item()
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if item == "":
		if hud:
			hud.bark("SPK_TOLGA", "ITEM_SELF_REMOTE", 2.5)
		return
	_item_busy = true
	var target := focus_id
	if target != "":
		hand_gesture("show")
	item_used.emit(target, item)
	# Karşıdaki karakter tepki verir (şaşırır, güler, omuz silker...)
	if target != "" and item != "selfie" and _ray.is_colliding():
		var who := Person.nearest(get_tree(), _ray.get_collision_point())
		if who:
			who.emote(["surprise", "laugh", "shrug", "nod", "facepalm"][randi() % 5])
	var qr := Quests.progress(target, item)
	if qr != "" and hud:
		if item == "selfie":
			await selfie_shot(hud, Quests.who(target))
		hud.quest_update(item, target, qr == "done")
	var handled := false
	if target != "" and item_handler.is_valid():
		handled = await item_handler.call(target, item)
	if not handled and hud:
		if target != "":
			hud.show_reaction(target, item)
		else:
			await _self_use(item, hud)
	_item_busy = false


## Oturma görünümü: göz hizası oturma yüksekliğine iner (çay, daktilo). Kontrol geri gelince kendiliğinden kalkar.
var seated := false


func sit_view(on: bool, lift := 0.0) -> void:
	seated = on and lift == 0.0
	var target := EYE - 0.55 if on and lift == 0.0 else (EYE + lift if lift != 0.0 else EYE)
	if GameState.autotest:
		eye_height = target
		return
	var tw := create_tween()
	tw.tween_property(self, "eye_height", target, 0.45 if lift == 0.0 else 0.3).set_trans(Tween.TRANS_SINE)


## Birinci şahıs el hareketi: "reach" (E: uzanıp dokunur), "show" (eldekini karşıdakine uzatır),
## "mouth" (ağza götürür: çay, leblebi), "rub" (kolonyayı ellerine sürer). Yürürken sallanma bu sırada durur.
func hand_gesture(kind: String) -> void:
	if hand == null or not hand.visible or not _hand_shown or GameState.autotest:
		return
	if _hand_tween and _hand_tween.is_running():
		return
	var base := _hand_base
	_hand_tween = create_tween()
	match kind:
		"reach":
			_hand_tween.tween_property(hand, "position", base + Vector3(-0.08, 0.06, -0.14), 0.12).set_ease(Tween.EASE_OUT)
			_hand_tween.tween_property(hand, "position", base, 0.2).set_trans(Tween.TRANS_SINE)
		"show":
			_hand_tween.tween_property(hand, "position", base + Vector3(-0.16, 0.1, -0.12), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_hand_tween.tween_interval(0.9)
			_hand_tween.tween_property(hand, "position", base, 0.25)
		"mouth":
			_hand_tween.tween_property(hand, "position", base + Vector3(-0.2, 0.14, 0.12), 0.3).set_trans(Tween.TRANS_SINE)
			_hand_tween.parallel().tween_property(hand, "rotation_degrees:x", 45.0, 0.3)
			_hand_tween.tween_interval(0.5)
			_hand_tween.tween_property(hand, "position", base, 0.3)
			_hand_tween.parallel().tween_property(hand, "rotation_degrees:x", 12.0, 0.3)
		"ear":
			# Telefonu / telsizi kulağa götürür
			_hand_tween.tween_property(hand, "position", base + Vector3(-0.02, 0.2, 0.22), 0.3).set_trans(Tween.TRANS_SINE)
			_hand_tween.parallel().tween_property(hand, "rotation_degrees:z", 70.0, 0.3)
			_hand_tween.tween_interval(1.6)
			_hand_tween.tween_property(hand, "position", base, 0.3)
			_hand_tween.parallel().tween_property(hand, "rotation_degrees:z", 0.0, 0.3)
		"rub":
			for i in 3:
				_hand_tween.tween_property(hand, "position", base + Vector3(-0.12, 0.02, 0.0), 0.12)
				_hand_tween.tween_property(hand, "position", base + Vector3(-0.04, 0.0, 0.0), 0.12)
			_hand_tween.tween_property(hand, "position", base, 0.15)


## Eşyanın kendi eylemi (boşlukta kullanınca): küçük bir görsel ve Tolga'nın bir cümlesi.
func _self_use(item: String, hud: Hud) -> void:
	var key := "ITEM_SELF_" + item.to_upper()
	match item:
		"selfie":
			hud.bark("SPK_TOLGA", key, 3.0)
			await outfit_view(2.8)
			return
		"lighter":
			var fl := Props.ball(_held_model, 0.05, Vector3(0, 0.24, 0), Color("ffb040"), Vector3(1, 1.8, 1), 6, 3.0)
			fl.material_override = Props.mat(Color("ffb040"), 4.0, false, "", false)
			var l := OmniLight3D.new()
			l.light_color = Color("ffb060")
			l.light_energy = 1.5
			l.omni_range = 3.0
			_held_model.add_child(l)
			get_tree().create_timer(2.5).timeout.connect(func():
				if is_instance_valid(fl):
					fl.queue_free()
				if is_instance_valid(l):
					l.queue_free())
		"thermos", "cologne":
			hand_gesture("mouth" if item == "thermos" else "rub")
			var st := Vfx.steam(get_parent(), global_position + Vector3(0, eye_height - 0.2, 0) - global_transform.basis.z * 0.5)
			get_tree().create_timer(1.8).timeout.connect(func():
				if is_instance_valid(st):
					st.queue_free())
		"chickpeas":
			hand_gesture("mouth")
			Audio.sfx("typewriter", -6.0, 0.6)
		"cube":
			var tw := create_tween()
			tw.tween_property(_held_model, "rotation:y", _held_model.rotation.y + TAU, 0.6)
		"phone":
			_held_model.scale *= 1.15
			get_tree().create_timer(0.4).timeout.connect(func():
				if is_instance_valid(_held_model):
					_held_model.scale /= 1.15)
	# Birkaç farklı cümle: sırayla döner
	var n := 1
	while tr("%s_%d" % [key, n + 1]) != "%s_%d" % [key, n + 1]:
		n += 1
	var idx: int = int(GameState.flags.get("self_use_" + item, 0))
	GameState.flags["self_use_" + item] = idx + 1
	hud.bark("SPK_TOLGA", key if idx % n == 0 else "%s_%d" % [key, idx % n + 1], 3.2)


# ---------------------------------------------------------------- mini oyunlar

## Seviyedeki "mg:<id>" etkileşim noktasından mini oyun: oyuncu donar, oyun biter, sonuç repliği gelir.
func _start_minigame(id: String) -> void:
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud == null or _item_busy or frozen:
		return
	var mg: MiniGame
	match id:
		"cauldron":
			mg = MiniGameCauldron.new()
		"haggle_wine", "haggle_double", "haggle_urban", "haggle_niko":
			var h := MiniGameHaggle.new()
			h.merchant = id.trim_prefix("haggle_")
			mg = h
		"mangala":
			mg = MiniGameMangala.new()
		"archery":
			mg = MiniGameArchery.new()
		_:
			return
	mg.title_font = hud._title_font
	frozen = true
	hud.set_prompt("")
	var mouse := Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.add_child(mg)
	var res: Array = await mg.finished
	mg.queue_free()
	Input.mouse_mode = mouse
	frozen = false
	var score: int = res[0]
	var won: bool = res[1]
	match id:
		"cauldron":
			GameState.bump_stat("cauldron_best", score, true)
			if (mg as MiniGameCauldron).duel:
				if won:
					GameState.bump_stat("kadri_duel_wins")
				hud.bark("SPK_TOLGA", "MG_CAUL_T_DUEL_WIN" if won else "MG_CAUL_T_DUEL_LOSE", 3.5)
		"archery":
			GameState.bump_stat("archery_best", score, true)
			hud.bark("SPK_HASAN", "MG_ARC_H_AFTER_WIN" if won else "MG_ARC_H_AFTER_LOSE", 4.0)
		"haggle_wine", "haggle_double", "haggle_urban", "haggle_niko":
			if won:
				GameState.bump_stat("haggle_wins")
			hud.bark("SPK_TOLGA", "MG_HAG_T_WIN" if won else "MG_HAG_T_LOSE", 3.0)
		"mangala":
			if won:
				GameState.bump_stat("mangala_wins")


## Bir sahne kararıp açıldıktan sonra kontrol oyuncuya geçince: duvara dönük başlamasın (hedefe dön),
## hedef hiç yoksa denetim için uyarı yaz (oyuncu ne yapacağını bilmez).
func _on_released() -> void:
	if not is_inside_tree():
		return
	if seated or absf(eye_height - EYE) > 0.01:
		sit_view(false)
	_unstick()
	var hud := get_tree().get_first_node_in_group("hud") as Hud
	if hud == null or Time.get_ticks_msec() - hud.last_blackout_ms > 8000:
		return
	var tree := get_tree()
	await tree.process_frame
	if not is_instance_valid(self) or not is_inside_tree():
		return
	await tree.process_frame
	if not is_instance_valid(self) or frozen or not is_inside_tree():
		return
	var tgt: Variant = null
	if hud.marker and hud.marker.target != null:
		tgt = hud.marker._world_pos()
	if tgt == null and hud._objective.text == "":
		var sc := get_tree().current_scene
		print("WARN_FREE_NO_OBJECTIVE scene=%s" % (sc.scene_file_path.get_file() if sc else ""))
	if GameState.autotest:
		return
	var fwd := -global_transform.basis.z
	fwd.y = 0.0
	var eye := global_position + Vector3(0, 1.2, 0)
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(eye, eye + fwd.normalized() * 1.6, 1, [get_rid()])
	if space.intersect_ray(q).is_empty():
		return
	if tgt != null:
		face(tgt as Vector3)
		return
	# Hedef yoksa en açık yöne dön
	var best := 0.0
	var best_a := rotation.y
	for k in 12:
		var a := k * TAU / 12.0
		var dir := Vector3(-sin(a), 0, -cos(a))
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(eye, eye + dir * 8.0, 1, [get_rid()]))
		var d: float = 8.0 if hit.is_empty() else eye.distance_to(hit["position"])
		if d > best:
			best = d
			best_a = a
	rotation.y = best_a
