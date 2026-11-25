class_name LoadingScreen
extends CanvasLayer
## Bölüm geçişlerinde yükleme ekranı (GameState._change_with_loader kurar ve kaldırır).
##   Arka plan: gidilen bölümün kapağı (assets/art/covers), karartılmış ve yavaşça yakınlaşan; kapağı olmayan sahnede
##   koyu degrade. Ortada bölüm adı ve tarihi; altta dönen saat çarkı, gerçek yükleme ilerlemesine bağlı çubuk ve her
##   açılışta değişen bir "tarihten" bilgisi ya da oyun ipucu (UI_LOADTIP_*).
## Eskiden düz siyah ekranda "Yükleniyor." yazıyordu (v0.99.13); oyun takıldı sanılıyordu.

const TIPS := 14
const GOLD := Color("d9b45a")

var _cover: TextureRect
var _bar_fill: ColorRect
var _bar_bg: ColorRect
var _label: Label
var _spinner: Control
var _t := 0.0
var _progress := 0.0
var _shown := 0.0


func _init(path: String) -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.025, 0.02)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	# Kapak: tam ekranı doldurur (kırparak), karartılır; _process'te yavaşça yakınlaşır
	var key: String = Hud.COVERS.get(path.get_file().get_basename(), "")
	var cp := "res://assets/art/covers/%s.png" % key
	if key != "" and ResourceLoader.exists(cp):
		_cover = TextureRect.new()
		_cover.texture = load(cp)
		_cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
		_cover.modulate = Color(0.55, 0.52, 0.48, 0.0)
		root.add_child(_cover)
	# Alttan yukarı koyulaşan perde: yazılar her kapakta okunsun
	var shade := TextureRect.new()
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.15))
	g.set_color(1, Color(0, 0, 0, 0.9))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	shade.texture = gt
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	box.offset_top = -250.0
	box.offset_bottom = -40.0
	box.offset_left = 80.0
	box.offset_right = -80.0
	box.add_theme_constant_override("separation", 10)
	root.add_child(box)
	var title := _title(path)
	if title != "":
		var tl := Label.new()
		tl.text = title
		if ResourceLoader.exists(Hud.FONT_TITLE):
			tl.add_theme_font_override("font", load(Hud.FONT_TITLE))
		tl.add_theme_font_size_override("font_size", 34)
		tl.add_theme_color_override("font_color", Color("f2e6c9"))
		tl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		tl.add_theme_constant_override("shadow_offset_y", 2)
		box.add_child(tl)
		var sub := _sub(path)
		if sub != "":
			var sl := Label.new()
			sl.text = sub
			sl.add_theme_font_size_override("font_size", 18)
			sl.add_theme_color_override("font_color", GOLD)
			box.add_child(sl)
	# İpucu / tarihten bilgi
	var tip := Label.new()
	tip.text = TranslationServer.translate("UI_LOADTIP_%d" % (1 + randi() % TIPS))
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(0, 52)
	tip.add_theme_font_size_override("font_size", 17)
	tip.add_theme_color_override("font_color", Color(1, 1, 1, 0.72))
	box.add_child(tip)
	# Çark + "Yükleniyor..." + ilerleme çubuğu
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	_spinner = Control.new()
	_spinner.custom_minimum_size = Vector2(30, 30)
	_spinner.draw.connect(_draw_spinner)
	row.add_child(_spinner)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 6)
	row.add_child(col)
	_label = Label.new()
	_label.text = TranslationServer.translate("UI_LOADING")
	_label.add_theme_font_size_override("font_size", 16)
	_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	col.add_child(_label)
	_bar_bg = ColorRect.new()
	_bar_bg.color = Color(1, 1, 1, 0.12)
	_bar_bg.custom_minimum_size = Vector2(0, 4)
	col.add_child(_bar_bg)
	_bar_fill = ColorRect.new()
	_bar_fill.color = GOLD
	_bar_fill.size = Vector2(0, 4)
	_bar_bg.add_child(_bar_fill)


## Yükleme perdesi açıkken bölüm kurulumunda pencereyi canlı tutar. Sahne dosyası iş parçacığında yüklenir ama seviye
## kurucuları (LandWalls, ByzCity, CampDay...) _ready içinde ana iş parçacığında 3-6 sn binlerce parça kurar; bu
## sürede pencere işletim sisteminin iletilerine cevap vermiyor, Windows "yanıt vermiyor" diyordu (tests/load_time).
## Props her parçada pump() çağırır: 150 ms'de bir pencere iletileri işlenir (giriş bu arada yutulur), perde ve
## saat çarkı ilerler, bir kare çizilir (perdeye tıklama yutulur). Perde yokken (oyun içi, otomatik test) hiçbir şey
## yapmaz.
static var current: LoadingScreen = null
static var _last_pump := 0


