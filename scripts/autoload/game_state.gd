extends Node
## Oyun genelinde kalıcı durum: bayraklar, göstergeler, bölüm sonuçları,
## oyunlar arası meta kayıt (akış şeması için) ve girdi haritası.

const META_PATH := "user://meta.cfg"
const AUTO_PATH := "user://save_auto.dat"
const SLOT_PATH := "user://save_%d.dat"
const SETTINGS_PATH := "user://settings.cfg"
const SLOTS := 3
## Oynanabilir en yeni bölüm (gizli Yaratıcı Menüsü ve --chapter=N buna kadar gider).
const LATEST_CHAPTER := 15

## Test ve ekran görüntüsü modları komut satırından açılır:
##   godot --path . -- --autotest
##   godot --path . -- --shots=/klasör/yolu
var autotest := false
var autotest_variant := ""       # "" = normal yol, "red" = kırmızı düğme, "kick" = Tolga tekme atar
var shots_dir := ""
var start_chapter := 1
var start_scene := ""             # --chapter=10b gibi dal bölümleri için sahne yolu

## Bölüm başındaki durumun kopyası: bölüm yeniden oynanırsa buna dönülür.
var _snapshots: Dictionary = {}

var flags: Dictionary = {}
var telsiz_bag := 2
var paradox := 0
var bag: Array[String] = []
var chapter_outcomes: Dictionary = {}
var seen_outcomes: Dictionary = {}
var locale := "tr"

## Kayıt: bölüm başları (snapshot) dosyaya yazılır. Oynama süresi ve ayarlar.
var current_chapter := 1
var play_time := 0.0
var skip_title := false          # "Bölümün başına dön" Bölüm 1'de başlık ekranını atlar
var last_final := ""             # ana menüde Hikmet'in yorumu için
var quests_ever: Dictionary = {}  # yan görev id -> true (herhangi bir oyunda tamamlandı)
var achievements: Dictionary = {} # başarım id -> true
var stats: Dictionary = {}        # kalıcı sayaçlar (fes, selfie, foto, geri sarma, rekorlar...)
var finals_seen: Dictionary = {}  # görülen final id -> true
## Vaka Dosyası'ndan bir finale gitmek için geri dönüldü: {"final": id, "step": "Bölüm 9 · ..."}; bölüm başında
## hatırlatılır, o final (ya da başka biri) görülünce silinir. Oyun sıfırlanınca da kalır (geri dönüş sıfırlar).
var review_goal: Dictionary = {}
var settings := {"music": 0.8, "sfx": 0.9, "voice": 1.0, "mouse": 1.0, "fullscreen": false,
	# Görüntü: quality 0 düşük (gölge yok, kontur yok, %70 çözünürlük, az kalabalık) · 1 orta · 2 yüksek
	"quality": 2, "fov": 72.0, "vsync": true, "fps": false, "subs": 1.0, "markers": true,
	# Kontrol: ters dikey eksen, kol hassasiyeti, yeniden atanmış tuşlar (eylem -> fiziksel tuş kodu)
	"invert_y": false, "pad_sens": 1.0, "keys": {}}
signal settings_changed
## Tuşları yeniden atanabilen eylemler (ayarlar sayfasındaki sırayla).
const REBINDABLE := ["move_forward", "move_back", "move_left", "move_right", "jump", "sprint", "interact", "use_item",
	"bag", "fez", "red_button", "outfit", "dive", "kick", "photo_mode", "fps_toggle"]
