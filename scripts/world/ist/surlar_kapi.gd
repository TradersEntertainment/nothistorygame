class_name IstSurlarKapi
extends RefCounted
## Sur kapılarının ortak yapısı: kemer süsü, kapı kanatları, mermer kaplama (Altın Kapı), Romanos koridoru.
## Kapı geçidi IstSurlar._run içinde sur gövdesinden oyulur (opts: gw genişlik, gh yükseklik, kapali, mermer, koridor).

const C_WOOD := Color("7a5634")
const C_IRON := Color("3a3634")
const C_BRICK := Color("96503a")
const C_DARK := Color("15120f")


## Yarım daire kemer (boşaltma kemeri), z düzleminde. face = +1 dış yüz, −1 iç yüz.
## TUR-14 (Taşıma 10 karesi 01: "iri, parlak turuncu-somon bloklar"): eskiden 11 iri kutu (56 × 72 cm, Props toon +
## kenar ışığı; doygun kiremit, ikide bir açık ton) — yakından oyuncak. Şimdi Theodosius kapılarının gerçek ölçüsü:
##   * kama halkası (r … r+0,56): kesme taş kama taşları (iç yüzde ≈ 30–38 cm) ile tuğla demetleri (üç tuğla: 4,5 cm tuğla +
##     ≈ 3,5 cm harç) dönüşümlü; iki üzengi ve kilit taşı taş
##   * dış halka (r+0,56 … r+0,74): tuğla sırası (tek tek tuğla, 4,5 cm + 3,5 cm harç)
##   * harç yatağı: tüm halkanın arkasında girintili kirli bej-gri (derzler gerçek boşluk + gölge)
## Taş taş/tuğla tuğla ton, yüz yüze 1–4 cm oynak çıkıntı (aşınmış kenar), yer yer kırık köşe. Malzeme sur taşı
## gölgelendiricisi (aynı ressam; gece payı duvarla aynı): kesme taş köşe alfası 0,8 (tek taş: dane, liken, yontu), tuğla
## köşe rengi kızıl (desensiz yıpranma). Tek ağ: eski 11 ayrı kutu ve dış çizgileri yerine bir çizim çağrısı.
## col: tuğla tonlu ise taş/tuğla dönüşümlü (kara surları), değilse yalnız taş kama (Altın Kapı mermer cephesi).
static func arch(p: Node3D, cx: float, y: float, r: float, z: float, face: float, col: Color, n := 11, depth := 0.14) -> void:
	var ag = KEMER_AG.new()
	arch_ag(ag, cx, y, r, z, face, col, depth, n)
	var mi: MeshInstance3D = ag.mesh_ekle(p, kemer_mat(), "Tas_KemerHalka")
	if mi != null:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


const KEMER_AG := preload("res://scripts/world/ist/sur_kule.gd").Ag
const KESME_A := 0.8          # sur_doku: köşe alfası 0,75–0,86 = tek taş (derzsiz kesme taş yolu)
const HALKA := 0.56           # kama halkası kalınlığı (eski kutunun boyu)
const TUGLA := 0.045          # tuğla kalınlığı
const HARC := 0.035           # harç kalınlığı


static func kemer_mat() -> Material:
	return (load("res://scripts/world/ist/sur_doku.gd") as GDScript).call("mat", 0, Color.WHITE, true)


static func _h(a: float, b: float) -> float:
	return fposmod(sin(a * 12.9898 + b * 78.233) * 43758.5453, 1.0)


## Kızıl tuğla (sur_doku "düz" yolu: köşe r > 1,4·g); ton tuğladan tuğlaya (soluk, fazla pişmiş koyu, az pişmiş sarımsı)
static func tugla_renk(h: float, h2: float) -> Color:
	var c := Color(0.6 + 0.08 * h, 0.4 + 0.05 * h, 0.33 + 0.04 * h)
	if h2 > 0.84:
		c = Color(0.66, 0.46, 0.35)          # az pişmiş (sarımsı)
	elif h2 < 0.16:
		c = Color(0.44, 0.27, 0.23)          # fazla pişmiş (mor-kahve)
	c.g = minf(c.g, (c.r - 0.03) / 1.4)
	return c


