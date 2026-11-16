extends Node
## esya_bolum.tscn'in kalıcı sondası (kök altında; sahne değişince yaşar). Açıklama esya_bolum.gd'de.

var dir := ""
var bekle := 10.0
var sec := 0
var yer := Vector2.INF
var olc := false
var donma := false
var olc_n := 240
var cam: Camera3D
var _kam_xf := Transform3D.IDENTITY


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"kare": dir = kv[1]
			"bekle": bekle = float(kv[1])
			"sec": sec = int(kv[1])
			"yer":
				var p := kv[1].split(",")
				yer = Vector2(float(p[0]), float(p[1]))
			"olc": olc = true
			"olc_n": olc_n = int(kv[1])
			"donma": donma = true
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
	_kos.call_deferred()


func _sahne() -> Node:
	return get_tree().current_scene


func _oyuncu() -> Player:
	return get_tree().get_first_node_in_group("player") as Player


func _bekle(sn: float) -> void:
	var t := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t < int(sn * 1000.0):
		await get_tree().process_frame


func _kos() -> void:
	# bölüm sahnesi ve oyuncu
	var t := 0.0
	while t < 90.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		var sc := _sahne()
		if sc and String(sc.name).begins_with("Chapter") and _oyuncu() != null:
			break
	print("ESYABOLUM sahne=%s" % (_sahne().name if _sahne() else "yok"))
	if donma:
		await _donma()
		get_tree().quit(0)
		return
	await _bekle(bekle)
	if olc:
		await _olc()
		get_tree().quit(0)
		return
	await _tekme_dizisi()
	get_tree().quit(0)


# ---------------------------------------------------------------- Bölüm 0: patlamanın donmuş karesi

func _donma() -> void:
	var sc := _sahne()
	var t := 0.0
	while t < 120.0 and not bool(sc.get("froze")):
		await get_tree().process_frame
		t += get_process_delta_time()
	await _bekle(0.9)
	await _kaydet("bolum0_savrulanlar_donma", "Bölüm 0 donma karesi: savrulan kalkan ve ok demeti zaman durdurmasında kasıtlı olarak havada (dünya duruyor, sonra geri sarılıyor)")
	var ef := EsyaFizik.ben()
	print("ESYABOLUM donma froze=%s esya_kayit=%d uyanik=%d" % [sc.get("froze"), ef.items.size() if ef else 0, ef.uyanik.size() if ef else 0])


# ---------------------------------------------------------------- tekme dizisi

func _aday() -> Dictionary:
	var ef := EsyaFizik.ben()
	var pl := _oyuncu()
	if ef == null or pl == null:
		return {}
	var adaylar: Array = []
	var space := pl.get_world_3d().direct_space_state
	print("ESYABOLUM oyuncu=%s" % str(pl.global_position))
	for e in ef.items:
		if OS.has_environment("ESYA_LISTE"):
			print("ESYABOLUM esya tur=%s at=%s yon=%s" % [e["tur"], str(ef._merkez(e)), str(_acik_yon(space, e))])
		if e["durum"] != "uyur" or (e["ab"] as AABB).size.y > 1.6:
			continue
		var c: Vector3 = ef._merkez(e)
		var ref := Vector2(pl.global_position.x, pl.global_position.z) if yer == Vector2.INF else yer
		var d := Vector2(c.x - ref.x, c.z - ref.y).length()
		if d > 70.0 or not ef._ustu_bos(e):
			continue
		var yon := _acik_yon(space, e)
		if yon == Vector3.ZERO:
			continue
		adaylar.append([d, e, yon])
	adaylar.sort_custom(func(a, b): return a[0] < b[0])
	print("ESYABOLUM aday=%d kayit=%d" % [adaylar.size(), ef.items.size()])
	if adaylar.is_empty():
		return {}
	var a: Array = adaylar[mini(sec, adaylar.size() - 1)]
	return {"e": a[1], "yon": a[2]}


## Eşyanın çevresinde oyuncunun duracağı ve eşyanın gideceği açık yön (zemin aynı yükseklikte, önü boş)
func _acik_yon(space: PhysicsDirectSpaceState3D, e: Dictionary) -> Vector3:
	var ef := EsyaFizik.ben()
	var c: Vector3 = ef._merkez(e)
	var alt := c.y - (e["ab"] as AABB).size.y * 0.5
	var r: float = ef._yaricap(e)
	var en := Vector3.ZERO
	var en_puan := -1.0
	for k in 16:
		var yon := Vector3(cos(k * TAU / 16.0), 0, sin(k * TAU / 16.0))
		var puan := 0.0
		var ok := true
		# oyuncunun duracağı yer (eşyanın arkası: -yon) ve eşyanın gideceği yer (+yon, 3 m)
		for s: float in [-0.95 - r, 0.7 + r]:
			var p := Vector3(c.x, alt + 1.2, c.z) + yon * s
			var q := PhysicsRayQueryParameters3D.create(p, p + Vector3.DOWN * 2.5)
			var h := space.intersect_ray(q)
			if OS.has_environment("ESYA_YON") and k == 0:
				print("ESYABOLUM yon_dbg c=%s s=%.2f hit=%s alt=%.2f" % [str(c), s, str(h.get("position", "yok")), alt])
			if h.is_empty() or absf((h["position"] as Vector3).y - alt) > 0.25:
				ok = false
				break
			puan += 1.0
		if not ok:
			continue
		# yatay engel yok (eşyanın yüksekliğinde): önü (gideceği yer) ve arkası (oyuncunun yeri), kendi yüzünden başlayarak
		var bos := true
		for sg: float in [1.0, -1.0]:
			var a := Vector3(c.x, alt + 0.45, c.z) + yon * sg * (r + 0.06)
			var b := Vector3(c.x, alt + 0.45, c.z) + yon * sg * (r + (1.0 if sg > 0.0 else 1.0))
			if not space.intersect_ray(PhysicsRayQueryParameters3D.create(a, b)).is_empty():
				bos = false
		if not bos:
			continue
		if puan > en_puan:
			en_puan = puan
			en = yon
	return en


