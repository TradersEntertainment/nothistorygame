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
var cam: Camera3D
var root: Node3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
		elif a.begins_with("--tur="):
			tur = a.substr(6).to_int()
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
	var dscr := load("res://scripts/world/ist/dunya.gd") if ResourceLoader.exists("res://scripts/world/ist/dunya.gd") else null
	if dscr != null:
		dscr.call("build", root, gece, Vector3.ZERO)
	else:
		IstSehir.attach_v2(root, gece)
		_kaba_dunya()
	print("ISTKUR ms=%d dunya=%s" % [Time.get_ticks_msec() - t0, "IstDunya" if dscr else "sonda"])
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
	if set_ in ["denetim", "hepsi"]:
		await _denetim()
	if set_ in ["hava", "hepsi"]:
		await _hava()
	if set_ in ["eser", "hepsi"]:
		await _eserler()
	if set_ in ["yer", "hepsi"]:
		await _yer()
	if IstSehir.active and IstSehir.active.stats.has("yavas"):
		print("ISTYAVAS ", IstSehir.active.stats["yavas"])
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
	while guard < 240 and s and _yakin_eksik(s, at):
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
	if name.begins_with("yer_"):
		_kirilim(at)
	print("ISTKARE %s at=(%.0f,%.0f,%.0f) cizim=%d ucgen=%d bekleme=%d kur_ms_max=%.1f" % [name, at.x, at.y, at.z, draws, tris, guard, s.stats["kur_ms_max"] if s else 0.0])


## Çizim kırılımı (kestirim): görünür, görünürlük aralığında ve kameranın önündeki geometri; öğe/küme başına yüzey
func _kirilim(at: Vector3) -> void:
	var s := IstSehir.active
	var groups := {}
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
	print("ISTKIRILIM ", arr.slice(0, 12))


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
	# Peter'in ilk karesi: Galata üstünden Haliç'in ötesinde yarımada
	await _shot_en(p + "galata", -480.0, 1950.0, 60.0, 200.0, 12.0)
	await _shot_en(p + "kara_disi", -5900.0, 300.0, 70.0, 80.0, 10.0)
	await _shot_en(p + "marmara", -1500.0, -3300.0, 70.0, 10.0, 10.0)
	await _shot_en(p + "sarayburnu", 1700.0, 900.0, 70.0, 250.0, 10.0)
	await _shot_en(p + "ucus70", -1500.0, 300.0, 70.0, 80.0, 25.0)
	await _shot_en(p + "tepe", -2000.0, 400.0, 2600.0, 0.0, 89.0, 62.0)
	if gece:
		return


func _eserler() -> void:
	var s := IstSehir.active
	if s == null:
		return
	for it: Dictionary in s.items:
		var d: Dictionary = it["data"]
		if not d.get("gorev", false) and not String(it["id"]) in ["ayasofya", "blakherna"]:
			continue
		var pp: Vector3 = it["pos"]
		var r := float(it["r"])
		var sz: Vector3 = d.get("gercek_olcu", Vector3(20, 20, 20))
		var h := sz.y * float(it["k"])
		await _shot("eser_%s_15m" % it["id"], pp + Vector3(r * 0.9 + 12.0, h + 15.0, r * 0.9 + 12.0), pp + Vector3(0, h * 0.4, 0), 60)
		await _shot("eser_%s_tepe" % it["id"], pp + Vector3(0, h + maxf(30.0, r * 2.2), 0.1), pp, 60)


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
