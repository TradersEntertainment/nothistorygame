extends Node3D
## GEZİ mese-dogu: gerçek oyuncuyla (scripts/player/player.gd) güzergâh yürüyüşü sondası (yalnız test; oyun kodu değil).
##   godot --path . --resolution 1280x720 res://tests/_ist/gezi_mese-dogu.tscn -- shots=KLASÖR [rota=ÖNEK]
## Satırlar: GEZI_OLAY <tür> <x> <z> ...; GEZI_ROTA <ad> yol=… ; kare her ~15 m'de (shots/yuru_<rota>_<n>.png).
## Rotalar gerçek (doğu, kuzey) noktalarıdır; oyuncu sırayla her noktaya yürür.

const ROTALAR := {
	"r1_konstantin_mese_milion": [[-790, 0], [-700, 5], [-560, 10], [-420, 5], [-300, 0], [-200, -40], [-130, -90]],
	"r2_milion_augustaion_khalke": [[-130, -90], [-90, -80], [-60, -95], [-50, -130], [-45, -160]],
	"r3_ayasofya_bati_giris": [[-120, 20], [-80, 20], [-50, 15], [-40, 0], [-30, -15]],
	"r4_ayasofya_cevre_guney": [[-60, -60], [-20, -75], [30, -75], [75, -50], [75, -10]],
	"r5_ayasofya_cevre_kuzey": [[75, -10], [75, 35], [30, 60], [-20, 60], [-60, 40]],
	"r6_irini_patrikhane": [[-30, 70], [40, 85], [100, 90], [140, 70], [150, 30]],
	"r7_mese_kuzey_sokaklar": [[-700, 120], [-560, 130], [-420, 110], [-300, 130], [-200, 120]],
	"r8_mese_guney_sokaklar": [[-700, -120], [-560, -130], [-420, -110], [-300, -130], [-200, -120]],
	"r10_mese_tam": [[-1100, 95], [-900, 60], [-760, 10], [-600, 15], [-420, 10], [-250, 0], [-110, -20]],
	"r11_aya_dis_halka": [[0, 230], [88, 212], [163, 163], [212, 88], [230, 0], [212, -88], [163, -163], [88, -212], [0, -230], [-88, -212], [-163, -163], [-212, -88], [-230, 0], [-212, 88], [-163, 163], [-88, 212], [0, 230]],
	"r9_konstantin_cevre": [[-800, -40], [-760, -60], [-720, -20], [-740, 30], [-790, 30]],
}

var shots := ""
var sec := ""
var kim := ""          # kim=e,n,r[;e,n,r…] : o noktaların çevresindeki görünür düğümlerin adları (GEZI_KIM satırları)
var dunya: IstDunya
var player: CharacterBody3D
var cam: Camera3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"shots": shots = kv[1]
			"rota": sec = kv[1]
			"kim": kim = kv[1]
	cam = Camera3D.new()
	cam.far = 30000.0
	add_child(cam)
	cam.current = true
	var w0 := IstGeo.w2(-790.0, 0.0)
	if kim != "":
		var q0 := kim.split(";")[0].split(",")
		w0 = IstGeo.w2(q0[0].to_float(), q0[1].to_float())
	cam.global_position = Vector3(w0.x, IstGeo.h(w0.x, w0.y) + 30.0, w0.y)
	dunya = IstDunya.build(self, false, cam.global_position) as IstDunya
	if kim != "":
		_kim.call_deferred()
		return
	var P = load("res://scripts/player/player.gd")
	player = P.new()
	add_child(player)
	dunya.izle = player
	cam.current = false
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	_yuru.call_deferred()


func _bekle(sn := 25.0) -> void:
	var t0 := Time.get_ticks_msec()
	for i in 6:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < sn * 1000.0:
		if dunya.olcum()["isler"] == 0:
			break
		await get_tree().process_frame


