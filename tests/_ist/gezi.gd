extends Node3D
## İstanbul v2 gezi sahnesi (docs/_ajan/gorev/_ist2_ortak.md): IstDunya.build ile v2'yi kurar.
##   godot --path . --resolution 1280x720 res://tests/_ist/gezi.tscn -- gece=0|1 kam=e,n,yukseklik,yon,egim
##       shots=KLASÖR liste=DOSYA kip=ucus|yuru|kare
## kam: gerçek doğu/kuzey (m), yükseklik (dünya m, ARAZİNİN ÜSTÜNDE; "@" önekiyle mutlak y: @300), yön (pusula
## derecesi, 0 kuzey, 90 doğu), eğim (derece, aşağı eksi).
## liste: her satır "ad e n yukseklik yon egim [gece]" ('#' yorum); her satır için arazi akışı bitince KLASÖR/ad.png.
## kip=ucus (varsayılan, liste yoksa): WASD + fare, Shift hızlı, Q/E alçal/yüksel. kip=yuru: Player (Tolga) kam
## konumunda yürür. Her kare listesinden sonra RINFO satırı: çizim, üçgen (RenderingServer) ve IstDunya ölçümü.

var gece := false
var kam := "0,0,40,0,-20"
var shots := ""
var liste := ""
var kip := ""
var dunya: IstDunya
var cam: Camera3D
var player: Node3D
var _yaw := 0.0
var _pitch := 0.0
var _hiz := 18.0


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"gece": gece = kv[1] == "1"
			"kam": kam = kv[1]
			"shots": shots = kv[1]
			"liste": liste = kv[1]
			"kip": kip = kv[1]
			"sehir": IstDunya.sehir_bagla = kv[1] != "0"
	if kip == "harita":
		_harita.call_deferred()
		return
	if kip == "":
		kip = "kare" if liste != "" else "ucus"
	cam = Camera3D.new()
	cam.far = 30000.0
	cam.near = 0.1
	cam.fov = 70.0
	add_child(cam)
	cam.current = true
	var k := _kam_coz(kam)
	_kam_koy(k)
	dunya = IstDunya.build(self, gece, cam.global_position) as IstDunya
	if kip == "yuru" or kip == "yuru_sina":
		_oyuncu(k)
		if kip == "yuru_sina":
			_yuru_sina.call_deferred()
	elif kip == "kare":
		IstDunya.butce_us = 250000        # yazılımla çizimde kare çok yavaş: akış beklemesin
		_kareler.call_deferred()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _kam_coz(s: String) -> Array:
	var p := s.split(",")
	var e := p[0].to_float() if p.size() > 0 else 0.0
	var n := p[1].to_float() if p.size() > 1 else 0.0
	var ys := p[2] if p.size() > 2 else "40"
	var yon := p[3].to_float() if p.size() > 3 else 0.0
	var egim := p[4].to_float() if p.size() > 4 else -20.0
	return [e, n, ys, yon, egim]


func _kam_koy(k: Array) -> void:
	var w2 := IstGeo.w2(k[0], k[1])
	var ys: String = k[2]
	var y := 0.0
	if ys.begins_with("@"):
		y = ys.substr(1).to_float()
	else:
		y = maxf(IstGeo.h(w2.x, w2.y), 0.0) + ys.to_float()
	cam.global_position = Vector3(w2.x, y, w2.y)
	_yaw = -deg_to_rad(k[3])
	_pitch = deg_to_rad(k[4])
	cam.rotation = Vector3(_pitch, _yaw, 0.0)


func _oyuncu(k: Array) -> void:
	var P = load("res://scripts/player/player.gd")
	player = P.new()
	var w2 := IstGeo.w2(k[0], k[1])
	add_child(player)
	player.global_position = Vector3(w2.x, IstGeo.h(w2.x, w2.y) + 0.5, w2.y)
	player.rotation.y = -deg_to_rad(k[3])
	dunya.izle = player
	dunya.carpisma_yenile(player.global_position)
	cam.current = false


func _unhandled_input(ev: InputEvent) -> void:
	if kip != "ucus":
		return
	if ev is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= ev.relative.x * 0.0025
		_pitch = clampf(_pitch - ev.relative.y * 0.0025, -1.55, 1.55)
		cam.rotation = Vector3(_pitch, _yaw, 0.0)
	elif ev is InputEventKey and ev.pressed and ev.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED


