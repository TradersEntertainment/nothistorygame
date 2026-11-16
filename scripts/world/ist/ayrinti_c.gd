class_name AyrintiC
extends RefCounted
## Ayrıntı kitaplığı, bölüm C: zanaat atölyeleri, liman, mobilya ve inşaat şantiyesi.
## ITEMS: [id, ad, en, yükseklik, boy, çarpışma, grup]

const L := preload("res://scripts/world/ist/ayrinti_lib.gd")

const ITEMS := [
	["demir_ocagi", "Demirci ocağı ve körük", 1.8, 1.5, 1.4, "kutu", "zanaat"],
	["ors", "Örs", 0.5, 0.85, 0.5, "kutu", "zanaat"],
	["soguma_teknesi", "Demirci su teknesi", 1.0, 0.7, 0.6, "kutu", "zanaat"],
	["dokuma_tezgahi", "Dokuma tezgâhı", 1.6, 1.9, 1.2, "ozel", "zanaat"],
	["boya_kazani", "Boya kazanı", 1.0, 1.0, 1.0, "kutu", "zanaat"],
	["boya_askisi", "Boyalı kumaş askısı", 3.2, 2.4, 0.4, "ozel", "zanaat"],
	["kumas_topu", "Kumaş topları", 1.0, 0.6, 0.6, "kutu", "carsi"],
	["deri_gerdirme", "Deri germe çerçevesi", 1.4, 1.8, 0.2, "ozel", "zanaat"],
	["balik_kasasi", "Balık kasası", 0.7, 0.35, 0.5, "kutu", "liman"],
	["balik_kurutma", "Balık kurutma askısı", 2.2, 1.9, 0.6, "ozel", "liman"],
	["halat_rulo", "Halat rulosu", 0.8, 0.45, 0.8, "kutu", "liman"],
	["palamar_babasi", "Palamar babası", 0.3, 0.6, 0.3, "kutu", "liman"],
	["yelken_bezi", "Katlanmış yelken bezi", 1.3, 0.6, 0.9, "kutu", "liman"],
	["masa", "Ahşap masa", 1.6, 0.8, 0.8, "kutu", "ev"],
	["tabure", "Tabure", 0.4, 0.45, 0.4, "kutu", "ev"],
	["bank", "Sokak bankı", 1.6, 0.9, 0.5, "kutu", "ev"],
	["sandik", "Ahşap sandık", 0.9, 0.55, 0.55, "kutu", "ev"],
	["kutuk", "Kütük", 0.5, 0.45, 0.5, "kutu", "yigin"],
	["kutuk_kutugu", "Odun kütüğü ve balta", 0.7, 0.9, 0.7, "kutu", "yigin"],
	["kazma_kurek", "Dayalı kazma ve kürek", 0.8, 1.7, 0.4, "ozel", "yapi"],
	["tugla_yigini", "Tuğla yığını", 1.4, 0.9, 1.0, "kutu", "yapi"],
	["kiremit_yigini", "Kiremit yığını", 1.4, 0.7, 0.8, "kutu", "yapi"],
	["harc_teknesi", "Harç teknesi", 1.2, 0.5, 0.8, "kutu", "yapi"],
	["yapi_iskelesi", "Sur onarım iskelesi", 4.6, 4.4, 1.6, "ozel", "yapi"],
	["cikrik_vinc", "Çıkrıklı taş vinci", 1.6, 3.6, 1.4, "ozel", "yapi"],
	["yikik_duvar", "Yıkık duvar (basamaklı)", 3.2, 1.8, 0.7, "ozel", "harabe"],
	["saban", "Saban", 1.8, 0.9, 0.5, "yok", "ciftlik"],
	["testi", "Testi ve çömlekler", 1.0, 0.5, 0.6, "yok", "kap"],
	["kase_tezgahi", "Kâse tezgâhı", 1.4, 0.9, 0.6, "kutu", "carsi"],
]


