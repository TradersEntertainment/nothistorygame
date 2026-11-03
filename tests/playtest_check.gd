extends Node
## Oyun testi kiti denetimi: anket açılır, 4 puan ve bir cevap seçilir; bölüm kaydı JSON olarak yazılır ve geri
## okunur; çıkıştaki panoya kopyalama ve "Kopyala / Çık / Geri" kartı (_send_flow). Ağ çağrısı yoktur. Kare: --out=DİZİN verilirse anket ekranı çekilir.
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
	# Kendi klasörü: geliştiricinin gerçek test verisine dokunulmaz, önceki koşudan kalan dosya sayıyı bozmaz
	GameState.playtest_dir = "user://playtest_check"
	var old_dir := DirAccess.open(GameState.playtest_dir)
	if old_dir:
		for fn in old_dir.get_files():
			old_dir.remove(fn)
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
	var why := "" if ok else "anket/dosya %s %s" % [ans, seg]
	if ok:
		why = await _send_flow(hud)
	print("PLAYTESTCHECK %s" % ("PASS" if why == "" else "FAIL " + why))
	get_tree().quit(0 if why == "" else 1)


## Çıkışta panoya kopyalama (v0.99.77): önceki açılıştan kalan dosya + bu oturum + süren bölüm tek metinde; kopyalanınca
## yeniden sorulmaz; yeni gönderilmemiş dosya gelince kart açılır, Kopyala durumu gösterir, Geri çıkışı iptal eder.
func _send_flow(hud: Hud) -> String:
	_old_file("eski_a", "chapter_eski")
	GameState._pt_seg = {"scene": "chapter_live", "chapter": 10, "t0": GameState.play_time - 100.0, "stats0": {}, "combat0": {}}
	if not GameState.playtest_pending():
		return "bekleyen yok sayıldı"
	var r: Array = GameState.playtest_clip_text()
	var text: String = r[0]
	var lines := Array(text.split("\n")).filter(func(l: String): return l.begins_with(GameState.PT_CLIP_TAG))
	if lines.size() != 2 or not ("chapter_eski" in text and "chapter_live" in text and "chapter_test" in text):
		return "pano metni %d satır: %s" % [lines.size(), text.left(300)]
	var f := FileAccess.open(GameState.playtest_dir.path_join("pano.txt"), FileAccess.WRITE)
	f.store_string("[03.11.2026 14:20] Ali: " + text)
	f.close()
	print("PLAYTESTCHECK clip=%s" % ProjectSettings.globalize_path(GameState.playtest_dir.path_join("pano.txt")))
	if GameState.playtest_pending():
		return "kopyalandıktan sonra yine soruluyor"
	# Süren bölüm kopyalanıp hemen çıkılırsa (quit) sonraki açılışta sorulmaz
	GameState._pt_close("quit")
	if GameState.playtest_pending():
		return "kopyalanan süren bölüm kapanınca yine soruluyor"
	# Yeni gönderilmemiş dosya: çıkış kartı
	_old_file("eski_b", "chapter_eski_b")
	var res := {"r": null}
	(func(): res["r"] = await GameState.quit_game()).call()
	for i in 4:
		await get_tree().process_frame
	var card := get_tree().root.find_child("PlaytestSend", true, false) as PlaytestSend
	if card == null:
		return "çıkış kartı açılmadı"
	if out != "":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(out.path_join("send.png"))
	card._do_copy()
	if not card._status.visible or not card._status.text.contains("3"):     # eski_b 1 + bu oturum 2
		return "kopyala durumu: '%s'" % card._status.text
	if out != "":
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(out.path_join("send_copied.png"))
	card._finish("back")
	for i in 3:
		await get_tree().process_frame
	if res["r"] != false:
		return "Geri çıkışı iptal etmedi (%s)" % str(res["r"])
	if get_tree().paused:
		return "Geri'den sonra oyun duraklı kaldı"
	if GameState.playtest_pending():
		return "kart kopyaladıktan sonra yine soruluyor"
	# Pencere kapatma (X, Alt+F4): oyun testi açıkken motor beklemeye alınır, kart açılır
	GameState.apply_settings()
	if get_tree().auto_accept_quit:
		return "oyun testi açıkken pencere kapatma beklenmiyor (auto_accept_quit)"
	_old_file("eski_c", "chapter_eski_c")
	GameState.notification(NOTIFICATION_WM_CLOSE_REQUEST)
	for i in 4:
		await get_tree().process_frame
	card = get_tree().root.find_child("PlaytestSend", true, false) as PlaytestSend
	if card == null:
		return "pencere kapatınca çıkış kartı açılmadı"
	card._finish("back")
	for i in 3:
		await get_tree().process_frame
	GameState.settings["playtest"] = false
	GameState.apply_settings()
	if not get_tree().auto_accept_quit:
		return "oyun testi kapalıyken pencere kapatma bekletiliyor"
	return ""


func _old_file(fn: String, scene: String) -> void:
	DirAccess.make_dir_recursive_absolute(GameState.playtest_dir)
	var d := {"version": "0.99.75", "locale": "tr", "started": "2026-11-01T10:00:00",
		"chapters": [{"scene": scene, "chapter": 3, "end": "done", "seconds": 120.0, "counters": {},
			"survey": {"fun": 3, "laugh": "", "bored": "", "skipped": false}}]}
	var f := FileAccess.open(GameState.playtest_dir.path_join("oturum_%s.json" % fn), FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()


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
