extends Node3D
## İstanbul v2 şehir sondası (gezi sahnesi tests/_ist/gezi.tscn gelene kadar ve denetim için).
## IstDunya varsa onu kurar (araziyi, denizi, göğü o kurar ve IstSehir.attach_v2'yi çağırır); yoksa IstGeo.h'den kaba bir
## arazi + deniz + gök kurup IstSehir.attach_v2'yi kendisi çağırır.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/sehir2_kare.tscn -- --out=KLASÖR --tur=N
##       [--set=hava|eser|yer|denetim|hepsi] [--gece]
## Kamera: gerçek koordinat (doğu, kuzey) + yerden yükseklik + bakış yönü (kuzeyden saat yönü) + eğim.
## Satırlar: ISTKARE ad cizim= ucgen= · ISTAUDIT … · ISTSUR … · ISTKONMA …

var out := "user://ist2_kare"
var tur := 1
var set_ := "hepsi"
var gece := false
var eser_sec: Array = []
var a_uzak := false
var cam: Camera3D
var root: Node3D
var dunya: Node3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
		elif a.begins_with("--tur="):
			tur = a.substr(6).to_int()
		elif a.begins_with("--set="):
			set_ = a.substr(6)
		elif a == "--onpisirme=0":
			IstSehir.on_pisirme = false
		elif a == "--uzak":
			a_uzak = true
		elif a == "--gece":
			gece = true
		elif a.begins_with("--eser="):
			eser_sec = Array(a.substr(7).split(","))
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
	var dscr := load("res://scripts/world/ist/dunya.gd") if ResourceLoader.exists("res://scripts/world/ist/dunya.gd") else null
	if dscr != null:
		dunya = dscr.call("build", root, gece, Vector3.ZERO)
	else:
		IstSehir.attach_v2(root, gece)
		_kaba_dunya()
	print("ISTKUR ms=%d dunya=%s" % [Time.get_ticks_msec() - t0, "IstDunya" if dscr else "sonda"])
	if set_ == "kirilim":
		var m := IstGeo.yol("mese")
		var pts: Array = [["mese", m[2].lerp(m[3], 0.35)], ["ayasofya", IstGeo.w2(-150, 10)], ["galata", IstGeo.w2(-480, 1800)]]
		for pr: Array in pts:
			var q: Vector2 = pr[1]
			var at := Vector3(q.x, IstGeo.h(q.x, q.y) + 1.7, q.y)
			cam.global_position = at
			cam.look_at(at + Vector3(10, 0, 3), Vector3.UP)
			for i in 200:
				await get_tree().process_frame
				if not _yakin_eksik(IstSehir.active, at) and i > 20:
					break
			print("KIRILIM_AT ", pr[0])
			_kirilim(at)
		get_tree().quit(0)
		return
	if set_ == "hatdebug":
		var s2 := IstSehir.active
		s2.set_process(false)
		var n := 0
		for it: Dictionary in s2.hat_items:
			if String(it.get("hat", "")) != "halic_suru" or not it.has("len"):
				continue
			s2._build(it, 0)
			await get_tree().physics_frame
			await get_tree().physics_frame
			var p: Vector3 = it["pos"]
			var sp := get_world_3d().direct_space_state
			var out := []
			for dz: float in [-6.0, -3.0, 0.0, 3.0, 6.0]:
				var q: Vector3 = (it["holder"] as Node3D).transform * Vector3(0, 0, dz)
				var hit := sp.intersect_ray(PhysicsRayQueryParameters3D.create(q + Vector3(0, 40, 0), q - Vector3(0, 40, 0)))
				out.append("%.0f:%s" % [dz, ("%.1f" % (hit["position"] as Vector3).y) if not hit.is_empty() else "-"])
			print("HATDBG len=%.1f pos=%s h=%.1f mesh=%d body=%d %s" % [float(it["len"]), str(p), IstGeo.h(p.x, p.z), (it["holder"] as Node3D).find_children("*", "MeshInstance3D", true, false).size(), (it["holder"] as Node3D).find_children("*", "CollisionShape3D", true, false).size(), " ".join(out)])
			n += 1
		get_tree().quit(0)
		return
	if set_ == "kosedbg":
		var m := IstGeo.yol("mese")
		var q := m[2].lerp(m[3], 0.35)
		cam.global_position = Vector3(q.x, IstGeo.h(q.x, q.y) + 1.7, q.y)
		for i in 60:
			await get_tree().process_frame
		var gor := 0
		var ornek := ""
		for it: Dictionary in IstSehir.active.items:
			if not String(it["id"]).begins_with("kose_"):
				continue
			for l in 3:
				var nd: Node3D = it["have"][l]
				if nd != null and nd.is_visible_in_tree():
					gor += 1
					if ornek.length() < 300:
						ornek += " %s:l%d:d%.0f:want%d:r1=%.0f" % [it["id"], l, (it["pos"] as Vector3).distance_to(cam.global_position), int(it.get("want", -1)), float(it.get("r1", -1))]
		print("KOSEDBG gorunur=%d %s" % [gor, ornek])
		get_tree().quit(0)
		return
	if set_ == "yavas":
		await _yavas_yol()
		print("ISTKARE BITTI")
		get_tree().quit(0)
		return
	if set_ == "oyun":
		await _oyun_denetim()
		print("ISTKARE BITTI")
		get_tree().quit(0)
		return
	if set_ == "isaret":
		await _isaretler()
		print("ISTKARE BITTI")
		get_tree().quit(0)
		return
	if set_ == "suryuru":
		await _sur_yuru()
		print("ISTKARE BITTI")
		get_tree().quit(0)
		return
	if set_ in ["denetim", "hepsi"]:
		await _denetim()
	if set_ in ["hava", "hepsi"]:
		await _hava()
	if set_ in ["eser", "hepsi"]:
		await _eserler()
	if set_ in ["yer", "hepsi"]:
		await _yer()
	if set_ == "hepsi":
		await _isaretler()
		await _oyun_denetim()
	if IstSehir.active and IstSehir.active.stats.has("yavas"):
		print("ISTYAVAS ", IstSehir.active.stats["yavas"])
		print("ISTYAVAS_PIS ", IstSehir.active.stats.get("yavas_pis", {}))
		print("ISTBAGLA bagla_ms_max=%.1f" % float(IstSehir.active.stats.get("bagla_ms_max", 0.0)))
	print("ISTKARE BITTI")
	get_tree().quit(0)


# ---------------------------------------------------------------- kaba dünya (IstDunya yokken)

