class_name TolgaQuips
extends PanelContainer
## Ayarlarda Tolga'nın yorumları (v0.92): bir ayar değişince Tolga sağ alt köşede kısa bir laf eder. Her ayar ve değer
## aralığı ("kova": kapalı / en yüksek / ara değer, açık / kapalı, kalite ve zorluk düzeyleri, dil) için 2-3 replik
## (DSET_T_<KOVA>_<n>), karışık sırayla; bir kovanın bütün replikleri söylenmeden aynısı gelmez, art arda hiç gelmez.
## Kaydırıcıda bırakınca (0,6 sn durunca), düğmede hemen; art arda değişikliklerde yalnız sonuncusuna konuşur. Canlı portre
## (PortraitStudio), varsa seslendirme yoksa mırıltı; yazı daktilo gibi akar, okuma süresi kadar kalır, sonra söner.

const SPEAKER := "SPK_TOLGA"
const SLIDER_WAIT := 0.6
const MIN_SHOW := 1.2         # yeni laf, öncekini en az bu kadar gösterdikten sonra keser
const W := 300.0
const PIC := 80.0
const MARGIN := 16.0

var said: Array[String] = []  # söylenen anahtarlar (test okur)
var _studio: PortraitStudio
var _pic: TextureRect
var _text: Label
var _mumble: Mumble
var _voice: AudioStreamPlayer
var _pending := ""
var _pending_t := 0.0
var _shown_t := -1.0          # şu anki laf ne zamandır ekranda (-1: yok)
var _hold := 0.0              # laf bittikten sonra ekranda kalma
var _bags := {}               # kova -> karışık anahtar sırası
var _last := ""
var _tw: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.09, 0.94)
	sb.border_color = Color("8ecbff")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(12)
	add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	_pic = TextureRect.new()
	_pic.custom_minimum_size = Vector2(PIC, PIC)
	_pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_pic)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	var nm := Label.new()
	nm.text = tr(SPEAKER)
	nm.add_theme_font_size_override("font_size", 15)
	nm.add_theme_color_override("font_color", Color("8ecbff"))
	col.add_child(nm)
	_text = Label.new()
	_text.custom_minimum_size = Vector2(W - PIC - 12 - 24, 0)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING     # kutu yazı akarken büyümesin
	_text.add_theme_font_size_override("font_size", 16)
	_text.add_theme_color_override("font_color", Color("f2e6c9"))
	col.add_child(_text)
	_studio = PortraitStudio.new()
	_studio.box = self
	add_child(_studio)
	_mumble = Mumble.new()
	_mumble.bus = "Voice"
	add_child(_mumble)
	_voice = AudioStreamPlayer.new()
	_voice.bus = "Voice"
	add_child(_voice)
	modulate.a = 0.0
	visible = false
	if not GameState.autotest:
		_studio.prewarm.call_deferred([SPEAKER])
	get_viewport().size_changed.connect(_layout)
	_layout()


## Sağ alt köşe, ayarlar panelinin sağındaki boşlukta (genişlik boşluğa göre 240–340); boşluk çok darsa panelin üstüne
## biner (laf birkaç saniye sürer). Köşeye çapalı, yazı uzadıkça yukarı doğru büyür (ekranın altına taşmaz).
func _layout() -> void:
	var vs := get_viewport().get_visible_rect().size
	var w := W
	var panel = get_parent().get("_panel") if get_parent() else null
	if panel is Control:
		var free: float = vs.x - (panel as Control).get_global_rect().end.x - 16.0 - MARGIN
		w = clampf(free, 240.0, 340.0)
	_text.custom_minimum_size.x = w - PIC - 12.0 - 24.0
	custom_minimum_size.x = w
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	offset_right = -MARGIN
	offset_bottom = -MARGIN
	offset_left = -MARGIN - w
	offset_top = -MARGIN - (PIC + 24.0)


## Bir ayar değişti: key GameState.settings anahtarı (ya da "lang", "keys", "open"), value yeni değeri.
func setting_changed(key: String, value: Variant) -> void:
	var b := bucket(key, value)
	if b == "":
		return
	_pending = b
	_pending_t = SLIDER_WAIT if value is float and key in SLIDERS else 0.15


const SLIDERS := ["music", "sfx", "voice", "mouse", "pad_sens", "fov", "fx", "subs"]
const ACTION := {"music": "MUSIC", "sfx": "SFX", "voice": "VOICE", "mouse": "MOUSE", "pad_sens": "PAD", "invert_y": "INVERT",
	"fullscreen": "FULLSCREEN", "vsync": "VSYNC", "quality": "QUALITY", "fov": "FOV", "fx": "FX", "difficulty": "DIFF",
	"subs": "SUBS", "markers": "MARKERS", "minimap": "MINIMAP", "auto_advance": "AUTO", "timed_choices": "TIMED", "fps": "FPS",
	"lang": "LANG", "keys": "KEYS", "open": "OPEN"}


