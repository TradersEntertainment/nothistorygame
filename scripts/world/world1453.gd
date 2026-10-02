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
	"ayasofya": Vector3(-380.0, 0.0, -1420.0),
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
	"hippodrome": Vector3(-250.0, 0.0, -1320.0),
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
}


## Tepelerin arasındaki bölgeler: dünya zemini düz alana rampayla iner
const BLEND := {"petrion": 70.0, "galata": 60.0}


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
		return true                                   # Boğaz / burnun ötesi
	if x < HORN_S_X and x > horn_n_x(z) and z < 520.0:
		return true                                   # Haliç
	return false


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
static func build(parent: Node3D, region_name: String, keep_local: Array, night := true) -> SiegeField:
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
	parent.add_child(f)
	f.build()
	f.set_mode("night" if night else "day")
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