## Eski ad (Props._place): genel nabza yönlenir.
static func pump() -> void:
	nabiz("props")


## G19 — Genel nabız. Ağır kurulum döngüleri (v2 şehri, ordugâh, pişirme, SiegeField...) bunu sık sık çağırır; son
## nabızdan 150 ms geçtiyse pencere iletileri işlenir (Windows "yanıt vermiyor" demesin), perde açıksa perde de çizilir.
## Yalnız açık bir kurulum kapsamında (kurulum_basla/kurulum_bitir ya da yükleme perdesi) çalışır: oynanışta Props._place
## (kor parçası vb.) çağırınca tek bir if ile döner; kare ortasında olay boşaltmak tuş/fare olaylarını kaybettirirdi.
## Perde yokken force_draw YOK (yarım 3B sahne çizilir, frame_post_draw bekleyen eşyordamlar kurucunun ortasında uyanır).
## Otomatik testte process_events çağrılmaz (botların Input.parse_input_event olayları boşalmasın), yalnız saat tutulur;
## pencereli kanıt koşusu YUKLEME_OLAY=1 ile olayları işler. Yalnız ana iş parçacığı; iç içe çağrı yok.
static var _kapsam := 0
static var _kapsam_evre := ""
static var _nabizda := false
static var _olay := -1             # -1 bilinmiyor, 0 kapalı (otomatik test), 1 açık
static var _changing_once := false


static func nabiz(kaynak := "") -> void:
	if _kapsam <= 0 and current == null and not _olc_acik:
		return
	if _nabizda or OS.get_thread_caller_id() != OS.get_main_thread_id():
		return
	var now := Time.get_ticks_msec()
	if _last_pump == 0:
		_last_pump = now
		_son_kaynak = kaynak
		return
	var gap := now - _last_pump
	if gap < 150:
		return
	_bosluk_yaz(gap, kaynak)
	_last_pump = now
	_son_kaynak = kaynak
	if _kapsam <= 0 and current == null:
		return
	if _olay < 0:
		_olay = 1 if (not GameState.autotest or OS.get_environment("YUKLEME_OLAY") == "1") else 0
	if _olay == 0:
		return
	_nabizda = true
	var root := (Engine.get_main_loop() as SceneTree).root
	var perde := current != null and is_instance_valid(current) and current.is_inside_tree()
	if current != null and not perde:
		current = null
	if perde:
		current._process(minf(gap / 1000.0, 0.25))
	var was := root.gui_disable_input
	root.gui_disable_input = true
	DisplayServer.process_events()
	root.gui_disable_input = was
	if perde:
		# Yalnız perde çizilir: arkadaki yarım kurulmuş 3B sahne (opak perdenin altında görünmez) çizilseydi her pompada
		# yeni malzemelerin gölgelendiricileri derlenirdi (yazılımla çizimde kare başına 50 sn)
		var d3 := root.disable_3d
		root.disable_3d = true
		RenderingServer.force_draw(true, 0.0)
		root.disable_3d = d3
	_nabizda = false
	_last_pump = Time.get_ticks_msec()


## Perdesiz kurulum kapsamı (bölüm ortası yeniden kurulum, beyaz kararma altında): nabız bu sürede çalışır, sahne
## değişimi beklemede sayılır (GameState.changing: duraklatma menüsü açılmaz, Hud._ready bayrağı indirmez).
static func kurulum_basla(evre := "") -> void:
	if _kapsam == 0:
		_kapsam_evre = evre
		_last_pump = Time.get_ticks_msec()
		_changing_once = GameState.changing
		GameState.changing = true
	_kapsam += 1


static func kurulum_bitir() -> void:
	if _kapsam <= 0:
		return
	_kapsam -= 1
	if _kapsam == 0:
		GameState.changing = _changing_once
		_changing_once = false


static func kapsam_acik() -> bool:
	return _kapsam > 0


