class_name Grade
extends RefCounted
## Savaş karnesi: savaşlı bölümlerin (20, 22o, 26, 26o) sonunda akış şemasının altında tek satır.
## Sayaçlar GameState.combat'ta (bölüm başında sıfırlanır; Duel, Handgun, Gunner, Player artırır).
##   Puan: 100 − 6 × yenen darbe − 25 × yere düşme − 10 × tüfekçi isabeti + 2 × karşılama (en çok 20)
##         + 20 × tüfek isabet oranı + 3 × kaçılan tüfekçi atışı (en çok 15)
##   Derece: S ≥ 115 · A ≥ 90 · B ≥ 65 · C
## Kalıcı: en iyi derece stats["grade_<bölüm>"] (0 C … 3 S); başarım sayaçları da burada artar.

const LETTERS := ["C", "B", "A", "S"]


static func score(c: Dictionary) -> int:
	var s := 100.0
	s -= 6.0 * float(c.get("hits_taken", 0))
	s -= 25.0 * float(c.get("downs", 0))
	s -= 10.0 * float(c.get("gunner_hits", 0))
	s += minf(2.0 * float(c.get("parries", 0)), 20.0)
	var shots := int(c.get("gun_shots", 0))
	if shots > 0:
		s += 20.0 * float(c.get("gun_hits", 0)) / float(shots)
	s += minf(3.0 * float(c.get("dodged", 0)), 15.0)
	return int(round(s))


static func rank(points: int) -> int:
	if points >= 115:
		return 3
	if points >= 90:
		return 2
	if points >= 65:
		return 1
	return 0


## Bölüm sonu: karneyi hesaplar, kalıcı sayaçları yazar, akış şeması satırını döndürür.
static func finish(chapter_id: String) -> String:
	var c: Dictionary = GameState.combat
	var pts := score(c)
	var r := rank(pts)
	var key := "grade_" + chapter_id
	if r > int(GameState.stats.get(key, -1)):
		GameState.bump_stat(key, r, true)
	if r == 3:
		GameState.bump_stat("grade_s", 1, true)
	if int(c.get("downs", 0)) == 0 and int(c.get("hits_taken", 0)) + int(c.get("parries", 0)) + int(c.get("kills", 0)) > 0:
		GameState.bump_stat("unbroken", 1, true)
	if int(GameState.settings.get("difficulty", 1)) == 2 and chapter_id.begins_with("26"):
		GameState.bump_stat("hard_finish", 1, true)
	var shots := int(c.get("gun_shots", 0))
	var parts: Array[String] = [TranslationServer.translate("UI_GRADE_PARRIES") % int(c.get("parries", 0))]
	if shots > 0:
		parts.append(TranslationServer.translate("UI_GRADE_GUN") % [int(c.get("gun_hits", 0)), shots])
	if int(c.get("gunner_shots", 0)) > 0:
		parts.append(TranslationServer.translate("UI_GRADE_DODGED") % [int(c.get("dodged", 0)), int(c.get("gunner_shots", 0))])
	parts.append(TranslationServer.translate("UI_GRADE_NODOWN") if int(c.get("downs", 0)) == 0 else TranslationServer.translate("UI_GRADE_DOWNS") % int(c.get("downs", 0)))
	if GameState.autotest:
		print("GRADE chapter=%s letter=%s points=%d %s" % [chapter_id, LETTERS[r], pts, str(c)])
	return TranslationServer.translate("UI_GRADE_LINE") % [LETTERS[r], " · ".join(parts)]
