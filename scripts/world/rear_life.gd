class_name RearLife
extends Node3D
## Sur içi artçı düzenin yakın planı: kameraya yakın (R) askerler çoklu ağ figüründen çıkıp gerçek, iskeletli askere
## dönüşür (kullanıcı: "hâlâ doğal durmuyor"). Uzakta figürler poz döngüsünde kalır; yakında hareket yumuşaktır:
## bölük komutla mızrak dürter (her adam kendi gecikmesiyle), kalkanlılar çöküp kalkar, okçu yayı gerip oku bırakır,
## işçi yükü omuzlayıp sur dibine yürür, bırakır, döner; aşçı kazanı karıştırır, oturanlar konuşur gibi kıpırdar,
## ayaktakiler etrafına bakınır, ağırlık değiştirir. Kişiler uzaklaşınca figür geri gelir.

const R := 46.0               # bu yarıçapın içindekiler canlanır
const R_OUT := 54.0           # bunun dışına çıkan figüre döner
const CAP := 22               # aynı anda en çok canlı asker
const PER_SCAN := 3           # bir taramada en çok kaç kişi kurulur (kurulum takılmasın)
const HIDDEN := Transform3D(Basis(Vector3(0.001, 0, 0), Vector3(0, 0.001, 0), Vector3(0, 0, 0.001)), Vector3(0, -200, 0))

static var enabled := true    # ölçüm ve testler kapatabilir

var field: SiegeField
var crew: PoseCrew
var spots: Array = []

var _live := {}               # spot dizini -> durum sözlüğü {"p": Person, ...}
var _cells := {}              # 32 m ızgara -> spot dizinleri
var _scan_t := 0.0
var _time := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 1453601
	for i in spots.size():
		var o: Vector3 = (spots[i]["xf"] as Transform3D).origin
		var k := Vector2i(floori(o.x / 32.0), floori(o.z / 32.0))
		if not _cells.has(k):
			_cells[k] = []
		(_cells[k] as Array).append(i)


func _process(delta: float) -> void:
	_time += delta
	_scan_t -= delta
	if _scan_t <= 0.0:
		_scan_t = 0.4
		_scan()
	for i: int in _live:
		_tick(i, _live[i], delta)


# ---------------------------------------------------------------- canlandırma / figüre dönüş

func _scan() -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null or not is_visible_in_tree() or not enabled:
		return
	var c := field.to_local(cam.global_position)
	# Yüksekten (dron, uçuş) bakılıyorsa kimse canlanmaz: figürler yeter, kurulum boşa gider
	if c.y - SiegeField.city_surf(c.x, c.z) > 30.0:
		for i: int in _live.keys():
			_release(i)
		return
	for i: int in _live.keys():
		var o: Vector3 = (spots[i]["xf"] as Transform3D).origin
		if Vector2(o.x - c.x, o.z - c.z).length() > R_OUT:
			_release(i)
	if _live.size() >= CAP:
		return
	var cand: Array = []
	var c0 := Vector2i(floori((c.x - R) / 32.0), floori((c.z - R) / 32.0))
	var c1 := Vector2i(floori((c.x + R) / 32.0), floori((c.z + R) / 32.0))
	for gx in range(c0.x, c1.x + 1):
		for gz in range(c0.y, c1.y + 1):
			for i: int in _cells.get(Vector2i(gx, gz), []):
				if _live.has(i):
					continue
				var o: Vector3 = (spots[i]["xf"] as Transform3D).origin
				var d := Vector2(o.x - c.x, o.z - c.z).length()
				if d < R:
					cand.append([d, i])
	cand.sort_custom(func(a, b): return float(a[0]) < float(b[0]))
	var made := 0
	for e: Array in cand:
		if _live.size() >= CAP or made >= PER_SCAN:
			break
		_wake(int(e[1]))
		made += 1


