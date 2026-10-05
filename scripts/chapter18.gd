extends Node3D
## Bölüm 18 — Fıçı Köprü (Tolga · Mayıs başı 1453, Haliç'in iç ucu, Osmanlı kıyısı). docs/SIEGE.md §3.
##
## Osmanlılar Haliç'in en iç kısmında, fıçıları ikişer ikişer bağlayıp üstüne kalas döşeyerek bir köprü kurar;
## köprünün üstüne top konur (Kritovoulos). Tolga köprücü ustanın yanında çalışır: her bölümde
##   fıçı çiftini suya yuvarla (E) · iki kez halatla bağla (zamanlama, E) · kalasları döşe (E).
## Bağ kaçarsa bölüm eğri durur. Altı bölüm sonunda top köprüye çekilir. Tespit karesi: köprünün üstündeki top.
##   18.1 Köprü sağlam (en çok iki kaçan bağ) · 18.2 Köprü eğri ama ayakta
## İlk gece nöbetçilerle dost olunduysa (guards_like_tolga, 4a) Hasan ile Hüseyin fıçıları tutar: bağın zamanı genişler.
## Kaçan bir bağ çantadaki koli bandıyla sarılabilir (bir şerit): bölüm doğrulur, kaçan sayılmaz.
##   --autotest[=crooked|twins|near|tape]   (varsayılan: 18.1; near: bağlar ikizsiz pencerenin hemen dışında,
##   twins: aynı bağlar ikizlerle tutar, tape: ilk dört bağ kaçar, üçü bantla sarılır)

const SECTIONS := 6
const SEC_LEN := 3.0
const SHORE_Z := 0.0
const DECK_Y := 0.7
const GROUND_Y := 0.3          # kıyı zemininin üstü (karakterler ve eşyalar buraya basar, zemine gömülmez)
const WIN := 0.16
const WIN_TWINS := 0.23        # ikizler fıçıyı tutar: bağın yeşil bandı genişler

var player: Player
var hud: Hud
var usta: Person
var workers: Array[Person] = []
var cannon: Node3D
var sections: Array[Node3D] = []
var phase := "intro"
var _outcome := ""
var built := 0
var step := ""              # "barrels" · "lash" · "planks"
var lashes := 0
var misses := 0
var _gauge: Control
var _g := -1.0
var _g_dir := 1.0
var _g_center := 0.5
var _pile_barrel: Node3D
var _pile_plank: Node3D
var _lash_point: Node3D
var _photo := ""
var cam: TespitCam
var _t := 0.0
## 4a'nın nöbetçileri (guards_like_tolga): köprü başında fıçıları tutarlar
var hasan: Soldier
var huseyin: Soldier
var taped := 0                 # bantla sarılan kaçan bağlar


