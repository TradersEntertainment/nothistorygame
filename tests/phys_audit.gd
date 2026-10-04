extends SceneTree
## Fizik denetimi (oynanabilirlik taraması):
##   godot --headless --path . -s tests/phys_audit.gd -- OUTDIR res://scenes/chapterN.tscn VARIANT [EVRE_SAYISI]
## Bölüm otomatik testte kendi kendine oynarken her yeni hedefte (evre) oyun dondurulur ve oyuncunun
## gerçekten yapabildikleri, gördükleriyle karşılaştırılır:
##   1. Oyuncu kapsülüyle ızgarada taşkın doldurma: nereye yürünebilir / zıplanabilir (0.62 m).
##   2. Sahnedeki bütün görünür ağlar ayrı bir fizik uzayına üçgen olarak kopyalanır ("görünen dünya").
##      Yürünen her adım ve durulan her hücre orada da denenir.
## Satırlar ("PHYS <tür> ..."):
##   GHOST   görünen bir nesnenin içinden yürünüyor (nesnenin çarpışması yok)
##   SINK    görünen zemin fizik zemininden yüksek: ayak nesnenin içine gömülüyor
##   AIR     fizik zemini var, görünen zemin yok: havada durulan yer (görünmez zemin)
##   IWALL   görünmez duvar: fizik engelliyor, orada görünen bir şey yok
##   VOID    zemin biter: oyuncu dünyanın dışına düşer
##   DROP    3 m'den büyük düşüş
##   SPAWN   oyuncu evre başında bir katının içinde
##   TARGET  hedef işaretinin 3 m yakınına yürünemiyor
##   FLOAT / VFLOAT / VSUNK / CLIP / INSOLID / OVERLAP  karakter havada / görünen zemini yok / ayağı nesnede /
##           gövdesi görünen bir ağın içinde / katının içinde / iki kişi iç içe
##   MMFLOAT çoğaltılmış (MultiMesh) nesne ya da kalabalık havada
##   SLIDE / WALKFALL / WALKBLOCK  yürüyen bot (oyuncunun gerçek gövdesi, move_and_slide): durulamayan yer / yürürken
##           zeminden düşme / düz ya da alçak adımda takılma
## Her evre için üstten PNG (OUTDIR) ve sonunda özet: "PHYSSUM ...".

const STEP := 1.0
const UP := 0.62        # zıplayarak çıkılabilecek basamak (JUMP 3.6 m/s, g 9.8)
const SLOPE_UP := 1.2   # 1 m'lik adımda yürünür eğimin en çok yükselişi (~50°)
const MAXC := 50000
const VIS := 1          # görünen dünya uzayında katman

## Bölüm betiğinin konumla bitirdiği evreler (tetik çizgisi): taşkın bu kutunun dışına çıkmaz.
## Anahtar: sahne dosyası; değer: [AABB] (evre ayrımı yok, oyuncunun o sahnede gidebileceği en geniş alan).
const BOUNDS := {
	"chapter4.tscn": [AABB(Vector3(-200, -50, -200), Vector3(400, 100, 209.5))],   # z > 9.5: kaçış (Camp.ESCAPE_Z)
	"chapter33o.tscn": [AABB(Vector3(-90, -10, -80), Vector3(190, 80, 79.5))],     # rıhtım, iskele, kule, batarya (ötesi yamaç)
}

var out_dir := ""
var scene_path := ""
var _ref := Vector3.ZERO     # uzaklıkların ölçüldüğü nokta (evre başında oyuncu, ara denetimde kamera)
var variant := ""
var max_phase := 14
var _seen := {}          # tekilleştirme anahtarı -> true
var _count := {}         # tür -> tekil sayı
var _vspace: RID
var _vstate: PhysicsDirectSpaceState3D
var _vbodies: Array[RID] = []
var _vshapes: Array[RID] = []
var _vdesc := {}         # gövde RID -> açıklama
var _vfaces := {}        # gövde RID -> dünya koordinatında üçgenler (arka yüz sınaması için)
var _vinst := {}         # "çoğaltılmış ağın yolu#örnek" -> gövde RID (örneğin kendi gövdesi ışından dışlanır)
var _dbg_mm := OS.get_environment("PHYS_DBG_MM")
var _vgrid := {}         # görünen dünyaya ek bölgeler: 8 m'lik xz kareleri (Vector2i -> true)
var _t0 := 0


func _initialize() -> void:
	_run()


func _finalize() -> void:
	_dump()
	var parts: Array[String] = []
	for k in _count:
		parts.append("%s=%d" % [k, _count[k]])
	print("PHYSSUM scene=%s variant=%s %s" % [scene_path.get_file(), variant, " ".join(parts)])


func _run() -> void:
	var a := OS.get_cmdline_user_args()
	out_dir = a[0]
	scene_path = a[1]
	variant = a[2] if a.size() > 2 else ""
	max_phase = int(a[3]) if a.size() > 3 else 14
	DirAccess.make_dir_recursive_absolute(out_dir)
	# Gerçek görüntü sunucusu gerekli (başsız modda MultiMesh örnek konumları saklanmaz), ama 3B çizim gereksiz: kareler
	# ucuz kalsın. Çizim döngüsü açık kalır (frame_post_draw bekleyen fotoğraf/kart akışları takılmasın).
	root.disable_3d = true
	var gs = root.get_node("GameState")
	var trailer := scene_path.contains("trailer")
	if not trailer:
		gs.autotest = true
		gs.autotest_variant = variant
		# Açılışın (boot.gd) yaptığı gibi önceki bölümlerin varsayılanları (çanta, bayraklar, kuşatma tarafı): yoksa
		# bazı bölümlerin otomatik testi (ör. Bölüm 6: çantada nohut) ilerleyemez
		var siege: Dictionary = load("res://scripts/siege.gd").get_script_constant_map()
		var latest: int = gs.get_script().get_script_constant_map().get("LATEST_CHAPTER", 15)
		var ch := scene_path.get_file().get_basename().trim_prefix("chapter").to_int()
		if ch >= siege["FIRST"] and ch <= siege["LAST"]:
			gs.ensure_defaults_for(12)     # kuşatma Bölüm 12 ile 13 arasındadır
			if scene_path.ends_with("o.tscn"):
				gs.flags["siege_side"] = "O"
		elif ch > 1:
			gs.ensure_defaults_for(mini(ch, latest))
	change_scene_to_file(scene_path)
	await create_timer(1.0).timeout
	# Dünya (WorldWalk) katılarını kareler boyunca parça parça kurar: bitmeden ölçülen dünya boşluk sanılır
	var ww_wait := 0
	while ww_wait < 3600 and current_scene != null:
		var busy := false
		for w in current_scene.find_children("WorldWalk", "", true, false):
			if w.get("done") == false:
				busy = true
		if not busy:
			break
		await process_frame
		ww_wait += 1
	if ww_wait > 0:
		print("PHYSWAIT worldwalk frames=%d" % ww_wait)
	var frames := 0
	var phase := 0
	var last_obj := ""
	var last_scene := ""
	var last_tick := 0
	var tick_every := 30 if trailer else 60
	if OS.get_environment("PHYS_NOTICK") == "1":
		tick_every = 1 << 30
	while frames < 60 * 900 and phase < max_phase:
		await physics_frame
		frames += 1
		var sc = current_scene
		if sc == null:
			continue
		if not trailer and ("player" in sc) and sc.player != null and ("hud" in sc) and sc.hud != null:
			if sc.scene_file_path != last_scene:
				last_scene = sc.scene_file_path
				last_obj = ""
			var obj: String = sc.hud._objective.text if sc.hud._objective_box.visible else ""
			if obj != "" and obj != last_obj:
				last_obj = obj
				# Hedefi açan konuşma bitsin (en çok 3 sn): oyuncu serbest kalınca taranır
				var w := 0
				while w < 180 and is_instance_valid(sc) and sc.hud.line_open:
					await physics_frame
					w += 1
				if is_instance_valid(sc) and current_scene == sc and is_instance_valid(sc.player):
					phase += 1
					await _audit(sc, phase, obj)
					last_tick = frames
					continue
		# Ara denetim: kamera ve karakterler (ara sahneler, fragman)
		if frames - last_tick >= tick_every and is_instance_valid(sc) and current_scene == sc:
			last_tick = frames
			await _tick(sc, phase)
	quit()


## Saniyede bir (fragmanda yarım saniyede bir): görünen kameranın 60 m yakınındaki karakterler ve kameranın kendisi.
func _tick(sc: Node, phase: int) -> void:
	var cam := sc.get_viewport().get_camera_3d()
	if cam == null:
		return
	var hud = sc.get("hud") if "hud" in sc else null
	if hud != null and hud._fade.color.a > 0.9:
		return
	_t0 = Time.get_ticks_msec()
	var ts0 := Engine.time_scale
	var eye := cam.global_position
	_ref = eye
	var regions: Array[AABB] = [AABB(eye - Vector3(1, 1, 1), Vector3(2, 2, 2))]
	for p in _people(sc):
		if p.global_position.distance_to(eye) < 60.0:
			regions.append(AABB(p.global_position - Vector3(1.5, 2.0, 1.5), Vector3(3, 4.5, 3)))
	_build_vis(sc, regions, true)
	var space := cam.get_world_3d().direct_space_state
	var excl := _char_rids(sc)
	_check_people(sc, space, excl, phase, eye, true)
	# Kamera bir ağın içinde ya da yakın düzlemi (5 cm) bir yüzeyi kesiyor mu
	var sp := SphereShape3D.new()
	sp.radius = 0.07
	var vq := PhysicsShapeQueryParameters3D.new()
	vq.shape = sp
	vq.collision_mask = VIS
	vq.transform = Transform3D(Basis(), eye)
	var hits := _vstate.intersect_shape(vq, 1)
	if not hits.is_empty() or _inside_vis(eye):
		var desc := _vdesc_of(hits[0]) if not hits.is_empty() else "(ağın içinde)"
		_add("CAMCLIP", _grp(desc), "%d,%d,%d" % [roundi(eye.x * 2), roundi(eye.y * 2), roundi(eye.z * 2)], eye, 0.0,
			"t=%.1f cam=%s %s" % [Time.get_ticks_msec() / 1000.0, _g(eye), cam.get_path()], phase)
	var ms := Time.get_ticks_msec() - _t0
	if ms > 400:
		print("PHYSTICK slow ms=%d people=%d" % [ms, regions.size() - 1])
	_free_vis()
	Engine.time_scale = 0.0
	await physics_frame
	Engine.time_scale = ts0


# ---------------------------------------------------------------- yardımcılar

const CHAR_CLASSES := ["Person", "Soldier", "Hikmet", "Horse", "Chicken", "Cat", "Goat", "ThiefGull", "Player"]
const PEOPLE_CLASSES := ["Person", "Soldier", "Hikmet", "Horse"]


## Betiğin (ya da atalarının) sınıf adı: bu betik otomatik yüklemelerden önce derlendiği için sınıf adları
## (Person, Soldier...) doğrudan kullanılmaz; betik zinciri adla denetlenir.
func _cls_in(n: Object, names: Array) -> bool:
	var s = n.get_script()
	while s != null:
		if (s as Script).get_global_name() in names:
			return true
		s = (s as Script).get_base_script()
	return false


