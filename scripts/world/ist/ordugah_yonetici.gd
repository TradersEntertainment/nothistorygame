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
var lod0_m := 230.0
var lod1_m := 800.0
var butce_us := 9000
var kurulan := 0
var bakan: Node3D                 # yoksa etkin kamera


func kur(plan: Array) -> void:
	items = plan
	for i in items.size():
		var it: Dictionary = items[i]
		var p: Vector2 = it["pos"]
		it["y"] = IstGeo.h(p.x, p.y)
		it["lod"] = -1
		it["host"] = null
		kuyruk.append([i, 2])


func _cam_pos() -> Vector3:
	if bakan != null and is_instance_valid(bakan):
		return bakan.global_position
	var c := get_viewport().get_camera_3d()
	if c != null:
		return c.global_position
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
	for i in items.size():
		var it: Dictionary = items[i]
		var p: Vector2 = it["pos"]
		var d := Vector2(cp.x, cp.z).distance_to(p)
		var r: float = it["r"]
		var want := 2
		var cur: int = it["lod"]
		var k0 := lod0_m + r
		var k1 := lod1_m + r
		if cur >= 0 and cur <= 0:
			k0 *= 1.15
		if cur >= 0 and cur <= 1:
			k1 *= 1.15
		if d < k0:
			want = 0
		elif d < k1:
			want = 1
		if cur != want and not _kuyrukta(i):
			istek.append([d, i, want])
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
	K.filtre = func(x: float, z: float) -> bool:
		var v := Vector3(x, 0, z).rotated(Vector3.UP, yaw)
		var wx := px + v.x
		var wz := pz + v.z
		if IstGeo.su(wx, wz) or IstGeo.sehir_ici(wx, wz) or IstGeo.galata_ici(wx, wz):
			return false
		var wp := Vector2(wx, wz)
		for j in items.size():
			var o: Dictionary = items[j]
			if o["kind"] == "kanat" or o["kind"] == "siper":
				continue
			if (o["pos"] as Vector2).distance_to(wp) < float(o["r"]) + 4.0:
				return false
		return true
	IstOrdugah.uret(it, host, lod)
	K.zemin = Callable()
	K.filtre = Callable()
	var eski = it["host"]
	it["host"] = host
	it["lod"] = lod
	if eski != null and is_instance_valid(eski):
		(eski as Node).queue_free()
	kurulan += 1
