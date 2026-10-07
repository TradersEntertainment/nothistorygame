class_name WallFight
extends Node3D
## Bizans surunda savaşın hikâyedeki işleri (LandWalls düzeni: dış sur z 14–16, yürüyüş yolu y 8, gedik x=0):
##   · kaynar yağ kazanları: dış surun yürüyüş yolunda, altında ateş; başında biri karıştırır, biri kaldıraçla devirir.
##     Dökülen yağ sur dibine iner, buhar ve duman kalkar; altındaki saldıranlar tutuşur.
##   · yanan saldıranlar: alev alan asker çırpınarak geri kaçar, düşer, alevi söner.
##   · onarım ekibi: depo ile gedik arasında sepetle toprak, fıçı, kalas taşıyanlar; gedikte kazık çakanlar ve taş
##     dizenler (Bölüm 20'de Tolga da bu ekiptedir).
## Bütün kişiler canlı karakterdir (Person / Soldier). Kök "garrison" grubundadır: fetihte kaldırılır.

var cauldrons: Array = []        # {node, pot, stream, pos, t}
var burning: Array = []          # {node, flames, light, t, dir}
var crew: Array = []             # {node, a, b, t, speed}
var rng := RandomNumberGenerator.new()
var _t := 0.0


func _ready() -> void:
	add_to_group("garrison")
	add_to_group("sight_dodgers")
	rng.seed = 5320


# ---------------------------------------------------------------- kaynar yağ

## Yürüyüş yolunda kazan (pos: kazanın yeri, y = yol). Dökülen yağ +Z yönünde sur dibine iner.
func add_cauldron(pos: Vector3, seed := 0) -> Dictionary:
	var c := Node3D.new()
	c.position = pos
	add_child(c)
	# Taş ocak, içinde kor ve alev
	for k in 6:
		var a := TAU * k / 6.0
		Props.ball(c, 0.16, Vector3(cos(a) * 0.5, 0.1, sin(a) * 0.5), Color("5a5550"), Vector3(1, 0.7, 1), 6)
	var fl := Props.cyl(c, 0.3, 0.45, Vector3(0, 0.28, 0), Color("ff9a30"), Vector3.ZERO, 6, 0.0)
	fl.material_override = Props.mat(Color("ff9a30"), 3.0, false, "", false)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 0.6, 0)
	light.light_color = Color("ff8a3a")
	light.light_energy = 1.6
	light.omni_range = 6.0
	c.add_child(light)
	# Demir sehpa ve devrilebilen kazan (pivot: ön kulplar, sur tarafı)
	for sx: float in [-0.6, 0.6]:
		Props.cyl(c, 0.04, 1.2, Vector3(sx, 0.6, 0.35), Color("3a3a40"), Vector3.ZERO, 5)
	Props.cyl(c, 0.03, 1.3, Vector3(0, 1.15, 0.35), Color("3a3a40"), Vector3(0, 0, 90), 5)
	var pivot := Node3D.new()
	pivot.position = Vector3(0, 1.1, 0.35)
	c.add_child(pivot)
	var pot := Node3D.new()
	pot.position = Vector3(0, -0.35, -0.35)
	pivot.add_child(pot)
	Props.cyl(pot, 0.42, 0.6, Vector3.ZERO, Color("2e2c2a"), Vector3.ZERO, 12, 0.34)
	Props.cyl(pot, 0.43, 0.05, Vector3(0, 0.3, 0), Color("4a4846"), Vector3.ZERO, 12)
	var oil := Props.cyl(pot, 0.39, 0.02, Vector3(0, 0.28, 0), Color("c88a2a"), Vector3.ZERO, 12)
	oil.material_override = Props.mat(Color("d89a3a"), 1.2, false, "", false)
	Props.cyl(pot, 0.03, 1.1, Vector3(0, 0.35, -0.75), Color("5a3e26"), Vector3(-70, 0, 0), 5)   # devirme kolu
	var steam := Vfx.steam(c, Vector3(0, 1.5, 0))
	# Başında iki adam: biri kazanı karıştırır, biri devirme kolunda bekler
	var stir := Garrison.man(c, Vector3(-0.85, 0, -0.3), PI * 0.4, seed + 1, "", "stir")
	var lever := Garrison.man(c, Vector3(0.8, 0, -0.45), -PI * 0.25, seed + 2, "")
	var d := {"node": c, "pivot": pivot, "pos": pos, "t": -1.0, "light": light, "men": [stir, lever], "steam": steam}
	cauldrons.append(d)
	return d


