class_name SideEvents
## Bölüm betiklerine dokunmadan çalışan küçük yan içerik:
##   "npc:<id>"  yan karakter: her E'de sıradaki cümle (NPC_<ID>_1..n), eşya gösterilince REACT_<ID>_*.
##               Hattat son cümlesini söyleyince "calligraphy" bayrağı (görev).
##               Venedikli çocuk: kedi bulununca teşekkür cümlelerine geçer.
##   "ev:<id>"   tek seferlik olay: Konstantin Sütunu'nda dilek ("column_wish").
## Player, bu önekli kimlikleri kendisi yakalar (Player._input) ve buraya yollar.

const SPEAKERS := {"calligrapher": "SPK_CALLIGRAPHER", "painter": "SPK_PAINTER", "kid": "SPK_KID"}

## Küçük sahneler ("ev:<id>" ile başlar, oyunu durdurmaz): [konuşmacı, metin anahtarı]. Konuşan karakter
## (meta "spk" ile işaretli Person) el kol oynatır. İlk izleyişte bayrak açılır (yan görev).
const SCENES := {
	# Bizans'ta konsey: Notaras, Kardinal Isidoros, Venedik baylosu. Notaras'ın sözü tarihîdir.
	"council": {"flag": "council_heard", "lines": [
		["SPK_NOTARAS", "EV_COUNCIL_1"], ["SPK_ISIDORE", "EV_COUNCIL_2"], ["SPK_BAILO", "EV_COUNCIL_3"],
		["SPK_NOTARAS", "EV_COUNCIL_4"], ["SPK_TOLGA", "EV_COUNCIL_5"], ["SPK_ISIDORE", "EV_COUNCIL_6"],
		["SPK_TOLGA", "EV_COUNCIL_7"], ["SPK_BAILO", "EV_COUNCIL_8"]]},
	# Ordugâhta Macar elçisi: rivayette topçulara nişan tavsiyesi verir. Burada Osmanlı topçuları işlerini
	# çoktan bilmektedir; gülünen, geç kalan danışmandır.
	"envoy": {"flag": "envoy_heard", "lines": [
		["SPK_HUNGARIAN", "EV_ENVOY_1"], ["SPK_SARUCA", "EV_ENVOY_2"], ["SPK_HUNGARIAN", "EV_ENVOY_3"],
		["SPK_SARUCA", "EV_ENVOY_4"], ["SPK_URBAN", "EV_ENVOY_5"], ["SPK_HUNGARIAN", "EV_ENVOY_6"], ["SPK_TOLGA", "EV_ENVOY_7"]]},
}
static var _playing := false


## Kalabalık: sahnenin yerine göre (Bizans, Galata, ordugâh) konuşan ve replik havuzu.
static func crowd_set(tree: SceneTree) -> String:
	var sc := tree.current_scene
	if sc == null:
		return "BYZ"
	for c in sc.get_children():
		if c is ByzCity:
			return "BYZ"
		if c is Galata:
			return "GAL"
		if c is CampDay or c is Camp or c is OtagHall:
			return "CAMP"
	return "BYZ"


const CROWD_SPEAKER := {"BYZ": "SPK_TOWNSMAN", "GAL": "SPK_GENOESE", "CAMP": "SPK_SOLDIER"}


static func prompt(id: String) -> String:
	if id == "npc:crowd":
		return TranslationServer.translate("UI_PROMPT_TALK_TO") % TranslationServer.translate(street_label())
	if id.begins_with("npc:"):
		var who := id.trim_prefix("npc:")
		return TranslationServer.translate("UI_PROMPT_TALK_TO") % TranslationServer.translate(SPEAKERS.get(who, ""))
	return TranslationServer.translate("UI_PROMPT_EV_" + id.trim_prefix("ev:").to_upper())


static func _lines(prefix: String) -> int:
	var n := 0
	while TranslationServer.translate("%s_%d" % [prefix, n + 1]) != "%s_%d" % [prefix, n + 1]:
		n += 1
	return n


