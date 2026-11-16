extends Node
## Fizik-3 oyun içi kare aracı (yalnız --fizik3-oyun=<klasör> verilince Ayak.ayarla yükler; paketli oyunda yok).
##   --fizik3-oyun=<klasör>        kareler buraya
##   --fizik3-oyun-t=12,30,45      bölüm açıldıktan bu saniyelerde: oyuncu gözünden kare + kumaşlı bir kişiye yandan
##                                 0,15 sn arayla 6 kare (tanık kamera kişiyi izler)
##   --fizik3-oyun-kim=sultan      aday önceliği: sultan|vizier (şapka), yuru (yürüyen), varsayılan: yakın ve yürüyen
## Aday: Rig'inde kumaş olan (Rig.kumas), kameranın önünde 25 m içinde, görünür kişi.

var dir := ""
var zamanlar: Array = []
var kim := ""
var _sahne: Node
var _t0 := 0
var _sira := 0
var _mesgul := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--fizik3-oyun="):
			dir = a.trim_prefix("--fizik3-oyun=")
		elif a.begins_with("--fizik3-oyun-t="):
			for x in a.trim_prefix("--fizik3-oyun-t=").split(","):
				zamanlar.append(float(x))
		elif a.begins_with("--fizik3-oyun-kim="):
			kim = a.trim_prefix("--fizik3-oyun-kim=")
	DirAccess.make_dir_recursive_absolute(dir)


func _process(_d: float) -> void:
	var sc := get_tree().current_scene
	if sc == null or _mesgul:
		return
	if sc != _sahne:
		_sahne = sc
		_t0 = Time.get_ticks_msec()
		_sira = 0
	var t := (Time.get_ticks_msec() - _t0) / 1000.0
	if _sira < zamanlar.size() and t >= float(zamanlar[_sira]):
		_sira += 1
		_cek("%s_t%02d" % [sc.scene_file_path.get_file().get_basename(), int(zamanlar[_sira - 1])])


func _cek(ad: String) -> void:
	_mesgul = true
	var vp := get_viewport()
	var cam0 := vp.get_camera_3d()
	if cam0 == null:
		_mesgul = false
		return
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_jpg(dir.path_join(ad + "_oyuncu.jpg"), 0.85)
	var c := _aday(cam0)
	if c == null:
		print("KUMASKARE %s aday yok" % ad)
		_mesgul = false
		return
	var cam := Camera3D.new()
	cam.fov = 45.0
	get_tree().current_scene.add_child(cam)
	var side := c.global_basis.x.normalized()
	if (cam0.global_position - c.global_position).dot(side) < 0.0:
		side = -side
	cam.current = true
	for i in 6:
		var hedef := c.global_position + Vector3(0, 0.75, 0)
		cam.global_position = hedef + side * 3.0 + Vector3(0, 0.35, 0) - c.global_basis.z.normalized() * 0.8
		cam.look_at(hedef)
		for k in 2:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		vp.get_texture().get_image().save_jpg(dir.path_join("%s_yan_%d.jpg" % [ad, i]), 0.85)
		await get_tree().create_timer(0.15, true, false, true).timeout
	var rg: Rig = c.get("rig")
	print("KUMASKARE %s kisi=%s/%s hat=%s at=%s yuru=%s" % [ad, (c.get_script() as Script).get_global_name(), c.name, str(c.get("hat")),
		c.global_position.snapped(Vector3.ONE * 0.1), str(rg.yuruyor if rg else false)])
	cam.current = false
	cam0.current = true
	cam.queue_free()
	_mesgul = false


func _aday(cam0: Camera3D) -> Node3D:
	var cp := cam0.global_position
	var fw := -cam0.global_basis.z
	var best: Node3D = null
	var bs := -INF
	for n in get_tree().current_scene.find_children("*", "Node3D", true, false):
		if not (n is Person or n is Soldier) or not (n as Node3D).is_visible_in_tree():
			continue
		var rg = n.get("rig")
		if not (rg is Rig) or (rg as Rig).kumas == null:
			continue
		var p := (n as Node3D).global_position
		var d := p.distance_to(cp)
		if d > 25.0 or d < 1.5 or (p - cp).normalized().dot(fw) < 0.5:
			continue
		var s := -d
		if (rg as Rig).yuruyor:
			s += 8.0
		if kim != "" and str(n.get("hat")) == kim:
			s += 40.0
		if s > bs:
			bs = s
			best = n
	return best
