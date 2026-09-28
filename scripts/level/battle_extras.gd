extends Node3D
## Peribolosta gerçek savaş kalabalığı (Bölüm 0 ve fragmanın soğuk açılışı): kalkanını başının üstüne kaldırıp koşan
## savunucular, kova/taş taşıyanlar, gedik ağzında kalkan kalkana duran küme, yerde oklanmış yatanlar ve ara ara
## ok yiyip geriye devrilen koşanlar. Koşanlar koridorun iki ucu arasında gidip gelir (uçlarda yok olmazlar).
## Kullanım: var b := BattleExtras.new(); parent.add_child(b); b.populate(a, b, genişlik, koşan, ölü, küme, tohum)
##   b.assault = assault   (varsa koşanların çevresine de ok iner)

const LOOKS := [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96"), Color("6a4a30"), Color("4a5a3a")]

var assault: Assault
var hit_every := 1.3             # saniyede bir koşan ok yiyip düşer (0: hiç)
var max_fallen_ratio := 0.45
var rng := RandomNumberGenerator.new()
var _runners: Array = []         # {p, a, b, t, speed, dir}
var _fallen := 0
var _run_total := 0
var _hit_t := 1.0
var _arrow_t := 0.6
var _avoid: Array = []           # [nokta, yarıçap]: buralarda kimse devrilmez (kamera önü)


## Kesmede kadrajın önüne düşenler (yeni çekim başlarken) gizlenir.
func hide_near(p: Vector3, r: float) -> void:
	for c in get_children():
		if c is Node3D and (c as Node3D).global_position.distance_to(p) < r:
			(c as Node3D).visible = false


## "Siper!": koşanlar durur, herkes çömelir; kalkanı olanlar kalkanı başının üstünde tutar.
var _cover := false


func take_cover() -> void:
	_cover = true
	duck_all(self, [])


## Kökün altındaki ayakta duran herkesi (yatanlar, kilitliler hariç) çömeltir.
static func duck_all(root: Node, except: Array) -> void:
	for n in root.find_children("*", "Node3D", true, false):
		if not n is Person:
			continue
		var p := n as Person
		if p in except or not p.visible or p.rig == null or p.rig.lock > 0:
			continue
		if p.rig.activity in ["", "carry", "crouch"]:
			p.set_activity("crouch")


func avoid(p: Vector3, r: float) -> void:
	_avoid.append([p, r])


## Başın üstünde tutulan yuvarlak kalkan: el(ler) kalkanın ortasının altında tutar; kalkanı Rig her karede elin
## üstüne yerleştirir (Rig.shield_node). one_hand: yalnız sol el (sağ elde yük).
static func overhead_shield(p: Person, color: Color, one_hand := false) -> Node3D:
	var n := Node3D.new()
	n.name = "OverShield"
	var parent: Node3D = p.rig.body if p.rig and p.rig.body else p
	parent.add_child(n)
	n.position = Vector3(0, 2.0, 0.05)
	Blades.shield(n, color, Color("9aa0a8")).scale = Vector3.ONE * 1.2
	if p.rig:
		p.rig.shield_up = 1 if one_hand else 2
		p.rig.shield_node = n
	return n


## Ok demeti: iple iki yerden bağlı ~18 ok (uzunluk yerel Z boyunca, uçlar +Z).
static func arrow_bundle(parent: Node3D) -> Node3D:
	var n := Node3D.new()
	parent.add_child(n)
	var am := Assault.arrow_mesh()
	for k in 18:
		var a := k * 2.4
		var r := 0.02 + (k % 3) * 0.022
		var mi := MeshInstance3D.new()
		mi.mesh = am
		n.add_child(mi)
		mi.position = Vector3(cos(a) * r, sin(a) * r, (k % 4) * 0.02 - 0.03)
		mi.rotation.z = a
	for z: float in [-0.18, 0.2]:
		Props.cyl(n, 0.075, 0.035, Vector3(0, 0, z), Color("8a7048"), Vector3(90, 0, 0), 10)
	return n


func _person(i: int, pos: Vector3) -> Person:
	var p := Person.new({"coat": LOOKS[i % LOOKS.size()], "pants": Color("3a2a22"), "hat": "helm" if i % 4 != 3 else "",
		"beard": i % 2 == 0, "mustache": true, "n": 900 + i})
	p.set_meta("no_talk", true)
	add_child(p)
	p.global_position = pos
	return p


func _ground(p: Vector3) -> Vector3:
	return LandWalls.on_rubble(Vector3(p.x, 0, p.z))


## "Siper!" herkese: sahnedeki bütün BattleExtras koşanları durur ve kökteki ayaktakiler çömelir.
static func all_take_cover(root: Node, except: Array) -> void:
	for b in root.get_tree().get_nodes_in_group("battle_extras"):
		(b as Node).call("take_cover")
	duck_all(root, except)


func populate(a: Vector3, b: Vector3, width: float, n_run: int, n_dead: int, n_wall: int, seed := 7) -> void:
	add_to_group("battle_extras")
	rng.seed = seed
	var along := (b - a)
	var side := Vector3(-along.z, 0, along.x).normalized()
	for i in n_run:
		var off := side * rng.randf_range(-width * 0.5, width * 0.5)
		var pa := _ground(a + off + along.normalized() * rng.randf_range(-2.0, 2.0))
		var pb := _ground(b + off + along.normalized() * rng.randf_range(-2.0, 2.0))
		var p := _person(i, pa)
		var kind := i % 5
		if kind <= 2:
			overhead_shield(p, [Color("7a2a24"), Color("3a4a6a"), Color("6a5a3a")][i % 3])
		elif kind == 3:
			p.set_activity("carry")
			Props.cyl(p, 0.16, 0.3, Vector3(0, 1.0, 0.36), Color("8a6440"), Vector3.ZERO, 8, 0.19)
		else:
			p.equip("spear_shield", Color("5a2a24"))
		_runners.append({"p": p, "a": pa, "b": pb, "t": rng.randf(), "speed": rng.randf_range(3.4, 5.0), "dir": 1.0 if i % 2 == 0 else -1.0})
	_run_total = n_run
	for i in n_dead:
		var pos := _ground(a.lerp(b, rng.randf()) + side * rng.randf_range(-width * 0.5, width * 0.5))
		var p := _person(100 + i, pos)
		_lay(p, rng.randf() < 0.5)
		for k in rng.randi_range(1, 3):
			_stick(p, Vector3(rng.randf_range(-0.15, 0.15), rng.randf_range(0.9, 1.35), 0.12))
		if rng.randf() < 0.6:
			var sh := Node3D.new()
			add_child(sh)
			sh.global_position = pos + Vector3(rng.randf_range(-0.9, 0.9), 0.04, rng.randf_range(-0.9, 0.9))
			sh.rotation = Vector3(-PI * 0.5, rng.randf() * TAU, 0)
			Blades.shield(sh, Color("5a2a24"), Color("9aa0a8"))
		if rng.randf() < 0.5:
			Props.cyl(self, rng.randf_range(0.35, 0.55), 0.01, _ground(pos) + Vector3(0, 0.012, 0), Color("3a1a16"), Vector3.ZERO, 12)
	for i in n_dead * 2:
		_debris(a.lerp(b, rng.randf()) + side * rng.randf_range(-width * 0.6, width * 0.6))
	# Gedik ağzında kalkan kalkana duran küme (başlarının üstünde çatı gibi kalkanlar)
	var wall_c := _ground(LandWalls.BREACH + Vector3(0, 0, -3.2))
	for i in n_wall:
		var pos := _ground(wall_c + Vector3((i % 4) * 0.72 - 1.1, 0, -floorf(i / 4.0) * 0.7))
		var p := _person(200 + i, pos)
		p.look_at_from_position(pos, pos + Vector3(0, 0, 5), Vector3.UP)
		p.rotate_y(PI)
		overhead_shield(p, [Color("7a2a24"), Color("8a8e96")][i % 2])


## Yerde yatan: sırtüstü ya da yüzüstü, düz uzanmış, kollar açık; biraz yana dönük olabilir. Gövde yere değer
## (eskiden "düşüş" pozunda kalıyor, bacakları havada, yere değmeden eğik duruyorlardı).
func _lay(p: Person, back: bool) -> void:
	if p.rig:
		p.rig.shield_up = 0
		p.set_activity("dead")
		var rg := p.rig
		var hold := func() -> void:
			rg.lock += 1
		p.get_tree().create_timer(0.5).timeout.connect(hold)
	p.rotation = Vector3(-PI * 0.5 if back else PI * 0.5, rng.randf() * TAU, rng.randf_range(-0.15, 0.15))
	p.global_position = _ground(p.global_position) + Vector3(0, 0.13, 0)


## Savaş enkazı: surdan düşmüş taş bloklar, kırık kılıçlar, yanan oklar, dağılmış barikat kalasları, kara lekeler.
func _debris(at: Vector3) -> void:
	var n := Node3D.new()
	add_child(n)
	n.global_position = _ground(at)
	match rng.randi() % 5:
		0:
			for k in rng.randi_range(1, 3):
				Props.box(n, Vector3(rng.randf_range(0.35, 0.7), rng.randf_range(0.25, 0.45), rng.randf_range(0.3, 0.55)),
					Vector3(rng.randf_range(-0.6, 0.6), 0.15, rng.randf_range(-0.6, 0.6)), LandWalls.C_STONE.darkened(rng.randf_range(0.15, 0.4)),
					Vector3(rng.randf_range(-15, 15), rng.randf() * 180.0, rng.randf_range(-15, 15)))
		1:
			# Kırık kılıç: kabzalı kısa parça ve uzakta kopmuş uç
			Props.box(n, Vector3(0.04, 0.012, 0.42), Vector3(0, 0.02, 0), Color("b8bec6"), Vector3(0, rng.randf() * 180.0, 0))
			Props.box(n, Vector3(0.2, 0.03, 0.04), Vector3(0, 0.03, -0.2), Color("7a6a4a"), Vector3(0, rng.randf() * 180.0, 0))
			Props.box(n, Vector3(0.04, 0.012, 0.3), Vector3(0.5, 0.02, 0.3), Color("b8bec6"), Vector3(0, rng.randf() * 180.0, 0))
		2:
			# Yanan oklar: toprağa saplı, ucunda alev
			for k in rng.randi_range(2, 4):
				var mi := MeshInstance3D.new()
				mi.mesh = Assault.arrow_mesh()
				n.add_child(mi)
				var p := Vector3(rng.randf_range(-0.7, 0.7), 0.25, rng.randf_range(-0.7, 0.7))
				mi.position = p
				mi.rotation = Vector3(-1.1 + rng.randf_range(-0.2, 0.2), rng.randf() * TAU, 0)
				Props.ball(n, 0.03, p + Vector3(0, 0.36, 0), Color("ffb040"), Vector3(1, 1.6, 1), 6, 3.0)
		3:
			# Dağılmış barikat kalasları
			for k in 3:
				Props.box(n, Vector3(0.22, 0.07, rng.randf_range(1.0, 1.8)), Vector3(rng.randf_range(-0.5, 0.5), 0.05 + k * 0.06, rng.randf_range(-0.4, 0.4)),
					Color("7a5634").darkened(rng.randf_range(0.0, 0.3)), Vector3(rng.randf_range(-6, 6), rng.randf() * 180.0, 0))
		4:
			Props.cyl(n, rng.randf_range(0.4, 0.7), 0.01, Vector3(0, 0.012, 0), Color("3a1a16"), Vector3.ZERO, 12)


func _stick(p: Node3D, local: Vector3) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = Assault.arrow_mesh()
	p.add_child(mi)
	mi.position = local
	mi.rotation = Vector3(rng.randf_range(-0.5, 0.5) - 0.3, rng.randf() * TAU, rng.randf_range(-0.4, 0.4))


func _process(delta: float) -> void:
	for r: Dictionary in _runners:
		if _cover:
			break
		var p: Person = r["p"]
		var pa: Vector3 = r["a"]
		var pb: Vector3 = r["b"]
		var t: float = float(r["t"]) + delta * float(r["speed"]) * float(r["dir"]) / maxf(pa.distance_to(pb), 1.0)
		if t >= 1.0 or t <= 0.0:
			r["dir"] = -float(r["dir"])
			t = clampf(t, 0.0, 1.0)
		r["t"] = t
		p.global_position = _ground(pa.lerp(pb, t))
	if hit_every > 0.0 and not _runners.is_empty() and _fallen < int(_run_total * max_fallen_ratio):
		_hit_t -= delta
		if _hit_t <= 0.0:
			_hit_t = hit_every * rng.randf_range(0.6, 1.4)
			_hit(_runners[rng.randi() % _runners.size()])
	if assault:
		_arrow_t -= delta
		if _arrow_t <= 0.0 and not _runners.is_empty():
			_arrow_t = rng.randf_range(0.35, 0.8)
			var p: Person = (_runners[rng.randi() % _runners.size()] as Dictionary)["p"]
			assault.volley(p.global_position, 2.2, 6, true, 0.6)


## Ok yiyen koşan: kalkanı düşer, geriye devrilir, yerde kalır (oklar gövdesinde).
func _hit(r: Dictionary) -> void:
	var p: Person = r["p"]
	for av: Array in _avoid:
		if p.global_position.distance_to(av[0]) < float(av[1]):
			return
	_runners.erase(r)
	_fallen += 1
	var sh := p.find_child("OverShield", true, false) as Node3D
	if sh:
		sh.reparent(self)
		var st := sh.create_tween().set_parallel(true)
		st.tween_property(sh, "global_position", _ground(sh.global_position) + Vector3(rng.randf_range(-0.6, 0.6), 0.04, rng.randf_range(-0.6, 0.6)), 0.45)
		st.tween_property(sh, "rotation", Vector3(-PI * 0.5, rng.randf() * TAU, 0), 0.45)
	_stick(p, Vector3(0.05, 1.25, 0.14))
	if p.rig:
		p.rig.shield_up = 0
		p.rig.shield_node = null
		p.rig.activity = "fall"
	var back := rng.randf() < 0.65
	var tw := p.create_tween().set_parallel(true)
	tw.tween_property(p, "rotation:x", -PI * 0.5 if back else PI * 0.5, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(p, "global_position:y", p.global_position.y + 0.14, 0.5)
	var freeze := func() -> void:
		if p.rig:
			p.set_activity("dead")
			var rg := p.rig
			var hold := func() -> void:
				rg.lock += 1
			p.get_tree().create_timer(0.3).timeout.connect(hold)
	tw.chain().tween_callback(freeze)
