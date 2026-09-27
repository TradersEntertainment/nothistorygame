class_name Assault
extends Node3D
## Son hücum (29 Mayıs 1453): kara surlarının önünde gerçek bir savaş kalabalığı. LandWalls koordinatları
## (x sur boyunca, +z ovaya doğru; dış sur z 14–16, gedik x=0). Oyuncunun yürüdüğü dikdörtgene (keep)
## çarpışmasız kalabalık konmaz; kalabalık onun arkasında, yanlarında ve surla arasındaki hendek kuşağındadır.
##   · ordu: sancaklı, mızraklı yüzlerce asker bloğu (toplu çizim)
##   · dalgalar: sura koşan, hendeğe inen, gediğe dalan askerler (her kare hareket eder)
##   · merdivenler: dış sura dayalı merdivenlerde tırmanan askerler (bazıları düşer)
##   · bataryalar: arkada ateş eden toplar (alev, duman, gülle yayı, surda toz ve taş)
##   · savunanlar: surların üstünde miğferli askerler; ok yağmuru (görünen oklar yere saplanır)
## Kullanım: var a := Assault.new(); a.keep = Rect2(...); add_child(a); a.build()

var keep := Rect2(-32.0, 36.4, 64.0, 42.0)
var night := true
var wall_len := 150.0
var intensity := 1.0              # 0..1 (dalgalar ve top sıklığı)
var gun_spots: Array = [Vector3(-44, 0, 92), Vector3(-16, 0, 94), Vector3(16, 0, 94), Vector3(44, 0, 92)]
var rng := RandomNumberGenerator.new()
const VOLLEY_FLIGHT := 2.4        # okun havada kaldığı süre (yüksek yay, dik iniş)

var _t := 0.0
var _runners: Array = []          # [MultiMeshInstance3D, [indeks listesi _run içinde]]
var _run: Array = []              # [from, to, speed, t]
var _climb: Array = []            # {node, base, top, t, speed, fall}
var _guns: Array = []             # {node, muzzle, timer}
var _flying: Array = []           # [node, vel, life]
var _stuck: Array = []            # [node, life]
var _defender_nodes: Array[Node3D] = []
var _ladder_nodes: Array[Node3D] = []
static var _arrow_mesh: ArrayMesh
static var _soldier_meshes := {}
static var _defender_mesh: ArrayMesh


func build() -> void:
	rng.seed = 5291453
	_army()
	_wave_runners()
	_ladders()
	_batteries()
	_defenders()
	_smoke()


# ---------------------------------------------------------------- modeller

## Uzak asker (kaftan rengi pişirilmiş): şalvar ve çizme, kaftan eteği, gövde, kuşak, kollar, baş, bıyık, börk,
## sağ elde mızrak. Örnek rengi kullanılmaz (börk ve yüz de boyanıyordu).
static func soldier_mesh(coat := Color("b3262d")) -> ArrayMesh:
	var key := coat.to_html()
	if not _soldier_meshes.has(key):
		_soldier_meshes[key] = Scenery.merged([
			[Scenery._cyl(0.07, 0.55, 0.08, 5), Scenery._t(Vector3(-0.09, 0.28, 0)), Color("e8e0d0")],
			[Scenery._cyl(0.07, 0.55, 0.08, 5), Scenery._t(Vector3(0.09, 0.28, 0)), Color("e8e0d0")],
			[Scenery._boxm(Vector3(0.12, 0.08, 0.2)), Scenery._t(Vector3(-0.09, 0.04, 0.04)), Color("4a3020")],
			[Scenery._boxm(Vector3(0.12, 0.08, 0.2)), Scenery._t(Vector3(0.09, 0.04, 0.04)), Color("4a3020")],
			[Scenery._cyl(0.27, 0.5, 0.21, 8), Scenery._t(Vector3(0, 0.72, 0)), coat.darkened(0.08)],
			[Scenery._cyl(0.2, 0.55, 0.19, 8), Scenery._t(Vector3(0, 1.18, 0)), coat],
			[Scenery._cyl(0.215, 0.08, -1.0, 8), Scenery._t(Vector3(0, 0.96, 0)), Color("e0b52a")],
			[Scenery._cyl(0.06, 0.5, 0.05, 4), Scenery._t(Vector3(-0.25, 1.12, 0.04), Vector3(0.2, 0, 0.12)), coat],
			[Scenery._cyl(0.06, 0.5, 0.05, 4), Scenery._t(Vector3(0.25, 1.12, 0.08), Vector3(-0.5, 0, -0.12)), coat],
			[Scenery._ball(0.15), Scenery._t(Vector3(0, 1.6, 0)), Color("e0b08a")],
			[Scenery._boxm(Vector3(0.2, 0.04, 0.05)), Scenery._t(Vector3(0, 1.55, 0.14)), Color("2b1d14")],
			[Scenery._cyl(0.155, 0.07, -1.0, 8), Scenery._t(Vector3(0, 1.72, 0)), Color("c9a24a")],
			[Scenery._cyl(0.13, 0.42, 0.09, 6), Scenery._t(Vector3(0, 1.93, -0.04), Vector3(-0.2, 0, 0)), Color("f3efe4")],
			[Scenery._cyl(0.022, 2.8, -1.0, 4), Scenery._t(Vector3(0.28, 1.25, 0.2)), Color("5a3e26")],
			[Scenery._cyl(0.05, 0.25, 0.0, 4), Scenery._t(Vector3(0.28, 2.75, 0.2)), Color("c8ccd4")],
		])
	return _soldier_meshes[key]


