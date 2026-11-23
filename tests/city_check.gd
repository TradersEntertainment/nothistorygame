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
	# CITYCHECK_CH=24 (virgüllü): yalnız bu bölümler (yerel deneme); tam paket hepsini koşar
	var chs: Array = CHAPTERS
	if OS.get_environment("CITYCHECK_CH") != "":
		chs = Array(OS.get_environment("CITYCHECK_CH").split(",", false))
	for ch: String in chs:
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
	var yk: IstHayatYakin = null
	var t := 0.0
	while t < 120.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		cl = _find_life(root)
		if cl and cl.graph_ready and cl.is_processing():
			break
		yk = _find_v2()
		if cl == null and yk and yk.graph_ready and yk.active_list().size() >= MIN_CIV:
			break
	if cl == null and yk != null and yk.graph_ready:
		await _chapter_v2(ch, yk)
		root.queue_free()
		for k in 3:
			await get_tree().process_frame
		return
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
		# Akış: doğsunlar, yürüsünler. Işınlanmadan sonraki ilk 1,5 sn (doğuşlar) ölçülmez; bütçe sonraki 5,5 sn'nin kare
		# ortalamasıyla karşılaştırılır (tek anda okunan kayan ortalama düşünme karesine denk gelince zıplıyordu)
		cl.prof_us = 0.0
		var tt := 0.0
		var armed := false
		while tt < 7.0:
			await get_tree().process_frame
			tt += get_process_delta_time()
			if not armed and tt >= 1.5:
				armed = true
				cl.prof_sum_us = 0.0
				cl.prof_n = 0
				cl.prof_max_us = 0.0
		worst_us = maxf(worst_us, _mean_us(cl))
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


## Ölçüm penceresindeki ortalama kare süresi (µs)
func _mean_us(cl: CityLife) -> float:
	return cl.prof_sum_us / maxf(cl.prof_n, 1)


func _find_life(root: Node) -> CityLife:
	var best: CityLife = null
	for n in root.find_children("CityLife", "Node3D", true, false):
		if n is CityLife and (n as CityLife).is_inside_tree():
			best = n
	return best


## İstanbul v2 dünyasının yakın kalabalığı (IstHayatYakin; düğüm adı "CityLife", StreetEye uyumlu). 0.99.125'ten Bölüm
## 24'ün şehir yarısı v2'de (SurHub): eski CityLife yerine bu kurulur.
func _find_v2() -> IstHayatYakin:
	var yk := IstHayatYakin.aktif
	if yk != null and is_instance_valid(yk) and yk.is_inside_tree():
		return yk
	return null