## Görünen bir engel mi (hud.gd ile aynı ölçüt): etkileşim alanları ve görünmez sınırlar sayılmaz.
func _visible_body(n: Object) -> bool:
	if not (n is Node) or String((n as Node).name).begins_with("Interact_") or n is Area3D:
		return false
	var nd := n as Node
	if nd.has_meta("facade") or nd.has_meta("wall"):
		return true
	for c in nd.get_children():
		if c is GeometryInstance3D and (c as GeometryInstance3D).is_visible_in_tree():
			return true
	return false


func _is_char(n: Node) -> bool:
	return _cls_in(n, CHAR_CLASSES) or n.is_in_group("persons") or n.is_in_group("soldiers")


func _char_rids(sc: Node) -> Array[RID]:
	var out: Array[RID] = []
	var stack: Array = [sc]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		if _is_char(n):
			for c in n.find_children("*", "CollisionObject3D", true, false):
				out.append((c as CollisionObject3D).get_rid())
			if n is CollisionObject3D:
				out.append((n as CollisionObject3D).get_rid())
			continue
		for c in n.get_children():
			stack.append(c)
	return out


## Hata ayıklama: PHYS_DBG_AT="x,y,z;x,y,z" noktalarının 0,6 m çevresindeki çarpışma cisimleri (şekil, boyut, yer)
func _dbg_at(space: PhysicsDirectSpaceState3D, phase: int) -> void:
	var spec := OS.get_environment("PHYS_DBG_AT")
	if spec == "":
		return
	var sp := SphereShape3D.new()
	sp.radius = 0.6
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = sp
	q.collision_mask = 0xFFFFFFFF
	for part in spec.split(";"):
		var f := part.split(",")
		if f.size() < 3:
			continue
		var pt := Vector3(float(f[0]), float(f[1]), float(f[2]))
		q.transform = Transform3D(Basis(), pt)
		for h in space.intersect_shape(q, 16):
			var col = h["collider"]
			if not (col is CollisionObject3D):
				continue
			var co := col as CollisionObject3D
			var sh := co.shape_owner_get_shape(co.shape_find_owner(h["shape"]), 0) if co.shape_find_owner(h["shape"]) >= 0 else null
			var sd := "?"
			if sh is BoxShape3D:
				sd = "box %s" % _g((sh as BoxShape3D).size)
			elif sh is CylinderShape3D:
				sd = "cyl r=%.2f h=%.2f" % [(sh as CylinderShape3D).radius, (sh as CylinderShape3D).height]
			elif sh is CapsuleShape3D:
				sd = "cap r=%.2f h=%.2f" % [(sh as CapsuleShape3D).radius, (sh as CapsuleShape3D).height]
			elif sh is SphereShape3D:
				sd = "sphere r=%.2f" % (sh as SphereShape3D).radius
			elif sh is ConvexPolygonShape3D:
				sd = "convex n=%d" % (sh as ConvexPolygonShape3D).points.size()
			elif sh is ConcavePolygonShape3D:
				sd = "trimesh n=%d" % ((sh as ConcavePolygonShape3D).get_faces().size() / 3)
			elif sh != null:
				sd = sh.get_class()
			var owner_node := co.shape_owner_get_owner(co.shape_find_owner(h["shape"])) as Node3D if co.shape_find_owner(h["shape"]) >= 0 else null
			var metas: Array = []
			for m in co.get_meta_list():
				metas.append(str(m))
			print("PHYSDBG phase=%d pt=%s col=%s cls=%s layer=%d shape=%s shape_at=%s basis_y=%s body_at=%s rot=%s meta=%s groups=%s" % [phase, _g(pt), _path_of(co), co.get_class(), co.collision_layer, sd,
				_g(owner_node.global_position) if owner_node else "?", _g(owner_node.global_transform.basis.y) if owner_node else "?", _g(co.global_position), _g(co.global_rotation_degrees), metas, co.get_groups()])


func _path_of(n: Node) -> String:
	var parts: Array[String] = []
	var q := n
	var k := 0
	while q != null and k < 4 and q != current_scene:
		var nm := str(q.name)
		if q.get_script() != null and (q.get_script() as Script).get_global_name() != "":
			nm = (q.get_script() as Script).get_global_name() + ":" + nm
		parts.push_front(nm)
		q = q.get_parent()
		k += 1
	return "/".join(parts)


func _solid_material(m: Material) -> bool:
	if m == null:
		return true
	if m is BaseMaterial3D:
		var b := m as BaseMaterial3D
		if b.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and b.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR \
				and b.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA_HASH:
			return false
		if b.blend_mode != BaseMaterial3D.BLEND_MODE_MIX:
			return false
		if b.billboard_mode != BaseMaterial3D.BILLBOARD_DISABLED:
			return false
		if b.no_depth_test:
			return false
		return true
	if m is ShaderMaterial:
		# Su, gökyüzü, ışık demetleri: gölgelendirici koduna bakılır (saydamsa ya da eklemeliyse katı değil)
		var sh := (m as ShaderMaterial).shader
		if sh == null:
			return true
		var code := sh.code
		return not (code.contains("ALPHA") or code.contains("blend_add") or code.contains("unshaded"))
	return true


func _geom_solid(gi: GeometryInstance3D, mesh: Mesh) -> bool:
	if gi.material_override != null:
		return _solid_material(gi.material_override)
	if mesh == null or mesh.get_surface_count() == 0:
		return false
	var any := false
	for s in mesh.get_surface_count():
		var m: Material = null
		if gi is MeshInstance3D:
			m = (gi as MeshInstance3D).get_active_material(s)
		else:
			m = mesh.surface_get_material(s)
		if _solid_material(m):
			any = true
	return any


# ---------------------------------------------------------------- görünen dünya

## Görünen dünya: bölgeyle (erişilebilir alan + yakın karakterler) kesişen ya da büyük (zemin, sur) bütün görünür,
## katı görünümlü ağlar üçgenleriyle ayrı bir fizik uzayına konur. Kalabalık kopyaları (Crowd) ve uzak katman
## (visibility_range_begin) konmaz: kalabalık ayrıca denetlenir.
func _build_vis(sc: Node, regions: Array[AABB], quiet := false) -> void:
	_vspace = PhysicsServer3D.space_create()
	PhysicsServer3D.space_set_active(_vspace, true)
	var stack: Array = [sc]
	var nmesh := 0
	var nfaces := 0
	var heavy := {}
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		if _is_char(n) or n is CanvasItem:
			continue
		if n is Node3D and not (n as Node3D).visible:
			continue
		for c in n.get_children():
			stack.append(c)
		if not (n is GeometryInstance3D) or n.has_meta("soft"):
			continue      # "soft": çimen gibi içinden yürünen örtü
		var gi := n as GeometryInstance3D
		if gi.visibility_range_begin > 0.0:
			continue
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if mi.mesh == null or mi.skin != null or not _geom_solid(mi, mi.mesh):
				continue
			var ab := mi.global_transform * mi.get_aabb()
			if not _in_regions(ab, regions):
				continue
			var faces := mi.mesh.get_faces()
			if faces.size() < 3:
				continue
			_add_vis(faces, mi.global_transform, _path_of(mi) + " [%s %s]" % [mi.mesh.get_class(), (mi.global_transform.basis.get_scale() * mi.get_aabb().size).snapped(Vector3.ONE * 0.1)] + " @%s" % _g(mi.global_position))
			nmesh += 1
			nfaces += faces.size() / 3
			heavy[_path_of(mi)] = int(heavy.get(_path_of(mi), 0)) + faces.size() / 3
		elif n is MultiMeshInstance3D:
			var mmi := n as MultiMeshInstance3D
			var mm := mmi.multimesh
			if mm == null or mm.mesh == null or not _geom_solid(mmi, mm.mesh) or _is_crowd_mesh(mm.mesh):
				continue
			var lab := mm.mesh.get_aabb()
			var faces := PackedVector3Array()
			var xfs := _mm_xforms(mm)
			var gxf := mmi.global_transform
			for i in xfs.size():
				var xf: Transform3D = gxf * (xfs[i] as Transform3D)
				if absf(xf.basis.determinant()) < 1e-6:
					continue
				if not _in_regions(xf * lab, regions):
					continue
				if faces.is_empty():
					faces = mm.mesh.get_faces()
					if faces.size() < 3:
						break
				_add_vis(faces, xf, _path_of(mmi) + "#%d [%s %s] n=%d mesh=%s" % [i, mm.mesh.get_class(), (xf.basis.get_scale() * lab.size).snapped(Vector3.ONE * 0.1), mm.instance_count, mm.mesh.resource_name if mm.mesh.resource_name != "" else str(mm.mesh.get_surface_count())], _path_of(mmi) + "#%d" % i)
				nmesh += 1
				nfaces += faces.size() / 3
				heavy[_path_of(mmi)] = int(heavy.get(_path_of(mmi), 0)) + faces.size() / 3
	_vstate = PhysicsServer3D.space_get_direct_state(_vspace)
	var top: Array = heavy.keys()
	top.sort_custom(func(a, b): return heavy[a] > heavy[b])
	var tops: Array[String] = []
	for i in mini(3, top.size()):
		tops.append("%s:%d" % [top[i], heavy[top[i]]])
	if not quiet:
		print("PHYSVIS meshes=%d faces=%d ms=%d heavy=%s" % [nmesh, nfaces, Time.get_ticks_msec() - _t0, " ".join(tops)])


func _in_regions(ab: AABB, regions: Array[AABB]) -> bool:
	if ab.size.x >= 20.0 or ab.size.z >= 20.0:
		return true    # zemin, arazi, sur, büyük yapı: her yerde gerekebilir
	for r in regions:
		if r.intersects(ab):
			return true
	if not _vgrid.is_empty():
		for gx in range(floori((ab.position.x - 1.0) / 8.0), floori((ab.end.x + 1.0) / 8.0) + 1):
			for gz in range(floori((ab.position.z - 1.0) / 8.0), floori((ab.end.z + 1.0) / 8.0) + 1):
				if _vgrid.has(Vector2i(gx, gz)):
					return true
	return false


var _mm_cache := {}      # MultiMesh -> [Transform3D] (bir denetim boyunca)


## Örnek dönüşümleri tek seferde tampondan (örnek başına sunucu çağrısı yavaş).
func _mm_xforms(mm: MultiMesh) -> Array:
	if _mm_cache.has(mm):
		return _mm_cache[mm]
	var out: Array = []
	var cnt := mm.instance_count if mm.visible_instance_count < 0 else mini(mm.visible_instance_count, mm.instance_count)
	var stride := 12 + (4 if mm.use_colors else 0) + (4 if mm.use_custom_data else 0)
	var buf := mm.buffer if mm.transform_format == MultiMesh.TRANSFORM_3D else PackedFloat32Array()
	if buf.size() >= cnt * stride and cnt > 0:
		for i in cnt:
			var o := i * stride
			out.append(Transform3D(Vector3(buf[o], buf[o + 4], buf[o + 8]), Vector3(buf[o + 1], buf[o + 5], buf[o + 9]),
				Vector3(buf[o + 2], buf[o + 6], buf[o + 10]), Vector3(buf[o + 3], buf[o + 7], buf[o + 11])))
	else:
		for i in cnt:
			out.append(mm.get_instance_transform(i))
	_mm_cache[mm] = out
	return out

