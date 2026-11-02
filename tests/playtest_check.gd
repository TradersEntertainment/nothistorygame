extends Node
## Oyun testi kiti denetimi: anket açılır, 4 puan ve bir cevap seçilir; bölüm kaydı user://playtest'e JSON olarak
## yazılır ve geri okunur. Ağ çağrısı yoktur. Kare: --out=DİZİN verilirse anket ekranı çekilir.
##   godot --path . res://tests/playtest_check.tscn [-- --out=DİZİN]
var out := ""


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.trim_prefix("--out=")
	_run.call_deferred()


func _run() -> void:
	GameState.autotest = false
	GameState.settings["playtest"] = true
	var hud := Hud.new()
	add_child(hud)
	hud.fade_to(0.0, 0.01)
	await get_tree().process_frame
	_answer.call_deferred(hud)
	var ans: Dictionary = await hud.playtest_survey()
	var ok := int(ans.get("fun", 0)) == 4 and str(ans.get("laugh", "")) == "fes"
	GameState._pt_seg = {"scene": "chapter_test", "chapter": 9, "t0": GameState.play_time, "stats0": {}, "combat0": {}}
	GameState.playtest_event("skips")
	GameState._pt_seg["outcome"] = "9.1"
	GameState._pt_seg["survey"] = ans
	GameState._pt_close("done")
	var path: String = GameState._pt_path
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	var seg: Dictionary = (data["chapters"] as Array)[-1] if data is Dictionary else {}
	ok = ok and seg.get("end") == "done" and int(seg.get("skips", 0)) == 1 and int((seg.get("survey", {}) as Dictionary).get("fun", 0)) == 4
	print("PLAYTESTCHECK file=%s" % ProjectSettings.globalize_path(path))
	print("PLAYTESTCHECK %s" % ("PASS" if ok else "FAIL %s %s" % [ans, seg]))
	get_tree().quit(0 if ok else 1)


func _answer(hud: Hud) -> void:
	for i in 4:
		await get_tree().process_frame
	var sv := hud.get_node_or_null("PlaytestSurvey") as PlaytestSurvey
	if sv == null:
		print("PLAYTESTCHECK FAIL anket açılmadı")
		get_tree().quit(1)
		return
	sv._pick(4)
	sv._laugh.text = "fes"
	if out != "":
		await get_tree().process_frame
		await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png(out.path_join("survey.png"))
	sv._send.pressed.emit()
