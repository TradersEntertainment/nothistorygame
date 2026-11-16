extends Node3D
## DOKU-2 sondası (docs/_ajan/gorev/ist2_tur2.md "DOKU-2"): IstDunya ile v2'yi kurar, sabit bakışlardan kare alır ve
## mahalle dokusunu sayar.
##   godot --path . --resolution 1280x720 res://tests/_ist/doku2_kare.tscn -- shots=KLASÖR [on=ONEK] [sadece=ad,ad]
## Bakışlar gerçek koordinatla (doğu, kuzey m; S'den bağımsız). Yerden ve çatıdan karelerde nokta en yakın sokağa/evin
## çatısına oturtulur. Satırlar:
##   DOKU2 sayim …          ev, tip/kat dağılımı, sıra, sokak
##   DOKU2 aralik …         bitişik (0) / dar (0 < a < 1,4 m) / geçit sayıları (ev tabanları arasındaki en kısa uzaklık)
##   ISTBOS …               40 m'lik karelerde boş oranı (şehir içi), örnek boş kare koordinatları
##   RINFO doku2 <ad> …     çizim, üçgen

var shots := ""
var on := ""
var sadece: Array = []
var dunya: IstDunya
var cam: Camera3D

## ad, e, n, yükseklik ("@" mutlak), yön (pusula), eğim, kip ("" | "sokak" | "cati" | "sur")
const BAKIS := [
	["hava70", -1500.0, 250.0, "70", 125.0, -32.0, ""],
	["hava30", -1050.0, 420.0, "30", 140.0, -38.0, ""],
	["tepe", -2350.0, 450.0, "@2300", 0.0, -89.9, ""],
	["tepe_mahalle", -1450.0, 520.0, "260", 0.0, -89.9, ""],
	["tepe_batı", -3600.0, 600.0, "300", 0.0, -89.9, ""],
	["sokak", -1150.0, 330.0, "1.7", 0.0, -4.0, "sokak"],
	["sokak_bati", -3300.0, 400.0, "1.7", 0.0, -4.0, "sokak"],
	["cati", -950.0, 380.0, "1.7", 200.0, -12.0, "cati"],
	["sur_dibi30", -4300.0, 150.0, "30", 255.0, -26.0, ""],
	["sur_dibi_yer", -4400.0, 400.0, "1.7", 0.0, -3.0, "sur"],
]

