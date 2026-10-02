class_name Lore
extends Node3D
## Tarih Defteri: açık alanlı bölümlere saklanmış sayfalar. Her sayfa o günün gerçek bir tarih bilgisidir.
## Bölüm serbest dolaşıma açılınca Lore.scatter(sahne, "anahtar") çağrılır: oyuncunun bulunduğu yerden 1 m ızgarada
## yürünebilir hücreler taranır (duvar, basamak, boşluk), başlangıçtan uzak, birbirinden ayrık ve duvar dibinde
## (köşe, arka sokak) hücreler seçilir. Sayfa yerde yatan bir parşömen rulosudur, üstünde hafif bir pırıltı.
## Üstüne yürüyünce okunur (akış durmaz: sol altta parşömen paneli). Bulunanlar oyunlar arasında saklanır (meta).
## Metinler: LORE_<ANAHTAR>_<n>_T (başlık) ve LORE_<ANAHTAR>_<n> (metin). Sayfa sayısı PAGES'ten gelir.

const PAGES := {
	"4": 3, "6a": 3, "6b": 5, "7": 3, "9": 3, "10": 3, "10g": 3, "10h": 3,
	"18": 6, "20": 3, "21": 3, "22": 3, "23": 3, "24": 3, "24o": 3, "17o": 3, "20o": 3, "21o": 3, "22o": 3, "26o": 3, "32o": 3, "37o": 3, "38o": 3, "39o": 3, "31o": 3, "33o": 3, "34o": 3, "35o": 3, "25": 3, "26": 3, "27": 3,
}
const STEP := 1.0
const UP := 0.55
const MAX_CELLS := 5000

var key := ""
var fixed: Array = []
var _items: Array[Node3D] = []
var _hud: Node
var _player: Node3D
var _t := 0.0


static func total() -> int:
	var n := 0
	for k in PAGES:
		n += int(PAGES[k])
	return n


static func found_count() -> int:
	return GameState.lore.size()


## Sahneye sayfaları dağıtır. Sahnenin "player" ve "hud" değişkenleri kullanılır. Anahtar PAGES'te yoksa bir şey yapmaz.
## fixed: sayfaların bir kısmı belli yerlere (ör. çatılara: yerden yürüyerek ulaşılamaz); kalanı yerde dağıtılır.
static func scatter(scene: Node3D, chapter_key: String, fixed: Array = []) -> Lore:
	if not PAGES.has(chapter_key) or not ("player" in scene) or scene.player == null:
		return null
	for c in scene.get_children():
		if c is Lore and (c as Lore).key == chapter_key:
			return c           # bölüm her serbest bırakışta çağırır; yalnız ilki dağıtır
	var l := Lore.new()
	l.key = chapter_key
	l.fixed = fixed
	l._player = scene.player
	l._hud = scene.hud if "hud" in scene else null
	scene.add_child(l)
	l._place.call_deferred()
	return l


func _place() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if not is_instance_valid(_player):
		return
	var spots: Array[Vector3] = []
	for f: Vector3 in fixed:
		spots.append(f)
	spots.append_array(_pick_spots(maxi(int(PAGES[key]) - fixed.size(), 0)))
	for i in spots.size():
		var id := "%s_%d" % [key, i + 1]
		if GameState.lore.has(id) and not GameState.autotest:
			continue
		_items.append(_make_page(id, spots[i]))
	if GameState.autotest:
		print("LORE key=%s placed=%d" % [key, spots.size()])
		if not _items.is_empty():
			_collect(_items[0])      # arayüz yolu testte de çalışsın


func _process(delta: float) -> void:
	_t += delta
	if not is_instance_valid(_player):
		return
	var p := _player.global_position
	for it in _items.duplicate():
		if not is_instance_valid(it):
			_items.erase(it)
			continue
		var glint: Node3D = it.get_node("Glint")
		glint.scale = Vector3.ONE * (0.8 + 0.35 * sin(_t * 3.0 + it.position.x))
		if Vector2(p.x - it.global_position.x, p.z - it.global_position.z).length() < 1.1 and absf(p.y - it.global_position.y) < 1.6:
			_collect(it)


func _collect(it: Node3D) -> void:
	_items.erase(it)
	var id: String = it.get_meta("lore_id")
	GameState.find_lore(id)
	Audio.sfx("newspaper", -6.0, 1.15)
	var tw := it.create_tween()
	tw.tween_property(it, "scale", Vector3.ONE * 0.01, 0.35)
	tw.tween_callback(it.queue_free)
	if _hud and _hud.has_method("lore_page"):
		_hud.lore_page(id)