static func build_demir_ocagi(h: Node3D) -> void:
	L.sol(h, Vector3(1.2, 0.9, 1.0), Vector3(-0.2, 0.45, 0), L.STONE, Vector3.ZERO, "rubble")
	L.b(h, Vector3(1.0, 0.06, 0.8), Vector3(-0.2, 0.93, 0), Color("a8341a"))
	L.b(h, Vector3(0.7, 0.05, 0.5), Vector3(-0.2, 0.97, 0), Color("1a1512"))
	L.sol(h, Vector3(0.8, 1.5, 0.35), Vector3(-0.2, 0.75, -0.55), L.STONE_D, Vector3.ZERO, "rubble")
	L.cb(h, 0.35, 0.3, -0.2, 1.5, -0.55, L.STONE_D, 6, 0.2)
	L.b(h, Vector3(0.5, 0.35, 0.6), Vector3(0.65, 0.65, 0.2), L.WOOD, Vector3(0, 0, -12), "wood")
	L.b(h, Vector3(0.5, 0.05, 0.6), Vector3(0.65, 0.84, 0.2), L.RED.darkened(0.2), Vector3(0, 0, -12))
	L.rod(h, Vector3(0.45, 0.65, 0.1), Vector3(0.0, 0.85, 0.15), 0.07, L.IRON)
	L.b(h, Vector3(0.1, 0.1, 0.7), Vector3(0.9, 1.0, 0.2), L.WOOD_D)
	L.b(h, Vector3(0.5, 0.04, 0.04), Vector3(-0.1, 1.0, 0.45), L.IRON)
	if L.lod == 0:
		Flame.add(h, Vector3(-0.2, 0.98, 0), 0.4, 0.5)


static func build_ors(h: Node3D) -> void:
	L.cb(h, 0.22, 0.45, 0, 0, 0, L.WOOD, 8, 0.2, "wood")
	L.b(h, Vector3(0.28, 0.12, 0.6), Vector3(0, 0.51, 0), L.IRON)
	L.b(h, Vector3(0.2, 0.2, 0.18), Vector3(0, 0.62, 0), L.IRON_L)
	L.b(h, Vector3(0.08, 0.06, 0.3), Vector3(0, 0.62, -0.38), L.IRON, Vector3(0, 0, 0))


static func build_soguma_teknesi(h: Node3D) -> void:
	L.bb(h, Vector3(1.0, 0.08, 0.6), 0, 0, 0, L.WOOD_D)
	L.bb(h, Vector3(1.0, 0.55, 0.06), 0, 0.05, 0.27, L.WOOD, 0, "wood")
	L.bb(h, Vector3(1.0, 0.55, 0.06), 0, 0.05, -0.27, L.WOOD, 0, "wood")
	L.bb(h, Vector3(0.06, 0.55, 0.6), -0.47, 0.05, 0, L.WOOD)
	L.bb(h, Vector3(0.06, 0.55, 0.6), 0.47, 0.05, 0, L.WOOD)
	L.b(h, Vector3(0.88, 0.03, 0.48), Vector3(0, 0.55, 0), L.WATER.darkened(0.3))
	L.b(h, Vector3(0.5, 0.04, 0.04), Vector3(0.1, 0.62, 0.1), L.IRON, Vector3(0, 20, 0))


static func build_dokuma_tezgahi(h: Node3D) -> void:
	for sx in [-0.7, 0.7]:
		L.sol(h, Vector3(0.1, 1.9, 0.1), Vector3(sx, 0.95, -0.5), L.WOOD_D)
		L.sol(h, Vector3(0.1, 1.0, 0.1), Vector3(sx, 0.5, 0.5), L.WOOD_D)
		L.b(h, Vector3(0.08, 0.08, 1.1), Vector3(sx, 0.9, 0.0), L.WOOD)
	L.b(h, Vector3(1.5, 0.1, 0.1), Vector3(0, 1.85, -0.5), L.WOOD)
	L.b(h, Vector3(1.5, 0.1, 0.1), Vector3(0, 1.0, 0.5), L.WOOD)
	for i in 14:
		L.b(h, Vector3(0.012, 0.9, 0.012), Vector3(-0.65 + i * 0.1, 1.4, -0.5 + 0.0), L.LINEN, Vector3(-35, 0, 0))
	L.b(h, Vector3(1.3, 0.04, 0.5), Vector3(0, 0.95, 0.25), L.RED, Vector3(0, 0, 0))
	L.b(h, Vector3(1.4, 0.2, 0.06), Vector3(0, 1.3, -0.15), L.WOOD_L)


