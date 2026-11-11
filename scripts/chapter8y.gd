extends Node3D
## Ara Bölüm — Beyaz Havlu (Tolga · 25 Nisan 1453, şafak). Bölüm 8 ile 9 arasında, yalnız Bizans yolunda (Bölüm 6
## sonucu 6b.*): surların içinden çıkış ve iki ordunun arasındaki yürüyüş. Ekranda numarasız "ARA BÖLÜM".
## Tasarım: kara surlarının dünya x 37'deki kapısı (World1453.LAND_GATES), tek haritada; bölgenin yerel x 0'ı kapının
## ortası, +z ova ve ordugâh, −z şehir. Koridor keep dikdörtgenleriyle boş ve düz tutulur; siperdeki geçidi
## SiegeField._gap koridorun genişliğinde kendisi açar.
##   1 Şehir içi, iç sur kapısının önü: Niko havluyu sırığa bağlı uzatır (6b.1/6b.2: mühürlü mektup cepte; açıldıysa
##     Niko mührün yamukluğunu görür). 6b.3: Niko Tolga'yı zindandan getirmiştir, mektup yok ("en azından şunu salla").
##   2 Peribolos boyunca dış sur kapısı: nöbetçi havluya kapı açmaz, Niko "imparatorluk havlusu" der; sürgü kalkar,
##     kanatlar açılır. Niko kuralları söyler (dümdüz yürü, indirme, koşma).
##   3 Hendek köprüsü: surdaki gözcü laf atar.
##   4 Ölü bölge: havlu yukarıda yürü. Havlu inikken (E), koşarken ya da koridorun kenarına sapınca ayağının dibine
##     uyarı oku saplanır (önce surdan, sonra siperden), o taraf bağırır. Kimse vurulmaz, ceza yok, süre yok.
##     Hikmet'in telsizi bir kez (bağ varsa, 8.4 değilse; telsiz göstergesi değişmez).
##   5 Osmanlı siperi: Hasan ile Hüseyin. Mühür / çantadan bir şey (REACT_GUARDS_*) / doğruyu söyle; hepsi geçirir.
##   6 Hatların içi (batarya, kazıcılar, kazan, çadırlar): Hasan pazarın girişine götürür. Sonra Bölüm 9.
##   8Y.1 havlu hiç inmedi · 8Y.2 uyarı okları · 8Y.3 sınır dışı edilerek çıktı (6b.3)
## Kayıtta sahte bölüm numarası NO (GameState.play_order: 8.5). Bayraklar: ch8y_done, ch8y_warnings, ch8y_id.
##   --autotest[=warn|dep|opened|honest|hikmet|next]   (varsayılan: 8Y.1, mühür)

const Towel := preload("res://scripts/chapter8y_towel.gd")
const NO := 80
const REGION := "gate8y"
const GATE_X := 37.0
## Oynanış alanı (bölge yereli): şehir içi, peribolos, dış sur kapısının üstü (oradaki sur figürleri yerine bölümün
## kendi gözcüleri), ölü bölge, siperdeki geçit, hatların içi. İç sur hattını (z −2,3) kesmez: kapıyı dünya kurar.
const KEEP := [Rect2(-12.0, -45.0, 24.0, 40.2), Rect2(-8.0, 0.0, 16.0, 12.5), Rect2(-12.0, 13.4, 24.0, 3.2),
	Rect2(-14.0, 36.0, 28.0, 64.0), Rect2(-5.0, 100.0, 10.0, 26.0), Rect2(-14.0, 126.0, 28.0, 26.0)]
const START := Vector3(0.0, 0.0, -10.0)
const NIKO_AT := Vector3(1.3, 0.0, -8.6)
const NIKO_GATE := Vector3(2.2, 0.0, 9.8)
const GUARD_AT := Vector3(-2.6, 0.0, 9.6)
const BAR_AT := Vector3(0.0, 1.55, 13.62)
## Sürgü kaldırılınca sol kulenin peribolosa bakan yüzüne dikine yaslanır (alt ucu yerde, üstü taşa değer)
const BAR_DOWN := Vector3(-4.6, 2.72, 12.45)
const HINGE_X := 3.45
const GATE_Z := 13.85
const GATE_TRIGGER_Z := 8.4
const BRIDGE_Z := 21.0
const FIELD_Z := 37.0
const TRENCH_Z := 103.5
const HASAN_AT := Vector3(-1.3, 0.0, 109.0)
const HUSEYIN_AT := Vector3(1.3, 0.0, 109.0)
const MARKET_AT := Vector3(-2.6, 0.0, 141.0)
## Ordugâh bölgesinin (CampDay) yerel z 0'ı bu bölümde: BYZ_SPAWN (yerel z 22) = END_AT
const CAMP_Z0 := 162.0
const END_AT := Vector3(0.0, 0.0, 140.0)
const END_Z := 137.5
const BATTERY := Vector3(10.5, 0.0, 99.0)
const LADDER_AT := Vector3(-5.2, 0.0, 61.0)
const LANE_HALF := 13.8
## Ölü bölgedeki terk edilmiş siper sıraları: [z, x başı, x sonu]; açıklıklar sırayla solda, sağda, solda
const BARRIERS := [[54.0, -6.0, 15.0], [72.0, -15.0, 6.0], [90.0, -6.0, 15.0]]
## Zikzak yol (bot ve ayak izi): açıklıklardan geçer
const PATH := [Vector3(-11.5, 0, 54.0), Vector3(11.5, 0, 72.0), Vector3(-11.5, 0, 90.0), Vector3(0.0, 0, 103.0)]
## Siperden "Dur!": ikinci sıradan sonra Tolga durup havluyu sallar (nöbetçiler görene kadar)
const HALT_Z := 76.0
const WARN_GAP := 5.0
const DOWN_GRACE := 1.2
## Sırık kameranın yerelinde: yukarıda (havlu sağ üstte dalgalanır) ve aşağıda (öne yatık, havlu sarkık)
const POLE_UP_POS := Vector3(0.06, -0.3, -0.52)
const POLE_UP_ROT := Vector3(-38, 4, -11)
const POLE_DOWN_POS := Vector3(0.14, -0.38, -0.44)
const POLE_DOWN_ROT := Vector3(-76, 10, -30)
const POLE_REST_POS := Vector3(0.3, -0.36, -0.42)
const POLE_REST_ROT := Vector3(-15, 0, -52)
const SPEAKERS := ["SPK_NIKO", "SPK_CITY_GUARD", "SPK_LOOKOUT", "SPK_HASAN", "SPK_HUSEYIN"]
## Uyarı sözleri: [konuşan, anahtar] (surdan ya da siperden; koşunca ayrı söz). Tolga'nın cevabı sırayla.
const WARN_WALL := [["SPK_LOOKOUT", "D8Y_WALL_WARN_1"], ["SPK_LOOKOUT", "D8Y_WALL_WARN_2"]]
const WARN_TRENCH := [["SPK_HASAN", "D8Y_HASAN_WARN_1"], ["SPK_HUSEYIN", "D8Y_HUSEYIN_WARN_2"]]
const WARN_TOLGA := [["SPK_TOLGA", "D8Y_T_WARN_1"], ["SPK_TOLGA", "D8Y_T_WARN_2"], ["SPK_TOLGA", "D8Y_T_WARN_3"]]
const RADIO := [["SPK_HIKMET", "D8Y_H_RADIO_1"], ["SPK_TOLGA", "D8Y_T_RADIO_1"], ["SPK_HIKMET", "D8Y_H_RADIO_2"]]
## Çantadan gösterilecek eşya: bu sırayla ilk bulunan (Hasan ile Hüseyin'in tepkisi REACT_GUARDS_<EŞYA>; eşya verilmez)
const SHOW_ORDER := ["chickpeas", "cologne", "thermos", "phone", "cube", "book", "powerbank", "lighter", "tape", "selfie"]

var world: SiegeField
var player: Player
var hud: Hud
var phase := "intro"          # intro, peri, gate, out, field, trench, lines, done
var _outcome := ""
var _busy := false
var _deported := false
var _letter := false
var _id := ""
var _warnings := 0
var _lowered := 0
var _towel_up := true
var _auto_down := false
var _auto_t := 0.0
var _run_t := 0.0
var _down_t := 0.0
var _warn_cd := 0.0
var _bot_running := false
var _radio_done := false
var _prompt := ""
var _fired := {}
var _pole: Node3D
var _pole_tw: Tween
var _sun: DirectionalLight3D
var niko: Person
var guard: Soldier
var lookout: Soldier
var hasan: Soldier
var huseyin: Soldier
var goat: Goat
var _leaf_l: Node3D
var _leaf_r: Node3D
var _bar: Node3D
var _seat: Node3D
var _archers: Array[Soldier] = []
## Sinerji (4b'den beri Tolga'nın peşindeki tavuk; bayrak "sinerji"): kapıdan pazara kadar yanında yürür
var sinerji: Chicken
## Sinerji'nin izlediği nokta: Chicken.follow hedefin arkasına geçer; birinci şahısta arkadaki tavuk hiç görünmüyordu.
## Yürürken oyuncunun sağ önünde (bakışın sağ altında görünür), sahnelerde yanında durur.
var _lead: Node3D


func _ready() -> void:
	GameState.snapshot(NO)
	_apply_autotest_setup()
	var ch6: String = str(GameState.chapter_outcomes.get(6, ""))
	if not ch6.begins_with("6b"):
		# Doğrudan açılış (--chapter=8y, Yaratıcı Menüsü): ara bölüm yalnız Bizans yolunda oynanır. Yalnız bu bölümün
		# kendi değişkeninde 6b.1 sayılır; GameState'e (kayda, sonraki bölümün başlangıcına) yazılmaz
		ch6 = "6b.1"
	_deported = ch6 == "6b.3"
	_letter = not _deported
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(GameState.telsiz_bag)
	hud.bag_locked = true
	hud.update_bag(GameState.bag)
	player.show_remote(true)
	_build_sky()
	# Bölge: dünyanın kara surlarındaki kapı (yerel x 0 = dünya x GATE_X); dünya tek haritadan kurulur
	World1453.REGIONS[REGION] = Transform3D(Basis.IDENTITY, Vector3(GATE_X, 0.0, 0.0))
	world = World1453.build(self, REGION, KEEP, false)
	_build_ground()
	_build_bounds()
	_build_gate()
	_build_people()
	_build_field()
	_build_lines()
	if GameState.autotest:
		Engine.time_scale = 2.5
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _apply_autotest_setup() -> void:
	if not GameState.autotest:
		return
	match GameState.autotest_variant:
		"warn":
			GameState.chapter_outcomes[6] = "6b.2"
		"dep":
			GameState.chapter_outcomes[6] = "6b.3"
		"opened":
			GameState.chapter_outcomes[6] = "6b.1"
			GameState.flags["letter_opened"] = true
		"hikmet":
			GameState.chapter_outcomes[6] = "6b.1"
			GameState.chapter_outcomes[8] = "8.4"
		"sinerji":
			GameState.chapter_outcomes[6] = "6b.1"
			GameState.flags["sinerji"] = true
		_:
			GameState.chapter_outcomes[6] = "6b.1"


func _d(sec: float) -> float:
	return 0.05 if Stage.fast() else sec


func _wait(sec: float) -> void:
	await get_tree().create_timer(_d(sec), false).timeout


## Görünen zeminin yüksekliği (bölge yereli): hendek geçidi 0, ova dünyanın görünen yüzeyi, gerisi döşeme (−0,03).
## Hiçbir yerde döşemenin (görünmez katı zemin) altına inmez: kişiler ona gömülmesin.
func _gy(x: float, z: float) -> float:
	if z > 19.6 and z < 36.4 and absf(x) < 3.5:
		return 0.0
	if z >= 36.0:
		return maxf(SiegeField.surf(x + GATE_X, z), -0.03)
	return -0.03


# ================================================================ sahne

