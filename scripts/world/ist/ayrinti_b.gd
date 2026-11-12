class_name AyrintiB
extends RefCounted
## Ayrıntı kitaplığı, bölüm B: hayvanlar, savunma/kuşatma, kamp ve çadırlar.
## ITEMS: [id, ad, en, yükseklik, boy, çarpışma, grup]

const L := preload("res://scripts/world/ist/ayrinti_lib.gd")

const ITEMS := [
	["kedi", "Kedi", 0.25, 0.3, 0.55, "yok", "hayvan"],
	["kopek", "Sokak köpeği", 0.3, 0.55, 0.9, "yok", "hayvan"],
	["tavuk", "Tavuk", 0.22, 0.35, 0.35, "yok", "hayvan"],
	["keci", "Keçi", 0.4, 0.8, 1.0, "yok", "hayvan"],
	["esek", "Eşek", 0.5, 1.2, 1.5, "kutu", "hayvan"],
	["at", "At", 0.6, 1.6, 2.2, "kutu", "hayvan"],
	["okuz", "Öküz", 0.8, 1.4, 2.0, "kutu", "hayvan"],
	["koyun", "Koyun", 0.5, 0.8, 1.0, "yok", "hayvan"],
	["kaz", "Kaz", 0.3, 0.55, 0.6, "yok", "hayvan"],
	["marti", "Martı (kondurulmuş)", 0.25, 0.4, 0.5, "yok", "hayvan"],
	["cop", "Çöp ve atık", 1.2, 0.4, 1.0, "yok", "yigin"],
	["su_birikintisi", "Su birikintisi", 1.6, 0.03, 1.2, "yok", "yigin"],
	["mancinik", "Mancınık", 3.0, 3.6, 7.0, "ozel", "savas"],
	["gulle_yigini", "Taş gülle yığını", 1.2, 0.8, 1.2, "kutu", "savas"],
	["ok_sandigi", "Ok sandığı", 1.0, 0.6, 0.45, "kutu", "savas"],
	["kalkan_askisi", "Kalkan askısı", 1.6, 1.8, 0.3, "ozel", "savas"],
	["mizraklik", "Mızraklık", 1.0, 2.4, 0.5, "ozel", "savas"],
	["nobetci_kulubesi", "Nöbetçi kulübesi", 2.4, 2.6, 2.4, "ozel", "savas"],
	["barikat", "Barikat", 3.4, 1.7, 1.0, "kutu", "savas"],
	["fici_toprak", "Fıçı-toprak tahkimat", 3.0, 1.5, 1.2, "kutu", "savas"],
	["top", "Top (dövme demir)", 1.4, 1.2, 3.4, "kutu", "savas"],
	["balista", "Balista", 1.2, 1.4, 2.0, "kutu", "savas"],
	["kazan_yag", "Kaynar yağ kazanı", 1.2, 1.3, 1.2, "kutu", "savas"],
	["okcu_siperi", "Hasır siper (mantlet)", 1.4, 1.8, 0.4, "kutu", "savas"],
	["kusatma_merdiveni", "Dayalı kuşatma merdiveni", 0.9, 5.0, 1.6, "ozel", "savas"],
	["sancak_diregi", "Sancak direği", 0.6, 4.0, 0.2, "ozel", "savas"],
	["hendek_kazigi", "Hendek kazıkları", 3.0, 1.2, 1.6, "yok", "savas"],
	["gabyon", "Toprak dolu sepet (gabyon)", 0.6, 0.9, 0.6, "kutu", "savas"],
	["ordu_cadiri", "Osmanlı ordu çadırı", 4.6, 3.2, 4.6, "ozel", "kamp"],
	["multeci_cadiri", "Mülteci çadırı", 3.0, 1.7, 2.6, "ozel", "kamp"],
	["yer_yatagi", "Yer yatağı", 0.8, 0.2, 1.9, "yok", "kamp"],
	["kamp_atesi", "Kamp ateşi", 1.2, 1.1, 1.2, "yok", "kamp"],
	["kazan", "Kazan ve üç ayak", 1.2, 1.4, 1.2, "ozel", "kamp"],
	["mangal", "Mangal", 0.6, 0.9, 0.6, "kutu", "kamp"],
	["mesale_diregi", "Meşale direği", 0.3, 2.4, 0.3, "ozel", "kamp"],
	["saman_balyasi", "Saman balyası", 1.0, 0.5, 0.6, "kutu", "ciftlik"],
	["saman_yigini", "Saman yığını", 2.6, 2.2, 2.6, "kutu", "ciftlik"],
	["ot_demeti", "Ot demeti", 0.6, 0.7, 0.5, "yok", "ciftlik"],
	["yun_balyasi", "Yün balyası", 0.9, 0.8, 0.6, "kutu", "zanaat"],
]

# ---- hayvanlar: durağan, düşük poligon; baş -z yönüne bakar ------------------------------------------------------

