class_name SiegeTower
extends RefCounted
## Kuşatma kulesi (Bölüm 22, 18 Mayıs 1453): üç katlı tahta iskelet, ıslak deri kaplama, tepede asma köprü,
## altında tekerlekler; önüne yuvarlanan barut fıçısıyla tutuşur.


## Kuşatma kulesi: üç katlı tahta iskelet, ıslak deri kaplama, tepede asma köprü, altında tekerlekler.
static func build(parent: Node3D, pos: Vector3) -> Node3D:
	var tower := Node3D.new()
	tower.position = pos
	parent.add_child(tower)
	var wood := Color("4a3220")
	for sx: float in [-2.2, 2.2]:
		for sz: float in [-2.2, 2.2]:
			Props.cyl(tower, 0.2, 14.0, Vector3(sx, 7.0, sz), wood, Vector3.ZERO, 6)
	for y: float in [0.8, 5.0, 9.2, 13.4]:
		Props.box(tower, Vector3(4.8, 0.3, 4.8), Vector3(0, y, 0), wood.darkened(0.1))
	for li in 3:
		var y: float = [3.0, 7.2, 11.4][li]
		# Islak deri kaplama: üst üste binen parçalar (düz levha değil); ön yüzde okçu mazgalları
		SiegeField.hide_panel(tower, Vector3(0, y, -2.35), 4.7, 3.8, false, 221 + li)
		for sx: float in [-1.0, 1.0]:
			SiegeField.hide_panel(tower, Vector3(sx * 2.35, y, 0), 4.7, 3.8, true, 231 + li * 2 + int(sx))
		for k in 2:
			Props.box(tower, Vector3(0.3, 0.8, 0.05), Vector3(-1.2 + k * 2.4, y + 0.6, -2.45), Color("140f0b"))
	for y: float in [3.0, 7.2, 11.4]:
		for d: float in [-35.0, 35.0]:
			Props.box(tower, Vector3(0.18, 5.2, 0.14), Vector3(0, y, -2.45), wood.lightened(0.1), Vector3(0, 0, d))
	Props.box(tower, Vector3(3.0, 0.15, 3.4), Vector3(0, 14.2, -3.4), wood, Vector3(-70, 0, 0))
	# Tepede hasır korkuluk (okçuların siperi) ve asma köprünün zincirleri
	for sx: float in [-1.0, 1.0]:
		Props.box(tower, Vector3(0.1, 1.2, 4.6), Vector3(sx * 2.3, 14.2, 0), Color("8a6a40"))
		Props.cyl(tower, 0.025, 3.6, Vector3(sx * 1.3, 15.4, -1.9), Color("3a3a40"), Vector3(-40, 0, 0), 4)
	Props.box(tower, Vector3(4.6, 1.2, 0.1), Vector3(0, 14.2, 2.3), Color("8a6a40"))
	for sx: float in [-1.9, 1.9]:
		for sz: float in [-1.9, 1.9]:
			Props.cyl(tower, 0.6, 0.3, Vector3(sx, 0.6, sz), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	Props.box(tower, Vector3(0.05, 1.2, 1.8), Vector3(0.6, 15.6, 0), Color("b3262d"))
	Props.cyl(tower, 0.04, 2.6, Vector3(0.6, 15.0, -0.9), wood, Vector3.ZERO, 4)
	var _fire_light := OmniLight3D.new()
	_fire_light.name = "FireLight"
	_fire_light.position = Vector3(0, 4.0, -2.8)
	_fire_light.light_color = Color("ff8a3a")
	_fire_light.light_energy = 0.0
	_fire_light.omni_range = 40.0
	tower.add_child(_fire_light)
	return tower


## Kuleye ateş: her isabette alevler büyür (level 1..3). Alev düğümlerini döndürür.
static func burn(tower: Node3D, level: int) -> Array[Node3D]:
	var out: Array[Node3D] = []
	for i in 4 * level:
		var f := Props.cyl(tower, randf_range(0.4, 0.9), randf_range(1.2, 2.6), Vector3(randf_range(-2.2, 2.2), randf_range(0.8, 5.0 + level * 4.0), randf_range(-2.4, -1.6)), Color("ffa030"), Vector3.ZERO, 6, 0.05, 3.0)
		f.material_override = Props.mat(Color("ff9a30"), 3.5, false, "", false)
		out.append(f)
	var l := tower.get_node_or_null("FireLight") as OmniLight3D
	if l:
		l.light_energy = 3.0 + level * 4.0
	return out
