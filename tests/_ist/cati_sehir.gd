extends Node3D
## ÇATI ROTASI — Ayasofya–Yerebatan–Hipodrom mahallesinin çatı envanteri, üstten harita, kareler ve gerçek Player botu.
##   envanter + harita (başsız):  godot --headless --path . res://tests/_ist/cati_sehir.tscn -- --is=olc --out=KLASÖR
##   bot (başsız):                godot --headless --path . res://tests/_ist/cati_sehir.tscn -- --is=bot [--kip=acik]
##   kareler (pencereli, xvfb):   godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/cati_sehir.tscn
##                                 -- --is=kare --out=KLASÖR --on=ONCE|SONRA
## Satırlar: CATIEV … (ev başına) · CATIZON … · CATIBOT <rota> … · CATIBOT OZET … · CATIKARE ad cizim= ilkel= · CATIS BITTI
## Bot kuralları: hücre çarpışması YÜKLENDİKTEN sonra yürür (rota boyunca hücreler zorla kurulur, kurulmayan sayılır);
## düşme = ilk çatıdan sonra zemine (arazi + 1,0 m altı) basmak; takılma = 8 sn ilerleme yok; sıkışma = havada ve
## hızsız 0,6 sn ya da Player._unstick'in itmesi. yüklenmemiş hücreden düşme ayrı sayılır (yuksuz=).

var is_ := "olc"
var out := "user://cati"
var on_ := "ONCE"
var kip := "kapali"
var root: Node3D
var dunya: Node3D
var s: IstSehir
var cam: Camera3D
var pl: Player


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--is="):
			is_ = a.substr(5)
		elif a.begins_with("--out="):
			out = a.substr(6)
		elif a.begins_with("--on="):
			on_ = a.substr(5)
		elif a.begins_with("--kip="):
			kip = a.substr(6)
	DirAccess.make_dir_recursive_absolute(out)
	_kos.call_deferred()


func _kos() -> void:
	root = Node3D.new()
	root.name = "IstV2"
	add_child(root)
	cam = Camera3D.new()
	cam.far = 9000.0
	cam.fov = 62.0
	add_child(cam)
	cam.make_current()
	var z := IstCati.noktalar()
	var aw: Vector2 = z["ayasofya"]
	cam.global_position = Vector3(aw.x - 60, IstGeo.h(aw.x - 60, aw.y) + 2.0, aw.y + 40)
	var t0 := Time.get_ticks_msec()
	dunya = load("res://scripts/world/ist/dunya.gd").call("build", root, false, Vector3.ZERO)
	s = IstSehir.active
	print("CATIS kur_ms=%d" % (Time.get_ticks_msec() - t0))
	match is_:
		"olc":
			_olc()
		"bot":
			await _bot_hepsi()
		"kare":
			await _kareler()
		"dolu":
			await _dolu()
		"nokta":
			await _dolu(true)
		"merd":
			await _merd()
	print("CATIS BITTI")
	get_tree().quit(0)


## Hata ayıklama: bir evin yan merdiveninin çevresinde (evin yereli) çarpışma yüksekliği ızgarası
func _merd() -> void:
	var ad := "Ds3"
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--ev="):
			ad = a.substr(5)
	var e: Dictionary = IstCati.plan()["geo"][ad]
	var c: Vector2 = e["c"]
	var merkez := ""
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--merkez="):
			merkez = a.substr(9)
	cam.global_position = Vector3(c.x, IstGeo.h(c.x, c.y) + 2, c.y)
	for cc: Dictionary in s._cells0:
		var q: Vector3 = cc["c"]
		if Vector2(q.x - c.x, q.z - c.y).length() < 80:
			s._cell_up(cc)
	dunya.call("carpisma_yenile", Vector3(c.x, 0, c.y))
	for i in 8:
		await get_tree().physics_frame
	var sp := get_world_3d().direct_space_state
	if merkez != "":
		var f := merkez.split(",")
		var mc := Vector2(f[0].to_float(), f[1].to_float())
		var yy := float(e["ust"])
		var zz := mc.y - 3.0
		while zz <= mc.y + 3.0:
			var row := PackedStringArray()
			var xx := mc.x - 3.0
			while xx <= mc.x + 3.0:
				var hit := sp.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(xx, yy + 12, zz), Vector3(xx, yy - 8, zz)))
				row.append("%5.2f" % ((hit["position"] as Vector3).y - yy) if not hit.is_empty() else "  -  ")
				xx += 0.3
			print("CATIMERD z=%.1f %s" % [zz, " ".join(row)])
			zz += 0.3
		return
	var L: float = e["L"]
	var D: float = e["D"]
	var y0: float = e["y0"]
	print("CATIMERD %s L=%.1f D=%.1f y0=%.2f ust=%.2f" % [ad, L, D, y0, float(e["ust"])])
	var x := L * 0.5 - 0.6
	while x < L * 0.5 + 1.8:
		var row := PackedStringArray()
		var z := D * 0.5 + 1.2
		while z > -D * 0.5 - 0.4:
			var q := (e["c"] as Vector2) + (e["ux"] as Vector2) * x + (e["uz"] as Vector2) * z
			var hit := sp.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(q.x, y0 + 12, q.y), Vector3(q.x, y0 - 3, q.y)))
			row.append("%5.2f" % ((hit["position"] as Vector3).y - y0) if not hit.is_empty() else "  -  ")
			z -= 0.3
		print("CATIMERD x=%.2f %s" % [x, " ".join(row)])
		x += 0.2


