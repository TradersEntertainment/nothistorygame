extends "res://tests/_ist/tasima12_kare.gd"
## TAŞIMA-13 kare aracı (31o: yeni surun ardında v2 şehri). Bölüm GERÇEK akışında açılır; ev evresi kurulunca (ilk konuşmada
## bekler: kendiliğinden ilerleme kapalı) dünya DONDURULMAZ (kalabalık ve v2 akışı sürer) ve aynı kameralardan kare alınır.
## ESKİ | YENİ: aynı araç `--eskisur=31o` ile ve `--yenisur=31o` ile (ESKI_VARSAYILAN boşaldıktan sonra anahtarsız yeni).
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/tasima13_kare.tscn -- bolum=31o shots=KLASÖR [yalniz=a,b]
##   evre=1: otomatik oyun (=yuksek hızda akış); eyüp ve aya evrelerinin ilk karesi oyuncunun kamerasından.
## Satırlar: T10KARE_YUKLE · T10KARE ad=… cizim=… ilkel=… · T13KARE ad=… kare_ms=… · T10KARE_BITTI

var evre := false


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.trim_prefix("--") == "evre=1":
			evre = true
	super._ready()


func _hazirla() -> void:
	GameState.settings["auto_advance"] = false
	if evre:
		GameState.autotest = true
		GameState.autotest_variant = ""


func _surus() -> void:
	if evre:
		await _evreler()
		return
	var sc := load("res://scenes/chapter31o.tscn") as PackedScene
	var t0 := Time.get_ticks_msec()
	ch = sc.instantiate() as Node3D
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	var t := 0.0
	while ch.get("city") == null and t < 120.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	var v2 := bool(ch.get("sur_v2"))
	print("T10KARE_YUKLE bolum=31o v2=%s yeni=%s ms=%d" % [IstBaglama.aktif(), v2, Time.get_ticks_msec() - t0])
	await _bekle(14.0)
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
		await _bekle(3.0)
		await _akis_bekle(8.0)
		await _bekle(1.0)
		await _kare_ms(String(b[0]))
		await _cek(String(b[0]))
	# (3) kalabalıktan biri 0,5-3 m: kameraya en yakın görünen gövde
	if yalniz == "" or "03_kalabalik_yakin" in yalniz.split(","):
		await _kalabalik_yakin()
	print("T10KARE_BITTI")
	get_tree().quit()


func _bakislar() -> Array:
	# Çerçeve iki sette aynı: iç kapı x 0, iç surun şehir yüzü z −4 (LandWalls.INNER_Z0), −z şehir
	var z0 := LandWalls.INNER_Z0
	return [
		["01a_kapidan_sehre", Vector3(0.4, 1.7, z0 - 1.0), Vector3(0.0, 1.8, z0 - 14.0)],
		["01b_kapidan_derin", Vector3(0.4, 1.7, z0 - 1.0), Vector3(-1.0, 6.0, z0 - 150.0)],
		["02_caddeden_sura", Vector3(0.8, 1.7, -40.0), Vector3(0.0, 6.0, z0)],
		["04a_tepeden_dikis", Vector3(-70.0, 85.0, 40.0), Vector3(0.0, 0.0, -30.0)],
		["04b_tepeden_sehir", Vector3(55.0, 70.0, -130.0), Vector3(0.0, 0.0, -20.0)],
	]


## Bakış başına ortalama kare süresi (2 sn) ve çizim
func _kare_ms(ad: String) -> void:
	var t0 := Time.get_ticks_usec()
	var n := 0
	var en := 0.0
	var son := t0
	while Time.get_ticks_usec() - t0 < 2000000:
		await get_tree().process_frame
		var s := Time.get_ticks_usec()
		en = maxf(en, (s - son) / 1000.0)
		son = s
		n += 1
	print("T13KARE ad=%s kare_ms=%.1f en_uzun_ms=%.1f kare=%d" % [ad, (Time.get_ticks_usec() - t0) / 1000.0 / maxf(n, 1), en, n])