## Ayar ve değerden kova: MUSIC_OFF, FOV_WIDE, DIFF_D2, INVERT_ON, LANG_EN...
static func bucket(key: String, value: Variant) -> String:
	var a: String = ACTION.get(key, "")
	if a == "":
		return ""
	match key:
		"music", "sfx", "voice", "fx":
			var v := float(value)
			return a + ("_OFF" if v <= 0.001 else ("_MAX" if v >= 0.999 else "_ANY"))
		"mouse", "pad_sens":
			var v := float(value)
			return a + ("_SLOW" if v <= 0.6 else ("_FAST" if v >= 2.0 else "_ANY"))
		"fov":
			var v := float(value)
			return a + ("_NARROW" if v <= 68.0 else ("_WIDE" if v >= 92.0 else "_ANY"))
		"subs":
			var v := float(value)
			return a + ("_SMALL" if v <= 0.85 else ("_BIG" if v >= 1.45 else "_ANY"))
		"quality":
			return a + "_Q%d" % int(value)
		"difficulty":
			return a + "_D%d" % int(value)
		"lang":
			return a + "_" + str(value).substr(0, 2).to_upper()
		"keys":
			return a + "_" + str(value).to_upper()
		"open":
			return a
	return a + ("_ON" if bool(value) else "_OFF")


## Kovanın replikleri: DSET_T_<KOVA>_1, _2, ... (çevirisi olanlar)
static func lines(b: String) -> Array[String]:
	var out: Array[String] = []
	for n in range(1, 7):
		var k := "DSET_T_%s_%d" % [b, n]
		if TranslationServer.translate(k) == k:
			break
		out.append(k)
	return out


## Kovadan sıradaki replik: karışık torba; torba yenilenince ilk replik bir önceki söylenen olmasın
func pick(b: String) -> String:
	var bag: Array = _bags.get(b, [])
	if bag.is_empty():
		bag = lines(b)
		if bag.is_empty():
			return ""
		bag.shuffle()
		if bag.size() > 1 and bag[0] == _last:
			bag.push_back(bag.pop_front())
		_bags[b] = bag
	return bag.pop_front()


func _process(delta: float) -> void:
	if _pending != "":
		_pending_t -= delta
		if _pending_t <= 0.0 and (_shown_t < 0.0 or _shown_t >= MIN_SHOW):
			var k := pick(_pending)
			_pending = ""
			if k != "":
				_say(k)
	if _shown_t >= 0.0:
		_shown_t += delta
		if not _voice.playing and _text.visible_ratio >= 1.0:
			_hold -= delta
			if _hold <= 0.0:
				_fade_out()


func _say(k: String) -> void:
	_last = k
	said.append(k)
	_text.text = tr(k)
	_shown_t = 0.0
	visible = true
	_layout()
	if _tw:
		_tw.kill()
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(self, "modulate:a", 1.0, 0.15)
	_text.visible_ratio = 0.0
	var dur := clampf(_text.text.length() * 0.028, 0.4, 2.2)
	var path := "res://assets/audio/voice/%s/%s.mp3" % [TranslationServer.get_locale().substr(0, 2), k]
	_voice.stop()
	_mumble.stop_speaking()
	if ResourceLoader.exists(path):
		_voice.stream = load(path)
		_voice.volume_db = VoiceGain.DB.get(k, 0.0)
		_voice.play()
		dur = clampf(_voice.stream.get_length() * 0.85, 0.4, 12.0)
	elif not GameState.autotest:
		_mumble.speak(dur, Hud.VOICE.get(SPEAKER, 210.0))
	_tw.tween_property(_text, "visible_ratio", 1.0, dur)
	_hold = clampf(_text.text.length() * 0.045 + 0.8, 1.8, 6.0)
	if not GameState.autotest and _studio.show_for(SPEAKER):
		_pic.texture = _studio.get_texture()


func _fade_out() -> void:
	_shown_t = -1.0
	_mumble.stop_speaking()
	if _tw:
		_tw.kill()
	_tw = create_tween()
	_tw.tween_property(self, "modulate:a", 0.0, 0.3)
	_tw.tween_callback(func():
		visible = false
		_studio.stop())


## Sayfadan çıkılınca: yarım kalan laf kesilir
func hush() -> void:
	_pending = ""
	_voice.stop()
	if _shown_t >= 0.0:
		_fade_out()
