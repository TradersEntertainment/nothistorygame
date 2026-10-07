class_name Trespass
extends Node
## Düşman tarafına geçen oyuncu (Osmanlı bölümlerinde barikattan, gedikten, açık bir kapıdan şehre ya da surlar arasına
## giren): uyarı, içeriden savunucular bağırıp üstüne koşar; geri çıkmazsa birkaç saniyede yakalanır, kalkanlarla dövülüp
## dışarıya, güvenli yere atılır. Eskiden barikatın ardı boştu ve oyuncu şehirde dolaşabiliyordu (37o).
## Kullanım: Trespass.attach(sahne, oyuncu, hud, içeride_mi, güvenli_yer, muhafız_çıkışı)
##   içeride_mi: func(p: Vector3) -> bool (boşsa byz_side); güvenli_yer: func() -> Vector3 (boşsa oyuncunun dışarıdaki
##   son sağlam yeri); muhafız_çıkışı: Vector3.INF ise oyuncunun girdiği yerin 8 m içerisi

const GRACE := 3.2            # uyarıdan sonra yakalanmaya kadar (sn)
const RUN := 5.2              # muhafızların koşusu (m/sn)

var player: Player
var hud: Hud
var inside: Callable
var safe: Callable
var guards_from := Vector3.INF
var enabled := true
var caught := 0
var _t := -1.0
var _busy := false
var _guards: Array[Person] = []
var _home: Array[Vector3] = []
var _last_safe := Vector3.INF
var _sample := 0.0


static func attach(scene: Node, p_player: Player, p_hud: Hud, p_inside := Callable(), p_safe := Callable(), from := Vector3.INF) -> Trespass:
	var t := Trespass.new()
	t.name = "Trespass"
	t.player = p_player
	t.hud = p_hud
	t.inside = p_inside if p_inside.is_valid() else Callable(Trespass, "byz_side")
	t.safe = p_safe
	t.guards_from = from
	scene.add_child(t)
	return t


## Kuşatma boyunca Bizans'ın elindeki yer: surların içi (şehir) ve iki sur arası (peribolos). Dış surun önü, hendek ve
## ova dışarıdır; yerin altı (lağım tünelleri) sayılmaz.
static func byz_side(p: Vector3) -> bool:
	return p.y > -1.5 and p.z < LandWalls.OUTER_Z0 - 0.3 and p.z > World1453.TIP.z and p.x > World1453.HORN_S_X \
		and p.x < World1453.marmara_x(p.z)


