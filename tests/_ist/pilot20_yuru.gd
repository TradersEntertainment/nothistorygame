extends Node
## PİLOT 20 yürüyüş kanıtı: Bölüm 20'yi "=yuru" test çeşidiyle açar (chapter20.gd _yuru): gerçek Player botu doğuş → depo →
## gedik (yükle) ×3 → ok sandığı → okçular → siper → gedik düello yeri bacaklarını yürür, yükleri gerçek etkileşim tuşuyla
## alır/bırakır. Eski set için komut satırına --eskisur.
##   timeout 300 godot --headless --path . res://tests/_ist/pilot20_yuru.tscn [-- --eskisur]
## Satırlar: PILOT20YURU bacak=… sure=… yol=… takilma=… dusme=… ; son satır PILOT20YURU OZET …


func _ready() -> void:
	GameState.autotest = true
	GameState.autotest_variant = "yuru"
	get_tree().change_scene_to_file.call_deferred("res://scenes/chapter20.tscn")