## DOKU-3 (tur=3): yerden sokak kareleri (gece=1 ile gece) + havadan 30/70 m. "mese": en yakın Mese şeridi.
const BAKIS3 := [
	["y_carsi", -1100.0, 95.0, "1.7", 80.0, -3.0, "mese"],
	["y_sik", -1450.0, 520.0, "1.7", 0.0, -3.0, "sokak"],
	["y_sur_dibi", -4400.0, 400.0, "1.7", 0.0, -3.0, "sur"],
	["y_iskele", -700.0, 1040.0, "1.7", 205.0, -3.0, "sokak"],
	["y_galata", -560.0, 1700.0, "1.7", 0.0, -3.0, "sokak"],
	["y_bostan", -2250.0, -560.0, "1.7", 0.0, -3.0, "sokak"],
	["y_ayasofya", -470.0, -20.0, "1.7", 88.0, -4.0, ""],
	["h30_carsi", -1150.0, 60.0, "30", 80.0, -35.0, ""],
	["h70_mahalle", -1500.0, 250.0, "70", 125.0, -32.0, ""],
	["h70_ayasofya", -700.0, -150.0, "70", 60.0, -30.0, ""],
]
## DOKU-4 (tur=4): dört mahalle × dört yerden sokak karesi (çarşı/Mese, sık mahalle, sur dibi, bostan-seyrek) + havadan;
## gece=1 ile GECE listesi (Galata'dan, uçuştan, surdan, ordugâh ufku, sokak).
const BAKIS4 := [
	["y4_carsi_1", -1100.0, 95.0, "1.7", 80.0, -3.0, "mese"],
	["y4_carsi_2", -1500.0, 180.0, "1.7", 0.0, -3.0, "sokak"],
	["y4_carsi_3", -800.0, 60.0, "1.7", 0.0, -3.0, "sokak"],
	["y4_carsi_4", -1900.0, 120.0, "1.7", 260.0, -3.0, "mese"],
	["y4_sik_1", -1450.0, 520.0, "1.7", 0.0, -3.0, "sokak"],
	["y4_sik_2", -2000.0, 900.0, "1.7", 0.0, -3.0, "sokak"],
	["y4_sik_3", -1100.0, 700.0, "1.7", 0.0, -3.0, "sokak"],
	["y4_sik_4", -2600.0, 1300.0, "1.7", 0.0, -3.0, "sokak"],
	["y4_surdibi_1", -4400.0, 400.0, "1.7", 0.0, -3.0, "sur"],
	["y4_surdibi_2", -4250.0, 1300.0, "1.7", 0.0, -3.0, "sur"],
	["y4_surdibi_3", -4200.0, -500.0, "1.7", 0.0, -3.0, "sur"],
	["y4_surdibi_4", -3700.0, 2200.0, "1.7", 0.0, -3.0, "sur"],
	["y4_bostan_1", -2250.0, -560.0, "1.7", 0.0, -3.0, "sokak"],
	["y4_bostan_2", -3200.0, -700.0, "1.7", 0.0, -3.0, "sokak"],
	["y4_bostan_3", -2900.0, 300.0, "1.7", 0.0, -3.0, "sokak"],
	["y4_bostan_4", -3600.0, 1000.0, "1.7", 0.0, -3.0, "sokak"],
	["h4_hub_30", -4700.0, 850.0, "30", 100.0, -30.0, ""],
	["h4_carsi_30", -1150.0, 60.0, "30", 80.0, -35.0, ""],
	["h4_mahalle_70", -1500.0, 250.0, "70", 125.0, -32.0, ""],
	["h4_bati_70", -3600.0, 600.0, "70", 90.0, -30.0, ""],
	["h4_forum_konstantin", -1160.0, -400.0, "45", 0.0, -40.0, ""],
	["h4_forum_tauri", -1750.0, -450.0, "45", 0.0, -40.0, ""],
	["y4_cati_1", -2134.0, 40.0, "1.7", 200.0, -12.0, "cati"],
	["h4_cati_15", -2120.0, 20.0, "15", 330.0, -35.0, ""],
]
const BAKIS4_GECE := [
	["g4_galata_kule", -512.0, 1889.0, "60", 205.0, -14.0, ""],
	["g4_galata_yer", -560.0, 1700.0, "1.7", 200.0, 2.0, "sokak"],
	["g4_halic_100", -1200.0, 1500.0, "100", 200.0, -18.0, ""],
	["g4_ucus_sehir", -2600.0, 400.0, "120", 90.0, -22.0, ""],
	["g4_sur_ordugah", -4550.0, 700.0, "40", 270.0, -8.0, ""],
	["g4_kara_suru", -5100.0, 1100.0, "50", 150.0, -12.0, ""],
	["g4_mese_yer", -1100.0, 95.0, "1.7", 80.0, -3.0, "mese"],
	["g4_ayasofya_28", -470.0, -20.0, "28", 88.0, -10.0, ""],
]
var tur3 := false
var tur4 := false
var gece := false


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"shots": shots = kv[1]
			"on": on = kv[1]
			"sadece": sadece = Array(kv[1].split(","))
			"tur":
				tur3 = kv[1] == "3"
				tur4 = kv[1] == "4"
			"gece": gece = kv[1] == "1"
			"yakin": IstHayat.yakin_acik = kv[1] != "0"
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var w := IstGeo.w2(-1500.0, 250.0)
	cam.global_position = Vector3(w.x, 80.0, w.y)
	IstDunya.butce_us = 250000
	dunya = IstDunya.build(self, gece, cam.global_position) as IstDunya
	_kareler.call_deferred()


func _bekle(sn := 25.0) -> void:
	var t0 := Time.get_ticks_msec()
	for i in 6:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < sn * 1000.0:
		var o := dunya.olcum()
		if o["isler"] == 0 and IstMahalleDoku.bekleyen() == 0:
			break
		await get_tree().process_frame
	for i in 6:
		await get_tree().process_frame


