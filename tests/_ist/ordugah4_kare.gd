extends Node3D
## ORDUGÂH-4 sondası: v2 dünyasını kurar, ordugâhın karelerini alır ve sayar.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/ordugah4_kare.tscn -- --out=KLASÖR
##       [--set=pafta|yer|hava|gece|butce|hepsi] [--gece]
## Satırlar:
##   ISTORDUKARE ad cizim= ucgen= ordu_cizim= kisi30= kisi70= hayvan30=
##   ISTORDUKISI icinde= havada= toplam=
##   ISTORDUBUTCE nokta= cizim= ucgen= ordu_cizim= ordu_ucgen=

var out := "user://ordugah4"
var set_ := "hepsi"
var gece := false
var cam: Camera3D
var root: Node3D
var dunya: Node3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
		elif a.begins_with("--set="):
			set_ = a.substr(6)
		elif a == "--gece":
			gece = true
	DirAccess.make_dir_recursive_absolute(out)
	root = Node3D.new()
	root.name = "IstV2"
	add_child(root)
	cam = Camera3D.new()
	cam.far = 9000.0
	cam.fov = 62.0
	add_child(cam)
	cam.make_current()
	var t0 := Time.get_ticks_msec()
	dunya = IstDunya.build(root, gece, Vector3.ZERO)
	print("ISTKUR ms=%d" % (Time.get_ticks_msec() - t0))
	for i in 10:
		await get_tree().process_frame
	var p := ("gece_" if gece else "")
	if set_ in ["pafta", "hepsi"] or "pafta" in set_.split(","):
		await _pafta(p)
	if (set_ in ["yer", "hepsi"] or "yer" in set_.split(",")) and not gece:
		await _yer()
	if set_ in ["hava", "hepsi"] and not gece:
		await _hava()
	if set_ in ["gece"] or (gece and set_ == "hepsi") or (gece and "gece" in set_.split(",")):
		await _gece_kareler()
	if set_ in ["butce", "hepsi"] or "butce" in set_.split(","):
		await _butce(p)
	if set_ in ["kisi", "hepsi"] or "kisi" in set_.split(","):
		await _kisi_denetim()
	var o := _ordu()
	if o:
		print("ISTORDUKURMS ", o.get("kur_ms"))
	print("ISTORDUKARE BITTI")
	get_tree().quit(0)


func _ordu() -> Node:
	return dunya.find_child("IstOrdugah", true, false) if dunya else null


func _plan_pos(id: String) -> Vector2:
	for it: Dictionary in IstOrdugah.plan():
		if String(it["id"]) == id:
			return it["pos"]
	return Vector2.INF


func _plan_it(id: String) -> Dictionary:
	for it: Dictionary in IstOrdugah.plan():
		if String(it["id"]) == id:
			return it
	return {}


func _g(p: Vector2, yuk := 0.0) -> Vector3:
	return Vector3(p.x, IstGeo.h(p.x, p.y) + yuk, p.y)


func _gw(e: float, n: float) -> Vector3:
	var w := IstGeo.w(e, n)
	return Vector3(w.x, maxf(w.y, 0.0), w.z)


# ---------------------------------------------------------------- pafta_ordugah'ın altı kamerası (ŞEHİR-3 s3_* ile aynı)

func _pafta(p: String) -> void:
	var pl: Array = IstOrdugah.plan()
	var ot: Vector2 = _plan_pos("otag")
	var oy := IstGeo.h(ot.x, ot.y)
	var yaw := float(_plan_it("otag")["yaw"])
	var to_wall := Vector3(sin(yaw), 0, cos(yaw))
	var o3 := Vector3(ot.x, oy, ot.y)
	await _shot(p + "ordu_30", o3 - to_wall * 70.0 + Vector3(0, 30, 0), o3 + to_wall * 120.0, 70)
	await _shot(p + "ordu_70", o3 - to_wall * 140.0 + Vector3(0, 70, 0), o3 + to_wall * 200.0, 70)
	await _shot(p + "otag_yakin", o3 + to_wall * 40.0 + Vector3(12, 14, 0), o3 + Vector3(0, 5, 0), 70)
	await _shot_en(p + "kara_disi", -5900.0, 300.0, 70.0, 80.0, 10.0)
	var w := IstOrdugah.at(1350.0, 70.0)
	var w2 := IstOrdugah.at(1600.0, 20.0)
	await _shot(p + "hendek", Vector3(w.x, IstGeo.h(w.x, w.y) + 15.0, w.y), Vector3(w2.x, IstGeo.h(w2.x, w2.y) + 4.0, w2.y), 70)


