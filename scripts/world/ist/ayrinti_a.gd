class_name AyrintiA
extends RefCounted
## Ayrıntı kitaplığı, bölüm A: çarşı, mutfak, liman ve çiftlik eşyası.
## ITEMS: [id, ad, en, yükseklik, boy, çarpışma ("kutu" | "yok" | "ozel"), grup]

const L := preload("res://scripts/world/ist/ayrinti_lib.gd")

const ITEMS := [
	["tezgah", "Çarşı tezgâhı", 2.0, 1.0, 0.8, "kutu", "carsi"],
	["tente", "Bez tente", 3.0, 2.6, 2.4, "ozel", "carsi"],
	["amfora", "Amfora", 0.4, 0.95, 0.4, "kutu", "kap"],
	["pithos", "Pithos (büyük küp)", 0.9, 1.3, 0.9, "kutu", "kap"],
	["fici", "Fıçı", 0.6, 0.85, 0.6, "kutu", "kap"],
	["sepet", "Hasır sepet", 0.55, 0.45, 0.55, "kutu", "kap"],
	["cuval", "Çuval", 0.5, 0.7, 0.4, "kutu", "kap"],
	["terazi", "Kefeli terazi", 0.6, 1.0, 0.3, "yok", "carsi"],
	["balik_agi", "Balık ağı", 2.4, 0.9, 1.0, "yok", "liman"],
	["ag_sehpasi", "Ağ sehpası", 2.2, 1.6, 0.6, "ozel", "liman"],
	["kayik", "Çekilmiş kayık", 4.2, 1.1, 1.6, "kutu", "liman"],
	["kurek", "Kürek", 0.15, 2.0, 0.15, "yok", "liman"],
	["capa", "Çapa", 0.9, 1.2, 0.3, "yok", "liman"],
	["camasir_ipi", "Çamaşır ipi", 3.4, 2.2, 0.2, "ozel", "ev"],
	["kumes", "Kümes", 1.4, 1.3, 1.0, "kutu", "ciftlik"],
	["guvercinlik", "Güvercinlik", 1.0, 2.8, 1.0, "ozel", "ciftlik"],
	["ari_kovani", "Arı kovanı", 0.5, 0.75, 0.5, "kutu", "ciftlik"],
	["yalak", "Yalak", 1.6, 0.6, 0.5, "kutu", "ciftlik"],
	["kuyu", "Kuyu ve çıkrık", 1.4, 2.0, 1.0, "ozel", "su"],
	["su_dolabi", "Su dolabı", 2.2, 2.4, 0.8, "ozel", "su"],
	["el_arabasi", "El arabası", 1.5, 0.8, 0.6, "kutu", "tasima"],
	["kagni", "Kağnı", 3.0, 1.6, 1.6, "ozel", "tasima"],
	["esek_semeri", "Eşek semeri yükü", 1.1, 0.9, 0.6, "kutu", "tasima"],
	["odun_yigini", "Odun yığını", 2.0, 1.2, 0.9, "kutu", "yigin"],
	["tas_yigini", "Taş yığını", 1.6, 0.9, 1.4, "kutu", "yigin"],
	["kirec_ocagi", "Kireç ocağı", 2.2, 1.5, 2.2, "kutu", "yapi"],
	["iskele", "Ahşap iskele", 6.0, 0.9, 1.6, "ozel", "liman"],
	["merdiven", "Ahşap merdiven", 0.5, 3.0, 0.9, "ozel", "yapi"],
	["sandik_yigini", "Sandık yığını (basamak)", 1.4, 1.0, 1.9, "ozel", "yigin"],
	["firin", "Ekmek fırını", 2.0, 2.0, 1.6, "kutu", "mutfak"],
	["tandir", "Tandır", 1.0, 0.9, 1.0, "kutu", "mutfak"],
	["degirmen_tasi", "Değirmen taşı", 1.2, 0.5, 1.2, "kutu", "mutfak"],
	["zeytin_presi", "Zeytin presi", 1.8, 1.8, 1.0, "ozel", "mutfak"],
	["sarap_fici", "Şarap fıçısı (kızakta)", 1.2, 1.3, 0.9, "kutu", "kap"],
	["uzum_teknesi", "Üzüm teknesi", 1.8, 0.7, 1.4, "kutu", "kap"],
	["tezgah_kepengi", "Tezgâh kepengi", 2.2, 2.2, 0.15, "kutu", "carsi"],
	["tabela", "Yunanca harfli tabela", 1.2, 2.4, 0.3, "ozel", "carsi"],
	["ikona_nisi", "İkona nişi", 0.8, 1.9, 0.5, "kutu", "kutsal"],
	["kandil", "Asma kandil (direkli)", 0.7, 2.4, 0.4, "ozel", "kutsal"],
	["mum_sehpasi", "Mum sehpası", 0.7, 1.2, 0.5, "kutu", "kutsal"],
	["hacli_tas", "Haçlı taş", 0.6, 1.5, 0.3, "kutu", "kutsal"],
	["lahit", "Lahit", 2.2, 1.0, 1.0, "kutu", "kutsal"],
	["sutun_baslik", "Devrik sütun başlığı", 1.2, 0.8, 1.2, "kutu", "harabe"],
	["mermer_parca", "Mermer parçaları", 1.8, 0.4, 1.4, "yok", "harabe"],
	["cit", "Çit", 3.0, 1.2, 0.2, "kutu", "bahce"],
	["bahce_kapisi", "Bahçe kapısı", 1.6, 1.8, 0.2, "ozel", "bahce"],
	["asma_cardagi", "Asma çardağı", 3.0, 2.6, 3.0, "ozel", "bahce"],
	["saksi", "Saksı", 0.4, 0.7, 0.4, "kutu", "bahce"],
	["cicekli_pencere", "Çiçekli pencere", 1.2, 1.9, 0.5, "kutu", "ev"],
]

# ----------------------------------------------------------------------------------------------------------------
static func build_tezgah(h: Node3D) -> void:
	var cl := L.RED
	L.bb(h, Vector3(2.0, 0.07, 0.8), 0, 0.88, 0, L.PLANK, 0, "wood")
	for sx in [-0.9, 0.9]:
		for sz in [-0.32, 0.32]:
			L.bb(h, Vector3(0.08, 0.88, 0.08), sx, 0, sz, L.WOOD_D)
	L.bb(h, Vector3(1.9, 0.03, 0.5), 0, 0.84, 0.0, L.WOOD_D)           # alt raf
	L.bb(h, Vector3(0.1, 0.5, 0.05), 0, 0.4, 0.38, L.WOOD_D)
	L.bb(h, Vector3(1.0, 0.012, 0.84), -0.2, 0.955, 0, cl)              # örtü
	L.bb(h, Vector3(0.9, 0.04, 0.84), -0.2, 0.0, 0, cl)                 # yok sayılacak kadar ince: sarkan kenar
	for i in 5:
		L.s(h, 0.07, Vector3(0.45 + i * 0.1, 1.0, -0.1 + (i % 2) * 0.15), L.TERRA if i % 2 == 0 else L.GREEN)
	L.bb(h, Vector3(0.3, 0.12, 0.25), 0.75, 0.955, 0.1, L.SACK)


