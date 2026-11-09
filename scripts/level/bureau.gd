class_name Bureau
extends Node3D
## Zaman Bürosu: zamanın dışında duran bir devlet dairesi (CHAPTERS §3.2, Bölüm 3).
## Nihat'ın odası (Form Z-1, akrepsiz saat, hiçliğe bakan pencere), sise gömülüp
## sonsuza uzanan koridor (her kapıda bir yıl), kostüm deposu, Başdenetçi'nin
## kâğıt dağları arasındaki masası ve saha asansörü.

const OFFICE_W := 6.0
const OFFICE_D := 6.0
const OFFICE_H := 3.0
const COR_W := 4.0
const COR_H := 3.4
const COR_LEN := 84.0
const DEPOT_Z0 := -10.5
const DEPOT_Z1 := -17.5
const DESK_Z := -26.0
const LIFT_Z := -34.0

const SPAWN_POS := Vector3(0.0, 0.0, 1.6)
## Saha asansörü (v0.99.6): Nihat tarih panelinin yanında, yolcu kabinin ortasında
## (Nihat açıklığın kenarında: kabindeki yolcu onu açıklıktan görür; açık kapı kanadı duvarın içine kayar)
const NIHAT_PANEL_POS := Vector3(-1.25, 0.0, -33.25)
const LIFT_IN := Vector3(-2.75, 0.0, -34.0)
const LIFT_FRONT := Vector3(0.4, 0.0, -34.0)
const LIFT_OUT := Vector3(-0.55, 0.0, -34.15)
const PANEL_POS := Vector3(-1.9, 1.32, -32.75)
const NIHAT_OFFICE_POS := Vector3(1.5, 0.0, 3.3)   # ofiste Nihat: masanın sağ önü, kapıdan girenin karşısında
const MUFIDE_POS := Vector3(0.0, 0.0, DESK_Z - 1.0)
const RIZA_POS := Vector3(4.3, 0.0, -14.0)

const C_WALL := Color("7d8a78")
const C_WALL_LOW := Color("5d6b5c")
const C_WOOD := Color("7a4f30")
const C_WOOD_DARK := Color("5a3820")
const C_BRASS := Color("c49a45")
const C_PAPER := Color("efe9d8")
const C_METAL := Color("8b939a")

const YEARS := ["1071", "1204", "1299", "1492", "1517", "1683", "1789", "1826", "1908",
	"1923", "1969", "2026", "2150", "MÖ 44", "MÖ 776", "1453", "1453", "1453"]

var mufide: Person
var riza: Person
var file_node: Node3D
var capsule: Node3D
var fedora_node: Node3D
var lift_door: Node3D
var lift_dial: Label3D        # koridordaki kat göstergesi (◀ 1453 ▶): Nihat'ın kadranıyla döner
var lift_dial_in: Label3D     # kabinin içindeki gösterge: kapı kapanınca yolcunun karşısında
var lift_light: OmniLight3D
var lift_open := false
var panel_wheel: Node3D       # tarih panelinin çarkı
var env_node: WorldEnvironment

# ---------------------------------------------------------------- v0.99.96 yeniden tasarım: ortak altyapı
# Büro eskiden düz yeşil bir kutuydu (oynanış denetimi: "en sıkıcı yer"). Artık gezilecek bir daire: çay ocağı, bekleme
# salonu, kayıp zaman bürosu, arşiv, şikâyet masası, müdür kapısı, atrium ve zamanın dışına bakan pencereler; çağ ışığı
# sızan aralık kapılar, tüplerde uçan kapsüller, memurlar. Etkileşimler Büro'nun kendisinde (bölümlere dokunmadan):
# _reg ile kaydedilen "bur_" kimlikleri oyuncunun sinyallerinden yakalanır.
const C_CREAM := Color("e9dcb8")
const C_TEAL := Color("3f6f68")
const C_COR_WALL := Color("d8caa0")
const C_COR_LOW := Color("4d7c6e")
const C_RUG := Color("7c2f2c")
const C_RUG_EDGE := Color("d9a84a")
const C_MUSTARD := Color("d9a22e")
const C_ORANGE := Color("d9702a")
const C_WALNUT := Color("3a2218")
const C_CEIL := Color("e8e0c8")
## Koridorun açıklıkları (oda kapıları): [z_üst, z_alt] (z_üst > z_alt). Batı (-x) ve doğu (+x) duvarları buralarda açık.
const OPEN_W := [[-4.2, -8.6], [-15.3, -18.7], [-27.3, -31.2], [-33.0, -35.0]]       # bekleme, arşiv, şikâyet, asansör
const OPEN_E := [[-2.2, -7.0], [-10.5, -17.5], [-19.0, -23.4], [-29.2, -31.2], [-36.5, -55.5]]   # çay, depo, kayıp, müdür, atrium
## Yıllı kapılar: [taraf, z, yıl]. 1492 doğuda z -8.5'te kalır (Bölüm 13 önüne birini koyar); 1453, 1923, 2026 şart (Bölüm 3).
const DOORS := [[-1, -12.25, "1071"], [-1, -25.5, "1204"], [-1, -38.0, "1299"], [-1, -42.5, "1517"], [-1, -47.0, "1683"],
	[-1, -51.5, "1789"], [-1, -56.0, "1826"], [-1, -60.5, "1908"], [-1, -65.0, "1923"], [-1, -69.5, "1969"], [-1, -74.0, "2026"],
	[-1, -78.5, "2150"], [-1, -82.0, "MÖ 44"], [1, -8.5, "1492"], [1, -58.5, "MÖ 776"], [1, -63.0, "1453"], [1, -67.5, "1453"],
	[1, -72.0, "1453"], [1, -76.5, "1683"], [1, -81.0, "1299"]]
const ERA_COLORS := {"1071": Color("e8c060"), "1204": Color("9a5ad8"), "1299": Color("7fa04a"), "1453": Color("ff6a2a"),
	"1492": Color("c8883a"), "1517": Color("e8b878"), "1683": Color("6a8ac8"), "1789": Color("cc4a4a"), "1826": Color("9a9aa0"),
	"1908": Color("c8a070"), "1923": Color("e03a3a"), "1969": Color("d8e8ff"), "2026": Color("6ad0ff"), "2150": Color("ff40d0"),
	"MÖ 44": Color("f0e8d8"), "MÖ 776": Color("ffe090")}

