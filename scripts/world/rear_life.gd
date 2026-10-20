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
var hot := false              # kuşatma sürüyor: Osmanlı okları gelir, kızgın yağ dökülür
var oil: Array = []           # WallRear.oil_nodes: {"node", "pivot"}

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
	if hot and enabled:
		_volley(delta)
	_fly(delta)
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
		_pc(sp).suppress(int(sp["crew"]), true)
	for ref: Array in sp.get("still", []):
		var mmi := ref[0] as MultiMeshInstance3D
		if is_instance_valid(mmi):
			if not st.has("saved"):
				st["saved"] = []
			(st["saved"] as Array).append([mmi, int(ref[1]), mmi.multimesh.get_instance_transform(int(ref[1]))])
			mmi.multimesh.set_instance_transform(int(ref[1]), HIDDEN)
			# Uzak kıpırtı (FarSway) gizleneni yeniden yerine koymasın
			var hid: Dictionary = mmi.get_meta("hidden", {})
			hid[int(ref[1])] = true
			mmi.set_meta("hidden", hid)
	match str(sp["do"]):
		"wall_archer", "wall_bow", "wall_watch":
			p.rotation.y = xf.basis.get_euler().y
		"oil_carrier":
			st["leg"] = 0
			st["phase"] = "pick"
		"lean_down":
			p.set_activity("")
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
		_pc(sp).suppress(int(sp["crew"]), false)
	for ref: Array in st.get("saved", []):
		var mmi := ref[0] as MultiMeshInstance3D
		if is_instance_valid(mmi):
			mmi.multimesh.set_instance_transform(int(ref[1]), ref[2])
			var hid: Dictionary = mmi.get_meta("hidden", {})
			hid.erase(int(ref[1]))
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
		"wall_archer":
			if not _duck(p, st, delta):
				_archer(i, p, st, delta)
		"wall_bow":
			if not _duck(p, st, delta):
				_wall_bow(p, st, delta)
		"wall_watch":
			if not _duck(p, st, delta):
				_wall_watch(p, st, delta)
		"oil_lever":
			_oil_lever(p, sp, st, delta)
		"oil_carrier":
			_oil_carrier(p, sp, st, delta)
		"lean_down":
			_feeder(p, st, delta)
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
		var pc := _pc(spots[i])
		pc.loose(pc.man(int(spots[i]["crew"])))
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


# ---------------------------------------------------------------- sur üstü

func _pc(sp: Dictionary) -> PoseCrew:
	return sp.get("pc", crew)


## Yakına ok düştü: siperin ardına çök (bir an), sonra kalk
func _duck(p: Person, st: Dictionary, delta: float) -> bool:
	if float(st.get("duck", 0.0)) <= 0.0:
		return false
	st["duck"] = float(st["duck"]) - delta
	if p.rig.activity != "crouch":
		p.rig.activity = "crouch"
	if float(st["duck"]) <= 0.0:
		p.rig.activity = ""
	return true


## Surda bekleyen: ovaya bakar; ara sıra mazgaldan aşağı eğilip bakar, sağa sola bakınır
func _wall_watch(p: Person, st: Dictionary, delta: float) -> void:
	st["t"] = float(st["t"]) - delta
	var want: float = st.get("look", float(st["yaw"]))
	p.rotation.y = lerp_angle(p.rotation.y, want, clampf(delta * 2.0, 0.0, 1.0))
	if float(st["t"]) > 0.0:
		return
	if p.rig.activity == "lean_down":
		p.rig.activity = ""
		st["t"] = _rng.randf_range(2.5, 6.0)
		return
	if _rng.randf() < 0.4:
		p.rig.activity = "lean_down"
		st["look"] = float(st["yaw"])
		st["t"] = _rng.randf_range(1.2, 2.4)
	else:
		st["look"] = float(st["yaw"]) + _rng.randf_range(-0.7, 0.7)
		st["t"] = _rng.randf_range(2.0, 4.5)


