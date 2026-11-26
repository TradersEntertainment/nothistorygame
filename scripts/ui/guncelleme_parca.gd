class_name GuncellemeParca
extends RefCounted
## Parçalı güncelleme (G24): yeni sürümün ham ikilisinin yalnız DEĞİŞEN parçaları indirilir.
## CI her ikili için parça listesini yazar (tools/guncelleme_parca.py → <ad>.parca.json: [konum, boy, md5]). Oyun kendi
## ikilisini aynı kuralla böler ve MD5'lerini çıkarır (kesimler, ozetle); uzak listeyle karşılaştırıp bir plan kurar
## (plan): aynı MD5'li parça yerel dosyadan kopyalanır, öteki aralıklar HTTP Range ile <exe>.parcalar'a indirilir
## (Guncelleyici); sonra <exe>.yeni plan sırasıyla birleştirilir (birlestir) ve guncelleme.json'daki sha256 ile doğrulanır.
## Kural tutmazsa (biçim değişti, sunucu Range vermiyor, sha256 tutmadı) tam indirmeye dönülür: bozuk dosya oluşmaz.
## Bölme kuralı tools/guncelleme_parca.py'nin belgesinde; ikisi aynı kalmalı.

const BLOK := 1024 * 1024
const MAGIC := 0x43504447          # "GDPC"
## İki indirme aralığı arasındaki boşluk bundan küçükse boşluk da indirilir (istek sayısı azalır)
const BIRLESTIR_BOSLUK := 256 * 1024
## Tek Range isteğinin en büyük boyu (bellekte tutulur)
const ISTEK_EN := 8 * 1024 * 1024
const KOPYA := 4 * 1024 * 1024
## İndirilecek bu oranı aşarsa tam indirme (parça yolunun bir kazancı kalmaz)
const TAM_ORAN := 0.8


## İkilinin parçaları: [[konum, boy], ...] ve gömülü pck bulundu mu. Dosya açılamazsa boş.
static func kesimler(yol: String) -> Dictionary:
	var f := FileAccess.open(yol, FileAccess.READ)
	if f == null:
		return {"parcalar": [], "pck": false}
	var n := f.get_length()
	var kes := {0: true, n: true}
	var ps := -1
	if n >= 16:
		f.seek(n - 4)
		if f.get_32() == MAGIC:
			f.seek(n - 12)
			var ds := f.get_64()
			var aday := n - 12 - ds
			if aday >= 0 and aday < n - 12:
				f.seek(aday)
				var bas := f.get_buffer(100)
				if bas.size() == 100 and bas.decode_u32(0) == MAGIC:
					var surum := bas.decode_u32(4)
					var bayrak := bas.decode_u32(20)
					var taban := bas.decode_u64(24)
					var sayi := bas.decode_u32(96)
					if surum == 2 and (bayrak & 1) == 0:
						ps = aday
						if bayrak & 2:
							taban += ps
						var dosyalar: Array = []
						for i in sayi:
							var sl := f.get_32()
							f.seek(f.get_position() + sl)
							var ofs := f.get_64()
							var boy := f.get_64()
							f.seek(f.get_position() + 20)
							dosyalar.append([taban + ofs, boy])
						if f.get_error() == OK or f.get_error() == ERR_FILE_EOF:
							kes[ps] = true
							kes[n - 12] = true
							for d: Array in dosyalar:
								var a := int(d[0])
								var b := int(d[1])
								if b > 0 and a >= ps and a + b <= n:
									kes[a] = true
									kes[a + b] = true
						else:
							ps = -1
	f.close()
	var ust := ps if ps >= 0 else n
	var k := BLOK
	while k < ust:
		kes[k] = true
		k += BLOK
	var s: Array = kes.keys()
	s.sort()
	var out: Array = []
	for i in s.size() - 1:
		if int(s[i + 1]) > int(s[i]):
			out.append([int(s[i]), int(s[i + 1]) - int(s[i])])
	return {"parcalar": out, "pck": ps >= 0}


## Parçaların MD5'i: "md5:boy" → yerel konum. ilerleme(okunan bayt). İş parçacığında çağrılır.
static func ozetle(yol: String, parcalar: Array, ilerleme: Callable = Callable()) -> Dictionary:
	var f := FileAccess.open(yol, FileAccess.READ)
	if f == null:
		return {}
	var out := {}
	var okunan := 0
	for p: Array in parcalar:
		var o := int(p[0])
		var b := int(p[1])
		var h := HashingContext.new()
		h.start(HashingContext.HASH_MD5)
		f.seek(o)
		var kalan := b
		while kalan > 0:
			var buf := f.get_buffer(mini(kalan, KOPYA))
			if buf.is_empty():
				f.close()
				return {}
			h.update(buf)
			kalan -= buf.size()
		var key := "%s:%d" % [h.finish().hex_encode(), b]
		if not out.has(key):
			out[key] = o
		okunan += b
		if ilerleme.is_valid():
			ilerleme.call(okunan)
	f.close()
	return out


