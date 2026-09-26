class_name Ladder
extends Node3D
## Tırmanılabilir merdiven: iki dikme, basamaklar, ince katı gövde (içinden geçilmez) ve önünde tırmanma alanı.
## Oyuncu alana girip ileri (W) basınca merdivene tutunur: W yukarı, S aşağı, Space bırakır; tepede öne çıkar.
## Yerel +Y merdiven boyunca yukarı, yerel +Z merdivenin önü (oyuncunun durduğu taraf). tilt: arkaya yaslanma (derece).

const WIDTH := 0.8
const RUNG := 0.36

var height := 6.0
var tilt := 15.0
var color := Color("6a4a2c")
var zone: Area3D


func _init(p_height := 6.0, p_tilt := 15.0, p_color := Color("6a4a2c")) -> void:
	height = p_height
	tilt = p_tilt
	color = p_color


func _ready() -> void:
	add_to_group("ladder")
	var frame := Node3D.new()
	frame.rotation_degrees = Vector3(-tilt, 0, 0)
	add_child(frame)
	for sx: float in [-WIDTH * 0.5, WIDTH * 0.5]:
		Props.cyl(frame, 0.05, height, Vector3(sx, height * 0.5, 0), color, Vector3.ZERO, 5)
	var n := int(height / RUNG)
	for k in n:
		Props.box(frame, Vector3(WIDTH, 0.05, 0.05), Vector3(0, 0.3 + k * RUNG, 0), color.darkened(0.1))
	# İnce katı gövde: merdivenin içine yürünmez
	var body := Props.solid(frame, Vector3(WIDTH + 0.1, height, 0.12), Vector3(0, height * 0.5, -0.06), Color.WHITE)
	body.get_child(0).visible = false
	body.set_meta("no_climb", true)
	# Tırmanma alanı (önünde)
	zone = Area3D.new()
	zone.collision_layer = 0
	zone.collision_mask = 0xFFFFFFFF
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(WIDTH + 0.5, height + 0.6, 1.0)
	cs.shape = bs
	cs.position = Vector3(0, height * 0.5, 0.45)
	zone.add_child(cs)
	frame.add_child(zone)


## Dünya uzayında: merdivenin yüzeyinde, y yüksekliğindeki nokta (oyuncunun gövdesi bu noktanın önünde durur).
func point_at(t: float) -> Vector3:
	var up := global_transform.basis * Basis.from_euler(Vector3(deg_to_rad(-tilt), 0, 0)) * Vector3.UP
	return global_position + up * clampf(t, 0.0, height)


func up_dir() -> Vector3:
	return (global_transform.basis * Basis.from_euler(Vector3(deg_to_rad(-tilt), 0, 0)) * Vector3.UP).normalized()


func front_dir() -> Vector3:
	return (global_transform.basis * Basis.from_euler(Vector3(deg_to_rad(-tilt), 0, 0)) * Vector3.BACK).normalized()


func top_exit() -> Vector3:
	# Tepede: merdivenin ucundan biraz arkaya (yaslandığı yüzeyin üstüne)
	return point_at(height) - front_dir() * 0.7 + Vector3(0, 0.1, 0)


## Oyuncu bu merdivenin alanında mı
func has_body(b: Node3D) -> bool:
	return zone != null and zone.overlaps_body(b)