static func interact(id: String, hud: Hud) -> void:
	if hud == null:
		return
	if id == "npc:crowd":
		if street_talk(hud):
			return
		var cs := crowd_set(hud.get_tree())
		var cprefix := "NPC_CROWD_" + cs
		var cn := _lines(cprefix)
		if cn == 0:
			return
		var cst: Dictionary = GameState.flags.get("npc_talk", {})
		var ci: int = int(cst.get(cprefix, randi() % cn))
		var ckey := "%s_%d" % [cprefix, ci % cn + 1]
		cst[cprefix] = ci + 1
		GameState.flags["npc_talk"] = cst
		# Sokaktaki kişi bellidir: söz onundur (adı rol etiketi, portresi kendi yüzü)
		var fw := street_focus(hud.get_tree())
		if fw != null and not street_story(fw):
			hud.street_bark(fw, street_role(fw, street_ctx(hud.get_tree())), ckey, 4.5, true)
			return
		hud.bark(CROWD_SPEAKER[cs], ckey, 4.5)
		var who_p := Person.nearest(hud.get_tree(), _focus_point(hud), 2.5)
		if who_p:
			who_p.talking = true
			hud.get_tree().create_timer(2.5).timeout.connect(func():
				if is_instance_valid(who_p):
					who_p.talking = false)
		return
	if id.begins_with("npc:"):
		var who := id.trim_prefix("npc:")
		var spk: String = SPEAKERS.get(who, "SPK_TOLGA")
		var prefix := "NPC_" + who.to_upper()
		if who == "kid" and GameState.flags.get("cat_returned", false):
			prefix = "NPC_KID_THANKS"
		var n := _lines(prefix)
		if n == 0:
			return
		var st: Dictionary = GameState.flags.get("npc_talk", {})
		var i: int = int(st.get(prefix, 0))
		hud.bark(spk, "%s_%d" % [prefix, i % n + 1], 4.5)
		st[prefix] = i + 1
		GameState.flags["npc_talk"] = st
		if who == "calligrapher" and i + 1 >= n:
			GameState.flags["calligraphy"] = true
		var p := Person.nearest(hud.get_tree(), _focus_point(hud), 2.5)
		if p:
			p.talking = true
			hud.get_tree().create_timer(2.5).timeout.connect(func():
				if is_instance_valid(p):
					p.talking = false)
		return
	var ev := id.trim_prefix("ev:")
	if SCENES.has(ev):
		_play_scene(ev, hud)
		return
	match ev:
		"column":
			if not GameState.flags.get("column_wish", false):
				GameState.flags["column_wish"] = true
				Audio.sfx("ui_confirm", -6.0)
			hud.bark("SPK_TOLGA", "D_EV_COLUMN", 5.0)
		"omphalion", "weeping_column":
			var fl := "aya_" + ev
			if not GameState.flags.get(fl, false):
				GameState.flags[fl] = true
				Audio.sfx("ui_confirm", -8.0)
			hud.bark("SPK_TOLGA", "D_EV_" + ev.to_upper(), 5.5)


static func _focus_point(hud: Hud) -> Vector3:
	var sc := hud.get_tree().current_scene
	var pl = sc.get("player") if sc else null
	if pl is Player:
		var p := pl as Player
		return p.global_position - p.global_transform.basis.z * 1.5 + Vector3(0, 1.0, 0)
	return Vector3.ZERO


static func _play_scene(ev: String, hud: Hud) -> void:
	if _playing:
		return
	_playing = true
	var sc: Dictionary = SCENES[ev]
	var tree := hud.get_tree()
	var people := {}
	for p in tree.get_nodes_in_group("persons"):
		if (p as Node).has_meta("spk"):
			people[(p as Node).get_meta("spk")] = p
	for line in sc["lines"]:
		var spk: String = line[0]
		var key: String = line[1]
		var secs := clampf(TranslationServer.translate(key).length() * 0.055 + 1.2, 2.4, 6.5)
		var vs := hud.voice_stream(key)
		if vs:
			secs = maxf(secs, GameState.voice_len(vs) + 0.4)
		if GameState.autotest:
			secs = 0.05
		var who: Person = people.get(spk)
		if who:
			who.talking = true
		hud.bark(spk, key, secs)
		await tree.create_timer(secs).timeout
		if is_instance_valid(who):
			who.talking = false
	GameState.flags[sc["flag"]] = true
	_playing = false


