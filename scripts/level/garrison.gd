class_name Garrison
extends RefCounted
## Bizans garnizonu: surun üstünde nöbetçiler, kule tepelerinde gözcüler, peribolosta ateş başında dinlenen ve
## sırada bekleyen yedekler. Oyuncunun yakınındakiler canlı Person (miğferli; mızrak, yay, kalkan), uzaktakiler tek
## MultiMesh (Assault.defender_mesh). Hiçbiri konuşmaz. Kökler "garrison" grubundadır: fetihten sonra gizlenir.

const COATS := [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96"), Color("4a3a2e"), Color("6a5a48"), Color("3a4a6a")]
const ARMS := ["spear", "bow", "spear_shield", "spear", "bow", ""]


## Tek savunucu. yaw: +Z'den (karakterin önü) dönüş.
static func man(parent: Node3D, pos: Vector3, yaw: float, i: int, arm := "spear", act := "") -> Person:
	var d := Person.new({"coat": COATS[i % COATS.size()], "pants": [Color("3a2a22"), Color("2a2a30"), Color("4a3a2a")][i % 3],
		"hat": "helm", "beard": i % 3 != 1, "mustache": i % 2 == 0, "n": i})
	d.set_meta("no_talk", true)
	d.set_meta("garrison", true)
	d.position = pos
	d.rotation.y = yaw
	parent.add_child(d)
	if arm != "":
		d.equip(arm, COATS[(i + 2) % COATS.size()])
	if act != "":
		d.set_activity(act)
	# Dış surdaki (ovaya bakan) canlı okçu gerçekten atar: yayı gerer, nişan alır, oku bırakır
	if arm == "bow" and pos.z > 10.0 and pos.y > 5.0:
		d.add_child(preload("res://scripts/npc/archer_loop.gd").new())
	return d


static func _root(parent: Node3D, name: String) -> Node3D:
	var r := Node3D.new()
	r.name = name
	r.add_to_group("garrison")
	parent.add_child(r)
	return r


static func _in(x: float, ranges: Array) -> bool:
	for r: Vector2 in ranges:
		if x >= r.x and x <= r.y:
			return true
	return false


## Kara surlarının garnizonu (LandWalls düzeni). skip: dış sur yürüyüş yolunda kimsenin durmayacağı x aralıkları
## (oyuncunun alanı); near: bu x aralıklarındakiler canlı Person (dış yol, dış kule tepeleri), gerisi MultiMesh.
## inner_near: iç sur üstünde canlı Person olacak x aralıkları (yoksa hepsi MultiMesh).
## span: dış surda |x| < span olanlar (Assault kendi uzak savunanlarını koyduğunda dar tutulur); inner: iç sur sırası.
static func land_walls(parent: Node3D, skip: Array, near: Array, inner_near: Array = [], seed := 20, span := 47.0, inner := true) -> Node3D:
	var root := _root(parent, "Garrison")
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var far: Array = []
	var cols: Array = []
	var i := 0
	var half := LandWalls.BREACH_W * 0.5 + LandWalls.EDGE_W + 1.0
	# Dış sur yürüyüş yolu (y 8, mazgalların ardında), sahaya (+Z) bakar; kuleler (x ±16) ve gedik boş
	for sx: float in [-1.0, 1.0]:
		var x := sx * (half + rng.randf_range(0.0, 1.0))
		while absf(x) < span:
			if not _in(x, skip) and absf(absf(x) - 16.0) > 3.3:
				var p := Vector3(x, LandWalls.OUTER_H, 14.72 + rng.randf_range(-0.08, 0.08))
				var yaw := rng.randf_range(-0.35, 0.35)
				if _in(x, near):
					man(root, p, yaw, i + seed, ARMS[i % ARMS.size()])
				else:
					far.append(Transform3D(Basis(Vector3.UP, yaw), p))
					cols.append(COATS[rng.randi() % COATS.size()])
				i += 1
			x += sx * rng.randf_range(1.8, 2.9)
		# Dış kule tepesi (y 11): iki gözcü
		var tx := sx * 16.0
		for k in 2:
			var p := Vector3(tx - 1.2 + k * 2.4, LandWalls.OUTER_H + 3.0, LandWalls.OUTER_Z1 + 1.6)
			if _in(p.x, skip):
				continue
			if _in(p.x, near):
				man(root, p, rng.randf_range(-0.3, 0.3), i + seed, ["bow", "spear"][k])
			else:
				far.append(Transform3D(Basis(Vector3.UP, rng.randf_range(-0.3, 0.3)), p))
				cols.append(COATS[rng.randi() % COATS.size()])
			i += 1
	# İç sur üstü (y 12): daha seyrek; iç kuleler (x ±24) üstünde (y 18) ikişer gözcü
	var xi := -46.0 + rng.randf_range(0.0, 2.0)
	while inner and xi < 47.0:
		if absf(absf(xi) - 24.0) > 5.2:
			var p := Vector3(xi, LandWalls.INNER_H, -2.1 + rng.randf_range(-0.1, 0.1))
			var yaw := rng.randf_range(-0.3, 0.3)
			if _in(xi, inner_near):
				man(root, p, yaw, i + seed, ARMS[i % ARMS.size()])
			else:
				far.append(Transform3D(Basis(Vector3.UP, yaw), p))
				cols.append(COATS[rng.randi() % COATS.size()])
			i += 1
		xi += rng.randf_range(2.4, 3.8)
	for tx: float in ([-24.0, 24.0] if inner else []):
		for k in 2:
			far.append(Transform3D(Basis(Vector3.UP, rng.randf_range(-0.3, 0.3)), Vector3(tx - 1.5 + k * 3.0, LandWalls.INNER_H + 6.0, 1.8)))
			cols.append(COATS[rng.randi() % COATS.size()])
	far_men(root, far, cols)
	return root


## Uzaktaki savunanlar: gerçek savunan modelinin kopyaları (Crowd; 150 m ötesi siluet).
static func far_men(parent: Node3D, xforms: Array, cols: Array) -> Array:
	var items: Array = []
	for i in xforms.size():
		var arm: String = ["spear_shield", "bow", "spear"][i % 3]
		var o: Vector3 = (xforms[i] as Transform3D).origin
		items.append([xforms[i], {"side": "B", "coat": cols[i % cols.size()], "arm": arm, "pose": "aim" if arm == "bow" and o.z > 10.0 and o.y > 5.0 else ""}])
	return Crowd.place(parent, items)


## Ateş başı: ortada ateş (gece; ışığı döndürür) ya da sönmüş kül (gündüz); çevresinde bağdaş kurmuş askerler,
## biri ayakta nöbette (mızraklı). Kök "garrison" grubunda.
static func fire_ring(parent: Node3D, c: Vector3, n: int, seed: int, lit := true) -> OmniLight3D:
	var root := _root(parent, "FireRing")
	var light: OmniLight3D = null
	if lit:
		light = Night.campfire(root, c, 0.8)
	else:
		Props.cyl(root, 0.55, 0.1, c + Vector3(0, 0.05, 0), Color("3a3430"), Vector3.ZERO, 10)
		for k in 3:
			Props.cyl(root, 0.05, 0.7, c + Vector3(0, 0.1, 0), Color("2a2018"), Vector3(80, k * 60, 0), 5)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var a0 := rng.randf() * TAU
	for k in n:
		var a := a0 + TAU * k / n + rng.randf_range(-0.15, 0.15)
		var r := rng.randf_range(1.35, 1.6)
		var p := c + Vector3(sin(a), 0, cos(a)) * r
		var standing := k == 0
		if standing:
			p = c + Vector3(sin(a), 0, cos(a)) * 2.1
		var d := man(root, p, a if standing else a + PI, seed + k, "spear" if standing else "", "" if standing else "sit_ground")
		if not standing and k % 3 == 1:
			# Mızrağı yanında yere yatırılmış
			var sp := p + Vector3(sin(a + 0.6), 0, cos(a + 0.6)) * 0.55
			Props.cyl(root, 0.022, 2.5, sp + Vector3(0, 0.05, 0), Color("6a4a2c"), Vector3(90, rad_to_deg(a + 0.6 + PI * 0.5), 0), 5)
		d.set_meta("fire_ring", true)
	return light


## Sırada bekleyen yedek bölük: cols x rows, yaw yönüne bakar; mızrak ve kalkanlı.
static func squad(parent: Node3D, c: Vector3, cols: int, rows: int, yaw: float, seed: int, arm := "spear_shield") -> Node3D:
	var root := _root(parent, "Squad")
	var b := Basis(Vector3.UP, yaw)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var k := 0
	for j in rows:
		for i in cols:
			var lp := Vector3((i - (cols - 1) * 0.5) * 1.1 + rng.randf_range(-0.08, 0.08), 0, -j * 1.2 + rng.randf_range(-0.08, 0.08))
			man(root, c + b * lp, yaw + rng.randf_range(-0.12, 0.12), seed + k, arm)
			k += 1
	return root


## Bütün garnizonu kaldırır (fetih: surda Bizans askeri kalmaz).
static func clear(tree: SceneTree) -> void:
	for n in tree.get_nodes_in_group("garrison"):
		n.queue_free()
	# Peribolostaki savaş kalabalığı (BattleExtras: koşanlar, yatanlar, enkaz) da kalkar: şehir düştü
	for n in tree.get_nodes_in_group("battle_extras"):
		n.queue_free()
