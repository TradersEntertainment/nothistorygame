extends Node3D
## Oyuncunun yalnız GÖLGE atan gövdesi (kendisi hiç çizilmez). Birinci şahısta oyuncunun gövdesi yoktur; yerde yalnız
## elindeki eşyanın gölgesi kalıyordu (8Y'de Beyaz Havlu: "gölgede sadece bayrak var", sırık havada duran bir çubuk).
## Bu düğüm oyuncunun ayaklarından başlayan insan biçimli bir gölge atar: baş + fes (Tolga, fes takılıysa) ya da fötr
## (Nihat), gövde, iki bacak, iki kol. Kollar elde taşınan şeye uzanır (iki kemikli yönelim): sırığı tutan elin gölgesi
## sırığın gölgesiyle birleşir.
##
## Tek ağ, tek çizim: 14 kemikli bir iskelete bağlı tek ArrayMesh (≈450 üçgen), SHADOW_CASTING_SETTING_SHADOWS_ONLY.
## Ağ yalnız görünüm anahtarı (karakter, fes, kaftan) değişince yeniden kurulur; her karede yalnız kemik dönüşümleri
## güncellenir. Player.gd tarafından `preload` ile kurulur (class_name yok); `persons` grubuna, çarpışmaya ve denetimlere
## girmez.
##
## Kapalı olduğu anlar: oyuncu kamerası etkin değilken (ara sahne, fotoğraf, selfie, düello bitirici), oyuncu gizliyken,
## oyuncunun kendi üçüncü şahıs modeli yanında görünürken (çift gölge olmasın), Nihat görünmezken, merdivende/tırmanırken,
## suda, yerde yatarken, emekleyince ve tavuk iken (Bölüm 16).

const SHADOW_ONLY := GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

# Kemik dizini (yan: 0 sol, 1 sağ). Her kemik köksüz; dünya (gövde) uzayında dönüşümü doğrudan yazılır.
const B_TORSO := 0
const B_HEAD := 1
const B_THIGH := 2        # +yan
const B_SHIN := 4
const B_FOOT := 6
const B_UARM := 8
const B_FARM := 10
const B_HAND := 12
const NB := 14

const HIP_Y := 0.90
const HIP_X := 0.10
const SH_X := 0.215
const SH_UP := 0.48       # kalçadan omza
const NECK_UP := 0.57     # kalçadan boyuna
const THIGH := 0.45
const SHIN := 0.42
const UARM := 0.29
const FARM := 0.27
const HAND := 0.10
const STRIDE := 0.2

var pl                    # Player (döngüsel bağımlılık olmasın diye türsüz)
var _skel: Skeleton3D
var _mi: MeshInstance3D
var _skin: Skin
var _pivot: Array = []    # kemik dinlenme noktaları (bağlama pozu)
var _key := ""
var _check_t := 0.0
var _double := false
var _ph := 0.0
var _k := 0.0
var _tris := 0

# ağ kurma ara belleği
var _v := PackedVector3Array()
var _i := PackedInt32Array()
var _b := PackedInt32Array()
var _w := PackedFloat32Array()


func setup(p) -> void:
	pl = p
	name = "ShadowBody"
	visible = false
	set_meta("no_audit", true)
	_skel = Skeleton3D.new()
	_skel.name = "Skeleton"
	add_child(_skel)
	_pivot.resize(NB)
	_pivot[B_TORSO] = Vector3(0, HIP_Y, 0)
	_pivot[B_HEAD] = Vector3(0, HIP_Y + NECK_UP, 0)
	for s in 2:
		var x := (-1.0 if s == 0 else 1.0)
		_pivot[B_THIGH + s] = Vector3(x * HIP_X, HIP_Y, 0)
		_pivot[B_SHIN + s] = Vector3(x * HIP_X, HIP_Y - THIGH, 0)
		_pivot[B_FOOT + s] = Vector3(x * HIP_X, HIP_Y - THIGH - SHIN, 0)
		_pivot[B_UARM + s] = Vector3(x * SH_X, HIP_Y + SH_UP, 0)
		_pivot[B_FARM + s] = Vector3(x * SH_X, HIP_Y + SH_UP - UARM, 0)
		_pivot[B_HAND + s] = Vector3(x * SH_X, HIP_Y + SH_UP - UARM - FARM, 0)
	_skin = Skin.new()
	for i in NB:
		_skel.add_bone("b%d" % i)
		_skel.set_bone_rest(i, Transform3D(Basis(), _pivot[i]))
		_skel.set_bone_pose_position(i, _pivot[i])
		_skin.add_bind(i, Transform3D(Basis(), _pivot[i]).affine_inverse())
	_mi = MeshInstance3D.new()
	_mi.name = "Mesh"
	_mi.cast_shadow = SHADOW_ONLY
	_mi.skin = _skin
	_mi.custom_aabb = AABB(Vector3(-1.4, -0.3, -1.4), Vector3(2.8, 2.6, 2.8))
	_skel.add_child(_mi)
	_mi.skeleton = NodePath("..")


