extends Node3D
## orta-sirt gezi denetimi yardımcısı (yalnız test). Başsız: ızgara düğümlerinin su/mahalle türünü yazar.
##   godot --headless --path . res://tests/_ist/gezi_orta-sirt.tscn -- e0=-4000 e1=-1700 n0=800 n1=2350 adim=80 cikti=DOSYA

func _ready() -> void:
	var a := {"mod": "izgara", "rota": "", "girdi": "", "cikti2": "", "e0": "-4000", "e1": "-1700", "n0": "800", "n1": "2350", "adim": "80", "cikti": ""}
	for s: String in OS.get_cmdline_user_args():
		var kv := s.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2:
			a[kv[0]] = kv[1]
	if a["mod"] == "ac":
		_ac_basla.call_deferred(String(a["girdi"]), String(a["cikti"]))
		return
	if a["mod"] == "yuru":
		var rot: Array = []
		for r: String in String(a["rota"]).split("|", false):
			var ad_p := r.split(":", true, 1)
			var pts: Array = []
			for q: String in ad_p[1].split(";", false):
				var c := q.split(",")
				pts.append(Vector2(float(c[0]), float(c[1])))
			rot.append([ad_p[0], pts])
		_yuru_basla.call_deferred(rot)
		return
	var e0 := float(a["e0"]); var e1 := float(a["e1"]); var n0 := float(a["n0"]); var n1 := float(a["n1"])
	var st := float(a["adim"])
	var out := ""
	var turler := {}
	var e := e0
	while e <= e1:
		var n := n0
		while n <= n1:
			var w := IstGeo.w2(e, n)
			var su := IstGeo.su(w.x, w.y)
			var m := IstGeo.mahalle(w.x, w.y)
			var t := "%s/%s" % [m.get("tur", "?"), m.get("alt", "")]
			out += "%d %d %s %s %.1f %s\n" % [e, n, "SU" if su else "KARA", t, IstGeo.h(w.x, w.y), m.get("ad", "")]
			turler[t] = int(turler.get(t, 0)) + 1
			n += st
		e += st
	if a["cikti"] != "":
		var f := FileAccess.open(a["cikti"], FileAccess.WRITE)
		f.store_string(out)
	print("IZGARA turler=", turler)
	get_tree().quit(0)


## --- Gerçek oyuncuyla yürüyüş (mod=yuru; başsız çalışır) ------------------------------------------------------
## godot --headless --path . res://tests/_ist/gezi_orta-sirt.tscn -- mod=yuru rota=ad:e,n;e,n;...|ad2:...
## Her rota için Player ilk noktaya konur, sırayla noktalara yürür (sprint). Olaylar: GEZI_OLAY <tür> <doğu> <kuzey>
##   TAKILMA (3 sn'de < 0,6 dünya m ilerleme), DUSME (zemin − 0,5 m altı), SU (suya girdi), BOSLUK (havada > 1,5 sn).
var dunya: IstDunya
var player: CharacterBody3D

func _enter_tree() -> void:
	pass

func _yuru_basla(rotalar: Array) -> void:
	IstDunya.butce_us = 20000
	var cam := Camera3D.new()
	add_child(cam)
	var p0: Vector2 = rotalar[0][1][0]
	var w0 := IstGeo.w2(p0.x, p0.y)
	cam.global_position = Vector3(w0.x, IstGeo.h(w0.x, w0.y) + 3.0, w0.y)
	cam.current = true
	dunya = IstDunya.build(self, false, cam.global_position) as IstDunya
	var P = load("res://scripts/player/player.gd")
	player = P.new()
	add_child(player)
	dunya.izle = player
	cam.current = false
	var toplam := 0.0
	for r: Array in rotalar:
		toplam += await _rota(r[0], r[1])
	print("GEZI_YURU toplam_dunya_m=%.0f gercek_m=%.0f" % [toplam, toplam / IstGeo.S])
	get_tree().quit(0)

