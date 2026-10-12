extends Node
## Büro önsözünün kaydı (v0.99.6). Bölüm 17 sahnesi hem Büro'yu (zamanın dışında) hem 28 Nisan sayfasını taşır; kuşatma
## iki tarafta da 17'den önce başlar (Bizans 36b → 29 → 17, Osmanlı 33o … 29o → 17o). Rotayı bölümlerin kayıt
## çağrılarıyla (Siege.snapshot_scene17, Siege.snapshot_page17, GameState.snapshot) yürür ve denetler:
##   * 28 Nisan'a varınca önsözün başı geri yüklenmez: Büro geçilmiş sayılır, taraf ve aradaki sayfaların sonuçları kalır;
##   * bölüm listesinden Büro'ya ve 28 Nisan'a geri dönüş doğru durumu açar;
##   * eski kayıtlarda 17 numarasıyla kalmış Büro kaydı sayfaya varınca Büro'ya taşınır.
## Sonuç: SNAPCHECK PASS/FAIL.

var ok := true


func _ready() -> void:
	GameState.autotest = true
	for side in ["B", "O"]:
		for old_save in [false, true]:
			_route(side, old_save)
	print("SNAPCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)


func _fail(msg: String) -> void:
	printerr("SNAPCHECK " + msg)
	ok = false


## Huzurdan Büro'ya, oradan kuşatmanın ilk sayfasından 28 Nisan'a. old_save: Büro kaydı v0.99.6'dan önceki gibi 17
## numarasıyla alınmış (eski kayıt dosyası).
func _route(side: String, old_save: bool) -> void:
	var tag := side + (" (eski kayıt)" if old_save else "")
	GameState.reset_run()
	GameState.ensure_defaults_for(12)
	_open(12, "res://scenes/chapter12.tscn")
	GameState.chapter_outcomes[12] = "12.1"
	Siege.gate("res://scenes/chapter13.tscn")
	# Bölüm 17 sahnesi açılır: Büro önsözü
	if old_save:
		GameState.snapshot(17)
		GameState._snapshots[17]["scene"] = Siege.PROLOGUE
	else:
		Siege.snapshot_scene17()
		_mark(Siege.PROLOGUE)
		if not GameState._snapshots.has(Siege.BUREAU):
			_fail("%s: Büro önsözü kendi kaydını almadı" % tag)
	GameState.flags["siege_contract"] = true
	GameState.flags["siege_side"] = side
	GameState.flags["siege_bureau_done"] = true
	# Kuşatmanın 28 Nisan'dan önceki sayfaları
	var played: Array[int] = []
	var path := Siege.first_path()
	var guard := 0
	while path != "" and guard < 12:
		guard += 1
		var ch := _id(path)
		if ch == 17:
			break
		_open(ch, path)
		GameState.chapter_outcomes[ch] = "%d%s.1" % [ch, "O" if side == "O" else ""]
		GameState.flags["page_%d" % ch] = true
		played.append(ch)
		path = Siege.next_path(ch)
	if played.is_empty():
		_fail("%s: kuşatma 17'den önce başlamıyor, sınanacak bir şey yok" % tag)
		return
	print("SNAP %s: Büro → %s → 17" % [tag, played])
	# 28 Nisan: Bizans'ta aynı sahne (chapter17), Osmanlı'da chapter17o
	_enter17(side, path)
	_check_page(tag + ", ilk varış", side, played)
	GameState.chapter_outcomes[17] = "17.1"
	var data := GameState.run_data()
	# Bölüm listesinden Büro'ya dönüş
	var p := GameState.prepare_load(data, Siege.BUREAU)
	if p != Siege.PROLOGUE:
		_fail("%s: Büro'ya dönüş %s sahnesini açıyor" % [tag, p])
	Siege.snapshot_scene17()
	if GameState.flags.get("siege_bureau_done", false):
		_fail("%s: Büro'ya dönüşte Büro geçilmiş sayıldı (önsöz oynamaz)" % tag)
	if GameState.chapter_outcomes.has(played[0]):
		_fail("%s: Büro'ya dönüşte sonraki sayfanın (%d) sonucu kaldı" % [tag, played[0]])
	# Bölüm listesinden 28 Nisan'a dönüş
	p = GameState.prepare_load(data, 17)
	if p != path:
		_fail("%s: 28 Nisan'a dönüş %s sahnesini açıyor (beklenen %s)" % [tag, p, path])
	_enter17(side, path)
	_check_page(tag + ", geri dönüş", side, played)


## Bir bölüm sahnesi açılır (kaydını alır; sahne yolunu _autosave gibi yazar).
func _open(ch: int, path: String) -> void:
	GameState.snapshot(ch)
	_mark(path)


func _mark(path: String) -> void:
	GameState._snapshots[GameState.current_chapter]["scene"] = path


## 28 Nisan sahnesinin _ready'si: chapter17 Siege.snapshot_scene17, chapter17o Siege.snapshot_page17 çağırır.
func _enter17(side: String, path: String) -> void:
	if side == "B":
		Siege.snapshot_scene17()
	else:
		Siege.snapshot_page17()
	if GameState._snapshots.has(GameState.current_chapter):
		_mark(path)


func _check_page(tag: String, side: String, played: Array[int]) -> void:
	if GameState.current_chapter != 17:
		_fail("%s: şimdiki bölüm %d (beklenen 17)" % [tag, GameState.current_chapter])
	if not GameState.flags.get("siege_bureau_done", false):
		_fail("%s: 28 Nisan'da Büro geçilmemiş sayıldı (önsöz yeniden oynar)" % tag)
	if Siege.side() != side:
		_fail("%s: taraf %s (beklenen %s)" % [tag, Siege.side(), side])
	if not GameState.flags.get("siege_contract", false):
		_fail("%s: sözleşme bayrağı silindi" % tag)
	for ch in played:
		if not GameState.chapter_outcomes.has(ch):
			_fail("%s: %d'nin sonucu silindi" % [tag, ch])
		if not GameState.flags.get("page_%d" % ch, false):
			_fail("%s: %d'de kurulan bayrak silindi" % [tag, ch])


func _id(path: String) -> int:
	var f := path.get_file().get_basename().trim_prefix("chapter")
	var d := ""
	for c in f:
		if c >= "0" and c <= "9":
			d += c
		else:
			break
	return int(d)