static func build_kedi(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.15, 0.05), L.FUR_T, Vector3(0.2, 0.22, 0.4), 7)
	L.s(h, 0.5, Vector3(0, 0.26, -0.2), L.FUR_T, Vector3(0.18, 0.17, 0.17), 7)
	for sx in [-1, 1]:
		L.pr(h, Vector3(0.05, 0.07, 0.03), Vector3(sx * 0.05, 0.37, -0.2), L.FUR_T.darkened(0.15))
	L.b(h, Vector3(0.04, 0.04, 0.3), Vector3(0.0, 0.1, 0.35), L.FUR_T.darkened(0.2), Vector3(-20, 0, 0))
	L.b(h, Vector3(0.14, 0.05, 0.03), Vector3(0, 0.28, -0.32), L.FUR_W)


static func build_kopek(h: Node3D) -> void:
	L.quad(h, 0.8, 0.28, 0.25, L.FUR_T.darkened(0.1), L.FUR_T, 0.12, true, 0.05)
	L.b(h, Vector3(0.1, 0.09, 0.16), Vector3(0, 0.5, -0.78), L.FUR_K)


static func build_tavuk(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.2, 0), L.FUR_W, Vector3(0.22, 0.24, 0.32), 7)
	L.s(h, 0.5, Vector3(0, 0.35, -0.15), L.FUR_W, Vector3(0.11, 0.14, 0.11), 6)
	L.b(h, Vector3(0.025, 0.05, 0.03), Vector3(0, 0.37, -0.22), L.OCHRE)
	L.b(h, Vector3(0.03, 0.06, 0.1), Vector3(0, 0.42, -0.14), L.RED)
	L.b(h, Vector3(0.1, 0.18, 0.04), Vector3(0, 0.28, 0.17), L.FUR_G, Vector3(-30, 0, 0))
	for sx in [-0.05, 0.05]:
		L.b(h, Vector3(0.02, 0.1, 0.02), Vector3(sx, 0.05, 0), L.OCHRE)


static func build_keci(h: Node3D) -> void:
	L.quad(h, 0.8, 0.38, 0.38, L.FUR_W.darkened(0.12), L.FUR_W.darkened(0.05), 0.0, true, 0.1)
	for sx in [-1, 1]:
		L.b(h, Vector3(0.04, 0.22, 0.04), Vector3(sx * 0.07, 0.95, -0.46), L.FUR_G, Vector3(-20, 0, sx * -12))
	L.b(h, Vector3(0.05, 0.12, 0.05), Vector3(0, 0.55, -0.62), L.FUR_W)


static func build_esek(h: Node3D) -> void:
	L.quad(h, 1.2, 0.5, 0.58, L.FUR_G, L.FUR_G.lightened(0.1), 0.28, true, 0.15)
	L.b(h, Vector3(0.45, 0.08, 0.85), Vector3(0, 1.1, 0.0), L.RED)
	L.b(h, Vector3(0.1, 0.12, 0.2), Vector3(0, 1.0, -0.78), L.FUR_W)


static func build_at(h: Node3D) -> void:
	L.quad(h, 1.6, 0.7, 0.8, L.FUR_B, L.FUR_B.darkened(0.1), 0.18, true, 0.3)
	L.b(h, Vector3(0.14, 0.45, 0.28), Vector3(0, 1.55, -0.92), L.FUR_B.darkened(0.25), Vector3(-25, 0, 0))
	L.b(h, Vector3(0.52, 0.06, 0.6), Vector3(0, 1.35, 0.05), L.RED)


static func build_okuz(h: Node3D) -> void:
	L.quad(h, 1.6, 0.8, 0.5, L.FUR_B.lightened(0.05), L.FUR_B, 0.0, true, 0.0)
	for sx in [-1, 1]:
		L.b(h, Vector3(0.08, 0.08, 0.3), Vector3(sx * 0.25, 1.2, -0.95), L.FUR_W, Vector3(0, 0, sx * -22))
	L.b(h, Vector3(0.9, 0.12, 0.12), Vector3(0, 1.4, -0.55), L.WOOD_D)


static func build_koyun(h: Node3D) -> void:
	L.quad(h, 0.8, 0.5, 0.28, L.FUR_W, L.FUR_K, 0.1, false, 0.0)
	L.s(h, 0.4, Vector3(0, 0.6, 0.05), L.FUR_W.lightened(0.05), Vector3(1.3, 1.0, 1.9), 7)


static func build_kaz(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.25, 0.05), L.FUR_W, Vector3(0.25, 0.28, 0.45), 7)
	L.b(h, Vector3(0.07, 0.3, 0.07), Vector3(0, 0.42, -0.2), L.FUR_W, Vector3(15, 0, 0))
	L.s(h, 0.5, Vector3(0, 0.56, -0.24), L.FUR_W, Vector3(0.09, 0.09, 0.12), 6)
	L.b(h, Vector3(0.05, 0.04, 0.1), Vector3(0, 0.55, -0.34), L.OCHRE)
	for sx in [-0.06, 0.06]:
		L.b(h, Vector3(0.025, 0.1, 0.025), Vector3(sx, 0.05, 0.05), L.OCHRE)


