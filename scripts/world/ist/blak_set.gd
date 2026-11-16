extends RefCounted
## TAŞIMA-9: BLAKHERNA SETİ — görünüş kalemi (çarpışmasız), şehir (IstSehir._blakherna_wall) ile bölüm sahnesinin
## (Blachernae, Bölüm 30 ve 30o) ORTAK ressamı. Ölçüler Blachernae'nin eski kabuğuyla aynı (Blachernae.WALL_Z0/Z1, WALL_H,
## WALK_Y, TOWERS); çarpışma her iki yerde de eski kabuğun kutularıdır (bu dosya çarpışma KURMAZ).
##
## Kalem (tur 9 `_blakherna_wall` + tur 10–13 yakın kamera düzeltmeleri, Mesoteikhion'la aynı):
##   · sur gövdesi: dipte gömülü temel + kaide basamağı + şevli dış yüz, sur taşı gölgelendiricisi (blok + tuğla hatıl;
##     sur_doku.uygula "ashlar" yüzeyi çevirir)
##   · yürüme yolunun dış kenarında korkuluk (ince taş örgü: köşe alfası 0,9, tuğla hatılsız; TUR-11) + KULE.disler_ag
##     dişleri (taş örgü gövde, eşek sırtı harpuşta, 2 cm saçak; TUR-11/12/13)
##   · kuleler: Mesoteikhion iç kulesi (KULE.ic_kule: pahlı plan, şev, silme, ok yarıkları, tepe korkuluğu, dişler)
##   · sur dibinde düşmüş taş (kaya ağı, sur kuşağının taş malzemesi)
## Bölüme özgü: iç taş merdiven (rampa çarpışmasının üstünde basamaklı, altı dolu taş kütle; havada değil), zemin (sur
## kuşağının zemin dili: sur_gorunus._levha) ve zemin sorgusu (zemin_y). class_name YOK (preload/load ile).

const SURKULE := preload("res://scripts/world/ist/sur_kule.gd")
const GOR := preload("res://scripts/world/ist/sur_gorunus.gd")
const OTAG := preload("res://scripts/world/ist/sur_oturtma_ag.gd")

const Z0 := 0.0
const Z1 := 4.6
const H := 12.0
const W := 12.0
const TOWERS := [-40.0, -20.0, 20.0, 40.0]
const STONE := Color("c8b89a")
## korkuluk (yürüme yolunun dış kenarı): 0,6 m kalın, 0,5 m yüksek; dişler 0,6 m (tepe WALK_Y + 1,1 = eski diş tepesi)
const PT := 0.6
const PH := 0.5
## diş dizisi (eski kabukla aynı yerler): x = DIS_X0 + k · DIS_ADIM, en 1,1
const DIS_X0 := -59.0
const DIS_ADIM := 1.9
const DIS_EN := 1.1


