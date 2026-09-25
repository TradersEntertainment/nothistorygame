class_name Look
extends RefCounted
## Ortak görünüm: sahneler kendi ortamını (WorldEnvironment) ve güneşini kurar, Look üstüne ortak bir "görüntü
## yönetmenliği" uygular: AgX ton eşleme, ortam kapanması (SSAO), dolaylı ışık (SSIL), yumuşak gölge, ufuk pusu,
## sahneye göre renk düzeltmesi (gölgeler serin, ışıklar sıcak). GameState, sahneye eklenen her WorldEnvironment ve
## DirectionalLight3D için bunu kendiliğinden çağırır; kalite ayarı (0 düşük, 1 orta, 2 yüksek) maliyeti belirler.
## Compatibility (OpenGL) yedek çiziciye düşülürse desteklenmeyen ayarlar sessizce etkisiz kalır.

## Mod: sahne sınıfından; Night.environment kendi ortamını "night" diye işaretler.
const MOOD_OF := {"CampDay": "ottoman", "Slipway": "ottoman", "ByzCity": "byzantine", "Galata": "genoese",
	"Camp": "night", "SeaWalls": "night", "Garage": "indoor", "HardwareStore": "indoor", "Bureau": "office",
	"OtagHall": "otag", "Monday": "modern"}

# mod: [pozlama, doygunluk, kontrast, sis rengi, sis yoğunluğu çarpanı, gölge tonu, ışık tonu, ortam ışığı çarpanı]
const MOODS := {
	"ottoman": [1.0, 1.12, 1.08, Color("d8d4c4"), 1.0, Color("3c4a6e"), Color("fff0d6"), 0.8],
	"byzantine": [0.98, 1.06, 1.08, Color("cfd3d8"), 1.0, Color("40405e"), Color("ffe8d0"), 0.8],
	"genoese": [1.0, 1.1, 1.06, Color("d6dcd8"), 1.0, Color("34506a"), Color("fff0dc"), 0.8],
	"night": [1.15, 1.0, 1.08, Color("1a2240"), 1.0, Color("141e40"), Color("ffe0b8"), 1.0],
	"indoor": [1.05, 1.02, 1.08, Color("10131c"), 1.0, Color("1e2638"), Color("ffe6c8"), 1.0],
	"office": [1.0, 0.96, 1.05, Color("2a3029"), 1.0, Color("2a3432"), Color("f4f0dc"), 1.0],
	"otag": [1.08, 1.05, 1.1, Color("1a0c08"), 1.0, Color("2a1410"), Color("ffe0b0"), 1.0],
	"modern": [0.98, 1.0, 1.06, Color("d0d8e0"), 1.0, Color("34405a"), Color("fff0e0"), 0.85],
}


static func mood(n: Node) -> String:
	if n.has_meta("look"):
		return str(n.get_meta("look"))
	var p := n.get_parent()
	while p:
		var sc: Script = p.get_script()
		if sc and MOOD_OF.has(sc.get_global_name()):
			return MOOD_OF[sc.get_global_name()]
		p = p.get_parent()
	return ""


