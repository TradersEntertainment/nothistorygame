extends Node
## Açılış: hangi bölümün yükleneceğini seçer (varsayılan 1; test için --chapter=N ya da --chapter=10b).

func _ready() -> void:
	var ch := maxi(GameState.start_chapter, 1)
	var path := GameState.start_scene if GameState.start_scene != "" else "res://scenes/chapter%d.tscn" % ch
	if not ResourceLoader.exists(path):
		ch = clampi(ch, 1, GameState.LATEST_CHAPTER)
		path = "res://scenes/chapter%d.tscn" % ch
	if ch >= Siege.FIRST and ch <= Siege.LAST:
		GameState.ensure_defaults_for(12)     # kuşatma Bölüm 12 ile 13 arasındadır
		if path.ends_with("o.tscn"):
			GameState.flags["siege_side"] = "O"
	elif ch > 1:
		GameState.ensure_defaults_for(mini(ch, GameState.LATEST_CHAPTER))
	get_tree().change_scene_to_file.call_deferred(path)
