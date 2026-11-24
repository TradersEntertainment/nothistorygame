class_name Guncelleyici
extends Node
## Oyunun kendini internetten güncellemesi (G16). Ana menü ilk açıldığında herkese açık indirme deposundaki küçük
## sürüm bildirimini (guncelleme.json, .github/workflows/release.yml üretir) bir kez okur; yeni sürüm varsa menüde bant
## gösterir. Oyuncu "Güncelle" derse kendi platformunun HAM ikilisini (pck gömülü exe / x86_64) çalışan dosyanın
## yanına <exe>.yeni olarak indirir, boyutunu ve SHA-256'sını doğrular; oyuncu menüde onaylayınca
##   <exe> → <exe>.eski,  <exe>.yeni → <exe>,  yeni süreç başlat,  çık.
## Herhangi bir adım tutmazsa geri alınır (.eski → <exe>): oyun hiçbir durumda eksik ya da bozuk exe ile kalmaz.
## Sonraki açılışta <exe>.eski ve on dakikadan eski yarım <exe>.yeni silinir (GameState._ready).
## Kayıtlar ve ayarlar user://'dadır, kurulum klasörüne dokunulmaz. macOS'ta yalnız bant + indirme sayfası.
##
## Ağ: yalnız aşağıdaki adresler; tek başlık User-Agent. Otomatik testte, ekran çekiminde, başsız koşuda, editörde ya da
## ayar kapalıyken hiç istek atılmaz. Test bayrakları (oyunun kendi bayrakları gibi "--" sonrasında):
##   --guncelleme-kaynak=http://127.0.0.1:PORT/guncelleme.json   bildirimi yerel sunucudan oku (yalnız 127.0.0.1/localhost)
##   --guncelleme-oto            menüsüz: denetle, indir, doğrula, değiştir, yeniden başlat; GUNCELLEME satırları yazar
##   --guncelleme-yalniz-denetle bildirimi oku, "GUNCELLEME uzak=… yerel=… yeni=…" yaz, çık
##   --guncelleme-surum-yaz      (yeniden başlayan süreç) "GUNCELLEME surum=…" yaz, çık

signal degisti

const DEPO := "https://github.com/TradersEntertainment/nothistorygamedemo"
const MANIFEST_URL := DEPO + "/releases/latest/download/guncelleme.json"
const SAYFA_URL := DEPO + "/releases/latest"
const INDIRME_ONEK := DEPO + "/releases/"
const DEGISIKLIK_URL := "https://raw.githubusercontent.com/TradersEntertainment/nothistorygamedemo/main/data/changelog.json"
const AYAR := "guncelleme_denetle"
const PARCA := 4 * 1024 * 1024
const TAKILMA_SN := 30.0
const YARIM_YENI_SN := 600

enum D { BOS, DENETLENIYOR, YENI, INDIRILIYOR, DOGRULANIYOR, HAZIR, SAYFA }

## Birim testi için: ikinci adlandırma (yeni → exe) bozulmuş gibi davranır (geri alma sınanır)
static var sinama_ikinci_adim_bozuk := false

var durum := D.BOS
## Güncellemenin neden yapılamadığı (i18n anahtarı); "" = engel yok
var neden := ""
var manifest: Dictionary = {}
var girdi: Dictionary = {}
var yerel := ""
var indirilen := 0
var toplam := 0
var kalan_sn := -1.0
var gizli := false
## "Ne değişti?" metni: "" henüz yok, "…" yükleniyor
var degisiklik := ""

var exe := ""
var kaynak := ""
var oto := false
var yalniz_denetle := false
var surum_yaz := false

var _denetlendi := false
var _http: HTTPRequest
var _http_indir: HTTPRequest
var _http_not: HTTPRequest
var _bekci_bayt := -1
var _bekci_ms := 0
var _hiz := 0.0
var _hiz_bayt := 0
var _hiz_ms := 0
var _yayin_ms := 0
var _ozet_is: Thread
var _ozet_bayt := 0


