class_name IstHayatYakin
extends Node3D
## İstanbul v2: oyuncunun çevresinde (≈90 m) gerçek kişiler ("yaşam dolu sokaklar", docs/_ajan/gorev/istanbul_parcalar.md).
## CityLife'ın (scripts/world/city_life.gd) v2 karşılığı: SiegeField/WorldWalk/CityPlan'a bağlı olmadığı için kendi akışı var;
## gövde Person (kişi sınıfı), canlandırma Rig (buradan sürülür), sokak sözü SideEvents/StreetEye düzeni çalışır:
##   · Düğüm adı "CityLife" ve ajanlar {body, active, kind, role, look, wait} alanlı: StreetEye (find_children("CityLife"))
##     yakındaki gövdelere "E · Konuş" alanı açar ve tuhaflığa tepki verdirir. Yeni replik yok: var olan havuzlar.
##   · Yerleşim IstSehir.sokak'tan (sokak çizgileri, 2 m doluluk ızgarası, meydanlar); konum hep IstGeo/ızgaradan.
##   · Yürüyenler sokak çizgisi boyunca sağdan yürür, kavşakta döner, karşılaşınca yol verir, tezgâhta durur, ikili sohbet eder.
##   · Duranlar: tezgâhlı satıcı, kapı önünde oturan, leğen başında kadın, sur dibinde işçi ve nöbetçi, rıhtımda balıkçı,
##     dilenci, ikili/üçlü sohbet.
##   · Akış: oyuncuya 38-85 m'de görüş dışında doğar, 105 m ötesinde havuza döner. Çarpışmasız (yalnız tezgâh katı).
## Kullanım: IstHayatYakin.attach(dunya, oyuncu, gece); oyuncu null ise etkin kamera izlenir.

const NEAR := 90.0
const FAR := 105.0
const SPAWN_MIN := 18.0           # görüş dışındaysa en az bu uzaklıkta doğar
const SPAWN_VIEW := 50.0          # görüş içindeyse (ufukta küçük) en az bu uzaklıkta
const SPAWN_MAX := 85.0
const MAX_ACTIVE := 45
const STEP := 5.0                 # sokak çizgisi sıklaştırma aralığı
const HC := 32.0                  # nokta karması hücresi
const SEP_R := 0.6

## Mahalle türüne göre hedef kişi sayısı (kalabalık)
const TARGET := {"carsi": 38, "liman": 26, "sik": 16, "sur_dibi": 14, "seyrek": 8, "bostan": 5, "harabe": 4, "kir": 3}
## Doğuş ağırlığı (aynı sokak noktası kabulü)
const WEIGHT := {"carsi": 1.0, "liman": 0.9, "sik": 0.7, "sur_dibi": 0.55, "seyrek": 0.35, "bostan": 0.2, "harabe": 0.15, "kir": 0.1}

static var aktif: IstHayatYakin


class Agent:
	var body: Person
	var rig: Rig
	var mouth: MeshInstance3D
	var kind := "civ"            # StreetEye için: civ, vendor, fisher, patrol
	var role := "man"            # StreetEye için: man, woman, child, porter, monk, priest
	var prol := "man"            # havuzdaki gerçek rol
	var mode := "walk"           # walk, stand
	var idx := 0
	var active := false
	var pos := Vector3.ZERO
	var yaw := 0.0
	var base := Vector2.ZERO     # yol çizgisi üstündeki konum
	var off := Vector2.ZERO      # yanal kayma (sağdan yürüyüş, yol verme)
	var s := -1                  # sokak
	var i := 0                   # sokak içi nokta
	var d := 1
	var dirv := Vector2.DOWN
	var prev := Vector2.INF
	var speed := 1.2
	var wait := 0.0
	var look := 0.0
	var seen_player := 0.0
	var lane_f := 0.7
	var face := Vector2.INF      # durarak bakılan nokta (x, z)
	var act0 := ""               # varsayılan etkinlik (yük taşıyan: "carry")
	var act := ""
	var mate: Agent
	var chat := 0.0
	var speaker := false
	var prop: Node3D
	var rig_dt := 0.0
	var moved := false
	var tick := true
	var shown_pos := Vector3.INF
	var shown_yaw := INF
	var bad := 0.0
	var bark_t := 0.0
	var customer_cd := 0.0
	var anchor := Vector2.ZERO   # gezinen: bağlı olduğu nokta ve yarıçap
	var arad := 0.0
	var tgt := Vector2.INF
	var plaza := false           # meydan hücrelerinde (doluluk 5) yürüyebilir


class Hayvan extends Agent:
	var node: Node3D
	var tur := "dog"


var sokak: IstSokak
var gece := false
var oyuncu: Node3D
var agents: Array[Agent] = []
var hayvanlar: Array[Hayvan] = []
var graph_ready := false

## Ölçüm
var prof_us := 0.0
var prof_sum_us := 0.0
var prof_n := 0
var prof_max_us := 0.0
var hizli_isinma := false         # önizleme: gövdeler hemen kurulsun

var _P := PackedVector2Array()
var _PS := PackedInt32Array()
var _PI := PackedInt32Array()
var _s0 := PackedInt32Array()
var _sn := PackedInt32Array()
var _sw := PackedFloat32Array()
var _stur: Array = []
var _hash := {}
var _rng := RandomNumberGenerator.new()
var _pw := Vector3.INF
var _last_pw := Vector3(1e9, 0, 1e9)
var _ring := PackedInt32Array()
var _ringw := PackedFloat32Array()
var _kp := PackedVector2Array()      # kıyı noktaları (kıyıdan 1,4 m içeride)
var _kd := PackedVector2Array()      # karadan suya yön
var _cam_at := Vector3.INF
var _cam_fwd := Vector3.ZERO
var _cam_cos := -1.0
var _hud: Node
var _stream_t := 0.0
var _tick_t := 0.0
var _frame := 0
var _time := 0.0
var _built := 0
var _built_frame := 0
var _warm_skip := 0
var _bark_t := 14.0
var _ilk := 6.0                   # ilk akış adımları (kare sayılır): görüş içinde de, yakında da doğabilir (açılış karesi boş olmasın)
var _kapali := false
var _meydan_c := PackedVector2Array()
var sayac := {"deneme": 0, "nokta_yok": 0, "yurur_yok": 0, "kondu": 0, "hucre_yok": 0, "agirlik": 0, "gorus": 0, "kalabalik": 0, "su": 0, "uzak": 0}


static func attach(dunya: Node3D, oyuncu_: Node3D = null, gece_ := false, as_citylife := true) -> IstHayatYakin:
	if IstSehir.sokak == null:
		push_warning("IstHayatYakin: IstSehir.sokak yok (attach_v2 sonrası çağır)")
		return null
	var h := IstHayatYakin.new()
	h.name = "CityLife" if as_citylife else "IstHayatYakin"
	h.sokak = IstSehir.sokak
	h.gece = gece_
	h.oyuncu = oyuncu_
	dunya.add_child(h)
	aktif = h
	return h


func _ready() -> void:
	_rng.seed = 1453771
	var t0 := Time.get_ticks_msec()
	_kur_ag()
	_make_agents()
	graph_ready = true
	print("ISTKISI kur noktalar=%d sokak=%d meydan=%d kiyi=%d havuz=%d hayvan=%d kur_ms=%d" % [_P.size(), _s0.size(), _meydan_c.size(), _kp.size(), agents.size(), hayvanlar.size(), Time.get_ticks_msec() - t0])


