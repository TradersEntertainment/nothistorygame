class_name WallCrowd
extends Node3D
## Tüfek sahnesinde surdaki kalabalık gerçek olur (GunRange "crowd_box"): hedef kutusundaki çoklu ağ figürleri (Crowd.place:
## Garrison'ın surdaki savunanları) gizlenir, yerlerine vurulabilen askerler konur. Okçular ok atar, birkaçı tüfekle
## karşılık verir (fitil parlar, duman, çatırtı); oklar oyuncunun çevresine saplanır, ara sıra biri değer. Eskiden yalnız
## dört "mazgaldan bakan" vurulabiliyordu; surdaki öteki herkes süstü ve kimse karşılık vermiyordu.
## Sahne bitince vurulmayanlar yine figür olur; vurulanların figürü gizli kalır.

const HIDDEN := Transform3D(Basis(Vector3(0.001, 0, 0), Vector3(0, 0.001, 0), Vector3(0, 0, 0.001)), Vector3(0, -200, 0))
const ARROW_HIT := 0.18        # okun oyuncuya değme olasılığı
const GUN_HIT := 0.22
const MIN_HP := 30.0           # karşılık ateşi oyuncuyu bu canın altına indirmez (sahne yenilgiyle bitmez)

var men: Array[Soldier] = []
var player: Player
var _slots: Array = []          # [soldier, [[mmi, i, özgün dönüşüm], ...]]
var _flying: Array = []         # [ok, hız, kalan süre, saplanacağı y]
var _t := 2.5
var _rng := RandomNumberGenerator.new()


## box: dünya koordinatında kutu; side: düşman tarafı ("B" Bizans); cap: en çok kaç figür canlanır (oyuncuya yakın olanlar)
## avoid: sahnenin kendi hedeflerinin yerleri (mazgaldan bakanlar): oraya ikinci asker konmaz (figür yalnız gizlenir)
static func make(scene: Node3D, p: Player, box: AABB, side := "B", cap := 22, seed := 0, avoid: Array = []) -> WallCrowd:
	var w := WallCrowd.new()
	w.player = p
	w._rng.seed = seed + 1453
	scene.add_child(w)
	w._convert(scene, box, side, cap, avoid)
	return w


func _convert(scene: Node3D, box: AABB, side: String, cap: int, avoid: Array) -> void:
	var cand: Array = []
	for n in scene.find_children("*", "MultiMeshInstance3D", true, false):
		var mmi := n as MultiMeshInstance3D
		if not mmi.has_meta("crowd_spec") or not mmi.is_visible_in_tree():
			continue
		var spec: Dictionary = mmi.get_meta("crowd_spec")
		if str(spec.get("side", "O")) != side or str(spec.get("pose", "")) in ["dead", "sit", "crouch"]:
			continue
		var mm := mmi.multimesh
		for i in mm.instance_count:
			var lx := mm.get_instance_transform(i)
			if lx.basis.get_scale().x < 0.1:
				continue
			var gx := mmi.global_transform * lx
			if box.has_point(gx.origin):
				cand.append([gx.origin.distance_to(player.global_position), mmi, i, lx, gx, spec])
	cand.sort_custom(func(a, b): return float(a[0]) < float(b[0]))
	var used := 0
	for c in cand:
		if used >= cap:
			break
		# Aynı yerde iki figür (yakın ve uzak kopya ya da üst üste) iki asker olmasın
		var gx: Transform3D = c[4]
		var taken := false
		for a: Vector3 in avoid:
			if Vector2(a.x - gx.origin.x, a.z - gx.origin.z).length() < 1.0 and absf(a.y - gx.origin.y) < 2.5:
				taken = true
		if taken:
			_hide(c[1], c[2])       # mazgaldan bakan hedefin içinde duran figür
			continue
		var dup := false
		for s: Array in _slots:
			if (s[0] as Soldier).global_position.distance_to(gx.origin) < 0.5:
				(s[1] as Array).append([c[1], c[2], c[3]])
				_hide(c[1], c[2])
				dup = true
				break
		if dup:
			continue
		var spec: Dictionary = c[5]
		var s := Soldier.new(spec.get("coat", Color("5a6a7a")), "stand", "helm")
		s.set_meta("no_talk", true)
		s.set_meta("climber", true)
		add_child(s)
		s.global_position = gx.origin
		var f := gx.basis.z
		s.global_rotation = Vector3(0, atan2(f.x, f.z), 0)
		var arm := str(spec.get("arm", ""))
		var role := "spear"
		if arm == "bow":
			s.equip("bow")
			role = "bow"
		elif used % 5 == 2:
			s.equip("handgun")
			role = "gun"
		else:
			s.equip("spear")
		s.set_meta("role", role)
		men.append(s)
		_slots.append([s, [[c[1], c[2], c[3]]]])
		_hide(c[1], c[2])
		used += 1
	# Uzak kopyaları (siluet) da gizle: aynı figürün uzaktan görünen eşi
	for sl: Array in _slots:
		for it: Array in (sl[1] as Array).duplicate():
			var twin = (it[0] as Node).get_meta("crowd_twin", null)
			if twin is MultiMeshInstance3D and is_instance_valid(twin):
				(sl[1] as Array).append([twin, it[1], (twin as MultiMeshInstance3D).multimesh.get_instance_transform(it[1])])
				_hide(twin, it[1])


