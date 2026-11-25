extends Node
## G19: bölüm sahnesinin bütün görünüşü ve çarpışması tek karmada (KESME B "bit bit aynı" denetimi). Bölüm köke eklenir,
## _ready döner dönmez (hiç kare geçmeden: akış/zaman dilimli işler karışmasın) ağaçtaki her GeometryInstance3D (yol,
## sınıf, küresel dönüşüm, görünürlük, ağ köşeleri/renkleri, MultiMesh örnekleri) ve her CollisionShape3D (küresel
## dönüşüm, biçim) karmaya katılır. Silinmek üzere işaretli (queue_free) alt ağaçlar atlanır. Kendiliğinden verilen
## düğüm adlarındaki sayaç (@Sınıf@N) atılır. ÖNCE | SONRA aynı satır = aynı görünüş ve çarpışma.
##   godot --headless --path . res://tests/_yukleme19/sahne_karma.tscn -- bolum=8y
## Satır: SAHNEKARMA bolum=… geo=… carp=… ucgen=… gorunus=… carpisma=…

var bolum := "8y"
var _mesh_h := {}
var _rx := RegEx.create_from_string("@[0-9]+")


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
	seed(1453)
	var ch := (load("res://scenes/chapter%s.tscn" % bolum) as PackedScene).instantiate()
	get_tree().root.add_child(ch)
	var g := HashingContext.new()
	g.start(HashingContext.HASH_MD5)
	var c := HashingContext.new()
	c.start(HashingContext.HASH_MD5)
	var n_g := 0
	var n_c := 0
	var tri := 0
	var st: Array = [ch]
	while not st.is_empty():
		var n: Node = st.pop_back()
		if n.is_queued_for_deletion():
			continue
		var kids := n.get_children()
		kids.reverse()
		st.append_array(kids)
		if n is GeometryInstance3D:
			var gi := n as GeometryInstance3D
			if not gi.is_inside_tree():
				continue
			n_g += 1
			g.update(("%s|%s|%s|%s|%.2f|%.2f|%s\n" % [_yol(ch, gi), gi.get_class(), gi.global_transform, gi.is_visible_in_tree(),
				gi.visibility_range_begin, gi.visibility_range_end, gi.cast_shadow]).to_utf8_buffer())
			var m: Mesh = null
			if gi is MeshInstance3D:
				m = (gi as MeshInstance3D).mesh
			elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh != null:
				var mm := (gi as MultiMeshInstance3D).multimesh
				m = mm.mesh
				g.update(("mm %d %d\n" % [mm.instance_count, mm.visible_instance_count]).to_utf8_buffer())
				g.update(mm.get("buffer").to_byte_array() if mm.get("buffer") is PackedFloat32Array else PackedByteArray())
			if m != null:
				var mh: Array = _mesh(m)
				g.update((mh[0] as String).to_utf8_buffer())
				tri += int(mh[1])
		elif n is CollisionShape3D:
			var cs := n as CollisionShape3D
			if not cs.is_inside_tree() or cs.shape == null:
				continue
			n_c += 1
			var sh := cs.shape
			var d := ""
			if sh is BoxShape3D:
				d = str((sh as BoxShape3D).size)
			elif sh is SphereShape3D:
				d = str((sh as SphereShape3D).radius)
			elif sh is CapsuleShape3D:
				d = "%s %s" % [(sh as CapsuleShape3D).radius, (sh as CapsuleShape3D).height]
			elif sh is CylinderShape3D:
				d = "%s %s" % [(sh as CylinderShape3D).radius, (sh as CylinderShape3D).height]
			elif sh is ConvexPolygonShape3D:
				d = str(hash((sh as ConvexPolygonShape3D).points))
			elif sh is ConcavePolygonShape3D:
				d = str(hash((sh as ConcavePolygonShape3D).get_faces()))
			elif sh is HeightMapShape3D:
				d = str(hash((sh as HeightMapShape3D).map_data))
			elif sh is WorldBoundaryShape3D:
				d = str((sh as WorldBoundaryShape3D).plane)
			c.update(("%s|%s|%s|%s|%s\n" % [_yol(ch, cs), sh.get_class(), cs.global_transform, cs.disabled, d]).to_utf8_buffer())
	print("SAHNEKARMA bolum=%s geo=%d carp=%d ucgen=%d gorunus=%s carpisma=%s" % [bolum, n_g, n_c, tri,
		g.finish().hex_encode(), c.finish().hex_encode()])
	get_tree().quit()


func _yol(ch: Node, n: Node) -> String:
	return _rx.sub(String(ch.get_path_to(n)), "@", true)


func _mesh(m: Mesh) -> Array:
	var k := m.get_rid()
	if _mesh_h.has(k):
		return _mesh_h[k]
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	var tri := 0
	for s in m.get_surface_count():
		var arr := m.surface_get_arrays(s)
		var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		ctx.update(v.to_byte_array())
		if arr[Mesh.ARRAY_COLOR] is PackedColorArray:
			ctx.update((arr[Mesh.ARRAY_COLOR] as PackedColorArray).to_byte_array())
		var idx = arr[Mesh.ARRAY_INDEX]
		if idx is PackedInt32Array:
			ctx.update((idx as PackedInt32Array).to_byte_array())
		tri += ((idx as PackedInt32Array).size() if idx is PackedInt32Array else v.size()) / 3
	var r := [ctx.finish().hex_encode(), tri]
	_mesh_h[k] = r
	return r