static func build_tente(h: Node3D) -> void:
	for sx in [-1.4, 1.4]:
		for sz in [-1.1, 1.1]:
			L.cb(h, 0.05, 2.6 if sz < 0 else 2.2, sx, 0, sz, L.WOOD_D, 5)
			L.col_box(h, Vector3(0.12, 2.2, 0.12), Vector3(sx, 1.1, sz))
	L.b(h, Vector3(3.1, 0.04, 2.5), Vector3(0, 2.45, 0), L.LINEN, Vector3(-9, 0, 0))
	for i in 5:
		L.b(h, Vector3(0.28, 0.045, 2.5), Vector3(-1.32 + i * 0.66, 2.455, 0), L.RED, Vector3(-9, 0, 0))
	L.b(h, Vector3(3.1, 0.25, 0.04), Vector3(0, 2.2, 1.24), L.RED)
	L.b(h, Vector3(3.1, 0.07, 0.1), Vector3(0, 2.5, -1.24), L.ROPE)


static func build_amfora(h: Node3D) -> void:
	L.cb(h, 0.07, 0.1, 0, 0, 0, L.TERRA_D, 6)
	L.s(h, 0.5, Vector3(0, 0.42, 0), L.TERRA, Vector3(0.38, 0.62, 0.38), 9)
	L.cb(h, 0.07, 0.25, 0, 0.62, 0, L.TERRA, 6, 0.09)
	L.cb(h, 0.1, 0.04, 0, 0.9, 0, L.TERRA_D, 7)
	for sx in [-1, 1]:
		L.b(h, Vector3(0.03, 0.22, 0.03), Vector3(sx * 0.15, 0.72, 0), L.TERRA_D)
	L.cb(h, 0.2, 0.01, 0, 0.58, 0, L.TERRA_D, 9)


static func build_pithos(h: Node3D) -> void:
	L.cb(h, 0.3, 0.1, 0, 0, 0, L.TERRA_D, 9)
	L.s(h, 0.5, Vector3(0, 0.62, 0), L.TERRA, Vector3(0.88, 1.0, 0.88), 11)
	L.cb(h, 0.3, 0.2, 0, 1.1, 0, L.TERRA, 9, 0.28)
	L.cb(h, 0.38, 0.06, 0, 1.28, 0, L.TERRA_D, 10, 0.3)
	for y in [0.45, 0.8]:
		L.cb(h, 0.435, 0.04, 0, y, 0, L.TERRA_D, 10)


static func build_fici(h: Node3D) -> void:
	L.cb(h, 0.27, 0.85, 0, 0, 0, L.WOOD, 10, 0.27, "wood")
	L.s(h, 0.5, Vector3(0, 0.43, 0), L.WOOD, Vector3(0.62, 0.7, 0.62), 10)
	for y in [0.1, 0.4, 0.72]:
		L.cb(h, 0.31 if y == 0.4 else 0.28, 0.035, 0, y, 0, L.IRON, 10)
	L.cb(h, 0.22, 0.02, 0, 0.84, 0, L.WOOD_D, 10)


static func build_sepet(h: Node3D) -> void:
	L.cb(h, 0.27, 0.45, 0, 0, 0, L.STRAW, 9, 0.22)
	L.cb(h, 0.23, 0.02, 0, 0.44, 0, L.HAY.darkened(0.2), 9)
	for y in [0.12, 0.28]:
		L.cb(h, 0.255 - y * 0.1, 0.03, 0, y, 0, L.STRAW.darkened(0.15), 9)
	for i in 4:
		L.s(h, 0.07, Vector3(-0.1 + (i % 2) * 0.2, 0.46, -0.08 + (i / 2) * 0.16), L.RED if i % 2 == 0 else L.OCHRE)


static func build_cuval(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.28, 0), L.SACK, Vector3(0.5, 0.56, 0.4), 8)
	L.cb(h, 0.14, 0.12, 0, 0.5, 0, L.SACK.darkened(0.1), 7, 0.1)
	L.bb(h, Vector3(0.18, 0.025, 0.02), 0, 0.5, 0.14, L.ROPE)
	L.bb(h, Vector3(0.24, 0.03, 0.2), 0, 0.15, 0.19, L.SACK.lightened(0.1))


static func build_terazi(h: Node3D) -> void:
	L.cb(h, 0.02, 0.9, 0, 0, 0, L.WOOD_D, 5)
	L.cb(h, 0.1, 0.03, 0, 0, 0, L.WOOD_D, 7)
	L.b(h, Vector3(0.6, 0.025, 0.03), Vector3(0, 0.92, 0), L.GOLD.darkened(0.2))
	for sx in [-0.28, 0.28]:
		L.b(h, Vector3(0.012, 0.3, 0.012), Vector3(sx, 0.77, 0), L.IRON)
		L.cb(h, 0.1, 0.02, sx, 0.6, 0, L.GOLD.darkened(0.2), 8)
	L.s(h, 0.05, Vector3(0.28, 0.65, 0), L.IRON)


static func build_balik_agi(h: Node3D) -> void:
	# zemine ve bir kazığa serilmiş ağ (yürünür, düşük)
	L.b(h, Vector3(2.2, 0.06, 0.9), Vector3(0, 0.03, 0.1), L.ROPE.darkened(0.25), Vector3(0, 8, 0))
	L.b(h, Vector3(1.8, 0.06, 0.4), Vector3(0.1, 0.07, 0.2), L.ROPE, Vector3(0, -12, 0))
	L.b(h, Vector3(0.14, 0.14, 0.14), Vector3(-0.8, 0.1, 0.0), L.STONE_D)
	for i in 6:
		L.b(h, Vector3(0.1, 0.1, 0.18), Vector3(-1.0 + i * 0.4, 0.1, -0.2 + (i % 2) * 0.5), L.WOOD_L)
	L.cb(h, 0.04, 0.9, 1.15, 0, -0.3, L.WOOD_D, 5)
	L.b(h, Vector3(0.9, 0.5, 0.04), Vector3(1.0, 0.55, -0.3), L.ROPE.darkened(0.2), Vector3(0, 0, -22))


static func build_ag_sehpasi(h: Node3D) -> void:
	for sx in [-1.0, 1.0]:
		L.rod(h, Vector3(sx, 0, -0.25), Vector3(sx, 1.55, 0), 0.08, L.WOOD_D)
		L.rod(h, Vector3(sx, 0, 0.25), Vector3(sx, 1.55, 0), 0.08, L.WOOD_D)
		L.col_box(h, Vector3(0.12, 1.5, 0.5), Vector3(sx, 0.75, 0))
	L.b(h, Vector3(2.2, 0.08, 0.08), Vector3(0, 1.55, 0), L.WOOD)
	L.b(h, Vector3(1.9, 1.2, 0.05), Vector3(0, 0.92, 0.0), L.ROPE.darkened(0.25))
	L.b(h, Vector3(1.4, 0.4, 0.07), Vector3(0.1, 0.5, 0.03), L.ROPE)
	for i in 5:
		L.b(h, Vector3(0.09, 0.09, 0.09), Vector3(-0.8 + i * 0.4, 0.3, 0.07), L.WOOD_L)