# ---------------------------------------------------------------- sokak noktaları

func _kur_ag() -> void:
	var ns := sokak.streets.size()
	_s0.resize(ns)
	_sn.resize(ns)
	_sw.resize(ns)
	_stur.resize(ns)
	var pts: Array = []
	var total := 0
	for k in ns:
		var st: Dictionary = sokak.streets[k]
		var pl: PackedVector2Array = st["pts"]
		var dens := PackedVector2Array()
		for a in pl.size() - 1:
			var L := pl[a].distance_to(pl[a + 1])
			var n := maxi(1, int(ceil(L / STEP)))
			for b in n:
				dens.append(pl[a].lerp(pl[a + 1], float(b) / n))
		if pl.size() > 0:
			dens.append(pl[pl.size() - 1])
		_s0[k] = total
		_sn[k] = dens.size()
		_sw[k] = float(st["w"])
		_stur[k] = String(st["tur"])
		total += dens.size()
		pts.append(dens)
	_P.resize(total)
	_PS.resize(total)
	_PI.resize(total)
	var g := 0
	for k in ns:
		var dens: PackedVector2Array = pts[k]
		for b in dens.size():
			_P[g] = dens[b]
			_PS[g] = k
			_PI[g] = b
			var c := Vector2i(floori(dens[b].x / HC), floori(dens[b].y / HC))
			var cell_arr: PackedInt32Array = _hash.get(c, PackedInt32Array())
			cell_arr.append(g)          # Packed*Array değer türü: geri yazılmalı
			_hash[c] = cell_arr
			g += 1
	for m: Dictionary in sokak.meydan:
		_meydan_c.append(m["c"])
	_kiyi_kur()


## Kıyı çizgisi boyunca 12 m'de bir nokta: sokak olmasa da rıhtımda balıkçı/hamal/sohbet doğabilsin
func _kiyi_kur() -> void:
	for ad: String in ["yarimada", "galata"]:
		var pl := IstGeo.kiyi(ad)
		var n := pl.size()
		for i in n:
			var a := pl[i]
			var b := pl[(i + 1) % n]
			var L := a.distance_to(b)
			if L < 0.5:
				continue
			var tg := (b - a) / L
			var nrm := Vector2(-tg.y, tg.x)
			for k in int(L / 12.0) + 1:
				var p := a + tg * minf(k * 12.0, L)
				for sg: float in [1.0, -1.0]:
					var dv := nrm * sg
					# kara tarafından suya doğru yürü
					var q0 := p - dv * 10.0
					if IstGeo.su(q0.x, q0.y):
						continue
					var dd := 0.0
					while dd < 24.0:
						var q := q0 + dv * dd
						if IstGeo.su(q.x, q.y):
							var sp := q - dv * 1.4
							if _ok_cell(sp.x, sp.y) and not IstGeo.su(sp.x, sp.y) and IstGeo.h(sp.x, sp.y) > 0.25:
								_kp.append(sp)
								_kd.append(dv)
							break
						dd += 1.5
					break


func _cands(p: Vector2, r: float) -> PackedInt32Array:
	var out := PackedInt32Array()
	var c0 := Vector2i(floori((p.x - r) / HC), floori((p.y - r) / HC))
	var c1 := Vector2i(floori((p.x + r) / HC), floori((p.y + r) / HC))
	for cx in range(c0.x, c1.x + 1):
		for cy in range(c0.y, c1.y + 1):
			var a = _hash.get(Vector2i(cx, cy))
			if a != null:
				out.append_array(a)
	return out


func _ok_cell(x: float, z: float) -> bool:
	var c := sokak.cell(x, z)
	return c == 0 or c == 1


func _tur(x: float, z: float) -> String:
	return String(IstGeo.mahalle(x, z).get("tur", "kir"))


# ---------------------------------------------------------------- havuz

func _make_agents() -> void:
	var roles := IstHayatGovde.pool_roles()
	for i in roles.size():
		var ag := Agent.new()
		ag.idx = i
		ag.prol = roles[i]
		match ag.prol:
			"vendor":
				ag.kind = "vendor"
				ag.role = "man"
			"fisher":
				ag.kind = "fisher"
				ag.role = "man"
			"guard":
				ag.kind = "patrol"
				ag.role = "man"
			"woman", "washer":
				ag.role = "woman"
			"porter", "priest", "monk", "child":
				ag.role = ag.prol
			_:
				ag.role = "man"
		ag.speed = _rng.randf_range(0.95, 1.4) * (0.8 if ag.prol in ["priest", "monk"] else 1.0) * (1.25 if ag.prol == "child" else 1.0)
		ag.lane_f = _rng.randf_range(0.35, 1.0)
		agents.append(ag)
	var hi := 0
	for e: Array in IstHayatGovde.ANIMALS:
		for k in int(e[1]):
			var h := Hayvan.new()
			h.tur = e[0]
			h.idx = 100 + hi
			h.mode = "walk"
			h.speed = {"dog": 1.5, "cat": 0.9, "hen": 0.5, "donkey": 0.95}.get(h.tur, 1.0) * _rng.randf_range(0.9, 1.15)
			h.lane_f = _rng.randf_range(0.2, 0.8)
			hayvanlar.append(h)
			hi += 1


func _ensure_animal(h: Hayvan) -> bool:
	if h.node != null:
		return true
	if _built_frame >= 3:
		return false
	_built_frame += 1
	h.node = IstHayatGovde.animal(h.tur, h.idx)
	h.node.visible = false
	h.node.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(h.node)
	return true


func _ensure_body(ag: Agent) -> bool:
	if ag.body != null:
		return true
	if _built_frame >= (8 if hizli_isinma else 2):
		return false
	_built_frame += 1
	var pr := IstHayatGovde.body(ag.prol, ag.idx, gece)
	pr.name = "Kisi%d" % ag.idx
	pr.visible = false
	pr.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(pr)
	pr.set_process(false)             # Rig'i buradan sürülür (yol açma ve ortam sohbeti çalışmaz)
	IstHayatGovde.dress(pr, ag.prol, ag.idx, gece)
	ag.body = pr
	ag.rig = pr.get("rig") as Rig
	ag.mouth = pr.get("_mouth") as MeshInstance3D
	ag.act0 = pr.activity
	_built += 1
	return true


func _prop_for(ag: Agent) -> Node3D:
	if ag.prop == null:
		match ag.prol:
			"vendor": ag.prop = IstHayatGovde.stall(ag.idx)
			"sitter": ag.prop = IstHayatGovde.stool()
			"washer": ag.prop = IstHayatGovde.tub()
			"worker": ag.prop = IstHayatGovde.rubble()
			"beggar": ag.prop = IstHayatGovde.bowl()
		if ag.prop != null:
			add_child(ag.prop)
	return ag.prop


func _activate(ag: Agent) -> void:
	ag.active = true
	var b := ag.body
	b.process_mode = Node.PROCESS_MODE_INHERIT
	b.set_process(false)
	b.visible = true
	b.position = ag.pos
	b.rotation = Vector3(0, ag.yaw, 0)
	ag.shown_pos = ag.pos
	ag.shown_yaw = ag.yaw
	if ag.rig:
		ag.rig.speed = 0.0
	ag.rig_dt = 0.0
	ag.look = 0.0
	ag.wait = maxf(ag.wait, 0.0)
	_set_act(ag, ag.act0)


