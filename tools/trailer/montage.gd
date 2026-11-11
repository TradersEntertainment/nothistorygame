extends Node
## Oynanış fragmanının yöneticisi (bkz. gameplay.gd). Sahne değişse de yaşar (kökün çocuğu).
## Her çekim: bölüm + test botu varyantı + "ne zaman" koşulu (Expression; aşağıdaki yardımcılarla) + süre + başlık.
## Koşul sağlanana dek ekran kara, ses kapalı, zaman SKIP_SPEED katı hızlı; sağlanınca kesme, pencere süresince oyun
## gerçek hızında oynar. Kesim listesi stdout'a: "MONTAGE seg=i in=<kare> out=<kare>".

const SKIP_SPEED := 4.0
const FADE := 0.18

## ch: --chapter değeri (ya da "arena"); v: --autotest varyantı; when: koşul; dur: pencere (sn); lead: koşuldan sonra
## pencere başlamadan beklenen (sn); cap: [TR, EN] üst yazı; wait: koşul için en fazla bekleme (oyun sn)
const CLIPS := [
	{"id": "duel", "ch": "20", "v": "", "when": "on('Duel', 'active')", "lead": 0.6, "dur": 7.0,
		"cap": ["KILIÇ: YÖNÜ OKU, SAVUŞTUR", "READ THE BLADE. PARRY."]},
	{"id": "cannon", "ch": "20o", "v": "", "when": "on('CannonCrew', 'state', 'ball')", "lead": 0.0, "dur": 10.0,
		"cap": ["TOPU KENDİN DOLDUR, KENDİN NİŞANLA", "LOAD IT. AIM IT. FIRE IT."]},
	{"id": "matchlock", "ch": "20", "v": "", "when": "busy('Handgun')", "lead": 0.0, "dur": 7.0,
		"cap": ["FİTİLLİ TÜFEK: BARUT, KURŞUN, HARBİ", "MATCHLOCK: POWDER, BALL, RAMROD"]},
	{"id": "rowing", "ch": "38o", "v": "", "when": "sv('phase') == 'row'", "lead": 4.0, "dur": 6.0,
		"cap": ["HALİÇ'TE KÜREK ÇEK", "ROW ACROSS THE GOLDEN HORN"]},
	{"id": "flight", "ch": "7", "v": "", "when": "flyable()", "lead": 3.0, "dur": 7.0, "drive": "fly", "bot": false, "wait": 1200.0,
		"cap": ["UÇ. GÖRÜNMEZ OL.", "FLY. TURN INVISIBLE."]},
	{"id": "city", "ch": "31o", "v": "", "when": "walking(4.0)", "lead": 0.0, "dur": 6.0,
		"cap": ["1453 İSTANBUL'UNU GEZ", "WALK 1453 CONSTANTINOPLE"]},
	{"id": "arena", "ch": "arena", "v": "osm", "when": "on('Duel', 'active')", "lead": 1.0, "dur": 7.0,
		"cap": ["SONSUZ KUŞATMA: İKİ TARAF", "ENDLESS SIEGE: BOTH SIDES"]},
]

## Hissiyat fragmanı ("-- set=feel"): v0.99.90-93'ün oynanış anları (Blakherna kulesi, ok altında taşıma, yakın atış)
const FEEL_CLIPS := [
	{"id": "sheet", "ch": "19", "v": "", "when": "shown('_sheet_rope') and after(6.0)", "lead": 0.0, "dur": 5.0,
		"cap": ["YELKEN HALATI SENDE", "THE SHEET IS IN YOUR HANDS"]},
	{"id": "ladder_arrows", "ch": "30o", "v": "", "when": "sv('phase') == 'carry'", "lead": 0.8, "dur": 6.0,
		"cap": ["MERDİVENİ TAŞI. OKLAR YAĞIYOR.", "CARRY THE LADDER. ARROWS INCOMING."]},
	{"id": "pole", "ch": "30", "v": "", "when": "sv('phase') == 'ladders' and shown('_pole')", "lead": 0.0, "dur": 5.0,
		"cap": ["MERDİVENİ SURDAN İT", "PUSH THE LADDER OFF THE WALL"]},
	{"id": "wall_duel", "ch": "30o", "v": "", "when": "sv('phase') == 'fight' and on('Duel', 'active')", "lead": 0.6, "dur": 6.5,
		"cap": ["SURDA İLK RAKİP", "FIRST BLADE ON THE WALL"]},
	{"id": "tower_gunner", "ch": "30o", "v": "", "when": "sv('phase') == 'tower' and on('Gunner', 'state', 'aim')", "lead": 0.0, "dur": 5.0,
		"cap": ["TÜFEK DOLU. YANA ATLA.", "HIS GUN IS LOADED. DODGE."]},
	{"id": "wounded", "ch": "30o", "v": "", "when": "sv('carried') == true", "lead": 1.2, "drive": "level", "dur": 6.0,
		"cap": ["YARALIYI OMZUNA AL", "SHOULDER THE WOUNDED"]},
	{"id": "giust_carry", "ch": "26", "v": "", "when": "sv('_carrying_giust') == true", "lead": 0.8, "dur": 6.0, "drive": "level", "wait": 2400.0,
		"cap": ["KOMUTANI SEN TAŞI. SARSMA.", "CARRY THE COMMANDER. DON'T JOLT HIM."]},
]