## Kesme taş (köşe alfası 0,8): sur_doku tek taş yolunda ton köşe parlaklığından (0,62–0,72 sRGB → ×0,76–1,0)
static func tas_renk(h: float) -> Color:
	var v := 0.6 + 0.1 * h
	return Color(v, v * 0.985, v * 0.95, KESME_A)


## Halka dilimi (a0 → a1 açı, ri → ro yarıçap): ön yüz z + face·on, arka z; ön kenar pahlı (aşınmış)
static func _dilim(ag, cx: float, y: float, a0: float, a1: float, ri: float, ro: float, z: float, face: float, on: float,
		col: Color, pah := 0.012, kirik := -1.0, ic_yuz := true) -> void:
	var u0 := Vector3(cos(a0), sin(a0), 0.0)
	var u1 := Vector3(cos(a1), sin(a1), 0.0)
	var o := Vector3(cx, y, z)
	var fz := Vector3(0, 0, face * on)
	if pah <= 0.0:
		# sade dilim (tuğla, harç yatağı): ön yüz + kemer altı + sırt (yanlar komşu derzinde görünmez); 6 üçgen
		var am0 := (a0 + a1) * 0.5
		var um0 := Vector3(cos(am0), sin(am0), 0.0)
		ag.quad(o + u0 * ri + fz, o + u1 * ri + fz, o + u1 * ro + fz, o + u0 * ro + fz, Vector3(0, 0, face), col)
		if ic_yuz:
			ag.quad_auto(o + u0 * ri, o + u1 * ri, o + u1 * ri + fz, o + u0 * ri + fz, -um0, col.darkened(0.08))
		ag.quad_auto(o + u0 * ro, o + u1 * ro, o + u1 * ro + fz, o + u0 * ro + fz, um0, col)
		return
	var pz := Vector3(0, 0, face * maxf(on - pah, 0.0))
	var am := (a0 + a1) * 0.5
	var pa := pah / maxf(ri, 0.3)
	var v0 := Vector3(cos(a0 + pa), sin(a0 + pa), 0.0)
	var v1 := Vector3(cos(a1 - pa), sin(a1 - pa), 0.0)
	# ön yüz (pah kadar içeride küçülmüş dörtgen)
	var f0 := o + v0 * (ri + pah) + fz
	var f1 := o + v1 * (ri + pah) + fz
	var f2 := o + v1 * (ro - pah) + fz
	var f3 := o + v0 * (ro - pah) + fz
	if kirik >= 0.0:
		# kırık köşe: dış köşelerden biri içe çökük
		if kirik < 0.5:
			f3 = f3.lerp(f0, 0.18) - Vector3(0, 0, face * on * 0.5)
		else:
			f2 = f2.lerp(f1, 0.18) - Vector3(0, 0, face * on * 0.5)
	var nf := Vector3(0, 0, face)
	ag.quad(f0, f1, f2, f3, nf, col)
	# pah halkası + yan yüzler (arka z'ye)
	var b0 := o + u0 * ri
	var b1 := o + u1 * ri
	var b2 := o + u1 * ro
	var b3 := o + u0 * ro
	var e0 := o + u0 * ri + pz
	var e1 := o + u1 * ri + pz
	var e2 := o + u1 * ro + pz
	var e3 := o + u0 * ro + pz
	var um := Vector3(cos(am), sin(am), 0.0)
	var dk := col.darkened(0.06)
	ag.quad_auto(e0, e1, f1, f0, -um + nf, dk)
	ag.quad_auto(e1, e2, f2, f1, Vector3(-sin(a1), cos(a1), 0) + nf, dk)
	ag.quad_auto(e2, e3, f3, f2, um + nf, dk)
	ag.quad_auto(e3, e0, f0, f3, -Vector3(-sin(a0), cos(a0), 0) + nf, dk)
	ag.quad_auto(b0, b1, e1, e0, -um, dk)                                   # iç yüz (kemer altı)
	ag.quad_auto(b2, b3, e3, e2, um, col)                                   # dış yüz
	ag.quad_auto(b1, b2, e2, e1, Vector3(-sin(a1), cos(a1), 0), dk)         # yan
	ag.quad_auto(b3, b0, e0, e3, -Vector3(-sin(a0), cos(a0), 0), dk)        # yan


