class_name World1453
extends RefCounted
## Tek İstanbul haritası (1453). Bütün kuşatma bölümleri aynı coğrafyanın bir parçasında oynanır; her bölümün ayrıntılı
## "bölge"si (LandWalls kesiti, Blakherna, ...) bu haritada sabit bir yerde durur ve çevresi (surun devamı, şehir,
## ordugâh, Haliç, karşı kıyı) her bölümde aynı kurulur. Böylece Blakherna'dan bakınca kara surları güneye doğru
## uzanır, Lykos gediğinden bakınca kuzeyde Blakherna'nın kuleleri ve Haliç görünür.
##
## Dünya koordinatları = LandWalls/SiegeField koordinatları: x kara surları boyunca (+x Marmara, −x Haliç), +z ova ve
## ordugâh, −z şehir. Surun ortası (x 0) Lykos vadisi, Aziz Romanos kapısı ve gedik.
##   · x −700…−580: Blakherna (tek, yüksek sur ve saray); x < −700: Haliç (su), karşıda Osmanlı yakası
##   · x −580…+700: Theodosius surları (iç sur, dış sur, hendek); şehir −z, ordugâh +z (Maltepe'de otağ)
## Bölge dönüşümü: bölgenin yerel koordinatından dünyaya. Bölüm kendi bölgesini yerel koordinatta kurar; çevre
## (SiegeField) bölgenin tersine kaydırılarak eklenir.

const REGIONS := {
	"landwalls": Vector3(0.0, 0.0, 0.0),
	"blachernae": Vector3(-640.0, 0.0, 0.0),
}


## Bölgenin çevresini kurar: dünyanın geri kalanı (SiegeField: sur devamı, şehir, ordugâh, Haliç ucu).
## keep_local: bölgenin kendi oynanış alanı (bölge koordinatında); oraya kalabalık, çadır, ev konmaz ve zemin düz kalır.
static func surround(parent: Node3D, region: String, keep_local: Array, night := true) -> SiegeField:
	var off: Vector3 = REGIONS[region]
	var f := SiegeField.new()
	f.position = -off
	f.fill_center = region != "landwalls"
	if region == "blachernae":
		f.wall_x_min = off.x + 60.0           # Blakherna surunun güney ucu: Theodosius surları buradan başlar
	var keep: Array = []
	for r: Rect2 in keep_local:
		keep.append(Rect2(r.position + Vector2(off.x, off.z), r.size))
	f.keep = keep
	SiegeField.flat_rects = keep.duplicate()
	f.near_works = false
	parent.add_child(f)
	f.build()
	f.set_mode("night" if night else "day")
	return f
