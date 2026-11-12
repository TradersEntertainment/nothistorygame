extends Node3D
## Serbest kamera sondası (G2 kanıtı): otağın içi ve dışı aynı yer mi.
##   --mode=in   : OtagHall (kapı dilimiyle) kurulur; içeriden kapıya bakış kareleri
##   --mode=out  : gerçek ordugâh (CampDay, World1453 "camp") kurulur; aynı noktalardan dışarı bakış, dışarıdan ve
##                 havadan otağın kapısına bakış
## Kareler --out=KLASÖR altına sonda_*.png. Kameralar salon yerelinde tanımlı; "out" kipinde World1453.region ile
## kamp yereline çevrilir (aynı dünya noktası). Kullanım (ekranlı):
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 res://tests/sonda_otag.tscn -- --mode=in --out=/tmp/x

## [ad, göz (salon yereli), bakılan nokta (salon yereli), görüş açısı]. Göz dünyadaki otağın kabuğunun (yarıçap 7)
## içindeyse "out" kipinde çekilmez (kapalı kabuğun içi).
const SHOTS := [
	["sonda_taht", Vector3(0.0, 1.62, -0.6), Vector3(0.0, 1.9, -6.7), 72.0],
	["sonda_yan_vezir", Vector3(0.0, 1.62, -0.6), Vector3(-6.0, 1.6, -0.6), 72.0],
	["sonda_kapi_tolga", Vector3(0.0, 1.62, -0.6), Vector3(0.0, 1.3, 40.0), 70.0],
	["sonda_kapi_giris", Vector3(0.0, 1.62, 7.8), Vector3(0.0, 1.0, 60.0), 70.0],
	["sonda_kapi_giris_sol", Vector3(0.0, 1.62, 7.8), Vector3(-45.0, 1.0, 40.0), 70.0],
	["sonda_kapi_giris_sag", Vector3(0.0, 1.62, 7.8), Vector3(45.0, 1.0, 40.0), 70.0],
	["sonda_kapi_tele", Vector3(0.0, 1.62, 7.8), Vector3(0.0, 9.0, 482.0), 22.0],
]
## Dışarıdan ve havadan otağın kapısına (salon yereli; "in" kipinde salonun kabuğu ve dilimin sınırı görünür)
const OUT_SHOTS := [
	["sonda_dis_kapiya", Vector3(0.0, 1.7, 34.0), Vector3(0.0, 3.0, 6.0), 70.0],
	["sonda_hava_kapiya", Vector3(14.0, 38.0, 70.0), Vector3(0.0, 2.0, 4.0), 70.0],
	["sonda_hava_yakin", Vector3(10.0, 20.0, 26.0), Vector3(0.0, 3.0, 0.0), 50.0],
]

var mode := "in"
var out_dir := "/tmp/sonda"
var cam: Camera3D


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--mode="):
			mode = a.substr(7)
		elif a.begins_with("--out="):
			out_dir = a.substr(6)
	DirAccess.make_dir_recursive_absolute(out_dir)
	var to_scene := Transform3D.IDENTITY        # salon yereli -> bu sahne
	var t0 := Time.get_ticks_msec()
	if mode == "in":
		var hall := OtagHall.new()
		add_child(hall)
	else:
		var camp := CampDay.new()
		add_child(camp)
		to_scene = World1453.region("camp").affine_inverse() * World1453.region("otag")
	print("SONDA mode=%s build=%dms" % [mode, Time.get_ticks_msec() - t0])
	cam = Camera3D.new()
	cam.fov = 70.0
	cam.far = 4000.0
	add_child(cam)
	cam.current = true
	for i in 150:
		await get_tree().process_frame
	var list: Array = SHOTS.duplicate()
	list.append_array(OUT_SHOTS)        # "in": salonun dış kabuğu ve dilimin sınırı havadan (ölçü karşılaştırması)
	for s in list:
		if mode != "in" and Vector2((s[1] as Vector3).x, (s[1] as Vector3).z).length() < 7.3:
			continue
		cam.fov = s[3]
		var eye: Vector3 = to_scene * (s[1] as Vector3)
		var at: Vector3 = to_scene * (s[2] as Vector3)
		cam.global_position = eye
		cam.look_at(at, Vector3.UP)
		for i in 8:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		var path := out_dir.path_join("%s_%s.png" % [s[0], mode])
		img.save_png(path)
		var w := World1453.region("otag") * (s[1] as Vector3)
		print("SONDA shot %s eye_world=(%.1f, %.1f, %.1f) draws=%d prims=%dk" % [path, w.x, w.y, w.z,
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) / 1000])
	get_tree().quit()