## Kalabalığın gövdeleri (v2: IstHayatYakin gerçek gövdeler; eski: CityLife düğümleri)
func _govdeler() -> Array:
	var out: Array = []
	var yk := IstHayatYakin.aktif
	if yk != null and is_instance_valid(yk) and yk.is_inside_tree():
		for ag in yk.active_list():
			if ag.body != null and is_instance_valid(ag.body) and ag.body.visible and ag.near:
				out.append(ag.body)
		return out
	for cl in ch.find_children("CityLife", "Node3D", true, false):
		if cl is CityLife:
			for e: Dictionary in (cl as CityLife).active_list():
				var n = e.get("node")
				if n is Node3D and is_instance_valid(n) and (n as Node3D).visible:
					out.append(n)
	return out


func _kalabalik_yakin() -> void:
	# kamerayı kalabalığın ortasına (v2: oyun alanının dışındaki ilk sokak halkası) götür, gövdeler gerçekleşsin
	var hedef := Vector3.INF
	var yk := IstHayatYakin.aktif
	if yk != null and is_instance_valid(yk) and yk.is_inside_tree():
		var g := (yk.get_parent() as Node3D).global_transform
		var bd := INF
		for ag in yk.active_list():
			var w: Vector3 = g * ag.pos
			var d := Vector2(w.x, w.z).distance_to(Vector2(0.0, -40.0))
			if d < bd:
				bd = d
				hedef = w
	else:
		var gl := _govdeler()
		if not gl.is_empty():
			hedef = (gl[0] as Node3D).global_position
	if hedef == Vector3.INF:
		print("T13KARE kalabalik_yok")
		return
	cam.global_position = hedef + Vector3(3.0, 1.7, 3.0)
	cam.look_at(hedef + Vector3(0, 1.2, 0), Vector3.UP)
	cam.make_current()
	var pl := get_tree().get_first_node_in_group("player") as Node3D
	if pl != null:
		pl.global_position = hedef + Vector3(4.0, 0.1, 4.0)
	await _bekle(4.0)
	# en yakın gerçek gövde: 2 m önünden, göz hizasından
	var best: Node3D = null
	var bd2 := INF
	for b: Node3D in _govdeler():
		var d := b.global_position.distance_to(cam.global_position)
		if d < bd2:
			bd2 = d
			best = b
	if best == null:
		print("T13KARE kalabalik_govde_yok")
		return
	get_tree().paused = true
	var fw := -best.global_basis.z
	fw.y = 0.0
	fw = fw.normalized() if fw.length() > 0.1 else Vector3.FORWARD
	cam.global_position = best.global_position + fw * 2.2 + Vector3(0.3, 1.65, 0.0)
	cam.look_at(best.global_position + Vector3(0, 1.35, 0), Vector3.UP)
	cam.make_current()
	await _bekle(0.5)
	print("T13KARE kalabalik uzaklik=%.2f" % cam.global_position.distance_to(best.global_position + Vector3(0, 1.35, 0)))
	await _cek("03_kalabalik_yakin")
	get_tree().paused = false


## Evre geçişi: otomatik oyunda eyüp ve aya evrelerinin ilk karesi (oyuncunun kamerası)
func _evreler() -> void:
	var sc := load("res://scenes/chapter31o.tscn") as PackedScene
	ch = sc.instantiate() as Node3D
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	for ev: String in ["eyup", "scaff"]:
		var t0 := Time.get_ticks_msec()
		while String(ch.get("phase")) != ev and Time.get_ticks_msec() - t0 < 400000:
			await get_tree().process_frame
		await _bekle(3.0)
		await _cek("05_%s_ilk" % ("eyup" if ev == "eyup" else "aya"))
	print("T10KARE_BITTI")
	get_tree().quit()
