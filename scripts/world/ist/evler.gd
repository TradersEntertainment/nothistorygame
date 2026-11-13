class_name IstEvler
extends RefCounted
## İstanbul 1453 ev kiti (docs/ISTANBUL_PLAN.md §4; görünüş: docs/ISTANBUL_GORUNUS.md §2–3). Yapı dili Tolga'nın mektup
## bölümünün evleri (ByzCity._house): taş zemin kat, sokağa taşan üst kat (çıkma) ve altında payandalar, tuğla dişli
## korniş, kiremit beşik çatı, kemerli kepenkli pencereler, kemerli ahşap kapı + basamak, duvar kandili, devşirme mermer.
##
## İkinci tur (DOKU-2): 1453 paleti (soluk, sıcak gri-bej-kahve; pembe sıva ve parlak turuncu çatı YOK), duvar
## biçimleri (taş-tuğla şeritli / kireç badana / açık sıva tonları / ahşap çıkmalı / sıvasız moloz taş), çatı tonları
## (kiremit kızıl-kahve, soluk, yosunlu), düz dam ve teras, sundurma, baca; tipler: sıra ev, dükkânlı ev, kule ev,
## yoksul kulübe, avlulu konak, han, fırın, demirci, ambar, Latin evi (3 kat), harap/terk edilmiş ev.
## Renk kuralı: uzak (lod 2, düz renk) ile orta/yakın (dokulu) katmanların GÖRÜNEN rengi aynı: dokulu yüzeyin malzeme
## rengi = palet rengi / dokunun ortalama rengi (_dk).
##
## Arayüz (docs/_ajan/gorev/_istanbul_ortak.md): build_<tip>(host, k, lod, tohum). Yerel koordinat: taban ortası, zemin
## y 0, sokak cephesi +z (çıkma +z'ye taşar), cephe boyu x ekseninde, derinlik z ekseninde. İnsan ölçüsü (kapı, basamak,
## sandık, sundurma) k'den bağımsız; k yalnız kütleyi (cephe boyu, derinlik) ölçekler.
##
## Tırmanma (player.gd: JUMP 3,6 m/sn, STEP_H 0,42 m, g 9,8 → zıplama 0,66 m; Traversal: REACH 2,3, VAULT_MAX 1,1):
##   basamak 0,40 (yürüyerek) · sandık/sıra 1,0 (tırmanma kipinde atlanır) · sundurma/tente 2,2 (tutunup çıkılır) ·
##   saçak 2,2 (kulübe: sundurma gibi tutunulur) / 3,4 / 5,8 / 8,4 (sundurmadan duvara tutunulur; kule ev, teras ve konak dış taş merdivenle).
##   Ara yükseklik yok (0,66–0,95 ve 1,1–2,1 m'de üst yüzey kullanılmaz: yarım tutunma olmasın); teras korkuluğu 1,0 m.
## Şehirde toplu kullanım: mesh(v, tip, lod) ile pişmiş ağ, shapes(v, tip) ile çarpışma (IstSehir).

# ---------------------------------------------------------------- palet (ISTANBUL_GORUNUS §2; görünen renkler)
const P_TAS := [Color("868070"), Color("7b7566"), Color("8d8673"), Color("756f60")]          # kireçtaşı / kesme taş
const P_SIVA := [Color("978b73"), Color("938870"), Color("9b907a"), Color("8b7f68"), Color("90826b"), Color("867860")]
const P_BADANA := [Color("a19987"), Color("9b9380"), Color("a49d8b")]                       # kirli kireç beyazı
const P_KERPIC := [Color("7a6850"), Color("71604a"), Color("645947")]                       # sıvasız / kerpiç
const P_TUGLA := Color("8a4630")
const P_AHSAP := [Color("584a39"), Color("64523e"), Color("715b41")]
## DOKU-3 (kalite notu 18): ışık altında doygun turuncuya kaçıyordu: soluk kırmızı-kahve Bizans kiremidi, daha az doygun
const P_KIREMIT := [Color("5c3428"), Color("53302a"), Color("5a3b2f"), Color("4b2d25"), Color("624538"), Color("573b31")]
const P_DAM := [Color("7a6a52"), Color("85735a"), Color("6e604c")]
const SHUTTERS := [Color("5a5244"), Color("4e5a4a"), Color("6b4a36"), Color("5a6250")]     # soluk, boyasız ahşap
## Eski adlar (başka dosyalar kullanabilir)
const PLASTERS := P_SIVA
const STONE := Color("b9b29e")
const WOOD := Color("6b5a46")
const BRICK := Color("a8553a")
const DARK := Color("1e1a18")
const GF := 3.0             # zemin kat
const UF := 2.7             # üst kat
const OVER := 0.7           # çıkma (cumba) çıkıntısı
const RISE := 1.7           # çatı sırtı (eğim ≤ 25°: yürünür)
const STEP := 0.40
const CRATE := 1.0
const SHED := 2.2
const KULUBE_H := 2.2

## CityPlan'ın eski ev ölçüleri (CityHouses.VARIANTS) v < ESKI için aynen (eski dünya); v2 yeni tabloyu kullanır.
## YENI: [cephe m, derinlik m, kat] (kat 0: kulübe). Her ölçü üç kez (üç farklı duvar/çatı biçimi) sıralanır.
const YENI := [
	[4.0, 8.0, 1], [5.0, 8.0, 1], [5.0, 9.0, 1], [6.0, 9.0, 1], [7.0, 10.0, 1], [8.0, 10.0, 1],
	[4.0, 8.0, 2], [5.0, 9.0, 2], [6.0, 9.0, 2], [6.0, 10.0, 2], [7.0, 10.0, 2], [8.0, 11.0, 2], [5.0, 10.0, 2],
	[5.0, 6.0, 1], [6.0, 7.0, 1], [7.0, 7.0, 1], [5.0, 7.0, 2], [6.0, 7.0, 2],
	[5.0, 10.0, 3], [6.0, 11.0, 3], [7.0, 12.0, 3],
	[4.0, 5.0, 0], [5.0, 6.0, 0], [6.0, 6.0, 0],
	[10.0, 12.0, 2], [12.0, 12.0, 2],                     # han, konak
]
const BICIM := 3

static func eski_sayi() -> int:
	return CityHouses.VARIANTS.size()


## v2 örnekleri: kat (0 kulübe, 1, 2, 3) ve en az/en çok cepheye göre süzülmüş liste (sokak dizicisi kullanır)
static func ornekler(kat: int, min_w := 0.0, max_w := 99.0, max_d := 99.0) -> Array:
	var out: Array = []
	for i in YENI.size():
		var r: Array = YENI[i]
		if int(r[2]) == kat and float(r[0]) >= min_w and float(r[0]) <= max_w and float(r[1]) <= max_d:
			for b in BICIM:
				out.append(eski_sayi() + i * BICIM + b)
	return out


## Döner: Vector3(cephe, saçak yüksekliği, derinlik)
static func dims(v: int) -> Vector3:
	var n0 := eski_sayi()
	if v < n0:
		var d: Array = CityHouses.VARIANTS[v % n0]
		var floors := int(d[2])
		var eave := 3.4 if floors <= 1 else GF + (floors - 1) * UF + 0.1
		return Vector3(int(d[0]) * 2.0, eave, int(d[1]) * 2.0)
	var r: Array = YENI[((v - n0) / BICIM) % YENI.size()]
	var kat := int(r[2])
	var h := KULUBE_H if kat == 0 else (3.4 if kat == 1 else GF + (kat - 1) * UF + 0.1)
	return Vector3(float(r[0]), h, float(r[1]))