func _kareler() -> void:
	await _bekle(40.0)
	_sayim()
	if OS.get_cmdline_user_args().has("oyuncu=1"):
		await _cati_sina()
	if OS.get_cmdline_user_args().has("cati2=1"):
		await _cati_cati()
		get_tree().quit(0)
		return
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	var liste: Array = BAKIS3 if tur3 else BAKIS
	if tur4:
		liste = BAKIS4_GECE if gece else BAKIS4
	for b: Array in liste:
		var ad: String = b[0]
		if not sadece.is_empty() and not ad in sadece:
			continue
		if not _kam(b):
			print("DOKU2 bakis_yok ", ad)
			continue
		await _bekle()
		if IstHayatYakin.aktif != null and is_instance_valid(IstHayatYakin.aktif):
			IstHayatYakin.aktif.doldur(8)
			for i in 40:
				await get_tree().process_frame
			print(IstHayatYakin.aktif.sayim_satiri(ad), " esyada=%d" % _esyada())
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		print("RINFO doku2 %s cizim=%d ucgen=%d konum=%s" % [ad, dc, pr, cam.global_position])
		print("DOKU2 dagilim %s %s" % [ad, _dagilim()])
		if shots != "":
			var img := get_viewport().get_texture().get_image()
			img.save_png(shots.path_join(on + ad + ".png"))
		if tur3 or tur4:
			await _katman_olc(ad, dc, pr)
	print("DOKU2 bitti")
	get_tree().quit(0)


## Katman payı: yakın kişiler (CityLife) ve sokak eşyası gizlenince çizim/üçgen ne kadar düşüyor
func _katman_olc(ad: String, dc0: int, pr0: int) -> void:
	var gizle: Array = []
	if IstHayatYakin.aktif != null and is_instance_valid(IstHayatYakin.aktif):
		gizle.append(["kisi", [IstHayatYakin.aktif]])
	var es: Array = []
	if IstMahalleDoku.aktif != null:
		for c in IstMahalleDoku.aktif.get_children():
			if String(c.name).begins_with("SokakEsya"):
				es.append(c)
	gizle.append(["esya", es])
	for g: Array in gizle:
		for n: Node3D in g[1]:
			n.visible = false
		for i in 3:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		print("RINFO katman %s %s cizim=%d ucgen=%d" % [ad, g[0], dc0 - dc, pr0 - pr])
		for n: Node3D in g[1]:
			n.visible = true


## Etkin yakın kişilerden sokak eşyasının (0,35 m) içinde duranlar
func _esyada() -> int:
	var d := IstMahalleDoku.aktif
	if d == null or d.sokak_esya == null:
		return -1
	var n := 0
	for ag in IstHayatYakin.aktif.active_list():
		var p: Vector3 = ag.pos
		if d.sokak_esya.esya_yakin(Vector2(p.x, p.z), 0.35):
			n += 1
	return n


func _kam(b: Array) -> bool:
	var w := IstGeo.w2(b[1], b[2])
	var ys: String = b[3]
	var yaw := -deg_to_rad(float(b[4]))
	var kip: String = b[6]
	var sk: IstSokak = IstSehir.sokak
	if kip == "sokak" or kip == "sur" or kip == "mese":
		if sk == null:
			return false
		var best := Vector2.INF
		var bd := INF
		var dir := Vector2.RIGHT
		for s: Dictionary in sk.streets:
			var t := String(s["tur"])
			if kip == "mese" and t != "mese":
				continue
			if kip == "sokak" and not t in ["sokak", "basamak"]:
				continue
			if kip == "sur" and t != "savunma":
				continue
			var pl: PackedVector2Array = s["pts"]
			for i in pl.size() - 1:
				# DOKU-3: sokak bakışında yalnız ≥ 22 m'lik düz parçalar, kamera parçanın başında (sokak boyunca görünsün)
				var q := Geometry2D.get_closest_point_to_segment(w, pl[i], pl[i + 1])
				var dv := (pl[i + 1] - pl[i]).normalized()
				if kip == "sokak":
					# i'den başlayan ≥ 22 m'lik neredeyse düz koşu (ara noktalar çizgiden ≤ 1,2 m)
					var j := i + 1
					var duz := 0.0
					while j < pl.size():
						var ok := true
						for m in range(i + 1, j):
							if Geometry2D.get_closest_point_to_segment(pl[m], pl[i], pl[j]).distance_to(pl[m]) > 1.2:
								ok = false
								break
						if not ok:
							break
						duz = pl[i].distance_to(pl[j])
						j += 1
					if duz < 22.0:
						continue
					dv = (pl[j - 1] - pl[i]).normalized()
					q = pl[i] + dv * 2.0
				if q.distance_to(w) < bd:
					bd = q.distance_to(w)
					best = q
					dir = dv
		if best == Vector2.INF:
			if kip == "sur":
				best = w
			else:
				return false
		w = best
		yaw = atan2(-dir.x, -dir.y)
	var y := maxf(IstGeo.h(w.x, w.y), 0.0) + ys.trim_prefix("@").to_float()
	if ys.begins_with("@"):
		y = ys.substr(1).to_float()
	if kip == "cati":
		if sk == null or sk.houses.is_empty():
			return false
		var bh: Dictionary = sk.houses[0]
		var bd := INF
		for h: Dictionary in sk.houses:
			var d := (h["c"] as Vector2).distance_to(w)
			if d < bd:
				bd = d
				bh = h
		var dm := IstEvler.dims(int(bh["v"]))
		var c: Vector2 = bh["c"]
		var fr: Vector2 = bh["on"]
		w = c
		y = IstGeo.h(fr.x, fr.y) + dm.y + IstEvler.RISE + 1.7
	cam.global_position = Vector3(w.x, y, w.y)
	cam.rotation = Vector3(deg_to_rad(float(b[5])), yaw, 0.0)
	return true


