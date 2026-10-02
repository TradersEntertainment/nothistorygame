extends Node
## Kuşatma yönlendirmesi (v0.53): iki taraf için Büro'dan sonraki ilk bölümden başlayıp next_path zincirini sonuna
## kadar yürür. Denetler: sıra Siege.ORDER'a uyar, her adım sahnesi var olan bir bölümdür, ekran numaraları 13'ten
## başlayıp kesintisiz artar, kuşatmadan sonraki 13–15 numaraları kuşatmanın uzunluğuna göre kayar, şehir tutulursa
## 31 ve 27 atlanır, bütün başlıklarda "{N}" doldurulur. Sonuç: ROUTECHECK PASS/FAIL.

func _ready() -> void:
	GameState.autotest = true
	var ok := true
	var saved := GameState.flags.duplicate(true)
	for side in ["B", "O"]:
		for held in [false, true]:
			GameState.flags["siege_side"] = side
			GameState.flags["siege_held"] = held
			var seq: Array[int] = []
			var path := Siege.first_path()
			var guard := 0
			while path != "" and guard < 40:
				guard += 1
				var ch := Siege.number(path) - Siege.NUMBER_BASE
				var id := _id(path)
				seq.append(id)
				if not ResourceLoader.exists(path):
					printerr("ROUTECHECK %s yok: %s" % [side, path])
					ok = false
				if Siege.number(path) != Siege.NUMBER_BASE + seq.size():
					printerr("ROUTECHECK %s numara %s → %d (beklenen %d)" % [side, path, Siege.number(path), Siege.NUMBER_BASE + seq.size()])
					ok = false
				var title := Siege.fill_number(tr(_title_key(path)), path)
				if title.contains("{N") or title.begins_with("UI_"):
					printerr("ROUTECHECK %s başlık: %s" % [path, title])
					ok = false
				path = Siege.next_path(id)
			# Sıra ORDER'a uyuyor mu
			var last := -1
			for id in seq:
				var k := Siege.ORDER.find(id)
				if k <= last:
					printerr("ROUTECHECK %s sıra bozuk: %s" % [side, seq])
					ok = false
				last = k
			if held and (31 in seq or 27 in seq):
				printerr("ROUTECHECK %s tutuldu ama fetih sonrası bölüm var: %s" % [side, seq])
				ok = false
			if not held and not (27 in seq):
				printerr("ROUTECHECK %s 27 yok: %s" % [side, seq])
				ok = false
			if not held:
				var after := Siege.number_of(13)
				if after != Siege.NUMBER_BASE + Siege.page_total() + 1:
					printerr("ROUTECHECK %s Bölüm 13'ün numarası %d" % [side, after])
					ok = false
				print("ROUTE side=%s seq=%s numbers=%d..%d after13=%d" % [side, seq, Siege.NUMBER_BASE + 1, Siege.NUMBER_BASE + seq.size(), after])
	GameState.flags = saved
	print("ROUTECHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)


func _id(path: String) -> int:
	var f := path.get_file().get_basename().trim_prefix("chapter")
	var d := ""
	for c in f:
		if c >= "0" and c <= "9":
			d += c
		else:
			break
	return int(d)


func _title_key(path: String) -> String:
	var f := path.get_file().get_basename().trim_prefix("chapter").to_upper()
	var k := "UI_CH%s_TITLE" % f
	return k if tr(k) != k else "UI_CH%d_TITLE" % _id(path)
