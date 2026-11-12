class_name IstKbCtx
extends RefCounted
## Kuzeybati parçasının ortak yapı kiti. Her yapı bir IstKbCtx açar; bütün KÜTLE ölçüleri gerçek metre verilir ve
## k ile çarpılır. İnsan ölçüsündeki parçalar (kapı, basamak, korkuluk, tezgâh) k'den bağımsız kurulur (fix_*).
## Model çerçevesi: eksen -z yönünde (apsis/ön), pivot yon_derece kadar döner; yerel çerçeve pusula hizalıdır
## (+x doğu, -z kuzey). lod: 0 tam, 1 ana kütle + çatı (çarpışmalı), 2 siluet (çarpışmasız birkaç kütle).

const STONE := Color("e9dcc0")
const STONE_D := Color("cdbd9c")
const BRICK := Color("c0704a")
const PLASTER := Color("e6cfa0")
const LEAD := Color("aab2ba")
const LEAD_D := Color("8d949c")
const TILE := Color("c8693f")
const TILE_OLD := Color("b8765a")
const WOOD := Color("6a4a2e")
const WOOD_D := Color("4a3220")
const DARK := Color("1c1816")
const MARBLE := Color("eee8da")
const MOSS := Color("6f8a4a")
const GRASS := Color("7e9a4e")
const EARTH := Color("8a7050")

var root: Node3D          # pivot (yon ile döner)
var k := 0.5
var lod := 0
var yon := 0.0
var seed_i := 1
var rng := RandomNumberGenerator.new()
var tris_hint := 0
var _mm_cache := {}


static func create(host: Node3D, name: String, k_: float, lod_: int, yon_deg: float, seed_ := 1) -> IstKbCtx:
	var c := IstKbCtx.new()
	c.k = k_
	c.lod = lod_
	c.yon = yon_deg
	c.rng.seed = seed_
	c.root = Node3D.new()
	c.root.name = name
	c.root.rotation_degrees.y = -yon_deg
	host.add_child(c.root)
	return c


## Model -> yerel (pivot dönüşü uygulanmış) dönüşümü, perch/climb noktaları için
func to_local(v: Vector3) -> Vector3:
	return v.rotated(Vector3.UP, deg_to_rad(-yon))


func s(v: float) -> float:
	return v * k


func sv(v: Vector3) -> Vector3:
	return v * k


# ----------------------------------------------------------------------------------------------------------------
# Temel kütleler (gerçek metre; k uygulanır). pos: ayak ortası (x, y0, z) = tabanın ortası.

## Katı duvar bloğu. w (x), d (z), h yükseklik, y0 taban yüksekliği (gerçek m). pattern: ashlar/tekfur/brick/plaster
func block(x: float, z: float, w: float, d: float, h: float, y0 := 0.0, col := Color.WHITE, pattern := "ashlar", parent: Node3D = null) -> StaticBody3D:
	var p: Node3D = parent if parent != null else root
	var size := Vector3(w, h, d) * k
	var pos := Vector3(x * k, (y0 + h * 0.5) * k, z * k)
	if lod >= 2:
		var mi := Props.box(p, size, pos, col)
		mi.material_override = Props.mat(col, 0.0, false, "")
		return null
	var b := Props.solid(p, size, pos, Color.WHITE)
	Props.set_pattern(b, col, pattern)
	return b


## Doğrudan metre cinsinden (k uygulanmaz): insan ölçüsü parçalar için.
func fixed_block(pos: Vector3, size: Vector3, col: Color, pattern := "", solid := true, rot_y := 0.0, parent: Node3D = null) -> Node3D:
	var p: Node3D = parent if parent != null else root
	if solid:
		var b := Props.solid(p, size, pos, Color.WHITE, Vector3(0, rot_y, 0))
		(b.get_child(0) as MeshInstance3D).material_override = Props.mat(col, 0.0, false, pattern)
		return b
	var mi := Props.box(p, size, pos, col, Vector3(0, rot_y, 0))
	if pattern != "":
		mi.material_override = Props.mat(col, 0.0, false, pattern)
	return mi


## Dekor kutu (çarpışmasız, k uygulanır)
func deco(x: float, y: float, z: float, w: float, h: float, d: float, col: Color, rot := Vector3.ZERO, pattern := "") -> MeshInstance3D:
	var mi := Props.box(root, Vector3(w, h, d) * k, Vector3(x, y, z) * k, col, rot)
	if pattern != "":
		mi.material_override = Props.mat(col, 0.0, false, pattern)
	return mi