func _build_sky() -> void:
	Audio.voice_space("outdoor")
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	# Şafak: tepede serin mavi, ufukta (şehrin üstünde, doğuda) sıcak turuncu
	sm.sky_top_color = Color("4a6f9e")
	sm.sky_horizon_color = Color("e8c4a0")
	sm.ground_horizon_color = Color("cdb894")
	sm.ground_bottom_color = Color("6a5a44")
	sm.sky_energy_multiplier = 0.9
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.5
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = Color("e2cdb4")
	e.fog_density = 0.0035
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.3
	e.tonemap_exposure = 0.9
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.08
	e.adjustment_contrast = 1.05
	env.environment = e
	add_child(env)
	# Güneş şehrin (−z, doğu) üstünden alçaktan vurur: gölgeler ovaya, Tolga'nın önüne uzanır
	_sun = DirectionalLight3D.new()
	_sun.rotation_degrees = Vector3(-14, 168, 0)
	_sun.light_color = Color("ffcf98")
	_sun.light_energy = 1.15
	_sun.shadow_enabled = true
	_sun.directional_shadow_max_distance = 70.0
	add_child(_sun)
	SkyBody.attach(self, _sun)


## Görünmez katı döşeme: dünyanın zemini karelere yayılarak katılaşır (WorldWalk), oyuncu ve kişiler o bitmeden de
## yürüyen alanda bassın. Üstü görünen zeminle aynı (−0,03; hendek geçidi 0).
func _floor(size: Vector3, top: Vector3) -> void:
	var b := Props.solid(self, size, top - Vector3(0, size.y * 0.5, 0), Color.WHITE)
	b.get_child(0).visible = false


## Koridorun görünmez kenarları (şehre, peribolos boyunca, hendeğe ve ovanın yanlarına gidilmez)
func _block(size: Vector3, center: Vector3) -> void:
	var b := Props.solid(self, size, center, Color.WHITE)
	b.get_child(0).visible = false
	b.set_meta("no_climb", true)


func _build_ground() -> void:
	_floor(Vector3(24, 0.6, 40.0), Vector3(0, -0.03, -24.8))      # şehir içi
	_floor(Vector3(8, 0.6, 5.0), Vector3(0, -0.03, -2.4))         # iç sur kapısının altı
	_floor(Vector3(14, 0.6, 15.0), Vector3(0, -0.03, 6.6))        # peribolos
	_floor(Vector3(8, 0.6, 6.0), Vector3(0, -0.03, 17.0))         # dış sur kapısı ve sur önündeki set
	_floor(Vector3(7, 0.6, 16.6), Vector3(0, 0.0, 28.2))          # hendeğin üstündeki dolgu geçit
	_floor(Vector3(30, 0.6, 118.0), Vector3(0, -0.03, 94.0))      # ölü bölge ve hatlar
	var gy := Callable(self, "_gy")
	# Zemin ayrıntısı (çarpışmasız, tür başına tek çoklu ağ): çiğnenmiş toprak düz levha gibi durmasın
	Nature.ground_detail(self, Rect2(-10.0, -40.0, 20.0, 34.0), "straw", 0.03, 8101, gy)
	Nature.ground_detail(self, Rect2(-10.0, -40.0, 20.0, 34.0), "pebble", 0.06, 8102, gy)
	Nature.ground_detail(self, Rect2(-6.0, 0.5, 12.0, 12.5), "rubble", 0.05, 8103, gy)
	Nature.ground_detail(self, Rect2(-6.0, 0.5, 12.0, 12.5), "stone", 0.08, 8104, gy)
	# Ölü bölge: oklar elle (tüylü, üç çeşit, kümeler: _build_arrows); zemin moloz, taş, çamur, yanık yama, ayak ve
	# toynak izi, seyrek ot (tek ton yeşil levha kalmasın)
	Nature.ground_detail(self, Rect2(-14.0, 37.0, 28.0, 64.0), "rubble", 0.05, 8106, gy)
	Nature.ground_detail(self, Rect2(-14.0, 37.0, 28.0, 64.0), "stone", 0.09, 8107, gy)
	Nature.ground_detail(self, Rect2(-14.0, 37.0, 28.0, 64.0), "mud", 0.03, 8108, gy)
	Nature.ground_detail(self, Rect2(-14.0, 37.0, 28.0, 64.0), "ash", 0.012, 8113, gy)
	Nature.ground_detail(self, Rect2(-14.0, 37.0, 28.0, 64.0), "footprint", 0.04, 8114, gy)
	Nature.ground_detail(self, Rect2(-14.0, 37.0, 28.0, 64.0), "hoofprint", 0.015, 8115, gy)
	Nature.ground_detail(self, Rect2(-14.0, 37.0, 28.0, 64.0), "tall_grass", 0.02, 8116, gy)
	Nature.ground_detail(self, Rect2(-14.0, 96.0, 28.0, 54.0), "hoofprint", 0.03, 8109, gy)
	Nature.ground_detail(self, Rect2(-14.0, 112.0, 28.0, 38.0), "camp_mud", 0.02, 8110, gy)
	Nature.ground_detail(self, Rect2(-14.0, 125.0, 28.0, 25.0), "straw", 0.04, 8111, gy)
	# Kapıdan ovaya ve hatlara giden ayak izi (nöbet değişimleri, sabah çıkan devriyeler)
	Nature.trail(self, [Vector3(0.6, 0, -9.0), Vector3(0.4, 0, 13.0), Vector3(0.2, 0, 36.0)] + PATH + [Vector3(0.3, 0, 108.0),
		Vector3(0.0, 0, 146.0)], "footprint", gy, 1.4, 8112)
	_build_causeway()


## Hendek geçidi: dünyanın dolgu geçidinin üstü taş döşeme (enine sıralar), ortasında iki tekerlek izi, iki yanda alçak taş
## korkuluk (katı; hendeğe düşülmez), yan yüzleri örme taş, kenarlarda moloz ve ot; hendeğin dibi çamurlu su ve saz.
func _build_causeway() -> void:
	var gy := Callable(self, "_gy")
	var pave := Props.box(self, Vector3(6.4, 0.04, 16.4), Vector3(0, 0.0, 28.2), Color.WHITE)
	Props.set_pattern(pave, Color("a08e6e"), "cobble")
	for k in 9:
		Props.box(self, Vector3(6.3, 0.045, 0.12), Vector3(0, 0.0, 20.6 + k * 1.9), Color("7e6e54"))
	for rx: float in [-0.8, 0.8]:
		Nature.trail(self, [Vector3(rx, 0, 16.5), Vector3(rx, 0, 37.0)], "wheel_ruts", gy, 1.0, 8130 + int(rx * 10.0), 0.1)
	for sx: float in [-1.0, 1.0]:
		# Alçak korkuluk (diz boyu): üstünden hendeğin dibi görünür, üstünden atlanmaz (katı + görünmez korkuluk)
		var par := Props.solid(self, Vector3(0.38, 0.34, 16.4), Vector3(sx * 3.28, 0.17, 28.2), Color.WHITE)
		Props.set_pattern(par, Color("b8a888"), "ashlar")
		Props.box(self, Vector3(0.46, 0.08, 16.4), Vector3(sx * 3.28, 0.38, 28.2), Color("9a8a70"))
		var face := Props.box(self, Vector3(0.06, 2.9, 16.0), Vector3(sx * 3.53, -1.45, 28.0), Color.WHITE)
		Props.set_pattern(face, Color("8a7a60"), "ashlar")
		Nature.ground_detail(self, Rect2(sx * 2.7 - 0.4, 20.2, 0.8, 15.6), "rubble", 0.6, 8131 + int(sx), gy)
		Nature.ground_detail(self, Rect2(sx * 2.7 - 0.4, 20.2, 0.8, 15.6), "grass", 1.2, 8133 + int(sx), gy)
		# Hendeğin dibi: çamurlu, yer yer su birikintili; sazlık ve taş
		var mud := Props.box(self, Vector3(14.0, 0.04, 15.2), Vector3(sx * 10.6, -2.86, 28.0), Color("4a4630"))
		mud.material_override = Props.mat(Color("4a4630"), 0.0, false, "", false)
		var pool := Props.box(self, Vector3(9.0, 0.02, 6.5), Vector3(sx * 9.0, -2.83, 28.6 + sx * 2.0), Color("3e4a44"))
		pool.material_override = Props.mat(Color(0.24, 0.3, 0.27, 0.82), 0.0, true, "", false)
		var low := func(_x: float, _z: float) -> float: return -2.84
		Nature.ground_detail(self, Rect2(sx * 10.6 - 7.0, 20.6, 14.0, 14.8), "tall_grass", 0.25, 8135 + int(sx), low)
		Nature.ground_detail(self, Rect2(sx * 10.6 - 7.0, 20.6, 14.0, 14.8), "stone", 0.12, 8137 + int(sx), low)


func _build_bounds() -> void:
	_block(Vector3(26, 4, 0.5), Vector3(0, 2, -22.0))
	for sx: float in [-1.0, 1.0]:
		_block(Vector3(0.5, 4, 18.0), Vector3(sx * 9.0, 2, -13.4))
		_block(Vector3(0.5, 4, 15.0), Vector3(sx * 6.5, 2, 6.6))
		# Sur önündeki set ve hendek geçidinin iki yanı (3 m'lik hendeğe düşülmez, sur boyunca gidilmez)
		_block(Vector3(0.5, 3, 20.6), Vector3(sx * 3.6, 1.5, 26.2))
		_block(Vector3(11.4, 3, 0.5), Vector3(sx * 9.3, 1.5, 36.1))
		_block(Vector3(0.5, 4, 116.0), Vector3(sx * 15.0, 2, 94.0))
	_block(Vector3(31, 4, 0.5), Vector3(0, 2, 152.0))


## Dış surun kapısı: iki ahşap kanat (kalas, demir kuşak, menteşe), önlerinde sürgü. Kanatlar katıdır; açılınca
## peribolosa doğru döner, sürgü kenara yere konur.
func _build_gate() -> void:
	for side: float in [-1.0, 1.0]:
		var h := Node3D.new()
		h.position = Vector3(side * HINGE_X, 0.0, GATE_Z)
		add_child(h)
		var lw := HINGE_X - 0.03
		Props.solid(h, Vector3(lw, 5.9, 0.16), Vector3(-side * lw * 0.5, 2.95, 0.0), Color("5a3e26"))
		for k in 5:
			Props.box(h, Vector3(0.025, 5.8, 0.02), Vector3(-side * (0.3 + k * 0.64), 2.95, -0.09), Color("3e2a1a"))
		for y: float in [0.9, 2.9, 4.9]:
			Props.box(h, Vector3(lw - 0.1, 0.12, 0.03), Vector3(-side * lw * 0.5, y, -0.095), Color("3a3634"))
			Props.ball(h, 0.07, Vector3(-side * 0.12, y, -0.1), Color("2a2624"), Vector3(1, 1.4, 0.6), 6)
		# Sürgünün yuvası (kanatla birlikte döner)
		Props.box(h, Vector3(0.12, 0.34, 0.12), Vector3(-side * (HINGE_X - 2.2), 1.55, -0.14), Color("2a2624"))
		if side < 0.0:
			_leaf_l = h
		else:
			_leaf_r = h
	_bar = Node3D.new()
	_bar.position = BAR_AT
	add_child(_bar)
	Props.box(_bar, Vector3(5.6, 0.2, 0.16), Vector3.ZERO, Color("6a4a2c"))
	for x: float in [-2.5, 2.5]:
		Props.box(_bar, Vector3(0.06, 0.22, 0.17), Vector3(x, 0, 0), Color("3a3634"))


