extends Node3D
## Bölüm 22 (Osmanlı tarafı) — Kule (Tolga · 17–19 Mayıs 1453, hendeğin önü).
##
## Barbaro'nun anlattığı "bir gecede kurulan kule"nin öbür yüzü. Tolga yeniçeri Hasan'ın yanında gece çalışır:
##   hendeğe üç sepet toprak taşı (taşı → hendek kıyısında bırak), kulenin önüne üç ıslak deri çak (E basılı),
##   derileri kova ile ıslat. Arada surdan ok yağar: "Siper!" denince bir siperin ya da kulenin dibine geç.
##   Şafakta tespit: kurulan kule. Ertesi gece Bizanslılar barut fıçılarını yuvarlar; kule yanar.
##   Tolga merdivenin dibinde üst kattaki üç marangozu aşağı indirir (E basılı), alevler büyümeden.
##   22O.1 Herkes indi · 22O.2 Sonuncuyu Hasan sırtında indirdi
##   --autotest[=late]   (varsayılan: 22O.1)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const TOWER := Vector3(-3.0, 0.0, 40.0)
const PILE := Vector3(9.0, 0.0, 56.0)
const DROP := Vector3(-3.0, 0.0, 37.2)
const WATER := Vector3(-11.0, 0.0, 52.0)
const HIDE_TIME := 1.6
const VOLLEY_EVERY := 22.0
const VOLLEY_WARN := 3.0
const RESCUE_TIME := 1.5
const FIRE_TIME := 26.0
const COVERS := [Vector3(-9.0, 0.0, 44.0), Vector3(4.0, 0.0, 45.0), Vector3(9.0, 0.0, 56.0), Vector3(-11.0, 0.0, 52.0)]

var walls: LandWalls
## Kule dibindeki çıkış düellosu kazanıldı mı (yenilgi: bir marangoz kulede kalır, 22O.2)
var _duel_won := true
var gun_shots := 0
var gun_hits := 0
var player: Player
var hud: Hud
var hasan: Person
var carpenters: Array[Person] = []
var tower: Node3D
var _hides: Array[Node3D] = []
var _levels: Array[Node3D] = []
var _fill: MeshInstance3D
var _fire: Array[Node3D] = []
var _fire_light: OmniLight3D
var _carry: Node3D
var carrying := ""
var phase := "intro"
var _outcome := ""
var baskets := 0
var hides := 0
var wet := false
var arrows := 0
var saved := 0
var _hold := 0.0
var _hold_id := ""
var _volley := VOLLEY_EVERY
var _warn := -1.0
var _fire_t := 0.0
var _photo := ""
var cam: TespitCam
var _t := 0.0


func _ready() -> void:
	GameState.snapshot(22)
	hud = Hud.new()
	add_child(hud)
	hud.chase_music = "tension"
	player = Player.new()
	add_child(player)
	player.frozen = true
	player.focus_changed.connect(_on_focus)
	player.interacted.connect(_on_interact)
	hud.set_fez(GameState.flags.get("fez", true))
	hud.set_signal(0)
	walls = LandWalls.new()
	add_child(walls)
	walls.set_repair(LandWalls.STAGES)
	_build()
	if GameState.autotest:
		Engine.time_scale = 3.0
	if GameState.shots_dir != "":
		_run_shots()
	else:
		_run()


