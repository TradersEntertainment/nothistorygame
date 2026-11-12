extends RefCounted
## ŞEHİR-3 yardımcıları (IstSehir'in eser kurucuları; catalog() yok, modül taramasına girmez):
##   palace(): Blakherna Sarayı (Tekfur Sarayı dili: üç katlı, taş-tuğla şeritli cephe, kemerli pencere sıraları,
##             zemin katta kemerli revak, üst katta balkon, kiremit kırma çatı, yan kuleler, şehir yanında avlu).
## Yerel düzen: sur iç yüzü z ≈ +2 (dış +z), saray gövdesi z −26…−16, avlu z −26…−44 (şehre bakar).

const STONE := Color("d8c8a8")
const BRICK := Color("9a5040")
const TILE := Color("a4553a")
const DARK := Color("221c18")
const LIT := Color("ffc070")


static func _sol(n: Node3D, size: Vector3, pos: Vector3, col: Color, pat: String, lod: int) -> void:
	if lod == 0:
		var b := Props.solid(n, size, pos, Color.WHITE)
		Props.set_pattern(b, col, pat)
	else:
		Props.box(n, size, pos, col)


## Kemerli açıklık (cephede): koyu dikdörtgen + yarım daire tepe + tuğla kemer çerçevesi. nz: cephenin dış normali (±x ya da ±z)
static func _arch(n: Node3D, c: Vector3, w: float, h: float, nrm: Vector3, lit: bool, gece: bool, lod: int) -> void:
	var along_x := absf(nrm.z) > 0.5
	var off := nrm * 0.03
	var rot := Vector3(90, 0, 0) if along_x else Vector3(0, 0, 90)
	var dsz := Vector3(w, h - w * 0.5, 0.06) if along_x else Vector3(0.06, h - w * 0.5, w)
	var col := DARK
	var em := 0.0
	if lit:
		col = LIT
		em = 2.2 if gece else 0.35
	var body := c + Vector3(0, (h - w * 0.5) * 0.5, 0) + off
	var mi := Props.box(n, dsz, body, col)
	if lit:
		mi.material_override = Props.mat(LIT, em, false, "", false)
	if lod <= 1:
		var top := Props.cyl(n, w * 0.5, 0.06, c + Vector3(0, h - w * 0.5, 0) + off, col, rot, 10)
		if lit:
			top.material_override = Props.mat(LIT, em, false, "", false)
		# tuğla kemer (dış yay) ve eşik
		Props.cyl(n, w * 0.5 + 0.28, 0.04, c + Vector3(0, h - w * 0.5, 0) + nrm * 0.015, BRICK, rot, 10)
		var sill := Vector3(w + 0.4, 0.18, 0.3) if along_x else Vector3(0.3, 0.18, w + 0.4)
		Props.box(n, sill, c + Vector3(0, -0.09, 0) + nrm * 0.12, STONE.lightened(0.1))