## Aynı rengin askerlerini tek MultiMesh'te toplar: {renk: [Transform3D]} → sahneye.
func _scatter_by_coat(groups: Dictionary) -> Dictionary:
	var out := {}
	for key in groups:
		var xs: Array = groups[key]
		if xs.is_empty():
			continue
		out[key] = Scenery.scatter(self, soldier_mesh(Color(key)), xs, [], _mat())
	return out


## Surdaki savunan: miğfer, kalkan.
static func defender_mesh() -> ArrayMesh:
	if _defender_mesh == null:
		_defender_mesh = Scenery.merged([
			[Scenery._cyl(0.24, 1.1, 0.18, 6), Scenery._t(Vector3(0, 0.75, 0)), Color.WHITE],
			[Scenery._ball(0.14), Scenery._t(Vector3(0, 1.45, 0)), Color("e0b08a")],
			[Scenery._ball(0.16), Scenery._t(Vector3(0, 1.53, 0), Vector3.ZERO, Vector3(1, 0.7, 1)), Color("9aa0a8")],
			[Scenery._cyl(0.3, 0.05, -1.0, 10), Scenery._t(Vector3(-0.2, 1.0, 0.25), Vector3(PI * 0.5, 0, 0)), Color("8a2b22")],
		])
	return _defender_mesh


## Ok: gövde, uç, tüyler (+Z uçtur).
static func arrow_mesh() -> ArrayMesh:
	if _arrow_mesh == null:
		_arrow_mesh = Scenery.merged([
			[Scenery._cyl(0.012, 0.85, -1.0, 4), Scenery._t(Vector3.ZERO, Vector3(PI * 0.5, 0, 0)), Color("6a4a2c")],
			[Scenery._cyl(0.03, 0.09, 0.0, 4), Scenery._t(Vector3(0, 0, 0.46), Vector3(PI * 0.5, 0, 0)), Color("3a3a40")],
			[Scenery._boxm(Vector3(0.004, 0.07, 0.16)), Scenery._t(Vector3(0, 0, -0.36)), Color("e8e0cc")],
			[Scenery._boxm(Vector3(0.07, 0.004, 0.16)), Scenery._t(Vector3(0, 0, -0.36)), Color("e8e0cc")],
		])
	return _arrow_mesh


func _mat() -> StandardMaterial3D:
	var m := Scenery._vc_mat()
	return m


func _blocked(x: float, z: float, margin := 1.5) -> bool:
	return keep.grow(margin).has_point(Vector2(x, z))


# ---------------------------------------------------------------- ordu blokları