static func build_marti(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.2, 0), L.FUR_W, Vector3(0.18, 0.18, 0.4), 7)
	L.s(h, 0.5, Vector3(0, 0.3, -0.18), L.FUR_W, Vector3(0.12, 0.12, 0.12), 6)
	L.b(h, Vector3(0.025, 0.025, 0.08), Vector3(0, 0.29, -0.28), L.OCHRE)
	L.b(h, Vector3(0.22, 0.04, 0.28), Vector3(0, 0.26, 0.05), L.FUR_G)
	L.b(h, Vector3(0.1, 0.05, 0.14), Vector3(0, 0.2, 0.28), L.FUR_G.darkened(0.2), Vector3(10, 0, 0))
	for sx in [-0.04, 0.04]:
		L.b(h, Vector3(0.015, 0.1, 0.015), Vector3(sx, 0.05, 0), L.OCHRE)


static func build_cop(h: Node3D) -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 21
	var cs := [L.SACK, L.TERRA_D, L.WOOD_D, L.STONE, L.GREEN_D, L.CREAM]
	for i in 12:
		var sz := Vector3(0.12 + rnd.randf() * 0.25, 0.04 + rnd.randf() * 0.1, 0.1 + rnd.randf() * 0.25)
		L.b(h, sz, Vector3(rnd.randf_range(-0.55, 0.55), sz.y * 0.5, rnd.randf_range(-0.45, 0.45)), cs[i % 6], Vector3(0, rnd.randf() * 180, 0))
	L.s(h, 0.18, Vector3(0.1, 0.12, 0.0), L.SACK.darkened(0.2), Vector3(1.4, 0.7, 1.1), 6)


static func build_su_birikintisi(h: Node3D) -> void:
	L.cb(h, 0.7, 0.03, 0, 0, 0, L.WATER.darkened(0.15), 10)
	L.cb(h, 0.35, 0.036, 0.35, 0, 0.18, L.WATER, 8)
	L.cb(h, 0.22, 0.036, -0.4, 0, -0.2, L.WATER, 7)


# ---- savunma ve kuşatma ----------------------------------------------------------------------------------------

static func build_mancinik(h: Node3D) -> void:
	# karşı ağırlıklı mancınık: iki yan ayak (A çerçeve), eksen, uzun kol, sapan, ağırlık sandığı
	for sx in [-1.25, 1.25]:
		L.rod(h, Vector3(sx, 0, -1.3), Vector3(sx, 3.2, 0), 0.22, L.WOOD)
		L.rod(h, Vector3(sx, 0, 1.3), Vector3(sx, 3.2, 0), 0.22, L.WOOD)
		L.col_box(h, Vector3(0.4, 0.5, 2.8), Vector3(sx, 0.25, 0))
	L.b(h, Vector3(2.9, 0.22, 0.22), Vector3(0, 3.2, 0), L.WOOD_D)
	for z in [-1.3, 1.3]:
		L.b(h, Vector3(2.9, 0.2, 0.2), Vector3(0, 0.1, z), L.WOOD_D)
	# kol: uzun taraf -z, kısa taraf +z (yarı kalkık)
	L.rod(h, Vector3(0, 3.2, 0.7), Vector3(0, 1.1, -3.4), 0.2, L.WOOD_L)
	L.rod(h, Vector3(0, 3.2, 0.0), Vector3(0, 3.5, 1.1), 0.18, L.WOOD_L)
	L.b(h, Vector3(1.3, 1.2, 0.9), Vector3(0, 3.0, 1.55), L.WOOD_D, Vector3.ZERO, "wood")
	for i in 4:
		L.b(h, Vector3(0.28, 0.28, 0.28), Vector3(-0.45 + i * 0.3, 3.0, 1.55), L.STONE)
	L.b(h, Vector3(0.012, 0.012, 1.0), Vector3(0, 1.0, -3.8), L.ROPE)
	L.b(h, Vector3(0.5, 0.05, 0.4), Vector3(0, 1.05, -3.6), L.ROPE)
	L.s(h, 0.2, Vector3(0, 1.28, -3.6), L.STONE, Vector3.ONE, 6)
	L.b(h, Vector3(0.1, 1.1, 0.1), Vector3(0, 0.55, -3.0), L.WOOD_D)
	L.sol(h, Vector3(0.6, 0.5, 0.6), Vector3(0, 0.25, 3.0), L.WOOD, Vector3.ZERO, "wood")
	L.sol(h, Vector3(0.6, 0.5, 0.6), Vector3(0, 0.25, 3.7), L.WOOD, Vector3.ZERO, "wood")


