extends Node
## Yaşayan İstanbul (CityLife, docs/CITY_LIFE.md §3): bölümü kurar (bölüm kendi akışında bekler), oyuncuyu şehrin
## birkaç noktasına ışınlar ve bakar:
##   · çevresinde (90 m) en az 8 sivil ve 1 devriye var;
##   · hiçbir karakter bir evin içinde, havada, gömülü, suda ya da bölümün kendi alanında (keep) değil;
##   · CityLife'ın kare süresi bütçede (headless ölçüm);
##   · sokak ağı CityPlan'dan geliyorsa düğümlerin %95'i evlerden boş; Landmarks1453 varsa yapılar yüklü.
## Sonuç: CITYCHECK PASS/FAIL.

const CHAPTERS := ["24", "31o"]
## Dünya koordinatında aday noktalar (en yakın açık sokak düğümüne ışınlanılır)
const POINTS := [Vector3(-470.0, 0, -1255.0), Vector3(-300.0, 0, -930.0), Vector3(-120.0, 0, -520.0),
	Vector3(220.0, 0, -260.0), Vector3(-600.0, 0, -1050.0), Vector3(-345.0, 0, -1320.0)]
const MIN_CIV := 8
const BUDGET_US := 1500.0

var ok := true
var _player: Node3D
var _hold := Vector3.INF