# ---------------------------------------------------------------- yerden yürüyüş (12 kare)

func _yer() -> void:
	var noktalar := [
		["yer_otag_onu", "otag", 30.0, 0.0],
		["yer_yeniceri_obasi", "yeniceri_1_1", 0.0, 0.0],
		["yer_anadolu", "anadolu_4_1", 0.0, 0.0],
		["yer_rumeli", "rumeli_3_1", 0.0, 0.0],
		["yer_pazar", "pazar", 16.0, 0.0],
		["yer_top_mevzii", "batarya_05", 22.0, 0.0],
		["yer_sahi", "sahi_top", 28.0, 0.0],
		["yer_siper", "siper_980", 18.0, 0.0],
		["yer_at_bagi", "ahir_otag", 14.0, 0.0],
		["yer_mutfak", "mutfak_otag", 14.0, 0.0],
		["yer_mescit", "mescit", 16.0, 0.0],
		["yer_zaganos", "zaganos_1_1", 0.0, 0.0],
	]
	for n: Array in noktalar:
		var it := _plan_it(n[1])
		if it.is_empty():
			print("ISTORDUKARE %s yok (öğe %s)" % [n[0], n[1]])
			continue
		var c: Vector2 = it["pos"]
		var yaw := float(it["yaw"])
		var back := Vector2(-sin(yaw), -cos(yaw))       # surdan uzağa (yerel −z)
		var dist: float = n[2]
		var at := c + back * dist if dist > 0.0 else c + Vector2(6, 4)
		var look := c if dist > 0.0 else c + Vector2(sin(yaw), cos(yaw)) * 40.0
		at = _bos_yer(at)
		await _shot(n[0], _g(at, 1.7), _g(look, 1.5), 70)


## Kişi/çadır katısının içinde olmayan yakın bir nokta (kamera çadırın içinde kalmasın)
func _bos_yer(p: Vector2) -> Vector2:
	var sp := get_world_3d().direct_space_state
	for r in range(0, 30, 2):
		for k in 8:
			var q := p + Vector2(r, 0).rotated(k * TAU / 8.0)
			var y := IstGeo.h(q.x, q.y)
			var pq := PhysicsShapeQueryParameters3D.new()
			var sh := SphereShape3D.new()
			sh.radius = 0.6
			pq.shape = sh
			pq.transform = Transform3D(Basis(), Vector3(q.x, y + 1.6, q.y))
			if sp.intersect_shape(pq, 1).is_empty():
				return q
	return p


# ---------------------------------------------------------------- 30 m ve 70 m'den sekiz kare

func _hava() -> void:
	var yerler := [["hava30_otag", "otag", 30.0], ["hava30_sahi", "sahi_top", 30.0], ["hava30_anadolu", "anadolu_4_1", 30.0],
		["hava30_rumeli", "rumeli_3_1", 30.0], ["hava70_otag", "otag", 70.0], ["hava70_mesoteikhion", "batarya_06", 70.0],
		["hava70_anadolu", "anadolu_2_1", 70.0], ["hava70_rumeli", "rumeli_5_1", 70.0]]
	for y: Array in yerler:
		var it := _plan_it(y[1])
		if it.is_empty():
			continue
		var c: Vector2 = it["pos"]
		var yaw := float(it["yaw"])
		var tw := Vector2(sin(yaw), cos(yaw))
		var yk: float = y[2]
		var at := c - tw * (yk * 1.6)
		await _shot(y[0], _g(at, yk), _g(c + tw * yk * 0.8, 0.0), 70)


