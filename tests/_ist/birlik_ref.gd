extends Node
## BİRLİK referans sondası: yayındaki bir bölüm (oyuncu kamerası, otomatik test botu oynarken) belirli saniyelerde
## kare + kategori kimlik karesi (birlik_id.gd) alınır; birlik_olc.py v2 kareleriyle aynı ölçüyü yapar.
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/birlik_ref.tscn --
##       --chapter=24 --autotest --out=KLASÖR --anlar=12,30
## Bölüm, açılıştaki (boot.gd) yolla yüklenir; izleyici düğüm kökte kalır (sahne değişince silinmez).

const ID := preload("res://tests/_ist/birlik_id.gd")


func _ready() -> void:
	var out := "user://birlik_ref"
	var anlar: Array = [12.0, 30.0]
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"anlar":
				anlar = []
				for t in kv[1].split(","):
					anlar.append(t.to_float())
	var izle := Izle.new()
	izle.out = out
	izle.anlar = anlar
	izle.sayim = OS.get_cmdline_user_args().has("--sayim")
	izle.ad = GameState.start_scene.get_file().get_basename() if GameState.start_scene != "" else "chapter%d" % GameState.start_chapter
	get_tree().root.add_child.call_deferred(izle)
	var ch := maxi(GameState.start_chapter, 1)
	var path := GameState.start_scene if GameState.start_scene != "" else "res://scenes/chapter%d.tscn" % ch
	if ch in Siege.ORDER:
		GameState.ensure_defaults_for(12)
	elif ch > 1:
		GameState.ensure_defaults_for(mini(ch, GameState.LATEST_CHAPTER))
	get_tree().change_scene_to_file.call_deferred(path)


class Izle extends Node:
	var out := ""
	var ad := ""
	var anlar: Array = []
	var t0 := 0
	var sayim := false

	## görünen geometrinin kategori sayımı (düğüm adı, ata betikleri, malzeme): sınıflandırıcı denetimi
	func _sayim() -> void:
		var say := {}
		for c in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
			var gi := c as GeometryInstance3D
			if not gi.is_visible_in_tree():
				continue
			var m: Material = gi.material_override
			if m == null and gi is MeshInstance3D and (gi as MeshInstance3D).mesh and (gi as MeshInstance3D).mesh.get_surface_count() > 0:
				m = (gi as MeshInstance3D).get_active_material(0)
			if m == null:
				continue
			var k := ID.GD.kategori(gi, m)
			var zincir := ""
			var p := gi.get_parent()
			for j in 4:
				if p == null:
					break
				zincir += String(p.name).left(14) + ("(" + p.get_script().resource_path.get_file() + ")" if p.get_script() else "") + "<"
				p = p.get_parent()
			var key := "%s | %s | %s | %s" % [k, String(gi.name).rstrip("0123456789_@").left(16), zincir, m.get_class()]
			say[key] = int(say.get(key, 0)) + 1
		for k in say:
			print("REFSAYIM %4d %s" % [say[k], k])

	func _ready() -> void:
		DirAccess.make_dir_recursive_absolute(out)
		t0 = Time.get_ticks_msec()
		_calis()

	func _calis() -> void:
		var i := 0
		for t: float in anlar:
			while (Time.get_ticks_msec() - t0) / 1000.0 < t:
				await get_tree().process_frame
			ID.ui(get_tree(), false)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var cam := get_viewport().get_camera_3d()
			var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			var nm := "ref_%s_%d" % [ad, i]
			print("BIRLIKREF %s t=%.1f kamera=%s cizim=%d" % [nm, t, cam.global_position if cam else Vector3.ZERO, dc])
			get_viewport().get_texture().get_image().save_jpg(out.path_join(nm + ".jpg"), 0.85)
			await ID.cek(get_tree(), out.path_join(nm + "_id.png"))
			ID.ui(get_tree(), true)
			if sayim:
				_sayim()
			i += 1
		print("BIRLIKREF BITTI")
		get_tree().quit(0)
