extends Node
## GUNCELLEMECHECK (G16): oyunun kendini güncellemesi, ağsız.
##  - sürüm karşılaştırma tablosu (eşit/büyük/küçük, v önekli, 0.99.9-0.99.10, 0.99-0.100, bozuk)
##  - bildirim (guncelleme.json) ayrıştırma: eksik alan, yanlış tür, kötü "ad"
##  - platform seçimi, önkoşullar (motor uyuşmazlığı, yazılamaz klasör, boş yer) → sayfa yolu
##  - yerel kaynak yalnız 127.0.0.1/localhost
##  - ~/is/ altında sahte dosyalarla değiştirme, ikinci adım bozukken geri alma, başlatma geri alması, açılış temizliği
##  - sahte bildirimle denetim akışı (yeni / yeni yok / 404 / motor uyuşmazlığı)
##  - bant: TR ve EN, her durumda 1280×720 içinde ve menü sütununun sağında
##   godot --headless --path . res://tests/guncelleme_check.tscn   → "GUNCELLEMECHECK PASS"

var _hata := 0
var _sayi := 0


func _ready() -> void:
	GameState.autotest = true          # ağ isteği atılmaz (Guncelleyici.etkin)
	get_window().size = Vector2i(1280, 720)
	_surumler()
	_manifestler()
	_onkosullar()
	_kaynaklar()
	_dosyalar()
	await _akis()
	await _bant()
	print("GUNCELLEMECHECK %s denetim=%d hata=%d" % ["PASS" if _hata == 0 else "FAIL", _sayi, _hata])
	get_tree().quit(0 if _hata == 0 else 1)


func _bak(kosul: bool, ne: String) -> void:
	_sayi += 1
	if not kosul:
		_hata += 1
		print("GUNCELLEMECHECK hata: " + ne)


func _surumler() -> void:
	var tablo := [
		["0.99.125", "0.99.125", 0], ["0.99.126", "0.99.125", 1], ["0.99.124", "0.99.125", -1],
		["v0.99.126", "0.99.125", 1], ["V0.99.125", "0.99.125", 0], ["0.99.10", "0.99.9", 1],
		["0.99.9", "0.99.10", -1], ["0.100", "0.99", 1], ["0.100.0", "0.99.999", 1], ["0.99", "0.99.0", 0],
		["1.0.0", "0.99.125", 1], [" 0.99.127\n", "0.99.125", 1],
		["", "0.99.125", -2], ["abc", "0.99.125", -2], ["0.99.x", "0.99.1", -2], ["0..1", "0.1", -2],
		["0.99.-1", "0.99.1", -2], ["0.99.125", "", -2], ["1.2.3-beta", "1.2.2", -2], ["vv1.0", "0.1", -2],
	]
	for t in tablo:
		var r := Guncelleyici.surum_karsilastir(t[0], t[1])
		_bak(r == t[2], "surum %s ? %s = %d (beklenen %d)" % [t[0], t[1], r, t[2]])
	_bak(Guncelleyici.yeni_mi("0.99.10", "0.99.9"), "yeni_mi 0.99.10 > 0.99.9")
	_bak(not Guncelleyici.yeni_mi("bozuk", "0.99.9"), "bozuk uzak = yeni yok")
	_bak(not Guncelleyici.yeni_mi("0.99.125", "0.99.125"), "eşit = yeni yok")
	_bak(not Guncelleyici.yeni_mi("0.99.124", "0.99.125"), "eski = yeni yok")


const SHA := "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"


func _m(over: Dictionary = {}) -> String:
	var d := {"surum": "0.99.127", "motor": "4.4.1",
		"windows": {"ad": "GercekTarihBuDegil.exe", "boyut": 1190000000, "sha256": SHA},
		"linux": {"ad": "GercekTarihBuDegil.x86_64", "boyut": 1180000000.0, "sha256": SHA.to_upper()}}
	d.merge(over, true)
	return JSON.stringify(d)


