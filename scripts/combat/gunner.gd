class_name Gunner
extends Node3D
## Düşman tüfekçisi: bekler, nişan alır (fitil parlar, ekranda "TÜFEKÇİ!" ve yön oku), ateş eder.
## Oyuncu nişan başladığı yerden 1,6 m uzaklaştıysa, ateş hattına dik 0,9 m kaydıysa ya da tüfekçiyle arasına görünen bir şey girdiyse (mantlet,
## barikat, duvar, kalkan siperi) kurşun ıskalar. Yoksa can gider (düelloda düellonun canından).
## Tüfekçi Handgun'la vurulabilir (soldier hedef listesine konur): vurulan tüfekçi susar.
## Gövde düellocularla aynı Person: tüfeği iki eliyle omzunda tutar (eller kundakta ve namlunun altında, Rig.reach).
## Yakın dövüş: çarpışma sürerken oyuncu dibine gelirse (kuleye erken çıkmak gibi) hayalet gibi durmaz; tüfeği yere
## atar, yerdeki kılıcı alır ve aynı kişi (aynı yüz, aynı kıyafet) rakip olarak dövüşe katılır. Bölüm de
## draw_sword() ile aynı geçişi sahneler (30o: "Yaklaşma! Bu tüfek dolu!" sonrası). Eskiden tüfekçi silinip yerine
## başka kıyafetli bir düellocu konuyordu ve tüfek göğüste, kollar açık duruyordu.
##   var g := Gunner.spawn(sahne, konum, player, hud)   ·   g.stop()   ·   var d: Duelist = await g.draw_sword()
## Otomatik testte bot uyarı gelince yana adım atar (=lose varyantlarında atmaz).

const WAIT_MIN := 7.0
const WAIT_MAX := 11.0
const DODGE_DIST := 1.6
const SIDE_DIST := 0.9
const DAMAGE := 22.0

signal joined_melee(d: Duelist)

const ENGAGE_DIST := 2.4

var soldier: Node3D            # gövde (Person; düellocuyla aynı görünüş)
var look: Dictionary = {}
var engaged := false           # kılıca davrandı (yakın dövüş)
var duelist: Duelist           # kılıca davrandıktan sonraki hâli
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
var _gun: Node3D
var _floor_sword: Node3D
var _look_n := 0
static var total_dodged := 0      # bölüm boyunca (başarım ve karne)


static func spawn(scene: Node3D, at: Vector3, p: Player, h: Hud, first_wait := 4.0, coat := Color("2f5fa8"), hat := "bork",
		p_look := {}) -> Gunner:
	var g := Gunner.new()
	g.player = p
	g.hud = h
	scene.add_child(g)
	g.global_position = at
	g.look = p_look if not p_look.is_empty() else {"coat": coat, "pants": Color("3a2a22") if hat == "helm" else Color("e8e0d0"),
		"hat": hat, "mustache": true, "skin": Color("d9a07a")}
	# Düellocuya dönüşünce aynı yüz, saç ve zırh çıksın: Person görünüşü tohumdan ve aynı görünüşün sırasından gelir
	g._look_n = int(Person._look_count.get(hash(str(g.look)), 0))
	var body := Person.new(g.look)
	body.set_meta("no_talk", true)
	body.set_meta("no_chat", true)
	body.set_meta("no_yield", true)
	body.set_meta("climber", true)
	g.soldier = body
	g.add_child(body)
	body.rig.lock += 1            # kollar tüfekte (aşağıda elle)
	g._build_gun()
	g._face(p.global_position)
	g._pose()
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


## Fitilli el topu: ahşap kundak sağ omuzda, demir namlu ileri; yanında yerde kını boş bir kılıç (kılıca davranınca alır)
func _build_gun() -> void:
	_gun = Node3D.new()
	_gun.name = "Handgun"
	soldier.add_child(_gun)
	_gun.position = Vector3(0.15, 1.36, 0.0)
	Props.box(_gun, Vector3(0.07, 0.09, 0.55), Vector3(0, 0, 0.16), Color("5a3a22"))
	Props.cyl(_gun, 0.028, 0.75, Vector3(0, 0.03, 0.8), Color("3a3a40"), Vector3(90, 0, 0), 6, 0.0)
	Props.ball(_gun, 0.025, Vector3(0.05, 0.08, 0.02), Color("ffb040"))
	_floor_sword = Node3D.new()
	add_child(_floor_sword)
	_floor_sword.position = Vector3(-0.5, 0.03, 0.25)
	_floor_sword.rotation_degrees = Vector3(90, 35, 0)
	Blades.spathion(_floor_sword)