static func build_boya_kazani(h: Node3D) -> void:
	L.sol(h, Vector3(1.0, 0.45, 1.0), Vector3(0, 0.23, 0), L.STONE, Vector3.ZERO, "rubble")
	L.cb(h, 0.4, 0.45, 0, 0.45, 0, L.IRON, 10, 0.44)
	L.cb(h, 0.38, 0.02, 0, 0.9, 0, L.PURPLE, 10)
	L.c(h, 0.45, 0.04, Vector3(0, 0.9, 0), L.IRON_L, Vector3.ZERO, 10)
	L.b(h, Vector3(0.07, 0.07, 1.2), Vector3(0.1, 1.1, 0.0), L.WOOD, Vector3(20, 20, 0))
	L.b(h, Vector3(0.4, 0.02, 0.4), Vector3(0.1, 0.92, 0.4), L.PURPLE.lightened(0.1), Vector3(0, 20, 0))


static func build_boya_askisi(h: Node3D) -> void:
	for sx in [-1.5, 1.5]:
		L.cb(h, 0.05, 2.4, sx, 0, 0, L.WOOD_D, 6)
		L.col_box(h, Vector3(0.12, 2.4, 0.12), Vector3(sx, 1.2, 0))
	L.b(h, Vector3(3.2, 0.08, 0.08), Vector3(0, 2.3, 0), L.WOOD)
	var cs := [L.PURPLE, L.BLUE, L.RED, L.OCHRE, L.GREEN]
	for i in 5:
		L.b(h, Vector3(0.5, 1.3 + (i % 2) * 0.3, 0.03), Vector3(-1.2 + i * 0.6, 1.55 - (i % 2) * 0.15, 0), cs[i])


static func build_kumas_topu(h: Node3D) -> void:
	var cs := [L.RED, L.BLUE, L.LINEN, L.OCHRE, L.PURPLE, L.GREEN]
	for i in 6:
		L.c(h, 0.14, 0.8, Vector3(-0.35 + (i % 3) * 0.3, 0.14 + (i / 3) * 0.26, 0.0), cs[i], Vector3(90, 0, 0), 7)


static func build_deri_gerdirme(h: Node3D) -> void:
	for sx in [-0.65, 0.65]:
		L.cb(h, 0.05, 1.8, sx, 0, 0, L.WOOD_D, 6)
		L.col_box(h, Vector3(0.12, 1.8, 0.12), Vector3(sx, 0.9, 0))
	L.b(h, Vector3(1.4, 0.07, 0.07), Vector3(0, 1.75, 0), L.WOOD)
	L.b(h, Vector3(1.4, 0.07, 0.07), Vector3(0, 0.3, 0), L.WOOD)
	L.b(h, Vector3(1.1, 1.3, 0.03), Vector3(0, 1.02, 0.0), L.FUR_B.lightened(0.15))
	for i in 5:
		L.b(h, Vector3(0.015, 0.2, 0.015), Vector3(-0.5 + i * 0.25, 1.62, 0.0), L.ROPE)


static func build_balik_kasasi(h: Node3D) -> void:
	L.bb(h, Vector3(0.7, 0.05, 0.5), 0, 0, 0, L.WOOD_D)
	L.bb(h, Vector3(0.7, 0.3, 0.04), 0, 0.03, 0.23, L.WOOD, 0, "wood")
	L.bb(h, Vector3(0.7, 0.3, 0.04), 0, 0.03, -0.23, L.WOOD, 0, "wood")
	L.bb(h, Vector3(0.04, 0.3, 0.5), -0.33, 0.03, 0, L.WOOD)
	L.bb(h, Vector3(0.04, 0.3, 0.5), 0.33, 0.03, 0, L.WOOD)
	for i in 5:
		L.s(h, 0.5, Vector3(-0.22 + i * 0.11, 0.25, -0.08 + (i % 2) * 0.16), L.FUR_G.lightened(0.15), Vector3(0.1, 0.07, 0.3), 5)


