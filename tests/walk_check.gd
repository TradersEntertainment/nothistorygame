extends Node3D
## Her yer yürünür (WorldWalk): birkaç bölgenin dünyasını kurar, katılaşmanın bitmesini bekler ve denetler:
##   · Dünyanın karasında (su ve oynanış alanı dışı) 150 m'lik ızgarada aşağı ışın zemine çarpar ve çarpma
##     görünen yüksekliğe yakındır (eksik ya da havada zemin yok).
##   · Şehrin evleri katı: şehirde yatay ışınların bir kısmı bir eve çarpar.
##   · Bir oyuncu şehirde 4 sn yürür: düşmez, ilerler.
##   · Suya yürüyen oyuncu kıyıya döner.
## Sonuç: WALKCHECK PASS/FAIL.

var ok := true


func _ready() -> void:
	GameState.autotest = true
	for reg: Array in [["landwalls", [Rect2(-70.0, -20.0, 140.0, 80.0)]], ["horn_wall_o", [Rect2(-40.0, -12.0, 80.0, 77.0)]],
			["byz_aya", [Rect2(-60.0, -60.0, 120.0, 120.0)]], ["galata", [Rect2(-60.0, -60.0, 120.0, 120.0)]]]:
		var holder := Node3D.new()
		add_child(holder)
		var w := World1453.build(holder, reg[0], reg[1], false)
		var ww: WorldWalk = w.get_node("WorldWalk")
		var t := 0
		while not ww.done and t < 2000:
			await get_tree().process_frame
			t += 1
		for i in 3:
			await get_tree().physics_frame
		await _check(reg[0], w, ww)
		remove_child(holder)
		holder.queue_free()
		await get_tree().physics_frame
	print("WALKCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit()


func _check(reg: String, w: SiegeField, ww: WorldWalk) -> void:
	var space := get_world_3d().direct_space_state
	var to_scene := w.global_transform
	var miss := 0
	var off := 0
	var n := 0
	var x := WorldFlight.X0 + 75.0
	while x < WorldFlight.X1:
		var z := WorldFlight.Z0 + 75.0
		while z < 880.0:
			var wx := x
			var wz := z
			z += 150.0
			if World1453.is_water(wx, wz) or ww._in_keep(Vector3(wx, 0, wz)):
				continue
			# Kıyıya çok yakın (kıyı şeridi su ile kara arasında) ve dünyanın kenarı sayılmaz
			if World1453.is_water(wx + 40.0, wz) or World1453.is_water(wx - 40.0, wz) or World1453.is_water(wx, wz + 40.0) or World1453.is_water(wx, wz - 40.0):
				continue
			var gy := World1453.ground_h(wx, wz)
			var a := to_scene * Vector3(wx, gy + 80.0, wz)
			var b := to_scene * Vector3(wx, gy - 40.0, wz)
			var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(a, b))
			n += 1
			if hit.is_empty():
				miss += 1
				if miss <= 5:
					print("WALKCHECK %s zemin yok: dünya (%.0f, %.0f)" % [reg, wx, wz])
				continue
			var hy: float = (to_scene.affine_inverse() * (hit["position"] as Vector3)).y
			if hy < gy - 3.0:
				off += 1
				if off <= 5:
					print("WALKCHECK %s zemin aşağıda: dünya (%.0f, %.0f) görünen≈%.1f çarpma %.1f" % [reg, wx, wz, gy, hy])
		x += 150.0
	# Evler: şehirde yatay ışınlar
	var house_hits := 0
	var rays := 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in 300:
		var wx := rng.randf_range(World1453.HORN_S_X + 60.0, 500.0)
		var wz := rng.randf_range(-1400.0, -100.0)
		if not World1453.in_city(wx, wz, 40.0) or ww._in_keep(Vector3(wx, 0, wz)):
			continue
		var gy := SiegeField.city_ground(wx, wz) + 1.5
		var a := to_scene * Vector3(wx, gy, wz)
		var b := to_scene * Vector3(wx + 30.0, gy, wz)
		rays += 1
		if not space.intersect_ray(PhysicsRayQueryParameters3D.create(a, b)).is_empty():
			house_hits += 1
	print("WALKCHECK %s noktalar=%d zeminsiz=%d aşağıda=%d ev ışını=%d/%d şekil=%d kutu=%d üçgen=%d" % [reg, n, miss, off,
		house_hits, rays, ww.shapes, ww.boxes, ww.tris])
	if miss > 0 or off > n / 50:
		_fail("%s: zemin eksik" % reg)
	if rays > 20 and house_hits < rays / 5:
		_fail("%s: evler katı değil (%d/%d)" % [reg, house_hits, rays])
	if reg == "byz_aya":
		await _walk(w, ww)


func _walk(w: SiegeField, ww: WorldWalk) -> void:
	# Şehirde yürüyüş: Ayasofya'nın 300 m batısı
	var wp := Vector3(-860.0, 0.0, -1480.0)
	wp.y = SiegeField.city_ground(wp.x, wp.z) + 1.0
	var p := Player.new()
	add_child(p)
	p.global_position = w.global_transform * wp
	for i in 30:
		await get_tree().physics_frame
	var start := p.global_position
	Input.action_press("move_forward")
	for i in 240:
		await get_tree().physics_frame
	Input.action_release("move_forward")
	var moved := Vector2(p.global_position.x - start.x, p.global_position.z - start.z).length()
	var lw := w.global_transform.affine_inverse() * p.global_position
	var gy := SiegeField.city_ground(lw.x, lw.z)
	print("WALKCHECK yürüyüş: yol=%.1f m, ayak=%.1f zemin≈%.1f" % [moved, lw.y, gy])
	if lw.y < gy - 2.0:
		_fail("yürüyüş: oyuncu zeminin altına düştü")
	if moved < 1.0 and not p.is_on_floor():
		_fail("yürüyüş: oyuncu duruyor ve havada")
	# Suya yürü: Haliç kıyısı
	var shore := Vector3(World1453.HORN_S_X + 20.0, 0.0, -900.0)
	shore.y = SiegeField.city_ground(shore.x, shore.z) + 1.0
	p.global_position = w.global_transform * shore
	for i in 40:
		await get_tree().physics_frame
	var land_y := p.global_position.y
	# Suya at (Haliç ortası, kıyının 60 m ötesi)
	p.global_position = w.global_transform * Vector3(World1453.HORN_S_X - 120.0, World1453.SEA_Y + 0.5, -900.0)
	for i in 180:
		await get_tree().physics_frame
	var after := w.global_transform.affine_inverse() * p.global_position
	print("WALKCHECK su: dönüş=(%.0f, %.1f, %.0f)" % [after.x, after.y, after.z])
	if World1453.is_water(after.x, after.z) and after.y < World1453.SEA_Y + 0.3:
		_fail("su: oyuncu suda kaldı")
	p.queue_free()


func _fail(msg: String) -> void:
	ok = false
	printerr("WALKCHECK FAIL: " + msg)
