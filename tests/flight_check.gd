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
	print("FLIGHTCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit()


func _check(hub: String, h: Node3D, world: SiegeField) -> void:
	var lms: Array = h.call("world_landmarks")
	var forms: Array = h.call("world_forms")
	var perches: Array = h.call("world_perches")
	if lms.size() != NihatPowers.LANDMARK_IDS.size():
		_fail("%s: %d yer işareti (beklenen %d)" % [hub, lms.size(), NihatPowers.LANDMARK_IDS.size()])
	for l: Array in lms:
		if not (l[0] in NihatPowers.LANDMARK_IDS):
			_fail("%s: bilinmeyen yer işareti %s" % [hub, l[0]])
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