func _process(dt: float) -> void:
	if kip != "ucus":
		return
	var v := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): v.z -= 1
	if Input.is_key_pressed(KEY_S): v.z += 1
	if Input.is_key_pressed(KEY_A): v.x -= 1
	if Input.is_key_pressed(KEY_D): v.x += 1
	if Input.is_key_pressed(KEY_E): v.y += 1
	if Input.is_key_pressed(KEY_Q): v.y -= 1
	var h := _hiz * (5.0 if Input.is_key_pressed(KEY_SHIFT) else 1.0)
	cam.global_position += (cam.global_transform.basis * Vector3(v.x, 0, v.z) + Vector3(0, v.y, 0)) * h * dt
	var g := IstGeo.h(cam.global_position.x, cam.global_position.z)
	cam.global_position.y = maxf(cam.global_position.y, maxf(g, 0.0) + 1.5)


## Arazi akışı bitene kadar bekle (en çok `sn`)
func _bekle(sn := 20.0) -> void:
	var t0 := Time.get_ticks_msec()
	for i in 6:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < sn * 1000.0:
		var o := dunya.olcum()
		if o["isler"] == 0:
			break
		await get_tree().process_frame
	for i in 4:
		await get_tree().process_frame


func _kareler() -> void:
	var satirlar: Array = []
	if liste != "":
		var f := FileAccess.open(liste, FileAccess.READ)
		if f == null:
			print("GEZI liste açılamadı: ", liste)
			get_tree().quit(1)
			return
		while not f.eof_reached():
			var s := f.get_line().strip_edges()
			if s == "" or s.begins_with("#"):
				continue
			satirlar.append(s)
	else:
		satirlar.append("kam %s" % kam.replace(",", " "))
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	for s: String in satirlar:
		var p := s.split(" ", false)
		var ad := p[0]
		var k := _kam_coz(",".join(p.slice(1, 6)))
		_kam_koy(k)
		await _bekle()
		var t0 := Time.get_ticks_usec()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var ms := (Time.get_ticks_usec() - t0) / 1000.0
		var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
		var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		var o := dunya.olcum()
		print("RINFO gezi %s cizim=%d ucgen=%d kare_ms=%.1f dunya_tris=%d dunya_draws=%d lod=%s kare_us=%d" % [ad, dc, pr, ms,
			o["tris"], o["draws"], o["lod"], o["kare_us"]])
		if shots != "":
			var img := get_viewport().get_texture().get_image()
			img.save_png(shots.path_join(ad + ".png"))
			print("GEZI kare ", shots.path_join(ad + ".png"))
	print("GEZI bitti kurulum_ms=%.0f" % dunya.olcum()["kurulum_ms"])
	get_tree().quit(0)


## Başsız yürüme sınaması: oyuncu ileri yürür (move_forward), arazi üstünde kalıyor mu; sonra denize bırakılır,
## yakalayıcı kıyıya çıkarıyor mu. Satırlar: YURU …
func _yuru_sina() -> void:
	IstDunya.butce_us = 20000
	var pl := player as CharacterBody3D
	for i in 30:
		await get_tree().physics_frame
	Input.action_press("move_forward")
	Input.action_press("sprint")
	var dus := 0
	var en_kotu := 0.0
	var yol := 0.0
	var son := pl.global_position
	var t0 := Time.get_ticks_msec()
	var kare := 0
	while Time.get_ticks_msec() - t0 < 40000 and kare < 1500:
		await get_tree().physics_frame
		kare += 1
		var p := pl.global_position
		yol += Vector2(p.x - son.x, p.z - son.z).length()
		son = p
		var g := IstGeo.h(p.x, p.z)
		var fark := p.y - g
		if not IstGeo.su(p.x, p.z):
			en_kotu = maxf(en_kotu, absf(fark) if pl.is_on_floor() else 0.0)
			if fark < -0.5:
				dus += 1
		if kare % 150 == 0:
			var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			var pr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
			print("YURU kare=%d konum=%s zemin=%.2f fark=%.2f yerde=%s cizim=%d ucgen=%d dunya=%s" % [kare, p, g, fark, pl.is_on_floor(), dc, pr, dunya.olcum()])
	Input.action_release("move_forward")
	Input.action_release("sprint")
	print("YURU sonuc yol=%.0f m alt_dusme=%d yerde_en_buyuk_fark=%.2f" % [yol, dus, en_kotu])
	# su yakalayıcı: Haliç'in ortasına bırak
	var w := IstGeo.w2(-1200.0, 1500.0)
	pl.global_position = Vector3(w.x, -1.5, w.y)
	for i in 60:
		await get_tree().physics_frame
	var q := pl.global_position
	print("YURU yakalayici konum=%s su=%s zemin=%.2f %s" % [q, IstGeo.su(q.x, q.z), IstGeo.h(q.x, q.z),
		"PASS" if not IstGeo.su(q.x, q.z) and q.y > -0.5 else "FAIL"])
	get_tree().quit(0)


