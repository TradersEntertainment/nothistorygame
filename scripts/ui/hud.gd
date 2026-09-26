class_name Hud
extends CanvasLayer
## Oyun arayüzü: altyazılar, seçimler, hedef, çanta, tuş takımı, telsiz,
## kırmızı düğme, fes görünümü, karartma, başlık kartları, akış şeması, duraklatma.
## Sahneyi yöneten betik (chapter1.gd) buradaki async fonksiyonları `await` ile çağırır.

signal _choice_made(index: int)

const C_PANEL := Color(0.06, 0.07, 0.1, 0.82)
const C_ACCENT := Color("6ff2c8")
const SPEAKER_COLORS := {
	"SPK_HIKMET": Color("ffc98a"),
	"SPK_TOLGA": Color("8ecbff"),
	"SPK_NIHAT": Color("c9b8ff"),
	"SPK_MUFIDE": Color("ff9ab0"),
	"SPK_RIZA": Color("e8d090"),
	"SPK_NIKO": Color("ff9a7a"),
	"SPK_HASAN": Color("ff8a8a"),
	"SPK_HUSEYIN": Color("8ab4ff"),
	"SPK_GUARDS": Color("d8b0ff"),
	"SPK_KADRI": Color("ffd08a"),
	"SPK_CEMIL": Color("9ac8ff"),
	"SPK_PASHA": Color("a8d890"),
	"SPK_AGA": Color("ff9a6a"),
	"SPK_CAMELEER": Color("e0c080"),
	"SPK_DERVISH": Color("f0f0e0"),
	"SPK_TAILOR": Color("e08aa0"),
	"SPK_FATIH": Color("ffd24a"),
	"SPK_MANAGER": Color("b0c4d8"),
	"SPK_RIDER": Color("a8c8f0"),
	"SPK_ENVOY": Color("d8b878"),
	"SPK_FISHMONGER": Color("a8c0d0"),
	"SPK_WINE": Color("d890a0"),
	"SPK_NOTARY": Color("b8b8c8"),
	"SPK_DOUBLE": Color("e8b870"),
	"SPK_CAPTAIN": Color("90b0e0"),
	"SPK_SINERJI": Color("fff4c8"),
	"SPK_MINER": Color("c8a878"),
	"SPK_GRANT": Color("a8b8c8"),
	"SPK_COWORKER_A": Color("a8d8b8"),
	"SPK_COWORKER_B": Color("e8b8c8"),
	"SPK_DRIVER": Color("c8c8a0"),
	"SPK_AGENT1": Color("b0b4bc"),
	"SPK_AGENT2": Color("a0a8b8"),
	"SPK_LUTFI": Color("9be0c0"),
	"SPK_URBAN": Color("e0a070"),
	"SPK_GIUST": Color("f0e090"),
	"SPK_EMPEROR": Color("d9a8ff"),
	"SPK_CLERK": Color("b8c8d8"),
	"SPK_THEODOROS": Color("a8d8ff"),
	"SPK_CANDARLI": Color("a0a0a0"),
	"SPK_CALLIGRAPHER": Color("e8d4a0"),
	"SPK_PAINTER": Color("a8c0f0"),
	"SPK_KID": Color("ffb8d0"),
	"SPK_NOTARAS": Color("d9a8ff"),
	"SPK_ISIDORE": Color("ff8a7a"),
	"SPK_BAILO": Color("f0c070"),
	"SPK_HUNGARIAN": Color("a8e0a0"),
	"SPK_SARUCA": Color("ffb070"),
}
const VOICE := {"SPK_HIKMET": 140.0, "SPK_TOLGA": 210.0, "SPK_NIHAT": 120.0, "SPK_MUFIDE": 250.0, "SPK_RIZA": 170.0,
	"SPK_NIKO": 190.0, "SPK_HASAN": 160.0, "SPK_HUSEYIN": 150.0, "SPK_GUARDS": 155.0, "SPK_KADRI": 110.0,
	"SPK_LUTFI": 180.0, "SPK_URBAN": 100.0, "SPK_GIUST": 130.0, "SPK_EMPEROR": 125.0, "SPK_CLERK": 165.0,
	"SPK_THEODOROS": 145.0, "SPK_CANDARLI": 115.0,
	"SPK_CEMIL": 105.0, "SPK_PASHA": 100.0, "SPK_AGA": 150.0, "SPK_CAMELEER": 118.0, "SPK_DERVISH": 95.0, "SPK_TAILOR": 200.0, "SPK_FATIH": 112.0, "SPK_MANAGER": 140.0, "SPK_RIDER": 175.0, "SPK_ENVOY": 118.0, "SPK_FISHMONGER": 150.0, "SPK_WINE": 135.0, "SPK_NOTARY": 170.0, "SPK_DOUBLE": 145.0, "SPK_CAPTAIN": 110.0, "SPK_SINERJI": 320.0, "SPK_MINER": 105.0, "SPK_GRANT": 125.0, "SPK_COWORKER_A": 190.0, "SPK_COWORKER_B": 230.0, "SPK_DRIVER": 120.0, "SPK_AGENT1": 135.0, "SPK_AGENT2": 128.0, "SPK_NOTARAS": 100.0, "SPK_ISIDORE": 120.0, "SPK_BAILO": 125.0, "SPK_HUNGARIAN": 150.0, "SPK_SARUCA": 95.0, "SPK_CALLIGRAPHER": 110.0, "SPK_PAINTER": 140.0, "SPK_KID": 280.0}
const PORTRAITS := {"SPK_HIKMET": "portraits/hikmet.svg", "SPK_NIHAT": "portraits/nihat.svg",
	"SPK_MUFIDE": "portraits/mufide.svg", "SPK_RIZA": "portraits/riza.svg", "SPK_NIKO": "portraits/niko.svg",
	"SPK_KADRI": "portraits/kadri.svg", "SPK_LUTFI": "portraits/lutfi.svg", "SPK_URBAN": "portraits/urban.svg",
	"SPK_HASAN": "portraits/hasan.svg", "SPK_HUSEYIN": "portraits/huseyin.svg", "SPK_GUARDS": "portraits/hasan.svg",
	"SPK_CANDARLI": "portraits/candarli.svg", "SPK_PASHA": "portraits/pasha.svg", "SPK_THEODOROS": "portraits/theodoros.svg",
	"SPK_CLERK": "portraits/clerk.svg", "SPK_GIUST": "portraits/giust.svg", "SPK_EMPEROR": "portraits/emperor.svg",
	"SPK_FATIH": "portraits/fatih.svg", "SPK_CEMIL": "portraits/cemil.svg", "SPK_AGENT1": "portraits/agent1.svg",
	"SPK_AGENT2": "portraits/agent2.svg", "SPK_AGA": "portraits/aga.svg", "SPK_ROWER": "portraits/rower.svg",
	"SPK_SINERJI": "portraits/sinerji.svg", "SPK_CAMELEER": "portraits/cameleer.svg",
	"SPK_DERVISH": "portraits/dervish.svg", "SPK_TAILOR": "portraits/tailor.svg", "SPK_MANAGER": "portraits/manager.svg",
	"SPK_DRIVER": "portraits/driver.svg", "SPK_CAPTAIN": "portraits/captain.svg", "SPK_WINE": "portraits/merchant.svg",
	"SPK_CALLIGRAPHER": "portraits/calligrapher.svg", "SPK_PAINTER": "portraits/painter.svg", "SPK_KID": "portraits/kid.svg",
	"SPK_DOUBLE": "portraits/double.svg", "SPK_FISHMONGER": "portraits/fishmonger.svg", "SPK_NOTARY": "portraits/notary.svg",
	"SPK_SOLDIER": "portraits/soldier.svg", "SPK_NOTARAS": "portraits/notaras.svg", "SPK_ISIDORE": "portraits/isidore.svg",
	"SPK_BAILO": "portraits/bailo.svg", "SPK_HUNGARIAN": "portraits/hungarian.svg", "SPK_SARUCA": "portraits/saruca.svg"}
## Bölüm kapakları (başlık kartının arkasında). Şubeli bölümlerde sahne cover_override'ı ayarlar.
const COVERS := {"chapter1": "ch1", "chapter2": "ch2", "chapter3": "ch3", "chapter4": "ch4a", "chapter5": "ch5",
	"chapter6": "ch6a", "chapter7": "ch7", "chapter8": "ch8", "chapter9": "ch9", "chapter10": "ch10", "chapter10b": "ch10b", "chapter10h": "ch10h", "chapter10z": "ch10z", "chapter10g": "ch10g", "chapter10a": "ch10a", "chapter16": "ch16", "chapter10l": "ch10l", "chapter12b": "ch12b", "chapter11": "ch11", "chapter12": "ch12",
	"chapter13": "ch13", "chapter14": "ch14", "chapter15": "ch15"}
const FONT_TITLE := "res://assets/fonts/title.ttf"
const ART := "res://assets/art/"

var mumble: Mumble
var cover_override := ""
## Patlamadan sonra Tolga'nın portresi isli görünür (10B)
var tolga_soot := false
var _cover: TextureRect
var _cover_shade: TextureRect
var _title_font: Font
## Seslendirme: assets/audio/voice/<dil>/<ANAHTAR>.mp3 varsa mırıltının yerine çalınır.
var _voice: AudioStreamPlayer
var fez: FezOverlay
var bag_locked := false

