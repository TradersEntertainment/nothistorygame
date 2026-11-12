extends Node
## Sürgünün yol hesabı (scripts/level/huzur.gd, scripts/siege.gd, docs/SENARYO_KURAL_CIGNEME.md §6): sahne açmadan
##   * her hükümdarlı kuşatma sayfası için sürgünün hedefi: karşı tarafın SONRAKİ ilk sayfası (aynı tarih çizgisi)
##   * kuşatmadan önce (34o) bekleyen sürgün: 35o'ya geçerken yürüyüş yok, iki taraflı günlere (28o) geçerken yürüyüş,
##     hedef 42b
##   * sürgünlü yol: bölüm listesi iki tarafın sayfalarını tek sırada sayar, numaralar ardışık, eski taraf sayfası kalır
##   * Büro (Perde II'den bekleyen sürgün): taraf zorlanır; iki hükümdar da: taraf serbest, ban
##   * hüküm: kendi hükümdarı / karşı hükümdar / üçüncü kez
## Sonuç: HUZURCHECK PASS/FAIL.

const Huzur := preload("res://scripts/level/huzur.gd")
var ok := true


func _fail(msg: String) -> void:
	printerr("HUZURCHECK " + msg)
	ok = false


func _ready() -> void:
	GameState.autotest = true
	# 1. Hedefler
	var want := {[34, "B"]: 42, [28, "B"]: 29, [32, "B"]: 26, [23, "O"]: 24, [25, "O"]: 32, [26, "O"]: 38, [30, "O"]: 21,
		[30, "B"]: 21, [25, "B"]: 26, [26, "B"]: 27}
	for k: Array in want:
		var got := Huzur.next_on(int(k[0]), String(k[1]))
		if got != int(want[k]):
			_fail("hedef %d -> %s: beklenen %d, gelen %d" % [k[0], k[1], want[k], got])
	# 2. Bekleyen sürgün (34o): 35o'ya geçerken yok, 28o'ya geçerken var
	GameState.flags = {"siege_side": "O", "siege_bureau_done": true,
		"surgun_pending": {"from": "O", "ruler": "fatih", "ch": 34}, "surgun_n": 1}
	var p1 := Siege.next_path(34)
	if not p1.ends_with("chapter35o.tscn"):
		_fail("34o sonrası beklenen 35o, gelen %s" % p1)
	var p2 := Siege.next_path(35)
	var walk: Dictionary = GameState.flags.get("surgun_walk", {})
	if not p2.ends_with("chapter8s.tscn") or int(walk.get("to_ch", 0)) != 42 or String(walk.get("to", "")) != "B":
		_fail("35o sonrası beklenen sürgün (42b), gelen %s %s" % [p2, str(walk)])
	if int(GameState.flags.get("surgun_n", 0)) != 1:
		_fail("bekleyen sürgün iki kez sayıldı: %d" % int(GameState.flags.get("surgun_n", 0)))
	# 3. Sürgünlü yol: 28o'dan Bizans'a; liste ve numaralar
	GameState.flags = {"siege_side": "B", "siege_bureau_done": true,
		"surgun_log": [{"ch": 28, "from": "O", "to": "B", "next": 29}]}
	var route := Siege.chapters()
	var exp_route: Array[int] = [33, 34, 35, 28, 29, 17, 18, 19, 20, 30, 21, 22, 23, 24, 25, 26, 27]
	if route != exp_route:
		_fail("yol: %s" % str(route))
	var nums: Array = []
	for ch: int in route:
		nums.append(Siege.number_of(ch))
	for i in nums.size():
		if int(nums[i]) != Siege.NUMBER_BASE + i + 1:
			_fail("numara sırası: %s" % str(nums))
			break
	if Siege.number("res://scenes/chapter28o.tscn") != Siege.number_of(28) or Siege.number("res://scenes/chapter29.tscn") != Siege.number_of(29):
		_fail("sahne yolundan numara: 28o=%d 29=%d" % [Siege.number("res://scenes/chapter28o.tscn"), Siege.number("res://scenes/chapter29.tscn")])
	if GameState.display_no(28) == "—":
		_fail("eski tarafın sayfası listede '—' görünüyor")
	if Siege.side_at(28) != "O" or Siege.side_at(29) != "B":
		_fail("side_at: 28=%s 29=%s" % [Siege.side_at(28), Siege.side_at(29)])
	# Sürgünsüz oyunda hiçbir şey değişmez
	GameState.flags = {"siege_side": "B"}
	if Siege.chapters() != Siege.chapters("B"):
		_fail("sürgünsüz yol değişti")
	# 4. Hüküm (bölüm sahnesi gerekmez: düğüm sahnesiz kurulur)
	var hz: Node = Huzur.new()
	add_child(hz)
	var cases := [[28, "O", "O", {}, "exile"], [34, "O", "O", {}, "pending"], [12, "O", "B", {}, "pending"],
		[26, "B", "O", {}, "enemy"], [30, "O", "B", {}, "enemy"], [25, "B", "B", {"surgun_n": 2}, "ban"],
		[25, "B", "B", {"surgun_n": 1}, "exile"], [6, "B", "B", {"huzur_ban": true}, "ban"]]
	for c: Array in cases:
		GameState.current_chapter = int(c[0])
		GameState.flags = {"siege_side": c[1], "siege_bureau_done": true}
		GameState.flags.merge(c[3] as Dictionary)
		var m: String = hz._verdict_mode(String(c[2]))
		if m != String(c[4]):
			_fail("hüküm bölüm %d taraf %s hükümdar %s: beklenen %s, gelen %s" % [c[0], c[1], c[2], c[4], m])
	# 5. Büro: Perde II'den bekleyen sürgün tarafı zorlar; iki hükümdar da: serbest + ban
	var hud := Hud.new()
	add_child(hud)
	GameState.flags = {"surgun_pending": {"from": "O", "ruler": "fatih", "ch": 12}, "surgun_n": 1}
	var forced: String = await Huzur.bureau_side(hud)
	if forced != "B" or GameState.flags.has("surgun_pending") or (GameState.flags.get("surgun_log", []) as Array).is_empty():
		_fail("Büro (Fatih notu): beklenen B, gelen '%s' %s" % [forced, str(GameState.flags)])
	if Siege.has_route():
		_fail("Büro'daki sürgün kuşatmanın yolunu bölmemeli")
	GameState.flags = {"surgun_pending": {"from": "B", "ruler": "emperor", "ch": 6}, "surgun_pending_both": true, "surgun_n": 2}
	forced = await Huzur.bureau_side(hud)
	if forced != "" or not GameState.flags.get("huzur_ban", false):
		_fail("Büro (iki hükümdar): beklenen serbest + ban, gelen '%s' %s" % [forced, str(GameState.flags)])
	# 6. Akıbet (Bölüm 15, İnsanların Akıbeti): sürgün satırı
	GameState.flags = {"siege_side": "B", "surgun_log": [{"ch": 28, "from": "O", "to": "B", "next": 29}], "huzur_ban": true}
	var found := false
	for pp: Dictionary in PeopleFates.people():
		if pp["name"] == "PF_SURGUN":
			found = "PF_SURGUN_O" in pp["steps"] and "PF_SURGUN_BAN" in pp["steps"]
			print("HUZURCHECK akıbet: " + PeopleFates.line(pp))
	if not found:
		_fail("akıbet sayfasında sürgün satırı yok")
	GameState.flags = {"siege_side": "B"}
	for pp: Dictionary in PeopleFates.people():
		if pp["name"] == "PF_SURGUN":
			_fail("sürgünsüz oyunda akıbet satırı çıktı")
	print("HUZURCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