## Gerçek oyuncu (player.gd, CharacterBody3D) ile sokaktan dama: teras evlerin dış taş merdiveni, beş yerde.
## Satır: DOKU2 cati_sina ev=… baslangic=… hedef_y=… en_yuksek=… PASS|FAIL
func _cati_sina() -> void:
	var sk: IstSokak = IstSehir.sokak
	var list: Array = []
	for h: Dictionary in sk.houses:
		if String(h["tip"]) == "teras" and IstGeo.sehir_ici((h["c"] as Vector2).x, (h["c"] as Vector2).y):
			list.append(h)
	if list.is_empty():
		print("DOKU2 cati_sina teras yok")
		return
	var P = load("res://scripts/player/player.gd")
	var ok := 0
	for n in 5:
		var h: Dictionary = list[(n * 7919 + 13) % list.size()]
		var v := int(h["v"])
		var dm := IstEvler.dims(v)
		var fr: Vector2 = h["on"]
		var c: Vector2 = h["c"]
		var bas := Basis(Vector3.UP, float(h["yaw"]))
		var xf := Transform3D(bas, Vector3(c.x, IstGeo.h(fr.x, fr.y) - 0.04, c.y))
		var cl: Array = IstEvler.climbs(v, "teras")
		if cl.is_empty():
			continue
		var alt: Vector3 = xf * (cl[0][0] as Vector3)
		var ust: Vector3 = xf * (cl[0][1] as Vector3)
		cam.global_position = alt + Vector3(0, 30, 20)
		await _bekle(10.0)
		for i in 30:
			await get_tree().physics_frame
		var pl: CharacterBody3D = P.new()
		add_child(pl)
		var ileri: Vector3 = bas * Vector3(0, 0, -1)
		pl.global_position = Vector3(alt.x, maxf(alt.y, IstGeo.h(alt.x, alt.z)) + 0.3, alt.z) + bas * Vector3(-0.08, 0, 0.5)
		pl.rotation.y = atan2(-ileri.x, -ileri.z)
		dunya.izle = pl
		dunya.carpisma_yenile(pl.global_position)
		for i in 20:
			await get_tree().physics_frame
		var bas0 := pl.global_position
		Input.action_press("move_forward")
		var en := -INF
		for i in 900:
			Input.action_press("move_forward")          # odak kaybında eylemler bırakılıyor: her kare yeniden bas
			await get_tree().physics_frame
			en = maxf(en, pl.global_position.y)
			if n == 4 and i % 20 == 0 and i < 400:
				print("DOKU2 iz i=%d yerel=%s hiz=%s yerde=%s ladder=%s kip=%s pinned=%s frozen=%s mult=%s girdi=%s" % [i, (xf.affine_inverse() * pl.global_position).snapped(Vector3.ONE * 0.01), pl.velocity.snapped(Vector3.ONE * 0.01), pl.is_on_floor(), pl.get("ladder"), pl.get("move_mode"), pl.get("pinned"), pl.get("frozen"), pl.get("speed_mult"), [pl.get("_tp_hold"), pl.get("_void_frames"), pl.get("_stagger"), pl.get("is_down")]])
		var carp: Array = []
		for ci in pl.get_slide_collision_count():
			var co := pl.get_slide_collision(ci)
			carp.append([String((co.get_collider() as Node).name) if co.get_collider() is Node else "?", co.get_normal().snapped(Vector3.ONE * 0.01), co.get_position().snapped(Vector3.ONE * 0.01)])
		var yon := Vector2(pl.global_position.x - bas0.x, pl.global_position.z - bas0.z).normalized()
		print("DOKU2 cati_sina_ayr ev=%d beklenen_yon=%s gidilen=%s carpisma=%s ev_yerel_son=%s" % [n, Vector2(ileri.x, ileri.z).snapped(Vector2.ONE * 0.01), yon.snapped(Vector2.ONE * 0.01), carp, (xf.affine_inverse() * pl.global_position).snapped(Vector3.ONE * 0.01)])
		Input.action_release("move_forward")
		var hedef := ust.y
		var gecti := en >= hedef - 0.35
		if gecti:
			ok += 1
		print("DOKU2 cati_sina ev=%s gercek=%s hedef_y=%.2f en_yuksek=%.2f bas=%s son=%s yol=%.2f alt=%s frozen=%s %s" % [n, IstGeo.real(c.x, c.y).round(), hedef, en, bas0, pl.global_position, Vector2(pl.global_position.x - bas0.x, pl.global_position.z - bas0.z).length(), alt, pl.get("frozen"), "PASS" if gecti else "FAIL"])
		pl.queue_free()
		await get_tree().physics_frame
	print("DOKU2 cati_sina sonuc %d/5" % ok)


