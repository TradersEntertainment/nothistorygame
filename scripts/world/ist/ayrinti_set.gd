class_name AyrintiSet
extends RefCounted
## Hazır "köşe" grupları: build_set_<ad>. Öğeler gerçek ölçüde kalır; k yalnız öğeler arası aralığı açar (1,0–1,3 kat).
## Yerleşim satırı: [öğe id, x, y, z, yön_derece]. Yerel koordinat; merkez grubun ortası, +x doğu, -z kuzey.

const SET_DEFS := [
	["pazar_kosesi", "Pazar köşesi", Vector3(18, 3.0, 9)],
	["firin_onu", "Fırın önü", Vector3(9, 3.0, 8)],
	["balikci_iskelesi", "Balıkçı iskelesi", Vector3(14, 3.0, 12)],
	["bostan_kosesi", "Bostan köşesi", Vector3(12, 6.0, 9)],
	["sur_onarim_santiyesi", "Sur onarım şantiyesi", Vector3(14, 3.6, 9)],
	["manastir_avlusu", "Manastır avlusu", Vector3(14, 6.0, 12)],
	["meyhane_onu", "Meyhane önü", Vector3(10, 3.0, 7)],
	["demirci", "Demirci köşesi", Vector3(9, 2.0, 7)],
	["dokumaci_boyaci", "Dokumacı ve boyacı köşesi", Vector3(12, 2.4, 8)],
	["multeci_cadirlari", "Mülteci çadırları", Vector3(16, 2.4, 12)],
	["ayin_alayi", "Ayin alayı hazırlığı", Vector3(12, 3.2, 8)],
]