func _face(p: Vector3) -> void:
	var to := p - soldier.global_position
	if Vector2(to.x, to.z).length() > 0.01:
		soldier.global_rotation = Vector3(0, atan2(to.x, to.z), 0)


## Nişan duruşu: gövde yan döner (sol omuz önde), baş namlu boyunca bakar; sağ el kundakta, sol el namlunun altında
func _pose() -> void:
	var b := soldier as Person
	if b == null or b._body == null:
		return
	b._body.rotation.y = 0.65
	b._head.rotation.y = -0.6
	b._leg_l.rotation.x = -0.12
	b._leg_r.rotation.x = 0.18
	var xf := b.global_transform
	Rig.reach(b._arm_r, b._elbow_r, xf * Vector3(0.17, 1.3, 0.04), xf.basis * Vector3(0.6, -1.0, -0.3))
	Rig.reach(b._arm_l, b._elbow_l, xf * Vector3(0.15, 1.33, 0.4), xf.basis * Vector3(-0.8, -1.0, 0.0))


## Tüfeği bırakıp kılıca davranır: tüfek yana savrulup yere düşer (orada kalır), eğilip yerdeki kılıcı alır; aynı kişi
## (aynı görünüş, yer, yön) düellocu olur. Döner: sahnedeki Duelist (Duel'e eklenmemiş). opts: "skill", "hp", "name".
func draw_sword(opts := {}) -> Duelist:
	if duelist:
		return duelist
	engaged = true
	state = "done"
	if is_instance_valid(_warn):
		_warn.queue_free()
	_spark.visible = false
	_fuse.light_energy = 0.0
	var b := soldier as Person
	var par := get_parent() as Node3D
	if b == null or not is_instance_valid(b) or par == null:
		return null
	Audio.sfx("whoosh_fly", -10.0, 1.4)
	if is_instance_valid(_gun):
		var gx := _gun.global_transform
		_gun.get_parent().remove_child(_gun)
		par.add_child(_gun)
		_gun.global_transform = gx
		var land := b.global_position + b.global_basis.x * 0.85 + b.global_basis.z * 0.25 + Vector3(0, 0.05, 0)
		var tw := _gun.create_tween().set_parallel()
		tw.tween_property(_gun, "global_position", land, 0.35).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(_gun, "global_rotation", Vector3(0, b.global_rotation.y + 1.3, PI * 0.5), 0.35)
		tw.finished.connect(func(): Audio.sfx("pick_tap", -6.0, 0.6))
	# Duruşu bırakır, eğilip yerdeki kılıcı alır
	b._body.rotation.y = 0.0
	b._head.rotation.y = 0.0
	b.rig.lock = maxi(0, b.rig.lock - 1)
	b.set_activity("lean_down")
	await get_tree().create_timer(0.55).timeout
	if is_instance_valid(_floor_sword):
		_floor_sword.visible = false
	Audio.sfx("sword_clash", -14.0, 1.7)
	b.set_activity("")
	await get_tree().create_timer(0.15).timeout
	if not is_instance_valid(b) or not is_instance_valid(par):
		return null
	Person._look_count[hash(str(look))] = _look_n
	var d := StoryDuel.make(par, player, {"pos": b.global_position, "look": look, "blade": "spathion", "shield": false,
		"name": opts.get("name", b.get_meta("spk", "SPK_DEFENDER")), "skill": opts.get("skill", 0.5), "hp": opts.get("hp", 70.0)},
		float(opts.get("skill", 0.5)), false)
	par.add_child(d)
	d.global_position = b.global_position
	d.global_rotation = Vector3(0, b.global_rotation.y, 0)
	b.visible = false
	b.queue_free()
	duelist = d
	return d