## Kabaca: kameranın önünde ve görünürlük aralığında olan çizim yüzeyleri, katmana göre (IstSehir altında ad önekiyle)
func _dagilim() -> Dictionary:
	var out := {}
	var cp := cam.global_position
	var fw := -cam.global_transform.basis.z
	for n in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
		var g := n as GeometryInstance3D
		if not g.is_visible_in_tree():
			continue
		var p := g.global_position
		var aabb := g.get_aabb()
		var gc := g.global_transform * aabb.get_center()
		var d := cp.distance_to(gc)
		var rad := aabb.size.length() * 0.5
		if g.visibility_range_end > 0.0 and d > g.visibility_range_end + rad * 0.0:
			continue
		if d < g.visibility_range_begin:
			continue
		if (gc - cp).dot(fw) < -rad:
			continue
		var surf := 1
		if g is MeshInstance3D and (g as MeshInstance3D).mesh:
			surf = (g as MeshInstance3D).mesh.get_surface_count()
		var key := ""
		var cur: Node = g
		while cur != null and cur.get_parent() != null:
			var par := cur.get_parent()
			if par.name in ["IstSehir", "IstMahalleDoku"] or par is IstDunya:
				key = String(par.name) + "/" + String(cur.name).rstrip("0123456789_").left(14)
				break
			cur = par
		if key == "":
			key = "diger"
		out[key] = int(out.get(key, 0)) + surf
	var top: Array = []
	for k in out:
		top.append([out[k], k])
	top.sort()
	top.reverse()
	return {"ilk": top.slice(0, 12)}


