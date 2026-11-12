extends RefCounted
## İstanbul v2 DOKU-3: SOKAK EŞYASI katmanı ("milyar parça" duygusu, 1453'e uyarlanmış). class_name yok:
## IstMahalleDoku preload eder. Her evin önüne (cephe dibine, sokağa taşmadan) mahalle türüne göre 0–3 öğe:
## fıçı, sepet, amfora, çuval, odun yığını, el arabası, saksı, tabure, sandık, testi, kütük, kedi, tavuk…; iskelede ağ, halat,
## balık kasası, yelken bezi, balya; sur dibinde taş/tuğla yığını, harç teknesi, gülle, ok sandığı.
## Çizim: her öğe türü Ayrinti kurucusundan BİR KEZ tek ağa pişirilir (Crowd._bake, köşe renkli); oyuncunun çevresinde (140 m)
## 48 m'lik hücrenin bütün öğeleri TEK ağa birleşir (hücre başına bir çizim; çarpışmasız, gölgesiz, görünürlük 125 m), kare
## başına bütçeyle akar, 210 m ötesi silinir. (Tür başına MultiMesh denendi: hücre × tür çizimi yerde bütçeyi aşıyordu.)

const HUCRE := 48.0
const UZAK := 125.0       # hücre merkezine uzaklık (hücre yarı köşegeni 34 m: 90 m içindeki öğe hep görünür)

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
var noktalar := {}          # Vector2i(8 m) → PackedVector2Array (denetim: kişi eşyanın içinde mi)
var _hucre := {}            # Vector2i(48 m) → [[öğe, Transform3D]]


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
	stats = {"meydan_oge": nm, "oge": n, "hucre": _hucre.size(), "tur": _mesh.size(), "kur_ms": Time.get_ticks_msec() - t0}
	print("ISTDOKU3 sokak_esyasi ", stats, " ", tur_say)


var _boylar := {}
## Denetim: noktaya r'den yakın sokak eşyası var mı
func esya_yakin(p: Vector2, r: float) -> bool:
	var k := Vector2i(floori(p.x / 8.0), floori(p.y / 8.0))
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			var na = noktalar.get(k + Vector2i(dx, dz))
			if na == null:
				continue
			for q: Vector2 in na:
				if q.distance_to(p) < r:
					return true
	return false


func _boy(id: String) -> Vector3:
	if _boylar.is_empty():
		for pr in Ayrinti._rows():
			_boylar[pr[1][0]] = Vector3(pr[1][2], pr[1][3], pr[1][4])
	return _boylar.get(id, Vector3(0.6, 0.6, 0.6))


func _ekle(id: String, xf: Transform3D) -> void:
	var key := Vector2i(floori(xf.origin.x / HUCRE), floori(xf.origin.z / HUCRE))
	if not _hucre.has(key):
		_hucre[key] = []
	(_hucre[key] as Array).append([id, xf])
	var nk := Vector2i(floori(xf.origin.x / 8.0), floori(xf.origin.z / 8.0))
	var na: PackedVector2Array = noktalar.get(nk, PackedVector2Array())
	na.append(Vector2(xf.origin.x, xf.origin.z))
	noktalar[nk] = na


