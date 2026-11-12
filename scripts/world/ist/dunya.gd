class_name IstDunya
extends Node3D
## İstanbul v2 dünyası (docs/_ajan/gorev/ist2_dunya.md): arazi (parça parça ağ, uzaklığa göre ayrıntı), deniz, gök,
## güneş/ay, sis, uzak ufuk (Trakya, Anadolu tepeleri, Boğaz kıyıları, Adalar), oyuncunun çevresinde akışlı çarpışma,
## su yakalayıcı. Coğrafya: IstGeo. Sonunda IstSehir.attach_v2 (varsa) çağrılır.
##
## Bütçe: kurulum ilk kare ≤ 2 sn (kaba ayrıntı), sonrası kare başına ≤ BUDGET_US (ayrıntı + çarpışma zaman dilimli).

const BUDGET_US := 5000
## Kare başına iş bütçesi (µs); kare alma sondası büyütebilir
static var butce_us := BUDGET_US
## Çekirdek (şehir ve çevresi) parça ızgarası: GERÇEK kapsam (e −6144…+4608, n −3072…+6144 m) IstGeo.S ile dünyaya
## çevrilir ve CH'lik parçalara yuvarlanır (S değişince kendiliğinden uyar).
const CH := 768.0
const CE_A := -6144.0
const CE_B := 4608.0
const CN_A := -3072.0
const CN_B := 6144.0
static var CX0 := floorf(CE_A * IstGeo.S / CH) * CH
static var CZ0 := floorf(-CN_B * IstGeo.S / CH) * CH
static var CNX := int(ceilf((CE_B * IstGeo.S - CX0) / CH))
static var CNZ := int(ceilf((-CN_A * IstGeo.S - CZ0) / CH))

## Izgara kaydırmayla (IstGeo.OX/OZ, IstBaglama) yeniden türer: parça sınırları kaydırmasız dünyadakiyle aynı yere düşer
static func _izgara() -> void:
	CX0 = floorf(CE_A * IstGeo.S / CH) * CH + IstGeo.OX
	CZ0 = floorf(-CN_B * IstGeo.S / CH) * CH + IstGeo.OZ
	CNX = int(ceilf((CE_B * IstGeo.S + IstGeo.OX - CX0) / CH))
	CNZ = int(ceilf((-CN_A * IstGeo.S + IstGeo.OZ - CZ0) / CH))
## Ayrıntı düzeyleri: hücre boyu (m) ve devreye girme uzaklığı (parça dikdörtgenine yatay uzaklık)
const LOD_CELL := [6.0, 12.0, 24.0, 48.0]
const LOD_DIST := [150.0, 700.0, 1900.0]
const LOD_HYST := 40.0
## Dış halka (veri sınırına kadar) hücre boyu
const OUT_CELL := 64.0
## Etek derinliği (ayrıntı düzeyleri arası çatlak örtüsü)
const SKIRT := 3.0
## Denizin yakın (dalgalı) parçası
const SEA_NEAR := 1200.0
const SEA_SUB := 10.0
## Çarpışma: oyuncu/kamera çevresinde yükseklik haritası
const COL_N := 160            # hücre
const COL_STEP := 2.0         # m
const COL_MOVE := 70.0        # bu kadar uzaklaşınca yenilenir

## false: IstSehir.attach_v2 çağrılmaz (yalnız arazi denetimi)
static var sehir_bagla := true
## false: gök, güneş ve ortam kurulmaz (bölümün kendi gökyüzü ve ışığı kullanılır; IstBaglama)
static var gok_kur := true

var gece := false
var merkez := Vector3.ZERO
## İzlenen düğüm (oyuncu ya da kamera); yoksa etkin kamera
var izle: Node3D = null

var _chunks := {}             # Vector2i → {"mi": MeshInstance3D, "lod": int}
var _jobs: Array = []         # [anahtar, lod]
var _job: Dictionary = {}     # yürüyen iş
var _sea_near: MeshInstance3D
var _sea_far: Array = []
var _sea_center := Vector2(INF, INF)
var _col_body: StaticBody3D
var _col_shape: CollisionShape3D
var _col_center := Vector2(INF, INF)
var _col_job: Dictionary = {}
var _tur_cache := {}
var _env: Environment
var _sun: DirectionalLight3D
var _sky_mat: ProceduralSkyMaterial
var _water_mat: ShaderMaterial
var _t_kurulum_ms := 0.0
var _son_kare_us := 0
var _yakala_son := 0.0


static func build(parent: Node3D, gece_ := false, merkez_ := Vector3.ZERO) -> Node3D:
	_izgara()
	var d := IstDunya.new()
	d.name = "IstDunya"
	d.gece = gece_
	d.merkez = merkez_
	parent.add_child(d)
	d._kur()
	var S = load("res://scripts/world/ist/sehir.gd")
	if S != null and sehir_bagla:
		for m in (S as Script).get_script_method_list():
			if m.get("name", "") == "attach_v2":
				S.call("attach_v2", d, gece_)
				break
	return d


func _kur() -> void:
	var t0 := Time.get_ticks_usec()
	if gok_kur:
		_gok()
	_deniz()
	_ufuk()
	# çekirdek: önce hepsi kaba (lod 3), sonra merkeze yakınlar zaman dilimli inceltilir
	for i in CNX:
		for j in CNZ:
			var k := Vector2i(i, j)
			var mi := MeshInstance3D.new()
			mi.name = "Arazi_%d_%d" % [i, j]
			mi.material_override = _zemin_mat()
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(mi)
			_chunks[k] = {"mi": mi, "lod": -1}
			var job := _is_baslat(k, 3)
			while not _is_ilerle(job, 1 << 62):
				pass
	_zemin_ortu()
	_dis_halka()
	_karsi_kiyilar()
	_kiz_kulesi()
	_carpisma_kur()
	_t_kurulum_ms = (Time.get_ticks_usec() - t0) / 1000.0
	print("ISTDUNYA kurulum_ms=%.0f" % _t_kurulum_ms)


# ------------------------------------------------------------------ izleme

func _bakan() -> Vector3:
	# Dönüşümlü bağlama (IstBaglama: v2 kökü bölümün çerçevesinde döner/iner): izleyici v2 çerçevesinde okunur
	if izle != null and is_instance_valid(izle) and izle.is_inside_tree():
		return to_local(izle.global_position)
	var c := get_viewport().get_camera_3d() if is_inside_tree() else null
	if c != null:
		return to_local(c.global_position)
	return merkez


func _process(_dt: float) -> void:
	var t0 := Time.get_ticks_usec()
	var p := _bakan()
	_pus(p)
	_deniz_izle(p)
	_lod_guncelle(p)
	_yakalayici(p)
	# çarpışma önce (oyuncu düşmesin), sonra arazi ayrıntısı
	var p2 := Vector2(p.x, p.z)
	if _col_job.is_empty() and p2.distance_to(_col_center) > COL_MOVE:
		_col_job = _col_is(p2)
	if not _col_job.is_empty():
		_carpisma_ilerle(t0 + butce_us / 2)
	while Time.get_ticks_usec() - t0 < butce_us:
		if _job.is_empty():
			if _jobs.is_empty():
				break
			var j: Array = _jobs.pop_front()
			_job = _is_baslat(j[0], j[1])
		if _is_ilerle(_job, t0 + butce_us):
			_job = {}
	_son_kare_us = Time.get_ticks_usec() - t0


