class_name IstOrdugahYonetici
extends Node3D
## Ordugâh akışı: her öğe başta lod 2 (uzak siluet) kurulur; kameraya yaklaştıkça lod 1 → 0 (zaman dilimli, karede ≤ 1 yapı).
## Kameradan uzaklaşınca bir alt ayrıntıya döner (bellek). v2 dünyasında IstOrdugah.attach() bunu ekler.

const K = preload("res://scripts/world/ist/ordugah_kit.gd")

var gece := false
var items: Array = []
var kuyruk: Array = []            # [öğe indeksi, lod]
var _t := 0.0
var _hazir_lod2 := false
## Yakın lod eşikleri (öğe yarıçapına eklenir; dünya metre)
var lod0_m := 120.0           # ŞEHİR-3: 230 → 120 (sık çadır denizinde yakın katman 4–5 M üçgen oluyordu)
var lod1_m := 450.0           # 800 → 450 (ötesi hücre başına pişmiş uzak ağ)
var butce_us := 9000
var kurulan := 0
var kur_ms := {}                  # ORDUGÂH-4: tür_lod → en uzun tek kurulum (ms)
var bakan: Node3D                 # yoksa etkin kamera


## Uzak katman (ŞEHİR-3): öğelerin lod 2'si açılışta kurulup HÜCRE başına tek ağa pişirilir (önce öğe başına 3–5 çizim:
## şehrin ortasından bile ~500 çizim). Hücre yakına gelince (lod1_m + hücre yarıçapı) içindeki öğeler tek tek lod 1/0
## kurulur, hepsi kurulunca hücre ağı gizlenir; uzaklaşınca öğeler boşaltılır, hücre ağı yine görünür.
const HUCRE := 320.0
var hucreler: Array = []          # {c: Vector2, r, mi: MeshInstance3D, idx: [i]}
var uzak_ms := 0


func kur(plan: Array) -> void:
	# yeniden kurulum (IstBaglama._temizle öğe listesini süzüp yeniden çağırır): eski hücre ağları kalkar
	for h: Dictionary in hucreler:
		if is_instance_valid(h["mi"]):
			(h["mi"] as Node).queue_free()
	hucreler.clear()
	items = plan
	var t0 := Time.get_ticks_msec()
	var by := {}
	for i in items.size():
		var it: Dictionary = items[i]
		var p: Vector2 = it["pos"]
		it["y"] = IstGeo.h(p.x, p.y)
		it["lod"] = 2
		it["host"] = null
		var ck := Vector2i(floori(p.x / HUCRE), floori(p.y / HUCRE))
		if not by.has(ck):
			by[ck] = []
		by[ck].append(i)
	for ck: Vector2i in by:
		var cen := Vector2((ck.x + 0.5) * HUCRE, (ck.y + 0.5) * HUCRE)
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var rmax := 0.0
		var n := 0
		var ates_x: Array = []
		for i: int in by[ck]:
			var it: Dictionary = items[i]
			var host := _kur_host(i, 2)
			var base := Transform3D(Basis(Vector3.UP, float(it["yaw"])), Vector3((it["pos"] as Vector2).x - cen.x, float(it["y"]), (it["pos"] as Vector2).y - cen.y))
			n += _pisir(host, host, base, st)
			# ORDUGÂH-5: gece uzak katmanda ocaklar ışıyan nokta (hücre başına tek çoklu ağ hale; ufka kadar ateş)
			if gece and host.has_meta("ates"):
				for fp: Vector2 in host.get_meta("ates"):
					var wp := base * Vector3(fp.x, 0.0, fp.y)
					var gy := IstGeo.h(cen.x + wp.x, cen.y + wp.z)
					ates_x.append(Transform3D(Basis().scaled(Vector3.ONE * 4.2), Vector3(wp.x, gy + 0.7, wp.z)))
			host.free()
			rmax = maxf(rmax, (it["pos"] as Vector2).distance_to(cen) + float(it["r"]))
		var mi := MeshInstance3D.new()
		mi.name = "OrduUzak_%d_%d" % [ck.x, ck.y]
		if n > 0:
			mi.mesh = st.commit()
		mi.material_override = _uzak_mat()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.position = Vector3(cen.x, 0, cen.y)
		mi.set_meta("no_walk", true)
		add_child(mi)
		if not ates_x.is_empty():
			var g := Flame.scatter_glows(mi, ates_x, 0.9)
			g.name = "uzak_ateş"
		hucreler.append({"c": cen, "r": rmax, "mi": mi, "idx": by[ck], "yakin": false})
	uzak_ms = Time.get_ticks_msec() - t0
	print("ISTORDU uzak_hucre=%d ms=%d" % [hucreler.size(), uzak_ms])


static var _umat: StandardMaterial3D

