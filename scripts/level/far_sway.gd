extends Node
## Uzaktaki (MultiMesh) sur savunanları donuk durmasın: her biri kendi evresinde öne eğilip doğrulur (siperden
## aşağı bakıp dürter gibi) ve hafifçe yana kayar. Yalnız kameraya yakın (görünür) kümeler güncellenir; 10 Hz.

var _sets: Array = []      # [MultiMeshInstance3D, [temel dönüşümler], [evreler]]
var _t := 0.0
var _acc := 0.0


func add(mmi: MultiMeshInstance3D) -> void:
	var mm := mmi.multimesh
	var base: Array = []
	var ph: Array = []
	for i in mm.instance_count:
		base.append(mm.get_instance_transform(i))
		ph.append(randf() * TAU)
	_sets.append([mmi, base, ph])


func _process(delta: float) -> void:
	_t += delta
	_acc += delta
	if _acc < 0.1:
		return
	_acc = 0.0
	var cam := get_viewport().get_camera_3d()
	for s: Array in _sets:
		var mmi := s[0] as MultiMeshInstance3D
		if not is_instance_valid(mmi) or not mmi.is_visible_in_tree():
			continue
		if cam and cam.global_position.distance_to(mmi.global_position + (s[1][0] as Transform3D).origin) > 140.0:
			continue
		var mm := mmi.multimesh
		for i in mm.instance_count:
			var b: Transform3D = s[1][i]
			var e: float = _t * 1.7 + float(s[2][i])
			# Dürtüş: öne eğilme (0–0,35 rad), kısa kısa; yana küçük kayma
			var lean := maxf(0.0, sin(e)) * 0.35 * (0.5 + 0.5 * sin(e * 3.1))
			var xf := b
			xf.basis = b.basis * Basis(Vector3.RIGHT, lean)
			xf.origin = b.origin + b.basis.x * sin(e * 0.37) * 0.25
			mm.set_instance_transform(i, xf)