static func build_kayik(h: Node3D) -> void:
	# karaya çekilmiş, burnu yukarı, yamuk yatan balıkçı kayığı; içine konan tahta oturaklar
	var hull := L.WOOD.darkened(0.1)
	L.sol(h, Vector3(1.3, 0.12, 3.6), Vector3(0, 0.38, 0), hull, Vector3.ZERO, "wood")
	for sx in [-1, 1]:
		L.sol(h, Vector3(0.1, 0.5, 3.3), Vector3(sx * 0.62, 0.7, 0), hull, Vector3(0, 0, sx * 6), "wood")
		L.b(h, Vector3(0.12, 0.08, 3.4), Vector3(sx * 0.7, 0.98, 0), L.WOOD_L, Vector3(0, 0, sx * 6))
	L.sol(h, Vector3(1.0, 0.55, 0.12), Vector3(0, 0.75, -1.75), hull, Vector3(-18, 0, 0))
	L.b(h, Vector3(0.9, 0.5, 0.12), Vector3(0, 0.95, 1.85), hull, Vector3(18, 0, 0))
	L.b(h, Vector3(0.12, 0.35, 0.2), Vector3(0, 1.2, -1.95), L.RED)
	for z in [-0.7, 0.5]:
		L.b(h, Vector3(1.2, 0.07, 0.3), Vector3(0, 0.78, z), L.PLANK)
	# kıç ve baş için dengeleyen takozlar
	L.bb(h, Vector3(0.9, 0.3, 0.3), 0, 0, 1.2, L.WOOD_D)
	L.bb(h, Vector3(0.9, 0.3, 0.3), 0, 0, -1.2, L.WOOD_D)
	L.rod(h, Vector3(-0.3, 0.8, 0.3), Vector3(0.45, 1.0, 1.6), 0.06, L.WOOD_L)
	L.b(h, Vector3(0.5, 0.05, 0.9), Vector3(0, 0.82, 0.9), L.ROPE)


static func build_kurek(h: Node3D) -> void:
	L.rod(h, Vector3(0, 0, 0), Vector3(0.15, 2.0, 0.0), 0.05, L.WOOD_L)
	L.b(h, Vector3(0.22, 0.5, 0.025), Vector3(-0.02, 0.28, 0.0), L.PLANK, Vector3(0, 0, -4))


static func build_capa(h: Node3D) -> void:
	L.bb(h, Vector3(0.08, 1.1, 0.08), 0, 0.0, 0, L.IRON)
	L.b(h, Vector3(0.7, 0.07, 0.07), Vector3(0, 0.95, 0), L.WOOD_D)
	L.b(h, Vector3(0.9, 0.07, 0.07), Vector3(0, 0.15, 0), L.IRON, Vector3(0, 0, 0))
	for sx in [-1, 1]:
		L.b(h, Vector3(0.08, 0.35, 0.07), Vector3(sx * 0.42, 0.25, 0), L.IRON, Vector3(0, 0, sx * -30))
	L.b(h, Vector3(0.18, 0.18, 0.06), Vector3(0, 1.1, 0), L.IRON_L)


static func build_camasir_ipi(h: Node3D) -> void:
	for sx in [-1.7, 1.7]:
		L.cb(h, 0.05, 2.2, sx, 0, 0, L.WOOD_D, 6)
		L.col_box(h, Vector3(0.12, 2.2, 0.12), Vector3(sx, 1.1, 0))
	L.b(h, Vector3(3.4, 0.015, 0.015), Vector3(0, 2.0, 0), L.ROPE)
	var cs := [L.LINEN, L.BLUE, L.RED, L.OCHRE]
	for i in 4:
		L.b(h, Vector3(0.5, 0.75 - i * 0.05, 0.02), Vector3(-1.2 + i * 0.75, 1.62, 0.0), cs[i])
		L.b(h, Vector3(0.05, 0.05, 0.05), Vector3(-1.2 + i * 0.75 - 0.15, 2.0, 0), L.WOOD_D)


static func build_kumes(h: Node3D) -> void:
	L.sol(h, Vector3(1.4, 0.7, 1.0), Vector3(0, 0.55, 0), L.PLANK, Vector3.ZERO, "wood")
	for sx in [-0.55, 0.55]:
		L.bb(h, Vector3(0.1, 0.35, 0.1), sx, 0, 0.35, L.WOOD_D)
		L.bb(h, Vector3(0.1, 0.35, 0.1), sx, 0, -0.35, L.WOOD_D)
	L.pr(h, Vector3(1.6, 0.4, 1.2), Vector3(0, 1.1, 0), L.TERRA_D, Vector3(0, 0, 0))
	L.b(h, Vector3(0.3, 0.3, 0.03), Vector3(0.3, 0.5, 0.51), L.BLACK)
	L.b(h, Vector3(0.1, 0.4, 0.03), Vector3(0.6, 0.5, 0.52), L.WOOD_D, Vector3(0, 0, 20))
	L.b(h, Vector3(0.7, 0.04, 0.2), Vector3(0.3, 0.2, 0.7), L.PLANK, Vector3(-18, 0, 0))


static func build_guvercinlik(h: Node3D) -> void:
	L.cb(h, 0.08, 1.9, -0.35, 0, -0.35, L.WOOD_D, 6)
	L.cb(h, 0.08, 1.9, 0.35, 0, -0.35, L.WOOD_D, 6)
	L.cb(h, 0.08, 1.9, -0.35, 0, 0.35, L.WOOD_D, 6)
	L.cb(h, 0.08, 1.9, 0.35, 0, 0.35, L.WOOD_D, 6)
	L.col_box(h, Vector3(0.9, 1.9, 0.9), Vector3(0, 0.95, 0))
	L.b(h, Vector3(0.7, 1.7, 0.7), Vector3(0, 0.9, 0), L.WOOD_D.darkened(0.1))
	L.b(h, Vector3(1.0, 0.8, 1.0), Vector3(0, 2.2, 0), L.PLANK, Vector3.ZERO, "wood")
	L.col_box(h, Vector3(1.0, 0.8, 1.0), Vector3(0, 2.2, 0))
	L.pr(h, Vector3(1.3, 0.55, 1.3), Vector3(0, 2.85, 0), L.TERRA_D)
	L.col_box(h, Vector3(1.0, 0.1, 1.0), Vector3(0, 2.65, 0))
	for z in [-0.51, 0.51]:
		for i in 3:
			L.b(h, Vector3(0.14, 0.14, 0.03), Vector3(-0.28 + i * 0.28, 2.2, z), L.BLACK)
			L.b(h, Vector3(0.2, 0.03, 0.12), Vector3(-0.28 + i * 0.28, 2.1, z * 1.1), L.WOOD_D)


