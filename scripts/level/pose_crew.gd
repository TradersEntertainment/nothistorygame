class_name PoseCrew
extends Node3D
## Uzaktaki (çoklu ağ) askerlere iş: her biri kendi döngüsünde poz değiştirir. Okçu yayı gerer ve oku bırakır (ok
## yay çizip ovaya saplanır), kalkanlı ok yağmurunda çöküp kalkar (bölükçe, aynı anda), mızraklı siperden eğilip
## dürter, taşçı taşı kaldırıp aşağı atar. Eskiden iç surun ve sur yolunun uzaktakileri donuk dikiliyordu ("sur
## içinde boş boş nizamlı dikilen askerler hiçbir şey yapmıyor"). Her tür (kaftan/silah) ve her poz bir MultiMesh;
## bir kişi o an yalnız kendi pozunun ağında görünür. add() ile doldurulur, build() ile kurulur.

## Döngüler: [poz, en kısa, en uzun süre, girişte olay]. Olay: "loose" (ok bırakır), "stone" (taş atar)
const CYCLES := {
	"archer": [["aim", 1.0, 1.6, ""], ["", 1.8, 4.6, "loose"]],
	"cover": [["", 2.5, 6.5, ""], ["crouch", 1.4, 3.0, ""]],
	"lean": [["", 1.6, 4.2, ""], ["lean_down", 1.0, 2.6, ""]],
	"thrust": [["", 1.2, 3.4, ""], ["thrust_a", 0.3, 0.5, ""], ["thrust_b", 0.2, 0.32, ""], ["thrust_a", 0.25, 0.4, ""],
		["thrust_b", 0.2, 0.32, ""]],
	"throw": [["", 2.2, 5.5, ""], ["throw_up", 0.6, 0.9, ""], ["throw_down", 0.6, 0.9, "stone"]],
	# Yük kaldırıp indiren (ok demeti, sandık): taşsız
	"pass": [["", 1.4, 3.6, ""], ["throw_up", 0.5, 0.8, ""], ["lean_down", 0.7, 1.2, ""]],
}
const MAX_FLYING := 28

var _hidden := Transform3D(Basis.from_scale(Vector3.ONE * 0.001), Vector3(0, -200, 0))
var _men: Array = []            # {"xf", "kind", "j", "cycle", "step", "t", "dur", "group", "lag", "reach", "shown"}
var _kinds := {}                # anahtar -> {"spec", "n", "mm": {poz: MultiMesh}}
var _groups := {}               # bölük -> {"cycle", "step", "t", "dur", "at"}
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _flying: Array = []         # [MeshInstance3D, hız, kalan süre, yer yüksekliği]
var _rock: Mesh
var _built := false


func _init(seed := 0) -> void:
	_rng.seed = seed


## spec: Crowd.place kalemi gibi ({"side", "coat", "arm", "hat"}). group >= 0: aynı bölüktekiler aynı anda çöker/kalkar.
## reach: okçunun okunun düştüğü uzaklık (m, önüne).
func add(xf: Transform3D, spec: Dictionary, cycle: String, group := -1, reach := Vector2(16.0, 32.0)) -> void:
	var key := "%s|%s|%s|%s" % [spec.get("side", "B"), (spec.get("coat", Color.WHITE) as Color).to_html(), spec.get("arm", ""), spec.get("hat", "")]
	if not _kinds.has(key):
		_kinds[key] = {"spec": spec, "n": 0, "mm": {}}
	var k: Dictionary = _kinds[key]
	var steps: Array = CYCLES[cycle]
	var st := _rng.randi() % steps.size()
	_men.append({"xf": xf, "kind": key, "j": int(k["n"]), "cycle": cycle, "step": st, "t": 0.0,
		"dur": _rng.randf_range(0.0, float(steps[st][2])), "group": group, "lag": _rng.randf_range(0.0, 0.35), "reach": reach,
		"shown": ""})
	k["n"] = int(k["n"]) + 1
	if group >= 0 and not _groups.has(group):
		_groups[group] = {"cycle": cycle, "step": 0, "t": 0.0, "dur": _rng.randf_range(0.5, 4.0), "at": -10.0, "prev": 0}