func _build_people() -> void:
	niko = Person.new({"face": "niko", "coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hair": Color("2a1e14"), "hat": "helm",
		"mustache": true, "beard": true, "skin": Color("d9a07a")})
	niko.set_meta("spk", "SPK_NIKO")
	niko.position = NIKO_AT + Vector3(0, _gy(NIKO_AT.x, NIKO_AT.z), 0)
	add_child(niko)
	niko.look_target = player
	_niko_pole_on()
	Stage.face(niko, START)
	# İç sur kapısının nöbetçileri (sözsüz): mızrak, kalkan; kapının iki yanında şehre bakar
	for sx: float in [-1.0, 1.0]:
		var g := Soldier.new(Color("6a2a2a") if sx < 0.0 else Color("3a4a6a"), "stand", "helm")
		g.position = Vector3(sx * 2.75, -0.03, -5.4)
		g.rotation.y = PI
		add_child(g)
		g.equip("spear")
		g.equip("shield", Color("7a2a24"))
	guard = Soldier.new(Color("5a3a2a"), "stand", "helm")
	guard.set_meta("spk", "SPK_CITY_GUARD")
	guard.position = GUARD_AT + Vector3(0, -0.03, 0)
	add_child(guard)
	guard.equip("spear")
	Stage.face(guard, Vector3(0, 0, 8.0))
	# Dış surun üstünde okçular ve gözcü (ovaya bakar). Sur yolunun çarpışması karelere yayılarak kurulur: ayaklarının
	# altında küçük görünmez döşeme (Unclip onları sur dibine indirmesin)
	for i in 4:
		# Kapının kemerinin üstünde, mazgal aralıklarında (dünyanın dış sur mazgalları 1,8 m arayla): gözcü ve iki okçu
		# köprüden çıkana tam tepeden bakar (bakışın içinde, kule ardında kalmaz); mızraklı biri yandaki sur yolunda
		var x: float = [-1.4, 0.4, 2.2, -8.6][i]
		var s := Soldier.new([Color("6a2a2a"), Color("3a4a6a"), Color("5a3a2a"), Color("6a2a2a")][i], "stand", "helm")
		# Mazgalın ardında taş atış basamağında (0,8 m): köprüden bakınca belden yukarısı mazgalın üstünde görünür
		s.position = Vector3(x, 8.8, 15.05)
		s.set_meta("climber", true)        # mazgalda: Unclip yere indirmesin (sur yolunun çarpışması sonradan kurulur)
		s.set_meta("no_unclip", true)
		add_child(s)
		s.equip("spear" if i == 3 else "bow")
		if i == 1 or i == 2:
			# Okçular yayı kaldırmış, ovaya nişanlı (kapı açılınca çıkan Tolga'ya döner); gözcünün sözüyle indirir
			s.pose = "aim"
			_archers.append(s)
		var step := Props.solid(self, Vector3(1.0, 0.8, 0.6), Vector3(x, 8.4, 15.05), Color.WHITE)
		Props.set_pattern(step, Color("b8a888"), "ashlar")
		if i == 0:
			lookout = s
			s.set_meta("spk", "SPK_LOOKOUT")
			s.set_meta("afar", true)
	# Osmanlı ileri siperinin geçidinde Hasan ile Hüseyin (sura, gelen Tolga'ya bakar)
	hasan = Soldier.new(Color("b3262d"), "stand", "bork")
	hasan.set_meta("spk", "SPK_HASAN")
	hasan.position = HASAN_AT + Vector3(0, _gy(HASAN_AT.x, HASAN_AT.z), 0)
	hasan.rotation.y = PI
	add_child(hasan)
	hasan.equip("spear")
	huseyin = Soldier.new(Color("2f5fa8"), "stand", Soldier.huseyin_hat())
	huseyin.set_meta("spk", "SPK_HUSEYIN")
	huseyin.position = HUSEYIN_AT + Vector3(0, _gy(HUSEYIN_AT.x, HUSEYIN_AT.z), 0)
	huseyin.rotation.y = PI
	add_child(huseyin)
	huseyin.equip("spear")
	huseyin.equip("shield", Color("8a2b22"))
	# Sınır dışı: Tolga kapının önünde bir taşın üstünde oturuyor (Niko onu zindandan buraya getirdi)
	if _deported:
		_seat = Node3D.new()
		add_child(_seat)
		Props.box(_seat, Vector3(0.9, 0.42, 0.6), Vector3(START.x, 0.18, START.z - 0.1), Color("b8a888"), Vector3(0, 8, 0))


## Ölü bölge: gülle çukurları, saplı oklar, gülleler, devrilmiş merdiven, sahipsiz miğfer ve perde, başıboş keçi.
## Hepsi çarpışmasız (koridorda yürünür); dünyanın kendi çukurları koridorun (keep) dışında kalır.
func _build_field() -> void:
	var craters: Array = []
	var cols: Array = []
	var rims: Array = []
	for c: Vector3 in [Vector3(-4.5, 2.0, 96.5), Vector3(-8.0, 2.8, 48.0), Vector3(9.0, 1.8, 58.0), Vector3(-6.0, 2.4, 80.0),
			Vector3(7.0, 1.4, 44.0), Vector3(-10.0, 1.6, 94.0), Vector3(11.0, 2.0, 74.0)]:
		var y := _gy(c.x, c.z) + 0.005
		craters.append(Scenery._t(Vector3(c.x, y, c.z), Vector3(0, c.z * 0.37, 0), Vector3(c.y, 1.0, c.y * 0.9)))
		cols.append(Color("262219").lerp(Color("3a3326"), fmod(c.z * 0.13, 1.0)))
		rims.append(Scenery._t(Vector3(c.x, y - 0.1, c.z), Vector3(0, c.z * 0.37, 0), Vector3(c.y * 1.15, 1.0, c.y * 1.04)))
	Scenery.scatter(self, Scenery._cyl(1.0, 0.05, 0.85, 10), craters, cols)
	Scenery.scatter(self, Scenery._cyl(1.0, 0.16, 0.8, 10), rims, [], Props.mat(Color("4a4230")))
	# Gülleler (yarı gömülü) ve saplı oklar (uç toprakta, sura doğru eğik)
	for b: Vector3 in [Vector3(-3.2, 0.3, 97.6), Vector3(-7.1, 0.26, 49.5), Vector3(5.5, 0.22, 52.0), Vector3(-3.0, 0.3, 83.0),
			Vector3(12.0, 0.28, 66.0)]:
		Props.ball(self, b.y, Vector3(b.x, _gy(b.x, b.z) + b.y * 0.55, b.z), Color("5e5a52"), Vector3.ONE, 8)
	_build_arrows()
	_build_barriers()
	# Kırık kalkanlar ve miğferler (yerde yatık; kimse ölmedi, kaçarken düşürülmüş)
	for sh: Vector3 in [Vector3(-11.0, 0.0, 46.0), Vector3(6.5, 0.0, 63.0), Vector3(-7.5, 0.0, 84.0)]:
		var sn := Node3D.new()
		sn.position = Vector3(sh.x, _gy(sh.x, sh.z) + 0.05, sh.z)
		sn.rotation = Vector3(deg_to_rad(-84.0), sh.z * 0.6, 0)
		add_child(sn)
		Blades.shield(sn, Color("7a2a24") if sh.x < 0.0 else Color("2f4a6a")).scale = Vector3.ONE * 0.85
	for hm: Vector3 in [Vector3(-12.0, 0.0, 66.0), Vector3(9.5, 0.0, 86.5)]:
		Props.cyl(self, 0.13, 0.16, Vector3(hm.x, _gy(hm.x, hm.z) + 0.12, hm.z), Color("7a7f88"), Vector3(75, hm.z * 3.0, 0), 10, 0.09)
	# Devrilmiş merdiven: iki direk, basamaklar; bir ucu taşın üstünde
	var ld := Node3D.new()
	ld.position = LADDER_AT + Vector3(0, _gy(LADDER_AT.x, LADDER_AT.z), 0)
	ld.rotation = Vector3(deg_to_rad(-1.6), deg_to_rad(35.0), 0)
	add_child(ld)
	for sx: float in [-0.38, 0.38]:
		Props.cyl(ld, 0.045, 4.8, Vector3(sx, 0.06, 0), Color("6a4a2c"), Vector3(90, 0, 0), 6)
	for k in 12:
		Props.box(ld, Vector3(0.76, 0.04, 0.05), Vector3(0, 0.07, -2.2 + k * 0.4), Color("5a3e26"))
	Props.box(ld, Vector3(0.08, 0.05, 0.4), Vector3(0.2, 0.08, 2.05), Color("4a3220"), Vector3(0, 30, 0))    # kırık basamak
	Props.ball(self, 0.22, ld.to_global(Vector3(0.0, 0.0, -2.3)) - Vector3(0, 0.08, 0), Color("8a8070"), Vector3(1.3, 0.7, 1.0), 6)
	# Sahipsiz miğfer ve devrilmiş ahşap perde (manto)
	var hx := 3.6
	var hz := 66.5
	Props.cyl(self, 0.13, 0.16, Vector3(hx, _gy(hx, hz) + 0.12, hz), Color("8a8f99"), Vector3(70, 20, 0), 10, 0.09)
	Props.cyl(self, 0.16, 0.02, Vector3(hx + 0.05, _gy(hx, hz) + 0.05, hz + 0.02), Color("6a6f78"), Vector3(70, 20, 0), 10)
	var mt := Node3D.new()
	mt.position = Vector3(10.2, _gy(10.2, 52.0), 52.0)
	mt.rotation.y = deg_to_rad(-20.0)
	add_child(mt)
	Props.box(mt, Vector3(3.0, 0.1, 2.1), Vector3(0, 0.06, 0), Color("6a4c30"))
	for k in 5:
		Props.box(mt, Vector3(0.12, 0.13, 2.1), Vector3(-1.3 + k * 0.65, 0.1, 0), Color("4e3620"))
	Props.cyl(mt, 0.35, 0.12, Vector3(1.7, 0.36, -0.7), Color("3a2a1e"), Vector3(0, 0, 70), 8)
	# Başıboş keçi: iki ordunun arasında otlar, yaklaşınca kaçar
	goat = Goat.new()
	goat.bounds = Rect2(-12.0, 75.0, 24.0, 12.0)
	goat.position = Vector3(4.0, 0.0, 80.0)
	add_child(goat)
	# Kovalanmaz (kaçarken kaldırdığı toz bulutu yürüyüşü örtüyordu); kendi alanında otlar


