class_name Blades
extends RefCounted
## Kılıç ve kalkan modelleri. Kabza orijinde, namlu +Y yönünde (el onu tutar).
##   kilij: Osmanlı kılıcı (ucu kıvrık, yelmanlı) · spathion: Bizans düz kılıcı (haç balçak) · shield: yuvarlak kalkan

const STEEL := Color("c9ced6")


static func kilij(parent: Node3D) -> Node3D:
	var s := Node3D.new()
	parent.add_child(s)
	Props.cyl(s, 0.022, 0.16, Vector3(0, -0.02, 0), Color("3a2418"), Vector3.ZERO, 6)
	Props.ball(s, 0.03, Vector3(0, -0.11, 0), Color("c8a040"), Vector3(1, 0.8, 1), 6)
	Props.box(s, Vector3(0.16, 0.025, 0.04), Vector3(0, 0.07, 0), Color("c8a040"))
	# Kıvrık namlu: uca doğru öne eğilen dilimler, son dilim yelman (genişler)
	var y := 0.08
	var z := 0.0
	for i in 6:
		var h := 0.13
		var a := 3.0 + i * 3.2
		Props.box(s, Vector3(0.012, h, 0.045 if i < 5 else 0.06), Vector3(0, y + h * 0.5, z), STEEL, Vector3(-a, 0, 0))
		y += h * cos(deg_to_rad(a))
		z += h * sin(deg_to_rad(a))
	return s


static func spathion(parent: Node3D) -> Node3D:
	var s := Node3D.new()
	parent.add_child(s)
	Props.cyl(s, 0.022, 0.15, Vector3(0, -0.02, 0), Color("4a2e1c"), Vector3.ZERO, 6)
	Props.ball(s, 0.035, Vector3(0, -0.11, 0), Color("b8b0a0"), Vector3.ONE, 6)
	Props.box(s, Vector3(0.24, 0.03, 0.04), Vector3(0, 0.07, 0), Color("b8b0a0"))
	Props.box(s, Vector3(0.012, 0.74, 0.05), Vector3(0, 0.45, 0), STEEL)
	Props.box(s, Vector3(0.012, 0.08, 0.03), Vector3(0, 0.85, 0), STEEL, Vector3(0, 0, 0))
	return s


static func shield(parent: Node3D, color: Color, boss := Color("c8a040")) -> Node3D:
	var s := Node3D.new()
	parent.add_child(s)
	Props.cyl(s, 0.3, 0.04, Vector3.ZERO, color, Vector3(90, 0, 0), 14)
	Props.cyl(s, 0.31, 0.02, Vector3(0, 0, -0.005), color.darkened(0.35), Vector3(90, 0, 0), 14)
	Props.ball(s, 0.07, Vector3(0, 0, 0.03), boss, Vector3(1, 1, 0.6), 8)
	return s


## Hikmet Amca'nın babadan kalma çiftesi (av tüfeği): dipçik orijinde, iki namlu +Y yönünde. Boy ~1.1 m.
static func shotgun(parent: Node3D) -> Node3D:
	var s := Node3D.new()
	parent.add_child(s)
	var wood := Color("7a4a26")
	var metal := Color("3a3c42")
	Props.box(s, Vector3(0.05, 0.34, 0.12), Vector3(0, 0.17, -0.01), wood, Vector3(-6, 0, 0))    # dipçik
	Props.box(s, Vector3(0.045, 0.14, 0.06), Vector3(0, 0.39, 0.03), wood.darkened(0.15))      # kabza
	Props.box(s, Vector3(0.06, 0.12, 0.07), Vector3(0, 0.51, 0.045), metal.lightened(0.2))     # kilit
	Props.box(s, Vector3(0.012, 0.06, 0.05), Vector3(0, 0.46, -0.02), metal)                   # tetik korkuluğu
	for sx: float in [-0.013, 0.013]:
		Props.cyl(s, 0.013, 0.6, Vector3(sx, 0.87, 0.06), metal, Vector3.ZERO, 6)            # iki namlu
	Props.box(s, Vector3(0.04, 0.22, 0.03), Vector3(0, 0.68, 0.035), wood)                     # ön kundak
	return s
