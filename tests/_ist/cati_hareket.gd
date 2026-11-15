extends Node3D
## ÇATI ROTASI — oyuncunun bugünkü hareketini ölçer (gerçek Player, sentetik düz zemin + bloklar; başsız).
##   timeout 600 godot --headless --path . res://tests/_ist/cati_hareket.tscn [-- --kip=kapali|acik]
## Her ölçüm iki kipte: can_climb KAPALI (şehrin çoğu bölümü) ve AÇIK (Traversal: 6, 10g, 24, 31o, 37o, 39o).
## Satırlar: CATIOLC <kip> <ölçüm> <değer> … ; son satır CATIOLC BITTI.
## Bot girdisi gerçek oyuncu girdisi gibi: move_forward + sprint basılı; zıplama Input.action_press("jump") (bir kare).

var pl: Player
var kip := "kapali"
var _govdeler: Array = []


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--kip="):
			kip = a.substr(6)
	_kos.call_deferred()


func _kos() -> void:
	var zemin := _blok(Vector3(400, 1, 400), Vector3(0, -0.5, 0))
	zemin.set_meta("kalici", true)
	pl = Player.new()
	add_child(pl)
	pl.show_remote(false)
	pl.fall_guard = false
	var cam := Camera3D.new()
	add_child(cam)
	for k in (["kapali", "acik"] if kip == "ikisi" else [kip]):
		if k == "acik":
			pl.enable_climb()
		else:
			pl.disable_climb()
		await _olc(k)
	print("CATIOLC BITTI")
	get_tree().quit(0)


func _olc(k: String) -> void:
	# 1) zıplama tepesi (yerinde)
	_temizle()
	await _tp(Vector3(0, 0.05, 0))
	var y0 := pl.global_position.y
	var tepe := y0
	_zipla()
	for i in 90:
		await get_tree().physics_frame
		tepe = maxf(tepe, pl.global_position.y)
	print("CATIOLC %s zipla_tepe %.2f" % [k, tepe - y0])
	# 2) yürüyerek çıkılan basamak (zıplamadan) ve 3) zıplayarak çıkılan en yüksek basamak (koşarak)
	var yur := 0.0
	for hh in range(10, 80, 2):
		var h := hh / 100.0
		if await _basamak(h, false, false):
			yur = h
		else:
			break
	print("CATIOLC %s yuruyerek_basamak %.2f" % [k, yur])
	var zip := 0.0
	for hh in range(40, 260, 5):
		var h := hh / 100.0
		if await _basamak(h, true, true):
			zip = h
		elif h > zip + 0.3:
			break
	print("CATIOLC %s zipla_basamak_kosarak %.2f" % [k, zip])
	# 4) düz zeminde koşarak atlama: en uzun aralık (kenardan zıplar)
	var en := 0.0
	for gg in range(10, 60, 1):
		var g := gg / 10.0
		if await _aralik(g, 0.0):
			en = g
		elif g > en + 0.4:
			break
	print("CATIOLC %s kosu_atlama_aralik %.1f" % [k, en])
	# 4b) yürüyerek (koşmadan) atlama
	var enw := 0.0
	for gg in range(5, 50, 1):
		var g := gg / 10.0
		if await _aralik(g, 0.0, false):
			enw = g
		elif g > enw + 0.4:
			break
	print("CATIOLC %s yuru_atlama_aralik %.1f" % [k, enw])
	# 5) aşağı atlama: kot farkı dh (alçak karşı yaka) için en uzun yatay aralık
	for dh: float in [1.0, 2.4, 3.4, 5.8]:
		var ea := 0.0
		for gg in range(10, 90, 2):
			var g := gg / 10.0
			if await _aralik(g, -dh):
				ea = g
			elif g > ea + 0.6:
				break
		print("CATIOLC %s asagi_atlama dh=%.1f aralik %.1f" % [k, dh, ea])
	# 5b) yukarı atlama: karşı yaka dh yüksekte
	for dh: float in [0.3, 0.5, 0.6]:
		var ey := 0.0
		for gg in range(5, 50, 1):
			var g := gg / 10.0
			if await _aralik(g, dh):
				ey = g
			elif g > ey + 0.4:
				break
		print("CATIOLC %s yukari_atlama dh=%.1f aralik %.1f" % [k, dh, ey])
	# 6) eğim: durulabilen (10 sn'de kaymayan) ve yürünerek çıkılan en dik eğim
	var dur := 0.0
	var cik := 0.0
	for a in range(10, 62, 2):
		var r := await _egim(float(a))
		if r[0]:
			dur = a
		if r[1]:
			cik = a
	print("CATIOLC %s egim_durulan %.0f egim_cikilan %.0f floor_max_angle %.1f" % [k, dur, cik, rad_to_deg(pl.floor_max_angle)])
	# 7) duvar: koşup zıplayarak ya da (açık kipte) tutunarak üstüne çıkılan en yüksek düz duvar (2 m kalın)
	var duv := 0.0
	for hh in range(50, 400, 10):
		var h := hh / 100.0
		if await _basamak(h, true, true, 2.0):
			duv = h
		elif h > duv + 0.6:
			break
	print("CATIOLC %s duvara_cikis %.2f" % [k, duv])
	# 8) düşme hasarı / sendeleme: yalnız açık kipte Traversal._land (fall > 4,0 m); kapalı kipte yok
	print("CATIOLC %s dusme_sendeleme_esigi %s" % [k, "4.0 m (Traversal.STAGGER_FALL)" if k == "acik" else "yok"])