func _deactivate(ag: Agent) -> void:
	ag.active = false
	if ag.mate != null:
		if ag.mate.mate == ag:
			ag.mate.mate = null
			ag.mate.chat = 0.0
		ag.mate = null
	ag.chat = 0.0
	ag.wait = 0.0
	ag.face = Vector2.INF
	if ag.body:
		ag.body.visible = false
		ag.body.process_mode = Node.PROCESS_MODE_DISABLED
	if ag is Hayvan and (ag as Hayvan).node:
		(ag as Hayvan).node.visible = false
		(ag as Hayvan).node.process_mode = Node.PROCESS_MODE_DISABLED
	if ag.prop:
		ag.prop.visible = false
		ag.prop.process_mode = Node.PROCESS_MODE_DISABLED


func _set_act(ag: Agent, a: String) -> void:
	if ag.act == a or ag.body == null:
		return
	ag.act = a
	if a == "" and ag.act0 != "":
		ag.body.set_activity(ag.act0)
	else:
		ag.body.set_activity(a)


# ---------------------------------------------------------------- her kare

func _process(delta: float) -> void:
	if _kapali or not graph_ready:
		return
	var t0 := Time.get_ticks_usec()
	_time += delta
	_frame += 1
	_built_frame = 0
	if oyuncu == null or not is_instance_valid(oyuncu):
		oyuncu = get_tree().get_first_node_in_group("player") as Node3D
	var cam := get_viewport().get_camera_3d()
	var ref: Node3D = oyuncu if oyuncu != null else cam
	if ref == null:
		return
	_pw = ref.global_position
	if _last_pw.distance_to(_pw) > 120.0:
		_ilk = 6.0            # ışınlanma/bölüm geçişi: yeni yerde de ilk kare dolu olsun
	_last_pw = _pw
	if _hud == null or not is_instance_valid(_hud):
		_hud = get_tree().get_first_node_in_group("hud")
	_view_cone(cam)
	# Havuz ısınır: gövde kurmak 6-17 ms; oyunda dört karede bir, önizlemede hızlı
	if _built < agents.size():
		_warm_skip -= 1
		if hizli_isinma or _warm_skip <= 0:
			_warm_skip = 4
			var n := 8 if hizli_isinma else 1
			for ag in agents:
				if n <= 0:
					break
				if ag.body == null:
					if _ensure_body(ag):
						n -= 1
	if _built >= agents.size():
		for h in hayvanlar:
			if h.node == null and _ensure_animal(h):
				break
	var yuksek := _pw.y - maxf(IstGeo.h(_pw.x, _pw.z), 0.0) > 150.0
	_stream_t -= delta
	if _stream_t <= 0.0:
		_stream_t = 0.2 if _ilk > 0.0 else 0.4
		_stream(yuksek)
	_tick_t -= delta
	if _tick_t <= 0.0:
		_tick_t = 0.1
		_think()
	for ag in agents:
		if ag.active:
			_update(ag, delta)
	for h in hayvanlar:
		if h.active:
			_update_hayvan(h, delta)
	var us := float(Time.get_ticks_usec() - t0)
	prof_us = lerpf(prof_us, us, 0.05) if prof_us > 0.0 else us
	prof_sum_us += us
	prof_n += 1
	prof_max_us = maxf(prof_max_us, us)


func _view_cone(cam: Camera3D) -> void:
	if cam == null:
		_cam_at = Vector3.INF
		return
	_cam_at = cam.global_position
	_cam_fwd = (-cam.global_basis.z).normalized()
	var vs := get_viewport().get_visible_rect().size
	var aspect := vs.x / maxf(vs.y, 1.0)
	var half := atan(tan(deg_to_rad(cam.fov) * 0.5) * maxf(aspect, 1.0))
	_cam_cos = cos(minf(half + deg_to_rad(20.0), PI * 0.5))


func _seen(p: Vector3) -> bool:
	if _cam_at == Vector3.INF:
		return true
	var d := p + Vector3(0, 1.0, 0) - _cam_at
	var l2 := d.length_squared()
	if l2 < 16.0:
		return true
	return _cam_fwd.dot(d) > _cam_cos * sqrt(l2)


func _flat(p: Vector3) -> Vector2:
	return Vector2(p.x, p.z)


# ---------------------------------------------------------------- akış (doğuş / havuza dönüş)

## Akış adımlarını hemen çalıştırır (önizleme, ışınlanma, bölüm girişi): n adım
func doldur(n := 6) -> void:
	if oyuncu == null or not is_instance_valid(oyuncu):
		oyuncu = get_tree().get_first_node_in_group("player") as Node3D
	var cam := get_viewport().get_camera_3d()
	var ref: Node3D = oyuncu if oyuncu != null else cam
	if ref == null:
		return
	_pw = ref.global_position
	_view_cone(cam)
	_ilk = float(n)
	for k in n:
		_stream(false)


func hedef_sayi() -> int:
	var p := Vector2(_pw.x, _pw.z)
	var sum := 0.0
	var n := 0.0
	for k in 5:
		var q := p if k == 0 else p + Vector2.from_angle(k * 1.57 + 0.4) * 45.0
		sum += float(TARGET.get(_tur(q.x, q.y), 6)) * (2.0 if k == 0 else 1.0)
		n += 2.0 if k == 0 else 1.0
	var t := sum / n
	for g in _cands(p, 30.0):
		if _stur[_PS[g]] == "mese" and _P[g].distance_to(p) < 30.0:
			t = maxf(t, 30.0)         # Mese kıyısında çarşı yoğunluğu
			break
	if gece:
		t *= 0.55
	return mini(int(round(t)), MAX_ACTIVE)


func _stream(yuksek: bool) -> void:
	var cnt := 0
	var p2 := _flat(_pw)
	for ag in agents:
		if not ag.active:
			continue
		var dd := _flat(ag.pos).distance_to(p2)
		if yuksek or dd > FAR:
			_deactivate(ag)
			continue
		cnt += 1
	for h in hayvanlar:
		if h.active and (yuksek or _flat(h.pos).distance_to(p2) > FAR):
			_deactivate(h)
	if yuksek:
		return
	var tgt := hedef_sayi()
	var ha := 0
	for h in hayvanlar:
		if h.active:
			ha += 1
	if ha < clampi(tgt / 5, 1, 6) and _rng.randf() < 0.6:
		_spawn_animal()
	# fazlalık: görünmeyen ve uzaktaki bir kişiyi çek
	if cnt > tgt + 2:
		for ag in agents:
			if ag.active and not _seen(ag.pos) and _flat(ag.pos).distance_to(p2) > 55.0:
				_deactivate(ag)
				break
	_ring_kur(p2)
	var burst := 10 if _ilk > 0.0 else 2
	var tries := 0
	while cnt < tgt and burst > 0 and tries < 14:
		tries += 1
		var made := _spawn_one()
		if made > 0:
			cnt += made
			burst -= 1
	if _ilk > 0.0:
		_ilk -= 1.0


func _free_agent(roles: Array) -> Agent:
	var cands: Array = []
	for ag in agents:
		if not ag.active and ag.body != null and ag.prol in roles:
			cands.append(ag)
	if cands.is_empty():
		return null
	return cands[_rng.randi() % cands.size()]