func _manifestler() -> void:
	var m := Guncelleyici.manifest_coz(_m())
	_bak(m.get("surum") == "0.99.127" and m.get("motor") == "4.4.1", "geçerli bildirim")
	_bak(m.has("windows") and m.has("linux"), "iki platform girdisi")
	_bak(m.has("linux") and m["linux"]["boyut"] is int and int(m["linux"]["boyut"]) == 1180000000, "boyut float → int")
	_bak(m.has("linux") and m["linux"]["sha256"] == SHA, "sha256 küçük harfe")
	_bak(Guncelleyici.manifest_coz("").is_empty(), "boş metin")
	_bak(Guncelleyici.manifest_coz("[1,2]").is_empty(), "dizi")
	_bak(Guncelleyici.manifest_coz("{bozuk").is_empty(), "bozuk JSON")
	_bak(Guncelleyici.manifest_coz(JSON.stringify({"motor": "4.4.1"})).is_empty(), "surum eksik")
	_bak(Guncelleyici.manifest_coz(_m({"surum": 99})).is_empty(), "surum sayı")
	_bak(Guncelleyici.manifest_coz(_m({"surum": "yeni"})).is_empty(), "surum bozuk")
	_bak(Guncelleyici.manifest_coz(_m({"surum": "v0.99.127"})).get("surum") == "0.99.127", "surum v önekli")
	_bak(Guncelleyici.manifest_coz(_m({"motor": 4.4})).get("motor") == "", "motor yanlış tür → boş")
	# G24 parçalı güncelleme: platform girdisindeki "parca" (liste adı, ad kuralıyla); yoksa/bozuksa alan düşer (tam indirme)
	var gp := {"ad": "GercekTarihBuDegil.x86_64", "boyut": 10, "sha256": SHA, "parca": "GercekTarihBuDegil.x86_64.parca.json"}
	var mp := Guncelleyici.manifest_coz(_m({"linux": gp}))
	_bak(mp.has("linux") and String(mp["linux"].get("parca", "")) == "GercekTarihBuDegil.x86_64.parca.json", "parca listesi adı okunur")
	_bak(not (Guncelleyici.manifest_coz(_m())["linux"] as Dictionary).has("parca"), "parca yok → alan yok (tam indirme)")
	for kp: Variant in ["../x.parca.json", "alt/x.json", "C:x.json", "", 5]:
		var g2 := gp.duplicate()
		g2["parca"] = kp
		var m2 := Guncelleyici.manifest_coz(_m({"linux": g2}))
		_bak(m2.has("linux") and not (m2["linux"] as Dictionary).has("parca"), "bozuk parca adı düşer: %s" % str(kp))
	var kotu := [
		{"ad": "../GercekTarihBuDegil.exe", "boyut": 10, "sha256": SHA},
		{"ad": "alt/GercekTarihBuDegil.exe", "boyut": 10, "sha256": SHA},
		{"ad": "alt\\x.exe", "boyut": 10, "sha256": SHA},
		{"ad": "C:x.exe", "boyut": 10, "sha256": SHA},
		{"ad": "", "boyut": 10, "sha256": SHA},
		{"ad": " x.exe", "boyut": 10, "sha256": SHA},
		{"ad": 5, "boyut": 10, "sha256": SHA},
		{"ad": "x.exe", "boyut": "10", "sha256": SHA},
		{"ad": "x.exe", "boyut": -1, "sha256": SHA},
		{"ad": "x.exe", "boyut": 10.5, "sha256": SHA},
		{"ad": "x.exe", "sha256": SHA},
		{"ad": "x.exe", "boyut": 10, "sha256": "abc"},
		{"ad": "x.exe", "boyut": 10, "sha256": SHA.replace("b", "g")},
		{"ad": "x.exe", "boyut": 10},
		"x.exe",
	]
	for k in kotu:
		var mm := Guncelleyici.manifest_coz(_m({"windows": k}))
		_bak(not mm.has("windows") and mm.has("linux"), "kötü girdi düşmeli: %s" % str(k))


