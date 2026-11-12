extends Node3D
## CANLI sonda (kalite notu 32): nötr zeminde hayvan kareleri. ÖNCE için aynı betik eski kodun kopyasında koşar
## (yalnız oyunun kendi API'si kullanılır). Kullanım:
##   godot --path . res://tests/_canli/sonda_kare.tscn -- tur=<okuz|at|deve|koyun|kopek|keci|tavuk|kedi|marti|esek|okuz_sinif|at_sinif|deve10> shots=KLASÖR
## Kareler: <tur>_yan, _capraz, _on (yakın: büyük hayvanda 5 m), _uzak (60 m), _suru.
const K := preload("res://scripts/world/ist/ordugah_kit.gd")

var _args := {}
var _cam: Camera3D
var _root: Node3D
var _shots := ""


func _ready() -> void:
	GameState.autotest = false
	for a: String in OS.get_cmdline_user_args():
		var p := a.split("=", true, 1)
		if p.size() == 2:
			_args[p[0]] = p[1]
	_shots = _args.get("shots", "")
	DirAccess.make_dir_recursive_absolute(_shots)
	_world()
	for tur: String in String(_args.get("tur", "okuz")).split(","):
		await _run(tur)
	get_tree().quit(0)


func _world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("6a9ccc")
	sm.sky_horizon_color = Color("d8d0b8")
	sm.ground_horizon_color = Color("b0a68a")
	sky.sky_material = sm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("ffe8c0")
	sun.light_energy = 1.0
	sun.rotation_degrees = Vector3(-48, -35, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 120.0
	add_child(sun)
	var gm := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(600, 600)
	gm.mesh = pm
	gm.material_override = Props.mat(Color("6a6650"), 0.0, false, "", false)
	add_child(gm)
	_cam = Camera3D.new()
	_cam.fov = 50
	_cam.far = 2000
	add_child(_cam)
	_cam.current = true
	_root = Node3D.new()
	add_child(_root)


func _clear() -> void:
	for c in _root.get_children():
		c.free()


func _bld(fn: Callable, pattern := "") -> Node3D:
	var host := Node3D.new()
	_root.add_child(host)
	var b := K.Bld.new(pattern)
	fn.call(b)
	b.done(host, "hayvan")
	return host


## Tek örnek (yaw derece, +Z ileri) ya da sürü; döndürür bakış yüksekliği
func _make(tur: String, pos: Vector3, yaw: float, i: int) -> float:
	var r := RandomNumberGenerator.new()
	r.seed = 77 + i
	match tur:
		"okuz":
			_bld(func(b): IstOrdugahYapi._okuz(b, pos, yaw, r), "wood")
			return 1.0
		"at":
			var renk := [Color("6a4a30"), Color("8a6a46"), Color("3a2e26"), Color("a88a62"), Color("c9b080")]
			_bld(func(b): IstOrdugahYapi2._at(b, pos, yaw, renk[i % renk.size()], false))
			return 1.1
		"deve":
			if i == 0:
				_bld(func(b): IstOrdugahYapi2._at(b, pos, yaw, Color("b49a6c"), true))
				return 1.3
			_bld(func(b): IstOrdugahOba._deve_yatan(b, pos, yaw + i * 40.0, Color("b49a6c").lerp(Color("8a7048"), (i % 4) / 4.0)))
			return 0.8
		"kopek":
			_bld(func(b): IstOrdugahOba._kopek(b, pos, yaw, r))
			return 0.4
		"okuz_sinif":
			var o := Ox.new(Color("8a5a36"))
			o.position = pos
			o.rotation.y = deg_to_rad(yaw)
			_root.add_child(o)
			o.set_process(false)
			return 1.0
		"at_sinif":
			var h := Horse.new()
			h.position = pos
			h.rotation.y = deg_to_rad(yaw)
			_root.add_child(h)
			h.set_process(false)
			return 1.1
		"keci":
			var g := Goat.new()
			g.position = pos
			g.rotation.y = deg_to_rad(yaw)
			_root.add_child(g)
			g.set_process(false)
			return 0.5
		"tavuk":
			var c := Chicken.new()
			c.position = pos
			c.rotation.y = deg_to_rad(yaw)
			_root.add_child(c)
			c.set_process(false)
			return 0.25
		"kedi":
			var k := Cat.new()
			k.position = pos
			k.rotation.y = deg_to_rad(yaw)
			_root.add_child(k)
			k.set_process(false)
			return 0.2
		"marti":
			var m := ThiefGull.new()
			m.position = pos
			m.rotation.y = deg_to_rad(yaw)
			_root.add_child(m)
			m.set_process(false)
			return 0.35
		"esek":
			var e := IstHayatGovde.animal("donkey", i)
			e.position = pos
			e.rotation.y = deg_to_rad(yaw)
			_root.add_child(e)
			return 0.8
	return 1.0


func _run(tur: String) -> void:
	_clear()
	# yakın: tek örnek (koyun: ağıl)
	var big := tur in ["okuz", "at", "deve", "okuz_sinif", "at_sinif", "esek"]
	var dn := 5.0 if big else (2.2 if tur in ["kopek", "keci"] else 1.3)
	var hy := 0.0
	var tgt := Vector3.ZERO
	if tur == "koyun":
		var host := Node3D.new()
		_root.add_child(host)
		IstOrdugahYerleske.build_agil(host, 0.5, 0, 1)
		var hay: PackedVector3Array = host.get_meta("hayvanlar", PackedVector3Array())
		tgt = hay[3] if hay.size() > 3 else Vector3.ZERO
		hy = 0.35
		dn = 2.6
	else:
		hy = _make(tur, Vector3.ZERO, 0.0, 0)
	var look := tgt + Vector3(0, hy, 0)
	await _shot(tur + "_yan", look + Vector3(dn, 0.25 * dn * 0.3, 0), look)
	await _shot(tur + "_capraz", look + Vector3(dn * 0.62, 0.3 * dn * 0.3, dn * 0.78), look)
	await _shot(tur + "_on", look + Vector3(0.0, 0.2 * dn * 0.3, dn), look)
	await _shot(tur + "_uzak", look + Vector3(36.0, 10.0, 46.0), look)
	# sürü
	if tur == "koyun":
		await _shot(tur + "_suru", tgt + Vector3(10, 7, 14), tgt + Vector3(0, 0, 4))
		return
	_clear()
	var n := 10
	var span := 2.4 if big else (1.2 if tur in ["kopek", "keci"] else 0.7)
	for i in n:
		var p := Vector3((i % 5) * span - 2 * span, 0, (i / 5) * span * 1.6)
		_make(tur, p, (i * 37) % 60 - 30.0 if tur != "deve" else 0.0, i)
	var c := Vector3(0, hy, span * 0.8)
	await _shot(tur + "_suru", c + Vector3(span * 4.0, span * 2.6, span * 5.5), c)


func _shot(nm: String, from: Vector3, to: Vector3) -> void:
	_cam.position = from
	_cam.look_at(to, Vector3.UP)
	for k in 3:
		await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_jpg(_shots.path_join(nm + ".jpg"), 0.88)
	print("CANLIKARE ", nm)