## Çarpışma sürerken oyuncu dibine geldi: kılıca davranıp o çarpışmaya rakip olarak katılır
func _engage() -> void:
	var duel := get_tree().get_first_node_in_group("active_duel") as Duel
	if duel == null or not duel.active:
		return
	engaged = true
	var d := await draw_sword()
	if d == null or not is_instance_valid(duel) or not duel.active:
		return
	duel.add_enemy(d)
	for m in get_tree().current_scene.find_children("Melee*", "", true, false):
		if m is Melee and (m as Melee).duel == duel:
			(m as Melee).add_foe(d)
	if GameState.autotest:
		print("GUNNER_ENGAGED shots=%d" % shots)
	joined_melee.emit(d)


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
	return soldier.global_position + soldier.global_transform.basis * Vector3(0.15, 1.39, 1.16)


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
	# Dibine gelen oyuncu: kılıca davranır (testte en az bir atıştan sonra: tüfekçi sayıları ölçülsün)
	if not engaged and not player.frozen and (shots > 0 or not GameState.autotest):
		var d := player.global_position - soldier.global_position
		if Vector2(d.x, d.z).length() < ENGAGE_DIST and absf(d.y) < 1.6:
			var duel := get_tree().get_first_node_in_group("active_duel") as Duel
			if duel and duel.active:
				_engage()
				return
	var held := player.frozen or player.pinned or _killcam()
	if held and state == "wait":
		_pose()
		return
	_face(player.global_position)
	_pose()
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


## Bot: uyarı gelince en çok kaçış sağlayan açık yöne koşar (_bot_dir). Eskiden önce rastgele bir yana, takılınca öbür
## yana, sonra ateş hattı boyunca deniyordu: 2 m'lik sur yolunda yanlar dar, yön değiştirirken nişan süresi bitiyordu
## (26o "gunner=0/2", yük altında).
func _bot_dodge() -> void:
	var line := player.global_position - global_position
	line.y = 0.0
	line = line.normalized()
	var origin := player.global_position
	var dir := _bot_dir(origin, line)
	var steps := 0
	# Ateşe kadar nişan alınan yerden uzak kal: düello botu oyuncuyu rakibine geri çekerse yeniden kaç (eskiden 24
	# karede bırakıyordu, atış anında eski yere dönmüş oluyordu). Uzaklık hep nişan alınan yerden ölçülür.
	while is_instance_valid(player) and state == "aim":
		await get_tree().process_frame
		if not is_instance_valid(player) or state != "aim":
			return
		var moved := Vector2(player.global_position.x - origin.x, player.global_position.z - origin.z).length()
		if moved >= DODGE_DIST + 0.3 or steps >= 240:
			continue
		steps += 1
		# Adım oyun zamanıyla (koşu hızı): kare başına sabit 0,27 m yük altındaki makinede (testte zaman 3 kat, kare hızı
		# düşük) nişan süresine 3-4 kare düşünce 1 m bile kaçamıyordu
		var step := clampf(get_process_delta_time() * 6.0, 0.27, 0.8)
		var before := player.global_position
		player.move_and_collide(dir * step)
		# Takıldıysa (rakip, mazgal, köşe) bulunduğu yerden yeniden ölç
		if player.global_position.distance_to(before) < 0.08:
			dir = _bot_dir(origin, line)


## Kaçış yönü: on altı yönde 2 m'lik deneme adımı (katıya ya da birine çarpınca durur, ayağının altı boşalınca kesilir:
## bot surdan aşağı yürümesin); varılan yerin nişan yerinden uzaklığı (DODGE_DIST) ya da ateş hattından yana kayması
## (SIDE_DIST) ölçülür, en iyisi seçilir.
func _bot_dir(origin: Vector3, line: Vector3) -> Vector3:
	var best := line.cross(Vector3.UP)
	var best_s := -1.0
	var p := player.global_position
	for j in 16:
		var d := line.rotated(Vector3.UP, j * TAU / 16.0)
		var col := player.move_and_collide(d * 2.0, true)
		var reach := 2.0 if col == null else col.get_travel().length()
		var r := 0.0
		while r + 0.25 <= reach and _floor_at(p + d * (r + 0.25)):
			r += 0.25
		var e := p + d * r - origin
		e.y = 0.0
		var side := (e - line * e.dot(line)).length()
		var sc := maxf(e.length() / DODGE_DIST, side / SIDE_DIST)
		if sc > best_s + 0.01:
			best_s = sc
			best = d
	return best


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