# ---------------------------------------------------------------- doluluk (ışın taraması)

## Zondaki anıtlar yakın katmanda (çarpışmalı) kurulur, hücreler yüklenir; 1 m ızgarada yukarıdan ışın: zeminden
## 0,4 m'den yüksek çarpışma = dolu. Görüntü: yeşil boş zemin, gri→beyaz yapı yüksekliği (0–20 m), mavi oyun alanı kenarı.
func _dolu(nokta := false) -> void:
	var r := IstCati.zon()
	for it: Dictionary in s.items:
		var ip: Vector3 = it["pos"]
		if it.has("hat") or not r.grow(80).has_point(Vector2(ip.x, ip.z)) or it.get("tek", false):
			continue
		if it["have"][0] == null:
			s._build(it, 0)
	for c: Dictionary in s._cells0:
		var cc: Vector3 = c["c"]
		if r.grow(30).has_point(Vector2(cc.x, cc.z)):
			s._cell_up(c)
	for i in 8:
		await get_tree().physics_frame
	var sp := get_world_3d().direct_space_state
	if nokta:
		for a: String in OS.get_cmdline_user_args():
			if a.begins_with("--p="):
				for t: String in a.substr(4).split(";"):
					var f := t.split(",")
					var q := Vector2(f[0].to_float(), f[1].to_float())
					if f.size() > 2:
						var P := Vector2(-147.3, 120.4)
						var X := Vector2(0.819, 0.574)
						var Z := Vector2(-0.574, 0.819)
						q = P + X * f[1].to_float() + Z * f[2].to_float()
					var g := IstGeo.h(q.x, q.y)
					var hit := sp.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(q.x, g + 60.0, q.y), Vector3(q.x, g - 3.0, q.y)))
					var cn := "" if hit.is_empty() else str((hit["collider"] as Node).get_path()).substr(0, 140)
					print("CATINOKTA %s w=(%.1f,%.1f) zemin=%.2f dh=%.2f %s" % [t, q.x, q.y, g, -1.0 if hit.is_empty() else (hit["position"] as Vector3).y - g, cn])
		return
	var W := int(r.size.x)
	var Hh := int(r.size.y)
	var img := Image.create(W, Hh, false, Image.FORMAT_RGB8)
	for j in Hh:
		for i in W:
			var x := r.position.x + i + 0.5
			var z := r.position.y + j + 0.5
			var g := IstGeo.h(x, z)
			var hit := sp.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(x, g + 60.0, z), Vector3(x, g - 3.0, z)))
			var dh := -1.0 if hit.is_empty() else (hit["position"] as Vector3).y - g
			var col := Color("3e5a2e") if dh < 0.4 else Color.from_hsv(0.08, 0.3, clampf(0.35 + dh / 25.0, 0.35, 1.0))
			img.set_pixel(i, j, col)
	for a: Rect2 in s.oyun_alanlari():
		for i in W:
			for j in Hh:
				var p := r.position + Vector2(i, j)
				if a.has_point(p) and not a.grow(-1.0).has_point(p):
					img.set_pixel(i, j, Color("40a0e0"))
	img.resize(W * 4, Hh * 4, Image.INTERPOLATE_NEAREST)
	img.save_png(out.path_join("dolu_%s.png" % on_))
	print("CATIZON dolu %s %dx%d basi=(%.1f,%.1f)" % [out.path_join("dolu_%s.png" % on_), W, Hh, r.position.x, r.position.y])


