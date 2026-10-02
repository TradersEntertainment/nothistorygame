class_name Achievements
## Başarımlar. Kimlikler Steam biçiminde (ACH_*); docs/STEAM_ACHIEVEMENTS.md aynı listeyi taşır.
## hud saniyede bir check() çağırır; yeni açılanlar rozetle gösterilir. Kilitler ve sayaçlar meta dosyasında
## (GameState.achievements, stats, finals_seen, seen_outcomes, quests_ever): oyunlar arası kalıcıdır.
## secret: kilitliyken adı ve açıklaması "???" görünür.

const LIST: Array[Dictionary] = [
	{"id": "ACH_ZAMANATOR", "secret": false},     # 1. bölümü bitir
	{"id": "ACH_KICK", "secret": false},          # makineye tekmeyi Tolga atsın (1.2)
	{"id": "ACH_RED_BUTTON", "secret": true},     # kızakta kırmızı düğme (2.5)
	{"id": "ACH_CHAIN", "secret": false},         # zincire ulaş (2.3)
	{"id": "ACH_TEA_AUDIT", "secret": true},      # Nihat Hikmet'le çay içsin (3.5)
	{"id": "ACH_ACT1", "secret": false},          # Perde I'i bitir (4. bölüm)
	{"id": "ACH_AUDIENCE", "secret": false},      # Fatih'in huzuruna çık (12. bölüm)
	{"id": "ACH_LAST_EVENING", "secret": true},   # Konstantinos'la Son Akşam (12B)
	{"id": "ACH_TUNNEL", "secret": true},         # lağımda ateşkes (10L)
	{"id": "ACH_CLUCK", "secret": true},          # tavuk bölümü (16)
	{"id": "ACH_MONDAY", "secret": false},        # ilk final
	{"id": "ACH_FINALS_5", "secret": false},      # 5 farklı final
	{"id": "ACH_FINALS_12", "secret": false},     # 12 farklı final
	{"id": "ACH_FINALS_ALL", "secret": false},    # 26 finalin hepsi
	{"id": "ACH_BIG_BANG", "secret": false},      # Büyük Patlama
	{"id": "ACH_ORDINARY", "secret": true},       # Sıradan Bir Pazartesi finali
	{"id": "ACH_QUEST_1", "secret": false},       # ilk yan görev
	{"id": "ACH_QUEST_10", "secret": false},      # 10 yan görev
	{"id": "ACH_QUEST_ALL", "secret": false},     # bütün yan görevler
	{"id": "ACH_TEA_BOTH", "secret": false},      # İki Tarafa Çay
	{"id": "ACH_CLIMBER", "secret": false},       # Ayasofya ve Galata
	{"id": "ACH_DIVER", "secret": false},         # Haliç'in Dibi
	{"id": "ACH_SELFIES_10", "secret": false},    # toplam 10 selfie
	{"id": "ACH_PHOTOGRAPHER", "secret": false},  # foto modunda 5 fotoğraf
	{"id": "ACH_FEZ_20", "secret": true},         # fesi 20 kez tak-çıkar
	{"id": "ACH_GOATHERD", "secret": false},      # kaçan keçiyi yakala
	{"id": "ACH_CHICKEN_WHISPERER", "secret": false},  # tavuğu 3 kez yakala
	{"id": "ACH_CHEF", "secret": false},          # Kadri'nin kazanında 80+ puan
	{"id": "ACH_HAGGLER", "secret": false},       # Galata'da pazarlığı kazan
	{"id": "ACH_MANGALA", "secret": false},       # mangalada bir kez kazan
	{"id": "ACH_ARCHER", "secret": false},        # Hasan'ın talim alanında 70+ puan
	{"id": "ACH_KADRI_DUEL", "secret": false},    # kazan düellosunda Kadri'yi yen
	{"id": "ACH_REWIND", "secret": true},         # bir bölüme geri dön
	{"id": "ACH_BILINGUAL", "secret": true},      # dili değiştir
	{"id": "ACH_SEYYAH", "secret": false},        # Nihat'ın seyir defteri: dokuz yer
	{"id": "ACH_FORMS", "secret": false},         # on iki uçuşan formun hepsi
	{"id": "ACH_ROOFTOP", "secret": false},       # kubbe, kule galerisi, sütun tepesi
	{"id": "ACH_LEGEND", "secret": true},         # beş tanık: uçan cin efsanesi
	{"id": "ACH_PARRY", "secret": false},         # ilk karşılama (parry)
	{"id": "ACH_PARRY_50", "secret": false},      # toplam 50 karşılama
	{"id": "ACH_MARKSMAN", "secret": false},      # bir tüfek sahnesinde 4/4
	{"id": "ACH_DODGE_10", "secret": false},      # 10 tüfekçi atışından kaç
	{"id": "ACH_UNBROKEN", "secret": false},      # savaşlı bölümü hiç düşmeden bitir
	{"id": "ACH_GRADE_S", "secret": false},       # bir bölümde S karnesi
	{"id": "ACH_ARENA_10", "secret": false},      # arenada 10. dalga
	{"id": "ACH_ARENA_BOTH", "secret": false},    # arenada iki tarafta da 5. dalga
	{"id": "ACH_ROOFTOPS", "secret": false},      # 6b'de üç seyir noktası
	{"id": "ACH_HARD", "secret": true},           # Zor ayarında 26 ya da 26o
	{"id": "ACH_OSM_BOAT", "secret": false},      # 19o: brigantinin tayfasına 3 isabet
	{"id": "ACH_OSM_BREACH", "secret": false},    # 20o: gedikteki dövüşü kazan
	{"id": "ACH_OSM_SAPPER", "secret": false},    # 21o: lağımdaki baskını püskürt
	{"id": "ACH_OSM_TOWER", "secret": false},     # 22o: kuleden 3 isabet
	{"id": "ACH_OSM_LORE", "secret": false},      # Osmanlı bölümlerinin bütün tarih sayfaları
]

