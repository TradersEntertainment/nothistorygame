extends Node
## İSTANBUL v2 GÖRSEL DİL (BİRLİK): şehrin bütün parçalarının TEK oyunun parçası gibi görünmesi için ortak kural.
## Belge: docs/ISTANBUL_GORSEL_DIL.md. class_name YOK (preload ile kullanılır: const GD := preload(".../gorsel_dil.gd")).
##
## Ne yapar
##   * PALET: adlı 28 renk (taş 5, sıva 3, kiremit 2, ahşap 3, toprak 4, ot 3, kumaş boyası 6, metal 2); renk(ad).
##   * KURAL: kategori başına doygunluk tavanı, parlaklık aralığı (sRGB HSV), ayrıntı dokusu ve 10 m'deki öğe boyu,
##     yıpranma (kir aşağıda, güneş solması yukarıda). Ölçü: yayındaki bölümler (Bölüm 24, 8, 8y, 9, 4, 12b).
##   * Ortak malzeme: StandardMaterial3D'ler aynı toon gölgelendiriciye (yayındaki Props.mat ile aynı ayar: toon
##     gölgeleme + toon parlama, pürüz 0,9, kenar ışığı 0,2 / 0,6; dış çizgi kaynağınki) çevrilir; var olan
##     gölgelendiricilere (sur taşı, zemin, insan, bez, bitki) aynı son işlem eklenir (kopya gölgelendirici; yayındaki
##     bölümlerin gölgelendiricisi değişmez).
##   * Uyum geçişi (kur): dünya kurulduktan sonra ve akışla eklenen her parça için düğüm ağacını gezer, her ağ
##     malzemesini kategorisine ayırır (grup, düğüm adı, kurucu betik, malzeme deseni/gölgelendiricisi; en son renk) ve
##     kurala çeker. Malzemeler önbellekli (aynı kaynak + kategori → aynı uyumlu kopya): çizim çağrısı ARTMAZ.
##   * Çadır dili: IstHayat'ın çadır/sancak kayıtları sur kuşağından (12 m) ve hendekten kaldırılır, çadır gövdeleri
##     keten/devetüyü/boz tonlarına çekilir, kutu gövdeli çadır ağı yuvarlak alaçıkla değiştirilir (KUTU YASAĞI).

const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")
const OTURTMA := preload("res://scripts/world/ist/sur_oturtma.gd")

# ------------------------------------------------------------------ palet (28 renk, sRGB)

const PALET := {
	# taş (5): kireçtaşı, koyu kireçtaşı, gri moloz, kumtaşı, harç
	"tas_kirec": Color("b2a58b"), "tas_kirec_koyu": Color("8b806c"), "tas_gri": Color("878277"),
	"tas_kumtasi": Color("b09670"), "tas_harc": Color("c2b79f"),
	# sıva (3): kirli kireç badana, aşı boyası (okra), soluk gül
	"siva_kirec": Color("cbbea4"), "siva_asi": Color("b99467"), "siva_gul": Color("b48c7a"),
	# kiremit (2)
	"kiremit": Color("9a5a44"), "kiremit_koyu": Color("764434"),
	# ahşap (3): yeni, yıllanmış, karaarmış
	"ahsap_acik": Color("9a7b58"), "ahsap": Color("76593d"), "ahsap_koyu": Color("52402d"),
	# toprak (4): toprak, kuru toprak, çamur, çakıl
	"toprak": Color("8a7358"), "toprak_kuru": Color("a6926e"), "camur": Color("5c4b3a"), "cakil": Color("938876"),
	# ot (3): bahar otu (soluk), koyu ot, kuru ot
	"ot": Color("7b8653"), "ot_koyu": Color("5a683f"), "ot_kuru": Color("a19865"),
	# kumaş (6): ağartılmamış keten (kirli beyaz), devetüyü keçe, boz yün; dönem boyaları (soluk): kök boya, çivit, cehri
	"keten": Color("d3c9b1"), "devetuyu": Color("b39a75"), "boz": Color("8b8070"),
	"kokboya": Color("8f4434"), "civit": Color("4d5b74"), "cehri": Color("b29c58"),
	# metal (2)
	"demir": Color("4d4b48"), "bakir": Color("946543"),
}


static func renk(ad: String) -> Color:
	return PALET.get(ad, Color(1, 0, 1))


# ------------------------------------------------------------------ kural

## Kategori: sat (doygunluk tavanı, sRGB HSV), v0..v1 (parlaklık aralığı), detay (ayrıntı dokusu), olcek (dokunun
## bir döşemesi kaç metre), guc (ayrıntı genliği), oge (10 m'de öğe boyu, m; belge için), kir/kir_h (dipte kir, model
## y), gunes (yukarı bakan yüzde solma), karsit (desenli dokuda karşıtlık çarpanı), ton (renk sıcaklığı çarpanı).
## v1 ≤ 0,88 (saf beyaz yasak), v0 ≥ 0,06 (saf siyah yasak).
const KURAL := {
	"tas": {"sat": 0.34, "v0": 0.2, "v1": 0.8, "detay": "tas", "olcek": 2.4, "guc": 0.16, "oge": 0.45, "kir": 0.0,
		"kir_h": 1.2, "gunes": 0.08, "karsit": 0.7, "ton": Color(1.03, 1.0, 0.94)},
	"siva": {"sat": 0.34, "v0": 0.25, "v1": 0.74, "detay": "siva", "olcek": 3.2, "guc": 0.14, "oge": 0.8, "kir": 0.0,
		"kir_h": 1.0, "gunes": 0.08, "karsit": 0.7, "ton": Color(1, 1, 1)},
	"kiremit": {"sat": 0.50, "v0": 0.20, "v1": 0.70, "detay": "tas", "olcek": 1.6, "guc": 0.12, "oge": 0.3, "kir": 0.0,
		"kir_h": 1.0, "gunes": 0.10, "karsit": 0.7, "ton": Color(1, 1, 1)},
	"ahsap": {"sat": 0.46, "v0": 0.12, "v1": 0.70, "detay": "ahsap", "olcek": 1.6, "guc": 0.20, "oge": 0.2, "kir": 0.25,
		"kir_h": 0.5, "gunes": 0.12, "karsit": 0.75, "ton": Color(1, 1, 1)},
	"zemin": {"sat": 0.40, "v0": 0.14, "v1": 0.66, "detay": "toprak", "olcek": 2.4, "guc": 0.34, "oge": 0.3, "kir": 0.0,
		"kir_h": 1.0, "gunes": 0.0, "karsit": 0.8, "ton": Color(1, 1, 1)},
	"bitki": {"sat": 0.44, "v0": 0.10, "v1": 0.70, "detay": "ot", "olcek": 2.8, "guc": 0.12, "oge": 0.5, "kir": 0.0,
		"kir_h": 1.0, "gunes": 0.06, "karsit": 0.8, "ton": Color(1, 1, 1)},
	"kumas": {"sat": 0.50, "v0": 0.18, "v1": 0.72, "detay": "dokuma", "olcek": 1.2, "guc": 0.16, "oge": 0.6, "kir": 0.55,
		"kir_h": 0.6, "gunes": 0.16, "karsit": 0.75, "ton": Color(0.97, 0.955, 0.92)},
	"kisi": {"sat": 0.52, "v0": 0.08, "v1": 0.84, "detay": "dokuma", "olcek": 0.9, "guc": 0.08, "oge": 0.45, "kir": 0.0,
		"kir_h": 0.3, "gunes": 0.0, "karsit": 0.85, "ton": Color(1, 1, 1)},
	"metal": {"sat": 0.36, "v0": 0.10, "v1": 0.66, "detay": "tas", "olcek": 0.8, "guc": 0.08, "oge": 0.15, "kir": 0.0,
		"kir_h": 0.3, "gunes": 0.0, "karsit": 0.8, "ton": Color(1, 1, 1)},
	"yapi": {"sat": 0.42, "v0": 0.12, "v1": 0.78, "detay": "siva", "olcek": 3.2, "guc": 0.10, "oge": 0.8, "kir": 0.0,
		"kir_h": 1.0, "gunes": 0.06, "karsit": 0.75, "ton": Color(1, 1, 1)},
}
## Kurala girmeyen ama sınıflı olanlar (ışık/efekt/su/gök): dokunulmaz, "kategorisiz" sayılmaz
const MUAF := ["efekt", "su", "gok"]
## Ayrıntının söndüğü uzaklık (m): ötesinde düz renk (mip de ortalamaya iner) — uzakta gürültü yok
const DETAY_UZAK := 70.0
const DETAY_UZAK_ZEMIN := 110.0

# ------------------------------------------------------------------ durum

static var _shaders := {}         # bayrak anahtarı → Shader (StandardMaterial yerine)
static var _enj := {}             # kaynak shader RID + toon → Shader (enjekte kopya) ya da null (enjekte edilemez)
static var _cache := {}           # kaynak malzeme kimliği + kategori + kir → uyumlu malzeme
static var _uyumlu := {}          # uyumlu malzeme kimliği → kategori (yeniden işlenmesin)
static var _detay := {}           # tür → ImageTexture
static var sayac := {}            # denetim sayaçları
static var aktif: Node = null

var kok: Node3D
var _kuyruk: Array = []           # [düğüm, kare]
var _kare := 0
var _hayat_tamam := false
var _isik_tamam := false
var _ilk := false


## Kurucu kancası: IstDunya.build bunu çağırır. Dönen: uyum düğümü (dünyanın çocuğu).
static func kur(dunya: Node3D) -> Node:
	if OS.has_environment("BIRLIK_YOK"):      # sondalar: ÖNCE kareleri (aynı kod yolu, uyum yok)
		return null
	var g = load("res://scripts/world/ist/gorsel_dil.gd").new()
	gece_mod = bool(dunya.get("gece"))
	g.name = "GorselDil"
	g.kok = dunya
	dunya.add_child(g)
	aktif = g
	return g


func _ready() -> void:
	get_tree().node_added.connect(_eklendi)
	process_priority = 1000


func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_eklendi):
		get_tree().node_added.disconnect(_eklendi)
	if aktif == self:
		aktif = null


