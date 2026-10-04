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
	# CampDay (ordugâh bölümleri): yerel +z surlara (dünya −z), otağ yerel (0, −62) = Maltepe'deki otağ (30, 480)
	"camp": Transform3D(Basis(Vector3.UP, PI), Vector3(30.0, 0.0, 418.0)),
	# ByzCity'nin sur parçası (6, 10H, 12B, 13, 23, 24): iç sur (yerel x 34) = kara surlarının iç suru (dünya z −2,3),
	# Romanos Kapısı (yerel z 5,5) = dünya x 0; yerel +x ova, yerel +z Haliç yönü
	"byz_walls": Transform3D(_TO_NORTH, Vector3(5.5, 0.0, -36.3)),
	# ByzCity'nin Ayasofya parçası (24, 25, 26, 31o): yerel AYA (−14, −82) = dünyanın Ayasofya'sı
	"byz_aya": Transform3D(_TO_NORTH, Vector3(-560.0 - 82.0, 0.0, -1480.0 + 14.0)),
}


## Tepelerin arasındaki bölgeler: dünya zemini düz alana rampayla iner
## Kara surlarının kapıları (dünya x'i; iç sur, dış sur, korkuluk ve hendek kesilir, hendeğin üstünde geçit):
## Harisios (Edirnekapı), Pempton, Romanos (Bizans şehri bölgesinin iç surundaki kapıyla aynı hizada), Rhegion,
## Pege (Silivrikapı), Altınkapı
const LAND_GATES := [-460.0, -230.0, 37.0, 170.0, 340.0, 520.0, 650.0]
## Kıyı surlarının kapıları: Haliç kıyısında (z) ve Marmara kıyısında (0..1 kesir) Petrion'a ek olarak
const HORN_GATE_Z := [-260.0, -520.0, -900.0, -1180.0, -1450.0]
const MARMARA_GATES := [0.22, 0.5, 0.78]
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
		return SiegeField.city_ground(x, z)
	if is_water(x, z):
		return SEA_Y - 2.4
	if x < horn_n_x(z) + 6.0 or (z < TIP.z and x < HORN_N_X):
		return HornWorld.north_h(x, z, true)
	return SiegeField.ground(x, z, true)


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
	if BLEND.has(region_name):
		SiegeField.flat_y = xf.origin.y - 0.05        # dünya zemini bölgenin zemini olur (yerel y 0'ın hemen altı)
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
		["AYASOFYA", at.call("ayasofya", 46.0), 48.0],
		["HIPODROM", at.call("hippodrome", 12.0), 60.0],
		["KONSTANTIN", at.call("column", 30.0), 26.0],
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
		[1, at.call("ayasofya", 51.4, Vector3(6.0, 0, 0))],
		[2, at.call("column", 36.5)],
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
		["aya", at.call("ayasofya", 51.4 - 1.0), 8.0],
		["galata", world.to_global(Vector3(tw.x, gallery, tw.z)), 9.5],
		["column", world.to_global(Vector3(col.x, HornWorld.east_surf(col.x, col.z) + 34.0, col.z)), 3.5],
	]
	return {"landmarks": landmarks, "forms": forms, "perches": perches}


## Galata Kulesi'nin feneri (GalataView top_y): HornWorld ve uçuş aynı değeri kullanır
static func galata_top(tw: Vector3) -> float:
	return HornWorld.north_surf(tw.x, tw.z) + 34.0      # kule görünen yüzeye oturur (GalataView)