static func build_ari_kovani(h: Node3D) -> void:
	for i in 4:
		L.cb(h, 0.2 - i * 0.015, 0.14, 0, 0.1 + i * 0.14, 0, L.STRAW if i % 2 == 0 else L.HAY, 9)
	L.s(h, 0.5, Vector3(0, 0.7, 0), L.STRAW, Vector3(0.28, 0.14, 0.28), 8)
	L.b(h, Vector3(0.2, 0.05, 0.03), Vector3(0, 0.12, 0.2), L.BLACK)
	L.bb(h, Vector3(0.4, 0.12, 0.4), 0, 0, 0, L.WOOD_D)
	L.bb(h, Vector3(0.1, 0.12, 0.1), -0.2, 0, -0.2, L.WOOD_D)


static func build_yalak(h: Node3D) -> void:
	L.bb(h, Vector3(1.6, 0.08, 0.5), 0, 0.12, 0, L.WOOD_D)
	L.bb(h, Vector3(1.6, 0.4, 0.06), 0, 0.14, 0.22, L.WOOD)
	L.bb(h, Vector3(1.6, 0.4, 0.06), 0, 0.14, -0.22, L.WOOD)
	L.bb(h, Vector3(0.06, 0.4, 0.5), -0.77, 0.14, 0, L.WOOD)
	L.bb(h, Vector3(0.06, 0.4, 0.5), 0.77, 0.14, 0, L.WOOD)
	L.b(h, Vector3(1.4, 0.03, 0.36), Vector3(0, 0.46, 0), L.WATER)
	for sx in [-0.7, 0.7]:
		L.bb(h, Vector3(0.12, 0.14, 0.45), sx, 0, 0, L.WOOD_D)


static func build_kuyu(h: Node3D) -> void:
	L.sol(h, Vector3(1.0, 0.8, 1.0), Vector3(0, 0.4, 0), L.STONE, Vector3.ZERO, "ashlar")
	L.b(h, Vector3(0.64, 0.02, 0.64), Vector3(0, 0.81, 0), L.BLACK)
	L.sol(h, Vector3(1.12, 0.1, 1.12), Vector3(0, 0.05, 0), L.STONE_D)
	for sx in [-0.5, 0.5]:
		L.cb(h, 0.05, 1.5, sx, 0.8, 0, L.WOOD_D, 6)
		L.col_box(h, Vector3(0.12, 1.5, 0.12), Vector3(sx, 1.55, 0))
	L.c(h, 0.07, 1.1, Vector3(0, 1.85, 0), L.WOOD, Vector3(0, 0, 90), 6)
	L.b(h, Vector3(0.05, 0.3, 0.05), Vector3(0.58, 1.75, 0), L.WOOD_D)
	L.b(h, Vector3(0.28, 0.04, 0.04), Vector3(0.7, 1.6, 0), L.WOOD_D)
	L.b(h, Vector3(0.012, 0.8, 0.012), Vector3(0.0, 1.35, 0.0), L.ROPE)
	L.cb(h, 0.1, 0.18, 0, 0.82, 0.28, L.WOOD, 7, 0.08)
	L.pr(h, Vector3(1.4, 0.3, 0.9), Vector3(0, 2.1, 0), L.TERRA_D)


static func build_su_dolabi(h: Node3D) -> void:
	# dolap: yan yana iki ayak, ortada kovalı çark
	for sx in [-0.9, 0.9]:
		L.sol(h, Vector3(0.14, 2.2, 0.8), Vector3(sx, 1.1, 0), L.WOOD_D, Vector3.ZERO, "wood")
	L.c(h, 1.0, 0.12, Vector3(0, 1.4, 0), L.WOOD, Vector3(0, 0, 90), 12, -1.0, "wood")
	for i in 8:
		var a := i * TAU / 8.0
		L.c(h, 0.11, 0.24, Vector3(0, 1.4 + sin(a) * 0.9, cos(a) * 0.9), L.TERRA, Vector3(0, 0, 90), 6, 0.08)
	L.b(h, Vector3(2.0, 0.08, 0.08), Vector3(0, 1.4, 0), L.WOOD_D)
	L.sol(h, Vector3(1.6, 0.35, 0.6), Vector3(0, 0.18, 0.0), L.STONE_D, Vector3.ZERO, "ashlar")
	L.b(h, Vector3(1.2, 0.03, 0.4), Vector3(0, 0.37, 0), L.WATER)


static func build_el_arabasi(h: Node3D) -> void:
	L.bb(h, Vector3(0.9, 0.08, 0.6), 0.1, 0.4, 0, L.PLANK, 0, "wood")
	L.bb(h, Vector3(0.9, 0.2, 0.05), 0.1, 0.48, 0.3, L.WOOD)
	L.bb(h, Vector3(0.9, 0.2, 0.05), 0.1, 0.48, -0.3, L.WOOD)
	L.bb(h, Vector3(0.05, 0.25, 0.6), -0.35, 0.48, 0, L.WOOD)
	L.bb(h, Vector3(0.05, 0.25, 0.6), 0.55, 0.48, 0, L.WOOD)
	L.c(h, 0.3, 0.06, Vector3(0.62, 0.3, 0), L.WOOD_D, Vector3(90, 0, 0), 10)
	for sz in [-1, 1]:
		L.b(h, Vector3(1.0, 0.05, 0.05), Vector3(-0.55, 0.45, sz * 0.2), L.WOOD_D, Vector3(0, 0, 7))
	L.b(h, Vector3(0.05, 0.05, 0.5), Vector3(-1.0, 0.5, 0), L.WOOD_L)
	L.bb(h, Vector3(0.05, 0.3, 0.05), -0.6, 0.0, 0.2, L.WOOD_D)
	L.bb(h, Vector3(0.05, 0.3, 0.05), -0.6, 0.0, -0.2, L.WOOD_D)
	L.s(h, 0.18, Vector3(0.2, 0.62, 0), L.SACK, Vector3(1.4, 0.8, 1.2))


static func build_kagni(h: Node3D) -> void:
	L.sol(h, Vector3(2.0, 0.1, 1.2), Vector3(0.0, 0.85, 0), L.PLANK, Vector3.ZERO, "wood")
	for sz in [-0.6, 0.6]:
		L.b(h, Vector3(2.0, 0.35, 0.06), Vector3(0, 1.05, sz), L.WOOD)
		L.c(h, 0.5, 0.1, Vector3(0.2, 0.5, sz * 1.3), L.WOOD_D, Vector3(90, 0, 0), 12, -1.0, "wood")
		L.c(h, 0.08, 0.12, Vector3(0.2, 0.5, sz * 1.3), L.IRON, Vector3(90, 0, 0), 6)
	L.c(h, 0.04, 1.5, Vector3(0.2, 0.5, 0), L.WOOD_D, Vector3(90, 0, 0), 6)
	L.b(h, Vector3(2.0, 0.35, 0.06), Vector3(0, 1.05, 0.6), L.WOOD)
	L.b(h, Vector3(0.06, 0.35, 1.2), Vector3(-1.0, 1.05, 0), L.WOOD)
	L.b(h, Vector3(0.06, 0.35, 1.2), Vector3(1.0, 1.05, 0), L.WOOD)
	L.b(h, Vector3(2.0, 0.05, 0.07), Vector3(1.95, 0.85, 0.3), L.WOOD_D)
	L.b(h, Vector3(2.0, 0.05, 0.07), Vector3(1.95, 0.85, -0.3), L.WOOD_D)
	L.b(h, Vector3(0.08, 0.08, 0.7), Vector3(2.9, 0.85, 0), L.WOOD_D)
	L.b(h, Vector3(0.3, 0.4, 1.6), Vector3(0.2, 0.62, 0), L.WOOD_D)
	L.b(h, Vector3(1.4, 0.35, 0.9), Vector3(-0.05, 1.3, 0), L.HAY)


