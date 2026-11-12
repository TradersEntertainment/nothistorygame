class_name World1453
extends RefCounted
## Tek İstanbul haritası (1453). Bütün kuşatma bölümleri aynı coğrafyanın bir parçasında oynanır; her bölümün ayrıntılı
## "bölge"si (LandWalls kesiti, Blakherna, Haliç kıyısı, Petrion, ...) bu haritada sabit bir yerde durur ve çevresi
## (surların devamı, şehir, ordugâh, Haliç, Galata, Boğaz, Marmara) her bölümde aynı kurulur.
##
## Dünya koordinatları = LandWalls/SiegeField koordinatları: x kara surları boyunca (+x Marmara, −x Haliç), +z ova ve
## ordugâh, −z şehir. Surun ortası (x 0) Lykos vadisi, Aziz Romanos kapısı ve gedik. Ölçek gerçeğin ≈ 1/4,5'i.
##   · Kara surları x −580…+700 (z 0); Blakherna x −700…−580; surun güney ucu Marmara'da (+700, 0).
##   · Haliç: güney (şehir) kıyısı x = −700, Blakherna köşesinden (z +40) ağza (z −1520, Eugenius kulesi); genişlik
##     ~220 m, kuzey kıyı (Galata, Kasımpaşa, Pınarlar Vadisi) x ≈ −920. Haliç'in iç kolu surların dışında +z'ye
##     uzanır; Eyüp güney kıyıda, surların dışında.
##   · Marmara kıyısı (+700, 0)'dan şehrin burnuna (−560, −1700); burnun ötesi Boğaz.
## Bölge dönüşümü (REGIONS): bölgenin yerel koordinatından dünyaya. Bölüm kendi bölgesini yerel koordinatta kurar;
## dünyanın geri kalanı bölge dönüşümünün tersiyle eklenir (build).

const HORN_S_X := -700.0          # Haliç'in şehir kıyısı
const HORN_N_X := -920.0          # Haliç'in kuzey (Galata/Kasımpaşa) kıyısı
const HORN_IN_Z := 40.0           # Blakherna köşesi (şehir suru burada Haliç'e iner)
const MOUTH_Z := -1520.0          # Haliç ağzı (zincir)
const TIP := Vector3(-600.0, 0.0, -1720.0)   # şehrin burnu
const SHORE_END_Z := -1660.0      # Haliç kıyısının düz bittiği yer (sonra kıyı buruna döner)
const WALL_N_X := -580.0          # Theodosius surlarının kuzey ucu (Blakherna başlar)

const LANDMARKS := {
	"ayasofya": Vector3(-560.0, 0.0, -1480.0),     # iki kıyıya ~140 m (Haliç ve Marmara)
	"galata_tower": Vector3(-971.2, 0.0, -1330.0),
	"galata_center": Vector3(-1060.0, 0.0, -1340.0),
	"blachernae": Vector3(-640.0, 0.0, -20.0),
	"eugenius": Vector3(-690.0, 0.0, -1525.0),
	"chain_s": Vector3(-700.0, 0.0, -1500.0),
	"chain_n": Vector3(-930.0, 0.0, -1480.0),
	"petrion_gate": Vector3(-700.0, 0.0, -650.0),
	"springs": Vector3(-960.0, 0.0, -900.0),
	"eyup": Vector3(-690.0, 0.0, 250.0),
	"bridge": Vector3(-810.0, 0.0, -90.0),
	"romanos": Vector3(0.0, 0.0, 0.0),
	"hippodrome": Vector3(-470.0, 0.0, -1440.0),   # Ayasofya'nın güneybatısı, Marmara'ya doğru
	"column": Vector3(-470.0, 0.0, -1300.0),       # Konstantin Sütunu (Mese üstünde, batıda)
	"great_palace": Vector3(-560.0, 0.0, -1590.0),
	"apostles": Vector3(-330.0, 0.0, -760.0),      # Havariyun Kilisesi (dördüncü tepe)
	"aqueduct_a": Vector3(-420.0, 0.0, -880.0),    # Bozdoğan Kemeri (Valens): Havariyun'dan üçüncü tepeye
	"aqueduct_b": Vector3(-300.0, 0.0, -980.0),
	"damalis": Vector3(-560.0, 0.0, -2072.0),      # Kız Kulesi adacığı (Asya kıyısının önünde)
	"uskudar": Vector3(-700.0, 0.0, -2240.0),      # Khrysopolis / Üsküdar (Asya yakası)
	# Landmarks1453 (docs/CITY_LIFE.md §2): şehrin 1453'te ayakta olan öteki yapıları
	"aya_irini": Vector3(-640.0, 0.0, -1550.0),    # Ayasofya'nın kuzeydoğusu
	"augustaion": Vector3(-555.0, 0.0, -1405.0),   # Mese'nin başı; Justinianus Sütunu
	"cistern": Vector3(-590.0, 0.0, -1378.0),      # Yerebatan Sarnıcı'nın girişi
	"forum_tauri": Vector3(-390.0, 0.0, -1130.0),  # Theodosius Forumu (zafer takı, sütun)
	"pantokrator": Vector3(-540.0, 0.0, -930.0),   # Zeyrek: üç kilise
	"khora": Vector3(-500.0, 0.0, -85.0),          # Kariye, Harisios Kapısı'nın içi
	"pammakaristos": Vector3(-575.0, 0.0, -470.0), # Fethiye, Haliç'e bakan beşinci tepe
	"studios": Vector3(540.0, 0.0, -158.0),        # Marmara surlarının dibinde
	"golden_gate": Vector3(650.0, 0.0, -10.0),     # Altınkapı (kara surlarının güney kapısı)
	"harbor_theodosius": Vector3(32.0, 0.0, -852.0),
	"harbor_kontoskalion": Vector3(-331.0, 0.0, -1329.0),
	"quay_venice": Vector3(-678.0, 0.0, -900.0),   # Haliç iskeleleri (kapıların içi)
	"quay_amalfi": Vector3(-678.0, 0.0, -1180.0),
	"quay_genoa": Vector3(-678.0, 0.0, -1450.0),
	"blachernae_palace": Vector3(-668.0, 0.0, -72.0),
}