## Dikey kısalar için konuşmalı kesitler ("-- set=shorts clean"): test botu tempo modunda (seslendirme süresince) oynar,
## pencere ilk replikle açılır (said), son replik bitince (done) tail saniye sonra kapanır. Kanca yazıları cut.py'de.
const SHORT_CLIPS := [
	{"id": "vlad_kasko", "ch": "17", "v": "edirne_policy", "pace": true, "pace_key": "D17E_R_03", "when": "said('D17E_T_POL')",
		"until": "done('D17E_M_POL')", "dur": 50.0, "wait": 4000.0, "tail": 0.8, "cap": ["Kale Kasko", "Castle Cover"]},
	{"id": "giust_kusatma_haric", "ch": "6", "v": "byz", "pace": true, "pace_key": "D6B_T_CAUGHT", "when": "said('D6_GIUST_HELLO')",
		"until": "done('D6B_G_INSURANCE2')", "dur": 40.0, "wait": 3000.0, "tail": 0.25, "cap": ["Kuşatma hariç", "Siege excluded"]},
	{"id": "buro_madde9", "ch": "17", "v": "", "pace": true, "when": "said('D17_N_04')",
		"until": "done('D17_N_06')", "dur": 50.0, "wait": 2000.0, "tail": 0.6, "cap": ["Madde 9", "Clause 9"]},
	{"id": "buro_kamera", "ch": "17", "v": "", "pace": true, "pace_key": "D17_T_05", "when": "said('D17_N_CAM_1')",
		"until": "done('D17_N_CAM_4') or done('D17_N_CAM_4_NOSHOT')", "dur": 40.0, "wait": 2400.0, "tail": 0.25,
		"cap": ["Model Z-0", "Model Z-0"]},
	{"id": "kayik_ters", "ch": "17", "v": "", "pace": true, "pace_key": "D17_N_RULE", "when": "said('D17_TR_01')",
		"until": "done('D17_HINT_ROW')", "dur": 40.0, "wait": 3000.0, "tail": 0.25, "cap": ["Ters oturan kürekçi", "Rowing backwards"]},
	{"id": "hikmet_1977", "ch": "15", "v": "wrong_stay", "pace": true, "pace_key": "D15_Y_T_RADIO", "when": "said('D15_S7_YH_1')",
		"until": "done('D15_S7_T_6')", "dur": 50.0, "wait": 3000.0, "tail": 1.0, "cap": ["1977", "1977"]},
	{"id": "tunel_police", "ch": "10l", "v": "", "pace": true, "pace_key": "D10L_G_MEET_2", "when": "said('D10L_T_POLICY')",
		"until": "done('D10L_G_POLICY')", "dur": 30.0, "wait": 3000.0, "tail": 0.25, "cap": ["İki tünel, tek poliçe", "Two tunnels, one policy"]},
	{"id": "bogaz_gumruk", "ch": "33o", "v": "", "pace": true, "pace_key": "D33O_M_DONE", "when": "said('D33O_FZ_01')",
		"until": "done('D33O_T_05')", "dur": 30.0, "wait": 3000.0, "tail": 0.25, "cap": ["Boğaz gümrüğü", "Bosphorus customs"]},
]

