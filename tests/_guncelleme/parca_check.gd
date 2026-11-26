extends Node
## G24 parçalı güncelleme, ağsız sınama:
##   godot --headless --path . res://tests/_guncelleme/parca_check.tscn -- a=ESKI_IKILI b=YENI_IKILI liste=B.parca.json
##  1. GDScript bölmesi (GuncellemeParca.kesimler + ozetle) B'de Python'un listesiyle (tools/guncelleme_parca.py) aynı mı
##  2. A'nın özetleri + B'nin listesi → plan; indirilecek aralıklar B'den okunup <hedef>.parcalar'a yazılır (HTTP yerine),
##     birlestir → sonuç B ile bit bit aynı mı (sha256)
##  3. bozuk liste (konum boşluğu, yanlış boy) reddediliyor mu
## Yoksa (argümansız) küçük yapay ikililerle aynı denetimler (sahte pck: PCKPacker + gömülü iz).
## Satır: PARCACHECK PASS|FAIL …

var _hata := 0


func _ready() -> void:
	_kos.call_deferred()


func _bak(k: bool, ne: String) -> void:
	if not k:
		_hata += 1
		print("PARCACHECK hata: " + ne)


func _kos() -> void:
	var a := ""
	var b := ""
	var liste := ""
	for x: String in OS.get_cmdline_user_args():
		var kv := x.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2:
			match kv[0]:
				"a": a = kv[1]
				"b": b = kv[1]
				"liste": liste = kv[1]
	if a == "":
		var d := OS.get_environment("HOME").path_join("is/parca_check")
		DirAccess.make_dir_recursive_absolute(d)
		a = d.path_join("A.bin")
		b = d.path_join("B.bin")
		_yapay(a, false)
		_yapay(b, true)
		liste = ""
	var t0 := Time.get_ticks_msec()
	# 1) bölme eşitliği (Python listesi verildiyse)
	var kb := GuncellemeParca.kesimler(b)
	print("PARCACHECK kesim n=%d pck=%s" % [(kb["parcalar"] as Array).size(), str(kb["pck"])])
	_bak(bool(kb["pck"]), "B'de gömülü pck bulunamadı")
	var ozb := GuncellemeParca.ozetle(b, kb["parcalar"])
	var uzak: Dictionary
	var fb := FileAccess.open(b, FileAccess.READ)
	var nb := fb.get_length()
	fb.close()
	if liste != "":
		uzak = GuncellemeParca.liste_coz(FileAccess.get_file_as_string(liste), nb)
		_bak(not uzak.is_empty(), "Python listesi okunamadı")
		var esit := 0
		for p: Array in uzak.get("parcalar", []):
			if ozb.get("%s:%d" % [String(p[2]), int(p[1])], -1) == int(p[0]) or ozb.has("%s:%d" % [String(p[2]), int(p[1])]):
				esit += 1
		print("PARCACHECK bolme parca=%d gd=%d esit=%d" % [(uzak.get("parcalar", []) as Array).size(), (kb["parcalar"] as Array).size(), esit])
		_bak(esit == (uzak.get("parcalar", []) as Array).size() and (kb["parcalar"] as Array).size() == esit, "GDScript ve Python bölmesi farklı")
	else:
		var ps: Array = []
		var f := FileAccess.open(b, FileAccess.READ)
		for p: Array in kb["parcalar"]:
			f.seek(int(p[0]))
			ps.append([int(p[0]), int(p[1]), _md5(f, int(p[0]), int(p[1]))])
		f.close()
		uzak = GuncellemeParca.liste_coz(JSON.stringify({"bicim": 1, "parcalar": ps}), nb)
		_bak(not uzak.is_empty(), "yapay liste okunamadı")
	# 2) plan + birleştirme
	var ka := GuncellemeParca.kesimler(a)
	var oza := GuncellemeParca.ozetle(a, ka["parcalar"])
	var pl := GuncellemeParca.plan(uzak, oza)
	var parcalar := b + ".sinama_parcalar"
	var hedef := b + ".sinama_yeni"
	var fo := FileAccess.open(parcalar, FileAccess.WRITE)
	var fbb := FileAccess.open(b, FileAccess.READ)
	for r: Array in GuncellemeParca.istekler(pl["araliklar"]):
		fbb.seek(int(r[0]))
		fo.store_buffer(fbb.get_buffer(int(r[1]) - int(r[0])))
	fo.close()
	fbb.close()
	var ok := GuncellemeParca.birlestir(a, parcalar, pl, hedef)
	_bak(ok, "birleştirme başarısız")
	var hb := Guncelleyici._ozet(b)
	var hy := Guncelleyici._ozet(hedef)
	print("PARCACHECK plan indirilecek=%d kopya=%d aralik=%d istek=%d toplam=%d ayni=%s ms=%d" % [int(pl["indirilecek"]),
		int(pl["kopya"]), (pl["araliklar"] as Array).size(), GuncellemeParca.istekler(pl["araliklar"]).size(), nb,
		str(hb == hy), Time.get_ticks_msec() - t0])
	_bak(hb == hy and hb != "", "birleşen dosya B ile aynı değil")
	_bak(int(pl["indirilecek"]) + int(pl["kopya"]) == nb, "plan toplamı tutmuyor")
	DirAccess.remove_absolute(parcalar)
	DirAccess.remove_absolute(hedef)
	# 3) bozuk listeler
	_bak(GuncellemeParca.liste_coz('{"bicim":1,"parcalar":[[0,10,"%s"],[11,5,"%s"]]}' % ["0".repeat(32), "0".repeat(32)], 16).is_empty(), "boşluklu liste kabul edildi")
	_bak(GuncellemeParca.liste_coz('{"bicim":1,"parcalar":[[0,10,"%s"]]}' % "0".repeat(32), 11).is_empty(), "yanlış boylu liste kabul edildi")
	_bak(GuncellemeParca.liste_coz('{"bicim":2,"parcalar":[]}', 0).is_empty(), "bilinmeyen biçim kabul edildi")
	print("PARCACHECK %s hata=%d" % ["PASS" if _hata == 0 else "FAIL", _hata])
	get_tree().quit(0 if _hata == 0 else 1)