## G19 — YUKLEMEAUDIT: yükleme penceresindeki en uzun "canlılık boşluğu" (iki nabız ya da kare arası; ana iş parçacığı
## bu sürede pencere iletisi işlemedi). Pencere sahne değişiminin (ya da bölüm ortası kurulumun) başından sahne hazır
## olduktan 5 kare sonrasına kadar. Ölçüm kipinde (otomatik test ya da YUKLEMEAUDIT=1) her kare de bir canlılık noktasıdır.
##   ilk_kare_ms: sahne hazır olduktan sonraki ilk tam kare (çizim dahil); bosalt_ms: eski sahnenin boşaltılması.
static var _olc_acik := false
static var _olc_evre := ""
static var _olc_scene := ""
static var _olc_t0 := 0
static var _olc_en := 0
static var _olc_kaynak := ""
static var _olc_bosalt := -1
static var _olc_ilk_kare := -1
static var _olc_kare_en := 0     # pencereli: perde kalktıktan sonraki ilk 60 karenin en uzunu
static var _son_kaynak := ""
static var _olcer: Node = null


static func olcum_kipi() -> bool:
	return GameState.autotest or OS.get_environment("YUKLEMEAUDIT") == "1"


static var _iz := -1


static func _bosluk_yaz(gap: int, kaynak: String) -> void:
	if _iz < 0:
		_iz = int(OS.get_environment("YUKLEME_IZ")) if OS.get_environment("YUKLEME_IZ") != "" else 0
	if _iz > 0 and gap >= _iz:
		print("YUKLEMEIZ %d %s>%s" % [gap, _son_kaynak, kaynak])
	if _olc_acik and gap > _olc_en:
		_olc_en = gap
		_olc_kaynak = "%s>%s" % [_son_kaynak if _son_kaynak != "" else "bas", kaynak if kaynak != "" else "?"]


## Ölçüm penceresi açılır (ölçüm kipinde). sahne_bekle: yeni sahnenin hazır olmasını bekler (sahne değişimi); değilse
## olcum_kapat() çağrılana kadar açık kalır (bölüm ortası kurulum).
static func olcum_ac(evre: String, sahne_bekle: bool) -> void:
	if not olcum_kipi():
		return
	if _olc_acik:
		_olc_evre += "+" + evre
		return
	_olc_acik = true
	_olc_evre = evre
	_olc_scene = ""
	_olc_t0 = Time.get_ticks_msec()
	_olc_en = 0
	_olc_kaynak = ""
	_olc_bosalt = -1
	_olc_ilk_kare = -1
	_olc_kare_en = 0
	_son_kaynak = "bas:" + evre
	_last_pump = _olc_t0
	var tree := Engine.get_main_loop() as SceneTree
	_olcer = _Olcer.new()
	_olcer.set("sahne_bekle", sahne_bekle)
	_olcer.set("eski", tree.current_scene)
	tree.root.add_child.call_deferred(_olcer)


static func olcum_kapat() -> void:
	if _olc_acik and is_instance_valid(_olcer):
		_olcer.set("bitti", true)


static func olcum_bosalt(ms: int) -> void:
	if _olc_acik:
		_olc_bosalt = ms


static func _kare(now: int) -> void:
	if _last_pump > 0:
		var gap := now - _last_pump
		if gap > 0:
			_bosluk_yaz(gap, "kare")
	_last_pump = now
	_son_kaynak = "kare"


static func _olcum_yaz(sc: Node) -> void:
	var scene := ""
	if sc != null and is_instance_valid(sc):
		scene = sc.scene_file_path.get_file().get_basename()
		if scene == "" and sc.get_child_count() > 0:
			scene = String(sc.name)
	var top := Time.get_ticks_msec() - _olc_t0
	var satir := "scene=%s evre=%s toplam_ms=%d en_uzun_bosluk_ms=%d kaynak=%s ilk_kare_ms=%d bosalt_ms=%d" % [
		scene, _olc_evre, top, _olc_en, _olc_kaynak, _olc_ilk_kare, _olc_bosalt]
	print("YUKLEMEAUDIT " + satir)
	# İki kademe: tek başına koşuda hedef < 1000 ms (aday, listelenir); pakette (8 parça CPU paylaşır) ≥ 2500 ms kesin hata
	if _olc_en >= 2500:
		print("YUKLEMEAUDIT_KESIN " + satir)
	elif _olc_en >= 1000:
		print("YUKLEMEAUDIT_ADAY " + satir)
	_olc_acik = false
	_olcer = null


