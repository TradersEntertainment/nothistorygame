class_name IstKbKilise
extends RefCounted
## Kuzeybati: Khora (Kariye) manastırı, Pammakaristos, Blakhernai Meryem kilisesi harabesi + ayazma, Petra manastırı.
## Model çerçevesi: eksen -z (apsis), giriş +z; model +x = apsise bakınca sağ = güney (yon=90 için).


static func catalog() -> Array:
	return [
		{"id": "khora", "ad": "Khora (Kariye) Manastırı", "dogu_m": -3444.0, "kuzey_m": 2516.0,
			"gercek_olcu": Vector3(30.0, 20.0, 30.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 28.0, 0), "bakis_r": 40.0, "gorev": true},
		{"id": "pammakaristos", "ad": "Pammakaristos (Tanrıanası) Manastırı", "dogu_m": -2831.0, "kuzey_m": 2338.0,
			"gercek_olcu": Vector3(34.0, 19.0, 30.0), "yon_derece": 95.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 27.0, 0), "bakis_r": 40.0, "gorev": true},
		{"id": "blakhernai_kilise", "ad": "Blakhernai Meryem Kilisesi (harabe) ve Ayazması", "dogu_m": -3390.0, "kuzey_m": 2900.0,
			"gercek_olcu": Vector3(30.0, 8.0, 40.0), "yon_derece": 90.0, "durum": "harap", "tur": "kilise",
			"bakis": Vector3(0, 16.0, 0), "bakis_r": 34.0, "gorev": true},
		{"id": "petra", "ad": "Petra (Aziz Yuhanna) Manastırı", "dogu_m": -3100.0, "kuzey_m": 3050.0,
			"gercek_olcu": Vector3(16.0, 13.0, 22.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 18.0, 0), "bakis_r": 26.0, "gorev": false},
	]


# ----------------------------------------------------------------------------------------------------------------
## KHORA
## Ölçüler (gerçek m): naos 11×11 (kestirim), ana kubbe çapı 7,7 (kaynak), parekklesion kubbesi 4,5 (kaynak), iç
## nartheks 4×18 ve iki kubbe 3,74 + 3,40 (kaynak), toplam altı kubbe (kaynak). Yükseklikler kestirim.

static func build_khora(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "Khora", k, lod, 90.0, 11)
	_khora(c)


