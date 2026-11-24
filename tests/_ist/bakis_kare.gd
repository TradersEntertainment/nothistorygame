extends "res://tests/_ist/tasima12_kare.gd"
## Dört yöne bakış kare aracı (0.99.126 sonrası göz kontrolü). Bölüm otomatik oyunla kendini oynar; oyuncu öncekilerin
## hepsinden ≥ `ara` m uzak bir yere her geldiğinde dünya durur, oyuncunun göz hizasından ileri/sağ/geri/sol çekilir
## (tek 1280×720 kare, 2×2: sol üst ileri, sağ üst sağ, sol alt GERİ, sağ alt sol). Arayüz katmanları çekimde gizlenir.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --rendering-driver opengl3 --resolution 1280x720 \
##     res://tests/_ist/bakis_kare.tscn -- bolum=8y shots=KLASÖR [ara=15] [en_cok=10] [sure=600] [cesit=…]
## Satırlar: BAKIS_YUKLE · BAKIS bolum=… n=… konum=… yon=… t=… · BAKIS_BITTI sebep=…

var ara := 15.0
var en_cok := 10
var sure := 600.0
var cesit := ""
var bas := 1.5         # ilk çekimden önce (sn)
var aralik := 0.2      # iki çekim arası en az (sn)
var pace := false      # gerçek hız (konuşmalar gerçek sürede: yavaş)
var halka := 30.0      # ilk noktanın çevresinde dört nokta (0: yok)
var sonda := ""        # "x0,x1,z": x0→x1 boyunca (z sabit) yer ışını + o noktayı kapsayan ağlar (BAKIS_SONDA satırları)
var bak := ""          # "x,y,z,yön°": yalnız bu göz noktasından dört TAM BOY kare (bolum_bak_<i>.jpg), sonra çık
var _noktalar: Array[Vector3] = []
var _son := -100.0
var _t0 := 0
var _cekiyor := false
var _kam: Camera3D


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"ara": ara = float(kv[1])
			"en_cok": en_cok = int(kv[1])
			"sure": sure = float(kv[1])
			"cesit": cesit = kv[1]
			"bas": bas = float(kv[1])
			"aralik": aralik = float(kv[1])
			"pace": pace = kv[1] == "1"
			"halka": halka = float(kv[1])
			"bak": bak = kv[1]
			"sonda": sonda = kv[1]
	super._ready()


## Dal kurulumu: 4b = bölüm 4'ün deniz dalı (2.3 sonucu); 6 ve 7 zorlanmaz (Bizans dalı `cesit=byz` ile, otomatik oyunun
## kendi beklediği sonuçla). Öteki bölümler Taşıma kare araçlarının ön koşullarıyla.
func _hazirla() -> void:
	match bolum:
		"4b":
			GameState.chapter_outcomes[2] = "2.3"
		"6", "7":
			pass
		_:
			super._hazirla()


func _surus() -> void:
	GameState.autotest = true
	# pace=1: gerçek hız (yürüyüşler ışınlanmaz) ama konuşmalar da gerçek sürede (8y: ilk 12 m 324 sn); varsayılan hızlı kip,
	# çekimde dünya durduğu için otomatik oyun çekimleri geçemez
	GameState.pace = pace
	if cesit != "":
		GameState.autotest_variant = cesit
	var sc := load("res://scenes/chapter%s.tscn" % ("4" if bolum == "4b" else bolum)) as PackedScene
	ch = sc.instantiate() as Node3D
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	_t0 = Time.get_ticks_msec()
	print("BAKIS_YUKLE bolum=%s" % bolum)
	_kam = Camera3D.new()
	_kam.fov = 75.0
	_kam.near = 0.05
	_kam.far = 4000.0
	_kam.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_kam)
	if sonda != "":
		await _sonda()
	if bak != "":
		await _tam_boy()
		return
	while true:
		await get_tree().process_frame
		var t := (Time.get_ticks_msec() - _t0) / 1000.0
		if not is_instance_valid(ch) or ch.is_queued_for_deletion():
			_bitir("bolum_bitti")
			return
		if t > sure:
			_bitir("sure")
			return
		if _noktalar.size() >= en_cok:
			_bitir("en_cok")
			return
		if t < bas or t - _son < aralik:
			continue
		var pl := get_tree().get_first_node_in_group("player") as Node3D
		if pl == null or not pl.is_inside_tree():
			continue
		var p := pl.global_position
		var uzak := true
		for q: Vector3 in _noktalar:
			if Vector2(p.x - q.x, p.z - q.z).length() < ara:
				uzak = false
				break
		if uzak:
			var ilk := _noktalar.is_empty()
			var yon0: Vector3 = await _dort_yon(pl, t)
			if ilk and halka > 0.0:
				await _halka(pl, yon0, t)
			_son = (Time.get_ticks_msec() - _t0) / 1000.0


