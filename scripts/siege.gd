class_name Siege
extends RefCounted
## Perde IV · Hasar Tespit (docs/SIEGE.md): kuşatma bölümlerinin ortak parçaları.
## Tolga, Büro'nun geçici tanığı olarak kuşatmanın olaylarını sırayla "tespit eder": her bölümün bir
## tespit karesi (telefonla doğru anda doğru şeyin fotoğrafı) ve sonunda Hasar Tespit Dosyası'na bir sayfası vardır.

const FIRST := 17
const LAST := 27
## Kuşatmanın oynanış (tarih) sırası. İç kimlikler sahne adlarıdır, tarih sırası değil: sonradan eklenenler
## 28 (11 Nisan, Şahi'nin ilk atışı), 29 (20 Nisan deniz savaşı), 30 (12 Mayıs Blakherna), 31 (30 Mayıs–1 Haziran).
## Bir tarafta sahnesi olmayan bölüm o taraf için atlanır (28o ve 31o yalnız Osmanlı tarafındadır).
const ORDER := [33, 34, 35, 28, 37, 29, 17, 18, 19, 20, 30, 21, 22, 23, 24, 25, 32, 26, 38, 39, 31, 27]
## Kuşatmadan önceki son bölümün ekrandaki numarası (Perde III'ün sonu: BÖLÜM 12)
const NUMBER_BASE := 12
## Kuşatmadan sonra ana hikâyenin bölümleri (ekran numaraları kuşatmanın uzunluğuna göre kayar)
const AFTER := [13, 14, 15]


const PROLOGUE := "res://scenes/chapter17.tscn"


## Tanığın tarafı: "B" (Bizans kayıtları) ya da "O" (Osmanlı kayıtları). Büro'da seçilir.
static func side() -> String:
	return String(GameState.flags.get("siege_side", "B"))


## Osmanlı tarafında bölüm başında "Önceki bölümde…", akış şemasında "Sırada…" satırı (kind: "PREV" / "NEXT").
## Anahtar: UI_RECAP_<sahne kimliği>_<kind> (chapter26o → 26O, chapter25 → 25). Yoksa ya da Bizans tarafıysa "".
static func recap(scene: String, kind: String) -> String:
	if side() != "O":
		return ""
	var f := scene.get_file().get_basename()
	if not f.begins_with("chapter"):
		return ""
	var key := GameState.line_variant("UI_RECAP_%s_%s" % [f.trim_prefix("chapter").to_upper(), kind])
	var t := TranslationServer.translate(key)
	return "" if t == key else String(t)


## Bölümün bu taraftaki sahnesi: chapterNo (Osmanlı) / chapterNb (Bizans) varsa o, yoksa ortak chapterN.
static func scene_path(ch: int, for_side := "") -> String:
	var sd := for_side if for_side != "" else side()
	var own := "res://scenes/chapter%d%s.tscn" % [ch, "o" if sd == "O" else "b"]
	if ResourceLoader.exists(own):
		return own
	return "res://scenes/chapter%d.tscn" % ch


## Kuşatmanın sıradaki bölümü; kuşatma bittiyse "" (çağıran dönüş yoluna gider).
static func next_path(ch: int) -> String:
	var i := ORDER.find(ch)
	for k in range(i + 1, ORDER.size()):
		if _plays(ORDER[k], true):
			return scene_path(ORDER[k])
	return ""


## Bu taraf bu bölümü oynar mı. Şehir düşmediyse fetihten sonraki bölümler (31: Kayser'in sarayı, 27: Galata'nın
## ahitnamesi) yazılmaz; held_check false ise bu koşula bakılmaz (menüler ve sayfa sayısı bütün listeyi gösterir).
static func _plays(ch: int, held_check := false, for_side := "") -> bool:
	if held_check and ch in [38, 39, 31, 27] and GameState.flags.get("siege_held", false):
		return false
	return ResourceLoader.exists(scene_path(ch, for_side))


