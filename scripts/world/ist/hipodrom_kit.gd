class_name IstHipoKit
extends RefCounted
## Hipodrom parçasının ortak yardımcıları: katı kutu/silindir, MultiMesh, yıkık duvar, kubbe, kemer, ot, moloz.
## Her yer YEREL koordinattır (merkez tabanın ortası, zemin y = 0). Mimari renkler byz_city/landmarks1453 paletindendir.

const BRICK := Color("b46a4e")
const BRICK2 := Color("a85c44")
const STONE := Color("cdbd9e")
const STONE_D := Color("b3a283")
const LIGHT := Color("e2d6bc")
const MARBLE := Color("e8e2d4")
const LEAD := Color("7a8594")
const TILE := Color("a0503a")
const BRONZE := Color("8a6a3a")
const GOLD := Color("d8b040")
const DARK := Color("2a2228")
const WOOD := Color("6a4a2c")
const PORPHYRY := Color("7a3040")
const GRANITE := Color("c49a82")
const GRASS := Color("8aa05a")
const GRASS_D := Color("6f8a48")
const SOIL := Color("a58a62")
const SAND := Color("c9b48a")
const MOSS := Color("7c9250")


## Katı kutu (görünür + çarpışma). pos = kutunun merkezi.
static func sb(host: Node3D, size: Vector3, pos: Vector3, color: Color, pattern := "", rot := Vector3.ZERO) -> StaticBody3D:
	var b := Props.solid(host, size, pos, color, rot)
	if pattern != "":
		Props.set_pattern(b, color, pattern)
	return b


## Tabanı zeminde (y = 0) duran katı kutu; (cx, cz) taban merkezi.
static func ground_box(host: Node3D, w: float, h: float, d: float, cx: float, cz: float, color: Color, pattern := "", y0 := 0.0) -> StaticBody3D:
	return sb(host, Vector3(w, h, d), Vector3(cx, y0 + h * 0.5, cz), color, pattern)


## Yalnız görünür kutu (çarpışmasız ayrıntı: silme, kabartma, koyu kemer boşluğu).
static func vb(host: Node3D, size: Vector3, pos: Vector3, color: Color, rot := Vector3.ZERO, pattern := "") -> MeshInstance3D:
	var m := Props.box(host, size, pos, color, rot)
	if pattern != "":
		Props.set_pattern(m, color, pattern)
	return m


## Katı silindir (sütun, kule, kaide). Çarpışma ağın dışbükey kabuğu.
static func sc(host: Node3D, r: float, h: float, pos: Vector3, color: Color, segs := 10, top_r := -1.0, rot := Vector3.ZERO, shrink := 0.92) -> MeshInstance3D:
	var m := Props.cyl(host, r, h, pos, color, rot, segs, top_r)
	Props.make_solid(m, shrink)
	return m


## Katı yarım küre / kubbe (kubbe tabanı pos'ta).
static func dome(host: Node3D, r: float, h: float, pos: Vector3, color: Color, segs := 14) -> MeshInstance3D:
	var m := Props.ball(host, r, pos, color, Vector3(1.0, h / r, 1.0), segs)
	var hull := m.mesh.create_convex_shape(true, false)
	var pts := PackedVector3Array()
	for p in hull.points:
		if p.y >= -0.001:
			pts.append(m.transform * Vector3(p.x * 0.97, p.y, p.z * 0.97))
		else:
			pts.append(m.transform * Vector3(p.x * 0.97, 0.0, p.z * 0.97))
	var shape := ConvexPolygonShape3D.new()
	shape.points = pts
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = shape
	body.add_child(cs)
	host.add_child(body)
	return m