static func _khora(c: IstKbCtx) -> void:
	var S := IstKbCtx.STONE
	var H_NAOS := 10.5
	# naos (Yunan haçı, kare) + dört kolu çaprazlayan beşik çatılar
	c.block(0, 0, 11, 11, H_NAOS, 0, S)
	c.gable(0, 0, 7.0, 11.0, H_NAOS, 1.4, true)
	c.gable(0, 0, 11.0, 7.0, H_NAOS, 1.4, false)
	c.dome(0, 0, H_NAOS, 3.85, 5.0, 3.6, 16, 16)
	# doğu (apsis) bölümü, iki yan kubbe
	c.block(0, -7.25, 11, 3.5, 8.6, 0, S)
	c.dome(-3.7, -7.25, 8.6, 1.7, 2.0, 1.4, 8, 8)
	c.dome(3.7, -7.25, 8.6, 1.7, 2.0, 1.4, 8, 8)
	c.apse(0, -9.0, 2.7, 7.4, 0, Color.WHITE)
	c.apse(-3.7, -9.0, 1.4, 6.2, 0, Color.WHITE)
	c.apse(3.7, -9.0, 1.4, 6.2, 0, Color.WHITE)
	# iç nartheks (4×18, iki kubbe) ve dış nartheks (basık)
	c.block(0, 7.5, 20, 4, 8.2, 0, S)
	c.dome(-7.8, 7.5, 8.2, 1.87, 1.8, 1.3, 8, 8)
	c.dome(7.8, 7.5, 8.2, 1.7, 1.8, 1.2, 8, 8)
	c.block(0, 12.0, 19.4, 5.0, 6.2, 0, S)
	c.deco(0, 6.2 + 0.01, 12.0, 19.0, 0.02, 4.6, IstKbCtx.LEAD)
	# güney: parekklesion (iki bölmeli, batı bölmesi kubbeli)
	c.block(7.9, -3.5, 4.8, 11, 9.2, 0, S)
	c.gable(7.9, -3.5, 4.8, 11.0, 9.2, 1.1, true)
	c.dome(7.9, -0.8, 9.2, 2.25, 3.2, 2.2, 8, 12)
	c.apse(7.9, -9.0, 1.9, 7.0, 0, Color.WHITE)
	# kuzey koridoru (alçak, naosa yaslı)
	c.block(-7.4, 0, 3.8, 11, 6.4, 0, S)
	c.lean(-7.4, 0, 3.8, 11.0, 6.4, 1.0, 1)
	# payandalar ve süsler (lod 0)
	for zz in [-7.5, -3.5, 0.5]:
		c.buttress(10.3, zz, 90, 0.9, 0.9, 7.5)
	c.buttress(-9.3, -1.0, 270, 0.9, 0.9, 5.0)
	c.buttress(-9.3, 3.5, 270, 0.9, 0.9, 5.0)
	# cepheler: tuğla bantları (opus mixtum) ve pencereler
	c.band(0, 12.0, 0, 2.55, 19.4, 4.6)
	c.band(0, 12.0, 0, 2.55, 19.4, 2.4)
	c.band(7.9, -3.5, 90, 2.45, 11, 5.0)
	c.band(7.9, -3.5, 90, 2.45, 11, 7.8)
	c.door_on(0, 12.0, 0, 2.5, 0.0, 6.2)
	c.door_on(0, 12.0, 0, 2.5, 6.0, 6.2)
	c.windows_on(0, 12.0, 0, 2.5, [-8.0, -4.0, 4.0, 8.0], 3.4, 0.6, 1.1)
	c.windows_on(0, 7.5, 0, 2.02, [], 5.6)
	c.windows_on(7.9, -3.5, 90, 2.45, [-4.0, -1.5, 1.5, 4.0], 5.5, 0.7, 1.9)
	c.windows_on(7.9, -3.5, 90, 2.45, [-4.0, -1.5, 1.5, 4.0], 2.0, 0.5, 0.8, false, true, true)
	c.windows_on(-7.4, 0, 270, 1.95, [-3.5, 0.0, 3.5], 3.6, 0.6, 1.0)
	c.windows_on(0, 0, 90, 5.55, [-3.0, 3.0], 6.5, 0.9, 1.9)    # naos güney kolu, parekklesion üstünden görünen
	c.windows_on(0, 0, 270, 5.55, [-3.0, 3.0], 7.0, 0.9, 1.9)
	c.windows_on(0, -9.0, 180, 2.7, [-1.6, 0.0, 1.6], 4.5, 0.5, 1.3)
	# yerden: güneş ve ağaç
	c.cypress(15.5, 5.5, 8.0)
	c.cypress(-14.0, -6.0, 9.0)
	c.olive(13.5, -9.0, 0.0, 0.9)
	# tırmanış: dış merdiven (güney uç), sandık basamakları ikişer kademe
	c.stair(9.7, 12.0, Vector2(-1, 0), 6.2 * c.k, 1.5, IstKbCtx.STONE_D, 0.5, 0.0)
	var n1 := maxi(1, int(ceil(2.0 * c.k / 0.6)))
	c.crate_steps(1.2, 9.5, Vector2(0, -1), n1, 2.0 * c.k / n1, 6.2 * c.k)
	var n2 := maxi(1, int(ceil(2.3 * c.k / 0.6)))
	c.crate_steps(-(3.5 + 0.35 / c.k + 0.4), 5.5, Vector2(0, -1), n2, 2.3 * c.k / n2, 8.2 * c.k)


# ----------------------------------------------------------------------------------------------------------------
## PAMMAKARİSTOS
## Ana kilise (Komnenos dönemi, kubbeli) + güneyde Glabas'ın parekklesionu (≈1310, beş kubbeli) + kuzey/batı dolaşma
## yolu. Ölçüler kestirim (kaynak yalnız "beş kubbe", "dar-yüksek orantı" der).

static func build_pammakaristos(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "Pammakaristos", k, lod, 95.0, 23)
	_pamma(c)