static func build_balik_kurutma(h: Node3D) -> void:
	for sx in [-1.0, 1.0]:
		L.rod(h, Vector3(sx, 0, -0.25), Vector3(sx, 1.85, 0), 0.07, L.WOOD_D)
		L.rod(h, Vector3(sx, 0, 0.25), Vector3(sx, 1.85, 0), 0.07, L.WOOD_D)
		L.col_box(h, Vector3(0.12, 1.8, 0.5), Vector3(sx, 0.9, 0))
	L.b(h, Vector3(2.2, 0.06, 0.06), Vector3(0, 1.85, 0), L.WOOD)
	for i in 6:
		L.b(h, Vector3(0.012, 0.25, 0.012), Vector3(-0.85 + i * 0.34, 1.7, 0), L.ROPE)
		L.s(h, 0.5, Vector3(-0.85 + i * 0.34, 1.45, 0), L.FUR_G, Vector3(0.1, 0.45, 0.04), 5)


static func build_halat_rulo(h: Node3D) -> void:
	for i in 4:
		L.cb(h, 0.38 - i * 0.02, 0.1, 0, i * 0.1, 0, L.ROPE if i % 2 == 0 else L.ROPE.darkened(0.15), 10)
	L.cb(h, 0.14, 0.42, 0, 0.0, 0, L.ROPE.darkened(0.3), 8)
	L.b(h, Vector3(0.05, 0.05, 0.6), Vector3(0.3, 0.06, 0.45), L.ROPE, Vector3(0, 40, 0))


static func build_palamar_babasi(h: Node3D) -> void:
	L.cb(h, 0.12, 0.5, 0, 0, 0, L.WOOD_D, 8)
	L.cb(h, 0.17, 0.1, 0, 0.5, 0, L.WOOD_D, 8)
	L.b(h, Vector3(0.28, 0.05, 0.05), Vector3(0, 0.38, 0), L.IRON)


static func build_yelken_bezi(h: Node3D) -> void:
	for i in 4:
		L.b(h, Vector3(1.3 - i * 0.06, 0.13, 0.9), Vector3(0, 0.07 + i * 0.14, 0), L.LINEN.darkened(0.04 * i), Vector3(0, i * 6 - 8, 0))
	L.b(h, Vector3(0.05, 0.62, 0.05), Vector3(0.5, 0.31, 0.4), L.ROPE)


static func build_masa(h: Node3D) -> void:
	L.sol(h, Vector3(1.6, 0.07, 0.8), Vector3(0, 0.78, 0), L.PLANK, Vector3.ZERO, "wood")
	for sx in [-0.7, 0.7]:
		for sz in [-0.32, 0.32]:
			L.sol(h, Vector3(0.09, 0.75, 0.09), Vector3(sx, 0.375, sz), L.WOOD_D)
	L.b(h, Vector3(1.4, 0.06, 0.06), Vector3(0, 0.55, 0.32), L.WOOD)
	L.b(h, Vector3(1.4, 0.06, 0.06), Vector3(0, 0.55, -0.32), L.WOOD)
	L.cb(h, 0.1, 0.08, 0.3, 0.82, 0.1, L.TERRA, 7)
	L.cb(h, 0.06, 0.1, -0.3, 0.82, -0.1, L.TERRA_D, 6)
	L.b(h, Vector3(0.3, 0.05, 0.3), Vector3(-0.1, 0.84, 0.15), L.SACK)


static func build_tabure(h: Node3D) -> void:
	L.sol(h, Vector3(0.4, 0.06, 0.4), Vector3(0, 0.42, 0), L.PLANK, Vector3.ZERO, "wood")
	for sx in [-0.15, 0.15]:
		for sz in [-0.15, 0.15]:
			L.b(h, Vector3(0.05, 0.4, 0.05), Vector3(sx, 0.2, sz), L.WOOD_D)
	L.col_box(h, Vector3(0.4, 0.45, 0.4), Vector3(0, 0.225, 0))


static func build_bank(h: Node3D) -> void:
	L.sol(h, Vector3(1.6, 0.07, 0.45), Vector3(0, 0.45, 0.0), L.PLANK, Vector3.ZERO, "wood")
	for sx in [-0.65, 0.65]:
		L.sol(h, Vector3(0.1, 0.45, 0.45), Vector3(sx, 0.23, 0), L.WOOD_D)
		L.b(h, Vector3(0.1, 0.5, 0.06), Vector3(sx, 0.7, -0.2), L.WOOD_D)
	L.b(h, Vector3(1.6, 0.35, 0.05), Vector3(0, 0.75, -0.21), L.PLANK, Vector3(-5, 0, 0), "wood")