# ---------------------------------------------------------------- ağ

func _vert(p: Vector3, bone: int) -> int:
	_v.append(p)
	_b.append_array(PackedInt32Array([bone, 0, 0, 0]))
	_w.append_array(PackedFloat32Array([1.0, 0.0, 0.0, 0.0]))
	return _v.size() - 1


## Üçgen: parçalar dışbükey olduğundan, yüz parçanın merkezinden dışa bakacak biçimde sarılır (Godot: saat yönü ön yüz).
func _tri(a: int, b: int, c: int, center: Vector3) -> void:
	var n := (_v[b] - _v[a]).cross(_v[c] - _v[a])
	var cen := (_v[a] + _v[b] + _v[c]) / 3.0
	if n.dot(cen - center) > 0.0:
		_i.append_array(PackedInt32Array([a, c, b]))
	else:
		_i.append_array(PackedInt32Array([a, b, c]))
	_tris += 1


## Düşey eksenli koni/silindir: y0'daki halka r0, y1'deki halka r1 yarıçaplı; uçlar yuvarlak (round > 0: tepe noktası)
## ya da düz (0). ox/oz: eksenin kayması; sx/sz: kesit ölçeği (gövde yassı).
func _tube(bone: int, y0: float, y1: float, r0: float, r1: float, n := 6, round0 := 0.0, round1 := 0.0,
		sx := 1.0, sz := 1.0, ox := 0.0, oz := 0.0) -> void:
	var ring0: Array = []
	var ring1: Array = []
	for k in n:
		var a := TAU * float(k) / float(n)
		ring0.append(_vert(Vector3(ox + cos(a) * r0 * sx, y0, oz + sin(a) * r0 * sz), bone))
		ring1.append(_vert(Vector3(ox + cos(a) * r1 * sx, y1, oz + sin(a) * r1 * sz), bone))
	var d0 := 1.0 if y0 >= y1 else -1.0
	var ap0 := _vert(Vector3(ox, y0 + d0 * round0, oz), bone)
	var ap1 := _vert(Vector3(ox, y1 - d0 * round1, oz), bone)
	var c := Vector3(ox, (y0 + y1) * 0.5, oz)
	for k in n:
		var k2 := (k + 1) % n
		_tri(ring0[k], ring0[k2], ring1[k2], c)
		_tri(ring0[k], ring1[k2], ring1[k], c)
		_tri(ap0, ring0[k2], ring0[k], c)
		_tri(ap1, ring1[k], ring1[k2], c)


func _box(bone: int, c: Vector3, h: Vector3) -> void:
	var ids: Array = []
	for sx in [-1.0, 1.0]:
		for sy in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				ids.append(_vert(c + Vector3(sx * h.x, sy * h.y, sz * h.z), bone))
	# 0..7: x,y,z işaret ikilisi (x en yavaş)
	for q in [[0, 1, 3, 2], [4, 6, 7, 5], [0, 4, 5, 1], [2, 3, 7, 6], [0, 2, 6, 4], [1, 5, 7, 3]]:
		_tri(ids[q[0]], ids[q[1]], ids[q[2]], c)
		_tri(ids[q[0]], ids[q[2]], ids[q[3]], c)