func _gece_kareler() -> void:
	var ot := _plan_pos("otag")
	var yaw := float(_plan_it("otag")["yaw"])
	var tw := Vector2(sin(yaw), cos(yaw))
	await _shot("gece_yer_otag", _g(_bos_yer(ot - tw * 30.0), 1.7), _g(ot, 3.0), 70)
	var s := _plan_pos("sahi_top")
	await _shot("gece_yer_sahi", _g(_bos_yer(s - tw * 26.0), 1.7), _g(s, 1.5), 70)
	var a := _plan_pos("anadolu_4_1")
	await _shot("gece_30_anadolu", _g(a - tw * 50.0, 30.0), _g(a + tw * 30.0, 0.0), 70)


# ---------------------------------------------------------------- bütçe: ≥ 6 nokta, uçuşta 60 m ve yerde

func _butce(p: String) -> void:
	var ids := ["otag", "sahi_top", "anadolu_4_1", "rumeli_3_1", "batarya_02", "yeniceri_2_1"]
	for id: String in ids:
		var it := _plan_it(id)
		if it.is_empty():
			continue
		var c: Vector2 = it["pos"]
		var yaw := float(it["yaw"])
		var tw := Vector2(sin(yaw), cos(yaw))
		await _olc(p + "ucus60_" + id, _g(c - tw * 60.0, 60.0), _g(c + tw * 60.0, 0.0))
		if id in ["otag", "anadolu_4_1", "sahi_top"]:
			await _olc(p + "yer_" + id, _g(_bos_yer(c - tw * 12.0), 1.7), _g(c + tw * 30.0, 1.5))


func _olc(name: String, at: Vector3, look: Vector3) -> void:
	cam.global_position = at
	cam.look_at(look, Vector3.UP)
	await _bekle(at)
	for i in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var d := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var t := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	var o := _ordu() as Node3D
	var od := 0
	var ot := 0
	if o:
		o.visible = false
		for i in 3:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		od = d - RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		ot = t - RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		o.visible = true
		for i in 2:
			await get_tree().process_frame
	print("ISTORDUBUTCE nokta=%s cizim=%d ucgen=%.2fM ordu_cizim=%d ordu_ucgen=%.2fM" % [name, d, t / 1e6, od, ot / 1e6])


# ---------------------------------------------------------------- kişi denetimi: çadırın içinde / havada

func _kisi_denetim() -> void:
	var o := _ordu()
	if o == null:
		return
	# otağ ve birkaç öğenin çevresinde yakın katman kurulsun
	var ids := ["otag", "sahi_top", "anadolu_4_1", "rumeli_3_1", "yeniceri_1_1", "pazar", "batarya_05"]
	var icinde := 0
	var havada := 0
	var toplam := 0
	var sp := get_world_3d().direct_space_state
	for id: String in ids:
		var c := _plan_pos(id)
		if c == Vector2.INF:
			continue
		cam.global_position = _g(c, 20.0)
		cam.look_at(_g(c + Vector2(1, 1), 0.0), Vector3.UP)
		await _bekle(cam.global_position)
		for i in 3:
			await get_tree().physics_frame
		for k in _kisiler(cam.global_position, 60.0, "kisiler"):
			var q: Vector3 = k
			toplam += 1
			# ayak altı: arazi ya da bir katı yüzey (teras, halı, zemin) 0,35 m içinde mi
			var g := IstGeo.h(q.x, q.z)
			var alt := sp.intersect_ray(PhysicsRayQueryParameters3D.create(q + Vector3(0, 0.3, 0), q - Vector3(0, 0.6, 0)))
			var destek := absf(q.y - g) <= 0.35 or (not alt.is_empty() and q.y - (alt["position"] as Vector3).y <= 0.35)
			if not destek or q.y < g - 0.3:
				havada += 1
			var hit := sp.intersect_ray(PhysicsRayQueryParameters3D.create(q + Vector3(0, 6.0, 0), q + Vector3(0, 0.4, 0)))
			if not hit.is_empty() and (hit["position"] as Vector3).y > q.y + 1.0:
				var col = hit.get("collider")
				if col is Node and not String((col as Node).name).begins_with("kisi"):
					icinde += 1
	print("ISTORDUKISI icinde=%d havada=%d toplam=%d" % [icinde, havada, toplam])


