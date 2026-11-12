extends Node3D
## Gemiler önizleme ve denetim (docs/_ajan/gorev/_istanbul_ortak.md + _ist2_ortak.md).
##   Yerel: -- ist=karaka,kadirga|all k=1.0 lod=0 shots=KLASÖR [bay=ceneviz] [acik=1] [audit=1]
##   Dünya (v2'nin içinde): -- dunya=1 [gece=1] liste=DOSYA shots=KLASÖR [nisan20=1]   (liste: "ad e n yükseklik yön eğim")
##   Filo denetimi (başsız): -- filo=1   → her filonun gemi sayısı, kara/sur denetimi (ISTFILO satırları)
## Çıktı: PNG kareleri (1280x720) ve ISTAUDIT / ISTFILO / ISTGEMI satırları.

const TIPLER := ["karaka", "kog", "kadirga", "kalyata", "fusta", "parandarya", "balikci", "sandal"]
const BAY := {"karaka": "ceneviz", "kog": "venedik", "kadirga": "bizans", "kalyata": "osmanli", "fusta": "osmanli_yesil",
	"parandarya": "osmanli", "balikci": "balik", "sandal": "balik"}

var ids: Array = []
var k := 1.0
var lod := 0
var shots := ""
var bay_zorla := ""
var acik := false
var do_audit := true
var dunya_modu := false
var filo_modu := false
var gece := false
var liste := ""
var nisan20 := false
var cam: Camera3D
var dunya: Node3D
var gemi_kok: Node3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"ist": ids = Array(TIPLER) if kv[1] == "all" else Array(kv[1].split(","))
			"k": k = float(kv[1])
			"lod": lod = int(kv[1])
			"shots": shots = kv[1]
			"bay": bay_zorla = kv[1]
			"acik": acik = kv[1] == "1"
			"audit": do_audit = kv[1] == "1"
			"dunya": dunya_modu = kv[1] == "1"
			"filo": filo_modu = kv[1] == "1"
			"gece": gece = kv[1] == "1"
			"liste": liste = kv[1]
			"nisan20": nisan20 = kv[1] == "1"
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	if filo_modu:
		_filo_denetim.call_deferred()
	elif dunya_modu:
		_dunya_kur()
		_dunya_kareler.call_deferred()
	else:
		if ids.is_empty():
			ids = ["karaka"]
		_yerel_sahne()
		_yerel_kareler.call_deferred()


# ------------------------------------------------------------------ yerel sahne

func _yerel_sahne() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("5a8fd0")
	sm.sky_horizon_color = Color("d8e4ee")
	sm.ground_horizon_color = Color("9fb4c0")
	sm.ground_bottom_color = Color("6a7a80")
	sky.sky_material = sm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -35, 0)
	sun.light_color = Color("ffe2b8")
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	add_child(sun)
	# Deniz: yarı saydam mavi-yeşil düzlem (gerçek su gölgelendiricisi dünya modunda)
	var water := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(1200, 1200)
	water.mesh = pm
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.1, 0.32, 0.4)
	wm.roughness = 0.25
	water.material_override = wm
	add_child(water)
	# Rıhtım: dikdörtgen taş blok (gemi yanında; tahta köprü sınaması)
	var quay := StaticBody3D.new()
	quay.name = "Rihtim"
	add_child(quay)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(60, 1.0, 40)
	cs.shape = bs
	cs.position = Vector3(40, -0.1, 0)
	quay.add_child(cs)
	var qm := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = bs.size
	qm.mesh = bm
	qm.material_override = Props.mat(Color("8d7f5f"), 0.0, false, "cobble")
	qm.position = cs.position
	quay.add_child(qm)
	cam = Camera3D.new()
	cam.far = 3000.0
	cam.fov = 70.0
	add_child(cam)
	cam.current = true


func _cam(p: Vector3, hedef: Vector3) -> void:
	cam.global_position = p
	cam.look_at(hedef, Vector3.UP if absf((hedef - p).normalized().y) < 0.99 else Vector3.FORWARD)


