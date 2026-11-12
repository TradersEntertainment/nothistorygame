class_name IstHipoSaray
extends RefCounted
## Büyük Saray harabeleri, Khalke kalıntısı, Zeuksippos hamamı harabesi, Nea Ekklesia kalıntısı. Bkz. hipodrom.gd.

const K := preload("res://scripts/world/ist/hipodrom_kit.gd")

static func catalog() -> Array:
	return [
		{"id": "buyuk_saray", "ad": "Büyük Saray harabeleri", "dogu_m": -90.0, "kuzey_m": -400.0,
		 "gercek_olcu": Vector3(120.0, 14.0, 150.0), "yon_derece": 35.0, "durum": "harap", "tur": "anit",
		 "bakis": Vector3(0, 26.0, 0), "bakis_r": 60.0, "gorev": true},
		{"id": "khalke", "ad": "Khalke Kapısı kalıntısı", "dogu_m": -45.0, "kuzey_m": -150.0,
		 "gercek_olcu": Vector3(30.0, 18.0, 24.0), "yon_derece": 0.0, "durum": "harap", "tur": "kapi",
		 "bakis": Vector3(0, 24.0, 0), "bakis_r": 30.0, "gorev": true},
		{"id": "zeuksippos", "ad": "Zeuksippos hamamı harabesi", "dogu_m": -170.0, "kuzey_m": -185.0,
		 "gercek_olcu": Vector3(46.0, 16.0, 62.0), "yon_derece": 35.0, "durum": "harap", "tur": "anit",
		 "bakis": Vector3(0, 24.0, 0), "bakis_r": 35.0, "gorev": true},
		{"id": "nea", "ad": "Nea Ekklesia kalıntısı", "dogu_m": -30.0, "kuzey_m": -360.0,
		 "gercek_olcu": Vector3(30.0, 25.0, 38.0), "yon_derece": 90.0, "durum": "harap", "tur": "kilise",
		 "bakis": Vector3(0, 28.0, 0), "bakis_r": 35.0, "gorev": true},
	]


# ---------------------------------------------------------------------------------------------------------------
# Büyük Saray: üç yıkık salon (tuğla-taş), kemerli alt yapı terası, mozaik döşeme parçaları, bostanlaşmış avlu
# ---------------------------------------------------------------------------------------------------------------
static func _sz(k: float) -> Vector2:
	return Vector2(maxf(120.0 * k, 52.0), maxf(150.0 * k, 66.0))


## Salon: dört duvar (kapı boşlukları ≥ 2,4 m), yarı yıkık, içi mozaikli döşeme, tonoz yıkığı (düşmüş kemer parçaları), ot.
static func _hall(host: Node3D, cx: float, cz: float, w: float, d: float, h: float, rng: RandomNumberGenerator, lod: int, y0 := 0.0, apse := false) -> void:
	var t := 1.1
	var wall := K.BRICK.lerp(K.STONE, 0.3)
	K.ground_box(host, w, 0.12, d, cx, cz, K.LIGHT.darkened(0.12), "marble", y0)
	# iki uzun duvar, kapı boşlukları: sol ortada, sağ kenara yakın
	for sx: float in [-1.0, 1.0]:
		var x := cx + sx * (w * 0.5 - t * 0.5)
		_wall_with_door(host, Vector2(x, cz - d * 0.5), Vector2(x, cz + d * 0.5), h, t, wall, rng, y0, d * (0.5 if sx < 0 else 0.25))
	_wall_with_door(host, Vector2(cx - w * 0.5, cz + d * 0.5 - t * 0.5), Vector2(cx + w * 0.5, cz + d * 0.5 - t * 0.5), h, t, wall, rng, y0, w * 0.5)
	_wall_with_door(host, Vector2(cx - w * 0.5, cz - d * 0.5 + t * 0.5), Vector2(cx + w * 0.5, cz - d * 0.5 + t * 0.5), h * 0.7, t, wall, rng, y0, -1.0)
	if apse:
		K.sc(host, w * 0.3, h * 0.6, Vector3(cx, y0 + h * 0.3, cz - d * 0.5 - w * 0.15), wall.darkened(0.05), 8, w * 0.29)
	if lod == 0:
		K.mosaic(host, Vector3(cx, y0 + 0.12, cz), Vector2(minf(w - 4.0, 9.0), minf(d - 4.0, 9.0)), rng, 7)
		# düşmüş tonoz kemerleri ve sütun gövdeleri
		for i in 3:
			var p := Vector3(cx + rng.randf_range(-w * 0.3, w * 0.3), y0 + 0.5, cz + rng.randf_range(-d * 0.3, d * 0.3))
			if i < 2:
				K.vb(host, Vector3(0.9, 0.9, rng.randf_range(2.5, 4.0)), p, K.STONE_D, Vector3(rng.randf() * 25.0, rng.randf() * 180.0, rng.randf() * 20.0))
			else:
				K.sc(host, 0.45, 2.4, p + Vector3(0, 0.1, 0), K.MARBLE.darkened(0.08), 8, 0.4, Vector3(0, 0, 80.0 + rng.randf() * 20.0))
		K.scatter(host, Rect2(cx - w * 0.4, cz - d * 0.4, w * 0.8, d * 0.8), int(w * d * 0.06), rng, y0 + 0.12, "ot")
		K.scatter(host, Rect2(cx - w * 0.4, cz - d * 0.4, w * 0.8, d * 0.8), int(w * d * 0.02), rng, y0 + 0.12, "moloz")