func _wake(i: int) -> void:
	var sp: Dictionary = spots[i]
	if str(sp["do"]) == "spar":
		_wake_spar(i)
		return
	var spec: Dictionary = sp["spec"]
	var coat: Color = spec.get("coat", Crowd.BYZ_COATS[0])
	var ci := maxi(Crowd.BYZ_COATS.find(coat), 0)
	var p := Person.new({"coat": coat, "pants": [Color("3a2a22"), Color("2a2a30"), Color("4a3a2a")][ci % 3], "hat": "helm",
		"beard": (i + ci) % 3 != 1, "mustache": (i + ci) % 2 == 0, "n": 900 + ci + (i % 7) * 13})
	p.set_meta("no_talk", true)
	p.set_meta("no_audit", true)          # dekor kalabalığı: bölüm denetimleri bunları saymaz
	add_child(p)
	var xf: Transform3D = sp["xf"]
	p.position = xf.origin
	p.rotation.y = xf.basis.get_euler().y
	var arm := str(spec.get("arm", ""))
	if arm != "":
		p.equip(arm, Crowd.BYZ_COATS[(ci + 2) % Crowd.BYZ_COATS.size()])
	var st := {"p": p, "home": xf.origin, "yaw": p.rotation.y, "t": _rng.randf_range(0.0, 3.0), "phase": "", "walk": null}
	match str(sp["do"]):
		"sit_ground", "stir", "hammer", "chop":
			p.set_activity(str(sp["do"]))
	# Figürü gizle (poz döngüsündeki ya da duran kalabalıktaki kopyaları)
	if sp.has("crew"):
		crew.suppress(int(sp["crew"]), true)
	for ref: Array in sp.get("still", []):
		var mmi := ref[0] as MultiMeshInstance3D
		if is_instance_valid(mmi):
			if not st.has("saved"):
				st["saved"] = []
			(st["saved"] as Array).append([mmi, int(ref[1]), mmi.multimesh.get_instance_transform(int(ref[1]))])
			mmi.multimesh.set_instance_transform(int(ref[1]), HIDDEN)
	_live[i] = st


func _release(i: int) -> void:
	var st: Dictionary = _live[i]
	var sp: Dictionary = spots[i]
	for dd in st.get("duels", []):
		if is_instance_valid(dd):
			(dd as Node).queue_free()
	for ci: int in sp.get("pair", []):
		crew.suppress(ci, false)
	if str(sp["do"]) == "spar":
		_live.erase(i)
		return
	var p := st["p"] as Person
	if is_instance_valid(st.get("walk")):
		(st["walk"] as Node).queue_free()
	if is_instance_valid(st.get("load")):
		(st["load"] as Node).queue_free()
	if is_instance_valid(p):
		p.queue_free()
	if sp.has("crew"):
		crew.suppress(int(sp["crew"]), false)
	for ref: Array in st.get("saved", []):
		var mmi := ref[0] as MultiMeshInstance3D
		if is_instance_valid(mmi):
			mmi.multimesh.set_instance_transform(int(ref[1]), ref[2])
	_live.erase(i)


# ---------------------------------------------------------------- davranışlar

func _tick(i: int, st: Dictionary, delta: float) -> void:
	if st.has("duels"):
		_leash(st, delta)
		return
	var p := st["p"] as Person
	if not is_instance_valid(p) or p.rig == null:
		return
	var sp: Dictionary = spots[i]
	match str(sp["do"]):
		"thrust":
			_drill_thrust(p, sp)
		"cover":
			_drill_cover(p, sp)
		"archer":
			_archer(i, p, st, delta)
		"pass":
			_hauler(p, sp, st, delta)
		"stand":
			_idle(p, st, delta)
		"instructor":
			_instructor(p, sp, st, delta)
		_:
			# Oturan, karıştıran, çekiçleyen: iş hareketini Rig kendisi oynatır; ara sıra başını çevirir
			_glance(p, st, delta)


