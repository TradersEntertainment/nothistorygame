extends Node3D
## Haliç gezi sondası (yalnız test): gerçek Player ile Haliç suru hattı boyunca 6 güzergâh yürür.
##   godot --headless --path . res://tests/_ist/gezi_halic.tscn
## Çıktı: GEZI_OLAY <tür> <doğu> <kuzey>; GEZI_ROTA ad uzunluk yürünen takılma düşme su
var dunya: IstDunya
var pl: CharacterBody3D
var cam: Camera3D


func _ready() -> void:
	cam = Camera3D.new()
	add_child(cam)
	cam.current = true
	var w := IstGeo.w2(-380.0, 852.0)
	cam.global_position = Vector3(w.x, 50.0, w.y)
	dunya = IstDunya.build(self, false, cam.global_position) as IstDunya
	IstDunya.butce_us = 20000
	var P = load("res://scripts/player/player.gd")
	pl = P.new()
	add_child(pl)
	dunya.izle = pl
	cam.current = false
	_calis.call_deferred()


func _nokta(pts: PackedVector2Array, s: float, off: float) -> Vector2:
	var L := 0.0
	for i in pts.size() - 1:
		var d := pts[i].distance_to(pts[i + 1])
		if s <= L + d or i == pts.size() - 2:
			var t := clampf((s - L) / d, 0.0, 1.0)
			var p := pts[i].lerp(pts[i + 1], t)
			var dir := (pts[i + 1] - pts[i]).normalized()
			var nrm := Vector2(-dir.y, dir.x)
			if nrm.y < 0.0:
				nrm = -nrm
			return p + nrm * off
		L += d
	return pts[pts.size() - 1]


func _calis() -> void:
	var pts := PackedVector2Array()
	for i in range(11, 36):
		pts.append(IstGeo.R_HALIC[i])
	# (ad, s0, s1, kıyı kenarına uzaklık: eksi = kara tarafı)
	var rotalar := [["R1_eugenios_neorion", 0.0, 420.0, -40.0], ["R2_neorion_venedik", 420.0, 840.0, -40.0],
		["R3_venedik_odun", 840.0, 1260.0, -40.0], ["R4_odun_perama", 1260.0, 1740.0, -40.0],
		["R5_sur_dibi_ic_bati", 0.0, 900.0, -110.0], ["R6_sur_dibi_ic_dogu", 900.0, 1740.0, -110.0]]
	var toplam := 0.0
	for r: Array in rotalar:
		var s := float(r[1])
		var p0 := _nokta(pts, s, float(r[3]))
		var w := IstGeo.w2(p0.x, p0.y)
		pl.global_position = Vector3(w.x, IstGeo.h(w.x, w.y) + 0.6, w.y)
		dunya.carpisma_yenile(pl.global_position)
		for i in 40:
			await get_tree().physics_frame
		var yol := 0.0
		var tak := 0
		var dus := 0
		var sul := 0
		var son := pl.global_position
		var son_t := Time.get_ticks_msec()
		var kontrol := pl.global_position
		var t_rota := Time.get_ticks_msec()
		Input.action_press("move_forward")
		Input.action_press("sprint")
		while s < float(r[2]) - 5.0 and Time.get_ticks_msec() - t_rota < 90000:
			await get_tree().physics_frame
			var pp := pl.global_position
			yol += Vector2(pp.x - son.x, pp.z - son.z).length()
			son = pp
			var hedef := _nokta(pts, s + 8.0, float(r[3]))
			var hw := IstGeo.w2(hedef.x, hedef.y)
			var to := Vector2(hw.x - pp.x, hw.y - pp.z)
			pl.rotation.y = atan2(-to.x, -to.y)
			if to.length() < 3.0:
				s += 8.0
			var g := IstGeo.h(pp.x, pp.z)
			var re := IstGeo.real(pp.x, pp.z)
			if IstGeo.su(pp.x, pp.z):
				sul += 1
				if sul == 1:
					print("GEZI_OLAY su %.0f %.0f" % [re.x, re.y])
			if pp.y < g - 0.8 and not IstGeo.su(pp.x, pp.z):
				dus += 1
				print("GEZI_OLAY dusme %.0f %.0f" % [re.x, re.y])
				pl.global_position = Vector3(pp.x, g + 0.6, pp.z)
			if Time.get_ticks_msec() - son_t > 4000:
				if Vector2(pp.x - kontrol.x, pp.z - kontrol.z).length() < 1.0:
					tak += 1
					print("GEZI_OLAY takilma %.0f %.0f" % [re.x, re.y])
					s += 10.0
					var np := _nokta(pts, s, float(r[3]))
					var nw := IstGeo.w2(np.x, np.y)
					pl.global_position = Vector3(nw.x, IstGeo.h(nw.x, nw.y) + 0.6, nw.y)
				son_t = Time.get_ticks_msec()
				kontrol = pl.global_position
		Input.action_release("move_forward")
		Input.action_release("sprint")
		toplam += yol
		print("GEZI_ROTA %s yol=%.0f hedef_s=%.0f takilma=%d dusme=%d su_kare=%d" % [r[0], yol, s, tak, dus, sul])
	print("GEZI_YURUYUS toplam_m=%.0f" % toplam)
	get_tree().quit(0)
