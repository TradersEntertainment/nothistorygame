class_name AudioAudit
extends Node
## Ses denetçisi (--audioaudit=KLASÖR, PACE ile): testler başsız ve "sessiz" sanılıyordu ama başsız sürücü (Dummy) sesi
## gerçekten karıştırıyor. Bu düğüm her 50 ms'de veri yollarının tepe düzeyini ve Voice yolundaki oynatıcıları ölçer,
## kulakla yakalanacak hataları satır olarak yazar (AUDIOAUDIT tür ...):
##   cut      replik yarıda kesildi (sonraki söz, bölüm geçişi, düğüm silindi); cut_voice ile bilerek kesilen sayılmaz
##   silent   replik çalıyor görünüyor ama Voice yolunda ses yok
##   overlap  iki seslendirme aynı anda çalıyor
##   clip     bir yol 0 dBFS'i aştı (çıkıştaki sınırlayıcı eziyor)
##   mask     müzik konuşmayla aynı yükseklikte (konuşma duyulmuyor)
##   gap      müzik çalmalıydı, yol 3 sn'den uzun sessiz
## Bölüm başına düzey özeti (ortanca/üst yüzdelik) KLASÖR/levels.csv'ye eklenir: bölümler arası ses sıçramaları için
## tools/audio_report.py. PACE gerekir: hızlı testte replikler sesi beklemeden geçer.

const STEP := 0.05
const BUSES := ["Master", "Voice", "Music", "SFX"]

static var cut_ok_until := 0      # ms: Hud.cut_voice bilerek keser

var out_dir := ""
var _acc := 0.0
var _t := 0.0
var _scan := 0.0
var _players: Array = []          # izlenen Voice oynatıcıları
var _state := {}                  # oynatıcı id -> {pos, len, key, t0, heard}
var _levels := {}                 # yol -> Array[float] (bu bölümün örnekleri)
var _music_quiet := 0.0
var _clip_seen := {}
var _mask := {}                   # anahtar -> [müzik-ses farkı toplamı, örnek]
var _scene := ""
var _reported := {}
var _now: Array = []              # şu an çalan seslendirme anahtarları


func _init(dir: String) -> void:
	out_dir = dir
	name = "AudioAudit"
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(out_dir)
	for b in BUSES:
		_levels[b] = []


func _report(kind: String, what: String, detail := "") -> void:
	var k := kind + "|" + what
	if _reported.has(k):
		return
	_reported[k] = true
	print("AUDIOAUDIT %s %s scene=%s t=%.1f %s" % [kind, what, _scene, _t, detail])


func _peak(bus: String) -> float:
	var i := AudioServer.get_bus_index(bus)
	if i < 0:
		return -200.0
	return maxf(AudioServer.get_bus_peak_volume_left_db(i, 0), AudioServer.get_bus_peak_volume_right_db(i, 0))


static func _key(p: Node) -> String:
	var s: AudioStream = p.get("stream")
	return s.resource_path.get_file().get_basename() if s and s.resource_path != "" else ""


func _process(delta: float) -> void:
	var sc := get_tree().current_scene
	var sname := sc.scene_file_path.get_file().get_basename() if sc else ""
	if sname != _scene:
		_flush_levels()
		_scene = sname
	if get_tree().paused:
		return
	_acc += delta
	if _acc < STEP:
		return
	var dt := _acc
	_acc = 0.0
	_t += dt
	_scan -= dt
	if _scan <= 0.0:
		_scan = 0.25
		_players.clear()
		for p in get_tree().root.find_children("*", "AudioStreamPlayer", true, false) \
				+ get_tree().root.find_children("*", "AudioStreamPlayer3D", true, false):
			if p.get("bus") == "Voice" and not (p.get("stream") is AudioStreamGenerator):
				_players.append(p)
	var pk := {}
	for b in BUSES:
		pk[b] = _peak(b)
		_levels[b].append(pk[b])
	_track_voices(dt, pk)
	for b in BUSES:
		if pk[b] > 2.0 and not _clip_seen.has(b + _scene):
			_clip_seen[b + _scene] = true
			_report("clip", b, "peak=%.1fdB voice=%s music=%s" % [pk[b], ",".join(_now), Audio.current_music()])
	# Müzik boşluğu: bir parça seçili ama yol sessiz (geçişte 1,5 sn kararma olağan)
	if Audio.current_music() != "" and pk["Music"] < -60.0:
		_music_quiet += dt
		if _music_quiet > 4.0:      # 3 sn'ye kadarı parçanın kendi girişi (yavaş açılan ney, davul)
			var why := PackedStringArray()
			for m: AudioStreamPlayer in Audio._music:
				why.append("%s:%s%s@%.0fdB" % [m.stream.resource_path.get_file() if m.stream else "-", "play" if m.playing else "stop",
					"/paused" if m.stream_paused else "", m.volume_db])
			_report("gap", Audio.current_music(), "%.1fs players=%s" % [_music_quiet, " ".join(why)])
	else:
		_music_quiet = 0.0


