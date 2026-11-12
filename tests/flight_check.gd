extends Node3D
## Tek haritada Nihat'ın uçuşu (Bölüm 7, 11): iki hub'ı (ordugâh, şehrin sur tarafı) dünya kipinde kurar, uçuş çarpışmasını
## (WorldFlight) ekler ve denetler: 9 yer işareti, 12 parça, 3 konma noktası var mı, menzil içinde mi; yer işaretlerinin
## ve parçaların altında zemin var mı (uçuşun yükseklik ölçümü); konma noktasının yüzeyi tepede mi (oyuncu bırakılınca
## üstünde durur); Haliç ortasında su yakalayıcı var mı. Sonuç: FLIGHTCHECK PASS/FAIL.

var ok := true


func _ready() -> void:
	GameState.autotest = true
	for hub in ["camp", "walls"]:
		var h: Node3D
		if hub == "camp":
			h = CampDay.new()
		else:
			h = ByzCity.new()
		add_child(h)
		var world: SiegeField = h.get("world")
		WorldFlight.attach(world)
		for i in 3:
			await get_tree().physics_frame
		await _check(hub, h, world)
		remove_child(h)
		h.queue_free()
		await get_tree().physics_frame
	# İstanbul v2 (IstBaglama): aynı iki hub, bölüm 11 / 7 isteğiyle; bakan kamera her noktaya gider (v2 akışla kurulur)
	if IstBaglama.etkin():
		for hub in ["camp", "walls"]:
			IstBaglama.hazirla(11 if hub == "camp" else 7, hub == "camp")
			var h: Node3D = CampDay.new() if hub == "camp" else ByzCity.new()
			add_child(h)
			for i in 3:
				await get_tree().physics_frame
			if not IstBaglama.aktif():
				_fail("v2 %s: IstBaglama kurulmadı" % hub)
			else:
				await _check_v2(hub, h)
			remove_child(h)
			h.queue_free()
			await get_tree().physics_frame
			IstBaglama.birak()
	print("FLIGHTCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit()


func _check(hub: String, h: Node3D, world: SiegeField) -> void:
	var lms: Array = h.call("world_landmarks")
	var forms: Array = h.call("world_forms")
	var perches: Array = h.call("world_perches")
	# İlk dokuzu kayıtlı oyunların kimlikleri, aynı sırada; ardından İstanbul 1453 parçalarının yeni eserleri (adı yazılı)
	if lms.size() < NihatPowers.LANDMARK_IDS.size():
		_fail("%s: %d yer işareti (beklenen en az %d)" % [hub, lms.size(), NihatPowers.LANDMARK_IDS.size()])
	for i in lms.size():
		var l: Array = lms[i]
		if i < NihatPowers.LANDMARK_IDS.size():
			if l[0] != NihatPowers.LANDMARK_IDS[i]:
				_fail("%s: %d. yer işareti %s (beklenen %s)" % [hub, i, l[0], NihatPowers.LANDMARK_IDS[i]])
		elif TranslationServer.translate("LM_" + String(l[0])) == "LM_" + String(l[0]):
			_fail("%s: adı yazılmamış yer işareti %s" % [hub, l[0]])
	if forms.size() != NihatPowers.FORMS_TOTAL:
		_fail("%s: %d parça (beklenen %d)" % [hub, forms.size(), NihatPowers.FORMS_TOTAL])
	var ids := perches.map(func(p: Array) -> String: return p[0])
	for want in ["aya", "galata", "column"]:
		if not (want in ids):
			_fail("%s: konma noktası yok: %s" % [hub, want])
	var space := get_world_3d().direct_space_state
	var home := h.global_position
	var spots: Array = []
	for l: Array in lms:
		spots.append([str(l[0]), l[1] as Vector3])
	for f: Array in forms:
		spots.append(["form_%d" % f[0], f[1] as Vector3])
	for s: Array in spots:
		var p: Vector3 = s[1]
		if Vector2(p.x - home.x, p.z - home.z).length() > 3000.0:
			_fail("%s: %s menzil dışında (%.0f m)" % [hub, s[0], Vector2(p.x - home.x, p.z - home.z).length()])
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(p + Vector3(0, 2, 0), p + Vector3(0, -300, 0)))
		if hit.is_empty():
			_fail("%s: %s altında zemin yok" % [hub, s[0]])
	for pe: Array in perches:
		var p: Vector3 = pe[1]
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(p + Vector3(0, 6, 0), p + Vector3(0, -40, 0)))
		if hit.is_empty() or absf((hit["position"] as Vector3).y - p.y) > 1.5:
			_fail("%s: %s konma yüzeyi yok ya da uzak (%s)" % [hub, pe[0], hit.get("position", "—")])
	# Haliç'in ortası: su yakalayıcı
	var hm := world.to_global(Vector3((World1453.HORN_S_X + World1453.HORN_N_X) * 0.5, World1453.SEA_Y - 0.2, -600.0))
	var pq := PhysicsPointQueryParameters3D.new()
	pq.position = hm
	pq.collide_with_areas = true
	pq.collide_with_bodies = false
	if space.intersect_point(pq, 4).is_empty():
		_fail("%s: Haliç'te su yakalayıcı yok" % hub)
	print("FLIGHTCHECK %s landmarks=%d forms=%d perches=%d" % [hub, lms.size(), forms.size(), perches.size()])


