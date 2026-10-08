extends Node
## Peribolosta sırada bekleyen yedek ya da iç surdaki mızraklı (Garrison, canlı Person): boş durmaz. Bakınır (gediğe,
## surlara, gökteki oklara), ok yağmurunda bölükçe kalkanının altına çöker, çavuş bağırıp gediği gösterir ve ötekiler
## silahını kaldırıp karşılık verir, "hazır ol" deyince bölükçe mızraklar gediğe doğrulur, yerinde bir iki adım
## kımıldar. Eskiden nizam halinde donuk dikiliyorlardı.
## group: aynı bölüğün paylaştığı sözlük (çökme ve nara hep birlikte); officer: bölüğün çavuşu (bağırır, el sallar).
## wall: sur üstünde (yer değiştirmez, yalnız bakınır ve çöker).

var group: Dictionary = {}
var officer := false
var wall := false
var _t := 0.0
var _dur := 0.0
var _home := Vector3.INF
var _yaw := 0.0
var _look := 0.0
var _lag := 0.0
var _seen := -1.0             # bölüğün son işaretini uyguladığı an
var _shift: Tween


func _ready() -> void:
	_dur = randf_range(0.5, 3.0)
	_lag = randf_range(0.05, 0.4)


func _process(delta: float) -> void:
	var p := get_parent() as Person
	if p == null or not p.visible or p.rig == null or p.rig.lock > 0:
		return
	if _home == Vector3.INF:
		_home = p.position
		_yaw = p.rotation.y
	_beat(delta)
	var now := float(Time.get_ticks_msec()) / 1000.0
	var phase: String = group.get("phase", "idle")
	var since := now - float(group.get("at", -100.0))
	# Bölüğün işareti (ok yağmuru: çök; "hazır ol": mızraklar gediğe; nara: silah kaldır), kişisel gecikmeyle
	var sp := p.find_child("Spear", true, false) as Node3D
	var want: String = {"cover": "crouch", "brace": "thrust_a"}.get(phase, "")
	if since >= _lag and p.rig.activity != want and (want != "" or p.rig.activity in ["crouch", "thrust_a"]):
		p.rig.activity = want
	if p.rig.activity == "thrust_a":
		_spear_level(p, sp)
	else:
		_spear_rest(sp)
	if phase == "cheer" and since >= _lag and _seen < float(group.get("at", 0.0)):
		_seen = float(group.get("at", 0.0))
		p.emote("cheer" if not officer else "wave")
	# Bakınma: önüne (gediğe) dönük kalır, ara ara başını çevirir gibi gövdesiyle yana bakar
	p.rotation.y = lerp_angle(p.rotation.y, _yaw + _look, clampf(delta * 3.0, 0.0, 1.0))
	_t += delta
	if _t < _dur:
		return
	_t = 0.0
	_dur = randf_range(1.5, 4.5)
	if p.rig.activity in ["crouch", "thrust_a"]:
		return
	var r := randf()
	if r < 0.45:
		_look = randf_range(-0.7, 0.7)
	elif r < 0.6:
		_look = 0.0
	elif r < 0.75 and officer:
		p.emote("wave")
	elif r < 0.9 and not wall:
		_step(p)
	else:
		_look = randf_range(-0.25, 0.25)


## Bölüğün ritmi: aynı karede bir kez ilerler (bölükten hangisi işlenirse). Arada bir ok yağmuru (hepsi çöker),
## arada bir çavuşun narası (hepsi silah kaldırır).
func _beat(delta: float) -> void:
	if group.is_empty():
		group["phase"] = "idle"
		group["t"] = 0.0
		group["dur"] = randf_range(3.0, 9.0)
		group["at"] = -100.0
	var f := Engine.get_process_frames()
	if int(group.get("frame", -1)) == f:
		return
	group["frame"] = f
	group["t"] = float(group["t"]) + delta
	if float(group["t"]) < float(group["dur"]):
		return
	group["t"] = 0.0
	group["at"] = float(Time.get_ticks_msec()) / 1000.0
	if group["phase"] != "idle":
		group["phase"] = "idle"
		group["dur"] = randf_range(4.0, 10.0)
		return
	var r := randf()
	if r < 0.45:
		group["phase"] = "cover"
		group["dur"] = randf_range(1.6, 3.0)
	elif r < 0.75:
		group["phase"] = "brace"
		group["dur"] = randf_range(2.5, 4.5)
	else:
		group["phase"] = "cheer"
		group["dur"] = 1.2
		if randf() < 0.5:
			var cam := get_viewport().get_camera_3d()
			var p := get_parent() as Node3D
			if cam and p and cam.global_position.distance_to(p.global_position) < 22.0:
				Audio.sfx(["war_cry", "heave_shout"][randi() % 2], -15.0, randf_range(0.9, 1.1))


## Yerinde bir adım (evinden en çok 0,4 m): yol boşsa ve yanındakinin yerine değilse
func _step(p: Person) -> void:
	if _shift and _shift.is_running():
		return
	var to := _home + Vector3(randf_range(-0.4, 0.4), 0, randf_range(-0.3, 0.3))
	var par := p.get_parent() as Node3D
	if par == null:
		return
	var to_g := par.global_transform * to
	var from := p.global_position + Vector3(0, 1.0, 0)
	var dir := to_g - p.global_position
	if dir.length() < 0.05:
		return
	var q := PhysicsRayQueryParameters3D.create(from, from + dir + dir.normalized() * 0.4)
	if not p.get_world_3d().direct_space_state.intersect_ray(q).is_empty() or Unclip.crowded(p, to_g, 0.7):
		return
	_shift = p.create_tween()
	_shift.tween_property(p, "position", to, 0.7)


## "Hazır ol": mızrak elde, ucu gediğe (öne, hafif yukarı)
func _spear_level(p: Person, sp: Node3D) -> void:
	if sp == null:
		return
	if not sp.has_meta("rest"):
		sp.set_meta("rest", sp.transform)
	var b := p.global_basis.orthonormalized() * Basis(Vector3.RIGHT, 1.42)
	var hand := (sp.get_parent() as Node3D).global_transform * Vector3(0, -0.28, 0.06)
	sp.global_transform = Transform3D(b, hand + b.y * -0.4)


func _spear_rest(sp: Node3D) -> void:
	if sp and sp.has_meta("rest"):
		sp.transform = sp.get_meta("rest")
		sp.remove_meta("rest")
