class_name CityLife
extends Node3D
## Yaşayan İstanbul (docs/CITY_LIFE.md §3): oyuncunun çevresinde (≈90 m) akan gerçek karakterler. Ötesinde kimse yok.
##   · Siviller (Person): satıcı (meydanda tezgâh başında), hamal (sepet, çuval, fıçı), rahip ve keşiş (siyah cüppe),
##     kadın (başörtüsü, etek), çocuk, balıkçı (limanda, oltasıyla), gece fener taşıyan. Sokak ağının kenarları
##     boyunca yürür, meydanlarda durur, ikişer sohbet eder (karşılıklı), oyuncu yaklaşınca yana çekilir ve bakar.
##   · Devriyeler (3 asker): ağda dolaşır; reis önde, ikisi arkasında; gece reisin elinde fener. Kuşatmada Bizans
##     (biri Ceneviz), fetihten sonra yeniçeri. Oyuncunun yanından geçerken durup bakar, bazen seslenir (altyazı).
##   · Ucuz: çarpışmasız, konum sokak çizgisinde (y = görünen yüzey), kararlar kenar sonunda; karakterlerin kendi
##     _process'i kapalı (Rig'i buradan sürülür, uzaktakiler seyrek). Uzaklaşan havuza döner, oyuncunun görmediği bir
##     yerde yeniden doğar. Bölümün kendi alanına (keep), suya, evin içine kimse konmaz.
## Sokak ağı CityPlan'dan (scripts/world/city_plan.gd) gelir; o yokken (ya da boşsa) şehrin içinde geçici bir kafes ağı
## kurulur. Her iki durumda da düğümler ve kenarlar ilk kullanılışta WorldWalk katılarına karşı denetlenir (ev, duvar).
## Keşif (§2): Landmarks1453 yapılarına yaklaşınca kart (Hud.discovery_card), GameState.discovered.

const NEAR := 90.0            # akışın yarıçapı
const FAR := 112.0            # bundan uzaktaki havuza döner
const SPAWN_MIN := 40.0       # görüş içindeyse en az bu uzaklıkta doğar
const CIV_N := 36
const PATROL_N := 4
const SQUAD := 3
const CELL := 32.0            # düğüm ızgarası
const STEP := 14.0            # geçici kafes ağının aralığı
const WP := 4.0               # kenar boyunca ara nokta (yükseklik) aralığı
const TEMP_W := 3.6           # geçici ağın sokak genişliği
const DISCOVER_R := 35.0
const BUILD_MS := 4
## Fetihten sonraki bölümler (yeniçeri devriyesi); diğerleri kuşatma dönemi (Osmanlı tarafı bölümlerinde de şehir
## Bizans'ındır)
const CONQUEST := ["13", "14", "26", "26o", "27", "31o", "39o"]

var world: SiegeField
var era := "siege"
var night := false
var density := 0.8
var keep: Array = []
var source := ""              # "plan" (CityPlan) ya da "temp" (geçici kafes)
var graph_ready := false
var nodes := PackedVector3Array()
var adj: Array[PackedInt32Array] = []
var wid := PackedFloat32Array()      # düğüm başına sokak genişliği
var plazas: Array = []
var landmarks: Array = []
var agents: Array[Agent] = []
## Ölçüm (CITYCHECK): son karelerin ortalama süresi (µs)
var prof_us := 0.0
## Ölçüm penceresi (CITYCHECK): toplam süre, kare sayısı, en uzun kare. Ortalama tek bir anda okunursa, 0,1 sn'de bir gelen
## düşünme karesine ne kadar yakın okunduğuna göre zıplıyordu (aynı kodla 1207–1841 µs); pencerenin ortalaması zıplamaz.
var prof_sum_us := 0.0
var prof_n := 0
var prof_max_us := 0.0

var _grid := {}
var _nstate := PackedByteArray()      # 0 bilinmez, 1 açık, 2 kapalı
var _estate := {}                     # kenar anahtarı -> bool (açık mı)
var _rng := RandomNumberGenerator.new()
var _player: Node3D
var _hud: Node
var _pw := Vector3.INF                # oyuncu (dünya çerçevesi)
var _last_pw := Vector3.INF
var _stream_t := 0.0
var _tick_t := 0.0
var _space: PhysicsDirectSpaceState3D
var _phys := false
var _budget := 0                      # bir akış adımında yapılabilecek fizik denetimi
var _bark_t := 12.0
var _disc_t := 0.0
var _disc_queue: Array = []
var _built := 0                       # kurulan gövde sayısı
var _frame := 0
var _time := 0.0
var _excl: Array = []                 # geçici ağda boş bırakılan anıt tabanları [Vector2, r]
var _stall_slots := {}                # meydan dizini -> dolu yuva dizileri


class Agent:
	var body: Node3D
	var kind := "civ"          # civ, vendor, fisher, patrol
	var role := ""
	var active := false
	var pos := Vector3.ZERO    # görünen konum (dünya)
	var base := Vector3.ZERO   # yol üstündeki konum (yana çekilmeden önce)
	var yaw := 0.0
	var a := -1
	var b := -1
	var prev := -1
	var pts := PackedVector3Array()
	var k := 0
	var speed := 1.2
	var wait := 0.0
	var lane := 0.0
	var side := 0.0            # oyuncuya yol verirken yana kayma
	var side_want := 0.0
	var dir := Vector3.FORWARD
	var mate: Agent
	var chat := 0.0
	var speaker := false
	var leader: Agent
	var squad: Array = []
	var slot := 0
	var trail := PackedVector3Array()
	var look := 0.0
	var face := Vector3.INF
	var stall: Node3D
	var plaza := -1
	var spot := -1
	var rig_dt := 0.0
	var seen_player := 0.0
	var moved := false
	var idx := 0
	var rig: Rig               # gövdenin iskeleti ve ağzı: kurulunca bir kez okunur (her kare get() ile aranıyordu)
	var mouth: MeshInstance3D
	var shown_pos := Vector3.INF   # gövdeye en son yazılan konum ve yön (değişmediyse yazılmaz)
	var shown_yaw := INF
	var tick := true           # bu kare canlandırılır ve yerine konur (yakındakiler her kare, uzaktakiler üç karede bir)
	var turn_cd := 0.0         # dar sokakta geri döndükten sonra bir süre yeniden dönmez (gidip gelmesin)


# ---------------------------------------------------------------- kurulum

## Bölümün dünyasına (World1453.build) ekler. opts: "era" ("siege" | "conquest"), "night" (bool), "density" (0..1)
static func attach(w: SiegeField, opts := {}) -> CityLife:
	if w == null or w.has_node("CityLife") or OS.has_environment("NO_CITYLIFE") or GameState.exitcheck:
		return null
	var cl := CityLife.new()
	cl.name = "CityLife"
	cl.world = w
	cl.era = str(opts.get("era", "siege"))
	cl.night = bool(opts.get("night", w.night_build))
	cl.density = clampf(float(opts.get("density", 0.8)), 0.0, 1.0)
	w.add_child(cl)
	return cl


## World1453.build kendiliğinden ekler mi: testlerin (tests/) kendi dünyaları eklenmez (belirlenimci kalsınlar);
## CITYCHECK gibi isteyen test sahnesi "citylife" işareti koyar.
static func auto_ok(parent: Node) -> bool:
	if OS.has_environment("NO_CITYLIFE") or GameState.exitcheck or parent == null or not parent.is_inside_tree():
		return false
	var sc := parent.get_tree().current_scene
	if sc and sc.scene_file_path.contains("/tests/") and not sc.has_meta("citylife"):
		return false
	return chapter_of(parent) != ""      # bölüm dışı sahneler (başlık arka planı, arena) eklemez


## Bölümün kimliği ("24", "26o"...): dünyayı kuranın ata zincirindeki bölüm sahnesinden
static func chapter_of(n: Node) -> String:
	while n != null:
		var f := n.scene_file_path
		if f.begins_with("res://scenes/chapter"):
			return f.get_file().get_basename().trim_prefix("chapter")
		n = n.get_parent()
	return ""


## Bölüme göre dönem, gece, yoğunluk
static func opts_for(parent: Node, night_build: bool) -> Dictionary:
	var ch := chapter_of(parent)
	var era := "conquest" if ch in CONQUEST else "siege"
	return {"era": era, "night": night_build, "density": density_for(era, night_build), "chapter": ch}


## Kuşatma gecesi: az sivil, fener taşıyanlar; gündüz pazar kalabalığı. Fethin ardı: halk evlerinde, sokakta devriye
static func density_for(era_name: String, is_night: bool) -> float:
	if era_name == "siege":
		return 0.5 if is_night else 0.85
	return 0.3 if is_night else 0.42


