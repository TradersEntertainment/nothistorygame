class_name DrumBeat
extends Node
## Davulcu: göğsünde kayışla asılı iki yüzlü davul (yanları dövülür), sağ elde kalın tokmak, sol elde ince çubuk.
## Eller davulun yüzlerine gerçekten iner (Rig.reach): tokmak "DÜM", çubuk "tek" (mehter usulü: DÜM · tek tek · DÜM · tek).
## Yürürken de çalar (kollar rig'in yürüyüşünden sonra konur). Yakındaysa vuruş sesi duyulur.
## Eskiden davul gövdenin önünde ya da arkasında boşta asılıydı, adam çekiç sallar gibi boşluğa vuruyordu.
##   DrumBeat.attach(kişi)   (Person ya da Soldier; _ready'den sonra). sound false: bölüm kendi davul sesini çalıyorsa
##   (37o: oyuncunun zil vuruşu davulla birlikte duyulur) davulcu sessiz vurur.

const CYCLE := 2.0
const DUM := [0.0, 1.0]
const TEK := [0.5, 0.75, 1.5]
const DRUM_C := Vector3(0, 0.98, 0.36)     # davulun ortası (gövdeye göre)
const HALF := 0.17                          # yüzlerin ortadan uzaklığı (yan yana)

var who: Node3D
var sound := true
var _t := 0.0
var _dum_done := -1
var _drum: Node3D


static func attach(p: Node3D, color := Color("c8a070"), p_sound := true) -> DrumBeat:
	var d := DrumBeat.new()
	d.who = p
	d.sound = p_sound
	p.add_child(d)
	d._t = randf() * CYCLE
	d._build(color)
	return d


func _body() -> Node3D:
	return who.get("_body") as Node3D


func _build(color: Color) -> void:
	var body := _body()
	if body == null:
		return
	_drum = Node3D.new()
	body.add_child(_drum)
	_drum.position = DRUM_C
	# Gövde (ekseni yana), iki deri yüz, kenar çemberleri, boyundan kayış
	Props.cyl(_drum, 0.25, HALF * 2.0, Vector3.ZERO, color, Vector3(0, 0, 90), 14)
	for sx: float in [-HALF, HALF]:
		Props.cyl(_drum, 0.26, 0.025, Vector3(sx, 0, 0), Color("f0e6cc"), Vector3(0, 0, 90), 14)
		Props.cyl(_drum, 0.265, 0.035, Vector3(sx * 1.04, 0, 0), Color("6a3a1e"), Vector3(0, 0, 90), 14)
	for a in 6:
		var ang := TAU * a / 6.0
		Props.box(_drum, Vector3(HALF * 2.0, 0.012, 0.012), Vector3(0, sin(ang) * 0.255, cos(ang) * 0.255), Color("8a5a2a"))
	Props.box(body, Vector3(0.05, 0.62, 0.02), Vector3(0.0, 1.3, 0.18), Color("5a3a22"), Vector3(-28, 0, 32))
	# Tokmak (sağ el) ve çubuk (sol el): avuçta, önkolun ucundan ileri
	for k in 2:
		var el := who.get("_elbow_r" if k == 0 else "_elbow_l") as Node3D
		if el == null:
			continue
		var hand: Vector3 = el.get_meta("hand", Vector3(0, -0.27, 0.01))
		var st := Node3D.new()
		el.add_child(st)
		st.position = hand
		st.rotation_degrees = Vector3(80, 0, 0)
		if k == 0:
			Props.cyl(st, 0.018, 0.34, Vector3(0, 0.15, 0), Color("6a4a2c"), Vector3.ZERO, 6)
			Props.ball(st, 0.05, Vector3(0, 0.33, 0), Color("d8c8a0"), Vector3.ONE, 6)
		else:
			Props.cyl(st, 0.008, 0.4, Vector3(0, 0.18, 0), Color("8a6a40"), Vector3.ZERO, 4)


## Vuruşa ne kadar yakın: 1 tam vuruş anı (el deride), 0 yukarıda
static func _hit(t: float, beats: Array) -> float:
	var best := 0.0
	for b: float in beats:
		var d := fmod(t - b + CYCLE * 2.0, CYCLE)
		# Vuruştan önce 0,22 sn kalkar-iner, sonra hızla kalkar
		var k := 0.0
		if d < 0.08:
			k = 1.0 - d / 0.08
		elif d > CYCLE - 0.22:
			k = (d - (CYCLE - 0.22)) / 0.22
		best = maxf(best, k)
	return best


func _process(delta: float) -> void:
	if who == null or not is_instance_valid(who) or not who.is_visible_in_tree():
		return
	var body := _body()
	var arm_r := who.get("_arm_r") as Node3D
	var arm_l := who.get("_arm_l") as Node3D
	var el_r := who.get("_elbow_r") as Node3D
	var el_l := who.get("_elbow_l") as Node3D
	if body == null or arm_r == null or arm_l == null:
		return
	_t = fmod(_t + delta, CYCLE)
	var bx := body.global_transform
	var hr := _hit(_t, DUM)
	var hl := _hit(_t, TEK)
	# Sağ: tokmak sağ yüze (+x) dışarıdan iner; sol: çubuk sol yüze (-x)
	var r_hit := DRUM_C + Vector3(HALF + 0.2, 0.12, 0.05)
	var r_up := DRUM_C + Vector3(HALF + 0.28, 0.42, 0.12)
	var l_hit := DRUM_C + Vector3(-HALF - 0.18, 0.1, 0.06)
	var l_up := DRUM_C + Vector3(-HALF - 0.24, 0.32, 0.14)
	Rig.reach(arm_r, el_r, bx * r_up.lerp(r_hit, hr), bx.basis * Vector3(1.0, -0.6, -0.2))
	Rig.reach(arm_l, el_l, bx * l_up.lerp(l_hit, hl), bx.basis * Vector3(-1.0, -0.6, -0.2))
	# DÜM: yakındaysa duyulur
	var beat := -1
	for i in DUM.size():
		var d := fmod(_t - float(DUM[i]) + CYCLE, CYCLE)
		if d < 0.05:
			beat = i
	if beat >= 0 and beat != _dum_done:
		_dum_done = beat
		var cam := get_viewport().get_camera_3d()
		if sound and cam and cam.global_position.distance_to(who.global_position) < 22.0:
			Audio.sfx_at("drum_boom", who, -12.0)
	elif beat < 0 and _dum_done >= 0 and fmod(_t - float(DUM[_dum_done]) + CYCLE, CYCLE) > 0.3:
		_dum_done = -1