func _snap(p: Vector2, s: float) -> Vector2:
	return Vector2(roundf(p.x / s) * s, roundf(p.y / s) * s)


# ------------------------------------------------------------------ arazi parçaları

func _rect(k: Vector2i) -> Rect2:
	return Rect2(CX0 + k.x * CH, CZ0 + k.y * CH, CH, CH)


func _istenen_lod(k: Vector2i, p: Vector3, simdiki: int) -> int:
	var r := _rect(k)
	var dx := maxf(maxf(r.position.x - p.x, p.x - r.end.x), 0.0)
	var dz := maxf(maxf(r.position.y - p.z, p.z - r.end.y), 0.0)
	var d := sqrt(dx * dx + dz * dz) + maxf(p.y - 40.0, 0.0) * 0.6
	var l := 3
	for i in LOD_DIST.size():
		var lim: float = LOD_DIST[i]
		if simdiki >= 0 and simdiki <= i:
			lim += LOD_HYST
		if d < lim:
			l = i
			break
	return l


func _lod_guncelle(p: Vector3) -> void:
	var yeni: Array = []
	for k in _chunks:
		var c: Dictionary = _chunks[k]
		var l := _istenen_lod(k, p, c["lod"])
		if l != c["lod"] and not (not _job.is_empty() and _job["k"] == k and _job["lod"] == l):
			var r := _rect(k)
			var d := Vector2(p.x, p.z).distance_to(r.get_center())
			yeni.append([d, k, l])
	if yeni.is_empty():
		_jobs.clear()
		return
	yeni.sort_custom(func(a, b): return a[0] < b[0])
	_jobs.clear()
	for y in yeni:
		_jobs.append([y[1], y[2]])


func _is_baslat(k: Vector2i, lod: int) -> Dictionary:
	var r := _rect(k)
	var cell: float = LOD_CELL[lod]
	var n := int(CH / cell)
	return {"k": k, "lod": lod, "x0": r.position.x, "z0": r.position.y, "cell": cell, "n": n}


## Bir işi `bitis` zamanına (µs) kadar ilerletir; bitince true. Evreler (hepsi satır satır, zaman dilimli):
## 0 yükseklik, 1 normal + renk, 2 üçgen dizini, 3 etek + ağın kurulması.
func _is_ilerle(job: Dictionary, bitis: int) -> bool:
	var m = _ag_ilerle(job, bitis)
	if m == null:
		return false
	var c: Dictionary = _chunks[job["k"]]
	(c["mi"] as MeshInstance3D).mesh = m
	c["lod"] = job["lod"]
	return true


## Ağ kurma durumu: x0, z0, cell, n (nx), nz (yoksa n), h (doluysa evre 0 atlanır)
func _ag_ilerle(st: Dictionary, bitis: int) -> Variant:
	var nx: int = st["n"]
	var nz: int = st.get("nz", nx)
	var W := nx + 1
	var cell: float = st["cell"]
	var x0: float = st["x0"]
	var z0: float = st["z0"]
	if not st.has("evre"):
		st["evre"] = 0
		if st.has("h") and (st["h"] as PackedFloat32Array).size() == W * (nz + 1):
			st["evre"] = 1
		else:
			var hs0 := PackedFloat32Array()
			hs0.resize(W * (nz + 1))
			st["h"] = hs0
		st["row"] = 0
	if st["evre"] == 0:
		var hs: PackedFloat32Array = st["h"]
		while st["row"] <= nz:
			var j: int = st["row"]
			var z := z0 + j * cell
			var base := j * W
			for i in W:
				hs[base + i] = IstGeo.h(x0 + i * cell, z)
			st["row"] = j + 1
			if Time.get_ticks_usec() > bitis:
				st["h"] = hs
				return null
		st["h"] = hs
		st["evre"] = 1
		st["row"] = 0
	if st["evre"] == 1:
		var hs: PackedFloat32Array = st["h"]
		if not st.has("v"):
			var v0 := PackedVector3Array(); v0.resize(W * (nz + 1))
			var n0 := PackedVector3Array(); n0.resize(W * (nz + 1))
			var c0 := PackedColorArray(); c0.resize(W * (nz + 1))
			st["v"] = v0; st["nr"] = n0; st["c"] = c0
		var verts: PackedVector3Array = st["v"]
		var norms: PackedVector3Array = st["nr"]
		var cols: PackedColorArray = st["c"]
		while st["row"] <= nz:
			var j: int = st["row"]
			for i in W:
				var y := hs[j * W + i]
				var x := x0 + i * cell
				var z := z0 + j * cell
				var yl := hs[j * W + maxi(i - 1, 0)]
				var yr := hs[j * W + mini(i + 1, nx)]
				var yu := hs[maxi(j - 1, 0) * W + i]
				var yd := hs[mini(j + 1, nz) * W + i]
				var sx := float(mini(i + 1, nx) - maxi(i - 1, 0)) * cell
				var sz := float(mini(j + 1, nz) - maxi(j - 1, 0)) * cell
				var nrm := Vector3(-(yr - yl) / sx, 1.0, -(yd - yu) / sz).normalized()
				verts[j * W + i] = Vector3(x, y, z)
				norms[j * W + i] = nrm
				cols[j * W + i] = _renk(x, z, y, 1.0 - nrm.y)
			st["row"] = j + 1
			if Time.get_ticks_usec() > bitis:
				st["v"] = verts; st["nr"] = norms; st["c"] = cols
				return null
		st["v"] = verts; st["nr"] = norms; st["c"] = cols
		st["evre"] = 2
		st["row"] = 0
		st["ix"] = PackedInt32Array()
	if st["evre"] == 2:
		var hs: PackedFloat32Array = st["h"]
		var idx: PackedInt32Array = st["ix"]
		while st["row"] < nz:
			var j: int = st["row"]
			var a := j * W
			for i in nx:
				if hs[a] < SU and hs[a + 1] < SU and hs[a + W] < SU and hs[a + W + 1] < SU:
					a += 1
					continue
				idx.push_back(a); idx.push_back(a + 1); idx.push_back(a + W)
				idx.push_back(a + 1); idx.push_back(a + W + 1); idx.push_back(a + W)
				a += 1
			st["row"] = j + 1
			if Time.get_ticks_usec() > bitis:
				st["ix"] = idx
				return null
		st["ix"] = idx
		st["evre"] = 3
	# evre 3: etek ve ağ
	var verts: PackedVector3Array = st["v"]
	var norms: PackedVector3Array = st["nr"]
	var cols: PackedColorArray = st["c"]
	var idx: PackedInt32Array = st["ix"]
	var kenar: Array = []
	for i in W:
		kenar.append([i, Vector3(0, 0, -1)])
	for j in nz + 1:
		kenar.append([j * W + nx, Vector3(1, 0, 0)])
	for i in range(nx, -1, -1):
		kenar.append([nz * W + i, Vector3(0, 0, 1)])
	for j in range(nz, -1, -1):
		kenar.append([j * W, Vector3(-1, 0, 0)])
	var s0 := verts.size()
	for e in kenar:
		var v: Vector3 = verts[e[0]]
		verts.append(v - Vector3(0, SKIRT, 0))
		norms.append(e[1])
		cols.append(cols[e[0]].darkened(0.15))
	for q in kenar.size() - 1:
		var ta: int = kenar[q][0]
		var tb: int = kenar[q + 1][0]
		if ta == tb or verts[ta].y < SU and verts[tb].y < SU:
			continue
		var ba := s0 + q
		var bb := s0 + q + 1
		idx.append_array([ta, ba, tb, tb, ba, bb])
	var m := ArrayMesh.new()
	if idx.is_empty():
		return m
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_COLOR] = cols
	arr[Mesh.ARRAY_INDEX] = idx
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return m