static func build_esek_semeri(h: Node3D) -> void:
	# yere konmuş yük: iki torba, semer ve ip
	L.s(h, 0.5, Vector3(-0.28, 0.4, 0), L.SACK, Vector3(0.5, 0.8, 0.55), 8)
	L.s(h, 0.5, Vector3(0.28, 0.4, 0), L.SACK.darkened(0.08), Vector3(0.5, 0.78, 0.55), 8)
	L.bb(h, Vector3(0.9, 0.12, 0.28), 0, 0.72, 0, L.RED)
	L.bb(h, Vector3(0.7, 0.08, 0.6), 0, 0.82, 0, L.WOOD_D)
	L.b(h, Vector3(1.0, 0.03, 0.03), Vector3(0, 0.5, 0.28), L.ROPE)
	L.b(h, Vector3(1.0, 0.03, 0.03), Vector3(0, 0.3, 0.28), L.ROPE)


static func build_odun_yigini(h: Node3D) -> void:
	for row in 4:
		var n := 5 - row
		for i in n:
			var x := -0.85 + (6 - n) * 0.15 + i * 0.3
			L.c(h, 0.13, 0.9, Vector3(x, 0.14 + row * 0.24, 0), L.WOOD if (i + row) % 2 == 0 else L.WOOD_L, Vector3(90, 0, 0), 5)
	# ucu görünen kesitler
	for i in 4:
		L.c(h, 0.1, 0.02, Vector3(-0.6 + i * 0.4, 0.14, 0.46), L.WOOD_L, Vector3(90, 0, 0), 7)
	L.bb(h, Vector3(0.06, 1.0, 0.06), -1.0, 0, 0.0, L.WOOD_D)
	L.bb(h, Vector3(0.06, 1.0, 0.06), 1.0, 0, 0.0, L.WOOD_D)


static func build_tas_yigini(h: Node3D) -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 7
	var cs := [L.STONE, L.STONE_D, L.STONE_L]
	for i in 11:
		var r := 0.3 + rnd.randf() * 0.2
		var a := rnd.randf() * TAU
		var d := rnd.randf() * 0.55
		var y := 0.15 + maxf(0.0, 0.5 - d) * 0.9
		L.b(h, Vector3(r * 1.6, r * 1.1, r * 1.3), Vector3(cos(a) * d, y, sin(a) * d), cs[i % 3], Vector3(rnd.randf() * 20, rnd.randf() * 90, rnd.randf() * 20), "rubble")


static func build_kirec_ocagi(h: Node3D) -> void:
	L.sol(h, Vector3(2.2, 1.0, 2.2), Vector3(0, 0.5, 0), L.STONE_L, Vector3.ZERO, "rubble")
	L.b(h, Vector3(1.5, 0.05, 1.5), Vector3(0, 1.02, 0), L.CREAM)
	L.b(h, Vector3(1.0, 0.3, 1.0), Vector3(0, 1.2, 0), L.CREAM.darkened(0.08), Vector3(0, 15, 0))
	L.pr(h, Vector3(0.9, 0.3, 0.9), Vector3(0, 1.45, 0), L.STONE_L)
	L.b(h, Vector3(0.7, 0.55, 0.05), Vector3(0, 0.45, 1.12), L.BLACK)
	L.sol(h, Vector3(0.9, 0.3, 0.6), Vector3(0, 0.15, 1.5), L.STONE_D)
	L.bb(h, Vector3(0.6, 0.15, 0.5), -1.3, 0, 1.3, L.CREAM)


static func build_iskele(h: Node3D) -> void:
	# su kenarındaki ahşap iskele: kalın kazıklar üstünde güverte, ucunda bağlama babaları
	L.sol(h, Vector3(6.0, 0.12, 1.6), Vector3(0, 0.78, 0), L.PLANK, Vector3.ZERO, "wood")
	for i in 5:
		L.cb(h, 0.1, 0.78, -2.7 + i * 1.35, 0, 0.7, L.WOOD_D, 6)
		L.cb(h, 0.1, 0.78, -2.7 + i * 1.35, 0, -0.7, L.WOOD_D, 6)
	for i in 12:
		L.b(h, Vector3(0.02, 0.13, 1.6), Vector3(-2.75 + i * 0.5, 0.78, 0), L.WOOD_D)
	for sx in [-2.8, 2.8]:
		L.cb(h, 0.1, 0.4, sx, 0.84, 0.7, L.WOOD_D, 6, 0.08)
	L.b(h, Vector3(0.02, 0.02, 3.0), Vector3(2.8, 0.92, 2.0), L.ROPE, Vector3(0, 20, 0))
	L.b(h, Vector3(1.0, 0.25, 0.4), Vector3(-1.0, 0.98, -0.3), L.SACK)


static func build_merdiven(h: Node3D) -> void:
	# duvara dayalı ahşap el merdiveni: 3 m, 1,0 m aralıkla hafif eğik, basamaklar 0,3 m
	var top := Vector3(0, 3.0, -0.4)
	var bot := Vector3(0, 0, 0.5)
	for sx in [-0.25, 0.25]:
		L.rod(h, bot + Vector3(sx, 0, 0), top + Vector3(sx, 0, 0), 0.07, L.WOOD)
	for i in 10:
		var t := (i + 0.5) / 10.0
		L.b(h, Vector3(0.5, 0.05, 0.05), bot.lerp(top, t), L.WOOD_L)


static func build_sandik_yigini(h: Node3D) -> void:
	# 0,5 m ve 1,0 m basamaklı sandık yığını: zıplamadan çıkmak için standart basamak
	var s1 := Vector3(0.9, 0.5, 0.9)
	L.sol(h, s1, Vector3(0, 0.25, 0.5), L.WOOD, Vector3.ZERO, "wood")
	L.sol(h, Vector3(0.9, 1.0, 0.9), Vector3(0, 0.5, -0.5), L.WOOD_L, Vector3.ZERO, "wood")
	L.b(h, Vector3(0.94, 0.04, 0.94), Vector3(0, 0.52, 0.5), L.WOOD_D)
	L.b(h, Vector3(0.94, 0.04, 0.94), Vector3(0, 0.5, -0.5), L.WOOD_D)
	L.b(h, Vector3(0.94, 0.04, 0.94), Vector3(0, 1.02, -0.5), L.WOOD_D)
	for sx in [-0.4, 0.4]:
		L.b(h, Vector3(0.05, 0.5, 0.94), Vector3(sx, 0.25, 0.5), L.WOOD_D)
		L.b(h, Vector3(0.05, 1.0, 0.94), Vector3(sx, 0.5, -0.5), L.WOOD_D)
	L.b(h, Vector3(0.3, 0.12, 0.2), Vector3(0.2, 0.56, 0.5), L.SACK)
	L.b(h, Vector3(0.3, 0.2, 0.3), Vector3(0.1, 1.12, -0.5), L.RED.darkened(0.2))


