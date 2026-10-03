class_name NightArmy
extends Node3D
## Gece hücumunun ovası (Bölüm 30/30o, Blakherna; başka sur önlerine de konabilir): sahnenin "büyük gece hücumu"
## olarak okunması için oynanış alanının ötesini dolduran ordu.
##   · bölükler: sancaklı, mızraklı ve kalkanlı asker blokları (8–12 × 4–6), her birinde meşaleler
##   · dalgalar: sura koşan askerler (iki adım pozu arasında; beşte birinin elinde meşale), sura varınca arkadan
##     yeniden başlar
##   · arkada büyük ateşler ve mehter (davul, zurna) halkası
## Koordinatlar ebeveynin yereli: sur x boyunca, dış yüzü z = wall_z, ova +z. field: kalabalığın kurulacağı alan
## (x, z dikdörtgeni). skip: koşanların girmeyeceği x şeritleri (bölümün kendi merdiveni). ground: Callable(x, z) → y.

var field := Rect2(-60.0, 30.0, 120.0, 90.0)
var wall_z := 4.6
var skip: Array = []
var skip_w := 7.0
var ground: Callable = func(_x: float, _z: float) -> float: return 0.0
var blocks := 10
var runners := 120
var seed_value := 1205
var rng := RandomNumberGenerator.new()

const COATS := [Color("d8cfb8"), Color("8a3a2e"), Color("6a5a48"), Color("3e4c68"), Color("b3262d"), Color("2e6a3a")]
const HATS := ["bork", "bork", "turban", "helmet", "bork", "turban"]

var _run: Array = []          # [from, to, speed, phase(0..1)]
var _sets: Array = []         # [[mm_a, mm_b], [indeks]]
var _flames: MultiMesh
var _flame_of := {}           # koşan → meşale örneği
var _hidden := Transform3D(Basis.from_scale(Vector3.ONE * 0.001), Vector3(0, -200, 0))
var _lights: Array = []
var _t := 0.0


func build() -> void:
	rng.seed = seed_value
	_blocks()
	_runners()
	_fires()


func _free_x(x: float, w := 0.0) -> bool:
	for sx: float in skip:
		if absf(x - sx) < skip_w + w:
			return false
	return true


func _blocks() -> void:
	var items: Array = []
	var d := Dressing.new(seed_value + 1)
	d.chunk = 120.0
	var placed: Array = []
	var tries := 0
	while placed.size() < blocks and tries < blocks * 30:
		tries += 1
		var c := Vector3(rng.randf_range(field.position.x + 8.0, field.end.x - 8.0), 0, rng.randf_range(field.position.y + 14.0, field.end.y - 6.0))
		var clash := false
		for q: Vector3 in placed:
			if absf(q.x - c.x) < 18.0 and absf(q.z - c.z) < 12.0:
				clash = true
		if clash or not _free_x(c.x, 9.0) and c.z < field.position.y + 30.0:
			continue
		placed.append(c)
		var cols := rng.randi_range(8, 12)
		var rows := rng.randi_range(4, 6)
		var k := rng.randi() % COATS.size()
		var arm: String = ["spear", "spear", "sword_shield", "bow"][rng.randi() % 4]
		for i in cols:
			for j in rows:
				var p := c + Vector3((i - (cols - 1) * 0.5) * 1.5 + rng.randf_range(-0.2, 0.2), 0, (j - (rows - 1) * 0.5) * 1.5 + rng.randf_range(-0.2, 0.2))
				p.y = ground.call(p.x, p.z)
				items.append([Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.15, 0.15)), p),
					{"side": "O", "coat": COATS[(k + (j % 2)) % COATS.size()], "hat": HATS[k], "arm": arm}])
		# Sancak ve iki meşale (önde)
		var fp := c + Vector3(cols * 0.75 + 0.6, 0, -(rows - 1) * 0.75)
		fp.y = ground.call(fp.x, fp.z)
		d.cyl(0.05, 6.0, fp + Vector3(0, 3.0, 0), Color("4a3420"), Vector3.ZERO, 5)
		d.ball(0.13, fp + Vector3(0, 6.1, 0), Color("d8b040"))
		d.box(Vector3(0.03, 1.6, 2.4), fp + Vector3(0, 5.0, 1.2), [Color("b3262d"), Color("2e6a3a"), Color("f0ece0"), Color("c98a3a")][rng.randi() % 4])
		for s: float in [-1.0, 1.0]:
			var tp := c + Vector3(s * cols * 0.6, 0, -(rows - 1) * 0.75 - 1.2)
			tp.y = ground.call(tp.x, tp.z)
			d.cyl(0.04, 2.2, tp + Vector3(0, 1.1, 0), Color("4a3020"), Vector3.ZERO, 5)
			d.glow(Vector3(0.35, 0.55, 0.35), tp + Vector3(0, 2.4, 0), Color("ffb040"))
		if _lights.size() < 8:
			var l := OmniLight3D.new()
			l.light_color = Color("ff9a40")
			l.light_energy = 2.2
			l.omni_range = 16.0
			l.position = c + Vector3(0, 3.0, -(rows - 1) * 0.75)
			l.position.y += ground.call(c.x, c.z)
			add_child(l)
			_lights.append(l)
	Crowd.place(self, items)
	d.build(self)