## Kazanı devirir: yağ sur dibine (hedef) iner; hedefin çevresindeki saldıranlar tutuşur. Süreyi döndürür.
func pour(d: Dictionary, target: Vector3, burn_count := 2) -> float:
	if float(d["t"]) >= 0.0:
		return 0.0
	d["t"] = 0.0
	var pivot: Node3D = d["pivot"]
	var tw := create_tween()
	tw.tween_property(pivot, "rotation:x", deg_to_rad(75.0), 0.55).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.4)
	tw.tween_property(pivot, "rotation:x", 0.0, 1.0)
	tw.tween_callback(func(): d["t"] = -1.0)
	# Devirme kolundaki adam iki koluyla kolu aşağı bastırır
	var lever: Person = (d["men"] as Array)[1]
	if is_instance_valid(lever) and lever.rig:
		lever.rig.lock += 1
		var lt := create_tween().set_parallel(true)
		lt.tween_property(lever.rig.arm_l, "rotation", Vector3(-1.2, 0, -0.2), 0.3)
		lt.tween_property(lever.rig.arm_r, "rotation", Vector3(-1.2, 0, 0.2), 0.3)
		lt.chain().tween_interval(1.6)
		lt.chain().tween_callback(func():
			if is_instance_valid(lever):
				lever.rig.lock = maxi(lever.rig.lock - 1, 0))
	# Yağ şeridi: kazanın ağzından sur dibine
	# Kazanın ağzı: kazan düğümünün önü (+Z yerel; Haliç surunda kazan denize döndürülür)
	var from: Vector3 = (d["node"] as Node3D).to_global(Vector3(0, 1.2, 0.9))
	var to := target
	var stream := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.16
	cm.bottom_radius = 0.34
	cm.height = 1.0
	stream.mesh = cm
	stream.material_override = Props.mat(Color("d8922a"), 1.6, false, "", false)
	add_child(stream)
	var mid := (from + to) * 0.5
	var up := (from - to).normalized()
	var side := up.cross(Vector3.RIGHT).normalized() if absf(up.dot(Vector3.RIGHT)) < 0.9 else up.cross(Vector3.FORWARD).normalized()
	stream.global_transform = Transform3D(Basis(side.cross(up), up, side).scaled(Vector3(1, from.distance_to(to), 1)), mid)
	stream.scale = Vector3(0.05, from.distance_to(to), 0.05)
	var st := create_tween()
	st.tween_interval(0.35)
	st.tween_property(stream, "scale", Vector3(1, from.distance_to(to), 1), 0.2)
	st.tween_interval(1.1)
	st.tween_property(stream, "scale", Vector3(0.05, from.distance_to(to), 0.05), 0.35)
	st.tween_callback(stream.queue_free)
	get_tree().create_timer(0.55).timeout.connect(func():
		if not is_inside_tree():
			return
		Audio.sfx("splash", -6.0, 0.7)
		Audio.sfx("fuse_burn", -8.0, 0.6)
		Vfx.dust(self, to + Vector3(0, 0.4, 0), 1.4)
		Vfx.smolder(self, to, 1.2, true)
		# Surdan dışarı: kazandan dökülen yere doğru (kara surlarında +Z, Haliç surunda kazan denize döner: -Z)
		var c := (d["node"] as Node3D).global_position
		var away := Vector3(to.x - c.x, 0.0, to.z - c.z)
		away = away.normalized() if away.length() > 0.1 else Vector3(0, 0, 1)
		var lat := away.cross(Vector3.UP)
		for k in burn_count:
			var at := _burn_spot(to, lat, away)
			if at.is_finite():
				burn(at, Color(0, 0, 0, 0), away))
	return 2.9


