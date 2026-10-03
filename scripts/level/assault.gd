class_name Assault
extends Node3D
## Son hücum (29 Mayıs 1453): kara surlarının önünde gerçek bir savaş kalabalığı. LandWalls koordinatları
## (x sur boyunca, +z ovaya doğru; dış sur z 14–16, gedik x=0). Oyuncunun yürüdüğü dikdörtgene (keep)
## çarpışmasız kalabalık konmaz; kalabalık onun arkasında, yanlarında ve surla arasındaki hendek kuşağındadır.
##   · ordu: sancaklı, mızraklı yüzlerce asker bloğu (toplu çizim)
##   · dalgalar: sura koşan, hendeğe inen, gediğe dalan askerler (her kare hareket eder)
##   · merdivenler: dış sura dayalı merdivenlerde tırmanan askerler (bazıları düşer)
##   · bataryalar: arkada ateş eden toplar (alev, duman, gülle yayı, surda toz ve taş)
##   · savunanlar: surların üstünde miğferli askerler; ok yağmuru (görünen oklar yere saplanır)
## Kullanım: var a := Assault.new(); a.keep = Rect2(...); add_child(a); a.build()

var keep := Rect2(-32.0, 36.4, 64.0, 42.0)
var night := true
var wall_len := 150.0
var intensity := 1.0              # 0..1 (dalgalar ve top sıklığı)
var with_defenders := true        # false: surdaki savunanları bölüm kendisi koyar (Garrison)
var live_span := 0.0              # dış surda |x| < live_span boş (bölüm oraya canlı Garrison askerleri koyar)
var gun_spots: Array = [Vector3(-44, 0, 92), Vector3(-16, 0, 94), Vector3(16, 0, 94), Vector3(44, 0, 92)]
var rng := RandomNumberGenerator.new()
const VOLLEY_FLIGHT := 2.4        # okun havada kaldığı süre (yüksek yay, dik iniş)

var _t := 0.0
var _runners: Array = []          # [[MultiMeshInstance3D (RUN_POSES sırasıyla)], [indeks listesi _run içinde]]
var _run: Array = []              # [from, to, speed, t]
var _climb: Array = []            # {node, base, top, t, speed, fall}
var _guns: Array = []             # {node, muzzle, timer}
var _flying: Array = []           # [node, vel, life]
var _stuck: Array = []            # [node, life]
var _defender_nodes: Array[Node3D] = []
var _ladder_nodes: Array[Node3D] = []
var _army_pts: Array[Vector3] = []
var _torch_lights: Array[OmniLight3D] = []
var fire_ratio := -1.0            # gece oklarının yanan payı (<0: gece 0,35, gündüz 0)
static var _flame_mat: StandardMaterial3D
static var _arrow_mesh: ArrayMesh
static var _soldier_meshes := {}
static var _defender_meshes := {}


## progressive: adımlar arasında bir kare beklenir (ana menünün arkası: tek karede ~5 sn sürüp pencereyi donduruyordu)
var progressive := false


func build() -> void:
	rng.seed = 5291453
	_army()
	await _yield()
	_wave_runners()
	await _yield()
	_ladders()
	await _yield()
	_batteries()
	await _yield()
	_equipment()
	if with_defenders:
		await _yield()
		_defenders()
	_smoke()
	if night:
		_torches()
		_dust_line()


func _yield() -> void:
	if progressive and is_inside_tree():
		await get_tree().process_frame


## Hücumdan önceki gün (Bölüm 32o): ordu, bataryalar, donanım, surda savunanlar ve duman; koşan dalga ve
## merdiven yok (oklar `volley` ile yine atılır)
func build_calm() -> void:
	rng.seed = 5281453
	_army()
	_batteries()
	_equipment()
	if with_defenders:
		_defenders()
	_smoke()


# ---------------------------------------------------------------- modeller

## Uzak asker (kaftan rengi pişirilmiş): şalvar ve çizme, kaftan eteği, gövde, kuşak, kollar, baş, bıyık, börk,
## sağ elde mızrak. Örnek rengi kullanılmaz (börk ve yüz de boyanıyordu).
static func soldier_mesh(coat := Color("b3262d")) -> ArrayMesh:
	var key := coat.to_html()
	if not _soldier_meshes.has(key):
		_soldier_meshes[key] = Scenery.merged([
			[Scenery._cyl(0.07, 0.55, 0.08, 5), Scenery._t(Vector3(-0.09, 0.28, 0)), Color("e8e0d0")],
			[Scenery._cyl(0.07, 0.55, 0.08, 5), Scenery._t(Vector3(0.09, 0.28, 0)), Color("e8e0d0")],
			[Scenery._boxm(Vector3(0.12, 0.08, 0.2)), Scenery._t(Vector3(-0.09, 0.04, 0.04)), Color("4a3020")],
			[Scenery._boxm(Vector3(0.12, 0.08, 0.2)), Scenery._t(Vector3(0.09, 0.04, 0.04)), Color("4a3020")],
			[Scenery._cyl(0.27, 0.5, 0.21, 8), Scenery._t(Vector3(0, 0.72, 0)), coat.darkened(0.08)],
			[Scenery._cyl(0.2, 0.55, 0.19, 8), Scenery._t(Vector3(0, 1.18, 0)), coat],
			[Scenery._cyl(0.215, 0.08, -1.0, 8), Scenery._t(Vector3(0, 0.96, 0)), Color("e0b52a")],
			[Scenery._cyl(0.06, 0.5, 0.05, 4), Scenery._t(Vector3(-0.25, 1.12, 0.04), Vector3(0.2, 0, 0.12)), coat],
			[Scenery._cyl(0.06, 0.5, 0.05, 4), Scenery._t(Vector3(0.25, 1.12, 0.08), Vector3(-0.5, 0, -0.12)), coat],
			[Scenery._ball(0.15), Scenery._t(Vector3(0, 1.6, 0)), Color("e0b08a")],
			[Scenery._boxm(Vector3(0.2, 0.04, 0.05)), Scenery._t(Vector3(0, 1.55, 0.14)), Color("2b1d14")],
			[Scenery._cyl(0.155, 0.07, -1.0, 8), Scenery._t(Vector3(0, 1.72, 0)), Color("c9a24a")],
			[Scenery._cyl(0.13, 0.42, 0.09, 6), Scenery._t(Vector3(0, 1.93, -0.04), Vector3(-0.2, 0, 0)), Color("f3efe4")],
			[Scenery._cyl(0.022, 2.8, -1.0, 4), Scenery._t(Vector3(0.28, 1.25, 0.2)), Color("5a3e26")],
			[Scenery._cyl(0.05, 0.25, 0.0, 4), Scenery._t(Vector3(0.28, 2.75, 0.2)), Color("c8ccd4")],
		])
	return _soldier_meshes[key]


## Aynı rengin askerlerini tek MultiMesh'te toplar: {renk: [Transform3D]} → sahneye.
func _scatter_by_coat(groups: Dictionary) -> Dictionary:
	var out := {}
	for key in groups:
		var xs: Array = groups[key]
		if xs.is_empty():
			continue
		out[key] = Scenery.scatter(self, Crowd.ottoman(Color(key), "bork", "spear"), xs, [], _mat())   # gerçek asker modeli
	return out


