class_name WallGuard
extends Node3D
## Sur yolunda canlı savunan: uzak kalabalık (MultiMesh) yerine gerçek asker. Oyuncu yakındayken ona döner ve başını
## çevirir; yanına sokulursa mızrağıyla dürter (can götürür, sendeletir). `active` kapalıyken yalnız bakar.
## Bölüm Blachernae.live_spots'tan kurar: WallGuard.spawn_all(scene, walls.live_spots, player)

const NOTICE := 28.0       # bu mesafede oyuncuya döner
const REACH := 2.3         # bu mesafede dürter
const COATS := [Color("7a2a24"), Color("5a6a7a"), Color("6a5a3a"), Color("2e4a6a"), Color("5a2a6a")]

var soldier: Soldier
var player: Player
var active := true
var damage := 9.0
var pokes := 0
var _cool := 0.0
var _home := Vector3.ZERO
var _rng := RandomNumberGenerator.new()


static func spawn_all(scene: Node3D, spots: Array[Transform3D], p: Player) -> Array[WallGuard]:
	var out: Array[WallGuard] = []
	for i in spots.size():
		var g := WallGuard.new()
		g.player = p
		g._rng.seed = 7301 + i * 13
		scene.add_child(g)
		g.global_transform = spots[i]
		g._home = spots[i].origin
		g.soldier = Soldier.new(COATS[i % COATS.size()], "stand", "helm")
		g.soldier.set_meta("no_talk", true)
		g.soldier.set_meta("climber", true)
		g.add_child(g.soldier)
		g.soldier.equip("spear" if i % 3 != 2 else "sword_shield", COATS[(i + 2) % COATS.size()])
		g._cool = g._rng.randf_range(0.0, 1.0)
		out.append(g)
	return out


func _process(delta: float) -> void:
	if not is_instance_valid(player) or soldier == null:
		return
	_cool -= delta
	var to := player.global_position - global_position
	var flat := Vector2(to.x, to.z)
	var d := flat.length()
	if d > NOTICE or absf(to.y) > 6.0:
		soldier.look_target = null
		return
	soldier.look_target = player
	# Yumuşak dönüş: gövde oyuncuya
	var want := atan2(to.x, to.z)
	rotation.y = lerp_angle(rotation.y, want, clampf(delta * 5.0, 0.0, 1.0))
	if active and d < REACH and absf(to.y) < 1.6 and _cool <= 0.0 and not player.is_down:
		_poke(Vector3(to.x, 0.0, to.z).normalized())


## Dürtme: öne atılır, mızrak ileri, geri çekilir. Oyuncu hâlâ menzildeyse can götürür ve sendeler.
func _poke(dir: Vector3) -> void:
	_cool = _rng.randf_range(1.3, 1.9)
	pokes += 1
	Audio.sfx("whoosh_fly", -8.0, 1.3)
	var tw := soldier.create_tween()
	tw.tween_property(soldier, "position", Vector3(0, 0, 0.45), 0.14).set_ease(Tween.EASE_OUT)
	if soldier._arm_r:
		soldier._arm_r.rotation.x = -1.5
	await tw.finished
	if is_instance_valid(player) and player.global_position.distance_to(global_position) < REACH + 0.5 and not player.is_down:
		player.hurt(damage, global_position + Vector3(0, 1.4, 0))
		player.stagger(0.35)
		Audio.sfx("land_thud", -6.0, 1.2)
		# İtilir: sur yolunda adamın önünden geri
		var push := dir * 0.7
		var col := player.move_and_collide(push, true)
		if col == null:
			player.global_position += push
	if not is_instance_valid(soldier):
		return
	var back := soldier.create_tween()
	back.tween_property(soldier, "position", Vector3.ZERO, 0.35).set_trans(Tween.TRANS_SINE)
	await back.finished
	if is_instance_valid(soldier) and soldier._arm_r:
		soldier._arm_r.rotation.x = 0.0