static func build_sandik(h: Node3D) -> void:
	L.sol(h, Vector3(0.9, 0.5, 0.55), Vector3(0, 0.25, 0), L.WOOD, Vector3.ZERO, "wood")
	L.b(h, Vector3(0.94, 0.07, 0.58), Vector3(0, 0.53, 0), L.WOOD_D)
	for sx in [-0.38, 0.38]:
		L.b(h, Vector3(0.06, 0.5, 0.58), Vector3(sx, 0.25, 0), L.IRON)
	L.b(h, Vector3(0.1, 0.12, 0.04), Vector3(0, 0.42, 0.29), L.GOLD.darkened(0.2))


static func build_kutuk(h: Node3D) -> void:
	L.cb(h, 0.25, 0.45, 0, 0, 0, L.WOOD, 9, 0.24, "wood")
	L.cb(h, 0.2, 0.02, 0, 0.45, 0, L.WOOD_L, 9)


static func build_kutuk_kutugu(h: Node3D) -> void:
	L.cb(h, 0.3, 0.55, 0, 0, 0, L.WOOD, 9, 0.28, "wood")
	L.cb(h, 0.27, 0.02, 0, 0.55, 0, L.WOOD_L, 9)
	L.b(h, Vector3(0.05, 0.05, 0.6), Vector3(0.1, 0.58, 0.05), L.WOOD_L, Vector3(0, 40, 0))
	L.b(h, Vector3(0.14, 0.12, 0.04), Vector3(0.28, 0.6, -0.15), L.IRON, Vector3(0, 40, 0))


static func build_kazma_kurek(h: Node3D) -> void:
	L.rod(h, Vector3(-0.25, 0, 0.12), Vector3(-0.15, 1.6, 0.0), 0.05, L.WOOD_L)
	L.b(h, Vector3(0.5, 0.06, 0.06), Vector3(-0.1, 1.62, 0.0), L.IRON, Vector3(0, 0, 8))
	L.rod(h, Vector3(0.25, 0, 0.12), Vector3(0.15, 1.5, 0.0), 0.05, L.WOOD_L)
	L.b(h, Vector3(0.25, 0.3, 0.025), Vector3(0.14, 1.62, 0.0), L.IRON_L)
	L.col_box(h, Vector3(0.8, 1.6, 0.2), Vector3(0, 0.8, 0.0))


static func build_tugla_yigini(h: Node3D) -> void:
	for row in 6:
		for i in 4 - row / 2:
			L.b(h, Vector3(0.34, 0.12, 0.2), Vector3(-0.5 + i * 0.36 + (row % 2) * 0.17 + row * 0.04, 0.07 + row * 0.13, 0.0), L.BRICK if (i + row) % 3 else L.BRICK.darkened(0.1), Vector3.ZERO, "brick")
			L.b(h, Vector3(0.34, 0.12, 0.2), Vector3(-0.5 + i * 0.36 + (row % 2) * 0.17 + row * 0.04, 0.07 + row * 0.13, 0.22), L.BRICK.lightened(0.04), Vector3.ZERO, "brick")
	L.b(h, Vector3(0.3, 0.12, 0.2), Vector3(0.7, 0.07, 0.6), L.BRICK, Vector3(0, 30, 0))
	L.b(h, Vector3(0.3, 0.12, 0.2), Vector3(-0.8, 0.07, 0.5), L.BRICK.darkened(0.1), Vector3(0, -20, 0))


static func build_kiremit_yigini(h: Node3D) -> void:
	for row in 5:
		for i in 6:
			L.b(h, Vector3(0.2, 0.12, 0.4), Vector3(-0.55 + i * 0.22, 0.06 + row * 0.1, -0.15 + row * 0.03), L.TERRA if (i + row) % 2 else L.TERRA_D)
	for i in 4:
		L.b(h, Vector3(0.2, 0.08, 0.4), Vector3(-0.3 + i * 0.22, 0.04, 0.35), L.TERRA, Vector3(0, 0, 0))


