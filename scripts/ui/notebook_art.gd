class_name NotebookArt
extends RefCounted
## Şehzadenin defteri (Edirne, 1444): iki sayfa, kodla çizilen doku. Sol sayfada tuğra denemeleri (üç elif ve
## bayrakları, iç içe beyzeler, uzanan kollar; köşede üstü çizilmiş bir deneme) ve mürekkeple satırlar, başlığı
## kırmızı; sağ sayfada Kostantiniyye: üçgen yarımada, kara surları ve burçları, Haliç'in zinciri, Galata kulesi,
## Ayasofya'nın kubbesi, Haliç'e karadan inen gemi taslağı (1453'ün tohumu), köşede Kızıl Elma. Tolga'lı sürümde
## sağ sayfanın köşesinde fesli, ıslak bir adam karikatürü. Eskiden birkaç kutuyla çiziliyordu ("defter tasarımı").
##   var pages := NotebookArt.pages(tolga)   # [sol, sağ] ImageTexture; bir kez çizilir, saklanır
## Kütüphane duvarındaki Batlamyus usulü dünya haritası da burada çizilir (map_texture). v0.99.17: sağ sayfada başlık,
## Galata, gemi taslağı ve fesli karikatür üst üste biniyordu; her biri kendi bölgesine çekildi.

const W := 256
const H := 340
const PAPER := Color("efe1bf")
const INK := Color(0.16, 0.11, 0.07, 0.9)
const RED := Color(0.62, 0.12, 0.1, 0.9)
const WASH := Color(0.42, 0.56, 0.68, 0.35)

static var _images := {}
## Arka plandaki çizim görevi (-1: yok). Durağan Mutex yerine görevin bitmesi beklenir: durağan değişkendeki kilit oyun
## kapanırken serbest kalıyor, çıkışta çöküyordu (signal 11, pthread_mutex_lock)
static var _task := -1


## Sayfaların resimleri arka planda çizilir (sarayın kuruluşunda): şehzade defteri uzattığında oyun takılmasın
static func warm() -> void:
	if _task >= 0 or not _images.is_empty():
		return
	_task = WorkerThreadPool.add_task(func():
		var got := {"map": [_map()]}
		for t: bool in [false, true]:
			got["t" if t else "n"] = _draw(t)
		_images.merge(got))


static func _images_for(tolga: bool) -> Array:
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1
	var key := "t" if tolga else "n"
	if not _images.has(key):
		_images[key] = _draw(tolga)
	return _images[key]


static func _draw(tolga: bool) -> Array:
	var l := _page(true)
	_tughra_page(l)
	var r := _page(false)
	_city_page(r, tolga)
	for im: Image in [l, r]:
		im.generate_mipmaps()
	return [l, r]


## Dokular sahne ağacının kökünde saklanır, durağan değişkende değil: durağan değişkendeki doku oyun kapanırken
## görüntü sunucusundan sonra serbest kalıyor, çıkışta çöküyordu (signal 11).
static func pages(tolga := false) -> Array:
	var key := "notebook_pages_" + ("t" if tolga else "n")
	var root := (Engine.get_main_loop() as SceneTree).root
	if not root.has_meta(key):
		var out := []
		for im: Image in _images_for(tolga):
			out.append(ImageTexture.create_from_image(im))
		root.set_meta(key, out)
	return root.get_meta(key)


## Harita dokusu arka planda çizildi mi (saray her karede sorar; hazır olunca levhaya takar)
static func map_ready() -> bool:
	if _task >= 0:
		return WorkerThreadPool.is_task_completed(_task)
	return true


## Batlamyus usulü dünya haritası (kütüphanenin kuzey duvarındaki asma levha). Doku sahne ağacının kökünde saklanır.
static func map_texture() -> Texture2D:
	var root := (Engine.get_main_loop() as SceneTree).root
	if not root.has_meta("ptolemy_map"):
		if _task >= 0:
			WorkerThreadPool.wait_for_task_completion(_task)
			_task = -1
		if not _images.has("map"):
			_images["map"] = [_map()]
		root.set_meta("ptolemy_map", ImageTexture.create_from_image(_images["map"][0]))
	return root.get_meta("ptolemy_map")


