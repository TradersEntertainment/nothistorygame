extends Node3D
## ordugah-merkez gezi sondası (YALNIZ test; oyun kodu değil).
##   --probe=plan : IstOrdugah.plan() öğelerinin gerçek koordinatları (PLAN satırları)
##   --probe=yuru : gerçek oyuncu (player.gd) ile 6 güzergâh; GEZI_OLAY <tür> <doğu> <kuzey> satırları
## godot --headless --path . res://tests/_ist/gezi_ordugah-merkez.tscn -- --probe=yuru

const ROTALAR := [
	["otag_dogu", -5720.0, 1490.0, 90.0],
	["pazar_batarya", -5560.0, 913.0, 90.0],
	["halil_otag", -5950.0, 1157.0, 80.0],
	["mutfak_siper", -5400.0, 1807.0, 110.0],
	["siper_boyu", -5084.0, 1151.0, 15.0],
	["agil_otag", -6298.0, 1771.0, 75.0],
]
var probe := "yuru"
var cam: Camera3D
var dunya: IstDunya
var player: CharacterBody3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--probe="):
			probe = a.substr(8)
	if probe == "plan":
		for it: Dictionary in IstOrdugah.plan():
			var pos: Vector2 = it["pos"]
			var r := IstGeo.real(pos.x, pos.y)
			print("PLAN %s|%s|%s e=%.0f n=%.0f r=%s" % [it["kind"], it["id"], it["ad"], r.x, r.y, str(it["r"])])
		get_tree().quit(0)
		return
	cam = Camera3D.new()
	add_child(cam)
	var w0 := IstGeo.w2(ROTALAR[0][1], ROTALAR[0][2])
	cam.global_position = Vector3(w0.x, IstGeo.h(w0.x, w0.y) + 2.0, w0.y)
	dunya = IstDunya.build(self, false, cam.global_position) as IstDunya
	var P = load("res://scripts/player/player.gd")
	player = P.new()
	add_child(player)
	dunya.izle = player
	cam.current = false
	_yuru.call_deferred()


func _yuru() -> void:
	IstDunya.butce_us = 20000
	var toplam := 0.0
	var olay := 0
	for ro: Array in ROTALAR:
		var w := IstGeo.w2(ro[1], ro[2])
		player.global_position = Vector3(w.x, IstGeo.h(w.x, w.y) + 0.6, w.y)
		player.velocity = Vector3.ZERO
		player.rotation.y = -deg_to_rad(ro[3])
		dunya.carpisma_yenile(player.global_position)
		for i in 90:
			await get_tree().physics_frame
		Input.action_press("move_forward")
		Input.action_press("sprint")
		var son := player.global_position
		var yol := 0.0
		var pencere := player.global_position
		var havada := 0
		var t0 := Time.get_ticks_msec()
		var kare := 0
		var takil := 0
		while Time.get_ticks_msec() - t0 < 30000 and kare < 1000:
			await get_tree().physics_frame
			kare += 1
			var p := player.global_position
			yol += Vector2(p.x - son.x, p.z - son.z).length()
			son = p
			var g := IstGeo.h(p.x, p.z)
			var r := IstGeo.real(p.x, p.z)
			if not IstGeo.su(p.x, p.z) and p.y - g < -0.8:
				print("GEZI_OLAY DUSME %.0f %.0f rota=%s fark=%.2f" % [r.x, r.y, ro[0], p.y - g])
				olay += 1
				player.global_position = Vector3(p.x, g + 0.6, p.z)
			if not player.is_on_floor() and p.y - g > 3.0:
				havada += 1
				if havada == 60:
					print("GEZI_OLAY HAVADA %.0f %.0f rota=%s yukseklik=%.1f" % [r.x, r.y, ro[0], p.y - g])
					olay += 1
			else:
				havada = 0
			if kare % 60 == 0:
				if Vector2(p.x - pencere.x, p.z - pencere.z).length() < 1.5:
					takil += 1
					print("GEZI_OLAY TAKILMA %.0f %.0f rota=%s" % [r.x, r.y, ro[0]])
					olay += 1
					player.rotation.y += deg_to_rad(70.0)      # kurtul ve sürdür
				pencere = p
		Input.action_release("move_forward")
		Input.action_release("sprint")
		toplam += yol
		var r0 := IstGeo.real(son.x, son.z)
		print("GEZI_YOL rota=%s yol=%.0f m bitis=%.0f,%.0f takilma=%d" % [ro[0], yol, r0.x, r0.y, takil])
	print("GEZI_YURUYUS_TOPLAM %.0f m olay=%d" % [toplam, olay])
	get_tree().quit(0)
