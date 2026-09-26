extends Node3D
## Hareket testi (ekransız): tırmanma, kenardan çıkma, alçak engelin üstünden atlama, nefes, sınır ve iptal.
## Gerçek Player'a gerçek girdi eylemleri basılır (Input.action_press); her durumun sonucu denetlenir.
##   godot --headless --path . res://tests/traversal_test.tscn -- --autotest

var player: Player
var hud: Hud
var fails: Array[String] = []
var results: Array[String] = []


func _ready() -> void:
	Engine.time_scale = 2.0
	var ground := Props.solid(self, Vector3(90, 0.2, 90), Vector3(0, -0.1, 0), Color("c8b894"))
	ground.name = "Ground"
	# A · alçak duvar (0.8 m, ince): koşarken üstünden atlanır
	Props.solid(self, Vector3(4.0, 0.8, 0.3), Vector3(-24, 0.4, 0), Color("a89c86"))
	# B · kutu (2 m): zıplayıp kenardan çıkılır
	Props.solid(self, Vector3(3.0, 2.0, 3.0), Vector3(-16, 1.0, 0), Color("a07a4e"))
	# C · ev (8 m): tırmanılır, tepeden çıkılır
	Props.solid(self, Vector3(4.0, 8.0, 4.0), Vector3(-8, 4.0, 0), Color("e8c890"))
	# D · kule (16 m): nefes yetmez, kayıp düşer
	Props.solid(self, Vector3(4.0, 16.0, 4.0), Vector3(0, 8.0, 0), Color("d8c8a8"))
	# E · sur (no_climb)
	Props.solid(self, Vector3(4.0, 6.0, 1.0), Vector3(8, 3.0, 0), Color("fff0e0")).set_meta("no_climb", true)
	# F · tavanlı oda (iç mekân): 5 m duvarlar, 5.1'de tavan
	var r := Vector3(16, 0, 0)
	Props.solid(self, Vector3(4.0, 5.0, 0.3), r + Vector3(0, 2.5, -2.0), Color("efe0c4"))
	Props.solid(self, Vector3(4.0, 5.0, 0.3), r + Vector3(0, 2.5, 2.0), Color("efe0c4"))
	Props.solid(self, Vector3(0.3, 5.0, 4.0), r + Vector3(-2.0, 2.5, 0), Color("efe0c4"))
	Props.solid(self, Vector3(0.3, 5.0, 4.0), r + Vector3(2.0, 2.5, 0), Color("efe0c4"))
	Props.solid(self, Vector3(4.3, 0.3, 4.3), r + Vector3(0, 5.1, 0), Color("b5533a"))
	# G · görünmez duvar (ağı gizli)
	var inv := Props.solid(self, Vector3(4.0, 4.0, 0.3), Vector3(26, 2.0, 0), Color.WHITE)
	inv.get_child(0).visible = false
	# H · sınırdaki kutu (3 m): üstünden oyun alanı dışına yürünmez
	Props.solid(self, Vector3(4.0, 3.0, 6.0), Vector3(-4, 1.5, 24.0), Color("a07a4e"))
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.global_position = Vector3(0, 0.05, 12)
	player.enable_climb([Rect2(-40, -40, 80, 65)])   # z en çok 25
	_run()


func _release_all() -> void:
	for a in ["move_forward", "move_back", "move_left", "move_right", "jump", "sprint", "dive"]:
		Input.action_release(a)


func _place(pos: Vector3) -> void:
	_release_all()
	player.traversal.cancel()
	player.global_position = pos
	player.rotation.y = 0.0          # -Z'ye bakar
	player.camera.rotation = Vector3.ZERO
	player.velocity = Vector3.ZERO
	player.traversal.stamina = 1.0
	player.traversal.tired = false
	await _frames(6)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _secs(s: float) -> void:
	await get_tree().create_timer(s).timeout


func _press(action: String) -> void:
	Input.action_press(action)
	await _frames(2)
	Input.action_release(action)


func _check(name: String, ok: bool, detail: String) -> void:
	results.append("%s=%s" % [name, "ok" if ok else "FAIL"])
	if not ok:
		fails.append("%s (%s)" % [name, detail])