## Haliç bölgelerinde yerel su yüzeyi (y 0) dünyanın deniz seviyesine (−1,6) oturur
const SEA_Y := -1.6
const BRIDGE_W := 62.0            # köprünün yerinde Haliç'in genişliği
## Haliç seviyesi (Horn.build) yerel çerçevesi: −z Osmanlı (kuzey) kıyısı, +z karşıdaki şehir suru. Dünyada şehir suru
## x = HORN_S_X boyunca uzanır: yerel +z → dünya +x, yerel +x → dünya −z (y ekseni etrafında +90°).
static var _TO_CITY := Basis(Vector3.UP, PI * 0.5)
## Eyüp (31o): yerel −z güney kıyı (surların dışı), +z Haliç'in iç kolu ve karşı kıyı: yerel +z → dünya −x.
static var _TO_NORTH := Basis(Vector3.UP, -PI * 0.5)

## Ayasofya'nın tepesinin (birinci tepe) görünen yüzeyi: byz_aya bölgesinin yüksekliği
const AYA_Y := 17.6

## Bölüm 2'nin kızak yolunun tepesi (Slipway yerel 0): yokuş 130 m, 7°; ucu kıyıda (x −922), su yerelde −16,64
const SLIP_TOP := Vector3(-1051.0, 15.043, -930.0)

