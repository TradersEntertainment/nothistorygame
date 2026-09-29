class_name Gulls
extends Node3D
## Martı sürüsü: merkez çevresinde farklı yarıçap ve yükseklikte süzülen, kanat çırpan basit kuşlar (ucuz).

var _birds: Array = []
var _t := 0.0


static func make(parent: Node3D, center: Vector3, count := 9, radius := 40.0, height := 30.0, seed := 1) -> Gulls:
	var g := Gulls.new()
	g.position = center
	parent.add_child(g)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("f4f2ec")
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for i in count:
		var b := Node3D.new()
		g.add_child(b)
		var wings: Array = []
		for sx in [-1, 1]:
			var w := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(0.9, 0.04, 0.3)
			w.mesh = bm
			w.material_override = mat
			var pivot := Node3D.new()
			b.add_child(pivot)
			pivot.add_child(w)
			w.position = Vector3(sx * 0.45, 0, 0)
			wings.append([pivot, sx])
		var body := MeshInstance3D.new()
		var cm := CapsuleMesh.new()
		cm.radius = 0.1
		cm.height = 0.5
		body.mesh = cm
		body.rotation.x = PI * 0.5
		body.material_override = mat
		b.add_child(body)
		g._birds.append({"node": b, "wings": wings, "r": radius * rng.randf_range(0.5, 1.2), "h": height + rng.randf_range(-8.0, 10.0),
			"sp": rng.randf_range(0.18, 0.35) * (1.0 if rng.randf() < 0.7 else -1.0), "a": rng.randf() * TAU, "ph": rng.randf() * TAU})
	return g


func _process(delta: float) -> void:
	_t += delta
	for b in _birds:
		b.a += b.sp * delta
		var p := Vector3(cos(b.a) * b.r, b.h + sin(_t * 0.7 + b.ph) * 2.0, sin(b.a) * b.r)
		var n: Node3D = b.node
		n.position = p
		n.rotation.y = -b.a + (PI if b.sp > 0.0 else 0.0)
		var flap := sin(_t * 7.0 + b.ph) * 0.5 if fmod(_t + b.ph, 5.0) < 2.2 else 0.12
		for w in b.wings:
			(w[0] as Node3D).rotation.z = flap * w[1]
