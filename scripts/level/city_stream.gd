class_name CityStream
extends Node3D
## Uçarak gezilen şehirlerin (Konstantinopolis, Galata) yakın ayrıntısı: şehir 64 m'lik hücrelere bölünür.
## Her hücrenin uzak görünümü baştan kurulur (MultiMesh ev kutuları: tek çizim, ucuz). Oyuncu bir hücreye
## LOAD_R kadar yaklaşınca o hücrenin gerçek binaları (taş zemin kat, çıkmalı ahşap üst katlar, pencereler ve
## kepenkler, balkonlar, dükkân önleri, kiremit çatılar, bacalar; Ceneviz evlerinde kemerli revak, sivri pencere,
## mazgallı dam; bahçelerde servi ve kuyu) WorkerThreadPool'da üretilir; ana iş parçacığı yalnız hazır diziyi
## ArrayMesh'e çevirir ve çarpışma kutularını ekler (oyun donmaz). Aynı anda tek hücre üretilir; DROP_R'den
## uzaklaşan hücre silinir, uzak görünüm geri gelir. Gece: ışıklı evlerin camları yanar.

const CELL := 64.0
const LOAD_R := 110.0
const DROP_R := 210.0

static var _mat: StandardMaterial3D
static var _glass: StandardMaterial3D

## Vector2i -> {lots, far, win, detail, center}
var cells: Dictionary = {}
var night := false
var _t := 0.0
var _task := -1
var _task_key := Vector2i.ZERO
var _result: Dictionary = {}
var _gen_lots: Array = []
## Yüklenen hücrelerin sokaklarına yerleşecek insanlar: [[hücre, konum, yön]] (her adımda bir kişi: takılma olmasın)
var _spawn: Array = []


static func key_of(p: Vector3) -> Vector2i:
	return Vector2i(floori(p.x / CELL), floori(p.z / CELL))


static func materials() -> void:
	if _mat == null:
		_mat = StandardMaterial3D.new()
		_mat.vertex_color_use_as_albedo = true
		_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		_mat.roughness = 0.9
		_glass = StandardMaterial3D.new()
		_glass.albedo_color = Color("2a2430")
		_glass.cull_mode = BaseMaterial3D.CULL_DISABLED
		_glass.emission_enabled = true
		_glass.emission = Color("ffb050")
	_glass.emission_energy_multiplier = 0.0


func _ready() -> void:
	materials()


## lot: {p (zemin merkezi), rot, w, d, floors, style ("byz"/"gen"/"garden"), tone, stone, tile, shutter, seed, lit}
func add_lot(lot: Dictionary) -> void:
	var k := key_of(lot.p)
	if not cells.has(k):
		cells[k] = {"lots": [], "far": null, "win": null, "detail": null,
			"center": Vector3((k.x + 0.5) * CELL, 0, (k.y + 0.5) * CELL)}
	cells[k].lots.append(lot)


## Bütün parseller eklendikten sonra: hücre başına uzak görünüm ve gece pencere noktaları.
func finish() -> void:
	var lamp := StandardMaterial3D.new()
	lamp.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lamp.albedo_color = Color("ffc870")
	var hm := Scenery.house_mesh()
	for k in cells:
		var cell: Dictionary = cells[k]
		var xf: Array = []
		var cols: Array = []
		var wins: Array = []
		for lot in cell.lots:
			if lot.style == "garden":
				continue
			var h: float = lot.floors * 3.0
			var b := Basis(Vector3.UP, lot.rot)
			xf.append(Transform3D(b * Basis.from_scale(Vector3(lot.w, h, lot.d)), lot.p + Vector3(0, -0.3, 0)))
			cols.append(lot.tone)
			if lot.lit:
				wins.append(Transform3D(b, lot.p + b * Vector3(0, h * 0.6, lot.d * 0.5 + 0.08)))
		if not xf.is_empty():
			cell.far = Scenery.scatter(self, hm, xf, cols)
		if not wins.is_empty():
			cell.win = Scenery.scatter(self, Scenery._boxm(Vector3(1.2, 1.0, 0.2)), wins, [], lamp)
			cell.win.visible = night


