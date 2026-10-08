extends Node3D
## Peribolosta gerçek savaş kalabalığı (Bölüm 0 ve fragmanın soğuk açılışı): kalkanını başının üstüne kaldırıp koşan
## savunucular, kova/taş taşıyanlar, gedik ağzında kalkan kalkana duran küme, yerde oklanmış yatanlar ve ara ara
## ok yiyip geriye devrilen koşanlar. Koşanlar koridorun iki ucu arasında gidip gelir (uçlarda yok olmazlar).
## Kullanım: var b := BattleExtras.new(); parent.add_child(b); b.populate(a, b, genişlik, koşan, ölü, küme, tohum)
##   b.assault = assault   (varsa koşanların çevresine de ok iner)

const LOOKS := [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96"), Color("6a4a30"), Color("4a5a3a")]

var assault: Assault
## "byz": Bizans savunucuları (peribolos, surların içi). "osm": Osmanlı hücum kıtaları (surların önü, hendek):
## azaplar (kırmızı keçe börk, zırhsız, hasır kalkan, yay/mızrak), yeniçeriler (beyaz börk, uzun dolama),
## sipahiler (zincir zırh, sarıklı çiçak miğfer). Zemin hendeğin kesitine göre (Assault.ground_y).
var side := "byz"
var flat := false                # düz zemin (LandWalls/Assault arazisi olmayan haritalar: Blakherna)
var flat_y := 0.0
var hit_every := 1.3             # saniyede bir koşan ok yiyip düşer (0: hiç)
var max_fallen_ratio := 0.45
var rng := RandomNumberGenerator.new()
var _runners: Array = []         # {p, a, b, t, speed, dir}
var _fallen := 0
var _run_total := 0
var _hit_t := 1.0
var _arrow_t := 0.6
var _avoid: Array = []           # [nokta, yarıçap]: buralarda kimse devrilmez (kamera önü)


## Kesmede kadrajın önüne düşenler (yeni çekim başlarken) gizlenir.
func hide_near(p: Vector3, r: float) -> void:
	for c in get_children():
		if c is Node3D and (c as Node3D).global_position.distance_to(p) < r:
			(c as Node3D).visible = false


## "Siper!": koşanlar durur, herkes çömelir; kalkanı olanlar kalkanı başının üstünde tutar.
var _cover := false


func take_cover() -> void:
	_cover = true
	# Koşarken yan yana gelenler olduğu yerde çömelir: iç içe durmasınlar (ayrılır, şeritteki yerleri de kayar)
	for r: Dictionary in _runners:
		var p: Person = r["p"]
		if is_instance_valid(p) and p.is_inside_tree():
			var before := p.global_position
			if Unclip.spread(p, 0.55):
				var lane := (r["b"] as Vector3) - (r["a"] as Vector3)
				lane.y = 0.0
				if lane.length() > 0.01:
					r["off"] = float(r.get("off", 0.0)) + (p.global_position - before).dot(lane.normalized().cross(Vector3.UP))
	duck_all(self, [])


## Kökün altındaki ayakta duran herkesi (yatanlar, kilitliler hariç) çömeltir.
static func duck_all(root: Node, except: Array, extras_only := false) -> void:
	for n in root.find_children("*", "Node3D", true, false):
		if not n is Person:
			continue
		var p := n as Person
		if p in except or not p.visible or p.rig == null or p.rig.lock > 0:
			continue
		if extras_only and not p.has_meta("no_talk"):
			continue
		# Osmanlı kıtaları kendi toplarının atışında siper almaz
		if p.get_parent() and p.get_parent().get("side") == "osm":
			continue
		# Gediğin moloz yamacındakiler çömelmez (eğimde çömelen, ayakları molozun içine gömülüyordu)
		if LandWalls.rubble_y(p.global_position.x, p.global_position.z) > 0.1:
			continue
		if p.rig.activity in ["", "carry"]:
			p.set_meta("pre_cover", p.rig.activity)
			p.set_activity("crouch")


## Top ateşinde kısa siper (oyun içi): herkes çömelir, secs sonra kalkıp işine döner (koşanlar yeniden koşar).
## Yalnız figüranlar (no_talk) çömelir: konuşan karakterlerin sahnesi bozulmaz.
static func cover_briefly(root: Node, secs := 3.5) -> void:
	var tree := root.get_tree()
	for b in tree.get_nodes_in_group("battle_extras"):
		if b.get("side") != "osm":
			(b as Node).call("take_cover")
	duck_all(root, [], true)
	var up := func() -> void:
		if not is_instance_valid(root):
			return
		for b in tree.get_nodes_in_group("battle_extras"):
			b.set("_cover", false)
		for n in root.find_children("*", "Node3D", true, false):
			if n is Person and n.has_meta("pre_cover") and (n as Person).rig and (n as Person).rig.lock == 0:
				(n as Person).set_activity(str(n.get_meta("pre_cover")))
				n.remove_meta("pre_cover")
	tree.create_timer(secs, false).timeout.connect(up)


func avoid(p: Vector3, r: float) -> void:
	_avoid.append([p, r])


## Başın üstünde tutulan yuvarlak kalkan: el(ler) kalkanın ortasının altında tutar; kalkanı Rig her karede elin
## üstüne yerleştirir (Rig.shield_node). one_hand: yalnız sol el (sağ elde yük).
## Osmanlı hasır kalkanı (kalkan): ahşap göbek çevresine spiral örülmüş kamış, renkli iplikle dikili halkalar,
## demir göbek ve kenar. Blades.shield gibi yüzü +Z'ye bakar.
static func kalkan(parent: Node3D, thread: Color) -> Node3D:
	var n := Node3D.new()
	parent.add_child(n)
	# Kamış sargılar: açık ve koyu saman tonları sırayla (spiral örgü), ortası hafif kabarık
	for k in 7:
		var r := 0.3 - k * 0.04
		var c := Color("c8a868") if k % 2 == 0 else Color("a88a50")
		Props.cyl(n, r, 0.03 + k * 0.005, Vector3(0, 0, k * 0.004), c, Vector3(90, 0, 0), 20)
	# Renkli iplik dikiş halkaları (ince) ve demir kenar, demir göbek
	for r: float in [0.25, 0.17]:
		Props.ring(n, r - 0.008, r + 0.008, Vector3(0, 0, 0.022 + (0.3 - r) * 0.1), thread, Vector3(90, 0, 0))
	Props.ring(n, 0.295, 0.315, Vector3(0, 0, 0.0), Color("4a4a50"), Vector3(90, 0, 0))
	Props.ball(n, 0.06, Vector3(0, 0, 0.045), Color("6a6a72"), Vector3(1, 1, 0.6), 8)
	return n


static func overhead_shield(p: Person, color: Color, one_hand := false, wicker := false) -> Node3D:
	var n := Node3D.new()
	n.name = "OverShield"
	var parent: Node3D = p.rig.body if p.rig and p.rig.body else p
	parent.add_child(n)
	n.position = Vector3(0, 2.0, 0.05)
	if wicker:
		kalkan(n, color).scale = Vector3.ONE * 1.2
	else:
		Blades.shield(n, color, Color("9aa0a8")).scale = Vector3.ONE * 1.2
	if p.rig:
		p.rig.shield_up = 1 if one_hand else 2
		p.rig.shield_node = n
	return n


## Ok demeti: iple iki yerden bağlı ~18 ok (uzunluk yerel Z boyunca, uçlar +Z).
static func arrow_bundle(parent: Node3D) -> Node3D:
	var n := Node3D.new()
	parent.add_child(n)
	var am := Assault.arrow_mesh()
	for k in 18:
		var a := k * 2.4
		var r := 0.02 + (k % 3) * 0.022
		var mi := MeshInstance3D.new()
		mi.mesh = am
		n.add_child(mi)
		mi.position = Vector3(cos(a) * r, sin(a) * r, (k % 4) * 0.02 - 0.03)
		mi.rotation.z = a
	for z: float in [-0.18, 0.2]:
		Props.cyl(n, 0.075, 0.035, Vector3(0, 0, z), Color("8a7048"), Vector3(90, 0, 0), 10)
	return n


const AZAP_COATS := [Color("8a3a2e"), Color("7a5a38"), Color("a07a48"), Color("5a4a3a")]
const JAN_COATS := [Color("2e4a7a"), Color("7a2a24"), Color("3a5a3a")]


## Osmanlı askeri: i'ye göre azap, yeniçeri ya da sipahi (araştırma: docs/SIEGE.md, kıyafet notu).
static func osm_look(i: int) -> Dictionary:
	match i % 5:
		0, 1, 2:
			return {"coat": AZAP_COATS[i % AZAP_COATS.size()], "pants": Color("5a4630"), "hat": "azap", "armor": "none",
				"beard": i % 2 == 0, "mustache": true, "n": 700 + i}
		3:
			var jc: Color = JAN_COATS[i % JAN_COATS.size()]
			return {"coat": jc, "robe": jc.darkened(0.1), "pants": Color("3a2a22"), "hat": "bork", "armor": "none",
				"mustache": true, "n": 700 + i}
		_:
			return {"coat": Color("6a3a2a"), "pants": Color("3a2a22"), "hat": "cicak", "armor": "mail", "beard": true, "n": 700 + i}


func _person(i: int, pos: Vector3) -> Person:
	var look: Dictionary = osm_look(i) if side == "osm" else {"coat": LOOKS[i % LOOKS.size()], "pants": Color("3a2a22"),
		"hat": "helm" if i % 4 != 3 else "", "beard": i % 2 == 0, "mustache": true, "n": 900 + i}
	var p := Person.new(look)
	p.set_meta("no_talk", true)
	add_child(p)
	p.global_position = pos
	return p


func _ground(p: Vector3) -> Vector3:
	if flat:
		return Vector3(p.x, flat_y, p.z)
	if side == "osm":
		return Vector3(p.x, Assault.ground_y(p.x, p.z), p.z)
	return LandWalls.on_rubble(Vector3(p.x, 0, p.z))


## "Siper!" herkese: sahnedeki bütün BattleExtras koşanları durur ve kökteki ayaktakiler çömelir.
static func all_take_cover(root: Node, except: Array) -> void:
	for b in root.get_tree().get_nodes_in_group("battle_extras"):
		(b as Node).call("take_cover")
	duck_all(root, except)


func populate(a: Vector3, b: Vector3, width: float, n_run: int, n_dead: int, n_wall: int, seed := 7) -> void:
	add_to_group("battle_extras")
	rng.seed = seed
	var along := (b - a)
	var perp := Vector3(-along.z, 0, along.x).normalized()
	for i in n_run:
		var off := perp * rng.randf_range(-width * 0.5, width * 0.5)
		var pa := _ground(a + off + along.normalized() * rng.randf_range(-2.0, 2.0))
		var pb := _ground(b + off + along.normalized() * rng.randf_range(-2.0, 2.0))
		var p := _person(i, pa)
		var kind := i % 5
		if side == "osm":
			# Azaplar hasır kalkanı başının üstünde (surdan yağan oklara), yeniçeri yay, sipahi mızrak
			match kind:
				0, 1, 2:
					overhead_shield(p, [Color("8a2a2a"), Color("2e4a7a"), Color("6a4a2a")][i % 3], false, true)
				3:
					p.equip("bow")
				_:
					p.equip("spear")
		elif kind <= 2:
			overhead_shield(p, [Color("7a2a24"), Color("3a4a6a"), Color("6a5a3a")][i % 3])
		elif kind == 3:
			p.set_activity("carry")
			Props.cyl(p, 0.16, 0.3, Vector3(0, 1.0, 0.36), Color("8a6440"), Vector3.ZERO, 8, 0.19)
		else:
			p.equip("spear_shield", Color("5a2a24"))
		# Şeritteki ilk yeri (ilk karede oraya sıçrayıp önceki koşanın üstüne düşmesin): boş bir yer
		var t0 := rng.randf()
		for k in 8:
			if not Unclip.crowded(p, _ground(pa.lerp(pb, t0)), 0.8):
				break
			t0 = fmod(t0 + 0.137, 1.0)
		p.global_position = _ground(pa.lerp(pb, t0))
		_runners.append({"p": p, "a": pa, "b": pb, "t": t0, "speed": rng.randf_range(3.4, 5.0), "dir": 1.0 if i % 2 == 0 else -1.0,
			"off": 0.0, "w": width * 0.5})
	_run_total = n_run
	var laid: Array[Vector3] = []
	for i in n_dead:
		var pos := _ground(a.lerp(b, rng.randf()) + perp * rng.randf_range(-width * 0.5, width * 0.5))
		# Yerde yatanlar üst üste düşmesin, koşanların başlangıç yerine de (VISAUDIT overlap, 26)
		for k in 10:
			var near := false
			for q: Vector3 in laid:
				near = near or Vector2(q.x - pos.x, q.z - pos.z).length() < 1.3
			for r: Dictionary in _runners:
				var rp: Vector3 = (r["p"] as Node3D).global_position
				near = near or Vector2(rp.x - pos.x, rp.z - pos.z).length() < 1.0
			if not near:
				break
			pos = _ground(a.lerp(b, rng.randf()) + perp * rng.randf_range(-width * 0.5, width * 0.5))
		laid.append(pos)
		var p := _person(100 + i, pos)
		_lay(p, rng.randf() < 0.5)
		for k in rng.randi_range(1, 3):
			_stick(p, Vector3(rng.randf_range(-0.15, 0.15), rng.randf_range(0.9, 1.35), 0.12))
		if rng.randf() < 0.6:
			var sh := Node3D.new()
			add_child(sh)
			sh.global_position = pos + Vector3(rng.randf_range(-0.9, 0.9), 0.04, rng.randf_range(-0.9, 0.9))
			sh.rotation = Vector3(-PI * 0.5, rng.randf() * TAU, 0)
			if side == "osm":
				kalkan(sh, Color("8a2a2a"))
			else:
				Blades.shield(sh, Color("5a2a24"), Color("9aa0a8"))
		if rng.randf() < 0.5:
			Props.cyl(self, rng.randf_range(0.35, 0.55), 0.01, _ground(pos) + Vector3(0, 0.012, 0), Color("3a1a16"), Vector3.ZERO, 12)
	for i in n_dead * 2:
		_debris(a.lerp(b, rng.randf()) + perp * rng.randf_range(-width * 0.6, width * 0.6))
	# Gedik ağzında kalkan kalkana duran küme (başlarının üstünde çatı gibi kalkanlar)
	var wall_c := _ground(LandWalls.BREACH + Vector3(0, 0, -3.2))
	for i in n_wall:
		var pos := _ground(wall_c + Vector3((i % 4) * 0.72 - 1.1, 0, -floorf(i / 4.0) * 0.7))
		var p := _person(200 + i, pos)
		p.look_at_from_position(pos, pos + Vector3(0, 0, 5), Vector3.UP)
		p.rotate_y(PI)
		overhead_shield(p, [Color("7a2a24"), Color("8a8e96")][i % 2])


## Yerde yatan: sırtüstü ya da yüzüstü, düz uzanmış, kollar açık; biraz yana dönük olabilir. Gövde yere değer
## (eskiden "düşüş" pozunda kalıyor, bacakları havada, yere değmeden eğik duruyorlardı).
func _lay(p: Person, back: bool) -> void:
	if p.rig:
		p.rig.shield_up = 0
		p.set_activity("dead")
		var rg := p.rig
		var hold := func() -> void:
			rg.lock += 1
		p.get_tree().create_timer(0.5).timeout.connect(hold)
	p.rotation = Vector3(-PI * 0.5 if back else PI * 0.5, rng.randf() * TAU, rng.randf_range(-0.15, 0.15))
	p.global_position = _ground(p.global_position) + Vector3(0, 0.13, 0)


## Savaş enkazı: surdan düşmüş taş bloklar, kırık kılıçlar, yanan oklar, dağılmış barikat kalasları, kara lekeler.
func _debris(at: Vector3) -> void:
	var n := Node3D.new()
	add_child(n)
	n.global_position = _ground(at)
	match rng.randi() % 5:
		0:
			for k in rng.randi_range(1, 3):
				Props.box(n, Vector3(rng.randf_range(0.35, 0.7), rng.randf_range(0.25, 0.45), rng.randf_range(0.3, 0.55)),
					Vector3(rng.randf_range(-0.6, 0.6), 0.15, rng.randf_range(-0.6, 0.6)), LandWalls.C_STONE.darkened(rng.randf_range(0.15, 0.4)),
					Vector3(rng.randf_range(-15, 15), rng.randf() * 180.0, rng.randf_range(-15, 15)))
		1:
			# Kırık kılıç: kabzalı kısa parça ve uzakta kopmuş uç
			Props.box(n, Vector3(0.04, 0.012, 0.42), Vector3(0, 0.02, 0), Color("b8bec6"), Vector3(0, rng.randf() * 180.0, 0))
			Props.box(n, Vector3(0.2, 0.03, 0.04), Vector3(0, 0.03, -0.2), Color("7a6a4a"), Vector3(0, rng.randf() * 180.0, 0))
			Props.box(n, Vector3(0.04, 0.012, 0.3), Vector3(0.5, 0.02, 0.3), Color("b8bec6"), Vector3(0, rng.randf() * 180.0, 0))
		2:
			# Yanan oklar: toprağa saplı, ucunda alev
			for k in rng.randi_range(2, 4):
				var mi := MeshInstance3D.new()
				mi.mesh = Assault.arrow_mesh()
				n.add_child(mi)
				var p := Vector3(rng.randf_range(-0.7, 0.7), 0.25, rng.randf_range(-0.7, 0.7))
				mi.position = p
				mi.rotation = Vector3(-1.1 + rng.randf_range(-0.2, 0.2), rng.randf() * TAU, 0)
				Props.ball(n, 0.03, p + Vector3(0, 0.36, 0), Color("ffb040"), Vector3(1, 1.6, 1), 6, 3.0)
		3:
			# Dağılmış barikat kalasları
			for k in 3:
				Props.box(n, Vector3(0.22, 0.07, rng.randf_range(1.0, 1.8)), Vector3(rng.randf_range(-0.5, 0.5), 0.05 + k * 0.06, rng.randf_range(-0.4, 0.4)),
					Color("7a5634").darkened(rng.randf_range(0.0, 0.3)), Vector3(rng.randf_range(-6, 6), rng.randf() * 180.0, 0))
		4:
			Props.cyl(n, rng.randf_range(0.4, 0.7), 0.01, Vector3(0, 0.012, 0), Color("3a1a16"), Vector3.ZERO, 12)


func _stick(p: Node3D, local: Vector3) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = Assault.arrow_mesh()
	p.add_child(mi)
	mi.position = local
	mi.rotation = Vector3(rng.randf_range(-0.5, 0.5) - 0.3, rng.randf() * TAU, rng.randf_range(-0.4, 0.4))


func _process(delta: float) -> void:
	for r: Dictionary in _runners:
		if _cover:
			break
		var p: Person = r["p"]
		var pa: Vector3 = r["a"]
		var pb: Vector3 = r["b"]
		# Ayaklanıp düelloya giden (Melee.rally: gizli) şeridinde yürütülmez: gizliler birbirini görmüyor, dönünce ikisi
		# üçü aynı yerde beliriyordu (26 VISAUDIT overlap). Döndüğünde yeri doluysa şeridinde boş bir yere geçer.
		if not p.visible:
			r["hid"] = true
			continue
		if r.get("hid", false):
			r["hid"] = false
			var t0: float = r["t"]
			var side_off: float = r.get("off", 0.0)
			var lane0 := pb - pa
			lane0.y = 0.0
			var perp0 := lane0.normalized().cross(Vector3.UP) if lane0.length() > 0.01 else Vector3.RIGHT
			for k in 8:
				if not Unclip.crowded(p, _ground(pa.lerp(pb, t0) + perp0 * side_off), 0.8):
					break
				t0 = fmod(t0 + 0.137, 1.0)
			r["t"] = t0
			p.global_position = _ground(pa.lerp(pb, t0) + perp0 * side_off)
		var t_old: float = r["t"]
		var t: float = float(r["t"]) + delta * float(r["speed"]) * float(r["dir"]) / maxf(pa.distance_to(pb), 1.0)
		if t >= 1.0 or t <= 0.0:
			r["dir"] = -float(r["dir"])
			t = clampf(t, 0.0, 1.0)
		r["t"] = t
		# Önündekinin içinden geçmez: 1,5 ve 3 m önünde biri varsa (karşıdan koşan, yavaş koşan, duran) yana kayar;
		# tam karşıdaysa ikisi de kendi sağına geçer. Yol açılınca şeridine döner. (Eskiden şeritteki koşanlar karşılaşınca
		# birbirinin içinden geçiyordu.)
		var dsg := float(r["dir"])
		var lane := pb - pa
		lane.y = 0.0
		lane = lane.normalized() if lane.length() > 0.01 else Vector3.FORWARD
		var perp := lane.cross(Vector3.UP)          # sabit yan eksen (off bunun üstünde; dönüşte zıplamaz)
		var fwd := lane * dsg
		var right := perp * dsg
		var off: float = r.get("off", 0.0)
		var here := pa.lerp(pb, t) + perp * off
		var steer := 0.0
		for k: float in [1.5, 3.0]:
			var ahead := Unclip.push(p, here + fwd * k, 1.0)
			ahead.y = 0.0
			if ahead.length() > 0.01:
				var lat := ahead.dot(right)
				steer += (signf(lat) if absf(lat) > ahead.length() * 0.25 else 1.0) * (2.0 if k < 2.0 else 1.0)
		var near := Unclip.push(p, here, 0.6)
		steer += near.dot(right) * 4.0
		var lim: float = float(r.get("w", 0.7)) + 0.6
		var want := off
		if absf(steer) > 0.01:
			want = clampf(off + clampf(steer, -1.0, 1.0) * 2.6 * delta * dsg, -lim, lim)
		else:
			want = move_toward(off, 0.0, 0.6 * delta)
		# Yana kaçtığı yer bir katının (sur, siper, sandık) içiyse oraya geçmez: şeridine doğru döner
		if absf(want) > absf(off) and Unclip.in_solid(p, _ground(pa.lerp(pb, t) + perp * want), 0.18):
			want = move_toward(off, 0.0, 1.2 * delta)
		off = want
		r["off"] = off
		var np := _ground(pa.lerp(pb, t) + perp * off)
		# Şeridin yana kaymış hali bir katının (siper, sandık) içinden geçiyorsa ya da adım ince bir katının (siper)
		# yüzeyinden geçiyorsa şeride döner. Kenarına zaten sürtünen (gövdesi değen) yalnız oradan uzaklaşabilir.
		# Eskiden "zaten içinde" sayılıp tekerlekli siperin ucundan içine yürüyor, test hızında bir karede yana kayıp
		# 20 cm'lik siperin öbür yanına geçiyordu (37o, WALKTHRU)
		var cur := p.global_position
		if Unclip.crosses(p, cur, np) or (Unclip.in_solid(p, np, 0.17) and not Unclip.in_solid(p, cur, 0.17)):
			r["off"] = move_toward(off, 0.0, 2.0 * delta)
			np = _ground(pa.lerp(pb, t) + perp * float(r["off"]))
			if Unclip.in_solid(p, np, 0.17) or Unclip.crosses(p, cur, np):
				r["t"] = t_old
				r["dir"] = -dsg
				continue
		# Son denetim: yeni yer ayakta birinin içindeyse ilerlemez (önündekini bekler); uzun sürerse geri döner
		if Unclip.blocks_step(p, p.global_position, np, 0.5) or _runner_near(p, p.global_position, np):
			r["t"] = t_old
			r["blk"] = float(r.get("blk", 0.0)) + delta
			if float(r["blk"]) > 0.6:
				r["blk"] = 0.0
				r["dir"] = -dsg
			continue
		r["blk"] = 0.0
		p.global_position = np
	_part_runners()
	if hit_every > 0.0 and not _runners.is_empty() and _fallen < int(_run_total * max_fallen_ratio):
		_hit_t -= delta
		if _hit_t <= 0.0:
			_hit_t = hit_every * rng.randf_range(0.6, 1.4)
			_hit(_runners[rng.randi() % _runners.size()])
	if assault:
		_arrow_t -= delta
		if _arrow_t <= 0.0 and not _runners.is_empty():
			_arrow_t = rng.randf_range(0.35, 0.8)
			var p: Person = (_runners[rng.randi() % _runners.size()] as Dictionary)["p"]
			assault.volley(p.global_position, 2.2, 6, side != "osm", 0.6 if side != "osm" else 0.0)


## Bu karede daha önce yürümüş koşanlar (canlı konumları): Unclip.blocks_step'in kalabalık ızgarası karenin başında
## kurulur, aynı karede o yere yeni gelmiş koşanı görmez. Test hızında bir karede ~1,8 m ilerleyen iki koşan iç içe
## giriyordu (22o hendeği, 31o sokağı: VISAUDIT overlap).
func _runner_near(p: Person, from: Vector3, to: Vector3) -> bool:
	for o: Dictionary in _runners:
		var q: Person = o["p"]
		if q == p or not is_instance_valid(q) or not q.visible:
			continue
		var qp := q.global_position
		if absf(qp.y - to.y) > 0.9:
			continue
		var dn := Vector2(to.x - qp.x, to.z - qp.z).length()
		if dn < 0.5 and dn < Vector2(from.x - qp.x, from.z - qp.z).length():
			return true
	return false


## Aynı karede birlikte ilerleyenler (aynı hızla yan yana koşan iki kişi, test hızında bir karede birbirinin üstünden
## atlayan karşılıklı ikisi) adım denetiminden kaçar: kare sonunda 0,55 m'den yakın iki koşandan biri ayrılır. Aynı yöne
## koşuyorlarsa arkadaki yavaşlar ve yanına açılır, karşılıklıysa biri geri döner.
func _part_runners() -> void:
	if _cover:
		return
	for i in _runners.size():
		var ra: Dictionary = _runners[i]
		var pa: Person = ra["p"]
		for j in range(i + 1, _runners.size()):
			var rb: Dictionary = _runners[j]
			var pb: Person = rb["p"]
			var d := Vector2(pa.global_position.x - pb.global_position.x, pa.global_position.z - pb.global_position.z)
			if d.length() >= 0.55 or absf(pa.global_position.y - pb.global_position.y) > 0.9:
				continue
			if float(ra["dir"]) == float(rb["dir"]):
				var slow: Dictionary = ra if float(ra["speed"]) < float(rb["speed"]) else rb
				var fast: Dictionary = rb if slow == ra else ra
				fast["speed"] = float(slow["speed"]) * 0.85
				fast["off"] = clampf(float(fast.get("off", 0.0)) + (0.4 if float(slow.get("off", 0.0)) <= float(fast.get("off", 0.0)) else -0.4),
					-(float(fast.get("w", 0.7)) + 0.6), float(fast.get("w", 0.7)) + 0.6)
			else:
				rb["dir"] = -float(rb["dir"])
				rb["off"] = clampf(float(rb.get("off", 0.0)) + 0.4, -(float(rb.get("w", 0.7)) + 0.6), float(rb.get("w", 0.7)) + 0.6)


## Ok yiyen koşan: kalkanı düşer, geriye devrilir, yerde kalır (oklar gövdesinde).
func _hit(r: Dictionary) -> void:
	var p: Person = r["p"]
	if not p.visible:
		return            # düelloya gitmiş (gizli): dönünce yerde yatan biri olarak belirmesin
	for av: Array in _avoid:
		if p.global_position.distance_to(av[0]) < float(av[1]):
			return
	_runners.erase(r)
	_fallen += 1
	var sh := p.find_child("OverShield", true, false) as Node3D
	if sh:
		sh.reparent(self)
		var st := sh.create_tween().set_parallel(true)
		st.tween_property(sh, "global_position", _ground(sh.global_position) + Vector3(rng.randf_range(-0.6, 0.6), 0.04, rng.randf_range(-0.6, 0.6)), 0.45)
		st.tween_property(sh, "rotation", Vector3(-PI * 0.5, rng.randf() * TAU, 0), 0.45)
	_stick(p, Vector3(0.05, 1.25, 0.14))
	if p.rig:
		p.rig.shield_up = 0
		p.rig.shield_node = null
		p.rig.activity = "fall"
	var back := rng.randf() < 0.65
	var tw := p.create_tween().set_parallel(true)
	tw.tween_property(p, "rotation:x", -PI * 0.5 if back else PI * 0.5, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(p, "global_position:y", p.global_position.y + 0.14, 0.5)
	var freeze := func() -> void:
		if p.rig:
			p.set_activity("dead")
			var rg := p.rig
			var hold := func() -> void:
				rg.lock += 1
			p.get_tree().create_timer(0.3).timeout.connect(hold)
	tw.chain().tween_callback(freeze)