# ---------------------------------------------------------------- yanan saldıranlar

## Yağın döküldüğü yerde yananın doğacağı boş nokta: korkuluğun, sur dibinin içinde ve bir başkasının (ötekinin de yanan)
## üstünde değil. Eskiden rastgele yerde doğup korkuluk taşının içinde ya da yanındakinin içinde duruyordu (VISAUDIT).
func _burn_spot(to: Vector3, lat: Vector3, away: Vector3) -> Vector3:
	for i in 12:
		var p := to + lat * rng.randf_range(-1.6, 1.6) + away * rng.randf_range(-0.4, 1.2)
		var fy := Unclip.floor_y(self, p, 1.0, 1.6)
		if is_nan(fy):
			continue          # altında zemin yok (suya, gemi bordasının dışına): orada yanan adam doğmaz
		p.y = fy
		if not Unclip.in_solid(self, p, 0.2) and not _taken(p):
			return p
	return Vector3.INF      # boş yer yok: bu döküşte yanan çıkmaz


func _taken(p: Vector3) -> bool:
	for g: String in ["persons", "soldiers"]:
		for n in get_tree().get_nodes_in_group(g):
			var o := n as Node3D
			if o and o.is_visible_in_tree() and absf(o.global_position.y - p.y) < 0.9 \
					and Vector2(o.global_position.x - p.x, o.global_position.z - p.z).length() < 0.7:
				return true
	return false


## Yanan saldıran: gerçek asker modeli; alevler içinde çırpınarak sur dibinden geri (away: surdan dışarı; kara surlarında
## +Z) kaçar, düşer, alev söner. v0.91: yön hep +Z'ydi; Haliç surunda (38o) adam surun içine koşuyordu (WALKTHRU).
func burn(pos: Vector3, coat := Color(0, 0, 0, 0), away := Vector3(0, 0, 1)) -> Soldier:
	var c: Color = coat if coat.a > 0.0 else Crowd.OTT_COATS[rng.randi() % Crowd.OTT_COATS.size()]
	var s := Soldier.new(c, "stand", "bork" if rng.randf() < 0.6 else "turban")
	s.set_meta("no_talk", true)
	# Alevler içinde iki saniyelik kaçış: korkuluğu, birbirini sıyırarak geçerler; kalabalık denetimi saymaz (yine de doğduğu
	# yer boş seçilir, kaçarken katıya girmez, birbirinden uzaklaşır: _burn_spot, _update_burning)
	s.set_meta("no_audit", true)
	# Başka birinin (öteki yananın) üstünde doğmasın: yana kayar
	for i in 6:
		if not is_inside_tree() or not _taken(global_transform * pos):
			break
		pos += Vector3(rng.randf_range(-0.9, 0.9), 0, rng.randf_range(-0.9, 0.9))
	s.position = pos
	s.rotation.y = rng.randf_range(-0.6, 0.6)
	add_child(s)
	# Döküldüğü yerin görünen zeminine basar (hedef noktası sur dibinin 0,4 m üstündeydi: ilk karelerde havada doğuyordu)
	var fy := Unclip.floor_y(s, s.global_position, 1.0, 1.6)
	if not is_nan(fy):
		s.global_position.y = fy
	var flames: Array = []
	for k in 5:
		var f := Props.cyl(s, rng.randf_range(0.14, 0.26), rng.randf_range(0.5, 0.9), Vector3(rng.randf_range(-0.2, 0.2), 0.6 + k * 0.28, rng.randf_range(-0.15, 0.15)),
			Color("ffa030"), Vector3.ZERO, 6, 0.0)
		f.material_override = Props.mat(Color("ffa030") if k % 2 == 0 else Color("ffd060"), 3.5, false, "", false)
		flames.append(f)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 1.2, 0)
	light.light_color = Color("ff8a30")
	light.light_energy = 2.4
	light.omni_range = 7.0
	s.add_child(light)
	burning.append({"node": s, "flames": flames, "light": light, "t": 0.0,
		"dir": (away + away.cross(Vector3.UP) * rng.randf_range(-0.4, 0.4)).normalized(), "speed": rng.randf_range(2.4, 3.6)})
	Audio.sfx("crowd_gasp", -14.0, rng.randf_range(0.8, 1.2))
	return s