func _ready() -> void:
	_rng.seed = 1453529 + hash(world.region_name)
	keep = world.keep
	set_process(false)
	_setup.call_deferred()


func _setup() -> void:
	# Dünyanın katıları (WorldWalk) bitmeden evler denetlenemez: bekle
	var ww := world.get_node_or_null("WorldWalk") as WorldWalk
	var t := 0
	while ww and is_instance_valid(ww) and not ww.done and t < 3000:
		if not is_inside_tree():
			return          # sahne değişti (bölüm geçişi): bekleyecek ağaç yok
		await get_tree().process_frame
		t += 1
		if not is_instance_valid(world) or not is_inside_tree():
			return
	_phys = ww != null and is_instance_valid(ww) and ww.done
	# Bölüm dünyayı kurduktan sonra gündüze/geceye çevirmiş olabilir (LandWalls.make_day): pencere ışıkları söyler
	var nl: Array = world.get("_night")
	if not nl.is_empty() and is_instance_valid(nl[0]):
		var nn := (nl[0] as Node3D).visible
		if nn != night:
			night = nn
			density = density_for(era, night)
	_landmarks()
	await _graph()
	if not is_inside_tree():
		return
	graph_ready = not nodes.is_empty()
	if OS.has_environment("WORLD_PROF") or GameState.autotest:
		print("CITYLIFE region=%s src=%s era=%s night=%s density=%.2f nodes=%d plazas=%d landmarks=%d" % [world.region_name,
			source, era, night, density, nodes.size(), plazas.size(), landmarks.size()])
	_make_agents()
	set_process(true)


## Yapıyı statik olarak çağırır (sınıf yoksa null): CityPlan ve Landmarks1453 başka bir dosyada; henüz yoksa geçici
## ağla çalışılır
static var _cls_cache := {}
static func _cls(cname: String) -> Script:
	if _cls_cache.has(cname):
		return _cls_cache[cname]
	var s: Script = null
	for c in ProjectSettings.get_global_class_list():
		if str(c["class"]) == cname and ResourceLoader.exists(str(c["path"])):
			s = load(str(c["path"]))
			break
	_cls_cache[cname] = s
	return s


func _landmarks() -> void:
	landmarks = []
	var lm := _cls("Landmarks1453")
	if lm and lm.has_method("all"):
		var all = lm.call("all")
		if all is Array:
			landmarks = all
	# Geçici ağda anıt tabanları boş kalsın
	_excl = []
	for l in landmarks:
		var p: Vector3 = l.get("pos", Vector3.ZERO)
		_excl.append([Vector2(p.x, p.z), float(l.get("r", 10.0))])
	for kr: Array in [["ayasofya", 62.0], ["apostles", 34.0], ["column", 6.0], ["great_palace", 40.0]]:
		var p: Vector3 = World1453.LANDMARKS[kr[0]]
		_excl.append([Vector2(p.x, p.z), kr[1]])


func _graph() -> void:
	var plan := _cls("CityPlan")
	if plan and plan.has_method("graph"):
		var g = plan.call("graph")
		if g is Dictionary and (g.get("nodes", PackedVector3Array()) as PackedVector3Array).size() > 1:
			_use_plan(plan, g)
			return
	await _temp_graph()


func _use_plan(plan: Script, g: Dictionary) -> void:
	source = "plan"
	nodes = (g["nodes"] as PackedVector3Array).duplicate()
	var n := nodes.size()
	adj.resize(n)
	for i in n:
		adj[i] = PackedInt32Array()
	wid.resize(n)
	wid.fill(0.0)
	var ws: PackedFloat32Array = g.get("width", PackedFloat32Array())
	var edges: Array = g.get("edges", [])
	for ei in edges.size():
		var e: Vector2i = edges[ei]
		if e.x < 0 or e.y < 0 or e.x >= n or e.y >= n or e.x == e.y:
			continue
		adj[e.x].append(e.y)
		adj[e.y].append(e.x)
		var w := ws[ei] if ei < ws.size() else TEMP_W
		wid[e.x] = maxf(wid[e.x], w)
		wid[e.y] = maxf(wid[e.y], w)
	for i in n:
		if wid[i] <= 0.0:
			wid[i] = TEMP_W
	if plan.has_method("plazas"):
		var pl = plan.call("plazas")
		if pl is Array:
			plazas = pl
	_index()


## Geçici kafes ağı: şehrin içinde 14 m'lik kafes (titreşimli), suya, bölümün alanına ve anıt tabanlarına düşen
## düğümler atılır. Evlere çarpan kenarlar ilk kullanılışta elenir.
func _temp_graph() -> void:
	source = "temp"
	var ids := {}
	var tick := Time.get_ticks_msec()
	var x0 := World1453.HORN_S_X
	var z0 := -4.0
	var nx := int((700.0 - x0) / STEP) + 1
	var nz := int((z0 - World1453.TIP.z) / STEP) + 1
	for j in nz:
		for i in nx:
			var h := hash(Vector2i(i, j))
			var x := x0 + i * STEP + float(h % 1000) / 1000.0 * 5.0 - 2.5
			var z := z0 - j * STEP + float((h / 1000) % 1000) / 1000.0 * 5.0 - 2.5
			if not World1453.in_city(x, z, 7.0) or World1453.is_water(x, z) or _in_keep(x, z, 6.0) or _excluded(x, z):
				continue
			ids[Vector2i(i, j)] = nodes.size()
			nodes.append(Vector3(x, 0.0, z))
		if Time.get_ticks_msec() - tick > BUILD_MS:
			if not is_inside_tree():
				return
			await get_tree().process_frame
			tick = Time.get_ticks_msec()
			if not is_inside_tree():
				return
	adj.resize(nodes.size())
	for i in nodes.size():
		adj[i] = PackedInt32Array()
	wid.resize(nodes.size())
	wid.fill(TEMP_W)
	for key: Vector2i in ids:
		var a: int = ids[key]
		var nbs := [Vector2i(1, 0), Vector2i(0, 1)]
		if hash(key) % 3 == 0:
			nbs.append(Vector2i(1, 1))
		for o: Vector2i in nbs:
			var bk: Vector2i = key + o
			if ids.has(bk):
				var b: int = ids[bk]
				adj[a].append(b)
				adj[b].append(a)
	# Meydanlar: forumlar ve limanlar (CityPlan yokken kaba yerler; tezgâhlar ancak boş yere kurulur)
	var col: Vector3 = World1453.LANDMARKS["column"]
	var ap: Vector3 = World1453.LANDMARKS["apostles"]
	var hp: Vector3 = World1453.LANDMARKS["hippodrome"]
	plazas = [
		{"name": "constantine", "pos": col, "r": 22.0, "kind": "forum"},
		{"name": "apostles", "pos": ap + Vector3(0, 0, 48.0), "r": 18.0, "kind": "market"},
		{"name": "augustaion", "pos": hp + Vector3(-70.0, 0, -20.0), "r": 18.0, "kind": "forum"},
		{"name": "tauri", "pos": Vector3(-420.0, 0, -1100.0), "r": 20.0, "kind": "market"},
		{"name": "bovis", "pos": Vector3(-150.0, 0, -620.0), "r": 18.0, "kind": "market"},
		{"name": "lykos", "pos": Vector3(0.0, 0, -160.0), "r": 18.0, "kind": "market"},
	]
	for z: float in World1453.HORN_GATE_Z:
		plazas.append({"name": "horn_%d" % int(-z), "pos": Vector3(World1453.HORN_S_X + 10.0, 0, z), "r": 14.0, "kind": "harbor"})
	for z: float in [-300.0, -800.0, -1250.0]:
		plazas.append({"name": "marmara_%d" % int(-z), "pos": Vector3(World1453.marmara_x(z) - 10.0, 0, z), "r": 14.0, "kind": "harbor"})
	_index()


func _index() -> void:
	var cells := {}
	for i in nodes.size():
		var c := Vector2i(floori(nodes[i].x / CELL), floori(nodes[i].z / CELL))
		if not cells.has(c):
			cells[c] = []
		(cells[c] as Array).append(i)
	_grid = {}
	for c: Vector2i in cells:
		_grid[c] = PackedInt32Array(cells[c])
	_nstate.resize(nodes.size())
	_nstate.fill(0)


func _in_keep(x: float, z: float, margin: float) -> bool:
	for r in keep:
		if (r as Rect2).grow(margin).has_point(Vector2(x, z)):
			return true
	return false


func _excluded(x: float, z: float) -> bool:
	for e: Array in _excl:
		if (e[0] as Vector2).distance_to(Vector2(x, z)) < float(e[1]):
			return true
	var hp: Vector3 = World1453.LANDMARKS["hippodrome"]
	return absf(x - hp.x) < 48.0 and absf(z - hp.z) < 118.0


