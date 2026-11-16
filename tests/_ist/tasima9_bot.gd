extends RefCounted
## TAŞIMA-9: Bölüm 30 / 30o `=kare` ve `=yuru` kiplerinin ortak yardımcısı (bölüm dosyaları yalnız çağırır).
##   =kare: sabit kameralar (göz, bakış, görüş açısı) → --dialogshots=<klasör>/an_XX_<ad>.jpg (1280×720 jpg 85) + her anda
##          4 karenin ortalama çizim çağrısı / ilkel sayısı: "T9KARE <dosya> cizim=… ilkel=… set=…"; son satır "T9KARE BITTI"
##   =yuru: gerçek Player botu (ileri tuşu, yüzü hedefe) bacak bacak yürür; takılma (8 sn yaklaşmama), düşme (dikey hız < −7
##          ya da beklenen yüksekliğin 1 m altı) sayılır. "T9YURU bacak=…"; son satır "T9YURU OZET …"

static func _dir() -> String:
	return GameState.dialog_shots_dir if GameState.dialog_shots_dir != "" else GameState.shots_dir


## kameralar: [[ad, göz, bakış, fov], …]
static func kare(ch: Node3D, player: Player, hud: Node, kameralar: Array, set_ad: String) -> void:
	Engine.time_scale = 1.0
	if hud is CanvasLayer:
		(hud as CanvasLayer).visible = false
	if hud.has_method("set_fade"):
		hud.call("set_fade", 0.0)
	player.frozen = true
	var dir := _dir()
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
	var cam := Camera3D.new()
	cam.name = "T9Kamera"
	ch.add_child(cam)
	# dünya kurulsun, akış (uzak katman, gölgelendirici derlemesi) otursun
	for i in 30:
		await ch.get_tree().process_frame
	var n := 0
	for k: Array in kameralar:
		n += 1
		cam.fov = float(k[3])
		cam.global_position = k[1]
		cam.look_at(k[2], Vector3.UP)
		cam.make_current()
		for i in 8:
			await ch.get_tree().process_frame
		var dc := 0.0
		var pr := 0.0
		for i in 4:
			await RenderingServer.frame_post_draw
			dc += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			pr += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		var f := "an_%02d_%s.jpg" % [n, k[0]]
		if dir != "":
			ch.get_viewport().get_texture().get_image().save_jpg(dir.path_join(f), 0.85)
		print("T9KARE %s goz=%s cizim=%.0f ilkel=%.0f set=%s" % [f, (k[1] as Vector3).snapped(Vector3.ONE * 0.01), dc / 4.0, pr / 4.0, set_ad])
		if "--t9tek" in OS.get_cmdline_user_args():
			break
	print("T9KARE BITTI set=%s" % set_ad)
	ch.get_tree().quit(0)


## bacaklar: [[ad, hedef (dünya), beklenen_y (düşme ölçüsü; NAN = ölçme), (isteğe bağlı) ışınlanma noktası], …]; bas: başlangıç
static func yuru(ch: Node3D, player: Player, hud: Node, bas: Vector3, bacaklar: Array, set_ad: String) -> void:
	Engine.time_scale = 1.0
	if hud.has_method("set_fade"):
		hud.call("set_fade", 0.0)
	player.global_position = bas
	player.frozen = false
	for i in 10:
		await ch.get_tree().physics_frame
	var top := {"bacak": 0, "takilma": 0, "dusme": 0, "sure": 0.0, "yol": 0.0}
	print("T9YURU set=%s bas=%s" % [set_ad, bas])
	for b: Array in bacaklar:
		var ad: String = b[0]
		var to: Vector3 = b[1]
		var ey: float = b[2]
		if b.size() > 3:
			# bacağın başında ışınla (sur yoluna ova merdiveninden çıkılmış gibi)
			player.global_position = b[3]
			player.velocity = Vector3.ZERO
			for i in 6:
				await ch.get_tree().physics_frame
		var t := 0.0
		var yol := 0.0
		var son := player.global_position
		var takil := 0
		var dus := 0
		var best := 1e9
		var iz := 0.0
		while t < 45.0:
			player.face(Vector3(to.x, player.global_position.y + 1.4, to.z))
			Input.action_press("move_forward")
			await ch.get_tree().physics_frame
			t += ch.get_physics_process_delta_time()
			var p := player.global_position
			yol += Vector2(p.x - son.x, p.z - son.z).length()
			son = p
			if not is_nan(ey) and (player.velocity.y < -7.0 or p.y < ey - 1.0):
				dus += 1
				break
			var dd := Vector2(p.x - to.x, p.z - to.z).length()
			if dd < best - 0.3:
				best = dd
				iz = t
			if dd < 0.5:
				break
			if t - iz > 8.0:
				takil += 1
				break
		Input.action_release("move_forward")
		for k in 4:
			await ch.get_tree().physics_frame
		top["bacak"] += 1
		top["takilma"] += takil
		top["dusme"] += dus
		top["sure"] += t
		top["yol"] += yol
		print("T9YURU bacak=%s sure=%.1f yol=%.1f takilma=%d dusme=%d son=%s" % [ad, t, yol, takil, dus, player.global_position.snapped(Vector3.ONE * 0.1)])
	print("T9YURU OZET set=%s bacak=%d takilma=%d dusme=%d sure=%.1f yol=%.1f" % [set_ad, top["bacak"], top["takilma"], top["dusme"], top["sure"], top["yol"]])
	ch.get_tree().quit(0)
