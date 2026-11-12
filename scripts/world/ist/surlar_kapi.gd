class_name IstSurlarKapi
extends RefCounted
## Sur kapılarının ortak yapısı: kemer süsü, kapı kanatları, mermer kaplama (Altın Kapı), Romanos koridoru.
## Kapı geçidi IstSurlar._run içinde sur gövdesinden oyulur (opts: gw genişlik, gh yükseklik, kapali, mermer, koridor).

const C_WOOD := Color("7a5634")
const C_IRON := Color("3a3634")
const C_BRICK := Color("96503a")
const C_DARK := Color("15120f")


## Yarım daire kemer süsü (kama taşları, tuğla), z düzleminde. face = +1 dış yüz, -1 iç yüz
static func arch(p: Node3D, cx: float, y: float, r: float, z: float, face: float, col: Color, n := 11, depth := 0.14) -> void:
	for i in n:
		var a := PI * (float(i) + 0.5) / n
		var pos := Vector3(cx + cos(a) * (r + 0.28), y + sin(a) * (r + 0.28), z + face * depth * 0.5)
		var tan_len := PI * (r + 0.28) / n * 0.92
		var m := Props.box(p, Vector3(0.56, tan_len, depth), pos, col if i % 2 == 0 else col.lightened(0.12), Vector3(0, 0, rad_to_deg(a)))
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func build(root: Node3D, lay: Dictionary, lod: int, o: Dictionary) -> void:
	var d: Dictionary = lay["d"]
	var gw: float = lay["gw"]
	var gh: float = float(o.get("gh", 3.6))
	var closed: bool = bool(o.get("kapali", false))
	var T: float = d["T"]
	var HW: float = d["HW"]
	var OH: float = d["OH"]
	var zi0: float = d["zi0"]
	var zi1: float = d["zi1"]
	var zo0: float = d["zo0"]
	var zo1: float = d["zo1"]
	var stone: Color = o.get("tas", Color("cdbd9e"))
	var marble := Color("e6dfcf")
	if lod >= 1:
		if o.get("mermer", false):
			IstSurlar._s(root, Vector3(-lay["gx"], 0, zi1), Vector3(lay["gx"], HW, zi1 + 0.35), marble, "marble", lod)
			IstSurlar._s(root, Vector3(-lay["gx"], 0, zo1), Vector3(lay["gx"], OH, zo1 + 0.35), marble, "marble", lod)
		return
	# ---- mermer kaplama (Altın Kapı): hem peribolos yüzünde (iç sur) hem dış surun ova yüzünde
	if o.get("mermer", false):
		_facade(root, lay, zi1, HW, gh, lod)
		_facade(root, lay, zo1, OH, minf(gh, OH - 1.4), lod)
		return
	# ---- kemer süsü iki yüzde
	if gw > 0.0:
		var r := gw * 0.5
		arch(root, 0.0, gh, r, zi0 - 0.12, -1.0, C_BRICK)
		arch(root, 0.0, gh, r, zi1 - 0.02, 1.0, C_BRICK)
		arch(root, 0.0, gh, r, zo1 - 0.02, 1.0, C_BRICK.darkened(0.05))
		arch(root, 0.0, gh, r, zo0 - 0.12, -1.0, C_BRICK.darkened(0.05))
		# lento üstü yazıt şeridi (açık renk taş)
		IstSurlar._d(root, Vector3(-r - 1.0, gh + r + 0.7, zi1), Vector3(r + 1.0, gh + r + 1.0, zi1 + 0.05), Color("e2d6bb"))
	if closed:
		# tuğla ile örülmüş geçit: kemer içi tuğla, ortasında küçük sıvalı niş
		IstSurlar._d(root, Vector3(-gw * 0.5, 0, zi1), Vector3(gw * 0.5, gh, zi1 + 0.06), Color("8a4a35"), "brick")
		IstSurlar._d(root, Vector3(-gw * 0.5, 0, zi0 - 0.06), Vector3(gw * 0.5, gh, zi0), Color("8a4a35"), "brick")
		return
	# ---- kuşatma (SUR-4, madde 6): kanatlar KAPALI (iç surda ve dış surun geçidinde), demir bağlı, arkası sürgülü
	for zk: float in [zi0 + 0.45, zo0 + 0.45]:
		var hk := gh - 0.2 if zk < zi1 else minf(gh, OH - 1.0) - 0.2
		for sx in [-1.0, 1.0]:
			var xa: float = sx * gw * 0.5
			var lo := Vector3(minf(xa, 0.0), 0.0, zk)
			var hi := Vector3(maxf(xa, 0.0), hk, zk + 0.28)
			IstSurlar._s(root, lo, hi, C_WOOD, "wood", 0)
			for yy in [0.7, hk * 0.5, hk - 0.7]:
				IstSurlar._d(root, Vector3(minf(xa, 0.0) + 0.1, yy, zk - 0.03), Vector3(maxf(xa, 0.0) - 0.1, yy + 0.14, zk), C_IRON)
		# sürgü kirişi (şehir yanında)
		IstSurlar._d(root, Vector3(-gw * 0.5 - 0.3, hk * 0.45, zk + 0.28), Vector3(gw * 0.5 + 0.3, hk * 0.45 + 0.28, zk + 0.5), C_WOOD.darkened(0.2))
	# ---- Romanos koridoru: iki yan duvar iç surdan dış sura (kapı yapısı)
	if o.get("koridor", false):
		var cw := 1.2
		var ch := OH + 0.6
		for sx in [-1.0, 1.0]:
			var xa2: float = sx * gw * 0.5
			var xb2: float = sx * (gw * 0.5 + cw)
			IstSurlar._s(root, Vector3(minf(xa2, xb2), 0, zi1), Vector3(maxf(xa2, xb2), ch, zo0), stone.darkened(0.05), "ashlar", 0, true)
			var xm: float = sx * (gw * 0.5 + cw * 0.5)
			var mer: Array = []
			var zz := zi1 + 0.8
			while zz < zo0 - 0.6:
				mer.append(Transform3D(Basis.from_scale(Vector3(cw * 0.8, 0.5, 0.9)), Vector3(xm, ch + 0.24, zz)))
				zz += 1.7
			Scenery.scatter(root, Scenery._boxm(Vector3.ONE), mer, [], Props.mat(stone.darkened(0.08), 0.0, false, "ashlar"))


