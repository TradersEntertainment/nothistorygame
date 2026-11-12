extends Node3D
## Marmara bölgesi gezi sondası (yalnız test): gerçek Player ile rota yürür, olay sayar.
##   godot --headless --path . res://tests/_ist/gezi_marmara.tscn -- rota=DOSYA
## rota dosyası satırı: "rotaadı doğu kuzey" (aynı ad = aynı rota, sırayla). Olaylar:
##   GEZI_OLAY <tür> <doğu> <kuzey> [ayrıntı]   tür: takildi | dusme | suya_girdi | yerden_yuksek
var dunya: IstDunya
var player: CharacterBody3D
var rotalar := {}
var sira: Array = []


func _ready() -> void:
	var dosya := ""
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2 and kv[0] == "rota":
			dosya = kv[1]
	var kimler := ""
	for a2: String in OS.get_cmdline_user_args():
		if a2.begins_with("--kim=") or a2.begins_with("kim="):
			kimler = a2.split("=", true, 1)[1]
	if kimler != "":
		_kim_say.call_deferred(kimler)
		dosya = "/dev/null"
	var f := FileAccess.open(dosya, FileAccess.READ)
	while f != null and not f.eof_reached():
		var p := f.get_line().strip_edges().split(" ", false)
		if p.size() < 3 or p[0].begins_with("#"):
			continue
		if not rotalar.has(p[0]):
			rotalar[p[0]] = []
			sira.append(p[0])
		rotalar[p[0]].append(Vector2(p[1].to_float(), p[2].to_float()))
	var cam := Camera3D.new()
	add_child(cam)
	cam.current = true
	var r0 := Vector2(-2000, -800)
	if kimler != "":
		sira.append("kim")
	else:
		r0 = rotalar[sira[0]][0]
	var w0 := IstGeo.w2(r0.x, r0.y)
	cam.global_position = Vector3(w0.x, 40, w0.y)
	dunya = IstDunya.build(self, false, cam.global_position) as IstDunya
	var P = load("res://scripts/player/player.gd")
	player = P.new()
	add_child(player)
	cam.current = false
	dunya.izle = player
	if kimler == "":
		_yuru.call_deferred()


func _yuru() -> void:
	IstDunya.butce_us = 20000
	var toplam := 0.0
	for ad: String in sira:
		var pts: Array = rotalar[ad]
		var w := IstGeo.w2(pts[0].x, pts[0].y)
		player.global_position = Vector3(w.x, IstGeo.h(w.x, w.y) + 0.6, w.y)
		dunya.carpisma_yenile(player.global_position)
		for i in 90:
			await get_tree().physics_frame
		var yol := 0.0
		var olay := {"takildi": 0, "dusme": 0, "suya_girdi": 0}
		for k in range(1, pts.size()):
			var hedef := IstGeo.w2(pts[k].x, pts[k].y)
			var t0 := _ms()
			var son := player.global_position
			var son_t := t0
			var su_ici := false
			while true:
				await get_tree().physics_frame
				var p := player.global_position
				var d := Vector2(hedef.x - p.x, hedef.y - p.z)
				if d.length() < 3.0:
					break
				player.rotation.y = atan2(-d.x, -d.y)
				Input.action_press("move_forward")
				yol += Vector2(p.x - son.x, p.z - son.z).length() if false else 0.0
				var now := _ms()
				if now - son_t > 3000:
					var ilerle := Vector2(p.x - son.x, p.z - son.z).length()
					yol += ilerle
					if ilerle < 1.0:
						olay["takildi"] += 1
						print("GEZI_OLAY takildi %.0f %.0f %s hedef=%d" % [_dogu(p), _kuzey(p), ad, k])
						# takılınca bir sonraki noktaya geç
						Input.action_release("move_forward")
						break
					son = p
					son_t = now
				var fark := p.y - IstGeo.h(p.x, p.z)
				if fark < -0.8 and not IstGeo.su(p.x, p.z):
					olay["dusme"] += 1
					print("GEZI_OLAY dusme %.0f %.0f %s fark=%.2f" % [_dogu(p), _kuzey(p), ad, fark])
				if IstGeo.su(p.x, p.z) and not su_ici:
					su_ici = true
					olay["suya_girdi"] += 1
					print("GEZI_OLAY suya_girdi %.0f %.0f %s" % [_dogu(p), _kuzey(p), ad])
				elif not IstGeo.su(p.x, p.z):
					su_ici = false
				if now - t0 > 90000:
					print("GEZI_OLAY zaman_asimi %.0f %.0f %s hedef=%d" % [_dogu(p), _kuzey(p), ad, k])
					break
			Input.action_release("move_forward")
		toplam += yol
		print("GEZI_ROTA %s yol=%.0f m takildi=%d dusme=%d suya_girdi=%d" % [ad, yol, olay["takildi"], olay["dusme"], olay["suya_girdi"]])
	print("GEZI_YURUYUS toplam=%.0f m" % toplam)
	get_tree().quit(0)


func _ms() -> int:
	return Engine.get_physics_frames() * 1000 / 60


func _dogu(p: Vector3) -> float:
	return IstGeo.real(p.x, p.z).x


func _kuzey(p: Vector3) -> float:
	return IstGeo.real(p.x, p.z).y


## kim=e,n,r;e,n,r… : noktaya (gerçek m) yakın MeshInstance3D düğümlerini adı + boyutuyla yazar (KIM satırı)
func _kim_say(spec: String) -> void:
	for i in 120:
		await get_tree().process_frame
	for q: String in spec.split(";"):
		var p := q.split(",")
		var w := IstGeo.w2(p[0].to_float(), p[1].to_float())
		var r := p[2].to_float() * IstGeo.S
		var liste2: Array = []
		var yigin: Array = [dunya]
		while not yigin.is_empty():
			var n: Node = yigin.pop_back()
			for c in n.get_children():
				yigin.append(c)
			if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
				var mi := n as MeshInstance3D
				var bb := mi.global_transform * mi.get_aabb()
				var c2 := bb.get_center()
				var d := Vector2(c2.x - w.x, c2.z - w.y).length()
				if d < r + bb.size.length() * 0.3 and bb.size.length() < 400.0:
					liste2.append([d, String(mi.get_path()).trim_prefix(str(dunya.get_path())), bb.size, mi.mesh.get_class(), c2.y])
		liste2.sort_custom(func(a, b): return a[0] < b[0])
		print("KIM nokta=%s r=%s adet=%d" % [p[0] + "," + p[1], p[2], liste2.size()])
		for k in mini(liste2.size(), 14):
			var e: Array = liste2[k]
			print("KIM   d=%.1f %s boyut=(%.1f,%.1f,%.1f) y=%.1f %s" % [e[0] / IstGeo.S, e[1], e[2].x, e[2].y, e[2].z, e[4], e[3]])
	get_tree().quit(0)