const SU := -1.2


func _izgara_agi(x0: float, z0: float, cell: float, nx: int, nz: int, hs: PackedFloat32Array, _etek: bool) -> ArrayMesh:
	var st := {"x0": x0, "z0": z0, "cell": cell, "n": nx, "nz": nz, "h": hs}
	return _ag_ilerle(st, 1 << 62)


## ZEMİN (scripts/level/zemin.gd): v2 arazisinin malzemesi (Zemin.v2_malzeme); eski bölümlerle paylaşılmaz (deniz
## seviyesi ve aşınma maskesi v2'nin kendi uzayında, yöre Trakya).
func _zemin_mat() -> ShaderMaterial:
	return load("res://scripts/level/zemin.gd").v2_malzeme()


## ZEMİN yer örtüsü (ot tutamı, çiçek, taş, dal, birikinti): izleyicinin 48 m çevresinde akışlı, çarpışmasız; yerleşik
## mahallelerde (döşeli sokak, çarşı) yok, açık arazide (kır, bostan, harabe, ordugâh, sur dışı) var.
func _zemin_ortu() -> void:
	var acik := ["kir", "seyrek", "bostan", "sarnic", "harabe", "ordugah", "bag", "orman", ""]
	load("res://scripts/level/zemin.gd").ortu_ekle(self, Rect2(-100000.0, -100000.0, 200000.0, 200000.0),
		func(x: float, z: float) -> float: return IstGeo.h(x, z),
		func(x: float, z: float) -> Color: return _renk(x, z, IstGeo.h(x, z), 0.0),
		{"temas": false, "tut": func(x: float, z: float) -> bool: return String(_mah(x, z).get("tur", "")) in acik and IstGeo.h(x, z) > 0.4})


## Mahalle türü (20 m önbellek; IstGeo.mahalle pahalı)
func _mah(x: float, z: float) -> Dictionary:
	var k := Vector2i(floori(x / 20.0), floori(z / 20.0))
	var t = _tur_cache.get(k)
	if t == null:
		t = IstGeo.mahalle(k.x * 20.0 + 10.0, k.y * 20.0 + 10.0)
		_tur_cache[k] = t
	return t


const C_CAYIR := Color("6c8644")
const C_KURU := Color("9a8c5c")
const C_TOPRAK := Color("94805e")
const C_CIGNEN := Color("86735a")
const C_TASLIK := Color("948a74")
const C_KUM := Color("c2ae80")
const C_BOSTAN := Color("627e46")
const C_TABAN := Color("6a7a68")


## Köşe rengi (kalite notu 0 ve görev 3: tek renk yeşil değil): mahalle türüne göre çiğnenmiş toprak, taşlık, çiçekli
## çayır, sürülmüş tarla / yeşil buğday parselleri, bağ sıraları, bostan tarhları; sur önü ve ordugâh çiğnenmiş toprak;
## karşı kıyılarda tarla parselleri, bağlar, koru. Bütün desen ölçüleri GERÇEK metre (S'den bağımsız görünüş için
## dünya metresine çevrilir: parsel ~150 m gerçek).
const C_CICEK := Color("8f9a58")
const C_SURULMUS := Color("7a6046")
const C_BUGDAY := Color("6f8c3c")
const C_NADAS := Color("a89a6c")
const C_BAG := Color("66783e")
const C_ORMAN := Color("3f5a33")
const C_MEYVE := Color("7d9150")

func _renk(x: float, z: float, y: float, egim: float) -> Color:
	var yr := y / IstGeo.S                       # gerçek yükseklik
	if yr < -0.8:
		return C_TABAN.lerp(C_KUM, clampf(1.0 + yr / 12.0, 0.0, 1.0))
	var rr := IstGeo.real(x, z)
	var g := sin(rr.x * 0.0073 + rr.y * 0.0046) * 0.5 + sin(rr.x * 0.0025 - rr.y * 0.0033 + 1.3) * 0.5
	var g2 := sin(rr.x * 0.031 - rr.y * 0.027 + 0.7) * sin(rr.x * 0.019 + rr.y * 0.041)   # ince leke
	var c := C_CAYIR.lerp(C_KURU, clampf(0.45 + g * 0.45, 0.0, 1.0))
	var b := IstGeo.bolge(x, z)
	var yakin := absf(rr.x + 1200.0) < 7000.0 and absf(rr.y - 1400.0) < 6500.0
	var m: Dictionary = _mah(x, z) if yakin else {"tur": "kir", "yogunluk": 0.05, "alt": "tarla"}
	var tur := String(m["tur"])
	var alt := String(m.get("alt", ""))
	var yog: float = m["yogunluk"]
	var cig := C_CIGNEN.lerp(C_TOPRAK, clampf(0.5 + g * 0.5, 0.0, 1.0))
	match tur:
		"carsi", "sik", "liman", "sur_dibi", "koy":
			# yerleşik doku: çiğnenmiş toprak, aralarda taşlık ve ot lekeleri
			c = c.lerp(cig, clampf(0.35 + yog * 0.8, 0.0, 1.0))
			c = c.lerp(C_TASLIK, clampf(g2, 0.0, 1.0) * 0.35)
		"seyrek":
			c = c.lerp(cig, 0.35).lerp(C_CICEK, clampf(g2, 0.0, 1.0) * 0.4)
		"bostan", "sarnic":
			c = _parsel(rr, alt if alt != "" else "bostan", c)
		"harabe", "saray":
			c = C_TASLIK.lerp(C_TOPRAK, clampf(0.4 + g * 0.4, 0.0, 1.0)).lerp(C_CAYIR, clampf(g2, 0.0, 1.0) * 0.45)
		"hipodrom":
			c = C_KURU.lerp(C_TOPRAK, 0.5 + 0.3 * g)
		"ordugah":
			# ordugâh: çiğnenmiş toprak, yollar ve ocak yerleri; aralarda ot lekeleri
			c = cig.lerp(c, clampf(0.12 + g2 * 0.35 - yog * 0.1, 0.0, 0.6))
		"bag":
			c = _parsel(rr, "bag", c)
		"orman":
			c = C_ORMAN.lerp(C_CAYIR, clampf(0.3 + g * 0.3 + g2 * 0.2, 0.0, 1.0))
		_:
			if alt == "hendek":
				c = C_CIGNEN.lerp(C_TOPRAK, 0.4 + 0.3 * g2)
			else:
				c = _parsel(rr, "tarla", c)
	if b == IstGeo.B_TRAKYA or b == IstGeo.B_ANADOLU:
		c = c.lerp(C_KURU, 0.12)
	# taşlık yamaç
	c = c.lerp(C_TASLIK, smoothstep(0.35, 0.7, egim) * 0.8)
	# kıyı kumu (gerçek 0–3 m)
	if yr < 3.2:
		c = C_KUM.lerp(c, smoothstep(1.2, 3.2, yr))
	# ışıkta (güneş + gök ortamı + ground.gdshader'ın ılık çarpanı) açık renkler soluk/süt rengi görünüyordu:
	# albedo biraz koyulaşır, doygunluk artar (kalite notu 3: canlı, sıcak, okunur)
	return Color.from_hsv(c.h, clampf(c.s * 1.25, 0.0, 1.0), c.v * 0.8)