func _eklendi(n: Node) -> void:
	if n is GeometryInstance3D and kok != null and kok.is_ancestor_of(n):
		_kuyruk.append([n, _kare])


func _process(_dt: float) -> void:
	_kare += 1
	if not _ilk:
		_ilk = true
		for c in kok.find_children("*", "GeometryInstance3D", true, false):
			_tek(c)
		_kuyruk.clear()
	if not _hayat_tamam:
		_hayat_tamam = _hayat_duzen()
	if not _isik_tamam:
		_isik_tamam = _isik()
	if _kare % 8 == 0 and not _bekleyen.is_empty():
		_bekleyenler(false)
	if _kuyruk.is_empty():
		return
	var t0 := Time.get_ticks_usec()
	var kalan: Array = []
	var i := 0
	while i < _kuyruk.size():
		var e: Array = _kuyruk[i]
		i += 1
		# kurucular (pişirme, lod) aynı çağrıda biter; bu düğüm en son işler (process_priority 1000). Sur taşına
		# dönüşecek "ashlar" desenli yüzey beklemeye alınır (sur_doku.uygula kurucunun sonraki adımında çevirir).
		_tek(e[0])
		if Time.get_ticks_usec() - t0 > 4000:
			break
	kalan.append_array(_kuyruk.slice(i))
	_kuyruk = kalan


var _bekleyen := {}               # düğüm kimliği → [düğüm, ilk kare]
const BEKLE_KARE := 30          # sur_doku.uygula en geç 1–2 kare sonra çevirir; ötesi sur olmayan "ashlar" yüzey


func _tek(n: Variant) -> void:
	if not is_instance_valid(n) or not (n as Node).is_inside_tree():
		return
	var gi := n as GeometryInstance3D
	if _sur_bekler(gi):
		if not _bekleyen.has(gi.get_instance_id()):
			_bekleyen[gi.get_instance_id()] = [gi, _kare]
		return
	uyumla_tek(gi)


## Bekleyenler: sur taşına dönmüşse işle; zaman aşımında (ya da zorla) genel kurala çek
func _bekleyenler(zorla: bool) -> void:
	for id in _bekleyen.keys():
		var e: Array = _bekleyen[id]
		var gi = e[0]
		if not is_instance_valid(gi):
			_bekleyen.erase(id)
			continue
		if not (gi as Node).is_inside_tree():
			continue
		var sure := _kare - int(e[1])
		if not _sur_bekler(gi):
			uyumla_tek(gi)
			_bekleyen.erase(id)
		elif (zorla and sure > 10) or sure > BEKLE_KARE:
			_sur_tasina(gi)       # sur_doku.uygula'nın yapacağını yap (dış çizgisiz sur taşı); sonra kural
			uyumla_tek(gi)
			_bekleyen.erase(id)


## Bekleme süresi dolan sur kuşağı yüzeyi: sur_doku.uygula ile aynı çeviri (tur: Galata 2, kara suru kuşağı 0, deniz 1).
## Kuşak dışındaki "ashlar" yüzey (sur olmayan yapı) olduğu gibi kalır; genel kurala uyumla_tek çeker.
static func _sur_tasina(gi: GeometryInstance3D) -> void:
	var p := gi.global_position
	var tur := 2 if IstGeo.galata_ici(p.x, p.z) else (0 if OTURTMA.kusakta(p.x, p.z, 30.0) else -1)
	if tur < 0:
		var y := IstGeo.yol("marmara_suru")
		var y2 := IstGeo.yol("halic_suru")
		var yak := (y.size() > 1 and IstGeo.cizgi_uzak(Vector2(p.x, p.z), y) < 60.0) or (y2.size() > 1 and IstGeo.cizgi_uzak(Vector2(p.x, p.z), y2) < 60.0)
		if not yak:
			return
		tur = 1
	# sur_doku.uygula ile aynı kural (o yalnız çocukları gezer; burada düğümün kendisi)
	var n := 0
	if gi.material_override != null:
		if SURDOKU._desen_mi(gi.material_override):
			var sm := gi.material_override as StandardMaterial3D
			gi.material_override = SURDOKU.mat(tur, Color.WHITE if sm.vertex_color_use_as_albedo else sm.albedo_color)
			n += 1
	elif gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
		var mi := gi as MeshInstance3D
		for si in mi.mesh.get_surface_count():
			var m := mi.get_active_material(si)
			if SURDOKU._desen_mi(m):
				var sm2 := m as StandardMaterial3D
				mi.set_surface_override_material(si, SURDOKU.mat(tur, Color.WHITE if sm2.vertex_color_use_as_albedo else sm2.albedo_color))
				n += 1
	_say("sur_tasina", n)


## Sur kurucusunun (sehir.gd _sur_tas) henüz çevirmediği "ashlar" desenli yüzey var mı
static func _sur_bekler(gi: GeometryInstance3D) -> bool:
	# yalnız şehir kurucusunun (sehir.gd) sur/kapı/kule parçaları; mahalle dokusu ve evler sur değildir
	var p := gi.get_parent()
	var sehir := false
	while p != null:
		var nm := String(p.name)
		if nm.begins_with("IstMahalleDoku") or nm.begins_with("IstEvler") or nm.begins_with("IstOrdugah") or nm.begins_with("IstHayat"):
			return false
		if nm == "IstSehir":
			sehir = true
			break
		p = p.get_parent()
	if not sehir:
		return false
	var ms: Array = []
	if gi.material_override != null:
		ms.append(gi.material_override)
	elif gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
		for si in (gi as MeshInstance3D).mesh.get_surface_count():
			ms.append((gi as MeshInstance3D).get_active_material(si))
	for m in ms:
		if m is StandardMaterial3D and not _uyumlu.has(m.get_instance_id()) and _desen(m as BaseMaterial3D) in ["ashlar", "ashlar_far"]:
			return true
	return false


## Bütün kuyruğu hemen işle (sondalar: kareden önce)
func bitir() -> void:
	if not _ilk:
		_ilk = true
		for c in kok.find_children("*", "GeometryInstance3D", true, false):
			_tek(c)
	for e: Array in _kuyruk:
		_tek(e[0])
	_kuyruk.clear()
	_bekleyenler(true)        # sur taşına dönmüş olanlar + 10 kareden eski bekleyenler (sur olmayan "ashlar" yüzey)
	if not _hayat_tamam:
		_hayat_tamam = _hayat_duzen()
	if not _isik_tamam:
		_isik_tamam = _isik()


# ------------------------------------------------------------------ ışık ve hava

## Yayındaki dış mekân bölümlerinin (ordugâh gündüzü: scripts/level/camp_day.gd _build_sky; şehir: byz_city.gd)
## gök "yer" yarısı (ortam ışığına karışır) sıcak toprak tonudur; v2'ninki mavi-griydi (b8c4c8 / 5a6a70): sur, toprak ve
## çadır gölgede soğuk-mavi kalıyordu. Gündüzde aynı kaynaktan alınır; ortam ışığı ve güneş de aynı ayarda
## (Look.apply_env bölüm havasını sonra yine uygular). Gece: v2'nin kendi gece ayarı kalır.
const ISIK := {"yer_ufuk": Color("cfc4aa"), "yer_dip": Color("7a6a50"), "ortam": 0.52, "gunes": Color("ffe9c7"), "gunes_e": 1.25}

func _isik() -> bool:
	var gok := kok.get_node_or_null("Gok") as WorldEnvironment
	if gok == null or gok.environment == null:
		return false
	if gok.has_meta("look") and String(gok.get_meta("look")) == "night":
		return true
	var e := gok.environment
	if e.sky != null and e.sky.sky_material is ProceduralSkyMaterial:
		var sm := e.sky.sky_material as ProceduralSkyMaterial
		sm.ground_horizon_color = ISIK["yer_ufuk"]
		sm.ground_bottom_color = ISIK["yer_dip"]
	if e.has_meta("look_base"):
		var b: Dictionary = e.get_meta("look_base")
		b["ambient"] = ISIK["ortam"]
		Look.refresh(gok)
	else:
		e.ambient_light_energy = ISIK["ortam"]
	# TUR-6: ortam ışığının yarısı gökten (mavi tepe), yarısı sıcak toprak yansıması: gölgedeki hendek iç yüzü, dibi ve
	# sur eteği teal/kara şerit okunmasın (yayındaki bölümlerin gölgesi sıcak gri)
	e.ambient_light_color = Color("b9a988")
	e.ambient_light_sky_contribution = 0.55
	var g := kok.get_node_or_null("Gunes") as DirectionalLight3D
	if g != null:
		g.light_color = ISIK["gunes"]
		g.light_energy = ISIK["gunes_e"]
	_say("isik", 1)
	return true


## Düğüm ağacının tamamı
static func uyumla(n: Node) -> int:
	var say := 0
	if n is GeometryInstance3D:
		say += uyumla_tek(n as GeometryInstance3D)
	for c in n.find_children("*", "GeometryInstance3D", true, false):
		say += uyumla_tek(c as GeometryInstance3D)
	return say


## Tek geometri: malzemelerini kurala çeker. Dönen: değişen yuva sayısı.
static func uyumla_tek(gi: GeometryInstance3D) -> int:
	if gi.has_meta("birlik_yok"):
		return 0
	var say := 0
	var kir := _kir_uygun(gi)
	if gi.material_override != null:
		var m2 := _uyumlu_malzeme(gi, gi.material_override, kir)
		if m2 != gi.material_override:
			gi.material_override = m2
			say += 1
		return say
	if gi is MeshInstance3D:
		var mi := gi as MeshInstance3D
		if mi.mesh == null:
			return 0
		for si in mi.mesh.get_surface_count():
			var m := mi.get_active_material(si)
			if m == null:
				continue
			var m2 := _uyumlu_malzeme(gi, m, kir)
			if m2 != m:
				mi.set_surface_override_material(si, m2)
				say += 1
	elif gi is MultiMeshInstance3D:
		var mmi := gi as MultiMeshInstance3D
		if mmi.multimesh == null or mmi.multimesh.mesh == null:
			return 0
		var mesh := mmi.multimesh.mesh
		if mesh.get_surface_count() == 1:
			var m := mesh.surface_get_material(0)
			if m != null:
				var m2 := _uyumlu_malzeme(gi, m, kir)
				if m2 != m:
					mmi.material_override = m2     # tek yüzey: üstüne yazma = aynı çizim
					say += 1
		else:
			# çok yüzeyli: ağın uyumlu kopyası (önbellekli; kaynak ağ değişmez, yayındaki bölümler etkilenmez)
			var key := "agk|%d|%s" % [mesh.get_instance_id(), kir]
			var kop: Mesh = _cache.get(key)
			if kop == null:
				kop = mesh.duplicate() as Mesh
				for si in kop.get_surface_count():
					var m := mesh.surface_get_material(si)
					if m != null:
						(kop as ArrayMesh).surface_set_material(si, _uyumlu_malzeme(gi, m, kir))
				_cache[key] = kop
			if mmi.multimesh.mesh != kop:
				mmi.multimesh.mesh = kop
				say += 1
	return say


