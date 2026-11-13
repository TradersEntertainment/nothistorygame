extends Node
## SUR SÖZLEŞMESİ denetimi (başsız):
##   timeout 120 godot --headless --path . res://tests/_ist/sur_sozlesme.tscn
## 1) Sözleşmenin CANLI hesabı (bugünkü IstSurlar/IstSehir kurucusundan) ile DONMUŞ tablo kalem kalem aynı mı
##    (0,001 m toleransla; fark → hangi kesim, hangi kalem, hangi anahtar).
## 2) DONMUŞ tablonun kalem özetleri depodaki beklenen özetle (tests/_ist/sur_sozlesme_beklenen.txt) aynı mı.
## Son satır: SURSOZLESME PASS|FAIL <ayrıntı>. Eşik/tolerans yok sayılamaz; "--uret" yalnız ilk dondurmada kullanıldı.
const SZ := preload("res://scripts/world/ist/sur_sozlesme.gd")
const BEKLENEN := "res://tests/_ist/sur_sozlesme_beklenen.txt"


func _ready() -> void:
	var uret := "--uret" in OS.get_cmdline_user_args()
	var canli: Dictionary = SZ.canli_tablo()
	if uret:
		var f := FileAccess.open(SZ.DONMUS_YOL, FileAccess.WRITE)
		f.store_string(JSON.stringify(canli, "\t", true))
		f.close()
		var oz := SZ.ozet(JSON.parse_string(JSON.stringify(canli)))
		var g := FileAccess.open(BEKLENEN, FileAccess.WRITE)
		var ks: Array = oz.keys()
		ks.sort()
		for k in ks:
			g.store_line("%s %s" % [k, oz[k]])
		g.close()
		print("SURSOZLESME uretildi")
		get_tree().quit(0)
		return
	var dn: Dictionary = SZ.donmus()
	var hatalar: Array = []
	# 1) canlı ↔ donmuş
	_kiyas("ortak", canli["ortak"], dn.get("ortak", {}), hatalar)
	for id in SZ.KESIMLER:
		_kiyas("kesim/" + id, canli["kesim"][id], (dn.get("kesim", {}) as Dictionary).get(id, {}), hatalar)
	# 2) donmuş özet ↔ beklenen
	var oz2: Dictionary = SZ.ozet(dn)
	var bek := {}
	var fb := FileAccess.open(BEKLENEN, FileAccess.READ)
	if fb == null:
		hatalar.append("beklenen_ozet_yok")
	else:
		for line in fb.get_as_text().split("\n", false):
			var p := line.split(" ")
			if p.size() == 2:
				bek[p[0]] = p[1]
	for k in bek:
		if String(oz2.get(k, "")) != String(bek[k]):
			hatalar.append("ozet:%s beklenen=%s donmus=%s" % [k, bek[k], oz2.get(k, "")])
	for k in oz2:
		if not bek.has(k):
			hatalar.append("ozet:%s beklenende_yok" % k)
	# özet tablo (insan okur)
	var kes: Dictionary = dn["ortak"]["kesit"]
	print("SURSOZLESME kesit T=%.2f HW=%.2f PW=%.2f OT=%.2f OH=%.2f PTW=%.2f MW=%.2f MD=%.2f S=%.2f zo0=%.2f zo1=%.2f zm0=%.2f zm1=%.2f" % [
		kes["T"], kes["HW"], kes["PW"], kes["OT"], kes["OH"], kes["PTW"], kes["MW"], kes["MD"], kes["S"], kes["zo0"], kes["zo1"], kes["zm0"], kes["zm1"]])
	for id in SZ.KESIMLER:
		var k: Dictionary = dn["kesim"][id]
		var ic: Array = []
		for t in k["kule"]["ic"]:
			ic.append("%.1f" % float(t[0]))
		print("SURSOZLESME %s ic_kule=[%s] dis_kule=%s gedik=%s merdiven_ic=%.1f..%.1f dis=%.1f..%.1f rampa=%.1f/%.1f poterna=%s dayama=%s gecis=%s" % [
			id, ", ".join(ic), k["kule"]["dis"], k["gedik"]["x"], float(k["merdiven"].get("in_x0", NAN)), float(k["merdiven"].get("in_x1", NAN)),
			float(k["merdiven"].get("out_x0", NAN)), float(k["merdiven"].get("out_x1", NAN)), float(k["hendek"]["ramp_a_x"]), float(k["hendek"]["ramp_b_x"]),
			k["oyun"]["poterna"], k["oyun"]["dayama"], SZ.duz(k["oyun"]["gecis"])])
	var ks2: Array = oz2.keys()
	ks2.sort()
	var ozs: Array = []
	for k in ks2:
		ozs.append("%s=%s" % [k, oz2[k]])
	print("SURSOZLESME ozet ", " ".join(ozs))
	for h in hatalar:
		print("SURSOZLESME fark ", h)
	if hatalar.is_empty():
		print("SURSOZLESME PASS kalem=%d kesim=%d" % [oz2.size(), SZ.KESIMLER.size()])
	else:
		print("SURSOZLESME FAIL fark=%d ilk=%s" % [hatalar.size(), hatalar[0]])
	get_tree().quit(0 if hatalar.is_empty() else 1)


func _kiyas(yol: String, a: Variant, b: Variant, out: Array) -> void:
	if a is Dictionary and b is Dictionary:
		for k in (a as Dictionary):
			if not (b as Dictionary).has(k):
				out.append("%s/%s donmusta_yok" % [yol, k])
				continue
			_kiyas("%s/%s" % [yol, k], a[k], b[k], out)
		for k in (b as Dictionary):
			if not (a as Dictionary).has(k):
				out.append("%s/%s canlida_yok" % [yol, k])
		return
	if a is Array and b is Array:
		if (a as Array).size() != (b as Array).size():
			out.append("%s sayi canli=%d donmus=%d" % [yol, (a as Array).size(), (b as Array).size()])
			return
		for i in (a as Array).size():
			_kiyas("%s[%d]" % [yol, i], a[i], b[i], out)
		return
	if (a is float or a is int) and (b is float or b is int):
		if absf(float(a) - float(b)) > 0.001:
			out.append("%s canli=%s donmus=%s" % [yol, a, b])
		return
	if str(a) != str(b):
		out.append("%s canli=%s donmus=%s" % [yol, a, b])