## Duran figürden canlanan okçu: gerer, nişan alır, bırakır (ok ovaya uçar), yeni ok çeker
func _wall_bow(p: Person, st: Dictionary, delta: float) -> void:
	st["t"] = float(st["t"]) - delta
	if float(st["t"]) > 0.0:
		return
	if p.rig.activity == "aim":
		p.rig.activity = ""
		var fwd := p.global_basis.z
		fwd.y = 0.0
		var from := p.global_position + Vector3(0, 1.45, 0) + fwd.normalized() * 0.5
		var to := p.global_position + fwd.normalized() * _rng.randf_range(32.0, 60.0) + fwd.normalized().cross(Vector3.UP) * _rng.randf_range(-4.0, 4.0)
		to.y = field.to_global(Vector3(0, 0, 0)).y
		_arrow(from, to, _rng.randf_range(1.6, 2.1), true)
		st["t"] = _rng.randf_range(2.4, 4.5)
	else:
		p.rig.activity = "aim"
		st["t"] = _rng.randf_range(1.0, 1.7)


## Osmanlı okları: kuşatma günleri ovadan sura ara ara ok yağar (kameranın yakınına). Çoğu mazgallara, yürüyüş
## yoluna saplanır, kimi iki sur arasına düşer; yakınındaki savunan siperin ardına çöker.
var _volley_t := 2.0
var _flying: Array = []       # [ok, hız, kalan süre, saplanacağı y, saplandı mı]

func _volley(delta: float) -> void:
	_volley_t -= delta
	if _volley_t > 0.0:
		return
	_volley_t = _rng.randf_range(1.2, 3.6)
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var c := field.to_local(cam.global_position)
	if c.z < -70.0 or c.z > 90.0 or absf(c.y) > 40.0:
		return
	for k in (1 if _rng.randf() < 0.7 else _rng.randi_range(3, 6)):
		var tx := c.x + _rng.randf_range(-26.0, 26.0)
		var r := _rng.randf()
		var to: Vector3
		if r < 0.45:
			to = Vector3(tx, 8.0 + _rng.randf_range(0.0, 0.05), _rng.randf_range(14.3, 15.5))       # yürüyüş yolu
		elif r < 0.75:
			to = Vector3(tx, 8.3 + _rng.randf_range(0.0, 0.7), 15.42)                            # mazgal taşının yüzü
		else:
			to = Vector3(tx, -0.02, _rng.randf_range(3.0, 12.5))                                  # iki sur arası
		var from := Vector3(tx + _rng.randf_range(-12.0, 12.0), 1.6, _rng.randf_range(80.0, 105.0))
		_arrow(field.to_global(from), field.to_global(to), _rng.randf_range(2.1, 2.7), false, k * 0.12)


func _arrow(from: Vector3, to: Vector3, t: float, outgoing: bool, delay := 0.0) -> void:
	if _flying.size() >= 40:
		var old: Array = _flying.pop_front()
		if is_instance_valid(old[0]):
			(old[0] as Node).queue_free()
	var mi := MeshInstance3D.new()
	mi.mesh = Assault.arrow_mesh()
	mi.material_override = Crowd.material()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	mi.global_position = from
	mi.visible = delay <= 0.0
	var v := (to - from) / t
	v.y = (to.y - from.y + 0.5 * 9.8 * t * t) / t
	_flying.append([mi, v, 9.0 + t, to.y, false, outgoing, delay, to])
	var cam := get_viewport().get_camera_3d()
	if cam and cam.global_position.distance_to(from) < 14.0 and outgoing:
		Audio.sfx("whoosh_fly", -18.0, _rng.randf_range(1.2, 1.5))


func _fly(delta: float) -> void:
	for k in range(_flying.size() - 1, -1, -1):
		var a: Array = _flying[k]
		var n := a[0] as Node3D
		if not is_instance_valid(n):
			_flying.remove_at(k)
			continue
		if float(a[6]) > 0.0:
			a[6] = float(a[6]) - delta
			n.visible = float(a[6]) <= 0.0
			continue
		a[2] = float(a[2]) - delta
		if float(a[2]) <= 0.0:
			n.queue_free()
			_flying.remove_at(k)
			continue
		if bool(a[4]):
			continue
		var v: Vector3 = a[1]
		v.y -= 9.8 * delta
		a[1] = v
		n.global_position += v * delta
		n.look_at(n.global_position + v, Vector3.UP if absf(v.normalized().y) < 0.98 else Vector3.RIGHT)
		n.rotate_object_local(Vector3.UP, PI)
		if v.y < 0.0 and n.global_position.y <= float(a[3]):
			n.global_position.y = float(a[3])
			n.global_position -= v.normalized() * 0.2       # ucu saplanır
			a[4] = true
			a[2] = minf(float(a[2]), 10.0)
			if not bool(a[5]):
				_impact(a[7])