## Dipte kir için model uzayı y zemin mi (ağ kökü yerde, boyu 25 m'den az)
static func _kir_uygun(gi: GeometryInstance3D) -> bool:
	var ab := AABB()
	if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
		ab = (gi as MeshInstance3D).mesh.get_aabb()
	elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh != null and (gi as MultiMeshInstance3D).multimesh.mesh != null:
		ab = (gi as MultiMeshInstance3D).multimesh.mesh.get_aabb()
	else:
		return false
	return absf(ab.position.y) < 0.6 and ab.size.y < 25.0


# ------------------------------------------------------------------ sınıflandırma

const AD_KUMAS := ["cadir", "çadır", "barinak", "buyuk", "koni", "catma", "kil", "bez", "bayrak", "flama", "otag",
	"tent", "banner", "awning", "cloth", "sancak", "tente", "perde", "yelken", "can", "esir"]
const AD_AHSAP := ["ahsap", "cit", "kereste", "odun", "mancinik", "fici", "kutuk", "sandik", "iskele", "kayik", "tahta",
	"dal", "kutu", "gemi", "sandal", "kadirga", "fusta", "kalyata", "karaka", "kog", "balikci", "parandarya", "araba"]
const AD_ZEMIN := ["zemin", "toprak", "sedde", "hendek", "arazi", "etek", "rampa", "birikinti", "yol", "meydan", "set"]
const AD_TAS := ["tas", "kule", "sur", "duvar", "kemer", "sutun", "cakil"]
const AD_BITKI := ["agac", "servi", "cali", "ot", "bitki", "papatya", "gelincik", "saman", "yaprak", "sarmasik", "bostan"]
const AD_KISI := ["kisi", "insan", "hayvan", "tavuk", "marti", "guvercin", "kus", "at_", "deve", "koyun", "canli",
	"ikiz", "figur", "person", "horse", "wallmen", "crew", "people", "guard", "soldier"]
const AD_METAL := ["demir", "bakir", "kazan", "kap", "gulle", "top_", "zincir"]
const AD_EFEKT := ["ates", "alev", "parilti", "duman", "isik", "pencere", "flame", "glow", "smoke"]


## Kategori (sırayla): efekt/su/gök → kişi (kurucu betik) → desen/gölgelendirici → düğüm adı (kendisi ve 3 ata) →
## kurucu betik → renk tonu
static func kategori(gi: Node, m: Material) -> String:
	# 1. gölgelendirici
	if m is ShaderMaterial:
		var sh := (m as ShaderMaterial).shader
		var p := sh.resource_path.get_file() if sh != null else ""
		match p:
			"flame.gdshader", "ist_duman.gdshader", "time_window.gdshader", "void.gdshader":
				return "efekt"
			"water.gdshader":
				return "su"
			"zemin.gdshader", "zemin_v2.gdshader", "ground.gdshader":
				return "zemin"
			"grass.gdshader":
				return "bitki"
			"ist_insan.gdshader", "ist_kus.gdshader":
				return "kisi"
			"ist_bez.gdshader":
				return "kumas"
		if sh != null and sh == SURDOKU._shader():
			return "tas"
		if sh != null and sh.code.contains("SkyBody") :
			return "gok"
	if m is BaseMaterial3D:
		var bm := m as BaseMaterial3D
		if bm.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED or bm.emission_enabled and bm.emission_energy_multiplier > 0.6:
			return "efekt"
		if not bm.vertex_color_use_as_albedo and bm.albedo_texture == null and _kumas_rengi(bm.albedo_color):
			return "kumas"
		var d := _desen(bm)
		match d:
			"ashlar", "ashlar_far", "rubble", "brick", "tekfur", "marble", "flagstone", "cobble", "concrete":
				return "tas"
			"plaster":
				return "siva"
			"tiles":
				return "kiremit"
			"wood":
				return "ahsap"
	# 2. düğüm adı (kendisi + 3 ata) ve kurucu betik
	var n: Node = gi
	for k in 4:
		if n == null:
			break
		var ad := String(n.name).to_lower()
		var c := _ad_kat(ad)
		if c != "":
			return c
		n = n.get_parent()
	if _ata_betik(gi, KISI_BETIK):
		return "kisi"
	var betik := _betik(gi)
	match betik:
		"sky_body.gd":
			return "gok"
		"gemiler.gd", "gemiler_mesh.gd", "ordugah_donanma.gd":
			return "ahsap"
		"evler.gd", "mahalle_doku.gd", "sokak.gd", "kuzeybati_semt.gd", "halic_mahalle.gd":
			return "yapi"
		"surlar.gd", "surlar_kapi.gd", "sur_kule.gd", "marmara_sur.gd", "halic_sur.gd", "galata_sur.gd":
			return "tas"
		"bitki.gd", "bitki_yama.gd", "bitki_kit.gd":
			return "bitki"
	# 3. renk tonu (köşe rengi beyaz ise yapı: pişmiş birleşik ağ)
	if m is BaseMaterial3D:
		var bm := m as BaseMaterial3D
		var c := bm.albedo_color
		if bm.vertex_color_use_as_albedo and c.s < 0.12:
			return "yapi"
		return _renk_kat(c)
	if m is ShaderMaterial:
		return "yapi"
	return ""


static func _ad_kat(ad: String) -> String:
	for t: String in AD_EFEKT:
		if ad.contains(t):
			return "efekt"
	for t: String in AD_KISI:
		if ad.begins_with(t) or ad.contains("_" + t) or ad.contains(t + "_"):
			return "kisi"
	for t: String in AD_KUMAS:
		if ad == t or ad.begins_with(t) or ad.contains("_" + t) or ad.contains(t + "_"):
			return "kumas"
	for t: String in AD_METAL:
		if ad == t or ad.begins_with(t) or ad.contains("_" + t):
			return "metal"
	for t: String in AD_AHSAP:
		if ad == t or ad.begins_with(t) or ad.contains("_" + t):
			return "ahsap"
	for t: String in AD_BITKI:
		if ad == t or ad.begins_with(t) or ad.contains("_" + t):
			return "bitki"
	for t: String in AD_ZEMIN:
		if ad == t or ad.begins_with(t) or ad.contains("_" + t) or ad.ends_with(t):
			return "zemin"
	for t: String in AD_TAS:
		if ad == t or ad.begins_with(t) or ad.contains("_" + t) or ad.ends_with(t):
			return "tas"
	if ad.begins_with("orduuzak"):
		return "kumas"
	if ad.begins_with("pismis") or ad.begins_with("baked") or ad.begins_with("ogeuzak") or ad.begins_with("ufuk"):
		return "yapi"
	return ""


static func _kumas_rengi(c: Color) -> bool:
	for k: Color in Dressing.CLOTH:
		if absf(k.r - c.r) + absf(k.g - c.g) + absf(k.b - c.b) < 0.02:
			return true
	return false


static func _renk_kat(c: Color) -> String:
	var h := c.h * 360.0
	if c.s < 0.18:
		return "tas"
	if h >= 55.0 and h <= 170.0:
		return "bitki"
	if (h < 22.0 or h > 340.0) and c.s > 0.35:
		return "kiremit"
	if h < 50.0 and c.v < 0.62:
		return "ahsap"
	return "yapi"


const KISI_BETIK := ["person.gd", "ordugah_kisi.gd", "char_kit.gd", "chicken.gd", "hayat_yakin_govde.gd", "canli_kit.gd",
	"soldier.gd", "hikmet.gd", "horse.gd", "cat.gd", "goat.gd", "ox.gd", "thief_gull.gd", "player.gd", "rig.gd", "crowd.gd",
	"pose_crew.gd", "hand_rig.gd"]


## Atalardan biri (8 kuşak) bu betiklerden biriyle mi
static func _ata_betik(gi: Node, liste: Array) -> bool:
	var p := gi.get_parent()
	var k := 0
	while p != null and k < 8:
		var sc: Script = p.get_script()
		if sc != null and sc.resource_path.get_file() in liste:
			return true
		p = p.get_parent()
		k += 1
	return false


static func _betik(gi: Node) -> String:
	var p := gi.get_parent()
	while p != null:
		var sc: Script = p.get_script()
		if sc != null:
			return sc.resource_path.get_file()
		p = p.get_parent()
	return ""


## Props desen dokusunun adı (doku kimliğinden)
static var _desen_ad := {}
static func _desen(bm: BaseMaterial3D) -> String:
	if bm.albedo_texture == null:
		return ""
	if _desen_ad.is_empty():
		for d: String in ["ashlar", "ashlar_far", "rubble", "brick", "tekfur", "marble", "flagstone", "cobble", "plaster",
				"tiles", "wood", "concrete"]:
			var t = Props._pattern_tex(d) if d in Props.PAINTED else Props._noise(d)
			if t != null:
				_desen_ad[(t as Texture2D).get_rid()] = d
	return String(_desen_ad.get(bm.albedo_texture.get_rid(), "doku"))


# ------------------------------------------------------------------ uyumlu malzeme