func _is_crowd_mesh(m: Mesh) -> bool:
	return _crowd_key(m) != ""


## Kalabalık ağının anahtarı ("O|renk|şapka|silah|poz"); kalabalık ağı değilse boş. Önbellek her denetimde tazelenir
## (sahne kurulurken yeni pozlar pişirilebilir).
var _crowd_keys := {}
func _crowd_key(m: Mesh) -> String:
	if m == null:
		return ""
	if not _crowd_keys.has(m):
		var cs: Script = load("res://scripts/npc/crowd.gd")
		var d = cs.get("_meshes")
		if d is Dictionary:
			for k in d:
				_crowd_keys[d[k]] = str(k)
	return str(_crowd_keys.get(m, ""))


func _add_vis(faces: PackedVector3Array, xf: Transform3D, desc: String, key := "") -> void:
	var w := PackedVector3Array()
	w.resize(faces.size())
	for i in faces.size():
		w[i] = xf * faces[i]
	var shape := PhysicsServer3D.concave_polygon_shape_create()
	PhysicsServer3D.shape_set_data(shape, {"faces": w, "backface_collision": true})
	var body := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body, PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_add_shape(body, shape)
	PhysicsServer3D.body_set_collision_layer(body, VIS)
	PhysicsServer3D.body_set_collision_mask(body, 0)
	PhysicsServer3D.body_set_space(body, _vspace)
	_vbodies.append(body)
	_vshapes.append(shape)
	_vdesc[body] = desc
	_vfaces[body] = w
	if key != "":
		_vinst[key] = body


func _free_vis() -> void:
	_mm_cache.clear()
	for b in _vbodies:
		PhysicsServer3D.free_rid(b)
	for s in _vshapes:
		PhysicsServer3D.free_rid(s)
	_vbodies.clear()
	_vshapes.clear()
	_vdesc.clear()
	_vfaces.clear()
	_vinst.clear()
	if _vspace.is_valid():
		PhysicsServer3D.free_rid(_vspace)
	_vspace = RID()
	_vstate = null


func _vray(a: Vector3, b: Vector3, excl: Array[RID] = []) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(a, b, VIS, excl)
	q.hit_back_faces = true
	return _vstate.intersect_ray(q)


func _vdesc_of(hit: Dictionary) -> String:
	return str(_vdesc.get(hit.get("rid", RID()), "?"))


# ---------------------------------------------------------------- kayıt

## Bulgular türe ve gruba (ağ / gövde / karakter) göre toplanır: her grup bir satır (sayı, en büyük değer, alan, örnek).
var _agg := {}


func _add(kind: String, group: String, cell: String, pos: Vector3, val: float, ex: String, phase: int) -> void:
	var dk := kind + "|" + group + "|" + cell
	if _seen.has(dk):
		return
	_seen[dk] = true
	_count[kind] = int(_count.get(kind, 0)) + 1
	var k := kind + "|" + group
	if not _agg.has(k):
		_agg[k] = {"kind": kind, "group": group, "n": 0, "max": val, "lo": pos, "hi": pos, "ex": ex, "phases": [], "d": INF}
	var e: Dictionary = _agg[k]
	e["n"] = int(e["n"]) + 1
	e["d"] = minf(float(e["d"]), pos.distance_to(_ref))
	if val > float(e["max"]):
		e["max"] = val
		e["ex"] = ex
	e["lo"] = (e["lo"] as Vector3).min(pos)
	e["hi"] = (e["hi"] as Vector3).max(pos)
	if not (phase in (e["phases"] as Array)):
		(e["phases"] as Array).append(phase)


func _dump() -> void:
	var keys: Array = _agg.keys()
	keys.sort_custom(func(a, b):
		var ea: Dictionary = _agg[a]
		var eb: Dictionary = _agg[b]
		if ea["kind"] != eb["kind"]:
			return str(ea["kind"]) < str(eb["kind"])
		return float(ea["d"]) < float(eb["d"]))
	var out: Array = []
	for k in keys:
		var e: Dictionary = _agg[k]
		print("PHYS %s scene=%s variant=%s d=%.0f n=%d max=%.2f area=%s..%s phases=%s group=%s ex=%s" % [e["kind"], scene_path.get_file(), variant,
			e["d"], e["n"], e["max"], _g(e["lo"]), _g(e["hi"]), str(e["phases"]), e["group"], e["ex"]])
		out.append({"kind": e["kind"], "group": e["group"], "d": e["d"], "n": e["n"], "max": e["max"], "lo": _g(e["lo"]), "hi": _g(e["hi"]), "ex": e["ex"], "phases": e["phases"]})
	var f := FileAccess.open("%s/%s%s.json" % [out_dir, scene_path.get_file().get_basename(), ("_" + variant) if variant != "" else ""], FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"scene": scene_path, "variant": variant, "counts": _count, "items": out}, " "))


func _g(v: Vector3) -> String:
	return "(%.1f,%.1f,%.1f)" % [v.x, v.y, v.z]


func _grp(desc: String) -> String:
	# Çoğaltılmış (MultiMesh) örnekler tek grup: "#12 [..]" atılır
	var i := desc.find("#")
	if i < 0:
		return desc
	var j := desc.find(" [", i)
	return desc.substr(0, i) + (desc.substr(j) if j >= 0 else "")


# ---------------------------------------------------------------- evre denetimi

func _audit(sc: Node, phase: int, obj: String) -> void:
	# Taşkın ve yürüyen bot bu fizik karesinde, hiç beklemeden yapılır: otomatik testte konuşma satırları karede bir
	# ilerler (zaman ölçeği 0 olsa da), beklenen her kare bölüme dünyayı değiştirme fırsatı verir (Bölüm 25'te surlar
	# bot başlamadan kaldırılıyordu). Bu karenin fizik adımı 1/60 s'dir (bot gövdeyi bununla yürütür).
	_t0 = Time.get_ticks_msec()
	var ts0 := Engine.time_scale     # bölümün kendi zaman ölçeği (Bölüm 10a otomatik testte 2,5)
	var pl: Node3D = sc.player
	_ref = pl.global_position
	var space: PhysicsDirectSpaceState3D = pl.get_world_3d().direct_space_state
	var excl := _char_rids(sc)
	print("PHYSPHASE scene=%s variant=%s phase=%d obj=\"%s\" player=%s" % [scene_path.get_file(), variant, phase, obj, _g(pl.global_position)])
	# Oyuncu nerede başlıyor: katının içinde mi
	# Oyuncunun kendi kapsülü (r 0,3, boy 1,75), 3 cm payla: kenarından çadırın, sandığın içine girmiş olmak da sayılır
	# (eskiden daha küçük kapsülle bakılıyordu; Bölüm 24o'da fırtınada çadır kenarının içinde başlamak görünmüyordu)
	var cap := CapsuleShape3D.new()
	cap.radius = 0.27
	cap.height = 1.7
	var qs := PhysicsShapeQueryParameters3D.new()
	qs.shape = cap
	qs.collision_mask = 1
	qs.exclude = excl
	qs.transform = Transform3D(Basis(), pl.global_position + Vector3(0, 0.88, 0))
	var frozen: bool = pl.get("frozen") == true or pl.get("pinned") == true
	for h in space.intersect_shape(qs, 4):
		var col = h["collider"]
		_add("SPAWN", _path_of(col) if col is Node else "?", str(phase), pl.global_position, 0.0, "phase=%d at=%s frozen=%s" % [phase, _g(pl.global_position), frozen], phase)
		break
	# Oyuncunun gerçek gövdesiyle deneme adımı: sekiz yönün hiçbirine 0.5 m gidilemiyorsa sıkışmış (donmuş değilse)
	if pl is CharacterBody3D and not frozen:
		var open := 0
		for k in 8:
			var a := TAU * k / 8.0
			if not (pl as CharacterBody3D).test_move(pl.global_transform, Vector3(sin(a), 0.05, cos(a)) * 0.5):
				open += 1
		if open == 0:
			_add("STUCK", "phase %d" % phase, str(phase), pl.global_position, 0.0, "phase=%d at=%s (hiçbir yöne adım atılamıyor)" % [phase, _g(pl.global_position)], phase)
	var r := _flood(sc, pl, space, excl)
	var tf := Time.get_ticks_msec() - _t0

	_dbg_at(space, phase)
	# Oyuncu yürümüyorsa (kürek çekiyor, sedye taşıyor, oturtulmuş, yüzüyor, kızaktan kaçışta şeritte koşuyor) erişim
	# ve hedef denetimi anlamsız. (Ara sahnede donmuş oyuncu sayılır: çözülünce aynı yerden yürür.)
	var walking: bool = pl.get("pinned") != true and pl.get("gravity_on") != false and pl.get("move_mode") != "script"
	# Taşkın başladığı hücreden hiçbir yere geçemiyorsa oyuncu kapalı kalmıştır (donmuşsa da: çözülünce aynı yerdedir)
	if walking and (r["cells"] as Dictionary).size() <= 1:
		_add("STUCK", "phase %d" % phase, str(phase) + "f", pl.global_position, 0.0, "phase=%d at=%s (taşkın başladığı hücreden çıkamıyor)" % [phase, _g(pl.global_position)], phase)
	if walking and pl is CharacterBody3D and OS.get_environment("PHYS_NOBOT") != "1":
		_walk_bot(pl as CharacterBody3D, space, r, phase)
	# Görünen dünyanın bölgesi: erişilebilir alan (+4 m) ve 80 m içindeki karakterler
	var regions: Array[AABB] = []
	var lo := Vector3(INF, INF, INF)
	var hi := -lo
	for c: Vector2i in r["cells"]:
		var y: float = r["cells"][c]
		lo = lo.min(Vector3(c.x * STEP, y, c.y * STEP))
		hi = hi.max(Vector3(c.x * STEP, y, c.y * STEP))
	regions.append(AABB(lo - Vector3(4, 3, 4), hi - lo + Vector3(8, 7, 8)))
	for p in _people(sc):
		if p.global_position.distance_to(pl.global_position) < 80.0:
			regions.append(AABB(p.global_position - Vector3(1.5, 2.0, 1.5), Vector3(3, 4.5, 3)))
	# Görünen dünya sunucu düzeyinde kurulur: gövdeler ve şekiller hemen sorgulanabilir (kare beklenmez)
	_build_vis(sc, regions)
	if walking:
		_check_cells(r, space, excl, phase)
		# Tespit (fotoğraf) hedefine uzaktan bakılır: yanına gitmek gerekmez
		if not obj.begins_with("Tespit et") and not obj.begins_with("Record"):
			_check_target(sc, r, phase)
		_check_interact(sc, r, phase)
	_check_people(sc, space, excl, phase, pl.global_position)
	_check_multimesh(sc, r, phase, regions)
	_check_flight(sc, pl, space, phase)
	_map(r, phase)
	print("PHYSTIME phase=%d flood_ms=%d total_ms=%d cells=%d" % [phase, tf, Time.get_ticks_msec() - _t0, r["cells"].size()])
	_dump()
	_free_vis()
	# Bu uzun kareden sonraki karenin adımı (saniyeler) zaman ölçeği 0 iken geçsin: oyun sıçramasın
	Engine.time_scale = 0.0
	await physics_frame
	Engine.time_scale = ts0