## Kubbenin tepesi pos'ta olacak biçimde: dilimli kurşun kubbe (kaburga çıtaları + kasnak penceresi + haç).
static func lead_dome(host: Node3D, r: float, h: float, base: Vector3, ribs := 12, drum_h := 0.0, drum_col := BRICK, win := true) -> void:
	var y := base.y
	if drum_h > 0.0:
		sc(host, r, drum_h, Vector3(base.x, y + drum_h * 0.5, base.z), drum_col, ribs, r * 0.98)
		if win:
			for i in ribs:
				var a := TAU * (i + 0.5) / ribs
				vb(host, Vector3(0.7, minf(drum_h * 0.6, 1.8), 0.14), Vector3(base.x + cos(a) * (r + 0.02), y + drum_h * 0.55, base.z + sin(a) * (r + 0.02)), DARK, Vector3(0, -rad_to_deg(a) + 90.0, 0))
		y += drum_h
		sc(host, r * 1.04, 0.25, Vector3(base.x, y + 0.12, base.z), STONE_D, ribs, r * 1.04)
		y += 0.25
	dome(host, r * 0.99, h, Vector3(base.x, y, base.z), LEAD, 14)
	for i in ribs:
		var ang := TAU * i / ribs
		var rad := Vector3(cos(ang), 0, sin(ang))
		var d := (-rad * r * 0.707 + Vector3.UP * h * 0.707).normalized()
		var rib := Props.box(host, Vector3(0.1, 0.42 * (r + h), 0.1), Vector3(base.x, y, base.z) + rad * r * 0.707 * 1.02 + Vector3.UP * h * 0.707 * 1.02, LEAD.darkened(0.25))
		rib.basis = Basis(Quaternion(Vector3.UP, d))
	# tepede küre ve haç
	vb(host, Vector3(0.12, 0.9, 0.12), Vector3(base.x, y + h + 0.5, base.z), GOLD)
	vb(host, Vector3(0.55, 0.1, 0.1), Vector3(base.x, y + h + 0.7, base.z), GOLD)


