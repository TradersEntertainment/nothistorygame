class_name WallFight
extends Node3D
## Bizans surunda savaşın hikâyedeki işleri (LandWalls düzeni: dış sur z 14–16, yürüyüş yolu y 8, gedik x=0):
##   · kaynar yağ kazanları: dış surun yürüyüş yolunda, altında ateş; başında biri karıştırır, biri kaldıraçla devirir.
##     Dökülen yağ sur dibine iner, buhar ve duman kalkar; altındaki saldıranlar tutuşur.
##   · yanan saldıranlar: alev alan asker çırpınarak geri kaçar, düşer, alevi söner.
##   · onarım ekibi: depo ile gedik arasında sepetle toprak, fıçı, kalas taşıyanlar; gedikte kazık çakanlar ve taş
##     dizenler (Bölüm 20'de Tolga da bu ekiptedir).
## Bütün kişiler canlı karakterdir (Person / Soldier). Kök "garrison" grubundadır: fetihte kaldırılır.

var cauldrons: Array = []        # {node, pot, stream, pos, t}
var burning: Array = []          # {node, flames, light, t, dir}
var crew: Array = []             # {node, a, b, t, speed}
var rng := RandomNumberGenerator.new()
var _t := 0.0


func _ready() -> void:
	add_to_group("garrison")
	rng.seed = 5320


# ---------------------------------------------------------------- kaynar yağ

## Yürüyüş yolunda kazan (pos: kazanın yeri, y = yol). Dökülen yağ +Z yönünde sur dibine iner.
func add_cauldron(pos: Vector3, seed := 0) -> Dictionary:
	var c := Node3D.new()
	c.position = pos
	add_child(c)
	# Taş ocak, içinde kor ve alev
	for k in 6:
		var a := TAU * k / 6.0
		Props.ball(c, 0.16, Vector3(cos(a) * 0.5, 0.1, sin(a) * 0.5), Color("5a5550"), Vector3(1, 0.7, 1), 6)
	var fl := Props.cyl(c, 0.3, 0.45, Vector3(0, 0.28, 0), Color("ff9a30"), Vector3.ZERO, 6, 0.0)
	fl.material_override = Props.mat(Color("ff9a30"), 3.0, false, "", false)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 0.6, 0)
	light.light_color = Color("ff8a3a")
	light.light_energy = 1.6
	light.omni_range = 6.0
	c.add_child(light)
	# Demir sehpa ve devrilebilen kazan (pivot: ön kulplar, sur tarafı)
	for sx: float in [-0.6, 0.6]:
		Props.cyl(c, 0.04, 1.2, Vector3(sx, 0.6, 0.35), Color("3a3a40"), Vector3.ZERO, 5)
	Props.cyl(c, 0.03, 1.3, Vector3(0, 1.15, 0.35), Color("3a3a40"), Vector3(0, 0, 90), 5)
	var pivot := Node3D.new()
	pivot.position = Vector3(0, 1.1, 0.35)
	c.add_child(pivot)
	var pot := Node3D.new()
	pot.position = Vector3(0, -0.35, -0.35)
	pivot.add_child(pot)
	Props.cyl(pot, 0.42, 0.6, Vector3.ZERO, Color("2e2c2a"), Vector3.ZERO, 12, 0.34)
	Props.cyl(pot, 0.43, 0.05, Vector3(0, 0.3, 0), Color("4a4846"), Vector3.ZERO, 12)
	var oil := Props.cyl(pot, 0.39, 0.02, Vector3(0, 0.28, 0), Color("c88a2a"), Vector3.ZERO, 12)
	oil.material_override = Props.mat(Color("d89a3a"), 1.2, false, "", false)
	Props.cyl(pot, 0.03, 1.1, Vector3(0, 0.35, -0.75), Color("5a3e26"), Vector3(-70, 0, 0), 5)   # devirme kolu
	var steam := Vfx.steam(c, Vector3(0, 1.5, 0))
	# Başında iki adam: biri kazanı karıştırır, biri devirme kolunda bekler
	var stir := Garrison.man(c, Vector3(-0.85, 0, -0.3), PI * 0.4, seed + 1, "", "stir")
	var lever := Garrison.man(c, Vector3(0.8, 0, -0.45), -PI * 0.25, seed + 2, "")
	var d := {"node": c, "pivot": pivot, "pos": pos, "t": -1.0, "light": light, "men": [stir, lever], "steam": steam}
	cauldrons.append(d)
	return d