func _onkosullar() -> void:
	_bak(Guncelleyici.platform() == "linux", "bu makine linux (platform=%s)" % Guncelleyici.platform())
	_bak(Guncelleyici.motor_surumu() == "4.4.1", "motor 4.4.1 (%s)" % Guncelleyici.motor_surumu())
	_bak(Guncelleyici.motor_norm("4.5") == "4.5.0" and Guncelleyici.motor_norm("4.4.1") == "4.4.1", "motor_norm")
	_bak(Guncelleyici.motor_norm("4.4.1.2") == "" and Guncelleyici.motor_norm("dört") == "", "motor_norm bozuk")
	var m := Guncelleyici.manifest_coz(_m())
	var bol := 10 * 1000 * 1000 * 1000
	_bak(Guncelleyici.onkosul(m, "linux", "4.4.1", true, bol) == "", "linux tamam")
	_bak(Guncelleyici.onkosul(m, "windows", "4.4.1", true, bol) == "", "windows tamam")
	_bak(Guncelleyici.onkosul(m, "macos", "4.4.1", true, bol) == "UI_GUNC_N_PLATFORM", "macos → sayfa")
	_bak(Guncelleyici.onkosul(m, "", "4.4.1", true, bol) == "UI_GUNC_N_PLATFORM", "bilinmeyen platform → sayfa")
	var yalniz_linux := Guncelleyici.manifest_coz(_m({"windows": {"ad": "../x"}}))
	_bak(Guncelleyici.onkosul(yalniz_linux, "windows", "4.4.1", true, bol) == "UI_GUNC_N_PLATFORM", "girdisiz platform → sayfa")
	_bak(Guncelleyici.onkosul(m, "linux", "4.5.0", true, bol) == "UI_GUNC_N_MOTOR", "motor uyuşmazlığı → sayfa")
	var m45 := Guncelleyici.manifest_coz(_m({"motor": "4.5"}))
	_bak(Guncelleyici.onkosul(m45, "linux", "4.5.0", true, bol) == "", "4.5 = 4.5.0")
	_bak(Guncelleyici.onkosul(m45, "linux", "4.4.1", true, bol) == "UI_GUNC_N_MOTOR", "4.5 ≠ 4.4.1")
	var mbos := Guncelleyici.manifest_coz(_m({"motor": ""}))
	_bak(Guncelleyici.onkosul(mbos, "linux", "4.4.1", true, bol) == "UI_GUNC_N_MOTOR", "motor yok → sayfa")
	_bak(Guncelleyici.onkosul(m, "linux", "4.4.1", false, bol) == "UI_GUNC_N_YAZMA", "yazılamaz → sayfa")
	_bak(Guncelleyici.onkosul(m, "linux", "4.4.1", true, 1200000000) == "UI_GUNC_N_YER", "yer az (×1,1) → sayfa")
	_bak(Guncelleyici.onkosul(m, "linux", "4.4.1", true, 1300000000) == "", "yer yeter")
	_bak(Guncelleyici.onkosul(m, "linux", "4.4.1", true, 0) == "", "yer bilinmiyor → engel değil")
	_bak(Guncelleyici.onkosul(m, "linux", "4.4.1", true, bol, false) == "UI_GUNC_N_GELISTIRME", "paket değil → sayfa")
	_bak(Guncelleyici.boyut_metni(1190000000, true) == "1,2 GB" and Guncelleyici.boyut_metni(1190000000, false) == "1.2 GB",
		"boyut metni %s" % Guncelleyici.boyut_metni(1190000000, true))