static func variant_count() -> int:
	return eski_sayi()


static func yeni_mi(v: int) -> bool:
	return v >= eski_sayi()


# ---------------------------------------------------------------- kayıt (arayüz)

## Evler anıt değildir: şehir kurucusu sokak kenarlarına dizer. Kayıt yalnız örnek amaçlı (önizleme).
static func catalog() -> Array:
	return []


# ---------------------------------------------------------------- tipler

static func build_sira_ev(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	var v := eski_sayi() + tohum % (YENI.size() * BICIM)
	var d := dims(v)
	ev(host, d.x * maxf(k, 0.6), d.z * maxf(k, 0.6), d.y, tohum, lod, "sira")


static func build_dukkanli_ev(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	var d := dims(eski_sayi() + (6 + tohum % 7) * BICIM)
	ev(host, d.x * maxf(k, 0.6), d.z * maxf(k, 0.6), d.y, tohum, lod, "dukkan")


## Kule ev: dar, üç katlı, düz damlı ve mazgallı (sur dibi); dış taş merdivenle dama çıkılır
static func build_kule_ev(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 6.0, 6.0, 9.8, tohum, lod, "kule")


static func build_kulube(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 5.0, 5.0, KULUBE_H, tohum, lod, "kulube")


static func build_konak(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 12.0, 10.0, GF + UF + 0.1, tohum, lod, "konak")


static func build_han(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 12.0, 10.0, GF + UF + 0.1, tohum, lod, "han")


static func build_firin(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 7.0, 8.0, 3.4, tohum, lod, "firin")


static func build_demirci(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 7.0, 8.0, 3.4, tohum, lod, "demirci")


static func build_ambar(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 9.0, 9.0, GF + UF + 0.1, tohum, lod, "ambar")


static func build_latin(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 7.0, 10.0, GF + 2.0 * UF + 0.1, tohum, lod, "latin")


static func build_harap(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 7.0, 8.0, GF + UF + 0.1, tohum, lod, "harap")


static func build_teras(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 7.0, 8.0, 3.4, tohum, lod, "teras")


## Harabe: yıkık zemin kat duvarları (≤ 0,4 m'lik kırık basamaklarla üstüne çıkılır), ot, moloz
static func build_harabe(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum * 131 + 7
	var L := rng.randf_range(6.0, 10.0) * maxf(k, 0.6)
	var D := rng.randf_range(5.0, 8.0) * maxf(k, 0.6)
	var hs := [1.0, 2.4, 2.8, 0.6]
	var tas: Color = P_KERPIC[tohum % P_KERPIC.size()].lerp(P_TAS[tohum % 4], 0.5)
	for i in 4:
		var h: float = hs[(i + tohum) % 4]
		var horiz := i % 2 == 0
		var sz := Vector3(L, h, 0.6) if horiz else Vector3(0.6, h, D - 1.2)
		var p := Vector3(0, h * 0.5, (D * 0.5 - 0.3) * (1 if i == 0 else -1)) if horiz else Vector3((L * 0.5 - 0.3) * (1 if i == 1 else -1), h * 0.5, 0)
		if i == 0:
			var w := (L - 1.6) * 0.5
			for sd in [-1, 1]:
				_block(host, Vector3(w, h, 0.6), Vector3(sd * (0.8 + w * 0.5), h * 0.5, D * 0.5 - 0.3), tas, "rubble", lod)
			continue
		_block(host, sz, p, tas, "rubble", lod)
	if lod >= 2:
		return
	var top: float = hs[(2 + tohum) % 4]
	var n := int(ceil(top / STEP))
	for s in n:
		var hh := minf((s + 1) * STEP, top)
		_block(host, Vector3(0.9, hh, 0.7), Vector3(-L * 0.5 + 0.9 + s * 0.7, hh * 0.5, -D * 0.5 + 0.95), tas.darkened(0.08), "rubble", lod)
	if lod == 0:
		for i in 6:
			var q := Vector3(rng.randf_range(-L * 0.35, L * 0.35), 0.15, rng.randf_range(-D * 0.3, D * 0.3))
			Props.box(host, Vector3(rng.randf_range(0.4, 0.9), 0.3, rng.randf_range(0.3, 0.7)), q, tas.darkened(0.15), Vector3(0, rng.randf() * 90.0, 0))
			Props.ball(host, rng.randf_range(0.3, 0.6), q + Vector3(0.8, 0.0, 0.5), Color("6e7f4e"), Vector3(1, 0.5, 1), 6)
		Props.box(host, Vector3(L - 1.2, 0.04, D - 1.2), Vector3(0, 0.02, 0), Color("7a8a4a"))


## Sundurma: 2,2 m düz damlı ahşap sundurma (sokaktan çatıya yolun ikinci basamağı). Yerel: duvara +z'den yaslanır.
static func build_sundurma(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	_sundurma(host, 0.0, 2.6, 1.6, 0.0, lod)


## Sandık yığını: 1,0 m (tırmanma kipinde atlanır), yanında 0,40 m'lik basamak taşı (yürüyerek)
static func build_sandik(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	if lod >= 2:
		return
	Props.solid(host, Vector3(1.0, CRATE, 1.0), Vector3(0, CRATE * 0.5, 0), Color("8a6f4f"))
	Props.solid(host, Vector3(0.9, STEP, 0.9), Vector3(0, STEP * 0.5, 1.0), Color("aaa38f"))
	if lod == 0:
		for y in [0.25, 0.75]:
			Props.box(host, Vector3(1.02, 0.06, 1.02), Vector3(0, y, 0), Color("5a4a36"))


## Dış taş merdiven: 0,30 m'lik basamaklarla yükseklik h'ye (yerel: +x yönünde çıkar, duvar −z'de)
static func build_merdiven(host: Node3D, h: float, lod: int = 0) -> void:
	var n := int(ceil(h / 0.30))
	var rise := h / n
	for i in n:
		var hh := (i + 1) * rise
		_block(host, Vector3(0.34, hh, 1.1), Vector3(i * 0.32, hh * 0.5, 0), P_TAS[1], "ashlar", lod)
	if lod == 0:
		Props.box(host, Vector3(n * 0.32, 0.06, 0.06), Vector3(n * 0.16 - 0.16, h * 0.5 + 1.0, 0.52), WOOD, Vector3(0, 0, rad_to_deg(atan2(h, n * 0.32))))


# ---------------------------------------------------------------- plan (görünüş ve çarpışma aynı plandan)

## Evin bütün kararları (biçim, renk, çatı, ekler) tohum ve tipten: ev() ve shapes() aynı planı kullanır.
static func plan(L: float, D: float, H: float, tohum: int, tip: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum * 7919 + hash(tip)
	var p := {"L": L, "D": D, "H": H, "tip": tip, "tohum": tohum}
	var gf := minf(GF, H)
	p["gf"] = gf
	# Duvar biçimi: 0 taş-tuğla şeritli, 1 kireç badana, 2 açık sıva, 3 ahşap çıkmalı, 4 sıvasız moloz/kerpiç
	var bicim := tohum % 5
	match tip:
		"kulube": bicim = 4
		"konak", "han", "latin", "ambar": bicim = 0 if tohum % 3 != 2 else 1
		"harap": bicim = [4, 2, 0][tohum % 3]
		"demirci", "firin": bicim = [0, 4, 2][tohum % 3]
		"kule": bicim = 0
	p["bicim"] = bicim
	var tas: Color = P_TAS[tohum % P_TAS.size()]
	var ust: Color = P_SIVA[(tohum / 5) % P_SIVA.size()]
	match bicim:
		0:
			ust = tas if tohum % 2 == 0 else P_SIVA[(tohum / 3) % P_SIVA.size()]
		1:
			ust = P_BADANA[(tohum / 5) % P_BADANA.size()]
		3:
			ust = P_SIVA[(tohum / 7) % P_SIVA.size()].darkened(0.04)
		4:
			tas = P_KERPIC[(tohum / 5) % P_KERPIC.size()]
			ust = tas.lightened(0.04)
	if tip == "harap":
		tas = tas.darkened(0.1)
		ust = ust.darkened(0.14)
	p["tas"] = tas
	p["ust"] = ust
	p["alt_desen"] = "rubble" if bicim == 4 else "ashlar"
	p["ust_desen"] = "rubble" if bicim == 4 else ("ashlar" if bicim == 0 and ust == tas else "plaster")
	# Çıkma: ahşap çıkmalı biçimde tam, sıra/dükkânda çoğunlukla; taş yapılarda yok
	var over := OVER
	if tip in ["kule", "kulube", "ambar", "latin", "han", "firin", "demirci", "teras"] or H <= gf + 0.1:
		over = 0.0
	elif bicim == 0 and tohum % 3 == 0:
		over = 0.0
	p["over"] = over
	# Çatı: kiremit (tonlar), düz dam, teras; kulübede alçak tek eğimli
	var cati := "kiremit"
	if tip == "kule":
		cati = "mazgal"
	elif tip == "teras":
		cati = "teras"
	elif tip == "kulube":
		cati = "duz" if tohum % 3 == 0 else "kiremit"
	elif tip in ["firin", "demirci"]:
		cati = "duz" if tohum % 2 == 0 else "kiremit"
	elif tip in ["sira", "dukkan"] and H < 4.0 and tohum % 6 == 0:
		cati = "duz"
	p["cati"] = cati
	var kr: Color = P_KIREMIT[(tohum / 2) % P_KIREMIT.size()]
	if tip == "harap":
		kr = kr.darkened(0.15).lerp(Color("6e7f4e"), 0.2)
	p["kiremit"] = kr
	p["dam"] = P_DAM[tohum % P_DAM.size()]
	p["kepenk"] = SHUTTERS[(tohum * 3) % SHUTTERS.size()]
	p["ahsap"] = P_AHSAP[tohum % P_AHSAP.size()]
	# Sundurma (2,2 m, cephede): sokaktan çatıya ikinci yol; dükkânda tente var
	p["sundurma"] = (tip in ["sira", "harap", "latin"] and tohum % 4 == 1 and L >= 5.0) or tip in ["konak", "han"]
	p["baca"] = tip in ["firin", "demirci"] or (cati == "kiremit" and rng.randf() < 0.45)
	# Dış merdiven (teras ve kule dama; konakta üst kat sofaya)
	p["merdiven"] = tip in ["teras", "kule"]
	return p


# ---------------------------------------------------------------- ev gövdesi

## Ev: L cephe (x), D derinlik (z), H saçak; tip "sira" | "dukkan" | "kule" | "kulube" | "konak" | "han" | "firin" |
## "demirci" | "ambar" | "latin" | "harap" | "teras". lod 0 tam ayrıntı + çarpışma; lod 1 gövde, çıkma, çatı, koyu
## pencere/kapı boşlukları (çarpışma aynı); lod 2 gövde + çatı (çarpışmasız, uzak siluet; renkler aynı).
static func ev(host: Node3D, L: float, D: float, H: float, tohum: int, lod: int, tip := "sira") -> void:
	var p := plan(L, D, H, tohum, tip)
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum * 97 + 13
	var gf: float = p["gf"]
	var over: float = p["over"]
	var tas: Color = p["tas"]
	var ust: Color = p["ust"]
	var fz := D * 0.5
	var cati := String(p["cati"])
	# Gövde: zemin kat (taş) ve üst kat(lar)
	_block(host, Vector3(L, gf, D), Vector3(0, gf * 0.5, 0), tas, String(p["alt_desen"]), lod)
	if H > gf + 0.1:
		var up := _block(host, Vector3(L, H - gf, D + over), Vector3(0, gf + (H - gf) * 0.5, over * 0.5), ust, String(p["ust_desen"]), lod)
		up.set_meta("facade", true)
	_cati(host, p, lod)
	if lod >= 2:
		return
	# Tuğla şeritler (taş-tuğla şeritli biçim): cephede ve yanlarda ince kuşaklar
	if int(p["bicim"]) == 0 and lod == 0:
		var ys := [1.1, 2.2] if H <= gf + 0.1 else [1.1, 2.2, gf + 1.0]
		for y: float in ys:
			if y > H - 0.3:
				continue
			var zz := fz + (over if y > gf else 0.0)
			Props.box(host, Vector3(L + 0.04, 0.22, 0.05), Vector3(0, y, zz + 0.01), _dk(P_TUGLA, ""))
	# Ahşap çıkma: üst katta dikme ve kuşak (ahşap iskelet)
	if int(p["bicim"]) == 3 and H > gf + 0.1 and lod == 0:
		var nd := maxi(2, int(L / 1.6))
		for i in nd + 1:
			Props.box(host, Vector3(0.14, H - gf - 0.1, 0.06), Vector3(-L * 0.5 + 0.07 + i * (L - 0.14) / nd, gf + (H - gf) * 0.5, fz + over + 0.02), p["ahsap"])
		Props.box(host, Vector3(L, 0.14, 0.06), Vector3(0, gf + (H - gf) * 0.5, fz + over + 0.02), p["ahsap"])
	# Korniş ve kat kirişi
	if cati == "kiremit" or cati == "harap":
		Props.box(host, Vector3(L + 0.1, 0.16, 0.14), Vector3(0, H - 0.1, fz + over), _dk(P_TUGLA, ""))
	if H > gf + 0.1:
		Props.box(host, Vector3(L + 0.1, 0.2, 0.18), Vector3(0, gf + 0.05, fz + over), p["ahsap"])
	# Pencereler
	var harap := tip == "harap"
	var floors := maxi(1, int(round((H - gf) / UF)))
	var wn := 1 if L < 5.0 else (2 if L < 7.0 else 3)
	if tip in ["han", "konak"]:
		wn = int(L / 2.6)
	if H > gf + 0.1:
		for fl in floors:
			var wy := pencere_y(gf, H, fl)
			if wy < 0.0:
				continue
			for i in wn:
				var x := -L * 0.5 + (i + 0.5) * L / wn
				_window(host, Vector3(x, wy, fz + over + 0.03), p, rng, lod, tip == "konak" and fl == 0)
	elif tip != "demirci":
		_window(host, Vector3(L * 0.25, 1.9 if H > 3.0 else 1.2, fz + 0.03), p, rng, lod, false)
	# Kapı
	var dx := rng.randf_range(-L * 0.2, L * 0.2)
	if tip == "dukkan":
		dx = -L * 0.5 + 1.1
	var kapi_w := 1.1
	var kapi_h := 1.9
	match tip:
		"kulube": kapi_w = 0.9; kapi_h = 1.65
		"han", "ambar": kapi_w = 2.4; kapi_h = 2.6; dx = 0.0
		"konak": kapi_w = 1.6; kapi_h = 2.4
	if tip != "demirci":
		Props.box(host, Vector3(kapi_w, kapi_h, 0.06), Vector3(dx, kapi_h * 0.5, fz + 0.02), Color("3e3022") if not harap else Color("1e1a18"))
		if lod == 0:
			Props.cyl(host, kapi_w * 0.5, 0.06, Vector3(dx, kapi_h, fz + 0.02), Color("3e3022"), Vector3(90, 0, 0), 10)
			Props.box(host, Vector3(kapi_w + 0.3, 0.14, 0.5), Vector3(dx, 0.07, fz + 0.25), _dk(P_TAS[2], ""))
			if harap:
				for i in 3:
					Props.box(host, Vector3(kapi_w + 0.2, 0.16, 0.05), Vector3(dx, 0.5 + i * 0.55, fz + 0.07), p["ahsap"], Vector3(0, 0, -8.0 + i * 9.0))
	match tip:
		"dukkan": _shop(host, L, fz, rng, lod)
		"han": _han(host, p, lod)
		"firin": _firin(host, p, lod)
		"demirci": _demirci(host, p, lod)
		"latin", "ambar": _depo_kapilari(host, p, lod)
	if bool(p["sundurma"]):
		_sundurma(host, dx + (1.6 if dx < 0 else -1.6), 2.6, 1.3, fz, lod)
	if bool(p["merdiven"]):
		_dis_merdiven(host, p, lod)
	if lod != 0:
		return
	# Çıkmanın altında payandalar
	if over > 0.0:
		for i in 4:
			var x := -L * 0.5 + 0.5 + i * (L - 1.0) / 3.0
			Props.box(host, Vector3(0.12, 0.12, 0.9), Vector3(x, gf - 0.25, fz + 0.35), p["ahsap"], Vector3(-40, 0, 0))
	# Duvar kandili (her ikinci ev) ve devşirme mermer
	if tohum % 2 == 0 and not harap and tip != "kulube":
		var lx := dx + kapi_w * 0.5 + 0.35
		Props.box(host, Vector3(0.035, 0.035, 0.48), Vector3(lx, 2.72, fz + 0.24), Color("26221e"))
		Props.ball(host, 0.1, Vector3(lx, 2.36, fz + 0.46), Color("8a6a3a"), Vector3(1, 0.42, 1), 8)
	if rng.randf() < 0.3 and tip in ["sira", "konak", "han", "dukkan"]:
		for sd in [-1.0, 1.0]:
			Props.cyl(host, 0.09, 1.95, Vector3(dx + sd * (kapi_w * 0.5 + 0.17), 0.97, fz + 0.1), Color("d8d6ce"), Vector3.ZERO, 8)
	# Harap: dökülmüş sıva, ot, moloz
	if harap:
		for i in 4:
			Props.ball(host, rng.randf_range(0.3, 0.55), Vector3(rng.randf_range(-L * 0.45, L * 0.45), 0.15, fz + 0.4), Color("6e7f4e"), Vector3(1, 0.6, 1), 6)
		Props.box(host, Vector3(1.2, 0.8, 0.04), Vector3(-L * 0.25, gf + 0.9, fz + over + 0.04), _dk(P_TUGLA, "").darkened(0.1))


## Çatı: kiremit beşik (mahya x ekseninde), düz dam, teras, kule mazgalı, harap (çökük ve yamalı)
static func _cati(host: Node3D, p: Dictionary, lod: int) -> void:
	var L: float = p["L"]
	var D: float = p["D"]
	var H: float = p["H"]
	var over: float = p["over"]
	var cati := String(p["cati"])
	var tas: Color = p["tas"]
	match cati:
		"mazgal":
			_block(host, Vector3(L, 0.2, D), Vector3(0, H + 0.1, 0), tas, "ashlar", lod)
			for sd in [-1, 1]:
				_block(host, Vector3(L, 1.0, 0.4), Vector3(0, H + 0.7, sd * (D * 0.5 - 0.2)), tas, "ashlar", lod)
				_block(host, Vector3(0.4, 1.0, D - 0.8), Vector3(sd * (L * 0.5 - 0.2), H + 0.7, 0), tas, "ashlar", lod)
			if lod == 0:
				for i in int(L / 1.2):
					for sd in [-1, 1]:
						Props.box(host, Vector3(0.5, 0.45, 0.42), Vector3(-L * 0.5 + 0.6 + i * 1.2, H + 1.42, sd * (D * 0.5 - 0.2)), _dk(tas, ""))
		"duz", "teras":
			var dam: Color = p["dam"]
			# dış merdivenli evde +x yanında saçak yok (merdivende baş çarpmasın)
			var mr := bool(p["merdiven"])
			var dw := L + (0.1 if mr else 0.2)
			var dx := -0.05 if mr else 0.0
			_block(host, Vector3(dw, 0.18, D + over + 0.2), Vector3(dx, H + 0.09, over * 0.5), dam, "", lod)
			if cati == "teras":
				# korkuluk 1,0 m (sokak cephesinde ve yanlarda; merdiven yanında arkada ağız)
				_block(host, Vector3(L - 0.4, 1.0, 0.3), Vector3(-0.2, H + 0.68, D * 0.5 + over - 0.15), p["ust"], "plaster", lod)
				for sd in [-1, 1]:
					_block(host, Vector3(0.3, 1.0, D * 0.6), Vector3(sd * (L * 0.5 - 0.25), H + 0.68, D * 0.2 + over * 0.5), p["ust"], "plaster", lod)
				if lod == 0:
					# asma çardağı
					for sx in [-1, 1]:
						Props.box(host, Vector3(0.1, 2.2, 0.1), Vector3(sx * L * 0.3, H + 1.28, -D * 0.1), p["ahsap"])
					Props.box(host, Vector3(L * 0.66, 0.08, 2.4), Vector3(0, H + 2.4, -D * 0.1), p["ahsap"])
					# TUR-7 (KUTU YASAĞI): asma yaprağı düz yeşil KUTU levha değil ("havada kare yeşillik"): kirişlere
					# oturan yassı, kabarık yaprak öbeği (tek ağ: çizim sayısı aynı), solgun zeytin
					Props.ball(host, 0.5, Vector3(0, H + 2.56, -D * 0.1), Color("434f33"), Vector3(L * 0.64, 0.42, 2.5), 8)
			elif lod == 0:
				# düz damda saman/odun ya da küp
				Props.box(host, Vector3(1.2, 0.5, 0.9), Vector3(-L * 0.2, H + 0.43, -D * 0.15), Color("8a7a50"))
		_:
			_roof(host, L + 0.8, D + over + 1.0, Vector3(0, H, over * 0.5), p["kiremit"], lod, String(p["tip"]) == "harap", int(p["tohum"]))
			if bool(p["baca"]):
				var bx := (float(int(p["tohum"]) % 5) / 4.0 - 0.5) * L * 0.6
				_block(host, Vector3(0.6, RISE + 1.2, 0.6), Vector3(bx, H + (RISE + 1.2) * 0.5, -D * 0.22), tas.lerp(P_TUGLA, 0.45).darkened(0.1), "", maxi(lod, 1) if lod < 2 else 2)


## Kiremit beşik çatı (mahya x ekseninde) ve saçak tahtası. Harap: bir yanı çökük (kirişler görünür), yosun lekeleri.
static func _roof(host: Node3D, w: float, d: float, base: Vector3, col: Color, lod: int, harap := false, tohum := 0) -> void:
	if lod >= 2:
		Props.prism(host, Vector3(d, RISE, w), base + Vector3(0, RISE * 0.5, 0), col, Vector3(0, 90, 0))
		return
	var pm := PrismMesh.new()
	pm.size = Vector3(d, RISE, w)
	var roof := MeshInstance3D.new()
	roof.mesh = pm
	roof.position = base + Vector3(0, RISE * 0.5, 0)
	roof.rotation_degrees = Vector3(0, 90, 0)
	roof.material_override = Props.mat(_dk(col, "tiles"), 0.0, false, "tiles")
	host.add_child(roof)
	Props.box(host, Vector3(w + 0.1, 0.12, d + 0.1), base + Vector3(0, 0.02, 0), Color("4a3a2a"))
	if lod == 0:
		Props.cyl(host, 0.14, w, base + Vector3(0, RISE + 0.02, 0), col.darkened(0.08), Vector3(0, 0, 90), 6)
		# yosun/soluk kiremit lekeleri (yüzeyin 3 cm üstünde; çatı tonuna yakın, göze batmaz)
		var ang := atan2(RISE, d * 0.5)
		for i in tohum % 3:
			var t := 0.25 + 0.5 * float((tohum * 7 + i * 13) % 10) / 10.0
			var x := (float((tohum * 11 + i * 17) % 10) / 10.0 - 0.5) * w * 0.6
			var sd := 1.0 if (tohum + i) % 2 == 0 else -1.0
			var lc := col.lerp(Color("5e6a44"), 0.35) if i % 2 == 0 else col.lightened(0.08)
			Props.box(host, Vector3(1.6, 0.03, 1.1), base + Vector3(x, RISE * (1.0 - t) + 0.05, sd * d * 0.5 * t), lc, Vector3(sd * -rad_to_deg(ang), 0, 0))
		if harap:
			# çökük köşe: koyu boşluk + kirişler (kapalı çarpışma altta aynı)
			var hx := -w * 0.22
			Props.box(host, Vector3(w * 0.35, 0.04, d * 0.3), base + Vector3(hx, RISE * 0.55 + 0.04, d * 0.17), Color("1e1a18"), Vector3(-rad_to_deg(ang), 0, 0))
			for i in 4:
				Props.box(host, Vector3(0.12, 0.12, d * 0.34), base + Vector3(hx - w * 0.15 + i * w * 0.1, RISE * 0.55 + 0.1, d * 0.17), Color("4a3a2a"), Vector3(-rad_to_deg(ang), 0, 0))


## Üst kat penceresinin orta yüksekliği (fl: kat sırası). TUR-6 (v2): üst bant bir kattan alçaksa pencere bandın ortasına
## iner; sığmıyorsa −1 (konmaz). Önceden max(1, …) kat sayısıyla pencere/kepenk/saksı saçağın üstünde havada kalıyordu
## (dip_03, hava_05). Yayındaki bölümde (v2 değil) eski davranış. Denetim: tests/_ist/havada_denetim.tscn.
static func pencere_y(gf: float, H: float, fl: int, v2 := IstSehir.v2) -> float:
	var wy := gf + UF * (fl + 0.5)
	if v2 and wy + 0.75 > H - 0.15:
		wy = gf + (H - gf) * 0.5 if fl == 0 else -1.0
		if wy < 0.0 or wy + 0.75 > H - 0.1 or wy - 0.75 < gf - 0.3:
			return -1.0
	return wy


## Kemerli, kepenkli pencere (cephe +z). bifora: iki kemerli, orta sütunlu (konak)
static func _window(host: Node3D, p: Vector3, plan_: Dictionary, rng: RandomNumberGenerator, lod: int, bifora: bool) -> void:
	var harap := String(plan_["tip"]) == "harap"
	var w := 0.6 if String(plan_["tip"]) != "kulube" else 0.4
	if bifora:
		for sd in [-1, 1]:
			Props.box(host, Vector3(0.5, 1.0, 0.05), p + Vector3(sd * 0.32, 0, 0), DARK)
		if lod == 0:
			Props.cyl(host, 0.09, 1.1, p + Vector3(0, -0.02, 0.06), Color("d8d6ce"), Vector3.ZERO, 6)
			for sd in [-1, 1]:
				Props.cyl(host, 0.25, 0.05, p + Vector3(sd * 0.32, 0.5, 0), DARK, Vector3(90, 0, 0), 8)
		return
	Props.box(host, Vector3(w, 0.95, 0.05), p, DARK)
	if lod != 0:
		return
	Props.cyl(host, w * 0.5, 0.05, p + Vector3(0, 0.47, 0), DARK, Vector3(90, 0, 0), 8)
	Props.box(host, Vector3(w + 0.2, 0.08, 0.16), p + Vector3(0, -0.52, 0.05), _dk(P_TAS[2], ""))
	var sh: Color = plan_["kepenk"]
	if harap:
		Props.box(host, Vector3(w + 0.1, 0.14, 0.05), p + Vector3(0, 0.1, 0.05), plan_["ahsap"], Vector3(0, 0, 12))
		return
	var open := rng.randf() < 0.55
	for sd in [-1, 1]:
		if open:
			Props.box(host, Vector3(0.04, 0.95, w * 0.5 + 0.05), p + Vector3(sd * (w * 0.5 + 0.22), 0, 0.18), sh, Vector3(0, sd * 20, 0))
		else:
			Props.box(host, Vector3(w * 0.5 - 0.02, 0.95, 0.04), p + Vector3(sd * w * 0.25, 0, 0.03), sh)
	if rng.randf() < 0.3:
		Props.cyl(host, 0.1, 0.16, p + Vector3(-0.15, -0.4, 0.1), Color("9a5a40"), Vector3.ZERO, 7, 0.12)
		Props.ball(host, 0.14, p + Vector3(-0.15, -0.25, 0.1), Color("5a7a3a"), Vector3(1, 0.8, 1), 6)


## Dükkân ağzı: kemerli açıklık (koyu), tezgâh (1,0 m), bez tente (2,2 m, düz katı üst: tırmanma basamağı)
static func _shop(host: Node3D, L: float, fz: float, rng: RandomNumberGenerator, lod: int) -> void:
	var w := minf(L - 2.6, 3.4)
	if w < 1.6:
		return
	var cx := L * 0.5 - 0.6 - w * 0.5
	Props.box(host, Vector3(w, 2.2, 0.05), Vector3(cx, 1.1, fz + 0.03), Color("2a2220"))
	var awn: Color = [Color("a8553a"), Color("8a7a5a"), Color("b09a6a"), Color("6e6a4e")][rng.randi() % 4]
	var t := Props.solid(host, Vector3(w + 0.4, 0.12, 1.4), Vector3(cx, SHED - 0.06, fz + 0.7), awn)
	t.set_meta("climb_top", true)
	Props.solid(host, Vector3(w, CRATE, 0.7), Vector3(cx, CRATE * 0.5, fz + 0.35), Color("7a644c"))
	if lod != 0:
		return
	for i in 4:
		Props.box(host, Vector3((w + 0.4) / 8.0, 0.13, 1.42), Vector3(cx - (w + 0.4) * 0.5 + (i * 2 + 0.5) * (w + 0.4) / 8.0, SHED - 0.05, fz + 0.7), Color("d8cfba"))
	for sx in [-1, 1]:
		Props.box(host, Vector3(0.08, SHED - 0.12, 0.08), Vector3(cx + sx * (w * 0.5 + 0.1), (SHED - 0.12) * 0.5, fz + 1.35), WOOD)
	for i in 3:
		var c: Color = [Color("b0432f"), Color("c9a547"), Color("62863f"), Color("b9683a")][(i + rng.randi()) % 4]
		Props.ball(host, 0.2, Vector3(cx - w * 0.3 + i * w * 0.3, CRATE + 0.12, fz + 0.4), c, Vector3(1, 0.6, 1), 6)


## Han: zemin katta kemerli revak ağızları (koyu), büyük kemerli kapı
static func _han(host: Node3D, p: Dictionary, lod: int) -> void:
	var L: float = p["L"]
	var fz: float = float(p["D"]) * 0.5
	var n := int(L / 3.0)
	for i in n:
		var x := -L * 0.5 + (i + 0.5) * L / n
		if absf(x) < 1.4:
			continue
		Props.box(host, Vector3(1.6, 1.8, 0.05), Vector3(x, 0.9, fz + 0.03), Color("2a2220"))
		if lod == 0:
			Props.cyl(host, 0.8, 0.05, Vector3(x, 1.8, fz + 0.03), Color("2a2220"), Vector3(90, 0, 0), 10)


## Fırın: yan tarafta kubbeli taş fırın (dam üstünde kubbe), baca, odun yığını
static func _firin(host: Node3D, p: Dictionary, lod: int) -> void:
	var L: float = p["L"]
	var H: float = p["H"]
	var D: float = p["D"]
	if lod >= 2:
		return
	Props.ball(host, 1.4, Vector3(L * 0.2, H + 0.2, -D * 0.15), _dk(P_KERPIC[0], ""), Vector3(1, 0.6, 1), 8)
	if lod == 0:
		Props.box(host, Vector3(1.6, 1.0, 0.7), Vector3(-L * 0.5 + 1.0, 0.5, float(p["D"]) * 0.5 + 0.4), Color("7a644c"))
		for i in 3:
			Props.cyl(host, 0.12, 1.5, Vector3(-L * 0.5 + 0.6 + i * 0.25, 1.1 + 0.12, float(p["D"]) * 0.5 + 0.4), Color("8a6f4f"), Vector3(0, 0, 90), 6)


## Demirci: cephesi açık atölye (koyu), içte ocak kızıllığı, örs, sundurma
static func _demirci(host: Node3D, p: Dictionary, lod: int) -> void:
	var L: float = p["L"]
	var fz: float = float(p["D"]) * 0.5
	Props.box(host, Vector3(L - 1.6, 2.4, 0.05), Vector3(0, 1.2, fz + 0.03), Color("1e1a18"))
	if lod == 0:
		Props.box(host, Vector3(0.9, 0.5, 0.05), Vector3(-L * 0.2, 0.7, fz + 0.04), Color("8a3a1e"))
		Props.box(host, Vector3(0.5, 0.35, 0.3), Vector3(L * 0.15, 0.55, fz + 0.5), Color("3a3a3e"))
		Props.cyl(host, 0.2, 0.4, Vector3(L * 0.15, 0.2, fz + 0.5), Color("5a4a36"), Vector3.ZERO, 6)


## Latin evi ve ambar: zeminde kemerli büyük depo kapıları
static func _depo_kapilari(host: Node3D, p: Dictionary, lod: int) -> void:
	var L: float = p["L"]
	var fz: float = float(p["D"]) * 0.5
	for sd in [-1, 1]:
		var x: float = sd * L * 0.3
		Props.box(host, Vector3(1.6, 2.3, 0.05), Vector3(x, 1.15, fz + 0.03), Color("4a3a2a"))
		if lod == 0:
			Props.cyl(host, 0.8, 0.05, Vector3(x, 2.3, fz + 0.03), Color("4a3a2a"), Vector3(90, 0, 0), 10)


## Cephede sundurma (2,2 m düz katı üst) ve yanında 1,0 m'lik sıra (sokaktan sundurmaya, sundurmadan saçağa)
static func _sundurma(host: Node3D, x: float, w: float, d: float, fz: float, lod: int) -> void:
	for sx in [-1, 1]:
		Props.box(host, Vector3(0.16, SHED, 0.16), Vector3(x + sx * (w * 0.5 - 0.1), SHED * 0.5, fz + d - 0.1), WOOD)
	var roof := _block(host, Vector3(w, 0.16, d), Vector3(x, SHED - 0.08, fz + d * 0.5), Color("7a644c"), "", lod)
	roof.set_meta("climb_top", true)
	_block(host, Vector3(1.0, CRATE, 0.7), Vector3(x + w * 0.5 + 0.55, CRATE * 0.5, fz + 0.35), Color("8a6f4f"), "", lod)
	if lod == 0:
		for i in 5:
			Props.box(host, Vector3(0.48, 0.05, d + 0.1), Vector3(x - w * 0.5 + 0.26 + i * 0.52, SHED + 0.02, fz + d * 0.5), _dk(P_KIREMIT[i % 3], ""))


## Dış taş merdiven (teras ve kule dama): evin bir yan duvarı boyunca, sokak cephesinden arkaya doğru çıkar. Dipte
## sokağa doğru iki ek basamak (üstleri −0,02 / −0,32 m): yamaçta sokak evin tabanından alçaksa ilk basamak ≤ 0,42 m kalır.
static func _dis_merdiven(host: Node3D, p: Dictionary, lod: int) -> void:
	var L: float = p["L"]
	var D: float = p["D"]
	for k in 2:
		var ust := -0.02 - k * 0.3
		_block(host, Vector3(1.0, ust + 1.6, 0.3), Vector3(L * 0.5 + 0.5, (ust - 1.6) * 0.5, D * 0.5 + 0.15 + k * 0.3), P_TAS[1], "ashlar", lod)
	var top: float = float(p["H"]) + (0.18 if String(p["cati"]) == "teras" else 0.2)
	var n := int(ceil(top / 0.30))
	var rise := top / n
	var run := D - 0.6
	var stepd := run / n
	for i in n:
		var hh := (i + 1) * rise
		_block(host, Vector3(1.0, hh, stepd + 0.02), Vector3(L * 0.5 + 0.5, hh * 0.5, D * 0.5 - 0.2 - (i + 0.5) * stepd), P_TAS[1], "ashlar", lod)
		# açık yanda 1,0 m'lik taş korkuluk (merdivenden düşülmesin)
		_block(host, Vector3(0.16, hh + 1.0, stepd + 0.02), Vector3(L * 0.5 + 0.92, (hh + 1.0) * 0.5, D * 0.5 - 0.2 - (i + 0.5) * stepd), P_TAS[0], "ashlar", lod)


## Katı blok: lod 0 ve 1'de çarpışmalı (Props.solid + desen), lod 2'de yalnız görüntü (görünen renk aynı)
static func _block(host: Node3D, size: Vector3, pos: Vector3, col: Color, pattern: String, lod: int) -> Node3D:
	if lod >= 2:
		return Props.box(host, size, pos, col)
	var b := Props.solid(host, size, pos, Color.WHITE if pattern != "" else col)
	if pattern != "":
		Props.set_pattern(b, _dk(col, pattern), pattern)
	return b


static var _ort := {}

## Dokulu yüzeyin malzeme rengi: görünen renk (palet) / dokunun ortalama rengi (uzak katmanla aynı görünsün)
static func _dk(col: Color, pattern: String) -> Color:
	if pattern == "":
		return col
	if not _ort.has(pattern):
		var a := World1453._avg(Props._pattern_tex(pattern))
		_ort[pattern] = Color(maxf(a.r, 0.2), maxf(a.g, 0.2), maxf(a.b, 0.2))
	var a: Color = _ort[pattern]
	return Color(minf(col.r / a.r, 1.0), minf(col.g / a.g, 1.0), minf(col.b / a.b, 1.0))


# ---------------------------------------------------------------- şehirde toplu kullanım (pişmiş ağ + çarpışma)

static var _mesh_cache := {}        # "v|tip|lod" → Mesh

static func _tohum(v: int, tip: String) -> int:
	return v * 7 + (3 if tip == "dukkan" else 0)


## Örneğin pişmiş ağı (MultiMesh / birleşik ağ için). lod 0 tam (dokulu), lod 1 sade (dokulu), lod 2 tek yüzey.
static func mesh(v: int, tip: String, lod: int) -> Mesh:
	var key := "%d|%s|%d" % [v, tip, lod]
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var t0 := Time.get_ticks_usec()
	var om := _ob_mesh_oku(v, tip, lod)
	if om != null:
		_mesh_cache[key] = om
		ob_say["okundu"] = int(ob_say.get("okundu", 0)) + 1
		ob_say["us"] = int(ob_say.get("us", 0)) + Time.get_ticks_usec() - t0
		return om
	var m := _mesh_kur(v, tip, lod)
	_mesh_cache[key] = m
	_ob_mesh_yaz(v, tip, lod, m)
	ob_say["kuruldu"] = int(ob_say.get("kuruldu", 0)) + 1
	ob_say["us"] = int(ob_say.get("us", 0)) + Time.get_ticks_usec() - t0
	return m


# ---------------------------------------------------------------- DOKU-4: pişmiş ev ağlarının disk önbelleği
## Ağ (yüzey dizileri + LOD'lar) user://ist_onbellek/ev/ altında .res; malzeme gömülmez: yüzey başına imza
## ("D": Dressing ortak malzemesi; "T|desen|ölçek": desen dokulu üçdüzlemli malzeme) metada; okurken desen
## Props'tan yeniden alınır (oturum içinde imza başına TEK malzeme: çizim çağrısı birleşir). Tanınmayan malzeme varsa
## o ağ yazılmaz. İmza: bu dosyanın, Props'un ve bake'in md5'i.
static var ob_say := {}
static var _ob_imza := ""
static var _ob_mat := {}
static var _ob_temiz := false


static func _ob_yol(v: int, tip: String, lod: int) -> String:
	if _ob_imza == "":
		_ob_imza = IstSokak.onbellek_imza(["res://scripts/world/ist/evler.gd", "res://scripts/level/props.gd",
			"res://scripts/world/world1453.gd", "res://scripts/level/dressing.gd", Props.outlines])
	return IstSokak.ONBELLEK_DIR + "ev/%s%s_%d_%s_%d.res" % [_ob_imza, "v2" if IstSehir.v2 else "", v, tip, lod]


static func _ob_mesh_oku(v: int, tip: String, lod: int) -> Mesh:
	if IstSokak._ob_kip() in ["yok", "yaz"]:
		return null
	var yol := _ob_yol(v, tip, lod)
	if not FileAccess.file_exists(yol):
		return null
	var m := ResourceLoader.load(yol, "ArrayMesh", ResourceLoader.CACHE_MODE_IGNORE) as ArrayMesh
	if m == null or not m.has_meta("ob_mat"):
		return null
	var sig: PackedStringArray = m.get_meta("ob_mat")
	if sig.size() != m.get_surface_count():
		return null
	for i in sig.size():
		var mt := _ob_mat_kur(sig[i])
		if mt == null:
			return null
		m.surface_set_material(i, mt)
	return m


static func _ob_mat_kur(s: String) -> Material:
	if _ob_mat.has(s):
		return _ob_mat[s]
	var mt: Material = null
	if s == "D":
		mt = Dressing._material()
	elif s.begins_with("T|"):
		var p := s.split("|")
		var sc: Variant = str_to_var(p[2])
		var gm := (Props.mat(Color.WHITE, 0.0, false, p[1])).duplicate() as StandardMaterial3D
		gm.albedo_color = Color.WHITE
		gm.vertex_color_use_as_albedo = true
		if sc is Vector3:
			gm.uv1_scale = sc
		mt = gm
	_ob_mat[s] = mt
	return mt


static func _ob_mesh_yaz(v: int, tip: String, lod: int, m: Mesh) -> void:
	if IstSokak._ob_kip() == "yok" or not (m is ArrayMesh):
		return
	var am := m as ArrayMesh
	var sig := PackedStringArray()
	for i in am.get_surface_count():
		var mt := am.surface_get_material(i)
		if mt == Dressing._material():
			sig.append("D")
			continue
		var bm := mt as StandardMaterial3D
		if bm == null or bm.albedo_texture == null or not bm.uv1_triplanar:
			return
		var desen := ""
		for k in Props._noise_cache:
			if Props._noise_cache[k] == bm.albedo_texture:
				desen = String(k)
				break
		if desen == "":
			return
		sig.append("T|%s|%s" % [desen, var_to_str(bm.uv1_scale)])
	var kopya := am.duplicate() as ArrayMesh
	for i in kopya.get_surface_count():
		kopya.surface_set_material(i, null)
	kopya.set_meta("ob_mat", sig)
	DirAccess.make_dir_recursive_absolute(IstSokak.ONBELLEK_DIR + "ev")
	if not _ob_temiz:
		# eski imzalı ev ağları (kod değişmiş) silinir; oturumda bir kez
		_ob_temiz = true
		var da := DirAccess.open(IstSokak.ONBELLEK_DIR + "ev")
		if da != null:
			for fn: String in da.get_files():
				if not fn.begins_with(_ob_imza + "_"):
					da.remove(fn)
	ResourceSaver.save(kopya, _ob_yol(v, tip, lod), ResourceSaver.FLAG_COMPRESS)
	# yazılanın da aynı paylaşılan malzemeleri kullanması (çizim çağrısı birleşsin) okunanla aynı görünüş verir
	for i in sig.size():
		var mt2 := _ob_mat_kur(sig[i])
		if mt2 != null:
			am.surface_set_material(i, mt2)


static func _mesh_kur(v: int, tip: String, lod: int) -> Mesh:
	var tmp := Node3D.new()
	var d := dims(v)
	ev(tmp, d.x, d.z, d.y, _tohum(v, tip), lod, tip)
	var list: Array = []
	for n in tmp.find_children("*", "MeshInstance3D", true, false):
		list.append(n)
	var holder := Node3D.new()
	var mi := World1453.bake(list, tmp, Transform3D.IDENTITY, holder, "Ev", 0.03, 0, lod >= 2)
	var m := mi.mesh
	holder.free()
	tmp.free()
	return m


## Örneğin çarpışma şekilleri (yerel): [[Shape3D, Transform3D], …] — ev() ile aynı plan
static func shapes(v: int, tip: String) -> Array:
	var d := dims(v)
	var p := plan(d.x, d.z, d.y, _tohum(v, tip), tip)
	var L := d.x
	var D := d.z
	var H := d.y
	var over: float = p["over"]
	var out: Array = []
	var gf: float = p["gf"]
	out.append([_bs(Vector3(L, gf, D)), Transform3D(Basis.IDENTITY, Vector3(0, gf * 0.5, 0))])
	if H > gf + 0.1:
		out.append([_bs(Vector3(L, H - gf, D + over)), Transform3D(Basis.IDENTITY, Vector3(0, gf + (H - gf) * 0.5, over * 0.5))])
	match String(p["cati"]):
		"mazgal":
			out.append([_bs(Vector3(L, 0.2, D)), Transform3D(Basis.IDENTITY, Vector3(0, H + 0.1, 0))])
			for sd in [-1, 1]:
				out.append([_bs(Vector3(L, 1.0, 0.4)), Transform3D(Basis.IDENTITY, Vector3(0, H + 0.7, sd * (D * 0.5 - 0.2)))])
				out.append([_bs(Vector3(0.4, 1.0, D - 0.8)), Transform3D(Basis.IDENTITY, Vector3(sd * (L * 0.5 - 0.2), H + 0.7, 0))])
		"duz", "teras":
			var mr := bool(p["merdiven"])
			out.append([_bs(Vector3(L + (0.1 if mr else 0.2), 0.18, D + over + 0.2)), Transform3D(Basis.IDENTITY, Vector3(-0.05 if mr else 0.0, H + 0.09, over * 0.5))])
			if String(p["cati"]) == "teras":
				out.append([_bs(Vector3(L - 0.4, 1.0, 0.3)), Transform3D(Basis.IDENTITY, Vector3(-0.2, H + 0.68, D * 0.5 + over - 0.15))])
				for sd in [-1, 1]:
					out.append([_bs(Vector3(0.3, 1.0, D * 0.6)), Transform3D(Basis.IDENTITY, Vector3(sd * (L * 0.5 - 0.25), H + 0.68, D * 0.2 + over * 0.5))])
		_:
			var conv := ConvexPolygonShape3D.new()
			var z0 := -D * 0.5
			var z1 := D * 0.5 + over
			var zm := (z0 + z1) * 0.5
			conv.points = PackedVector3Array([Vector3(-L * 0.5, H, z0), Vector3(-L * 0.5, H, z1), Vector3(-L * 0.5, H + RISE - 0.1, zm),
				Vector3(L * 0.5, H, z0), Vector3(L * 0.5, H, z1), Vector3(L * 0.5, H + RISE - 0.1, zm)])
			out.append([conv, Transform3D.IDENTITY])
	if tip == "dukkan" and minf(L - 2.6, 3.4) >= 1.6:
		var w := minf(L - 2.6, 3.4)
		var cx := L * 0.5 - 0.6 - w * 0.5
		out.append([_bs(Vector3(w + 0.4, 0.12, 1.4)), Transform3D(Basis.IDENTITY, Vector3(cx, SHED - 0.06, D * 0.5 + 0.7))])
		out.append([_bs(Vector3(w, CRATE, 0.7)), Transform3D(Basis.IDENTITY, Vector3(cx, CRATE * 0.5, D * 0.5 + 0.35))])
	if bool(p["sundurma"]):
		var sx := _sundurma_x(v, tip)
		out.append([_bs(Vector3(2.6, 0.16, 1.3)), Transform3D(Basis.IDENTITY, Vector3(sx, SHED - 0.08, D * 0.5 + 0.65))])
		out.append([_bs(Vector3(1.0, CRATE, 0.7)), Transform3D(Basis.IDENTITY, Vector3(sx + 1.85, CRATE * 0.5, D * 0.5 + 0.35))])
	if bool(p["merdiven"]):
		var top: float = H + (0.18 if String(p["cati"]) == "teras" else 0.2)
		var n := int(ceil(top / 0.30))
		var rise := top / n
		var run := D - 0.6
		var stepd := run / n
		for k in 2:
			var ust := -0.02 - k * 0.3
			out.append([_bs(Vector3(1.0, ust + 1.6, 0.3)), Transform3D(Basis.IDENTITY, Vector3(L * 0.5 + 0.5, (ust - 1.6) * 0.5, D * 0.5 + 0.15 + k * 0.3))])
		for i in n:
			var hh := (i + 1) * rise
			out.append([_bs(Vector3(1.0, hh, stepd + 0.02)), Transform3D(Basis.IDENTITY, Vector3(L * 0.5 + 0.5, hh * 0.5, D * 0.5 - 0.2 - (i + 0.5) * stepd))])
			out.append([_bs(Vector3(0.16, hh + 1.0, stepd + 0.02)), Transform3D(Basis.IDENTITY, Vector3(L * 0.5 + 0.92, (hh + 1.0) * 0.5, D * 0.5 - 0.2 - (i + 0.5) * stepd))])
	return out


static func _bs(s: Vector3) -> BoxShape3D:
	var b := BoxShape3D.new()
	b.size = s
	return b


## Sundurmanın x'i (ev() içindeki kapı yerinden; aynı rng sırası)
static func _sundurma_x(v: int, tip: String) -> float:
	var d := dims(v)
	var rng := RandomNumberGenerator.new()
	rng.seed = _tohum(v, tip) * 97 + 13
	var dx := rng.randf_range(-d.x * 0.2, d.x * 0.2)
	return dx + (1.6 if dx < 0 else -1.6)


## Ek yer kaplaması (yerel, cephenin önünde): sundurma ve dış merdiven taban dışına taşar (sokak dizicisi hesaba katar)
static func tasma(v: int, tip: String) -> Dictionary:
	var d := dims(v)
	var p := plan(d.x, d.z, d.y, _tohum(v, tip), tip)
	return {"on": 1.4 if (bool(p["sundurma"]) or tip == "dukkan") else 0.6, "yan": 1.0 if bool(p["merdiven"]) else 0.0}


## Sokaktan çatıya yollar (yerel): dükkânlı evde sandık (1,0) → tente (2,2) → üst kat duvarı (tırmanma kipi);
## sundurmalı evde sıra (1,0) → sundurma (2,2) → saçak; teras ve kule evde dış taş merdiven
static func climbs(v: int, tip: String) -> Array:
	var d := dims(v)
	var p := plan(d.x, d.z, d.y, _tohum(v, tip), tip)
	var out: Array = []
	if tip == "dukkan":
		var w := minf(d.x - 2.6, 3.4)
		var cx := d.x * 0.5 - 0.6 - w * 0.5
		out.append([Vector3(cx, 0, d.z * 0.5 + 1.2), Vector3(0, d.y + RISE * 0.5, OVER * 0.5), "sandik"])
	if bool(p["sundurma"]):
		var sx := _sundurma_x(v, tip)
		out.append([Vector3(sx + 1.85, 0, d.z * 0.5 + 1.0), Vector3(sx, d.y + RISE * 0.5, 0), "sandik"])
	if bool(p["merdiven"]):
		out.append([Vector3(d.x * 0.5 + 0.5, 0, d.z * 0.5 + 0.5), Vector3(d.x * 0.5 - 0.6, d.y + 0.2, -d.z * 0.5 + 0.8), "merdiven"])
	if tip == "kulube":
		out.append([Vector3(0, 0, d.z * 0.5 + 0.8), Vector3(0, d.y + RISE * 0.5, 0), "tutunma"])
	return out


## Uçuş konma noktası (yerel): çatının sırtı
static func perches(v: int) -> Array:
	var d := dims(v)
	return [Vector3(0, d.y + RISE - 0.1, OVER * 0.5 - 0.0)]
