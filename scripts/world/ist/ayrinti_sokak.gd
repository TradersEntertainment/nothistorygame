extends RefCounted
## İstanbul v2 DOKU-3: SOKAK EŞYASI katmanı ("milyar parça" duygusu, 1453'e uyarlanmış). class_name yok:
## IstMahalleDoku preload eder. Her evin önüne (cephe dibine, sokağa taşmadan) mahalle türüne göre 0–3 öğe:
## fıçı, sepet, amfora, çuval, odun yığını, el arabası, saksı, tabure, sandık, testi, kütük, kedi, tavuk…; iskelede ağ, halat,
## balık kasası, yelken bezi, balya; sur dibinde taş/tuğla yığını, harç teknesi, gülle, ok sandığı.
## Çizim: her öğe türü Ayrinti kurucusundan BİR KEZ tek ağa pişirilir (Crowd._bake, köşe renkli, LOD'lu); yerleşim 64 m hücre ×
## tür başına bir MultiMesh (çarpışmasız, gölgesiz, görünürlük 0–UZAK m). Kurulum açılışta bir kez.

const HUCRE := 64.0
const UZAK := 115.0       # hücre merkezine uzaklık (hücre yarı köşegeni 45 m: 70 m içindeki öğe hep görünür)

## mahalle türü → [öğe, ağırlık]
const SEC := {
	"carsi": [["amfora", 3], ["sepet", 4], ["cuval", 4], ["fici", 3], ["sandik", 3], ["testi", 3], ["kumas_topu", 2], ["pithos", 1],
		["tabure", 2], ["saksi", 1], ["kedi", 1], ["el_arabasi", 1], ["kase_tezgahi", 1], ["mum_sehpasi", 1]],
	"liman": [["halat_rulo", 4], ["balik_kasasi", 4], ["fici", 3], ["yelken_bezi", 2], ["yun_balyasi", 2], ["sepet", 2], ["cuval", 2],
		["amfora", 2], ["kurek", 1], ["balik_agi", 1], ["kedi", 1], ["sandik", 2]],
	"sik": [["saksi", 4], ["odun_yigini", 2], ["sepet", 3], ["fici", 2], ["tabure", 3], ["testi", 3], ["kutuk_kutugu", 1], ["sandik", 1],
		["el_arabasi", 1], ["kedi", 2], ["tavuk", 2], ["amfora", 1], ["cop", 1], ["kutuk", 1]],
	"seyrek": [["odun_yigini", 3], ["saksi", 2], ["sepet", 2], ["tavuk", 3], ["kutuk_kutugu", 2], ["el_arabasi", 1], ["saman_balyasi", 2],
		["fici", 1], ["kedi", 1], ["ari_kovani", 1], ["testi", 1]],
	"sur_dibi": [["tas_yigini", 2], ["tugla_yigini", 2], ["harc_teknesi", 1], ["gulle_yigini", 2], ["ok_sandigi", 2], ["fici", 2],
		["odun_yigini", 2], ["sepet", 1], ["gabyon", 2], ["kazma_kurek", 1], ["kedi", 1], ["saksi", 1]],
}
const MEYDAN_SEC := {
	"carsi": [["tezgah", 3], ["bank", 2], ["amfora", 2], ["sepet", 2], ["testi", 2], ["kase_tezgahi", 2], ["terazi", 1], ["fici", 1]],
	"liman": [["balik_kasasi", 3], ["halat_rulo", 2], ["bank", 2], ["fici", 2], ["sepet", 2], ["balik_kurutma", 1]],
	"sik": [["bank", 3], ["testi", 2], ["sepet", 2], ["saksi", 2], ["tabure", 2], ["masa", 1], ["kedi", 1], ["amfora", 1]],
	"seyrek": [["bank", 2], ["yalak", 2], ["saman_balyasi", 2], ["testi", 1], ["tavuk", 2], ["sepet", 1]],
	"sur_dibi": [["bank", 2], ["ok_sandigi", 2], ["mizraklik", 1], ["fici", 2], ["mangal", 1], ["tas_yigini", 1]],
}
const ADET := {"carsi": [1, 3], "liman": [1, 3], "sik": [0, 2], "seyrek": [0, 2], "sur_dibi": [0, 2]}