## Surdaki savunan (uzak): bacaklar, tunik (kaftan rengi pişirilmiş), kollar, baş, sivri miğfer ve burun siperi,
## sol kolda yuvarlak kalkan, sağ elde mızrak. Örnek rengi kullanılmaz (yüzü ve miğferi de boyuyordu).
static func defender_mesh(coat := Color("7a2a24")) -> ArrayMesh:
	var key := coat.to_html()
	if not _defender_meshes.has(key):
		_defender_meshes[key] = Scenery.merged([
			[Scenery._cyl(0.07, 0.6, 0.08, 5), Scenery._t(Vector3(-0.09, 0.3, 0)), Color("3a2a22")],
			[Scenery._cyl(0.07, 0.6, 0.08, 5), Scenery._t(Vector3(0.09, 0.3, 0)), Color("3a2a22")],
			[Scenery._cyl(0.25, 0.42, 0.2, 8), Scenery._t(Vector3(0, 0.76, 0)), coat.darkened(0.1)],
			[Scenery._cyl(0.2, 0.52, 0.19, 8), Scenery._t(Vector3(0, 1.18, 0)), coat],
			[Scenery._cyl(0.2, 0.1, 0.2, 8), Scenery._t(Vector3(0, 1.4, 0)), Color("7a7f86")],
			[Scenery._cyl(0.06, 0.5, 0.05, 4), Scenery._t(Vector3(-0.25, 1.12, 0.04), Vector3(0.2, 0, 0.12)), coat],
			[Scenery._cyl(0.06, 0.5, 0.05, 4), Scenery._t(Vector3(0.25, 1.12, 0.08), Vector3(-0.5, 0, -0.12)), coat],
			[Scenery._ball(0.15), Scenery._t(Vector3(0, 1.58, 0)), Color("e0b08a")],
			[Scenery._ball(0.165), Scenery._t(Vector3(0, 1.66, -0.01), Vector3.ZERO, Vector3(1, 0.8, 1)), Color("9aa0a8")],
			[Scenery._cyl(0.1, 0.16, 0.0, 6), Scenery._t(Vector3(0, 1.82, -0.01)), Color("9aa0a8")],
			[Scenery._boxm(Vector3(0.03, 0.1, 0.03)), Scenery._t(Vector3(0, 1.6, 0.15)), Color("8e949c")],
			[Scenery._cyl(0.3, 0.05, -1.0, 10), Scenery._t(Vector3(-0.28, 1.05, 0.22), Vector3(PI * 0.5, 0, 0)), coat.darkened(0.35)],
			[Scenery._cyl(0.07, 0.06, -1.0, 6), Scenery._t(Vector3(-0.28, 1.05, 0.26), Vector3(PI * 0.5, 0, 0)), Color("c8a040")],
			[Scenery._cyl(0.022, 2.6, -1.0, 4), Scenery._t(Vector3(0.28, 1.2, 0.2)), Color("5a3e26")],
			[Scenery._cyl(0.045, 0.24, 0.0, 4), Scenery._t(Vector3(0.28, 2.6, 0.2)), Color("c8ccd4")],
		])
	return _defender_meshes[key]


## Ok: gövde, uç, tüyler (+Z uçtur).
static func arrow_mesh() -> ArrayMesh:
	if _arrow_mesh == null:
		_arrow_mesh = Scenery.merged([
			[Scenery._cyl(0.012, 0.85, -1.0, 4), Scenery._t(Vector3.ZERO, Vector3(PI * 0.5, 0, 0)), Color("6a4a2c")],
			[Scenery._cyl(0.03, 0.09, 0.0, 4), Scenery._t(Vector3(0, 0, 0.46), Vector3(PI * 0.5, 0, 0)), Color("3a3a40")],
			[Scenery._boxm(Vector3(0.004, 0.07, 0.16)), Scenery._t(Vector3(0, 0, -0.36)), Color("e8e0cc")],
			[Scenery._boxm(Vector3(0.07, 0.004, 0.16)), Scenery._t(Vector3(0, 0, -0.36)), Color("e8e0cc")],
		])
	return _arrow_mesh


func _mat() -> StandardMaterial3D:
	return Crowd.material()


func _blocked(x: float, z: float, margin := 1.5) -> bool:
	return keep.grow(margin).has_point(Vector2(x, z))


# ---------------------------------------------------------------- ordu blokları

## Yürünen alanın arkasında ve iki yanında düzenli bloklar (her blok 8x6 asker), aralarında sancaklar.
func _army() -> void:
	var army: Array = []
	# Birlik türleri (blok başına bir tür): yeniçeri (beyaz börk; krem, lacivert ya da kırmızı dolama), azap
	# (sarıklı hafif piyade; ham bez, kahve, gri; yay ve kalkan), sipahi (sivri miğfer; koyu kırmızı, yeşil; kılıç-kalkan)
	var kinds := [
		{"coats": [Color("d8cfb8"), Color("3e4c68"), Color("8a3a2e")], "hat": "bork", "arms": ["spear", "spear", "spear", "sword_shield"]},
		{"coats": [Color("7a6448"), Color("6a5a48"), Color("5a5448"), Color("a89878")], "hat": "turban", "arms": ["bow", "spear", "sword_shield"]},
		{"coats": [Color("7a2e28"), Color("3e5238"), Color("5a4a3a")], "hat": "helmet", "arms": ["sword_shield", "spear"]},
	]
	var blocks: Array = []
	# Arka: iki sıra blok
	for row in 3:
		for bx in 9:
			blocks.append(Vector3(-72.0 + bx * 18.0, 0, keep.end.y + 26.0 + row * 14.0))
	# Yanlar: hendeğin (z 20–36) hemen ardından geriye. (Eskiden ilk sıra z 27–33'te, hendeğin üstünde zemin
	# seviyesinde, dibinin 2,9 m üstünde havada duruyordu.)
	for side in [-1.0, 1.0]:
		for row in 4:
			for col in 3:
				blocks.append(Vector3(side * (keep.end.x + 10.0 + col * 16.0), 0, 41.0 + row * 12.0))
	var banner_pos: Array = []
	for b: Vector3 in blocks:
		var kind: Dictionary = kinds[rng.randi() % kinds.size()]
		var coats: Array = kind["coats"]
		var arms: Array = kind["arms"]
		for i in 8:
			for j in 5:
				var p := b + Vector3(-5.6 + i * 1.6 + rng.randf_range(-0.2, 0.2), 0, -3.2 + j * 1.6 + rng.randf_range(-0.2, 0.2))
				if _blocked(p.x, p.z):
					continue
				p.y = ground_y(p.x, p.z)
				# Aynı birlikte de giysi tek tip değil: iki-üç ton karışık, silah sırası sıraya göre
				_army_pts.append(p)
				army.append([Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.15, 0.15)).scaled(Vector3.ONE * rng.randf_range(0.95, 1.08)), p),
					{"side": "O", "coat": coats[(i * 3 + j * 5 + rng.randi() % 2) % coats.size()], "hat": kind["hat"], "arm": arms[j % arms.size()]}])
		if not _blocked(b.x, b.z, 0.5):
			banner_pos.append(b + Vector3(0, 0, -4.6))
	Crowd.place(self, army)
	# Sancaklar ve tuğlar
	for bp: Vector3 in banner_pos:
		if rng.randf() < 0.3:
			_tug(bp)
		else:
			_sancak(bp, [Color("9a2a24"), Color("2e5a36"), Color("9a2a24"), Color("c8a040")][rng.randi() % 4])


## Sancak: kırmızı ya da yeşil (ya da sarı) çatal kuyruklu bayrak, üstünde beyaz hilal; direğin tepesinde tunç alem.
func _sancak(bp: Vector3, col: Color) -> void:
	Props.cyl(self, 0.05, 5.5, bp + Vector3(0, 2.75, 0), Color("4a3420"), Vector3.ZERO, 5)
	Props.ball(self, 0.1, bp + Vector3(0, 5.58, 0), Color("c8a040"), Vector3.ONE, 6)
	Props.ring(self, 0.07, 0.12, bp + Vector3(0, 5.8, 0), Color("c8a040"), Vector3(90, 0, 0))
	var fl := Node3D.new()
	fl.position = bp + Vector3(0, 4.7, 0)
	add_child(fl)
	fl.set_meta("flag", true)
	Props.box(fl, Vector3(0.03, 1.3, 1.5), Vector3(0, 0, -0.75), col)
	# Çatal kuyruk: uca doğru ayrılan iki dil
	for sy: float in [-0.33, 0.33]:
		Props.box(fl, Vector3(0.03, 0.34, 1.0), Vector3(0, sy + signf(sy) * 0.05, -1.92), col, Vector3(signf(sy) * 10.0, 0, 0))
	# Hilal (ağzı bayrağın uçuşan ucuna bakar): beyaz disk, üstünü uca doğru kaydırılmış bayrak renginde disk örter
	for sx: float in [0.02, -0.02]:
		Props.cyl(fl, 0.34, 0.012, Vector3(sx, 0.05, -0.6), Color("f0ece0"), Vector3(0, 0, 90), 16)
		Props.cyl(fl, 0.29, 0.014, Vector3(sx * 1.1, 0.08, -0.72), col, Vector3(0, 0, 90), 16)


