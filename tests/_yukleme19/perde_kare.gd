extends Node
## G19 pencereli kanıt: oyuncunun gördüğü sahne değişimi (GameState.change_scene → yükleme perdesi) bölüme. Dışarıdan
## (ffmpeg x11grab) 0,5 sn arayla kare alınır: perdenin çarkı ve çubuğu ilerliyor mu, yoksa donuk mu.
##   xvfb altında: godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_yukleme19/perde_kare.tscn -- hedef=chapter24
## YUKLEMEAUDIT=1 ortamında YUKLEMEAUDIT ve YUKLEMEAUDIT_PENCERE satırları da basılır.

var hedef := "chapter24"


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2 and kv[0] == "hedef":
			hedef = kv[1]
	GameState.chapter_outcomes[8] = "8.1"
	GameState.chapter_outcomes[6] = "6b.1"
	print("PERDEKARE basla hedef=%s t=%d" % [hedef, Time.get_ticks_msec()])
	process_mode = Node.PROCESS_MODE_ALWAYS
	_git.call_deferred()


func _git() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().current_scene = null        # bu düğüm sahne değişiminde boşaltılmasın (kökte kalır)
	print("PERDEKARE degisim t=%d" % Time.get_ticks_msec())
	var t0 := Time.get_ticks_msec()
	GameState.change_scene("res://scenes/%s.tscn" % hedef)
	var tree := get_tree()
	while tree.current_scene == null or tree.current_scene.scene_file_path.get_file().get_basename() != hedef \
			or not tree.current_scene.is_node_ready():
		await tree.process_frame
	print("PERDEKARE hazir ms=%d" % (Time.get_ticks_msec() - t0))
	await tree.create_timer(4.0).timeout
	print("PERDEKARE bitti")
	tree.quit()
