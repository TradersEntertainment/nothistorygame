class_name DoorScenes
extends RefCounted
## Zaman Bürosu kapılarının ardındaki minyatür sahneler (v0.99.101). Kullanıcı: "kapılardan içeride önemli olayları
## ufakça izlesek bizim grafiklerle". Her kapının nişinde bel hizasında bir kaide; üstünde o yılın olayı döngüyle
## oynar (piramide blok itilir, Sezar'ın çevresinde senatörler, Newton'un başına elma düşer, Ay'da astronot sekerek
## yürür...). Figürler Person değil birkaç parçalı bebeklerdir: yirmi sahne, onlarca figür; Person her karede iskelet
## hesaplar, bebek yalnız tween'le oynar.
## Sahne yerel ekseni: +z izleyiciye (koridora), x sahnenin genişliği (±0,42), y kaidenin üstünden yukarı.

const SKIN := Color("e0b08a")
const GOLD := Color("d4a640")


static func build(year: String, st: Node3D) -> void:
	match year:
		"MÖ 2560": _pyramid(st)
		"MÖ 776": _olympics(st)
		"MÖ 44": _ides(st)
		"1215": _magna(st)
		"1347": _plague(st)
		"1453": _siege(st)
		"1455": _press(st)
		"1492": _columbus(st)
		"1517": _luther(st)
		"1687": _newton(st)
		"1769": _steam(st)
		"1789": _bastille(st)
		"1815": _waterloo(st)
		"1903": _flyer(st)
		"1914": _sarajevo(st)
		"1945": _peace(st)
		"1969": _moon(st)
		"1989": _berlin(st)
		"2026": _now(st)
		"2150": _future(st)


# ---------------------------------------------------------------- yardımcılar

static func _base(st: Node3D, col: Color) -> void:
	Props.box(st, Vector3(0.86, 0.02, 0.52), Vector3(0, 0.01, 0), col)


## Bebek: bacaklar, gövde, baş, iki kol (omuzdan döner: meta "arm_l"/"arm_r"), isteğe bağlı başlık. Boy ~0,3 m.
static func _doll(parent: Node3D, pos: Vector3, coat: Color, hat := "", yaw := 0.0, s := 1.0) -> Node3D:
	var d := Node3D.new()
	d.position = pos
	d.rotation_degrees.y = yaw
	d.scale = Vector3.ONE * s
	parent.add_child(d)
	var pants := coat.darkened(0.35)
	for sx: float in [-1.0, 1.0]:
		Props.box(d, Vector3(0.03, 0.1, 0.03), Vector3(sx * 0.022, 0.05, 0), pants)
	Props.cyl(d, 0.045, 0.12, Vector3(0, 0.16, 0), coat, Vector3.ZERO, 8, 0.038)
	Props.ball(d, 0.036, Vector3(0, 0.255, 0), SKIN, Vector3.ONE, 8)
	for sx: float in [-1.0, 1.0]:
		var arm := Node3D.new()
		arm.position = Vector3(sx * 0.055, 0.21, 0)
		d.add_child(arm)
		Props.box(arm, Vector3(0.02, 0.095, 0.02), Vector3(0, -0.045, 0), coat)
		Props.ball(arm, 0.013, Vector3(0, -0.095, 0), SKIN, Vector3.ONE, 5)
		d.set_meta("arm_l" if sx < 0 else "arm_r", arm)
	match hat:
		"crown":
			Props.cyl(d, 0.034, 0.03, Vector3(0, 0.295, 0), GOLD, Vector3.ZERO, 8)
		"laurel":
			Props.ring(d, 0.03, 0.04, Vector3(0, 0.275, 0), Color("4a8a2a"))
		"bicorne":
			Props.ball(d, 0.03, Vector3(0, 0.29, 0), Color("141418"), Vector3(2.6, 0.9, 0.7), 6)
		"top":
			Props.cyl(d, 0.05, 0.008, Vector3(0, 0.285, 0), Color("141418"), Vector3.ZERO, 8)
			Props.cyl(d, 0.03, 0.06, Vector3(0, 0.315, 0), Color("141418"), Vector3.ZERO, 8)
		"beak":
			Props.cyl(d, 0.04, 0.05, Vector3(0, 0.3, 0), Color("141418"), Vector3.ZERO, 8, 0.03)
			Props.cyl(d, 0.016, 0.07, Vector3(0, 0.25, 0.05), Color("d8d0b8"), Vector3(90, 0, 0), 6, 0.002)
		"astro":
			Props.ball(d, 0.05, Vector3(0, 0.255, 0), Color("f2f2ee"), Vector3.ONE, 8)
			Props.ball(d, 0.034, Vector3(0, 0.255, 0.025), Color("c8a040"), Vector3(1, 0.8, 0.6), 6, 0.4)
		"wig":
			Props.ball(d, 0.04, Vector3(0, 0.27, -0.01), Color("f0ece4"), Vector3(1.15, 1.0, 1.1), 6)
		"helmet":
			Props.ball(d, 0.039, Vector3(0, 0.27, 0), Color("6a7078"), Vector3(1, 0.7, 1), 6)
		"cap":
			Props.cyl(d, 0.038, 0.02, Vector3(0, 0.285, 0), coat.darkened(0.3), Vector3.ZERO, 8)
	return d