var _default_keys := {}


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--autotest"):
			autotest = true
			if "=" in arg:
				autotest_variant = arg.split("=")[1]
		elif arg.begins_with("--chapter="):
			var v := arg.trim_prefix("--chapter=")
			start_chapter = int(v)
			if not v.is_valid_int():
				start_scene = "res://scenes/chapter%s.tscn" % v
		elif arg.begins_with("--shots="):
			shots_dir = arg.trim_prefix("--shots=")
		elif arg.begins_with("--outcome="):
			# Test/görüntü için önceki bölüm sonucu: --outcome=2:2.3
			var kv := arg.trim_prefix("--outcome=").split(":")
			if kv.size() == 2:
				chapter_outcomes[int(kv[0])] = kv[1]
	_setup_inputs()
	_load_meta()
	TranslationServer.set_locale(locale)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buses()
	_load_settings()
	if not autotest and shots_dir == "":
		SteamBridge.init()


func _process(delta: float) -> void:
	SteamBridge.tick()
	if not get_tree().paused:
		play_time += delta


func reset_run() -> void:
	_snapshots.clear()
	current_chapter = 1
	play_time = 0.0
	flags.clear()
	telsiz_bag = 2
	paradox = 0
	bag.clear()
	chapter_outcomes.clear()


## Bölüme doğrudan başlanıyorsa (test, geliştirme) önceki bölümlerin makul sonuçlarını kurar.
func ensure_defaults_for(chapter: int) -> void:
	if chapter >= 2 and bag.is_empty():
		bag = ["phone", "tape", "chickpeas", "cube", "cologne"] as Array[String]
		flags["fez"] = true
		chapter_outcomes[1] = "1.1"
	if chapter >= 3 and not chapter_outcomes.has(2):
		chapter_outcomes[2] = "2.1"
		telsiz_bag = maxi(telsiz_bag, 3)
	if chapter >= 4 and not chapter_outcomes.has(3):
		chapter_outcomes[3] = "3.3"
		flags["sadakat"] = 55
		flags["machine"] = "free"
		flags["nihat_card"] = true
	if chapter >= 5 and not chapter_outcomes.has(4):
		chapter_outcomes[4] = "4a.1"
	if chapter >= 6 and not chapter_outcomes.has(5):
		chapter_outcomes[5] = "5.1"
	if chapter >= 7 and not chapter_outcomes.has(6):
		chapter_outcomes[6] = "6a.1"
		flags["route"] = "A"
	if chapter >= 8 and not chapter_outcomes.has(7):
		chapter_outcomes[7] = "7.1"
	if chapter >= 9 and not chapter_outcomes.has(8):
		chapter_outcomes[8] = "8.1"
	if chapter >= 10 and not chapter_outcomes.has(9):
		chapter_outcomes[9] = "9.6"
	if chapter >= 11 and not chapter_outcomes.has(10):
		chapter_outcomes[10] = "10O.1"
	if chapter >= 12 and not chapter_outcomes.has(11):
		chapter_outcomes[11] = "11.2"
	if chapter >= 13 and not chapter_outcomes.has(12):
		chapter_outcomes[12] = "12.1"
	if chapter >= 14 and not chapter_outcomes.has(13):
		chapter_outcomes[13] = "13.1"
		flags["tolga_fate"] = "T1"
	if chapter >= 15 and not chapter_outcomes.has(14):
		chapter_outcomes[14] = "14.1"
		flags["nihat_fate"] = "N1"


func snapshot(chapter: int) -> void:
	current_chapter = chapter
	if _snapshots.has(chapter):
		# Yeniden oynanıyor (ya da kayıttan/bölüm listesinden dönüldü): bölüm başındaki duruma dön
		var snap: Dictionary = _snapshots[chapter]
		flags = snap["flags"].duplicate(true)
		telsiz_bag = snap["telsiz_bag"]
		paradox = snap["paradox"]
		bag.assign(snap["bag"])
		if snap.has("outcomes"):
			chapter_outcomes = (snap["outcomes"] as Dictionary).duplicate()
		# Sonraki bölümlerin eski başlangıçları geçersiz: yeniden oynandıkça yeniden yazılır
		for k in _snapshots.keys():
			if int(k) > chapter:
				_snapshots.erase(k)
	else:
		_snapshots[chapter] = {"flags": flags.duplicate(true), "telsiz_bag": telsiz_bag, "paradox": paradox,
			"bag": bag.duplicate(), "outcomes": chapter_outcomes.duplicate(), "scene": ""}
	_autosave.call_deferred(chapter)


