class_name LipSync
extends RefCounted
## Konuşan karakterin ağzı seslendirmeyle birlikte oynasın: "Voice" veri yolundaki sesin
## anlık şiddeti (konuşma frekansları). Karede bir kez hesaplanır, herkes aynı değeri okur.
## Ses yoksa (satır bitti, oyuncu devam tuşunu bekliyor) 0 döner: ağız kapanır.
## Ses kapalıysa ya da ölçülemiyorsa -1 döner: karakterler eski usul ritmik oynatır.

static var _inst: AudioEffectSpectrumAnalyzerInstance
static var _frame := -1
static var _level := 0.0
static var _raw := -1.0


static func level(dt := 1.0 / 60.0) -> float:
	var f := Engine.get_process_frames()
	if f == _frame:
		return _raw if _raw < 0.0 else _level
	_frame = f
	var bus := AudioServer.get_bus_index("Voice")
	if bus < 0 or AudioServer.is_bus_mute(bus) or AudioServer.get_bus_volume_db(bus) < -50.0 \
			or AudioServer.get_bus_volume_db(0) < -50.0 or GameState.autotest:
		_raw = -1.0
		return -1.0
	if _inst == null:
		var idx := -1
		for i in AudioServer.get_bus_effect_count(bus):
			if AudioServer.get_bus_effect(bus, i) is AudioEffectSpectrumAnalyzer:
				idx = i
		if idx < 0:
			var fx := AudioEffectSpectrumAnalyzer.new()
			fx.buffer_length = 0.1
			fx.fft_size = AudioEffectSpectrumAnalyzer.FFT_SIZE_512
			AudioServer.add_bus_effect(bus, fx)
			idx = AudioServer.get_bus_effect_count(bus) - 1
		_inst = AudioServer.get_bus_effect_instance(bus, idx) as AudioEffectSpectrumAnalyzerInstance
		if _inst == null:
			_raw = -1.0
			return -1.0
	var m := _inst.get_magnitude_for_frequency_range(120.0, 3500.0)
	var db := linear_to_db(maxf((m.x + m.y) * 0.5, 0.00001))
	var target := clampf((db + 58.0) / 40.0, 0.0, 1.0)
	# Hızlı açılır, biraz daha yavaş kapanır: heceler okunur ama titremez
	var k := 1.0 - exp(-clampf(dt, 0.0, 0.1) * (28.0 if target > _level else 14.0))
	_level = lerpf(_level, target, k)
	_raw = 0.0
	return _level


## Ağız açıklığı 0..1 (ölçülemiyorsa t ile ritmik yedek).
static func mouth(t: float, dt: float) -> float:
	var l := level(dt)
	if l < 0.0:
		return absf(sin(t * 14.0))
	return l
