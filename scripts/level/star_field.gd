extends MultiMeshInstance3D
## Yıldızlar kamerayla birlikte taşınır (sonsuzda gibi durur, oyuncu yürüyünce kaymaz).
## Gökyüzü aydınlanınca (gündüz, şafak) solar: gündüz gökte yıldız görünmesin.

var _sky: ProceduralSkyMaterial


func _ready() -> void:
	for c in get_parent().get_children():
		if c is WorldEnvironment and (c as WorldEnvironment).environment and (c as WorldEnvironment).environment.sky:
			_sky = (c as WorldEnvironment).environment.sky.sky_material as ProceduralSkyMaterial


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam:
		global_position = cam.global_position
	if _sky:
		visible = _sky.sky_top_color.get_luminance() < 0.22
