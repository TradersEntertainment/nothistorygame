extends Node
## Tek İstanbul haritası (World1453) denetimi. Her bölge için: dönüşüm yalnız dönme + öteleme mi, yer işaretleri
## gidiş-dönüşte aynı noktaya mı düşüyor, bölge orijini doğru yerde mi (Haliç bölgeleri suda, ötekiler karada);
## bölümler arası hizalar: Galata Kulesi, otağ, Ayasofya, iç sur. Sonuç: WORLDCHECK PASS/FAIL.

const WATER_REGIONS := ["horn_bridge", "horn_wall_o", "horn_chain"]
var ok := true


func _ready() -> void:
	for name: String in World1453.REGIONS:
		var xf := World1453.region(name)
		var b := xf.basis
		if absf(b.determinant() - 1.0) > 1e-4 or not b.is_equal_approx(b.orthonormalized()):
			_fail("%s: dönüşüm dönme değil (det %.3f)" % [name, b.determinant()])
		for key: String in World1453.LANDMARKS:
			var w: Vector3 = World1453.LANDMARKS[key]
			var back := World1453.to_world(name, World1453.landmark_local(name, key))
			if back.distance_to(w) > 0.01:
				_fail("%s: %s gidiş-dönüş %s ≠ %s" % [name, key, back, w])
		# Haliç bölgeleri kıyıya oturur: yerel +z'de 30 m açık su olmalı; kara bölgelerinin orijini karada
		if name in WATER_REGIONS:
			var q := World1453.to_world(name, Vector3(0, 0, 30.0))
			if not World1453.is_water(q.x, q.z):
				_fail("%s: kıyının önü su değil (%s)" % [name, q])
		elif not (name in ["galata", "springs", "eyup"]) and World1453.is_water(xf.origin.x, xf.origin.z):
			_fail("%s: orijin suda (%s)" % [name, xf.origin])
	# Yer işaretleri doğru yüzeyde
	for key: String in ["ayasofya", "hippodrome", "column", "great_palace", "petrion_gate"]:
		var p: Vector3 = World1453.LANDMARKS[key]
		if key != "petrion_gate" and not World1453.in_city(p.x, p.z, 10.0):
			_fail("%s şehrin dışında (%s)" % [key, p])
	for key: String in ["galata_tower", "galata_center", "springs"]:
		var p: Vector3 = World1453.LANDMARKS[key]
		if World1453.is_water(p.x, p.z) or World1453.in_city(p.x, p.z):
			_fail("%s kuzey kıyıda değil (%s)" % [key, p])
	# Bölümler arası hizalar (bölgenin yerel koordinatı → dünyanın aynı noktası)
	_same("galata", Vector3(8.0, 0, -58.0), World1453.LANDMARKS["galata_tower"], "Galata Kulesi (27)")
	_same("camp", Vector3(0.0, 0, -62.0), Vector3(30.0, 0, 480.0), "otağ (ordugâh)")
	_same("byz_aya", ByzCity.AYA, World1453.LANDMARKS["ayasofya"], "Ayasofya (24-26, 31o)")
	var wz := World1453.to_world("byz_walls", Vector3(34.0, 0, -10.0)).z
	if absf(wz - (LandWalls.INNER_Z0 + LandWalls.INNER_Z1) * 0.5) > 0.05:
		_fail("ByzCity iç suru dünyanın iç surunda değil (z %.2f)" % wz)
	var gx := World1453.to_world("byz_walls", Vector3(31.0, 0, 5.5)).x
	if absf(gx) > 0.5:
		_fail("Romanos Kapısı x 0'da değil (%.2f)" % gx)
	_same("petrion", Vector3(0, 0, Petrion.GATE_Z + 1.5), Vector3(World1453.HORN_S_X, 0, -650.0), "Petrion kapısı (39o)")
	print("WORLDCHECK %s regions=%d landmarks=%d" % ["PASS" if ok else "FAIL", World1453.REGIONS.size(), World1453.LANDMARKS.size()])
	get_tree().quit()


func _same(region: String, local: Vector3, world: Vector3, what: String) -> void:
	var w := World1453.to_world(region, local)
	if Vector2(w.x - world.x, w.z - world.z).length() > 0.5:
		_fail("%s: %s → %s (beklenen %s)" % [what, local, w, world])


func _fail(msg: String) -> void:
	ok = false
	printerr("WORLDCHECK " + msg)
