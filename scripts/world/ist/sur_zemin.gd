extends RefCounted
## SUR-4: sur dibi arazisi (madde 3; sahibinin "o yeşil alan yükseltileri ne öyle" sözü).
##   set_(): hendeğin dış yakasındaki toprak set (glacis): eskiden 14 m'lik düz yeşil KUTU (surlar.gd _build_moat), dilimin
##           tabanı yamaçta yerden yüksekte kalınca keskin köşeli parlak yeşil prizma olarak görünüyordu. Şimdi sur boyunca
##           4 m'lik bölmelerle düzensiz tepeli, dışa doğru 1:3 eğimle araziye inen çiğnenmiş toprak + solgun ot yaması.
##   ates_alani(): kara surunun dışında hendekten 60 m'lik "ateş alanı" (ORDUGÂH-4 ile sınır: ilk 60 m bu dosyanın):
##           araziyi izleyen örtü (çiğnenmiş toprak, solgun ot, yanık), top güllesi çukurları, taş gülle, kırık merdiven,
##           ok, kalkan, kazık parçaları (MultiMesh). Ağaç yok.
## catalog() yok; class_name yok.

const TOPRAK := Color("66523c")
const TOPRAK2 := Color("554534")
const OT := Color("5e6a3a")
const YANIK := Color("4e4438")
const CAMUR := Color("6a5a44")
const KULE := preload("res://scripts/world/ist/sur_kule.gd")


static func _hash(a: int, b: int) -> float:
	var h := (a * 73856093) ^ (b * 19349663)
	h = (h ^ (h >> 13)) * 1274126177
	return float(h & 0xffff) / 65535.0


## Hendek dış yakası toprak seti. Yerel çerçeve (surlar.gd): sur boyunca x, dış +z. z0: setin başladığı (karşı yaka
## duvarının dış yüzü), y = 0 zemin. Katı (lod 0: çarpışmalı). tohum: dilim tohumu (komşu dilimler ayrı desen).
## Dünya dönüşümü (ağaçta olmayan uzak katman kurulumunda IstSehir verir): set eteği araziye iner
static var xf_dunya := Transform3D()
static var xf_var := false

static func set_(p: Node3D, x0: float, x1: float, z0: float, lod: int, tohum: int, pencere := Vector2(-1e9, 1e9)) -> void:
	var adim := 4.0 if lod == 0 else 12.0
	var n := maxi(1, int(ceil((x1 - x0) / adim)))
	# kesit: (z, y) — yaka düzü, alçak tümsek, dışa 1:2,5 eğim; etek araziye iner (dilim tabanı yamaçta yerden yüksek
	# kaldığında altı açık kalmasın). Dünya dönüşümü yoksa sabit 28 m'lik etek.
	var xf := Transform3D()
	var arazi := false
	if p.is_inside_tree():
		xf = p.global_transform
		arazi = true
	elif xf_var:
		xf = xf_dunya
		arazi = true
	var prof := [[0.0, 0.0], [2.5, 0.35], [6.0, 0.55], [10.0, 0.1], [18.0, -2.6], [28.0, -6.5]]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cols := []
	var pts := []
	for i in n + 1:
		var x := x0 + (x1 - x0) * i / n
		var row := []
		var crow := []
		var pr := prof
		if arazi:
			var zend := 90.0
			var yend := 0.1 - (90.0 - 10.0) / 2.5
			var zz := 12.0
			while zz <= 90.0:
				var wq := xf * Vector3(x, 0.0, z0 + zz)
				var tt := IstGeo.h(wq.x, wq.z) - wq.y - 0.45
				var ys := 0.1 - (zz - 10.0) / 2.5
				if ys <= tt:
					zend = zz
					yend = maxf(tt, ys - 1.0)
					break
				zz += 3.0
			pr = [[0.0, 0.0], [2.5, 0.35], [6.0, 0.55], [10.0, 0.1], [lerpf(10.0, zend, 0.5), lerpf(0.1, yend, 0.5) - 0.3], [zend + 3.0, yend - 0.8]]
		for j in pr.size():
			var hz := _hash(tohum * 31 + i, j)
			var y: float = pr[j][1]
			if j >= 1 and j <= 3:
				y += (hz - 0.4) * 0.7
			var z: float = z0 + pr[j][0] + (hz - 0.5) * (2.0 if j >= 3 else 0.0)
			row.append(Vector3(x, y, z))
			var t := _hash(tohum + i * 7, j * 13)
			var c := TOPRAK.lerp(OT, clampf(t * 1.3 - 0.2, 0.0, 1.0) * (0.8 if j >= 2 else 0.3))
			if t > 0.85:
				c = c.lerp(TOPRAK2, 0.6)
			crow.append(c)
		pts.append(row)
		cols.append(crow)
	# SUR-5: kesit sıklaştırılır (Chaikin) ve köşe normalleri komşulardan (düz renkli üçgen yüzler okunuyordu: kara_05_yer60)
	for k in (2 if lod == 0 else 0):
		for i in pts.size():
			var r0: Array = pts[i]
			var c0: Array = cols[i]
			var r1: Array = [r0[0]]
			var c1: Array = [c0[0]]
			for j in r0.size() - 1:
				var a3: Vector3 = r0[j]
				var b3: Vector3 = r0[j + 1]
				r1.append(a3.lerp(b3, 0.25))
				r1.append(a3.lerp(b3, 0.75))
				c1.append((c0[j] as Color).lerp(c0[j + 1], 0.25))
				c1.append((c0[j] as Color).lerp(c0[j + 1], 0.75))
			r1.append(r0[r0.size() - 1])
			c1.append(c0[c0.size() - 1])
			pts[i] = r1
			cols[i] = c1
	var m := (pts[0] as Array).size()
	var nrm := _izgara_normal(pts)
	var any := false
	for i in n:
		var xm := (float(pts[i][0].x) + float(pts[i + 1][0].x)) * 0.5
		if xm < pencere.x or xm >= pencere.y:
			continue
		any = true
		for j in m - 1:
			_ucgen_n(st, [pts[i][j], pts[i][j + 1], pts[i + 1][j], pts[i + 1][j], pts[i][j + 1], pts[i + 1][j + 1]],
				[cols[i][j], cols[i][j + 1], cols[i + 1][j], cols[i + 1][j], cols[i][j + 1], cols[i + 1][j + 1]],
				[nrm[i][j], nrm[i][j + 1], nrm[i + 1][j], nrm[i + 1][j], nrm[i][j + 1], nrm[i + 1][j + 1]])
	if not any:
		return
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = _mat()
	mi.name = "ToprakSet"
	p.add_child(mi)
	if lod == 0:
		var body := StaticBody3D.new()
		body.name = "ToprakSetGovde"
		var cs := CollisionShape3D.new()
		cs.shape = mesh.create_trimesh_shape()
		body.add_child(cs)
		p.add_child(body)


