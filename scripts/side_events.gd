class_name SideEvents
## Bölüm betiklerine dokunmadan çalışan küçük yan içerik:
##   "npc:<id>"  yan karakter: her E'de sıradaki cümle (NPC_<ID>_1..n), eşya gösterilince REACT_<ID>_*.
##               Hattat son cümlesini söyleyince "calligraphy" bayrağı (görev).
##               Venedikli çocuk: kedi bulununca teşekkür cümlelerine geçer.
##   "ev:<id>"   tek seferlik olay: Konstantin Sütunu'nda dilek ("column_wish").
## Player, bu önekli kimlikleri kendisi yakalar (Player._input) ve buraya yollar.

const SPEAKERS := {"calligrapher": "SPK_CALLIGRAPHER", "painter": "SPK_PAINTER", "kid": "SPK_KID"}


static func prompt(id: String) -> String:
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
	match id.trim_prefix("ev:"):
		"column":
			if not GameState.flags.get("column_wish", false):
				GameState.flags["column_wish"] = true
				Audio.sfx("ui_confirm", -6.0)
			hud.bark("SPK_TOLGA", "D_EV_COLUMN", 5.0)


static func _focus_point(hud: Hud) -> Vector3:
	var sc := hud.get_tree().current_scene
	var pl = sc.get("player") if sc else null
	if pl is Player:
		var p := pl as Player
		return p.global_position - p.global_transform.basis.z * 1.5 + Vector3(0, 1.0, 0)
	return Vector3.ZERO