## Yürünen alanın arkasında ve iki yanında düzenli bloklar (her blok 8x6 asker), aralarında sancaklar.
func _army() -> void:
	var groups := {}
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a"), Color("8a6a4a"), Color("6a4a3a"), Color("c98a3a")]
	var blocks: Array = []
	# Arka: iki sıra blok
	for row in 3:
		for bx in 9:
			blocks.append(Vector3(-72.0 + bx * 18.0, 0, keep.end.y + 26.0 + row * 14.0))
	# Yanlar: sura kadar
	for side in [-1.0, 1.0]:
		for row in 4:
			for col in 3:
				blocks.append(Vector3(side * (keep.end.x + 10.0 + col * 16.0), 0, 30.0 + row * 12.0))
	var banner_pos: Array = []
	for b: Vector3 in blocks:
		var coat: Color = coats[rng.randi() % coats.size()]
		for i in 8:
			for j in 5:
				var p := b + Vector3(-5.6 + i * 1.6 + rng.randf_range(-0.2, 0.2), 0, -3.2 + j * 1.6 + rng.randf_range(-0.2, 0.2))
				if _blocked(p.x, p.z):
					continue
				var key := coat.to_html()
				if not groups.has(key):
					groups[key] = []
				(groups[key] as Array).append(Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.15, 0.15)).scaled(Vector3.ONE * rng.randf_range(0.95, 1.08)), p))
		if not _blocked(b.x, b.z, 0.5):
			banner_pos.append(b + Vector3(0, 0, -4.6))
	_scatter_by_coat(groups)
	# Sancaklar: kırmızı, yeşil, beyaz (tuğlu direk)
	for bp: Vector3 in banner_pos:
		var col: Color = [Color("b3262d"), Color("2e6a3a"), Color("f0ece0"), Color("b3262d")][rng.randi() % 4]
		Props.cyl(self, 0.05, 5.5, bp + Vector3(0, 2.75, 0), Color("4a3420"), Vector3.ZERO, 5)
		Props.ball(self, 0.12, bp + Vector3(0, 5.6, 0), Color("d8b040"), Vector3.ONE, 6)
		var fl := Props.box(self, Vector3(0.03, 1.4, 2.1), bp + Vector3(0, 4.6, -1.05), col)
		fl.set_meta("flag", true)


# ---------------------------------------------------------------- koşan dalgalar

## Surla yürünen alan arasındaki kuşakta sura koşan askerler (döngü): hendeğe iner, sura ya da gediğe varınca
## yeniden arkadan başlar. Tek MultiMesh, her kare dönüşüm güncellenir.
func _wave_runners() -> void:
	var n := int(140 * intensity) + 40
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("8a6a4a"), Color("3a6b3a")]
	var groups := {}
	var idx := {}
	for i in n:
		var x := rng.randf_range(-wall_len * 0.45, wall_len * 0.45)
		var from := Vector3(x + rng.randf_range(-3, 3), 0, rng.randf_range(34.0, 46.0))
		if keep.grow(3.0).has_point(Vector2(from.x, from.y)):
			from.z = keep.position.y - 4.0
		# Gediğin karşısındakiler gediğe, öbürleri sur dibine
		var to := Vector3(x * 0.25 if absf(x) < 18.0 else x, 0, 17.5 if absf(x) >= 18.0 else 15.5)
		var sp := rng.randf_range(3.2, 4.8)
		_run.append([from, to, sp, rng.randf()])
		var key: String = (coats[i % coats.size()] as Color).to_html()
		if not groups.has(key):
			groups[key] = []
			idx[key] = []
		(groups[key] as Array).append(Transform3D(Basis.IDENTITY, from))
		(idx[key] as Array).append(i)
	var mms := _scatter_by_coat(groups)
	for key in mms:
		_runners.append([mms[key], idx[key]])


func _update_runners(delta: float) -> void:
	for grp in _runners:
		var mm: MultiMesh = (grp[0] as MultiMeshInstance3D).multimesh
		var ids: Array = grp[1]
		for j in ids.size():
			_update_runner(mm, j, int(ids[j]), delta)


func _update_runner(mm: MultiMesh, j: int, i: int, delta: float) -> void:
	if true:
		var r: Array = _run[i]
		var from: Vector3 = r[0]
		var to: Vector3 = r[1]
		var d := from.distance_to(to)
		r[3] = fmod(float(r[3]) + delta * float(r[2]) / maxf(d, 1.0), 1.0)
		var t: float = r[3]
		var p := from.lerp(to, t)
		# Hendek: z 18–26 arası çukur (koşarken iner, çıkar), adım sekmesi
		if p.z > 17.5 and p.z < 26.0:
			p.y -= sin((p.z - 17.5) / 8.5 * PI) * 1.6
		p.y += absf(sin(_t * 9.0 + i)) * 0.12
		var yaw := atan2(to.x - from.x, to.z - from.z)
		mm.set_instance_transform(j, Transform3D(Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, 0.18), p))