func _ball(bone: int, c: Vector3, r: float, sx := 1.0, sy := 1.0, sz := 1.0, n := 8) -> void:
	var rings: Array = []
	for k in 3:
		var phi := PI * float(k + 1) / 4.0
		var ring: Array = []
		for j in n:
			var th := TAU * float(j) / float(n)
			ring.append(_vert(c + Vector3(sin(phi) * cos(th) * r * sx, cos(phi) * r * sy, sin(phi) * sin(th) * r * sz), bone))
		rings.append(ring)
	var top := _vert(c + Vector3(0, r * sy, 0), bone)
	var bot := _vert(c - Vector3(0, r * sy, 0), bone)
	for j in n:
		var j2 := (j + 1) % n
		_tri(top, rings[0][j2], rings[0][j], c)
		_tri(bot, rings[2][j], rings[2][j2], c)
		for k in 2:
			_tri(rings[k][j], rings[k][j2], rings[k + 1][j2], c)
			_tri(rings[k][j], rings[k + 1][j2], rings[k + 1][j], c)


## Görünüş anahtarı: karakter + şapka + kaftan. Değişince ağ yeniden kurulur.
func _look_key() -> String:
	var style := str(pl.hand_style)
	var fez: bool = style == "tolga" and bool(pl.wears_fez())
	var kaftan: bool = style == "tolga" and bool(pl.wears_kaftan())
	return "%s|%s|%s" % [style, fez, kaftan]


func _build(key: String) -> void:
	_key = key
	var parts := key.split("|")
	var style := parts[0]
	var fez := parts[1] == "true"
	var kaftan := parts[2] == "true"
	_v.clear()
	_i.clear()
	_b.clear()
	_w.clear()
	_tris = 0
	var hip := HIP_Y
	# Gövde: yassı gövde, omuz, boyun; redingot/kaftan eteği (Tolga), takım elbise (Nihat) kalçada biter
	_tube(B_TORSO, hip + SH_UP + 0.05, hip - 0.04, 0.2, 0.17, 8, 0.0, 0.0, 1.0, 0.62)
	_box(B_TORSO, Vector3(0, hip + SH_UP - 0.02, 0), Vector3(0.235, 0.05, 0.1))
	if kaftan:
		_tube(B_TORSO, hip, 0.40, 0.18, 0.27, 8, 0.0, 0.0, 1.0, 0.8)
	elif style == "tolga":
		_tube(B_TORSO, hip, 0.62, 0.18, 0.225, 8, 0.0, 0.0, 1.0, 0.75)
	# Boyun ve baş
	_tube(B_HEAD, hip + NECK_UP + 0.04, hip + NECK_UP - 0.04, 0.05, 0.055, 5)
	_ball(B_HEAD, Vector3(0, hip + NECK_UP + 0.13, 0), 0.115, 0.95, 1.08, 1.0, 8)
	if style == "nihat":
		_tube(B_HEAD, 1.775, 1.665, 0.085, 0.095, 6, 0.0, 0.0)       # fötr tepesi
		_tube(B_HEAD, 1.672, 1.66, 0.2, 0.2, 8, 0.0, 0.0)             # fötr kenarı
	elif fez:
		_tube(B_HEAD, 1.78, 1.665, 0.07, 0.095, 8, 0.0, 0.0)          # fes
	# Bacaklar
	for s in 2:
		var x: float = (-1.0 if s == 0 else 1.0) * HIP_X
		_tube(B_THIGH + s, hip, hip - THIGH, 0.082, 0.065, 6, 0.03, 0.03, 1.0, 1.0, x)
		_tube(B_SHIN + s, hip - THIGH, hip - THIGH - SHIN, 0.065, 0.05, 6, 0.0, 0.0, 1.0, 1.0, x)
		_box(B_FOOT + s, Vector3(x, 0.03 - 0.0, -0.07), Vector3(0.05, 0.035, 0.125))
	# Kollar: üst kol, ön kol, el
	for s in 2:
		var x2: float = (-1.0 if s == 0 else 1.0) * SH_X
		var sy := hip + SH_UP
		_tube(B_UARM + s, sy, sy - UARM, 0.052, 0.045, 6, 0.04, 0.0, 1.0, 1.0, x2)
		_tube(B_FARM + s, sy - UARM, sy - UARM - FARM, 0.045, 0.036, 6, 0.0, 0.0, 1.0, 1.0, x2)
		_tube(B_HAND + s, sy - UARM - FARM, sy - UARM - FARM - HAND, 0.04, 0.03, 6, 0.0, 0.04, 1.0, 1.0, x2)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _v
	arrays[Mesh.ARRAY_INDEX] = _i
	arrays[Mesh.ARRAY_BONES] = _b
	arrays[Mesh.ARRAY_WEIGHTS] = _w
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_mi.mesh = m


