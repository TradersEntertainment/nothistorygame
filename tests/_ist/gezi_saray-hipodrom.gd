extends Node3D
## Gezi sondası, bölge `saray-hipodrom` (yalnız test; oyun kodu değil).
##   -- --set=maske [--e0= --e1= --n0= --n1= --adim=60]   GEZIMASKE satırları: kara/su, yükseklik (kare listesi için)
##   -- --set=yuru --rota=ad:e,n;e,n;…                     gerçek Player ile rota yürür (GEZI_OLAY satırları)
## Rota noktaları gerçek doğu,kuzey (m). Oyuncu her noktaya yürür; takılma/düşme/suya girme sayılır.

var set_ := "maske"
var e0 := -800.0
var e1 := 700.0
var n0 := -1000.0
var n1 := 900.0
var adim := 60.0
var rotalar: Array = []
var dunya: Node3D
var player: CharacterBody3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"set": set_ = kv[1]
			"e0": e0 = kv[1].to_float()
			"e1": e1 = kv[1].to_float()
			"n0": n0 = kv[1].to_float()
			"n1": n1 = kv[1].to_float()
			"adim": adim = kv[1].to_float()
			"rota": rotalar.append(kv[1])
	if set_ == "yerler":
		var cam0 := Camera3D.new()
		add_child(cam0)
		cam0.current = true
		var w0 := IstGeo.w2(-300.0, -300.0)
		cam0.global_position = Vector3(w0.x, 40.0, w0.y)
		dunya = IstDunya.build(self, false, cam0.global_position)
		IstDunya.butce_us = 250000
		await get_tree().process_frame
		var s0 := IstSehir.active
		var t0 := Time.get_ticks_msec()
		while s0 != null and Time.get_ticks_msec() - t0 < 120000:
			s0._last_cam = Vector3.INF
			for k in 400:
				s0._process(0.0)
				if s0._queue.is_empty():
					break
			if s0._queue.is_empty():
				break
			await get_tree().process_frame
		for c in s0.get_children():
			var re := IstGeo.real(c.global_position.x, c.global_position.z) if c is Node3D else Vector2.ZERO
			if re.x > -900.0 and re.x < 800.0 and re.y > -1100.0 and re.y < 1000.0 and String(c.name).begins_with("Ist_"):
				print("GEZIYER %s e=%.0f n=%.0f" % [c.name, re.x, re.y])
		get_tree().quit(0)
		return
	if set_ == "izgara":
		var nn := n1
		while nn >= n0:
			var ee := e0
			while ee <= e1:
				var ww := IstGeo.w2(ee, nn)
				var yy := IstGeo.h(ww.x, ww.y)
				print("GEZIIZ %d %d %.1f" % [int(ee), int(nn), yy])
				ee += adim
			nn -= adim
		get_tree().quit(0)
		return
	if set_ == "maske":
		_maske()
		get_tree().quit(0)
		return
	var cam := Camera3D.new()
	cam.far = 3000.0
	add_child(cam)
	cam.current = true
	var r0 := _nokta(String(rotalar[0]).split(":")[1].split(";")[0])
	var w := IstGeo.w2(r0.x, r0.y)
	cam.global_position = Vector3(w.x, 60.0, w.y)
	dunya = IstDunya.build(self, false, cam.global_position)
	IstDunya.butce_us = 20000
	await get_tree().process_frame
	await _yuru()
	get_tree().quit(0)


func _nokta(s: String) -> Vector2:
	var p := s.split(",")
	return Vector2(p[0].to_float(), p[1].to_float())


func _maske() -> void:
	var n := n1
	while n >= n0:
		var satir := ""
		var e := e0
		while e <= e1:
			var w := IstGeo.w2(e, n)
			var y := IstGeo.h(w.x, w.y)
			satir += "S" if y < 0.0 else ("." if y < 8.0 else ("o" if y < 16.0 else "O"))
			e += adim
		print("GEZIMASKE n=%5d %s" % [int(n), satir])
		n -= adim


func _bekle() -> void:
	var t0 := Time.get_ticks_msec()
	for i in 6:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < 30000:
		if dunya.has_method("olcum") and int(dunya.olcum()["isler"]) == 0:
			break
		await get_tree().process_frame


func _yuru() -> void:
	var P = load("res://scripts/player/player.gd")
	for rota: String in rotalar:
		var ad := rota.split(":")[0]
		var nok: Array = []
		for s: String in rota.split(":")[1].split(";"):
			nok.append(_nokta(s))
		player = P.new()
		add_child(player)
		var w: Vector2 = IstGeo.w2(nok[0].x, nok[0].y)
		player.global_position = Vector3(w.x, IstGeo.h(w.x, w.y) + 0.6, w.y)
		dunya.izle = player
		dunya.carpisma_yenile(player.global_position)
		await _bekle()
		for i in 40:
			await get_tree().physics_frame
		var yol := 0.0
		var son := player.global_position
		var olay := 0
		for k in range(1, nok.size()):
			var hedef: Vector2 = IstGeo.w2(nok[k].x, nok[k].y)
			var takili := 0.0
			var sapma := 0
			var son_nokta := Vector2(player.global_position.x, player.global_position.z)
			var t0 := Time.get_ticks_msec()
			var onceki := Vector2(son.x, son.z)
			while true:
				var p := player.global_position
				var d := Vector2(hedef.x - p.x, hedef.y - p.z)
				if d.length() < 1.5 or Time.get_ticks_msec() - t0 > 90000:
					break
				player.rotation.y = atan2(-d.x, -d.y) + deg_to_rad([0.0, 55.0, -55.0, 110.0, -110.0][sapma % 5])
				Input.action_press("move_forward")
				Input.action_press("sprint")
				await get_tree().physics_frame
				var q := player.global_position
				yol += Vector2(q.x - son.x, q.z - son.z).length()
				son = q
				var g := IstGeo.h(q.x, q.z)
				var re := IstGeo.real(q.x, q.z)
				if q.y - g < -1.0 and not IstGeo.su(q.x, q.z):
					olay += 1
					print("GEZI_OLAY dusme %.0f %.0f" % [re.x, re.y])
				if IstGeo.su(q.x, q.z) and q.y < -0.3:
					olay += 1
					print("GEZI_OLAY suya_girme %.0f %.0f" % [re.x, re.y])
				# takılma: 1 sn'de 0,3 m'den az ilerleme -> yönü kaydır (sapma); 8 kez art arda olursa vazgeç
				if Engine.get_physics_frames() % 60 == 0:
					var simdi := Vector2(q.x, q.z)
					if simdi.distance_to(onceki) < 0.3:
						takili += 1.0
						sapma += 1
						print("GEZI_OLAY takilma %.0f %.0f" % [re.x, re.y])
					elif simdi.distance_to(son_nokta) > 3.0:
						takili = 0.0
						sapma = 0
						son_nokta = simdi
					onceki = simdi
				if takili >= 8.0:
					print("GEZI_OLAY vazgec %.0f %.0f hedef=%.0f,%.0f" % [re.x, re.y, nok[k].x, nok[k].y])
					break
			Input.action_release("move_forward")
			Input.action_release("sprint")
		print("GEZI_ROTA %s yol_dunya_m=%.0f gercek_m=%.0f olay=%d" % [ad, yol, yol / IstGeo.S, olay])
		player.queue_free()
		await get_tree().process_frame