static func build_harc_teknesi(h: Node3D) -> void:
	L.sol(h, Vector3(1.2, 0.08, 0.8), Vector3(0, 0.04, 0), L.WOOD_D)
	L.sol(h, Vector3(1.2, 0.4, 0.06), Vector3(0, 0.25, 0.37), L.WOOD, Vector3.ZERO, "wood")
	L.sol(h, Vector3(1.2, 0.4, 0.06), Vector3(0, 0.25, -0.37), L.WOOD, Vector3.ZERO, "wood")
	L.sol(h, Vector3(0.06, 0.4, 0.8), Vector3(-0.57, 0.25, 0), L.WOOD)
	L.sol(h, Vector3(0.06, 0.4, 0.8), Vector3(0.57, 0.25, 0), L.WOOD)
	L.b(h, Vector3(1.05, 0.12, 0.65), Vector3(0, 0.38, 0), L.CREAM.darkened(0.12))
	L.b(h, Vector3(0.07, 0.07, 0.9), Vector3(0.1, 0.5, 0.0), L.WOOD_L, Vector3(0, 70, 20))


static func build_yapi_iskelesi(h: Node3D) -> void:
	# iki katlı ahşap şantiye iskelesi: zemin, 1,6 m'de ilk platform, 3,2 m'de ikinci; sandık yığınıyla çıkılır
	for sx in [-1.4, 1.4]:
		for sz in [-0.7, 0.7]:
			L.sol(h, Vector3(0.14, 4.4, 0.14), Vector3(sx, 2.2, sz), L.WOOD_D, Vector3.ZERO, "wood")
	for y in [1.6, 3.2]:
		L.sol(h, Vector3(3.0, 0.1, 1.6), Vector3(0, y, 0), L.PLANK, Vector3.ZERO, "wood")
		L.b(h, Vector3(3.0, 0.07, 0.07), Vector3(0, y + 1.0, 0.75), L.WOOD)
		L.b(h, Vector3(3.0, 0.07, 0.07), Vector3(0, y + 0.55, 0.75), L.WOOD)
		L.b(h, Vector3(3.0, 0.07, 0.07), Vector3(0, y + 1.0, -0.75), L.WOOD)
		L.b(h, Vector3(3.0, 0.07, 0.07), Vector3(0, y + 0.55, -0.75), L.WOOD)
	for sz in [-0.7, 0.7]:
		L.rod(h, Vector3(-1.4, 0.0, sz), Vector3(1.4, 1.6, sz), 0.07, L.WOOD)
		L.rod(h, Vector3(-1.4, 1.6, sz), Vector3(1.4, 3.2, sz), 0.07, L.WOOD)
	# yan merdiven basamakları (0,4 m aralıklı basamak tahtaları)
	L.sol(h, Vector3(0.6, 0.5, 0.9), Vector3(-2.5, 0.25, 0.0), L.WOOD, Vector3.ZERO, "wood")
	L.sol(h, Vector3(0.6, 1.0, 0.9), Vector3(-2.0, 0.5, 0.0), L.WOOD_L, Vector3.ZERO, "wood")
	L.b(h, Vector3(0.3, 0.3, 0.3), Vector3(0.6, 3.4, 0.2), L.STONE)
	L.b(h, Vector3(0.5, 0.2, 0.4), Vector3(-0.5, 3.35, -0.3), L.CREAM.darkened(0.1))


static func build_cikrik_vinc(h: Node3D) -> void:
	for sx in [-0.7, 0.7]:
		L.rod(h, Vector3(sx, 0, -0.55), Vector3(sx, 3.5, 0.0), 0.14, L.WOOD)
		L.rod(h, Vector3(sx, 0, 0.55), Vector3(sx, 3.5, 0.0), 0.14, L.WOOD)
		L.col_box(h, Vector3(0.3, 0.3, 1.2), Vector3(sx, 0.15, 0))
	L.c(h, 0.8, 0.12, Vector3(0, 3.0, 0.0), L.WOOD_D, Vector3(0, 0, 90), 12, -1.0, "wood")
	L.b(h, Vector3(1.5, 0.12, 0.12), Vector3(0, 3.5, 0), L.WOOD_D)
	L.rod(h, Vector3(0.0, 3.4, 0.4), Vector3(0.0, 0.8, 0.5), 0.02, L.ROPE)
	L.b(h, Vector3(0.7, 0.55, 0.7), Vector3(0.0, 0.55, 0.5), L.STONE_L, Vector3.ZERO, "ashlar")
	L.b(h, Vector3(0.9, 0.05, 0.05), Vector3(0, 0.84, 0.5), L.IRON)