# ---------------------------------------------------------------- sokak insanı: herkesle konuşma
## Sokakta, ordugâhta, surun dibinde gördüğün her kişi (yoldan geçen sivil, devriye, asker, satıcı, hamal...) "E: Konuş"
## ile konuşur. Rol (BYZSOL, JAN, WOMB...) kişinin "street_role" işaretinden (CityLife'ın gövdeleri, StreetEye koyar) ya da
## görünüşünden (şapka, etek, çocuk, cüppe, zırh) çıkarılır. Replik havuzu: DST_<ROL>_IDLE_n; bağlama göre fesli
## (DST_<ROL>_FEZ_n), gece (NIGHT), Galata (GAL), fetih sonrası (CONQ: Bizanslılar kısa ve şakasız). Aynı kişiye 3., 4.
## kez gidince DST_<GRUP>_AGAIN_1/_2, sonra hep DST_<GRUP>_AGAIN (Stubborn "_AGAIN"i sayar). Tolga ara sıra kısa bir
## cevap verir (DST_T_REPLY_n). Hikâye karakterleri (yüzü tasarlanmış, "spk" işaretli) rol almaz: eski davranış.
## Kuşatma öncesi bölümlerde (1452 Edirne/Boğazkesen) ve rolü çıkmayan kişide eski kalabalık repliği (NPC_CROWD_*) sürer.

const STREET_SPK := {"BYZSOL": "SPK_CITY_GUARD", "GENMERC": "SPK_GENOESE", "OSMSOL": "SPK_SOLDIER",
	"JAN": "SPK_JANISSARY", "AZAP": "SPK_AZAP", "VENDB": "SPK_TOWNSMAN", "VENDO": "SPK_SUTLER", "PORTER": "SPK_PORTER",
	"WORKER": "SPK_WORKER", "PRIEST": "SPK_PRIEST", "MONK": "SPK_STREET_MONK", "DERV": "SPK_DERVISH",
	"WOMB": "SPK_WOMAN_BYZ", "CHILDB": "SPK_CHILD_BYZ", "FISHER": "SPK_FISHMONGER", "TOWNB": "SPK_TOWNSMAN",
	"GAL": "SPK_GENOESE", "CIVB": "SPK_TOWNSMAN", "VEND": "SPK_TOWNSMAN"}
## Rolün tarafı: B Bizans, O Osmanlı, G Ceneviz (Galata)
const STREET_SIDE := {"BYZSOL": "B", "GENMERC": "G", "OSMSOL": "O", "JAN": "O", "AZAP": "O", "VENDB": "B", "VENDO": "O",
	"PORTER": "B", "WORKER": "O", "PRIEST": "B", "MONK": "B", "DERV": "O", "WOMB": "B", "CHILDB": "B", "FISHER": "B",
	"TOWNB": "B", "GAL": "G"}
## Tırmanan cevap grubu
const STREET_AGAIN := {"BYZSOL": "BYZSOL", "GENMERC": "CIVB", "OSMSOL": "OSMSOL", "JAN": "JAN", "AZAP": "OSMSOL",
	"VENDB": "VEND", "VENDO": "VEND", "PORTER": "CIVB", "WORKER": "OSMSOL", "PRIEST": "PRIEST", "MONK": "PRIEST",
	"DERV": "DERV", "WOMB": "WOMB", "CHILDB": "CHILDB", "FISHER": "CIVB", "TOWNB": "CIVB", "GAL": "CIVB"}
## İstemdeki ad (UI_STREET_<..>); yoksa "yoldan geçen"
const STREET_LABEL := {"BYZSOL": "BYZSOL", "GENMERC": "GENMERC", "OSMSOL": "OSMSOL", "JAN": "JAN", "AZAP": "AZAP",
	"VENDB": "VEND", "VENDO": "VEND", "PORTER": "PORTER", "WORKER": "WORKER", "PRIEST": "PRIEST", "MONK": "MONK",
	"DERV": "DERV", "WOMB": "WOMAN", "CHILDB": "CHILD", "FISHER": "FISHER"}