## Sur gövdesi (x0…x1) + kuleler + sur dibi taşı. opt: "tohum_L" (şehir: dilim boyu; tohumlar eskisiyle aynı), "kuleler"
## (x listesi; varsayılan TOWERS), "dip_tas" (bool, varsayılan true), "korkuluk" (bool: korkuluk aynı ağda + dişler; şehir).
## Bölüm korkuluğu ayrı kurar (korkuluk_dis): merdiven yerlerini sonra bildirir.
static func sur(n: Node3D, x0: float, x1: float, lod: int, opt := {}) -> void:
	var L := x1 - x0
	var tl: float = opt.get("tohum_L", L)
	var ag = SURKULE.Ag.new()
	# dış yüz profili (y, dışa öteleme): gömülü temel, kaide basamağı, şev, düz gövde
	var prof := [[-1.6, 0.55], [0.0, 0.55], [0.0, 0.42], [0.9, 0.42], [0.9, 0.28], [3.2, 0.0], [H, 0.0]]
	if lod > 0:
		prof = [[-1.6, 0.3], [2.4, 0.0], [H, 0.0]]
	for k in prof.size() - 1:
		var ya: float = prof[k][0]
		var yb: float = prof[k + 1][0]
		var oa: float = prof[k][1]
		var ob: float = prof[k + 1][1]
		if absf(yb - ya) < 0.001:
			ag.quad(Vector3(x0, ya, Z1 + ob), Vector3(x1, ya, Z1 + ob), Vector3(x1, ya, Z1 + oa), Vector3(x0, ya, Z1 + oa), Vector3.UP)
		else:
			var nr := Vector3(0, oa - ob, yb - ya).normalized()
			ag.quad(Vector3(x0, ya, Z1 + oa), Vector3(x1, ya, Z1 + oa), Vector3(x1, yb, Z1 + ob), Vector3(x0, yb, Z1 + ob), nr)
	# iç yüz (şehir), tepe (yürüme yolu), uçlar (komşu dilime kavuşur: uç yüzler yalnız kaide çıkıntısını kapatır)
	ag.quad(Vector3(x0, -1.6, Z0), Vector3(x1, -1.6, Z0), Vector3(x1, H, Z0), Vector3(x0, H, Z0), Vector3.FORWARD)
	ag.quad(Vector3(x0, H, Z0), Vector3(x1, H, Z0), Vector3(x1, H, Z1), Vector3(x0, H, Z1), Vector3.UP)
	for sx: float in [-1.0, 1.0]:
		var xe := x1 if sx > 0.0 else x0
		for k in prof.size() - 1:
			var ya2: float = prof[k][0]
			var yb2: float = prof[k + 1][0]
			var oa2: float = prof[k][1]
			var ob2: float = prof[k + 1][1]
			if oa2 < 0.01 and ob2 < 0.01:
				continue
			ag.quad(Vector3(xe, ya2, Z1), Vector3(xe, yb2, Z1), Vector3(xe, yb2, Z1 + ob2), Vector3(xe, ya2, Z1 + oa2), Vector3(sx, 0, 0))
	var korkuluk: bool = opt.get("korkuluk", false)
	if korkuluk:
		_korkuluk_ag(ag, x0, x1, [])
	ag.mesh_ekle(n, SURKULE._tas_mat(STONE, lod), "BlakhernaSur")
	if korkuluk and lod == 0:
		_disler(n, x0, x1, int(absf(tl * 13.0)), [], [])
	# kuleler: Mesoteikhion iç kulesi, kabuktaki kutu kulenin ölçüsünde (8 × 8 m, z Z1−2,4 … Z1+5,6, tepe WALL_H + 5)
	var kl: Array = opt.get("kuleler", TOWERS)
	for i in TOWERS.size():
		var tx: float = TOWERS[i]
		if not tx in kl or tx - 4.0 < x0 - 0.01 or tx + 4.0 > x1 + 0.01:
			continue
		kule(n, {"cx": tx, "w": 8.0, "zb": Z1 - 2.4, "zf": Z1 + 5.6, "zi1": Z1, "yf": W + 0.03, "HT": H + 5.0,
			"yc": H + 4.5, "tur": 0, "tohum": 1305 + i * 31, "hasar": 0.6, "kapi_z0": Z1 - 2.1, "kapi_z1": Z1 - 0.3,
			"cati": false, "yazit": false, "tas": STONE}, lod)
	# sur dibi: dökülmüş taş (yalnız yakın)
	if lod == 0 and opt.get("dip_tas", true):
		var rng := RandomNumberGenerator.new()
		rng.seed = int(absf(tl * 7.0)) + 53
		var tas: Array = []
		for k in int(L / 6.0):
			var px := rng.randf_range(x0 + 1.0, x1 - 1.0)
			var sc := rng.randf_range(0.25, 0.6)
			tas.append(Transform3D(Basis.from_euler(Vector3(rng.randf() * 2.0, rng.randf() * 6.0, 0.3)).scaled(Vector3(sc * 1.3, sc * 0.7, sc)), Vector3(px, sc * 0.12, Z1 + 0.8 + rng.randf_range(0.0, 2.2))))
		if not tas.is_empty():
			Scenery.scatter(n, SURKULE.kaya_mesh(), tas, [], GOR.kaya_tas_mat())


