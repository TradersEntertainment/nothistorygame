class_name RowMeter
extends Control
## Kürek ritmi (Bölüm 17): ibre bir kürek çekişini (1 evre) soldan sağa geçer; yeşil pencerede Space'e basılırsa
## kürek suya sessiz girer ve kayık hızlanır. Erken ya da geç basış şapırtı yapar (gürültü artar).
## Kürekçiler de ibrenin evresiyle birlikte çeker (Rig.row_phase).

signal stroke(good: bool)
## İbre yeşil pencereye girdi (ritim işareti: kızak çekenlerin davulu, Bölüm 28o)
signal beat

const PERIOD := 1.5
const WIN_A := 0.72
const WIN_B := 0.9

var phase := 0.0
var noise := 0.0
var streak := 0
var enabled := false
var _flash := 0.0
var _flash_good := true
var _pressed_this := false
## Basışın sesi ("" sessiz: kızak çekmede kürek şapırtısı yok); gürültü çubukları (kürek) gösterilsin mi
var sound := "splash"
var show_noise := true
## İbrenin üstünde kısa yazı (iyi/erken/geç geri bildirimi), rengiyle; caption_t saniye görünür
var caption := ""
var caption_col := Color("fff3d6")
var caption_t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_left = -220.0
	offset_right = 220.0
	offset_top = -150.0
	offset_bottom = -96.0


func _process(delta: float) -> void:
	visible = enabled
	if not enabled:
		return
	# Altyazı açıkken onun üstüne çıkar (eskiden altyazı kutusunun ortasına çiziliyordu)
	var p := get_parent()
	var up: bool = p != null and p.has_method("is_talking") and p.is_talking()
	offset_top = -260.0 if up else -150.0
	offset_bottom = offset_top + 54.0
	var before := phase
	phase = fmod(phase + delta / PERIOD, 1.0)
	# Otomatik test pencerenin ortasında basar, kare süresinden bağımsız: test 3 kat hızda koşar, yük altında ibre bir
	# karede pencerenin sonunu aşıyor, bot geç basıyordu (35o'da 56 kayma, yalnız paralel koşuda)
	var mid := (WIN_A + WIN_B) * 0.5
	if GameState.autotest and enabled and not _pressed_this and before < mid and before + delta / PERIOD >= mid:
		phase = mid
	if before < WIN_A and phase >= WIN_A:
		beat.emit()
	caption_t = maxf(0.0, caption_t - delta)
	if phase < before:
		# Evre bitti: basılmadıysa seri bozulur (kayık yavaşlar, ses yok)
		if not _pressed_this:
			streak = 0
		_pressed_this = false
	noise = maxf(0.0, noise - delta * 0.08)
	_flash = maxf(0.0, _flash - delta * 3.0)
	if GameState.autotest and not _pressed_this and phase >= mid:
		press()
	queue_redraw()


func press() -> void:
	if not enabled or _pressed_this:
		return
	_pressed_this = true
	var good := phase >= WIN_A and phase <= WIN_B
	if good:
		streak = mini(streak + 1, 6)
		if sound != "":
			Audio.sfx(sound, -22.0, 1.4)
	else:
		streak = 0
		noise = minf(1.0, noise + 0.3)
		if sound != "":
			Audio.sfx(sound, -8.0, 0.9)
	_flash = 1.0
	_flash_good = good
	stroke.emit(good)


## İbrenin üstünde kısa geri bildirim yazısı
func say(text: String, col := Color("fff3d6"), secs := 1.1) -> void:
	caption = text
	caption_col = col
	caption_t = secs


## 0 (duruyor) .. 1 (tam hız): seriye bağlı
func speed_factor() -> float:
	return 0.35 + 0.65 * float(streak) / 6.0


func _draw() -> void:
	var r := Rect2(Vector2(0, 16), Vector2(size.x, 18))
	draw_rect(r.grow(3), Color(0, 0, 0, 0.5))
	draw_rect(r, Color("2a3450"))
	var w := Rect2(Vector2(size.x * WIN_A, r.position.y), Vector2(size.x * (WIN_B - WIN_A), r.size.y))
	draw_rect(w, Color("5fcf6a"))
	var x := size.x * phase
	draw_rect(Rect2(Vector2(x - 3, r.position.y - 6), Vector2(6, r.size.y + 12)), Color("fff3d6"))
	if _flash > 0.0:
		var c := Color("5fcf6a") if _flash_good else Color("ff5a4a")
		c.a = _flash
		draw_rect(r.grow(6), c, false, 3.0)
	if caption_t > 0.0 and caption != "":
		var f := get_theme_default_font()
		var cc := caption_col
		cc.a = minf(1.0, caption_t * 2.0)
		draw_string_outline(f, Vector2(0, -6), caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, 22, 6, Color(0, 0, 0, cc.a * 0.8))
		draw_string(f, Vector2(0, -6), caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, 22, cc)
	if not show_noise:
		for i in 6:
			draw_circle(Vector2(8 + i * 16, 6), 4.0, Color("fff3d6") if i < streak else Color(1, 1, 1, 0.2))
		return
	# Gürültü: sağda küçük dalga çubukları
	for i in 5:
		var on := noise > float(i) / 5.0
		draw_rect(Rect2(Vector2(size.x + 14 + i * 9, 34 - i * 5), Vector2(6, 6 + i * 5)), Color("ff9a4a") if on else Color(1, 1, 1, 0.2))
	# Seri
	for i in 6:
		draw_circle(Vector2(8 + i * 16, 6), 4.0, Color("fff3d6") if i < streak else Color(1, 1, 1, 0.2))
