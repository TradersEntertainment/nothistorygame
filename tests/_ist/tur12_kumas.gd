extends Node3D
## TUR-12 KUMAŞ sergisi: oyundaki bayrak kurucularının KENDİLERİ (aynı işlevler, aynı ölçü) yan yana; her biri için
## sabit kameradan 0,4 sn arayla 3 kare (dalganın kanıtı). Gündüz ışığı; --gece ile gece.
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur12_kumas.tscn --
##       --t12kare=<klasör> [--gece]
## Satırlar: KUMAS istasyon=<ad> kare=<dosya> ; KUMAS bitti

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const Y = preload("res://scripts/world/ist/ordugah_yapi.gd")
const OB = preload("res://scripts/world/ist/ordugah_oba.gd")
const GM = preload("res://scripts/world/ist/gemiler_mesh.gd")
const KUMAS = preload("res://scripts/world/ist/kumas.gd")

var _ist: Array = []      # [ad, kamera konumu, bakılan nokta]


func _ready() -> void:
	var gece := "--gece" in OS.get_cmdline_user_args()
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--t12kare="):
			dir = a.get_slice("=", 1)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("101828") if gece else Color("2a3b4e")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("3a4660") if gece else Color("8f8a7c")
	e.ambient_light_energy = 0.6 if gece else 0.2
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 30, 0) if not gece else Vector3(-50, 140, 0)
	sun.light_energy = 0.4 if not gece else 0.25
	sun.light_color = Color("ffe9c7") if not gece else Color("9fb0d8")
	sun.shadow_enabled = true
	add_child(sun)
	var yer := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(400, 400)
	yer.mesh = pm
	yer.material_override = Props.mat(Color("8a7358") if gece else Color("3d3226"))
	add_child(yer)
	_kur()
	await get_tree().process_frame
	await get_tree().process_frame
	var cam := Camera3D.new()
	cam.fov = 70.0
	add_child(cam)
	cam.make_current()
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
	for s: Array in _ist:
		cam.look_at_from_position(s[1], s[2], Vector3.UP)
		for i in 10:
			await get_tree().process_frame
		for k in 3:
			await RenderingServer.frame_post_draw
			var img := get_viewport().get_texture().get_image()
			var f := dir.path_join("%s_%d.jpg" % [s[0], k])
			if dir != "":
				img.save_jpg(f, 0.85)
			print("KUMAS istasyon=%s kare=%s cizim=%d" % [s[0], f.get_file(), RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)])
			var tt := Time.get_ticks_msec()
			while Time.get_ticks_msec() - tt < 400:
				await get_tree().process_frame
	print("KUMAS bitti bayrak_dugum=%d" % KUMAS.sayac)
	get_tree().quit()


func _host(x: float, z: float) -> Node3D:
	var h := Node3D.new()
	h.position = Vector3(x, 0, z)
	add_child(h)
	return h


