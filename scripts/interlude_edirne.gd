class_name EdirneInterlude
extends Node
## Ara bölüm "ARIZA · Edirne Sarayı, 1444 yazı" (v0.99.6; docs/SIEGE.md §Edirne arızası). Bölüm 17'nin Büro önsözünde,
## sözleşme ve kameradan sonra, taraf seçiminden önce: Büro'dan geçen her oyun bir kez görür.
##   0 Kalibrasyon: Nihat makineyi kameraya alıştırmak için beş dakikalık bir atlama ister. Asansörde kadran 1453'e
##     kurulur; çantada leblebi varsa biri kadranın dişlisine kaçar, yoksa Tolga'nın telefonu çalar (annesi). Kadran
##     1444'e kayar: kırmızı arıza girdabı.
##   1 Havuz: Tolga sarayın havuzuna düşer. Çınarın altında İskendernâme okuyan on iki yaşındaki Mehmed kaçmaz:
##     "Sen Hızır mısın?" (edirne_who: hizir / time / greek). Halil Paşa divana çağırır: tahtta çocuk, işi yürüten vezir.
##   2 Ders: Molla Gürânî ve II. Murad'ın verdiği değnek (rivayet); "âlem kadîm mi, hâdis mi?"; Tolga'ya "Dünya nasıldır?"
##     (edirne_answer: round / flat: değnek, eğilme QTE'si / dunno: "Bilmiyorum demek ilmin yarısıdır")
##   3 İskender ve Kayser: kütüphane köşkü; ilk Kayser (edirne_caesar: veni / salad / brutus: o an Halil girer),
##     defterde surlu şehir; gelecek (edirne_future: told / book / silent); çantada küp ya da selfie çubuğu varsa
##   4 Rehine prensler: Vlad sopa sivriltir, Radu neşeli; tarihi değiştiren seçim (edirne_vlad: kebab / policy /
##     legend / none)
##   5 Kaçış: Halil'in muhafızları; havuza (yakalanan da havuza atılır). Nihat geri çeker; Mehmed: "Kostantiniyye'de
##     görüşürüz!"
##   6 Büro: asansör açılır; ofisteki Vikipedi ekranında değişiklik farkı; Nihat: "Bu oyunun adı 'Gerçek Tarih Bu
##     Değil'… Ne yaptın sen?!"; düzeltme damgası, dipnot kalır.
## İzleri: 33o ve 26 (Fatih tanır), 14 (sicil), 15 (İnsanların Akıbeti), 12 (sonraki oyunlarda).
## Otomatik test (Bölüm 17 varyantı → seçimler):
##   "" (varsayılan)   hizir, dunno, veni, told, kebab
##   osm              time, round, brutus, silent, none
##   edirne_policy    greek, flat (eğilir), salad, told, policy
##   edirne_legend    hizir, flat (yer), brutus, book, legend   (--bag=phone,book,selfie)
##   edirne_none      time, dunno, veni, silent, none

const ORIGIN := Vector3(3000.0, 0.0, 0.0)
const PICKS := {
	"": {"who": "hizir", "answer": "dunno", "caesar": "veni", "future": "told", "vlad": "kebab"},
	"osm": {"who": "time", "answer": "round", "caesar": "brutus", "future": "silent", "vlad": "none"},
	"edirne_policy": {"who": "greek", "answer": "flat", "caesar": "salad", "future": "told", "vlad": "policy"},
	"edirne_legend": {"who": "hizir", "answer": "flat", "caesar": "brutus", "future": "book", "vlad": "legend"},
	"edirne_none": {"who": "time", "answer": "dunno", "caesar": "veni", "future": "silent", "vlad": "none"},
}
const WHO := ["hizir", "time", "greek"]
## Ofiste Vikipedi ekranının önü (ekran sol duvarda, x -2.9)
const BOARD_VIEW := Vector3(-1.3, 0.0, 1.2)

var host: Node3D
var hud: Hud
var player: Player
var bureau: Bureau
var nihat: Person
var board: Node3D
var palace: EdirnePalace
var mehmed: Person
var gurani: Person
var vlad: Person
var radu: Person
var halil: Person
var guards: Array[Person] = []
var _bureau_env: Environment
var _picks: Dictionary = {}


func run(h: Node3D, hd: Hud, pl: Player, bu: Bureau, ni: Person, bo: Node3D) -> void:
	host = h
	hud = hd
	player = pl
	bureau = bu
	nihat = ni
	board = bo
	host.add_child(self)
	_picks = PICKS.get(GameState.autotest_variant, PICKS[""])
	hud.set_objective("")
	await _calibration()
	await _arrive()
	await _lesson()
	await _library()
	await _hostages()
	await _escape()
	await _aftermath()
	# Sonraki oyunlarda Bölüm 12'de Fatih bir an durur (oyunlar arasında kalır)
	GameState.bump_stat("edirne_seen", 1, true)
	queue_free()


# ================================================================ yardımcılar

func _wait(s: float) -> void:
	await get_tree().create_timer(s).timeout


func _p(local: Vector3) -> Vector3:
	return palace.to_global(local)


func _pick(kind: String) -> String:
	return String(_picks.get(kind, ""))


## Seçim: anahtarlar ve kimlikleri sırayla; otomatik testte varyantın kimliği seçilir.
func _choose(keys: Array, ids: Array, kind: String) -> String:
	var want := ids.find(_pick(kind))
	var c := await hud.choose(keys, 0.0, maxi(want, 0))
	return String(ids[clampi(c, 0, ids.size() - 1)])


## Ekranın ortasında kırmızı "[kaynak belirtilmeli]" damgası (rivayet, ya da Tolga tarihe salata soktu).
func _cn() -> void:
	Audio.sfx("stamp", -6.0, 1.3)
	var l := Label.new()
	l.text = tr("PROP17_WIKI_CN")
	l.add_theme_font_size_override("font_size", 34)
	l.add_theme_color_override("font_color", Color("e0302a"))
	l.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.9))
	l.add_theme_constant_override("outline_size", 8)
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	l.position.y += 150.0
	l.rotation = -0.06
	hud.add_child(l)
	var tw := l.create_tween()
	tw.tween_interval(0.4 if GameState.autotest else 1.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)


