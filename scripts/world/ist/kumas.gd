extends RefCounted
## TUR-12 KUMAŞ: bayrak / sancak / flama / tente / çamaşır için ortak ağ ve malzeme (class_name YOK; preload ile:
## const KUMAS := preload("res://scripts/world/ist/kumas.gd")). Gölgelendirici: assets/shaders/ist_kumas.gdshader.
##
## * Bayrak ince, çift yüzlü bir ızgaradır (kutu kalınlığı YOK). Direk kenarı sabit; gölgelendirici bayrağı DÜNYA rüzgâr
##   yönüne yeniden kurar (aynı sahnedeki bütün bayraklar aynı yöne uçar), serbest uç dalgalanır; uzakta dalga söner.
## * Desen: taban renk + dikdörtgen yamalar [u0, v0, u1, v1, renk] (u direkten uca 0…1, v üstten alta 0…1). Izgara
##   çizgileri yama kenarlarından da geçer: her hücre tek renk, üst üste binen (z-kavgası yapan) ikinci yüz yok.
## * Fizik gövdesi yok, çarpışma yok (eski bayrak kutularının da yoktu).

const SHADER := preload("res://assets/shaders/ist_kumas.gdshader")
const KIP_SABIT := 0.0
const KIP_BAYRAK := 1.0
const KIP_SARKIK := 2.0
## Sahnenin rüzgârı (dünya, yatay): gölgelendiricinin varsayılanı ile aynı
const RUZGAR := Vector3(0.62, 0.0, 0.78)

static var _mats := {}
static var _meshes := {}
## Kurulan bayrak sayısı (denetim / rapor)
static var sayac := 0


## Paylaşılan malzeme. srgb: köşe renkleri sRGB (Props renkleri gibi); false: doğrusal kabul + ordugâh vmat çarpanı.
static func mat(srgb := true) -> ShaderMaterial:
	var key := "s" if srgb else "l"
	if _mats.has(key):
		return _mats[key]
	var m := ShaderMaterial.new()
	m.shader = SHADER
	m.set_shader_parameter("renk_srgb", srgb)
	m.set_shader_parameter("carpan", Vector3.ONE if srgb else Vector3(0.78, 0.76, 0.72))
	_mats[key] = m
	return m


## Izgara kesim noktaları: düzgün n bölme + yama kenarları
static func _kesim(n: int, ekler: Array) -> PackedFloat32Array:
	var s := {}
	for i in n + 1:
		s[snappedf(float(i) / n, 0.0001)] = true
	for e in ekler:
		s[snappedf(clampf(float(e), 0.0, 1.0), 0.0001)] = true
	var k := s.keys()
	k.sort()
	var out := PackedFloat32Array()
	for x in k:
		if out.is_empty() or float(x) - out[out.size() - 1] > 0.001:
			out.append(float(x))
	return out


static func _renk(u: float, v: float, taban: Color, yamalar: Array) -> Color:
	var c := taban
	for y in yamalar:
		if u >= float(y[0]) and u <= float(y[2]) and v >= float(y[1]) and v <= float(y[3]):
			c = y[4]
	return c