## Yere saplı oklar: üç çeşit (tam ok, kısa/dik saplanmış, kırılmış yatık), kümeler hâlinde (yaylım ateşinin düştüğü yer)
## ve seyrek tekler. Tür başına tek çoklu ağ; tüy ve demir uç ağın kendisinde (Assault.arrow_mesh).
func _build_arrows() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 81450
	var shaft := Color("6a4a2c")
	var short_m := Scenery.merged([
		[Scenery._cyl(0.011, 0.6, -1.0, 4), Scenery._t(Vector3.ZERO, Vector3(PI * 0.5, 0, 0)), shaft.darkened(0.1)],
		[Scenery._cyl(0.026, 0.08, 0.0, 4), Scenery._t(Vector3(0, 0, 0.33), Vector3(PI * 0.5, 0, 0)), Color("3a3a40")],
		[Scenery._boxm(Vector3(0.004, 0.06, 0.13)), Scenery._t(Vector3(0, 0, -0.24)), Color("d8cfb8")],
		[Scenery._boxm(Vector3(0.06, 0.004, 0.13)), Scenery._t(Vector3(0, 0, -0.24)), Color("c8b898")]])
	var broken_m := Scenery.merged([
		[Scenery._cyl(0.011, 0.4, -1.0, 4), Scenery._t(Vector3.ZERO, Vector3(PI * 0.5, 0, 0)), shaft],
		[Scenery._boxm(Vector3(0.004, 0.07, 0.14)), Scenery._t(Vector3(0, 0, -0.14)), Color("e8e0cc")],
		[Scenery._boxm(Vector3(0.07, 0.004, 0.14)), Scenery._t(Vector3(0, 0, -0.14)), Color("b8a888")],
		[Scenery._cyl(0.011, 0.25, -1.0, 4), Scenery._t(Vector3(0.05, 0, 0.36), Vector3(PI * 0.5, 0.5, 0)), shaft.lightened(0.1)]])
	var full: Array = []
	var shorts: Array = []
	var broken: Array = []
	var stuck := func(x: float, z: float, tilt: float, yaw: float) -> Transform3D:
		return Transform3D(Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, deg_to_rad(tilt)), Vector3(x, _gy(x, z) + 0.18, z))
	for c in 22:
		var cx := rng.randf_range(-13.5, 13.5)
		var cz := rng.randf_range(39.0, 100.0)
		for k in rng.randi_range(3, 8):
			var x := cx + rng.randf_range(-1.3, 1.3)
			var z := cz + rng.randf_range(-1.0, 1.0)
			var yaw := rng.randf_range(-0.35, 0.35)
			match rng.randi() % 5:
				0, 1:
					full.append(stuck.call(x, z, rng.randf_range(48.0, 72.0), yaw))
				2, 3:
					var t: Transform3D = stuck.call(x, z, rng.randf_range(62.0, 84.0), yaw)
					shorts.append(Transform3D(t.basis, t.origin - Vector3(0, 0.06, 0)))
				_:
					broken.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU) * Basis(Vector3.RIGHT, deg_to_rad(88.0)),
						Vector3(x, _gy(x, z) + 0.015, z)))
	for i in 40:
		var x := rng.randf_range(-14.0, 14.0)
		var z := rng.randf_range(38.0, 101.0)
		full.append(stuck.call(x, z, rng.randf_range(45.0, 78.0), rng.randf_range(-0.5, 0.5)))
	Scenery.scatter(self, Assault.arrow_mesh(), full, [], Scenery._vc_mat())
	Scenery.scatter(self, short_m, shorts, [], Scenery._vc_mat())
	Scenery.scatter(self, broken_m, broken, [], Scenery._vc_mat())


## Ölü bölgede üç sıra terk edilmiş siper (tekerlekli ahşap perde ve sepet): sırayla sağdan ve soldan açık, yürüyüş zikzak
## olur (65 m'lik düz yol ~100 m'ye çıkar). Perdelere saplı oklar; görünmez katı kutu görünen sıranın kendisi.
func _build_barriers() -> void:
	var d := Dressing.new(8140)
	var stuck: Array = []
	for b: Array in BARRIERS:
		var z: float = b[0]
		var x0: float = b[1]
		var x1: float = b[2]
		var x := x0 + 1.7
		var k := 0
		while x < x1 - 1.0:
			var yaw := sin(x * 1.3 + z) * 0.12
			var p := Vector3(x, _gy(x, z), z + sin(x * 0.7) * 0.3)
			d.at(p, yaw)
			if k % 3 == 2:
				for gx: float in [-0.7, 0.7]:
					SiegeField.gabion(d, Vector3(gx, 0, 0), 0.62, 1.5, fmod(absf(x) * 0.05, 0.15))
			else:
				d.box(Vector3(3.2, 2.3, 0.18), Vector3(0, 1.35, 0), SiegeField.WOOD.darkened(0.15), Vector3(-8, 0, 0))
				for j in 5:
					d.box(Vector3(0.1, 2.3, 0.22), Vector3(-1.4 + j * 0.7, 1.35, 0.02), SiegeField.WOOD.darkened(0.35), Vector3(-8, 0, 0))
				for j in 2:
					d.cyl(0.35, 0.12, Vector3(-1.3 + j * 2.6, 0.35, 0.35), Color("3a2a1e"), Vector3(0, 0, 90), 8)
				d.box(Vector3(0.1, 0.1, 1.4), Vector3(0, 0.9, 0.9), SiegeField.WOOD, Vector3(-40, 0, 0))
				# Perdenin sura bakan yüzüne saplanmış oklar (uç perdede, tüy sura doğru)
				for j in 3:
					var q := p + Basis(Vector3.UP, yaw) * Vector3(-1.0 + j * 0.9, 0.9 + fmod(x * 3.1 + j, 1.1), -0.25)
					stuck.append(Transform3D(Basis(Vector3.UP, yaw + 0.2 * (j - 1)) * Basis(Vector3.RIGHT, deg_to_rad(12.0)), q))
			x += 3.4
			k += 1
		_block(Vector3(x1 - x0, 2.4, 1.3), Vector3((x0 + x1) * 0.5, 1.2, z))
	d.build(self)
	Scenery.scatter(self, Assault.arrow_mesh(), stuck, [], Scenery._vc_mat())


## Osmanlı hatları: siperin önünde bir batarya, setin ardında iş başındaki askerler, ordugâhın ilk çadırları ve pazarın
## girişi (iki tezgâh, satıcı).
func _build_lines() -> void:
	var gy := Callable(self, "_gy")
	var d := Dressing.new(8120)
	var p := BATTERY + Vector3(0, _gy(BATTERY.x, BATTERY.z), 0)
	var yaw := atan2(p.x + GATE_X - (p.x + GATE_X) * 0.93, p.z - 15.0)
	d.at(p, yaw)
	d.box(Vector3(8.0, 0.05, 10.0), Vector3(0, 0.0, 0.5), Color("54462f"))
	d.box(Vector3(2.4, 0.5, 6.0), Vector3(0, 0.25, 0.2), Color("4e3620"))
	for k in 3:
		d.box(Vector3(2.9, 0.3, 0.4), Vector3(0, 0.12, -1.8 + k * 1.8), Color("3e2a1a"))
	d.cyl(0.6, 4.6, Vector3(0, 1.2, -0.3), Color("8c5e26"), Vector3(90, 0, 0), 12)
	d.cyl(0.71, 0.4, Vector3(0, 1.2, -2.6), Color("7a5020"), Vector3(90, 0, 0), 12)
	d.cyl(0.48, 0.08, Vector3(0, 1.2, -2.81), Color("15120f"), Vector3(90, 0, 0), 12)
	d.ball(0.36, Vector3(0, 1.2, 2.2), Color("7a5020"))
	d.box(Vector3(1.0, 0.4, 0.9), Vector3(0, 0.7, 1.6), Color("7a5634"))
	for gx: float in [-4.3, -3.0, -1.7, 1.7, 3.0, 4.3]:
		SiegeField.gabion(d, Vector3(gx, 0, -3.9), 0.64, 1.6, fmod(absf(gx) * 0.07, 0.15))
	for k in 10:
		var lay := 0 if k < 6 else (1 if k < 9 else 2)
		var idx := k if lay == 0 else (k - 6 if lay == 1 else 0)
		d.ball(0.3, Vector3(3.0 + (idx % 3) * 0.6 + lay * 0.3, 0.3 + lay * 0.48, 1.4 + (idx / 3) * 0.6 + lay * 0.3), Color("8a8478"))
	for k in 3:
		d.cyl(0.33, 0.8, Vector3(-3.4 + k * 0.72, 0.4, 2.4), Color("2e2a26"), Vector3.ZERO, 8)
	d.build(self)
	# Topçu: topun yanında durur, geçen Tolga'ya bakar (elinde kova); halat saran yardımcısı
	var gunner := Soldier.new(Color("c98a3a"), "stand", "bork")
	gunner.position = p + Basis(Vector3.UP, yaw) * Vector3(-1.7, 0, 0.8)
	add_child(gunner)
	gunner.look_target = player
	gunner.give_tool("bucket")
	# Tokmakçı: namlunun ağzının önünde (mazgalın açıklığında), iki elle tokmağı namluya sürer
	var muzzle := p + Basis(Vector3.UP, yaw) * Vector3(0, 1.2, -2.81)
	var rammer := Soldier.new(Color("b3262d"), "stand", "azap")
	rammer.position = p + Basis(Vector3.UP, yaw) * Vector3(-0.6, 0, -3.6)
	add_child(rammer)
	Stage.face(rammer, muzzle)
	rammer.give_tool("rammer", {"aim": muzzle, "aim_world": true})
	Stage.station(self, "coil_rope", BATTERY + Vector3(3.2, 0, 4.4), Vector3(-1, 0, 0.2), {"ground": gy, "person": false})
	# Setin ardında: kazı (siperi derinleştiren), kazan başında aşçı (ateşli), su içen, halat saran
	Stage.station(self, "dig", Vector3(-8.5, 0, 119.5), Vector3(0.6, 0, -1), {"ground": gy, "hat": "azap"})
	Stage.station(self, "stir_pot", Vector3(9.0, 0, 133.0), Vector3(-1, 0, 0), {"ground": gy, "fire": true})
	Stage.station(self, "drink", Vector3(-9.0, 0, 136.0), Vector3(1, 0, 0.2), {"ground": gy})
	Stage.station(self, "carry_sack", Vector3(-10.5, 0, 128.0), Vector3(0.3, 0, 1), {"ground": gy})
	# Çadırlar: koridorun iki yanında, ordugâhın ilk sıraları (çarpışmasız; koridorun dışında)
	var tx: Array = []
	var tc: Array = []
	for i in 8:
		var sx := -1.0 if i % 2 == 0 else 1.0
		var x := sx * (19.0 + fmod(i * 2.3, 5.0))
		var z := 128.0 + i * 3.0
		tx.append(Scenery._t(Vector3(x, _gy(x, z) - 0.1, z), Vector3(0, i * 0.9, 0), Vector3.ONE * (2.0 + fmod(i * 0.37, 0.8))))
		tc.append([Color("d4c8aa"), Color("cbbd9c"), Color("bcad8c"), Color("ddd1b6")][i % 4])
	Scenery.scatter(self, Scenery.tent_mesh(Color("7a3a2e")), tx, tc)
	_build_market()


## Pazarın girişi: Bölüm 9'un açıldığı yerin (CampDay._build_market, BYZ_SPAWN çevresi) aynısı. Ordugâh bölgesinin yerel
## koordinatı bu bölümde (−x, CAMP_Z0 − z)'ye düşer (iki bölge de sura bakar, yönleri ters): beş tezgâh aynı sırada,
## aynı tente renkleri ve mallar, "PAZAR" tabelası, meydanın kırmızı sancağı, pazar keçisi, mektup yazdıracak asker.
## Tolga'nın bittiği yer ve bakışı Bölüm 9'un ilk karesiyle aynı (BYZ_SPAWN, ordugâhın içine doğru).
func _camp(cx: float, cz: float, y := 0.0) -> Vector3:
	return Vector3(-cx, y, CAMP_Z0 - cz)