var doku: Node3D
var sk: IstSokak
var stats := {}
var _mesh := {}
var _hucre := {}            # Vector2i → {öğe: PackedFloat32Array (12 kayan / örnek)}


func _init(doku_: Node3D, sk_: IstSokak) -> void:
	doku = doku_
	sk = sk_


func _tur(p: Vector2) -> String:
	var m := IstGeo.mahalle(p.x, p.y)
	var t := String(m.get("tur", "sik"))
	if t in ["bostan", "harabe", "kir"]:
		return "seyrek"
	return t if SEC.has(t) else "sik"


func _sec(liste: Array, rng: RandomNumberGenerator) -> String:
	var top := 0
	for e: Array in liste:
		top += int(e[1])
	var r := rng.randi_range(0, top - 1)
	for e: Array in liste:
		r -= int(e[1])
		if r < 0:
			return String(e[0])
	return String(liste[0][0])


## Nokta sokakta (yol hücresi) ve çevresi (r) evin/anıtın içine taşmıyor mu
func _yer_uygun(p: Vector2, r: float) -> bool:
	if IstGeo.su(p.x, p.y):
		return false
	var c := sk.cell(p.x, p.y)
	if c != 1 and c != 0 and c != 5 and c != 6:
		return false
	for a in 4:
		var q := p + Vector2.from_angle(a * PI * 0.5) * r
		var cq := sk.cell(q.x, q.y)
		if cq == 3 or cq == 4:
			return false
	return true


func kur() -> void:
	var t0 := Time.get_ticks_msec()
	var rng := RandomNumberGenerator.new()
	rng.seed = 145319
	var n := 0
	var tur_say := {}
	for h: Dictionary in sk.houses:
		var c: Vector2 = h["c"]
		var on: Vector2 = h["on"]
		if not IstGeo.sehir_ici(c.x, c.y) and not IstGeo.galata_ici(c.x, c.y):
			continue
		var dis := on - c
		if dis.length() < 0.01:
			continue
		dis = dis.normalized()
		var yan := Vector2(-dis.y, dis.x)
		var dm := IstEvler.dims(int(h["v"]))
		var mt := _tur(on)
		var ad: Array = ADET[mt]
		var tip := String(h.get("tip", ""))
		var k := rng.randi_range(int(ad[0]), int(ad[1]))
		if tip == "harap":
			k = mini(k, 1)
		var kullanilan: Array = []
		for i in k:
			var id := _sec(SEC[mt], rng)
			var bo := _boy(id)
			# cephe boyunca kapıdan uzak (kapı ortada: ±0,9 m boş), duvardan öğenin yarı derinliği + 0,15 m
			var s := rng.randf_range(0.9, maxf(1.0, dm.x * 0.5 - 0.3)) * (1.0 if rng.randf() < 0.5 else -1.0)
			if tip == "dukkan":
				s = signf(s) * maxf(absf(s), dm.x * 0.5 - 0.4)
			var p := on + yan * s + dis * (bo.z * 0.5 + 0.15)
			var cakis := false
			for q: Vector2 in kullanilan:
				if q.distance_to(p) < 0.9:
					cakis = true
			if cakis or not _yer_uygun(p, 0.3):
				continue
			kullanilan.append(p)
			var yaw := atan2(dis.x, dis.y) + (rng.randf_range(-0.4, 0.4) if id != "kedi" else rng.randf() * TAU)
			if id in ["odun_yigini", "tas_yigini", "tugla_yigini", "el_arabasi", "kurek", "kazma_kurek", "balik_agi"]:
				yaw = atan2(yan.x, yan.y)       # duvara yaslı (uzun yanı cepheye paralel)
				p = on + yan * s + dis * (bo.x * 0.0 + bo.z * 0.5 + 0.12)
			var y := IstGeo.h(p.x, p.y)
			if IstMahalleDoku.aktif != null and is_instance_valid(IstMahalleDoku.aktif):
				y = maxf(y, IstMahalleDoku.aktif._zy(p.x, p.y))
			_ekle(id, Transform3D(Basis(Vector3.UP, yaw), Vector3(p.x, y, p.y)))
			n += 1
			tur_say[id] = int(tur_say.get(id, 0)) + 1
	# meydan köşe grupları: kuyu/çeşmenin (ŞEHİR kurar, merkezde) çevresinde 3,6–5 m halkada 4–6 öğe
	var nm := 0
	for m: Dictionary in sk.meydan:
		var c: Vector2 = m["c"]
		var mt := _tur(c)
		var liste: Array = MEYDAN_SEC.get(mt, MEYDAN_SEC["sik"])
		var a0 := rng.randf() * TAU
		for i in rng.randi_range(4, 6):
			var ang := a0 + i * TAU / 6.0 + rng.randf_range(-0.2, 0.2)
			var p := c + Vector2.from_angle(ang) * rng.randf_range(3.6, 5.0)
			if not _yer_uygun(p, 0.3):
				continue
			var id := _sec(liste, rng)
			var y := IstGeo.h(p.x, p.y)
			if IstMahalleDoku.aktif != null and is_instance_valid(IstMahalleDoku.aktif):
				y = maxf(y, IstMahalleDoku.aktif._zy(p.x, p.y))
			_ekle(id, Transform3D(Basis(Vector3.UP, -ang + PI * 0.5 + rng.randf_range(-0.3, 0.3)), Vector3(p.x, y, p.y)))
			nm += 1
			tur_say[id] = int(tur_say.get(id, 0)) + 1
	_cizim()
	stats = {"meydan_oge": nm, "oge": n, "hucre": _hucre.size(), "tur": _mesh.size(), "kur_ms": Time.get_ticks_msec() - t0}
	print("ISTDOKU3 sokak_esyasi ", stats, " ", tur_say)


