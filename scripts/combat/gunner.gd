class_name Gunner
extends Node3D
## Düşman tüfekçisi: bekler, nişan alır (fitil parlar, ekranda "TÜFEKÇİ!" ve yön oku), ateş eder.
## Oyuncu nişan başladığı yerden 1,6 m uzaklaştıysa, ateş hattına dik 0,9 m kaydıysa ya da tüfekçiyle arasına görünen bir şey girdiyse (mantlet,
## barikat, duvar, kalkan siperi) kurşun ıskalar. Yoksa can gider (düelloda düellonun canından).
## Tüfekçi Handgun'la vurulabilir (soldier hedef listesine konur): vurulan tüfekçi susar.
##   var g := Gunner.spawn(sahne, konum, player, hud)   ·   g.stop()
## Otomatik testte bot uyarı gelince yana adım atar (=lose varyantlarında atmaz).

const WAIT_MIN := 7.0
const WAIT_MAX := 11.0
const DODGE_DIST := 1.6
const SIDE_DIST := 0.9
const DAMAGE := 22.0

var soldier: Soldier
var player: Player
var hud: Hud
var state := "wait"            # wait | aim | done
var shots := 0
var dodged := 0
var hits := 0
var _t := 0.0
var _aim_from := Vector3.ZERO
var _fuse: OmniLight3D
var _spark: MeshInstance3D
var _warn: _Warn
var _rng := RandomNumberGenerator.new()
static var total_dodged := 0      # bölüm boyunca (başarım ve karne)


static func spawn(scene: Node3D, at: Vector3, p: Player, h: Hud, first_wait := 4.0, coat := Color("2f5fa8"), hat := "bork") -> Gunner:
	var g := Gunner.new()
	g.player = p
	g.hud = h
	scene.add_child(g)
	g.global_position = at
	g.soldier = Soldier.new(coat, "stand", hat)
	g.soldier.set_meta("no_talk", true)
	g.soldier.set_meta("climber", true)
	g.add_child(g.soldier)
	g.soldier.equip("handgun")
	g.soldier.face_toward(p.global_position)
	g._rng.seed = int(at.x * 31.0 + at.z * 17.0) + 1453
	g._t = first_wait
	g._build_fuse()
	g._warn = _Warn.new()
	g._warn.gunner = g
	h.add_child(g._warn)
	return g


func stop() -> void:
	state = "done"
	if is_instance_valid(_warn):
		_warn.queue_free()
	if GameState.autotest:
		print("GUNNER shots=%d dodged=%d hits=%d" % [shots, dodged, hits])
	queue_free()


## Testte tüfekçi en az bir kez ateş etsin (bot kaçar), sayılar ondan sonra okunur. Oyuncu donukken (replik, bitirici
## kamerası) tüfekçi beklediği için hızlı makinede bot dalgaları ilk atıştan önce bitirebiliyordu (CI'da Bölüm 20 zor
## düzeyde 0/0; yerelde 5-8 atış). Kalan bekleme kısalır, en çok 12 sn beklenir. Oyunda hiçbir şey değişmez.
func settle_test() -> void:
	if not GameState.autotest or shots > 0 or state == "done" or not alive() or not is_inside_tree():
		return
	if state == "wait":
		_t = minf(_t, 0.4)
	var wt := 0.0
	while shots == 0 and state != "done" and alive() and wt < 12.0:
		await get_tree().process_frame
		wt += get_process_delta_time()


func alive() -> bool:
	return state != "done" and is_instance_valid(soldier) and not soldier.has_meta("gun_down")


func _build_fuse() -> void:
	_fuse = OmniLight3D.new()
	_fuse.light_color = Color("ff9a30")
	_fuse.omni_range = 3.0
	_fuse.light_energy = 0.0
	add_child(_fuse)
	_fuse.position = Vector3(0.15, 1.45, 0.6)
	_spark = Props.ball(self, 0.05, _fuse.position, Color("ffb040"), Vector3.ONE, 6, 4.0)
	_spark.visible = false


func _muzzle() -> Vector3:
	return soldier.global_position + soldier.global_transform.basis * Vector3(0.14, 1.4, 0.85)


