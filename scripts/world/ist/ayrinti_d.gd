class_name AyrintiD
extends RefCounted
## Ayrıntı kitaplığı, bölüm D: su yapıları, kilise/mezar ayrıntıları, bostan ve ağaçlar, sokak mobilyası.
## ITEMS: [id, ad, en, yükseklik, boy, çarpışma, grup]

const L := preload("res://scripts/world/ist/ayrinti_lib.gd")

const ITEMS := [
	["tas_havuz", "Taş havuz", 2.4, 0.8, 2.4, "kutu", "su"],
	["cesme", "Duvar çeşmesi", 1.6, 2.2, 0.8, "kutu", "su"],
	["sarnic_agzi", "Sarnıç ağzı", 1.4, 0.9, 1.4, "kutu", "su"],
	["sutun_govdesi", "Sütun gövdesi (yatık)", 2.8, 0.8, 0.8, "kutu", "harabe"],
	["mezar_tasi", "Mezar taşı", 0.6, 1.1, 0.25, "kutu", "mezar"],
	["can_cercevesi", "Çan çerçevesi", 1.8, 2.8, 0.8, "ozel", "kutsal"],
	["vaftiz_kurnasi", "Vaftiz kurnası", 1.0, 1.0, 1.0, "kutu", "kutsal"],
	["ayin_bayragi", "Ayin sancağı", 1.0, 3.0, 0.2, "ozel", "ayin"],
	["ikon_sehpasi", "İkona taşıma sedyesi", 1.4, 1.2, 1.0, "kutu", "ayin"],
	["buhurdan", "Buhurdan sehpası", 0.5, 1.2, 0.5, "kutu", "ayin"],
	["bostan_sirasi", "Bostan sırası", 3.0, 0.5, 1.0, "yok", "bahce"],
	["korkuluk", "Bostan korkuluğu", 1.2, 2.0, 0.4, "ozel", "bahce"],
	["meyve_agaci", "Meyve ağacı", 2.8, 3.4, 2.8, "ozel", "bitki"],
	["zeytin_agaci", "Zeytin ağacı", 3.0, 4.0, 3.0, "ozel", "bitki"],
	["selvi", "Selvi", 1.2, 6.0, 1.2, "ozel", "bitki"],
	["cali", "Çalı", 1.4, 0.9, 1.4, "yok", "bitki"],
	["cicek_tarhasi", "Çiçek tarhası", 2.0, 0.5, 1.0, "yok", "bahce"],
	["tas_kemer", "Taş kemer geçidi", 3.0, 3.0, 1.0, "ozel", "yapi"],
	["sokak_basamagi", "Sokak basamakları", 1.6, 1.2, 2.4, "ozel", "yapi"],
	["direk_fener", "Direk kandil", 0.4, 3.0, 0.4, "ozel", "yapi"],
	["sundurma", "Alçak sundurma", 3.0, 2.8, 2.2, "ozel", "ev"],
	["agac_govde_kutugu", "Devrilmiş ağaç gövdesi", 3.0, 0.7, 0.7, "kutu", "bitki"],
	["kuru_ot_yigini", "Kuru ot ve dikenli çalı", 1.4, 0.7, 1.2, "yok", "bitki"],
	["kilise_kapi_sundurmasi", "Ayin kapısı sundurması", 2.6, 3.2, 1.4, "ozel", "kutsal"],
	["tahta_yigini", "Tahta yığını", 2.0, 0.8, 0.6, "kutu", "yapi"],
	["baglama_kazigi", "At bağlama kazığı", 1.6, 1.3, 0.3, "ozel", "tasima"],
	["su_kovasi", "Su kovası ve sırık", 0.5, 0.45, 0.5, "kutu", "su"],
	["toprak_yigini", "Toprak yığını", 1.8, 0.7, 1.4, "kutu", "yigin"],
	["cuval_yigini", "Çuval yığını", 1.4, 1.0, 0.9, "kutu", "yigin"],
	["firin_kuregi", "Fırın küreği", 0.3, 2.2, 0.3, "ozel", "mutfak"],
	["tas_oturak", "Taş oturak", 1.2, 0.5, 0.5, "kutu", "ev"],
	["hasir", "Hasır serili zemin", 1.6, 0.05, 1.2, "yok", "ev"],
	["hasir_perde", "Hasır perde", 1.8, 2.0, 0.1, "ozel", "ev"],
	["yol_tasi", "Mil taşı", 0.5, 1.2, 0.5, "kutu", "yapi"],
	["tas_kaide", "Heykel kaidesi (boş)", 1.2, 1.6, 1.2, "kutu", "harabe"],
	["balik_sepeti_yuk", "Balık sepeti yükü", 0.9, 0.7, 0.5, "kutu", "liman"],
	["tulum_yigini", "Su tulumları", 1.0, 0.5, 0.8, "kutu", "tasima"],
	["tas_havan", "Taş havan", 0.5, 0.45, 0.5, "kutu", "mutfak"],
]


