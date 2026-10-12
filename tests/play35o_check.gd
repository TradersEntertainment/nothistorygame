extends Node
## Bölüm 35o köprüsünü insan gibi oynar (tests/play35o_driver.gd): bölüm otomatik test kipi olmadan açılır, sürücü
## kökte kalır. Sonuç: PLAYCHECK PASS/FAIL.

func _ready() -> void:
	Engine.time_scale = 2.0
	get_tree().root.add_child.call_deferred(preload("res://tests/play35o_driver.gd").new())
	GameState.reset_run()
	GameState.ensure_defaults_for(35)
	get_tree().change_scene_to_file.call_deferred("res://scenes/chapter35o.tscn")
