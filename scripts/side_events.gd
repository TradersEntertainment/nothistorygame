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
		return TranslationServer.translate("UI_PROMPT_TALK_TO") % TranslationServer.translate("UI_SOMEONE")
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
		var cs := crowd_set(hud.get_tree())
		var cprefix := "NPC_CROWD_" + cs
		var cn := _lines(cprefix)
		if cn == 0:
			return
		var cst: Dictionary = GameState.flags.get("npc_talk", {})
		var ci: int = int(cst.get(cprefix, randi() % cn))
		hud.bark(CROWD_SPEAKER[cs], "%s_%d" % [cprefix, ci % cn + 1], 4.5)
		cst[cprefix] = ci + 1
		GameState.flags["npc_talk"] = cst
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
			secs = maxf(secs, vs.get_length() + 0.4)
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
