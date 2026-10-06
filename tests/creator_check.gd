extends Node
## Yaratıcı Menüsü ("yarat") denetimi (v0.92): bütün bölüm sahneleri menüde; bölümler oynanış sırasıyla (Perde I,
## Perde II, kuşatmanın iki tarafı, dönüş ve final, Sonsuz Kuşatma); kuşatma numaraları her tarafta 13'ten başlayıp
## aralıksız; ana hikâye ve final numaraları sıralı; her kartın başlığı, alt satırı (iç sahne adı değil) ve kapağı var;
## kartlar satırı doldurur (1280 genişlikte en az 5 sütun). Çıktı: CREATORCHECK PASS / FAIL + ayrıntı.

const SECTIONS := ["act1", "act2", "siege_B", "siege_O", "finale", "arena"]


func _ready() -> void:
	var errs: Array[String] = []
	var menu := CreatorMenu.new()
	add_child(menu)
	for i in 4:
		await get_tree().process_frame
	var cards: Array[Dictionary] = menu.cards
	# 1) Bütün bölüm sahneleri menüde
	var used := {}
	var pairs := {}
	for c in cards:
		used[String(c["scene"])] = true
		var key := "%s %s" % [c["scene"], c["setup"]]
		if pairs.has(key):
			errs.append("iki kez: " + key)
		pairs[key] = true
	for f in DirAccess.get_files_at("res://scenes"):
		f = f.trim_suffix(".remap")
		if f.begins_with("chapter") and f.ends_with(".tscn") and not used.has("res://scenes/" + f):
			errs.append("menüde yok: " + f)
	# 2) Bölüm sırası: hiçbir kart önceki bölüme dönmez
	var last := 0
	for c in cards:
		var i := SECTIONS.find(String(c["section"]))
		if i < 0:
			errs.append("bilinmeyen bölüm: %s" % c["section"])
		elif i < last:
			errs.append("sıra bozuk: %s (%s), %s bölümünden sonra" % [c["title"], c["section"], SECTIONS[last]])
		last = maxi(last, i)
	# 3) Ana hikâye: 0'dan 12'ye sıralı (dallar kendi numarasıyla: 10, 10B, 10Z, ...)
	var story: Array[int] = []
	for c in cards:
		if String(c["section"]) in ["act1", "act2"]:
			story.append(String(c["no"]).to_int())
	if story.is_empty() or story[0] != 0 or story[-1] != 12:
		errs.append("ana hikâye 0 ile başlayıp 12 ile bitmeli: %s" % [story])
	for i in range(1, story.size()):
		if story[i] < story[i - 1]:
			errs.append("ana hikâye sırası bozuk: %s" % [story])
			break
	# 4) Kuşatma: her tarafta 13, 14, ... aralıksız; Büro (§) Bizans tarafının başında
	var seen := {}
	for sd: String in ["B", "O"]:
		var want := Siege.NUMBER_BASE + 1
		var first := true
		for c in cards:
			if String(c["section"]) != "siege_" + sd:
				continue
			if String(c["no"]) == "§":
				if sd != "B" or not first:
					errs.append("Büro kartı yanlış yerde (%s)" % sd)
				first = false
				continue
			first = false
			if String(c["no"]).to_int() != want:
				errs.append("kuşatma %s: %s kartının numarası %s, beklenen %d" % [sd, c["title"], c["no"], want])
			want += 1
		seen[sd] = want - Siege.NUMBER_BASE - 1
		if seen[sd] != Siege.chapters(sd).size():
			errs.append("kuşatma %s: %d kart, %d bölüm" % [sd, seen[sd], Siege.chapters(sd).size()])
	# 5) Dönüş ve final: iki tarafın numarası kuşatmanın hemen ardından ("B·O"); gizli bölüm G
	var nb := Siege.chapters("B").size()
	var no := Siege.chapters("O").size()
	var k := 0
	for c in cards:
		if String(c["section"]) != "finale" or String(c["no"]) == "G":
			continue
		var want := "%d·%d" % [Siege.NUMBER_BASE + nb + 1 + k, Siege.NUMBER_BASE + no + 1 + k]
		if String(c["no"]) != want:
			errs.append("final: %s kartının numarası %s, beklenen %s" % [c["title"], c["no"], want])
		k += 1
	# 6) Başlık, alt satır, kapak; çevrilmemiş anahtar ya da iç sahne adı (17, 18b, 33o) yok
	var internal := RegEx.create_from_string("^\\d+[a-zA-Z]?$")
	for c in cards:
		var t := String(c["title"])
		var s := String(c["sub"])
		if t in ["", "?"] or t.begins_with("UI_"):
			errs.append("başlık yok: %s" % c["scene"])
		if s == "" or s.begins_with("UI_") or internal.search(s) != null:
			errs.append("alt satır boş ya da iç ad: %s → '%s'" % [c["scene"], s])
		if String(c["cover"]) == "" or not ResourceLoader.exists(String(c["cover"])):
			errs.append("kapak yok: %s" % c["scene"])
	# 7) Yerleşim: Perde II'nin ilk satırı genişliği doldurur, 1280'de en az 5 sütun
	var row: Array[Control] = []
	var grid: Control = null
	for b: Button in menu._buttons:
		var p := b.get_parent() as Control
		if grid == null and p.get_child_count() > 6:
			grid = p
		if p == grid and is_equal_approx(b.position.y, (grid.get_child(0) as Control).position.y):
			row.append(b)
	var cols := row.size()
	if grid == null or cols == 0:
		errs.append("kart ızgarası bulunamadı")
	else:
		var right := row[-1].position.x + row[-1].size.x
		if grid.size.x >= 1100.0 and cols < 5:
			errs.append("1280 genişlikte %d sütun (en az 5)" % cols)
		if grid.size.x - right > row[0].size.x * 0.5:
			errs.append("satır dolmuyor: sağda %.0f px boş" % (grid.size.x - right))
	if errs.is_empty():
		print("CREATORCHECK PASS cards=%d story=%d siege_B=%d siege_O=%d finale=%d cols=%d" % [cards.size(), story.size(),
			seen.get("B", 0), seen.get("O", 0), k + 1, cols])
	else:
		for e in errs:
			print("CREATORCHECK  · ", e)
		print("CREATORCHECK FAIL (%d)" % errs.size())
	get_tree().quit()