static func build_yikik_duvar(h: Node3D) -> void:
	# basamak basamak yıkılmış duvar: 0,45 – 0,9 – 1,35 – 1,8 m; her basamak zıplamadan çıkılır
	var hs := [1.8, 1.35, 0.9, 0.45]
	for i in 4:
		var x := -1.2 + i * 0.8
		L.sol(h, Vector3(0.8, hs[i], 0.7), Vector3(x, hs[i] * 0.5, 0), L.STONE if i % 2 == 0 else L.STONE_D, Vector3.ZERO, "rubble")
		L.b(h, Vector3(0.84, 0.06, 0.74), Vector3(x, hs[i] + 0.01, 0), L.STONE_L)
	L.b(h, Vector3(0.4, 0.3, 0.4), Vector3(1.0, 0.15, 0.6), L.STONE, Vector3(0, 25, 0), "rubble")
	L.b(h, Vector3(0.3, 0.25, 0.3), Vector3(-0.1, 0.12, 0.7), L.STONE_D, Vector3(0, 40, 0), "rubble")
	L.s(h, 0.3, Vector3(-1.3, 1.9, 0.0), L.GREEN, Vector3(1.2, 0.4, 0.9), 5)


static func build_saban(h: Node3D) -> void:
	L.b(h, Vector3(0.07, 0.07, 1.8), Vector3(0, 0.55, 0.0), L.WOOD, Vector3(10, 0, 0))
	L.b(h, Vector3(0.07, 0.6, 0.07), Vector3(0, 0.3, 0.7), L.WOOD_D, Vector3(0, 0, 0))
	L.b(h, Vector3(0.12, 0.08, 0.4), Vector3(0, 0.05, 0.75), L.IRON)
	L.b(h, Vector3(0.5, 0.06, 0.06), Vector3(0, 0.95, -0.9), L.WOOD)
	L.rod(h, Vector3(0, 0.1, 0.7), Vector3(0, 0.9, 0.95), 0.05, L.WOOD_L)


static func build_testi(h: Node3D) -> void:
	L.cb(h, 0.14, 0.3, -0.3, 0, 0, L.TERRA, 8, 0.07)
	L.cb(h, 0.06, 0.1, -0.3, 0.3, 0, L.TERRA, 7, 0.05)
	L.b(h, Vector3(0.03, 0.14, 0.04), Vector3(-0.17, 0.3, 0.0), L.TERRA_D)
	L.cb(h, 0.2, 0.26, 0.15, 0, 0.05, L.TERRA_D, 9, 0.16)
	L.cb(h, 0.17, 0.03, 0.15, 0.26, 0.05, L.SOIL, 9)
	L.cb(h, 0.12, 0.14, 0.35, 0, -0.18, L.TERRA, 7, 0.1)


static func build_kase_tezgahi(h: Node3D) -> void:
	L.sol(h, Vector3(1.4, 0.07, 0.6), Vector3(0, 0.8, 0), L.PLANK, Vector3.ZERO, "wood")
	for sx in [-0.6, 0.6]:
		L.sol(h, Vector3(0.08, 0.77, 0.5), Vector3(sx, 0.38, 0), L.WOOD_D)
	for i in 3:
		for j in 3 - i:
			L.cb(h, 0.12, 0.06, -0.45 + i * 0.1 + j * 0.3, 0.84 + i * 0.06, 0.0, L.TERRA if j % 2 else L.CREAM, 8, 0.07)
	L.cb(h, 0.12, 0.06, 0.5, 0.84, 0.1, L.BLUE, 8, 0.07)
	L.b(h, Vector3(1.4, 0.05, 0.6), Vector3(0, 0.12, 0), L.PLANK)
