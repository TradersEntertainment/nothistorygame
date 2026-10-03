class_name TitleBackdrop
extends CanvasLayer
## Başlık ve ana menünün arkasında canlı kuşatma: 28/29 Mayıs gecesi kara surları. Ayrı bir dünyada (SubViewport)
## sur, gedik ve hücum eden ordu kurulur; kamera ağır ağır sur boyunca süzülür, büyük top arada bir ateşlenir.
## HUD'un (katman 10) altında, garajın 3B görüntüsünün üstündedir. Bölüm sahnesi değişince kendiliğinden gider.

var _cam: Camera3D
var _walls: LandWalls
var _t := 0.0
var _gun_t := 7.0


func _ready() -> void:
	layer = 5
	var svc := SubViewportContainer.new()
	svc.stretch = true
	svc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	svc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(svc)
	var sv := SubViewport.new()
	sv.own_world_3d = true
	sv.audio_listener_enable_3d = false
	svc.add_child(sv)
	var world := Node3D.new()
	sv.add_child(world)
	_cam = Camera3D.new()
	_cam.fov = 55.0
	world.add_child(_cam)
	_cam.current = true
	_build.call_deferred(world)


## Sahne kare kare kurulur (tek karede ~10 sn sürüyordu: bölümden ana menüye dönerken pencere "yanıt vermiyor" oluyordu)
func _build(world: Node3D) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_inside_tree():
		return
	_walls = LandWalls.new()
	_walls.assault_mode = true
	_walls.lite = true            # kamera gediğe bakar: uzak ordugâh seyrek (menüye dönüş donmasın)
	world.add_child(_walls)
	_walls.set_repair(LandWalls.STAGES - 2)
	await get_tree().process_frame
	if not is_inside_tree():
		return
	var a := Assault.new()
	a.intensity = 0.8
	a.progressive = true
	world.add_child(a)
	a.build()
	_place_cam()


func _process(delta: float) -> void:
	_t += delta
	_place_cam()
	_gun_t -= delta
	if _gun_t <= 0.0 and _walls and _walls.is_inside_tree():
		_gun_t = randf_range(11.0, 16.0)
		_walls.fire_flash()
		Audio.sfx("cannon", -12.0, 0.8)


## Dışarıdan, ordunun arkasından sura doğru: gedik ortada, kamera sağa sola ağır süzülür, hafifçe iner kalkar.
func _place_cam() -> void:
	var a := sin(_t * 0.045) * 0.55
	var target := LandWalls.BREACH + Vector3(sin(_t * 0.03) * 5.0, 5.5, 3.0)
	_cam.position = LandWalls.BREACH + Vector3(sin(a) * 30.0, 11.0 + sin(_t * 0.07) * 1.5, 30.0 + cos(a) * 9.0)
	_cam.look_at(target, Vector3.UP)
