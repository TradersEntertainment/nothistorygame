extends MultiMeshInstance3D
## Yıldızlar kamerayla birlikte taşınır (sonsuzda gibi durur, oyuncu yürüyünce kaymaz).

func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam:
		global_position = cam.global_position