## Hikâye fragmanı ("-- set=story"): komik/merak uyandıran sahneler + birkaç temiz mekanik an. Yazısız kayıt (clean
## + nohud): altyazı ve üst yazı story_cut.py'de ASS ile basılır; oyunun müzik yolu susturulur, kurguda tek parça
## müzik alta yatar. "steps": botsuz çekimlerde oyuncuyu betikten süren zamanlı adımlar (bkz. _steps_tick).
## Adım: {"t": sn (koşul sağlandığı andan), "pos": Vector3 (ışınla), "look": Vector3 (anında bak),
##   "pan": [Vector3, sn] (yumuşak dönüş), "walk": [Vector3, hız çarpanı] (ileri yürü, hedefe bakarak),
##   "do": "ifade" (Expression; ör. "sv('bureau')._fg_seq([...])"), "frozen": bool}
const STORY_CLIPS := [
	# 0 Kanca: soğuk açılış, kare donar, Tolga havada: "Evet. Bu benim."
	{"id": "kanca_bu_benim", "ch": "0", "v": "", "pace": true, "pace_key": "D0_S_ARROWS", "when": "sv('phase') == 'freeze'",
		"lead": 0.0, "until": "done('D0_T_FREEZE_1')", "dur": 14.0, "tail": 0.3, "wait": 600.0, "cap": ["", ""]},
	# 3 Zaman Bürosu bekleme salonu: Napolyon Hitler'e Rusya dersi verir (atışma otomatik testte kapalı: betikten)
	{"id": "buro_atisma", "ch": "3", "v": "", "bot": false, "when": "loose() and after(3.0)", "lead": 0.3, "dur": 14.0,
		"until": "done('BUR_FG_NAP_4')", "tail": 0.5, "drive": "steps", "nohands": true,
		"cap": ["Zaman Bürosu, bekleme salonu", "Time Bureau, waiting room"], "steps": [
			{"t": 0.0, "do": "sv('bureau').set('_amb_on', false)"},
			{"t": 0.0, "do": "sv('bureau').set('_wait_said', true)"},
			{"t": 0.0, "pos": Vector3(-7.4, 0.05, -9.4), "look": Vector3(-4.7, 1.85, -6.9)},
			{"t": 0.0, "do": "_player().camera.set('fov', 46.0)"},
			{"t": 0.4, "do": "sv('bureau')._fg_seq([['nap', 'BUR_FG_NAP_3', 8.0, 'hit'], ['hit', 'BUR_FG_HIT_R', 1.2, 'nap'], ['nap', 'BUR_FG_NAP_4', 0.8, 'hit']])"},
			{"t": 0.0, "on": "said('BUR_FG_HIT_R')", "pan": [Vector3(-8.15, 1.3, -7.95), 0.8]},
		]},
	# Büro: Napolyon ile Cengiz Han sıra numarası yarışı
	{"id": "buro_numara", "ch": "3", "v": "", "bot": false, "when": "loose() and after(3.0)", "lead": 0.3, "dur": 10.0,
		"until": "done('BUR_AMB_G1_2_3')", "tail": 0.5, "drive": "steps", "nohands": true, "cap": ["", ""], "steps": [
			{"t": 0.0, "do": "sv('bureau').set('_amb_on', false)"},
			{"t": 0.0, "do": "sv('bureau').set('_wait_said', true)"},
			{"t": 0.0, "pos": Vector3(-2.5, 0.05, -8.6), "look": Vector3(-3.9, 1.75, -6.1)},
			{"t": 0.0, "do": "_player().camera.set('fov', 62.0)"},
			{"t": 0.4, "do": "sv('bureau')._fg_seq([['nap', 'BUR_AMB_G1_2_1', 1.9, 'gen'], ['gen', 'BUR_AMB_G1_2_2', 2.9, 'nap'], ['nap', 'BUR_AMB_G1_2_3', 1.6, 'gen']])"},
		]},
	# Edirne 1444: genç Vlad'a kale sigortası ("Kazık." / "Hayır, poliçe.")
	{"id": "vlad_kazik", "ch": "17", "v": "edirne_policy", "pace": true, "pace_key": "D17E_R_03", "when": "said('D17E_T_POL_2')",
		"lead": 0.0, "until": "done('D17E_V_POL_3')", "dur": 14.0, "wait": 4000.0, "tail": 0.4, "cap": ["", ""]},
	# 1977: genç Hikmet'e poliçe; "kırmızı düğmeye basma" (hikâyenin merak ucu)
	{"id": "hikmet_1977", "ch": "15", "v": "wrong_stay", "pace": true, "pace_key": "D15_Y_T_RADIO", "when": "said('D15_S7_YH_5')",
		"lead": 0.0, "until": "done('D15_S7_YH_5')", "dur": 9.0, "wait": 3000.0, "tail": 0.05, "cap": ["", ""]},
	# 5 Otağ: Fatih "Bu şehir alınacak mı?" / "Evet. 29 Mayıs'ta. Salı günü."
	{"id": "otag_sali", "ch": "12", "v": "leblebi", "pre": "unbag('book')", "pace": true, "pace_key": "D12_F_KEY", "when": "said('D12_F_KEY')",
		"lead": 0.1, "until": "done('D12_T_KEY_B') or done('D12_T_KEY_B_NOBOOK')", "dur": 14.0, "tail": 0.5, "wait": 3000.0,
		"drive": "steps", "nohands": true, "cap": ["", ""], "steps": [
			{"t": 0.0, "do": "_player().camera.set('fov', 24.0)"},
			{"t": 0.0, "aim": ["sv('hall').fatih", 1.55, 0.05]},
		]},
	# Boğaz gümrüğü: "Ağam, siz sigortacılığı icat etmişsiniz."
	{"id": "bogaz_prim", "ch": "33o", "v": "", "pace": true, "pace_key": "D33O_M_DONE", "when": "said('D33O_T_05')",
		"lead": 0.0, "until": "done('D33O_T_05')", "dur": 10.0, "wait": 3000.0, "tail": 0.4, "drive": "steps", "nohands": true,
		"cap": ["", ""], "steps": []},
	{"id": "flight", "ch": "7", "v": "", "when": "flyable()", "lead": 3.0, "dur": 5.5, "drive": "fly", "bot": false, "wait": 1200.0, "nohands": true,
		"cap": ["Uç. Görünmez ol.", "Fly. Turn invisible."]},
]

var _en := false
var _only: Array = []
var _steps: Array = []
var _step_i := 0
var _pan := {}               # {"y0","p0","y1","p1","t","d"}
var _walk_to := Vector3.INF
var _walk_mult := 1.0
var _nohands := false         # çekimde birinci şahıs eller gizli (elde alakasız eşya kadrajı kapatmasın)
var _shots := ""
var _layer: CanvasLayer
var _black: ColorRect
var _cap: Label
var _title: Label
var _tag: Label
var _t := 0.0               # çekimin sahnesi yüklendiğinden beri oyun saniyesi
var _fps := 30.0            # kayıt --fixed-fps 30 ile: pencere kare sayısıyla ölçülür (Godot bu argümanı betiğe
                            # vermez); fps=N ile değişir; kare önizlemede (shots=) duvar saati