func _run() -> void:
	await _frames(10)
	var t := player.traversal
	# A · koşarken alçak duvarın üstünden kendiliğinden
	await _place(Vector3(-24, 0.05, 3.5))
	Input.action_press("sprint")
	Input.action_press("move_forward")
	await _secs(1.4)
	_release_all()
	await _secs(0.4)
	_check("vault", player.global_position.z < -0.6 and t.vaults >= 1, "z=%.2f vaults=%d" % [player.global_position.z, t.vaults])
	# B · 2 m kutuya zıplayıp çık
	await _place(Vector3(-16, 0.05, 2.1))
	await _press("jump")
	await _secs(1.0)
	_check("mantle", absf(player.global_position.y - 2.0) < 0.25 and t.mantles >= 1, "y=%.2f mantles=%d" % [player.global_position.y, t.mantles])
	# C · 8 m eve tırman, tepeden çık
	await _place(Vector3(-8, 0.05, 2.6))
	await _press("jump")
	_check("grab", t.state == "climb", "state=%s" % t.state)
	Input.action_press("move_forward")
	var top := 0.0
	for i in 120:
		await _secs(0.1)
		top = maxf(top, player.global_position.y)
		if t.state == "" and player.is_on_floor() and player.global_position.y > 7.5:
			break
	_release_all()
	await _secs(0.4)
	_check("climb8", absf(player.global_position.y - 8.0) < 0.3, "y=%.2f top=%.2f stamina=%.2f" % [player.global_position.y, top, t.stamina])
	# Çatıdayken nefes dolar
	await _secs(2.5)
	_check("regen", t.stamina > 0.95, "stamina=%.2f" % t.stamina)
	# D · 16 m kule: nefes biter, düşer
	await _place(Vector3(0, 0.05, 2.6))
	await _press("jump")
	Input.action_press("move_forward")
	var high := 0.0
	var was_tired := false
	for i in 160:
		await _secs(0.1)
		high = maxf(high, player.global_position.y)
		was_tired = was_tired or t.tired
		if was_tired and player.is_on_floor():
			break
	_release_all()
	await _secs(0.5)
	_check("exhaust", was_tired and high < 13.0 and high > 7.0 and player.global_position.y < 0.3,
		"tired=%s high=%.2f y=%.2f" % [was_tired, high, player.global_position.y])
	_check("fall", t.falls >= 1, "falls=%d" % t.falls)
	# Tükenmişken yeniden tutunulamaz
	await _press("jump")
	await _frames(4)
	_check("tired_nograb", t.state != "climb", "state=%s" % t.state)
	# E · no_climb sur
	await _place(Vector3(8, 0.05, 1.3))
	var before := t.climbs
	await _press("jump")
	await _frames(4)
	_check("no_climb", t.state == "" and t.climbs == before, "state=%s" % t.state)
	# F · tavanlı odada tırmanılmaz
	await _place(Vector3(16, 0.05, -1.2))
	before = t.climbs
	await _press("jump")
	await _frames(4)
	_check("ceiling", t.state == "" and t.climbs == before, "state=%s" % t.state)
	# G · görünmez duvar
	await _place(Vector3(26, 0.05, 0.7))
	before = t.climbs
	await _press("jump")
	await _frames(4)
	_check("invisible", t.state == "" and t.climbs == before, "state=%s" % t.state)
	# H · sınır: 3 m kutunun üstünden oyun alanı dışına (z > 25) yürünmez
	await _place(Vector3(-4, 0.05, 21.5))
	player.rotation.y = PI            # +Z'ye bakar
	await _press("jump")
	Input.action_press("move_forward")
	var on_box := false
	for i in 40:
		await _secs(0.1)
		on_box = on_box or (t.state == "" and player.is_on_floor() and player.global_position.y > 2.8)
	_release_all()
	await _secs(0.3)
	_check("bounds", on_box and player.global_position.z <= 25.05 and player.global_position.y > 2.8,
		"on_box=%s z=%.2f y=%.2f" % [on_box, player.global_position.z, player.global_position.y])
	# I · ara sahne (frozen) tırmanmayı iptal eder, Tolga yere iner
	await _place(Vector3(-8, 0.05, 2.6))
	await _press("jump")
	Input.action_press("move_forward")
	await _secs(1.5)
	_release_all()
	var mid := player.global_position.y
	player.frozen = true
	await _frames(3)
	_check("cancel", mid > 1.0 and t.state == "" and player.global_position.y < 0.2, "mid=%.2f y=%.2f state=%s" % [mid, player.global_position.y, t.state])
	player.frozen = false
	Engine.time_scale = 1.0
	print("TRAVERSAL %s" % " ".join(results))
	if fails.is_empty():
		print("AUTOTEST PASS traversal checks=%d" % results.size())
	else:
		print("AUTOTEST FAIL traversal: %s" % "; ".join(fails))
	get_tree().quit()