# ---------------------------------------------------------------- envanter + harita

func _olc() -> void:
	var z := IstCati.noktalar()
	for k: String in z:
		var p: Vector2 = z[k]
		print("CATIZON %s (%.1f, %.1f) y=%.2f" % [k, p.x, p.y, IstGeo.h(p.x, p.y)])
	var evs := IstCati.evler(s.sokak.houses, IstCati.zon())
	var txt := PackedStringArray()
	txt.append("| # | sıra | tip | cephe×derinlik | çatı | saçak y (dünya) | sırt y | eğim° | komşu (sıra dışı) | aralık m | kot farkı m | çıkış |")
	txt.append("|---|---|---|---|---|---|---|---|---|---|---|---|")
	var say := {"ev": 0, "duz": 0, "teras": 0, "kiremit": 0, "mazgal": 0, "cikisli": 0}
	for e: Dictionary in evs:
		var kom := IstCati.en_yakin_komsu(e, evs)
		var cik := IstEvler.climbs(int(e["v"]), String(e["tip"]))
		var cikt: Array = []
		for c: Array in cik:
			cikt.append(String(c[2]))
		say["ev"] += 1
		say[String(e["cati"])] = int(say.get(String(e["cati"]), 0)) + 1
		if not cikt.is_empty():
			say["cikisli"] += 1
		var line := "| %d | %d | %s | %.0f×%.0f | %s | %.2f | %.2f | %.0f | %s | %s | %s | %s |" % [int(e["i"]), int(e["sira"]), e["tip"], e["L"], e["D"],
			e["cati"], e["saçak"], e["sirt"], e["egim"], str(kom.get("i", "-")), ("%.1f" % float(kom["ara"])) if kom.has("ara") else "-",
			("%.1f" % float(kom["dy"])) if kom.has("dy") else "-", ",".join(cikt) if not cikt.is_empty() else "yok"]
		txt.append(line)
		print("CATIEV " + line)
	var yol := IstCati.sokaklar(s.sokak.streets, IstCati.zon())
	for st: Dictionary in yol:
		var lp: Array = []
		for q: Vector2 in (st["pts"] as PackedVector2Array):
			var r := q - IstCati.HIP_P
			lp.append("(%.0f,%.0f|h%.1f,%.1f)" % [q.x, q.y, r.dot(IstCati.HIP_X), r.dot(IstCati.HIP_Z)])
		print("CATIYOL w=%.1f tur=%s %s" % [float(st["w"]), st["tur"], " ".join(lp)])
	print("CATIZON ozet %s sokak_sayisi=%d genislikler=%s" % [str(say), yol.size(), str(IstCati.genislik_ozet(yol))])
	var f := FileAccess.open(out.path_join("cati_envanter_%s.md" % on_), FileAccess.WRITE)
	f.store_string("# Çatı envanteri (%s)\n\nÖzet: %s\n\nSokak genişlikleri (m, adet): %s\n\n" % [on_, str(say), str(IstCati.genislik_ozet(yol))])
	f.store_string("\n".join(txt) + "\n")
	f.close()
	_harita(evs, yol)