## Kemer halkasını verilen ağa ekler (aynı ağa lento taşları da eklenebilir)
static func arch_ag(ag, cx: float, y: float, r: float, z: float, face: float, col: Color, depth := 0.14, _n := 11, dis_halka := true) -> void:
	var tuglali := col.r > col.g * 1.4
	var rm := r + HALKA * 0.5
	var L := PI * rm
	var sd := float(int(cx * 7.1 + y * 3.3 + z * 5.7 + face * 11.0))
	var on0 := depth * 0.55            # ortalama çıkıntı (eski kutu 14 cm; derz/girinti payı)
	# harç yatağı: tüm halkanın arkasında, taşlardan 4 cm geride (derzde görünen kirli bej-gri)
	var harc := Color(0.5, 0.48, 0.45, KESME_A)
	var seg := 16
	for i in seg:
		var a0 := PI * float(i) / seg
		var a1 := PI * float(i + 1) / seg
		_dilim(ag, cx, y, a0, a1, r + 0.01, r + HALKA + (0.17 if tuglali and dis_halka else 0.0), z, face, maxf(on0 - 0.04, 0.02), harc, 0.0, -1.0, false)
	# kama halkası: taş (≈ 0,34 m) + derz + tuğla demeti (3 tuğla) dönüşümlü; uçlar ve tepe taş
	var tas_w := 0.34
	var dem_w := 3.0 * TUGLA + 2.0 * HARC
	var derz := 0.022
	var birim := tas_w + dem_w + 2.0 * derz if tuglali else tas_w + derz
	var k := maxi(3, int(round((L + (dem_w + 2.0 * derz if tuglali else derz)) / birim)))
	if tuglali and k % 2 == 0:
		k += 1
	# ölçek: taşlar sığsın (tuğla ve derz gerçek ölçüde kalır)
	var sabit := (float(k - 1) * (dem_w + 2.0 * derz)) if tuglali else float(k - 1) * derz
	var tw := (L - sabit) / float(k)
	var s := 0.0
	for i in k:
		var hs := _h(sd + float(i), 3.1)
		var hs2 := _h(sd + float(i) * 1.7, 9.4)
		var a0 := (L - s - tw) / rm
		var a1 := (L - s) / rm
		var on := on0 + (hs - 0.5) * 0.035
		_dilim(ag, cx, y, a0, a1, r + (hs2 - 0.5) * 0.02, r + HALKA + (hs - 0.5) * 0.04, z, face, on,
			tas_renk(hs) if tuglali else Color(col.r * (0.92 + 0.1 * hs), col.g * (0.92 + 0.1 * hs), col.b * (0.9 + 0.1 * hs), KESME_A),
			0.018 + 0.02 * hs2, hs2 if hs2 > 0.72 else -1.0)
		s += tw
		if i == k - 1:
			break
		if tuglali:
			s += derz
			for b in 3:
				var hb := _h(sd + float(i) * 3.0 + float(b), 5.7)
				var hb2 := _h(sd + float(i) * 5.0 + float(b), 1.3)
				var b1 := (L - s - TUGLA) / rm
				var b0 := (L - s) / rm
				_dilim(ag, cx, y, b1, b0, r + 0.015 + hb * 0.01, r + HALKA - 0.01 - hb2 * 0.02, z, face, on0 - 0.012 + (hb - 0.5) * 0.02,
					tugla_renk(hb, hb2), 0.0)
				s += TUGLA
				if b < 2:
					s += HARC
			s += derz
		else:
			s += derz
	if not tuglali or not dis_halka:
		return
	# dış halka: tek tek tuğla (rowlock), harçla
	var r2 := r + HALKA + 0.01
	var r3 := r2 + 0.16
	var rm2 := (r2 + r3) * 0.5
	var L2 := PI * rm2
	var nb := int(floor((L2 + HARC) / (TUGLA + HARC)))
	var ad := (L2 - float(nb) * TUGLA) / float(maxi(nb - 1, 1))
	var t := 0.0
	for b in nb:
		var hb := _h(sd + float(b) * 0.37, 7.7)
		var hb2 := _h(sd + float(b) * 1.13, 2.9)
		var b0 := t / rm2
		var b1 := (t + TUGLA) / rm2
		_dilim(ag, cx, y, b0, b1, r2, r3 - hb * 0.015, z, face, on0 - 0.018 + (hb2 - 0.5) * 0.016, tugla_renk(hb, hb2), 0.0, -1.0, false)
		t += TUGLA + ad


