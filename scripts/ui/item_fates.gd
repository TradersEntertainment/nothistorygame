class_name ItemFates
## Eşyaların Akıbeti (docs/BRANCHING_V2.md §2.3): garajdan çıkan çantanın her eşyası nereye gitti. Defterden
## (GameState.item_log) okunur: her şerit, her avuç, kime verildiği; sonunda 2026'da kimsenin fark etmediği bir iz.
## Final (Bölüm 15) kâğıt olarak gösterir.


## Garajdan çıkan çanta, sonra kazanılanlar ve cebe girenler (sıra korunur).
static func items() -> Array:
	var out: Array = []
	for id in GameState.flags.get("start_bag", []):
		if not id in out:
			out.append(id)
	for r in GameState.item_log():
		if not r[0] in out:
			out.append(r[0])
	for id in GameState.bag:
		if not id in out:
			out.append(id)
	return out


## Eşyanın yolculuğu: {"steps": [kullanım...], "end": "kept"|"given"|"empty"|"lost", "last": son kullanım}
static func journey(item: String) -> Dictionary:
	var steps: Array = []
	var last_kind := ""
	for r in GameState.item_log():
		if r[0] != item:
			continue
		var kind: String = r[3]
		# Kazanılan da bir adım: cebe giren fes ("Haliç'te bulundu"), kapıda geri verilen küp, yaralı Giustiniani'nin
		# avucundan dönen çakmak. Son adım 2026 izini seçer.
		if kind in ["spend", "give", "use", "lose", "gain"]:
			steps.append(str(r[1]))
		if kind != "gain":
			last_kind = kind
		else:
			last_kind = ""
	var end := "kept"
	if not GameState.holds(item):
		if GameState.given_to(item) != "":
			end = "given"
		elif last_kind == "lose":
			end = "lost"
		else:
			end = "empty"
	return {"steps": steps, "end": end, "last": steps[-1] if not steps.is_empty() else ""}


## Bir eşyanın satırı: "Koli Bandı — Hasan ile Hüseyin... → Urban'ın topunun çatlağı → ... (bitti)"
static func line(item: String) -> String:
	var j := journey(item)
	var parts: Array = []
	for u in j["steps"]:
		# Aynı yere art arda giden şarjlar tek adım (iki bardak Lütfi'ye: bir kez yazılır)
		var t: String = TranslationServer.translate("USE_" + str(u).to_upper())
		if parts.is_empty() or parts[-1] != t:
			parts.append(t)
	var body: String = " → ".join(parts) if not parts.is_empty() else String(TranslationServer.translate("FATE_UNUSED"))
	# Cepte duran (Misafir İzni, yedek fes) "çantada" değil "cebinde" kalır
	var end_key := "FATE_END_POCKET" if j["end"] == "kept" and GameState.in_pocket(item) else "FATE_END_" + str(j["end"]).to_upper()
	return "%s — %s%s" % [TranslationServer.translate(Items.name_key(item)), body, TranslationServer.translate(end_key)]


## 2026'daki iz: önce son kullanıma özgü, yoksa akıbete göre ("" = yok).
static func trace(item: String) -> String:
	var j := journey(item)
	var up := item.to_upper()
	for k in ["FATE26_%s_%s" % [up, str(j["last"]).to_upper()], "FATE26_%s_%s" % [up, str(j["end"]).to_upper()]]:
		if j["last"] == "" and k.ends_with("_"):
			continue
		if TranslationServer.translate(k) != k:
			return TranslationServer.translate(k)
	return ""


## Bölüm 15'in kâğıdı için satırlar ([metin, boyut, renk, tür]).
static func rows() -> Array:
	var out: Array = [["UI_FATES_TITLE", 26, Color("2a2420"), "title"], ["UI_FATES_SUB", 14, Color("5a4a3a"), "rule"]]
	for id in items():
		out.append([line(id), 16, Color("2a2420"), ""])
		var t := trace(id)
		if t != "":
			out.append(["   2026 · " + t, 14, Color("6a4a2a"), ""])
	return out