static func build_tas_havuz(h: Node3D) -> void:
	L.sol(h, Vector3(2.4, 0.2, 2.4), Vector3(0, 0.1, 0), L.STONE_D, Vector3.ZERO, "ashlar")
	L.sol(h, Vector3(2.4, 0.6, 0.3), Vector3(0, 0.5, 1.05), L.STONE, Vector3.ZERO, "ashlar")
	L.sol(h, Vector3(2.4, 0.6, 0.3), Vector3(0, 0.5, -1.05), L.STONE, Vector3.ZERO, "ashlar")
	L.sol(h, Vector3(0.3, 0.6, 1.8), Vector3(-1.05, 0.5, 0), L.STONE, Vector3.ZERO, "ashlar")
	L.sol(h, Vector3(0.3, 0.6, 1.8), Vector3(1.05, 0.5, 0), L.STONE, Vector3.ZERO, "ashlar")
	L.b(h, Vector3(1.8, 0.04, 1.8), Vector3(0, 0.55, 0), L.WATER)
	L.b(h, Vector3(2.5, 0.06, 0.4), Vector3(0, 0.83, 1.05), L.STONE_L)
	L.b(h, Vector3(2.5, 0.06, 0.4), Vector3(0, 0.83, -1.05), L.STONE_L)


static func build_cesme(h: Node3D) -> void:
	L.sol(h, Vector3(1.6, 2.0, 0.5), Vector3(0, 1.0, -0.15), L.STONE, Vector3.ZERO, "ashlar")
	L.pr(h, Vector3(1.8, 0.4, 0.6), Vector3(0, 2.2, -0.15), L.TERRA_D)
	L.b(h, Vector3(0.9, 0.9, 0.06), Vector3(0, 1.35, 0.13), L.STONE_D)
	L.b(h, Vector3(0.22, 0.28, 0.04), Vector3(0, 1.55, 0.17), L.MARBLE)
	L.c(h, 0.04, 0.2, Vector3(0, 1.28, 0.22), L.IRON, Vector3(90, 0, 0), 6)
	L.b(h, Vector3(0.02, 0.5, 0.02), Vector3(0, 0.95, 0.26), L.WATER)
	L.sol(h, Vector3(1.4, 0.4, 0.5), Vector3(0, 0.2, 0.4), L.STONE_L, Vector3.ZERO, "ashlar")
	L.b(h, Vector3(1.2, 0.03, 0.34), Vector3(0, 0.41, 0.4), L.WATER)
	L.b(h, Vector3(0.5, 0.08, 0.06), Vector3(0, 1.82, 0.14), L.STONE_L)


static func build_sarnic_agzi(h: Node3D) -> void:
	L.sol(h, Vector3(1.4, 0.2, 1.4), Vector3(0, 0.1, 0), L.STONE_D, Vector3.ZERO, "ashlar")
	L.cb(h, 0.55, 0.7, 0, 0.2, 0, L.MARBLE, 12, 0.5, "marble")
	L.cb(h, 0.38, 0.02, 0, 0.9, 0, L.BLACK, 10)
	L.c(h, 0.58, 0.08, Vector3(0, 0.88, 0), L.MARBLE.darkened(0.05), Vector3.ZERO, 12)
	L.b(h, Vector3(0.08, 0.12, 0.2), Vector3(0.48, 0.55, 0), L.IRON)


static func build_sutun_govdesi(h: Node3D) -> void:
	L.c(h, 0.38, 2.6, Vector3(0, 0.42, 0), L.MARBLE, Vector3(0, 0, 90), 12, 0.36, "marble")
	for x in [-1.1, 0.0, 1.1]:
		L.c(h, 0.4, 0.06, Vector3(x, 0.42, 0), L.MARBLE.darkened(0.12), Vector3(0, 0, 90), 12)
	L.b(h, Vector3(0.4, 0.16, 0.4), Vector3(-1.2, 0.08, 0.0), L.STONE_D, Vector3.ZERO, "rubble")
	L.b(h, Vector3(0.4, 0.16, 0.4), Vector3(1.2, 0.08, 0.0), L.STONE_D, Vector3.ZERO, "rubble")