func _build_market() -> void:
	var awning := [Color("8a4a3a"), Color("56627a"), Color("a0804e"), Color("64704e"), Color("b8ab8e")]
	var dm := Dressing.new(748)
	dm.at(Vector3.ZERO, 0.0)
	for i in 5:
		var p := _camp(-8.0 + i * 4.0, 17.0)
		p.y = _gy(p.x, p.z)
		Props.solid(self, Vector3(2.4, 0.9, 1.2), p + Vector3(0, 0.45, 0), Color("7a5a38"))
		for k in 4:
			dm.cyl(0.04, 2.2, p + Vector3(1.1 - (k % 2) * 2.2, 1.1, 0.55 - (k / 2) * 1.1), Color("4a3020"), Vector3.ZERO, 4)
		dm.box(Vector3(2.8, 0.05, 1.8), p + Vector3(0, 2.2, -0.2), awning[i], Vector3(10, 0, 0))
		if Kit.has_food():
			var goods: Array = [["Apple", "Orange", "Apple_Green"], ["Eggplant", "Turnip", "Carrot"], ["Bread", "Bread_Slice"],
				["Fish", "Fish"], ["Jar_Large", "CookingPot", "FryingPan"]][i]
			if i < 2:
				var prng := RandomNumberGenerator.new()
				prng.seed = 60 + i
				Kit.produce(self, p + Vector3(0, 0.9, 0.15), 2.1, 0.8, prng, goods)
				continue
			for k in 10:
				var g: String = goods[k % goods.size()]
				var big := g in ["Jar_Large", "CookingPot", "FryingPan", "Fish", "Bread"]
				if big and k >= 5:
					continue
				Kit.food(self, g, p + Vector3(0.95 - (k % 5) * 0.47, 0.9, 0.35 - (k / 5) * 0.3), k * 1.7 + PI)
		else:
			for k in 5:
				Props.ball(self, 0.13, p + Vector3(0.9 - k * 0.45, 1.0, 0.2), [Color("e0a020"), Color("b3262d"), Color("6a8a3a"), Color("e8e0cc"), Color("c98a3a")][(k + i) % 5], Vector3.ONE, 6)
	dm.build(self)
	# "PAZAR" tabelası (iki yüzü yazılı) ve meydanın sancağı
	var sp := _camp(-2.5, 7.2)
	sp.y = _gy(sp.x, sp.z)
	Props.cyl(self, 0.05, 2.2, sp + Vector3(0, 1.1, 0), Color("4a3020"), Vector3.ZERO, 5)
	Props.box(self, Vector3(1.8, 0.45, 0.06), sp + Vector3(0, 2.0, 0), Color("c8a868"))
	Props.label(self, "PAZAR", sp + Vector3(0, 2.0, -0.035), 36, Color("2a1a10"), Vector3(0, 180, 0), 1.6)
	Props.label(self, "PAZAR", sp + Vector3(0, 2.0, 0.035), 36, Color("2a1a10"), Vector3.ZERO, 1.6)
	var fp := _camp(0.0, -4.0)
	fp.y = _gy(fp.x, fp.z)
	Props.cyl(self, 0.08, 7.0, fp + Vector3(0, 3.5, 0), Color("6a4c30"), Vector3.ZERO, 6)
	Props.box(self, Vector3(0.02, 1.0, 1.6), fp + Vector3(0, 6.3, -0.8), Color("c8262f"))
	Props.crescent(self, fp + Vector3(0, 6.3, -0.9), 0.22, Color("c8262f"), 0.02)
	# Pazarın keçisi (Bölüm 9'daki gibi tezgâhların arkasında dolaşır) ve mektup yazdıracak asker
	var mg := Goat.new()
	var gp := _camp(0.0, 11.0)
	mg.position = Vector3(gp.x, 0.0, gp.z)
	mg.bounds = Rect2(-7.0, CAMP_Z0 - 15.0, 14.0, 6.5)
	add_child(mg)
	var ls := Soldier.new(Color("3a6b3a"), "stand", "bork")
	ls.position = _camp(5.5, 12.0, _gy(-5.5, CAMP_Z0 - 12.0))
	ls.rotation.y = PI * 0.8 + PI
	add_child(ls)
	Props.solid(self, Vector3(0.5, 0.45, 0.5), ls.position + Vector3(-0.8, 0.22, -0.2), Color("8a6440"))


# ================================================================ havlu

## Sırık iki elde: kameranın çocuğu, eller sırığın iki noktasında (her karede izlenir), eldeki eşya cepte.
func _hold_towel(pole: Node3D = null) -> void:
	if is_instance_valid(_pole):
		return
	_pole = pole if pole != null else Towel.pole_model(0.07)
	Towel.set_sway(_pole, 0.07)
	_pole.set_meta("transient", true)       # Hud._held_audit: bölüm boyunca bilerek elde (sonda bırakılır)
	player.camera.add_child(_pole)
	_pole.position = POLE_UP_POS
	_pole.rotation_degrees = POLE_UP_ROT
	Props.strip_outlines(_pole)
	player.stow_hands(true)
	player.hold_both(Towel.LEFT_GRIP, Towel.RIGHT_GRIP, _pole)
	player.speed_mult = 0.66         # sırık iki elde, havlu başın üstünde: ağır, temkinli adım
	_towel_up = true


func _pose_towel(up: bool) -> void:
	if not is_instance_valid(_pole):
		return
	if _pole_tw and _pole_tw.is_valid():
		_pole_tw.kill()
	var t := 0.05 if Stage.fast() else 0.35
	_pole_tw = create_tween().set_parallel()
	_pole_tw.tween_property(_pole, "position", POLE_UP_POS if up else POLE_DOWN_POS, t).set_trans(Tween.TRANS_SINE)
	_pole_tw.tween_property(_pole, "rotation_degrees", POLE_UP_ROT if up else POLE_DOWN_ROT, t).set_trans(Tween.TRANS_SINE)
	Towel.set_sway(_pole, 0.07 if up else 0.02, 3.2 if up else 1.4)


## Sahnede (köprüde surdakilere bakarken, siperde sorguda) sırık omza yatar: bakışı kapatmaz; sayılmaz, uyarı getirmez
func _rest_towel(on: bool) -> void:
	if not is_instance_valid(_pole):
		return
	if not on:
		_pose_towel(_towel_up)
		return
	if _pole_tw and _pole_tw.is_valid():
		_pole_tw.kill()
	var t := 0.05 if Stage.fast() else 0.35
	_pole_tw = create_tween().set_parallel()
	_pole_tw.tween_property(_pole, "position", POLE_REST_POS, t).set_trans(Tween.TRANS_SINE)
	_pole_tw.tween_property(_pole, "rotation_degrees", POLE_REST_ROT, t).set_trans(Tween.TRANS_SINE)


func _set_towel(up: bool) -> void:
	if up == _towel_up or not is_instance_valid(_pole):
		return
	_towel_up = up
	if not up:
		_lowered += 1
	_pose_towel(up)
	Audio.sfx("cloth", -12.0, 1.1 if up else 0.9)


## Havlu bırakılır: sırık eller üstündeyken ekranın altına iner, sonra eller bırakır, eşya cepten çıkar.
func _drop_towel() -> void:
	if not is_instance_valid(_pole):
		return
	var p := _pole
	_pole = null
	if _pole_tw and _pole_tw.is_valid():
		_pole_tw.kill()
	var tw := create_tween()
	tw.tween_property(p, "position", Vector3(0.2, -0.75, -0.4), 0.05 if Stage.fast() else 0.45).set_trans(Tween.TRANS_SINE)
	player.speed_mult = 1.0
	tw.tween_callback(func() -> void:
		player.release_both()
		player.stow_hands(false)
		player.show_remote(true)
		p.queue_free())
	Audio.sfx("cloth", -12.0, 0.8)


func _towel_tick(delta: float) -> void:
	var v := player.velocity
	var running := _bot_running or (not player.frozen and Input.is_action_pressed("sprint") and Vector2(v.x, v.z).length() > Player.WALK + 0.4)
	if running:
		_run_t += delta
		if _towel_up:
			_set_towel(false)
			_auto_down = true
		_auto_t = 0.0
	else:
		_run_t = 0.0
		if _auto_down and not _towel_up:
			# Koşu bitince kol kendiliğinden kalkar
			_auto_t += delta
			if _auto_t > 0.6:
				_auto_down = false
				_auto_t = 0.0
				_set_towel(true)
	if not player.frozen and Input.is_action_just_pressed("interact"):
		_auto_down = false
		_set_towel(not _towel_up)
	_down_t = _down_t + delta if (not _towel_up and not running) else 0.0
	_warn_cd = maxf(0.0, _warn_cd - delta)
	if _warn_cd <= 0.0:
		if running and _run_t > 0.35:
			_warn("run")
		elif _down_t > DOWN_GRACE:
			_warn("down")
		elif absf(player.global_position.x) > LANE_HALF:
			_warn("side")
	# İpucu yalnız havlu inikken (kaldır); yukarıdayken indirmeyi önermez
	var pr := "" if _towel_up else GameState.tr_pad("UI_PROMPT8Y_RAISE")
	if pr != _prompt:
		_prompt = pr
		hud.set_prompt(pr)


## Sinerji oyuncunun arkasında yanından yürür (Chicken.follow); burada yalnız yürünen yerde tutulur: hendek geçidinden
## (x ±3,5) taşıp hendeğin üstünde havada kalmasın, kapı ve peribolos duvarlarına girmesin; ayağı görünen zeminde.
func _move_lead() -> void:
	if not is_instance_valid(_lead):
		return
	var f := -player.camera.global_transform.basis.z if player.camera else Vector3.BACK
	f.y = 0.0
	f = f.normalized() if f.length() > 0.01 else Vector3.BACK
	var r := f.cross(Vector3.UP)        # sağ
	var walking := not _busy and phase in ["peri", "out", "field", "lines"]
	var p := player.global_position + (f * 3.4 + r * 1.3 if walking else f * 1.4 + r * 0.9)
	_lead.global_transform = Transform3D(Basis(Vector3.UP, atan2(-f.x, -f.z)), Vector3(p.x, player.global_position.y, p.z))


func _keep_sinerji() -> void:
	if not is_instance_valid(sinerji):
		return
	_move_lead()
	var p := sinerji.global_position
	var lim := 13.5
	if p.z < -4.0:
		lim = 8.0
	elif p.z < 14.5:
		lim = 3.0 if p.z > -4.6 and p.z < 0.0 else 5.5
	elif p.z < 36.6:
		lim = 2.7
	p.x = clampf(p.x, -lim, lim)
	p.z = minf(p.z, 151.0)
	p.y = _gy(p.x, p.z)
	sinerji.global_position = p


## Uyarı okunda tavuk ürker: bir an kanat çırpar
func _scare_sinerji() -> void:
	if not is_instance_valid(sinerji):
		return
	sinerji.flapping = true
	Audio.sfx_at("chicken", sinerji, -8.0)
	await _wait(1.2)
	if is_instance_valid(sinerji):
		sinerji.flapping = false


## Uyarı oku: ayağının bir adım önüne saplanır (surdan ya da siperden), o taraf bağırır, Tolga söylenir.
func _warn(reason: String) -> void:
	_warn_cd = WARN_GAP
	_warnings += 1
	var pp := player.global_position
	var fwd := -player.camera.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized() if fwd.length() > 0.01 else Vector3.BACK
	var side := fwd.cross(Vector3.UP)
	# Bakış yönünde 6 m önü, sırığın karşı yanı (altyazı kutusunun üstünde, ufka yakın). Oyuncu yürüyor/koşuyorsa ok
	# uçarken aldığı yol da eklenir: ok saplandığında yine ayağının 3-8 m önünde, bakışın içinde olur.
	var hv := Vector3(player.velocity.x, 0.0, player.velocity.z)
	var lead := hv * 0.8 if hv.dot(fwd) > 0.0 else Vector3.ZERO
	var land := pp + fwd * 6.0 + lead.limit_length(4.0) + side * -1.4
	land.y = _gy(land.x, land.z)
	var from_wall := pp.z < 70.0
	var src := Vector3(land.x * 0.5 + (2.0 if _warnings % 2 == 0 else -2.0), 9.5, 15.0) if from_wall else Vector3(land.x + 1.5, 2.6, 110.0)
	_shoot_arrow(src, land)
	_scare_sinerji()
	var line: Array = (WARN_WALL if from_wall else WARN_TRENCH)[1 if reason == "run" else 0]
	_warn_lines(line, WARN_TOLGA[(_warnings - 1) % WARN_TOLGA.size()])


func _warn_lines(line: Array, answer: Array) -> void:
	hud.bark(line[0], line[1], 3.6, true)
	await _wait(1.6)
	if phase == "field":
		hud.bark(answer[0], answer[1], 3.6)