## Dekor kutu, boyut gerçek (k'siz), konum k'li (cephe süsü: kemer, silme)
func trim(pos_real: Vector3, size_fixed: Vector3, col: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	return Props.box(root, size_fixed, pos_real * k, col, rot)


## Dikey silindir kütle (kule, kasnak, sütun): katı (dışbükey kabuk).
func tower(x: float, z: float, r: float, h: float, y0 := 0.0, col := Color.WHITE, pattern := "ashlar", segs := 14, top_r := -1.0, solid := true) -> MeshInstance3D:
	var tr := top_r if top_r >= 0.0 else r
	var mi := Props.cyl(root, r * k, h * k, Vector3(x * k, (y0 + h * 0.5) * k, z * k), col, Vector3.ZERO, segs, tr * k)
	mi.material_override = Props.mat(col, 0.0, false, pattern if lod < 2 else "")
	if solid and lod < 2:
		Props.make_solid(mi)
	return mi


## Çatı: beşik (gable). Sırt z boyunca (axis_z=true) ya da x boyunca. Dışbükey çarpışma, eğim <= ~30°.
## rise gerçek metre; eğim çok dikse rise kırpılır.
func gable(x: float, z: float, w: float, d: float, y0: float, rise: float, axis_z := true, col := TILE, pattern := "tiles", over := 0.35) -> MeshInstance3D:
	var half := (w if axis_z else d) * 0.5 * k + over
	var rs := minf(rise * k, half * 0.5)
	var ww := w * k + (over * 2.0 if axis_z else 0.0)
	var dd := d * k + (0.0 if axis_z else over * 2.0)
	var ll := d * k + over * 2.0 if axis_z else w * k + over * 2.0
	var wid := half * 2.0
	var pm := PrismMesh.new()
	pm.size = Vector3(wid, rs, ll)
	var mi := MeshInstance3D.new()
	mi.mesh = pm
	mi.material_override = Props.mat(col, 0.0, false, pattern if lod < 2 else "")
	mi.position = Vector3(x * k, y0 * k + rs * 0.5, z * k)
	if not axis_z:
		mi.rotation_degrees.y = 90.0
	root.add_child(mi)
	if lod < 2:
		var body := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var cv := ConvexPolygonShape3D.new()
		var hw := wid * 0.5
		var hl := ll * 0.5
		cv.points = PackedVector3Array([Vector3(-hw, -rs * 0.5, -hl), Vector3(hw, -rs * 0.5, -hl), Vector3(0, rs * 0.5, -hl),
			Vector3(-hw, -rs * 0.5, hl), Vector3(hw, -rs * 0.5, hl), Vector3(0, rs * 0.5, hl)])
		cs.shape = cv
		body.add_child(cs)
		mi.add_child(body)
	# mahya (sırt) çizgisi
	if lod == 0:
		var rl := Props.box(mi, Vector3(0.22, 0.14, ll), Vector3(0, rs * 0.5 + 0.02, 0), TILE_OLD)
		rl.material_override = Props.mat(TILE_OLD)
	return mi


## Tek eğimli (şed) çatı: alçak ek yapılar için. Yüksek kenar +x (dir=1) ya da -x (dir=-1).
func lean(x: float, z: float, w: float, d: float, y0: float, rise: float, dir_x := 1, col := TILE) -> void:
	var rs := rise * k
	var pm := PrismMesh.new()
	pm.size = Vector3(w * k, rs, d * k)
	pm.left_to_right = 1.0 if dir_x > 0 else 0.0
	var mi := MeshInstance3D.new()
	mi.mesh = pm
	mi.material_override = Props.mat(col, 0.0, false, "tiles" if lod < 2 else "")
	mi.position = Vector3(x * k, y0 * k + rs * 0.5, z * k)
	root.add_child(mi)
	if lod < 2:
		var body := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var cv := ConvexPolygonShape3D.new()
		var hw := w * k * 0.5
		var hl := d * k * 0.5
		var hi := hw * dir_x
		cv.points = PackedVector3Array([Vector3(-hw, -rs * 0.5, -hl), Vector3(hw, -rs * 0.5, -hl), Vector3(hi, rs * 0.5, -hl),
			Vector3(-hw, -rs * 0.5, hl), Vector3(hw, -rs * 0.5, hl), Vector3(hi, rs * 0.5, hl)])
		cs.shape = cv
		body.add_child(cs)
		mi.add_child(body)


## Yassı yürünür dam (toprak ya da taş), korkuluksuz
func flat_roof(x: float, z: float, w: float, d: float, y0: float, col := STONE_D) -> void:
	block(x, z, w, d, 0.5, y0 - 0.5, col, "flagstone")


# ----------------------------------------------------------------------------------------------------------------
# Kubbe

static var _dome_cache := {}


## Dilimli (pırtık) kubbe ağı: R yarıçap, H yükseklik (k'li), ribs dilim sayısı.
static func dome_mesh(R: float, H: float, ribs: int, rings := 7) -> ArrayMesh:
	var key := "%.3f|%.3f|%d|%d" % [R, H, ribs, rings]
	if _dome_cache.has(key):
		return _dome_cache[key]
	var seg := ribs * 2
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array = []
	for i in rings + 1:
		var th := (PI * 0.5) * float(i) / rings            # 0 = tepe
		var row: Array = []
		for j in seg:
			var ph := TAU * float(j) / seg
			var scallop := 1.0 + 0.045 * cos(ph * ribs * 0.5) * sin(th)
			var rr := R * sin(th) * scallop
			row.append(Vector3(cos(ph) * rr, H * cos(th), sin(ph) * rr))
		pts.append(row)
	for i in rings:
		for j in seg:
			var j2 := (j + 1) % seg
			var a: Vector3 = pts[i][j]
			var b: Vector3 = pts[i][j2]
			var c: Vector3 = pts[i + 1][j]
			var d: Vector3 = pts[i + 1][j2]
			if i == 0:
				st.add_vertex(a); st.add_vertex(d); st.add_vertex(c)
			else:
				st.add_vertex(a); st.add_vertex(b); st.add_vertex(d)
				st.add_vertex(a); st.add_vertex(d); st.add_vertex(c)
	st.generate_normals()
	var m := st.commit()
	_dome_cache[key] = m
	return m


## Kubbe: kasnak (silindir + pencereler) + kurşun kubbe + haç. base_y: kasnağın altı (gerçek m).
## R: kasnak yarıçapı (gerçek m), drum_h: kasnak boyu, dome_h: kubbe yüksekliği.
func dome(x: float, z: float, base_y: float, R: float, drum_h: float, dome_h: float, windows := 12, ribs := 12, cross := true, col_drum := Color.WHITE) -> void:
	var drum := tower(x, z, R, drum_h, base_y, col_drum, "ashlar", 16 if lod == 0 else 10, R * 0.985)
	var top_y := (base_y + drum_h) * k
	if lod >= 2:
		var dm := MeshInstance3D.new()
		dm.mesh = dome_mesh(R * k * 0.97, dome_h * k, ribs, 3)
		dm.material_override = Props.mat(LEAD)
		dm.position = Vector3(x * k, top_y, z * k)
		root.add_child(dm)
		return
	# kasnak üst silmesi
	var cor := Props.cyl(root, R * k * 1.04, 0.12, Vector3(x * k, top_y - 0.06, z * k), STONE_D, Vector3.ZERO, 16 if lod == 0 else 10)
	var dm := MeshInstance3D.new()
	dm.mesh = dome_mesh(R * k * 0.97, dome_h * k, ribs, 7 if lod == 0 else 4)
	dm.material_override = Props.mat(LEAD)
	dm.position = Vector3(x * k, top_y, z * k)
	root.add_child(dm)
	# kubbe kabuğu çarpışması: kubbenin dışbükey kabuğu
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var cv := ConvexPolygonShape3D.new()
	cv.points = (dome_mesh(R * k * 0.97, dome_h * k, ribs, 4) as ArrayMesh).get_faces()
	cs.shape = cv
	body.add_child(cs)
	dm.add_child(body)
	# tepe fenerliği: küçük katı silindir (konma yeri) + haç
	var ty := top_y + dome_h * k
	var fr := maxf(0.22, 0.05 * R * k)
	var lan := Props.cyl(root, fr, 0.5, Vector3(x * k, ty - 0.08, z * k), LEAD_D, Vector3.ZERO, 8)
	Props.make_solid(lan)
	if cross:
		Props.cyl(root, 0.03, 0.9, Vector3(x * k, ty + 0.65, z * k), Color("40362e"), Vector3.ZERO, 5)
		Props.box(root, Vector3(0.5, 0.05, 0.05), Vector3(x * k, ty + 0.85, z * k), Color("40362e"))
		Props.box(root, Vector3(0.05, 0.05, 0.5), Vector3(x * k, ty + 0.85, z * k), Color("40362e"), Vector3.ZERO)
	# kasnak pencereleri: MultiMesh (koyu boşluk + taş çerçeve)
	if lod == 0 and windows > 0:
		var wx: Array = []
		var fx: Array = []
		var rad := R * k * 0.985
		var wh := clampf(drum_h * k * 0.55, 0.5, 1.6)
		var ww := clampf(rad * TAU / windows * 0.34, 0.25, 0.6)
		var wy := (base_y + drum_h * 0.5) * k
		for i in windows:
			var a := TAU * (i + 0.5) / windows
			var dir := Vector3(sin(a), 0, cos(a))
			var t := Transform3D(Basis(Vector3.UP, a), Vector3(x * k, wy, z * k) + dir * (rad + 0.015))
			wx.append(t)
			var t2 := Transform3D(Basis(Vector3.UP, a), Vector3(x * k, wy, z * k) + dir * (rad + 0.005))
			fx.append(t2)
		mm_box(root, Vector3(ww, wh, 0.05), DARK, wx)
		mm_box(root, Vector3(ww + 0.18, wh + 0.14, 0.04), STONE, fx)
		# pencere kemeri: üstte yarım daire
		var ax: Array = []
		for t in wx:
			var tt: Transform3D = t
			ax.append(Transform3D(tt.basis, tt.origin + Vector3(0, wh * 0.5, 0)))
		mm_cyl(root, ww * 0.5, 0.05, DARK, ax, true)


# ----------------------------------------------------------------------------------------------------------------
# MultiMesh yardımcıları

func mm_box(p: Node3D, size: Vector3, col: Color, xf: Array, pattern := "") -> MultiMeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = size
	return _mm(p, bm, col, xf, pattern)


func mm_cyl(p: Node3D, r: float, h: float, col: Color, xf: Array, face := false) -> MultiMeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r
	cm.height = h
	cm.radial_segments = 8
	cm.rings = 1
	# face: disk yüzü +z'ye baksın (cephe kemeri)
	var xs: Array = xf
	if face:
		xs = []
		for t in xf:
			var tt: Transform3D = t
			xs.append(Transform3D(tt.basis * Basis(Vector3.RIGHT, PI * 0.5), tt.origin))
	return _mm(p, cm, col, xs, "")


func mm_ball(p: Node3D, r: float, col: Color, xf: Array) -> MultiMeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 8
	sm.rings = 4
	return _mm(p, sm, col, xf, "")


func _mm(p: Node3D, mesh: Mesh, col: Color, xf: Array, pattern: String) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xf.size()
	var ab := AABB()
	for i in xf.size():
		var t: Transform3D = xf[i]
		mm.set_instance_transform(i, t)
		var b := AABB(t.origin - Vector3.ONE * 3.0, Vector3.ONE * 6.0)
		ab = b if i == 0 else ab.merge(b)
	mm.custom_aabb = ab.grow(4.0)
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = Props.mat(col, 0.0, false, pattern, false)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.add_child(mi)
	return mi


# ----------------------------------------------------------------------------------------------------------------
# Cephe ayrıntıları (yalnız lod 0)

## Kemerli pencere dizisi. Cephe düzlemi: merkez (x,z), cephe normali nrm_y (derece, 0 = +z'ye bakar; 90 = +x), yüz uzaklığı
## fd (gerçek m, merkezden cepheye). ys: pencere merkezi yükseklikleri (gerçek m). offs: yan kaymalar (gerçek m).
## pw, ph: pencere boyu (k'siz, cm hassasiyetli; zemin kat insan ölçüsü).
func windows_on(cx: float, cz: float, nrm_deg: float, fd: float, offs: Array, y: float, pw := 0.7, ph := 1.1, arched := true, tall_fixed := true, bars := false) -> void:
	if lod > 0:
		return
	var a := deg_to_rad(nrm_deg)
	var n := Vector3(sin(a), 0, cos(a))
	var tg := Vector3(cos(a), 0, -sin(a))
	var c := Vector3(cx, 0, cz) * k
	var wx: Array = []
	var fx: Array = []
	var ax: Array = []
	var ax2: Array = []
	var yy := y * k if not tall_fixed else y * k
	for o in offs:
		var base := c + n * (fd * k) + tg * (float(o) * k)
		var bas := Basis(Vector3.UP, a)
		wx.append(Transform3D(bas, base + n * 0.012 + Vector3(0, yy, 0)))
		fx.append(Transform3D(bas, base + n * 0.004 + Vector3(0, yy, 0)))
		ax.append(Transform3D(bas, base + n * 0.012 + Vector3(0, yy + ph * 0.5, 0)))
		ax2.append(Transform3D(bas, base + n * 0.004 + Vector3(0, yy + ph * 0.5, 0)))
	mm_box(root, Vector3(pw, ph, 0.04), DARK, wx)
	mm_box(root, Vector3(pw + 0.2, ph + 0.12, 0.03), STONE, fx)
	if arched:
		mm_cyl(root, pw * 0.5, 0.04, DARK, ax, true)
		mm_cyl(root, pw * 0.5 + 0.1, 0.03, STONE, ax2, true)
	if bars:
		var bx: Array = []
		for o in offs:
			var base := c + n * (fd * k) + tg * (float(o) * k)
			for q in 3:
				var off := (q - 1) * pw * 0.3
				bx.append(Transform3D(Basis(Vector3.UP, a), base + n * 0.05 + tg * off + Vector3(0, yy, 0)))
		mm_box(root, Vector3(0.025, ph, 0.025), Color("2c2824"), bx)


## Kapı: cepheden hafif çıkıntılı taş çerçeve + ahşap kanat + kemer (insan ölçüsü: 1,4 × 2,2). Girilmez (dekor).
func door_on(cx: float, cz: float, nrm_deg: float, fd: float, off: float, wall_h_real: float, dw := 1.4, dh := 2.2) -> void:
	if lod > 0:
		return
	var a := deg_to_rad(nrm_deg)
	var n := Vector3(sin(a), 0, cos(a))
	var tg := Vector3(cos(a), 0, -sin(a))
	var hh := minf(dh, wall_h_real * k * 0.72)
	var base := Vector3(cx, 0, cz) * k + n * (fd * k) + tg * (off * k)
	var bas := Basis(Vector3.UP, a)
	var parts := Node3D.new()
	parts.position = base
	parts.basis = bas
	root.add_child(parts)
	Props.box(parts, Vector3(dw + 0.5, hh + 0.25, 0.1), Vector3(0, (hh + 0.25) * 0.5, 0.04), STONE)
	Props.box(parts, Vector3(dw, hh, 0.12), Vector3(0, hh * 0.5, 0.05), WOOD)
	var arch := Props.cyl(parts, dw * 0.5, 0.12, Vector3(0, hh, 0.05), WOOD, Vector3(90, 0, 0), 10)
	arch.scale = Vector3(1, 1, 1)
	for i in 3:
		Props.box(parts, Vector3(dw - 0.1, 0.07, 0.04), Vector3(0, 0.45 + i * 0.7, 0.115), Color("2a2622"))
	Props.ball(parts, 0.05, Vector3(dw * 0.3, hh * 0.45, 0.14), Color("c8a050"), Vector3.ONE, 6)
	# eşik taşı
	Props.box(parts, Vector3(dw + 0.6, 0.1, 0.5), Vector3(0, 0.05, 0.28), STONE_D)


## Payanda (eğik/basamaklı destek): konum merkez (x,z) taban, w genişlik (gerçek), proj çıkıntı, h boy. Katı, iki kademeli.
func buttress(x: float, z: float, nrm_deg: float, w: float, proj: float, h: float, col := STONE_D) -> void:
	if lod > 0:
		return
	var a := deg_to_rad(nrm_deg)
	var n := Vector3(sin(a), 0, cos(a))
	var tg := Vector3(cos(a), 0, -sin(a))
	# alt kademe
	var t1 := Props.solid(root, Vector3(w * k, h * k * 0.55, proj * k * 0.9), Vector3(x * k, h * k * 0.275, z * k) + n * (proj * k * 0.45), Color.WHITE, Vector3(0, nrm_deg, 0))
	Props.set_pattern(t1, col, "ashlar")
	var t2 := Props.solid(root, Vector3(w * k * 0.82, h * k * 0.4, proj * k * 0.55), Vector3(x * k, h * k * 0.75, z * k) + n * (proj * k * 0.275), Color.WHITE, Vector3(0, nrm_deg, 0))
	Props.set_pattern(t2, col, "ashlar")


## Yarım silindir apsis (cephe -z'ye açılır; model eksen yönü), içine gömülü katı silindir + yarı kubbe çatı.
func apse(x: float, z: float, r: float, h: float, y0 := 0.0, col := Color.WHITE, cap := true) -> void:
	var mi := tower(x, z, r, h, y0, col, "ashlar", 14 if lod == 0 else 8)
	if cap and lod < 2:
		var dm := MeshInstance3D.new()
		dm.mesh = dome_mesh(r * k * 1.0, minf(r * k * 0.55, 1.6), 8, 4)
		dm.material_override = Props.mat(LEAD)
		dm.position = Vector3(x * k, (y0 + h) * k + 0.02, z * k)
		root.add_child(dm)
		var body := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var cv := ConvexPolygonShape3D.new()
		cv.points = (dm.mesh as ArrayMesh).get_faces()
		cs.shape = cv
		body.add_child(cs)
		dm.add_child(body)
	elif cap:
		var dm2 := MeshInstance3D.new()
		dm2.mesh = dome_mesh(r * k, minf(r * k * 0.55, 1.6), 8, 2)
		dm2.material_override = Props.mat(LEAD)
		dm2.position = Vector3(x * k, (y0 + h) * k + 0.02, z * k)
		root.add_child(dm2)


## Dış merdiven: from_(x,z) gerçek, dir yönü (normalize, xz), yukseklik gerçek-k'siz (m, zaten ölçekli), genişlik 1,4.
## Her basamak yerden başlayan katı sütundur (altı boş kalmaz). Basamak yüksekliği 0,28–0,34.
func stair(fx: float, fz: float, dir: Vector2, height_m: float, width := 1.5, col := STONE_D, tread := 0.5, y0 := 0.0) -> void:
	var n := maxi(1, int(ceil(height_m / 0.32)))
	var rise := height_m / n
	var d := dir.normalized()
	var ang := rad_to_deg(atan2(d.x, d.y))      # +z'ye göre Y dönüşü (d = (x,z))
	for i in n:
		var top := rise * (i + 1)
		var along := tread * (n - i - 0.5)       # en yüksek basamak duvara bitişik (along küçük)
		var pos := Vector3(fx * k, y0 + top * 0.5, fz * k) + Vector3(d.x, 0, d.y) * (-along)
		var b := Props.solid(root, Vector3(width, top, tread), pos, Color.WHITE, Vector3(0, ang, 0))
		Props.set_pattern(b, col, "flagstone")


## Yığılmış sandık/fıçı basamakları (insan ölçüsü): zeminden başlayıp duvara dayalı, her basamak katı.
func crate_steps(x: float, z: float, dir: Vector2, count: int, rise := 0.5, y0 := 0.0) -> void:
	var d := dir.normalized()
	var ang := rad_to_deg(atan2(d.x, d.y))
	for i in count:
		var top := rise * (i + 1)
		var along := 0.9 * (count - i - 0.5)
		var pos := Vector3(x * k, y0 + top * 0.5, z * k) - Vector3(d.x, 0, d.y) * along
		var b := Props.solid(root, Vector3(1.1, top, 0.9), pos, Color.WHITE, Vector3(0, ang, 0))
		Props.set_pattern(b, WOOD if i % 2 == 0 else Color("7e5a38"), "wood")
		# kasa şeritleri
		Props.box(root, Vector3(1.12, 0.06, 0.92), pos + Vector3(0, top * 0.5 - 0.08, 0), WOOD_D, Vector3(0, ang, 0))


## Dekor: tuğla bandı (opus mixtum şeridi) bir cephenin üstüne
func band(cx: float, cz: float, nrm_deg: float, fd: float, w: float, y: float, hgt := 0.25, col := BRICK) -> void:
	if lod > 0:
		return
	var a := deg_to_rad(nrm_deg)
	var n := Vector3(sin(a), 0, cos(a))
	Props.box(root, Vector3(w * k, hgt, 0.04), Vector3(cx, 0, cz) * k + n * (fd * k + 0.01) + Vector3(0, y * k, 0), col, Vector3(0, nrm_deg, 0))


# ----------------------------------------------------------------------------------------------------------------
# Bitki ve sahne ayrıntısı (k'siz boy; insan ölçeği)

func cypress(x: float, z: float, h := 7.0, y := 0.0) -> void:
	if lod >= 2:
		Props.cyl(root, 0.02, h * 0.9, Vector3(x * k, y * k + h * 0.45, z * k), Color("34502c"), Vector3.ZERO, 5, 0.9 * 0.0 + 0.0)
		return
	var hh := h * maxf(k, 0.55)
	Props.cyl(root, 0.09, hh * 0.15, Vector3(x * k, y * k + hh * 0.075, z * k), WOOD_D, Vector3.ZERO, 5)
	var b := Props.cyl(root, 0.0, hh * 0.9, Vector3(x * k, y * k + hh * 0.55, z * k), Color("34502c"), Vector3.ZERO, 7, 0.0)
	b.scale = Vector3.ONE
	var c := Props.ball(root, hh * 0.1, Vector3(x * k, y * k + hh * 0.45, z * k), Color("3a5a30"), Vector3(1, hh * 0.9 / (hh * 0.2), 1), 7)
	c.name = "cypress"


func olive(x: float, z: float, y := 0.0, sc := 1.0) -> void:
	if lod >= 2:
		return
	Props.cyl(root, 0.14 * sc, 1.5 * sc, Vector3(x * k, y * k + 0.75 * sc, z * k), Color("5e4a36"), Vector3(4, 0, 3), 6, 0.1 * sc)
	Props.ball(root, 1.3 * sc, Vector3(x * k, y * k + 2.0 * sc, z * k), Color("7f9060"), Vector3(1.2, 0.7, 1.2), 7)
	Props.ball(root, 0.9 * sc, Vector3(x * k + 0.7 * sc, y * k + 1.8 * sc, z * k - 0.3), Color("8a9a68"), Vector3(1, 0.7, 1), 6)


func rubble(x: float, z: float, n: int, spread: float, y := 0.0) -> void:
	for i in n:
		var rx := x * k + rng.randf_range(-spread, spread) * k
		var rz := z * k + rng.randf_range(-spread, spread) * k
		var sz := rng.randf_range(0.25, 0.7)
		var mi := Props.box(root, Vector3(sz, sz * rng.randf_range(0.5, 0.9), sz * 1.2), Vector3(rx, y * k + sz * 0.3, rz), [STONE_D, BRICK, Color("a99a82")][i % 3], Vector3(rng.randf_range(-8, 8), rng.randf_range(0, 180), rng.randf_range(-8, 8)))
		if sz > 0.5 and lod == 0:
			Props.make_solid(mi)


func fire(x: float, y: float, z: float, w := 0.4, h := 0.7) -> void:
	if lod == 0:
		Flame.add(root, Vector3(x, y, z), w, h)


## Zemin yaması (çarpışmalı ince plaka, görsel yüzey): z-çakışması olmasın diye +2 cm
func ground_patch(x: float, z: float, w: float, d: float, col: Color, pattern := "", thick := 0.06) -> void:
	var b := Props.solid(root, Vector3(w * k, thick, d * k), Vector3(x * k, thick * 0.5 + 0.0, z * k), Color.WHITE)
	Props.set_pattern(b, col, pattern)


## Siperlik: a'dan b'ye (model xz gerçek m, y = ölçekli metre) katı alçak duvar (1,1 m) + üstünde mazgal sırası
func parapet(ax: float, az: float, bx: float, bz: float, y: float, thick := 0.5, h := 1.1, col := STONE_D) -> void:
	var a := Vector3(ax, 0, az) * k
	var b := Vector3(bx, 0, bz) * k
	var len := a.distance_to(b)
	if len < 0.2:
		return
	var mid := (a + b) * 0.5
	var ang := rad_to_deg(atan2(b.x - a.x, b.z - a.z))
	var pos := Vector3(mid.x, y + h * 0.5, mid.z)
	if lod >= 2:
		return
	var bd := fixed_block(pos, Vector3(thick, h, len), col, "ashlar", true, ang)
	if lod == 0:
		var n := maxi(2, int(len / 1.7))
		var xf: Array = []
		for i in n:
			var f := (i + 0.5) / n
			var pp := a.lerp(b, f)
			xf.append(Transform3D(Basis(Vector3.UP, deg_to_rad(ang)), Vector3(pp.x, y + h + 0.22, pp.z)))
		mm_box(root, Vector3(thick + 0.06, 0.44, 0.9), col, xf, "ashlar")
