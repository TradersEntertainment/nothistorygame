extends SceneTree
## Erişilebilirlik taraması. godot --headless --path . -s tests/reach_check.gd -- OUT.png res://scenes/chapterN.tscn VARIANT NTH
## (ya da SCENE yerine "level:res://scripts/level/X.gd" ve NTH yerine "x,y,z"). NTH: kaçıncı hedef değişiminde taranacağı.
## Her yeni hedef bir evredir; NTH'inci evrede oyun dondurulur ve oyuncu kapsülüyle 1 m ızgarada taşkın doldurma yapılır:
## nereye yürüyebilir, nerede zemin biter (boşluk), nereden büyük düşüş var. Üstten harita PNG + özet.
const STEP := 1.0
const UP := 0.62        # zıplayarak çıkılabilecek basamak
const MAXC := 60000

func _initialize() -> void:
	_run()

func _run() -> void:
	var a := OS.get_cmdline_user_args()
	var out: String = a[0]
	DirAccess.make_dir_recursive_absolute(out.get_base_dir())
	var gs = root.get_node("GameState")
	gs.autotest = true
	gs.autotest_variant = a[2]
	var nth := int(a[3]) if a.size() > 3 else 1
	if a[1].begins_with("level:"):
		var lv = load(a[1].substr(6)).new()
		root.add_child(lv)
		await physics_frame
		await physics_frame
		var v := a[3].split(",")
		var body := CharacterBody3D.new()
		root.add_child(body)
		body.global_position = Vector3(float(v[0]), float(v[1]), float(v[2]))
		await physics_frame
		_flood(out, a[1], body, 0)
		quit()
		return
	change_scene_to_file(a[1])
	await create_timer(1.0).timeout
	var t := 0.0
	var seen := 0
	var last_obj := ""
	var sc = null
	while t < 400.0:
		await physics_frame
		t += 0.016
		sc = current_scene
		if sc == null or not ("player" in sc) or sc.player == null or not ("hud" in sc) or sc.hud == null:
			continue
		# Her yeni hedef bir "evre": hedef göründüğünde ve konuşma yokken say
		var obj: String = sc.hud._objective.text if sc.hud._objective_box.visible else ""
		if obj != "" and obj != last_obj:
			last_obj = obj
			seen += 1
			if seen >= nth:
				# Konuşma bitene kadar bekle (en çok 3 sn), sonra dondur
				var w := 0.0
				while w < 3.0 and sc.hud.line_open:
					await physics_frame
					w += 0.016
				break
	if sc == null:
		print("REACH none")
		quit()
		return
	# Oyunu dondur, doldur
	Engine.time_scale = 0.0
	await physics_frame
	print("OBJ ", last_obj)
	_flood(out, a[1], sc.player, nth)
	quit()