func _kaba_dunya() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var ps := ProceduralSkyMaterial.new()
	ps.sky_top_color = Color("1a2440") if gece else Color("6a9ad8")
	ps.sky_horizon_color = Color("3a4058") if gece else Color("d8e4ec")
	ps.ground_horizon_color = Color("c8d0d0")
	sky.sky_material = ps
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.3 if gece else 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.9
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -135, 0)
	sun.light_energy = 0.2 if gece else 1.1
	sun.light_color = Color("9ab0ff") if gece else Color("fff0d8")
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 500.0
	add_child(sun)
	# Arazi: 8 m ızgara, yükseklik IstGeo.h; çarpışma HeightMapShape3D
	var x0 := -3000.0
	var z0 := -2300.0
	var st := 8.0
	var nx := 501
	var nz := 451
	var hs := PackedFloat32Array()
	hs.resize(nx * nz)
	for j in nz:
		for i in nx:
			hs[j * nx + i] = IstGeo.h(x0 + i * st, z0 + j * st)
	var m := SurfaceTool.new()
	m.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in nz:
		for i in nx:
			var hh := hs[j * nx + i]
			var c := Color("6a7a3e").lerp(Color("9a8a5a"), clampf(hh / 40.0, 0, 1)) if hh > 0.5 else Color("b8a880")
			m.set_color(c)
			m.add_vertex(Vector3(x0 + i * st, hh, z0 + j * st))
	for j in nz - 1:
		for i in nx - 1:
			var a := j * nx + i
			m.add_index(a)
			m.add_index(a + 1)
			m.add_index(a + nx)
			m.add_index(a + 1)
			m.add_index(a + nx + 1)
			m.add_index(a + nx)
	m.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = m.commit()
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.roughness = 1.0
	mi.material_override = mat
	root.add_child(mi)
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var hm := HeightMapShape3D.new()
	hm.map_width = nx
	hm.map_depth = nz
	hm.map_data = hs
	cs.shape = hm
	cs.scale = Vector3(st, 1, st)
	cs.position = Vector3(x0 + (nx - 1) * st * 0.5, 0, z0 + (nz - 1) * st * 0.5)
	body.add_child(cs)
	root.add_child(body)
	var sea := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(16000, 16000)
	sea.mesh = pm
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color("1a3a5a") if gece else Color("3a7aa0")
	sm.roughness = 0.2
	sea.material_override = sm
	sea.position = Vector3(-1000, 0.0, 0)
	root.add_child(sea)


# ---------------------------------------------------------------- kamera

func _gw(e: float, n: float) -> Vector3:
	var w := IstGeo.w(e, n)
	return Vector3(w.x, maxf(w.y, 0.0), w.z)


## e, n gerçek; yuk: yerden; yon: bakış (kuzeyden saat yönü); egim: aşağı derece
func _shot_en(name: String, e: float, n: float, yuk: float, yon: float, egim: float, fov := 62.0) -> void:
	var p := _gw(e, n) + Vector3(0, yuk, 0)
	var b := deg_to_rad(yon)
	var dir := Vector3(sin(b) * cos(deg_to_rad(egim)), -sin(deg_to_rad(egim)), -cos(b) * cos(deg_to_rad(egim)))
	await _shot(name, p, p + dir * 10.0, fov)


func _shot(name: String, at: Vector3, look: Vector3, fov := 62.0) -> void:
	cam.fov = fov
	cam.global_position = at
	var up := Vector3.UP if absf((look - at).normalized().y) < 0.98 else Vector3(0, 0, -1)
	cam.look_at(look, up)
	for i in 4:
		await get_tree().process_frame
	var guard := 0
	var s := IstSehir.active
	# Yakın çevre: kameranın 150 m'si içindeki öğelerin istenen katmanı kurulana dek (en çok 240 kare)
	while guard < 150 and s and _yakin_eksik(s, at):
		await get_tree().process_frame
		guard += 1
	for we in get_tree().root.find_children("*", "WorldEnvironment", true, false):
		var env := (we as WorldEnvironment).environment
		if env and env.fog_enabled:
			print("ISTSIS kapatildi: ", we.get_path())
			env.fog_enabled = false
			env.volumetric_fog_enabled = false
	for i in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_jpg(out.path_join(name + ".jpg"), 0.82)
	var draws := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var tris := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	if name.begins_with("yer_") or name.begins_with("tur_") or name.ends_with("_15m"):
		_kirilim(at)
	print("ISTKARE %s at=(%.0f,%.0f,%.0f) cizim=%d ucgen=%d bekleme=%d kur_ms_max=%.1f" % [name, at.x, at.y, at.z, draws, tris, guard, s.stats["kur_ms_max"] if s else 0.0])


## Çizim kırılımı (kestirim): görünür, görünürlük aralığında ve kameranın önündeki geometri; öğe/küme başına yüzey
func _kirilim(at: Vector3) -> void:
	var s := IstSehir.active
	var groups := {}
	# Şehir dışındaki katmanlar (dünya, ordugâh, gemiler, hayat): dünyanın doğrudan çocuğu başına
	var ust: Node = s.get_parent()
	for gi in ust.find_children("*", "GeometryInstance3D", true, false):
		var g2 := gi as GeometryInstance3D
		if s.is_ancestor_of(g2) or not g2.is_visible_in_tree():
			continue
		var d2 := g2.global_position.distance_to(at)
		if (g2.visibility_range_end > 0.0 and d2 > g2.visibility_range_end) or d2 < g2.visibility_range_begin:
			continue
		var n2 := 1
		if g2 is MeshInstance3D and (g2 as MeshInstance3D).mesh:
			n2 = (g2 as MeshInstance3D).mesh.get_surface_count()
		var t2: Node = g2
		while t2.get_parent() != ust and t2.get_parent() != null:
			t2 = t2.get_parent()
		var k2 := "D:" + String(t2.name).left(18)
		groups[k2] = int(groups.get(k2, 0)) + n2
	for gi in s.find_children("*", "GeometryInstance3D", true, false):
		var g := gi as GeometryInstance3D
		if not g.is_visible_in_tree():
			continue
		var d := g.global_position.distance_to(at)
		if g.visibility_range_end > 0.0 and d > g.visibility_range_end:
			continue
		if d < g.visibility_range_begin:
			continue
		var n := 1
		if g is MeshInstance3D and (g as MeshInstance3D).mesh:
			n = (g as MeshInstance3D).mesh.get_surface_count()
		var top: Node = g
		while top.get_parent() != s:
			top = top.get_parent()
		var key := String(top.name)
		if key.begins_with("Ist_"):
			key = key.substr(4).get_slice("_", 0)
		elif key.begins_with("doku_"):
			key = "doku_" + key.get_slice("_", 1)
		elif top is MultiMeshInstance3D:
			key = "mm"
		elif top is MeshInstance3D:
			key = "agMI"
		groups[key] = int(groups.get(key, 0)) + n
	var arr: Array = []
	for k in groups:
		arr.append([groups[k], k])
	arr.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) > int(b[0]))
	print("ISTKIRILIM ", arr.slice(0, 16))