## Bölge → dönüşüm (yerel → dünya)
static var REGIONS := {
	"landwalls": Transform3D.IDENTITY,
	"blachernae": Transform3D(Basis.IDENTITY, Vector3(-640.0, 0.0, 0.0)),
	# 18 ve 18b: Osmanlı köprüsü, Haliç'in en dar yeri (62 m): kuzey kıyı yerel z 0, şehir suru yerel z 62
	"horn_bridge": Transform3D(_TO_CITY, Vector3(HORN_S_X - BRIDGE_W, SEA_Y, -90.0)),
	# 38o: Petrion'un yakınında Haliç surları (yerel sur z 62)
	"horn_wall_o": Transform3D(_TO_CITY, Vector3(HORN_S_X - 62.0, SEA_Y, -560.0)),
	# 31o Eyüp: surların dışında güney kıyı, karşıda Haliç'in iç kolu
	"eyup": Transform3D(_TO_NORTH, Vector3(HORN_S_X, SEA_Y, 250.0)),
	# SeaWalls (17, 19, 19o, 29, 29o): ağızda, zincirin dış yanında şehir suru ve rıhtım; yerel +z Haliç'in karşısı
	# (kuzey), yerel +x Haliç'in içine doğru (yerel x 75'teki deniz savaşı zincirin hemen önünde)
	"horn_chain": Transform3D(_TO_NORTH, Vector3(HORN_S_X, SEA_Y, -1600.0)),
	# 39o Petrion: cadde yerel −z boyunca şehrin içine; kapının suru (yerel z 5,5) Haliç surunun üstünde (x −700)
	"petrion": Transform3D(_TO_NORTH, Vector3(HORN_S_X + 5.5, 0.0, -650.0)),
	# 27 Galata: rıhtım (yerel z 1,2) kuzey kıyının 8 m önünde (kıyı yamacı rıhtımın önüne taşmasın), karşı şehir yerel +z; Galata Kulesi yerel (8, −58) = galata_tower.
	# Yerel su (−1,2) dünyanın deniz seviyesine oturur.
	"galata": Transform3D(_TO_CITY, Vector3(HORN_N_X + 6.8, -0.4, -1322.0)),
	# 17o: Kasımpaşa kıyısında Osmanlı bataryası (Pınarlar Vadisi'nin ağzı); kıyı yerel z 0, Galata yerel +x'te (~180 m).
	# Yerel su (−0,35) deniz seviyesinde.
	"springs": Transform3D(_TO_CITY, Vector3(HORN_N_X, SEA_Y + 0.35, -1150.0)),
	# 2 (Yağlı Kızaklar): kızak yolunun Haliç'e indiği yer, Pınarlar Vadisi'nin ağzı (Kasımpaşa). Yokuş kıyıya dik iner:
	# yerel −z dünya +x (Haliç'e), yerel −x dünya −z (Galata, ağız ve zincir solda). Yokuşun tepesi (yerel 0) SLIP_TOP,
	# ucu kıyıda (−922, −930); yerel su (−16,64) deniz seviyesinde.
	"slipway": Transform3D(_TO_NORTH, SLIP_TOP),
	# CampDay (ordugâh bölümleri): yerel +z surlara (dünya −z), otağ yerel (0, −62) = Maltepe'deki otağ (30, 480)
	"camp": Transform3D(Basis(Vector3.UP, PI), Vector3(30.0, 0.0, 418.0)),
	# Otağın içi (OtagHall: 10a, 12, 13): salonun yereli; merkez tabanda, kapı yerel +z = ordugâhın yolu ve surlar (dünya −z).
	# CampDay'deki otağın (yerel (0, −62)) yeriyle aynı: "camp" dönüşümü + (0, 0, −62)
	"otag": Transform3D(Basis(Vector3.UP, PI), Vector3(30.0, 0.0, 480.0)),
	# ByzCity'nin sur parçası (6, 10H, 12B, 13, 23, 24): iç sur (yerel x 34) = kara surlarının iç suru (dünya z −2,3),
	# Romanos Kapısı (yerel z 5,5) = dünya x 0; yerel +x ova, yerel +z Haliç yönü
	"byz_walls": Transform3D(_TO_NORTH, Vector3(5.5, 0.0, -36.3)),
	# ByzCity'nin Ayasofya parçası (24, 25, 26, 31o): yerel AYA (−14, −82) = dünyanın Ayasofya'sı. Yükseklik birinci
	# tepenin görünen yüzeyi (AYA_Y): eskiden 0'daydı, bölüm Ayasofya'yı 17 m'lik bir çukura kuruyordu; uçuşta aynı
	# Ayasofya tepenin üstündeydi (iki bölümde iki farklı yerde)
	"byz_aya": Transform3D(_TO_NORTH, Vector3(-560.0 - 82.0, AYA_Y, -1480.0 + 14.0)),
}


## Uzak görünüşü dünyada kurulan bölgeler: bölge → oynanış dikdörtgeni (yerel). Bölüm o bölgede değilse dünya, bölgenin
## kendi kurucusunun pişirilmiş sürümünü koyar (ByzCity.far_hub). Ayasofya (byz_aya) HornWorld'de (World1453.far_aya).
const FAR_REGIONS := {"byz_walls": Rect2(-46.0, -48.0, 84.0, 70.0)}


## Tepelerin arasındaki bölgeler: dünya zemini düz alana rampayla iner
## Kara surlarının kapıları (dünya x'i; iç sur, dış sur, korkuluk ve hendek kesilir, hendeğin üstünde geçit):
## Harisios (Edirnekapı), Pempton, Romanos (Bizans şehri bölgesinin iç surundaki kapıyla aynı hizada), Rhegion,
## Pege (Silivrikapı), Altınkapı
const LAND_GATES := [-460.0, -230.0, 37.0, 170.0, 340.0, 520.0, 650.0]
## Kıyı surlarının kapıları: Haliç kıyısında (z) ve Marmara kıyısında (0..1 kesir) Petrion'a ek olarak
const HORN_GATE_Z := [-260.0, -520.0, -900.0, -1180.0, -1450.0]
const MARMARA_GATES := [0.22, 0.5, 0.78]
## Bölgenin altında dünya zemininin ineceği yükseklik (bölgenin arazisi kıyıya, suya iniyorsa)
const FLAT_Y := {"slipway": -6.0}
const BLEND := {"petrion": 70.0, "galata": 60.0, "camp": 90.0, "byz_aya": 70.0}


static func region(name: String) -> Transform3D:
	if REGIONS.has(name):
		return REGIONS[name]
	return Transform3D.IDENTITY