## Sayım: ev ve tip dağılımı, aralıklar, 40 m'lik karelerde boşluk
func _sayim() -> void:
	var sk: IstSokak = IstSehir.sokak
	if sk == null:
		print("DOKU2 sokak yok")
		return
	var tips := {}
	var katlar := {}
	for h: Dictionary in sk.houses:
		var t := String(h["tip"])
		tips[t] = int(tips.get(t, 0)) + 1
		var dm := IstEvler.dims(int(h["v"]))
		var kat := "1" if dm.y < 4.6 else ("2" if dm.y < 7.0 else "3+")
		katlar[kat] = int(katlar.get(kat, 0)) + 1
	var st := {}
	for s: Dictionary in sk.streets:
		st[String(s["tur"])] = int(st.get(String(s["tur"]), 0)) + 1
	var hist := {}
	var nic := 0
	for j in range(0, sk.nz, 2):
		for i in range(0, sk.nx, 2):
			var c := sk.cell_c(i, j)
			if not IstGeo.sehir_ici(c.x, c.y):
				continue
			nic += 1
			var o := sk.occ[j * sk.nx + i]
			hist[o] = int(hist.get(o, 0)) + 1
	var hp := {}
	for o in hist:
		hp[["bos", "yol", "ev", "anit_sur", "dis", "doku", "avlu"][int(o)]] = "%.1f%%" % (100.0 * hist[o] / maxf(nic, 1))
	print("DOKU2 doluluk sehir_ici ", hp)
	if IstSehir.active and OS.get_cmdline_user_args().has("anit=1"):
		var lst: Array = []
		for it: Dictionary in IstSehir.active.items:
			if it.has("hat"):
				continue
			var dt: Dictionary = it.get("data", {})
			lst.append([float(it["r"]), String(it["id"]), dt.get("gercek_olcu", Vector3.ZERO), float(it.get("k", 0.0)), it.keys()])
		lst.sort()
		lst.reverse()
		for e in lst.slice(0, 25):
			print("DOKU2 anit ", e)
	if shots != "" or OS.get_cmdline_user_args().has("--harita=1") or OS.get_cmdline_user_args().has("harita=1"):
		var img := Image.create(sk.nx, sk.nz, false, Image.FORMAT_RGB8)
		var pal := [Color("6a8a4a"), Color("d8d0b8"), Color("b05030"), Color("404040"), Color("203050"), Color("90b050"), Color("c8a060")]
		for j in sk.nz:
			for i in sk.nx:
				img.set_pixel(i, j, pal[sk.occ[j * sk.nx + i]])
		var yol := shots if shots != "" else "/root/is"
		img.save_png(yol.path_join(on + "doluluk.png"))
	# Sokaktan çatıya yol: her sıranın en az bir evinde IstEvler.climbs (dükkân tentesi, sundurma, dış merdiven)
	var sira_yol := {}
	var siralar := {}
	for h: Dictionary in sk.houses:
		siralar[int(h["sira"])] = true
		if not IstEvler.climbs(int(h["v"]), String(h["tip"])).is_empty():
			sira_yol[int(h["sira"])] = true
	print("DOKU2 cati_yolu sira=%d yolu_olan=%d (%.1f%%)" % [siralar.size(), sira_yol.size(), 100.0 * sira_yol.size() / maxf(siralar.size(), 1)])
	print("DOKU2 sayim ev=%d sira=%d tip=%s kat=%s sokak=%s doku=%d meydan=%d stats=%s" % [sk.houses.size(), sk.rows, tips, katlar, st,
		sk.doku.size(), sk.meydan.size(), sk.stats])
	# Aralıklar: ev tabanı dikdörtgenleri (cumba dahil değil) arasındaki en kısa uzaklık
	var polys: Array = []
	var hash := {}
	for i in sk.houses.size():
		var h: Dictionary = sk.houses[i]
		var dm := IstEvler.dims(int(h["v"]))
		var c: Vector2 = h["c"]
		var yaw := float(h["yaw"])
		var u := Vector2(cos(yaw), -sin(yaw))
		var v := Vector2(sin(yaw), cos(yaw))
		var pg := PackedVector2Array([c - u * dm.x * 0.5 - v * dm.z * 0.5, c + u * dm.x * 0.5 - v * dm.z * 0.5,
			c + u * dm.x * 0.5 + v * dm.z * 0.5, c - u * dm.x * 0.5 + v * dm.z * 0.5])
		polys.append(pg)
		var key := Vector2i(floori(c.x / 16.0), floori(c.y / 16.0))
		if not hash.has(key):
			hash[key] = []
		hash[key].append(i)
	var bitisik := 0
	var dar := 0
	var ornek: Array = []
	for i in polys.size():
		var c: Vector2 = sk.houses[i]["c"]
		var key := Vector2i(floori(c.x / 16.0), floori(c.y / 16.0))
		for dj in range(-1, 2):
			for di in range(-1, 2):
				for j: int in hash.get(key + Vector2i(di, dj), []):
					if j <= i:
						continue
					var d := IstSokak.poly_gap(polys[i], polys[j])
					if d < 0.05:
						bitisik += 1
					elif d < 1.4:
						dar += 1
						if ornek.size() < 6:
							ornek.append(IstGeo.real(c.x, c.y).round())
	print("DOKU2 aralik bitisik=%d dar=%d ornek=%s" % [bitisik, dar, ornek])
	# 40 m'lik karelerde boşluk (şehir içi): ev, sokak dışı doku öğesi, anıt yoksa "boş"
	var dolu := {}
	for h: Dictionary in sk.houses:
		var c: Vector2 = h["c"]
		dolu[Vector2i(floori(c.x / 40.0), floori(c.y / 40.0))] = true
	for d: Dictionary in sk.doku:
		var c: Vector2 = d["c"]
		var al: Vector2 = d["alan"]
		for oy in [-0.4, 0.0, 0.4]:
			for ox in [-0.4, 0.0, 0.4]:
				dolu[Vector2i(floori((c.x + al.x * ox) / 40.0), floori((c.y + al.y * oy) / 40.0))] = true
	for m: Dictionary in sk.meydan:
		var c: Vector2 = m["c"]
		dolu[Vector2i(floori(c.x / 40.0), floori(c.y / 40.0))] = true
	for c: Vector2 in sk.oge_noktalari():
		dolu[Vector2i(floori(c.x / 40.0), floori(c.y / 40.0))] = true
	if IstSehir.active:
		for it: Dictionary in IstSehir.active.items:
			var p: Vector3 = it["pos"]
			var r := float(it["r"])
			var n := int(ceil(r / 40.0))
			for dj in range(-n, n + 1):
				for di in range(-n, n + 1):
					var q := Vector2(p.x + di * 40.0, p.z + dj * 40.0)
					if q.distance_to(Vector2(p.x, p.z)) <= r * 0.8:
						dolu[Vector2i(floori(q.x / 40.0), floori(q.y / 40.0))] = true
	for bolge: String in ["sehir_ici", "galata"]:
		_istbos(bolge, sk, dolu)