## Başlangıcın çevresi (serbest dolaşılan alan; otomatik oyun her yeri yürümez): `halka` m ötede ileri/sağ/geri/sol, yer
## yukarıdan ışınla bulunur (çatıya düşen ya da başlangıçtan 6 m'den fazla yukarıda/aşağıda olan nokta atlanır).
func _halka(pl: Node3D, ileri: Vector3, t: float) -> void:
	var p0 := pl.global_position
	var uzay := pl.get_world_3d().direct_space_state
	for i in 4:
		var d := ileri.rotated(Vector3.UP, -PI * 0.5 * i)
		var q := p0 + d * halka
		# çatı/sur tepesine çarparsa altından yeniden (en çok 4 kez); başlangıçtan aşağıdaki zemin kabul (sur yolunda başlayan
		# bölümlerde halka surun dibindedir)
		var ust := p0.y + 30.0
		var hit := {}
		for deneme in 4:
			hit = uzay.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(q.x, ust, q.z), Vector3(q.x, p0.y - 40.0, q.z)))
			if hit.is_empty() or (hit["position"] as Vector3).y - p0.y <= 6.0:
				break
			ust = (hit["position"] as Vector3).y - 0.3
		if hit.is_empty() or (hit["position"] as Vector3).y - p0.y > 6.0:
			print("BAKIS_HALKA_ATLA bolum=%s i=%d" % [bolum, i])
			continue
		await _dort_yon(pl, t, (hit["position"] as Vector3) + Vector3(0, 1.62, 0), d, "h%d" % i)


func _dort_yon(pl: Node3D, t: float, goz_ozel := Vector3.INF, ileri_ozel := Vector3.ZERO, ek := "") -> Vector3:
	_cekiyor = true
	get_tree().paused = true
	var onceki := get_viewport().get_camera_3d()
	var goz := pl.global_position + Vector3(0, 1.62, 0)
	var ileri := -pl.global_basis.z
	if onceki != null and pl.is_ancestor_of(onceki):
		goz = onceki.global_position
		ileri = -onceki.global_basis.z
		_kam.fov = onceki.fov
	if goz_ozel != Vector3.INF:
		goz = goz_ozel
		ileri = ileri_ozel
	ileri.y = 0.0
	if ileri.length() < 0.01:
		ileri = Vector3.FORWARD
	ileri = ileri.normalized()
	var gizli: Array[CanvasLayer] = []
	for n in get_tree().root.find_children("*", "CanvasLayer", true, false):
		var cl := n as CanvasLayer
		if cl.visible:
			cl.visible = false
			gizli.append(cl)
	var kare := Image.create(1280, 720, false, Image.FORMAT_RGB8)
	# ileri, sağ, geri, sol (sağ = ileri'nin saat yönünde 90°'si: yukarıdan bakınca -y ekseni etrafında)
	var yonler := [ileri, ileri.rotated(Vector3.UP, -PI * 0.5), -ileri, ileri.rotated(Vector3.UP, PI * 0.5)]
	_kam.global_position = goz
	_kam.make_current()
	for i in 4:
		var y: Vector3 = yonler[i]
		_kam.look_at(goz + y * 10.0 - Vector3(0, 0.6, 0), Vector3.UP)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var im := get_viewport().get_texture().get_image()
		im.convert(Image.FORMAT_RGB8)
		im.resize(640, 360, Image.INTERPOLATE_BILINEAR)
		kare.blit_rect(im, Rect2i(0, 0, 640, 360), Vector2i((i % 2) * 640, (i / 2) * 360))
	var ad := "%s_%02d%s" % [bolum, _noktalar.size(), ek]
	if shots != "":
		kare.save_jpg(shots.path_join(ad + ".jpg"), 0.88)
	print("BAKIS bolum=%s n=%d%s konum=(%.1f, %.1f, %.1f) yon=%.0f t=%.1f" % [bolum, _noktalar.size(), ek, goz.x, goz.y, goz.z,
		rad_to_deg(atan2(ileri.x, ileri.z)), t])
	_noktalar.append(goz - Vector3(0, 1.62, 0))
	for cl in gizli:
		if is_instance_valid(cl):
			cl.visible = true
	if onceki != null and is_instance_valid(onceki):
		onceki.make_current()
	get_tree().paused = false
	_cekiyor = false
	return ileri


