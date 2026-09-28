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


func avoid(p: Vector3, r: float) -> void:
	_avoid.append([p, r])


## Başın üstünde tutulan yuvarlak kalkan: gövdeye bağlı; alt kenarı öne-yukarı uzanan ellerde (≈1,72 m), kalkan
## başın ve miğferin/fesin üstünden geriye 50° eğik çatı gibi uzanır (kollar kısa: düz tutulsa başın içine girerdi).
## one_hand: yalnız sol el tutar (sağ elde kova).
static func overhead_shield(p: Person, color: Color, one_hand := false) -> Node3D:
	var n := Node3D.new()
	n.name = "OverShield"
	var parent: Node3D = p.rig.body if p.rig and p.rig.body else p
	parent.add_child(n)
	n.position = Vector3(-0.07 if one_hand else 0.0, 1.97, 0.08)
	n.rotation = Vector3(deg_to_rad(-40.0), 0, 0)
	Blades.shield(n, color, Color("9aa0a8")).scale = Vector3.ONE * 1.2
	if p.rig:
		p.rig.shield_up = 1 if one_hand else 2
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


func populate(a: Vector3, b: Vector3, width: float, n_run: int, n_dead: int, n_wall: int, seed := 7) -> void:
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
	# Gedik ağzında kalkan kalkana duran küme (başlarının üstünde çatı gibi kalkanlar)
	var wall_c := _ground(LandWalls.BREACH + Vector3(0, 0, -3.2))
	for i in n_wall:
		var pos := _ground(wall_c + Vector3((i % 4) * 0.72 - 1.1, 0, -floorf(i / 4.0) * 0.7))
		var p := _person(200 + i, pos)
		p.look_at_from_position(pos, pos + Vector3(0, 0, 5), Vector3.UP)
		p.rotate_y(PI)
		overhead_shield(p, [Color("7a2a24"), Color("8a8e96")][i % 2])


func _lay(p: Person, back: bool) -> void:
	if p.rig:
		p.rig.lock += 1
		p.rig.shield_up = 0
	p.rotation = Vector3(-PI * 0.5 if back else PI * 0.5, rng.randf() * TAU, 0)
	p.global_position += Vector3(0, 0.14, 0)


func _stick(p: Node3D, local: Vector3) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = Assault.arrow_mesh()
	p.add_child(mi)
	mi.position = local
	mi.rotation = Vector3(rng.randf_range(-0.5, 0.5) - 0.3, rng.randf() * TAU, rng.randf_range(-0.4, 0.4))


func _process(delta: float) -> void:
	for r: Dictionary in _runners:
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
		p.rig.activity = "fall"
	var back := rng.randf() < 0.65
	var tw := p.create_tween().set_parallel(true)
	tw.tween_property(p, "rotation:x", -PI * 0.5 if back else PI * 0.5, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(p, "global_position:y", p.global_position.y + 0.14, 0.5)
	var freeze := func() -> void:
		if p.rig:
			p.rig.lock += 1
	tw.chain().tween_callback(freeze)