const PLACE := {
	"pazar_kosesi": [
		["tente", -4, 0, -3.4, 0], ["tezgah", -4, 0, -3.4, 0], ["terazi", -3.4, 0.96, -3.4, 0], ["tente", 3.5, 0, -3.4, 0],
		["tezgah", 2.9, 0, -3.4, 0], ["kase_tezgahi", 4.6, 0, -3.4, 0], ["amfora", -7.6, 0, -3.0, 0], ["amfora", -7.2, 0, -3.1, 0],
		["pithos", -8.5, 0, -3.0, 0], ["fici", -6.3, 0, -2.5, 0], ["sepet", 0, 0, -1.6, 0], ["sepet", 0.55, 0, -1.6, 0],
		["cuval", -1.1, 0, -1.3, 0], ["cuval", -1.6, 0, -1.3, 0], ["el_arabasi", 7.0, 0, -1.0, 90], ["tabela", 8.2, 0, -3.5, 0],
		["kedi", 1.8, 0, 0.5, 20], ["tavuk", -2.5, 0, 0.3, 40], ["tavuk", -2.0, 0, 0.8, 200], ["bank", -6.0, 0, 2.5, 0],
		["esek_semeri", 5.0, 0, 2.0, 0], ["sandik_yigini", 8.0, 0, 2.2, 0], ["cop", -1.0, 0, 3.0, 0], ["su_birikintisi", 2.0, 0, 3.4, 0],
	],
	"firin_onu": [
		["firin", 0, 0, -3, 0], ["odun_yigini", -4.2, 0, -3.2, 0], ["sepet", 1.8, 0, -1.2, 0], ["sepet", 2.4, 0, -1.2, 0],
		["cuval", 3.0, 0, -2.6, 0], ["cuval", 3.5, 0, -2.6, 0], ["masa", 3.8, 0, 0.6, 0], ["tabure", 2.4, 0, 1.0, 0],
		["tandir", -3.2, 0, 0.5, 0], ["kopek", -1.5, 0, 1.8, 90], ["fici", -4.0, 0, 2.0, 0], ["yalak", 3.8, 0, 2.8, 0],
		["sandik", -3.4, 0, -0.9, 0],
	],
	"balikci_iskelesi": [
		["iskele", 0, 0, 2.0, 90], ["kayik", -5.0, 0, -3.0, 20], ["kayik", 5.0, 0, -3.5, -15], ["ag_sehpasi", -1.0, 0, -4.2, 0],
		["balik_agi", 2.0, 0, -2.0, 0], ["balik_kasasi", -2.8, 0, -0.6, 0], ["balik_kasasi", -2.2, 0, -0.6, 0], ["balik_kurutma", 3.0, 0, -5.2, 0],
		["capa", 0.5, 0, -0.5, 0], ["kurek", -3.4, 0, -1.4, 0], ["halat_rulo", 1.0, 0, 0.0, 0], ["palamar_babasi", 1.0, 0, 4.4, 0],
		["marti", 2.0, 0.78, 0.0, 0], ["kedi", -3.5, 0, 1.2, 80], ["fici", 6.0, 0, 0.8, 0],
	],
	"bostan_kosesi": [
		["bostan_sirasi", -3.0, 0, -1.0, 0], ["bostan_sirasi", 1.0, 0, -1.0, 0], ["bostan_sirasi", -3.0, 0, 1.2, 0], ["bostan_sirasi", 1.0, 0, 1.2, 0],
		["korkuluk", -1.0, 0, 0.1, 0], ["cit", -4.2, 0, -3.0, 0], ["cit", -1.2, 0, -3.0, 0], ["cit", 1.8, 0, -3.0, 0], ["bahce_kapisi", 5.2, 0, -3.0, 0],
		["kuyu", 5.0, 0, 1.2, 0], ["yalak", 3.8, 0, 3.2, 0], ["meyve_agaci", -5.0, 0, 3.6, 0], ["zeytin_agaci", 3.0, 0, -4.8, 0],
		["saksi", 2.0, 0, 3.0, 0], ["saksi", 2.5, 0, 3.0, 0], ["kutuk", 0.0, 0, 3.4, 0], ["tavuk", -2.0, 0, 3.0, 20], ["cali", -6.0, 0, -0.5, 0],
	],
	"sur_onarim_santiyesi": [
		["yapi_iskelesi", -2.0, 0, -2.5, 0], ["cikrik_vinc", 4.5, 0, -2.0, 0], ["tas_yigini", -5.5, 0, 2.0, 0], ["tugla_yigini", 1.0, 0, 3.0, 0],
		["harc_teknesi", 3.4, 0, 3.0, 0], ["kirec_ocagi", -2.5, 0, 3.2, 0], ["kazma_kurek", 5.8, 0, 3.2, 0], ["sandik_yigini", -6.0, 0, -1.0, 0],
		["el_arabasi", 1.2, 0, 0.2, 40], ["kiremit_yigini", 6.0, 0, 1.0, 0], ["yikik_duvar", 3.5, 0, 6.4, 0], ["merdiven", -0.8, 0, -4.8, 0],
	],
	"manastir_avlusu": [
		["tas_havuz", 0, 0, 0, 0], ["can_cercevesi", -5.0, 0, -4.0, 0], ["kandil", 3.6, 0, -1.0, 0], ["mum_sehpasi", 3.5, 0, -3.0, 0],
		["hacli_tas", -3.2, 0, 3.0, 0], ["bank", 3.6, 0, 2.4, 0], ["mezar_tasi", -5.0, 0, 3.0, 0], ["mezar_tasi", -4.2, 0, 3.4, 0],
		["lahit", 5.2, 0, -4.8, 0], ["ikona_nisi", 0, 0, -5.4, 0], ["selvi", -6.0, 0, 0.0, 0], ["saksi", 2.8, 0, 4.0, 0],
		["vaftiz_kurnasi", 6.0, 0, 1.0, 0], ["buhurdan", 2.2, 0, -3.2, 0], ["sutun_baslik", -2.2, 0, 4.4, 20],
	],
	"meyhane_onu": [
		["masa", -2.8, 0, -1.0, 0], ["masa", 0.2, 0, 1.0, 0], ["tabure", -3.4, 0, 0.0, 0], ["tabure", -2.2, 0, 0.0, 0], ["tabure", -0.4, 0, 2.0, 0],
		["tabure", 0.8, 0, 2.0, 0], ["sarap_fici", 3.4, 0, -2.2, 0], ["fici", 4.6, 0, -2.2, 0], ["asma_cardagi", -2.0, 0, -4.0, 0],
		["tabela", 3.2, 0, -4.0, 0], ["mum_sehpasi", 1.2, 0, -1.0, 0], ["testi", -1.0, 0, 3.0, 0], ["kopek", 4.0, 0, 1.0, 30],
		["amfora", 4.9, 0, 0.0, 0], ["kandil", 0.0, 0, -2.0, 0],
	],
	"demirci": [
		["demir_ocagi", -2.0, 0, -2.5, 0], ["ors", 0.6, 0, -1.0, 0], ["soguma_teknesi", 2.2, 0, -2.2, 0], ["kutuk", 2.8, 0, 0.8, 0],
		["tezgah", -2.5, 0, 1.2, 0], ["sandik", 3.2, 0, 2.6, 0], ["cuval", -3.6, 0, -0.4, 0], ["kutuk_kutugu", 0.0, 0, 2.4, 0], ["capa", -4.2, 0, 2.6, 0],
		["mesale_diregi", 1.0, 0, -3.5, 0],
	],
	"dokumaci_boyaci": [
		["dokuma_tezgahi", -3.5, 0, -1.5, 0], ["boya_kazani", 0.8, 0, -1.8, 0], ["boya_askisi", 1.8, 0, 1.6, 0], ["kumas_topu", -3.5, 0, 1.2, 0],
		["kumas_topu", -2.4, 0, 1.2, 0], ["yun_balyasi", -5.5, 0, 0.0, 0], ["yun_balyasi", -5.5, 0, 0.8, 0], ["fici", 3.6, 0, -2.0, 0], ["sepet", 4.6, 0, -1.6, 0],
		["deri_gerdirme", 4.8, 0, 1.6, 0], ["masa", -0.8, 0, 2.6, 0],
	],
	"multeci_cadirlari": [
		["multeci_cadiri", -5.0, 0, -2.0, 0], ["multeci_cadiri", 0.0, 0, -3.0, 90], ["multeci_cadiri", 5.0, 0, -2.0, 0], ["yer_yatagi", -5.0, 0, 2.2, 0],
		["kamp_atesi", -1.0, 0, 1.5, 0], ["kazan", 1.4, 0, 2.2, 0], ["esek", 5.0, 0, 2.5, 90], ["saman_balyasi", 3.4, 0, 3.8, 0], ["yer_yatagi", 7.0, 0, 1.0, 0],
		["cuval", -3.0, 0, 3.5, 0], ["sandik", -2.4, 0, 3.6, 0], ["kedi", -2.0, 0, 0.2, 20], ["camasir_ipi", 3.0, 0, 5.0, 0],
	],
	"ayin_alayi": [
		["ayin_bayragi", -3.0, 0, -2.0, 0], ["ayin_bayragi", 3.0, 0, -2.0, 0], ["ikon_sehpasi", 0.0, 0, -1.0, 0], ["buhurdan", -1.6, 0, 0.5, 0],
		["buhurdan", 1.6, 0, 0.5, 0], ["mum_sehpasi", -4.2, 0, 1.2, 0], ["mum_sehpasi", 4.2, 0, 1.2, 0], ["kandil", 0.0, 0, 2.0, 0], ["sandik", 0.0, 0, 3.0, 0],
		["hacli_tas", 0.0, 0, -3.4, 0], ["mesale_diregi", -5.4, 0, -0.5, 0], ["mesale_diregi", 5.4, 0, -0.5, 0],
	],
}