## Kazanı devirir: yağ sur dibine (hedef) iner; hedefin çevresindeki saldıranlar tutuşur. Süreyi döndürür.
func pour(d: Dictionary, target: Vector3, burn_count := 2) -> float:
	if float(d["t"]) >= 0.0:
		return 0.0
	d["t"] = 0.0
	var pivot: Node3D = d["pivot"]
	var tw := create_tween()
	tw.tween_property(pivot, "rotation:x", deg_to_rad(75.0), 0.55).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.4)
	tw.tween_property(pivot, "rotation:x", 0.0, 1.0)
	tw.tween_callback(func(): d["t"] = -1.0)
	# Devirme kolundaki adam iki koluyla kolu aşağı bastırır
	var lever: Person = (d["men"] as Array)[1]
	if is_instance_valid(lever) and lever.rig:
		lever.rig.lock += 1
		var lt := create_tween().set_parallel(true)
		lt.tween_property(lever.rig.arm_l, "rotation", Vector3(-1.2, 0, -0.2), 0.3)
		lt.tween_property(lever.rig.arm_r, "rotation", Vector3(-1.2, 0, 0.2), 0.3)
		lt.chain().tween_interval(1.6)
		lt.chain().tween_callback(func():
			if is_instance_valid(lever):
				lever.rig.lock = maxi(lever.rig.lock - 1, 0))
	# Yağ şeridi: kazanın ağzından sur dibine
	var from: Vector3 = (d["node"] as Node3D).global_position + Vector3(0, 1.2, 0.9)
	var to := target
	var stream := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.16
	cm.bottom_radius = 0.34
	cm.height = 1.0
	stream.mesh = cm
	stream.material_override = Props.mat(Color("d8922a"), 1.6, false, "", false)
	add_child(stream)
	var mid := (from + to) * 0.5
	var up := (from - to).normalized()
	var side := up.cross(Vector3.RIGHT).normalized() if absf(up.dot(Vector3.RIGHT)) < 0.9 else up.cross(Vector3.FORWARD).normalized()
	stream.global_transform = Transform3D(Basis(side.cross(up), up, side).scaled(Vector3(1, from.distance_to(to), 1)), mid)
	stream.scale = Vector3(0.05, from.distance_to(to), 0.05)
	var st := create_tween()
	st.tween_interval(0.35)
	st.tween_property(stream, "scale", Vector3(1, from.distance_to(to), 1), 0.2)
	st.tween_interval(1.1)
	st.tween_property(stream, "scale", Vector3(0.05, from.distance_to(to), 0.05), 0.35)
	st.tween_callback(stream.queue_free)
	get_tree().create_timer(0.55).timeout.connect(func():
		if not is_inside_tree():
			return
		Audio.sfx("splash", -6.0, 0.7)
		Audio.sfx("fuse_burn", -8.0, 0.6)
		Vfx.dust(self, to + Vector3(0, 0.4, 0), 1.4)
		Vfx.smolder(self, to, 1.2, true)
		for k in burn_count:
			burn(to + Vector3(rng.randf_range(-1.6, 1.6), 0, rng.randf_range(-0.4, 1.2))))
	return 2.9


# ---------------------------------------------------------------- yanan saldıranlar

## Yanan saldıran: gerçek asker modeli; alevler içinde çırpınarak sur dibinden geri (+Z) kaçar, düşer, alev söner.
func burn(pos: Vector3, coat := Color(0, 0, 0, 0)) -> Soldier:
	var c: Color = coat if coat.a > 0.0 else Crowd.OTT_COATS[rng.randi() % Crowd.OTT_COATS.size()]
	var s := Soldier.new(c, "stand", "bork" if rng.randf() < 0.6 else "turban")
	s.set_meta("no_talk", true)
	s.position = pos
	s.rotation.y = rng.randf_range(-0.6, 0.6)
	add_child(s)
	var flames: Array = []
	for k in 5:
		var f := Props.cyl(s, rng.randf_range(0.14, 0.26), rng.randf_range(0.5, 0.9), Vector3(rng.randf_range(-0.2, 0.2), 0.6 + k * 0.28, rng.randf_range(-0.15, 0.15)),
			Color("ffa030"), Vector3.ZERO, 6, 0.0)
		f.material_override = Props.mat(Color("ffa030") if k % 2 == 0 else Color("ffd060"), 3.5, false, "", false)
		flames.append(f)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 1.2, 0)
	light.light_color = Color("ff8a30")
	light.light_energy = 2.4
	light.omni_range = 7.0
	s.add_child(light)
	burning.append({"node": s, "flames": flames, "light": light, "t": 0.0, "dir": Vector3(rng.randf_range(-0.4, 0.4), 0, 1).normalized(),
		"speed": rng.randf_range(2.4, 3.6)})
	Audio.sfx("crowd_gasp", -14.0, rng.randf_range(0.8, 1.2))
	return s