## Akış adımı başında: oyuncunun 12/18–85 m çevresindeki sokak noktaları, yakına ve bakış yönüne ağırlıklı (birikimli)
func _ring_kur(p2: Vector2) -> void:
	_ring.clear()
	_ringw.clear()
	var fwd := Vector2(_cam_fwd.x, _cam_fwd.z)
	if fwd.length() > 0.1:
		fwd = fwd.normalized()
	var r0 := 12.0 if _ilk > 0.0 else SPAWN_MIN
	var tot := 0.0
	for g in _cands(p2, SPAWN_MAX):
		var dv := _P[g] - p2
		var dd := dv.length()
		if dd < r0 or dd > SPAWN_MAX:
			continue
		var w := 0.15 + 0.85 * pow(clampf(1.0 - (dd - r0) / (SPAWN_MAX - r0), 0.0, 1.0), 1.2)
		if fwd.length() > 0.1 and dv.dot(fwd) < dd * 0.5:
			w *= 0.6
		match String(_stur[_PS[g]]):
			"mese":
				w *= 6.0           # ana cadde: nokta sayısı az ama kalabalık orada
			"yol":
				w *= 2.0
		tot += w
		_ring.append(g)
		_ringw.append(tot)


func _pick_point() -> int:
	var p2 := _flat(_pw)
	var n := _ring.size()
	if n == 0:
		return -1
	var tot := _ringw[n - 1]
	for k in 12:
		var i := mini(_ringw.bsearch(_rng.randf() * tot), n - 1)
		var g: int = _ring[i]
		var pt := _P[g]
		var dd := pt.distance_to(p2)
		var tur := _tur(pt.x, pt.y)
		var wgt := float(WEIGHT.get(tur, 0.3))
		match String(_stur[_PS[g]]):
			"mese":
				wgt = 1.0          # Mese her yerde kalabalık
			"yol":
				wgt = maxf(wgt, 0.7)
		if _rng.randf() > wgt:
			sayac["agirlik"] += 1
			continue
		var y := IstGeo.h(pt.x, pt.y)
		if IstGeo.su(pt.x, pt.y) or y < 0.2:
			sayac["su"] += 1
			continue
		if _ilk <= 0.0 and dd < SPAWN_VIEW and _seen(Vector3(pt.x, y, pt.y)) and not _occluded(p2, pt):
			sayac["gorus"] += 1
			continue
		if _crowded(pt, 1.6):
			sayac["kalabalik"] += 1
			continue
		return g
	return -1


## Oyuncu ile nokta arasında ev/sur hücresi (2, 3) varsa görünmez sayılır (yakında da doğabilir)
func _occluded(a: Vector2, b: Vector2) -> bool:
	var d := b - a
	var L := d.length()
	var n := int(L / 2.0)
	for k in range(1, n):
		var q := a + d * (float(k) / n)
		var c := sokak.cell(q.x, q.y)
		if c == 2 or c == 3:
			return true
	return false


func _crowded(p: Vector2, r: float) -> bool:
	for ag in agents:
		if ag.active and (_flat(ag.pos).distance_to(p) < r or ag.base.distance_to(p) < r):
			return true
	return false


## Bir doğuş denemesi; kaç kişi eklendi
func _spawn_one() -> int:
	sayac["deneme"] += 1
	var r := _rng.randf()
	# sokak noktası istemeyen yerler: meydan ve rıhtım
	if r < 0.14:
		var np := _spawn_plaza()
		if np > 0:
			return np
	elif r > 0.84:
		var nq := _spawn_quay_ring()
		if nq > 0:
			return nq
	r = _rng.randf()
	var g := _pick_point()
	if g < 0:
		sayac["nokta_yok"] += 1
		return 0
	var pt := _P[g]
	var s := _PS[g]
	var w := _sw[s]
	var tur := _tur(pt.x, pt.y)
	var wide := w >= 5.5
	# durarak/iş yapanlar
	if wide and tur in ["carsi", "liman", "sik"] and r < 0.16:
		if _spawn_vendor(g):
			return 1
	elif tur == "liman" and r < 0.14:
		if _spawn_fisher(g):
			return 1
	elif tur == "sur_dibi" and r < 0.45:
		if _spawn_wall(g):
			return 1
	elif r < 0.07 and tur in ["carsi", "sik", "liman", "seyrek"]:
		if _spawn_edge(g, "sitter"):
			return 1
	elif r < 0.10 and tur in ["sik", "seyrek", "liman"]:
		if _spawn_edge(g, "washer"):
			return 1
	elif r < 0.12 and tur in ["carsi", "liman"]:
		if _spawn_edge(g, "beggar"):
			return 1
	elif r < 0.30:
		var n := _spawn_gossip(g)
		if n > 0:
			return n
	# yürüyen (yüzde 22 ikili)
	var pair := _rng.randf() < 0.22
	var a := _spawn_walker(g, null)
	if a == null:
		sayac["yurur_yok"] += 1
		return 0
	sayac["kondu"] += 1
	if pair:
		var b := _spawn_walker(g, a)
		if b != null:
			a.mate = b
			b.mate = a
			b.speed = a.speed
			b.lane_f = clampf(a.lane_f - 0.3, 0.2, 1.0)
			return 2
	return 1


const WALKERS := ["man", "woman", "child", "porter", "monk", "priest", "lantern"]

func _walker_roles() -> Array:
	var w: Array = ["man", "woman", "child", "porter"]
	w.append_array(["lantern", "lantern"] if gece else ["man", "woman"])
	if _rng.randf() < 0.12:
		w.append_array(["monk", "priest"])
	return w


func _spawn_walker(g: int, ref: Agent) -> Agent:
	var ag := _free_agent(_walker_roles())
	if ag == null:
		return null
	var s := _PS[g]
	var i := _PI[g]
	ag.mode = "walk"
	ag.s = s
	ag.i = i
	ag.d = 1 if (_rng.randf() < 0.5 or i == 0) and i < _sn[s] - 1 else -1
	if ref != null and ref.s == s:
		ag.d = ref.d
	if i + ag.d < 0 or i + ag.d >= _sn[s]:
		return null
	var nxt := _P[_s0[s] + i + ag.d]
	ag.base = _P[g].lerp(nxt, _rng.randf() * 0.85)          # aynı noktaya dizilmesinler
	ag.dirv = (nxt - ag.base).normalized()
	ag.prev = ag.base - ag.dirv * 2.0
	ag.off = Vector2.ZERO
	_lane_snap(ag)
	var q := ag.base + ag.off
	if not _ok_cell(q.x, q.y):
		ag.off = Vector2.ZERO
		q = ag.base
		if not _ok_cell(q.x, q.y):
			return null
	if ref == null and _crowded(q, 1.8):
		return null
	ag.pos = Vector3(q.x, IstGeo.h(q.x, q.y), q.y)
	ag.yaw = atan2(ag.dirv.x, ag.dirv.y)
	ag.wait = _rng.randf_range(0.0, 1.5)
	ag.face = Vector2.INF
	ag.bad = 0.0
	_activate(ag)
	return ag


func _lane_max(ag: Agent) -> float:
	var w := _sw[ag.s]
	return maxf(0.3, w * 0.5 - (2.4 if w >= 5.5 else 1.5))


func _lane_target(ag: Agent) -> Vector2:
	var right := Vector2(-ag.dirv.y, ag.dirv.x)
	return right * _lane_max(ag) * ag.lane_f