func size() -> int:
	return _men.size()


func build() -> void:
	if _men.is_empty():
		return
	var lo := Vector3.INF
	var hi := -Vector3.INF
	var need := {}
	for m: Dictionary in _men:
		var o: Vector3 = (m["xf"] as Transform3D).origin
		lo = Vector3(minf(lo.x, o.x), minf(lo.y, o.y), minf(lo.z, o.z))
		hi = Vector3(maxf(hi.x, o.x), maxf(hi.y, o.y), maxf(hi.z, o.z))
		if not need.has(m["kind"]):
			need[m["kind"]] = {}
		for s: Array in CYCLES[m["cycle"]]:
			need[m["kind"]][s[0]] = true
	# Kırpma kutusu: herkesin durduğu yer (gizlenenler kutunun dışında, -200'de)
	var box := AABB(lo - Vector3(2, 1, 2), hi - lo + Vector3(4, 4, 4))
	for key: String in _kinds:
		var k: Dictionary = _kinds[key]
		var spec: Dictionary = k["spec"]
		for pose: String in need[key]:
			var mesh: ArrayMesh = Crowd.civilian(spec.get("coat", Color.WHITE), spec.get("hat", ""), pose) if spec.get("side", "B") == "C" \
				else Crowd.byzantine(spec.get("coat", Color.WHITE), spec.get("arm", ""), pose)
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = mesh
			mm.instance_count = int(k["n"])
			for j in mm.instance_count:
				mm.set_instance_transform(j, _hidden)
			mm.custom_aabb = box
			var mi := MultiMeshInstance3D.new()
			mi.multimesh = mm
			mi.material_override = Crowd.material()
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(mi)
			(k["mm"] as Dictionary)[pose] = mm
	for m: Dictionary in _men:
		_show(m, str(CYCLES[m["cycle"]][int(m["step"])][0]))
	_built = true


func _show(m: Dictionary, pose: String) -> void:
	if str(m["shown"]) == pose:
		return
	var mms: Dictionary = (_kinds[m["kind"]] as Dictionary)["mm"]
	var j: int = m["j"]
	if mms.has(m["shown"]):
		(mms[m["shown"]] as MultiMesh).set_instance_transform(j, _hidden)
	(mms[pose] as MultiMesh).set_instance_transform(j, m["xf"])
	m["shown"] = pose


func _process(delta: float) -> void:
	if not _built or not is_visible_in_tree():
		return
	_time += delta
	# Bölükler (ok yağmurunda hep birlikte kalkanın altına)
	for g: int in _groups:
		var gr: Dictionary = _groups[g]
		gr["t"] = float(gr["t"]) + delta
		if float(gr["t"]) >= float(gr["dur"]):
			var steps: Array = CYCLES[gr["cycle"]]
			gr["prev"] = gr["step"]
			gr["step"] = (int(gr["step"]) + 1) % steps.size()
			gr["t"] = 0.0
			gr["dur"] = _rng.randf_range(float(steps[gr["step"]][1]), float(steps[gr["step"]][2]))
			gr["at"] = _time
	for m: Dictionary in _men:
		var steps: Array = CYCLES[m["cycle"]]
		var g: int = m["group"]
		if g >= 0:
			var gr: Dictionary = _groups[g]
			var st: int = gr["step"] if _time - float(gr["at"]) >= float(m["lag"]) else gr["prev"]
			if st != int(m["step"]):
				m["step"] = st
				_enter(m, steps[st])
			continue
		m["t"] = float(m["t"]) + delta
		if float(m["t"]) >= float(m["dur"]):
			var st := (int(m["step"]) + 1) % steps.size()
			m["step"] = st
			m["t"] = 0.0
			m["dur"] = _rng.randf_range(float(steps[st][1]), float(steps[st][2]))
			_enter(m, steps[st])
	_fly(delta)