var _skip_speed := SKIP_SPEED
var _dur := 0.0
var _skipping := true
var _cache := {}
var _walk_t := 0.0
var _last_p := Vector3.INF
var _seg := 0
var _drive := ""
var _drive_t := 0.0
var _cloak_done := false
var _drive_y0 := INF
## Yazısız kayıt ("clean"): HUD ve üst yazı çizilmez, replikler ve başlık kare numarasıyla stdout'a yazılır
## (tools/trailer/cut.py dikey kısaları ve 16:9 kurguyu kendi yazılarıyla basar)
var _clean := false
var _nohud := false            # "nohud": arayüz gizlenir, üst başlık kalır (hissiyat fragmanı)
var _set := "trailer"
var _hud: Node
var _seen := {}              # gösterilen replik anahtarı → kare
var _ended := {}             # bitmiş replikler
var _line_on := false
var _line_key := ""          # line_shown'ın son anahtarı
var _cur_key := ""           # ekrandaki repliğin anahtarı (yeni replik gelince "biten" bu olur)
var _line_txt := ""
var _in_window := false
var _pace_key := ""          # bu replik gösterildiği anda tempo modu açılır (öncesi anında geçer)
const HUD_HIDE := ["_sub_box", "_objective_box", "_prompt", "_controls", "_bag_box", "_bag_strip", "_held_label",
	"_signal_box", "_portrait", "_crosshair", "_choice_box", "_chase_box", "_qte", "_lore_panel", "_disc_panel",
	"_red_bar", "_red_label", "_keypad_box"]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 1000          # HUD'dan sonra: gizleme o karenin son sözü olsun
	for a in OS.get_cmdline_user_args():
		if a == "en":
			_en = true
		elif a == "clean":
			_clean = true
		elif a == "nohud":
			_nohud = true
		elif a.begins_with("set="):
			_set = a.trim_prefix("set=")
		elif a.begins_with("only="):
			_only = Array(a.trim_prefix("only=").split(",")).map(func(x): return int(x))
		elif a.begins_with("dur="):
			_dur = float(a.trim_prefix("dur="))     # önizleme: bütün pencereler bu uzunlukta
		elif a.begins_with("fps="):
			_fps = float(a.trim_prefix("fps="))
		elif a.begins_with("shots="):
			_shots = a.trim_prefix("shots=")
			_fps = 0.0
			DirAccess.make_dir_recursive_absolute(_shots)
	if _set == "story":
		_clean = true
		_nohud = true
	if _en:
		GameState.locale = "en"
		TranslationServer.set_locale("en")
	_build_ui()
	# HUD sahneye girer girmez dinlenir: bölüm ilk karelerde konuşmaya başlıyorsa (17'nin Büro açılışı) _process'te
	# bağlanmak geç kalıyordu, pace_key repliği kaçıyordu
	get_tree().node_added.connect(func(n: Node):
		if n is Hud:
			_hook_hud(n))
	_run()


func _build_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 120
	add_child(_layer)
	_black = ColorRect.new()
	_black.color = Color.BLACK
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(_black)
	var font: Font = load(Hud.FONT_TITLE)
	_cap = Label.new()
	_cap.add_theme_font_override("font", font)
	_cap.add_theme_font_size_override("font_size", 50)
	_cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cap.custom_minimum_size = Vector2(980, 0)
	_cap.add_theme_color_override("font_color", Color("ffd24a"))
	_cap.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_cap.add_theme_constant_override("outline_size", 14)
	_cap.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_cap.position = Vector2(80, 60)
	_cap.modulate.a = 0.0
	_layer.add_child(_cap)
	for big in [true, false]:
		var l := Label.new()
		l.add_theme_font_override("font", font)
		l.add_theme_font_size_override("font_size", 100 if big else 36)
		l.add_theme_color_override("font_color", Color("f2e6c9"))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER if big else VERTICAL_ALIGNMENT_BOTTOM
		l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if not big:
			l.offset_bottom = -150
		l.modulate.a = 0.0
		_layer.add_child(l)
		if big:
			_title = l
		else:
			_tag = l


func _tx(pair: Array) -> String:
	return pair[1] if _en else pair[0]


func _process(delta: float) -> void:
	_t += delta
	if _skipping:
		if Engine.time_scale > 0.05:
			Engine.time_scale = _skip_speed
	elif Engine.time_scale > 1.0:
		Engine.time_scale = 1.0       # bölümün test hızı (2,5-3x) kayıtta gerçek hıza; Fx'in ağır çekimi (<1) kalır
	# Kara ekranda 3B çizilmez: yazılımla çizimde (fragman kaydı) atlanan bekleme kareleri ucuzlar
	get_tree().root.disable_3d = _black.color.a > 0.99
	_track_hud()
	var p := _player()
	if p and _drive != "":
		_drive_step(p, delta)
	if p:
		var pos := p.global_position
		if _last_p != Vector3.INF and Vector2(pos.x - _last_p.x, pos.z - _last_p.z).length() > 0.01 and not p.frozen:
			_walk_t += delta
		else:
			_walk_t = 0.0
		_last_p = pos


## Replikleri izler: said()/done() koşulları ve pencere içinde "MONTAGE line on/off" kayıtları; clean'de HUD gizlenir
func _hook_hud(h: Node) -> void:
	if h == null or h.has_meta("montage_hooked") or not h.has_signal("line_shown"):
		return
	h.set_meta("montage_hooked", true)
	h.line_shown.connect(func(k: String):
		_seen[k] = Engine.get_process_frames()
		_line_key = k
		# Aynı replik içinde (HUD _fast()'a bakmadan önce): bu replik ve sonrakiler seslendirme süresince
		if k == _pace_key:
			GameState.pace = true)