static func _uyumlu_malzeme(gi: GeometryInstance3D, m: Material, kir: bool) -> Material:
	if _uyumlu.has(m.get_instance_id()):
		return m
	var kat := kategori(gi, m)
	var key := "%d|%s|%s" % [m.get_instance_id(), kat, kir]
	if _cache.has(key):
		return _cache[key]
	_say("kaynak", 1)
	var out: Material = null
	if kat == "" or kat in MUAF:
		_say("kat_" + (kat if kat != "" else "yok"), 1)
		_cache[key] = m
		return m
	_say("kat_" + kat, 1)
	if m is StandardMaterial3D:
		out = _std_cevir(m as StandardMaterial3D, kat, kir)
	elif m is ShaderMaterial:
		out = _sh_cevir(m as ShaderMaterial, kat, kir)
	if out != null:
		_uyumlu[out.get_instance_id()] = kat
		out.set_meta("birlik_kat", kat)
		out.set_meta("birlik_kaynak", m)
	else:
		_say("cevrilemedi", 1)
		out = m
	_cache[key] = out
	return out


static func _say(k: String, n: int) -> void:
	sayac[k] = int(sayac.get(k, 0)) + n


## Kuralın uniformları (ortak)
## TUR-6: gece payları (kategori başına ay ışığı tabanı; kumaşta sızan ışık). Görsel birlik gecede çadır parlaklık ortasını
## 0,18 → 0,07'ye indirmişti (toon + taban sıkıştırması ay ışığında koyu tarafı eziyordu).
static var gece_mod := false
const GECE := {"kumas": 0.16, "zemin": 0.42, "tas": 0.16, "siva": 0.14, "kiremit": 0.12, "ahsap": 0.14, "bitki": 0.12,
	"kisi": 0.14, "metal": 0.1, "yapi": 0.14}

static func _kural_ver(sm: ShaderMaterial, kat: String, kir: bool, dokulu := true) -> void:
	var r: Dictionary = KURAL[kat]
	sm.set_shader_parameter("b9_gece", float(GECE.get(kat, 0.12)) if gece_mod else 0.0)
	sm.set_shader_parameter("b9_sizma", 0.3 if gece_mod and kat == "kumas" else 0.0)
	sm.set_shader_parameter("b9_sat", r["sat"])
	sm.set_shader_parameter("b9_vmin", r["v0"])
	sm.set_shader_parameter("b9_vmax", r["v1"])
	sm.set_shader_parameter("b9_detay", detay_doku(String(r["detay"])))
	sm.set_shader_parameter("b9_olcek", r["olcek"])
	sm.set_shader_parameter("b9_guc", float(r["guc"]) if dokulu else float(r["guc"]) * 0.5)
	sm.set_shader_parameter("b9_d1", DETAY_UZAK)
	sm.set_shader_parameter("b9_kir", float(r["kir"]) if kir else 0.0)
	sm.set_shader_parameter("b9_kir_h", r["kir_h"])
	sm.set_shader_parameter("b9_kir_renk", renk("camur"))
	sm.set_shader_parameter("b9_gunes", r["gunes"])
	sm.set_shader_parameter("b9_ton", r["ton"])


## StandardMaterial3D → ortak toon gölgelendirici
static func _std_cevir(s: StandardMaterial3D, kat: String, kir: bool) -> Material:
	var saydam := s.transparency in [BaseMaterial3D.TRANSPARENCY_ALPHA, BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS]
	if s.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and s.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR and not saydam:
		# karışım türü bilinmeyen saydam (hash vb.): yalnız rengi tavana
		var d := s.duplicate() as StandardMaterial3D
		d.albedo_color = sikistir(s.albedo_color, kat)
		return d
	var tex := s.albedo_texture
	var tri := tex != null and s.uv1_triplanar
	var bay := {
		"vc": s.vertex_color_use_as_albedo, "srgb": s.vertex_color_is_srgb, "tex": tex != null, "tri": tri,
		"dunya": s.uv1_world_triplanar, "cull": int(s.cull_mode), "makas": s.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR,
		"isik": s.emission_enabled, "saydam": saydam, "dif": int(s.diffuse_mode), "spec": int(s.specular_mode),
		"golge_alma": s.disable_receive_shadows, "golgesiz": s.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED, "toon": s.diffuse_mode == BaseMaterial3D.DIFFUSE_TOON or kat in ["kumas", "tas", "ahsap", "siva", "kiremit", "metal", "yapi"],
	}
	var alb := s.albedo_color
	if s == IstOrdugahYonetici._umat and s != null:
		# ordugâhın uzak pişmiş hücre ağı: yakın malzemenin (ordugah_kit vmat) renk uzayı ve çarpanı — köşe rengi doğrusal,
		# 0,78 / 0,76 / 0,72. Kaynakta sRGB ve çarpansızdı: uzaklaşınca çadırlar beyaza patlıyordu.
		bay["srgb"] = false
		alb = Color(0.78, 0.76, 0.72)
		_say("orduuzak_renk", 1)
	var sm := ShaderMaterial.new()
	sm.shader = std_shader(bay)
	sm.set_shader_parameter("albedo", alb)
	if tex != null:
		sm.set_shader_parameter("tex", tex)
		sm.set_shader_parameter("tex_karsit", KURAL[kat]["karsit"])
	sm.set_shader_parameter("uv1_scale", s.uv1_scale)
	sm.set_shader_parameter("uv1_offset", s.uv1_offset)
	sm.set_shader_parameter("tri_sharp", s.uv1_triplanar_sharpness)
	sm.set_shader_parameter("makas_esik", s.alpha_scissor_threshold)
	if s.emission_enabled:
		sm.set_shader_parameter("isik_renk", s.emission * s.emission_energy_multiplier)
	_kural_ver(sm, kat, kir, tex != null)
	sm.next_pass = s.next_pass
	sm.render_priority = s.render_priority
	return sm


## Var olan gölgelendirici: aynı son işlem eklenmiş kopya. v2'nin kendi malzemesiyse yerinde (sonradan gelen
## parametre güncellemeleri kaybolmasın), ortak/yayındaki malzemeyse kopya.
static func _sh_cevir(m: ShaderMaterial, kat: String, kir: bool) -> Material:
	if m.shader == null:
		return null
	var toon := kat == "kumas"      # kişi kendi gölgelemesinde kalır (zorla toon: güneş arkadayken kapkara siluet)
	var sur := m.shader == SURDOKU._shader()
	var sh := enjekte(m.shader, toon)
	if sh == null:
		return null
	var yerinde := _v2_malzemesi(m)
	var out := m if yerinde else (m.duplicate() as ShaderMaterial)
	out.shader = sh
	_kural_ver(out, kat, kir)
	if kat == "zemin":
		out.set_shader_parameter("b9_guc", KURAL["zemin"]["guc"])
		out.set_shader_parameter("b9_d1", DETAY_UZAK_ZEMIN)
	if kat == "tas" and sur:
		# sur taşı: blok blok sert ton farkı ("piksel/dama") ölçüye iner; taşın ortalaması korunur
		out.set_shader_parameter("b9_karsit", KURAL["tas"]["karsit"])
		out.set_shader_parameter("b9_ort", renk("tas_kirec_koyu"))
		out.set_shader_parameter("b9_guc", 0.10)
	return out


static func _v2_malzemesi(m: ShaderMaterial) -> bool:
	var sh := m.shader
	if sh == SURDOKU._shader():
		return true
	var p := sh.resource_path.get_file()
	if p in ["ist_insan.gdshader", "ist_bez.gdshader", "ist_kus.gdshader"]:
		return true
	if p == "zemin_v2.gdshader":
		return true
	if p == "zemin.gdshader":
		return m == load("res://scripts/level/zemin.gd").v2_malzeme()
	return false


## Bir rengi kategorinin tavanına sıkıştır (GDScript eşi; saydam malzeme ve denetim için)
static func sikistir(c: Color, kat: String) -> Color:
	if not KURAL.has(kat):
		return c
	var r: Dictionary = KURAL[kat]
	return Color.from_hsv(c.h, _ust(c.s, float(r["sat"])), _alt(_ust(c.v, float(r["v1"])), float(r["v0"])), c.a)


static func _ust(x: float, hi: float) -> float:
	var k := hi * 0.7
	return x if x <= k else k + (hi - k) * (1.0 - exp(-(x - k) / maxf(hi - k, 1e-3)))


static func _alt(x: float, lo: float) -> float:
	var k := lo * 2.0
	return x if x >= k else lo + (k - lo) * (x / maxf(k, 1e-3))


# ------------------------------------------------------------------ gölgelendiriciler