func _build() -> void:
	# Ordugâhın önü: yürünebilir zemin (LandWalls'ın ovası yalnız görüntüdür) ve alanın sınırları
	Props.solid(self, Vector3(64, 0.4, 42), Vector3(0, -0.2, 57.0), Color("3a3e2a")).get_child(0).visible = false
	for spec in [[Vector3(64, 6, 0.4), Vector3(0, 3, 36.4)], [Vector3(64, 6, 0.4), Vector3(0, 3, 78.0)],
			[Vector3(0.4, 6, 42), Vector3(-32, 3, 57.0)], [Vector3(0.4, 6, 42), Vector3(32, 3, 57.0)]]:
		var b := Props.solid(self, spec[0], spec[1], Color.WHITE)
		b.get_child(0).visible = false
		b.set_meta("no_climb", true)
	# Hendeğin kule önü: sepetlerle dolan toprak (üç aşamada yükselir)
	_fill = Props.box(self, Vector3(8.0, 1.0, 16.0), Vector3(TOWER.x, -3.0, 28.0), Color("5a4630"))
	_build_tower()
	# Hendekte (kulenin önündeki dolgu dışında) hasır kalkanlı azaplar, yeniçeri ve sipahiler; devrilenler, yatanlar
	for lane: Array in [[Vector3(-26.0, 0, 27.5), Vector3(-9.0, 0, 27.5), 4.0, 5, 4], [Vector3(3.5, 0, 27.5), Vector3(26.0, 0, 27.5), 4.0, 5, 4],
			[Vector3(-24.0, 0, 17.9), Vector3(24.0, 0, 17.9), 0.6, 0, 5]]:
		var bx := BattleExtras.new()
		bx.side = "osm"
		add_child(bx)
		bx.hit_every = 3.0
		bx.populate(lane[0], lane[1], lane[2], lane[3], lane[4], 0, 2200 + int(lane[0].x))
	# Toprak sepetleri yığını
	for i in 7:
		_basket(self, PILE + Vector3((i % 3) * 0.8 - 0.8, (i / 3) * 0.55, (i / 3) * 0.2))
	Props.interactable(self, "pile", Vector3(2.8, 1.6, 2.0), PILE + Vector3(0, 0.8, 0))
	# Sepet yığını ve su fıçısı katı (içlerinden yürünüyordu)
	for spec: Array in [[Vector3(2.5, 1.2, 1.3), PILE + Vector3(0, 0.6, 0.2)], [Vector3(1.1, 1.1, 1.1), WATER + Vector3(0, 0.55, 0)]]:
		var sb := Props.solid(self, spec[0], spec[1], Color.WHITE)
		sb.get_child(0).visible = false
		sb.set_meta("no_climb", true)
	# Su fıçısı ve kovalar
	Props.cyl(self, 0.55, 1.1, WATER + Vector3(0, 0.55, 0), Color("6a4a2c"), Vector3.ZERO, 10)
	Props.cyl(self, 0.5, 0.05, WATER + Vector3(0, 1.1, 0), Color("3a5a78"), Vector3.ZERO, 10)
	Props.interactable(self, "water", Vector3(1.6, 1.6, 1.6), WATER + Vector3(0, 0.8, 0))
	Props.interactable(self, "drop", Vector3(6.0, 2.0, 1.4), DROP + Vector3(0, 1.0, 0))
	# Hasır siperler (ok yağınca arkasına geçilir)
	for c: Vector3 in COVERS.slice(0, 2):
		for i in 5:
			Props.cyl(self, 0.05, 2.2, c + Vector3(i * 0.45 - 0.9, 1.1, -0.6), Color("8a6a40"), Vector3.ZERO, 4)
		Props.solid(self, Vector3(2.2, 1.8, 0.12), c + Vector3(0, 1.1, -0.6), Color("a08050"))     # içinden geçilmez
	# Ordugâhın ön kenarı: meşaleler, çadırlar
	for x: float in [-14.0, -6.0, 6.0, 14.0]:
		walls.lights.append(Night.torch(self, Vector3(x, 0, 48.0)))
	for i in 5:
		Night.tent(self, Vector3(-16.0 + i * 8.0, 0, 66.0 + (i % 2) * 3.0), 2.2)
	# Alanın kenarları: iki yanda sepet siper sırası, arkada siper ve çadırlar; ateş başında oturan askerler
	for sx: float in [-32.7, 32.7]:
		SiegeField.gabion_line(self, Vector3(sx, 0, 38.0), Vector3(sx, 0, 77.5), 1.3, 2201 + int(sx))
	SiegeField.gabion_line(self, Vector3(-32.0, 0, 78.7), Vector3(32.0, 0, 78.7), 1.3, 2203)
	for i in 6:
		var t := Night.tent(self, Vector3(-27.0 + i * 10.5, 0, 84.0 + (i % 2) * 4.0), 2.4, Color("d8cbb0"), [Color("8a2b22"), Color("2f5fa8"), Color("3a6b3a")][i % 3])
		t.rotation.y = i * 1.3
	var rng := RandomNumberGenerator.new()
	rng.seed = 2204
	for fp: Vector3 in [Vector3(-22.0, 0, 72.0), Vector3(22.0, 0, 70.0)]:
		walls.lights.append(Night.campfire(self, fp, 0.9))
		for k in 4:
			var a := TAU * k / 4.0 + rng.randf_range(-0.3, 0.3)
			var sp := Person.new({"coat": [Color("b3262d"), Color("6a4a3a"), Color("2f5fa8"), Color("3a6b3a")][k], "pants": Color("e8e0d0"),
				"hat": "bork" if k % 2 == 0 else "turban", "mustache": true, "beard": k == 1, "skin": Color("d9a07a")})
			sp.set_meta("no_talk", true)
			sp.position = fp + Vector3(cos(a), 0, sin(a)) * 1.5
			sp.rotation.y = atan2(-cos(a), -sin(a))
			add_child(sp)
			sp.set_activity("sit_ground")
	# Karşıda surlar: Bizans nöbetçileri (uzak). Önde pavezlerin ardında okçular (sura bakar); iki yanda bekleyen
	# bölükler (azaplar solda, yeniçeriler sağda) sancaklarıyla. Bölüklerin içinden geçilmesin: görünmez sınır.
	Garrison.land_walls(self, [], [], [], 2210)
	for i in 8:
		var x: float = [-28.0, -25.5, -23.0, -20.5, 17.5, 20.0, 22.5, 25.0][i]
		var z := 39.4 + (i % 2) * 0.3
		var pv := Props.solid(self, Vector3(1.1, 1.5, 0.12), Vector3(x, 0.75, z - 0.9), Color("8a6a40"), Vector3(-8, 0, 0))
		Props.set_pattern(pv, Color("8a6a40"), "wood")
		Props.cyl(self, 0.03, 1.1, Vector3(x, 0.5, z - 0.4), Color("5a3e26"), Vector3(40, 0, 0), 4)
		var ar := Soldier.new([Color("b3262d"), Color("6a4a3a"), Color("3a6b3a"), Color("8a6a4a")][i % 4], "stand", "bork" if i % 2 == 0 else "turban")
		ar.position = Vector3(x + 0.2, 0, z)
		ar.rotation.y = PI
		add_child(ar)
		ar.equip("bow")
	for spec in [[Vector3(-25.0, 0, 58.0), Color("8a6a4a"), 7, 3], [Vector3(24.0, 0, 58.5), Color("2f5fa8"), 6, 3]]:
		var c: Vector3 = spec[0]
		var men: Array = []
		for i in int(spec[2]):
			for j in int(spec[3]):
				men.append(Transform3D(Basis(Vector3.UP, PI + rng.randf_range(-0.1, 0.1)),
					c + Vector3((i - (int(spec[2]) - 1) * 0.5) * 1.3 + rng.randf_range(-0.1, 0.1), 0, j * 1.4 + rng.randf_range(-0.1, 0.1))))
		Horn.figures(self, men.map(func(t): return [t, spec[1]]))
		var w := int(spec[2]) * 1.3 + 0.8
		var blk := Props.solid(self, Vector3(w, 2.0, int(spec[3]) * 1.4 + 0.6), c + Vector3(0, 1.0, (int(spec[3]) - 1) * 0.7), Color.WHITE)
		blk.get_child(0).visible = false
		blk.set_meta("no_climb", true)
		var fp := c + Vector3(w * 0.5 + 0.4, 0, 0)
		Props.cyl(self, 0.05, 5.0, fp + Vector3(0, 2.5, 0), Color("4a3420"), Vector3.ZERO, 5)
		Props.ball(self, 0.12, fp + Vector3(0, 5.1, 0), Color("d8b040"), Vector3.ONE, 8)
		Props.box(self, Vector3(0.03, 1.3, 1.9), fp + Vector3(0, 4.2, 0.95), Color("b3262d") if spec[1] == Color("2f5fa8") else Color("2e6a3a"))
	Scenery.ground_detail(self, Rect2(-32.0, 36.5, 64.0, 41.0), 380, func(_x: float, _z: float) -> float: return 0.0, Color("3a4a2a"), 2205)
	hasan = Person.new({"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")})
	hasan.set_meta("spk", "SPK_HASAN")
	hasan.position = TOWER + Vector3(3.6, 0, 3.0)
	hasan.rotation.y = PI * 0.8
	add_child(hasan)
	hasan.look_target = player
	for i in 3:
		var p := Person.new({"coat": [Color("7a6a58"), Color("8a5a3a"), Color("5a6a48")][i], "pants": Color("3a3028"), "hat": "turban",
			"mustache": true, "apron": Color("6a5a40"), "skin": Color("d9a07a")})
		p.set_meta("no_talk", true)
		p.position = TOWER + Vector3(-1.2 + i * 1.2, 0, 3.2)     # kulenin tabanının dışında (içine gömülmeden)
		p.rotation.y = PI
		add_child(p)
		p.set_activity("chop")
		carpenters.append(p)