# ---------------------------------------------------------------- kayıt

func _saving_disabled() -> bool:
	return autotest or shots_dir != ""


func _autosave(chapter: int) -> void:
	var scene := get_tree().current_scene
	if scene != null and _snapshots.has(chapter):
		_snapshots[chapter]["scene"] = scene.scene_file_path
	if not _saving_disabled():
		_write(AUTO_PATH, run_data())


## Bu oyunun kaydı: bütün bölüm başları, şimdiki bölüm, süre ve tarih.
func run_data() -> Dictionary:
	return {"version": 1, "chapter": current_chapter, "snapshots": _snapshots.duplicate(true),
		"play_time": play_time, "date": Time.get_datetime_string_from_system(false, true)}


func _write(path: String, data: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(var_to_str(data))


func read_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var v: Variant = str_to_var(FileAccess.get_file_as_string(path))
	if v is Dictionary and (v as Dictionary).has("snapshots"):
		return v
	return {}


func read_auto() -> Dictionary:
	return read_save(AUTO_PATH)


func read_slot(i: int) -> Dictionary:
	return read_save(SLOT_PATH % i)


func save_slot(i: int) -> void:
	if not _saving_disabled():
		_write(SLOT_PATH % i, run_data())


## Kayıttan bir bölümün başına döner (chapter = -1: kayıttaki son bölüm).
func load_run(data: Dictionary, chapter := -1) -> void:
	var snaps: Dictionary = data["snapshots"]
	if chapter < 0:
		chapter = int(data["chapter"])
	elif chapter < int(data.get("chapter", 0)):
		stats["rewinds"] = int(stats.get("rewinds", 0)) + 1
	reset_run()
	for k in snaps.keys():
		if int(k) <= chapter:
			_snapshots[int(k)] = (snaps[k] as Dictionary).duplicate(true)
	play_time = float(data.get("play_time", 0.0))
	current_chapter = chapter
	if chapter <= 1 or not _snapshots.has(chapter):
		skip_title = true
		get_tree().change_scene_to_file("res://scenes/chapter1.tscn")
		return
	var path: String = _snapshots[chapter].get("scene", "")
	if path == "":
		path = "res://scenes/chapter%d.tscn" % chapter
	get_tree().change_scene_to_file(path)


## Bu oyunun içinden bir bölümün başına dön (duraklatma menüsü).
func rewind_to(chapter: int) -> void:
	load_run(run_data(), chapter)


func reached_chapters(data: Dictionary) -> Array[int]:
	var out: Array[int] = [1]
	if data.is_empty():
		return out
	for k in (data["snapshots"] as Dictionary).keys():
		if int(k) > 1:
			out.append(int(k))
	out.sort()
	return out


# ---------------------------------------------------------------- ayarlar

func _setup_buses() -> void:
	for b in ["Music", "SFX", "Voice"]:
		if AudioServer.get_bus_index(b) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, b)
			AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if not _saving_disabled() and cfg.load(SETTINGS_PATH) == OK:
		for k in settings.keys():
			settings[k] = cfg.get_value("settings", k, settings[k])
	apply_settings.call_deferred()


func set_setting(key: String, value: Variant) -> void:
	settings[key] = value
	apply_settings()
	if _saving_disabled():
		return
	var cfg := ConfigFile.new()
	for k in settings.keys():
		cfg.set_value("settings", k, settings[k])
	cfg.save(SETTINGS_PATH)