static func palace(n: Node3D, lod: int, gece: bool) -> void:
	var z0 := -26.0
	var z1 := -16.0
	var W := 26.0
	var H := 16.0
	var zc := (z0 + z1) * 0.5
	# Gövde (üç kat) ve kat şeritleri (tuğla), saçak silmesi
	_sol(n, Vector3(W, H, z1 - z0), Vector3(0, H * 0.5, zc), STONE, "tekfur", lod)
	for y: float in [5.2, 10.4]:
		Props.box(n, Vector3(W + 0.12, 0.45, z1 - z0 + 0.12), Vector3(0, y, zc), BRICK)
	Props.box(n, Vector3(W + 0.6, 0.5, z1 - z0 + 0.6), Vector3(0, H - 0.1, zc), STONE.darkened(0.08))
	if lod <= 1:
		# taş-tuğla şeritler (her katta iki ince tuğla bandı)
		for y: float in [2.0, 7.6, 12.8]:
			Props.box(n, Vector3(W + 0.08, 0.22, z1 - z0 + 0.08), Vector3(0, y, zc), BRICK.lightened(0.06))
	# Kırma çatı (kiremit) + mahya
	Props.prism(n, Vector3(z1 - z0 + 1.0, 3.6, W + 1.0), Vector3(0, H + 0.15 + 1.8, zc), TILE, Vector3(0, 90, 0))
	Props.box(n, Vector3(W + 1.0, 0.25, 0.35), Vector3(0, H + 3.85, zc), TILE.darkened(0.25))
	for sx: float in [-1.0, 1.0]:
		# kalkan uçlarında küçük kırma (çatı yüzü kapalı)
		Props.prism(n, Vector3(z1 - z0 + 1.0, 3.6, 1.2), Vector3(sx * (W * 0.5 + 0.3), H + 0.15 + 1.8, zc), TILE.darkened(0.08), Vector3(0, 90, 0))
	if lod <= 1:
		# Kiremit sıraları (çatı yüzünde ince çizgiler)
		for k in 7:
			var t := (k + 0.5) / 7.0
			var yy := H + 0.15 + 3.6 * (1.0 - t)
			var dz := (z1 - z0 + 1.0) * 0.5 * t
			for sd: float in [-1.0, 1.0]:
				Props.box(n, Vector3(W + 0.9, 0.08, 0.12), Vector3(0, yy + 0.06, zc + sd * dz), TILE.darkened(0.18))
	# Cepheler: uzun yüzlerde (z1 sur yanı, z0 avlu yanı) zemin katta kemerli revak, üst iki katta kemerli pencereler
	for side: float in [1.0, -1.0]:
		var zf := z1 if side > 0.0 else z0
		var nrm := Vector3(0, 0, side)
		for k in 6:
			var x := -10.0 + k * 4.0
			var lit := gece and (k + int(side)) % 3 != 0
			if lod <= 1:
				_arch(n, Vector3(x, 1.0, zf), 2.4, 3.4, nrm, false, gece, lod)
			_arch(n, Vector3(x, 6.4, zf), 1.5, 2.8, nrm, lit, gece, lod)
			_arch(n, Vector3(x, 11.6, zf), 1.5, 2.8, nrm, gece and not lit, gece, lod)
		if lod == 0:
			# revak sütunları (kemerlerin arası)
			for k in 7:
				Props.cyl(n, 0.28, 3.0, Vector3(-12.0 + k * 4.0, 1.5, zf + side * 0.35), Color("e6dccb"), Vector3.ZERO, 8)
	# Kısa yüzler: katta iki pencere
	for sx: float in [-1.0, 1.0]:
		for k in 2:
			for row in 2:
				_arch(n, Vector3(sx * W * 0.5, 6.4 + row * 5.2, zc - 2.4 + k * 4.8), 1.4, 2.6, Vector3(sx, 0, 0), gece and (k + row) % 2 == 0, gece, lod)
	# Balkon (üst kat, avlu yanı; Tekfur Sarayı'nın doğu balkonu): döşeme, konsollar, korkuluk
	var bz := z0 - 0.9
	_sol(n, Vector3(9.0, 0.3, 1.8), Vector3(0, 10.35, bz), STONE.lightened(0.05), "flagstone", lod)
	for k in 4:
		Props.box(n, Vector3(0.35, 0.9, 1.6), Vector3(-3.6 + k * 2.4, 9.75, bz + 0.1), STONE.darkened(0.12))
	if lod <= 1:
		Props.box(n, Vector3(9.0, 0.12, 0.12), Vector3(0, 11.5, bz - 0.84), Color("6a4a30"))
		for k in 13:
			Props.box(n, Vector3(0.06, 1.0, 0.06), Vector3(-4.4 + k * 0.733, 11.0, bz - 0.84), Color("6a4a30"))
		for sx: float in [-4.45, 4.45]:
			Props.box(n, Vector3(0.12, 0.12, 1.7), Vector3(sx, 11.5, bz), Color("6a4a30"))
	# Yan kuleler: şeritli gövde, mazgallı teras, piramit külah
	for sx: float in [-1.0, 1.0]:
		var ox := sx * (W * 0.5 + 2.4)
		_sol(n, Vector3(5.4, 20.0, 5.4), Vector3(ox, 10.0, zc + 1.0), STONE.darkened(0.03), "tekfur", lod)
		for y: float in [4.0, 9.0, 14.0, 19.0]:
			Props.box(n, Vector3(5.52, 0.45, 5.52), Vector3(ox, y, zc + 1.0), BRICK)
		Props.box(n, Vector3(6.0, 0.4, 6.0), Vector3(ox, 20.2, zc + 1.0), STONE.darkened(0.1))
		Props.prism(n, Vector3(5.6, 3.2, 5.6), Vector3(ox, 20.4 + 1.6, zc + 1.0), TILE.darkened(0.1))
		for k in 2:
			_arch(n, Vector3(ox, 6.0 + k * 6.0, zc + 1.0 + 2.7), 1.0, 2.0, Vector3(0, 0, 1), false, gece, lod)
			_arch(n, Vector3(ox + sx * 2.7, 6.0 + k * 6.0, zc + 1.0), 1.0, 2.0, Vector3(sx, 0, 0), gece and k == 1, gece, lod)
		if lod == 0:
			for k in 4:
				for sd: float in [-1.0, 1.0]:
					Props.box(n, Vector3(0.7, 0.8, 0.5), Vector3(ox - 1.9 + k * 1.27, 20.8, zc + 1.0 + sd * 2.75), STONE.darkened(0.06))
	# Altın haç (çatı ortası) ve imparatorluk sancağı
	if lod <= 1:
		Props.cyl(n, 0.12, 2.2, Vector3(0, H + 4.9, zc), Color("d8b040"), Vector3.ZERO, 6)
		Props.box(n, Vector3(1.2, 0.14, 0.14), Vector3(0, H + 5.4, zc), Color("d8b040"))
		for sx: float in [-1.0, 1.0]:
			Props.cyl(n, 0.07, 4.0, Vector3(sx * (W * 0.5 + 2.4), 23.6 + 2.0, zc + 1.0), Color("6a4a30"), Vector3.ZERO, 5)
			Props.box(n, Vector3(0.05, 1.3, 2.0), Vector3(sx * (W * 0.5 + 2.4), 26.6, zc + 2.0), Color("8a1c24"))
	# Avlu (şehir yanı): döşeli zemin, alçak duvar, kapı, kuyu, iki servi
	var a0 := -44.0
	Props.box(n, Vector3(W + 6.0, 0.1, z0 - a0), Vector3(0, 0.05, (z0 + a0) * 0.5), Color("bfb39a")).set_meta("no_walk", true)
	if lod == 0:
		var fl := n.get_child(n.get_child_count() - 1)
		Props.set_pattern(fl, Color("c8bba0"), "flagstone")
	var aw := 3.4
	for sx: float in [-1.0, 1.0]:
		_sol(n, Vector3(0.8, 4.0, z0 - a0), Vector3(sx * (W * 0.5 + 3.0), 2.0, (z0 + a0) * 0.5), STONE.darkened(0.06), "ashlar", lod)
		var seg := (W + 6.0) * 0.5 - aw * 0.5
		_sol(n, Vector3(seg, 4.0, 0.8), Vector3(sx * (aw * 0.5 + seg * 0.5), 2.0, a0), STONE.darkened(0.06), "ashlar", lod)
		Props.box(n, Vector3(seg + 0.2, 0.3, 1.0), Vector3(sx * (aw * 0.5 + seg * 0.5), 4.15, a0), BRICK)
	# kapı kemeri (üstten geçiş: başlık 4,6 m'de)
	Props.box(n, Vector3(aw + 1.6, 1.0, 1.0), Vector3(0, 4.9, a0), STONE.darkened(0.1))
	for sx: float in [-1.0, 1.0]:
		_sol(n, Vector3(0.8, 4.4, 1.0), Vector3(sx * (aw * 0.5 + 0.4), 2.2, a0), STONE.darkened(0.1), "ashlar", lod)
	Props.cyl(n, 1.0, 0.9, Vector3(-6.0, 0.45, -35.0), STONE.darkened(0.15), Vector3.ZERO, 10)
	if lod <= 1:
		Props.box(n, Vector3(0.12, 1.6, 0.12), Vector3(-6.8, 1.2, -35.0), Color("5a3a20"))
		Props.box(n, Vector3(0.12, 1.6, 0.12), Vector3(-5.2, 1.2, -35.0), Color("5a3a20"))
		Props.box(n, Vector3(1.8, 0.12, 0.12), Vector3(-6.0, 2.0, -35.0), Color("5a3a20"))
		for p: Vector3 in [Vector3(9.0, 0, -31.0), Vector3(-10.0, 0, -40.5), Vector3(10.0, 0, -40.5)]:
			Props.cyl(n, 0.18, 1.6, p + Vector3(0, 0.8, 0), Color("5a3a20"), Vector3.ZERO, 5)
			Props.cyl(n, 0.9, 6.0, p + Vector3(0, 4.4, 0), Color("2f4a2a"), Vector3.ZERO, 7, 0.05)
	if lod == 0:
		# kapılar: sur yanı ve avlu yanı (orta kemerin altı, koyu kanat)
		for side: float in [1.0, -1.0]:
			Props.box(n, Vector3(2.0, 2.6, 0.12), Vector3(0, 1.3, (z1 if side > 0 else z0) + side * 0.07), Color("4a3020"))