func _init(p_kaynak := "", p_oto := false, p_yalniz := false, p_surum_yaz := false) -> void:
	name = "Guncelleyici"
	kaynak = p_kaynak
	oto = p_oto
	yalniz_denetle = p_yalniz
	surum_yaz = p_surum_yaz
	# Linux'ta get_executable_path /proc/self/exe okur: adlandırmadan sonra ".eski" döner, yol açılışta saklanır
	exe = OS.get_executable_path()
	yerel = GameState.version_text()
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	if surum_yaz:
		_yaz("surum=%s eski_var=%s" % [yerel, str(FileAccess.file_exists(exe + ".eski")).to_lower()])
		get_tree().quit(0)
		return
	if kaynak != "" and not kaynak_gecerli(kaynak):
		_yaz("kaynak reddedildi (yalniz http://127.0.0.1 ve http://localhost): " + kaynak)
		kaynak = ""
		if oto or yalniz_denetle:
			get_tree().quit(2)
		return
	if oto or yalniz_denetle:
		denetle()


func _exit_tree() -> void:
	if _ozet_is != null and _ozet_is.is_started():
		_ozet_is.wait_to_finish()


# ---------------------------------------------------------------- saf yardımcılar (tests/guncelleme_check.gd)

## "0.99.10" → [0, 99, 10]; baştaki v atılır; bozuksa boş dizi.
static func surum_parcala(s: String) -> PackedInt64Array:
	var t := s.strip_edges()
	if t.begins_with("v") or t.begins_with("V"):
		t = t.substr(1)
	var out := PackedInt64Array()
	if t == "":
		return out
	for p in t.split("."):
		if p == "" or p.length() > 9:
			return PackedInt64Array()
		for ch in p:
			if not (ch >= "0" and ch <= "9"):
				return PackedInt64Array()
		out.append(int(p))
	return out


## -1 a<b, 0 eşit, 1 a>b, -2 bozuk girdi. Eksik parça 0 sayılır (0.99 = 0.99.0).
static func surum_karsilastir(a: String, b: String) -> int:
	var x := surum_parcala(a)
	var y := surum_parcala(b)
	if x.is_empty() or y.is_empty():
		return -2
	for i in maxi(x.size(), y.size()):
		var u: int = x[i] if i < x.size() else 0
		var v: int = y[i] if i < y.size() else 0
		if u != v:
			return 1 if u > v else -1
	return 0


## Uzaktaki sürüm yerelden yeni mi (bozuk girdi = yeni yok).
static func yeni_mi(uzak: String, yerel_s: String) -> bool:
	return surum_karsilastir(uzak, yerel_s) == 1


## Bildirimdeki platform girdisi geçerli mi: ad (yol ayıracı ve ".." yok), boyut (pozitif tam sayı), sha256 (64 onaltılık).
static func girdi_gecerli(g: Variant) -> bool:
	if not g is Dictionary:
		return false
	var d := g as Dictionary
	if not (d.get("ad") is String and d.get("sha256") is String):
		return false
	var ad: String = d["ad"]
	if ad.strip_edges() == "" or ad != ad.strip_edges() or "/" in ad or "\\" in ad or ".." in ad or ":" in ad:
		return false
	var b: Variant = d.get("boyut")
	if not (b is float or b is int):
		return false
	if float(b) <= 0.0 or float(b) != floorf(float(b)) or float(b) > 1.0e12:
		return false
	var h: String = d["sha256"]
	if h.length() != 64:
		return false
	for ch in h.to_lower():
		if not ((ch >= "0" and ch <= "9") or (ch >= "a" and ch <= "f")):
			return false
	return true


## guncelleme.json metni → {"surum", "motor", "windows"?, "linux"?}; bozuk bildirim {} (= yeni yok).
## Geçersiz platform girdisi düşer (o platformda güncelleme yok, sayfa yolu).
static func manifest_coz(metin: String) -> Dictionary:
	var js := JSON.new()
	if js.parse(metin) != OK or not js.data is Dictionary:
		return {}
	var d := js.data as Dictionary
	if not d.get("surum") is String or surum_parcala(d["surum"]).is_empty():
		return {}
	var out := {"surum": String(d["surum"]).strip_edges().trim_prefix("v"),
		"motor": String(d["motor"]) if d.get("motor") is String else ""}
	for p in ["windows", "linux"]:
		if girdi_gecerli(d.get(p)):
			var g := d[p] as Dictionary
			out[p] = {"ad": String(g["ad"]), "boyut": int(g["boyut"]), "sha256": String(g["sha256"]).to_lower()}
	return out


static func platform() -> String:
	match OS.get_name():
		"Windows":
			return "windows"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return "linux"
		"macOS":
			return "macos"
	return ""


