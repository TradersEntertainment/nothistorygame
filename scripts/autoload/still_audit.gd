class_name StillAudit
extends Node
## Donuk karakter denetçisi (--stillaudit): sahne açıldıktan 6 sn sonra her karakterin (Rig: Person, Soldier) baş,
## gövde ve kollarının dönüşü kaydedilir; 3 sn sonra yeniden ölçülür. Hiçbir parçası 0,02 rad'dan fazla oynamayan,
## ekranda görünür karakter "donuk" sayılır (canlı kalabalıkta en yapay görüntü). Satırlar:
##   STILL scene=... rigs=.. frozen=.. (%)        STILLRIG scene=... who=... activity=...   (ilk 10 donuk)

var _scene := ""
var _t := 0.0
var _snap := {}
var _done := false


func _init() -> void:
	name = "StillAudit"


func _process(delta: float) -> void:
	var sc := get_tree().current_scene
	var sname := sc.scene_file_path.get_file().get_basename() if sc else ""
	if sname != _scene:
		_scene = sname
		_t = 0.0
		_snap.clear()
		_done = false
	if get_tree().paused or _done:
		return
	_t += delta
	if _t >= 6.0 and _snap.is_empty():
		for r in _rigs():
			_snap[r.get_instance_id()] = _pose(r)
	elif _t >= 9.0 and not _snap.is_empty():
		_done = true
		var rigs := _rigs()
		var frozen: Array = []
		var n := 0
		for r in rigs:
			var id: int = r.get_instance_id()
			if not _snap.has(id):
				continue
			n += 1
			var a: Array = _snap[id]
			var b: Array = _pose(r)
			var moved := 0.0
			for i in a.size():
				moved = maxf(moved, (a[i] as Vector3).distance_to(b[i]))
			if moved < 0.02:
				frozen.append(r)
		print("STILL scene=%s rigs=%d frozen=%d (%d%%)" % [_scene, n, frozen.size(), int(100.0 * frozen.size() / maxf(1.0, n))])
		for k in mini(10, frozen.size()):
			var r: Rig = frozen[k]
			print("STILLRIG scene=%s who=%s activity=%s lock=%d" % [_scene, r.owner.name if r.owner else "?", r.activity, r.lock])


## Yalnız kameranın gördüğü ve 40 m içindeki karakterler (görüş dışındakilerin iskeleti bilerek bekler: CityLife)
func _rigs() -> Array:
	var out: Array = []
	var cam := get_viewport().get_camera_3d()
	for n in get_tree().get_nodes_in_group("persons") + get_tree().get_nodes_in_group("soldiers"):
		var r = n.get("rig")
		if not (r is Rig) or not (n as Node3D).is_visible_in_tree():
			continue
		var p := (n as Node3D).global_position + Vector3(0, 1.2, 0)
		if cam and (not cam.is_position_in_frustum(p) or cam.global_position.distance_to(p) > 40.0):
			continue
		out.append(r)
	return out


func _pose(r: Rig) -> Array:
	var out: Array = []
	for part in [r.head, r.body, r.arm_l, r.arm_r]:
		out.append((part as Node3D).rotation if part is Node3D else Vector3.ZERO)
	return out