func _flood(_sc: Node, pl: Node3D, space: PhysicsDirectSpaceState3D, excl: Array[RID]) -> Dictionary:
	var start: Vector3 = pl.global_position
	var cap := CapsuleShape3D.new()
	# Oyuncunun gerçek kapsülü (player.gd: yarıçap 0,3, boy 1,75). Eskiden 0,27 / 1,6 idi: yürüyen bot, dar
	# aralıklarda ve alçak tavan altında taşkının geçtiği ama gövdenin geçemediği yerler buldu
	cap.radius = 0.3
	cap.height = 1.75
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.collision_mask = 1
	q.exclude = excl
	var mq := PhysicsShapeQueryParameters3D.new()
	mq.shape = cap
	mq.collision_mask = 1
	mq.exclude = excl
	var rp := PhysicsRayQueryParameters3D.new()
	rp.collision_mask = 1
	rp.exclude = excl
	var cells := {}      # Vector2i -> zemin y
	var voids := {}
	var drops := {}
	var blocks := []     # [çarpma noktası, yön, gövde, yükseklik]
	var edges := []      # taşkının geçtiği adımlar [hücre, komşu] (yürüyen bot bunları dener)
	var queue: Array = []
	var k0 := Vector2i(roundi(start.x / STEP), roundi(start.z / STEP))
	# Başlangıç zemini: oyuncunun altındaki ilk zemin
	rp.from = start + Vector3(0, 0.5, 0)
	rp.to = start + Vector3(0, -3.0, 0)
	var h0 := space.intersect_ray(rp)
	cells[k0] = (h0["position"] as Vector3).y if not h0.is_empty() else start.y
	queue.append(k0)
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var head := 0
	var bounds: Array = BOUNDS.get(scene_path.get_file(), [])
	while head < queue.size() and cells.size() < MAXC:
		var c: Vector2i = queue[head]
		head += 1
		var fy: float = cells[c]
		for d: Vector2i in dirs:
			var n: Vector2i = c + d
			if cells.has(n) or voids.has(n):
				continue
			# Başlangıç hücresi oyuncunun gerçek yerinden çıkar (hücre ortası duvarın içine düşebilir)
			var p0 := Vector3(c.x * STEP, fy, c.y * STEP) if c != k0 else Vector3(start.x, fy, start.z)
			var p1 := Vector3(n.x * STEP, fy, n.y * STEP)
			if not bounds.is_empty():
				var inside := false
				for b: AABB in bounds:
					inside = inside or b.has_point(p1 + Vector3(0, 0.5, 0))
				if not inside:
					continue
			# Zemin: basamak (en çok UP) ya da yürünür eğim (rampa, yamaç: en çok ~50°, ara nokta iki ucun arasında).
			# (Eskiden yalnız basamak vardı: 1 m'de 0,62 m'den çok yükselen 32°'lik gedik rampası çıkılamaz sanılıyordu.)
			rp.from = p1 + Vector3(0, SLOPE_UP + 0.05, 0)
			rp.to = p1 + Vector3(0, -60, 0)
			var hit := space.intersect_ray(rp)
			if hit.is_empty():
				# Boşluk, ancak oraya gidilebiliyorsa: kapsül yerden ya da zıplama yüksekliğinden geçebilmeli (duvarın
				# ardındaki boşluk düşülen yer değildir; eskiden taşkın önce zemine bakıp duvarı hiç sormuyordu)
				var reach := false
				for lift0: float in [0.06, UP + 0.06]:
					mq.transform = Transform3D(Basis(), p0 + Vector3(0, lift0 + 0.875, 0))
					mq.motion = p1 - p0
					var vm := space.cast_motion(mq)
					if vm.size() == 0 or vm[0] >= 0.999:
						reach = true
						break
				if reach:
					voids[n] = fy
				continue
			var ny: float = (hit["position"] as Vector3).y
			var rise := ny - fy
			if (hit["normal"] as Vector3).y < 0.6:
				continue
			if rise > UP:
				if rise > SLOPE_UP:
					continue
				var pm := (p0 + p1) * 0.5
				rp.from = pm + Vector3(0, rise + 0.3, 0)
				rp.to = pm + Vector3(0, -1.0, 0)
				var mh := space.intersect_ray(rp)
				if mh.is_empty() or (mh["normal"] as Vector3).y < 0.6:
					continue
				var my: float = (mh["position"] as Vector3).y
				if my < fy + rise * 0.2 or my > fy + rise * 0.8:
					continue      # eğim değil, yüksek basamak (kutu, masa)
			# Yol: basamak/eğim üstünde bir şey kesiyor mu (duvarın içinde zemin aranmasın)
			var pre := false
			for hh: float in [UP + 0.05, 1.3]:
				rp.from = p0 + Vector3(0, hh, 0)
				rp.to = p1 + Vector3(0, hh + maxf(0.0, rise), 0)
				var bh := space.intersect_ray(rp)
				if not bh.is_empty():
					pre = true
					blocks.append([bh["position"], (p1 - p0).normalized(), bh.get("collider"), hh])
					break
			if pre:
				continue
			# Oyuncu kapsülü oradan geçer mi (dar aralık, alçak tavan): basamak yüksekliğinde süpürme
			var lift := maxf(0.0, ny - fy) + 0.06
			mq.transform = Transform3D(Basis(), p0 + Vector3(0, lift + 0.875, 0))
			mq.motion = p1 - p0
			var mv := space.cast_motion(mq)
			if mv.size() > 0 and mv[0] < 0.999:
				rp.from = p0 + Vector3(0, lift + 0.8, 0)
				rp.to = p1 + Vector3(0, lift + 0.8, 0)
				var bh2 := space.intersect_ray(rp)
				if not bh2.is_empty():
					blocks.append([bh2["position"], (p1 - p0).normalized(), bh2.get("collider"), lift + 0.8])
				continue
			# Hedefte kapsül sığıyor mu
			q.transform = Transform3D(Basis(), Vector3(p1.x, ny + 0.06 + 0.875, p1.z))
			if not space.intersect_shape(q, 1).is_empty():
				continue
			if fy - ny > 3.0:
				drops[n] = fy - ny
			cells[n] = ny
			edges.append([c, n])
			queue.append(n)
	return {"cells": cells, "voids": voids, "drops": drops, "blocks": blocks, "k0": k0, "start": start, "edges": edges,
		"capped": cells.size() >= MAXC, "ghost": {}, "sink": {}, "air": {}, "iwall": {}, "crowd": {},
		"slide": {}, "wfall": {}, "wblock": {}, "jneed": {}}


func _check_cells(r: Dictionary, space: PhysicsDirectSpaceState3D, excl: Array[RID], phase: int) -> void:
	var cells: Dictionary = r["cells"]
	var sp := SphereShape3D.new()
	sp.radius = 0.14
	var sq := PhysicsShapeQueryParameters3D.new()
	sq.shape = sp
	sq.collision_mask = 1
	sq.exclude = excl
	var rp := PhysicsRayQueryParameters3D.new()
	rp.collision_mask = 1
	rp.exclude = excl
	var vsp := SphereShape3D.new()
	vsp.radius = 0.22
	var vq := PhysicsShapeQueryParameters3D.new()
	vq.shape = vsp
	vq.collision_mask = VIS
	for c: Vector2i in cells:
		var fy: float = cells[c]
		var p := Vector3(c.x * STEP, fy, c.y * STEP)
		var ck := "%d,%d" % [c.x, c.y]
		# Görünen zemin (hücre ortası tam bir kutunun kenarına düşerse ışın kenardan kaçar: rıhtımın deniz kenarı
		# z=0'da, hücre de z=0'da. Ayak 0,27 m genişlikte: 15 cm yanında görünen zemin varsa o zemindir)
		var vh := _vray(p + Vector3(0, 0.6, 0), p + Vector3(0, -0.5, 0))
		if vh.is_empty() or absf((vh["position"] as Vector3).y - fy) > 0.22:
			for o: Vector3 in [Vector3(0.15, 0, 0), Vector3(-0.15, 0, 0), Vector3(0, 0, 0.15), Vector3(0, 0, -0.15)]:
				var oh := _vray(p + o + Vector3(0, 0.6, 0), p + o + Vector3(0, -0.5, 0))
				if not oh.is_empty() and absf((oh["position"] as Vector3).y - fy) <= 0.22:
					vh = oh
					break
		if vh.is_empty():
			r["air"][c] = true
			_add("AIR", "(görünen zemin yok)", ck, p, 0.5, "phase=%d at=%s" % [phase, _g(p)], phase)
		else:
			var vy: float = (vh["position"] as Vector3).y
			if vy > fy + 0.22:
				r["sink"][c] = vy - fy
				_add("SINK", _grp(_vdesc_of(vh)), ck, p, vy - fy, "phase=%d at=%s depth=%.2f" % [phase, _g(p), vy - fy], phase)
			elif vy < fy - 0.25:
				r["air"][c] = true
				_add("AIR", _grp(_vdesc_of(vh)), ck, p, fy - vy, "phase=%d at=%s gap=%.2f" % [phase, _g(p), fy - vy], phase)
		# Komşuya yürürken görünen bir nesneden geçiliyor mu (diz, bel, baş hizası)
		for d: Vector2i in [Vector2i(1, 0), Vector2i(0, 1)]:
			var n: Vector2i = c + d
			if not cells.has(n):
				continue
			var ny: float = cells[n]
			if absf(ny - fy) > UP:
				continue
			var base := maxf(fy, ny)
			var p1 := Vector3(n.x * STEP, ny, n.y * STEP)
			for hh: float in [0.4, 1.0, 1.55]:
				var a := Vector3(p.x, base + hh, p.z)
				var b := Vector3(p1.x, base + hh, p1.z)
				var gh := _vray(a, b)
				if gh.is_empty():
					gh = _vray(b, a)
				if gh.is_empty():
					continue
				var gp: Vector3 = gh["position"]
				# Görünen yüzeyin hemen arkasında (14 cm) fizik gövdesi var mı: duvar kabuğu, sorun değil
				sq.transform = Transform3D(Basis(), gp)
				if not space.intersect_shape(sq, 1).is_empty():
					continue
				# Aynı hizada fizik ışını da kesiliyorsa (kapsül yine de geçiyorsa) nesne katıdır
				rp.from = a
				rp.to = b
				var ph := space.intersect_ray(rp)
				if not ph.is_empty() and (ph["position"] as Vector3).distance_to(gp) < 0.35:
					continue
				var desc := _vdesc_of(gh)
				r["ghost"][c] = desc
				_add("GHOST", _grp(desc), "%d,%d" % [roundi(gp.x * 2.0), roundi(gp.z * 2.0)], gp, hh, "phase=%d at=%s h=%.2f %s" % [phase, _g(gp), hh, desc.get_slice(" [", 0).get_slice("/", -1)], phase)
				break
	# Görünmez duvar: fizik ışınını kesen yüzeyin 22 cm yakınında görünen bir yüzey yok
	for bk in r["blocks"]:
		var bp: Vector3 = bk[0]
		vq.transform = Transform3D(Basis(), bp)
		if not _vstate.intersect_shape(vq, 1).is_empty():
			continue
		var col = bk[2]
		var ck2 := Vector2i(roundi(bp.x / STEP), roundi(bp.z / STEP))
		r["iwall"][ck2] = true
		_add("IWALL", _path_of(col) if col is Node else "?", "%d,%d" % [ck2.x, ck2.y], bp, float(bk[3]), "phase=%d at=%s h=%.2f" % [phase, _g(bp), bk[3]], phase)
	# Boşluk ve düşüş
	# Dünyanın suyu boşluk değildir: WorldWalk suya düşeni kıyıya çıkarır (oynanış alanında denizin 4 m altına batanı da)
	var wws: Array = current_scene.find_children("WorldWalk", "", true, false) if current_scene else []
	var w14 = load("res://scripts/world/world1453.gd")
	var sea := 0
	for v: Vector2i in r["voids"]:
		var vp := Vector3(v.x * STEP, float(r["voids"][v]), v.y * STEP)
		var wet := false
		for ww in wws:
			var wn = ww.get("world")
			if wn is Node3D and is_instance_valid(wn):
				var wp: Vector3 = (wn as Node3D).global_transform.affine_inverse() * vp
				if ww.call("_in_keep", wp) or w14.is_water(wp.x, wp.z):
					wet = true
		if wet:
			sea += 1
			continue
		_add("VOID", "(zemin yok)", "%d,%d" % [v.x, v.y], vp, 0.0, "phase=%d at=%s" % [phase, _g(vp)], phase)
	if sea > 0:
		print("PHYSSEA phase=%d cells=%d (dünyanın suyu / oynanış alanında deniz: WorldWalk kıyıya çıkarır)" % [phase, sea])
	for dp: Vector2i in r["drops"]:
		var pp := Vector3(dp.x * STEP, float(cells[dp]), dp.y * STEP)
		_add("DROP", "(büyük düşüş)", "%d,%d" % [dp.x, dp.y], pp, float(r["drops"][dp]), "phase=%d at=%s fall=%.1f" % [phase, _g(pp), r["drops"][dp]], phase)
	if r["capped"]:
		_add("CAPPED", "(alan sınırı)", str(phase), r["start"], float(cells.size()), "phase=%d cells=%d" % [phase, cells.size()], phase)