func _track_hud() -> void:
	var h := get_tree().get_first_node_in_group("hud")
	if h != _hud:
		_hud = h
		_line_on = false
		_hook_hud(h)
	if _hud == null or not is_instance_valid(_hud):
		return
	var sb = _hud.get("_sub_box")
	var on: bool = sb is Control and (sb as Control).visible
	var txt := ""
	if on:
		var st = _hud.get("_sub_text")
		txt = (st as Label).text if st is Label else ""
	if _line_on and (not on or txt != _line_txt):
		_ended[_cur_key] = true
		if _in_window:
			print("MONTAGE line off frame=%d" % Engine.get_process_frames())
	if on and (not _line_on or txt != _line_txt):
		_cur_key = _line_key
		if _in_window:
			var sp = _hud.get("_sub_speaker")
			var name := (sp as Label).text if sp is Label else ""
			var col := (sp as Label).get_theme_color("font_color") if sp is Label else Color("ffd24a")
			print("MONTAGE line on frame=%d key=%s col=%s spk=%s text=%s" % [Engine.get_process_frames(), _cur_key,
				col.to_html(false), name, txt.replace("\n", " ")])
	_line_on = on
	_line_txt = txt
	if (_clean or _nohud) and _in_window:
		for n in HUD_HIDE + (["minimap"] if _nohud else []) + (["marker", "meters", "_legend", "_sub_hint"] if _set == "story" else []):
			var c = _hud.get(n)
			if c != null and is_instance_valid(c) and c is CanvasItem:
				(c as CanvasItem).modulate.a = 0.0


## Bu anahtarlı replik gösterildi mi / bitti mi (pencereyi bir replikten ötekine açmak için)
func said(key: String) -> bool:
	return _seen.has(key)


func done(key: String) -> bool:
	return _ended.has(key)


func _wait(t: float) -> void:
	await get_tree().create_timer(t, true, false, false).timeout


func _mute(on: bool) -> void:
	AudioServer.set_bus_mute(0, on)


func _mark(what: String) -> void:
	print("MONTAGE %s seg=%d frame=%d" % [what, _seg, Engine.get_process_frames()])


# ---------------------------------------------------------------- akış

func _run() -> void:
	await get_tree().process_frame
	if _set == "shorts":
		for i in SHORT_CLIPS.size():
			if not _only.is_empty() and not (i in _only):
				continue
			await _clip(SHORT_CLIPS[i])
			_seg += 1
		print("MONTAGE done")
		get_tree().quit()
		return
	if _set == "story":
		await _story()
		return
	_skipping = false
	Engine.time_scale = 1.0
	# Açılış kartı (kara zemin, yazı): kayıtta tutulur
	_mark("in")
	Audio.music("tension", 0.0)
	if _set == "feel":
		await _card(_tx(["1453. Surlar.", "1453. The walls."]), _tx(["Oynanış", "Gameplay"]), 2.2)
	else:
		await _card(_tx(["1453.", "1453."]), _tx(["Oynanış", "Gameplay"]), 2.2)
	_mark("out")
	_seg += 1
	var clips: Array = FEEL_CLIPS if _set == "feel" else CLIPS
	for i in clips.size():
		if not _only.is_empty() and not (i in _only):
			continue
		await _clip(clips[i])
		_seg += 1
	# Kapanış kartı: bölüm kaldırılır (sesi sussun), başlık ve istek listesi
	_skipping = true
	_mute(true)
	_black.color.a = 1.0
	GameState.changing = false
	get_tree().change_scene_to_file("res://tools/trailer/blank.tscn")
	await _wait(0.6)
	_skipping = false
	Engine.time_scale = 1.0
	_mute(false)
	Audio.music("credits", 0.0)
	_mark("in")
	await _card(_tx(["Gerçek Tarih Bu Değil", "Not a History Game"]),
		_tx(["27 final · kuşatma iki taraftan · tamamen seslendirilmiş\nSteam'de istek listene ekle",
			"27 endings · the siege from both sides · fully voiced\nWishlist it on Steam"]), 3.4)
	_mark("out")
	print("MONTAGE done")
	get_tree().quit()


## Hikâye fragmanı: açılış kartı yok (ilk çekim kanca), çekimler, kapanış kartı (ad, tek cümle, istek listesi).
## Önizlemede (only=) kart yalnız "card" verilirse çekilir.
func _story() -> void:
	var with_card := _only.is_empty() or "card" in OS.get_cmdline_user_args()
	for i in STORY_CLIPS.size():
		if not _only.is_empty() and not (i in _only):
			continue
		await _clip(STORY_CLIPS[i])
		_seg += 1
	if with_card:
		_skipping = true
		_mute(true)
		_black.color.a = 1.0
		GameState.changing = false
		get_tree().change_scene_to_file("res://tools/trailer/blank.tscn")
		await _wait(0.6)
		_skipping = false
		Engine.time_scale = 1.0
		_mute(false)
		_mark("in")
		print("MONTAGE card seg=%d frame=%d" % [_seg, Engine.get_process_frames()])
		await _card(_tx(["Gerçek Tarih Bu Değil", "Not a History Game"]),
			_tx(["Tarih böyle değildi. Artık böyle.\n27 final · kuşatma iki taraftan · tamamen seslendirilmiş\nSteam'de istek listene ekle",
				"History wasn't like this. Now it is.\n27 endings · the siege from both sides · fully voiced\nWishlist it on Steam"]), 4.0)
		_mark("out")
	print("MONTAGE done")
	get_tree().quit()