static func apply_env(we: WorldEnvironment, q: int) -> void:
	var e := we.environment
	if e == null:
		return
	var m := mood(we)
	if m == "" and e.background_mode == Environment.BG_SKY:
		m = "ottoman"
	elif m == "":
		m = "indoor"
	var cfg: Array = MOODS[m]
	var outdoor := e.background_mode == Environment.BG_SKY and m != "night"
	# İlk değerleri sakla: kalite değişince baştan hesaplansın
	if not e.has_meta("look_base"):
		e.set_meta("look_base", {"exposure": e.tonemap_exposure, "ambient": e.ambient_light_energy,
			"fog": e.fog_density, "glow": e.glow_intensity, "fog_enabled": e.fog_enabled})
	var base: Dictionary = e.get_meta("look_base")

	# Ton eşleme: sahnenin kendi Filmic ayarı korunur (bütün renkler Compatibility çizicisine göre seçildi);
	# pozlama ve ortam ışığı moda göre hafifçe ayarlanır
	e.tonemap_exposure = float(base["exposure"]) * float(cfg[0])
	e.ambient_light_energy = float(base["ambient"]) * float(cfg[7])

	# Ortam kapanması: nesnelerin dibine, köşelere, çatı altına yumuşak gölge (orta ve yüksek)
	e.ssao_enabled = q >= 1
	e.ssao_radius = 1.3 if outdoor else 0.8
	e.ssao_intensity = 2.2 if outdoor else 1.8
	e.ssao_power = 1.6
	e.ssao_detail = 0.6
	e.ssao_horizon = 0.06
	e.ssao_sharpness = 0.98
	e.ssao_light_affect = 0.15
	e.ssao_ao_channel_affect = 0.0
	# Dolaylı ışık: güneşin zeminden yansıyıp gölgedeki yüzleri hafifçe renklendirmesi (yalnız yüksek)
	e.ssil_enabled = q >= 2
	e.ssil_radius = 4.0 if outdoor else 2.5
	e.ssil_intensity = 0.9
	e.ssil_sharpness = 0.98
	e.ssil_normal_rejection = 1.0

	# Parıltı: yalnız gerçekten parlak şeyler (alev, fener, güneş) ışısın
	e.glow_enabled = true
	e.glow_intensity = maxf(float(base["glow"]), 0.3)
	e.glow_hdr_threshold = 0.95
	e.glow_bloom = 0.03
	e.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	e.set_glow_level(0, 0.0)
	e.set_glow_level(1, 0.6)
	e.set_glow_level(2, 1.0)
	e.set_glow_level(3, 0.5)

	# Pus: uzak şeyler açılıp gökyüzüne karışsın (hava perspektifi); ufuk çizgisi yumuşasın
	if outdoor or m == "night":
		e.fog_enabled = true
		e.fog_light_color = cfg[3]
		e.fog_density = maxf(float(base["fog"]), 0.002 if outdoor else 0.008) * float(cfg[4]) * (0.6 if outdoor else 1.0)
		e.fog_aerial_perspective = 0.3 if outdoor else 0.2
		e.fog_sky_affect = 0.15 if outdoor else 0.0
		e.fog_height = -1.0
		e.fog_height_density = 0.0
	if outdoor and e.sky and e.sky.sky_material is ProceduralSkyMaterial:
		var sm := e.sky.sky_material as ProceduralSkyMaterial
		if not sm.has_meta("look_done"):
			sm.set_meta("look_done", true)
			# Gök tepesi biraz daha derin, ufuk puslu ve açık: sahneyi bir çerçeve gibi sarar
			sm.sky_top_color = sm.sky_top_color.lerp(Color("3a78c8"), 0.3)
			sm.sky_horizon_color = sm.sky_horizon_color.lerp(cfg[3], 0.35).lightened(0.1)
			sm.ground_horizon_color = sm.sky_horizon_color
			sm.sky_curve = 0.12
			sm.ground_curve = 0.05
			sm.sun_angle_max = 20.0

	# Renk düzeltmesi: gölgeler serin, ışıklar sıcak (iki tonlu), sahnenin kendi paleti
	e.adjustment_enabled = true
	e.adjustment_saturation = float(cfg[1])
	e.adjustment_contrast = float(cfg[2])
	e.adjustment_brightness = 1.0
	e.adjustment_color_correction = _grade(cfg[5], cfg[6])


## Kanal eğrileri: koyu uçta gölge tonuna, açık uçta ışık tonuna doğru hafif kayma (Compatibility'de de çalışır).
static func _grade(shadow: Color, light: Color) -> GradientTexture1D:
	var g := Gradient.new()
	var dark := Color(0, 0, 0).lerp(shadow, 0.1)
	g.set_color(0, dark)
	g.set_color(1, Color(1, 1, 1).lerp(light, 0.2))
	g.add_point(0.5, Color(0.5, 0.5, 0.5).lerp(light.lerp(shadow, 0.5), 0.06))
	var t := GradientTexture1D.new()
	t.gradient = g
	t.width = 256
	return t


static func apply_sun(l: DirectionalLight3D, q: int) -> void:
	if l.has_meta("sky_body_only"):
		return
	# Yumuşak gölge kenarı ve bölmeler arası geçiş
	l.shadow_blur = 1.4 if q >= 1 else 1.0
	l.directional_shadow_blend_splits = q >= 2
	l.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS if q >= 2 else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	l.shadow_bias = 0.04
	l.shadow_normal_bias = 1.2
	l.light_angular_distance = 0.6 if q >= 2 else 0.0
	l.shadow_opacity = 0.92
