extends Node
## G21 kare sondası (eski dünya: ordugâh bölümleri ve 43o): bölümü kurar, arayüzü gizler, listedeki bakışlardan kare alır.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --rendering-driver opengl3 --resolution 1280x720 \
##       res://tests/_ist/lykos21_kare.tscn -- bolum=43o shots=KLASÖR liste=DOSYA [v2=1] [on=ONEK] [bekle=SN]
## liste: her satır "ad x y z hedef_x hedef_y hedef_z" (eski dünya koordinatı; '#' yorum).
## v2=1: gerçek oyundaki gibi önce bir v2 bölümü kurulmuş sayılır (IstSehir.enabled = v2 = true; docs rapor D6):
## eski dünyanın şehir dokusu IstSehir'in yolundan kurulur.
## Satırlar: LYKOS21KARE ad=… dosya=…; LYKOS21KARE bitti n=…

var bolum := "43o"
var shots := ""
var liste := ""
var on := ""
var bekle := 8.0
var ch: Node


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"bolum": bolum = kv[1]
			"shots": shots = kv[1]
			"liste": liste = kv[1]
			"on": on = kv[1]
			"bekle": bekle = kv[1].to_float()
			"v2":
				if kv[1] == "1":
					IstSehir.enabled = true
					IstSehir.v2 = true
	_calis.call_deferred()


func _calis() -> void:
	DirAccess.make_dir_recursive_absolute(shots)
	var ps: PackedScene = load("res://scenes/chapter%s.tscn" % bolum)
	ch = ps.instantiate()
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	await get_tree().create_timer(bekle, false).timeout
	for k in 30:
		await get_tree().process_frame
	var cam := Camera3D.new()
	cam.fov = 70.0
	cam.near = 0.1
	cam.far = 20000.0
	ch.add_child(cam)
	var n := 0
	var f := FileAccess.open(liste, FileAccess.READ)
	while f != null and not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var p := line.split(" ", false)
		if p.size() < 7:
			continue
		_gizle()
		cam.current = true
		var fx := _alan_xf()
		var pos := fx * Vector3(p[1].to_float(), p[2].to_float(), p[3].to_float())
		var tgt := fx * Vector3(p[4].to_float(), p[5].to_float(), p[6].to_float())
		cam.global_position = pos
		cam.look_at(tgt, Vector3.UP)
		for k in 45:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var ad := on + p[0] + ".png"
		get_viewport().get_texture().get_image().save_png(shots.path_join(ad))
		print("LYKOS21KARE ad=%s dosya=%s" % [p[0], ad])
		n += 1
	print("LYKOS21KARE bitti n=%d bolum=%s v2=%s" % [n, bolum, str(IstSehir.v2)])
	get_tree().quit()


## Arayüz, sis perdesi ve oyuncu kamerası gizlenir (yalnız dünya görünsün)
func _gizle() -> void:
	for c in ch.find_children("*", "CanvasLayer", true, false):
		(c as CanvasLayer).visible = false
	for c in get_tree().root.get_children():
		if c is CanvasLayer:
			(c as CanvasLayer).visible = false
		for cc in c.find_children("*", "CanvasLayer", true, false):
			(cc as CanvasLayer).visible = false


## Eski dünyanın (SiegeField: yereli World1453 dünya koordinatı) küresel dönüşümü; bölüm kendi yerelinde kurulur
func _alan_xf() -> Transform3D:
	for n in ch.find_children("*", "Node3D", true, false):
		if n is SiegeField:
			return (n as Node3D).global_transform
	return Transform3D.IDENTITY