func _process(delta: float) -> void:
	if state == "done" or player == null:
		return
	if not alive():
		_spark.visible = false
		_fuse.light_energy = 0.0
		state = "done"
		return
	_fuse.global_position = _muzzle()
	_spark.global_position = _fuse.global_position
	# Oyuncu kıpırdayamazken (replik, bitirici kamerası) tüfekçi ateş etmez: nişanı tutar, oyuncu çözülünce kısa bir payla
	# ateşler. Savunmasız oyuncuyu vurmak haksızdı; testte de kaçma botu o arada kımıldayamıyordu (26o'da ara sıra 0/2).
	var held := player.frozen or player.pinned or _killcam()
	if held and state == "wait":
		return
	soldier.face_toward(player.global_position)
	_t -= delta
	if held and state == "aim":
		_t = maxf(_t, 0.45)
	match state:
		"wait":
			if _t <= 0.0:
				state = "aim"
				_t = GameState.diff("gun_aim")
				_aim_from = player.global_position
				_spark.visible = true
				Audio.stinger("warn", -6.0)
				Audio.sfx("fuse_burn", -10.0, 1.6)
				if GameState.autotest and not GameState.autotest_variant.ends_with("lose"):
					_bot_dodge()
		"aim":
			_fuse.light_energy = 2.0 + 1.5 * sin(Time.get_ticks_msec() * 0.03)
			if _t <= 0.0:
				_fire()
				state = "wait"
				_t = _rng.randf_range(WAIT_MIN, WAIT_MAX)


## Bu noktada ayak hizasının 0,8 m altında zemin var mı (oyuncunun kendisi sayılmaz).
func _floor_at(p: Vector3) -> bool:
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 0.4, 0), p + Vector3(0, -0.8, 0), 1)
	q.exclude = [player.get_rid()]
	return not get_world_3d().direct_space_state.intersect_ray(q).is_empty()


func _killcam() -> bool:
	var d := get_tree().get_first_node_in_group("active_duel") as Duel
	return d != null and d.killcam


func _fire() -> void:
	shots += 1
	GameState.combat_add("gunner_shots")
	_spark.visible = false
	_fuse.light_energy = 0.0
	var at := _muzzle()
	Handgun.blast_fx(get_parent() as Node3D, at, (player.global_position - at).normalized(), -8.0)
	var moved := Vector2(player.global_position.x - _aim_from.x, player.global_position.z - _aim_from.z).length()
	# Ateş hattına dik kayma: kurşun eski yere gider; bir gövde genişliği yana çekilen kurtulur (dar sur yolunda da)
	var line := _aim_from - at
	line.y = 0.0
	var shift := player.global_position - _aim_from
	shift.y = 0.0
	var perp := (shift - line.normalized() * shift.dot(line.normalized())).length() if line.length() > 0.1 else 0.0
	if moved >= DODGE_DIST or perp >= SIDE_DIST or _blocked(at):
		dodged += 1
		GameState.combat_add("dodged")
		GameState.bump_stat("gunner_dodged")
		total_dodged += 1
		Vfx.dust(get_parent() as Node3D, _aim_from + Vector3(0, 0.1, 0), 0.3)
		Audio.sfx("pick_tap", -8.0, 2.2)          # kurşun taşa
		return
	hits += 1
	if GameState.autotest:
		print("GUNNER_HIT moved=%.2f perp=%.2f aim=%s now=%s" % [moved, perp, _aim_from.snapped(Vector3.ONE * 0.1),
			player.global_position.snapped(Vector3.ONE * 0.1)])
	GameState.combat_add("gunner_hits")
	var dmg := DAMAGE
	var duel := get_tree().get_first_node_in_group("active_duel") as Duel
	if duel and duel.active:
		duel.external_hit(dmg, at)
	else:
		player.hurt(dmg, at)
		player.stagger(0.6)


## Tüfekçiyle oyuncunun göğsü arasında görünen bir engel var mı (görünmez sınır duvarları ve karakterler sayılmaz)
func _blocked(from: Vector3) -> bool:
	var to := player.global_position + Vector3(0, 1.2, 0)
	var space := get_world_3d().direct_space_state
	var ex: Array[RID] = [player.get_rid()]
	for _i in 6:
		var q := PhysicsRayQueryParameters3D.create(from + (to - from).normalized() * 0.6, to)
		q.exclude = ex
		q.collision_mask = 1
		var r := space.intersect_ray(q)
		if r.is_empty():
			return false
		var col := r["collider"] as CollisionObject3D
		if col == null:
			return false
		var visible_mesh := false
		for c in col.get_children():
			if c is VisualInstance3D and (c as VisualInstance3D).visible:
				visible_mesh = true
		if not visible_mesh or col.is_in_group("persons"):
			ex.append(col.get_rid())
			continue
		return true
	return false