# ---------------------------------------------------------------- denetim (evler, su, alan)

func _g(p: Vector3) -> Vector3:
	return world.global_transform * p


func _surf(x: float, z: float) -> float:
	return World1453.surface_h(x, z)


## Bu noktada ayakta durulur mu: alan dışı, kara, evin/duvarın içi değil, üstünde çatı yok
func _spot_open(p: Vector3) -> bool:
	if not World1453.in_city(p.x, p.z, 4.0) or World1453.is_water(p.x, p.z) or _in_keep(p.x, p.z, 5.0):
		return false
	if not _phys:
		return true
	_budget -= 1
	if _space == null:
		_space = get_world_3d().direct_space_state
	var ex: Array[RID] = []
	if _player is CollisionObject3D:
		ex.append((_player as CollisionObject3D).get_rid())
	var q := PhysicsPointQueryParameters3D.new()
	q.collision_mask = 1
	q.exclude = ex
	for hy: float in [0.9, 1.9]:
		q.position = _g(p + Vector3(0, hy, 0))
		if not _space.intersect_point(q, 1).is_empty():
			return false
	var rq := PhysicsRayQueryParameters3D.create(_g(p + Vector3(0, 16.0, 0)), _g(p + Vector3(0, -3.0, 0)), 1, ex)
	var hit := _space.intersect_ray(rq)
	if hit.is_empty():
		return false
	var hy2: float = (world.global_transform.affine_inverse() * (hit["position"] as Vector3)).y
	return absf(hy2 - p.y) < 0.6


func _node_open(i: int) -> bool:
	if _nstate[i] == 0:
		var p := nodes[i]
		p.y = _surf(p.x, p.z)
		nodes[i] = p
		_nstate[i] = 1 if _spot_open(p) else 2
	return _nstate[i] == 1


func _ekey(a: int, b: int) -> int:
	return mini(a, b) * 1048576 + maxi(a, b)


## Kenar açık mı: ara noktalarda diz-bel hizasında, ortada ve iki yanda yatay ışın (zemine değen ışınlar sayılmaz)
func _edge_open(a: int, b: int) -> bool:
	var key := _ekey(a, b)
	if _estate.has(key):
		return _estate[key]
	if not _node_open(a) or not _node_open(b):
		_estate[key] = false
		return false
	var ok := true
	var pa := nodes[a]
	var pb := nodes[b]
	var len := Vector2(pb.x - pa.x, pb.z - pa.z).length()
	var n := maxi(1, ceili(len / WP))
	var perp := Vector3(pb.z - pa.z, 0, -(pb.x - pa.x)).normalized() * 0.7
	var prev := pa
	for s in range(1, n + 1):
		var q := pa.lerp(pb, float(s) / n)
		q.y = _surf(q.x, q.z)
		if World1453.is_water(q.x, q.z) or _in_keep(q.x, q.z, 4.0) or not World1453.in_city(q.x, q.z, 4.0):
			ok = false
			break
		if _phys:
			for off: Vector3 in [Vector3.ZERO, perp, -perp]:
				if _ray_blocked(prev + off + Vector3(0, 1.0, 0), q + off + Vector3(0, 1.0, 0)):
					ok = false
					break
			if not ok:
				break
		prev = q
	_budget -= 1
	_estate[key] = ok
	return ok


func _ray_blocked(a: Vector3, b: Vector3) -> bool:
	if _space == null:
		_space = get_world_3d().direct_space_state
	var ex: Array[RID] = []
	if _player is CollisionObject3D:
		ex.append((_player as CollisionObject3D).get_rid())
	var hit := _space.intersect_ray(PhysicsRayQueryParameters3D.create(_g(a), _g(b), 1, ex))
	if hit.is_empty():
		return false
	var nrm := world.global_transform.basis.inverse() * (hit["normal"] as Vector3)
	return absf(nrm.y) < 0.6


func _open_nbrs(i: int) -> PackedInt32Array:
	var out := PackedInt32Array()
	for j in adj[i]:
		if _budget <= 0 and not _estate.has(_ekey(i, j)):
			continue
		if _edge_open(i, j):
			out.append(j)
	return out


# ---------------------------------------------------------------- havuz

func _make_agents() -> void:
	# Roller: gece ve fetihten sonra sokakta daha az kadın ve çocuk, daha çok fener
	var roles: Array = []
	roles.append_array(["vendor", "vendor", "vendor", "vendor", "vendor"])
	roles.append_array(["fisher", "fisher", "fisher"])
	roles.append_array(["porter", "porter", "porter", "porter"])
	roles.append_array(["priest", "priest", "monk"])
	roles.append_array(["woman", "woman", "woman", "woman", "woman", "woman", "woman"])
	roles.append_array(["child", "child", "child"])
	roles.append_array(["man", "man", "man", "man", "man", "man", "man", "man"])
	roles.append_array(["lantern", "lantern", "lantern"] if night else ["man", "woman", "porter"])
	for i in CIV_N:
		var ag := Agent.new()
		ag.role = roles[i % roles.size()]
		ag.kind = "vendor" if ag.role == "vendor" else ("fisher" if ag.role == "fisher" else "civ")
		ag.speed = _rng.randf_range(0.95, 1.35) * (0.8 if ag.role in ["priest", "monk"] else 1.0)
		ag.idx = agents.size()
		agents.append(ag)
	for p in PATROL_N:
		var ld: Agent = null
		for s in SQUAD:
			var ag := Agent.new()
			ag.kind = "patrol"
			ag.role = "leader" if s == 0 else "guard"
			ag.slot = s
			ag.speed = 1.15
			ag.squad = [p]
			if s == 0:
				ld = ag
			else:
				ag.leader = ld
				ld.squad.append(ag)
			ag.idx = agents.size()
			agents.append(ag)


## Bir sivilin görünüşü (rol ve döneme göre)
func _civ_body(ag: Agent, idx: int) -> Node3D:
	var r := RandomNumberGenerator.new()
	r.seed = 7001 + idx * 131
	var earth := [Color("6a5038"), Color("7a6a50"), Color("5a5a48"), Color("8a6a4a"), Color("6a4a3a"), Color("4a5a6a"), Color("8a7a5a"), Color("5a4a40")]
	var bright := [Color("a84a3a"), Color("3a6a8a"), Color("7a8a4a"), Color("b8885a"), Color("6a4a7a"), Color("c8a868")]
	var pants := [Color("3a3028"), Color("4a3a2a"), Color("2a2a30"), Color("5a4a3a")]
	var coat: Color = earth[r.randi() % earth.size()]
	var p := {"coat": coat, "pants": pants[r.randi() % pants.size()], "n": 3000 + idx}
	match ag.role:
		"vendor":
			p["coat"] = bright[r.randi() % bright.size()]
			p["apron"] = Color("e8dcc0")
			p["mustache"] = r.randf() < 0.6
			p["beard"] = r.randf() < 0.4
			if era == "conquest" and r.randf() < 0.5:
				p["hat"] = "turban"
		"fisher":
			p["coat"] = [Color("3a5a7a"), Color("5a6a6a"), Color("6a5a48")][r.randi() % 3]
			p["hat"] = "hood" if r.randf() < 0.3 else "none"
			p["beard"] = r.randf() < 0.6
		"porter":
			p["coat"] = [Color("8a7050"), Color("7a6040"), Color("6a6050")][r.randi() % 3]
			p["mustache"] = true
		"priest":
			p["coat"] = Color("1e1c1e")
			p["pants"] = Color("1e1c1e")
			p["robe"] = Color("1e1c1e")
			p["hat"] = "priest"
			p["beard"] = true
			p["hair"] = [Color("2a2420"), Color("6a6662"), Color("8a8682")][r.randi() % 3]
		"monk":
			p["coat"] = Color("2a2226")
			p["pants"] = Color("2a2226")
			p["robe"] = Color("2a2226")
			p["hat"] = "hood"
			p["beard"] = true
		"woman":
			p["coat"] = bright[r.randi() % bright.size()].darkened(0.15)
			p["pants"] = [Color("5a3a4a"), Color("3a4a5a"), Color("6a5a3a"), Color("4a3a30")][r.randi() % 4]
			p["skirt"] = true
			p["hat"] = "scarf" if r.randf() < 0.75 else "bun"
			p["scarf"] = [Color("e8e0d0"), Color("3a3a5a"), Color("8a3a3a"), Color("5a6a4a"), Color("c8b088")][r.randi() % 5]
		"child":
			p["coat"] = bright[r.randi() % bright.size()]
			p["child"] = true
		"lantern":
			p["coat"] = earth[r.randi() % earth.size()].darkened(0.1)
			p["hat"] = "hood" if r.randf() < 0.5 else "none"
			p["mustache"] = r.randf() < 0.5
		_:
			p["mustache"] = r.randf() < 0.6
			p["beard"] = r.randf() < 0.45
			if era == "conquest" and r.randf() < 0.3:
				p["hat"] = "turban"
			elif r.randf() < 0.15:
				p["hat"] = "hood"
	var pr := Person.new(p)
	pr.set_meta("no_chat", true)
	pr.set_meta("citylife", true)
	return pr