## Bu tarafta (ya da verilen tarafta) oynanan kuşatma bölümleri, oynanış sırasıyla.
static func chapters(for_side := "") -> Array[int]:
	var out: Array[int] = []
	for ch: int in ORDER:
		if _plays(ch, false, for_side):
			out.append(ch)
	return out


## Büro'dan sonra gidilen ilk bölüm.
static func first_path() -> String:
	return scene_path(chapters()[0])


## Tespit dosyasının sayfa sayısı (bu tarafın bölüm sayısı).
static func page_total() -> int:
	return chapters().size()


## Bölümün bu taraftaki sırası (1'den); kuşatma bölümü değilse 0.
static func index_of(ch: int) -> int:
	return chapters().find(ch) + 1


## Ekrandaki bölüm numarası: sahne yolundan (chapter17o.tscn → 17). Kuşatma bölümleri Perde III'ün ardından sırayla
## numaralanır; kuşatmadan sonraki ana hikâye bölümleri (13, 14, 15) kuşatmanın bu taraftaki uzunluğu kadar kayar.
## Bilinmeyen sahne: 0.
static func number(scene: String) -> int:
	var f := scene.get_file().get_basename()
	if not f.begins_with("chapter"):
		return 0
	var digits := ""
	for c in f.trim_prefix("chapter"):
		if c >= "0" and c <= "9":
			digits += c
		else:
			break
	if digits == "":
		return 0
	# Tarafa özgü sahne (chapter28o, chapter18b) kendi tarafının listesinde sayılır (taraf bayrağı yokken de)
	var rest := f.trim_prefix("chapter" + digits)
	var sd := "O" if rest == "o" else ("B" if rest == "b" else "")
	return number_of(int(digits), sd)


## İç kimliğin ekrandaki numarası (kuşatma ya da kuşatmadan sonraki ana hikâye bölümü değilse 0).
static func number_of(ch: int, for_side := "") -> int:
	var list := chapters(for_side)
	var i := list.find(ch) + 1
	if i > 0:
		return NUMBER_BASE + i
	var a := AFTER.find(ch)
	if a >= 0:
		return NUMBER_BASE + list.size() + a + 1
	return 0


## Metindeki "{N}" yerine geçerli sahnenin ekran numarası (başlık kartları ve akış şeması başlığı buradan geçer).
static func fill_number(text: String, scene := "") -> String:
	if not text.contains("{N"):
		return text
	# {N13} {N14} {N15}: kuşatmadan sonraki ana hikâye bölümlerinin numarası ("Sıradaki: Bölüm {N13} — …")
	for k: int in AFTER:
		text = text.replace("{N%d}" % k, str(number_of(k)))
	if not text.contains("{N}"):
		return text
	if scene == "":
		var tree := Engine.get_main_loop() as SceneTree
		if tree and tree.current_scene:
			scene = tree.current_scene.scene_file_path
	var n := number(scene)
	return text.replace("{N}", str(n) if n > 0 else "")


## Kuşatma ana hikâyenin içindedir: Bölüm 13'e (ya da tutuklanan Tolga için 14'e) giden her yol, kuşatma bu
## oyunda henüz oynanmadıysa önce Büro'ya (Bölüm 17) uğrar. Büro zamanın dışındadır: Tolga bir ay tanıklık eder ve
## ayrıldığı ana (26 Nisan öğlesi; 12B'de gün batımı) geri bırakılır; Hikmet'in penceresi kaçmaz.
## from: Büro'nun Tolga'yı nereden aldığı ("audience" huzurdan, "walls" 12B surları, "arrest", "elsewhere").
static func gate(next: String, from := "audience") -> String:
	if GameState.flags.get("siege_done", false):
		return next
	GameState.flags["bureau_from"] = from
	GameState.flags["siege_return"] = next
	GameState.flags.erase("siege_bureau_done")
	return PROLOGUE


## Akış şemasının "Sıradaki" satırı: Bölüm 13/14'e giden yol kuşatma oynanmadıysa önce Büro'ya uğrar.
static func next_line(key: String) -> String:
	if GameState.flags.get("siege_done", false):
		return TranslationServer.translate(key)
	return TranslationServer.translate("UI_FLOW_NEXT_SIEGE")


