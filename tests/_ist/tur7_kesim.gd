extends "res://tests/_ist/sur_oyun_demo.gd"
## TUR-7 geliştirme sondası (kesim sahnesi; sur_oyun_demo ile AYNI kurulum ve gök): seçili kameralar + tanı.
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur7_kesim.tscn -- \
##     --out=DIR [--sec=07_gedikten,01_ovadan] [--pik=x,y] [--gizle=ad1,ad2]
## --pik: ekran pikselinin ışınının geçtiği görünen ağları (AABB) yakından uzağa yazar: "TUR7PIK <yol> <uzaklık>"
## --pisirme_yok: dilimler pişirilmez (tanı: --pik düğüm adını verir; çizim sayısı gerçek değil)
## --gizle: adı bu parçalardan birini içeren düğümler gizlenir (kaynak bulmak için)

var _sec: Array = []
var _pik := Vector2(-1, -1)
var _gizle: Array = []


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		var kv := s.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"sec": _sec = Array(kv[1].split(","))
			"pik":
				var p := kv[1].split(",")
				_pik = Vector2(p[0].to_float(), p[1].to_float())
			"gizle": _gizle = Array(kv[1].split(","))
			"pisirme_yok": IstSurlar.bake = false
	super._ready()


## sur_oyun_demo'nun kare döngüsüne kanca: kamera kurulduktan sonra, kareden önce çağrılır (_kos'u kopyalamamak için
## kameraları kendisi dolaşır)
func _kos() -> void:
	var sec := {"ebeveyn": self, "dunya": false, "uzak": true, "asama": 2, "dolgu": 0.5, "kalas": true, "poterna_acik": true, "merdiven": [0, 1, 2]}
	var k: Dictionary = SurOyun.kur("mesoteikhion", sec)
	a = k["arayuz"]
	kok = k["kok"]
	SURDOKU.uygula(kok, 0)
	load("res://scripts/world/ist/gorsel_dil.gd").kur(self)
	_tirmananlar(k["parca"])
	for i in 30:
		await get_tree().process_frame
	for n in find_children("*", "Node3D", true, false):
		for g: String in _gizle:
			if g != "" and String(n.name).contains(g):
				(n as Node3D).visible = false
	var d: Dictionary = a.d
	var gx: float = a.gx
	var zo0 := float(d["zo0"])
	var zo1 := float(d["zo1"])
	var zm0 := float(d["zm0"])
	var zm1 := float(d["zm1"])
	var OH := float(d["OH"])
	var zc: float = a.zc_dis()
	var yt: float = a.y_teras()
	var yo: float = a.y_ova()
	var dy: float = a.dy
	var pot := float(a.poterna()["x"])
	var dm: Dictionary = a.dayamalar()[1]
	var ay: Vector3 = dm["ayak"]["yerel"]
	var kam := {
		"01_ovadan": [Vector3(gx + 22.0, yo + 1.7, zm1 + 38.0), Vector3(gx + 4.0, 3.0, zo1)],
		"02_hendek_kiyisindan": [Vector3(gx + 15.0, yo + 1.7, zm1 + 1.6), Vector3(gx - 2.0, dy - 3.5, zm0 + 6.0)],
		"03_kopru_ustunden": [Vector3(pot, dy + 1.7, (zm0 + zm1) * 0.5 + 4.0), Vector3(pot + 1.0, -0.5, zo1)],
		"04_merdiven_dibinden": [Vector3(ay.x + 3.0, yt + 1.6, ay.z + 3.2), Vector3(ay.x - 0.5, OH + 0.5, zo1)],
		"05_sur_yolundan_asagi": [Vector3(ay.x + 7.0, OH + 2.6, zo1 - 0.6), Vector3(ay.x - 3.0, yt, zm0 + 1.0)],
		"06_peribolostan": [Vector3(gx + 16.0, 1.6, zo0 - 6.5), Vector3(gx, 1.4, zo0 + 1.0)],
		"07_gedikten": [Vector3(gx + 0.5, 1.3 + 1.7, zc), Vector3(gx + 2.0, dy - 2.0, zm1 + 6.0)],
		"08_poternadan": [Vector3(pot - 0.3, 1.6, zo0 - 4.0), Vector3(pot + 0.3, 0.6, zm0)],
		"09_havadan_gedik": [Vector3(gx + 46.0, 42.0, zm1 + 40.0), Vector3(gx + 6.0, 0.0, zo1 + 4.0)],
		"10_havadan_kesim": [Vector3(-30.0, 70.0, -60.0), Vector3(-30.0, 0.0, 28.0)],
	}
	for ad: String in kam.keys():
		if not _sec.is_empty() and not ad in _sec:
			continue
		var c: Array = kam[ad]
		cam.global_position = c[0]
		cam.look_at(c[1], Vector3.UP)
		for i in 12:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		img.save_jpg("%s/%s%s.jpg" % [out, ("gece_" if gece else ""), ad], 0.85)
		var vp := get_viewport()
		print("TUR7KESIM kare %s cizim=%d ilkel=%d" % [ad, vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME),
			vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME)])
		if _pik.x >= 0.0:
			_pik_yaz()
	print("TUR7KESIM BITTI")
	get_tree().quit(0)


func _pik_yaz() -> void:
	var o := cam.project_ray_origin(_pik)
	var dr := cam.project_ray_normal(_pik)
	var hits: Array = []
	for n in find_children("*", "GeometryInstance3D", true, false):
		var gi := n as GeometryInstance3D
		if not gi.is_visible_in_tree():
			continue
		var ab := gi.global_transform * gi.get_aabb()
		var h = ab.intersects_ray(o, dr)
		if h != null:
			hits.append([o.distance_to(h), str(gi.get_path()).trim_prefix(str(get_path())), ab.size])
	hits.sort_custom(func(p, q): return p[0] < q[0])
	for h in hits.slice(0, 14):
		print("TUR7PIK %s %.1f %s" % [h[1], h[0], h[2]])