static func _pamma(c: IstKbCtx) -> void:
	var S := Color("e4d4b4")
	# ana kilise (kare naos) + kubbe
	c.block(0, 0, 12.5, 12.5, 11.0, 0, S, "ashlar")
	c.gable(0, 0, 7.5, 12.5, 11.0, 1.4, true)
	c.gable(0, 0, 12.5, 7.5, 11.0, 1.4, false)
	c.dome(0, 0, 11.0, 4.0, 5.6, 3.8, 16, 16)
	# kuzey ve batı dolaşma yolu (alçak), köşelerde küçük kubbeler
	c.block(-8.0, 0, 3.6, 12.5, 7.4, 0, S, "ashlar")
	c.lean(-8.0, 0, 3.6, 12.5, 7.4, 1.0, 1)
	c.block(0, 9.15, 12.5, 5.8, 7.8, 0, S, "ashlar")
	c.dome(-1.6, 9.15, 7.8, 1.3, 1.6, 1.1, 8, 8)
	c.dome(1.6, 9.15, 7.8, 1.3, 1.6, 1.1, 8, 8)
	# doğu: üç apsis
	c.block(0, -7.4, 12.5, 2.4, 9.0, 0, S, "ashlar")
	c.apse(0, -8.6, 3.0, 8.0, 0, Color.WHITE)
	c.apse(-4.0, -8.6, 1.6, 6.6, 0, Color.WHITE)
	c.apse(4.0, -8.6, 1.6, 6.6, 0, Color.WHITE)
	# güney: parekklesion (çapraz-kare, beş kubbe)
	c.block(9.2, -2.0, 5.8, 13.0, 10.2, 0, Color("ecdcb8"), "ashlar")
	c.gable(9.2, -2.0, 5.8, 13.0, 10.2, 1.2, true)
	c.dome(9.2, -2.0, 10.2, 2.2, 4.0, 2.4, 12, 12)
	c.dome(7.6, -6.0, 10.2, 1.0, 1.4, 1.0, 6, 6)
	c.dome(10.8, -6.0, 10.2, 1.0, 1.4, 1.0, 6, 6)
	c.dome(7.6, 3.0, 10.2, 1.1, 1.4, 1.0, 6, 6)
	c.dome(10.8, 3.0, 10.2, 1.1, 1.4, 1.0, 6, 6)
	c.apse(9.2, -8.5, 2.2, 7.6, 0, Color.WHITE)
	c.buttress(12.2, -6.0, 90, 0.9, 0.9, 8.0)
	c.buttress(12.2, -2.0, 90, 0.9, 0.9, 8.0)
	c.buttress(12.2, 2.0, 90, 0.9, 0.9, 8.0)
	# geometrik tuğla süsleme (tekfur deseni zaten yüzeyde), bantlar
	c.band(9.2, -2.0, 90, 2.95, 13.0, 4.0, 0.3)
	c.band(9.2, -2.0, 90, 2.95, 13.0, 8.2, 0.3)
	c.band(0, 9.15, 0, 2.92, 12.5, 3.6, 0.3)
	c.door_on(0, 9.15, 0, 2.9, 0.0, 7.8)
	c.windows_on(9.2, -2.0, 90, 2.95, [-5.0, -2.5, 0.0, 2.5, 5.0], 5.2, 0.7, 1.7)
	c.windows_on(9.2, -2.0, 90, 2.95, [-5.0, -2.5, 0.0, 2.5, 5.0], 2.0, 0.5, 0.8, false, true, true)
	c.windows_on(0, 9.15, 0, 2.92, [-4.0, 4.0], 4.4, 0.6, 1.2)
	c.windows_on(-8.0, 0, 270, 1.85, [-4.0, 0.0, 4.0], 3.8, 0.6, 1.1)
	c.windows_on(0, -8.6, 180, 3.0, [-1.6, 0.0, 1.6], 4.6, 0.5, 1.3)
	# bahçe: servi, zeytin
	c.cypress(-13.0, 4.0, 9.0)
	c.cypress(-12.5, -5.0, 8.0)
	c.olive(14.5, 6.0, 0.0, 1.0)
	# tırmanış: batı dolaşma yolunun çatısına dış merdiven, oradan naosa sandıklar
	c.stair(6.25, 9.15, Vector2(-1, 0), 7.8 * c.k, 1.5, IstKbCtx.STONE_D, 0.5, 0.0)
	c.crate_steps(-5.0, 6.25, Vector2(0, -1), maxi(1, int(ceil(3.2 * c.k / 0.6))), 3.2 * c.k / maxi(1, int(ceil(3.2 * c.k / 0.6))), 7.8 * c.k)