## Kapı boşluklu yıkık duvar: door_at, duvar boyunda (a→b) uzaklık (<0 ise kapı yok).
static func _wall_with_door(host: Node3D, a: Vector2, b: Vector2, h: float, t: float, color: Color, rng: RandomNumberGenerator, y0: float, door_at: float) -> void:
	var len := a.distance_to(b)
	if door_at < 0.0 or len < 8.0:
		K.ruin_wall(host, a, b, h, t, color, rng, "brick", y0)
		return
	var u := (b - a).normalized()
	var d0 := clampf(door_at - 1.4, 2.0, len - 5.0)
	K.ruin_wall(host, a, a + u * d0, h, t, color, rng, "brick", y0)
	K.ruin_wall(host, a + u * (d0 + 2.8), b, h, t, color, rng, "brick", y0)
	# kapı yanı sövesi (kalan lento kırığı): geçit içinde 2,6 m altında engel yok
	var yaw := rad_to_deg(atan2(u.x, u.y))
	var m := a + u * (d0 + 1.4)
	K.vb(host, Vector3(t + 0.2, 0.25, 3.1), Vector3(m.x, y0 + 0.125, m.y), K.STONE_D, Vector3(0, yaw, 0))


static func build_buyuk_saray(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4099
	var sz := _sz(k)
	if lod >= 2:
		K.ground_box(host, sz.x, 0.3, sz.y, 0, 0, K.SOIL)
		K.ground_box(host, sz.x * 0.4, 5.0, sz.y * 0.25, -sz.x * 0.1, -sz.y * 0.2, K.BRICK.lerp(K.STONE, 0.3))
		return
	# zemin: bostan toprağı (yumuşak), üstte yürünür düz
	K.ground_box(host, sz.x, 0.1, sz.y, 0, 0, K.SOIL, "")
	# yamaç terası: arka (kuzey) kenarda iki kademeli alt yapı (kemerli destek duvarı), basamaklı çıkış
	var tw := sz.x * 0.8
	var tz := -sz.y * 0.5 + 8.0
	K.ground_box(host, tw, 2.4, 14.0, 0, tz, K.BRICK2.lerp(K.STONE_D, 0.3), "brick", 0.1)
	K.ground_box(host, tw * 0.8, 2.0, 10.0, 0, tz - 2.0, K.BRICK2.lerp(K.STONE_D, 0.4), "brick", 2.5)
	if lod == 0:
		K.arcade_face(host, Vector3(0, 0.1, tz + 7.02), Vector3(0, 0, 1), tw, 2.3, 4.0, 1.0, K.BRICK2)
		K.vb(host, Vector3(tw + 0.2, 0.2, 14.4), Vector3(0, 2.6, tz), K.STONE_D)
		K.vb(host, Vector3(tw * 0.8 + 0.2, 0.2, 10.4), Vector3(0, 4.6, tz - 2.0), K.STONE_D)
		K.scatter(host, Rect2(-tw * 0.4, tz - 7.0, tw * 0.8, 10.0), 40, rng, 4.6, "ot")
	# teras basamakları (doğal çıkış): 0,4 m × 6 + 0,4 × 6
	for s in 6:
		K.ground_box(host, 3.0, 0.4 * (s + 1) + 0.1, 1.0, tw * 0.3, tz + 8.0 + (5 - s) * 1.0, K.STONE_D, "ashlar")
	# salonlar
	_hall(host, -sz.x * 0.2, -sz.y * 0.05, 22.0, 26.0, 6.0, rng, lod, 0.1, true)
	_hall(host, sz.x * 0.25, sz.y * 0.1, 18.0, 20.0, 4.6, rng, lod, 0.1, false)
	_hall(host, -sz.x * 0.12, sz.y * 0.32, 16.0, 14.0, 3.6, rng, lod, 0.1, false)
	# bostanlaşmış avlu: sürülmüş sıralar (alçak toprak şeritleri, katı değil ama 12 cm) ve çit
	if lod == 0:
		for r in 12:
			K.vb(host, Vector3(10.0, 0.12, 0.7), Vector3(sz.x * 0.25, 0.16, -sz.y * 0.22 + r * 1.5), K.SOIL.darkened(0.15))
			for c in 5:
				if rng.randf() < 0.7:
					Props.ball(host, 0.22, Vector3(sz.x * 0.25 - 4.0 + c * 2.0, 0.34, -sz.y * 0.22 + r * 1.5), K.GRASS, Vector3(1, 0.8, 1), 6)
		K.ruin_wall(host, Vector2(sz.x * 0.1, -sz.y * 0.25), Vector2(sz.x * 0.4, -sz.y * 0.25), 1.1, 0.5, K.STONE_D, rng, "rubble", 0.1)
		K.ruin_wall(host, Vector2(sz.x * 0.4, -sz.y * 0.25), Vector2(sz.x * 0.4, 0.0), 1.1, 0.5, K.STONE_D, rng, "rubble", 0.1)
	# ayakta kalmış üç sütun (porfir/mermer) ve düşmüş başlıklar
	for i in 3:
		var cx := sz.x * 0.05 + i * 3.4
		var cz := sz.y * 0.28
		var ch := 4.0 + i * 0.9
		K.sc(host, 0.5, ch, Vector3(cx, 0.1 + ch * 0.5, cz), K.PORPHYRY.lerp(K.MARBLE, 0.3) if i == 1 else K.MARBLE.darkened(0.06), 10, 0.45, Vector3.ZERO, 1.0)
		K.vb(host, Vector3(1.3, 0.35, 1.3), Vector3(cx, 0.1 + ch + 0.17, cz), K.LIGHT)
	if lod == 0:
		K.vb(host, Vector3(1.3, 0.5, 1.3), Vector3(sz.x * 0.05 + 1.0, 0.35, sz.y * 0.28 + 3.0), K.LIGHT, Vector3(10, 30, 8))
		K.scatter(host, Rect2(-sz.x * 0.45, -sz.y * 0.45, sz.x * 0.9, sz.y * 0.9), int(sz.x * sz.y * 0.025), rng, 0.1, "ot")
		K.scatter(host, Rect2(-sz.x * 0.45, -sz.y * 0.45, sz.x * 0.9, sz.y * 0.9), int(sz.x * sz.y * 0.01), rng, 0.1, "moloz")
		# sandık yığını: sokaktan tırmanma (güney kenar)
		for i in 4:
			K.ground_box(host, 1.0, 0.4 * (i + 1), 1.2, sz.x * 0.3 + i * 1.0, sz.y * 0.45, K.WOOD, "wood")


static func perches_buyuk_saray(k: float = 0.5) -> Array:
	var sz := _sz(k)
	return [Vector3(0, 4.6 + 0.9, -sz.y * 0.5 + 6.0), Vector3(sz.x * 0.05 + 3.4, 0.1 + 4.9 + 0.5, sz.y * 0.28)]


static func climbs_buyuk_saray(k: float = 0.5) -> Array:
	var sz := _sz(k)
	var tw := sz.x * 0.8
	var tz := -sz.y * 0.5 + 8.0
	return [[Vector3(tw * 0.3, 0.1, tz + 15.0), Vector3(tw * 0.3, 2.5, tz + 7.0), "basamak"],
			[Vector3(sz.x * 0.3 - 1.2, 0, sz.y * 0.45), Vector3(sz.x * 0.3 + 3.5, 1.6, sz.y * 0.45), "sandik"]]


# ---------------------------------------------------------------------------------------------------------------
# Khalke
# ---------------------------------------------------------------------------------------------------------------
static func build_khalke(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1204
	var w := maxf(30.0 * k, 16.0)
	var d := maxf(24.0 * k, 14.0)
	var h := maxf(18.0 * k, 9.0)
	var wall := K.BRICK.lerp(K.MARBLE, 0.25)
	if lod >= 2:
		K.ground_box(host, w, h, d, 0, 0, wall)
		return
	K.ground_box(host, w + 4.0, 0.3, d + 4.0, 0, 0, K.STONE_D, "flagstone")
	# yan duvarlar (kalın), arka duvar; ön yüzde (güney) yüksek kemerli bronz kapı açıklığı (3,4 m geçit)
	for sx: float in [-1.0, 1.0]:
		K.ground_box(host, 2.0, h, d, sx * (w * 0.5 - 1.0), 0, wall, "brick", 0.3)
	K.ground_box(host, w - 4.0, h * 0.7, 1.6, 0, -d * 0.5 + 0.8, wall, "brick", 0.3)
	# ön duvar iki yanda (kapı ortada 3,6 m)
	var fw := (w - 4.0 - 3.6) * 0.5
	for sx2: float in [-1.0, 1.0]:
		K.ground_box(host, fw, h * 0.92, 1.6, sx2 * (1.8 + fw * 0.5), d * 0.5 - 0.8, wall, "brick", 0.3)
	K.ground_box(host, 3.6, h * 0.92 - 4.2, 1.6, 0, d * 0.5 - 0.8, wall, "brick", 4.5)
	# alınlık ve kemer: kapı üstü boşluk (eski ikon boşluğu), bronz çerçeve izi
	if lod == 0:
		K.vb(host, Vector3(3.6, 4.2, 0.08), Vector3(0, 2.4, d * 0.5 + 0.03), K.DARK)
		K.vb(host, Vector3(4.2, 0.3, 0.14), Vector3(0, 4.55, d * 0.5 + 0.05), K.LIGHT)
		K.vb(host, Vector3(0.3, 4.4, 0.14), Vector3(-2.1, 2.5, d * 0.5 + 0.05), K.BRONZE)
		K.vb(host, Vector3(0.3, 4.4, 0.14), Vector3(2.1, 2.5, d * 0.5 + 0.05), K.BRONZE)
		# ikon boşluğu (Hristos ikonu 8. yy'da sökülmüş): açık renk dikdörtgen
		K.vb(host, Vector3(2.0, 2.6, 0.06), Vector3(0, h * 0.7, d * 0.5 + 0.04), K.LIGHT.darkened(0.12))
		K.windows(host, Vector3(0, 0, d * 0.5), Vector3(0, 0, 1), w - 4.0, h * 0.78, 4, 0.8, 1.7)
		K.scatter(host, Rect2(-w * 0.4, -d * 0.4, w * 0.8, d * 0.8), 40, rng, 0.3, "ot")
		K.scatter(host, Rect2(-w * 0.4, -d * 0.4, w * 0.8, d * 0.8), 20, rng, 0.3, "moloz")
	# üst: yıkık tonoz izleri: yarım kubbe tabanı ve ot, düz üst katı
	K.ground_box(host, w - 0.2, 0.4, d + 0.2, 0, 0, K.STONE, "ashlar", 0.3 + h)
	K.sc(host, w * 0.3, 1.6, Vector3(0, 0.3 + h + 0.4 + 0.8, 0), K.BRICK2, 10, w * 0.27)
	# kapı önünde 5 basamak (yıkık duvar basamağı) ve yan duvar tepesine çıkış (moloz yığını)
	var steps := int(h / 0.4)
	for s in steps:
		K.ground_box(host, 0.9, 0.3 + (s + 1) * 0.4, 3.0, w * 0.5 + 0.5 + (steps - 1 - s) * 0.9, d * 0.1, K.STONE_D, "ashlar")


static func perches_khalke(k: float = 0.5) -> Array:
	var h := maxf(18.0 * k, 9.0)
	return [Vector3(0, 0.3 + h + 0.4 + 1.6 + 0.1, 0)]


static func climbs_khalke(k: float = 0.5) -> Array:
	var w := maxf(30.0 * k, 16.0)
	var d := maxf(24.0 * k, 14.0)
	var h := maxf(18.0 * k, 9.0)
	var steps := int(h / 0.4)
	return [[Vector3(w * 0.5 + 0.5 + steps * 0.9 + 0.8, 0, d * 0.1), Vector3(w * 0.5 - 0.3, 0.3 + steps * 0.4, d * 0.1), "basamak"]]


# ---------------------------------------------------------------------------------------------------------------
# Zeuksippos hamamı
# ---------------------------------------------------------------------------------------------------------------
static func build_zeuksippos(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 700
	var w := maxf(46.0 * k, 22.0)
	var d := maxf(62.0 * k, 28.0)
	var h := maxf(14.0 * k, 7.0)
	var wall := K.BRICK2.lerp(K.STONE, 0.3)
	if lod >= 2:
		K.ground_box(host, w, h, d, 0, 0, wall)
		return
	K.ground_box(host, w + 3.0, 0.25, d + 3.0, 0, 0, K.STONE_D, "flagstone")
	# ana hol (frigidarium): kalın duvarlı büyük dikdörtgen, kemerli tonoz çökmüş: yalnız kaburga kemerleri
	_hall(host, 0, -d * 0.2, w, d * 0.55, h, rng, lod, 0.25, true)
	# sıcak oda (caldarium): yuvarlak tuğla kütle, kubbesi çökmüş (kasnak yarım)
	K.sc(host, w * 0.28, h * 0.8, Vector3(0, 0.25 + h * 0.4, d * 0.25), wall, 12, w * 0.27)
	K.sc(host, w * 0.2, 0.4, Vector3(0, 0.25 + h * 0.8 + 0.2, d * 0.25), K.STONE_D, 12, w * 0.2)
	if lod == 0:
		for i in 6:
			var a := PI * 0.15 + PI * 0.7 * i / 5.0
			K.vb(host, Vector3(0.9, 1.6, 0.1), Vector3(cos(a) * w * 0.275, 0.25 + h * 0.55, d * 0.25 + sin(a) * w * 0.275), K.DARK, Vector3(0, -rad_to_deg(a) + 90.0, 0))
		# yıkık tonoz kaburgası: ayakta kalan iki kemer (iki ayak + üst kiriş)
		for sz in [-d * 0.32, -d * 0.1]:
			for sx: float in [-1.0, 1.0]:
				K.ground_box(host, 1.4, h * 0.85, 1.4, sx * (w * 0.5 - 2.0), sz, K.BRICK, "brick", 0.25)
			K.ground_box(host, w - 3.0, 1.0, 1.4, 0, sz, K.BRICK, "brick", 0.25 + h * 0.85)
		# havuz kalıntısı: çevresi alçak mermer set, içi ot-su (yürünür kapak, 0,45 m yüksek taş set)
		K.ground_box(host, 8.0, 0.45, 5.0, 0, d * 0.45, K.MARBLE.darkened(0.1), "marble")
		K.vb(host, Vector3(7.0, 0.04, 4.0), Vector3(0, 0.49, d * 0.45), Color("5a7a7a"))
		for i in 3:
			K.ground_box(host, 1.0, 0.4 * (i + 1), 1.2, w * 0.5 + 2.0 + (2 - i) * 1.0, 0, K.STONE_D, "ashlar")


static func perches_zeuksippos(k: float = 0.5) -> Array:
	var w := maxf(46.0 * k, 22.0)
	var h := maxf(14.0 * k, 7.0)
	return [Vector3(0, 0.25 + h * 0.8 + 0.4 + 0.1, maxf(62.0 * k, 28.0) * 0.25), Vector3(-(w * 0.5 - 2.0), 0.25 + h * 0.85 + 1.1, -maxf(62.0 * k, 28.0) * 0.32)]


static func climbs_zeuksippos(k: float = 0.5) -> Array:
	var w := maxf(46.0 * k, 22.0)
	return [[Vector3(w * 0.5 + 4.8, 0, 0), Vector3(w * 0.5 + 2.0, 1.2, 0), "basamak"]]


# ---------------------------------------------------------------------------------------------------------------
# Nea Ekklesia: haç-içinde-kare plan, merkezde ve köşelerde beş kubbe (kısmen çökmüş)
# ---------------------------------------------------------------------------------------------------------------
static func build_nea(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 880
	var w := maxf(30.0 * k, 14.0)
	var d := maxf(38.0 * k, 18.0)
	var h := maxf(14.0 * k, 7.0)
	var info := IstHipoAug.church(host, w, d, h, w * 0.25, lod, 0.5, 880)
	if lod >= 2:
		return
	# dört köşe kubbeciği (üçü sağlam, biri çökmüş: düz kasnak)
	var roof_top: float = info["roof_top"]
	for i in 4:
		var sx: float = -1.0 if i % 2 == 0 else 1.0
		var sz: float = -1.0 if i < 2 else 1.0
		var pos := Vector3(sx * w * 0.32, roof_top + 0.2, sz * d * 0.32)
		if i == 3:
			K.sc(host, w * 0.1, 1.2, pos + Vector3(0, 0.6, 0), K.BRICK2, 8, w * 0.09)
			K.scatter(host, Rect2(pos.x - 1.5, pos.z - 1.5, 3.0, 3.0), 12, rng, pos.y + 1.2, "moloz")
		else:
			K.lead_dome(host, w * 0.1, w * 0.07, pos, 8, w * 0.08, K.BRICK, lod == 0)
	# kuzeybatı köşesi çökmüş: moloz yığını ve ot
	if lod == 0:
		K.scatter(host, Rect2(-w * 0.5 - 3.0, d * 0.3, 6.0, 8.0), 20, rng, 0.0, "moloz")
		K.scatter(host, Rect2(-w, -d, w * 2.0, d * 2.0), 50, rng, 0.0, "ot")
		for i in 3:
			K.ground_box(host, 1.0, 0.4 * (i + 1), 1.2, w * 0.5 + 2.0 + (2 - i) * 1.0, 0, K.WOOD, "wood")


static func perches_nea(k: float = 0.5) -> Array:
	var w := maxf(30.0 * k, 14.0)
	var h := maxf(14.0 * k, 7.0)
	var rise := minf(w * 0.18, 3.0)
	var r := w * 0.25
	return [Vector3(0, h + rise + 0.2 + r * 0.5 + 0.25 + r * 0.55 + 0.1, -maxf(38.0 * k, 18.0) * 0.04)]


static func climbs_nea(k: float = 0.5) -> Array:
	var w := maxf(30.0 * k, 14.0)
	return [[Vector3(w * 0.5 + 4.8, 0, 0), Vector3(w * 0.5 + 2.0, 1.2, 0), "sandik"]]
