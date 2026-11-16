extends Node
## EŞYA FİZİĞİ — oyun içi kanıt ve bütçe sondası. Bölümü oyunun kendi açılışıyla (main.tscn → boot) açar; kalıcı bir
## sonda düğümü (esya_bolum_sonda.gd) bölüm yüklenince oyuncuyu bir dekor eşyasının yanına koyar, Player.kick ile
## tekmeletir ve kare dizisi çeker (tekmeden önce / 0,3 sn / 1 sn / durunca), ya da bütçe ölçer.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --rendering-driver opengl3 --resolution 1280x720 \
##       res://tests/_ist/esya_bolum.tscn -- --chapter=20 --kare=DIR [--bekle=10] [--sec=0] [--yer=x,z]
##   bütçe: … -- --chapter=20 --olc [--bekle=12]      (ÖNCE: aynı komut ESYA_KAPALI=1 ortamıyla)
##   Bölüm 0 savrulanlar: … -- --chapter=0 --autotest --donma --kare=DIR
## Satırlar: ESYABOLUM …

func _ready() -> void:
	var s := preload("res://tests/_ist/esya_bolum_sonda.gd").new()
	s.name = "EsyaBolumSonda"
	get_tree().root.add_child.call_deferred(s)
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