static func build_gulle_yigini(h: Node3D) -> void:
	var pos := [Vector3(-0.35, 0.2, 0.35), Vector3(0.0, 0.2, 0.35), Vector3(0.35, 0.2, 0.35), Vector3(-0.35, 0.2, -0.0), Vector3(0.0, 0.2, 0.0), Vector3(0.35, 0.2, 0.0),
			Vector3(-0.17, 0.52, 0.17), Vector3(0.17, 0.52, 0.17), Vector3(0.0, 0.55, -0.1), Vector3(-0.2, 0.2, -0.35), Vector3(0.2, 0.2, -0.35), Vector3(0.0, 0.2, -0.35)]
	for i in pos.size():
		L.s(h, 0.18, pos[i], L.STONE if i % 2 == 0 else L.STONE_D, Vector3.ONE, 5)
	L.s(h, 0.16, Vector3(0.0, 0.8, 0.08), L.STONE_L, Vector3.ONE, 7)


static func build_ok_sandigi(h: Node3D) -> void:
	L.sol(h, Vector3(1.0, 0.45, 0.45), Vector3(0, 0.23, 0), L.PLANK, Vector3.ZERO, "wood")
	L.b(h, Vector3(1.04, 0.05, 0.5), Vector3(0, 0.47, 0), L.WOOD_D)
	for sx in [-0.4, 0.4]:
		L.b(h, Vector3(0.05, 0.47, 0.5), Vector3(sx, 0.24, 0), L.IRON)
	for i in 7:
		L.b(h, Vector3(0.015, 0.14, 0.015), Vector3(-0.3 + i * 0.1, 0.56, (i % 3 - 1) * 0.08), L.WOOD_L)
		L.b(h, Vector3(0.03, 0.04, 0.03), Vector3(-0.3 + i * 0.1, 0.64, (i % 3 - 1) * 0.08), L.RED)


static func build_kalkan_askisi(h: Node3D) -> void:
	for sx in [-0.75, 0.75]:
		L.cb(h, 0.05, 1.8, sx, 0, 0, L.WOOD_D, 6)
		L.col_box(h, Vector3(0.12, 1.8, 0.12), Vector3(sx, 0.9, 0))
	L.b(h, Vector3(1.6, 0.07, 0.07), Vector3(0, 1.7, 0), L.WOOD)
	L.b(h, Vector3(1.6, 0.07, 0.07), Vector3(0, 0.6, 0), L.WOOD)
	var cs := [L.RED, L.BLUE, L.OCHRE, L.GREEN]
	for i in 4:
		var x := -0.55 + i * 0.37
		L.c(h, 0.24, 0.06, Vector3(x, 1.15, 0.06), cs[i], Vector3(90, 0, 0), 10)
		L.c(h, 0.07, 0.08, Vector3(x, 1.15, 0.1), L.IRON_L, Vector3(90, 0, 0), 6)
		L.c(h, 0.24, 0.02, Vector3(x, 1.15, 0.03), L.WOOD_D, Vector3(90, 0, 0), 10)


static func build_mizraklik(h: Node3D) -> void:
	L.sol(h, Vector3(1.0, 0.12, 0.5), Vector3(0, 0.06, 0), L.WOOD_D, Vector3.ZERO, "wood")
	L.sol(h, Vector3(1.0, 0.7, 0.06), Vector3(0, 0.45, -0.22), L.WOOD, Vector3.ZERO, "wood")
	for i in 5:
		var x := -0.4 + i * 0.2
		L.rod(h, Vector3(x, 0.1, 0.1 - (i % 2) * 0.12), Vector3(x + 0.04, 2.1, -0.04), 0.035, L.WOOD_L)
		L.b(h, Vector3(0.05, 0.22, 0.02), Vector3(x + 0.04, 2.2, -0.04), L.IRON_L)
	L.b(h, Vector3(1.0, 0.05, 0.05), Vector3(0, 1.1, -0.2), L.WOOD_D)


static func build_nobetci_kulubesi(h: Node3D) -> void:
	for sx in [-0.9, 0.9]:
		for sz in [-0.9, 0.9]:
			L.sol(h, Vector3(0.12, 2.0, 0.12), Vector3(sx, 1.0, sz), L.WOOD_D)
	L.sol(h, Vector3(1.8, 0.1, 0.1), Vector3(0, 1.0, -0.9), L.WOOD)
	L.sol(h, Vector3(1.9, 1.0, 0.06), Vector3(0, 1.5, -0.94), L.PLANK, Vector3.ZERO, "wood")
	L.sol(h, Vector3(0.06, 1.0, 1.9), Vector3(-0.94, 1.5, 0), L.PLANK, Vector3.ZERO, "wood")
	L.sol(h, Vector3(0.06, 1.0, 1.9), Vector3(0.94, 1.5, 0), L.PLANK, Vector3.ZERO, "wood")
	L.pr(h, Vector3(2.4, 0.6, 2.4), Vector3(0, 2.3, 0), L.TERRA_D)
	L.col_box(h, Vector3(2.2, 0.1, 2.2), Vector3(0, 2.06, 0))
	L.sol(h, Vector3(1.9, 0.1, 1.9), Vector3(0, 0.05, 0), L.WOOD_D)
	L.b(h, Vector3(0.4, 0.25, 0.4), Vector3(0.0, 0.2, 0.3), L.WOOD_L)