## Kaçanın önünde (gövde hizasında) sur ya da kule varsa yüzü boyunca kayar, yönü de öyle kalır: yön surdan dışarı ama
## yanlara savrulur; 26o'da kazanın yanındaki kulenin yan yüzüne koşup içinden geçiyordu (CI'da WALKTHRU).
func _slide(s: Node3D, b: Dictionary, step: Vector3) -> Vector3:
	if step.length() < 0.0001:
		return step
	# Diz ve göğüs hizasında: alçak korkuluk (38o güvertesinin parmaklığı) tek ışının altında kalıyordu
	var h := {}
	for hy: float in [0.7, 1.3]:
		var a := s.global_position + Vector3(0, hy, 0)
		var q := PhysicsRayQueryParameters3D.create(a, a + step + step.normalized() * 0.35, 1)
		h = s.get_world_3d().direct_space_state.intersect_ray(q)
		if not h.is_empty() and h["collider"] is StaticBody3D and Unclip.visible_body(h["collider"]):
			break
		h = {}
	if h.is_empty():
		return step
	var n: Vector3 = h["normal"]
	n.y = 0.0
	if n.length() < 0.1:
		return step
	n = n.normalized()
	var along := step - n * step.dot(n)
	if along.length() < step.length() * 0.2:
		along = step - n * step.dot(n) * 2.0      # tam karşıdan: geri döner
	b["dir"] = along.normalized()
	return along


