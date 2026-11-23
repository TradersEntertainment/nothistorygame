extends "res://tests/_ist/tasima10_kare.gd"
## TAŞIMA-12 kare aracı (Taşıma 10'unkinin üstüne): aynı sürüş, yeni bölümlerin bakışları.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/tasima12_kare.tscn -- bolum=8y shots=KLASÖR [yalniz=a,b] [--eskisur=8y]
## Satırlar: T10KARE_YUKLE · T10KARE ad=… cizim=… ilkel=… · T10KARE_BITTI


func _hazirla() -> void:
	match bolum:
		"13":
			GameState.chapter_outcomes[8] = "8.1"
			GameState.flags["cur_scene"] = "chapter12b"      # 13'ün şehir dalı (=city çeşidiyle aynı)
			# 13 şehre büro sahnesinden sonra geçer: otomatik oyunun "city" çeşidiyle akış hub'a gelir
			GameState.autotest = true
			GameState.autotest_variant = "city"
		"23", "24":
			GameState.chapter_outcomes[8] = "8.1"
		_:
			super._hazirla()


## Taşıma 10'unkinin aynısı; hub'ı bekleme listesine 13, 23, 24 eklendi (hub bölüm akışında sonradan kurulabilir)
func _surus() -> void:
	var sc := load("res://scenes/chapter%s.tscn" % bolum.trim_prefix("uzak")) as PackedScene
	var t0 := Time.get_ticks_msec()
	ch = sc.instantiate() as Node3D
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	await get_tree().process_frame
	var t := 0.0
	while city == null and t < (90.0 if bolum in ["6", "7", "10h", "12b", "13", "23", "24"] else 0.0):
		city = _bul(ch)
		await get_tree().process_frame
		t += get_process_delta_time()
	if bolum.begins_with("uzak"):
		# uzak hub: bölümün v2 dünyası kurulsun (IstBaglama), hub_sehir öğesi akışla gelsin
		var tt := 0.0
		while not IstBaglama.aktif() and tt < 120.0:
			await get_tree().process_frame
			tt += get_process_delta_time()
		await _bekle(20.0)
		get_tree().paused = true
	if bolum in ["31o", "41o", "42b"]:
		# sur seti bölümün akışında kurulur (31o ev evresi): kurulunca otomatik akış donar
		if bolum == "31o":
			GameState.autotest = true
		var tt := 0.0
		while ch.get("walls") == null and tt < 120.0:
			await get_tree().process_frame
			tt += get_process_delta_time()
		await _bekle(6.0)
		get_tree().paused = true
	if bolum == "13" and city != null:
		await _bekle(20.0)
		get_tree().paused = true      # otomatik akış (=city) bölümü bitirmesin: dünya donar, kareler alınır
	print("T10KARE_YUKLE bolum=%s v2=%s yeni=%s ms=%d" % [bolum, IstBaglama.aktif(), (city if city != null else ch).get("sur_yeni") == true, Time.get_ticks_msec() - t0])
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


