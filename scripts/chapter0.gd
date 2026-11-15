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
##   --chapter=0 --autotest[=next|yuru|kare]   (next: bittiğinde Bölüm 1'e geçer; yuru: gerçek Player botu START → LINE;
##                                            kare: oyuncu kamerasından altı an + bütçe)
##   --eskisur[=0]   eski set (LandWalls) — geri dönüş anahtarı (karar 13); anahtarsız: yeni İstanbul kara suru,
##                   Mesoteikhion kesimi (SurSetSahne + bölüm bağdaştırıcısı SurSet; docs/SUR_SOZLESME.md)

const BattleExtras := preload("res://scripts/level/battle_extras.gd")
const TOLGA := {"face": "tolga", "coat": Color("23262d"), "pants": Color("23262d"), "hat": "fez", "skin": Color("e6ad88")}
const START := Vector3(7.0, 0.05, 4.0)
## Ok demetlerinin götürüleceği savunucu sırası (gediğin içi)
const LINE := Vector3(-0.6, 0.0, 11.4)
## Donan karede Tolga'nın (havadaki) yeri: gedik önündeki açık peribolos
const STAGE := Vector3(3.0, 0.0, 8.6)
## Yeni set (TAŞIMA-3): gediğin SAĞINDA iç kule peribolosa taşar (x −2,8…12,2, z ≤ 8): eski START (7; 4) kulenin içine düşer.
## Depo ve taşıyıcı şeridi gediğin solunda (SurSet.depo). Koşu yine depo yanından gediğe, peribolosu çaprazlama: START
## deponun önü, LINE gediğin önündeki savunucu sırası (barikatın toprak setinin kutusu z 12,0–13,2: sıra onun şehir yanında).
## START → LINE 10,1 m (eski 10,6). Donan kare gediğin solunda, aynalı (kamera peribolos boyunca −x'e bakar): eski kadrajın
## sağında iç kule kadrajı kapatırdı.
const START_YENI := Vector3(-8.6, 0.05, 4.4)
const LINE_YENI := Vector3(-0.6, 0.0, 10.6)
const STAGE_YENI := Vector3(-3.0, 0.0, 8.6)
const GIUST_YENI := Vector3(-4.6, 0.0, 11.0)
## Savunucu sırası (6 kişi): işçilerin (barikatın dibi, x ±2,4 z 11,3) önünde ve aralarında, taşıyıcıların varış yerini
## (gedik önü, x 0, z 10,4) açık bırakarak; işçilere ≥ 1,1 m (ilk denemede x −2,3: VISAUDIT overlap … WallFight{hammer})
const SAVUNUCU_YENI := [Vector3(-4.3, 0, 10.8), Vector3(-3.2, 0, 10.4), Vector3(-1.3, 0, 10.8), Vector3(1.3, 0, 10.8),
	Vector3(3.3, 0, 10.5), Vector3(2.4, 0, 10.1)]
## Bölüm sabiti: true → eski set (geri dönüş; komut satırında --eskisur ile de)
const ESKI_SUR := false