func _person(look: Dictionary, spk: String, at: Vector3, face: Vector3) -> Person:
	var p := Person.new(look)
	if spk != "":
		p.set_meta("spk", spk)
	else:
		p.set_meta("no_talk", true)
	p.set_meta("no_chat", true)
	palace.add_child(p)
	p.position = at
	p.face_toward(_p(face))
	return p


## Biri bir yere yürür (Walker), oyuncu ardından gelir. Otomatik testte ikisi de yerine konur. Oyuncu gelmezse
## (25 sn) yerine konur: sahne beklemesin.
func _go_together(who: Person, to: Vector3, player_to: Vector3, obj_key: String) -> void:
	if GameState.autotest:
		who.position = to
		player.global_position = _p(player_to) + Vector3(0, 0.05, 0)
		await _wait(0.1)
		return
	var w := Walker.go(who, _p(to), 1.4)
	player.frozen = false
	hud.set_objective(tr(obj_key), _p(player_to) + Vector3(0, 1.0, 0))
	var t := 0.0
	while player.global_position.distance_to(_p(player_to)) > 2.2 and t < 25.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	hud.set_objective("")
	player.frozen = true
	if is_instance_valid(w):
		await w.arrived
	who.position = to
	if player.global_position.distance_to(_p(player_to)) > 2.2:
		await hud.fade_to(1.0, 0.3)
		player.global_position = _p(player_to) + Vector3(0, 0.05, 0)
		await hud.fade_to(0.0, 0.3)


func _look(at: Node3D) -> void:
	if at:
		player.face(at.global_position + Vector3(0, 1.25 * at.scale.y if at is Person and (at as Person).child else 1.5, 0))


# ================================================================ 0 kalibrasyon

func _calibration() -> void:
	await hud.say("SPK_NIHAT", "D17E_N_CAL_1")
	await hud.say("SPK_TOLGA", "D17E_T_CAL_1")
	await bureau.lift_board(player, hud, nihat, "D17E_N_LIFT_1")
	await bureau.lift_spin("1453", 1.2, nihat)
	if GameState.has_item("chickpeas"):
		await hud.say("SPK_TOLGA", "D17E_T_LEB")
		Audio.sfx("timer_tick", -2.0, 1.7)
		bureau.panel_wheel.rotation.x += 1.4
		await hud.say("SPK_NIHAT", "D17E_N_LEB")
	else:
		for k in 2:
			Audio.sfx("radio_beep", -4.0, 1.5)
			await _wait(0.3)
		await hud.say("SPK_TOLGA", "D17E_T_PHONE")
		await hud.say("SPK_NIHAT", "D17E_N_PHONE")
	# Kadran kayar: 1453 → 1444
	for y in ["1452", "1450", "1449", "1447", "1446", "1444"]:
		bureau.set_dial(y)
		bureau.panel_wheel.rotation.x -= 0.6
		Audio.sfx("timer_tick", -6.0, 0.7)
		await _wait(0.16)
	hud.bark("SPK_NIHAT", "D17E_N_NO", 3.0)
	await bureau.lift_close(player)
	await bureau.lift_go(hud, "1453", "1444", true, tr("D17E_CAP_GLITCH"), 3.0)


# ================================================================ 1 havuz