func _yakin_eksik(s: IstSehir, at: Vector3) -> bool:
	if s._queue.is_empty():
		return false
	for it: Dictionary in s.items:
		var p: Vector3 = it["pos"]
		if p.distance_to(at) - float(it["r"]) < 150.0:
			var want := int(it.get("want", 2))
			if want == 2 and it.get("no2", false):
				continue
			if it["have"][want] == null:
				return true
	return false


func _hava() -> void:
	var p := "tur_%d_" % tur
	for it: Dictionary in IstSehir.active.items:
		var id := String(it["id"])
		if id.begins_with("doku_") or id.begins_with("meydan_"):
			continue
		print("ISTYER %s %.0f %.0f %.0f %.2f" % [id, (it["pos"] as Vector3).x, (it["pos"] as Vector3).z, float(it["r"]), float(it["k"])])
	# Peter'in ilk karesi: Galata üstünden Haliç'in ötesinde yarımada
	await _shot_en(p + "galata", -480.0, 1950.0, 60.0, 200.0, 12.0)
	await _shot_en(p + "kara_disi", -5900.0, 300.0, 70.0, 80.0, 10.0)
	await _shot_en(p + "marmara", -1500.0, -3300.0, 70.0, 10.0, 10.0)
	await _shot_en(p + "sarayburnu", 1700.0, 900.0, 70.0, 250.0, 10.0)
	await _shot_en(p + "ucus70", -1500.0, 300.0, 70.0, 80.0, 25.0)
	await _shot_en(p + "tepe", -2000.0, 400.0, 2600.0 * IstGeo.S / 0.5, 0.0, 89.0, 62.0)
	if gece:
		return


const ESER_LISTE := ["ayasofya", "hipodrom", "konstantin", "havariyun", "bozdogan", "galata_kulesi", "blakherna", "romanos",
	"tauri", "arkadius", "studios", "khora", "pammakaristos", "halic_eugenios", "aya_irini", "sergios", "pantokrator", "tekfur",
	"altin_kapi", "aetios", "mokios", "aspar", "augustaion", "buyuk_saray"]

func _eserler() -> void:
	var s := IstSehir.active
	if s == null:
		return
	for it: Dictionary in s.items:
		var d: Dictionary = it["data"]
		if not String(it["id"]) in (eser_sec if not eser_sec.is_empty() else ESER_LISTE):
			continue
		var pp: Vector3 = it["pos"]
		var r := float(it["r"])
		var sz: Vector3 = d.get("gercek_olcu", Vector3(20, 20, 20))
		var h := sz.y * float(it["k"])
		await _shot("eser_%s_15m" % it["id"], pp + Vector3(r * 0.9 + 12.0, h + 15.0, r * 0.9 + 12.0), pp + Vector3(0, h * 0.4, 0), 60)
		await _shot("eser_%s_tepe" % it["id"], pp + Vector3(0, h + maxf(30.0, r * 2.2), 0.1), pp, 60)
		if a_uzak:
			await _shot("eser_%s_uzak" % it["id"], pp + Vector3(0, 700.0, 0.1), pp, 12)


func _yer() -> void:
	var p := "yer_%d_" % tur
	var s := IstSehir.active
	var by := {}
	for it: Dictionary in s.items:
		by[String(it["id"])] = it
	var g := func(x: float, z: float) -> Vector3:
		return Vector3(x, IstGeo.h(x, z) + 1.7, z)
	# Mese: Konstantin ile Tauri arasındaki revaklı dilimin ortası, cadde boyunca
	var m := IstGeo.yol("mese")
	if m.size() >= 4:
		var a := m[2].lerp(m[3], 0.35)
		var b := m[3]
		await _shot(p + "mese", g.call(a.x, a.y), g.call(b.x, b.y), 70)
	# Haliç iskelesi: iskele öğesinin kara yanından suya
	if by.has("halic_iskele"):
		var h := by["halic_iskele"]["holder"] as Node3D
		var at: Vector3 = h.transform * Vector3(0, 0, 40)
		await _shot(p + "halic_iskele", g.call(at.x, at.z), h.position + Vector3(0, 2, 0), 70)
	# Bostan köyü: Studios'a en yakın bostan/bağ yaması
	var best: Dictionary = {}
	var bd := INF
	var sp: Vector3 = by["studios"]["pos"] if by.has("studios") else Vector3(-2250, 0, 900)
	for it: Dictionary in s.items:
		if String(it["id"]).begins_with("doku_bostan") or String(it["id"]).begins_with("doku_bag"):
			var d := (it["pos"] as Vector3).distance_to(sp)
			if d < bd:
				bd = d
				best = it
	if not best.is_empty():
		var bp: Vector3 = best["pos"]
		await _shot(p + "bostan_koy", g.call(bp.x + 16, bp.z + 16), bp, 70)
	# Sur dibi: Romanos Kapısı'nın iç yanında, sura bakarak
	if by.has("romanos"):
		var h := by["romanos"]["holder"] as Node3D
		var at: Vector3 = h.transform * Vector3(30, 0, -28)
		await _shot(p + "sur_dibi", g.call(at.x, at.z), h.transform * Vector3(0, 8, 0), 70)
	if by.has("hipodrom"):
		var h := by["hipodrom"]["holder"] as Node3D
		var at: Vector3 = h.transform * Vector3(0, 0, 60)
		await _shot(p + "hipodrom", g.call(at.x, at.z), h.transform * Vector3(0, 3, -60), 70)
	if by.has("ayasofya"):
		var ap: Vector3 = by["ayasofya"]["pos"]
		await _shot(p + "ayasofya_bati", g.call(ap.x - 75, ap.z + 5), ap + Vector3(0, 14, 0), 70)
	# Çatıdan bakış: beş dükkânlı evin çatı sırtında (sandık 1,0 → tente 2,2 → saçak; IstEvler.climbs)
	var n := 0
	for hh: Dictionary in IstSehir.sokak.houses:
		if String(hh["tip"]) != "dukkan" or (int(hh["sira"]) % 97) != 3:
			continue
		var dm := IstEvler.dims(int(hh["v"]))
		var c: Vector2 = hh["c"]
		var fr: Vector2 = hh["on"]
		var y := IstGeo.h(fr.x, fr.y) + dm.y + IstEvler.RISE + 1.6
		var dir := (c - fr).normalized()
		await _shot(p + "cati_%d" % n, Vector3(c.x, y, c.y), Vector3(c.x + dir.x * 30.0, y - 4.0, c.y + dir.y * 30.0), 70)
		n += 1
		if n >= 5:
			break