## Bölüm bağdaştırıcısı: sette yer soran her şey buradan (eski: LandWalls sabitleri; yeni: SurOyun sorguları)
var sur: SurSet
var start_p := START
var line_p := LINE
var stage_p := STAGE
## Donan karenin yönü: eski +x (kamera gediğin solunda, sağa bakar), yeni −x (aynalı)
var _ayna := 1.0

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
var _place_tw: Tween
## Yer/tarih yazısının yazılış süresi (sn). 1,4 iken bot/PACE koşusunda (yazı 1,7-2,0 sn'de söner) tam yazıldıktan sonra
## ekranda 1,6-1,9 sn kalıyordu; 0,8 ile en az 2,0 sn (ölçüm: PLACE_OUT).
const PLACE_WRITE := 0.8
var _place_age := -1.0       # yazı başladığından beri oyun zamanı (sn); -1 = başlamadı
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
	var t_kur := Time.get_ticks_usec()
	sur = SurSet.sec("0", ESKI_SUR)
	if sur.eski_mi:
		walls = LandWalls.new()
	else:
		var ss := SurSetSahne.new()
		ss.sur = sur
		walls = ss
		start_p = START_YENI
		line_p = LINE_YENI
		stage_p = STAGE_YENI
		_ayna = -1.0
	walls.assault_mode = true
	world.add_child(walls)
	walls.set_repair(LandWalls.STAGES - 2)
	walls.auto_cover = false
	var t_set := Time.get_ticks_usec()
	_build()
	_build_overlay()
	if GameState.autotest:
		# kurulum ölçümü (karar 12; oyunun ilk dakikası): set (sur + ova + dekor) ve bölümün kendi kurulumu
		print("TASIMA0KURULUM sur=%s set_ms=%.0f bolum_ms=%.0f toplam_ms=%.0f" % ["eski" if sur.eski_mi else "yeni",
			(t_set - t_kur) / 1000.0, (Time.get_ticks_usec() - t_set) / 1000.0, (Time.get_ticks_usec() - t_kur) / 1000.0])
	if GameState.autotest and GameState.autotest_variant in ["yuru", "kare"]:
		_yuru()
		return
	if GameState.autotest:
		Engine.time_scale = 2.5
	_run()


