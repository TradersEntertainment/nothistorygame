extends Node
## Vuruş hissi ("juice"): kısa donma (hit-stop), ağır çekim, birikimli sarsıntı, görüş açısı darbesi ve ekran kenarı
## rengi. Tek yerden yönetilir; bölümler ve sistemler yalnızca çağırır.
##
## Zaman ölçeği: bölümler otomatik testte Engine.time_scale'i 2,5–3'e çeker. Fx onların yazdığını "taban" sayar ve
## etkiyi tabanın üstüne çarpar; etki bitince tabana döner. Fx'in yazmadığı bir değer görülürse (bölüm ya da menü
## değiştirdi) yeni taban odur. Sahne değişince bütün etkiler sıfırlanır.
## Ayar "fx" (0..1): 0'da donma, ağır çekim, sarsıntı ve görüş darbesi kapanır (hareket hassasiyeti); kenar rengi
## (hasar uyarısı) yarım güçte kalır.

var _base := 1.0
var _written := -1.0          # Fx'in en son yazdığı Engine.time_scale (-1: etki yok, dokunmuyor)
var _hit_t := 0.0             # gerçek saniye
var _slow_t := 0.0
var _slow_scale := 1.0
var _ease_t := 0.0
var _ease_dur := 0.0
var _fov_t := 0.0
var _fov_dur := 0.0
var _fov_deg := 0.0
var _fov_base := -1.0
var _fov_cam: Camera3D
var _edge_amt := 0.0
var _edge_dur := 0.0
var _edge_t := 0.0
var _edge_peak := 0.0
var _last_us := 0
var _busy_t := 0.0
var _scene: Node
var _layer: CanvasLayer
var _rect: ColorRect
var _mat: ShaderMaterial
## Otomatik test: bölüm sonunda zaman ölçeği tabana dönmüş mü diye bakılır
var active_count := 0

const EDGE_SHADER := """
shader_type canvas_item;
uniform vec4 col : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float amt = 0.0;
void fragment() {
	vec2 d = (UV - 0.5) * vec2(1.0, 0.78);
	float r = length(d) * 2.0;
	float a = smoothstep(0.55, 1.15, r) * amt;
	COLOR = vec4(col.rgb, clamp(a, 0.0, 1.0) * col.a);
}
"""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_layer = CanvasLayer.new()
	_layer.layer = 9          # HUD'un (10) altında: yazılar kenar renginin üstünde kalır
	add_child(_layer)
	_rect = ColorRect.new()
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	var sh := Shader.new()
	sh.code = EDGE_SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_rect.material = _mat
	_rect.visible = false
	_layer.add_child(_rect)
	_last_us = Time.get_ticks_usec()


func _strength() -> float:
	return clampf(float(GameState.settings.get("fx", 1.0)), 0.0, 1.0)


## Kısa donma: vuruşun "oturduğu" an (gerçek saniye). Üst üste gelirse uzun olan kalır.
func hitstop(sec := 0.07) -> void:
	if _strength() <= 0.0:
		return
	_hit_t = maxf(_hit_t, sec * _strength())


## Ağır çekim: ölçek (0..1) sec gerçek saniye sürer, sonra ease_out saniyede tabana yumuşakça döner.
func slowmo(scale := 0.35, sec := 0.6, ease_out := 0.25) -> void:
	var k := _strength()
	if k <= 0.0:
		return
	_slow_scale = lerpf(1.0, scale, k) if _slow_t <= 0.0 else minf(_slow_scale, lerpf(1.0, scale, k))
	_slow_t = maxf(_slow_t, sec)
	_ease_dur = ease_out
	_ease_t = 0.0


## Birikimli sarsıntı (oyuncu kamerası).
func trauma(amount: float) -> void:
	var k := _strength()
	if k <= 0.0:
		return
	var p := get_tree().get_first_node_in_group("player")
	if p and p.has_method("shake"):
		p.shake(amount * k)


## Görüş açısı darbesi: kamera bir an daralır, geri açılır.
func fov_punch(deg := 6.0, sec := 0.25) -> void:
	var k := _strength()
	if k <= 0.0:
		return
	var p := get_tree().get_first_node_in_group("player")
	if p == null or not ("camera" in p) or p.camera == null:
		return
	if _fov_t <= 0.0 or _fov_cam != p.camera:
		_fov_cam = p.camera
		_fov_base = _fov_cam.fov
	_fov_deg = maxf(_fov_deg if _fov_t > 0.0 else 0.0, deg * k)
	_fov_dur = sec
	_fov_t = sec