# ---------------------------------------------------------------- denetim

func _denetim() -> void:
	var s := IstSehir.active
	if s == null:
		return
	var sk := IstSehir.sokak
	s.set_process(false)          # denetim boyunca akış kurduğumuz yakın katmanı boşaltmasın
	print("ISTDENETIM ev=%d sokak=%d doku=%d" % [sk.houses.size(), sk.streets.size(), sk.doku.size()])
	# 1) Evler arası aralık: aynı sıradan olmayan iki ev arasında 0 < aralık < 1,4 m (kaba: taban dikdörtgenleri)
	var grid := {}
	var rects: Array = []
	for h: Dictionary in sk.houses:
		var dm := IstEvler.dims(int(h["v"]))
		var yaw := float(h["yaw"])
		var u := Vector2(cos(yaw), -sin(yaw))
		var v := Vector2(sin(yaw), cos(yaw))
		var c: Vector2 = h["c"]
		rects.append([c, u, v, dm.x * 0.5, dm.z * 0.5 + IstEvler.OVER * 0.5, int(h["sira"])])
		var key := Vector2i(int(c.x / 20.0), int(c.y / 20.0))
		if not grid.has(key):
			grid[key] = []
		grid[key].append(rects.size() - 1)
	var dar := 0
	var ic := 0
	for i in rects.size():
		var a: Array = rects[i]
		var c: Vector2 = a[0]
		var key := Vector2i(int(c.x / 20.0), int(c.y / 20.0))
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				for j: int in grid.get(key + Vector2i(dx, dz), []):
					if j <= i:
						continue
					var b: Array = rects[j]
					var gap := _rect_gap(a, b)
					if gap < -0.05 and int(a[5]) != int(b[5]):
						ic += 1
					elif gap > 0.05 and gap < 1.4 and int(a[5]) != int(b[5]):
						dar += 1
	# 2) Havada/gömülü: evin cephe ortasındaki zemin ile tabanı farkı; arka köşe gömülü (> 1,2 m)
	var havada := 0
	var gomulu := 0
	for h: Dictionary in sk.houses:
		var fr: Vector2 = h["on"]
		var dm := IstEvler.dims(int(h["v"]))
		var yaw := float(h["yaw"])
		var bas := Basis(Vector3.UP, yaw)
		var c: Vector2 = h["c"]
		var y := IstGeo.h(fr.x, fr.y)
		for o: Vector3 in [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5)]:
			var q := Vector3(c.x, 0, c.y) + bas * (o * Vector3(dm.x, 0, dm.z))
			if IstGeo.h(q.x, q.z) - y > 1.2:
				gomulu += 1
	# 3) Çatıya yol: her sırada en az bir dükkânlı ev (sandık → tente → duvar)
	var sira_yol := {}
	var siralar := {}
	for h: Dictionary in sk.houses:
		siralar[int(h["sira"])] = true
		if String(h["tip"]) == "dukkan":
			sira_yol[int(h["sira"])] = true
	print("ISTAUDIT v2 ev=%d sira=%d ic_ice=%d dar=%d havada=%d gomulu_arka=%d cati_yolu_eksik_sira=%d" % [rects.size(), siralar.size(), ic, dar, havada, gomulu, siralar.size() - sira_yol.size()])
	# 4) Sur üstü yürüyüş: her hattın dilimleri boyunca yürüme yolu hizasından aşağı ışın (1 m adım); boşluk ve basamak
	await get_tree().physics_frame
	var space := get_world_3d().direct_space_state
	for ad: String in IstSehir.HAT:
		var pl := IstSehir._sade(IstGeo.yol(ad))
		if pl.size() < 2:
			continue
		# Bu hattın bütün dilimlerini lod 0 kur (çarpışma)
		for it: Dictionary in s.items:
			var fx: Dictionary = IstSehir.YER2.get(String(it["id"]), {})
			if String(it.get("hat", "")) == ad or String(fx.get("hat", "")) == ad:
				s._build(it, 1)
				s._build(it, 0)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var prev := NAN
		var bosluk := 0
		var runs: Array = []
		var run0 := -1.0
		var sacc := 0.0
		var basamak := 0
		var adim := 0
		var maxstep := 0.0
		for i in pl.size() - 1:
			var a := pl[i]
			var b := pl[i + 1]
			var L := a.distance_to(b)
			var n := int(L / 0.25)
			for k in n:
				var q := a.lerp(b, float(k) / n)
				var from := Vector3(q.x, IstGeo.h(q.x, q.y) + 40.0, q.y)
				var rq := PhysicsRayQueryParameters3D.create(from, from - Vector3(0, 80, 0))
				var hit := space.intersect_ray(rq)
				adim += 1
				var sq := sacc + float(k) / n * L
				if hit.is_empty() or (hit["position"] as Vector3).y < IstGeo.h(q.x, q.y) + 2.0:
					bosluk += 1
					prev = NAN
					if run0 < 0.0:
						run0 = sq
					continue
				if run0 >= 0.0:
					if sq - run0 > 3.0:
						runs.append("%.0f+%.0f@(%.0f,%.0f)" % [run0, sq - run0, q.x, q.y])
					run0 = -1.0
				var y := (hit["position"] as Vector3).y
				if not is_nan(prev):
					var dy := absf(y - prev)
					maxstep = maxf(maxstep, dy if dy < 3.0 else 0.0)
					if dy > 0.45 and dy < 3.0:
						basamak += 1
				prev = y
			sacc += L
		print("ISTSUR %s adim=%d bosluk=%d yuksek_basamak=%d en_buyuk_basamak=%.2f" % [ad, adim, bosluk, basamak, maxstep])
		print("ISTSURBOS %s %s" % [ad, " ".join(runs.slice(0, 40))])
	# 5) Konma noktaları gerçek çarpışmalı yüzeyde mi
	var fd := IstSehir.flight_data_v2()
	var ok := 0
	var bad: Array = []
	for pr: Array in fd["perches"]:
		var p: Vector3 = pr[1]
		var rq := PhysicsRayQueryParameters3D.create(p + Vector3(0, 1.0, 0), p - Vector3(0, 2.0, 0))
		var hit := space.intersect_ray(rq)
		if hit.is_empty():
			bad.append(pr[0])
		else:
			ok += 1
	print("ISTKONMA toplam=%d carpismali=%d eksik=%s" % [fd["perches"].size(), ok, str(bad)])
	for lm: Array in fd["landmarks"]:
		print("ISTESER %s p=%s r=%.0f" % [lm[0], str(lm[1]), lm[2]])
	# Formlar (kâğıt): altında 3 m içinde gerçek bir yüzey (eserin lod 0'ı kurulu olmalı: yakındakileri kur)
	var fok := 0
	var fbad: Array = []
	for f: Array in fd["forms"]:
		var p: Vector3 = f[1]
		for it: Dictionary in s.items:
			if (it["pos"] as Vector3).distance_to(p) < float(it["r"]) + 40.0 and not it.has("hat") and String(it.get("mod", "")) != "doku":
				s._build(it, 0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	space = get_world_3d().direct_space_state
	for f: Array in fd["forms"]:
		var p: Vector3 = f[1]
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(p + Vector3(0, 0.5, 0), p - Vector3(0, 3.0, 0)))
		if hit.is_empty():
			fbad.append("%d@%s" % [f[0], str(p)])
		else:
			fok += 1
	print("ISTFORM toplam=%d yuzeyde=%d eksik=%s" % [fd["forms"].size(), fok, str(fbad)])
	s.set_process(true)


