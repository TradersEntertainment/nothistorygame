class_name SiegeChaos
extends Node3D
## Sur içi kargaşa (son hücum, savunan tarafı): peribolosta koşuşan savunanlar ve halk. Yedekler gediğe koşar,
## yaralılar ve kaçanlar geri, haberciler surun boyunca; arada duraksayıp geri dönen, yön değiştiren. Yerinde
## kalanlar: yerde yatan yaralının başına çökmüş arkadaşı, kalkanın altına sinmiş bölük, dua eden rahip ve kadınlar,
## taş yığınının başındakiler. (Eskiden sur içi boştu: "savunan çok az, kaos kargaşa olması gerekmez mi")
##
## Koşanlar donmuş model kopyalarıdır (Crowd; iki koşu pozu ve duruş, MultiMesh): yüzlercesi ucuzdur. Yolları kurulurken
## çarpışma gövdelerine (sandık, merdiven, kazan, barikat) ve sahnedeki insanlara karşı denenir; geçemeyen yol atılır.
## Oyuncuya yaklaşan yana açılır, olmazsa durup geri döner. Kök "garrison" grubunda: Garrison.clear ile kalkar.
##
##   var ch := SiegeChaos.new(); ch.area = Rect2(...); ch.avoid = [[nokta, yarıçap], ...]; ch.player = player
##   add_child(ch)          # kurulum iki fizik karesi sonra (çarpışma gövdeleri yerleşsin)
##   ch.rout()              # bozgun: herkes iç sura doğru kaçar, ucuna varan gözden kaybolur (kapıdan çıktı)

const POSES := ["run_a", "run_b", ""]
const CIV_COATS := [Color("5a4a3a"), Color("6a5a4a"), Color("3a3430"), Color("7a6a5a"), Color("4a4038")]

var area := Rect2(-44.0, 1.4, 88.0, 10.6)     # XZ: koşulan kuşak
var avoid: Array = []                          # [[Vector3, yarıçap]]: yol buralara girmez (etkileşim yerleri, merdiven ayağı)
var avoid_lines: Array = []                    # [[a, b, yarı en]]: yerinde kalanlar bu çizgilere konmaz (oyuncunun yolu)
var start_active := true                       # false: koşanlar başta yok, set_active(true) ile görüş dışından katılır
var n_run := 96
var n_static := 44
var civ_ratio := 0.3                           # koşanlardan halk (başı açık, kaftanlı) oranı
var seed := 26
var player: Node3D
var built := false
var bells := false                             # şehrin çanları (29 Mayıs sabahı bütün kiliselerde alarm çalındı)
var static_clear_x := 0.0                     # yerinde kalanlar |x| bundan küçükse konmaz (dövüşün döndüğü gedik çevresi)
var block_pts := PackedVector3Array()          # yerinde kalanlar: oyuncu kişi gibi yumuşakça itilir (Player)

var _rng := RandomNumberGenerator.new()
var _segs: Array = []        # [a, b, ys (PackedFloat32Array), len]
var _run: Array = []         # her koşan: {seg, t, dir, speed, pause, side, grp, j, gone}
var _groups: Array = []      # [[MultiMesh (POSES sırasıyla)], koşan sayısı]
var _people: Array[Vector3] = []
var _obst: Array = []        # yerinde kalanlar [yer, yarıçap]: koşu yolu bunların üstünden geçmez
var _lanes: Array = []       # BattleExtras şeritleri [a, b, yarı en]: yerinde kalanlar onların yolunu kesmez
var _hidden := Transform3D(Basis.from_scale(Vector3.ONE * 0.001), Vector3(0, -200, 0))
var _t := 0.0
var _rout := false
var _active := true
var _cry_t := 2.0
var _bell_t := 4.0
var _shape := CapsuleShape3D.new()


func _ready() -> void:
	add_to_group("garrison")
	add_to_group("crowd_block")
	_rng.seed = seed
	_active = start_active
	_shape.radius = 0.3
	_shape.height = 1.3
	set_process(false)
	_build.call_deferred()