func _ready() -> void:
	GameState.snapshot(18)
	if GameState.autotest and GameState.autotest_variant in ["twins", "near"]:
		GameState.flags["guards_like_tolga"] = GameState.autotest_variant == "twins"
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	# Gün ortası, açık gök
	var we := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("4a86c8")
	sm.sky_horizon_color = Color("bcd8ec")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	e.fog_enabled = true
	e.fog_light_color = Color("c8d8e8")
	e.fog_density = 0.0022
	we.environment = e
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)
	# Haliç: su, Osmanlı kıyısı (tepeler, ordugâh, köprü malzemesi, kadırgalar), karşıda Haliç surları ve Blakherna
	# Tek harita: köprünün yeri Haliç'in en dar yeri (62 m); çevre (şehir, Blakherna, Galata, karşı kıyılar) dünyadan
	Horn.build(self, World1453.BRIDGE_W, Rect2(-62.0, -44.0, 124.0, 44.5), Vector2.ZERO, 1801, true)
	World1453.build(self, "horn_bridge", [Rect2(-Horn.WORLD_E, -Horn.WORLD_E, Horn.WORLD_E * 2.0, Horn.WORLD_E + World1453.BRIDGE_W + 3.0)], false)
	var ground := Props.solid(self, Vector3(120, 1.0, 40), Vector3(0, -0.2, SHORE_Z - 20.0), Color.WHITE)
	ground.get_child(0).visible = false
	Props.box(self, Vector3(120, 0.6, 4.0), Vector3(0, -0.3, SHORE_Z + 1.2), Color("6e5e42"), Vector3(-8, 0, 0))
	# Çalışma alanının iki yanında fıçı istifleri (katı; aralarında geçit: ötesi kıyı ve ordugâh, yürünür); su kenarında
	# görünmez korkuluk
	var dd := Dressing.new(1802)
	for sx: float in [-1.0, 1.0]:
		var z := -28.0
		var n := 0
		while z < -2.0:
			n += 1
			if n % 3 == 0:
				z += 3.4
				continue        # geçit
			dd.at(Vector3(sx * 24.5, 0.3, z), PI * 0.5)
			for row in 3:
				for k in 4 - row:
					dd.cyl(0.4, 1.2, Vector3(-1.2 + k * 0.82 + row * 0.41, 0.4 + row * 0.7, 0), Color("7a5634").darkened(randf() * 0.15), Vector3(90, 0, 0), 10)
			dd.solid(Vector3(3.4, 2.0, 1.2), Vector3(0, 0.7, 0))
			z += 3.4
	# Alanın içi (köprü yolunun iki yanı): kalas istifleri, marangoz tezgâhı, halat, katran kazanı, dikili fıçılar
	for spec in [[Vector3(13.0, 0.3, -9.0), 0.2], [Vector3(16.5, 0.3, -16.0), -0.3]]:
		dd.at(spec[0], spec[1])
		for i in 8:
			dd.box(Vector3(0.5, 0.1, 3.8), Vector3((i % 4) * 0.52 - 0.8, 0.06 + (i / 4) * 0.12, 0), Color("9a7248").darkened((i % 3) * 0.05))
		dd.solid(Vector3(2.1, 0.25, 3.8), Vector3(-0.02, 0.125, 0))      # istifin içinden yürünmesin (üstüne çıkılır)
		dd.rope_coil(Vector3(1.8, 0, 1.4))
	dd.at(Vector3(12.0, 0.3, -22.0), 0.4)
	dd.box(Vector3(2.4, 0.12, 0.9), Vector3(0, 0.8, 0), Color("7a5634"))
	dd.solid(Vector3(2.4, 0.86, 0.9), Vector3(0, 0.43, 0))      # tezgâh
	for k in 4:
		dd.box(Vector3(0.1, 0.8, 0.1), Vector3(-1.1 + (k % 2) * 2.2, 0.4, -0.35 + (k / 2) * 0.7), Color("5a3e26"))
	dd.box(Vector3(1.4, 0.08, 0.35), Vector3(0.2, 0.9, 0.1), Color("b8905a"))
	dd.at(Vector3(-14.0, 0.3, -12.0), 0.0)
	for k in 7:
		dd.cyl(0.4, 0.95, Vector3((k % 4) * 0.84 - 1.2, 0.48, (k / 4) * 0.84), Color("7a5634").darkened(randf() * 0.12), Vector3.ZERO, 10)
		dd.solid(Vector3(0.72, 0.95, 0.72), Vector3((k % 4) * 0.84 - 1.2, 0.475, (k / 4) * 0.84))      # dikili fıçılar katı
	dd.at(Vector3(-15.0, 0.3, -22.0), 0.0)
	dd.cyl(0.6, 0.7, Vector3(0, 0.55, 0), Color("2a2622"), Vector3.ZERO, 10)
	dd.solid(Vector3(1.1, 0.9, 1.1), Vector3(0, 0.45, 0))      # katran kazanı
	for k in 5:
		var a := TAU * k / 5.0
		dd.box(Vector3(0.6, 0.12, 0.14), Vector3(cos(a) * 0.5, 0.08, sin(a) * 0.5), Color("4a3020"), Vector3(0, -rad_to_deg(a), 0))
	dd.build(self)
	Scenery.smoke_column(self, Vector3(-15.0, 0.8, -22.0), false)
	var men: Array = []
	for spec in [[Vector3(12.8, 0.3, -21.2), PI], [Vector3(-13.8, 0.3, -21.0), PI * 0.2], [Vector3(15.2, 0.3, -9.4), -1.2],
			[Vector3(-12.4, 0.3, -10.8), 0.8], [Vector3(-10.5, 0.3, -18.0), 2.4]]:
		men.append([Transform3D(Basis(Vector3.UP, spec[1]), spec[0]), [Color("8a6a4a"), Color("6a4a3a"), Color("7a5a3a")][men.size() % 3]])
	Horn.figures(self, men, true)      # çalışma alanının içindeki işçiler: içlerinden geçilmesin
	# Alanın iki yanı (x 27..60, kıyı düzlüğü): köprü malzemesi yığınları ve başında işçiler, fıçı taşıyan sıralar,
	# kıyıda seyreden sancaklı bölükler. Kıyı ordugâhı (Horn) buradan sonra başlar; arası boş kalmasın.
	var sd := Dressing.new(1803)
	sd.chunk = 160.0
	var crowd: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 1804
	for sx: float in [-1.0, 1.0]:
		var x := 27.5
		while x < 58.0:
			var p := Vector3(sx * x, GROUND_Y, rng.randf_range(-24.0, -12.0))
			sd.at(p, rng.randf_range(-0.3, 0.3) + (PI * 0.5 if rng.randf() < 0.5 else 0.0))
			match rng.randi() % 4:
				0, 1:
					for row in 3:
						for k in 5 - row:
							sd.cyl(0.4, 1.2, Vector3(-1.6 + k * 0.82 + row * 0.41, 0.4 + row * 0.7, 0), Horn.WOOD.darkened(rng.randf() * 0.15), Vector3(90, 0, 0), 10)
				2:
					for i in 7:
						sd.box(Vector3(0.5, 0.1, 3.6), Vector3(0, 0.06 + i * 0.12, 0), Color("9a7248").darkened((i % 3) * 0.05))
					sd.rope_coil(Vector3(1.2, 0, 0.8))
				_:
					sd.box(Vector3(1.6, 0.14, 2.6), Vector3(0, 0.75, 0), Horn.WOOD)
					for wx: float in [-0.95, 0.95]:
						sd.cyl(0.6, 0.12, Vector3(wx, 0.6, 0), Color("4a3020"), Vector3(0, 0, 90), 10)
					for k in 3:
						sd.cyl(0.36, 0.85, Vector3(-0.4 + (k % 2) * 0.8, 1.25, -0.7 + k * 0.7), Horn.WOOD.darkened(0.1), Vector3.ZERO, 10)
			for k in rng.randi_range(2, 4):
				var q := p + Vector3(rng.randf_range(-2.4, 2.4), 0, rng.randf_range(2.2, 3.4) * (1.0 if k % 2 == 0 else -1.0))
				crowd.append([Transform3D(Basis(Vector3.UP, rng.randf() * TAU), q), Horn.COATS[rng.randi() % Horn.COATS.size()]])
			x += rng.randf_range(6.5, 9.5)
		# Fıçı taşıyan sıra: yığınlardan su kenarına doğru (kıyıya dik), omuz omuza
		for k in 7:
			var q := Vector3(sx * (40.0 + rng.randf_range(-0.3, 0.3)), GROUND_Y, -8.0 + k * 1.1)
			crowd.append([Transform3D(Basis(Vector3.UP, rng.randf_range(-0.2, 0.2)), q), Color("8a6a4a") if k % 2 == 0 else Color("6a4a3a")])
		# Seyreden bölük: suya (+Z) bakar; yanında sancak
		var c := Vector3(sx * 48.0, GROUND_Y, -32.0)
		var coat: Color = Color("b3262d") if sx < 0.0 else Color("2f5fa8")
		for i in 7:
			for j in 4:
				crowd.append([Transform3D(Basis(Vector3.UP, rng.randf_range(-0.1, 0.1)), c + Vector3((i - 3) * 1.5 + rng.randf_range(-0.1, 0.1), 0, -j * 1.5)), coat])
		var fp := c + Vector3(-sx * 6.2, 0, 0.4)
		sd.at(Vector3.ZERO, 0.0)
		sd.cyl(0.05, 5.5, fp + Vector3(0, 2.75, 0), Color("4a3420"), Vector3.ZERO, 5)
		sd.ball(0.12, fp + Vector3(0, 5.6, 0), Color("d8b040"))
		sd.box(Vector3(2.1, 1.4, 0.03), fp + Vector3(1.05 * sx, 4.6, 0), Color("2e6a3a") if sx < 0.0 else Color("b3262d"))
	# Alanın içi: arkada (çadırların önünde) bekleyen iki bölük, kıyıda iki yanda köprüyü seyreden askerler
	for sx: float in [-1.0, 1.0]:
		var c := Vector3(sx * 17.0, GROUND_Y, -27.0)
		for i in 6:
			for j in 3:
				crowd.append([Transform3D(Basis(Vector3.UP, rng.randf_range(-0.12, 0.12)),
					c + Vector3((i - 2.5) * 1.4 + rng.randf_range(-0.1, 0.1), 0, -j * 1.5)), Color("3a6b3a") if sx < 0.0 else Color("b3262d")])
		var blk := Props.solid(self, Vector3(8.6, 2.0, 4.0), c + Vector3(0, 1.0, -1.5), Color.WHITE)
		blk.get_child(0).visible = false
		blk.set_meta("no_climb", true)
		for k in 4:
			var o := Soldier.new([Color("8a6a4a"), Color("b3262d"), Color("6a4a3a"), Color("2f5fa8")][k], "stand", ["bork", "turban"][(k + int(sx)) % 2])
			o.position = Vector3(sx * (12.0 + k * 2.5), GROUND_Y, -2.2 - (k % 2) * 0.6)
			o.rotation.y = -sx * 0.25
			add_child(o)
			if k % 2 == 0:
				o.equip("spear")
	sd.build(self)
	Horn.figures(self, crowd)
	# Yalnız su kenarı (kıyıdan düşülmesin); yanlar ve arka açık
	for spec in [[Vector3(21.0, 4.0, 0.4), Vector3(-13.1, 2.0, SHORE_Z + 0.3)], [Vector3(21.0, 4.0, 0.4), Vector3(13.1, 2.0, SHORE_Z + 0.3)]]:
		var b := Props.solid(self, spec[0], spec[1], Color.WHITE)
		b.get_child(0).visible = false
		b.set_meta("no_climb", true)
	# Osmanlı kıyısı: çadırlar (alanın arka kenarı)
	for i in 6:
		var t := Night.tent(self, Vector3(-20.0 + i * 8.0, GROUND_Y, SHORE_Z - 34.0 - (i % 2) * 3.0), 2.4)
		t.rotation.y = i * 1.1
	# Köprünün kıyı ucu: kazıklar, iskele başı
	Props.set_pattern(Props.solid(self, Vector3(5.0, 0.4, 3.0), Vector3(0, DECK_Y - 0.2, SHORE_Z + 0.5), Color.WHITE), Color("8a6440"), "wood")
	for sx: float in [-2.2, 2.2]:
		Props.make_solid(Props.cyl(self, 0.18, 3.0, Vector3(sx, 0.2, SHORE_Z + 1.8), Color("5a3e26"), Vector3.ZERO, 6))
	# İskele başının iki yanında korkuluk: kıyıdaki sınırla köprünün korkuluğu arası açıktı, yandan suya düşülüyordu
	for sx: float in [-1.0, 1.0]:
		Props.solid(self, Vector3(0.1, 0.9, 1.9), Vector3(sx * 2.45, DECK_Y + 0.45, SHORE_Z + 1.05), Color("6a4a2c"))
	# Kıyıdan iskele başına kalas rampa (0.4 m'lik basamak yürünerek çıkılsın)
	Props.set_pattern(Props.ramp(self, Vector3(0, GROUND_Y, SHORE_Z - 2.8), Vector3(0, DECK_Y, SHORE_Z - 1.0), 4.6, Color.WHITE), Color("8a6440"), "wood")
	# Bölümler (her biri: iki fıçı, iki halat bağı, kalaslar); yapıldıkça görünür
	for i in SECTIONS:
		var s := Node3D.new()
		s.position = Vector3(0, 0, SHORE_Z + 2.0 + SEC_LEN * (i + 0.5))
		add_child(s)
		var barrels := Node3D.new()
		barrels.name = "Barrels"
		barrels.visible = false
		s.add_child(barrels)
		for sx: float in [-1.3, 1.3]:
			Props.cyl(barrels, 0.55, 2.2, Vector3(sx, 0.15, 0), Color("7a5634"), Vector3(90, 0, 0), 12)
			for zz: float in [-0.7, 0.7]:
				Props.cyl(barrels, 0.56, 0.08, Vector3(sx, 0.15, zz), Color("3a3634"), Vector3(90, 0, 0), 12)
		var rope := Node3D.new()
		rope.name = "Rope"
		rope.visible = false
		s.add_child(rope)
		# İki bağ (her düğümde biri): fıçıların üstünden geçen kenevir halat ve fıçılara dolanan sargılar
		rope.visible = true
		for zz: float in [-0.6, 0.6]:
			var lash := Node3D.new()
			lash.position = Vector3(0, 0, zz)
			lash.visible = false
			rope.add_child(lash)
			Props.cyl(lash, 0.04, 3.0, Vector3(0, 0.66, 0), Color("9a7a4a"), Vector3(0, 0, 90), 6)
			for sx: float in [-1.3, 1.3]:
				Props.ring(lash, 0.56, 0.62, Vector3(sx, 0.15, 0), Color("8a6a3a"), Vector3(90, 0, 0))
				Props.ring(lash, 0.56, 0.62, Vector3(sx, 0.15, 0.08), Color("7a5a30"), Vector3(90, 0, 0))
			Props.ball(lash, 0.07, Vector3(0, 0.68, 0), Color("7a5a30"), Vector3(1.4, 1, 1.4), 6)   # düğüm
		var deck := Node3D.new()
		deck.name = "Deck"
		deck.visible = false
		s.add_child(deck)
		for k in 6:
			Props.box(deck, Vector3(4.2, 0.1, 0.46), Vector3(0, DECK_Y, -1.2 + k * 0.49), Color("9a7248").darkened((k % 3) * 0.06))
		var body := Props.solid(s, Vector3(4.2, 0.3, SEC_LEN), Vector3(0, DECK_Y - 0.15, 0), Color.WHITE)
		body.name = "Solid"
		body.get_child(0).visible = false
		body.process_mode = Node.PROCESS_MODE_DISABLED
		for sx: float in [-2.15, 2.15]:
			var rail := Props.solid(s, Vector3(0.1, 0.9, SEC_LEN), Vector3(sx, DECK_Y + 0.45, 0), Color("6a4a2c"))
			rail.name = "Rail"
			rail.visible = false
			rail.process_mode = Node.PROCESS_MODE_DISABLED
		sections.append(s)
	# Malzeme yığınları: bölüm başına taşınır (işçiler getirir)
	_pile_barrel = Node3D.new()
	add_child(_pile_barrel)
	for i in 3:
		Props.cyl(_pile_barrel, 0.4, 1.4, Vector3(0, 0.4 + (i / 2) * 0.78, -0.45 + (i % 2) * 0.9), Color("7a5634"), Vector3(0, 0, 90), 12)
	Props.interactable(_pile_barrel, "barrels", Vector3(1.6, 1.8, 2.2), Vector3(0, 0.8, 0))
	_pile_plank = Node3D.new()
	add_child(_pile_plank)
	for i in 6:
		Props.box(_pile_plank, Vector3(0.46, 0.1, 2.2), Vector3(0, 0.1 + i * 0.12, 0), Color("9a7248"))
	Props.interactable(_pile_plank, "planks", Vector3(1.0, 1.2, 2.4), Vector3(0, 0.5, 0))
	# Yığınlar ve top katıdır (içlerinden yürünüyordu); yığınlar köprü ucuna taşınırken birlikte gider
	for spec: Array in [[_pile_barrel, Vector3(1.4, 1.2, 1.8), Vector3(0, 0.6, 0)], [_pile_plank, Vector3(0.5, 0.8, 2.2), Vector3(0, 0.4, 0)]]:
		var pb := Props.solid(spec[0], spec[1], spec[2], Color.WHITE)
		pb.get_child(0).visible = false
		pb.set_meta("no_climb", true)
	_lash_point = Node3D.new()
	add_child(_lash_point)
	Props.interactable(_lash_point, "lash", Vector3(3.6, 1.6, 2.0), Vector3(0, 0.6, 0))
	_move_piles()
	usta = Person.new({"coat": Color("6a5a3a"), "pants": Color("3a3028"), "hat": "turban", "beard": true, "mustache": true,
		"hair": Color("5a5a5a"), "apron": Color("8a7050"), "skin": Color("d9a07a")})
	usta.set_meta("spk", "SPK_USTA")
	add_child(usta)
	usta.look_target = player
	_move_piles()          # usta yerine (iskele başının üstü); yoksa ilk bölüme kadar dünya merkezinde, tahtaya gömülü kalırdı
	for i in 3:
		var wk := Soldier.new([Color("8a6a4a"), Color("6a4a3a"), Color("7a5a3a")][i], "stand", "turban")
		wk.position = Vector3(-6.0 + i * 1.5, GROUND_Y, SHORE_Z - 3.0)
		add_child(wk)
	if GameState.flags.get("guards_like_tolga", false):
		hasan = Soldier.new(Color("b3262d"), "stand", "bork")
		hasan.set_meta("spk", "SPK_HASAN")
		add_child(hasan)
		huseyin = Soldier.new(Color("2f5fa8"), "stand", Soldier.huseyin_hat())
		huseyin.set_meta("spk", "SPK_HUSEYIN")
		add_child(huseyin)
		_move_piles()
	# Top (bitişte köprüye çekilir)
	cannon = Node3D.new()
	cannon.position = Vector3(6.0, GROUND_Y, SHORE_Z - 4.0)
	add_child(cannon)
	Props.box(cannon, Vector3(1.4, 0.4, 3.2), Vector3(0, 0.3, 0), Color("5a3e26"))
	var cb := Props.solid(cannon, Vector3(1.5, 1.25, 3.4), Vector3(0, 0.62, 0.1), Color.WHITE)
	cb.get_child(0).visible = false
	cb.set_meta("no_climb", true)
	Props.cyl(cannon, 0.35, 3.0, Vector3(0, 0.85, 0.2), Color("8c5e26"), Vector3(90, 0, 0), 12)
	Props.cyl(cannon, 0.42, 0.3, Vector3(0, 0.85, 1.65), Color("7a4e1e"), Vector3(90, 0, 0), 12)
	for sx: float in [-0.75, 0.75]:
		Props.cyl(cannon, 0.35, 0.12, Vector3(sx, 0.35, -0.9), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	_gauge = Control.new()
	_gauge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gauge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gauge.draw.connect(_draw_gauge)
	hud.add_child(_gauge)


## Yığınlar ve bağ noktası: köprünün ucuna taşınır.
func _move_piles() -> void:
	var head_z := SHORE_Z + 2.0 + SEC_LEN * built
	# İlk bölümden önce de yığınlar iskele başının üstündedir (DECK_Y): tahtaya gömülmesinler
	_pile_barrel.position = Vector3(-1.5, DECK_Y, head_z - 2.2)
	_pile_plank.position = Vector3(1.5, DECK_Y, head_z - 2.2)
	if built < SECTIONS:
		_lash_point.position = sections[built].position + Vector3(0, 0, 0)
	if usta:
		# Fıçı yığınının kıyı tarafında, yığından bir adım geride durur (yığının içine girmesin, köprü yolunu da
		# kesmesin); ilk bölümde kıyıdan iskeleye çıkan rampanın üstündedir
		var uz := head_z - 4.2
		usta.position = Vector3(-1.4, _deck_y(uz), uz)
	if hasan:
		# İkizler köprü başının öbür yanında, tahta yığınının kıyı tarafında (yolu kesmeden): fıçıyı onlar tutar
		var hz := head_z - 4.2
		hasan.position = Vector3(1.3, _deck_y(hz), hz)
		huseyin.position = Vector3(1.3, _deck_y(hz - 1.1), hz - 1.1)
		for tw: Soldier in [hasan, huseyin]:
			tw.face_toward(tw.global_position + Vector3(-0.4, 0, 1.0))


## Köprü başında (ya da kıyıdan iskeleye çıkan rampada) durulacak yükseklik.
func _deck_y(z: float) -> float:
	if z < SHORE_Z - 1.0:
		return lerpf(GROUND_Y, DECK_Y, clampf((z - (SHORE_Z - 2.8)) / 1.8, 0.0, 1.0))
	return DECK_Y


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH18_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH18_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	player.global_position = Vector3(0.8, GROUND_Y + 0.05, SHORE_Z - 3.5)
	player.face(Vector3(0, 1.0, 40.0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D18_N_01")
	await hud.say("SPK_USTA", "D18_U_01")
	await hud.say("SPK_TOLGA", "D18_T_01")
	await hud.say("SPK_USTA", "D18_U_02")
	if hasan:
		player.face(hasan.global_position + Vector3(0, 1.5, 0))
		await hud.say("SPK_HASAN", "D18_HA_01")
		await hud.say("SPK_HUSEYIN", "D18_HU_01")
		await hud.say("SPK_USTA", "D18_U_TWINS")
	Lore.scatter(self, "18")
	player.frozen = false
	phase = "build"
	step = "barrels"
	_update_objective()
	if GameState.autotest:
		_auto()
	while built < SECTIONS:
		await get_tree().process_frame
	await _finish_bridge()
	await _end_chapter()


func _update_objective() -> void:
	if phase != "build":
		hud.set_objective("")
		return
	var k := "UI_OBJ18_" + step.to_upper()
	var target: Vector3 = {"barrels": _pile_barrel.global_position, "lash": _lash_point.global_position,
		"planks": _pile_plank.global_position}[step]
	hud.set_objective(tr(k) % [built + 1, SECTIONS], target + Vector3(0, 1.4, 0))


func _do_barrels() -> void:
	var s := sections[built]
	var b: Node3D = s.get_node("Barrels")
	b.visible = true
	var end := b.position
	b.position = end + Vector3(0, 1.2, -2.0)
	var tw := create_tween()
	tw.tween_property(b, "position", end, 0.6).set_ease(Tween.EASE_IN)
	Audio.sfx("splash", -4.0)
	step = "lash"
	lashes = 0
	hud.bark("SPK_USTA", "D18_U_BARRELS", 2.5)
	_update_objective()


func _start_lash() -> void:
	if _g >= 0.0:
		return
	_g = 0.0
	_g_dir = 1.0
	_g_center = randf_range(0.35, 0.75)
	player.frozen = true
	hud.set_prompt(tr("UI_PROMPT18_TIE"))


func _tie() -> void:
	if _g < 0.0:
		return
	var ok := absf(_g - _g_center) <= _win()
	_g = -1.0
	_gauge.queue_redraw()
	hud.set_prompt("")
	Lore.scatter(self, "18")
	player.frozen = false
	lashes += 1
	if ok:
		Audio.sfx("land_pot", -8.0, 1.3)
	else:
		misses += 1
		Audio.sfx("cartoon_boing", -10.0)
		hud.bark("SPK_USTA", "D18_U_MISS_%d" % mini(misses, 3), 2.5)
		sections[built].rotation.z = deg_to_rad(randf_range(-4.0, 4.0))
	# Bu düğümün halatı görünür: gerilerek yerine oturur, fıçılardan su sıçrar (kaçan düğüm eğri kalır)
	var ropes := sections[built].get_node("Rope").get_children()
	if lashes - 1 < ropes.size():
		var lash: Node3D = ropes[lashes - 1]
		lash.visible = true
		lash.scale = Vector3(0.05, 1.0, 1.0)
		lash.rotation.y = 0.0 if ok else deg_to_rad(randf_range(-9.0, 9.0))
		var tw := create_tween()
		tw.tween_property(lash, "scale", Vector3(1.08, 1.0, 1.0), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(lash, "scale", Vector3.ONE, 0.12)
		Audio.sfx("whoosh_fly", -14.0, 0.7)
		for sx: float in [-1.3, 1.3]:
			Vfx.dust(self, sections[built].global_position + Vector3(sx, 0.4, lash.position.z), 0.45)
	if not ok and GameState.has_item("tape"):
		await _offer_tape(ropes[lashes - 1] if lashes - 1 < ropes.size() else null)
	if lashes >= 2:
		step = "planks"
	_update_objective()


## Bağın yeşil bandının yarı genişliği: ikizler fıçıyı tutuyorsa geniş.
func _win() -> float:
	return WIN_TWINS if hasan else WIN


## Kaçan bağ: koli bandıyla sarılırsa (bir şerit) halat yerine oturur, bölüm doğrulur, kaçan sayılmaz.
func _offer_tape(lash: Node3D) -> void:
	player.frozen = true
	var c := await hud.choose(["UI_C18_TAPE", "UI_C18_NOTAPE"], 0.0, 0 if GameState.autotest_variant == "tape" else 1)
	if c == 0 and GameState.spend("tape", "bridge_18"):
		misses -= 1
		taped += 1
		player.show_prop("tape", 1.8)
		sections[built].rotation.z = 0.0
		if lash:
			lash.rotation.y = 0.0
		Audio.sfx("land_pot", -8.0, 1.3)
		hud.bark("SPK_USTA", "D18_U_TAPE" if taped == 1 else "D18_U_TAPE_2", 3.0)
	player.frozen = _g >= 0.0


func _do_planks() -> void:
	var s := sections[built]
	var deck: Node3D = s.get_node("Deck")
	deck.visible = true
	# Kalaslar tek tek inip yerine oturur
	var k := 0
	for p in deck.get_children():
		if p is Node3D:
			var end: float = (p as Node3D).position.y
			(p as Node3D).position.y = end + 0.7
			var tw := create_tween()
			tw.tween_interval(k * 0.07)
			tw.tween_property(p, "position:y", end, 0.18).set_ease(Tween.EASE_IN)
			k += 1
	var solid: Node = s.get_node("Solid")
	solid.process_mode = Node.PROCESS_MODE_INHERIT
	for c in s.get_children():
		if c.name.begins_with("Rail"):
			c.visible = true
			c.process_mode = Node.PROCESS_MODE_INHERIT
	Audio.sfx("land_thud", -8.0, 1.1)
	built += 1
	if built in [2, 4]:
		hud.bark("SPK_USTA", "D18_U_SECTION_%d" % built, 3.0)
	elif built < SECTIONS:
		hud.bark("SPK_TOLGA", "D18_T_SECTION", 2.2)
	step = "barrels"
	_move_piles()
	_update_objective()


func _finish_bridge() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	await hud.say("SPK_USTA", "D18_U_DONE" if misses <= 2 else "D18_U_CROOKED")
	# Top köprüye çekilir
	var end := Vector3(0, DECK_Y, SHORE_Z + 2.0 + SEC_LEN * (SECTIONS - 1))
	cannon.position = Vector3(0, DECK_Y, SHORE_Z + 1.0)
	var tw := create_tween()
	tw.tween_property(cannon, "position", end, 4.0 if not GameState.autotest else 0.3)
	player.global_position = Vector3(2.8, 0.05, SHORE_Z - 2.0)
	player.face(end + Vector3(0, 1.0, 0))
	await hud.say("SPK_TOLGA", "D18_T_CANNON")
	if tw.is_running():   # replik uzun okunduysa hareket çoktan bitmiştir (bitmiş tweeni beklemek sonsuza dek takılır)
		await tw.finished
	Lore.scatter(self, "18")
	player.frozen = false
	var target := Node3D.new()
	cannon.add_child(target)
	target.position = Vector3(0, 1.0, 0)
	hud.set_objective(tr("UI_OBJ18_PHOTO"), cannon.global_position + Vector3(0, 1.2, 0))
	cam = TespitCam.new(player, hud, target, "siege18")
	hud.add_child(cam)
	cam.max_dist = 40.0
	cam.cone_deg = 12.0
	cam.taken.connect(func(path: String): _photo = path)
	cam.start()
	var t := 0.0
	while not cam.done and t < (3.0 if GameState.autotest else 40.0):
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.stop()
	player.frozen = true
	hud.set_objective("")
	Audio.sfx("cannon", -2.0)
	Vfx.explosion(self, cannon.global_position + Vector3(0, 1.0, 2.2), 0.8)
	player.shake(0.4)
	await hud.say("SPK_USTA", "D18_U_END")
	await hud.say("SPK_TOLGA", "D18_T_END")
	await hud.say("SPK_NIHAT", "D18_N_END")
	_outcome = "18.1" if misses <= 2 else "18.2"
	Siege.record(18, _photo, "SIEGE_NOTE_18_%s" % _outcome.split(".")[1])


func _process(delta: float) -> void:
	_t += delta
	# Suya düşen oyuncu kıyıya döner (boşluğa düşmesin)
	if player and player.global_position.y < -2.5:
		player.global_position = Vector3(0.8, 0.4, SHORE_Z - 3.5)
		player.velocity = Vector3.ZERO
	if _g >= 0.0:
		_g += _g_dir * delta * 1.1
		if _g >= 1.0:
			_g = 1.0
			_g_dir = -1.0
		elif _g <= 0.0 and _g_dir < 0.0:
			_g = 0.0
			_g_dir = 1.0
		_gauge.queue_redraw()
	for i in built:
		sections[i].position.y = sin(_t * 1.2 + i * 0.7) * 0.03


func _draw_gauge() -> void:
	if _g < 0.0:
		return
	var vs := _gauge.size
	var r := Rect2(Vector2(vs.x * 0.5 - 200, vs.y * 0.62), Vector2(400, 18))
	_gauge.draw_rect(r.grow(3), Color(0, 0, 0, 0.5))
	_gauge.draw_rect(r, Color("2a2622"))
	_gauge.draw_rect(Rect2(r.position + Vector2(r.size.x * (_g_center - _win()), 0), Vector2(r.size.x * _win() * 2.0, r.size.y)), Color("5fcf6a"))
	var x := r.position.x + r.size.x * _g
	_gauge.draw_rect(Rect2(Vector2(x - 3, r.position.y - 6), Vector2(6, r.size.y + 12)), Color("fff3d6"))
	_gauge.draw_string(ThemeDB.fallback_font, r.position + Vector2(0, -12), tr("UI_CH18_ROPE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f2e6c9"))


func _unhandled_input(event: InputEvent) -> void:
	if _g >= 0.0 and event.is_action_pressed("interact"):
		_tie()
		get_viewport().set_input_as_handled()


func _on_focus(id: String) -> void:
	if phase != "build":
		hud.set_prompt("")
		return
	match id:
		"barrels":
			hud.set_prompt(tr("UI_PROMPT18_BARRELS") if step == "barrels" else "")
		"lash":
			hud.set_prompt(tr("UI_PROMPT18_LASH") if step == "lash" and _g < 0.0 else "")
		"planks":
			hud.set_prompt(tr("UI_PROMPT18_PLANKS") if step == "planks" else "")
		_:
			if _g < 0.0:
				hud.set_prompt("")


func _on_interact(id: String) -> void:
	if phase != "build":
		return
	match id:
		"barrels":
			if step == "barrels":
				_do_barrels()
		"lash":
			if step == "lash":
				_start_lash()
		"planks":
			if step == "planks":
				_do_planks()


func _auto() -> void:
	var v := GameState.autotest_variant
	for i in SECTIONS:
		await get_tree().create_timer(0.1).timeout
		_on_interact("barrels")
		for k in 2:
			_on_interact("lash")
			_g_center = 0.5
			_g = 0.5
			if v == "crooked" or (v == "tape" and i < 2):
				_g = 0.95
			elif v in ["twins", "near"]:
				_g = 0.5 + 0.2          # ikizsiz bandın (0,16) dışında, ikizlinin (0,23) içinde
			await _tie()
		_on_interact("planks")


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(18, _outcome)
	await Siege.show_page(hud, 18)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(18)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW18_TITLE")
	c.nodes = [
		{"id": "build", "key": "FLOW18_BUILD", "pos": Vector2(0.5, 0.14)},
		{"id": "18.1", "key": "FLOW_18_1", "pos": Vector2(0.3, 0.36), "outcome": true},
		{"id": "18.2", "key": "FLOW_18_2", "pos": Vector2(0.7, 0.36), "outcome": true},
		{"id": "cannon", "key": "FLOW18_CANNON", "pos": Vector2(0.5, 0.56)},
	]
	c.edges = [["build", "18.1"], ["build", "18.2"], ["18.1", "cannon"], ["18.2", "cannon"]]
	for k in ["build", "cannon", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH18_STATS") % [misses, Siege.page_count(), Siege.page_total()],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "18.1", "crooked": "18.2", "twins": "18.1", "near": "18.2", "tape": "18.1"}.get(v, "18.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("18", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and built == SECTIONS
	ok = ok and (hasan != null) == (v == "twins") and (taped == 3) == (v == "tape")
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=18 variant=%s outcome=%s built=%d misses=%d taped=%d twins=%s" % ["PASS" if ok else "FAIL", v, _outcome, built,
		misses, taped, hasan != null])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	phase = "build"
	for i in 3:
		step = "barrels"
		_do_barrels()
		lashes = 2
		sections[built].get_node("Rope").visible = true
		_do_planks()
	_do_barrels()
	player.global_position = Vector3(0.6, DECK_Y + 0.05, SHORE_Z + 2.0 + SEC_LEN * 2.6)
	await get_tree().create_timer(0.8).timeout
	player.face(_lash_point.global_position + Vector3(0, 0.3, 0))
	_g = 0.3
	_g_center = 0.55
	await _shot("c18_01_lash.png")
	_g = -1.0
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = Vector3(9.0, 4.0, SHORE_Z - 6.0)
	cv.look_at(Vector3(0, 0.5, SHORE_Z + 10.0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await _shot("c18_cover.png")
	get_tree().quit()