func _ready() -> void:
	set_meta("citylife", true)        # World1453.build / LandWalls bu test sahnesinde de CityLife ekler
	# Bölüm kendi akışında ilk konuşmada beklesin: kendiliğinden ilerleyen diyalog (ayar) bölümü sonraki evrelere
	# götürüp şehri değiştiriyordu (Bölüm 24'te son iki noktada CityLife boş kalıyordu)
	GameState.settings["auto_advance"] = false
	for ch: String in CHAPTERS:
		await _chapter(ch)
	print("CITYCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)


func _process(_d: float) -> void:
	if _hold != Vector3.INF and is_instance_valid(_player):
		_player.global_position = _hold
		if _player is CharacterBody3D:
			(_player as CharacterBody3D).velocity = Vector3.ZERO


func _chapter(ch: String) -> void:
	var scene: PackedScene = load("res://scenes/chapter%s.tscn" % ch)
	var root := scene.instantiate()
	add_child(root)
	# Şehrin CityLife'ı kurulup hazır olana kadar bekle (WorldWalk katıları + sokak ağı)
	var cl: CityLife = null
	var t := 0.0
	while t < 120.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		cl = _find_life(root)
		if cl and cl.graph_ready and cl.is_processing():
			break
	if cl == null or not cl.graph_ready:
		_fail("%s: CityLife yok ya da hazır değil" % ch)
		root.queue_free()
		await get_tree().process_frame
		return
	_player = get_tree().get_first_node_in_group("player") as Node3D
	var w := cl.world
	print("CITYCHECK %s: kaynak=%s dönem=%s gece=%s yoğunluk=%.2f düğüm=%d meydan=%d yapı=%d" % [ch, cl.source, cl.era,
		cl.night, cl.density, cl.nodes.size(), cl.plazas.size(), cl.landmarks.size()])
	var worst_us := 0.0
	var visited := 0
	for wp: Vector3 in POINTS:
		var i := _nearest_open(cl, wp)
		if i < 0:
			print("CITYCHECK %s: (%.0f, %.0f) yakınında açık düğüm yok" % [ch, wp.x, wp.z])
			continue
		visited += 1
		var np := cl.nodes[i]
		_hold = w.global_transform * (np + Vector3(0, 0.05, 0))
		_player.global_position = _hold
		# Akış: doğsunlar, yürüsünler
		cl.prof_us = 0.0
		var tt := 0.0
		while tt < 7.0:
			await get_tree().process_frame
			tt += get_process_delta_time()
		worst_us = maxf(worst_us, cl.prof_us)
		_check_point(ch, cl, np)
	_hold = Vector3.INF
	if visited < 3:
		_fail("%s: şehirde yeterli açık nokta yok (%d)" % [ch, visited])
	if worst_us > BUDGET_US:
		_fail("%s: CityLife kare süresi %.0f µs > %.0f" % [ch, worst_us, BUDGET_US])
	print("CITYCHECK %s: kare süresi (en kötü nokta ortalaması) %.0f µs, kurulan gövde %d" % [ch, worst_us, cl._built])
	if cl.source == "plan":
		_check_plan(ch, cl)
	root.queue_free()
	for k in 3:
		await get_tree().process_frame


func _find_life(root: Node) -> CityLife:
	var best: CityLife = null
	for n in root.find_children("CityLife", "Node3D", true, false):
		if n is CityLife and (n as CityLife).is_inside_tree():
			best = n
	return best


func _nearest_open(cl: CityLife, wp: Vector3) -> int:
	var best := -1
	var bd := 120.0
	for i in cl.nodes.size():
		var d := Vector2(cl.nodes[i].x - wp.x, cl.nodes[i].z - wp.z).length()
		if d < bd and cl._nstate[i] != 2:
			cl._budget = 50
			if cl._node_open(i) and not cl._open_nbrs(i).is_empty():
				bd = d
				best = i
	return best


func _check_point(ch: String, cl: CityLife, at: Vector3) -> void:
	var w := cl.world
	var g := w.global_transform
	var space := w.get_world_3d().direct_space_state
	var ex: Array[RID] = []
	if _player is CollisionObject3D:
		ex.append((_player as CollisionObject3D).get_rid())
	var civ := 0
	var pat := 0
	var bad := 0
	var roles := {}
	for e: Dictionary in cl.active_list():
		var n: Node3D = e["node"]
		var lp: Vector3 = g.affine_inverse() * n.global_position
		var d := Vector2(lp.x - at.x, lp.z - at.z).length()
		if d <= CityLife.NEAR:
			if e["kind"] == "patrol":
				if int(e["slot"]) == 0:
					pat += 1
			else:
				civ += 1
				roles[e["role"]] = int(roles.get(e["role"], 0)) + 1
		var why := ""
		if World1453.is_water(lp.x, lp.z):
			why = "suda"
		elif cl._in_keep(lp.x, lp.z, 0.0):
			why = "bölümün alanında"
		else:
			var q := PhysicsPointQueryParameters3D.new()
			q.collision_mask = 1
			q.exclude = ex
			q.position = g * (lp + Vector3(0, 1.0, 0))
			if not space.intersect_point(q, 1).is_empty():
				why = "evin içinde"
			else:
				var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(g * (lp + Vector3(0, 0.8, 0)), g * (lp + Vector3(0, -1.5, 0)), 1, ex))
				if hit.is_empty():
					why = "zeminsiz"
				else:
					var hy: float = (g.affine_inverse() * (hit["position"] as Vector3)).y
					if absf(hy - lp.y) > 0.35:
						why = "havada/gömülü (%.2f m)" % (lp.y - hy)
		if why != "":
			bad += 1
			if bad <= 4:
				print("CITYCHECK %s: %s %s (%.1f, %.1f, %.1f) %s" % [ch, e["kind"], e["role"], lp.x, lp.y, lp.z, why])
	print("CITYCHECK %s @(%.0f, %.0f): sivil=%d devriye=%d kötü=%d roller=%s µs=%.0f" % [ch, at.x, at.z, civ, pat, bad, roles, cl.prof_us])
	if civ < MIN_CIV:
		_fail("%s @(%.0f, %.0f): sivil az (%d)" % [ch, at.x, at.z, civ])
	if pat < 1:
		_fail("%s @(%.0f, %.0f): devriye yok" % [ch, at.x, at.z])
	if bad > 0:
		_fail("%s @(%.0f, %.0f): %d karakter yanlış yerde" % [ch, at.x, at.z, bad])


## CityPlan'ın sokak düğümleri evlerden boş mu (%95); Landmarks1453 yapıları yüklü mü
func _check_plan(ch: String, cl: CityLife) -> void:
	var n := 0
	var open := 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 29
	for k in 400:
		var i := rng.randi() % cl.nodes.size()
		var p := cl.nodes[i]
		if not World1453.in_city(p.x, p.z, 6.0) or cl._in_keep(p.x, p.z, 6.0) or World1453.is_water(p.x, p.z):
			continue
		p.y = World1453.surface_h(p.x, p.z)
		n += 1
		cl._budget = 10
		if cl._spot_open(p):
			open += 1
	print("CITYCHECK %s: sokak düğümleri açık %d/%d" % [ch, open, n])
	if n > 40 and open < n * 0.95:
		_fail("%s: sokak düğümlerinin %%95'i boş değil (%d/%d)" % [ch, open, n])
	if CityLife._cls("Landmarks1453") != null and cl.landmarks.is_empty():
		_fail("%s: Landmarks1453 yapıları yok" % ch)


func _fail(msg: String) -> void:
	ok = false
	printerr("CITYCHECK FAIL: " + msg)
