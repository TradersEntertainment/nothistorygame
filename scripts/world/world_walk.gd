class_name WorldWalk
extends Node
## Tek haritada her yer yürünür: dünyanın görüntüsü (SiegeField + HornWorld) çarpışmasız kurulur; bu düğüm onu
## görünenle birebir katılaştırır. Her World1453.build sonrası eklenir, kurulum karelere yayılır (yükleme takılmaz).
##   · Arazi (LowPoly.terrain, "terrain" metalı): görünen üçgenlerin kendisi; bölgenin oynanış alanında (keep) da
##     (orada dünya zemini bölümün zeminiyle aynı ya da hemen altında: döşeme bitince dünyaya inilir). Alınmayanlar:
##     dünyanın suyu (bölümün kendi su kuralı geçerli) ve bölümün verdiği delikler (hendek, lağım: add_holes).
##   · Büyük ağlar (sur, kule, kilise, Ayasofya, Galata, birleşik süs parçaları): ağın üçgenleri. Işıklı/saydam/
##     gölgelendirici malzemeler (pencere ışıkları, su, duman, alev) alınmaz.
##   · Çoklu ağlar (MultiMesh: evler, çadırlar, kiliseler): örnek başına yönlü kutu (insan, at boyundakiler alınmaz).
##   · Su: oyuncu dünyanın suyuna (Haliç, Boğaz, Marmara; oynanış alanı dışı) girerse sıçrar, kıyıdaki son güvenli
##     yerine döner.

const MM_MIN_W := 2.5       # çoklu ağ örneği: en az bu genişlik (yatay)
const MM_MIN_H := 2.3       # ve bu yükseklik
const MI_MIN := 1.2         # tek ağ: yatayda ya da düşeyde en az bu
const BUDGET_MS := 12       # bir karede en çok bu kadar kurulum

var world: SiegeField
var keep: Array = []          # dünya çerçevesinde (world.keep)
var holes: Array = []         # dünya çerçevesinde: burada dünya zemini katılaşmaz (bölümün kendi çukuru, suyu)
var body: StaticBody3D
var done := false
var shapes := 0
var boxes := 0
var tris := 0
var _sea_y := 0.0             # sahne çerçevesinde deniz yüzü
var _land := Vector3.INF      # oyuncunun sudan önceki son güvenli yeri (sahne)
var _land_body: Node3D        # o yer hareketli bir şeyin (gemi güvertesi) üstündeyse: oraya göre
var _land_local := Vector3.ZERO
var _player: Player
var _splash_t := 0.0
var _wet_t := 0.0
const WET_WAIT := 0.8


## Bölümün kendi çukurları (yerel dikdörtgenler, bölge çerçevesinde): orada dünya zemini katılaşmaz
static func add_holes(w: SiegeField, rects_local: Array) -> void:
	var ww := w.get_node_or_null("WorldWalk") as WorldWalk if w else null
	if ww == null:
		return
	var xf := w.transform.affine_inverse()
	for r: Rect2 in rects_local:
		ww.holes.append(World1453.world_rect(xf, r))


static func attach(w: SiegeField) -> WorldWalk:
	if w == null or w.has_node("WorldWalk") or OS.has_environment("NO_WORLDWALK"):
		return null
	var ww := WorldWalk.new()
	ww.name = "WorldWalk"
	ww.world = w
	ww.keep = w.keep
	w.add_child(ww)
	return ww


func _ready() -> void:
	body = StaticBody3D.new()
	body.name = "WalkSolids"
	world.add_child(body)
	_sea_y = (world.transform * Vector3(0.0, World1453.SEA_Y, 0.0)).y
	_build()


func _build() -> void:
	# Dünyanın kurulumu (lite yolunda kareye yayılır) bitmeden ağlar eksik olur: bir kare bekle
	await get_tree().process_frame
	var t0 := Time.get_ticks_msec()
	var list: Array = []
	_collect(world, list)
	var inv := world.global_transform.affine_inverse()
	var tick := Time.get_ticks_msec()
	for n: Node in list:
		if not is_instance_valid(n):
			continue
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if mi.has_meta("terrain"):
				_terrain(mi, inv)
			else:
				_mesh(mi, inv)
		elif n is MultiMeshInstance3D:
			_multi(n as MultiMeshInstance3D, inv)
		if Time.get_ticks_msec() - tick > BUDGET_MS:
			if not is_inside_tree():
				return
			await get_tree().process_frame
			tick = Time.get_ticks_msec()
			if not is_instance_valid(world):
				return
	done = true
	if OS.has_environment("WORLD_PROF") or GameState.autotest:
		print("WORLDWALK region=%s shapes=%d boxes=%d tris=%d ms=%d" % [world.region_name, shapes, boxes, tris, Time.get_ticks_msec() - t0])