## Bölgenin yerel noktasını dünyaya çevirir
static func to_world(name: String, p: Vector3) -> Vector3:
	return region(name) * p


## Dünyadaki bir yer işaretinin bölgedeki yerel konumu
static func landmark_local(name: String, key: String) -> Vector3:
	return region(name).affine_inverse() * (LANDMARKS[key] as Vector3)


# ---------------------------------------------------------------- coğrafya

## Marmara kıyısının x'i (z < 0: kara surlarının güney ucundan şehrin burnuna)
static func marmara_x(z: float) -> float:
	if z >= 0.0:
		return 700.0
	return lerpf(700.0, TIP.x, clampf(-z / -TIP.z, 0.0, 1.0))


## Şehrin içinde mi (surların içi, deniz değil)
static func in_city(x: float, z: float, margin := 0.0) -> bool:
	return z < -margin and z > TIP.z + margin and x > HORN_S_X + margin and x < marmara_x(z) - margin


## Su mu (Haliç, Boğaz, Marmara)
static func is_water(x: float, z: float) -> bool:
	if x > 700.0 and z > -10.0:
		return true                                   # Marmara (surların güney ucunun ötesi)
	if z < 0.0 and x > marmara_x(z) and x > HORN_S_X:
		return true                                   # Marmara (şehrin güney kıyısı)
	if z < TIP.z and x > HORN_N_X:
		return z > asia_z(x)                          # Boğaz / burnun ötesi (ötesi Asya yakası)
	if x < HORN_S_X and x > horn_n_x(z) and z < 520.0:
		return true                                   # Haliç
	return false


## Asya yakasının kıyısı (Üsküdar karşıda, Kadıköy'e doğru kıyı geri çekilir): z bundan küçükse kara
static func asia_z(x: float) -> float:
	return -2120.0 - 260.0 * smoothstep(100.0, 900.0, x) + 18.0 * sin(x * 0.006)


## Dünyanın tek yükseklik fonksiyonu (uçuş çarpışması ve uzaktaki yerleşimler): bölgelerin düz alanlarında batmadan
static func ground_h(x: float, z: float) -> float:
	if z < asia_z(x):
		return HornWorld.asia_h(x, z)
	if in_city(x, z):
		return city_ground(x, z)
	if is_water(x, z):
		return SEA_Y - 2.4
	if x < horn_n_x(z) + 6.0 or (z < TIP.z and x < HORN_N_X):
		return HornWorld.north_h(x, z, true)
	return SiegeField.ground(x, z, true)


## Şehrin arazisi (SiegeField.city_ground) ve Ayasofya meydanının düzlüğü: byz_aya bölgesinin oynanış alanı her bölümde
## AYA_Y'de düz, çevresine 40 m'de rampayla iner (bölümün kendi düzlüğüyle aynı; uçuşta Ayasofya yamaca gömülmesin)
static var _aya_pad := Rect2()

static func city_ground(x: float, z: float) -> float:
	var h := SiegeField.city_ground(x, z)
	if _aya_pad.size == Vector2.ZERO:
		_aya_pad = world_rect(region("byz_aya"), Rect2(-46.0, -114.0, 64.0, 76.0))
	var dx := maxf(maxf(_aya_pad.position.x - x, 0.0), x - _aya_pad.end.x)
	var dz := maxf(maxf(_aya_pad.position.y - z, 0.0), z - _aya_pad.end.y)
	var d := Vector2(dx, dz).length()
	if d >= 40.0:
		return h
	return lerpf(h, AYA_Y - 0.05, 1.0 - smoothstep(0.0, 40.0, d))


## Görünen arazinin yüzeyi (ground_h'nin kaba ızgaralı çizilmiş hâli): dünyaya konan yapılar ve uçuşun noktaları
static func surface_h(x: float, z: float) -> float:
	if z < asia_z(x):
		return HornWorld.asia_surf(x, z)
	if in_city(x, z):
		return HornWorld.east_surf(x, z) if z < -700.0 else SiegeField.city_surf(x, z)
	if is_water(x, z):
		return SEA_Y - 2.4
	if x < horn_n_x(z) + 6.0 or (z < TIP.z and x < HORN_N_X):
		return HornWorld.north_surf(x, z)
	return SiegeField.surf(x, z)


## Haliç'in iç kolunda (surların dışı, +z) kuzey kıyı yaklaşır: kol daralır
static func horn_narrow(z: float) -> float:
	return 150.0 * smoothstep(60.0, 520.0, z)