## Yıkık duvar parçası: tabanı 0'da, yüksekliği uçlara doğru düşen, üstü moloz/ot kaplı katı. a→b doğrusu üzerinde.
## Yıkık duvar (ÇEVRE-4; kalite notu 23): "basamak bloğu" değil. Sürekli alt gövde (katı) + üstte komşusuna yumuşak
## geçen, kırık (sivri/eğik) tepeli parçalar; uzun ve yüksek duvarda kör kemerler (tuğla kemer kaşı + koyu boşluk);
## seyrek yosun öbekleri ve yüzde sarmaşık lekeleri; dipte moloz yığını. chop: yükseklik çarpanı.
static func ruin_wall(host: Node3D, a: Vector2, b: Vector2, h: float, th: float, color: Color, rng: RandomNumberGenerator, pattern := "brick", y0 := 0.0, chop := 1.0) -> void:
	var len := a.distance_to(b)
	if len < 0.5:
		return
	var yaw := rad_to_deg(atan2(b.x - a.x, b.y - a.y))
	var u := (b - a) / len
	var nrm := Vector2(-u.y, u.x)
	var H := maxf(h * chop, 0.8)
	var hb := maxf(H * 0.42, 0.6)
	var mid := (a + b) * 0.5
	var base := sb(host, Vector3(th, hb, len + 0.02), Vector3(mid.x, y0 + hb * 0.5, mid.y), color.darkened(rng.randf() * 0.06), pattern, Vector3(0, yaw, 0))
	base.name = "RuinWall"
	# üst parçalar: yumuşak rastgele yürüyüş (komşu farkı ≤ %25 H), kırık tepe (prizma), ara ara gedik
	var n := maxi(1, int(len / 2.6))
	var cur := rng.randf_range(0.55, 1.0)
	for i in n:
		var t0 := float(i) / n
		var t1 := float(i + 1) / n
		cur = clampf(cur + rng.randf_range(-0.25, 0.25), 0.0, 1.0)
		if cur < 0.12:
			continue                      # gedik: yalnız alt gövde
		var m := a.lerp(b, (t0 + t1) * 0.5)
		var seg := len / n
		var hh := (H - hb) * cur
		if hh > 0.3:
			var bd := sb(host, Vector3(th * 0.96, hh, seg + 0.02), Vector3(m.x, y0 + hb + hh * 0.5, m.y), color.darkened(rng.randf() * 0.08), pattern, Vector3(0, yaw, 0))
			bd.name = "RuinWall"
		# kırık tepe: duvar boyunca sivri/eğik taş kırığı (görsel)
		var pk := rng.randf_range(0.4, 1.3) * minf(1.0, H * 0.3)
		var pr := Props.prism(host, Vector3(seg * rng.randf_range(0.6, 1.0), pk, th * 0.9), Vector3(m.x, y0 + hb + hh + pk * 0.5 - 0.02, m.y), color.darkened(0.05 + rng.randf() * 0.06), Vector3(0, yaw + 90.0, 0))
		if pattern != "":
			Props.set_pattern(pr, color, pattern)
		if rng.randf() < 0.35:
			vb(host, Vector3(th * 0.7, 0.16, seg * rng.randf_range(0.25, 0.5)), Vector3(m.x, y0 + hb + hh + 0.08, m.y) + Vector3(0, 0, 0), MOSS.darkened(0.25), Vector3(0, yaw, 0))
		if rng.randf() < 0.25 and hh + hb > 1.6:
			# sarmaşık lekesi (bir yüzde)
			var sd := 1.0 if rng.randf() < 0.5 else -1.0
			var ih := rng.randf_range(1.0, hh + hb - 0.3)
			vb(host, Vector3(0.06, ih, seg * rng.randf_range(0.3, 0.7)), Vector3(m.x + nrm.x * sd * (th * 0.5 + 0.03), y0 + hb + hh - ih * 0.5, m.y + nrm.y * sd * (th * 0.5 + 0.03)), Color("4a5e38"), Vector3(0, yaw, 0))
	# kör kemerler: yüksek ve uzun duvarda
	if H >= 2.8 and len >= 6.0:
		var ka := maxi(1, int(len / 5.0))
		var kw := minf(2.6, len / ka * 0.6)
		for j in ka:
			var c := a.lerp(b, (j + 0.5) / ka)
			for sd2: float in [-1.0, 1.0]:
				var off := nrm * sd2 * (th * 0.5 + 0.02)
				var ky := y0 + minf(H * 0.32, hb * 0.9)
				var kh := minf(H * 0.36, 2.6)
				vb(host, Vector3(0.05, kh, kw), Vector3(c.x + off.x, ky + kh * 0.5, c.y + off.y), DARK.lightened(0.08), Vector3(0, yaw, 0))
				Props.cyl(host, kw * 0.5, 0.05, Vector3(c.x + off.x, ky + kh, c.y + off.y), DARK.lightened(0.08), Vector3(0, yaw, 90), 10)
				Props.cyl(host, kw * 0.5 + 0.3, 0.04, Vector3(c.x + off.x * 0.98, ky + kh, c.y + off.y * 0.98), BRICK2.darkened(0.1), Vector3(0, yaw, 90), 10)
	# dipte moloz
	var mo := maxi(1, int(len / 3.0))
	for j in mo:
		var c2 := a.lerp(b, rng.randf()) + nrm * (th * 0.5 + rng.randf_range(0.2, 1.2)) * (1.0 if rng.randf() < 0.5 else -1.0)
		var s2 := rng.randf_range(0.4, 0.9)
		vb(host, Vector3(s2, s2 * 0.6, s2 * 0.8), Vector3(c2.x, y0 + s2 * 0.25, c2.y), STONE_D.darkened(rng.randf() * 0.1), Vector3(rng.randf() * 20.0, rng.randf() * 180.0, rng.randf() * 20.0))


