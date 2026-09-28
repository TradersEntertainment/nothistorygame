class_name IconArt
extends RefCounted
## Bizans ikonaları (yordamsal boyama, dosya yok).
## hodegetria(): Meryem Hodegetria. Meryem, Çocuk İsa'yı sol kolunda tutar, sağ eliyle O'nu gösterir. Altın zemin,
## koyu kırmızı-mor maforion (altın kenar şeridi, alında ve omuzlarda üç yıldız), altındaki mavi başörtüsü,
## zeytin gölgeli ten, badem gözler. Çocuk'un haçlı halesi, altın yollu (khrysographia) aşı boyası giysisi,
## elinde tomar, kutsayan eli. Kırmızı çerçeve.

static var _cache: ImageTexture

const W := 240
const H := 320


static func hodegetria() -> ImageTexture:
	if _cache:
		return _cache
	var img := Image.create(W, H, false, Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	# Altın zemin: hafif dövme varak dokusu, yukarıdan aşağı ısınan ton
	for y in H:
		for x in W:
			var t := float(y) / H
			var c := Color("d8b458").lerp(Color("c49a3e"), t) * (0.94 + rng.randf() * 0.1)
			img.set_pixel(x, y, c)
	var maf := Color("5a1e2a")        # maforion
	var maf_d := Color("3e1420")
	var trim := Color("e0b84e")
	var blue := Color("24365e")
	var skin := Color("c89468")
	var olive := Color("8a7048")
	var red := Color("9a2a22")
	# Haleler (başların arkasında): kırmızı dış çizgi, açık altın iç
	_ring(img, 138, 104, 60, 64, red)
	_disc(img, 138, 104, 60, Color("e8c868"))
	_ring(img, 138, 104, 57, 59, Color("b8923e"))
	_ring(img, 74, 176, 30, 33, red)
	_disc(img, 74, 176, 30, Color("e8c868"))
	# Çocuk'un haçlı halesi: üç kol kırmızı
	_rect(img, 71, 146, 77, 160, red)
	_rect(img, 44, 173, 56, 179, red)
	_rect(img, 92, 173, 104, 179, red)
	# Meryem'in gövdesi (maforion omuzlardan aşağı), başı saran örtü
	_ellipse(img, 132, 272, 112, 150, maf)
	_ellipse(img, 138, 104, 50, 56, maf)
	# Kıvrım çizgileri (koyu)
	for k in 5:
		_line(img, 170 + k * 12, 170 + k * 6, 150 + k * 18, 318, 2, maf_d)
	_line(img, 96, 160, 70, 318, 2, maf_d)
	# Altın kenar şeridi: yüzü çevreler ve omuzlara iner
	_ring(img, 138, 108, 33, 38, trim)
	_line(img, 108, 132, 92, 178, 4, trim)
	_line(img, 168, 132, 190, 176, 4, trim)
	# Mavi başörtüsü (alında ince şerit)
	_ellipse(img, 138, 94, 26, 12, blue)
	# Yüz: uzun, zeytin gölgeli ten
	_ellipse(img, 138, 112, 25, 32, olive)
	_ellipse(img, 139, 114, 21, 28, skin)
	_ellipse(img, 146, 110, 10, 16, skin.lightened(0.12))
	# Kaşlar, badem gözler, uzun ince burun, küçük ağız
	_line(img, 124, 101, 134, 99, 2, Color("3a2418"))
	_line(img, 144, 99, 154, 101, 2, Color("3a2418"))
	_ellipse(img, 129, 106, 5, 3, Color("f0e4cc"))
	_ellipse(img, 149, 106, 5, 3, Color("f0e4cc"))
	_disc(img, 129, 106, 2, Color("2a1a10"))
	_disc(img, 149, 106, 2, Color("2a1a10"))
	_line(img, 139, 104, 137, 122, 1, Color("6a4428"))
	_line(img, 134, 123, 140, 124, 1, Color("6a4428"))
	_line(img, 134, 131, 143, 131, 2, Color("9a3a2a"))
	# Üç yıldız: alında ve iki omuzda
	for st: Vector2i in [Vector2i(138, 82), Vector2i(98, 170), Vector2i(186, 168)]:
		_line(img, st.x - 5, st.y, st.x + 5, st.y, 2, trim)
		_line(img, st.x, st.y - 5, st.x, st.y + 5, 2, trim)
		_disc(img, st.x, st.y, 2, trim)
	# Çocuk: aşı boyası giysi, altın yollar; tomar ve kutsayan el
	_ellipse(img, 80, 228, 34, 46, Color("b8743a"))
	for k in 6:
		_line(img, 58 + k * 8, 196, 52 + k * 9, 268, 1, Color("f0d078"))
	_ellipse(img, 74, 176, 14, 17, olive)
	_ellipse(img, 75, 177, 12, 15, skin)
	_disc(img, 70, 174, 2, Color("2a1a10"))
	_disc(img, 80, 174, 2, Color("2a1a10"))
	_line(img, 72, 185, 78, 185, 1, Color("9a3a2a"))
	_ellipse(img, 72, 162, 12, 5, Color("5a3a22"))
	_ellipse(img, 106, 204, 7, 8, skin)                      # kutsayan el
	_line(img, 104, 196, 106, 188, 2, skin)
	_line(img, 108, 196, 110, 189, 2, skin)
	_ellipse(img, 62, 250, 7, 16, Color("e8dcc0"))           # tomar
	_line(img, 56, 238, 68, 238, 1, Color("8a6a40"))
	# Meryem'in sağ eli (Çocuğu gösterir) ve sol eli (Çocuğu taşır)
	_ellipse(img, 132, 232, 12, 16, skin)
	_line(img, 124, 222, 116, 214, 3, skin)
	_ellipse(img, 70, 282, 20, 10, skin)
	# Kısaltmalar (kırmızı, üstlerinde kısaltma çizgisi): ΜΡ ΘΥ (Meter Theou) ve IC XC (Iesous Khristos)
	_text(img, 16, 30, "MP", red)
	_text(img, 190, 30, "0Y", red)
	_text(img, 12, 136, "IC", red)
	_text(img, 12, 212, "XC", red)
	# Çerçeve: kırmızı bant, içinde ince altın çizgi
	_rect(img, 0, 0, W - 1, 7, red)
	_rect(img, 0, H - 8, W - 1, H - 1, red)
	_rect(img, 0, 0, 7, H - 1, red)
	_rect(img, W - 8, 0, W - 1, H - 1, red)
	_rect(img, 8, 8, W - 9, 9, trim)
	_rect(img, 8, H - 10, W - 9, H - 9, trim)
	_rect(img, 8, 8, 9, H - 9, trim)
	_rect(img, W - 10, 8, W - 9, H - 9, trim)
	# Yaşlanma: kararmış vernik (kenarlarda koyu), mum isi
	for y in H:
		for x in W:
			var dx := (float(x) / W - 0.5) * 2.0
			var dy := (float(y) / H - 0.5) * 2.0
			var v := clampf(1.0 - (dx * dx + dy * dy) * 0.18, 0.7, 1.0)
			img.set_pixel(x, y, img.get_pixel(x, y) * Color(v, v * 0.98, v * 0.9))
	img.generate_mipmaps()
	_cache = ImageTexture.create_from_image(img)
	return _cache


## Küçük kapital harfler (h 16 px, çizgiyle): M P Y I C X ve 0 (Θ: ortası çizgili oval). Üstte kısaltma çizgisi.
static func _text(img: Image, x0: int, y0: int, txt: String, c: Color) -> void:
	var w := 11
	var h := 16
	var x := x0
	for ch in txt:
		match ch:
			"M":
				_line(img, x, y0 + h, x, y0, 2, c)
				_line(img, x, y0, x + w / 2, y0 + h * 6 / 10, 2, c)
				_line(img, x + w / 2, y0 + h * 6 / 10, x + w, y0, 2, c)
				_line(img, x + w, y0, x + w, y0 + h, 2, c)
			"P":
				_line(img, x, y0, x, y0 + h, 2, c)
				_line(img, x, y0, x + w * 7 / 10, y0, 2, c)
				_line(img, x + w * 7 / 10, y0, x + w, y0 + h / 4, 2, c)
				_line(img, x + w, y0 + h / 4, x + w * 7 / 10, y0 + h / 2, 2, c)
				_line(img, x + w * 7 / 10, y0 + h / 2, x, y0 + h / 2, 2, c)
			"0":
				for k in 24:
					var a := TAU * k / 24.0
					_put(img, x + w / 2 + int(cos(a) * w * 0.55), y0 + h / 2 + int(sin(a) * h * 0.5), c)
					_put(img, x + w / 2 + int(cos(a) * w * 0.55) + 1, y0 + h / 2 + int(sin(a) * h * 0.5), c)
				_line(img, x + 2, y0 + h / 2, x + w - 2, y0 + h / 2, 2, c)
			"Y":
				_line(img, x, y0, x + w / 2, y0 + h / 2, 2, c)
				_line(img, x + w, y0, x + w / 2, y0 + h / 2, 2, c)
				_line(img, x + w / 2, y0 + h / 2, x + w / 2, y0 + h, 2, c)
			"I":
				_line(img, x + w / 2, y0, x + w / 2, y0 + h, 2, c)
			"C":
				_line(img, x + w, y0 + 2, x + 3, y0, 2, c)
				_line(img, x + 3, y0, x, y0 + h / 2, 2, c)
				_line(img, x, y0 + h / 2, x + 3, y0 + h, 2, c)
				_line(img, x + 3, y0 + h, x + w, y0 + h - 2, 2, c)
			"X":
				_line(img, x, y0, x + w, y0 + h, 2, c)
				_line(img, x + w, y0, x, y0 + h, 2, c)
		x += w + 5
	_line(img, x0, y0 - 5, x - 5, y0 - 5, 2, c)


static func _put(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < W and y < H:
		img.set_pixel(x, y, c)


static func _rect(img: Image, x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	for y in range(maxi(y0, 0), mini(y1, H - 1) + 1):
		for x in range(maxi(x0, 0), mini(x1, W - 1) + 1):
			img.set_pixel(x, y, c)


static func _ellipse(img: Image, cx: int, cy: int, rx: int, ry: int, c: Color) -> void:
	for y in range(maxi(cy - ry, 0), mini(cy + ry, H - 1) + 1):
		for x in range(maxi(cx - rx, 0), mini(cx + rx, W - 1) + 1):
			var u := float(x - cx) / rx
			var v := float(y - cy) / ry
			if u * u + v * v <= 1.0:
				img.set_pixel(x, y, c)


static func _disc(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	_ellipse(img, cx, cy, maxi(r, 1), maxi(r, 1), c)


static func _ring(img: Image, cx: int, cy: int, r0: int, r1: int, c: Color) -> void:
	for y in range(maxi(cy - r1, 0), mini(cy + r1, H - 1) + 1):
		for x in range(maxi(cx - r1, 0), mini(cx + r1, W - 1) + 1):
			var d := Vector2(x - cx, y - cy).length()
			if d >= r0 and d <= r1:
				img.set_pixel(x, y, c)


static func _line(img: Image, x0: int, y0: int, x1: int, y1: int, w: int, c: Color) -> void:
	var n := maxi(absi(x1 - x0), absi(y1 - y0))
	for i in n + 1:
		var t := float(i) / maxf(n, 1)
		var x := int(round(lerpf(x0, x1, t)))
		var y := int(round(lerpf(y0, y1, t)))
		for oy in range(-(w / 2), w - w / 2):
			for ox in range(-(w / 2), w - w / 2):
				_put(img, x + ox, y + oy, c)