## Ölçüm penceresinin kare saati: her _process bir canlılık noktası; sahne hazır olunca 5 kare sonra satırı basar.
class _Olcer extends Node:
	var sahne_bekle := true
	var bitti := false
	var eski: Node = null
	var _hazir_t := -1
	var _sayac := 0
	var _kare60 := 0
	var _sc: Node = null

	func _init() -> void:
		name = "YuklemeOlcer"
		process_mode = Node.PROCESS_MODE_ALWAYS
		process_priority = -1000

	func _process(_d: float) -> void:
		var now := Time.get_ticks_msec()
		var gap := now - LoadingScreen._last_pump
		LoadingScreen._kare(now)
		if _hazir_t >= 0:
			if LoadingScreen._olc_ilk_kare < 0:
				LoadingScreen._olc_ilk_kare = now - _hazir_t
			if _sayac >= 5:
				LoadingScreen._olc_kare_en = maxi(LoadingScreen._olc_kare_en, gap)
		var sc := get_tree().current_scene
		if _hazir_t < 0:
			var hazir := false
			if sahne_bekle:
				hazir = sc != null and sc != eski and is_instance_valid(sc) and sc.is_node_ready()
			else:
				hazir = bitti
			if hazir:
				_hazir_t = now
				_sc = sc
			return
		_sayac += 1
		if _sayac == 5:
			LoadingScreen._olcum_yaz(_sc)
			if DisplayServer.get_name() == "headless":
				queue_free()
				return
		if _sayac >= 65:
			if DisplayServer.get_name() != "headless":
				print("YUKLEMEAUDIT_PENCERE scene=%s ilk_kare_ms=%d sonraki60_en_ms=%d" % [
					_sc.scene_file_path.get_file().get_basename() if is_instance_valid(_sc) else "",
					LoadingScreen._olc_ilk_kare, LoadingScreen._olc_kare_en])
			queue_free()


func _enter_tree() -> void:
	current = self
	_last_pump = 0 if not _olc_acik else _last_pump


func _exit_tree() -> void:
	if current == self:
		current = null


## Gerçek yükleme ilerlemesi (0–1): ResourceLoader.load_threaded_get_status'tan
func set_progress(p: float) -> void:
	_progress = clampf(maxf(_progress, p), 0.0, 1.0)


func _process(delta: float) -> void:
	_t += delta
	# Çubuk ilerlemeye yumuşakça yetişir; ilerleme gelmezse de yavaşça kıpırdar (donmuş görünmesin)
	_shown = minf(lerpf(_shown, maxf(_progress, minf(0.9, 1.0 - exp(-_t * 0.25))), minf(1.0, delta * 4.0)), 1.0)
	if _bar_fill and _bar_bg:
		_bar_fill.size = Vector2(_bar_bg.size.x * _shown, _bar_bg.size.y)
	if _label:
		_label.text = TranslationServer.translate("UI_LOADING") + ".".repeat(1 + int(_t * 3.0) % 3)
	if _cover:
		_cover.modulate.a = minf(1.0, _cover.modulate.a + delta * 2.5)
		var s := 1.0 + minf(_t, 20.0) * 0.006
		_cover.pivot_offset = _cover.size * 0.5
		_cover.scale = Vector2(s, s)
	if _spinner:
		_spinner.queue_redraw()


## Saat çarkı: dönen altın yay ve içinde ters dönen kısa ibre
func _draw_spinner() -> void:
	var c := _spinner.size * 0.5
	var r := minf(c.x, c.y) - 2.0
	_spinner.draw_arc(c, r, 0.0, TAU, 40, Color(1, 1, 1, 0.12), 3.0, true)
	var a := _t * 4.0
	_spinner.draw_arc(c, r, a, a + PI * 0.7, 24, GOLD, 3.0, true)
	var h := -_t * 1.3
	_spinner.draw_line(c, c + Vector2(cos(h), sin(h)) * r * 0.55, Color(1, 1, 1, 0.7), 2.0, true)
	_spinner.draw_circle(c, 2.5, GOLD)


static func _key(path: String) -> String:
	return path.get_file().get_basename().trim_prefix("chapter").to_upper()


static func _title(path: String) -> String:
	if not path.get_file().begins_with("chapter"):
		return ""
	var k := _key(path)
	for key: String in ["UI_CH%s_TITLE" % k, "UI_CH%sA_TITLE" % k]:
		var t := String(TranslationServer.translate(key))
		if t != key:
			return Siege.fill_number(t, path).replace("  ", " ")
	return ""


static func _sub(path: String) -> String:
	var key := "UI_CH%s_SUB" % _key(path)
	var t := String(TranslationServer.translate(key))
	return t if t != key else ""