## Bot: uyarı gelince tüfekçiye dik yönde 2 m yana adım
func _bot_dodge() -> void:
	var to := player.global_position - global_position
	to.y = 0.0
	var side := to.normalized().cross(Vector3.UP)
	if _rng.randf() < 0.5:
		side = -side
	# Dar yerde (sur yolu) yana yer yoksa yol boyunca: önce yanlar, sonra uzaklaş, en son yaklaş. Takılırsa sıradakini dene.
	var dirs: Array[Vector3] = [side, -side, to.normalized(), -to.normalized()]
	var origin := player.global_position
	var k := 0
	var steps := 0
	# Ateşe kadar nişan alınan yerden uzak kal: düello botu oyuncuyu rakibine geri çekerse yeniden kaç (eskiden 24
	# karede bırakıyordu, atış anında eski yere dönmüş oluyordu). Uzaklık hep nişan alınan yerden ölçülür: yön
	# değişince (yan kapalı) öbür yana geçerken başlangıca dönüp orada durmasın.
	while is_instance_valid(player) and state == "aim":
		await get_tree().process_frame
		if not is_instance_valid(player) or state != "aim":
			return
		var moved := Vector2(player.global_position.x - origin.x, player.global_position.z - origin.z).length()
		if moved >= DODGE_DIST + 0.3 or steps >= 240:
			continue
		steps += 1
		var before := player.global_position
		player.move_and_collide(dirs[k] * 0.27)
		# Duvara dayandıysa (bu adımda ilerlemediyse) sıradaki yön
		if player.global_position.distance_to(before) < 0.08 and k < dirs.size() - 1:
			k += 1
		elif player.global_position.distance_to(before) < 0.08:
			# Dört yön de kapalı (sur köşesi, iki rakip arası): sekiz yönden açık olanı dene. Eskiden köşede kalıp
			# vuruluyordu; 26o testi ara sıra bu yüzden düşüyordu.
			for j in 8:
				var dj: Vector3 = dirs[0].rotated(Vector3.UP, j * PI / 4.0)
				var col := player.move_and_collide(dj * 0.27, true)
				# Açık ama ayağının altı boş yön (sur yolunun kenarı) sayılmaz: bot surdan aşağı yürüyordu
				if (col == null or col.get_travel().length() >= 0.08) and _floor_at(player.global_position + dj * 0.4):
					dirs[k] = dj
					player.move_and_collide(dj * 0.27)
					break


## Ekran uyarısı: "TÜFEKÇİ!" yazısı ve tüfekçi ekran dışındaysa kenarda kırmızı ok, ekrandaysa üstünde halka
class _Warn extends Control:
	var gunner: Gunner

	func _ready() -> void:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(_d: float) -> void:
		queue_redraw()

	func _draw() -> void:
		if not is_instance_valid(gunner) or gunner.state != "aim" or not gunner.alive():
			return
		var cam := gunner.player.camera
		var vs := get_viewport_rect().size
		var c := vs * 0.5
		var pulse := 0.6 + 0.4 * sin(Time.get_ticks_msec() * 0.02)
		var col := Color(1.0, 0.25, 0.15, pulse)
		var font := ThemeDB.fallback_font
		var tp := Vector2(c.x - 400, vs.y * 0.24)
		draw_string_outline(font, tp, tr("UI_GUNNER_WARN"), HORIZONTAL_ALIGNMENT_CENTER, 800, 30, 8, Color(0, 0, 0, 0.75 * pulse))
		draw_string(font, tp, tr("UI_GUNNER_WARN"), HORIZONTAL_ALIGNMENT_CENTER, 800, 30, Color(1.0, 0.35, 0.2, 1.0))
		var p := gunner._muzzle()
		var local := cam.global_transform.basis.inverse() * (p - cam.global_position)
		if local.z < 0.0:
			var sp := cam.unproject_position(p)
			if Rect2(Vector2.ZERO, vs).grow(-20).has_point(sp):
				draw_arc(sp, 26.0, 0.0, TAU, 24, col, 3.0)
				return
		var ang := atan2(local.z if local.z > 0.0 else -local.y, local.x)
		if local.z < 0.0:
			ang = atan2(-local.y, local.x)
		var dv := Vector2(cos(ang), sin(ang))
		var e := c + dv * minf(c.x, c.y) * 0.85
		var s := 34.0
		var pts := PackedVector2Array([e + dv * s, e + dv.rotated(2.5) * s * 0.7, e + dv.rotated(-2.5) * s * 0.7])
		draw_colored_polygon(pts, col)