func _collect(n: Node, out: Array) -> void:
	if n == body or n is Person or n is Soldier:
		return
	if n is Node3D and not (n as Node3D).visible:
		return
	if n.has_meta("no_walk"):
		return                    # görünür kaplama (sokak döşemesi): zemin altındaki arazidir
	if n is MeshInstance3D or n is MultiMeshInstance3D:
		out.append(n)
	for c in n.get_children():
		_collect(c, out)


func _skip_mat(m: Material) -> bool:
	if m == null:
		return false
	if m is ShaderMaterial:
		return true
	if m is BaseMaterial3D:
		var b := m as BaseMaterial3D
		return b.emission_enabled or b.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or b.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED
	return false


func _in_keep(p: Vector3) -> bool:
	for r in keep:
		if (r as Rect2).has_point(Vector2(p.x, p.z)):
			return true
	return false


func _in_hole(p: Vector3) -> bool:
	for r in holes:
		if (r as Rect2).has_point(Vector2(p.x, p.z)):
			return true
	return false


## Arazi: üçgenler dünya çerçevesinde. Oynanış alanında dünyanın suyu ve bölümün delikleri atlanır
func _terrain(mi: MeshInstance3D, inv: Transform3D) -> void:
	var xf := inv * mi.global_transform
	var f := mi.mesh.get_faces()
	var out := PackedVector3Array()
	for i in range(0, f.size(), 3):
		var a := xf * f[i]
		var b := xf * f[i + 1]
		var c := xf * f[i + 2]
		var m := (a + b + c) / 3.0
		if _in_hole(m) or (_in_keep(m) and World1453.is_water(m.x, m.z)):
			continue
		out.append_array([a, b, c])
	if out.is_empty():
		return
	_add_faces(out, Transform3D.IDENTITY)