static func _uzak_mat() -> StandardMaterial3D:
	if _umat == null:
		_umat = StandardMaterial3D.new()
		_umat.vertex_color_use_as_albedo = true
		_umat.vertex_color_is_srgb = true
		_umat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		_umat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		_umat.roughness = 1.0
	return _umat


## host altındaki görünür ağları (MeshInstance3D ve MultiMesh örnekleri) st'ye köşe renkli üçgen olarak ekler
func _pisir(top: Node, n: Node, xf: Transform3D, st: SurfaceTool) -> int:
	var cnt := 0
	for c in n.get_children():
		if c is Node3D and not (c as Node3D).visible:
			continue
		var cx := xf * ((c as Node3D).transform if c is Node3D else Transform3D.IDENTITY)
		if c is GeometryInstance3D and _parlak((c as GeometryInstance3D).material_override):
			continue
		if c is MeshInstance3D and (c as MeshInstance3D).mesh != null:
			var mi := c as MeshInstance3D
			if _parlak(mi.get_active_material(0)):
				continue
			for si in mi.mesh.get_surface_count():
				cnt += _ekle(st, mi.mesh, si, cx, _renk(mi.get_active_material(si)), false)
		elif c is MultiMeshInstance3D and (c as MultiMeshInstance3D).multimesh != null:
			var mm := (c as MultiMeshInstance3D).multimesh
			if mm.mesh == null:
				continue
			var mcol := _renk((c as MultiMeshInstance3D).material_override if (c as MultiMeshInstance3D).material_override else mm.mesh.surface_get_material(0))
			for k in mm.instance_count:
				var ic := mm.get_instance_color(k) if mm.use_colors else Color.WHITE
				for si in mm.mesh.get_surface_count():
					cnt += _ekle(st, mm.mesh, si, cx * mm.get_instance_transform(k), mcol * ic, true)
		if c is Node3D and not (c is GeometryInstance3D):
			cnt += _pisir(top, c, cx, st)
	return cnt


## alev, ışık, saydam: pişmiş uzak ağa girmez
static func _parlak(m: Material) -> bool:
	if m is ShaderMaterial:
		return true
	if m is BaseMaterial3D:
		var bm := m as BaseMaterial3D
		return (bm.emission_enabled and bm.emission_energy_multiplier > 0.5) or (bm.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and bm.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR)
	return false


static func _renk(m: Material) -> Color:
	if m is BaseMaterial3D:
		var bm := m as BaseMaterial3D
		if bm.vertex_color_use_as_albedo:
			return Color.WHITE
		return bm.albedo_color * World1453._avg(bm.albedo_texture)
	return Color(0.8, 0.75, 0.65)


static func _ekle(st: SurfaceTool, m: Mesh, si: int, xf: Transform3D, col: Color, _mm: bool) -> int:
	var arr := m.surface_get_arrays(si)
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var ns = arr[Mesh.ARRAY_NORMAL]
	var cs = arr[Mesh.ARRAY_COLOR]
	var ia = arr[Mesh.ARRAY_INDEX]
	var idx: PackedInt32Array = ia if ia is PackedInt32Array else PackedInt32Array()
	var cnt := idx.size() if idx.size() > 0 else vs.size()
	var nb := xf.basis.inverse().transposed()
	var hasn: bool = ns is PackedVector3Array and (ns as PackedVector3Array).size() == vs.size()
	var hasc: bool = cs is PackedColorArray and (cs as PackedColorArray).size() == vs.size()
	for k in cnt:
		var i: int = idx[k] if idx.size() > 0 else k
		var c := col
		if hasc:
			c = col * (cs as PackedColorArray)[i]
		st.set_color(Color(c.r, c.g, c.b, 1.0))
		st.set_normal((nb * ((ns as PackedVector3Array)[i] if hasn else Vector3.UP)).normalized())
		st.add_vertex(xf * vs[i])
	return cnt / 3


func _cam_pos() -> Vector3:
	if bakan != null and is_instance_valid(bakan):
		return to_local(bakan.global_position)
	var c := get_viewport().get_camera_3d()
	if c != null:
		return to_local(c.global_position)
	return Vector3.ZERO


func _process(delta: float) -> void:
	_t += delta
	if _t > 0.4:
		_t = 0.0
		_planla()
	var t0 := Time.get_ticks_usec()
	while not kuyruk.is_empty() and Time.get_ticks_usec() - t0 < butce_us:
		var q: Array = kuyruk.pop_front()
		_kur_item(q[0], q[1])


