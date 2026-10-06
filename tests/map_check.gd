extends Node
## Harita (v0.90): pişmiş doku (assets/ui/map1453.png, tools/map_bake.gd) dünyayla uyuşuyor mu, mini harita doğru yerde mi.
##   · doku var, boyutu MapView.W × H; world_pixel ile pixel_world birbirinin tersi;
##   · 6000 rastgele pikselde dokunun suyu (mavi baskın) World1453.is_water ile uyuşuyor (en az %98,5: kıyı surları, köprü,
##     zincir pay);
##   · bütün tarihî yapılar haritanın içinde;
##   · 1453 dünyası kurulan bölümlerde (24 şehir, 20 kara surları, 27 Galata) dünya alanı bulunur, oyuncu haritanın içinde,
##     mini harita görünür ve oyuncunun haritadaki yeri dünyadaki yeriyle tutar; 1453 dünyası olmayan bölümde (14, Büro)
##     alan yok, mini harita gizli.
## Sonuç: MAPCHECK PASS/FAIL.

const WORLD_CHAPTERS := ["24", "20", "27"]
const PLAIN_CHAPTERS := ["14"]
const MIN_AGREE := 0.985

var ok := true


func _ready() -> void:
	# Bölüm kendi akışında ilk konuşmada beklesin (city_check gibi)
	GameState.settings["auto_advance"] = false
	_check_texture()
	for ch: String in WORLD_CHAPTERS:
		await _chapter(ch, true)
	for ch: String in PLAIN_CHAPTERS:
		await _chapter(ch, false)
	print("MAPCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)


func _fail(msg: String) -> void:
	ok = false
	print("MAPCHECK FAIL: " + msg)


func _check_texture() -> void:
	var tex := MapView.texture()
	if tex == null:
		_fail("doku yok: " + MapView.TEX_PATH)
		return
	var img := tex.get_image()
	if img == null or img.get_width() != MapView.W or img.get_height() != MapView.H:
		_fail("doku boyutu %s, beklenen %dx%d" % [str(img.get_size()) if img else "?", MapView.W, MapView.H])
		return
	if img.is_compressed():
		img.decompress()
	for p: Vector2 in [Vector2(-700.0, -1500.0), Vector2(300.0, 400.0), Vector2(-1000.0, -2000.0)]:
		var q := MapView.pixel_world(MapView.world_pixel(p))
		if q.distance_to(p) > 0.01:
			_fail("dönüşüm ters değil: %s → %s" % [p, q])
	var rng := RandomNumberGenerator.new()
	rng.seed = 90
	var agree := 0
	var n := 6000
	var shown := 0
	for i in n:
		var ix := rng.randi_range(0, MapView.W - 1)
		var iy := rng.randi_range(0, MapView.H - 1)
		var w := MapView.pixel_world(Vector2(ix + 0.5, iy + 0.5))
		var c := img.get_pixel(ix, iy)
		var tex_water := c.b > c.r + 0.08
		if tex_water == World1453.is_water(w.x, w.y):
			agree += 1
		elif shown < 5:
			shown += 1
			print("MAPCHECK su uyuşmuyor: piksel (%d, %d) dünya (%.0f, %.0f) doku=%s dünya=%s" % [ix, iy, w.x, w.y,
				"su" if tex_water else "kara", "su" if World1453.is_water(w.x, w.y) else "kara"])
	var k := float(agree) / n
	print("MAPCHECK doku %dx%d, su/kara uyumu %.1f%%" % [img.get_width(), img.get_height(), k * 100.0])
	if k < MIN_AGREE:
		_fail("dokunun suyu dünyayla uyuşmuyor (%.1f%% < %.1f%%)" % [k * 100.0, MIN_AGREE * 100.0])
	for l: Dictionary in Landmarks1453.all():
		var p: Vector3 = l["pos"]
		if not MapView.inside(Vector2(p.x, p.z)):
			_fail("yapı haritanın dışında: %s" % l["key"])


func _chapter(ch: String, has_world: bool) -> void:
	var scene: PackedScene = load("res://scenes/chapter%s.tscn" % ch)
	var root := scene.instantiate()
	add_child(root)
	var t := 0.0
	var f: Node3D = null
	var hud: Hud = null
	var free_seen := false
	var shown := false
	var limit := 120.0 if has_world else 8.0
	while t < limit:
		await get_tree().process_frame
		t += get_process_delta_time()
		f = MapView.field(get_tree())
		hud = get_tree().get_first_node_in_group("hud") as Hud
		if hud == null or hud.minimap == null:
			continue
		if not (hud.cinematic or hud.is_faded()) and hud.map_free():
			free_seen = true
		if hud.minimap.visible:
			shown = true
			if t > 3.0:
				break
	var pl := get_tree().get_first_node_in_group("player") as Node3D
	if has_world:
		if f == null:
			_fail("%s: 1453 dünyası (grup %s) bulunamadı" % [ch, MapView.GROUP])
		elif pl == null:
			_fail("%s: oyuncu yok" % ch)
		else:
			var wp := MapView.to_world(f, pl.global_position)
			print("MAPCHECK %s: alan=%s oyuncu (%.0f, %.0f) piksel %s mini=%s" % [ch, f.get("region_name"), wp.x, wp.y,
				MapView.world_pixel(wp).round(), shown])
			if not MapView.inside(wp):
				_fail("%s: oyuncu haritanın dışında (%.0f, %.0f)" % [ch, wp.x, wp.y])
			elif shown and hud.minimap._pos.distance_to(wp) > 1.0:
				_fail("%s: mini haritadaki yer %s, dünyadaki %s" % [ch, hud.minimap._pos, wp])
			elif not shown and free_seen:
				_fail("%s: oyuncu serbestken mini harita görünmedi" % ch)
			elif not shown:
				print("MAPCHECK %s: bölüm ara sahnede kaldı, mini harita sınanamadı" % ch)
	else:
		print("MAPCHECK %s: alan=%s mini=%s" % [ch, f != null, shown])
		if f != null:
			_fail("%s: 1453 dünyası olmayan bölümde harita alanı var" % ch)
		if shown:
			_fail("%s: 1453 dünyası olmayan bölümde mini harita göründü" % ch)
	root.queue_free()
	for k in 3:
		await get_tree().process_frame
