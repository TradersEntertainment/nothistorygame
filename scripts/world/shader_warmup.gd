class_name ShaderWarmup
extends Node3D
## Gölgelendirici ısınması (gl_compatibility işleyicisi malzemeyi ekranda ilk çizildiğinde derler: şehre yaklaşınca,
## yeni ev katmanı ya da yeni giysili karakter göründüğünde kısa donmalar). Sahnedeki her (malzeme, yüzey biçimi,
## tekil/çoklu) birleşimi bir kez, kameranın hemen önünde 1 cm'lik bir kopya olarak çizilir; sonra silinir.
## Kopyalar mesh kaynağını paylaşır (bellek yok). Ekran kararmışken de çizilir (karartma katmanı üsttedir).
## Kullanım: ShaderWarmup.run(kök)  — dünya ve kalabalık kurulduktan sonra; birkaç kare sürer.

const PER_FRAME := 48          # bir karede çizilen kopya (çok olursa o kare uzar; yükleme sırasında sorun değil)
const HOLD_FRAMES := 2         # her parti kaç kare görünür kalsın (derleme + çizim)

static var _seen := {}         # oturum boyunca derlenmiş birleşimler (bölümler arası tekrar etmesin)

var _items: Array = []         # [mesh, surface, material, multi, colors]
var done := false


static func run(root: Node) -> ShaderWarmup:
	if root == null or not root.is_inside_tree() or DisplayServer.get_name() == "headless":
		return null
	var w := ShaderWarmup.new()
	w.name = "ShaderWarmup"
	root.add_child(w)
	return w


## Dünya kurulduktan sonra: dünyanın katıları (WorldWalk) ve şehrin kalabalık havuzu (CityLife) hazır olunca bütün
## sahne ısıtılır (kalabalığın giysileri de dahil)
static func after_world(world: Node3D) -> void:
	if DisplayServer.get_name() == "headless" or GameState.autotest or OS.has_environment("NO_WARMUP"):
		return
	var w := ShaderWarmup.new()
	w.name = "ShaderWarmup"
	w.set_meta("wait_world", world)
	world.add_child(w)


func _ready() -> void:
	if has_meta("wait_world"):
		_after.call_deferred()
		return
	_collect(get_parent())
	_work.call_deferred()


func _after() -> void:
	var world: Node = get_meta("wait_world")
	var t := 0
	while t < 1800 and is_inside_tree():
		var ww = world.get_node_or_null("WorldWalk")
		var cl: Node = null
		for c in world.get_children():
			if c is CityLife:
				cl = c
		var ww_ok: bool = ww == null or ww.done
		var cl_ok: bool = cl == null or not cl.graph_ready or cl._built >= cl.agents.size() or t > 900
		if ww_ok and cl_ok:
			break
		await get_tree().process_frame
		t += 1
	if not is_inside_tree():
		return
	_collect(get_tree().current_scene if get_tree().current_scene else world)
	_work()


func _collect(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		if mi.mesh:
			for s in mi.mesh.get_surface_count():
				_add(mi.mesh, s, mi.get_active_material(s), false, false)
	elif n is MultiMeshInstance3D:
		var mm := (n as MultiMeshInstance3D).multimesh
		if mm and mm.mesh:
			for s in mm.mesh.get_surface_count():
				var m: Material = (n as MultiMeshInstance3D).material_override
				if m == null:
					m = mm.mesh.surface_get_material(s)
				_add(mm.mesh, s, m, true, mm.use_colors)
	for c in n.get_children():
		_collect(c)


func _add(mesh: Mesh, s: int, mat: Material, multi: bool, colors: bool) -> void:
	var fmt := 0
	if mesh is ArrayMesh:
		fmt = (mesh as ArrayMesh).surface_get_format(s)
	var key := "%d|%d|%s|%s" % [mat.get_instance_id() if mat else 0, fmt, multi, colors]
	if _seen.has(key):
		return
	_seen[key] = true
	_items.append([mesh, s, mat, multi, colors])


func _work() -> void:
	var cam := get_viewport().get_camera_3d() if get_viewport() else null
	var i := 0
	while i < _items.size():
		if not is_inside_tree():
			return
		cam = get_viewport().get_camera_3d()
		var batch: Array[Node3D] = []
		for k in mini(PER_FRAME, _items.size() - i):
			var it: Array = _items[i + k]
			var n: GeometryInstance3D
			if it[3]:
				var mm := MultiMesh.new()
				mm.transform_format = MultiMesh.TRANSFORM_3D
				mm.use_colors = it[4]
				mm.mesh = it[0]
				mm.instance_count = 1
				var mmi := MultiMeshInstance3D.new()
				mmi.multimesh = mm
				n = mmi
			else:
				var mi := MeshInstance3D.new()
				mi.mesh = it[0]
				n = mi
			if it[2]:
				n.material_override = it[2]
			n.extra_cull_margin = 16384.0
			add_child(n)
			if cam:
				# Kameranın 1 m önünde, ekran içinde ızgara: her kopya en az birkaç piksel kaplar
				var col := k % 8
				var row := k / 8
				var off := Vector3((col - 3.5) * 0.06, (row - 3.0) * 0.06, -1.0)
				var big := maxf(0.01, (it[0] as Mesh).get_aabb().get_longest_axis_size())
				n.global_transform = Transform3D(cam.global_basis.scaled(Vector3.ONE * (0.05 / big)), cam.global_transform * off)
			batch.append(n)
		for f in HOLD_FRAMES:
			await get_tree().process_frame
		for n in batch:
			n.queue_free()
		i += PER_FRAME
	done = true
	queue_free()
