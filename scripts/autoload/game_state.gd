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
var settings := {"music": 0.8, "sfx": 0.9, "voice": 1.0, "mouse": 1.0, "fullscreen": false}


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


func _process(delta: float) -> void:
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
	apply_settings()


func set_setting(key: String, value: Variant) -> void:
	settings[key] = value
	apply_settings()
	if _saving_disabled():
		return
	var cfg := ConfigFile.new()
	for k in settings.keys():
		cfg.set_value("settings", k, settings[k])
	cfg.save(SETTINGS_PATH)


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
	_bind("move_forward", [KEY_W, KEY_UP])
	_bind("move_back", [KEY_S, KEY_DOWN])
	_bind("move_left", [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("jump", [KEY_SPACE])
	_bind("sprint", [KEY_SHIFT])
	_bind("interact", [KEY_E])
	_bind("advance", [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER], [MOUSE_BUTTON_LEFT])
	_bind("fez", [KEY_H])
	_bind("bag", [KEY_TAB])
	_bind("red_button", [KEY_R])
	_bind("dive", [KEY_CTRL, KEY_C])
	_bind("kick", [KEY_F], [MOUSE_BUTTON_LEFT])
	_bind("continue", [KEY_ENTER, KEY_KP_ENTER])
	_bind("pause", [KEY_ESCAPE])
	_bind("language", [KEY_L])
	_bind("outfit", [KEY_V])
	_bind("use_item", [KEY_G], [MOUSE_BUTTON_RIGHT])
	_bind("item_next", [], [MOUSE_BUTTON_WHEEL_DOWN])
	_bind("item_prev", [], [MOUSE_BUTTON_WHEEL_UP])
	_bind("quit", [KEY_Q])
	for i in range(1, 10):
		_bind("choice_%d" % i, [KEY_0 + i, KEY_KP_0 + i])


func _bind(action: String, keys: Array, mouse_buttons: Array = []) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
	for b in mouse_buttons:
		var mb := InputEventMouseButton.new()
		mb.button_index = b
		InputMap.action_add_event(action, mb)


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
	return true


func set_last_final(id: String) -> void:
	last_final = id
	if id != "":
		finals_seen[id] = true
	_save_meta()