static func motor_surumu() -> String:
	var v := Engine.get_version_info()
	return "%d.%d.%d" % [int(v["major"]), int(v["minor"]), int(v["patch"])]


## "4.5" → "4.5.0"; bozuksa "".
static func motor_norm(s: String) -> String:
	var p := surum_parcala(s)
	if p.is_empty() or p.size() > 3:
		return ""
	while p.size() < 3:
		p.append(0)
	return "%d.%d.%d" % [p[0], p[1], p[2]]


## Yerinde güncellemenin önkoşulları; tutmayanın nedeni (i18n anahtarı) ya da "".
## bos_yer <= 0 "bilinmiyor" sayılır, engellemez.
static func onkosul(man: Dictionary, plat: String, motor: String, yazilir: bool, bos_yer: int, paket := true) -> String:
	if plat == "" or plat == "macos" or not man.has(plat):
		return "UI_GUNC_N_PLATFORM"
	if motor_norm(String(man.get("motor", ""))) == "" or motor_norm(String(man.get("motor", ""))) != motor_norm(motor):
		return "UI_GUNC_N_MOTOR"
	if not paket:
		return "UI_GUNC_N_GELISTIRME"
	if not yazilir:
		return "UI_GUNC_N_YAZMA"
	if bos_yer > 0 and float(bos_yer) < float((man[plat] as Dictionary)["boyut"]) * 1.1:
		return "UI_GUNC_N_YER"
	return ""


## Yerel test kaynağı yalnız bu makineden (http://127.0.0.1 ya da http://localhost).
static func kaynak_gecerli(url: String) -> bool:
	for on in ["http://127.0.0.1:", "http://127.0.0.1/", "http://localhost:", "http://localhost/"]:
		if url.begins_with(on):
			return not ("@" in url)
	return false