## Kâğıt: sıcak krem, kenarlara doğru kararır; cilde yakın kenarda (sol sayfanın sağı, sağ sayfanın solu) gölge
static func _page(left: bool) -> Image:
	var im := Image.create(W, H, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1444 if left else 1453
	for y in H:
		for x in W:
			var ex := minf(float(x), float(W - 1 - x)) / W
			var ey := minf(float(y), float(H - 1 - y)) / H
			var edge := clampf(1.0 - minf(ex, ey) * 9.0, 0.0, 1.0)
			var gutter := float(W - 1 - x) / W if left else float(x) / W
			var g := clampf(1.0 - gutter * 7.0, 0.0, 1.0)
			var c := PAPER.darkened(edge * 0.18 + g * 0.22 + rng.randf() * 0.025)
			im.set_pixel(x, y, c)
	return im


static func _blend(im: Image, x: int, y: int, c: Color) -> void:
	if x < 0 or y < 0 or x >= im.get_width() or y >= im.get_height():
		return
	im.set_pixel(x, y, im.get_pixel(x, y).blend(c))


static func _dot(im: Image, p: Vector2, r: float, c: Color) -> void:
	var r2 := r * r
	for yy in range(int(floor(p.y - r)), int(ceil(p.y + r)) + 1):
		for xx in range(int(floor(p.x - r)), int(ceil(p.x + r)) + 1):
			if Vector2(xx - p.x, yy - p.y).length_squared() <= r2:
				_blend(im, xx, yy, c)


## Kalem darbesi: uçta incelir (kamış kalem)
static func _line(im: Image, a: Vector2, b: Vector2, w: float, c: Color, taper := true) -> void:
	var n := int(a.distance_to(b) / 0.9) + 1
	for i in n + 1:
		var t := float(i) / n
		var ww := w * (0.45 + 0.55 * sin(t * PI)) if taper else w
		_dot(im, a.lerp(b, t), maxf(ww * 0.5, 0.5), c)


static func _arc(im: Image, c0: Vector2, rx: float, ry: float, a0: float, a1: float, w: float, c: Color, tilt := 0.0, taper := false) -> void:
	var n := int(maxf(rx, ry) * absf(a1 - a0) / 2.0) + 6
	var prev := Vector2.INF
	for i in n + 1:
		var a := lerpf(a0, a1, float(i) / n)
		var p := c0 + Vector2(cos(a) * rx, sin(a) * ry).rotated(tilt)
		if prev != Vector2.INF:
			var t := float(i) / n
			_line(im, prev, p, w * (0.5 + 0.5 * sin(t * PI)) if taper else w, c, false)
		prev = p


## Bir yazı satırı: kelimeler (taban çizgisi, bir iki diş, nokta) — okunmaz ama el yazısı gibi durur
static func _script_row(im: Image, x0: float, x1: float, y: float, c: Color, rng: RandomNumberGenerator) -> void:
	var x := x1
	while x > x0 + 8.0:
		var wl := rng.randf_range(10.0, 22.0)
		var s := maxf(x - wl, x0)
		_line(im, Vector2(x, y), Vector2(s, y + rng.randf_range(-0.8, 0.8)), 1.6, c)
		for k in rng.randi_range(1, 3):
			var hx := rng.randf_range(s + 2.0, x - 2.0)
			_line(im, Vector2(hx, y), Vector2(hx + rng.randf_range(-1.0, 1.0), y - rng.randf_range(3.0, 7.0)), 1.3, c)
		if rng.randf() < 0.6:
			_dot(im, Vector2(rng.randf_range(s, x), y + (-6.0 if rng.randf() < 0.5 else 4.0)), 1.1, c)
		if rng.randf() < 0.3:
			_arc(im, Vector2(s + 1.0, y + 2.0), 3.5, 4.0, 0.0, PI, 1.2, c)
		x = s - rng.randf_range(4.0, 8.0)


static func _tughra(im: Image, o: Vector2, k: float, c: Color) -> void:
	# Üç elif (dik), tepelerinde bayraklar (tuğ) sağa savrulur
	for i in 3:
		var x := o.x + (i * 15.0 - 8.0) * k
		_line(im, Vector2(x, o.y - 100.0 * k), Vector2(x - 2.0 * k, o.y), 3.4 * k, c)
		_arc(im, Vector2(x + 9.0 * k, o.y - 92.0 * k + i * 4.0 * k), 9.0 * k, 5.0 * k, PI, TAU * 0.95, 2.0 * k, c, -0.3, true)
	# Sere: elif'lerin dibinde düğüm
	_arc(im, o + Vector2(10.0, 4.0) * k, 22.0 * k, 9.0 * k, 0.2, PI * 1.8, 2.4 * k, c, 0.05)
	_arc(im, o + Vector2(4.0, 10.0) * k, 12.0 * k, 6.0 * k, 0.0, TAU, 1.8 * k, c)
	# Beyzeler: solda iç içe iki oval
	_arc(im, o + Vector2(-48.0, 6.0) * k, 44.0 * k, 26.0 * k, 0.3, TAU + 0.1, 2.8 * k, c, -0.12, true)
	_arc(im, o + Vector2(-38.0, 8.0) * k, 28.0 * k, 15.0 * k, 0.5, TAU + 0.2, 2.2 * k, c, -0.12, true)
	# Kollar: sağa uzanan iki uzun darbe
	_arc(im, o + Vector2(60.0, -6.0) * k, 60.0 * k, 16.0 * k, PI * 0.95, PI * 1.85, 2.6 * k, c, 0.08, true)
	_arc(im, o + Vector2(56.0, 14.0) * k, 54.0 * k, 10.0 * k, PI * 0.9, PI * 1.9, 2.0 * k, c, 0.04, true)


static func _tughra_page(im: Image) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	_script_row(im, 40.0, 216.0, 26.0, RED, rng)
	_line(im, Vector2(36, 36), Vector2(220, 36), 0.8, Color(RED, 0.4), false)
	_tughra(im, Vector2(140, 182), 1.0, INK)
	# Köşede bir deneme daha, beğenilmemiş: üstü çizili
	_tughra(im, Vector2(70, 296), 0.38, Color(INK, 0.75))
	_line(im, Vector2(30, 312), Vector2(112, 262), 1.6, Color(RED, 0.8))
	for k in 4:
		_script_row(im, 128.0, 226.0, 246.0 + k * 20.0, INK, rng)


## Sağ sayfa, yukarıdan aşağı ayrı bölgeler: kırmızı başlık; Haliç'in kuzey kıyısı (Galata kulesi, tepelerde karadan
## inen gemi ve Haliç'e kesik ok); Haliç'in suyu; üçgen yarımada (kara surları, Ayasofya, Sarayburnu'ndan Galata'ya
## zincir); altta Marmara. Tolga'lı sürümde fesli ıslak adam Marmara'da, sol altta yüzer; Kızıl Elma sağ alt köşede.
static func _city_page(im: Image, tolga: bool) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	_script_row(im, 46.0, 214.0, 22.0, RED, rng)
	_line(im, Vector2(40, 31), Vector2(220, 31), 0.8, Color(RED, 0.4), false)
	# Su: Haliç (kuzey kıyısı ile yarımada arası) ve Marmara (yarımadanın altı), sulu boya
	for y in range(80, 136):
		for x in range(18, 240):
			_blend(im, x, y, Color(WASH, 0.32 * (1.0 - float(y - 80) / 90.0) + 0.05))
	for y in range(228, 314):
		for x in range(18, 240):
			_blend(im, x, y, Color(WASH, 0.28 * float(y - 228) / 86.0 + 0.06))
	# Haliç'in kuzey kıyısı: dalgalı çizgi; ardında tepeler
	var shore := [Vector2(22, 80), Vector2(64, 84), Vector2(112, 80), Vector2(160, 78), Vector2(204, 76), Vector2(238, 78)]
	for i in shore.size() - 1:
		_line(im, shore[i], shore[i + 1], 1.4, INK, false)
	for hx: float in [36.0, 58.0, 150.0, 176.0]:
		_arc(im, Vector2(hx, 66), 10.0, 5.0, PI, TAU, 1.1, Color(INK, 0.6))
	# Galata kulesi ve suru (kıyının doğu ucunda)
	_line(im, Vector2(212, 76), Vector2(212, 50), 2.6, INK, false)
	_arc(im, Vector2(212, 50), 4.0, 6.0, PI, TAU, 1.6, INK)
	_line(im, Vector2(196, 76), Vector2(196, 62), 1.2, INK, false)
	_line(im, Vector2(196, 62), Vector2(230, 62), 1.2, INK, false)
	_line(im, Vector2(230, 62), Vector2(232, 77), 1.2, INK, false)
	# Karadan inen gemi: tepelerin arasında küçük kadırga, Haliç'e kesik kırmızı ok
	var sh := Vector2(100, 58)
	_arc(im, sh, 13.0, 4.0, 0.0, PI, 1.6, INK)
	_line(im, sh, sh + Vector2(0, -13), 1.2, INK, false)
	_line(im, sh + Vector2(0, -13), sh + Vector2(9, -4), 1.0, INK, false)
	for t in range(0, 7):
		var p := Vector2(110, 66).lerp(Vector2(126, 104), t / 6.0)
		if t % 2 == 0:
			_line(im, p, p + Vector2(2.6, 6.2), 1.4, RED, false)
	_line(im, Vector2(126, 104), Vector2(121, 100), 1.4, RED, false)
	_line(im, Vector2(126, 104), Vector2(128, 98), 1.4, RED, false)
	# Yarımada: üçgen kara (batıda kara surları, doğu ucunda Sarayburnu)
	var poly := PackedVector2Array([Vector2(28, 126), Vector2(96, 120), Vector2(158, 126), Vector2(212, 140), Vector2(240, 170),
		Vector2(206, 210), Vector2(140, 222), Vector2(70, 226), Vector2(32, 224)])
	for y in range(116, 230):
		for x in range(24, 244):
			if Geometry2D.is_point_in_polygon(Vector2(x, y), poly):
				im.set_pixel(x, y, PAPER.darkened(0.04 + rng.randf() * 0.02))
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i + 1) % poly.size()]
		if i == poly.size() - 1:
			# Kara surları: çift hat ve burçlar
			for t in range(0, 11):
				var p := a.lerp(b, t / 10.0)
				_dot(im, p, 2.6, INK)
			continue
		_line(im, a, b, 1.6, INK, false)
	_line(im, Vector2(22, 128), Vector2(26, 226), 1.4, INK, false)
	for t in range(0, 9):
		var p := Vector2(24, 132).lerp(Vector2(28, 222), t / 8.0)
		for yy in range(-3, 4):
			for xx in range(-3, 4):
				_blend(im, int(p.x + xx), int(p.y + yy), INK)
	# Saldırı oku batıdan surlara
	_line(im, Vector2(4, 180), Vector2(16, 178), 2.4, RED, false)
	_line(im, Vector2(16, 178), Vector2(10, 172), 2.0, RED, false)
	_line(im, Vector2(16, 178), Vector2(10, 185), 2.0, RED, false)
	# Ayasofya: kubbe, yarım kubbeler, gövde
	var hs := Vector2(194, 180)
	_arc(im, hs, 13.0, 12.0, PI, TAU, 2.0, INK)
	_arc(im, hs + Vector2(-15, 4), 7.0, 6.0, PI, TAU, 1.6, INK)
	_arc(im, hs + Vector2(15, 4), 7.0, 6.0, PI, TAU, 1.6, INK)
	_line(im, hs + Vector2(-24, 4), hs + Vector2(24, 4), 1.6, INK, false)
	_line(im, hs + Vector2(-24, 4), hs + Vector2(-24, 14), 1.4, INK, false)
	_line(im, hs + Vector2(24, 4), hs + Vector2(24, 14), 1.4, INK, false)
	# Zincir: Sarayburnu'ndan Galata'ya halkalar (Haliç'in ağzı)
	for t in range(0, 12):
		var p := Vector2(226, 148).lerp(Vector2(220, 80), t / 11.0)
		_arc(im, p, 2.6, 3.4, 0.0, TAU, 1.0, INK)
	# Marmara'da birkaç dalga
	for k in 5:
		var wp := Vector2(96 + k * 26, 262 + (k % 2) * 16)
		_arc(im, wp, 5.0, 2.5, PI, TAU, 1.0, Color(INK, 0.45))
		_arc(im, wp + Vector2(10, 0), 5.0, 2.5, PI, TAU, 1.0, Color(INK, 0.45))
	# Kızıl Elma: sağ alt köşe
	_dot(im, Vector2(226, 300), 9.0, Color(0.7, 0.12, 0.1, 0.85))
	_line(im, Vector2(226, 291), Vector2(229, 285), 1.6, INK, false)
	_arc(im, Vector2(233, 287), 4.0, 2.0, 0.0, TAU, 1.2, Color(0.25, 0.42, 0.2, 0.9))
	if tolga:
		# Fesli, ıslak adam Marmara'da yüzer: yuvarlak yüz, bıyık, fes, çevresinde damlalar ve halka halka su
		var f := Vector2(58, 274)
		_arc(im, f + Vector2(0, 16), 20.0, 5.0, 0.0, TAU, 1.0, Color(INK, 0.5))
		_arc(im, f, 11.0, 12.0, 0.0, TAU, 1.6, INK)
		for y in range(int(f.y - 24), int(f.y - 11)):
			var half := 7.0 + (y - (f.y - 24)) * 0.25
			for x in range(int(f.x - half), int(f.x + half)):
				_blend(im, x, y, Color(0.7, 0.12, 0.1, 0.9))
		_line(im, f + Vector2(4, -24), f + Vector2(12, -18), 1.2, INK, false)
		_arc(im, f + Vector2(-4, 4), 4.0, 2.0, 0.0, PI, 1.4, INK)
		_arc(im, f + Vector2(4, 4), 4.0, 2.0, 0.0, PI, 1.4, INK)
		_dot(im, f + Vector2(-4, -3), 1.3, INK)
		_dot(im, f + Vector2(4, -3), 1.3, INK)
		for k in 4:
			_dot(im, f + Vector2(-22 + k * 14, -6 - (k % 2) * 8), 1.6, Color(0.3, 0.5, 0.8, 0.85))