const FINALS_TOTAL := 26


static func title_key(id: String) -> String:
	return id + "_T"


static func desc_key(id: String) -> String:
	return id + "_D"


static func _seen_prefix(prefix: String) -> bool:
	for k in GameState.seen_outcomes:
		if String(k).begins_with(prefix):
			return true
	return false


static func _stat(key: String) -> int:
	return int(GameState.stats.get(key, 0))


static func _quest(id: String) -> bool:
	return GameState.quests_ever.has(id)


## Koşulu sağlanıyor mu?
static func met(id: String) -> bool:
	var seen := GameState.seen_outcomes
	var finals := GameState.finals_seen.size()
	match id:
		"ACH_ZAMANATOR": return _seen_prefix("1.")
		"ACH_KICK": return seen.has("1.2")
		"ACH_RED_BUTTON": return seen.has("2.5")
		"ACH_CHAIN": return seen.has("2.3")
		"ACH_TEA_AUDIT": return seen.has("3.5")
		"ACH_ACT1": return _seen_prefix("4a.") or _seen_prefix("4b.")
		"ACH_AUDIENCE": return _seen_prefix("12.")
		"ACH_LAST_EVENING": return _seen_prefix("12B.")
		"ACH_TUNNEL": return _seen_prefix("10L.")
		"ACH_CLUCK": return _seen_prefix("16.")
		"ACH_MONDAY": return finals >= 1
		"ACH_FINALS_5": return finals >= 5
		"ACH_FINALS_12": return finals >= 12
		"ACH_FINALS_ALL": return finals >= FINALS_TOTAL
		"ACH_BIG_BANG": return GameState.finals_seen.has("big_bang") or _quest("bigbang")
		"ACH_ORDINARY": return GameState.finals_seen.has("ordinary_monday")
		"ACH_QUEST_1": return GameState.quests_ever.size() >= 1
		"ACH_QUEST_10": return GameState.quests_ever.size() >= 10
		"ACH_QUEST_ALL": return GameState.quests_ever.size() >= Quests.LIST.size()
		"ACH_TEA_BOTH": return _quest("thermos")
		"ACH_CLIMBER": return _quest("ayasofya") and _quest("galata")
		"ACH_DIVER": return _quest("diver")
		"ACH_SELFIES_10": return _stat("selfies") >= 10
		"ACH_PHOTOGRAPHER": return _stat("photo_mode_shots") >= 5
		"ACH_FEZ_20": return _stat("fez_toggles") >= 20
		"ACH_GOATHERD": return _quest("goatherd")
		"ACH_CHICKEN_WHISPERER": return _quest("chickens")
		"ACH_CHEF": return _stat("cauldron_best") >= 80
		"ACH_HAGGLER": return _stat("haggle_wins") >= 1
		"ACH_MANGALA": return _stat("mangala_wins") >= 1
		"ACH_ARCHER": return _stat("archery_best") >= 70
		"ACH_KADRI_DUEL": return _stat("kadri_duel_wins") >= 1
		"ACH_REWIND": return _stat("rewinds") >= 1
		"ACH_BILINGUAL": return _stat("lang_switch") >= 1
		"ACH_SEYYAH": return _quest("seyyah")
		"ACH_FORMS": return _quest("forms")
		"ACH_ROOFTOP": return _quest("perch")
		"ACH_LEGEND": return _stat("flying_legend") >= 1
		"ACH_PARRY": return _stat("parries_total") >= 1
		"ACH_PARRY_50": return _stat("parries_total") >= 50
		"ACH_MARKSMAN": return _stat("gun_perfect") >= 1
		"ACH_DODGE_10": return _stat("gunner_dodged") >= 10
		"ACH_UNBROKEN": return _stat("unbroken") >= 1
		"ACH_GRADE_S": return _stat("grade_s") >= 1
		"ACH_ARENA_10": return maxi(_stat("arena_best_B"), _stat("arena_best_O")) >= 10
		"ACH_ARENA_BOTH": return _stat("arena_best_B") >= 5 and _stat("arena_best_O") >= 5
		"ACH_ROOFTOPS": return _stat("vista_6b_1") >= 1 and _stat("vista_6b_2") >= 1 and _stat("vista_6b_3") >= 1
		"ACH_HARD": return _stat("hard_finish") >= 1
		"ACH_OSM_BOAT": return _stat("osm_boat_gun") >= 3
		"ACH_OSM_BREACH": return _stat("osm_breach") >= 1
		"ACH_OSM_SAPPER": return _stat("osm_sapper") >= 1
		"ACH_OSM_TOWER": return _stat("osm_tower_gun") >= 3
		"ACH_OSM_LORE": return osm_lore_found() >= osm_lore_total()
	return false


## Osmanlı tarafı bölümlerinin (anahtarı "o" ile biten) tarih sayfaları
static func osm_lore_total() -> int:
	var n := 0
	for k: String in Lore.PAGES:
		if k.ends_with("o"):
			n += int(Lore.PAGES[k])
	return n


static func osm_lore_found() -> int:
	var n := 0
	for id in GameState.lore:
		if String(id).get_slice("_", 0).ends_with("o"):
			n += 1
	return n


## Yeni açılan başarımlar (bir kez döner).
static func check() -> Array[String]:
	var out: Array[String] = []
	if GameState.autotest:
		return out
	for a in LIST:
		var id: String = a["id"]
		if not GameState.achievements.has(id) and met(id) and GameState.unlock_achievement(id):
			out.append(id)
	return out


static func unlocked_count() -> int:
	return GameState.achievements.size()