## Klasöre yazılabiliyor mu: benzersiz adlı küçük dosya yazılıp silinir.
static func yazilir_mi(klasor: String) -> bool:
	var yol := klasor.path_join(".gtbd_yazma_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	var f := FileAccess.open(yol, FileAccess.WRITE)
	if f == null:
		return false
	f.store_8(1)
	f.close()
	DirAccess.remove_absolute(yol)
	return not FileAccess.file_exists(yol)


static func bos_yer(klasor: String) -> int:
	var d := DirAccess.open(klasor)
	return int(d.get_space_left()) if d != null else 0


## Bayt → "≈1,2 GB" (Türkçede virgül).
static func boyut_metni(b: int, tr_mi := true) -> String:
	var s := ""
	if b >= 1000 * 1000 * 1000:
		s = "%.1f GB" % (b / 1.0e9)
	else:
		s = "%d MB" % int(round(b / 1.0e6))
	return s.replace(".", ",") if tr_mi else s


static func _adlandir(a: String, b: String) -> int:
	# Windows: virüs tarayıcısı yeni dosyayı bir süre kilitleyebilir → birkaç kez dene (ana iş parçacığı kısa bekler)
	var err := DirAccess.rename_absolute(a, b)
	var n := 0
	while err != OK and n < 4:
		OS.delay_msec(500)
		err = DirAccess.rename_absolute(a, b)
		n += 1
	return err


## Dosya adımları: <exe> → <exe>.eski, <exe>.yeni → <exe>. "" başarı; değilse neden ve eski exe yerinde.
## Arada await yok, res:// okunmaz (pck gömülü: her kaynak okuması exe'yi yol adıyla yeniden açar).
static func dosyalari_degistir(e: String) -> String:
	var eski := e + ".eski"
	var yeni := e + ".yeni"
	if not FileAccess.file_exists(yeni) or not FileAccess.file_exists(e):
		return "UI_GUNC_N_DEGISTIRME"
	if FileAccess.file_exists(eski):
		DirAccess.remove_absolute(eski)
		if FileAccess.file_exists(eski):
			return "UI_GUNC_N_DEGISTIRME"
	if _adlandir(e, eski) != OK:
		return "UI_GUNC_N_DEGISTIRME"
	if sinama_ikinci_adim_bozuk or _adlandir(yeni, e) != OK:
		_adlandir(eski, e)
		return "UI_GUNC_N_DEGISTIRME"
	return ""


## Yeni süreç başlatılamadı: yeni exe geri .yeni olur (sonraki açılışta silinir), eski yerine döner.
static func baslatma_geri_al(e: String) -> void:
	if FileAccess.file_exists(e + ".eski"):
		_adlandir(e, e + ".yeni")
		_adlandir(e + ".eski", e)


## Açılış temizliği: önceki güncellemeden kalan <exe>.eski ve on dakikadan eski yarım <exe>.yeni silinir. Yalnız
## dışa aktarılmış pakette (testlerde exe Godot'nun kendisidir). Kilitliyse (Windows) sessizce sonraki açılışa kalır.
static func acilis_temizligi(e: String, paket := OS.has_feature("template") and not OS.has_feature("editor")) -> void:
	if not paket or e == "":
		return
	if FileAccess.file_exists(e + ".eski"):
		DirAccess.remove_absolute(e + ".eski")
	var yeni := e + ".yeni"
	if FileAccess.file_exists(yeni):
		var yas := int(Time.get_unix_time_from_system()) - int(FileAccess.get_modified_time(yeni))
		if yas > YARIM_YENI_SN:
			DirAccess.remove_absolute(yeni)


static func _ozet(yol: String, ilerleme: Callable = Callable()) -> String:
	var f := FileAccess.open(yol, FileAccess.READ)
	if f == null:
		return ""
	var h := HashingContext.new()
	h.start(HashingContext.HASH_SHA256)
	var n := f.get_length()
	while f.get_position() < n:
		h.update(f.get_buffer(PARCA))
		if ilerleme.is_valid():
			ilerleme.call(f.get_position())
	f.close()
	return h.finish().hex_encode()


# ---------------------------------------------------------------- denetim

## Ağ isteği atılabilir mi (test bayrakları dışında).
func etkin() -> bool:
	if oto or yalniz_denetle:
		return true
	if GameState.autotest or GameState.shots_dir != "" or GameState.dialog_shots_dir != "" or GameState.exitcheck:
		return false
	if DisplayServer.get_name() == "headless":
		return false
	if OS.has_feature("editor") and kaynak == "":
		return false
	return bool(GameState.settings.get(AYAR, true))


## Ana menü açıldı: ilk seferde (bu açılışta bir kez) denetler.
func menu_acildi() -> void:
	if not _denetlendi and etkin():
		denetle()


func denetle() -> void:
	if _denetlendi:
		return
	_denetlendi = true
	durum = D.DENETLENIYOR
	_http = HTTPRequest.new()
	_http.timeout = 8.0
	_http.accept_gzip = true
	add_child(_http)
	_http.request_completed.connect(_denetim_bitti)
	var url := kaynak if kaynak != "" else MANIFEST_URL
	var err := _http.request(url, _basliklar())
	if err != OK:
		_denetim_bitti(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())


func _basliklar() -> PackedStringArray:
	return PackedStringArray(["User-Agent: GercekTarihBuDegil/" + (yerel if yerel != "" else "0")])


func _denetim_bitti(sonuc: int, kod: int, _h: PackedStringArray, govde: PackedByteArray) -> void:
	if is_instance_valid(_http):
		_http.queue_free()
	_http = null
	var m := {}
	if sonuc == HTTPRequest.RESULT_SUCCESS and kod == 200:
		m = manifest_coz(govde.get_string_from_utf8())
	var uzak := String(m.get("surum", "yok"))
	var yeni := not m.is_empty() and yeni_mi(uzak, yerel)
	var aciklama := ""
	if m.is_empty():
		aciklama = "manifest yok -> yeni yok" if (sonuc == HTTPRequest.RESULT_SUCCESS and kod == 404) else \
			("ag yok/bozuk -> yeni yok" if sonuc != HTTPRequest.RESULT_SUCCESS else "manifest okunamadi -> yeni yok")
	_yaz("uzak=%s yerel=%s yeni=%s sonuc=%d kod=%d%s" % [uzak, yerel, "evet" if yeni else "hayir", sonuc, kod,
		(" (" + aciklama + ")") if aciklama != "" else ""])
	if yalniz_denetle:
		get_tree().quit(0)
		return
	if not yeni:
		durum = D.BOS
		_yayinla()
		if oto:
			get_tree().quit(0)
		return
	manifest = m
	var plat := platform()
	girdi = m.get(plat, {})
	var klasor := exe.get_base_dir()
	var paket := OS.has_feature("template") and not OS.has_feature("editor")
	neden = onkosul(m, plat, motor_surumu(), paket and yazilir_mi(klasor), bos_yer(klasor) if paket else 0, paket)
	durum = D.YENI
	_yayinla()
	if oto:
		if neden != "":
			_yaz("sayfa neden=%s" % neden)
			get_tree().quit(3)
		else:
			indir()


# ---------------------------------------------------------------- indirme

func indirme_url() -> String:
	var ad := String(girdi.get("ad", ""))
	if kaynak != "":
		return kaynak.get_base_dir() + "/" + ad.uri_encode()
	return DEPO + "/releases/download/v%s/%s" % [String(manifest["surum"]), ad.uri_encode()]


func indir() -> void:
	if durum != D.YENI or neden != "" or girdi.is_empty():
		return
	var url := indirme_url()
	var ok := url.begins_with(INDIRME_ONEK) if kaynak == "" else kaynak_gecerli(url)
	if not ok:
		_sayfa("UI_GUNC_N_ADRES")
		return
	_http_indir = HTTPRequest.new()
	_http_indir.download_file = exe + ".yeni"
	_http_indir.use_threads = true
	_http_indir.timeout = 0.0
	_http_indir.accept_gzip = false
	_http_indir.download_chunk_size = PARCA
	add_child(_http_indir)
	_http_indir.request_completed.connect(_indirme_bitti)
	toplam = int(girdi["boyut"])
	indirilen = 0
	kalan_sn = -1.0
	_hiz = 0.0
	_bekci_bayt = -1
	_bekci_ms = Time.get_ticks_msec()
	_hiz_ms = _bekci_ms
	_hiz_bayt = 0
	var err := _http_indir.request(url, _basliklar())
	if err != OK:
		_indirme_kapat()
		_sayfa("UI_GUNC_N_INDIRME")
		return
	durum = D.INDIRILIYOR
	_yaz("indiriliyor url=%s boyut=%d" % [url, toplam])
	_yayinla()


func iptal() -> void:
	if durum == D.INDIRILIYOR:
		_indirme_kapat()
		durum = D.YENI
		_yaz("iptal")
		_yayinla()


func _indirme_kapat() -> void:
	if is_instance_valid(_http_indir):
		_http_indir.cancel_request()
		_http_indir.queue_free()
	_http_indir = null
	_yeni_sil()


func _yeni_sil() -> void:
	if FileAccess.file_exists(exe + ".yeni"):
		DirAccess.remove_absolute(exe + ".yeni")


func _process(_d: float) -> void:
	var simdi := Time.get_ticks_msec()
	if durum == D.INDIRILIYOR and is_instance_valid(_http_indir):
		var b := _http_indir.get_downloaded_bytes()
		indirilen = b
		if b != _bekci_bayt:
			_bekci_bayt = b
			_bekci_ms = simdi
		elif simdi - _bekci_ms > int(TAKILMA_SN * 1000.0):
			_indirme_kapat()
			_sayfa("UI_GUNC_N_TAKILDI")
			return
		if simdi - _hiz_ms >= 1000:
			var anlik := float(b - _hiz_bayt) / ((simdi - _hiz_ms) / 1000.0)
			_hiz = anlik if _hiz <= 0.0 else lerpf(_hiz, anlik, 0.3)
			_hiz_ms = simdi
			_hiz_bayt = b
			kalan_sn = (toplam - b) / _hiz if _hiz > 1.0 else -1.0
		if simdi - _yayin_ms >= 250:
			_yayinla()
	elif durum == D.DOGRULANIYOR:
		indirilen = _ozet_bayt
		if _ozet_is != null and not _ozet_is.is_alive():
			var h: String = _ozet_is.wait_to_finish()
			_ozet_is = null
			_dogrulama_bitti(h)
		elif simdi - _yayin_ms >= 250:
			_yayinla()


func _indirme_bitti(sonuc: int, kod: int, _h: PackedStringArray, _g: PackedByteArray) -> void:
	if durum != D.INDIRILIYOR:
		return
	if is_instance_valid(_http_indir):
		_http_indir.queue_free()
	_http_indir = null
	if sonuc != HTTPRequest.RESULT_SUCCESS or kod != 200:
		_yaz("indirme hatasi sonuc=%d kod=%d" % [sonuc, kod])
		_yeni_sil()
		_sayfa("UI_GUNC_N_INDIRME")
		return
	# Dosya kapandıktan sonra (bir kare) boyut ve özet
	await get_tree().process_frame
	var yol := exe + ".yeni"
	var f := FileAccess.open(yol, FileAccess.READ)
	var n := f.get_length() if f != null else -1
	if f != null:
		f.close()
	if n != toplam:
		_yaz("boyut tutmadi %d != %d" % [n, toplam])
		_yeni_sil()
		_sayfa("UI_GUNC_N_BOZUK")
		return
	durum = D.DOGRULANIYOR
	_ozet_bayt = 0
	_ozet_is = Thread.new()
	_ozet_is.start(_ozet.bind(yol, func(p: int): _ozet_bayt = p))
	_yayinla()


func _dogrulama_bitti(h: String) -> void:
	var yol := exe + ".yeni"
	if h == "" or h != String(girdi["sha256"]):
		_yaz("sha256 tutmadi %s != %s" % [h, girdi["sha256"]])
		_yeni_sil()
		_sayfa("UI_GUNC_N_BOZUK")
		return
	if platform() != "windows":
		# 0o755; FAT/exFAT'te chmod düşebilir: çalıştırma biti yoksa yerinde güncelleme yok
		var err := FileAccess.set_unix_permissions(yol, 493)
		if err != OK and (FileAccess.get_unix_permissions(yol) & 64) == 0:
			_yeni_sil()
			_sayfa("UI_GUNC_N_IZIN")
			return
	_yaz("dogrulandi sha256=%s" % h)
	durum = D.HAZIR
	_yayinla()
	if oto:
		uygula.call_deferred()


# ---------------------------------------------------------------- değiştirme

## Oyuncu onayladı (ya da oto kip): dosyalar yer değiştirir, yeni süreç başlar, oyun kapanır. Tek işlev, arada await yok.
func uygula() -> void:
	if durum != D.HAZIR:
		return
	if GameState.changing:
		return
	var args := PackedStringArray(["--headless", "--", "--guncelleme-surum-yaz"]) if oto else PackedStringArray()
	var e := exe
	var r := dosyalari_degistir(e)
	if r != "":
		_yeni_sil()
		_sayfa(r)
		return
	var pid := OS.create_process(e, args)
	if pid == -1:
		baslatma_geri_al(e)
		_yeni_sil()
		_sayfa("UI_GUNC_N_BASLATMA")
		return
	_yaz("degistirildi pid=%d" % pid)
	get_tree().quit(0)


func _sayfa(n: String) -> void:
	neden = n
	durum = D.SAYFA
	gizli = false
	_yaz("sayfa neden=%s" % n)
	_yayinla()
	if oto:
		get_tree().quit(3)


func _yayinla() -> void:
	_yayin_ms = Time.get_ticks_msec()
	degisti.emit()


func _yaz(s: String) -> void:
	if oto or yalniz_denetle or surum_yaz:
		print("GUNCELLEME " + s)


func sayfayi_ac() -> void:
	OS.shell_open(SAYFA_URL)


## "Ne değişti?": sitenin sürüm notu (data/changelog.json, sürüm → {tr, en}); alınamazsa sürüm sayfası açılır.
func degisiklik_iste() -> void:
	if degisiklik != "" or is_instance_valid(_http_not):
		return
	degisiklik = "…"
	_yayinla()
	_http_not = HTTPRequest.new()
	_http_not.timeout = 8.0
	add_child(_http_not)
	_http_not.request_completed.connect(_degisiklik_geldi)
	var url := (kaynak.get_base_dir() + "/changelog.json") if kaynak != "" else DEGISIKLIK_URL
	if _http_not.request(url, _basliklar()) != OK:
		_degisiklik_geldi(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())


func _degisiklik_geldi(sonuc: int, kod: int, _h: PackedStringArray, govde: PackedByteArray) -> void:
	if is_instance_valid(_http_not):
		_http_not.queue_free()
	_http_not = null
	var metin := ""
	if sonuc == HTTPRequest.RESULT_SUCCESS and kod == 200:
		var js := JSON.new()
		var j: Variant = js.data if js.parse(govde.get_string_from_utf8()) == OK else null
		if j is Dictionary:
			var e: Variant = (j as Dictionary).get(String(manifest.get("surum", "")))
			if e is Dictionary:
				var dil := "tr" if TranslationServer.get_locale().begins_with("tr") else "en"
				var t: Variant = (e as Dictionary).get(dil, (e as Dictionary).get("tr"))
				if t is String:
					metin = t
	if metin.strip_edges() == "":
		degisiklik = ""
		_yayinla()
		sayfayi_ac()
		return
	degisiklik = metin
	_yayinla()


# ---------------------------------------------------------------- menü bandı

const C_KREM := Color("f2e6c9")
const C_VURGU := Color("6ff2c8")
const C_SOLUK := Color(1, 1, 1, 0.6)
const BANT_EN := 500.0


## Ana menünün sağ üst köşesindeki bant. Güncelleyicinin durumuna göre kendini yeniler; gösterilecek bir şey yoksa gizli.
func bant() -> Control:
	menu_acildi()
	var p := PanelContainer.new()
	p.name = "GuncellemeBandi"
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.09, 0.9)
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(14)
	sb.border_width_left = 4
	sb.border_color = C_VURGU
	p.add_theme_stylebox_override("panel", sb)
	p.custom_minimum_size = Vector2(BANT_EN, 0)
	p.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	p.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	p.offset_left = -24.0 - BANT_EN
	p.offset_right = -24.0
	p.offset_top = 24.0
	p.offset_bottom = 24.0
	var kutu := VBoxContainer.new()
	kutu.add_theme_constant_override("separation", 8)
	p.add_child(kutu)
	var yenile := func(): _bant_doldur(p, kutu)
	degisti.connect(yenile)
	p.tree_exiting.connect(func():
		if degisti.is_connected(yenile):
			degisti.disconnect(yenile))
	_bant_doldur(p, kutu)
	return p