static func _rect_gap(a: Array, b: Array) -> float:
	# İki döndürülmüş dikdörtgen arası (ayırma ekseni; kaba: dört eksende en büyük ayrım)
	var best := -INF
	for ax: Vector2 in [a[1], a[2], b[1], b[2]]:
		var pa := _proj(a, ax)
		var pb := _proj(b, ax)
		var sep := maxf(pb.x - pa.y, pa.x - pb.y)
		best = maxf(best, sep)
	return best


static func _proj(r: Array, ax: Vector2) -> Vector2:
	var c: Vector2 = r[0]
	var u: Vector2 = r[1]
	var v: Vector2 = r[2]
	var e := absf(u.dot(ax)) * float(r[3]) + absf(v.dot(ax)) * float(r[4])
	var m := c.dot(ax)
	return Vector2(m - e, m + e)


# ---------------------------------------------------------------- sur üstü yürüyüş: gerçek oyuncu (Player, CharacterBody3D)

## Her hattın sadeleştirilmiş çizgisi boyunca oyuncu yürüme yolunun üstünde koşturulur: her karede 6 m ilerideki hat noktasına
## döner, "ileri + koş" basılı. Düşüş: oyuncu yürüme yolundan > 2,5 m aşağı iner (zemine/peribolosa) → kayıt, 8 m ileride yürüme
## yoluna geri konur. Takılma: 4 sn'de < 1 m ilerleme → kayıt, 6 m ileri konur. Satır: ISTSURYURU hat= uzunluk= yurunen= dusme= takilma=
var _pl: CharacterBody3D