## Konuşan: oyuncu Nihat'ken nesne replikleri onun sesiyle; başka biri (Bölüm 13/17) Büro'daysa nesneler sessiz kalır,
## memurlar yine konuşur.
## Seslendirme eşlemesi (tools/voice_map.py okur): _say(anahtar, sn, konuşan) çağrıları desenle yakalanmıyor
const _BUR_VOICE := [
	["SPK_NAPOLEON", "BUR_FG_NAP_V2_1"], ["SPK_NAPOLEON", "BUR_FG_NAP_V2_2"], ["SPK_NAPOLEON", "BUR_FG_NAP_V3_1"],
	["SPK_NAPOLEON", "BUR_FG_NAP_V3_2"], ["SPK_HITLER", "BUR_FG_HIT_V2_1"], ["SPK_HITLER", "BUR_FG_HIT_V2_2"],
	["SPK_HITLER", "BUR_FG_HIT_V3_1"], ["SPK_HITLER", "BUR_FG_HIT_V3_2"], ["SPK_CLEOPATRA", "BUR_FG_CLE_V2_1"],
	["SPK_CLEOPATRA", "BUR_FG_CLE_V2_2"], ["SPK_CLEOPATRA", "BUR_FG_CLE_V3_1"], ["SPK_CLEOPATRA", "BUR_FG_CLE_V3_2"],
	["SPK_CAESAR", "BUR_FG_CAE_V2_1"], ["SPK_CAESAR", "BUR_FG_CAE_V2_2"], ["SPK_CAESAR", "BUR_FG_CAE_V3_1"],
	["SPK_CAESAR", "BUR_FG_CAE_V3_2"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_V2_1"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_V2_2"],
	["SPK_SHAKESPEARE", "BUR_FG_SHK_V3_1"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_V3_2"], ["SPK_LEONARDO", "BUR_FG_LEO_V2_1"],
	["SPK_LEONARDO", "BUR_FG_LEO_V2_2"], ["SPK_LEONARDO", "BUR_FG_LEO_V3_1"], ["SPK_LEONARDO", "BUR_FG_LEO_V3_2"],
	["SPK_EINSTEIN", "BUR_FG_EIN_V2_1"], ["SPK_EINSTEIN", "BUR_FG_EIN_V2_2"], ["SPK_EINSTEIN", "BUR_FG_EIN_V3_1"],
	["SPK_EINSTEIN", "BUR_FG_EIN_V3_2"], ["SPK_GENGHIS", "BUR_FG_GEN_V2_1"], ["SPK_GENGHIS", "BUR_FG_GEN_V2_2"],
	["SPK_GENGHIS", "BUR_FG_GEN_V3_1"], ["SPK_GENGHIS", "BUR_FG_GEN_V3_2"], ["SPK_COLUMBUS", "BUR_FG_COL_V2_1"],
	["SPK_COLUMBUS", "BUR_FG_COL_V2_2"], ["SPK_COLUMBUS", "BUR_FG_COL_V3_1"], ["SPK_COLUMBUS", "BUR_FG_COL_V3_2"],
	["SPK_SULEYMAN", "BUR_FG_SUL_V2_1"], ["SPK_SULEYMAN", "BUR_FG_SUL_V2_2"], ["SPK_SULEYMAN", "BUR_FG_SUL_V3_1"],
	["SPK_SULEYMAN", "BUR_FG_SUL_V3_2"], ["SPK_GUIDE", "BUR_FG_GUI_V2_1"], ["SPK_GUIDE", "BUR_FG_GUI_V2_2"],
	["SPK_GUIDE", "BUR_FG_GUI_V3_1"], ["SPK_GUIDE", "BUR_FG_GUI_V3_2"], ["SPK_ROBOT", "BUR_FG_ROB_V2_1"],
	["SPK_ROBOT", "BUR_FG_ROB_V2_2"], ["SPK_ROBOT", "BUR_FG_ROB_V3_1"], ["SPK_ROBOT", "BUR_FG_ROB_V3_2"],
	["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_V2_1"], ["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_V2_2"],
	["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_V3_1"], ["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_V3_2"],
	["SPK_SULEYMAN", "BUR_FG_SUL_1"], ["SPK_SULEYMAN", "BUR_FG_SUL_2"], ["SPK_SULEYMAN", "BUR_FG_SUL_3"],
	["SPK_GUIDE", "BUR_FG_GUI_1"], ["SPK_GUIDE", "BUR_FG_GUI_2"], ["SPK_ROBOT", "BUR_FG_ROB_1"],
	["SPK_ROBOT", "BUR_FG_ROB_2"], ["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_1"], ["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_2"],
	["SPK_NAPOLEON", "BUR_FG_NAP_1"], ["SPK_NAPOLEON", "BUR_FG_NAP_2"], ["SPK_NAPOLEON", "BUR_FG_NAP_3"],
	["SPK_HITLER", "BUR_FG_HIT_R"], ["SPK_NAPOLEON", "BUR_FG_NAP_4"], ["SPK_HITLER", "BUR_FG_HIT_1"],
	["SPK_HITLER", "BUR_FG_HIT_2"], ["SPK_CLEOPATRA", "BUR_FG_CLE_1"], ["SPK_CLEOPATRA", "BUR_FG_CLE_2"],
	["SPK_CAESAR", "BUR_FG_CAE_1"], ["SPK_CAESAR", "BUR_FG_CAE_2"], ["SPK_CAESAR", "BUR_FG_CAE_3"],
	["SPK_SHAKESPEARE", "BUR_FG_SHK_R"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_1"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_2"],
	["SPK_LEONARDO", "BUR_FG_LEO_1"], ["SPK_LEONARDO", "BUR_FG_LEO_2"], ["SPK_LEONARDO", "BUR_FG_LEO_3"],
	["SPK_EINSTEIN", "BUR_FG_EIN_1"], ["SPK_EINSTEIN", "BUR_FG_EIN_2"], ["SPK_GENGHIS", "BUR_FG_GEN_1"],
	["SPK_GENGHIS", "BUR_FG_GEN_2"], ["SPK_COLUMBUS", "BUR_FG_COL_1"], ["SPK_COLUMBUS", "BUR_FG_COL_2"],
	["SPK_NIHAT", "BUR_BLIND"], ["SPK_NIHAT", "BUR_BLIND_2"], ["SPK_NIHAT", "BUR_CLOCKKNOB"],
	["SPK_NIHAT", "BUR_CLOCKKNOB_2"], ["SPK_NIHAT", "BUR_TYPEWRITER"], ["SPK_NIHAT", "BUR_TYPEWRITER_2"],
	["SPK_NIHAT", "BUR_STAMP_OK"], ["SPK_NIHAT", "BUR_STAMP_NO"], ["SPK_NIHAT", "BUR_STAMP_MISSING"],
	["SPK_NIHAT", "BUR_TUBE"], ["SPK_NIHAT", "BUR_TUBE_2"], ["SPK_NIHAT", "BUR_DRAWER"], ["SPK_NIHAT", "BUR_DRAWER_2"],
	["SPK_NIHAT", "BUR_DRAWER_3"], ["SPK_NIHAT", "BUR_FOUNDER"], ["SPK_NIHAT", "BUR_FOUNDER_2"],
	["SPK_NIHAT", "BUR_CALENDAR"], ["SPK_NIHAT", "BUR_CALENDAR_2"], ["SPK_NIHAT", "BUR_GLOBE"],
	["SPK_NIHAT", "BUR_GLOBE_2"], ["SPK_NIHAT", "BUR_GLOBE_3"], ["SPK_NIHAT", "BUR_SECOND_1"],
	["SPK_NIHAT", "BUR_SECOND_2"], ["SPK_NIHAT", "BUR_SECOND_3"], ["SPK_NIHAT", "BUR_SECOND_4"],
	["SPK_NIHAT", "BUR_SECOND_ALL"], ["SPK_NIHAT", "BUR_NOTICE_A"], ["SPK_NIHAT", "BUR_NOTICE_A_2"],
	["SPK_NIHAT", "BUR_NOTICE_B"], ["SPK_NIHAT", "BUR_NOTICE_C"], ["SPK_NIHAT", "BUR_NOTICE_D"],
	["SPK_NIHAT", "BUR_CCLOCK0"], ["SPK_NIHAT", "BUR_CCLOCK1"], ["SPK_NIHAT", "BUR_CCLOCK2"],
	["SPK_NIHAT", "BUR_CCLOCK3"], ["SPK_NIHAT", "BUR_CCLOCK4"], ["SPK_NIHAT", "BUR_COOLER"],
	["SPK_NIHAT", "BUR_COOLER_2"], ["SPK_NIHAT", "BUR_PALM"], ["SPK_NIHAT", "BUR_PALM_2"], ["SPK_CEMAL", "BUR_CEMAL"],
	["SPK_CEMAL", "BUR_CEMAL_2"], ["SPK_ZEKI", "BUR_TROLLEY"], ["SPK_ZEKI", "BUR_TROLLEY_2"],
	["SPK_NIHAT", "BUR_MEHTER"], ["SPK_NIHAT", "BUR_MEHTER_2"], ["SPK_NIHAT", "BUR_TEAPOT"],
	["SPK_NIHAT", "BUR_TEAPOT_2"], ["SPK_NECMI", "BUR_NECMI"], ["SPK_NECMI", "BUR_NECMI_2"],
	["SPK_NECMI", "BUR_NECMI_3"], ["SPK_NIHAT", "BUR_DISPLAY"], ["SPK_NIHAT", "BUR_DISPLAY_2"],
	["SPK_NIHAT", "BUR_TICKET"], ["SPK_NIHAT", "BUR_TICKET_2"], ["SPK_NIHAT", "BUR_TICKET_3"],
	["SPK_NIHAT", "BUR_GHOST"], ["SPK_NIHAT", "BUR_GHOST_2"], ["SPK_NIHAT", "BUR_GHOST_3"], ["SPK_SABRI", "BUR_BELL"],
	["SPK_SABRI", "BUR_BELL_2"], ["SPK_NIHAT", "BUR_NOKIA"], ["SPK_NIHAT", "BUR_NOKIA_2"], ["SPK_NIHAT", "BUR_SANDAL"],
	["SPK_NIHAT", "BUR_SANDAL_2"], ["SPK_NIHAT", "BUR_LOSTSHELF"], ["SPK_NIHAT", "BUR_LOSTSHELF_2"],
	["SPK_NIHAT", "BUR_LOSTSHELF_3"], ["SPK_NIHAT", "BUR_LOSTSHELF_4"], ["SPK_NIHAT", "BUR_TOLGA_FILE"],
	["SPK_NIHAT", "BUR_TOLGA_FILE_2"], ["SPK_NIHAT", "BUR_ARCHDRAWER"], ["SPK_NIHAT", "BUR_ARCHDRAWER_2"],
	["SPK_HATICE", "BUR_HATICE"], ["SPK_HATICE", "BUR_HATICE_2"], ["SPK_NURAN", "BUR_PARADOKS"],
	["SPK_NURAN", "BUR_PARADOKS_2"], ["SPK_NURAN", "BUR_PARADOKS_3"], ["SPK_NIHAT", "BUR_DIRECTOR"],
	["SPK_NIHAT", "BUR_DIRECTOR_2"], ["SPK_NIHAT", "BUR_DIRECTOR_3"], ["SPK_NIHAT", "BUR_REGWALL"],
	["SPK_NIHAT", "BUR_REGWALL_2"], ["SPK_NIHAT", "BUR_ATRIUMWIN"], ["SPK_NIHAT", "BUR_ATRIUMWIN_2"],
	["SPK_NIHAT", "BUR_TIMELINE"], ["SPK_NIHAT", "BUR_TIMELINE_2"], ["SPK_NIHAT", "BUR_PENDULUM"],
	["SPK_NIHAT", "BUR_PENDULUM_2"]]

var bark_speaker := "SPK_NIHAT"
var player: Player
var hud: Hud
var _handlers := {}       # kimlik → Callable() (etkileşim)
var _prompts := {}        # kimlik → istem anahtarı (UI_BUR_*)
var _prompt_args := {}    # kimlik → isteme konan ad anahtarı ("Konuş: %s")
var _nihat_only := {}     # kimlik → true: yalnız Nihat oynarken
var _cycles := {}         # kimlik → sayaç (replik varyantları sırayla)
var _spinners: Array = []         # [Node3D, eksen Vector3, hız rad/sn]: dişliler, saat ibreleri
var _bobbers: Array = []          # [Node3D, taban y, genlik, hız, faz]: hayaletler, süzülenler
var _fog_t := 0.0
var _focus_bur := ""


## Etkileşimli nesne kaydı: görünmez kutu + istem + iş. fn çağrılınca hud/player hazırdır.
func _reg(id: String, size: Vector3, pos: Vector3, prompt_key: String, fn: Callable, parent: Node3D = null, nihat_only := true) -> StaticBody3D:
	_handlers[id] = fn
	_prompts[id] = prompt_key
	if nihat_only:
		_nihat_only[id] = true
	return Props.interactable(parent if parent else self, id, size, pos)


func _active(id: String) -> bool:
	if not _handlers.has(id):
		return false
	if _nihat_only.has(id) and (player == null or player.hand_style != "nihat"):
		return false
	return true


## Bölümler de sorabilir (Bölüm 3 kendi isteminin yanında bunu kullanır)
func prompt_for(id: String) -> String:
	return _prompt_text(id) if _active(id) else ""


func _prompt_text(id: String) -> String:
	var t := tr(_prompts[id])
	if _prompt_args.has(id):
		t = t % tr(_prompt_args[id])
	return t


func handle_interact(id: String) -> bool:
	if not _active(id):
		return false
	if player and player.frozen:
		return true
	(_handlers[id] as Callable).call()
	return true


## Oyuncunun sinyallerine bağlanır (bölüm hangisi olursa olsun): istem ve etkileşim Büro'nun kendi kimlikleri için.
func _attach() -> void:
	if not is_inside_tree():
		return
	player = get_tree().get_first_node_in_group("player") as Player
	hud = get_tree().get_first_node_in_group("hud") as Hud
	if player == null:
		return
	if not player.focus_changed.is_connected(_on_focus):
		player.focus_changed.connect(_on_focus)
		player.interacted.connect(_on_interacted)


func _on_focus(id: String) -> void:
	if hud == null:
		return
	if _active(id):
		_focus_bur = id
		hud.set_prompt.call_deferred(_prompt_text(id))      # bölümün kendi istem temizliğinden sonra
	elif _focus_bur != "":
		_focus_bur = ""
		if id == "":
			hud.set_prompt.call_deferred("")      # bölüm istemini kendisi temizlemiyorsa (13, 17) Büro'nunki kalmasın


func _on_interacted(id: String) -> void:
	if not visible or hud == null:
		return
	if handle_interact(id) and _active(id) and player and player.focus_id == id:
		hud.set_prompt.call_deferred(_prompt_text(id))      # bölüm etkileşimden sonra istemi silebiliyor (Bölüm 3)


## Nesne repliği (oyuncunun sesi); konuşan verilirse o (memurlar)
func _say(key: String, secs := 3.5, spk := "") -> void:
	if hud:
		hud.bark(spk if spk != "" else bark_speaker, key, secs)


## Sıradaki varyant: keys dizisinden sırayla (son elemandan sonra başa döner)
func _next(id: String, keys: Array) -> String:
	var n: int = _cycles.get(id, 0)
	_cycles[id] = n + 1
	return keys[n % keys.size()]


func _count(id: String) -> int:
	return int(_cycles.get(id, 0))


## İki dilli tabela: İngilizce oynanırken en metni (Props.LABEL_EN'e her yazıyı eklemek yerine)
func _lbl(parent: Node3D, text_tr: String, text_en: String, pos: Vector3, size := 32, color := Color.WHITE, rot := Vector3.ZERO, max_w := 0.0) -> Label3D:
	var t := text_en if TranslationServer.get_locale().begins_with("en") and text_en != "" else text_tr
	return Props.label(parent, t, pos, size, color, rot, max_w)


func _bulb(pos: Vector3, color: Color, energy: float, range_m: float, shadow := false, parent: Node3D = null) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = range_m
	l.shadow_enabled = shadow
	(parent if parent else self).add_child(l)
	return l


## Sahte ışık: zemine ya da duvara toplamsal, kenarı sönen dörtgen (gerçek ışık maliyeti olmadan sızan çağ ışığı)
static var _glow_tex: GradientTexture2D
func _glow(parent: Node3D, pos: Vector3, size: Vector2, color: Color, rot := Vector3(-90, 0, 0), strength := 1.0) -> MeshInstance3D:
	if _glow_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		_glow_tex = GradientTexture2D.new()
		_glow_tex.gradient = g
		_glow_tex.fill = GradientTexture2D.FILL_RADIAL
		_glow_tex.fill_from = Vector2(0.5, 0.5)
		_glow_tex.fill_to = Vector2(1.0, 0.5)
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_texture = _glow_tex
	m.albedo_color = Color(color.r * strength, color.g * strength, color.b * strength, 1.0)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi


## Kayıp saniyeler (5 gizli, kozmetik): ev sahibi nesneye ikinci etkileşimde altın bir disk fışkırır.
func _second(idx: int, at: Vector3) -> bool:
	var mask := int(GameState.flags.get("bureau_seconds", 0))
	if mask & (1 << idx):
		return false
	mask |= 1 << idx
	GameState.flags["bureau_seconds"] = mask
	var n := 0
	for i in 5:
		if mask & (1 << i):
			n += 1
	var d := Node3D.new()
	add_child(d)
	d.position = at
	Props.cyl(d, 0.06, 0.012, Vector3.ZERO, Color("ffd24a"), Vector3(90, 0, 0), 12, -1.0, 2.5)
	var tw := d.create_tween()
	tw.tween_property(d, "position", at + Vector3(0, 0.7, 0), 0.05 if GameState.autotest else 0.9).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(d, "rotation:y", TAU * 2.0, 0.05 if GameState.autotest else 0.9)
	tw.tween_callback(d.queue_free)
	Audio.sfx("ui_confirm", -6.0, 1.3)
	if hud:
		hud.bark(bark_speaker, "BUR_SECOND_ALL" if n >= 5 else "BUR_SECOND_%d" % n, 5.0 if n >= 5 else 2.8, true)
	_seconds_changed(n)
	return true


func seconds_found() -> int:
	var mask := int(GameState.flags.get("bureau_seconds", 0))
	var n := 0
	for i in 5:
		if mask & (1 << i):
			n += 1
	return n


## Kayıp saniye sayısı değişince (ilan panosundaki sayaç, müdür kapısının ışığı): odaları kuranlar bağlar
signal seconds_changed(n: int)
func _seconds_changed(n: int) -> void:
	seconds_changed.emit(n)


func _process(delta: float) -> void:
	# Sis nefes alır: mor ile camgöbeği arasında 40 sn (düz yeşil sis yerine)
	_fog_t += delta
	if is_instance_valid(env_node) and env_node.environment:
		var k := 0.5 + 0.5 * sin(_fog_t * TAU / 40.0)
		env_node.environment.fog_light_color = Color("2a2238").lerp(Color("1f3a40"), k)
	for s in _spinners:
		var n: Node3D = s[0]
		if is_instance_valid(n):
			n.rotate_object_local(s[1], float(s[2]) * delta)
	for b in _bobbers:
		var n: Node3D = b[0]
		if is_instance_valid(n):
			n.position.y = float(b[1]) + sin(_fog_t * float(b[3]) + float(b[4])) * float(b[2])


func _ready() -> void:
	Audio.voice_space("room")
	_build_env()
	_build_office()
	_build_corridor()
	_build_depot()
	_build_desk()
	_build_lift()
	_build_rooms()
	_build_life()
	_lod_pass()
	_attach.call_deferred()


## Uzaktaki küçük ayrıntılar çizilmez (görünürlük menzili): 84 m'lik koridor boyunca yüzlerce kulp, kâğıt, düğme
## ve küçük yazı her karede çiziliyordu (her biri dış hat geçişiyle iki çizim). Kişiler ve büyük parçalar dokunulmaz.
func _lod_pass() -> void:
	var st: Array = get_children()
	while st.size() > 0:
		var n: Node = st.pop_back()
		if n is Person:
			continue
		st.append_array(n.get_children())
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if mi.mesh == null:
				continue
			var sz := mi.mesh.get_aabb().size
			var sc := mi.global_basis.get_scale()
			var big := maxf(sz.x * absf(sc.x), maxf(sz.y * absf(sc.y), sz.z * absf(sc.z)))
			if big < 0.35:
				mi.visibility_range_end = 14.0
			elif big < 1.2:
				mi.visibility_range_end = 30.0
		elif n is Label3D:
			var lb := n as Label3D
			lb.visibility_range_end = 16.0 if lb.font_size <= 24 else (32.0 if lb.font_size <= 40 else 0.0)
		elif n is OmniLight3D:
			var ol := n as OmniLight3D
			if not ol.shadow_enabled and ol.omni_range < 9.0:
				ol.distance_fade_enabled = true
				ol.distance_fade_begin = 24.0
				ol.distance_fade_length = 8.0


## Odalar (v0.99.96): her biri kendi duvarı, ışığı, yazısı ve etkileşimiyle
func _build_rooms() -> void:
	_rb_build()
	_rc_build()
	_fg_build()


## Canlılık (v0.99.96): memurlar, kapsüller, saatler, sesler
func _build_life() -> void:
	_ld_build()


# ---------------------------------------------------------------- ortam

func _build_env() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("1b1626")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("f1d9b0")
	e.ambient_light_energy = 0.5
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	# Koridor sise gömülür ama sis düz yeşil değil: mor ile camgöbeği arasında nefes alır (_process)
	e.fog_enabled = true
	e.fog_light_color = Color("2a2238")
	e.fog_density = 0.035
	e.glow_enabled = true
	e.glow_intensity = 0.6
	e.glow_hdr_threshold = 1.0
	env.environment = e
	add_child(env)
	env_node = env


func _checker(c1: Color, c2: Color) -> ImageTexture:
	var img := Image.create(2, 2, false, Image.FORMAT_RGB8)
	img.set_pixel(0, 0, c1)
	img.set_pixel(1, 1, c1)
	img.set_pixel(1, 0, c2)
	img.set_pixel(0, 1, c2)
	return ImageTexture.create_from_image(img)


func _floor(size: Vector2, pos: Vector3, c1: Color, c2: Color, tiles: float) -> void:
	var body := Props.solid(self, Vector3(size.x, 0.2, size.y), pos + Vector3(0, -0.1, 0), c1)
	var m := StandardMaterial3D.new()
	m.albedo_texture = _checker(c1, c2)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3(tiles, tiles, tiles)
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.roughness = 0.6
	(body.get_child(0) as MeshInstance3D).material_override = m


func _wall(size: Vector3, pos: Vector3, color := C_WALL) -> void:
	Props.set_pattern(Props.solid(self, size, pos, color), color, "wall")


func _tube(pos: Vector3, lit := true) -> void:
	Props.box(self, Vector3(0.18, 0.06, 1.3), pos, Color("e8f4e0"), Vector3.ZERO, 2.2 if lit else 0.2)
	Props.box(self, Vector3(0.26, 0.04, 1.4), pos + Vector3(0, 0.05, 0), C_METAL)


# ---------------------------------------------------------------- Nihat'ın odası

## Krem üst duvar + petrol yeşili lambri, parke, kilim, kaset tavan, sarkıt lamba, doğu duvarda büyük zaman penceresi.

const _OF_YEARS := ["1071", "1204", "1299", "1453", "1492", "1517", "1683", "1789", "1826", "1908",
	"1923", "1969", "2026", "2150", "MÖ 44", "MÖ 776"]
## Çağlar küresinin durabileceği yerler: [TR, EN]; sonuncusu "Bütçe Yok" (BUR_GLOBE_2 şakası)
const _OF_ERAS := [["Roma", "Rome"], ["Selçuklu", "Seljuk"], ["Bizans", "Byzantium"], ["1453 Kuşatması", "Siege of 1453"],
	["Cumhuriyet", "Republic"], ["Yeniçağ", "Early Modern"], ["2150", "2150"], ["Bütçe Yok", "No Budget"]]

var _of_slats: Array = []             # jaluzi çıtaları (9)
var _of_blind_closed := false
var _of_ring: Node3D                  # saatin rakam halkası (akrepsiz, yalnız döner)
var _of_ring_step := 0
var _of_tw_paper: MeshInstance3D      # daktiloda yükselen kâğıt
var _of_tw_busy := false
var _of_stamp_node: Node3D
var _of_stamp_lbl: Label3D
var _of_stamp_busy := false
var _of_lever: Node3D
var _of_tube_busy := false
var _of_drawer: Node3D
var _of_drawer_lbl: Label3D
var _of_drawer_busy := false
var _of_founder: Node3D
var _of_cal: Node3D
var _of_cal_busy := false
var _of_globe: Node3D
var _of_globe_lbl: Label3D
var _of_globe_busy := false


func _build_office() -> void:
	var w := OFFICE_W
	var d := OFFICE_D
	var h := OFFICE_H
	_of_slats.clear()
	_of_blind_closed = false
	_of_ring_step = 0
	# Zemin: sıcak parke (iki kahve) + kilim; tavan
	_floor(Vector2(w, d), Vector3(0, 0, d / 2), Color("8a6038"), Color("73502e"), 1.2)
	Props.solid(self, Vector3(w, 0.2, d), Vector3(0, h + 0.1, d / 2), C_CEIL)
	Props.box(self, Vector3(3.4, 0.01, 2.4), Vector3(0, 0.005, 2.8), C_RUG_EDGE)
	Props.box(self, Vector3(3.2, 0.012, 2.2), Vector3(0, 0.01, 2.8), C_RUG)
	_of_shell(w, d, h)
	_of_ceiling(w, d, h)
	_of_window()
	_of_desk()
	_of_cabinets()
	_of_wall_art(d)
	_of_clock_and_calendar(w)
	_of_corner_props()
	# Kapının üstünde tabela (koridor tarafı)
	Props.label(self, "DENETÇİ N. ZAMANOĞLU", Vector3(0, 2.55, -0.21), 30, Color("e8e2c8"), Vector3(0, 180, 0), 1.3)


## Duvarlar: krem üst, petrol yeşili lambri, pirinç bant; doğu duvarda pencere boşluğu (z 1.7..4.3, y 0.95..2.55)
func _of_shell(w: float, d: float, h: float) -> void:
	# Arka duvar
	_wall(Vector3(w, h, 0.2), Vector3(0, h / 2, d + 0.1), C_CREAM)
	_of_wain(Vector3(0, 0.5, d - 0.02), Vector3(w, 1.0, 0.04))
	# Batı duvar (z 0.15..1.85, y 1.05..2.25 boş kalır: lambri 1.04'te biter)
	_wall(Vector3(0.2, h, d), Vector3(-w / 2 - 0.1, h / 2, d / 2), C_CREAM)
	_of_wain(Vector3(-w / 2 + 0.02, 0.5, d / 2), Vector3(0.04, 1.0, d))
	# Kapılı ön duvar (koridora açılır, 1.4 m kapı)
	_wall(Vector3(w / 2 - 0.7, h, 0.2), Vector3(-(w / 2 + 0.7) / 2, h / 2, -0.1), C_CREAM)
	_wall(Vector3(w / 2 - 0.7, h, 0.2), Vector3((w / 2 + 0.7) / 2, h / 2, -0.1), C_CREAM)
	_wall(Vector3(1.4, h - 2.3, 0.2), Vector3(0, 2.3 + (h - 2.3) / 2, -0.1), C_CREAM)
	_of_wain(Vector3(-(w / 2 + 0.7) / 2, 0.5, 0.02), Vector3(w / 2 - 0.7, 1.0, 0.04))
	_of_wain(Vector3((w / 2 + 0.7) / 2, 0.5, 0.02), Vector3(w / 2 - 0.7, 1.0, 0.04))
	# Kapı kasası (ceviz)
	Props.box(self, Vector3(0.08, 2.3, 0.26), Vector3(-0.74, 1.15, -0.1), C_WOOD_DARK)
	Props.box(self, Vector3(0.08, 2.3, 0.26), Vector3(0.74, 1.15, -0.1), C_WOOD_DARK)
	Props.box(self, Vector3(1.56, 0.08, 0.26), Vector3(0, 2.34, -0.1), C_WOOD_DARK)
	# Doğu duvar: pencere boşluğunun iki yanı normal duvar, altı/üstü 0.4 m kalın (pencere yuvası)
	_wall(Vector3(0.2, h, 1.7), Vector3(w / 2 + 0.1, h / 2, 0.85), C_CREAM)
	_wall(Vector3(0.2, h, 1.7), Vector3(w / 2 + 0.1, h / 2, 5.15), C_CREAM)
	_wall(Vector3(0.4, 0.95, 2.6), Vector3(w / 2 + 0.2, 0.475, 3.0), C_TEAL)
	_wall(Vector3(0.4, h - 2.55, 2.6), Vector3(w / 2 + 0.2, 2.55 + (h - 2.55) / 2, 3.0), C_CREAM)
	_of_wain(Vector3(w / 2 - 0.02, 0.5, 0.85), Vector3(0.04, 1.0, 1.7))
	_of_wain(Vector3(w / 2 - 0.02, 0.5, 5.15), Vector3(0.04, 1.0, 1.7))


## Lambri: petrol yeşili kutu + üstünde pirinç bant (pos: lambrinin merkezi, y 0.5)
func _of_wain(pos: Vector3, size: Vector3) -> void:
	Props.box(self, size, pos, C_TEAL)
	var bs := Vector3(size.x + (0.02 if size.x < 0.1 else 0.0), 0.05, size.z + (0.02 if size.z < 0.1 else 0.0))
	Props.box(self, bs, Vector3(pos.x, 1.015, pos.z), C_BRASS)


## Kaset tavan kirişleri + sarkıt lamba (gölgeli tungsten) -- floresan yok
func _of_ceiling(w: float, d: float, h: float) -> void:
	for z in [1.5, 4.5]:
		Props.box(self, Vector3(w - 0.2, 0.14, 0.22), Vector3(0, h - 0.07, z), C_WOOD_DARK)
	for x in [-1.5, 1.5]:
		Props.box(self, Vector3(0.22, 0.14, d - 0.2), Vector3(x, h - 0.07, d / 2), C_WOOD_DARK)
	# Sarkıt: ip, abajur (gölge atmaz), ampul
	Props.cyl(self, 0.008, 0.3, Vector3(0, h - 0.15, 3.0), Color("222222"), Vector3.ZERO, 4)
	var shade := Props.cyl(self, 0.3, 0.2, Vector3(0, 2.72, 3.0), Color("2f5a4a"), Vector3.ZERO, 12, 0.07)
	shade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var bulb := Props.ball(self, 0.08, Vector3(0, 2.58, 3.0), Color("ffe6b0"), Vector3.ONE, 8, 2.0)
	bulb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_bulb(Vector3(0, 2.5, 3.0), Color("ffd9a0"), 1.0, 7.0, true)


## BÜYÜK PENCERE (doğu duvar): yuva, ahşap çerçeve, zaman manzarası, pencere oturağı, perde, jaluzi
func _of_window() -> void:
	# Çerçeve: yuvanın iç yüzünü kaplayan ceviz sövesi (0.4 derin) + orta denk
	Props.box(self, Vector3(0.4, 0.1, 2.7), Vector3(3.2, 2.5, 3.0), C_WOOD_DARK)
	Props.box(self, Vector3(0.45, 0.06, 2.8), Vector3(3.18, 0.98, 3.0), C_WOOD)
	Props.box(self, Vector3(0.4, 1.6, 0.1), Vector3(3.2, 1.75, 1.75), C_WOOD_DARK)
	Props.box(self, Vector3(0.4, 1.6, 0.1), Vector3(3.2, 1.75, 4.25), C_WOOD_DARK)
	Props.box(self, Vector3(0.08, 1.5, 0.06), Vector3(3.34, 1.75, 3.0), C_WOOD_DARK)
	# Manzara: gölgelendirici dörtgen, +Z odanın içine baksın (rotasyon y -90: +Z → -x)
	var win := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(2.6, 1.6)
	win.mesh = q
	var sm := ShaderMaterial.new()
	sm.shader = load("res://assets/shaders/time_window.gdshader")
	sm.set_shader_parameter("quad_size", Vector2(2.6, 1.6))
	sm.set_shader_parameter("view_ref", 1.6)
	win.material_override = sm
	win.position = Vector3(3.38, 1.75, 3.0)
	win.rotation_degrees = Vector3(0, -90, 0)
	win.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(win)
	# Görünmez cam: oyuncu oturağa çıkıp yuvaya girmesin
	var gb := StaticBody3D.new()
	gb.position = Vector3(3.3, 1.75, 3.0)
	var gcs := CollisionShape3D.new()
	var gbs := BoxShape3D.new()
	gbs.size = Vector3(0.1, 1.6, 2.6)
	gcs.shape = gbs
	gb.add_child(gcs)
	add_child(gb)
	# Pencere oturağı: ahşap sedir + hardal minder
	Props.solid(self, Vector3(0.5, 0.42, 2.2), Vector3(2.7, 0.21, 3.0), C_WOOD)
	Props.box(self, Vector3(0.46, 0.08, 2.1), Vector3(2.7, 0.46, 3.0), C_MUSTARD)
	# Perdeler: iki yanda toplanmış kalın bordo-altın kumaş, korniş
	for cz: float in [1.45, 4.55]:
		for k in 4:
			var fz := cz - 0.21 + k * 0.14
			Props.box(self, Vector3(0.1 if k % 2 == 0 else 0.16, 2.75, 0.15), Vector3(2.88 - (0.0 if k % 2 == 0 else 0.03), 1.45, fz), Color("8a2a2c") if k % 2 == 0 else Color("a8383a"))
		Props.box(self, Vector3(0.2, 0.06, 0.6), Vector3(2.86, 1.25, cz), C_BRASS)       # perde bağı
	Props.cyl(self, 0.02, 3.9, Vector3(2.85, 2.88, 3.0), C_BRASS, Vector3(90, 0, 0), 8)
	# Jaluzi: 9 çıta; açıkken üstte yığılı, kapalıyken pencereyi örter (ip sağ yanda)
	Props.box(self, Vector3(0.06, 0.06, 2.4), Vector3(3.02, 2.46, 3.0), C_WOOD_DARK)
	for i in 9:
		var s := Props.box(self, Vector3(0.03, 0.17, 2.38), Vector3(3.02, 2.4 + i * 0.012, 3.0), Color("e0d2a8"))
		_of_slats.append(s)
	Props.cyl(self, 0.008, 1.1, Vector3(3.0, 1.9, 4.12), Color("e9dcb8"), Vector3.ZERO, 4)
	Props.ball(self, 0.025, Vector3(3.0, 1.33, 4.12), C_BRASS, Vector3.ONE, 6)
	# Pencereden odaya sızan soğuk mor ışık (gölgesiz)
	_bulb(Vector3(2.5, 1.7, 3.0), Color("9a8cff"), 0.9, 4.5)
	# Etkileşimler. "window" bölüm 3'ün: yuvanın içinde, jaluzinin arkasında
	Props.interactable(self, "window", Vector3(0.3, 1.6, 2.6), Vector3(3.15, 1.75, 3.0))
	_reg("bur_blind", Vector3(0.3, 1.2, 0.5), Vector3(2.85, 1.75, 4.12), "UI_BUR_PULL", _of_blind_use)


func _of_blind_use() -> void:
	_of_blind_closed = not _of_blind_closed
	Audio.sfx("cloth", -8.0)
	var tw := create_tween()
	tw.set_parallel(true)
	for i in _of_slats.size():
		var s: Node3D = _of_slats[i]
		if not is_instance_valid(s):
			continue
		var ty: float = (2.4 - i * 0.18) if _of_blind_closed else (2.4 + i * 0.012)
		tw.tween_property(s, "position:y", ty, 0.5 + i * 0.05).set_trans(Tween.TRANS_SINE)
	_say("BUR_BLIND" if _of_blind_closed else "BUR_BLIND_2")


## Masa, sandalye, daktilo, yeşil lamba, damga takımı, pnömatik tüp ve kolu
func _of_desk() -> void:
	var desk_z := 4.3
	Props.set_pattern(Props.solid(self, Vector3(2.2, 0.08, 1.0), Vector3(0, 0.78, desk_z), C_WOOD), C_WOOD, "wood")
	for x in [-1.0, 1.0]:
		Props.box(self, Vector3(0.12, 0.74, 0.9), Vector3(x, 0.37, desk_z), C_WOOD_DARK)
	Props.box(self, Vector3(0.5, 0.05, 0.5), Vector3(0, 0.48, desk_z + 0.9), C_WOOD_DARK)
	Props.box(self, Vector3(0.5, 0.6, 0.05), Vector3(0, 0.8, desk_z + 1.15), C_WOOD_DARK)
	_typewriter(Vector3(0.45, 0.82, desk_z - 0.05), 0.0)
	# Daktiloda yükselen kâğıt (başta gizli)
	_of_tw_paper = Props.box(self, Vector3(0.26, 0.2, 0.004), Vector3(0.45, 1.1, 4.07), Color("fffbe8"))
	_of_tw_paper.visible = false
	# Dosya (pnömatik tüpten gelecek)
	file_node = Node3D.new()
	file_node.position = Vector3(-0.45, 0.83, desk_z - 0.15)
	add_child(file_node)
	Props.box(file_node, Vector3(0.36, 0.03, 0.26), Vector3.ZERO, Color("c9a45a"))
	Props.box(file_node, Vector3(0.2, 0.005, 0.05), Vector3(0, 0.017, -0.05), Color("a8242a"))
	Props.label(file_node, "1453-T", Vector3(0.0, 0.021, 0.04), 30, Color("3a2a18"), Vector3(-90, 0, 0), 0.22)
	file_node.visible = false
	Props.interactable(file_node, "file", Vector3(0.5, 0.3, 0.4), Vector3(0, 0.1, 0)).collision_layer = 0
	# Pnömatik pirinç tüp: tavandan masanın köşesine inen kap
	Props.cyl(self, 0.09, 2.1, Vector3(-1.0, 1.95, 4.6), C_BRASS, Vector3.ZERO, 10)
	Props.cyl(self, 0.13, 0.12, Vector3(-1.0, 0.88, 4.6), C_BRASS, Vector3.ZERO, 10)
	capsule = Node3D.new()
	capsule.position = Vector3(-1.0, 2.9, 4.6)
	add_child(capsule)
	Props.cyl(capsule, 0.07, 0.22, Vector3.ZERO, Color("6f8a96"), Vector3.ZERO, 8)
	capsule.visible = false
	# Kırmızı kol tüpün yanında
	Props.box(self, Vector3(0.1, 0.05, 0.07), Vector3(-0.78, 0.845, 4.6), C_WOOD_DARK)
	_of_lever = Node3D.new()
	_of_lever.position = Vector3(-0.78, 0.87, 4.6)
	add_child(_of_lever)
	Props.cyl(_of_lever, 0.012, 0.2, Vector3(0, 0.1, 0), Color("b8323a"), Vector3.ZERO, 6)
	Props.ball(_of_lever, 0.03, Vector3(0, 0.21, 0), Color("b8323a"), Vector3.ONE, 8)
	_reg("bur_tube", Vector3(0.5, 0.8, 0.5), Vector3(-1.0, 1.25, 4.6), "UI_BUR_PULL", _of_tube_use)
	# Yeşil bankacı lambası + küçük sıcak ışık
	Props.box(self, Vector3(0.14, 0.025, 0.1), Vector3(-0.35, 0.8325, 4.62), C_BRASS)
	Props.cyl(self, 0.008, 0.24, Vector3(-0.35, 0.965, 4.62), C_BRASS, Vector3.ZERO, 5)
	Props.cyl(self, 0.055, 0.26, Vector3(-0.35, 1.1, 4.62), Color("1f6a45"), Vector3(0, 0, 90), 10, -1.0, 0.25)
	_glow(self, Vector3(-0.35, 0.83, 4.55), Vector2(0.7, 0.5), Color("ffd890"), Vector3(-90, 0, 0), 0.35)     # masaya düşen ışık
	# Damga takımı: kırmızı ped, sap damga, iki form
	Props.box(self, Vector3(0.14, 0.015, 0.1), Vector3(0.82, 0.8275, 3.95), Color("a8242a"))
	_of_stamp_node = Node3D.new()
	_of_stamp_node.position = Vector3(0.98, 0.82, 3.95)
	add_child(_of_stamp_node)
	Props.box(_of_stamp_node, Vector3(0.08, 0.025, 0.05), Vector3(0, 0.0125, 0), C_WOOD_DARK)
	Props.cyl(_of_stamp_node, 0.02, 0.1, Vector3(0, 0.075, 0), C_WOOD, Vector3.ZERO, 8)
	Props.ball(_of_stamp_node, 0.03, Vector3(0, 0.14, 0), C_WOOD, Vector3.ONE, 8)
	Props.box(self, Vector3(0.22, 0.004, 0.3), Vector3(0.93, 0.822, 4.42), C_PAPER, Vector3(0, -6, 0))
	Props.box(self, Vector3(0.22, 0.004, 0.3), Vector3(0.95, 0.826, 4.4), Color("f4eed8"), Vector3(0, 8, 0))
	_reg("bur_stamp", Vector3(0.45, 0.3, 0.6), Vector3(0.98, 0.97, 4.15), "UI_BUR_STAMP", _of_stamp_use)
	_reg("bur_typewriter", Vector3(0.6, 0.4, 0.5), Vector3(0.45, 1.0, 4.25), "UI_BUR_USE", _of_typewriter_use)


func _of_typewriter_use() -> void:
	_say(_next("bur_typewriter", ["BUR_TYPEWRITER", "BUR_TYPEWRITER_2"]))
	if _of_tw_busy or not is_instance_valid(_of_tw_paper):
		return
	_of_tw_busy = true
	Audio.sfx("typewriter", -8.0)
	_of_tw_paper.position.y = 1.1
	_of_tw_paper.visible = true
	var tw := create_tween()
	tw.tween_property(_of_tw_paper, "position:y", 1.3, 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func(): Audio.sfx("typewriter_bell", -8.0))
	tw.tween_interval(2.2)
	tw.tween_callback(_of_typewriter_done)


func _of_typewriter_done() -> void:
	if is_instance_valid(_of_tw_paper):
		_of_tw_paper.visible = false
		_of_tw_paper.position.y = 1.1
	_of_tw_busy = false


func _of_stamp_use() -> void:
	if _of_stamp_busy or not is_instance_valid(_of_stamp_node):
		return
	var idx: int = _count("bur_stamp") % 3
	var key: String = _next("bur_stamp", ["BUR_STAMP_OK", "BUR_STAMP_NO", "BUR_STAMP_MISSING"])
	_of_stamp_busy = true
	var rest := Vector3(0.98, 0.82, 3.95)
	var spot := Vector3(0.95, 0.83, 4.4)
	var tw := create_tween()
	tw.tween_property(_of_stamp_node, "position", rest + Vector3(0, 0.1, 0), 0.15)
	tw.tween_property(_of_stamp_node, "position", spot + Vector3(0, 0.1, 0), 0.25).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_of_stamp_node, "position", spot, 0.1)
	tw.tween_callback(_of_stamp_hit.bind(idx, key))
	tw.tween_property(_of_stamp_node, "position", spot + Vector3(0, 0.1, 0), 0.12)
	tw.tween_property(_of_stamp_node, "position", rest, 0.25).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_of_stamp_done)


func _of_stamp_hit(idx: int, key: String) -> void:
	Audio.sfx("stamp", -4.0)
	if is_instance_valid(_of_stamp_lbl):
		_of_stamp_lbl.queue_free()
	var tr_txt := ["ONAYLANDI", "RED", "EKSİK EVRAK"]
	var en_txt := ["APPROVED", "REJECTED", "MISSING"]
	var cols := [Color("2a6a3a"), Color("a8242a"), Color("b86a1a")]
	_of_stamp_lbl = _lbl(self, tr_txt[idx], en_txt[idx], Vector3(0.95, 0.832, 4.4), 36, cols[idx], Vector3(-90, 180, 0), 0.2)
	_say(key)


func _of_stamp_done() -> void:
	_of_stamp_busy = false