# ---------------------------------------------------------------- durum

## Çevredeki "oyuncunun kendi üçüncü şahıs modeli" (Person) var mı: ikizin kendi gölgesi var, çift gölge olmasın.
func _near_double() -> bool:
	if pl == null or not pl.is_inside_tree():
		return false
	var want := "tolga"
	if pl.hand_style == "nihat":
		want = "nihat"
	elif pl.hand_style == "hikmet":
		return false
	var here: Vector3 = pl.global_position
	for n in get_tree().get_nodes_in_group("persons"):
		var p := n as Node3D
		if p == null or not p.visible or p.get("face_id") != want:
			continue
		var d := p.global_position - here
		if absf(d.y) < 1.2 and Vector2(d.x, d.z).length() < 1.1 and p.is_visible_in_tree():
			return true
	return false


func _should_show() -> bool:
	var cam: Camera3D = pl.camera
	if cam == null or not cam.current or not pl.is_visible_in_tree():
		return false
	if pl.is_down or pl.ladder != null or pl.floating or pl.step_voice != "" or _double:
		return false
	if pl.traversal != null and pl.traversal.state != "":
		return false
	if pl.powers != null and pl.powers.cloaked:
		return false
	return pl.eye_height >= 0.55


func _process(delta: float) -> void:
	if pl == null or not is_instance_valid(pl) or _skel == null:
		return
	_check_t -= delta
	if _check_t <= 0.0:
		_check_t = 0.25
		_double = _near_double()
		var key := _look_key()
		if key != _key:
			_build(key)
	var on := _should_show()
	if on != visible:
		visible = on
	if not on:
		return
	_pose(delta)


static func _aim(dir: Vector3) -> Basis:
	# Yerel -Y eksenini dir'e çeviren dönüş (kemikler aşağı sarkan ağla kurulu)
	var d := dir.normalized()
	if d.is_zero_approx():
		return Basis()
	var down := Vector3(0, -1, 0)
	if d.dot(down) < -0.9999:
		return Basis(Vector3.RIGHT, PI)
	return Basis(Quaternion(down, d))


func _put(bone: int, xf: Transform3D) -> void:
	_skel.set_bone_pose_position(bone, xf.origin)
	_skel.set_bone_pose_rotation(bone, xf.basis.get_rotation_quaternion())


## İki kemikli yönelim: kök P, uç T (erişilemezse uzanabildiği kadar), dirsek/diz pole yönüne doğru bükülür.
## Dönüş: [orta eklem, uç]
static func _ik(p: Vector3, t: Vector3, a: float, b: float, pole: Vector3) -> Array:
	var to := t - p
	var d := clampf(to.length(), 0.06, (a + b) * 0.995)
	var u := to.normalized() if to.length() > 0.0001 else Vector3(0, -1, 0)
	var x := (a * a - b * b + d * d) / (2.0 * d)
	var h := sqrt(maxf(a * a - x * x, 0.0))
	var pp := pole - u * pole.dot(u)
	pp = pp.normalized() if pp.length() > 0.0001 else Vector3(0, 0, -1)
	var mid := p + u * x + pp * h
	return [mid, p + u * d]


