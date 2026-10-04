class_name LimbAnim
extends Node
## Pişirilmiş iskelet animasyonlarını (assets/anim/ual.json, tools/anim_bake.py) oyunun kendi eklemlerine uygular.
## Kaynak Quaternius Universal Animation Library 1–2 (CC0). Kemik açısı yerine uzuv YÖNLERİ saklanır: üst kol, ön kol,
## uyluk, baldır, gövde, baş. Her karede kolun/bacağın omuz ekseni o yöne çevrilir, dirsek/diz o açıyla bükülür.
## Kullanım: var a := LimbAnim.new(); person.add_child(a); a.bind(person.rig); a.play("Sword_Idle")
## Rig.lock > 0 iken çalışır (Rig'in kendi boşta/yürüme hareketi devre dışı).

const PATH := "res://assets/anim/ual.json"
static var _data: Dictionary = {}

var rig: Rig
var clip := ""
var t := 0.0              # saniye
var speed := 1.0
var loop := true
var hold_end := false     # döngüsüzken son karede kal
var fade := 0.12          # geçiş (sn)
var body_amount := 0.7    # gövde eğiminin ne kadarı uygulansın
var _cur: Dictionary = {} # son uygulanan yönler (geçiş için)
var _k := 1.0
var _body_y0 := 0.0
var _playing := true
## Ek gövde eğimi (rad, karakterin X ekseni çevresinde; eksi geriye): tekmeyle sendeleme, darbeyle iki büklüm olma
var lean := 0.0
## Zemin: 0 dokunma · 1 hiçbir uzuv karakterin y=0 düzleminin altına inmez (gömülmez) · 2 en alçak uzuv tam zemine
## oturur (yerde yatan: ne gömülür ne havada kalır)
var ground_mode := 0
## Döngüsüz klip son karesine varınca: true (bir kez) — ölüm pozu donar, işlem kapanır
signal finished_clip
var _done_sent := false


static func data() -> Dictionary:
	if _data.is_empty():
		var f := FileAccess.open(PATH, FileAccess.READ)
		if f:
			_data = JSON.parse_string(f.get_as_text())
	return _data


static func has_clip(name: String) -> bool:
	return (data().get("anims", {}) as Dictionary).has(name)


static func length(name: String) -> float:
	var a: Dictionary = data().get("anims", {}).get(name, {})
	return maxf(0.0, (a.get("frames", []) as Array).size() - 1) / float(data().get("fps", 30.0))


## Vuruş anı (el en hızlı): saldırı animasyonlarında darbe karesi (sn).
static func hit_time(name: String) -> float:
	var a: Dictionary = data().get("anims", {}).get(name, {})
	return float(a.get("hit", 0)) / float(data().get("fps", 30.0))


func bind(r: Rig) -> void:
	rig = r
	if rig and rig.body:
		_body_y0 = rig.body.position.y


func play(name: String, p_speed := 1.0, p_loop := true, from := 0.0) -> void:
	if name == clip and loop == p_loop and absf(speed - p_speed) < 0.001:
		return
	clip = name
	speed = p_speed
	loop = p_loop
	t = from
	_k = 0.0
	_playing = true
	_done_sent = false


## Zamanı dışarıdan sür (saldırının darbe anını oyun mantığına denk getirmek için).
func scrub(name: String, time: float) -> void:
	if name != clip:
		clip = name
		_k = 0.0
	t = time
	_playing = false


## Döngüsüz klip son karesine vardı mı
func done() -> bool:
	return clip != "" and not loop and _playing and t >= length(clip)


func stop_driving() -> void:
	clip = ""


func _process(delta: float) -> void:
	if rig == null or clip == "":
		return
	var d := data()
	var a: Dictionary = d.get("anims", {}).get(clip, {})
	var frames: Array = a.get("frames", [])
	if frames.is_empty():
		return
	var fps := float(d.get("fps", 30.0))
	if _playing:
		t += delta * speed
	var len := (frames.size() - 1) / fps
	var ft := t
	if loop and len > 0.0:
		ft = fmod(t, len)
	else:
		ft = clampf(t, 0.0, len)
		if _playing and t >= len and _k >= 1.0 and not _done_sent:
			_done_sent = true
			finished_clip.emit.call_deferred()
	var fi := ft * fps
	var i0 := clampi(int(fi), 0, frames.size() - 1)
	var i1 := clampi(i0 + 1, 0, frames.size() - 1)
	var f := fi - float(i0)
	var r0: Array = frames[i0]
	var r1: Array = frames[i1]
	_k = minf(1.0, _k + delta / maxf(fade, 0.001))
	_apply(r0, r1, f)


func _dir(r0: Array, r1: Array, idx: int, f: float) -> Vector3:
	var a := Vector3(r0[idx * 3], r0[idx * 3 + 1], r0[idx * 3 + 2])
	var b := Vector3(r1[idx * 3], r1[idx * 3 + 1], r1[idx * 3 + 2])
	return a.lerp(b, f).normalized()


func _blend(key: String, v: Vector3) -> Vector3:
	var prev: Vector3 = _cur.get(key, v)
	var out := prev.lerp(v, _k).normalized() if _k < 1.0 else v
	_cur[key] = out
	return out