func _sonda() -> void:
	var v := sonda.split(",")
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(maxf(bas, 1.0) * 1000.0):
		await get_tree().process_frame
	var uzay := ch.get_world_3d().direct_space_state
	# "x0,x1,z" (x boyunca) ya da "x0,z0,x1,z1" (doğru parçası boyunca), 2 m adım
	var a := Vector2(float(v[0]), float(v[2])) if v.size() == 3 else Vector2(float(v[0]), float(v[1]))
	var b := Vector2(float(v[1]), float(v[2])) if v.size() == 3 else Vector2(float(v[2]), float(v[3]))
	var adim := maxi(1, int(a.distance_to(b) / 2.0))
	for ii in adim + 1:
		var pp := a.lerp(b, float(ii) / adim)
		var x := pp.x
		var z := pp.y
		var h := uzay.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(x, 20, z), Vector3(x, -20, z)))
		var hy: float = (h["position"] as Vector3).y if not h.is_empty() else -99.0
		var hc: String = String((h["collider"] as Node).get_path()).right(60) if not h.is_empty() else "-"
		var ham := -99.0
		var yama := -99.0
		if IstBaglama.aktif():
			var w := IstBaglama.v2(Vector3(x, 0, z))
			ham = IstGeo.h_ham(w.x, w.z) - (IstBaglama.v2(Vector3.ZERO).y)
			yama = IstGeo.h(w.x, w.z) - (IstBaglama.v2(Vector3.ZERO).y)
		print("BAKIS_SONDA x=%.1f z=%.1f carp_y=%.2f arazi_ham=%.2f arazi=%.2f carp=%s" % [x, z, hy, ham, yama, hc.right(40)])


func _tam_boy() -> void:
	var v := bak.split(",")
	var goz := Vector3(float(v[0]), float(v[1]), float(v[2]))
	var yaw := deg_to_rad(float(v[3]))
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(maxf(bas, 1.0) * 1000.0):
		await get_tree().process_frame
	get_tree().paused = true
	for n in get_tree().root.find_children("*", "CanvasLayer", true, false):
		(n as CanvasLayer).visible = false
	_kam.global_position = goz
	_kam.make_current()
	for i in 4:
		var y := Vector3(sin(yaw), 0, cos(yaw)).rotated(Vector3.UP, -PI * 0.5 * i)
		_kam.look_at(goz + y * 10.0 - Vector3(0, 1.2, 0), Vector3.UP)
		for k in 4:
			await RenderingServer.frame_post_draw
		if shots != "":
			get_viewport().get_texture().get_image().save_jpg(shots.path_join("%s_bak_%d.jpg" % [bolum, i]), 0.9)
	print("BAKIS_TAMBOY bolum=%s goz=%s" % [bolum, goz])
	_bitir("bak")


func _bitir(sebep: String) -> void:
	print("BAKIS_BITTI bolum=%s sebep=%s nokta=%d" % [bolum, sebep, _noktalar.size()])
	get_tree().quit()