# ----------------------------------------------------------------------------------------------------------------
## BLAKHERNAİ MERYEM KİLİSESİ (1434'te yanmış) + AYAZMA
## 1434 yangınında çatısı, kubbesi ve doğu duvarı çökmüş bazilika; duvar kalıntıları ayakta, ortası moloz ve ot,
## yanında Ayazma (kutsal kaynak, kemerli taş havuz hücresi). Ölçüler kestirim.

static func build_blakhernai_kilise(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "BlakhernaiKilise", k, lod, 90.0, 41)
	var dk := Color("c9b898")
	# kuzey ve güney yan duvarlar (kısmen yıkık: farklı yükseklik), batı duvarı, apsis kalıntısı
	c.block(-7.0, 0, 1.6, 26, 7.0, 0, dk, "rubble")
	c.block(7.0, 0, 1.6, 26, 5.2, 0, dk, "rubble")
	c.block(0, 13.0, 15.6, 1.6, 6.0, 0, dk, "rubble")
	c.block(-4.0, -13.0, 7.4, 1.6, 3.2, 0, dk, "rubble")
	c.apse(0, -13.0, 4.2, 4.0, 0, Color.WHITE, false)
	# ortada nef zemini: moloz, ot, mozaik döşeme parçası (yürünür katı zemin)
	c.ground_patch(0, 0, 12.4, 25.0, Color("8a7a5a"), "flagstone", 0.25)
	c.deco(0, 0.16, 0.0, 6.0, 0.02, 10.0, Color("b0a080"), Vector3.ZERO, "marble")
	# kolon kalıntıları: iki sıra, bazıları devrik
	for i in 5:
		var z := -9.0 + i * 4.5
		c.tower(-3.6, z, 0.45, 2.8 if i % 2 == 0 else 1.2, 0.25, Color("d8d0c0"), "marble", 8)
		c.tower(3.6, z, 0.45, 3.4 if i % 2 == 1 else 0.9, 0.25, Color("d8d0c0"), "marble", 8)
	# devrik sütun gövdesi
	var fall := Props.cyl(c.root, 0.42 * 1.0, 3.2, Vector3(1.2 * k, 0.3 + 0.42, 3.0 * k), Color("d8d0c0"), Vector3(0, 30, 90), 8)
	Props.make_solid(fall)
	c.rubble(0, 4, 18, 5.0, 0.25)
	c.rubble(-5, -9, 10, 3.0, 0.0)
	c.rubble(5, 10, 8, 3.0, 0.0)
	# duvar tepesinde ot ve yabani incir
	for i in 8:
		Props.ball(c.root, 0.35, Vector3((-7.0 + c.rng.randf_range(-0.3, 0.3)) * k, 7.0 * k + 0.15, (-11.0 + i * 3.1) * k), IstKbCtx.MOSS, Vector3(1, 0.6, 1), 6)
	# ayazma: kemerli taş hücre, içinde havuz, kuzeybatı
	var ax := 13.0
	var az := 6.0
	c.block(ax, az, 5.0, 5.0, 4.2, 0, Color("d4c4a0"), "ashlar")
	c.gable(ax, az, 5.0, 5.0, 4.2, 1.1, true)
	c.fixed_block(Vector3(ax * k - 2.6 * k, 0.45, az * k), Vector3(0.1, 0.9, 1.8), Color("2a3a44"), "", false)
	c.fixed_block(Vector3(ax * k, 0.12, (az + 2.5) * k + 1.4), Vector3(3.6, 0.24, 2.2), Color("c8c0aa"), "flagstone")
	c.fixed_block(Vector3(ax * k, 0.26, (az + 2.5) * k + 1.4), Vector3(2.8, 0.04, 1.5), Color("4a7a8a"), "", false)
	c.cypress(18.0, 3.0, 8.0)
	c.cypress(-12.0, 15.0, 7.0)
	c.olive(-10.0, -5.0, 0.0, 0.9)
	# tırmanış: yıkık duvar basamakları (güney duvarı alçak) — dış basamaklar
	c.crate_steps(7.8, 0.0, Vector2(-1, 0), maxi(1, int(ceil(5.2 * c.k / 0.6))), 5.2 * c.k / maxi(1, int(ceil(5.2 * c.k / 0.6))), 0.0)


# ----------------------------------------------------------------------------------------------------------------
## PETRA (Aziz Yuhanna Prodromos) — Haliç yamacında küçük manastır; çapraz-kare, tek kubbe, avlu duvarı. Kestirim.