## Tuğ: uzun direk, tepede tunç top ve alem, altından sarkan at kılı demetleri (koyu ve kızıl).
func _tug(bp: Vector3) -> void:
	Props.cyl(self, 0.05, 6.0, bp + Vector3(0, 3.0, 0), Color("4a3420"), Vector3.ZERO, 5)
	Props.ball(self, 0.14, bp + Vector3(0, 6.05, 0), Color("c8a040"), Vector3.ONE, 8)
	Props.cyl(self, 0.02, 0.35, bp + Vector3(0, 6.35, 0), Color("c8a040"), Vector3.ZERO, 4, 0.0)
	Props.cyl(self, 0.16, 0.08, bp + Vector3(0, 5.85, 0), Color("c8a040"), Vector3.ZERO, 10)
	for k in 5:
		var a := k * TAU / 5.0
		Props.cyl(self, 0.07, 1.3, bp + Vector3(cos(a) * 0.1, 5.15, sin(a) * 0.1), [Color("2a1e18"), Color("6a2a1e")][k % 2], Vector3(sin(a) * 6.0, 0, cos(a) * 6.0), 5, 0.02)


# ---------------------------------------------------------------- koşan dalgalar

## Surla yürünen alan arasındaki kuşakta sura koşan askerler (döngü): hendeğe iner, sura ya da gediğe varınca
## yeniden arkadan başlar. Tek MultiMesh, her kare dönüşüm güncellenir.
func _wave_runners() -> void:
	var n := int(140 * intensity) + 40
	# Hücum eden: yeniçeri (krem, kırmızı; börk), azap (kahve; sarık), sipahi (lacivert; miğfer)
	var coats := [Color("d8cfb8"), Color("8a3a2e"), Color("6a5a48"), Color("3e4c68")]
	var groups := {}
	var idx := {}
	for i in n:
		var x := rng.randf_range(-wall_len * 0.45, wall_len * 0.45)
		var from := Vector3(x + rng.randf_range(-3, 3), 0, rng.randf_range(40.0, 60.0))
		# Başlangıç noktası oyuncunun alanına düşerse alanın önüne (sur tarafına) alınır. (Eskiden y'ye bakılıyordu:
		# Bizans tarafında alan peribolosu kapsadığından koşanlar şehrin içinden, peribolosun ortasından geçiyordu.)
		if keep.grow(3.0).has_point(Vector2(from.x, from.z)):
			from.z = keep.position.y - 4.0
		# Gediğin karşısındakiler gediğe (gediğin kırık kenarına değil, açıklığın içine), öbürleri sur dibine
		# (dış sur kulesinin, x 13.5–18.5, önüne değil)
		if absf(x) >= 18.0 and absf(x) < 19.5:
			x = signf(x) * 19.5
			from.x = x + rng.randf_range(-1.5, 1.5)
		var to := Vector3(clampf(x * 0.17, -2.6, 2.6) if absf(x) < 18.0 else x, 0, 17.5 if absf(x) >= 18.0 else 15.2)
		var sp := rng.randf_range(3.2, 4.8)
		_run.append([from, to, sp, rng.randf()])
		var key: String = (coats[i % coats.size()] as Color).to_html()
		if not groups.has(key):
			groups[key] = []
			idx[key] = []
		(groups[key] as Array).append(Transform3D(Basis.IDENTITY, from))
		(idx[key] as Array).append(i)
	# Her renk için üç poz (koşu adımının iki ucu ve sıçrayış): her asker o anki pozun ağında görünür, öbürlerinde gizli
	for key in groups:
		var xs: Array = groups[key]
		var set_mm: Array = []
		var hat: String = RUN_HATS.get(key, "bork")
		for pose in RUN_POSES:
			set_mm.append(Scenery.scatter(self, Crowd.ottoman(Color(key), hat, "spear", pose), xs, [], _mat()))
		_runners.append([set_mm, idx[key]])
	# Gece hücumunda her beş koşandan birinin sol elinde meşale (alev koşanla birlikte gider)
	if night:
		var fx: Array = []
		var fc: Array = []
		for i in n:
			if i % 5 == 0:
				_run_flame[i] = fx.size()
				fx.append(_hidden)
				fc.append(Color(1.0, 0.72, 0.32))
		var q := SphereMesh.new()
		q.radius = 0.13
		q.height = 0.42
		q.radial_segments = 6
		q.rings = 3
		var mm := Scenery.scatter(self, q, fx, fc, flame_mat())
		_run_flames = mm.multimesh


## Surun önündeki arazinin yüksekliği (LandWalls ve SiegeField'in kesiti): karşı duvardan hendeğe atlar (dibi -3),
## iç yamaçtan çıkar, korkuluğun (z 18.8–19.6, 1.4 m) üstünden atlar, sur dibindeki sete (y 0) varır. Gediğin önünde
## korkuluk yıkıktır: molozun dış basamaklarına ve hendeğe dökülen dile (LandWalls.tongue_y) basar.
## Eskiden hendeğin üstünde yer seviyesinde yürüyor, hendek duvarının ve korkuluğun içinden geçiyorlardı; karşı
## duvarın içinden eğik iniyorlardı.
static func ground_y(x: float, z: float) -> float:
	if absf(x - LandWalls.BREACH.x) < LandWalls.TONGUE_W * 0.5 and z >= 16.0 and z <= LandWalls.TONGUE_Z1:
		return LandWalls.outside_y(x, z)
	var y := 0.0
	if LandWalls.ditch_filled and z >= 18.4 and z <= 35.8:
		# Dolu hendek: korkuluk dövülmüş, set ile dolgu tek yüzey
		y = LandWalls.fill_y(x, z)
	elif z >= 35.7:
		y = 0.0
	elif z >= 34.8:
		y = -2.9 * pow((35.7 - z) / 0.9, 2.0)      # karşı duvarın (z 35.7–36.3) kenarından hendeğe düşüş
	elif z >= 20.8:
		y = -2.9
	elif z >= 20.3:
		y = lerpf(0.0, -2.9, (z - 20.3) / 0.5)
	elif z >= 19.7:
		y = lerpf(1.45, 0.0, (z - 19.7) / 0.6)
	elif z >= 18.7:
		y = 1.45
	elif z >= 18.4:
		y = lerpf(0.0, 1.45, (z - 18.4) / 0.3)
	# Gediğin moloz yamacı ve basamakları (iki yanda korkuluğa kadar uzanır)
	if z < 20.4:
		y = maxf(y, LandWalls.rubble_y(x, z))
	return y


func _update_runners(delta: float) -> void:
	for grp in _runners:
		var mms: Array = []
		for mi in grp[0]:
			mms.append((mi as MultiMeshInstance3D).multimesh)
		var ids: Array = grp[1]
		for j in ids.size():
			_update_runner(mms, j, int(ids[j]), delta)


const RUN_POSES := ["run_a", "run_b", "leap"]
const RUN_HATS := {"d8cfb8ff": "bork", "8a3a2eff": "bork", "6a5a48ff": "turban", "3e4c68ff": "helmet"}
var _hidden := Transform3D(Basis.from_scale(Vector3.ONE * 0.001), Vector3(0, -200, 0))
var _down := {}           # vurulan koşan: indeks → yerde kalacağı süre
const DOWN_TIME := 3.2
var _run_flame := {}      # koşan indeksi → meşale örneği
var _run_flames: MultiMesh