var _crosshair: ColorRect
var _prompt: Label
var _objective_box: PanelContainer
var marker: ObjectiveMarker
var last_blackout_ms := -100000   # son tam kararma (sahne başı/geçişi) zamanı
var cinematic := false
var _objective: Label
var _sub_box: PanelContainer
var _sub_speaker: Label
var _sub_text: Label
var _sub_hint: Label
var _choice_box: VBoxContainer
var _choice_timer: ColorRect
var _bag_box: PanelContainer
var _bag_list: VBoxContainer
var _bag_strip: HBoxContainer
var _held := 0
var _held_label: Label
var _signal_box: HBoxContainer
var _signal_bars: Array[ColorRect] = []
var _red_bar: ColorRect
var _red_label: Label
var _keypad_box: PanelContainer
var _keypad_display: Label
var _keypad_value := ""
var _keypad_active := false
var _fade: ColorRect
var _card: VBoxContainer
var _menu: GameMenu
var _controls: Label
var _bark_id := 0
var _portrait: TextureRect
var _qte: Label
var _chase_box: VBoxContainer
var _chase_bar: ColorRect
var _underwater: ColorRect
var _tolga_fez := false
var meters: NihatMeters


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("hud")
	# Vaka Dosyası'ndan bir finale gitmek için dönüldüyse bölüm başında hedefi hatırlat
	if not GameState.review_goal.is_empty() and not GameState.autotest:
		get_tree().create_timer(4.0).timeout.connect(_show_review_goal)
	# Olay yan görevleri (bayraklar): saniyede bir kontrol
	var qt := Timer.new()
	qt.wait_time = 1.0
	qt.autostart = true
	qt.process_mode = Node.PROCESS_MODE_PAUSABLE
	qt.timeout.connect(func():
		for id in Quests.check_events():
			quest_update(id, "", true)
		var new_ach := Achievements.check()
		if new_ach.size() > 3:   # eski oyuncu güncellemeyle birçoğunu birden açar: tek özet rozet
			_toast(tr("UI_ACH_MANY") % new_ach.size(), Color("ffcf4a"), 5.0)
		else:
			for aid in new_ach:
				achievement_toast(aid))
	add_child(qt)
	_apply_fonts()
	mumble = Mumble.new()
	mumble.bus = "Voice"
	add_child(mumble)
	_voice = AudioStreamPlayer.new()
	_voice.bus = "Voice"
	add_child(_voice)

	# Kenarlarda hafif karartma (bütün sahnelerde)
	var vig := ColorRect.new()
	vig.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vm := ShaderMaterial.new()
	vm.shader = load("res://assets/shaders/vignette.gdshader")
	vig.material = vm
	add_child(vig)

	fez = FezOverlay.new()
	fez.visible = false
	add_child(fez)

	_crosshair = ColorRect.new()
	_crosshair.color = Color(1, 1, 1, 0.8)
	_crosshair.size = Vector2(6, 6)
	_crosshair.set_anchors_preset(Control.PRESET_CENTER)
	_crosshair.position = Vector2(-3, -3)
	_crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_crosshair)

	marker = ObjectiveMarker.new()
	add_child(marker)

	_prompt = _label("", 22, Color.WHITE)
	_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.custom_minimum_size = Vector2(700, 30)
	_prompt.position = Vector2(-350, 36)
	add_child(_prompt)

	# Hedef (sol üst)
	_objective_box = _panel()
	_objective_box.position = Vector2(24, 70)
	var ov := VBoxContainer.new()
	_objective_box.add_child(ov)
	ov.add_child(_label("", 14, C_ACCENT))
	_objective = _label("", 20, Color.WHITE)
	ov.add_child(_objective)
	_objective_box.visible = false
	add_child(_objective_box)

	# Altyazı (alt orta)
	_sub_box = _panel()
	_sub_box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_sub_box.custom_minimum_size = Vector2(900, 0)
	var sh := HBoxContainer.new()
	sh.add_theme_constant_override("separation", 16)
	_sub_box.add_child(sh)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(112, 112)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sh.add_child(_portrait)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 4)
	sh.add_child(sv)
	_sub_speaker = _label("", 18, Color.WHITE)
	sv.add_child(_sub_speaker)
	_sub_text = _label("", 24, Color.WHITE)
	_sub_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub_text.custom_minimum_size = Vector2(730, 0)
	sv.add_child(_sub_text)
	_sub_hint = _label("", 13, Color(1, 1, 1, 0.5))
	_sub_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sv.add_child(_sub_hint)
	_sub_box.visible = false
	add_child(_sub_box)
	_apply_sub_size()
	GameState.settings_changed.connect(_apply_sub_size)

	# Seçimler (orta)
	_choice_box = VBoxContainer.new()
	_choice_box.set_anchors_preset(Control.PRESET_CENTER)
	_choice_box.custom_minimum_size = Vector2(520, 0)
	_choice_box.add_theme_constant_override("separation", 10)
	_choice_box.visible = false
	add_child(_choice_box)

	# Çanta şeridi (sağ üst) ve çanta paneli
	_bag_strip = HBoxContainer.new()
	_bag_strip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_bag_strip.add_theme_constant_override("separation", 6)
	_bag_strip.visible = false
	add_child(_bag_strip)
	_bag_box = _panel()
	_bag_box.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_bag_list = VBoxContainer.new()
	_bag_list.add_theme_constant_override("separation", 6)
	_bag_box.add_child(_bag_list)
	_bag_box.visible = false
	add_child(_bag_box)

	# Telsiz sinyali (sağ alt)
	_signal_box = HBoxContainer.new()
	_signal_box.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_signal_box.add_theme_constant_override("separation", 4)
	_signal_box.alignment = BoxContainer.ALIGNMENT_END
	var sl := _label(tr("UI_SIGNAL"), 14, C_ACCENT)
	sl.size_flags_vertical = Control.SIZE_SHRINK_END
	_signal_box.add_child(sl)
	for i in 5:
		var bar := ColorRect.new()
		bar.custom_minimum_size = Vector2(8, 8 + i * 6)
		bar.size_flags_vertical = Control.SIZE_SHRINK_END
		_signal_box.add_child(bar)
		_signal_bars.append(bar)
	_signal_box.visible = false
	add_child(_signal_box)

	# Kırmızı düğme basılı tutma çubuğu
	_red_label = _label(tr("UI_RED_HOLD"), 16, Color("ff5a4a"))
	_red_label.set_anchors_preset(Control.PRESET_CENTER)
	_red_label.position = Vector2(-60, 70)
	_red_label.visible = false
	add_child(_red_label)
	_red_bar = ColorRect.new()
	_red_bar.color = Color("ff3b30")
	_red_bar.set_anchors_preset(Control.PRESET_CENTER)
	_red_bar.position = Vector2(-100, 96)
	_red_bar.size = Vector2(0, 8)
	add_child(_red_bar)

	# Tuş takımı
	_keypad_box = _panel()
	_keypad_box.set_anchors_preset(Control.PRESET_CENTER)
	var kv := VBoxContainer.new()
	kv.add_theme_constant_override("separation", 10)
	_keypad_box.add_child(kv)
	kv.add_child(_label(tr("UI_KEYPAD_TITLE"), 18, C_ACCENT))
	_keypad_display = _label("----", 72, C_ACCENT)
	_keypad_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_keypad_display.custom_minimum_size = Vector2(420, 90)
	kv.add_child(_keypad_display)
	kv.add_child(_label(tr("UI_KEYPAD_HINT"), 14, Color(1, 1, 1, 0.6)))
	_keypad_box.visible = false
	add_child(_keypad_box)

	# Kontroller ipucu (alt)
	_controls = _label("", 14, Color(1, 1, 1, 0.55))
	_controls.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_controls.position = Vector2(24, -34)
	_controls.visible = false
	add_child(_controls)

	# QTE uyarısı (büyük, sarı)
	_qte = _label("", 40, Color("ffd60a"))
	_qte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_qte.custom_minimum_size = Vector2(900, 60)
	_qte.visible = false
	add_child(_qte)

	# Kovalamaca çubuğu (üst orta)
	_chase_box = VBoxContainer.new()
	_chase_box.add_theme_constant_override("separation", 4)
	var cl := _label("", 14, Color("ff8a7a"))
	cl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_chase_box.add_child(cl)
	var track := ColorRect.new()
	track.color = Color(1, 1, 1, 0.15)
	track.custom_minimum_size = Vector2(360, 10)
	_chase_box.add_child(track)
	_chase_bar = ColorRect.new()
	_chase_bar.color = Color("ff5a4a")
	_chase_bar.size = Vector2(0, 10)
	track.add_child(_chase_bar)
	_chase_box.visible = false
	add_child(_chase_box)

	# Su altı
	_underwater = ColorRect.new()
	_underwater.color = Color(0.1, 0.35, 0.45, 0.55)
	_underwater.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_underwater.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_underwater.visible = false
	add_child(_underwater)
	# Fes püskülünün hemen üstünde, yazıların ve arayüzün altında durur
	move_child(_underwater, fez.get_index() + 1)

	# Nihat'ın göstergeleri (sağ üst; Nihat bölümlerinde çantanın yerine)
	meters = NihatMeters.new()
	meters.visible = false
	add_child(meters)

	# Karartma ve kartlar (en üstte)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 1)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	_cover = TextureRect.new()
	_cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.visible = false
	add_child(_cover)
	# Kapağın alt üçte birini karartan degrade (yazı oraya biner)
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0))
	g.set_color(1, Color(0, 0, 0, 0.85))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_from = Vector2(0, 0.45)
	gt.fill_to = Vector2(0, 1)
	_cover_shade = TextureRect.new()
	_cover_shade.texture = gt
	_cover_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cover_shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cover_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.add_child(_cover_shade)
	_card = VBoxContainer.new()
	_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_card.alignment = BoxContainer.ALIGNMENT_CENTER
	_card.add_theme_constant_override("separation", 18)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_card)


	get_viewport().size_changed.connect(_relayout)
	_relayout()