func _enter_palace() -> void:
	palace = EdirnePalace.new()
	palace.position = ORIGIN
	host.add_child(palace)
	# Tek WorldEnvironment kalsın: Büro'nun ortamı 1444 yazıyla değişir (Büro gizlenir, sahnede kalır)
	_bureau_env = bureau.env_node.environment
	bureau.env_node.environment = EdirnePalace.make_env()
	bureau.visible = false
	Audio.voice_space("outdoor")
	Audio.ambience("amb_city_day")
	Audio.music("tender")
	mehmed = _person({"face": "fatih", "child": true, "coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "turban",
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")}, "SPK_SEHZADE",
		EdirnePalace.READ_SPOT, EdirnePalace.POOL)
	mehmed.set_activity("sit_ground")
	mehmed.hold_item(Items.open_book(), true)
	gurani = _person({"face": {"nose": "long", "nose_s": 1.1, "eye_s": 0.85, "lid": 0.35, "brow": 1.5, "brow_tilt": 10.0,
		"wrinkles": true, "beard": "full", "mustache": "walrus", "head": Vector3(1.0, 1.1, 1.0)}, "coat": Color("2e2a36"),
		"pants": Color("23202a"), "hat": "turban", "robe": Color("3a3442"), "beard": true, "mustache": true,
		"hair": Color("4a4038"), "skin": Color("c8946a")}, "SPK_GURANI", EdirnePalace.HOCA_SPOT,
		EdirnePalace.HOCA_SPOT + Vector3(0, 0, -3))
	gurani.set_activity("sit_ground")
	vlad = _person({"face": {"nose": "long", "nose_s": 1.2, "eye_s": 1.2, "eye_gap": 0.36, "brow": 1.6, "brow_tilt": 20.0,
		"head": Vector3(0.95, 1.12, 0.98), "blush": false}, "child": true, "coat": Color("5a1820"), "pants": Color("2a2026"),
		"hat": "kalpak", "hair": Color("1a1412"), "hair_style": "long", "skin": Color("e6c0a0")}, "SPK_VLAD",
		EdirnePalace.VLAD_SPOT, EdirnePalace.LOG)
	vlad.scale = Vector3.ONE * 1.12
	vlad.set_activity("chop")         # kütüğün başında sopa yontar
	radu = _person({"face": {"nose": "button", "eye_s": 1.3, "brow_tilt": -12.0, "blush": true, "mouth_w": 1.2},
		"child": true, "coat": Color("3a6a9a"), "pants": Color("2a3040"), "hat": "kalpak", "hair": Color("6a4a2a"), "hair_style": "curly",
		"skin": Color("f0caa8")}, "SPK_RADU", EdirnePalace.RADU_SPOT, EdirnePalace.POOL)
	radu.scale = Vector3.ONE * 0.86   # yedi yaşında: ağabeyinden ve şehzadeden küçük
	# Halil Paşa kapıda: divana çağırır, sonra çekilir (kütüphanede ve kaçışta yeniden gelir)
	halil = _person({"face": "candarli", "coat": Color("3a4a3a"), "pants": Color("2a2a24"), "hat": "vizier", "beard": true,
		"mustache": true, "hair": Color("6a6a6a"), "robe": Color("3a4a3a"), "skin": Color("d9a07a")}, "SPK_HALIL",
		EdirnePalace.GATE + Vector3(0, 0, 2.2), EdirnePalace.POOL)
	# Kapının iki yanında nöbetçiler (kovalamacada Halil'in muhafızları olur)
	for s in [-1.0, 1.0]:
		var g := _person({"coat": Color("b3262d"), "pants": Color("3a2a20"), "hat": "bork", "mustache": true, "skin": Color("d8a888")},
			"", EdirnePalace.GATE + Vector3(s * 2.4, 0, 1.2), EdirnePalace.POOL)
		g.equip("spear")
		guards.append(g)


func _arrive() -> void:
	_enter_palace()
	# Çarpışmalar bir sonraki fizik karesinde gelir: önce bekle, sonra havuzun üstüne
	await get_tree().physics_frame
	await get_tree().physics_frame
	player.global_position = _p(Vector3(-1.9, 2.4, -1.0))
	player.face(_p(EdirnePalace.READ_SPOT) + Vector3(0, 0.8, 0))
	hud.cover_override = "ch17e"
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH17E_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH17E_SUB"), 20, Color(1, 1, 1, 0.75)]], 2.8)
	hud.clear_card()
	hud.cover_override = ""
	await hud.fade_to(0.0, 0.4, Color.WHITE)
	var t := 0.0
	while not player.is_on_floor() and t < 1.5:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	Audio.sfx("splash", 0.0)
	Vfx.splash(palace, Vector3(-1.9, EdirnePalace.WATER_Y, -1.0), 1.6)
	player.shake(0.5)
	await _wait(0.6)
	await hud.say("SPK_TOLGA", "D17E_T_SPLASH")
	_look(mehmed)
	mehmed.look_target = player
	await hud.say("SPK_SEHZADE", "D17E_M_01")
	await hud.say("SPK_SEHZADE", "D17E_M_02")
	var who := await _choose(["UI_C17E_WHO_HIZIR", "UI_C17E_WHO_TIME", "UI_C17E_WHO_GREEK"], WHO, "who")
	GameState.flags["edirne_who"] = who
	match who:
		"hizir":
			await hud.say("SPK_TOLGA", "D17E_T_HIZIR")
			await hud.say("SPK_SEHZADE", "D17E_M_HIZIR")
		"time":
			await hud.say("SPK_TOLGA", "D17E_T_TIME")
			await hud.say("SPK_SEHZADE", "D17E_M_TIME")
			await hud.say("SPK_TOLGA", "D17E_T_TIME_2")
			mehmed.emote("nod")
			await hud.say("SPK_SEHZADE", "D17E_M_TIME_2")
		_:
			await hud.say("SPK_TOLGA", "D17E_T_GREEK")
			await hud.say("SPK_SEHZADE", "D17E_M_GREEK")
			await hud.say("SPK_TOLGA", "D17E_T_GREEK_2")
			mehmed.emote("laugh")
			await hud.say("SPK_SEHZADE", "D17E_M_GREEK_2")
	# Kapıdan Halil Paşa: tahtta çocuk, divanı yürüten vezir
	halil.look_target = mehmed
	await hud.say("SPK_HALIL", "D17E_H_DIVAN")
	await hud.say("SPK_SEHZADE", "D17E_M_DIVAN")
	halil.look_target = null
	halil.leave(_p(EdirnePalace.POOL), 1.2, 1.2, true)
	await hud.say("SPK_TOLGA", "D17E_T_SULTAN")
	await hud.say("SPK_SEHZADE", "D17E_M_COME")
	mehmed.release_item()
	mehmed.set_activity("")
	mehmed.look_target = null
	await _wait(0.4)
	await _go_together(mehmed, EdirnePalace.MEHMED_DERS, EdirnePalace.TOLGA_DERS, "UI_OBJ17E_FOLLOW")


# ================================================================ 2 ders

func _lesson() -> void:
	mehmed.set_activity("sit_ground")
	mehmed.face_toward(gurani.global_position)
	player.face(gurani.global_position + Vector3(0, 1.0, 0))
	gurani.look_target = player
	# Hocanın değneği: duvardan eline
	palace.rod.visible = false
	gurani.equip("rod")
	await hud.say("SPK_SEHZADE", "D17E_M_ROD")
	await hud.say("SPK_TOLGA", "D17E_T_ROD")
	await hud.say("SPK_SEHZADE", "D17E_M_ROD_2")
	_cn()
	await hud.say("SPK_GURANI", "D17E_G_01")
	await hud.say("SPK_TOLGA", "D17E_T_GUR")
	await hud.say("SPK_GURANI", "D17E_G_02")
	await hud.say("SPK_SEHZADE", "D17E_M_03")
	await hud.say("SPK_GURANI", "D17E_G_03")
	await hud.say("SPK_TOLGA", "D17E_T_HOW")
	await hud.say("SPK_GURANI", "D17E_G_04")
	var ans := await _choose(["UI_C17E_ANS_ROUND", "UI_C17E_ANS_FLAT", "UI_C17E_ANS_DUNNO"], ["round", "flat", "dunno"], "answer")
	GameState.flags["edirne_answer"] = ans
	match ans:
		"round":
			await hud.say("SPK_TOLGA", "D17E_T_ROUND")
			await hud.say("SPK_GURANI", "D17E_G_ROUND")
			await hud.say("SPK_SEHZADE", "D17E_M_ROUND")
			await hud.say("SPK_GURANI", "D17E_G_ROUND_2")
		"flat":
			await hud.say("SPK_TOLGA", "D17E_T_FLAT")
			mehmed.emote("laugh")
			await hud.say("SPK_SEHZADE", "D17E_M_FLAT")
			await hud.say("SPK_GURANI", "D17E_G_FLAT")
			await hud.say("SPK_TOLGA", "D17E_T_FLAT_2")
			if await _rod_qte():
				await hud.say("SPK_GURANI", "D17E_G_DODGE")
			else:
				await hud.say("SPK_TOLGA", "D17E_T_HIT")
		_:
			await hud.say("SPK_TOLGA", "D17E_T_DUNNO")
			await hud.say("SPK_GURANI", "D17E_G_DUNNO")
			mehmed.emote("nod")
			await hud.say("SPK_SEHZADE", "D17E_M_DUNNO")
	await hud.say("SPK_GURANI", "D17E_G_END")
	gurani.look_target = null
	mehmed.set_activity("")
	await _wait(0.3)
	await _go_together(mehmed, EdirnePalace.MEHMED_LIB, EdirnePalace.TOLGA_LIB, "UI_OBJ17E_FOLLOW")


## Değnek iner: Ctrl (ya da boşluk) ile eğil. Döner: eğildi mi.
func _rod_qte() -> bool:
	hud.set_qte(tr("UI_QTE17E_ROD"))
	gurani.emote("surprise")
	var ok := false
	if GameState.autotest:
		await _wait(0.2)
		ok = GameState.autotest_variant == "edirne_policy"
	else:
		var t := 0.0
		while t < 1.1:
			await get_tree().process_frame
			t += get_process_delta_time()
			hud.set_red_progress(t / 1.1)
			if Input.is_action_just_pressed("dive") or Input.is_action_just_pressed("jump"):
				ok = true
				break
	hud.set_red_progress(0.0)
	hud.set_qte("")
	Audio.sfx("chop" if not ok else "cloth", -4.0, 1.4)
	if ok:
		player.shake(0.15)
	else:
		player.shake(0.6)
		Vfx.stars(palace, palace.to_local(player.global_position) + Vector3(0, 1.7, 0))
	return ok


# ================================================================ 3 İskender ve Kayser

func _library() -> void:
	mehmed.face_toward(player.global_position)
	mehmed.look_target = player
	player.face(mehmed.global_position + Vector3(0, 1.1, 0))
	var book := Items.open_book()
	mehmed.hold_item(book, true)
	await hud.say("SPK_SEHZADE", "D17E_M_ISK")
	await hud.say("SPK_TOLGA", "D17E_T_ISK")
	await hud.say("SPK_SEHZADE", "D17E_M_ISK_2")
	await hud.say("SPK_SEHZADE", "D17E_M_KAYSER")
	var cae := await _choose(["UI_C17E_CAE_VENI", "UI_C17E_CAE_SALAD", "UI_C17E_CAE_BRUTUS"], ["veni", "salad", "brutus"], "caesar")
	GameState.flags["edirne_caesar"] = cae
	match cae:
		"veni":
			await hud.say("SPK_TOLGA", "D17E_T_VENI")
			await hud.say("SPK_SEHZADE", "D17E_M_VENI")
		"salad":
			await hud.say("SPK_TOLGA", "D17E_T_SALAD")
			await hud.say("SPK_SEHZADE", "D17E_M_SALAD")
			_cn()
			hud.bark("SPK_NIHAT", "D17E_N_SALAD", 3.0)
			await _wait(1.2)
		_:
			await hud.say("SPK_TOLGA", "D17E_T_BRUTUS")
			# O an Halil Paşa köşkün önüne gelir
			halil.position = EdirnePalace.LIB + Vector3(-4.2, 0, -1.6)
			halil.face_toward(mehmed.global_position)
			halil.visible = true
			await hud.say("SPK_HALIL", "D17E_H_LIB")
			mehmed.look_target = halil
			await _wait(0.8)
			await hud.say("SPK_SEHZADE", "D17E_M_BRUTUS")
			await hud.say("SPK_HALIL", "D17E_H_BRUTUS")
			await hud.say("SPK_SEHZADE", "D17E_M_BRUTUS_2")
			mehmed.look_target = player
			halil.leave(mehmed.global_position, 6.0, 2.5, true)
			await hud.say("SPK_TOLGA", "D17E_T_BRUTUS_2")
	# Defter: tuğra denemeleri, surlu bir şehir ve zinciri
	mehmed.release_item()
	book.queue_free()
	await hud.say("SPK_SEHZADE", "D17E_M_NOTE")
	await hud.say("SPK_TOLGA", "D17E_T_NOTE")
	var keys := ["UI_C17E_FUT_TELL"]
	var ids := ["told"]
	if GameState.has_item("book"):
		keys.append("UI_C17E_FUT_BOOK")
		ids.append("book")
	keys.append("UI_C17E_FUT_SILENT")
	ids.append("silent")
	var fut := await _choose(keys, ids, "future")
	GameState.flags["edirne_future"] = fut
	match fut:
		"told":
			await hud.say("SPK_TOLGA", "D17E_T_TELL")
			await hud.say("SPK_SEHZADE", "D17E_M_TELL")
			await hud.say("SPK_TOLGA", "D17E_T_TELL_2")
			await hud.say("SPK_SEHZADE", "D17E_M_TELL_2")
		"book":
			await hud.say("SPK_TOLGA", "D17E_T_BOOK")
			var b := Items.build("book")
			await mehmed.receive_item(b, player.global_position + Vector3(0, 1.3, 0))
			await _wait(0.5)
			await hud.say("SPK_SEHZADE", "D17E_M_BOOK")
			mehmed.release_item()
			b.queue_free()
			GameState.note_use("book", "book_sehzade")
			hud.bark("SPK_NIHAT", "D17E_N_BOOK", 3.0)
			await _wait(1.0)
		_:
			await hud.say("SPK_TOLGA", "D17E_T_SILENT")
			await hud.say("SPK_SEHZADE", "D17E_M_SILENT")
	# Çantadakiler: Rubik küpü (önce köşeler) ve selfie çubuğu (hatıra; defterde karikatür)
	if GameState.has_item("cube"):
		await hud.say("SPK_SEHZADE", "D17E_M_CUBE")
		await hud.say("SPK_TOLGA", "D17E_T_CUBE")
		var c := Items.build("cube")
		await mehmed.receive_item(c, player.global_position + Vector3(0, 1.3, 0))
		await _wait(0.8)
		await hud.say("SPK_SEHZADE", "D17E_M_CUBE_2")
		mehmed.release_item()
		c.queue_free()
		await hud.say("SPK_TOLGA", "D17E_T_CUBE_2")
		GameState.note_use("cube", "cube_sehzade")
		GameState.flags["edirne_cube"] = true
	if GameState.has_item("selfie"):
		await hud.say("SPK_TOLGA", "D17E_T_SELFIE")
		await hud.say("SPK_SEHZADE", "D17E_M_SELFIE")
		Audio.sfx("camera", -2.0)
		await hud.fade_to(0.85, 0.05, Color.WHITE)
		await hud.fade_to(0.0, 0.3, Color.WHITE)
		await hud.say("SPK_SEHZADE", "D17E_M_SELFIE_2")
		GameState.note_use("selfie", "selfie_sehzade")
		GameState.flags["edirne_selfie"] = true
	await hud.say("SPK_SEHZADE", "D17E_M_TO_AVLU")
	mehmed.look_target = null
	await _go_together(mehmed, EdirnePalace.MEHMED_AVLU, EdirnePalace.TOLGA_AVLU, "UI_OBJ17E_FOLLOW")


# ================================================================ 4 rehine prensler

func _hostages() -> void:
	mehmed.face_toward(vlad.global_position)
	player.face(vlad.global_position + Vector3(0, 0.9, 0))
	radu.look_target = player
	radu.emote("wave")
	await hud.say("SPK_SEHZADE", "D17E_M_AVLU")
	await hud.say("SPK_RADU", "D17E_R_01")
	await hud.say("SPK_SEHZADE", "D17E_M_DRACUL")
	player.shake(0.2)
	await hud.say("SPK_TOLGA", "D17E_T_DRAC")
	mehmed.look_target = player
	await hud.say("SPK_SEHZADE", "D17E_M_VAMP")
	vlad.look_target = player
	await hud.say("SPK_VLAD", "D17E_V_01")
	await hud.say("SPK_VLAD", "D17E_V_02")
	await hud.say("SPK_SEHZADE", "D17E_M_VLAD")
	await hud.say("SPK_VLAD", "D17E_V_03")
	radu.emote("laugh")
	await hud.say("SPK_RADU", "D17E_R_02")
	await hud.say("SPK_TOLGA", "D17E_T_PANIC")
	var v := await _choose(["UI_C17E_VLAD_KEBAB", "UI_C17E_VLAD_POLICY", "UI_C17E_VLAD_LEGEND", "UI_C17E_VLAD_NONE"],
		["kebab", "policy", "legend", "none"], "vlad")
	GameState.flags["edirne_vlad"] = v
	match v:
		"kebab":
			await hud.say("SPK_TOLGA", "D17E_T_KEB")
			radu.emote("cheer")
			await hud.say("SPK_RADU", "D17E_R_KEB")
			palace.light_brazier()
			Audio.sfx("fire_crackle", -6.0)
			await _hold("UI_QTE17E_TURN", 1.6)
			# Vlad'ın sivrilttiği sopa şiş olur: üç parça et, arada soğan
			var skewer := Node3D.new()
			Props.cyl(skewer, 0.016, 0.7, Vector3.ZERO, Color("b89a6a"), Vector3(90, 0, 0), 5)
			for k in 4:
				Props.ball(skewer, 0.045, Vector3(0, 0, -0.18 + k * 0.09), Color("6a3a22") if k % 2 == 0 else Color("e8d8b0"), Vector3.ONE, 6)
			vlad.set_activity("")
			vlad.hold_item(skewer)
			vlad.emote("eat")
			await hud.say("SPK_VLAD", "D17E_V_KEB")
			radu.emote("cheer")
			await hud.say("SPK_RADU", "D17E_R_KEB_2")
			await hud.say("SPK_SEHZADE", "D17E_M_KEB")
			await hud.say("SPK_VLAD", "D17E_V_KEB_2")
			await hud.say("SPK_TOLGA", "D17E_T_KEB_2")
		"policy":
			await hud.say("SPK_TOLGA", "D17E_T_POL")
			await hud.say("SPK_VLAD", "D17E_V_POL")
			await hud.say("SPK_TOLGA", "D17E_T_POL_2")
			await hud.say("SPK_VLAD", "D17E_V_POL_2")
			await hud.say("SPK_TOLGA", "D17E_T_POL_3")
			await hud.say("SPK_VLAD", "D17E_V_POL_3")
			mehmed.emote("facepalm")
			await hud.say("SPK_SEHZADE", "D17E_M_POL")
		"legend":
			await hud.say("SPK_TOLGA", "D17E_T_LEG")
			await hud.say("SPK_VLAD", "D17E_V_LEG")
			await hud.say("SPK_TOLGA", "D17E_T_LEG_2")
			vlad.set_activity("write")
			await hud.say("SPK_VLAD", "D17E_V_LEG_2")
			radu.emote("surprise")
			await hud.say("SPK_RADU", "D17E_R_LEG")
		_:
			await hud.say("SPK_TOLGA", "D17E_T_NONE")
			await hud.say("SPK_VLAD", "D17E_V_NONE")
			await hud.say("SPK_TOLGA", "D17E_T_NONE_2")


## E basılı tutularak şişler çevrilir (Bölüm 13'teki basılı tutma gibi).
func _hold(label_key: String, seconds: float) -> void:
	hud.set_qte(tr(label_key))
	var h := 0.0
	while h < seconds:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		if Input.is_action_pressed("interact") or GameState.autotest:
			h += dt
			if randf() < 0.05:
				Audio.sfx("fire_crackle", -14.0, randf_range(0.9, 1.2))
		else:
			h = maxf(0.0, h - dt)
		hud.set_red_progress(h / seconds)
	hud.set_red_progress(0.0)
	hud.set_qte("")


# ================================================================ 5 kaçış

func _escape() -> void:
	# Halil Paşa muhafızlarla avluya gelir
	halil.visible = true
	halil.position = EdirnePalace.TOLGA_AVLU + Vector3(5.0, 0, -5.5)
	for i in guards.size():
		guards[i].position = EdirnePalace.TOLGA_AVLU + Vector3(4.0 + i * 2.2, 0, -7.0)
		guards[i].face_toward(player.global_position)
	halil.face_toward(player.global_position)
	await hud.say("SPK_HALIL", "D17E_H_SPY")
	await hud.say("SPK_TOLGA", "D17E_T_SPY")
	var who := String(GameState.flags.get("edirne_who", "hizir"))
	mehmed.look_target = player
	await hud.say("SPK_SEHZADE", "D17E_M_RUN_" + who.to_upper())
	# Havuza koş: muhafızlar peşinde. Yakalanan da havuza atılır (yenilgi yok)
	Audio.music("chase")
	var pool_at := _p(EdirnePalace.POOL)
	var caught := false
	if GameState.autotest:
		player.global_position = pool_at + Vector3(0.6, 0.6, 0.2)
		await _wait(0.2)
	else:
		player.frozen = false
		hud.set_objective(tr("UI_OBJ17E_POOL"), pool_at + Vector3(0, 0.8, 0))
		hud.set_chase(tr("UI_CHASE17E"), 0.0)
		for g in guards:
			g.set_meta("no_audit", true)
		var t := 0.0
		while t < 40.0:
			await get_tree().process_frame
			var dt := get_process_delta_time()
			t += dt
			var lp := palace.to_local(player.global_position)
			if absf(lp.x) < EdirnePalace.POOL_SIZE.x * 0.5 + 0.2 and absf(lp.z) < EdirnePalace.POOL_SIZE.y * 0.5 + 0.2:
				break
			var near := 99.0
			for g in guards:
				var to := player.global_position - g.global_position
				to.y = 0.0
				near = minf(near, to.length())
				if to.length() > 0.8:
					g.global_position += to.normalized() * minf(to.length() - 0.8, 3.1 * dt)
			hud.set_chase(tr("UI_CHASE17E"), clampf(1.0 - near / 8.0, 0.0, 1.0))
			if near < 1.0:
				caught = true
				break
		hud.set_objective("")
		hud.set_chase("", 0.0)
		player.frozen = true
		if caught or t >= 40.0:
			# Muhafızlar Tolga'yı kollarından tutup havuza fırlatır
			await hud.say("SPK_HALIL", "D17E_H_TOSS")
			await hud.fade_to(1.0, 0.25)
			player.global_position = pool_at + Vector3(0.6, 1.6, 0.2)
			await hud.fade_to(0.0, 0.25)
		else:
			player.global_position = pool_at + Vector3(0.6, 1.0, 0.2)
	await _wait(0.5)
	Audio.sfx("splash", 0.0)
	Vfx.splash(palace, EdirnePalace.POOL + Vector3(0.6, EdirnePalace.WATER_Y, 0.2), 1.4)
	player.face(mehmed.global_position + Vector3(0, 1.0, 0))
	hud.bark("SPK_NIHAT", "D17E_N_PULL", 3.0)
	await _wait(1.2)
	mehmed.emote("wave")
	await hud.say("SPK_SEHZADE", "D17E_M_BYE_" + who.to_upper())
	await hud.say("SPK_TOLGA", "D17E_T_BYE")
	# Ters girdap: 1444 → zamanın dışı
	var v := TimeVortex.new()
	host.add_child(v)
	await v.play_text("1444", tr("UI_JUMP_BUREAU"), 0.5 if GameState.autotest else 2.4, false, tr("D17E_CAP_BACK"))
	Audio.sfx("machine_jump", -4.0)
	hud.set_fade(1.0, Color.WHITE)
	v.queue_free()
	_leave_palace()


func _leave_palace() -> void:
	bureau.env_node.environment = _bureau_env
	bureau.visible = true
	palace.queue_free()
	palace = null
	Audio.voice_space("room")
	Audio.ambience("")
	Audio.music("bureau")


# ================================================================ 6 Büro'da sonrası

func _aftermath() -> void:
	await get_tree().physics_frame
	player.global_position = bureau.to_global(Bureau.LIFT_IN) + Vector3(0, 0.05, 0)
	player.face(bureau.to_global(Vector3(Bureau.COR_W / 2, 1.45, Bureau.LIFT_Z)))
	nihat.position = Bureau.NIHAT_PANEL_POS
	nihat.look_target = player
	await hud.fade_to(0.0, 0.6, Color.WHITE)
	Audio.sfx("door_open", -6.0)
	await bureau.open_lift()
	await _wait(0.4)
	await hud.fade_to(1.0, 0.2)
	player.global_position = bureau.to_global(Bureau.LIFT_OUT) + Vector3(0, 0.05, 0)
	player.face(nihat.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.3)
	await hud.say("SPK_NIHAT", "D17E_N_BACK_1")
	await hud.say("SPK_TOLGA", "D17E_T_BACK_1")
	# Müfide masasından koşar
	var mu := bureau.mufide
	var mu_home := mu.position
	var run := mu.create_tween()
	run.tween_property(mu, "position", Vector3(0.7, 0, Bureau.LIFT_Z + 2.1), 0.6 if GameState.autotest else 2.4)
	await run.finished
	mu.face_toward(nihat.global_position)
	await hud.say("SPK_MUFIDE", "D17E_MU_01")
	await hud.say("SPK_NIHAT", "D17E_N_OFFICE")
	# Ofise: Vikipedi ekranında değişiklik farkı
	await hud.fade_to(1.0, 0.4)
	mu.position = mu_home
	nihat.position = Bureau.NIHAT_OFFICE_POS
	player.global_position = bureau.to_global(BOARD_VIEW) + Vector3(0, 0.05, 0)
	var vlad_pick := String(GameState.flags.get("edirne_vlad", "none"))
	var diff := wiki_diff(board, vlad_pick)
	player.face(board.global_position)
	await hud.fade_to(0.0, 0.5)
	Audio.sfx("typewriter_bell", -6.0)
	await _wait(0.6 if GameState.autotest else 1.6)
	nihat.look_target = player
	await hud.say("SPK_NIHAT", "D17E_N_META")
	await hud.say("SPK_TOLGA", "D17E_T_META")
	await hud.say("SPK_NIHAT", "D17E_N_META_2")
	await hud.say("SPK_TOLGA", "D17E_T_WHAT_" + vlad_pick.to_upper())
	await hud.say("SPK_NIHAT", "D17E_N_WHAT_" + vlad_pick.to_upper())
	# Düzeltme damgası: asıl tarih geri gelir, dipnot kalır
	nihat.stamp()
	Audio.sfx("stamp", -2.0)
	await hud.say("SPK_NIHAT", "D17E_N_FIX")
	_wiki_fix(diff, vlad_pick)
	await _wait(0.4)
	await hud.say("SPK_TOLGA", "D17E_T_FIX")
	await hud.say("SPK_NIHAT", "D17E_N_FIX_2")


## Vikipedi ekranı: değişiklik farkı (kırmızı üstü çizili eski satır, yeşil yeni satır, [kaynak belirtilmeli]).
## Döner: eklenen düğüm (düzeltmede dipnota döner).
static func wiki_diff(b: Node3D, vlad_pick: String) -> Node3D:
	for c in b.get_children():
		if c is Label3D or (c is MeshInstance3D and c.position.z > 0.02):
			c.visible = false
	var n := Node3D.new()
	n.name = "WikiDiff"
	b.add_child(n)
	var k := vlad_pick.to_upper()
	Props.label(n, TranslationServer.translate("PROP17E_DIFF_HEAD"), Vector3(0, 0.47, 0.036), 22, Color("202122"), Vector3.ZERO, 1.5)
	Props.box(n, Vector3(1.56, 0.26, 0.004), Vector3(0, 0.25, 0.034), Color("ffe0de"))
	Props.box(n, Vector3(1.56, 0.62, 0.004), Vector3(0, -0.22, 0.034), Color("dcf5dc"))
	var ol := _wrap(n, "− " + TranslationServer.translate("PROP17E_DIFF_OLD_" + k), Vector3(0, 0.25, 0.038), 17, Color("a01818"), 1.44)
	Props.box(n, Vector3(minf(1.4, Props.text_width(ol.text, ol.font_size, ol.pixel_size)), 0.008, 0.002), Vector3(0, 0.25, 0.04), Color("a01818"))
	_wrap(n, "+ " + TranslationServer.translate("PROP17E_DIFF_NEW_" + k), Vector3(0, -0.2, 0.038), 15, Color("146014"), 1.44)
	Props.label(n, TranslationServer.translate("PROP17_WIKI_CN"), Vector3(0.45, -0.49, 0.038), 13, Color("cc2a2a"), Vector3.ZERO)
	return n


## Ekranda satırlara sarılan yazı (width_m metre genişliğinde).
static func _wrap(parent: Node3D, text: String, pos: Vector3, size: int, color: Color, width_m: float) -> Label3D:
	var l := Props.label(parent, text, pos, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.width = width_m / l.pixel_size
	return l


## Düzeltme damgası: fark kalkar, asıl satır geri gelir, yanında dipnot (tarih inatçıdır; dipnotlar daha inatçı).
func _wiki_fix(diff: Node3D, vlad_pick: String) -> void:
	if is_instance_valid(diff):
		diff.queue_free()
	var n := Node3D.new()
	n.name = "WikiFixed"
	board.add_child(n)
	var k := vlad_pick.to_upper()
	Props.label(n, tr("PROP17E_DIFF_HEAD"), Vector3(0, 0.47, 0.036), 22, Color("202122"), Vector3.ZERO, 1.5)
	_wrap(n, tr("PROP17E_DIFF_OLD_" + k), Vector3(0, 0.2, 0.038), 18, Color("202122"), 1.44)
	_wrap(n, tr("PROP17E_FOOT_" + k) + " " + tr("PROP17_WIKI_CN"), Vector3(0, -0.06, 0.038), 16, Color("8a4a1a"), 1.44)
	Props.box(n, Vector3(0.5, 0.16, 0.01), Vector3(0.42, -0.36, 0.04), Color("c8262f"), Vector3(0, 0, -8))
	Props.label(n, tr("PROP17E_FIXED"), Vector3(0.42, -0.36, 0.046), 16, Color("fff0e0"), Vector3(0, 0, -8), 0.48)


# ================================================================ çekimler (--flag=shots17:edirne)

## Görsel tur: her sahnenin bir karesi (diyalogsuz; kişiler yerlerinde). Bölüm 17'nin _run_shots'ından çağrılır.
func shots(h: Node3D, hd: Hud, pl: Player, bu: Bureau, ni: Person, bo: Node3D, shot: Callable) -> void:
	host = h
	hud = hd
	player = pl
	bureau = bu
	nihat = ni
	board = bo
	host.add_child(self)
	hud.set_fade(0.0)
	# Asansör: Nihat panelde, kadran 1453
	player.global_position = bureau.to_global(Bureau.LIFT_FRONT + Vector3(0.6, 0, 1.6)) + Vector3(0, 0.05, 0)
	nihat.position = Bureau.NIHAT_PANEL_POS
	player.face(bureau.to_global(Vector3(-1.6, 1.6, Bureau.LIFT_Z + 0.6)))
	bureau.set_dial("1453")
	await bureau.open_lift()
	await _wait(0.4)
	await shot.call("c17e_01_lift.png")
	# Arıza girdabı (ortasında)
	var v := TimeVortex.new()
	host.add_child(v)
	v._fit(4)
	v._year.text = "HATA"
	v._year.modulate.a = 1.0
	v._mat.set_shader_parameter("prog", 0.55)
	v._mat.set_shader_parameter("glitch", 1.0)
	v._caption.text = tr("D17E_CAP_GLITCH")
	v._caption.modulate.a = 1.0
	await _wait(0.2)
	await shot.call("c17e_02_glitch.png")
	v.queue_free()
	_enter_palace()
	await _wait(1.0)
	# Havuz ve çınar altında şehzade
	player.global_position = _p(Vector3(-2.3, 0.05, -1.3))
	_look(mehmed)
	await _wait(0.5)
	await shot.call("c17e_03_pool.png")
	# Kapak (assets/art/covers/ch17e.png): üç çocuk çınarın önünde; arkada Dershâne'de Gürânî, surun ardında
	# yapımdaki Üç Şerefeli
	var cam := _p(Vector3(2.6, 0.05, 3.4))
	var kids: Array[Person] = [vlad, mehmed, radu]
	var spots: Array[Vector3] = [Vector3(1.6, 0, 6.6), Vector3(2.75, 0, 6.2), Vector3(3.85, 0, 6.5)]
	var homes: Array[Vector3] = []
	for i in kids.size():
		homes.append(kids[i].position)
		kids[i].set_activity("")
		kids[i].position = spots[i]
		kids[i].face_toward(cam)
		kids[i].look_target = player
	player.global_position = cam
	player.face(_p(Vector3(2.75, 1.45, 6.4)))
	radu.emote("wave")
	hud.visible = false
	await _wait(0.7)
	await shot.call("c17e_00_cover.png")
	hud.visible = true
	for i in kids.size():
		kids[i].position = homes[i]
		kids[i].look_target = null
	vlad.set_activity("chop")
	# Dershâne: Gürânî ve değnek
	mehmed.release_item()
	mehmed.position = EdirnePalace.MEHMED_DERS
	mehmed.face_toward(gurani.global_position)
	palace.rod.visible = false
	gurani.equip("rod")
	player.global_position = _p(EdirnePalace.TOLGA_DERS + Vector3(0, 0.05, 0))
	player.face(gurani.global_position + Vector3(0, 0.9, 0))
	gurani.look_target = player
	await _wait(0.6)
	await shot.call("c17e_04_lesson.png")
	# Kütüphane: İskendernâme ve defter
	mehmed.set_activity("")
	mehmed.position = EdirnePalace.MEHMED_LIB
	mehmed.hold_item(Items.open_book(), true)
	player.global_position = _p(EdirnePalace.TOLGA_LIB + Vector3(0, 0.05, 0))
	mehmed.face_toward(player.global_position)
	_look(mehmed)
	await _wait(0.6)
	await shot.call("c17e_05_library.png")
	# Avlu: Vlad, Radu, sopalar; mangal yanar
	mehmed.release_item()
	mehmed.position = EdirnePalace.MEHMED_AVLU
	mehmed.face_toward(vlad.global_position)
	palace.light_brazier()
	player.global_position = _p(EdirnePalace.TOLGA_AVLU + Vector3(0.8, 0.05, -0.6))
	player.face(vlad.global_position + Vector3(0, 0.7, 0))
	vlad.look_target = player
	radu.look_target = player
	await _wait(0.8)
	await shot.call("c17e_06_hostages.png")
	# Kaçış: Halil ve muhafızlar
	halil.position = EdirnePalace.GATE + Vector3(0, 0, 3.0)
	for i in guards.size():
		guards[i].position = EdirnePalace.GATE + Vector3(-1.4 + i * 2.8, 0, 4.2)
	player.global_position = _p(Vector3(0.0, 0.05, -6.5))
	player.face(halil.global_position + Vector3(0, 1.4, 0))
	await _wait(0.6)
	await shot.call("c17e_07_escape.png")
	_leave_palace()
	# Büro: Vikipedi farkı
	await _wait(0.3)
	var pick := str(GameState.flags.get("shots_vlad", "kebab"))
	wiki_diff(board, pick)
	player.global_position = bureau.to_global(BOARD_VIEW) + Vector3(0, 0.05, 0)
	player.face(board.global_position)
	await _wait(0.5)
	await shot.call("c17e_08_wiki.png")
	# Gerçek gönderiş: Büro'dan kuşatmanın ilk sayfasına giden girdap (ortasında)
	var j := TimeVortex.new()
	host.add_child(j)
	var to := Siege.date_label(36)
	j._fit(to.length())
	j._year.text = to
	j._year.modulate.a = 1.0
	j._mat.set_shader_parameter("prog", 0.5)
	j._caption.text = tr("UI_JUMP_CAP_FIRST")
	j._caption.modulate.a = 1.0
	await _wait(0.2)
	await shot.call("c17e_09_jump.png")
	j.queue_free()