## Devriye askeri: kuşatmada Bizans (miğfer, zırh; dördüncü devriye Cenevizli), fetihten sonra yeniçeri (börk)
func _patrol_body(ag: Agent, idx: int) -> Node3D:
	var squad: int = ag.squad[0] if ag.leader == null else ag.leader.squad[0]
	var lantern := night and ag.slot == 0
	if era == "conquest":
		var s := Soldier.new([Color("2f5fa8"), Color("b3262d"), Color("3a6b3a"), Color("6a4a3a")][squad % 4], "stand", "bork")
		s.set_meta("citylife", true)
		if lantern:
			s.ready.connect(func(): _lantern(s._elbow_r), CONNECT_ONE_SHOT)
		else:
			s.equip("spear")
		return s
	var genoese := squad == 3
	var coat: Color = Color("a8aeb6") if genoese else Crowd.BYZ_COATS[(squad * 2 + ag.slot) % Crowd.BYZ_COATS.size()]
	var p := Person.new({"coat": coat, "pants": Color("6a2a2a") if genoese else Color("3a2a22"), "hat": "helm",
		"beard": (idx % 3) != 1, "mustache": idx % 2 == 0, "n": 4000 + idx, "armor": "mail" if genoese else ""})
	p.set_meta("no_chat", true)
	p.set_meta("citylife", true)
	if lantern:
		p.equip("fanari")
	else:
		p.equip("spear_shield" if ag.slot == 0 else "spear", Color("b8262a") if genoese else Color("7a2a24"))
	return p


## Elde taşınan fener (yeniçeri devriyesinin reisi): demir kafes, sıcak ışık
func _lantern(elbow: Node3D) -> void:
	if elbow == null:
		return
	var ln := Node3D.new()
	ln.name = "Lantern"
	elbow.add_child(ln)
	ln.position = Vector3(0, -0.42, 0.06)
	Props.cyl(ln, 0.012, 0.16, Vector3(0, 0.1, 0), Color("2a2622"), Vector3.ZERO, 4)
	Props.cyl(ln, 0.1, 0.04, Vector3(0, 0.0, 0), Color("3a3430"), Vector3.ZERO, 8, 0.03)
	var gl := Props.cyl(ln, 0.08, 0.22, Vector3(0, -0.14, 0), Color("ffd890"), Vector3.ZERO, 8)
	gl.material_override = Props.mat(Color("ffcf80"), 1.8, false, "", false)
	Props.cyl(ln, 0.1, 0.03, Vector3(0, -0.26, 0), Color("3a3430"), Vector3.ZERO, 8)
	var l := OmniLight3D.new()
	l.position = Vector3(0, -0.14, 0)
	l.light_color = Color("ffb868")
	l.light_energy = 1.7
	l.omni_range = 7.0
	ln.add_child(l)


## Rolün eşyası (gövde kurulduktan sonra)
func _dress(ag: Agent) -> void:
	var p := ag.body as Person
	if p == null:
		return
	match ag.role:
		"porter":
			p.carry(["basket", "sack", "barrel", "crate"][ag.idx % 4])
		"lantern":
			p.equip("lamp")
		"fisher":
			# Olta: sağ elde uzun ince kamış, ucunda ip
			var rod := Node3D.new()
			p._elbow_r.add_child(rod)
			rod.position = Vector3(0, -0.28, 0.06)
			rod.rotation_degrees = Vector3(62, 0, 0)
			Props.cyl(rod, 0.016, 3.0, Vector3(0, 1.4, 0), Color("8a6a3a"), Vector3.ZERO, 4, 0.006)
			Props.cyl(rod, 0.003, 1.6, Vector3(0, 2.5, 0.6), Color("d8d0c0"), Vector3(-62, 0, 0), 3)
	if ag.role == "child":
		p.scale = Vector3.ONE * 0.62


func _ensure_body(ag: Agent) -> bool:
	if ag.body != null:
		return true
	if _built_this_frame >= 3:
		return false
	_built_this_frame += 1
	var idx := ag.idx
	ag.body = _patrol_body(ag, idx) if ag.kind == "patrol" else _civ_body(ag, idx)
	ag.body.name = "Life%d" % idx
	ag.body.visible = false
	ag.body.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(ag.body)
	ag.body.set_process(false)   # Rig'i CityLife sürer (yol açma ve ortam sohbeti döngüleri çalışmaz)
	_dress(ag)
	ag.rig = ag.body.get("rig") as Rig
	ag.mouth = ag.body.get("_mouth") as MeshInstance3D
	_built += 1
	return true

var _built_this_frame := 0


func _activate(ag: Agent) -> void:
	ag.active = true
	ag.body.process_mode = Node.PROCESS_MODE_INHERIT
	ag.body.set_process(false)
	ag.body.visible = true
	ag.body.position = ag.pos
	ag.body.rotation = Vector3(0, ag.yaw, 0)
	ag.shown_pos = ag.pos
	ag.shown_yaw = ag.yaw
	if ag.rig:
		ag.rig.speed = 0.0
	ag.rig_dt = 0.0
	ag.side = 0.0
	ag.side_want = 0.0
	ag.look = 0.0
	ag.trail = PackedVector3Array([ag.pos])


func _deactivate(ag: Agent) -> void:
	ag.active = false
	ag.mate = null
	ag.chat = 0.0
	if ag.body:
		ag.body.visible = false
		ag.body.process_mode = Node.PROCESS_MODE_DISABLED
	if ag.stall:
		ag.stall.visible = false
		ag.stall.process_mode = Node.PROCESS_MODE_DISABLED
	if ag.plaza >= 0 and _stall_slots.has(ag.plaza):
		(_stall_slots[ag.plaza] as Array).erase(ag.spot)
	ag.plaza = -1
	ag.spot = -1


# ---------------------------------------------------------------- akış

func _process(delta: float) -> void:
	var t0 := Time.get_ticks_usec()
	_time += delta
	_frame += 1
	_built_this_frame = 0
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D
	if _hud == null or not is_instance_valid(_hud):
		_hud = get_tree().get_first_node_in_group("hud")
	if _player == null or not is_instance_valid(world):
		return
	_pw = world.global_transform.affine_inverse() * _player.global_position
	# Havuz ısınır: şehre ~700 m kala karede bir gövde kurulur (yaklaşınca hepsi hazır, gölgelendiriciler ısınmış) (ilk doğuşta hepsi hazır olsun)
	if graph_ready and _built < agents.size() and World1453.in_city(_pw.x, _pw.z, -NEAR * 8.0):
		for ag in agents:
			if ag.body == null:
				_ensure_body(ag)
				break
	_stream_t -= delta
	if _stream_t <= 0.0:
		_stream_t = 0.5
		_stream()
	_tick_t -= delta
	var tick := _tick_t <= 0.0
	if tick:
		_tick_t = 0.1
		_think()
	_disc_t -= delta
	if _disc_t <= 0.0:
		_disc_t = 0.5
		_discover()
	for ag in agents:
		if ag.active:
			_update(ag, delta)
	_separate(delta)
	var us := float(Time.get_ticks_usec() - t0)
	prof_us = lerpf(prof_us, us, 0.05) if prof_us > 0.0 else us
	prof_sum_us += us
	prof_n += 1
	prof_max_us = maxf(prof_max_us, us)


## Kişisel alan (her kare): 0,6 m'den yakın iki kişi ayrılır (karşılaşan, aynı adımla yan yana yürüyen, reisin dönüşünde
## yer değiştiren devriye askerleri iç içe girmesin). Sivil ve reis yolundaki yerinden (base) kayar, yola yavaşça döner;
## takımdaki asker yerinden kayar, reisin izine yine yetişir. Kaydığı yer bir evin, duvarın içiyse kaymaz.
const SEP_R := 0.6