func _of_tube_use() -> void:
	_say(_next("bur_tube", ["BUR_TUBE", "BUR_TUBE_2"]))
	if _of_tube_busy or not is_instance_valid(_of_lever):
		return
	_of_tube_busy = true
	Audio.sfx("whoosh_fly", -8.0)
	var lt := create_tween()
	lt.tween_property(_of_lever, "rotation_degrees:x", -50.0, 0.2)
	lt.tween_property(_of_lever, "rotation_degrees:x", 0.0, 0.35).set_trans(Tween.TRANS_BACK)
	lt.tween_callback(_of_tube_done)
	# Ayrı, boş bir kapsül (Bölüm 3'ün `capsule`ına dokunmaz): tüpün dışında bir manşon gibi fırlar
	var cap := Node3D.new()
	cap.position = Vector3(-1.0, 1.0, 4.6)
	add_child(cap)
	Props.cyl(cap, 0.1, 0.2, Vector3.ZERO, Color("6f8a96"), Vector3.ZERO, 8)
	var ct := cap.create_tween()
	ct.tween_property(cap, "position:y", 2.95, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	ct.tween_callback(cap.queue_free)


func _of_tube_done() -> void:
	_of_tube_busy = false


## Dosya dolapları (sol: çekmeceli, üstünde radyo; sağ: saksı) -- ayrıca "plant"
func _of_cabinets() -> void:
	for x in [-2.5, 2.5]:
		Props.set_pattern(Props.solid(self, Vector3(0.6, 1.4, 0.6), Vector3(x, 0.7, 5.55), Color("6f7a70")), Color("6f7a70"), "wall")
		for i in 3:
			if x < 0.0 and i == 1:
				continue       # ortadaki çekmece hareketli
			Props.box(self, Vector3(0.5, 0.02, 0.02), Vector3(x, 0.35 + i * 0.42, 5.24), C_BRASS)
	# Hareketli çekmece (sol dolap, orta): ön yüz, tutamak, tepsi, klasör, yıl etiketi
	_of_drawer = Node3D.new()
	_of_drawer.position = Vector3(-2.5, 0.77, 5.24)
	add_child(_of_drawer)
	Props.box(_of_drawer, Vector3(0.5, 0.36, 0.03), Vector3(0, 0, -0.02), Color("5c6e66"))
	Props.box(_of_drawer, Vector3(0.14, 0.025, 0.025), Vector3(0, 0.05, -0.045), C_BRASS)
	Props.box(_of_drawer, Vector3(0.46, 0.02, 0.5), Vector3(0, -0.15, 0.25), C_WOOD_DARK)
	Props.box(_of_drawer, Vector3(0.34, 0.03, 0.4), Vector3(0, -0.125, 0.25), Color("c9a45a"))
	_of_drawer_lbl = Props.label(_of_drawer, "MÖ 776", Vector3(0, -0.108, 0.2), 34, Color("3a2a18"), Vector3(-90, 180, 0), 0.3)
	_of_drawer_lbl.visible = false
	_reg("bur_drawer", Vector3(0.5, 0.4, 0.4), Vector3(-2.5, 0.77, 5.2), "UI_BUR_OPEN", _of_drawer_use)
	# Radyo (sol dolabın üstünde)
	Props.box(self, Vector3(0.34, 0.2, 0.16), Vector3(-2.5, 1.5, 5.55), Color("8a5a30"))
	Props.box(self, Vector3(0.15, 0.13, 0.01), Vector3(-2.56, 1.5, 5.468), Color("2b2118"))
	Props.cyl(self, 0.02, 0.02, Vector3(-2.4, 1.54, 5.465), C_BRASS, Vector3(90, 0, 0), 8)
	Props.cyl(self, 0.02, 0.02, Vector3(-2.4, 1.47, 5.465), C_BRASS, Vector3(90, 0, 0), 8)
	Props.cyl(self, 0.004, 0.3, Vector3(-2.38, 1.7, 5.6), C_METAL, Vector3(0, 0, -20), 4)
	# Saksı bitkisi (sağ dolabın üstünde) + "plant" etkileşimi (Bölüm 3)
	Props.cyl(self, 0.18, 0.35, Vector3(2.5, 1.58, 5.55), Color("8a5a3a"), Vector3.ZERO, 8, 0.22)
	for i in 5:
		Props.cyl(self, 0.02, 0.4, Vector3(2.5 + (i - 2) * 0.05, 1.9, 5.55), Color("4f7a3a") if i % 2 == 0 else Color("62924a"), Vector3(0, i * 30, 20 - i * 10), 4)
	Props.interactable(self, "plant", Vector3(0.5, 0.6, 0.5), Vector3(2.5, 1.8, 5.55))


func _of_drawer_use() -> void:
	if _of_drawer_busy or not is_instance_valid(_of_drawer):
		return
	_of_drawer_busy = true
	var year: String = _OF_YEARS[randi() % _OF_YEARS.size()]
	_of_drawer_lbl.text = year
	_of_drawer_lbl.visible = true
	Audio.sfx("wood_creak", -8.0)
	_say(_next("bur_drawer", ["BUR_DRAWER", "BUR_DRAWER_2", "BUR_DRAWER_3"]))
	var third := _count("bur_drawer") == 3
	var tw := create_tween()
	tw.tween_property(_of_drawer, "position:z", 4.82, 0.4).set_trans(Tween.TRANS_SINE)
	if third:
		tw.tween_interval(1.3)
		tw.tween_callback(_of_drawer_second)
		tw.tween_interval(1.2)
	else:
		tw.tween_interval(2.4)
	tw.tween_property(_of_drawer, "position:z", 5.24, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_of_drawer_done)


func _of_drawer_second() -> void:
	_second(0, Vector3(-2.5, 0.77, 5.24) + Vector3(0, 0.2, 0))


func _of_drawer_done() -> void:
	if is_instance_valid(_of_drawer_lbl):
		_of_drawer_lbl.visible = false
	_of_drawer_busy = false


## Arka duvar: Form Z-1 (Bölüm 3), kurucu çerçevesi, "Ayın Memuru" çerçevesi
func _of_wall_art(d: float) -> void:
	# Form Z-1: arka duvarda çerçeve
	var fz := Node3D.new()
	fz.position = Vector3(0, 1.95, d - 0.02)
	fz.rotation_degrees.y = 180
	add_child(fz)
	Props.box(fz, Vector3(0.78, 0.98, 0.04), Vector3(0, 0, 0.0), C_BRASS)
	Props.box(fz, Vector3(0.66, 0.86, 0.045), Vector3(0, 0, 0.0), C_PAPER)
	Props.label(fz, "ZAMAN BÜROSU", Vector3(0, 0.33, 0.03), 26, Color("2a2a2a"), Vector3.ZERO, 0.5)
	Props.label(fz, "FORM Z-1", Vector3(0, 0.25, 0.03), 34, Color("8a1f1f"), Vector3.ZERO, 0.4)
	Props.label(fz, "KURULUŞ BELGESİ", Vector3(0, 0.17, 0.03), 18, Color("3a3a3a"), Vector3.ZERO, 0.4)
	for i in 6:
		Props.box(fz, Vector3(0.5, 0.008, 0.005), Vector3(0, 0.08 - i * 0.055, 0.025), Color("9a9a90"))
	Props.label(fz, "Kurucu:", Vector3(-0.17, -0.28, 0.03), 18, Color("3a3a3a"), Vector3.ZERO, 0.2)
	Props.label(fz, "T.", Vector3(0.08, -0.29, 0.03), 44, Color("1a2a6a"), Vector3.ZERO, 0.12)
	Props.cyl(fz, 0.07, 0.01, Vector3(0.2, -0.33, 0.03), Color("b8323a"), Vector3(90, 0, 0), 12)
	Props.interactable(self, "formz1", Vector3(0.9, 1.1, 0.4), Vector3(0, 1.95, d - 0.2))
	# Kurucunun çerçevesi: boş altın çerçeve, solmamış dikdörtgen, pirinç plaka "KURUCU"
	_of_founder = Node3D.new()
	_of_founder.position = Vector3(-1.5, 1.95, d - 0.02)
	_of_founder.rotation_degrees.y = 180
	add_child(_of_founder)
	Props.box(_of_founder, Vector3(0.62, 0.8, 0.03), Vector3.ZERO, Color("c9a23a"))
	Props.box(_of_founder, Vector3(0.5, 0.68, 0.035), Vector3.ZERO, Color("f6ecd0"))
	Props.box(_of_founder, Vector3(0.22, 0.05, 0.02), Vector3(0, -0.46, 0.015), C_BRASS)
	Props.label(_of_founder, "KURUCU", Vector3(0, -0.46, 0.03), 20, Color("3a2a18"), Vector3.ZERO, 0.19)
	_reg("bur_founder", Vector3(0.7, 0.9, 0.4), Vector3(-1.5, 1.9, 5.8), "UI_BUR_LOOK", _of_founder_use)
	# Ayın Memuru: koyu zeminde silüet
	var am := Node3D.new()
	am.position = Vector3(-2.35, 1.95, d - 0.02)
	am.rotation_degrees.y = 180
	add_child(am)
	Props.box(am, Vector3(0.5, 0.62, 0.03), Vector3.ZERO, C_BRASS)
	Props.box(am, Vector3(0.4, 0.52, 0.035), Vector3.ZERO, Color("2d3a48"))
	Props.ball(am, 0.07, Vector3(0, 0.06, 0.03), Color("d9b48f"), Vector3.ONE, 8)
	Props.box(am, Vector3(0.3, 0.14, 0.01), Vector3(0, -0.1, 0.03), Color("1f2a33"))
	Props.box(am, Vector3(0.16, 0.035, 0.02), Vector3(0, -0.36, 0.015), C_BRASS)


func _of_founder_use() -> void:
	_say(_next("bur_founder", ["BUR_FOUNDER", "BUR_FOUNDER_2"]))
	if not is_instance_valid(_of_founder):
		return
	Audio.sfx("wood_creak", -14.0)
	var tw := create_tween()
	tw.tween_property(_of_founder, "rotation_degrees:z", 4.0, 0.2)
	tw.tween_property(_of_founder, "rotation_degrees:z", 0.0, 0.5).set_trans(Tween.TRANS_BOUNCE)


## Akrepsiz saat (batı duvar, rakam halkası döner) + saat topuzu + yaprak takvim
func _of_clock_and_calendar(w: float) -> void:
	var clock := Node3D.new()
	clock.position = Vector3(-w / 2 + 0.03, 2.2, 3.0)
	clock.rotation_degrees.y = 90
	add_child(clock)
	Props.cyl(clock, 0.28, 0.05, Vector3.ZERO, Color("f4f1e6"), Vector3(90, 0, 0), 20)
	Props.ring(clock, 0.26, 0.3, Vector3.ZERO, C_BRASS, Vector3(90, 0, 0))
	_of_ring = Node3D.new()
	_of_ring.position = Vector3(0, 0, 0.03)
	clock.add_child(_of_ring)
	for i in 12:
		var a := TAU * i / 12.0
		var tick_col := Color("a8242a") if i == 0 else Color("2a2a2a")
		var tick_len := 0.08 if i % 3 == 0 else 0.05
		Props.box(_of_ring, Vector3(0.02, tick_len, 0.01), Vector3(sin(a) * 0.22, cos(a) * 0.22, 0), tick_col, Vector3(0, 0, -rad_to_deg(a)))
	Props.interactable(self, "clock", Vector3(0.3, 0.7, 0.7), Vector3(-w / 2 + 0.2, 2.2, 3.0))
	# Saatin altında pirinç ayar topuzu
	Props.cyl(self, 0.035, 0.06, Vector3(-w / 2 + 0.05, 1.72, 3.0), C_BRASS, Vector3(0, 0, 90), 10)
	_reg("bur_clockknob", Vector3(0.3, 0.25, 0.4), Vector3(-w / 2 + 0.15, 1.7, 3.0), "UI_BUR_SPIN", _of_clockknob_use)
	# Yaprak takvim (z 4.5: bölüm 17'nin panosuna ayrılan z 0.15..1.85 dışında)
	_of_cal = Node3D.new()
	_of_cal.position = Vector3(-w / 2 + 0.03, 1.75, 4.5)
	_of_cal.rotation_degrees.y = 90
	add_child(_of_cal)
	Props.box(_of_cal, Vector3(0.3, 0.42, 0.02), Vector3.ZERO, C_WOOD_DARK)
	Props.box(_of_cal, Vector3(0.26, 0.3, 0.035), Vector3(0, -0.03, 0.02), C_PAPER)
	Props.box(_of_cal, Vector3(0.26, 0.07, 0.03), Vector3(0, 0.17, 0.02), Color("a8242a"))
	_reg("bur_calendar", Vector3(0.3, 0.5, 0.4), Vector3(-w / 2 + 0.12, 1.75, 4.5), "UI_BUR_TAKE", _of_calendar_use)


func _of_clockknob_use() -> void:
	_of_ring_step += 1
	Audio.sfx("timer_tick", -8.0)
	if is_instance_valid(_of_ring):
		var tw := create_tween()
		tw.tween_property(_of_ring, "rotation_degrees:z", -30.0 * _of_ring_step, 0.25).set_trans(Tween.TRANS_BACK)
	_say(_next("bur_clockknob", ["BUR_CLOCKKNOB", "BUR_CLOCKKNOB_2"]))


func _of_calendar_use() -> void:
	_say(_next("bur_calendar", ["BUR_CALENDAR", "BUR_CALENDAR_2"]))
	Audio.sfx("paper_tear", -8.0)
	if _of_cal_busy or not is_instance_valid(_of_cal):
		return
	_of_cal_busy = true
	var leaf := Node3D.new()
	leaf.position = Vector3(0, -0.03, 0.045)
	_of_cal.add_child(leaf)
	Props.box(leaf, Vector3(0.26, 0.3, 0.004), Vector3.ZERO, C_PAPER)
	_lbl(leaf, "BUGÜN", "TODAY", Vector3(0, 0, 0.004), 36, Color("a8242a"), Vector3.ZERO, 0.22)
	var tw := leaf.create_tween()
	tw.tween_property(leaf, "position:y", -1.6, 1.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(leaf, "rotation_degrees:z", 35.0, 1.3)
	tw.parallel().tween_property(leaf, "position:z", 0.3, 1.3)
	tw.tween_property(leaf, "scale", Vector3(0.01, 0.01, 0.01), 0.3)
	tw.tween_callback(leaf.queue_free)
	tw.tween_callback(_of_calendar_done)


func _of_calendar_done() -> void:
	_of_cal_busy = false


## Portmanto (kapının doğusunda) ve çağlar küresi
func _of_corner_props() -> void:
	# Portmanto: ayak, direk, kollar, palto, fötr şapka
	Props.cyl(self, 0.22, 0.03, Vector3(2.45, 0.015, 0.45), C_WOOD_DARK, Vector3.ZERO, 8)
	Props.cyl(self, 0.025, 1.8, Vector3(2.45, 0.9, 0.45), C_WOOD_DARK, Vector3.ZERO, 6)
	Props.box(self, Vector3(0.3, 0.02, 0.02), Vector3(2.45, 1.7, 0.45), C_WOOD_DARK)
	Props.box(self, Vector3(0.02, 0.02, 0.3), Vector3(2.45, 1.7, 0.45), C_WOOD_DARK)
	Props.box(self, Vector3(0.32, 0.7, 0.1), Vector3(2.45, 1.3, 0.32), Color("5a4a3a"))
	Props.cyl(self, 0.17, 0.015, Vector3(2.45, 1.84, 0.45), Color("2e2a28"), Vector3.ZERO, 10)
	Props.cyl(self, 0.09, 0.09, Vector3(2.45, 1.89, 0.45), Color("2e2a28"), Vector3.ZERO, 8)
	# Çağlar küresi: ayaklık, direk, bakır meridyen, dönen küre + kıtalar
	Props.cyl(self, 0.16, 0.03, Vector3(2.3, 0.015, 1.5), C_WOOD_DARK, Vector3.ZERO, 8)
	Props.cyl(self, 0.025, 0.8, Vector3(2.3, 0.45, 1.5), C_WOOD, Vector3.ZERO, 6)
	Props.ring(self, 0.27, 0.285, Vector3(2.3, 1.1, 1.5), Color("b8743a"), Vector3(90, 90, 0))
	_of_globe = Node3D.new()
	_of_globe.position = Vector3(2.3, 1.1, 1.5)
	add_child(_of_globe)
	Props.ball(_of_globe, 0.25, Vector3.ZERO, Color("3a6a98"), Vector3.ONE, 14)
	Props.ball(_of_globe, 0.09, Vector3(0.1, 0.13, 0.2), Color("7a8a4a"), Vector3(1, 0.8, 0.5), 8)
	Props.ball(_of_globe, 0.09, Vector3(-0.2, -0.05, 0.12), Color("7a8a4a"), Vector3(0.6, 1, 0.8), 8)
	Props.ball(_of_globe, 0.09, Vector3(-0.05, 0.1, -0.22), Color("7a8a4a"), Vector3(1, 0.8, 0.5), 8)
	_reg("bur_globe", Vector3(0.6, 0.8, 0.6), Vector3(2.3, 1.15, 1.5), "UI_BUR_SPIN", _of_globe_use)


func _of_globe_use() -> void:
	if _of_globe_busy or not is_instance_valid(_of_globe):
		return
	_of_globe_busy = true
	if is_instance_valid(_of_globe_lbl):
		_of_globe_lbl.queue_free()
		_of_globe_lbl = null
	Audio.sfx("machine_spin", -18.0)
	var pick: int = randi() % _OF_ERAS.size()
	var tw := create_tween()
	tw.tween_property(_of_globe, "rotation:y", _of_globe.rotation.y + TAU * 3.0 + randf() * TAU, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_of_globe_stop.bind(pick))


func _of_globe_stop(pick: int) -> void:
	var era: Array = _OF_ERAS[pick]
	_of_globe_lbl = _lbl(self, era[0], era[1], Vector3(2.3, 1.55, 1.5), 30, Color("ffe9b0"), Vector3(0, -90, 0), 0.6)
	if pick == _OF_ERAS.size() - 1:
		_say("BUR_GLOBE_2")
	else:
		_say(_next("bur_globe", ["BUR_GLOBE", "BUR_GLOBE_3"]))
	_of_globe_busy = false


func _typewriter(pos: Vector3, rot: float) -> Node3D:
	var t := Node3D.new()
	t.position = pos
	t.rotation_degrees.y = rot
	add_child(t)
	Props.box(t, Vector3(0.42, 0.1, 0.34), Vector3(0, 0.05, 0), Color("1f2426"))
	Props.box(t, Vector3(0.4, 0.06, 0.12), Vector3(0, 0.12, -0.08), Color("2b3134"), Vector3(-15, 0, 0))
	Props.cyl(t, 0.035, 0.46, Vector3(0, 0.16, -0.15), Color("15191a"), Vector3(0, 0, 90), 8)
	Props.box(t, Vector3(0.28, 0.2, 0.005), Vector3(0, 0.26, -0.16), C_PAPER, Vector3(-10, 0, 0))
	for r in 3:
		for c in 7:
			Props.box(t, Vector3(0.025, 0.012, 0.025), Vector3(-0.13 + c * 0.043, 0.105 + r * 0.012, 0.06 + r * 0.035 - 0.06), Color("d8d2c0"))
	return t


# ---------------------------------------------------------------- koridor

func _build_corridor() -> void:
	var z1 := -COR_LEN
	var mid := z1 / 2.0
	# Zemin: sıcak linolyum; ortada oksit kırmızısı kilim şeridi, altın kenarlı (düz siyah-beyaz dama yerine)
	_floor(Vector2(COR_W, COR_LEN), Vector3(0, 0, mid), Color("c8b88a"), Color("a08a62"), 1.0)
	Props.box(self, Vector3(1.4, 0.012, COR_LEN - 0.4), Vector3(0, 0.006, mid), C_RUG)
	for sx in [-0.72, 0.72]:
		Props.box(self, Vector3(0.06, 0.014, COR_LEN - 0.4), Vector3(sx, 0.007, mid), C_RUG_EDGE)
	Props.solid(self, Vector3(COR_W, 0.2, COR_LEN), Vector3(0, COR_H + 0.1, mid), C_CEIL)
	# Duvarlar yalnız odaların açıklıkları dışında; açıklıkların üstünde lento (kapı ağzı)
	for side in [-1, 1]:
		var opens: Array = OPEN_W if side < 0 else OPEN_E
		for seg in _solid_ranges(0.0, z1, opens):
			_cor_wall(side, seg[0], seg[1])
		for o in opens:
			var za: float = o[0]
			var zb: float = o[1]
			if (side < 0 and absf(za - (LIFT_Z + 1.0)) < 0.01) or (side > 0 and absf(za - -36.5) < 0.01):
				continue       # asansörün kendi kasası, atriumun sütunları var
			Props.box(self, Vector3(0.2, 0.55, za - zb), Vector3(side * (COR_W / 2 + 0.1), COR_H - 0.275, (za + zb) / 2.0), C_COR_WALL)
			Props.box(self, Vector3(0.24, 0.08, za - zb + 0.2), Vector3(side * (COR_W / 2 + 0.08), COR_H - 0.58, (za + zb) / 2.0), C_WOOD_DARK)
			for zz in [za, zb]:
				Props.box(self, Vector3(0.24, COR_H - 0.55, 0.1), Vector3(side * (COR_W / 2 + 0.08), (COR_H - 0.55) / 2.0, zz), C_WOOD_DARK)
	_wall(Vector3(COR_W, COR_H, 0.2), Vector3(0, COR_H / 2, z1 - 0.1), C_COR_WALL)
	# Tavan floresanları: her yedincisi bozuk (titrer); dört tavan ışığı
	var z := -3.0
	var n := 0
	while z > z1:
		_tube(Vector3(0, COR_H - 0.05, z), n % 7 != 5)
		z -= 5.0
		n += 1
	for lz in [-6.0, -20.0, -30.0, -60.0]:
		_bulb(Vector3(0, COR_H - 0.4, lz), Color("e6f0d8"), 1.0, 11.0)
	# Kapılar: her birinde bir yıl, kanat aralık, ardından çağının ışığı sızar
	for d in DOORS:
		_door(int(d[0]), float(d[1]), String(d[2]))
	# 1453 kapılarının önünde gerçek, titrek turuncu ışık (kuşatma ateşi)
	var fire := _bulb(Vector3(1.2, 1.4, -67.5), Color("ff7a30"), 0.9, 7.0)
	var ft := fire.create_tween().set_loops()
	ft.tween_property(fire, "light_energy", 1.3, 0.35).set_trans(Tween.TRANS_SINE)
	ft.tween_property(fire, "light_energy", 0.7, 0.5).set_trans(Tween.TRANS_SINE)


## [za, zb] aralığında açıklıklar (azalan sırada) dışında kalan dolu duvar parçaları
func _solid_ranges(za: float, zb: float, opens: Array) -> Array:
	var out: Array = []
	var cur := za
	for o in opens:
		if float(o[0]) < cur - 0.01:
			out.append([cur, float(o[0])])
		cur = minf(cur, float(o[1]))
	if cur > zb + 0.01:
		out.append([cur, zb])
	return out


## Koridor duvarı parçası: krem üst, 1,1 m petrol yeşili lambri, pirinç bant, ceviz süpürgelik
func _cor_wall(side: int, za: float, zb: float) -> void:
	var length := za - zb
	var zc := (za + zb) / 2.0
	Props.set_pattern(Props.solid(self, Vector3(0.2, COR_H, length), Vector3(side * (COR_W / 2 + 0.1), COR_H / 2, zc), C_COR_WALL), C_COR_WALL, "wall")
	var xi := side * (COR_W / 2 - 0.015)
	Props.box(self, Vector3(0.03, 1.1, length), Vector3(xi, 0.55, zc), C_COR_LOW)
	Props.box(self, Vector3(0.04, 0.05, length), Vector3(xi, 1.12, zc), C_BRASS)
	Props.box(self, Vector3(0.05, 0.12, length), Vector3(xi, 0.06, zc), C_WOOD_DARK)


func _door(side: int, z: float, year: String) -> void:
	var x := side * (COR_W / 2 - 0.02)
	var col: Color = ERA_COLORS.get(year, Color("e8d8b0"))
	var rot := Vector3(0, -90 * side, 0)
	# Kasa (ceviz) ve kapının ardındaki aydınlık: duvarda çağ renginde parlayan boşluk (kanat aralık durur)
	Props.box(self, Vector3(0.06, 2.3, 0.08), Vector3(x, 1.15, z - 0.54), C_WALNUT)
	Props.box(self, Vector3(0.06, 2.3, 0.08), Vector3(x, 1.15, z + 0.54), C_WALNUT)
	Props.box(self, Vector3(0.06, 0.08, 1.16), Vector3(x, 2.3, z), C_WALNUT)
	Props.box(self, Vector3(0.02, 2.2, 1.0), Vector3(side * (COR_W / 2 + 0.0), 1.1, z), col.darkened(0.35), Vector3.ZERO, 0.9)
	# Kanat: menteşe z+0,5'te, 14° koridora açık
	var hinge := Node3D.new()
	hinge.position = Vector3(x - side * 0.03, 0.0, z + 0.5)
	hinge.rotation_degrees.y = side * 14.0
	add_child(hinge)
	Props.box(hinge, Vector3(0.05, 2.2, 1.0), Vector3(0, 1.1, -0.5), Color("5f4630"))
	Props.box(hinge, Vector3(0.055, 0.5, 0.6), Vector3(0, 1.7, -0.5), col.lerp(Color("dfe8e0"), 0.55), Vector3.ZERO, 0.45)
	Props.ball(hinge, 0.04, Vector3(-side * 0.04, 1.05, -0.85), C_BRASS, Vector3.ONE, 6)
	Props.label(hinge, year, Vector3(-side * 0.035, 1.7, -0.5), 48, Color("2a2a2a"), rot, 0.5)
	# Aralıktan sızan ışık: zeminde yelpaze, kanadın kenarında ince parlak şerit
	_glow(self, Vector3(x - side * 0.45, 0.015, z - 0.35), Vector2(1.3, 1.1), col, Vector3(-90, 0, 0), 0.55)
	Props.box(self, Vector3(0.03, 2.05, 0.04), Vector3(x - side * 0.02, 1.05, z - 0.47), col, Vector3.ZERO, 2.2)
	Props.interactable(self, "door:" + year, Vector3(0.4, 2.0, 1.0), Vector3(x - side * 0.2, 1.1, z))


# ---------------------------------------------------------------- kostüm deposu

func _build_depot() -> void:
	var x0 := COR_W / 2
	var x1 := x0 + 4.4
	var zc := (DEPOT_Z0 + DEPOT_Z1) / 2.0
	var dz := DEPOT_Z0 - DEPOT_Z1
	_floor(Vector2(x1 - x0, dz), Vector3((x0 + x1) / 2, 0, zc), Color("8a7a5a"), Color("7a6a4a"), 1.2)
	Props.solid(self, Vector3(x1 - x0, 0.2, dz), Vector3((x0 + x1) / 2, COR_H + 0.1, zc), Color("b8b6a4"))
	_wall(Vector3(x1 - x0, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, DEPOT_Z0 + 0.1))
	_wall(Vector3(x1 - x0, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, DEPOT_Z1 - 0.1))
	_wall(Vector3(0.2, COR_H, dz), Vector3(x1 + 0.1, COR_H / 2, zc))
	Props.box(self, Vector3(0.04, 0.48, 3.2), Vector3(x0 - 0.03, 3.12, zc), C_TEAL)
	Props.box(self, Vector3(0.03, 0.52, 3.26), Vector3(x0 - 0.015, 3.12, zc), C_BRASS)
	Props.label(self, "KOSTÜM DEPOSU", Vector3(x0 - 0.06, 3.19, zc), 34, Color("f2e6c9"), Vector3(0, -90, 0), 3.0)
	Props.label(self, "Her dönem · Her beden · İade yok", Vector3(x0 - 0.06, 2.99, zc), 16, Color("e8d8a8"), Vector3(0, -90, 0), 3.0)
	_tube(Vector3((x0 + x1) / 2, COR_H - 0.05, zc))
	var l := OmniLight3D.new()
	l.position = Vector3((x0 + x1) / 2, COR_H - 0.5, zc)
	l.light_color = Color("fff0d0")
	l.light_energy = 1.3
	l.omni_range = 6.0
	add_child(l)
	# Tezgâh
	Props.set_pattern(Props.solid(self, Vector3(0.6, 1.05, dz - 1.2), Vector3(x0 + 1.4, 0.525, zc), C_WOOD), C_WOOD, "wood")
	Props.box(self, Vector3(0.7, 0.05, dz - 1.1), Vector3(x0 + 1.4, 1.07, zc), C_WOOD_DARK)
	# Zil ve damga
	Props.cyl(self, 0.06, 0.05, Vector3(x0 + 1.3, 1.12, zc + 1.5), C_BRASS, Vector3.ZERO, 10, 0.02)
	Props.box(self, Vector3(0.08, 0.08, 0.08), Vector3(x0 + 1.4, 1.14, zc - 1.2), Color("3a2a20"))
	# Fötr şapka (Nihat'a verilecek)
	fedora_node = Node3D.new()
	fedora_node.position = Vector3(x0 + 1.3, 1.1, zc)
	add_child(fedora_node)
	Props.cyl(fedora_node, 0.2, 0.02, Vector3(0, 0.01, 0), Color("4a4038"), Vector3.ZERO, 10)
	Props.cyl(fedora_node, 0.12, 0.12, Vector3(0, 0.08, 0), Color("4a4038"), Vector3.ZERO, 8, 0.1)
	Props.cyl(fedora_node, 0.125, 0.03, Vector3(0, 0.035, 0), Color("1f1b18"), Vector3.ZERO, 8)
	fedora_node.visible = false
	# Askılı kostüm rafları: her dönemden
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("e8d9a8"), Color("3a6b3a"), Color("6a3a7a"),
		Color("d8d8d0"), Color("1f2a44"), Color("c98a3a"), Color("8a2b22"), Color("4a4038")]
	for r in 2:
		var rx := x1 - 0.5 - r * 1.3
		Props.cyl(self, 0.025, dz - 1.0, Vector3(rx, 1.9, zc), C_METAL, Vector3(90, 0, 0), 6)
		for k in 9:
			var cz := DEPOT_Z1 + 0.9 + k * (dz - 1.8) / 8.0
			var c: Color = coats[(k + r * 3) % coats.size()]
			Props.box(self, Vector3(0.12, 0.95, 0.42), Vector3(rx, 1.4, cz), c, Vector3(0, 0, 3 - k % 3 * 3))
	# Rafta tarihî başlıklar: Roma miğferi, pudralı peruk, astronot kaskı, bir de fes
	var shelf_x := x1 - 0.25
	Props.box(self, Vector3(0.45, 0.04, dz - 1.0), Vector3(shelf_x, 2.45, zc), C_WOOD_DARK)
	var hz := DEPOT_Z1 + 1.0
	Props.ball(self, 0.15, Vector3(shelf_x, 2.6, hz), Color("c9a24a"), Vector3(1, 0.9, 1.1), 8)
	Props.box(self, Vector3(0.04, 0.12, 0.3), Vector3(shelf_x, 2.78, hz), Color("b3262d"))
	for k in 5:
		Props.ball(self, 0.07, Vector3(shelf_x, 2.55 + (k % 2) * 0.1, hz + 1.2 + (k - 2) * 0.09), Color("f4f1ea"), Vector3.ONE, 6)
	Props.ball(self, 0.17, Vector3(shelf_x, 2.64, hz + 2.4), Color("f0f0f0"), Vector3.ONE, 10)
	Props.box(self, Vector3(0.02, 0.12, 0.2), Vector3(shelf_x - 0.16, 2.64, hz + 2.4), Color("d4a020"), Vector3.ZERO, 0.6)
	Props.cyl(self, 0.1, 0.14, Vector3(shelf_x, 2.54, hz + 3.6), Color("b3262d"), Vector3.ZERO, 8, 0.08)
	# Alan tezgâha doğru uzanır: raf tezgâhın ardında, E ışını (2,4 m) tezgâhın önünden fese yetişmiyordu
	Props.interactable(self, "fezshelf", Vector3(1.4, 0.6, 0.7), Vector3(shelf_x - 0.6, 2.55, hz + 3.6))
	# Depo memuru Asır
	riza = Person.new({"coat": Color("7a6a4a"), "pants": Color("3a3228"), "hair": Color("2a2a2a"), "mustache": true, "glasses": true})
	riza.set_meta("spk", "SPK_RIZA")
	riza.position = RIZA_POS
	riza.rotation_degrees.y = -90
	add_child(riza)
	Props.interactable(self, "riza", Vector3(1.4, 1.8, 2.0), Vector3(x0 + 1.0, 1.0, zc))


# ---------------------------------------------------------------- Başdenetçi'nin masası

func _build_desk() -> void:
	var z := DESK_Z
	Props.set_pattern(Props.solid(self, Vector3(2.4, 0.08, 1.1), Vector3(0, 0.8, z), C_WOOD), C_WOOD, "wood")
	Props.set_pattern(Props.solid(self, Vector3(2.3, 0.76, 0.1), Vector3(0, 0.38, z + 0.5), C_WOOD_DARK), C_WOOD_DARK, "wood")
	# Kâğıt dağları: tavana kadar
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for k in 10:
		var px := -1.0 + (k % 5) * 0.5
		var pz := z - 0.25 + (k / 5) * 0.4
		# Ortada alçak (Başdenetçi görünsün), kenarlarda tavana kadar
		var hgt := rng.randf_range(0.15, 0.3) if absf(px) < 0.3 else rng.randf_range(1.1, 1.9)     # tepe 2.74: 'SIRA' tabelasının altında kalır
		var layer_cols := [C_PAPER, Color("c9a45a"), Color("e8e0c8"), Color("b89a5a"), Color("efe4c4")]
		var yy := 0.84
		var li := k
		while yy < 0.84 + hgt - 0.05:
			var lh := minf(rng.randf_range(0.18, 0.42), 0.84 + hgt - yy)
			Props.box(self, Vector3(0.34 + rng.randf_range(-0.03, 0.03), lh, 0.26 + rng.randf_range(-0.02, 0.02)), Vector3(px + rng.randf_range(-0.025, 0.025), yy + lh / 2, pz), layer_cols[li % layer_cols.size()], Vector3(0, rng.randf_range(-9, 9), 0))
			yy += lh
			li += 1
		if hgt > 1.0:
			Props.box(self, Vector3(0.05, 0.012, 0.28), Vector3(px, 0.84 + hgt * 0.62, pz), Color("b8323a"))     # kırmızı bant
	Props.box(self, Vector3(0.3, 0.02, 0.22), Vector3(0.9, 0.85, z + 0.25), Color("b8323a"))
	Props.label(self, "BAŞDENETÇİ", Vector3(0, 1.0, z + 0.56), 28, Color("f2e6c9"), Vector3.ZERO, 1.0)
	Props.label(self, "M. ZAMANOVA", Vector3(0, 0.88, z + 0.56), 22, Color("d8d0b8"), Vector3.ZERO, 1.0)
	# Tepede 'SIRA NUMARANIZ' tabelası
	Props.box(self, Vector3(1.0, 0.35, 0.05), Vector3(0, 3.0, z + 0.2), Color("1a1f1a"))
	Props.label(self, "SIRA: 1453", Vector3(0, 3.0, z + 0.23), 40, Color("ff5a4a"), Vector3.ZERO, 0.9)
	var l := OmniLight3D.new()
	l.position = Vector3(0, 2.5, z + 1.5)
	l.light_color = Color("fff4d8")
	l.light_energy = 1.2
	l.omni_range = 5.0
	add_child(l)
	mufide = Person.new({"coat": Color("6b3a4a"), "pants": Color("3a2a30"), "hair": Color("9a9a9a"), "hat": "bun", "glasses": true, "skirt": true, "skin": Color("e8b894")})
	mufide.set_meta("spk", "SPK_MUFIDE")
	mufide.position = MUFIDE_POS
	add_child(mufide)
	Props.interactable(self, "mufide", Vector3(2.4, 2.0, 1.6), Vector3(0, 1.0, z + 0.2))


# ---------------------------------------------------------------- saha asansörü

func _build_lift() -> void:
	var z := LIFT_Z
	var x0 := -COR_W / 2
	var x1 := x0 - 1.6
	Props.solid(self, Vector3(1.6, 0.2, 2.0), Vector3((x0 + x1) / 2, -0.1, z), C_METAL)
	Props.solid(self, Vector3(1.6, 0.2, 2.0), Vector3((x0 + x1) / 2, COR_H + 0.1, z), C_METAL)
	_wall(Vector3(1.6, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, z + 1.1), Color("6f7a70"))
	_wall(Vector3(1.6, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, z - 1.1), Color("6f7a70"))
	_wall(Vector3(0.2, COR_H, 2.0), Vector3(x1 - 0.1, COR_H / 2, z), Color("6f7a70"))
	Props.box(self, Vector3(0.1, 0.5, 2.2), Vector3(x0, COR_H - 0.25, z), C_BRASS)
	Props.label(self, "SAHA ÇIKIŞI", Vector3(x0 + 0.06, COR_H - 0.25, z), 40, Color("1a1a1a"), Vector3(0, 90, 0), 1.9)
	# Kayan kapı (açılır)
	lift_door = Node3D.new()
	lift_door.position = Vector3(x0 - 0.05, 0, z)
	add_child(lift_door)
	Props.box(lift_door, Vector3(0.06, 2.6, 0.95), Vector3(0, 1.3, -0.48), C_BRASS)
	Props.box(lift_door, Vector3(0.06, 2.6, 0.95), Vector3(0, 1.3, 0.48), C_BRASS)
	# Kat göstergesi: yıllar dönüyor (Nihat'ın kadranı); kabinin içinde de bir tane, kapının üstünde
	lift_dial = Props.label(self, "◀ 1453 ▶", Vector3(x0 + 0.06, COR_H - 0.7, z), 28, Color("ffb020"), Vector3(0, 90, 0), 0.8)
	lift_dial_in = Props.label(self, "◀ 1453 ▶", Vector3(x0 - 0.12, 2.76, z), 22, Color("ffb020"), Vector3(0, -90, 0), 0.8)
	var l := OmniLight3D.new()
	l.position = Vector3((x0 + x1) / 2, 2.6, z)
	l.light_color = Color("ffd89a")
	l.light_energy = 1.0
	l.omni_range = 4.0
	add_child(l)
	lift_light = l
	Props.interactable(self, "lift", Vector3(0.6, 2.4, 2.0), Vector3(x0 + 0.2, 1.2, z))
	# Tarih paneli: asansörün sağında pirinç kutu; çark yılı kurar, kırmızı topuzlu kol gönderir
	var pz := PANEL_POS.z
	Props.box(self, Vector3(0.08, 0.66, 0.48), Vector3(x0 + 0.04, 1.35, pz), C_BRASS)
	Props.box(self, Vector3(0.02, 0.13, 0.38), Vector3(x0 + 0.09, 1.58, pz), Color("15181a"))
	Props.label(self, "TARİH", Vector3(x0 + 0.105, 1.58, pz), 16, Color("ffb020"), Vector3(0, 90, 0), 0.34)
	panel_wheel = Node3D.new()
	panel_wheel.position = Vector3(x0 + 0.11, 1.3, pz - 0.06)
	add_child(panel_wheel)
	Props.cyl(panel_wheel, 0.12, 0.03, Vector3.ZERO, C_BRASS.darkened(0.25), Vector3(0, 0, 90), 12)
	Props.box(panel_wheel, Vector3(0.012, 0.22, 0.03), Vector3(0.018, 0, 0), Color("3a2a1a"))
	Props.box(panel_wheel, Vector3(0.012, 0.03, 0.22), Vector3(0.018, 0, 0), Color("3a2a1a"))
	Props.ball(panel_wheel, 0.024, Vector3(0.035, 0.1, 0.0), Color("e8d8b0"), Vector3.ONE, 6)
	Props.box(self, Vector3(0.035, 0.2, 0.035), Vector3(x0 + 0.11, 1.12, pz + 0.16), Color("5a4630"), Vector3(0, 0, -18))
	Props.ball(self, 0.035, Vector3(x0 + 0.14, 1.21, pz + 0.16), Color("a8262f"), Vector3.ONE, 6)


func open_lift() -> void:
	Audio.sfx("door_metal", -8.0)
	lift_open = true
	var tw := create_tween().set_parallel()
	tw.tween_property(lift_door.get_child(0), "position:z", -1.3, 0.8)
	tw.tween_property(lift_door.get_child(1), "position:z", 1.3, 0.8)
	await tw.finished


# ---------------------------------------------------------------- asansörle gönderiş (v0.99.6)
## Nihat Tolga'yı (Bölüm 3'te kendini) geçmişe gönderirken sahne: asansörün önü, Nihat panelde, kapı açılır, yolcu
## kabine yürür, kadran yılları çevirip durur, kapı kapanır, kabin camgöbeği yanar ve sarsılır, girdap. Bitince ekran
## beyazdır. Parçalar ayrı da çağrılır (Bölüm 17'nin kalibrasyon atlaması arada arızalanır: EdirneInterlude).

## Biniş: cut ise kesmeyle asansörün önü (Nihat panelin yanında); line_key Nihat'ın sözü; yolcu kabine yürür
## (hedef işaretli; otomatik testte ve çekimde konur), donar ve kapıya döner.
func lift_board(pl: Player, h: Hud, nihat: Person = null, line_key := "", cut := true) -> void:
	if cut:
		await h.fade_to(1.0, 0.4)
		pl.frozen = true
		pl.global_position = to_global(LIFT_FRONT) + Vector3(0, 0.05, 0)
		pl.face(to_global(Vector3(-2.0, 1.5, LIFT_Z)))
		if nihat:
			nihat.position = NIHAT_PANEL_POS
			nihat.face_toward(pl.global_position)
			nihat.look_target = pl
		await h.fade_to(0.0, 0.5)
	if not lift_open:
		Audio.sfx("door_open", -6.0)
		await open_lift()
	lift_light.light_color = Color("ffd89a")
	lift_light.light_energy = 1.0
	if line_key != "":
		await h.say("SPK_NIHAT", line_key)
	if not (GameState.autotest or GameState.shots_dir != ""):
		pl.frozen = false
		h.set_objective(tr("UI_OBJ_LIFT"), to_global(LIFT_IN) + Vector3(0, 1.0, 0))
		var t := 0.0
		while not in_cabin(pl) and t < 30.0:
			await get_tree().process_frame
			if get_tree().paused:      # duraklatmada sayaç akmaz
				continue
			t += get_process_delta_time()
		h.set_objective("")
	pl.frozen = true
	pl.global_position = to_global(LIFT_IN) + Vector3(0, 0.05, 0)
	pl.face(to_global(Vector3(COR_W / 2, 1.45, LIFT_Z)))


## Yolcu kabinde mi (kapının iç tarafında).
func in_cabin(pl: Player) -> bool:
	var lp := to_local(pl.global_position)
	return lp.x < -COR_W / 2 - 0.3 and absf(lp.z - LIFT_Z) < 0.95


## Göstergeler (koridordaki ve kabindeki) aynı yazıyı gösterir.
func set_dial(text: String) -> void:
	lift_dial.text = "◀ %s ▶" % text
	lift_dial_in.text = lift_dial.text


## Kadran: yıllar akar, to'da durur. Nihat verilirse panele döner, çarkı o çevirir.
func lift_spin(to: String, secs := 1.4, nihat: Person = null) -> void:
	if nihat:
		nihat.look_target = null
		nihat.face_toward(to_global(PANEL_POS))
	var n := maxi(6, int(secs / 0.09))
	for k in n:
		set_dial(String(YEARS[(k * 5 + 3) % YEARS.size()]))
		panel_wheel.rotation.x += 0.55
		if k % 2 == 0:
			Audio.sfx("timer_tick", -9.0, 0.9 + 0.02 * k)
		await get_tree().create_timer(secs / n, false).timeout
	set_dial(to)
	Audio.sfx("ui_confirm", -6.0)


## Kapı kapanır; kabin camgöbeği yanar, sarsılır, makine döner.
func lift_close(pl: Player) -> void:
	lift_open = false
	var tw := create_tween().set_parallel()
	tw.tween_property(lift_door.get_child(0), "position:z", -0.48, 0.7)
	tw.tween_property(lift_door.get_child(1), "position:z", 0.48, 0.7)
	Audio.sfx("door_metal", -6.0)
	await tw.finished
	lift_light.light_color = Color("7ff2ff")
	create_tween().tween_property(lift_light, "light_energy", 3.2, 0.6)
	Audio.sfx("machine_spin", -5.0, 1.2)
	pl.shake(0.35)
	await get_tree().create_timer(0.7, false).timeout


## Girdap (from → to); bitince ekran bembeyaz (Hud beyazda tutar), kabin ışığı eski haline döner.
func lift_go(h: Hud, from: String, to: String, glitch := false, caption := "", secs := 2.6) -> void:
	var v := TimeVortex.new()
	get_parent().add_child(v)
	await v.play_text(from, to, 0.5 if GameState.autotest else secs, glitch, caption)
	Audio.sfx("machine_jump", -4.0)
	h.set_fade(1.0, Color.WHITE)
	v.queue_free()
	lift_light.light_color = Color("ffd89a")
	lift_light.light_energy = 1.0


## Tam gönderiş: Büro'dan to tarihine (Bölüm 3: 2026'daki garaj; Bölüm 17: kuşatmanın ilk sayfası). Kadranda yıl.
func ride_lift(pl: Player, h: Hud, nihat: Person, to: String, line_key := "", caption := "", cut := true) -> void:
	await lift_board(pl, h, nihat, line_key, cut)
	var year := to.split(" ")[-1]
	await lift_spin(year, 1.4, nihat)
	await lift_close(pl)
	await lift_go(h, tr("UI_JUMP_BUREAU"), to, false, caption)


# ================================================================ koridor süsü ve canlılık (v0.99.96)

## ---- ld: koridor süsü + canlılık (boru postası, asma saatler, ilan panoları, mobilya, memurlar, sesler) ----

const LD_PASTEL := [Color("f4e8c8"), Color("d8ecd8"), Color("f0d0d8"), Color("d0e0f4"), Color("efe9d8"), Color("f6dca0")]
const LD_ERA_SFX := {"1071": "war_cry", "1204": "church_bell", "1299": "goat", "1453": "drum_boom", "1492": "cloth",
	"1517": "crowd_camp", "1683": "drum_boom", "1789": "crowd_gasp", "1826": "cannon", "1908": "whistle",
	"1923": "crowd_camp", "1969": "radio_static", "2026": "radio_beep", "2150": "veil_hum", "MÖ 44": "sword_clash",
	"MÖ 776": "crowd_camp"}

var _ld_counter: Label3D          # pano C: "KAYIP SANİYE: n/5"
var _ld_cemal: Person
var _ld_zeki: Person
var _ld_cart: Node3D              # Zeki'nin servis arabası (etkileşim kutusu bunun çocuğu)
var _ld_timer: Timer
var _ld_last_amb := 0.0           # son ortam sesi (en çok 3 sn'de bir)
var _ld_era_next := 0.0
var _ld_type_next := 0.0


func _ld_build() -> void:
	_ld_tubes()
	_ld_capsules()
	_ld_clocks()
	_ld_boards()
	_ld_furniture()
	_ld_clerks()
	_ld_desk_extras()
	_ld_loudspeaker()
	_ld_sounds()


# ---------------------------------------------------------------- boru postası

func _ld_tubes() -> void:
	var xs := [-1.35, 1.35]
	var ys := [3.15, 3.05]
	for t in 2:
		var x: float = xs[t]
		var y: float = ys[t]
		Props.cyl(self, 0.07, 84.0, Vector3(x, y, -42.0), C_BRASS, Vector3(90, 0, 0), 8)
		# Tek tek boyunduruk halkaları
		for k in 6:
			Props.cyl(self, 0.085, 0.14, Vector3(x, y, -7.0 - k * 14.0), C_BRASS.darkened(0.3), Vector3(90, 0, 0), 8)
	# Dirsekler: ofis kapısı çevresi ve birkaç oda açıklığı (boru aşağı sarkar)
	for e in [[-1.35, 3.15, -0.3], [-1.35, 3.15, -6.4], [1.35, 3.05, -0.3], [1.35, 3.05, -20.7]]:
		var ex: float = e[0]
		var ey: float = e[1]
		var ez: float = e[2]
		Props.cyl(self, 0.07, 0.75, Vector3(ex, ey - 0.375, ez), C_BRASS, Vector3.ZERO, 8)
		Props.ball(self, 0.09, Vector3(ex, ey, ez), C_BRASS.darkened(0.15), Vector3.ONE, 8)


func _ld_capsules() -> void:
	# [boru x, boru y, geçiş süresi, uç bekleme, başlangıç yönü]
	var defs := [[-1.35, 3.15, 9.0, 0.5, 0], [1.35, 3.05, 14.0, 2.5, 1], [-1.35, 3.15, 18.0, 4.0, 1],
		[1.35, 3.05, 11.0, 1.2, 0], [-1.35, 3.15, 13.0, 6.0, 0], [1.35, 3.05, 19.0, 3.0, 1]]
	for i in defs.size():
		var d: Array = defs[i]
		_ld_capsule(float(d[0]), float(d[1]), float(d[2]), float(d[3]), int(d[4]))


# Kapsül borunun üstünde bir kılıf gibi gezer (borudan biraz kalın: görünsün)
func _ld_capsule(x: float, y: float, dur: float, pause: float, dir: int) -> void:
	var c := Node3D.new()
	add_child(c)
	var za := -1.0
	var zb := -83.0
	if dir == 1:
		za = -83.0
		zb = -1.0
	c.position = Vector3(x, y, za)
	Props.cyl(c, 0.1, 0.42, Vector3.ZERO, Color("6f8a96"), Vector3(90, 0, 0), 8)
	Props.cyl(c, 0.108, 0.06, Vector3(0, 0, 0.18), C_BRASS, Vector3(90, 0, 0), 8)
	var tw := c.create_tween().set_loops()
	tw.tween_interval(pause)
	tw.tween_callback(_ld_whoosh.bind(c))
	tw.tween_property(c, "position:z", zb, dur).from(za).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_interval(pause)
	tw.tween_property(c, "position:z", za, dur).from(zb).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _ld_whoosh(c: Node3D) -> void:
	if GameState.autotest or not is_instance_valid(c) or randf() > 0.2:
		return
	Audio.sfx_at("whoosh_fly", c, -26.0)


# ---------------------------------------------------------------- asma saatler

func _ld_hand(parent: Node3D, length: float, width: float, color: Color, speed: float) -> Node3D:
	var pivot := Node3D.new()
	parent.add_child(pivot)
	Props.box(pivot, Vector3(width, length, 0.09), Vector3(0, length * 0.45, 0), color)
	_spinners.append([pivot, Vector3(0, 0, 1), speed])
	return pivot


func _ld_clocks() -> void:
	var zs := [-12.0, -19.5, -36.0, -46.0, -58.0]
	for i in 5:
		var root := Node3D.new()
		root.position = Vector3(0.9, 2.75, zs[i])
		add_child(root)
		Props.cyl(root, 0.012, 0.45, Vector3(0, 0.42, 0), C_METAL.darkened(0.3), Vector3.ZERO, 6)
		match i:
			0:  # güneş saati: kum rengi disk, sabit gnomon, yavaş dönen gölge
				Props.cyl(root, 0.28, 0.05, Vector3.ZERO, Color("e0c890"), Vector3(90, 0, 0), 20)
				Props.box(root, Vector3(0.03, 0.2, 0.09), Vector3(0, 0.1, 0), Color("5a4630"))
				_ld_hand(root, 0.24, 0.02, Color("7a5a38"), 0.08)
			1:  # su saati: mavi disk, ters dönen ibre, damla
				Props.cyl(root, 0.28, 0.05, Vector3.ZERO, Color("7fb0c8"), Vector3(90, 0, 0), 20)
				_ld_hand(root, 0.24, 0.02, Color("1f3a4a"), -0.45)
				Props.ball(root, 0.035, Vector3(0, 0, 0), Color("c8ecff"), Vector3.ONE, 8)
			2:  # kum saati: 10 sn'de bir döner
				var fl := Node3D.new()
				root.add_child(fl)
				Props.cyl(fl, 0.015, 0.2, Vector3(0, 0.1, 0), Color("b8d4dc"), Vector3.ZERO, 10, 0.1)
				Props.cyl(fl, 0.1, 0.2, Vector3(0, -0.1, 0), Color("b8d4dc"), Vector3.ZERO, 10, 0.015)
				Props.cyl(fl, 0.12, 0.025, Vector3(0, 0.215, 0), C_BRASS, Vector3.ZERO, 10)
				Props.cyl(fl, 0.12, 0.025, Vector3(0, -0.215, 0), C_BRASS, Vector3.ZERO, 10)
				Props.ball(fl, 0.05, Vector3(0, -0.15, 0), Color("e8c878"), Vector3(1, 0.6, 1), 8)
				var tw := fl.create_tween().set_loops()
				tw.tween_interval(10.0)
				tw.tween_property(fl, "rotation:z", PI, 0.8).as_relative().set_trans(Tween.TRANS_SINE)
			3:  # dijital: iki yüzde 88:88 (arka yüzde kırmızı şerit)
				Props.box(root, Vector3(0.52, 0.22, 0.07), Vector3.ZERO, Color("15181a"))
				Props.box(root, Vector3(0.4, 0.12, 0.008), Vector3(0, 0, -0.038), Color("ff2a1a"), Vector3.ZERO, 2.0)
				var lab := Props.label(root, "88:88", Vector3(0, 0, 0.037), 34, Color("ff2a1a"), Vector3.ZERO, 0.48)
				var tb := lab.create_tween().set_loops()
				tb.tween_callback(func(): lab.text = "88 88")
				tb.tween_interval(0.5)
				tb.tween_callback(func(): lab.text = "88:88")
				tb.tween_interval(0.5)
			4:  # atom saati: mavi disk, çekirdek, iki elektron
				Props.cyl(root, 0.28, 0.05, Vector3.ZERO, Color("2a4a9a"), Vector3(90, 0, 0), 20, -1.0, 0.4)
				Props.ball(root, 0.055, Vector3.ZERO, Color("6ad0ff"), Vector3.ONE, 8, 1.5)
				var pa := Node3D.new()
				root.add_child(pa)
				Props.ball(pa, 0.03, Vector3(0.2, 0, 0), Color("ffffff"), Vector3.ONE, 6, 1.5)
				_spinners.append([pa, Vector3(0, 0, 1), 1.6])
				var pb := Node3D.new()
				root.add_child(pb)
				Props.ball(pb, 0.03, Vector3(0, 0.14, 0), Color("c8e8ff"), Vector3.ONE, 6, 1.5)
				_spinners.append([pb, Vector3(0, 0, 1), -2.4])
		_reg("bur_cclock%d" % i, Vector3(0.7, 0.7, 0.5), Vector3.ZERO, "UI_BUR_LOOK", _ld_cclock.bind(i), root)


func _ld_cclock(i: int) -> void:
	_say("BUR_CCLOCK%d" % i)


# ---------------------------------------------------------------- ilan panoları

func _ld_counter_text(n: int) -> String:
	var en := TranslationServer.get_locale().begins_with("en")
	return ("LOST SECONDS: %d/5" if en else "KAYIP SANİYE: %d/5") % n


func _ld_on_seconds(n: int) -> void:
	if is_instance_valid(_ld_counter):
		_ld_counter.text = _ld_counter_text(n)


func _ld_boards() -> void:
	# [dz, dy, genişlik, yükseklik, pastel indeksi, eğim]
	var pa := [[-0.27, 0.0, 0.26, 0.32, 0, 3.0], [0.0, 0.02, 0.22, 0.3, 1, -4.0], [0.28, -0.02, 0.24, 0.34, 2, 5.0], [-0.1, -0.22, 0.5, 0.14, 3, -1.0]]
	var pb := [[-0.28, 0.02, 0.24, 0.3, 5, -3.0], [0.0, 0.0, 0.26, 0.34, 4, 2.0], [0.3, 0.03, 0.22, 0.28, 1, 4.0], [0.02, -0.22, 0.6, 0.12, 2, 1.0], [-0.3, -0.2, 0.2, 0.14, 0, -5.0]]
	var pc := [[-0.33, 0.05, 0.19, 0.24, 3, 4.0], [-0.11, 0.06, 0.19, 0.26, 5, -3.0], [0.11, 0.05, 0.19, 0.22, 0, 2.0], [0.33, 0.05, 0.19, 0.24, 2, -4.0]]
	var pd := [[-0.3, 0.0, 0.25, 0.34, 1, -2.0], [-0.02, 0.03, 0.28, 0.3, 4, 3.0], [0.3, -0.01, 0.24, 0.32, 3, -5.0], [0.0, -0.23, 0.7, 0.1, 5, 0.0]]
	_ld_board("bur_noticeA", 1, -1.1, 1.6, "DUYURU", "NOTICE", pa, ["BUR_NOTICE_A", "BUR_NOTICE_A_2"])
	_ld_board("bur_noticeB", -1, -23.0, 1.6, "KAYIP İLANI", "LOST NOTICE", pb, ["BUR_NOTICE_B"])
	_ld_board("bur_noticeC", 1, -25.8, 1.6, "SANİYE AVI", "SECOND HUNT", pc, ["BUR_NOTICE_C"])
	_ld_board("bur_noticeD", -1, -40.0, 1.6, "İHALE", "TENDER", pd, ["BUR_NOTICE_D"])
	# Pano C'deki sayaç: n/5 (bölme işareti var, düz tamsayı değil)
	_ld_counter = Props.label(self, _ld_counter_text(seconds_found()), Vector3(1.932, 1.6 - 0.23, -25.8), 17, Color("6a1a1a"), Vector3(0, -90, 0), 0.8)
	if not seconds_changed.is_connected(_ld_on_seconds):
		seconds_changed.connect(_ld_on_seconds)


func _ld_board(id: String, e: int, z: float, y: float, tr_head: String, en_head: String, papers: Array, keys: Array) -> void:
	Props.box(self, Vector3(0.05, 0.72, 0.96), Vector3(e * 1.975, y, z), C_WALNUT)
	Props.box(self, Vector3(0.03, 0.62, 0.86), Vector3(e * 1.955, y, z), Color("9a7a4a"))
	var pins := 0
	for p in papers:
		var w: float = p[2]
		var h: float = p[3]
		Props.box(self, Vector3(0.006, h, w), Vector3(e * 1.938, y + float(p[1]), z + float(p[0])), LD_PASTEL[int(p[4])], Vector3(float(p[5]), 0, 0))
		if pins < 2:
			pins += 1
			Props.ball(self, 0.014, Vector3(e * 1.932, y + float(p[1]) + h * 0.5 - 0.03, z + float(p[0])), Color("b8323a"), Vector3.ONE, 6)
	_lbl(self, tr_head, en_head, Vector3(e * 1.932, y + 0.24, z), 18, Color("2a1a10"), Vector3(0, -90 * e, 0), 0.8)
	_reg(id, Vector3(0.3, 0.8, 1.0), Vector3(e * 1.9, y, z), "UI_BUR_LOOK", _ld_notice.bind(id, keys))


func _ld_notice(id: String, keys: Array) -> void:
	_say(_next(id, keys))


# ---------------------------------------------------------------- koridor mobilyası

func _ld_furniture() -> void:
	# Su soğutucusu (doğu duvarı)
	Props.box(self, Vector3(0.36, 0.95, 0.36), Vector3(1.6, 0.475, -24.5), Color("d8e0e0"))
	Props.cyl(self, 0.15, 0.42, Vector3(1.6, 1.16, -24.5), Color("7ec0e8"), Vector3.ZERO, 12)
	Props.box(self, Vector3(0.08, 0.05, 0.07), Vector3(1.4, 0.82, -24.5), Color("b8323a"))
	var bub := Props.ball(self, 0.035, Vector3(1.47, 1.0, -24.5), Color("ffffff"), Vector3.ONE, 6, 1.0)
	_bobbers.append([bub, 1.0, 0.14, 2.2, 0.0])
	_reg("bur_cooler", Vector3(0.5, 1.4, 0.5), Vector3(1.6, 0.7, -24.5), "UI_BUR_USE", _ld_cooler)
	# Areka palmiyesi
	Props.cyl(self, 0.2, 0.36, Vector3(1.55, 0.18, -0.9), C_ORANGE.darkened(0.2), Vector3.ZERO, 10, 0.16)
	Props.cyl(self, 0.035, 0.8, Vector3(1.55, 0.7, -0.9), Color("6a5a30"), Vector3.ZERO, 6)
	for k in 5:
		var th := deg_to_rad(k * 72.0 + 20.0)
		var off := Vector3(cos(th), -0.05, -sin(th)) * 0.3
		Props.box(self, Vector3(0.7, 0.02, 0.14), Vector3(1.55, 1.1, -0.9) + off, Color("3f7a3a"), Vector3(0, rad_to_deg(th), -28))
	_reg("bur_palm", Vector3(0.7, 1.3, 0.7), Vector3(1.55, 0.65, -0.9), "UI_BUR_LOOK", _ld_palm)
	# Banklar: duvara yaslı, kapı ve açıklık dışında
	_ld_bench(-1, -10.2)
	_ld_bench(-1, -14.0)
	_ld_bench(1, -27.4)
	# İki sandalye, birinin sırtında ceket
	for j in 2:
		var cz := -20.5 - j * 1.2
		Props.box(self, Vector3(0.42, 0.05, 0.42), Vector3(-1.65, 0.45, cz), C_WOOD)
		Props.box(self, Vector3(0.05, 0.45, 0.42), Vector3(-1.85, 0.7, cz), C_WOOD_DARK)
		Props.box(self, Vector3(0.1, 0.43, 0.1), Vector3(-1.65, 0.215, cz), C_WOOD_DARK)
	Props.box(self, Vector3(0.07, 0.4, 0.36), Vector3(-1.8, 0.68, -20.5), Color("4a5a78"), Vector3(0, 0, 5))
	# Boş altın çerçeveler (portre sırası)
	var eras := ["fez", "laurel", "helmet", "tophat"]
	var bgs := [Color("6a2a2a"), Color("2f4a3a"), Color("3a3f5a"), Color("5a4a2a")]
	var pzs := [-1.0, -2.2, -3.4, -20.8]
	for i in pzs.size():
		_ld_portrait(float(pzs[i]), eras[i], bgs[i])
	# Duvar lambaları (kehribar parlak kutular; gerçek ışık yok)
	for s in [[-1, -9.9], [-1, -14.0], [-1, -20.3], [1, -24.5], [1, -33.5], [-1, -44.75]]:
		var se: int = s[0]
		Props.box(self, Vector3(0.08, 0.16, 0.1), Vector3(se * 1.96, 2.05, float(s[1])), Color("ffb040"), Vector3.ZERO, 1.5)


## Eski müdürlerin portresi: pirinç çerçeve, renkli zemin, büst ve çağın şapkası (fes, defne, miğfer, silindir)
func _ld_portrait(pz: float, era: String, bg: Color) -> void:
	var x := -1.965
	Props.box(self, Vector3(0.04, 0.55, 0.42), Vector3(-1.98, 2.35, pz), C_BRASS)
	Props.box(self, Vector3(0.03, 0.45, 0.33), Vector3(x, 2.35, pz), bg)
	Props.box(self, Vector3(0.02, 0.14, 0.24), Vector3(x + 0.012, 2.19, pz), Color("2a2a30"))          # omuzlar
	Props.ball(self, 0.075, Vector3(x + 0.015, 2.34, pz), Color("d9b08a"), Vector3(0.4, 1.1, 1.0), 8)   # baş
	Props.box(self, Vector3(0.02, 0.012, 0.07), Vector3(x + 0.03, 2.31, pz), Color("3a2a20"))        # bıyık
	match era:
		"fez":
			Props.cyl(self, 0.045, 0.07, Vector3(x + 0.015, 2.43, pz), Color("b3262d"), Vector3.ZERO, 8, 0.038)
		"laurel":
			Props.ring(self, 0.06, 0.08, Vector3(x + 0.015, 2.4, pz), Color("6a9a3a"), Vector3(0, 0, 90))
		"helmet":
			Props.ball(self, 0.08, Vector3(x + 0.015, 2.39, pz), Color("9aa0a8"), Vector3(0.45, 0.7, 1.05), 8)
		"tophat":
			Props.cyl(self, 0.05, 0.1, Vector3(x + 0.015, 2.45, pz), Color("1a1a1e"), Vector3.ZERO, 8)
			Props.cyl(self, 0.07, 0.01, Vector3(x + 0.015, 2.4, pz), Color("1a1a1e"), Vector3.ZERO, 8)
	Props.box(self, Vector3(0.02, 0.04, 0.16), Vector3(-1.97, 2.06, pz), C_BRASS)


func _ld_bench(e: int, z: float) -> void:
	var bl := 1.3
	Props.box(self, Vector3(0.42, 0.05, bl), Vector3(e * 1.77, 0.46, z), C_WOOD)
	Props.box(self, Vector3(0.05, 0.42, bl), Vector3(e * 1.96, 0.72, z), C_WOOD_DARK)
	for sg in 2:
		var sf := -1.0 + sg * 2.0
		Props.box(self, Vector3(0.36, 0.44, 0.06), Vector3(e * 1.78, 0.22, z + sf * (bl * 0.5 - 0.06)), C_WOOD_DARK)


func _ld_cooler() -> void:
	var k := _next("bur_cooler", ["BUR_COOLER", "BUR_COOLER_2"])
	if not GameState.autotest:
		Audio.sfx("splash", -22.0, 1.4)
	_say(k)


func _ld_palm() -> void:
	_say(_next("bur_palm", ["BUR_PALM", "BUR_PALM_2"]))


# ---------------------------------------------------------------- memurlar

func _ld_talk(p: Person, secs: float) -> void:
	if not is_instance_valid(p):
		return
	p.talking = true
	get_tree().create_timer(secs).timeout.connect(func():
		if is_instance_valid(p):
			p.talking = false)


func _ld_clerks() -> void:
	# Katip Cemal: batı duvarına yaslı küçük masada daktilo; sırtı koridorda
	Props.box(self, Vector3(0.4, 0.04, 0.9), Vector3(-1.8, 0.8, -2.2), C_WOOD)
	Props.box(self, Vector3(0.36, 0.78, 0.05), Vector3(-1.8, 0.39, -2.6), C_WOOD_DARK)
	Props.box(self, Vector3(0.36, 0.78, 0.05), Vector3(-1.8, 0.39, -1.8), C_WOOD_DARK)
	Props.box(self, Vector3(0.26, 0.1, 0.3), Vector3(-1.78, 0.87, -2.1), Color("1f2426"))
	Props.box(self, Vector3(0.01, 0.2, 0.22), Vector3(-1.9, 1.0, -2.1), C_PAPER, Vector3(0, 0, -12))
	Props.box(self, Vector3(0.2, 0.12, 0.22), Vector3(-1.82, 0.88, -2.45), C_PAPER)
	_ld_cemal = Person.new({"coat": Color("5a5048"), "pants": Color("2a2a30"), "hair": Color("3a3a3a"), "hat": "none",
		"glasses": true, "mustache": true, "skin": Color("e0b090")})
	_ld_cemal.set_meta("spk", "SPK_CEMAL")
	_ld_cemal.set_meta("no_yield", true)
	_ld_cemal.position = Vector3(-1.5, 0.0, -2.2)
	_ld_cemal.rotation_degrees.y = -90
	add_child(_ld_cemal)
	_ld_cemal.set_activity("write")
	_reg("bur_cemal", Vector3(0.9, 1.8, 1.0), Vector3(-1.6, 0.9, -2.2), "UI_BUR_TALK", _ld_cemal_talk, null, false)
	# Kurye Zeki + servis arabası
	_ld_zeki = Person.new({"coat": Color("2f5f8a"), "pants": Color("4a4038"), "hair": Color("2a1a10"), "hat": "fez",
		"mustache": true, "skin": Color("d9a07a"), "scarf": Color("b8323a")})
	_ld_zeki.set_meta("spk", "SPK_ZEKI")
	_ld_zeki.set_meta("no_yield", true)
	add_child(_ld_zeki)
	_ld_cart = Node3D.new()
	add_child(_ld_cart)
	_ld_build_cart(_ld_cart)
	_reg("bur_trolley", Vector3(0.7, 1.0, 1.0), Vector3(0, 0.55, 0), "UI_BUR_TALK", _ld_zeki_talk, _ld_cart, false)
	if GameState.autotest:
		_ld_zeki.position = Vector3(1.0, 0.0, -40.0)
		_ld_zeki.rotation_degrees.y = 180
		_ld_cart.position = Vector3(1.0, 0.0, -40.8)
		return
	_ld_zeki.position = Vector3(1.0, 0.0, -4.0)
	_ld_zeki.rotation_degrees.y = 180
	_ld_cart.position = Vector3(1.0, 0.0, -4.8)
	# ~45 sn: -z yönünde yürü, araba öne geçer; uçta araba Zeki'nin yanından dolanıp öbür tarafa geçer
	var tw := create_tween().set_loops()
	tw.tween_property(_ld_zeki, "position:z", -44.0, 20.0).from(-4.0)
	tw.parallel().tween_property(_ld_cart, "position:z", -44.8, 20.0).from(-4.8)
	tw.tween_property(_ld_cart, "position:x", 1.7, 0.5)
	tw.tween_property(_ld_cart, "position:z", -43.2, 0.8)
	tw.tween_property(_ld_cart, "position:x", 1.0, 0.5)
	tw.tween_interval(1.0)
	tw.tween_property(_ld_zeki, "position:z", -4.0, 20.0)
	tw.parallel().tween_property(_ld_cart, "position:z", -3.2, 20.0)
	tw.tween_property(_ld_cart, "position:x", 1.7, 0.5)
	tw.tween_property(_ld_cart, "position:z", -4.8, 0.8)
	tw.tween_property(_ld_cart, "position:x", 1.0, 0.5)
	tw.tween_interval(0.4)


func _ld_build_cart(c: Node3D) -> void:
	Props.box(c, Vector3(0.5, 0.03, 0.9), Vector3(0, 0.28, 0), C_WOOD)
	Props.box(c, Vector3(0.5, 0.03, 0.9), Vector3(0, 0.78, 0), C_WOOD)
	for sx in [-0.24, 0.24]:
		Props.box(c, Vector3(0.03, 0.62, 0.9), Vector3(sx, 0.56, 0), C_WOOD_DARK)
	for hz in [-0.46, 0.46]:
		Props.cyl(c, 0.015, 0.5, Vector3(0, 0.95, hz), C_METAL, Vector3(0, 0, 90), 6)
	for az in [-0.33, 0.33]:
		Props.cyl(c, 0.08, 0.56, Vector3(0, 0.08, az), Color("2a2a2e"), Vector3(0, 0, 90), 10)
	# Üst raf: çay bardakları ve semaver; alt raf: simit ve dosya kutuları
	for g in 3:
		Props.cyl(c, 0.03, 0.08, Vector3(-0.12 + g * 0.12, 0.84, -0.28), Color("b3402a"), Vector3.ZERO, 8, 0.036)
	Props.cyl(c, 0.1, 0.26, Vector3(0, 0.93, 0.15), C_BRASS, Vector3.ZERO, 10, 0.07)
	Props.cyl(c, 0.1, 0.09, Vector3(-0.1, 0.345, -0.25), Color("c8802a"), Vector3.ZERO, 10)
	Props.box(c, Vector3(0.2, 0.18, 0.26), Vector3(0.1, 0.39, 0.2), Color("8a6a40"))
	Props.box(c, Vector3(0.2, 0.14, 0.26), Vector3(-0.1, 0.37, 0.25), Color("b8a070"))


func _ld_cemal_talk() -> void:
	_ld_talk(_ld_cemal, 3.5)
	_say(_next("bur_cemal", ["BUR_CEMAL", "BUR_CEMAL_2"]), 3.8, "SPK_CEMAL")


func _ld_zeki_talk() -> void:
	_ld_talk(_ld_zeki, 3.5)
	_say(_next("bur_trolley", ["BUR_TROLLEY", "BUR_TROLLEY_2"]), 3.8, "SPK_ZEKI")


# ---------------------------------------------------------------- Başdenetçi'nin masası: süsler

func _ld_desk_extras() -> void:
	var z := DESK_Z
	# Yeşil bankacı lambası
	Props.cyl(self, 0.06, 0.025, Vector3(-0.8, 0.8525, z + 0.2), C_BRASS, Vector3.ZERO, 10)
	Props.cyl(self, 0.01, 0.22, Vector3(-0.8, 0.965, z + 0.2), C_BRASS, Vector3.ZERO, 6)
	Props.cyl(self, 0.06, 0.2, Vector3(-0.8, 1.09, z + 0.2), Color("2a7a4a"), Vector3(0, 0, 90), 10, -1.0, 0.25)
	_glow(self, Vector3(-0.8, 0.85, z + 0.3), Vector2(0.8, 0.6), Color("ffc870"), Vector3(-90, 0, 0), 0.35)
	# Pirinç isim plakası: masa ön kenarında, hafif geriye yaslı
	Props.box(self, Vector3(0.46, 0.1, 0.03), Vector3(-0.35, 0.9, z + 0.5), C_BRASS, Vector3(-20, 0, 0))
	Props.label(self, "M. ZAMANOVA", Vector3(-0.35, 0.906, z + 0.516), 16, Color("2a1a10"), Vector3(-20, 0, 0), 0.42)
	if GameState.autotest:
		return
	# Kâğıt dağlarından süzülen sayfalar
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var sx := [-1.0, 0.85, -0.7, 1.0, -0.95]
	for i in 5:
		var start := Vector3(sx[i], 2.6, z - 0.1 + rng.randf_range(-0.1, 0.25))
		var end := Vector3(sx[i] + rng.randf_range(-0.5, 0.5), 0.02, z + rng.randf_range(-0.2, 1.0))
		var sheet := Props.box(self, Vector3(0.2, 0.004, 0.28), start, C_PAPER, Vector3(rng.randf_range(-20, 20), rng.randf_range(0, 90), 0))
		_ld_paper_fall(sheet, start, end, 12.0, float(i) / 5.0)


func _ld_paper_fall(sheet: MeshInstance3D, start: Vector3, end: Vector3, dur: float, phase: float) -> void:
	sheet.position = start.lerp(end, phase)
	var tw := sheet.create_tween()
	tw.tween_property(sheet, "position", end, dur * (1.0 - phase))
	tw.tween_callback(_ld_paper_loop.bind(sheet, start, end, dur))


func _ld_paper_loop(sheet: MeshInstance3D, start: Vector3, end: Vector3, dur: float) -> void:
	if not is_instance_valid(sheet):
		return
	var tw := sheet.create_tween().set_loops()
	tw.tween_property(sheet, "position", end, dur).from(start).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(sheet, "rotation_degrees", Vector3(30, 180, -25), dur).from(Vector3(-10, 0, 15))


# ---------------------------------------------------------------- asansör: kafesli hoparlör

func _ld_loudspeaker() -> void:
	# Tabelanın (SAHA ÇIKIŞI, z -32.9..-35.1) yanında; önünde durup yazıyı örtüyordu
	Props.box(self, Vector3(0.04, 0.34, 0.34), Vector3(-1.94, 2.9, -32.3), C_METAL.darkened(0.3))
	Props.cyl(self, 0.05, 0.36, Vector3(-1.76, 2.9, -32.3), C_BRASS, Vector3(0, 0, -90), 12, 0.17)
	Props.ring(self, 0.15, 0.18, Vector3(-1.58, 2.9, -32.3), Color("3a3a3e"), Vector3(0, 0, 90))
	Props.label(self, "♪", Vector3(-1.56, 3.15, -32.3), 40, Color("ffb020"), Vector3(0, 90, 0), 0.4)
	_reg("bur_mehter", Vector3(0.5, 0.5, 0.6), Vector3(-1.8, 2.9, -32.3), "UI_BUR_LOOK", _ld_mehter)


func _ld_mehter() -> void:
	var k := _next("bur_mehter", ["BUR_MEHTER", "BUR_MEHTER_2"])
	if k == "BUR_MEHTER_2":
		Audio.sfx("drum_boom", -24.0)
	_say(k)


# ---------------------------------------------------------------- çağ sesleri

func _ld_sounds() -> void:
	if GameState.autotest:
		return
	_ld_timer = Timer.new()
	_ld_timer.wait_time = 0.7
	_ld_timer.autostart = true
	add_child(_ld_timer)
	_ld_timer.timeout.connect(_ld_tick)


func _ld_tick() -> void:
	if GameState.autotest or not is_instance_valid(player) or not is_visible_in_tree():
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - _ld_last_amb < 3.0:
		return
	var lp := to_local(player.global_position)
	var pp := Vector2(lp.x, lp.z)
	# Kapıya 4 m yakınken çağın sesi, uzaktan boğuk
	if now >= _ld_era_next:
		for d in DOORS:
			var dp := Vector2(float(d[0]) * 2.0, float(d[1]))
			if dp.distance_to(pp) < 4.0:
				var nm: String = LD_ERA_SFX.get(String(d[2]), "")
				if nm != "":
					Audio.sfx(nm, randf_range(-30.0, -26.0))
					_ld_last_amb = now
					_ld_era_next = now + randf_range(6.0, 10.0)
					return
				break
	# Cemal'in daktilosu
	if now >= _ld_type_next and is_instance_valid(_ld_cemal) and Vector2(_ld_cemal.position.x, _ld_cemal.position.z).distance_to(pp) < 6.0:
		Audio.sfx_at("typewriter_bell" if randf() < 0.12 else "typewriter", _ld_cemal, -24.0)
		_ld_last_amb = now
		_ld_type_next = now + randf_range(4.0, 7.0)


# ================================================================ çay ocağı, bekleme salonu, kayıp zaman bürosu (v0.99.96)

## ---- rb: Çay Ocağı + Bekleme Salonu + Kayıp Zaman Bürosu (Bureau içine yapıştırılacak yöntemler) ----

var _rb_mats := {}                  # saydam malzeme önbelleği
var _rb_necmi_p: Person
var _rb_sabri_p: Person
var _rb_paper: MeshInstance3D       # Sabri'nin gazetesi
var _rb_paper_busy := false
var _rb_teapot_pos := Vector3(3.6, 1.06, -3.9)


func _rb_build() -> void:
	_rb_tea()
	_rb_wait()
	_rb_lost()


# ---------------------------------------------------------------- ortak yardımcılar

## Saydam malzeme (hayalet, cam, buhar); aynı parametre aynı malzemeyi paylaşır.
func _rb_mat(col: Color, alpha: float, emis: float, unshaded := false) -> StandardMaterial3D:
	var key := "%s|%.2f|%.2f|%s" % [col.to_html(), alpha, emis, unshaded]
	if _rb_mats.has(key):
		return _rb_mats[key]
	var m := StandardMaterial3D.new()
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(col.r, col.g, col.b, alpha)
	if emis > 0.0:
		m.emission_enabled = true
		m.emission = col
		m.emission_energy_multiplier = emis
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_rb_mats[key] = m
	return m


func _rb_t(mi: MeshInstance3D, m: Material) -> MeshInstance3D:
	mi.material_override = m
	return mi


## 4582119 -> "4.582.119"
func _rb_fmt(n: int) -> String:
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "." + out
	return out


## Konuşurken ağız oynasın
func _rb_talk(p: Person, secs: float) -> void:
	if p == null:
		return
	p.talking = true
	await get_tree().create_timer(secs).timeout
	if is_instance_valid(p):
		p.talking = false


# ---------------------------------------------------------------- 1. ÇAY OCAĞI (x 2..7, z -2.2..-7.0)

func _rb_tea() -> void:
	var cw := Color("e8e2d0")
	var tq := Color("3aa6a0")
	_floor(Vector2(5.0, 4.8), Vector3(4.5, 0, -4.6), Color("b5a58a"), Color("a69677"), 2.0)
	Props.solid(self, Vector3(5.2, 0.2, 5.0), Vector3(4.6, 3.1, -4.6), C_CEIL)
	_wall(Vector3(0.2, 0.4, 4.8), Vector3(2.1, 3.2, -4.6), Color("2f7f7a"))     # söve (3.0-3.4)
	_wall(Vector3(5.2, 3.4, 0.2), Vector3(4.6, 1.7, -2.2), cw)
	_wall(Vector3(5.2, 3.4, 0.2), Vector3(4.6, 1.7, -7.0), cw)
	_wall(Vector3(0.2, 3.4, 5.0), Vector3(7.1, 1.7, -4.6), cw)
	# turkuaz fayans lambri
	Props.box(self, Vector3(5.0, 1.1, 0.04), Vector3(4.6, 0.55, -2.32), tq)
	Props.box(self, Vector3(5.0, 1.1, 0.04), Vector3(4.6, 0.55, -6.88), tq)
	Props.box(self, Vector3(0.04, 1.1, 4.6), Vector3(6.98, 0.55, -4.6), tq)
	_lbl(self, "ÇAY OCAĞI", "TEA NOOK", Vector3(1.98, 3.2, -4.6), 56, Color("f4ecd4"), Vector3(0, -90, 0))
	# tezgâh
	Props.solid(self, Vector3(0.8, 1.0, 3.0), Vector3(3.6, 0.5, -4.9), tq)
	Props.box(self, Vector3(0.95, 0.06, 3.15), Vector3(3.6, 1.03, -4.9), Color("8a6a48"))
	# ocak + çaydanlık + demlik
	var tp := _rb_teapot_pos
	var copper := Color("b87333")
	Props.cyl(self, 0.14, 0.05, tp + Vector3(0, 0.025, 0), Color("2a2a2a"))
	Props.ball(self, 0.045, tp + Vector3(0, 0.08, 0), Color("2a7bff"), Vector3(1, 1.3, 1), 6, 3.0)
	Props.cyl(self, 0.15, 0.2, tp + Vector3(0, 0.2, 0), copper, Vector3.ZERO, 10, 0.11, 0.1)
	Props.cyl(self, 0.09, 0.16, tp + Vector3(0, 0.38, 0), copper, Vector3.ZERO, 10, 0.07, 0.1)
	Props.ball(self, 0.05, tp + Vector3(0, 0.49, 0), copper, Vector3(1, 0.7, 1), 8)
	Props.box(self, Vector3(0.04, 0.04, 0.14), tp + Vector3(0, 0.24, 0.17), copper, Vector3(30, 0, 0))
	# buhar: üç saydam top
	var steam := Node3D.new()
	steam.position = tp + Vector3(0, 0.56, 0)
	add_child(steam)
	var sm := _rb_mat(Color.WHITE, 0.3, 0.0, true)
	for i in 3:
		var b := Props.ball(steam, 0.04 + 0.01 * i, Vector3(0.02 * (i - 1), 0.1 * i, 0), Color.WHITE, Vector3.ONE, 6)
		_rb_t(b, sm)
		_bobbers.append([b, 0.1 * i, 0.05, 1.6 + 0.4 * i, float(i) * 1.7])
	Props.strip_outlines(steam)
	# ince belli bardaklar (tabak + cam + çay)
	var glass := _rb_mat(Color("e8f4f4"), 0.3, 0.0)
	for i in 4:
		var z := -5.3 - 0.14 * i
		Props.cyl(self, 0.06, 0.01, Vector3(3.6, 1.09, z), Color("f0ece0"), Vector3.ZERO, 10)
		Props.cyl(self, 0.027, 0.06, Vector3(3.6, 1.125, z), Color("a8501a"), Vector3.ZERO, 8, -1.0, 0.4)
		_rb_t(Props.cyl(self, 0.03, 0.09, Vector3(3.6, 1.145, z), Color.WHITE, Vector3.ZERO, 8, 0.04), glass)
	# şekerlik
	Props.cyl(self, 0.07, 0.08, Vector3(3.6, 1.1, -6.15), Color("f0ece0"))
	Props.ball(self, 0.04, Vector3(3.6, 1.16, -6.15), Color("f0ece0"), Vector3(1, 0.6, 1), 6)
	# arka duvar: çay kutuları rafı, takvim, tabela
	Props.box(self, Vector3(0.3, 0.04, 2.4), Vector3(6.85, 1.25, -3.9), C_WOOD)
	var tins := [Color("c0392b"), Color("2e86c1"), Color("d4ac0d"), Color("27ae60")]
	for i in 4:
		Props.cyl(self, 0.07, 0.2, Vector3(6.85, 1.37, -3.2 - 0.5 * i), tins[i], Vector3.ZERO, 8)
	Props.box(self, Vector3(0.02, 0.38, 0.28), Vector3(6.96, 1.7, -6.1), C_PAPER)
	Props.box(self, Vector3(0.025, 0.08, 0.28), Vector3(6.955, 1.92, -6.1), Color("b83a2a"))
	_lbl(self, "29 MAYIS", "29 MAY", Vector3(6.93, 1.66, -6.1), 30, Color("222222"), Vector3(0, -90, 0), 0.26)
	Props.box(self, Vector3(0.04, 0.8, 1.9), Vector3(6.96, 2.1, -4.6), Color("2b4a3a"))
	_lbl(self, "ÇAY 1 LİRA", "TEA 1 LIRA", Vector3(6.93, 2.3, -4.6), 52, Color("f0e8d0"), Vector3(0, -90, 0))
	Props.box(self, Vector3(0.02, 0.05, 1.5), Vector3(6.94, 2.3, -4.6), Color("d8281c"), Vector3(6, 0, 0))
	_lbl(self, "ÜCRETSİZ (SONSUZA DEK)", "FREE (FOREVER)", Vector3(6.93, 1.93, -4.6), 30, Color("ffd24a"), Vector3(0, -90, 0), 1.8)
	# sıcak ışık
	_bulb(Vector3(4.5, 2.6, -4.6), Color("ffb866"), 1.3, 6.5)
	Props.ball(self, 0.07, Vector3(4.5, 2.72, -4.6), Color("ffd89a"), Vector3.ONE, 6, 3.0)
	# Çaycı Necmi
	_rb_necmi_p = Person.new({"coat": Color("cfd4d0"), "pants": Color("3a3a42"), "hair": Color("8a8a8a"),
		"mustache": true, "apron": Color("f0eee4"), "hat": "none"})
	_rb_necmi_p.set_meta("spk", "SPK_NECMI")
	_rb_necmi_p.set_meta("no_talk", true)
	_rb_necmi_p.position = Vector3(4.8, 0, -5.2)
	_rb_necmi_p.rotation_degrees.y = -90
	add_child(_rb_necmi_p)
	_rb_necmi_p.set_activity("stir")
	# etkileşimler
	_reg("bur_teapot", Vector3(0.5, 0.7, 0.5), tp + Vector3(0, 0.3, 0), "UI_BUR_LOOK", _rb_teapot)
	_reg("bur_necmi", Vector3(1.0, 1.8, 0.9), Vector3(4.8, 0.9, -5.2), "UI_BUR_TALK", _rb_necmi, self, false)


func _rb_teapot() -> void:
	_say(_next("bur_teapot", ["BUR_TEAPOT", "BUR_TEAPOT_2"]))
	Audio.sfx("tea_stir", -10.0)
	if _count("bur_teapot") == 2:
		_second(1, _rb_teapot_pos + Vector3(0, 0.3, 0))


func _rb_necmi() -> void:
	_say(_next("bur_necmi", ["BUR_NECMI", "BUR_NECMI_2", "BUR_NECMI_3"]), 4.0, "SPK_NECMI")
	Audio.sfx("tea_stir", -8.0)
	if is_instance_valid(_rb_necmi_p):
		_rb_necmi_p.emote("nod")
	_rb_talk(_rb_necmi_p, 3.5)


# ---------------------------------------------------------------- 2. BEKLEME SALONU (x -8.5..-2, z -3.5..-11.5)

func _rb_wait() -> void:
	var wall := Color("cfc08e")
	var blue := Color("2d5f8a")
	_floor(Vector2(6.5, 8.0), Vector3(-5.25, 0, -7.5), Color("6a5a46"), Color("5f5040"), 2.0)
	Props.solid(self, Vector3(6.7, 0.2, 8.2), Vector3(-5.35, 3.5, -7.5), C_CEIL)
	_wall(Vector3(6.7, 3.4, 0.2), Vector3(-5.35, 1.7, -3.5), wall)
	_wall(Vector3(6.7, 3.4, 0.2), Vector3(-5.35, 1.7, -11.5), wall)
	_wall(Vector3(0.2, 3.4, 8.2), Vector3(-8.6, 1.7, -7.5), wall)
	Props.box(self, Vector3(6.4, 1.1, 0.04), Vector3(-5.3, 0.55, -3.62), blue)
	Props.box(self, Vector3(6.4, 1.1, 0.04), Vector3(-5.3, 0.55, -11.38), blue)
	Props.box(self, Vector3(0.04, 1.1, 7.8), Vector3(-8.48, 0.55, -7.5), blue)
	# loş sodyum ışığı + armatür
	_bulb(Vector3(-5.3, 3.0, -7.5), Color("ffc477"), 0.9, 8.0)
	Props.box(self, Vector3(0.2, 0.05, 2.0), Vector3(-5.3, 3.35, -7.5), Color("ffd9a0"), Vector3.ZERO, 1.5)
	# asma tabela
	Props.box(self, Vector3(0.05, 0.5, 2.4), Vector3(-2.6, 2.8, -6.4), Color("1d3f5a"))
	_lbl(self, "BEKLEME SALONU", "WAITING ROOM", Vector3(-2.57, 2.8, -6.4), 40, Color("f4ecd4"), Vector3(0, 90, 0), 2.2)
	# turuncu kova koltuk sıraları (arka duvara bakar)
	var orange := Color("e08a2c")
	var steel := Color("55606a")
	for r in 3:
		var x := -4.6 - 1.3 * r
		Props.box(self, Vector3(0.08, 0.08, 3.0), Vector3(x, 0.32, -7.9), steel)
		Props.box(self, Vector3(0.06, 0.32, 0.06), Vector3(x, 0.16, -6.6), steel)
		Props.box(self, Vector3(0.06, 0.32, 0.06), Vector3(x, 0.16, -9.2), steel)
		Props.box(self, Vector3(0.05, 0.34, 2.8), Vector3(x + 0.22, 0.68, -7.9), orange)
		for i in 5:
			Props.box(self, Vector3(0.4, 0.06, 0.46), Vector3(x, 0.45, -6.8 - 0.55 * i), orange)
	# sıra numarası makinesi
	Props.box(self, Vector3(0.4, 1.3, 0.4), Vector3(-2.7, 0.65, -4.6), Color("8a949a"))
	Props.box(self, Vector3(0.46, 0.3, 0.46), Vector3(-2.7, 1.45, -4.6), Color("c42a22"))
	_lbl(self, "SIRA NO", "TICKET", Vector3(-2.46, 1.45, -4.6), 36, Color.WHITE, Vector3(0, 90, 0), 0.4)
	Props.box(self, Vector3(0.02, 0.22, 0.1), Vector3(-2.49, 1.0, -4.6), C_PAPER, Vector3(0, 0, -8))
	_reg("bur_ticket", Vector3(0.6, 1.2, 0.7), Vector3(-2.7, 0.9, -4.6), "UI_BUR_PULL", _rb_ticket)
	# kırmızı LED ekran (arka duvar), yanıp söner
	Props.box(self, Vector3(0.06, 0.8, 3.2), Vector3(-8.47, 2.45, -7.5), Color("1a1a1a"))
	_glow(self, Vector3(-8.35, 2.45, -7.5), Vector2(3.8, 1.4), Color("ff2a1a"), Vector3(0, 90, 0), 0.4)
	var led := _lbl(self, "SIRADAKİ: 1453", "NOW SERVING: 1453", Vector3(-8.4, 2.45, -7.5), 64, Color("ff4a3a"), Vector3(0, 90, 0), 2.9)
	var tw := led.create_tween().set_loops()
	tw.tween_property(led, "modulate:a", 0.3, 0.6)
	tw.tween_property(led, "modulate:a", 1.0, 0.6)
	_reg("bur_display", Vector3(0.4, 0.9, 3.2), Vector3(-8.3, 2.45, -7.5), "UI_BUR_LOOK", _rb_display)
	# kauçuk bitkisi
	Props.cyl(self, 0.18, 0.3, Vector3(-3.0, 0.15, -10.8), Color("8a4a2a"), Vector3.ZERO, 8, 0.22)
	Props.ball(self, 0.18, Vector3(-3.0, 0.6, -10.8), Color("2f6a34"), Vector3(1, 1.4, 0.4))
	Props.ball(self, 0.17, Vector3(-2.9, 0.85, -10.8), Color("3a7a3a"), Vector3(0.5, 1.4, 1))
	Props.ball(self, 0.16, Vector3(-3.1, 0.78, -10.7), Color("2a5a2e"), Vector3(1, 1.3, 0.5))
	# uyuyan memur (primitifler; Person değil)
	Props.solid(self, Vector3(0.7, 0.85, 1.8), Vector3(-8.0, 0.425, -10.3), C_WOOD_DARK)
	Props.box(self, Vector3(0.4, 0.05, 0.4), Vector3(-7.1, 0.43, -10.4), steel)
	Props.box(self, Vector3(0.3, 0.5, 0.3), Vector3(-7.2, 0.78, -10.4), Color("4a5a3a"), Vector3(0, 0, 18))
	Props.ball(self, 0.12, Vector3(-7.52, 0.98, -10.4), Color("e8b894"))
	Props.box(self, Vector3(0.5, 0.08, 0.1), Vector3(-7.7, 0.9, -10.15), Color("4a5a3a"))
	var zzz := Props.label(self, "Zzz", Vector3(-7.6, 1.5, -10.4), 48, Color("e8e0c8"), Vector3(0, 90, 0))
	_bobbers.append([zzz, 1.5, 0.08, 1.5, 0.0])
	# hayaletler: oturanlar
	var blue_t := Color("a8d4ff")
	var green_t := Color("b4ffe0")
	var warm_t := Color("ffe4b8")
	_rb_ghost("toga", Vector3(-4.6, 0, -7.35), true, -90.0, blue_t, 0.0)
	_rb_ghost("legion", Vector3(-4.6, 0, -8.45), true, -90.0, warm_t, 1.3)
	_rb_ghost("bork", Vector3(-5.9, 0, -7.9), true, -90.0, green_t, 2.1)
	_rb_ghost("fedora", Vector3(-5.9, 0, -9.0), true, -90.0, blue_t, 3.0)
	_rb_ghost("byz", Vector3(-7.2, 0, -6.8), true, -90.0, warm_t, 4.2)
	# ayakta bekleyenler
	_rb_ghost("astro", Vector3(-6.6, 0.0, -10.4), false, -60.0, blue_t, 0.7)
	_reg("bur_ghost", Vector3(3.4, 1.4, 2.9), Vector3(-5.9, 0.7, -7.9), "UI_BUR_LOOK", _rb_ghost_talk)


## Başka çağlardan bekleyenler (yarı saydam hayaletlerdi; yer tutucu gibi duruyordu): Romalı senatör, lejyoner,
## yeniçeri, 1920'lerden bir memur, Bizanslı soylu, astronot. Koltuktakiler LED ekrana bakar.
const _RB_ERA := {
	"toga": {"coat": Color("efe9dc"), "pants": Color("efe9dc"), "robe": Color("efe9dc"), "hair": Color("9a9a90"), "hair_style": "receding", "skin": Color("e0a882")},
	"legion": {"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "armor": "mail", "skin": Color("d9a07a")},
	"bork": {"coat": Color("2f5f8a"), "pants": Color("e8e0c8"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")},
	"fedora": {"coat": Color("5a5a62"), "pants": Color("3a3a42"), "hat": "fedora", "mustache": true, "skin": Color("ecc0a0")},
	"byz": {"coat": Color("5a2a6a"), "pants": Color("3a2a30"), "robe": Color("5a2a6a"), "hat": "skiadion", "beard": true, "skin": Color("e0b08a")},
	"astro": {"coat": Color("eceae4"), "pants": Color("eceae4"), "hat": "astro", "skin": Color("e8b894")},
}


func _rb_ghost(kind: String, pos: Vector3, sit: bool, yaw: float, _tint: Color, _phase: float) -> void:
	var p := Person.new(_RB_ERA[kind])
	p.set_meta("no_unclip", true)
	add_child(p)
	p.position = Vector3(pos.x, 0.0, pos.z)
	p.rotation_degrees.y = yaw
	if sit:
		p.set_activity("sit")
	var st: Array = [p]
	while st.size() > 0:
		var n: Node = st.pop_back()
		st.append_array(n.get_children())
		if n is GeometryInstance3D:
			(n as GeometryInstance3D).visibility_range_end = 24.0


func _rb_ticket() -> void:
	_say(_next("bur_ticket", ["BUR_TICKET", "BUR_TICKET_2", "BUR_TICKET_3"]))
	Audio.sfx("paper_tear", -10.0, 1.4)
	var n := 4582118 + _count("bur_ticket")
	var t := Node3D.new()
	t.position = Vector3(-2.5, 0.92, -4.6)
	t.rotation_degrees = Vector3(0, 0, 75)
	add_child(t)
	Props.box(t, Vector3(0.12, 0.004, 0.2), Vector3.ZERO, C_PAPER)
	Props.label(t, _rb_fmt(n), Vector3(0, 0.004, 0), 16, Color("222222"), Vector3(-90, 0, 0))
	var tw := t.create_tween().set_parallel(true)
	tw.tween_property(t, "position", Vector3(-2.15, 0.03, -4.85), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(t, "rotation_degrees:z", 0.0, 1.0)
	tw.tween_property(t, "rotation_degrees:y", 40.0, 1.0)
	tw.chain().tween_interval(4.0)
	tw.chain().tween_callback(t.queue_free)
	var tw2 := t.create_tween()
	tw2.tween_property(t, "rotation_degrees:x", 20.0, 0.4)
	tw2.tween_property(t, "rotation_degrees:x", -15.0, 0.3)
	tw2.tween_property(t, "rotation_degrees:x", 0.0, 0.3)


func _rb_display() -> void:
	_say(_next("bur_display", ["BUR_DISPLAY", "BUR_DISPLAY_2"]))
	Audio.sfx("radio_beep", -12.0)


func _rb_ghost_talk() -> void:
	_say(_next("bur_ghost", ["BUR_GHOST", "BUR_GHOST_2", "BUR_GHOST_3"]))
	Audio.sfx("veil_hum", -14.0)


# ---------------------------------------------------------------- 3. KAYIP ZAMAN BÜROSU (x 2..9, z -17.9..-24.4)

func _rb_lost() -> void:
	var wall := Color("9a8f70")
	var cardboard := [Color("a9825a"), Color("b58d63"), Color("9a7650")]
	_floor(Vector2(7.0, 6.5), Vector3(5.5, 0, -21.15), Color("7a6e5a"), Color("6a5e4a"), 2.0)
	Props.solid(self, Vector3(7.2, 0.2, 6.9), Vector3(5.6, 3.5, -21.15), C_CEIL)
	_wall(Vector3(7.3, 3.4, 0.3), Vector3(5.65, 1.7, -17.75), wall)     # depo duvarıyla arasındaki boşluğu kapatır
	_wall(Vector3(7.3, 3.4, 0.2), Vector3(5.65, 1.7, -24.5), wall)
	_wall(Vector3(0.2, 3.4, 6.9), Vector3(9.1, 1.7, -21.15), wall)
	# iki çıplak ampul
	for p in [Vector3(4.6, 2.7, -19.6), Vector3(6.8, 2.7, -22.8)]:
		Props.box(self, Vector3(0.012, 0.7, 0.012), p + Vector3(0, 0.35, 0), Color("222222"))
		Props.ball(self, 0.06, p, Color("ffe0a8"), Vector3.ONE, 6, 3.0)
	_bulb(Vector3(5.7, 2.6, -21.2), Color("ffe0a8"), 1.4, 7.0)      # iki ampulün tek ışığı
	# asma tabela
	Props.box(self, Vector3(0.05, 0.45, 2.6), Vector3(2.55, 2.75, -21.5), Color("3a2a1a"))
	_lbl(self, "KAYIP ZAMAN BÜROSU", "LOST TIME OFFICE", Vector3(2.52, 2.75, -21.5), 34, Color("f4e8c0"), Vector3(0, -90, 0), 2.4)
	# tezgâh (kuzey ucunda 1 m geçit) + zil
	Props.solid(self, Vector3(0.6, 1.0, 3.4), Vector3(2.6, 0.5, -21.7), C_WOOD)
	Props.box(self, Vector3(0.75, 0.05, 3.55), Vector3(2.6, 1.025, -21.7), C_WOOD_DARK)
	Props.cyl(self, 0.07, 0.02, Vector3(2.6, 1.07, -21.0), C_BRASS, Vector3.ZERO, 10)
	Props.ball(self, 0.06, Vector3(2.6, 1.1, -21.0), C_BRASS, Vector3(1, 0.8, 1), 8)
	_reg("bur_bell", Vector3(0.4, 0.4, 0.4), Vector3(2.6, 1.15, -21.0), "UI_BUR_RING", _rb_bell, self, false)
	# memur Sabri + gazete
	_rb_sabri_p = Person.new({"coat": Color("6a5a3a"), "pants": Color("3a3a40"), "hair": Color("3a3a3a"),
		"glasses": true, "hat": "none"})
	_rb_sabri_p.set_meta("spk", "SPK_SABRI")
	_rb_sabri_p.set_meta("no_talk", true)
	_rb_sabri_p.position = Vector3(3.8, 0, -21.2)
	_rb_sabri_p.rotation_degrees.y = -90
	add_child(_rb_sabri_p)
	_rb_paper = Props.box(self, Vector3(0.03, 0.5, 0.4), Vector3(3.55, 1.5, -21.2), Color("d8d0b8"))
	# çelik raflar + etiketli koliler (arka duvar)
	var steel := Color("7f8a8c")
	var tags := {"0_1_0": "Yıl: 1071", "1_0_1": "Yıl: 1299", "1_2_0": "Yıl: 1920", "2_1_0": "Yıl: 2031"}
	var zcs := [-19.1, -21.2, -23.3]
	for u in 3:
		var zc: float = zcs[u]
		Props.box(self, Vector3(0.45, 2.0, 0.04), Vector3(8.775, 1.0, zc - 0.98), steel)
		Props.box(self, Vector3(0.45, 2.0, 0.04), Vector3(8.775, 1.0, zc + 0.98), steel)
		for l in 3:
			var by := 0.4 + 0.6 * l
			Props.box(self, Vector3(0.45, 0.04, 2.0), Vector3(8.775, by, zc), steel)
			var cnt := 1 if l == 2 else 2
			for j in cnt:
				var h := 0.26 + 0.03 * ((u * 7 + l * 3 + j * 5) % 4)
				var bz := zc - 0.5 + 0.9 * j
				Props.box(self, Vector3(0.38, h, 0.5), Vector3(8.77, by + 0.02 + h * 0.5, bz), cardboard[(u + l + j) % 3])
				var key := "%d_%d_%d" % [u, l, j]
				if tags.has(key):
					Props.label(self, tags[key], Vector3(8.575, by + 0.02 + h * 0.5, bz), 18, Color("2a1a0a"), Vector3(0, -90, 0), 0.45)
	_reg("bur_lostshelf", Vector3(0.8, 2.2, 6.0), Vector3(8.6, 1.1, -21.15), "UI_BUR_LOOK", _rb_lostshelf)
	# Nokia 3310 cam fanus altında
	var np := Vector3(6.2, 1.0, -21.8)
	Props.box(self, Vector3(0.6, 1.0, 0.6), Vector3(6.2, 0.5, -21.8), Color("c8c4b8"))
	Props.box(self, Vector3(0.05, 0.16, 0.08), np + Vector3(0, 0.1, 0), Color("5a6870"))
	Props.box(self, Vector3(0.012, 0.05, 0.06), np + Vector3(-0.03, 0.14, 0), Color("8fd05a"), Vector3.ZERO, 1.5)
	Props.box(self, Vector3(0.012, 0.06, 0.06), np + Vector3(-0.03, 0.06, 0), Color("3a4650"))
	var dome := Props.ball(self, 0.22, np + Vector3(0, 0.12, 0), Color.WHITE, Vector3(1, 1.1, 1), 12)
	_rb_t(dome, _rb_mat(Color("dff4ff"), 0.22, 0.0))
	Props.strip_outlines(dome)
	Props.label(self, "1453 · Topkapı önü", Vector3(5.88, 0.72, -21.8), 24, Color("222222"), Vector3(0, -90, 0), 0.55)
	_reg("bur_nokia", Vector3(0.6, 0.6, 0.6), np + Vector3(0, 0.1, 0), "UI_BUR_LOOK", _rb_nokia)
	# Roma sandaleti + beyaz spor çorabı
	Props.box(self, Vector3(0.7, 0.5, 0.5), Vector3(3.3, 0.25, -23.8), C_WOOD)
	Props.box(self, Vector3(0.32, 0.03, 0.12), Vector3(3.3, 0.515, -23.8), Color("8a6a40"), Vector3(0, 90, 0))
	Props.box(self, Vector3(0.03, 0.05, 0.14), Vector3(3.26, 0.55, -23.8), Color("6a4a2a"))
	Props.box(self, Vector3(0.03, 0.05, 0.14), Vector3(3.34, 0.55, -23.8), Color("6a4a2a"))
	Props.box(self, Vector3(0.1, 0.1, 0.12), Vector3(3.37, 0.58, -23.8), Color("f4f4f0"))
	Props.label(self, "MS 79", Vector3(2.94, 0.3, -23.8), 28, Color("f0e8d0"), Vector3(0, -90, 0), 0.5)
	_reg("bur_sandal", Vector3(0.6, 0.6, 0.6), Vector3(3.3, 0.7, -23.8), "UI_BUR_LOOK", _rb_sandal)
	# tavuk kafesi (tel = ince kutular), masa üstünde
	var wire := Color("5a5f62")
	Props.box(self, Vector3(0.9, 0.5, 0.6), Vector3(7.6, 0.25, -18.5), C_WOOD_DARK)
	Props.box(self, Vector3(0.7, 0.04, 0.5), Vector3(7.6, 0.52, -18.5), C_WOOD)
	for cx in [-0.34, 0.34]:
		for cz in [-0.24, 0.24]:
			Props.box(self, Vector3(0.02, 0.45, 0.02), Vector3(7.6 + cx, 0.77, -18.5 + cz), wire)
	Props.box(self, Vector3(0.7, 0.02, 0.5), Vector3(7.6, 1.0, -18.5), wire)
	Props.box(self, Vector3(0.7, 0.015, 0.015), Vector3(7.6, 0.75, -18.26), wire)
	Props.box(self, Vector3(0.7, 0.015, 0.015), Vector3(7.6, 0.75, -18.74), wire)
	Props.ball(self, 0.1, Vector3(7.6, 0.66, -18.5), Color("f0d040"), Vector3(1, 0.9, 1.2), 8)
	Props.ball(self, 0.05, Vector3(7.5, 0.78, -18.5), Color("f4f0e0"), Vector3.ONE, 6)
	Props.label(self, "No. 1204", Vector3(7.14, 0.3, -18.5), 26, Color("f0e8d0"), Vector3(0, -90, 0), 0.6)
	# selfie çubuğu (duvara yaslı)
	Props.cyl(self, 0.012, 1.1, Vector3(8.3, 0.58, -18.25), Color("222222"), Vector3(15, 0, 0), 6)
	Props.box(self, Vector3(0.05, 0.1, 0.012), Vector3(8.3, 1.16, -18.1), Color("3a3a40"), Vector3(15, 0, 0))
	Props.label(self, "Otağ-ı Hümayun", Vector3(8.3, 1.55, -18.0), 22, Color("f0e8d0"), Vector3(0, 180, 0), 0.8)
	# şemsiye
	Props.cyl(self, 0.12, 0.4, Vector3(5.0, 0.2, -18.3), Color("4a4a4a"), Vector3.ZERO, 8)
	Props.cyl(self, 0.012, 1.0, Vector3(5.0, 0.7, -18.3), Color("1a1a1a"), Vector3.ZERO, 6)
	Props.cyl(self, 0.045, 0.45, Vector3(5.0, 1.25, -18.3), Color("2a2a3a"), Vector3.ZERO, 8, 0.008)
	Props.label(self, "Hiçbir yıl", Vector3(5.0, 1.75, -18.0), 24, Color("f0e8d0"), Vector3(0, 180, 0), 0.7)


func _rb_bell() -> void:
	Audio.sfx("typewriter_bell", -4.0)
	_say(_next("bur_bell", ["BUR_BELL", "BUR_BELL_2"]), 4.0, "SPK_SABRI")
	_rb_talk(_rb_sabri_p, 3.5)
	if is_instance_valid(_rb_paper) and not _rb_paper_busy:
		_rb_paper_busy = true
		var tw := create_tween()
		tw.tween_property(_rb_paper, "position:y", 0.98, 0.25)
		tw.tween_interval(0.1 if GameState.autotest else 2.0)
		tw.tween_property(_rb_paper, "position:y", 1.5, 0.35)
		tw.tween_callback(func(): _rb_paper_busy = false)


func _rb_nokia() -> void:
	_say(_next("bur_nokia", ["BUR_NOKIA", "BUR_NOKIA_2"]))
	Audio.sfx("radio_beep", -10.0, 0.8)
	if _count("bur_nokia") == 2:
		_second(2, Vector3(6.2, 1.3, -21.8))


func _rb_sandal() -> void:
	_say(_next("bur_sandal", ["BUR_SANDAL", "BUR_SANDAL_2"]))
	Audio.sfx("cloth", -10.0)


func _rb_lostshelf() -> void:
	_say(_next("bur_lostshelf", ["BUR_LOSTSHELF", "BUR_LOSTSHELF_2", "BUR_LOSTSHELF_3", "BUR_LOSTSHELF_4"]))
	Audio.sfx("paper_tear", -14.0, 0.8)


## ---- bur_rooms_c: Arşiv, Paradoks Şikâyet Masası, Müdür Kapısı, Yönetmelik Duvarı, Atrium, koridor sonu penceresi ----
## Giriş noktası: _rc_build()  (bureau.gd içinde _build_rooms() çağırır)

var _rc_hatice: Person
var _rc_hatice_rig: Node3D            # merdiven + Hatice birlikte raydan kayar
var _rc_nuran: Person
var _rc_paper: MeshInstance3D          # tezgâhtan kayan kâğıt
var _rc_paper_tw: Tween
var _rc_arch_drawer: Node3D
var _rc_arch_open := false
var _rc_drawer_mat: StandardMaterial3D
var _rc_dir_glow: MeshInstance3D       # müdür kapısının altından sızan ışık
var _rc_dir_tw: Tween
var _rc_dir_bright := false
var _rc_win_mat: ShaderMaterial        # atrium büyük penceresi
var _rc_win_tw: Tween
var _rc_pend: Node3D


func _rc_build() -> void:
	_rc_archive()
	_rc_complaint()
	_rc_director()
	_rc_regwall()
	_rc_atrium()
	_rc_end_window()
	if not seconds_changed.is_connected(_rc_on_seconds):
		seconds_changed.connect(_rc_on_seconds)
	if seconds_found() >= 5:
		_rc_on_seconds(5, true)


# ---------------------------------------------------------------- ortak yardımcılar

## Pencere shader'ı kaplı dörtgen. +Z yüzü odaya bakacak şekilde rot verilir.
func _rc_window_quad(parent: Node3D, size: Vector2, pos: Vector3, rot: Vector3, view_ref: float) -> ShaderMaterial:
	var sh = load("res://assets/shaders/time_window.gdshader")
	if sh == null:
		return null
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("quad_size", size)
	m.set_shader_parameter("view_ref", view_ref)
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return m


## Çekmece dokulu malzeme: tek kutu üzerinde dolap çekmeceleri (üçgen-düzlemsel, 0,9 x 0,8 m'lik tekrar)
func _rc_dmat() -> StandardMaterial3D:
	if _rc_drawer_mat:
		return _rc_drawer_mat
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color("2b3633"))
	for r in 2:
		var y0 := r * 32
		img.fill_rect(Rect2i(2, y0 + 2, 60, 28), Color("55655f"))
		img.fill_rect(Rect2i(22, y0 + 6, 20, 8), Color("e4dcc4"))
		img.fill_rect(Rect2i(25, y0 + 9, 14, 1), Color("6a6a60"))
		img.fill_rect(Rect2i(20, y0 + 21, 24, 3), Color("c49a45"))
	img.generate_mipmaps()
	var m := StandardMaterial3D.new()
	m.albedo_texture = ImageTexture.create_from_image(img)
	m.uv1_triplanar = true
	m.uv1_scale = Vector3(1.0 / 0.9, 1.0 / 0.8, 1.0 / 0.9)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	m.roughness = 0.8
	_rc_drawer_mat = m
	return m


func _rc_cab(size: Vector3, pos: Vector3) -> void:
	var b := Props.solid(self, size, pos, Color("4a5854"))
	(b.get_child(0) as MeshInstance3D).material_override = _rc_dmat()


## id için "KEY", "KEY_2", ... n varyantı sırayla söyler (nesne replikleri: Nihat)
func _rc_look(id: String, key: String, n: int) -> void:
	var keys: Array = [key]
	for i in range(2, n + 1):
		keys.append("%s_%d" % [key, i])
	_say(_next(id, keys))


func _rc_talk_pulse(p: Person) -> void:
	if not is_instance_valid(p):
		return
	p.talking = true
	get_tree().create_timer(3.0).timeout.connect(_rc_untalk.bind(p))


func _rc_untalk(p: Person) -> void:
	if is_instance_valid(p):
		p.talking = false


# ---------------------------------------------------------------- ARŞİV (batı, x -11..-2, z -13..-24)

func _rc_archive() -> void:
	var wc := Color("6d7d78")
	var low := Color("4e5c58")
	_floor(Vector2(9.0, 11.0), Vector3(-6.5, 0, -18.5), Color("2c3338"), Color("262c31"), 0.8)
	Props.solid(self, Vector3(9.2, 0.2, 11.2), Vector3(-6.6, COR_H + 0.1, -18.5), Color("3b4743"))
	_wall(Vector3(9.0, COR_H, 0.2), Vector3(-6.7, COR_H / 2, -12.9), wc)
	_wall(Vector3(9.0, COR_H, 0.2), Vector3(-6.7, COR_H / 2, -24.1), wc)
	_wall(Vector3(0.2, COR_H, 11.2), Vector3(-11.1, COR_H / 2, -18.5), wc)
	Props.box(self, Vector3(8.8, 0.9, 0.04), Vector3(-6.6, 0.45, -13.02), low)
	Props.box(self, Vector3(8.8, 0.9, 0.04), Vector3(-6.6, 0.45, -23.98), low)
	Props.box(self, Vector3(0.04, 0.9, 10.8), Vector3(-10.98, 0.45, -18.5), low)
	# soğuk, loş ışık
	_bulb(Vector3(-6.5, 3.0, -18.0), Color("cfe7ff"), 1.1, 9.5)
	Props.box(self, Vector3(0.12, 0.05, 1.6), Vector3(-6.5, 3.35, -18.0), Color("dff0ff"), Vector3.ZERO, 1.6)
	# çıkış kapısı + kırmızı tabela (arka duvar)
	Props.box(self, Vector3(0.06, 2.2, 1.1), Vector3(-10.96, 1.1, -18.5), Color("1b2220"))
	Props.box(self, Vector3(0.05, 0.3, 1.1), Vector3(-10.94, 2.6, -18.5), Color("8a1410"), Vector3.ZERO, 1.4)
	_lbl(self, "ÇIKIŞ / EXIT", "ÇIKIŞ / EXIT", Vector3(-10.9, 2.6, -18.5), 26, Color("ffd8d0"), Vector3(0, 90, 0), 1.0)
	_glow(self, Vector3(-10.85, 2.6, -18.5), Vector2(2.4, 1.2), Color("ff2a1a"), Vector3(0, 90, 0), 0.5)
	# çekmece duvarları
	_rc_cab(Vector3(0.6, 2.9, 9.2), Vector3(-7.1, 1.45, -18.8))       # merdiven duvarı (doğuya bakar)
	_rc_cab(Vector3(0.6, 2.9, 3.2), Vector3(-8.5, 1.45, -15.6))
	_rc_cab(Vector3(0.6, 2.9, 4.3), Vector3(-10.7, 1.45, -15.75))     # arka duvar boyunca (kapının iki yanı)
	_rc_cab(Vector3(0.6, 2.9, 4.3), Vector3(-10.7, 1.45, -21.25))
	_rc_cab(Vector3(2.8, 2.9, 0.6), Vector3(-9.0, 1.45, -23.7))
	_rc_cab(Vector3(2.8, 2.9, 0.6), Vector3(-9.0, 1.45, -13.3))
	# yarı açık iki çekmece (yakın sıra)
	Props.box(self, Vector3(0.4, 0.32, 0.68), Vector3(-6.6, 0.5, -20.2), Color("62736d"))
	Props.box(self, Vector3(0.04, 0.05, 0.2), Vector3(-6.38, 0.55, -20.2), C_BRASS)
	Props.box(self, Vector3(0.3, 0.32, 0.68), Vector3(-6.65, 0.9, -17.4), Color("62736d"))
	Props.box(self, Vector3(0.04, 0.05, 0.2), Vector3(-6.48, 0.95, -17.4), C_BRASS)
	# raylar
	Props.box(self, Vector3(0.05, 0.05, 9.2), Vector3(-6.78, 2.75, -18.8), C_BRASS)
	Props.box(self, Vector3(0.05, 0.03, 9.0), Vector3(-6.1, 0.015, -18.8), C_METAL)
	# kayar merdiven + Hatice
	var rig := Node3D.new()
	rig.position = Vector3(-6.1, 0, -16.0)
	add_child(rig)
	_rc_hatice_rig = rig
	for s: float in [-0.33, 0.33]:
		Props.box(rig, Vector3(0.05, 2.7, 0.05), Vector3(-0.14, 1.35, s), C_WOOD_DARK, Vector3(0, 0, 6))
	for k in 5:
		var ry := 0.4 + k * 0.5
		Props.box(rig, Vector3(0.04, 0.04, 0.7), Vector3(-ry * 0.105, ry, 0), C_WOOD)
	Props.box(rig, Vector3(0.5, 0.05, 0.7), Vector3(-0.134, 1.275, 0), C_WOOD)
	Props.box(rig, Vector3(0.4, 0.04, 0.06), Vector3(-0.45, 2.72, 0), C_BRASS)
	_rc_hatice = Person.new({"coat": Color("7a5a6a"), "pants": Color("3a2a30"), "hair": Color("6a5a50"), "hat": "bun", "glasses": true, "skirt": true, "skin": Color("e8b894")})
	_rc_hatice.set_meta("spk", "SPK_HATICE")
	_rc_hatice.set_meta("no_talk", true)
	rig.add_child(_rc_hatice)
	_rc_hatice.position = Vector3(-0.13, 1.3, 0)
	_rc_hatice.rotation_degrees.y = -90
	_reg("bur_hatice", Vector3(0.9, 2.0, 0.9), Vector3(-0.13, 2.2, 0), "UI_BUR_TALK", _rc_hatice_talk, rig, false)
	if not GameState.autotest:
		var tw := rig.create_tween().set_loops()
		tw.tween_interval(6.0)
		tw.tween_property(rig, "position:z", -22.0, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_interval(6.0)
		tw.tween_property(rig, "position:z", -16.0, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# kırmızı bantlı dosya, kürsüde
	var lp := Vector3(-9.3, 0.0, -19.8)
	Props.box(self, Vector3(0.32, 1.2, 0.32), Vector3(lp.x, 0.6, lp.z), C_WOOD_DARK)
	Props.box(self, Vector3(0.62, 0.06, 0.52), Vector3(lp.x, 1.23, lp.z), C_WOOD)
	Props.box(self, Vector3(0.3, 0.04, 0.22), Vector3(lp.x, 1.28, lp.z), Color("d9c9a0"))
	Props.box(self, Vector3(0.05, 0.045, 0.23), Vector3(lp.x - 0.05, 1.28, lp.z), Color("c0262d"))
	Props.label(self, "1453-T", Vector3(lp.x + 0.06, 1.312, lp.z), 14, Color("3a2a20"), Vector3(-90, 0, 0), 0.12)
	_reg("bur_tolga_file", Vector3(0.8, 0.5, 0.7), Vector3(lp.x, 1.3, lp.z), "UI_BUR_LOOK", _rc_tolga)
	# arşivin arşivi: çekmecenin içinde çekmece
	var d := Node3D.new()
	d.position = Vector3(-10.38, 1.1, -21.3)
	add_child(d)
	_rc_arch_drawer = d
	Props.box(d, Vector3(0.04, 0.34, 0.74), Vector3(0.02, 0, 0), Color("62736d"))
	Props.box(d, Vector3(0.04, 0.05, 0.22), Vector3(0.06, 0.04, 0), C_BRASS)
	Props.box(d, Vector3(0.5, 0.03, 0.68), Vector3(-0.27, -0.155, 0), Color("3c4a46"))
	Props.box(d, Vector3(0.5, 0.14, 0.02), Vector3(-0.27, -0.08, 0.34), Color("3c4a46"))
	Props.box(d, Vector3(0.5, 0.14, 0.02), Vector3(-0.27, -0.08, -0.34), Color("3c4a46"))
	Props.box(d, Vector3(0.02, 0.1, 0.26), Vector3(-0.12, -0.09, 0), Color("7a8a84"))
	Props.box(d, Vector3(0.18, 0.08, 0.24), Vector3(-0.22, -0.1, 0), Color("5a6a64"))
	Props.box(d, Vector3(0.02, 0.03, 0.08), Vector3(-0.1, -0.07, 0), C_BRASS)
	_reg("bur_archdrawer", Vector3(0.8, 0.6, 0.9), Vector3(-10.2, 1.1, -21.3), "UI_BUR_PULL", _rc_archdrawer)


func _rc_hatice_talk() -> void:
	_say(_next("bur_hatice", ["BUR_HATICE", "BUR_HATICE_2"]), 4.2, "SPK_HATICE")
	_rc_talk_pulse(_rc_hatice)


func _rc_tolga() -> void:
	_say(_next("bur_tolga_file", ["BUR_TOLGA_FILE", "BUR_TOLGA_FILE_2"]))
	Audio.sfx("newspaper", -14.0, 1.2)
	if _count("bur_tolga_file") >= 2:
		_second(3, Vector3(-9.3, 1.5, -19.8))


func _rc_archdrawer() -> void:
	_say(_next("bur_archdrawer", ["BUR_ARCHDRAWER", "BUR_ARCHDRAWER_2"]))
	_rc_arch_open = not _rc_arch_open
	Audio.sfx("wood_creak", -16.0, 1.3)
	if not is_instance_valid(_rc_arch_drawer):
		return
	var tw := create_tween()
	tw.tween_property(_rc_arch_drawer, "position:x", -10.38 + (0.42 if _rc_arch_open else 0.0), 0.05 if GameState.autotest else 0.7).set_trans(Tween.TRANS_SINE)


# ---------------------------------------------------------------- PARADOKS ŞİKÂYET MASASI (batı niş, x -4.2..-2, z -27.3..-31.2)

func _rc_complaint() -> void:
	var wc := Color("c9b98a")
	_floor(Vector2(2.2, 3.9), Vector3(-3.1, 0, -29.25), Color("7a6a4a"), Color("6c5d40"), 0.8)
	Props.solid(self, Vector3(2.4, 0.2, 4.1), Vector3(-3.1, COR_H + 0.1, -29.25), Color("b8b6a4"))
	_wall(Vector3(0.2, COR_H, 4.1), Vector3(-4.3, COR_H / 2, -29.25), wc)
	_wall(Vector3(2.2, COR_H, 0.2), Vector3(-3.1, COR_H / 2, -27.2), wc)
	_wall(Vector3(2.2, COR_H, 0.2), Vector3(-3.1, COR_H / 2, -31.3), wc)
	Props.box(self, Vector3(0.04, 1.0, 3.9), Vector3(-4.18, 0.5, -29.25), C_COR_LOW)
	_bulb(Vector3(-3.2, 3.0, -29.25), Color("ffe2b0"), 0.9, 4.5)
	# tabela
	Props.box(self, Vector3(0.05, 0.55, 2.6), Vector3(-4.16, 2.35, -29.25), C_WALNUT)
	_lbl(self, "PARADOKS ŞİKAYET MASASI", "PARADOX COMPLAINTS DESK", Vector3(-4.12, 2.35, -29.25), 26, Color("e8d8a8"), Vector3(0, 90, 0), 2.4)
	# tezgâh
	Props.set_pattern(Props.solid(self, Vector3(0.55, 1.05, 3.1), Vector3(-2.75, 0.525, -29.25), C_WOOD), C_WOOD, "wood")
	Props.box(self, Vector3(0.7, 0.06, 3.3), Vector3(-2.72, 1.08, -29.25), C_WOOD_DARK)
	Props.box(self, Vector3(0.3, 0.2, 0.22), Vector3(-2.75, 1.24, -28.15), C_PAPER, Vector3(0, 6, 0))
	Props.box(self, Vector3(0.28, 0.12, 0.2), Vector3(-2.7, 1.2, -28.6), Color("e2dcc8"), Vector3(0, -9, 0))
	# büyük kırmızı düğme
	Props.cyl(self, 0.2, 0.05, Vector3(-2.72, 1.135, -29.3), Color("2a2a2e"), Vector3.ZERO, 14)
	Props.cyl(self, 0.15, 0.07, Vector3(-2.72, 1.195, -29.3), Color("d02a22"), Vector3.ZERO, 14, 0.14, 1.0)
	Props.box(self, Vector3(0.02, 0.22, 1.1), Vector3(-2.465, 0.75, -29.3), C_BRASS)
	_lbl(self, "ŞİKAYET ET", "COMPLAIN", Vector3(-2.45, 0.75, -29.3), 22, Color("2a1c0c"), Vector3(0, 90, 0), 1.0)
	# kâğıt şişi
	Props.cyl(self, 0.008, 0.32, Vector3(-2.7, 1.27, -30.5), C_METAL, Vector3.ZERO, 6)
	Props.box(self, Vector3(0.18, 0.006, 0.24), Vector3(-2.7, 1.18, -30.5), C_PAPER, Vector3(0, 20, 0))
	Props.box(self, Vector3(0.18, 0.006, 0.24), Vector3(-2.7, 1.22, -30.5), Color("e2dcc8"), Vector3(0, -15, 0))
	# tezgâhın içinde bekleyen kâğıt (basınca dışarı kayar)
	_rc_paper = Props.box(self, Vector3(0.38, 0.008, 0.28), Vector3(-2.85, 0.8, -29.7), Color("f4efe0"))
	# Nuran
	_rc_nuran = Person.new({"coat": Color("8a3a4a"), "pants": Color("3a2a30"), "hair": Color("1f1a1a"), "skirt": true, "skin": Color("d8a888")})
	_rc_nuran.set_meta("spk", "SPK_NURAN")
	_rc_nuran.set_meta("no_talk", true)
	add_child(_rc_nuran)
	_rc_nuran.position = Vector3(-3.3, 0, -29.3)
	_rc_nuran.rotation_degrees.y = 90
	_reg("bur_paradoks", Vector3(1.4, 1.9, 3.0), Vector3(-3.0, 0.95, -29.25), "UI_BUR_PRESS", _rc_paradoks, null, false)
	if not GameState.autotest:
		var t := Timer.new()
		t.wait_time = 6.0
		t.autostart = true
		t.timeout.connect(_rc_nuran_stamp)
		add_child(t)


func _rc_nuran_stamp() -> void:
	if is_instance_valid(_rc_nuran) and is_visible_in_tree():
		_rc_nuran.stamp()
		Audio.sfx_at("stamp", _rc_nuran, -22.0)


func _rc_paradoks() -> void:
	_say(_next("bur_paradoks", ["BUR_PARADOKS", "BUR_PARADOKS_2", "BUR_PARADOKS_3"]), 4.4, "SPK_NURAN")
	if is_instance_valid(_rc_nuran):
		_rc_nuran.stamp()
		_rc_talk_pulse(_rc_nuran)
	Audio.sfx("stamp", -8.0)
	if is_instance_valid(_rc_paper):
		if _rc_paper_tw and _rc_paper_tw.is_valid():
			_rc_paper_tw.kill()
		_rc_paper.position.x = -2.85
		var fast := GameState.autotest
		_rc_paper_tw = create_tween()
		_rc_paper_tw.tween_property(_rc_paper, "position:x", -2.3, 0.05 if fast else 0.45).set_trans(Tween.TRANS_SINE)
		_rc_paper_tw.tween_interval(0.05 if fast else 3.0)
		_rc_paper_tw.tween_property(_rc_paper, "position:x", -2.85, 0.05 if fast else 0.5)


# ---------------------------------------------------------------- MÜDÜR KAPISI (doğu niş, x 2..2.4, z -29.2..-31.2)

func _rc_director() -> void:
	_wall(Vector3(0.2, COR_H, 2.6), Vector3(2.5, COR_H / 2, -30.2), C_COR_WALL)
	_wall(Vector3(0.2, COR_H, 0.2), Vector3(2.3, COR_H / 2, -29.1), C_COR_WALL)
	_wall(Vector3(0.2, COR_H, 0.2), Vector3(2.3, COR_H / 2, -31.3), C_COR_WALL)
	Props.solid(self, Vector3(0.6, 0.2, 2.6), Vector3(2.3, COR_H + 0.1, -30.2), Color("b8b6a4"))
	_floor(Vector2(0.5, 2.2), Vector3(2.25, 0, -30.2), Color("2a1e18"), Color("22170f"), 1.0)
	# çift kanatlı ceviz kapı (-x'e bakar)
	for s: float in [-0.46, 0.46]:
		Props.box(self, Vector3(0.06, 2.6, 0.88), Vector3(2.37, 1.3, -30.2 + s), C_WALNUT)
		Props.box(self, Vector3(0.02, 0.95, 0.6), Vector3(2.33, 0.75, -30.2 + s), Color("4a2d1e"))
		Props.box(self, Vector3(0.02, 0.95, 0.6), Vector3(2.33, 1.95, -30.2 + s), Color("4a2d1e"))
		Props.box(self, Vector3(0.03, 0.3, 0.03), Vector3(2.315, 1.1, -30.2 + s * 0.15), C_BRASS)
	Props.box(self, Vector3(0.08, 2.7, 0.1), Vector3(2.36, 1.35, -29.25), Color("231409"))
	Props.box(self, Vector3(0.08, 2.7, 0.1), Vector3(2.36, 1.35, -31.15), Color("231409"))
	Props.box(self, Vector3(0.1, 0.12, 2.0), Vector3(2.36, 2.66, -30.2), Color("231409"))
	Props.box(self, Vector3(0.015, 0.16, 0.7), Vector3(2.31, 1.65, -30.2), C_BRASS)
	_lbl(self, "MÜDÜR", "DIRECTOR", Vector3(2.3, 1.65, -30.2), 24, Color("2a1c0c"), Vector3(0, -90, 0), 0.6)
	# kırmızı halı şeridi (koridor ortası x -0.6..0.6 boş kalır)
	Props.box(self, Vector3(1.45, 0.012, 3.7), Vector3(1.34, 0.006, -30.2), C_RUG_EDGE)
	Props.box(self, Vector3(1.35, 0.016, 3.55), Vector3(1.34, 0.008, -30.2), Color("8a1c24"))
	# pirinç direkler + kadife kordon
	for pz: float in [-28.6, -31.8]:
		Props.cyl(self, 0.12, 0.03, Vector3(1.1, 0.015, pz), C_BRASS, Vector3.ZERO, 10)
		Props.cyl(self, 0.03, 0.95, Vector3(1.1, 0.5, pz), C_BRASS, Vector3.ZERO, 8)
		Props.ball(self, 0.05, Vector3(1.1, 1.0, pz), C_BRASS, Vector3.ONE, 8)
	Props.cyl(self, 0.02, 3.2, Vector3(1.1, 0.85, -30.2), Color("a01c28"), Vector3(90, 0, 0), 6)
	# kapının altından sızan ışık
	Props.box(self, Vector3(0.04, 0.02, 1.8), Vector3(2.31, 0.012, -30.2), Color("bff8ff"), Vector3.ZERO, 3.0)
	_rc_dir_glow = _glow(self, Vector3(1.4, 0.03, -30.2), Vector2(2.6, 3.4), Color("8ff0ff"), Vector3(-90, 0, 0), 0.45)
	_rc_dir_pulse()
	_reg("bur_director", Vector3(0.8, 2.6, 2.0), Vector3(2.2, 1.3, -30.2), "UI_BUR_KNOCK", _rc_director_knock)


func _rc_dir_pulse() -> void:
	if not is_instance_valid(_rc_dir_glow):
		return
	if _rc_dir_tw and _rc_dir_tw.is_valid():
		_rc_dir_tw.kill()
	var m := _rc_dir_glow.material_override as StandardMaterial3D
	var base := Color(0.56, 0.94, 1.0)
	var lo := 0.55 if _rc_dir_bright else 0.18
	var hi := 1.0 if _rc_dir_bright else 0.5
	var c_lo := Color(base.r * lo, base.g * lo, base.b * lo, 1.0)
	var c_hi := Color(base.r * hi, base.g * hi, base.b * hi, 1.0)
	m.albedo_color = c_lo
	_rc_dir_tw = _rc_dir_glow.create_tween().set_loops()
	_rc_dir_tw.tween_property(m, "albedo_color", c_hi, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_rc_dir_tw.tween_property(m, "albedo_color", c_lo, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Beşinci kayıp saniye bulununca kapının altındaki ışık kalıcı olarak parlar
func _rc_on_seconds(n: int, silent := false) -> void:
	if n >= 5 and not _rc_dir_bright:
		_rc_dir_bright = true
		_rc_dir_pulse()
		if not silent:
			Audio.sfx("veil_hum", -8.0)


func _rc_director_knock() -> void:
	Audio.sfx("kick_metal", -18.0, 0.8)
	if seconds_found() >= 5:
		_say("BUR_DIRECTOR_3")
	else:
		_say(_next("bur_director", ["BUR_DIRECTOR", "BUR_DIRECTOR_2"]))


# ---------------------------------------------------------------- YÖNETMELİK DUVARI (doğu koridor duvarı, z -32..-36)

func _rc_regwall() -> void:
	Props.box(self, Vector3(0.03, 1.8, 4.1), Vector3(1.985, 1.6, -34.0), C_WALNUT)
	var titles := [["Madde 1", "Art. 1"], ["Madde 14/b", "Art. 14/b"], ["Madde 27", "Art. 27"], ["Ek Madde 3", "Add. Art. 3"],
		["Madde 61/c", "Art. 61/c"], ["Geçici Madde 2", "Prov. Art. 2"], ["Madde 8", "Art. 8"], ["Madde 112", "Art. 112"],
		["Madde 5/a", "Art. 5/a"], ["Madde 77", "Art. 77"], ["Madde 0", "Art. 0"], ["Madde 31 Şubat", "Art. 31 Feb"]]
	for i in 12:
		var row := floori(i / 4.0)
		var col := i % 4
		var z := -32.5 - col * 1.0
		var y := 2.1 - row * 0.5
		Props.box(self, Vector3(0.02, 0.36, 0.7), Vector3(1.96, y, z), C_BRASS if (i + row) % 2 == 0 else Color("a88438"))
		_lbl(self, titles[i][0], titles[i][1], Vector3(1.945, y, z), 14, Color("2a1c0c"), Vector3(0, -90, 0), 0.6)
	_lbl(self, "YÖNETMELİK", "REGULATIONS", Vector3(1.94, 2.75, -34.0), 40, Color("e8d8a8"), Vector3(0, -90, 0), 2.4)
	_reg("bur_regwall", Vector3(0.5, 2.0, 4.2), Vector3(1.75, 1.7, -34.0), "UI_BUR_LOOK", _rc_look.bind("bur_regwall", "BUR_REGWALL", 2))


# ---------------------------------------------------------------- ATRIUM (doğu, x 2..16, z -36.5..-55.5, tavan 7,5)

func _rc_gear(centre: Vector3, r: float, teeth: int, thick: float, col: Color, speed: float) -> void:
	var g := Node3D.new()
	g.position = centre
	add_child(g)
	Props.cyl(g, r, thick, Vector3.ZERO, col, Vector3.ZERO, 14)
	for i in teeth:
		var a := TAU * float(i) / float(teeth)
		Props.box(g, Vector3(r * 0.22, thick, r * 0.16), Vector3(cos(a) * r * 1.05, 0, sin(a) * r * 1.05), col, Vector3(0, -rad_to_deg(a), 0))
	_spinners.append([g, Vector3.UP, speed])


## Zaman nehri maketinde iki nokta arası ince şerit (x, z) masa koordinatlarında
func _rc_strip(a: Vector2, b: Vector2, w: float, col: Color, em: float) -> void:
	var d := b - a
	var m := (a + b) * 0.5
	Props.box(self, Vector3(w, 0.02, d.length()), Vector3(m.x, 0.99, m.y), col, Vector3(0, rad_to_deg(atan2(d.x, d.y)), 0), em)


func _rc_atrium() -> void:
	var ind := Color("3c4a78")
	var dark := Color("26304e")
	var h := 7.5
	_floor(Vector2(14.0, 19.0), Vector3(9.0, 0, -46.0), Color("e6dcc2"), Color("33406a"), 0.5)
	Props.solid(self, Vector3(14.2, 0.3, 19.4), Vector3(9.1, h + 0.15, -46.0), Color("15162a"))
	_wall(Vector3(14.0, h, 0.2), Vector3(9.2, h / 2, -36.4), ind)
	_wall(Vector3(14.0, h, 0.2), Vector3(9.2, h / 2, -55.6), ind)
	# doğu duvarı: pencere açıklığının (z -40.5..-51.5, y 1..5,8) çevresi
	_wall(Vector3(0.2, h, 4.0), Vector3(16.1, h / 2, -38.5), ind)
	_wall(Vector3(0.2, h, 4.0), Vector3(16.1, h / 2, -53.5), ind)
	_wall(Vector3(0.2, 1.0, 11.0), Vector3(16.1, 0.5, -46.0), dark)
	_wall(Vector3(0.2, 1.7, 11.0), Vector3(16.1, 6.65, -46.0), ind)
	# koridor açıklığının üstü (y 3,4 üzeri) kapalı
	_wall(Vector3(0.2, h - COR_H, 19.0), Vector3(2.1, COR_H + (h - COR_H) / 2, -46.0), ind)
	# koyu alt bant
	Props.box(self, Vector3(13.8, 1.6, 0.04), Vector3(9.1, 0.8, -36.52), dark)
	Props.box(self, Vector3(13.8, 1.6, 0.04), Vector3(9.1, 0.8, -55.48), dark)
	Props.box(self, Vector3(0.04, 1.6, 4.0), Vector3(15.98, 0.8, -38.5), dark)
	Props.box(self, Vector3(0.04, 1.6, 4.0), Vector3(15.98, 0.8, -53.5), dark)
	# sütunlu sıra x=2,0 + lento
	for cz: float in [-38.5, -42.5, -46.5, -50.5, -54.5]:
		var col := Props.cyl(self, 0.3, 3.4, Vector3(2.0, 1.7, cz), Color("c8c0d8"), Vector3.ZERO, 12)
		Props.make_solid(col, 0.9)
		Props.cyl(self, 0.38, 0.12, Vector3(2.0, 3.34, cz), C_BRASS, Vector3.ZERO, 12)
	Props.box(self, Vector3(0.7, 0.3, 19.0), Vector3(2.0, 3.55, -46.0), Color("4a3a24"))
	# kaset tavan kirişleri
	for bx: float in [5.5, 9.0, 12.5]:
		Props.box(self, Vector3(0.35, 0.3, 19.0), Vector3(bx, 7.2, -46.0), Color("1c1e38"))
	for bz: float in [-39.5, -44.0, -48.5, -53.0]:
		Props.box(self, Vector3(14.0, 0.3, 0.35), Vector3(9.0, 7.2, bz), Color("1c1e38"))
	# BÜYÜK PENCERE
	_rc_win_mat = _rc_window_quad(self, Vector2(11.0, 4.8), Vector3(15.95, 3.4, -46.0), Vector3(0, -90, 0), 1.2)
	Props.box(self, Vector3(0.14, 0.14, 11.2), Vector3(15.9, 1.07, -46.0), C_WALNUT)
	Props.box(self, Vector3(0.14, 0.14, 11.2), Vector3(15.9, 5.73, -46.0), C_WALNUT)
	Props.box(self, Vector3(0.14, 4.8, 0.14), Vector3(15.9, 3.4, -40.57), C_WALNUT)
	Props.box(self, Vector3(0.14, 4.8, 0.14), Vector3(15.9, 3.4, -51.43), C_WALNUT)
	for mz: float in [-48.75, -46.0, -43.25]:
		Props.box(self, Vector3(0.08, 4.7, 0.1), Vector3(15.9, 3.4, mz), C_BRASS)
	Props.box(self, Vector3(0.08, 0.1, 11.0), Vector3(15.9, 3.4, -46.0), C_BRASS)
	Props.solid(self, Vector3(0.55, 0.45, 10.8), Vector3(15.7, 0.225, -46.0), C_WOOD_DARK)
	Props.box(self, Vector3(0.5, 0.1, 10.6), Vector3(15.7, 0.5, -46.0), C_RUG)
	_glow(self, Vector3(13.5, 0.03, -46.0), Vector2(6.0, 9.0), Color("9a8cff"), Vector3(-90, 0, 0), 0.25)
	_reg("bur_atriumwin", Vector3(0.5, 4.8, 11.0), Vector3(15.5, 3.4, -46.0), "UI_BUR_LOOK", _rc_atriumwin)
	# pencereye bakan bankolar
	for bz: float in [-43.2, -48.8]:
		Props.solid(self, Vector3(0.4, 0.42, 2.8), Vector3(11.8, 0.21, bz), C_WOOD_DARK)
		Props.box(self, Vector3(0.5, 0.07, 3.0), Vector3(11.8, 0.45, bz), C_WOOD)
		Props.box(self, Vector3(0.07, 0.5, 3.0), Vector3(11.55, 0.75, bz), C_WOOD)
	# ışıklar
	_bulb(Vector3(14.2, 3.8, -46.0), Color("9a8cff"), 2.2, 16.0)
	_bulb(Vector3(7.0, 2.8, -46.0), Color("ffb830"), 1.4, 8.0)
	_bulb(Vector3(9.0, 6.8, -46.0), Color("ffd890"), 1.3, 13.0)
	# Duvar aplikleri: pirinç kol + kehribar küre + duvara vuran sıcak hale (gerçek ışık yok)
	for ap in [[9.2, -36.55, 0.0], [5.0, -36.55, 0.0], [13.0, -36.55, 0.0], [9.2, -55.45, 180.0], [5.0, -55.45, 180.0], [13.0, -55.45, 180.0]]:
		var az: float = ap[1]
		var sg := 1.0 if az > -46.0 else -1.0
		Props.box(self, Vector3(0.06, 0.06, 0.22), Vector3(float(ap[0]), 3.0, az - sg * 0.1), C_BRASS)
		Props.ball(self, 0.12, Vector3(float(ap[0]), 3.12, az - sg * 0.24), Color("ffc860"), Vector3.ONE, 8, 1.6)
		_glow(self, Vector3(float(ap[0]), 3.1, az - sg * 0.03), Vector2(2.2, 2.2), Color("ffb040"), Vector3(0, float(ap[2]), 0), 0.35)
	# tavandan sarkan orrery / dişli düzeneği
	var gold := C_BRASS
	var gdark := Color("a07830")
	Props.cyl(self, 0.07, 2.5, Vector3(8.5, 6.25, -46.0), gold, Vector3.ZERO, 8)
	Props.cyl(self, 0.04, 1.9, Vector3(11.4, 6.55, -46.0), gold, Vector3.ZERO, 6)
	Props.cyl(self, 0.04, 2.3, Vector3(6.0, 6.35, -44.0), gold, Vector3.ZERO, 6)
	_rc_gear(Vector3(8.5, 5.0, -46.0), 1.9, 8, 0.12, gold, 0.12)
	_rc_gear(Vector3(11.4, 5.6, -46.0), 1.2, 6, 0.1, gdark, -0.2)
	_rc_gear(Vector3(6.0, 5.2, -44.0), 0.8, 5, 0.1, gold, 0.3)
	var rr1 := Node3D.new()
	rr1.position = Vector3(8.5, 5.0, -46.0)
	add_child(rr1)
	Props.ring(rr1, 2.25, 2.32, Vector3.ZERO, gold, Vector3(35, 0, 10))
	_spinners.append([rr1, Vector3(0.1, 1.0, 0.05).normalized(), 0.08])
	var rr2 := Node3D.new()
	rr2.position = Vector3(8.5, 5.0, -46.0)
	add_child(rr2)
	Props.ring(rr2, 1.55, 1.61, Vector3.ZERO, gdark, Vector3(-30, 0, -25))
	_spinners.append([rr2, Vector3(-0.1, 1.0, 0.08).normalized(), -0.14])
	Props.ball(self, 0.22, Vector3(8.5, 4.6, -46.0), Color("ffb830"), Vector3.ONE, 10, 1.5)
	# sarkaç: 6,4 m çubuk, 1 m altın top, periyot ~4 sn
	var pivot := Node3D.new()
	pivot.position = Vector3(12.0, 7.45, -38.5)
	add_child(pivot)
	_rc_pend = pivot
	Props.box(pivot, Vector3(0.4, 0.1, 0.4), Vector3(0, 0.02, 0), gold)
	Props.cyl(pivot, 0.025, 6.4, Vector3(0, -3.2, 0), gold, Vector3.ZERO, 6)
	Props.ball(pivot, 0.5, Vector3(0, -6.45, 0), Color("e0b030"), Vector3.ONE, 14, 0.5)
	pivot.rotation.z = -0.3
	var ptw := pivot.create_tween().set_loops()
	ptw.tween_property(pivot, "rotation:z", 0.3, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ptw.tween_property(pivot, "rotation:z", -0.3, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	Props.ring(self, 0.62, 0.68, Vector3(12.0, 0.02, -38.5), gold, Vector3.ZERO, 0.4)
	_lbl(self, "±0 sn", "±0 s", Vector3(12.0, 0.03, -37.6), 26, Color("e8d8a8"), Vector3(-90, 0, 0), 1.0)
	_reg("bur_pendulum", Vector3(3.0, 2.0, 1.4), Vector3(12.0, 1.2, -38.5), "UI_BUR_LOOK", _rc_pendulum)
	# zaman nehri maketi (bel hizasında masa)
	Props.solid(self, Vector3(3.0, 0.88, 9.0), Vector3(7.0, 0.44, -46.0), C_WOOD_DARK)
	Props.box(self, Vector3(3.3, 0.08, 9.3), Vector3(7.0, 0.92, -46.0), C_WALNUT)
	Props.box(self, Vector3(3.0, 0.02, 9.0), Vector3(7.0, 0.97, -46.0), dark)
	var amber := Color("ffb830")
	_rc_strip(Vector2(7.0, -50.2), Vector2(7.0, -46.2), 0.12, amber, 1.6)
	_rc_strip(Vector2(7.0, -46.2), Vector2(6.4, -42.2), 0.1, amber, 1.6)
	_rc_strip(Vector2(7.0, -46.2), Vector2(7.47, -44.78), 0.1, amber, 1.6)
	_rc_strip(Vector2(7.47, -44.78), Vector2(7.95, -43.4), 0.08, Color("7a5a20"), 0.4)
	_rc_strip(Vector2(7.0, -48.5), Vector2(6.2, -47.6), 0.06, Color("7a5a20"), 0.5)
	_rc_strip(Vector2(7.28, -44.72), Vector2(7.66, -44.84), 0.07, Color("c0262d"), 0.5)       # kırmızı bant
	Props.label(self, "1453", Vector3(8.1, 1.0, -45.4), 18, Color("ff6a2a"), Vector3(-90, 0, 0), 0.4)
	# minik simgeler: sütun, kubbe+minareler, roket, garaj
	var stone := Color("c8c0a8")
	Props.cyl(self, 0.025, 0.25, Vector3(6.3, 1.11, -49.0), stone, Vector3.ZERO, 8)
	Props.box(self, Vector3(0.1, 0.03, 0.1), Vector3(6.3, 0.995, -49.0), stone)
	Props.box(self, Vector3(0.28, 0.08, 0.28), Vector3(8.2, 1.02, -42.7), stone)
	Props.ball(self, 0.11, Vector3(8.2, 1.06, -42.7), Color("6a8aa8"), Vector3(1, 0.8, 1), 8)
	Props.cyl(self, 0.012, 0.3, Vector3(8.4, 1.16, -42.5), stone, Vector3.ZERO, 6)
	Props.cyl(self, 0.012, 0.3, Vector3(8.0, 1.16, -42.9), stone, Vector3.ZERO, 6)
	Props.cyl(self, 0.03, 0.22, Vector3(6.2, 1.1, -41.9), Color("e8e4dc"), Vector3.ZERO, 8)
	Props.cyl(self, 0.03, 0.08, Vector3(6.2, 1.25, -41.9), Color("c0262d"), Vector3.ZERO, 8, 0.003)
	Props.box(self, Vector3(0.2, 0.12, 0.16), Vector3(5.9, 1.04, -43.0), Color("7a8a84"))
	Props.box(self, Vector3(0.1, 0.08, 0.01), Vector3(6.0, 1.02, -42.91), Color("3a2218"))
	_reg("bur_timeline", Vector3(3.4, 0.5, 9.4), Vector3(7.0, 1.15, -46.0), "UI_BUR_LOOK", _rc_look.bind("bur_timeline", "BUR_TIMELINE", 2))


func _rc_atriumwin() -> void:
	_rc_look("bur_atriumwin", "BUR_ATRIUMWIN", 2)
	Audio.sfx("whoosh_fly", -20.0, 0.6)
	if _rc_win_mat == null:
		return
	_rc_win_mat.set_shader_parameter("focus_era", randi_range(0, 7))
	if _rc_win_tw and _rc_win_tw.is_valid():
		_rc_win_tw.kill()
	var t := 0.3 if GameState.autotest else 1.5
	_rc_win_tw = create_tween()
	_rc_win_tw.tween_method(_rc_set_focus, 0.0, 1.0, t)
	_rc_win_tw.tween_method(_rc_set_focus, 1.0, 0.0, t)


func _rc_set_focus(v: float) -> void:
	if _rc_win_mat:
		_rc_win_mat.set_shader_parameter("era_focus", v)


func _rc_pendulum() -> void:
	_rc_look("bur_pendulum", "BUR_PENDULUM", 2)
	Audio.sfx("timer_tick", -16.0, 0.7)
	if _count("bur_pendulum") >= 2:
		_second(4, Vector3(12.0, 1.6, -38.5))


# ---------------------------------------------------------------- koridor sonu: zamana açılan kemerli pencere (z -84)

func _rc_end_window() -> void:
	_rc_window_quad(self, Vector2(3.0, 2.0), Vector3(0, 1.7, -83.88), Vector3.ZERO, 1.4)
	# pirinç çerçeve
	Props.box(self, Vector3(3.2, 0.1, 0.1), Vector3(0, 0.72, -83.85), C_BRASS)
	Props.box(self, Vector3(0.1, 2.0, 0.1), Vector3(-1.55, 1.7, -83.85), C_BRASS)
	Props.box(self, Vector3(0.1, 2.0, 0.1), Vector3(1.55, 1.7, -83.85), C_BRASS)
	Props.box(self, Vector3(1.4, 0.08, 0.1), Vector3(0, 2.66, -83.85), C_BRASS)
	# üst köşeleri basamaklı duvar parçalarıyla yuvarlayarak kemer biçimi
	for sx: float in [-1.0, 1.0]:
		Props.box(self, Vector3(0.8, 0.15, 0.04), Vector3(sx * 1.1, 2.625, -83.86), C_COR_WALL)
		Props.box(self, Vector3(0.5, 0.2, 0.04), Vector3(sx * 1.25, 2.45, -83.86), C_COR_WALL)
		Props.box(self, Vector3(0.2, 0.25, 0.04), Vector3(sx * 1.4, 2.225, -83.86), C_COR_WALL)
	_glow(self, Vector3(0, 0.03, -82.6), Vector2(3.2, 3.5), Color("a8c8ff"), Vector3(-90, 0, 0), 0.25)


# ---------------------------------------------------------------- Bekleme salonunda tarihî figürler (v0.99.97)
## Ünlüler Büro'nun odalarına dağılmış, her biri orada bir işte: bekleme salonunda Napolyon sandalyeye çıkmış, Cengiz Han
## numaratörü kolluyor, Hitler köşede yüzü duvara oturtulmuş; Sezar ile Shakespeare çay ocağında, Kolomb Kayıp Zaman
## Bürosu'nda, Kleopatra şikâyet masasında, Einstein sarkacın, Leonardo zaman nehri maketinin başında. Her biri isim
## kartı takar (Büro'nun kuralı); konuşulunca oyuncuya döner; yan yana olanlar laf yetiştirir.

var _fg: Dictionary = {}          # kimlik → Person
var _fg_yaw: Dictionary = {}      # kimlik → asıl bakış (derece)
var _fg_busy := false

## [kimlik, konuşan, konum, bakış, görünüş, isim TR, isim EN]
const _FG := [
	["nap", "SPK_NAPOLEON", Vector3(-4.6, 0.48, -6.8), 90.0, {"coat": Color("24365e"), "pants": Color("efe9dc"), "hat": "bicorne", "hair": Color("2a2018"), "hair_style": "short", "skin": Color("e8c0a0")}, "NAPOLYON", "NAPOLEON"],
	["cle", "SPK_CLEOPATRA", Vector3(-1.72, 0, -28.7), -60.0, {"coat": Color("efe6d0"), "pants": Color("efe6d0"), "skirt": true, "hat": "uraeus", "hair": Color("121010"), "hair_style": "long", "skin": Color("c98e6a")}, "KLEOPATRA", "CLEOPATRA"],
	["cae", "SPK_CAESAR", Vector3(2.55, 0, -3.95), -158.0, {"coat": Color("efe9dc"), "pants": Color("efe9dc"), "robe": Color("efe9dc"), "hat": "laurel", "hair": Color("8a8478"), "hair_style": "receding", "skin": Color("e0a882")}, "SEZAR", "CAESAR"],
	["leo", "SPK_LEONARDO", Vector3(9.1, 0, -45.5), -90.0, {"coat": Color("5a2030"), "pants": Color("3a1a20"), "robe": Color("5a2030"), "hat": "soft_beret", "hair": Color("e6e2da"), "hair_style": "long", "beard": true, "mustache": true, "skin": Color("e8b894")}, "LEONARDO", "LEONARDO"],
	["ein", "SPK_EINSTEIN", Vector3(11.0, 0, -40.0), -45.0, {"coat": Color("7a7468"), "pants": Color("4a4a48"), "hair": Color("f2f0ea"), "hair_style": "curly", "mustache": true, "face": {"mustache": "walrus", "bags": true, "wrinkles": true}, "skin": Color("ecc0a0")}, "EINSTEIN", "EINSTEIN"],
	["hit", "SPK_HITLER", Vector3(-7.55, 0, -4.65), -45.0, {"coat": Color("5a5040"), "pants": Color("3a3630"), "hair": Color("2a2018"), "hair_style": "swept", "mustache": true, "face": {"mustache": "toothbrush", "brow_tilt": 10.0}, "skin": Color("e8c0a0")}, "HITLER", "HITLER"],
	["gen", "SPK_GENGHIS", Vector3(-3.4, 0, -5.45), 41.0, {"coat": Color("7a3a22"), "pants": Color("3a2a1a"), "hat": "mongol", "hair": Color("1a1410"), "mustache": true, "beard": true, "face": {"mustache": "chevron", "beard": "goatee"}, "skin": Color("d9a07a")}, "CENGİZ HAN", "GENGHIS KHAN"],
	["col", "SPK_COLUMBUS", Vector3(5.6, 0, -20.1), -105.0, {"coat": Color("2a4a3a"), "pants": Color("3a3a30"), "hat": "berretta", "hair": Color("d8d4c8"), "hair_style": "long", "skin": Color("e8b894")}, "KOLOMB", "COLUMBUS"],
	["sul", "SPK_SULEYMAN", Vector3(1.62, 0, -33.0), 60.0, {"coat": Color("2f6a4a"), "pants": Color("3a2a1a"), "robe": Color("c9a24a"), "hat": "sultan", "beard": true, "mustache": true, "hair": Color("3a2a1e"), "skin": Color("e0b08a"), "face": {"beard": "full", "nose": "hook"}}, "SÜLEYMAN", "SULEIMAN"],
	["gui", "SPK_GUIDE", Vector3(8.5, 0, -52.3), -30.0, {"coat": Color("c8ccd4"), "pants": Color("2a8a8a"), "skirt": true, "hair": Color("d84a8a"), "hair_style": "short", "skin": Color("e0a882")}, "REHBER", "GUIDE"],
	["rob", "SPK_ROBOT", Vector3(-7.95, 0, -6.0), -120.0, {"coat": Color("9aa4ae"), "pants": Color("7a848e"), "hat": "robot", "hair": Color("8a949e"), "skin": Color("b8c2cc")}, "STAJYER", "INTERN"],
	["arc", "SPK_ARCHAEOLOGIST", Vector3(-5.2, 0, -20.6), -100.0, {"coat": Color("b89a6a"), "pants": Color("5a4a3a"), "hat": "fedora", "glasses": true, "hair": Color("3a2a1e"), "skin": Color("c98e6a")}, "ARKEOLOG", "ARCHAEOLOGIST"],
	["shk", "SPK_SHAKESPEARE", Vector3(2.55, 0, -5.35), -22.0, {"coat": Color("1e1e22"), "pants": Color("1e1e22"), "hair": Color("6a4a30"), "hair_style": "receding", "mustache": true, "beard": true, "face": {"mustache": "pencil", "beard": "goatee"}, "skin": Color("ecc0a0")}, "SHAKESPEARE", "SHAKESPEARE"],
]


func _fg_build() -> void:
	var gold := Color("d4a640")
	for f in _FG:
		var id: String = f[0]
		var p := Person.new(f[4])
		p.set_meta("spk", f[1])
		p.set_meta("no_talk", true)
		p.set_meta("no_unclip", true)      # sandalyenin üstündeki Napolyon zemine indirilmesin
		add_child(p)
		p.position = f[2]
		p.rotation_degrees.y = f[3]
		_fg[id] = p
		_fg_yaw[id] = f[3]
		var hd := p._head
		match id:
			"hit":     # köşede tek sandalye, yüzü duvara
				var ch := Node3D.new()
				ch.position = f[2]
				ch.rotation_degrees.y = f[3]
				add_child(ch)
				Props.box(ch, Vector3(0.42, 0.05, 0.42), Vector3(0, 0.45, 0), C_WOOD)
				Props.box(ch, Vector3(0.42, 0.45, 0.05), Vector3(0, 0.7, -0.2), C_WOOD_DARK)
				for lx: float in [-0.18, 0.18]:
					for lz: float in [-0.18, 0.18]:
						Props.box(ch, Vector3(0.04, 0.43, 0.04), Vector3(lx, 0.215, lz), C_WOOD_DARK)
				p.set_activity("sit")
			"cae", "shk":     # çay ocağının tezgâhında ince belli bardak
				var g: Vector3 = f[2] + Vector3(0.62, 1.1, -0.1 if id == "cae" else 0.1)
				Props.cyl(self, 0.03, 0.09, g, Color("a8381c"), Vector3.ZERO, 8, 0.036)
				Props.cyl(self, 0.045, 0.006, g - Vector3(0, 0.048, 0), Color("e8e4dc"), Vector3.ZERO, 10)
			"gui":     # sopanın ucunda tur bayrağı (2187)
				Props.cyl(p, 0.012, 1.5, Vector3(0.3, 1.25, 0.12), C_METAL, Vector3.ZERO, 6)
				Props.box(p, Vector3(0.02, 0.24, 0.36), Vector3(0.3, 1.88, 0.3), Color("ff6a2a"), Vector3.ZERO, 0.6)
			"arc":     # elinde fırça
				Props.cyl(p, 0.012, 0.22, Vector3(0.3, 0.86, 0.16), C_WOOD, Vector3(40, 0, 0), 6)
				Props.box(p, Vector3(0.05, 0.06, 0.03), Vector3(0.3, 0.95, 0.25), Color("e8d8b0"), Vector3(40, 0, 0))
			"cle":     # altın gerdanlık (taç bandı: Person "uraeus")
				Props.cyl(p, 0.2, 0.03, Vector3(0, 1.4, 0.0), gold, Vector3.ZERO, 12)
			"cae":     # omuzdan kırmızı kuşak (defne: Person "laurel")
				Props.box(p, Vector3(0.08, 0.7, 0.36), Vector3(0.0, 1.1, 0.0), Color("9a1f24"), Vector3(0, 90, 32))
			"ein":     # dağınık beyaz saç
				for q in [Vector3(-0.19, 0.09, -0.04), Vector3(0.19, 0.09, -0.04), Vector3(-0.12, 0.17, -0.1), Vector3(0.12, 0.17, -0.1), Vector3(0, 0.2, -0.05), Vector3(0, 0.1, -0.19)]:
					Props.ball(hd, 0.085, q, Color("f2f0ea"), Vector3(1.0, 0.8, 1.0), 8)
			"shk":     # kırma yaka (fırfır), altın küpe
				Props.cyl(p, 0.24, 0.07, Vector3(0, 1.38, 0.0), Color("f4f2ec"), Vector3.ZERO, 14)
				Props.ball(hd, 0.014, Vector3(0.2, -0.06, 0.0), gold, Vector3.ONE, 6)
		# İsim kartı (göğüste, sol): Büro herkese takar
		Props.box(p, Vector3(0.17, 0.11, 0.008), Vector3(-0.09, 1.2, 0.2), Color("f6f2e6"))
		Props.box(p, Vector3(0.17, 0.028, 0.009), Vector3(-0.09, 1.245, 0.2), Color("b8323a"))
		_lbl(p, f[5], f[6], Vector3(-0.09, 1.19, 0.206), 7, Color("1a1a1a"))
		_reg("bur_fg_" + id, Vector3(0.7, 1.8, 0.7), f[2] + Vector3(0, 0.9, 0), "UI_PROMPT3_TALK", _fg_talk.bind(id), null, false)
		_prompt_args["bur_fg_" + id] = f[1]
		# Uzaktan çizilmez: yalnız bekleme salonundan ve koridorun başından görünürler
		var st: Array = [p]
		while st.size() > 0:
			var n: Node = st.pop_back()
			st.append_array(n.get_children())
			if n is GeometryInstance3D:
				(n as GeometryInstance3D).visibility_range_end = 24.0
	# Hitler sıranın sonunda, herkesten bir adım uzakta; arkasındaki duvarda kırmızı "RED" damgalı başvurusu asılı
	var form := Props.box(self, Vector3(0.006, 0.3, 0.22), Vector3(-8.47, 1.5, -4.2), C_PAPER, Vector3(0, 0, 4))
	_lbl(form, "RED", "REJECTED", Vector3(0.006, 0.0, 0.0), 22, Color("b8323a"), Vector3(0, 90, 10), 0.2)


## Konuşulan figür oyuncuya döner, birkaç saniye sonra yine sıraya bakar
func _fg_face(id: String, secs: float) -> void:
	var p: Person = _fg.get(id)
	if not is_instance_valid(p) or player == null:
		return
	p.look_target = player
	p.talking = true
	get_tree().create_timer(secs).timeout.connect(_fg_unface.bind(id))


func _fg_unface(id: String) -> void:
	var p: Person = _fg.get(id)
	if not is_instance_valid(p):
		return
	p.look_target = null
	p.talking = false
	var tw := p.create_tween()
	tw.tween_property(p, "rotation:y", deg_to_rad(float(_fg_yaw[id])), 0.6).set_trans(Tween.TRANS_SINE)


## Sırayla söylenen kısa sahne: [[kimlik, anahtar, süre], ...]
func _fg_seq(lines: Array) -> void:
	_fg_busy = true
	for l in lines:
		var id: String = l[0]
		var secs: float = l[2]
		if not is_inside_tree():
			return
		_say(l[1], secs, _fg_spk(id))
		_fg_face(id, secs + 0.4)
		if l.size() > 3 and _fg.has(l[3]):
			(_fg[id] as Person).look_target = _fg[l[3]]       # atışmada karşısındakine döner
		await get_tree().create_timer(secs + 0.2).timeout
	_fg_busy = false


func _fg_spk(id: String) -> String:
	for f in _FG:
		if f[0] == id:
			return f[1]
	return bark_speaker


## Büro'ya üç ayrı zamanda gelinir: Bölüm 3 (ilk gün), 13-14 (kuşatmadan dönüş), 15 ve sonrası (17, 26, 27, final).
## Figür önce o ziyaretin repliklerini söyler (yenisi önce), sonra eskileri; aynı replik art arda gelmez.
func _fg_tier() -> int:
	var c := GameState.current_chapter
	return 1 if c <= 12 else (2 if c <= 14 else 3)


## İlk ziyaretin listesi: "@" = atışma (Napolyon ile Hitler, Sezar ile Shakespeare)
const _FG_T1 := {"nap": ["BUR_FG_NAP_1", "@", "BUR_FG_NAP_2"], "hit": ["BUR_FG_HIT_1", "@"],
	"cae": ["BUR_FG_CAE_1", "@", "BUR_FG_CAE_2"], "shk": ["BUR_FG_SHK_1", "@", "BUR_FG_SHK_2"]}


func _fg_lines(id: String) -> Array:
	var up := id.to_upper()
	var t1: Array = _FG_T1.get(id, [])
	if t1.is_empty():
		for i in range(1, 4):
			var k := "BUR_FG_%s_%d" % [up, i]
			if tr(k) != k:
				t1.append(k)
	var out: Array = []
	for t in range(_fg_tier(), 1, -1):
		for i in range(1, 3):
			out.append("BUR_FG_%s_V%d_%d" % [up, t, i])
	return out + t1


func _fg_talk(id: String) -> void:
	if _fg_busy:
		return
	var n := _count("bur_fg_" + id) + 1
	_cycles["bur_fg_" + id] = n
	var lines := _fg_lines(id)
	var item: String = lines[(n - 1) % lines.size()]
	if item != "@":
		_fg_seq([[id, item, 5.5]])
	elif id == "nap":
		_fg_seq([["nap", "BUR_FG_NAP_3", 5.0, "hit"], ["hit", "BUR_FG_HIT_R", 2.0, "nap"], ["nap", "BUR_FG_NAP_4", 1.6, "hit"]])
	elif id == "hit":
		_fg_seq([["hit", "BUR_FG_HIT_2", 4.0], ["nap", "BUR_FG_NAP_3", 5.0, "hit"], ["hit", "BUR_FG_HIT_R", 2.0, "nap"], ["nap", "BUR_FG_NAP_4", 1.6, "hit"]])
	else:
		_fg_seq([["cae", "BUR_FG_CAE_3", 5.5, "shk"], ["shk", "BUR_FG_SHK_R", 4.5, "cae"]])