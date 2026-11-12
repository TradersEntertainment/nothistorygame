class_name IstKuzeybati
extends RefCounted
## Kuzeybati parçasının toplu girişi: bütün öğelerin kaydı ve kimlikle kurucu.
## Şehir kurucusu `IstKuzeybati.catalog()` ile kaydı okur, `IstKuzeybati.build(id, host, k, lod)` ile kurar.
## Yerel çerçeve pusula hizalıdır (+x doğu, -z kuzey); yapının ekseni build içinde yon_derece kadar uygulanmıştır.

static func catalog() -> Array:
	var all: Array = []
	all.append_array(IstKbKilise.catalog())
	all.append_array(IstKbSaray.catalog())
	all.append_array(IstKbSemt.catalog())
	return all


static func build(id: String, host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	match id:
		"khora": IstKbKilise.build_khora(host, k, lod)
		"pammakaristos": IstKbKilise.build_pammakaristos(host, k, lod)
		"blakhernai_kilise": IstKbKilise.build_blakhernai_kilise(host, k, lod)
		"petra": IstKbKilise.build_petra(host, k, lod)
		"tekfur": IstKbSaray.build_tekfur(host, k, lod)
		"anemas": IstKbSaray.build_anemas(host, k, lod)
		"kynegion": IstKbSaray.build_kynegion(host, k, lod)
		"aetios": IstKbSemt.build_aetios(host, k, lod)
		"kaligaria": IstKbSemt.build_kaligaria(host, k, lod)
		"ayvansaray_iskele": IstKbSemt.build_ayvansaray_iskele(host, k, lod)
		_: push_warning("IstKuzeybati: bilinmeyen id " + id)


static func perches(id: String, k: float = 0.5) -> Array:
	match id:
		"khora": return IstKbKilise.perches_khora(k)
		"pammakaristos": return IstKbKilise.perches_pammakaristos(k)
		"blakhernai_kilise": return IstKbKilise.perches_blakhernai_kilise(k)
		"petra": return IstKbKilise.perches_petra(k)
		"tekfur": return IstKbSaray.perches_tekfur(k)
		"anemas": return IstKbSaray.perches_anemas(k)
		"kynegion": return IstKbSaray.perches_kynegion(k)
		"aetios": return IstKbSemt.perches_aetios(k)
		"kaligaria": return IstKbSemt.perches_kaligaria(k)
		"ayvansaray_iskele": return IstKbSemt.perches_ayvansaray_iskele(k)
	return []


static func climbs(id: String, k: float = 0.5) -> Array:
	match id:
		"khora": return IstKbKilise.climbs_khora(k)
		"pammakaristos": return IstKbKilise.climbs_pammakaristos(k)
		"blakhernai_kilise": return IstKbKilise.climbs_blakhernai_kilise(k)
		"petra": return IstKbKilise.climbs_petra(k)
		"tekfur": return IstKbSaray.climbs_tekfur(k)
		"anemas": return IstKbSaray.climbs_anemas(k)
		"kynegion": return IstKbSaray.climbs_kynegion(k)
		"aetios": return IstKbSemt.climbs_aetios(k)
		"kaligaria": return IstKbSemt.climbs_kaligaria(k)
		"ayvansaray_iskele": return IstKbSemt.climbs_ayvansaray_iskele(k)
	return []
