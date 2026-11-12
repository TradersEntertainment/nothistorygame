# gezi_havadan: tests/_ist/baglama_ucus.gd kopyası; tek fark: _yer() içinde ikinci `var q` adı q2 (taban sürümde ayrıştırma hatası)
extends Node
## BAĞLAMA-3 kanıt ve ölçüm sahnesi: GERÇEK bölümü (7 ya da 11) normal akışında açar (otomatik test değil), Nihat
## serbest kalınca uçurur ve HUD'lu oyun içi kareler alır; yükleme süresini, takılmaları ve çizim yükünü ölçer.
##   godot --path . --resolution 1280x720 res://tests/_ist/baglama_ucus.tscn -- bolum=11 [dal=byz] shots=KLASÖR
##       [kip=kare|rota|olc] [--eski-dunya]
## kip=kare: kalkış, şehrin üstü, ordugâhın üstü, yan görev eserlerine yaklaşma (yer işaretleri, kimlikle), Galata'dan
##   dönüş: <shots>/<n>_<ad>.png. kip=rota: 60 sn'lik güzergâh (kalkış → şehir → Ayasofya), 3 sn'de bir kare (20 kare).
## Satırlar: BAGLAMA_YUKLE ms=… (bölüm sahnesinin eklenmesinden ilk kareye) · BAGLAMA_RINFO ad=… cizim=… ucgen=…
##   · BAGLAMA_TAKILMA evre=… kare=… ust50=… en_uzun=…ms · BAGLAMA_BITTI

var bolum := 11
var dal := ""
var shots := ""
var kip := "kare"
var en_cok := 16
var kirilim := false      # kirilim=1: bazı karelerde çizim kırılımı (v2 gizli / bölüm sahnesi gizli)
var ch: Node3D
var pl: Player
var pw: NihatPowers
var _son_us := 0
var _evre := ""
var _kare := 0
var _ust50 := 0
var _en_uzun := 0.0
var _n := 0


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"bolum": bolum = kv[1].to_int()
			"dal": dal = kv[1]
			"shots": shots = kv[1]
			"kip": kip = kv[1]
			"en_cok": en_cok = kv[1].to_int()
			"kirilim": kirilim = kv[1] == "1"
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	GameState.autotest = false
	if bolum == 7:
		GameState.chapter_outcomes[6] = "6b.1" if dal == "byz" else "6a.1"
	process_priority = 1000
	_surus.call_deferred()


func _process(_dt: float) -> void:
	var now := Time.get_ticks_usec()
	if _son_us > 0 and _evre != "":
		var ms := (now - _son_us) / 1000.0
		_kare += 1
		if ms > 50.0:
			_ust50 += 1
		_en_uzun = maxf(_en_uzun, ms)
	_son_us = now


func _evre_bas(ad: String) -> void:
	_evre = ad
	_kare = 0
	_ust50 = 0
	_en_uzun = 0.0
	_son_us = 0


func _evre_bitir() -> void:
	if _evre != "":
		print("BAGLAMA_TAKILMA evre=%s kare=%d ust50=%d en_uzun=%.0fms" % [_evre, _kare, _ust50, _en_uzun])
	_evre = ""


func _surus() -> void:
	var sc := load("res://scenes/chapter%d.tscn" % bolum) as PackedScene
	var t0 := Time.get_ticks_msec()
	ch = sc.instantiate() as Node3D
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	print("BAGLAMA_YUKLE bolum=%d dal=%s v2=%s ms=%d" % [bolum, dal, IstBaglama.aktif(), Time.get_ticks_msec() - t0])
	pl = get_tree().get_first_node_in_group("player") as Player
	if pl == null:
		pl = ch.find_children("*", "Player", true, false)[0] as Player
	pw = pl.powers
	# kurulum takılması: açılıştan sonraki 20 sn (kart, kararma, ilk konuşmalar; oyuncu henüz serbest değil)
	_evre_bas("acilis_20sn")
	var bekle := 0.0
	while bekle < 20.0:
		await get_tree().process_frame
		bekle += get_process_delta_time()
	_evre_bitir()
	var t := 0.0
	while pl.frozen and t < 60.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	pl.frozen = false
	if kip == "olc":
		await _rota(false)
	elif kip == "rota":
		await _rota(true)
	else:
		await _kareler()
	print("BAGLAMA_BITTI")
	get_tree().quit()


