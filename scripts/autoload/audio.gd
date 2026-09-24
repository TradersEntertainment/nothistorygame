extends Node
## Müzik ve ses efektleri. Müzik sahneye göre kendiliğinden seçilir (bölüm → parça),
## sahneler istediğinde music()/sfx() ile değiştirir. Dosya yoksa sessizce geçer.

const MUSIC_DIR := "res://assets/audio/music/"
const SFX_DIR := "res://assets/audio/sfx/"
const CHAPTER_MUSIC := {"main": "theme", "chapter1": "garage", "chapter2": "chase", "chapter3": "bureau",
	"chapter4": "stealth", "chapter5": "tension", "chapter6": "camp_day", "chapter7": "bureau",
	"chapter8": "tension", "chapter9": "camp_day", "chapter10": "camp_day", "chapter10b": "foundry", "chapter10h": "byzantium", "chapter10z": "kitchen", "chapter10g": "galata", "chapter10a": "byzantium", "chapter16": "chicken", "chapter10l": "tunnel", "chapter12b": "byzantium_evening", "chapter11": "confrontation",
	"chapter12": "audience", "chapter13": "garage", "chapter14": "bureau", "chapter15": "theme"}
## ElevenLabs ile üretilen yeni parçalar henüz yoksa eskisine düşülür (tools/music_gen.py)
const MUSIC_FALLBACK := {"stealth": "camp_night", "tension": "garage", "confrontation": "camp_night", "audience": "tender",
	"countdown": "chase", "walls_night": "camp_night", "tunnel": "camp_night", "foundry": "camp_day", "chicken": "chase"}
const CHAPTER_AMBIENCE := {"chapter1": "fluorescent", "chapter3": "fluorescent", "chapter4": "night_camp",
	"chapter5": "city_2026", "chapter6": "crowd_camp", "chapter7": "fluorescent", "chapter8": "fluorescent",
	"chapter9": "crowd_camp", "chapter10": "crowd_camp", "chapter10b": "crowd_camp", "chapter10z": "crowd_camp", "chapter10g": "crowd_camp", "chapter11": "night_camp", "chapter13": "fluorescent",
	"chapter14": "fluorescent", "chapter15": "city_2026"}
## Ayak sesi zemini: ordugâh çimen, Büro ve kançılarya ahşap, gerisi taş
const CHAPTER_STEPS := {"chapter4": "grass", "chapter6": "grass", "chapter7": "grass", "chapter9": "grass", "chapter10": "grass", "chapter10b": "grass", "chapter10z": "grass", "chapter16": "grass",
	"chapter11": "grass", "chapter3": "wood", "chapter10a": "wood", "chapter14": "wood", "chapter12": "wood"}
const MUSIC_DB := -14.0
const AMBIENCE_DB := -20.0

var _music: Array[AudioStreamPlayer] = []
var _cur := 0
var _music_name := ""
var _ambience: AudioStreamPlayer
var _ambience_name := ""
var _sfx: Array[AudioStreamPlayer] = []
var _cache: Dictionary = {}
var _scene_path := ""
var step_surface := "stone"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.volume_db = -80.0
		p.bus = "Music"
		add_child(p)
		_music.append(p)
	_ambience = AudioStreamPlayer.new()
	_ambience.volume_db = AMBIENCE_DB
	_ambience.bus = "SFX"
	add_child(_ambience)
	for i in 6:
		var s := AudioStreamPlayer.new()
		s.bus = "SFX"
		add_child(s)
		_sfx.append(s)


func _process(_delta: float) -> void:
	# Sahne değişince bölümün müziğine geç
	var scene := get_tree().current_scene
	if scene == null or scene.scene_file_path == _scene_path:
		return
	_scene_path = scene.scene_file_path
	var key := _scene_path.get_file().get_basename()
	ambience(CHAPTER_AMBIENCE.get(key, ""))
	step_surface = CHAPTER_STEPS.get(key, "stone")
	# Sahne kendi parçasını seçebilir (ör. Bölüm 4: ordugâh ya da Bizans surları)
	if scene.has_meta("music"):
		music(scene.get_meta("music"))
	elif CHAPTER_MUSIC.has(key):
		music(CHAPTER_MUSIC[key])


func _load(path: String, loop: bool) -> AudioStream:
	if _cache.has(path):
		return _cache[path]
	if not ResourceLoader.exists(path):
		_cache[path] = null
		return null
	var s: AudioStream = load(path)
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = loop
	elif s is AudioStreamMP3:
		(s as AudioStreamMP3).loop = loop
	_cache[path] = s
	return s


## Müziği yumuşak geçişle değiştirir. "" müziği susturur.
func music(track: String, fade := 1.5) -> void:
	if track == _music_name:
		return
	_music_name = track
	var old := _music[_cur]
	_cur = 1 - _cur
	var nu := _music[_cur]
	var tw := create_tween().set_parallel(true)
	tw.tween_property(old, "volume_db", -80.0, fade)
	if track != "":
		var s := _music_stream(track)
		if s != null:
			nu.stream = s
			nu.volume_db = -80.0
			nu.play()
			tw.tween_property(nu, "volume_db", MUSIC_DB, fade)
	tw.chain().tween_callback(old.stop)


## Önce ElevenLabs .mp3'ü, yoksa eski .ogg'u, o da yoksa yedek parçayı çalar.
func _music_stream(track: String) -> AudioStream:
	for ext in [".mp3", ".ogg"]:
		if ResourceLoader.exists(MUSIC_DIR + track + ext):
			return _load(MUSIC_DIR + track + ext, track not in ["credits", "explosion_slowmo"])
	if MUSIC_FALLBACK.has(track):
		return _music_stream(MUSIC_FALLBACK[track])
	return null


func current_music() -> String:
	return _music_name


## Döngülü ortam sesi (ordugâh kalabalığı, gece, şehir, floresan). "" susturur.
func ambience(name: String) -> void:
	if name == _ambience_name:
		return
	_ambience_name = name
	_ambience.stop()
	if name == "":
		return
	var s := _load(SFX_DIR + name + ".ogg", true)
	if s != null:
		_ambience.stream = s
		_ambience.play()


## Tek seferlik efekt. Ayak sesi gibi varyasyonlu olanlar için ad "_1".."_4" olmadan verilir.
func sfx(name: String, volume_db := -6.0, pitch := 1.0) -> void:
	var path := SFX_DIR + name + ".ogg"
	if not ResourceLoader.exists(path):
		path = SFX_DIR + "%s_%d.ogg" % [name, randi_range(1, 4)]
	var s := _load(path, false)
	if s == null:
		return
	for p in _sfx:
		if not p.playing:
			p.stream = s
			p.volume_db = volume_db
			p.pitch_scale = pitch
			p.play()
			return


func step() -> void:
	sfx("footstep_" + step_surface, -16.0, randf_range(0.9, 1.1))