## Kuzey kıyının x'i: iç kolda daralır; köprünün yerinde (Osmanlı köprüsü, z ≈ −90) kıyı öne çıkar (Haliç 62 m)
static func horn_n_x(z: float) -> float:
	var bulge := (HORN_S_X - BRIDGE_W) - HORN_N_X
	return HORN_N_X + horn_narrow(z) + bulge * exp(-pow((z + 90.0) / 150.0, 2.0))


# ---------------------------------------------------------------- kurucu

## Bölgenin çevresini kurar: dünyanın geri kalanı (SiegeField: sur devamı, şehir, ova, ordugâh; HornWorld: Haliç,
## kıyı surları, Galata, Boğaz, Marmara). keep_local: bölgenin kendi oynanış alanı (bölge koordinatında); oraya
## kalabalık, çadır, ev konmaz ve zemin düz kalır. Dönen bölgelerde dikdörtgenin dünyadaki sınır kutusu kullanılır.
## blend_local: rampanın ölçüldüğü düz oynanış alanı (bölgenin kendi arazisi keep'in tamamını kaplıyorsa)
static func build(parent: Node3D, region_name: String, keep_local: Array, night := true, blend_local: Array = []) -> SiegeField:
	var xf := region(region_name)
	var f := SiegeField.new()
	f.transform = xf.affine_inverse()
	f.region_name = region_name
	f.fill_center = region_name != "landwalls"
	f.wall_x_min = WALL_N_X
	var keep: Array = []
	for r: Rect2 in keep_local:
		keep.append(world_rect(xf, r))
	f.keep = keep
	SiegeField.flat_rects = keep.duplicate()
	# Bölgenin kendi zemini dünya zemininin üstünde kalsın: dünya, bölgenin altına iner
	SiegeField.flat_y = xf.origin.y - 0.8 if xf.origin.y < -0.1 else -0.03
	if FLAT_Y.has(region_name):
		SiegeField.flat_y = FLAT_Y[region_name]
	if BLEND.has(region_name):
		SiegeField.flat_y = xf.origin.y - 0.05        # dünya zemini bölgenin zemini olur (yerel y 0'ın hemen altı)
	# Başka bölgelerin bölümlerde kurulan yapıları (hub: kançılarya, saray avlusu, cadde) burada da durur: dünya oraya kendi
	# evini, ağacını, kalabalığını koymaz (FAR_REGIONS). Bölümün kendi alanıyla kesişirse kurulmaz.
	var far: Array = []
	for fr: String in FAR_REGIONS:
		if fr == region_name:
			continue
		var wr := world_rect(region(fr), FAR_REGIONS[fr])
		var hit := false
		for r: Rect2 in keep:
			if r.grow(20.0).intersects(wr):
				hit = true
		if not hit:
			far.append(fr)
			f.keep.append(wr)
	f.near_works = false
	f.night_build = night
	SiegeField.flat_blend = BLEND.get(region_name, 0.0)
	var br: Array = []
	for r: Rect2 in blend_local:
		br.append(world_rect(xf, r))
	SiegeField.blend_rects = br
	parent.add_child(f)
	f.build()
	f.set_mode("night" if night else "day")
	# Her yer yürünür: dünyanın görüntüsü katılaşır (karelere yayılarak)
	WorldWalk.attach(f)
	# Yaşayan şehir: oyuncunun çevresinde siviller ve devriyeler (dönem bölümden; testlerin dünyalarına eklenmez)
	if CityLife.auto_ok(parent):
		CityLife.attach(f, CityLife.opts_for(parent, night))
	for fr: String in far:
		match fr:
			"byz_walls":
				ByzCity.far_hub(f, region(fr))
	# Ateşler: Dressing.glow kutuları (ordugâhın, ovanın, surların, kıyının gece ateşleri) alev ve haleye çevrilir
	Flame.from_glow_boxes(f)
	# Gölgelendiriciler yüklemede derlensin (yaklaşınca donma olmasın)
	ShaderWarmup.after_world(f)
	return f


## Eski ad (Blakherna bölümleri)
static func surround(parent: Node3D, region_name: String, keep_local: Array, night := true) -> SiegeField:
	return build(parent, region_name, keep_local, night)


static func world_rect(xf: Transform3D, r: Rect2) -> Rect2:
	var pts := [Vector3(r.position.x, 0, r.position.y), Vector3(r.end.x, 0, r.position.y),
		Vector3(r.position.x, 0, r.end.y), Vector3(r.end.x, 0, r.end.y)]
	var out := Rect2()
	for i in pts.size():
		var w: Vector3 = xf * (pts[i] as Vector3)
		if i == 0:
			out = Rect2(Vector2(w.x, w.z), Vector2.ZERO)
		else:
			out = out.expand(Vector2(w.x, w.z))
	return out


# ---------------------------------------------------------------- uçuş (Nihat: Bölüm 7, 11)