## Bölük talimi: çavuşun komutuyla (bölüğün ortak saati) üç dört kez dürt, dur, nefes al. Herkes biraz geç kalır.
func _drill_thrust(p: Person, sp: Dictionary) -> void:
	var g := int(sp.get("group", 0))
	var beat := float(sp.get("beat", 4.2))
	var ph := fmod(_time + float(sp.get("off", float(g % 7) * 0.53)) - float(sp.get("lag", 0.0)), beat)
	var work := beat * 0.48          # kendi temposunda: bir süre soluklanır, sonra üç dört kez dürter
	var want := ""
	if ph > beat - work:
		want = "thrust_b" if fmod(ph - (beat - work), 0.55) < 0.24 else "thrust_a"
	elif ph > beat - work - 0.4:
		want = "thrust_a"           # hazır ol: mızrak yatar
	if p.rig.activity != want:
		p.rig.activity = want
	var sp_node := p.find_child("Spear", true, false) as Node3D
	if want != "":
		_spear_level(p, sp_node, 0.25 if want == "thrust_b" else -0.35)
	else:
		_spear_rest(sp_node)


## Kalkan talimi: "ok!" komutunda bölük kalkanın altına çöker, sonra kalkar
func _drill_cover(p: Person, sp: Dictionary) -> void:
	var g := int(sp.get("group", 0))
	var beat := float(sp.get("beat", 7.0)) * 1.4
	var ph := fmod(_time + float(sp.get("off", float(g % 5) * 0.91)) - float(sp.get("lag", 0.0)), beat)
	var want := "crouch" if ph > beat * 0.63 and ph < beat * 0.88 else ""
	if p.rig.activity != want:
		p.rig.activity = want


## Okçu: yayı ger, nişan al, bırak; ok hedefe uçar (PoseCrew'in ok uçuşu); sonra yeni ok çeker
func _archer(i: int, p: Person, st: Dictionary, delta: float) -> void:
	st["t"] = float(st["t"]) - delta
	if float(st["t"]) > 0.0:
		return
	if p.rig.activity == "aim":
		p.rig.activity = ""
		crew.loose(crew.man(int(spots[i]["crew"])))
		st["t"] = _rng.randf_range(2.2, 4.0)
	else:
		p.rig.activity = "aim"
		st["t"] = _rng.randf_range(1.1, 1.8)


## Yük taşıyan: yerinden yükü al (eğil, kaldır), omzunda sur dibine yürü, bırak, boş dön, biraz soluklan
func _hauler(p: Person, sp: Dictionary, st: Dictionary, delta: float) -> void:
	var walk = st.get("walk")
	if walk != null and is_instance_valid(walk):
		if st.has("load") and is_instance_valid(st["load"]):
			var ld := st["load"] as Node3D
			ld.global_position = p.global_position + Vector3(0, 1.62, 0) + p.global_basis.z * 0.05
			ld.global_rotation = p.global_rotation
		return
	st["t"] = float(st["t"]) - delta
	if float(st["t"]) > 0.0:
		return
	var drop: Vector3 = sp.get("drop", (st["home"] as Vector3) + Vector3(0, 0, 8.0))
	match str(st["phase"]):
		"":
			p.rig.activity = "lean_down"           # yükü yerden al
			st["phase"] = "lift"
			st["t"] = 0.9
		"lift":
			p.rig.activity = "throw_up"            # omuza
			if not is_instance_valid(st.get("load")):
				st["load"] = _load_mesh()
			st["phase"] = "go"
			st["t"] = 0.5
		"go":
			p.rig.activity = "carry"
			st["walk"] = _go(p, Vector3(drop.x, SiegeField.city_surf(drop.x, drop.z), drop.z), 1.05)
			st["phase"] = "drop"
			st["t"] = 0.0
		"drop":
			p.rig.activity = "lean_down"           # sur dibine bırak
			if is_instance_valid(st.get("load")):
				var ld := st["load"] as Node3D
				ld.global_position = p.global_position + p.global_basis.z * 0.6 + Vector3(0, 0.15, 0)
				var stay := ld
				get_tree().create_timer(6.0).timeout.connect(func():
					if is_instance_valid(stay):
						stay.queue_free())
				st.erase("load")
			st["phase"] = "back"
			st["t"] = 0.9
		"back":
			p.rig.activity = ""
			var h: Vector3 = st["home"]
			st["walk"] = _go(p, h, 1.25)
			st["phase"] = "rest"
			st["t"] = 0.0
		"rest":
			p.rotation.y = float(st["yaw"])
			st["phase"] = ""
			st["t"] = _rng.randf_range(1.5, 4.0)