func _build() -> void:
	# Çarpışma gövdeleri ve sahnedeki insanlar yerleşsin (bölüm kurulumu bu karede sürüyor)
	for i in 3:
		await get_tree().physics_frame
	if not is_inside_tree():
		return
	for n in get_tree().get_nodes_in_group("persons"):
		var p := n as Node3D
		if p and p.is_visible_in_tree() and area.grow(2.0).has_point(Vector2(p.global_position.x, p.global_position.z)):
			_people.append(p.global_position)
	# Canlı koşanların (BattleExtras) şeritleri: donmuş kalabalığın katı gövdesi şeridin yanına düşerse koşanlar yana
	# kaçamaz, bir yere sıkışıp iç içe giriyordu (VISAUDIT overlap)
	for bx in get_tree().get_nodes_in_group("battle_extras"):
		var rs = bx.get("_runners")
		if rs is Array:
			for r in rs:
				if r is Dictionary and r.has("a"):
					_lanes.append([r["a"], r["b"], float(r.get("w", 0.7)) + 1.0])
	_lanes.append_array(avoid_lines)
	# Önce yerinde kalanlar (geniş yer bulsunlar), koşu yolları onların çevresinden geçer
	_make_static()
	_make_segments()
	_make_runners()
	built = true
	set_process(true)
	if GameState.autotest:
		print("SIEGECHAOS segs=%d runners=%d static=%d" % [_segs.size(), _run.size(), _static_n])


# ---------------------------------------------------------------- yollar

func _make_segments() -> void:
	var want := maxi(8, n_run / 2)
	var tries := 0
	while _segs.size() < want and tries < want * 40:
		tries += 1
		var a := Vector3(_rng.randf_range(area.position.x, area.end.x), 0, _rng.randf_range(area.position.y, area.end.y))
		var b: Vector3
		var r := _rng.randf()
		if r < 0.5:
			# Surun boyunca (haberci, yer değiştiren bölük)
			var ang := _rng.randf_range(-0.35, 0.35) + (PI if _rng.randf() < 0.5 else 0.0)
			b = a + Vector3(cos(ang), 0, sin(ang)) * _rng.randf_range(7.0, 22.0)
		elif r < 0.8:
			# Dış sura doğru (yedekler koşar) ya da ondan geri (yaralı, kaçan)
			b = Vector3(a.x + _rng.randf_range(-8.0, 8.0), 0, area.end.y - _rng.randf_range(0.0, 1.5))
		else:
			# İç sura doğru (kapıya, taşa, suya)
			b = Vector3(a.x + _rng.randf_range(-8.0, 8.0), 0, area.position.y + _rng.randf_range(0.0, 1.2))
		b.x = clampf(b.x, area.position.x, area.end.x)
		b.z = clampf(b.z, area.position.y, area.end.y)
		if a.distance_to(b) < 4.0:
			continue
		var ys := _clear_line(a, b)
		if ys.is_empty():
			continue
		_segs.append([a, b, ys, a.distance_to(b)])


## Yol boyunca (0,5 m'de bir) zemin ve gövde boşluğu: zemin ışınla bulunur, ani basamak (> 0,35 m) yolu bozar; gövde
## boyunda kapsül bir şeye değerse ya da bir insana 0,6 m'den yakın geçerse yol atılır. Boşsa boş dizi.
func _clear_line(a: Vector3, b: Vector3) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	var space := get_world_3d().direct_space_state
	var n := maxi(2, ceili(a.distance_to(b) / 0.5))
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = _shape
	var prev := NAN
	for k in n + 1:
		var p := a.lerp(b, float(k) / n)
		for av: Array in avoid:
			var c: Vector3 = av[0]
			if Vector2(p.x - c.x, p.z - c.z).length() < float(av[1]):
				return PackedFloat32Array()
		for pp in _people:
			if Vector2(p.x - pp.x, p.z - pp.z).length() < 0.6:
				return PackedFloat32Array()
		for ob: Array in _obst:
			var oc: Vector3 = ob[0]
			if Vector2(p.x - oc.x, p.z - oc.z).length() < float(ob[1]) + 0.35:
				return PackedFloat32Array()
		var ray := PhysicsRayQueryParameters3D.create(Vector3(p.x, 4.0, p.z), Vector3(p.x, -3.0, p.z))
		var hit := space.intersect_ray(ray)
		if hit.is_empty():
			return PackedFloat32Array()
		var y: float = hit["position"].y
		if y > 1.2 or (not is_nan(prev) and absf(y - prev) > 0.35):
			return PackedFloat32Array()     # bir şeyin üstüne (sandık, merdiven) çıkıyor ya da basamak
		q.transform = Transform3D(Basis.IDENTITY, Vector3(p.x, y + 1.0, p.z))
		if not space.intersect_shape(q, 1).is_empty():
			return PackedFloat32Array()
		out.append(y)
		prev = y
	return out