## Tür ağı: Ayrinti kurucusundan pişmiş, indekssiz açılmış [köşe, normal, renk] (hücre birleştirmesi yalnız append)
func _ag(id: String) -> Array:
	if _mesh.has(id):
		return _mesh[id]
	# kendi pişirme: dokulu malzemede (taş, tuğla, sıva desenleri) albedo × dokunun ortalama rengi (Crowd._bake dokuyu
	# atıyor: taş yığını bembeyaz kalıyordu)
	var root := Node3D.new()
	var tree := Engine.get_main_loop() as SceneTree
	root.visible = false
	tree.root.add_child(root)
	Ayrinti.build(id, root, 0.5, 1)
	var ov := PackedVector3Array()
	var on := PackedVector3Array()
	var oc := PackedColorArray()
	var inv := root.global_transform.affine_inverse()
	for c in root.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null or not mi.visible:
			continue
		var xf := inv * mi.global_transform
		var nb := Transform3D(xf.basis.inverse().transposed(), Vector3.ZERO)
		for si in mi.mesh.get_surface_count():
			var mat := mi.material_override as StandardMaterial3D
			if mat == null:
				mat = mi.get_surface_override_material(si) as StandardMaterial3D
			if mat == null:
				mat = mi.mesh.surface_get_material(si) as StandardMaterial3D
			if mat != null and (mat.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or mat.albedo_color.a < 0.99):
				continue
			var tint := Color.WHITE
			var vcol := true
			if mat != null:
				tint = mat.albedo_color
				vcol = mat.vertex_color_use_as_albedo
				if mat.albedo_texture != null:
					var a := World1453._avg(mat.albedo_texture)
					tint = Color(tint.r * a.r, tint.g * a.g, tint.b * a.b)
				if mat.emission_enabled:
					tint = tint.lerp(mat.emission, 0.3)
			var ar := mi.mesh.surface_get_arrays(si)
			var v: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
			var nr: PackedVector3Array = ar[Mesh.ARRAY_NORMAL] if ar[Mesh.ARRAY_NORMAL] != null else PackedVector3Array()
			var vc: PackedColorArray = ar[Mesh.ARRAY_COLOR] if ar[Mesh.ARRAY_COLOR] != null and vcol else PackedColorArray()
			var ix: PackedInt32Array = ar[Mesh.ARRAY_INDEX] if ar[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			var n := ix.size() if not ix.is_empty() else v.size()
			for i in n:
				var k := ix[i] if not ix.is_empty() else i
				ov.append(xf * v[k])
				on.append((nb * nr[k]).normalized() if k < nr.size() else Vector3.UP)
				var col := vc[k] if k < vc.size() else Color.WHITE
				oc.append(Color(col.r * tint.r, col.g * tint.g, col.b * tint.b, 1.0))
	tree.root.remove_child(root)
	root.queue_free()
	_mesh[id] = [ov, on, oc]
	return _mesh[id]


## Akış (IstMahalleDoku._process'ten): YAKIN içindeki hücreler birleştirilip kurulur (kare başına bütçe), SIL ötesi silinir.
const YAKIN := 140.0
const SIL := 210.0
var _kurulu := {}          # Vector2i → MeshInstance3D
var _kuyruk: Array = []
var _son := Vector3(1e9, 0, 1e9)

func bekleyen() -> int:
	return _kuyruk.size()


func akis(cp: Vector3, butce_us: int) -> void:
	if Vector2(cp.x - _son.x, cp.z - _son.z).length() > 12.0:
		_son = cp
		_kuyruk.clear()
		var lst: Array = []
		var r := int(ceil(YAKIN / HUCRE)) + 1
		var c0 := Vector2i(floori(cp.x / HUCRE), floori(cp.z / HUCRE))
		for dz in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var k := c0 + Vector2i(dx, dz)
				if not _hucre.has(k) or _kurulu.has(k):
					continue
				var d := Vector2((k.x + 0.5) * HUCRE - cp.x, (k.y + 0.5) * HUCRE - cp.z).length()
				if d < YAKIN:
					lst.append([d, k])
		lst.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
		for e: Array in lst:
			_kuyruk.append(e[1])
		for k: Vector2i in _kurulu.keys():
			var d := Vector2((k.x + 0.5) * HUCRE - cp.x, (k.y + 0.5) * HUCRE - cp.z).length()
			if d > SIL:
				(_kurulu[k] as Node).queue_free()
				_kurulu.erase(k)
	var t0 := Time.get_ticks_usec()
	while not _kuyruk.is_empty() and Time.get_ticks_usec() - t0 < butce_us:
		var k: Vector2i = _kuyruk.pop_front()
		if not _kurulu.has(k):
			_hucre_kur(k)


func _hucre_kur(k: Vector2i) -> void:
	var cen := Vector3((k.x + 0.5) * HUCRE, 0.0, (k.y + 0.5) * HUCRE)
	var vv := PackedVector3Array()
	var nn := PackedVector3Array()
	var cc := PackedColorArray()
	for e: Array in _hucre[k]:
		var t: Array = _ag(String(e[0]))
		var xf: Transform3D = e[1]
		xf.origin -= cen
		vv.append_array(xf * (t[0] as PackedVector3Array))
		nn.append_array(Transform3D(xf.basis, Vector3.ZERO) * (t[1] as PackedVector3Array))
		cc.append_array(t[2])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vv
	arr[Mesh.ARRAY_NORMAL] = nn
	arr[Mesh.ARRAY_COLOR] = cc
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	am.surface_set_material(0, CharKit.vc_mat(false))
	var mi := MeshInstance3D.new()
	mi.name = "SokakEsya_%d_%d" % [k.x, k.y]
	mi.mesh = am
	mi.position = cen
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.visibility_range_end = UZAK
	mi.visibility_range_end_margin = 8.0
	mi.set_meta("no_walk", true)
	mi.set_meta("soft", true)
	doku.add_child(mi)
	_kurulu[k] = mi
	stats["kurulan"] = int(stats.get("kurulan", 0)) + 1
