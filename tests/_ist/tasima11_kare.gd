extends Node
## TAŞIMA 11: bölüm kareleri (ESKİ | YENİ). Bölümü boot gibi yükler (GameState komut satırını kendisi okur: --chapter,
## --autotest[=çeşit], --eskisur), kurulumdan sonra bekler, ağacı dondurur (çizim sürer), HUD'u gizler ve verilen
## kameralardan 1280×720 jpg (85) çeker; her karede çizim çağrısı / ilkel (4 kare ortalaması).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tasima11_kare.tscn -- \
##     --chapter=4 --autotest=chain [--eskisur] --out=DIR --bekle=1.5 --kam="ad:x,y,z:bx,by,bz;..." [--fov=72]
## Kamera koordinatları bölüm sahnesinin yerel çerçevesinde (sahne kökü). --oyuncu: kamera yerine oyuncunun gözü.

var out := "user://tasima11_kare"
var bekle := 1.5
var kamlar := ""
var fov := 72.0
var on_ek := ""
## --once=Sinif: bekleme, sahnede bu sınıftan bir düğüm (SeaWalls) kurulduktan sonra başlar
var once := ""


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		var kv := s.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"bekle": bekle = float(kv[1])
			"kam": kamlar = kv[1]
			"fov": fov = float(kv[1])
			"onek": on_ek = kv[1]
			"once": once = kv[1]
	DirAccess.make_dir_recursive_absolute(out)
	var h := Yardimci.new()
	h.ana = self
	h.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(h)
	var ch := GameState.start_chapter if GameState.start_chapter == 0 and GameState.start_scene == "" else maxi(GameState.start_chapter, 1)
	var path := GameState.start_scene if GameState.start_scene != "" else "res://scenes/chapter%d.tscn" % ch
	if ch in Siege.ORDER:
		GameState.ensure_defaults_for(12)
		if path.ends_with("o.tscn"):
			GameState.flags["siege_side"] = "O"
	elif ch > 1:
		GameState.ensure_defaults_for(mini(ch, GameState.LATEST_CHAPTER))
	get_tree().change_scene_to_file.call_deferred(path)


class Yardimci extends Node:
	var ana

	func _ready() -> void:
		_kos.call_deferred()

	func _kos() -> void:
		var out: String = ana.out
		var bekle: float = ana.bekle
		var kamlar: String = ana.kamlar
		var fov: float = ana.fov
		var on_ek: String = ana.on_ek
		var once: String = ana.once
		get_window().size = Vector2i(1280, 720)
		var t := 0.0
		if once != "":
			var bulundu := false
			while not bulundu and t < 240.0:
				await get_tree().process_frame
				t += get_process_delta_time() / maxf(Engine.time_scale, 0.01)
				var sc := get_tree().current_scene
				if sc != null and Engine.get_process_frames() % 10 == 0:
					for c in sc.get_children():
						if c.get_script() != null and (c.get_script() as Script).get_global_name() == once:
							bulundu = true
			print("T11BEKLE once=%s bulundu=%s t=%.1f" % [once, bulundu, t])
			t = 0.0
		while t < bekle:
			await get_tree().process_frame
			t += get_process_delta_time() / maxf(Engine.time_scale, 0.01)
		var sahne := get_tree().current_scene as Node3D
		get_tree().paused = true
		for c in get_tree().root.find_children("*", "CanvasLayer", true, false):
			(c as CanvasLayer).visible = false
		var cam := Camera3D.new()
		cam.fov = fov
		cam.near = 0.05
		cam.far = 4000.0
		cam.process_mode = Node.PROCESS_MODE_ALWAYS
		sahne.add_child(cam)
		for t2 in kamlar.split(";", false):
			var p := t2.split(":")
			var a := p[1].split(",")
			var b := p[2].split(",")
			var pos := Vector3(float(a[0]), float(a[1]), float(a[2]))
			var bak := Vector3(float(b[0]), float(b[1]), float(b[2]))
			cam.global_position = sahne.to_global(pos)
			cam.look_at(sahne.to_global(bak), Vector3.UP)
			cam.current = true
			var dc := 0
			var pr := 0
			for i in 6:
				cam.current = true
				await RenderingServer.frame_post_draw
				if i >= 2:
					dc += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
					pr += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
			var img := get_viewport().get_texture().get_image()
			img.save_jpg(out.path_join("%s%s.jpg" % [on_ek, p[0]]), 0.85)
			print("T11KARE %s%s ciz=%d ilkel=%d" % [on_ek, p[0], dc / 4, pr / 4])
		get_tree().quit()