## Parsel deseni: ~150 m gerçek hücreler (hafif dönük), her hücreye tür: sürülmüş tarla (çizgili), yeşil buğday,
## nadas, çiçekli çayır, bağ sıraları, bostan tarhları, meyve bahçesi (çiçekte).
func _parsel(rr: Vector2, kind: String, c0: Color) -> Color:
	var q := rr.rotated(0.35)
	var ci := floori(q.x / 150.0)
	var cj := floori(q.y / 110.0)
	var hs := IstGeo._hash(ci, cj)
	var u := fposmod(q.x, 150.0)
	var v := fposmod(q.y, 110.0)
	var kenar := minf(minf(u, 150.0 - u), minf(v, 110.0 - v)) < 4.0     # tarla sınırı / patika
	if kenar:
		return C_TOPRAK.lerp(c0, 0.3)
	var serit := 0.5 + 0.5 * sin((q.y if hs < 0.5 else q.x) * 1.6)
	match kind:
		"bag":
			return C_BAG.lerp(C_TOPRAK, 0.25 + serit * 0.35) if hs < 0.75 else C_CICEK
		"bostan":
			return C_BOSTAN.lerp(C_SURULMUS, serit * 0.45) if hs < 0.6 else C_BUGDAY.lerp(C_BOSTAN, 0.4)
		"meyve":
			return C_MEYVE.lerp(Color("b7a0a0"), clampf(serit - 0.55, 0.0, 1.0) * 0.6)
		"mezarlik":
			return C_CAYIR.lerp(C_TASLIK, 0.3)
	# tarla
	if hs < 0.3:
		return C_SURULMUS.lerp(C_TOPRAK, serit * 0.4)
	if hs < 0.6:
		return C_BUGDAY.lerp(C_CAYIR, serit * 0.2)
	if hs < 0.78:
		return C_NADAS.lerp(c0, 0.3)
	return C_CICEK.lerp(c0, 0.25)


# ------------------------------------------------------------------ dış halka (veri sınırına kadar, kaba)

func _dis_halka() -> void:
	var X1 := CX0 + CNX * CH
	var Z1 := CZ0 + CNZ * CH
	var C := OUT_CELL
	var XA := CX0 - ceilf((CX0 - IstGeo.X0 + 512.0) / C) * C
	var XB := X1 + ceilf((IstGeo.X0 + (IstGeo.NX - 1) * IstGeo.ST + 512.0 - X1) / C) * C
	var ZA := CZ0 - ceilf((CZ0 - IstGeo.Z0 + 512.0) / C) * C
	var ZB := Z1 + ceilf((IstGeo.Z0 + (IstGeo.NZ - 1) * IstGeo.ST + 512.0 - Z1) / C) * C
	for r in [Rect2(XA, ZA, XB - XA, CZ0 - ZA), Rect2(XA, Z1, XB - XA, ZB - Z1),
			Rect2(XA, CZ0, CX0 - XA, Z1 - CZ0), Rect2(X1, CZ0, XB - X1, Z1 - CZ0)]:
		var nx := int(roundf(r.size.x / C))
		var nz := int(roundf(r.size.y / C))
		var hs := PackedFloat32Array()
		hs.resize((nx + 1) * (nz + 1))
		for j in nz + 1:
			for i in nx + 1:
				hs[j * (nx + 1) + i] = IstGeo.h_ham(r.position.x + i * C, r.position.y + j * C)
		var mi := MeshInstance3D.new()
		mi.name = "AraziDis"
		mi.mesh = _izgara_agi(r.position.x, r.position.y, C, nx, nz, hs, true)
		mi.material_override = _zemin_mat()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)


# ------------------------------------------------------------------ karşı kıyılar ve sur dışı (görev 4, kalite notu 0)

## Sur dışı ve karşı kıyıların her 40 m'lik dünya karesine en az bir öğe: köylerde ev (Üsküdar, Khalkedon, Boğaz
## köyleri, Eyüp, Kasımpaşa, Hasköy), bağ/bahçe sıraları, ormanlık tepelerde ağaç kümeleri, tarlalarda ot yığını ve
## sınır ağaçları, ordugâh kuşağında çalı/ot yığını (çadırlar IstOrdugah'ın). Ucuz: 1600 m'lik öbeklerde her tür için
## tek MultiMesh (ağaç, servi, ev, ot yığını, çalı). Sayım: karsi_sayim {kare: öğe sayısı} (ISTBOS).
const KARSI_E := Vector2(-8200.0, 9000.0)
const KARSI_N := Vector2(-4600.0, 9600.0)
const KARSI_OBEK := 1600.0
var karsi_sayim := {}            # Vector2i(IstGeo.kare40) → öğe sayısı
var _karsi_ogeler := 0

