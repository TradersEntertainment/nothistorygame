class_name EarthChain
extends Node3D
## Hendek dolduran işçi zinciri: toprak yığınında sepeti doldurur (eğilir), yüklü yürür, hendeğin kıyısında sepeti
## aşağı boşaltır (toprak dökülür, toz kalkar), boş döner. Gidiş ve dönüş ayrı şeritte (karşılaşanlar birbirinin
## içinden geçmez); herkes kendi döküm yerine gider. Oyuncu hendeği tek başına dolduruyor gibi durmasın (22o).
##   var ch := EarthChain.new(); add_child(ch); ch.setup(yığın, [döküm yerleri...], kişi, tohum); ch.active = false (durur)
##   ch.duck = true: ok yağmurunda olduğu yere çömelir (sepeti bırakmaz), false: işine döner

const LOAD_SPEED := 1.25
const EMPTY_SPEED := 1.7
const LANE := 0.55

var active := true
var duck := false
var _ducked := false
var pile := Vector3.ZERO
var drops: Array[Vector3] = []
var _men: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()


func setup(p_pile: Vector3, p_drops: Array[Vector3], n: int, seed := 0) -> void:
	_rng.seed = seed
	pile = p_pile
	drops = p_drops
	# Toprak yığını: tümsek ve yanında boş sepetler
	Props.ball(self, 1.6, pile + Vector3(0, -0.35, 0), Color("5a4630"), Vector3(1.2, 0.55, 1.0), 10)
	Props.ball(self, 1.0, pile + Vector3(0.9, -0.2, 0.6), Color("4e3c28"), Vector3(1.0, 0.6, 1.0), 8)
	for i in 4:
		var a := 0.7 + i * 0.45
		Props.cyl(self, 0.22, 0.26, pile + Vector3(cos(a), 0, sin(a)) * 2.3 + Vector3(0, 0.13, 0), Color("9a7a48"), Vector3.ZERO, 8, 0.27)
	var sb := Props.solid(self, Vector3(2.6, 1.0, 2.0), pile + Vector3(0, 0.4, 0), Color.WHITE)
	sb.get_child(0).visible = false
	sb.set_meta("no_climb", true)
	for i in n:
		var p := Person.new({"coat": [Color("8a6a4a"), Color("6a4a3a"), Color("b3262d"), Color("7a6a58"), Color("5a6a48"), Color("a08050")][(i + seed) % 6],
			"pants": Color("e8e0d0"), "hat": ["azap", "bork", "turban", "none", "azap", "turban"][(i * 5 + seed) % 6],
			"mustache": true, "beard": i % 3 == 1, "skin": Color("d9a07a")})
		p.set_meta("no_talk", true)
		add_child(p)
		var d: Vector3 = drops[i % drops.size()]
		# Yığının çevresinde her birinin kendi doldurma yeri (yığına bakan yüzde, sırayla)
		var to_drop := (d - pile)
		to_drop.y = 0.0
		var ang := atan2(to_drop.z, to_drop.x) + (float(i) / maxf(1.0, n - 1.0) - 0.5) * 1.6
		var fill := pile + Vector3(cos(ang), 0, sin(ang)) * 1.75
		var m := {"p": p, "drop": d, "fill": fill, "state": "", "t": 0.0, "load": null}
		_men.append(m)
		# Zincir kurulmuş başlasın: herkes döngünün başka bir yerinde
		var u := float(i) / float(n) + _rng.randf_range(-0.04, 0.04)
		if u < 0.45:
			_load(m)
			p.position = _on_lane(fill, d, u / 0.45, true)
			m["state"] = "out"
		elif u < 0.9:
			p.position = _on_lane(d, fill, (u - 0.45) / 0.45, false)
			m["state"] = "back"
		else:
			p.position = fill
			m["state"] = "fill"
			m["t"] = _rng.randf_range(0.0, 0.8)
			p.set_activity("lean_down")