func _update_burning(delta: float) -> void:
	for b: Dictionary in burning.duplicate():
		var s: Soldier = b["node"]
		if not is_instance_valid(s):
			burning.erase(b)
			continue
		b["t"] = float(b["t"]) + delta
		var t: float = b["t"]
		for f: Node3D in b["flames"]:
			if is_instance_valid(f):
				f.scale = Vector3.ONE * (0.8 + absf(sin(_t * 14.0 + f.position.y * 5.0)) * 0.5) * clampf(1.0 - (t - 3.2) / 2.0, 0.0, 1.0)
		(b["light"] as OmniLight3D).light_energy = 2.4 * clampf(1.0 - (t - 3.2) / 2.0, 0.0, 1.0) * (0.8 + randf() * 0.4)
		if t < 2.2:
			# Kaçar: kollar havada, yalpalar
			s.position += (b["dir"] as Vector3) * float(b["speed"]) * delta
			s.rotation.z = sin(t * 11.0) * 0.18
			if s.rig:
				s.rig.lock = 1
				s.rig.arm_l.rotation.x = -2.4 + sin(t * 16.0) * 0.5
				s.rig.arm_r.rotation.x = -2.4 + cos(t * 15.0) * 0.5
		elif t < 2.8:
			# Yüzüstü düşer
			s.rotation.x = lerpf(s.rotation.x, 1.45, clampf(delta * 6.0, 0.0, 1.0))
			s.position.y = lerpf(s.position.y, 0.15, clampf(delta * 6.0, 0.0, 1.0))
		elif t > 9.0:
			burning.erase(b)
			s.queue_free()


# ---------------------------------------------------------------- onarım ekibi

## Depo (a) ile gedik (b) arasında taşıyanlar: sepetle toprak, fıçı, kalas. n kişi, yan yana şeritlerde.
func add_carriers(a: Vector3, b: Vector3, n: int, seed := 0) -> void:
	var kinds := ["earth", "barrel", "plank", "earth", "earth", "barrel"]
	for i in n:
		var p := Person.new({"coat": [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a"), Color("4a4a3a"), Color("6a5a48")][i % 5],
			"pants": Color("3a3028"), "hat": "helm" if i % 3 == 0 else "none", "mustache": i % 2 == 0, "beard": i % 3 == 1,
			"hair": [Color("3a2a1e"), Color("5a4a3a")][i % 2], "n": seed + i})
		p.set_meta("no_talk", true)
		p.set_meta("garrison", true)
		add_child(p)
		p.carry(kinds[i % kinds.size()])
		var off := Vector3(-1.6 + (i % 4) * 1.05, 0, 0)
		crew.append({"node": p, "a": a + off, "b": b + off * 0.8, "t": float(i) / n, "speed": rng.randf_range(0.04, 0.055)})


## Gedikte çalışanlar: kazık çakanlar ve taş dizenler (yerinde; iş hareketi).
func add_builders(site: Vector3, n: int, seed := 0) -> void:
	for i in n:
		var p := Person.new({"coat": [Color("5a4a3a"), Color("6a5a48"), Color("4a3a2e")][i % 3], "pants": Color("3a3028"),
			"hat": "none", "mustache": true, "beard": i % 2 == 0, "apron": Color("5a4a36"), "n": seed + 40 + i})
		p.set_meta("no_talk", true)
		p.set_meta("garrison", true)
		var x := (-1.0 if i % 2 == 0 else 1.0) * (2.4 + (i / 2) * 1.2)
		p.position = site + Vector3(x, 0, -0.6 - (i / 2) * 0.5)
		p.rotation.y = -signf(x) * 0.5
		add_child(p)
		p.set_activity(["hammer", "chop"][i % 2])


func _update_crew(delta: float) -> void:
	for c: Dictionary in crew:
		var p: Person = c["node"]
		if not is_instance_valid(p) or not p.visible:
			continue
		c["t"] = fmod(float(c["t"]) + delta * float(c["speed"]), 1.0)
		var ph: float = c["t"]
		var k := smoothstep(0.0, 0.45, ph) if ph < 0.5 else 1.0 - smoothstep(0.55, 1.0, ph)
		var a: Vector3 = c["a"]
		var b: Vector3 = c["b"]
		p.position = a.lerp(b, k)
		var dir := (b - a) if ph < 0.5 else (a - b)
		p.rotation.y = lerp_angle(p.rotation.y, atan2(dir.x, dir.z), clampf(delta * 6.0, 0.0, 1.0))


func _process(delta: float) -> void:
	_t += delta
	_update_burning(delta)
	_update_crew(delta)
	for d: Dictionary in cauldrons:
		var l: OmniLight3D = d["light"]
		l.light_energy = 1.4 + sin(_t * 9.0 + l.position.x) * 0.25 + randf() * 0.15


## Önizleme / test: bütün kazanlar birlikte döker.
func demo_pour() -> void:
	for d: Dictionary in cauldrons:
		pour(d, Vector3((d["pos"] as Vector3).x, 0.0, 18.0), 3)