# ---------------------------------------------------------------- uzak sur katmanı (kalite notu 11)

## Uzak sur ağının malzemesi: köşe rengi (kireçtaşı krem / tuğla) + dikey yüzlerde dünya yüksekliğine bağlı tuğla
## şeritleri (Theodosius surlarının taş-tuğla şeridi: ~1,9 m'de bir 0,45 m'lik beş sıra tuğla) ve ince taş sırası
## çizgileri; yatay yüzler (yürüme yolu, kule terası) düz taş. Işık oyunun toon diliyle (gece ay ışığında da taş rengi).
static var _sur_uzak_mat: ShaderMaterial

static func sur_uzak_mat() -> ShaderMaterial:
	if _sur_uzak_mat != null:
		return _sur_uzak_mat
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode diffuse_toon, specular_disabled;
varying vec3 wpos;
varying vec3 wnrm;
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}
void fragment() {
	// köşe rengi sRGB olarak saklı (albedo_color'dan): doğrusala çevrilir (yoksa uzak sur yakınından açık ve gece
	// ay ışığında bembeyaz görünüyordu)
	vec3 c = pow(COLOR.rgb, vec3(2.2));
	float vert = step(abs(wnrm.y), 0.5);
	float stone = step(COLOR.r - COLOR.b, 0.24);
	float band = step(fract((wpos.y + 0.35) / 1.9), 0.24) * vert * stone;
	float course = step(fract(wpos.y / 0.62), 0.07) * vert * stone;
	float joint = step(fract((wpos.x + wpos.z) / 1.3), 0.04) * vert * stone * (1.0 - band);
	c = mix(c, pow(vec3(0.58, 0.31, 0.22), vec3(2.2)), band * 0.85);
	c *= 1.0 - (course + joint) * 0.10;
	ALBEDO = c;
	ROUGHNESS = 0.95;
}
"""
	_sur_uzak_mat = ShaderMaterial.new()
	_sur_uzak_mat.shader = sh
	return _sur_uzak_mat


## Pişmiş uzak sur ağına mazgal dişleri: yerel eksene hizalı, yukarı bakan geniş üst yüzlerin (sur yürüme yolu,
## kule terası; y > ymin) dış kenarları boyunca 2,1 m'de bir diş (1,0 × 1,1 × 0,7). st'ye xf ile eklenir.
static func mazgal(st: SurfaceTool, m: Mesh, xf: Transform3D, ymin: float) -> int:
	if m == null:
		return 0
	var seen := {}
	var n := 0
	var col := Color("cbbd9e")
	for si in m.get_surface_count():
		var arr := m.surface_get_arrays(si)
		var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var ia = arr[Mesh.ARRAY_INDEX]
		var idx: PackedInt32Array = ia if ia is PackedInt32Array else PackedInt32Array()
		var cnt := idx.size() if idx.size() > 0 else vs.size()
		for t in range(0, cnt - 2, 3):
			var a: Vector3 = vs[idx[t] if idx.size() > 0 else t]
			var b: Vector3 = vs[idx[t + 1] if idx.size() > 0 else t + 1]
			var c: Vector3 = vs[idx[t + 2] if idx.size() > 0 else t + 2]
			if absf(a.y - b.y) > 0.05 or absf(a.y - c.y) > 0.05 or a.y < ymin:
				continue
			var lo := Vector2(minf(a.x, minf(b.x, c.x)), minf(a.z, minf(b.z, c.z)))
			var hi := Vector2(maxf(a.x, maxf(b.x, c.x)), maxf(a.z, maxf(b.z, c.z)))
			var sz := hi - lo
			var area := absf((b - a).cross(c - a).y) * 0.5
			# eksene hizalı dikdörtgenin yarısı (üçgen alanı ≈ kutunun yarısı)
			if sz.x < 1.6 or sz.y < 1.6 or absf(area - sz.x * sz.y * 0.5) > sz.x * sz.y * 0.05:
				continue
			var key := "%d|%d|%d|%d|%d" % [roundi(lo.x * 4), roundi(lo.y * 4), roundi(hi.x * 4), roundi(hi.y * 4), roundi(a.y * 4)]
			if seen.has(key):
				continue
			seen[key] = true
			var y := a.y
			var kare := minf(sz.x, sz.y) > 3.5 and maxf(sz.x, sz.y) < minf(sz.x, sz.y) * 1.8
			# uzun kenarlar (kule terasında dört kenar)
			var edges: Array = []
			if sz.x >= sz.y or kare:
				edges.append([Vector2(lo.x, lo.y + 0.35), Vector2(hi.x, lo.y + 0.35)])
				edges.append([Vector2(lo.x, hi.y - 0.35), Vector2(hi.x, hi.y - 0.35)])
			if sz.y > sz.x or kare:
				edges.append([Vector2(lo.x + 0.35, lo.y), Vector2(lo.x + 0.35, hi.y)])
				edges.append([Vector2(hi.x - 0.35, lo.y), Vector2(hi.x - 0.35, hi.y)])
			for e: Array in edges:
				var p0: Vector2 = e[0]
				var p1: Vector2 = e[1]
				var L := p0.distance_to(p1)
				var k := maxi(int(L / 2.1), 1)
				var bas := Basis(Vector3.UP, 0.0 if absf(p1.y - p0.y) < 0.01 else PI * 0.5)
				for i in k:
					var q := p0.lerp(p1, (i + 0.5) / k)
					IstSehir._box_st(st, xf * Vector3(q.x, y, q.y), xf.basis * bas, Vector3(1.0, 1.1, 0.7), col)
					n += 1
	return n


# ---------------------------------------------------------------- manastır avlusu (Khora, Pammakaristos)

## Kilisenin çevresinde manastır külliyesi: avlu duvarı (kapılı, kiremit başlıklı), avluyu çeviren keşiş hücreleri
## sırası (revaklı, kiremit çatılı), trapeza (yemekhane), çan yerine simandron çerçevesi, şadırvan/kuyu, servi ve
## meyve ağaçları, döşeli yollar. hx, hz: avlunun yarı eni/boyu (yerel; kilise ortada). Kapı +z (batı cephesi) yanında.
static func manastir(n: Node3D, lod: int, hx: float, hz: float, seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var wall := STONE.darkened(0.08)
	var t := 0.8
	var wh := 3.6
	var gate := 3.6
	# avlu zemini: çakıl-toprak + döşeli yollar
	var zem := Props.box(n, Vector3(hx * 2.0, 0.08, hz * 2.0), Vector3(0, 0.04, 0), Color("b9ab8c"))
	zem.set_meta("no_walk", true)
	if lod == 0:
		Props.set_pattern(zem, Color("bfb194"), "cobble")
	Props.box(n, Vector3(3.0, 0.1, hz - 6.0), Vector3(0, 0.09, hz * 0.5 + 3.0), Color("cfc2a8")).set_meta("no_walk", true)
	# duvarlar (kapı +z ortada, arka kapı −z)
	for sx: float in [-1.0, 1.0]:
		_sol(n, Vector3(t, wh, hz * 2.0), Vector3(sx * hx, wh * 0.5, 0), wall, "ashlar", lod)
		Props.box(n, Vector3(t + 0.3, 0.3, hz * 2.0 + 0.3), Vector3(sx * hx, wh + 0.15, 0), TILE)
		for sz: float in [-1.0, 1.0]:
			var seg := hx - gate * 0.5
			_sol(n, Vector3(seg, wh, t), Vector3(sx * (gate * 0.5 + seg * 0.5), wh * 0.5, sz * hz), wall, "ashlar", lod)
			Props.box(n, Vector3(seg + 0.3, 0.3, t + 0.3), Vector3(sx * (gate * 0.5 + seg * 0.5), wh + 0.15, sz * hz), TILE)
	# ana kapı: kemerli kapı yapısı, üstte küçük kiremit çatı
	for sx: float in [-1.0, 1.0]:
		_sol(n, Vector3(1.0, 5.0, 1.6), Vector3(sx * (gate * 0.5 + 0.5), 2.5, hz), wall.darkened(0.05), "ashlar", lod)
	Props.box(n, Vector3(gate + 2.0, 1.0, 1.6), Vector3(0, 5.0, hz), wall.darkened(0.05))
	Props.prism(n, Vector3(gate + 2.6, 1.3, 2.2), Vector3(0, 6.15, hz), TILE)
	if lod <= 1:
		Props.cyl(n, gate * 0.5, 1.62, Vector3(0, 4.5, hz), Color("2a2420"), Vector3(90, 0, 0), 10)
		Props.box(n, Vector3(0.1, 1.2, 0.1), Vector3(0, 7.3, hz), Color("d8b040"))
		Props.box(n, Vector3(0.7, 0.1, 0.1), Vector3(0, 7.55, hz), Color("d8b040"))
	# keşiş hücreleri: iki yan duvar boyunca revaklı sıra (iç yüz), kiremit eğik çatı
	var cw := 4.2
	for sx: float in [-1.0, 1.0]:
		var x := sx * (hx - t * 0.5 - cw * 0.5)
		var L := hz * 2.0 - 10.0
		_sol(n, Vector3(cw, 4.4, L), Vector3(x, 2.2, -1.0), STONE.lightened(0.04), "plaster", lod)
		Props.prism(n, Vector3(cw + 1.2, 1.6, L + 0.6), Vector3(x, 4.4 + 0.8, -1.0), TILE.darkened(0.05))
		if lod <= 1:
			var nk := int(L / 3.6)
			for k in nk:
				var z := -1.0 - L * 0.5 + (k + 0.5) * L / nk
				Props.box(n, Vector3(0.06, 1.9, 0.9), Vector3(x - sx * (cw * 0.5 + 0.03), 0.95, z), Color("3a2a1c"))
				Props.box(n, Vector3(0.06, 0.7, 0.6), Vector3(x - sx * (cw * 0.5 + 0.03), 3.0, z + 0.9), Color("221c18"))
	# trapeza (yemekhane): arka duvara yaslı uzun yapı, apsisli
	var tz := -hz + t * 0.5 + 3.0
	_sol(n, Vector3(hx * 1.1, 6.0, 6.0), Vector3(0, 3.0, tz), STONE, "ashlar", lod)
	Props.prism(n, Vector3(6.6, 2.2, hx * 1.1 + 0.6), Vector3(0, 6.0 + 1.1, tz), TILE, Vector3(0, 90, 0))
	Props.box(n, Vector3(hx * 1.1 + 0.1, 0.35, 6.1), Vector3(0, 3.2, tz), BRICK)
	if lod <= 1:
		for k in 5:
			_arch(n, Vector3(-hx * 0.44 + k * hx * 0.22, 2.4, tz + 3.0), 1.0, 2.0, Vector3(0, 0, 1), false, false, lod)
	# simandron çerçevesi (çan yerine tahta), kuyu/şadırvan
	var sx2 := hx * 0.55
	var sz2 := hz * 0.55
	for dx: float in [-0.9, 0.9]:
		Props.box(n, Vector3(0.22, 3.2, 0.22), Vector3(sx2 + dx, 1.6, sz2), Color("5a3a20"))
	Props.box(n, Vector3(2.2, 0.22, 0.22), Vector3(sx2, 3.2, sz2), Color("5a3a20"))
	Props.box(n, Vector3(1.5, 0.3, 0.12), Vector3(sx2, 2.5, sz2), Color("8a6a40"))
	Props.cyl(n, 1.1, 0.8, Vector3(-sx2, 0.4, sz2), STONE.darkened(0.12), Vector3.ZERO, 10)
	Props.cyl(n, 1.3, 0.25, Vector3(-sx2, 3.0, sz2), TILE, Vector3.ZERO, 8, 0.2)
	for dx: float in [-1.0, 1.0]:
		Props.box(n, Vector3(0.14, 2.6, 0.14), Vector3(-sx2 + dx, 1.7, sz2), Color("5a3a20"))
	# ağaçlar: serviler duvar boyu, meyve ağaçları (erik/badem çiçekte) bahçede
	for k in 8:
		var a := rng.randf() * TAU
		var p := Vector3(cos(a) * hx * 0.7, 0, sin(a) * hz * 0.7)
		if absf(p.x) < 13.0 and absf(p.z) < 13.0:
			continue
		if absf(p.x) > hx - t - cw - 1.2:
			continue
		var cyp := k % 2 == 0
		Props.cyl(n, 0.16, 1.6, p + Vector3(0, 0.8, 0), Color("5a3a20"), Vector3.ZERO, 5)
		if cyp:
			Props.cyl(n, 0.8, 6.5, p + Vector3(0, 4.6, 0), Color("27402a"), Vector3.ZERO, 7, 0.05)
		else:
			Props.ball(n, 1.6, p + Vector3(0, 2.9, 0), Color("e8c8d0") if k % 3 == 0 else Color("6a8a4a"), Vector3(1, 0.8, 1), 7)


# ---------------------------------------------------------------- Ayasofya meydanı (oyun alanı; Augustaion'un batısı)

## Oyun alanının zemini boş çayır kalmasın: sıcak gri-krem kireçtaşı döşeme (düzensiz derzli desen), kenar taşı, köşelerde
## çınarlar, bir kenarda mumcu/ikona tezgâhları, bir köşede çeşme, taş sekiler. Orta alan (bölümlerin oynanışı) boş.
## Yerel: merkez (0,0), sx × sz dünya ekseninde.
static func meydan(n: Node3D, lod: int, sx: float, sz: float) -> void:
	var tas := Color("c8bea6")
	var f := Props.box(n, Vector3(sx, 0.14, sz), Vector3(0, 0.07, 0), tas)
	f.set_meta("no_walk", true)
	if lod == 0:
		Props.set_pattern(f, tas, "flagstone")
	if lod >= 2:
		return
	for s: float in [-1.0, 1.0]:
		Props.box(n, Vector3(sx + 0.4, 0.22, 0.4), Vector3(0, 0.11, s * (sz * 0.5 + 0.2)), tas.darkened(0.15))
		Props.box(n, Vector3(0.4, 0.22, sz), Vector3(s * (sx * 0.5 + 0.2), 0.11, 0), tas.darkened(0.15))
	# köşe çınarları (gövde + iri taç)
	for c: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		var p := Vector3(c.x * (sx * 0.5 - 3.0), 0, c.y * (sz * 0.5 - 3.0))
		Props.cyl(n, 1.3, 0.5, p + Vector3(0, 0.25, 0), tas.darkened(0.2), Vector3.ZERO, 10)
		Props.cyl(n, 0.35, 5.0, p + Vector3(0, 2.6, 0), Color("6a5640"), Vector3.ZERO, 7)
		Props.ball(n, 3.6, p + Vector3(0, 7.2, 0), Color("4f7a3a"), Vector3(1.0, 0.75, 1.0), 9)
	# çeşme (kuzeybatı köşesine yakın): kemerli taş gövde, kurna
	var cp := Vector3(-sx * 0.5 + 9.0, 0, -sz * 0.5 + 2.2)
	Props.box(n, Vector3(4.0, 3.2, 1.6), cp + Vector3(0, 1.6, 0), Color("ddd2bc"))
	Props.prism(n, Vector3(4.4, 1.0, 2.0), cp + Vector3(0, 3.7, 0), TILE)
	Props.cyl(n, 0.9, 0.18, cp + Vector3(0, 2.2, 0.82), Color("8a7a66"), Vector3(90, 0, 0), 10)
	Props.box(n, Vector3(2.4, 0.6, 1.0), cp + Vector3(0, 0.3, 1.2), Color("bdb19a"))
	# mumcu ve ikona tezgâhları (güney kenarı): tezgâh, tente, mal
	for k in 4:
		var tp := Vector3(-sx * 0.5 + 8.0 + k * 9.0, 0, sz * 0.5 - 2.0)
		Props.box(n, Vector3(3.0, 0.9, 1.2), tp + Vector3(0, 0.45, 0), Color("8a6244"))
		Props.box(n, Vector3(3.4, 0.08, 2.2), tp + Vector3(0, 2.5, -0.3), [Color("b84a3a"), Color("e8d8a8"), Color("3a6a8a"), Color("c89a3a")][k], Vector3(-12, 0, 0))
		for sx2: float in [-1.6, 1.6]:
			Props.box(n, Vector3(0.1, 2.5, 0.1), tp + Vector3(sx2, 1.25, 0.5), Color("5a4030"))
			Props.box(n, Vector3(0.1, 2.3, 0.1), tp + Vector3(sx2, 1.15, -1.3), Color("5a4030"))
		for j in 5:
			if k % 2 == 0:
				Props.cyl(n, 0.05, 0.35, tp + Vector3(-1.2 + j * 0.6, 1.08, 0.0), Color("f2e6c0"), Vector3.ZERO, 5)
			else:
				Props.box(n, Vector3(0.4, 0.5, 0.05), tp + Vector3(-1.2 + j * 0.6, 1.15, 0.2), Color("c8a040"), Vector3(-15, 0, 0))
	# taş sekiler (kuzey kenarı)
	for k in 3:
		Props.box(n, Vector3(3.0, 0.45, 0.6), Vector3(-6.0 + k * 9.0, 0.22, -sz * 0.5 + 1.2), Color("d4c9b2"))