## Gelen ok saplandı: tok ses (yakınsa), taş tozu; yakındaki savunanlar çöker
func _impact(at: Vector3) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam and cam.global_position.distance_to(at) < 18.0:
		Audio.sfx("land_thud", -20.0, _rng.randf_range(1.6, 2.0))
	if at.y - field.global_position.y > 6.0:
		Vfx.dust(self, to_local(at), 0.15)
	for i: int in _live:
		var st: Dictionary = _live[i]
		if not st.has("p") or not is_instance_valid(st["p"]):
			continue
		var p := st["p"] as Person
		if p.global_position.distance_to(at) < 3.5 and str(spots[i]["do"]).begins_with("wall") and p.rig.activity != "aim":
			st["duck"] = _rng.randf_range(0.8, 1.5)


## Kızgın yağ kazanının devirme kolundaki adam: bekler, ara ara yağı mazgaldan sur dibine döker (kuşatma günleri)
func _oil_lever(p: Person, sp: Dictionary, st: Dictionary, delta: float) -> void:
	st["t"] = float(st["t"]) - delta
	if float(st["t"]) > 0.0 or not hot:
		return
	var ci := int(sp.get("cauldron", -1))
	if ci < 0 or ci >= oil.size():
		return
	st["t"] = _rng.randf_range(28.0, 55.0)
	_pour(p, oil[ci])


func _pour(lever: Person, c: Dictionary) -> void:
	var pivot := c["pivot"] as Node3D
	var node := c["node"] as Node3D
	if not is_instance_valid(pivot) or pivot.has_meta("pouring"):
		return
	pivot.set_meta("pouring", true)
	var tw := create_tween()
	tw.tween_property(pivot, "rotation:x", deg_to_rad(72.0), 0.6).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.5)
	tw.tween_property(pivot, "rotation:x", 0.0, 1.1)
	tw.tween_callback(func():
		if is_instance_valid(pivot):
			pivot.remove_meta("pouring"))
	if is_instance_valid(lever) and lever.rig:
		lever.rig.lock += 1
		var lt := create_tween().set_parallel(true)
		lt.tween_property(lever.rig.arm_l, "rotation", Vector3(-1.2, 0, -0.2), 0.3)
		lt.tween_property(lever.rig.arm_r, "rotation", Vector3(-1.2, 0, 0.2), 0.3)
		lt.chain().tween_interval(1.8)
		lt.chain().tween_callback(func():
			if is_instance_valid(lever):
				lever.rig.lock = maxi(lever.rig.lock - 1, 0))
	# Yağ şeridi: kazanın ağzından mazgalın üstünden sur dibine (dış surun önü, set)
	var from := node.to_global(Vector3(0, 1.25, 0.95))
	var to := node.to_global(Vector3(0, -8.0 + 1.5, 3.4))
	var stream := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.08
	cm.bottom_radius = 0.24
	cm.height = 1.0
	stream.mesh = cm
	stream.material_override = Props.mat(Color(0.62, 0.36, 0.09, 0.84), 0.8, true, "", false)
	stream.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(stream)
	var up := (from - to).normalized()
	var side := up.cross(Vector3.RIGHT).normalized()
	var length := from.distance_to(to)
	stream.global_transform = Transform3D(Basis(side.cross(up), up, side), (from + to) * 0.5)
	stream.scale = Vector3(0.05, length, 0.05)
	var st := create_tween()
	st.tween_interval(0.4)
	st.tween_property(stream, "scale", Vector3(1, length, 1), 0.2)
	st.tween_interval(1.2)
	st.tween_property(stream, "scale", Vector3(0.05, length, 0.05), 0.35)
	st.tween_callback(stream.queue_free)
	get_tree().create_timer(0.6).timeout.connect(func():
		if not is_inside_tree():
			return
		var cam := get_viewport().get_camera_3d()
		if cam and cam.global_position.distance_to(to) < 45.0:
			Audio.sfx("splash", -10.0, 0.7)
			Audio.sfx("fuse_burn", -12.0, 0.6)
		for k in 3:
			Vfx.dust(self, to_local(from.lerp(to, 0.25 + k * 0.25)), 0.3)
		Vfx.dust(self, to_local(to) + Vector3(0, 0.3, 0), 1.2)
		var puff := Vfx.steam(self, to_local(to) + Vector3(0, 0.2, 0))
		get_tree().create_timer(4.0).timeout.connect(func():
			if is_instance_valid(puff):
				puff.queue_free()))