## Üstten harita: evler çatı türüne göre renkli (düz/teras açık, kiremit kızıl), sokaklar gri, rota çizgileri, A/B noktaları
func _harita(evs: Array, yol: Array) -> void:
	var r := IstCati.zon()
	var W := 1280
	var Hh := int(W * r.size.y / r.size.x)
	var img := Image.create(W, Hh, false, Image.FORMAT_RGB8)
	img.fill(Color("3e4a32"))
	var sc := W / r.size.x
	var px := func(p: Vector2) -> Vector2: return (p - r.position) * sc
	for st: Dictionary in yol:
		var pts: PackedVector2Array = st["pts"]
		for i in pts.size() - 1:
			_cizgi(img, px.call(pts[i]), px.call(pts[i + 1]), float(st["w"]) * sc, Color("a49a86"))
	for it: Dictionary in s.items:
		var ip: Vector3 = it["pos"]
		if it.has("hat") or not r.grow(60).has_point(Vector2(ip.x, ip.z)) or String(it["id"]).begins_with("doku_"):
			continue
		var cc: Vector2 = px.call(Vector2(ip.x, ip.z))
		var rr := float(it["r"]) * sc
		for k in 64:
			var a0 := TAU * k / 64.0
			var a1 := TAU * (k + 1) / 64.0
			_cizgi(img, cc + Vector2(cos(a0), sin(a0)) * rr, cc + Vector2(cos(a1), sin(a1)) * rr, 2.0, Color("c060c0"))
		print("CATIZON anit %s (%.1f, %.1f) r=%.1f yaw=%.1f k=%.3f" % [it["id"], ip.x, ip.z, float(it["r"]), rad_to_deg(float(it["yaw"])), float(it.get("k", 1.0))])
	for a: Rect2 in s.oyun_alanlari():
		var p0: Vector2 = px.call(a.position)
		var p1: Vector2 = px.call(a.end)
		for e2: Array in [[p0, Vector2(p1.x, p0.y)], [Vector2(p1.x, p0.y), p1], [p1, Vector2(p0.x, p1.y)], [Vector2(p0.x, p1.y), p0]]:
			_cizgi(img, e2[0], e2[1], 2.0, Color("40c0e0"))
	for e: Dictionary in evs:
		var col := Color("7a3a2c")
		match String(e["cati"]):
			"duz": col = Color("d8c79a")
			"teras": col = Color("e8e0b0")
			"mazgal": col = Color("b0a890")
		if e.get("rota", false):
			col = Color("f0d060")
		var pg: PackedVector2Array = e["poly"]
		var q := PackedVector2Array()
		for p: Vector2 in pg:
			q.append(px.call(p))
		_dolgu(img, q, col)
	for k: Array in IstCati.kopru_cizgileri():
		_cizgi(img, px.call(k[0]), px.call(k[1]), 3.0, Color("5a3a1a"))
	var z := IstCati.noktalar()
	for k: String in z:
		var p: Vector2 = px.call(z[k])
		_cizgi(img, p - Vector2(6, 6), p + Vector2(6, 6), 3.0, Color("2040e0"))
		_cizgi(img, p - Vector2(6, -6), p + Vector2(6, -6), 3.0, Color("2040e0"))
	for ro: Array in IstCati.rota_cizgileri():
		for i in ro.size() - 1:
			_cizgi(img, px.call(ro[i]), px.call(ro[i + 1]), 2.0, Color("e02020"))
	img.save_png(out.path_join("harita_%s.png" % on_))
	print("CATIZON harita %s" % out.path_join("harita_%s.png" % on_))


func _cizgi(img: Image, a: Vector2, b: Vector2, w: float, c: Color) -> void:
	var n := int(a.distance_to(b)) + 1
	var hw := maxi(1, int(w * 0.5))
	for i in n + 1:
		var p := a.lerp(b, float(i) / n)
		for dx in range(-hw, hw + 1):
			for dy in range(-hw, hw + 1):
				var x := int(p.x) + dx
				var y := int(p.y) + dy
				if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
					img.set_pixel(x, y, c)


func _dolgu(img: Image, q: PackedVector2Array, c: Color) -> void:
	var mn := q[0]
	var mx := q[0]
	for p in q:
		mn = mn.min(p)
		mx = mx.max(p)
	for y in range(maxi(0, int(mn.y)), mini(img.get_height(), int(mx.y) + 1)):
		for x in range(maxi(0, int(mn.x)), mini(img.get_width(), int(mx.x) + 1)):
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), q):
				img.set_pixel(x, y, c)
	for i in q.size():
		_cizgi(img, q[i], q[(i + 1) % q.size()], 1.0, c.darkened(0.5))


# ---------------------------------------------------------------- bot

var iz_kayit := OS.get_cmdline_user_args().has("--iz")
var ozet := {"rota": 0, "tamam": 0, "takilma": 0, "dusme": 0, "sikisma": 0, "yuksuz": 0}


func _bot_hepsi() -> void:
	pl = Player.new()
	root.get_parent().add_child(pl)
	pl.show_remote(false)
	pl.fall_guard = false
	if kip == "acik":
		pl.enable_climb()
	var rotalar := IstCati.rotalar(s.sokak.houses)
	var sec := ""
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--rota="):
			sec = a.substr(7)
	for ro: Dictionary in rotalar:
		if sec != "" and not String(ro["ad"]).begins_with(sec):
			continue
		await _bot(ro)
	print("CATIBOT OZET kip=%s rota=%d tamam=%d takilma=%d dusme=%d sikisma=%d yuksuz=%d" % [kip, ozet["rota"], ozet["tamam"],
		ozet["takilma"], ozet["dusme"], ozet["sikisma"], ozet["yuksuz"]])