func _check_target(sc: Node, r: Dictionary, phase: int) -> void:
	var mk = sc.hud.marker if "marker" in sc.hud else null
	if mk == null or mk.target == null:
		return
	var tp = mk._world_pos()
	if not (tp is Vector3):
		return
	var t: Vector3 = tp
	var best := INF
	var cells: Dictionary = r["cells"]
	# Hedefin altındaki zemin (atlı, kule tepesindeki hedeflerde baş hizası değil ayak hizası)
	var gq := PhysicsRayQueryParameters3D.create(t + Vector3(0, 0.5, 0), t + Vector3(0, -30, 0), 1)
	var gh := (sc.player as Node3D).get_world_3d().direct_space_state.intersect_ray(gq)
	var ty: float = (gh["position"] as Vector3).y if not gh.is_empty() else t.y - 1.6
	for c: Vector2i in cells:
		var fy: float = cells[c]
		# Hedefin zeminiyle aynı katta ya da hedef bir nesnenin üstünde (top, masa) ve yanından uzanılabiliyor
		if absf(fy - ty) > 2.0 and not (fy < ty and t.y - fy <= 3.2):
			continue
		var d := Vector2(c.x * STEP - t.x, c.y * STEP - t.z).length()
		if d < best:
			best = d
	if best > 3.0:
		_add("TARGET", "phase %d" % phase, str(phase), t, minf(best, 999.0), "phase=%d target=%s nearest=%.1f cells=%d capped=%s" % [phase, _g(t), best, cells.size(), r["capped"]], phase)


## Etkileşim alanları (E): açık (katman 2) her alana oyuncunun gidebildiği bir yerden E ışınının boyu (2,4 m) içinde
## uzanılabiliyor mu. Eşyalar katı yapıldıkça (raf, masa, sandık) alanın önü kapanabilir; otomatik test etkileşimi
## doğrudan çağırdığı için bunu görmez. Izgara 1 m: en yakın hücre ortası gerçek en yakın yerden ~0,7 m uzak olabilir.
const E_REACH := 2.4
func _check_interact(sc: Node, r: Dictionary, phase: int) -> void:
	var cells: Dictionary = r["cells"]
	for n in sc.find_children("Interact_*", "StaticBody3D", true, false):
		var b := n as StaticBody3D
		if (b.collision_layer & 2) == 0:
			continue
		if b.get_parent() is Node3D and not (b.get_parent() as Node3D).is_visible_in_tree():
			continue
		var cs: CollisionShape3D = null
		for ch in b.get_children():
			if ch is CollisionShape3D and not (ch as CollisionShape3D).disabled and (ch as CollisionShape3D).shape is BoxShape3D:
				cs = ch
				break
		if cs == null:
			continue
		var he := ((cs.shape as BoxShape3D).size * 0.5).abs()
		var gx := cs.global_transform
		var inv := gx.affine_inverse()
		var c0 := gx.origin
		var k0 := Vector2i(roundi(c0.x / STEP), roundi(c0.z / STEP))
		var best := INF
		for dx in range(-5, 6):
			for dz in range(-5, 6):
				var k := k0 + Vector2i(dx, dz)
				if not cells.has(k):
					continue
				var eye := _cell_pos(r, k) + Vector3(0, 1.62, 0)
				var lp := inv * eye
				var cp := Vector3(clampf(lp.x, -he.x, he.x), clampf(lp.y, -he.y, he.y), clampf(lp.z, -he.z, he.z))
				best = minf(best, (gx * cp).distance_to(eye))
		# Yakında hiç yürünen hücre yoksa ve oyuncudan da uzaksa: o evrede kapalı bir bölümdeki ya da sahnenin dışına park
		# edilmiş alan. Halktan birine konuşma alanı (npc:crowd) herkese eklenir; surdaki, balkondaki erişilmez
		if best == INF and c0.distance_to((sc.player as Node3D).global_position) > 15.0:
			continue
		if str(b.get_meta("interact_id", "")) == "npc:crowd":
			continue
		if best > E_REACH + 0.7:
			var id := str(b.get_meta("interact_id", b.name))
			_add("NOREACH", id, id, c0, minf(best, 99.0), "phase=%d at=%s nearest_eye=%.1f" % [phase, _g(c0), best], phase)


## Nihat'ın uçuşu (Bölüm 3, 7, 11): yürüyerek varılamayan çatılara, kubbelere, kulelere uçularak varılır. Uçuş menzilindeki
## (saha kapısından range_m, yerden max_alt) iri, katı görünümlü basit ağların (kutu, silindir, küre, prizma; en küçük
## boyu 0,8 m, hacmi 6 m³) içi fizikte boş mu: boşsa içinden uçulur (FLYGHOST). İç nokta ağın ortası; üçgen çarpışmalı
## (hacimsiz) gövdeler için ortadan altı yöne ışın: en az beşi ağın sınırında bir çarpışmaya değiyorsa kapalı sayılır.
func _check_flight(sc: Node, pl: Node3D, space: PhysicsDirectSpaceState3D, phase: int) -> void:
	var pw = pl.get("powers")
	if pw == null or not bool(pw.get("can_fly")):
		return
	# Oyunda ilk uçuşta yapılan: yürüme yüksekliğinin üstündeki iri ağlara çarpışma (NihatPowers.ensure_flight_solids)
	var tf0 := Time.get_ticks_usec()
	var made := int(pw.call("ensure_flight_solids")) if pw.has_method("ensure_flight_solids") else -1
	var fly_ms := (Time.get_ticks_usec() - tf0) / 1000.0
	var home: Vector3 = pw.get("_home")
	if home == Vector3.INF:
		home = pl.global_position
	var rng_m: float = minf(float(pw.get("range_m")), 400.0) + 10.0   # tek haritada menzil ~3 km: yakın çevre taranır
	var top_y := home.y + float(pw.get("max_alt")) + 10.0
	var pq := PhysicsPointQueryParameters3D.new()
	pq.collision_mask = 1
	var rq := PhysicsRayQueryParameters3D.new()
	rq.collision_mask = 1
	rq.hit_from_inside = true
	var n_checked := 0
	var stack: Array = [sc]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		if _is_char(n) or n is CanvasItem:
			continue
		if n is Node3D and not (n as Node3D).visible:
			continue
		for c in n.get_children():
			stack.append(c)
		if not (n is GeometryInstance3D) or n.has_meta("soft"):
			continue
		var gi := n as GeometryInstance3D
		if gi.visibility_range_begin > 0.0:
			continue
		var mesh: Mesh = null
		var xfs: Array = []
		if n is MeshInstance3D:
			mesh = (n as MeshInstance3D).mesh
			xfs = [gi.global_transform]
		elif n is MultiMeshInstance3D and (n as MultiMeshInstance3D).multimesh != null:
			mesh = (n as MultiMeshInstance3D).multimesh.mesh
			if mesh != null and _is_crowd_mesh(mesh):
				continue
			for x in _mm_xforms((n as MultiMeshInstance3D).multimesh):
				xfs.append(gi.global_transform * (x as Transform3D))
		if mesh == null or not (mesh is BoxMesh or mesh is CylinderMesh or mesh is SphereMesh or mesh is PrismMesh or mesh is CapsuleMesh):
			continue
		if not _geom_solid(gi, mesh):
			continue
		var lab := mesh.get_aabb()
		for i in xfs.size():
			var xf: Transform3D = xfs[i]
			var sz := xf.basis.get_scale() * lab.size
			if minf(sz.x, minf(sz.y, sz.z)) < 0.8 or sz.x * sz.y * sz.z < 6.0:
				continue
			var cen: Vector3 = xf * lab.get_center()
			if Vector2(cen.x - home.x, cen.z - home.z).length() > rng_m or (xf * lab).position.y > top_y:
				continue
			n_checked += 1
			pq.position = cen
			if not space.intersect_point(pq, 1).is_empty():
				continue
			var closed := 0
			for k in 3:
				for sgn: float in [1.0, -1.0]:
					rq.from = cen
					rq.to = cen + xf.basis[k] * lab.size[k] * 0.54 * sgn
					if not space.intersect_ray(rq).is_empty():
						closed += 1
			if closed >= 5:
				continue
			var desc := "%s [%s %s]" % [_path_of(gi), mesh.get_class(), sz.snapped(Vector3.ONE * 0.1)]
			# Yerden yüksekliği (oyundaki geçiş yerden 2 m'den aşağıda başlayanlara dokunmaz: yürüyüş değişmesin)
			var bottom := (xf * lab).position.y
			var ex: Array[RID] = [(pl as CollisionObject3D).get_rid()]
			var from := Vector3(cen.x, bottom + 0.05, cen.z)
			var ground := bottom - 300.0
			for k in 8:
				var gq := PhysicsRayQueryParameters3D.create(from, Vector3(cen.x, bottom - 300.0, cen.z), 1, ex)
				var gh := space.intersect_ray(gq)
				if gh.is_empty():
					break
				ground = (gh["position"] as Vector3).y
				if gh["collider"] is CollisionObject3D:
					ex.append((gh["collider"] as CollisionObject3D).get_rid())
				from = (gh["position"] as Vector3) + Vector3.DOWN * 0.02
			_add("FLYGHOST", desc, "%s#%d" % [_path_of(gi), i], cen, sz.x * sz.y * sz.z, "phase=%d at=%s size=%s above=%.1f" % [phase, _g(cen), _g(sz), bottom - ground], phase)
	print("PHYSFLY phase=%d home=%s range=%.0f checked=%d made=%d solid_ms=%.1f" % [phase, _g(home), rng_m, n_checked, made, fly_ms])