func _shoot_arrow(from: Vector3, to: Vector3) -> void:
	var a := MeshInstance3D.new()
	a.mesh = Assault.arrow_mesh()
	a.material_override = Scenery._vc_mat()
	add_child(a)
	a.scale = Vector3.ONE * 1.7
	var dir := (to - from).normalized()
	# Okun ucu yerel +Z'de: ok gidiş yönüne bakar; saplanınca ucu toprağın içinde
	a.global_transform = Transform3D(Basis.looking_at(-dir, Vector3.UP), from)
	var rest := to - dir * 0.28
	Audio.sfx("whoosh_fly", -10.0, 1.3)
	if Stage.fast():
		a.global_position = rest
	else:
		var tw := create_tween()
		tw.tween_property(a, "global_position", rest, clampf(from.distance_to(to) / 70.0, 0.25, 0.9)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await tw.finished
	Audio.sfx("land_thud", -14.0, 1.6)
	_dust(to)
	# Saplanan ok titrer, sonra durur
	var r0 := a.rotation.x
	var qt := create_tween()
	for k in 5:
		var amp := deg_to_rad(5.0) * (1.0 - k / 5.0) * (1.0 if k % 2 == 0 else -1.0)
		qt.tween_property(a, "rotation:x", r0 + amp, 0.06)
	qt.tween_property(a, "rotation:x", r0, 0.06)
	_cshot("ok_%d" % _warnings, 0.05)


## Saplanan okun tozu: küçük, yarı saydam, çabuk dağılan birkaç zerre (ok seçilsin; Vfx.dust bu yakınlıkta ekranı örtüyordu)
func _dust(at: Vector3) -> void:
	var p := CPUParticles3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(0.16, 0.16)
	q.material = Vfx._soft_mat(Color(0.74, 0.64, 0.5, 0.42))
	p.mesh = q
	p.one_shot = true
	p.amount = 10
	p.lifetime = 0.55
	p.explosiveness = 0.9
	p.direction = Vector3.UP
	p.spread = 70.0
	p.initial_velocity_min = 0.4
	p.initial_velocity_max = 1.0
	p.gravity = Vector3(0, -1.2, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.3
	add_child(p)
	p.global_position = at + Vector3(0, 0.05, 0)
	p.emitting = true
	get_tree().create_timer(1.2, false).timeout.connect(p.queue_free)


# ================================================================ ana akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH8Y_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH8Y_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.6)
	hud.clear_card()
	player.global_position = START + Vector3(0, 0.05, 0)
	player.face(NIKO_AT + Vector3(0, 1.5, 0))
	if _deported:
		player.sit_view(true)
	if GameState.flags.get("sinerji", false):
		sinerji = Chicken.new()
		add_child(sinerji)
		sinerji.process_priority = -10      # önce tavuk yürür, sonra bölüm onu koridorda ve zeminde tutar (_keep_sinerji)
		sinerji.global_position = player.global_position + Vector3(0.8, 0, 1.0)
		sinerji.global_position.y = _gy(sinerji.global_position.x, sinerji.global_position.z)
		_lead = Node3D.new()
		add_child(_lead)
		_move_lead()
		sinerji.follow = _lead
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	if _deported:
		await _say("SPK_NIKO", "D8Y_NIKO_DEP")
		player.sit_view(false)
		await _t("D8Y_T_DEP")
		await _offer_towel()
		await _say("SPK_NIKO", "D8Y_NIKO_DEP_TOWEL")
		await _take_towel()
		await _t("D8Y_T_DEP_TOWEL")
	else:
		await _offer_towel()
		await _say("SPK_NIKO", "D8Y_NIKO_1")
		await _take_towel()
		await _t("D8Y_T_TOWEL")
		await _say("SPK_NIKO", "D8Y_NIKO_TOWEL")
		if GameState.flags.get("letter_opened", false):
			await _say("SPK_NIKO", "D8Y_NIKO_OPENED")
			await _t("D8Y_T_OPENED")
		else:
			await _say("SPK_NIKO", "D8Y_NIKO_LETTER")
			await _t("D8Y_T_LETTER")
	if is_instance_valid(sinerji):
		# "Sınır dışı edilen bir tek sen değilsin" yalnız 6b.3'te doğru; öbür yolda nötr söz
		if _deported:
			await _say("SPK_NIKO", "D8Y_NIKO_SINERJI")
		else:
			await _say("SPK_NIKO", "D8Y_NIKO_SINERJI_N")
	GameState.meet("niko")
	# Niko önden dış sur kapısına yürür; Tolga peşinden
	Stage.walk_on_ground(niko, NIKO_GATE, Callable(self, "_gy"), 1.6, Vector3(0, 0, 13.0))
	phase = "peri"
	hud.set_objective(tr("UI_OBJ8Y_GATE"), Vector3(0, 1.6, 12.6))
	player.frozen = false
	if GameState.autotest:
		_auto()
	while _outcome == "":
		await get_tree().process_frame
	while _busy:
		await get_tree().process_frame
	await _end_chapter()


## Niko sırığı baştan elinde tutar (sağ önkolunda, mızrak gibi dik); uzatırken kolu Tolga'ya doğru gelir (Stage.grip_hold),
## sırık onun elinden Tolga'nın iki eline süzülür ve orada iki elle tutulan sırık olur (aynı nesne, aynı duruş).
var _niko_pole: Node3D
var _niko_arm0: Array = []


func _niko_pole_on() -> void:
	# İskeletin (Rig) sağ önkolu: uzanırken (grip_hold) kol onu taşır; eski _elbow_r düğümü kolla gitmiyordu
	var rg := Handover.rig_of(niko)
	if rg == null or rg.elbow_r == null:
		niko.ready.connect(_niko_pole_on, CONNECT_ONE_SHOT)
		return
	_niko_pole = Towel.pole_model(0.06)
	rg.elbow_r.add_child(_niko_pole)
	_niko_pole.position = Vector3(0, -0.3, 0.08)
	_niko_pole.rotation_degrees = Vector3(0, 0, -7)
	niko.set_meta("armed", true)


func _offer_towel() -> void:
	player.face(niko.global_position + Vector3(0, 1.3, 0))
	player.show_remote(false)        # sağ el boşalır: sırığı alacak
	var to := player.global_position - niko.global_position
	to.y = 0.0
	var pt := niko.global_position + to.normalized() * 0.7 + Vector3(0, 1.25, 0)
	# Sırığı tutan SAĞ kol uzanır (grip_hold tek noktada yakın eli seçiyordu: sırıksız kol uzanıyordu)
	var rg := Handover.rig_of(niko)
	if rg and rg.arm_r and rg.elbow_r:
		rg.lock += 1
		_niko_arm0 = [rg.arm_r.rotation, rg.elbow_r.rotation]
		Rig.reach(rg.arm_r, rg.elbow_r, pt, Vector3.DOWN + niko.global_transform.basis.x * 0.6)
		var r1: Vector3 = rg.arm_r.rotation
		var e1: Vector3 = rg.elbow_r.rotation
		rg.arm_r.rotation = _niko_arm0[0]
		rg.elbow_r.rotation = _niko_arm0[1]
		var at := create_tween().set_parallel()
		at.tween_property(rg.arm_r, "rotation", r1, 0.35).set_trans(Tween.TRANS_SINE)
		at.tween_property(rg.elbow_r, "rotation", e1, 0.35)
		await at.finished
		# Kol uzanınca sırık elde dik kalır (önkolla yatmasın), tepesi hafifçe Tolga'ya eğik
		if is_instance_valid(_niko_pole):
			var yaw := atan2(to.x, to.z)
			_niko_pole.global_basis = Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, deg_to_rad(10.0))
	# Uzatma görünür olsun (otomatik testte de: replik karesi bu duruşu yakalar)
	await get_tree().create_timer(0.45, false).timeout
	_cshot("verme_1_uzatir")


func _take_towel() -> void:
	var pole := _niko_pole
	_niko_pole = null
	if not is_instance_valid(pole):
		_hold_towel()
		return
	var gt := pole.global_transform
	pole.get_parent().remove_child(pole)
	add_child(pole)
	pole.global_transform = gt
	var dest := player.camera.global_transform * Transform3D(Basis.from_euler(POLE_UP_ROT * PI / 180.0), POLE_UP_POS)
	Audio.sfx("cloth", -10.0, 1.1)
	var tw := create_tween()
	tw.tween_property(pole, "global_transform", dest, 0.45).set_trans(Tween.TRANS_SINE)
	player.hand_gesture("reach", 0.5)
	_cshot("verme_2_gecis", 0.2)
	await tw.finished
	var rg := Handover.rig_of(niko)
	if rg and not _niko_arm0.is_empty():
		var bt := create_tween().set_parallel()
		bt.tween_property(rg.arm_r, "rotation", _niko_arm0[0], 0.3)
		bt.tween_property(rg.elbow_r, "rotation", _niko_arm0[1], 0.3)
		bt.chain().tween_callback(func() -> void: rg.lock = maxi(0, rg.lock - 1))
		_niko_arm0 = []
	niko.remove_meta("armed")
	pole.get_parent().remove_child(pole)
	_hold_towel(pole)


func _process(delta: float) -> void:
	if hud == null or player == null or GameState.shots_dir != "":
		return
	_keep_sinerji()
	var pz := player.global_position.z
	match phase:
		"peri":
			if not _busy and pz > GATE_TRIGGER_Z:
				_gate_scene()
		"out":
			if not _busy and pz > BRIDGE_Z and not _fired.has("bridge"):
				_bridge_scene()
			elif not _busy and pz > FIELD_Z and _fired.has("bridge"):
				_start_field()
		"field":
			_towel_tick(delta)
			_events(pz, delta)
			if not _busy and pz > HALT_Z and not _fired.has("halt"):
				_halt_scene()
			if not _busy and pz > TRENCH_Z:
				_trench()
		"lines":
			if not _busy and pz > END_Z:
				_finale()


# ---------------------------------------------------------------- dış sur kapısı

func _gate_scene() -> void:
	_busy = true
	phase = "gate"
	player.frozen = true
	hud.set_objective("")
	await Stage.settle(niko)
	guard.look_target = player
	player.face(guard.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_NIKO", "D8Y_NIKO_GATE")
	await _say("SPK_CITY_GUARD", "D8Y_GUARD_GATE")
	await _say("SPK_NIKO", "D8Y_NIKO_GATE2")
	await _open_gate()
	player.face(niko.global_position + Vector3(0, 1.4, 0))
	await _say("SPK_NIKO", "D8Y_NIKO_RULES")
	await _t("D8Y_T_BYE")
	await _say("SPK_NIKO", "D8Y_NIKO_BYE")
	player.face(Vector3(0, 1.6, 30.0))
	for a: Soldier in _archers:
		a.look_target = player
	phase = "out"
	hud.set_objective(tr("UI_OBJ8Y_FIELD"), Vector3(0, 1.6, 104.0))
	player.frozen = false
	_busy = false


## Nöbetçi sürgüye yürür, kaldırır ve kenara yere bırakır; kanatlar peribolosa doğru açılır.
func _open_gate() -> void:
	var gy := Callable(self, "_gy")
	await Stage.walk_on_ground(guard, Vector3(-0.9, 0, 12.6), gy, 1.6, BAR_AT)
	# İki elle sürgüyü yuvalarından kaldırır (eller sürgüde), sürgüyü taşıyarak kulenin dibine götürür, dikine yaslar
	# Eller sürgünün kendi yerelinde (Stage.grip_hold her karede izler): kaldırırken ve taşırken sürgüde kalır
	Stage.grip_hold(guard, _bar, [Vector3(-1.25, 0.0, -0.1), Vector3(-0.55, 0.0, -0.1)], -1.0, 0.1)
	await _wait(0.35)
	Audio.sfx("wood_creak", -8.0, 1.2)
	var lift := create_tween()
	lift.tween_property(_bar, "position", BAR_AT + Vector3(0, 0.3, -0.25), _d(0.4)).set_trans(Tween.TRANS_SINE)
	await lift.finished
	var walk_t := _d(1.4)
	var carry := create_tween().set_parallel()
	carry.tween_property(guard, "global_position", Vector3(-3.95, _gy(-3.95, 11.95), 11.95), walk_t)
	carry.tween_property(_bar, "position", BAR_DOWN, walk_t).set_trans(Tween.TRANS_SINE)
	carry.tween_property(_bar, "rotation_degrees", Vector3(10, 0, 90), walk_t).set_trans(Tween.TRANS_SINE)
	guard.set_meta("stage_walk", true)
	await carry.finished
	guard.remove_meta("stage_walk")
	Stage.grip_release(guard)
	Audio.sfx("land_thud", -12.0, 0.8)
	await Stage.walk_on_ground(guard, GUARD_AT, gy, 1.6, Vector3(0, 0, 8.0))
	Audio.sfx("door_open", -6.0, 0.8)
	Audio.sfx("wood_creak", -10.0, 0.7)
	var tw2 := create_tween().set_parallel()
	tw2.tween_property(_leaf_l, "rotation:y", deg_to_rad(95.0), _d(1.6)).set_trans(Tween.TRANS_SINE)
	tw2.tween_property(_leaf_r, "rotation:y", deg_to_rad(-95.0), _d(1.6)).set_trans(Tween.TRANS_SINE)
	await tw2.finished


# ---------------------------------------------------------------- hendek köprüsü ve ölü bölge

func _bridge_scene() -> void:
	_fired["bridge"] = true
	_busy = true
	player.frozen = true
	await _cshot("gecit")
	player.face(player.global_position + Vector3(9.0, -3.2, 4.0))
	await _cshot("hendek", 0.1)
	lookout.look_target = player
	# Tolga dönüp kapının üstüne bakar; sırığı omzuna yatırır (sırık ve el kapıdakileri örtmesin)
	_rest_towel(true)
	player.face(Vector3(0.4, 9.3, 15.0))
	_say("SPK_LOOKOUT", "D8Y_WALL_1")
	# Okçular gözcünün sözü başlayınca indirir (testte de görünür süre: replik karesi nişanı, sonraki indirmeyi yakalar)
	await get_tree().create_timer(0.7, false).timeout
	_cshot("yay_1_nisanda")
	await get_tree().create_timer(0.3, false).timeout
	_lower_bows()
	await _cshot("yay_2_indi", 0.6)
	while hud.is_talking():
		await get_tree().process_frame
	await _say("SPK_LOOKOUT", "D8Y_WALL_2")
	player.face(player.global_position + Vector3(0, 1.5, 12.0))
	_rest_towel(false)
	await _t("D8Y_T_BRIDGE")
	player.frozen = false
	_busy = false


## Okçular yayı indirir: nişan duruşundan (kollar önde, gövde öne) ayakta duruşa, sonra yine Tolga'yı izler
func _lower_bows() -> void:
	for a: Soldier in _archers:
		if not is_instance_valid(a):
			continue
		a.pose = "stand"
		var body = a.get("_body")
		if body is Node3D:
			var tw := create_tween()
			tw.tween_property(body, "rotation:x", 0.0, _d(0.4))


## Siperden "Dur orada!": Tolga durur, havluyu başının üstünde sağa sola sallar; Hüseyin "gel, yavaş" diyene kadar.
func _halt_scene() -> void:
	_fired["halt"] = true
	_busy = true
	while hud.is_talking() or hud.chain_busy():
		await get_tree().process_frame
	player.frozen = true
	_auto_down = false
	_set_towel(true)
	player.face(player.global_position + Vector3(0, 1.6, 12.0))
	await _say("SPK_HASAN", "D8Y_HASAN_STOP")
	_cshot("salla", 1.5)
	await _wave_towel(6.0)
	await _say("SPK_HUSEYIN", "D8Y_HUSEYIN_COME")
	player.frozen = false
	_busy = false


## Sırık iki elde, başın üstünde sağa sola sallanır (havlu hızlı dalgalanır), sonra yerine döner
func _wave_towel(secs: float) -> void:
	if not is_instance_valid(_pole):
		return
	if _pole_tw and _pole_tw.is_valid():
		_pole_tw.kill()
	Towel.set_sway(_pole, 0.11, 5.0)
	var n := maxi(2, int(secs / 0.7))
	var tw := create_tween()
	for k in n:
		var side := -1.0 if k % 2 == 0 else 1.0
		tw.tween_property(_pole, "rotation_degrees", POLE_UP_ROT + Vector3(0, 0, side * 16.0), 0.35).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_pole, "rotation_degrees", POLE_UP_ROT, 0.3)
	Audio.sfx("cloth", -10.0, 1.2)
	await tw.finished
	Towel.set_sway(_pole, 0.07, 3.2)


func _start_field() -> void:
	_cshot("gecit_arka")
	phase = "field"
	_warn_cd = 2.0
	# Telsiz ölü bölgenin başında; Tolga'nın yorumları sıraya girer, telsizden sonra sırayla söylenir (kaybolmaz)
	_fired["radio"] = true
	_radio()


## Yürürken tek seferlik olaylar: [z0, z1] aralığında ve konuşma yokken bir kez; aralık geçildiyse atlanır.
var _queue: Array = []
var _queue_gap := 0.0


## Yürürken tek seferlik yorumlar: yeri gelince sıraya girer; sıra telsiz ya da başka söz yokken, aralarında 4,5 sn
## boşlukla söylenir. Çok geride kalan (yerinden 25 m'den fazla ileride) yorum söylenmez.
func _events(pz: float, delta: float) -> void:
	_queue_gap = maxf(0.0, _queue_gap - delta)
	if _busy:
		return
	_event("mantlet", pz, 46.0, 60.0, "D8Y_T_MANTLET")
	_event("arrows", pz, 56.0, 76.0, "D8Y_T_ARROWS")
	if player.global_position.distance_to(LADDER_AT) < 10.0:
		_event("ladder", pz, 54.0, 72.0, "D8Y_T_LADDER")
	if player.global_position.distance_to(goat.global_position) < 12.0:
		_event("goat", pz, 72.0, 90.0, "D8Y_T_GOAT")
	_event("crater", pz, 91.0, 101.0, "D8Y_T_CRATER")
	_event("battery", pz, 96.0, 104.0, "D8Y_T_BATTERY")
	while not _queue.is_empty() and float((_queue[0] as Array)[1]) < pz - 25.0:
		_queue.pop_front()
	if _queue.is_empty() or _queue_gap > 0.0 or hud.is_talking() or hud.chain_busy() or _fired.get("radio_live", false):
		return
	var it: Array = _queue.pop_front()
	_queue_gap = 4.5
	hud.bark("SPK_TOLGA", it[0], 4.5)
	_cshot("yorum_" + String(it[0]).trim_prefix("D8Y_T_").to_lower(), 0.4)
	if GameState.autotest:
		print("YORUM8Y %s z=%.1f" % [it[0], pz])


func _event(id: String, pz: float, z0: float, _z1: float, key: String) -> void:
	if _fired.has(id) or pz < z0:
		return
	_fired[id] = true
	_queue.append([key, z0])


## Hikmet'in telsizi (bir kez): bağ yoksa ya da Hikmet zaten 1453'teyse (8.4) çalmaz; telsiz göstergesi değişmez.
func _radio() -> void:
	if GameState.telsiz_bag <= 0 or str(GameState.chapter_outcomes.get(8, "")) == "8.4":
		return
	_fired["radio_live"] = true
	var t := 0.0
	while (hud.is_talking() or hud.chain_busy()) and t < 10.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	Audio.sfx("radio_beep", -8.0)
	_radio_done = true
	hud.say_chain(RADIO)
	await hud.chain_done
	_fired["radio_live"] = false


# ---------------------------------------------------------------- Osmanlı siperi

func _trench() -> void:
	_busy = true
	phase = "trench"
	_queue.clear()
	hud.set_prompt("")
	_prompt = ""
	while hud.chain_busy() or hud.is_talking():
		await get_tree().process_frame
	player.frozen = true
	hud.set_objective("")
	_auto_down = false
	_set_towel(true)
	var mid := (HASAN_AT + HUSEYIN_AT) * 0.5
	hasan.look_target = player
	huseyin.look_target = player
	await Stage.walk_player(player, mid, 2.8, mid + Vector3(0, 1.5, 0))
	player.frozen = true
	await _say("SPK_HASAN", "D8Y_HASAN_1")
	# Kim kim (GDD §5.7): Hüseyin soruyu üstüne alınır, Hasan düzeltir
	await _say("SPK_HUSEYIN", "D8Y_HUSEYIN_WHO")
	await _say("SPK_HASAN", "D8Y_HASAN_WHO")
	await _say("SPK_HUSEYIN", "D8Y_HUSEYIN_1")
	await _say("SPK_HASAN", "D8Y_HASAN_2")
	await _t("D8Y_T_TRENCH")
	await _say("SPK_HUSEYIN", "D8Y_HUSEYIN_2")
	var keys: Array = []
	if _letter:
		keys.append("UI_CH8Y_SEAL")
	var item := _show_item()
	if item != "":
		keys.append("UI_CH8Y_ITEM")
	keys.append("UI_CH8Y_HONEST")
	var want: String = {"warn": "UI_CH8Y_ITEM", "dep": "UI_CH8Y_HONEST", "honest": "UI_CH8Y_HONEST"}.get(GameState.autotest_variant, "UI_CH8Y_SEAL")
	var c := await hud.choose(keys, 0.0, maxi(0, keys.find(want)))
	var picked: String = keys[clampi(c, 0, keys.size() - 1)]
	_rest_towel(true)        # sorguda sırık omza: gösterilen şey ve nöbetçiler bakışta açık kalsın
	match picked:
		"UI_CH8Y_SEAL":
			_id = "seal"
			await _show_letter(true)
			await _say("SPK_HASAN", "D8Y_HASAN_SEAL")
			await _show_letter(false)
			if GameState.flags.get("letter_opened", false):
				await _say("SPK_HUSEYIN", "D8Y_HUSEYIN_SEAL_OPEN")
			else:
				await _say("SPK_HUSEYIN", "D8Y_HUSEYIN_SEAL")
		"UI_CH8Y_ITEM":
			_id = "item"
			player.show_prop(item, 2.6)
			hud.show_reaction("npc:guards", item)
			await _wait(1.0)
			await _say("SPK_HASAN", "D8Y_HASAN_ITEM")
		_:
			_id = "honest"
			await _t("D8Y_T_HONEST_DEP" if _deported else "D8Y_T_HONEST")
			await _say("SPK_HASAN", "D8Y_HASAN_HONEST")
	GameState.meet("guards")
	await _say("SPK_HUSEYIN", "D8Y_HUSEYIN_END")
	await _say("SPK_HASAN", "D8Y_HASAN_END")
	_drop_towel()
	# Hasan önden, hatların içinden (kazıcının, kazanın yanından) pazara yürür; hedef işareti onun üstünde. Hüseyin kalır.
	_hasan_lead()
	huseyin.look_target = null
	phase = "lines"
	hud.set_objective(tr("UI_OBJ8Y_LINES"), hasan, 2.0)
	player.frozen = false
	_busy = false


## Mühürlü mektup: sol el cepten çıkarıp mühür nöbetçilere görünecek biçimde göğüs altında tutar (sağ el sırıkta);
## Hasan'ın sözünden sonra cebe geri girer. El Player'ın gösterilen eşya tutuşu (hold_model: sol el kâğıdın köşesinde).
var _letter_node: Node3D
## Gösterme yeri (kamera yereli): ortanın biraz altı, iki nöbetçinin arasında, altyazının üstünde; Hasan'a uzatılmış
const LETTER_SHOW := Vector3(-0.01, -0.12, -0.5)


func _show_letter(on: bool) -> void:
	if on:
		_letter_node = Towel.letter_model()
		player.hold_model(_letter_node)          # sol (boş) el kâğıdın sol alt köşesinden tutar; sırık sağ elde omuzda
		_letter_node.position = Vector3(-0.08, -0.42, -0.42)
		_letter_node.rotation_degrees = Vector3(-10, 6, 4)
		Audio.sfx("paper_tear", -16.0, 1.4)
		var tw := create_tween().set_parallel()
		tw.tween_property(_letter_node, "position", LETTER_SHOW, 0.05 if Stage.fast() else 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_property(_letter_node, "rotation_degrees", Vector3(-22, 4, 3), 0.05 if Stage.fast() else 0.45)
		await tw.finished
		_cshot("muhur", 0.3)
		return
	if not is_instance_valid(_letter_node):
		return
	var n := _letter_node
	_letter_node = null
	var tw2 := create_tween()
	tw2.tween_property(n, "position", Vector3(-0.12, -0.5, -0.36), 0.05 if Stage.fast() else 0.5).set_trans(Tween.TRANS_SINE)
	_cshot("muhur_iner", 0.25)
	tw2.tween_callback(n.queue_free)
	await tw2.finished


var _hasan_walking := false


func _hasan_lead() -> void:
	_hasan_walking = true
	hasan.look_target = null
	for q: Vector3 in [Vector3(-6.0, 0, 122.0), Vector3(6.0, 0, 131.0), MARKET_AT]:
		await Stage.walk_on_ground(hasan, q, Callable(self, "_gy"), 1.35)
	Stage.face(hasan, MARKET_AT + Vector3(0, 0, -6.0))
	_hasan_walking = false


## Çantada Hasan ile Hüseyin'in tepkisi olan ilk eşya ("" yoksa)
func _show_item() -> String:
	for id: String in SHOW_ORDER:
		if GameState.has_item(id) and tr("REACT_GUARDS_" + id.to_upper()) != "REACT_GUARDS_" + id.to_upper():
			return id
	return ""


# ---------------------------------------------------------------- pazar girişi

func _finale() -> void:
	_busy = true
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	while _hasan_walking:
		await get_tree().process_frame
	Stage.face(hasan, player.global_position)
	hasan.look_target = player
	player.face(hasan.global_position + Vector3(0, 1.5, 0))
	await _say("SPK_HASAN", "D8Y_HASAN_MARKET")
	# Son kare Bölüm 9'un ilk karesi: BYZ_SPAWN'da, ordugâhın içine (tezgâhlara, sancağa) bakarak
	await Stage.walk_player(player, END_AT, 0.05, END_AT + Vector3(0, 1.6, 10.0))
	player.face(END_AT + Vector3(0, 1.6, 10.0))
	if is_instance_valid(sinerji):
		sinerji.global_position = END_AT + Vector3(1.0, _gy(1.0, END_AT.z + 2.6), 2.6)
		sinerji.rotation.y = 0.0
	await _t("D8Y_T_END_DEP" if _deported else "D8Y_T_END")
	if _deported:
		_outcome = "8Y.3"
	else:
		_outcome = "8Y.1" if _warnings == 0 else "8Y.2"
	_busy = false


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	phase = "done"
	player.frozen = true
	hud.set_objective("")
	hud.set_prompt("")
	_drop_towel()
	GameState.flags["ch8y_done"] = true
	GameState.flags["ch8y_warnings"] = _warnings
	GameState.flags["ch8y_id"] = _id
	GameState.set_outcome(NO, _outcome)
	await hud.fade_to(1.0, 0.8)
	var chart := _make_chart()
	var result := await hud.show_flowchart(chart, true)
	Engine.time_scale = 1.0
	if GameState.autotest and GameState.autotest_variant == "next":
		print("AUTOTEST chapter=8y -> 9 outcome=%s" % _outcome)
		# Bölüm 9'un Bizans yolundaki testi: Theodoros'un teklifi (6b.1; varsayılan "" Kadri'yi arar, bu yolda yok)
		GameState.autotest_variant = "arch"
		get_tree().change_scene_to_file("res://scenes/chapter9.tscn")
		return
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			GameState.change_scene("res://scenes/chapter9.tscn")
		"replay":
			GameState.replay_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW8Y_TITLE")
	c.nodes = [
		{"id": "niko", "key": "FLOW8Y_NIKO", "pos": Vector2(0.28, 0.14)},
		{"id": "cell", "key": "FLOW8Y_CELL", "pos": Vector2(0.72, 0.14)},
		{"id": "field", "key": "FLOW8Y_FIELD", "pos": Vector2(0.5, 0.32)},
		{"id": "seal", "key": "FLOW8Y_SEAL", "pos": Vector2(0.18, 0.5)},
		{"id": "item", "key": "FLOW8Y_ITEM", "pos": Vector2(0.5, 0.5)},
		{"id": "honest", "key": "FLOW8Y_HONEST", "pos": Vector2(0.82, 0.5)},
		{"id": "8Y.1", "key": "FLOW_8Y_1", "pos": Vector2(0.18, 0.74), "outcome": true},
		{"id": "8Y.2", "key": "FLOW_8Y_2", "pos": Vector2(0.5, 0.74), "outcome": true},
		{"id": "8Y.3", "key": "FLOW_8Y_3", "pos": Vector2(0.82, 0.74), "outcome": true},
	]
	c.edges = [["niko", "field"], ["cell", "field"], ["field", "seal"], ["field", "item"], ["field", "honest"],
		["seal", "8Y.1"], ["seal", "8Y.2"], ["item", "8Y.1"], ["item", "8Y.2"], ["item", "8Y.3"], ["honest", "8Y.1"],
		["honest", "8Y.2"], ["honest", "8Y.3"]]
	c.taken["cell" if _deported else "niko"] = true
	c.taken["field"] = true
	if _id != "":
		c.taken[_id] = true
	c.taken[_outcome] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH8Y_STATS") % [_warnings, _lowered],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW8Y_NEXT"),
		GameState.tr_pad("UI_FLOW_CONTINUE"),
	]
	return c