func _bant_doldur(p: PanelContainer, kutu: VBoxContainer) -> void:
	var goster := not gizli and durum in [D.YENI, D.INDIRILIYOR, D.DOGRULANIYOR, D.HAZIR, D.SAYFA]
	p.visible = goster
	if not goster:
		return
	# İlerleme sırasında yalnız çubuk ve yazı güncellenir (düğmeler yeniden kurulursa odak kaybolur)
	if durum in [D.INDIRILIYOR, D.DOGRULANIYOR] and p.has_meta("durum") and int(p.get_meta("durum")) == durum:
		var bar := kutu.get_node_or_null("Cubuk") as ProgressBar
		var yazi := kutu.get_node_or_null("Ilerleme") as Label
		if bar and yazi:
			bar.value = _oran() * 100.0
			yazi.text = _ilerleme_metni()
			return
	p.set_meta("durum", durum)
	for c in kutu.get_children():
		kutu.remove_child(c)
		c.queue_free()
	var tr_mi := TranslationServer.get_locale().begins_with("tr")
	var uzak := "v" + String(manifest.get("surum", "?"))
	var sende := "v" + yerel
	match durum:
		D.YENI:
			var bas := tr("UI_GUNC_YENI") % [uzak, sende]
			if not girdi.is_empty():
				bas += "  ·  ≈" + boyut_metni(int(girdi["boyut"]), tr_mi).replace(" ", "\u00a0")
			_yazi(kutu, bas, 19, C_KREM)
			if neden != "":
				_yazi(kutu, tr(neden), 15, Color("ffc98a"))
			var sira := _sira(kutu)
			if neden == "":
				_dugme(sira, tr("UI_GUNC_GUNCELLE"), indir, true)
			else:
				_dugme(sira, tr("UI_GUNC_SAYFA"), sayfayi_ac, true)
			_dugme(sira, tr("UI_GUNC_NE_DEGISTI"), degisiklik_iste)
			_dugme(sira, tr("UI_GUNC_SONRA"), _sonra)
			_not_alani(kutu)
		D.INDIRILIYOR, D.DOGRULANIYOR:
			_yazi(kutu, tr("UI_GUNC_INDIRILIYOR" if durum == D.INDIRILIYOR else "UI_GUNC_DOGRULANIYOR") % uzak, 19, C_KREM)
			var bar := ProgressBar.new()
			bar.name = "Cubuk"
			bar.min_value = 0.0
			bar.max_value = 100.0
			bar.show_percentage = false
			bar.custom_minimum_size = Vector2(0, 14)
			var arka := StyleBoxFlat.new()
			arka.bg_color = Color(1, 1, 1, 0.08)
			arka.set_corner_radius_all(4)
			var dolu := StyleBoxFlat.new()
			dolu.bg_color = C_VURGU
			dolu.set_corner_radius_all(4)
			bar.add_theme_stylebox_override("background", arka)
			bar.add_theme_stylebox_override("fill", dolu)
			bar.value = _oran() * 100.0
			kutu.add_child(bar)
			var yazi := _yazi(kutu, _ilerleme_metni(), 15, C_SOLUK)
			yazi.name = "Ilerleme"
			_yazi(kutu, tr("UI_GUNC_OYNA_NOT"), 14, C_SOLUK)
			if durum == D.INDIRILIYOR:
				_dugme(_sira(kutu), tr("UI_GUNC_IPTAL"), iptal)
		D.HAZIR:
			_yazi(kutu, tr("UI_GUNC_HAZIR") % uzak, 18, C_KREM)
			var sira := _sira(kutu)
			_dugme(sira, tr("UI_GUNC_KUR"), uygula, true)
			_dugme(sira, tr("UI_GUNC_SONRA"), _sonra)
		D.SAYFA:
			_yazi(kutu, tr("UI_GUNC_OLMADI") % tr(neden), 17, Color("ffc98a"))
			var sira := _sira(kutu)
			_dugme(sira, tr("UI_GUNC_SAYFA"), sayfayi_ac, true)
			_dugme(sira, tr("UI_GUNC_SONRA"), _sonra)
	p.reset_size()