static func build_petra(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var c := IstKbCtx.create(host, "Petra", k, lod, 90.0, 53)
	var S := Color("e6d4ac")
	c.block(0, 0, 9.0, 9.0, 8.5, 0, S, "ashlar")
	c.gable(0, 0, 5.5, 9.0, 8.5, 1.6, true)
	c.gable(0, 0, 9.0, 5.5, 8.5, 1.6, false)
	c.dome(0, 0, 8.5, 2.6, 3.8, 2.4, 12, 12)
	c.block(0, 7.3, 9.0, 5.6, 6.0, 0, S, "ashlar")
	c.deco(0, 6.01, 7.3, 8.6, 0.02, 5.2, IstKbCtx.LEAD)
	c.apse(0, -4.5, 2.1, 6.2, 0, Color.WHITE)
	c.buttress(4.5, 0, 90, 0.8, 0.8, 6.0)
	c.buttress(-4.5, 0, 270, 0.8, 0.8, 6.0)
	c.door_on(0, 7.3, 0, 2.85, 0.0, 6.0)
	c.windows_on(0, 7.3, 0, 2.85, [-3.0, 3.0], 3.4, 0.6, 1.1)
	c.windows_on(4.5, 0, 90, 0.0, [-2.0, 2.0], 4.4, 0.6, 1.4)
	c.band(0, 7.3, 0, 2.82, 9.0, 4.2)
	# avlu duvarı ve hücre sırası
	c.block(11.0, 0, 1.0, 20, 3.4, 0, Color("cdbd9c"), "rubble")
	c.block(-11.0, 0, 1.0, 20, 3.4, 0, Color("cdbd9c"), "rubble")
	c.block(0, 10.5, 22.0, 1.0, 3.4, 0, Color("cdbd9c"), "rubble")
	c.block(0, -10.5, 22.0, 1.0, 3.4, 0, Color("cdbd9c"), "rubble")
	c.cypress(7.0, 8.0, 8.0)
	c.olive(-7.5, 7.5, 0.0, 0.9)
	c.stair(4.5, 7.3, Vector2(-1, 0), 6.0 * c.k, 1.4, IstKbCtx.STONE_D, 0.5, 0.0)
	c.crate_steps(0.0, 4.5, Vector2(0, -1), maxi(1, int(ceil(2.5 * c.k / 0.6))), 2.5 * c.k / maxi(1, int(ceil(2.5 * c.k / 0.6))), 6.0 * c.k)


# ----------------------------------------------------------------------------------------------------------------
# Ortak yardımcılar

static func _nul(k: float, yon: float) -> IstKbCtx:
	var c := IstKbCtx.new()
	c.k = k
	c.yon = yon
	return c


## Kubbe tepe fenerliğinin üst yüzü (yerel y, k'li): IstKbCtx.dome ile aynı hesap.
static func _dome_top(base: float, drum_h: float, dome_h: float, k: float) -> float:
	return (base + drum_h) * k + dome_h * k - 0.08 + 0.25 + 0.02


## Model-uzayı adımlarını (x,z gerçek m; y zaten metre) yerel koordinata çevirir: [alt, ust, tur]
static func _climbs_generic(k: float, yon: float, steps: Array) -> Array:
	var c := _nul(k, yon)
	var out: Array = []
	for e in steps:
		var a: Vector3 = e[0]
		var b: Vector3 = e[1]
		out.append([c.to_local(Vector3(a.x * k, a.y, a.z * k)), c.to_local(Vector3(b.x * k, b.y, b.z * k)), e[2]])
	return out

# Tırmanış ve konma noktaları kurucudan toplanır (IstKbCtx.harvest): kurulumla birebir tutarlı.
static func perches_khora(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("khora", build_khora, k)[1]


static func climbs_khora(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("khora", build_khora, k)[0]


static func perches_pammakaristos(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("pammakaristos", build_pammakaristos, k)[1]


static func climbs_pammakaristos(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("pammakaristos", build_pammakaristos, k)[0]


static func perches_blakhernai_kilise(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("blakhernai_kilise", build_blakhernai_kilise, k)[1]


static func climbs_blakhernai_kilise(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("blakhernai_kilise", build_blakhernai_kilise, k)[0]


static func perches_petra(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("petra", build_petra, k)[1]


static func climbs_petra(k: float = 0.5) -> Array:
	return IstKbCtx.harvest("petra", build_petra, k)[0]