## Yıkık kemer dizisi (serbest duran): ayaklar + yarım daire kemerler (yedi parçalı tuğla kemer taşları); yıkık
## açıklıklarda kemer yok (yalnız ayak kütüğü). a→b boyunca, açıklık ~4 m. Ayaklar katı, kemerler görsel.
static func kemer_dizisi(host: Node3D, a: Vector2, b: Vector2, h: float, color: Color, rng: RandomNumberGenerator, y0 := 0.0, yikik := 0.3) -> void:
	var len := a.distance_to(b)
	var n := maxi(1, int(len / 4.2))
	var sp := len / n
	var u := (b - a) / len
	var yaw := rad_to_deg(atan2(u.x, u.y))
	var pw := 1.1
	var ph: Array = []
	for i in n + 1:
		ph.append(h if rng.randf() > yikik * 0.6 else h * rng.randf_range(0.25, 0.6))
	for i in n + 1:
		var p := a + u * (sp * i)
		var hh: float = ph[i]
		var bd := sb(host, Vector3(1.2, hh, pw), Vector3(p.x, y0 + hh * 0.5, p.y), color.darkened(rng.randf() * 0.08), "brick", Vector3(0, yaw, 0))
		bd.name = "RuinWall"
		vb(host, Vector3(1.4, 0.25, pw + 0.2), Vector3(p.x, y0 + minf(hh, h) - 0.12, p.y), STONE, Vector3(0, yaw, 0))
	for i in n:
		if float(ph[i]) < h * 0.9 or float(ph[i + 1]) < h * 0.9 or rng.randf() < yikik * 0.5:
			continue
		var c := a + u * (sp * (i + 0.5))
		var r := (sp - pw) * 0.5
		var segs := 7
		for j in segs:
			var t := PI * (j + 0.5) / segs
			var off := cos(t) * r
			var up := sin(t) * r
			var q := c + u * off
			vb(host, Vector3(1.1, 0.55, r * PI / segs + 0.12), Vector3(q.x, y0 + h + up - 0.1, q.y), BRICK2.darkened(rng.randf() * 0.1), Vector3(-rad_to_deg(t + PI * 0.5), yaw, 0))
		# kemer üstü dolgu (spandrel) + yosun
		vb(host, Vector3(1.1, r * 0.55, sp - pw * 0.4), Vector3(c.x, y0 + h + r + r * 0.2, c.y), color.darkened(0.04), Vector3(0, yaw, 0))
		if rng.randf() < 0.6:
			vb(host, Vector3(0.9, 0.15, sp * 0.5), Vector3(c.x, y0 + h + r * 1.5, c.y), MOSS.darkened(0.25), Vector3(0, yaw, 0))


## MultiMesh: aynı ağın çok kopyası (mazgal, kiremit, ot demeti, moloz). xforms: Transform3D dizisi.
static func multi(host: Node3D, mesh: Mesh, xforms: Array, color: Color, cast_shadow := false) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = Props.mat(color, 0.0, false, "", false)
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	host.add_child(mmi)
	return mmi


static func box_mesh(size: Vector3) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = size
	return m


## Ot demetleri ve moloz taşları (MultiMesh, çarpışmasız, küçük): dikdörtgen alana saçılır.
static func scatter(host: Node3D, rect: Rect2, count: int, rng: RandomNumberGenerator, y := 0.0, kind := "ot") -> void:
	if count <= 0:
		return
	var xf: Array = []
	var mesh: Mesh
	var col: Color
	if kind == "ot":
		var pm := PrismMesh.new()
		pm.size = Vector3(0.22, 0.45, 0.22)
		mesh = pm
		col = GRASS_D
		for i in count:
			var p := Vector2(rect.position.x + rng.randf() * rect.size.x, rect.position.y + rng.randf() * rect.size.y)
			var s := rng.randf_range(0.7, 1.6)
			var t := Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s, s, s)), Vector3(p.x, y + 0.2 * s, p.y))
			xf.append(t)
	else:
		mesh = box_mesh(Vector3(0.5, 0.3, 0.4))
		col = STONE_D
		for i in count:
			var p2 := Vector2(rect.position.x + rng.randf() * rect.size.x, rect.position.y + rng.randf() * rect.size.y)
			var s2 := rng.randf_range(0.5, 1.8)
			var bs := Basis(Vector3.UP, rng.randf() * TAU) * Basis(Vector3.RIGHT, rng.randf_range(-0.2, 0.2))
			xf.append(Transform3D(bs.scaled(Vector3(s2, s2 * rng.randf_range(0.5, 1.0), s2)), Vector3(p2.x, y + 0.12 * s2, p2.y)))
	multi(host, mesh, xf, col)


## Kemerli cephe: düz kutu ayaklar + koyu boşluk + kemer üstü (düz lento) ile, dış duvara yapışık görsel ayrıntı.
## origin duvar yüzünün alt-orta noktası; dir yüzün bakış yönü (yatay birim vektör); span yüzün boyu.
static func arcade_face(host: Node3D, origin: Vector3, dir: Vector3, span: float, h: float, bay: float, pier: float, color: Color, storeys := 1) -> void:
	var tang := Vector3(-dir.z, 0, dir.x)
	var n := maxi(1, int(span / bay))
	var yaw := rad_to_deg(atan2(dir.x, dir.z))
	var sh := h / storeys
	for st in storeys:
		var y0 := origin.y + st * sh
		for i in n:
			var off := (i + 0.5 - n * 0.5) * (span / n)
			var c := origin + tang * off + dir * 0.02
			# koyu kemer boşluğu
			vb(host, Vector3(bay - pier, sh * 0.62, 0.06), Vector3(c.x, y0 + sh * 0.34, c.z), DARK, Vector3(0, yaw, 0))
			vb(host, Vector3(bay - pier, 0.18, 0.1), Vector3(c.x, y0 + sh * 0.68, c.z) + dir * 0.02, color.lightened(0.12), Vector3(0, yaw, 0))
		vb(host, Vector3(span, 0.22, 0.2), Vector3(origin.x, y0 + sh - 0.11, origin.z) + dir * 0.06, color.lightened(0.1), Vector3(0, yaw, 0))


