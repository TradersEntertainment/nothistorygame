class_name ThiefGull
extends Node3D
## Bölüm 6b'nin hırsız martısı: gagasında kırmızı mühürlü Misafir İzni. Tünekte başını oynatır, gagalar,
## oyuncu yaklaşınca çığlık atıp bir sonraki tüneğe kavisle uçar. Kanatlar uçarken çırpar, tünekte katlanır.

const CK = preload("res://scripts/world/ist/canli_kit.gd")

signal landed

var flying := false
var paper: Node3D
var _wings: Array = []
var _head: Node3D
var _t := 0.0


func _ready() -> void:
	# CANLI (kalite notu 32): martı canli_kit'ten (kesit halkalı gövde, yuvarlak baş, sivri gaga, kanatlar omuz pivotunda,
	# sivrilen kanat ucu koyu); kutu yok. Arayüz aynı: _head (izin onun çocuğu), _wings [[pivot, s]].
	var kit: Dictionary = CK.dugum("marti", {"lod": 0, "golge": false})
	add_child(kit["root"])
	var kp: Dictionary = kit["p"]
	_head = kp["bas"]
	# Gagadaki izin: katlanmış kâğıt, kırmızı balmumu mühür
	paper = Node3D.new()
	paper.position = Vector3(0.05, -0.05, 0.2)
	paper.rotation_degrees = Vector3(0, 70, -20)
	_head.add_child(paper)
	Props.box(paper, Vector3(0.24, 0.16, 0.01), Vector3.ZERO, Color("efe6cf"))
	Props.cyl(paper, 0.03, 0.012, Vector3(0.04, -0.02, 0.008), Color("b3262d"), Vector3(90, 0, 0), 8)
	for s in [-1, 1]:
		_wings.append([kp["kanat_l" if s < 0 else "kanat_r"], s])
	scale = Vector3.ONE * 1.6


func _process(delta: float) -> void:
	_t += delta
	for w in _wings:
		var pv: Node3D = w[0]
		if flying:
			pv.rotation.y = lerpf(pv.rotation.y, 0.0, 0.3)
			pv.rotation.z = sin(_t * 16.0) * 0.8 * w[1]
		else:
			# Katlı kanat: geriye, gövdenin yanına yatar
			pv.rotation.y = lerpf(pv.rotation.y, 1.35 * w[1], 0.2)
			pv.rotation.z = lerpf(pv.rotation.z, -0.12 * w[1], 0.2)
	if not flying:
		# Tünekte: baş sağa sola, ara sıra gagalama
		_head.rotation.y = sin(_t * 1.7) * 0.6
		_head.rotation.x = 0.5 if fmod(_t, 3.1) < 0.25 else 0.0


## Bir tüneğe kavisli uçuş (tepe noktası en az 3 m yukarıda). Süre uzaklıkla artar.
func fly_to(target: Vector3, speed := 7.0) -> void:
	flying = true
	Audio.sfx("whoosh_fly", -14.0, 1.6)
	var from := global_position
	var d := from.distance_to(target)
	var secs := clampf(d / speed, 0.8, 5.0)
	var apex := maxf(from.y, target.y) + clampf(d * 0.25, 3.0, 9.0)
	var flat := Vector3(target.x - from.x, 0, target.z - from.z)
	if flat.length() > 0.01:
		rotation.y = atan2(flat.x, flat.z)
	var tw := create_tween()
	tw.tween_method(func(k: float):
		var p := from.lerp(target, k)
		p.y = lerpf(lerpf(from.y, apex, k), lerpf(apex, target.y, k), k)
		global_position = p, 0.0, 1.0, secs).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	flying = false
	landed.emit()


## İzni bırakır: kâğıt yere süzülür (dünyaya taşınır), düğümü döndürür.
func drop_paper() -> Node3D:
	var p := paper
	var gp := p.global_transform
	_head.remove_child(p)
	get_parent().add_child(p)
	p.global_transform = gp
	paper = null
	var tw := p.create_tween().set_parallel(true)
	tw.tween_property(p, "global_position", gp.origin + Vector3(0.4, -gp.origin.y + 0.9, 0.5), 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(p, "rotation_degrees", Vector3(80, 200, 10), 0.9)
	return p
