extends Node
## TAŞIMA-10 kare aracı: bölümü GERÇEK akışında açar (otomatik test değil), açılış geçince bölümün kendi noktalarından
## (eski kipte eski değerleri, yeni kipte yenileri: WALL_TOP, EMP_AT, DOOR …) anlamca AYNI bakışlardan kare alır.
## ESKİ | YENİ: aynı araç, `--eskisur=<bölüm>` ile ve onsuz.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/tasima10_kare.tscn -- bolum=12b shots=KLASÖR [--eskisur=12b]
## Satırlar: T10KARE_YUKLE · T10KARE ad=… cizim=… ilkel=… · T10KARE_BITTI

const SurHub := preload("res://scripts/world/ist/sur_set_hub.gd")

var bolum := "12b"
var shots := ""
var yalniz := ""
var ch: Node3D
var city: Node3D
var cam: Camera3D
var _n := 0


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"bolum": bolum = kv[1]
			"shots": shots = kv[1]
			"yalniz": yalniz = kv[1]
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	GameState.autotest = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_hazirla()
	_surus.call_deferred()


## Bölümün akışının istediği ön koşullar (hub_kare ile aynı)
func _hazirla() -> void:
	match bolum:
		"6":
			GameState.chapter_outcomes[4] = "4b.1"
		"7":
			GameState.chapter_outcomes[6] = "6b.1"
		"10h", "12b":
			GameState.chapter_outcomes[8] = "8.1"


func _surus() -> void:
	var sc := load("res://scenes/chapter%s.tscn" % bolum) as PackedScene
	var t0 := Time.get_ticks_msec()
	ch = sc.instantiate() as Node3D
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	await get_tree().process_frame
	var t := 0.0
	while city == null and t < (60.0 if bolum in ["6", "7", "10h", "12b"] else 0.0):
		city = _bul(ch)
		await get_tree().process_frame
		t += get_process_delta_time()
	print("T10KARE_YUKLE bolum=%s v2=%s yeni=%s ms=%d" % [bolum, IstBaglama.aktif(), bool((city if city != null else ch).get("sur_yeni")), Time.get_ticks_msec() - t0])
	await _bekle(12.0)
	cam = Camera3D.new()
	cam.fov = 70.0
	cam.far = 4000.0
	cam.near = 0.05
	ch.add_child(cam)
	for b: Array in _bakislar():
		if yalniz != "" and not (String(b[0]) in yalniz.split(",")):
			continue
		cam.global_position = b[1]
		cam.look_at(b[2], Vector3.UP)
		cam.make_current()
		var pl := get_tree().get_first_node_in_group("player") as Node3D
		if pl != null and b.size() > 3 and b[3] is Vector3:
			pl.global_position = b[3]
		await _bekle(3.0)
		await _akis_bekle(8.0)
		cam.make_current()
		await _cek(String(b[0]))
	print("T10KARE_BITTI")
	get_tree().quit()