## Yürüme yolunun dış korkuluğu (0,6 × 0,5 m, ince taş örgü) ve dişleri. kes: korkuluğun olmadığı x aralıkları (Vector2;
## merdivenin sur yoluna açıldığı mazgal); dissiz: bu x'leri örten diş kurulmaz (merdiven tepesi dişe dayanmasın).
## Diş yerleri eski kabuğun "merl" dizisi (−59 + 1,9 k), yer yer eksik (tur 9 kuralı). tohum: şehirde dilim boyu × 13.
static func korkuluk_dis(n: Node3D, x0: float, x1: float, lod: int, tohum: int, kes: Array = [], dissiz: Array = []) -> void:
	var ag = SURKULE.Ag.new()
	_korkuluk_ag(ag, x0, x1, kes)
	ag.mesh_ekle(n, SURKULE._tas_mat(STONE, lod), "BlakhernaKorkuluk")
	if lod == 0:
		_disler(n, x0, x1, tohum, kes, dissiz)


## TUR-11 kuralı: korkuluk köşe alfası 0,9 → sur_doku ince taş örgü (0,2 m sıra, tuğla hatılsız; göz hizasında hatıl yok)
static func _korkuluk_ag(ag, x0: float, x1: float, kes: Array) -> void:
	var orgu := Color(1, 1, 1, 0.9)
	var parca: Array = [Vector2(x0, x1)]
	for k: Vector2 in kes:
		var yeni: Array = []
		for p: Vector2 in parca:
			if k.y <= p.x or k.x >= p.y:
				yeni.append(p)
				continue
			if k.x > p.x:
				yeni.append(Vector2(p.x, k.x))
			if k.y < p.y:
				yeni.append(Vector2(k.y, p.y))
		parca = yeni
	for p: Vector2 in parca:
		if p.y - p.x < 0.05:
			continue
		ag.kutu(Vector3((p.x + p.y) * 0.5, W, Z1 - PT), Vector3.RIGHT, Vector3.BACK, p.y - p.x, PH, PT, orgu)


static func _disler(n: Node3D, x0: float, x1: float, tohum: int, kes: Array, dissiz: Array) -> void:
	var hx := maxf(absf(x0), absf(x1))
	var mer: Array = []
	var xx := DIS_X0
	while xx < -DIS_X0:
		var ac := false
		for dx: float in dissiz:
			if absf(xx - dx) < DIS_EN * 0.5 + 0.3:
				ac = true
		for k: Vector2 in kes:
			# 1 cm pay: xx 1,9'luk toplamayla birikir (11,3 → 11,2999); aralığın kenarındaki diş yanlışlıkla atılıyordu
			if xx + DIS_EN * 0.5 > k.x + 0.01 and xx - DIS_EN * 0.5 < k.y - 0.01:
				ac = true
		if not ac and absf(xx) + 0.5 < hx and absf(fposmod(xx * 0.37 + 4.6, 11.0)) >= 0.8:
			mer.append(Transform3D(Basis.from_scale(Vector3(DIS_EN, 0.6, PT)), Vector3(xx, W + PH + 0.3, Z1 - PT * 0.5)))
		xx += DIS_ADIM
	SURKULE.disler_ag(n, mer, STONE.darkened(0.04), tohum)


## Merdivenin (x) sur yoluna açıldığı mazgal aralığı: x'in düştüğü iki diş arası (dişin üstüne düşüyorsa o dişin yeri).
static func mazgal_araligi(x: float) -> Vector2:
	var k := floorf((x - DIS_X0) / DIS_ADIM)
	var a := DIS_X0 + k * DIS_ADIM + DIS_EN * 0.5           # soldaki dişin sağ kenarı
	var b := DIS_X0 + (k + 1.0) * DIS_ADIM - DIS_EN * 0.5   # sağdaki dişin sol kenarı
	if x < a:
		return Vector2(a - DIS_EN, a)                        # dişin üstünde: o dişin yeri
	if x > b:
		return Vector2(b, b + DIS_EN)
	return Vector2(a, b)