func _kaynaklar() -> void:
	for u in ["http://127.0.0.1:8000/guncelleme.json", "http://localhost:9/x.json", "http://127.0.0.1/g.json"]:
		_bak(Guncelleyici.kaynak_gecerli(u), "kaynak kabul: " + u)
	for u in ["https://127.0.0.1:8000/g.json", "http://127.0.0.1.ornek.com/g.json", "http://10.0.0.1/g.json",
			"http://127.0.0.1:80@ornek.com/g.json", "file:///etc/passwd", "http://localhost.ornek.com/", "ftp://127.0.0.1/"]:
		_bak(not Guncelleyici.kaynak_gecerli(u), "kaynak red: " + u)


func _yaz(yol: String, metin: String) -> void:
	var f := FileAccess.open(yol, FileAccess.WRITE)
	f.store_string(metin)
	f.close()


func _oku(yol: String) -> String:
	return FileAccess.get_file_as_string(yol) if FileAccess.file_exists(yol) else "<yok>"


func _dosyalar() -> void:
	var dir := OS.get_environment("HOME").path_join("is/gunc_birim")
	DirAccess.make_dir_recursive_absolute(dir)
	var exe := dir.path_join("GercekTarihBuDegil.x86_64")
	for s in ["", ".eski", ".yeni"]:
		if FileAccess.file_exists(exe + s):
			DirAccess.remove_absolute(exe + s)
	_bak(Guncelleyici.yazilir_mi(dir), "~/is yazılabilir")
	_bak(not Guncelleyici.yazilir_mi("/proc"), "/proc yazılamaz")
	_bak(Guncelleyici.bos_yer(dir) > 0, "boş yer okunuyor")
	# 1) .yeni yok: hiçbir şeye dokunulmaz
	_yaz(exe, "ESKI")
	_bak(Guncelleyici.dosyalari_degistir(exe) != "" and _oku(exe) == "ESKI", ".yeni yokken exe yerinde")
	# 2) başarılı değiştirme
	_yaz(exe + ".yeni", "YENI")
	_bak(Guncelleyici.dosyalari_degistir(exe) == "", "değiştirme başarılı")
	_bak(_oku(exe) == "YENI" and _oku(exe + ".eski") == "ESKI" and not FileAccess.file_exists(exe + ".yeni"),
		"değiştirmeden sonra exe=YENI .eski=ESKI .yeni yok (%s/%s)" % [_oku(exe), _oku(exe + ".eski")])
	# 3) açılış temizliği .eski'yi siler (paket kipinde); paket değilken dokunmaz
	Guncelleyici.acilis_temizligi(exe, false)
	_bak(FileAccess.file_exists(exe + ".eski"), "paket dışında temizlik yok")
	Guncelleyici.acilis_temizligi(exe, true)
	_bak(not FileAccess.file_exists(exe + ".eski") and _oku(exe) == "YENI", ".eski temizlendi, exe yerinde")
	# 4) ikinci adım bozuk: geri alınır, eski exe (şimdiki YENI) yerinde
	_yaz(exe + ".yeni", "YENI2")
	Guncelleyici.sinama_ikinci_adim_bozuk = true
	var r := Guncelleyici.dosyalari_degistir(exe)
	Guncelleyici.sinama_ikinci_adim_bozuk = false
	_bak(r == "UI_GUNC_N_DEGISTIRME", "ikinci adım bozuk → hata")
	_bak(_oku(exe) == "YENI" and not FileAccess.file_exists(exe + ".eski"), "geri alındı: exe yerinde, .eski yok (%s)" % _oku(exe))
	# 5) eski .eski kalmışsa önce silinir, değiştirme sürer
	_yaz(exe + ".eski", "ARTIK")
	_bak(Guncelleyici.dosyalari_degistir(exe) == "" and _oku(exe) == "YENI2" and _oku(exe + ".eski") == "YENI",
		"artık .eski silinip değiştirildi")
	# 6) yeni süreç başlatılamadı: geri al → exe eski, yeni .yeni olarak kenarda
	Guncelleyici.baslatma_geri_al(exe)
	_bak(_oku(exe) == "YENI" and _oku(exe + ".yeni") == "YENI2" and not FileAccess.file_exists(exe + ".eski"),
		"başlatma geri alındı")
	# 7) yarım .yeni: on dakikadan eskiyse silinir, tazeyse (başka örnek indiriyor) kalır
	Guncelleyici.acilis_temizligi(exe, true)
	_bak(FileAccess.file_exists(exe + ".yeni"), "taze .yeni kalır")
	OS.execute("touch", ["-d", "20 minutes ago", exe + ".yeni"])
	Guncelleyici.acilis_temizligi(exe, true)
	_bak(not FileAccess.file_exists(exe + ".yeni") and _oku(exe) == "YENI", "eski yarım .yeni silindi")
	# 8) özet (iş parçacığındaki işlevin kendisi)
	_yaz(exe + ".yeni", "abc")
	_bak(Guncelleyici._ozet(exe + ".yeni") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", "sha256(abc)")
	for s in ["", ".eski", ".yeni"]:
		if FileAccess.file_exists(exe + s):
			DirAccess.remove_absolute(exe + s)
	DirAccess.remove_absolute(dir)


func _akis() -> void:
	var ok := PackedStringArray()
	var cases := [
		[200, _m(), Guncelleyici.D.YENI, "UI_GUNC_N_GELISTIRME"],     # editörde: yeni var ama yerinde güncelleme yok
		[200, _m({"motor": "4.5.0"}), Guncelleyici.D.YENI, "UI_GUNC_N_MOTOR"],
		[200, _m({"surum": "0.0.1"}), Guncelleyici.D.BOS, ""],
		[200, "{bozuk", Guncelleyici.D.BOS, ""],
		[404, "Not Found", Guncelleyici.D.BOS, ""],
	]
	for c in cases:
		var g := Guncelleyici.new()
		g.yerel = "0.99.125"
		add_child(g)
		g._denetlendi = true
		g._denetim_bitti(HTTPRequest.RESULT_SUCCESS, c[0], ok, (c[1] as String).to_utf8_buffer())
		_bak(g.durum == c[2] and g.neden == c[3], "akış kod=%d → durum=%d neden=%s (beklenen %d %s)" % [c[0], g.durum, g.neden, c[2], c[3]])
		g.queue_free()
	var g2 := Guncelleyici.new()
	add_child(g2)
	g2._denetim_bitti(HTTPRequest.RESULT_CANT_CONNECT, 0, ok, PackedByteArray())
	_bak(g2.durum == Guncelleyici.D.BOS, "ağ yok → sessiz")
	# Test bayrakları olmadan testte (autotest) ağa çıkılmaz
	g2._denetlendi = false
	g2.menu_acildi()
	_bak(not g2._denetlendi and g2._http == null, "autotest'te denetim yok")
	g2.queue_free()
	await get_tree().process_frame


func _bant() -> void:
	var kok := Control.new()
	kok.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(kok)
	var g := Guncelleyici.new()
	add_child(g)
	g.yerel = "0.99.125"
	g.manifest = Guncelleyici.manifest_coz(_m({"surum": "0.99.1270"}))
	g.girdi = g.manifest["linux"]
	g.toplam = 1180000000
	g.indirilen = 612000000
	g.kalan_sn = 754.0
	var uzun_not := "Uzun sürüm notu. ".repeat(80)
	var durumlar := [
		[Guncelleyici.D.YENI, "", ""], [Guncelleyici.D.YENI, "UI_GUNC_N_PLATFORM", ""],
		[Guncelleyici.D.YENI, "", uzun_not], [Guncelleyici.D.YENI, "UI_GUNC_N_MOTOR", "…"],
		[Guncelleyici.D.INDIRILIYOR, "", ""], [Guncelleyici.D.DOGRULANIYOR, "", ""], [Guncelleyici.D.HAZIR, "", ""],
	]
	for n in ["UI_GUNC_N_PLATFORM", "UI_GUNC_N_MOTOR", "UI_GUNC_N_GELISTIRME", "UI_GUNC_N_YAZMA", "UI_GUNC_N_YER",
			"UI_GUNC_N_INDIRME", "UI_GUNC_N_TAKILDI", "UI_GUNC_N_BOZUK", "UI_GUNC_N_IZIN", "UI_GUNC_N_DEGISTIRME",
			"UI_GUNC_N_BASLATMA", "UI_GUNC_N_ADRES"]:
		durumlar.append([Guncelleyici.D.SAYFA, n, ""])
	var vs := Vector2(1280, 720)
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		for d in durumlar:
			g.durum = d[0]
			g.neden = d[1]
			g.degisiklik = d[2]
			g.gizli = false
			var b := g.bant()
			kok.add_child(b)
			await get_tree().process_frame
			await get_tree().process_frame
			var r := b.get_global_rect()
			var ad := "bant %s durum=%d %s" % [loc, d[0], d[1]]
			_bak(b.visible, ad + " görünmüyor")
			_bak(r.position.x >= 560.0 and r.position.y >= 0.0 and r.end.x <= vs.x and r.end.y <= vs.y,
				"%s taşıyor: %s" % [ad, r])
			for c in b.find_children("*", "Control", true, false):
				var cc := c as Control
				if cc.is_visible_in_tree() and not (cc.get_parent() is ScrollContainer):
					var rr := cc.get_global_rect()
					if rr.end.x > r.end.x + 1.0 or rr.end.y > r.end.y + 1.0:
						_bak(false, "%s içerik taşıyor: %s %s" % [ad, cc.get_class(), rr])
						break
			# İlerleme durumunda yalnız çubuk güncellenir (düğme yeniden kurulmaz)
			if d[0] == Guncelleyici.D.INDIRILIYOR:
				var once := b.find_children("*", "Button", true, false)
				g.indirilen += 1000000
				g._yayinla()
				var sonra := b.find_children("*", "Button", true, false)
				_bak(once.size() == 1 and sonra.size() == 1 and once[0] == sonra[0], "ilerlemede düğme korunur")
			b.queue_free()
		# Sonra → gizli
		g.durum = Guncelleyici.D.YENI
		g.neden = ""
		g.degisiklik = ""
		var b2 := g.bant()
		kok.add_child(b2)
		g._sonra()
		_bak(not b2.visible, "Sonra bandı gizler")
		b2.queue_free()
		g.gizli = false
		# Hiçbir şey yokken bant gizli
		g.durum = Guncelleyici.D.BOS
		var b3 := g.bant()
		kok.add_child(b3)
		_bak(not b3.visible, "BOS durumda bant gizli")
		b3.queue_free()
	TranslationServer.set_locale("tr")
	# Menüye bağlı: ana menü kökünde bant var, ayarlara geçince kalkar; duraklatmada hiç yok
	var menu := GameMenu.new("main")
	kok.add_child(menu)
	await get_tree().process_frame
	_bak(is_instance_valid(menu._bant), "ana menü kökünde bant düğümü")
	menu.show_settings()
	_bak(not is_instance_valid(menu._bant) or menu._bant.is_queued_for_deletion(), "ayarlarda bant yok")
	var ayar := false
	for c: CheckButton in menu.find_children("*", "CheckButton", true, false):
		if c.text == tr("UI_GUNC_AYAR"):
			ayar = c.button_pressed == bool(GameState.settings.get(Guncelleyici.AYAR, true))
	_bak(ayar, "ayarlarda 'Güncellemeleri denetle' satırı")
	_bak(bool(GameState.settings.get(Guncelleyici.AYAR, false)), "ayar varsayılanı açık")
	menu.queue_free()
	var dur := GameMenu.new("pause")
	kok.add_child(dur)
	await get_tree().process_frame
	_bak(dur._bant == null, "duraklatmada bant yok")
	dur.queue_free()
	g.queue_free()
	await get_tree().process_frame