## Uçuşun yer işaretleri, parçaları ve konma noktaları (NihatPowers biçiminde, sahne koordinatında). Kimlikler ve parça
## numaraları eski panoramayla aynı (yan görevler: seyyah, forms, perch).
static func flight_data(world: SiegeField) -> Dictionary:
	var at := func(key: String, dy: float, off := Vector3.ZERO) -> Vector3:
		var p: Vector3 = (LANDMARKS[key] as Vector3) + off
		return world.to_global(Vector3(p.x, surface_h(p.x, p.z) + dy, p.z))
	var mid := func(a: String, b: String) -> Vector3:
		return ((LANDMARKS[a] as Vector3) + (LANDMARKS[b] as Vector3)) * 0.5
	var tw: Vector3 = LANDMARKS["galata_tower"]
	var gallery := galata_top(tw) - 1.2
	var cm: Vector3 = mid.call("chain_s", "chain_n")
	var aq: Vector3 = mid.call("aqueduct_a", "aqueduct_b")
	var landmarks := [
		["AYASOFYA", at.call("ayasofya", AYA_DOME_TOP + 6.0), 48.0],
		["HIPODROM", at.call("hippodrome", 12.0), 60.0],
		["KONSTANTIN", at.call("column", ByzCity.COLUMN_TOP + 1.0), 26.0],
		["HAVARIYUN", at.call("apostles", 24.0), 38.0],
		["BOZDOGAN", world.to_global(Vector3(aq.x, ground_h(aq.x, aq.z) + 26.0, aq.z)), 34.0],
		["ZINCIR", world.to_global(Vector3(cm.x, 8.0, cm.z)), 45.0],
		["GALATA", world.to_global(Vector3(tw.x, gallery + 6.0, tw.z)), 36.0],
		["BLAKHERNA", at.call("blachernae", 16.0), 34.0],
		["SURLAR", at.call("romanos", 18.0, Vector3(0, 0, 9.0)), 30.0],
	]
	var gc: Vector3 = LANDMARKS["galata_center"]
	var e: Vector3 = LANDMARKS["eugenius"]
	var forms := [
		[1, at.call("ayasofya", AYA_DOME_TOP + 0.4, Vector3(4.0, 0, 0))],
		[2, at.call("column", ByzCity.COLUMN_TOP + 2.5)],
		[3, world.to_global(Vector3(tw.x + 7.6, gallery + 1.0, tw.z))],
		[4, at.call("hippodrome", 22.0, Vector3(0, 0, -30.0))],
		[5, world.to_global(Vector3(aq.x, ground_h(aq.x, aq.z) + 21.0, aq.z))],
		[6, at.call("apostles", 30.0)],
		[7, at.call("blachernae", 37.0, Vector3(24.0, 0, -2.0))],
		[8, world.to_global(Vector3(e.x, 24.0, e.z))],
		[9, world.to_global(Vector3(gc.x - 30.0, HornWorld.north_h(gc.x - 30.0, gc.z + 20.0, true) + 20.0, gc.z + 20.0))],
		[10, world.to_global((LANDMARKS["damalis"] as Vector3) + Vector3(0, 21.0, 0))],
		[11, at.call("romanos", 14.4, Vector3(0, 0, 9.0))],
		[12, at.call("uskudar", 22.0)],
	]
	var col: Vector3 = LANDMARKS["column"]
	var perches := [
		# kubbenin tepesindeki haçın 3,5 m yanında, kubbe yüzeyinde
		["aya", at.call("ayasofya", 19.5 + 11.1 * 0.42 * sqrt(1.0 - pow(3.5 / 11.1, 2.0)), Vector3(3.5, 0, 0)), 5.0],
		["galata", world.to_global(Vector3(tw.x, gallery, tw.z)), 9.5],
		["column", world.to_global(Vector3(col.x, HornWorld.east_surf(col.x, col.z) + ByzCity.COLUMN_TOP, col.z)), 3.5],
	]
	return {"landmarks": landmarks, "forms": forms, "perches": perches}


## Galata Kulesi'nin feneri (GalataView top_y): HornWorld ve uçuş aynı değeri kullanır
static func galata_top(tw: Vector3) -> float:
	return HornWorld.north_surf(tw.x, tw.z) + 34.0      # kule görünen yüzeye oturur (GalataView)


# ---------------------------------------------------------------- ortak kurucuların uzak sürümü (tek harita)

## Ayasofya'nın kubbesinin tepesi (bölgenin zemininden): ByzCity.aya_exterior'ın kurşun kubbesi (y 19,5, yarıçap 11,1,
## basıklık 0,42). Uçuşun konma noktası, parçası ve yer işareti buna göre.
const AYA_DOME_TOP := 19.5 + 11.1 * 0.42