# ================================================================ yardımcılar

func _npc(speaker: String) -> Node3D:
	match speaker:
		"SPK_NIKO": return niko
		"SPK_CITY_GUARD": return guard
		"SPK_LOOKOUT": return lookout
		"SPK_HASAN": return hasan
		"SPK_HUSEYIN": return huseyin
	return null


func _t(key: String) -> void:
	await hud.say("SPK_TOLGA", key)


func _say(speaker: String, key: String) -> void:
	var who := _npc(speaker)
	if who:
		who.set("talking", true)
	await hud.say(speaker, key)
	if who and is_instance_valid(who):
		who.set("talking", false)


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ================================================================ otomatik test

## Test botu yürür (oyuncu donuk; konum zemin yüksekliğinde adım adım). Sahne açıkken (_busy) bekler. PACE'te gerçek
## yürüme hızı, yoksa kare başına 0,35 m (tetikler sırayla çalışsın diye ışınlanmaz).
func _bot_to(target: Vector3) -> void:
	var t := 0.0
	while t < 240.0:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if _outcome != "":
			return
		if _busy:
			continue
		var pp := player.global_position
		var d := Vector3(target.x - pp.x, 0.0, target.z - pp.z)
		if d.length() < 0.4:
			return
		var step := minf(d.length(), Player.WALK * player.speed_mult * get_physics_process_delta_time() if GameState.pace else 0.35)
		var np := pp + d.normalized() * step
		np.y = _gy(np.x, np.z) + 0.05
		player.global_position = np
		if not player.frozen:
			player.velocity = Vector3.ZERO
		player.face(np + d.normalized() * 6.0 + Vector3(0, 1.5, 0))
	printerr("AUTOTEST: bot %s noktasına varamadı (konum %s)" % [target, player.global_position])