static func build_firin(h: Node3D) -> void:
	L.sol(h, Vector3(2.0, 0.7, 1.6), Vector3(0, 0.35, 0), L.BRICK, Vector3.ZERO, "brick")
	L.s(h, 0.5, Vector3(0, 0.7, 0), L.BRICK.darkened(0.05), Vector3(1.9, 1.2, 1.5), 12)
	L.col_box(h, Vector3(1.8, 1.0, 1.4), Vector3(0, 1.1, 0))
	L.b(h, Vector3(0.8, 0.5, 0.1), Vector3(0, 0.95, 0.74), L.BLACK)
	L.b(h, Vector3(0.95, 0.07, 0.15), Vector3(0, 1.22, 0.78), L.STONE_D)
	L.cb(h, 0.13, 0.9, 0.5, 1.2, -0.5, L.STONE_D, 6, 0.1)
	L.bb(h, Vector3(1.2, 0.1, 0.6), 0, 0.5, 1.05, L.PLANK)
	L.bb(h, Vector3(0.1, 0.5, 0.1), -0.5, 0, 1.2, L.WOOD_D)
	L.bb(h, Vector3(0.1, 0.5, 0.1), 0.5, 0, 1.2, L.WOOD_D)
	for i in 3:
		L.s(h, 0.14, Vector3(-0.35 + i * 0.35, 0.65, 1.05), L.TERRA, Vector3(1.0, 0.45, 1.2), 7)


static func build_tandir(h: Node3D) -> void:
	L.s(h, 0.5, Vector3(0, 0.42, 0), L.TERRA_D, Vector3(0.95, 0.85, 0.95), 10)
	L.cb(h, 0.38, 0.12, 0, 0.82, 0, L.TERRA, 10, 0.3)
	L.cb(h, 0.28, 0.02, 0, 0.93, 0, L.BLACK, 9)
	L.b(h, Vector3(0.3, 0.2, 0.05), Vector3(0, 0.12, 0.46), L.BLACK)
	L.cb(h, 0.52, 0.1, 0, 0, 0, L.STONE_D, 10)


static func build_degirmen_tasi(h: Node3D) -> void:
	L.cb(h, 0.6, 0.22, 0, 0.0, 0, L.STONE, 14, 0.6, "rubble")
	L.cb(h, 0.58, 0.2, 0, 0.24, 0, L.STONE_L, 14, 0.55, "rubble")
	L.cb(h, 0.09, 0.1, 0, 0.44, 0, L.IRON, 6)
	L.b(h, Vector3(0.8, 0.06, 0.06), Vector3(0.3, 0.5, 0), L.WOOD_D)


static func build_zeytin_presi(h: Node3D) -> void:
	for sx in [-0.6, 0.6]:
		L.sol(h, Vector3(0.2, 1.8, 0.3), Vector3(sx, 0.9, 0), L.WOOD, Vector3.ZERO, "wood")
	L.sol(h, Vector3(1.4, 0.2, 0.3), Vector3(0, 1.7, 0), L.WOOD_D, Vector3.ZERO, "wood")
	L.cb(h, 0.05, 1.0, 0, 0.7, 0, L.WOOD_L, 6)
	L.b(h, Vector3(1.0, 0.1, 0.1), Vector3(0, 1.45, 0), L.WOOD_L)
	L.cb(h, 0.35, 0.3, 0, 0.0, 0, L.TERRA, 9)
	L.cb(h, 0.3, 0.05, 0, 0.3, 0, L.GREEN_D, 9)
	L.sol(h, Vector3(1.8, 0.35, 0.9), Vector3(0, 0.18, 0.1), L.STONE, Vector3.ZERO, "rubble")
	L.cb(h, 0.12, 0.2, 0.6, 0.35, 0.3, L.TERRA, 7)


static func build_sarap_fici(h: Node3D) -> void:
	L.bb(h, Vector3(0.12, 0.3, 0.9), -0.4, 0, 0, L.WOOD_D)
	L.bb(h, Vector3(0.12, 0.3, 0.9), 0.4, 0, 0, L.WOOD_D)
	L.c(h, 0.5, 1.1, Vector3(0, 0.82, 0), L.WOOD, Vector3(0, 0, 90), 12, 0.5, "wood")
	L.s(h, 0.5, Vector3(0, 0.82, 0), L.WOOD, Vector3(1.0, 1.0, 1.0) * 0.0 + Vector3(1.1, 1.0, 1.0), 4)
	for x in [-0.4, 0.0, 0.4]:
		L.c(h, 0.53, 0.04, Vector3(x, 0.82, 0), L.IRON, Vector3(0, 0, 90), 12)
	L.cb(h, 0.05, 0.14, 0, 1.28, 0, L.WOOD_D, 6)
	L.b(h, Vector3(0.1, 0.1, 0.12), Vector3(0.6, 0.62, 0.0), L.WOOD_D)


static func build_uzum_teknesi(h: Node3D) -> void:
	L.sol(h, Vector3(1.8, 0.1, 1.4), Vector3(0, 0.05, 0), L.WOOD_D, Vector3.ZERO, "wood")
	L.sol(h, Vector3(1.8, 0.6, 0.1), Vector3(0, 0.4, 0.65), L.WOOD, Vector3(-8, 0, 0), "wood")
	L.sol(h, Vector3(1.8, 0.6, 0.1), Vector3(0, 0.4, -0.65), L.WOOD, Vector3(8, 0, 0), "wood")
	L.sol(h, Vector3(0.1, 0.6, 1.4), Vector3(-0.85, 0.4, 0), L.WOOD, Vector3(0, 0, 8), "wood")
	L.sol(h, Vector3(0.1, 0.6, 1.4), Vector3(0.85, 0.4, 0), L.WOOD, Vector3(0, 0, -8), "wood")
	L.b(h, Vector3(1.5, 0.08, 1.1), Vector3(0, 0.45, 0), L.PURPLE)
	for i in 8:
		L.s(h, 0.08, Vector3(-0.6 + (i % 4) * 0.4, 0.52, -0.3 + (i / 4) * 0.6), L.PURPLE.lightened(0.15))