## Koşan: adım evresine göre iki koşu pozu arasında gidip gelir; hendeğe inişte, iç yamaçta ve korkulukta sıçrar.
## Okla vurulan geriye devrilir, bir süre yerde yatar, sonra arkadan yeniden koşar.
func _update_runner(mms: Array, j: int, i: int, delta: float) -> void:
	var r: Array = _run[i]
	var from: Vector3 = r[0]
	var to: Vector3 = r[1]
	var yaw := atan2(to.x - from.x, to.z - from.z)
	var pose := 0
	var xf: Transform3D
	if _down.has(i):
		# Yerde: devrilir (0.45 s), yatar, son 0.7 s'de toprağa/molozun arkasına gömülür; sonra arkadan yeniden koşar.
		# (Eskiden sura varan koşan o anda yok olup başa ışınlanıyordu: surda beliren-kaybolan adamlar.)
		var left: float = float(_down[i]) - delta
		var p := from.lerp(to, float(r[3]))
		var k := clampf((DOWN_TIME - left) / 0.45, 0.0, 1.0)
		p.y = ground_y(p.x, p.z) + 0.12 * k - 0.45 * clampf(1.0 - left / 0.7, 0.0, 1.0)
		xf = Transform3D(Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, -PI * 0.5 * k), p)
		pose = 1
		if left <= 0.0:
			_down.erase(i)
			r[3] = 0.0
		else:
			_down[i] = left
	else:
		var d := from.distance_to(to)
		r[3] = float(r[3]) + delta * float(r[2]) / maxf(d, 1.0)
		if float(r[3]) >= 1.0:
			# Sura/gediğe vardı: savunanlar düşürür (yok olmaz, yerde kalır)
			r[3] = 1.0
			_down[i] = DOWN_TIME
		var p := from.lerp(to, float(r[3]))
		var gy := ground_y(p.x, p.z)
		var z := p.z
		var jump := (z > 18.3 and z < 20.9) or (z > 35.0 and z < 36.5)
		var stride := fmod(_t * float(r[2]) * 0.55 + i * 0.37, 1.0)
		pose = 2 if jump else (0 if stride < 0.5 else 1)
		p.y = gy + (0.35 * sin(clampf((z - 18.3) / 2.6, 0.0, 1.0) * PI) if jump else absf(sin(stride * TAU)) * 0.08)
		# Başlangıçta arkadaki toprak tabyanın/çukurların ardından yükselerek çıkar (birden belirmez)
		p.y -= 1.8 * (1.0 - clampf(float(r[3]) * d / 2.2, 0.0, 1.0))
		xf = Transform3D(Basis(Vector3.UP, yaw), p)
	for m in mms.size():
		(mms[m] as MultiMesh).set_instance_transform(j, xf if m == pose else _hidden)
	if _run_flames and _run_flame.has(i):
		var up := not _down.has(i)
		_run_flames.set_instance_transform(int(_run_flame[i]),
			Transform3D(Basis.IDENTITY, xf * Vector3(-0.34, 2.15, 0.12)) if up else _hidden)


# ---------------------------------------------------------------- merdivenler

func _ladders() -> void:
	# Merdiven ayağı korkuluğun (z 18.8–19.6) önündeki sette, dış sur kulelerinin (x 13.5–18.5) dışında. Eskiden ayak
	# korkuluğun içindeydi ve ince direkler uzaktan görünmüyordu: tırmananlar duvarda süzülüyor gibiydi.
	var xs := [-44.0, -33.0, -24.0, -12.0, 12.0, 22.0, 31.0, 42.0]
	for x: float in xs:
		var base := Vector3(x, 0.0, 18.35)
		var top := Vector3(x, 7.7, 16.25)
		var l := Node3D.new()
		add_child(l)
		_ladder_nodes.append(l)
		var yv := (top - base).normalized()
		l.transform = Transform3D(Basis(Vector3.RIGHT, yv, Vector3.RIGHT.cross(yv)), base)
		var len := base.distance_to(top)
		for sx: float in [-0.34, 0.34]:
			Props.cyl(l, 0.075, len, Vector3(sx, len * 0.5, 0), Color("8a6440"), Vector3.ZERO, 6)
		for k in int(len / 0.45):
			Props.box(l, Vector3(0.7, 0.07, 0.07), Vector3(0, 0.3 + k * 0.45, 0), Color("8a6440"))
		# Tırmananlar: iki-üç kişi, farklı yüksekliklerde
		for k in 3:
			var s := Soldier.new([Color("8a3a2e"), Color("3e4c68"), Color("6a5a48")][k], "stand", ["bork", "helmet", "turban"][k])
			s.set_meta("no_talk", true)
			s.set_meta("climber", true)      # merdivende (altında zemin olmaması doğal)
			add_child(s)
			s.rotation.y = PI
			_climb.append({"node": s, "base": base + Vector3(0, 0, 0.22), "top": top + Vector3(0, 0, 0.3), "t": k * 0.33 + rng.randf() * 0.1,
				"speed": rng.randf_range(0.14, 0.2), "fall": -1.0, "a": 1.0})


func _update_climbers(delta: float) -> void:
	for c: Dictionary in _climb:
		var s: Soldier = c["node"]
		if not is_instance_valid(s):
			continue
		var base: Vector3 = c["base"]
		var top: Vector3 = c["top"]
		if float(c["fall"]) >= 0.0:
			# Düşüş: kollar havada, geriye devrilip sur dibine; yerde yatar, sonra toprağa gömülüp gözden çıkar
			c["fall"] = float(c["fall"]) + delta
			var f: float = c["fall"]
			var gy := ground_y(s.position.x, s.position.z)
			if s.position.y > gy + 0.15:
				if s.rig:
					s.rig.activity = "fall"
				s.set_meta("no_turn", true)   # +z kayarken kendiliğinden yaw 0'a dönüp yüzüstü duvara devrilmesin
				s.rotation.y = PI
				s.position += Vector3(0, -9.0 * f * delta * 3.0, 0.9 * delta)   # yavaş yatay kayma: düşerken dönmesin
				s.position.y = maxf(s.position.y, gy + 0.15)
				s.rotation.x = -minf(f * 3.0, 1.4)
				c["lie"] = 0.0
			else:
				s.rotation.x = -PI * 0.5
				c["lie"] = float(c.get("lie", 0.0)) + delta
				var lie: float = c["lie"]
				if lie > 2.2:
					s.position.y = gy + 0.15 - (lie - 2.2) * 0.6
				if lie > 3.0:
					c["fall"] = -1.0
					c["t"] = 0.0
					c["a"] = 0.0
					s.rotation.x = 0.0
					s.remove_meta("no_turn")
			continue
		# Yaklaşma: hendekten çıkar, korkuluğun üstünden sete atlar, merdivenin dibine koşar (eskiden dipte belirirdi)
		var a: float = c.get("a", 1.0)
		if a < 1.0:
			a = minf(a + delta * 0.45, 1.0)
			c["a"] = a
			var from := Vector3(base.x + 0.8, 0, 23.5)
			var p := from.lerp(base, a)
			var jump := p.z > 18.3 and p.z < 20.9
			p.y = ground_y(p.x, p.z) + (0.35 * sin(clampf((p.z - 18.3) / 2.6, 0.0, 1.0) * PI) if jump else 0.0)
			s.position = p
			if s.rig:
				s.rig.activity = "leap" if jump else ("run_a" if fmod(_t * 2.6, 1.0) < 0.5 else "run_b")
			continue
		c["t"] = float(c["t"]) + delta * float(c["speed"])
		var t: float = c["t"]
		var len := base.distance_to(top)
		if t >= 1.0:
			# Tepeye vardı: savunan mızrakla iter, geri düşer (ışınlanıp yeniden dipte belirmez)
			c["fall"] = 0.0
			s.position = top
			continue
		# Basamak basamak: bir el ve karşı ayak kalkar, gövde bir basamak (0.45 m) yükselir, sonra öbür taraf.
		# Basamak arasındaki duraklama kısa (eskiden her basamakta ~0,6 s durup bekliyor gibiydiler)
		var rung := t * len / 0.45
		var ph := fmod(rung, 1.0)
		s.position = base.lerp(top, (floor(rung) + smoothstep(0.1, 0.85, ph)) * 0.45 / len)
		if s.rig:
			s.rig.activity = "climb_a" if int(rung) % 2 == 0 else "climb_b"
		if t > 0.93 and s.rig:
			s.rig.activity = "leap"
		if t > 0.45 and rng.randf() < delta * 0.08 * intensity:
			c["fall"] = 0.0


# ---------------------------------------------------------------- bataryalar

func _batteries() -> void:
	for gp: Vector3 in gun_spots:
		var g := Node3D.new()
		add_child(g)
		g.position = gp
		g.look_at_from_position(gp, Vector3(gp.x * 0.3, 0, 15.0), Vector3.UP)
		Props.box(g, Vector3(3.0, 0.8, 6.0), Vector3(0, 0.4, 0), Color("4a3420"))
		Props.cyl(g, 0.8, 5.5, Vector3(0, 1.4, -0.8), Color("8c5e26"), Vector3(90, 0, 0), 14)
		Props.cyl(g, 1.0, 0.5, Vector3(0, 1.4, -3.5), Color("7a5020"), Vector3(90, 0, 0), 14, 1.2)
		Props.box(g, Vector3(7.0, 1.3, 0.5), Vector3(0, 0.65, -5.2), Color("5a4028"))
		for k in 4:
			Props.cyl(g, 0.55, 1.2, Vector3(-3.0 + k * 2.0, 0.6, -6.0), Color("7a6040"), Vector3.ZERO, 8)
		# Topçular: gerçek asker modelinin kopyası, toplu çizim
		for c in 2:
			var xs: Array = []
			for k in [c, c + 2]:
				xs.append(Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.5, 0.5)), Vector3(-2.2 + (k % 2) * 4.4, 0, 1.0 + (k / 2) * 1.5)))
			Scenery.scatter(g, Crowd.ottoman([Color("b3262d"), Color("6a4a3a")][c], "bork", ""), xs, [], _mat())
		var m := Node3D.new()
		m.position = Vector3(0, 1.4, -3.9)
		g.add_child(m)
		_guns.append({"node": g, "muzzle": m, "timer": rng.randf_range(2.0, 8.0)})