## Ekran kenarı rengi: kırmızı hasar, altın parry, beyaz top patlaması.
func edge(color: Color, strength := 0.6, sec := 0.35) -> void:
	var k := maxf(_strength(), 0.5)
	_mat.set_shader_parameter("col", color)
	_edge_peak = maxf(strength * k, _edge_amt)
	_edge_dur = sec
	_edge_t = 0.0
	_edge_amt = _edge_peak
	_rect.visible = true


## Bütün etkileri hemen bitirir, zaman ölçeğini tabana döndürür.
func reset() -> void:
	_hit_t = 0.0
	_slow_t = 0.0
	_ease_t = 0.0
	_ease_dur = 0.0
	_edge_amt = 0.0
	_rect.visible = false
	if _fov_t > 0.0 and is_instance_valid(_fov_cam):
		_fov_cam.fov = _fov_base
	_fov_t = 0.0
	if _written >= 0.0:
		Engine.time_scale = _base
		_written = -1.0
	AudioServer.playback_speed_scale = 1.0


## Ağır çekim ya da donma sürüyor mu
func busy() -> bool:
	return _hit_t > 0.0 or _slow_t > 0.0 or _ease_t < _ease_dur


func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	var dt := clampf((now - _last_us) / 1000000.0, 0.0, 0.1)
	_last_us = now
	var sc := get_tree().current_scene
	if sc != _scene:
		_scene = sc
		reset()
		_base = Engine.time_scale
	if get_tree().paused:
		return
	# Başkası (bölüm, menü) zaman ölçeğini değiştirdiyse yeni taban o
	if _written >= 0.0 and not is_equal_approx(Engine.time_scale, _written):
		_base = Engine.time_scale
		_written = -1.0
	elif _written < 0.0:
		_base = Engine.time_scale
	var f := 1.0
	if _hit_t > 0.0:
		_hit_t -= dt
		f = 0.02
	elif _slow_t > 0.0:
		_slow_t -= dt
		f = _slow_scale
	elif _ease_t < _ease_dur:
		_ease_t += dt
		f = lerpf(_slow_scale, 1.0, smoothstep(0.0, 1.0, _ease_t / maxf(_ease_dur, 0.001)))
	if f < 0.999:
		_written = _base * f
		Engine.time_scale = _written
		AudioServer.playback_speed_scale = lerpf(1.0, 0.85, clampf((1.0 - f) * 1.5, 0.0, 1.0))
	elif _written >= 0.0:
		Engine.time_scale = _base
		_written = -1.0
		AudioServer.playback_speed_scale = 1.0
	active_count = 1 if _written >= 0.0 else 0
	# Bekçi: hiçbir etki 6 sn'den uzun sürmez; sürerse (bir hata yüzünden takıldıysa) sıfırlanır ve testte uyarı yazılır
	if _written >= 0.0:
		_busy_t += dt
		if _busy_t > 6.0:
			if GameState.autotest:
				print("WARN_FX_STUCK scale=%.2f base=%.2f" % [Engine.time_scale, _base])
			reset()
	else:
		_busy_t = 0.0
	# Görüş darbesi: hızlı daralma, yumuşak açılma
	if _fov_t > 0.0:
		_fov_t -= dt
		if is_instance_valid(_fov_cam):
			var u := 1.0 - clampf(_fov_t / maxf(_fov_dur, 0.001), 0.0, 1.0)
			var curve := sin(minf(u * 4.0, 1.0) * PI * 0.5) * (1.0 - smoothstep(0.25, 1.0, u))
			_fov_cam.fov = _fov_base - _fov_deg * curve
			if _fov_t <= 0.0:
				_fov_cam.fov = _fov_base
	# Kenar rengi sönümü
	if _rect.visible:
		_edge_t += dt
		_edge_amt = _edge_peak * (1.0 - smoothstep(0.0, 1.0, _edge_t / maxf(_edge_dur, 0.001)))
		_mat.set_shader_parameter("amt", _edge_amt)
		if _edge_t >= _edge_dur:
			_rect.visible = false
			_edge_amt = 0.0
