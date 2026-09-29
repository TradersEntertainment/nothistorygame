class_name LivePortrait
extends SubViewport
## Konuşma kartının canlı portresi: konuşan karakter sahnedeyse küçük bir kamera onun yüzünü çeker. Kart böylece
## karakterin oyundaki hâliyle aynıdır (miğfer, zırh, is, sarık) ve ağzı sesle birlikte oynar. Karakter sahnede
## yoksa (telsiz, uzak ses) Hud eski çizimi gösterir.

var target: Node3D
var box: Control          # altyazı kutusu: kapanınca çekim durur
var _cam: Camera3D


func _init() -> void:
	size = Vector2i(224, 224)
	own_world_3d = false
	transparent_bg = false
	render_target_update_mode = SubViewport.UPDATE_DISABLED
	msaa_3d = Viewport.MSAA_2X
	_cam = Camera3D.new()
	_cam.fov = 24.0
	_cam.near = 0.05
	_cam.far = 400.0
	add_child(_cam)


## Kişinin baş düğümü (Rig.head) ya da gövdenin 1.6 m yukarısı.
static func head_of(n: Node3D) -> Vector3:
	var r = n.get("rig")
	if r is Rig and (r as Rig).head and (r as Rig).head.is_inside_tree():
		return (r as Rig).head.global_position + Vector3(0, 0.02, 0)
	return n.global_position + Vector3(0, 1.6, 0)


## Hedefi ayarla; true: portre kullanılabilir.
func show_for(n: Node3D, main: Viewport) -> bool:
	target = n
	if n == null or not is_instance_valid(n) or not n.is_inside_tree():
		stop()
		return false
	world_3d = main.world_3d
	_place()
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	return true


func stop() -> void:
	target = null
	render_target_update_mode = SubViewport.UPDATE_DISABLED


func _process(_delta: float) -> void:
	if target == null:
		return
	if not is_instance_valid(target) or not target.is_inside_tree() or (box and not box.visible):
		stop()
		return
	_place()


## Kamera yüzün önünde, 1.1 m uzakta, hafif yandan ve göz hizasının biraz üstünden (ortak "görüntülü arama" açısı).
func _place() -> void:
	var h := head_of(target)
	var fwd := target.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized() if fwd.length() > 0.01 else Vector3.BACK
	var side := fwd.cross(Vector3.UP).normalized()
	_cam.global_position = h + fwd * 1.1 + side * 0.18 + Vector3(0, 0.06, 0)
	_cam.look_at(h + Vector3(0, -0.02, 0), Vector3.UP)