func _update_guns(delta: float) -> void:
	for gd: Dictionary in _guns:
		gd["timer"] = float(gd["timer"]) - delta * intensity
		if float(gd["timer"]) > 0.0:
			continue
		gd["timer"] = rng.randf_range(9.0, 16.0)
		_fire_gun(gd)


func _fire_gun(gd: Dictionary) -> void:
	var m: Node3D = gd["muzzle"]
	var g: Node3D = gd["node"]
	var mp := m.global_position
	var fwd := -g.global_basis.z
	Vfx.explosion(self, mp + fwd * 1.5, 1.3)
	Vfx.dust(self, mp + fwd * 3.0 + Vector3(0, 1.0, 0), 1.2)
	var fl := OmniLight3D.new()
	fl.light_color = Color("ffb060")
	fl.light_energy = 10.0
	fl.omni_range = 50.0
	add_child(fl)
	fl.global_position = mp + fwd * 2.0
	var tw := fl.create_tween()
	tw.tween_property(fl, "light_energy", 0.0, 0.5)
	tw.tween_callback(fl.queue_free)
	var cam := get_viewport().get_camera_3d()
	var dist := cam.global_position.distance_to(mp) if cam else 100.0
	Audio.sfx("cannon", clampf(-4.0 - dist * 0.08, -22.0, -4.0), rng.randf_range(0.75, 0.9))
	# Gülle yayı: sura (gediğin çevresine) düşer
	var hit := Vector3(clampf(mp.x * 0.35 + rng.randf_range(-12, 12), -wall_len * 0.4, wall_len * 0.4), rng.randf_range(3.0, 7.0), 16.2)
	hit.x = _away_from_quiet(hit.x)
	var ball := Props.ball(self, 0.35, mp + fwd * 2.0, Color("2a2624"), Vector3.ONE, 6)
	var peak := (mp + hit) * 0.5 + Vector3(0, 10.0, 0)
	var start := ball.global_position
	var tb := ball.create_tween()
	tb.tween_method(func(k: float): ball.global_position = start.lerp(peak, k).lerp(peak.lerp(hit, k), k), 0.0, 1.0, 1.4)
	tb.tween_callback(func():
		Vfx.explosion(self, hit, 0.8)
		Vfx.dust(self, hit + Vector3(0, -1.0, 1.0), 1.4)
		for k in 5:
			var st := Props.box(self, Vector3.ONE * rng.randf_range(0.2, 0.45), hit, Color("cdbd9e"))
			var v := Vector3(rng.randf_range(-3, 3), rng.randf_range(2, 5), rng.randf_range(2, 6))
			_flying.append([st, v, 2.5])
		Audio.sfx("explosion_small", -12.0, rng.randf_range(0.7, 1.0))
		ball.queue_free())


# ---------------------------------------------------------------- kuşatma donanımı

var _trebs: Array = []        # {arm: Node3D, t: float, fire_at: float, fired: bool, tip: Node3D}
var _teams: Array = []        # {root: Node3D, men: [Soldier], from, to, t, speed}


## Mancınıklar (bataryaların gerisinde), merdiven taşıyan takımlar, okçuların önünde kalkan siperleri (pavise),
## bataryaların önünde toprak tabya.
func _equipment() -> void:
	for gp: Vector3 in gun_spots:
		_earthwork(gp)
	# Ordu bloklarının (18 m arayla) arasındaki boşluklarda, iki blok sırası arasında
	for x: float in [-27.0, 27.0, -63.0, 63.0]:
		var p := Vector3(x, 0, keep.end.y + 32.6)
		if not _blocked(p.x, p.z, 4.0):
			_trebuchet(p)
	_pavises()
	for x: float in [-40.0, 38.0, -54.0, 50.0, 23.0 if keep.position.y < 30.0 else 66.0]:
		if not _blocked(x, 44.0, 2.0) and not _blocked(x, 30.0, 2.0):
			_ladder_team(x)


## Toprak tabya: bataryanın önünde eğimli toprak set, üstünde sepet siperler; toplar arasından ateş eder.
func _earthwork(gp: Vector3) -> void:
	var g := Node3D.new()
	add_child(g)
	g.position = gp
	g.look_at_from_position(gp, Vector3(gp.x * 0.3, 0, 15.0), Vector3.UP)
	var earth := Color("5e4c36")
	Props.box(g, Vector3(12.0, 1.8, 3.2), Vector3(0, 0.6, -8.4), earth, Vector3(-14, 0, 0))
	Props.box(g, Vector3(12.0, 0.8, 2.0), Vector3(0, 1.4, -8.0), earth.lightened(0.06))
	for side: float in [-1.0, 1.0]:
		Props.box(g, Vector3(3.0, 1.6, 6.0), Vector3(side * 6.8, 0.5, -5.5), earth, Vector3(0, side * 20.0, 0))
		for k in 3:
			Props.cyl(g, 0.5, 1.1, Vector3(side * (2.6 + k * 1.05), 2.3, -8.0), Color("7a6040"), Vector3.ZERO, 8)


## Karşı ağırlıklı mancınık: kalın kızaklı taban, iki A ayak, mil; kısa uçta taş dolu sandık, uzun kolda sapan.
## Arada bir kol savrulur, taş sura yay çizer.
func _trebuchet(p: Vector3) -> void:
	var r := Node3D.new()
	add_child(r)
	r.position = p
	r.look_at_from_position(p, Vector3(p.x * 0.4, 0, 15.0), Vector3.UP)
	var wood := Color("6b4a2e")
	for sx: float in [-1.3, 1.3]:
		Props.box(r, Vector3(0.35, 0.35, 6.5), Vector3(sx, 0.18, 0), wood.darkened(0.15))
		for sz: float in [-1.6, 1.6]:
			Props.box(r, Vector3(0.28, 5.6, 0.28), Vector3(sx, 2.7, sz * 0.5), wood, Vector3(sz * 9.0, 0, 0))
	for sz: float in [-2.6, 0.0, 2.6]:
		Props.box(r, Vector3(2.9, 0.3, 0.3), Vector3(0, 0.3, sz), wood.darkened(0.1))
	Props.cyl(r, 0.14, 3.0, Vector3(0, 5.2, 0), Color("3a3634"), Vector3(0, 0, 90), 8)
	var arm := Node3D.new()
	arm.position = Vector3(0, 5.2, 0)
	r.add_child(arm)
	# Kol: uzun ucu +z (geriye, yere yatık dururken), kısa ucu -z (karşı ağırlık)
	Props.box(arm, Vector3(0.3, 0.3, 9.5), Vector3(0, 0, 2.6), wood.lightened(0.05))
	var cw := Node3D.new()
	cw.position = Vector3(0, 0, -2.0)
	arm.add_child(cw)
	Props.box(cw, Vector3(1.6, 1.4, 1.4), Vector3(0, -1.2, 0), Color("5a4028"))
	Props.box(cw, Vector3(1.4, 0.3, 1.2), Vector3(0, -0.4, 0), Color("8a8478"))
	var tip := Node3D.new()
	tip.position = Vector3(0, 0, 7.3)
	arm.add_child(tip)
	Props.ball(tip, 0.28, Vector3.ZERO, Color("8a8478"), Vector3.ONE, 6)
	arm.rotation.x = 0.72
	cw.rotation.x = -0.72
	# Mancınıkçılar: çıkrık başında
	var xs: Array = []
	for k in 4:
		xs.append(Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.6, 0.6)), Vector3(-1.9 + (k % 2) * 3.8, 0, 2.2 + (k / 2) * 1.6)))
	Scenery.scatter(r, Crowd.ottoman(Color("6a5a48"), "turban", ""), xs, [], _mat())
	_trebs.append({"arm": arm, "cw": cw, "tip": tip, "t": 0.0, "wait": rng.randf_range(4.0, 14.0), "fired": false})