## Ev (saha kapısı): uçuşun başladığı yer
func _ev() -> Vector3:
	return pl.global_position


func _lm(id: String) -> Dictionary:
	for l: Dictionary in pw.landmarks:
		if String(l["id"]) == id:
			return l
	return {}


func _yer(x: float, z: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(Vector3(x, 400, z), Vector3(x, -50, z))
	q.exclude = [pl.get_rid()]
	var hit := pl.get_world_3d().direct_space_state.intersect_ray(q)
	if not hit.is_empty():
		return (hit["position"] as Vector3).y
	if IstBaglama.aktif() and IstBaglama.kok != null:
		var q2 := IstBaglama.kok.to_local(Vector3(x, 0.0, z))       # v2 çerçevesi (dönüşümlü bağlama)
		return IstBaglama.kok.to_global(Vector3(q2.x, IstGeo.h(q2.x, q2.z), q2.z)).y
	return 0.0


## Uçarken bakış: konum ve bakılan nokta
func _koy(p: Vector3, bak: Vector3) -> void:
	if not pw.flying:
		pw.set_flying(true)
	pl.global_position = p
	pl.velocity = Vector3.ZERO
	pw.set("_v", Vector3.ZERO)
	pl.face(bak)


func _akis_bekle(en_az: float, en_cok_sn: float) -> void:
	var t := 0.0
	while t < en_cok_sn:
		await get_tree().process_frame
		t += get_process_delta_time()
		if t < en_az:
			continue
		var s := IstSehir.active
		var bos := true
		if IstBaglama.aktif() and s != null:
			var q = s.get("_queue")
			bos = q is Array and (q as Array).is_empty()
		if bos:
			break


func _gercek() -> Vector2:
	var q := IstBaglama.kok.to_local(pl.global_position) if IstBaglama.kok != null else pl.global_position
	return IstGeo.real(q.x, q.z)


func _cek(ad: String) -> void:
	await RenderingServer.frame_post_draw
	_n += 1
	var dosya := "%02d_%s" % [_n, ad]
	var vp := get_viewport()
	print("BAGLAMA_RINFO ad=%s cizim=%d ucgen=%d nesne=%d konum=(%.0f, %.0f, %.0f) gercek=%s" % [dosya,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		pl.global_position.x, pl.global_position.y, pl.global_position.z,
		_gercek() if IstBaglama.aktif() else "-"])
	if shots != "":
		vp.get_texture().get_image().save_png(shots.path_join(dosya + ".png"))
	if kirilim and IstBaglama.kok != null and ad in ["kalkis", "ordugah_ustu", "galata_donus", "eve_donus", "sehrin_ustu"]:
		var cz := func() -> int:
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			return RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		IstBaglama.kok.visible = false
		var sahne: int = await cz.call()
		IstBaglama.kok.visible = true
		var gizli: Array = []
		for c in ch.get_children():
			if c is Node3D and c != pl and (c as Node3D).visible and not (c as Node3D).is_ancestor_of(IstBaglama.kok):
				(c as Node3D).visible = false
				gizli.append(c)
		for c in IstBaglama.kok.get_parent().get_children():
			if c is Node3D and c != IstBaglama.kok and (c as Node3D).visible:
				(c as Node3D).visible = false
				gizli.append(c)
		var v2: int = await cz.call()
		for c in gizli:
			(c as Node3D).visible = true
		print("BAGLAMA_KIRILIM ad=%s yalniz_sahne=%d yalniz_v2=%d" % [dosya, sahne, v2])


func _kareler() -> void:
	var ev := _ev()
	var aya := _lm("AYASOFYA")
	var aya_p: Vector3 = aya.get("pos", ev + Vector3(0, 0, -1000))
	var yon := Vector3(aya_p.x - ev.x, 0, aya_p.z - ev.z).normalized()
	# 1. kalkış: kapının 8 m üstü, şehre doğru
	_koy(ev + Vector3(0, 8, 0), ev + yon * 200.0 + Vector3(0, 4, 0))
	await _akis_bekle(3.0, 10.0)
	await _cek("kalkis")
	# 2. ordugâhın (bölümün alanı) üstü: 60 m, aşağı bakış
	_koy(ev + Vector3(-50, 60, 70), ev + Vector3(0, 0, -25))
	await _akis_bekle(3.0, 10.0)
	await _cek("ordugah_ustu")
	# 3. şehrin üstü: Ayasofya ile ev arasında, 100 m
	var orta := ev.lerp(aya_p, 0.55)
	_koy(Vector3(orta.x, _yer(orta.x, orta.z) + 100.0, orta.z), aya_p)
	await _akis_bekle(4.0, 14.0)
	await _cek("sehrin_ustu")
	# 4. yan görev eserlerine yaklaşma: her biri 38 m öteden (evden yana), 8 m yukarıdan
	var say := 0
	for l: Dictionary in pw.landmarks.duplicate():
		if say >= en_cok:
			break
		var p: Vector3 = l["pos"]
		var d := Vector3(ev.x - p.x, 0, ev.z - p.z).normalized()
		if d == Vector3.ZERO:
			d = Vector3(0, 0, 1)
		var k := p + d * 38.0 + Vector3(0, 6.0, 0)
		_koy(k, p - Vector3(0, 8.0, 0))
		await _akis_bekle(3.0, 12.0)
		await _cek("eser_" + String(l["id"]).to_lower())
		say += 1
	# 5. Galata'dan dönüş: kulenin yanından eve (ve şehre) bakış
	var gal := _lm("GALATA")
	if not gal.is_empty():
		var gp: Vector3 = gal["pos"]
		_koy(gp + Vector3(0, 4, 0) + Vector3(ev.x - gp.x, 0, ev.z - gp.z).normalized() * 30.0, ev + Vector3(0, 10, 0))
		await _akis_bekle(4.0, 12.0)
		await _cek("galata_donus")
	# 6. dönüşte ordugâhın girişi: alçak uçuş, eve doğru
	_koy(ev + yon * 160.0 + Vector3(0, 25, 0), ev)
	await _akis_bekle(3.0, 10.0)
	await _cek("eve_donus")


## 60 sn'lik güzergâh: 6 sn tırmanış (kapıdan 50 m'ye), sonra 30 m/sn ile Ayasofya'ya doğru (kalan mesafe kısa ise ötesine
## dönüş); 3 sn'de bir kare (20 kare). Takılma ölçümü bu evrede.
func _rota(kare: bool) -> void:
	var ev := _ev()
	var aya := _lm("AYASOFYA")
	var hedef: Vector3 = aya.get("pos", ev + Vector3(0, 0, -1800))
	var yon := Vector3(hedef.x - ev.x, 0, hedef.z - ev.z).normalized()
	pw.set_flying(true)
	_evre_bas("ucus_60sn")
	var t := 0.0
	var sonraki := 0.0
	var p := ev
	while t < 60.0:
		var dt := minf(get_process_delta_time(), 0.1)
		t += dt
		var ilerle := 30.0 if t > 6.0 else 8.0
		p += yon * ilerle * dt
		var zemin := _yer(p.x, p.z)
		var hy := zemin + (minf(t, 6.0) / 6.0) * 50.0 + 2.0
		if t > 6.0:
			hy = maxf(zemin + 45.0, hy)
		p.y = lerpf(p.y, hy, clampf(dt * 2.0, 0.0, 1.0))
		pl.global_position = p
		pl.velocity = Vector3.ZERO
		pw.set("_v", Vector3.ZERO)
		pl.face(p + yon * 100.0 + Vector3(0, -25.0, 0))
		if kare and t >= sonraki:
			sonraki += 3.0
			await _cek("rota_%02ds" % int(t))
		else:
			await get_tree().process_frame
	_evre_bitir()