func _karsi_kiyilar() -> void:
	var t0 := Time.get_ticks_usec()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var turler := ["agac", "servi", "ev", "ot", "cali"]
	var obekler := {}                # Vector2i → {tur: Array[Transform3D, Color]}
	var xa := KARSI_E.x * IstGeo.S
	var xb := KARSI_E.y * IstGeo.S
	var za := -KARSI_N.y * IstGeo.S
	var zb := -KARSI_N.x * IstGeo.S
	var i0 := floori(xa / 40.0)
	var j0 := floori(za / 40.0)
	for j in range(j0, floori(zb / 40.0) + 1):
		for i in range(i0, floori(xb / 40.0) + 1):
			var cx := (i + 0.5) * 40.0 + IstGeo.OX
			var cz := (j + 0.5) * 40.0 + IstGeo.OZ
			if IstGeo.su(cx, cz) or IstGeo.sehir_ici(cx, cz) or IstGeo.galata_ici(cx, cz) or IstGeo.dislanan_mi(cx, cz):
				continue
			var m := IstGeo.mahalle(cx, cz)
			var tur := String(m["tur"])
			var alt := String(m.get("alt", ""))
			var liste: Array = []      # [tür, ölçek, renk]
			match tur:
				"koy":
					var n := 1 + int(rng.randf() * 3.0 * float(m["yogunluk"]) * 2.0)
					for k in n:
						liste.append(["ev", rng.randf_range(0.8, 1.3), Color("d9c6a8").lerp(Color("b98c6a"), rng.randf())])
					liste.append(["agac" if rng.randf() < 0.7 else "servi", rng.randf_range(0.8, 1.2), Color("4f6e35")])
				"orman":
					for k in 3 + rng.randi() % 3:
						liste.append(["agac", rng.randf_range(0.9, 1.5), Color("3d5a2c").lerp(Color("587a3a"), rng.randf())])
					if rng.randf() < 0.3:
						liste.append(["servi", 1.2, Color("2f4a28")])
				"bag":
					for k in 2 + rng.randi() % 2:
						liste.append(["cali", rng.randf_range(0.7, 1.0), Color("5f7a34")])
					if rng.randf() < 0.45:
						liste.append(["agac", rng.randf_range(0.8, 1.1), Color("8a9a5a").lerp(Color("d8c8d8"), 0.5 * rng.randf())])
					if rng.randf() < 0.12:
						liste.append(["ev", 0.8, Color("cbb79a")])
				"ordugah":
					# çadırlar IstOrdugah'ın; burada çalı, kesilmiş ağaç kütüğü yerine ot yığını (ikmal), seyrek ağaç
					liste.append(["ot" if rng.randf() < 0.6 else "cali", rng.randf_range(0.7, 1.1), Color("b59c5a")])
					if rng.randf() < 0.15:
						liste.append(["agac", 1.0, Color("4f6a33")])
				_:
					if alt == "hendek":
						liste.append(["cali", 0.7, Color("6b6a40")])
					elif alt == "tarla":
						liste.append(["ot" if rng.randf() < 0.55 else "agac", rng.randf_range(0.8, 1.2),
							Color("c9b06a") if rng.randf() < 0.55 else Color("56733a")])
					else:
						liste.append(["agac" if rng.randf() < 0.6 else "cali", rng.randf_range(0.8, 1.2), Color("56733a")])
						if rng.randf() < 0.25:
							liste.append(["servi", 1.0, Color("2f4a28")])
			if liste.is_empty():
				continue
			var ok := Vector2i(floori(cx / KARSI_OBEK), floori(cz / KARSI_OBEK))
			if not obekler.has(ok):
				var d := {}
				for t in turler:
					d[t] = []
				obekler[ok] = d
			var konan := 0
			for o in liste:
				var px := cx + rng.randf_range(-17.0, 17.0)
				var pz := cz + rng.randf_range(-17.0, 17.0)
				if IstGeo.su(px, pz):
					continue
				var y := IstGeo.h(px, pz)
				var sc: float = o[1]
				var tf := Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * sc), Vector3(px, y - 0.2, pz))
				(obekler[ok][o[0]] as Array).append([tf, o[2]])
				konan += 1
			if konan > 0:
				karsi_sayim[Vector2i(i, j)] = konan
				_karsi_ogeler += konan
	var mats := {}
	for t in turler:
		var mt := StandardMaterial3D.new()
		mt.vertex_color_use_as_albedo = true
		mt.roughness = 1.0
		mt.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		mats[t] = mt
	for ok in obekler:
		for t in turler:
			var l: Array = obekler[ok][t]
			if l.is_empty():
				continue
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.use_colors = true
			mm.mesh = _karsi_ag(t)
			mm.instance_count = l.size()
			for k in l.size():
				mm.set_instance_transform(k, l[k][0])
				mm.set_instance_color(k, l[k][1])
			var mi := MultiMeshInstance3D.new()
			mi.name = "Karsi_%s_%d_%d" % [t, ok.x, ok.y]
			mi.multimesh = mm
			mi.material_override = mats[t]
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.visibility_range_end = 4200.0 if t in ["agac", "ev", "servi"] else 2400.0
			add_child(mi)
	print("ISTDUNYA karsi_kiyilar oge=%d kare=%d ms=%.0f" % [_karsi_ogeler, karsi_sayim.size(), (Time.get_ticks_usec() - t0) / 1000.0])


## Düşük çokgen öğe ağları (köşe rengi × örnek rengi)
func _karsi_ag(t: String) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	match t:
		"agac":
			_koni(st, 0.35, 0.3, 0.0, 2.2, 5, Color("6b5338"))
			_koni(st, 3.0, 0.0, 1.8, 7.5, 6, Color(1, 1, 1), 2.6)
		"servi":
			_koni(st, 0.3, 0.3, 0.0, 1.0, 4, Color("6b5338"))
			_koni(st, 1.3, 0.0, 0.8, 11.0, 6, Color(1, 1, 1))
		"cali":
			_koni(st, 1.6, 0.0, 0.0, 1.8, 5, Color(1, 1, 1), 1.0)
		"ot":
			_koni(st, 2.2, 0.3, 0.0, 2.6, 7, Color(1, 1, 1))
		"ev":
			# 6 × 5 m, 4,5 m duvar + kiremit çatı
			var a := Vector3(-3, 0, -2.5)
			var b := Vector3(3, 4.5, 2.5)
			_kutu(st, a, b, Color(1, 1, 1))
			var r := Color("b5583a")
			var y0 := 4.5
			var y1 := 6.6
			for q in [[Vector3(-3.3, y0, -2.8), Vector3(3.3, y0, -2.8), Vector3(3.3, y1, 0), Vector3(-3.3, y1, 0)],
					[Vector3(3.3, y0, 2.8), Vector3(-3.3, y0, 2.8), Vector3(-3.3, y1, 0), Vector3(3.3, y1, 0)]]:
				_dortgen(st, q, r)
			_ucgen(st, Vector3(-3, y0, -2.5), Vector3(-3, y1, 0), Vector3(-3, y0, 2.5), Color(1, 1, 1))
			_ucgen(st, Vector3(3, y0, 2.5), Vector3(3, y1, 0), Vector3(3, y0, -2.5), Color(1, 1, 1))
	st.generate_normals()
	return st.commit()