func _separate(delta: float) -> void:
	var grid := {}
	for ag in agents:
		if ag.active:
			var c := Vector2i(floori(ag.pos.x), floori(ag.pos.z))
			if grid.has(c):
				(grid[c] as Array).append(ag)
			else:
				grid[c] = [ag]
	var cap := 2.5 * delta
	for ag in agents:
		if not ag.active:
			continue
		ag.turn_cd = maxf(0.0, ag.turn_cd - delta)
		var c := Vector2i(floori(ag.pos.x), floori(ag.pos.z))
		var push := Vector3.ZERO
		var onto: Agent = null       # iç içe girdiği (0,35 m) biri
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				for o in grid.get(c + Vector2i(dx, dz), []):
					if o == ag or absf(o.pos.y - ag.pos.y) > 1.0:
						continue
					var rel := Vector3(ag.pos.x - o.pos.x, 0, ag.pos.z - o.pos.z)
					var d := rel.length()
					if d >= SEP_R:
						continue
					if d < 0.35:
						onto = o
					if d < 0.01:
						var a := 0.7 if ag.idx < o.idx else 0.7 + PI
						rel = Vector3(sin(a), 0, cos(a))
						d = 0.01
					push += rel / d * (SEP_R - d) * 0.5
		if push == Vector3.ZERO:
			continue
		push = push.limit_length(cap)
		if _phys and not _sep_open(ag.pos + push):
			# Duvar tarafına itilemiyor: yana (sokak boyunca) kayar; o da kapalıysa öbür yana (eskiden hiç
			# kaymıyordu, ev duvarının dibinde iki kişi iç içe kalıyordu)
			# Köşede (iki duvar) yanlar da kapalıysa çaprazlar denenir (köşede iki kişi iç içe kalıyordu)
			var side := Vector3(-push.z, 0, push.x)
			var found := false
			for cand: Vector3 in [side, -side, (push + side) * 0.7, (push - side) * 0.7]:
				if _sep_open(ag.pos + cand):
					push = cand
					found = true
					break
			if not found:
				# Dar sokakta karşı karşıya: iki yan da duvar, ikisi iç içe kalıyordu (kara surunun ardındaki x 37 sokağı,
				# 20/26/37o VISAUDIT overlap). Sırası büyük olan geri döner.
				if onto != null and ag.idx > onto.idx and ag.kind == "civ" and ag.turn_cd <= 0.0:
					_turn_back(ag)
				continue
		if ag.kind == "patrol" and ag.slot > 0:
			ag.pos += push
		else:
			ag.base += push
			ag.pos += push
		if ag.body and ag.tick:
			_place(ag)


## Geri dönüş: kenarın iki ucu yer değiştirir; yeni yolda bulunduğu yerin önündeki ilk noktadan devam eder (başa
## ışınlanmaz)
func _turn_back(ag: Agent) -> void:
	if ag.a < 0 or ag.b < 0 or ag.a == ag.b:
		return
	var t := ag.a
	ag.a = ag.b
	ag.b = t
	ag.prev = -1
	_start_edge(ag)
	var k := ag.pts.size() - 1
	for i in ag.pts.size():
		var to := ag.pts[i] - ag.base
		if Vector2(to.x, to.z).dot(Vector2(ag.dir.x, ag.dir.z)) > 0.2:
			k = i
			break
	ag.k = k
	ag.wait = 0.0
	ag.turn_cd = 4.0


func _sep_open(p: Vector3) -> bool:
	if _space == null:
		_space = get_world_3d().direct_space_state
	var q := PhysicsPointQueryParameters3D.new()
	q.collision_mask = 1
	if _player is CollisionObject3D:
		q.exclude = [(_player as CollisionObject3D).get_rid()]
	q.position = _g(p + Vector3(0, 0.9, 0))
	return _space.intersect_point(q, 1).is_empty()


## Yarıçap dışındakiler havuza döner; havuzdakiler oyuncunun çevresinde (görmediği yerde) doğar
func _stream() -> void:
	if not graph_ready:
		return
	_budget = 60
	var jump := _last_pw == Vector3.INF or _flat(_pw).distance_to(_flat(_last_pw)) > 40.0
	_last_pw = _pw
	for ag in agents:
		if ag.active and ag.kind != "patrol" and _flat(ag.pos).distance_to(_flat(_pw)) > FAR:
			_deactivate(ag)
	# Devriye: reis uzaklaştıysa bütün takım döner
	for ag in agents:
		if ag.kind == "patrol" and ag.slot == 0 and ag.active and _flat(ag.pos).distance_to(_flat(_pw)) > FAR:
			_deactivate(ag)
			for f: Agent in _followers(ag):
				_deactivate(f)
	# Oyuncu şehrin çok dışındaysa (ordugâh, Galata, deniz) kimse doğmaz
	if not World1453.in_city(_pw.x, _pw.z, -NEAR) or _pw.y < World1453.SEA_Y - 3.0:
		return
	var want_civ := roundi(CIV_N * density)
	var n_civ := 0
	for ag in agents:
		if ag.kind != "patrol" and ag.active:
			n_civ += 1
	var want_pat := PATROL_N if (night or era == "conquest") else PATROL_N - 1
	var n_pat := 0
	for ag in agents:
		if ag.kind == "patrol" and ag.slot == 0 and ag.active:
			n_pat += 1
	var spawned := 0
	var cap := 12 if jump else 3
	# Devriyeler önce (az ve görünür olmalılar); sivillerin denetim bütçesi ayrı
	for ag in agents:
		if _budget <= 0 or n_pat >= want_pat:
			break
		if ag.kind != "patrol" or ag.slot != 0 or ag.active:
			continue
		var fl := _followers(ag)
		var all_built := _ensure_body(ag)
		for f: Agent in fl:
			all_built = _ensure_body(f) and all_built
		if not all_built:
			continue
		if _spawn_patrol(ag, fl, jump):
			n_pat += 1
			spawned += 1
	_budget = 60
	# Sıra her seferinde başka yerden başlar (aynı roller hep önce doğmasın); satıcı ve balıkçı ancak yakında
	# meydan/liman varsa
	var order := range(agents.size())
	for q in range(order.size() - 1, 0, -1):
		var r := _rng.randi() % (q + 1)
		var tmp: int = order[q]
		order[q] = order[r]
		order[r] = tmp
	for q: int in order:
		var ag := agents[q]
		if spawned >= cap or _budget <= 0:
			break
		if ag.active or ag.kind == "patrol" or n_civ >= want_civ:
			continue
		if not _ensure_body(ag):
			continue
		var ok := false
		if ag.kind == "vendor" or ag.kind == "fisher":
			ok = _spawn_stand(ag, jump)
		else:
			ok = _spawn_walker(ag, jump)
		if ok:
			n_civ += 1
			spawned += 1


func _followers(ld: Agent) -> Array:
	return ld.squad.slice(1)


func _flat(p: Vector3) -> Vector2:
	return Vector2(p.x, p.z)


func _in_view(p: Vector3) -> bool:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return false
	var gp := _g(p + Vector3(0, 1.0, 0))
	var to := gp - cam.global_position
	if to.length() < 0.1:
		return true
	return (-cam.global_basis.z).dot(to.normalized()) > 0.45


## Oyuncunun çevresinde boş, açık bir düğüm
func _pick_node(jump: bool, min_d := -1.0) -> int:
	var c := Vector2i(floori(_pw.x / CELL), floori(_pw.z / CELL))
	var r := ceili(NEAR / CELL)
	var lo := min_d if min_d >= 0.0 else (6.0 if jump else SPAWN_MIN)
	for t in 24:
		if _budget <= 0:
			return -1
		var cell := c + Vector2i(_rng.randi_range(-r, r), _rng.randi_range(-r, r))
		var ids: PackedInt32Array = _grid.get(cell, PackedInt32Array())
		if ids.is_empty():
			continue
		var i := ids[_rng.randi() % ids.size()]
		var d := _flat(nodes[i]).distance_to(_flat(_pw))
		if d > NEAR - 8.0 or d < lo:
			continue
		if not jump and d < 75.0 and _in_view(nodes[i]):
			continue
		if _nstate[i] == 2 or _crowded(nodes[i], 1.6):
			continue
		if not _node_open(i) or _open_nbrs(i).is_empty():
			continue
		return i
	return -1


func _crowded(p: Vector3, r: float) -> bool:
	for o in agents:
		if o.active and _flat(o.pos).distance_to(_flat(p)) < r:
			return true
	return false


func _spawn_walker(ag: Agent, jump: bool) -> bool:
	var i := _pick_node(jump)
	if i < 0:
		return false
	var nb := _open_nbrs(i)
	ag.a = i
	ag.prev = -1
	ag.b = nb[_rng.randi() % nb.size()]
	ag.lane = _rng.randf_range(-1.0, 1.0) * _lane_max(i)
	ag.wait = _rng.randf_range(0.0, 2.0)
	_start_edge(ag)
	# Kenarın üstünde rastgele bir yerde (ağ seyrekse herkes kavşakta doğmasın)
	ag.k = _rng.randi_range(0, maxi(0, ag.pts.size() - 2))
	ag.base = ag.pts[ag.k]
	if _crowded(ag.base, 1.5) or _flat(ag.base).distance_to(_flat(_pw)) > NEAR - 4.0:
		ag.k = 0
		ag.base = ag.pts[0]
		if _crowded(ag.base, 0.8):
			return false        # kavşakta biri duruyor: onun içinde doğmasın (sonra yeniden denenir)
	ag.pos = ag.base
	var nx := ag.pts[mini(ag.k + 1, ag.pts.size() - 1)]
	ag.yaw = atan2(nx.x - ag.base.x, nx.z - ag.base.z)
	_activate(ag)
	# Bazen ikisi birlikte doğar ve sohbet eder (karşılıklı)
	if ag.role in ["woman", "man", "priest", "porter"] and _rng.randf() < 0.3:
		for o in agents:
			if o.active or o.kind != "civ" or o == ag or o.role in ["child", "lantern"] or o.body == null:
				continue
			_pair(ag, o)
			break
	return true