static func build_barikat(h: Node3D) -> void:
	for i in 4:
		L.b(h, Vector3(1.0, 1.0, 1.0), Vector3(-1.2 + i * 0.85, 0.5, 0.0), L.WOOD if i % 2 == 0 else L.WOOD_L, Vector3(0, i * 9, 0), "wood")
	L.b(h, Vector3(3.2, 0.5, 0.9), Vector3(0, 1.25, 0.0), L.WOOD_D, Vector3(0, 3, 0), "wood")
	for i in 7:
		L.rod(h, Vector3(-1.5 + i * 0.5, 0.2, 0.45), Vector3(-1.3 + i * 0.5, 1.75, 0.5), 0.07, L.WOOD_L)
	L.s(h, 0.3, Vector3(-1.2, 1.6, -0.2), L.SACK, Vector3(1.2, 0.8, 1.0), 6)
	L.s(h, 0.3, Vector3(0.9, 1.55, -0.25), L.SACK, Vector3(1.2, 0.9, 1.0), 6)


static func build_fici_toprak(h: Node3D) -> void:
	for i in 4:
		L.cb(h, 0.3, 0.9, -0.9 + i * 0.6, 0, 0.0, L.WOOD if i % 2 == 0 else L.WOOD_L, 9, 0.28, "wood")
		L.cb(h, 0.31, 0.05, -0.9 + i * 0.6, 0.35, 0.0, L.IRON, 9)
		L.cb(h, 0.26, 0.04, -0.9 + i * 0.6, 0.9, 0.0, L.SOIL, 9)
	L.b(h, Vector3(3.0, 0.5, 1.0), Vector3(0, 1.15, 0.0), L.SOIL, Vector3.ZERO, "rubble")
	L.s(h, 0.5, Vector3(0, 1.3, 0.0), L.SOIL.lightened(0.05), Vector3(3.0, 0.6, 1.1), 8)


static func build_top(h: Node3D) -> void:
	# kuşatma topu: ahşap kızakta uzun dövme demir namlu (Urban tipi), yanında gülle
	L.sol(h, Vector3(1.4, 0.35, 3.3), Vector3(0, 0.175, 0.0), L.WOOD_D, Vector3.ZERO, "wood")
	L.c(h, 0.35, 3.0, Vector3(0, 0.95, 0), L.IRON, Vector3(90, 0, 0), 12, 0.28)
	for z in [-1.2, -0.4, 0.4, 1.2]:
		L.c(h, 0.37, 0.07, Vector3(0, 0.95, z), L.IRON_L, Vector3(90, 0, 0), 12)
	L.c(h, 0.2, 0.2, Vector3(0, 0.95, -1.55), L.BLACK, Vector3(90, 0, 0), 10)
	L.b(h, Vector3(0.14, 0.14, 0.3), Vector3(0, 1.36, 1.2), L.IRON)
	for sx in [-0.55, 0.55]:
		L.b(h, Vector3(0.15, 0.5, 2.0), Vector3(sx * 0.78, 0.6, 0), L.WOOD, Vector3.ZERO, "wood")


static func build_balista(h: Node3D) -> void:
	L.cb(h, 0.1, 1.0, 0, 0, 0.1, L.WOOD_D, 6)
	L.b(h, Vector3(0.9, 0.12, 0.12), Vector3(0, 1.0, -0.0), L.WOOD)
	L.b(h, Vector3(0.12, 0.14, 1.6), Vector3(0, 1.1, -0.2), L.WOOD_L)
	for sx in [-1, 1]:
		L.rod(h, Vector3(sx * 0.06, 1.2, -0.8), Vector3(sx * 0.7, 1.15, -0.55), 0.06, L.WOOD_D)
		L.rod(h, Vector3(sx * 0.7, 1.15, -0.55), Vector3(sx * 0.1, 1.15, 0.3), 0.012, L.ROPE)
	L.b(h, Vector3(0.04, 0.04, 1.2), Vector3(0, 1.2, -0.4), L.WOOD_L)
	L.b(h, Vector3(0.06, 0.08, 0.18), Vector3(0, 1.2, -1.0), L.IRON_L)
	for sx in [-0.5, 0.5]:
		L.b(h, Vector3(0.1, 0.35, 0.1), Vector3(sx, 0.17, 0.5), L.WOOD_D, Vector3(15, 0, 0))
		L.b(h, Vector3(0.1, 0.35, 0.1), Vector3(sx, 0.17, -0.5), L.WOOD_D, Vector3(-15, 0, 0))