## Koni/kesik koni (alt yarıçap r0, üst r1, y0 → y1); bas > 0 ise tepe kapağı yerine yuvarlak taç (iki koni)
func _koni(st: SurfaceTool, r0: float, r1: float, y0: float, y1: float, n: int, c: Color, bas := 0.0) -> void:
	var ust := y1
	var ortay := y0
	if bas > 0.0:
		ortay = y0 + bas
		for k in n:
			var a0 := TAU * k / n
			var a1 := TAU * (k + 1) / n
			_ucgen(st, Vector3(0, y0, 0), Vector3(cos(a0) * r0, ortay, sin(a0) * r0), Vector3(cos(a1) * r0, ortay, sin(a1) * r0), c)
		y0 = ortay
	for k in n:
		var a0 := TAU * k / n
		var a1 := TAU * (k + 1) / n
		var p0 := Vector3(cos(a0) * r0, y0, sin(a0) * r0)
		var p1 := Vector3(cos(a1) * r0, y0, sin(a1) * r0)
		if r1 <= 0.01:
			_ucgen(st, p0, Vector3(0, ust, 0), p1, c)
		else:
			var q0 := Vector3(cos(a0) * r1, ust, sin(a0) * r1)
			var q1 := Vector3(cos(a1) * r1, ust, sin(a1) * r1)
			_dortgen(st, [p0, p1, q1, q0], c)


func _kutu(st: SurfaceTool, a: Vector3, b: Vector3, c: Color) -> void:
	var v := [Vector3(a.x, a.y, a.z), Vector3(b.x, a.y, a.z), Vector3(b.x, a.y, b.z), Vector3(a.x, a.y, b.z),
		Vector3(a.x, b.y, a.z), Vector3(b.x, b.y, a.z), Vector3(b.x, b.y, b.z), Vector3(a.x, b.y, b.z)]
	for f in [[0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7]]:
		_dortgen(st, [v[f[0]], v[f[1]], v[f[2]], v[f[3]]], c)


func _ucgen(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	# dışa bakan yüz (Godot: saat yönü önden)
	st.set_color(col); st.add_vertex(a)
	st.set_color(col); st.add_vertex(c)
	st.set_color(col); st.add_vertex(b)


func _dortgen(st: SurfaceTool, q: Array, col: Color) -> void:
	_ucgen(st, q[0], q[3], q[2], col)
	_ucgen(st, q[0], q[2], q[1], col)


## Kız Kulesi (Damalis / Arkla): 1453'te adacıkta küçük kale: kule (Manuel Komnenos) + çevre duvarı (kestirim).
## Ölçü k = 0,75 gerçek (kule ~10 × 10 × 18 m, duvar ~6 m).
func _kiz_kulesi() -> void:
	var c := IstGeo.w(2005.0, 1390.0)
	var host := Node3D.new()
	host.name = "KizKulesi"
	add_child(host)
	var k := 0.75
	var y := maxf(IstGeo.h(c.x, c.z), 0.3)
	host.position = Vector3(c.x, y, c.z)
	var tas := Color("b9ab92")
	var tugla := Color("a0644a")
	Props.box(host, Vector3(30, 2.0, 22) * k, Vector3(0, -0.6, 0), Color("8f8574"))
	for q in [[Vector3(30, 8, 1.6), Vector3(0, 4, -11)], [Vector3(30, 8, 1.6), Vector3(0, 4, 11)],
			[Vector3(1.6, 8, 22), Vector3(-15, 4, 0)], [Vector3(1.6, 8, 22), Vector3(15, 4, 0)]]:
		Props.box(host, q[0] * k, q[1] * k, tas)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			Props.box(host, Vector3(4.5, 10, 4.5) * k, Vector3(15 * sx, 5, 11 * sz) * k, tas.darkened(0.05))
	Props.box(host, Vector3(10, 18, 10) * k, Vector3(2, 9, 0) * k, tas)
	for hy in [6.0, 12.0]:
		Props.box(host, Vector3(10.3, 0.8, 10.3) * k, Vector3(2, hy, 0) * k, tugla)
	for dx in [-1, 1]:
		for dz in [-1, 1]:
			Props.box(host, Vector3(1.6, 1.4, 1.6) * k, Vector3(2 + 4.2 * dx, 18.7, 4.2 * dz) * k, tas)
	Props.cyl(host, 0.15, 5.0, Vector3(2, 21.0, 0) * k, Color("4a3a2a"))
	Props.box(host, Vector3(2.4, 1.4, 0.05), Vector3(2 * k + 1.2, 23.0 * k, 0), Color("8a1f1f"))


# ------------------------------------------------------------------ deniz

func _deniz() -> void:
	_water_mat = ShaderMaterial.new()
	_water_mat.shader = load("res://assets/shaders/water.gdshader")
	_water_mat.set_shader_parameter("foam_width", 0.0)
	_water_mat.set_shader_parameter("wave_height", 0.25)
	_water_mat.set_shader_parameter("ripple", 0.07)       # uzakta hare (moiré) yapmasın
	if gece:
		_water_mat.set_shader_parameter("shallow_color", Color(0.05, 0.13, 0.2))
		_water_mat.set_shader_parameter("deep_color", Color(0.02, 0.05, 0.1))
		_water_mat.set_shader_parameter("sky_tint", Color(0.25, 0.3, 0.45))
		_water_mat.set_shader_parameter("glint", 0.3)
	_sea_near = MeshInstance3D.new()
	_sea_near.name = "DenizYakin"
	var pm := PlaneMesh.new()
	pm.size = Vector2(SEA_NEAR, SEA_NEAR)
	pm.subdivide_width = int(SEA_NEAR / SEA_SUB) - 1
	pm.subdivide_depth = int(SEA_NEAR / SEA_SUB) - 1
	_sea_near.mesh = pm
	_sea_near.material_override = _water_mat
	_sea_near.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_sea_near)
	var far_mat := _water_mat.duplicate() as ShaderMaterial
	far_mat.set_shader_parameter("wave_height", 0.0)
	far_mat.set_shader_parameter("ripple", 0.0)
	far_mat.set_shader_parameter("glint", 0.0)
	for i in 4:
		var m := MeshInstance3D.new()
		m.name = "DenizUzak%d" % i
		m.mesh = PlaneMesh.new()
		m.material_override = far_mat
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(m)
		_sea_far.append(m)
	_deniz_izle(merkez)


func _deniz_izle(p: Vector3) -> void:
	var c := _snap(Vector2(p.x, p.z), 100.0)
	if c == _sea_center:
		return
	_sea_center = c
	_sea_near.position = Vector3(c.x, 0.0, c.y)
	var R := 24000.0
	var h := SEA_NEAR * 0.5
	# kuzey, güney, batı, doğu dikdörtgenleri (yakın parçanın çevresi)
	var rs := [Rect2(c.x - R, c.y - R, 2 * R, R - h), Rect2(c.x - R, c.y + h, 2 * R, R - h),
		Rect2(c.x - R, c.y - h, R - h, 2 * h), Rect2(c.x + h, c.y - h, R - h, 2 * h)]
	# Bölümün kendi zemini (IstGeo.dislanan; deniz düzeyinde, y ≈ 0) denizin altında kalmasın: izleyici yakınken yakın deniz
	# gizlenir, uzak parçalar o alanın çevresine dizilir (alan karada; arada kalan deniz dalgasız)
	_sea_near.visible = true
	for dr: Rect2 in IstGeo.deniz_yok:
		if dr.grow(SEA_NEAR * 0.5 + 100.0).has_point(c):
			_sea_near.visible = false
			var a := dr.position
			var b := dr.end
			rs = [Rect2(a.x - R, a.y - R, b.x - a.x + 2 * R, R), Rect2(a.x - R, b.y, b.x - a.x + 2 * R, R),
				Rect2(a.x - R, a.y, R, b.y - a.y), Rect2(b.x, a.y, R, b.y - a.y)]
			break
	for i in 4:
		var r: Rect2 = rs[i]
		var m: MeshInstance3D = _sea_far[i]
		(m.mesh as PlaneMesh).size = r.size
		m.position = Vector3(r.get_center().x, -0.02, r.get_center().y)