func _pair(ag: Agent, o: Agent) -> void:
	var perp := Vector3(cos(ag.yaw), 0, -sin(ag.yaw))
	var p := ag.base + perp * 1.3
	p.y = _surf(p.x, p.z)
	if not _spot_open(p) or _crowded(p, 0.8):
		return
	o.a = ag.a
	o.b = ag.b
	o.prev = -1
	o.lane = ag.lane
	_start_edge(o)
	o.base = p
	o.pos = p
	o.yaw = ag.yaw
	_activate(o)
	var t := _rng.randf_range(7.0, 16.0)
	ag.mate = o
	o.mate = ag
	ag.chat = t
	o.chat = t
	ag.speaker = true
	o.speaker = false
	ag.wait = t
	o.wait = t + 0.4


func _spawn_patrol(ld: Agent, fl: Array, jump: bool) -> bool:
	var i := _pick_node(jump, 14.0 if jump else -1.0)
	if i < 0:
		return false
	var nb := _open_nbrs(i)
	ld.a = i
	ld.prev = -1
	ld.b = nb[_rng.randi() % nb.size()]
	ld.lane = 0.0
	ld.wait = 0.0
	_start_edge(ld)
	ld.base = ld.pts[0]
	ld.pos = ld.base
	ld.yaw = atan2(ld.pts[mini(1, ld.pts.size() - 1)].x - ld.base.x, ld.pts[mini(1, ld.pts.size() - 1)].z - ld.base.z)
	_activate(ld)
	# Takım reisin arkasında, yolun geldiği yönde dizilir
	var back := -Vector3(sin(ld.yaw), 0, cos(ld.yaw))
	ld.trail = PackedVector3Array([ld.pos + back * 4.0, ld.pos])
	for f: Agent in fl:
		var off := _form(ld, f.slot)
		f.pos = off[0]
		f.base = f.pos
		f.yaw = ld.yaw
		_activate(f)
		f.trail = PackedVector3Array()
	return true


## Kenarın ara noktaları (şeritte, yüzeyde)
func _start_edge(ag: Agent) -> void:
	var pa := nodes[ag.a]
	var pb := nodes[ag.b]
	pa.y = _surf(pa.x, pa.z)
	var d := Vector3(pb.x - pa.x, 0, pb.z - pa.z)
	var len := d.length()
	var perp := Vector3(d.z, 0, -d.x).normalized() if len > 0.01 else Vector3.RIGHT
	var n := maxi(1, ceili(len / WP))
	ag.pts = PackedVector3Array()
	for s in n + 1:
		var q := pa.lerp(pb, float(s) / n) + perp * ag.lane
		q.y = _surf(q.x, q.z)
		ag.pts.append(q)
	ag.k = 0
	ag.dir = d.normalized() if len > 0.01 else ag.dir


func _lane_max(i: int) -> float:
	return clampf(wid[i] * 0.3, 0.0, 0.6 if source == "temp" else 2.2)


## Düğüme varış: sonraki kenar (geri dönmeden, düze yakın), bazen durur; meydanda daha çok
func _arrive(ag: Agent) -> bool:
	var at := ag.b
	var nb := _open_nbrs(at)
	if nb.is_empty():
		if _budget <= 0:
			_budget = 6          # kararsız kalmasın: bu düğümün kenarlarını denetle
			nb = _open_nbrs(at)
		if nb.is_empty():
			ag.wait = 1.0
			ag.a = at
			ag.b = ag.a if ag.prev < 0 else ag.prev
			if ag.b == ag.a:
				return false
			_start_edge(ag)
			return true
	var best := -1
	var bw := -INF
	for j in nb:
		if j == ag.a and nb.size() > 1:
			continue
		var d := Vector3(nodes[j].x - nodes[at].x, 0, nodes[j].z - nodes[at].z).normalized()
		var w := d.dot(ag.dir) * (1.4 if ag.kind == "patrol" else 0.8) + _rng.randf() * 1.2
		if w > bw:
			bw = w
			best = j
	ag.prev = ag.a
	ag.a = at
	ag.b = best
	if ag.lane != 0.0:
		ag.lane = clampf(ag.lane, -_lane_max(at), _lane_max(at))
	_start_edge(ag)
	if ag.kind == "civ":
		var at_plaza := _plaza_at(nodes[at]) >= 0
		if _rng.randf() < (0.4 if at_plaza else 0.12):
			ag.wait = _rng.randf_range(3.0, 8.0) if at_plaza else _rng.randf_range(1.0, 3.5)
			if _rng.randf() < 0.3 and ag.body.has_method("emote") and not GameState.autotest:
				ag.body.emote(["nod", "shrug", "wave"][_rng.randi() % 3])
	return true


func _plaza_at(p: Vector3) -> int:
	for i in plazas.size():
		var pl: Dictionary = plazas[i]
		var c: Vector3 = pl["pos"]
		if _flat(c).distance_to(_flat(p)) < float(pl.get("r", 15.0)):
			return i
	return -1


## Satıcı (meydanda tezgâh) ya da balıkçı (limanda): yakındaki uygun meydanın bir yuvasında
func _spawn_stand(ag: Agent, jump: bool) -> bool:
	var kinds := ["harbor"] if ag.kind == "fisher" else ["market", "forum"]
	for pi in plazas.size():
		var pl: Dictionary = plazas[pi]
		if not str(pl.get("kind", "")) in kinds:
			continue
		var c: Vector3 = pl["pos"]
		var d := _flat(c).distance_to(_flat(_pw))
		if d > NEAR - 10.0 or _in_keep(c.x, c.z, 8.0):
			continue
		var used: Array = _stall_slots.get(pi, [])
		var nslot := 6 if ag.kind == "vendor" else 4
		for s in nslot:
			if s in used or _budget <= 0:
				continue
			var spot := _stand_spot(ag, pl, pi, s)
			if spot.is_empty():
				used.append(s)          # bu yuva kapalı (ev, su): bir daha denenmez
				_stall_slots[pi] = used
				continue
			var p: Vector3 = spot["pos"]
			if not jump and _flat(p).distance_to(_flat(_pw)) < 30.0 and _in_view(p):
				continue
			used.append(s)
			_stall_slots[pi] = used
			ag.plaza = pi
			ag.spot = s
			ag.pos = p
			ag.base = p
			ag.face = spot["face"]
			ag.yaw = atan2(ag.face.x - p.x, ag.face.z - p.z)
			ag.wait = 0.0
			_activate(ag)
			if ag.kind == "vendor":
				_place_stall(ag, spot["stall"], ag.yaw)
			return true
	return false


## Yuvanın yeri: satıcı tezgâhın ardında, meydanın ortasına bakar; balıkçı suya bakar
func _stand_spot(ag: Agent, pl: Dictionary, pi: int, s: int) -> Dictionary:
	var c: Vector3 = pl["pos"]
	var r := float(pl.get("r", 15.0))
	var h := hash(Vector2i(pi, s))
	var ang := s * TAU / 6.0 + float(h % 100) / 100.0 * 0.6
	if ag.kind == "vendor":
		var ring := maxf(4.0, r * 0.62)
		var sp := c + Vector3(sin(ang), 0, cos(ang)) * ring
		var vp := c + Vector3(sin(ang), 0, cos(ang)) * (ring + 1.1)
		sp.y = _surf(sp.x, sp.z)
		vp.y = _surf(vp.x, vp.z)
		if not _spot_open(sp) or not _spot_open(vp) or _crowded(sp, 2.5):
			return {}
		# Tezgâhın iki ucu da açık olsun
		var perp := Vector3(cos(ang), 0, -sin(ang))
		for e: float in [-1.0, 1.0]:
			var q := sp + perp * e
			q.y = _surf(q.x, q.z)
			if not _spot_open(q):
				return {}
		return {"pos": vp, "stall": sp, "face": c}
	# Balıkçı: kıyıya doğru (en yakın su yönü) birkaç metre
	var wdir := Vector3.ZERO
	for k in 8:
		var a := k * TAU / 8.0
		var q := c + Vector3(sin(a), 0, cos(a)) * 30.0
		if World1453.is_water(q.x, q.z):
			wdir = Vector3(sin(a), 0, cos(a))
			break
	if wdir == Vector3.ZERO:
		return {}
	var side := Vector3(wdir.z, 0, -wdir.x)
	for back: float in [4.0, 7.0, 10.0]:
		var p := c + side * ((s - 1.5) * 3.2) + wdir * (8.0 - back)
		p.y = _surf(p.x, p.z)
		if World1453.in_city(p.x, p.z, 3.0) and _spot_open(p) and not _crowded(p, 1.5):
			return {"pos": p, "face": p + wdir * 10.0}
	return {}