## Yukarı bakan üçgen (Godot ön yüzü saat yönünde: yukarıdan bakınca (b−a)×(c−a) aşağı bakmalı)
static func _ucgen(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, ca: Color, cb: Color, cc: Color) -> void:
	var nr := (b - a).cross(c - a)
	if nr.y > 0.0:
		var t := b
		b = c
		c = t
		var tc := cb
		cb = cc
		cc = tc
	else:
		nr = -nr
	nr = nr.normalized()
	st.set_color(ca)
	st.set_normal(nr)
	st.add_vertex(a)
	st.set_color(cb)
	st.set_normal(nr)
	st.add_vertex(b)
	st.set_color(cc)
	st.set_normal(nr)
	st.add_vertex(c)


static var _m: ShaderMaterial

## ZEMİN (scripts/level/zemin.gd): ateş alanı ve set ortak zemin malzemesiyle (köşe rengi ipucu: toprak, ot, yanık,
## çamur); yöre "kusatma": çiğnenmiş toprak öbekleri, solgun ot, çakıl, çatlak; bulanık tek doku yerine üç ölçek.
static func _mat() -> Material:
	if _m == null:
		_m = load("res://scripts/level/zemin.gd").kopya("kusatma")
		if IstSehir.v2:
			_m.shader = load("res://scripts/world/ist/zemin_v2.gdshader")     # TUR-6: v2 zemin dili
		_m.set_shader_parameter("su_y", -10000.0)
		# TUR-7: dik yüz (rampa omzu, set şevi) "yamaç kayası" paleti açık gri-bej: güneşte beyaz üçgen okunuyordu.
		# Sur kuşağında dik toprak = koyu, kuru döküm toprak
		_m.set_shader_parameter("c_kaya", Color(0.43, 0.36, 0.28))
	return _m


## Hendek dibi: kuru çamur üstünde su birikintileri ve saz öbekleri (lod 0). Yerel: x0..x1, z0..z1 (dip), y = dip.
static func hendek_dibi(p: Node3D, x0: float, x1: float, z0: float, z1: float, y: float, tohum: int, pencere := Vector2(-1e9, 1e9)) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum * 17 + 3
	var su: Array = []
	var saz: Array = []
	var x := x0 + rng.randf_range(2.0, 8.0)
	while x < x1 - 3.0:
		var l := rng.randf_range(3.0, 11.0)
		var w := rng.randf_range(2.0, (z1 - z0) * 0.55)
		var zc := rng.randf_range(z0 + w * 0.5 + 1.0, z1 - w * 0.5 - 1.0)
		var xc := x + l * 0.5
		# TUR-6 (v2): kuru hendek — birikinti seyrek (üçte bir), çamurlu koyu; saz öbekleri kalır
		var kuru := IstSehir.v2 and rng.randf() > 0.33
		if xc >= pencere.x and xc < pencere.y and xc + l * 0.5 < x1 - 2.0 and not kuru:
			su.append(Transform3D(Basis.from_euler(Vector3(0, rng.randf_range(-0.2, 0.2), 0)).scaled(Vector3(l, 0.04, w)), Vector3(xc, y + 0.03, zc)))
			for k in rng.randi_range(2, 6):
				var a := rng.randf() * TAU
				var r := Vector2(l * 0.5, w * 0.5) * rng.randf_range(0.8, 1.1)
				var sp := Vector3(xc + cos(a) * r.x, y, zc + sin(a) * r.y)
				for m in rng.randi_range(3, 6):
					var h := rng.randf_range(0.6, 1.4)
					var q := sp + Vector3(rng.randf_range(-0.5, 0.5), h * 0.5, rng.randf_range(-0.5, 0.5))
					saz.append(Transform3D(Basis.from_euler(Vector3(rng.randf_range(-0.25, 0.25), rng.randf() * TAU, rng.randf_range(-0.25, 0.25))).scaled(Vector3(0.05, h, 0.05)), q))
		x += l + rng.randf_range(4.0, 16.0)
	if su.size() > 0:
		Scenery.scatter(p, _disk(), su, [], Props.mat(Color("4a4a3e") if not IstSehir.v2 else Color("4e4a3c"), 0.0, false, "", false))
	if saz.size() > 0:
		Scenery.scatter(p, _saz(), saz, [], Props.mat(Color("7a7a3c"), 0.0, false, "", false))


# ---------------------------------------------------------------- ateş alanı (kara surunun dışı, hendekten 60 m)

const ATES_EN := 60.0
const ATES_ADIM := 5.0

