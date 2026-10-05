class_name PeopleFates
## İnsanların Akıbeti (docs/BRANCHING_V2.md §6.1, M5): Tolga'nın yolunu değiştirdiği insanlar. Eşyaların Akıbeti'nin
## kardeşi; Bölüm 15'te ondan sonra kâğıt olarak gösterilir. Yalnız Tolga yüzünden bir şeyi değişen kişi yazılır:
## 1453'te neler oldu (adımlar oynanış sırasıyla, " · " ile) ve 2026'da kimsenin fark etmediği bir iz. Her adım oyunda
## gerçekten söylenen ya da görülen bir şeydir: bayraklardan, bölüm sonuçlarından ve eşya defterinden okunur. Eşyanın
## kendi izi Eşyaların Akıbeti'ndedir; buradaki izler kişinin izidir.

## Bir kâğıda sığan kişi sayısı (fazlası ikinci kâğıda geçer)
const PER_PAGE := 6


## Kişiler, ilk karşılaşma sırasıyla: {"name": ad anahtarı, "steps": [adım anahtarı ya da metni...], "trace": 2026 izi
## anahtarı ("" olabilir)}. Adımı olmayan kişi yazılmaz.
static func people() -> Array:
	var f := GameState.flags
	var o := GameState.chapter_outcomes
	var byz := Siege.side() == "B"
	var out: Array = []

	# Hasan ile Hüseyin (4a'nın nöbetçileri). Osmanlı tarafında 18'de fıçıları tutarlar, 22o'da Hüseyin kuleden usta indirir.
	var friends: bool = f.get("guards_like_tolga", false)
	var fez := GameState.given_to("spare_fez") == "huseyin"
	var tw: Array = []
	if friends:
		tw.append("PF_TWINS_FRIENDS")
	if fez:
		tw.append("PF_TWINS_FEZ")
	if f.get("huseyin_vouched", false):
		tw.append("PF_TWINS_VOUCH")
	if friends and not byz and str(o.get(18, "")).begins_with("18."):
		tw.append("PF_TWINS_BRIDGE")
	if f.get("huseyin_carried", false):
		tw.append("PF_TWINS_TOWER")
	_add(out, "PF_TWINS", tw, "PF26_TWINS_FEZ" if fez else "PF26_TWINS")

	# Aşçıbaşı Kadri (6a, 10Z; Osmanlı tarafında 17o, 24o, 26o)
	var o6 := str(o.get(6, ""))
	var o10 := str(o.get(10, ""))
	var menu: Array = f.get("ch10z_menu", [])
	var kd: Array = []
	if o6 == "6a.1":
		kd.append("PF_KADRI_APPRENTICE")
	if _logged("thermos", "thermos_kadri_6a"):
		kd.append("PF_KADRI_KAFTAN")
	if o10 == "10Z.1":
		kd.append("PF_KADRI_FEAST")
	elif o10 == "10Z.2":
		kd.append("PF_KADRI_FIRE")
	if not byz:
		if o.has(17) and Siege.kadri_ally():
			kd.append("PF_KADRI_BUCKETS")
		if o.has(24) and not menu.is_empty():
			kd.append("PF_KADRI_SOUP_AGAIN" if o10 == "10Z.2" else "PF_KADRI_SOUP")
		if o.has(26) and Siege.kadri_ally():
			kd.append("PF_KADRI_WATER")
	_add(out, "PF_KADRI", kd, "PF26_KADRI_FIRE" if o10 == "10Z.2" else "PF26_KADRI")

	# Usta Urban (6a, 10B; Osmanlı tarafında 20o)
	var bang: bool = f.get("big_bang", false)
	var name_i := clampi(int(f.get("cannon_name", 0)), 0, 3) + 1 if f.has("cannon_name") else 0
	var ur: Array = []
	if _logged("lighter", "lighter_urban_6a"):
		ur.append("PF_URBAN_LIGHTER")
	if f.get("cannon_taped", false):
		ur.append("PF_URBAN_TAPE")
	if name_i > 0:
		ur.append("PF_URBAN_NAME_%d" % name_i)
	if bang:
		ur.append("PF_URBAN_BANG")
	if not byz and o.has(20):
		if f.get("gun_tape_20o", false):
			ur.append("PF_URBAN_TAPE_20O")
		elif int(f.get("gun_cracks", 0)) >= 2:
			ur.append("PF_URBAN_CRACKS")
	var ur_trace := "PF26_URBAN_BANG" if bang else ("PF26_URBAN_NAME_%d" % name_i if name_i > 0 else "PF26_URBAN")
	_add(out, "PF_URBAN", ur, ur_trace)

	# Niko (surların tercümanı; Bizans tarafında 17, 20, 24)
	var niko: bool = f.get("niko_friend", false)
	var chain: bool = f.get("chain_watch", false)
	var nk: Array = []
	if niko:
		nk.append("PF_NIKO_FRIEND")
	if chain:
		nk.append("PF_NIKO_CHAIN")
	if byz:
		if chain and o.has(17):
			nk.append("PF_NIKO_LANTERN")
		if niko and o.has(20):
			nk.append("PF_NIKO_BREACH")
		if niko and o.has(24):
			nk.append("PF_NIKO_KID" if f.get("siege_kid", false) else "PF_NIKO_ICON")
	_add(out, "PF_NIKO", nk, "PF26_NIKO")

	# Giovanni Giustiniani: yalnız Tolga'dan bir şey aldıysa ya da uyarıldıysa (yarası tarihtir)
	var held: bool = f.get("siege_held", false)
	var dawn_warned: bool = f.get("dawn_warned", false)
	var gs: Array = []
	if _logged("lighter", "lighter_giust_6b"):
		gs.append("PF_GIUST_LIGHTER")
	if _logged("book", "book_giust_6b"):
		gs.append("PF_GIUST_BOOK")
	if f.get("giust_warned", false):
		gs.append("PF_GIUST_WARNED")
	if f.get("giust_armored", false):
		gs.append("PF_GIUST_BOX")
	if byz and o.has(26) and (dawn_warned or not gs.is_empty()):
		if held:
			gs.append("PF_GIUST_DUCK" if dawn_warned else "PF_GIUST_BOXHIT")
		else:
			gs.append("PF_GIUST_WARN_HURT" if dawn_warned else "PF_GIUST_HURT")
			if _logged("lighter", "giust_back_26"):
				gs.append("PF_GIUST_LIGHTER_BACK")
	var gs_trace := "PF26_GIUST"
	if held:
		gs_trace = "PF26_GIUST_HELD" if dawn_warned else "PF26_GIUST_BOX"
	_add(out, "PF_GIUST", gs, gs_trace)

	# Boğazkesen'in Cenevizlisi (33o, Ağustos 1452; 27'de Galata'da)
	if f.has("toll_gift"):
		var honest := str(f.get("toll_gift", "")) == "refuse"
		var gn: Array = ["PF_GENOESE_FOUND" if f.get("toll_hidden", false) else "PF_GENOESE_MISSED"]
		gn.append("PF_GENOESE_REFUSE" if honest else "PF_GENOESE_TAKE")
		if o.has(27):
			gn.append("PF_GENOESE_STAYED" if honest else "PF_GENOESE_LEFT")
		_add(out, "PF_GENOESE", gn, "PF26_GENOESE_HONEST" if honest else "PF26_GENOESE_WINE")

	# Haliç'in denizcileri (17; biri 19'da brigantinin tayfasında)
	var saved := int(f.get("siege_saved", 0))
	var sl: Array = []
	if saved > 0:
		sl.append(TranslationServer.translate("PF_SAILORS_SAVED") % saved)
		if byz and o.has(19):
			sl.append("PF_SAILORS_CREW")
	_add(out, "PF_SAILORS", sl, "PF26_SAILORS")

	# Topçubaşı Ali (17o, 32o)
	var al: Array = []
	if f.get("siege_gun_hit", false):
		al.append("PF_ALI_HIT")
		if not byz and o.has(32):
			al.append("PF_ALI_MARKSMAN")
	_add(out, "PF_ALI", al, "PF26_ALI")

	# Brigantinin kaptanı (19; 27'de Galata iskelesinde)
	if f.has("brig_vote"):
		var back := int(f.get("brig_vote", 0)) == 0
		var br: Array = []
		if f.get("brig_tezkire", false):
			br.append("PF_BRIG_TEZKIRE")
		br.append("PF_BRIG_RETURN" if back else "PF_BRIG_FLEE")
		var br_trace := "PF26_BRIG"
		if o.has(27):
			br.append("PF_BRIG_STAYED" if back else "PF_BRIG_SAILED")
			br_trace = "PF26_BRIG_STAYED" if back else "PF26_BRIG_SAILED"
		_add(out, "PF_BRIG", br, br_trace)

	# Lağımcıbaşı Kasım (21; 26'da zindandan çıkar)
	var talk := str(f.get("siege21_talk", ""))
	var ks: Array = []
	if talk == "talk":
		ks.append("PF_KASIM_TALK")
	elif talk == "iron":
		ks.append("PF_KASIM_IRON")
	if str(f.get("isidore_by", "")) == "kasim":
		ks.append("PF_KASIM_FREE")
	_add(out, "PF_KASIM", ks, "PF26_KASIM_IRON" if talk == "iron" else "PF26_KASIM")

	# Elçi İsmail Hamza (23)
	var card: bool = f.get("ismail_card", false)
	var ism: Array = []
	if f.get("letter_delivered", false) and o.has(12) and o.has(23):
		ism.append("PF_ISMAIL_LETTER")
	if card:
		ism.append("PF_ISMAIL_CARD")
	_add(out, "PF_ISMAIL", ism, "PF26_ISMAIL" if card else "")

	# Venedikli Marco (24; 25'te son ayinde annesiyle)
	var mc: Array = []
	if f.get("siege_kid", false):
		mc.append("PF_MARCO_EAVES")
		if o.has(25) and f.get("siege_candle", false):
			mc.append("PF_MARCO_CANDLE")
	_add(out, "PF_MARCO", mc, "PF26_MARCO")

	# Kardinal Isidoros: yalnız esir kafilesinden çıktıysa (26)
	if f.get("isidore_freed", false):
		var by_kasim := str(f.get("isidore_by", "")) == "kasim"
		var isi: Array = []
		if f.get("met_isidore", false):
			isi.append("PF_ISIDORE_LITURGY")
		isi.append("PF_ISIDORE_KASIM" if by_kasim else "PF_ISIDORE_TEZKIRE")
		if o.has(27):
			isi.append("PF_ISIDORE_ROME")
		_add(out, "PF_ISIDORE", isi, "PF26_ISIDORE_KASIM" if by_kasim else "PF26_ISIDORE")
	return out