## Yağ taşıyan: ocaktan küpü alır, rampadan sura çıkar, kazana boşaltır, aynı yoldan iner, yeni küp alır
func _oil_carrier(p: Person, sp: Dictionary, st: Dictionary, delta: float) -> void:
	var path: Array = sp.get("path", [])
	if path.size() < 2:
		return
	if st.has("load") and is_instance_valid(st["load"]):
		var ld := st["load"] as Node3D
		ld.global_position = p.global_position + Vector3(0, 1.62, 0) + p.global_basis.z * 0.05
		ld.global_rotation = p.global_rotation
	st["t"] = float(st["t"]) - delta
	match str(st["phase"]):
		"pick":
			if float(st["t"]) > 0.0:
				return
			if p.rig.activity != "lean_down":
				p.rig.activity = "lean_down"
				st["t"] = 0.9
				return
			p.rig.activity = "carry"
			st["load"] = _jar_mesh()
			st["phase"] = "up"
			st["leg"] = 1
		"up", "down":
			var up := str(st["phase"]) == "up"
			var leg := int(st["leg"])
			var tgt: Vector3 = path[leg] if up else path[leg]
			var here := p.position
			var to := tgt - here
			var flat := Vector2(to.x, to.z)
			var step := (1.0 if up else 1.25) * delta
			if flat.length() <= step:
				p.position = tgt
				if up:
					if leg >= path.size() - 1:
						st["phase"] = "empty"
						p.rig.activity = "lean_down"           # küpü kazana boşaltır
						st["t"] = 1.4
						return
					st["leg"] = leg + 1
				else:
					if leg <= 0:
						st["phase"] = "pick"
						p.rig.activity = ""
						p.rotation.y = float(st["yaw"])
						st["t"] = _rng.randf_range(2.0, 5.0)
						return
					st["leg"] = leg - 1
				return
			var dir := Vector3(to.x, 0, to.z).normalized()
			var prev: Vector3 = path[leg - 1] if up and leg > 0 else (path[leg + 1] if not up and leg < path.size() - 1 else here)
			var seg := Vector2(tgt.x - prev.x, tgt.z - prev.z).length()
			var done := clampf(1.0 - (flat.length() - step) / maxf(seg, 0.01), 0.0, 1.0)
			p.position = Vector3(here.x + dir.x * step, lerpf(prev.y, tgt.y, done), here.z + dir.z * step)
			p.rotation.y = lerp_angle(p.rotation.y, atan2(dir.x, dir.z), clampf(delta * 8.0, 0.0, 1.0))
		"empty":
			if float(st["t"]) > 0.0:
				return
			if is_instance_valid(st.get("load")):
				(st["load"] as Node).queue_free()
			st.erase("load")
			var ci := int(sp.get("cauldron", -1))
			if ci >= 0 and ci < oil.size() and is_instance_valid(oil[ci]["node"]):
				var puff := Vfx.steam(oil[ci]["node"], Vector3(0, 1.3, 0))
				get_tree().create_timer(2.0).timeout.connect(func():
					if is_instance_valid(puff):
						puff.queue_free())
			p.rig.activity = ""
			st["phase"] = "down"
			st["leg"] = path.size() - 2


## Ocağı besleyen: eğilip odun atar, doğrulur, ateşe bakar
func _feeder(p: Person, st: Dictionary, delta: float) -> void:
	st["t"] = float(st["t"]) - delta
	if float(st["t"]) > 0.0:
		return
	if p.rig.activity == "lean_down":
		p.rig.activity = ""
		st["t"] = _rng.randf_range(2.0, 4.0)
	else:
		p.rig.activity = "lean_down"
		st["t"] = _rng.randf_range(1.0, 1.8)


func _jar_mesh() -> Node3D:
	var n := Node3D.new()
	add_child(n)
	Props.cyl(n, 0.2, 0.5, Vector3.ZERO, Color("a86a3a"), Vector3.ZERO, 10, 0.12)
	Props.cyl(n, 0.11, 0.06, Vector3(0, 0.27, 0), Color("d8cfb8"), Vector3.ZERO, 8)
	return n


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