func _people(sc: Node) -> Array[Node3D]:
	var out: Array[Node3D] = []
	for n in sc.find_children("*", "Node3D", true, false):
		if _cls_in(n, PEOPLE_CLASSES):
			var p := n as Node3D
			if not p.is_visible_in_tree() or p.get_meta("hologram", false) or p.has_meta("no_audit") or p.has_meta("climber"):
				continue
			out.append(p)
	return out


func _skip_person(p: Node3D) -> bool:
	var act := str(p.get("activity")) if p.get("activity") != null else ""
	if act.begins_with("sit") or act in ["ride", "lie", "sleep", "row", "swim", "fly", "hover", "dead", "fallen"]:
		return true
	if _cls_in(p, ["Soldier"]) and str(p.get("pose")) in ["dead", "lie", "fallen", "sit", "carried", "sit_ground"]:
		return true
	if absf(p.global_rotation.x) > 0.4 or absf(p.global_rotation.z) > 0.4:
		return true
	var q: Node = p.get_parent()
	while q != null:
		if _cls_in(q, ["Horse", "Player", "Person", "Soldier"]):
			return true   # atta, taşınan, omuzda
		q = q.get_parent()
	return false


func _check_people(sc: Node, space: PhysicsDirectSpaceState3D, excl: Array[RID], phase: int, eye: Vector3, tick := false) -> void:
	var ppl := _people(sc)
	var tag := "tick" if tick else "phase"
	var cap := CapsuleShape3D.new()
	cap.radius = 0.13
	cap.height = 0.9
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.collision_mask = 1
	q.exclude = excl
	var vq := PhysicsShapeQueryParameters3D.new()
	vq.shape = cap
	vq.collision_mask = VIS
	var rp := PhysicsRayQueryParameters3D.new()
	rp.collision_mask = 1
	rp.exclude = excl
	for p in ppl:
		if _skip_person(p):
			continue
		var feet := p.global_position
		var who := "%s%s" % [_path_of(p), (" spk=" + str(p.get_meta("spk"))) if p.has_meta("spk") else ""]
		if p.get("coat") is Color:
			# Kim olduğu (aynı düğüm adı her koşuda değişir): palto, şapka, iş
			var act := str(p.get("activity")) if p.get("activity") != null else ""
			who += " [%s %s%s]" % [(p.get("coat") as Color).to_html(false), str(p.get("hat")), (" " + act) if act != "" else ""]
		var ck := "%d,%d,%d" % [roundi(feet.x), roundi(feet.y), roundi(feet.z)]
		var dist := feet.distance_to(eye)
		var near := dist < 80.0
		# Fizik zemini
		rp.from = feet + Vector3(0, 0.3, 0)
		rp.to = feet + Vector3(0, -0.35, 0)
		# Uzaktakiler denetlenmez: görünen dünya orada kurulmaz, uzak arazinin çoğunun çarpışması da yoktur
		if not near:
			continue
		var ph := space.intersect_ray(rp)
		var vh := _vray(feet + Vector3(0, 0.3, 0), feet + Vector3(0, -0.35, 0))
		if ph.is_empty() and vh.is_empty():
			_add("FLOAT", who, ck, feet, dist, "%s=%d feet=%s dist=%.0f" % [tag, phase, _g(feet), dist], phase)
		elif vh.is_empty():
			_add("VFLOAT", who, ck, feet, dist, "%s=%d feet=%s dist=%.0f (fizik zemini var, görünen yok)" % [tag, phase, _g(feet), dist], phase)
		# Ayak görünen bir nesnenin içinde mi (zemin ayak hizasından yüksek)
		var sh := _vray(feet + Vector3(0, 0.9, 0), feet + Vector3(0, 0.02, 0))
		if not sh.is_empty() and (sh["normal"] as Vector3).y > 0.5 and (sh["position"] as Vector3).y > feet.y + 0.15:
			_add("VSUNK", who, ck, feet, (sh["position"] as Vector3).y - feet.y, "%s=%d feet=%s floor=%.2f mesh=%s dist=%.0f" % [tag, phase, _g(feet), (sh["position"] as Vector3).y, _vdesc_of(sh), dist], phase)
		# Gövde görünen bir ağın içinde / içinden geçiyor
		vq.transform = Transform3D(Basis(), feet + Vector3(0, 1.0, 0))
		var vc := _vstate.intersect_shape(vq, 1)
		if not vc.is_empty():
			_add("CLIP", who, ck, feet, dist, "%s=%d feet=%s mesh=%s dist=%.0f" % [tag, phase, _g(feet), _vdesc_of(vc[0]), dist], phase)
		elif _inside_vis(feet + Vector3(0, 1.0, 0)):
			_add("CLIP", who, ck, feet, dist, "%s=%d feet=%s mesh=(içinde) dist=%.0f" % [tag, phase, _g(feet), dist], phase)
		q.transform = Transform3D(Basis(), feet + Vector3(0, 1.05, 0))
		var pc := space.intersect_shape(q, 4)
		var vis_hit: Array = pc.filter(func(h): return _visible_body(h["collider"]))
		if not vis_hit.is_empty():
			var col = vis_hit[0]["collider"]
			_add("INSOLID", who, ck, feet, dist, "%s=%d feet=%s by=%s dist=%.0f" % [tag, phase, _g(feet), _path_of(col) if col is Node else "?", dist], phase)
	for i in ppl.size():
		if _skip_person(ppl[i]):
			continue
		for j in range(i + 1, ppl.size()):
			if _skip_person(ppl[j]):
				continue
			var a := ppl[i].global_position
			var b := ppl[j].global_position
			var hi := _cls_in(ppl[i], ["Horse"])
			var hj := _cls_in(ppl[j], ["Horse"])
			if hi or hj:
				# At ile insan / at ile at: atın gövde kutusu (yan 0.35, boy 1.1 m)
				var horse: Node3D = ppl[i] if hi else ppl[j]
				var other: Node3D = ppl[j] if hi else ppl[i]
				var lp := horse.global_transform.affine_inverse() * other.global_position
				var sc2 := horse.global_transform.basis.get_scale()
				if absf(lp.x * sc2.x) < 0.45 and absf(lp.z * sc2.z) < 1.2 and absf(a.y - b.y) < 1.0:
					_add("OVERLAP", "%s + %s" % [_path_of(horse), _path_of(other)], "%d,%d" % [roundi(other.global_position.x), roundi(other.global_position.z)], other.global_position, 0.0, "%s=%d at=%s (at gövdesinin içinde)" % [tag, phase, _g(other.global_position)], phase)
				continue
			if Vector2(a.x - b.x, a.z - b.z).length() < 0.35 and absf(a.y - b.y) < 0.6:
				_add("OVERLAP", "%s + %s" % [_path_of(ppl[i]), _path_of(ppl[j])], "%d,%d" % [roundi(a.x), roundi(a.z)], a, 0.0, "%s=%d at=%s" % [tag, phase, _g(a)], phase)


## Işın bir üçgene arkasından mı çarptı. Godot arka yüz çarpışmasında normali ışına doğru çevirir: yüzün gerçek
## normali üçgen dizininden hesaplanır (saat yönünde sarılan ön yüz; Plane(a, b, c) normali ön yüze bakar).
func _is_back(hit: Dictionary, dir: Vector3) -> bool:
	var f: PackedVector3Array = _vfaces.get(hit.get("rid", RID()), PackedVector3Array())
	var k: int = hit.get("face_index", -1)
	if k < 0 or f.size() < k * 3 + 3:
		return false
	return Plane(f[k * 3], f[k * 3 + 1], f[k * 3 + 2]).normal.dot(dir) > 0.0


## Nokta bir zeminin altında mı (çakılı kazık, gömülü taş): yukarı giden ışın, girmediği bir gövdenin arka yüzüne
## çarpar. Alt yüzünden girilen nesne (setin tabanı) içinden geçilip sayılmaz; çatının altındaki nokta gömülü değildir.
func _buried(pt: Vector3, own: Array[RID]) -> bool:
	var a := pt
	var inside := {}
	for k in 6:
		var u := _vray(a, pt + Vector3(0, 3.0, 0), own)
		if u.is_empty():
			return false
		var rid: RID = u.get("rid", RID())
		if _is_back(u, Vector3.UP):
			if not inside.has(rid):
				return true
			inside.erase(rid)
		else:
			inside[rid] = true
		a = (u["position"] as Vector3) + Vector3(0, 0.005, 0)
	return false


## Nokta görünen kapalı bir ağın içinde mi: beş yönde ışın, arka yüze çarpanlar
func _inside_vis(pt: Vector3) -> bool:
	var back := 0
	for d: Vector3 in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK, Vector3.UP]:
		var h := _vray(pt, pt + d * 6.0)
		if not h.is_empty() and _is_back(h, d):
			back += 1
	return back >= 4