func _mesh(mi: MeshInstance3D, inv: Transform3D) -> void:
	if mi.mesh == null or _skip_mat(mi.material_override):
		return
	var xf := inv * mi.global_transform
	var ab := xf * mi.get_aabb()
	if maxf(ab.size.x, ab.size.z) < MI_MIN and ab.size.y < MI_MIN:
		return
	if _in_keep(ab.get_center()) and ab.size.x < 200.0 and ab.size.z < 200.0:
		return
	var faces := PackedVector3Array()
	for s in mi.mesh.get_surface_count():
		if mi.material_override == null and _skip_mat(mi.mesh.surface_get_material(s)):
			continue
		var arr := mi.mesh.surface_get_arrays(s)
		var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX] if arr[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
		if idx.is_empty():
			faces.append_array(v)
		else:
			for k in idx:
				faces.append(v[k])
	if faces.is_empty():
		return
	# Ölçek/eğiklik varsa üçgenlere işlenir (ölçekli içbükey şekil güvenilmez)
	var sc := xf.basis.get_scale()
	if absf(sc.x - 1.0) > 0.01 or absf(sc.y - 1.0) > 0.01 or absf(sc.z - 1.0) > 0.01:
		for i in faces.size():
			faces[i] = xf * faces[i]
		_add_faces(faces, Transform3D.IDENTITY)
	else:
		_add_faces(faces, xf.orthonormalized())


func _multi(mm_i: MultiMeshInstance3D, inv: Transform3D) -> void:
	var mm := mm_i.multimesh
	if mm == null or mm.mesh == null or mm.transform_format != MultiMesh.TRANSFORM_3D:
		return
	if _skip_mat(mm_i.material_override):
		return
	var base := inv * mm_i.global_transform
	var mab := mm.mesh.get_aabb()
	# Örnek dönüşümleri kurulurken düğüme yazılır (Scenery.scatter, Kit.batch); yoksa MultiMesh'ten okunur
	var xfs: Array = mm_i.get_meta("xforms", [])
	var n := xfs.size() if not xfs.is_empty() else (mm.visible_instance_count if mm.visible_instance_count >= 0 else mm.instance_count)
	for i in n:
		var ixf := base * (xfs[i] as Transform3D if not xfs.is_empty() else mm.get_instance_transform(i))
		var sc := ixf.basis.get_scale()
		var size := mab.size * sc
		if maxf(size.x, size.z) < MM_MIN_W or size.y < MM_MIN_H:
			continue
		var center := ixf * mab.get_center()
		if _in_keep(center):
			continue
		var bs := BoxShape3D.new()
		bs.size = size * Vector3(0.94, 1.0, 0.94)
		var own := body.create_shape_owner(body)
		body.shape_owner_add_shape(own, bs)
		body.shape_owner_set_transform(own, Transform3D(ixf.basis.orthonormalized(), center))
		shapes += 1
		boxes += 1


func _add_faces(faces: PackedVector3Array, xf: Transform3D) -> void:
	var cp := ConcavePolygonShape3D.new()
	cp.backface_collision = true
	cp.set_faces(faces)
	var own := body.create_shape_owner(body)
	body.shape_owner_add_shape(own, cp)
	body.shape_owner_set_transform(own, xf)
	shapes += 1
	tris += faces.size() / 3


# ---------------------------------------------------------------- su

func _physics_process(delta: float) -> void:
	_splash_t -= delta
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Player
		if _player == null:
			return
	var p := _player.global_position
	var wp := world.global_transform.affine_inverse() * p
	if _player.is_on_floor() and p.y > _sea_y + 0.4 and _player.ladder == null:
		# Işınlanmanın ilk karesinde is_on_floor eski yerden kalır: suyun üstü kara sayılmasın
		if _in_keep(wp) or not World1453.is_water(wp.x, wp.z):
			_land = p + Vector3(0, 0.1, 0)
			_land_body = _floor_body()
			if _land_body:
				_land_local = _land_body.global_transform.affine_inverse() * _land
		return
	if p.y > _sea_y + 0.2 or _splash_t > 0.0 or _land == Vector3.INF or _player.frozen:
		_wet_t = 0.0
		return
	if _player.move_mode != "walk" or _player.pinned or not _player.gravity_on:
		_wet_t = 0.0
		return
	if _player.powers and (_player.powers.flying or _player.powers.landing):
		_wet_t = 0.0
		return
	# Oynanış alanında: bölümün suyu çarpışmasız (bölümün kendi kuralı yoksa oyuncu batar gider): zeminsiz ve denizin
	# 4 m altına batmışsa. Dışarıda: dünyanın suyu
	var deep := p.y < _sea_y - 4.0 and not _player.is_on_floor()
	if _in_keep(wp):
		if not deep:
			_wet_t = 0.0
			return
	elif not World1453.is_water(wp.x, wp.z):
		_wet_t = 0.0
		return
	# Bölümlerin kendi su kuralları önce gelir (düşeni tayfa çeker, kayık alır, hapse girilir: oyuncuyu dondururlar):
	# bir süre kimse almazsa dünya kıyıya çıkarır
	_wet_t += delta
	if _wet_t < WET_WAIT:
		return
	_wet_t = 0.0
	# Dünyanın suyu: sıçra, kıyıya dön
	_splash_t = 1.0
	Audio.sfx("splash", -4.0, 1.0)
	_player.velocity = Vector3.ZERO
	_player.global_position = _land_body.global_transform * _land_local if is_instance_valid(_land_body) else _land
	print("WORLDWALK_WATER pos=%s" % p)


## Oyuncunun bastığı gövde (gemi güvertesi gibi hareket edebilen; dünyanın kendi gövdesi değil)
func _floor_body() -> Node3D:
	for i in _player.get_slide_collision_count():
		var c := _player.get_slide_collision(i)
		if c.get_normal().y > 0.6:
			var b := c.get_collider() as Node3D
			if b and b != body:
				return b
	return null


func _exit_tree() -> void:
	if is_instance_valid(body):
		body.queue_free()
