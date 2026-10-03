extends Node
## Başarım ve karne denetimi (v0.50): her yeni başarımın koşulu sahte sayaçlarla açılır, sayaç yokken kapalıdır;
## karne puanı ve derecesi sınır değerlerde doğrudur. Sonuç: ACHCHECK PASS/FAIL.

const NEW := {
	"ACH_PARRY": {"parries_total": 1},
	"ACH_PARRY_50": {"parries_total": 50},
	"ACH_MARKSMAN": {"gun_perfect": 1},
	"ACH_DODGE_10": {"gunner_dodged": 10},
	"ACH_UNBROKEN": {"unbroken": 1},
	"ACH_GRADE_S": {"grade_s": 1},
	"ACH_ARENA_10": {"arena_best_O": 10},
	"ACH_ARENA_BOTH": {"arena_best_B": 5, "arena_best_O": 5},
	"ACH_ROOFTOPS": {"vista_6b_1": 1, "vista_6b_2": 1, "vista_6b_3": 1},
	"ACH_HARD": {"hard_finish": 1},
	"ACH_OSM_BOAT": {"osm_boat_gun": 3},
	"ACH_OSM_BREACH": {"osm_breach": 1},
	"ACH_OSM_SAPPER": {"osm_sapper": 1},
	"ACH_OSM_TOWER": {"osm_tower_gun": 3},
	"ACH_HORSE_SEA": {"horse_sea": 1},
	"ACH_FIRST_SHOT": {"first_shot": 1},
	"ACH_BLACHERNAE": {"blachernae_held": 1},
}


func _ready() -> void:
	GameState.autotest = true
	var ok := true
	var saved := GameState.stats.duplicate(true)
	for id: String in NEW:
		GameState.stats = {}
		var before := Achievements.met(id)
		for k in NEW[id]:
			GameState.stats[k] = NEW[id][k]
		var after := Achievements.met(id)
		var listed := Achievements.LIST.any(func(a): return a["id"] == id)
		var named := tr(Achievements.title_key(id)) != Achievements.title_key(id)
		if before or not after or not listed or not named:
			printerr("ACHCHECK %s önce=%s sonra=%s listede=%s ad=%s" % [id, before, after, listed, named])
			ok = false
	# Yarım koşul: iki taraftan biri 5'in altındaysa ACH_ARENA_BOTH kapalı
	GameState.stats = {"arena_best_B": 5, "arena_best_O": 4}
	if Achievements.met("ACH_ARENA_BOTH"):
		printerr("ACHCHECK ACH_ARENA_BOTH yarım koşulda açıldı")
		ok = false
	# Osmanlı tarih sayfaları: biri eksikken kapalı, hepsi bulununca açık; Bizans sayfaları sayılmaz
	var saved_lore := GameState.lore.duplicate(true)
	GameState.lore = {"20_1": true, "6b_1": true}
	var all_osm := {}
	for k: String in Lore.PAGES:
		if k.ends_with("o"):
			for i in int(Lore.PAGES[k]):
				all_osm["%s_%d" % [k, i + 1]] = true
	var missing_one := all_osm.duplicate()
	missing_one.erase(missing_one.keys()[0])
	GameState.lore = missing_one
	var lore_partial := Achievements.met("ACH_OSM_LORE")
	GameState.lore = all_osm
	var lore_full := Achievements.met("ACH_OSM_LORE")
	if lore_partial or not lore_full or Achievements.osm_lore_total() != all_osm.size():
		printerr("ACHCHECK ACH_OSM_LORE eksik=%s tam=%s toplam=%d" % [lore_partial, lore_full, Achievements.osm_lore_total()])
		ok = false
	GameState.lore = saved_lore
	# Yaşayan İstanbul: 9 yapıda kapalı, 10'da açık
	var saved_disc := GameState.discovered.duplicate()
	GameState.discovered = {}
	for i in Achievements.EXPLORER_N - 1:
		GameState.discovered["lm%d" % i] = true
	var disc_partial := Achievements.met("ACH_EXPLORER")
	GameState.discovered["lm_last"] = true
	var disc_full := Achievements.met("ACH_EXPLORER")
	var disc_named := tr(Achievements.title_key("ACH_EXPLORER")) != Achievements.title_key("ACH_EXPLORER")
	if disc_partial or not disc_full or not disc_named:
		printerr("ACHCHECK ACH_EXPLORER eksik=%s tam=%s ad=%s" % [disc_partial, disc_full, disc_named])
		ok = false
	GameState.discovered = saved_disc
	GameState.stats = saved
	# Karne
	var clean := Grade.score({"parries": 10, "gun_shots": 4, "gun_hits": 4, "dodged": 5})
	var bad := Grade.score({"hits_taken": 6, "downs": 1})
	if Grade.rank(clean) != 3 or Grade.rank(bad) != 0 or Grade.rank(90) != 2 or Grade.rank(65) != 1:
		printerr("ACHCHECK karne temiz=%d kötü=%d" % [clean, bad])
		ok = false
	print("ACHCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
