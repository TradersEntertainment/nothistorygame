extends Node
## Uzun oturum (soak) testi: bütün bölüm sahneleri tek süreçte art arda açılır (SOAK_HOLD sn kalınır), iki tur
## dönülür. Her geçişten sonra bellek, nesne, düğüm, sahipsiz düğüm ve kaynak sayıları yazılır (SOAK satırı). İlk tur
## kaynak önbelleğini doldurur (bellek ~800 MB'a çıkar, sonra durur); son turda aynı sahnede ölçülen değer bir önceki
## turdakinden belirgin büyükse sahneler arası sızıntı var demektir (SOAK FAIL).
##   godot --headless --path . res://tests/soak.tscn    (SOAK_HOLD=6, SOAK_LAPS=2, SOAK_ONLY=chapter9,chapter12)
var runner := false
var hold := float(OS.get_environment("SOAK_HOLD")) if OS.has_environment("SOAK_HOLD") else 6.0
var laps := int(OS.get_environment("SOAK_LAPS")) if OS.has_environment("SOAK_LAPS") else 3


func _ready() -> void:
	if runner:
		_run.call_deferred()
		return
	var r: Node = load("res://tests/soak.gd").new()
	r.runner = true
	r.name = "SoakRunner"
	r.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(r)


func _scenes() -> Array[String]:
	var out: Array[String] = []
	var only := OS.get_environment("SOAK_ONLY").split(",", false) if OS.has_environment("SOAK_ONLY") else PackedStringArray()
	for f in DirAccess.get_files_at("res://scenes"):
		if not f.ends_with(".tscn") or not (f.begins_with("chapter") or f.begins_with("interlude")):
			continue
		if not only.is_empty() and not f.get_basename() in only:
			continue
		out.append("res://scenes/" + f)
	out.sort()
	return out


func _sample() -> Dictionary:
	return {"mem": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"obj": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"nodes": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"orphans": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
		"res": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))}


func _run() -> void:
	var list := _scenes()
	var first := {}          # sahne -> 1. turdaki ölçüm
	var ok := true
	var base := _sample()
	print("SOAK start scenes=%d mem=%.1fMB obj=%d res=%d" % [list.size(), base["mem"], base["obj"], base["res"]])
	for lap in laps:
		for path in list:
			GameState.change_scene(path)
			await _wait(hold)
			# Sahneden çıkıp boş kareye geç: ölçüm o sahnenin kendi kalıntısını görür
			var sc := get_tree().current_scene
			var name := path.get_file().get_basename()
			var m := _sample()
			print("SOAK lap=%d %s mem=%.1fMB obj=%d nodes=%d orphans=%d res=%d" % [lap, name, m["mem"], m["obj"], m["nodes"],
				m["orphans"], m["res"]])
			if sc == null:
				print("SOAK FAIL: sahne açılmadı %s" % name)
				ok = false
			if lap < laps - 1:
				first[name] = m          # son turdan önceki tur (önbellek ısınmış)
			else:
				var f: Dictionary = first.get(name, m)
				if m["orphans"] > f["orphans"] + 50 or m["obj"] > f["obj"] + 3000 or m["mem"] > f["mem"] + 60.0:
					print("SOAK leak %s obj %d→%d orphans %d→%d mem %.0f→%.0fMB" % [name, f["obj"], m["obj"], f["orphans"],
						m["orphans"], f["mem"], m["mem"]])
					ok = false
	var end := _sample()
	print("SOAK %s mem %.1f→%.1fMB obj %d→%d res %d→%d" % ["PASS" if ok else "FAIL", base["mem"], end["mem"], base["obj"],
		end["obj"], base["res"], end["res"]])
	get_tree().quit(0 if ok else 1)


func _wait(s: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(s * 1000.0):
		await get_tree().process_frame
