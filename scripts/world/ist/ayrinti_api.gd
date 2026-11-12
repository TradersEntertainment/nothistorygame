class_name AyrintiApi
extends RefCounted
## Dondurulmuş arayüz kalıbı (build_<id>, perches_<id>, climbs_<id>) — hepsi Ayrinti.build/perches/climbs'e yönlenir.
## Üretildi: öğe başına bir satır. Köşe grupları: build_set_<ad>.

static func build_tezgah(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tezgah", host, k, lod)
static func perches_tezgah(k: float = 0.5) -> Array:
	return Ayrinti.perches("tezgah", k)
static func climbs_tezgah(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tezgah", k)

static func build_tente(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tente", host, k, lod)
static func perches_tente(k: float = 0.5) -> Array:
	return Ayrinti.perches("tente", k)
static func climbs_tente(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tente", k)

static func build_amfora(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("amfora", host, k, lod)
static func perches_amfora(k: float = 0.5) -> Array:
	return Ayrinti.perches("amfora", k)
static func climbs_amfora(k: float = 0.5) -> Array:
	return Ayrinti.climbs("amfora", k)

static func build_pithos(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("pithos", host, k, lod)
static func perches_pithos(k: float = 0.5) -> Array:
	return Ayrinti.perches("pithos", k)
static func climbs_pithos(k: float = 0.5) -> Array:
	return Ayrinti.climbs("pithos", k)

static func build_fici(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("fici", host, k, lod)
static func perches_fici(k: float = 0.5) -> Array:
	return Ayrinti.perches("fici", k)
static func climbs_fici(k: float = 0.5) -> Array:
	return Ayrinti.climbs("fici", k)

static func build_sepet(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sepet", host, k, lod)
static func perches_sepet(k: float = 0.5) -> Array:
	return Ayrinti.perches("sepet", k)
static func climbs_sepet(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sepet", k)

static func build_cuval(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("cuval", host, k, lod)
static func perches_cuval(k: float = 0.5) -> Array:
	return Ayrinti.perches("cuval", k)
static func climbs_cuval(k: float = 0.5) -> Array:
	return Ayrinti.climbs("cuval", k)

static func build_terazi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("terazi", host, k, lod)
static func perches_terazi(k: float = 0.5) -> Array:
	return Ayrinti.perches("terazi", k)
static func climbs_terazi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("terazi", k)

static func build_balik_agi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("balik_agi", host, k, lod)
static func perches_balik_agi(k: float = 0.5) -> Array:
	return Ayrinti.perches("balik_agi", k)
static func climbs_balik_agi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("balik_agi", k)

static func build_ag_sehpasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("ag_sehpasi", host, k, lod)
static func perches_ag_sehpasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("ag_sehpasi", k)
static func climbs_ag_sehpasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("ag_sehpasi", k)

static func build_kayik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kayik", host, k, lod)
static func perches_kayik(k: float = 0.5) -> Array:
	return Ayrinti.perches("kayik", k)
static func climbs_kayik(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kayik", k)

static func build_kurek(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kurek", host, k, lod)
static func perches_kurek(k: float = 0.5) -> Array:
	return Ayrinti.perches("kurek", k)
static func climbs_kurek(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kurek", k)

static func build_capa(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("capa", host, k, lod)
static func perches_capa(k: float = 0.5) -> Array:
	return Ayrinti.perches("capa", k)
static func climbs_capa(k: float = 0.5) -> Array:
	return Ayrinti.climbs("capa", k)

static func build_camasir_ipi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("camasir_ipi", host, k, lod)
static func perches_camasir_ipi(k: float = 0.5) -> Array:
	return Ayrinti.perches("camasir_ipi", k)
static func climbs_camasir_ipi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("camasir_ipi", k)

static func build_kumes(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kumes", host, k, lod)
static func perches_kumes(k: float = 0.5) -> Array:
	return Ayrinti.perches("kumes", k)
static func climbs_kumes(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kumes", k)

static func build_guvercinlik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("guvercinlik", host, k, lod)
static func perches_guvercinlik(k: float = 0.5) -> Array:
	return Ayrinti.perches("guvercinlik", k)
static func climbs_guvercinlik(k: float = 0.5) -> Array:
	return Ayrinti.climbs("guvercinlik", k)

static func build_ari_kovani(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("ari_kovani", host, k, lod)
static func perches_ari_kovani(k: float = 0.5) -> Array:
	return Ayrinti.perches("ari_kovani", k)
static func climbs_ari_kovani(k: float = 0.5) -> Array:
	return Ayrinti.climbs("ari_kovani", k)

static func build_yalak(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("yalak", host, k, lod)
static func perches_yalak(k: float = 0.5) -> Array:
	return Ayrinti.perches("yalak", k)
static func climbs_yalak(k: float = 0.5) -> Array:
	return Ayrinti.climbs("yalak", k)

static func build_kuyu(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kuyu", host, k, lod)
static func perches_kuyu(k: float = 0.5) -> Array:
	return Ayrinti.perches("kuyu", k)
static func climbs_kuyu(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kuyu", k)

static func build_su_dolabi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("su_dolabi", host, k, lod)
static func perches_su_dolabi(k: float = 0.5) -> Array:
	return Ayrinti.perches("su_dolabi", k)
static func climbs_su_dolabi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("su_dolabi", k)

static func build_el_arabasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("el_arabasi", host, k, lod)
static func perches_el_arabasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("el_arabasi", k)
static func climbs_el_arabasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("el_arabasi", k)

static func build_kagni(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kagni", host, k, lod)
static func perches_kagni(k: float = 0.5) -> Array:
	return Ayrinti.perches("kagni", k)
static func climbs_kagni(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kagni", k)

static func build_esek_semeri(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("esek_semeri", host, k, lod)
static func perches_esek_semeri(k: float = 0.5) -> Array:
	return Ayrinti.perches("esek_semeri", k)
static func climbs_esek_semeri(k: float = 0.5) -> Array:
	return Ayrinti.climbs("esek_semeri", k)

static func build_odun_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("odun_yigini", host, k, lod)
static func perches_odun_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("odun_yigini", k)
static func climbs_odun_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("odun_yigini", k)

static func build_tas_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tas_yigini", host, k, lod)
static func perches_tas_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("tas_yigini", k)
static func climbs_tas_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tas_yigini", k)

static func build_kirec_ocagi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kirec_ocagi", host, k, lod)
static func perches_kirec_ocagi(k: float = 0.5) -> Array:
	return Ayrinti.perches("kirec_ocagi", k)
static func climbs_kirec_ocagi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kirec_ocagi", k)

static func build_iskele(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("iskele", host, k, lod)
static func perches_iskele(k: float = 0.5) -> Array:
	return Ayrinti.perches("iskele", k)
static func climbs_iskele(k: float = 0.5) -> Array:
	return Ayrinti.climbs("iskele", k)

static func build_merdiven(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("merdiven", host, k, lod)
static func perches_merdiven(k: float = 0.5) -> Array:
	return Ayrinti.perches("merdiven", k)
static func climbs_merdiven(k: float = 0.5) -> Array:
	return Ayrinti.climbs("merdiven", k)

static func build_sandik_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sandik_yigini", host, k, lod)
static func perches_sandik_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("sandik_yigini", k)
static func climbs_sandik_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sandik_yigini", k)

static func build_firin(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("firin", host, k, lod)
static func perches_firin(k: float = 0.5) -> Array:
	return Ayrinti.perches("firin", k)
static func climbs_firin(k: float = 0.5) -> Array:
	return Ayrinti.climbs("firin", k)

static func build_tandir(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tandir", host, k, lod)
static func perches_tandir(k: float = 0.5) -> Array:
	return Ayrinti.perches("tandir", k)
static func climbs_tandir(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tandir", k)

static func build_degirmen_tasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("degirmen_tasi", host, k, lod)
static func perches_degirmen_tasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("degirmen_tasi", k)
static func climbs_degirmen_tasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("degirmen_tasi", k)

static func build_zeytin_presi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("zeytin_presi", host, k, lod)
static func perches_zeytin_presi(k: float = 0.5) -> Array:
	return Ayrinti.perches("zeytin_presi", k)
static func climbs_zeytin_presi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("zeytin_presi", k)

static func build_sarap_fici(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sarap_fici", host, k, lod)
static func perches_sarap_fici(k: float = 0.5) -> Array:
	return Ayrinti.perches("sarap_fici", k)
static func climbs_sarap_fici(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sarap_fici", k)

static func build_uzum_teknesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("uzum_teknesi", host, k, lod)
static func perches_uzum_teknesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("uzum_teknesi", k)
static func climbs_uzum_teknesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("uzum_teknesi", k)

static func build_tezgah_kepengi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tezgah_kepengi", host, k, lod)
static func perches_tezgah_kepengi(k: float = 0.5) -> Array:
	return Ayrinti.perches("tezgah_kepengi", k)
static func climbs_tezgah_kepengi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tezgah_kepengi", k)

static func build_tabela(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tabela", host, k, lod)
static func perches_tabela(k: float = 0.5) -> Array:
	return Ayrinti.perches("tabela", k)
static func climbs_tabela(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tabela", k)

static func build_ikona_nisi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("ikona_nisi", host, k, lod)
static func perches_ikona_nisi(k: float = 0.5) -> Array:
	return Ayrinti.perches("ikona_nisi", k)
static func climbs_ikona_nisi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("ikona_nisi", k)

static func build_kandil(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kandil", host, k, lod)
static func perches_kandil(k: float = 0.5) -> Array:
	return Ayrinti.perches("kandil", k)
static func climbs_kandil(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kandil", k)

static func build_mum_sehpasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("mum_sehpasi", host, k, lod)
static func perches_mum_sehpasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("mum_sehpasi", k)
static func climbs_mum_sehpasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("mum_sehpasi", k)

static func build_hacli_tas(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("hacli_tas", host, k, lod)
static func perches_hacli_tas(k: float = 0.5) -> Array:
	return Ayrinti.perches("hacli_tas", k)
static func climbs_hacli_tas(k: float = 0.5) -> Array:
	return Ayrinti.climbs("hacli_tas", k)

static func build_lahit(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("lahit", host, k, lod)
static func perches_lahit(k: float = 0.5) -> Array:
	return Ayrinti.perches("lahit", k)
static func climbs_lahit(k: float = 0.5) -> Array:
	return Ayrinti.climbs("lahit", k)

static func build_sutun_baslik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sutun_baslik", host, k, lod)
static func perches_sutun_baslik(k: float = 0.5) -> Array:
	return Ayrinti.perches("sutun_baslik", k)
static func climbs_sutun_baslik(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sutun_baslik", k)

static func build_mermer_parca(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("mermer_parca", host, k, lod)
static func perches_mermer_parca(k: float = 0.5) -> Array:
	return Ayrinti.perches("mermer_parca", k)
static func climbs_mermer_parca(k: float = 0.5) -> Array:
	return Ayrinti.climbs("mermer_parca", k)

static func build_cit(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("cit", host, k, lod)
static func perches_cit(k: float = 0.5) -> Array:
	return Ayrinti.perches("cit", k)
static func climbs_cit(k: float = 0.5) -> Array:
	return Ayrinti.climbs("cit", k)

static func build_bahce_kapisi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("bahce_kapisi", host, k, lod)
static func perches_bahce_kapisi(k: float = 0.5) -> Array:
	return Ayrinti.perches("bahce_kapisi", k)
static func climbs_bahce_kapisi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("bahce_kapisi", k)

static func build_asma_cardagi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("asma_cardagi", host, k, lod)
static func perches_asma_cardagi(k: float = 0.5) -> Array:
	return Ayrinti.perches("asma_cardagi", k)
static func climbs_asma_cardagi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("asma_cardagi", k)

static func build_saksi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("saksi", host, k, lod)
static func perches_saksi(k: float = 0.5) -> Array:
	return Ayrinti.perches("saksi", k)
static func climbs_saksi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("saksi", k)

static func build_cicekli_pencere(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("cicekli_pencere", host, k, lod)
static func perches_cicekli_pencere(k: float = 0.5) -> Array:
	return Ayrinti.perches("cicekli_pencere", k)
static func climbs_cicekli_pencere(k: float = 0.5) -> Array:
	return Ayrinti.climbs("cicekli_pencere", k)

static func build_kedi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kedi", host, k, lod)
static func perches_kedi(k: float = 0.5) -> Array:
	return Ayrinti.perches("kedi", k)
static func climbs_kedi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kedi", k)

static func build_kopek(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kopek", host, k, lod)
static func perches_kopek(k: float = 0.5) -> Array:
	return Ayrinti.perches("kopek", k)
static func climbs_kopek(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kopek", k)

static func build_tavuk(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tavuk", host, k, lod)
static func perches_tavuk(k: float = 0.5) -> Array:
	return Ayrinti.perches("tavuk", k)
static func climbs_tavuk(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tavuk", k)

static func build_keci(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("keci", host, k, lod)
static func perches_keci(k: float = 0.5) -> Array:
	return Ayrinti.perches("keci", k)
static func climbs_keci(k: float = 0.5) -> Array:
	return Ayrinti.climbs("keci", k)

static func build_esek(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("esek", host, k, lod)
static func perches_esek(k: float = 0.5) -> Array:
	return Ayrinti.perches("esek", k)
static func climbs_esek(k: float = 0.5) -> Array:
	return Ayrinti.climbs("esek", k)

static func build_at(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("at", host, k, lod)
static func perches_at(k: float = 0.5) -> Array:
	return Ayrinti.perches("at", k)
static func climbs_at(k: float = 0.5) -> Array:
	return Ayrinti.climbs("at", k)

static func build_okuz(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("okuz", host, k, lod)
static func perches_okuz(k: float = 0.5) -> Array:
	return Ayrinti.perches("okuz", k)
static func climbs_okuz(k: float = 0.5) -> Array:
	return Ayrinti.climbs("okuz", k)

static func build_koyun(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("koyun", host, k, lod)
static func perches_koyun(k: float = 0.5) -> Array:
	return Ayrinti.perches("koyun", k)
static func climbs_koyun(k: float = 0.5) -> Array:
	return Ayrinti.climbs("koyun", k)

static func build_kaz(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kaz", host, k, lod)
static func perches_kaz(k: float = 0.5) -> Array:
	return Ayrinti.perches("kaz", k)
static func climbs_kaz(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kaz", k)

static func build_marti(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("marti", host, k, lod)
static func perches_marti(k: float = 0.5) -> Array:
	return Ayrinti.perches("marti", k)
static func climbs_marti(k: float = 0.5) -> Array:
	return Ayrinti.climbs("marti", k)

static func build_cop(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("cop", host, k, lod)
static func perches_cop(k: float = 0.5) -> Array:
	return Ayrinti.perches("cop", k)
static func climbs_cop(k: float = 0.5) -> Array:
	return Ayrinti.climbs("cop", k)

static func build_su_birikintisi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("su_birikintisi", host, k, lod)
static func perches_su_birikintisi(k: float = 0.5) -> Array:
	return Ayrinti.perches("su_birikintisi", k)
static func climbs_su_birikintisi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("su_birikintisi", k)

static func build_mancinik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("mancinik", host, k, lod)
static func perches_mancinik(k: float = 0.5) -> Array:
	return Ayrinti.perches("mancinik", k)
static func climbs_mancinik(k: float = 0.5) -> Array:
	return Ayrinti.climbs("mancinik", k)

static func build_gulle_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("gulle_yigini", host, k, lod)
static func perches_gulle_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("gulle_yigini", k)
static func climbs_gulle_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("gulle_yigini", k)

static func build_ok_sandigi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("ok_sandigi", host, k, lod)
static func perches_ok_sandigi(k: float = 0.5) -> Array:
	return Ayrinti.perches("ok_sandigi", k)
static func climbs_ok_sandigi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("ok_sandigi", k)

static func build_kalkan_askisi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kalkan_askisi", host, k, lod)
static func perches_kalkan_askisi(k: float = 0.5) -> Array:
	return Ayrinti.perches("kalkan_askisi", k)
static func climbs_kalkan_askisi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kalkan_askisi", k)

static func build_mizraklik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("mizraklik", host, k, lod)
static func perches_mizraklik(k: float = 0.5) -> Array:
	return Ayrinti.perches("mizraklik", k)
static func climbs_mizraklik(k: float = 0.5) -> Array:
	return Ayrinti.climbs("mizraklik", k)

static func build_nobetci_kulubesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("nobetci_kulubesi", host, k, lod)
static func perches_nobetci_kulubesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("nobetci_kulubesi", k)
static func climbs_nobetci_kulubesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("nobetci_kulubesi", k)

static func build_barikat(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("barikat", host, k, lod)
static func perches_barikat(k: float = 0.5) -> Array:
	return Ayrinti.perches("barikat", k)
static func climbs_barikat(k: float = 0.5) -> Array:
	return Ayrinti.climbs("barikat", k)

static func build_fici_toprak(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("fici_toprak", host, k, lod)
static func perches_fici_toprak(k: float = 0.5) -> Array:
	return Ayrinti.perches("fici_toprak", k)
static func climbs_fici_toprak(k: float = 0.5) -> Array:
	return Ayrinti.climbs("fici_toprak", k)

static func build_top(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("top", host, k, lod)
static func perches_top(k: float = 0.5) -> Array:
	return Ayrinti.perches("top", k)
static func climbs_top(k: float = 0.5) -> Array:
	return Ayrinti.climbs("top", k)

static func build_balista(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("balista", host, k, lod)
static func perches_balista(k: float = 0.5) -> Array:
	return Ayrinti.perches("balista", k)
static func climbs_balista(k: float = 0.5) -> Array:
	return Ayrinti.climbs("balista", k)

static func build_kazan_yag(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kazan_yag", host, k, lod)
static func perches_kazan_yag(k: float = 0.5) -> Array:
	return Ayrinti.perches("kazan_yag", k)
static func climbs_kazan_yag(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kazan_yag", k)

static func build_okcu_siperi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("okcu_siperi", host, k, lod)
static func perches_okcu_siperi(k: float = 0.5) -> Array:
	return Ayrinti.perches("okcu_siperi", k)
static func climbs_okcu_siperi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("okcu_siperi", k)

static func build_kusatma_merdiveni(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kusatma_merdiveni", host, k, lod)
static func perches_kusatma_merdiveni(k: float = 0.5) -> Array:
	return Ayrinti.perches("kusatma_merdiveni", k)
static func climbs_kusatma_merdiveni(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kusatma_merdiveni", k)

static func build_sancak_diregi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sancak_diregi", host, k, lod)
static func perches_sancak_diregi(k: float = 0.5) -> Array:
	return Ayrinti.perches("sancak_diregi", k)
static func climbs_sancak_diregi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sancak_diregi", k)

static func build_hendek_kazigi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("hendek_kazigi", host, k, lod)
static func perches_hendek_kazigi(k: float = 0.5) -> Array:
	return Ayrinti.perches("hendek_kazigi", k)
static func climbs_hendek_kazigi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("hendek_kazigi", k)

static func build_gabyon(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("gabyon", host, k, lod)
static func perches_gabyon(k: float = 0.5) -> Array:
	return Ayrinti.perches("gabyon", k)
static func climbs_gabyon(k: float = 0.5) -> Array:
	return Ayrinti.climbs("gabyon", k)

static func build_ordu_cadiri(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("ordu_cadiri", host, k, lod)
static func perches_ordu_cadiri(k: float = 0.5) -> Array:
	return Ayrinti.perches("ordu_cadiri", k)
static func climbs_ordu_cadiri(k: float = 0.5) -> Array:
	return Ayrinti.climbs("ordu_cadiri", k)

static func build_multeci_cadiri(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("multeci_cadiri", host, k, lod)
static func perches_multeci_cadiri(k: float = 0.5) -> Array:
	return Ayrinti.perches("multeci_cadiri", k)
static func climbs_multeci_cadiri(k: float = 0.5) -> Array:
	return Ayrinti.climbs("multeci_cadiri", k)

static func build_yer_yatagi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("yer_yatagi", host, k, lod)
static func perches_yer_yatagi(k: float = 0.5) -> Array:
	return Ayrinti.perches("yer_yatagi", k)
static func climbs_yer_yatagi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("yer_yatagi", k)

static func build_kamp_atesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kamp_atesi", host, k, lod)
static func perches_kamp_atesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("kamp_atesi", k)
static func climbs_kamp_atesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kamp_atesi", k)

static func build_kazan(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kazan", host, k, lod)
static func perches_kazan(k: float = 0.5) -> Array:
	return Ayrinti.perches("kazan", k)
static func climbs_kazan(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kazan", k)

static func build_mangal(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("mangal", host, k, lod)
static func perches_mangal(k: float = 0.5) -> Array:
	return Ayrinti.perches("mangal", k)
static func climbs_mangal(k: float = 0.5) -> Array:
	return Ayrinti.climbs("mangal", k)

static func build_mesale_diregi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("mesale_diregi", host, k, lod)
static func perches_mesale_diregi(k: float = 0.5) -> Array:
	return Ayrinti.perches("mesale_diregi", k)
static func climbs_mesale_diregi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("mesale_diregi", k)

static func build_saman_balyasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("saman_balyasi", host, k, lod)
static func perches_saman_balyasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("saman_balyasi", k)
static func climbs_saman_balyasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("saman_balyasi", k)

static func build_saman_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("saman_yigini", host, k, lod)
static func perches_saman_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("saman_yigini", k)
static func climbs_saman_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("saman_yigini", k)

static func build_ot_demeti(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("ot_demeti", host, k, lod)
static func perches_ot_demeti(k: float = 0.5) -> Array:
	return Ayrinti.perches("ot_demeti", k)
static func climbs_ot_demeti(k: float = 0.5) -> Array:
	return Ayrinti.climbs("ot_demeti", k)

static func build_yun_balyasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("yun_balyasi", host, k, lod)
static func perches_yun_balyasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("yun_balyasi", k)
static func climbs_yun_balyasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("yun_balyasi", k)

static func build_demir_ocagi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("demir_ocagi", host, k, lod)
static func perches_demir_ocagi(k: float = 0.5) -> Array:
	return Ayrinti.perches("demir_ocagi", k)
static func climbs_demir_ocagi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("demir_ocagi", k)

static func build_ors(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("ors", host, k, lod)
static func perches_ors(k: float = 0.5) -> Array:
	return Ayrinti.perches("ors", k)
static func climbs_ors(k: float = 0.5) -> Array:
	return Ayrinti.climbs("ors", k)

static func build_soguma_teknesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("soguma_teknesi", host, k, lod)
static func perches_soguma_teknesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("soguma_teknesi", k)
static func climbs_soguma_teknesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("soguma_teknesi", k)

static func build_dokuma_tezgahi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("dokuma_tezgahi", host, k, lod)
static func perches_dokuma_tezgahi(k: float = 0.5) -> Array:
	return Ayrinti.perches("dokuma_tezgahi", k)
static func climbs_dokuma_tezgahi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("dokuma_tezgahi", k)

static func build_boya_kazani(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("boya_kazani", host, k, lod)
static func perches_boya_kazani(k: float = 0.5) -> Array:
	return Ayrinti.perches("boya_kazani", k)
static func climbs_boya_kazani(k: float = 0.5) -> Array:
	return Ayrinti.climbs("boya_kazani", k)

static func build_boya_askisi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("boya_askisi", host, k, lod)
static func perches_boya_askisi(k: float = 0.5) -> Array:
	return Ayrinti.perches("boya_askisi", k)
static func climbs_boya_askisi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("boya_askisi", k)

static func build_kumas_topu(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kumas_topu", host, k, lod)
static func perches_kumas_topu(k: float = 0.5) -> Array:
	return Ayrinti.perches("kumas_topu", k)
static func climbs_kumas_topu(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kumas_topu", k)

static func build_deri_gerdirme(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("deri_gerdirme", host, k, lod)
static func perches_deri_gerdirme(k: float = 0.5) -> Array:
	return Ayrinti.perches("deri_gerdirme", k)
static func climbs_deri_gerdirme(k: float = 0.5) -> Array:
	return Ayrinti.climbs("deri_gerdirme", k)

static func build_balik_kasasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("balik_kasasi", host, k, lod)
static func perches_balik_kasasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("balik_kasasi", k)
static func climbs_balik_kasasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("balik_kasasi", k)

static func build_balik_kurutma(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("balik_kurutma", host, k, lod)
static func perches_balik_kurutma(k: float = 0.5) -> Array:
	return Ayrinti.perches("balik_kurutma", k)
static func climbs_balik_kurutma(k: float = 0.5) -> Array:
	return Ayrinti.climbs("balik_kurutma", k)

static func build_halat_rulo(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("halat_rulo", host, k, lod)
static func perches_halat_rulo(k: float = 0.5) -> Array:
	return Ayrinti.perches("halat_rulo", k)
static func climbs_halat_rulo(k: float = 0.5) -> Array:
	return Ayrinti.climbs("halat_rulo", k)

static func build_palamar_babasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("palamar_babasi", host, k, lod)
static func perches_palamar_babasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("palamar_babasi", k)
static func climbs_palamar_babasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("palamar_babasi", k)

static func build_yelken_bezi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("yelken_bezi", host, k, lod)
static func perches_yelken_bezi(k: float = 0.5) -> Array:
	return Ayrinti.perches("yelken_bezi", k)
static func climbs_yelken_bezi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("yelken_bezi", k)

static func build_masa(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("masa", host, k, lod)
static func perches_masa(k: float = 0.5) -> Array:
	return Ayrinti.perches("masa", k)
static func climbs_masa(k: float = 0.5) -> Array:
	return Ayrinti.climbs("masa", k)

static func build_tabure(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tabure", host, k, lod)
static func perches_tabure(k: float = 0.5) -> Array:
	return Ayrinti.perches("tabure", k)
static func climbs_tabure(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tabure", k)

static func build_bank(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("bank", host, k, lod)
static func perches_bank(k: float = 0.5) -> Array:
	return Ayrinti.perches("bank", k)
static func climbs_bank(k: float = 0.5) -> Array:
	return Ayrinti.climbs("bank", k)

static func build_sandik(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sandik", host, k, lod)
static func perches_sandik(k: float = 0.5) -> Array:
	return Ayrinti.perches("sandik", k)
static func climbs_sandik(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sandik", k)

static func build_kutuk(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kutuk", host, k, lod)
static func perches_kutuk(k: float = 0.5) -> Array:
	return Ayrinti.perches("kutuk", k)
static func climbs_kutuk(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kutuk", k)

static func build_kutuk_kutugu(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kutuk_kutugu", host, k, lod)
static func perches_kutuk_kutugu(k: float = 0.5) -> Array:
	return Ayrinti.perches("kutuk_kutugu", k)
static func climbs_kutuk_kutugu(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kutuk_kutugu", k)

static func build_kazma_kurek(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kazma_kurek", host, k, lod)
static func perches_kazma_kurek(k: float = 0.5) -> Array:
	return Ayrinti.perches("kazma_kurek", k)
static func climbs_kazma_kurek(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kazma_kurek", k)

static func build_tugla_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tugla_yigini", host, k, lod)
static func perches_tugla_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("tugla_yigini", k)
static func climbs_tugla_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tugla_yigini", k)

static func build_kiremit_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kiremit_yigini", host, k, lod)
static func perches_kiremit_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("kiremit_yigini", k)
static func climbs_kiremit_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kiremit_yigini", k)

static func build_harc_teknesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("harc_teknesi", host, k, lod)
static func perches_harc_teknesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("harc_teknesi", k)
static func climbs_harc_teknesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("harc_teknesi", k)

static func build_yapi_iskelesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("yapi_iskelesi", host, k, lod)
static func perches_yapi_iskelesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("yapi_iskelesi", k)
static func climbs_yapi_iskelesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("yapi_iskelesi", k)

static func build_cikrik_vinc(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("cikrik_vinc", host, k, lod)
static func perches_cikrik_vinc(k: float = 0.5) -> Array:
	return Ayrinti.perches("cikrik_vinc", k)
static func climbs_cikrik_vinc(k: float = 0.5) -> Array:
	return Ayrinti.climbs("cikrik_vinc", k)

static func build_yikik_duvar(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("yikik_duvar", host, k, lod)
static func perches_yikik_duvar(k: float = 0.5) -> Array:
	return Ayrinti.perches("yikik_duvar", k)
static func climbs_yikik_duvar(k: float = 0.5) -> Array:
	return Ayrinti.climbs("yikik_duvar", k)

static func build_saban(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("saban", host, k, lod)
static func perches_saban(k: float = 0.5) -> Array:
	return Ayrinti.perches("saban", k)
static func climbs_saban(k: float = 0.5) -> Array:
	return Ayrinti.climbs("saban", k)

static func build_testi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("testi", host, k, lod)
static func perches_testi(k: float = 0.5) -> Array:
	return Ayrinti.perches("testi", k)
static func climbs_testi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("testi", k)

static func build_kase_tezgahi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kase_tezgahi", host, k, lod)
static func perches_kase_tezgahi(k: float = 0.5) -> Array:
	return Ayrinti.perches("kase_tezgahi", k)
static func climbs_kase_tezgahi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kase_tezgahi", k)

static func build_tas_havuz(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tas_havuz", host, k, lod)
static func perches_tas_havuz(k: float = 0.5) -> Array:
	return Ayrinti.perches("tas_havuz", k)
static func climbs_tas_havuz(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tas_havuz", k)

static func build_cesme(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("cesme", host, k, lod)
static func perches_cesme(k: float = 0.5) -> Array:
	return Ayrinti.perches("cesme", k)
static func climbs_cesme(k: float = 0.5) -> Array:
	return Ayrinti.climbs("cesme", k)

static func build_sarnic_agzi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sarnic_agzi", host, k, lod)
static func perches_sarnic_agzi(k: float = 0.5) -> Array:
	return Ayrinti.perches("sarnic_agzi", k)
static func climbs_sarnic_agzi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sarnic_agzi", k)

static func build_sutun_govdesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sutun_govdesi", host, k, lod)
static func perches_sutun_govdesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("sutun_govdesi", k)
static func climbs_sutun_govdesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sutun_govdesi", k)

static func build_mezar_tasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("mezar_tasi", host, k, lod)
static func perches_mezar_tasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("mezar_tasi", k)
static func climbs_mezar_tasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("mezar_tasi", k)

static func build_can_cercevesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("can_cercevesi", host, k, lod)
static func perches_can_cercevesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("can_cercevesi", k)
static func climbs_can_cercevesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("can_cercevesi", k)

static func build_vaftiz_kurnasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("vaftiz_kurnasi", host, k, lod)
static func perches_vaftiz_kurnasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("vaftiz_kurnasi", k)
static func climbs_vaftiz_kurnasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("vaftiz_kurnasi", k)

static func build_ayin_bayragi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("ayin_bayragi", host, k, lod)
static func perches_ayin_bayragi(k: float = 0.5) -> Array:
	return Ayrinti.perches("ayin_bayragi", k)
static func climbs_ayin_bayragi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("ayin_bayragi", k)

static func build_ikon_sehpasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("ikon_sehpasi", host, k, lod)
static func perches_ikon_sehpasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("ikon_sehpasi", k)
static func climbs_ikon_sehpasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("ikon_sehpasi", k)

static func build_buhurdan(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("buhurdan", host, k, lod)
static func perches_buhurdan(k: float = 0.5) -> Array:
	return Ayrinti.perches("buhurdan", k)
static func climbs_buhurdan(k: float = 0.5) -> Array:
	return Ayrinti.climbs("buhurdan", k)

static func build_bostan_sirasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("bostan_sirasi", host, k, lod)
static func perches_bostan_sirasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("bostan_sirasi", k)
static func climbs_bostan_sirasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("bostan_sirasi", k)

static func build_korkuluk(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("korkuluk", host, k, lod)
static func perches_korkuluk(k: float = 0.5) -> Array:
	return Ayrinti.perches("korkuluk", k)
static func climbs_korkuluk(k: float = 0.5) -> Array:
	return Ayrinti.climbs("korkuluk", k)

static func build_meyve_agaci(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("meyve_agaci", host, k, lod)
static func perches_meyve_agaci(k: float = 0.5) -> Array:
	return Ayrinti.perches("meyve_agaci", k)
static func climbs_meyve_agaci(k: float = 0.5) -> Array:
	return Ayrinti.climbs("meyve_agaci", k)

static func build_zeytin_agaci(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("zeytin_agaci", host, k, lod)
static func perches_zeytin_agaci(k: float = 0.5) -> Array:
	return Ayrinti.perches("zeytin_agaci", k)
static func climbs_zeytin_agaci(k: float = 0.5) -> Array:
	return Ayrinti.climbs("zeytin_agaci", k)

static func build_selvi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("selvi", host, k, lod)
static func perches_selvi(k: float = 0.5) -> Array:
	return Ayrinti.perches("selvi", k)
static func climbs_selvi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("selvi", k)

static func build_cali(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("cali", host, k, lod)
static func perches_cali(k: float = 0.5) -> Array:
	return Ayrinti.perches("cali", k)
static func climbs_cali(k: float = 0.5) -> Array:
	return Ayrinti.climbs("cali", k)

static func build_cicek_tarhasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("cicek_tarhasi", host, k, lod)
static func perches_cicek_tarhasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("cicek_tarhasi", k)
static func climbs_cicek_tarhasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("cicek_tarhasi", k)

static func build_tas_kemer(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tas_kemer", host, k, lod)
static func perches_tas_kemer(k: float = 0.5) -> Array:
	return Ayrinti.perches("tas_kemer", k)
static func climbs_tas_kemer(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tas_kemer", k)

static func build_sokak_basamagi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sokak_basamagi", host, k, lod)
static func perches_sokak_basamagi(k: float = 0.5) -> Array:
	return Ayrinti.perches("sokak_basamagi", k)
static func climbs_sokak_basamagi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sokak_basamagi", k)

static func build_direk_fener(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("direk_fener", host, k, lod)
static func perches_direk_fener(k: float = 0.5) -> Array:
	return Ayrinti.perches("direk_fener", k)
static func climbs_direk_fener(k: float = 0.5) -> Array:
	return Ayrinti.climbs("direk_fener", k)

static func build_sundurma(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("sundurma", host, k, lod)
static func perches_sundurma(k: float = 0.5) -> Array:
	return Ayrinti.perches("sundurma", k)
static func climbs_sundurma(k: float = 0.5) -> Array:
	return Ayrinti.climbs("sundurma", k)

static func build_agac_govde_kutugu(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("agac_govde_kutugu", host, k, lod)
static func perches_agac_govde_kutugu(k: float = 0.5) -> Array:
	return Ayrinti.perches("agac_govde_kutugu", k)
static func climbs_agac_govde_kutugu(k: float = 0.5) -> Array:
	return Ayrinti.climbs("agac_govde_kutugu", k)

static func build_kuru_ot_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kuru_ot_yigini", host, k, lod)
static func perches_kuru_ot_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("kuru_ot_yigini", k)
static func climbs_kuru_ot_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kuru_ot_yigini", k)

static func build_kilise_kapi_sundurmasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("kilise_kapi_sundurmasi", host, k, lod)
static func perches_kilise_kapi_sundurmasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("kilise_kapi_sundurmasi", k)
static func climbs_kilise_kapi_sundurmasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("kilise_kapi_sundurmasi", k)

static func build_tahta_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tahta_yigini", host, k, lod)
static func perches_tahta_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("tahta_yigini", k)
static func climbs_tahta_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tahta_yigini", k)

static func build_baglama_kazigi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("baglama_kazigi", host, k, lod)
static func perches_baglama_kazigi(k: float = 0.5) -> Array:
	return Ayrinti.perches("baglama_kazigi", k)
static func climbs_baglama_kazigi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("baglama_kazigi", k)

static func build_su_kovasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("su_kovasi", host, k, lod)
static func perches_su_kovasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("su_kovasi", k)
static func climbs_su_kovasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("su_kovasi", k)

static func build_toprak_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("toprak_yigini", host, k, lod)
static func perches_toprak_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("toprak_yigini", k)
static func climbs_toprak_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("toprak_yigini", k)

static func build_cuval_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("cuval_yigini", host, k, lod)
static func perches_cuval_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("cuval_yigini", k)
static func climbs_cuval_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("cuval_yigini", k)

static func build_firin_kuregi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("firin_kuregi", host, k, lod)
static func perches_firin_kuregi(k: float = 0.5) -> Array:
	return Ayrinti.perches("firin_kuregi", k)
static func climbs_firin_kuregi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("firin_kuregi", k)

static func build_tas_oturak(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tas_oturak", host, k, lod)
static func perches_tas_oturak(k: float = 0.5) -> Array:
	return Ayrinti.perches("tas_oturak", k)
static func climbs_tas_oturak(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tas_oturak", k)

static func build_hasir(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("hasir", host, k, lod)
static func perches_hasir(k: float = 0.5) -> Array:
	return Ayrinti.perches("hasir", k)
static func climbs_hasir(k: float = 0.5) -> Array:
	return Ayrinti.climbs("hasir", k)

static func build_hasir_perde(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("hasir_perde", host, k, lod)
static func perches_hasir_perde(k: float = 0.5) -> Array:
	return Ayrinti.perches("hasir_perde", k)
static func climbs_hasir_perde(k: float = 0.5) -> Array:
	return Ayrinti.climbs("hasir_perde", k)

static func build_yol_tasi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("yol_tasi", host, k, lod)
static func perches_yol_tasi(k: float = 0.5) -> Array:
	return Ayrinti.perches("yol_tasi", k)
static func climbs_yol_tasi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("yol_tasi", k)

static func build_tas_kaide(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tas_kaide", host, k, lod)
static func perches_tas_kaide(k: float = 0.5) -> Array:
	return Ayrinti.perches("tas_kaide", k)
static func climbs_tas_kaide(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tas_kaide", k)

static func build_balik_sepeti_yuk(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("balik_sepeti_yuk", host, k, lod)
static func perches_balik_sepeti_yuk(k: float = 0.5) -> Array:
	return Ayrinti.perches("balik_sepeti_yuk", k)
static func climbs_balik_sepeti_yuk(k: float = 0.5) -> Array:
	return Ayrinti.climbs("balik_sepeti_yuk", k)

static func build_tulum_yigini(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tulum_yigini", host, k, lod)
static func perches_tulum_yigini(k: float = 0.5) -> Array:
	return Ayrinti.perches("tulum_yigini", k)
static func climbs_tulum_yigini(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tulum_yigini", k)

static func build_tas_havan(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("tas_havan", host, k, lod)
static func perches_tas_havan(k: float = 0.5) -> Array:
	return Ayrinti.perches("tas_havan", k)
static func climbs_tas_havan(k: float = 0.5) -> Array:
	return Ayrinti.climbs("tas_havan", k)

static func build_set_pazar_kosesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_pazar_kosesi", host, k, lod)
static func perches_set_pazar_kosesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_pazar_kosesi", k)
static func climbs_set_pazar_kosesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_pazar_kosesi", k)

static func build_set_firin_onu(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_firin_onu", host, k, lod)
static func perches_set_firin_onu(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_firin_onu", k)
static func climbs_set_firin_onu(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_firin_onu", k)

static func build_set_balikci_iskelesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_balikci_iskelesi", host, k, lod)
static func perches_set_balikci_iskelesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_balikci_iskelesi", k)
static func climbs_set_balikci_iskelesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_balikci_iskelesi", k)

static func build_set_bostan_kosesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_bostan_kosesi", host, k, lod)
static func perches_set_bostan_kosesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_bostan_kosesi", k)
static func climbs_set_bostan_kosesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_bostan_kosesi", k)

static func build_set_sur_onarim_santiyesi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_sur_onarim_santiyesi", host, k, lod)
static func perches_set_sur_onarim_santiyesi(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_sur_onarim_santiyesi", k)
static func climbs_set_sur_onarim_santiyesi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_sur_onarim_santiyesi", k)

static func build_set_manastir_avlusu(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_manastir_avlusu", host, k, lod)
static func perches_set_manastir_avlusu(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_manastir_avlusu", k)
static func climbs_set_manastir_avlusu(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_manastir_avlusu", k)

static func build_set_meyhane_onu(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_meyhane_onu", host, k, lod)
static func perches_set_meyhane_onu(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_meyhane_onu", k)
static func climbs_set_meyhane_onu(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_meyhane_onu", k)

static func build_set_demirci(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_demirci", host, k, lod)
static func perches_set_demirci(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_demirci", k)
static func climbs_set_demirci(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_demirci", k)

static func build_set_dokumaci_boyaci(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_dokumaci_boyaci", host, k, lod)
static func perches_set_dokumaci_boyaci(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_dokumaci_boyaci", k)
static func climbs_set_dokumaci_boyaci(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_dokumaci_boyaci", k)

static func build_set_multeci_cadirlari(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_multeci_cadirlari", host, k, lod)
static func perches_set_multeci_cadirlari(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_multeci_cadirlari", k)
static func climbs_set_multeci_cadirlari(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_multeci_cadirlari", k)

static func build_set_ayin_alayi(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	Ayrinti.build("set_ayin_alayi", host, k, lod)
static func perches_set_ayin_alayi(k: float = 0.5) -> Array:
	return Ayrinti.perches("set_ayin_alayi", k)
static func climbs_set_ayin_alayi(k: float = 0.5) -> Array:
	return Ayrinti.climbs("set_ayin_alayi", k)