## Bayrak ızgarasını dizilere ekler. ust: direk ekseninde bayrağın üst köşesi (ağın yerel uzayında); yon: dinlenme yönü
## (yatay; yalnız gölgelendirici çalışmadığında / sınır kutusu için); L boy (direkten uca), H yükseklik.
## kat: true ise sabit (gölgelendiricisiz) çift yüz (uzak LOD ağları için), false ise kip 1 (dalgalanır).
static func bayrak_diz(v: PackedVector3Array, n: PackedVector3Array, c: PackedColorArray, uv: PackedVector2Array,
		uv2: PackedVector2Array, ust: Vector3, yon: Vector3, L: float, H: float, taban: Color, yamalar: Array = [],
		nx := 8, kat := false, cift := false, catal := 0.0, koken := false, hilal := false, yerel := false) -> void:
	var d := Vector3(yon.x, 0.0, yon.z)
	d = d.normalized() if d.length() > 0.001 else Vector3(0, 0, 1)
	var eu: Array = []
	var ev: Array = []
	for y in yamalar:
		eu.append(y[0]); eu.append(y[2])
		ev.append(y[1]); ev.append(y[3])
	var us := _kesim(nx, eu)
	if catal > 0.0:
		ev.append(0.5)
	var vs := _kesim(1, ev)
	var fn := Vector3.DOWN.cross(d).normalized()      # ön yüz normali (Godot: saat yönü ön yüz; gölgelendiricideki ile aynı)
	# çatallı (kırlangıç kuyruğu) flama: uç kenarın ortası (u 1, v 0,5) catal kadar içeri çekilir
	var U := func(u: float, w: float) -> float:
		if catal > 0.0 and u > 0.999:
			return 1.0 - catal * (1.0 - absf(w - 0.5) * 2.0)
		return u
	var P := func(u: float, w: float) -> Vector3:
		return ust + d * (float(U.call(u, w)) * L) + Vector3(0, -w * H, 0)
	for i in us.size() - 1:
		for j in vs.size() - 1:
			var u0 := us[i]
			var u1 := us[i + 1]
			var v0 := vs[j]
			var v1 := vs[j + 1]
			var col := _renk((u0 + u1) * 0.5, (v0 + v1) * 0.5, taban, yamalar)
			var q := [[u0, v0], [u1, v0], [u0, v1], [u1, v0], [u1, v1], [u0, v1]]
			var yuz := [false, true] if cift else [false]
			for arka in yuz:
				for k in 6:
					var kk: int = k if not arka else [0, 2, 1, 3, 5, 4][k]
					var uu: float = q[kk][0]
					var ww: float = q[kk][1]
					v.append(P.call(uu, ww))
					n.append(-fn if arka else fn)
					var cc := col.darkened(0.08) if arka else col
					cc.a = 0.5 if hilal else 1.0
					c.append(cc)
					if kat:
						uv.append(Vector2(0.0, KIP_SABIT))
						uv2.append(Vector2(ust.x, ust.z))
					elif koken:
						# kip 10 + L: direk ekseni ağın kökeninde; UV2 = (v, H) (parça deseni: hilal)
						uv.append(Vector2(float(U.call(uu, ww)) * L, 10.0 + L))
						uv2.append(Vector2(ww, -H if yerel else H))
					else:
						uv.append(Vector2(float(U.call(uu, ww)) * L, KIP_BAYRAK))
						uv2.append(Vector2(ust.x, ust.z))


## Tek bayrak düğümü (Props.box bayraklarının yerine): yerel köken = direkteki üst köşe. Ağ önbellekli.
## Döner: MeshInstance3D (adı "Bayrak"; çarpışmasız, gölge verir).
## yerel: bayrak sahne rüzgârına değil kendi kurulduğu yöne uçar (duvara/gövdeye yakın bayrak duvarın içine dönmesin)
## catal: kırlangıç kuyruğu derinliği (0…0,5, L'nin oranı); hilal: Osmanlı hilali (beyaz; parça gölgelendiricisinde keskin)
static func bayrak(parent: Node3D, ust: Vector3, yon: Vector3, L: float, H: float, taban: Color, yamalar: Array = [],
		nx := 8, ad := "Bayrak", catal := 0.0, hilal := false, yerel := false) -> MeshInstance3D:
	var key := "%s|%s|%s|%s|%s|%d|%s|%s|%s" % [yon.snapped(Vector3.ONE * 0.01), L, H, taban.to_html(), str(yamalar), nx, catal, hilal, yerel]
	var am: ArrayMesh = _meshes.get(key)
	if am == null:
		var v := PackedVector3Array()
		var n := PackedVector3Array()
		var c := PackedColorArray()
		var uv := PackedVector2Array()
		var uv2 := PackedVector2Array()
		bayrak_diz(v, n, c, uv, uv2, Vector3.ZERO, yon, L, H, taban, yamalar, nx, false, false, catal, true, hilal, yerel)
		am = _dizi_ag(v, n, c, uv, uv2)
		# gölgelendirici bayrağı her yöne çevirebilir: sınır kutusu direğin çevresinde L yarıçaplı
		am.custom_aabb = AABB(Vector3(-L - 0.3, -H - L * 0.4 - 0.3, -L - 0.3), Vector3(2.0 * L + 0.6, H + L * 0.4 + 0.6, 2.0 * L + 0.6))
		_meshes[key] = am
	var mi := MeshInstance3D.new()
	mi.mesh = am
	mi.material_override = mat(true)
	mi.position = ust
	mi.name = ad
	mi.set_meta("no_walk", true)
	parent.add_child(mi)
	sayac += 1
	return mi


static func _dizi_ag(v: PackedVector3Array, n: PackedVector3Array, c: PackedColorArray, uv: PackedVector2Array,
		uv2: PackedVector2Array) -> ArrayMesh:
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_NORMAL] = n
	arr[Mesh.ARRAY_COLOR] = c
	arr[Mesh.ARRAY_TEX_UV] = uv
	arr[Mesh.ARRAY_TEX_UV2] = uv2
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return am


