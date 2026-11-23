extends Node
## TUR 15: HornWorld'ün kurduğu görünüşün karması (öteki bölümler bit bit aynı mı). Bölümü gerçek akışında açar, HornWorld
## kurulunca altındaki her GeometryInstance3D'nin adı, sınıfı, dönüşümü, ağ köşeleri (yüzey dizileri), MultiMesh örnek
## dönüşümleri ve görünürlük uzaklığı tek karmaya katılır. ÖNCE | SONRA aynı satır = aynı görünüş.
##   godot --headless --path . res://tests/_ist/tur15_karma.tscn -- bolum=8
## Satır: T15KARMA bolum=… horn=… dugum=… ucgen=… karma=…

var bolum := "8"


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2 and kv[0] == "bolum":
			bolum = kv[1]
	GameState.autotest = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_surus.call_deferred()


func _surus() -> void:
	match bolum:
		"6":
			GameState.chapter_outcomes[4] = "4b.1"
		"7":
			GameState.chapter_outcomes[6] = "6b.1"
		"10h", "12b", "13", "23", "24":
			GameState.chapter_outcomes[8] = "8.1"
	var ch := (load("res://scenes/chapter%s.tscn" % bolum) as PackedScene).instantiate()
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	var t0 := Time.get_ticks_msec()
	var horn: Node = null
	while horn == null and Time.get_ticks_msec() - t0 < 120000:
		await get_tree().process_frame
		for c: Node in ch.find_children("*", "Node3D", true, false):
			if c is HornWorld:
				horn = c
				break
	if horn == null:
		print("T15KARMA bolum=%s horn=yok" % bolum)
		get_tree().quit()
		return
	# HornWorld.build tek karede (await yok) biter; uzak siluet ve savunanlar sonda: iki kare bekle
	for i in 3:
		await get_tree().process_frame
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	var n := 0
	var tri := 0
	for g: Node in horn.find_children("*", "GeometryInstance3D", true, false):
		var gi := g as GeometryInstance3D
		n += 1
		ctx.update(("%s|%s|%s|%s|%.2f|%s\n" % [horn.get_path_to(gi), gi.get_class(), gi.transform, gi.visible, gi.visibility_range_end, gi.cast_shadow]).to_utf8_buffer())
		var m: Mesh = null
		if gi is MeshInstance3D:
			m = (gi as MeshInstance3D).mesh
		elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh != null:
			var mm := (gi as MultiMeshInstance3D).multimesh
			m = mm.mesh
			ctx.update(("mm %d\n" % mm.instance_count).to_utf8_buffer())
			for k in mm.instance_count:
				ctx.update(var_to_bytes(mm.get_instance_transform(k)))
		if m != null:
			for s in m.get_surface_count():
				var arr := m.surface_get_arrays(s)
				var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				ctx.update(v.to_byte_array())
				if arr[Mesh.ARRAY_COLOR] is PackedColorArray:
					ctx.update((arr[Mesh.ARRAY_COLOR] as PackedColorArray).to_byte_array())
				var idx = arr[Mesh.ARRAY_INDEX]
				tri += ((idx as PackedInt32Array).size() if idx is PackedInt32Array else v.size()) / 3
	print("T15KARMA bolum=%s horn=%s dugum=%d ucgen=%d karma=%s" % [bolum, horn.get("region_name"), n, tri, ctx.finish().hex_encode()])
	get_tree().quit()