## Kuşatma bitince hikâyenin döneceği sahne.
static func return_path() -> String:
	return String(GameState.flags.get("siege_return", "res://scenes/chapter13.tscn"))


## Kuşatmanın hükmü (Bölüm 26, 29 Mayıs şafağı). Perde II'de Bizans'a yardım eden Tolga (Heyet, Direniş ≥ 1)
## bir değişiklik iddia etmişti; 12B'de İmparator "Yetecek mi?" diye sordu. Cevabı kuşatma verir:
##   Tolga Bizans tarafındaysa ve şafakta Giustiniani vurulmazsa (Tolga uyarır ve İmparator'un güveni ona geçmiştir,
##   ya da powerbank "zırh ısıtıcısı" kurşunu tutar) son hücum püskürtülür, şehir o sabah düşmez. Erteleme:
##     23.2 (yaratıcı tercüme: teslim teklifi evrakta kaybolur)                  → W12 Ertelendi
##     gedik (20.1/20.2) + lağım (21.1) + kule (22.1), üçü de Tolga'nın eliyle    → W11 1455 (kuşatma donanımı kalmadı)
##     yalnız şafak tuttu                                                          → W10 1454
##   Tutmazsa (Osmanlı tarafında tanıklık da dahil) fetih 1453'te olur: dünya W1'e döner, final "Bir Akşam".
## Direniş 0 ise iddia yoktur: Perde II'nin dünyası olduğu gibi kalır.
static func has_claim() -> bool:
	return int(GameState.flags.get("direnc", 0)) >= 1


## Kadri'nin mutfağına Perde II'de iyilik edildi mi (6a.1 yamaklık, 10Z.1 ziyafet ya da termos kaftanla takasta
## Kadri'de) ve mutfak 10Z'de Tolga yüzünden yanmadı mı. Osmanlı tarafında Kadri ve yamakları yardıma gelir (17o, 26o).
## 6a.4 tek başına sayılmaz: kaftan pazar yolunda tüccardan da gelir (keçi, yüzük, mektup), Kadri hiç görülmeden.
static func kadri_ally() -> bool:
	var o10 := str(GameState.chapter_outcomes.get(10, ""))
	if o10 == "10Z.2":
		return false
	return str(GameState.chapter_outcomes.get(6, "")) == "6a.1" or o10 == "10Z.1" or GameState.given_to("thermos") == "kadri"


## Bu kuşatma sayfasının sonucu ("34O.2"); oynanmadıysa "". Dallanma v3 (docs/BRANCHING_V3.md): kötü iş de iyi iş de
## sonraki sayfada hatırlanır; okunmayan sonuç tests/check_outcomes.py'de hata.
static func outcome(ch: int) -> String:
	return str(GameState.chapter_outcomes.get(ch, ""))


## Şafakta Giustiniani'nin vurulmasını önleyebilir mi (uyarının dinlenmesi için İmparator'un güveni gerekir)?
static func can_hold() -> bool:
	return side() == "B" and has_claim()


## Şafak tutarsa yazılacak dünya (Büro'daki alarmda kapının yıl yazısı da buna döner).
static func pending_world(held: bool) -> String:
	if not held:
		return "W1"
	var o := GameState.chapter_outcomes
	if o.get(23, "") == "23.2":
		return "W12"
	if o.get(20, "") in ["20.1", "20.2"] and o.get(21, "") == "21.1" and o.get(22, "") == "22.1":
		return "W11"
	return "W10"


static func resolve(held: bool) -> String:
	var f := GameState.flags
	f["siege_held"] = held
	if not has_claim():
		return String(f.get("world10", ""))
	var w := pending_world(held)
	f["byz_reasserted"] = not held
	f["world10"] = w
	return w


## Dosyaya sayfa: fotoğraf yolu (yoksa ""), Tolga'nın notu (çeviri anahtarı).
static func record(ch: int, photo: String, note_key: String) -> void:
	var d: Dictionary = GameState.flags.get("dossier", {})
	d[str(ch)] = {"photo": photo, "note": note_key}
	GameState.flags["dossier"] = d