## Bölümler: fetih sonrası (şehrin halkı susar), kuşatmadan önce (eski kalabalık repliği), 22 Nisan'dan önce (gemiler
## henüz karadan yürümedi: işçinin kızak sözü yok)
const STREET_CONQ := ["26", "27", "31o", "39o"]
const STREET_PRE := ["33o", "34o", "35o"]
const STREET_BEFORE_22 := ["2", "28o", "29", "29o", "36b", "37o", "41o", "42b"]
## Tuhaflık tepkileri, nöbetçi uyarısı, fısıltı, çocuk taklidi: [konuşmacı, anahtar] (StreetEye seçer; ses haritası
## konuşmacıyı buradan alır)
const STREET_EVENT_LINES := [
	["SPK_TOWNSMAN", "DST_ODD_JUMP_B_1"], ["SPK_CITY_GUARD", "DST_ODD_JUMP_B_2"], ["SPK_SOLDIER", "DST_ODD_JUMP_O_1"],
	["SPK_AZAP", "DST_ODD_JUMP_O_2"], ["SPK_TOWNSMAN", "DST_ODD_BUMP_B_1"], ["SPK_PORTER", "DST_ODD_BUMP_B_2"],
	["SPK_SOLDIER", "DST_ODD_BUMP_O_1"], ["SPK_WORKER", "DST_ODD_BUMP_O_2"], ["SPK_CITY_GUARD", "DST_ODD_PHONE_B_1"],
	["SPK_WOMAN_BYZ", "DST_ODD_PHONE_B_2"], ["SPK_SOLDIER", "DST_ODD_PHONE_O_1"], ["SPK_AZAP", "DST_ODD_PHONE_O_2"],
	["SPK_TOWNSMAN", "DST_ODD_SELFIE_B_1"], ["SPK_WOMAN_BYZ", "DST_ODD_SELFIE_B_2"],
	["SPK_SOLDIER", "DST_ODD_SELFIE_O_1"], ["SPK_AZAP", "DST_ODD_SELFIE_O_2"], ["SPK_TOWNSMAN", "DST_ODD_STARE_B_1"],
	["SPK_WOMAN_BYZ", "DST_ODD_STARE_B_2"], ["SPK_SOLDIER", "DST_ODD_STARE_O_1"],
	["SPK_JANISSARY", "DST_ODD_STARE_O_2"], ["SPK_TOWNSMAN", "DST_ODD_SPIN_B_1"], ["SPK_SOLDIER", "DST_ODD_SPIN_O_1"],
	["SPK_AZAP", "DST_ODD_SPIN_O_2"], ["SPK_TOWNSMAN", "DST_ODD_CLIMB_B_1"], ["SPK_WOMAN_BYZ", "DST_ODD_CLIMB_B_2"],
	["SPK_SOLDIER", "DST_ODD_CLIMB_O_1"], ["SPK_WORKER", "DST_ODD_CLIMB_O_2"], ["SPK_CITY_GUARD", "DST_ODD_SWORD_B_1"],
	["SPK_JANISSARY", "DST_ODD_SWORD_O_1"], ["SPK_SOLDIER", "DST_ODD_SWORD_O_2"], ["SPK_TOWNSMAN", "DST_ODD_FEZ_B_1"],
	["SPK_SOLDIER", "DST_ODD_FEZ_O_1"], ["SPK_WOMAN_BYZ", "DST_ODD_COLOGNE_B_1"],
	["SPK_SOLDIER", "DST_ODD_COLOGNE_O_1"], ["SPK_PRIEST", "DST_ODD_LIGHTER_B_1"],
	["SPK_JANISSARY", "DST_ODD_LIGHTER_O_1"], ["SPK_TOWNSMAN", "DST_ODD_CHICK_B_1"],
	["SPK_SOLDIER", "DST_ODD_CHICK_O_1"], ["SPK_TOWNSMAN", "DST_ODD_CUBE_B_1"], ["SPK_SOLDIER", "DST_ODD_CUBE_O_1"],
	["SPK_CITY_GUARD", "DST_ODD_CROUCH_B_1"], ["SPK_JANISSARY", "DST_ODD_CROUCH_O_1"],
	["SPK_CITY_GUARD", "DST_WARN_B_1"], ["SPK_CITY_GUARD", "DST_WARN_B_2"], ["SPK_CITY_GUARD", "DST_WARN_B_3"],
	["SPK_JANISSARY", "DST_WARN_O_1"], ["SPK_JANISSARY", "DST_WARN_O_2"], ["SPK_JANISSARY", "DST_WARN_O_3"],
	["SPK_GENOESE", "DST_WARN_G_1"], ["SPK_WOMAN_BYZ", "DST_WHISPER_B_1"], ["SPK_TOWNSMAN", "DST_WHISPER_B_2"],
	["SPK_SOLDIER", "DST_WHISPER_O_1"], ["SPK_AZAP", "DST_WHISPER_O_2"], ["SPK_CHILD_BYZ", "DST_CHILD_COPY_1"],
	["SPK_CHILD_BYZ", "DST_CHILD_COPY_2"], ["SPK_CHILD_BYZ", "DST_CHILD_COPY_3"]]

