extends "res://tests/_ist/bakis_kare.gd"
## G18: bakis_kare'nin hub'ı bekleyen eşi. `sonda=` ve `bak=` hub bölümlerinde (10h, 12b, 13, 23, 24, 6, 7) hub kurulmadan
## (13: büro sahnesinden sonra; 6/7: akışın içinde) çalışırsa yanlış dünyayı ölçer. Burada önce hub beklenir:
## IstBaglama.aktif_bolge == "byz_walls" ve sahnede "SurHub" düğümü (en çok 120 sn; yoksa GOZ18_HUB_YOK satırı ve
## yine de ölçülür). hub=0: beklemeden (8y, 31o, 18b, 25, 36b … bakis_kare ile aynı).
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/goz18_sonda.tscn -- \
##     bolum=10h sonda=30,5.9,58,5.9 [bak=31,1.6,5.9,90 shots=KLASÖR] [cesit=byz] [hub=0]
## Satırlar: GOZ18_HUB t=… · BAKIS_SONDA … · BAKIS_TAMBOY … · BAKIS_BITTI

var hub_bekle := true
var bekle_oz := ""     # bekle=city: bölüm düğümünün bu özelliği dolana dek bekle (25: ayin evresinin ByzCity'si), sonra 4 sn


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2 and kv[0] == "hub":
			hub_bekle = kv[1] != "0"
		if kv.size() == 2 and kv[0] == "bekle":
			bekle_oz = kv[1]
	super._ready()


func _oz_bekle() -> void:
	if bekle_oz == "":
		return
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 300000:
		if is_instance_valid(ch) and ch.get(bekle_oz) != null:
			print("GOZ18_BEKLE %s t=%.1f" % [bekle_oz, (Time.get_ticks_msec() - t0) / 1000.0])
			var t1 := Time.get_ticks_msec()
			while Time.get_ticks_msec() - t1 < 4000:
				await get_tree().process_frame
			return
		await get_tree().process_frame
	print("GOZ18_BEKLE_YOK %s" % bekle_oz)


func _hub_bekle() -> void:
	if not hub_bekle:
		return
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 120000:
		if IstBaglama.aktif_bolge == "byz_walls" and get_tree().root.find_child("SurHub", true, false) != null:
			print("GOZ18_HUB t=%.1f" % ((Time.get_ticks_msec() - t0) / 1000.0))
			return
		await get_tree().process_frame
	print("GOZ18_HUB_YOK bolum=%s bolge=%s" % [bolum, IstBaglama.aktif_bolge])


func _sonda() -> void:
	await _hub_bekle()
	await super._sonda()
	if bak == "":
		_bitir("sonda")


## bul=x,y,z[;x,y,z…]: o noktayı (±0,5 m) kapsayan görünür ağları basar (GOZ18_BUL yol, ağ türü, renk)
func _g18_bul(s: String) -> void:
	for parca in s.split(";"):
		var v := parca.split(",")
		var p := Vector3(float(v[0]), float(v[1]), float(v[2]))
		for n in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
			var gi := n as GeometryInstance3D
			if not gi.is_visible_in_tree():
				continue
			var ab: AABB = gi.global_transform * gi.get_aabb()
			if gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh != null and ab.grow(0.5).has_point(p):
				var mmx := (gi as MultiMeshInstance3D).multimesh
				for k in mmx.instance_count:
					var iab: AABB = gi.global_transform * mmx.get_instance_transform(k) * mmx.mesh.get_aabb()
					if iab.grow(0.5).has_point(p):
						print("GOZ18_BUL_MM p=%s yol=%s ornek=%d iab=%s gor=[%.0f,%.0f] uzak=%.1f meta=%s" % [p, String(gi.get_path()).right(90), k, iab,
							gi.visibility_range_begin, gi.visibility_range_end, gi.global_position.distance_to(Vector3(float(bak.split(",")[0]), float(bak.split(",")[1]), float(bak.split(",")[2]))) if bak != "" else -1.0,
							mmx.mesh.resource_name])
				continue
			if ab.grow(0.5).has_point(p):
				var tur := ""
				var renk := ""
				if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
					tur = (gi as MeshInstance3D).mesh.get_class()
				var m := gi.material_override
				if m is BaseMaterial3D:
					renk = (m as BaseMaterial3D).albedo_color.to_html(false)
				print("GOZ18_BUL p=%s yol=%s tur=%s/%s renk=%s ab=%s" % [p, String(gi.get_path()).right(110), gi.get_class(), tur, renk, ab])
				var ust := gi.get_parent()
				var bilgi := "ust_betik=%s ust_ad=%s meta=%s gor=[%.0f,%.0f]" % [ust.get_script().resource_path if ust.get_script() else "-", ust.name, gi.get_meta_list(), gi.visibility_range_begin, gi.visibility_range_end]
				if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
					var me := (gi as MeshInstance3D).mesh
					for si in me.get_surface_count():
						var sm := me.surface_get_material(si)
						bilgi += " yuzey%d=%s/%s" % [si, sm.resource_name if sm else "-", (sm as BaseMaterial3D).albedo_color.to_html(false) if sm is BaseMaterial3D else ""]
				print("GOZ18_BUL_EK " + bilgi)


func _tam_boy() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("bul="):
			await get_tree().create_timer(maxf(bas, 1.0)).timeout
			_g18_bul(a.trim_prefix("bul="))
		if a.begins_with("gizle="):
			# teşhis: yolunda bu parça geçen ağlar gizlenir (hangi ağın ne olduğunu karede görmek için)
			await get_tree().create_timer(maxf(bas, 1.0)).timeout
			for n in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
				if String(n.get_path()).contains(a.trim_prefix("gizle=")):
					(n as GeometryInstance3D).visible = false
					print("GOZ18_GIZLE %s" % n.get_path())
	if sonda == "":
		await _hub_bekle()
	await _oz_bekle()
	await super._tam_boy()