static func build_kazan_yag(h: Node3D) -> void:
	for a in 3:
		var an := a * TAU / 3.0 + 0.5
		L.rod(h, Vector3(cos(an) * 0.55, 0, sin(an) * 0.55), Vector3(cos(an) * 0.12, 0.8, sin(an) * 0.12), 0.07, L.IRON)
	L.s(h, 0.5, Vector3(0, 0.95, 0), L.IRON, Vector3(1.0, 0.7, 1.0) * 1.0, 10)
	L.c(h, 0.5, 0.05, Vector3(0, 1.22, 0), L.IRON_L, Vector3.ZERO, 12)
	L.cb(h, 0.42, 0.02, 0, 1.2, 0, Color("6a5522"), 12)
	for a in 3:
		var an := a * TAU / 3.0 + 0.5
		L.s(h, 0.18, Vector3(cos(an) * 0.28, 0.12, sin(an) * 0.28), Color("ff9a2a"), Vector3(1, 0.7, 1), 5)
	L.b(h, Vector3(0.9, 0.05, 0.05), Vector3(0, 1.3, 0.0), L.IRON, Vector3.ZERO)


static func build_okcu_siperi(h: Node3D) -> void:
	for sx in [-0.55, 0.55]:
		L.sol(h, Vector3(0.1, 1.8, 0.1), Vector3(sx, 0.9, 0.08), L.WOOD_D)
	L.sol(h, Vector3(1.4, 1.7, 0.12), Vector3(0, 0.85, 0), L.STRAW, Vector3.ZERO, "wood")
	for i in 6:
		L.b(h, Vector3(0.04, 1.7, 0.15), Vector3(-0.6 + i * 0.24, 0.85, 0), L.STRAW.darkened(0.25))
	for y in [0.3, 0.8, 1.3]:
		L.b(h, Vector3(1.45, 0.05, 0.17), Vector3(0, y, 0), L.HAY.darkened(0.2))


static func build_kusatma_merdiveni(h: Node3D) -> void:
	var top := Vector3(0, 5.0, -0.5)
	var bot := Vector3(0, 0, 1.4)
	for sx in [-0.4, 0.4]:
		L.rod(h, bot + Vector3(sx, 0, 0), top + Vector3(sx, 0, 0), 0.1, L.WOOD)
	for i in 14:
		L.b(h, Vector3(0.8, 0.07, 0.07), bot.lerp(top, (i + 0.5) / 14.0), L.WOOD_L)
	L.b(h, Vector3(0.9, 0.07, 0.07), top + Vector3(0, 0.05, 0), L.WOOD_D)
	L.b(h, Vector3(0.06, 0.4, 0.08), bot + Vector3(-0.4, 0.2, 0.05), L.IRON)
	L.b(h, Vector3(0.06, 0.4, 0.08), bot + Vector3(0.4, 0.2, 0.05), L.IRON)


static func build_sancak_diregi(h: Node3D) -> void:
	L.cb(h, 0.05, 3.8, 0, 0, 0, L.WOOD_D, 6, 0.035)
	L.col_box(h, Vector3(0.12, 3.8, 0.12), Vector3(0, 1.9, 0))
	L.s(h, 0.07, Vector3(0, 3.92, 0), L.GOLD, Vector3.ONE, 6)
	L.b(h, Vector3(0.025, 0.2, 0.025), Vector3(0, 4.05, 0), L.GOLD)
	L.b(h, Vector3(0.02, 0.7, 1.1), Vector3(0, 3.3, 0.6), L.RED)
	L.b(h, Vector3(0.025, 0.2, 0.2), Vector3(0, 3.3, 0.5), L.CREAM)
	L.cb(h, 0.35, 0.12, 0, 0, 0, L.STONE_D, 8, 0.28)


static func build_hendek_kazigi(h: Node3D) -> void:
	for i in 9:
		var x := -1.3 + (i % 3) * 1.3
		var z := -0.55 + (i / 3) * 0.55
		L.cb(h, 0.06, 1.1 + (i % 2) * 0.1, x + (i % 2) * 0.1, 0, z, L.WOOD, 5, 0.01)
	L.b(h, Vector3(3.0, 0.2, 0.2), Vector3(0, 0.1, 0.9), L.SOIL)


static func build_gabyon(h: Node3D) -> void:
	L.cb(h, 0.3, 0.9, 0, 0, 0, L.STRAW, 10, 0.3, "wood")
	for y in [0.15, 0.4, 0.65, 0.88]:
		L.cb(h, 0.31, 0.03, 0, y - 0.015, 0, L.STRAW.darkened(0.3), 10)
	L.cb(h, 0.27, 0.02, 0, 0.89, 0, L.SOIL, 10)


# ---- kamp ve çadırlar ------------------------------------------------------------------------------------------