static func build_mezar_tasi(h: Node3D) -> void:
	L.sol(h, Vector3(0.6, 0.16, 0.3), Vector3(0, 0.08, 0), L.STONE_D, Vector3.ZERO, "rubble")
	L.sol(h, Vector3(0.4, 0.8, 0.14), Vector3(0, 0.55, 0), L.STONE_L, Vector3.ZERO, "ashlar")
	L.s(h, 0.5, Vector3(0, 0.96, 0), L.STONE_L, Vector3(0.4, 0.2, 0.14), 6)
	L.b(h, Vector3(0.06, 0.3, 0.03), Vector3(0, 0.62, 0.075), L.STONE_D)
	L.b(h, Vector3(0.2, 0.06, 0.03), Vector3(0, 0.7, 0.075), L.STONE_D)


static func build_can_cercevesi(h: Node3D) -> void:
	for sx in [-0.8, 0.8]:
		L.sol(h, Vector3(0.18, 2.6, 0.18), Vector3(sx, 1.3, 0), L.WOOD_D, Vector3.ZERO, "wood")
		L.rod(h, Vector3(sx, 0.0, 0.5), Vector3(sx, 1.9, 0.0), 0.1, L.WOOD)
		L.rod(h, Vector3(sx, 0.0, -0.5), Vector3(sx, 1.9, 0.0), 0.1, L.WOOD)
	L.b(h, Vector3(1.8, 0.2, 0.2), Vector3(0, 2.6, 0), L.WOOD_D)
	L.pr(h, Vector3(2.0, 0.4, 0.8), Vector3(0, 2.9, 0), L.TERRA_D)
	L.s(h, 0.5, Vector3(0, 1.9, 0), L.GOLD.darkened(0.1), Vector3(0.7, 0.8, 0.7), 8)
	L.b(h, Vector3(0.1, 0.1, 0.3), Vector3(0, 1.5, 0), L.IRON)
	L.b(h, Vector3(0.05, 0.25, 0.05), Vector3(0, 2.45, 0), L.IRON)
	L.b(h, Vector3(0.05, 0.9, 0.05), Vector3(0, 1.1, 0.0), L.ROPE)


static func build_vaftiz_kurnasi(h: Node3D) -> void:
	L.cb(h, 0.25, 0.65, 0, 0, 0, L.MARBLE, 8, 0.22, "marble")
	L.cb(h, 0.45, 0.35, 0, 0.65, 0, L.MARBLE, 10, 0.5, "marble")
	L.cb(h, 0.38, 0.02, 0, 0.99, 0, L.WATER, 10)
	L.cb(h, 0.5, 0.1, 0, 0, 0, L.STONE_L, 10)
	L.b(h, Vector3(0.1, 0.04, 0.04), Vector3(0.0, 1.03, 0.0), L.GOLD)


static func build_ayin_bayragi(h: Node3D) -> void:
	L.cb(h, 0.04, 2.9, 0, 0, 0, L.WOOD_D, 6)
	L.col_box(h, Vector3(0.1, 2.9, 0.1), Vector3(0, 1.45, 0))
	L.b(h, Vector3(0.05, 0.05, 0.9), Vector3(0, 2.7, 0), L.WOOD)
	L.b(h, Vector3(0.025, 0.2, 0.025), Vector3(0, 3.05, 0), L.GOLD)
	L.b(h, Vector3(0.15, 0.04, 0.04), Vector3(0, 2.98, 0), L.GOLD)
	L.b(h, Vector3(0.03, 1.3, 0.8), Vector3(0, 2.0, 0), L.PURPLE)
	L.b(h, Vector3(0.035, 0.5, 0.06), Vector3(0, 2.0, 0), L.GOLD)
	L.b(h, Vector3(0.035, 0.06, 0.3), Vector3(0, 2.2, 0), L.GOLD)
	for i in 5:
		L.b(h, Vector3(0.03, 0.14, 0.04), Vector3(0, 1.3, -0.3 + i * 0.15), L.GOLD)


static func build_ikon_sehpasi(h: Node3D) -> void:
	for sx in [-0.55, 0.55]:
		L.sol(h, Vector3(0.08, 0.8, 1.0), Vector3(sx, 0.4, 0), L.WOOD_D, Vector3.ZERO, "wood")
	for z in [-0.4, 0.4]:
		L.b(h, Vector3(1.2, 0.06, 0.06), Vector3(0, 0.5, z), L.WOOD)
	for z in [-0.45, 0.45]:
		L.rod(h, Vector3(-0.55, 0.0, z * 1.25), Vector3(-0.55, 0.8, z * 0.5), 0.06, L.WOOD_L)
	L.sol(h, Vector3(1.0, 0.08, 0.8), Vector3(0, 0.7, 0), L.PLANK, Vector3.ZERO, "wood")
	L.b(h, Vector3(0.6, 0.45, 0.04), Vector3(0, 0.98, 0.0), L.GOLD, Vector3(-12, 0, 0))
	L.s(h, 0.5, Vector3(0, 1.08, 0.03), L.SKIN, Vector3(0.14, 0.17, 0.02), 6)
	L.b(h, Vector3(0.62, 0.04, 0.08), Vector3(0, 0.76, 0.12), L.PURPLE)