## Kara suru hattı boyunca (dünya x,z çoklu çizgi, dış yön fonksiyonu) araziyi izleyen örtü ve döküntü.
## bas: hattan dış yöne başlangıç uzaklığı (hendek dış yakası + set), en: genişlik. Dönen: kurulan düğüm.
static func ates_alani(parent: Node3D, pl: PackedVector2Array, dis: Callable, bas: float, kapilar: Array) -> Node3D:
	var root := Node3D.new()
	root.name = "SurAtesAlani"
	parent.add_child(root)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cukur: Array = []
	var cukur_c: Array = []
	var tas: Array = []
	var cubuk: Array = []
	var kalkan: Array = []
	var merdiven: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var nz := int(ATES_EN / ATES_ADIM) + 1
	var L := 0.0
	for i in pl.size() - 1:
		L += pl[i].distance_to(pl[i + 1])
	var ns := int(L / ATES_ADIM)
	var prev: Array = []
	var prev_c: Array = []
	for si in ns + 1:
		var sv := L * si / ns
		var q := _at(pl, sv)
		var p: Vector2 = q["p"]
		var d: Vector2 = q["d"]
		var o: Vector2 = dis.call(d, p)
		var row: Array = []
		var crow: Array = []
		for j in nz:
			var dz := bas + j * ATES_ADIM + (_hash(si, j) - 0.5) * 1.5
			var w := p + o * dz
			var y := IstGeo.h(w.x, w.y) + 0.12 + 0.04 * j      # (OTURTMA: örtü ağı kurulmuyor; rengi arazinin köşe rengi)
			row.append(Vector3(w.x, y, w.y))
			var r := IstGeo.real(w.x, w.y)
			var g := sin(r.x * 0.031 + r.y * 0.017) * sin(r.x * 0.013 - r.y * 0.029)
			var t := _hash(si * 3 + 1, j * 5 + 2)
			var c := TOPRAK.lerp(OT, clampf(0.2 + g * 0.9 + float(j) / nz * 0.45 + (t - 0.5) * 0.6, 0.0, 0.9))
			# sur boyunca çiğnenmiş yol (ikmal/devriye izi): hendekten ~25 m'de koyu toprak şerit
			if j == 4 or j == 5:
				c = c.lerp(TOPRAK2, 0.55)
			if t > 0.9:
				c = c.lerp(YANIK, 0.55)
			elif t < 0.12:
				c = c.lerp(TOPRAK2, 0.5)
			crow.append(c)
		if prev.size() > 0:
			for j in nz - 1:
				var a: Vector3 = prev[j]
				var b: Vector3 = row[j]
				var c3: Vector3 = row[j + 1]
				var e: Vector3 = prev[j + 1]
				_ucgen(st, a, b, e, prev_c[j], crow[j], prev_c[j + 1])
				_ucgen(st, b, c3, e, crow[j], crow[j + 1], prev_c[j + 1])
		prev = row
		prev_c = crow
		# döküntü (kapı önleri hariç)
		var kapida := false
		for kp: Vector2 in kapilar:
			if kp.distance_to(p) < 30.0:
				kapida = true
		if kapida:
			continue
		if rng.randf() < 0.75:
			var dz2 := bas + rng.randf_range(2.0, ATES_EN - 4.0)
			var w2 := p + o * dz2 + d * rng.randf_range(-2.0, 2.0)
			var y2 := IstGeo.h(w2.x, w2.y) + 0.03
			var rr := rng.randf_range(1.2, 3.0)
			# TUR-7: hat çizgisi dilimden sapınca döküntü hendeğin/setin içinde arazi yüksekliğinde havada kalıyordu
			# (k09: hendek duvarı önünde uçan beyaz gülleler): sur kuşağında (hendek dış kıyısı + 5 m) döküntü yok
			if load("res://scripts/world/ist/sur_oturtma.gd").kusakta(w2.x, w2.y, 12.0, 5.0 + rr):
				continue
			cukur.append(Transform3D(Basis.from_euler(Vector3(0, rng.randf() * TAU, 0)).scaled(Vector3(rr * 2.0, 0.06, rr * 1.7)), Vector3(w2.x, y2, w2.y)))
			cukur_c.append(Transform3D(Basis.from_euler(Vector3(0, rng.randf() * TAU, 0)).scaled(Vector3(rr * 2.6, 0.35, rr * 2.3)), Vector3(w2.x, y2 - 0.12, w2.y)))
			if rng.randf() < 0.5:
				var gp := w2 + Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
				var gr := rng.randf_range(0.25, 0.45)
				tas.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * gr * 2.0), Vector3(gp.x, IstGeo.h(gp.x, gp.y) + gr * 0.7, gp.y)))
		for k in rng.randi_range(0, 3):
			var dz3 := bas + rng.randf_range(0.0, ATES_EN * 0.6)
			var w3 := p + o * dz3 + d * rng.randf_range(-2.5, 2.5)
			var y3 := IstGeo.h(w3.x, w3.y) + 0.1
			if load("res://scripts/world/ist/sur_oturtma.gd").kusakta(w3.x, w3.y, 12.0, 8.0):
				continue
			var kind := rng.randf()
			var yaw := rng.randf() * TAU
			if kind < 0.5:
				# ok/kazık: yere saplı eğik çubuk
				var h := rng.randf_range(0.7, 1.6)
				cubuk.append(Transform3D(Basis.from_euler(Vector3(rng.randf_range(0.3, 0.7), yaw, 0)).scaled(Vector3(0.04, h, 0.04)), Vector3(w3.x, y3 + h * 0.35, w3.y)))
			elif kind < 0.75:
				kalkan.append(Transform3D(Basis.from_euler(Vector3(rng.randf_range(-0.2, 0.2), yaw, PI * 0.5 + rng.randf_range(-0.15, 0.15))).scaled(Vector3(0.9, 0.08, 0.9)), Vector3(w3.x, y3 + 0.05, w3.y)))
			elif kind < 0.9:
				# kırık merdiven: iki ray + basamaklar (yerde yatık)
				var bb := Basis.from_euler(Vector3(0, yaw, 0))
				var ln := rng.randf_range(2.5, 5.0)
				for sd: float in [-0.3, 0.3]:
					merdiven.append(Transform3D(bb.scaled(Vector3(0.09, 0.09, ln)), Vector3(w3.x, y3 + 0.05, w3.y) + bb * Vector3(sd, 0, 0)))
				for r2 in int(ln / 0.45):
					if rng.randf() < 0.75:
						merdiven.append(Transform3D(bb.scaled(Vector3(0.6, 0.06, 0.07)), Vector3(w3.x, y3 + 0.09, w3.y) + bb * Vector3(0, 0, -ln * 0.5 + 0.3 + r2 * 0.45)))
			else:
				var gr2 := rng.randf_range(0.3, 0.5)
				tas.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * gr2 * 2.0), Vector3(w3.x, y3 + gr2 * 0.6, w3.y)))
	# OTURTMA: arazinin 0,12–0,6 m üstünde yüzen ikinci zemin ağı (AtesAlaniOrtu) KALKTI: sur dışında "ayrı iki model"
	# görünümünün ve büyük düz renkli üçgenlerin kaynağıydı. Ateş alanının rengi artık arazinin köşe rengi (sur_oturtma.gd
	# _ates_renk: çiğnenmiş toprak, ot lekeleri, devriye izi); döküntü araziye oturur.
	st.clear()
	var mm: Array = []
	if cukur_c.size() > 0 and IstSehir.v2:
		# TUR-6: top çukuru düz koyu DİSK değil: kabarık kenarlı sığ çanak (zemin malzemesi; dibi yanık toprak, kenarı
		# dışarı savrulmuş açık toprak, dış eteği araziye iner). Ölçek: disk örneğinin yarıçapı.
		var cx: Array = []
		for t: Transform3D in cukur:
			var sc := t.basis.get_scale()
			cx.append(Transform3D(t.basis.orthonormalized().scaled(Vector3(sc.x * 0.62, 1.0, sc.z * 0.62)), t.origin - Vector3(0, 0.03, 0)))
		mm.append(Scenery.scatter(root, _cukur_ag(), cx, [], _mat()))
	elif cukur_c.size() > 0:
		mm.append(Scenery.scatter(root, _kure(), cukur_c, [], Props.mat(TOPRAK2.darkened(0.1), 0.0, false, "", false)))
		mm.append(Scenery.scatter(root, _disk(), cukur, [], Props.mat(YANIK.darkened(0.25), 0.0, false, "", false)))
	if tas.size() > 0:
		mm.append(Scenery.scatter(root, _kure(), tas, [], Props.mat(Color("8a806e"), 0.0, false, "", false)))      # TUR-7: taş gülle koyu kireçtaşı (güneşte beyaz benek değil)
	if cubuk.size() > 0:
		# TUR-6 (v2): kazık/ok yuvarlak: kutu değil, ince silindir
		mm.append(Scenery.scatter(root, _cubuk_ag() if IstSehir.v2 else Scenery._boxm(Vector3.ONE), cubuk, [], Props.mat(Color("6a5434"), 0.0, false, "", false)))
	if kalkan.size() > 0:
		mm.append(Scenery.scatter(root, _disk(), kalkan, [], Props.mat(Color("7a4a30"), 0.0, false, "", false)))
	if merdiven.size() > 0:
		mm.append(Scenery.scatter(root, Scenery._boxm(Vector3.ONE), merdiven, [], Props.mat(Color("7a6040"), 0.0, false, "", false)))
	for m in mm:
		if m is GeometryInstance3D:
			(m as GeometryInstance3D).visibility_range_end = 420.0
			(m as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.set_meta("say", {"cukur": cukur.size(), "tas": tas.size(), "cubuk": cubuk.size(), "kalkan": kalkan.size(), "merdiven": merdiven.size()})
	return root


static var _km: Mesh
static var _dm: Mesh
static var _cm: ArrayMesh
static var _cbm: Mesh

static func _cubuk_ag() -> Mesh:
	if _cbm == null:
		var c := CylinderMesh.new()
		c.top_radius = 0.4
		c.bottom_radius = 0.5
		c.height = 1.0
		c.radial_segments = 6
		c.rings = 1
		_cbm = c
	return _cbm


## TUR-6: birim top çukuru (yarıçap 1 = kenar tepesi; dış etek 1,45'e kadar araziye iner). Köşe rengi zemin ipucu, alfa
## çıplaklık (zemin_v2): dip yanık koyu toprak, kenar savrulmuş açık toprak.
static func _cukur_ag() -> ArrayMesh:
	if _cm != null:
		return _cm
	var halka := [[0.0, -0.22, Color("4e4438")], [0.35, -0.2, Color("54493a")], [0.7, -0.08, Color("6a5a44")],
		[1.0, 0.24, Color("8a7458")], [1.2, 0.12, Color("806b50")], [1.45, -0.06, Color("7a6650")]]
	var n := 14
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rows: Array = []
	for h: Array in halka:
		var r: Array = []
		for i in n:
			var a := TAU * i / n
			var jit := 1.0 + 0.08 * sin(a * 3.0 + 1.3) + 0.05 * sin(a * 5.0)
			r.append(Vector3(cos(a) * float(h[0]) * jit, float(h[1]) * (1.0 + 0.15 * sin(a * 2.0)), sin(a) * float(h[0]) * jit))
		rows.append(r)
	for k in halka.size() - 1:
		var c0: Color = halka[k][2]
		var c1: Color = halka[k + 1][2]
		c0.a = 0.05
		c1.a = 0.05
		for i in n:
			var j := (i + 1) % n
			var a0: Vector3 = rows[k][i]
			var a1: Vector3 = rows[k][j]
			var b0: Vector3 = rows[k + 1][i]
			var b1: Vector3 = rows[k + 1][j]
			for e: Array in [[a0, c0], [b0, c1], [b1, c1], [a0, c0], [b1, c1], [a1, c0]]:
				st.set_color(e[1])
				st.add_vertex(e[0])
	st.generate_normals()
	_cm = st.commit()
	return _cm

static func _kure() -> Mesh:
	if _km == null:
		var s := SphereMesh.new()
		s.radius = 0.5
		s.height = 1.0
		s.radial_segments = 8
		s.rings = 4
		_km = s
	return _km


static func _disk() -> Mesh:
	if _dm == null:
		var c := CylinderMesh.new()
		c.top_radius = 0.5
		c.bottom_radius = 0.5
		c.height = 1.0
		c.radial_segments = 10
		c.rings = 1
		_dm = c
	return _dm


static func _at(pl: PackedVector2Array, sv: float) -> Dictionary:
	var acc := 0.0
	for i in pl.size() - 1:
		var l := pl[i].distance_to(pl[i + 1])
		if acc + l >= sv or i == pl.size() - 2:
			var d := (pl[i + 1] - pl[i]) / maxf(l, 0.001)
			return {"p": pl[i] + d * clampf(sv - acc, 0.0, l), "d": d}
		acc += l
	return {"p": pl[0], "d": Vector2.RIGHT}

## Izgara (pts[i][j]: i sur boyu, j kesit) köşe normalleri: komşu farklarından, yukarı bakan
static func _izgara_normal(pts: Array) -> Array:
	var out: Array = []
	var n := pts.size()
	for i in n:
		var row: Array = pts[i]
		var m := row.size()
		var nr: Array = []
		for j in m:
			var a: Vector3 = pts[mini(i + 1, n - 1)][j]
			var b: Vector3 = pts[maxi(i - 1, 0)][j]
			var c: Vector3 = row[mini(j + 1, m - 1)]
			var d: Vector3 = row[maxi(j - 1, 0)]
			var v := (a - b).cross(c - d)
			if v.y < 0.0:
				v = -v
			nr.append(v.normalized() if v.length() > 1e-6 else Vector3.UP)
		out.append(nr)
	return out


## Köşe normalli üçgen dizisi (3'erli); sarım yukarı bakan yüze göre (Godot ön yüzü saat yönü)
static func _ucgen_n(st: SurfaceTool, v: Array, c: Array, nn: Array) -> void:
	for t in range(0, v.size(), 3):
		var a: Vector3 = v[t]
		var b: Vector3 = v[t + 1]
		var cc: Vector3 = v[t + 2]
		var ord := [0, 1, 2]
		var avg: Vector3 = (nn[t] as Vector3) + (nn[t + 1] as Vector3) + (nn[t + 2] as Vector3)
		if (b - a).cross(cc - a).dot(avg) > 0.0:
			ord = [0, 2, 1]
		for k: int in ord:
			st.set_color(c[t + k])
			st.set_normal(nn[t + k])
			st.add_vertex(v[t + k])


## SUR-5 (C): hendek kesiti — bıçak kenarlı kutu çukur yerine tek ağ: iki yanda taş kaplama (hafif şevli, üst kenarı
## düzensiz; yer yer YIKILMIŞ kaplama ve toprak kayması), dipte yuvarlanmış köşeler ve düzensiz çamur tabanı (orta biraz
## çukur). Yerel: x0..x1 boyunca, z0 (iç yaka duvarı) … z1 (karşı yaka), dip y = -md. Çarpışma surlar.gd'deki kutular.
## Dönen: [taş ağı (ashlar; sur taşı gölgelendiricisine çevrilir), toprak ağı]
static func hendek_kesit(p: Node3D, x0: float, x1: float, z0: float, z1: float, md: float, lod: int, tohum: int, pencere := Vector2(-1e9, 1e9)) -> void:
	var adim := 2.5 if lod == 0 else (8.0 if lod == 1 else 40.0)
	var n := maxi(1, int(ceil((x1 - x0) / adim)))
	var W := z1 - z0
	# kesit (z, y): taş iç yaka 0 → 1,1 (şev), dip köşesi yuvarlak, taban, karşı yaka simetrik
	# OTURTMA: iki yakada 0,45 m'lik harpuşta (arazi düzeyinin 8–13 cm üstü; arazi ona yaslanır, kırpılmış arazi kenarı
	# tam harpuştanın dış ucunda biter), sonra taş örgü yüz, yuvarlak dip köşesi, çamur taban
	var kes := [[0.0, 0.08], [0.45, 0.08], [0.6, -0.2], [1.0, -md * 0.5], [1.5, -md + 0.9], [2.05, -md + 0.32], [3.0, -md + 0.08],
		[W * 0.5, -md - 0.12], [W - 3.0, -md + 0.06], [W - 2.05, -md + 0.3], [W - 1.5, -md + 0.9], [W - 1.0, -md * 0.5],
		[W - 0.6, -0.2], [W - 0.45, 0.08], [W, 0.08]]
	var tas_j := {0: true, 1: true, 2: true, 3: true, 10: true, 11: true, 12: true, 13: true}       # j..j+1 bandı taş kaplama
	# TUR-6: v2'de harpuşta (j 0 ve 13 bandı) ayrı kesme taş bloklarıyla kurulur (harpuşta_kur); bant altta toprak yatağı.
	# Düz 0,45 m'lik yatay şerit sur gölgelendiricisinin 0,9 m'lik döşeme ızgarasıyla "tahta kalas" okunuyordu.
	var v2 := IstSehir.v2
	if v2:
		tas_j.erase(0)
		tas_j.erase(13)
	var rows: Array = []
	var crow: Array = []
	var kay: Array = []          # bu x'te karşı yaka kaymış mı (0..1)
	for i in n + 1:
		var x := x0 + (x1 - x0) * float(i) / n
		var r: Array = []
		var cr: Array = []
		# toprak kayması: ~45 m'de bir 6–10 m'lik kesimde dış yaka kaplaması yıkık, toprak yamaçtan kaymış
		var kk := 0.0
		var ph := fposmod(x * 0.023 + float(tohum % 97) * 0.13, 1.0)
		if ph < 0.18:
			kk = sin(ph / 0.18 * PI)
		kay.append(kk)
		for j in kes.size():
			var z: float = z0 + float(kes[j][0])
			var y: float = kes[j][1]
			var hz := _hash(tohum * 7 + i, j * 3 + 1)
			if j >= 5 and j <= 9:
				y += (hz - 0.5) * 0.22
			if j <= 1 or j >= kes.size() - 2:
				y += hz * 0.05                           # harpuşta: hep arazinin üstünde, hafif düzensiz
			if kk > 0.0 and j >= 9 and j <= kes.size() - 3:
				# kayan toprak: karşı yaka eğimi yatıklaşır (1:1,6), dibe yayılır
				var zt := float(kes[j][0])
				var t := clampf((zt - (W - 6.0)) / 6.0, 0.0, 1.0)
				y = lerpf(y, lerpf(-md + 0.3, 0.0, t), kk)
				z = lerpf(z, z0 + lerpf(W - 6.0, W, t), kk * 0.5)
			r.append(Vector3(x, y, z))
			var col := CAMUR.lerp(TOPRAK2, hz * 0.6)
			if j >= 6 and j <= 8 and hz > 0.7:
				col = col.lerp(Color("4a4a3c"), 0.5)        # ıslak çamur
			if v2 and j >= 4 and j <= 10:
				# TUR-6: kuru hendek dibi: açık kuru toprak, yer yer ot/saz öbeği (yeşil ipucu), alçak yerde nemli koyu leke
				var hb := _hash(tohum * 13 + i / 3, j * 7 + 2)
				col = Color("8a7154").lerp(Color("9c8662"), hz)
				col.a = 0.35
				if hb > 0.62:
					col = Color("6e7a44").lerp(Color("7f8550"), hz)
					col.a = 1.0
				elif hb < 0.12:
					col = Color("5f4f3c")
			if kk > 0.3 and j >= 9:
				col = TOPRAK.lerp(OT, hz * 0.3)
			cr.append(col)
		rows.append(r)
		crow.append(cr)
	var nrm := _izgara_normal(rows)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tst := SurfaceTool.new()
	tst.begin(Mesh.PRIMITIVE_TRIANGLES)
	var any := false
	var anyt := false
	for i in n:
		var xm := (float(rows[i][0].x) + float(rows[i + 1][0].x)) * 0.5
		if xm < pencere.x or xm >= pencere.y:
			continue
		for j in kes.size() - 1:
			var vv := [rows[i][j], rows[i][j + 1], rows[i + 1][j], rows[i + 1][j], rows[i][j + 1], rows[i + 1][j + 1]]
			var nv := [nrm[i][j], nrm[i][j + 1], nrm[i + 1][j], nrm[i + 1][j], nrm[i][j + 1], nrm[i + 1][j + 1]]
			var tas := tas_j.has(j) and not (j >= 9 and j <= 12 and (float(kay[i]) > 0.25 or float(kay[i + 1]) > 0.25))
			if tas:
				# taş kaplama: yüz normali (düz duvar), beyaz köşe rengi; onarım/eksik yerler koyu
				var hh := _hash(tohum + i * 5, j)
				var cc := Color.WHITE if hh > 0.12 else Color(0.7, 0.68, 0.64)
				var ccs := [cc, cc, cc, cc, cc, cc]
				if v2:
					# TUR-7: örgü yüzü tek düz levha / pano değil: ton KÖŞE başına (yumuşak geçiş), yer yer koyu akıntı izi
					# (yukarıdan aşağı, dibe doğru açılan), dibe doğru yosunlu-koyu (hendek duvarı surdan koyu okunur)
					var vi := [[i, j], [i, j + 1], [i + 1, j], [i + 1, j], [i, j + 1], [i + 1, j + 1]]
					for q in 6:
						var ii: int = vi[q][0]
						var vy: float = (vv[q] as Vector3).y
						var dd := clampf(-vy / md, 0.0, 1.0)
						var s := _hash(tohum * 5 + ii, 77)
						var ak := 1.0 if _hash(tohum * 3 + ii, 91) > 0.8 else 0.0
						var ton := 0.80 + 0.14 * s - 0.17 * ak * (0.5 + 0.5 * dd)
						ccs[q] = Color(ton * (1.0 - 0.30 * dd), ton * (1.0 - 0.17 * dd), ton * (1.0 - 0.38 * dd))
				var fn: Vector3 = ((vv[1] as Vector3) - (vv[0] as Vector3)).cross((vv[2] as Vector3) - (vv[0] as Vector3)).normalized()
				var hedef := Vector3(0, 0.3, 1.0 if j < 7 else -1.0)
				if fn.dot(hedef) < 0.0:
					fn = -fn
				if v2:
					# TUR-6: iç yüzler surla aynı aydınlıkta (gölgelendirme normali yukarı yatık: kara şerit okunmasın)
					fn = (fn + Vector3.UP * 0.9).normalized()
				_ucgen_n(tst, vv, ccs, [fn, fn, fn, fn, fn, fn])
				anyt = true
			else:
				_ucgen_n(st, vv, [crow[i][j], crow[i][j + 1], crow[i + 1][j], crow[i + 1][j], crow[i][j + 1], crow[i + 1][j + 1]], nv)
				any = true
	if any:
		var mi := MeshInstance3D.new()
		mi.name = "HendekToprak"
		mi.mesh = st.commit()
		mi.material_override = _mat()
		mi.set_meta("no_walk", true)
		p.add_child(mi)
	if v2 and lod < 2:
		# TUR-6: harpuşta taşları kaplamayla AYNI ağda (aynı sur taşı malzemesi: ek çizim çağrısı yok)
		anyt = harpusta_kur(tst, x0, x1, z0, z1, kay, lod, tohum, pencere) > 0 or anyt
	if anyt:
		var mt := MeshInstance3D.new()
		mt.name = "HendekKaplama"
		mt.mesh = tst.commit()
		mt.material_override = Props.mat(Color("a49a86"), 0.0, false, "ashlar" if lod < 2 else "ashlar_far")
		if v2:
			# TUR-6: sur taşı gölgelendiricisinin "dipte koyulaşması" yerel y'ye göre (hendek kesiti hep y < 0: bütün yüz
			# %28 koyu + yosunlu kara şerit); pişirmede birleşen Props malzemesi kalır (çizim çağrısı), taban rengi açılır
			mt.material_override = Props.mat(Color("c4b9a2"), 0.0, false, "ashlar" if lod < 2 else "ashlar_far")
		mt.set_meta("no_walk", true)
		p.add_child(mt)
	# kayan kesimlerde dibe düşmüş kaplama taşları (düzensiz kaya, kutu değil)
	if lod == 0:
		var kl: Array = []
		for i in n:
			if float(kay[i]) > 0.5:
				var xm2: float = rows[i][0].x
				if xm2 < pencere.x or xm2 >= pencere.y:
					continue
				for k in 3:
					var hz2 := _hash(tohum + i * 11, k + 40)
					var sc := 0.35 + hz2 * 0.5
					kl.append(Transform3D(Basis.from_euler(Vector3(hz2 * 2.0, hz2 * 6.0, 0.3)).scaled(Vector3(sc * 1.3, sc * 0.7, sc)), Vector3(xm2 + (hz2 - 0.5) * 2.0, -md + sc * 0.25, z1 - 2.5 - hz2 * 4.0)))
		if kl.size() > 0:
			Scenery.scatter(p, KULE.kaya_mesh(), kl, [], Props.mat(Color("948a76"), 0.0, false, "rubble"))



const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")
static var _hmat: StandardMaterial3D

## TUR-6: harpuşta (hendek yakalarının üst taş sırası) — kesme taş bloklar: 0,8–1,4 m boy, 0,5 m en, 0,26 m yükseklik,
## üst kenarları pahlı (aşınmış), aralarında 3–6 cm derz; blok blok ton (kireçtaşı / gri / kumtaşı); %10 eksik, %12
## kaymış (hendeğe doğru 5–25 cm, 3–12° yatık); karşı yakanın toprak kayması kesimlerinde yok (dibe düşmüş). kay: kesit
## satırı başına kayma (0..1). Yerel: x boyunca, iç yaka z0, karşı yaka z1 (kesitle aynı).
static func harpusta_kur(st: SurfaceTool, x0: float, x1: float, z0: float, z1: float, kay: Array, lod: int, tohum: int, pencere := Vector2(-1e9, 1e9)) -> int:
	var ag := {"st": st, "n": 0}
	var nk := kay.size() - 1
	# köşe rengi sur taşı gölgelendiricisinde taban renginin (a49a86 × 0,93) çarpanı: blok blok ton farkı
	var tonlar := [Color("f2f0ec"), Color("e4e2de"), Color("d6d4d0"), Color("ece6da"), Color("f0ece4")]
	for yaka in 2:
		var x := x0 + 0.05
		var k := 0
		while x < x1 - 0.3:
			var hb := _hash(tohum * 31 + yaka * 977 + k, 5)
			var L := lerpf(0.6, 1.1, hb)
			if x + L > x1 - 0.05:
				L = x1 - 0.05 - x
			if L < 0.35:
				break
			var xm := x + L * 0.5
			x += L + lerpf(0.03, 0.06, _hash(k, tohum + yaka))
			k += 1
			if xm < pencere.x or xm >= pencere.y:
				continue
			var ii := clampi(int((xm - x0) / (x1 - x0) * nk), 0, nk)
			if yaka == 1 and float(kay[ii]) > 0.2:
				continue                          # toprak kayması: harpuşta dibe düşmüş
			var hm := _hash(tohum + k * 3, yaka + 11)
			if hm < 0.1 and lod == 0:
				continue                          # eksik taş
			var kayik := hm > 0.88
			var W := 0.5
			var zi := z0 - 0.04 if yaka == 0 else z1 - W + 0.04
			var ic := 1.0 if yaka == 0 else -1.0     # hendeğe doğru +z (iç yaka) / −z (karşı yaka)
			var hgt := 0.26 + (_hash(k, 77 + yaka) - 0.5) * 0.06
			var dz := 0.0
			var tilt := 0.0
			if kayik:
				dz = lerpf(0.05, 0.25, _hash(k, 91)) * ic
				tilt = deg_to_rad(lerpf(3.0, 12.0, _hash(k, 93)))
			var yaw := (_hash(k, 95 + yaka) - 0.5) * 0.05
			var bas := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, tilt * ic)
			var o := Vector3(xm, -0.16, zi + W * 0.5 + dz)      # üst yüz arazinin ~0,10 m üstünde (gömülü taban)
			var col: Color = tonlar[int(_hash(k * 7, tohum + yaka) * tonlar.size()) % tonlar.size()]
			col = col.darkened((_hash(k, 3) - 0.5) * 0.12)
			var ust := col.lightened(0.06)            # üst yüz: güneş solması
			var hx := L * 0.5
			var hz := W * 0.5
			var pa := 0.05                            # pah
			var b := [Vector3(-hx, 0, -hz), Vector3(hx, 0, -hz), Vector3(hx, 0, hz), Vector3(-hx, 0, hz)]
			var m := [Vector3(-hx, hgt - pa, -hz), Vector3(hx, hgt - pa, -hz), Vector3(hx, hgt - pa, hz), Vector3(-hx, hgt - pa, hz)]
			var t := [Vector3(-hx + pa, hgt, -hz + pa), Vector3(hx - pa, hgt, -hz + pa), Vector3(hx - pa, hgt, hz - pa), Vector3(-hx + pa, hgt, hz - pa)]
			for arr: Array in [b, m, t]:
				for q in 4:
					arr[q] = o + bas * (arr[q] as Vector3)
			var mer := o + bas * Vector3(0, hgt * 0.5, 0)
			for q in 4:
				var q2 := (q + 1) % 4
				_hq(ag, b[q], b[q2], m[q2], m[q], ((b[q] + b[q2]) * 0.5 - mer) * Vector3(1, 0, 1), col)
				_hq(ag, m[q], m[q2], t[q2], t[q], ((m[q] + m[q2]) * 0.5 - mer) + Vector3.UP * 0.2, col.lerp(ust, 0.5))
			_hq(ag, t[0], t[1], t[2], t[3], Vector3.UP, ust)
	return int(ag["n"])