func _sur_yuru() -> void:
	var s := IstSehir.active
	s.set_process(false)
	var P = load("res://scripts/player/player.gd")
	_pl = P.new()
	add_child(_pl)
	if dunya and "izle" in dunya:
		dunya.izle = _pl
	Engine.time_scale = 3.0
	var hatlar: Array = ["kara_suru", "blakherna_suru", "marmara_suru", "halic_suru", "galata_suru"]
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--hat="):
			hatlar = Array(a.substr(6).split(","))
	for ad: String in hatlar:
		var pl := IstSehir._sade(IstGeo.yol(ad))
		if pl.size() < 2:
			continue
		var hat_len := 0.0
		for i in pl.size() - 1:
			hat_len += pl[i].distance_to(pl[i + 1])
		var lim := hat_len
		for a: String in OS.get_cmdline_user_args():
			if a.begins_with("--surboy="):
				lim = minf(hat_len, a.substr(9).to_float())
		# Dilim dilim: her ADIM metrede bir yürüme yolunun üstüne konur, bir sonraki noktaya en çok 8 sn yürür.
		# ok: 1,5 m yakına vardı ve yürüme yolundan > 2,5 m düşmedi; dus: düştü; tak: varamadı.
		var ADIM := 15.0
		var ok := 0
		var dus := 0
		var tak := 0
		var zipla := 0
		var kotu: Array = []
		var t_hat := Time.get_ticks_msec()
		var sv := 4.0
		for a: String in OS.get_cmdline_user_args():
			if a.begins_with("--surbas="):
				sv = a.substr(9).to_float()
		var kar := 0
		while sv < lim - ADIM:
			await _sur_koy(ad, pl, sv)
			var y0 := _pl.global_position.y
			var hedef := _hat_nokta(pl, sv + ADIM)
			var sonuc := "tak"
			var t := 0.0
			var son_p := _pl.global_position
			var son_tt := 0.0
			while t < 8.0:
				await get_tree().physics_frame
				t += get_physics_process_delta_time()
				# takılınca zıpla (oyuncunun yapabildiği: JUMP 3,6 m/sn ≈ 0,66 m)
				if t - son_tt > 0.4:
					if Vector2(_pl.global_position.x - son_p.x, _pl.global_position.z - son_p.z).length() < 0.15 and _pl.is_on_floor():
						_pl.velocity.y = 3.6
						zipla += 1
					son_p = _pl.global_position
					son_tt = t
				var p2 := Vector2(_pl.global_position.x, _pl.global_position.z)
				var s_now := float(IstSehir._snap(pl, p2)["s"])
				var hn := _hat_nokta(pl, minf(s_now + 3.0, sv + ADIM))
				var to := Vector3(hn.x - p2.x, 0, hn.y - p2.y)
				_pl.rotation.y = atan2(-to.x, -to.z)
				_pl.set("frozen", false)
				_pl.set("move_mode", "script")
				_pl.set("script_velocity", to.normalized() * 3.2)
				if _pl.global_position.y < y0 - 2.5:
					sonuc = "dus"
					break
				if p2.distance_to(hedef) < 1.5 or s_now > sv + ADIM - 1.0:
					sonuc = "ok"
					break
			if kar < 2:
				print("ISTSURDBG p0y=%.1f p=%s hedef=%s vel=%s yerde=%s fizik=%s pinned=%s tp=%s" % [y0, str(_pl.global_position), str(hedef), str(_pl.velocity), _pl.is_on_floor(), _pl.is_physics_processing(), str(_pl.get("pinned")), str(_pl.get("_tp_hold"))])
			_pl.set("script_velocity", Vector3.ZERO)
			match sonuc:
				"ok": ok += 1
				"dus": dus += 1
				_: tak += 1
			if sonuc != "ok":
				var q := _hat_nokta(pl, sv)
				if kotu.size() < 6 and DisplayServer.get_name() != "headless":
					var pp := _pl.global_position
					var bk := Vector3(q.x - hedef.x, 0, q.y - hedef.y).normalized()
					var yan := bk.cross(Vector3.UP)
					cam.make_current()
					await _shot("suryuru_%s_%d" % [ad, kotu.size()], pp + bk * 4.0 + yan * 5.0 + Vector3(0, 6.0, 0), pp + Vector3(0, 0.8, 0), 70)
				var pp2 := _pl.global_position
				var fw := Vector3(hedef.x - pp2.x, 0, hedef.y - pp2.z).normalized()
				var sp3 := get_world_3d().direct_space_state
				var info := ""
				for hh: float in [0.25, 0.9, 1.6]:
					var rq3 := PhysicsRayQueryParameters3D.create(pp2 + Vector3(0, hh, 0), pp2 + Vector3(0, hh, 0) + fw * 1.2)
					rq3.exclude = [_pl.get_rid()]
					var h3 := sp3.intersect_ray(rq3)
					var ek := ""
					if not h3.is_empty() and h3["collider"] is Node3D:
						var cb := h3["collider"] as Node3D
						var sl: Node3D = cb
						while sl != null and not String(sl.name).begins_with("SurDilimi") and not String(sl.name).begins_with("IstSurlar"):
							sl = sl.get_parent() as Node3D
						for cs in cb.get_children():
							if cs is CollisionShape3D and (cs as CollisionShape3D).shape is BoxShape3D:
								var lp: Vector3 = sl.global_transform.affine_inverse() * (cs as Node3D).global_position if sl else Vector3.ZERO
								ek += " kutu=%s yerel=%s ad=%s" % [str(((cs as CollisionShape3D).shape as BoxShape3D).size), str(lp), String(cb.name)]
					info += "|%.2f:%s%s" % [hh, ("%s@%.2f" % [String((h3["collider"] as Node).get_parent().name) if h3["collider"] is Node else "?", (h3["position"] as Vector3).distance_to(pp2 + Vector3(0, hh, 0))]) if not h3.is_empty() else "-", ek]
				for it3: Dictionary in IstSehir.active.hat_items:
					if String(it3.get("hat", "")) == ad and it3.has("s0") and float(it3["s1"]) > sv - 20.0 and float(it3["s0"]) < sv + 35.0:
						info += " [%s s=%.0f-%.0f walk=%.1f]" % [String(it3["id"]), float(it3["s0"]), float(it3["s1"]), float(it3.get("walk", 0.0))]
				var sn3 := IstSehir._snap(pl, Vector2(pp2.x, pp2.z))
				var yanal := (Vector2(pp2.x, pp2.z) - (sn3["p"] as Vector2)).length()
				kotu.append("%s@%.0f(%.0f,%.0f,y%.1f) son=(%.1f,%.1f,%.1f) yanal=%.2f yerde=%s %s" % [sonuc, sv, q.x, q.y, y0, pp2.x, pp2.y, pp2.z, yanal, _pl.is_on_floor(), info])
			sv += ADIM
			kar += 1
			if kar % 20 == 0:
				print("ISTSURILERLE %s s=%.0f/%.0f ok=%d dus=%d tak=%d" % [ad, sv, lim, ok, dus, tak])
		print("ISTSURYURU hat=%s uzunluk=%.0f sinanan=%.0f dilim=%d gecti=%d dusme=%d takilma=%d zipla=%d gercek_ms=%d" % [ad, hat_len, minf(sv, lim), ok + dus + tak, ok, dus, tak, zipla, Time.get_ticks_msec() - t_hat])
		print("ISTSURYURU_OLAY %s %s" % [ad, " ".join(kotu.slice(0, 80))])
		for it: Dictionary in s.items:
			if String(it.get("hat", "")) == ad or String((IstSehir.YER2.get(String(it["id"]), {}) as Dictionary).get("hat", "")) == ad:
				for l in 2:
					if it["have"][l] != null:
						(it["have"][l] as Node3D).queue_free()
						it["have"][l] = null
				s._show(it)
	Engine.time_scale = 1.0
	_pl.queue_free()
	s.set_process(true)


func _hat_nokta(pl: PackedVector2Array, sv: float) -> Vector2:
	var acc := 0.0
	for i in pl.size() - 1:
		var L := pl[i].distance_to(pl[i + 1])
		if acc + L >= sv:
			return pl[i].lerp(pl[i + 1], clampf((sv - acc) / L, 0.0, 1.0))
		acc += L
	return pl[pl.size() - 1]


func _sur_lod(ad: String, at: Vector3) -> void:
	var s := IstSehir.active
	for it: Dictionary in s.items:
		var fx: Dictionary = IstSehir.YER2.get(String(it["id"]), {})
		if String(it.get("hat", "")) != ad and String(fx.get("hat", "")) != ad:
			continue
		var d := Vector2((it["pos"] as Vector3).x - at.x, (it["pos"] as Vector3).z - at.z).length() - float(it["r"])
		if d < 120.0:
			if it["have"][0] == null:
				s._build(it, 1)
				s._build(it, 0)
				it["want"] = 0
				s._show(it)
		elif d > 260.0 and it["have"][0] != null:
			(it["have"][0] as Node3D).queue_free()
			it["have"][0] = null
			it["want"] = 2
			s._show(it)


## Oyuncuyu hattın sv noktasında yürüme yolunun üstüne koy (yukarıdan ışın; en üst yüzey)
func _sur_koy(ad: String, pl: PackedVector2Array, sv: float) -> void:
	var q := _hat_nokta(pl, sv)
	_sur_lod(ad, Vector3(q.x, 0, q.y))
	if dunya and dunya.has_method("carpisma_yenile"):
		dunya.call("carpisma_yenile", Vector3(q.x, IstGeo.h(q.x, q.y), q.y))
	for i in 3:
		await get_tree().physics_frame
	var sp := get_world_3d().direct_space_state
	# Işın yürüme yolunun 1,6 m üstünden (kule tepesine değil yürüme yoluna konsun): en yakın hat öğesinin "walk" değeri
	var wy := IstGeo.h(q.x, q.y) + 45.0
	var bd := INF
	for it: Dictionary in IstSehir.active.hat_items:
		if String(it.get("hat", "")) == ad and it.has("walk"):
			var dd := Vector2((it["pos"] as Vector3).x - q.x, (it["pos"] as Vector3).z - q.y).length()
			if dd < bd:
				bd = dd
				wy = float(it["walk"]) + 1.6
	var from := Vector3(q.x, wy, q.y)
	var rq := PhysicsRayQueryParameters3D.create(from, from - Vector3(0, 90, 0))
	rq.exclude = [_pl.get_rid()]
	var hit := sp.intersect_ray(rq)
	var y := IstGeo.h(q.x, q.y) + 12.0
	if not hit.is_empty():
		y = (hit["position"] as Vector3).y
	_pl.global_position = Vector3(q.x, y + 1.0, q.y)
	_pl.velocity = Vector3.ZERO
	for i in 4:
		await get_tree().physics_frame