# ---------------------------------------------------------------- merdivenler

func _ladders() -> void:
	var xs := [-44.0, -33.0, -24.0, -13.0, 13.0, 22.0, 31.0, 42.0]
	for x: float in xs:
		var base := Vector3(x, -0.8, 19.0)
		var top := Vector3(x, 7.8, 16.3)
		var l := Node3D.new()
		add_child(l)
		_ladder_nodes.append(l)
		var yv := (top - base).normalized()
		l.transform = Transform3D(Basis(Vector3.RIGHT, yv, Vector3.RIGHT.cross(yv)), base)
		var len := base.distance_to(top)
		for sx: float in [-0.32, 0.32]:
			Props.cyl(l, 0.045, len, Vector3(sx, len * 0.5, 0), Color("6a4a2c"), Vector3.ZERO, 5)
		for k in int(len / 0.45):
			Props.box(l, Vector3(0.64, 0.045, 0.045), Vector3(0, 0.3 + k * 0.45, 0), Color("6a4a2c"))
		# Tırmananlar: iki-üç kişi, farklı yüksekliklerde
		for k in 3:
			var s := Soldier.new([Color("b3262d"), Color("2f5fa8"), Color("8a6a4a")][k], "stand", "bork" if k % 2 == 0 else "turban")
			s.set_meta("no_talk", true)
			add_child(s)
			s.rotation.y = PI
			_climb.append({"node": s, "base": base + Vector3(0, 0, 0.35), "top": top + Vector3(0, 0, 0.35), "t": k * 0.33 + rng.randf() * 0.1,
				"speed": rng.randf_range(0.07, 0.11), "fall": -1.0})


func _update_climbers(delta: float) -> void:
	for c: Dictionary in _climb:
		var s: Soldier = c["node"]
		if not is_instance_valid(s):
			continue
		if float(c["fall"]) >= 0.0:
			# Düşüş: geriye devrilip hendeğe
			c["fall"] = float(c["fall"]) + delta
			var f: float = c["fall"]
			s.position += Vector3(0, -9.0 * f * delta * 3.0, 3.0 * delta)
			s.rotation.x = minf(f * 3.0, 1.4)
			if s.position.y < -1.5:
				c["fall"] = -1.0
				c["t"] = 0.0
				s.rotation.x = 0.0
			continue
		c["t"] = float(c["t"]) + delta * float(c["speed"])
		var t: float = c["t"]
		if t >= 1.0:
			c["t"] = 0.0
			t = 0.0
		var base: Vector3 = c["base"]
		var top: Vector3 = c["top"]
		s.position = base.lerp(top, t) + Vector3(0, sin(_t * 6.0 + base.x) * 0.05, 0)
		if t > 0.55 and rng.randf() < delta * 0.05 * intensity:
			c["fall"] = 0.0


# ---------------------------------------------------------------- bataryalar

func _batteries() -> void:
	for gp: Vector3 in gun_spots:
		var g := Node3D.new()
		add_child(g)
		g.position = gp
		g.look_at_from_position(gp, Vector3(gp.x * 0.3, 0, 15.0), Vector3.UP)
		Props.box(g, Vector3(3.0, 0.8, 6.0), Vector3(0, 0.4, 0), Color("4a3420"))
		Props.cyl(g, 0.8, 5.5, Vector3(0, 1.4, -0.8), Color("8c5e26"), Vector3(90, 0, 0), 14)
		Props.cyl(g, 1.0, 0.5, Vector3(0, 1.4, -3.5), Color("7a5020"), Vector3(90, 0, 0), 14, 1.2)
		Props.box(g, Vector3(7.0, 1.3, 0.5), Vector3(0, 0.65, -5.2), Color("5a4028"))
		for k in 4:
			Props.cyl(g, 0.55, 1.2, Vector3(-3.0 + k * 2.0, 0.6, -6.0), Color("7a6040"), Vector3.ZERO, 8)
		for k in 4:
			var s := Soldier.new([Color("b3262d"), Color("6a4a3a")][k % 2], "stand", "bork")
			s.set_meta("no_talk", true)
			s.position = Vector3(-2.2 + (k % 2) * 4.4, 0, 1.0 + (k / 2) * 1.5)
			g.add_child(s)
		var m := Node3D.new()
		m.position = Vector3(0, 1.4, -3.9)
		g.add_child(m)
		_guns.append({"node": g, "muzzle": m, "timer": rng.randf_range(2.0, 8.0)})


