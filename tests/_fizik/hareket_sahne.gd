extends Node3D
## HAREKET HİSSİ — gerçek Player ile sentetik sahnede ölçüm ve kare dizileri (oyuncu girdisi Input.action_press ile).
##   ölçüm (başsız):   godot --headless --path . res://tests/_fizik/hareket_sahne.tscn -- --is=olc
##   kareler (xvfb):   godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_fizik/hareket_sahne.tscn
##                     -- --is=kare --out=KLASÖR --on=ONCE|SONRA [--sen=kosu,donus,...]
## Satırlar: HAREKETOLC <ölçüm> <değer> … ; HAREKETKARE <senaryo> <dosya> ; son satır HAREKETOLC BITTI / HAREKETKARE BITTI.
## Senaryolar (her biri 0,1 sn arayla 6 kare): kosu (duruştan koşuya), donus (koşarken ani 90° dönüş), zipla (koşup
## zıplama + iniş), dusus3 (3,5 m'lik damdan yürüyüp düşme), merdiven (3 m merdivenin tepesinden çıkış), kenar (2,2 m
## duvara tutunup çıkma, tırmanma açık), tirman (tırmanırken nefes azalırken eller).

var pl: Player
var is_ := "olc"
var out := "user://hareket"
var on_ := "ONCE"
var sen: Array = []
var _cam_ref: Camera3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--is="):
			is_ = a.substr(5)
		elif a.begins_with("--out="):
			out = a.substr(6)
		elif a.begins_with("--on="):
			on_ = a.substr(5)
		elif a.begins_with("--sen="):
			sen = Array(a.substr(6).split(","))
	DirAccess.make_dir_recursive_absolute(out)
	_kos.call_deferred()


# ---------------------------------------------------------------- sahne

func _blok(s: Vector3, p: Vector3, c: Color, climb := true) -> StaticBody3D:
	var b := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = s
	cs.shape = bs
	b.add_child(cs)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = s
	mi.mesh = bm
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	mi.material_override = m
	b.add_child(mi)
	b.position = p
	if not climb:
		b.set_meta("no_climb", true)
	add_child(b)
	return b


func _sahne() -> void:
	# Zemin: dama tahtası (kamera hareketi karede okunsun)
	_blok(Vector3(200, 1, 200), Vector3(0, -0.5, 0), Color("6f7a5a"), false)
	for i in range(-12, 13):
		for j in range(-12, 13):
			if (i + j) % 2 == 0:
				var t := MeshInstance3D.new()
				var pm := PlaneMesh.new()
				pm.size = Vector2(2, 2)
				t.mesh = pm
				var m := StandardMaterial3D.new()
				m.albedo_color = Color("8d9670")
				t.material_override = m
				t.position = Vector3(i * 2.0, 0.005, j * 2.0)
				add_child(t)
	# Sütun sırası (yol kenarı): uzaktaki referans
	for k in 12:
		_blok(Vector3(0.6, 4.0, 0.6), Vector3(-4.0, 2.0, -k * 4.0), Color("b9a47e"), false)
		_blok(Vector3(0.6, 4.0, 0.6), Vector3(4.0, 2.0, -k * 4.0), Color("a48f6b"), false)
	# 3,5 m dam (düşüş): x = 20 tarafında
	_blok(Vector3(4, 3.5, 6), Vector3(20, 1.75, 0), Color("9c6b4e"), false)
	# 2,2 m duvar (kenara tutunma): x = -20
	_blok(Vector3(6, 2.2, 3), Vector3(-20, 1.1, -6), Color("a07a5a"))
	# 7 m duvar (tırmanma, nefes)
	_blok(Vector3(6, 7.0, 3), Vector3(-30, 3.5, -6), Color("8a7660"))
	# Merdiven: 3 m sahanlığa
	_blok(Vector3(4, 3.0, 4), Vector3(30, 1.5, -2), Color("7d6a58"), false)
	var ld := Ladder.new(3.4, 12.0)
	add_child(ld)
	ld.position = Vector3(30, 0, 0.12)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("9cc3e0")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.7, 0.7, 0.7)
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	add_child(sun)


func _kos() -> void:
	_sahne()
	pl = Player.new()
	add_child(pl)
	pl.show_remote(false)
	pl.fall_guard = false
	await _kare_bekle(10)
	if is_ == "olc":
		await _olc()
		print("HAREKETOLC BITTI")
	else:
		await _kareler()
		print("HAREKETKARE BITTI")
	get_tree().quit(0)