static func build_buhurdan(h: Node3D) -> void:
	L.cb(h, 0.03, 1.0, 0, 0, 0, L.IRON, 6)
	L.cb(h, 0.15, 0.04, 0, 0, 0, L.IRON, 8)
	L.s(h, 0.5, Vector3(0, 1.05, 0), L.GOLD, Vector3(0.28, 0.2, 0.28), 8)
	L.cb(h, 0.1, 0.1, 0, 1.12, 0, L.GOLD.darkened(0.1), 7, 0.04)
	L.s(h, 0.06, Vector3(0, 1.3, 0), Color("c9c4bb"), Vector3(1, 1.6, 1), 5)


static func build_bostan_sirasi(h: Node3D) -> void:
	L.b(h, Vector3(3.0, 0.1, 1.0), Vector3(0, 0.05, 0), L.SOIL, Vector3.ZERO, "rubble")
	for i in 5:
		var x := -1.2 + i * 0.6
		L.s(h, 0.5, Vector3(x, 0.22, -0.2), L.GREEN if i % 2 == 0 else L.GREEN.lightened(0.15), Vector3(0.32, 0.3, 0.32), 6)
		L.s(h, 0.5, Vector3(x + 0.1, 0.2, 0.25), L.GREEN_D, Vector3(0.28, 0.24, 0.28), 6)
	for i in 3:
		L.s(h, 0.09, Vector3(-0.9 + i * 0.9, 0.18, 0.05), L.RED if i % 2 == 0 else L.OCHRE, Vector3.ONE, 5)


static func build_korkuluk(h: Node3D) -> void:
	L.cb(h, 0.04, 1.7, 0, 0, 0, L.WOOD_D, 6)
	L.col_box(h, Vector3(0.1, 1.7, 0.1), Vector3(0, 0.85, 0))
	L.b(h, Vector3(1.2, 0.05, 0.05), Vector3(0, 1.4, 0), L.WOOD)
	L.b(h, Vector3(0.7, 0.8, 0.03), Vector3(0, 1.0, 0.04), L.SACK.darkened(0.15))
	L.s(h, 0.18, Vector3(0, 1.75, 0), L.SACK, Vector3.ONE, 7)
	L.cb(h, 0.22, 0.03, 0, 1.85, 0, L.STRAW, 8, 0.12)
	L.cb(h, 0.12, 0.12, 0, 1.88, 0, L.STRAW, 8, 0.12)
	for sx in [-1, 1]:
		L.b(h, Vector3(0.015, 0.2, 0.015), Vector3(sx * 0.5, 1.28, 0), L.HAY)


static func build_meyve_agaci(h: Node3D) -> void:
	L.cb(h, 0.17, 1.6, 0, 0, 0, L.WOOD_D, 7, 0.12)
	L.col_box(h, Vector3(0.35, 1.5, 0.35), Vector3(0, 0.75, 0))
	L.rod(h, Vector3(0, 1.3, 0), Vector3(-0.7, 2.2, 0.2), 0.1, L.WOOD_D)
	L.rod(h, Vector3(0, 1.4, 0), Vector3(0.7, 2.3, -0.2), 0.1, L.WOOD_D)
	L.s(h, 0.5, Vector3(0, 2.6, 0), L.GREEN, Vector3(2.6, 1.8, 2.6), 8)
	L.s(h, 0.5, Vector3(-0.8, 2.3, 0.3), L.GREEN_D, Vector3(1.4, 1.1, 1.4), 7)
	L.s(h, 0.5, Vector3(0.8, 2.4, -0.3), L.GREEN.lightened(0.1), Vector3(1.4, 1.0, 1.4), 7)
	for i in 7:
		var a := i * 0.9
		L.s(h, 0.8 * 0.1, Vector3(cos(a) * 0.9, 2.4 + (i % 3) * 0.25, sin(a) * 0.9), Color("f5e6ea") if i % 2 == 0 else L.RED, Vector3.ONE, 5)