func _lane_snap(ag: Agent) -> void:
	ag.off = _lane_target(ag)


## Sokağın kenarında durulabilir nokta: kenardan içeri `inset`; side +1/−1 (sol/sağ)
func _edge_spot(g: int, inset: float, side: float) -> Dictionary:
	var s := _PS[g]
	var i := _PI[g]
	var a := _P[g]
	var b := _P[_s0[s] + mini(i + 1, _sn[s] - 1)] if i + 1 < _sn[s] else a
	var c := _P[_s0[s] + maxi(i - 1, 0)]
	var tg := (b - c)
	if tg.length() < 0.1:
		return {}
	tg = tg.normalized()
	var nrm := Vector2(-tg.y, tg.x) * side
	var w := _sw[s]
	var p := a + nrm * (w * 0.5 - inset)
	if not _ok_cell(p.x, p.y):
		return {}
	var y := IstGeo.h(p.x, p.y)
	if IstGeo.su(p.x, p.y) or y < 0.2:
		return {}
	return {"p": p, "tg": tg, "nrm": nrm, "w": w, "y": y}


func _stand(ag: Agent, p: Vector2, face_to: Vector2, act: String, kind_prop_off: Vector2 = Vector2.ZERO) -> void:
	ag.mode = "stand"
	ag.s = -1
	ag.base = p
	ag.off = Vector2.ZERO
	ag.pos = Vector3(p.x, IstGeo.h(p.x, p.y), p.y)
	var dv := (face_to - p)
	ag.yaw = atan2(dv.x, dv.y) if dv.length() > 0.01 else 0.0
	ag.face = face_to
	ag.wait = 0.0
	ag.bad = 0.0
	_activate(ag)
	_set_act(ag, act)


func _spawn_vendor(g: int) -> bool:
	var ag := _free_agent(["vendor"])
	if ag == null:
		return false
	var side := 1.0 if _rng.randf() < 0.5 else -1.0
	var e := _edge_spot(g, 1.2, side)
	if e.is_empty():
		return false
	var c: Vector2 = e["p"]
	var tg: Vector2 = e["tg"]
	var nrm: Vector2 = e["nrm"]
	# tezgâh dikdörtgeni (1,95 × 1 + arkada satıcı payı) yol hücrelerinde olmalı
	for u in [-1.0, 0.0, 1.0]:
		for v in [-0.9, 0.0, 0.9]:
			var q: Vector2 = c + tg * u + nrm * v
			if not _ok_cell(q.x, q.y):
				return false
	if _crowded(c, 4.0):
		return false
	var toroad := -nrm
	var pr := _prop_for(ag)
	pr.visible = true
	pr.process_mode = Node.PROCESS_MODE_INHERIT
	pr.position = Vector3(c.x, IstGeo.h(c.x, c.y), c.y)
	pr.rotation = Vector3(0, atan2(toroad.x, toroad.y), 0)
	var vp := c + nrm * 0.95
	_stand(ag, vp, c + toroad * 3.0, "")
	ag.bark_t = _rng.randf_range(2.0, 12.0)
	return true


func _spawn_edge(g: int, prol: String) -> bool:
	var ag := _free_agent([prol])
	if ag == null:
		return false
	var side := 1.0 if _rng.randf() < 0.5 else -1.0
	var e := _edge_spot(g, 0.85, side)
	if e.is_empty():
		return false
	var c: Vector2 = e["p"]
	var nrm: Vector2 = e["nrm"]
	if _crowded(c, 2.5):
		return false
	var toroad := -nrm
	var pr := _prop_for(ag)
	match prol:
		"sitter":
			pr.visible = true
			pr.process_mode = Node.PROCESS_MODE_INHERIT
			pr.position = Vector3(c.x, IstGeo.h(c.x, c.y), c.y)
			pr.rotation = Vector3(0, atan2(toroad.x, toroad.y), 0)
			_stand(ag, c, c + toroad * 3.0, "sit")
		"washer":
			var lp := c + toroad * 0.55
			pr.visible = true
			pr.process_mode = Node.PROCESS_MODE_INHERIT
			pr.position = Vector3(lp.x, IstGeo.h(c.x, c.y), lp.y)
			pr.rotation = Vector3(0, atan2(toroad.x, toroad.y), 0)
			_stand(ag, c, c + toroad * 3.0, "stir")
		"beggar":
			var bp := c + toroad * 0.7
			pr.visible = true
			pr.process_mode = Node.PROCESS_MODE_INHERIT
			pr.position = Vector3(bp.x, IstGeo.h(c.x, c.y), bp.y)
			_stand(ag, c, c + toroad * 3.0, "sit_ground")
		_:
			return false
	return true


func _spawn_gossip(g: int) -> int:
	var a := _free_agent(["man", "woman", "man", "porter"])
	if a == null:
		return 0
	var side := 1.0 if _rng.randf() < 0.5 else -1.0
	var e := _edge_spot(g, 1.0, side)
	if e.is_empty():
		return 0
	return _gossip_at(a, e["p"], e["tg"], false)


func _gossip_at(a: Agent, c: Vector2, tg: Vector2, plaza_: bool) -> int:
	if _crowded(c, 3.0):
		return 0
	var pa := c - tg * 0.55
	var pb := c + tg * 0.55
	if not (_ok_p(pa, plaza_) and _ok_p(pb, plaza_)):
		return 0
	var b := _free_agent(["woman", "man", "child"] if a.prol != "child" else ["woman"])
	if b == null or b == a:
		return 0
	_stand(a, pa, pb, "")
	_stand(b, pb, pa, "")
	a.mate = b
	b.mate = a
	a.chat = _rng.randf_range(30.0, 90.0)
	b.chat = a.chat
	a.speaker = true
	b.speaker = false
	return 2


## Noktadan kıyıya: {sp: kıyıdan 1,4 m içerideki kara noktası, face: su noktası, dv}; yoksa {}
func _coast_from(pt: Vector2) -> Dictionary:
	for k in 16:
		var dv := Vector2.from_angle(k * TAU / 16.0 + _rng.randf() * 0.2)
		var dd := 3.0
		while dd < 24.0:
			var q: Vector2 = pt + dv * dd
			if IstGeo.su(q.x, q.y):
				var sp: Vector2 = q - dv * 1.4
				if _ok_cell(sp.x, sp.y) and not IstGeo.su(sp.x, sp.y) and IstGeo.h(sp.x, sp.y) > 0.25:
					return {"sp": sp, "face": q, "dv": dv}
				break
			dd += 1.5
	return {}


func _spawn_fisher(g: int) -> bool:
	var ag := _free_agent(["fisher"])
	if ag == null:
		return false
	var cf := _coast_from(_P[g])
	if cf.is_empty() or _crowded(cf["sp"], 3.0):
		return false
	_stand(ag, cf["sp"], cf["face"], "sit_ground")
	return true


func _ok_p(q: Vector2, plaza_: bool) -> bool:
	var c := sokak.cell(q.x, q.y)
	if c == 0 or c == 1 or (plaza_ and c == 5):
		return not IstGeo.su(q.x, q.y) and IstGeo.h(q.x, q.y) > 0.2
	return false