# ------------------------------------------------------------------ gök, ışık, sis

func _gok() -> void:
	var env := WorldEnvironment.new()
	env.name = "Gok"
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f7fc4")
	sm.sky_horizon_color = Color("cfdde6")
	sm.ground_horizon_color = Color("b8c4c8")
	sm.ground_bottom_color = Color("5a6a70")
	sm.sun_angle_max = 20.0
	sky.sky_material = sm
	_sky_mat = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.48
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	e.fog_enabled = true
	# üstel sis (Compatibility çizicisinde derinlik sisi yok): 1 km'de %80, 3 km'de %55, 10 km'de %13 görünür
	e.fog_light_color = Color("d6dcd8")
	e.fog_density = 0.00008
	e.fog_aerial_perspective = 0.0
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.2
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.08
	e.adjustment_contrast = 1.05
	env.environment = e
	# Look.apply_env (GameState) sisi şehir ölçeğine göre kalınlaştırır (en az 0,002/m): km ölçeğinde dünya süt beyazı
	# olurdu. fog_cap ile sınırla; gece işareti lacivert pus verir.
	env.set_meta("fog_cap", 0.00025 if gece else 0.00008)
	if gece:
		env.set_meta("look", "night")
	add_child(env)
	_env = e
	_sun = DirectionalLight3D.new()
	_sun.name = "Gunes"
	# öğleden sonra güneşi (güneybatıdan, ~36°): sıcak, uzun gölgeler; şehir okunur
	_sun.rotation_degrees = Vector3(-36, 38, 0)
	_sun.light_color = Color("ffe2b8")
	_sun.light_energy = 1.2
	_sun.shadow_enabled = true
	_sun.directional_shadow_max_distance = 140.0
	add_child(_sun)
	if gece:
		sm.sky_top_color = Color("0b1330")
		sm.sky_horizon_color = Color("2a3560")
		sm.ground_horizon_color = Color("1c2238")
		sm.ground_bottom_color = Color("10141f")
		e.fog_light_color = Color("1c2440")
		e.fog_density = 0.00025
		e.ambient_light_energy = 0.22
		_sun.rotation_degrees = Vector3(-50, -140, 0)
		_sun.light_color = Color("9fb4e8")
		_sun.light_energy = 0.28
		SkyBody.attach(self, _sun, true)
	else:
		SkyBody.attach(self, _sun)


## Pus kamera yüksekliğine göre: yerden ve alçak uçuşta ufuk yumuşak (hava perspektifi), yükseldikçe incelir; tam
## tepeden (2 km) şehir süt rengine dönmesin. Look.apply_env sahne açılışında sisi ve hava perspektifini (0,3) yeniden
## kurar: her karede burada sınırlanır.
var _pus_y := INF
func _pus(p: Vector3) -> void:
	if _env == null:
		return
	var y := p.y
	if absf(y - _pus_y) < 5.0 and _env.fog_aerial_perspective <= 0.12:
		return
	_pus_y = y
	var taban := 0.00025 if gece else 0.00008
	var k := clampf(1.0 - (y - 80.0) / 900.0, 0.18, 1.0)
	_env.fog_enabled = true
	_env.fog_density = taban * k
	_env.fog_aerial_perspective = 0.1
	_env.fog_sky_affect = 0.0


# ------------------------------------------------------------------ uzak ufuk

## Veri sınırının ötesi: Trakya ve Anadolu tepeleri, Boğaz'ın iki yakası, Adalar, Marmara'nın güneyinde uzak dağlar
## (Samanlı/Armutlu). Gerçek yönler (Ayasofya'dan kerteriz), yükseklikler kestirim; düşük çokgen şerit, sisle karışır.
const UFUK_YAY := [
	# [kerteriz başı, sonu (derece, kuzeyden saat yönü), uzaklık (gerçek m), tepe yüksekliği (gerçek m), renk]
	[236.0, 360.0, 16000.0, 110.0, "7d8a68"],    # Trakya (Bakırköy'den kuzeye)
	[0.0, 27.0, 15000.0, 140.0, "6f8060"],        # Avrupa yakası Boğaz sırtları
	[33.0, 75.0, 15000.0, 180.0, "667a5a"],       # Anadolu yakası Boğaz sırtları (Beykoz)
	[75.0, 128.0, 15000.0, 420.0, "6a7660"],      # Anadolu tepeleri (Kayışdağı ~438 m)
	[118.0, 135.0, 26000.0, 530.0, "77806e"],     # Aydos
	[150.0, 205.0, 60000.0, 900.0, "9aa6b0"],     # Marmara'nın güneyi (Samanlı dağları), çok soluk
]
const ADALAR := [
	# ad, enlem, boylam, yarıçap (gerçek m), yükseklik (gerçek m)
	["Kınalıada", 40.910, 29.052, 750.0, 115.0], ["Burgazada", 40.881, 29.067, 800.0, 165.0],
	["Kaşıkadası", 40.875, 29.083, 200.0, 40.0], ["Heybeliada", 40.877, 29.095, 1200.0, 136.0],
	["Büyükada", 40.857, 29.122, 1700.0, 202.0], ["Sedefadası", 40.850, 29.143, 450.0, 60.0],
	["Sivriada", 40.877, 28.973, 220.0, 90.0], ["Yassıada", 40.888, 28.993, 300.0, 40.0],
]