func _istbos(bolge: String, sk: IstSokak, dolu: Dictionary) -> void:
	var top := 0
	var bos := 0
	var bos_ornek: Array = []
	var poly := IstGeo.kiyi("yarimada") if bolge == "sehir_ici" else IstGeo.yol("galata_suru")
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for p in poly:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	for j in range(floori(lo.y / 40.0), floori(hi.y / 40.0) + 1):
		for i in range(floori(lo.x / 40.0), floori(hi.x / 40.0) + 1):
			var c := Vector2((i + 0.5) * 40.0, (j + 0.5) * 40.0)
			# karenin tamamı sur içinde ve karada
			var ic := true
			for o: Vector2 in [Vector2(-18, -18), Vector2(18, -18), Vector2(18, 18), Vector2(-18, 18)]:
				var ici := IstGeo.sehir_ici(c.x + o.x, c.y + o.y) if bolge == "sehir_ici" else IstGeo.galata_ici(c.x + o.x, c.y + o.y)
				if not ici or IstGeo.su(c.x + o.x, c.y + o.y):
					ic = false
			if not ic or sk.cell(c.x, c.y) == 3:
				continue
			var oyun := false
			if IstSehir.active:
				for a: Rect2 in IstSehir.active.oyun_alanlari():
					if a.grow(20.0).has_point(c):
						oyun = true
			if oyun:
				continue
			top += 1
			if not dolu.has(Vector2i(i, j)):
				bos += 1
				if bos_ornek.size() < 12:
					bos_ornek.append(IstGeo.real(c.x, c.y).round())
	print("ISTBOS %s kare=%d bos=%d oran=%.1f%% ornek=%s" % [bolge, top, bos, 100.0 * bos / maxf(top, 1), bos_ornek])