# ---------------------------------------------------------------- yardımcılar

func _label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_PANEL
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(16)
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


func _relayout() -> void:
	var vs := get_viewport().get_visible_rect().size
	_sub_box.position = Vector2((vs.x - 900) * 0.5, vs.y - 190)
	_place_choices()
	_bag_strip.position = Vector2(vs.x - 5 * 58 - 24, 24)
	if _held_label:
		_held_label.size = Vector2(700, 22)
		_held_label.position = Vector2(vs.x - 724, 84)
	_bag_box.position = Vector2(vs.x - 360, vs.y * 0.5 - 170)
	_signal_box.position = Vector2(vs.x - 140, vs.y - 70)
	_keypad_box.position = Vector2((vs.x - 452) * 0.5, vs.y * 0.5 - 130)
	_controls.position = Vector2(24, vs.y - 34)
	var c := vs * 0.5
	_qte.position = c + Vector2(-450, -150)
	_chase_box.position = Vector2(c.x - 180, 24)
	if meters:
		meters.position = Vector2(vs.x - meters.size.x - 24, 24)
	_crosshair.position = c - Vector2(3, 3)
	_prompt.position = c + Vector2(-350, 36)
	_red_label.position = c + Vector2(-60, 70)
	_red_bar.position = c + Vector2(-100, 96)


## Seçenekler ekranın ortasında; çok seçenek ya da küçük ekranda altyazının üstünde kalacak kadar yukarı çıkar.
func _place_choices() -> void:
	var vs := get_viewport().get_visible_rect().size
	var h := _choice_box.get_combined_minimum_size().y
	var y := minf(vs.y * 0.5 - 40.0, vs.y - 190.0 - 14.0 - h)
	_choice_box.position = Vector2((vs.x - 520) * 0.5, maxf(70.0, y))


func is_talking() -> bool:
	return _sub_box != null and _sub_box.visible


func _fast() -> bool:
	return GameState.autotest


# ---------------------------------------------------------------- oyun içi

## target: hedefin yeri (Node3D ya da Vector3); ekranda baklava ve uzaklıkla gösterilir. h: Node3D'de yükseklik.
func _show_review_goal() -> void:
	var sc := get_tree().current_scene
	if GameState.review_goal.is_empty() or sc == null or not sc.scene_file_path.get_file().begins_with("chapter"):
		return
	var g: Dictionary = GameState.review_goal
	var box := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.1, 0.16, 0.88)
	sb.border_color = Color("ffd24a")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	box.add_theme_stylebox_override("panel", sb)
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.offset_top = 96
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Label.new()
	l.text = tr("UI_RV_GOAL") % [tr("UI_CH15_FINAL_" + str(g.get("final", "")).to_upper()), str(g.get("step", ""))]
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", Color("f2e6c9"))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l)
	add_child(box)
	box.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(box, "modulate:a", 1.0, 0.5)
	tw.tween_interval(9.0)
	tw.tween_property(box, "modulate:a", 0.0, 0.8)
	tw.tween_callback(box.queue_free)


func set_objective(text: String, target: Variant = null, h := 1.6) -> void:
	if marker:
		marker.set_target(target if text != "" else null, h)
	_objective_box.visible = text != ""
	(_objective_box.get_child(0).get_child(0) as Label).text = tr("UI_OBJECTIVE")
	_objective.text = text


## Hedef işaretçisi için: etkileşim kimliği (interact_id) verilen nesneyi sahnede bulur (bulunca önbelleğe alır).
## Birden çok kimlik verilirse henüz duran en yakınını gösterir (ör. kalan ipuçları).
## skip: kimliği alır, true dönerse o hedef atlanır (ör. taranmış ipucu).
func spot(ids: Variant, skip := Callable()) -> Callable:
	var list: Array = ids if ids is Array else [ids]
	var cache := {}
	return func():
		var cam := get_viewport().get_camera_3d()
		var best: Node3D = null
		var bd := INF
		for id in list:
			if skip.is_valid() and skip.call(id):
				continue
			var n = cache.get(id)
			if n == null or not is_instance_valid(n):
				n = _find_interact(get_tree().current_scene, str(id))
				cache[id] = n
			if n == null or not (n as Node3D).is_inside_tree() or not _interact_live(n):
				continue
			var d: float = cam.global_position.distance_to((n as Node3D).global_position) if cam else 0.0
			if d < bd:
				bd = d
				best = n
		return best


static func _find_interact(node: Node, id: String) -> Node3D:
	if node == null:
		return null
	if node is Node3D and node.has_meta("interact_id") and str(node.get_meta("interact_id")) == id:
		return node
	for c in node.get_children():
		var r := _find_interact(c, id)
		if r:
			return r
	return null


## Toplanmış/kapatılmış etkileşimler (görünmez ya da çarpışması kapalı) hedef sayılmaz
static func _interact_live(n: Node3D) -> bool:
	if not n.is_visible_in_tree():
		return false
	if n is CollisionObject3D and (n as CollisionObject3D).collision_layer == 0:
		return false
	return true


func set_prompt(text: String) -> void:
	# Kol kullanılıyorsa "E · ..." istemleri kol düğmesiyle gösterilir
	if GameState.pad and text.begins_with("E ·"):
		text = "X ·" + text.substr(3)
	_prompt.text = text


func show_crosshair(on: bool) -> void:
	_crosshair.visible = on


## Altyazı boyutu ayarı (0.8 - 1.6).
func _apply_sub_size() -> void:
	var k := float(GameState.settings.get("subs", 1.0))
	_sub_speaker.add_theme_font_size_override("font_size", int(18 * k))
	_sub_text.add_theme_font_size_override("font_size", int(24 * k))
	_sub_text.custom_minimum_size.x = 730.0 * clampf(k, 1.0, 1.3)


func show_controls(on: bool) -> void:
	_controls.text = tr("UI_CONTROLS_PAD" if GameState.pad else "UI_CONTROLS")
	_controls.visible = on
	if not GameState.pad_changed.is_connected(_on_pad_changed):
		GameState.pad_changed.connect(_on_pad_changed)


func _on_pad_changed(_on: bool) -> void:
	if _controls.visible:
		_controls.text = tr("UI_CONTROLS_PAD" if GameState.pad else "UI_CONTROLS")


var _fez_last := -1   # başarım sayacı: ilk çağrı (bölüm başı) sayılmaz


func set_fez(on: bool) -> void:
	fez.visible = on
	if _fez_last != -1 and _fez_last != int(on) and not GameState.autotest:
		GameState.bump_stat("fez_toggles")
	_fez_last = int(on)


## Sinematik: çanta, telsiz ve nişangâh gizlenir.
var _fez_before_cine := false


func set_cinematic(on: bool) -> void:
	cinematic = on
	_bag_strip.visible = not on
	_signal_box.visible = not on
	_crosshair.visible = not on
	# Sinematik kamerada fesin püskülü (birinci şahıs katmanı) görünmez
	if on:
		_fez_before_cine = fez.visible
		fez.visible = false
	elif _fez_before_cine:
		fez.visible = true
		_fez_before_cine = false


## Nihat bölümleri: fes yerine fötr şapka, çanta ve telsiz yerine göstergeler.
func set_nihat_mode(on: bool) -> void:
	fez.style = "fedora" if on else "fez"
	meters.visible = on
	_bag_strip.visible = not on
	_signal_box.visible = not on and _signal_box.visible
	_relayout()
	_tolga_fez = on


func set_signal(level: int) -> void:
	_signal_box.visible = true
	for i in _signal_bars.size():
		_signal_bars[i].color = C_ACCENT if i < level else Color(1, 1, 1, 0.18)


func set_qte(text: String) -> void:
	_qte.text = text
	_qte.visible = text != ""


## Kovalayanın yakınlığı: 0 (uzak) .. 1 (yakaladı)
var _music_before_chase := ""
var chase_music := "chase"   # bölüm değiştirebilir (13: geri sayım, 16: tavuk)


func set_chase(label_text: String, v: float) -> void:
	if label_text != "" and not _chase_box.visible:
		_music_before_chase = Audio.current_music()
		if _music_before_chase != "chicken":
			Audio.music(chase_music, 0.6)
	elif label_text == "" and _chase_box.visible and _music_before_chase != "":
		Audio.music(_music_before_chase)
	_chase_box.visible = label_text != ""
	(_chase_box.get_child(0) as Label).text = label_text
	_chase_bar.size = Vector2(360.0 * clampf(v, 0.0, 1.0), 10)
	_chase_bar.color = Color("ff5a4a") if v > 0.6 else Color("ffb13b")


## Tırmanma nefesi (Traversal her fizik adımında çağırır); halka ilk gerektiğinde kurulur.
var _stamina: StaminaRing


func set_stamina(v: float, on: bool, tired: bool) -> void:
	if _stamina == null:
		if not on:
			return
		_stamina = StaminaRing.new()
		add_child(_stamina)
		move_child(_stamina, _crosshair.get_index() + 1)
	_stamina.show_value(v, on and not cinematic, tired)


func set_underwater(on: bool) -> void:
	_underwater.visible = on


