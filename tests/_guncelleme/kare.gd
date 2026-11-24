extends Node
## Güncelleyici kareleri (kanıt; CI'a girmez). Pencereli (xvfb) 1280×720, TR ve EN:
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --rendering-driver opengl3 --resolution 1280x720 \
##     res://tests/_guncelleme/kare.tscn -- --kareler=docs/_kanit_guncelleyici
## Ağa çıkılmaz: güncelleyicinin durumu sahte bildirimle elle kurulur (editörde denetim zaten kapalı).

var _dir := "docs/_kanit_guncelleyici"


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--kareler="):
			_dir = a.trim_prefix("--kareler=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://").path_join(_dir))
	get_window().size = Vector2i(1280, 720)
	var g: Guncelleyici = GameState.guncelleyici
	await get_tree().process_frame
	g.yerel = GameState.version_text()
	g.manifest = Guncelleyici.manifest_coz(JSON.stringify({"surum": "0.99.127", "motor": "4.4.1",
		"windows": {"ad": "GercekTarihBuDegil.exe", "boyut": 1191234567, "sha256": "0".repeat(64)},
		"linux": {"ad": "GercekTarihBuDegil.x86_64", "boyut": 1187654321, "sha256": "0".repeat(64)}}))
	g.girdi = g.manifest["linux"]
	g._denetlendi = true
	var notlar := {}
	var cl := FileAccess.get_file_as_string(OS.get_environment("HOME").path_join("is/changelog.json"))
	var js := JSON.new()
	if js.parse(cl) == OK and js.data is Dictionary:
		notlar = (js.data as Dictionary).get("0.99.125", {})
	for loc in ["tr", "en"]:
		GameState.locale = loc
		TranslationServer.set_locale(loc)
		var menu := GameMenu.new("main")
		menu.title_font = load("res://assets/fonts/title.ttf") if ResourceLoader.exists("res://assets/fonts/title.ttf") else null
		add_child(menu)
		await _bekle(40)
		_kur(g, Guncelleyici.D.YENI, "", "")
		await _cek("bant_yeni_%s" % loc)
		_kur(g, Guncelleyici.D.YENI, "", String(notlar.get(loc, "…")))
		await _cek("bant_ne_degisti_%s" % loc)
		g.toplam = 1187654321
		g.indirilen = 486123456
		g.kalan_sn = 412.0
		_kur(g, Guncelleyici.D.INDIRILIYOR, "", "")
		await _cek("ilerleme_%s" % loc)
		_kur(g, Guncelleyici.D.HAZIR, "", "")
		await _cek("hazir_%s" % loc)
		_kur(g, Guncelleyici.D.YENI, "UI_GUNC_N_MOTOR", "")
		await _cek("sayfa_yolu_motor_%s" % loc)
		_kur(g, Guncelleyici.D.SAYFA, "UI_GUNC_N_BOZUK", "")
		await _cek("hata_dogrulama_%s" % loc)
		menu.show_settings()
		await _bekle(10)
		for c: CheckButton in menu.find_children("*", "CheckButton", true, false):
			if c.text == tr("UI_GUNC_AYAR"):
				var sc := menu.find_children("*", "ScrollContainer", true, false)[0] as ScrollContainer
				c.grab_focus()
				await _bekle(4)
				sc.ensure_control_visible(c)
		await _cek("ayar_%s" % loc)
		menu.queue_free()
		await _bekle(4)
	print("GUNCKARE BITTI %s" % _dir)
	get_tree().quit(0)


func _kur(g: Guncelleyici, d: int, n: String, notu: String) -> void:
	g.durum = d
	g.neden = n
	g.degisiklik = notu
	g.gizli = false
	g._yayinla()


func _bekle(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _cek(ad: String) -> void:
	await _bekle(8)
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var yol := ProjectSettings.globalize_path("res://").path_join(_dir).path_join(ad + ".jpg")
	img.save_jpg(yol, 0.88)
	print("GUNCKARE %s %dx%d" % [yol, img.get_width(), img.get_height()])