## Mermer cephe: z0 duvarın dış yüzü; üç kemer (ortası kapı genişliğinde, kör ve tuğla ile örülü), sütun çiftleri, silme
static func _facade(root: Node3D, lay: Dictionary, z0: float, H: float, gh: float, lod: int) -> void:
	var gw: float = lay["gw"]
	var gx: float = lay["gx"]
	var marble := Color("e6dfcf")
	var zf := z0 + 0.35
	IstSurlar._s(root, Vector3(-gx, 0, z0), Vector3(gx, H, zf), marble, "marble", lod)
	var arch_x := [-gw * 0.95, 0.0, gw * 0.95]
	for i in 3:
		var ax: float = arch_x[i]
		var aw: float = gw if i == 1 else gw * 0.62
		var ah: float = gh if i == 1 else gh * 0.8
		IstSurlar._d(root, Vector3(ax - aw * 0.5, 0, zf), Vector3(ax + aw * 0.5, ah, zf + 0.05), Color("5e4a3a"), "brick")
		arch(root, ax, ah, aw * 0.5, zf, 1.0, Color("c8b99c"))
		IstSurlar._d(root, Vector3(ax - 0.9, 0, zf + 0.05), Vector3(ax + 0.9, 2.3, zf + 0.09), C_DARK)
	var colh := H * 0.62
	for i in 4:
		var sx: float = [-gw * 1.3, -gw * 0.65, gw * 0.65, gw * 1.3][i]
		var cmi := Props.cyl(root, 0.32, colh, Vector3(sx, colh * 0.5, zf + 0.25), marble.lightened(0.04), Vector3.ZERO, 10)
		Props.make_solid(cmi, 0.9)
		Props.box(root, Vector3(0.9, 0.22, 0.9), Vector3(sx, colh + 0.11, zf + 0.25), marble.darkened(0.05))
		Props.box(root, Vector3(0.8, 0.22, 0.8), Vector3(sx, 0.11, zf + 0.25), marble.darkened(0.05))
	IstSurlar._s(root, Vector3(-gw * 1.55, colh + 0.22, zf), Vector3(gw * 1.55, colh + 0.9, zf + 0.7), marble.darkened(0.04), "marble", lod)
	IstSurlar._d(root, Vector3(-gw * 1.5, colh + 0.95, zf), Vector3(gw * 1.5, colh + 1.5, zf + 0.06), C_BRICK, "brick")