## Ayasofya'nın uzak görünüşü: bölümün kendi dış kabuğu (ByzCity.aya_exterior + Ayasofya.build'in "exterior" parçaları:
## gövde duvarları, narteks, apsis, kurşun çatı) sahne dışında kurulur ve bölgenin dünyadaki yerine tek birleşik ağ
## olarak pişirilir (iki çizim). Yerdeki Ayasofya ile aynı yer, ölçü, biçim ve renk.
static func far_aya(parent: Node3D) -> MeshInstance3D:
	var tmp := Node3D.new()
	ByzCity.aya_exterior(tmp)
	var inner := Node3D.new()
	inner.position = ByzCity.AYA
	tmp.add_child(inner)
	Ayasofya._shell_walls(inner)
	Ayasofya._narthex(inner)
	Ayasofya._apse(inner)
	Ayasofya._domes(inner)
	var list: Array = []
	for n in tmp.find_children("*", "MeshInstance3D", true, false):
		if not inner.is_ancestor_of(n) or n.has_meta("exterior") or n.get_parent().has_meta("exterior"):
			list.append(n)
	var mi := bake(list, tmp, region("byz_aya"), parent, "FarAyasofya")
	# Uzaklık katmanı: 90 m'ye kadar dokulu, dış çizgili kabuk; ötesinde küçük parçasız, tek yüzeyli, dış çizgisiz kopya
	# (siluet ve renk aynı; uzaktan dış çizgi zaten seçilmez, üçgen yarıya iner)
	var lo := bake(list, tmp, region("byz_aya"), mi, "FarAyasofyaLo", 1.2, 0, true)
	lo.transform = Transform3D.IDENTITY
	lo.material_override = Scenery._vc_mat()
	lo.set_meta("no_walk", true)            # çarpışma yakın kabuktan
	# Kenar payı (hysteresis) yok: iki katman da gizliyken arada bir ölü bant kalıyordu (ikisi de görünmüyordu)
	mi.visibility_range_end = 90.0
	lo.visibility_range_begin = 90.0
	tmp.free()
	return mi


static var _tex_avg := {}