func _update_guns(delta: float) -> void:
	for gd: Dictionary in _guns:
		gd["timer"] = float(gd["timer"]) - delta * intensity
		if float(gd["timer"]) > 0.0:
			continue
		gd["timer"] = rng.randf_range(9.0, 16.0)
		_fire_gun(gd)


func _fire_gun(gd: Dictionary) -> void:
	var m: Node3D = gd["muzzle"]
	var g: Node3D = gd["node"]
	var mp := m.global_position
	var fwd := -g.global_basis.z
	Vfx.explosion(self, mp + fwd * 1.5, 1.3)
	Vfx.dust(self, mp + fwd * 3.0 + Vector3(0, 1.0, 0), 1.2)
	var fl := OmniLight3D.new()
	fl.light_color = Color("ffb060")
	fl.light_energy = 10.0
	fl.omni_range = 50.0
	add_child(fl)
	fl.global_position = mp + fwd * 2.0
	var tw := fl.create_tween()
	tw.tween_property(fl, "light_energy", 0.0, 0.5)
	tw.tween_callback(fl.queue_free)
	var cam := get_viewport().get_camera_3d()
	var dist := cam.global_position.distance_to(mp) if cam else 100.0
	Audio.sfx("cannon", clampf(-4.0 - dist * 0.08, -22.0, -4.0), rng.randf_range(0.75, 0.9))
	# Gülle yayı: sura (gediğin çevresine) düşer
	var hit := Vector3(clampf(mp.x * 0.35 + rng.randf_range(-12, 12), -wall_len * 0.4, wall_len * 0.4), rng.randf_range(3.0, 7.0), 16.2)
	var ball := Props.ball(self, 0.35, mp + fwd * 2.0, Color("2a2624"), Vector3.ONE, 6)
	var peak := (mp + hit) * 0.5 + Vector3(0, 10.0, 0)
	var start := ball.global_position
	var tb := ball.create_tween()
	tb.tween_method(func(k: float): ball.global_position = start.lerp(peak, k).lerp(peak.lerp(hit, k), k), 0.0, 1.0, 1.4)
	tb.tween_callback(func():
		Vfx.explosion(self, hit, 0.8)
		Vfx.dust(self, hit + Vector3(0, -1.0, 1.0), 1.4)
		for k in 5:
			var st := Props.box(self, Vector3.ONE * rng.randf_range(0.2, 0.45), hit, Color("cdbd9e"))
			var v := Vector3(rng.randf_range(-3, 3), rng.randf_range(2, 5), rng.randf_range(2, 6))
			_flying.append([st, v, 2.5])
		Audio.sfx("explosion_small", -12.0, rng.randf_range(0.7, 1.0))
		ball.queue_free())


# ---------------------------------------------------------------- savunanlar ve oklar

func _defenders() -> void:
	var xf: Array = []
	var cols: Array = []
	var x := -wall_len * 0.5
	while x < wall_len * 0.5:
		if absf(x) > 5.0:
			xf.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE), Vector3(x + rng.randf_range(-0.4, 0.4), 8.0, 15.2)))
			cols.append([Color("7a2a24"), Color("5a4a3a"), Color("3a4a6a")][rng.randi() % 3])
		x += rng.randf_range(1.6, 3.2)
	# İç sur (yüksek) üstünde de
	x = -wall_len * 0.5
	while x < wall_len * 0.5:
		xf.append(Transform3D(Basis.IDENTITY, Vector3(x, 12.0, -1.8)))
		cols.append([Color("7a2a24"), Color("5a4a3a")][rng.randi() % 2])
		x += rng.randf_range(2.5, 4.5)
	_defender_nodes.append(Scenery.scatter(self, defender_mesh(), xf, cols, _mat()))