static func _arm(d: Node3D, side: String) -> Node3D:
	return d.get_meta(side) as Node3D


## Sonsuz ileri-geri: düğümün özelliği a ile b arasında
static func _swing(n: Node, prop: String, a: Variant, b: Variant, secs: float, delay := 0.0) -> void:
	var tw := n.create_tween().set_loops()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(n, prop, b, secs).from(a).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(n, prop, a, secs).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


static func _spin(n: Node3D, secs: float, axis := "y") -> void:
	var tw := n.create_tween().set_loops()
	tw.tween_property(n, "rotation:" + axis, TAU, secs).as_relative()


static func _ship(parent: Node3D, pos: Vector3, s := 1.0, cross := false) -> Node3D:
	var sh := Node3D.new()
	sh.position = pos
	sh.scale = Vector3.ONE * s
	parent.add_child(sh)
	Props.box(sh, Vector3(0.22, 0.05, 0.08), Vector3(0, 0.03, 0), Color("6a4426"))
	Props.box(sh, Vector3(0.06, 0.04, 0.08), Vector3(-0.09, 0.07, 0), Color("5a3a20"))
	Props.cyl(sh, 0.006, 0.22, Vector3(0.01, 0.16, 0), Color("4a3020"), Vector3.ZERO, 4)
	Props.box(sh, Vector3(0.11, 0.1, 0.006), Vector3(0.01, 0.17, 0.0), Color("f2ede0"))
	if cross:
		Props.box(sh, Vector3(0.02, 0.07, 0.008), Vector3(0.01, 0.17, 0.004), Color("c42a22"))
		Props.box(sh, Vector3(0.06, 0.02, 0.008), Vector3(0.01, 0.18, 0.004), Color("c42a22"))
	return sh


# ---------------------------------------------------------------- MÖ 2560: Büyük Piramit

static func _pyramid(st: Node3D) -> void:
	_base(st, Color("d8b878"))
	var stone := Color("c8a868")
	for k in 5:
		var w := 0.42 - k * 0.08
		if k == 4:
			break      # tepe taşı henüz yok: inşaat sürüyor
		Props.box(st, Vector3(w, 0.06, w * 0.8), Vector3(-0.12, 0.05 + k * 0.06, -0.04), stone.darkened(k * 0.04))
	Props.ball(st, 0.06, Vector3(0.3, 0.42, -0.2), Color("ffd060"), Vector3.ONE, 8, 2.0)
	# Kızağa bağlı blok ve iten işçi: ileri-geri
	var sled := Node3D.new()
	sled.position = Vector3(0.3, 0.02, 0.12)
	st.add_child(sled)
	for k in 3:
		Props.cyl(sled, 0.012, 0.09, Vector3(-0.04 + k * 0.04, 0.012, 0), Color("8a6a40"), Vector3(90, 0, 0), 5)
	Props.box(sled, Vector3(0.09, 0.07, 0.07), Vector3(0, 0.06, 0), stone)
	_doll(sled, Vector3(0.1, 0.0, 0), Color("e8e0c8"), "", -90.0)
	_swing(sled, "position:x", 0.32, 0.14, 2.4)


# ---------------------------------------------------------------- MÖ 776: ilk olimpiyat

static func _olympics(st: Node3D) -> void:
	_base(st, Color("6a9a4a"))
	var track := Props.ring(st, 0.15, 0.2, Vector3(0, 0.025, 0), Color("c8885a"))
	track.scale = Vector3(1.9, 1, 1.15)
	var piv := Node3D.new()
	piv.position = Vector3(0, 0.03, 0)
	st.add_child(piv)
	for k in 2:
		var a := PI * k
		_doll(piv, Vector3(cos(a) * 0.33, 0, sin(a) * 0.2), [Color("f2ede0"), Color("c8a060")][k], "", rad_to_deg(-a))
	_spin(piv, 5.0)
	Props.box(st, Vector3(0.08, 0.05, 0.06), Vector3(0, 0.045, 0), Color("e8e4d8"))
	Props.ring(st, 0.018, 0.028, Vector3(0, 0.08, 0), Color("4a8a2a"))


# ---------------------------------------------------------------- MÖ 44: Mart'ın on beşi