func _basket(parent: Node3D, pos: Vector3) -> void:
	Props.cyl(parent, 0.3, 0.5, pos + Vector3(0, 0.25, 0), Color("a08050"), Vector3.ZERO, 8, 0.36)
	Props.cyl(parent, 0.33, 0.06, pos + Vector3(0, 0.49, 0), Color("5a4630"), Vector3.ZERO, 8)


## Kuşatma kulesi: bölüm 22'deki kulenin aynısı; katlar gece boyunca birer birer görünür, deriler sonradan çakılır.
func _build_tower() -> void:
	tower = Node3D.new()
	tower.position = TOWER
	add_child(tower)
	var wood := Color("4a3220")
	for sx: float in [-2.2, 2.2]:
		for sz: float in [-2.2, 2.2]:
			Props.cyl(tower, 0.2, 14.0, Vector3(sx, 7.0, sz), wood, Vector3.ZERO, 6)
	for sx: float in [-1.9, 1.9]:
		for sz: float in [-1.9, 1.9]:
			Props.cyl(tower, 0.6, 0.3, Vector3(sx, 0.6, sz), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	for li in 4:
		var lv := Node3D.new()
		tower.add_child(lv)
		var y: float = [0.8, 5.0, 9.2, 13.4][li]
		Props.solid(lv, Vector3(4.8, 0.3, 4.8), Vector3(0, y, 0), wood.darkened(0.1)).set_meta("no_climb", true)
		if li < 3:
			for d: float in [-35.0, 35.0]:
				Props.box(lv, Vector3(0.18, 5.2, 0.14), Vector3(0, y + 2.2, -2.5), wood.lightened(0.1), Vector3(0, 0, d))
		_levels.append(lv)
	# Merdiven (arka yüz, ordugâh tarafı)
	var ld := Ladder.new(9.3, 6.0)
	ld.position = Vector3(0, 0, 2.5 + 9.3 * sin(deg_to_rad(6.0)) - 0.1)
	tower.add_child(ld)
	Props.interactable(tower, "ladder", Vector3(1.6, 2.2, 1.2), Vector3(0, 1.1, 3.0))
	# Ön yüzün deri panelleri (surlara bakan yüz): başta yok, Tolga çakar
	for i in 3:
		var h := SiegeField.hide_panel(tower, Vector3(0, 3.0 + i * 4.2, -2.35), 4.7, 3.8, false, 221 + i)
		h.visible = false
		_hides.append(h)
	Props.interactable(tower, "hides", Vector3(4.6, 2.4, 1.2), Vector3(0, 1.2, -2.9))
	Props.solid(tower, Vector3(4.8, 1.6, 4.8), Vector3(0, 0.8, 0), Color("4a3220")).get_child(0).visible = false
	Props.box(tower, Vector3(0.05, 1.2, 1.8), Vector3(0.6, 15.6, 0), Color("b3262d"))
	Props.cyl(tower, 0.04, 2.6, Vector3(0.6, 15.0, -0.9), wood, Vector3.ZERO, 4)
	_fire_light = OmniLight3D.new()
	_fire_light.position = Vector3(0, 4.0, -2.8)
	_fire_light.light_color = Color("ff8a3a")
	_fire_light.light_energy = 0.0
	_fire_light.omni_range = 40.0
	tower.add_child(_fire_light)


func _show_levels(n: int) -> void:
	for i in _levels.size():
		_levels[i].visible = i < n


func _burn(level: int) -> void:
	for i in 4 * level:
		var f := Props.cyl(tower, randf_range(0.4, 0.9), randf_range(1.2, 2.6), Vector3(randf_range(-2.2, 2.2), randf_range(0.8, 5.0 + level * 3.0), randf_range(-2.4, -1.6)), Color("ffa030"), Vector3.ZERO, 6, 0.05, 3.0)
		f.material_override = Props.mat(Color("ff9a30"), 3.5, false, "", false)
		_fire.append(f)
	_fire_light.light_energy = 3.0 + level * 3.0


func _make_night() -> void:
	var e := walls.env.environment
	var sm := e.sky.sky_material as ProceduralSkyMaterial
	sm.sky_top_color = Color("0b1330")
	sm.sky_horizon_color = Color("2a3560")
	sm.ground_horizon_color = Color("1c2238")
	e.ambient_light_color = Color("6a7ab8")
	e.ambient_light_energy = 0.5
	e.fog_light_color = Color("1a2240")
	e.fog_density = 0.006
	walls.moon.light_color = Color("9fb4ff")
	walls.moon.light_energy = 0.6
	walls.moon.rotation_degrees = Vector3(-34, -20, 0)
	if walls.field:
		walls.field.set_mode("night")


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH22O_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH22O_SUB"), 20, Color(1, 1, 1, 0.7)]], 2.8)
	hud.clear_card()
	_make_night()
	_show_levels(1)
	player.global_position = TOWER + Vector3(4.0, 0.05, 6.0)
	player.face(hasan.global_position + Vector3(0, 1.5, 0))
	player.show_remote(false)
	_capture_mouse()
	await hud.fade_to(0.0, 1.0)
	await hud.say("SPK_NIHAT", "D22O_N_01")
	await hud.say("SPK_HASAN", "D22O_H_01")
	await hud.say("SPK_TOLGA", "D22O_T_01")
	await hud.say("SPK_HASAN", "D22O_H_02")
	player.frozen = false
	phase = "build"
	Lore.scatter(self, "22o")
	_update_objective()
	if GameState.autotest:
		_auto_build()
	while phase == "build":
		await get_tree().process_frame
	await _dawn()
	await _fire_night()
	await _end_chapter()


func _update_objective() -> void:
	if phase != "build":
		return
	if carrying == "basket":
		hud.set_objective(tr("UI_OBJ22O_DROP") % [baskets, 3], DROP + Vector3(0, 1.0, 0))
	elif carrying == "bucket":
		hud.set_objective(tr("UI_OBJ22O_WET"), TOWER + Vector3(0, 1.5, -2.9))
	elif baskets < 3:
		hud.set_objective(tr("UI_OBJ22O_BASKET") % [baskets, 3], PILE + Vector3(0, 1.2, 0))
	elif hides < 3:
		hud.set_objective(tr("UI_OBJ22O_HIDE") % [hides, 3], TOWER + Vector3(0, 1.5, -2.9))
	elif not wet:
		hud.set_objective(tr("UI_OBJ22O_WATER"), WATER + Vector3(0, 1.2, 0))


func _check_done() -> void:
	if baskets >= 3 and hides >= 3 and wet:
		phase = "built"
		hud.set_objective("")


func _auto_build() -> void:
	while phase == "build":
		await get_tree().create_timer(0.15).timeout
		if carrying == "basket":
			_on_interact("drop")
		elif carrying == "bucket":
			_wet()
		elif baskets < 3:
			_on_interact("pile")
		elif hides < 3:
			_hide_done()
		else:
			_on_interact("water")


func _take(kind: String) -> void:
	carrying = kind
	_carry = Node3D.new()
	_carry.position = Vector3(0, -0.55, -0.8)
	player.camera.add_child(_carry)
	if kind == "basket":
		_basket(_carry, Vector3(0, -0.25, 0))
	else:
		Props.cyl(_carry, 0.18, 0.3, Vector3(0, 0, 0), Color("6a4a2c"), Vector3.ZERO, 8, 0.2)
		Props.cyl(_carry, 0.17, 0.02, Vector3(0, 0.14, 0), Color("3a5a78"), Vector3.ZERO, 8)
	Props.strip_outlines(_carry)
	player.speed_mult = 0.75
	Audio.sfx("land_pot", -10.0, 0.8)
	_update_objective()


func _drop_carry() -> void:
	carrying = ""
	if _carry:
		_carry.queue_free()
		_carry = null
	player.speed_mult = 1.0


func _hide_done() -> void:
	_hides[hides].visible = true
	hides += 1
	_show_levels(mini(4, 1 + hides))
	Audio.sfx("kick_metal", -10.0, 1.4)
	if hides < 3:
		hud.bark("SPK_HASAN", "D22O_H_HIDE_%d" % hides, 2.5)
	_update_objective()
	_check_done()


func _wet() -> void:
	_drop_carry()
	wet = true
	for i in 4:
		Vfx.steam(self, TOWER + Vector3(randf_range(-2.0, 2.0), randf_range(1.5, 9.0), -2.6))
	Audio.sfx("splash", -8.0)
	hud.bark("SPK_HASAN", "D22O_H_WET", 3.0)
	_update_objective()
	_check_done()


## Ok yağmuru: uyarıdan sonra siperin (ya da kulenin dibinin) 3 m yakınında olmayan Tolga'nın fesine ok saplanır.
func _covered() -> bool:
	var p := player.global_position
	if p.distance_to(TOWER + Vector3(0, 0, 2.0)) < 4.0:
		return true
	for c: Vector3 in COVERS:
		if Vector2(p.x - c.x, p.z - c.z).length() < 3.0:
			return true
	return false


func _volley_tick(delta: float) -> void:
	if GameState.autotest:
		return
	if _warn >= 0.0:
		_warn += delta
		if _warn >= VOLLEY_WARN:
			_warn = -1.0
			_volley = VOLLEY_EVERY
			Audio.sfx("whoosh_fly", -4.0)
			for i in 10:
				var a := Props.cyl(self, 0.015, 0.8, Vector3(randf_range(-14, 12), 0.35, randf_range(38, 58)), Color("5a4a30"), Vector3(randf_range(-30, 30), 0, randf_range(-30, 30)), 4)
				get_tree().create_timer(12.0).timeout.connect(a.queue_free)
			if not _covered():
				arrows += 1
				player.hurt(30.0, Vector3(player.global_position.x, 8.0, player.global_position.z - 20.0))
				hud.bark("SPK_TOLGA", "D22O_T_ARROW_%d" % mini(arrows, 3), 3.0)
			else:
				hud.bark("SPK_HASAN", "D22O_H_SAFE", 2.0)
		return
	_volley -= delta
	if _volley <= 0.0:
		_warn = 0.0
		hud.bark("SPK_HASAN", "D22O_H_VOLLEY", VOLLEY_WARN)


func _dawn() -> void:
	player.frozen = true
	hud.set_prompt("")
	for p in carpenters:
		p.set_activity("")
	await hud.say("SPK_HASAN", "D22O_H_DONE")
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH22O_DAWN"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	walls.make_dawn(0.01)
	_show_levels(4)
	_fill.position.y = -1.4
	_fill.scale.y = 3.2
	player.global_position = TOWER + Vector3(7.0, 0.05, 14.0)
	player.face(TOWER + Vector3(0, 7.0, 0))
	await hud.fade_to(0.0, 0.8)
	await hud.say("SPK_TOLGA", "D22O_T_DAWN")
	var target := Node3D.new()
	tower.add_child(target)
	target.position = Vector3(0, 7.0, 0)
	player.frozen = false
	hud.set_objective(tr("UI_OBJ22O_PHOTO"), target.global_position)
	cam = TespitCam.new(player, hud, target, "siege22o")
	hud.add_child(cam)
	cam.max_dist = 60.0
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
	await hud.say("SPK_HASAN", "D22O_H_WALL")
	await _tower_gun()


## Kule bunun için kuruldu: tepesinden surun yürüyüş yoluna bakılır. Tolga en üst kattan mazgaldakilere ateş eder;
## susturulamayanlar gece kulenin dibine çıkışa katılır (çıkış düellosu +1).
func _tower_gun() -> void:
	await hud.say("SPK_HASAN", "D22O_H_GUN")
	await hud.fade_to(1.0, 0.4)
	var top := TOWER + Vector3(0, 13.55, -1.2)
	var rails: Array = []
	# En üst katın korkuluğu yok: atış sırasında görünmez kenar (13 m'den düşülmesin)
	for r: Array in [[Vector3(4.8, 1.2, 0.1), Vector3(0, 14.2, -2.45)], [Vector3(4.8, 1.2, 0.1), Vector3(0, 14.2, 2.45)],
			[Vector3(0.1, 1.2, 4.8), Vector3(-2.45, 14.2, 0)], [Vector3(0.1, 1.2, 4.8), Vector3(2.45, 14.2, 0)]]:
		var w := Props.solid(tower, r[0], r[1], Color.WHITE)
		w.get_child(0).visible = false
		rails.append(w)
	player.global_position = top
	var y := LandWalls.OUTER_H
	player.face(Vector3(TOWER.x, y + 1.2, LandWalls.OUTER_Z0 + 1.2))
	await hud.fade_to(0.0, 0.4)
	var peek: Array = []
	var xs := [-9.0, -5.5, -0.5, 3.5]
	for i in 4:
		peek.append({"coat": [Color("7a2a24"), Color("8a8e96"), Color("5a6a7a"), Color("6a5a3a")][i], "hat": "helm",
			"pos": Vector3(TOWER.x + xs[i], y, LandWalls.OUTER_Z1 - 0.75), "face": top, "phase": i * 0.9})
	var res: Dictionary = await GunRange.run(self, hud, player, {"peek": peek, "limit": 28.0,
		"objective": tr("UI_OBJ20O_GUN") % 4, "look": Vector3(TOWER.x, y + 1.2, LandWalls.OUTER_Z1)})
	gun_shots = res["shots"]
	gun_hits = res["hits"]
	GameState.bump_stat("osm_tower_gun", gun_hits, true)
	player.frozen = true
	await hud.say("SPK_TOLGA", "D20_T_GUN_GOOD" if gun_hits >= 2 else "D26O_T_GUN_BAD")
	await hud.fade_to(1.0, 0.4)
	for w in rails:
		w.queue_free()
	player.global_position = TOWER + Vector3(7.0, 0.05, 14.0)
	await hud.fade_to(0.0, 0.4)


## Ertesi gece: Bizanslıların fıçıları kuleyi tutuşturur. Üst kattaki üç marangoz merdivenden indirilir.
func _sortie_duel() -> void:
	var p := player.global_position
	var to := TOWER - p
	to.y = 0.0
	to = to.normalized() if to.length() > 0.1 else Vector3(0, 0, -1)
	var side := to.cross(Vector3.UP).normalized()
	var specs := []
	var n := 3 if gun_hits < 2 else 2          # kuleden susturulamayanlar çıkışa katılır
	for k in n:
		specs.append({"pos": p + to * (3.8 + (k / 2) * 1.6) + side * (-1.0 + (k % 2) * 2.0), "blade": "spathion", "shield": k == 1,
			"name": "SPK_DEFENDER", "look": {"coat": [Color("7a2a24"), Color("5a6a7a"), Color("6a5a3a")][k], "pants": Color("3a2a22"),
			"hat": "helm", "mustache": true, "beard": k == 1}})
	await hud.say("SPK_HASAN", "D22O_H_DUEL")
	player.frozen = false
	var r: Dictionary = await StoryDuel.fight(self, hud, player, specs, "kilij", 0.4)
	_duel_won = r["won"]
	player.frozen = true
	await hud.say("SPK_TOLGA", "D22O_T_DUEL" if _duel_won else "D22O_T_LOST")
	player.face(TOWER + Vector3(0, 4.0, 0))


func _fire_night() -> void:
	await hud.fade_to(1.0, 0.8)
	await hud.card([[tr("UI_CH22O_NIGHT2"), 26, Color("f2e6c9")]], 1.8)
	hud.clear_card()
	_make_night()
	for i in 3:
		var p := carpenters[i]
		p.set_activity("")
		p.position = TOWER + Vector3(-1.2 + i * 1.2, 9.35, 0.4)
		p.rotation.y = PI
	player.global_position = TOWER + Vector3(1.5, 0.05, 8.0)
	player.face(TOWER + Vector3(0, 4.0, 0))
	await hud.fade_to(0.0, 0.8)
	# Fıçılar surdan yuvarlanır
	for i in 2:
		var b := Node3D.new()
		add_child(b)
		Props.cyl(b, 0.32, 0.8, Vector3(0, 0.4, 0), Color("2e2a26"), Vector3(0, 0, 90), 10)
		b.global_position = Vector3(TOWER.x + randf_range(-1.0, 1.0), LandWalls.OUTER_H, LandWalls.OUTER_Z1 + 0.5)
		var tw := create_tween()
		tw.tween_property(b, "global_position", Vector3(TOWER.x, 0.5, 30.0), 1.0).set_ease(Tween.EASE_IN)
		tw.tween_property(b, "global_position", TOWER + Vector3(randf_range(-0.8, 0.8), 0.4, -2.9), 0.8)
		await tw.finished
		Vfx.explosion(self, b.global_position + Vector3(0, 0.5, 0), 1.3)
		Audio.sfx("explosion_big", -2.0)
		player.shake(0.5)
		b.queue_free()
		_burn(i + 1)
		await get_tree().create_timer(0.4).timeout
	# Savunucular fıçıların ardından küçük bir çıkış yapar: kulenin dibinde göğüs göğüse (StoryDuel)
	await _sortie_duel()
	await hud.say("SPK_HASAN", "D22O_H_FIRE")
	await hud.say("SPK_TOLGA", "D22O_T_FIRE")
	phase = "rescue"
	_fire_t = FIRE_TIME
	player.frozen = false
	hud.set_objective(tr("UI_OBJ22O_RESCUE") % [saved, 3], TOWER + Vector3(0, 1.5, 3.0))
	if GameState.autotest:
		_auto_rescue()
	while phase == "rescue" and _fire_t > 0.0 and saved < 3:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		_fire_t -= dt
		hud.set_chase(tr("UI_CH22O_FIRE") % maxi(0, int(ceil(_fire_t))), 1.0 - _fire_t / FIRE_TIME)
		if int(_fire_t * 2.0) % 9 == 0 and fmod(_fire_t, 0.5) < dt:
			_burn(1)
	phase = "after"
	hud.set_chase("", 0.0)
	hud.set_prompt("")
	hud.set_objective("")
	player.frozen = true
	# Kulenin çöküşü görünsün: oyuncu kulenin önünde, açık bir yerde, kuleye bakar
	player.global_position = TOWER + Vector3(3.0, 0.05, 10.0)
	player.face(TOWER + Vector3(0, 5.0, 0))
	# Düello kaybedildiyse marangozlardan biri kulede kalır (Tolga yerdeyken merdiven yanmaya başladı)
	if not _duel_won:
		saved = mini(saved, 2)
	if saved < 3:
		# Hasan kalan son adamı sırtında indirir
		Audio.sfx("crowd_gasp", -4.0, 0.9)
		for i in range(saved, 3):
			carpenters[i].global_position = TOWER + Vector3(1.8 + i * 0.6, 0, 4.2)
		hasan.global_position = TOWER + Vector3(0.4, 0, 5.4)      # inenlerin yolunun ve kalanların önünde
		await hud.say("SPK_HASAN", "D22O_H_CARRY")
	else:
		await hud.say("SPK_HASAN", "D22O_H_ALL")
	# Kule çöker
	Audio.sfx("land_thud", 0.0, 0.5)
	Vfx.dust(self, TOWER + Vector3(0, 2.0, 0), 2.0)
	var tw2 := create_tween()
	tw2.tween_property(tower, "rotation_degrees:x", -18.0, 1.6).set_ease(Tween.EASE_IN)
	await tw2.finished
	await hud.say("SPK_TOLGA", "D22O_T_END")
	await hud.say("SPK_NIHAT", "D22O_N_END")
	_outcome = "22O.1" if saved >= 3 else "22O.2"
	Siege.record(22, _photo, "SIEGE_NOTE_22O_%s" % _outcome.split(".")[1])


func _auto_rescue() -> void:
	player.global_position = TOWER + Vector3(0, 0.05, 3.4)
	var late := GameState.autotest_variant == "late"
	while phase == "rescue" and saved < 3:
		await get_tree().create_timer(0.4).timeout
		if late and saved == 2:
			_fire_t = 0.0
			return
		_rescue_done()


func _rescue_done() -> void:
	var p := carpenters[saved]
	# Arka yüzdeki merdivenden iner (katların içinden çapraz kayarak değil), sonra kuleden uzaklaşır
	var tw := create_tween()
	tw.tween_property(p, "global_position", TOWER + Vector3(0, 9.35, 2.6), 0.35)
	tw.tween_property(p, "global_position", TOWER + Vector3(0, 0, 3.3), 1.1)
	tw.tween_property(p, "global_position", TOWER + Vector3(2.4 + saved * 0.8, 0, 6.0), 0.8)
	saved += 1
	if saved < 3:
		hud.bark("SPK_TOLGA", "D22O_T_RESCUE_%d" % saved, 2.0)
	hud.set_objective(tr("UI_OBJ22O_RESCUE") % [saved, 3], TOWER + Vector3(0, 1.5, 3.0))


func _process(delta: float) -> void:
	_t += delta
	for i in _fire.size():
		_fire[i].scale.y = 1.0 + sin(_t * 9.0 + i) * 0.25
	if _fire_light and _fire_light.light_energy > 0.0:
		_fire_light.light_energy = maxf(1.0, _fire_light.light_energy + sin(_t * 17.0) * 0.4)
	if phase == "build":
		_volley_tick(delta)
	# E basılı işler: deri çakmak (kurulum), adam indirmek (yangın)
	var want := ""
	if phase == "build" and hides < 3 and carrying == "" and baskets >= 3 and player.focus_id == "hides":
		want = "hides"
	elif phase == "rescue" and player.focus_id == "ladder":
		want = "ladder"
	if want != "" and Input.is_action_pressed("interact"):
		if _hold_id != want:
			_hold = 0.0
			_hold_id = want
		_hold += delta
		var need := HIDE_TIME if want == "hides" else RESCUE_TIME
		hud.set_chase(tr("UI_CH22O_HAMMER") if want == "hides" else tr("UI_CH22O_HELP"), _hold / need)
		if want == "hides" and fmod(_hold, 0.4) < delta:
			Audio.sfx("land_thud", -14.0, 1.6)
		if _hold >= need:
			_hold = 0.0
			hud.set_chase("", 0.0)
			if want == "hides":
				_hide_done()
			else:
				_rescue_done()
	elif _hold > 0.0:
		_hold = 0.0
		if phase == "build":
			hud.set_chase("", 0.0)


func _on_focus(id: String) -> void:
	var k := ""
	match id:
		"pile":
			if phase == "build" and carrying == "" and baskets < 3:
				k = "UI_PROMPT22O_BASKET"
		"drop":
			if carrying == "basket":
				k = "UI_PROMPT22O_DROP"
		"water":
			if phase == "build" and carrying == "" and baskets >= 3 and hides >= 3 and not wet:
				k = "UI_PROMPT22O_WATER"
		"hides":
			if carrying == "bucket":
				k = "UI_PROMPT22O_WET"
			elif phase == "build" and carrying == "" and baskets >= 3 and hides < 3:
				k = "UI_PROMPT22O_HIDE"
		"ladder":
			if phase == "rescue":
				k = "UI_PROMPT22O_HELP"
	hud.set_prompt(tr(k) if k != "" else "")


func _on_interact(id: String) -> void:
	if phase != "build":
		return
	match id:
		"pile":
			if carrying == "" and baskets < 3:
				_take("basket")
		"drop":
			if carrying == "basket":
				_drop_carry()
				baskets += 1
				_fill.position.y = -3.0 + baskets * 0.5
				_fill.scale.y = 1.0 + baskets * 0.6
				Vfx.dust(self, DROP + Vector3(0, -1.0, -3.0), 0.8)
				Audio.sfx("land_thud", -6.0, 0.8)
				hud.bark("SPK_HASAN", "D22O_H_BASKET_%d" % baskets, 2.5)
				_update_objective()
				_check_done()
		"water":
			if carrying == "" and baskets >= 3 and hides >= 3 and not wet:
				_take("bucket")
		"hides":
			if carrying == "bucket":
				_wet()


# ================================================================ bölüm sonu

func _end_chapter() -> void:
	player.frozen = true
	GameState.set_outcome(22, _outcome)
	await Siege.show_page(hud, 22)
	await hud.fade_to(1.0, 0.8)
	var result := await hud.show_flowchart(_make_chart(), true)
	Engine.time_scale = 1.0
	if GameState.autotest:
		_autotest_report()
		return
	match result:
		"next":
			var nxt := Siege.next_path(22)
			GameState.change_scene(nxt if nxt != "" else Siege.return_path())
		"replay":
			get_tree().reload_current_scene()
		_:
			get_tree().quit()


func _make_chart() -> Flowchart:
	var c := Flowchart.new()
	c.title_text = tr("UI_FLOW22O_TITLE")
	c.nodes = [
		{"id": "build", "key": "FLOW22O_BUILD", "pos": Vector2(0.5, 0.12)},
		{"id": "fire", "key": "FLOW22O_FIRE", "pos": Vector2(0.5, 0.3)},
		{"id": "22O.1", "key": "FLOW_22O_1", "pos": Vector2(0.3, 0.52), "outcome": true},
		{"id": "22O.2", "key": "FLOW_22O_2", "pos": Vector2(0.7, 0.52), "outcome": true},
	]
	c.edges = [["build", "fire"], ["fire", "22O.1"], ["fire", "22O.2"]]
	for k in ["build", "fire", _outcome]:
		c.taken[k] = true
	for n in c.nodes:
		if n.get("outcome", false) and GameState.has_seen(n["id"]):
			c.seen[n["id"]] = true
	c.footer_lines = [
		tr("UI_CH22O_STATS") % [saved, arrows, Siege.page_count(), Siege.LAST - Siege.FIRST + 1],
		tr("UI_FLOW_LEGEND"),
		tr("UI_FLOW_CONTINUE"),
	]
	c.footer_lines.insert(0, Grade.finish("22o"))
	return c


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _autotest_report() -> void:
	var v := GameState.autotest_variant
	var expected: String = {"": "22O.1", "late": "22O.2", "lose": "22O.2"}.get(v, "22O.1")
	var page: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get("22", {})
	var ok: bool = _outcome == expected and not page.is_empty() and cam != null and cam.done and baskets == 3 and hides == 3 and wet and gun_shots >= 3 and gun_hits >= 1
	# Yenilgi testi: oyuncu düelloda yere düşmüş ve düello kaybedilmiş olmalı
	if v.ends_with("lose"):
		ok = ok and player.downs >= 1 and not _duel_won
	if not ok:
		printerr("AUTOTEST: beklenen %s, gelen %s (sayfa=%s)" % [expected, _outcome, not page.is_empty()])
	print("AUTOTEST %s chapter=22o variant=%s outcome=%s saved=%d gun=%d/%d" % ["PASS" if ok else "FAIL", v, _outcome, saved, gun_hits, gun_shots])
	get_tree().quit(0 if ok else 1)


# ================================================================ ekran görüntüleri

func _shot_png(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(name))
	print("shot: " + name)


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	hud.set_fade(0.0)
	player.show_remote(false)
	_make_night()
	_show_levels(3)
	_hides[0].visible = true
	_hides[1].visible = true
	player.global_position = TOWER + Vector3(5.0, 0.05, 9.0)
	await get_tree().create_timer(0.8).timeout
	player.face(TOWER + Vector3(0, 5.0, 0))
	hud.set_objective(tr("UI_OBJ22O_HIDE") % [2, 3], TOWER + Vector3(0, 1.5, -2.9))
	await _shot_png("c22o_01_build.png")
	_show_levels(4)
	_hides[2].visible = true
	_burn(2)
	hud.visible = false
	var cv := Camera3D.new()
	add_child(cv)
	cv.global_position = TOWER + Vector3(9.0, 2.2, 14.0)
	cv.look_at(TOWER + Vector3(0, 6.5, 0), Vector3.UP)
	cv.fov = 60.0
	cv.make_current()
	await get_tree().create_timer(0.3).timeout
	await _shot_png("c22o_cover.png")
	get_tree().quit()