func _seg_point(s: Array, t: float) -> Vector3:
	var a: Vector3 = s[0]
	var b: Vector3 = s[1]
	var ys: PackedFloat32Array = s[2]
	var f := clampf(t, 0.0, 1.0) * (ys.size() - 1)
	var i := mini(int(f), ys.size() - 2)
	var p := a.lerp(b, t)
	p.y = lerpf(ys[i], ys[i + 1], f - i)
	return p


# ---------------------------------------------------------------- koşanlar

func _make_runners() -> void:
	if _segs.is_empty():
		return
	# Tür (renk/silah) başına bir MultiMesh ailesi: savunan altı kaftan rengi, halk iki tür
	var kinds: Array = []
	for c: Color in Crowd.BYZ_COATS:
		kinds.append(["B", c, ["spear", "spear_shield", ""][kinds.size() % 3]])
	kinds.append(["C", CIV_COATS[0], ""])
	kinds.append(["C", CIV_COATS[3], ""])
	var members: Array = []
	for k in kinds.size():
		members.append([])
	for i in n_run:
		var civ := _rng.randf() < civ_ratio
		var k := (kinds.size() - 1 - (i % 2)) if civ else (i % Crowd.BYZ_COATS.size())
		var s := i % _segs.size()
		var r := {"seg": s, "t": _rng.randf(), "dir": 1.0 if _rng.randf() < 0.5 else -1.0, "shown": start_active,
			"speed": _rng.randf_range(2.6, 4.6) if not civ else _rng.randf_range(2.2, 3.6),
			"pause": 0.0, "side": 0.0, "grp": k, "j": (members[k] as Array).size(), "gone": false, "yaw": 0.0}
		(members[k] as Array).append(_run.size())
		_run.append(r)
	for k in kinds.size():
		var cnt := (members[k] as Array).size()
		var mms: Array = []
		if cnt > 0:
			for pose: String in POSES:
				var mesh: ArrayMesh = Crowd.byzantine(kinds[k][1], kinds[k][2], pose) if kinds[k][0] == "B" \
					else Crowd.civilian(kinds[k][1], "", pose)
				var mm := MultiMesh.new()
				mm.transform_format = MultiMesh.TRANSFORM_3D
				mm.mesh = mesh
				mm.instance_count = cnt
				for j in cnt:
					mm.set_instance_transform(j, _hidden)
				var mi := MultiMeshInstance3D.new()
				mi.multimesh = mm
				mi.material_override = Crowd.material()
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				# Dönüşümler her kare değişir: kırpma kutusu bütün kuşağı kapsasın
				mm.custom_aabb = AABB(Vector3(area.position.x - 2.0, -3.0, area.position.y - 2.0), Vector3(area.size.x + 4.0, 8.0, area.size.y + 4.0))
				add_child(mi)
				mms.append(mm)
		_groups.append([mms, cnt])


func _process(delta: float) -> void:
	_t += delta
	var pp := Vector3.INF
	if player and is_instance_valid(player):
		pp = player.global_position
	var cam := get_viewport().get_camera_3d()
	for i in _run.size():
		_step(i, delta, pp, cam)
	if _active and not _rout:
		_sounds(delta)


## Kargaşanın sesi: uzaktan narası, kılıç şakırtısı, bağırış, düşenin çığlığı; şehrin çanları
func _sounds(delta: float) -> void:
	_cry_t -= delta
	if _cry_t <= 0.0:
		_cry_t = _rng.randf_range(2.2, 5.5)
		var pick := _rng.randi() % 4
		Audio.sfx(["war_cry", "heave_shout", "sword_clash", "fall_scream"][pick], [-19.0, -17.0, -21.0, -23.0][pick], _rng.randf_range(0.88, 1.12))
	if bells:
		_bell_t -= delta
		if _bell_t <= 0.0:
			_bell_t = _rng.randf_range(9.0, 16.0)
			Audio.sfx("church_bell", -21.0, _rng.randf_range(0.78, 0.92))