func _kur() -> void:
	# 1. ordugâh sancak ormanı (ordugah_yapi2.build_sancaklar → ordugah_yapi.sancak), 5 sancak + 1 tuğ
	var h := _host(0, 0)
	IstOrdugahYapi2.build_sancaklar(h, 1.0, 0)
	_ist.append(["ordugah_sancak", Vector3(3.0, 5.0, 7.5), Vector3(3.0, 6.2, 0.0)])
	# 2. otağ tuğları (ordugah_oba._sancak tuğ) + çatallı flama
	h = _host(40, 0)
	var w := K.Bld.new("wood")
	var f := K.Bld.new()
	for i in 4:
		OB._sancak(w, f, Vector3(-2.0 + i * 1.3, 0, 0), 6.0, K.KIRMIZI, 0, true)
	OB._sancak(w, f, Vector3(4.0, 0, 0), 7.0, OB.SANCAK[0][0], 0, false)
	OB._sancak(w, f, Vector3(6.5, 0, 0), 7.0, OB.SANCAK[1][0], 0, false)
	w.done(h, "dir")
	f.done(h, "bayrak")
	_ist.append(["otag_tug", Vector3(42.0, 4.8, 8.5), Vector3(42.0, 5.4, 0.0)])
	# 3. sur kulesi tepesinde bayrak (surlar_ayrinti._flag): taş kaide üstünde
	h = _host(80, 0)
	Props.box(h, Vector3(8, 6, 8), Vector3(0, 3, 0), Color("8b806c"))
	IstSurlarAyrinti._flag(h, -1.0, 6.0, -1.0, Color("8a1c1c"), Color("d9a82a"))
	IstSurlarAyrinti._flag(h, 2.0, 6.0, -1.0, Color("1c3a8a"), Color("e8e0d0"))
	_ist.append(["sur_bayrak", Vector3(81.0, 9.5, 8.0), Vector3(81.0, 8.6, 0.0)])
	# 4. Galata (Ceneviz) bayrağı (galata_ortak.flag)
	h = _host(120, 0)
	Props.box(h, Vector3(6, 4, 6), Vector3(0, 2, 0), Color("b9aa8c"))
	IstGalataOrtak.flag(h, Vector3(0, 4, 0), 4.5, 2.0, 1.3)
	_ist.append(["galata_bayrak", Vector3(121.0, 7.2, 7.5), Vector3(121.0, 7.6, 0.0)])
	# 5. gemi bayrakları (gemiler_mesh._bayrak/_flama, gemi gölgelendiricisi SALINIM)
	h = _host(170, 0)
	for gi in 2:
		var mi := MeshInstance3D.new()
		mi.mesh = GM.mesh(["kadirga", "karaka"][gi], ["osmanli", "venedik"][gi], 0)
		mi.material_override = GM.malzeme()
		mi.position = Vector3(gi * 30.0, 0, 0)
		h.add_child(mi)
		# bayrak köşelerinin (alfa < 1) en büyük kümesi: kıç bayrağı; kamera ona 7 m yandan bakar
		var ar := mi.mesh.surface_get_arrays(0)
		var vv: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
		var cc: PackedColorArray = ar[Mesh.ARRAY_COLOR]
		var lo := Vector3(1e9, 1e9, 1e9)
		var en := -1e9
		var hedef := Vector3.ZERO
		var say := 0
		for i in vv.size():
			if cc[i].a < 0.997 and vv[i].y < 12.0:
				hedef += vv[i]
				say += 1
		if say > 0:
			hedef = hedef / say + mi.position + h.position
		_ist.append([["gemi_kadirga", "gemi_karaka"][gi], hedef + Vector3(7.0, 0.5, 3.0), hedef])
	# 6. şehir/hub sancakları: Haliç mahallesi ve Haliç suru (halic_mahalle._banner, halic_sur._banner), sahne sancağı
	#    (dressing.banner_pole), talim meydanı (training_yard._banner eşi)
	h = _host(260, 0)
	IstHalicMahalle._banner(h, Vector3(0, 0, 0), true)
	IstHalicMahalle._banner(h, Vector3(4, 0, 0), false)
	IstHalicSur._banner(h, Vector3(8, 0, 0), 0.0)
	var d := Dressing.new(3)
	d.at(Vector3(272, 0, 0))
	d.banner_pole(Vector3.ZERO, Color("8a1a3a"))
	d.build(self)
	_ist.append(["sehir_sancak", Vector3(266.0, 3.6, 10.0), Vector3(266.0, 4.0, 0.0)])
	# 7. Osmanlı hücum sancağı (assault._sancak'ın aynı çağrısı: çatal kuyruk + hilal) ve tuğ
	h = _host(320, 0)
	Props.cyl(h, 0.05, 5.5, Vector3(0, 2.75, 0), Color("4a3420"), Vector3.ZERO, 5)
	KUMAS.bayrak(h, Vector3(0, 5.35, 0), Vector3.FORWARD, 2.45, 1.3, Color("9a2a24"), [], 10, "Sancak", 0.4, true)
	Props.cyl(h, 0.05, 5.5, Vector3(4, 2.75, 0), Color("4a3420"), Vector3.ZERO, 5)
	KUMAS.bayrak(h, Vector3(4, 5.35, 0), Vector3.FORWARD, 2.45, 1.3, Color("2e5a36"), [], 10, "Sancak", 0.4, true)
	_ist.append(["hucum_sancak", Vector3(323.0, 4.6, 8.5), Vector3(323.0, 4.8, 0.0)])
	# 8. Bölüm 39o kapı sancağı (_plant_flag'ın aynı kumaşı: eğik direk ucunda, kurulduğu yöne)
	h = _host(360, 0)
	# kapı duvarı: _plant_flag'da side = −1 iken direk +x'e çıkar; duvar yüzü f'nin 0,15 m gerisinde (x = 0)
	Props.box(h, Vector3(0.6, 4, 4), Vector3(-0.3, 2, 0), Color("b8a888"))
	var fl := Node3D.new()
	fl.position = Vector3(-0.15, 2.4, 0.7)
	h.add_child(fl)
	Props.cyl(fl, 0.03, 1.4, Vector3(0.3, 0, 0), Color("6a4a2c"), Vector3(0, 0, -60.0), 5)
	KUMAS.bayrak(fl, Vector3(0.86, 0.33, 0.0), Vector3.BACK, 0.7, 0.5, Color("b3262d"), [], 6, "Sancak", 0.0, false, true)
	_ist.append(["c39o_sancak", Vector3(363.2, 3.2, 3.2), Vector3(360.6, 2.6, 0.9)])
	# 9. çamaşır ipi (ordugah_oba._camasir)
	h = _host(400, 0)
	var wd := K.Bld.new("wood")
	var cf := K.Bld.new()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	OB._camasir(wd, cf, [[Vector2(0, 0), 1.0], [Vector2(7, 0), 1.0]], r)
	wd.done(h, "odun")
	cf.done(h, "bayrak")
	_ist.append(["camasir", Vector3(403.5, 1.9, 4.5), Vector3(403.5, 1.5, 1.2)])
	# 10. çadır kumaşı (yakın ağ, MultiMesh ve tek düğüm) ve tente (ayrinti "tente"): çok hafif nefes
	h = _host(440, 0)
	K.mm(h, K.tent_lod("koni", 0), [Transform3D(Basis().scaled(Vector3(2.4, 1.0, 2.4)), Vector3(0, -0.1, 0))], [Color("d9ccaa")], "cadir", "", true)
	preload("res://scripts/world/ist/ordugah_cadir.gd").ekle(h, "pasa", Transform3D(Basis().scaled(Vector3(3.0, 1.0, 3.0)), Vector3(8, -0.1, 0)), Color("c8b48a"), 0, "pasa_cadir")
	Ayrinti.build("tente", _host(440, 9), 1.0, 0)
	_ist.append(["cadir_tente", Vector3(444.0, 3.2, 12.0), Vector3(444.0, 1.6, 3.0)])