## Yeniden atanmış tuşlar: eylemin ilk klavye tuşu değiştirilir (ok tuşları, kol ve fare atamaları kalır).
func _apply_keys() -> void:
	for action in REBINDABLE:
		if not InputMap.has_action(action):
			continue
		var first: InputEventKey = null
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				first = ev
				break
		if not _default_keys.has(action):
			_default_keys[action] = first.physical_keycode if first else 0
		var want: int = int((settings["keys"] as Dictionary).get(action, _default_keys[action]))
		if first and first.physical_keycode != want and want != 0:
			first.physical_keycode = want
		elif first == null and want != 0:
			var e := InputEventKey.new()
			e.physical_keycode = want
			InputMap.action_add_event(action, e)


func key_name(action: String) -> String:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return OS.get_keycode_string((ev as InputEventKey).physical_keycode)
	return "—"


func rebind(action: String, keycode: int) -> void:
	var k: Dictionary = settings["keys"]
	k[action] = keycode
	set_setting("keys", k)


func reset_keys() -> void:
	set_setting("keys", {})


## Grafik kalitesi: gölgeler ve 3B çözünürlük hemen, kontur ve kalabalık bir sonraki sahnede.
func _apply_quality() -> void:
	var q := int(settings["quality"])
	var outline := q >= 1
	if Props.outlines != outline:
		Props.outlines = outline
		Props._materials.clear()
		Dressing._mat = null
	var root := get_tree().root
	root.scaling_3d_scale = [0.7, 0.85, 1.0][clampi(q, 0, 2)]
	for n in root.find_children("*", "DirectionalLight3D", true, false):
		_light_quality(n as DirectionalLight3D)
	for n in root.find_children("*", "WorldEnvironment", true, false):
		_env_quality(n as WorldEnvironment)
	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)


func _on_node_added(n: Node) -> void:
	if n is DirectionalLight3D:
		_light_quality.call_deferred(n)
	elif n is WorldEnvironment:
		_env_quality.call_deferred(n)


## Ortak görünüm (Look): ton eşleme, ortam kapanması, pus, renk düzeltmesi
func _env_quality(w: WorldEnvironment) -> void:
	if is_instance_valid(w):
		Look.apply_env(w, int(settings["quality"]))


func _light_quality(l: DirectionalLight3D) -> void:
	if not is_instance_valid(l):
		return
	var q := int(settings["quality"])
	if not l.has_meta("q_shadow"):
		l.set_meta("q_shadow", l.shadow_enabled)
		l.set_meta("q_dist", l.directional_shadow_max_distance)
	l.shadow_enabled = bool(l.get_meta("q_shadow")) and q >= 1
	l.directional_shadow_max_distance = minf(float(l.get_meta("q_dist")), 45.0) if q == 1 else float(l.get_meta("q_dist"))
	Look.apply_sun(l, q)


## Kalabalık çarpanı (yürüyen halk sayısı): düşük %30, orta %70, yüksek %100.
func crowd() -> float:
	return [0.3, 0.7, 1.0][clampi(int(settings["quality"]), 0, 2)]


func apply_settings() -> void:
	for pair in [["Music", "music"], ["SFX", "sfx"], ["Voice", "voice"]]:
		var idx := AudioServer.get_bus_index(pair[0])
		var v: float = settings[pair[1]]
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(v, 0.0001)))
		AudioServer.set_bus_mute(idx, v <= 0.001)
	if DisplayServer.get_name() != "headless":
		var fs: bool = settings["fullscreen"]
		var want := DisplayServer.WINDOW_MODE_FULLSCREEN if fs else DisplayServer.WINDOW_MODE_WINDOWED
		if DisplayServer.window_get_mode() != want and (fs or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(want)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if bool(settings["vsync"]) else DisplayServer.VSYNC_DISABLED)
	if is_inside_tree():
		_apply_quality()
	_apply_keys()
	FpsOverlay.show_overlay(self, bool(settings["fps"]))
	settings_changed.emit()


func set_outcome(chapter: int, outcome_id: String) -> void:
	chapter_outcomes[chapter] = outcome_id
	seen_outcomes[outcome_id] = true
	_save_meta()


