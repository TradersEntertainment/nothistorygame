class_name TimeVortex
extends CanvasLayer
## Zaman tüneli: ekran girdaba döner (önce görüntü burulur, sonra halkalı tünel), ortada yıl sayacı geriye akar
## (2026 → 1453), sonunda beyaz patlama. Makine kalkışlarında kullanılır.
##   var v := TimeVortex.new(); add_child(v); await v.play(2026, 1453, 3.2)
## Nihat'ın ışınlamaları (v0.99.6) tarih ya da yazıyla: play_text("ZAMANIN DIŞI", "9 NİSAN 1453", 1.8, false, telsiz)
## glitch: arıza (kırmızı, yırtık görüntü; sayaç takılır, "HATA" yanıp söner). Kısa girdapta (sayfadan sayfaya) sayacın
## altında Nihat'ın telsizinden bir satır.
## Bittiğinde ekran beyazdır; çağıran bölüm beyazdan açılır ya da sahneyi değiştirir.

var _rect: ColorRect
var _mat: ShaderMaterial
var _year: Label
var _caption: Label
var _t := 0.0
## Sayaçta karışan harfler (tarihten tarihe geçerken)
const GLYPHS := "0123456789ABCDEFGHIJKLMNOPRSTUVYZ"

const SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float prog = 0.0;
uniform float clock = 0.0;
uniform float glitch = 0.0;
void fragment() {
	vec2 uv = SCREEN_UV - 0.5;
	float asp = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	// 0) Arıza: yatay yırtılma bantları kayar (bant başına sıçrayan gürültü)
	float band = floor(SCREEN_UV.y * 26.0 + floor(clock * 11.0) * 3.0);
	float nz = fract(sin(band * 91.7 + floor(clock * 13.0) * 7.31) * 43758.55);
	uv.x += (nz > 0.78 ? (nz - 0.78) * 0.9 : 0.0) * glitch;
	vec2 q = vec2(uv.x * asp, uv.y);
	float r = length(q);
	float a = atan(q.y, q.x);
	// 1) Görüntü merkeze doğru burulur
	float tw = prog * 6.0 * (1.0 - smoothstep(0.0, 0.9, r));
	float ca = cos(tw), sa = sin(tw);
	vec2 sw = vec2(uv.x * ca - uv.y * sa, uv.x * sa + uv.y * ca) * (1.0 - prog * 0.35) + 0.5;
	// Arızada renk kanalları ayrılır
	float ch = 0.012 * glitch;
	vec3 scr = vec3(texture(screen_tex, sw + vec2(ch, 0.0)).r, texture(screen_tex, sw).g, texture(screen_tex, sw - vec2(ch, 0.0)).b);
	// 2) Tünel: derinliğe akan halkalar ve sarmal ışık çizgileri
	float depth = 0.3 / max(r, 0.015) + clock * (1.5 + prog * 9.0);
	float rings = pow(0.5 + 0.5 * sin(depth * 5.0), 3.0);
	float streak = pow(0.5 + 0.5 * sin((a + depth * 0.45) * 9.0), 8.0);
	vec3 warm = vec3(1.0, 0.62, 0.25);
	vec3 cold = vec3(0.35, 0.62, 1.0);
	vec3 col = mix(warm, cold, smoothstep(0.2, 0.8, prog));
	col = mix(col, vec3(1.0, 0.22, 0.16), glitch * 0.85);
	vec3 tun = col * (rings * 0.55 + streak * 1.3) * smoothstep(0.02, 0.3, r);
	tun += vec3(1.0, 0.96, 0.88) * smoothstep(0.18, 0.0, r) * (0.6 + prog);
	vec3 c = mix(scr, tun, smoothstep(0.1, 0.45, prog));
	// Arıza: kırmızı ton ve ara sıra sönen satırlar
	c = mix(c, c * vec3(1.3, 0.5, 0.45), glitch * 0.55);
	c *= 1.0 - glitch * 0.5 * step(0.93, fract(sin(floor(SCREEN_UV.y * 90.0) * 12.9 + floor(clock * 20.0)) * 4375.85));
	// 3) Sonda beyaz
	c = mix(c, vec3(1.0), smoothstep(0.82, 1.0, prog));
	COLOR = vec4(c, 1.0);
}
"""


func _ready() -> void:
	layer = 20
	_rect = ColorRect.new()
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_rect.material = _mat
	add_child(_rect)
	_year = Label.new()
	_year.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_year.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_year.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_year.add_theme_font_override("font", load(Hud.FONT_TITLE))
	_year.add_theme_font_size_override("font_size", 150)
	_year.add_theme_color_override("font_color", Color("ffd24a"))
	_year.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_year.add_theme_constant_override("outline_size", 22)
	_year.modulate.a = 0.0
	add_child(_year)
	_caption = Label.new()
	_caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_caption.offset_top = 210.0
	_caption.add_theme_font_size_override("font_size", 26)
	_caption.add_theme_color_override("font_color", Color("cfeeff"))
	_caption.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_caption.add_theme_constant_override("outline_size", 10)
	_caption.modulate.a = 0.0
	add_child(_caption)


func _process(delta: float) -> void:
	_t += delta
	_mat.set_shader_parameter("clock", _t)


## Girdabı oynatır; bitince ekran bembeyazdır.
func play(from_year: int, to_year: int, secs := 3.2) -> void:
	var tw := create_tween().set_parallel()
	tw.tween_method(func(v: float): _mat.set_shader_parameter("prog", v), 0.0, 1.0, secs).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Yıl sayacı: yavaş başlar, ortada çok hızlı akar, hedefte durur ve bir an parlar
	tw.tween_property(_year, "modulate:a", 1.0, secs * 0.2).set_delay(secs * 0.12)
	tw.tween_method(func(v: float): _year.text = str(int(round(lerpf(from_year, to_year, v)))), 0.0, 1.0, secs * 0.72).set_delay(secs * 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	Audio.sfx("machine_spin", -4.0, 1.6)
	Audio.sfx("whoosh_fly", -6.0, 0.5)
	await get_tree().create_timer(secs * 0.86).timeout
	_year.text = str(to_year)
	_year.pivot_offset = _year.size * 0.5
	var pop := create_tween()
	pop.tween_property(_year, "scale", Vector2.ONE * 1.25, 0.12)
	pop.tween_property(_year, "scale", Vector2.ONE, 0.2)
	Audio.sfx("whoosh_fly", -2.0, 0.35)
	await get_tree().create_timer(secs * 0.14 + 0.1).timeout


## Tarih ya da yazıyla girdap (Nihat'ın ışınlamaları): sayaç from'dan to'ya akar. İkisi de yılsa sayılar akar; değilse
## harfler karışarak yerine oturur ("ZAMANIN DIŞI" → "9 NİSAN 1453"). glitch: arıza; sayaç takılır, "HATA" yanıp söner,
## görüntü kırmızı ve yırtık. caption: sayacın altında küçük satır (telsiz). Bitince ekran bembeyazdır.
func play_text(from: String, to: String, secs := 1.8, glitch := false, caption := "") -> void:
	_fit(maxi(from.length(), to.length()))
	_year.text = from
	if glitch:
		_mat.set_shader_parameter("glitch", 0.0)
		_year.add_theme_color_override("font_color", Color("ff8a6a"))
	var tw := create_tween().set_parallel()
	tw.tween_method(func(v: float): _mat.set_shader_parameter("prog", v), 0.0, 1.0, secs).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(_year, "modulate:a", 1.0, secs * 0.18).set_delay(secs * 0.08)
	if glitch:
		tw.tween_method(func(v: float): _mat.set_shader_parameter("glitch", v), 0.0, 1.0, secs * 0.35).set_delay(secs * 0.15)
	if caption != "":
		_caption.text = caption
		tw.tween_property(_caption, "modulate:a", 1.0, secs * 0.15).set_delay(secs * 0.1)
	var steps := _glitch_steps(from, to) if glitch else []
	if steps.is_empty():
		tw.tween_method(func(v: float): _year.text = _between(from, to, v), 0.0, 1.0, secs * 0.66).set_delay(secs * 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	Audio.sfx("machine_spin", -4.0, 1.9 if not glitch else 1.25)
	Audio.sfx("whoosh_fly", -6.0, 0.5)
	if not steps.is_empty():
		# Arıza: sayaç düzgün akmaz; takılır, geri sıçrar, "HATA" yanar, sonra yanlış yılda durur
		var per := secs * 0.72 / steps.size()
		await get_tree().create_timer(secs * 0.1).timeout
		for k in steps.size():
			var st: String = steps[k]
			_year.text = st
			if st == tr("UI_JUMP_ERROR"):
				Audio.sfx("radio_beep", -2.0, 0.6)
				_year.add_theme_color_override("font_color", Color("ff3a2a"))
			else:
				_year.add_theme_color_override("font_color", Color("ff8a6a") if k % 2 == 0 else Color("ffd24a"))
				Audio.sfx("timer_tick", -8.0, 0.8 + randf() * 0.4)
			await get_tree().create_timer(per).timeout
		await get_tree().create_timer(maxf(0.0, secs * 0.86 - secs * 0.1 - per * steps.size())).timeout
	else:
		await get_tree().create_timer(secs * 0.86).timeout
	_year.text = to
	_year.add_theme_color_override("font_color", Color("ffd24a") if not glitch else Color("ff6a4a"))
	_year.pivot_offset = _year.size * 0.5
	var pop := create_tween()
	pop.tween_property(_year, "scale", Vector2.ONE * 1.25, 0.12)
	pop.tween_property(_year, "scale", Vector2.ONE, 0.2)
	Audio.sfx("whoosh_fly", -2.0, 0.35)
	await get_tree().create_timer(secs * 0.14 + 0.1).timeout


## Uzun yazı sayaca sığsın: yılın 150 punto boyu dört harf içindir.
func _fit(n: int) -> void:
	var fs := 150 if n <= 4 else clampi(int(150.0 * 6.0 / float(n)), 58, 120)
	_year.add_theme_font_size_override("font_size", fs)
	_year.add_theme_constant_override("outline_size", maxi(10, fs / 7))


## v (0–1) anındaki sayaç: iki yıl arasında sayı akar; yazılar harf harf karışarak yerine oturur.
func _between(a: String, b: String, v: float) -> String:
	if a.is_valid_int() and b.is_valid_int():
		return str(int(round(lerpf(float(a), float(b), v))))
	if v <= 0.02:
		return a
	if v >= 0.98:
		return b
	var n := b.length()
	var settled := int(v * float(n + 1))
	var out := ""
	for i in n:
		var c := b[i]
		if i < settled or c == " " or c == ",":
			out += c
		else:
			out += GLYPHS[randi() % GLYPHS.length()]
	return out


## Arızanın sayaç adımları: iki yıl arasında takılarak (1453 → 1452 → 1449 → 1451 → HATA → 1446 → 1444), yazıda karışık
## harfler ve HATA.
func _glitch_steps(a: String, b: String) -> Array:
	var err := tr("UI_JUMP_ERROR")
	if a.is_valid_int() and b.is_valid_int():
		var x := int(a)
		var y := int(b)
		var mid := (x + y) / 2
		return [str(x - signi(x - y)), str(mid + 1), str(x - 2 * signi(x - y)), err, str(mid), err, str(y + signi(x - y))]
	return [_between(a, b, 0.3), err, _between(a, b, 0.6), err]