func _step(i: int, delta: float, pp: Vector3, cam: Camera3D) -> void:
	var r: Dictionary = _run[i]
	var mms: Array = _groups[int(r["grp"])][0]
	var j: int = r["j"]
	if r["gone"]:
		return
	if bool(r["shown"]) != _active:
		# Katılma/çekilme yalnız oyuncunun görmediği yerde (gözünün önünde belirip kaybolmasın)
		var here := _seg_point(_segs[int(r["seg"])], float(r["t"])) + Vector3(0, 1.0, 0)
		if cam == null or not cam.is_position_in_frustum(here) or cam.global_position.distance_to(here) > 70.0:
			r["shown"] = _active
	if not bool(r["shown"]):
		for m in mms.size():
			(mms[m] as MultiMesh).set_instance_transform(j, _hidden)
		r["t"] = fmod(float(r["t"]) + delta * 0.05, 1.0)
		return
	var s: Array = _segs[int(r["seg"])]
	var a: Vector3 = s[0]
	var b: Vector3 = s[1]
	var len: float = s[3]
	var pose := 2
	if float(r["pause"]) > 0.0:
		r["pause"] = float(r["pause"]) - delta
	else:
		r["t"] = float(r["t"]) + float(r["dir"]) * float(r["speed"]) * delta / len
		if float(r["t"]) >= 1.0 or float(r["t"]) <= 0.0:
			r["t"] = clampf(float(r["t"]), 0.0, 1.0)
			if _rout and _end_z(s, float(r["t"])) <= area.position.y + 2.5:
				# Bozgunda iç sura (kapıya) varan gözden kaybolur
				r["gone"] = true
				for m in mms.size():
					(mms[m] as MultiMesh).set_instance_transform(j, _hidden)
				return
			r["dir"] = -float(r["dir"])
			# Kimi ucunda bir an duraksar, etrafına bakınır (kargaşa: nereye koşacağını bilemeyen)
			if _rng.randf() < 0.45 and not _rout:
				r["pause"] = _rng.randf_range(0.3, 1.6)
		pose = 0 if fmod(_t * float(r["speed"]) * 0.55 + i * 0.37, 1.0) < 0.5 else 1
	var p := _seg_point(s, float(r["t"]))
	var fwd := (b - a).normalized() * float(r["dir"])
	var perp := Vector3(-fwd.z, 0, fwd.x)
	# Oyuncuya yaklaşınca yana açılır (en çok 0,6 m); yine de dibindeyse durur ve geri döner
	var side_want := 0.0
	if pp.x != INF:
		var d := Vector2(pp.x - p.x, pp.z - p.z)
		var ahead := d.dot(Vector2(fwd.x, fwd.z))
		if d.length() < 1.6 and ahead > -0.4:
			var lat := d.dot(Vector2(perp.x, perp.z))
			side_want = -signf(lat if absf(lat) > 0.01 else 1.0) * 0.6
			if d.length() < 0.75 and float(r["pause"]) <= 0.0:
				r["dir"] = -float(r["dir"])
				r["pause"] = 0.25
	r["side"] = move_toward(float(r["side"]), side_want, delta * 2.5)
	p += perp * float(r["side"])
	if pose < 2:
		p.y += absf(sin(fmod(_t * float(r["speed"]) * 0.55 + i * 0.37, 1.0) * TAU)) * 0.07
	var yaw := atan2(fwd.x, fwd.z)
	if pose == 2:
		# Duraksayan: başını çevirip bakınır
		yaw += sin(_t * 1.7 + i) * 0.9
	var xf := Transform3D(Basis(Vector3.UP, yaw), p)
	for m in mms.size():
		(mms[m] as MultiMesh).set_instance_transform(j, xf if m == pose else _hidden)


func _end_z(s: Array, t: float) -> float:
	return (s[1] as Vector3).z if t >= 0.5 else (s[0] as Vector3).z


## Koşanlar sahneye katılır (true) ya da çekilir (false): oyuncunun görmediği yerde, birer birer.
func set_active(on: bool) -> void:
	_active = on