static func _ides(st: Node3D) -> void:
	_base(st, Color("e8e4d8"))
	for sx: float in [-0.32, 0.32]:
		Props.cyl(st, 0.03, 0.42, Vector3(sx, 0.22, -0.2), Color("f2f0ea"), Vector3.ZERO, 10)
	var cae := _doll(st, Vector3(0, 0.02, 0.0), Color("f2ede0"), "laurel")
	Props.box(cae, Vector3(0.08, 0.13, 0.01), Vector3(0, 0.15, -0.046), Color("9a1f24"))
	_swing(cae, "rotation:z", -0.08, 0.08, 0.5)
	for k in 3:
		var a := TAU * k / 3.0 + 0.4
		var s := _doll(st, Vector3(cos(a) * 0.2, 0.02, sin(a) * 0.16), Color("ece6d6"), "", rad_to_deg(atan2(-cos(a), -sin(a))))
		_swing(s, "position", Vector3(cos(a) * 0.2, 0.02, sin(a) * 0.16), Vector3(cos(a) * 0.11, 0.02, sin(a) * 0.09), 0.6, k * 0.25)
		_swing(_arm(s, "arm_r"), "rotation:x", 0.0, -1.6, 0.6, k * 0.25)


# ---------------------------------------------------------------- 1215: Magna Carta