static func _add(out: Array, name_key: String, steps: Array, trace: String) -> void:
	if steps.is_empty():
		return
	out.append({"name": name_key, "steps": steps, "trace": trace})


## Defterde bu eşya bu kullanımla geçiyor mu (verildi, harcandı ya da geri geldi; sonradan dönse bile).
static func _logged(item: String, use: String) -> bool:
	for r in GameState.item_log():
		if r[0] == item and str(r[1]) == use:
			return true
	return false


## Bir kişinin satırı: "Lağımcıbaşı Kasım — 21'de sorguda sana güvendi · 26'da ..."
static func line(p: Dictionary) -> String:
	var parts: Array = []
	for s: String in p["steps"]:
		parts.append(TranslationServer.translate(s))
	return "%s — %s" % [TranslationServer.translate(p["name"]), " · ".join(parts)]


## Kâğıtlar (her biri Bölüm 15'in _paper satırları): kişi sayısı PER_PAGE'i aşarsa ikinci kâğıda geçer. Kimse yoksa boş.
static func pages() -> Array:
	var ps := people()
	var out: Array = []
	var i := 0
	while i < ps.size():
		var rows: Array = [["UI_PEOPLE_TITLE", 26, Color("2a2420"), "title"], ["UI_PEOPLE_SUB", 14, Color("5a4a3a"), "rule"]]
		for p: Dictionary in ps.slice(i, i + PER_PAGE):
			rows.append([line(p), 16, Color("2a2420"), ""])
			if str(p["trace"]) != "":
				rows.append(["   2026 · " + TranslationServer.translate(p["trace"]), 14, Color("6a4a2a"), ""])
		i += PER_PAGE
		if i < ps.size():
			rows.append(["UI_PEOPLE_MORE", 13, Color("5a4a3a"), "sign"])
		out.append(rows)
	return out
