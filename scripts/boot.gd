extends Node
## Açılış: hangi bölümün yükleneceğini seçer (varsayılan 1; test için --chapter=N).

func _ready() -> void:
	var ch := clampi(GameState.start_chapter, 1, 2)
	if ch > 1:
		GameState.ensure_defaults_for(ch)
	get_tree().change_scene_to_file.call_deferred("res://scenes/chapter%d.tscn" % ch)
