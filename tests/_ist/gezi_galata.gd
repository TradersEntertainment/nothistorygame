extends Node3D
## Galata gezi denetimi: gerçek oyuncuyla (scripts/player/player.gd) güzergâh yürüyüşü. Yalnız test dosyası.
##   godot --path . res://tests/_ist/gezi_galata.tscn -- [--out=KLASÖR] [--shot=1]
## Satırlar: GEZI_OLAY <tür> <doğu> <kuzey> (tak | dus | su | duvar_zipla), GEZI_ROTA ad uzunluk=… yurunen=… tak=… dus=…
## shot=1 ekranlı koşuda olay anında kare yazar (olay_<n>.png, yürüyüş yönü).

var out := ""
var shot := false
var cam: Camera3D
var dunya: Node3D
var pl: CharacterBody3D
var _iyi := Vector3.ZERO

const ROTALAR := {
	"r1_rihtimdan_kuleye": [[-470, 1485], [-478, 1600], [-490, 1720], [-487, 1860]],
	"r2_bati_dogu_orta": [[-900, 1640], [-700, 1660], [-500, 1700], [-300, 1720], [-100, 1740]],
	"r3_dogu_dikme": [[-250, 1530], [-250, 1640], [-260, 1760], [-250, 1880]],
	"r4_bati_dikme": [[-700, 1555], [-700, 1700], [-690, 1830], [-640, 1915]],
	"r5_surdan_disari": [[-300, 1800], [-380, 1900], [-480, 1990], [-480, 2060], [-450, 2200]],
	"r6_iskele_boyu": [[-790, 1615], [-700, 1585], [-600, 1560], [-520, 1560], [-420, 1545], [-330, 1555]],
}


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2:
			if kv[0] == "out": out = kv[1]
			if kv[0] == "shot": shot = kv[1] == "1"
	if out != "":
		DirAccess.make_dir_recursive_absolute(out)
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var w0 := IstGeo.w2(-470.0, 1485.0)
	cam.global_position = Vector3(w0.x, 40.0, w0.y)
	dunya = IstDunya.build(self, false, cam.global_position)
	IstDunya.butce_us = 250000
	await get_tree().process_frame
	var P = load("res://scripts/player/player.gd")
	pl = P.new()
	add_child(pl)
	dunya.izle = pl
	Engine.time_scale = 2.0
	var tum := 0.0
	var olay := 0
	for ad: String in ROTALAR:
		var pts: Array = ROTALAR[ad]
		var w := IstGeo.w2(pts[0][0], pts[0][1])
		pl.global_position = Vector3(w.x, IstGeo.h(w.x, w.y) + 1.0, w.y)
		dunya.carpisma_yenile(pl.global_position)
		for i in 40:
			await get_tree().physics_frame
		var uz := 0.0
		var yur := 0.0
		var tak := 0
		var dus := 0
		for i in pts.size() - 1:
			uz += Vector2(pts[i][0], pts[i][1]).distance_to(Vector2(pts[i + 1][0], pts[i + 1][1]))
		for i in range(1, pts.size()):
			var hw := IstGeo.w2(pts[i][0], pts[i][1])
			var t := 0.0
			var son := Vector2(pl.global_position.x, pl.global_position.z)
			var son_t := 0.0
			var stuck := 0
			while t < 90.0:
				await get_tree().physics_frame
				var dt := get_physics_process_delta_time()
				t += dt
				if pl.is_on_floor() and not IstGeo.su(pl.global_position.x, pl.global_position.z):
					_iyi = pl.global_position
				var p2 := Vector2(pl.global_position.x, pl.global_position.z)
				var to := Vector3(hw.x - p2.x, 0, hw.y - p2.y)
				if to.length() < 2.0:
					break
				pl.rotation.y = atan2(-to.x, -to.z)
				pl.set("frozen", false)
				pl.set("move_mode", "script")
				pl.set("script_velocity", to.normalized() * 3.2)
				if t - son_t > 1.5:
					var d := p2.distance_to(son)
					yur += d
					if d < 0.8:
						stuck += 1
						pl.velocity.y = 3.6
						var rr := IstGeo.real(pl.global_position.x, pl.global_position.z)
						print("GEZI_OLAY tak %.0f %.0f (%s) yon=%.0f engel=%s" % [rr.x, rr.y, ad, fposmod(rad_to_deg(atan2(to.x, -to.z)), 360.0), _engel(to)])
						tak += 1
						olay += 1
						if shot and out != "" and olay <= 40:
							await _kare("olay_%s_%02d" % [ad, olay])
						if stuck >= 3:
							# 6 m ileri koy (oyuncunun gerçekten çıkamadığı yer)
							var nd := to.normalized() * 6.0
							pl.global_position += Vector3(nd.x, 1.0, nd.z)
							stuck = 0
					else:
						stuck = 0
					son = p2
					son_t = t
				if pl.global_position.y < IstGeo.h(pl.global_position.x, pl.global_position.z) - 2.0 and not IstGeo.su(pl.global_position.x, pl.global_position.z):
					dus += 1
					olay += 1
					var rd := IstGeo.real(pl.global_position.x, pl.global_position.z)
					print("GEZI_OLAY dus %.0f %.0f (%s)" % [rd.x, rd.y, ad])
					pl.global_position.y = IstGeo.h(pl.global_position.x, pl.global_position.z) + 1.0
				if IstGeo.su(pl.global_position.x, pl.global_position.z):
					olay += 1
					var rs := IstGeo.real(pl.global_position.x, pl.global_position.z)
					print("GEZI_OLAY su %.0f %.0f (%s)" % [rs.x, rs.y, ad])
					pl.global_position = _iyi
					pl.velocity = Vector3.ZERO
		pl.set("script_velocity", Vector3.ZERO)
		tum += uz
		print("GEZI_ROTA %s uzunluk=%.0f yurunen=%.0f tak=%d dus=%d" % [ad, uz, yur, tak, dus])
	print("GEZI_TOPLAM km=%.2f olay=%d" % [tum / 1000.0, olay])
	get_tree().quit(0)


func _kare(ad: String) -> void:
	cam.global_position = pl.global_position + Vector3(0, 1.7, 0)
	cam.rotation = Vector3(0, pl.rotation.y, 0)
	cam.make_current()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out + "/" + ad + ".png")


## Yürüme yönünde 0,3 / 1,0 / 1,7 m yükseklikten 1,2 m ışın: çarpılan düğümün ata zinciri (kaynak bulmak için).
func _engel(to: Vector3) -> String:
	var sp := get_world_3d().direct_space_state
	var fw := to.normalized()
	var r := []
	for hh: float in [0.3, 1.0, 1.7]:
		var rq := PhysicsRayQueryParameters3D.create(pl.global_position + Vector3(0, hh, 0), pl.global_position + Vector3(0, hh, 0) + fw * 1.2)
		rq.exclude = [pl.get_rid()]
		var h := sp.intersect_ray(rq)
		if h.is_empty():
			r.append("-")
		else:
			var c := h["collider"] as Node
			var z := String(c.name)
			var q := c.get_parent()
			var n := 0
			while q != null and n < 4:
				z += "<" + String(q.name)
				q = q.get_parent()
				n += 1
			r.append(z)
	return "|".join(r)