## Yönlü kemer (kule kapısı vb.): arch_ag'ı yerel z düzleminde kurar, (t, UP, nrm) çerçevesine taşıyıp ag'a ekler. o: kemer
## merkezi (yüz düzleminde), t: yüz boyunca yatay, nrm: yüzün dış normali.
static func arch_yon(ag, o: Vector3, t: Vector3, nrm: Vector3, r: float, depth: float, dis_halka := false) -> void:
	var tmp = KEMER_AG.new()
	arch_ag(tmp, 0.0, 0.0, r, 0.0, 1.0, C_BRICK, depth, 11, dis_halka)
	if tmp.n == 0:
		return
	var m: ArrayMesh = tmp.st.commit()
	var arr := m.surface_get_arrays(0)
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var ns: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
	var cs: PackedColorArray = arr[Mesh.ARRAY_COLOR]
	var b := Basis(t.normalized(), Vector3.UP, nrm.normalized())
	# (t, UP, nrm) sol el çerçevesiyse (yansıma) üçgen sarımı ters çevrilir: ön yüz yine dışa baksın
	var ters := b.determinant() < 0.0
	for i in range(0, vs.size() - 2, 3):
		var sira := [i, i + 2, i + 1] if ters else [i, i + 1, i + 2]
		for j: int in sira:
			ag.st.set_color(cs[j])
			ag.st.set_normal((b * ns[j]).normalized())
			ag.st.add_vertex(o + b * vs[j])
	ag.n += vs.size() / 3