static var _street_bags := {}
static var _street_last := ""
static var _street_keys := {}


## Bağlam: bölüm, dönem ("pre" | "siege" | "conq"), yer (BYZ/GAL/CAMP), gece, Tolga fesli mi, Tolga mı oynanıyor
static func street_ctx(tree: SceneTree, night := false) -> Dictionary:
	var pl := tree.get_first_node_in_group("player") as Player
	var hud := tree.get_first_node_in_group("hud") as Hud
	var ch := CityLife.chapter_of(pl) if pl else ""
	if ch == "" and tree.current_scene and tree.current_scene.scene_file_path.contains("interlude"):
		ch = "pre"
	var era := "conq" if ch in STREET_CONQ else ("pre" if ch in STREET_PRE or ch == "pre" else "siege")
	var tolga := pl != null and pl.hand_style == "tolga"
	# Yer: oyuncunun bölüm sahnesine göre (sahne bir test sahnesinin içindeyse de doğru bölüm bulunur)
	var place := crowd_set(tree)
	var root: Node = pl.get_parent() if pl else null
	if root != null and root != tree.current_scene:
		for c in root.get_children():
			if c is ByzCity:
				place = "BYZ"
				break
			if c is Galata:
				place = "GAL"
				break
			if c is CampDay or c is Camp or c is OtagHall:
				place = "CAMP"
				break
	return {"chapter": ch, "era": era, "place": place, "night": night, "tolga": tolga,
		"fez": tolga and hud != null and hud.tolga_wears_fez()}


## Kişinin rolü ("" = rol yok: hikâye karakteri ya da bilinmeyen)
static func street_role(n: Node, ctx: Dictionary) -> String:
	if n == null:
		return ""
	if n.has_meta("street_role"):
		return str(n.get_meta("street_role"))
	if n.has_meta("spk") or (n.has_meta("speaker") and not n.has_meta("street_speaking")) or n.get_meta("hologram", false):
		return ""
	var camp: bool = ctx.get("place", "BYZ") == "CAMP"
	if n is Soldier:
		match (n as Soldier).hat:
			"bork": return "JAN"
			"azap": return "AZAP"
			"helm": return "BYZSOL"
		return "OSMSOL"
	var p := n as Person
	if p == null or p.face_id != "":
		return ""
	if p.child:
		return "" if camp else "CHILDB"
	if p.skirt or p.hat in ["scarf", "bun"]:
		return "" if camp else "WOMB"
	if p.armor == "mail":
		return "GENMERC"
	match p.hat:
		"helm":
			return "BYZSOL"
		"bork":
			return "JAN"
		"azap":
			return "AZAP"
		"priest":
			return "PRIEST"
		"hood":
			if p.robe.a > 0.0:
				return "DERV" if camp else "MONK"
	if p.apron.a > 0.0:
		return "VENDO" if camp else "VENDB"
	if camp:
		if p.hat == "cook" or p.activity in ["carry", "push", "hammer", "chop", "stir"] or p.has_meta("shoulder_load"):
			return "WORKER"
		return "OSMSOL"
	if ctx.get("place", "BYZ") == "GAL":
		return "GAL"
	return "TOWNB"


## Konuşulan kişi: oyuncunun bakış ışınının değdiği "npc:crowd" alanının sahibi; yoksa önündeki en yakın kişi ya da asker
static func street_focus(tree: SceneTree) -> Node3D:
	var pl := tree.get_first_node_in_group("player") as Player
	if pl == null:
		return null
	var ray = pl.get("_ray")
	if ray is RayCast3D and (ray as RayCast3D).is_colliding():
		var c = (ray as RayCast3D).get_collider()
		if c is Node and str((c as Node).get_meta("interact_id", "")) == "npc:crowd" and (c as Node).get_parent() is Node3D:
			return (c as Node).get_parent() as Node3D
	var at := pl.global_position - pl.global_transform.basis.z * 1.5 + Vector3(0, 1.0, 0)
	var best: Node3D = null
	var bd := 2.5
	for g in ["persons", "soldiers"]:
		for n in tree.get_nodes_in_group(g):
			var c := n as Node3D
			if c == null or not c.is_visible_in_tree():
				continue
			var d := (c.global_position + Vector3(0, 1.0, 0)).distance_to(at)
			if d < bd:
				bd = d
				best = c
	return best