func _track_voices(dt: float, pk: Dictionary) -> void:
	var playing: Array = []
	var seen := {}
	for p in _players:
		if not is_instance_valid(p):
			continue
		var id: int = p.get_instance_id()
		seen[id] = true
		var st: Dictionary = _state.get(id, {})
		var k := _key(p)
		if p.get("playing") and not p.get("stream_paused"):
			playing.append(k)
			if st.is_empty() or st["key"] != k:
				if not st.is_empty():
					_end_line(st, "replaced by " + k)      # aynı oynatıcıda yeni söz: eskisi bitmeden mi geldi
				st = {"key": k, "pos": 0.0, "len": (p.get("stream") as AudioStream).get_length(), "age": 0.0, "heard": false,
					"scene": _scene}
			st["pos"] = p.get_playback_position()
			st["age"] += dt
			if pk["Voice"] > -45.0:
				st["heard"] = true
			if st["age"] > 1.2 and not st["heard"] and p.get("volume_db") > -30.0:
				_report("silent", k, "voice=%.0fdB" % pk["Voice"])
			# Konuşma sürerken müzik ona ne kadar yakın: ortalama fark 6 dB'den azsa konuşma örtülür
			if pk["Voice"] > -30.0 and pk["Music"] > -40.0:
				var m: Array = _mask.get(k, [0.0, 0])
				m[0] += pk["Voice"] - pk["Music"]
				m[1] += 1
				_mask[k] = m
			_state[id] = st
		elif not st.is_empty():
			_end_line(st, "stop")
			_state.erase(id)
	for id in _state.keys():
		if not seen.has(id):
			_end_line(_state[id], "freed")
			_state.erase(id)
	_now = playing
	if playing.size() > 1:
		playing.sort()
		_report("overlap", " + ".join(playing))


func _end_line(st: Dictionary, why: String) -> void:
	var m: Array = _mask.get(st["key"], [0.0, 0])
	if m[1] >= 10 and m[0] / m[1] < 6.0:
		_report("mask", st["key"], "voice-music=%.1fdB" % (m[0] / m[1]))
	_mask.erase(st["key"])
	if Time.get_ticks_msec() < cut_ok_until:
		return
	# Son yarım saniye sayılmaz: makine yüklüyken başsız sürücünün karıştırıcısı oyun saatinin gerisinde kalıyor (söz
	# zamanında bitmiş ama konum 0,5 sn geride görünüyor). Gerçek kesilme sözün ortasında olur.
	var left: float = st["len"] - st["pos"]
	if left > maxf(0.8, st["len"] * 0.15):
		_report("cut", st["key"], "%s at %.1f/%.1fs (from %s)" % [why, st["pos"], st["len"], st.get("scene", "")])


func _flush_levels() -> void:
	if _scene == "" or (_levels["Master"] as Array).size() < 40:
		for b in BUSES:
			_levels[b] = []
		return
	var path := out_dir.path_join("levels.csv")
	var f := FileAccess.open(path, FileAccess.READ_WRITE) if FileAccess.file_exists(path) else FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return
	f.seek_end()
	if f.get_position() == 0:
		f.store_line("scene,bus,median_db,p95_db,active_share")
	for b in BUSES:
		var a: Array = (_levels[b] as Array).filter(func(x): return x > -70.0)
		var share := float(a.size()) / maxf(1.0, (_levels[b] as Array).size())
		a.sort()
		var med: float = a[a.size() / 2] if a.size() > 0 else -200.0
		var p95: float = a[mini(a.size() - 1, int(a.size() * 0.95))] if a.size() > 0 else -200.0
		f.store_line("%s,%s,%.1f,%.1f,%.2f" % [_scene, b, med, p95, share])
		_levels[b] = []
	f.close()


func _exit_tree() -> void:
	for id in _state.keys():
		var st: Dictionary = _state[id]
		var m: Array = _mask.get(st["key"], [0.0, 0])
		if m[1] >= 10 and m[0] / m[1] < 6.0:
			_report("mask", st["key"], "voice-music=%.1fdB" % (m[0] / m[1]))
	_flush_levels()