func _music_bus_mute() -> void:
	var mb := AudioServer.get_bus_index("Music")
	if mb >= 0:
		AudioServer.set_bus_mute(mb, true)


func _card(big: String, small: String, hold: float) -> void:
	_black.color.a = 1.0
	_title.text = big
	_tag.text = small
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_title, "modulate:a", 1.0, 0.3)
	tw.tween_property(_tag, "modulate:a", 1.0, 0.4).set_delay(0.3)
	await _wait(hold)
	_title.modulate.a = 0.0
	_tag.modulate.a = 0.0


func _clip(c: Dictionary) -> void:
	_skipping = true
	_mute(true)
	if _set == "story":
		_music_bus_mute()
	_black.color.a = 1.0
	_cache.clear()
	_seen.clear()
	_ended.clear()
	_skip_speed = float(c.get("skip", SKIP_SPEED))
	# Konuşmalı kesit: test botu replikleri seslendirme süresince bekler (yoksa anında geçer). pace_key verilirse
	# tempo o replikte açılır: bütün bölüm gerçek sürede oynanmaz, kayıtta dakikalarca kara kare birikmez
	_pace_key = String(c.get("pace_key", ""))
	GameState.pace = bool(c.get("pace", false)) and _pace_key == ""
	_walk_t = 0.0
	_last_p = Vector3.INF
	GameState.reset_run()
	# bot: false: botu olmayan mekanik (uçuş); bölüm normal akar, oyuncuyu pencerede bu betik yönetir
	GameState.autotest = c.get("bot", true)
	GameState.flags["trailer"] = true      # botlar görünür hızda oynar (ör. top ekibi adım adım)
	GameState.autotest_variant = c["v"]
	var path := ""
	if c["ch"] == "arena":
		path = "res://scenes/arena.tscn"
	else:
		var v: String = c["ch"]
		GameState.start_chapter = int(v)
		GameState.start_scene = "" if v.is_valid_int() else "res://scenes/chapter%s.tscn" % v
		var ch := int(v)
		path = GameState.start_scene if GameState.start_scene != "" else "res://scenes/chapter%d.tscn" % ch
		if ch in Siege.ORDER:
			GameState.ensure_defaults_for(12)
			if path.ends_with("o.tscn"):
				GameState.flags["siege_side"] = "O"
		elif ch > 1:
			GameState.ensure_defaults_for(mini(ch, GameState.LATEST_CHAPTER))
	# Fes kenarı birinci şahısta kadrajın üstünü kırmızı bir şeritle kapatıyordu: fragmanda fes yok
	GameState.flags["fez"] = false
	GameState.changing = false
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	if c.has("pre"):          # sahne kurulunca bir kez (ör. "unbag('book')"): bölümün akışı başlamadan
		var pe := Expression.new()
		if pe.parse(String(c["pre"])) == OK:
			pe.execute([], self, false)
	_t = 0.0
	var ex := Expression.new()
	if ex.parse(c["when"]) != OK:
		push_error("MONTAGE koşul okunamadı: " + str(c["when"]))
		return
	var limit: float = c.get("wait", 400.0)
	var ok := false
	while _t < limit:
		await _wait(0.1)
		var r: Variant = ex.execute([], self, false)
		if not ex.has_execute_failed() and r == true:
			ok = true
			break
	print("MONTAGE seg=%d ch=%s when=%s ok=%s t=%.1f id=%s" % [_seg, c["ch"], c["when"], ok, _t, c.get("id", "")])
	if not ok:
		return
	# Yönetilen mekanik koşuldan hemen sonra başlar (kara ekranda): uçuşta pencere açıldığında Nihat zaten havada
	_drive = c.get("drive", "")
	_drive_t = 0.0
	_drive_y0 = INF
	_steps = c.get("steps", [])
	_nohands = bool(c.get("nohands", false))
	_step_i = 0
	_pan = {}
	_walk_to = Vector3.INF
	await _wait(float(c.get("lead", 0.0)))
	# Pencere: gerçek hız, ses açık, kara kalkar (sert kesme), üstte başlık
	_skipping = false
	Engine.time_scale = minf(Engine.time_scale, 1.0)
	# Hızlı sarmada yarıda kalan önceki repliğin sesi (sessizde çalmaya devam ediyordu) pencereye taşmasın
	if _hud and is_instance_valid(_hud) and not _line_on:
		var vo = _hud.get("_voice")
		if vo is AudioStreamPlayer:
			(vo as AudioStreamPlayer).stop()
	_mute(false)
	_black.color.a = 0.0
	_in_window = true
	_line_on = false             # açık replik pencerede yeniden "on" yazılsın
	_mark("in")
	_cap.text = _tx(c["cap"])
	if _clean:
		_cap.self_modulate.a = 0.0
		print("MONTAGE cap seg=%d frame=%d text=%s" % [_seg, Engine.get_process_frames(), _cap.text.replace("\n", "|")])
	var ct := create_tween()
	ct.tween_property(_cap, "modulate:a", 1.0, 0.15)
	ct.tween_interval(2.4)
	ct.tween_property(_cap, "modulate:a", 0.0, 0.3)
	var dur: float = c["dur"] if _dur <= 0.0 else _dur
	var f0 := Engine.get_process_frames()
	var w0 := Time.get_ticks_msec()
	var real := func() -> float:
		# Kayıttaki süre: Fx'in ağır çekimi ve donması pencereyi uzatmaz/kısaltmaz
		return (Engine.get_process_frames() - f0) / _fps if _fps > 0.0 else (Time.get_ticks_msec() - w0) / 1000.0
	var next_shot := 0.0
	# until: pencereyi erken kapatan koşul (ör. done('D4A_HU_ARGUE_6')); sağlanınca tail saniye daha kayıt
	var until := Expression.new()
	var has_until := c.has("until") and until.parse(c["until"]) == OK
	var tail_left := -1.0
	while real.call() < dur:
		if has_until and tail_left < 0.0:
			var u: Variant = until.execute([], self, false)
			if not until.has_execute_failed() and u == true:
				tail_left = float(c.get("tail", 0.5))
				dur = minf(dur, real.call() + tail_left)
		await get_tree().process_frame
		if _shots != "" and real.call() >= next_shot:
			next_shot += float(OS.get_environment("SHOT_STEP")) if OS.has_environment("SHOT_STEP") else 1.0
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(_shots.path_join("s%02d_%04.1f.png" % [_seg, next_shot]))
	_mark("out")
	_in_window = false
	_end_drive()
	ct.kill()
	_cap.modulate.a = 0.0
	_black.color.a = 1.0
	_mute(true)