## Gezinen: anchor çevresinde (arad) rastgele noktalara gidip bekler; meydanda doluluk 5 de geçerli
func _wander_start(ag: Agent, at: Vector2, anchor: Vector2, arad: float, plaza_: bool) -> void:
	ag.mode = "wander"
	ag.s = -1
	ag.anchor = anchor
	ag.arad = arad
	ag.plaza = plaza_
	ag.tgt = Vector2.INF
	ag.base = at
	ag.off = Vector2.ZERO
	ag.pos = Vector3(at.x, IstGeo.h(at.x, at.y), at.y)
	ag.yaw = _rng.randf() * TAU
	ag.dirv = Vector2.from_angle(ag.yaw)
	ag.wait = _rng.randf_range(0.0, 3.0)
	ag.face = Vector2.INF
	ag.bad = 0.0
	if ag is Hayvan:
		(ag as Hayvan).node.position = ag.pos
		(ag as Hayvan).node.visible = true
		(ag as Hayvan).node.process_mode = Node.PROCESS_MODE_INHERIT
		ag.active = true
		return
	_activate(ag)


func _wander(ag: Agent, delta: float) -> void:
	if ag.wait > 0.0:
		ag.wait -= delta
		return
	if ag.tgt == Vector2.INF:
		for k in 8:
			var q := ag.anchor + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(0.4, 1.0) * ag.arad
			if ag.plaza and q.distance_to(ag.anchor) < 1.8:
				continue
			if _ok_p(q, ag.plaza) and _ok_p((ag.base + q) * 0.5, ag.plaza):
				ag.tgt = q
				break
		if ag.tgt == Vector2.INF:
			ag.wait = 2.0
			return
	var to := ag.tgt - ag.base
	var dist := to.length()
	var step := ag.speed * delta
	if dist <= step:
		ag.base = ag.tgt
		ag.tgt = Vector2.INF
		ag.wait = _rng.randf_range(1.5, 6.0)
	else:
		ag.base += to / dist * step
		ag.dirv = to / dist
	ag.pos.x = ag.base.x
	ag.pos.z = ag.base.y


## Meydan: 2-3 gezinen + bir sohbet ikilisi (doğuş görüş kurallarına uyar)
func _spawn_plaza() -> int:
	var p2 := _flat(_pw)
	var r0 := 5.0 if _ilk > 0.0 else SPAWN_MIN
	var opts: Array = []
	for c: Vector2 in _meydan_c:
		var d := c.distance_to(p2)
		if d < r0 or d > SPAWN_MAX:
			continue
		if _ilk <= 0.0 and d < SPAWN_VIEW and _seen(Vector3(c.x, IstGeo.h(c.x, c.y) + 1.0, c.y)) and not _occluded(p2, c):
			continue
		if _crowded(c, 7.0):
			continue
		opts.append(c)
	if opts.is_empty():
		return 0
	var c: Vector2 = opts[_rng.randi() % opts.size()]
	var n := 0
	for k in _rng.randi_range(2, 3):
		var ag := _free_agent(["man", "woman", "child", "porter", "man"])
		if ag == null:
			break
		var st: Vector2 = c + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(2.2, 5.0)
		if not _ok_p(st, true):
			continue
		_wander_start(ag, st, c, 5.4, true)
		n += 1
	var ga := _free_agent(["man", "woman"])
	if ga != null:
		var ang := _rng.randf() * TAU
		var cc: Vector2 = c + Vector2.from_angle(ang) * 3.6
		n += _gossip_at(ga, cc, Vector2.from_angle(ang + PI * 0.5), true)
	return n


## Çevredeki kıyı noktalarından biri: balıkçı, kıyı boyu gezinen hamal, sohbet
func _spawn_quay_ring() -> int:
	var p2 := _flat(_pw)
	var r0 := 8.0 if _ilk > 0.0 else SPAWN_MIN
	var opts: Array = []
	for k in _kp.size():
		var d := _kp[k].distance_to(p2)
		if d < r0 or d > SPAWN_MAX:
			continue
		var tur := _tur(_kp[k].x, _kp[k].y)
		if tur != "liman" and _rng.randf() > 0.35:
			continue
		if _ilk <= 0.0 and d < SPAWN_VIEW and _seen(Vector3(_kp[k].x, IstGeo.h(_kp[k].x, _kp[k].y) + 1.0, _kp[k].y)) and not _occluded(p2, _kp[k]):
			continue
		opts.append(k)
	if opts.is_empty():
		return 0
	var k: int = opts[_rng.randi() % opts.size()]
	return _spawn_quay(_kp[k], _kd[k])


func _spawn_quay(sp: Vector2, dv: Vector2) -> int:
	if _crowded(sp, 6.0):
		return 0
	var n := 0
	var fa := _free_agent(["fisher"])
	if fa != null:
		_stand(fa, sp, sp + dv * 3.0, "sit_ground")
		n += 1
	var pa := _free_agent(["porter", "man", "woman"])
	if pa != null:
		var st: Vector2 = sp - dv * 2.5
		if _ok_p(st, false):
			_wander_start(pa, st, st, 6.0, false)
			n += 1
	var ga := _free_agent(["man"])
	if ga != null:
		var tg := Vector2(-dv.y, dv.x)
		n += _gossip_at(ga, sp - dv * 3.5 + tg * 4.0, tg, false)
	return n


# ---------------------------------------------------------------- hayvanlar

func _spawn_animal() -> bool:
	var cands: Array = []
	for h in hayvanlar:
		if not h.active and h.node != null:
			cands.append(h)
	if cands.is_empty():
		return false
	var h: Hayvan = cands[_rng.randi() % cands.size()]
	var g := _pick_point()
	if g < 0:
		return false
	var pt := _P[g]
	match h.tur:
		"dog", "donkey":
			var s := _PS[g]
			var i := _PI[g]
			h.s = s
			h.i = i
			h.d = 1 if (_rng.randf() < 0.5 or i == 0) and i < _sn[s] - 1 else -1
			if i + h.d < 0 or i + h.d >= _sn[s]:
				return false
			h.mode = "walk"
			h.base = pt
			h.dirv = (_P[_s0[s] + i + h.d] - h.base).normalized()
			h.prev = h.base - h.dirv * 2.0
			h.off = Vector2.ZERO
			_lane_snap(h)
			var q := h.base + h.off
			if not _ok_cell(q.x, q.y):
				h.off = Vector2.ZERO
				q = h.base
				if not _ok_cell(q.x, q.y):
					return false
			h.pos = Vector3(q.x, IstGeo.h(q.x, q.y), q.y)
			h.yaw = atan2(h.dirv.x, h.dirv.y)
			h.wait = 0.0
			h.bad = 0.0
			h.node.position = h.pos
			h.node.rotation.y = h.yaw
			h.node.visible = true
			h.node.process_mode = Node.PROCESS_MODE_INHERIT
			h.active = true
		_:
			var e := _edge_spot(g, 0.8, 1.0 if _rng.randf() < 0.5 else -1.0)
			if e.is_empty() or _crowded(e["p"], 1.5):
				return false
			_wander_start(h, e["p"], e["p"], 1.4 if h.tur == "cat" else 2.0, false)
	return true


func _update_hayvan(h: Hayvan, delta: float) -> void:
	var old := h.pos
	if h.mode == "walk":
		_walk(h, delta)
	else:
		_wander(h, delta)
	var mx := h.pos.x - old.x
	var mz := h.pos.z - old.z
	var moved := mx * mx + mz * mz > 0.00000025
	if moved and delta > 0.0:
		h.yaw = lerp_angle(h.yaw, atan2(mx, mz), clampf(delta * 6.0, 0.0, 1.0))
		h.pos.y = IstGeo.h(h.pos.x, h.pos.z)
	h.node.position = h.pos
	h.node.rotation.y = h.yaw
	if h.tur != "hen" and _seen(h.pos):
		IstHayatGovde.animate(h.node, _time, moved)


