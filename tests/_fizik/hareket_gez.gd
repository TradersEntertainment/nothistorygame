extends Node
## Hareket hissi oyun içi kare aracı (yalnız --hareket-kare=<klasör> verilince Player._ready yükler; paketli oyunda yok).
##   --hareket-kare=<klasör>          kareler buraya
##   --hareket-kare-on=ONCE|SONRA     dosya adı eki
##   --hareket-kare-tetik=flail|kuyu  flail: oyuncunun kolları uzun savrulunca (Bölüm 2 kızaktan uçuş, flail ≥ 1,0 sn);
##                                    kuyu: Bölüm 44b (--autotest ile açın) — avluda otomatik testi kapatır, kuyuya
##                                    kendisi "basar", ip kopunca (hızlı iniş) çeker
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
var _hizli := 0
var _dbg_t := 0.0
var _ilk_y := INF
var _durgun := 0.0


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
	_dbg_t += delta
	if _dbg_t > 5.0:
		_dbg_t = 0.0
		print("HAREKETGEZ t=%d faz=%s y=%.2f" % [Time.get_ticks_msec() / 1000, str(sc.get("phase")), p.global_position.y])
	match tetik:
		"flail":
			if p._flail_t >= 1.0:
				_cek(ad + "_ucus")
		"kuyu":
			if not _kuyu_basti and str(sc.get("phase")) in ["yard", "descend"]:
				# --autotest ile açılır (menüsüz, avlu konuşmaları hızlı); kuyuya inerken otomatik test kapanır: iniş ve
				# düşüş oyundaki gerçek süreleriyle oynar (otomatik testte düşüş 0,05 sn)
				_kuyu_basti = true
				GameState.autotest = false
				Engine.time_scale = 1.0
				if str(sc.get("phase")) == "yard":
					sc.call("_on_interact", "well")
			var y := p.global_position.y
			# İpte iniş 4,8 m (kuyu ağzı +3,7'den −1,1'e): inişin sonuna doğru ağır çekime geçilir (yazılım çiziminde
			# 0,75 sn'lik düşüş yoksa tek karede biterdi); iniş başında oyun 0,25 hızında (karede ≤ 0,25 sn)
			if str(sc.get("phase")) == "descend":
				if _son_y != INF and absf(_son_y - y) > 1.0 and Engine.time_scale > 0.05:
					_ilk_y = INF            # avludan kuyunun içine ışınlandı: iniş buradan ölçülür
				if _ilk_y == INF:
					_ilk_y = y
					Engine.time_scale = 0.25
				if _ilk_y - y > 4.6 and Engine.time_scale > 0.05:
					Engine.time_scale = 0.04
			# Işınlanma (avludan kuyunun içine) sayılmaz: karede 1 m'den az, iki ardışık karede > 3 m/sn iniş (ip kopunca)
			var hiz := (_son_y - y) / maxf(delta, 0.001) if _son_y != INF and absf(_son_y - y) < 1.0 else 0.0
			_hizli = _hizli + 1 if hiz > 3.0 and str(sc.get("phase")) == "descend" else 0
			# İp 4,8 m'de biter; ondan 0,15 m aşağısı kopuştan sonraki düşüş (tween'ler çizim karesinde ilerler: fizik
			# adımları arasında hız sıfır görünebilir, yalnız hıza bakılmaz)
			if _hizli >= 2 or (_ilk_y != INF and str(sc.get("phase")) == "descend" and _ilk_y - y > 4.95):
				_cek(ad + "_kuyu")
			_son_y = y


## Yazılım çizimi (xvfb) saniyede ~1 kare çizer: kare aralığı oyun zamanında doğru olsun diye çekim boyunca oyun
## ağır çekimde (time_scale 0,04) akar, kareler oyun zamanıyla 0,1 sn arayla alınır.
func _cek(ad: String) -> void:
	_mesgul = true
	Engine.time_scale = 0.04
	for i in n:
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_jpg(dir.path_join("%s_%s_%d.jpg" % [ad, on_, i]), 0.85)
		if i < n - 1:
			await get_tree().create_timer(ara, true, false, false).timeout
	print("HAREKETKARE %s %s" % [ad, on_])
	_bitti = true
	get_tree().quit(0)