# ---------------------------------------------------------------- oyuncuyu yönetme (botu olmayan mekanikler)

## "fly": uçuşu açar, yükselir, ileri süzülür, yavaşça döner; ortada bir an görünmez olur
func _drive_step(p: Player, delta: float) -> void:
	_drive_t += delta
	if _nohands:
		for n in [p.hand, p.free_hand, p.get("_prop_item"), p.get("_held_model"), p.get("_remote_model")]:
			if n is Node3D and is_instance_valid(n):
				(n as Node3D).visible = false
	if _set == "story" and p.powers and p.powers.get("_layer") is CanvasLayer:
		(p.powers.get("_layer") as CanvasLayer).visible = false     # uçuş göstergesi, yer işaretleri (arayüz)
	if _drive == "fly" and p.powers:
		p.frozen = false
		if not p.powers.flying:
			p.powers.set_flying(true)
			_cloak_done = false
		if _drive_y0 == INF:
			_drive_y0 = p.global_position.y
		Input.action_press("move_forward")
		# Ordugâhın üstüne yükselip orada süzülür (GLIDE alçalır: koşu tuşu basılmaz)
		if p.global_position.y - _drive_y0 < 24.0:
			Input.action_press("jump")
		else:
			Input.action_release("jump")
		p.rotate_y(-0.22 * delta)
		p.camera.rotation.x = lerpf(p.camera.rotation.x, -0.12, clampf(delta * 2.0, 0.0, 1.0))
		if int(_drive_t * 2.0) != int((_drive_t - delta) * 2.0):
			print("MONTAGE fly t=%.1f y=%.1f" % [_drive_t, p.global_position.y - _drive_y0])
		if not _cloak_done and _drive_t > 6.5 and p.powers.can_cloak:
			_cloak_done = true
			p.powers.set_cloak(true)
			get_tree().create_timer(1.4).timeout.connect(func():
				if is_instance_valid(p) and p.powers:
					p.powers.set_cloak(false))


	elif _drive == "steps":
		_steps_tick(p, delta)
	elif _drive == "look_up":
		# Merdivende kamera yukarı: surun tepesi, düşen taş ve kaynar yağ kadrajda (botun bakışı duvara dönüktü)
		p.camera.rotation.x = lerpf(p.camera.rotation.x, 0.75, clampf(delta * 3.0, 0.0, 1.0))
	elif _drive == "level":
		# Bot yokuş inerken yere bakıyordu: kamera ufka (biraz aşağı) gelir, taşınan yük ve yol kadrajda
		p.camera.rotation.x = lerpf(p.camera.rotation.x, -0.12, clampf(delta * 3.0, 0.0, 1.0))


func _yaw_pitch(p: Player, at: Vector3) -> Vector2:
	var to := at - p.global_position
	var flat := Vector2(to.x, to.z).length()
	return Vector2(atan2(-to.x, -to.z), atan2(to.y - p.eye_height, flat))


