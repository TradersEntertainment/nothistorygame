extends Node3D
## Soğuk açılış (yeni oyunun ilk dakikası): 29 Mayıs 1453, gece 01.30, kara surlarındaki gedik.
##
## Oyuncu doğrudan kuşatmanın en büyük gecesinde başlar: kolunun altında ok demetleri, ok yağmuru altında gedikteki okçulara
## koşar. Gözcü "Büyük top! Siper!" diye bağırır, gülle arkasına düşer; Tolga havaya savrulurken kare donar
## (renkler solar, "TOLGA · hasar tespit uzmanı" yazısı). Tolga seyirciye döner: "Muhtemelen buraya nasıl geldiğimi
## merak ediyorsunuz." Nihat telsizden araya girer: "Bu sayfa henüz yazılmadı. Geri sarıyoruz." Görüntü kaset gibi
## geri sarılır ve oyun garajda başlar ("Beş hafta önce").
## Bu an oyunda gerçekten gelir: Bölüm 26 (Şafak), Bizans tarafı. Osmanlı tarafını seçen oyuncu için Nihat'ın sözü
## doğrudur: sayfa henüz yazılmamıştır.
##   --chapter=0 --autotest[=next]   (next: bittiğinde Bölüm 1'e geçer)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const TOLGA := {"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")}
const START := Vector3(7.0, 0.05, 4.0)
## Ok demetlerinin götürüleceği savunucu sırası (gediğin içi)
const LINE := Vector3(-0.6, 0.0, 11.4)
## Donan karede Tolga'nın (havadaki) yeri: gedik önündeki açık peribolos
const STAGE := Vector3(3.0, 0.0, 8.6)

var world: Node3D
var walls: LandWalls
var assault: Assault
var player: Player
var hud: Hud
var giust: Person
var phase := "intro"
var _carry: Node3D
var _shield: Node3D
var _volley_t := 1.2
var _overlay: ColorRect
var _mat: ShaderMaterial
var _caption: Control
var _place: Label
var freeze_cam: Camera3D
var froze := false


func _ready() -> void:
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.frozen = true
	hud.set_fez(true)
	hud.set_signal(0)
	world = Node3D.new()
	add_child(world)
	walls = LandWalls.new()
	walls.assault_mode = true
	world.add_child(walls)
	walls.set_repair(LandWalls.STAGES - 2)
	walls.auto_cover = false
	_build()
	_build_overlay()
	if GameState.autotest:
		Engine.time_scale = 2.5
	_run()


