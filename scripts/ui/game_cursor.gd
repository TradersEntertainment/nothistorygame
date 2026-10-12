class_name GameCursor
## Oyunun fare imleci (v0.99.11, arkadaş notu: "oyuna özel imleç"): sistem oku yerine bir ok ucu. Kemik rengi
## demir uç, ceviz şaft, biri kırmızı biri kemik iki tüy. Düğme ve kaydırıcıların üstünde uç altına döner, çevresi
## menülerin turkuaz vurgusuyla parlar. Çizimler SVG'den ekran çözünürlüğüne göre üretilir (1080p'de 32 px,
## 4K'da 64 px): bulanık büyütülmüş bir resim değil.
##
## GameState açılışta kurar. Ağaca eklenen her düğme ve kaydırıcı kendiliğinden "el" imlecini alır.

const BASE := 64.0
## Ok ucunun sivri noktası (64'lük çizimde): tıklama burada
const HOT := Vector2(3, 3)

const SHAFT := """
  <path d="M15 15 L51 51" stroke="#24160c" stroke-width="7" stroke-linecap="round"/>
  <path d="M15 15 L51 51" stroke="#a8743c" stroke-width="3.4" stroke-linecap="round"/>
  <path d="M40 40 L47 37 L55 45 L52 52 Z" fill="#b8322b" stroke="#24160c" stroke-width="2.4" stroke-linejoin="round"/>
  <path d="M40 40 L37 47 L45 55 L52 52 Z" fill="#efe2c0" stroke="#24160c" stroke-width="2.4" stroke-linejoin="round"/>
"""
const SHADOW := """
  <g transform="translate(2.5,3)" opacity="0.32">
    <path d="M3 3 L27 10 L17 17 L10 27 Z" fill="#000"/>
    <path d="M15 15 L51 51" stroke="#000" stroke-width="7" stroke-linecap="round"/>
  </g>
"""
const HEAD := """
  <path d="M3 3 L27 10 L17 17 L10 27 Z" fill="%s" stroke="#24160c" stroke-width="2.6" stroke-linejoin="round"/>
  <path d="M6.5 6.5 L20 10.5 L14 14 Z" fill="#ffffff" opacity="0.55"/>
"""
const GLOW := """
  <path d="M3 3 L27 10 L17 17 L10 27 Z" fill="none" stroke="#6ff2c8" stroke-width="7" stroke-linejoin="round" opacity="0.55"/>
"""

static var _size := 0


## Ekrana göre boyut: 1080p'ye kadar 32, üstünde orantılı (8'in katı), en çok 64.
static func size_for(screen_h: int) -> int:
	return clampi(int(round(32.0 * clampf(screen_h / 1080.0, 1.0, 2.0) / 8.0)) * 8, 32, 64)


static func svg(hover: bool) -> String:
	var body := SHADOW + SHAFT + (GLOW if hover else "") + HEAD % ("#ffd24a" if hover else "#f2e6c9")
	return '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">%s</svg>' % body


static func texture(hover: bool, px: int) -> ImageTexture:
	var img := Image.new()
	img.load_svg_from_string(svg(hover), px / BASE)
	return ImageTexture.create_from_image(img)


static func install(tree: SceneTree) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_apply()
	tree.root.size_changed.connect(_apply)
	tree.node_added.connect(_on_node_added)


static func _apply() -> void:
	var px := size_for(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()).y)
	if px == _size:
		return
	_size = px
	var hot := HOT * (px / BASE)
	Input.set_custom_mouse_cursor(texture(false, px), Input.CURSOR_ARROW, hot)
	Input.set_custom_mouse_cursor(texture(true, px), Input.CURSOR_POINTING_HAND, hot)


## Çıkışta imleç resimleri bırakılır (çizim sunucusu kapanmadan: yoksa çıkışta "sızan doku" uyarısı)
static func uninstall() -> void:
	if _size == 0:
		return
	_size = 0
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)


static func _on_node_added(n: Node) -> void:
	if (n is BaseButton or n is Slider) and (n as Control).mouse_default_cursor_shape == Control.CURSOR_ARROW:
		(n as Control).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