func _wait_until(f: Callable, limit := 60.0) -> void:
	var t := 0.0
	while not bool(f.call()) and t < limit:
		await get_tree().process_frame
		t += get_process_delta_time()


func _auto() -> void:
	var v := GameState.autotest_variant
	await _bot_to(Vector3(0.0, 0.0, 9.0))
	await _wait_until(func() -> bool: return phase in ["out", "field"] and not _busy)
	await _bot_to(Vector3(0.0, 0.0, 42.0))
	if v == "warn":
		_set_towel(false)
		await _wait_until(func() -> bool: return _warnings >= 1, 20.0)
		_set_towel(true)
	# Zikzak: siper sıralarının açıklıklarından
	for i in PATH.size():
		await _bot_to(PATH[i])
		if v == "warn" and i == 0:
			_bot_running = true
			await _wait_until(func() -> bool: return _warnings >= 2, 20.0)
			_bot_running = false
			await get_tree().create_timer(1.6, false).timeout        # okun saplandığı yerde durur (gerçek oyuncu gibi): ok bakışta saplanır, karesi alınır
	await _bot_to(Vector3(0.0, 0.0, 105.0))
	await _wait_until(func() -> bool: return phase in ["lines", "done"] and not _busy)
	await _bot_to(Vector3(0.6, 0.0, 139.0))


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"warn": "8Y.2", "dep": "8Y.3"}.get(v, "8Y.1")
	var ok: bool = _outcome == expected and str(GameState.chapter_outcomes.get(NO, "")) == _outcome
	match v:
		"":
			ok = ok and _id == "seal" and _warnings == 0 and _radio_done
		"warn":
			ok = ok and _warnings == 2 and _lowered == 2 and _id == "item"
		"dep":
			ok = ok and _id == "honest" and not _letter
		"opened":
			ok = ok and _id == "seal"
		"honest":
			ok = ok and _id == "honest"
		"hikmet":
			ok = ok and not _radio_done
		"sinerji":
			ok = ok and is_instance_valid(sinerji) and sinerji.global_position.distance_to(player.global_position) < 3.0
	# Havlu bırakıldı (sırık elde kalmadı), bayrak yazıldı
	if is_instance_valid(_pole) or not GameState.flags.get("ch8y_done", false):
		ok = false
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (kimlik %s, uyarı %d, indirme %d, telsiz %s)" % [expected, _outcome, _id,
			_warnings, _lowered, str(_radio_done)])
	print("AUTOTEST %s chapter=8y variant=%s outcome=%s id=%s warnings=%d lowered=%d radio=%s" % [
		"PASS" if ok else "FAIL", v, _outcome, _id, _warnings, _lowered, str(_radio_done)])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

## Denetim karesi (yalnız --dialogshots ile ve ekranlıyken): oynanış sürerken, olayın anında (verme, ok, yorum).
## Dosya: <dialogshots>/c_<ad>.jpg. Oynanışı durdurmaz, sahneyi kurmaz.
func _cshot(name: String, delay := 0.0) -> void:
	if GameState.dialog_shots_dir == "" or DisplayServer.get_name() == "headless":
		return
	if delay > 0.0:
		await get_tree().create_timer(delay, true, false, true).timeout
	await RenderingServer.frame_post_draw
	if not is_inside_tree():
		return
	DirAccess.make_dir_recursive_absolute(GameState.dialog_shots_dir)
	get_viewport().get_texture().get_image().save_jpg(GameState.dialog_shots_dir.path_join("c_%s.jpg" % name), 0.85)


func _shot(file_name: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file_name))
	print("shot: ", file_name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	phase = "shots"
	await get_tree().create_timer(1.5, false).timeout
	_hold_towel()
	player.global_position = START + Vector3(0, 0.05, 0)
	player.face(NIKO_AT + Vector3(0, 1.5, 0))
	niko.talking = true
	hud.bark("SPK_NIKO", "D8Y_NIKO_1", 30.0)
	await get_tree().create_timer(0.4, false).timeout
	await _shot("c8y_01_niko.png")
	niko.talking = false
	player.global_position = Vector3(0, 0.05, 30.0)
	player.face(Vector3(0, 1.6, 60.0))
	await get_tree().create_timer(0.6, false).timeout
	await _shot("c8y_02_field.png")
	player.global_position = Vector3(0, 0.05, 106.0)
	player.face(hasan.global_position + Vector3(0, 1.5, 0))
	hasan.talking = true
	hud.bark("SPK_HASAN", "D8Y_HASAN_1", 30.0)
	await get_tree().create_timer(0.4, false).timeout
	await _shot("c8y_03_trench.png")
	get_tree().quit()