## Uzak parça listesi (<ad>.parca.json metni) → {"boyut", "parcalar": [[o, b, md5], ...]}; bozuksa {}.
static func liste_coz(metin: String, beklenen_boyut: int) -> Dictionary:
	var js := JSON.new()
	if js.parse(metin) != OK or not js.data is Dictionary:
		return {}
	var d := js.data as Dictionary
	if int(d.get("bicim", 0)) != 1 or not d.get("parcalar") is Array:
		return {}
	var ps: Array = d["parcalar"]
	var beklenen := 0
	for p in ps:
		if not p is Array or (p as Array).size() != 3:
			return {}
		var o := int(p[0])
		var b := int(p[1])
		if o != beklenen or b <= 0 or not p[2] is String or String(p[2]).length() != 32:
			return {}
		beklenen += b
	if beklenen != beklenen_boyut:
		return {}
	return {"boyut": beklenen, "parcalar": ps}


## Plan: uzak liste + yerel özetler → {"islem": [["y", yerel_konum, boy] | ["u", parcalar_konumu, boy]],
## "araliklar": [[uzak_a, uzak_b], ...] (indirilecek, sırayla <exe>.parcalar'a), "indirilecek": bayt, "kopya": bayt}
static func plan(uzak: Dictionary, yerel: Dictionary) -> Dictionary:
	var ps: Array = uzak["parcalar"]
	# 1) hangi parça uzaktan; uzak aralıkları birleştir (küçük boşluklar da indirilir)
	var uzaktan: Array = []
	for p: Array in ps:
		uzaktan.append(not yerel.has("%s:%d" % [String(p[2]), int(p[1])]))
	var araliklar: Array = []
	for i in ps.size():
		if not uzaktan[i]:
			continue
		var a := int(ps[i][0])
		var b := a + int(ps[i][1])
		if not araliklar.is_empty() and a - int(araliklar[-1][1]) <= BIRLESTIR_BOSLUK:
			araliklar[-1][1] = b
		else:
			araliklar.append([a, b])
	# 2) işlem listesi: aralık içindeki her bayt indirilen dosyadan, dışındakiler yerelden
	var islem: Array = []
	var ai := 0
	var indirilen_ofs := 0          # aralığın .parcalar'daki başı
	var ind := 0
	for r: Array in araliklar:
		ind += int(r[1]) - int(r[0])
	for p: Array in ps:
		var o := int(p[0])
		var b := int(p[1])
		while ai < araliklar.size() and o >= int(araliklar[ai][1]):
			indirilen_ofs += int(araliklar[ai][1]) - int(araliklar[ai][0])
			ai += 1
		var aralikta := ai < araliklar.size() and o >= int(araliklar[ai][0])
		if aralikta:
			_ekle(islem, "u", indirilen_ofs + (o - int(araliklar[ai][0])), b)
		else:
			_ekle(islem, "y", int(yerel["%s:%d" % [String(p[2]), b]]), b)
	return {"islem": islem, "araliklar": araliklar, "indirilecek": ind, "kopya": int(uzak["boyut"]) - ind}


static func _ekle(islem: Array, tur: String, konum: int, boy: int) -> void:
	if not islem.is_empty():
		var s: Array = islem[-1]
		if String(s[0]) == tur and int(s[1]) + int(s[2]) == konum:
			s[2] = int(s[2]) + boy
			return
	islem.append([tur, konum, boy])


## Planı uygular: yerel ikili + indirilen parçalar → hedef. ilerleme(yazılan bayt). Başarı true.
static func birlestir(yerel_yol: String, parca_yol: String, pl: Dictionary, hedef: String, ilerleme: Callable = Callable()) -> bool:
	var fy := FileAccess.open(yerel_yol, FileAccess.READ)
	var fu: FileAccess = null
	if int(pl["indirilecek"]) > 0:
		fu = FileAccess.open(parca_yol, FileAccess.READ)
	var fo := FileAccess.open(hedef, FileAccess.WRITE)
	if fy == null or fo == null or (int(pl["indirilecek"]) > 0 and fu == null):
		return false
	var yazilan := 0
	for s: Array in pl["islem"]:
		var kaynak: FileAccess = fy if String(s[0]) == "y" else fu
		kaynak.seek(int(s[1]))
		var kalan := int(s[2])
		while kalan > 0:
			var buf := kaynak.get_buffer(mini(kalan, KOPYA))
			if buf.is_empty():
				fo.close()
				return false
			fo.store_buffer(buf)
			kalan -= buf.size()
			yazilan += buf.size()
			if ilerleme.is_valid():
				ilerleme.call(yazilan)
	var ok := fo.get_error() == OK
	fo.close()
	fy.close()
	if fu != null:
		fu.close()
	return ok


## Uzak aralıkları en çok ISTEK_EN'lik isteklere böler: [[a, b], ...] (b dahil değil)
static func istekler(araliklar: Array) -> Array:
	var out: Array = []
	for r: Array in araliklar:
		var a := int(r[0])
		while a < int(r[1]):
			var b := mini(int(r[1]), a + ISTEK_EN)
			out.append([a, b])
			a = b
	return out