## v2 şehri: eski ölçütlerin aynısı. Oyuncunun durduğu yer ve oradan 40-85 m ötede sokakta yürüyen iki kişinin yeri:
## çevrede (NEAR) en az MIN_CIV sivil; kimse evde, havada/gömülü ya da suda değil (IstHayatYakin.sayim); gerçek gövde
## ajanın konumunu izliyor; kalabalığın kare süresi bütçede.
func _chapter_v2(ch: String, yk: IstHayatYakin) -> void:
	_player = get_tree().get_first_node_in_group("player") as Node3D
	var dn := yk.get_parent() as Node3D
	print("CITYCHECK %s: kaynak=v2 (IstHayatYakin) gece=%s hedef=%d etkin=%d" % [ch, yk.gece, yk.hedef_sayi(), yk.active_list().size()])
	# Bölümün açılış yüklemesi (v2 dünyasının akışı, gölgelendirici ısınması) bitene kadar bekle: art arda 30 kare ≤ 50 ms.
	# Eski CityLife ısınma bitene kadar işlemez (ölçüm ondan sonra başlar); v2 ilk karesinden işler, ilk ölçüm yüklemeye
	# denk geliyordu (5,5 sn'de 55 kare). Bütçe aynı.
	var calm := 0
	var st := 0.0
	while calm < 30 and st < 40.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		st += dt
		calm = calm + 1 if dt <= 0.05 else 0
	print("CITYCHECK %s v2: açılış yüklemesi %.1f sn (sakin=%d)" % [ch, st, calm])
	var pts: Array[Vector3] = [_player.global_position]
	var worst_us := 0.0
	var i := 0
	while i < pts.size():
		_hold = pts[i]
		_player.global_position = _hold
		var tt := 0.0
		var armed := false
		while tt < 7.0:
			await get_tree().process_frame
			tt += get_process_delta_time()
			if not armed and tt >= 1.5:
				armed = true
				yk.prof_sum_us = 0.0
				yk.prof_n = 0
				yk.prof_max_us = 0.0
		var mean_us := yk.prof_sum_us / maxf(yk.prof_n, 1)
		worst_us = maxf(worst_us, mean_us)
		var g := dn.global_transform
		var at_l := g.affine_inverse() * pts[i]
		var civ := 0
		var pat := 0
		var kopuk := 0
		var roles := {}
		for ag in yk.active_list():
			var d: float = Vector2(ag.pos.x - at_l.x, ag.pos.z - at_l.z).length()
			if d <= IstHayatYakin.NEAR:
				if ag.kind == "patrol":
					pat += 1
				else:
					civ += 1
					roles[ag.role] = int(roles.get(ag.role, 0)) + 1
			if ag.near and ag.body != null and is_instance_valid(ag.body) and ag.body.visible:
				var bp: Vector3 = g.affine_inverse() * (ag.body.global_position as Vector3)
				var lag: float = bp.distance_to(ag.pos)
				if lag > maxf(0.5, get_process_delta_time() * 3.0 * 2.4 + 0.2):
					kopuk += 1
		var s := yk.sayim()
		var bad := int(s["evde"]) + int(s["havada"]) + int(s["suda"]) + kopuk
		print("CITYCHECK %s v2 @(%.0f, %.0f): sivil=%d devriye=%d evde=%d havada=%d suda=%d kopuk=%d roller=%s µs=%.0f (en uzun kare %.0f, %d kare)" % [
			ch, at_l.x, at_l.z, civ, pat, s["evde"], s["havada"], s["suda"], kopuk, roles, mean_us, yk.prof_max_us, yk.prof_n])
		if civ < MIN_CIV:
			_fail("%s v2 @(%.0f, %.0f): sivil az (%d)" % [ch, at_l.x, at_l.z, civ])
		if bad > 0:
			_fail("%s v2 @(%.0f, %.0f): %d karakter yanlış yerde" % [ch, at_l.x, at_l.z, bad])
		if i == 0:
			# Ek iki nokta: ilk noktadan 40-85 m ötede sokakta yürüyen kişilerin yerleri, birbirinden 30 m ayrı
			for ag in yk.active_list():
				if pts.size() >= 3:
					break
				if ag.mode != "walk":
					continue
				var d0: float = Vector2(ag.pos.x - at_l.x, ag.pos.z - at_l.z).length()
				if d0 < 40.0 or d0 > 85.0:
					continue
				var wp: Vector3 = g * (ag.pos + Vector3(0, 0.05, 0))
				if pts.size() == 2 and wp.distance_to(pts[1]) < 30.0:
					continue
				pts.append(wp)
		i += 1
	_hold = Vector3.INF
	if pts.size() < 3:
		_fail("%s v2: şehirde yeterli açık nokta yok (%d)" % [ch, pts.size()])
	if worst_us > BUDGET_US:
		_fail("%s v2: kalabalığın kare süresi %.0f µs > %.0f" % [ch, worst_us, BUDGET_US])
	print("CITYCHECK %s v2: kare süresi (en kötü nokta ortalaması) %.0f µs" % [ch, worst_us])


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
		# Gövde ajanın konumunu izliyor mu (CityLife değişmeyeni yazmaz, uzaktakini üç karede bir yazar)
		var lag := lp.distance_to(e["pos"] as Vector3)
		# Uzaktaki gövde üç karede bir yazılır: yavaş makinede (CI) uzun karede eşlikçi (≈2 m/s) 0,5 m'yi aşabiliyordu
		var allow := maxf(0.5, get_process_delta_time() * 3.0 * 2.4 + 0.2)
		if lag > allow:
			why = "gövde yerinden kopuk (%.2f m)" % lag
		elif World1453.is_water(lp.x, lp.z):
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
	print("CITYCHECK %s @(%.0f, %.0f): sivil=%d devriye=%d kötü=%d roller=%s µs=%.0f (en uzun kare %.0f, %d kare)" % [ch, at.x, at.z, civ, pat, bad, roles,
		_mean_us(cl), cl.prof_max_us, cl.prof_n])
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