## "Bütçe yetmedi" haritası: ok çizilir, Hikmet yorum yapar.
func budget_map(title_text: String, from_text: String, to_text: String, seconds := 3.0) -> void:
	var m := BudgetMap.new()
	m.title = title_text
	m.from_label = from_text
	m.to_label = to_text
	add_child(m)
	move_child(m, _fade.get_index())
	if _fast():
		m.progress = 1.0
		await get_tree().process_frame
		m.queue_free()
		return
	var tw := create_tween()
	tw.tween_property(m, "progress", 1.0, seconds * 0.7)
	await get_tree().create_timer(seconds).timeout
	m.queue_free()


## Sahne kararırken ya da bir kart çıkarken geçici ipuçları silinir: bir önceki anın "A/D ile dengede kal"
## gibi istemleri yeni sahnede (hücre, başka yer) asılı kalmasın. Hedef ve konuşma kutusu dokunulmaz.
func clear_transient() -> void:
	if _prompt:
		_prompt.text = ""
		# Oyuncu aynı nesneye bakmaya devam ediyorsa "E · ..." istemi bir sonraki karede geri gelsin
		var sc := get_tree().current_scene if is_inside_tree() else null
		var pl = sc.get("player") if sc else null
		if pl is Player:
			(pl as Player).focus_id = ""
	if _qte:
		set_qte("")
	if _red_label:
		set_red_progress(0.0)
	if _chase_box and _chase_box.visible:
		set_chase("", 0.0)


func set_red_progress(v: float) -> void:
	_red_label.visible = v > 0.0
	_red_bar.size = Vector2(200.0 * clampf(v, 0.0, 1.0), 8)


func update_bag(bag: Array) -> void:
	for c in _bag_strip.get_children():
		c.queue_free()
	_bag_strip.visible = true
	for i in 5:
		var slot := ColorRect.new()
		slot.custom_minimum_size = Vector2(52, 52)
		slot.color = Color(1, 1, 1, 0.08)
		if i < bag.size():
			slot.color = Color(0, 0, 0, 0)
			var ic := TextureRect.new()
			ic.texture = load(ART + "icons/%s.svg" % bag[i])
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ic.size = Vector2(52, 52)
			slot.add_child(ic)
			var l := _label(str(i + 1), 13, Color("1d2330"))
			l.remove_theme_color_override("font_shadow_color")
			slot.add_child(l)
			l.position = Vector2(8, 5)
		if i + 1 == _held and i < bag.size():
			var frame := ReferenceRect.new()
			frame.border_color = C_ACCENT
			frame.border_width = 3.0
			frame.editor_only = false
			frame.size = Vector2(52, 52)
			frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(frame)
		_bag_strip.add_child(slot)
	# Açık çanta paneli
	for c in _bag_list.get_children():
		c.queue_free()
	_bag_list.add_child(_label(tr("UI_BAG_TITLE") + "  %d/5" % bag.size(), 18, C_ACCENT))
	for i in 5:
		var txt := "%d. %s" % [i + 1, tr(Items.name_key(bag[i])) if i < bag.size() else tr("UI_BAG_EMPTY")]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var ic2 := TextureRect.new()
		ic2.custom_minimum_size = Vector2(34, 34)
		ic2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if i < bag.size():
			ic2.texture = load(ART + "icons/%s.svg" % bag[i])
		row.add_child(ic2)
		row.add_child(_label(txt, 18, Color.WHITE if i < bag.size() else Color(1, 1, 1, 0.4)))
		_bag_list.add_child(row)
	_bag_list.add_child(_label(tr("UI_BAG_LOCKED") if bag_locked else tr("UI_BAG_HINT"), 13, Color(1, 1, 1, 0.6)))


## Elde tutulan eşya: çanta şeridinde çerçeve ve altında adı (0 = Telsiz-Kumanda).
func set_held(i: int, item: String) -> void:
	_held = i
	if _held_label == null:
		_held_label = _label("", 14, C_ACCENT)
		_held_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		add_child(_held_label)
		_relayout()
	_held_label.text = tr("UI_HELD") % (tr(Items.name_key(item)) if item != "" else tr("UI_HELD_REMOTE"))
	_held_label.visible = _bag_strip.visible
	update_bag(GameState.bag)


## Eldeki eşyayı birine göstermek: ITEM_REACTIONS matrisi (10 eşya × 12 karakter).
const REACT_CHARS := {"hikmet": ["HIKMET", "SPK_HIKMET"], "guards": ["GUARDS", "SPK_HASAN"], "hasan": ["GUARDS", "SPK_HASAN"],
	"huseyin": ["GUARDS", "SPK_HUSEYIN"], "kadri": ["KADRI", "SPK_KADRI"], "lutfi": ["LUTFI", "SPK_LUTFI"],
	"urban": ["URBAN", "SPK_URBAN"], "aga": ["AGA", "SPK_AGA"], "fatih": ["FATIH", "SPK_FATIH"], "nihat": ["NIHAT", "SPK_NIHAT"],
	"niko": ["NIKO", "SPK_NIKO"], "emperor": ["EMPEROR", "SPK_EMPEROR"], "giustiniani": ["GIUST", "SPK_GIUST"],
	"theodoros": ["THEODOROS", "SPK_THEODOROS"], "tailor": ["TAILOR", "SPK_TAILOR"], "pasha": ["PASHA", "SPK_PASHA"],
	"dervish": ["DERVISH", "SPK_DERVISH"], "cameleer": ["CAMELEER", "SPK_CAMELEER"], "miner": ["MINER", "SPK_MINER"],
	"soldier": ["SOLDIER", "SPK_SOLDIER"], "candarli": ["CANDARLI", "SPK_CANDARLI"], "clerk": ["CLERK", "SPK_CLERK"],
	"wine": ["WINE", "SPK_WINE"], "notary": ["NOTARY", "SPK_NOTARY"], "double": ["DOUBLE", "SPK_DOUBLE"],
	"fishmonger": ["FISHMONGER", "SPK_FISHMONGER"], "calligrapher": ["CALLIGRAPHER", "SPK_CALLIGRAPHER"],
	"painter": ["PAINTER", "SPK_PAINTER"], "kid": ["KID", "SPK_KID"]}


var _replay_i := {}


func show_reaction(target: String, item: String) -> void:
	var who := target.trim_prefix("npc:").get_slice(":", 0)   # "clerk:2" -> "clerk", "npc:kid" -> "kid"
	if REACT_CHARS.has(who):
		var c: Array = REACT_CHARS[who]
		# Tekrar oynayan (bir final görmüş) oyuncuya ana karakterlerden arada yeni espri
		var rk := "REACT_%s_REPLAY" % c[0]
		if not GameState.finals_seen.is_empty() and randf() < 0.35 and tr(rk + "_1") != rk + "_1":
			var ri := int(_replay_i.get(rk, 0))
			_replay_i[rk] = ri + 1
			var k2 := "%s_%d" % [rk, ri % 5 + 1]
			if tr(k2) != k2:
				bark(c[1], k2, 5.5)
				return
		var key := "REACT_%s_%s" % [c[0], item.to_upper()]
		if tr(key) != key:
			bark(c[1], key, 5.5)
			return
	if target.begins_with("item:") or target in ["panel", "face", "table", "exit", "mirror"] or target.begins_with("shelf_"):
		bark("SPK_TOLGA", "ITEM_SHOW_THING", 2.5)
	else:
		bark("SPK_TOLGA", "ITEM_SHOW_PERSON", 3.0)


## Yan görev ilerlemesi: köşede bir rozet (selfie fotoğrafını Player.selfie_shot çeker).
func quest_update(item: String, _target: String, done: bool) -> void:
	var q: Dictionary = Quests.LIST[item]
	var text := tr("UI_QUEST_DONE") % tr(Quests.title_key(item)) if done else \
		tr("UI_QUEST_PROGRESS") % [tr(Quests.title_key(item)), Quests.progress_of(item), int(q["need"])]
	_toast(text, Color("ffd24a") if done else C_ACCENT, 4.5 if done else 2.8)
	Audio.sfx("stamp" if done else "ui_confirm", -6.0 if done else -10.0)
	if done and tr("QUEST_%s_DONE" % item.to_upper()) != "QUEST_%s_DONE" % item.to_upper():
		get_tree().create_timer(1.2).timeout.connect(func(): bark("SPK_TOLGA", "QUEST_%s_DONE" % item.to_upper(), 3.5))


## Başarım açıldı: altın rozet (görev rozetinin biraz altında), mühür sesi.
func achievement_toast(id: String) -> void:
	get_tree().create_timer(0.6).timeout.connect(func():
		_toast(tr("UI_ACH_UNLOCKED") % tr(Achievements.title_key(id)), Color("ffcf4a"), 5.0, 140.0)
		Audio.sfx("stamp", -4.0))


var _toasts: Array[Control] = []


## Sağ üstte rozet; aynı anda birden çoksa alt alta dizilir.
func _toast(text: String, color: Color, seconds: float, _y := 90.0) -> void:
	var p := _panel()
	var l := _label(text, 20, color)
	p.add_child(l)
	add_child(p)
	p.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	var y := 90.0 + 50.0 * _toasts.size()
	_toasts.append(p)
	p.tree_exited.connect(func(): _toasts.erase(p))
	p.position = Vector2(get_viewport().get_visible_rect().size.x - 40, y)
	await get_tree().process_frame
	p.position.x = get_viewport().get_visible_rect().size.x - p.size.x - 24
	p.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(p, "modulate:a", 1.0, 0.25)
	tw.tween_interval(0.05 if _fast() else seconds)
	tw.tween_property(p, "modulate:a", 0.0, 0.4)
	tw.tween_callback(p.queue_free)