var _boylar := {}
func _boy(id: String) -> Vector3:
	if _boylar.is_empty():
		for pr in Ayrinti._rows():
			_boylar[pr[1][0]] = Vector3(pr[1][2], pr[1][3], pr[1][4])
	return _boylar.get(id, Vector3(0.6, 0.6, 0.6))


func _ekle(id: String, xf: Transform3D) -> void:
	var key := Vector2i(floori(xf.origin.x / HUCRE), floori(xf.origin.z / HUCRE))
	if not _hucre.has(key):
		_hucre[key] = {}
	var d: Dictionary = _hucre[key]
	var a: PackedFloat32Array = d.get(id, PackedFloat32Array())
	var b := xf.basis
	var o := xf.origin
	a.append_array(PackedFloat32Array([b.x.x, b.y.x, b.z.x, o.x, b.x.y, b.y.y, b.z.y, o.y, b.x.z, b.y.z, b.z.z, o.z]))
	d[id] = a


func _ag(id: String) -> Mesh:
	if _mesh.has(id):
		return _mesh[id]
	var root := Node3D.new()
	Ayrinti.build(id, root, 0.5, 1)
	var m := Crowd._bake(root, Callable())
	_mesh[id] = m
	return m


func _cizim() -> void:
	var mat := CharKit.vc_mat(false)
	for key: Vector2i in _hucre:
		var d: Dictionary = _hucre[key]
		var host := Node3D.new()
		host.name = "SokakEsya_%d_%d" % [key.x, key.y]
		doku.add_child(host)
		for id: String in d:
			var a: PackedFloat32Array = d[id]
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = _ag(id)
			mm.instance_count = a.size() / 12
			mm.buffer = a
			var mi := MultiMeshInstance3D.new()
			mi.multimesh = mm
			mi.material_override = mat
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.visibility_range_end = UZAK
			mi.visibility_range_end_margin = 6.0
			mi.set_meta("no_walk", true)
			mi.set_meta("soft", true)
			host.add_child(mi)