## Çoğaltılmış nesneler: havada duran örnekler (görünen zemin 0.3 m'den aşağıda) ve oyuncunun yürüyebildiği
## hücrelerde duran kalabalık kopyaları (içinden geçilen donmuş asker). Görünen dünya yalnız erişilen alanın
## çevresinde kurulur: 40 m içindeki öbür örnekler için dünya, çevrelerindeki 8 m'lik karelerle yeniden kurulur.
func _check_multimesh(sc: Node, r: Dictionary, phase: int, regions: Array[AABB]) -> void:
	var reach := regions[0]
	var cells: Dictionary = r["cells"]
	var cands: Array = []
	for n in sc.find_children("*", "MultiMeshInstance3D", true, false):
		var mmi := n as MultiMeshInstance3D
		if not mmi.is_visible_in_tree() or mmi.multimesh == null or mmi.multimesh.mesh == null or mmi.visibility_range_begin > 0.0:
			continue
		var mm := mmi.multimesh
		if not _geom_solid(mmi, mm.mesh):
			continue
		var ab := mm.mesh.get_aabb()
		if ab.size.y < 0.3 or maxf(ab.size.x, ab.size.z) < 0.15:
			continue      # yassı ya da ince uzun (ok, mızrak): uçuşta ya da saplı, havada olması doğal
		var ckey := _crowd_key(mm.mesh)
		var crowd := ckey != ""
		if ckey.ends_with("|leap") or ckey.contains("climb"):
			continue    # sıçrayan / tırmanan asker pozu: havada olması doğal
		var xfs := _mm_xforms(mm)
		var gxf := mmi.global_transform
		for i in xfs.size():
			var xf: Transform3D = gxf * (xfs[i] as Transform3D)
			if absf(xf.basis.determinant()) < 1e-6:
				continue
			# Yatık ya da devrik örnek (düşmüş asker, yatırılmış kütük): ayak noktası alt uç değildir
			if xf.basis.y.normalized().y < 0.85:
				continue
			var bot := xf * Vector3(ab.get_center().x, ab.position.y, ab.get_center().z)
			if crowd:
				var ck := Vector2i(roundi(bot.x / STEP), roundi(bot.z / STEP))
				if cells.has(ck) and absf(float(cells[ck]) - bot.y) < 1.0:
					r["crowd"][ck] = true
					_add("CROWD", _path_of(mmi), "%d,%d" % [ck.x, ck.y], bot, 0.0, "phase=%d at=%s (yürünebilir hücrede donmuş kalabalık kopyası)" % [phase, _g(bot)], phase)
			if not reach.grow(40.0).has_point(bot):
				continue
			cands.append([mmi, i, bot, crowd])
	if cands.is_empty():
		return
	var grid := {}
	for c in cands:
		var bot: Vector3 = c[2]
		if not reach.has_point(bot):
			grid[Vector2i(floori(bot.x / 8.0), floori(bot.z / 8.0))] = true
	if not grid.is_empty():
		_free_vis()
		_vgrid = grid
		_build_vis(sc, regions, true)
		_vgrid = {}
	for c in cands:
		var mmi: MultiMeshInstance3D = c[0]
		var i: int = c[1]
		var bot: Vector3 = c[2]
		var own: Array[RID] = []
		var key := _path_of(mmi) + "#%d" % i
		if _vinst.has(key):
			own.append(_vinst[key])
		var gap := 9.9
		# Alt ucun 0,3 m üstünden (yarı gömülü taşın altı zeminin altındadır: oradan inen ışın arazinin altındaki
		# gizli katmana çarpıyordu); nesnenin kendi gövdesi dışlanır
		var h := _vray(bot + Vector3(0, 0.3, 0), bot + Vector3(0, -1.5, 0), own)
		if not h.is_empty():
			gap = bot.y - (h["position"] as Vector3).y
		# 0,3 m'den derin gömülüyse ışın zeminin altından başlar, zemini görmez ve alttaki bir katmana çarpar
		# (yamaçtaki evler "y - 0,4"e oturtulur): alt uç görünen bir yüzeyin altındaysa havada değildir
		if gap > 0.3 and _buried(bot, own):
			gap = 0.0
		if _dbg_mm != "" and _path_of(mmi).contains(_dbg_mm) and (i % 7 == 0 or gap > 0.3):
			var u2 := _vray(bot, bot + Vector3(0, 3.0, 0), own)
			var hw := (mmi.get_world_3d().direct_space_state as PhysicsDirectSpaceState3D).intersect_ray(PhysicsRayQueryParameters3D.create(bot + Vector3(0, 3, 0), bot + Vector3(0, -3, 0), 1))
			var cdh = load("res://scripts/level/camp_day.gd").height(bot.x, bot.z) if OS.get_environment("PHYS_DBG_CAMP") == "1" else 0.0
			print("MMDBG camp_h=%.2f %s#%d bot=%s gap=%.2f down=%s up=%s phys=%s own=%s nb=%d" % [cdh, _path_of(mmi), i, _g(bot), gap,
				_g(h["position"]) if not h.is_empty() else "-", ("%s n=%s fi=%s back=%s %s" % [_g(u2["position"]), _g(u2["normal"]), u2.get("face_index", "?"), _is_back(u2, Vector3.UP), _vdesc_of(u2)]) if not u2.is_empty() else "-",
				_g(hw["position"]) if not hw.is_empty() else "-", own.size(), _vbodies.size()])
		if gap > 0.3:
			# Altında görünmeyen bir çarpışma cismi mi var (Dressing onun üstüne koymuş olabilir)
			var pq := PhysicsRayQueryParameters3D.create(bot + Vector3(0, 0.3, 0), bot + Vector3(0, -1.5, 0), 1)
			var ph := (mmi.get_world_3d().direct_space_state as PhysicsDirectSpaceState3D).intersect_ray(pq)
			var under := ("%s@%.2f" % [_path_of(ph["collider"]) if ph["collider"] is Node else "?", (ph["position"] as Vector3).y]) if not ph.is_empty() else "-"
			_add("MMFLOAT", ("crowd " if c[3] else "") + _path_of(mmi) + " [%s %s]" % [mmi.multimesh.mesh.get_class(), mmi.multimesh.mesh.get_aabb().size.snapped(Vector3.ONE * 0.1)], str(i), bot, gap, "phase=%d at=%s gap=%.1f under=%s" % [phase, _g(bot), gap, under], phase)


# ---------------------------------------------------------------- yürüyen bot

const BOT_MS := 6000       # evre başına bot süresi (ms)
var _dbg_walk := Vector2.INF   # PHYS_DBG_WALK="x,z": bu hücreden başlayan yürüyüşleri kare kare yaz

## Yürüyen bot: oyuncunun kendi gövdesiyle (aynı kapsül; CharacterBody3D.move_and_slide ve zemin ayarları: en çok 45°
## eğim, 10 cm yere yapışma) taşkının bulduğu hücrelerde durma ve komşu hücreye yürüme denenir. Bütün denemeler tek
## bir fizik karesinin içinde yapılır (zaman ölçeği yalnız o kare için 1): başka hiçbir şey kıpırdamaz; oyuncunun yeri
## ve hızı sonunda geri konur (bölge tetikleri ve bölüm betiği görmez).
##   SLIDE     durulamayan yer: iç hücreye (dört komşusu da yürünür) bırakılan gövde kayıyor, düşüyor ya da itiliyor
##   WALKFALL  komşu hücreye yürürken iki zeminin de 1 m'den çok altına düşülüyor (zeminden geçme)
##   WALKBLOCK taşkına göre geçilen düz ya da alçak (en çok 0,45 m) adımda gövde takılıyor (zıplayarak da)
func _walk_bot(pl: CharacterBody3D, space: PhysicsDirectSpaceState3D, r: Dictionary, phase: int) -> void:
	var dt := pl.get_physics_process_delta_time()
	var dw := OS.get_environment("PHYS_DBG_WALK").split(",")
	if dw.size() == 2:
		_dbg_walk = Vector2(float(dw[0]), float(dw[1]))
	if dt < 1.0 / 240.0:
		print("PHYSBOT phase=%d skipped (dt=%.4f)" % [phase, dt])
		return
	var cells: Dictionary = r["cells"]
	if cells.size() < 2:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 7 + phase
	# Yürüyüş: yalnız taşkının gerçekten geçtiği adımlar (iki komşu hücre arasında duvar olabilir: odanın içi ve
	# koridor). Önce basamaklı/eğimli olanlar, sonra düzler.
	var rise_e: Array = []
	var flat_e: Array = []
	for e in r["edges"]:
		var dy: float = float(cells[e[1]]) - float(cells[e[0]])
		if absf(dy) <= 0.12:
			flat_e.append(e)
		elif dy <= 0.45:
			rise_e.append(e)
	_shuffle(rise_e, rng)
	_shuffle(flat_e, rng)
	var walks: Array = rise_e.slice(0, 2000)
	walks.append_array(flat_e.slice(0, 2000))
	# Durma: ayak izi (0,3 m yarıçap) tümüyle zeminde olan hücreler (kenardaki hücreden kayıp düşmek doğaldır);
	# eğimli zemin (normal dikten >8°) önce
	var keys: Array = cells.keys()
	_shuffle(keys, rng)
	var rq := PhysicsRayQueryParameters3D.new()
	rq.collision_mask = 1
	rq.exclude = [pl.get_rid()] as Array[RID]
	var tilted: Array = []
	var level: Array = []
	for c: Vector2i in keys.slice(0, 8000):
		var p := _cell_pos(r, c)
		rq.from = p + Vector3(0, 0.5, 0)
		rq.to = p + Vector3(0, -0.5, 0)
		var h0 := space.intersect_ray(rq)
		if h0.is_empty():
			continue
		var ok := true
		for o: Vector3 in [Vector3(0.3, 0, 0), Vector3(-0.3, 0, 0), Vector3(0, 0, 0.3), Vector3(0, 0, -0.3)]:
			rq.from = p + o + Vector3(0, 0.5, 0)
			rq.to = p + o + Vector3(0, -0.5, 0)
			var h1 := space.intersect_ray(rq)
			if h1.is_empty() or absf((h1["position"] as Vector3).y - p.y) > 0.3:
				ok = false
				break
		if not ok:
			continue
		if (h0["normal"] as Vector3).y < 0.99:
			tilted.append(c)
		else:
			level.append(c)
	var stand: Array = tilted.slice(0, 2000)
	stand.append_array(level.slice(0, 1000))
	var t0 := Time.get_ticks_msec()
	var g: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	var save_xf := pl.global_transform
	var save_v := pl.velocity
	var n_st := 0
	var n_wk := 0
	for c: Vector2i in stand:
		if Time.get_ticks_msec() - t0 > BOT_MS / 2:
			break
		n_st += 1
		var p := _cell_pos(r, c)
		var q := _bot_stand(pl, p, dt, g)
		var drift := Vector2(q.x - p.x, q.z - p.z).length()
		if drift > 0.25 or q.y < p.y - 0.4 or q.y > p.y + 0.4:
			var col := _bot_collider(pl, space, q)
			r["slide"][c] = true
			_add("SLIDE", col, "%d,%d" % [c.x, c.y], p, maxf(drift, absf(q.y - p.y)), "phase=%d at=%s -> %s" % [phase, _g(p), _g(q)], phase)
	for e in walks:
		if Time.get_ticks_msec() - t0 > BOT_MS:
			break
		n_wk += 1
		var c: Vector2i = e[0]
		var n: Vector2i = e[1]
		var a := _cell_pos(r, c)
		var b := _cell_pos(r, n)
		var w := _bot_walk(pl, a, b, false, dt, g)
		if not w["ok"] and not w["fall"]:
			var stuck: Vector3 = w["at"]
			var wcol: String = w["col"]
			w = _bot_walk(pl, a, b, true, dt, g)
			# Yürüyüş durmadan hedefin ötesine geçtiyse küçük bir cismin çevresinden dolaşılmıştır (hücre merkezi taşın
			# üstüne denk gelmiş): engel değil
			var passed := Vector2(stuck.x - a.x, stuck.z - a.z).length() > Vector2(b.x - a.x, b.z - a.z).length() + 0.8
			if w["ok"] and b.y - a.y > 0.12 and not passed:
				# Yürüyerek çıkılamayan alçak basamak (zıplayınca çıkılıyor): kaldırım, eşik, basamak
				r["jneed"][c] = true
				_add("JUMPNEED", wcol, "%d,%d" % [c.x, c.y], a, b.y - a.y, "phase=%d at=%s to=%s stuck=%s rise=%.2f" % [phase, _g(a), _g(b), _g(stuck), b.y - a.y], phase)
		if w["ok"]:
			continue
		var at: Vector3 = w["at"]
		if w["fall"]:
			r["wfall"][c] = true
			var fc := space.intersect_ray(PhysicsRayQueryParameters3D.create(b + Vector3(0, 0.5, 0), b + Vector3(0, -1.0, 0), 1, [pl.get_rid()] as Array[RID]))
			_add("WALKFALL", _path_of(fc["collider"]) if not fc.is_empty() and fc["collider"] is Node else "?", "%d,%d" % [c.x, c.y], a, a.y - at.y,
				"phase=%d at=%s to=%s fell_to=%s" % [phase, _g(a), _g(b), _g(at)], phase)
		elif b.y - a.y <= 0.45:
			r["wblock"][c] = true
			_add("WALKBLOCK", w["col"], "%d,%d" % [c.x, c.y], a, b.y - a.y, "phase=%d at=%s to=%s stuck=%s rise=%.2f" % [phase, _g(a), _g(b), _g(at), b.y - a.y], phase)
	pl.global_transform = save_xf
	pl.velocity = save_v
	PhysicsServer3D.body_set_state(pl.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, save_xf)
	print("PHYSBOT phase=%d stand=%d/%d walk=%d/%d ms=%d" % [phase, n_st, stand.size(), n_wk, walks.size(), Time.get_ticks_msec() - t0])