const ORTAK := """
// ---- BİRLİK (scripts/world/ist/gorsel_dil.gd): ortak görsel kural ----
uniform float b9_sat = 1.0;
uniform float b9_vmin = 0.0;
uniform float b9_vmax = 1.0;
uniform float b9_karsit = 1.0;
uniform vec4 b9_ort : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform sampler2D b9_detay : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float b9_olcek = 2.0;
uniform float b9_guc = 0.0;
uniform float b9_d1 = 70.0;
uniform float b9_kir = 0.0;
uniform float b9_kir_h = 0.7;
uniform vec4 b9_kir_renk : source_color = vec4(0.36, 0.29, 0.23, 1.0);
uniform float b9_gunes = 0.0;
uniform vec4 b9_ton : source_color = vec4(1.0);
uniform float b9_gece = 0.0;      // TUR-6: gece ay ışığı tabanı (öz-ışık payı; gündüz 0)
uniform float b9_sizma = 0.0;     // TUR-6: gece çadır içinden sızan sıcak ışık (kumaş)
varying float b9_ly;

vec3 b9_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 1e-6)), d / (q.x + 1e-6), q.x);
}
vec3 b9_rgb(vec3 c) {
	vec3 p = abs(fract(c.xxx + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
	return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}
// yumuşak dirsek: tavanın %70'inden sonra üstel sıkıştırma (sert kırpma dokuyu siler); altta doğrusal kaldırma
float b9_ust(float x, float hi) {
	float k = hi * 0.7;
	return x <= k ? x : k + (hi - k) * (1.0 - exp(-(x - k) / max(hi - k, 1e-3)));
}
float b9_alt(float x, float lo) {
	float k = lo * 2.0;
	return x >= k ? x : lo + (k - lo) * (x / max(k, 1e-3));
}
vec3 b9_uygula(vec3 c, vec3 vtx, vec3 nrm, mat4 ivm, float ly) {
	vec3 wp = (ivm * vec4(vtx, 1.0)).xyz;
	vec3 wn = normalize((ivm * vec4(nrm, 0.0)).xyz);
	float dist = length(vtx);
	c = mix(b9_ort.rgb, c, b9_karsit);
	if (b9_guc > 0.001) {
		vec3 w = pow(abs(wn), vec3(4.0));
		w /= (w.x + w.y + w.z + 1e-4);
		vec3 q = wp / b9_olcek;
		float d = texture(b9_detay, q.zy).r * w.x + texture(b9_detay, q.xz).r * w.y + texture(b9_detay, q.xy).r * w.z;
		float f = 1.0 - smoothstep(b9_d1 * 0.35, b9_d1, dist);
		c *= 1.0 + (d - 0.5) * 2.0 * b9_guc * f;
	}
	if (b9_kir > 0.001) {
		float t = 1.0 - smoothstep(0.0, b9_kir_h, ly);
		c = mix(c, b9_kir_renk.rgb, t * t * b9_kir);
	}
	if (b9_gunes > 0.001) {
		float up = smoothstep(0.25, 0.95, wn.y);
		float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
		c = mix(c, mix(vec3(l), c, 0.55) * 1.12, up * b9_gunes);
	}
	c *= b9_ton.rgb;
	vec3 s = pow(max(c, vec3(0.0)), vec3(1.0 / 2.2));
	vec3 h = b9_hsv(s);
	h.y = b9_ust(h.y, b9_sat);
	h.z = b9_alt(b9_ust(h.z, b9_vmax), b9_vmin);
	return pow(b9_rgb(h), vec3(2.2));
}
// TUR-6: gece okunurluğu — ay ışığı tabanı (soğuk, düşük) + kumaşta alt kısımdan sızan ocak/kandil ışığı (çadır başına
// rastgele: her çadır yanmaz)
vec3 b9_gece_isik(vec3 alb, vec3 vtx, mat4 ivm, float ly) {
	if (b9_gece <= 0.0) { return vec3(0.0); }
	vec3 wp = (ivm * vec4(vtx, 1.0)).xyz;
	vec3 e = alb * vec3(0.62, 0.7, 0.95) * b9_gece;
	if (b9_sizma > 0.0) {
		vec2 hc = floor(wp.xz / 7.0);
		float hs = fract(sin(dot(hc, vec2(127.1, 311.7))) * 43758.5453);
		float alt = 1.0 - smoothstep(0.1, 1.5, ly);
		e += vec3(1.0, 0.56, 0.24) * step(0.68, hs) * alt * b9_sizma * (0.55 + 0.45 * alb.r);
	}
	return e;
}
// ---- BİRLİK sonu ----
"""


## StandardMaterial3D'nin yerine geçen ortak toon gölgelendirici (bayrak başına bir Shader)
static func std_shader(bay: Dictionary) -> Shader:
	var key := str(bay)
	if _shaders.has(key):
		return _shaders[key]
	var cull: String = ["cull_back", "cull_front", "cull_disabled"][clampi(int(bay["cull"]), 0, 2)]
	# dağınık ışık ve parlama kaynağınki (kumaş/taş/ahşap/sıva/kiremit/metal/yapı toon'a çekilir); gölge almayan kaynak
	# (kişi: CharKit.vc_mat) gölge almaz — yoksa figürler çadır ve öz gölgede kararıyor
	var DIF := ["diffuse_burley", "diffuse_lambert", "diffuse_lambert_wrap", "diffuse_toon"]
	var SPC := ["specular_schlick_ggx", "specular_toon", "specular_disabled"]
	var dif: String = "diffuse_toon, specular_toon" if bay["toon"] else "%s, %s" % [DIF[clampi(int(bay.get("dif", 1)), 0, 3)], SPC[clampi(int(bay.get("spec", 2)), 0, 2)]]
	if bay.get("golge_alma", false):
		dif += ", shadows_disabled"
	var c := "shader_type spatial;\nrender_mode %s, %s, %s;\n" % [dif, cull, "blend_mix, depth_draw_never" if bay.get("saydam", false) else "depth_draw_opaque"]
	c += "uniform vec4 albedo : source_color = vec4(1.0);\n"
	c += "uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;\n"
	c += "uniform float tex_karsit = 1.0;\nuniform vec3 uv1_scale = vec3(1.0);\nuniform vec3 uv1_offset = vec3(0.0);\n"
	c += "uniform float tri_sharp = 1.0;\nuniform float makas_esik = 0.5;\nuniform vec4 isik_renk : source_color = vec4(0.0);\n"
	c += ORTAK
	if bay["tri"]:
		c += "varying vec3 b9_tp;\nvarying vec3 b9_tw;\n"
	c += "void vertex() {\n\tb9_ly = VERTEX.y;\n"
	if bay["vc"] and bay["srgb"]:
		# Godot'nun kendi dönüşümü, vertex()'te (örnek rengi bundan SONRA çarpılır: fragment'te yapılırsa kaftan rengi de
		# gama'dan geçip koyulaşıyor ve doyuyordu)
		# BaseMaterial3D ile birebir: Compatibility çizicisinde OUTPUT_IS_SRGB doğru, dönüşüm YOK (yapılırsa figürler koyulaşıyordu)
		c += "\tif (!OUTPUT_IS_SRGB) {\n\t\tCOLOR.rgb = mix(pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), COLOR.rgb * (1.0 / 12.92), lessThan(COLOR.rgb, vec3(0.04045)));\n\t}\n"
	if bay["tri"]:
		if bay["dunya"]:
			c += "\tvec3 n = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);\n\tvec3 p = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;\n"
		else:
			c += "\tvec3 n = NORMAL;\n\tvec3 p = VERTEX;\n"
		c += "\tb9_tw = pow(abs(n), vec3(tri_sharp));\n\tb9_tw /= dot(b9_tw, vec3(1.0));\n"
		c += "\tb9_tp = (p * uv1_scale + uv1_offset) * vec3(1.0, -1.0, 1.0);\n"
	elif bay["tex"]:
		c += "\tUV = UV * uv1_scale.xy + uv1_offset.xy;\n"
	c += "}\n\nvoid fragment() {\n\tvec4 a = albedo;\n"
	if bay["vc"]:
		c += "\ta.rgb *= COLOR.rgb;\n\ta.a *= COLOR.a;\n"
	if bay["tex"]:
		if bay["tri"]:
			c += "\tvec4 t = texture(tex, b9_tp.xy) * b9_tw.z + texture(tex, b9_tp.xz) * b9_tw.y + texture(tex, b9_tp.zy * vec2(-1.0, 1.0)) * b9_tw.x;\n"
			c += "\tvec4 tm = textureLod(tex, vec2(0.5), 12.0);\n"
		else:
			c += "\tvec4 t = texture(tex, UV);\n\tvec4 tm = textureLod(tex, UV, 12.0);\n"
		c += "\tt.rgb = mix(tm.rgb, t.rgb, tex_karsit);\n\ta *= t;\n"
	c += "\tALBEDO = b9_uygula(a.rgb, VERTEX, NORMAL, INV_VIEW_MATRIX, b9_ly);\n"
	c += "\tROUGHNESS = 0.9;\n\tSPECULAR = 0.2;\n\tRIM = 0.2;\n\tRIM_TINT = 0.6;\n"
	if bay["makas"]:
		c += "\tALPHA = a.a;\n\tALPHA_SCISSOR_THRESHOLD = makas_esik;\n"
	elif bay.get("saydam", false):
		c += "\tALPHA = a.a;\n"
	if bay["isik"]:
		c += "\tEMISSION = isik_renk.rgb;\n"
	if not bay.get("golgesiz", false):
		c += "\tEMISSION += b9_gece_isik(ALBEDO, VERTEX, INV_VIEW_MATRIX, b9_ly);\n"
	c += "}\n"
	var sh := Shader.new()
	sh.code = c
	_shaders[key] = sh
	return sh


## Var olan gölgelendiricinin kopyası: ORTAK eklenir, vertex() başında model y saklanır, fragment() sonunda
## ALBEDO = b9_uygula(...). fragment içinde erken dönüş (return) varsa ya da ALBEDO yazılmıyorsa null.
static func enjekte(src: Shader, toon := false) -> Shader:
	var key := "%d|%s" % [src.get_rid().get_id(), toon]
	if _enj.has(key):
		return _enj[key]
	var code := src.code
	var out: Shader = null
	var fi := code.find("void fragment()")
	if fi >= 0 and code.contains("ALBEDO"):
		var a := code.find("{", fi)
		var e := _kapanis(code, a)
		var govde := code.substr(a, e - a) if e > a else ""
		var donus := RegEx.create_from_string("\\breturn\\b").search(govde) != null
		if e > a and not donus and govde.contains("ALBEDO"):
			var gece_s := "" if code.contains("unshaded") else "\tEMISSION += b9_gece_isik(ALBEDO, VERTEX, INV_VIEW_MATRIX, b9_ly);\n"
			code = code.substr(0, e) + "\tALBEDO = b9_uygula(ALBEDO, VERTEX, NORMAL, INV_VIEW_MATRIX, b9_ly);\n" + gece_s + code.substr(e)
			var vi := code.find("void vertex()")
			if vi >= 0:
				var va := code.find("{", vi)
				code = code.substr(0, va + 1) + "\n\tb9_ly = VERTEX.y;" + code.substr(va + 1)
			else:
				var fi2 := code.find("void fragment()")
				code = code.substr(0, fi2) + "void vertex() {\n\tb9_ly = VERTEX.y;\n}\n\n" + code.substr(fi2)
			if toon:
				code = code.replace("diffuse_lambert", "diffuse_toon")
			# ORTAK: render_mode satırından (yoksa shader_type satırından) sonra
			var ri := code.find("render_mode")
			if ri < 0:
				ri = code.find("shader_type")
			var sat := code.find(";", ri)
			code = code.substr(0, sat + 1) + "\n" + ORTAK + code.substr(sat + 1)
			out = Shader.new()
			out.code = code
	_enj[key] = out
	if out == null:
		_say("enjekte_yok", 1)
	return out


static func _kapanis(code: String, a: int) -> int:
	var d := 0
	for i in range(a, code.length()):
		var ch := code[i]
		if ch == "{":
			d += 1
		elif ch == "}":
			d -= 1
			if d == 0:
				return i
	return -1


