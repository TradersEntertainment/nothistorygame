class_name TimeVortex
extends CanvasLayer
## Zaman tüneli: ekran girdaba döner (önce görüntü burulur, sonra halkalı tünel), ortada yıl sayacı geriye akar
## (2026 → 1453), sonunda beyaz patlama. Makine kalkışlarında kullanılır.
##   var v := TimeVortex.new(); add_child(v); await v.play(2026, 1453, 3.2)
## Bittiğinde ekran beyazdır; çağıran bölüm beyazdan açılır ya da sahneyi değiştirir.

var _rect: ColorRect
var _mat: ShaderMaterial
var _year: Label
var _t := 0.0

const SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float prog = 0.0;
uniform float clock = 0.0;
void fragment() {
	vec2 uv = SCREEN_UV - 0.5;
	float asp = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 q = vec2(uv.x * asp, uv.y);
	float r = length(q);
	float a = atan(q.y, q.x);
	// 1) Görüntü merkeze doğru burulur
	float tw = prog * 6.0 * (1.0 - smoothstep(0.0, 0.9, r));
	float ca = cos(tw), sa = sin(tw);
	vec2 sw = vec2(uv.x * ca - uv.y * sa, uv.x * sa + uv.y * ca) * (1.0 - prog * 0.35) + 0.5;
	vec3 scr = texture(screen_tex, sw).rgb;
	// 2) Tünel: derinliğe akan halkalar ve sarmal ışık çizgileri
	float depth = 0.3 / max(r, 0.015) + clock * (1.5 + prog * 9.0);
	float rings = pow(0.5 + 0.5 * sin(depth * 5.0), 3.0);
	float streak = pow(0.5 + 0.5 * sin((a + depth * 0.45) * 9.0), 8.0);
	vec3 warm = vec3(1.0, 0.62, 0.25);
	vec3 cold = vec3(0.35, 0.62, 1.0);
	vec3 col = mix(warm, cold, smoothstep(0.2, 0.8, prog));
	vec3 tun = col * (rings * 0.55 + streak * 1.3) * smoothstep(0.02, 0.3, r);
	tun += vec3(1.0, 0.96, 0.88) * smoothstep(0.18, 0.0, r) * (0.6 + prog);
	vec3 c = mix(scr, tun, smoothstep(0.1, 0.45, prog));
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