func has_seen(outcome_id: String) -> bool:
	return seen_outcomes.has(outcome_id)


func toggle_locale() -> void:
	locale = "en" if locale == "tr" else "tr"
	stats["lang_switch"] = int(stats.get("lang_switch", 0)) + 1
	TranslationServer.set_locale(locale)
	_save_meta()


func _load_meta() -> void:
	if autotest or shots_dir != "":
		return
	var cfg := ConfigFile.new()
	if cfg.load(META_PATH) == OK:
		seen_outcomes = cfg.get_value("meta", "seen", {})
		locale = cfg.get_value("meta", "locale", "tr")
		last_final = cfg.get_value("meta", "last_final", "")
		quests_ever = cfg.get_value("meta", "quests", {})
		achievements = cfg.get_value("meta", "achievements", {})
		stats = cfg.get_value("meta", "stats", {})
		finals_seen = cfg.get_value("meta", "finals", {})


func _save_meta() -> void:
	if autotest or shots_dir != "":
		return
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "seen", seen_outcomes)
	cfg.set_value("meta", "locale", locale)
	cfg.set_value("meta", "last_final", last_final)
	cfg.set_value("meta", "quests", quests_ever)
	cfg.set_value("meta", "achievements", achievements)
	cfg.set_value("meta", "stats", stats)
	cfg.set_value("meta", "finals", finals_seen)
	cfg.save(META_PATH)


func _setup_inputs() -> void:
	# Klavye/fare ve kol (Xbox düzeni; PlayStation'da aynı yerlerdeki düğmeler):
	# sol çubuk yürü · sağ çubuk bak · A zıpla/ilerlet · X etkileşim · Y çanta · B kırmızı düğme (basılı tut)
	# LB/RB eşya değiştir · RT eşyayı kullan/tekme · LT dal · L3 koş · R3 kendine bak · Select fes · Start duraklat
	# D-pad ← ↑ → ↓ seçim 1-4 · LB/RB seçim 5-6 (mangala)
	_bind("move_forward", [KEY_W, KEY_UP], [], [], [[JOY_AXIS_LEFT_Y, -1.0]])
	_bind("move_back", [KEY_S, KEY_DOWN], [], [], [[JOY_AXIS_LEFT_Y, 1.0]])
	_bind("move_left", [KEY_A, KEY_LEFT], [], [], [[JOY_AXIS_LEFT_X, -1.0]])
	_bind("move_right", [KEY_D, KEY_RIGHT], [], [], [[JOY_AXIS_LEFT_X, 1.0]])
	_bind("look_left", [], [], [], [[JOY_AXIS_RIGHT_X, -1.0]])
	_bind("look_right", [], [], [], [[JOY_AXIS_RIGHT_X, 1.0]])
	_bind("look_up", [], [], [], [[JOY_AXIS_RIGHT_Y, -1.0]])
	_bind("look_down", [], [], [], [[JOY_AXIS_RIGHT_Y, 1.0]])
	_bind("jump", [KEY_SPACE], [], [JOY_BUTTON_A])
	_bind("sprint", [KEY_SHIFT], [], [JOY_BUTTON_LEFT_STICK])
	_bind("interact", [KEY_E], [], [JOY_BUTTON_X])
	_bind("advance", [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER], [MOUSE_BUTTON_LEFT], [JOY_BUTTON_A, JOY_BUTTON_X])
	_bind("fez", [KEY_H], [], [JOY_BUTTON_BACK])
	_bind("bag", [KEY_TAB], [], [JOY_BUTTON_Y])
	_bind("red_button", [KEY_R], [], [JOY_BUTTON_B])
	_bind("dive", [KEY_CTRL, KEY_C], [], [], [[JOY_AXIS_TRIGGER_LEFT, 1.0]])
	_bind("kick", [KEY_F], [MOUSE_BUTTON_LEFT], [], [[JOY_AXIS_TRIGGER_RIGHT, 1.0]])
	_bind("continue", [KEY_ENTER, KEY_KP_ENTER], [], [JOY_BUTTON_A, JOY_BUTTON_START])
	_bind("pause", [KEY_ESCAPE], [], [JOY_BUTTON_START])
	_bind("language", [KEY_L])
	_bind("outfit", [KEY_V], [], [JOY_BUTTON_RIGHT_STICK])
	_bind("photo_mode", [KEY_F2])
	_bind("use_item", [KEY_G], [MOUSE_BUTTON_RIGHT], [], [[JOY_AXIS_TRIGGER_RIGHT, 1.0]])
	_bind("item_next", [], [MOUSE_BUTTON_WHEEL_DOWN], [JOY_BUTTON_RIGHT_SHOULDER])
	_bind("item_prev", [], [MOUSE_BUTTON_WHEEL_UP], [JOY_BUTTON_LEFT_SHOULDER])
	_bind("quit", [KEY_Q])
	_bind("fps_toggle", [KEY_F3])
	var pad_choice := [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN,
		JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER]
	for i in range(1, 10):
		_bind("choice_%d" % i, [KEY_0 + i, KEY_KP_0 + i], [], [pad_choice[i - 1]] if i <= 6 else [])