static func build_ordu_cadiri(h: Node3D) -> void:
	# yuvarlak gövde + koni çatı (Osmanlı otağ), kırmızı-krem şeritli, tepede alem
	var tent := L.LINEN
	L.cb(h, 2.3, 1.5, 0, 0, 0, tent, 12, 2.3)
	L.cb(h, 2.31, 0.3, 0, 1.0, 0, L.RED, 12, 2.31)
	L.cb(h, 2.5, 0.12, 0, 0.0, 0, L.RED.darkened(0.3), 12)
	L.c(h, 2.35, 1.5, Vector3(0, 2.25, 0), L.LINEN, Vector3.ZERO, 12, 0.08)
	for i in 6:
		var a := i * TAU / 6.0
	L.cb(h, 0.07, 0.4, 0, 3.0, 0, L.GOLD, 6)
	L.s(h, 0.12, Vector3(0, 3.4, 0), L.GOLD, Vector3.ONE, 6)
	L.cb(h, 0.12, 0.1, 0, 2.95, 0, L.GOLD, 6)
	# giriş: kapı boşluğu (yüksek 2,0 m), perde
	L.b(h, Vector3(0.45, 1.9, 0.05), Vector3(-0.55, 1.0, 2.3), L.RED.darkened(0.2), Vector3(0, 40, 0))
	L.b(h, Vector3(0.45, 1.9, 0.05), Vector3(0.55, 1.0, 2.3), L.RED.darkened(0.2), Vector3(0, -40, 0))
	L.cb(h, 0.04, 2.3, -2.0, 0, 2.6, L.WOOD_D, 5)
	L.cb(h, 0.04, 2.3, 2.0, 0, 2.6, L.WOOD_D, 5)


static func build_multeci_cadiri(h: Node3D) -> void:
	# yamuk eğik örtü: iki dikme + bir mahya direği, üstüne atılmış yamalı bez
	for sz in [-1.1, 1.1]:
		L.cb(h, 0.05, 1.7, 0, 0, sz, L.WOOD_D, 6)
		L.col_box(h, Vector3(0.12, 1.7, 0.12), Vector3(0, 0.85, sz))
	L.b(h, Vector3(0.07, 0.07, 2.4), Vector3(0, 1.7, 0), L.WOOD)
	L.b(h, Vector3(1.8, 0.04, 2.5), Vector3(-0.8, 0.85, 0), L.SACK.darkened(0.15), Vector3(0, 0, -55))
	L.b(h, Vector3(1.8, 0.04, 2.5), Vector3(0.8, 0.85, 0), L.LINEN.darkened(0.2), Vector3(0, 0, 55))
	L.b(h, Vector3(0.5, 0.04, 0.5), Vector3(-0.85, 0.9, 0.3), L.BLUE.darkened(0.2), Vector3(0, 0, -55))
	L.b(h, Vector3(0.4, 0.04, 0.4), Vector3(0.85, 0.9, -0.4), L.RED.darkened(0.2), Vector3(0, 0, 55))
	for sx in [-1, 1]:
		L.cb(h, 0.07, 0.07, sx * 1.55, 0, 1.0, L.STONE_D, 5)
		L.cb(h, 0.07, 0.07, sx * 1.55, 0, -1.0, L.STONE_D, 5)
	L.b(h, Vector3(0.7, 0.12, 1.4), Vector3(0.0, 0.07, 0), L.HAY)


static func build_yer_yatagi(h: Node3D) -> void:
	L.b(h, Vector3(0.8, 0.05, 1.9), Vector3(0, 0.03, 0), L.HAY.darkened(0.15))
	L.b(h, Vector3(0.7, 0.08, 1.5), Vector3(0, 0.08, 0.1), L.RED.darkened(0.15), Vector3(0, 3, 0))
	L.b(h, Vector3(0.5, 0.1, 0.3), Vector3(0, 0.13, -0.7), L.LINEN)
	L.b(h, Vector3(0.7, 0.05, 0.6), Vector3(0.0, 0.14, 0.45), L.SACK.darkened(0.1), Vector3(0, -8, 0))


static func build_kamp_atesi(h: Node3D) -> void:
	for i in 6:
		var a := i * TAU / 6.0
		L.s(h, 0.5, Vector3(cos(a) * 0.5, 0.1, sin(a) * 0.5), L.STONE_D, Vector3(0.28, 0.2, 0.3), 5)
	for i in 4:
		var a := i * PI / 2.0 + 0.4
		L.b(h, Vector3(0.1, 0.1, 0.85), Vector3(0, 0.2 + (i % 2) * 0.09, 0), L.WOOD_D, Vector3(0, rad_to_deg(a), 8))
	L.cb(h, 0.45, 0.04, 0, 0, 0, Color("2b2623"), 9)
	if L.lod == 0:
		Flame.add(h, Vector3(0, 0.22, 0), 0.7, 1.0)