func _ufuk() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var o := Vector3(IstGeo.OX, 0.0, IstGeo.OZ)      # Ayasofya (kerteriz merkezi)
	for y in UFUK_YAY:
		var a0: float = y[0]
		var a1: float = y[1]
		var R: float = y[2] * IstGeo.S
		var H: float = y[3] * IstGeo.S
		var col := Color(y[4] as String)
		var nseg := int(ceilf((a1 - a0) / 1.5))
		var prev_top := Vector3.ZERO
		var prev_bot := Vector3.ZERO
		for s in nseg + 1:
			var a := deg_to_rad(lerpf(a0, a1, float(s) / nseg))
			var dir := Vector3(sin(a), 0.0, -cos(a))
			var t := float(s) / nseg
			var env := smoothstep(0.0, 0.12, t) * smoothstep(1.0, 0.88, t)
			var hh := H * (0.45 + 0.35 * sin(a * 7.0 + 1.0) + 0.2 * rng.randf()) * maxf(env, 0.15)
			var rr := R * (1.0 + 0.06 * sin(a * 11.0))
			var top := o + dir * rr + Vector3(0, hh, 0)
			var bot := o + dir * (rr * 0.92) + Vector3(0, -2.0, 0)
			if s > 0:
				var n := (top - prev_top).cross(prev_bot - prev_top).normalized()
				if n.dot(-dir) < 0.0:
					n = -n
				for v in [prev_top, top, prev_bot, top, bot, prev_bot]:
					st.set_color(col)
					st.set_normal(n)
					st.add_vertex(v)
			prev_top = top
			prev_bot = bot
	# Adalar: alçak koni tepeler
	for a in ADALAR:
		var c := IstGeo.ll(a[1], a[2])
		c.y = 0.0
		var r: float = a[3] * IstGeo.S
		var hh: float = a[4] * IstGeo.S
		var seg := 14
		var col := Color("6f7d5c")
		var tepe := c + Vector3(r * 0.15, hh, 0)
		for s in seg:
			var a0 := TAU * s / seg
			var a1 := TAU * (s + 1) / seg
			var p0 := c + Vector3(cos(a0) * r * (1.0 + 0.25 * sin(a0 * 3.0)), -1.0, sin(a0) * r * 0.7)
			var p1 := c + Vector3(cos(a1) * r * (1.0 + 0.25 * sin(a1 * 3.0)), -1.0, sin(a1) * r * 0.7)
			var m0 := p0.lerp(tepe, 0.55) + Vector3(0, hh * 0.1, 0)
			var m1 := p1.lerp(tepe, 0.55) + Vector3(0, hh * 0.1, 0)
			for tri in [[p0, m0, p1], [p1, m0, m1], [m0, tepe, m1]]:
				var n: Vector3 = (tri[1] - tri[0]).cross(tri[2] - tri[0]).normalized()
				if n.y < 0.0:
					n = -n
				for v in tri:
					st.set_color(col)
					st.set_normal(n)
					st.add_vertex(v)
	var mi := MeshInstance3D.new()
	mi.name = "Ufuk"
	mi.mesh = st.commit()
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.vertex_color_is_srgb = true
	m.roughness = 1.0
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)


# ------------------------------------------------------------------ çarpışma

func _carpisma_kur() -> void:
	_col_body = StaticBody3D.new()
	_col_body.name = "AraziCarpisma"
	_col_shape = CollisionShape3D.new()
	var hm := HeightMapShape3D.new()
	hm.map_width = COL_N + 1
	hm.map_depth = COL_N + 1
	_col_shape.shape = hm
	_col_shape.scale = Vector3(COL_STEP, 1.0, COL_STEP)
	_col_body.add_child(_col_shape)
	add_child(_col_body)
	var p := _bakan()
	_col_job = _col_is(Vector2(p.x, p.z))
	_carpisma_ilerle(1 << 62)


func _col_is(p2: Vector2) -> Dictionary:
	var d := PackedFloat32Array()
	d.resize((COL_N + 1) * (COL_N + 1))
	return {"c": _snap(p2, COL_STEP), "row": 0, "data": d}


func _carpisma_ilerle(bitis: int) -> void:
	var c: Vector2 = _col_job["c"]
	var data: PackedFloat32Array = _col_job["data"]
	var W := COL_N + 1
	var half := COL_N * COL_STEP * 0.5
	while _col_job["row"] < W:
		var j: int = _col_job["row"]
		var z := c.y - half + j * COL_STEP
		for i in W:
			data[j * W + i] = IstGeo.h(c.x - half + i * COL_STEP, z)
		_col_job["row"] = j + 1
		if Time.get_ticks_usec() > bitis:
			_col_job["data"] = data
			return
	var hm := _col_shape.shape as HeightMapShape3D
	hm.map_data = data
	_col_shape.position = Vector3(c.x, 0.0, c.y)
	_col_center = c
	_col_job = {}


## Çarpışma merkezini zorla yeniler (ışınlama sonrası); hemen kurar.
func carpisma_yenile(p: Vector3) -> void:
	_col_job = _col_is(Vector2(p.x, p.z))
	_carpisma_ilerle(1 << 62)


## Düzleme kaydından (IstGeo.duzle) sonra etkilenen parçaları yeniden kurdurur.
func yenile(alan := Rect2()) -> void:
	for k in _chunks:
		if alan.size == Vector2.ZERO or _rect(k).intersects(alan):
			_chunks[k]["lod"] = -1
	_col_center = Vector2(INF, INF)


# ------------------------------------------------------------------ su yakalayıcı

## Suya düşen oyuncu/uçuş: deniz tabanına inmeden en yakın kıyıya çıkarılır (yürüyen CharacterBody3D için).
func _yakalayici(p: Vector3) -> void:
	if izle == null or not is_instance_valid(izle) or not (izle is CharacterBody3D):
		return
	if p.y > -0.9 or not IstGeo.su(p.x, p.z):
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - _yakala_son < 0.5:
		return
	_yakala_son = now
	var k := kiyi_bul(p)
	izle.global_position = to_global(k + Vector3(0, 1.0, 0))
	(izle as CharacterBody3D).velocity = Vector3.ZERO
	carpisma_yenile(k)
	print("ISTDUNYA su_yakalayici %s -> %s" % [p, k])


## En yakın kara noktası (sarmal arama, 4 m adım)
static func kiyi_bul(p: Vector3) -> Vector3:
	for r in range(4, 1600, 4):
		var n := maxi(8, int(TAU * r / 6.0))
		for s in n:
			var a := TAU * s / n
			var x := p.x + cos(a) * r
			var z := p.z + sin(a) * r
			var y := IstGeo.h(x, z)
			if y > 0.6:
				return Vector3(x, y, z)
	return p


# ------------------------------------------------------------------ ölçüm

func olcum() -> Dictionary:
	var tris := 0
	var draws := 0
	for c in get_children():
		if c is MeshInstance3D and (c as MeshInstance3D).visible and (c as MeshInstance3D).mesh != null:
			var m := (c as MeshInstance3D).mesh
			for s in m.get_surface_count():
				draws += 1
				if m is ArrayMesh:
					var a := (m as ArrayMesh).surface_get_arrays(s)
					var ix = a[Mesh.ARRAY_INDEX]
					tris += (ix.size() if ix != null else (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
				elif m is PlaneMesh:
					var pm := m as PlaneMesh
					tris += (pm.subdivide_width + 1) * (pm.subdivide_depth + 1) * 2
	var lods := [0, 0, 0, 0]
	for k in _chunks:
		var l: int = _chunks[k]["lod"]
		if l >= 0:
			lods[l] += 1
	return {"tris": tris, "draws": draws, "lod": lods, "isler": _jobs.size() + (0 if _job.is_empty() else 1),
		"kare_us": _son_kare_us, "kurulum_ms": _t_kurulum_ms}