func _kare_bekle(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _birak() -> void:
	for a in ["move_forward", "move_back", "move_left", "move_right", "sprint", "jump", "kick", "use_item"]:
		Input.action_release(a)


func _tp(p: Vector3, yaw := 0.0, bekle := 20) -> void:
	_birak()
	if pl.traversal:
		pl.traversal.cancel()
	pl.ladder = null
	pl.global_position = p
	pl.rotation.y = yaw
	pl.camera.rotation = Vector3.ZERO
	pl.velocity = Vector3.ZERO
	await _kare_bekle(bekle)


func _zipla() -> void:
	Input.action_press("jump")
	await get_tree().physics_frame
	Input.action_release("jump")


# ---------------------------------------------------------------- ölçüm

func _olc() -> void:
	var dt := 1.0 / Engine.physics_ticks_per_second
	pl.disable_climb()
	# 1) duruştan koşuya: %90 hıza varış süresi; koşudan duruşa
	for kip in ["yuru", "kos"]:
		await _tp(Vector3(0, 0.05, 10))
		var hedef := (Player.RUN if kip == "kos" else Player.WALK) * 0.9
		if kip == "kos":
			Input.action_press("sprint")
		Input.action_press("move_forward")
		var t := 0.0
		while pl.horizontal_speed() < hedef and t < 2.0:
			await get_tree().physics_frame
			t += dt
		var fov_t := []
		for i in 60:
			await get_tree().physics_frame
			if i % 15 == 14:
				fov_t.append("%.1f" % pl.camera.fov)
		var tepe := pl.horizontal_speed()
		_birak()
		var td := 0.0
		while pl.horizontal_speed() > 0.1 and td < 2.0:
			await get_tree().physics_frame
			td += dt
		print("HAREKETOLC %s_hiz %.2f vari_sn %.2f durma_sn %.2f fov(0.25..1sn)=%s fov_dur=%.1f" % [kip, tepe, t, td, ",".join(fov_t), pl.camera.fov])
	# 2) ani dönüş: koşarken yön 90° değişir; hız yönünün yeni yöne dönme süresi, en büyük kamera yatışı
	await _tp(Vector3(0, 0.05, 10))
	Input.action_press("sprint")
	Input.action_press("move_forward")
	await _kare_bekle(40)
	var roll := 0.0
	var t2 := 0.0
	pl.rotate_y(-PI * 0.5)
	var hedef_yon := -pl.global_transform.basis.z
	while t2 < 1.0:
		await get_tree().physics_frame
		t2 += dt
		roll = maxf(roll, absf(pl.camera.rotation.z))
		var v := Vector3(pl.velocity.x, 0, pl.velocity.z).normalized()
		if v.dot(hedef_yon) > 0.97:
			break
	print("HAREKETOLC donus_sn %.2f yatis_der %.2f" % [t2, rad_to_deg(roll)])
	_birak()
	# 3) yerinde zıplama: tepe, havada kalış, inişte kamera çökmesi
	await _tp(Vector3(0, 0.05, 10))
	var y0 := pl.global_position.y
	var cam0 := pl.camera.position.y
	await _zipla()
	var tepe_y := y0
	var hava := 0.0
	await get_tree().physics_frame
	while not pl.is_on_floor() and hava < 3.0:
		await get_tree().physics_frame
		hava += dt
		tepe_y = maxf(tepe_y, pl.global_position.y)
	var cok := 0.0
	for i in 40:
		await get_tree().physics_frame
		cok = maxf(cok, cam0 - pl.camera.position.y)
	print("HAREKETOLC zipla_tepe %.3f havada_sn %.2f inis_cokme %.3f" % [tepe_y - y0, hava + dt, cok])
	# 4) coyote: kenardan yürüyüp düştükten sonra 0,08 sn içinde zıplama tutuyor mu; tampon: inişten 0,08 sn önce basılan
	await _tp(Vector3(20, 3.55, 1.0), PI)        # damın üstü, kenara (+z) dönük değil: geri geri yürür
	pl.rotation.y = 0.0
	Input.action_press("move_back")
	var kt := 0.0
	while pl.is_on_floor() and kt < 3.0:
		await get_tree().physics_frame
		kt += dt
	await _kare_bekle(4)
	await _zipla()
	await get_tree().physics_frame
	print("HAREKETOLC coyote_0.07sn vy=%.2f (zıplarsa > 0)" % pl.velocity.y)
	_birak()
	await _tp(Vector3(0, 1.2, 10))
	while pl.global_position.y > 0.32 or pl.velocity.y > 0.0:
		await get_tree().physics_frame
	await _zipla()
	var tutt := false
	for i in 20:
		await get_tree().physics_frame
		if pl.velocity.y > 1.0:
			tutt = true
	print("HAREKETOLC tampon_inis_oncesi zipladi=%s" % tutt)
	# 5) düşüşler: 1, 2,5, 3,5 m; inişte kamera çökmesi, göz hizası, sendeleme (tırmanma kapalı ve açık)
	for kip in ["kapali", "acik"]:
		if kip == "acik":
			pl.enable_climb()
		for h in [1.0, 2.5, 3.5, 6.0]:
			await _tp(Vector3(0, 0.05, 10))
			await _tp(Vector3(0, 0.05 + h, 10), 0.0, 1)
			var c0 := pl.eye_height
			var miny := 99.0
			var dus := 0.0
			while not pl.is_on_floor() and dus < 3.0:
				await get_tree().physics_frame
				dus += dt
			await get_tree().physics_frame
			var sen0 := pl._stagger
			for i in 50:
				await get_tree().physics_frame
				miny = minf(miny, pl.camera.position.y)
			print("HAREKETOLC %s dusus_%.1fm sure %.2f kamera_min %.3f goz %.2f sendeleme %.2f falls %d" % [kip, h, dus, miny, c0, sen0,
				pl.traversal.falls if pl.traversal else 0])
	pl.disable_climb()
	# 6) merdiven: 3,4 m'yi çıkış süresi
	await _tp(Vector3(30, 0.05, 1.2), 0.0)
	Input.action_press("move_forward")
	var lt := 0.0
	var tutundu := false
	while lt < 6.0:
		await get_tree().physics_frame
		lt += dt
		if pl.ladder != null:
			tutundu = true
		if tutundu and pl.ladder == null:
			break
	print("HAREKETOLC merdiven_cikis_sn %.2f y=%.2f" % [lt, pl.global_position.y])
	_birak()
	# 7) kenara tutunup çıkma (açık): 2,2 m duvar
	pl.enable_climb()
	await _tp(Vector3(-20, 0.05, -4.0), 0.0)
	await _zipla()
	var mt := 0.0
	var gordu := ""
	while mt < 3.0:
		await get_tree().physics_frame
		mt += dt
		if pl.traversal.state != "":
			gordu = pl.traversal.state
		if gordu != "" and pl.traversal.state == "":
			break
	print("HAREKETOLC kenar_cikis_sn %.2f durum=%s y=%.2f nefes=%.2f" % [mt, gordu, pl.global_position.y, pl.traversal.stamina])
	# 8) tırmanma: 7 m duvarda nefes tükenene dek (değerler aynı mı)
	await _tp(Vector3(-30, 0.05, -4.0), 0.0)
	pl.traversal.stamina = 1.0
	pl.traversal.tired = false
	await _zipla()
	await _kare_bekle(3)
	Input.action_press("move_forward")
	var ct := 0.0
	while pl.traversal.state == "climb" and ct < 12.0:
		await get_tree().physics_frame
		ct += dt
	print("HAREKETOLC tirmanma_sn %.2f durum=%s y=%.2f nefes=%.2f" % [ct, pl.traversal.state, pl.global_position.y, pl.traversal.stamina])
	_birak()
	pl.disable_climb()
	await _menzil()


## Menzil (kare hizasından bağımsız): 30 m yükseklikte dam; koşarak kenardan zıplanır, yol kalkış noktasından ölçülür
## (kalkış hizasının dh altına inene dek, ara değerli). coyote: kenardan zıplamadan çıkıp k kare sonra zıplanır, yol
## zeminden ayrılınan noktadan. ÖNCE = SONRA ve coyote ≤ kenar beklenir.
func _menzil() -> void:
	var dam := _blok(Vector3(4, 1, 20), Vector3(60, 29.5, 10), Color("9c6b4e"), false)
	for kip in ["kenar", "coyote3", "coyote6"]:
		var yollar := []
		await _tp(Vector3(60, 30.05, 12.0), 0.0)
		Input.action_press("sprint")
		Input.action_press("move_forward")
		var k0 := -1
		var z0 := 0.0
		var y0 := 0.0
		var iz: Array = []
		for i in 400:
			await get_tree().physics_frame
			var p := pl.global_position
			if k0 < 0:
				if kip == "kenar" and p.z < 1.0 and pl.is_on_floor():
					await _zipla()
					k0 = i
					z0 = p.z
					y0 = p.y
				elif kip != "kenar" and not pl.is_on_floor() and p.z < 2.0:
					k0 = i
					z0 = p.z
					y0 = p.y
			elif kip != "kenar" and i == k0 + int(kip.trim_prefix("coyote")):
				await _zipla()
			if k0 >= 0:
				iz.append(p)
			if p.y < 20.0:
				break
		var tepe_i := 0
		for j in iz.size():
			if (iz[j] as Vector3).y > (iz[tepe_i] as Vector3).y:
				tepe_i = j
		for dh in [0.0, 1.0, 2.4, 3.4, 5.8]:
			var hy: float = y0 - float(dh)
			var yol := -1.0
			for j in range(maxi(tepe_i, 1), iz.size()):
				var a: Vector3 = iz[j - 1]
				var b: Vector3 = iz[j]
				if a.y >= hy and b.y < hy:
					var f: float = (a.y - hy) / maxf(a.y - b.y, 0.0001)
					yol = z0 - lerpf(a.z, b.z, f)
					break
			yollar.append("dh%.1f=%.2f" % [dh, yol])
		print("HAREKETOLC menzil_%s %s" % [kip, " ".join(yollar)])
		_birak()
	dam.queue_free()


# ---------------------------------------------------------------- kareler

func _cek(ad: String, n := 6, ara := 0.1) -> void:
	for i in n:
		await RenderingServer.frame_post_draw
		var f := out.path_join("%s_%s_%d.jpg" % [ad, on_, i])
		get_viewport().get_texture().get_image().save_jpg(f, 0.85)
		if i < n - 1:
			await get_tree().create_timer(ara, true, true).timeout
	print("HAREKETKARE %s %s" % [ad, on_])


func _istendi(ad: String) -> bool:
	return sen.is_empty() or sen.has(ad)


func _kareler() -> void:
	pl.disable_climb()
	if _istendi("kosu"):
		await _tp(Vector3(0, 0.05, 10))
		Input.action_press("sprint")
		Input.action_press("move_forward")
		await _cek("kosu")
		await _kare_bekle(30)
		await _cek("kosu_surer")
	if _istendi("donus"):
		await _tp(Vector3(0, 0.05, 10))
		Input.action_press("sprint")
		Input.action_press("move_forward")
		await _kare_bekle(40)
		var tw := create_tween()
		tw.tween_method(func(a: float): pl.rotation.y = a, 0.0, -PI * 0.5, 0.2)
		await _cek("donus")
	if _istendi("zipla"):
		await _tp(Vector3(0, 0.05, 10))
		Input.action_press("sprint")
		Input.action_press("move_forward")
		await _kare_bekle(40)
		await _zipla()
		await get_tree().create_timer(0.35, true, true).timeout
		await _cek("zipla")
	if _istendi("dusus3"):
		await _tp(Vector3(20, 3.55, 1.0), 0.0)
		pl.rotation.y = PI          # kenara (+z) dönük
		Input.action_press("move_forward")
		while pl.is_on_floor():
			await get_tree().physics_frame
		_birak()
		await get_tree().create_timer(0.45, true, true).timeout
		await _cek("dusus3")
	if _istendi("dusus8"):
		await _tp(Vector3(0, 8.05, 10), 0.0)
		pl.camera.rotation.x = -0.35
		await get_tree().create_timer(0.3, true, true).timeout
		await _cek("dusus8", 8, 0.12)
	if _istendi("merdiven"):
		await _tp(Vector3(30, 0.05, 1.2), 0.0)
		Input.action_press("move_forward")
		while pl.ladder == null:
			await get_tree().physics_frame
		while pl.ladder != null and pl._ladder_t < pl.ladder.height - 0.85:
			await get_tree().physics_frame
		await _cek("merdiven")
	if _istendi("kenar"):
		pl.enable_climb()
		await _tp(Vector3(-20, 0.05, -4.0), 0.0)
		await _zipla()
		await _cek("kenar", 6, 0.08)
		pl.disable_climb()
	if _istendi("tirman"):
		pl.enable_climb()
		await _tp(Vector3(-30, 0.05, -4.0), 0.0)
		pl.traversal.stamina = 0.3
		await _zipla()
		await _kare_bekle(3)
		Input.action_press("move_forward")
		await get_tree().create_timer(0.3, true, true).timeout
		await _cek("tirman")
		_birak()
		pl.disable_climb()
	_birak()
