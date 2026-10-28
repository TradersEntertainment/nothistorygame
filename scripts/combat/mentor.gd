class_name Mentor
extends Node
## Talimin hocası sonraki çarpışmalarda yanından seslenir: talim bölümü (41o Hızır, 42b Leon) oynandıysa ve hoca hâlâ
## sağsa (Hızır 37o'da sürüklenip kurtarılmadıysa düşer; Leon 36b'de dışarıda kaldıysa esirdir), oyuncu talimde
## öğrendiğini unutunca bir kez hatırlatır:
##   kalkanlı rakibin kalkanına art arda vuruyor, tekme atmıyorsa → "tekmele"
##   rakip sendeliyor ya da yerde, bitirici hazır ama basılmıyorsa → "bitir"
## Her çarpışmada her hatırlatma en çok bir kez (WaveRunner ve StoryDuel kurar; talim bölümlerinin Drill'i kurmaz).

const BLOCKED_BEFORE_KICK := 3
const FIN_WAIT := 1.4

var duel: Duel
var hud: Hud
var who := ""              # "hizir" | "leon"
var _blocked := 0
var _kicks0 := 0
var _fin_t := 0.0
var _said_kick := false
var _said_fin := false


## Bu çarpışmaya hoca gerekiyorsa kurar (gerekmiyorsa null)
static func attach(p_duel: Duel, p_hud: Hud) -> Mentor:
	var w := current()
	if w == "" or p_hud == null:
		return null
	var m := Mentor.new()
	m.duel = p_duel
	m.hud = p_hud
	m.who = w
	m._kicks0 = p_duel.kicks
	p_duel.swung.connect(m._on_swung)
	p_duel.add_child(m)
	return m


## Şu anki tarafta talimin hocası yanımızda mı: "hizir", "leon" ya da ""
static func current() -> String:
	if Siege.side() == "O":
		if Siege.outcome(41) != "" and not bool(GameState.flags.get("hizir_fell", false)):
			return "hizir"
	else:
		if Siege.outcome(42) != "" and Siege.outcome(36) != "36.2":
			return "leon"
	return ""


func _on_swung(_dir: int, result: String, e: Duelist) -> void:
	if result == "blocked" and e != null and e.shield != null:
		_blocked += 1
	elif result in ["hit", "kill"]:
		_blocked = 0


func _process(delta: float) -> void:
	if duel == null or not duel.active or hud == null:
		return
	if duel.kicks > _kicks0:
		_kicks0 = duel.kicks
		_blocked = 0
	if not _said_kick and _blocked >= BLOCKED_BEFORE_KICK:
		_said_kick = true
		if GameState.autotest:
			print("MENTOR %s kick" % who)
		if who == "hizir":
			hud.bark("SPK_AZAP", "D41O_HZ_KICK_FIELD", 3.0)
		else:
			hud.bark("SPK_LEON", "D42B_LN_KICK_FIELD", 3.0)
	if _said_fin:
		return
	_fin_t = _fin_t + delta if duel._finish_ready() else 0.0
	if _fin_t >= FIN_WAIT:
		_said_fin = true
		if GameState.autotest:
			print("MENTOR %s fin" % who)
		if who == "hizir":
			hud.bark("SPK_AZAP", "D41O_HZ_FIN_FIELD", 2.5)
		else:
			hud.bark("SPK_LEON", "D42B_LN_FIN_FIELD", 2.5)