static func build_zeytin_agaci(h: Node3D) -> void:
	L.cb(h, 0.22, 1.4, 0, 0, 0, L.WOOD_D.lightened(0.1), 7, 0.16)
	L.col_box(h, Vector3(0.45, 1.4, 0.45), Vector3(0, 0.7, 0))
	L.rod(h, Vector3(0, 1.2, 0), Vector3(-0.9, 2.4, 0), 0.13, L.WOOD_D)
	L.rod(h, Vector3(0, 1.2, 0), Vector3(0.9, 2.2, 0.3), 0.13, L.WOOD_D)
	L.rod(h, Vector3(0, 1.3, 0), Vector3(0.1, 2.7, -0.7), 0.12, L.WOOD_D)
	var gc := Color("7e9a64")
	L.s(h, 0.5, Vector3(0, 3.0, 0), gc, Vector3(3.0, 1.5, 3.0), 8)
	L.s(h, 0.5, Vector3(-1.0, 2.5, 0.2), gc.darkened(0.1), Vector3(1.6, 1.0, 1.6), 7)
	L.s(h, 0.5, Vector3(1.0, 2.6, 0.3), gc.lightened(0.08), Vector3(1.6, 1.0, 1.6), 7)
	L.s(h, 0.5, Vector3(0.1, 3.5, -0.4), gc.lightened(0.05), Vector3(1.8, 0.9, 1.8), 7)


static func build_selvi(h: Node3D) -> void:
	L.cb(h, 0.1, 0.8, 0, 0, 0, L.WOOD_D, 6)
	L.col_box(h, Vector3(0.25, 0.8, 0.25), Vector3(0, 0.4, 0))
	L.cb(h, 0.55, 5.2, 0, 0.8, 0, Color("3f5e34"), 8, 0.03)
	L.s(h, 0.5, Vector3(0, 2.3, 0), Color("466a38"), Vector3(1.1, 3.0, 1.1), 7)


static func build_cali(h: Node3D) -> void:
	for i in 5:
		var a := i * 1.3
		L.s(h, 0.5, Vector3(cos(a) * 0.3, 0.3 + (i % 2) * 0.1, sin(a) * 0.3), L.GREEN if i % 2 == 0 else L.GREEN_D, Vector3(0.7, 0.55, 0.7), 6)
	L.s(h, 0.5, Vector3(0, 0.45, 0), L.GREEN.lightened(0.1), Vector3(0.8, 0.6, 0.8), 6)
	for i in 3:
		L.s(h, 0.05, Vector3(cos(i * 2.0) * 0.4, 0.5, sin(i * 2.0) * 0.4), L.RED, Vector3.ONE, 4)


static func build_cicek_tarhasi(h: Node3D) -> void:
	L.b(h, Vector3(2.0, 0.12, 1.0), Vector3(0, 0.06, 0), L.SOIL)
	for sx in [-1.0, 1.0]:
		L.b(h, Vector3(0.1, 0.2, 1.1), Vector3(sx, 0.1, 0), L.STONE_D, Vector3.ZERO, "rubble")
	for sz in [-0.5, 0.5]:
		L.b(h, Vector3(2.1, 0.2, 0.1), Vector3(0, 0.1, sz), L.STONE_D, Vector3.ZERO, "rubble")
	var cs := [L.RED, L.OCHRE, Color("f0e6f0"), L.PURPLE.lightened(0.2), Color("d96b8a")]
	for i in 6:
		var x := -0.7 + (i % 3) * 0.7
		var z := -0.2 + (i / 5) * 0.4
		L.b(h, Vector3(0.02, 0.25, 0.02), Vector3(x, 0.24, z), L.GREEN_D)
		L.s(h, 0.07, Vector3(x, 0.4, z), cs[i % 5], Vector3.ONE, 5)


static func build_tas_kemer(h: Node3D) -> void:
	# 1,4 m geçitli taş kemer: iki ayak + sivri tonoz kemerliği, tepe düz yüzey
	L.sol(h, Vector3(0.8, 2.3, 1.0), Vector3(-1.1, 1.15, 0), L.STONE, Vector3.ZERO, "ashlar")
	L.sol(h, Vector3(0.8, 2.3, 1.0), Vector3(1.1, 1.15, 0), L.STONE, Vector3.ZERO, "ashlar")
	L.sol(h, Vector3(3.0, 0.7, 1.0), Vector3(0, 2.65, 0), L.STONE, Vector3.ZERO, "ashlar")
	for i in 5:
		var a := PI * (0.08 + i * 0.21)
		L.b(h, Vector3(0.22, 0.22, 1.04), Vector3(cos(a) * 0.82, 2.3 + sin(a) * 0.2, 0), L.STONE_L, Vector3(0, 0, rad_to_deg(a)))
	L.b(h, Vector3(3.1, 0.12, 1.1), Vector3(0, 3.0, 0), L.STONE_L)


static func build_sokak_basamagi(h: Node3D) -> void:
	for i in 4:
		L.sol(h, Vector3(1.6, 0.3 * (i + 1), 0.6), Vector3(0, 0.15 * (i + 1), -0.9 + i * 0.6), L.STONE if i % 2 == 0 else L.STONE_L, Vector3.ZERO, "ashlar")


