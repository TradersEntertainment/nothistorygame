extends Node3D
## ORDUGÂH-5 sondası: çadır türlerini düz zeminde yan yana çizer (yakın/orta/uzak), kareler alır.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/ordugah5_cadir.tscn -- --out=KLASÖR [--gece]

const C = preload("res://scripts/world/ist/ordugah_cadir.gd")
const K = preload("res://scripts/world/ist/ordugah_kit.gd")

var out := "user://ordugah5_cadir"
var cam: Camera3D

const TURLER := [["koni", Vector3(2.4, 1.0, 2.4), Color("d9ccaa")], ["can", Vector3(2.6, 1.0, 2.6), Color("efe6cc")],
	["catma", Vector3(5.2, 1.15, 3.6), Color("cdbf9a")], ["buyuk", Vector3(8.0, 1.0, 5.6), Color("e4dcc4")],
	["kil", Vector3(7.0, 1.0, 3.8), Color(0.95, 0.93, 0.9)], ["barinak", Vector3(3.4, 1.2, 2.6), Color("b8a882")],
	["pasa", Vector3(12.0, 1.0, 8.0), Color.WHITE]]


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
	DirAccess.make_dir_recursive_absolute(out)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("8fb8e0")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.6, 0.62, 0.7)
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 35, 0)
	sun.shadow_enabled = true
	add_child(sun)
	var zem := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(200, 200)
	zem.mesh = pm
	var zm := StandardMaterial3D.new()
	zm.albedo_color = Color("8a9a5a")
	zem.material_override = zm
	add_child(zem)
	cam = Camera3D.new()
	cam.fov = 60
	add_child(cam)
	cam.make_current()
	var x := 0.0
	for t: Array in TURLER:
		for lod in 3:
			var nm: String = (["", "orta_", "uzak_"][lod]) + String(t[0])
			var mi := MeshInstance3D.new()
			mi.mesh = C.mesh(nm)
			mi.material_override = K.mat("")
			mi.transform = Transform3D(Basis().scaled(t[1]), Vector3(x, -0.1, lod * 16.0))
			add_child(mi)
			var mat := K.mat("").duplicate() as StandardMaterial3D
			mat.albedo_color = t[2] * Color(0.78, 0.76, 0.72)
			mi.material_override = mat
			print("ISTCADIR %s ucgen=%d" % [nm, C.tris(nm)])
		x += 16.0
	await get_tree().process_frame
	var i := 0
	x = 0.0
	for t: Array in TURLER:
		var s: Vector3 = t[1]
		var R := maxf(s.x, s.z) * (0.5 if String(t[0]) in ["catma", "buyuk", "kil", "barinak", "pasa"] else 1.0)
		await _shot("on_%s" % t[0], Vector3(x + R * 0.7, 1.7, R + 5.0), Vector3(x, 1.2, 0))
		await _shot("kapi_%s" % t[0], Vector3(x, 1.4, R * (0.5 if R > 3 else 1.0) + 1.6), Vector3(x, 0.6, 0))
		await _shot("orta_%s" % t[0], Vector3(x + 6, 6, 16.0 + R + 14.0), Vector3(x, 1.0, 16.0))
		x += 16.0
	await _shot("genel", Vector3(50, 22, 60), Vector3(50, 0, 10))
	get_tree().quit(0)


func _shot(name: String, at: Vector3, look: Vector3) -> void:
	cam.global_position = at
	cam.look_at(look, Vector3.UP)
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_jpg(out.path_join(name + ".jpg"), 0.85)