## DOKU-4: çatıdan çatıya (ŞEHİR'in `--set=oyun` sınamasıyla aynı seçim: evler x'e göre sıralı, %10/30/50/70/90'daki evin
## 35 m çevresinde aynı sıradan bitişik ilk çift) + her mahallede ek 4 çift (toplam 25). Gerçek oyuncu A'nın çatısından
## B'nin çatısına yürür (2,4 m/sn, 7 sn). Satır: DOKU4 cati … GECTI|KALDI · DOKU4 cati_toplam n= gecti=
func _cati_cati() -> void:
	var sk: IstSokak = IstSehir.sokak
	var hs: Array = sk.houses.duplicate()
	hs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["c"] as Vector2).x < (b["c"] as Vector2).x)
	var P = load("res://scripts/player/player.gd")
	var pl: CharacterBody3D = P.new()
	add_child(pl)
	if "izle" in dunya:
		dunya.izle = pl
	var n := 0
	var ok_n := 0
	var ilk_n := 0
	var ilk_ok := 0
	for q: float in [0.1, 0.3, 0.5, 0.7, 0.9]:
		var m: Vector2 = (hs[int(q * (hs.size() - 1))] as Dictionary)["c"]
		var ciftler: Array = []
		for a: Dictionary in sk.houses:
			if (a["c"] as Vector2).distance_to(m) > 35.0 + 25.0 * float(ciftler.size() > 0):
				continue
			for b: Dictionary in sk.houses:
				if b == a or int(b["sira"]) != int(a["sira"]):
					continue
				var da := IstEvler.dims(int(a["v"]))
				var db := IstEvler.dims(int(b["v"]))
				var dd := (a["c"] as Vector2).distance_to(b["c"])
				if dd < (da.x + db.x) * 0.5 + 0.3 and dd > 2.0:
					ciftler.append([a, b])
					break
			if ciftler.size() >= 5:
				break
		cam.global_position = Vector3(m.x, IstGeo.h(m.x, m.y) + 40.0, m.y)
		if dunya.has_method("carpisma_yenile"):
			dunya.call("carpisma_yenile", Vector3(m.x, IstGeo.h(m.x, m.y), m.y))
		var s := IstSehir.active
		for c: Dictionary in s._cells0:
			var cc: Vector3 = c["c"]
			if Vector2(cc.x - m.x, cc.z - m.y).length() < 110.0 and not c["up"]:
				s._cell_up(c)
		await _bekle(20.0)
		for ci in ciftler.size():
			var A: Dictionary = ciftler[ci][0]
			var B: Dictionary = ciftler[ci][1]
			var ca: Vector2 = A["c"]
			var cb: Vector2 = B["c"]
			pl.global_position = Vector3(ca.x, IstGeo.h(ca.x, ca.y) + 30.0, ca.y)
			for i in 30:
				await get_tree().physics_frame
			var sp := get_world_3d().direct_space_state
			var rq := PhysicsRayQueryParameters3D.create(Vector3(ca.x, 90, ca.y), Vector3(ca.x, -5, ca.y))
			rq.exclude = [pl.get_rid()]
			var ra := sp.intersect_ray(rq)
			if ra.is_empty():
				print("DOKU4 cati A_yok")
				continue
			pl.global_position = (ra["position"] as Vector3) + Vector3(0, 0.6, 0)
			pl.velocity = Vector3.ZERO
			for i in 6:
				await get_tree().physics_frame
			var y_a := pl.global_position.y
			pl.set("move_mode", "script")
			var t := 0.0
			var en_y := y_a
			while t < 7.0:
				await get_tree().physics_frame
				t += get_physics_process_delta_time()
				var p2 := Vector2(pl.global_position.x, pl.global_position.z)
				var to := Vector3(cb.x - p2.x, 0, cb.y - p2.y)
				pl.rotation.y = atan2(-to.x, -to.z)
				pl.set("script_velocity", to.normalized() * 2.4 if to.length() > 0.4 else Vector3.ZERO)
				en_y = maxf(en_y, pl.global_position.y)
			pl.set("script_velocity", Vector3.ZERO)
			var son := pl.global_position
			var gecti := Vector2(son.x, son.z).distance_to(cb) < 1.5 and son.y > IstGeo.h(cb.x, cb.y) + 2.5
			var ua: Dictionary = IstMahalleDoku.aktif._ev_ust(A)
			var ub: Dictionary = IstMahalleDoku.aktif._ev_ust(B)
			n += 1
			if gecti:
				ok_n += 1
			if ci == 0:
				ilk_n += 1
				if gecti:
					ilk_ok += 1
			print("DOKU4 cati mah=%s i=%d A=%s/%s B=%s/%s ust_a=%.1f/%.1f ust_b=%.1f/%.1f y_a=%.1f en=%.1f son=%s kalan=%.1f %s" % [
				IstGeo.mahalle(m.x, m.y).get("ad", ""), ci, A["tip"], ua["cati"], B["tip"], ub["cati"], ua["yuz"], ua["engel"], ub["yuz"], ub["engel"],
				y_a, en_y, son.snapped(Vector3.ONE * 0.1), Vector2(son.x, son.z).distance_to(cb), "GECTI" if gecti else "KALDI"])
	print("DOKU4 cati_toplam n=%d gecti=%d ilk_cift(sehir2 secimi)=%d/%d" % [n, ok_n, ilk_ok, ilk_n])
	pl.queue_free()