static func build_kazan(h: Node3D) -> void:
	for a in 3:
		var an := a * TAU / 3.0
		L.rod(h, Vector3(cos(an) * 0.6, 0, sin(an) * 0.6), Vector3(0, 1.4, 0), 0.06, L.WOOD_D)
		L.col_box(h, Vector3(0.14, 0.3, 0.14), Vector3(cos(an) * 0.6, 0.15, sin(an) * 0.6))
	L.b(h, Vector3(0.012, 0.35, 0.012), Vector3(0, 1.2, 0), L.IRON)
	L.s(h, 0.5, Vector3(0, 0.78, 0), L.IRON, Vector3(0.85, 0.6, 0.85), 9)
	L.cb(h, 0.4, 0.03, 0, 1.06, 0, Color("6a4a2a"), 10)
	L.c(h, 0.42, 0.04, Vector3(0, 1.08, 0), L.IRON_L, Vector3.ZERO, 10)
	for i in 4:
		var a := i * PI / 2.0
		L.b(h, Vector3(0.05, 0.05, 0.5), Vector3(cos(a) * 0.15, 0.15, sin(a) * 0.15), L.WOOD_D, Vector3(0, rad_to_deg(a), 0))
	L.cb(h, 0.3, 0.04, 0, 0, 0, Color("2b2623"), 8)


static func build_mangal(h: Node3D) -> void:
	for sx in [-0.22, 0.22]:
		for sz in [-0.22, 0.22]:
			L.cb(h, 0.03, 0.7, sx, 0, sz, L.IRON, 5)
	L.c(h, 0.3, 0.2, Vector3(0, 0.78, 0), L.IRON, Vector3.ZERO, 10, 0.34)
	L.cb(h, 0.27, 0.02, 0, 0.86, 0, Color("a8341a"), 10)
	L.cb(h, 0.1, 0.1, 0.14, 0.88, 0.0, Color("1a1512"), 6)
	for i in 3:
		L.s(h, 0.04, Vector3(-0.1 + i * 0.1, 0.89, 0.1), Color("e8571c"), Vector3.ONE, 4)


static func build_mesale_diregi(h: Node3D) -> void:
	L.cb(h, 0.04, 2.1, 0, 0, 0, L.WOOD_D, 6)
	L.col_box(h, Vector3(0.1, 2.1, 0.1), Vector3(0, 1.05, 0))
	L.cb(h, 0.06, 0.2, 0, 2.05, 0, L.IRON, 6, 0.09)
	L.cb(h, 0.12, 0.05, 0, 0.0, 0, L.STONE_D, 7)
	if L.lod == 0:
		Flame.add(h, Vector3(0, 2.25, 0), 0.3, 0.5)


static func build_saman_balyasi(h: Node3D) -> void:
	L.b(h, Vector3(1.0, 0.5, 0.6), Vector3(0, 0.25, 0), L.HAY, Vector3.ZERO)
	for x in [-0.28, 0.28]:
		L.b(h, Vector3(0.04, 0.52, 0.64), Vector3(x, 0.25, 0), L.ROPE)
	L.b(h, Vector3(1.04, 0.04, 0.5), Vector3(0, 0.51, 0), L.STRAW.lightened(0.08))
	L.b(h, Vector3(0.3, 0.03, 0.04), Vector3(0.1, 0.53, 0.2), L.HAY.lightened(0.1), Vector3(0, 30, 0))


static func build_saman_yigini(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.7, 0), L.HAY, Vector3(2.6, 1.8, 2.6), 10)
	L.cb(h, 0.04, 2.6, 0, 0, 0, L.WOOD_D, 5)
	L.s(h, 0.5, Vector3(0.7, 0.25, 0.9), L.HAY.darkened(0.1), Vector3(1.0, 0.5, 0.9), 7)
	L.s(h, 0.5, Vector3(-0.9, 0.15, 0.7), L.HAY.lightened(0.05), Vector3(0.9, 0.3, 0.7), 7)


static func build_ot_demeti(h: Node3D) -> void:
	L.cb(h, 0.25, 0.7, 0, 0, 0, L.GREEN.lightened(0.15), 8, 0.12)
	L.b(h, Vector3(0.5, 0.04, 0.04), Vector3(0, 0.25, 0.0), L.ROPE)
	L.s(h, 0.2, Vector3(0, 0.72, 0), L.GREEN, Vector3(1.0, 0.5, 1.0), 6)


static func build_yun_balyasi(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.4, 0), L.FUR_W, Vector3(0.9, 0.8, 0.62), 8)
	L.b(h, Vector3(0.05, 0.82, 0.66), Vector3(-0.2, 0.4, 0), L.ROPE)
	L.b(h, Vector3(0.05, 0.82, 0.66), Vector3(0.2, 0.4, 0), L.ROPE)
	L.b(h, Vector3(0.9, 0.05, 0.05), Vector3(0, 0.62, 0.3), L.ROPE)
