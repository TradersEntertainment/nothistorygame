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
var _head: Node3D
var _mouth: MeshInstance3D
var _arm_r: Node3D
var _leg_r: Node3D
var _t := 0.0
var _busy := false


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
	_body = Node3D.new()
	add_child(_body)
	# Ayakkabılar ve bacaklar (sağ bacak kalçadan döner)
	Props.box(_body, Vector3(0.13, 0.08, 0.26), Vector3(-0.1, 0.04, 0.04), Color("1d2027"))
	Props.cyl(_body, 0.075, 0.62, Vector3(-0.1, 0.35, 0), pants, Vector3.ZERO, 6)
	_leg_r = Node3D.new()
	_leg_r.position = Vector3(0.1, 0.66, 0)
	_body.add_child(_leg_r)
	Props.cyl(_leg_r, 0.075, 0.62, Vector3(0, -0.31, 0), pants, Vector3.ZERO, 6)
	Props.box(_leg_r, Vector3(0.13, 0.08, 0.26), Vector3(0, -0.62, 0.04), Color("1d2027"))
	if skirt:
		Props.cyl(_body, 0.2, 0.45, Vector3(0, 0.55, 0), pants, Vector3.ZERO, 8, 0.25)
	# Gövde ve yaka
	Props.cyl(_body, 0.24, 0.66, Vector3(0, 1.0, 0), coat, Vector3.ZERO, 8, 0.2)
	if robe.a > 0.0:
		# Uzun kaftan / cüppe: dizlere kadar
		Props.cyl(_body, 0.3, 0.75, Vector3(0, 0.55, 0), robe, Vector3.ZERO, 8, 0.25)
	if apron.a > 0.0:
		Props.box(_body, Vector3(0.36, 0.6, 0.03), Vector3(0, 0.78, 0.23), apron)
	Props.prism(_body, Vector3(0.16, 0.14, 0.04), Vector3(0, 1.26, 0.2), Color("f1ede2"), Vector3(180, 0, 0))
	# Kollar
	Props.cyl(_body, 0.06, 0.52, Vector3(-0.29, 1.03, 0), coat, Vector3(0, 0, -10), 6)
	Props.ball(_body, 0.06, Vector3(-0.33, 0.76, 0), skin, Vector3.ONE, 6)
	_arm_r = Node3D.new()
	_arm_r.position = Vector3(0.28, 1.28, 0)
	_body.add_child(_arm_r)
	Props.cyl(_arm_r, 0.06, 0.52, Vector3(0, -0.25, 0), coat, Vector3.ZERO, 6)
	Props.ball(_arm_r, 0.06, Vector3(0, -0.52, 0), skin, Vector3.ONE, 6)
	# Kafa
	_head = Node3D.new()
	_head.position = Vector3(0, 1.56, 0)
	_body.add_child(_head)
	Props.ball(_head, 0.21, Vector3.ZERO, skin, Vector3(1, 1.08, 1), 10)
	Props.ball(_head, 0.05, Vector3(0, -0.02, 0.2), skin.darkened(0.12), Vector3(1, 1.2, 1), 6)
	Props.ball(_head, 0.022, Vector3(-0.07, 0.05, 0.19), Color("1a1a1a"), Vector3.ONE, 6)
	Props.ball(_head, 0.022, Vector3(0.07, 0.05, 0.19), Color("1a1a1a"), Vector3.ONE, 6)
	_mouth = Props.box(_head, Vector3(0.08, 0.015, 0.02), Vector3(0, -0.1, 0.19), Color("7a3a2e"))
	if mustache:
		Props.box(_head, Vector3(0.2, 0.045, 0.05), Vector3(0, -0.07, 0.19), hair)
	if beard:
		Props.ball(_head, 0.13, Vector3(0, -0.16, 0.12), hair, Vector3(1.1, 1.0, 0.8), 8)
	if glasses:
		Props.ring(_head, 0.035, 0.048, Vector3(-0.07, 0.05, 0.2), Color("222222"), Vector3(90, 0, 0))
		Props.ring(_head, 0.035, 0.048, Vector3(0.07, 0.05, 0.2), Color("222222"), Vector3(90, 0, 0))
	# Saç ve şapka
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
			Props.ball(_head, 0.215, Vector3(0, 0.06, -0.03), hair, Vector3(1.02, 0.9, 1.0), 10)


func _process(delta: float) -> void:
	_t += delta
	if not _busy:
		_body.rotation.z = sin(_t * 1.1) * 0.02
	_mouth.scale.y = 1.0 + (absf(sin(_t * 14.0)) * 3.0 if talking else 0.0)
	if look_target and not _busy:
		var to := look_target.global_position - global_position
		to.y = 0.0
		if to.length() > 0.1:
			rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 4.0, 0.0, 1.0))


## Damga vurma / masaya vurma: sağ kol kalkar ve iner.
func stamp() -> void:
	var tw := create_tween()
	tw.tween_property(_arm_r, "rotation:x", -2.2, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(_arm_r, "rotation:x", -0.9, 0.08)
	tw.tween_property(_arm_r, "rotation:x", 0.0, 0.3)
	await tw.finished


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