func _update_burning(delta: float) -> void:
	for b: Dictionary in burning.duplicate():
		var s: Soldier = b["node"]
		if not is_instance_valid(s):
			burning.erase(b)
			continue
		b["t"] = float(b["t"]) + delta
		var t: float = b["t"]
		for f: Node3D in b["flames"]:
			if is_instance_valid(f):
				f.scale = Vector3.ONE * (0.8 + absf(sin(_t * 14.0 + f.position.y * 5.0)) * 0.5) * clampf(1.0 - (t - 3.2) / 2.0, 0.0, 1.0)
		(b["light"] as OmniLight3D).light_energy = 2.4 * clampf(1.0 - (t - 3.2) / 2.0, 0.0, 1.0) * (0.8 + randf() * 0.4)
		if t < 2.2:
			# Kaçar: kollar havada, yalpalar; zemini izler (hendeğe iner, korkuluğun üstünden atlar)
			var cur := s.global_position.y
			var was := s.position
			s.position += _slide(s, b, (b["dir"] as Vector3) * float(b["speed"]) * delta)
			# Korkuluğun, kulenin içine girmez: adımı geri alır, yönü yana kırar (ışınlar dizin üstünde kalan alçak
			# taşları kaçırıyordu)
			if Unclip.in_solid(s, s.global_position, 0.15) and not Unclip.in_solid(s, global_transform * was, 0.15):
				s.position = was
				b["dir"] = (b["dir"] as Vector3).rotated(Vector3.UP, PI * 0.5 * (1.0 if rng.randf() < 0.5 else -1.0))
			# Sur dibinden hendeğe atlarken duvarın yüzüne sürtünüyordu: yüzden biraz açılır; açılamazsa geri durur
			for k in 3:
				if not Unclip.in_solid(s, s.global_position, 0.16):
					break
				s.position += (b["dir"] as Vector3) * 0.1
			if Unclip.in_solid(s, s.global_position, 0.16):
				s.position = was
			# Öteki yananla aynı yere koşmasın: yakınındaysa ondan uzağa döner
			for o: Dictionary in burning:
				var on: Node3D = o["node"]
				if o == b or not is_instance_valid(on):
					continue
				var d := s.position - on.position
				d.y = 0.0
				if d.length() < 0.7:
					s.position = was
					b["dir"] = (d.normalized() if d.length() > 0.01 else (b["dir"] as Vector3).rotated(Vector3.UP, 1.2))
					break
			var gp := s.global_position
			var gy := Assault.ground_y(gp.x, gp.z)
			# Görünen zemine basar (hendeğin kenarında ground_y eğrisi görünen dikey düşüşün üstünde havada kalıyordu); önce
			# bulunduğu yükseklikten aranır: gemi güvertesinde (38o) ground_y deniz düzeyidir, adam güverteye gömülüyordu
			var fy := Unclip.floor_y(s, Vector3(gp.x, maxf(cur, gy), gp.z), 1.0, 1.6)
			if is_nan(fy):
				fy = Unclip.floor_y(s, Vector3(gp.x, gy, gp.z), 1.0, 1.6)
			s.global_position.y = gy if is_nan(fy) else fy
			s.rotation.z = sin(t * 11.0) * 0.18
			if s.rig:
				s.rig.lock = 1
				s.rig.arm_l.rotation.x = -2.4 + sin(t * 16.0) * 0.5
				s.rig.arm_r.rotation.x = -2.4 + cos(t * 15.0) * 0.5
		elif t < 2.8:
			# Yüzüstü düşer
			s.rotation.x = lerpf(s.rotation.x, 1.45, clampf(delta * 6.0, 0.0, 1.0))
			var gy := Assault.ground_y(s.global_position.x, s.global_position.z)
			var fy := Unclip.floor_y(s, Vector3(s.global_position.x, gy, s.global_position.z), 1.0, 1.6)
			# Düştüğü görünen zemin: yüzüstü yatan gövdenin kökü zeminin 0,15 üstündedir; düşmeye başlarken (henüz dik)
			# ayaklar zemindedir (eskiden baştan 0,15 yukarı çekiliyordu: hendek dibinde havada başlıyordu)
			gy = (gy if is_nan(fy) else fy) + 0.15 * clampf(s.rotation.x / 1.45, 0.0, 1.0)
			# Yüksekteki zemine (korkuluk, basamak) hemen basar, alçaktakine yavaşça iner (yere gömülmesin)
			s.global_position.y = gy if gy > s.global_position.y else lerpf(s.global_position.y, gy, clampf(delta * 6.0, 0.0, 1.0))
		elif t > 9.0:
			burning.erase(b)
			s.queue_free()


# ---------------------------------------------------------------- onarım ekibi

## Depo (a) ile gedik (b) arasında taşıyanlar: sepetle toprak, fıçı, kalas. n kişi, yan yana şeritlerde.
func add_carriers(a: Vector3, b: Vector3, n: int, seed := 0) -> void:
	var kinds := ["earth", "barrel", "plank", "earth", "earth", "barrel"]
	for i in n:
		var p := Person.new({"coat": [Color("6a5040"), Color("5a6a7a"), Color("7a4a3a"), Color("4a4a3a"), Color("6a5a48")][i % 5],
			"pants": Color("3a3028"), "hat": "helm" if i % 3 == 0 else "none", "mustache": i % 2 == 0, "beard": i % 3 == 1,
			"hair": [Color("3a2a1e"), Color("5a4a3a")][i % 2], "n": seed + i})
		p.set_meta("no_talk", true)
		p.set_meta("garrison", true)
		add_child(p)
		p.carry(kinds[i % kinds.size()])
		# Her taşıyıcının kendi şeridi, hepsi aynı hızda: birbirinin içinden geçmez
		var off := Vector3((i - (n - 1) * 0.5) * 1.3, 0, 0)
		crew.append({"node": p, "a": a + off, "b": b + off * 0.8, "t": float(i) / n, "speed": 0.048})
		p.position = _crew_pos(crew[-1], float(i) / n)      # ilk karede şeridinde (başlangıçta hepsi aynı noktada durmasın)


