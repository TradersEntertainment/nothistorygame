class_name NightArmy
extends Node3D
## Gece hücumunun ovası (Bölüm 30/30o, Blakherna; başka sur önlerine de konabilir): sahnenin "büyük gece hücumu"
## olarak okunması için oynanış alanının ötesini dolduran ordu.
##   · bölükler: sancaklı, mızraklı ve kalkanlı asker blokları (8–12 × 4–6), her birinde meşaleler
##   · dalgalar: sura koşan askerler (dört karelik koşu: adım, geçiş, adım, geçiş; hafif sekme). Beşte birinin sağ
##     elinde başının üstünde meşale (sap ve alev; eskiden sapsız, başın yanında süzülen sarı bir küreydi). Sur
##     dibine varan çömelip bir süre bekler, sonra ovanın gerisinden yeniden koşar (eskiden sura değince ovanın
##     başına ışınlanıyor, kulelerin önünde kulenin içine koşuyordu: towers)
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
## Surdan taşan kulelerin x'leri (yarı genişlik TOWER_HALF, dış yüzü wall_z + tower_out): koşanlar kulenin önünde durur
var towers: Array = []
var tower_out := 5.6
const TOWER_HALF := 4.6

const COATS := [Color("d8cfb8"), Color("8a3a2e"), Color("6a5a48"), Color("3e4c68"), Color("b3262d"), Color("2e6a3a")]
const HATS := ["bork", "bork", "turban", "helmet", "bork", "turban"]

var _run: Array = []          # [from, to, speed, phase(0..1), bekleme(sn; >0 sur dibinde çömelmiş)]
var _sets: Array = []         # [[mm_a, mm_m, mm_b, mm_crouch], [indeks], meşaleli]
var _flames: MultiMeshInstance3D
var _glows: MultiMeshInstance3D
var _flame_of := {}           # koşan → meşale örneği
var _tip := Vector3(0.3, 2.2, 0.35)     # meşalenin ucu (koşanın yerelinde; ilk kurulumda modelden okunur)
var _tip_crouch := Vector3(0.3, 1.0, 0.5)
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
		var tx := x + rng.randf_range(-1.5, 1.5)
		var stop := wall_z + rng.randf_range(1.5, 3.5)
		for t: float in towers:
			if absf(tx - t) < TOWER_HALF + 0.6:
				stop = wall_z + tower_out + rng.randf_range(0.8, 2.6)
		_run.append([from, Vector3(tx, 0, stop), rng.randf_range(3.0, 4.6), rng.randf(), 0.0])
		var torch := i % 5 == 0
		var k := (i % COATS.size()) * 2 + (1 if torch else 0)
		if not groups.has(k):
			groups[k] = []
		(groups[k] as Array).append(i)
	_tip = _torch_tip("run_ta", _tip)
	_tip_crouch = _torch_tip("crouch", _tip_crouch)
	for k: int in groups:
		var ids: Array = groups[k]
		var torch: bool = k % 2 == 1
		var c: Color = COATS[k / 2]
		var h: String = HATS[k / 2]
		var xs: Array = []
		for i in ids:
			xs.append(_hidden)
		var meshes: Array = []
		var poses: Array = ["run_ta", "run_tm", "run_tb", "crouch"] if torch else ["run_a", "run_m", "run_b", "crouch"]
		for pose in poses:
			meshes.append(Scenery.scatter(self, Crowd.ottoman(c, h, "torch" if torch else "spear", pose), xs, [], Crowd.material()).multimesh)
		_sets.append([meshes, ids, torch])
	var fx: Array = []
	for i in runners:
		if i % 5 == 0:
			_flame_of[i] = fx.size()
			fx.append(_hidden)
	_flames = Flame.scatter_flames(self, fx, 1.4)
	_glows = Flame.scatter_glows(self, fx, 0.5)
	# Görünürlük kutusu bütün koşu alanı (ilk dönüşümler gizli noktada: kutu oradan hesaplanınca alevler hep kırpılıyordu)
	var box := AABB(Vector3(field.position.x - 6.0, -4.0, wall_z - 4.0), Vector3(field.size.x + 12.0, 16.0, field.end.y - wall_z + 8.0))
	_flames.multimesh.custom_aabb = box
	_glows.multimesh.custom_aabb = box


## Meşalenin ucu koşanın yerelinde: aynı pozdaki bir askerden okunur (kol pozu üç karede de aynı)
func _torch_tip(pose: String, fallback: Vector3) -> Vector3:
	var s := Soldier.new(COATS[0], "stand", HATS[0])
	add_child(s)
	s.equip("torch")
	Crowd._pose(s, pose)
	var tip := s.find_child("TorchTip", true, false) as Node3D
	var at := s.to_local(tip.global_position) if tip else fallback
	s.free()
	return at


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
		var mms: Array = grp[0]
		var ids: Array = grp[1]
		for j in ids.size():
			var i: int = ids[j]
			var r: Array = _run[i]
			var from: Vector3 = r[0]
			var to: Vector3 = r[1]
			var length := from.distance_to(to)
			var hold: float = r[4]
			var frame := 0
			var p: Vector3
			var ph: float = r[3]
			if hold > 0.0:
				# Sur dibinde: çömelmiş bekler; süre dolunca ovanın gerisinden yeniden koşar (karanlıkta, uzakta belirir)
				hold -= delta
				r[4] = hold
				p = to
				frame = 3
				if hold <= 0.0:
					r[3] = 0.0
			else:
				ph += delta * float(r[2]) / maxf(length, 1.0)
				if ph >= 1.0:
					ph = 1.0
					r[4] = rng.randf_range(3.0, 9.0)
				r[3] = ph
				p = from.lerp(to, ph)
				var cyc := fmod(ph * length * 0.9 + float(i) * 0.37, 1.0)
				frame = [0, 1, 2, 1][int(cyc * 4.0) % 4]
				p.y += 0.05 * absf(sin(cyc * TAU))
			p.y += ground.call(p.x, p.z)
			var xf := Transform3D(Basis(Vector3.UP, atan2(to.x - from.x, to.z - from.z)), p)
			for m in mms.size():
				(mms[m] as MultiMesh).set_instance_transform(j, xf if m == frame else _hidden)
			if _flame_of.has(i):
				var tp := xf * (_tip if frame != 3 else _tip_crouch)
				var fl: int = _flame_of[i]
				_flames.multimesh.set_instance_transform(fl, Transform3D(Basis.from_scale(Vector3(0.3, 0.52, 0.3)), tp))
				_glows.multimesh.set_instance_transform(fl, Transform3D(Basis.from_scale(Vector3.ONE * 1.1), tp + Vector3(0, 0.16, 0)))
