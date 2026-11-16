extends Node
## Fizik-ayak oyun içi kare aracı (yalnız --ayak-kare=<klasör> verilince Ayak.ayarla yükler; paketli oyunda yok).
##   --ayak-kare=<klasör>        kareler buraya
##   --ayak-kare-t=12,30,45      bölüm açıldıktan bu saniyelerde: oyuncu gözünden kare + seçilen kişiye yandan kare
##   --ayak-kare-kim=egim|yuru|at  aday: ayakları arasında en çok zemin farkı olan (varsayılan), yürüyen, at
##   --ayak-kare-izle            bölümün kendi kare kipi (=kare, GameState.shots_dir) "an_XX" kaydedince aynı anı yandan çek
## Aday seçimi yalnız ışınla (IK'dan bağımsız): ÖNCE ve SONRA koşusunda aynı ölçü.

var dir := ""
var zamanlar: Array = []
var kim := "egim"
var izle := false
var _sahne: Node
var _t0 := 0
var _sira := 0
var _gorulen := {}
var _mesgul := false
var _red := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ayak-kare="):
			dir = a.trim_prefix("--ayak-kare=")
		elif a.begins_with("--ayak-kare-t="):
			for x in a.trim_prefix("--ayak-kare-t=").split(","):
				zamanlar.append(float(x))
		elif a.begins_with("--ayak-kare-kim="):
			kim = a.trim_prefix("--ayak-kare-kim=")
		elif a == "--ayak-kare-izle":
			izle = true
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
		_cek("%s_t%02d" % [_ad(sc), int(zamanlar[_sira - 1])], true)
		return
	if izle and GameState.shots_dir != "" and Engine.get_process_frames() % 4 == 0:
		var d := DirAccess.open(GameState.shots_dir)
		if d:
			for f in d.get_files():
				if f.begins_with("an_") and f.ends_with(".jpg") and not f.ends_with("_yan.jpg") and not _gorulen.has(f):
					_gorulen[f] = true
					_cek(f.get_basename(), false)
					return


func _ad(sc: Node) -> String:
	return sc.scene_file_path.get_file().get_basename()


func _cek(ad: String, oyuncu: bool) -> void:
	_mesgul = true
	var vp := get_viewport()
	var cam0 := vp.get_camera_3d()
	if cam0 == null:
		_mesgul = false
		return
	if oyuncu:
		await RenderingServer.frame_post_draw
		vp.get_texture().get_image().save_jpg(dir.path_join(ad + "_oyuncu.jpg"), 0.85)
	var c := _aday(cam0)
	if c == null:
		print("AYAKKARE %s aday yok %s" % [ad, _red])
		_mesgul = false
		return
	var cam := Camera3D.new()
	cam.fov = 50.0
	get_tree().current_scene.add_child(cam)
	var at := c is Horse or c is Ox
	var hedef := c.global_position + Vector3(0, 0.45 if not at else 0.8, 0)
	cam.global_position = _yan_yer(c, cam0, at)
	cam.look_at(hedef)
	cam.current = true
	for k in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_jpg(dir.path_join(ad + "_yan.jpg"), 0.85)
	print("AYAKKARE %s kisi=%s/%s at=%s fark=%.2f" % [ad, c.get_class() if c.get_script() == null else (c.get_script() as Script).get_global_name(),
		c.name, c.global_position.snapped(Vector3.ONE * 0.1), _fark(c)])
	cam.current = false
	cam0.current = true
	cam.queue_free()
	_mesgul = false


## Kameranın önündeki 22 m içindeki adaylardan en iyisi: ayakları arasındaki zemin farkı (ya da yürüyen, at)
func _aday(cam0: Camera3D) -> Node3D:
	var cp := cam0.global_position
	var best: Node3D = null
	var bs := -1.0
	var list: Array = []
	_red = {}
	if kim == "at":
		for n in get_tree().current_scene.find_children("*", "Node3D", true, false):
			if n is Horse or n is Ox:
				list.append(n)
	else:
		list = get_tree().get_nodes_in_group("persons") + get_tree().get_nodes_in_group("soldiers")
	for n: Node3D in list:
		if not n.is_visible_in_tree():
			_red["gizli"] = _red.get("gizli", 0) + 1
			continue
		var d := cp.distance_to(n.global_position)
		if d > 22.0 or d < 2.0 or not cam0.is_position_in_frustum(n.global_position + Vector3(0, 0.6, 0)):
			_red["uzak"] = _red.get("uzak", 0) + 1
			continue
		var s := 0.0
		if kim == "at":
			s = 10.0 - d * 0.1 + _fark(n) * 20.0
		else:
			var rg = n.get("rig")
			if not (rg is Rig):
				_red["rigsiz"] = _red.get("rigsiz", 0) + 1
				continue
			var kd: String = Rig.Ayak.kapsam_disi(rg)
			if kd != "":
				_red[kd] = _red.get(kd, 0) + 1
				continue
			s = _fark(n)
			if kim == "yuru":
				s += 1.0 if (rg as Rig).yuruyor else 0.0
			s -= d * 0.004
		if s > bs:
			bs = s
			best = n
	return best


## Kişinin iki yanındaki (±0,1 m) ve önündeki/arkasındaki (±0,25 m) zeminin en büyük yükseklik farkı
func _fark(n: Node3D) -> float:
	var b := n.global_basis
	var p := n.global_position
	var ys: Array = []
	for o: Vector3 in [b.x * 0.1, -b.x * 0.1, b.z * 0.25, -b.z * 0.25]:
		var y := Unclip.floor_y(n, p + o, 0.5, 0.8)
		if not is_nan(y):
			ys.append(y)
	if ys.size() < 2:
		return 0.0
	return ys.max() - ys.min()


## Yan kamera yeri: kişinin yanından (profil) başlayıp çevresinde açılar denenir; kameradan kişinin dizine ve tabanına
## görüş hattı açık (çarpışan katı yok) ilk yer. Hiçbiri açık değilse oyuncu kamerası tarafındaki yan.
func _yan_yer(c: Node3D, cam0: Camera3D, at: bool) -> Vector3:
	var space := c.get_world_3d().direct_space_state
	var side := c.global_basis.x.normalized()
	if side.dot(cam0.global_position - c.global_position) < 0.0:
		side = -side
	var p := c.global_position
	var yuk := 0.8 if not at else 1.3
	var hedefler: Array = [p + Vector3(0, 0.45, 0), p + Vector3(0, 0.08, 0)] if not at else [p + Vector3(0, 0.9, 0), p + Vector3(0, 0.15, 0)]
	for dd: float in ([3.0, 2.3, 4.0] if not at else [5.0, 4.0, 6.5]):
		for a: float in [0.0, PI, 0.5, -0.5, PI - 0.5, PI + 0.5, 1.0, -1.0, PI - 1.0, PI + 1.0]:
			var dir := side.rotated(Vector3.UP, a)
			var cp := p + dir * dd + Vector3(0, yuk, 0)
			var acik := true
			for h: Vector3 in hedefler:
				var q := PhysicsRayQueryParameters3D.create(cp, h)
				q.collide_with_areas = false
				var r := space.intersect_ray(q)
				if not r.is_empty() and not (r["collider"] as Node).is_ancestor_of(c) and r["collider"] != c \
						and (r["position"] as Vector3).distance_to(h) > 0.12:
					acik = false
					break
			if acik:
				return cp
	return p + side * (3.0 if not at else 5.0) + Vector3(0, yuk, 0)