## Kurulmuş öğelerin kişi/hayvan noktaları (dünya), merkezden r içinde
func _kisiler(at: Vector3, r: float, meta: String) -> Array:
	var o := _ordu()
	var res: Array = []
	if o == null:
		return res
	for h in o.get_children():
		if not (h is Node3D) or not (h as Node3D).visible or not h.has_meta(meta):
			continue
		var xf := (h as Node3D).global_transform
		for q: Vector3 in (h.get_meta(meta) as PackedVector3Array):
			var w := xf * q
			if Vector2(w.x, w.z).distance_to(Vector2(at.x, at.z)) <= r:
				res.append(w)
	return res


## Kamera karesinde (görüş konisi içinde, d ≤ r) kaç kişi var
func _karede(at: Vector3, r: float, meta: String) -> int:
	var n := 0
	for w: Vector3 in _kisiler(at, r, meta):
		if not cam.is_position_behind(w + Vector3(0, 1, 0)):
			var sp := cam.unproject_position(w + Vector3(0, 1, 0))
			if sp.x >= 0 and sp.y >= 0 and sp.x <= 1280 and sp.y <= 720:
				n += 1
	return n


# ---------------------------------------------------------------- kamera

func _shot_en(name: String, e: float, n: float, yuk: float, yon: float, egim: float, fov := 62.0) -> void:
	var p := _gw(e, n) + Vector3(0, yuk, 0)
	var b := deg_to_rad(yon)
	var dir := Vector3(sin(b) * cos(deg_to_rad(egim)), -sin(deg_to_rad(egim)), -cos(b) * cos(deg_to_rad(egim)))
	await _shot(name, p, p + dir * 10.0, fov)


## Ordugâh yöneticisinin yakın öğeleri kuruluncaya dek (ve şehrin yakın katmanı) bekler
func _bekle(at: Vector3) -> void:
	for i in 4:
		await get_tree().process_frame
	var guard := 0
	var o := _ordu()
	while guard < 400:
		var eksik := false
		if o and o.has_method("eksik_var"):
			eksik = bool(o.call("eksik_var"))
		elif o:
			eksik = not (o.get("kuyruk") as Array).is_empty()
		var s := IstSehir.active
		if not eksik and s and s.has_method("_yakin_eksik"):
			pass
		if not eksik and guard > 10:
			break
		await get_tree().process_frame
		guard += 1


func _shot(name: String, at: Vector3, look: Vector3, fov := 62.0) -> void:
	cam.fov = fov
	cam.global_position = at
	var up := Vector3.UP if absf((look - at).normalized().y) < 0.98 else Vector3(0, 0, -1)
	cam.look_at(look, up)
	await _bekle(at)
	for we in get_tree().root.find_children("*", "WorldEnvironment", true, false):
		var env := (we as WorldEnvironment).environment
		if env and env.fog_enabled:
			env.fog_enabled = false
			env.volumetric_fog_enabled = false
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_jpg(out.path_join(name + ".jpg"), 0.85)
	var draws := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var tris := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	var k30 := _karede(at, 30.0 + at.y - IstGeo.h(at.x, at.z), "kisiler")
	var k70 := _karede(at, 400.0, "kisiler")
	var h30 := _karede(at, 40.0 + at.y - IstGeo.h(at.x, at.z), "hayvanlar")
	var hk := _karede(at, 400.0, "hayvanlar")
	print("ISTORDUKARE %s cizim=%d ucgen=%.2fM kisi_yakin=%d kisi_karede=%d hayvan_yakin=%d hayvan_karede=%d" % [name, draws, tris / 1e6, k30, k70, h30, hk])