## Selfie: arayüzü bir kareliğine gizleyip ekranı çeker, albüme kaydeder, flaş ve polaroid gösterir.
func snap_photo(who: String) -> void:
	if GameState.autotest:
		return
	var was := visible
	visible = false
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	visible = was
	DirAccess.make_dir_recursive_absolute(Quests.ALBUM_DIR)
	_watermark(img)
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	img.save_png(Quests.ALBUM_DIR + "%s_%s.png" % [stamp, who])
	GameState.bump_stat("selfies" if who != "photo" else "photo_mode_shots")
	Audio.sfx("camera", -4.0)
	var flash := ColorRect.new()
	flash.color = Color.WHITE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	create_tween().tween_property(flash, "modulate:a", 0.0, 0.35).finished.connect(flash.queue_free)
	# Polaroid: beyaz çerçeve, altında "Tolga ve <kişi> · 1453"
	var vs := get_viewport().get_visible_rect().size
	var frame := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("f4f1ea")
	sb.set_content_margin_all(10)
	sb.content_margin_bottom = 8
	frame.add_theme_stylebox_override("panel", sb)
	var col := VBoxContainer.new()
	frame.add_child(col)
	var pic := TextureRect.new()
	pic.texture = ImageTexture.create_from_image(img)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.custom_minimum_size = Vector2(300, 200)
	col.add_child(pic)
	var cap := Label.new()
	cap.text = tr("UI_PHOTO_CAPTION") % tr("PHOTO_" + who.to_upper())
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.add_theme_color_override("font_color", Color("1d2330"))
	cap.add_theme_font_size_override("font_size", 16)
	col.add_child(cap)
	add_child(frame)
	frame.position = Vector2(vs.x - 360, vs.y + 20)
	frame.rotation = 0.06
	var tw := create_tween()
	tw.tween_property(frame, "position:y", vs.y - 330, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(2.4)
	tw.tween_property(frame, "position:y", vs.y + 20, 0.4)
	tw.tween_callback(frame.queue_free)


## Albüm fotoğrafının sağ alt köşesine oyunun logosu (paylaşılan her fotoğraf oyunu tanıtsın).
func _watermark(img: Image) -> void:
	var tex := load("res://assets/art/posters/logo_wm.png") as Texture2D
	if tex == null:
		return
	var logo := tex.get_image()
	if logo == null:
		return
	logo.decompress()
	logo.convert(Image.FORMAT_RGBA8)
	img.convert(Image.FORMAT_RGBA8)
	var w := int(img.get_width() * 0.22)
	var h := int(w * logo.get_height() / float(logo.get_width()))
	logo.resize(w, h, Image.INTERPOLATE_BILINEAR)
	# Okunsun diye arkasına yarı saydam koyu şerit
	var pad := int(w * 0.04)
	var bg := Image.create(w + pad * 2, h + pad * 2, false, Image.FORMAT_RGBA8)
	bg.fill(Color(0.08, 0.09, 0.12, 0.55))
	var at := Vector2i(img.get_width() - bg.get_width() - pad, img.get_height() - bg.get_height() - pad)
	img.blend_rect(bg, Rect2i(Vector2i.ZERO, bg.get_size()), at)
	img.blend_rect(logo, Rect2i(Vector2i.ZERO, logo.get_size()), at + Vector2i(pad, pad))


func toggle_bag(open: bool) -> void:
	_bag_box.visible = open


func is_bag_open() -> bool:
	return _bag_box.visible


# ---------------------------------------------------------------- diyalog

## Engelleyen replik: oyuncu devam tuşuna basana kadar bekler.
func say(speaker_key: String, text_key: String) -> void:
	_audit(speaker_key, text_key)
	# Denetim: ekran tamamen kararmış/beyazken (kart yokken) konuşma = sahne kurulmamış ya da açılmamış
	var radio_card := false
	if _fade.color.a > 0.95 and _card.get_child_count() == 0 and not text_key in DARK_OK:
		if "RADIO" in text_key:
			# Karanlıkta telsiz görüşmesi: ne olduğu anlaşılsın diye telsiz kartı
			radio_card = true
			_radio_card()
		else:
			print("WARN_SAY_ON_FADE key=%s scene=%s" % [text_key, get_tree().current_scene.scene_file_path.get_file() if get_tree().current_scene else ""])
	_show_line(speaker_key, tr(text_key), true)
	var turned := _face_listeners(speaker_key, text_key)
	_line_prop(speaker_key, text_key)
	_stage_action(speaker_key, text_key)
	if _fast():
		await get_tree().process_frame
		_sub_box.visible = false
		_release_listeners(turned)
		if radio_card:
			clear_card()
		return
	var text_len := _sub_text.text.length()
	var dur := clampf(text_len * 0.028, 0.4, 2.2)
	var vs := voice_stream(text_key)
	if vs:
		_voice.stream = vs
		_voice.volume_db = VoiceGain.DB.get(text_key, 0.0)   # kısık/bağıran kayıtlar dengelenir
		_voice.play()
		dur = clampf(vs.get_length() * 0.85, 0.4, 12.0)
	else:
		mumble.speak(dur, VOICE.get(speaker_key, 180.0))
	var tw := create_tween()
	_sub_text.visible_ratio = 0.0
	tw.tween_property(_sub_text, "visible_ratio", 1.0, dur)
	await get_tree().create_timer(0.2).timeout
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("advance"):
			if _sub_text.visible_ratio < 1.0:
				tw.kill()
				_sub_text.visible_ratio = 1.0
				mumble.stop_speaking()
			else:
				break
	mumble.stop_speaking()
	_voice.stop()
	_sub_box.visible = false
	_release_listeners(turned)
	if radio_card:
		clear_card()


## Replikte adı geçen ve gösterilen eşya elde gerçekten görünsün ("Kartvizitim." deyip boş el uzatılmasın).
## anahtar -> [eşya, kim göstermeli]: "self" yalnız konuşan oyuncunun kendisiyse, "any" her durumda.
const LINE_PROPS := {
	"D3_N_END_33": ["card", "self"],
	"D3_N_TEA": ["tea", "self"],
	"D7_N_TEA": ["tea", "self"],
	"D7_N_TEA_DONE": ["tea", "self"],
	"D6B_T_LETTER": ["letter", "self"],
	"D6B_T_SEALED": ["letter", "self"],
	"D8_H_PHONE": ["card", "self"],
	"D15_G_W8": ["card", "any"],
	"D10H_K_LETTER": ["letter", "any"],
	"D10A_T_04_CUBE": ["cube", "self"],
	"D4B_T_SELFIE": ["pole", "self"],
}
const _SPEAKER_STYLE := {"SPK_TOLGA": "tolga", "SPK_NIHAT": "nihat", "SPK_HIKMET": "hikmet"}


func _line_prop(speaker_key: String, text_key: String) -> void:
	if not LINE_PROPS.has(text_key) or _fast():
		return
	var sc := get_tree().current_scene
	var pl = sc.get("player") if sc else null
	if not (pl is Player):
		return
	var spec: Array = LINE_PROPS[text_key]
	if spec[1] == "self" and _SPEAKER_STYLE.get(speaker_key, "") != (pl as Player).hand_style:
		return
	(pl as Player).show_prop(spec[0], 2.6)


## Sahne notu -> hareket: replikteki "(Okur)", "(Kalemi uzatır)", "(Gözleri dolar)" gibi notlar konuşan karaktere
## oynatılır. Sıra önemli: ilk eşleşen kazanır. Notlar Türkçe metinden okunur (oyun dili ne olursa olsun).
## Notu olmayan ama belli bir hareket isteyen replikler (çay ikramı gibi): anahtar -> hareket
const LINE_GESTURES := {
	"D7_HUSEYIN_TEA": "offer_cup",
	"D7_HASAN_TEA": "sip",
	"D15_G_N4": "offer_cup",
	"D3_H_24": "offer_cup",
}

const STAGE_ACTIONS := [
	["çayını karıştır", "stir_cup"], ["karıştırır", "stir_cup"],
	["mühür vur", "stamp"], ["mührü vurur", "stamp"], ["vurur", "stamp"],
	["imzala", "write"], ["yazar", "write"], ["not al", "write"], ["karala", "write"], ["doldurur", "write"], ["tutanağa", "write"],
	["yudum", "sip"], ["içer", "sip"],
	["tadar", "eat"], ["çiğner", "eat"], ["bir tane al", "eat"], ["bir avuç al", "eat"], ["bir tane yer", "eat"], ["yine de yer", "eat"],
	["koklar", "sniff"], ["burnunu çek", "sniff"], ["yüzüne sür", "sniff"], ["ellerine döker", "sniff"],
	["ellerini uzat", "offer2"], ["tartar", "offer2"],
	["uzatır", "offer"], ["geri verir", "offer"], ["dürter", "offer"], ["masasına koyar", "offer"], ["cebine koyar", "offer"],
	["formu indir", "offer"], ["kalemini bırakır", "offer"], ["kalemi geri al", "offer"], ["rozetini masaya", "offer"],
	["okur", "read"], ["sayfaları çevir", "read"], ["inceler", "read"], ["küpü çevir", "read"], ["defterini", "read"],
	["katlar", "read"], ["bakar, kapatır", "read"], ["eşyaya bakar", "read"],
	["gözleri dol", "tearful"], ["ağlar", "tearful"], ["sesi titre", "tearful"], ["eli titri", "tearful"],
	["iç çeker", "sigh"],
	["şapkasını çıkar", "hat"], ["kukuletayı indir", "hat"], ["sarığını tut", "hat"],
	["öne eğil", "lean"], ["toprağa eğil", "lean"], ["telsize eğil", "lean"], ["küpeşteye eğil", "lean"],
	["eğil", "bow"], ["başını hafifçe eğer", "bow"],
	["fısılda", "whisper"],
	["başını salla", "nod"], ["gülümser", "nod"],
	["güler", "laugh"],
	["omuz silk", "shrug"],
	["poz verir", "cheer"], ["çan çalar", "wave"],
	["kaşları çatıl", "think"], ["kafası karış", "think"], ["susar", "think"], ["durur", "think"], ["donup kal", "surprise"],
]


func _stage_action(speaker_key: String, text_key: String) -> void:
	if _fast():
		return
	var tro := TranslationServer.get_translation_object("tr")
	var src: String = String(tro.get_message(text_key)) if tro else tr(text_key)
	var notes := ""
	for m in RegEx.create_from_string("\\(([^)]*)\\)").search_all(src):
		notes += " " + m.get_string(1).to_lower()
	var kind := ""
	if LINE_GESTURES.has(text_key):
		notes += " "
		kind = LINE_GESTURES[text_key]
	if notes == "":
		return
	for pair in STAGE_ACTIONS:
		if kind != "":
			break
		if notes.find(pair[0]) >= 0:
			kind = pair[1]
			break
	# "(Kalkar)" tek başına: oturan ayağa kalkar ("kaşı kalkar", "tutup kalkar" değil)
	if notes.strip_edges() == "kalkar":
		kind = "stand"
	# Tek kelimelik "(Yer)" notu ("yere", "yerleştirir" değil)
	if kind == "" and (" " + notes.replace(",", " ").replace(".", " ") + " ").find(" yer ") >= 0:
		kind = "eat"
	var sc := get_tree().current_scene
	var pl = sc.get("player") if sc else null
	var who := _speaker_node(speaker_key, pl)
	if who == null:
		# Konuşan oyuncunun kendisi: birinci şahıs el hareketi
		if pl is Player and _SPEAKER_STYLE.get(speaker_key, "") == (pl as Player).hand_style:
			_self_action(pl as Player, notes, kind)
		return
	# "Tolga'ya döner/bakar": konuşan oyuncuya döner
	if pl is Node3D and (notes.find("tolga'ya") >= 0 or notes.find("döner") >= 0) and who.get("look_target") == null:
		who.set("look_target", pl)
	# "(Gider)", "(Arkandan koşarak)" değil: konuşan yürüyüp uzaklaşır
	if (notes.find("gider") >= 0 or notes.find("uzaklaşır") >= 0) and who.has_method("leave") and pl is Node3D:
		who.leave((pl as Node3D).global_position, 4.0, 3.0)
		return
	if kind == "stand":
		var rg = who.get("rig")
		if rg and String(rg.activity).begins_with("sit"):
			rg.activity = ""
			if who.has_method("set_activity"):
				who.set_activity("")
		return
	if kind != "" and who.has_method("emote"):
		who.emote(kind)


func _self_action(pl: Player, notes: String, kind: String) -> void:
	if notes.find("oturur") >= 0:
		pl.sit_view(true)
	if notes.find("telefon") >= 0:
		pl.hand_gesture("ear")
	elif notes.find("mektub") >= 0 or notes.find("mühr") >= 0:
		pl.show_prop("letter", 2.2)
	elif notes.find("rubik") >= 0 or notes.find("küp") >= 0:
		pl.show_prop("cube", 2.2)
	elif kind in ["sip", "eat"] or notes.find("leblebi") >= 0 and notes.find("atar") < 0:
		pl.hand_gesture("mouth")
	elif notes.find("atar") >= 0 or notes.find("uzat") >= 0 or notes.find("gösterir") >= 0 or notes.find("başparmağ") >= 0:
		pl.hand_gesture("show")
	elif notes.find("takar") >= 0 or notes.find("dokunur") >= 0 or notes.find("çıkarır") >= 0:
		pl.hand_gesture("reach")


## Konuşan karakterin sahnedeki düğümü: konuşan (talking) ya da oyuncuya en yakın karakter. Oyuncunun kendisiyse yok.
func _speaker_node(speaker_key: String, pl) -> Node3D:
	if pl is Player and _SPEAKER_STYLE.get(speaker_key, "") == (pl as Player).hand_style:
		return null
	var here: Vector3 = (pl as Node3D).global_position if pl is Node3D else Vector3.ZERO
	var best: Node3D = null
	var bd := 4.5     # konuştuğu bilinmiyorsa yalnız dibindeki karakter (uzaktaki rastgele biri oynamasın)
	for g in ["persons", "soldiers", "persons_hikmet"]:
		for n in get_tree().get_nodes_in_group(g):
			var c := n as Node3D
			if c == null or not c.is_visible_in_tree():
				continue
			var d := c.global_position.distance_to(here)
			if c.get("talking") == true and d < 30.0:
				d -= 100.0   # konuştuğu bilinen önce (uzaktan konuşsa da)
			if d < bd:
				bd = d
				best = c
	if speaker_key == "SPK_HIKMET" and best and not (best is Hikmet) and bd > -90.0:
		return null   # Hikmet telsizdeyse başkasına oynatma
	return best


func _release_listeners(turned: Array) -> void:
	for n in turned:
		if is_instance_valid(n):
			n.look_target = null
			n.talking = false
			var r = n.get("rig")
			if r is Rig:
				r.mood = ""


## Bilerek karanlıkta söylenen replikler (telsizden gelen ses, kapanış): denetim uyarısı vermez.
const DARK_OK := ["D2_H_24", "D10L_T_COLLAPSE", "D10L_N_DIG_1", "D10L_N_DIG_2", "D10L_T_COLLAPSE_2"]


func _radio_card() -> void:
	var l := Label.new()
	l.text = "📻  " + tr("UI_RADIO_CARD")
	l.add_theme_font_size_override("font_size", 26)
	l.add_theme_color_override("font_color", Color("6ff2c8"))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.add_child(l)


## Oyuncunun kendisi ya da telsizdeki sesler: kimseyi döndürmez.
const _SELF_SPEAKERS := ["SPK_TOLGA", "SPK_NIHAT", "SPK_HIKMET", "SPK_SINERJI"]


## Karşıdaki biri konuşurken yakındaki boşta duran askerler/kişiler oyuncuya döner
## (sırtı dönük konuşma olmasın). Konuşan (en yakın) ağzını oynatır. Satır bitince bırakılır.
func _face_listeners(speaker_key: String, text_key := "") -> Array:
	var out: Array = []
	if speaker_key in _SELF_SPEAKERS:
		return out
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return out
	var me: Node3D = cam
	var sc := get_tree().current_scene
	var p = sc.get("player") if sc else null
	if p is Node3D and (p as Node3D).is_inside_tree():
		me = p
	var here := me.global_position
	var near: Node3D = null
	var nd := 9.0
	var cands: Array = []
	for n in get_tree().get_nodes_in_group("soldiers") + get_tree().get_nodes_in_group("persons"):
		var c := n as Node3D
		if c == null or not c.is_visible_in_tree() or c.get("look_target") != null:
			continue
		if c is Soldier and (c as Soldier).pose != "stand":
			continue
		if c is Person and ((c as Person)._busy or (c as Person).rig == null or (c as Person).rig.activity != ""):
			continue
		var d := Vector2(c.global_position.x - here.x, c.global_position.z - here.z).length()
		if d < nd:
			nd = d
			near = c
		if d < 4.5:
			cands.append(c)
	if near and not near in cands:
		cands.append(near)
	for c in cands:
		c.look_target = me
		out.append(c)
	if near:
		near.talking = true
		# Yüz ifadesi repliğe göre (Türkçe metinden; notlar ve noktalama)
		var r = near.get("rig")
		if r is Rig and text_key != "":
			var trt := TranslationServer.get_translation_object("tr")
			var src: String = trt.get_message(text_key) if trt else ""
			r.mood = Rig.mood_of(speaker_key, src if src != "" else tr(text_key))
	return out


## Seslendirme dosyası (varsa). Dil: oyunun o anki dili.
func voice_stream(text_key: String) -> AudioStream:
	if text_key == "" or " " in text_key:
		return null
	var path := "res://assets/audio/voice/%s/%s.mp3" % [TranslationServer.get_locale().substr(0, 2), text_key]
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	return null


## Engellemeyen replik: kendi kendine kaybolur (eşya yorumları gibi).
func bark(speaker_key: String, text_key: String, seconds := 4.0) -> void:
	_bark_id += 1
	var my_id := _bark_id
	_audit(speaker_key, text_key)
	_show_line(speaker_key, tr(text_key), false)
	_sub_text.visible_ratio = 1.0
	if not _fast():
		var vs := voice_stream(text_key)
		if vs:
			_voice.stream = vs
			_voice.volume_db = VoiceGain.DB.get(text_key, 0.0)
			_voice.play()
			# Ses süreden uzunsa altyazı sesin sonuna kadar kalır
			seconds = maxf(seconds, vs.get_length() + 0.3) if seconds < 20.0 else seconds
		else:
			mumble.speak(minf(1.6, _sub_text.text.length() * 0.028), VOICE.get(speaker_key, 180.0))
	await get_tree().create_timer(0.01 if _fast() else seconds).timeout
	if my_id == _bark_id:
		_sub_box.visible = false


## Ses denetimi (VOICE_AUDIT=1): kimin hangi repliği söylediğini yazar; tools/voice_audit.py ses haritasıyla karşılaştırır.
static var _audit_on := OS.has_environment("VOICE_AUDIT")
static func _audit(speaker_key: String, text_key: String) -> void:
	if _audit_on:
		print("VOICEAUDIT|%s|%s" % [speaker_key, text_key])


func _show_line(speaker_key: String, text: String, blocking: bool) -> void:
	_sub_speaker.text = tr(speaker_key)
	var pic: String = PORTRAITS.get(speaker_key, "")
	if speaker_key == "SPK_TOLGA":
		pic = "portraits/tolga_soot.svg" if tolga_soot else ("portraits/tolga_fez.svg" if _tolga_fez else "portraits/tolga.svg")
	elif speaker_key == "SPK_NIHAT" and GameState.flags.get("nihat_fate", "") == "N3":
		pic = "portraits/nihat_new.svg"
	_portrait.texture = load(ART + pic) if pic != "" else null
	_portrait.visible = pic != ""
	_sub_speaker.add_theme_color_override("font_color", SPEAKER_COLORS.get(speaker_key, Color.WHITE))
	_sub_text.text = text
	_sub_hint.text = tr("UI_CONTINUE") if blocking else ""
	_sub_box.visible = true
	_relayout()


## Süreli (timeout > 0) ya da süresiz seçim. Seçilen dizini, süre dolarsa -1 döner.
func choose(option_keys: Array, timeout := 0.0, autotest_pick := 0) -> int:
	for c in _choice_box.get_children():
		c.queue_free()
	for i in option_keys.size():
		var b := Button.new()
		b.text = "%s  %s" % [GameState.key_hint(str(i + 1)) if GameState.pad else "%d." % (i + 1), tr(option_keys[i])]
		b.add_theme_font_size_override("font_size", 22)
		b.custom_minimum_size = Vector2(520, 52)
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(func(): _choice_made.emit(i))
		_choice_box.add_child(b)
	_choice_timer = ColorRect.new()
	_choice_timer.color = Color("ff5a4a")
	_choice_timer.custom_minimum_size = Vector2(520, 6)
	_choice_box.add_child(_choice_timer)
	_choice_timer.visible = timeout > 0.0
	_choice_box.visible = true
	_place_choices.call_deferred()
	if _fast():
		await get_tree().process_frame
		_choice_box.visible = false
		return autotest_pick
	var prev_mouse := Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var result := -1
	var left := timeout
	var picked := [-1]
	var cb := func(i: int): picked[0] = i
	_choice_made.connect(cb)
	while true:
		await get_tree().process_frame
		for i in option_keys.size():
			if Input.is_action_just_pressed("choice_%d" % (i + 1)):
				picked[0] = i
		if picked[0] >= 0:
			result = picked[0]
			break
		if timeout > 0.0:
			var before := left
			left -= get_process_delta_time()
			if int(before) != int(left) and left > 0.0:
				Audio.sfx("timer_tick", -14.0)
			_choice_timer.custom_minimum_size.x = 520.0 * maxf(0.0, left / timeout)
			if left <= 0.0:
				break
	_choice_made.disconnect(cb)
	_choice_box.visible = false
	if result >= 0:
		Audio.sfx("ui_confirm", -10.0)
	Input.mouse_mode = prev_mouse
	return result


## Açık bir seçimi kapatır (ekran görüntüsü modu için).
func choose_cancel() -> void:
	_choice_box.visible = false


# ---------------------------------------------------------------- tuş takımı

func keypad(autotest_value := "1453") -> String:
	_keypad_value = ""
	_keypad_display.text = "----"
	_keypad_box.visible = true
	if _fast():
		await get_tree().process_frame
		_keypad_box.visible = false
		return autotest_value
	_keypad_active = true
	while _keypad_active:
		await get_tree().process_frame
	_keypad_box.visible = false
	return _keypad_value


func keypad_visible(on: bool) -> void:
	_keypad_box.visible = on


func keypad_show(text: String) -> void:
	_keypad_display.text = text


func _input(event: InputEvent) -> void:
	_title_key(event)
	if not _keypad_active or not (event is InputEventKey) or not event.pressed:
		return
	var k: int = event.physical_keycode
	if k >= KEY_0 and k <= KEY_9 and _keypad_value.length() < 4:
		_keypad_value += str(k - KEY_0)
	elif k >= KEY_KP_0 and k <= KEY_KP_9 and _keypad_value.length() < 4:
		_keypad_value += str(k - KEY_KP_0)
	elif k == KEY_BACKSPACE and _keypad_value.length() > 0:
		_keypad_value = _keypad_value.left(_keypad_value.length() - 1)
	elif (k == KEY_ENTER or k == KEY_KP_ENTER) and _keypad_value.length() == 4:
		_keypad_active = false
	_keypad_display.text = _keypad_value + "-".repeat(4 - _keypad_value.length())
	get_viewport().set_input_as_handled()


# ---------------------------------------------------------------- karartma ve kartlar

func fade_to(alpha: float, seconds: float, color := Color.BLACK) -> void:
	_fade.color = Color(color.r, color.g, color.b, _fade.color.a)
	if alpha >= 0.95:
		clear_transient()
		last_blackout_ms = Time.get_ticks_msec()
	if _fast():
		_fade.color.a = alpha
		return
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", alpha, seconds)
	await tw.finished


func is_faded() -> bool:
	return _fade.color.a > 0.4 or (_card != null and _card.get_child_count() > 0)


func set_fade(alpha: float, color := Color.BLACK) -> void:
	_fade.color = Color(color.r, color.g, color.b, alpha)
	if alpha >= 0.95:
		last_blackout_ms = Time.get_ticks_msec()


## Siyah ekranda ortalanmış satırlar. lines: [[metin, boyut, renk], ...]
func card(lines: Array, hold: float) -> void:
	clear_card()
	clear_transient()
	# Bölüm başlığı (44 pt ilk satır): kapak resmi arkada, yazı alt üçte birde
	var is_title: bool = lines.size() > 0 and int(lines[0][1]) == 44
	if is_title:
		_show_cover()
	for spec in lines:
		var l := _label(spec[0], spec[1], spec[2] if spec.size() > 2 else Color.WHITE)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if int(spec[1]) >= 34 and _title_font != null:
			l.add_theme_font_override("font", _title_font)
		l.modulate.a = 0.0
		_card.add_child(l)
		if not _fast():
			create_tween().tween_property(l, "modulate:a", 1.0, 0.6)
	if not _fast():
		await get_tree().create_timer(hold).timeout


## Daktilo: yazı ekranın altında harf harf belirir (Perde I kapanışı, Nihat'ın raporu).
func typewriter(text: String, per_char := 0.08) -> void:
	var l := _label("", 34, Color("f2e6c9"))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var vs := get_viewport().get_visible_rect().size
	l.position = Vector2(0, vs.y * 0.24)
	l.size = Vector2(vs.x, 60)
	add_child(l)
	if _fast():
		l.text = text
		await get_tree().process_frame
		l.queue_free()
		return
	for i in text.length():
		l.text = text.substr(0, i + 1)
		if text[i] != " ":
			Audio.sfx("typewriter", -8.0, randf_range(0.92, 1.08))
		await get_tree().create_timer(per_char).timeout
	Audio.sfx("typewriter_bell", -8.0)
	await get_tree().create_timer(1.6).timeout
	var tw := create_tween()
	tw.tween_property(l, "modulate:a", 0.0, 0.6)
	await tw.finished
	l.queue_free()


func add_card_line(text: String, font_size: int, color := Color.WHITE) -> Label:
	var l := _label(text, font_size, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.add_child(l)
	return l


func clear_card() -> void:
	for c in _card.get_children():
		c.queue_free()
	_card.alignment = BoxContainer.ALIGNMENT_CENTER
	_card.offset_bottom = 0.0
	_cover.visible = false


func _show_cover() -> void:
	var key := cover_override
	if key == "":
		var scene := get_tree().current_scene
		if scene != null:
			key = COVERS.get(scene.scene_file_path.get_file().get_basename(), "")
	var path := ART + "covers/" + key + ".png"
	if key == "" or not ResourceLoader.exists(path):
		return
	_cover.texture = load(path)
	_cover.visible = true
	_card.alignment = BoxContainer.ALIGNMENT_END
	_card.offset_bottom = -70.0
	if not _fast():
		_cover.modulate.a = 0.0
		create_tween().tween_property(_cover, "modulate:a", 1.0, 0.6)


## Başlık yazı tipi (Alfa Slab One). Dosya yoksa varsayılan kalır.
func _apply_fonts() -> void:
	# Arayüz yazı tipi project.godot'ta (gui/theme/custom_font); burada yalnız başlık yazı tipi
	if ResourceLoader.exists(FONT_TITLE):
		_title_font = load(FONT_TITLE)


## Açılış uyarısı ve başlık (GDD §9.0). Dil L ile değiştirilebilir.
## Başlık ekranı. 0 döner (normal başla) ya da gizli Yaratıcı Menüsü'nden seçilen bölümü.
## Gizli kod: başlık ekranında "yarat" yazmak. Kodun başı yazılıp bırakılırsa oyun yine başlar.
const CREATOR_CODE := "yarat"
var _title_active := false
var _typed := ""
var _typed_t := 0.0


func title_screen() -> int:
	set_fade(1.0)
	await card([[tr("UI_DISCLAIMER_1"), 40]], 2.2)
	var l2 := add_card_line(tr("UI_DISCLAIMER_2"), 22, Color(1, 1, 1, 0.7))
	if not _fast():
		await get_tree().create_timer(2.0).timeout
	l2.queue_free()
	clear_card()
	if not _fast():
		await get_tree().create_timer(0.4).timeout
	var logo := TextureRect.new()
	logo.texture = load(ART + "posters/fez.svg")
	logo.custom_minimum_size = Vector2(0, 130)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_card.add_child(logo)
	var t := add_card_line(tr("UI_TITLE"), 64, Color("f2e6c9"))
	var hint := add_card_line(tr("UI_PRESS_ANY"), 20, Color(1, 1, 1, 0.7))
	var lang := add_card_line(tr("UI_LANG_HINT"), 16, C_ACCENT)
	if _fast():
		clear_card()
		return 0
	_typed = ""
	_title_active = true
	var start := false
	while not start:
		await get_tree().process_frame
		if _typed == CREATOR_CODE:
			_title_active = false
			clear_card()
			var ch := await creator_menu()
			if ch > 0:
				return ch
			return await title_screen()
		if _typed != "":
			# Kodun başı yazıldı ama devam edilmedi: normal başla
			_typed_t += get_process_delta_time()
			if _typed_t > 0.9:
				start = true
			continue
		if Input.is_action_just_pressed("language"):
			GameState.toggle_locale()
			t.text = tr("UI_TITLE")
			hint.text = tr("UI_PRESS_ANY")
			lang.text = tr("UI_LANG_HINT")
		elif Input.is_anything_pressed() and not Input.is_action_pressed("language") and not _is_code_key():
			start = true
	_title_active = false
	clear_card()
	return await main_menu()


## Yeni oyunun başında: kaç karar, kaç son; birkaç örnek. Tuşa basınca ya da 14 sn sonra geçer.
const INTRO_EXAMPLES := ["UI_INTRO_EX_1", "UI_INTRO_EX_2", "UI_INTRO_EX_3", "UI_INTRO_EX_4", "UI_INTRO_EX_5"]


func intro_notice() -> void:
	if _fast():
		return
	set_fade(1.0)
	clear_card()
	var head := add_card_line(tr("UI_INTRO_HEAD"), 34, Color("ffd24a"))
	if _title_font:
		head.add_theme_font_override("font", _title_font)
	add_card_line(tr("UI_INTRO_COUNTS") % [17, 80, 91, 24], 22, Color("f2e6c9"))
	add_card_line("", 8)
	for k in INTRO_EXAMPLES:
		add_card_line("· " + tr(k), 18, Color(1, 1, 1, 0.85))
	add_card_line("", 8)
	add_card_line(tr("UI_INTRO_FLOW"), 16, C_ACCENT)
	add_card_line(tr("UI_PRESS_ANY"), 16, Color(1, 1, 1, 0.55))
	for c in _card.get_children():
		(c as Label).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		(c as Label).custom_minimum_size = Vector2(900, 0)
	await get_tree().create_timer(0.8).timeout
	var t := 0.0
	while t < 14.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		if Input.is_action_just_pressed("advance") or Input.is_action_just_pressed("continue"):
			break
	clear_card()


## Ana menü (başlık ekranından sonra, garaj arkada). 0 = yeni oyun; -1 = sahne değişiyor.
func main_menu() -> int:
	if _fast():
		return 0
	fade_to(0.35, 0.8)
	var prev_music := Audio.current_music()
	Audio.music("menu", 1.2)
	var m := GameMenu.new("main")
	m.title_font = _title_font
	_menu = m
	add_child(m)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var res: Array = await m.picked
	_menu = null
	m.queue_free()
	Audio.music(prev_music, 1.0)
	var action: String = res[0]
	var arg: int = res[1]
	match action:
		"new":
			return 0
		"continue":
			GameState.load_run(GameState.read_auto())
		"load":
			GameState.load_run(GameState.read_slot(arg))
		"chapter":
			GameState.load_run(GameState.read_auto(), arg)
		"quit":
			get_tree().quit()
	return -1


func _is_code_key() -> bool:
	# Kodun ilk harfine basılıyken hemen başlama (kod mu yazılıyor, bekle)
	return Input.is_physical_key_pressed(OS.find_keycode_from_string(CREATOR_CODE[0].to_upper()))


func _title_key(event: InputEvent) -> void:
	if not _title_active or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var c := char(event.unicode).to_lower() if event.unicode > 0 else ""
	var next := _typed + c
	if c != "" and CREATOR_CODE.begins_with(next):
		_typed = next
		_typed_t = 0.0
	elif _typed != "":
		_typed_t = 1.0  # yanlış harf: kod değilmiş, normal başla


## Gizli Yaratıcı Menüsü: bölüm seç. 0 = geri.
func creator_menu() -> int:
	var latest := GameState.LATEST_CHAPTER
	await card([[tr("UI_DEV_TITLE"), 40, Color("ffd60a")], [tr("UI_DEV_SUB"), 18, Color(1, 1, 1, 0.7)]], 0.0)
	for n in range(1, latest + 1):
		var line := "[%d]  %s" % [n, tr("UI_CH%d_TITLE" % n)]
		if n == latest:
			line += "  " + tr("UI_DEV_NEW")
		add_card_line(line, 24, Color("f2e6c9") if n == latest else Color(1, 1, 1, 0.85))
	add_card_line(tr("UI_DEV_HINT"), 18, C_ACCENT)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().process_frame
	var pick := -1
	while pick < 0:
		await get_tree().process_frame
		for n in range(1, latest + 1):
			if Input.is_action_just_pressed("choice_%d" % n):
				pick = n
		if Input.is_action_just_pressed("continue"):
			pick = latest
		elif Input.is_action_just_pressed("pause"):
			pick = 0
	clear_card()
	return pick


## Klasik film geçişi: gazete dönerek ekrana gelir, bir süre durur, kaybolur.
func spin_newspaper(tex: Texture2D, hold: float) -> void:
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var vs := get_viewport().get_visible_rect().size
	var h := vs.y * 0.86
	r.size = Vector2(h * tex.get_width() / float(tex.get_height()), h)
	r.position = (vs - r.size) * 0.5
	r.pivot_offset = r.size * 0.5
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.scale = Vector2(0.05, 0.05)
	r.rotation = -TAU * 2.0
	add_child(r)
	var t := 0.05 if _fast() else 0.9
	var tw := create_tween().set_parallel(true)
	tw.tween_property(r, "scale", Vector2.ONE, t).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(r, "rotation", -0.04, t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished
	await get_tree().create_timer(0.01 if _fast() else hold).timeout
	var out := create_tween()
	out.tween_property(r, "modulate:a", 0.0, 0.05 if _fast() else 0.4)
	await out.finished
	r.queue_free()


# ---------------------------------------------------------------- akış şeması

## Bölüm sonu akış şeması. "next", "replay" ya da "quit" döner.
func show_flowchart(chart: Flowchart, can_continue := false) -> String:
	Audio.music("flowchart")
	Audio.ambience("")
	var scene := get_tree().current_scene
	if chart.strip == null and scene != null:
		var digits := scene.scene_file_path.get_file().get_basename().trim_prefix("chapter").to_int()
		var sp := ART + "flow/ch%d.png" % digits
		if digits > 0 and ResourceLoader.exists(sp):
			chart.strip = load(sp)
	add_child(chart)
	move_child(chart, get_child_count() - 1)
	if _fast():
		await get_tree().process_frame
		return "quit"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().create_timer(0.4).timeout
	while true:
		await get_tree().process_frame
		if can_continue and Input.is_action_just_pressed("continue"):
			chart.queue_free()
			return "next"
		if Input.is_action_just_pressed("red_button"):
			return "replay"
		if Input.is_action_just_pressed("quit"):
			return "quit"
	return "quit"


# ---------------------------------------------------------------- duraklatma

## Foto modu açılabilir mi: Tolga oynanıyor, menü ya da başlık açık değil.
func _photo_player() -> Player:
	var sc := get_tree().current_scene
	if sc == null or _menu != null or _title_active or _photo != null:
		return null
	var p = sc.get("player")
	if p is Player and (p as Player).hand_style == "tolga" and (p as Player).is_inside_tree():
		return p
	return null


var _photo: PhotoMode


func open_photo_mode() -> void:
	var p := _photo_player()
	if p == null or GameState.autotest:
		return
	_photo = PhotoMode.new(p, self)
	add_child(_photo)
	await _photo.closed
	_photo = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("photo_mode"):
		open_photo_mode()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") and not _keypad_active and not _title_active and _menu == null and _photo == null:
		_set_paused(true)
		get_viewport().set_input_as_handled()


var _mouse_before_pause := Input.MOUSE_MODE_CAPTURED


func _set_paused(on: bool) -> void:
	get_tree().paused = on
	if on:
		_mouse_before_pause = Input.mouse_mode
		Audio.sfx("menu_open", -8.0)
		var m := GameMenu.new("pause")
		m.title_font = _title_font
		_menu = m
		add_child(m)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var res: Array = await m.picked
		_menu = null
		m.queue_free()
		Audio.sfx("menu_close", -8.0)
		get_tree().paused = false
		Engine.time_scale = 1.0
		var action: String = res[0]
		var arg: int = res[1]
		match action:
			"resume":
				Input.mouse_mode = _mouse_before_pause
			"photo":
				Input.mouse_mode = _mouse_before_pause
				open_photo_mode()
			"chapter":
				GameState.rewind_to(arg)
			"load":
				GameState.load_run(GameState.read_slot(arg))
			"main_menu":
				GameState.skip_title = false
				get_tree().change_scene_to_file("res://scenes/chapter1.tscn")
			"quit":
				get_tree().quit()