static func build_tezgah_kepengi(h: Node3D) -> void:
	# yarı açık ahşap kepenk: ahşap panel dizisi; üst yarısı yukarı kalkık, altta tezgâh levhası
	for i in 11:
		L.sol(h, Vector3(0.2, 1.2, 0.08), Vector3(-1.0 + i * 0.2, 0.6, 0), L.PLANK if i % 2 == 0 else L.WOOD_L, Vector3.ZERO, "wood")
	L.b(h, Vector3(2.2, 0.1, 0.12), Vector3(0, 1.25, 0.0), L.WOOD_D)
	for sx in [-1.1, 1.1]:
		L.sol(h, Vector3(0.12, 2.2, 0.14), Vector3(sx, 1.1, 0), L.WOOD_D, Vector3.ZERO, "wood")
	L.b(h, Vector3(2.0, 0.8, 0.05), Vector3(0, 1.8, 0.2), L.PLANK, Vector3(-65, 0, 0))
	L.cb(h, 0.03, 0.8, -0.9, 1.0, 0.2, L.WOOD_D, 5)
	L.b(h, Vector3(0.1, 0.1, 0.04), Vector3(0.0, 0.3, 0.07), L.IRON)


static func build_tabela(h: Node3D) -> void:
	L.cb(h, 0.05, 2.4, -0.5, 0, 0, L.WOOD_D, 6)
	L.col_box(h, Vector3(0.12, 2.4, 0.12), Vector3(-0.5, 1.2, 0))
	L.b(h, Vector3(0.9, 0.5, 0.06), Vector3(-0.05, 2.05, 0), L.PLANK, Vector3.ZERO, "wood")
	L.b(h, Vector3(0.08, 0.06, 0.08), Vector3(-0.35, 2.4, 0), L.IRON)
	L.b(h, Vector3(0.94, 0.06, 0.09), Vector3(-0.05, 2.32, 0), L.WOOD_D)
	L.b(h, Vector3(0.94, 0.06, 0.09), Vector3(-0.05, 1.78, 0), L.WOOD_D)
	L.lbl(h, "ΑΡΤΟΣ", Vector3(-0.05, 2.05, 0.04), 36, Color("2b1a0c"))
	L.lbl(h, "ΑΡΤΟΣ", Vector3(-0.05, 2.05, -0.04), 36, Color("2b1a0c"), Vector3(0, 180, 0))


static func build_ikona_nisi(h: Node3D) -> void:
	L.sol(h, Vector3(0.8, 1.2, 0.5), Vector3(0, 0.6, 0), L.STONE, Vector3.ZERO, "ashlar")
	L.b(h, Vector3(0.5, 0.65, 0.08), Vector3(0, 1.45, 0.0), L.STONE_D)
	L.b(h, Vector3(0.38, 0.52, 0.04), Vector3(0, 1.48, 0.22), L.GOLD)
	L.s(h, 0.1, Vector3(0, 1.58, 0.255), L.SKIN, Vector3(1, 1.2, 0.3))
	L.b(h, Vector3(0.18, 0.2, 0.02), Vector3(0, 1.36, 0.25), L.PURPLE)
	L.pr(h, Vector3(0.7, 0.28, 0.5), Vector3(0, 1.88, 0), L.TERRA_D)
	L.b(h, Vector3(0.12, 0.05, 0.12), Vector3(0, 1.22, 0.3), L.WOOD_D)


static func build_kandil(h: Node3D) -> void:
	L.cb(h, 0.04, 2.35, -0.3, 0, 0, L.WOOD_D, 6)
	L.col_box(h, Vector3(0.1, 2.35, 0.1), Vector3(-0.3, 1.18, 0))
	L.b(h, Vector3(0.62, 0.04, 0.04), Vector3(0, 2.33, 0), L.IRON)
	L.b(h, Vector3(0.012, 0.9, 0.012), Vector3(0, 1.85, 0), L.IRON)
	L.cb(h, 0.1, 0.16, 0, 1.4, 0, L.GOLD.darkened(0.15), 7, 0.05)
	L.cb(h, 0.12, 0.02, 0, 1.55, 0, L.GOLD, 7)
	L.s(h, 0.08, Vector3(0, 1.5, 0), Color("ffd890"), Vector3.ONE, 6)
	L.b(h, Vector3(0.1, 0.03, 0.1), Vector3(0, 2.3, 0), L.IRON)


static func build_mum_sehpasi(h: Node3D) -> void:
	L.sol(h, Vector3(0.7, 0.08, 0.5), Vector3(0, 0.8, 0), L.WOOD_D, Vector3.ZERO, "wood")
	for sx in [-0.3, 0.3]:
		L.sol(h, Vector3(0.06, 0.8, 0.06), Vector3(sx, 0.4, 0.0), L.WOOD_D)
	L.sol(h, Vector3(0.6, 0.06, 0.4), Vector3(0, 0.15, 0), L.WOOD_D)
	for i in 6:
		var x := -0.28 + i * 0.112
		L.cb(h, 0.025, 0.1 + (i % 3) * 0.03, x, 0.84, -0.1 + (i % 2) * 0.2, L.CREAM, 6)
		L.s(h, 0.025, Vector3(x, 0.98 + (i % 3) * 0.03, -0.1 + (i % 2) * 0.2), Color("ffd890"), Vector3(1, 1.5, 1), 5)


static func build_hacli_tas(h: Node3D) -> void:
	L.sol(h, Vector3(0.6, 0.5, 0.35), Vector3(0, 0.25, 0), L.STONE_D, Vector3.ZERO, "ashlar")
	L.sol(h, Vector3(0.36, 1.0, 0.24), Vector3(0, 1.0, 0), L.STONE, Vector3.ZERO, "ashlar")
	L.b(h, Vector3(0.1, 0.5, 0.04), Vector3(0, 1.1, 0.13), L.STONE_D)
	L.b(h, Vector3(0.3, 0.1, 0.04), Vector3(0, 1.25, 0.13), L.STONE_D)
	L.b(h, Vector3(0.7, 0.08, 0.45), Vector3(0, 0.04, 0), L.STONE_D)


static func build_lahit(h: Node3D) -> void:
	L.sol(h, Vector3(2.1, 0.75, 0.95), Vector3(0, 0.38, 0), L.MARBLE, Vector3.ZERO, "marble")
	L.pr(h, Vector3(2.2, 0.28, 1.05), Vector3(0, 0.89, 0), L.MARBLE.darkened(0.05))
	L.col_box(h, Vector3(2.2, 0.2, 1.05), Vector3(0, 0.9, 0))
	for sx in [-1.0, 1.0]:
		L.b(h, Vector3(0.14, 0.22, 0.12), Vector3(sx, 1.08, 0.4), L.MARBLE)
		L.b(h, Vector3(0.14, 0.22, 0.12), Vector3(sx, 1.08, -0.4), L.MARBLE)
	for i in 3:
		L.b(h, Vector3(0.45, 0.4, 0.04), Vector3(-0.65 + i * 0.65, 0.4, 0.5), L.STONE_L)
		L.b(h, Vector3(0.12, 0.12, 0.05), Vector3(-0.65 + i * 0.65, 0.45, 0.52), L.STONE_D)