## Batlamyus usulü dünya haritası (Ptolemaios'un ikinci izdüşümü): yelpaze biçimli çerçeve, eğri enlemler ve ışınsal
## boylamlar; kara krem-toprak rengi, denizler sulu boya (Okyanus batıda, Akdeniz, Karadeniz, Hazar, Kızıldeniz,
## Basra, Hint denizi). Kostantiniyye kırmızı noktayla işaretli. Üstte kırmızı başlık satırı.
static func _map() -> Image:
	var mw := 256
	var mh := 176
	var im := Image.create(mw, mh, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 150
	var c0 := Vector2(128, -150)
	var r0 := 180.0
	var r1 := 320.0
	var half := deg_to_rad(22.0)
	var land := Color("dcc8a0")
	var sea := Color("9fb8c4")
	var seas := [[Vector2(100, 96), 54.0, 11.0, -0.08], [Vector2(152, 102), 24.0, 9.0, 0.1], [Vector2(104, 82), 4.0, 12.0, 0.6],
		[Vector2(140, 88), 6.0, 10.0, 0.0], [Vector2(162, 70), 20.0, 7.0, 0.05], [Vector2(206, 66), 6.0, 14.0, 0.0],
		[Vector2(176, 126), 3.5, 18.0, -0.4], [Vector2(214, 116), 4.0, 12.0, -0.6], [Vector2(214, 172), 64.0, 30.0, 0.0]]
	var mask := PackedByteArray()
	mask.resize(mw * mh)
	mask.fill(2)
	for y in mh:
		for x in mw:
			var ex := minf(float(x), float(mw - 1 - x)) / mw
			var ey := minf(float(y), float(mh - 1 - y)) / mh
			var edge := clampf(1.0 - minf(ex, ey) * 9.0, 0.0, 1.0)
			var col := PAPER.darkened(edge * 0.2 + rng.randf() * 0.025)
			var v := Vector2(x, y) - c0
			var r := v.length()
			var ang := absf(v.angle() - PI * 0.5)
			if r >= r0 and r <= r1 and ang <= half:
				var wet := x < 34 + int(sin(y * 0.15) * 3.0)
				if not wet:
					for sp: Array in seas:
						var q := (Vector2(x, y) - (sp[0] as Vector2)).rotated(-float(sp[3]))
						if pow(q.x / float(sp[1]), 2.0) + pow(q.y / float(sp[2]), 2.0) <= 1.0:
							wet = true
							break
				col = (sea if wet else land).darkened(edge * 0.15 + rng.randf() * 0.03)
				mask[y * mw + x] = 1 if wet else 0
			im.set_pixel(x, y, col)
	# Kıyılar: yalnız kara ile denizin değdiği yerde tek çizgi (elipsler üst üste binse de iç çizgi kalmaz)
	for y in range(1, mh - 1):
		for x in range(1, mw - 1):
			var m := mask[y * mw + x]
			if m == 2:
				continue
			for o: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n := mask[(y + o.y) * mw + x + o.x]
				if n != 2 and n != m:
					_blend(im, x, y, Color(INK, 0.7))
					break
	# Çerçeve: üst ve alt enlem yayı, iki yan boylam; içte ince ızgara
	for rr: float in [r0, r1]:
		_arc(im, c0, rr, rr, PI * 0.5 - half, PI * 0.5 + half, 1.6, INK)
	for k in range(-5, 6):
		var a := PI * 0.5 + half * k / 5.0
		var dir := Vector2(cos(a), sin(a))
		_line(im, c0 + dir * r0, c0 + dir * r1, 1.6 if absi(k) == 5 else 0.7, INK if absi(k) == 5 else Color(INK, 0.3), false)
	for k in range(1, 5):
		var rr := lerpf(r0, r1, k / 5.0)
		_arc(im, c0, rr, rr, PI * 0.5 - half, PI * 0.5 + half, 0.7, Color(INK, 0.3))
	# Dağlar: küçük kahverengi tepecikler
	for k in 9:
		var mp := Vector2(rng.randf_range(80, 210), rng.randf_range(48, 64))
		_line(im, mp, mp + Vector2(3, -5), 1.0, Color(0.42, 0.28, 0.14, 0.8), false)
		_line(im, mp + Vector2(3, -5), mp + Vector2(6, 0), 1.0, Color(0.42, 0.28, 0.14, 0.8), false)
	# Kostantiniyye
	_dot(im, Vector2(152, 77), 3.0, Color(0.7, 0.12, 0.1, 0.95))
	_arc(im, Vector2(152, 77), 6.0, 6.0, 0.0, TAU, 1.0, Color(RED, 0.9))
	_script_row(im, 70.0, 186.0, 12.0, RED, rng)
	im.generate_mipmaps()
	return im