func _not_alani(kutu: VBoxContainer) -> void:
	if degisiklik == "":
		return
	if degisiklik == "…":
		_yazi(kutu, tr("UI_GUNC_NOT_YUKLENIYOR"), 14, C_SOLUK)
		return
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.custom_minimum_size = Vector2(0, 220)
	kutu.add_child(sc)
	var l := Label.new()
	l.text = degisiklik
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", C_KREM)
	sc.add_child(l)
	_dugme(_sira(kutu), tr("UI_GUNC_KAPAT"), func():
		degisiklik = ""
		_yayinla())


func _sonra() -> void:
	gizli = true
	_yayinla()


func _oran() -> float:
	return clampf(float(indirilen) / float(maxi(toplam, 1)), 0.0, 1.0)


func _ilerleme_metni() -> String:
	var mb := "%d / %d MB" % [int(indirilen / 1.0e6), int(toplam / 1.0e6)]
	if durum != D.INDIRILIYOR or kalan_sn < 0.0:
		return mb
	var k := ""
	if kalan_sn < 90.0:
		k = tr("UI_GUNC_SN") % maxi(1, int(kalan_sn))
	else:
		k = tr("UI_GUNC_DK") % int(ceil(kalan_sn / 60.0))
	return tr("UI_GUNC_ILERLEME") % [mb, k]