## Pişirici (ortak arayüz): verilen MeshInstance3D'leri top düğümüne göre dönüşümleriyle, xf (top yereli → parent
## yereli) ile TEK MeshInstance3D'ye toplar. Düz renkli parçalar köşe rengiyle tek yüzeyde (Dressing malzemesi: toon + dış
## çizgi); desenli parçalar (taş, sıva, kiremit, tuğla: dünya üçlü düzlem dokusu) doku başına bir yüzeyde, renkleri köşe
## renginde (malzemenin kendisi, beyaz albedo). min_size: en uzun kenarı bundan kısa parçalar (saksı, çivi) atılır.
## max_tris > 0: üçgeni bundan çok olan hazır model parçası (Kit kiremit çatısı) kendi kutusunu dolduran beşik çatıyla
## (aynı siluet, dokusunun ortalama renginde) değiştirilir: uzaktan aynı, üçgeni yüzde biri. flat: desenler de dokunun
## ortalama rengiyle tek yüzeye (uzak sürüm: tek çizim + dış çizgi). Yakından da yerdekiyle aynı doku; çizim sayısı = farklı doku sayısı + 1
## (her biri dış çizgiyle iki). Işıklı (ateş, pencere ışığı), saydam, yazı ve 5 cm'den küçük parçalar atılır; Person
## altındakiler (insanlar) atılır.
static func bake(list: Array, top: Node3D, xf: Transform3D, parent: Node3D, node_name := "Baked", min_size := 0.05, max_tris := 0, flat := false) -> MeshInstance3D:
	var groups := {}           # anahtar -> [v, n, c, malzeme]
	for n: MeshInstance3D in list:
		if n.mesh == null or not n.visible:
			continue
		var sz := n.mesh.get_aabb().size * n.scale.abs()
		if maxf(sz.x, maxf(sz.y, sz.z)) < min_size:
			continue
		var rel := Transform3D.IDENTITY
		var cur: Node = n
		var skip := false
		while cur != null and cur != top:
			if cur is Person or (cur is Node3D and not (cur as Node3D).visible):
				skip = true
				break
			if cur is Node3D:
				rel = (cur as Node3D).transform * rel
			cur = cur.get_parent()
		if skip:
			continue
		var t := xf * rel
		var nb := t.basis.inverse().transposed()
		if max_tris > 0 and not (n.mesh is PrimitiveMesh):
			var tc := 0
			for si in n.mesh.get_surface_count():
				tc += n.mesh.surface_get_array_index_len(si) / 3 if n.mesh.surface_get_array_index_len(si) > 0 else n.mesh.surface_get_array_len(si) / 3
			if tc > max_tris:
				var ab := n.mesh.get_aabb()
				var m0 := n.get_active_material(0) as BaseMaterial3D
				var rc := Color(0.7, 0.36, 0.26)
				if m0:
					rc = m0.albedo_color * _avg(m0.albedo_texture)
				if not groups.has("flat"):
					var fst := SurfaceTool.new()
					fst.begin(Mesh.PRIMITIVE_TRIANGLES)
					groups["flat"] = [fst, Dressing._material()]
				var pm := PrismMesh.new()
				pm.size = ab.size
				var pt := t * Transform3D(Basis.IDENTITY, ab.get_center())
				var pa := pm.surface_get_arrays(0)
				var pv: PackedVector3Array = pa[Mesh.ARRAY_VERTEX]
				var pn: PackedVector3Array = pa[Mesh.ARRAY_NORMAL]
				var pidx: PackedInt32Array = pa[Mesh.ARRAY_INDEX]
				var pnb := pt.basis.inverse().transposed()
				var fst2: SurfaceTool = groups["flat"][0]
				for k in pidx:
					fst2.set_color(Color(rc.r, rc.g, rc.b, 1.0))
					fst2.set_normal((pnb * pn[k]).normalized())
					fst2.add_vertex(pt * pv[k])
				continue
		for si in n.mesh.get_surface_count():
			var m := n.get_active_material(si)
			var col := Color(0.8, 0.78, 0.74)
			var key := "flat"
			var gmat: Material = null
			if m is ShaderMaterial:
				continue                  # alev, su, gölgelendiricili süs: uzak kabuğa girmez
			if m is BaseMaterial3D:
				var bm := m as BaseMaterial3D
				if bm.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and bm.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR:
					continue
				if bm.emission_enabled and bm.emission_energy_multiplier > 0.5:
					continue
				col = bm.albedo_color
				if bm.albedo_texture and bm.uv1_triplanar and bm.uv1_world_triplanar and not flat:
					key = "%s|%s" % [bm.albedo_texture.get_rid(), bm.uv1_scale]
					if not groups.has(key):
						var gm := bm.duplicate() as StandardMaterial3D
						gm.albedo_color = Color.WHITE
						gm.vertex_color_use_as_albedo = true
						gmat = gm
				elif bm.albedo_texture:
					col = col * _avg(bm.albedo_texture)
			if not groups.has(key):
				var nst := SurfaceTool.new()
				nst.begin(Mesh.PRIMITIVE_TRIANGLES)
				groups[key] = [nst, gmat if gmat else Dressing._material()]
			var st: SurfaceTool = groups[key][0]
			var arr := n.mesh.surface_get_arrays(si)
			var sv: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var sn: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
			var ia = arr[Mesh.ARRAY_INDEX]
			var idx: PackedInt32Array = ia if ia != null else PackedInt32Array()
			var count := idx.size() if idx.size() > 0 else sv.size()
			var c3 := Color(col.r, col.g, col.b, 1.0)
			for k in count:
				var i: int = idx[k] if idx.size() > 0 else k
				st.set_color(c3)
				st.set_normal((nb * (sn[i] if sn.size() > i else Vector3.UP)).normalized())
				st.add_vertex(t * sv[i])
	var mi := MeshInstance3D.new()
	mi.name = node_name
	# Ayrıntı düzeyleri (ImporterMesh.generate_lods): uzaklaştıkça motor sadeleştirilmiş üçgen dizisini çizer
	var im := ImporterMesh.new()
	for key: String in groups:
		var g: Array = groups[key]
		var st: SurfaceTool = g[0]
		st.index()
		im.add_surface(Mesh.PRIMITIVE_TRIANGLES, st.commit_to_arrays(), [], {}, g[1])
	if im.get_surface_count() > 0:
		im.generate_lods(25.0, 60.0, [])
		mi.mesh = im.get_mesh()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


## Desen dokusunun ortalama rengi (yoksa ya da henüz üretilmediyse beyaz)
static func _avg(tex: Texture2D) -> Color:
	if tex == null:
		return Color.WHITE
	if _tex_avg.has(tex):
		return _tex_avg[tex]
	var img := tex.get_image()
	if img == null or img.is_empty():
		return Color.WHITE
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	# 24×24 örnekle ortalama (tek piksele küçültme yalnız birkaç pikseli örnekliyordu: tuğla dokusu derz renginde çıkıyordu)
	var c := Color(0, 0, 0, 0)
	var n := 0
	for j in 24:
		for i in 24:
			c += img.get_pixel(int((i + 0.5) * img.get_width() / 24.0), int((j + 0.5) * img.get_height() / 24.0))
			n += 1
	c /= float(n)
	_tex_avg[tex] = c
	return c