## Sarkık kumaş için ağırlık işareti: i0'dan bu yana eklenen köşelere kip 2 yazar. agirlik: Callable(Vector3) -> float
## (0 tutturulmuş … 1 serbest). Diziler v ile eşit boya getirilir (öncesi sabit).
static func sarkik_isaretle(v: PackedVector3Array, uv: PackedVector2Array, uv2: PackedVector2Array, i0: int,
		agirlik: Callable, evre := 0.0, genlik := 1.0) -> void:
	esitle(v, uv, uv2, i0)
	for i in range(i0, v.size()):
		uv.append(Vector2(clampf(float(agirlik.call(v[i])), 0.0, 1.0), KIP_SARKIK))
		uv2.append(Vector2(evre, genlik))


## uv/uv2'yi v'nin boyuna (ya da verilen boya) sabit kiple doldurur
static func esitle(v: PackedVector3Array, uv: PackedVector2Array, uv2: PackedVector2Array, boy := -1) -> void:
	var hedef := v.size() if boy < 0 else boy
	while uv.size() < hedef:
		uv.append(Vector2(0.0, KIP_SABIT))
	while uv2.size() < hedef:
		uv2.append(Vector2.ZERO)


## Sarkık kumaş levha (tente, saçak): merkez c, genişlik w (x), derinlik d (z), x ekseni çevresinde eğim (derece; +z
## kenarı aşağı), ortası sarkma kadar çöker. renk: Callable(u, v) -> Color (u x boyunca, v z boyunca 0…1). saçak: ön
## (+z) kenardan sarkan perde yüksekliği (0 = yok), saçak rengi sc. Kip 2: köşeler (direklere bağlı) sabit, kenar
## ortaları ve saçağın alt ucu hafif nefes alır. Tek MeshInstance (ince çift yüz), çarpışmasız.
static func sarkik_levha(parent: Node3D, c: Vector3, w: float, d: float, egim: float, sarkma: float, renk: Callable,
		sacak := 0.0, sc := Color.WHITE, nx := 10, nz := 8, ad := "Tente") -> MeshInstance3D:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var cl := PackedColorArray()
	var uv := PackedVector2Array()
	var uv2 := PackedVector2Array()
	var e := deg_to_rad(egim)
	var P := func(u: float, t: float) -> Vector3:
		var x := (u - 0.5) * w
		var z := (t - 0.5) * d
		var y := -sin(PI * u) * sin(PI * t) * sarkma
		return Vector3(x, y - z * sin(e), z * cos(e))
	var Wt := func(u: float, t: float) -> float:
		return clampf((sin(PI * u) + sin(PI * t)) * 0.6, 0.0, 1.0)
	var quad := func(a: Vector3, b: Vector3, cc: Vector3, dd: Vector3, col: Color, wa: float, wb: float, wc: float, wd: float) -> void:
		# a-b-cc-dd; tek yüz (gölgelendirici cull_disabled: arka yüz aynı üçgen, normali Godot çevirir)
		var nn := (b - a).cross(dd - a).normalized()
		for arka in [false]:
			var tri: Array = [[a, wa], [b, wb], [cc, wc], [a, wa], [cc, wc], [dd, wd]]
			if arka:
				tri = [[a, wa], [cc, wc], [b, wb], [a, wa], [dd, wd], [cc, wc]]
			for q in tri:
				v.append(q[0])
				n.append(nn if arka else -nn)      # Godot: saat yönü ön yüz → ön normal −(b−a)×(c−a)
				cl.append(col.darkened(0.12) if arka else col)
				uv.append(Vector2(float(q[1]), KIP_SARKIK))
				uv2.append(Vector2(c.x * 0.3 + c.z * 0.2, 1.5))
	for i in nx:
		for j in nz:
			var u0 := float(i) / nx
			var u1 := float(i + 1) / nx
			var t0 := float(j) / nz
			var t1 := float(j + 1) / nz
			var col: Color = renk.call((u0 + u1) * 0.5, (t0 + t1) * 0.5)
			quad.call(P.call(u0, t1), P.call(u1, t1), P.call(u1, t0), P.call(u0, t0), col,
				Wt.call(u0, t1), Wt.call(u1, t1), Wt.call(u1, t0), Wt.call(u0, t0))
	if sacak > 0.0:
		for i in nx:
			var u0 := float(i) / nx
			var u1 := float(i + 1) / nx
			var a: Vector3 = P.call(u0, 1.0)
			var b: Vector3 = P.call(u1, 1.0)
			# saçak dilimleri: kenarda sabit, alt uçta serbest; dişli alt kenar
			var dis := sacak * (0.85 if i % 2 == 0 else 1.0)
			quad.call(a, b, b + Vector3(0, -dis, 0), a + Vector3(0, -dis, 0), sc, 0.0, 0.0, 1.0, 1.0)
	var mi := MeshInstance3D.new()
	mi.mesh = _dizi_ag(v, n, cl, uv, uv2)
	mi.material_override = mat(true)
	mi.position = c
	mi.name = ad
	mi.set_meta("no_walk", true)
	parent.add_child(mi)
	return mi
