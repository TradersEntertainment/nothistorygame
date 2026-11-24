extends "res://tests/_ist/bakis_kare.gd"
## Kapı geçidine düşen sur dibi eteği üçgenleri (teşhis): adı `ad` içeren görünür ağların, geçidin içine (dünya |x−x0| < yarim,
## z0 < z < z1) düşen üçgen köşelerini z dilimlerine göre özetler (en düşük/yüksek y, ağın yolu).
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/etek_sonda.tscn -- \
##     bolum=8y etek=0,2.4,-14,30 [ad=SurDibiEtek] [bas=8]
## Satırlar: ETEK z=… n=… y=[min..max] yol=… · ETEK_BITTI

var etek := ""
var ad := "SurDibiEtek"


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2 and kv[0] == "etek":
			etek = kv[1]
		if kv.size() == 2 and kv[0] == "ad":
			ad = kv[1]
	super._ready()


func _tam_boy() -> void:
	var v := etek.split(",")
	var x0 := float(v[0])
	var yarim := float(v[1])
	var z0 := float(v[2])
	var z1 := float(v[3])
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(maxf(bas, 1.0) * 1000.0):
		await get_tree().process_frame
	for n in get_tree().root.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree() or not String(mi.get_path()).contains(ad):
			continue
		var f := mi.mesh.get_faces()
		var dil := {}
		for i in f.size():
			var p: Vector3 = mi.global_transform * f[i]
			if absf(p.x - x0) < yarim and p.z > z0 and p.z < z1:
				var k := int(floor(p.z))
				var e: Array = dil.get(k, [INF, -INF, 0])
				dil[k] = [minf(e[0], p.y), maxf(e[1], p.y), int(e[2]) + 1]
		var ks := dil.keys()
		ks.sort()
		for k in ks:
			print("ETEK z=%d n=%d y=[%.2f..%.2f] yol=%s" % [k, dil[k][2], dil[k][0], dil[k][1], String(mi.get_path()).right(80)])
	print("ETEK_BITTI")
	get_tree().quit()