func _yuru() -> void:
	IstDunya.butce_us = 20000
	var toplam := 0.0
	var olay := 0
	for ad: String in ROTALAR:
		if sec != "":
			var ok := false
			for pre: String in sec.split(","):
				if ad.begins_with(pre + "_"):
					ok = true
			if not ok:
				continue
		var pts: Array = ROTALAR[ad]
		var w := IstGeo.w2(pts[0][0], pts[0][1])
		player.global_position = Vector3(w.x, IstGeo.h(w.x, w.y) + 0.6, w.y)
		dunya.carpisma_yenile(player.global_position)
		await _bekle()
		for i in 20:
			await get_tree().physics_frame
		var yol := 0.0
		var kare_n := 0
		var son_kare := player.global_position
		var rota_olay := 0
		for k in range(1, pts.size()):
			var hedef := IstGeo.w2(pts[k][0], pts[k][1])
			var t0 := Time.get_ticks_msec()
			var son := player.global_position
			var son_t := t0
			var takili := 0
			var yerde_degil := 0.0
			while true:
				var p := player.global_position
				var d := Vector2(hedef.x - p.x, hedef.y - p.z)
				if d.length() < 2.0:
					break
				if Time.get_ticks_msec() - t0 > 45000:
					print("GEZI_OLAY zaman_asimi %.1f %.1f rota=%s nokta=%d" % [p.x, p.z, ad, k])
					rota_olay += 1
					break
				player.rotation.y = atan2(-d.x, -d.y)
				Input.action_press("move_forward")
				Input.action_press("sprint")
				await get_tree().physics_frame
				var q := player.global_position
				yol += Vector2(q.x - p.x, q.z - p.z).length()
				var g := IstGeo.h(q.x, q.z)
				if q.y < g - 1.0 and not IstGeo.su(q.x, q.z):
					print("GEZI_OLAY dusme %.1f %.1f y=%.2f zemin=%.2f rota=%s" % [q.x, q.z, q.y, g, ad])
					rota_olay += 1
					player.global_position = Vector3(q.x, g + 0.6, q.z)
				if not player.is_on_floor():
					yerde_degil += get_physics_process_delta_time()
				else:
					yerde_degil = 0.0
				if yerde_degil > 2.5:
					print("GEZI_OLAY havada %.1f %.1f y=%.2f zemin=%.2f rota=%s" % [q.x, q.z, q.y, g, ad])
					rota_olay += 1
					yerde_degil = 0.0
				if Time.get_ticks_msec() - son_t > 2500:
					if Vector2(q.x - son.x, q.z - son.z).length() < 0.8:
						takili += 1
						print("GEZI_OLAY takili %.1f %.1f rota=%s nokta=%d hedef=%.1f,%.1f" % [q.x, q.z, ad, k, hedef.x, hedef.y])
						rota_olay += 1
						if takili >= 3:
							break
						# yan adım: hedefe dik yönde 6 m kaydırıp yeniden dene (engeli dolaşma)
						var dd := Vector2(hedef.x - q.x, hedef.y - q.z).normalized()
						var yan := Vector2(-dd.y, dd.x) * (6.0 if takili % 2 == 1 else -6.0)
						player.global_position = Vector3(q.x + yan.x, IstGeo.h(q.x + yan.x, q.z + yan.y) + 0.6, q.z + yan.y)
					else:
						takili = 0
					son = q
					son_t = Time.get_ticks_msec()
				if Vector2(q.x - son_kare.x, q.z - son_kare.z).length() >= 15.0:
					son_kare = q
					kare_n += 1
					await RenderingServer.frame_post_draw
					if shots != "":
						get_viewport().get_texture().get_image().save_png(shots.path_join("yuru_%s_%02d.png" % [ad, kare_n]))
						var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
						var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
						print("RINFO yuru %s_%02d cizim=%d ucgen=%d konum=%.1f,%.1f" % [ad, kare_n, dc, pr, q.x, q.z])
			Input.action_release("move_forward")
			Input.action_release("sprint")
		toplam += yol
		olay += rota_olay
		print("GEZI_ROTA %s yol=%.0f m olay=%d kare=%d" % [ad, yol, rota_olay, kare_n])
	print("GEZI_YURU_SONUC toplam=%.0f m olay=%d" % [toplam, olay])
	get_tree().quit(0)


## Düğüm adları: kim noktalarının r (gerçek m) çevresindeki görünür GeometryInstance3D'lerin yolları (ilk 5 düzey) ve sayıları.
func _kim() -> void:
	IstDunya.butce_us = 250000
	for i in 4:
		await get_tree().process_frame
	var s := IstSehir.active
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 90000:
		var bos := true
		if int(dunya.olcum()["isler"]) > 0:
			bos = false
		if s != null:
			s._last_cam = Vector3.INF
			for k in 400:
				s._process(0.0)
				if s._queue.is_empty():
					break
			if not s._queue.is_empty():
				bos = false
		if bos:
			break
		await get_tree().process_frame
	for nokta in kim.split(";"):
		var q := nokta.split(",")
		var w := IstGeo.w2(q[0].to_float(), q[1].to_float())
		var r := q[2].to_float() * IstGeo.S
		var say := {}
		for c in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
			var gi := c as GeometryInstance3D
			if not gi.is_visible_in_tree():
				continue
			var yol := String(gi.get_path()).replace("/root/GeziMeseDogu/", "")
			var pr := yol.split("/")
			var kisa := "/".join(pr.slice(0, mini(4, pr.size())))
			var o := gi.global_position
			if gi is MultiMeshInstance3D:
				var mm := (gi as MultiMeshInstance3D).multimesh
				if mm == null:
					continue
				var n := 0
				for i in mini(mm.instance_count, 4000):
					var oo := gi.global_transform * mm.get_instance_transform(i).origin
					if Vector2(oo.x, oo.z).distance_to(w) < r:
						n += 1
				if n > 0:
					say[kisa + " [MM]"] = int(say.get(kisa + " [MM]", 0)) + n
			elif Vector2(o.x, o.z).distance_to(w) < r:
				say[kisa] = int(say.get(kisa, 0)) + 1
		for k: String in say:
			print("GEZI_KIM %s r=%s %s = %d" % [q[0] + "," + q[1], q[2], k, say[k]])
	print("GEZI_KIM bitti")
	get_tree().quit(0)