## Dörtgen (iki üçgen), istenen dış normale göre sarım (Godot ön yüzü saat yönünde); düz normal, köşe rengi
static func _hq(ag: Dictionary, a: Vector3, b: Vector3, c: Vector3, d: Vector3, dis: Vector3, col: Color) -> void:
	var nrm := (b - a).cross(d - a)
	if nrm.length_squared() < 1e-10:
		return
	if nrm.dot(dis) < 0.0:
		nrm = -nrm
	nrm = nrm.normalized()
	var st: SurfaceTool = ag["st"]
	for tr: Array in [[a, b, c], [a, c, d]]:
		var p0: Vector3 = tr[0]
		var p1: Vector3 = tr[1]
		var p2: Vector3 = tr[2]
		if (p1 - p0).cross(p2 - p0).dot(nrm) > 0.0:
			var tmp := p1
			p1 = p2
			p2 = tmp
		for v: Vector3 in [p0, p1, p2]:
			st.set_color(col)
			st.set_normal(nrm)
			st.add_vertex(v)
	ag["n"] = int(ag["n"]) + 2


static var _sz: Mesh

## Saz sapı: ince koni (SUR-5: kutu değil)
static func _saz() -> Mesh:
	if _sz == null:
		var c := CylinderMesh.new()
		c.top_radius = 0.0
		c.bottom_radius = 0.6
		c.height = 1.0
		c.radial_segments = 4
		c.rings = 1
		_sz = c
	return _sz


