extends "res://tests/_ist/tur7_kesim.gd"
## TUR-9: D gece kareleri (tur7_kesim.gd ile aynı kameralar ve kesim) ama ışık BÖLÜM 20'NİN IŞIĞI: Night.environment
## (sur_set_sahne.gd ile aynı sis 0,006) + GameState kalite kancası. Ay gölgesi ayarının (scripts/level/night.gd, look.gd)
## sette nasıl göründüğünü hızlı karşılaştırmak için.
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur9_gece.tscn -- \
##     --out=DIR --gece --sec=D1_peribolos_ic_sur_dibi,D2_peribolos_dis_sur_dibi,D3_peribolos_boyunca,D4_poterna_yani_dip


func _gok() -> void:
	gece = true
	Night.environment(self, 0.006)
	# sur_oyun_demo'daki meşaleler (aynı yerler)
	for p: Vector3 in [Vector3(-67.7, 2.2, 15.0), Vector3(-55.9, 9.8, 18.8), Vector3(-20.0, 9.8, 18.8), Vector3(-85.6, 1.8, 16.0), Vector3(-67.7, -2.0, 26.0)]:
		var l := OmniLight3D.new()
		l.light_color = Color("ffb35c")
		l.light_energy = 2.2
		l.omni_range = 14.0
		l.position = p
		add_child(l)