func _update_trebuchets(delta: float) -> void:
	for tr: Dictionary in _trebs:
		var arm: Node3D = tr["arm"]
		var cw: Node3D = tr["cw"]
		if float(tr["wait"]) > 0.0:
			tr["wait"] = float(tr["wait"]) - delta * intensity
			continue
		tr["t"] = float(tr["t"]) + delta
		var t: float = tr["t"]
		if t < 0.9:
			# Savruluş: karşı ağırlık düşer, kol öne ve yukarı döner
			var k := ease(t / 0.9, 2.2)
			arm.rotation.x = lerpf(0.72, -2.3, k)
			if not tr["fired"] and arm.rotation.x < -1.35:
				tr["fired"] = true
				_lob((tr["tip"] as Node3D).global_position)
		elif t < 7.5:
			# Geri sarılır (çıkrık): kol ağır ağır yere iner
			arm.rotation.x = lerpf(-2.3, 0.72, smoothstep(0.9, 7.5, t))
		else:
			tr["t"] = 0.0
			tr["fired"] = false
			tr["wait"] = rng.randf_range(10.0, 18.0)
		cw.rotation.x = -arm.rotation.x


## Sessiz kuşak (fragman/sinematik: kameranın önüne gülle ve taş tozu düşmesin): quiet_x çevresindeki isabet kaydırılır.
var quiet_x := INF
const QUIET_R := 12.0


func _away_from_quiet(x: float) -> float:
	if quiet_x == INF or absf(x - quiet_x) >= QUIET_R:
		return x
	return quiet_x + (QUIET_R if x >= quiet_x else -QUIET_R) * 1.2


## Mancınık taşı: yüksek yay, sura ya da surun ardına düşer, toz ve kırık taş.
func _lob(from: Vector3) -> void:
	var hit := Vector3(clampf(from.x * 0.5 + rng.randf_range(-10, 10), -wall_len * 0.4, wall_len * 0.4), rng.randf_range(4.0, 9.0), rng.randf_range(12.0, 16.2))
	hit.x = _away_from_quiet(hit.x)
	var stone := Props.ball(self, 0.4, from, Color("8a8478"), Vector3.ONE, 6)
	var peak := (from + hit) * 0.5 + Vector3(0, 28.0, 0)
	var tb := stone.create_tween()
	tb.tween_method(func(k: float): stone.global_position = from.lerp(peak, k).lerp(peak.lerp(hit, k), k), 0.0, 1.0, 2.6)
	tb.tween_callback(func():
		Vfx.dust(self, hit, 1.6)
		for k in 4:
			var st := Props.box(self, Vector3.ONE * rng.randf_range(0.2, 0.4), hit, Color("cdbd9e"))
			_flying.append([st, Vector3(rng.randf_range(-3, 3), rng.randf_range(2, 5), rng.randf_range(1, 5)), 2.5])
		Audio.sfx("explosion_small", -16.0, rng.randf_range(0.5, 0.7))
		stone.queue_free())


## Pavise (kalkan siper): hendeğin ötesinde, okçu sıralarının önünde, arkası payandalı büyük tahta kalkanlar;
## arkalarında diz çökmüş Osmanlı okçuları.
func _pavises() -> void:
	var d := Dressing.new(7711)
	var archers: Array = []
	var x := -wall_len * 0.47
	while x < wall_len * 0.47:
		var z := 39.0 + sin(x * 0.21) * 1.2
		if not _blocked(x, z, 1.0) and absf(x) > live_span:
			var col: Color = [Color("7a5634"), Color("6b4a2e"), Color("8a3a2e"), Color("3e5238")][int(absf(x) * 7.0) % 4]
			d.box(Vector3(1.1, 1.7, 0.1), Vector3(x, 0.85, z), col, Vector3(-12, 0, 0))
			d.box(Vector3(0.14, 1.72, 0.12), Vector3(x, 0.86, z - 0.02), col.darkened(0.25), Vector3(-12, 0, 0))
			d.cyl(0.03, 1.6, Vector3(x, 0.7, z + 0.55), Color("4a3020"), Vector3(40, 0, 0), 4)
			if rng.randf() < 0.55:
				archers.append([Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.2, 0.2)), Vector3(x + rng.randf_range(-0.3, 0.3), 0, z + 1.0)),
					{"side": "O", "coat": [Color("7a6448"), Color("6a5a48"), Color("a89878")][rng.randi() % 3], "hat": "turban", "arm": "bow", "pose": "sit_ground" if rng.randf() < 0.3 else ""}])
		x += rng.randf_range(2.6, 4.2)
	d.build(self)
	Crowd.place(self, archers)


## Merdiven taşıyan takım: üç asker omuzlarında uzun merdiveni arkadan sura taşır, hendeğe iner; hendek dibine
## varınca yeniden arkadan gelir (döngü).
func _ladder_team(x: float) -> void:
	var root := Node3D.new()
	add_child(root)
	var lad := Node3D.new()
	root.add_child(lad)
	for sx: float in [-0.3, 0.3]:
		Props.box(lad, Vector3(0.09, 0.09, 7.2), Vector3(sx, 0, 0), Color("8a6440"))
	for k in 15:
		Props.box(lad, Vector3(0.6, 0.06, 0.06), Vector3(0, 0, -3.4 + k * 0.48), Color("8a6440"))
	var men: Array = []
	for k in 3:
		var s := Soldier.new([Color("d8cfb8"), Color("6a5a48"), Color("8a3a2e")][k], "stand", ["bork", "turban", "bork"][k])
		s.set_meta("no_talk", true)
		s.set_meta("shoulder_load", true)
		root.add_child(s)
		s.rig.activity = "carry"
		men.append(s)
	var from := Vector3(x + rng.randf_range(-2, 2), 0, 58.0 if not _blocked(x, 58.0) else 46.0)
	_teams.append({"root": root, "lad": lad, "men": men, "from": from, "to": Vector3(x * 0.98, 0, 22.0), "t": rng.randf(), "speed": rng.randf_range(2.2, 2.8)})


func _update_teams(delta: float) -> void:
	for tm: Dictionary in _teams:
		var from: Vector3 = tm["from"]
		var to: Vector3 = tm["to"]
		tm["t"] = fmod(float(tm["t"]) + delta * float(tm["speed"]) / maxf(from.distance_to(to), 1.0), 1.0)
		var c := from.lerp(to, float(tm["t"]))
		# Uçlarda birden belirip kaybolmasınlar: arkadaki tabyanın ardından yükselir, hendeğin dibinde gözden çıkar
		var dl := from.distance_to(to)
		var tt: float = tm["t"]
		var dy := -1.8 * (1.0 - clampf(tt * dl / 2.5, 0.0, 1.0)) - 1.8 * (1.0 - clampf((1.0 - tt) * dl / 2.5, 0.0, 1.0))
		var fwd := (to - from).normalized()
		var yaw := atan2(fwd.x, fwd.z)
		var side := Vector3(cos(yaw), 0, -sin(yaw))
		var men: Array = tm["men"]
		for k in men.size():
			var s: Soldier = men[k]
			var p := c + fwd * (2.4 - k * 2.4)
			p.y = ground_y(p.x, p.z) + dy
			s.position = p
			s.rotation.y = yaw
		var lad: Node3D = tm["lad"]
		var front := c + fwd * 2.4
		var back := c - fwd * 2.4
		front.y = ground_y(front.x, front.z) + 1.5 + dy
		back.y = ground_y(back.x, back.z) + 1.5 + dy
		lad.global_position = (front + back) * 0.5 + side * 0.36
		lad.look_at(lad.global_position + (front - back), Vector3.UP)


# ---------------------------------------------------------------- savunanlar ve oklar

