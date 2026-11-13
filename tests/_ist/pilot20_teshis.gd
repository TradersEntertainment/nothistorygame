extends Node
## PİLOT 20 görsel teşhis: Bölüm 20'yi açar, oyuncuyu depo önüne koyup gediğe baktırır (ilk kare `c20_01_carry` bakışı),
## sonra sahnenin üst düğümlerini (ve sur kesiminin çocuklarını) TEK TEK gizleyip kare alır. Her gizlemede verilen ekran
## kutusundaki (x0,y0,x1,y1) koyu piksel oranını ve ortalama rengi yazar: hangi düğüm gizlenince kusur kayboluyorsa kaynak odur.
##   PACE=1 xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/pilot20_teshis.tscn \
##     -- --kutu=760,405,1170,470 --teshis=<klasör> [--eskisur] [--bakis=depo|dogus|siper]
## Satırlar: TESHIS taban koyu=… ; TESHIS gizli=<yol> koyu=… fark=…

const K := preload("res://tests/_ist/pilot20_teshis_k.gd")


func _ready() -> void:
	GameState.autotest = false
	var k := K.new()
	k.name = "Pilot20Teshis"
	get_tree().root.add_child.call_deferred(k)
	get_tree().change_scene_to_file.call_deferred("res://scenes/chapter20.tscn")