## Şeritteki bir taşıyıcının yerine bölüme özel biri geçer (20'de dost Niko): şeridi ve evresi aynı kalır.
func swap_carrier(i: int, p: Person, kind := "barrel") -> Person:
	if i < 0 or i >= crew.size():
		return null
	var c: Dictionary = crew[i]
	var old: Node3D = c["node"]
	p.set_meta("no_talk", true)
	p.set_meta("garrison", true)
	add_child(p)
	p.position = old.position
	p.visible = old.visible
	p.carry(kind)
	old.queue_free()
	c["node"] = p
	return p


## Gedikte çalışanlar: kazık çakanlar ve taş dizenler (yerinde; iş hareketi).
func add_builders(site: Vector3, n: int, seed := 0) -> void:
	for i in n:
		var p := Person.new({"coat": [Color("5a4a3a"), Color("6a5a48"), Color("4a3a2e")][i % 3], "pants": Color("3a3028"),
			"hat": "none", "mustache": true, "beard": i % 2 == 0, "apron": Color("5a4a36"), "n": seed + 40 + i})
		p.set_meta("no_talk", true)
		p.set_meta("garrison", true)
		var x := (-1.0 if i % 2 == 0 else 1.0) * (2.4 + (i / 2) * 1.2)
		p.position = site + Vector3(x, 0, -0.6 - (i / 2) * 0.5)
		p.position.y = LandWalls.rubble_y(p.position.x, p.position.z)
		p.rotation.y = -signf(x) * 0.5
		add_child(p)
		p.set_activity(["hammer", "chop"][i % 2])


## Onarım ekibini gösterir / gizler (giriş konuşmasında kameranın önünden geçmesinler; iş başlayınca çıkarlar).
func set_crew_active(on: bool) -> void:
	for c: Dictionary in crew:
		var p: Node3D = c["node"]
		if is_instance_valid(p):
			p.visible = on


## Şeritteki yeri (evre 0..1: gidiş, dönüş).
func _crew_pos(c: Dictionary, ph: float) -> Vector3:
	var k := smoothstep(0.0, 0.45, ph) if ph < 0.5 else 1.0 - smoothstep(0.55, 1.0, ph)
	var p := (c["a"] as Vector3).lerp(c["b"], k)
	p.y = LandWalls.rubble_y(p.x, p.z)
	return p


func _gap(hud: Node, c: Dictionary, ph: float) -> float:
	# Yana çekilmiş (off) yeriyle: şeridin çizgisi açık olsa da kendisi çizgide durabilir
	return hud.sightline_gap(global_transform * (_crew_pos(c, ph) + (c.get("off", Vector3.ZERO) as Vector3))) if hud else INF


## Replik başladı (Hud): oyuncuyla konuşanın arasındaki taşıyıcı çizginin dışına geçer (evresini ilerletir),
## ötekiler replik bitene dek çizgiye girmeden bekler (_update_crew).
func dodge(_eye: Vector3, _head: Vector3, _speaker: Node3D) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	for c: Dictionary in crew:
		var p: Node3D = c["node"]
		if not is_instance_valid(p) or not p.visible:
			continue
		var ph: float = c["t"]
		var n := 0
		var off0: Vector3 = c.get("off", Vector3.ZERO)
		# Çizgiden çıktığı yer başka bir taşıyıcının (ayakta birinin) içi de olmasın (eskiden öbür şeritteki
		# taşıyıcının üstüne konabiliyordu)
		while (_gap(hud, c, ph) < 1.0 or (n > 0 and Unclip.crowded(p, global_transform * (_crew_pos(c, ph) + off0), 0.45))) and n < 100:
			ph = fmod(ph + 0.01, 1.0)
			n += 1
		if n >= 100:
			# Her yer dolu: hiç değilse konuşmanın görüş çizgisinden çıkar
			ph = c["t"]
			n = 0
			while _gap(hud, c, ph) < 1.0 and n < 100:
				ph = fmod(ph + 0.01, 1.0)
				n += 1
		if n > 0:
			c["t"] = ph
			# Yana çekilmiş yeriyle (off): _gap onu ölçtü; eskiden şeridin çizgisine konup görüşün önünde kalıyordu
			var at := _crew_pos(c, ph) + (c.get("off", Vector3.ZERO) as Vector3)
			at.y = LandWalls.rubble_y(at.x, at.z)
			p.position = at