func _place_stall(ag: Agent, at: Vector3, yaw: float) -> void:
	if ag.stall == null:
		ag.stall = _make_stall(ag.idx)
		add_child(ag.stall)
	ag.stall.visible = true
	ag.stall.process_mode = Node.PROCESS_MODE_INHERIT
	ag.stall.position = at
	ag.stall.rotation = Vector3(0, yaw + PI, 0)


## Pazar tezgâhı: masa, iki direk, çizgili saçak, mal (meyve, ekmek, kumaş, çömlek); tek kutu katı
func _make_stall(seed: int) -> Node3D:
	var st := Node3D.new()
	st.name = "Stall%d" % seed
	var wood := Color("7a5634")
	var cloth: Array = [[Color("c8463a"), Color("efe2c0")], [Color("3a6a9a"), Color("e8dcc0")], [Color("6a8a3a"), Color("efe2c0")], [Color("b8883a"), Color("6a3a2a")]][seed % 4]
	Props.box(st, Vector3(1.9, 0.08, 0.9), Vector3(0, 0.86, 0), wood)
	for sx: float in [-0.85, 0.85]:
		for sz: float in [-0.38, 0.38]:
			Props.box(st, Vector3(0.07, 0.86, 0.07), Vector3(sx, 0.43, sz), wood.darkened(0.2))
		Props.box(st, Vector3(0.08, 2.3, 0.08), Vector3(sx, 1.15, -0.5), wood.darkened(0.25))
		Props.box(st, Vector3(0.06, 1.9, 0.06), Vector3(sx, 0.95, 0.55), wood.darkened(0.25))
	for k in 5:
		Props.box(st, Vector3(0.42, 0.03, 1.5), Vector3(-0.84 + k * 0.42, 2.12 - 0.0, 0.0), cloth[k % 2], Vector3(-16, 0, 0))
	var goods := seed % 4
	for k in 6:
		var gx := -0.7 + (k % 3) * 0.7
		var gz := -0.18 + (k / 3) * 0.36
		match goods:
			0:   # meyve sepetleri
				Props.cyl(st, 0.2, 0.14, Vector3(gx, 0.97, gz), Color("9a7a48"), Vector3.ZERO, 8, 0.24)
				Props.ball(st, 0.17, Vector3(gx, 1.05, gz), [Color("d8452a"), Color("e8a020"), Color("8ab840")][k % 3], Vector3(1, 0.5, 1), 8)
			1:   # ekmek
				Props.ball(st, 0.15, Vector3(gx, 0.96, gz), Color("c8904a"), Vector3(1.3, 0.55, 1.0), 8)
			2:   # kumaş topları
				Props.cyl(st, 0.1, 0.55, Vector3(gx, 1.0, gz), [Color("8a2a4a"), Color("2a5a8a"), Color("c8a040")][k % 3], Vector3(0, 0, 90), 8)
			_:   # çömlek
				Props.ball(st, 0.15, Vector3(gx, 1.04, gz), Color("b8683a"), Vector3(1, 1.2, 1), 8)
				Props.cyl(st, 0.06, 0.1, Vector3(gx, 1.22, gz), Color("a8582a"), Vector3.ZERO, 8)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.95, 1.0, 1.0)
	cs.shape = bs
	cs.position = Vector3(0, 0.5, 0)
	body.add_child(cs)
	st.add_child(body)
	return st


# ---------------------------------------------------------------- davranış (10 Hz)

func _think() -> void:
	_bark_t -= 0.1
	var talking: bool = _hud != null and _hud.has_method("is_talking") and _hud.is_talking()
	# Yolda karşılaşanlar sağdan geçer (eskiden aynı kenarda karşıdan gelen ikisi birbirinin içinden yürüyordu):
	# önünde (3 m içinde, 0,7 m yanında) biri olan sivil yolun sağına kayar. Izgara: 2 m'lik hücreler.
	var grid := {}
	for ag in agents:
		if ag.active:
			var c := Vector2i(floori(ag.pos.x * 0.5), floori(ag.pos.z * 0.5))
			if grid.has(c):
				(grid[c] as Array).append(ag)
			else:
				grid[c] = [ag]
	for ag in agents:
		if not ag.active or ag.kind != "civ" or ag.wait > 0.0:
			continue
		var c := Vector2i(floori(ag.pos.x * 0.5), floori(ag.pos.z * 0.5))
		var fwd := Vector2(ag.dir.x, ag.dir.z)
		var left := Vector2(ag.dir.z, -ag.dir.x)        # _side'ın yan ekseni (artı: sol)
		var blocked := false
		for dx in range(-2, 3):
			for dz in range(-2, 3):
				for o in grid.get(c + Vector2i(dx, dz), []):
					if o == ag or o == ag.mate:
						continue
					var rel := _flat(o.pos) - _flat(ag.pos)
					var ahead := fwd.dot(rel)
					if ahead > 0.0 and ahead < 3.0 and absf(left.dot(rel)) < 0.7:
						blocked = true
		if blocked:
			ag.set_meta("keep_right", 1.5)
			ag.side_want = minf(ag.side_want, -0.6)
		elif ag.has_meta("keep_right"):
			var kt: float = float(ag.get_meta("keep_right")) - 0.1
			if kt <= 0.0:
				ag.remove_meta("keep_right")
				ag.side_want = 0.0
			else:
				ag.set_meta("keep_right", kt)
	for ag in agents:
		if not ag.active:
			continue
		var to := _flat(_pw) - _flat(ag.pos)
		var d := to.length()
		ag.look = maxf(0.0, ag.look - 0.1)
		ag.seen_player = maxf(0.0, ag.seen_player - 0.1)
		match ag.kind:
			"civ":
				# Yol ver: oyuncu önündeyse yana kay; çok yakından geçerken bakar
				if d < 3.2 and ag.wait <= 0.0:
					var ahead := Vector2(ag.dir.x, ag.dir.z).dot(to)
					if ahead > -0.5:
						var perp := Vector2(ag.dir.z, -ag.dir.x)
						var s := -signf(perp.dot(to)) if absf(perp.dot(to)) > 0.05 else 1.0
						ag.side_want = s * 1.1
						if ag.seen_player <= 0.0 and _rng.randf() < 0.5:
							# Yana çekilip durur, bakar, sonra yoluna devam eder
							ag.look = 1.6
							ag.wait = maxf(ag.wait, 1.4)
							ag.seen_player = 8.0
				elif d > 5.0 and not ag.has_meta("keep_right"):
					ag.side_want = 0.0
				if d < 4.0 and ag.wait > 0.0 and ag.mate == null and ag.seen_player <= 0.0:
					ag.look = 2.5
					ag.seen_player = 6.0
				# Sohbet sırası: konuşan ara ara değişir
				if ag.mate and ag.chat > 0.0 and ag.speaker and _rng.randf() < 0.04:
					ag.speaker = false
					ag.mate.speaker = true
			"vendor", "fisher":
				if d < 6.0 and ag.seen_player <= 0.0:
					ag.look = 4.0
					ag.seen_player = 10.0
					if ag.kind == "vendor" and not talking:
						_try_bark("SPK_TOWNSMAN", ["CL_BARK_BREAD", "CL_BARK_FRUIT", "CL_BARK_CLOTH", "CL_BARK_POTS"][ag.idx % 4], ag)
					elif ag.kind == "fisher" and not talking:
						_try_bark("SPK_FISHMONGER", "CL_BARK_FISH", ag)
			"patrol":
				if ag.slot == 0 and d < 9.0 and ag.seen_player <= 0.0:
					ag.seen_player = 25.0
					ag.wait = 1.6
					ag.look = 2.2
					for f: Agent in _followers(ag):
						f.look = 2.2
					if not talking:
						var keys := ["CL_BARK_J_HALT", "CL_BARK_J_QUARTER", "CL_BARK_J_MOVE"] if era == "conquest" else \
							(["CL_BARK_HALT", "CL_BARK_CURFEW", "CL_BARK_MOVE"] if night else ["CL_BARK_HALT", "CL_BARK_WALLS", "CL_BARK_MOVE"])
						_try_bark("SPK_JANISSARY" if era == "conquest" else "SPK_PATROL", keys[_rng.randi() % keys.size()], ag)


