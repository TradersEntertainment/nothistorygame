extends Node
## Hareket hissi oyun içi kare aracı (yalnız --hareket-kare=<klasör> verilince Player._ready yükler; paketli oyunda yok).
##   --hareket-kare=<klasör>          kareler buraya
##   --hareket-kare-on=ONCE|SONRA     dosya adı eki
##   --hareket-kare-tetik=flail|kuyu  flail: oyuncunun kolları uzun savrulunca (Bölüm 2 kızaktan uçuş, flail ≥ 1,0 sn);
##                                    kuyu: Bölüm 44b — avluda kuyuya kendisi "basar", ip kopunca (hızlı iniş) çeker
##   --hareket-kare-n=8 --hareket-kare-ara=0.1
## Satır: HAREKETKARE <ad> <on> ; sonra oyunu kapatır.

var dir := ""
var on_ := "SONRA"
var tetik := "flail"
var n := 8
var ara := 0.1
var _bitti := false
var _mesgul := false
var _son_y := INF
var _kuyu_basti := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--hareket-kare="):
			dir = a.trim_prefix("--hareket-kare=")
		elif a.begins_with("--hareket-kare-on="):
			on_ = a.trim_prefix("--hareket-kare-on=")
		elif a.begins_with("--hareket-kare-tetik="):
			tetik = a.trim_prefix("--hareket-kare-tetik=")
		elif a.begins_with("--hareket-kare-n="):
			n = int(a.trim_prefix("--hareket-kare-n="))
		elif a.begins_with("--hareket-kare-ara="):
			ara = float(a.trim_prefix("--hareket-kare-ara="))
	DirAccess.make_dir_recursive_absolute(dir)


func _physics_process(delta: float) -> void:
	if _bitti or _mesgul:
		return
	var sc := get_tree().current_scene
	var p := get_tree().get_first_node_in_group("player") as Player
	if sc == null or p == null:
		return
	var ad := sc.scene_file_path.get_file().get_basename()
	match tetik:
		"flail":
			if p._flail_t >= 1.0:
				_cek(ad + "_ucus")
		"kuyu":
			if not _kuyu_basti and str(sc.get("phase")) == "yard":
				_kuyu_basti = true
				sc.call("_on_interact", "well")
			var y := p.global_position.y
			if _son_y != INF and str(sc.get("phase")) == "descend" and (_son_y - y) / maxf(delta, 0.001) > 3.0:
				_cek(ad + "_kuyu")
			_son_y = y


func _cek(ad: String) -> void:
	_mesgul = true
	for i in n:
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_jpg(dir.path_join("%s_%s_%d.jpg" % [ad, on_, i]), 0.85)
		if i < n - 1:
			await get_tree().create_timer(ara, true, false, false).timeout
	print("HAREKETKARE %s %s" % [ad, on_])
	_bitti = true
	get_tree().quit(0)
