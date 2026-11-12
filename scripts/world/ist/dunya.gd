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
## Çekirdek (şehir ve çevresi) parça ızgarası: dünya metre
const CX0 := -3072.0
const CZ0 := -3072.0
const CH := 768.0
const CNX := 7
const CNZ := 6
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
	_gok()
	_deniz()
	_ufuk()
	# çekirdek: önce hepsi kaba (lod 3), sonra merkeze yakınlar zaman dilimli inceltilir
	for i in CNX:
		for j in CNZ:
			var k := Vector2i(i, j)
			var mi := MeshInstance3D.new()
			mi.name = "Arazi_%d_%d" % [i, j]
			mi.material_override = Nature.ground_material()
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(mi)
			_chunks[k] = {"mi": mi, "lod": -1}
			var job := _is_baslat(k, 3)
			while not _is_ilerle(job, 1 << 62):
				pass
	_dis_halka()
	_carpisma_kur()
	_t_kurulum_ms = (Time.get_ticks_usec() - t0) / 1000.0
	print("ISTDUNYA kurulum_ms=%.0f" % _t_kurulum_ms)


# ------------------------------------------------------------------ izleme

func _bakan() -> Vector3:
	if izle != null and is_instance_valid(izle) and izle.is_inside_tree():
		return izle.global_position
	var c := get_viewport().get_camera_3d() if is_inside_tree() else null
	if c != null:
		return c.global_position
	return merkez


func _process(_dt: float) -> void:
	var t0 := Time.get_ticks_usec()
	var p := _bakan()
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


## Mahalle türü (20 m önbellek; IstGeo.mahalle pahalı)
func _mah(x: float, z: float) -> Dictionary:
	var k := Vector2i(floori(x / 20.0), floori(z / 20.0))
	var t = _tur_cache.get(k)
	if t == null:
		t = IstGeo.mahalle(k.x * 20.0 + 10.0, k.y * 20.0 + 10.0)
		_tur_cache[k] = t
	return t


const C_CAYIR := Color("7a8752")
const C_KURU := Color("a0976a")
const C_TOPRAK := Color("94805e")
const C_CIGNEN := Color("86735a")
const C_TASLIK := Color("948a74")
const C_KUM := Color("c2ae80")
const C_BOSTAN := Color("627e46")
const C_TABAN := Color("6a7a68")


## Köşe rengi: çayır / toprak / taşlık / kıyı kumu; şehir içinde mahalleye göre (çarşı ve sık mahalle çiğnenmiş
## toprak, bostan koyu yeşil, harabe taşlık), sur önü ovası kuru çayır, uzak tepeler havaya karışır.
func _renk(x: float, z: float, y: float, egim: float) -> Color:
	if y < -0.4:
		return C_TABAN.lerp(C_KUM, clampf(1.0 + y / 6.0, 0.0, 1.0))
	var g := sin(x * 0.021 + z * 0.013) * 0.5 + sin(x * 0.0071 - z * 0.0093 + 1.3) * 0.5
	var c := C_CAYIR.lerp(C_KURU, clampf(0.45 + g * 0.45, 0.0, 1.0))
	var b := IstGeo.bolge(x, z)
	var yakin := absf(x + 600.0) < 2600.0 and absf(z + 200.0) < 2400.0
	if b == IstGeo.B_YARIMADA or b == IstGeo.B_GALATA:
		var m := _mah(x, z) if yakin else {"tur": "seyrek", "yogunluk": 0.3}
		var yog: float = m["yogunluk"]
		var cig := C_CIGNEN.lerp(C_TOPRAK, clampf(0.5 + g * 0.5, 0.0, 1.0))
		match m["tur"]:
			"bostan":
				c = C_BOSTAN.lerp(C_CAYIR, clampf(0.3 + g * 0.5, 0.0, 1.0))
			"harabe":
				c = C_TASLIK.lerp(C_TOPRAK, clampf(0.4 + g * 0.4, 0.0, 1.0))
			_:
				c = c.lerp(cig, clampf(0.25 + yog * 0.9, 0.0, 1.0))
	elif b == IstGeo.B_TRAKYA and yakin:
		# kuşatma ovası: surların önü çiğnenmiş toprak, ötesi kuru çayır
		var dk := IstGeo.cizgi_uzak(Vector2(x, z), IstGeo.Y_KARA) if x < -1700.0 and x > -3400.0 and z > -2000.0 and z < 1200.0 else 999.0
		c = C_CIGNEN.lerp(c, smoothstep(30.0, 160.0, dk))
	elif b == IstGeo.B_ANADOLU:
		c = c.lerp(Color("5f7a40"), 0.35)
	if b == IstGeo.B_TRAKYA or b == IstGeo.B_ANADOLU:
		c = c.lerp(C_KURU, 0.25).darkened(0.05)
	# taşlık yamaç
	c = c.lerp(C_TASLIK, smoothstep(0.35, 0.7, egim) * 0.8)
	# kıyı kumu
	if y < 1.6:
		c = C_KUM.lerp(c, smoothstep(0.7, 1.6, y))
	return c


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
		mi.material_override = Nature.ground_material()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)


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
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	e.fog_enabled = true
	e.fog_mode = Environment.FOG_MODE_DEPTH
	e.fog_light_color = Color("c9d6de")
	e.fog_depth_begin = 1400.0
	e.fog_depth_end = 9000.0
	e.fog_depth_curve = 1.6
	e.fog_density = 1.0
	e.fog_aerial_perspective = 0.3
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.2
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.08
	e.adjustment_contrast = 1.05
	env.environment = e
	add_child(env)
	_env = e
	_sun = DirectionalLight3D.new()
	_sun.name = "Gunes"
	_sun.rotation_degrees = Vector3(-38, 32, 0)
	_sun.light_color = Color("ffe6c4")
	_sun.light_energy = 1.15
	_sun.shadow_enabled = true
	_sun.directional_shadow_max_distance = 140.0
	add_child(_sun)
	if gece:
		sm.sky_top_color = Color("0b1330")
		sm.sky_horizon_color = Color("2a3560")
		sm.ground_horizon_color = Color("1c2238")
		sm.ground_bottom_color = Color("10141f")
		e.fog_light_color = Color("1c2440")
		e.fog_depth_begin = 600.0
		e.fog_depth_end = 6000.0
		e.ambient_light_energy = 0.22
		_sun.rotation_degrees = Vector3(-50, -140, 0)
		_sun.light_color = Color("9fb4e8")
		_sun.light_energy = 0.28
		SkyBody.attach(self, _sun, true)
	else:
		SkyBody.attach(self, _sun)


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
	var o := Vector3.ZERO
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
	izle.global_position = k + Vector3(0, 1.0, 0)
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