func _pose(delta: float) -> void:
	var pitch: float = pl.camera.rotation.x
	var s := clampf(float(pl.eye_height), 0.55, 1.7)
	var flying: bool = pl.powers != null and pl.powers.flying
	var spd: float = 0.0 if flying else float(pl.horizontal_speed())
	var seated: bool = (bool(pl.seated) or bool(pl.pinned)) and s < 1.45
	var airborne: bool = (not flying) and bool(pl.gravity_on) and not bool(pl.is_on_floor())
	_k = lerpf(_k, clampf(spd / 3.2, 0.0, 1.4) if not seated else 0.0, clampf(delta * 10.0, 0.0, 1.0))
	_ph += delta * spd * 2.6
	var hip_y := clampf(s - 0.72, 0.28, HIP_Y)
	var crouch := clampf((HIP_Y - hip_y) / 0.6, 0.0, 1.0) if not seated else 0.0
	hip_y -= 0.03 * _k
	var lean := crouch * 0.5
	var hz := sin(lean) * 0.6
	if seated:
		hz = 0.1
	var torso_b := Basis(Vector3.RIGHT, -lean)
	var hip := Vector3(0, hip_y, hz)
	_put(B_TORSO, Transform3D(torso_b, hip))
	var neck := hip + torso_b * Vector3(0, NECK_UP, 0)
	_put(B_HEAD, Transform3D(Basis(Vector3.RIGHT, pitch * 0.8), neck))
	# Bacaklar
	var kick_leg: Node3D = pl.leg
	var kicking: bool = kick_leg != null and kick_leg.visible
	for side in 2:
		var sgn := -1.0 if side == 0 else 1.0
		var hp := hip + Vector3(sgn * HIP_X, 0, 0)
		var foot: Vector3
		var lift := 0.0
		var pole := Vector3(0, 0.4, -1)
		if seated:
			foot = Vector3(sgn * 0.14, 0.04, -0.46)
			pole = Vector3(0, 1, 0)
		else:
			var sw := sin(_ph + (0.0 if side == 0 else PI))
			foot = Vector3(sgn * 0.11, 0.035, -0.05 - sw * STRIDE * _k)
			lift = maxf(0.0, cos(_ph + (0.0 if side == 0 else PI))) * 0.11 * _k
			if airborne:
				lift = 0.12
			foot.y += lift
		if kicking and side == 1:
			foot = to_local(kick_leg.to_global(Vector3(0, -1.02, 0)))
		var legs := _ik(hp, foot, THIGH, SHIN, pole)
		var knee: Vector3 = legs[0]
		var ankle: Vector3 = legs[1]
		_put(B_THIGH + side, Transform3D(_aim(knee - hp), hp))
		_put(B_SHIN + side, Transform3D(_aim(ankle - knee), knee))
		_put(B_FOOT + side, Transform3D(Basis(), Vector3(ankle.x, ankle.y - 0.0, ankle.z)))
	# Kollar
	for side in 2:
		var sgn2 := -1.0 if side == 0 else 1.0
		var sh := hip + torso_b * Vector3(sgn2 * SH_X, SH_UP, 0)
		var wrist: Vector3
		var hdir := Vector3(sgn2 * 0.15, -1.0, -0.2)
		var node: Node3D = null
		if side == 1:
			if pl.hand != null and pl.hand.visible and bool(pl._hand_shown):
				node = pl.hand
		elif pl.free_hand != null and pl.free_hand.visible and pl.free_hand.position.y > float(pl._free_base.y) - 0.3:
			node = pl.free_hand
		if node != null:
			wrist = to_local(node.global_position)
			hdir = to_local(node.global_position - node.global_transform.basis.z) - wrist
			# Eşya/tutuş sırasında dirsek aşağı ve hafifçe dışa
		else:
			var swing := sin(_ph + (PI if side == 0 else 0.0)) * 0.12 * _k
			wrist = sh + Vector3(sgn2 * 0.045, -(UARM + FARM) * 0.97, swing)
			hdir = Vector3(sgn2 * 0.1, -1.0, -0.15)
		var arm := _ik(sh, wrist, UARM, FARM, Vector3(sgn2 * 0.5, -1.0, 0.45))
		var elbow: Vector3 = arm[0]
		var tip: Vector3 = arm[1]
		_put(B_UARM + side, Transform3D(_aim(elbow - sh), sh))
		_put(B_FARM + side, Transform3D(_aim(tip - elbow), elbow))
		_put(B_HAND + side, Transform3D(_aim(hdir), tip))