func _apply(r0: Array, r1: Array, f: float) -> void:
	var body := rig.body
	# Gövde: omurga yönü (UP'tan en kısa yay), kısmen
	var sp := _blend("sp", _dir(r0, r1, 8, f))
	if body:
		var tilt := Quaternion(Vector3.UP, Vector3.UP.lerp(sp, body_amount).normalized())
		if absf(lean) > 0.001:
			tilt = Quaternion(Vector3.RIGHT, lean) * tilt
		body.basis = Basis(tilt)
		# Gövde KALÇADAN döner (eskiden ayak tabanından dönüyordu: geriye düşen asker 0,8 m aşağı da indirilince
		# belinden aşağısı yerin dibine giriyordu). Kalça yüksekliği: klibin kalça oranı × bacak boyu.
		var pel: float = lerpf(float(r0[r0.size() - 1]), float(r1[r1.size() - 1]), f)
		var hip := rig.leg_r.position.y if rig.leg_r else 0.66
		var want := Vector3(0, _body_y0 + hip * pel, 0) - body.basis * Vector3(0, hip, 0)
		body.position = Vector3(want.x, lerpf(body.position.y, want.y, 0.5), want.z)
	var binv := body.basis.inverse() if body else Basis.IDENTITY
	_limb(rig.arm_r, rig.elbow_r, binv * _blend("ua_r", _dir(r0, r1, 0, f)), binv * _blend("la_r", _dir(r0, r1, 1, f)), false)
	_limb(rig.arm_l, rig.elbow_l, binv * _blend("ua_l", _dir(r0, r1, 2, f)), binv * _blend("la_l", _dir(r0, r1, 3, f)), false)
	_limb(rig.leg_r, rig.knee_r, binv * _blend("th_r", _dir(r0, r1, 4, f)), binv * _blend("ca_r", _dir(r0, r1, 5, f)), true)
	_limb(rig.leg_l, rig.knee_l, binv * _blend("th_l", _dir(r0, r1, 6, f)), binv * _blend("ca_l", _dir(r0, r1, 7, f)), true)
	if rig.head:
		var hd := binv * _blend("hd", _dir(r0, r1, 9, f))
		var pitch := clampf(-atan2(hd.z, hd.y) * 0.6, -0.6, 0.6)
		rig.head.rotation.x = lerpf(rig.head.rotation.x, pitch, 0.5)
	if ground_mode > 0 and body:
		_clamp_to_ground()


## En alçak nokta (ayak, diz, el, kalça, göğüs, omuz, baş; yarıçaplarıyla) karakterin y=0 düzlemine oturur.
func _clamp_to_ground() -> void:
	var o := rig.owner
	if o == null or not o.is_inside_tree():
		return
	var inv := o.global_transform.affine_inverse()
	var body := rig.body
	var lo := INF
	for pr in [[body, Vector3(0, 0.62, 0), 0.2], [body, Vector3(0, 1.0, 0), 0.23], [body, Vector3(0, 1.22, 0), 0.24],
			[rig.head, Vector3.ZERO, 0.21], [rig.knee_l, Vector3.ZERO, 0.09], [rig.knee_r, Vector3.ZERO, 0.09],
			[rig.knee_l, Vector3(0, -0.31, 0.05), 0.07], [rig.knee_r, Vector3(0, -0.31, 0.05), 0.07],
			[rig.elbow_l, Vector3(0, -0.27, 0), 0.06], [rig.elbow_r, Vector3(0, -0.27, 0), 0.06]]:
		var n := pr[0] as Node3D
		if n == null:
			continue
		var p := inv * (n.global_transform * (pr[1] as Vector3))
		lo = minf(lo, p.y - float(pr[2]))
	if lo < INF and (lo < 0.0 or ground_mode == 2):
		body.position.y -= lo


## Omuz/kalça ekseni: yerel -Y üst uzva (u) bakar; dirsek/diz yerel X çevresinde bükülür ve alt uzvu (l) izler.
## Kol: bükülme +Z yönüne (dirsek açısı eksi) · Bacak: bükülme -Z yönüne (diz açısı artı).
func _limb(pivot: Node3D, joint: Node3D, u: Vector3, l: Vector3, is_leg: bool) -> void:
	if pivot == null:
		return
	var y_axis := -u
	var perp := l - u * l.dot(u)
	if perp.length() < 0.02:
		# Düz uzuv: bükülme düzlemi olarak karakterin önünü kullan
		perp = Vector3(0, 0, 1) - u * u.z
		if perp.length() < 0.02:
			perp = Vector3(0, 1, 0) - u * u.y
	perp = perp.normalized()
	var z_axis := -perp if is_leg else perp
	var x_axis := y_axis.cross(z_axis).normalized()
	z_axis = x_axis.cross(y_axis).normalized()
	pivot.basis = Basis(x_axis, y_axis, z_axis)
	if joint:
		var ang := acos(clampf(u.dot(l), -1.0, 1.0))
		joint.rotation = Vector3(ang if is_leg else -ang, 0, 0)