const PERCH := {
	"pazar_kosesi": [Vector3(3.5, 2.55, -3.4)], "firin_onu": [Vector3(0.0, 2.0, -3.0)], "balikci_iskelesi": [Vector3(0, 0.9, 5.0)],
	"bostan_kosesi": [Vector3(5.0, 2.0, 1.2)], "sur_onarim_santiyesi": [Vector3(-2.0, 3.4, -2.5)], "manastir_avlusu": [Vector3(-5.0, 2.8, -4.0)],
	"meyhane_onu": [Vector3(-2.0, 2.65, -4.0)], "demirci": [Vector3(-2.0, 1.5, -2.5)], "dokumaci_boyaci": [Vector3(1.8, 2.3, 1.6)],
	"multeci_cadirlari": [Vector3(0.0, 1.7, -3.0)], "ayin_alayi": [Vector3(-3.0, 3.0, -2.0)],
}

const CLIMB := {
	"sur_onarim_santiyesi": [[Vector3(-5.0, 0, -2.5), Vector3(-2.0, 1.6, -2.5), "iskele"], [Vector3(-4.5, 0, -1.0), Vector3(-3.0, 1.0, -1.0), "sandik"]],
	"firin_onu": [[Vector3(2.0, 0, -0.5), Vector3(0.0, 2.0, -3.0), "sandik"]],
	"pazar_kosesi": [[Vector3(8.0, 0, 3.3), Vector3(8.0, 1.0, 1.7), "sandik"]],
}


static func _sp(k: float) -> float:
	return clampf(0.9 + k * 0.3, 1.0, 1.3)


static func build_set(name: String, host: Node3D, k: float, lod: int) -> Node3D:
	if not PLACE.has(name):
		return null
	var root := Node3D.new()
	root.name = "set_" + name
	host.add_child(root)
	var sp := _sp(k)
	for r in PLACE[name]:
		var it := Node3D.new()
		it.position = Vector3(r[1] * sp, r[2], r[3] * sp)
		it.rotation_degrees.y = r[4]
		root.add_child(it)
		Ayrinti.build(r[0], it, k, lod)
	return root


static func perches_set(name: String) -> Array:
	return PERCH.get(name, [])


static func climbs_set(name: String) -> Array:
	return CLIMB.get(name, [])