## İstemdeki ad: odaktaki kişinin rolü
static func street_label() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "UI_SOMEONE"
	var ctx := street_ctx(tree)
	if ctx["era"] == "pre":
		return "UI_SOMEONE"
	return role_label(street_role(street_focus(tree), ctx))


## Rolün ekranda görünen adı (istem ve altyazı adı aynı): UI_STREET_<..>; etiketi olmayan rol "yoldan geçen"
static func role_label(role: String) -> String:
	return "UI_STREET_" + str(STREET_LABEL[role]) if STREET_LABEL.has(role) else "UI_SOMEONE"


## Hikâye karakteri (yüzü tasarlanmış, "spk"/"speaker" işaretli, hologram): sokak insanı değil, eski davranış sürer
static func street_story(n: Node) -> bool:
	if n == null:
		return true
	if n.has_meta("street_role"):
		return false
	if n.has_meta("spk") or (n.has_meta("speaker") and not n.has_meta("street_speaking")) or n.get_meta("hologram", false):
		return true
	return n is Person and (n as Person).face_id != ""


## Bir anahtar öbeğinin bütün satırları (PREFIX_1, _2, ...): ilk bakışta sayılır
static func street_keys(prefix: String) -> Array:
	if _street_keys.has(prefix):
		return _street_keys[prefix]
	var out: Array = []
	for i in range(1, 40):
		var k := "%s_%d" % [prefix, i]
		if TranslationServer.translate(k) == k:
			break
		out.append(k)
	_street_keys[prefix] = out
	return out


static func _has(k: String) -> bool:
	return TranslationServer.translate(k) != k


## Karışık torbadan sıradaki (bir torba bitmeden aynısı gelmez, art arda hiç gelmez)
static func street_bag(name: String, keys: Array) -> String:
	if keys.is_empty():
		return ""
	var bag: Array = _street_bags.get(name, [])
	bag = bag.filter(func(k): return k in keys)
	if bag.is_empty():
		bag = keys.duplicate()
		bag.shuffle()
		if bag.size() > 1 and bag[0] == _street_last:
			bag.push_back(bag.pop_front())
	var k: String = bag.pop_front()
	_street_bags[name] = bag
	_street_last = k
	return k


## Rolün, bağlamın ve kaçıncı ziyaret olduğunun repliği
static func street_pick(role: String, ctx: Dictionary, visits: int) -> String:
	var conq: bool = ctx.get("era", "siege") == "conq"
	var civ := role in ["TOWNB", "VENDB", "PORTER", "FISHER", "WOMB", "CHILDB", "PRIEST", "MONK"]
	if visits >= 3 and not (conq and civ):
		var g: String = STREET_AGAIN.get(role, "CIVB")
		var k1 := "DST_%s_AGAIN_1" % g
		var k2 := "DST_%s_AGAIN_2" % g
		if visits == 3 and _has(k1):
			return k1
		if visits == 4 and _has(k2):
			return k2
		return "DST_%s_AGAIN" % g
	if conq:
		match role:
			"TOWNB", "VENDB", "PORTER", "FISHER":
				return street_bag("conq_town", street_keys("DST_%s_CONQ" % "TOWNB"))
			"WOMB":
				return street_bag("conq_wom", street_keys("DST_%s_CONQ" % "WOMB"))
			"PRIEST", "MONK":
				return "DST_PRIEST_CONQ_1"
			"CHILDB":
				return "DST_CHILDB_IDLE_2"
			"JAN":
				if randf() < 0.6:
					return street_bag("conq_jan", street_keys("DST_%s_CONQ" % "JAN"))
			"GENMERC":
				if randf() < 0.5:
					return street_bag("conq_gen", street_keys("DST_%s_CONQ" % "GENMERC"))
	if ctx.get("fez", false) and randf() < 0.4:
		var fz := street_keys("DST_%s_FEZ" % role)
		if not fz.is_empty():
			return street_bag(role + "_fez", fz)
	if ctx.get("night", false) and randf() < 0.5:
		var nt := street_keys("DST_%s_NIGHT" % role)
		if not nt.is_empty():
			return street_bag(role + "_night", nt)
	if role == "WOMB" and ctx.get("place", "") == "GAL" and randf() < 0.6:
		return street_bag("WOMB_gal", street_keys("DST_%s_GAL" % "WOMB"))
	var idle: Array = street_keys("DST_%s_IDLE" % role).duplicate()
	match role:
		"TOWNB":
			idle += street_keys("NPC_CROWD_BYZ")
		"OSMSOL":
			idle += street_keys("NPC_CROWD_CAMP")
		"GAL":
			idle = street_keys("NPC_CROWD_GAL").duplicate()
		"WORKER":
			idle.erase("DST_WORKER_IDLE_2" if ctx.get("chapter", "") in STREET_BEFORE_22 else "DST_WORKER_IDLE_5")
	return street_bag(role + "_idle", idle)


