class_name AyrintiLib
extends RefCounted
## İstanbul 1453 "ayrıntı" kitaplığı: öğe kurarken kullanılan ortak yardımcılar ve renk paleti.
## Öğenin başlangıcı (0,0,0) taban ortasıdır; y = 0 zemin. lod >= 1'de 12 cm'den küçük parçalar atlanır.

static var lod := 0

const WOOD := Color("8a5a35")
const WOOD_D := Color("5f3d22")
const WOOD_L := Color("b08350")
const PLANK := Color("a47a4b")
const LINEN := Color("e6dabd")
const RED := Color("b0432f")
const BLUE := Color("40608c")
const OCHRE := Color("cf9a3c")
const GREEN := Color("596e42")   # DOKU-4: soluk (toon gölgede fosforlu açık yeşil okunuyordu)
const GREEN_D := Color("3f5233")
const TERRA := Color("b9683a")
const TERRA_D := Color("94512c")
const STONE := Color("9d978b")
const STONE_D := Color("77726a")
const STONE_L := Color("a29c8e")
const MARBLE := Color("c4bcaa")
const BRICK := Color("a8553a")
const ROPE := Color("c3a56b")
const IRON := Color("484a52")
const IRON_L := Color("6e717a")
const STRAW := Color("d6b65e")
const HAY := Color("c9a547")
const SACK := Color("c8b68c")
const SOIL := Color("5c4330")
const CREAM := Color("dcd2b8")
const BLACK := Color("2a2623")
const FUR_B := Color("7a5a3c")
const FUR_W := Color("e2dccb")
const FUR_G := Color("8a867f")
const FUR_T := Color("c68a45")
const FUR_K := Color("2f2b29")
const PURPLE := Color("6b3a6e")
const GOLD := Color("d2a33a")
const WATER := Color("5b8fa6")
const SKIN := Color("d9a679")


static func _small(size: Vector3) -> bool:
	return lod >= 1 and maxf(size.x, maxf(size.y, size.z)) < 0.12


static func _pat(mi: MeshInstance3D, col: Color, pat: String) -> MeshInstance3D:
	if pat != "":
		Props.set_pattern(mi, col, pat)
	return mi


## Kutu, merkezi pos.
static func b(p: Node3D, size: Vector3, pos: Vector3, col: Color, rot := Vector3.ZERO, pat := "") -> Node3D:
	if _small(size):
		return null
	return _pat(Props.box(p, size, pos, col, rot), col, pat)


## Kutu, dibi y0'da (x, z merkezde).
static func bb(p: Node3D, size: Vector3, x: float, y0: float, z: float, col: Color, rot_y := 0.0, pat := "") -> Node3D:
	return b(p, size, Vector3(x, y0 + size.y * 0.5, z), col, Vector3(0, rot_y, 0), pat)


## Silindir, merkezi pos (rot ile yatırılabilir).
static func c(p: Node3D, r: float, h: float, pos: Vector3, col: Color, rot := Vector3.ZERO, seg := 8, top := -1.0, pat := "") -> Node3D:
	if _small(Vector3(r * 2.0, h, r * 2.0)):
		return null
	return _pat(Props.cyl(p, r, h, pos, col, rot, (mini(seg, 6) if r < 0.15 else mini(seg, 8)) if lod == 0 else 5, top), col, pat)


## Silindir, dibi y0'da.
static func cb(p: Node3D, r: float, h: float, x: float, y0: float, z: float, col: Color, seg := 8, top := -1.0, pat := "") -> Node3D:
	return c(p, r, h, Vector3(x, y0 + h * 0.5, z), col, Vector3.ZERO, seg, top, pat)


static func s(p: Node3D, r: float, pos: Vector3, col: Color, sc := Vector3.ONE, seg := 8) -> Node3D:
	if _small(Vector3.ONE * r * 2.0):
		return null
	# TUR-7: uzak katmanda (lod 1) yeşil öbek 4 dilimle eşkenar dörtgen/kutu okunuyordu (asma çardağı "yeşil levha"):
	# bitki rengi en az 6 dilim; öteki küçük yuvarlaklar 4 (bütçe)
	var yesil := col.g > col.r * 1.05 and col.g > col.b
	return Props.ball(p, r, pos, col, sc, (5 if r < 0.12 else mini(seg, 6)) if lod == 0 else (6 if yesil else 4))


static func pr(p: Node3D, size: Vector3, pos: Vector3, col: Color, rot := Vector3.ZERO) -> Node3D:
	if _small(size):
		return null
	return Props.prism(p, size, pos, col, rot)


## İnce uzun çubuk: a'dan b'ye (kalınlık t).
static func rod(p: Node3D, a: Vector3, bpt: Vector3, t: float, col: Color) -> Node3D:
	var d := bpt - a
	var len := d.length()
	if len < 0.001 or _small(Vector3(t, len, t)):
		return null
	var mi := Props.box(p, Vector3(t, len, t), (a + bpt) * 0.5, col)
	# y ekseni a→b yönüne bakacak şekilde döndür
	var up := Vector3.UP
	var dir := d / len
	var axis := up.cross(dir)
	if axis.length() < 0.0001:
		if dir.y < 0.0:
			mi.rotation_degrees = Vector3(180, 0, 0)
	else:
		mi.transform.basis = Basis(axis.normalized(), up.angle_to(dir))
	return mi


## Görünmez çarpışma kutusu.
static func col_box(p: Node3D, size: Vector3, pos: Vector3, rot := Vector3.ZERO) -> StaticBody3D:
	if lod >= 1:
		return null
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation_degrees = rot
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	body.add_child(cs)
	p.add_child(body)
	return body


## Görünür ve katı kutu.
static func sol(p: Node3D, size: Vector3, pos: Vector3, col: Color, rot := Vector3.ZERO, pat := "") -> Node3D:
	if lod >= 1:
		return b(p, size, pos, col, rot, pat)
	var body := Props.solid(p, size, pos, col, rot)
	if pat != "":
		Props.set_pattern(body.get_child(0), col, pat)
	return body


static func lbl(p: Node3D, text: String, pos: Vector3, px: int, col: Color, rot := Vector3.ZERO) -> Node3D:
	if lod >= 1:
		return null
	return Props.label(p, text, pos, px, col, rot)


## Dört ayaklı hayvan: gövde uzunluğu bl (z ekseni boyunca, baş -z yönünde), gövde yüksekliği bh, ayak boyu lh.
static func quad(p: Node3D, bl: float, bh: float, lh: float, col: Color, head_col: Color, ear := 0.0, tail := true, neck_up := 0.0) -> void:
	var body_y := lh + bh * 0.5
	s(p, 0.5, Vector3(0, body_y, 0), col, Vector3(bh / 1.0, bh / 1.0, bl / 1.0) * 1.0, 8)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			cb(p, maxf(0.035, bh * 0.1), lh + 0.05, sx * bh * 0.28, 0, sz * bl * 0.3, col.darkened(0.15), 5)
	var hs := bh * 0.55
	var hy := body_y + bh * 0.25 + neck_up
	s(p, 0.5, Vector3(0, hy, -bl * 0.55), head_col, Vector3(hs * 0.9, hs * 0.9, hs * 1.1), 7)
	if ear > 0.0:
		for sx in [-1, 1]:
			pr(p, Vector3(ear * 0.6, ear, ear * 0.3), Vector3(sx * hs * 0.3, hy + hs * 0.55, -bl * 0.52), head_col)
	if tail:
		b(p, Vector3(0.04, 0.04, bl * 0.22), Vector3(0, body_y + bh * 0.2, bl * 0.58), col.darkened(0.2))