func _hide(mmi: MultiMeshInstance3D, i: int) -> void:
	var hid: Dictionary = mmi.get_meta("hidden", {})
	hid[i] = true
	mmi.set_meta("hidden", hid)
	mmi.multimesh.set_instance_transform(i, HIDDEN)


## Sahne bitti: vurulmayanlar yine figür (kıpırdamaya devam eder), canlı askerler kalkar
func finish() -> void:
	for sl: Array in _slots:
		var s := sl[0] as Soldier
		var shot := not is_instance_valid(s) or s.has_meta("gun_down")
		if shot:
			continue
		for it: Array in sl[1]:
			var mmi := it[0] as MultiMeshInstance3D
			if not is_instance_valid(mmi):
				continue
			var hid: Dictionary = mmi.get_meta("hidden", {})
			hid.erase(it[1])
			mmi.multimesh.set_instance_transform(it[1], it[2])
	for a: Array in _flying:
		if is_instance_valid(a[0]):
			(a[0] as Node).queue_free()
	_flying.clear()
	queue_free()


func _alive() -> Array[Soldier]:
	var out: Array[Soldier] = []
	for s in men:
		if is_instance_valid(s) and s.visible and not s.has_meta("gun_down"):
			out.append(s)
	return out


func _process(delta: float) -> void:
	_fly(delta)
	if player == null or not is_instance_valid(player):
		return
	_t -= delta
	if _t > 0.0:
		return
	_t = _rng.randf_range(1.3, 2.6)
	var live := _alive()
	if live.is_empty():
		return
	# Atıcılar: okçular ve tüfekçiler (ötekiler ara sıra taş atamaz; uzak)
	var shooters := live.filter(func(s: Soldier): return s.get_meta("role", "") != "spear")
	if shooters.is_empty():
		return
	var s: Soldier = shooters[_rng.randi() % shooters.size()]
	s.face_toward(player.global_position)
	if s.get_meta("role") == "gun":
		_gun_shot(s)
	else:
		_arrow(s)


## Ok: oyuncunun çevresine (çoğu kez ıska) yay çizerek iner, değdiği yere saplanır
func _arrow(s: Soldier) -> void:
	if _flying.size() >= 24:
		return
	var from := s.global_position + Vector3(0, 1.45, 0)
	var hit := _rng.randf() < ARROW_HIT and not GameState.autotest
	var aim := player.global_position + Vector3(0, 1.0, 0)
	var to := aim if hit else _miss_point()
	var t := clampf(from.distance_to(to) / 26.0, 0.7, 1.9)
	var v := (to - from) / t
	v.y = (to.y - from.y + 0.5 * 9.8 * t * t) / t
	var mi := MeshInstance3D.new()
	mi.mesh = Assault.arrow_mesh()
	mi.material_override = Crowd.material()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	mi.global_position = from
	_flying.append([mi, v, t + 8.0, to.y, hit, t])
	Audio.sfx("whoosh_fly", -14.0, _rng.randf_range(1.2, 1.5))


## Tüfek: fitil parlar, namludan alev ve duman, gecikmeli çatırtı; kurşun yanından geçer ya da değer
func _gun_shot(s: Soldier) -> void:
	var at := s.global_position + s.global_transform.basis * Vector3(0.14, 1.4, 0.85)
	var dir := (player.global_position + Vector3(0, 1.2, 0) - at).normalized()
	Handgun.blast_fx(get_parent() as Node3D, at, dir, -12.0)
	var hit := _rng.randf() < GUN_HIT and not GameState.autotest
	var d := at.distance_to(player.global_position)
	get_tree().create_timer(clampf(d / 340.0, 0.03, 0.2)).timeout.connect(func():
		if not is_instance_valid(player):
			return
		if hit:
			_wound(6.0, at)
		else:
			Audio.sfx("pick_tap", -10.0, 2.2)
			Vfx.dust(get_parent() as Node3D, _miss_point(), 0.25))


func _wound(amount: float, from: Vector3) -> void:
	if player.hp - amount < MIN_HP:
		Fx.trauma(0.25)
		Audio.sfx("pick_tap", -6.0, 2.0)
		return
	player.hurt(amount, from, true)


## Oyuncunun yanına (1–3 m) bir nokta: kulenin tahtası, korkuluk ya da aşağıdaki zemin
func _miss_point() -> Vector3:
	var p := player.global_position
	var a := _rng.randf() * TAU
	var r := _rng.randf_range(1.0, 3.0)
	var q := p + Vector3(cos(a) * r, 2.0, sin(a) * r)
	var ray := PhysicsRayQueryParameters3D.create(q, q + Vector3(0, -40.0, 0), 1)
	ray.exclude = [player.get_rid()]
	var hitr := get_world_3d().direct_space_state.intersect_ray(ray)
	return (hitr["position"] as Vector3) if not hitr.is_empty() else Vector3(q.x, p.y, q.z)


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
			continue
		a[5] = float(a[5]) - delta
		v.y -= 9.8 * delta
		a[1] = v
		n.global_position += v * delta
		n.look_at(n.global_position + v, Vector3.UP if absf(v.normalized().y) < 0.98 else Vector3.RIGHT)
		n.rotate_object_local(Vector3.UP, PI)
		if float(a[5]) <= 0.0 or n.global_position.y <= float(a[3]):
			a[1] = Vector3.ZERO
			if bool(a[4]):
				n.visible = false
				_wound(5.0, n.global_position - v.normalized() * 6.0)
			else:
				Audio.sfx("pick_tap", -16.0, 1.6)
