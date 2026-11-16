extends Node3D
## BİTKİ sondası (4. tur): her tür nötr zeminde 5 m (lod 0), 30 m (lod 1), 150 m (lod 2) karesi + sayımlar.
##   xvfb-run godot --path . --resolution 640x360 res://tests/_ist/bitki_kit_sonda.tscn -- shots=KLASÖR [gece=1]
## Aynı betik ÖNCE (taban) çalışma kopyasında da koşar: kit yoksa yalnız eski kurucular (IstBitki.tree_mesh,
## Scenery.cypress_mesh / plane_tree_mesh) çizilir. Çıktı: ISTBITKI tur=… lod=… ucgen=… beyaz=… satırları.
const KIT := "res://scripts/level/bitki_kit.gd"
const TURLER := ["cinar", "servi", "fistik_cami", "zeytin", "incir", "dut", "ihlamur", "nar", "ayva", "erguvan",
	"badem", "erik", "kiraz", "defne", "cali", "kutuk", "eski_servi", "eski_cinar"]
const UZAK := [5.0, 30.0, 150.0]

var _shots := ""
var _gece := false
var _ozne: Node3D
var _cam: Camera3D
var _kit: GDScript


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"shots": _shots = kv[1]
			"gece": _gece = kv[1] == "1"
	if ResourceLoader.exists(KIT):
		_kit = load(KIT)
	_dunya()
	_kos.call_deferred()


func _dunya() -> void:
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color("6c6a4e")
	gm.roughness = 1.0
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(1200, 1200)
	mi.mesh = pm
	mi.material_override = gm
	add_child(mi)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -35, 0) if not _gece else Vector3(-30, 120, 0)
	sun.light_color = Color(1.0, 0.95, 0.85) if not _gece else Color(0.55, 0.62, 0.85)
	sun.light_energy = 1.1 if not _gece else 0.25
	sun.shadow_enabled = true
	add_child(sun)
	var env := Environment.new()
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	psm.sky_top_color = Color("5e92c8") if not _gece else Color("0a1020")
	psm.sky_horizon_color = Color("bcd4e4") if not _gece else Color("1a2238")
	psm.ground_horizon_color = psm.sky_horizon_color
	sky.sky_material = psm
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.6 if not _gece else 0.3
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	_cam = Camera3D.new()
	_cam.fov = 60
	_cam.far = 2000
	add_child(_cam)
	_cam.current = true


func _mesh(tur: String, lod: int) -> Mesh:
	if tur == "eski_servi":
		return Scenery.cypress_mesh()
	if tur == "eski_cinar":
		return Scenery.plane_tree_mesh()
	if IstBitki.AGAC.has(tur):
		return IstBitki.tree_mesh(tur, lod)
	if _kit:
		return _kit.call("agac", tur, lod)
	return null


func _tris(m: Mesh) -> int:
	var t := 0
	for s in m.get_surface_count():
		var arr := m.surface_get_arrays(s)
		var idx = arr[Mesh.ARRAY_INDEX]
		if idx != null and (idx as PackedInt32Array).size() > 0:
			t += (idx as PackedInt32Array).size() / 3
		else:
			t += (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return t


func _beyaz(m: Mesh) -> int:
	var n := 0
	for s in m.get_surface_count():
		var cs = m.surface_get_arrays(s)[Mesh.ARRAY_COLOR]
		if cs == null:
			continue
		for c: Color in cs:
			if maxf(c.r, maxf(c.g, c.b)) > 0.92:
				n += 1
	return n


func _kos() -> void:
	var toplam_beyaz := 0
	for tur: String in TURLER:
		for li in 3:
			var m := _mesh(tur, li)
			if m == null:
				print("ISTBITKI tur=%s lod=%d yok" % [tur, li])
				continue
			var bz := _beyaz(m)
			toplam_beyaz += bz
			print("ISTBITKI tur=%s lod=%d ucgen=%d beyaz=%d" % [tur, li, _tris(m), bz])
			if _shots == "":
				continue
			if _ozne:
				_ozne.queue_free()
			_ozne = Node3D.new()
			add_child(_ozne)
			var mi := MeshInstance3D.new()
			mi.mesh = m
			if m.get_surface_count() > 0 and m.surface_get_material(0) == null:
				mi.material_override = Scenery._vc_mat()
			_ozne.add_child(mi)
			var ab := m.get_aabb()
			var h := ab.size.y
			var dd: float = UZAK[li]
			var hedef := Vector3(0, minf(h * 0.5, 4.0) if dd < 10.0 else h * 0.45, 0)
			# 150 m: dar açı (fov 18) — siluet okunur; 5 m: göz hizası, geniş açı
			_cam.fov = 75.0 if dd < 10.0 else (50.0 if dd < 100.0 else 18.0)
			_cam.position = Vector3(dd * 0.6, 1.7 if dd < 10.0 else maxf(2.0, dd * 0.05), dd * 0.8)
			_cam.look_at(hedef, Vector3.UP)
			for f in 4:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var img := get_viewport().get_texture().get_image()
			DirAccess.make_dir_recursive_absolute(_shots)
			img.save_png("%s/%s_%dm%s.png" % [_shots, tur, int(dd), "_gece" if _gece else ""])
	print("ISTBITKI sonda beyaz=%d" % toplam_beyaz)
	get_tree().quit()
