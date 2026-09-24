class_name SteamBridge
## Steam bağlantısı (GodotSteam GDExtension). Eklenti kurulu değilse ya da oyun Steam dışından açıldıysa
## hiçbir şey yapmaz: oyun her durumda aynı çalışır.
## Kurulum ve App ID: docs/STEAM.md. Başarım kimlikleri: scripts/achievements.gd (docs/STEAM_ACHIEVEMENTS.md).
##   init()   GameState._ready'de: Steam'e bağlanır, daha önce açılmış başarımları Steam'e eşitler
##   tick()   her karede: Steam geri çağrıları
##   unlock() GameState.unlock_achievement: başarımı Steam'de de açar

static var _steam: Object
static var ready := false


static func init() -> void:
	if not Engine.has_singleton("Steam"):
		return
	_steam = Engine.get_singleton("Steam")
	var res: Variant = _steam.call("steamInitEx", true) if _steam.has_method("steamInitEx") else _steam.call("steamInit", true)
	var status := int((res as Dictionary).get("status", 1)) if res is Dictionary else (0 if res else 1)
	ready = status == 0
	if not ready:
		push_warning("Steam başlatılamadı (durum %s): Steam açık mı, steam_appid.txt var mı?" % str(res))
		return
	for id in GameState.achievements:
		_steam.call("setAchievement", id)
	_steam.call("storeStats")


static func tick() -> void:
	if ready:
		_steam.call("run_callbacks")


static func unlock(id: String) -> void:
	if not ready:
		return
	_steam.call("setAchievement", id)
	_steam.call("storeStats")


## Steam arayüzünde görünen oyuncu adı (yoksa boş).
static func persona() -> String:
	return str(_steam.call("getPersonaName")) if ready else ""
