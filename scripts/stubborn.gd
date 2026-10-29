class_name Stubborn
extends Node
## İnatçı oyuncu (v0.99.68): oyunun "olmaz" dediği şeyi üsteleyen oyuncu cezalandırılmaz, fark edilir. Tolga kendi
## inadına laf eder (her eşikte başka söz), ısrar sürerse gizli başarım açılır. Her sahnenin Hud'u bir tane kurar.
##   duvar   bir duvara 3 sn yürümeye devam etmek (2., 4., 6. seferde söz; toplam 10'da ACH_STUBBORN_WALL)
##   zıplama 20 sn içinde 20 zıplama (iki seferde ACH_STUBBORN_JUMP)
##   soru    aynı "yine" repliğini (…_AGAIN) üst üste dinletmek (3. ve 6. seferde söz; 6'da ACH_STUBBORN_TALK)
##   düşüş   bir bölümde 3. ve 6. kez yere düşmek; 4+ kez düşüp savaşı bitiren ACH_STUBBORN_WIN alır (Grade.finish)

## Tolga'nın inat sözleri (konuşmacı çiftleri: tools/voice_map.py seslendirme haritasına buradan alır)
const LINES := [["SPK_TOLGA", "STUB_WALL_1"], ["SPK_TOLGA", "STUB_WALL_2"], ["SPK_TOLGA", "STUB_WALL_3"],
	["SPK_TOLGA", "STUB_JUMP_1"], ["SPK_TOLGA", "STUB_JUMP_2"], ["SPK_TOLGA", "STUB_AGAIN_1"], ["SPK_TOLGA", "STUB_AGAIN_2"],
	["SPK_TOLGA", "STUB_DOWN_1"], ["SPK_TOLGA", "STUB_DOWN_2"]]
const PUSH_S := 3.0
const JUMP_N := 20
const JUMP_WINDOW := 20.0

var hud: Hud
var _push := 0.0
var _pushes := 0
var _jumps: Array[float] = []
var _jump_bursts := 0
var _downs := 0
var _clock := 0.0
var _player: Player


func _init(h: Hud) -> void:
	hud = h
	name = "Stubborn"


func _ready() -> void:
	hud.line_shown.connect(_on_line)


func _speak(key: String) -> void:
	if _player == null or _player.hand_style == "nihat":
		return            # Nihat'ın oynadığı bölümde Tolga'nın sözü olmaz
	hud.bark("SPK_TOLGA", key, 3.5)


func _physics_process(delta: float) -> void:
	_clock += delta
	var sc := get_tree().current_scene
	var p: Player = sc.get("player") as Player if sc else null
	if p != _player:
		if _player and is_instance_valid(_player) and _player.downed.is_connected(_on_down):
			_player.downed.disconnect(_on_down)
		_player = p
		if p:
			p.downed.connect(_on_down)
	if p == null or not p.is_inside_tree() or p.frozen or hud.line_open or get_tree().paused:
		_push = 0.0
		return
	# Duvara yürümek: tuş basılı, oyuncu yerde ve duvara dayalı, ama ilerlemiyor
	var want := Input.get_vector("move_left", "move_right", "move_forward", "move_back").length() > 0.6
	var moving := Vector2(p.get_real_velocity().x, p.get_real_velocity().z).length() > 0.4
	if want and not moving and p.is_on_floor() and p.is_on_wall():
		_push += delta
		if _push >= PUSH_S:
			_push = -999.0          # bu dayanış bir kez sayılır; tuş bırakılınca sıfırlanır
			_pushes += 1
			GameState.bump_stat("wall_push")
			match _pushes:
				2: _speak("STUB_WALL_1")
				4: _speak("STUB_WALL_2")
				6: _speak("STUB_WALL_3")
	elif not want or moving:
		_push = 0.0
	if Input.is_action_just_pressed("jump") and p.is_on_floor():
		_jumps.append(_clock)
		while not _jumps.is_empty() and _clock - _jumps[0] > JUMP_WINDOW:
			_jumps.pop_front()
		if _jumps.size() >= JUMP_N:
			_jumps.clear()
			_jump_bursts += 1
			GameState.bump_stat("jump_burst")
			_speak("STUB_JUMP_1" if _jump_bursts == 1 else "STUB_JUMP_2")


func _on_down() -> void:
	_downs += 1
	if _downs == 3:
		_speak("STUB_DOWN_1")
	elif _downs == 6:
		_speak("STUB_DOWN_2")


## Aynı "yine" repliği: sayaç koşu boyunca tutulur (bölüm değişse de aynı kişiye aynı soru)
func _on_line(key: String) -> void:
	if not "_AGAIN" in key:
		return
	var d: Dictionary = GameState.flags.get("stub_again", {})
	var n := int(d.get(key, 0)) + 1
	d[key] = n
	GameState.flags["stub_again"] = d
	if n == 3:
		_speak("STUB_AGAIN_1")
	elif n == 6:
		GameState.bump_stat("again_6")
		_speak("STUB_AGAIN_2")