func _rota(ad: String, noktalar: Array) -> float:
	var w0 := IstGeo.w2(noktalar[0].x, noktalar[0].y)
	player.global_position = Vector3(w0.x, IstGeo.h(w0.x, w0.y) + 0.6, w0.y)
	player.velocity = Vector3.ZERO
	dunya.carpisma_yenile(player.global_position)
	for i in 45:
		await get_tree().physics_frame
	var yol := 0.0
	var olay := 0
	var bosluk := 0.0
	Input.action_press("move_forward")
	Input.action_press("sprint")
	var son := player.global_position
	var pencere_t := 0.0
	var pencere_p := player.global_position
	var bayrak := {}
	for k in range(1, noktalar.size()):
		var hw := IstGeo.w2(noktalar[k].x, noktalar[k].y)
		var guard := 0
		while guard < 2400:
			guard += 1
			await get_tree().physics_frame
			var p := player.global_position
			var d := Vector2(hw.x - p.x, hw.y - p.z)
			if d.length() < 1.5:
				break
			player.rotation.y = atan2(-d.x, -d.y)
			yol += Vector2(p.x - son.x, p.z - son.z).length()
			son = p
			var dt := 1.0 / float(Engine.physics_ticks_per_second)
			pencere_t += dt
			var re := IstGeo.real(p.x, p.z)
			if pencere_t >= 3.0:
				if Vector2(p.x - pencere_p.x, p.z - pencere_p.z).length() < 0.6 and d.length() > 2.0:
					print("GEZI_OLAY TAKILMA %.0f %.0f rota=%s nokta=%d hedefe=%.1f" % [re.x, re.y, ad, k, d.length()])
					olay += 1
					# kurtul: bir sonraki noktaya ışınla değil, 2 m yana it
					player.global_position += Vector3(-d.y, 0, d.x).normalized() * 1.5
				pencere_t = 0.0
				pencere_p = p
			var g := IstGeo.h(p.x, p.z)
			if not IstGeo.su(p.x, p.z) and p.y - g < -0.5 and not bayrak.has("dusme%d" % int(p.x / 5.0)):
				bayrak["dusme%d" % int(p.x / 5.0)] = true
				print("GEZI_OLAY DUSME %.0f %.0f rota=%s zemin_fark=%.2f" % [re.x, re.y, ad, p.y - g])
			if IstGeo.su(p.x, p.z):
				print("GEZI_OLAY SU %.0f %.0f rota=%s" % [re.x, re.y, ad])
				break
			if not player.is_on_floor():
				bosluk += dt
				if bosluk > 1.5 and p.y - g > 1.5:
					print("GEZI_OLAY BOSLUK %.0f %.0f rota=%s yuk=%.2f" % [re.x, re.y, ad, p.y - g])
					bosluk = 0.0
			else:
				bosluk = 0.0
		if guard >= 2400:
			var q := IstGeo.real(player.global_position.x, player.global_position.z)
			print("GEZI_OLAY ULASILAMADI %.0f %.0f rota=%s nokta=%d" % [q.x, q.y, ad, k])
			break
	Input.action_release("move_forward")
	Input.action_release("sprint")
	print("GEZI_ROTA %s yol_dunya_m=%.0f gercek_m=%.0f olay=%d" % [ad, yol, yol / IstGeo.S, olay])
	return yol


## --- Açık zemin bulucu (mod=ac; başsız): içeride kalan ızgara düğümlerini en yakın açık zemine kaydırır ------------
## godot --headless --path . res://tests/_ist/gezi_orta-sirt.tscn -- mod=ac girdi=DOSYA cikti=DOSYA
## girdi satırı: "ad e n yuk yon egim"; çıktı aynı biçim, e/n açık zemine kaydırılmış ("ad_k"), bulunamayanlar "YOK ad".
func _ac_basla(girdi: String, cikti: String) -> void:
	IstDunya.butce_us = 20000
	var cam := Camera3D.new()
	add_child(cam)
	cam.global_position = Vector3(0, 50, 0)
	var satirlar: Array = []
	for l in FileAccess.get_file_as_string(girdi).split("\n", false):
		var p := l.strip_edges().split(" ", false)
		if p.size() >= 6:
			satirlar.append(p)
	var w0 := IstGeo.w2(float(satirlar[0][1]), float(satirlar[0][2]))
	cam.global_position = Vector3(w0.x, IstGeo.h(w0.x, w0.y) + 3.0, w0.y)
	cam.current = true
	dunya = IstDunya.build(self, false, cam.global_position) as IstDunya
	var out := ""
	var bulundu := 0
	for p in satirlar:
		var e := float(p[1]); var n := float(p[2])
		var w := IstGeo.w2(e, n)
		dunya.izle = cam
		cam.global_position = Vector3(w.x, IstGeo.h(w.x, w.y) + 3.0, w.y)
		dunya.carpisma_yenile(cam.global_position)
		for i in 24:
			await get_tree().physics_frame
		var best := Vector2.INF
		var space := get_world_3d().direct_space_state
		for r in [0.0, 5.0, 10.0, 15.0, 20.0, 28.0]:
			var ok := false
			for a in (1 if r == 0.0 else 12):
				var th := TAU * a / 12.0
				var q := Vector2(e + r * sin(th), n + r * cos(th))
				var wq := IstGeo.w2(q.x, q.y)
				if IstGeo.su(wq.x, wq.y):
					continue
				var g := IstGeo.h(wq.x, wq.y)
				var from := Vector3(wq.x, g + 60.0, wq.y)
				var qy := PhysicsRayQueryParameters3D.create(from, Vector3(wq.x, g - 5.0, wq.y))
				var hit := space.intersect_ray(qy)
				if hit.is_empty() or absf(hit["position"].y - g) > 0.6:
					continue    # çatı/üst yüzey ya da çarpışma yok: açık zemin değil
				var tavan := PhysicsRayQueryParameters3D.create(Vector3(wq.x, g + 1.7, wq.y), Vector3(wq.x, g + 30.0, wq.y))
				if not space.intersect_ray(tavan).is_empty():
					continue    # üstü kapalı (bina içi)
				var temiz := true
				for d in 8:
					var ang := TAU * d / 8.0
					var hq := PhysicsRayQueryParameters3D.create(Vector3(wq.x, g + 1.7, wq.y),
						Vector3(wq.x + 3.0 * sin(ang), g + 1.7, wq.y + 3.0 * cos(ang)))
					if not space.intersect_ray(hq).is_empty():
						temiz = false
						break
				if temiz:
					best = q
					ok = true
					break
			if ok:
				break
		if best == Vector2.INF:
			out += "YOK %s %s %s\n" % [p[0], p[1], p[2]]
		else:
			bulundu += 1
			out += "%s_k %.0f %.0f %s %s %s\n" % [p[0], best.x, best.y, p[3], p[4], p[5]]
	FileAccess.open(cikti, FileAccess.WRITE).store_string(out)
	print("GEZI_AC bulundu=%d / %d" % [bulundu, satirlar.size()])
	get_tree().quit(0)