## Kule: KULE.ic_kule görünüşü; kendi çarpışması atılır (kabuğun kutusu kalır, ölçü aynı)
static func kule(n: Node3D, g: Dictionary, lod: int) -> void:
	var tmp := Node3D.new()
	SURKULE.ic_kule(tmp, g, lod)
	for c in tmp.get_children():
		tmp.remove_child(c)
		if c is CollisionObject3D:
			c.free()
		else:
			n.add_child(c)
	tmp.free()


## İç taş merdiven (rampa lo → hi, en w): çarpışma rampası yerinde kalır; görünüş basamaklı taş merdiven ve altını dolduran
## taş kütle (basamak basamak zemine iner: havada merdiven yok). Basamak burnu rampa düzleminin rıht/2 üstünde, ardı rıht/2
## altında (yürüyen ayak rampada ±rıht/2). Kütlenin sur tarafı iç yüze (z0) yaslanır.
static func merdiven(n: Node3D, lo: Vector3, hi: Vector3, w: float, lod: int) -> void:
	var yat := Vector3(hi.x - lo.x, 0, hi.z - lo.z)
	var boy := yat.length()
	var u := yat / boy                       # yatay ilerleme
	var v := Vector3(-u.z, 0, u.x)           # yan
	var rise := hi.y - lo.y
	var nb := maxi(8, int(ceil(rise / 0.26)))
	var r := rise / nb
	var t := boy / nb
	var ag = SURKULE.Ag.new()
	var orgu := Color(1, 1, 1, 0.9)          # basamak taşları ince örgü (TUR-11)
	for i in nb:
		var a := lo + u * (t * i)
		var y_ust := lo.y + r * (i + 0.5)    # basamak üstü: rampa çizgisinin ortalaması
		var p0 := a - v * w * 0.5
		var p1 := a + v * w * 0.5
		# son basamak sur gövdesine 2,5 m girer: çapraz merdivenin ucuyla iç yüz arasında üçgen boşluk kalmasın
		var tt := t + (2.5 if i == nb - 1 else 0.0)
		var q0 := p0 + u * tt
		var q1 := p1 + u * tt
		# basamak üstü
		ag.quad(Vector3(p0.x, y_ust, p0.z), Vector3(p1.x, y_ust, p1.z), Vector3(q1.x, y_ust, q1.z), Vector3(q0.x, y_ust, q0.z), Vector3.UP, orgu)
		# rıht (önceki basamaktan bu basamağa)
		var y_alt := lo.y + r * (i - 0.5) if i > 0 else lo.y - 0.3
		ag.quad(Vector3(p0.x, y_alt, p0.z), Vector3(p1.x, y_alt, p1.z), Vector3(p1.x, y_ust, p1.z), Vector3(p0.x, y_ust, p0.z), -u, orgu)
		# yan yüzler: basamağın altından zemine (dolu kütle; temel 0,3 m gömülü)
		for s: float in [-1.0, 1.0]:
			var e0 := a + v * w * 0.5 * s
			var e1 := e0 + u * tt
			ag.quad(Vector3(e0.x, lo.y - 0.3, e0.z), Vector3(e1.x, lo.y - 0.3, e1.z), Vector3(e1.x, y_ust, e1.z), Vector3(e0.x, y_ust, e0.z), v * s)
	ag.mesh_ekle(n, SURKULE._tas_mat(STONE.darkened(0.06), lod), "BlakhernaMerdiven")