func _try_bark(spk: String, key: String, ag: Agent) -> void:
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
	var b := ag.body
	# Konuşmaya dışarıdan çekildiyse (Hud: yan karakter repliği, dinleyenler döner) durur ve ona döner
	var ext_talk := bool(b.get(&"talking"))
	var ext_look = b.get(&"look_target")
	if ext_talk or (ext_look != null and is_instance_valid(ext_look)):
		ag.wait = maxf(ag.wait, 0.5)
	match ag.kind:
		"civ":
			_walk(ag, delta)
		"patrol":
			if ag.slot == 0:
				_walk(ag, delta)
				if ag.trail.is_empty() or _flat(ag.trail[ag.trail.size() - 1]).distance_to(_flat(ag.pos)) > 0.35:
					ag.trail.append(ag.pos)
					if ag.trail.size() > 48:
						ag.trail.remove_at(0)
			else:
				_follow(ag, delta)
	var mx := ag.pos.x - old.x
	var mz := ag.pos.z - old.z
	ag.moved = mx * mx + mz * mz > 0.00000025          # 0,5 mm
	# Yön: yürürken gidişe, sohbette karşısındakine, bakarken oyuncuya, dururken (satıcı) meydana
	var want := ag.yaw
	if ext_look != null and is_instance_valid(ext_look) and ext_look is Node3D:
		var lp: Vector3 = world.global_transform.affine_inverse() * (ext_look as Node3D).global_position
		want = atan2(lp.x - ag.pos.x, lp.z - ag.pos.z)
	elif ag.look > 0.0:
		want = atan2(_pw.x - ag.pos.x, _pw.z - ag.pos.z)
	elif ag.mate and ag.chat > 0.0:
		want = atan2(ag.mate.pos.x - ag.pos.x, ag.mate.pos.z - ag.pos.z)
	elif ag.moved and delta > 0.0:
		want = atan2(ag.pos.x - old.x, ag.pos.z - old.z)
	elif ag.face != Vector3.INF:
		want = atan2(ag.face.x - ag.pos.x, ag.face.z - ag.pos.z)
	elif ag.leader and ag.leader.active:
		want = ag.leader.yaw
	ag.yaw = lerp_angle(ag.yaw, want, clampf(delta * 6.0, 0.0, 1.0))
	# Yerine koyma ve canlandırma: yakındakiler (28 m) her kare, uzaktakiler üç karede bir, ikisi aynı karede (Rig hızı
	# gövdenin konum farkından ölçer)
	ag.rig_dt += delta
	var nx := ag.pos.x - _pw.x
	var nz := ag.pos.z - _pw.z
	ag.tick = nx * nx + nz * nz < 784.0 or (_frame + ag.idx) % 3 == 0
	if ag.tick:
		_place(ag)
		var rg := ag.rig
		if rg:
			var talk := (ag.mate != null and ag.chat > 0.0 and ag.speaker) or ext_talk
			rg.update(ag.rig_dt, talk, false)
			var m := ag.mouth
			if m:
				var open := LipSync.mouth(_time, ag.rig_dt) if ext_talk else (absf(sin(_time * 11.0)) * 0.7 if talk else 0.0)
				m.scale.y = 0.22 * (1.0 + open * 2.8)
				m.scale.x = rg.mouth_x
		ag.rig_dt = 0.0


func _walk(ag: Agent, delta: float) -> void:
	if ag.chat > 0.0:
		ag.chat -= delta
		if ag.chat <= 0.0:
			ag.mate = null
	if ag.wait > 0.0:
		ag.wait -= delta
		_side(ag, delta)
		return
	var left := ag.speed * delta
	var guard := 0
	while left > 0.0 and guard < 6:
		guard += 1
		if ag.k >= ag.pts.size():
			if not _arrive(ag):
				_deactivate(ag)
				for f: Agent in _followers(ag) if ag.kind == "patrol" else []:
					_deactivate(f)
				return
			if ag.wait > 0.0:
				break
			continue
		var tgt := ag.pts[ag.k]
		var to := tgt - ag.base
		var d := Vector2(to.x, to.z).length()
		if d <= left:
			ag.base = tgt
			ag.k += 1
			left -= d
		else:
			ag.base += to * (left / d)
			left = 0.0
		if d > 0.01:
			ag.dir = Vector3(to.x, 0, to.z).normalized()
	_side(ag, delta)


## Gövdeyi yerine koyar, yalnız değiştiyse. Gövdenin konumunu yazmak bütün parçalarına yayılır: CityLife karesinin en
## pahalı işiydi (kişi başına ~9 µs, her kare); duran satıcı, sohbet eden ikili, dönüşünü bitiren artık yazılmaz.
func _place(ag: Agent) -> void:
	if ag.pos.distance_squared_to(ag.shown_pos) > 0.000001:      # 1 mm
		ag.shown_pos = ag.pos
		ag.body.position = ag.pos
	if not absf(angle_difference(ag.yaw, ag.shown_yaw)) <= 0.002:  # ~0,1° (ilk yazılışta shown_yaw INF: fark NaN)
		ag.shown_yaw = ag.yaw
		ag.body.rotation.y = ag.yaw


## Yana çekilme (oyuncuya yol): yolun çizgisinden en çok ~1 m
func _side(ag: Agent, delta: float) -> void:
	ag.side = move_toward(ag.side, ag.side_want, delta * 1.5)
	var perp := Vector3(ag.dir.z, 0, -ag.dir.x)
	var p := ag.base + perp * ag.side
	ag.pos = p


## Devriye askeri reisin izinde: iki yanında, bir buçuk adım arkada (adım uydurarak)
func _follow(ag: Agent, delta: float) -> void:
	var ld := ag.leader
	if ld == null or not ld.active:
		return
	var f := _form(ld, ag.slot)
	var tgt: Vector3 = f[0]
	var to := tgt - ag.pos
	var d := Vector2(to.x, to.z).length()
	if d > 8.0:
		ag.pos = tgt
		return
	var sp := minf(d * 2.5, ld.speed * 1.5)
	if d > 0.02:
		var step := minf(d, sp * delta)
		ag.pos += Vector3(to.x, 0, to.z) / d * step
		ag.pos.y = lerpf(ag.pos.y, tgt.y, clampf(delta * 8.0, 0.0, 1.0))


## Takımdaki yer: reisin izinde 1,6 m geride, sağ ya da solda 0,55 m
func _form(ld: Agent, slot: int) -> Array:
	var back := 1.6
	var p := ld.pos
	var dir := ld.dir
	var i := ld.trail.size() - 1
	var rem := back
	while i >= 0:
		var q := ld.trail[i]
		var d := _flat(p).distance_to(_flat(q))
		if d >= rem and d > 0.001:
			dir = (p - q)
			dir.y = 0.0
			dir = dir.normalized()
			p = p.lerp(q, rem / d)
			rem = 0.0
			break
		rem -= d
		p = q
		i -= 1
	if rem > 0.0:
		p -= dir * rem
	var perp := Vector3(dir.z, 0, -dir.x)
	p += perp * (0.55 if slot == 1 else -0.55)
	p.y = _surf(p.x, p.z) if _frame % 2 == 0 else p.y
	return [p, dir]


# ---------------------------------------------------------------- keşif (§2)

func _discover() -> void:
	if landmarks.is_empty():
		return
	for l in landmarks:
		var key := str(l.get("key", ""))
		if key == "" or GameState.discovered.has(key):
			continue
		var p: Vector3 = l.get("pos", Vector3.ZERO)
		if _flat(p).distance_to(_flat(_pw)) < DISCOVER_R + float(l.get("r", 0.0)):
			if GameState.discover(key):
				_disc_queue.append(l)
	if _disc_queue.is_empty() or _hud == null or GameState.autotest or not _hud.has_method("discovery_card"):
		if GameState.autotest:
			_disc_queue.clear()
		return
	if bool(_hud.get("cinematic")) or (_hud.has_method("is_talking") and _hud.is_talking()):
		return
	var l: Dictionary = _disc_queue.pop_front()
	_hud.discovery_card(str(l.get("name_key", "")), str(l.get("info_key", "")), GameState.discovered.size(), landmarks.size())


# ---------------------------------------------------------------- test yardımcıları

## Etkin karakterler (CITYCHECK): [{"node", "kind", "role", "pos" (dünya)}]
func active_list() -> Array:
	var out: Array = []
	for ag in agents:
		if ag.active:
			out.append({"node": ag.body, "kind": ag.kind, "role": ag.role, "pos": ag.pos, "slot": ag.slot})
	return out