func _runners() -> void:
	var groups := {}
	for i in runners:
		var x := rng.randf_range(field.position.x + 2.0, field.end.x - 2.0)
		var guard := 0
		while not _free_x(x) and guard < 20:
			x = rng.randf_range(field.position.x + 2.0, field.end.x - 2.0)
			guard += 1
		var from := Vector3(x + rng.randf_range(-2.0, 2.0), 0, rng.randf_range(field.position.y + 10.0, field.end.y - 10.0))
		var to := Vector3(x + rng.randf_range(-1.5, 1.5), 0, wall_z + rng.randf_range(1.0, 3.0))
		_run.append([from, to, rng.randf_range(3.0, 4.6), rng.randf()])
		var k := i % COATS.size()
		if not groups.has(k):
			groups[k] = []
		(groups[k] as Array).append(i)
	for k in groups:
		var ids: Array = groups[k]
		var xs: Array = []
		for i in ids:
			xs.append(_hidden)
		var pair: Array = []
		for pose in ["run_a", "run_b"]:
			pair.append(Scenery.scatter(self, Crowd.ottoman(COATS[k], HATS[k], "spear", pose), xs, [], Crowd.material()).multimesh)
		_sets.append([pair, ids])
	var fx: Array = []
	for i in runners:
		if i % 5 == 0:
			_flame_of[i] = fx.size()
			fx.append(_hidden)
	var q := SphereMesh.new()
	q.radius = 0.13
	q.height = 0.42
	q.radial_segments = 6
	q.rings = 3
	_flames = Scenery.scatter(self, q, fx, [], Assault.flame_mat()).multimesh


func _fires() -> void:
	# Arkada büyük ateşler (gerçek ışık birkaçında) ve mehter halkası
	var x := field.position.x + 10.0
	var n := 0
	while x < field.end.x - 10.0:
		var p := Vector3(x + rng.randf_range(-4.0, 4.0), 0, field.end.y - rng.randf_range(2.0, 10.0))
		p.y = ground.call(p.x, p.z)
		if n % 3 == 0:
			Night.campfire(self, p, 1.4)
		else:
			var d := Dressing.new(seed_value + 10 + n)
			d.glow(Vector3(1.2, 1.6, 1.2), p + Vector3(0, 0.8, 0), Color("ffa030"))
			d.build(self)
		n += 1
		x += rng.randf_range(14.0, 22.0)
	var mc := Vector3(field.get_center().x, 0, field.end.y - 18.0)
	mc.y = ground.call(mc.x, mc.z)
	var items: Array = []
	for i in 14:
		var a := TAU * i / 14.0
		var p := mc + Vector3(cos(a) * 4.0, 0, sin(a) * 3.0)
		p.y = ground.call(p.x, p.z)
		items.append([Transform3D(Basis(Vector3.UP, atan2(-cos(a), -sin(a))), p), {"side": "O", "coat": Color("b3262d"), "hat": "bork", "arm": ""}])
	Crowd.place(self, items)
	var dd := Dressing.new(seed_value + 30)
	for i in 4:
		var a := TAU * i / 4.0 + 0.4
		dd.cyl(0.45, 0.5, mc + Vector3(cos(a) * 2.2, 0.8, sin(a) * 1.6), Color("8a5a2a"), Vector3(90, 0, 0), 10)
	dd.build(self)


func _process(delta: float) -> void:
	_t += delta
	for grp: Array in _sets:
		var mm_a: MultiMesh = grp[0][0]
		var mm_b: MultiMesh = grp[0][1]
		var ids: Array = grp[1]
		for j in ids.size():
			var i: int = ids[j]
			var r: Array = _run[i]
			var from: Vector3 = r[0]
			var to: Vector3 = r[1]
			var length := from.distance_to(to)
			var ph: float = r[3] + delta * float(r[2]) / maxf(length, 1.0)
			if ph >= 1.0:
				ph = 0.0
			r[3] = ph
			var p := from.lerp(to, ph)
			p.y = ground.call(p.x, p.z)
			var xf := Transform3D(Basis(Vector3.UP, atan2(to.x - from.x, to.z - from.z)), p)
			var step := fmod(ph * length * 0.9 + float(i) * 0.37, 1.0) < 0.5
			mm_a.set_instance_transform(j, xf if step else _hidden)
			mm_b.set_instance_transform(j, _hidden if step else xf)
			if _flame_of.has(i):
				_flames.set_instance_transform(_flame_of[i], Transform3D(Basis.IDENTITY, p + xf.basis * Vector3(-0.32, 1.75, 0.25)))