static func build_direk_fener(h: Node3D) -> void:
	L.cb(h, 0.05, 2.6, 0, 0, 0, L.WOOD_D, 6)
	L.col_box(h, Vector3(0.12, 2.6, 0.12), Vector3(0, 1.3, 0))
	L.b(h, Vector3(0.7, 0.05, 0.05), Vector3(0.3, 2.5, 0), L.IRON)
	L.b(h, Vector3(0.05, 0.28, 0.05), Vector3(0.6, 2.35, 0), L.IRON)
	L.b(h, Vector3(0.2, 0.28, 0.2), Vector3(0.6, 2.15, 0), L.GOLD.darkened(0.3))
	L.s(h, 0.12, Vector3(0.6, 2.15, 0), Color("ffd890"), Vector3.ONE, 5)
	L.b(h, Vector3(0.28, 0.04, 0.28), Vector3(0.6, 2.32, 0), L.IRON)


static func build_sundurma(h: Node3D) -> void:
	# alçak sundurma: ön direk 2,2 m, arka 2,8; üstü düz tahta (çıkılabilir) + eğimli saz kaplama
	for sx in [-1.35, 1.35]:
		L.sol(h, Vector3(0.14, 2.2, 0.14), Vector3(sx, 1.1, 1.0), L.WOOD_D, Vector3.ZERO, "wood")
		L.sol(h, Vector3(0.14, 2.8, 0.14), Vector3(sx, 1.4, -1.0), L.WOOD_D, Vector3.ZERO, "wood")
	L.sol(h, Vector3(3.0, 0.1, 2.3), Vector3(0, 2.55, 0), L.PLANK, Vector3(-14, 0, 0), "wood")
	L.col_box(h, Vector3(3.0, 0.12, 2.0), Vector3(0, 2.5, 0))
	L.b(h, Vector3(3.1, 0.12, 2.35), Vector3(0, 2.63, 0), L.STRAW, Vector3(-14, 0, 0))
	L.sol(h, Vector3(3.0, 2.8, 0.1), Vector3(0, 1.4, -1.1), L.PLANK, Vector3.ZERO, "wood")
	L.sol(h, Vector3(1.4, 0.5, 0.6), Vector3(-0.2, 0.25, -0.6), L.WOOD)
	L.sol(h, Vector3(0.7, 1.0, 0.7), Vector3(1.0, 0.5, -0.65), L.WOOD_L, Vector3.ZERO, "wood")


static func build_agac_govde_kutugu(h: Node3D) -> void:
	L.c(h, 0.35, 3.0, Vector3(0, 0.35, 0), L.WOOD_D, Vector3(0, 0, 90), 9, 0.3, "wood")
	L.c(h, 0.2, 0.02, Vector3(-1.5, 0.35, 0), L.WOOD_L, Vector3(0, 0, 90), 9)
	L.rod(h, Vector3(0.6, 0.55, 0.0), Vector3(1.2, 1.0, 0.5), 0.09, L.WOOD_D)
	L.s(h, 0.5, Vector3(1.3, 1.1, 0.5), L.GREEN_D, Vector3(0.7, 0.5, 0.7), 6)


static func build_kuru_ot_yigini(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.25, 0), L.HAY.darkened(0.2), Vector3(1.4, 0.5, 1.1), 7)
	for i in 6:
		L.rod(h, Vector3(-0.5 + i * 0.2, 0.3, (i % 2) * 0.2 - 0.1), Vector3(-0.6 + i * 0.25, 0.7, (i % 3 - 1) * 0.25), 0.02, L.WOOD_D)


static func build_kilise_kapi_sundurmasi(h: Node3D) -> void:
	for sx in [-1.1, 1.1]:
		L.sol(h, Vector3(0.22, 2.4, 0.22), Vector3(sx, 1.2, 0.5), L.MARBLE, Vector3.ZERO, "marble")
		L.b(h, Vector3(0.34, 0.14, 0.34), Vector3(sx, 2.47, 0.5), L.MARBLE.darkened(0.05))
		L.b(h, Vector3(0.3, 0.1, 0.3), Vector3(sx, 0.05, 0.5), L.MARBLE.darkened(0.1))
	L.sol(h, Vector3(2.6, 0.2, 1.3), Vector3(0, 2.65, 0.0), L.STONE, Vector3.ZERO, "ashlar")
	L.pr(h, Vector3(2.8, 0.55, 1.4), Vector3(0, 3.0, 0), L.TERRA_D)
	L.col_box(h, Vector3(2.6, 0.1, 1.3), Vector3(0, 2.8, 0))
	L.sol(h, Vector3(2.6, 2.6, 0.2), Vector3(0, 1.3, -0.6), L.STONE, Vector3.ZERO, "ashlar")
	L.b(h, Vector3(1.0, 1.9, 0.08), Vector3(0, 0.95, -0.46), L.WOOD_D, Vector3.ZERO, "wood")
	L.b(h, Vector3(0.06, 0.3, 0.03), Vector3(0, 2.35, -0.45), L.GOLD)
	L.b(h, Vector3(0.2, 0.06, 0.03), Vector3(0, 2.41, -0.45), L.GOLD)