## Rota çevresindeki 48 m hücreleri zorla kur (görsel + çarpışma); kurulamayan kalırsa sayar
func _hucre_hazir(wps: Array) -> int:
	var eksik := 0
	for c: Dictionary in s._cells0:
		var cc: Vector3 = c["c"]
		var yak := false
		for w: Vector3 in wps:
			if Vector2(cc.x - w.x, cc.z - w.z).length() < 70.0:
				yak = true
				break
		if not yak:
			continue
		if not c["up"]:
			s._cell_up(c)
		if c["col"] == null:
			s._cell_col(c)
		if c["col"] == null:
			eksik += 1
	for i in 4:
		await get_tree().physics_frame
	return eksik


func _hucre_yuklu(p: Vector3) -> bool:
	for c: Dictionary in s._cells0:
		var cc: Vector3 = c["c"]
		if absf(cc.x - p.x) <= IstSehir.CELL0 * 0.5 + 0.01 and absf(cc.z - p.z) <= IstSehir.CELL0 * 0.5 + 0.01:
			return c["col"] != null
	return true


func _bot(ro: Dictionary) -> void:
	var etiket := String(ro["ad"])
	var wps: Array = ro["wps"]
	var eksik: int = await _hucre_hazir(wps)
	var bas: Vector3 = ro["bas"]
	cam.global_position = bas + Vector3(0, 2, 0)
	# ışınlama sonrası arazi çarpışma yaması yenilenir (IstDunya.carpisma_yenile; oyundaki ışınlamalar da böyle yapar)
	dunya.call("carpisma_yenile", dunya.to_local(bas))
	pl.global_position = bas + Vector3(0, 0.3, 0)
	pl.velocity = Vector3.ZERO
	for i in 20:
		await get_tree().physics_frame
	Input.action_press("sprint")
	var t := 0.0
	var i := 0
	var iz := 0.0
	var best := 1e9
	var logs: Array = []
	var takil := 0
	var dus := 0
	var sik := 0
	var yuksuz := 0
	var catida := false
	var hava_dur := 0.0
	var limit := 40.0 + wps.size() * 12.0
	var zipla_bekle := 0.0
	while i < wps.size() and t < limit:
		var wp: Vector3 = wps[i]
		var p := pl.global_position
		pl.face(Vector3(wp.x, p.y + 1.4, wp.z))
		Input.action_press("move_forward")
		# zıplama kararı (oyuncu gibi): yerdeyken önde 0,7 m'de zemin yoksa ya da 1,3 m altındaysa (karşıda çatı varsa)
		# ya da önde diz hizasında engel varsa
		zipla_bekle = maxf(0.0, zipla_bekle - get_physics_process_delta_time())
		if pl.is_on_floor() and zipla_bekle <= 0.0 and _zipla_gerek(wp):
			Input.action_press("jump")
			zipla_bekle = 0.4
		await get_tree().physics_frame
		Input.action_release("jump")
		cam.global_position = pl.global_position + Vector3(0, 1.6, 0)
		if iz_kayit and Engine.get_physics_frames() % 5 == 0:
			print("CATIIZ wp%d p=(%.2f,%.2f,%.2f) v=(%.1f,%.1f,%.1f) yer=%s" % [i, pl.global_position.x, pl.global_position.y, pl.global_position.z, pl.velocity.x, pl.velocity.y, pl.velocity.z, pl.is_on_floor()])
		var dt := get_physics_process_delta_time()
		t += dt
		p = pl.global_position
		var yer := IstGeo.h(p.x, p.z)
		if i >= 1 and p.y > yer + 2.0:
			catida = true
		if catida and pl.is_on_floor() and p.y < yer + 1.0 and int(ro.get("son_cati", 1 << 20)) > i:
			dus += 1
			if not _hucre_yuklu(p):
				yuksuz += 1
			logs.append("DUSME wp%d (%.1f,%.1f,%.1f) zemin=%.1f yuklu=%s" % [i, p.x, p.y, p.z, yer, _hucre_yuklu(p)])
			break
		if not pl.is_on_floor() and pl.velocity.length() < 0.2:
			hava_dur += dt
			if hava_dur > 0.6:
				sik += 1
				logs.append("SIKISMA wp%d (%.1f,%.1f,%.1f)" % [i, p.x, p.y, p.z])
				break
		else:
			hava_dur = 0.0
		var dd := Vector2(p.x - wp.x, p.z - wp.z).length()
		if dd < best - 0.3:
			best = dd
			iz = t
		if dd < 0.9 and absf(p.y - wp.y) < 0.2:
			logs.append("wp%d t=%.1f y=%.2f" % [i, t, p.y])
			i += 1
			iz = t
			best = 1e9
		elif t - iz > 8.0:
			takil += 1
			logs.append("TAKILDI wp%d hedef(%.1f,%.1f,%.1f) at (%.1f,%.2f,%.1f) t=%.1f" % [i, wp.x, wp.y, wp.z, p.x, p.y, p.z, t])
			break
	Input.action_release("move_forward")
	Input.action_release("sprint")
	for k in 3:
		await get_tree().physics_frame
	var bitti := i >= wps.size()
	ozet["rota"] += 1
	ozet["takilma"] += takil + (0 if bitti or takil + dus + sik > 0 else 1)
	ozet["dusme"] += dus
	ozet["sikisma"] += sik
	ozet["yuksuz"] += yuksuz
	if bitti:
		ozet["tamam"] += 1
	print("CATIBOT %s kip=%s sure=%.1f wp=%d/%d takilma=%d dusme=%d sikisma=%d yuksuz=%d eksik_hucre=%d bitti=%s son=(%.1f,%.2f,%.1f) | %s" % [
		etiket, kip, t, i, wps.size(), takil, dus, sik, yuksuz, eksik, bitti, pl.global_position.x, pl.global_position.y, pl.global_position.z,
		" | ".join(logs)])


