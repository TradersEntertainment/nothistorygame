class_name MiniGameHaggle
extends MiniGame
## Galata'da pazarlık: bir fıçı şarap (şarapçı) ya da "iki tarafa da" barut (çifte tüccar).
## 1 düşük teklif, 2 makul teklif, 3 fiyatı kabul, 4 tatlı dil (sabır kazandırır, en fazla iki kez).
## Satıcının sabrı biterse pazarlık biter. Fiyat ilk fiyatın %60'ına ya da altına inerse kazanılır.

var merchant := "wine"          # wine: sabırsız, ucuz başlar · double: sabırlı, pahalı başlar
var _start := 40
var _ask := 40.0
var _floor := 20.0
var _patience := 100.0
var _sweet := 2
var _round := 0
var _line: Label
var _price: Label
var _bar: ProgressBar
var _options: Label
var _over := false


func setup() -> void:
	var w := merchant == "wine"
	_start = 40 if w else 60
	_ask = float(_start)
	_floor = _start * randf_range(0.45, 0.55)
	heading(tr("MG_HAG_TITLE_W" if w else "MG_HAG_TITLE_D"))
	footer(tr("MG_HAG_HELP"))
	_price = text_label("", 34, C_GOLD)
	_price.position = Vector2(0, 10)
	_bar = ProgressBar.new()
	_bar.max_value = 100.0
	_bar.show_percentage = false
	_bar.position = Vector2(0, 70)
	_bar.size = Vector2(area.size.x, 18)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("c8503a")
	_bar.add_theme_stylebox_override("fill", fill)
	area.add_child(_bar)
	text_label(tr("MG_HAG_PATIENCE"), 14, C_DIM).position = Vector2(0, 92)
	_line = text_label(tr("MG_HAG_%s_OPEN" % merchant.to_upper()), 20, C_CREAM)
	_line.position = Vector2(0, 130)
	_line.size = Vector2(area.size.x, 90)
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_options = text_label("", 19, C_ACCENT)
	_options.position = Vector2(0, 240)
	_refresh()


func _refresh() -> void:
	_price.text = tr("MG_HAG_PRICE") % int(round(_ask))
	_bar.value = _patience
	_options.text = tr("MG_HAG_OPTIONS") % [int(round(_ask * 0.6)), int(round(_ask * 0.85)), int(round(_ask)), _sweet]


func _process(_delta: float) -> void:
	if _over:
		if Input.is_action_just_pressed("advance") or Input.is_action_just_pressed("choice_1"):
			var price := int(round(_ask))
			var won := price <= int(_start * 0.6)
			finish(clampi(int(round((1.0 - price / float(_start)) * 100.0)), 0, 100) if _deal else 0, won and _deal)
		return
	for i in 4:
		if Input.is_action_just_pressed("choice_%d" % (i + 1)):
			_act(i)


var _deal := false


func _act(i: int) -> void:
	var w := merchant == "wine"
	_round += 1
	var key := ""
	match i:
		0:
			var offer := _ask * 0.6
			_patience -= 34.0 if w else 20.0
			if offer >= _floor:
				_ask = lerpf(_ask, offer, 0.5)
			key = "LOW"
		1:
			var offer := _ask * 0.85
			_patience -= 12.0 if w else 8.0
			_ask = maxf(_floor, lerpf(_ask, offer, 0.7))
			key = "FAIR"
		2:
			_deal = true
			_end("WIN" if _ask <= _start * 0.6 else "DEAL")
			return
		3:
			if _sweet <= 0:
				key = "NOSWEET"
			else:
				_sweet -= 1
				_patience = minf(100.0, _patience + 22.0)
				key = "SWEET"
	if _patience <= 0.0:
		_patience = 0.0
		_deal = false
		_end("LOSE")
		return
	if _round >= 7:
		_deal = true
		_end("WIN" if _ask <= _start * 0.6 else "DEAL")
		return
	_line.text = tr("MG_HAG_%s_%s" % [merchant.to_upper(), key])
	Audio.sfx("ui_confirm", -12.0)
	_refresh()


func _end(key: String) -> void:
	_over = true
	_refresh()
	_line.text = tr("MG_HAG_%s_%s" % [merchant.to_upper(), key])
	_options.text = tr("MG_HAG_END") % int(round(_ask)) if _deal else tr("MG_HAG_END_NONE")
	Audio.sfx("stamp" if key == "WIN" else "ui_confirm", -6.0)