## SUR-5: hendek rampası (görünen): kama prizması uçtan bakınca "yeşil piramit" okunuyordu (sahip_03). Toprak döküm
## rampa: üstü düz yürüme şeridi, yanları yumuşak eğimle dibe iner; köşe normalli, toprak renkli. xa: dipteki uç, xb:
## yaka hizasındaki uç (y0 + rise), z: şerit ortası, w: şerit eni. Çarpışma surlar.gd'deki görünmez kama.
static func rampa(p: Node3D, xa: float, xb: float, z: float, y0: float, rise: float, w: float, tohum: int) -> void:
	var nx := 10
	var kes := [-w * 0.5 - 2.6, -w * 0.5 - 1.0, -w * 0.5, 0.0, w * 0.5, w * 0.5 + 1.0, w * 0.5 + 2.6]
	var rows: Array = []
	var cols: Array = []
	for i in nx + 1:
		var t := float(i) / nx
		var x := lerpf(xa, xb, t)
		var yt := y0 + rise * t
		var r: Array = []
		var c: Array = []
		for j in kes.size():
			var zz: float = kes[j]
			var dz := maxf(absf(zz) - w * 0.5, 0.0)
			var k := clampf(dz / 2.6, 0.0, 1.0)
			var y := lerpf(yt, y0 - 0.05, k * k * (3.0 - 2.0 * k)) + (_hash(tohum + i, j) - 0.5) * 0.1
			r.append(Vector3(x, y, z + zz))
			c.append(TOPRAK.lerp(CAMUR, _hash(tohum * 3 + i, j)) if k < 0.5 else CAMUR.lerp(TOPRAK2, 0.4))
		rows.append(r)
		cols.append(c)
	var nrm := _izgara_normal(rows)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in nx:
		for j in kes.size() - 1:
			_ucgen_n(st, [rows[i][j], rows[i][j + 1], rows[i + 1][j], rows[i + 1][j], rows[i][j + 1], rows[i + 1][j + 1]],
				[cols[i][j], cols[i][j + 1], cols[i + 1][j], cols[i + 1][j], cols[i][j + 1], cols[i + 1][j + 1]],
				[nrm[i][j], nrm[i][j + 1], nrm[i + 1][j], nrm[i + 1][j], nrm[i][j + 1], nrm[i + 1][j + 1]])
	# TUR-7: uçlar kapalı (yaka ucunda omzun altı açık kalıyor, içten bakınca açık gri üçgen okunuyordu): kesit dibe
	# kadar koyu döküm toprakla örülür
	var koyu := CAMUR.lerp(TOPRAK2, 0.5)
	koyu.a = 0.15
	for uc: int in [0, nx]:
		var r: Array = rows[uc]
		var dn := Vector3(signf(xa - xb) if uc == 0 else signf(xb - xa), 0.15, 0.0).normalized()
		for j in kes.size() - 1:
			var p0: Vector3 = r[j]
			var p1: Vector3 = r[j + 1]
			var q0 := Vector3(p0.x, y0 - 0.08, p0.z)
			var q1 := Vector3(p1.x, y0 - 0.08, p1.z)
			if p0.y - q0.y < 0.03 and p1.y - q1.y < 0.03:
				continue
			_ucgen_n(st, [p0, p1, q1, p0, q1, q0], [koyu, koyu, koyu, koyu, koyu, koyu], [dn, dn, dn, dn, dn, dn])
	var mi := MeshInstance3D.new()
	mi.name = "HendekRampa"
	mi.mesh = st.commit()
	mi.material_override = _mat()
	mi.set_meta("no_walk", true)
	p.add_child(mi)