func _bakislar() -> Array:
	var c := city as Node3D
	match bolum:
		"8y":
			var b: Array = super._bakislar()
			var g := func(x: float, z: float) -> float: return float(ch.call("_gy", x, z))
			var cr: Vector3 = (ch.get_script() as Script).get_script_constant_map()["BATTERY"] + Vector3(3.2, 0, 4.4)
			var y := float(g.call(cr.x, cr.z))
			b.append(["08_halatci_yakin", ch.to_global(Vector3(cr.x - 1.3, y + 0.75, cr.z + 0.9)), ch.to_global(Vector3(cr.x, y + 0.15, cr.z)), ch.to_global(Vector3(cr.x - 3.0, y, cr.z - 2.0))])
			b.append(["09_halatci_yan", ch.to_global(Vector3(cr.x + 0.2, y + 0.35, cr.z + 1.6)), ch.to_global(Vector3(cr.x, y + 0.1, cr.z)), ch.to_global(Vector3(cr.x - 3.0, y, cr.z - 2.0))])
			b.append(["10_batarya", ch.to_global(Vector3(cr.x - 7.0, y + 1.8, cr.z - 6.0)), ch.to_global(Vector3(cr.x - 2.0, y + 0.6, cr.z)), ch.to_global(Vector3(cr.x - 7.0, y, cr.z - 6.0))])
			return b
		"13", "23", "24":
			var gz := 5.5
			return [
				["01_caddeden_sur", c.to_global(Vector3(-20.0, 1.7, -14.0)), c.to_global(Vector3(34.0, 7.0, -10.0)), null],
				["02_kapi_sehir_yani", c.to_global(Vector3(22.0, 1.7, 0.5)), c.to_global(Vector3(33.0, 3.5, gz)), null],
				["03_ufuk", c.to_global(Vector3(-30.0, 16.0, -6.0)), c.to_global(Vector3(60.0, 8.0, -14.0)), null],
				["04_ic_mekan_kapisi", c.to_global(ByzCity.EMPEROR_POS + Vector3(9.0, 1.7, 3.0)), c.to_global(ByzCity.EMPEROR_POS + Vector3(0.0, 1.5, 0.0)), null],
				["05_tepeden", c.to_global(Vector3(-10.0, 140.0, -10.0)), c.to_global(Vector3(45.0, 0.0, -10.0)), null],
			]
		"31o":
			var w := ch.get("walls") as Node3D
			var ro: Dictionary = (ch.get("sur") as SurSet).romanos()
			var g := w.to_global(Vector3(float(ro["x"]), 0.0, float(ro["ic_z0"])))     # iç kapının şehir yüzü (sahne çerçevesi)
			return [
				["01_caddeden_kapi", g + Vector3(0.6, 1.7, -16.0), g + Vector3(0.0, 4.0, 2.0), null],
				["02_kapi_yakin", g + Vector3(1.2, 1.6, -2.2), g + Vector3(-0.6, 2.2, 2.0), null],
				["03_cadde", Vector3(-1.2, 1.8, -30.0), Vector3(1.0, 2.6, -60.0), null],
				["04_tepeden", g + Vector3(-40.0, 60.0, -40.0), g + Vector3(0.0, 0.0, 0.0), null],
			]
		"41o", "42b":
			var y := ch.get("yard") as Node3D
			var sgn := -1.0 if bolum == "41o" else 1.0       # sur 41o'da meydanın −z'sinde (ova), 42b'de +z'sinde (şehir)
			var p := y.global_position
			return [
				["01_meydandan_sur", p + Vector3(4.0, 1.7, -sgn * 6.0), p + Vector3(0.0, 6.0, sgn * 60.0), null],
				["02_meydan", p + Vector3(-14.0, 5.0, -sgn * 14.0), p + Vector3(0.0, 1.0, 0.0), null],
			]
		"uzak7", "uzak11":
			# uzak hub (IstSehir hub_sehir): v2 kökünün çerçevesinde SurHub.hub_v2 (hub yereli → v2)
			var hv: Transform3D = IstBaglama.kok.global_transform * load("res://scripts/world/ist/sur_set_hub.gd").hub_v2()
			for it: Dictionary in IstSehir.active.items:
				if String(it.get("id", "")) == "hub_sehir":
					print("T12_UZAK hub_sehir pos=%s yaw=%.1f hub_v2=%s yaw=%.1f" % [it["pos"], rad_to_deg(float(it["yaw"])),
						load("res://scripts/world/ist/sur_set_hub.gd").hub_v2().origin, rad_to_deg(load("res://scripts/world/ist/sur_set_hub.gd").hub_v2().basis.get_euler().y)])
			return [
				["01_uzak_hub_havadan", hv * Vector3(-70.0, 70.0, -40.0), hv * Vector3(30.0, 0.0, -5.0), null],
				["02_uzak_hub_kapi", hv * Vector3(12.0, 16.0, 14.0), hv * Vector3(33.0, 5.0, 5.5), null],
			]
		"17o", "21o":
			# oyuncunun gözünden: 17o Haliç'in karşı kıyısı (şehir surları uzak fon, +z), 21o tünel (iki yön)
			var pl := get_tree().get_first_node_in_group("player") as Node3D
			var e := pl.global_position + Vector3(0, 1.65, 0)
			if bolum == "17o":
				return [["01_karsi_kiyi_sur", e + Vector3(0, 2.0, 0), e + Vector3(0, 4.0, 200.0), null],
					["02_karsi_kiyi_sag", e + Vector3(0, 2.0, 0), e + Vector3(120.0, 4.0, 180.0), null]]
			return [["01_tunel_ileri", e, e + pl.global_basis * Vector3(0, 0, -10.0), null],
				["02_tunel_geri", e, e + pl.global_basis * Vector3(0, 0, 10.0), null]]
	return super._bakislar()


## Çekimden önce bölümün arayüz katmanları (başlık kartı, altyazı, harita) gizlenir: kare dünyayı göstersin
func _cek(ad: String) -> void:
	for n in ch.find_children("*", "CanvasLayer", true, false):
		(n as CanvasLayer).visible = false
	await super._cek(ad)
