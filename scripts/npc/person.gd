class_name Person
extends Node3D
## Genel low-poly insan: Büro memurları, Başdenetçi ve Paradoks İzi'ndeki hologram Tolga.
## Kıyafet, saç, şapka (none/fez/fedora/bun), gözlük ve bıyık seçilebilir.
## Sağ bacak kalçadan döner (tekme), sağ kol omuzdan (el sallama, damga vurma).

signal kick_hit

var coat := Color("3d4a5c")
var pants := Color("2b2f38")
var skin := Color("e0a57e")
var hair := Color("3a2a1e")
var hat := "none"
var glasses := false
var mustache := false
var skirt := false
var beard := false
var apron := Color(0, 0, 0, 0)
var robe := Color(0, 0, 0, 0)
var talking := false
var look_target: Node3D

var _body: Node3D
var activity := ""
var _head: Node3D
var _mouth: MeshInstance3D
var _arm_r: Node3D
var _arm_l: Node3D
var _leg_r: Node3D
var _leg_l: Node3D
var _knee_l: Node3D
var _knee_r: Node3D
var _elbow_l: Node3D
var _elbow_r: Node3D
var _eyes: Node3D
var _brows: Node3D
var _t := 0.0
var _busy := false
var rig: Rig


func _init(p := {}) -> void:
	coat = p.get("coat", coat)
	pants = p.get("pants", pants)
	skin = p.get("skin", skin)
	hair = p.get("hair", hair)
	hat = p.get("hat", hat)
	glasses = p.get("glasses", glasses)
	mustache = p.get("mustache", mustache)
	skirt = p.get("skirt", skirt)
	beard = p.get("beard", beard)
	apron = p.get("apron", apron)
	robe = p.get("robe", robe)