func set_night(on: bool) -> void:
	night = on
	materials()
	_glass.emission_energy_multiplier = 2.4 if on else 0.0
	for k in cells:
		var cell: Dictionary = cells[k]
		if cell.win:
			cell.win.visible = on and cell.detail == null


func _exit_tree() -> void:
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1


func _process(delta: float) -> void:
	_t -= delta
	if _t > 0.0:
		return
	_t = 0.2
	var pl := get_tree().get_first_node_in_group("player") as Node3D
	if pl == null:
		# Oyuncu yoksa (fragman, çekim) kameranın çevresi yüklenir
		pl = get_viewport().get_camera_3d()
	if pl == null:
		return
	var lp := to_local(pl.global_position)
	lp.y = 0.0
	if _task >= 0:
		if not WorkerThreadPool.is_task_completed(_task):
			return
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
		if cells.has(_task_key) and lp.distance_to(cells[_task_key].center) < DROP_R:
			_attach(_task_key)
	if not _spawn.is_empty():
		var s: Array = _spawn.pop_front()
		var c: Dictionary = cells.get(s[0], {})
		if not c.is_empty() and c.detail:
			_person(c.detail, s[1], s[2])
	# Uzaklaşan hücreleri boşalt
	for k in cells:
		var cell: Dictionary = cells[k]
		if cell.detail and lp.distance_to(cell.center) > DROP_R:
			cell.detail.queue_free()
			cell.detail = null
			if cell.far:
				cell.far.visible = true
			if cell.win:
				cell.win.visible = night
	# En yakın yüklenmemiş hücreyi üret
	var best = null
	var bd := LOAD_R
	for k in cells:
		var cell: Dictionary = cells[k]
		if cell.detail:
			continue
		var d := lp.distance_to(cell.center)
		if d < bd:
			bd = d
			best = k
	if best != null:
		_task_key = best
		_gen_lots = cells[best].lots
		_task = WorkerThreadPool.add_task(_generate, false, "city cell")


## Fragman ve çekimler için: dünya noktasının çevresindeki hücreleri hemen (eşzamanlı) yükler. Oyunda
## kullanılmaz (takılmaya yol açar); --write-movie sabit kare hızında sorun olmaz.
func force_load(world_pos: Vector3, r := LOAD_R) -> void:
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
		if cells.has(_task_key) and cells[_task_key].detail == null:
			_attach(_task_key)
	var lp := to_local(world_pos)
	lp.y = 0.0
	for k in cells:
		var cell: Dictionary = cells[k]
		if cell.detail == null and lp.distance_to(cell.center) < r:
			_gen_lots = cell.lots
			_generate()
			_attach(k)


## İş parçacığında: yalnız saf veri (MeshKit dizileri, çarpışma listeleri) üretir.
func _generate() -> void:
	var k := MeshKit.new()
	var g := MeshKit.new()
	var boxes: Array = []
	var hulls: Array = []
	for lot in _gen_lots:
		if lot.style == "garden":
			_garden(k, lot, boxes)
		else:
			house(k, g, lot, boxes, hulls)
	_result = {"main": k.arrays(), "glass": g.arrays() if not g.is_empty() else [], "boxes": boxes, "hulls": hulls}


func _attach(key: Vector2i) -> void:
	var r := _result
	_result = {}
	if r.is_empty():
		return
	var cell: Dictionary = cells[key]
	var node := Node3D.new()
	add_child(node)
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, r.main)
	am.surface_set_material(0, _mat)
	if not (r.glass as Array).is_empty():
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, r.glass)
		am.surface_set_material(1, _glass)
	var mi := MeshInstance3D.new()
	mi.mesh = am
	node.add_child(mi)
	var body := StaticBody3D.new()
	node.add_child(body)
	for b in r.boxes:
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = b[1]
		cs.shape = bs
		cs.transform = b[0]
		body.add_child(cs)
	for h in r.hulls:
		var cs := CollisionShape3D.new()
		var cp := ConvexPolygonShape3D.new()
		cp.points = h
		cs.shape = cp
		body.add_child(cs)
	cell.detail = node
	# Sokakta insanlar: kapı önlerinde (gece daha az)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(key)
	var n := 0
	for lot in cell.lots:
		if lot.style == "garden" or rng.randf() > (0.06 if night else 0.14) or n >= 4:
			continue
		var b := Basis(Vector3.UP, lot.rot)
		_spawn.append([key, lot.p + b * Vector3(rng.randf_range(-1.5, 1.5), 0.15, lot.d * 0.5 + (0.55 if lot.floors > 1 else 0.0) + 1.3), lot.rot + rng.randf_range(-1.0, 1.0)])
		n += 1
	if cell.far:
		cell.far.visible = false
	if cell.win:
		cell.win.visible = false