## İki yüzlü beşik çatı (uzun eksen z boyunca): iki eğik KATI levha (yürünebilir, ~eğim), mahya silmesi, alın duvarları.
## y_eave saçak yüksekliği, rise mahya yüksekliği farkı. Çatı levhaları duvar tepesinin üstünde oturur.
static func gable_roof(host: Node3D, cx: float, cz: float, w: float, d: float, y_eave: float, rise: float, color: Color, wall_col: Color) -> void:
	var half := w * 0.5
	var slope := atan2(rise, half)
	var plen := sqrt(half * half + rise * rise) + 0.35
	for sx: float in [-1.0, 1.0]:
		var mx := cx + sx * half * 0.5
		var my := y_eave + rise * 0.5 + 0.1
		var b := sb(host, Vector3(plen, 0.2, d + 0.5), Vector3(mx, my, cz), color, "tiles", Vector3(0, 0, -sx * rad_to_deg(slope)))
		b.name = "Roof"
	vb(host, Vector3(0.4, 0.26, d + 0.6), Vector3(cx, y_eave + rise + 0.2, cz), color.darkened(0.18))
	# alın duvarı üçgeni (görsel): iki ucunda
	for ez: float in [-1.0, 1.0]:
		var pr := Props.prism(host, Vector3(w, rise, 0.4), Vector3(cx, y_eave + rise * 0.5, cz + ez * (d * 0.5 - 0.02)), wall_col)
		Props.set_pattern(pr, wall_col, "brick")


## Tuğla/taş dolgulu kemerli pencere dizisi (bir cephede, görsel): origin cephe orta-alt, dir dışa yön.
static func windows(host: Node3D, origin: Vector3, dir: Vector3, span: float, y: float, count: int, w := 0.9, h := 1.6) -> void:
	var tang := Vector3(-dir.z, 0, dir.x)
	var yaw := rad_to_deg(atan2(dir.x, dir.z))
	for i in count:
		var off := (i + 0.5 - count * 0.5) * (span / count)
		var c := origin + tang * off + dir * 0.03
		vb(host, Vector3(w, h, 0.06), Vector3(c.x, y + h * 0.5, c.z), DARK, Vector3(0, yaw, 0))
		vb(host, Vector3(w + 0.2, 0.14, 0.09), Vector3(c.x, y + h + 0.05, c.z) + dir * 0.01, LIGHT, Vector3(0, yaw, 0))


## Mozaik/döşeme parçası: yerden 2 cm yukarıda renkli küçük levhalar (görsel; yalnız yürünen zemin üstüne)
static func mosaic(host: Node3D, center: Vector3, size: Vector2, rng: RandomNumberGenerator, cells := 7) -> void:
	var cols := [Color("a89470"), Color("6a4a44"), Color("cfc4ae"), Color("5a6670"), Color("8a7458"), Color("6e7a5e")]   # aşınmış, toprak altından (ÇEVRE-4)
	var cw := size.x / cells
	var ch := size.y / cells
	for i in cells:
		for j in cells:
			if rng.randf() < 0.4:
				continue            # eksik parçalar (toprak/ot altında)
			var c: Color = cols[(i + j * 2 + int(rng.randf() * 2)) % cols.size()]
			if (i + j) % 2 == 0:
				c = cols[0] if (i / 2 + j / 2) % 2 == 0 else cols[2]
			vb(host, Vector3(cw * 0.94, 0.02, ch * 0.94), Vector3(center.x + (i + 0.5 - cells * 0.5) * cw, center.y + 0.02, center.z + (j + 0.5 - cells * 0.5) * ch), c)