# ------------------------------------------------------------------ ayrıntı dokuları

## Küçük, döşenebilir, yordamsal ayrıntı dokusu (128 px, ortalama 0,5; mip'li: uzakta ortalamaya iner).
##   tas    taş yüzeyi: yumru/çentik ve ince benek (öğe ~0,3–0,6 m @ 2,4 m döşeme)
##   siva   kireç sıva: yumuşak leke, seyrek çatlak (öğe ~0,5–1,2 m @ 3,2 m)
##   dokuma keten/keçe: dikiş hatları (0,6 m'de bir), yatay atkı bandı, ince dokuma (yalnız yakında)
##   toprak toprak/çakıl: çiğnenmiş leke, çakıl beneği (öğe ~0,3–1 m @ 3,6 m)
##   ahsap  tahta: lif çizgileri ve tahta aralıkları (0,2 m)
##   ot     ot lekesi (öğe ~0,4–1 m @ 2,8 m)
static func detay_doku(tur: String) -> Texture2D:
	if _detay.has(tur):
		return _detay[tur]
	var N := 128
	var img := Image.create(N, N, false, Image.FORMAT_L8)
	for y in N:
		for x in N:
			var u := float(x) / N
			var v := float(y) / N
			var d := 0.5
			match tur:
				"tas":
					d = 0.5 + 0.30 * (_pn(u, v, 6, 11) - 0.5) + 0.22 * (_pn(u, v, 24, 12) - 0.5) + 0.12 * (_pn(u, v, 64, 13) - 0.5)
				"siva":
					d = 0.5 + 0.38 * (_pn(u, v, 4, 21) - 0.5) + 0.14 * (_pn(u, v, 16, 22) - 0.5)
					var cr := absf(_pn(u, v, 8, 23) - 0.5)
					d -= 0.1 * (1.0 - smoothstep(0.004, 0.02, cr))
				"dokuma":
					d = 0.5 + 0.16 * (_pn(u, v, 4, 31) - 0.5)
					var fx := fposmod(u * 2.0, 1.0)          # 1,2 m döşemede 0,6 m'de bir dikiş
					if fx < 0.02 or fx > 0.985:
						d -= 0.22
					elif fx < 0.045:
						d += 0.06
					var fy := fposmod(v * 3.0, 1.0)
					d += 0.05 * sin(fy * TAU)
					d += 0.06 * (float((x + y) % 2) - 0.5)   # ince dokuma (mip ile yakında söner)
				"toprak":
					# iri leke hafif (kamuflaj olmasın), ince taneli toprak/çakıl belirgin (yakında okunur, mip ile söner)
					d = 0.5 + 0.18 * (_pn(u, v, 5, 41) - 0.5) + 0.16 * (_pn(u, v, 16, 42) - 0.5) + 0.22 * (_pn(u, v, 64, 44) - 0.5)
					var b := _pn(u, v, 32, 43)
					d += 0.18 * smoothstep(0.66, 0.86, b) - 0.12 * (1.0 - smoothstep(0.14, 0.3, b))
				"ahsap":
					var fx := fposmod(u * 8.0, 1.0)            # 1,6 m döşemede 0,2 m tahta
					d = 0.5 + 0.18 * (_pn(u, v * 0.25, 8, 51) - 0.5) + 0.05 * sin((u * 48.0 + _pn(u, v, 8, 52) * 3.0) * TAU)
					d += 0.1 * (_pn(floorf(u * 8.0) / 8.0, 0.0, 8, 53) - 0.5)
					if fx < 0.05:
						d -= 0.25
				"ot":
					d = 0.5 + 0.3 * (_pn(u, v, 6, 61) - 0.5) + 0.2 * (_pn(u, v, 20, 62) - 0.5)
			img.set_pixel(x, y, Color(clampf(d, 0.0, 1.0), 0, 0))
	# ortalama tam 0,5 olsun (ayrıntı ortalama rengi değiştirmez)
	var top := 0.0
	for y in N:
		for x in N:
			top += img.get_pixel(x, y).r
	var kay := 0.5 - top / float(N * N)
	for y in N:
		for x in N:
			img.set_pixel(x, y, Color(clampf(img.get_pixel(x, y).r + kay, 0.0, 1.0), 0, 0))
	img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	_detay[tur] = t
	return t


## Döşenebilir değer gürültüsü (dönem p hücre)
static func _pn(u: float, v: float, p: int, s: int) -> float:
	var x := u * p
	var y := v * p
	var ix := floori(x)
	var iy := floori(y)
	var fx := x - ix
	var fy := y - iy
	fx = fx * fx * (3.0 - 2.0 * fx)
	fy = fy * fy * (3.0 - 2.0 * fy)
	var a := _h(posmod(ix, p), posmod(iy, p), s)
	var b := _h(posmod(ix + 1, p), posmod(iy, p), s)
	var c := _h(posmod(ix, p), posmod(iy + 1, p), s)
	var d := _h(posmod(ix + 1, p), posmod(iy + 1, p), s)
	return lerpf(lerpf(a, b, fx), lerpf(c, d, fx), fy)


static func _h(x: int, y: int, s: int) -> float:
	return fposmod(sin(float(x) * 127.1 + float(y) * 311.7 + float(s) * 74.7) * 43758.5453, 1.0)


# ------------------------------------------------------------------ ortak malzeme üreticisi (yeni kod için)

## Kategorinin ortak malzemesi: renk palet adı ya da Color; köşe rengi çarpılır (vc). Önbellekli.
static func malzeme(kat: String, r: Variant = Color.WHITE, vc := false) -> ShaderMaterial:
	var c: Color = renk(r) if r is String else r
	var key := "uret|%s|%s|%s" % [kat, c.to_html(), vc]
	if _cache.has(key):
		return _cache[key]
	var sm := ShaderMaterial.new()
	sm.shader = std_shader({"vc": vc, "srgb": false, "tex": false, "tri": false, "dunya": false, "cull": 0, "makas": false,
		"isik": false, "toon": true})
	sm.set_shader_parameter("albedo", c)
	_kural_ver(sm, kat, true, false)
	sm.next_pass = Props._outline_mat() if Props.outlines else null
	_uyumlu[sm.get_instance_id()] = kat
	sm.set_meta("birlik_kat", kat)
	_cache[key] = sm
	return sm


# ------------------------------------------------------------------ çadır dili: IstHayat katmanı

## IstHayat (yaşam katmanı) çadır ve sancak kayıtları: sur kuşağı (12 m) ve hendekteki kayıtlar kaldırılır; çadır
## gövdeleri keten/devetüyü/boza çekilir (padişah otağı kök boya); kutu gövdeli çadır ağı alaçıkla değişir.
## OTURTMA kuşağı kurulmadan çalışmaz (false döner, sonraki karede yine dener).
func _hayat_duzen() -> bool:
	if OTURTMA.kusak.is_empty():
		return false
	var h := kok.get_node_or_null("IstHayat")
	if h == null:
		for c in kok.find_children("IstHayat", "", true, false):
			h = c
			break
	if h == null or not ("K" in h) or h.get("K") == null:
		return false
	var K: Dictionary = h.get("K")
	var kaldir := 0
	var boya := 0
	var topuz := 0
	for ad: String in ["cadir", "bez", "kutu"]:
		if not K.has(ad):
			continue
		var kt = K[ad]
		var stride: int = kt.stride
		var renkli: bool = kt.renkli
		var cells: Dictionary = kt.cells
		for key in cells.keys():
			var a: PackedFloat32Array = cells[key]
			var b := PackedFloat32Array()
			var m := a.size() / stride
			for i in m:
				var o := i * stride
				var x := a[o + 3]
				var z := a[o + 11]
				# TUR-6: hendekte ve sur dibinden 15 m'lik kuşakta çadır/tezgâh/sancak yok; çadır ve sancak ateş alanında da yok
				# (hendek dış kıyısından 60 m: top menzili, ordugâh oradan başlar)
				if OTURTMA.kusakta(x, z, 15.0, OTURTMA.ATES if ad != "kutu" else 15.0):
					kaldir += 1
					continue
				var rec := a.slice(o, o + stride)
				if ad == "kutu" and renkli and _topuz_kutu(rec):
					# sancak direğinin tepesindeki pirinç topuz: 0,24 m küp (KUTU YASAĞI: yuvarlak nesne kutudan olmaz)
					topuz += 1
					continue
				if ad == "cadir" and renkli:
					var c := Color(rec[12], rec[13], rec[14], rec[15])
					var c2 := _cadir_renk(c, rec[1] * rec[1] + rec[5] * rec[5] + rec[9] * rec[9], x, z)
					rec[12] = c2.r
					rec[13] = c2.g
					rec[14] = c2.b
					boya += 1
				b.append_array(rec)
			kt.n -= m - b.size() / stride
			if b.is_empty():
				cells.erase(key)
			else:
				cells[key] = b
		if ad == "cadir":
			for v: Dictionary in kt.views:
				v["mesh"] = alacik()
				if v.has("mm"):
					(v["mm"] as MultiMesh).mesh = v["mesh"]
	# TUR-6 (KUTU YASAĞI, "küp eşya = 0"): kutu katmanının (sandık, yük, tezgâh, baca, direk, ip) düz birim küpü yuvarlak
	# köşeli, şişkin, pahlı yük ağıyla değişir (çuval/balya/kasa okunur; ince direk ve ip sekizgen olur)
	if K.has("kutu"):
		for j in (K["kutu"].views as Array).size():
			var vk: Dictionary = K["kutu"].views[j]
			vk["mesh"] = yuk_yuvarlak(j > 0)
			if vk.has("mm"):
				(vk["mm"] as MultiMesh).mesh = vk["mesh"]
	# KUTU YASAĞI: insan katmanının kutu gövdeli ağları (hayat_mesh.gd insan / insan_uzak) yuvarlak gövdeyle değişir
	# (aynı bölge ve renk kodu düzeni: ist_insan gölgelendiricisi bacağı y < 0,8, kolu |x| > 0,215 bandında sallar)
	if K.has("insan"):
		var vs: Array = K["insan"].views
		for j in vs.size():
			var v: Dictionary = vs[j]
			v["mesh"] = insan_yuvarlak(j > 0)
			if v.has("mm"):
				(v["mm"] as MultiMesh).mesh = v["mesh"]
		_say("hayat_insan_agi", vs.size())
	if h.has_method("yenile_hepsi"):
		h.call("yenile_hepsi")
	_say("hayat_kaldirilan", kaldir)
	_say("hayat_cadir_boyanan", boya)
	_say("hayat_topuz_kutu", topuz)
	print("BIRLIK hayat kaldirilan=%d cadir_boyanan=%d topuz_kutu=%d" % [kaldir, boya, topuz])
	return true