## Bozgun: herkes iç sura (alçak z) doğru, daha hızlı koşar; ucuna varan kapıdan çıkmış sayılır.
func rout() -> void:
	_rout = true
	for r: Dictionary in _run:
		var s: Array = _segs[int(r["seg"])]
		var a: Vector3 = s[0]
		var b: Vector3 = s[1]
		r["dir"] = 1.0 if b.z < a.z else -1.0
		r["speed"] = float(r["speed"]) * 1.25
		r["pause"] = 0.0


# ---------------------------------------------------------------- yerinde kalanlar

var _static_n := 0

## Yaralının başında diz çökmüş arkadaşı, kalkanın altına sinmiş üçlü, dua eden rahip ve kadınlar, ayakta bekleyen
## yedekler. Yerleri kapsülle denenir; oyuncu içlerinden geçmez (block_pts).
func _make_static() -> void:
	var items: Array = []
	# Döngülü olanlar (kalkanın altına bölükçe çöküp kalkanlar, yük kaldıranlar) donuk durmaz: PoseCrew
	var crew := PoseCrew.new(seed + 5)
	add_child(crew)
	var tries := 0
	while _static_n < n_static and tries < n_static * 30:
		tries += 1
		var c := Vector3(_rng.randf_range(area.position.x + 1.0, area.end.x - 1.0), 0, _rng.randf_range(area.position.y + 0.4, area.end.y - 0.4))
		if absf(c.x) < static_clear_x:
			continue
		var kind := _rng.randi() % 5
		var spots: Array = _vignette(kind, c)
		var ok := true
		var placed: Array = []
		for sp: Array in spots:
			var p: Vector3 = sp[0]
			var y := _spot_y(p, float(sp[3]))
			if is_nan(y):
				ok = false
				break
			placed.append([p + Vector3(0, y, 0), sp[1], sp[2], sp[3]])
		if not ok:
			continue
		for pl: Array in placed:
			var xf: Transform3D = pl[1]
			xf.origin = (pl[0] as Vector3) + xf.origin
			var spec: Dictionary = pl[2]
			if spec.has("cycle"):
				crew.add(xf, spec, spec["cycle"], tries if spec["cycle"] == "cover" else -1)
			else:
				items.append([xf, spec])
			_people.append(pl[0])
			_obst.append([pl[0], pl[3]])
			block_pts.append(pl[0])
			_static_n += 1
	if not items.is_empty():
		# Katı değil (bkz. block_pts): katı gövdenin üstünü başka kişilerin zemin ışını zemin sanıyordu
		Crowd.place(self, items, true, false)
	crew.build()