func _go(p: Person, to: Vector3, speed: float) -> Walker:
	var w := Walker.go(p, field.to_global(to), speed)
	w.ground = true
	return w


## Tahta kılıçla talim eden çift: gerçek düello yapay zekâsı (yön, siper, karşılama), kan yok, can gitmez
## (TrainingYard.add_sparring_pair gibi). İki figür gizlenir, yerlerine iki Duelist gelir.
func _wake_spar(i: int) -> void:
	var sp: Dictionary = spots[i]
	var ends: Array = sp["ends"]
	var duels: Array = []
	for k in 2:
		var coat: Color = Crowd.BYZ_COATS[(i * 3 + k * 2) % Crowd.BYZ_COATS.size()]
		var look := {"coat": coat, "pants": [Color("3a2a22"), Color("2a2a30"), Color("4a3a2a")][(i + k) % 3], "hat": "helm" if (i + k) % 3 != 0 else "none",
			"beard": (i + k) % 2 == 0, "mustache": true, "n": 930 + (i * 2 + k) % 40}
		var dd := Duelist.new(look, "spathion", 0.5 + 0.1 * k, (i + k) % 2 == 0)
		dd.practice = true
		dd.max_hp = 99999.0
		dd.hp = dd.max_hp
		dd.damage = 0.0
		dd.set_meta("no_talk", true)
		dd.body.set_meta("no_audit", true)
		add_child(dd)
		dd.global_position = field.to_global(ends[k])
		dd.set_meta("home", dd.global_position)
		TrainingYard.woodify(dd.sword)
		duels.append(dd)
	(duels[0] as Duelist).target = duels[1]
	(duels[1] as Duelist).target = duels[0]
	for ci: int in sp.get("pair", []):
		crew.suppress(ci, true)
	_live[i] = {"duels": duels}


## Çift talim yerinden uzaklaşmasın (yan adımlarla kayıp gidiyorlardı; TrainingYard'daki gibi)
func _leash(st: Dictionary, delta: float) -> void:
	for dd in st["duels"]:
		var d := dd as Duelist
		if not is_instance_valid(d):
			continue
		var home: Vector3 = d.get_meta("home")
		var off := d.global_position - home
		off.y = 0.0
		if off.length() > 2.0:
			d.global_position -= off.normalized() * minf(off.length() - 2.0, delta * 2.0)


## Eğitmen: çiftlerin, kuklaların, öbeğin arasında dolaşır; yanına varınca durur, bakar, işaret eder ya da kollarını
## kavuşturup izler; sonra bir sonrakine geçer
func _instructor(p: Person, sp: Dictionary, st: Dictionary, delta: float) -> void:
	var walk = st.get("walk")
	if walk != null and is_instance_valid(walk):
		return
	var visit: Array = sp.get("visit", [])
	if visit.is_empty():
		_idle(p, st, delta)
		return
	var at: Vector3 = st.get("at", Vector3.INF)
	if at != Vector3.INF:
		p.rotation.y = lerp_angle(p.rotation.y, atan2(at.x - p.position.x, at.z - p.position.z), clampf(delta * 3.0, 0.0, 1.0))
	st["t"] = float(st["t"]) - delta
	if float(st["t"]) > 0.0:
		return
	if str(st["phase"]) == "walk":
		# Vardı: göster
		st["phase"] = "watch"
		p.emote(["point", "arms_cross", "nod", "point"][_rng.randi() % 4])
		st["t"] = _rng.randf_range(4.0, 8.0)
		return
	var tgt: Vector3 = visit[_rng.randi() % visit.size()]
	var a := _rng.randf() * TAU
	var stand := tgt + Vector3(cos(a), 0, sin(a)) * 3.0
	stand.y = SiegeField.city_surf(stand.x, stand.z)
	st["at"] = tgt
	st["walk"] = _go(p, stand, 1.0)
	st["phase"] = "walk"
	st["t"] = 0.3