static func build_sutun_baslik(h: Node3D) -> void:
	# devrik Korint başlığı + yanında sütun parçası
	L.b(h, Vector3(1.0, 0.16, 1.0), Vector3(0, 0.1, 0), L.MARBLE, Vector3(0, 20, 8), "marble")
	L.c(h, 0.42, 0.45, Vector3(0.0, 0.42, 0), L.MARBLE.darkened(0.04), Vector3(0, 0, 0), 12, 0.28, "marble")
	for i in 4:
		L.b(h, Vector3(0.28, 0.4, 0.06), Vector3(cos(i * PI / 2) * 0.35, 0.42, sin(i * PI / 2) * 0.35), L.MARBLE.darkened(0.12), Vector3(0, -i * 90, 0))
	L.b(h, Vector3(1.0, 0.1, 1.0), Vector3(0, 0.7, 0), L.MARBLE.lightened(0.04), Vector3(0, 20, 0))
	L.col_box(h, Vector3(1.0, 0.7, 1.0), Vector3(0, 0.35, 0))


static func build_mermer_parca(h: Node3D) -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 11
	for i in 7:
		var sz := Vector3(0.25 + rnd.randf() * 0.5, 0.08 + rnd.randf() * 0.1, 0.25 + rnd.randf() * 0.4)
		L.b(h, sz, Vector3(rnd.randf_range(-0.7, 0.7), sz.y * 0.5 + 0.005, rnd.randf_range(-0.55, 0.55)), L.MARBLE if i % 2 == 0 else L.MARBLE.darkened(0.1), Vector3(0, rnd.randf() * 180, 0), "marble")
	L.b(h, Vector3(0.5, 0.35, 0.35), Vector3(0.4, 0.2, 0.2), L.MARBLE.darkened(0.15), Vector3(10, 30, 0), "marble")


static func build_cit(h: Node3D) -> void:
	for i in 4:
		L.sol(h, Vector3(0.09, 1.2, 0.09), Vector3(-1.4 + i * 0.93, 0.6, 0), L.WOOD_D)
	for y in [0.45, 0.85]:
		L.b(h, Vector3(2.9, 0.07, 0.05), Vector3(0, y, 0.06), L.WOOD, Vector3.ZERO, "wood")
	L.col_box(h, Vector3(2.9, 1.15, 0.12), Vector3(0, 0.57, 0))


static func build_bahce_kapisi(h: Node3D) -> void:
	for sx in [-0.8, 0.8]:
		L.sol(h, Vector3(0.18, 1.8, 0.18), Vector3(sx, 0.9, 0), L.WOOD_D, Vector3.ZERO, "wood")
	L.b(h, Vector3(1.7, 0.15, 0.2), Vector3(0, 1.8, 0), L.WOOD_D)
	for i in 5:
		L.b(h, Vector3(0.1, 1.2, 0.05), Vector3(-0.55 + i * 0.28, 0.75, 0.0), L.PLANK)
	L.b(h, Vector3(1.4, 0.06, 0.06), Vector3(0, 0.45, 0.04), L.WOOD_D)
	L.b(h, Vector3(1.4, 0.06, 0.06), Vector3(0, 1.1, 0.04), L.WOOD_D)
	L.b(h, Vector3(0.12, 0.12, 0.04), Vector3(0.45, 0.9, 0.08), L.IRON)


static func build_asma_cardagi(h: Node3D) -> void:
	for sx in [-1.4, 1.4]:
		for sz in [-1.4, 1.4]:
			L.cb(h, 0.07, 2.4, sx, 0, sz, L.WOOD_D, 6)
			L.col_box(h, Vector3(0.16, 2.4, 0.16), Vector3(sx, 1.2, sz))
	for sx in [-1.4, 1.4]:
		L.b(h, Vector3(0.1, 0.1, 3.0), Vector3(sx, 2.45, 0), L.WOOD)
	for i in 7:
		L.b(h, Vector3(3.0, 0.06, 0.07), Vector3(0, 2.52, -1.35 + i * 0.45), L.WOOD_D)
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 3
	for i in 7:
		L.s(h, 0.3, Vector3(rnd.randf_range(-1.3, 1.3), 2.6 + rnd.randf() * 0.1, rnd.randf_range(-1.3, 1.3)), L.GREEN if i % 2 == 0 else L.GREEN_D, Vector3(1.2, 0.35, 1.2), 6)
	for i in 5:
		var gx := rnd.randf_range(-1.1, 1.1)
		var gz := rnd.randf_range(-1.1, 1.1)
		L.s(h, 0.06, Vector3(gx, 2.3, gz), L.PURPLE.lightened(0.1), Vector3(1, 1.3, 1), 5)
		L.b(h, Vector3(0.02, 0.14, 0.02), Vector3(gx, 2.4, gz), L.GREEN_D)
	L.col_box(h, Vector3(3.1, 0.1, 3.1), Vector3(0, 2.6, 0))
	L.bb(h, Vector3(2.0, 0.45, 0.5), 0, 0, -1.0, L.PLANK, 0, "wood")
	L.col_box(h, Vector3(2.0, 0.45, 0.5), Vector3(0, 0.22, -1.0))


static func build_saksi(h: Node3D) -> void:
	L.cb(h, 0.2, 0.34, 0, 0, 0, L.TERRA, 8, 0.16)
	L.cb(h, 0.22, 0.05, 0, 0.32, 0, L.TERRA_D, 8)
	L.cb(h, 0.17, 0.02, 0, 0.36, 0, L.SOIL, 8)
	L.s(h, 0.5, Vector3(0, 0.55, 0), L.GREEN, Vector3(0.4, 0.35, 0.4), 7)
	for i in 4:
		L.s(h, 0.04, Vector3(cos(i * 1.6) * 0.12, 0.6 + (i % 2) * 0.08, sin(i * 1.6) * 0.12), L.RED if i % 2 == 0 else L.OCHRE, Vector3.ONE, 5)


static func build_cicekli_pencere(h: Node3D) -> void:
	# tuğla/sıva duvar parçası içinde pencere, altında çiçek kutusu
	L.sol(h, Vector3(1.2, 1.9, 0.4), Vector3(0, 0.95, 0), L.CREAM.darkened(0.06), Vector3.ZERO, "plaster")
	L.b(h, Vector3(0.6, 0.8, 0.06), Vector3(0, 1.3, 0.2), L.BLACK)
	L.b(h, Vector3(0.7, 0.07, 0.1), Vector3(0, 1.74, 0.22), L.STONE_L)
	L.b(h, Vector3(0.74, 0.07, 0.12), Vector3(0, 0.88, 0.25), L.STONE_L)
	L.b(h, Vector3(0.04, 0.8, 0.07), Vector3(0, 1.3, 0.21), L.WOOD_D)
	L.b(h, Vector3(0.6, 0.04, 0.07), Vector3(0, 1.3, 0.21), L.WOOD_D)
	for sx in [-0.34, 0.34]:
		L.b(h, Vector3(0.1, 0.86, 0.07), Vector3(sx, 1.3, 0.22), L.WOOD)
	L.b(h, Vector3(0.7, 0.16, 0.2), Vector3(0, 0.99, 0.36), L.WOOD)
	for i in 5:
		L.s(h, 0.07, Vector3(-0.27 + i * 0.135, 1.14, 0.36), L.RED if i % 2 == 0 else L.OCHRE, Vector3.ONE, 5)
	L.s(h, 0.5, Vector3(0, 1.12, 0.36), L.GREEN, Vector3(0.7, 0.18, 0.14), 6)