func _defenders() -> void:
	var xf: Array = []
	var cols: Array = []
	var x := -wall_len * 0.5
	while x < wall_len * 0.5:
		# Dış kuleler (x ±16, 5 m genişlik) içine asker konmaz (kule duvarından kol, kafa taşıyordu). Gediğin kırık
		# kenarı (x ±3,5..6,5) basamaklı: surun tam boylu üstü ±7,2'de başlar (eskiden ±5'te duranlar boşlukta kalıyordu)
		if absf(x) > maxf(LandWalls.BREACH_W * 0.5 + LandWalls.EDGE_W + 1.1, live_span) and absf(absf(x) - 16.0) > 3.4:
			xf.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE), Vector3(x + rng.randf_range(-0.4, 0.4), 8.0, 15.2)))
			cols.append([Color("7a2a24"), Color("5a4a3a"), Color("3a4a6a")][rng.randi() % 3])
		x += rng.randf_range(1.6, 3.2)
	# İç sur (yüksek) üstünde de
	x = -wall_len * 0.5
	while x < wall_len * 0.5:
		if absf(absf(x) - 24.0) > 5.2:
			xf.append(Transform3D(Basis.IDENTITY, Vector3(x, 12.0, -1.8)))
			cols.append([Color("7a2a24"), Color("5a4a3a")][rng.randi() % 2])
		x += rng.randf_range(2.5, 4.5)
	var items: Array = []
	for i in xf.size():
		var arm: String = ["spear_shield", "bow", "spear"][i % 3]
		# Dış surdaki okçular yayı germiş durur (ovaya nişan); iç surdakiler bekler
		var outer := (xf[i] as Transform3D).origin.z > 10.0
		items.append([xf[i], {"side": "B", "coat": cols[i], "arm": arm, "pose": "aim" if arm == "bow" and outer else ""}])
		if arm == "bow" and (xf[i] as Transform3D).origin.z > 10.0:
			_archer_spots.append((xf[i] as Transform3D).origin + Vector3(0, 1.45, 0.35))
	var sway := preload("res://scripts/level/far_sway.gd").new()
	add_child(sway)
	for n in Crowd.place(self, items):
		_defender_nodes.append(n)
		if n is MultiMeshInstance3D:
			sway.add(n)


## Surdaki okçular: hücum edenlere tek tek nişan alır. Oku koşanın varacağı yere atar; kimi ıskalar (ok toprağa
## saplanır), kimi vurur (asker geriye devrilir, bir süre yatar). Surun gerisinden okçu yoksa (Garrison) sur çizgisi.
var _archer_spots: Array = []
var _archer_t := 1.0


func _update_archers(delta: float) -> void:
	_archer_t -= delta * (0.4 + intensity)
	if _archer_t > 0.0 or _run.is_empty():
		return
	_archer_t = rng.randf_range(0.25, 0.7)
	# Hedef: surun önündeki ovada koşan (hendek ve ötesi), yerde yatmayan biri
	var i := -1
	for tries in 8:
		var c := rng.randi() % _run.size()
		if _down.has(c):
			continue
		var r: Array = _run[c]
		var p := (r[0] as Vector3).lerp(r[1], float(r[3]))
		if p.z > 21.0 and p.z < 42.0:
			i = c
			break
	if i < 0:
		return
	var r: Array = _run[i]
	var from_r: Vector3 = r[0]
	var to_r: Vector3 = r[1]
	var flight := rng.randf_range(0.8, 1.1)
	var d := from_r.distance_to(to_r)
	var tk := minf(float(r[3]) + flight * float(r[2]) / maxf(d, 1.0), 0.999)
	var aim := from_r.lerp(to_r, tk)
	aim.y = ground_y(aim.x, aim.z)
	var hit := rng.randf() < 0.45
	if hit:
		aim.y += 1.2
	else:
		aim += Vector3(rng.randf_range(-1.6, 1.6), 0, rng.randf_range(-1.2, 1.6))
		aim.y = ground_y(aim.x, aim.z)
	var src := Vector3(clampf(aim.x + rng.randf_range(-5, 5), -wall_len * 0.45, wall_len * 0.45), 9.45, 15.55)
	if not _archer_spots.is_empty():
		var best: Vector3 = _archer_spots[0]
		for sp: Vector3 in _archer_spots:
			if absf(sp.x - aim.x) < absf(best.x - aim.x):
				best = sp
		if absf(best.x - aim.x) < 14.0:
			src = best
	elif absf(src.x) < live_span:
		src.x = signf(src.x if src.x != 0.0 else 1.0) * (live_span + 1.0)
	var v := (aim - src) / flight
	v.y = (aim.y - src.y + 0.5 * 9.8 * flight * flight) / flight
	var mi := MeshInstance3D.new()
	mi.mesh = arrow_mesh()
	mi.material_override = _mat()
	add_child(mi)
	mi.global_position = src
	_maybe_flame(mi)
	_flying.append([mi, v, flight + 0.05, "arrow", aim.y, i if hit else -1])


## Ok yağmuru: surdan kalkan oklar yay çizip hedef çemberine düşer ve saplanıp kalır. Uçuş süresini döndürür.
## inward: oklar dışarıdaki okçulardan (hendek ve ova) kalkar, surların üstünden aşıp içeri düşer.
## drop > 0: oklar surun üstünden dik iner ve drop saniyede yere saplanır (fragman: koşanın çevresine tam o anda düşer).
func volley(target: Vector3, radius := 6.0, count := 40, inward := false, drop := 0.0) -> float:
	var flight := VOLLEY_FLIGHT if not inward else 3.1
	if drop > 0.0:
		flight = drop
	for i in count:
		var from := Vector3(clampf(target.x + rng.randf_range(-18, 18), -wall_len * 0.45, wall_len * 0.45), rng.randf_range(8.8, 12.5), rng.randf_range(-1.5, 15.6))
		if inward:
			from = Vector3(target.x + rng.randf_range(-14, 14), rng.randf_range(0.8, 2.6), rng.randf_range(27.0, 42.0))
		var a := rng.randf() * TAU
		var r := sqrt(rng.randf()) * radius
		var to := target + Vector3(cos(a) * r, 0, sin(a) * r)
		if drop > 0.0:
			from = to + Vector3(rng.randf_range(-1.5, 1.5), rng.randf_range(11.0, 14.0), rng.randf_range(6.0, 9.0))
		var t := flight * rng.randf_range(0.85, 1.15)
		var v := (to - from) / t
		v.y = (to.y - from.y + 0.5 * 9.8 * t * t) / t
		var mi := MeshInstance3D.new()
		mi.mesh = arrow_mesh()
		mi.material_override = _mat()
		add_child(mi)
		mi.global_position = from
		_maybe_flame(mi)
		_flying.append([mi, v, t + 0.05, "arrow", to.y])
		if i % 8 == 0:
			Audio.sfx("whoosh_fly", -18.0, rng.randf_range(0.9, 1.4))
	return flight


func _update_flying(delta: float) -> void:
	for k in range(_flying.size() - 1, -1, -1):
		var f: Array = _flying[k]
		var n: Node3D = f[0]
		if not is_instance_valid(n):
			_flying.remove_at(k)
			continue
		var v: Vector3 = f[1]
		v.y -= 9.8 * delta
		f[1] = v
		n.global_position += v * delta
		f[2] = float(f[2]) - delta
		var is_arrow := f.size() > 3
		if is_arrow and v.length() > 0.1:
			n.look_at(n.global_position + v, Vector3.UP if absf(v.normalized().y) < 0.98 else Vector3.RIGHT)
			n.rotate_object_local(Vector3.UP, PI)
		var ground: float = f[4] if is_arrow else -0.5
		if n.global_position.y <= ground or float(f[2]) <= -1.0:
			_flying.remove_at(k)
			if is_arrow and f.size() > 5 and int(f[5]) >= 0:
				# Okçunun oku koşana isabet etti: asker devrilir (ok onunla gider)
				if not _down.has(int(f[5])):
					_down[int(f[5])] = DOWN_TIME
				n.queue_free()
			elif is_arrow:
				# Uçla toprağa saplanır: gövdenin yarısı dışarıda, iniş açısıyla
				var dir := v.normalized()
				n.global_position = Vector3(n.global_position.x, ground, n.global_position.z) - dir * 0.18
				_stuck.append([n, 18.0])
			else:
				n.queue_free()


func _update_stuck(delta: float) -> void:
	for k in range(_stuck.size() - 1, -1, -1):
		_stuck[k][1] = float(_stuck[k][1]) - delta
		# Yanan ok saplandıktan sonra birkaç saniye yanar, söner
		if float(_stuck[k][1]) < 15.0 and is_instance_valid(_stuck[k][0]):
			var fl := (_stuck[k][0] as Node).get_node_or_null("Flame") as Node3D
			if fl:
				fl.queue_free()
		if float(_stuck[k][1]) <= 0.0:
			var n: Node3D = _stuck[k][0]
			if is_instance_valid(n):
				n.queue_free()
			_stuck.remove_at(k)