## Lento üstü yazıt/silme şeridi: kesme taş sırası (derzli, taş taş ton ve çıkıntı); eskisi açık renk (e2d6bb) tek levha
static func lento_ag(ag, x0: float, x1: float, y0: float, y1: float, z: float, face: float) -> void:
	var L := x1 - x0
	var nt := maxi(2, int(round(L / 0.85)))
	var w := L / nt
	for i in nt:
		var h := _h(x0 * 3.1 + float(i), y0)
		var a := x0 + w * float(i) + 0.008
		var b := x0 + w * float(i + 1) - 0.008
		var on := 0.04 + 0.02 * h
		var col := tas_renk(h)
		var pz := Vector3(0, 0, face * on)
		var p := 0.015
		var f0 := Vector3(a + p, y0 + p, z) + pz
		var f1 := Vector3(b - p, y0 + p, z) + pz
		var f2 := Vector3(b - p, y1 - p, z) + pz
		var f3 := Vector3(a + p, y1 - p, z) + pz
		ag.quad(f0, f1, f2, f3, Vector3(0, 0, face), col)
		var e := Vector3(0, 0, face * (on - p))
		var g0 := Vector3(a, y0, z) + e
		var g1 := Vector3(b, y0, z) + e
		var g2 := Vector3(b, y1, z) + e
		var g3 := Vector3(a, y1, z) + e
		var dk := col.darkened(0.06)
		ag.quad_auto(g0, g1, f1, f0, Vector3(0, -1, face), dk)
		ag.quad_auto(g1, g2, f2, f1, Vector3(1, 0, face), dk)
		ag.quad_auto(g2, g3, f3, f2, Vector3(0, 1, face), col)
		ag.quad_auto(g3, g0, f0, f3, Vector3(-1, 0, face), dk)
		ag.quad_auto(Vector3(a, y0, z), Vector3(b, y0, z), g1, g0, Vector3.DOWN, dk)
		ag.quad_auto(Vector3(b, y0, z), Vector3(b, y1, z), g2, g1, Vector3.RIGHT, dk)
		ag.quad_auto(Vector3(a, y1, z), Vector3(b, y1, z), g2, g3, Vector3.UP, col)
		ag.quad_auto(Vector3(a, y0, z), Vector3(a, y1, z), g3, g0, Vector3.LEFT, dk)


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
		# TUR-14: dört kemer + lento üstü taş sırası tek ağ (sur taşı gölgelendiricisi; eski 4 × 11 kutu + açık levha)
		var ag = KEMER_AG.new()
		arch_ag(ag, 0.0, gh, r, zi0 - 0.12, -1.0, C_BRICK)
		arch_ag(ag, 0.0, gh, r, zi1 - 0.02, 1.0, C_BRICK)
		arch_ag(ag, 0.0, gh, r, zo1 - 0.02, 1.0, C_BRICK.darkened(0.05))
		arch_ag(ag, 0.0, gh, r, zo0 - 0.12, -1.0, C_BRICK.darkened(0.05))
		# lento üstü yazıt şeridi: kesme taş sırası (eski: açık renk e2d6bb tek levha, 5 cm)
		if IstSurlar._ic(0.0):
			lento_ag(ag, -r - 1.0, r + 1.0, gh + r + 0.7, gh + r + 1.0, zi1, 1.0)
		var kmi: MeshInstance3D = ag.mesh_ekle(root, kemer_mat(), "Tas_KapiKemer")
		if kmi != null:
			kmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if closed:
		# tuğla ile örülmüş geçit: kemer içi tuğla, ortasında küçük sıvalı niş
		IstSurlar._d(root, Vector3(-gw * 0.5, 0, zi1), Vector3(gw * 0.5, gh, zi1 + 0.06), Color("8a4a35"), "brick")
		IstSurlar._d(root, Vector3(-gw * 0.5, 0, zi0 - 0.06), Vector3(gw * 0.5, gh, zi0), Color("8a4a35"), "brick")
		return
	# ---- kuşatma (SUR-4, madde 6): kanatlar KAPALI (iç surda ve dış surun geçidinde), demir bağlı, arkası sürgülü
	# SUR-OYUN: o["kanat_disarida"] verilirse kanatları oynanış parçası (sur_oyun_parca KapiKanat, açılır) kurar
	for zk: float in ([] if o.get("kanat_disarida", false) else [zi0 + 0.45, zo0 + 0.45]):
		var hk := gh - 0.2 if zk < zi1 else minf(gh, OH - 1.0) - 0.2
		# TUR-14: çarpışma eskisinin aynısı (aynı kutu, yalnız çarpışma); görünüş tahta tahta ağ (kanat_ag)
		var tahta = KEMER_AG.new()
		var demir = KEMER_AG.new()
		for sx in [-1.0, 1.0]:
			var xa: float = sx * gw * 0.5
			var lo := Vector3(minf(xa, 0.0), 0.0, zk)
			var hi := Vector3(maxf(xa, 0.0), hk, zk + 0.28)
			var eski_c: bool = IstSurlar.carp_only
			IstSurlar.carp_only = true
			IstSurlar._s(root, lo, hi, C_WOOD, "wood", 0)
			IstSurlar.carp_only = eski_c
			if IstSurlar._ic((lo.x + hi.x) * 0.5):
				kanat_ag(tahta, demir, lo.x, hi.x, hk, zk, 0.28, zk * 3.0 + sx * 7.0)
		# sürgü kirişi (şehir yanında)
		if IstSurlar._ic(0.0):
			tahta.kutu(Vector3(0.0, hk * 0.45, zk + 0.28), Vector3.RIGHT, Vector3.BACK, gw + 0.6, 0.28, 0.22, Color(0.33, 0.26, 0.2), true)
		tahta.mesh_ekle(root, kanat_mat(), "Ahsap_KanatTahta")
		demir.mesh_ekle(root, Props.mat(C_IRON, 0.0, false, ""), "Demir_KanatKusak", false)
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


