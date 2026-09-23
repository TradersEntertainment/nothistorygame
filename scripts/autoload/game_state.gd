extends Node
## Oyun genelinde kalıcı durum: bayraklar, göstergeler, bölüm sonuçları,
## oyunlar arası meta kayıt (akış şeması için) ve girdi haritası.

const META_PATH := "user://meta.cfg"
## Oynanabilir en yeni bölüm (gizli Yaratıcı Menüsü ve --chapter=N buna kadar gider).
const LATEST_CHAPTER := 3

## Test ve ekran görüntüsü modları komut satırından açılır:
##   godot --path . -- --autotest
##   godot --path . -- --shots=/klasör/yolu
var autotest := false
var autotest_variant := ""       # "" = normal yol, "red" = kırmızı düğme, "kick" = Tolga tekme atar
var shots_dir := ""
var start_chapter := 1

## Bölüm başındaki durumun kopyası: bölüm yeniden oynanırsa buna dönülür.
var _snapshots: Dictionary = {}

var flags: Dictionary = {}
var telsiz_bag := 2
var paradox := 0
var bag: Array[String] = []
var chapter_outcomes: Dictionary = {}
var seen_outcomes: Dictionary = {}
var locale := "tr"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--autotest"):
			autotest = true
			if "=" in arg:
				autotest_variant = arg.split("=")[1]
		elif arg.begins_with("--chapter="):
			start_chapter = int(arg.trim_prefix("--chapter="))
		elif arg.begins_with("--shots="):
			shots_dir = arg.trim_prefix("--shots=")
	_setup_inputs()
	_load_meta()
	TranslationServer.set_locale(locale)


func reset_run() -> void:
	_snapshots.clear()
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


func snapshot(chapter: int) -> void:
	if _snapshots.has(chapter):
		# Yeniden oynanıyor: bölüm başındaki duruma dön
		var snap: Dictionary = _snapshots[chapter]
		flags = snap["flags"].duplicate(true)
		telsiz_bag = snap["telsiz_bag"]
		paradox = snap["paradox"]
		bag = snap["bag"].duplicate()
		return
	_snapshots[chapter] = {"flags": flags.duplicate(true), "telsiz_bag": telsiz_bag, "paradox": paradox, "bag": bag.duplicate()}


func set_outcome(chapter: int, outcome_id: String) -> void:
	chapter_outcomes[chapter] = outcome_id
	seen_outcomes[outcome_id] = true
	_save_meta()


func has_seen(outcome_id: String) -> bool:
	return seen_outcomes.has(outcome_id)


func toggle_locale() -> void:
	locale = "en" if locale == "tr" else "tr"
	TranslationServer.set_locale(locale)
	_save_meta()


func _load_meta() -> void:
	if autotest or shots_dir != "":
		return
	var cfg := ConfigFile.new()
	if cfg.load(META_PATH) == OK:
		seen_outcomes = cfg.get_value("meta", "seen", {})
		locale = cfg.get_value("meta", "locale", "tr")


func _save_meta() -> void:
	if autotest or shots_dir != "":
		return
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "seen", seen_outcomes)
	cfg.set_value("meta", "locale", locale)
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
	_bind("quit", [KEY_Q])
	for i in range(1, 6):
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