func _fail(msg: String) -> void:
	ok = false
	printerr("FLIGHTCHECK " + msg)


## v2: yer işaretleri (ilk dokuzu kayıtlı kimlikler + adı yazılı yeni eserler), 12 parça, konma noktaları; her noktada
## kamera oraya gider, akış (IstSehir kuyruğu, arazi çarpışması) bitince ışın: altında zemin ya da yapı var mı; konma
## noktasının yüzeyi 1,5 m içinde mi; Haliç'in ortası su mu (IstBaglama su yakalayıcısı); yumuşak sınır hepsini kapsıyor mu
func _check_v2(hub: String, h: Node3D) -> void:
	var fd := IstBaglama.flight_data()
	var lms: Array = fd["landmarks"]
	var forms: Array = fd["forms"]
	var perches: Array = fd["perches"]
	var tag := "v2_" + hub
	if lms.size() < NihatPowers.LANDMARK_IDS.size():
		_fail("%s: %d yer işareti" % [tag, lms.size()])
	for i in lms.size():
		var l: Array = lms[i]
		if i < NihatPowers.LANDMARK_IDS.size() and l[0] != NihatPowers.LANDMARK_IDS[i]:
			_fail("%s: %d. yer işareti %s (beklenen %s)" % [tag, i, l[0], NihatPowers.LANDMARK_IDS[i]])
		if (l[1] as Vector3) == Vector3.INF or not (l[1] as Vector3).is_finite():
			_fail("%s: %s konumsuz" % [tag, l[0]])
	if forms.size() != NihatPowers.FORMS_TOTAL:
		_fail("%s: %d parça (beklenen %d)" % [tag, forms.size(), NihatPowers.FORMS_TOTAL])
	var ids := perches.map(func(p: Array) -> String: return p[0])
	var ham := (IstSehir.flight_data_v2(IstBaglama.kok)["perches"] as Array).map(func(p: Array) -> String: return p[0])
	print("FLIGHTCHECK %s konma=%s ham=%s" % [tag, ids, ham])
	for want in ["aya", "galata", "column"]:
		if not (want in ids):
			_fail("%s: konma noktası yok: %s" % [tag, want])
	var cam := Camera3D.new()
	add_child(cam)
	cam.current = true
	var space := get_world_3d().direct_space_state
	var home := h.global_position + (Vector3(0, 0, 4.0) if hub == "camp" else Vector3(0, 0, 12.0))
	var sinir := IstBaglama.sinir()
	var spots: Array = []
	for l: Array in lms:
		spots.append([str(l[0]), l[1] as Vector3, -1.0])
	for f: Array in forms:
		spots.append(["form_%d" % f[0], f[1] as Vector3, -1.0])
	for pe: Array in perches:
		spots.append(["perch_" + str(pe[0]), pe[1] as Vector3, 1.5])
	var n_ok := 0
	for sp: Array in spots:
		var p: Vector3 = sp[1]
		if Vector2(p.x - home.x, p.z - home.z).length() > 3000.0:
			_fail("%s: %s menzil dışında (%.0f m)" % [tag, sp[0], Vector2(p.x - home.x, p.z - home.z).length()])
		if not sinir.has_point(Vector2(p.x, p.z)):
			_fail("%s: %s uçuş sınırının dışında" % [tag, sp[0]])
		cam.global_position = p + Vector3(0, 12, 8)
		cam.look_at(p)
		IstBaglama.dunya.carpisma_yenile(p)
		var t := 0.0
		while t < 8.0:
			await get_tree().process_frame
			t += get_process_delta_time()
			var q = IstSehir.active.get("_queue") if IstSehir.active else []
			if t > 0.6 and (q == null or (q as Array).is_empty()):
				break
		for i in 2:
			await get_tree().physics_frame
		var tol: float = sp[2]
		var from := p + Vector3(0, 6 if tol > 0.0 else 2, 0)
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, p + Vector3(0, -300 if tol < 0.0 else -40, 0)))
		if hit.is_empty():
			_fail("%s: %s altında zemin yok %s" % [tag, sp[0], p])
		elif tol > 0.0 and absf((hit["position"] as Vector3).y - p.y) > tol:
			_fail("%s: %s konma yüzeyi uzak (nokta y %.1f, yüzey y %.1f)" % [tag, sp[0], p.y, (hit["position"] as Vector3).y])
		else:
			n_ok += 1
	cam.queue_free()
	# Haliç'in ortası: su (yakalayıcı Nihat'ı yeniden havalandırır)
	var hl := IstGeo.yol("halic_suru")
	var hm := hl[hl.size() / 2] + Vector2(0, -40)
	if IstBaglama.son == null:
		_fail("%s: su/zemin yakalayıcı düğümü yok" % tag)
	print("FLIGHTCHECK %s landmarks=%d forms=%d perches=%d noktalar_tamam=%d/%d halic_su=%s" % [tag, lms.size(), forms.size(),
		perches.size(), n_ok, spots.size(), IstGeo.su(hm.x, hm.y)])