## Bir küme: [[yer (y'siz), yerel dönüşüm (yükseklik farkı kökende), spec, yarıçap], ...]
func _vignette(kind: int, c: Vector3) -> Array:
	var yaw := _rng.randf() * TAU
	var b := Basis(Vector3.UP, yaw)
	var i := _rng.randi()
	match kind:
		0:
			# Yerde yatan yaralı, başında diz çökmüş arkadaşı
			var lie := Transform3D(b * Basis(Vector3.RIGHT, -PI * 0.5), Vector3(0, 0.13, 0))
			var kneel := Transform3D(Basis(Vector3.UP, yaw + PI * 0.5), Vector3.ZERO)
			return [[c, lie, {"side": "B", "coat": Crowd.BYZ_COATS[i % 6], "arm": "", "pose": "dead"}, 1.0],
				[c + b * Vector3(0.9, 0, 0.2), kneel, {"side": "B", "coat": Crowd.BYZ_COATS[(i + 2) % 6], "arm": "", "pose": "crouch"}, 0.45]]
		1:
			# Ok yağmurunda kalkanın altına sinen üçlü: yağmur dinince doğrulup bakar, yeni yağmurda yine çöker
			var out: Array = []
			for k in 3:
				out.append([c + b * Vector3((k - 1) * 0.85, 0, (k % 2) * 0.5), Transform3D(Basis(Vector3.UP, yaw + _rng.randf_range(-0.3, 0.3)), Vector3.ZERO),
					{"side": "B", "coat": Crowd.BYZ_COATS[(i + k) % 6], "arm": "spear_shield", "pose": "crouch", "cycle": "cover"}, 0.45])
			return out
		2:
			# Dua eden rahip ve iki kadın (başları eğik)
			return [[c, Transform3D(Basis(Vector3.UP, yaw), Vector3.ZERO), {"side": "C", "coat": Color("1e1e22"), "hat": "kamelaukion", "pose": "bow"}, 0.45],
				[c + b * Vector3(-0.8, 0, 0.6), Transform3D(Basis(Vector3.UP, yaw + 0.3), Vector3.ZERO), {"side": "C", "coat": CIV_COATS[1], "hat": "", "pose": "bow"}, 0.45],
				[c + b * Vector3(0.8, 0, 0.6), Transform3D(Basis(Vector3.UP, yaw - 0.3), Vector3.ZERO), {"side": "C", "coat": CIV_COATS[4], "hat": "", "pose": "bow"}, 0.45]]
		3:
			# Gediğe gidecek yedekler (dış sura bakar): ok yağmurunda hep birlikte kalkanın altına çöker, biri yük (ok demeti)
			# kaldırıp indirir (eskiden dördü donuk dikiliyordu)
			var out: Array = []
			var face := Basis(Vector3.UP, _rng.randf_range(-0.4, 0.4))
			for k in 4:
				var carry := k == 3
				out.append([c + face * Vector3((k % 2) * 1.0 - 0.5, 0, -floorf(k / 2.0) * 1.1), Transform3D(face * Basis(Vector3.UP, _rng.randf_range(-0.35, 0.35)), Vector3.ZERO),
					{"side": "B", "coat": Crowd.BYZ_COATS[(i + k) % 6], "arm": "" if carry else "spear_shield", "pose": "", "cycle": "pass" if carry else "cover"}, 0.45])
			return out
		_:
			# Yerde yatan ölü (üstü örtülmemiş), yanında devrik kalkanlı biri
			var lie := Transform3D(b * Basis(Vector3.RIGHT, PI * 0.5), Vector3(0, 0.13, 0))
			return [[c, lie, {"side": "B", "coat": Crowd.BYZ_COATS[(i + 4) % 6], "arm": "", "pose": "dead"}, 1.0]]


## Bir kişilik yerin zemini: yarıçap içinde kapsül boş, insan yok, zemin düz (≤ 1,2 m yükseklikte). Yoksa NAN.
func _spot_y(p: Vector3, rad: float) -> float:
	var space := get_world_3d().direct_space_state
	for av: Array in avoid:
		var c: Vector3 = av[0]
		if Vector2(p.x - c.x, p.z - c.z).length() < float(av[1]) + rad:
			return NAN
	for pp in _people:
		if Vector2(p.x - pp.x, p.z - pp.z).length() < 0.55 + rad:
			return NAN
	for ob: Array in _obst:
		var oc: Vector3 = ob[0]
		if Vector2(p.x - oc.x, p.z - oc.z).length() < float(ob[1]) + rad + 0.15:
			return NAN
	for s: Array in _segs:
		var a: Vector3 = s[0]
		var b: Vector3 = s[1]
		var q2 := Geometry2D.get_closest_point_to_segment(Vector2(p.x, p.z), Vector2(a.x, a.z), Vector2(b.x, b.z))
		if q2.distance_to(Vector2(p.x, p.z)) < 0.9 + rad:
			return NAN      # koşu yolunun üstüne kimse oturmasın
	for ln: Array in _lanes:
		var a: Vector3 = ln[0]
		var b: Vector3 = ln[1]
		var q3 := Geometry2D.get_closest_point_to_segment(Vector2(p.x, p.z), Vector2(a.x, a.z), Vector2(b.x, b.z))
		if q3.distance_to(Vector2(p.x, p.z)) < float(ln[2]) + rad:
			return NAN
	var ray := PhysicsRayQueryParameters3D.create(Vector3(p.x, 4.0, p.z), Vector3(p.x, -3.0, p.z))
	var hit := space.intersect_ray(ray)
	if hit.is_empty():
		return NAN
	var y: float = hit["position"].y
	if y > 1.2:
		return NAN
	var q := PhysicsShapeQueryParameters3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = maxf(0.3, rad)
	cap.height = maxf(1.3, cap.radius * 2.0 + 0.1)
	q.shape = cap
	q.transform = Transform3D(Basis.IDENTITY, Vector3(p.x, y + 0.35 + cap.height * 0.5, p.z))
	if not space.intersect_shape(q, 1).is_empty():
		return NAN
	return y