func _build() -> void:
	giust = Person.new({"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
		"beard": true, "skin": Color("e0b08a")})
	giust.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-4.2, 0, -3.0))
	world.add_child(giust)
	giust.look_target = player
	for i in 6:
		var d := Person.new({"coat": [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96")][i % 3], "pants": Color("3a2a22"), "hat": "helm",
			"beard": i % 2 == 0, "mustache": true, "n": 40 + i})
		d.set_meta("no_talk", true)
		d.set_meta("spk", "SPK_DEFENDER")       # "Oklar!": kartta en yakın savunucu
		# Barikatın arkasında (tabyanın içinde değil)
		d.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-3.2 + i * 1.3, 0, -2.7 - (i % 2) * 0.35))
		world.add_child(d)
	# Surun önü: sancaklı ordu, sura koşan dalgalar, merdivenler, bataryalar, surda savunanlar, ok yağmuru
	assault = Assault.new()
	assault.keep = Rect2(-40.0, -10.0, 80.0, 36.0)
	assault.live_span = 30.0
	world.add_child(assault)
	assault.build()
	# Sur yolu dolu, iç surun üstü de (Bölüm 26 gibi)
	Garrison.land_walls(world, [Vector2(13.0, 19.0), Vector2(-10.4, -6.8), Vector2(6.8, 10.4)], [Vector2(-30.0, 30.0)], [], 26, 46.0, true, true, true)
	var fight := WallFight.new()
	world.add_child(fight)
	for sx: float in [-1.0, 1.0]:
		fight.add_cauldron(Vector3(sx * 8.6, LandWalls.OUTER_H, 15.0), 2640 + int(sx))
	fight.add_carriers(LandWalls.DEPOT + Vector3(-2.6, 0, 2.6), LandWalls.BREACH + Vector3(0, 0, -3.4), 4, 2650)
	fight.add_builders(LandWalls.BREACH + Vector3(0, 0, -2.6), 2, 2660)
	Garrison.squad(world, Vector3(-18.0, 0, 8.0), 5, 2, 0.0, 2610, "spear_shield", true)
	Garrison.squad(world, Vector3(22.5, 0, 9.0), 4, 2, 0.0, 2620, "spear_shield", true)
	# Gerçek savaş: kalkanını başına kaldırıp koşanlar, ok yiyip devrilenler, yerde oklanmış yatanlar, gedikte
	# kalkan kalkana duranlar (oyuncunun yolunu kesmeyen şeritlerde)
	# (Arka şerit depoda biter: eskiden depoyu, toprak yığınını ve fıçıları içinden geçerek kesiyordu.)
	for lane: Array in [[Vector3(-17.5, 0, 2.4), Vector3(3.0, 0, 2.4), 1.4, 11, 5, 0], [Vector3(6.5, 0, 12.6), Vector3(26, 0, 12.6), 1.2, 6, 3, 0],
			[Vector3(-26, 0, 12.6), Vector3(-6.5, 0, 12.6), 1.2, 6, 3, 0], [START + Vector3(-2.2, 0, 3.0), LINE + Vector3(2.4, 0, -3.0), 3.0, 0, 4, 0]]:
		var bx := BattleExtras.new()
		world.add_child(bx)
		bx.assault = assault
		bx.hit_every = 1.8
		bx.populate(lane[0], lane[1], lane[2], lane[3], lane[4], lane[5], 3100 + int(lane[0].x))
	# Sur içi kargaşa (Bölüm 26'daki gibi): koşuşan yedekler, kaçan halk, yaralısının başına çökenler. Oyuncunun ok taşıdığı
	# yol (başlangıç → gedik hattı), gediğin arkası, depo ve merdiven ayakları boş kalır.
	var chaos := SiegeChaos.new()
	chaos.player = player
	chaos.area = Rect2(-44.0, 1.4, 88.0, 10.6)
	chaos.static_clear_x = 12.0
	chaos.bells = true
	chaos.seed = 29
	chaos.avoid = [[Vector3(0, 0, 14.0), 5.4], [LandWalls.DEPOT, 3.0], [Vector3(-8.0, 0, 12.2), 1.8], [Vector3(8.0, 0, 12.2), 1.8],
		[START, 2.0], [LINE, 2.4], [STAGE, 2.2]]
	chaos.avoid_lines = [[START, LINE, 1.6]]
	world.add_child(chaos)
	# Başın üstünde kalkan (birinci şahıs: ekranın üst solunda, alttan görünür)
	var sh := Node3D.new()
	sh.position = Vector3(-0.44, 0.34, -0.78)
	sh.rotation = Vector3(-1.05, 0.0, 0.35)
	sh.scale = Vector3.ONE * 0.75
	player.camera.add_child(sh)
	Blades.shield(sh, Color("7a2a24"), Color("9aa0a8"))
	Props.strip_outlines(sh)
	_shield = sh
	# Kolun altında ok demetleri (gedikteki okçulara; 29 Mayıs gecesi okçuların oku tükeniyordu)
	_carry = Node3D.new()
	_carry.position = Vector3(0.32, -0.5, -0.75)
	_carry.rotation = Vector3(0.2, 0.9, 0.35)
	player.camera.add_child(_carry)
	for k in 2:
		var bd := BattleExtras.arrow_bundle(_carry)
		bd.position = Vector3(k * 0.14, -k * 0.05, k * 0.06)
	Props.strip_outlines(_carry)
	player.speed_mult = 0.9


