class_name Quests
## Yan görevler: her eşyanın kendi görevi. Çoğu "bu eşyayı şu kişilere göster" biçimindedir;
## Player._use_held her gösterimde progress() çağırır, bölüm betiklerinin bir şey yapması gerekmez.
## Bu oyundaki ilerleme GameState.flags["quests"] içinde (kayıtla birlikte geri sarılır),
## bir kez bile tamamlananlar meta dosyasında (GameState.quests_ever) kalır.
## Selfie görevinde her yeni kişi için ekran görüntüsü user://album/ klasörüne kaydedilir.

const ANY := ["hikmet", "guards", "kadri", "lutfi", "urban", "aga", "fatih", "nihat", "niko", "emperor", "giustiniani",
	"theodoros", "tailor", "pasha", "dervish", "cameleer", "miner", "soldier", "candarli", "clerk", "wine", "notary",
	"double", "fishmonger"]

## id = eşya id'si. need = kaç farklı kişi. targets boşsa ANY.
const LIST := {
	"selfie": {"need": 5, "targets": ["fatih", "emperor", "urban", "giustiniani", "guards", "kadri", "niko", "lutfi",
		"theodoros", "aga", "pasha", "dervish", "cameleer", "tailor", "miner", "wine", "soldier", "notary", "double", "fishmonger"]},
	"cube": {"need": 1, "targets": ["fatih", "dervish"]},
	"tape": {"need": 4, "targets": ["urban", "kadri", "miner", "wine", "clerk", "hikmet", "guards", "niko", "giustiniani", "notary", "fishmonger"]},
	"chickpeas": {"need": 6, "targets": []},
	"lighter": {"need": 3, "targets": ["urban", "miner", "wine", "clerk", "tailor"]},
	"thermos": {"need": 2, "targets": ["fatih", "emperor"]},
	"cologne": {"need": 7, "targets": []},
	"phone": {"need": 3, "targets": ["emperor", "theodoros", "giustiniani", "niko", "clerk"]},
	"book": {"need": 3, "targets": ["fatih", "pasha", "urban", "giustiniani", "emperor", "theodoros"]},
	"powerbank": {"need": 2, "targets": ["urban", "miner", "hikmet"]},
	# Olay görevleri: bayraklardan kaçı doğruysa ilerleme odur (hud saniyede bir kontrol eder)
	"ayasofya": {"need": 1, "flags": ["climbed_ayasofya"]},
	"galata": {"need": 1, "flags": ["climbed_galata"]},
	"bigbang": {"need": 1, "flags": ["big_bang"]},
	"engineer": {"need": 1, "flags": ["cannon_taped", "breach_taped"]},
	"friends": {"need": 2, "flags": ["urban_friend", "niko_friend", "guards_like_tolga"]},
	"kitchen": {"need": 1, "flags": ["kitchen_fire"]},
	"diver": {"need": 1, "flags": ["amphora_seen"]},
	"goatherd": {"need": 1, "flags": ["goat_caught"]},
	"chickens": {"need": 1, "flags": ["chickens_3"]},
}
const ALBUM_DIR := "user://album/"


static func title_key(id: String) -> String:
	return "QUEST_%s_T" % id.to_upper()


static func hint_key(id: String) -> String:
	return "QUEST_%s_H" % id.to_upper()


## Eşya görevinde eşyanın adı, olay görevinde nerede olduğu.
static func where_text(id: String) -> String:
	return TranslationServer.translate("QUEST_%s_W" % id.to_upper()) if is_event(id) else TranslationServer.translate(Items.name_key(id))


static func is_event(id: String) -> bool:
	return LIST[id].has("flags")


## "clerk:2" -> "clerk", Hasan/Hüseyin tek kişi sayılır.
static func who(target: String) -> String:
	var w := target.get_slice(":", 0)
	return "guards" if w in ["hasan", "huseyin"] else w


static func state() -> Dictionary:
	if not GameState.flags.has("quests"):
		GameState.flags["quests"] = {}
	return GameState.flags["quests"]


static func progress_of(id: String) -> int:
	if is_event(id):
		var n := 0
		for f in LIST[id]["flags"]:
			if GameState.flags.get(f, false):
				n += 1
		return n
	return (state().get(id, []) as Array).size()


## Yeni tamamlanan olay görevleri (bir kez döner; bu oyunda hatırlanır).
static func check_events() -> Array[String]:
	var out: Array[String] = []
	var st := state()
	var seen: Array = st.get("_events", [])
	for id in LIST:
		if is_event(id) and not id in seen and is_done(id):
			seen.append(id)
			GameState.mark_quest_ever(id)
			out.append(id)
	st["_events"] = seen
	return out


static func is_done(id: String) -> bool:
	return progress_of(id) >= int(LIST[id]["need"])


static func done_count() -> int:
	var n := 0
	for id in LIST:
		if is_done(id):
			n += 1
	return n


## Bir gösterim. Yeni ilerleme varsa "progress" ya da "done", yoksa "".
static func progress(target: String, item: String) -> String:
	if not LIST.has(item) or target == "" or is_event(item):
		return ""
	var w := who(target)
	var q: Dictionary = LIST[item]
	var targets: Array = q["targets"] if not (q["targets"] as Array).is_empty() else ANY
	if not w in targets or is_done(item):
		return ""
	var st := state()
	var got: Array = st.get(item, [])
	if w in got:
		return ""
	got.append(w)
	st[item] = got
	if got.size() >= int(q["need"]):
		GameState.mark_quest_ever(item)
		return "done"
	return "progress"


## Albümdeki fotoğrafların yolları (en yeni önce).
static func album() -> Array[String]:
	var out: Array[String] = []
	if not DirAccess.dir_exists_absolute(ALBUM_DIR):
		return out
	var files := DirAccess.get_files_at(ALBUM_DIR)
	for f in files:
		if f.ends_with(".png"):
			out.append(ALBUM_DIR + f)
	out.sort()
	out.reverse()
	return out