func _zipla() -> void:
	Input.action_press("jump")
	await get_tree().physics_frame
	Input.action_release("jump")


func _tp(p: Vector3) -> void:
	pl.global_position = p
	pl.velocity = Vector3.ZERO
	pl.rotation = Vector3.ZERO
	if pl.traversal:
		pl.traversal.cancel()
	for i in 6:
		await get_tree().physics_frame


func _temizle() -> void:
	var kal: Array = []
	for b: Node in _govdeler:
		if is_instance_valid(b) and b.has_meta("kalici"):
			kal.append(b)
		elif is_instance_valid(b):
			b.queue_free()
	_govdeler = kal
	Input.action_release("move_forward")
	Input.action_release("sprint")
	Input.action_release("jump")


func _blok(s: Vector3, p: Vector3, rot := Vector3.ZERO) -> StaticBody3D:
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
	b.add_child(mi)
	b.position = p
	b.rotation_degrees = rot
	add_child(b)
	if not _govdeler.has(b):
		_govdeler.append(b)
	return b


## Önde h yüksekliğinde blok (derinlik dd): 6 m geriden koşarak gelir; zipla: 0,5 m kala zıplar. Üstüne çıktı mı?
func _basamak(h: float, zipla: bool, kos: bool, dd := 3.0) -> bool:
	_temizle()
	await get_tree().physics_frame
	_blok(Vector3(4, h, dd), Vector3(0, h * 0.5, -dd * 0.5 - 0.0))
	await _tp(Vector3(0, 0.05, 6.0))
	pl.face(Vector3(0, 1.6, -10))
	Input.action_press("move_forward")
	if kos:
		Input.action_press("sprint")
	var zipladi := false
	var ok := false
	for i in 240:
		await get_tree().physics_frame
		var z := pl.global_position.z
		if zipla and not zipladi and z < 0.75:
			zipladi = true
			await _zipla()
		if pl.global_position.y > h - 0.05 and pl.global_position.z < -0.4 and pl.is_on_floor():
			ok = true
			break
		if pl.global_position.z < -dd:
			break
	_temizle()
	return ok


## Kalkış platformu (y 0) ile karşı platform (üst y = dy) arasında g m boşluk; kenarda (0,15 m kala) zıplar.
func _aralik(g: float, dy: float, kos := true) -> bool:
	_temizle()
	await get_tree().physics_frame
	var H := 10.0
	var Y := 30.0                                                       # düz zeminin üstünde (boşluğun altı açık)
	_blok(Vector3(4, H, 20), Vector3(0, Y - H * 0.5, 10.0))             # kalkış: z 0..20
	_blok(Vector3(4, H, 12), Vector3(0, Y + dy - H * 0.5, -g - 6.0))    # karşı: z −g−12..−g
	await _tp(Vector3(0, Y + 0.05, 12.0))
	pl.face(Vector3(0, 1.6, -100))
	Input.action_press("move_forward")
	if kos:
		Input.action_press("sprint")
	var zipladi := false
	var ok := false
	for i in 300:
		await get_tree().physics_frame
		var p := pl.global_position
		if not zipladi and p.z < 0.15 and pl.is_on_floor() and p.y > Y - 0.5:
			zipladi = true
			await _zipla()
		if p.z < -g - 0.3 and pl.is_on_floor() and p.y > Y + dy - 0.2:
			ok = true
			break
		if p.y < Y + minf(dy, 0.0) - 1.5:
			break
	_temizle()
	return ok


## Eğim (derece): r[0] 10 sn durunca 0,3 m'den az kaydı mı, r[1] yürüyerek 4 m yukarı çıktı mı
func _egim(a: float) -> Array:
	_temizle()
	await get_tree().physics_frame
	var L := 16.0
	_blok(Vector3(4, 0.5, L), Vector3(0, sin(deg_to_rad(a)) * L * 0.5 - 0.25 / cos(deg_to_rad(a)), -cos(deg_to_rad(a)) * L * 0.5), Vector3(a, 0, 0))
	var orta := Vector3(0, sin(deg_to_rad(a)) * L * 0.5 + 0.1, -cos(deg_to_rad(a)) * L * 0.5)
	await _tp(orta + Vector3(0, 0.3, 0))
	for i in 20:
		await get_tree().physics_frame
	var p0 := pl.global_position
	for i in 200:
		await get_tree().physics_frame
	var dur := pl.global_position.distance_to(p0) < 0.3
	await _tp(Vector3(0, 0.2, 0.6))
	pl.face(Vector3(0, 1.6, -100))
	Input.action_press("move_forward")
	var cik := false
	for i in 400:
		await get_tree().physics_frame
		if pl.global_position.y > sin(deg_to_rad(a)) * 4.0 + 0.0 and pl.global_position.z < -cos(deg_to_rad(a)) * 4.0:
			cik = true
			break
	_temizle()
	return [dur, cik and a > 0.0]
