class_name ShaderWarmup
extends Node3D
## Gölgelendirici ısınması (gl_compatibility işleyicisi malzemeyi ekranda ilk çizildiğinde derler: şehre yaklaşınca,
## yeni ev katmanı ya da yeni giysili karakter göründüğünde kısa donmalar). Sahnedeki her (malzeme, yüzey biçimi,
## tekil/çoklu) birleşimi bir kez küçük bir kopya olarak çizilir; sonra silinir. Kopyalar ekranda görünmez: kendi
## dünyası olan gizli bir SubViewport'ta (aynı ortam ve güneş ışığıyla, aynı gölgelendirici çeşitleri derlensin)
## çizilir. (Eskiden ana kameranın önüne konuyordu; bölüm başında ekranda dev renkli kırıklar görünüyordu.)
## Kopyalar mesh kaynağını paylaşır (bellek yok).
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
	if DisplayServer.get_name() == "headless" or (GameState.autotest and not OS.has_environment("FORCE_WARMUP")) or OS.has_environment("NO_WARMUP"):
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


## Gizli çizim yüzeyi: kendi dünyası, ana sahnenin ortamı ve güneşinin kopyası, ana ekranın MSAA ayarı
func _stage() -> Array:
	var vp := SubViewport.new()
	vp.name = "WarmupView"
	vp.size = Vector2i(256, 256)
	vp.own_world_3d = true
	vp.world_3d = World3D.new()
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var main_vp := get_viewport()
	if main_vp:
		vp.msaa_3d = main_vp.msaa_3d
		var env: Environment = main_vp.world_3d.environment if main_vp.world_3d else null
		var cam0 := main_vp.get_camera_3d()
		if cam0 and cam0.environment:
			env = cam0.environment
		if env:
			vp.world_3d.environment = env
	add_child(vp)
	var cam := Camera3D.new()
	cam.near = 0.05
	vp.add_child(cam)
	cam.current = true
	var sun := _find_sun(get_tree().current_scene)
	if sun:
		var l := DirectionalLight3D.new()
		l.light_color = sun.light_color
		l.light_energy = sun.light_energy
		l.shadow_enabled = sun.shadow_enabled
		l.directional_shadow_mode = sun.directional_shadow_mode
		l.rotation = Vector3(-0.8, 0.5, 0.0)
		vp.add_child(l)
	return [vp, cam]


func _find_sun(n: Node) -> DirectionalLight3D:
	if n == null:
		return null
	if n is DirectionalLight3D and (n as DirectionalLight3D).visible:
		return n
	for c in n.get_children():
		var r := _find_sun(c)
		if r:
			return r
	return null


func _work() -> void:
	var st := _stage()
	var vp: SubViewport = st[0]
	var cam: Camera3D = st[1]
	var i := 0
	while i < _items.size():
		if not is_inside_tree():
			return
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
				mm.set_instance_transform(0, Transform3D.IDENTITY)
				if it[4]:
					mm.set_instance_color(0, Color.WHITE)
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
			vp.add_child(n)
			# Gizli kameranın 1 m önünde ızgara; mesh kendi kutusunun ortası hücreye gelecek biçimde küçültülür
			var col := k % 8
			var row := k / 8
			var off := Vector3((col - 3.5) * 0.06, (row - 3.0) * 0.06, -1.0)
			var box := (it[0] as Mesh).get_aabb()
			var sc := 0.05 / maxf(0.01, box.get_longest_axis_size())
			var b := Basis.IDENTITY.scaled(Vector3.ONE * sc)
			n.transform = Transform3D(b, cam.transform * off - b * box.get_center())
			batch.append(n)
		for f in HOLD_FRAMES:
			await get_tree().process_frame
		for n in batch:
			n.queue_free()
		i += PER_FRAME
	if OS.has_environment("FORCE_WARMUP"):
		print("WARMUP done items=%d" % _items.size())
	done = true
	queue_free()