func _flood(out: String, scene_name: String, pl, nth: int) -> void:
	var space: PhysicsDirectSpaceState3D = pl.get_world_3d().direct_space_state
	var start: Vector3 = pl.global_position
	var cap := CapsuleShape3D.new()
	cap.radius = 0.28
	cap.height = 1.3
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.collision_mask = 1
	q.exclude = [pl.get_rid()]
	var cells := {}      # Vector2i -> floor y
	var voids := {}
	var drops := {}
	var queue: Array = []
	var k0 := Vector2i(roundi(start.x / STEP), roundi(start.z / STEP))
	cells[k0] = start.y
	queue.append(k0)
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var head := 0
	while head < queue.size() and cells.size() < MAXC:
		var c: Vector2i = queue[head]
		head += 1
		var fy: float = cells[c]
		for d: Vector2i in dirs:
			var n: Vector2i = c + d
			if cells.has(n) or voids.has(n):
				continue
			var p0 := Vector3(c.x * STEP, fy, c.y * STEP)
			var p1 := Vector3(n.x * STEP, fy, n.y * STEP)
			# Önce yol: basamak üstü yükseklikte bir şey kesiyor mu (duvarın içine zemin aranmasın)
			var pre := false
			for h0: float in [UP + 0.05, 1.3]:
				var r0 := PhysicsRayQueryParameters3D.create(p0 + Vector3(0, h0, 0), p1 + Vector3(0, h0, 0), 1, [pl.get_rid()])
				if not space.intersect_ray(r0).is_empty():
					pre = true
					break
			if pre:
				continue
			# Zemin
			var rq := PhysicsRayQueryParameters3D.create(p1 + Vector3(0, UP + 0.05, 0), p1 + Vector3(0, -60, 0), 1, [pl.get_rid()])
			var hit := space.intersect_ray(rq)
			if hit.is_empty():
				voids[n] = fy
				if voids.size() <= 3:
					print("VOID from=%s y=%.2f to=%s" % [str(c), fy, str(n)])
				continue
			var ny: float = hit.position.y
			if hit.normal.y < 0.6 or ny - fy > UP:
				continue
			# Yol açık mı (zıplama yüksekliğinde yatay ışınlar: bel ve göğüs)
			var blocked := false
			for h: float in [maxf(0.0, ny - fy) + 0.12, maxf(0.0, ny - fy) + 1.2]:
				var r2 := PhysicsRayQueryParameters3D.create(p0 + Vector3(0, h, 0), p1 + Vector3(0, h, 0), 1, [pl.get_rid()])
				if not space.intersect_ray(r2).is_empty():
					blocked = true
					break
			if blocked:
				continue
			# Hedefte kapsül sığıyor mu
			q.transform = Transform3D(Basis(), Vector3(p1.x, ny + 0.05 + 0.65 + 0.02, p1.z))
			if not space.intersect_shape(q, 1).is_empty():
				continue
			if fy - ny > 3.0:
				drops[n] = fy - ny
				if drops.size() <= 5:
					print("DROP from=%s y=%.2f to=%s y=%.2f" % [str(c), fy, str(n), ny])
			cells[n] = ny
			queue.append(n)
	# Harita
	var mn := Vector2i(1 << 20, 1 << 20)
	var mx := -mn
	var ymin := INF
	var ymax := -INF
	for c: Vector2i in cells:
		mn = Vector2i(mini(mn.x, c.x), mini(mn.y, c.y))
		mx = Vector2i(maxi(mx.x, c.x), maxi(mx.y, c.y))
		ymin = minf(ymin, cells[c])
		ymax = maxf(ymax, cells[c])
	for c: Vector2i in voids:
		mn = Vector2i(mini(mn.x, c.x), mini(mn.y, c.y))
		mx = Vector2i(maxi(mx.x, c.x), maxi(mx.y, c.y))
	var S := 4
	var w := (mx.x - mn.x + 1) * S
	var h2 := (mx.y - mn.y + 1) * S
	var img := Image.create(maxi(w, 1), maxi(h2, 1), false, Image.FORMAT_RGB8)
	img.fill(Color(0.08, 0.08, 0.1))
	for c: Vector2i in cells:
		var k := clampf((cells[c] - ymin) / maxf(ymax - ymin, 0.5), 0.0, 1.0)
		var col := Color(0.2, 0.35 + 0.5 * k, 0.3 + 0.2 * k).lerp(Color(0.95, 0.95, 0.9), k * 0.6)
		if drops.has(c):
			col = Color(1.0, 0.6, 0.1)
		img.fill_rect(Rect2i((c.x - mn.x) * S, (c.y - mn.y) * S, S, S), col)
	for c: Vector2i in voids:
		img.fill_rect(Rect2i((c.x - mn.x) * S, (c.y - mn.y) * S, S, S), Color(1, 0.1, 0.1))
	img.fill_rect(Rect2i((k0.x - mn.x) * S - 3, (k0.y - mn.y) * S - 3, S + 6, S + 6), Color(0.2, 0.5, 1.0))
	img.save_png(out)
	# Boşluk kümeleri (ilk birkaç örnek)
	var vs: Array = voids.keys()
	var ex := []
	for i in mini(vs.size(), 6):
		ex.append("(%d,%.1f,%d)" % [vs[i].x, voids[vs[i]], vs[i].y])
	print("REACH scene=%s nth=%d start=%s cells=%d voids=%d drops=%d x=[%d..%d] z=[%d..%d] y=[%.1f..%.1f] cap=%s ex=%s" % [
		scene_name.get_file(), nth, str(start.snapped(Vector3.ONE * 0.1)), cells.size(), voids.size(), drops.size(),
		mn.x, mx.x, mn.y, mx.y, ymin, ymax, str(cells.size() >= MAXC), " ".join(ex)])
	quit()