static func page_count() -> int:
	return (GameState.flags.get("dossier", {}) as Dictionary).size()


## Hasar Tespit Tutanağı: kâğıt sayfa, fotoğraf, not ve "KAYNAK" damgası. Etkileşim tuşuyla ya da 7 sn sonra kapanır.
static func show_page(hud: Hud, ch: int) -> void:
	var d: Dictionary = (GameState.flags.get("dossier", {}) as Dictionary).get(str(ch), {})
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.05, 0.07, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	var paper := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("efe6cf")
	sb.border_color = Color("2a2622")
	sb.set_border_width_all(2)
	sb.set_content_margin_all(26)
	paper.add_theme_stylebox_override("panel", sb)
	paper.custom_minimum_size = Vector2(820, 0)
	paper.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	paper.rotation = -0.012
	root.add_child(paper)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	paper.add_child(col)
	var ink := Color("2a2622")
	var head := _l(hud.tr("UI_SIEGE_PAGE_HEAD") % [index_of(ch), page_total()], 15, Color("7a6f60"))
	col.add_child(head)
	col.add_child(_l(hud.tr("SIEGE_DATE_%d" % ch), 26, ink))
	col.add_child(_l(hud.tr("SIEGE_EV_%d" % ch), 18, Color("4a4038")))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	col.add_child(row)
	var pic := PanelContainer.new()
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color("f8f4ea")
	psb.set_content_margin_all(8)
	pic.add_theme_stylebox_override("panel", psb)
	pic.rotation = 0.03
	row.add_child(pic)
	var photo: String = d.get("photo", "")
	if photo != "" and FileAccess.file_exists(photo):
		var tex := TextureRect.new()
		tex.texture = ImageTexture.create_from_image(Image.load_from_file(photo))
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.custom_minimum_size = Vector2(340, 214)
		pic.add_child(tex)
	else:
		var none := _l(hud.tr("UI_SIEGE_NO_PHOTO"), 16, Color("7a6f60"))
		none.custom_minimum_size = Vector2(340, 214)
		none.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		none.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pic.add_child(none)
	var note := _l(GameState.fill_outcomes(hud.tr(String(d.get("note", "")))), 18, ink)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size = Vector2(380, 0)
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(note)
	col.add_child(_l(hud.tr("UI_SIEGE_PAGE_SIGN"), 14, Color("7a6f60")))
	# Damga
	var stamp := _l(hud.tr("UI_SIEGE_STAMP"), 40, Color("c8262f"))
	stamp.add_theme_color_override("font_outline_color", Color("c8262f"))
	stamp.add_theme_constant_override("outline_size", 2)
	root.add_child(stamp)
	paper.modulate.a = 0.0
	stamp.modulate.a = 0.0
	await hud.get_tree().process_frame
	if not hud.is_inside_tree():
		root.queue_free()
		return
	var vs := hud.get_viewport().get_visible_rect().size
	paper.position = (vs - paper.size) * 0.5
	stamp.pivot_offset = stamp.size * 0.5
	stamp.position = paper.position + Vector2(paper.size.x - stamp.size.x - 40, paper.size.y - stamp.size.y - 30)
	stamp.rotation = -0.22
	if GameState.autotest:
		root.queue_free()
		return
	Audio.sfx("paper_tear", -14.0, 1.4)
	var tw := hud.create_tween()
	tw.tween_property(paper, "modulate:a", 1.0, 0.4)
	await tw.finished
	await hud.get_tree().create_timer(0.8).timeout
	stamp.scale = Vector2.ONE * 2.2
	var st := hud.create_tween().set_parallel()
	st.tween_property(stamp, "modulate:a", 0.9, 0.12)
	st.tween_property(stamp, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Audio.sfx("stamp", -2.0)
	var t := 0.0
	while t < 7.0:
		await hud.get_tree().process_frame
		t += hud.get_process_delta_time()
		if t > 1.2 and (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept")):
			break
	var out := hud.create_tween()
	out.tween_property(root, "modulate:a", 0.0, 0.35)
	await out.finished
	root.queue_free()


static func _l(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l
