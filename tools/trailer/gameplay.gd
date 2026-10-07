extends Node
## Oynanış fragmanı: gerçek bölümleri oyunun kendi test botlarıyla (--autotest) oynatır, her bölümde mekaniğin başladığı
## anı (düello, tüfek doldurma, top nişanı, merdiven, uçuş...) bekler ve yalnız o pencereyi gösterir. Bekleme sırasında
## ekran kara, ses kapalı, zaman hızlı akar; kayıttan bu kısımlar gameplay_cut.py ile atılır (kesim listesi stdout'ta).
##
## Kayıt (kesim listesi için çıktı dosyaya):
##   godot --path . --write-movie oynanis_ham.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/gameplay.tscn > oynanis.log
##   python3 tools/trailer/gameplay_cut.py oynanis_ham.avi oynanis.log oynanis.mp4   (libx264'süz ffmpeg: --vcodec h264_nvenc)
## Çekimler (~54 sn): açılış kartı · kılıç düellosu (20) · top doldurma ve nişan (20o) · fitilli tüfek (20) · Haliç'te
## kürek (38o) · uçuş ve görünmezlik (7, oyuncuyu bu betik uçurur) · 1453 İstanbul sokakları (31o) · Sonsuz Kuşatma · kapanış.
## İngilizce: sona "-- en". Tek çekim önizleme: "-- only=3". Kayıtsız kare önizleme: "-- shots=/klasör" (her saniye bir PNG).

const Montage := preload("res://tools/trailer/montage.gd")


func _ready() -> void:
	var m := Montage.new()
	get_tree().root.add_child.call_deferred(m)