## Ayakta bekleyen: bakınır, ağırlık değiştirir, ara sıra bir iki adım atıp yerine döner
func _idle(p: Person, st: Dictionary, delta: float) -> void:
	var walk = st.get("walk")
	if walk != null and is_instance_valid(walk):
		return
	st["t"] = float(st["t"]) - delta
	var want: float = st.get("look", float(st["yaw"]))
	p.rotation.y = lerp_angle(p.rotation.y, want, clampf(delta * 2.0, 0.0, 1.0))
	if float(st["t"]) > 0.0:
		return
	var r := _rng.randf()
	var home: Vector3 = st["home"]
	if r < 0.18 and p.position.distance_to(home) < 0.5:
		var a := _rng.randf() * TAU
		var to := home + Vector3(cos(a), 0, sin(a)) * _rng.randf_range(1.2, 2.4)
		to.y = SiegeField.city_surf(to.x, to.z)
		st["walk"] = _go(p, to, 0.8)
	elif r < 0.3 and p.position.distance_to(home) > 0.5:
		st["walk"] = _go(p, home, 0.8)
	else:
		st["look"] = float(st["yaw"]) + _rng.randf_range(-0.9, 0.9)
	st["t"] = _rng.randf_range(2.0, 5.0)


func _glance(p: Person, st: Dictionary, delta: float) -> void:
	st["t"] = float(st["t"]) - delta
	if float(st["t"]) <= 0.0:
		st["look"] = float(st["yaw"]) + _rng.randf_range(-0.35, 0.35)
		st["t"] = _rng.randf_range(3.0, 7.0)
	p.rotation.y = lerp_angle(p.rotation.y, float(st.get("look", st["yaw"])), clampf(delta * 1.5, 0.0, 1.0))


# ---------------------------------------------------------------- yardımcılar

## Talimde mızrak yatay, öne: el hizasından ileri; off ileri/geri kayma (SpearLoop'un dürtüşünün düz hali)
func _spear_level(p: Person, sp: Node3D, off: float) -> void:
	if sp == null:
		return
	if not sp.has_meta("rest"):
		sp.set_meta("rest", sp.transform)
	var b := p.global_basis.orthonormalized() * Basis(Vector3.RIGHT, 1.62)
	var hand := (sp.get_parent() as Node3D).global_transform * Vector3(0, -0.28, 0.06)
	sp.global_transform = Transform3D(b, hand + b.y * off)


func _spear_rest(sp: Node3D) -> void:
	if sp and sp.has_meta("rest"):
		sp.transform = sp.get_meta("rest")
		sp.remove_meta("rest")


## Omuzdaki yük: çuval ya da ok demeti
func _load_mesh() -> Node3D:
	var n := Node3D.new()
	add_child(n)
	if _rng.randf() < 0.5:
		Props.ball(n, 0.28, Vector3.ZERO, Color("b8a27a"), Vector3(1.4, 0.8, 1.0), 8)
	else:
		Props.cyl(n, 0.16, 0.9, Vector3.ZERO, Color("8a6a40"), Vector3(0, 0, 90), 8)
		Props.cyl(n, 0.17, 0.08, Vector3.ZERO, Color("5a4630"), Vector3(0, 0, 90), 8)
	return n
