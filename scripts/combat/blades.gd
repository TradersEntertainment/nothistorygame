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
	# Kıvrık namlu: uca doğru öne eğilen dilimler, son dilim yelman (genişler). Her dilim kendi doğrultusunda
	# (eğrinin gittiği yana) yatar, ortası dilimin ortasındadır; uçlar hafif bindirilir (yandan bakınca kesintisiz yay;
	# önceden dilimler ters yana yatıyordu: namlu şimşek gibi zikzak görünüyordu)
	var y := 0.08
	var z := 0.0
	for i in 6:
		var h := 0.13
		var a := 3.0 + i * 3.2
		var r := deg_to_rad(a)
		Props.box(s, Vector3(0.012, h * 1.06, 0.045 if i < 5 else 0.06), Vector3(0, y + h * 0.5 * cos(r), z + h * 0.5 * sin(r)),
			STEEL, Vector3(a, 0, 0))
		y += h * cos(r)
		z += h * sin(r)
	return s


## Türk yayı (kısa, kasanları öne kıvrık): kabza orijinde, kollar ±Y, kiriş -Z yanında (okçuya dönük), uçlar kirişe
## oturur. Parçalar `b`nin içine eklenir (çağıran "Bow" düğümünü kendisi kurar). Dilimler eğrinin teğetine yatar; eskiden
## açı teğetin üç katıydı (yay taraklı görünüyordu), kiriş uçlardan 11 cm taşıyordu, kollar kirişten uzağa bükülüyordu.
static func bow_parts(b: Node3D, wood := Color("5a3a22")) -> void:
	var pts: Array[Vector2] = [Vector2(-0.46, -0.055), Vector2(-0.41, -0.085), Vector2(-0.3, -0.065), Vector2(-0.15, -0.022),
		Vector2(0.0, 0.0), Vector2(0.15, -0.022), Vector2(0.3, -0.065), Vector2(0.41, -0.085), Vector2(0.46, -0.055)]
	for i in pts.size() - 1:
		var p: Vector2 = pts[i]
		var q: Vector2 = pts[i + 1]
		var d := q - p
		var grip := i == 3 or i == 4
		Props.box(b, Vector3(0.034 if grip else 0.026, d.length() * 1.1, 0.034 if grip else 0.024), Vector3(0, (p.x + q.x) * 0.5, (p.y + q.y) * 0.5),
			wood.darkened(0.15) if grip else wood, Vector3(rad_to_deg(atan2(d.y, d.x)), 0, 0))
	Props.box(b, Vector3(0.042, 0.1, 0.042), Vector3(0, 0, -0.004), Color("3a2418"))
	Props.box(b, Vector3(0.006, 0.92, 0.006), Vector3(0, 0, -0.055), Color("e8e0cc"))


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