func _bind(action: String, keys: Array, mouse_buttons: Array = [], joy_buttons: Array = [], joy_axes: Array = []) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action, 0.35)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
	for b in mouse_buttons:
		var mb := InputEventMouseButton.new()
		mb.button_index = b
		InputMap.action_add_event(action, mb)
	for j in joy_buttons:
		var jb := InputEventJoypadButton.new()
		jb.button_index = j
		InputMap.action_add_event(action, jb)
	for ax in joy_axes:
		var jm := InputEventJoypadMotion.new()
		jm.axis = ax[0]
		jm.axis_value = ax[1]
		InputMap.action_add_event(action, jm)


## Son kullanılan giriş aygıtı kol mu? (Ekrandaki tuş ipuçları buna göre değişir.)
var pad := false
signal pad_changed(on: bool)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fps_toggle"):
		set_setting("fps", not bool(settings["fps"]))
	var now := pad
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.5):
		now = true
	elif event is InputEventKey or event is InputEventMouseButton or (event is InputEventMouseMotion and (event as InputEventMouseMotion).relative.length() > 4.0):
		now = false
	if now != pad:
		pad = now
		pad_changed.emit(pad)


## Ekranda gösterilecek tuş adı: kol kullanılıyorsa kol düğmesi.
const PAD_GLYPH := {"1": "◀", "2": "▲", "3": "▶", "4": "▼", "5": "LB", "6": "RB", "E": "X", "UI_KEY_SPACE": "A",
	"Shift": "L3", "WASD": "L", "1–6": "◀▲▶▼ LB RB", "Tab": "Y", "H": "Select", "R": "B", "G": "RT", "V": "R3", "Esc": "Start", "CTRL": "LT"}


func key_hint(k: String) -> String:
	return PAD_GLYPH.get(k, k) if pad else k


func mark_quest_ever(id: String) -> void:
	if not quests_ever.has(id):
		quests_ever[id] = true
		_save_meta()


## Kalıcı sayaç (başarımlar için). max_mode: değeri artırmak yerine en yükseği tutar (rekor).
func bump_stat(key: String, n := 1, max_mode := false) -> void:
	var v := int(stats.get(key, 0))
	stats[key] = maxi(v, n) if max_mode else v + n
	_save_meta()


func unlock_achievement(id: String) -> bool:
	if achievements.has(id):
		return false
	achievements[id] = true
	_save_meta()
	SteamBridge.unlock(id)
	return true


func set_last_final(id: String) -> void:
	last_final = id
	review_goal = {}
	if id != "":
		finals_seen[id] = true
	_save_meta()
