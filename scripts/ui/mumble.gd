class_name Mumble
extends AudioStreamPlayer
## Animal Crossing tarzı anlamsız mırıltı (GDD §11): gerçek seslendirme yerine
## karakter konuşurken kısa, rastgele perdeli heceler üretir.

const RATE := 22050.0

var _playback: AudioStreamGeneratorPlayback
var _remaining := 0.0       # kalan konuşma süresi (sn)
var _syll_left := 0         # hecede kalan örnek
var _gap_left := 0
var _freq := 200.0
var _base := 200.0
var _phase := 0.0


func _ready() -> void:
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = RATE
	gen.buffer_length = 0.15
	stream = gen
	volume_db = -14.0
	play()
	_playback = get_stream_playback()


## base_hz: karakterin ses perdesi (Hikmet kalın, Tolga orta).
func speak(seconds: float, base_hz: float) -> void:
	_remaining = seconds
	_base = base_hz


func stop_speaking() -> void:
	_remaining = 0.0


func _process(delta: float) -> void:
	if _playback == null:
		return
	_remaining = maxf(0.0, _remaining - delta)
	var frames := _playback.get_frames_available()
	for i in frames:
		var s := 0.0
		if _syll_left > 0:
			_phase = fmod(_phase + _freq / RATE, 1.0)
			# Üçgen dalga + hafif kare: yumuşak ama "konuşur gibi"
			var tri := 4.0 * absf(_phase - 0.5) - 1.0
			var env := minf(1.0, _syll_left / 400.0)
			s = tri * 0.35 * env
			_syll_left -= 1
		elif _gap_left > 0:
			_gap_left -= 1
		elif _remaining > 0.0:
			_syll_left = int(RATE * randf_range(0.05, 0.11))
			_gap_left = int(RATE * randf_range(0.02, 0.06))
			_freq = _base * randf_range(0.85, 1.35)
		_playback.push_frame(Vector2(s, s))