static func build_tahta_yigini(h: Node3D) -> void:
	for i in 6:
		L.b(h, Vector3(2.0, 0.1, 0.55 - (i % 2) * 0.05), Vector3(0, 0.05 + i * 0.12, 0), L.PLANK if i % 2 == 0 else L.WOOD_L, Vector3(0, (i % 3 - 1) * 2.0, 0), "wood")

static func build_baglama_kazigi(h: Node3D) -> void:
	for sx in [-0.7, 0.7]:
		L.cb(h, 0.07, 1.3, sx, 0, 0, L.WOOD_D, 6)
		L.col_box(h, Vector3(0.16, 1.3, 0.16), Vector3(sx, 0.65, 0))
	L.b(h, Vector3(1.5, 0.08, 0.08), Vector3(0, 1.0, 0), L.WOOD)
	L.b(h, Vector3(0.02, 0.5, 0.02), Vector3(-0.2, 0.78, 0.0), L.ROPE)
	L.b(h, Vector3(0.14, 0.05, 0.05), Vector3(-0.2, 0.55, 0.0), L.ROPE)


static func build_su_kovasi(h: Node3D) -> void:
	L.cb(h, 0.2, 0.34, 0, 0, 0, L.WOOD, 8, 0.17, "wood")
	L.cb(h, 0.215, 0.03, 0, 0.08, 0, L.IRON, 8)
	L.cb(h, 0.16, 0.02, 0, 0.32, 0, L.WATER, 8)
	L.b(h, Vector3(0.36, 0.03, 0.03), Vector3(0, 0.42, 0), L.IRON)
	L.b(h, Vector3(0.03, 0.12, 0.03), Vector3(-0.18, 0.36, 0), L.IRON)
	L.b(h, Vector3(0.03, 0.12, 0.03), Vector3(0.18, 0.36, 0), L.IRON)


static func build_toprak_yigini(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.12, 0), L.SOIL, Vector3(1.8, 0.7, 1.4), 7)
	L.s(h, 0.5, Vector3(0.5, 0.08, 0.5), L.SOIL.lightened(0.08), Vector3(0.9, 0.35, 0.7), 6)
	L.s(h, 0.5, Vector3(-0.5, 0.06, -0.3), L.SOIL.darkened(0.08), Vector3(0.7, 0.3, 0.6), 6)
	L.rod(h, Vector3(0.7, 0.2, 0.2), Vector3(1.2, 0.75, -0.1), 0.04, L.WOOD_L)


static func build_cuval_yigini(h: Node3D) -> void:
	for i in 3:
		L.s(h, 0.5, Vector3(-0.4 + i * 0.4, 0.27, 0.0), L.SACK, Vector3(0.45, 0.54, 0.7), 6)
	for i in 2:
		L.s(h, 0.5, Vector3(-0.2 + i * 0.4, 0.74, 0.0), L.SACK.darkened(0.06), Vector3(0.45, 0.5, 0.7), 6)
	L.s(h, 0.5, Vector3(0.0, 0.88, -0.1), L.SACK.lightened(0.05), Vector3(0.45, 0.35, 0.6), 6)
	L.b(h, Vector3(0.9, 0.04, 0.04), Vector3(0, 0.45, 0.35), L.ROPE)


static func build_firin_kuregi(h: Node3D) -> void:
	L.rod(h, Vector3(0, 0.0, 0.2), Vector3(0.05, 1.95, 0.0), 0.05, L.WOOD_L)
	L.b(h, Vector3(0.28, 0.03, 0.34), Vector3(0.0, 0.03, 0.4), L.WOOD)
	L.col_box(h, Vector3(0.14, 2.0, 0.14), Vector3(0.02, 1.0, 0.1))


static func build_tas_oturak(h: Node3D) -> void:
	L.sol(h, Vector3(1.2, 0.5, 0.5), Vector3(0, 0.25, 0), L.STONE, Vector3.ZERO, "ashlar")
	L.b(h, Vector3(1.24, 0.06, 0.54), Vector3(0, 0.51, 0), L.STONE_L)
	L.b(h, Vector3(0.3, 0.14, 0.4), Vector3(0.3, 0.57, 0), L.RED.darkened(0.1))