func _make_page(id: String, at: Vector3) -> Node3D:
	var n := Node3D.new()
	n.set_meta("lore_id", id)
	add_child(n)
	n.global_position = at
	n.rotation.y = randf() * TAU
	# Parşömen rulosu: iki ucu koyu mühürlü, üstünde kırmızı şerit; yere yatık
	Props.cyl(n, 0.045, 0.34, Vector3(0, 0.05, 0), Color("efe2c0"), Vector3(0, 0, 90), 10)
	Props.cyl(n, 0.05, 0.03, Vector3(0.17, 0.05, 0), Color("8a6a3a"), Vector3(0, 0, 90), 10)
	Props.cyl(n, 0.05, 0.03, Vector3(-0.17, 0.05, 0), Color("8a6a3a"), Vector3(0, 0, 90), 10)
	Props.cyl(n, 0.049, 0.035, Vector3(0, 0.05, 0), Color("b3262d"), Vector3(0, 0, 90), 10)
	# Pırıltı: uzaktan seçilsin (küçük, sıcak, yanıp söner)
	var g := Node3D.new()
	g.name = "Glint"
	g.position = Vector3(0, 0.42, 0)
	n.add_child(g)
	var s := Props.ball(g, 0.05, Vector3.ZERO, Color("ffe08a"), Vector3(1, 1, 1), 6, 4.0)
	s.material_override = Props.mat(Color("ffe08a"), 4.0, false, "", false)
	s.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var l := OmniLight3D.new()
	l.light_color = Color("ffd070")
	l.light_energy = 1.1
	l.omni_range = 2.2
	g.add_child(l)
	return n


# ---------------------------------------------------------------- yer seçimi

func _pick_spots(count: int) -> Array[Vector3]:
	var space := _player.get_world_3d().direct_space_state
	var ex: Array[RID] = [(_player as CollisionObject3D).get_rid()]
	var start := _player.global_position
	var k0 := Vector2i(roundi(start.x / STEP), roundi(start.z / STEP))
	var floor_y := {k0: start.y}
	var nook := {}
	var queue: Array[Vector2i] = [k0]
	var head := 0
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while head < queue.size() and floor_y.size() < MAX_CELLS:
		var c: Vector2i = queue[head]
		head += 1
		var fy: float = floor_y[c]
		var blocked := 0
		for d: Vector2i in dirs:
			var n: Vector2i = c + d
			var p0 := Vector3(c.x * STEP, fy, c.y * STEP)
			var p1 := Vector3(n.x * STEP, fy, n.y * STEP)
			if _hit(space, p0 + Vector3(0, UP + 0.1, 0), p1 + Vector3(0, UP + 0.1, 0), ex) or _hit(space, p0 + Vector3(0, 1.3, 0), p1 + Vector3(0, 1.3, 0), ex):
				blocked += 1
				continue
			if floor_y.has(n):
				continue
			var q := PhysicsRayQueryParameters3D.create(p1 + Vector3(0, UP + 0.1, 0), p1 + Vector3(0, -4.0, 0), 1, ex)
			var h := space.intersect_ray(q)
			if h.is_empty() or (h.normal as Vector3).y < 0.7:
				blocked += 1
				continue
			var ny: float = (h.position as Vector3).y
			if absf(ny - fy) > UP:
				blocked += 1
				continue
			if Vector2(n.x - k0.x, n.y - k0.y).length() > 70.0:
				continue
			floor_y[n] = ny
			queue.append(n)
		if blocked > 0:
			nook[c] = blocked
	# Adaylar: başlangıçtan 9 m ötede, duvar dibinde; en uzağından başlayıp birbirinden ayrık seç
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(key)
	var cands: Array[Vector2i] = []
	for c: Vector2i in nook:
		if Vector2(c.x - k0.x, c.y - k0.y).length() >= 9.0:
			cands.append(c)
	if cands.is_empty():
		for c: Vector2i in floor_y:
			if Vector2(c.x - k0.x, c.y - k0.y).length() >= 6.0:
				cands.append(c)
	var out: Array[Vector3] = []
	var chosen: Array[Vector2i] = []
	for i in count:
		var best := Vector2i.ZERO
		var best_s := -1.0
		for c in cands:
			var d := Vector2(c.x - k0.x, c.y - k0.y).length() * 0.35
			var sep := 999.0
			for o in chosen:
				sep = minf(sep, Vector2(c.x - o.x, c.y - o.y).length())
			if chosen.is_empty():
				sep = 20.0
			var sc := minf(sep, 25.0) + minf(d, 12.0) + rng.randf() * 6.0 + float(nook[c] if nook.has(c) else 0) * 1.5
			if sc > best_s:
				best_s = sc
				best = c
		if best_s < 0.0:
			break
		chosen.append(best)
		cands.erase(best)
		out.append(Vector3(best.x * STEP, float(floor_y[best]) + 0.01, best.y * STEP))
	return out


func _hit(space: PhysicsDirectSpaceState3D, a: Vector3, b: Vector3, ex: Array[RID]) -> bool:
	var q := PhysicsRayQueryParameters3D.create(a, b, 1, ex)
	return not space.intersect_ray(q).is_empty()