func _ready() -> void:
	_t = randf() * 10.0
	add_to_group("persons")
	_body = Node3D.new()
	add_child(_body)
	# Bacaklar (kalçadan döner), yuvarlak ayakkabılar — CharKit: yumuşak, karikatür oranlı parçalar
	var shoe := Color("2a2420")
	_leg_l = Node3D.new()
	_leg_l.position = Vector3(-0.1, 0.66, 0)
	_body.add_child(_leg_l)
	_knee_l = CharKit.leg(_leg_l, pants, shoe)
	_leg_r = Node3D.new()
	_leg_r.position = Vector3(0.1, 0.66, 0)
	_body.add_child(_leg_r)
	_knee_r = CharKit.leg(_leg_r, pants, shoe)
	if skirt:
		Props.cyl(_body, 0.2, 0.45, Vector3(0, 0.55, 0), pants, Vector3.ZERO, 14, 0.25)
	# Gövde, boyun, yaka (sakallı/bıyıklı olanlar biraz göbekli: mizah)
	CharKit.torso(_body, coat, skin, 0.25, 0.6 if beard else 0.0)
	if robe.a > 0.0:
		# Uzun kaftan / cüppe: dizlere kadar, etekte hafif açılır
		Props.cyl(_body, 0.32, 0.78, Vector3(0, 0.56, 0), robe, Vector3.ZERO, 14, 0.25)
		Props.cyl(_body, 0.325, 0.06, Vector3(0, 0.2, 0), robe.darkened(0.18), Vector3.ZERO, 14)
	if apron.a > 0.0:
		Props.box(_body, Vector3(0.38, 0.62, 0.03), Vector3(0, 0.8, 0.25), apron)
	Props.prism(_body, Vector3(0.17, 0.12, 0.04), Vector3(0, 1.3, 0.21), Color("f1ede2"), Vector3(180, 0, 0))
	# Kollar
	_arm_l = Node3D.new()
	_arm_l.position = Vector3(-0.3, 1.28, 0)
	_body.add_child(_arm_l)
	_elbow_l = CharKit.arm(_arm_l, coat, skin)
	_arm_r = Node3D.new()
	_arm_r.position = Vector3(0.3, 1.28, 0)
	_body.add_child(_arm_r)
	_elbow_r = CharKit.arm(_arm_r, coat, skin)
	# Kafa: iri gözler, iri burun, kalın kaşlar
	_head = Node3D.new()
	_head.position = Vector3(0, 1.58, 0)
	_body.add_child(_head)
	_eyes = Node3D.new()
	_head.add_child(_eyes)
	_brows = Node3D.new()
	_head.add_child(_brows)
	_mouth = CharKit.face(_head, _eyes, _brows, skin, hair, 0.2, 1.15 if mustache else 1.0)
	if mustache:
		CharKit.mustache(_head, hair, 0.2, 1.1 if beard else 1.0)
	if beard:
		CharKit.beard(_head, hair)
	if glasses:
		Props.ring(_head, 0.045, 0.058, Vector3(-0.072, 0.05, 0.2), Color("222222"), Vector3(90, 0, 0))
		Props.ring(_head, 0.045, 0.058, Vector3(0.072, 0.05, 0.2), Color("222222"), Vector3(90, 0, 0))
		Props.box(_head, Vector3(0.05, 0.01, 0.01), Vector3(0, 0.055, 0.205), Color("222222"))
	# Saç ve şapka (şapkalılarda ense ve favoriler görünür)
	if hat in ["fez", "fedora", "cook", "helm", "plume", "turban"]:
		CharKit.hair_under_hat(_head, hair)
	match hat:
		"fez":
			Props.cyl(_head, 0.15, 0.2, Vector3(0, 0.25, 0), Color("b3262d"), Vector3.ZERO, 8, 0.12)
			Props.cyl(_head, 0.008, 0.16, Vector3(0.08, 0.28, -0.06), Color("141414"), Vector3(0, 0, 30), 4)
		"fedora":
			Props.cyl(_head, 0.3, 0.03, Vector3(0, 0.17, 0), Color("4a4038"), Vector3(-6, 0, 0), 10)
			Props.cyl(_head, 0.19, 0.18, Vector3(0, 0.27, 0), Color("4a4038"), Vector3.ZERO, 8, 0.16)
			Props.cyl(_head, 0.195, 0.05, Vector3(0, 0.2, 0), Color("1f1b18"), Vector3.ZERO, 8)
		"helm":
			# Bizans miğferi: sivri, burun korumalı, altında zincir zırh
			Props.cyl(_head, 0.225, 0.26, Vector3(0, 0.16, 0), Color("8e949c"), Vector3.ZERO, 8, 0.02)
			Props.cyl(_head, 0.23, 0.05, Vector3(0, 0.06, 0), Color("6e747c"), Vector3.ZERO, 8)
			Props.box(_head, Vector3(0.035, 0.14, 0.03), Vector3(0, -0.02, 0.22), Color("8e949c"))
			Props.cyl(_head, 0.24, 0.2, Vector3(0, -0.12, -0.03), Color("7a7f86"), Vector3.ZERO, 8, 0.22)
		"cook":
			# Aşçıbaşı külahı: uzun, beyaz, hafif şişkin
			Props.cyl(_head, 0.2, 0.08, Vector3(0, 0.15, 0), Color("e8e2d4"), Vector3.ZERO, 8)
			Props.cyl(_head, 0.2, 0.42, Vector3(0, 0.38, 0), Color("f6f2e8"), Vector3.ZERO, 8, 0.24)
		"turban":
			Props.ball(_head, 0.25, Vector3(0, 0.16, 0), Color("f3efe4"), Vector3(1.1, 0.75, 1.1), 10)
			Props.ball(_head, 0.06, Vector3(0, 0.26, 0.2), Color("2f5fa8"), Vector3.ONE, 6)
		"crown":
			# İmparator: altın taç, mor kenar
			Props.ball(_head, 0.215, Vector3(0, 0.06, -0.03), hair, Vector3(1.02, 0.9, 1.0), 10)
			Props.cyl(_head, 0.2, 0.14, Vector3(0, 0.2, 0), Color("d8b040"), Vector3.ZERO, 10)
			Props.cyl(_head, 0.205, 0.03, Vector3(0, 0.14, 0), Color("5a2a6a"), Vector3.ZERO, 10)
			for i in 4:
				var a := TAU * i / 4.0
				Props.ball(_head, 0.03, Vector3(sin(a) * 0.2, 0.22, cos(a) * 0.2), Color("c8323a"), Vector3.ONE, 5)
		"hood":
			Props.ball(_head, 0.25, Vector3(0, 0.04, -0.04), Color("2a2a30"), Vector3(1.0, 1.1, 1.05), 10)
		"kamelaukion":
			# Bizans memur külahı: silindir, kırmızı
			Props.ball(_head, 0.215, Vector3(0, 0.06, -0.03), hair, Vector3(1.02, 0.9, 1.0), 10)
			Props.cyl(_head, 0.19, 0.26, Vector3(0, 0.27, 0), Color("8a2b22"), Vector3.ZERO, 8, 0.2)
			Props.cyl(_head, 0.2, 0.04, Vector3(0, 0.16, 0), Color("c49a45"), Vector3.ZERO, 8)
		"plume":
			# Cenevizli komutan: miğfer ve kırmızı sorguç
			Props.cyl(_head, 0.225, 0.22, Vector3(0, 0.14, 0), Color("a8aeb6"), Vector3.ZERO, 8, 0.18)
			Props.box(_head, Vector3(0.05, 0.3, 0.2), Vector3(0, 0.36, -0.02), Color("c8262f"), Vector3(-15, 0, 0))
		"bun":
			Props.ball(_head, 0.215, Vector3(0, 0.05, -0.02), hair, Vector3(1.02, 1.0, 1.02), 10)
			Props.ball(_head, 0.1, Vector3(0, 0.2, -0.16), hair, Vector3.ONE, 8)
		_:
			CharKit.hair_cap(_head, hair)

	# Parçaları hareketli düğüm başına tek ağda birleştir (60 parça yerine ~9 çizim)
	CharKit.bake(self, [_body, _leg_l, _leg_r, _knee_l, _knee_r, _arm_l, _arm_r, _elbow_l, _elbow_r, _head, _eyes, _brows], [_mouth], [_eyes, _brows])
	_make_rig()