func _update_crew(delta: float) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	for c: Dictionary in crew:
		var p: Person = c["node"]
		if not is_instance_valid(p) or not p.visible:
			continue
		var t_old: float = c["t"]
		var nt := fmod(float(c["t"]) + delta * float(c["speed"]), 1.0)
		if _gap(hud, c, c["t"]) < 1.0:
			# Konuşmanın görüş çizgisinde kalmış (replik başlarken görünmüyordu ya da yolu kapalıydı): hızla çizgiden çıkar
			nt = fmod(float(c["t"]) + delta * float(c["speed"]) * 6.0, 1.0)
		elif _gap(hud, c, nt) < 1.0:
			nt = c["t"]      # konuşmanın önünden geçmez: bekler
		c["t"] = nt
		var ph: float = c["t"]
		var a: Vector3 = c["a"]
		var b: Vector3 = c["b"]
		# Biri (yaralı taşıyanlar, komutan, düellocu, ekipten bir başkası) yakından geçerse yana çekilir, sonra şeridine
		# döner. Yana çekildiği yer bir katının (ok sandığı, siper) içiyse oraya girmez.
		var base := _crew_pos(c, ph)
		var off: Vector3 = c.get("off", Vector3.ZERO)
		var gb := global_transform * base
		var push := Unclip.push(p, gb + off, 1.0)
		push.y = 0.0
		if push != Vector3.ZERO:
			var want := (off + push * delta * 4.0).limit_length(1.1)
			# ...ve yandaki şeridin taşıyıcısının içine de girmez (22'de depo önünde ikisi iç içe kalıyordu)
			if not Unclip.in_solid(self, global_transform * (base + want)) and not Unclip.crowded(p, global_transform * (base + want), 0.45):
				off = want
		else:
			off = off.lerp(Vector3.ZERO, clampf(delta * 1.5, 0.0, 1.0))
		c["off"] = off
		base += off
		base.y = LandWalls.rubble_y(base.x, base.z)
		# Görünen zemin (moloz yamacı, set): hesaplanan yükseklik onunla uyuşmazsa ona basar (gömülmez, havada kalmaz)
		var fy := Unclip.floor_y(self, global_transform * base, 0.9, 0.9)
		if not is_nan(fy):
			base.y = fy - global_position.y
		# Son denetim: yeni yer ayakta birinin (öbür taşıyıcı, düellocu, savunan) içindeyse o kare ilerlemez, bekler
		if p.is_inside_tree() and Unclip.blocks_step(p, p.global_position, global_transform * base, 0.5):
			c["t"] = t_old
			continue
		p.position = base
		var dir := (b - a) if ph < 0.5 else (a - b)
		p.rotation.y = lerp_angle(p.rotation.y, atan2(dir.x, dir.z), clampf(delta * 6.0, 0.0, 1.0))


func _process(delta: float) -> void:
	_t += delta
	_update_burning(delta)
	_update_crew(delta)
	for d: Dictionary in cauldrons:
		var l: OmniLight3D = d["light"]
		l.light_energy = 1.4 + sin(_t * 9.0 + l.position.x) * 0.25 + randf() * 0.15


## Önizleme / test: bütün kazanlar birlikte döker.
func demo_pour() -> void:
	for d: Dictionary in cauldrons:
		pour(d, Vector3((d["pos"] as Vector3).x, 0.0, 18.0), 3)