## [ad, göz (dünya), bakılan (dünya), (oyuncunun konacağı yer)] — bölümün kendi noktalarından
func _bakislar() -> Array:
	var c := city as Node3D
	match bolum:
		"12b":
			var wt: Vector3 = ch.get("WALL_TOP")
			var em: Vector3 = ch.get("EMP_AT")
			var dr: Vector3 = ch.get("DOOR")
			var gz := 5.5
			return [
				["01_surda_imparator", wt + Vector3(-0.3, 1.65, -1.4), em + Vector3(0.3, 1.4, 0.3), wt + Vector3(0, 0, 3.0)],
				["02_mazgal_yakin", em + Vector3(-0.9, 1.6, -1.2), em + Vector3(3.0, 1.0, 0.6), wt + Vector3(0, 0, 3.0)],
				["03_kule_kapisi", wt + Vector3(0.0, 1.65, -2.0), dr + Vector3(0, 1.4, 0), wt + Vector3(0, 0, -3.0)],
				["04_surdan_ordugah", wt + Vector3(0.6, 1.7, 0.0), wt + Vector3(60.0, -6.0, 0.0), wt + Vector3(0, 0, -3.0)],
				["05_caddeden_sur", c.to_global(Vector3(-20.0, 1.7, -14.0)), c.to_global(Vector3(34.0, 7.0, -10.0)), null],
				["06_kapi_sehir_yani", c.to_global(Vector3(24.5, 1.7, 1.5)), c.to_global(Vector3(33.0, 3.5, gz)), null],
				["07_disaridan_sur", c.to_global(Vector3(130.0, 22.0, -14.0)), c.to_global(Vector3(34.0, 6.0, -8.0)), null],
				["08_tepeden", c.to_global(Vector3(-10.0, 140.0, -10.0)), c.to_global(Vector3(45.0, 0.0, -10.0)), null],
			]
		"10h":
			var br: Vector3 = c.to_global(_k("BREACH"))
			return [
				["01_gedik", br + Vector3(-4.0, 1.7, 2.2), br + Vector3(0, 1.6, 0), br + Vector3(-4.0, 0, 2.2)],
				["02_gedik_yakin", br + Vector3(-1.9, 1.5, 1.0), br + Vector3(0.0, 1.0, -0.2), br + Vector3(-1.9, 0, 1.0)],
				["03_kapi_sehir_yani", c.to_global(Vector3(24.5, 1.7, 1.5)), c.to_global(Vector3(33.0, 3.5, 5.5)), c.to_global(Vector3(24.5, 0, 1.5))],
				["04_caddeden_sur", c.to_global(Vector3(-20.0, 1.7, -14.0)), c.to_global(Vector3(34.0, 7.0, -10.0)), null],
			]
		"6":
			var pr: Array = _k("PERCHES")
			var fc: Vector3 = c.to_global(pr[4])
			return [
				["01_sur_yolu_fici", fc + Vector3(-5.0, 0.5, 3.0), fc + Vector3(4.0, 1.5, -1.0), fc + Vector3(-5.0, -1.2, 3.0)],
				["02_giust_masa_sur", c.to_global(ByzCity.GIUST_POS + Vector3(-5.0, 1.7, 3.0)), c.to_global(ByzCity.GIUST_POS + Vector3(3.0, 3.0, -1.0)), null],
				["03_kapi_yakin", c.to_global(ByzCity.EXIT_POS + Vector3(-2.6, 1.65, 0.0)), c.to_global(ByzCity.EXIT_POS + Vector3(1.0, 1.8, 0.0)), c.to_global(ByzCity.EXIT_POS + Vector3(-2.6, 0, 0))],
				["04_caddeden_sur", c.to_global(Vector3(-20.0, 1.7, -14.0)), c.to_global(Vector3(34.0, 7.0, -10.0)), null],
			]
		"7":
			return [
				["01_iz_sur", c.to_global(ByzCity.GIUST_POS + Vector3(-3.5, 1.65, 2.5)), c.to_global(ByzCity.GIUST_POS + Vector3(6.0, 4.0, 0.0)), c.to_global(ByzCity.GIUST_POS + Vector3(-3.5, 0, 2.5))],
				["02_iz_kapi", c.to_global(ByzCity.EXIT_POS + Vector3(-2.4, 1.65, 1.4)), c.to_global(ByzCity.EXIT_POS + Vector3(1.0, 2.0, 0.0)), c.to_global(ByzCity.EXIT_POS + Vector3(-2.4, 0, 1.4))],
				["03_caddeden_sur", c.to_global(Vector3(-20.0, 1.7, -14.0)), c.to_global(Vector3(34.0, 7.0, -10.0)), null],
				["04_tepeden", c.to_global(Vector3(-10.0, 140.0, -10.0)), c.to_global(Vector3(45.0, 0.0, -10.0)), null],
			]
		"8y":
			var gz: float = ch.get("GATE_Z")
			var bz: float = ch.get("BRIDGE_Z")
			var fz: float = ch.get("FIELD_Z")
			var tz: float = ch.get("GATE_TRIGGER_Z")
			var st: Vector3 = ch.get("START")
			var g := func(x: float, z: float) -> float: return float(ch.call("_gy", x, z))
			var on: Vector3 = Vector3(0, 0, gz + 2.3)
			return [
				["01_sehirden_ic_kapi", ch.to_global(st + Vector3(0, 1.65, 0)), ch.to_global(Vector3(0, 4.0, 2.0)), ch.to_global(st)],
				["02_koridor_dis_kapi", ch.to_global(Vector3(0.0, 1.65, tz - 3.0)), ch.to_global(Vector3(0.0, 2.6, gz)), ch.to_global(Vector3(0, 0, tz - 3.0))],
				["03_kanat_yakin", ch.to_global(Vector3(1.2, 1.6, gz - 2.2)), ch.to_global(Vector3(-1.0, 1.4, gz)), ch.to_global(Vector3(1.2, 0, gz - 2.2))],
				["04_kopru", ch.to_global(Vector3(0.0, g.call(0.0, bz + 1.5) + 1.65, bz + 1.5)), ch.to_global(Vector3(0.0, g.call(0.0, fz + 15.0) + 1.0, fz + 15.0)), ch.to_global(Vector3(0, g.call(0.0, bz + 1.5), bz + 1.5))],
				["05_ovadan_sur", ch.to_global(Vector3(0.0, g.call(0.0, 63.0) + 1.7, 63.0)), ch.to_global(Vector3(0.0, 5.0, gz)), ch.to_global(Vector3(0, g.call(0.0, 63.0), 63.0))],
				["06_dis_kapi_yakin", ch.to_global(Vector3(1.6, g.call(1.6, on.z) + 1.6, on.z)), ch.to_global(Vector3(-1.2, 2.6, gz + 1.0)), ch.to_global(Vector3(1.6, g.call(1.6, on.z), on.z))],
				["07_tepeden", ch.to_global(Vector3(-60.0, 90.0, 10.0)), ch.to_global(Vector3(0.0, 0.0, 40.0)), null],
			]
	return []


## Bölümün değişkeni ya da sabiti
func _k(ad: String) -> Variant:
	var v = ch.get(ad)
	if v == null:
		v = (ch.get_script() as Script).get_script_constant_map().get(ad)
	return v


func _bul(n: Node) -> Node3D:
	if n is ByzCity:
		return n
	for c in n.get_children():
		var r := _bul(c)
		if r != null:
			return r
	return null


func _bekle(sn: float) -> void:
	# gerçek saat: bölüm ağacı duraklatırsa (7b açılış kartı) işlem deltası akmaz
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(sn * 1000.0):
		await get_tree().process_frame
		if cam != null:
			cam.make_current()


func _akis_bekle(en_cok: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(en_cok * 1000.0):
		await get_tree().process_frame
		var s := IstSehir.active
		if not IstBaglama.aktif() or s == null:
			break
		var q = s.get("_queue")
		if q is Array and (q as Array).is_empty():
			break


func _cek(ad: String) -> void:
	await RenderingServer.frame_post_draw
	_n += 1
	print("T10KARE ad=%s cizim=%d ilkel=%d" % [ad, RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)])
	if shots != "":
		get_viewport().get_texture().get_image().save_jpg(shots.path_join(ad + ".jpg"), 0.85)