func _enter(m: Dictionary, step: Array) -> void:
	_show(m, str(step[0]))
	match str(step[3]):
		"loose":
			_loose(m)
		"stone":
			_stone(m)


## Ok: kişinin önüne (ovaya), reach uzaklığına; dış surun üstünden aşacak kadar yüksek yay
func _loose(m: Dictionary) -> void:
	if _flying.size() >= MAX_FLYING:
		return
	var xf: Transform3D = global_transform * (m["xf"] as Transform3D)
	var fwd := xf.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized() if fwd.length() > 0.1 else Vector3.BACK
	var side := fwd.cross(Vector3.UP)
	var reach: Vector2 = m["reach"]
	var from := xf.origin + Vector3(0, 1.45, 0) + fwd * 0.5
	var to := xf.origin + fwd * _rng.randf_range(reach.x, reach.y) + side * _rng.randf_range(-5.0, 5.0)
	to.y = Assault.ground_y(to.x, to.z)
	var t := _rng.randf_range(1.5, 2.1) if reach.x > 24.0 else _rng.randf_range(1.2, 1.8)
	var v := (to - from) / t
	v.y = (to.y - from.y + 0.5 * 9.8 * t * t) / t
	var mi := MeshInstance3D.new()
	mi.mesh = Assault.arrow_mesh()
	mi.material_override = Crowd.material()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	mi.global_position = from
	_flying.append([mi, v, 10.0 + t, to.y])
	var cam := get_viewport().get_camera_3d()
	if cam and cam.global_position.distance_to(from) < 14.0:
		Audio.sfx("whoosh_fly", -18.0, _rng.randf_range(1.2, 1.5))


## Taş: elinden önüne, sur dibine düşer
func _stone(m: Dictionary) -> void:
	if _flying.size() >= MAX_FLYING:
		return
	if _rock == null:
		var sm := SphereMesh.new()
		sm.radius = 0.16
		sm.height = 0.28
		sm.radial_segments = 6
		sm.rings = 3
		sm.material = Props.mat(Color("8a8278"))
		_rock = sm
	var xf: Transform3D = global_transform * (m["xf"] as Transform3D)
	var fwd := xf.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized() if fwd.length() > 0.1 else Vector3.BACK
	var from := xf.origin + Vector3(0, 1.3, 0) + fwd * 0.7
	var land := xf.origin + fwd * _rng.randf_range(1.6, 2.6)
	var gy := Assault.ground_y(land.x, land.z)
	var mi := MeshInstance3D.new()
	mi.mesh = _rock
	add_child(mi)
	mi.global_position = from
	_flying.append([mi, fwd * 1.2 + Vector3(0, 0.6, 0), 8.0, gy])


func _fly(delta: float) -> void:
	for k in range(_flying.size() - 1, -1, -1):
		var a: Array = _flying[k]
		var n := a[0] as Node3D
		a[2] = float(a[2]) - delta
		if not is_instance_valid(n) or float(a[2]) <= 0.0:
			if is_instance_valid(n):
				n.queue_free()
			_flying.remove_at(k)
			continue
		var v: Vector3 = a[1]
		if v == Vector3.ZERO:
			continue       # saplanmış / düşmüş: süresi dolunca kalkar
		v.y -= 9.8 * delta
		a[1] = v
		n.global_position += v * delta
		if (n as MeshInstance3D).mesh != _rock:
			n.look_at(n.global_position + v, Vector3.UP if absf(v.normalized().y) < 0.98 else Vector3.RIGHT)
			n.rotate_object_local(Vector3.UP, PI)
		if n.global_position.y <= float(a[3]):
			n.global_position.y = float(a[3])
			if (n as MeshInstance3D).mesh != _rock:
				n.global_position -= v.normalized() * 0.18
			a[1] = Vector3.ZERO
			a[2] = minf(float(a[2]), 6.0)