func _build() -> void:
	giust = Person.new({"face": "giustiniani", "coat": Color("8a8e96"), "pants": Color("3a3a40"), "hat": "condottiero",
		"beard": true, "skin": Color("e0b08a")})
	giust.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-4.2, 0, -3.0)) if sur.eski_mi else sur.on_rubble(GIUST_YENI)
	world.add_child(giust)
	giust.look_target = player
	for i in 6:
		var d := Person.new({"coat": [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96")][i % 3], "pants": Color("3a2a22"), "hat": "helm",
			"beard": i % 2 == 0, "mustache": true, "n": 40 + i})
		d.set_meta("no_talk", true)
		d.set_meta("spk", "SPK_DEFENDER")       # "Oklar!": kartta en yakın savunucu
		# Barikatın arkasında (tabyanın içinde değil)
		d.position = LandWalls.on_rubble(LandWalls.BREACH + Vector3(-3.2 + i * 1.3, 0, -2.7 - (i % 2) * 0.35)) if sur.eski_mi \
			else sur.on_rubble(SAVUNUCU_YENI[i])
		if not sur.eski_mi:
			d.set_meta("no_yield", true)       # yerinde durur: gelen taşıyıcı onu barikata itmesin (tasima2 2a'nın aynısı)
		world.add_child(d)
	# Surun önü: sancaklı ordu, sura koşan dalgalar, merdivenler, bataryalar, surda savunanlar, ok yağmuru
	assault = Assault.new()
	assault.sur = sur
	# yeni sette ordu ova kaydırmasıyla aynı yerde dursun: alan hendeğin uzak yakasına kadar (eski 36 ↔ yeni ova_z0)
	assault.keep = Rect2(-40.0, -10.0, 80.0, 36.0) if sur.eski_mi else Rect2(-40.0, -10.0, 80.0, 36.0 + sur.ova_ofs().z)
	assault.live_span = 30.0
	world.add_child(assault)
	assault.build()
	# Sur yolu dolu, iç surun üstü de (Bölüm 26 gibi)
	Garrison.land_walls(world, [Vector2(13.0, 19.0), Vector2(-10.4, -6.8), Vector2(6.8, 10.4)], [Vector2(-30.0, 30.0)], [], 26, 46.0, true, true, true, sur)
	var fight := WallFight.new()
	fight.sur = sur
	world.add_child(fight)
	for sx: float in [-1.0, 1.0]:
		fight.add_cauldron(Vector3(sx * 8.6, sur.dis_yol_y(), sur.dis_yol_z()), 2640 + int(sx))
	if sur.eski_mi:
		fight.add_carriers(LandWalls.DEPOT + Vector3(-2.6, 0, 2.6), LandWalls.BREACH + Vector3(0, 0, -3.4), 4, 2650)
		fight.add_builders(LandWalls.BREACH + Vector3(0, 0, -2.6), 2, 2660)
		Garrison.squad(world, Vector3(-18.0, 0, 8.0), 5, 2, 0.0, 2610, "spear_shield", true)
		Garrison.squad(world, Vector3(22.5, 0, 9.0), 4, 2, 0.0, 2620, "spear_shield", true)
	else:
		# Bölüm 20'nin yeni yerleşimi: taşıyıcılar depodan (gediğin solu) gedik önünün 0,4 m gerisine, işçiler barikatın dibinde
		# (gedik önü + 1,1), iş başındaki işçi itilmez (taşıyıcı kalabalığı onu barikatın kutusuna itiyordu; tasima2 2a)
		fight.add_carriers(sur.depo() + Vector3(-2.6, 0, 2.6), sur.gedik_onu() + Vector3(0, 0, -0.4), 4, 2650)
		fight.add_builders(sur.gedik_onu() + Vector3(0, 0, 1.1), 2, 2660)
		for c in fight.get_children():
			if c is Person and String((c as Person).activity) in ["hammer", "chop"]:
				c.set_meta("no_yield", true)
		# yedek bölükler: sol ateş halkasının önü ve iç kulenin ötesi (eski −18 / 22,5; kule x −2,8…12,2 z ≤ 8)
		Garrison.squad(world, Vector3(-20.0, 0, 7.6), 5, 2, 0.0, 2610, "spear_shield", true)
		Garrison.squad(world, Vector3(22.5, 0, 9.0), 4, 2, 0.0, 2620, "spear_shield", true)
	# Gerçek savaş: kalkanını başına kaldırıp koşanlar, ok yiyip devrilenler, yerde oklanmış yatanlar, gedikte
	# kalkan kalkana duranlar (oyuncunun yolunu kesmeyen şeritlerde)
	# (Arka şerit depoda biter: eskiden depoyu, toprak yığınını ve fıçıları içinden geçerek kesiyordu.)
	var lanes: Array = [[Vector3(-17.5, 0, 2.4), Vector3(3.0, 0, 2.4), 1.4, 11, 5, 0], [Vector3(6.5, 0, 12.6), Vector3(26, 0, 12.6), 1.2, 6, 3, 0],
			[Vector3(-26, 0, 12.6), Vector3(-6.5, 0, 12.6), 1.2, 6, 3, 0], [START + Vector3(-2.2, 0, 3.0), LINE + Vector3(2.4, 0, -3.0), 3.0, 0, 4, 0]]
	if not sur.eski_mi:
		# yeni peribolos (z 2,4–10,6; sur dibi etekleri dışında): arka şerit deponun solunda biter (iç kulenin ve deponun
		# içinden geçmesin), sur boyu şeritler dış surun eteğinin önünde (z 9,8), ok yolunun yanındaki yaralılar koşu
		# çizgisinin sol yanında (eskideki gibi)
		lanes = [[Vector3(-25.0, 0, 3.4), Vector3(-15.6, 0, 3.4), 1.4, 11, 5, 0], [Vector3(8.4, 0, 9.8), Vector3(26, 0, 9.8), 1.2, 6, 3, 0],
			[Vector3(-26, 0, 9.8), Vector3(-10.5, 0, 9.8), 1.2, 6, 3, 0], [Vector3(-5.6, 0, 4.6), Vector3(-3.6, 0, 6.4), 1.4, 0, 4, 0]]
	for lane: Array in lanes:
		var bx := BattleExtras.new()
		world.add_child(bx)
		bx.assault = assault
		bx.hit_every = 1.8
		bx.populate(lane[0], lane[1], lane[2], lane[3], lane[4], lane[5], 3100 + int(lane[0].x))
	# Sur içi kargaşa (Bölüm 26'daki gibi): koşuşan yedekler, kaçan halk, yaralısının başına çökenler. Oyuncunun ok taşıdığı
	# yol (başlangıç → gedik hattı), gediğin arkası, depo ve merdiven ayakları boş kalır.
	var chaos := SiegeChaos.new()
	chaos.player = player
	chaos.area = Rect2(-44.0, 1.4, 88.0, 10.6) if sur.eski_mi else sur.peribolos()
	chaos.static_clear_x = 12.0
	chaos.bells = true
	chaos.seed = 29
	chaos.avoid = [[Vector3(0, 0, 14.0), 5.4], [sur.depo(), 3.0], [Vector3(-8.0, 0, 12.2), 1.8], [Vector3(8.0, 0, 12.2), 1.8],
		[start_p, 2.0], [line_p, 2.4], [stage_p, 2.2]]
	chaos.avoid_lines = [[start_p, line_p, 1.6]]
	if not sur.eski_mi:
		chaos.avoid += sur.peribolos_engelleri()
		for m: Vector3 in sur.siperler():
			chaos.avoid.append([m + Vector3(0, 0, 0.6), 2.0])
		chaos.avoid_lines.append([sur.depo(), sur.gedik_onu(), 1.6])        # taşıyıcı şeridi
		chaos.avoid.append([stage_p + Vector3(-5.8, 0, 1.3), 2.4])           # donan karenin patlama yeri
	world.add_child(chaos)
	if GameState.autotest and not sur.eski_mi:
		# yerleşim denetimi: set noktaları SurOyun.engeller()'in (kule + etek, merdiven, sur gövdesi, poterna…) dışında mı
		var noktalar := {"start": start_p, "line": line_p, "stage": stage_p, "giust": GIUST_YENI, "patlama": stage_p + Vector3(-5.8, 0, 1.3),
			"kamera": stage_p + Vector3(4.2, 0, 0.9), "yarali0": Vector3(-5.6, 0, 4.6), "yarali1": Vector3(-3.6, 0, 6.4), "bolük0": Vector3(-20.0, 0, 7.6), "bolük1": Vector3(22.5, 0, 9.0)}
		for i in SAVUNUCU_YENI.size():
			noktalar["savunucu%d" % i] = SAVUNUCU_YENI[i]
		var kotu := 0
		for ad: String in noktalar:
			if sur.engelde(noktalar[ad]):
				kotu += 1
				print("TASIMA0ENGEL %s %s" % [ad, noktalar[ad]])
		print("TASIMA0ENGEL OZET nokta=%d engelde=%d" % [noktalar.size(), kotu])
	# Başın üstünde kalkan (birinci şahıs: ekranın üst solunda, alttan görünür)
	var sh := Node3D.new()
	sh.position = Vector3(-0.44, 0.34, -0.78)
	sh.rotation = Vector3(-1.05, 0.0, 0.35)
	sh.scale = Vector3.ONE * 0.75
	player.camera.add_child(sh)
	player.free_hold = sh.position + Vector3(0.08, -0.2, 0.12)       # sol el kalkanı başın üstünde tutar (havada duruyordu)
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
	player.global_position = start_p
	player.face(line_p + Vector3(0, 1.4, 0))
	player.show_remote(false)
	_capture_mouse()
	Audio.music("tension", 0.0)
	Audio.ambience("amb_wall_night")
	Audio.sfx("cannon", -2.0)
	await hud.fade_to(0.0, 0.8)
	_place.text = tr("UI_CH0_PLACE")
	_place_age = 0.0
	_place_tw = create_tween()
	_place_tw.tween_property(_place, "visible_ratio", 1.0, PLACE_WRITE)
	_place_tw.tween_interval(3.2)      # yazılış 0,6 sn kısaldı; toplam süre (4,5 sn) aynı
	_place_tw.tween_property(_place, "modulate:a", 0.0, 0.5)
	phase = "run"
	player.frozen = false
	# Yeni oyuncunun ilk saniyeleri (oyun testi: "ne yapacağımız anlaşılmıyor"): kontrol önce gösterilir, ilk söz
	# görevi söyleyen Giustiniani'nin; gözcünün "Davul sesi!" bağırışı arkadan gelir (önceden sıra tersti, talimat
	# 3,4 sn gecikiyordu). Kontroller (Bölüm 1'de vardı, ilk sahnede yoktu) teslime ya da 15 sn'ye kadar kalır.
	hud.show_controls(true, "UI_CONTROLS_CH0")
	_first_step_hint()
	hud.set_objective(tr("UI_OBJ0_ARROWS"), line_p + Vector3(0, 1.4, 0))
	hud.bark("SPK_GIUST", "D0_G_ARROWS", 5.0)
	get_tree().create_timer(5.4, false).timeout.connect(func():
		if phase == "run":
			hud.bark("SPK_LOOKOUT", "D26_L_WAVE_1", 3.2))
	_nudge()
	await _shot("c0_01_run", 0.8)
	if GameState.autotest or GameState.shots_dir != "":
		player.global_position = line_p + Vector3(0.8, 0.05, -2.0)
	while phase == "run":
		await get_tree().process_frame
	hud.show_controls(false)
	await _hit()
	await _freeze()
	await _rewind()


## Köşedeki kontrol satırı ilk kez oynayana küçük kalıyordu: ilk adıma (2 m) ya da 10 sn'ye kadar ekranın ortasında da durur
func _first_step_hint() -> void:
	# Yer yazısı ("29 Mayıs 1453 · gece 01.30") kaybolana kadar bekler: ortadaki ipucu onun üstüne biniyordu
	var w := 0.0
	while _place.modulate.a > 0.05 and w < 6.0 and player.global_position.distance_to(start_p) < 2.0:
		await get_tree().process_frame
		w += get_process_delta_time()
	if phase != "run" or player.global_position.distance_to(start_p) >= 2.0:
		return
	hud.set_qte(GameState.tr_pad("UI_CONTROLS_CH0"))
	var t := 0.0
	while phase == "run" and t < 10.0 and player.global_position.distance_to(start_p) < 2.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	hud.set_qte("")


## Oyuncu okçulara yaklaşmıyorsa (durdu ya da yanlış yöne gitti) Giustiniani talimatı yineler; ilk 12 sn'den sonra,
## en çok iki kez, aralarında 10 sn
func _nudge() -> void:
	var best := INF
	var said := 0
	var t := 0.0
	var last_say := 0.0
	while phase == "run" and said < 2:
		await get_tree().create_timer(1.0, false).timeout
		t += 1.0
		var d := Vector2(player.global_position.x - line_p.x, player.global_position.z - line_p.z).length()
		if d < best - 1.0:
			best = d
			last_say = maxf(last_say, t - 6.0)      # yaklaşıyorsa sabır süresi baştan
		if t >= 12.0 and t - last_say >= 10.0 and phase == "run" and not hud.line_open:
			hud.bark("SPK_GIUST", "D0_G_ARROWS", 5.0)
			last_say = t
			said += 1


func _process(delta: float) -> void:
	if _place_age >= 0.0:
		_place_age += delta
	if phase != "run":
		return
	# Oklar oyuncunun çevresine yağar (üstüne değil: yakınına saplanır)
	_volley_t -= delta
	if _volley_t <= 0.0:
		_volley_t = randf_range(2.2, 3.4)
		var p := player.global_position + Vector3(randf_range(-5, 5), 0, randf_range(1.5, 6.0))
		assault.volley(Vector3(p.x, 0, p.z), 3.5, 18, true)
		Audio.sfx("whoosh_fly", -14.0, 1.4)
	var d := Vector2(player.global_position.x - line_p.x, player.global_position.z - line_p.z).length()
	if d < 3.0:
		phase = "delivered"


## Oklar verilir; gözcü bağırır, herkes siper alır; büyük top; gülle arkaya düşer.
func _hit() -> void:
	player.frozen = true
	hud.set_objective("")
	if _carry:
		# Demetler gedikteki savunucuya uzatılır: kolun altından onun göğsüne gider (eskiden elden siliniyordu)
		var who := hud.find_speaker("SPK_DEFENDER")
		var to := player.camera.global_position - player.camera.global_basis.z * 1.3 + Vector3(0, -0.45, 0)
		if who and who.global_position.distance_to(player.global_position) < 6.0:
			to = who.global_position + Vector3(0, 1.1, 0)
		var xf := _carry.global_transform
		_carry.get_parent().remove_child(_carry)
		add_child(_carry)
		_carry.global_transform = xf
		player.hand_gesture("reach")
		var ht := _carry.create_tween()
		ht.tween_property(_carry, "global_position", to, 0.05 if Stage.fast() else 0.4).set_trans(Tween.TRANS_SINE)
		ht.tween_callback(_carry.queue_free)
		_carry = null
	Audio.sfx("land_thud", -10.0)
	hud.bark("SPK_DEFENDER", "D0_S_ARROWS", 2.0)
	await get_tree().create_timer(1.6, false).timeout
	hud.bark("SPK_LOOKOUT", "D20_L_WARN_2", 2.4, true)      # gözcü topu görür, askerin sözünü keser: bağırış toptan önce
	_place_out()
	walls.fire_flash()
	BattleExtras.all_take_cover(world, [])
	Audio.sfx("cannon", 0.0, 0.8)
	# Top surun ardında: gökyüzü turuncu parlar, yer sarsılır
	player.face(sur.gedik() + Vector3(0, 16.0, 40.0))
	player.shake(0.8)
	hud.set_fade(0.45, Color("ffb45a"))
	hud.fade_to(0.0, 0.5, Color("ffb45a"))
	await _shot("c0_02_gun", 0.25)
	await get_tree().create_timer(1.4, false).timeout


## Kare donar: Tolga havada, arkasında patlama; renk solar; isim yazısı; Tolga seyirciye konuşur; Nihat araya girer.
func _freeze() -> void:
	phase = "freeze"
	# Sabit kadraj (oyuncunun durduğu yerden bağımsız): peribolos boyunca bakılır; solda dış sur ve gedik, sağda iç sur,
	# Tolga ortada havada ve kameraya doğru savrulmuş, patlama arkasında (sur koridorunun derinliğinde)
	var tp := stage_p + Vector3(0, 0.6, 0)
	var eye := tp + Vector3(0, 1.2, 0)
	var cam_p := stage_p + Vector3(-4.2 * _ayna, 1.55, 0.9)
	var blast := stage_p + Vector3(5.8 * _ayna, 0.2, 1.3)
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
		player.free_hold = Vector3.INF
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
	freeze_cam.look_at(stage_p + Vector3(0.9 * _ayna, 1.45, -0.1))
	freeze_cam.make_current()
	hud.set_fez(false)
	Vfx.explosion(world, blast, 1.0)
	Vfx.dust(world, blast, 1.3)
	Vfx.frozen_blast(world, blast, 1.0, 0.13, Vector3(cam_p.x - blast.x, 0, cam_p.z - blast.z).normalized())
	Audio.sfx("explosion_big", 2.0)
	Audio.music("", 0.0)
	await get_tree().create_timer(0.16, false).timeout
	# DON: dünya durur, ağızdaki söz de yarıda donar (sonraki replik onu beklemesin)
	hud.cut_voice(0.02)
	_pause_world(true)
	player.gravity_on = false      # dünya DISABLED: zemin çarpışmaları kapandı, donmuş oyuncu boşluğa düşmesin
	player.velocity = Vector3.ZERO
	froze = true
	_unstack_frozen()
	Audio.sfx("stamp", 0.0)
	_overlay.visible = true
	create_tween().tween_method(func(v: float): _mat.set_shader_parameter("amount", v), 0.0, 1.0, 0.25)
	freeze_cam.fov = 48.0
	_show_caption()
	await get_tree().create_timer(0.8, false).timeout
	if _kare_on:
		hud.say("SPK_TOLGA", "D0_T_FREEZE_1")
		await _kare("donma")
		print("TASIMA0KARE BITTI")
		get_tree().quit(0)
		return
	if GameState.shots_dir != "":
		hud.say("SPK_TOLGA", "D0_T_FREEZE_1")
		await _shot("c0_03_freeze", 1.2)
		get_tree().quit()
		return
	await hud.say("SPK_TOLGA", "D0_T_FREEZE_1")
	await hud.say("SPK_TOLGA", "D0_T_FREEZE_2")
	Audio.sfx("radio_static", -6.0)
	await hud.say("SPK_NIHAT", "D0_N_FREEZE")


## Yer/tarih yazısı en geç top ateşlenirken söner. Kendi süresi (yazılış 1,4 + bekleme 2,6 + sönme 0,5 sn) oyun
## zamanıyla sayar ve akıştan habersizdi: koşan oyuncu (5,2 m/sn, çizgiye ~2 sn) ya da test botu (ışınlanır; 2,5-4x
## hızda) çizgiye 4,5 sn dolmadan vardığında yazı vuruşun, patlamanın ve donan karenin ("TOLGA" kartı) üstünde
## kalıyordu (fragmanın kanca çekimi yazıyla açılıyordu). Artık bitiş akışa bağlı: süre dolmadıysa burada hızlıca söner.
func _place_out() -> void:
	if _place_tw and _place_tw.is_valid():
		_place_tw.kill()
	if _place.modulate.a <= 0.0:
		return
	# Yazı tam yazıldıktan (PLACE_WRITE) en az 2,0 sn ekranda kalır; ama patlamadan (top ateşinden 1,56 sn sonra) 0,26 sn
	# önce sönmüş olur: bekleme en çok 1,0 sn. Yürüyen oyuncuda bekleme 0 (eski süre), koşanda ~0,3 sn.
	var hold := clampf(PLACE_WRITE + 2.0 - _place_age, 0.0, 1.0) if _place_age >= 0.0 else 0.0
	_place_tw = create_tween()
	if hold > 0.0:
		_place_tw.tween_interval(hold)
	_place_tw.tween_property(_place, "modulate:a", 0.0, 0.3)


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
	await get_tree().create_timer(1.1, false).timeout
	await hud.fade_to(1.0, 0.3, Color.WHITE)
	_pause_world(false)
	player.gravity_on = true
	if GameState.autotest:
		print("AUTOTEST PASS chapter=0 variant=%s froze=%s sur=%s" % [GameState.autotest_variant, froze, "eski" if sur.eski_mi else "yeni"])
		if GameState.autotest_variant != "next":
			get_tree().quit(0 if froze else 1)
			return
	GameState.skip_title = true
	GameState.after_prologue = true
	Engine.time_scale = 1.0
	GameState.change_scene("res://scenes/chapter1.tscn", false)


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
	if _kare_on:
		await get_tree().create_timer(wait, false).timeout
		await _kare(file.substr(6))
		return
	if GameState.shots_dir == "":
		return
	await get_tree().create_timer(wait, false).timeout
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


# ================================================================ yürüyüş ve kare kanıtı (=yuru, =kare; TAŞIMA-3)

## =yuru: gerçek Player botu bölümün tek bacağını yürür: START → savunucu sırası (LINE'a 3 m: teslim). İleri tuşu basılı,
## yön her karede hedefe; takılma (8 sn yaklaşmama), düşme (dikey hız < −7) sayılır. Oklar oyuncunun çevresine yağar (akış
## aynı). Satır: TASIMA0YURU bacak=… ; son satır TASIMA0YURU OZET …
## =kare: oyuncunun kamerasından altı an (--dialogshots klasörüne an_XX_*.jpg) ve her anda 10 karenin ortalama çizim çağrısı /
## ilkel sayısı: açılış (yer yazısı, hedef), koşunun ortası, savunucu sırası (teslim), sabit bakış (iki sette AYNI kamera:
## bütçe), top (gözcü bağırışı + namlu parlaması), donan kare. Bacaklar ışınlanır (yazılımsal GL'de yürüyüş saatler sürer).
var _kare_on := false
var _kare_n := 0

func _yuru() -> void:
	_kare_on = GameState.autotest_variant == "kare"
	Engine.time_scale = 1.0
	hud.set_fade(0.0)
	player.global_position = start_p
	player.face(line_p + Vector3(0, 1.4, 0))
	player.show_remote(false)
	hud.set_objective(tr("UI_OBJ0_ARROWS"), line_p + Vector3(0, 1.4, 0))
	for i in 10:
		await get_tree().physics_frame
	var mes := Vector2(line_p.x - start_p.x, line_p.z - start_p.z).length()
	print("TASIMA0YURU set=%s start=%s line=%s stage=%s mesafe=%.1f teslim_mesafe=%.1f" % ["eski" if sur.eski_mi else "yeni", start_p, line_p,
		stage_p, mes, mes - 3.0])
	if _kare_on:
		_place.text = tr("UI_CH0_PLACE")
		_place.visible_ratio = 1.0
		await _kare("acilis")
		_place.visible_ratio = 0.0
		player.global_position = start_p.lerp(line_p, 0.5) + Vector3(0, 0.05, 0)
		player.face(line_p + Vector3(0, 1.4, 0))
		await _kare("kosu_orta")
		player.global_position = line_p + Vector3(0.8, 0.05, -2.0)
		player.face(line_p + Vector3(0, 1.3, 0.6))
		await _kare("teslim_savunucular")
		# bütçe: iki sette aynı kamera (peribolosun ortası, gediğe ve dış sura bakış)
		player.global_position = Vector3(-6.0, 0.05, 6.0)
		player.face(Vector3(0.0, 2.5, 14.0))
		await _kare("sabit_bakis")
		player.global_position = line_p + Vector3(0.8, 0.05, -2.0)
		player.face(line_p + Vector3(0, 1.3, 0))
		phase = "delivered"
		await _hit()                 # içinde "top" karesi (_shot → _kare)
		await _freeze()              # "donma" karesinden sonra çıkar
		return
	phase = "run"
	player.frozen = false
	var t := 0.0
	var yol := 0.0
	var son := player.global_position
	var takil := 0
	var dus := 0
	var best := 1e9
	var iz := 0.0
	while phase == "run" and t < 60.0:
		player.face(Vector3(line_p.x, player.global_position.y + 1.4, line_p.z))
		Input.action_press("move_forward")
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		var p := player.global_position
		yol += Vector2(p.x - son.x, p.z - son.z).length()
		son = p
		if player.velocity.y < -7.0:
			dus += 1
		var dd := Vector2(p.x - line_p.x, p.z - line_p.z).length()
		if dd < best - 0.3:
			best = dd
			iz = t
		if t - iz > 8.0:
			takil += 1
			break
	Input.action_release("move_forward")
	print("TASIMA0YURU bacak=start_line sure=%.1f yol=%.1f takilma=%d dusme=%d teslim=%s son=%s" % [t, yol, takil, dus,
		"tamam" if phase == "delivered" else "YOK", player.global_position.snapped(Vector3.ONE * 0.1)])
	print("TASIMA0YURU OZET set=%s bacak=1 takilma=%d dusme=%d teslim=%s sure=%.1f yol=%.1f" % ["eski" if sur.eski_mi else "yeni",
		takil, dus, "tamam" if phase == "delivered" else "YOK", t, yol])
	get_tree().quit(0)


func _kare(ad: String) -> void:
	var dir := GameState.dialog_shots_dir if GameState.dialog_shots_dir != "" else GameState.shots_dir
	if dir == "":
		return
	DirAccess.make_dir_recursive_absolute(dir)
	for k in 12:
		await get_tree().process_frame
	var dc := 0.0
	var pr := 0.0
	for k in 10:
		await RenderingServer.frame_post_draw
		dc += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		pr += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	_kare_n += 1
	var f := dir.path_join("an_%02d_%s.jpg" % [_kare_n, ad])
	get_viewport().get_texture().get_image().save_jpg(f, 0.85)
	var cam := get_viewport().get_camera_3d()
	print("TASIMA0KARE %s kamera=%s cizim=%.0f ilkel=%.0f sur=%s" % [f.get_file(), cam.global_position.snapped(Vector3.ONE * 0.1) if cam else Vector3.ZERO,
		dc / 10.0, pr / 10.0, "eski" if sur.eski_mi else "yeni"])