func _spawn_wall(g: int) -> bool:
	var pt := _P[g]
	var prol := "worker" if _rng.randf() < 0.65 else "guard"
	var ag := _free_agent([prol])
	if ag == null:
		return false
	var side := 1.0 if _rng.randf() < 0.5 else -1.0
	var e := _edge_spot(g, 1.0, side)
	if e.is_empty():
		return false
	var c: Vector2 = e["p"]
	if _crowded(c, 3.5):
		return false
	# sura (doluluk 3) bak
	var face := Vector2.INF
	for k in 12:
		var dv := Vector2.from_angle(k * TAU / 12.0)
		for dd in [3.0, 5.0, 7.0]:
			var q: Vector2 = c + dv * dd
			if sokak.cell(q.x, q.y) == 3:
				face = c + dv * 3.0
				break
		if face != Vector2.INF:
			break
	if face == Vector2.INF:
		face = c + (e["nrm"] as Vector2) * 3.0
	if prol == "worker":
		var dv := (face - c).normalized()
		var pr := _prop_for(ag)
		var rp := c + dv * 0.9
		pr.visible = true
		pr.process_mode = Node.PROCESS_MODE_INHERIT
		pr.position = Vector3(rp.x, IstGeo.h(c.x, c.y), rp.y)
		pr.rotation = Vector3(0, atan2(dv.x, dv.y), 0)
		_stand(ag, c, face, "hammer" if ag.idx % 2 == 0 else "chop")
	else:
		_stand(ag, c, face, "")
	return true


# ---------------------------------------------------------------- davranış (10 Hz)

func _think() -> void:
	var talking: bool = _hud != null and _hud.has_method("is_talking") and _hud.is_talking()
	_bark_t -= 0.1
	var p2 := _flat(_pw)
	# karşılaşan yürüyenler yan kayar (ayrı şeritte olsalar da omuz çarpmasın)
	var act: Array = []
	for ag in agents:
		if ag.active:
			act.append(ag)
	for ag: Agent in act:
		ag.look = maxf(0.0, ag.look - 0.1)
		ag.seen_player = maxf(0.0, ag.seen_player - 0.1)
		ag.customer_cd = maxf(0.0, ag.customer_cd - 0.1)
		if ag.chat > 0.0 and ag.mate != null:
			ag.chat -= 0.1
			if ag.mode == "walk" and ag.chat <= 0.0:
				ag.mate = null
			elif ag.speaker and _rng.randf() < 0.05:
				ag.speaker = false
				ag.mate.speaker = true
		var to := p2 - _flat(ag.pos)
		var d := to.length()
		if ag.mode == "walk":
			if d < 3.2 and ag.wait <= 0.0 and ag.seen_player <= 0.0:
				var ahead := ag.dirv.dot(to)
				if ahead > -0.5:
					# yana çekilip bakar
					ag.look = 1.6
					ag.wait = 1.2
					ag.seen_player = 8.0
					var perp := Vector2(ag.dirv.y, -ag.dirv.x)
					var sgn := -signf(perp.dot(to)) if absf(perp.dot(to)) > 0.05 else 1.0
					ag.off += perp * sgn * 0.5
			# tezgâhta müşteri
			elif ag.wait <= 0.0 and ag.customer_cd <= 0.0 and ag.mate == null and ag.prol != "porter":
				for v: Agent in act:
					if v.prol == "vendor" and _flat(v.pos).distance_to(_flat(ag.pos)) < 2.7:
						if _rng.randf() < 0.18:
							ag.wait = _rng.randf_range(6.0, 12.0)
							ag.face = _flat(v.pos)
							ag.customer_cd = 40.0
							ag.chat = 0.0
							v.look = 3.0
							v.face = _flat(ag.pos)
						else:
							ag.customer_cd = 6.0
						break
			# ikili yürüyüş: ara sıra durup karşılıklı sohbet
			if ag.mate != null and ag.wait <= 0.0 and ag.mate.mode == "walk" and ag.idx < ag.mate.idx and _rng.randf() < 0.004:
				var w := _rng.randf_range(5.0, 10.0)
				ag.wait = w
				ag.mate.wait = w
				ag.chat = w
				ag.mate.chat = w
				ag.speaker = true
				ag.mate.speaker = false
				ag.face = _flat(ag.mate.pos)
				ag.mate.face = _flat(ag.pos)
		else:
			if d < 7.0 and ag.seen_player <= 0.0 and ag.mate == null:
				ag.look = 3.5
				ag.seen_player = 12.0
				if ag.prol == "vendor" and not talking:
					_try_bark("SPK_TOWNSMAN", ["CL_BARK_BREAD", "CL_BARK_FRUIT", "CL_BARK_CLOTH", "CL_BARK_POTS"][ag.idx % 4])
				elif ag.prol == "fisher" and not talking:
					_try_bark("SPK_FISHMONGER", "CL_BARK_FISH")
		# bekleyen yürüyenin etkinliği
		if ag.mode == "walk":
			if ag.wait > 0.0 and ag.face != Vector2.INF and ag.mate == null and ag.chat <= 0.0:
				_set_act(ag, "arms_folded" if ag.prol != "porter" else ag.act0)
			elif ag.wait <= 0.0:
				_set_act(ag, ag.act0)
				ag.face = Vector2.INF
	# kişisel alan
	for a in act.size():
		var A: Agent = act[a]
		if A.mode != "walk":
			continue
		for b in range(a + 1, act.size()):
			var B: Agent = act[b]
			if B.mode != "walk" or A.mate == B:
				continue
			var dv := _flat(A.pos) - _flat(B.pos)
			var dl := dv.length()
			if dl < SEP_R and dl > 0.001:
				var push := dv / dl * (SEP_R - dl) * 0.5
				A.off += push
				B.off -= push


func _try_bark(spk: String, key: String) -> void:
	if _bark_t > 0.0 or _hud == null or GameState.autotest or not _hud.has_method("bark"):
		return
	if bool(_hud.get("cinematic")) or bool(_hud.get("line_open")):
		return
	if _rng.randf() > 0.55:
		_bark_t = 6.0
		return
	_bark_t = 28.0
	_hud.bark(spk, key, 3.0)


# ---------------------------------------------------------------- her kare: konum ve canlandırma