## TUR-7: hendek yakası kıyı örtüsü (yalnız görünüm): harpuştanın üstüne taşan düzensiz toprak/ot saçağı; yer yer çökmüş
## (kenar hendeğe doğru 0,3–1,1 m sarkar, harpuştayı örter), yer yer çıplak taş görünür. ze: yaka çizgisi (harpuşta dış
## ucu), s: karaya doğru yön (+1 dış yaka, −1 iç yaka). kes: atlanacak x aralıkları (rampa, geçit, kapı).
static func kiyi_ortu(p: Node3D, x0: float, x1: float, ze: float, s: float, tohum: int, kes: Array, pencere := Vector2(-1e9, 1e9)) -> void:
	var GOR := load("res://scripts/world/ist/sur_gorunus.gd")
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var adim := 1.4
	var n := int(ceil((x1 - x0) / adim))
	var prof := [-1.15, -0.6, -0.15, 0.5, 1.3, 2.6]
	var rows: Array = []
	var cols: Array = []
	var aktif: Array = []
	for i in n + 1:
		var x := lerpf(x0, x1, float(i) / n)
		var ok := true
		for k: Array in kes:
			if x > float(k[0]) and x < float(k[1]):
				ok = false
		aktif.append(ok)
		var cok: float = clampf((GOR.gn(x, ze, 7.0, tohum % 13) - 0.42) * 3.0, 0.0, 1.0)     # çökme (0..1)
		var tas_gor: bool = GOR.gn(x, ze, 4.0, tohum % 7 + 3) > 0.62                       # kenar geri çekilmiş: harpuşta açık
		var r: Array = []
		var c: Array = []
		for j in prof.size():
			var d: float = prof[j]
			var hz := _hash(tohum + i * 3, j * 5 + 1)
			var y := 0.12 + hz * 0.08
			var dd := d
			if j == 0:
				y = lerpf(0.02, -1.1, cok) if not tas_gor else 0.1
				dd = lerpf(-0.25, d, cok) if not tas_gor else 0.05
			elif j == 1:
				y = lerpf(0.15, -0.45, cok) if not tas_gor else 0.13
				dd = lerpf(-0.2, d, maxf(cok, 0.3)) if not tas_gor else 0.15
			elif j == 2:
				y = 0.17 + hz * 0.06 - cok * 0.12
				if tas_gor:
					dd = 0.3
			elif j == prof.size() - 1:
				y = 0.0
			var z := ze + s * dd
			r.append(Vector3(x + (hz - 0.5) * 0.4, y, z))
			var w := maxf(dd, 0.0)
			var rc: Array = GOR.zemin_renk(x, z, w + 1.5)
			var col: Color = rc[0]
			if j <= 1:
				col = col.lerp(TOPRAK.darkened(0.15), 0.6)          # kopan kenarın çıplak toprağı
			col.a = 1.0 - float(rc[1]) if j > 1 else 0.05
			c.append(col)
		rows.append(r)
		cols.append(c)
	var nrm := _izgara_normal(rows)
	var say := 0
	for i in n:
		if not aktif[i] or not aktif[i + 1]:
			continue
		var xm := lerpf(x0, x1, (i + 0.5) / n)
		if xm < pencere.x or xm >= pencere.y:
			continue
		for j in prof.size() - 1:
			var vv := [rows[i][j], rows[i][j + 1], rows[i + 1][j], rows[i + 1][j], rows[i][j + 1], rows[i + 1][j + 1]]
			var cc := [cols[i][j], cols[i][j + 1], cols[i + 1][j], cols[i + 1][j], cols[i][j + 1], cols[i + 1][j + 1]]
			var nn := [nrm[i][j], nrm[i][j + 1], nrm[i + 1][j], nrm[i + 1][j], nrm[i][j + 1], nrm[i + 1][j + 1]]
			if s < 0.0:
				vv = [vv[0], vv[2], vv[1], vv[3], vv[5], vv[4]]
				cc = [cc[0], cc[2], cc[1], cc[3], cc[5], cc[4]]
				nn = [nn[0], nn[2], nn[1], nn[3], nn[5], nn[4]]
			_ucgen_n(st, vv, cc, nn)
			say += 1
	if say == 0:
		return
	var mi := MeshInstance3D.new()
	mi.name = "Toprak_HendekKiyi"
	mi.mesh = st.commit()
	mi.material_override = load("res://scripts/world/ist/sur_oturtma_ag.gd").etek_malzeme()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.set_meta("no_walk", true)
	p.add_child(mi)