func _zipla_gerek(wp: Vector3) -> bool:
	var p := pl.global_position
	var fwd := Vector3(wp.x - p.x, 0, wp.z - p.z)
	if fwd.length() < 0.6:
		return false
	fwd = fwd.normalized()
	var sp := get_world_3d().direct_space_state
	var ex := [pl.get_rid()]
	var ahead := p + fwd * 0.7
	var q := PhysicsRayQueryParameters3D.create(ahead + Vector3.UP * 0.5, ahead + Vector3.DOWN * 1.3)
	q.exclude = ex
	var h := sp.intersect_ray(q)
	if h.is_empty() and wp.y > p.y - 4.0:
		return true                  # kenar: önde zemin yok (karşı çatıya atla)
	# Diz hizası engelde zıplanmaz: rotaların bütün basamakları ≤ 0,30 m (Player.step_up yürüyerek çıkar); dar merdivende
	# zıplamak oyuncuyu yana kaydırıyordu (ilk sürüm). Engel varsa bot takılır ve takılma olarak sayılır.
	return false


# ---------------------------------------------------------------- kareler

func _kareler() -> void:
	var kl: Array = IstCati.kameralar()
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--kam="):
			kl = []
			for t: String in a.substr(6).split(";"):
				var f := t.split(",")
				kl.append([f[0], Vector3(f[1].to_float(), f[2].to_float(), f[3].to_float()), Vector3(f[4].to_float(), f[5].to_float(), f[6].to_float())])
	var sec: Array = []
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--kamsec="):
			sec = Array(a.substr(9).split(","))
	for k: Array in kl:
		var ad := String(k[0])
		if not sec.is_empty() and not sec.has(ad):
			continue
		var at: Vector3 = k[1]
		var bak: Vector3 = k[2]
		cam.global_position = at
		cam.look_at(bak, Vector3.UP)
		for c: Dictionary in s._cells0:
			var cc: Vector3 = c["c"]
			if Vector2(cc.x - at.x, cc.z - at.z).length() < 120.0 and not c["up"]:
				s._cell_up(c)
		# belirlenimci bekleme: en az 90 kare ve akış kuyruğu (IstSehir._queue) 10 kare üst üste boş (en çok 400 kare);
		# yalnız sabit kare sayısı beklenince aynı kameranın çizim sayısı akış durumuna göre ±%20 oynuyordu
		var bos := 0
		for i in 400:
			await get_tree().process_frame
			bos = bos + 1 if s._queue.is_empty() else 0
			if i >= 90 and bos >= 10:
				break
		var img := get_viewport().get_texture().get_image()
		img.save_jpg(out.path_join("%s_%s.jpg" % [on_, ad]), 0.85)
		var rs := RenderingServer
		print("CATIKARE %s cizim=%d ilkel=%d" % [ad, rs.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			rs.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)])