static func _topuz_kutu(rec: PackedFloat32Array) -> bool:
	var sx := Vector3(rec[0], rec[4], rec[8]).length()
	var sy := Vector3(rec[1], rec[5], rec[9]).length()
	return absf(sx - 0.24) < 0.02 and absf(sy - 0.24) < 0.02 and rec[12] > 0.8 and rec[14] < 0.35


## Çadır gövde rengi: keten / devetüyü / boz (karışım tohumu konumdan); iri (ölçek² > 4: padişah otağı) kök boya.
func _cadir_renk(c: Color, olcek2: float, x: float, z: float) -> Color:
	if olcek2 > 4.0 and c.r > c.g * 1.8:
		return renk("kokboya")
	var t := fposmod(sin(x * 12.9898 + z * 78.233) * 43758.5453, 1.0)
	var r: Color = renk("keten") if t < 0.55 else (renk("devetuyu") if t < 0.85 else renk("boz"))
	# beyaz çadırlar kirli beyaz, renkliler devetüyü yanına: aynı aile
	if c.s > 0.3:
		r = r.lerp(renk("devetuyu"), 0.5)
	return r


## Alaçık / yuvarlak çadır: sekizgen hafif eğik duvar + konik çatı + etek saçağı + alem direği (yerde y = 0; çap ~4 m,
## duvar 1,5, tepe 3,3 m — IstHayat cadir ağıyla aynı ölçü). Köşe rengi: duvar/çatı beyaz (örnek rengiyle çarpılır),
## etek saçağı ve tepe şeridi kök boya, alem pirinç. Dikiş: dilim dilim hafif ton farkı.
## TUR-6: birim yük (merkezli, 1 m³ sınır kutusu): kesit köşeleri yuvarlatılmış kare (12 kenar), ortası hafif şişkin,
## alt ve üst pahlı; üst yüz biraz açık, alt kenar koyu (kir). uzak: 8 kenar, pahsız.
static func yuk_yuvarlak(uzak := false) -> ArrayMesh:
	var key := "yuk_%s" % uzak
	if _cache.has(key):
		return _cache[key]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := 6 if uzak else 8           # (kayıt sayısı binlerce: üçgen bütçesi)
	var kes: Array = []           # her kenar köşesi (birim kare içinde yuvarlak köşe)
	for i in n:
		var a := TAU * (float(i) + 0.5) / n
		var c := Vector2(cos(a), sin(a))
		# süper elips (|x|^4 + |y|^4 = 1): köşeli ama yuvarlak
		var k := pow(pow(absf(c.x), 4.0) + pow(absf(c.y), 4.0), -0.25)
		kes.append(c * k * 0.5)
	var hs := [[-0.5, 0.88], [-0.36, 1.02], [0.36, 1.02], [0.5, 0.88]] if not uzak else [[-0.5, 1.0], [0.5, 1.0]]
	var ton := [0.72, 0.92, 1.0, 1.06] if not uzak else [0.85, 1.02]
	for r in hs.size() - 1:
		for i in n:
			var a0: Vector2 = kes[i]
			var a1: Vector2 = kes[(i + 1) % n]
			var y0: float = hs[r][0]
			var y1: float = hs[r + 1][0]
			var s0: float = hs[r][1]
			var s1: float = hs[r + 1][1]
			var c0 := Color(ton[r], ton[r], ton[r])
			var c1 := Color(ton[r + 1], ton[r + 1], ton[r + 1])
			var p00 := Vector3(a0.x * s0, y0, a0.y * s0)
			var p10 := Vector3(a1.x * s0, y0, a1.y * s0)
			var p01 := Vector3(a0.x * s1, y1, a0.y * s1)
			var p11 := Vector3(a1.x * s1, y1, a1.y * s1)
			for e: Array in [[p00, c0], [p10, c0], [p11, c1], [p00, c0], [p11, c1], [p01, c1]]:
				st.set_color(e[1])
				st.add_vertex(e[0])
	# kapaklar
	for yy: Array in [[hs[0][0], hs[0][1], ton[0], -1.0], [hs[hs.size() - 1][0], hs[hs.size() - 1][1], ton[ton.size() - 1], 1.0]]:
		var cc := Color(float(yy[2]), float(yy[2]), float(yy[2]))
		for i in n:
			var a0: Vector2 = kes[i] * float(yy[1])
			var a1: Vector2 = kes[(i + 1) % n] * float(yy[1])
			var m := Vector3(0, float(yy[0]), 0)
			var q0 := Vector3(a0.x, float(yy[0]), a0.y)
			var q1 := Vector3(a1.x, float(yy[0]), a1.y)
			var tri := [m, q1, q0] if float(yy[3]) > 0.0 else [m, q0, q1]
			for v: Vector3 in tri:
				st.set_color(cc)
				st.add_vertex(v)
	st.generate_normals()
	var mm := st.commit()
	_cache[key] = mm
	return mm


static func alacik() -> ArrayMesh:
	if _cache.has("alacik"):
		return _cache["alacik"]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := 10
	var r0 := 2.05
	var r1 := 1.9
	var hw := 1.5
	var tepe := 3.3
	var serit := Color(0.62, 0.36, 0.3)
	for i in n:
		var a0 := TAU * i / n
		var a1 := TAU * (i + 1) / n
		var d0 := Vector3(cos(a0), 0, sin(a0))
		var d1 := Vector3(cos(a1), 0, sin(a1))
		var ton := 0.94 if i % 2 == 0 else 1.0
		var w := Color(ton, ton, ton)
		# duvar (alt etek şeridi ayrı)
		var e := 0.22
		_dq(st, d0 * r0, d1 * r0, d1 * r0 + Vector3(0, e, 0), d0 * r0 + Vector3(0, e, 0), w * Color(0.86, 0.84, 0.8))
		_dq(st, d0 * r0 + Vector3(0, e, 0), d1 * r0 + Vector3(0, e, 0), d1 * r1 + Vector3(0, hw, 0), d0 * r1 + Vector3(0, hw, 0), w)
		# saçak (kök boya şerit), çatı
		var s0 := d0 * (r1 + 0.28) + Vector3(0, hw - 0.12, 0)
		var s1 := d1 * (r1 + 0.28) + Vector3(0, hw - 0.12, 0)
		_dq(st, d0 * r1 + Vector3(0, hw, 0), d1 * r1 + Vector3(0, hw, 0), s1, s0, serit)
		_dq(st, s0, s1, d1 * (r1 + 0.18) + Vector3(0, hw + 0.08, 0), d0 * (r1 + 0.18) + Vector3(0, hw + 0.08, 0), serit)
		var c0 := d0 * (r1 + 0.18) + Vector3(0, hw + 0.08, 0)
		var c1 := d1 * (r1 + 0.18) + Vector3(0, hw + 0.08, 0)
		var m0 := d0 * 0.55 + Vector3(0, tepe - 0.45, 0)
		var m1 := d1 * 0.55 + Vector3(0, tepe - 0.45, 0)
		_dq(st, c0, c1, m1, m0, w * Color(1.0, 0.99, 0.97))
		_tri(st, m0, m1, Vector3(0, tepe, 0), serit.lerp(Color.WHITE, 0.25))
	# alem direği
	var al := Color(0.72, 0.58, 0.32)
	for i in 4:
		var a0 := TAU * i / 4.0
		var a1 := TAU * (i + 1) / 4.0
		var p0 := Vector3(cos(a0), 0, sin(a0)) * 0.05
		var p1 := Vector3(cos(a1), 0, sin(a1)) * 0.05
		_dq(st, p0 + Vector3(0, tepe - 0.1, 0), p1 + Vector3(0, tepe - 0.1, 0), p1 + Vector3(0, tepe + 0.45, 0), p0 + Vector3(0, tepe + 0.45, 0), al)
	st.generate_normals()
	var m := st.commit()
	_cache["alacik"] = m
	return m


## İnsan (IstHayat insan katmanı): yuvarlak gövde, kutu yok. Renk alfa kodu hayat_mesh.gd ile aynı: 0 sabit (pantolon,
## ten, çizme), 1 tunik (örnek paleti), 0,5 başlık, 0,25 alet (alet işareti yoksa gölgelendirici sıfıra çökertir).
## Yakın ≈ 130, uzak ≈ 40 üçgen.
static func insan_yuvarlak(uzak: bool) -> ArrayMesh:
	var key := "insan_uzak" if uzak else "insan"
	if _cache.has(key):
		return _cache[key]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hose := Color(0.2, 0.17, 0.14, 0.0)
	var skin := Color(0.86, 0.66, 0.52, 0.0)
	var tun := Color(1, 1, 1, 1.0)
	var cap := Color(1, 1, 1, 0.5)
	if uzak:
		_silindir(st, Vector3(0, 0.0, 0), 0.0, 0.9, 0.12, 0.15, 5, hose, false)
		_silindir(st, Vector3(0, 0.0, 0), 0.82, 1.5, 0.2, 0.16, 5, tun, true)
		_kure(st, Vector3(0, 1.62, 0), Vector3(0.13, 0.15, 0.13), 5, 2, cap)
	else:
		for sx: float in [-1.0, 1.0]:
			_silindir(st, Vector3(sx * 0.1, 0, 0), 0.06, 0.8, 0.06, 0.075, 5, hose, false)
			_kure(st, Vector3(sx * 0.1, 0.05, -0.04), Vector3(0.075, 0.05, 0.13), 5, 2, Color(0.16, 0.11, 0.08, 0.0))
		_silindir(st, Vector3.ZERO, 0.74, 0.96, 0.21, 0.19, 6, tun.darkened(0.12), false)
		_silindir(st, Vector3.ZERO, 0.94, 1.42, 0.19, 0.17, 6, tun, true)
		for sx: float in [-1.0, 1.0]:
			_silindir(st, Vector3(sx * 0.28, 0, 0), 0.86, 1.4, 0.045, 0.055, 5, tun.darkened(0.06), false)
			_kure(st, Vector3(sx * 0.28, 0.8, 0), Vector3(0.05, 0.06, 0.05), 4, 2, skin)
		_kure(st, Vector3(0, 1.53, 0), Vector3(0.11, 0.13, 0.115), 6, 3, skin)
		_silindir(st, Vector3(0, 0, 0), 1.6, 1.72, 0.125, 0.11, 6, cap, true)
		_silindir(st, Vector3(0.34, 0, -0.06), 0.0, 2.1, 0.02, 0.02, 4, Color(0.45, 0.32, 0.2, 0.25), false)
		_silindir(st, Vector3(0.34, 0, -0.06), 2.1, 2.3, 0.035, 0.0, 4, Color(0.7, 0.72, 0.75, 0.25), false)
	st.generate_normals()
	var m := st.commit()
	_cache[key] = m
	return m