## kip=harita: IstGeo.mahalle türlerinin tam tepe haritası (dünya hücresi `hucre` m) → shots/mahalle_harita.png;
## satırlar: HARITA tur=… hucre_sayisi=…, en büyük kesintisiz evsiz (bostan/harabe/seyrek ada) alan.
const TUR_RENK := {"carsi": "c0392b", "sik": "e08a4a", "seyrek": "e8c27a", "bostan": "5d8a3a", "harabe": "8e8170",
	"liman": "3e6fb0", "sur_dibi": "a0522d", "kir": "c9c08f", "sarnic": "2f6b2f", "hipodrom": "d9cfae", "saray": "6e6258",
	"ordugah": "b08fd0", "koy": "d8a0a0", "bag": "7a9a3a", "orman": "2e5030"}
func _harita() -> void:
	var hucre := 10.0
	var e0 := -7200.0
	var e1 := 5200.0
	var n0 := -3400.0
	var n1 := 6400.0
	var W := int((e1 - e0) * IstGeo.S / hucre)
	var H := int((n1 - n0) * IstGeo.S / hucre)
	var img := Image.create(W, H, false, Image.FORMAT_RGB8)
	var say := {}
	var ici := PackedByteArray()
	ici.resize(W * H)
	var t0 := Time.get_ticks_msec()
	for j in H:
		for i in W:
			var x := e0 * IstGeo.S + (i + 0.5) * hucre
			var z := -n1 * IstGeo.S + (j + 0.5) * hucre
			var m := IstGeo.mahalle(x, z)
			var tur := String(m["tur"])
			if m["ad"] == "deniz":
				img.set_pixel(i, j, Color("1d4f7a"))
				continue
			var c := Color(TUR_RENK.get(tur, "ff00ff"))
			c = c.darkened(0.25 * (1.0 - float(m["yogunluk"])))
			img.set_pixel(i, j, c)
			if IstGeo.sehir_ici(x, z):
				say[tur] = int(say.get(tur, 0)) + 1
				if tur in ["bostan", "harabe"] or (tur == "seyrek" and float(m["yogunluk"]) < 0.5):
					ici[j * W + i] = 1
	# en büyük kesintisiz evsiz ada (4-komşu)
	var en_buyuk := 0
	var en_yer := Vector2.ZERO
	var gor := PackedByteArray()
	gor.resize(W * H)
	for k in W * H:
		if ici[k] == 0 or gor[k] == 1:
			continue
		var yigin := [k]
		gor[k] = 1
		var n := 0
		var mn := Vector2i(W, H)
		var mx := Vector2i(-1, -1)
		while not yigin.is_empty():
			var q: int = yigin.pop_back()
			n += 1
			var qi := q % W
			var qj := q / W
			mn = Vector2i(mini(mn.x, qi), mini(mn.y, qj))
			mx = Vector2i(maxi(mx.x, qi), maxi(mx.y, qj))
			for d in [q - 1, q + 1, q - W, q + W]:
				if d >= 0 and d < W * H and ici[d] == 1 and gor[d] == 0 and absi(d % W - qi) <= 1:
					gor[d] = 1
					yigin.append(d)
		var boy := maxi(mx.x - mn.x + 1, mx.y - mn.y + 1)
		if boy > en_buyuk:
			en_buyuk = boy
			en_yer = Vector2(e0 + (mn.x + mx.x) * 0.5 * hucre / IstGeo.S, n1 - (mn.y + mx.y) * 0.5 * hucre / IstGeo.S)
	var top := 0
	for t in say:
		top += say[t]
	for t in say:
		print("HARITA sehir_ici tur=%s hucre=%d oran=%.3f" % [t, say[t], float(say[t]) / maxf(top, 1)])
	print("HARITA en_buyuk_evsiz_ada_kenar=%.0f m (dunya) gercek_merkez=%s sure_ms=%d" % [en_buyuk * hucre, en_yer, Time.get_ticks_msec() - t0])
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
		img.save_png(shots.path_join("mahalle_harita.png"))
		print("GEZI kare ", shots.path_join("mahalle_harita.png"))
	get_tree().quit(0)
