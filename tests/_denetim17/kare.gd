extends "res://tests/_ist/tasima12_kare.gd"
## G17 kare aracı (ÖNCE|SONRA): bölümü gerçek akışında açar, bölümün YEREL koordinatlarında verilen bakışlardan kare alır.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_denetim17/kare.tscn -- bolum=8y shots=KLASÖR \
##       bakis="ad:gx,gy,gz:hx,hy,hz;ad2:…"
## (göz → hedef; ikisi de bölüm kökünün yerelinde). Satırlar: T10KARE ad=… · T10KARE_BITTI

var bakis := ""


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2 and kv[0] == "bakis":
			bakis = kv[1]
	super._ready()


func _v(s: String) -> Vector3:
	var p := s.split(",")
	return Vector3(float(p[0]), float(p[1]), float(p[2]))


func _bakislar() -> Array:
	var b: Array = []
	for parca: String in bakis.split(";", false):
		var q := parca.split(":")
		if q.size() < 3:
			continue
		b.append([q[0], ch.to_global(_v(q[1])), ch.to_global(_v(q[2])), null])
	return b
