class_name HitchAudit
extends Node
## Takılma denetçisi (--hitchaudit, --max-fps 60 ile): iki kare arasındaki gerçek süreyi ölçer (Performance monitörleri
## saniyede bir güncelleniyor, tek kareyi göstermiyor). 60 FPS'te kare 16,7 ms; 25 ms'yi aşan kare takılmadır. Satırlar:
##   HITCH scene=... t=... frame=..ms               (25 ms üstü her kare; sahne başına en çok 12 satır)
##   HITCHSUM scene=... frames=.. over8=.. over16=.. max=..ms p99=..ms   (sahne değişince ve çıkışta)
## Başsız koşuda çizim yoktur: ölçülen yalnız oyun kodu ve fizik (ekran kartı değil).

const LIMIT_MS := 25.0
var _last_us := 0
var _scene := ""
var _samples: Array[float] = []
var _lines := 0
var _t := 0.0
var _rinfo := OS.get_environment("RINFO") != ""
var _rinfo_next := 0.0
var _win := 0
var _nodes := 0


var _added := {}                 # bu karede eklenen düğümler: ebeveyn yolu -> sayı


func _ready() -> void:
	get_tree().node_added.connect(func(n: Node):
		# Betik taşıyan ilk iki ata: hangi sistem kuruyor (Person < CityLife gibi)
		var chain := PackedStringArray()
		var a := n.get_parent()
		while a != null and chain.size() < 2:
			if a.get_script():
				chain.append((a.get_script() as Script).resource_path.get_file().get_basename())
			a = a.get_parent()
		var key: String = "<".join(chain) if not chain.is_empty() else "?"
		_added[key] = int(_added.get(key, 0)) + 1)


func _top_added() -> String:
	var best := ""
	var bn := 0
	for k in _added:
		if int(_added[k]) > bn:
			bn = int(_added[k])
			best = k
	return "%s x%d" % [best, bn] if bn > 0 else "-"


func _init() -> void:
	name = "HitchAudit"
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 1000          # öteki _process'lerden sonra: bu karenin ölçümü dolmuş olur


func _process(delta: float) -> void:
	_process_body(delta)
	_added.clear()


func _process_body(delta: float) -> void:
	var sc := get_tree().current_scene
	var sname := sc.scene_file_path.get_file().get_basename() if sc else ""
	if sname != _scene:
		_flush()
		_last_us = 0
		_scene = sname
		_t = 0.0
		_rinfo_next = 0.0
	_t += delta
	if _t < 0.5:
		return                       # sahne kurulumu ayrı ölçülür (yükleme ekranı); oynanış takılmaları aranıyor
	# RINFO=1: iki saniyede bir çizim çağrısı, kameradaki nesne, üçgen, ışık ve süreç süresi (görüntülü koşuda anlamlı)
	if _rinfo and _t >= _rinfo_next:
		_rinfo_next = _t + 2.0
		if OS.get_environment("RINFO") == "noshadow":     # karşılaştırma: güneş gölgesi kapalıyken çizim yükü
			for l in get_tree().current_scene.find_children("*", "DirectionalLight3D", true, false):
				(l as DirectionalLight3D).shadow_enabled = false
		print("RINFO scene=%s t=%.0f draws=%d objs=%d prims=%dk nodes=%d proc=%.1fms phys=%.1fms" % [_scene, _t,
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) / 1000,
			int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
			Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0])
	var now := Time.get_ticks_usec()
	var nn := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var dn := nn - _nodes
	_nodes = nn
	# Ekran karartılmış ya da bölüm kartı açıkken takılma görünmez (kurulum oraya saklanır): sayılmaz
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		var fade = hud.get("_fade")
		var card = hud.get("_card")
		if (fade is ColorRect and (fade as ColorRect).color.a > 0.6) or (card is Control and (card as Control).get_child_count() > 0):
			_last_us = now
			return
	var tot := (now - _last_us) / 1000.0 if _last_us > 0 else 0.0
	_last_us = now
	if tot <= 0.0 or get_tree().paused:
		return
	_samples.append(tot)
	_win += 1
	if _win >= 1200:                 # her ~20 sn bir ara özet (çıkışta yazılmayabilir)
		_flush(false)
	if tot > LIMIT_MS and _lines < int(OS.get_environment("HITCH_LINES") if OS.has_environment("HITCH_LINES") else "12"):
		_lines += 1
		print("HITCH scene=%s t=%.1f frame=%.1fms nodes%+d (%d) %s added=%s" % [_scene, _t, tot, dn, nn, _masked_str(), _top_added()])


func _masked_str() -> String:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud == null:
		return "nohud"
	var fade = hud.get("_fade")
	return "fade=%.2f" % ((fade as ColorRect).color.a if fade is ColorRect else -1.0)


func _flush(reset_lines := true) -> void:
	_win = 0
	if _scene == "" or _samples.size() < 30:
		_samples.clear()
		if reset_lines:
			_lines = 0
		return
	var s := _samples.duplicate()
	s.sort()
	var over25 := s.filter(func(x: float): return x > 25.0).size()
	var over50 := s.filter(func(x: float): return x > 50.0).size()
	print("HITCHSUM scene=%s frames=%d over25=%d over50=%d max=%.1fms p99=%.1fms median=%.1fms" % [_scene, s.size(), over25,
		over50, s[s.size() - 1], s[int(s.size() * 0.99)], s[s.size() / 2]])
	_samples.clear()
	if reset_lines:
		_lines = 0


func _exit_tree() -> void:
	_flush()