## Ok yağmuru: surdan kalkan oklar yay çizip hedef çemberine düşer ve saplanıp kalır. Uçuş süresini döndürür.
func volley(target: Vector3, radius := 6.0, count := 40) -> float:
	var flight := VOLLEY_FLIGHT
	for i in count:
		var from := Vector3(clampf(target.x + rng.randf_range(-18, 18), -wall_len * 0.45, wall_len * 0.45), rng.randf_range(8.8, 12.5), rng.randf_range(-1.5, 15.6))
		var a := rng.randf() * TAU
		var r := sqrt(rng.randf()) * radius
		var to := target + Vector3(cos(a) * r, 0, sin(a) * r)
		var t := flight * rng.randf_range(0.85, 1.15)
		var v := (to - from) / t
		v.y = (to.y - from.y + 0.5 * 9.8 * t * t) / t
		var mi := MeshInstance3D.new()
		mi.mesh = arrow_mesh()
		mi.material_override = _mat()
		add_child(mi)
		mi.global_position = from
		_flying.append([mi, v, t + 0.05, "arrow", to.y])
		if i % 8 == 0:
			Audio.sfx("whoosh_fly", -18.0, rng.randf_range(0.9, 1.4))
	return flight


func _update_flying(delta: float) -> void:
	for k in range(_flying.size() - 1, -1, -1):
		var f: Array = _flying[k]
		var n: Node3D = f[0]
		if not is_instance_valid(n):
			_flying.remove_at(k)
			continue
		var v: Vector3 = f[1]
		v.y -= 9.8 * delta
		f[1] = v
		n.global_position += v * delta
		f[2] = float(f[2]) - delta
		var is_arrow := f.size() > 3
		if is_arrow and v.length() > 0.1:
			n.look_at(n.global_position + v, Vector3.UP if absf(v.normalized().y) < 0.98 else Vector3.RIGHT)
			n.rotate_object_local(Vector3.UP, PI)
		var ground: float = f[4] if is_arrow else -0.5
		if n.global_position.y <= ground or float(f[2]) <= -1.0:
			_flying.remove_at(k)
			if is_arrow:
				# Uçla toprağa saplanır: gövdenin yarısı dışarıda, iniş açısıyla
				var dir := v.normalized()
				n.global_position = Vector3(n.global_position.x, ground, n.global_position.z) - dir * 0.18
				_stuck.append([n, 18.0])
			else:
				n.queue_free()


func _update_stuck(delta: float) -> void:
	for k in range(_stuck.size() - 1, -1, -1):
		_stuck[k][1] = float(_stuck[k][1]) - delta
		if float(_stuck[k][1]) <= 0.0:
			var n: Node3D = _stuck[k][0]
			if is_instance_valid(n):
				n.queue_free()
			_stuck.remove_at(k)


# ---------------------------------------------------------------- duman

func _smoke() -> void:
	for p: Vector3 in [Vector3(-30, 6, 12), Vector3(-8, 4, 20), Vector3(18, 6, 12), Vector3(40, 3, 24), Vector3(-50, 2, 60), Vector3(55, 2, 70)]:
		Scenery.smoke_column(self, p, night)


## Şehir düştü: hücum durur. Koşanlar, tırmananlar, savunanlar, merdivenler ve yerdeki oklar kalkar;
## ordu blokları ve sancaklar kalır (Fatih'in girişini seyreder).
func victory() -> void:
	set_process(false)
	for grp in _runners:
		(grp[0] as Node3D).visible = false
	for c: Dictionary in _climb:
		if is_instance_valid(c["node"]):
			(c["node"] as Node3D).visible = false
	for n in _defender_nodes:
		n.visible = false
	for n in _ladder_nodes:
		n.visible = false
	for f in _flying:
		if is_instance_valid(f[0]):
			(f[0] as Node).queue_free()
	_flying.clear()
	for f in _stuck:
		if is_instance_valid(f[0]):
			(f[0] as Node).queue_free()
	_stuck.clear()


func _process(delta: float) -> void:
	_t += delta
	_update_runners(delta)
	_update_climbers(delta)
	_update_guns(delta)
	_update_flying(delta)
	_update_stuck(delta)