func _tekme_dizisi() -> void:
	var sec_ := _aday()
	if sec_.is_empty():
		print("ESYABOLUM HATA aday yok")
		return
	var ef := EsyaFizik.ben()
	var pl := _oyuncu()
	var e: Dictionary = sec_["e"]
	var yon: Vector3 = sec_["yon"]
	var c: Vector3 = ef._merkez(e)
	var r: float = ef._yaricap(e)
	var alt := c.y - (e["ab"] as AABB).size.y * 0.5
	print("ESYABOLUM secilen tur=%s at=(%.1f,%.1f,%.1f) yon=(%.2f,%.2f)" % [e["tur"], c.x, c.y, c.z, yon.x, yon.z])
	# oyuncu eşyanın arkasında, ona bakar
	var pp := Vector3(c.x, alt + 0.05, c.z) - yon * (r + 0.95)
	pl.global_position = pp
	pl.velocity = Vector3.ZERO
	pl.face(c)
	# üçüncü kişi kamera: yandan, biraz geriden, yukarıdan
	var yan := yon.cross(Vector3.UP).normalized()
	cam = Camera3D.new()
	cam.fov = 60.0
	cam.far = 3000.0
	_sahne().add_child(cam)
	# kamera: birkaç açıdan, eşyaya (ve gideceği yere) görüşü en açık olanı (bir şeyin içine düşmesin)
	var space := pl.get_world_3d().direct_space_state
	var kp := c + yan * 3.4 - yon * 1.2 + Vector3.UP * 1.7
	var en_acik := -1.0
	for aci: float in [0.0, 0.5, -0.5, 1.0, -1.0, PI, 1.6, -1.6]:
		for uz: float in [3.6, 2.8]:
			var d := yan.rotated(Vector3.UP, aci)
			var aday := c + d * uz - yon * 0.6 + Vector3.UP * 1.6
			var acik := 0.0
			for hedef in [c + Vector3.UP * 0.3, c + yon * 1.2 + Vector3.UP * 0.3]:
				var hq := PhysicsRayQueryParameters3D.create(aday, hedef)
				var h := space.intersect_ray(hq)
				acik += 1.0 if h.is_empty() or (h["position"] as Vector3).distance_to(hedef) < 0.5 else 0.0
			# kameranın yeri boş mu (küçük küre)
			var sq := PhysicsShapeQueryParameters3D.new()
			var sp := SphereShape3D.new()
			sp.radius = 0.4
			sq.shape = sp
			sq.transform = Transform3D(Basis(), aday)
			if not space.intersect_shape(sq, 1).is_empty():
				continue
			acik += uz * 0.1
			if acik > en_acik:
				en_acik = acik
				kp = aday
	cam.look_at_from_position(kp, c + yon * 0.8, Vector3.UP)
	_kam_xf = cam.global_transform
	for i in 6:
		pl.global_position = pp
		pl.face(c)
		await get_tree().physics_frame
	await _kaydet("1_once", _cumle(e))
	var c0 := c
	pl.kick(c, 0.75, func() -> void: pass)
	var t := 0.0
	while e["durum"] == "uyur" and t < 2.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
	if e["durum"] == "uyur":
		print("ESYABOLUM HATA tekmede uyanmadı")
	await _bekle(0.3)
	await _kaydet("2_03sn", _cumle(e))
	await _bekle(0.7)
	await _kaydet("3_1sn", _cumle(e))
	t = 0.0
	while e["durum"] == "uyanik" and t < 12.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
	await _bekle(0.2)
	await _kaydet("4_durunca", _cumle(e))
	var g = e.get("govde")
	if g != null and is_instance_valid(g):
		var gp := (g as Node3D).global_position
		print("ESYABOLUM sonuc yol=%.2f dy=%.2f durum=%s denetim=%s" % [Vector2(gp.x - c0.x, gp.z - c0.z).length(), gp.y - c0.y, e["durum"], str(ef.sayac)])