## Tekrarlanabilir karıştırma (oyunun genel rastgele üretecine dokunmaz)
func _shuffle(a: Array, rng: RandomNumberGenerator) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = a[i]
		a[i] = a[j]
		a[j] = t


## Hücrenin ortası; başlangıç hücresi için oyuncunun gerçek yeri (yuvarlanan hücre ortası duvarın içinde olabilir)
func _cell_pos(r: Dictionary, c: Vector2i) -> Vector3:
	if c == r["k0"]:
		var st: Vector3 = r["start"]
		return Vector3(st.x, float(r["cells"][c]), st.z)
	return Vector3(c.x * STEP, float(r["cells"][c]), c.y * STEP)


## Hücreye bırakılan gövde 0,4 s kendi haline: nereye varıyor
func _bot_stand(pl: CharacterBody3D, p: Vector3, dt: float, g: float) -> Vector3:
	pl.global_position = p + Vector3(0, 0.03, 0)
	pl.velocity = Vector3.ZERO
	var dbg := OS.get_environment("PHYS_DBG_BOT") == "1"
	if dbg:
		var shapes := []
		for c in pl.get_children():
			if c is CollisionShape3D:
				shapes.append("%s dis=%s pos=%s" % [(c as CollisionShape3D).shape, (c as CollisionShape3D).disabled, (c as CollisionShape3D).position])
		print("BOTDBG start=%s mask=%d layer=%d shapes=%s test_down=%s snap=%.2f maxang=%.1f up=%s mode=%d" % [_g(pl.global_position), pl.collision_mask, pl.collision_layer, shapes,
			pl.test_move(pl.global_transform, Vector3(0, -0.5, 0)), pl.floor_snap_length, rad_to_deg(pl.floor_max_angle), pl.up_direction, pl.motion_mode])
	for i in 24:
		pl.velocity.x = 0.0
		pl.velocity.z = 0.0
		if not pl.is_on_floor():
			pl.velocity.y -= g * dt
		pl.move_and_slide()
		if dbg and i < 4:
			print("BOTDBG  i=%d pos=%s v=%s floor=%s n=%d" % [i, _g(pl.global_position), _g(pl.velocity), pl.is_on_floor(), pl.get_slide_collision_count()])
	return pl.global_position


## a'dan b'ye yürüyüş (gerekirse ilk adımda zıplayarak), en çok 0,8 s
func _bot_walk(pl: CharacterBody3D, a: Vector3, b: Vector3, jump: bool, dt: float, g: float) -> Dictionary:
	pl.global_position = a + Vector3(0, 0.03, 0)
	pl.velocity = Vector3.ZERO
	for i in 3:
		if not pl.is_on_floor():
			pl.velocity.y -= g * dt
		pl.move_and_slide()
	var dir := Vector3(b.x - a.x, 0, b.z - a.z).normalized()
	var jumped := false
	# Player sınıfına derlemede bağlanılmaz (oyuncu betiği autoload'lara bağlı; -s betiğinde onlar derlenmez)
	var consts: Dictionary = pl.get_script().get_script_constant_map()
	var walk: float = consts.get("WALK", 3.2)
	var jump_v: float = consts.get("JUMP", 3.6)
	var can_step := pl.has_method("step_up")
	for i in 48:
		pl.velocity.x = dir.x * walk
		pl.velocity.z = dir.z * walk
		var was_floor := pl.is_on_floor()
		if was_floor:
			if jump and not jumped:
				pl.velocity.y = jump_v
				jumped = true
		else:
			pl.velocity.y -= g * dt
		pl.move_and_slide()
		# Oyuncunun kendi basamak çıkışı (alçak basamağa zıplamadan çıkar)
		var stepped := false
		if was_floor and can_step:
			stepped = pl.call("step_up", dir * walk, dt)
		if _dbg_walk != Vector2.INF and Vector2(a.x, a.z).distance_to(_dbg_walk) < 0.6:
			var kc := pl.get_last_slide_collision()
			print("BOTWALK jump=%s i=%d pos=%s v=%s floor=%s step=%s n=%d col=%s" % [jump, i, _g(pl.global_position), _g(pl.velocity), pl.is_on_floor(), stepped,
				pl.get_slide_collision_count(), (_path_of(kc.get_collider()) + " n=" + _g(kc.get_normal())) if kc != null and kc.get_collider() is Node else "-"])
		var p := pl.global_position
		if Vector2(p.x - b.x, p.z - b.z).length() < 0.3 and p.y > b.y - 0.35:
			return {"ok": true}
		if p.y < minf(a.y, b.y) - 1.0:
			return {"ok": false, "fall": true, "at": p}
	var col := "?"
	var k := pl.get_last_slide_collision()
	if k != null and k.get_collider() is Node:
		col = _path_of(k.get_collider())
	return {"ok": false, "fall": false, "at": pl.global_position, "col": col}


## Gövdenin değdiği (yoksa altındaki) cisim
func _bot_collider(pl: CharacterBody3D, space: PhysicsDirectSpaceState3D, q: Vector3) -> String:
	var k := pl.get_last_slide_collision()
	if k != null and k.get_collider() is Node:
		return _path_of(k.get_collider())
	var h := space.intersect_ray(PhysicsRayQueryParameters3D.create(q + Vector3(0, 0.5, 0), q + Vector3(0, -3.0, 0), 1, [pl.get_rid()] as Array[RID]))
	return _path_of(h["collider"]) if not h.is_empty() and h["collider"] is Node else "(zemin yok)"


# ---------------------------------------------------------------- harita

func _map(r: Dictionary, phase: int) -> void:
	var cells: Dictionary = r["cells"]
	var mn := Vector2i(1 << 20, 1 << 20)
	var mx := -mn
	var ymin := INF
	var ymax := -INF
	for c: Vector2i in cells:
		mn = Vector2i(mini(mn.x, c.x), mini(mn.y, c.y))
		mx = Vector2i(maxi(mx.x, c.x), maxi(mx.y, c.y))
		ymin = minf(ymin, cells[c])
		ymax = maxf(ymax, cells[c])
	for c: Vector2i in r["voids"]:
		mn = Vector2i(mini(mn.x, c.x), mini(mn.y, c.y))
		mx = Vector2i(maxi(mx.x, c.x), maxi(mx.y, c.y))
	var S := 4 if (mx.x - mn.x) < 300 and (mx.y - mn.y) < 300 else 2
	var w := (mx.x - mn.x + 1) * S
	var h2 := (mx.y - mn.y + 1) * S
	var img := Image.create(maxi(w, 1), maxi(h2, 1), false, Image.FORMAT_RGB8)
	img.fill(Color(0.08, 0.08, 0.1))
	for c: Vector2i in cells:
		var k := clampf((cells[c] - ymin) / maxf(ymax - ymin, 0.5), 0.0, 1.0)
		var col := Color(0.2, 0.35 + 0.5 * k, 0.3 + 0.2 * k).lerp(Color(0.95, 0.95, 0.9), k * 0.6)
		if r["air"].has(c):
			col = Color(0.2, 0.85, 1.0)
		if r["sink"].has(c):
			col = Color(0.7, 0.3, 0.9)
		if r["drops"].has(c):
			col = Color(1.0, 0.6, 0.1)
		if r["ghost"].has(c):
			col = Color(1.0, 0.95, 0.1)
		if r["crowd"].has(c):
			col = Color(0.9, 0.35, 0.2)
		if r["slide"].has(c) or r["wblock"].has(c):
			col = Color(1.0, 1.0, 1.0)
		if r["wfall"].has(c):
			col = Color(0.55, 0.0, 0.0)
		img.fill_rect(Rect2i((c.x - mn.x) * S, (c.y - mn.y) * S, S, S), col)
	for c: Vector2i in r["iwall"]:
		if c.x >= mn.x and c.x <= mx.x and c.y >= mn.y and c.y <= mx.y:
			img.fill_rect(Rect2i((c.x - mn.x) * S, (c.y - mn.y) * S, S, S), Color(1.0, 0.3, 0.8))
	for c: Vector2i in r["voids"]:
		img.fill_rect(Rect2i((c.x - mn.x) * S, (c.y - mn.y) * S, S, S), Color(1, 0.1, 0.1))
	var k0: Vector2i = r["k0"]
	img.fill_rect(Rect2i((k0.x - mn.x) * S - 3, (k0.y - mn.y) * S - 3, S + 6, S + 6), Color(0.2, 0.5, 1.0))
	var fn := "%s/%s%s_p%02d.png" % [out_dir, scene_path.get_file().get_basename(), ("_" + variant) if variant != "" else "", phase]
	img.save_png(fn)
	print("PHYSMAP %s cells=%d voids=%d drops=%d ghost=%d sink=%d air=%d iwall=%d x=[%d..%d] z=[%d..%d] y=[%.1f..%.1f] capped=%s" % [fn,
		cells.size(), r["voids"].size(), r["drops"].size(), r["ghost"].size(), r["sink"].size(), r["air"].size(), r["iwall"].size(),
		mn.x, mx.x, mn.y, mx.y, ymin, ymax, r["capped"]])