## Yan görev işaretleri: her eserin işaret noktasına kırmızı küre; 45° yukarıdan kare (işaret eserin tam üstünde mi)
func _isaretler() -> void:
	var fd := IstSehir.flight_data_v2()
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(1, 0.1, 0.1)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var i := 0
	for lm: Array in fd["landmarks"]:
		var p: Vector3 = lm[1]
		var sp := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 1.6
		sm.height = 3.2
		sp.mesh = sm
		sp.material_override = m
		add_child(sp)
		sp.global_position = p
		var off := Vector3(1, 0, 1).normalized() * (float(lm[2]) * 0.9 + 25.0) + Vector3(0, 14.0, 0)
		await _shot("isaret_%02d_%s" % [i, String(lm[0]).to_lower()], p + off, p - Vector3(0, 10.0, 0), 60)
		sp.queue_free()
		i += 1


# ---------------------------------------------------------------- oynanış denetimi (kalite notu 9)

## Beş mahallede (80 × 80 m): lod 0 ve ev çarpışmaları kurulur; 0,5 m ızgarada yukarıdan ışın.
##   delik: karada hiçbir çarpışmaya değmeyen ışın ya da zeminin > 0,5 m altına inen vuruş
##   kapali_cep: zemin hizasındaki (vuruş − zemin < 0,3 m) hücreden sokağa (IstSokak hücre 1) yürüyüş + zıplamayla
##     (komşu hücreye en çok 1,1 m çıkış, iniş serbest) ulaşılamıyor (oyuncu oraya düşerse çıkamaz)
##   cati_ulasilamaz: zeminden > 2,5 m yüksek hücrelerden sokaktan bu kuralla ulaşılamayanların oranı (tırmanma kipi hariç)
## Çatıdan çatıya: aynı sıradaki iki komşu evin çatısında oyuncu (Player, script yürüyüşü) A'dan B'ye 6 sn yürür.
func _oyun_denetim() -> void:
	var s := IstSehir.active
	s.set_process(false)
	var sk := IstSehir.sokak
	var hs: Array = sk.houses.duplicate()
	hs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["c"] as Vector2).x < (b["c"] as Vector2).x)
	var merkezler: Array = []
	for q: float in [0.1, 0.3, 0.5, 0.7, 0.9]:
		merkezler.append((hs[int(q * (hs.size() - 1))] as Dictionary)["c"])
	var P = load("res://scripts/player/player.gd")
	_pl = P.new()
	add_child(_pl)
	if dunya and "izle" in dunya:
		dunya.izle = _pl
	var cati_ok := 0
	var cati_n := 0
	for mi in merkezler.size():
		var m: Vector2 = merkezler[mi]
		var mah := IstGeo.mahalle(m.x, m.y)
		if dunya and dunya.has_method("carpisma_yenile"):
			dunya.call("carpisma_yenile", Vector3(m.x, IstGeo.h(m.x, m.y), m.y))
		for c: Dictionary in s._cells0:
			var cc: Vector3 = c["c"]
			if Vector2(cc.x - m.x, cc.z - m.y).length() < 110.0 and not c["up"]:
				s._cell_up(c)
		for it: Dictionary in s.items:
			var pp: Vector3 = it["pos"]
			if Vector2(pp.x - m.x, pp.z - m.y).length() - float(it["r"]) < 70.0:
				s._build(it, 0)
		for i in 4:
			await get_tree().physics_frame
		var sp := get_world_3d().direct_space_state
		var N := 160
		var top := PackedFloat32Array()
		top.resize(N * N)
		var gr := PackedFloat32Array()
		gr.resize(N * N)
		var delik := 0
		var kara := 0
		for j in N:
			for i in N:
				var x := m.x - 40.0 + i * 0.5 + 0.25
				var z := m.y - 40.0 + j * 0.5 + 0.25
				var g := IstGeo.h(x, z)
				gr[j * N + i] = g
				if IstGeo.su(x, z):
					top[j * N + i] = NAN
					continue
				kara += 1
				var rq := PhysicsRayQueryParameters3D.create(Vector3(x, g + 60.0, z), Vector3(x, g - 4.0, z))
				rq.exclude = [_pl.get_rid()]
				var h := sp.intersect_ray(rq)
				if h.is_empty() or (h["position"] as Vector3).y < g - 0.5:
					delik += 1
					top[j * N + i] = NAN
				else:
					top[j * N + i] = (h["position"] as Vector3).y
		# Sokaktan ulaşılabilirlik (ileri) ve sokağa dönebilirlik (geri)
		var ileri := PackedByteArray()
		ileri.resize(N * N)
		var geri := PackedByteArray()
		geri.resize(N * N)
		var q1: Array = []
		for k in N * N:
			var x := m.x - 40.0 + (k % N) * 0.5 + 0.25
			var z := m.y - 40.0 + (k / N) * 0.5 + 0.25
			if not is_nan(top[k]) and top[k] - gr[k] < 0.3 and sk.cell(x, z) == 1:
				ileri[k] = 1
				geri[k] = 1
				q1.append(k)
		var q2: Array = q1.duplicate()
		while not q1.is_empty():
			var u: int = q1.pop_back()
			for d: int in [1, -1, N, -N]:
				var v := u + d
				if v < 0 or v >= N * N or (absi(d) == 1 and (v / N) != (u / N)) or ileri[v] == 1 or is_nan(top[v]):
					continue
				if top[v] - top[u] <= 1.1 and top[u] - top[v] <= 8.0:
					ileri[v] = 1
					q1.append(v)
		while not q2.is_empty():
			var u: int = q2.pop_back()
			for d: int in [1, -1, N, -N]:
				var v := u + d
				if v < 0 or v >= N * N or (absi(d) == 1 and (v / N) != (u / N)) or geri[v] == 1 or is_nan(top[v]):
					continue
				# v'den u'ya geçilebiliyor mu (v → u)
				if top[u] - top[v] <= 1.1 and top[v] - top[u] <= 8.0:
					geri[v] = 1
					q2.append(v)
		var cep := 0
		var cati := 0
		var cati_ulas := 0
		var cep_ornek := ""
		for k in N * N:
			if is_nan(top[k]):
				continue
			var yuk := top[k] - gr[k]
			if yuk < 0.3 and geri[k] == 0:
				cep += 1
				if cep_ornek == "":
					cep_ornek = "(%.0f,%.0f)" % [m.x - 40.0 + (k % N) * 0.5, m.y - 40.0 + (k / N) * 0.5]
			if yuk > 2.5:
				cati += 1
				if ileri[k] == 1:
					cati_ulas += 1
		print("ISTDELIK mah=%s merkez=(%.0f,%.0f) kara_hucre=%d delik=%d kapali_cep_hucre=%d ornek=%s cati_hucre=%d sokaktan_yuruyerek=%.0f%%" % [String(mah.get("ad", "")), m.x, m.y, kara, delik, cep, cep_ornek, cati, 100.0 * cati_ulas / maxf(cati, 1)])
		# Çatıdan çatıya: bu bölgedeki aynı sıradan iki komşu ev
		var cift: Array = []
		for a: Dictionary in sk.houses:
			if (a["c"] as Vector2).distance_to(m) > 35.0:
				continue
			for b: Dictionary in sk.houses:
				if b == a or int(b["sira"]) != int(a["sira"]):
					continue
				var da := IstEvler.dims(int(a["v"]))
				var db := IstEvler.dims(int(b["v"]))
				var dd := (a["c"] as Vector2).distance_to(b["c"])
				if dd < (da.x + db.x) * 0.5 + 0.3 and dd > 2.0:
					cift = [a, b]
					break
			if not cift.is_empty():
				break
		if cift.is_empty():
			print("ISTCATI mah=%s cift_yok" % mah.get("ad", ""))
			continue
		var A: Dictionary = cift[0]
		var B: Dictionary = cift[1]
		var ca: Vector2 = A["c"]
		var cb: Vector2 = B["c"]
		var ra := sp.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(ca.x, 80, ca.y), Vector3(ca.x, -5, ca.y)))
		if ra.is_empty():
			print("ISTCATI mah=%s A_cati_yok" % mah.get("ad", ""))
			continue
		_pl.global_position = (ra["position"] as Vector3) + Vector3(0, 0.6, 0)
		_pl.velocity = Vector3.ZERO
		for i in 6:
			await get_tree().physics_frame
		var y_a := _pl.global_position.y
		var t := 0.0
		_pl.set("move_mode", "script")
		while t < 6.0:
			await get_tree().physics_frame
			t += get_physics_process_delta_time()
			var p2 := Vector2(_pl.global_position.x, _pl.global_position.z)
			var to := Vector3(cb.x - p2.x, 0, cb.y - p2.y)
			_pl.rotation.y = atan2(-to.x, -to.z)
			_pl.set("script_velocity", to.normalized() * 2.4 if to.length() > 0.4 else Vector3.ZERO)
		_pl.set("script_velocity", Vector3.ZERO)
		var son := _pl.global_position
		var ok := Vector2(son.x, son.z).distance_to(cb) < 1.5 and son.y > IstGeo.h(cb.x, cb.y) + 2.5
		cati_n += 1
		if ok:
			cati_ok += 1
		print("ISTCATI mah=%s A=(%.0f,%.0f) B=(%.0f,%.0f) y_a=%.1f son=(%.1f,%.1f,%.1f) zemin_b=%.1f %s" % [mah.get("ad", ""), ca.x, ca.y, cb.x, cb.y, y_a, son.x, son.y, son.z, IstGeo.h(cb.x, cb.y), "GECTI" if ok else "KALDI"])
		if DisplayServer.get_name() != "headless":
			cam.make_current()
			await _shot("oyun_cati_%d" % mi, son + Vector3(6, 5, 6), son, 70)
	print("ISTCATI toplam=%d gecti=%d" % [cati_n, cati_ok])
	_pl.queue_free()
	s.set_process(true)