## Görünen zemin (sur kuşağının zemin dili: sur_gorunus._levha; zemin_v2 gölgelendiricisi, yamalı kuru ot / çıplak
## toprak, sura doğru taş tozu, ±1,6 cm engebe; ot tutamları). Çarpışma bölümün düz levhalarıdır (yükseklik aynı).
## yuz_z: sur yüzlerinin z'leri (taş tozu ve dip kararması için). Levha z0 kenarından 2,5 m'lik satırlarla sıklaşır.
static func zemin(n: Node3D, x0: float, x1: float, z0: float, z1: float, y: float, yuz_z: Array, ad: String) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ot: Array = []
	GOR._levha(st, x0, x1, z0, z1, y, 0, yuz_z, ot)
	var mi := MeshInstance3D.new()
	mi.name = ad
	mi.mesh = st.commit()
	mi.material_override = OTAG.etek_malzeme()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.set_meta("no_walk", true)
	n.add_child(mi)
	GOR._ortu(n, ot)


## Görünen zeminin yüksekliği (sur_gorunus._levha'nın levha içi engebesi, uzat 0): ±1,6 cm. Çarpışma düz (y 0).
static func zemin_y(x: float, z: float) -> float:
	return (GOR.gn(x, z, 5.0, 7) - 0.5) * 0.032


## Çizim bütçesi: kökün altındaki görünen ağları MALZEMEYE göre tek ağda birleştirir (aynı malzeme nesnesi = tek çizim;
## kule taşları, korkuluk, merdiven, saray kutuları, ışıklı pencereler kendi malzemeleriyle). Katı gövdenin çocuğu olan ağ
## kaldırılırsa gövde "görünür katı" sayılır (meta "wall": Unclip/düellocu düşüşü eskisi gibi). Kişi, çoklu ağ, özel sınır
## kutulu (kumaş) ve yalnız-çarpışma düğümleri dokunulmaz. Dönen: birleştirilen ağ sayısı.
static func birlestir(root: Node3D, ad: String) -> int:
	var gruplar := {}
	var sira: Array = []
	var say := 0
	for c in root.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree() or mi.has_meta("birlesik") or mi.mesh.custom_aabb.size != Vector3.ZERO:
			continue
		var rel := Transform3D.IDENTITY
		var q: Node = mi
		var atla := false
		while q != null and q != root:
			if q is Person or q is MultiMeshInstance3D:
				atla = true
				break
			if q is Node3D:
				rel = (q as Node3D).transform * rel
			q = q.get_parent()
		if atla or q == null:
			continue
		# mekânsal hücre (x 32 m, z iç/dış): birleşik ağ görüşte değilse kesilsin (ilkel bütçesi; tek 130 m'lik ağ her açıda
		# bütün kuleleri ve gölge geçişlerini çiziyordu)
		var mc := rel * mi.mesh.get_aabb().get_center()
		var hucre := "%d|%d" % [floori(mc.x / 32.0), 0 if mc.z < -8.0 else 1]
		for si in mi.mesh.get_surface_count():
			var m: Material = mi.get_active_material(si)
			if m == null:
				continue
			var k := "%d|%d|%s" % [m.get_instance_id(), int(mi.cast_shadow), hucre]
			if not gruplar.has(k):
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				gruplar[k] = [st, m, mi.cast_shadow]
				sira.append(k)
			(gruplar[k][0] as SurfaceTool).append_from(mi.mesh, si, rel)
		var p := mi.get_parent()
		if p is StaticBody3D:
			p.set_meta("wall", true)
		p.remove_child(mi)
		mi.queue_free()
		say += 1
	var i := 0
	for k: String in sira:
		var g: Array = gruplar[k]
		var yeni := MeshInstance3D.new()
		yeni.name = "%s_%d" % [ad, i]
		yeni.mesh = (g[0] as SurfaceTool).commit()
		yeni.material_override = g[1]
		yeni.cast_shadow = g[2]
		yeni.set_meta("birlesik", true)
		yeni.set_meta("no_walk", true)
		root.add_child(yeni)
		i += 1
	return say