func _ready() -> void:
	# Üç savunucu: kalkan ve mızrak, Bizans miğferi. Oyuncu içeri girene dek görünmez (koşarak gelir)
	for i in 3:
		var g := Person.new({"coat": [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96")][i], "pants": Color("3a3a40"), "hat": "helm",
			"mustache": i != 1, "beard": i == 0, "skin": Color("e0b08a")})
		g.set_meta("no_talk", true)
		g.set_meta("no_rally", true)
		g.visible = false
		get_parent().add_child.call_deferred(g)
		g.ready.connect(func(): g.equip("spear_shield", Color("5a2a24")), CONNECT_ONE_SHOT)
		_guards.append(g)
		_home.append(Vector3.ZERO)


func _process(delta: float) -> void:
	if not enabled or _busy or player == null or not is_instance_valid(player):
		return
	# Kara ara sahnede ve düelloda bakmaz: gedikte dövüşte cephe hattı oynaktır (rakibin peşinden moloz dilinin içine
	# birkaç adım girilir)
	if player.frozen or hud.is_faded() or not get_tree().get_nodes_in_group("active_duel").is_empty():
		return
	var p := player.global_position
	var is_in: bool = inside.call(p)
	# Dışarıdaki son sağlam yer (güvenli yer verilmemişse oyuncu buraya atılır)
	_sample -= delta
	if not is_in and _sample <= 0.0 and player.is_on_floor():
		_sample = 0.5
		_last_safe = p + Vector3(0, 0.05, 0)
	if is_in:
		if _t < 0.0:
			_t = 0.0
			_alarm(p)
		_t += delta
		var near := false
		for g in _guards:
			if not is_instance_valid(g) or not g.visible:
				continue
			var to := p - g.global_position
			to.y = 0.0
			if to.length() < 1.3:
				near = true
				continue
			# Katıların (barikat, moloz katmanı) içinden geçmez; görünen zemine basar
			var step := Unclip.free_step(g, to.normalized() * minf(RUN * delta, to.length() - 1.2))
			var np := g.global_position + step
			var fy := Unclip.floor_y(g, np, 0.9, 2.5)
			if not is_nan(fy):
				np.y = fy
			g.global_position = np
		if near or _t >= GRACE:
			_catch()
	else:
		if _t >= 0.0:
			# Geri çıktı: uyarı kalkar, muhafızlar olduğu yerde durur
			_t = -1.0
			hud.set_qte("")
		_send_home()


## Uyarı ve savunucuların çıkışı: verilen yerden ya da oyuncunun girdiği yerin içerisinden (katı olmayan, zemini olan)
func _alarm(p: Vector3) -> void:
	hud.set_qte(tr("UI_TRESPASS_WARN"))
	Audio.sfx("war_cry", -8.0, 1.15)
	var base := guards_from
	if base == Vector3.INF:
		base = p + Vector3(0, 0, -8.0)
		for d: float in [8.0, 6.0, 4.0, 2.5]:
			var c := p + Vector3(0, 0, -d)
			var fy := Unclip.floor_y(player, c, 3.0, 4.0)
			if not is_nan(fy) and not Unclip.in_solid(player, Vector3(c.x, fy + 0.9, c.z), 0.3):
				base = Vector3(c.x, fy, c.z)
				break
	for i in _guards.size():
		var g := _guards[i]
		if not is_instance_valid(g):
			continue
		var h := base + Vector3(-1.6 + i * 1.6, 0, -1.2 * (i % 2))
		var fy := Unclip.floor_y(player, h, 1.5, 3.0)
		_home[i] = Vector3(h.x, base.y if is_nan(fy) else fy, h.z)
		g.global_position = _home[i]
		g.visible = true


## Kovalamayı bırakan muhafızlar, oyuncu uzaklaşınca ya da görmüyorken yerlerine döner (gözden çıkar)
func _send_home() -> void:
	var cam := get_viewport().get_camera_3d()
	for i in _guards.size():
		var g := _guards[i]
		if not is_instance_valid(g) or not g.visible:
			continue
		var far := g.global_position.distance_to(player.global_position) > 22.0
		if far or cam == null or not cam.is_position_in_frustum(g.global_position + Vector3(0, 1.0, 0)):
			g.global_position = _home[i]
			g.visible = false


## Yakalanma: kalkan darbesi, kararma, kart; oyuncu güvenli yere atılır (biraz yaralı)
func _catch() -> void:
	_busy = true
	caught += 1
	hud.set_qte("")
	Audio.sfx("kick_metal", -2.0, 0.8)
	Audio.sfx("land_thud", -2.0, 0.7)
	Fx.trauma(0.6)
	player.frozen = true
	if GameState.autotest:
		print("TRESPASS caught=%d at=%s" % [caught, player.global_position.snapped(Vector3.ONE * 0.1)])
	await hud.fade_to(1.0, 0.35)
	for i in _guards.size():
		if is_instance_valid(_guards[i]):
			_guards[i].visible = false
	var to: Vector3 = safe.call() if safe.is_valid() else _last_safe
	if to != Vector3.INF:
		player.global_position = to
		player.velocity = Vector3.ZERO
	player.hurt(12.0, Vector3.INF, true)
	await hud.card([[tr("UI_TRESPASS_CAUGHT"), 24, Color("f2e6c9")]], 2.2 if not GameState.autotest else 0.3)
	hud.clear_card()
	await hud.fade_to(0.0, 0.35)
	player.frozen = false
	_t = -1.0
	_busy = false
