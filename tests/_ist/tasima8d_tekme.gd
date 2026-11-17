extends Node
## TAŞIMA-8D — sur yolu fıçılarına oyuncu tekmesi sondası. Bölümü oyunun kendi açılışıyla (main.tscn → boot) açar;
## kalıcı sonda bölüm yüklenince dış sur yolundaki stauroma dizilerinin (korkuluğa yaslı dört fıçı) uçtaki fıçısını
## gerçek Player.kick ile üç kez tekmeler: (1) dizinin dışından boyuna, (2) sur yolunun iç yanından korkuluğa doğru,
## (3) yeniden boyuna. Her donuştan sonra fıçının iki yanında oyuncunun geçeceği yer ölçülür (EsyaFizik._gecit_yan).
##   godot --headless --max-fps 20 --path . res://tests/_ist/tasima8d_tekme.tscn -- --chapter=26o [--dizi=3]
## Satırlar: T8DTEKME …, son satır T8DTEKME PASS|FAIL. ESYAAUDIT ortamı denetimi açar (bu sahne açar).

func _ready() -> void:
	var s := Node.new()
	s.set_script(preload("res://tests/_ist/tasima8d_tekme_sonda.gd"))
	s.name = "T8DTekmeSonda"
	get_tree().root.add_child.call_deferred(s)
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