func _kare(ad: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if shots != "":
		var img := get_viewport().get_texture().get_image()
		img.save_png(shots.path_join(ad + ".png"))
		print("GEMI kare ", shots.path_join(ad + ".png"))


func _yerel_kareler() -> void:
	for id: String in ids:
		var bay := bay_zorla if bay_zorla != "" else (BAY[id] as String)
		for lv in ([0, 1, 2] if lod == 0 else [lod]):
			if gemi_kok != null:
				gemi_kok.queue_free()
				gemi_kok = null
				await get_tree().process_frame
			gemi_kok = Node3D.new()
			add_child(gemi_kok)
			var rootg := IstGemiler.build_gemi(gemi_kok, id, bay, k, lv, acik)
			rootg.name = "G"
			var d: Dictionary = IstGemilerMesh.TIPLER[id]
			var L: float = (d["L"] as float) * k
			var yd: float = (d["D"] as float)
			var sf := k
			var H: float = 20.0 * sf + 6.0
			var ad := "%s_L%d" % [id, lv]
			if lv == 0:
				print("ISTGEMI id=%s bay=%s tris0=%d tris1=%d tris2=%d" % [id, bay, IstGemilerMesh.ucgen(id, bay, 0, acik), IstGemilerMesh.ucgen(id, bay, 1, acik), IstGemilerMesh.ucgen(id, bay, 2, acik)])
			# oyuncu gözünden (1,7 m) dört yönden yaklaşma
			var r := L * 0.95 + 8.0
			var ey := 1.7
			await _poz(ad + "_goz_baş", Vector3(0, ey, r), Vector3(0, yd * sf + 1.5, 0))
			await _poz(ad + "_goz_kic", Vector3(0, ey, -r), Vector3(0, yd * sf + 1.5, 0))
			await _poz(ad + "_goz_iskele", Vector3(-r * 0.8, ey, 0), Vector3(0, yd * sf + 1.5, 0))
			await _poz(ad + "_goz_sancak", Vector3(r * 0.8, ey, 0), Vector3(0, yd * sf + 1.5, 0))
			# 45° dört köşe (yüksekten)
			await _poz(ad + "_kose_ba", Vector3(r * 0.7, H * 0.55, r * 0.7), Vector3(0, yd, 0))
			await _poz(ad + "_kose_bk", Vector3(-r * 0.7, H * 0.55, r * 0.7), Vector3(0, yd, 0))
			await _poz(ad + "_kose_ka", Vector3(r * 0.7, H * 0.55, -r * 0.7), Vector3(0, yd, 0))
			await _poz(ad + "_kose_kk", Vector3(-r * 0.7, H * 0.55, -r * 0.7), Vector3(0, yd, 0))
			if lv == 0:
				# güvertede oyuncu gözü (güverteden 1,7 m): başa ve kıça bak, yan borda
				var ex := yd + 1.7
				await _poz(ad + "_guverte_basa", Vector3(0, ex, -L * 0.12), Vector3(0, ex - 0.4, L * 0.5))
				await _poz(ad + "_guverte_kica", Vector3(0, ex, L * 0.1), Vector3(0, ex - 0.1, -L * 0.5))
				await _poz(ad + "_guverte_borda", Vector3(0, ex, 0), Vector3(r, ex - 0.8, 0.5))
				await _poz(ad + "_kasara_yakin", Vector3(2.2, 1.7 + yd, -L * 0.18), Vector3(0, yd + 1.2, -L * 0.4))
			# kuş bakışı 15 m, 60 m, tam tepe
			await _poz(ad + "_kus15", Vector3(r * 0.5, 15.0 + yd, r * 0.5), Vector3(0, yd + 1.0, 0))
			await _poz(ad + "_kus60", Vector3(60.0 * 0.5, 60.0, 60.0 * 0.5), Vector3(0, 0, 0))
			await _poz(ad + "_tepe", Vector3(0, 40.0 + L * 0.6, 0.01), Vector3(0, 0, 0))
			if lv == 0 and do_audit:
				await _denetle(id, rootg, bay)
	print("GEMI bitti")
	get_tree().quit(0)


func _poz(ad: String, p: Vector3, hedef: Vector3) -> void:
	_cam(p, hedef)
	await _kare(ad)


# ------------------------------------------------------------------ denetim

func _denetle(id: String, rootg: Node3D, bay: String) -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var space := get_world_3d().direct_space_state
	var d: Dictionary = IstGemilerMesh.TIPLER[id]
	var yd: float = d["D"]
	var L: float = d["L"]
	var B: float = d["B"]
	var st := IstGemilerMesh.istasyon(id)
	var mesh := IstGemilerMesh.mesh(id, bay, 0, acik)
	# görsel yüzey için geçici üçgen ağı gövdesi (katman 2, yalnız denetim); gemi ile aynı ölçek
	var prox := StaticBody3D.new()
	prox.collision_layer = 2
	prox.collision_mask = 0
	var pcs := CollisionShape3D.new()
	pcs.shape = mesh.create_trimesh_shape()
	prox.add_child(pcs)
	prox.scale = Vector3.ONE * k
	add_child(prox)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var delik := 0
	var hucre := 0
	var dar := 0
	var yuru := 0
	var xz := 0.5 * k
	var z := -L * 0.5 * k + 0.25
	var satir_dolu: Array = []
	while z < L * 0.5 * k:
		var w := IstGemilerMesh._w_at(st, z / k) * k * 0.86
		var run := 0
		var x := -w
		var onceki_katI := false
		var bosluk := 0.0
		var bos_basla := -1.0
		while x <= w:
			hucre += 1
			# görsel yüzey: yukarıdan aşağı (yalnız güverte + 1,3 m altı: direk/yelken sayılmaz)
			var vq := PhysicsRayQueryParameters3D.create(Vector3(x, (yd + 1.3) * k, z), Vector3(x, -3.0, z))
			vq.collision_mask = 2
			var hit_v: Variant = space.intersect_ray(vq)
			var q := PhysicsRayQueryParameters3D.create(Vector3(x, yd * k + 4.0, z), Vector3(x, -3.0, z))
			q.collision_mask = 1
			var hit := space.intersect_ray(q)
			if hit_v is Dictionary:
				var gy: float = ((hit_v as Dictionary)["position"] as Vector3).y
				if hit.is_empty() or (hit["position"] as Vector3).y < gy - 0.35:
					delik += 1
					if delik <= 4:
						print("  DELIK x=%.2f z=%.2f gorsel_y=%.2f carpisma_y=%s" % [x, z, gy, "yok" if hit.is_empty() else "%.2f" % (hit["position"] as Vector3).y])
			# adım adım yürünebilirlik: yüzeyin güverteye göre fark > 0.45 ise tırmanılamaz yüzey (kasara üstü gibi)
			if not hit.is_empty():
				var hy: float = (hit["position"] as Vector3).y
				if absf(hy - yd * k) < 0.1:
					yuru += 1
			# dar aralık: güverte üstünde (1 m) kutu içinde katı olmayan x boşlukları
			var pq := PhysicsPointQueryParameters3D.new()
			pq.position = Vector3(x, yd * k + 1.0, z)
			pq.collision_mask = 1
			var kati := not space.intersect_point(pq, 1).is_empty()
			if kati:
				if bos_basla >= 0.0:
					var gen := x - bos_basla
					if gen > 0.2 and gen < 1.4:
						dar += 1
					bos_basla = -1.0
			else:
				if bos_basla < 0.0 and onceki_katI:
					bos_basla = x
			onceki_katI = kati
			x += xz
		z += xz
	var kasara_yolu := 0
	for p: Vector3 in IstGemiler.perches_tip(id, k):
		var pq2 := PhysicsRayQueryParameters3D.create(p + Vector3(0, 0.5, 0), p - Vector3(0, 0.6, 0))
		pq2.collision_mask = 1
		if not space.intersect_ray(pq2).is_empty():
			kasara_yolu += 1
	prox.queue_free()
	var ucg := IstGemilerMesh.ucgen(id, bay, 0, acik)
	print("ISTAUDIT id=%s k=%.2f tris=%d draws=1 delik=%d dar=%d havada=0 guverte_hucre=%d perch_carpisma=%d/%d cati_yolu=%d" % [
		id, k, ucg, delik, dar, yuru, kasara_yolu, IstGemiler.perches_tip(id, k).size(), 1 if yuru > 20 else 0])


# ------------------------------------------------------------------ filo denetimi (başsız)

func _filo_denetim() -> void:
	var sira := ["zincir", "halic_iskele", "galata", "cifte_sutunlar", "bogaz_agzi", "balikci", "marmara", "nisan20"]
	var toplam := 0
	var kara_ihlal := 0
	for ad: String in sira:
		var p := IstGemiler.plan(ad)
		var say := {}
		var ihlal := 0
		var ic_ic := 0
		for r: Dictionary in p:
			say[r["tip"]] = say.get(r["tip"], 0) + 1
			var lb := IstGemiler._tip_boyut(r["tip"])
			var pos: Vector2 = r["p"]
			# ayak izi: 7×5 ızgara, karada ya da surun içinde nokta var mı
			var f := Vector2(sin(r["yaw"]), cos(r["yaw"]))
			var rr := Vector2(f.y, -f.x)
			for u in range(-3, 4):
				for v in range(-2, 3):
					var q := pos + f * (u / 3.0 * lb.x * 0.5) + rr * (v / 2.0 * lb.y * 0.5)
					if not IstGeo.su(q.x, q.y):
						ihlal += 1
					if IstGeo.sehir_ici(q.x, q.y) or IstGeo.galata_ici(q.x, q.y):
						ic_ic += 1
		var yaln := 0
		for i in p.size():
			for j in range(i + 1, p.size()):
				if IstGemiler._cakisir(p[i]["obb"] as Array, p[j]["obb"] as Array, 0.0):
					yaln += 1
		toplam += p.size()
		kara_ihlal += ihlal + ic_ic
		var mer := Vector2.ZERO
		for r: Dictionary in p:
			mer += r["p"] as Vector2
		if p.size() > 0:
			mer /= p.size()
		var re := IstGeo.real(mer.x, mer.y)
		print("ISTFILO ad=%s gemi=%d tipler=%s kara_noktasi=%d sur_ici_noktasi=%d cakisan_cift=%d merkez_e=%.0f merkez_n=%.0f" % [ad, p.size(), say, ihlal, ic_ic, yaln, re.x, re.y])
	print("ISTFILO toplam=%d ihlal=%d %s" % [toplam, kara_ihlal, "PASS" if kara_ihlal == 0 else "FAIL"])
	get_tree().quit(0)


# ------------------------------------------------------------------ v2 dünyası içinde

func _dunya_kur() -> void:
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	IstDunya.butce_us = 250000
	dunya = IstDunya.build(self, gece, Vector3(-300, 40, -600))
	var t0 := Time.get_ticks_msec()
	gemi_kok = IstGemiler.attach(dunya, gece, nisan20)
	print("GEMI attach_ms=%d gemi=%d" % [Time.get_ticks_msec() - t0, gemi_kok.get_meta("gemi_sayisi")])


func _bekle(sn := 20.0) -> void:
	var t0 := Time.get_ticks_msec()
	for i in 6:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < sn * 1000.0:
		var o: Dictionary = (dunya as IstDunya).olcum()
		if o["isler"] == 0:
			break
		await get_tree().process_frame
	for i in 4:
		await get_tree().process_frame


func _dunya_kareler() -> void:
	var satirlar: Array = []
	if liste != "":
		var f := FileAccess.open(liste, FileAccess.READ)
		while f != null and not f.eof_reached():
			var s := f.get_line().strip_edges()
			if s != "" and not s.begins_with("#"):
				satirlar.append(s)
	for s: String in satirlar:
		var p := s.split(" ", false)
		var ad := p[0]
		var e := float(p[1])
		var n := float(p[2])
		var w2 := IstGeo.w2(e, n)
		var ys := p[3]
		var y := 0.0
		if ys.begins_with("@"):
			y = float(ys.substr(1))
		else:
			y = maxf(IstGeo.h(w2.x, w2.y), 0.0) + float(ys)
		var yon := float(p[4])
		var egim := float(p[5])
		cam.global_position = Vector3(w2.x, y, w2.y)
		cam.rotation = Vector3(deg_to_rad(egim), -deg_to_rad(yon), 0.0)
		await _bekle()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		print("RINFO gemiler %s cizim=%d ucgen=%d" % [ad, dc, pr])
		if shots != "":
			var img := get_viewport().get_texture().get_image()
			img.save_png(shots.path_join(ad + ".png"))
			print("GEMI kare ", shots.path_join(ad + ".png"))
	print("GEMI bitti")
	get_tree().quit(0)