static func _magna(st: Node3D) -> void:
	_base(st, Color("6a8a4a"))
	Props.box(st, Vector3(0.3, 0.1, 0.16), Vector3(0, 0.07, 0.02), Color("6a4426"))
	Props.box(st, Vector3(0.2, 0.004, 0.13), Vector3(0, 0.124, 0.02), Color("efe4c4"))
	Props.cyl(st, 0.012, 0.13, Vector3(-0.1, 0.13, 0.02), Color("e0d4b0"), Vector3(90, 0, 0), 6)
	_doll(st, Vector3(0, 0.02, -0.13), Color("8a2a3a"), "crown")
	for sx: float in [-0.28, 0.28]:
		_doll(st, Vector3(sx, 0.02, 0.0), Color("5a6a7a"), "helmet", -sx * 120.0)
	var seal := Node3D.new()
	seal.position = Vector3(0.04, 0.2, 0.02)
	st.add_child(seal)
	Props.cyl(seal, 0.022, 0.02, Vector3(0, 0, 0), Color("b8322a"), Vector3.ZERO, 8)
	Props.cyl(seal, 0.008, 0.06, Vector3(0, 0.04, 0), Color("4a3020"), Vector3.ZERO, 5)
	var tw := seal.create_tween().set_loops()
	tw.tween_property(seal, "position:y", 0.137, 0.25).from(0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_interval(0.3)
	tw.tween_property(seal, "position:y", 0.24, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(0.8)


# ---------------------------------------------------------------- 1347: Kara Ölüm limana gelir

static func _plague(st: Node3D) -> void:
	Props.box(st, Vector3(0.86, 0.02, 0.26), Vector3(0, 0.01, -0.13), Color("3a6a8a"))
	Props.box(st, Vector3(0.86, 0.04, 0.26), Vector3(0, 0.02, 0.13), Color("7a5a3a"))
	var sh := _ship(st, Vector3(-0.15, 0.02, -0.13), 1.2)
	_swing(sh, "rotation:z", -0.07, 0.07, 1.3)
	var rat := Node3D.new()
	rat.position = Vector3(0.0, 0.04, 0.1)
	st.add_child(rat)
	Props.ball(rat, 0.022, Vector3(0, 0.015, 0), Color("6a6a70"), Vector3(1.5, 0.8, 0.9), 6)
	Props.cyl(rat, 0.003, 0.06, Vector3(-0.05, 0.01, 0), Color("c89090"), Vector3(0, 0, 80), 3)
	_swing(rat, "position:x", -0.25, 0.15, 1.1)
	var doc := _doll(st, Vector3(0.3, 0.04, 0.12), Color("1a1a1e"), "beak", -90.0)
	_swing(doc, "rotation:y", deg_to_rad(-120.0), deg_to_rad(-60.0), 0.6)


# ---------------------------------------------------------------- 1453: surlar, top ve karadan yürüyen gemi

static func _siege(st: Node3D) -> void:
	_base(st, Color("7a6a4a"))
	var stone := Color("9a948a")
	Props.box(st, Vector3(0.8, 0.22, 0.06), Vector3(0, 0.13, -0.2), stone)
	for k in 6:
		Props.box(st, Vector3(0.06, 0.05, 0.06), Vector3(-0.35 + k * 0.14, 0.265, -0.2), stone)
	Props.cyl(st, 0.05, 0.3, Vector3(0.28, 0.17, -0.18), stone.darkened(0.1), Vector3.ZERO, 10)
	var gun := Node3D.new()
	gun.position = Vector3(-0.2, 0.04, 0.12)
	st.add_child(gun)
	Props.box(gun, Vector3(0.1, 0.04, 0.08), Vector3(0, 0.02, 0), Color("6a4426"))
	Props.cyl(gun, 0.025, 0.16, Vector3(0, 0.06, -0.04), Color("3a3a3a"), Vector3(-80, 0, 0), 8, 0.03)
	var flash := Props.ball(st, 0.04, Vector3(-0.2, 0.08, -0.04), Color("ffb040"), Vector3.ONE, 6, 3.0)
	var tw := gun.create_tween().set_loops()
	tw.tween_interval(1.6)
	tw.tween_callback(func(): flash.visible = true)
	tw.tween_property(gun, "position:z", 0.17, 0.08)
	tw.tween_callback(func(): flash.visible = false)
	tw.tween_property(gun, "position:z", 0.12, 0.6)
	flash.visible = false
	# Kızaklar üstünde karada yürüyen gemi
	var ship := Node3D.new()
	ship.position = Vector3(0.2, 0.02, 0.14)
	st.add_child(ship)
	_ship(ship, Vector3(0, 0.03, 0), 0.9)
	for k in 3:
		Props.cyl(st, 0.01, 0.12, Vector3(0.05 + k * 0.1, 0.03, 0.14), Color("8a6a40"), Vector3(90, 0, 0), 5)
	_swing(ship, "position:x", 0.32, 0.08, 2.6)


# ---------------------------------------------------------------- 1455: Gutenberg matbaası

static func _press(st: Node3D) -> void:
	_base(st, Color("6a5038"))
	var wood := Color("7a5430")
	for sx: float in [-0.1, 0.1]:
		Props.box(st, Vector3(0.03, 0.34, 0.04), Vector3(sx, 0.18, -0.05), wood)
	Props.box(st, Vector3(0.26, 0.04, 0.06), Vector3(0, 0.35, -0.05), wood)
	Props.box(st, Vector3(0.22, 0.04, 0.18), Vector3(0, 0.08, -0.02), wood.darkened(0.2))
	var platen := Node3D.new()
	platen.position = Vector3(0, 0.22, -0.04)
	st.add_child(platen)
	Props.box(platen, Vector3(0.16, 0.025, 0.12), Vector3.ZERO, Color("4a3420"))
	Props.cyl(platen, 0.012, 0.13, Vector3(0, 0.075, 0), Color("8a7a60"), Vector3.ZERO, 6)
	var tw := platen.create_tween().set_loops()
	tw.tween_property(platen, "position:y", 0.12, 0.35).from(0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_interval(0.25)
	tw.tween_property(platen, "position:y", 0.22, 0.6)
	tw.tween_interval(0.4)
	# Basılan sayfa öne kayar
	var page := Props.box(st, Vector3(0.1, 0.004, 0.13), Vector3(0, 0.104, -0.02), Color("f6f2e6"))
	_swing(page, "position:z", -0.02, 0.17, 0.8, 0.6)
	var g := _doll(st, Vector3(0.25, 0.02, 0.05), Color("3a2a1e"), "cap", -70.0)
	Props.box(g, Vector3(0.04, 0.05, 0.02), Vector3(0, 0.22, 0.035), Color("8a7a6a"))


# ---------------------------------------------------------------- 1492: üç gemi ve ada

static func _columbus(st: Node3D) -> void:
	_base(st, Color("2a6aa0"))
	for k in 4:
		Props.box(st, Vector3(0.86, 0.004, 0.02), Vector3(0, 0.022, -0.2 + k * 0.13), Color("5a9ac8"))
	var fleet := Node3D.new()
	st.add_child(fleet)
	for k in 3:
		var sh := _ship(fleet, Vector3(-0.3 + k * 0.13, 0.02, -0.12 + (k % 2) * 0.14), 0.7 + (0.15 if k == 0 else 0.0), k == 0)
		_swing(sh, "rotation:z", -0.09, 0.09, 1.1 + k * 0.2, k * 0.3)
	_swing(fleet, "position:x", 0.0, 0.12, 4.0)
	Props.ball(st, 0.12, Vector3(0.33, 0.0, 0.08), Color("e0c890"), Vector3(1.0, 0.45, 1.0), 10)
	Props.cyl(st, 0.008, 0.18, Vector3(0.33, 0.12, 0.08), Color("6a4a2a"), Vector3(0, 0, 8), 5)
	for k in 4:
		Props.box(st, Vector3(0.11, 0.008, 0.03), Vector3(0.33 + cos(k * 1.6) * 0.04, 0.21, 0.08 + sin(k * 1.6) * 0.04), Color("3a8a3a"), Vector3(0, k * 45.0, -15))


# ---------------------------------------------------------------- 1517: kapıya çivilenen tezler

static func _luther(st: Node3D) -> void:
	_base(st, Color("7a7470"))
	Props.box(st, Vector3(0.6, 0.42, 0.05), Vector3(0, 0.22, -0.2), Color("b8aa94"))
	Props.box(st, Vector3(0.18, 0.3, 0.02), Vector3(0, 0.17, -0.17), Color("6a4426"))
	Props.ball(st, 0.09, Vector3(0, 0.32, -0.18), Color("6a4426"), Vector3(1.0, 0.6, 0.2), 8)
	Props.box(st, Vector3(0.07, 0.09, 0.004), Vector3(0.02, 0.2, -0.158), Color("f6f2e6"))
	var lu := _doll(st, Vector3(0.06, 0.02, -0.06), Color("1a1a1e"), "", 180.0)
	var arm := _arm(lu, "arm_r")
	Props.box(arm, Vector3(0.012, 0.012, 0.05), Vector3(0, -0.095, 0.02), Color("5a5a60"))
	_swing(arm, "rotation:x", -2.4, -1.6, 0.18)


# ---------------------------------------------------------------- 1687: Newton ve elma

static func _newton(st: Node3D) -> void:
	_base(st, Color("6a9a4a"))
	Props.cyl(st, 0.03, 0.46, Vector3(-0.12, 0.24, -0.12), Color("6a4a2a"), Vector3.ZERO, 6)
	Props.ball(st, 0.17, Vector3(-0.08, 0.54, -0.1), Color("3a7a3a"), Vector3(1.2, 0.8, 1.0), 10)
	var nw := _doll(st, Vector3(0.0, 0.02, 0.02), Color("4a3a5a"), "wig", 20.0)
	var apple := Props.ball(st, 0.022, Vector3(0.0, 0.46, 0.02), Color("c42a22"), Vector3.ONE, 6)
	var tw := apple.create_tween().set_loops()
	tw.tween_interval(1.4)
	tw.tween_callback(func(): apple.visible = true)
	tw.tween_property(apple, "position:y", 0.31, 0.45).from(0.46).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(apple, "position", Vector3(0.12, 0.03, 0.08), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.6)
	tw.tween_callback(func(): apple.visible = false)
	tw.tween_property(apple, "position", Vector3(0.0, 0.46, 0.02), 0.01)
	var tw2 := nw.create_tween().set_loops()
	tw2.tween_interval(1.85)
	tw2.tween_property(nw, "scale", Vector3(1.1, 0.85, 1.1), 0.08)
	tw2.tween_property(nw, "scale", Vector3.ONE, 0.25)
	tw2.tween_interval(1.27)


# ---------------------------------------------------------------- 1769: buhar makinesi

static func _steam(st: Node3D) -> void:
	_base(st, Color("5a5048"))
	Props.cyl(st, 0.07, 0.24, Vector3(-0.15, 0.09, -0.05), Color("3a3a3e"), Vector3(0, 0, 90), 12)
	Props.cyl(st, 0.025, 0.36, Vector3(-0.28, 0.2, -0.12), Color("7a4a3a"), Vector3.ZERO, 8)
	Props.box(st, Vector3(0.03, 0.3, 0.03), Vector3(0.0, 0.17, -0.05), Color("6a4426"))
	var beam := Node3D.new()
	beam.position = Vector3(0.0, 0.33, -0.05)
	st.add_child(beam)
	Props.box(beam, Vector3(0.4, 0.025, 0.03), Vector3.ZERO, Color("4a3420"))
	_swing(beam, "rotation:z", -0.25, 0.25, 0.7)
	var wheel := Node3D.new()
	wheel.position = Vector3(0.24, 0.15, -0.05)
	st.add_child(wheel)
	Props.ring(wheel, 0.09, 0.11, Vector3.ZERO, Color("3a3a3e"), Vector3(90, 0, 0))
	for k in 3:
		Props.box(wheel, Vector3(0.012, 0.2, 0.012), Vector3.ZERO, Color("3a3a3e"), Vector3(0, 0, k * 60.0))
	_spin(wheel, 1.4, "z")
	for k in 3:
		var puff := Props.ball(st, 0.035, Vector3(-0.28, 0.4, -0.12), Color("d8d8d8"), Vector3.ONE, 6)
		var tw := puff.create_tween().set_loops()
		tw.tween_interval(k * 0.6)
		tw.tween_property(puff, "position", Vector3(-0.24, 0.62, -0.14), 1.8).from(Vector3(-0.28, 0.4, -0.12))
		tw.parallel().tween_property(puff, "scale", Vector3.ONE * 2.2, 1.8).from(Vector3.ONE * 0.6)


# ---------------------------------------------------------------- 1789: Bastille

static func _bastille(st: Node3D) -> void:
	_base(st, Color("7a7064"))
	var stone := Color("8a8478")
	Props.box(st, Vector3(0.5, 0.26, 0.08), Vector3(0, 0.15, -0.2), stone)
	for sx: float in [-0.27, 0.27]:
		Props.cyl(st, 0.07, 0.36, Vector3(sx, 0.2, -0.2), stone.darkened(0.08), Vector3.ZERO, 10)
	for k in 3:
		var d := _doll(st, Vector3(-0.15 + k * 0.15, 0.02, 0.1), [Color("2a4ab0"), Color("efe9dc"), Color("c42a22")][k], "cap", 180.0)
		_swing(d, "position:y", 0.02, 0.05, 0.3, k * 0.1)
	var fl := Node3D.new()
	fl.position = Vector3(0.0, 0.32, 0.1)
	st.add_child(fl)
	Props.cyl(st, 0.005, 0.32, Vector3(0.0, 0.18, 0.1), Color("4a3020"), Vector3.ZERO, 4)
	for k in 3:
		Props.box(fl, Vector3(0.04, 0.08, 0.004), Vector3(0.02 + k * 0.04, 0, 0), [Color("2a4ab0"), Color("f2f0ea"), Color("c42a22")][k])
	_swing(fl, "rotation:y", -0.5, 0.5, 0.7)


# ---------------------------------------------------------------- 1815: Waterloo, toprağın kurumasını bekleyen Napolyon

static func _waterloo(st: Node3D) -> void:
	_base(st, Color("5a4a32"))
	Props.ball(st, 0.15, Vector3(-0.22, 0.0, 0.0), Color("6a7a3a"), Vector3(1.3, 0.5, 1.0), 10)
	var nap := _doll(st, Vector3(-0.22, 0.07, 0.0), Color("24365e"), "bicorne", 60.0)
	_swing(nap, "rotation:y", deg_to_rad(40.0), deg_to_rad(80.0), 1.6)
	for k in 3:
		var r := _doll(st, Vector3(0.22, 0.02, -0.15 + k * 0.12), Color("b8262a"), "top", -90.0, 0.85)
		_swing(r, "position:y", 0.02, 0.04, 0.35, k * 0.12)
	var sun := Props.ball(st, 0.05, Vector3(0.0, 0.48, -0.2), Color("ffd060"), Vector3.ONE, 8, 1.6)
	for k in 3:
		Props.ball(st, 0.06, Vector3(-0.06 + k * 0.06, 0.48, -0.18), Color("e8e8ec"), Vector3(1.2, 0.8, 0.8), 8)
	_swing(sun, "position:x", -0.15, 0.2, 3.0)


# ---------------------------------------------------------------- 1903: Wright Flyer

static func _flyer(st: Node3D) -> void:
	_base(st, Color("e0cc98"))
	Props.box(st, Vector3(0.7, 0.012, 0.025), Vector3(0, 0.026, 0.0), Color("6a4426"))
	var plane := Node3D.new()
	st.add_child(plane)
	var cloth := Color("efe6cc")
	for y: float in [0.04, 0.1]:
		Props.box(plane, Vector3(0.08, 0.006, 0.36), Vector3(0, y, 0), cloth)
	for z: float in [-0.15, 0.0, 0.15]:
		Props.box(plane, Vector3(0.004, 0.06, 0.004), Vector3(0.02, 0.07, z), Color("6a4426"))
	Props.box(plane, Vector3(0.04, 0.004, 0.1), Vector3(0.13, 0.07, 0), cloth)
	var pilot := _doll(plane, Vector3(0, 0.055, 0), Color("3a3a40"), "cap", 0.0, 0.6)
	pilot.rotation_degrees = Vector3(0, 90, 90)
	var tw := plane.create_tween().set_loops()
	tw.tween_property(plane, "position", Vector3(-0.08, 0.0, 0), 0.9).from(Vector3(-0.32, 0.0, 0)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(plane, "position", Vector3(0.12, 0.12, 0), 0.6).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(plane, "rotation:z", -0.15, 0.6)
	tw.tween_property(plane, "position", Vector3(0.3, 0.02, 0), 0.7).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(plane, "rotation:z", 0.0, 0.7)
	tw.tween_interval(0.8)
	tw.tween_property(plane, "position", Vector3(-0.32, 0.0, 0), 0.01)


# ---------------------------------------------------------------- 1914: yanlış sokağa sapan araba

static func _sarajevo(st: Node3D) -> void:
	_base(st, Color("8a8478"))
	Props.box(st, Vector3(0.86, 0.3, 0.05), Vector3(0, 0.17, -0.23), Color("c8b898"))
	for k in 4:
		Props.box(st, Vector3(0.07, 0.09, 0.006), Vector3(-0.3 + k * 0.2, 0.22, -0.204), Color("3a4a5a"))
	var car := Node3D.new()
	car.position = Vector3(-0.3, 0.02, 0.05)
	st.add_child(car)
	Props.box(car, Vector3(0.16, 0.04, 0.08), Vector3(0, 0.04, 0), Color("1a1a1e"))
	Props.box(car, Vector3(0.07, 0.035, 0.08), Vector3(-0.02, 0.08, 0), Color("2a2a2e"))
	for sx: float in [-0.055, 0.055]:
		for sz: float in [-0.045, 0.045]:
			Props.cyl(car, 0.018, 0.012, Vector3(sx, 0.018, sz), Color("101012"), Vector3(90, 0, 0), 8)
	var tw := car.create_tween().set_loops()
	tw.tween_property(car, "position:x", 0.15, 1.6).from(-0.3).set_trans(Tween.TRANS_SINE)
	tw.tween_property(car, "rotation:y", deg_to_rad(35.0), 0.4)
	tw.tween_interval(0.6)
	tw.tween_property(car, "rotation:y", 0.0, 0.4)
	tw.tween_property(car, "position:x", -0.3, 1.4).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(0.4)


# ---------------------------------------------------------------- 1945: savaş biter, imza ve konfeti

static func _peace(st: Node3D) -> void:
	_base(st, Color("7a8088"))
	Props.box(st, Vector3(0.22, 0.08, 0.12), Vector3(0, 0.06, -0.02), Color("6a4426"))
	Props.box(st, Vector3(0.12, 0.004, 0.08), Vector3(0, 0.102, -0.02), Color("f6f2e6"))
	for sx: float in [-1.0, 1.0]:
		var d := _doll(st, Vector3(sx * 0.18, 0.02, -0.02), [Color("3a4a3a"), Color("2a2a34")][int(sx > 0)], "cap", -sx * 90.0)
		_swing(d, "rotation:x", 0.0, 0.35, 0.8, 0.4 if sx > 0 else 0.0)
	for k in 8:
		var c := Props.box(st, Vector3(0.018, 0.004, 0.012), Vector3(-0.35 + k * 0.1, 0.5, -0.15 + (k % 3) * 0.12), [Color("c42a22"), Color("2a5ab0"), Color("e8c020"), Color("2a9a4a")][k % 4])
		var tw := c.create_tween().set_loops()
		tw.tween_interval(k * 0.2)
		tw.tween_property(c, "position:y", 0.03, 2.2).from(0.5)
		tw.parallel().tween_property(c, "rotation:y", TAU * 2.0, 2.2).from(0.0)


# ---------------------------------------------------------------- 1969: Ay'a iniş

static func _moon(st: Node3D) -> void:
	_base(st, Color("9a9aa0"))
	for k in 3:
		Props.ring(st, 0.03 + k * 0.015, 0.045 + k * 0.015, Vector3(-0.25 + k * 0.22, 0.022, 0.12 - k * 0.08), Color("7a7a80"))
	var lm := Node3D.new()
	lm.position = Vector3(-0.18, 0.02, -0.1)
	st.add_child(lm)
	Props.box(lm, Vector3(0.12, 0.08, 0.12), Vector3(0, 0.1, 0), Color("c8a040"), Vector3(0, 45, 0), 0.3)
	Props.box(lm, Vector3(0.09, 0.07, 0.09), Vector3(0, 0.17, 0), Color("c8c8cc"), Vector3(0, 45, 0))
	for k in 4:
		var a := TAU * k / 4.0
		Props.box(lm, Vector3(0.008, 0.08, 0.008), Vector3(cos(a) * 0.08, 0.04, sin(a) * 0.08), Color("d8c070"), Vector3(sin(a) * 25.0, 0, -cos(a) * 25.0))
	Props.cyl(st, 0.004, 0.24, Vector3(0.22, 0.13, -0.05), Color("d8d8d8"), Vector3.ZERO, 4)
	Props.box(st, Vector3(0.1, 0.06, 0.003), Vector3(0.27, 0.22, -0.05), Color("f2f0ea"))
	Props.box(st, Vector3(0.04, 0.03, 0.004), Vector3(0.245, 0.235, -0.048), Color("2a3a8a"))
	for k in 3:
		Props.box(st, Vector3(0.1, 0.006, 0.004), Vector3(0.27, 0.2 + k * 0.012, -0.0485), Color("b8262a"))
	var astro := _doll(st, Vector3(0.08, 0.02, 0.08), Color("f2f2ee"), "astro", -30.0)
	var tw := astro.create_tween().set_loops()
	tw.tween_property(astro, "position", Vector3(0.0, 0.1, 0.1), 0.7).from(Vector3(0.08, 0.02, 0.08)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(astro, "position", Vector3(-0.06, 0.02, 0.12), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(astro, "position", Vector3(0.0, 0.1, 0.1), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(astro, "position", Vector3(0.08, 0.02, 0.08), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	Props.ball(st, 0.06, Vector3(0.3, 0.46, -0.2), Color("3a7ad8"), Vector3.ONE, 10, 0.8)
	Props.ball(st, 0.03, Vector3(0.31, 0.47, -0.15), Color("3aa04a"), Vector3(1.2, 0.8, 0.4), 6, 0.6)


# ---------------------------------------------------------------- 1989: Berlin Duvarı

static func _berlin(st: Node3D) -> void:
	_base(st, Color("8a8a88"))
	var cols := [Color("e83a5a"), Color("3ab8e8"), Color("e8c020"), Color("6ae04a")]
	for k in 4:
		Props.box(st, Vector3(0.19, 0.3, 0.06), Vector3(-0.3 + k * 0.2, 0.17, -0.12), Color("c8c4bc"))
		Props.box(st, Vector3(0.12, 0.1, 0.004), Vector3(-0.3 + k * 0.2, 0.17 + (k % 2) * 0.06, -0.088), cols[k], Vector3(0, 0, k * 12.0 - 15.0))
	var top := _doll(st, Vector3(-0.1, 0.32, -0.12), Color("4a5a8a"), "", 0.0)
	_swing(_arm(top, "arm_r"), "rotation:z", 2.4, 3.0, 0.3)
	_swing(_arm(top, "arm_l"), "rotation:z", -2.4, -3.0, 0.3, 0.15)
	var ham := _doll(st, Vector3(0.2, 0.02, 0.0), Color("6a3a2a"), "", 180.0)
	_swing(_arm(ham, "arm_r"), "rotation:x", -2.2, -1.2, 0.2)
	for k in 3:
		var chip := Props.box(st, Vector3(0.02, 0.015, 0.015), Vector3(0.18 + k * 0.02, 0.18, -0.08), Color("c8c4bc"))
		var tw := chip.create_tween().set_loops()
		tw.tween_interval(k * 0.25)
		tw.tween_property(chip, "position:y", 0.025, 0.4).from(0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_interval(0.3)


# ---------------------------------------------------------------- 2026: bugün

static func _now(st: Node3D) -> void:
	_base(st, Color("5a5a60"))
	var d := _doll(st, Vector3(-0.1, 0.02, 0.0), Color("3a5a8a"), "", 20.0)
	var arm := _arm(d, "arm_r")
	Props.box(arm, Vector3(0.03, 0.05, 0.006), Vector3(0.0, -0.1, 0.03), Color("9ae0ff"), Vector3(-60, 0, 0), 1.6)
	arm.rotation.x = -1.0
	var head_down := d.create_tween()
	head_down.tween_property(d, "rotation:x", 0.12, 0.5)
	Props.cyl(st, 0.04, 0.12, Vector3(0.28, 0.08, 0.1), Color("ff6a1a"), Vector3.ZERO, 8, 0.008)
	var bot := Node3D.new()
	bot.position = Vector3(0.1, 0.02, 0.12)
	st.add_child(bot)
	Props.box(bot, Vector3(0.08, 0.07, 0.07), Vector3(0, 0.05, 0), Color("e8e8e4"))
	Props.ball(bot, 0.012, Vector3(0, 0.1, 0), Color("ff4a3a"), Vector3.ONE, 5, 1.5)
	for sx: float in [-0.03, 0.03]:
		Props.cyl(bot, 0.014, 0.08, Vector3(sx, 0.014, 0), Color("2a2a2e"), Vector3(90, 0, 0), 6)
	_swing(bot, "position:x", 0.25, -0.05, 2.2)


# ---------------------------------------------------------------- 2150: yüzen şehir

static func _future(st: Node3D) -> void:
	_base(st, Color("1a1a2a"))
	for k in 4:
		Props.box(st, Vector3(0.86, 0.004, 0.006), Vector3(0, 0.022, -0.2 + k * 0.13), Color("40f0ff"), Vector3.ZERO, 1.5)
	for k in 4:
		var t := Node3D.new()
		t.position = Vector3(-0.3 + k * 0.2, 0.08, -0.08 + (k % 2) * 0.1)
		st.add_child(t)
		var h := 0.12 + (k % 3) * 0.06
		Props.box(t, Vector3(0.08, h, 0.08), Vector3(0, h * 0.5, 0), [Color("8a7ad8"), Color("5ab8d8"), Color("d87ab8"), Color("7ad8a8")][k])
		Props.box(t, Vector3(0.082, 0.01, 0.082), Vector3(0, h, 0), Color("ff40d0"), Vector3.ZERO, 2.0)
		_swing(t, "position:y", 0.06, 0.12, 1.2 + k * 0.3, k * 0.2)
	var piv := Node3D.new()
	piv.position = Vector3(0, 0.36, -0.02)
	st.add_child(piv)
	var car := Props.cyl(piv, 0.02, 0.07, Vector3(0.28, 0, 0), Color("f2f0ea"), Vector3(0, 0, 90), 8)
	Props.ball(car, 0.012, Vector3(0, -0.035, 0), Color("40f0ff"), Vector3.ONE, 5, 2.0)
	_spin(piv, 3.5)