## Zaman dilimi ölçümü: kamera sabit bir yolda (Romanos'un iç yanı → Mese → Ayasofya → Galata, 40 m ve yerde 1,7 m)
## 18 m/sn ile ilerler; akış kendi kuyruğuyla kurar. Sonda: ISTYAVAS (6 ms'yi aşan tek işler, kurma+pişirme) ve
## kare başına akış süresi dağılımı (ISTAKIS).
func _yavas_yol() -> void:
	var s := IstSehir.active
	s.stats.erase("yavas")
	s.stats.erase("yavas_pis")
	s.stats["kur_ms_max"] = 0.0
	var yol: Array = [Vector3(-4400, 900, 40), Vector3(-3000, 300, 40), Vector3(-1554, 211, 40), Vector3(-756, -11, 20),
		Vector3(-100, 0, 20), Vector3(-300, 900, 40), Vector3(-480, 1900, 30), Vector3(-1200, 300, 1.7), Vector3(-600, 0, 1.7)]
	var dts: Array = []
	for i in yol.size() - 1:
		var a: Vector3 = yol[i]
		var b: Vector3 = yol[i + 1]
		var A := _gw(a.x, a.y) + Vector3(0, a.z, 0)
		var B := _gw(b.x, b.y) + Vector3(0, b.z, 0)
		var L := A.distance_to(B)
		var n := int(L / (18.0 / 30.0))
		for k in n:
			var p := A.lerp(B, float(k) / n)
			p.y = maxf(p.y, IstGeo.h(p.x, p.z) + 1.7)
			cam.global_position = p
			cam.look_at(p + (B - A).normalized() + Vector3(0, -0.05, 0), Vector3.UP)
			var t0 := Time.get_ticks_usec()
			await get_tree().process_frame
			dts.append((Time.get_ticks_usec() - t0) / 1000.0)
	dts.sort()
	print("ISTAKIS kare=%d ortanca_ms=%.1f p95_ms=%.1f p99_ms=%.1f en_cok_ms=%.1f" % [dts.size(), dts[dts.size() / 2], dts[int(dts.size() * 0.95)], dts[int(dts.size() * 0.99)], dts[dts.size() - 1]])
	print("ISTYAVAS ", s.stats.get("yavas", {}))
	print("ISTYAVAS_PIS ", s.stats.get("yavas_pis", {}))
	print("ISTBAGLA bagla_ms_max=%.1f kur_ms_max=%.1f" % [float(s.stats.get("bagla_ms_max", 0.0)), float(s.stats["kur_ms_max"])])