# ---------------------------------------------------------------- duman

func _smoke() -> void:
	for p: Vector3 in [Vector3(-30, 6, 12), Vector3(-8, 4, 20), Vector3(18, 6, 12), Vector3(40, 3, 24), Vector3(-50, 2, 60), Vector3(55, 2, 70)]:
		Scenery.smoke_column(self, p, night)
	if not night:
		return
	# Gece yangınları: surun üstünde tutuşmuş çalı demetleri ve enkaz, hendekte yanan merdiven ve kalas yığınları;
	# duvar yüzüne turuncu ışık düşürür (canlı savunanların alanı ve gedik boş kalır)
	for x: float in [-39.0, -22.0, 27.0, 44.0]:
		if absf(x) > live_span + 2.0:
			Vfx.fire(self, Vector3(x, LandWalls.OUTER_H + 0.1, 15.0), 0.8)
	for p: Vector3 in [Vector3(-9.0, -2.8, 27.0), Vector3(12.0, -2.8, 31.0), Vector3(-30.0, -2.8, 24.0)]:
		if not _blocked(p.x, p.z, 0.5):
			Vfx.fire(self, p, 1.1)


## Şehir düştü: hücum durur. Koşanlar, tırmananlar, savunanlar, merdivenler ve yerdeki oklar kalkar;
## ordu blokları ve sancaklar kalır (Fatih'in girişini seyreder).
func victory() -> void:
	set_process(false)
	for grp in _runners:
		for mi in grp[0]:
			(mi as Node3D).visible = false
	for c: Dictionary in _climb:
		if is_instance_valid(c["node"]):
			(c["node"] as Node3D).visible = false
	for n in _defender_nodes:
		n.visible = false
	for n in _ladder_nodes:
		n.visible = false
	for tm: Dictionary in _teams:
		(tm["root"] as Node3D).visible = false
	for f in _flying:
		if is_instance_valid(f[0]):
			(f[0] as Node).queue_free()
	_flying.clear()
	for f in _stuck:
		if is_instance_valid(f[0]):
			(f[0] as Node).queue_free()
	_stuck.clear()


func _process(delta: float) -> void:
	_t += delta
	for i in _torch_lights.size():
		_torch_lights[i].light_energy = 1.3 + 0.35 * sin(_t * (7.0 + i) + i * 1.7) + 0.2 * sin(_t * 13.0 + i)
	_update_runners(delta)
	_update_climbers(delta)
	_update_archers(delta)
	_update_trebuchets(delta)
	_update_teams(delta)
	_update_guns(delta)
	_update_flying(delta)
	_update_stuck(delta)


# ---------------------------------------------------------------- gece: meşaleler, yanan oklar, toz

static func flame_mat() -> StandardMaterial3D:
	if _flame_mat == null:
		_flame_mat = StandardMaterial3D.new()
		_flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_flame_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_flame_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		_flame_mat.vertex_color_use_as_albedo = true
		_flame_mat.albedo_color = Color(1.0, 0.62, 0.22, 0.95)
		_flame_mat.emission_enabled = true
		_flame_mat.emission = Color("ff8a2a")
		_flame_mat.emission_energy_multiplier = 2.5
		_flame_mat.no_depth_test = false
	return _flame_mat


## Yanan ok: ucunda turuncu alev (gece okların bir kısmı; ovayı ve hendeği aydınlatır).
func _maybe_flame(arrow: Node3D) -> void:
	var ratio := fire_ratio if fire_ratio >= 0.0 else (0.35 if night else 0.0)
	if rng.randf() >= ratio:
		return
	var q := SphereMesh.new()
	q.radius = 0.06
	q.height = 0.2
	q.radial_segments = 6
	q.rings = 3
	var f := MeshInstance3D.new()
	f.name = "Flame"
	f.mesh = q
	f.material_override = flame_mat()
	f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	f.position = Vector3(0, 0.04, 0.38)
	arrow.add_child(f)


## Ordunun elinde meşaleler: blokların arasında yüzlerce alev (toplu çizim) ve arkada, ordugâhın önünde uzanan
## meşale dizisi; sekiz titreyen ışık zemine ve askerlere turuncu düşer.
func _torches() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 29051453
	var flames: Array = []
	var poles: Array = []
	for i in _army_pts.size():
		if r.randf() > 0.16:
			continue
		var p: Vector3 = _army_pts[i] + Vector3(0.32, 0, 0.1)
		p.y = ground_y(p.x, p.z)
		poles.append(Transform3D(Basis.IDENTITY, p + Vector3(0, 1.55, 0)))
		flames.append(Transform3D(Basis.from_scale(Vector3.ONE * r.randf_range(0.8, 1.25)), p + Vector3(0, 2.45, 0)))
	# Arkada, ordugâhın önünde: kilometrelerce meşale ve ateş (uzak ışık noktaları)
	for i in 420:
		var x := r.randf_range(-190.0, 190.0)
		var z := r.randf_range(keep.end.y + 70.0, keep.end.y + 170.0)
		flames.append(Transform3D(Basis.from_scale(Vector3.ONE * r.randf_range(1.4, 2.6)), Vector3(x, ground_y(x, z) + 2.2, z)))
	var pole := CylinderMesh.new()
	pole.top_radius = 0.025
	pole.bottom_radius = 0.03
	pole.height = 1.3
	pole.radial_segments = 4
	pole.rings = 1
	var pc: Array = []
	pc.resize(poles.size())
	pc.fill(Color("3a2a1c"))
	Scenery.scatter(self, pole, poles, pc)
	# Alev: sivri, dik bir damla (her yönden aynı görünür; toplu çizimde billboard kullanılamaz)
	var q := SphereMesh.new()
	q.radius = 0.14
	q.height = 0.5
	q.radial_segments = 6
	q.rings = 3
	var fc: Array = []
	for i in flames.size():
		fc.append(Color(1.0, r.randf_range(0.6, 0.85), r.randf_range(0.25, 0.4)))
	var mm := Scenery.scatter(self, q, flames, fc, flame_mat())
	mm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in 8:
		if _army_pts.is_empty():
			break
		var p: Vector3 = _army_pts[r.randi() % _army_pts.size()]
		var l := OmniLight3D.new()
		l.light_color = Color("ff9a48")
		l.omni_range = 16.0
		l.light_energy = 1.4
		l.shadow_enabled = false
		l.position = p + Vector3(0, 3.0, 0)
		add_child(l)
		_torch_lights.append(l)


## Surun dibinde ve hendekte asılı toz ve barut dumanı: yavaş kıvrılan, alçak, kahverengi-gri bulutlar.
func _dust_line() -> void:
	var puff := SphereMesh.new()
	puff.radius = 1.0
	puff.height = 1.6
	puff.radial_segments = 8
	puff.rings = 4
	var m := StandardMaterial3D.new()
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.vertex_color_use_as_albedo = true
	m.albedo_color = Color(1, 1, 1, 1)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	puff.material = m
	var g := Gradient.new()
	g.set_color(0, Color(0.42, 0.37, 0.31, 0.0))
	g.add_point(0.25, Color(0.42, 0.37, 0.31, 0.22))
	g.add_point(0.7, Color(0.36, 0.33, 0.30, 0.16))
	g.set_color(g.get_point_count() - 1, Color(0.3, 0.3, 0.3, 0.0))
	for x: float in [-66.0, -44.0, -24.0, -8.0, 8.0, 24.0, 44.0, 66.0]:
		var d := CPUParticles3D.new()
		d.amount = 18
		d.lifetime = 7.0
		d.preprocess = 7.0
		d.mesh = puff
		d.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		d.emission_box_extents = Vector3(9.0, 0.4, 3.5)
		d.direction = Vector3(0.3, 1, 0)
		d.spread = 40.0
		d.initial_velocity_min = 0.2
		d.initial_velocity_max = 0.6
		d.gravity = Vector3(0.15, 0.08, 0)
		d.scale_amount_min = 1.6
		d.scale_amount_max = 3.2
		d.color_ramp = g
		d.position = Vector3(x, ground_y(x, 21.0) + 0.8, 21.0)
		d.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(d)