func _cumle(e: Dictionary) -> String:
	var ef := EsyaFizik.ben()
	var g = e.get("govde")
	if g == null or not is_instance_valid(g):
		return "uyuyor (durağan dekor, %s)" % e["tur"]
	var rb := g as RigidBody3D
	var bos: float = ef._zemin_boslugu(rb)
	var dik := absf(rb.global_basis.y.normalized().y)
	var dur := ("hareket ediyor v=%.1f m/s" % rb.linear_velocity.length()) if e["durum"] == "uyanik" else "durdu ve dondu"
	var yon := "dik" if dik > 0.9 else ("yan yatık" if dik < 0.3 else "eğik")
	return "%s %s, %s, zemin boşluğu %.2f m%s" % [e["tur"], dur, yon, bos, " (HAVADA)" if bos > 0.06 and e["durum"] != "uyanik" else ""]


func _kaydet(ad: String, cumle: String) -> void:
	if cam and is_instance_valid(cam):
		cam.global_transform = _kam_xf
		cam.make_current()
	if dir == "":
		print("ESYABOLUM DURUM %s %s" % [ad, cumle])
		return
	# arayüz katmanları (bölüm başlığı, altyazı, HUD) yalnız kare için gizlenir: eşya görünsün
	var gizli: Array = []
	if not donma:
		for n in get_tree().root.find_children("*", "CanvasLayer", true, false):
			if (n as CanvasLayer).visible:
				(n as CanvasLayer).visible = false
				gizli.append(n)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	if cam and is_instance_valid(cam):
		cam.make_current()
	var img := get_viewport().get_texture().get_image()
	for n in gizli:
		if is_instance_valid(n):
			(n as CanvasLayer).visible = true
	if img.get_width() != 1280:
		img.resize(1280, 720)
	var f := dir.path_join("%s.jpg" % ad)
	img.save_jpg(f, 0.85)
	print("ESYABOLUM KARE %s %s" % [f.get_file(), cumle])


# ---------------------------------------------------------------- bütçe

func _olc() -> void:
	var ef := EsyaFizik.ben()
	var a := await _olc_pencere(olc_n)
	print("ESYABOLUM OLC dururken betik_ms=%.3f fizik_ms=%.3f cizim=%d kare_ms=%.2f esya=%d kapali=%s" % [a[0], a[1], a[2], a[3], ef.items.size() if ef else 0, EsyaFizik.KAPALI])
	if ef == null or EsyaFizik.KAPALI:
		return
	# tekme anı: tek eşya uyanır (darbe) — en kötü kare
	var sec_ := _aday()
	if not sec_.is_empty():
		var e: Dictionary = sec_["e"]
		var pl := _oyuncu()
		pl.global_position = ef._merkez(e) - (sec_["yon"] as Vector3) * 1.3
		pl.face(ef._merkez(e))
		EsyaFizik.darbe(pl, ef._merkez(e), 0.75)
		var b := await _olc_pencere(maxi(8, olc_n / 4))
		print("ESYABOLUM OLC tekme betik_ms=%.3f fizik_ms=%.3f cizim=%d kare_ms=%.2f en_kotu_kare_ms=%.2f" % [b[0], b[1], b[2], b[3], b[4]])
	# 12 gövde aynı anda uyanık: oyuncuya en yakın 12 uyuyan eşya
	var pl2 := _oyuncu()
	var uy: Array = []
	for e in ef.items:
		if e["durum"] == "uyur":
			uy.append([Vector2((ef._merkez(e) as Vector3).x - pl2.global_position.x, (ef._merkez(e) as Vector3).z - pl2.global_position.z).length(), e])
	uy.sort_custom(func(x, y): return x[0] < y[0])
	for i in mini(12, uy.size()):
		var e: Dictionary = uy[i][1]
		ef._uyandir(e)
		ef._itki(e, Vector3(randf_range(-1, 1), 0.6, randf_range(-1, 1)).normalized() * 40.0, Vector3(0, 0.2, 0))
	var c := await _olc_pencere(maxi(8, olc_n / 6))
	print("ESYABOLUM OLC 12uyanik=%d betik_ms=%.3f fizik_ms=%.3f cizim=%d kare_ms=%.2f en_kotu_kare_ms=%.2f" % [ef.uyanik.size(), c[0], c[1], c[2], c[3], c[4]])
	var t := 0.0
	while not ef.uyanik.is_empty() and t < 15.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	print("ESYABOLUM OLC donunca uyanik=%d denetim=%s" % [ef.uyanik.size(), str(ef.sayac)])


## n kare ortalaması: [betik ms (process), fizik ms, çizim çağrısı, kare ms, en kötü kare ms]
func _olc_pencere(n: int) -> Array:
	var sp := 0.0
	var sf := 0.0
	var dc := 0
	var sk := 0.0
	var en := 0.0
	var t0 := Time.get_ticks_usec()
	for i in n:
		await get_tree().process_frame
		var t1 := Time.get_ticks_usec()
		var k := (t1 - t0) / 1000.0
		t0 = t1
		sp += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		sf += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		dc += int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		sk += k
		en = maxf(en, k)
	return [sp / n, sf / n, dc / n, sk / n, en]