## Anahtarın konuşmacısı
static func street_speaker(key: String) -> String:
	if key.begins_with("NPC_CROWD_"):
		return CROWD_SPEAKER.get(key.get_slice("_", 2), "SPK_TOWNSMAN")
	if key.begins_with("DST_T_"):
		return "SPK_TOLGA"
	for pr: Array in STREET_EVENT_LINES:
		if pr[1] == key:
			return pr[0]
	return STREET_SPK.get(key.get_slice("_", 1), "SPK_TOWNSMAN")


## Konuşan kişi: konuşur (ağzı oynar), oyuncuya döner (sahnenin baktırmadığı, işi olmayan). Hud, altyazı göründüğü anda
## çağırır; altyazı başka bir satıra geçince street_release ile susturur. Aynı anda tek konuşan: yeni hold öncekini bırakır.
static func street_hold(who: Node3D, secs: float) -> void:
	if who == null or not is_instance_valid(who) or not who.is_inside_tree():
		return
	street_release(who)
	var pl := who.get_tree().get_first_node_in_group("player") as Node3D
	who.set("talking", true)
	var turned := false
	if pl and who.get("look_target") == null and str(who.get("activity") if "activity" in who else "") == "" \
			and not who.has_meta("no_turn") and not who.has_meta("garrison") and not (who is Soldier and (who as Soldier).pose != "stand"):
		who.set("look_target", pl)
		turned = true
	var gen := int(who.get_meta("street_gen", 0)) + 1
	who.set_meta("street_gen", gen)
	who.set_meta("street_held", true)
	who.set_meta("street_turned", turned)
	var id := who.get_instance_id()
	who.get_tree().create_timer(secs).timeout.connect(func():
		var w := instance_from_id(id) as Node3D          # kişi sahneden kalkmış olabilir: düğümü değil kimliği tut
		if w != null and int(w.get_meta("street_gen", 0)) == gen:
			street_release(w))


## Konuşmayı bırakır (ağız durur, oyuncuya dönüşü kalkar)
static func street_release(who: Node3D) -> void:
	if who == null or not is_instance_valid(who) or not who.get_meta("street_held", false):
		return
	who.set_meta("street_held", false)
	who.set_meta("street_gen", int(who.get_meta("street_gen", 0)) + 1)
	who.set("talking", false)
	if who.get_meta("street_turned", false):
		var pl := who.get_tree().get_first_node_in_group("player") if who.is_inside_tree() else null
		if pl != null and who.get("look_target") == pl:
			who.set("look_target", null)
	who.set_meta("street_turned", false)


## "E: Konuş" sokakta: rolü olan kişiyle konuşur. Rol yoksa false (eski kalabalık repliği)
static func street_talk(hud: Hud) -> bool:
	var tree := hud.get_tree()
	var eye = hud.get("street_eye")
	var night: bool = bool(eye.call("is_night")) if eye != null else false
	var ctx := street_ctx(tree, night)
	if ctx["era"] == "pre":
		return false
	var who := street_focus(tree)
	var role := street_role(who, ctx)
	if role == "":
		return false
	var n := int(who.get_meta("street_n", 0)) + 1
	who.set_meta("street_n", n)
	var key := street_pick(role, ctx, n)
	if key == "":
		return false
	hud.street_bark(who, role, key, 4.5, true)
	if eye != null:
		eye.call("note_talk", who, key)
	# Tolga'nın kısa cevabı (son, sabit "yine" repliğinden sonra değil)
	if ctx["tolga"] and not key.ends_with("_AGAIN") and randf() < 0.25 and not GameState.autotest:
		tree.create_timer(4.8, false).timeout.connect(func():
			if is_instance_valid(hud) and not hud.is_talking() and not hud.line_open:
				hud.bark("SPK_TOLGA", street_bag("t_reply", street_keys("DST_T_%s" % "REPLY")), 3.0))
	return true