func _update(ag: Agent, delta: float) -> void:
	var old := ag.pos
	if ag.mode == "walk":
		_walk(ag, delta)
	elif ag.mode == "wander":
		_wander(ag, delta)
	var mx := ag.pos.x - old.x
	var mz := ag.pos.z - old.z
	ag.moved = mx * mx + mz * mz > 0.00000025
	var want := ag.yaw
	if bool(ag.body.get(&"talking")):
		ag.wait = maxf(ag.wait, 0.5)
	if ag.look > 0.0:
		want = atan2(_pw.x - ag.pos.x, _pw.z - ag.pos.z)
	elif ag.face != Vector2.INF and (ag.mode == "stand" or ag.wait > 0.0):
		want = atan2(ag.face.x - ag.pos.x, ag.face.y - ag.pos.z)
	elif ag.moved and delta > 0.0:
		want = atan2(mx, mz)
	ag.yaw = lerp_angle(ag.yaw, want, clampf(delta * 6.0, 0.0, 1.0))
	ag.rig_dt += delta
	var nx := ag.pos.x - _pw.x
	var nz := ag.pos.z - _pw.z
	var near := nx * nx + nz * nz < 784.0
	ag.tick = near or (_frame + ag.idx) % 3 == 0
	if ag.tick:
		_place(ag)
		var rg := ag.rig
		if rg and not _seen(ag.pos):
			return
		if rg:
			var talk := (ag.mate != null and ag.chat > 0.0 and ag.speaker) or bool(ag.body.get(&"talking"))
			rg.update(ag.rig_dt, talk, false, near)
			var m := ag.mouth
			if m:
				m.scale.y = 0.22 * (1.0 + (absf(sin(_time * 11.0)) * 0.7 if talk else 0.0) * 2.8)
				m.scale.x = rg.mouth_x
		ag.rig_dt = 0.0


func _place(ag: Agent) -> void:
	var mx := ag.pos.x - ag.shown_pos.x
	var mz := ag.pos.z - ag.shown_pos.z
	if mx * mx + mz * mz > 0.0001:
		ag.pos.y = IstGeo.h(ag.pos.x, ag.pos.z)
	if ag.pos.distance_squared_to(ag.shown_pos) > 0.000001:
		ag.shown_pos = ag.pos
		ag.body.position = ag.pos
	if not absf(angle_difference(ag.yaw, ag.shown_yaw)) <= 0.002:
		ag.shown_yaw = ag.yaw
		ag.body.rotation.y = ag.yaw


func _walk(ag: Agent, delta: float) -> void:
	if ag.wait > 0.0:
		ag.wait -= delta
		_off_step(ag, delta)
		return
	var left := ag.speed * delta
	var guard := 0
	while left > 0.0 and guard < 5:
		guard += 1
		var tgt := _P[_s0[ag.s] + ag.i + ag.d]
		var to := tgt - ag.base
		var dist := to.length()
		if dist <= left:
			ag.base = tgt
			left -= dist
			if dist > 0.01:
				ag.dirv = to / dist
			ag.prev = ag.base - ag.dirv * 1.0
			ag.i += ag.d
			if not _arrive(ag):
				_deactivate(ag)
				return
			if ag.wait > 0.0:
				break
		else:
			ag.base += to / dist * left
			ag.dirv = to / dist
			left = 0.0
	_off_step(ag, delta)


## Yanal kaymayı hedefe yaklaştır; kaymış konum yol hücresinde değilse sıfırla; yolun kendisi geçersizse sayaç
func _off_step(ag: Agent, delta: float) -> void:
	var tgt := _lane_target(ag) if ag.wait <= 0.0 else ag.off
	ag.off = ag.off.move_toward(tgt, delta * 1.4)
	var q := ag.base + ag.off
	if not _ok_cell(q.x, q.y):
		ag.off = ag.off.move_toward(Vector2.ZERO, delta * 3.0)
		q = ag.base + ag.off
		if not _ok_cell(q.x, q.y):
			q = ag.base
			ag.bad += delta
			if ag.bad > 2.0 and not _ok_cell(q.x, q.y):
				_deactivate(ag)
				return
		else:
			ag.bad = 0.0
	else:
		ag.bad = 0.0
	ag.pos.x = q.x
	ag.pos.z = q.y


## Bir noktaya varıldı (ag.i yeni nokta). false: yürüme bitti (havuza dön)
func _arrive(ag: Agent) -> bool:
	var s := ag.s
	var nxt := ag.i + ag.d
	var at_end := nxt < 0 or nxt >= _sn[s]
	var try_j := at_end or _rng.randf() < 0.3
	if try_j:
		var cs := _cands(ag.base, 4.5)
		var opts: Array = []
		for g in cs:
			if _PS[g] != s and _P[g].distance_to(ag.base) < 4.5 and sokak.cell(_P[g].x, _P[g].y) <= 1:
				opts.append(g)
		if not opts.is_empty():
			var g: int = opts[_rng.randi() % opts.size()]
			var t := _PS[g]
			var j := _PI[g]
			# yön: geldiğimiz yerden uzaklaşan komşu
			var best := 0
			var bd := -1.0
			for dd in [-1, 1]:
				var k: int = j + dd
				if k < 0 or k >= _sn[t]:
					continue
				var dist := _P[_s0[t] + k].distance_to(ag.prev)
				if dist > bd:
					bd = dist
					best = dd
			if best != 0:
				ag.s = t
				ag.i = j
				ag.d = best
				ag.base = _P[g]
				return true
		if at_end:
			ag.d = -ag.d
			ag.wait = 0.5
			if ag.i + ag.d < 0 or ag.i + ag.d >= _sn[s]:
				return false
	return true


# ---------------------------------------------------------------- denetim

## Sayım: etkin, gorunen (kamera görüş konisinde ve ≤ NEAR), kötü konumlar
func sayim() -> Dictionary:
	var etkin := 0
	var gor := 0
	var ev := 0
	var havada := 0
	var suda := 0
	var yurur := 0
	var dur := 0
	var y30 := 0
	var y60 := 0
	for ag in agents:
		if not ag.active:
			continue
		etkin += 1
		var hd := _flat(ag.pos).distance_to(_flat(_pw))
		if hd < 30.0:
			y30 += 1
		if hd < 60.0:
			y60 += 1
		if ag.mode == "walk":
			yurur += 1
		else:
			dur += 1
		var p := ag.pos
		if _flat(p).distance_to(_flat(_pw)) <= NEAR and _seen(p):
			gor += 1
		var c := sokak.cell(p.x, p.z)
		if c == 2 or c == 3 or c == 4:
			ev += 1
		if absf(p.y - IstGeo.h(p.x, p.z)) > 0.25:
			havada += 1
		if IstGeo.su(p.x, p.z):
			suda += 1
	var hay := 0
	for h in hayvanlar:
		if h.active:
			hay += 1
	return {"hayvan": hay, "y30": y30, "y60": y60, "etkin": etkin, "gorunen": gor, "yuruyen": yurur, "duran": dur, "evde": ev, "havada": havada, "suda": suda,
		"ms": prof_us / 1000.0, "ms_ort": (prof_sum_us / maxf(prof_n, 1)) / 1000.0, "ms_max": prof_max_us / 1000.0}


func sayim_satiri(ad: String) -> String:
	var s := sayim()
	print("ISTKISISAYAC ", sayac)
	return "ISTKISI %s y30=%d y60=%d gorunen=%d hayvan=%d etkin=%d yuruyen=%d duran=%d evde=%d havada=%d suda=%d ms=%.2f ms_ort=%.2f ms_max=%.2f hedef=%d" % [
		ad, s["y30"], s["y60"], s["gorunen"], s["hayvan"], s["etkin"], s["yuruyen"], s["duran"], s["evde"], s["havada"], s["suda"], s["ms"], s["ms_ort"], s["ms_max"], hedef_sayi()]


func active_list() -> Array:
	var out: Array = []
	for ag in agents:
		if ag.active:
			out.append(ag)
	return out


func kapat(v := true) -> void:
	_kapali = v
	if v:
		for ag in agents:
			if ag.active:
				_deactivate(ag)