## Şerit: gidiş (yüklü) yolun sağı, dönüş solu; uçlarda şerit kapanır (doldurma ve döküm yerine varılır)
func _on_lane(a: Vector3, b: Vector3, u: float, out: bool) -> Vector3:
	var dir := b - a
	dir.y = 0.0
	var side := dir.normalized().cross(Vector3.UP) * (LANE if out else -LANE)
	var w := clampf(minf(u, 1.0 - u) * 6.0, 0.0, 1.0)
	return a.lerp(b, u) + side * w


func _process(delta: float) -> void:
	if duck != _ducked:
		_ducked = duck
		for m in _men:
			if is_instance_valid(m["p"]):
				(m["p"] as Person).set_activity("crouch" if duck else {"fill": "lean_down", "tip": "throw_down"}.get(m["state"], ""))
	if duck:
		return
	for m in _men:
		var p: Person = m["p"]
		if not is_instance_valid(p) or not p.visible:
			continue
		m["t"] = float(m["t"]) + delta
		match m["state"]:
			"out":
				if _walk(m, m["fill"], m["drop"], LOAD_SPEED, true, delta):
					m["state"] = "tip"
					m["t"] = 0.0
					p.face_toward(p.global_position + Vector3(0, 0, -1.0))
					p.set_activity("throw_down")
			"tip":
				if m["load"] != null and float(m["t"]) > 0.3:
					_unload(m)
				if float(m["t"]) > 0.9:
					p.set_activity("")
					m["state"] = "back"
					m["u"] = 0.0
			"back":
				if _walk(m, m["drop"], m["fill"], EMPTY_SPEED, false, delta):
					if not active:
						m["state"] = "idle"
						continue
					m["state"] = "fill"
					m["t"] = 0.0
					p.face_toward(pile)
					p.set_activity("lean_down")
			"fill":
				if float(m["t"]) > 1.1:
					p.set_activity("")
					_load(m)
					m["state"] = "out"
					m["u"] = 0.0


## Şeritte ilerle: u (0…1) yolun ne kadarı; varınca true
func _walk(m: Dictionary, a: Vector3, b: Vector3, speed: float, out: bool, delta: float) -> bool:
	var p: Person = m["p"]
	if not m.has("u"):
		# Kurulumda şeride konanın kaldığı yer
		var ab := b - a
		ab.y = 0.0
		m["u"] = clampf((p.position - a).dot(ab) / maxf(ab.length_squared(), 0.01), 0.0, 1.0)
	var length := maxf(Vector2(b.x - a.x, b.z - a.z).length(), 0.1)
	var u := minf(float(m["u"]) + speed * delta / length, 1.0)
	m["u"] = u
	p.position = _on_lane(a, b, u, out)
	return u >= 1.0


func _load(m: Dictionary) -> void:
	var p: Person = m["p"]
	if m["load"] != null:
		return
	var before := p._body.get_child_count()
	p.carry("earth")
	if p._body.get_child_count() > before:
		m["load"] = p._body.get_child(p._body.get_child_count() - 1)


## Sepeti boşaltır: toprak kıyıdan hendeğe dökülür, toz kalkar
func _unload(m: Dictionary) -> void:
	var p: Person = m["p"]
	var ld = m["load"]
	m["load"] = null
	if ld != null and is_instance_valid(ld):
		(ld as Node).queue_free()
	var at := p.global_position + Vector3(0, 0.9, -0.5)
	for k in 4:
		var clod := Props.ball(self, _rng.randf_range(0.08, 0.14), Vector3.ZERO, Color("5a4630"), Vector3.ONE, 5)
		clod.global_position = at + Vector3(_rng.randf_range(-0.2, 0.2), 0, 0)
		var land := at + Vector3(_rng.randf_range(-0.5, 0.5), -3.4, _rng.randf_range(-1.6, -0.8))
		var tw := clod.create_tween()
		tw.tween_property(clod, "global_position", land, _rng.randf_range(0.5, 0.7)).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tw.tween_callback(clod.queue_free)
	Vfx.dust(self, p.global_position + Vector3(0, -1.6, -1.4), 0.45)
	var cam := get_viewport().get_camera_3d()
	if cam and cam.global_position.distance_to(p.global_position) < 14.0 and _rng.randf() < 0.5:
		Audio.sfx("land_thud", -16.0, _rng.randf_range(0.8, 1.0))