func _planla() -> void:
	var cp := _cam_pos()
	var istek: Array = []
	for h: Dictionary in hucreler:
		var dh := Vector2(cp.x, cp.z).distance_to(h["c"]) - float(h["r"])
		var lim := lod1_m * (1.15 if h["yakin"] else 1.0)
		h["yakin"] = dh < lim
		var hepsi := true
		for i: int in h["idx"]:
			var it: Dictionary = items[i]
			var p: Vector2 = it["pos"]
			var d := Vector2(cp.x, cp.z).distance_to(p)
			var r: float = it["r"]
			var want := 2
			var cur: int = it["lod"]
			var k0 := lod0_m + r
			if cur == 0:
				k0 *= 1.15
			if h["yakin"]:
				want = 0 if d < k0 else 1
			if cur != want and not _kuyrukta(i):
				istek.append([d, i, want])
			if want < 2 and cur == 2:
				hepsi = false
		# hücrenin pişmiş uzak ağı: yakınken öğelerin hepsi kurulunca gizlenir (delik kalmaz), uzakta görünür
		(h["mi"] as MeshInstance3D).visible = not (h["yakin"] and hepsi)
	istek.sort_custom(func(a, b): return a[0] < b[0])
	for e in istek:
		if kuyruk.size() > 24:
			break
		kuyruk.append([e[1], e[2]])


func _kuyrukta(i: int) -> bool:
	for q in kuyruk:
		if q[0] == i:
			return true
	return false


func _kur_item(i: int, lod: int) -> void:
	var it: Dictionary = items[i]
	if it["lod"] == lod:
		return
	if lod == 2:
		# uzak: hücrenin pişmiş ağı çizer; öğenin kendi katmanı boşaltılır (hücre ağı önce görünür olur)
		for h: Dictionary in hucreler:
			if i in (h["idx"] as Array):
				(h["mi"] as MeshInstance3D).visible = true
		var e2 = it["host"]
		if e2 != null and is_instance_valid(e2):
			(e2 as Node).queue_free()
		it["host"] = null
		it["lod"] = 2
		return
	var t0 := Time.get_ticks_usec()
	var host := _kur_host(i, lod)
	var dt := (Time.get_ticks_usec() - t0) / 1000.0
	var key := "%s_l%d" % [it["kind"], lod]
	kur_ms[key] = maxf(float(kur_ms.get(key, 0.0)), dt)
	var eski = it["host"]
	it["host"] = host
	it["lod"] = lod
	if eski != null and is_instance_valid(eski):
		(eski as Node).queue_free()
	kurulan += 1


func _kur_host(i: int, lod: int) -> Node3D:
	var it: Dictionary = items[i]
	var p: Vector2 = it["pos"]
	var host := Node3D.new()
	host.name = "%s_lod%d" % [it["id"], lod]
	var y: float = it["y"]
	host.position = Vector3(p.x, y, p.y)
	host.rotation.y = it["yaw"]
	add_child(host)
	var yaw: float = it["yaw"]
	var px := p.x
	var pz := p.y
	var py := y
	K.gece = gece
	K.zemin = func(x: float, z: float) -> float:
		var v := Vector3(x, 0, z).rotated(Vector3.UP, yaw)
		return IstGeo.h(px + v.x, pz + v.z) - py
	# kanat süzgeci: su, Galata içi, yarımada içi ve yapı çevreleri dışlanır (yerel x,z)
	# ORDUGÂH-4: yalnız bu öğeye yakın yapılar sınanır (oba yerleşimi binlerce nokta sorar; önce her noktada bütün plan)
	var yakin: Array = []
	var geo_onb := {}
	var hr: float = float(it["r"]) + 6.0
	for j in items.size():
		var o: Dictionary = items[j]
		if o["kind"] == "kanat" or o["kind"] == "siper" or j == i:
			continue
		if (o["pos"] as Vector2).distance_to(p) < hr + float(o["r"]) + 4.0:
			yakin.append([o["pos"], float(o["r"]) + 4.0])
	K.filtre = func(x: float, z: float) -> bool:
		var v := Vector3(x, 0, z).rotated(Vector3.UP, yaw)
		var wx := px + v.x
		var wz := pz + v.z
		# ORDUGÂH-4: kıyı/şehir sınaması 4 m'lik ızgarada önbellekli (oba yerleşimi binlerce nokta sorar)
		var ck := Vector2i(floori(wx / 4.0), floori(wz / 4.0))
		var geo_ok = geo_onb.get(ck)
		if geo_ok == null:
			geo_ok = not (IstGeo.su(wx, wz) or IstGeo.sehir_ici(wx, wz) or IstGeo.galata_ici(wx, wz))
			geo_onb[ck] = geo_ok
		if not geo_ok:
			return false
		var wp := Vector2(wx, wz)
		for o: Array in yakin:
			if (o[0] as Vector2).distance_to(wp) < float(o[1]):
				return false
		return true
	IstOrdugah.uret(it, host, lod)
	K.zemin = Callable()
	K.filtre = Callable()
	if lod == 2:
		remove_child(host)
	return host