# ------------------------------------------------------------------ KAPI KANADI (TUR-14)

## Ahşap damarı dokusu (bir kez üretilir): dikey lifler (ince/kalın), hafif dalga, yıllık halka çizgisi, seyrek budak;
## 0,62–1,0 (köşe rengiyle çarpılır)
static var _damar: ImageTexture
static var _kanat_mat: StandardMaterial3D


static func damar_doku() -> ImageTexture:
	if _damar != null:
		return _damar
	var W := 128
	var H := 512
	var img := Image.create(W, H, false, Image.FORMAT_RGB8)
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.seed = 1453
	n.frequency = 0.02
	n.fractal_octaves = 3
	var budak: Array[Vector3] = []
	for k in 5:
		budak.append(Vector3(_h(float(k), 1.0) * W, _h(float(k), 2.0) * H, 3.0 + 4.0 * _h(float(k), 3.0)))
	for y in H:
		for x in W:
			var fx := float(x)
			var fy := float(y)
			var dx := 0.0
			for b: Vector3 in budak:
				var ex := fx - b.x
				var ey := (fy - b.y) * 0.35
				var dd := sqrt(ex * ex + ey * ey)
				if dd < b.z * 3.5:
					dx += (b.z * 3.5 - dd) * signf(ex) * 0.4
			var w := n.get_noise_2d((fx + dx) * 3.2, fy * 0.12)               # iri lif bandı
			var w2 := n.get_noise_2d((fx + dx) * 11.0 + 300.0, fy * 0.35)     # ince lif
			var v := 0.88 + 0.05 * w + 0.06 * w2
			v -= 0.06 * smoothstep(0.55, 0.9, absf(sin((fx + dx + w * 6.0) * 0.55)))   # yıllık halka çizgisi
			for b: Vector3 in budak:
				var ex2 := fx - b.x
				var ey2 := (fy - b.y) * 0.8
				var d2 := sqrt(ex2 * ex2 + ey2 * ey2)
				if d2 < b.z:
					v *= lerpf(0.62, 0.9, d2 / b.z)
			v = clampf(v, 0.62, 1.0)
			img.set_pixel(x, y, Color(v, v * 0.985, v * 0.96))
	img.generate_mipmaps()
	_damar = ImageTexture.create_from_image(img)
	return _damar


## Kanat tahtası malzemesi: Props "wood" toon ayarı (aynı ressam: toon, kenar ışığı, dış çizgi) + köşe rengi + damar dokusu
static func kanat_mat() -> StandardMaterial3D:
	if _kanat_mat != null:
		return _kanat_mat
	_kanat_mat = (Props.mat(Color.WHITE, 0.0, false, "wood") as StandardMaterial3D).duplicate() as StandardMaterial3D
	_kanat_mat.albedo_texture = damar_doku()
	_kanat_mat.vertex_color_use_as_albedo = true
	_kanat_mat.vertex_color_is_srgb = true
	_kanat_mat.uv1_triplanar = true
	_kanat_mat.uv1_world_triplanar = true
	_kanat_mat.uv1_scale = Vector3(2.0, 0.33, 2.0)
	_kanat_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return _kanat_mat