static func build_hasir(h: Node3D) -> void:
	for i in 6:
		L.b(h, Vector3(1.6, 0.03, 0.2), Vector3(0, 0.025, -0.5 + i * 0.2), L.STRAW if i % 2 == 0 else L.HAY, Vector3.ZERO)
	L.b(h, Vector3(1.6, 0.04, 0.06), Vector3(0, 0.03, 0.55), L.RED.darkened(0.1))
	L.b(h, Vector3(1.6, 0.04, 0.06), Vector3(0, 0.03, -0.55), L.RED.darkened(0.1))


static func build_hasir_perde(h: Node3D) -> void:
	for sx in [-0.9, 0.9]:
		L.cb(h, 0.05, 2.0, sx, 0, 0, L.WOOD_D, 6)
		L.col_box(h, Vector3(0.12, 2.0, 0.12), Vector3(sx, 1.0, 0))
	L.b(h, Vector3(1.9, 0.07, 0.07), Vector3(0, 1.95, 0), L.WOOD)
	for i in 7:
		L.b(h, Vector3(0.22, 1.6, 0.03), Vector3(-0.75 + i * 0.25, 1.1, 0), L.STRAW if i % 2 == 0 else L.HAY)
	L.b(h, Vector3(1.8, 0.05, 0.05), Vector3(0, 0.3, 0.02), L.ROPE)


static func build_yol_tasi(h: Node3D) -> void:
	L.sol(h, Vector3(0.5, 0.2, 0.5), Vector3(0, 0.1, 0), L.STONE_D, Vector3.ZERO, "rubble")
	L.sol(h, Vector3(0.34, 0.9, 0.34), Vector3(0, 0.65, 0), L.STONE_L, Vector3.ZERO, "ashlar")
	L.pr(h, Vector3(0.38, 0.14, 0.38), Vector3(0, 1.17, 0), L.STONE_L)
	L.b(h, Vector3(0.08, 0.3, 0.02), Vector3(0, 0.8, 0.18), L.STONE_D)


static func build_tas_kaide(h: Node3D) -> void:
	L.sol(h, Vector3(1.2, 0.3, 1.2), Vector3(0, 0.15, 0), L.STONE_D, Vector3.ZERO, "ashlar")
	L.sol(h, Vector3(0.9, 1.0, 0.9), Vector3(0, 0.8, 0), L.MARBLE, Vector3.ZERO, "marble")
	L.sol(h, Vector3(1.1, 0.14, 1.1), Vector3(0, 1.37, 0), L.MARBLE.darkened(0.05), Vector3.ZERO, "marble")
	L.b(h, Vector3(0.5, 0.3, 0.03), Vector3(0, 0.85, 0.46), L.STONE_L)
	L.b(h, Vector3(0.1, 0.06, 0.12), Vector3(0.3, 1.47, 0.3), L.STONE, Vector3(0, 30, 0), "rubble")
	L.b(h, Vector3(1.0, 0.08, 1.0), Vector3(0, 0.34, 0), L.STONE_L, Vector3.ZERO)


static func build_balik_sepeti_yuk(h: Node3D) -> void:
	for sx in [-0.22, 0.22]:
		L.cb(h, 0.22, 0.6, sx, 0, 0, L.STRAW, 8, 0.18)
		L.cb(h, 0.17, 0.02, sx, 0.6, 0, L.FUR_G, 8)
	L.b(h, Vector3(0.9, 0.05, 0.05), Vector3(0, 0.45, 0.2), L.ROPE)
	L.b(h, Vector3(0.06, 0.2, 0.06), Vector3(0, 0.68, 0.0), L.FUR_G)


static func build_tulum_yigini(h: Node3D) -> void:
	for i in 3:
		L.s(h, 0.5, Vector3(-0.3 + i * 0.3, 0.2, (i % 2) * 0.2 - 0.1), L.FUR_B.lightened(0.1), Vector3(0.34, 0.4, 0.5), 6)
		L.b(h, Vector3(0.06, 0.1, 0.06), Vector3(-0.3 + i * 0.3, 0.42, (i % 2) * 0.2 - 0.1), L.ROPE)
	L.s(h, 0.5, Vector3(0.0, 0.18, 0.4), L.FUR_B, Vector3(0.7, 0.32, 0.3), 6)


static func build_tas_havan(h: Node3D) -> void:
	L.cb(h, 0.26, 0.4, 0, 0, 0, L.STONE_L, 8, 0.22, "rubble")
	L.cb(h, 0.17, 0.04, 0, 0.4, 0, L.STONE_D, 8)
	L.b(h, Vector3(0.08, 0.5, 0.08), Vector3(0.05, 0.55, 0.0), L.WOOD_L, Vector3(0, 0, -12))