## Sürekli iş hareketi (Rig.activity): sit, sit_ground, stir, hammer, write, paint, carry.
func set_activity(a: String) -> void:
	activity = a
	if rig:
		rig.activity = a


## Önünde yük taşır (sandık, sepet ya da çuval) ve "carry" hareketine geçer.
func carry(kind := "crate") -> void:
	var c := Node3D.new()
	c.position = Vector3(0, 0.98, 0.34)
	_body.add_child(c)
	match kind:
		"basket":
			Props.cyl(c, 0.2, 0.2, Vector3.ZERO, Color("b8904a"), Vector3.ZERO, 8, 1.2)
			for i in 4:
				Props.ball(c, 0.06, Vector3(-0.08 + (i % 2) * 0.16, 0.12, -0.05 + (i / 2) * 0.1), [Color("d83a2a"), Color("e8a020"), Color("8ab840")][i % 3], Vector3.ONE, 5)
		"sack":
			Props.ball(c, 0.2, Vector3(0, 0.04, 0), Color("c8b48a"), Vector3(1.2, 0.9, 0.9), 6)
		_:
			Props.box(c, Vector3(0.4, 0.3, 0.3), Vector3.ZERO, Color("8a6440"))
	set_activity("carry")


func _make_rig() -> void:
	rig = Rig.new(self, {"body": _body, "head": _head, "arm_l": _arm_l, "arm_r": _arm_r, "leg_l": _leg_l,
		"leg_r": _leg_r, "eyes": _eyes, "brows": _brows, "arm_rest_z": 0.1,
		"knee_l": _knee_l, "knee_r": _knee_r, "elbow_l": _elbow_l, "elbow_r": _elbow_r})
	rig.activity = activity


func _process(delta: float) -> void:
	_t += delta
	if not _busy:
		_body.rotation.z = sin(_t * 1.1) * 0.02
	_mouth.scale.y = 0.22 * (1.0 + (absf(sin(_t * 14.0)) * 2.5 if talking else 0.0))
	if look_target and not _busy:
		var to := look_target.global_position - global_position
		to.y = 0.0
		if to.length() > 0.1:
			rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 4.0, 0.0, 1.0))
	rig.update(delta, talking, _busy)


## Bir noktaya en yakın karakter (eşya gösterince, selfie'de tepki için).
static func nearest(tree: SceneTree, point: Vector3, max_dist := 2.5, exclude: Node = null) -> Person:
	var best: Person = null
	var bd := max_dist
	for n in tree.get_nodes_in_group("persons"):
		var p := n as Person
		if p and p != exclude and p.is_visible_in_tree():
			var d := (p.global_position + Vector3(0, 1.0, 0)).distance_to(point)
			if d < bd:
				bd = d
				best = p
	return best


## Tepki animasyonları (Rig): "surprise", "laugh", "shrug", "wave", "nod", "facepalm", "cheer".
func emote(kind: String) -> void:
	if _busy:
		return
	await rig.emote(kind)


## Damga vurma / masaya vurma: sağ kol kalkar ve iner.
func stamp() -> void:
	rig.lock += 1
	var tw := create_tween()
	tw.tween_property(_arm_r, "rotation:x", -2.2, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(_arm_r, "rotation:x", -0.9, 0.08)
	tw.tween_property(_arm_r, "rotation:x", 0.0, 0.3)
	await tw.finished
	rig.lock -= 1


## Tekme (hologram Tolga): geri çekiş, savuruş, darbe sinyali, geri dönüş.
func kick() -> void:
	_busy = true
	var tw := create_tween()
	tw.tween_property(_leg_r, "rotation:x", deg_to_rad(40), 0.35).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_body, "rotation:x", -0.1, 0.35)
	tw.tween_interval(0.12)
	tw.tween_property(_leg_r, "rotation:x", deg_to_rad(-85), 0.13).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_body, "rotation:x", 0.15, 0.13)
	tw.tween_callback(func(): kick_hit.emit())
	tw.tween_interval(0.3)
	# "Ay, ayağım!": ayağını tutup zıplar
	tw.tween_property(_leg_r, "rotation:x", deg_to_rad(-30), 0.2)
	tw.parallel().tween_property(_body, "rotation:x", 0.0, 0.2)
	tw.tween_property(self, "position:y", position.y + 0.15, 0.15)
	tw.tween_property(self, "position:y", position.y, 0.15)
	tw.tween_property(self, "position:y", position.y + 0.15, 0.15)
	tw.tween_property(self, "position:y", position.y, 0.15)
	tw.tween_property(_leg_r, "rotation:x", 0.0, 0.25)
	await tw.finished
	_busy = false


func is_busy() -> bool:
	return _busy


## Bütün parçaları yarı saydam, parlayan hologram malzemesine çevirir.
static func make_hologram(node: Node, color := Color(0.35, 0.95, 1.0, 0.45)) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.emission_enabled = true
	m.emission = Color(color.r, color.g, color.b)
	m.emission_energy_multiplier = 1.5
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_apply(node, m)


static func _apply(node: Node, m: Material) -> void:
	for c in node.get_children():
		if c is MeshInstance3D:
			(c as MeshInstance3D).material_override = m
		_apply(c, m)