func _yazi(kutu: VBoxContainer, metin: String, boy: int, renk: Color) -> Label:
	var l := Label.new()
	l.text = metin
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(BANT_EN - 32.0, 0)
	l.add_theme_font_size_override("font_size", boy)
	l.add_theme_color_override("font_color", renk)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_y", 2)
	kutu.add_child(l)
	return l


func _sira(kutu: VBoxContainer) -> HFlowContainer:
	var h := HFlowContainer.new()
	h.add_theme_constant_override("h_separation", 8)
	h.add_theme_constant_override("v_separation", 6)
	kutu.add_child(h)
	return h


func _dugme(sira: Control, metin: String, cb: Callable, ana := false) -> Button:
	var b := Button.new()
	b.text = metin
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_color_override("font_color", Color(0.05, 0.06, 0.09) if ana else C_KREM)
	b.add_theme_color_override("font_hover_color", Color.BLACK if ana else Color.WHITE)
	b.add_theme_color_override("font_focus_color", Color.BLACK if ana else Color.WHITE)
	for st in ["normal", "hover", "focus", "pressed"]:
		var s := StyleBoxFlat.new()
		s.set_corner_radius_all(6)
		s.content_margin_left = 14
		s.content_margin_right = 14
		s.content_margin_top = 5
		s.content_margin_bottom = 5
		var acik: bool = st != "normal"
		s.bg_color = (C_VURGU.lightened(0.2) if acik else C_VURGU) if ana else Color(1, 1, 1, 0.16 if acik else 0.07)
		if acik:
			s.border_width_bottom = 2
			s.border_color = Color.WHITE if ana else C_VURGU
		b.add_theme_stylebox_override(st, s)
	b.pressed.connect(func():
		Audio.sfx("ui_confirm", -8.0)
		cb.call())
	sira.add_child(b)
	return b