## Donan kare efekti (renk solması, kenar kararması) ve geri sarma (satır kayması, parazit).
func _build_overlay() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 4
	add_child(cl)
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float amount = 0.0;
uniform float rewind = 0.0;
void fragment() {
	vec2 uv = SCREEN_UV;
	float band = step(0.5, fract(uv.y * 70.0 + TIME * 24.0));
	uv.x += rewind * (sin(uv.y * 38.0 + TIME * 55.0) * 0.012 + (band - 0.5) * 0.006);
	vec3 c = texture(screen_tex, uv).rgb;
	float g = dot(c, vec3(0.3, 0.59, 0.11));
	// Ateş (parlak, sıcak) renginde kalır: sepyanın içinde patlama parlar
	float fire = smoothstep(0.35, 0.6, c.r - c.b) * smoothstep(0.8, 0.97, c.r);
	c = mix(c, vec3(g * 1.1, g * 0.96, g * 0.78), amount * 0.8 * (1.0 - fire * 0.85));
	vec2 d = SCREEN_UV - 0.5;
	c *= 1.0 - dot(d, d) * 1.1 * amount;
	c += rewind * 0.1 * band;
	COLOR = vec4(c, 1.0);
}
"""
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.material = _mat
	_overlay.visible = false
	cl.add_child(_overlay)
	# Yer ve zaman yazısı (sol üst, daktilo): siyah kart yerine görüntünün üstünde
	_place = Label.new()
	# Ortada, hedef kutusunun altında (sol üstteki hedef kutusuyla çakışmaz)
	_place.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_place.offset_top = 168.0
	_place.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place.add_theme_font_override("font", load(Hud.FONT_TITLE))
	_place.add_theme_font_size_override("font_size", 30)
	_place.add_theme_color_override("font_color", Color("f2e6c9"))
	_place.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_place.add_theme_constant_override("outline_size", 10)
	_place.visible_ratio = 0.0
	cl.add_child(_place)


# ================================================================ akış

func _run() -> void:
	hud.set_fade(1.0)
	player.global_position = START
	player.face(LINE + Vector3(0, 1.4, 0))
	player.show_remote(false)
	_capture_mouse()
	Audio.music("tension", 0.0)
	Audio.ambience("amb_wall_night")
	Audio.sfx("cannon", -2.0)
	await hud.fade_to(0.0, 0.8)
	_place.text = tr("UI_CH0_PLACE")
	var tw := create_tween()
	tw.tween_property(_place, "visible_ratio", 1.0, 1.4)
	tw.tween_interval(3.5)
	tw.tween_property(_place, "modulate:a", 0.0, 0.6)
	hud.bark("SPK_LOOKOUT", "D26_L_WAVE_1", 3.2)
	phase = "run"
	player.frozen = false
	hud.set_objective(tr("UI_OBJ0_ARROWS"), LINE + Vector3(0, 1.4, 0))
	await get_tree().create_timer(3.4).timeout
	if phase == "run":
		hud.bark("SPK_GIUST", "D0_G_ARROWS", 5.0)
	await _shot("c0_01_run", 0.8)
	if GameState.autotest or GameState.shots_dir != "":
		player.global_position = LINE + Vector3(0.8, 0.05, -2.0)
	while phase == "run":
		await get_tree().process_frame
	await _hit()
	await _freeze()
	await _rewind()


func _process(delta: float) -> void:
	if phase != "run":
		return
	# Oklar oyuncunun çevresine yağar (üstüne değil: yakınına saplanır)
	_volley_t -= delta
	if _volley_t <= 0.0:
		_volley_t = randf_range(2.2, 3.4)
		var p := player.global_position + Vector3(randf_range(-5, 5), 0, randf_range(1.5, 6.0))
		assault.volley(Vector3(p.x, 0, p.z), 3.5, 18, true)
		Audio.sfx("whoosh_fly", -14.0, 1.4)
	var d := Vector2(player.global_position.x - LINE.x, player.global_position.z - LINE.z).length()
	if d < 3.0:
		phase = "delivered"


## Oklar verilir; gözcü bağırır, herkes siper alır; büyük top; gülle arkaya düşer.
func _hit() -> void:
	player.frozen = true
	hud.set_objective("")
	if _carry:
		_carry.queue_free()
		_carry = null
	Audio.sfx("land_thud", -10.0)
	hud.bark("SPK_DEFENDER", "D0_S_ARROWS", 2.0)
	await get_tree().create_timer(1.6).timeout
	hud.bark("SPK_LOOKOUT", "D20_L_WARN_2", 2.4)
	walls.fire_flash()
	BattleExtras.all_take_cover(world, [])
	Audio.sfx("cannon", 0.0, 0.8)
	# Top surun ardında: gökyüzü turuncu parlar, yer sarsılır
	player.face(LandWalls.BREACH + Vector3(0, 16.0, 40.0))
	player.shake(0.8)
	hud.set_fade(0.45, Color("ffb45a"))
	hud.fade_to(0.0, 0.5, Color("ffb45a"))
	await _shot("c0_02_gun", 0.25)
	await get_tree().create_timer(1.4).timeout


## Kare donar: Tolga havada, arkasında patlama; renk solar; isim yazısı; Tolga seyirciye konuşur; Nihat araya girer.
func _freeze() -> void:
	phase = "freeze"
	# Sabit kadraj (oyuncunun durduğu yerden bağımsız): peribolos boyunca bakılır; solda dış sur ve gedik, sağda iç sur,
	# Tolga ortada havada ve kameraya doğru savrulmuş, patlama arkasında (sur koridorunun derinliğinde)
	var tp := STAGE + Vector3(0, 0.6, 0)
	var eye := tp + Vector3(0, 1.2, 0)
	var cam_p := STAGE + Vector3(-4.2, 1.55, 0.9)
	var blast := STAGE + Vector3(5.8, 0.2, 1.3)
	# Kadrajın önüne giren kalabalık gizlenir
	for n in world.find_children("*", "Node3D", true, false):
		if (n is Person or n is Soldier) and n.visible:
			var np: Vector3 = (n as Node3D).global_position + Vector3(0, 1.0, 0)
			var seg := Geometry3D.get_closest_point_to_segment(np, cam_p, eye)
			if np.distance_to(seg) < 1.0 or np.distance_to(cam_p) < 3.4 or np.distance_to(blast) < 3.0:
				n.visible = false
	# Üçüncü kişi: Tolga havada; yüzü kameraya (seyirciye konuşacak), başı öne: patlama onu kameraya doğru savurdu
	var tolga := Person.new(TOLGA)
	tolga.set_meta("no_audit", true)      # patlamanın donmuş karesinde havada: kasıtlı (fizik denetimi saymaz)
	world.add_child(tolga)
	var to_cam := cam_p - tp
	to_cam.y = 0.0
	tolga.global_position = tp
	tolga.rotation = Vector3(0, atan2(to_cam.x, to_cam.z), 0)
	tolga.rotate_object_local(Vector3.RIGHT, 0.3)
	tolga.rotate_object_local(Vector3.FORWARD, -0.12)
	# Kollar tam patlama karesinde havaya (önceden kalkmaz); kalkan elden uçar
	if tolga.rig:
		tolga.rig.lock += 1
		tolga.rig.arm_l.rotation = Vector3(-2.9, 0, -0.55)
		tolga.rig.arm_r.rotation = Vector3(-2.9, 0, 0.55)
		if tolga.rig.elbow_l:
			tolga.rig.elbow_l.rotation.x = -0.25
			tolga.rig.elbow_r.rotation.x = -0.25
		tolga.rig.mood = "surprised"
	var fsh := Node3D.new()
	world.add_child(fsh)
	fsh.global_position = tp + Vector3(0.5, 2.35, 0.6)
	fsh.rotation = Vector3(-0.4, 0.6, 0.9)
	Blades.shield(fsh, Color("7a2a24"), Color("9aa0a8")).scale = Vector3.ONE * 1.25
	if _shield:
		_shield.queue_free()
		_shield = null
	# Patlamanın yanındakiler de savrulur
	for n in world.find_children("*", "Node3D", true, false):
		if (n is Person or n is Soldier) and n != tolga and n.visible:
			var np: Vector3 = (n as Node3D).global_position
			if np.distance_to(blast) < 7.5:
				var away := Vector3(np.x - blast.x, 0, np.z - blast.z).normalized()
				(n as Node3D).global_position = np + Vector3(0, randf_range(0.5, 1.1), 0) + away * 0.6
				(n as Node3D).rotate(Vector3.UP.cross(away).normalized(), randf_range(0.5, 0.9))
				n.set_meta("no_audit", true)      # donmuş karede havada savrulmuş: kasıtlı
				var nr: Variant = n.get("rig")
				if nr is Rig:
					(nr as Rig).activity = "fall"
	# Savrulan son ok demeti: havada dağılan oklar
	var loose := Node3D.new()
	world.add_child(loose)
	loose.global_position = tp + Vector3(-0.2, 2.2, 0.7)
	for k in 9:
		var mi := MeshInstance3D.new()
		mi.mesh = Assault.arrow_mesh()
		loose.add_child(mi)
		mi.position = Vector3(randf_range(-0.6, 0.6), randf_range(-0.3, 0.5), randf_range(-0.4, 0.4))
		mi.rotation = Vector3(randf() * TAU, randf() * TAU, 0)
	freeze_cam = Camera3D.new()
	add_child(freeze_cam)
	freeze_cam.fov = 52.0
	freeze_cam.global_position = cam_p
	freeze_cam.look_at(STAGE + Vector3(0.9, 1.45, -0.1))
	freeze_cam.make_current()
	hud.set_fez(false)
	Vfx.explosion(world, blast, 1.0)
	Vfx.dust(world, blast, 1.3)
	Vfx.frozen_blast(world, blast, 1.0, 0.13, Vector3(cam_p.x - blast.x, 0, cam_p.z - blast.z).normalized())
	Audio.sfx("explosion_big", 2.0)
	Audio.music("", 0.0)
	await get_tree().create_timer(0.16).timeout
	# DON
	_pause_world(true)
	froze = true
	_unstack_frozen()
	Audio.sfx("stamp", 0.0)
	_overlay.visible = true
	create_tween().tween_method(func(v: float): _mat.set_shader_parameter("amount", v), 0.0, 1.0, 0.25)
	freeze_cam.fov = 48.0
	_show_caption()
	await get_tree().create_timer(0.8).timeout
	if GameState.shots_dir != "":
		hud.say("SPK_TOLGA", "D0_T_FREEZE_1")
		await _shot("c0_03_freeze", 1.2)
		get_tree().quit()
		return
	await hud.say("SPK_TOLGA", "D0_T_FREEZE_1")
	await hud.say("SPK_TOLGA", "D0_T_FREEZE_2")
	Audio.sfx("radio_static", -6.0)
	await hud.say("SPK_NIHAT", "D0_N_FREEZE")


## Kaset gibi geri sarma, beyaz ışık, garaj.
func _rewind() -> void:
	phase = "rewind"
	if _caption:
		_caption.queue_free()
	Audio.sfx("machine_spin", -2.0, 2.2)
	Audio.sfx("whoosh_fly", -4.0, 0.6)
	var tw := create_tween().set_parallel(true)
	tw.tween_method(func(v: float): _mat.set_shader_parameter("rewind", v), 0.0, 1.0, 0.4)
	tw.tween_property(freeze_cam, "global_position", freeze_cam.global_position + (freeze_cam.global_transform.basis.z * 7.0) + Vector3(0, 2.5, 0), 1.3)
	tw.tween_property(freeze_cam, "fov", 70.0, 1.3)
	await get_tree().create_timer(1.1).timeout
	await hud.fade_to(1.0, 0.3, Color.WHITE)
	_pause_world(false)
	if GameState.autotest:
		print("AUTOTEST PASS chapter=0 variant=%s froze=%s" % [GameState.autotest_variant, froze])
		if GameState.autotest_variant != "next":
			get_tree().quit(0 if froze else 1)
			return
	GameState.skip_title = true
	GameState.after_prologue = true
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/chapter1.tscn")


## Donan karenin ismi: sol altta büyük "TOLGA", altında meslek ve zaman (film açılışlarındaki karakter kartı gibi).
func _show_caption() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 6
	add_child(cl)
	_caption = Control.new()
	_caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(_caption)
	var font: Font = load(Hud.FONT_TITLE)
	var name_l := Label.new()
	name_l.text = tr("UI_CH0_NAME")
	name_l.add_theme_font_override("font", font)
	name_l.add_theme_font_size_override("font_size", 120)
	name_l.add_theme_color_override("font_color", Color("ffd24a"))
	name_l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	name_l.add_theme_constant_override("outline_size", 18)
	name_l.anchor_top = 1.0
	name_l.anchor_bottom = 1.0
	name_l.offset_left = 70
	name_l.offset_top = -430
	_caption.add_child(name_l)
	var sub := Label.new()
	sub.text = tr("UI_CH0_ROLE")
	sub.add_theme_font_override("font", font)
	sub.add_theme_font_size_override("font_size", 30)
	sub.add_theme_color_override("font_color", Color("f2e6c9"))
	sub.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	sub.add_theme_constant_override("outline_size", 10)
	sub.anchor_top = 1.0
	sub.anchor_bottom = 1.0
	sub.offset_left = 78
	sub.offset_top = -290
	_caption.add_child(sub)
	# Soldan kayarak girer
	_caption.position.x = -500.0
	create_tween().tween_property(_caption, "position:x", 0.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Dünyayı dondurur: süreçler, parçacıklar, canlandırmalar durur (arayüz ve ses çalışır).
func _pause_world(on: bool) -> void:
	world.process_mode = Node.PROCESS_MODE_DISABLED if on else Node.PROCESS_MODE_INHERIT
	for n in world.find_children("*", "GPUParticles3D", true, false):
		(n as GPUParticles3D).speed_scale = 0.0 if on else 1.0
	for n in world.find_children("*", "CPUParticles3D", true, false):
		(n as CPUParticles3D).speed_scale = 0.0 if on else 1.0


## Ekran görüntüsü kipi (--shots=klasör): akışın ana anlarını kaydeder.
func _shot(file: String, wait: float) -> void:
	if GameState.shots_dir == "":
		return
	await get_tree().create_timer(wait).timeout
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(GameState.shots_dir)
	get_viewport().get_texture().get_image().save_png(GameState.shots_dir.path_join(file + ".png"))
	print("shot: ", file)


func _capture_mouse() -> void:
	if not GameState.autotest and GameState.shots_dir == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Donan karede iç içe yakalanan askerler (merdiven kuyruğu, korkuluk atlayışı) karede öyle kalırdı: aynı yerdeki
## ikinciyi yandaki boş yere (aynı zemin yüksekliğinde) kaydır
func _unstack_frozen() -> void:
	var men: Array[Node3D] = []
	for g in ["soldiers", "persons"]:
		for n in get_tree().get_nodes_in_group(g):
			if n is Node3D and (n as Node3D).is_visible_in_tree() and not (n as Node3D).has_meta("corpse") and not men.has(n):
				men.append(n)
	for i in men.size():
		for j in range(i + 1, men.size()):
			var a := men[i].global_position
			var b := men[j].global_position
			if Vector2(a.x - b.x, a.z - b.z).length() < 0.4 and absf(a.y - b.y) < 0.6:
				var d := Vector3(b.x - a.x, 0, b.z - a.z)
				d = d.normalized() if d.length() > 0.02 else Vector3.RIGHT
				for k in 6:
					var to := b + d.rotated(Vector3.UP, k * PI / 3.0) * 0.55
					if not Unclip.crowded(men[j], to, 0.4) and not Unclip.in_solid(men[j], to, 0.17):
						var fy := Unclip.floor_y(men[j], to, 0.6, 1.0)
						if not is_nan(fy) and absf(fy - to.y) < 0.5:
							men[j].global_position = Vector3(to.x, fy, to.z)
							break