func _md5(f: FileAccess, o: int, n: int) -> String:
	var h := HashingContext.new()
	h.start(HashingContext.HASH_MD5)
	f.seek(o)
	h.update(f.get_buffer(n))
	return h.finish().hex_encode()


## Yapay "ikili": 3 MiB rastgele motor + PCKPacker ile pck (40 dosya) + gömülü iz (u64 pck boyu, "GDPC"). yeni=true:
## motorun bir baytı ve üç dosya değişir, bir dosya eklenir.
func _yapay(yol: String, yeni: bool) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 24
	var d := yol.get_base_dir()
	var pck := yol + ".pck"
	var pk := PCKPacker.new()
	pk.pck_start(pck)
	for i in 40 + (1 if yeni else 0):
		var src := d.path_join("dosya_%d.bin" % i)
		var buf := PackedByteArray()
		buf.resize(1000 + i * 3000)
		for j in buf.size():
			buf[j] = rng.randi() % 256
		if yeni and i in [3, 17, 30]:
			buf[7] = buf[7] ^ 0xff
		var f := FileAccess.open(src, FileAccess.WRITE)
		f.store_buffer(buf)
		f.close()
		pk.add_file("res://veri/dosya_%d.bin" % i, src)
	pk.flush()
	var motor := PackedByteArray()
	motor.resize(3 * 1024 * 1024 + 123)
	for j in range(0, motor.size(), 97):
		motor[j] = (j * 7) % 256
	if yeni:
		motor[2 * 1024 * 1024 + 5] = 1
	var p := FileAccess.get_file_as_bytes(pck)
	# PCKPacker tek başına pck yazar (dosya tabanı pck başına göre ama "göreli" bayrağı yok); gömülü dışa aktarımdaki gibi
	# PACK_REL_FILEBASE (1 << 1) konur
	p.encode_u32(20, p.decode_u32(20) | 2)
	var o := FileAccess.open(yol, FileAccess.WRITE)
	o.store_buffer(motor)
	o.store_buffer(p)
	o.store_64(p.size())
	o.store_32(0x43504447)
	o.close()