## Kanat (görünen ağ): x0 … x1 arası, y 0 … hk, z zf … zf + dp (zf = demir kuşaklı yüz). Dikey tahtalar (≈ 27 cm, 8 mm
## aralık, arkada koyu dolgu), tahtadan tahtaya ton (yıpranmış meşe: gri-kahve; eski tek ton turuncu 7a5634: Props.mat köşe
## rengini okumuyordu, tahta ayrımı görünmüyordu) ve 0–8 mm çıkıntı; üç demir kuşak (yer ve ölçü eskisi) + kuşakta tahta
## başına iki çivi başı, kuşak aralarında perçin çivileri. tahta/demir: sur_kule Ag. sd: tohum.
static func kanat_ag(tahta, demir, x0: float, x1: float, hk: float, zf: float, dp: float, sd: float, kusak := true) -> void:
	var w := x1 - x0
	var n := maxi(2, int(round(w / 0.27)))
	var pw := w / n
	var gap := 0.008
	# dolgu (tahta aralıklarında görünen koyu iç kat)
	tahta.kutu(Vector3((x0 + x1) * 0.5, 0.0, zf + 0.025), Vector3.RIGHT, Vector3.BACK, w - 0.004, hk - 0.004, dp - 0.05,
		Color(0.22, 0.17, 0.13))
	for i in n:
		var h := _h(sd + float(i), 4.2)
		var h2 := _h(sd + float(i) * 1.9, 8.8)
		var col := Color(0.41 + 0.04 * h, 0.345 + 0.035 * h, 0.285 + 0.03 * h)
		if h2 > 0.82:
			col = Color(0.43, 0.39, 0.345)           # güneşte grileşmiş tahta
		elif h2 < 0.14:
			col = Color(0.36, 0.295, 0.245)          # yağ/is koyusu
		var on := 0.008 * h2
		var arka := 0.006 * h
		var ust := hk - 0.012 * h
		tahta.kutu(Vector3(x0 + pw * (float(i) + 0.5), 0.0, zf - on), Vector3.RIGHT, Vector3.BACK, pw - gap, ust, dp + on + arka, col)
	if not kusak:
		return
	var ys: Array = [0.7, hk * 0.5, hk - 0.7]
	for yy: float in ys:
		demir.kutu(Vector3((x0 + x1) * 0.5, yy, zf - 0.03), Vector3.RIGHT, Vector3.BACK, w - 0.2, 0.14, 0.03)
		for i in n:
			var cx := x0 + pw * (float(i) + 0.5)
			if cx < x0 + 0.12 or cx > x1 - 0.12:
				continue
			for dy: float in [0.035, 0.105]:
				_civi(demir, Vector3(cx + (dy - 0.07) * 0.6, yy + dy, zf - 0.03), 0.019, 0.016)
	# kuşak aralarında perçin çivileri (tahta başına bir, iki yükseklikte)
	for k in 2:
		var ya: float = lerpf(float(ys[k]) + 0.14, float(ys[k + 1]), 0.5)
		for i in n:
			var cx2 := x0 + pw * (float(i) + 0.5)
			_civi(demir, Vector3(cx2, ya, zf - 0.008 * _h(sd + float(i) * 1.9, 8.8)), 0.017, 0.014)


## Dövme çivi başı: −z yüzüne oturan dört yüzlü piramit (yarı en hw, çıkıntı h); 4 üçgen
static func _civi(demir, c: Vector3, hw: float, h: float) -> void:
	var a := c + Vector3(-hw, -hw, 0)
	var b := c + Vector3(hw, -hw, 0)
	var d := c + Vector3(hw, hw, 0)
	var e := c + Vector3(-hw, hw, 0)
	var t := c + Vector3(0, 0, -h)
	demir.tri(a, b, t, Vector3(0, -1, -1))
	demir.tri(b, d, t, Vector3(1, 0, -1))
	demir.tri(d, e, t, Vector3(0, 1, -1))
	demir.tri(e, a, t, Vector3(-1, 0, -1))