const PEOPLE := [
	{"coat": Color("6a3a5a"), "robe": Color("6a3a5a"), "skirt": true, "hair": Color("3a2a1e"), "skin": Color("e0b08a")},
	{"coat": Color("3a5a6a"), "robe": Color("3a5a6a"), "beard": true, "hat": "hood", "skin": Color("d9a07a")},
	{"coat": Color("a86a3a"), "pants": Color("5a4028"), "mustache": true, "skin": Color("c89070")},
	{"coat": Color("7a8a5a"), "robe": Color("7a8a5a"), "skirt": true, "hat": "bun", "hair": Color("5a3a1e"), "skin": Color("e8b894")},
	{"coat": Color("1e1e22"), "robe": Color("1e1e22"), "beard": true, "hat": "kamelaukion", "hair": Color("8a8a8a"), "skin": Color("e0b08a")},
	{"coat": Color("d8c8a8"), "robe": Color("d8c8a8"), "beard": true, "skin": Color("c89070")},
	{"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true, "skin": Color("d9a07a")},
]


func _person(parent: Node3D, p: Vector3, yaw: float) -> void:
	var pr := Person.new(PEOPLE[absi(hash(p)) % PEOPLE.size()])
	pr.position = p
	pr.rotation.y = yaw
	parent.add_child(pr)
	# Yokuşta kapı önü arsa merkezinden alçak ya da yüksek: yere (arazi çarpışmasına) oturt, havada durmasın
	var gp := pr.global_position
	var q := PhysicsRayQueryParameters3D.create(gp + Vector3(0, 2.0, 0), gp + Vector3(0, -4.0, 0), 1)
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty() or absf((hit["normal"] as Vector3).y) < 0.7:
		pr.queue_free()      # zemin yok ya da dik (duvar, çatı kenarı): kimseyi koyma
		return
	pr.global_position = hit["position"]


# ---------------------------------------------------------------- binalar (iş parçacığında)

const WOOD := Color("5a3a22")
const DARK := Color("2a2228")


static func _rot(axis: Vector3, ang: float) -> Transform3D:
	return Transform3D(Basis(axis, ang), Vector3.ZERO)


static func _at(xf: Transform3D, x: float, y: float, z: float) -> Transform3D:
	return xf.translated_local(Vector3(x, y, z))


## Tek ev. k: gövde, g: ışıklı camlar (gece yanar). boxes/hulls: çarpışma.
static func house(k: MeshKit, g: MeshKit, lot: Dictionary, boxes: Array, hulls: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = lot.seed
	var xf := Transform3D(Basis(Vector3.UP, lot.rot), lot.p)
	var w: float = lot.w
	var d: float = lot.d
	var fl: int = lot.floors
	var gen: bool = lot.style == "gen"
	var fh := 3.1 if gen else 2.9
	var H := fl * fh
	var stone: Color = lot.stone
	var tone: Color = lot.tone
	var j := 0.0 if gen or fl < 2 else 0.55     # çıkma (cumba): üst katlar sokağa taşar
	# Zemin kat ve temel (yamaçta toprağa gömülür)
	k.box(_at(xf, 0, (fh - 2.0) * 0.5, 0), Vector3(w, fh + 2.0, d), stone)
	boxes.append([_at(xf, 0, (fh - 2.0) * 0.5, 0), Vector3(w, fh + 2.0, d)])
	if fl > 1:
		var uh := H - fh
		var col := stone.lightened(0.06) if gen else tone
		k.box(_at(xf, 0, fh + uh * 0.5, j * 0.5), Vector3(w, uh, d + j), col)
		boxes.append([_at(xf, 0, fh + uh * 0.5, j * 0.5), Vector3(w, uh, d + j)])
		# Kat silmesi
		k.box(_at(xf, 0, fh, j * 0.5), Vector3(w + 0.12, 0.2, d + j + 0.12), stone.darkened(0.12))
		if not gen:
			# Ahşap karkas: dikmeler ve kat kirişleri (ön ve arka yüz)
			var nposts := maxi(2, int(w / 1.6))
			for side in [1, -1]:
				var fz: float = (d * 0.5 + (j if side > 0 else 0.0)) * side + 0.03 * side
				for i in nposts + 1:
					var px := -w * 0.5 + 0.07 + (w - 0.14) * i / nposts
					k.face(_at(xf, px, fh + uh * 0.5, fz) * _rot(Vector3.UP, 0.0 if side > 0 else PI), 0.14, uh, WOOD)
				for f in range(1, fl):
					k.face(_at(xf, 0, f * fh + 0.08, fz + 0.005 * side) * _rot(Vector3.UP, 0.0 if side > 0 else PI), w, 0.16, WOOD)
			# Çıkmanın altında eğik payandalar
			if j > 0.0:
				for i in 3:
					var px := -w * 0.5 + 0.3 + (w - 0.6) * i / 2.0
					k.box(_at(xf, px, fh - 0.3, d * 0.5 + j * 0.45) * _rot(Vector3.RIGHT, 0.7), Vector3(0.12, 0.8, 0.12), WOOD)
	# Pencereler: ön, arka ve yanlar
	var shutter: Color = lot.shutter
	for f in fl:
		var y := f * fh + (1.5 if f == 0 else 1.7)
		var fz := d * 0.5 + (j if f > 0 else 0.0)
		var nw := maxi(1, int(w / 2.4))
		for side in [1, -1]:
			for i in nw:
				var px := -w * 0.5 + w * (i + 0.5) / nw
				if f == 0 and side == 1 and absf(px) < 1.0:
					continue   # kapı
				_window(k, g, _at(xf, px, y, (fz if side > 0 else d * 0.5) * side), side, gen, shutter, lot.lit and f > 0 and rng.randf() < 0.6, rng)
		if f > 0 and w > 5.0 and rng.randf() < 0.6:
			for sx in [-1, 1]:
				var t := _at(xf, sx * (w * 0.5 + 0.02), y, 0) * _rot(Vector3.UP, PI * 0.5 * sx)
				_window(k, g, t, 1, gen, shutter, false, rng)
	# Kapı / dükkân / revak (ön yüz, zemin kat)
	var fz0 := d * 0.5
	if gen:
		# Kemerli revak: 2-3 açıklık, aralarda taş ayaklar
		var na := 3 if w > 6.5 else 2
		for i in na:
			var px := -w * 0.5 + w * (i + 0.5) / na
			var aw := w / na - 0.8
			k.box(_at(xf, px, 1.25, fz0 + 0.02), Vector3(aw, 2.5, 0.05), DARK)
			k.cyl(_at(xf, px, 2.5, fz0 + 0.02) * _rot(Vector3.RIGHT, PI * 0.5), aw * 0.5, 0.05, DARK, 10)
			k.cyl(_at(xf, px, 2.5, fz0) * _rot(Vector3.RIGHT, PI * 0.5), aw * 0.5 + 0.18, 0.05, stone.lightened(0.15), 10)
	elif rng.randf() < 0.3:
		# Dükkân: geniş açıklık, bez tente, önünde mallar
		var cloth: Color = [Color("b8402e"), Color("3a6a8a"), Color("c89a3a"), Color("5a7a3a"), Color("e8dcc0")][rng.randi() % 5]
		k.box(_at(xf, 0, 1.2, fz0 + 0.02), Vector3(w * 0.7, 2.2, 0.05), DARK)
		k.box(_at(xf, 0, 2.55, fz0 + 0.7) * _rot(Vector3.RIGHT, 0.35), Vector3(w * 0.75, 0.05, 1.5), cloth)
		for i in 3:
			var px := -w * 0.3 + i * w * 0.3
			k.box(_at(xf, px, 0.35, fz0 + 0.6), Vector3(0.7, 0.7, 0.6), [Color("8a6a44"), Color("c8a060"), Color("a05a3a")][i])
	else:
		k.box(_at(xf, 0, 1.1, fz0 + 0.02), Vector3(1.1, 2.2, 0.05), WOOD.darkened(0.2))
		k.box(_at(xf, 0, 2.3, fz0 + 0.04), Vector3(1.5, 0.25, 0.1), stone.lightened(0.12))
		if rng.randf() < 0.35:
			k.cyl(_at(xf, 1.1, 0, fz0 + 0.55), 0.32, 0.9, Color("6a4a2a"), 8)
	# Balkon
	if not gen and fl >= 2 and rng.randf() < 0.3:
		var by := fh + 0.1
		var bz := fz0 + j + 0.45
		k.box(_at(xf, 0, by, bz), Vector3(w * 0.55, 0.12, 0.9), WOOD)
		for i in 6:
			k.box(_at(xf, -w * 0.27 + w * 0.54 * i / 5.0, by + 0.5, bz + 0.42), Vector3(0.06, 0.9, 0.06), WOOD)
		k.box(_at(xf, 0, by + 0.95, bz + 0.42), Vector3(w * 0.55, 0.08, 0.08), WOOD)
	# Çatı
	var tile: Color = lot.tile
	var rz := j * 0.5
	var rs := Vector3(w + 0.7, minf(w, d + j) * 0.36, d + j + 0.7)
	var roll := rng.randf()
	if gen and roll < 0.5:
		# Düz dam ve mazgallı korkuluk
		k.box(_at(xf, 0, H + 0.1, rz), Vector3(w, 0.2, d + j), stone.darkened(0.1))
		var m := 0.0
		while m < w:
			for sz in [-1, 1]:
				k.box(_at(xf, -w * 0.5 + m + 0.35, H + 0.6, rz + sz * (d * 0.5 - 0.2)), Vector3(0.6, 0.8, 0.35), stone)
			m += 1.2
		m = 0.0
		while m < d:
			for sx in [-1, 1]:
				k.box(_at(xf, sx * (w * 0.5 - 0.2), H + 0.6, -d * 0.5 + m + 0.35), Vector3(0.35, 0.8, 0.6), stone)
			m += 1.2
	elif not gen and roll < 0.12:
		# Teras: düz dam, alçak korkuluk, asma çardağı
		k.box(_at(xf, 0, H + 0.1, rz), Vector3(w, 0.2, d + j), stone.darkened(0.08))
		for sx in [-1, 1]:
			k.box(_at(xf, sx * (w * 0.5 - 0.1), H + 0.45, rz), Vector3(0.2, 0.7, d + j), tone.darkened(0.1))
		for i in 4:
			k.box(_at(xf, -w * 0.3 + i * w * 0.2, H + 1.2, rz), Vector3(0.1, 2.2, 0.1), WOOD)
		k.box(_at(xf, 0, H + 2.3, rz), Vector3(w * 0.7, 0.3, (d + j) * 0.6), Color("4a6a32"))
	else:
		var rt := _at(xf, 0, H, rz)
		if roll < 0.75:
			k.gable(rt, rs, tile)
		else:
			k.hip(rt, rs, tile)
		# Saçak altı
		k.box(_at(xf, 0, H - 0.08, rz), Vector3(w + 0.72, 0.16, d + j + 0.72), tile.darkened(0.3))
		var pts := PackedVector3Array()
		for p in [Vector3(-rs.x * 0.5, 0, -rs.z * 0.5), Vector3(rs.x * 0.5, 0, -rs.z * 0.5), Vector3(rs.x * 0.5, 0, rs.z * 0.5),
				Vector3(-rs.x * 0.5, 0, rs.z * 0.5), Vector3(-rs.x * 0.5, rs.y, 0), Vector3(rs.x * 0.5, rs.y, 0)]:
			pts.append(rt * p)
		hulls.append(pts)
		if rng.randf() < 0.45:
			k.box(_at(xf, w * rng.randf_range(-0.3, 0.3), H + rs.y * 0.7, rz - d * 0.2), Vector3(0.5, 1.6, 0.5), stone.darkened(0.15))


static func _window(k: MeshKit, g: MeshKit, t: Transform3D, side: int, gen: bool, shutter: Color, lit: bool, rng: RandomNumberGenerator) -> void:
	var face := _rot(Vector3.UP, 0.0 if side > 0 else PI)
	var tt := t * face
	var m := g if lit else k
	if gen:
		# Sivri kemerli pencere, taş söve ve ince orta dikme
		k.face(tt.translated_local(Vector3(0, 0.05, 0.02)), 1.0, 1.6, Color("e0d4bc"))
		m.face(tt.translated_local(Vector3(0, 0, 0.04)), 0.75, 1.3, DARK)
		m.face(tt.translated_local(Vector3(0, 0.65, 0.04)) * _rot(Vector3.BACK, PI * 0.25), 0.53, 0.53, DARK)
		k.face(tt.translated_local(Vector3(0, 0.05, 0.06)), 0.07, 1.3, Color("e0d4bc"))
	else:
		m.face(tt.translated_local(Vector3(0, 0, 0.03)), 0.7, 1.0, DARK)
		k.box(tt.translated_local(Vector3(0, -0.56, 0.08)), Vector3(0.9, 0.08, 0.16), Color("d8ccb4"))
		if rng.randf() < 0.8:
			for sx in [-1, 1]:
				k.face(tt.translated_local(Vector3(sx * 0.58, 0, 0.05)), 0.38, 1.02, shutter)


static func _garden(k: MeshKit, lot: Dictionary, boxes: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = lot.seed
	var xf := Transform3D(Basis(Vector3.UP, lot.rot), lot.p)
	var w: float = lot.w
	var d: float = lot.d
	var wall: Color = lot.stone
	for sz in [-1, 1]:
		k.box(_at(xf, 0, 0.6, sz * d * 0.5), Vector3(w, 1.6, 0.4), wall)
		boxes.append([_at(xf, 0, 0.6, sz * d * 0.5), Vector3(w, 1.6, 0.4)])
		k.box(_at(xf, sz * w * 0.5, 0.6, 0), Vector3(0.4, 1.6, d), wall)
		boxes.append([_at(xf, sz * w * 0.5, 0.6, 0), Vector3(0.4, 1.6, d)])
	k.box(_at(xf, 0, 0.05, 0), Vector3(w - 0.4, 0.1, d - 0.4), Color("5a7a3a"))
	for i in rng.randi_range(2, 4):
		var p := _at(xf, rng.randf_range(-w * 0.35, w * 0.35), 0, rng.randf_range(-d * 0.35, d * 0.35))
		if rng.randf() < 0.6:
			k.cyl(p, 0.6, 7.5, Color("2e4a2a"), 7, 0.05)
		else:
			k.cyl(p, 0.18, 2.2, WOOD, 6)
			k.dome(p.translated_local(Vector3(0, 2.0, 0)), 1.8, Color("4a7a32"), 1.2, 8, 3)
	if rng.randf() < 0.5:
		var c := _at(xf, 0, 0, 0)
		k.cyl(c, 0.9, 0.9, wall.lightened(0.1), 12)
		k.cyl(c.translated_local(Vector3(0, 0.88, 0)), 0.7, 0.05, Color("1e2a34"), 12)
		for sx in [-1, 1]:
			k.box(c.translated_local(Vector3(sx * 0.8, 1.5, 0)), Vector3(0.1, 1.3, 0.1), WOOD)
		k.box(c.translated_local(Vector3(0, 2.15, 0)), Vector3(1.8, 0.12, 0.12), WOOD)