## Dikey kesik koni (merkez c'nin x/z'si; y0..y1; yarıçap r0 → r1; n kenar; kapak: üst kapak)
static func _silindir(st: SurfaceTool, c: Vector3, y0: float, y1: float, r0: float, r1: float, n: int, col: Color, kapak: bool) -> void:
	for i in n:
		var a0 := TAU * i / n
		var a1 := TAU * (i + 1) / n
		var d0 := Vector3(cos(a0), 0, sin(a0))
		var d1 := Vector3(cos(a1), 0, sin(a1))
		var p0 := Vector3(c.x, y0, c.z) + d0 * r0
		var p1 := Vector3(c.x, y0, c.z) + d1 * r0
		var q0 := Vector3(c.x, y1, c.z) + d0 * r1
		var q1 := Vector3(c.x, y1, c.z) + d1 * r1
		_tri(st, p0, q0, p1, col)
		if r1 > 0.0:
			_tri(st, p1, q0, q1, col)
		if kapak and r1 > 0.0:
			_tri(st, Vector3(c.x, y1, c.z), q1, q0, col)


## Alçak çokgen elipsoit (merkez, yarıçaplar, boylam n, enlem m)
static func _kure(st: SurfaceTool, c: Vector3, r: Vector3, n: int, m: int, col: Color) -> void:
	var halka: Array = []
	for j in m + 1:
		var t := PI * float(j) / m - PI * 0.5
		var h: Array = []
		for i in n:
			var a := TAU * i / n
			h.append(c + Vector3(cos(a) * cos(t) * r.x, sin(t) * r.y, sin(a) * cos(t) * r.z))
		halka.append(h)
	for j in m:
		for i in n:
			var a: Vector3 = halka[j][i]
			var b: Vector3 = halka[j][(i + 1) % n]
			var d: Vector3 = halka[j + 1][i]
			var e: Vector3 = halka[j + 1][(i + 1) % n]
			if j > 0:
				_tri(st, a, d, b, col)
			if j < m - 1:
				_tri(st, b, d, e, col)


static func _dq(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, col: Color) -> void:
	_tri(st, a, c, b, col)
	_tri(st, a, d, c, col)


## (Godot ön yüzü saat yönünde: dışarıdan bakınca a → c → b sırası)
static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	st.set_color(col)
	st.add_vertex(a)
	st.set_color(col)
	st.add_vertex(c)
	st.set_color(col)
	st.add_vertex(b)


# ------------------------------------------------------------------ denetim

## Bütün malzemeleri gezer: [malzeme, kategorisiz, doygunluk_asan, duz_buyuk_yuzey, saf_beyaz] ve ayrıntı.
## doygunluk_asan / saf_beyaz: kurala çekilmemiş (kaynak hâliyle çizilen) malzemenin taban rengi (albedo × köşe rengi ×
## örnek rengi örneklemi) kategori tavanını / saf beyazı aşıyorsa; kurala çekilmişte tavan uniformu kuraldan gevşekse.
## duz_buyuk_yuzey: dokusuz ve ayrıntısız (b9_guc 0) malzemeyle çizilen, 4 m²'den büyük yüzeyli ağ.
static func denetle(kok_: Node) -> Dictionary:
	var mats := {}
	var r := {"malzeme": 0, "kategorisiz": 0, "doygunluk_asan": 0, "duz_buyuk_yuzey": 0, "saf_beyaz": 0, "ornek": []}
	for c in kok_.find_children("*", "GeometryInstance3D", true, false):
		var gi := c as GeometryInstance3D
		if not gi.is_visible_in_tree():
			continue
		for e: Array in _yuvalar(gi):
			var m: Material = e[0]
			var mesh: Mesh = e[1]
			var si: int = e[2]
			if m == null:
				continue
			var id := m.get_instance_id()
			var ilk := not mats.has(id)
			mats[id] = true
			var kat := String(m.get_meta("birlik_kat", "")) if m.has_meta("birlik_kat") else kategori(gi, m)
			var uy := m.has_meta("birlik_kat")
			if kat in MUAF:
				continue
			if kat == "":
				if ilk:
					r["kategorisiz"] += 1
					_ornek(r, "kategorisiz", gi, m)
				continue
			var kr: Dictionary = KURAL[kat]
			if uy and m is ShaderMaterial:
				var sm := m as ShaderMaterial
				var sat = sm.get_shader_parameter("b9_sat")
				var v1 = sm.get_shader_parameter("b9_vmax")
				if ilk and (sat == null or float(sat) > float(kr["sat"]) + 1e-4):
					r["doygunluk_asan"] += 1
					_ornek(r, "doygunluk_asan", gi, m)
				if ilk and (v1 == null or float(v1) > 0.9):
					r["saf_beyaz"] += 1
					_ornek(r, "saf_beyaz", gi, m)
				var g = sm.get_shader_parameter("b9_guc")
				var tx = sm.get_shader_parameter("tex")
				if ilk and (g == null or float(g) <= 0.0) and tx == null and _alan(mesh) > 4.0:
					r["duz_buyuk_yuzey"] += 1
					_ornek(r, "duz_buyuk_yuzey", gi, m)
				continue
			# kurala çekilmemiş: kaynak renkleri örnekle
			if not ilk:
				continue
			var renkler := _taban_renkler(gi, m, mesh, si)
			var asan := false
			var beyaz := false
			for col: Color in renkler:
				if col.s > float(kr["sat"]) + 0.02:
					asan = true
				if col.v > 0.95 and col.s < 0.06:
					beyaz = true
			if asan:
				r["doygunluk_asan"] += 1
				_ornek(r, "doygunluk_asan", gi, m)
			if beyaz:
				r["saf_beyaz"] += 1
				_ornek(r, "saf_beyaz", gi, m)
			var dokulu := m is BaseMaterial3D and (m as BaseMaterial3D).albedo_texture != null
			if not dokulu and not (m is ShaderMaterial) and _alan(mesh) > 4.0:
				r["duz_buyuk_yuzey"] += 1
				_ornek(r, "duz_buyuk_yuzey", gi, m)
	r["malzeme"] = mats.size()
	return r


static func _ornek(r: Dictionary, t: String, gi: Node, m: Material) -> void:
	if (r["ornek"] as Array).size() < 40:
		(r["ornek"] as Array).append("%s %s [%s] %s" % [t, String(gi.get_path()).right(70), _betik(gi), m.get_class()])


## [malzeme, ağ, yüzey] listesi (etkin malzeme)
static func _yuvalar(gi: GeometryInstance3D) -> Array:
	var o: Array = []
	var mesh: Mesh = null
	if gi is MeshInstance3D:
		mesh = (gi as MeshInstance3D).mesh
	elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh != null:
		mesh = (gi as MultiMeshInstance3D).multimesh.mesh
	if mesh == null:
		return o
	if gi.material_override != null:
		o.append([gi.material_override, mesh, -1])
		return o
	for si in mesh.get_surface_count():
		var m: Material = (gi as MeshInstance3D).get_active_material(si) if gi is MeshInstance3D else mesh.surface_get_material(si)
		o.append([m, mesh, si])
	return o


static func _alan(mesh: Mesh) -> float:
	var ab := mesh.get_aabb()
	var s := ab.size
	return maxf(s.x * s.y, maxf(s.x * s.z, s.y * s.z))


## Taban renk örneklemi (albedo × köşe rengi × örnek rengi): en çok 64 renk
static func _taban_renkler(gi: GeometryInstance3D, m: Material, mesh: Mesh, si: int) -> Array:
	var out: Array = []
	var alb := Color.WHITE
	var vc := false
	if m is BaseMaterial3D:
		alb = (m as BaseMaterial3D).albedo_color
		vc = (m as BaseMaterial3D).vertex_color_use_as_albedo
	elif m is ShaderMaterial:
		return out          # kendi gölgelendiricisi: renk kodun içinde (enjekte edilemediyse sayaçta "cevrilemedi")
	var cols: Array = [Color.WHITE]
	if vc and mesh is ArrayMesh:
		cols = []
		var sl := [si] if si >= 0 else range(mesh.get_surface_count())
		for s: int in sl:
			var arr := mesh.surface_get_arrays(s)
			var cs = arr[Mesh.ARRAY_COLOR]
			if cs is PackedColorArray:
				var pc := cs as PackedColorArray
				var adim := maxi(1, pc.size() / 48)
				for i in range(0, pc.size(), adim):
					cols.append(pc[i])
		if cols.is_empty():
			cols = [Color.WHITE]
	var inst: Array = [Color.WHITE]
	if gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh.use_colors:
		var mm := (gi as MultiMeshInstance3D).multimesh
		inst = []
		var n := mm.visible_instance_count if mm.visible_instance_count >= 0 else mm.instance_count
		for i in range(0, n, maxi(1, n / 16)):
			inst.append(mm.get_instance_color(i))
		if inst.is_empty():
			inst = [Color.WHITE]
	for a: Color in cols:
		for b: Color in inst:
			if out.size() < 64:
				out.append(Color(alb.r * a.r * b.r, alb.g * a.g * b.g, alb.b * a.b * b.b))
	return out