## Zamanlı adımlar: ışınlama, bakış, yumuşak dönüş, amaçlı yürüyüş, betik çağrısı
func _steps_tick(p: Player, delta: float) -> void:
	while _step_i < _steps.size() and _drive_t >= float(_steps[_step_i].get("t", 0.0)):
		var s: Dictionary = _steps[_step_i]
		if s.has("on"):         # koşullu adım (ör. "said('BUR_FG_HIT_R')"): sağlanana dek sıradakiler de bekler
			var oe := Expression.new()
			if oe.parse(String(s["on"])) != OK:
				push_error("MONTAGE adım koşulu okunamadı: " + String(s["on"]))
			else:
				var ok: Variant = oe.execute([], self, false)
				if oe.has_execute_failed() or ok != true:
					break
		_step_i += 1
		if s.has("frozen"):
			p.frozen = bool(s["frozen"])
		if s.has("pos"):
			p.global_position = s["pos"]
			p.velocity = Vector3.ZERO
		if s.has("look"):
			_pan = {}
			var yp := _yaw_pitch(p, s["look"])
			p.rotation.y = yp.x
			p.camera.rotation = Vector3(yp.y, 0.0, 0.0)
		if s.has("pan"):
			var yp := _yaw_pitch(p, s["pan"][0])
			_pan = {"y0": p.rotation.y, "p0": p.camera.rotation.x, "y1": yp.x, "p1": yp.y, "t": 0.0, "d": float(s["pan"][1])}
		if s.has("aim"):        # [ifade (Node3D), yükseklik, sn]: düğüme yumuşak dönüş (yeri betikte belli olmayan kişi)
			var ae := Expression.new()
			if ae.parse(String(s["aim"][0])) == OK:
				var n: Variant = ae.execute([], self, false)
				if n is Node3D:
					var at: Vector3 = (n as Node3D).global_position + Vector3(0, float(s["aim"][1]), 0)
					var yp := _yaw_pitch(p, at)
					_pan = {"y0": p.rotation.y, "p0": p.camera.rotation.x, "y1": yp.x, "p1": yp.y, "t": 0.0, "d": float(s["aim"][2])}
		if s.has("walk"):
			_walk_to = s["walk"][0]
			_walk_mult = float(s["walk"][1]) if s["walk"].size() > 1 else 1.0
		if s.has("do"):
			var ex := Expression.new()
			if ex.parse(String(s["do"])) == OK:
				ex.execute([], self, false)
				if ex.has_execute_failed():
					push_error("MONTAGE adım çalışmadı: " + String(s["do"]))
			else:
				push_error("MONTAGE adım okunamadı: " + String(s["do"]))
	if not _pan.is_empty():
		_pan["t"] += delta
		var k := smoothstep(0.0, 1.0, clampf(_pan["t"] / maxf(_pan["d"], 0.01), 0.0, 1.0))
		p.rotation.y = lerp_angle(_pan["y0"], _pan["y1"], k)
		p.camera.rotation.x = lerpf(_pan["p0"], _pan["p1"], k)
		if k >= 1.0:
			_pan = {}
	if _walk_to != Vector3.INF:
		var to := _walk_to - p.global_position
		if Vector2(to.x, to.z).length() < 0.3:
			Input.action_release("move_forward")
			p.speed_mult = 1.0
			_walk_to = Vector3.INF
		else:
			p.speed_mult = _walk_mult
			if _pan.is_empty():
				p.rotation.y = lerp_angle(p.rotation.y, atan2(-to.x, -to.z), clampf(delta * 4.0, 0.0, 1.0))
			Input.action_press("move_forward")


## Adım yardımcıları: geçerli sahne; replikleri seslendirme süresince oynat
func sc() -> Node:
	return get_tree().current_scene


func unbag(id: String) -> bool:
	GameState.bag.erase(id)
	return true


func pace_on() -> bool:
	GameState.pace = true
	return true


## Koşul yardımcısı: oyuncu sahnede ve serbest
func loose() -> bool:
	var p := _player()
	return p != null and not p.frozen


func _end_drive() -> void:
	for a in ["move_forward", "jump", "sprint", "dive"]:
		Input.action_release(a)
	var p := _player()
	if p:
		p.speed_mult = 1.0
	_drive = ""
	_nohands = false
	_steps = []
	_walk_to = Vector3.INF


# ---------------------------------------------------------------- koşul yardımcıları (Expression)

func _player() -> Player:
	var s := get_tree().current_scene
	if s == null:
		return null
	var p = s.get("player")
	return p if p is Player and is_instance_valid(p) else null


func _nodes(cls: String) -> Array:
	var got: Array = _cache.get(cls, [])
	got = got.filter(func(n): return is_instance_valid(n))
	if got.is_empty() and get_tree().current_scene:
		for n in get_tree().current_scene.find_children("*", "", true, false):
			var sc: Script = n.get_script()
			if sc and sc.get_global_name() == cls:
				got.append(n)
		_cache[cls] = got
	return got


## cls sınıfından bir düğümün prop'u val mi (ör. on('Duel', 'active'))
func on(cls: String, prop: String, val: Variant = true) -> bool:
	for n in _nodes(cls):
		if n.get(prop) == val:
			return true
	return false


## Etkin ve boşta olmayan (doldurma/nişan adımında) top ya da tüfek
func busy(cls: String) -> bool:
	for n in _nodes(cls):
		if n.get("state") != null and str(n.get("state")) not in ["idle", "done", ""]:
			if n.get("active") == null or n.get("active") == true:
				return true
	return false


## Nihat'ın güçleri elde ve oyuncu serbest
func flyable() -> bool:
	var p := _player()
	return p != null and p.powers != null and p.powers.can_fly and not p.frozen and _t > 3.0


## Bölüm betiğindeki bir değişken (ör. sv('_stone_falling'))
func sv(name: String) -> Variant:
	var s := get_tree().current_scene
	return s.get(name) if s else null


## Bölüm betiğindeki bir düğüm sahnede ve görünür mü (ör. shown('_pole'))
func shown(name: String) -> bool:
	var n: Variant = sv(name)
	return n is Node3D and is_instance_valid(n) and (n as Node3D).is_visible_in_tree()


func ladder() -> bool:
	var p := _player()
	return p != null and p.ladder != null


func flying() -> bool:
	var p := _player()
	return p != null and p.powers != null and p.powers.flying


## Oyuncu en az secs saniyedir serbestçe yürüyor
func walking(secs: float) -> bool:
	return _walk_t >= secs


func after(secs: float) -> bool:
	return _t >= secs
