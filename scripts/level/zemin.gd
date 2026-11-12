extends RefCounted
## ZEMİN: oyunun ortak zemin kitaplığı (class_name YOK; kullanım: const Zemin = preload("res://scripts/level/zemin.gd")).
## Tek malzeme ailesi (assets/shaders/zemin.gdshader), parametreyle yöreye uyar:
##   Zemin.malzeme()                      → paylaşılan ShaderMaterial (Nature.ground_material() bunu döndürür)
##   Zemin.yore(ad)                       → yöre paleti: "trakya" (varsayılan), "ordugah", "kusatma", "kiyi", "sehir",
##                                          "kurak", "kar"; Zemin.ayarla({"kuruluk": 0.5, "su_y": 0.0, ...})
##   Aşınma maskesi (yol, patika, çiğnenmiş alan, tekerlek izi, ocak isi, hendek kenarı, yapı dibi teması):
##     var a := Zemin.asinma_baslat(sahip_dugum, Rect2(x0, z0, en, boy), 0.5)   # 0,5 m/piksel
##     Zemin.asinma_cizgi(a, Vector2(x, z), Vector2(x2, z2), 3.0, Zemin.YOL)     # en 3 m'lik yol
##     Zemin.asinma_daire(a, Vector2(x, z), 4.0, Zemin.YOL, 0.8)                  # çiğnenmiş alan
##     Zemin.asinma_daire(a, ocak, 1.2, Zemin.IS)                                # ocak isi
##     Zemin.asinma_kutu(a, merkez, Vector2(yarı_en, yarı_boy), açı, 1.2)        # yapı dibi temas + toprak eteği
##     Zemin.asinma_uygula(a)                                                    # dokuya yazar, malzemeye bağlar
##   Sahip düğüm ağaçtan çıkınca maske kendiliğinden kapanır (bölüm değişince eski maske kalmaz).
##   Yer örtüsü (ot tutamı, papatya/gelincik öbeği, yuvarlak taş, kuru dal, su birikintisi; MultiMesh, çarpışmasız,
##   oyuncunun 48 m çevresinde akışlı; yolda/çiğnenmiş alanda yok):
##     Zemin.ortu_ekle(ebeveyn, Rect2 alan, yukseklik: Callable(x, z) -> y, renk: Callable(x, z) -> Color (ipucu))

const YOL := 0       # R: yol / patika / çiğnenmiş (ot kalkar, sıkışık toprak)
const CAMUR := 1     # G: çamur / tekerlek izi / hendek kenarı
const IS := 2        # B: ocak isi, yanık
const TEMAS := 3     # A: yapı dibi temas kararması + toprak eteği

const YORELER := {
	"trakya": {"c_ot": Color("5b6d2d"), "c_ot2": Color("475c25"), "c_kuru": Color("8a7f4b"), "c_toprak": Color("765a3d"),
		"c_camur": Color("433526"), "c_cakil": Color("8a8272"), "c_kum": Color("b29f7e"), "c_kaya": Color("7a7468"),
		"kuruluk": 0.36, "cignenme": 0.0},
	"ordugah": {"c_ot": Color("5b6b2e"), "c_ot2": Color("4a5a25"), "c_kuru": Color("8c7f4c"), "c_toprak": Color("76593b"),
		"c_camur": Color("423325"), "c_cakil": Color("888070"), "c_kum": Color("b09c7c"), "c_kaya": Color("7a7468"),
		"kuruluk": 0.5, "cignenme": 0.4},
	"kusatma": {"c_ot": Color("5a6831"), "c_ot2": Color("495628"), "c_kuru": Color("867c51"), "c_toprak": Color("6e533a"),
		"c_camur": Color("3d3027"), "c_cakil": Color("847c70"), "c_kum": Color("ac9a7c"), "c_kaya": Color("767066"),
		"kuruluk": 0.5, "cignenme": 0.45},
	"kiyi": {"c_ot": Color("596d32"), "c_ot2": Color("465d29"), "c_kuru": Color("8e8355"), "c_toprak": Color("786148"),
		"c_camur": Color("42352a"), "c_cakil": Color("8e877a"), "c_kum": Color("b8a684"), "c_kaya": Color("7e786e"),
		"kuruluk": 0.3, "cignenme": 0.1},
	"sehir": {"c_ot": Color("596b34"), "c_ot2": Color("475a2e"), "c_kuru": Color("887e55"), "c_toprak": Color("786146"),
		"c_camur": Color("43392c"), "c_cakil": Color("8e8676"), "c_kum": Color("b09e80"), "c_kaya": Color("807a70"),
		"kuruluk": 0.42, "cignenme": 0.35},
	"kurak": {"c_ot": Color("666d36"), "c_ot2": Color("555c2e"), "c_kuru": Color("93844f"), "c_toprak": Color("7d6041"),
		"c_camur": Color("46392b"), "c_cakil": Color("8e8574"), "c_kum": Color("b6a27e"), "c_kaya": Color("7e776a"),
		"kuruluk": 0.62, "cignenme": 0.2},
	"kar": {"c_ot": Color("53613a"), "c_ot2": Color("455330"), "c_kuru": Color("7d7553"), "c_toprak": Color("614c3b"),
		"c_camur": Color("372f28"), "c_cakil": Color("807c76"), "c_kum": Color("9e978a"), "c_kaya": Color("706c68"),
		"kuruluk": 0.3, "cignenme": 0.3, "kar": 0.62},
}

static var _mat: ShaderMaterial
static var _gurultu: Texture2D
static var _gimg: Image


static func malzeme() -> ShaderMaterial:
	if _mat == null:
		_mat = ShaderMaterial.new()
		_mat.shader = load("res://assets/shaders/zemin.gdshader")
		_gurultu = load("res://assets/textures/zemin_gurultu.png")
		_mat.set_shader_parameter("gurultu", _gurultu)
		_yore_uygula("trakya")
	return _mat


## Yöre paleti (tablo: YORELER). Paylaşılan malzemeye yazılır: bölüm kurulurken çağrılır.
static func yore(ad: String, sahip: Node = null, ek := {}) -> void:
	if sahip != null:
		sahip.tree_exiting.connect(func() -> void: yore("trakya"), CONNECT_ONE_SHOT)
	_yore_uygula(ad)
	ayarla(ek)


static func _yore_uygula(ad: String) -> void:
	var m := malzeme()
	var y: Dictionary = YORELER.get(ad, YORELER["trakya"])
	for k: String in ["kuruluk", "cignenme", "kar"]:
		m.set_shader_parameter(k, 0.0)
	m.set_shader_parameter("su_y", -10000.0)
	ayarla(y)


static func ayarla(p: Dictionary) -> void:
	var m := malzeme()
	for k: String in p.keys():
		m.set_shader_parameter(k, p[k])


## Bölüme özel kopya (başka bölümde paylaşılan malzemeyi bozmadan farklı yöre: örn. v2 dünyası).
static func kopya(ad: String) -> ShaderMaterial:
	var m := malzeme().duplicate() as ShaderMaterial
	var y: Dictionary = YORELER.get(ad, YORELER["trakya"])
	for k: String in y.keys():
		m.set_shader_parameter(k, y[k])
	return m


## Yama türevi (köşe rengi olmayan düzlem yamalar: çayır, sazlık, kum, patika): ipucu rengi uniform'dan, kenarı
## gürültüyle erir (alfa makası; keskin dikdörtgen kenar kalmaz). Döner: ShaderMaterial (yöre: trakya).
static var _yama_sh: Shader
static func yama_malzeme(ipucu: Color, boyut: Vector2, kenar := 2.0) -> ShaderMaterial:
	if _yama_sh == null:
		var base: Shader = load("res://assets/shaders/zemin.gdshader")
		_yama_sh = Shader.new()
		_yama_sh.code = base.code.replace("//YAMA_KENAR", "{ vec2 e = min(UV, 1.0 - UV) * yama_boyut; float ed = min(e.x, e.y);\n" +
			"\tALPHA = smoothstep(0.0, 1.0, ed / max(yama_kenar, 0.01) + (W.x - 0.5) * 1.1 + (T.y - 0.5) * 0.3);\n" +
			"\tALPHA_SCISSOR_THRESHOLD = 0.5; }")
	var m := kopya("trakya")
	m.shader = _yama_sh
	m.set_shader_parameter("ipucu", ipucu)
	m.set_shader_parameter("yama_boyut", boyut)
	m.set_shader_parameter("yama_kenar", minf(kenar, minf(boyut.x, boyut.y) * 0.3))
	return m


## Kutu biçimli zemin parçası (set, peribolos, hendek dibi gibi Props.solid levhaları): düz boyalı levha yerine ortak
## zemin; ipucu rengi tür seçer (kahve: toprak, koyu: çamur, gri: taşlık). Döner: aynı düğüm.
static var _kutu_mat := {}
static func kutu_zemin(sahip: Node, ipucu: Color, yore_ad := "kusatma", ek := {}) -> Node:
	var key := "%s|%s|%s" % [ipucu.to_html(), yore_ad, str(ek)]
	var m: ShaderMaterial = _kutu_mat.get(key)
	if m == null:
		m = kopya(yore_ad)
		m.set_shader_parameter("ipucu", ipucu)
		for k: String in ek.keys():
			m.set_shader_parameter(k, ek[k])
		_kutu_mat[key] = m
	for n in ([sahip] + sahip.find_children("*", "MeshInstance3D", true, false)):
		if n is MeshInstance3D:
			(n as MeshInstance3D).material_override = m
	return sahip


## v2 dünyasının arazi malzemesi (IstDunya kullanır; tek örnek). Deniz seviyesi v2'nin kendi uzayında 0. Maske v2'nin
## kendi uzayında (asinma_yerel): ORDUGÂH/SUR-4 yolları ve çiğnenmiş alanları buraya boyar (bkz. v2_asinma).
static var _v2: ShaderMaterial
static func v2_malzeme() -> ShaderMaterial:
	if _v2 == null:
		_v2 = kopya("trakya")
		_v2.set_shader_parameter("su_y", 0.0)
		_v2.set_shader_parameter("asinma_yerel", 1.0)
	return _v2


## v2 aşınma maskesi (paylaşılan): sur dışı + ordugâh kuşağı (gerçek doğu −9570…−4710, kuzey −1500…3570), v2 yerel
## x-z (dünya m: x = e·S, z = −n·S), 1 m/piksel. Herkes aynı sözlüğe
## boyar, sonunda asinma_uygula(Zemin.v2_asinma()) çağırır. alan: v2 yerel dikdörtgen (ilk çağıranınki geçerli).
static var _v2a: Dictionary = {}
static func v2_asinma(alan := Rect2(-3350.0, -1250.0, 1700.0, 1800.0), m_px := 1.0) -> Dictionary:
	if _v2a.is_empty():
		_v2a = asinma_baslat(null, alan, m_px, v2_malzeme())
	return _v2a


## Taş döşeme/kaldırım (Props "cobble" desenli StandardMaterial3D): malzeme türü aynı kalır (ıslaklık kodu onu bekler);
## dünya uzayında ayrıntı katmanı eklenir: 2–10 m'lik kir/aşınma lekeleri, derzlerde koyulaşma, sıcak ton (düz,
## yinelenen soğuk gri desen kırılır). Döner: aynı malzeme.
static var _kir: ImageTexture
static func doseme_kir(m: StandardMaterial3D) -> StandardMaterial3D:
	if _kir == null:
		malzeme()
		var src := _gurultu.get_image()
		if src.is_compressed():
			src.decompress()
		var n := src.get_width()
		var img := Image.create(n, n, false, Image.FORMAT_RGB8)
		for y in n:
			for x in n:
				var c := src.get_pixel(x, y)
				var c2 := src.get_pixel((x * 3 + 17) % n, (y * 3 + 41) % n)
				var k := 0.8 + 0.24 * (c.r * 0.65 + c2.g * 0.35) - 0.1 * smoothstep(0.62, 0.8, c2.r)
				img.set_pixel(x, y, Color(k * 1.03, k * 1.0, k * 0.9))
		img.generate_mipmaps()
		_kir = ImageTexture.create_from_image(img)
	m.detail_enabled = true
	m.detail_blend_mode = BaseMaterial3D.BLEND_MODE_MUL
	m.detail_albedo = _kir
	m.detail_uv_layer = BaseMaterial3D.DETAIL_UV_2
	m.uv2_triplanar = true
	m.uv2_world_triplanar = true
	m.uv2_scale = Vector3(1.0 / 13.0, 1.0 / 13.0, 1.0 / 13.0)
	return m


## Düğümün (Props.solid/box) döşeme malzemesini kopyalayıp doseme_kir uygular (paylaşılan desen malzemesi bozulmaz).
static func doseme_kir_dugum(sahip: Node) -> Node:
	for n in ([sahip] + sahip.find_children("*", "MeshInstance3D", true, false)):
		if n is MeshInstance3D and (n as MeshInstance3D).material_override is StandardMaterial3D:
			var mi := n as MeshInstance3D
			mi.material_override = doseme_kir((mi.material_override as StandardMaterial3D).duplicate())
	return sahip


# ------------------------------------------------------------------ aşınma maskesi

static func asinma_baslat(sahip: Node, alan: Rect2, m_px := 0.5, mat: ShaderMaterial = null) -> Dictionary:
	var w := clampi(int(ceil(alan.size.x / m_px)), 4, 2048)
	var h := clampi(int(ceil(alan.size.y / m_px)), 4, 2048)
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var a := {"img": img, "alan": alan, "px": Vector2(w / alan.size.x, h / alan.size.y), "mat": mat if mat else malzeme()}
	if sahip:
		var mm: ShaderMaterial = a["mat"]
		sahip.tree_exiting.connect(func() -> void: mm.set_shader_parameter("asinma_acik", 0.0), CONNECT_ONE_SHOT)
	return a


## Yumuşak kenarlı fırça (merkezde guc, kenarda 0); kanal değeri en büyüğü alır.
static func _firca(a: Dictionary, c: Vector2, r: float, kanal: int, guc: float) -> void:
	var img: Image = a["img"]
	var alan: Rect2 = a["alan"]
	var px: Vector2 = a["px"]
	var cx := (c.x - alan.position.x) * px.x
	var cy := (c.y - alan.position.y) * px.y
	var rx := maxf(r * px.x, 0.75)
	var ry := maxf(r * px.y, 0.75)
	var x0 := maxi(int(cx - rx - 1), 0)
	var x1 := mini(int(cx + rx + 1), img.get_width() - 1)
	var y0 := maxi(int(cy - ry - 1), 0)
	var y1 := mini(int(cy + ry + 1), img.get_height() - 1)
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var d := Vector2((x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry).length()
			if d >= 1.0:
				continue
			var v := guc * (1.0 - smoothstep(0.45, 1.0, d))
			var col := img.get_pixel(x, y)
			if v > col[kanal]:
				col[kanal] = v
				img.set_pixel(x, y, col)


static func asinma_daire(a: Dictionary, c: Vector2, r: float, kanal := YOL, guc := 1.0) -> void:
	_firca(a, c, r, kanal, guc)


static func asinma_cizgi(a: Dictionary, p0: Vector2, p1: Vector2, en: float, kanal := YOL, guc := 1.0) -> void:
	var px: Vector2 = a["px"]
	var adim := maxf(0.5 / maxf(px.x, px.y), en * 0.3)
	var n := maxi(1, int(ceil(p0.distance_to(p1) / adim)))
	for i in n + 1:
		_firca(a, p0.lerp(p1, float(i) / n), en * 0.5, kanal, guc)


## Kırık çizgi (patika, tekerlek izi çifti için iki kez çağır).
static func asinma_yol(a: Dictionary, noktalar: PackedVector2Array, en: float, kanal := YOL, guc := 1.0) -> void:
	for i in noktalar.size() - 1:
		asinma_cizgi(a, noktalar[i], noktalar[i + 1], en, kanal, guc)


## Dikdörtgen yapı dibi: kenarlardan dışa `etek` m'lik temas kararması ve toprak eteği (zemin-duvar bıçak çizgisi kalkar).
static func asinma_kutu(a: Dictionary, c: Vector2, yarim: Vector2, aci: float, etek := 1.0, kanal := TEMAS) -> void:
	var ex := Vector2(cos(aci), sin(aci))
	var ez := Vector2(-ex.y, ex.x)
	var kose := [c + ex * yarim.x + ez * yarim.y, c - ex * yarim.x + ez * yarim.y, c - ex * yarim.x - ez * yarim.y, c + ex * yarim.x - ez * yarim.y]
	for i in 4:
		asinma_cizgi(a, kose[i], kose[(i + 1) % 4], etek * 2.0, kanal, 1.0)


static func asinma_uygula(a: Dictionary) -> void:
	var mat: ShaderMaterial = a["mat"]
	var img: Image = a["img"]
	var tex: ImageTexture = a.get("tex")
	if tex == null:
		tex = ImageTexture.create_from_image(img)
		a["tex"] = tex
	else:
		tex.update(img)
	var alan: Rect2 = a["alan"]
	mat.set_shader_parameter("asinma", tex)
	mat.set_shader_parameter("asinma_alan", Vector4(alan.position.x, alan.position.y, alan.size.x, alan.size.y))
	mat.set_shader_parameter("asinma_acik", 1.0)
	_asinma_cpu = a


static var _asinma_cpu: Dictionary = {}


## Maskenin CPU okuması (yer örtüsü yolda/çiğnenmiş alanda çıkmasın).
static func asinma_oku(x: float, z: float) -> Color:
	if _asinma_cpu.is_empty():
		return Color(0, 0, 0, 0)
	var mat: ShaderMaterial = _asinma_cpu["mat"]
	if float(mat.get_shader_parameter("asinma_acik")) < 0.5:
		return Color(0, 0, 0, 0)
	var img: Image = _asinma_cpu["img"]
	var alan: Rect2 = _asinma_cpu["alan"]
	var px: Vector2 = _asinma_cpu["px"]
	var ix := int((x - alan.position.x) * px.x)
	var iy := int((z - alan.position.y) * px.y)
	if ix < 0 or iy < 0 or ix >= img.get_width() or iy >= img.get_height():
		return Color(0, 0, 0, 0)
	return img.get_pixel(ix, iy)


# ------------------------------------------------------------------ sahne maskesi (eski bölümler kendiliğinden)

## Nature.ground_detail'in leke türleri (çamur, iz, kül, ıslak leke) yassı çıkartma yerine sahnenin aşınma maskesine
## boyanır: damga/elips leke kalmaz, kenar zemin gölgelendiricisinde gürültüyle bükülür. Tür → [kanal, güç, yarıçap çarpanı]
const LEKE := {"mud": [CAMUR, 0.62, 0.55], "camp_mud": [CAMUR, 0.55, 0.6], "grease": [CAMUR, 0.85, 0.4],
	"wet": [CAMUR, 0.42, 0.6], "footprint": [YOL, 0.5, 0.7], "hoofprint": [YOL, 0.5, 0.7], "snow_print": [YOL, 0.75, 0.8],
	"ash": [IS, 0.8, 0.55]}
static var _sahne: Dictionary = {}
static var _sahne_kok_id := 0


static func _kok(n: Node) -> Node:
	var k := n
	while k.get_parent() != null and k.get_parent().get_parent() != null:
		k = k.get_parent()
	return k


static func _sahne_al(kok: Node, area: Rect2) -> Dictionary:
	if _sahne.is_empty() or _sahne_kok_id != kok.get_instance_id():
		var r := Rect2(-170.0, -170.0, 340.0, 340.0).merge(area.grow(30.0))
		if r.size.x > 720.0 or r.size.y > 720.0:
			r = area.grow(30.0)
		_sahne = asinma_baslat(kok, r, 0.5)
		_sahne_kok_id = kok.get_instance_id()
	return _sahne


## Yapı dibi teması (kendiliğinden): sahnedeki durağan gövdelerin kutu/silindir çarpışma biçimlerinden zemine oturanların
## dibine temas kararması + toprak eteği (zemin ile duvar/çadır/ev arasındaki bıçak çizgisi kalkar). yer(x, z) -> dünya y.
static func temas_tara(kok: Node, yer: Callable, alan: Rect2) -> int:
	var a := _sahne_al(kok, alan)
	var say := 0
	for n in kok.find_children("*", "CollisionShape3D", true, false):
		var cs := n as CollisionShape3D
		if cs.disabled or not (cs.get_parent() is StaticBody3D) or cs.shape == null:
			continue
		var g := cs.global_transform
		var yarim := Vector2.ZERO
		var alt := 0.0
		if cs.shape is BoxShape3D:
			var e: Vector3 = (cs.shape as BoxShape3D).size * 0.5
			var sx := g.basis.x.length() * e.x
			var sy := g.basis.y.length() * e.y
			var sz := g.basis.z.length() * e.z
			if absf(g.basis.y.normalized().y) < 0.95:
				continue
			yarim = Vector2(sx, sz)
			alt = g.origin.y - sy
		elif cs.shape is CylinderShape3D:
			var c := cs.shape as CylinderShape3D
			yarim = Vector2(c.radius, c.radius) * g.basis.x.length()
			alt = g.origin.y - c.height * 0.5 * g.basis.y.length()
		else:
			continue
		if yarim.x < 0.25 or yarim.y < 0.25 or yarim.x > 30.0 or yarim.y > 30.0:
			continue
		var p := Vector2(g.origin.x, g.origin.z)
		if not (a["alan"] as Rect2).has_point(p):
			continue
		var gy: float = yer.call(p.x, p.y)
		if absf(alt - gy) > 0.7:
			continue
		var aci := atan2(g.basis.x.z, g.basis.x.x)
		var etek := clampf(minf(yarim.x, yarim.y) * 0.35, 0.35, 0.9)
		if cs.shape is CylinderShape3D:
			_firca(a, p, yarim.x + etek, TEMAS, 0.85)
		else:
			asinma_kutu(a, p, yarim, aci, etek)
		say += 1
		if say >= 900:
			break
	asinma_uygula(a)
	return say


## Döner: true (maskeye boyandı; çıkartma kurulmaz) / false (alan maskenin dışında: eski çıkartma).
static func sahne_boya(parent: Node, area: Rect2, kind: String, density: float, seed: int, keep: Callable, max_count: int) -> bool:
	if not LEKE.has(kind):
		return false
	_sahne_al(_kok(parent), area)
	var alan: Rect2 = _sahne["alan"]
	if not alan.encloses(area.intersection(alan)) or area.intersection(alan).get_area() < area.get_area() * 0.9:
		return false
	var spec: Array = LEKE[kind]
	var d: Array = Nature.DETAIL[kind]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var n := mini(max_count, int(area.get_area() * density))
	for i in n:
		var x := rng.randf_range(area.position.x, area.end.x)
		var z := rng.randf_range(area.position.y, area.end.y)
		if keep.is_valid() and not bool(keep.call(x, z)):
			continue
		var s := rng.randf_range(float(d[0]), float(d[1]))
		_firca(_sahne, Vector2(x, z), s * float(spec[2]), int(spec[0]), float(spec[1]) * rng.randf_range(0.75, 1.0))
	asinma_uygula(_sahne)
	return true


# ------------------------------------------------------------------ CPU gürültüsü (gölgelendiriciyle aynı doku)

static func _g(u: float, v: float) -> Color:
	if _gimg == null:
		malzeme()
		_gimg = _gurultu.get_image()
		if _gimg.is_compressed():
			_gimg.decompress()
	var w := _gimg.get_width()
	var x := int(fposmod(u, 1.0) * w)
	var y := int(fposmod(v, 1.0) * w)
	return _gimg.get_pixel(x, y)


## Gölgelendiricinin n2'si: iki ölçekte, döndürülmüş örnek (R, G yumuşak kanallar).
static func _n2(x: float, z: float, s1: float, s2: float, a: float) -> Vector2:
	var qx := x * cos(a) - z * sin(a)
	var qz := x * sin(a) + z * cos(a)
	var c1 := _g(x / s1, z / s1)
	var c2 := _g(qx / s2 + 0.37, qz / s2 + 0.37)
	return Vector2(c1.r + c2.g, c1.g + c2.r) * 0.5


## Gölgelendiricinin ot payı (yaklaşık): yer örtüsü otu yalnız otlu yerde çıksın.
static func ot_payi(x: float, z: float, ipucu: Color) -> float:
	var yesil := clampf((ipucu.g - maxf(ipucu.r, ipucu.b)) * 12.0, 0.0, 1.0)      # ipucu sRGB
	var o := _n2(x, z, 37.0, 23.0, 1.1)
	var q := _n2(x, z, 17.0, 11.0, 2.3)
	var w := _n2(x, z, 6.1, 3.7, 0.9)
	var m := malzeme()
	var cig := float(m.get_shader_parameter("cignenme"))
	var acik := smoothstep(0.42, 0.62, ipucu.r * 0.2126 + ipucu.g * 0.7152 + ipucu.b * 0.0722)
	var otluk := yesil + (w.x - 0.5) * 0.6 + (q.y - 0.5) * 0.35
	otluk -= cig * 0.45 * smoothstep(0.4, 0.7, o.x)
	otluk -= cig * 0.3 * smoothstep(0.5, 0.72, q.x + (w.y - 0.5) * 0.3)
	otluk -= smoothstep(0.6, 0.78, q.x) * 0.5 * (1.0 - yesil * 0.5)
	otluk += smoothstep(0.62, 0.8, o.y) * 0.45 * (1.0 - acik * 0.55) * (1.0 - cig * 0.5)
	return smoothstep(0.44, 0.56, otluk)


# ------------------------------------------------------------------ yer örtüsü ağları

static var _agl := {}


static func _ag(tur: String) -> ArrayMesh:
	if _agl.has(tur):
		return _agl[tur]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = tur.hash()
	match tur:
		"ot":
			# eğri yapraklı tutam: 6 yaprak, her biri 3 bölümlü kavisli şerit (dipte geniş, uçta sivri)
			for i in 5:
				var a := TAU * i / 5.0 + rng.randf_range(-0.4, 0.4)
				var d := Vector3(cos(a), 0, sin(a))
				_yaprak(st, d * rng.randf_range(0.0, 0.05), d, rng.randf_range(0.2, 0.38), rng.randf_range(0.02, 0.03),
					rng.randf_range(0.25, 0.6), Color(0.46, 0.52, 0.36), Color(0.86, 0.88, 0.7))
		"papatya", "gelincik":
			var tac := Color("f4f0e2") if tur == "papatya" else Color("c8321e")
			var orta := Color("e8c030") if tur == "papatya" else Color("201814")
			for i in 4:
				var b := Vector3(rng.randf_range(-0.14, 0.14), 0, rng.randf_range(-0.14, 0.14))
				var hh := rng.randf_range(0.16, 0.32) if tur == "papatya" else rng.randf_range(0.3, 0.45)
				var d := Vector3(rng.randf_range(-1, 1), 0, rng.randf_range(-1, 1)).normalized()
				_yaprak(st, b, d, hh, 0.008, 0.12, Color(0.32, 0.42, 0.22), Color(0.42, 0.55, 0.28))
				var c := b + d * hh * 0.12 + Vector3(0, hh, 0)
				var r := 0.03 if tur == "papatya" else 0.045
				var up := Vector3(rng.randf_range(-0.3, 0.3), 1, rng.randf_range(-0.3, 0.3)).normalized()
				_disk(st, c, up, r, 7, tac, tac.darkened(0.12), tur == "gelincik")
				_disk(st, c + up * 0.006, up, r * 0.32, 5, orta, orta, false)
			for i in 3:
				var a := TAU * i / 3.0
				var d := Vector3(cos(a), 0, sin(a))
				_yaprak(st, d * 0.03, d, 0.12, 0.016, 0.5, Color(0.42, 0.5, 0.32), Color(0.62, 0.68, 0.45))
		"tas":
			_kure(st, Vector3.ZERO, Vector3(1.0, 0.55, 0.85), 6, 3, rng, Color(0.62, 0.6, 0.56), Color(0.4, 0.38, 0.35))
		"dal":
			var p0 := Vector3(-0.35, 0.02, 0.0)
			var p1 := Vector3(0.0, 0.035, 0.04)
			var p2 := Vector3(0.38, 0.02, -0.03)
			_cubuk(st, [p0, p1, p2], 0.014, Color("5a4632"))
			_cubuk(st, [p1, p1 + Vector3(0.1, 0.01, 0.16), p1 + Vector3(0.14, 0.01, 0.28)], 0.008, Color("624c36"))
		"birikinti":
			var n := 14
			var c := Vector3.ZERO
			for i in n:
				var a0 := TAU * i / n
				var a1 := TAU * (i + 1) / n
				var r0 := 0.75 + 0.25 * sin(a0 * 3.0 + 1.0) + 0.1 * sin(a0 * 7.0)
				var r1 := 0.75 + 0.25 * sin(a1 * 3.0 + 1.0) + 0.1 * sin(a1 * 7.0)
				for v: Vector3 in [c, Vector3(cos(a1) * r1, 0, sin(a1) * r1), Vector3(cos(a0) * r0, 0, sin(a0) * r0)]:
					st.set_color(Color(0.16, 0.17, 0.17) if v == c else Color(0.22, 0.2, 0.17))
					st.set_normal(Vector3.UP)
					st.add_vertex(v)
	var m := st.commit()
	_agl[tur] = m
	return m


## Kavisli yaprak: dipten uca 3 bölüm, dışa eğilerek yatar (kutu/üçgen prizma değil).
static func _yaprak(st: SurfaceTool, b: Vector3, d: Vector3, h: float, w: float, egik: float, c0: Color, c1: Color) -> void:
	var side := Vector3(-d.z, 0, d.x)
	var pts: Array = []
	for k in 4:
		var t := k / 3.0
		pts.append(b + d * (egik * h * t * t) + Vector3(0, h * (t - 0.25 * egik * t * t), 0))
	for k in 3:
		var t0 := k / 3.0
		var t1 := (k + 1) / 3.0
		var w0 := w * (1.0 - t0 * 0.85)
		var w1 := w * (1.0 - t1 * 0.85) if k < 2 else 0.0
		var a0: Vector3 = pts[k] - side * w0
		var a1: Vector3 = pts[k] + side * w0
		var b0: Vector3 = pts[k + 1] - side * w1
		var b1: Vector3 = pts[k + 1] + side * w1
		var n := (side).cross(pts[k + 1] - pts[k]).normalized().lerp(Vector3.UP, 0.5).normalized()
		var ca := c0.lerp(c1, t0)
		var cb := c0.lerp(c1, t1)
		for v: Array in [[a0, ca], [a1, ca], [b1, cb], [a0, ca], [b1, cb], [b0, cb]]:
			st.set_color(v[1])
			st.set_normal(n)
			st.add_vertex(v[0])


static func _disk(st: SurfaceTool, c: Vector3, up: Vector3, r: float, n: int, ci: Color, co: Color, kase: bool) -> void:
	var t := up.cross(Vector3.RIGHT if absf(up.x) < 0.9 else Vector3.FORWARD).normalized()
	var b := up.cross(t)
	for i in n:
		var a0 := TAU * i / n
		var a1 := TAU * (i + 1) / n
		var lift := up * (r * 0.5 if kase else 0.0)
		var v0 := c + (t * cos(a0) + b * sin(a0)) * r * (0.85 + 0.15 * float(i % 2)) + lift
		var v1 := c + (t * cos(a1) + b * sin(a1)) * r * (0.85 + 0.15 * float((i + 1) % 2)) + lift
		for v: Array in [[c, ci], [v0, co], [v1, co]]:
			st.set_color(v[1])
			st.set_normal(up)
			st.add_vertex(v[0])


## Yuvarlak taş: enlem-boylam küresi, köşeler hafif oynatılmış, yumuşak normal; dibi koyu.
static func _kure(st: SurfaceTool, c: Vector3, s: Vector3, nb: int, ne: int, rng: RandomNumberGenerator, ust: Color, alt: Color) -> void:
	var rows: Array = []
	for j in ne + 1:
		var th := PI * j / ne
		var row: Array = []
		for i in nb:
			var ph := TAU * i / nb
			var dir := Vector3(sin(th) * cos(ph), cos(th), sin(th) * sin(ph))
			var jit := 1.0 if j == 0 or j == ne else rng.randf_range(0.86, 1.1)
			row.append(dir * jit)
		rows.append(row)
	for j in ne:
		for i in nb:
			var i2 := (i + 1) % nb
			var q: Array = [rows[j][i], rows[j][i2], rows[j + 1][i2], rows[j + 1][i]]
			for tri: Array in [[q[0], q[1], q[2]], [q[0], q[2], q[3]]]:
				for v: Vector3 in tri:
					st.set_color(alt.lerp(ust, clampf(v.y * 0.5 + 0.5, 0.0, 1.0)))
					st.set_normal(v.normalized())
					st.add_vertex(c + v * s)


static func _cubuk(st: SurfaceTool, pts: Array, r: float, col: Color) -> void:
	for k in pts.size() - 1:
		var a: Vector3 = pts[k]
		var b: Vector3 = pts[k + 1]
		var d := (b - a).normalized()
		var t := d.cross(Vector3.UP).normalized()
		var u := t.cross(d)
		for i in 5:
			var a0 := TAU * i / 5.0
			var a1 := TAU * (i + 1) / 5.0
			var o0 := (t * cos(a0) + u * sin(a0))
			var o1 := (t * cos(a1) + u * sin(a1))
			var rb := r * (1.0 - 0.3 * float(k + 1) / pts.size())
			var ra := r * (1.0 - 0.3 * float(k) / pts.size())
			for v: Array in [[a + o0 * ra, o0], [b + o1 * rb, o1], [a + o1 * ra, o1], [a + o0 * ra, o0], [b + o0 * rb, o0], [b + o1 * rb, o1]]:
				st.set_color(col)
				st.set_normal(v[1])
				st.add_vertex(v[0])


# ------------------------------------------------------------------ yer örtüsü (akışlı)

## Yer örtüsü kur: ebeveynin YEREL uzayında alan (x, z), yukseklik(x, z) -> y (yerel), renk(x, z) -> Color (zemin
## ipucu; boşsa her yer otlu sayılır). ayar: {"yogunluk": 1.0, "cicek": 1.0, "tas": 1.0, "dal": 1.0, "birikinti": 1.0,
## "tut": Callable(x, z) -> bool (false: örtü yok; yapı içi, su, döşeme)}. Döner: düğüm (Node3D).
static func ortu_ekle(ebeveyn: Node3D, alan: Rect2, yukseklik: Callable, renk := Callable(), ayar := {}) -> Node3D:
	var o := Ortu.new()
	o.name = "ZeminOrtu"
	o.alan = alan
	o.yukseklik = yukseklik
	o.renk = renk
	o.ayar = ayar
	ebeveyn.add_child(o)
	return o


class Ortu extends Node3D:
	const HUCRE := 8.0
	const YARICAP := 48.0
	const TURLER := ["ot", "papatya", "gelincik", "tas", "dal", "birikinti"]
	var alan: Rect2
	var yukseklik: Callable
	var renk: Callable
	var ayar := {}
	var _mm := {}                   # tur -> MultiMesh
	var _hucre := {}                # Vector2i -> {tur: PackedFloat32Array} (her örnek 17 float: 16 + sıra)
	var _etkin: Array = []          # şu an çizilen hücreler
	var _merkez := Vector2i(1 << 30, 0)
	var _kirli := false
	var _yaklasik := 0

	func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS      # bölüm duraklatılsa da (giriş kartı, menü) örtü akar
		for t: String in TURLER:
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.use_colors = true
			mm.mesh = Zemin_ag(t)
			var mi := MultiMeshInstance3D.new()
			mi.name = "Ortu_" + t
			mi.multimesh = mm
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			if t == "ot" or t == "papatya" or t == "gelincik":
				mi.material_override = Zemin_ot_mat()
			elif t == "birikinti":
				var wm := StandardMaterial3D.new()
				wm.vertex_color_use_as_albedo = true
				wm.roughness = 0.08
				wm.metallic_specular = 0.9
				wm.metallic = 0.25
				mi.material_override = wm
			else:
				mi.material_override = Nature.rock_material()
			add_child(mi)
			_mm[t] = mm

	## Örtü otu: rüzgârda salınan çimen gölgelendiricisi, arka ışığı kısık (güneşte "marul yeşili" parlamasın)
	static var _ot_mat: ShaderMaterial
	static func Zemin_ot_mat() -> ShaderMaterial:
		if _ot_mat == null:
			var base: Shader = load("res://assets/shaders/grass.gdshader")
			var sh := Shader.new()
			sh.code = base.code.replace("BACKLIGHT = vec3(0.25, 0.3, 0.15);", "BACKLIGHT = vec3(0.07, 0.08, 0.04);")
			_ot_mat = ShaderMaterial.new()
			_ot_mat.shader = sh
		return _ot_mat

	static func Zemin_ag(t: String) -> ArrayMesh:
		return load("res://scripts/level/zemin.gd")._ag(t)

	var _kare := 0
	func _process(_d: float) -> void:
		_kare += 1
		if _kare == 4 and ayar.get("temas", true):
			var gx := global_transform
			var yer := func(x: float, z: float) -> float:
				var l := gx.affine_inverse() * Vector3(x, 0, z)
				return (gx * Vector3(l.x, yukseklik.call(l.x, l.z), l.z)).y
			var Z = load("res://scripts/level/zemin.gd")
			var kok: Node = Z._kok(self)
			var r := Rect2((gx * Vector3(alan.position.x, 0, alan.position.y)).x, (gx * Vector3(alan.position.x, 0, alan.position.y)).z, alan.size.x, alan.size.y)
			var t0 := Time.get_ticks_msec()
			var say: int = Z.temas_tara(kok, yer, r.abs())
			print("ZEMIN temas=%d ms=%d" % [say, Time.get_ticks_msec() - t0])
		var cam := get_viewport().get_camera_3d()
		if cam == null:
			return
		var lp := to_local(cam.global_position)
		var ic := alan.grow(YARICAP).has_point(Vector2(lp.x, lp.z))
		visible = ic
		if not ic:
			return
		var m := Vector2i(floori(lp.x / HUCRE), floori(lp.z / HUCRE))
		var n := int(ceil(YARICAP / HUCRE))
		if m != _merkez:
			_merkez = m
			_etkin.clear()
			for j in range(-n, n + 1):
				for i in range(-n, n + 1):
					var k := m + Vector2i(i, j)
					var cc := (Vector2(k) + Vector2(0.5, 0.5)) * HUCRE
					if cc.distance_to(Vector2(lp.x, lp.z)) > YARICAP + HUCRE * 0.7:
						continue
					if not alan.intersects(Rect2(Vector2(k) * HUCRE, Vector2(HUCRE, HUCRE))):
						continue
					_etkin.append(k)
			_etkin.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return (a - m).length_squared() < (b - m).length_squared())
			_kirli = true
		# kare başına en çok 3 yeni hücre (takılma yok)
		var yeni := 0
		for k: Vector2i in _etkin:
			if not _hucre.has(k):
				_hucre[k] = _hucre_kur(k)
				_kirli = true
				yeni += 1
				if yeni >= 3:
					break
		if _kirli and (yeni == 0 or _hucre.size() < 6 or Engine.get_process_frames() % 8 == 0):
			_kirli = false
			_doldur(m)
		# uzak önbellek temizliği
		if _hucre.size() > 400:
			for k: Vector2i in _hucre.keys():
				if (k - m).length() > n * 2.5:
					_hucre.erase(k)

	func _doldur(m: Vector2i) -> void:
		var buf := {}
		var say := {}
		for t: String in TURLER:
			buf[t] = PackedFloat32Array()
			say[t] = 0
		for k: Vector2i in _etkin:
			var h: Dictionary = _hucre.get(k, {})
			if h.is_empty():
				continue
			var dd := (Vector2(k - m)).length() * HUCRE
			# uzaklığa göre seyrelme: 13 m'ye kadar tam, 48 m'de %8 (sıra < pay)
			var pay := 1.0 if dd < 13.0 else lerpf(0.3, 0.08, clampf((dd - 13.0) / 35.0, 0.0, 1.0))
			for t: String in TURLER:
				var a: PackedFloat32Array = h.get(t, PackedFloat32Array())
				var tp := pay if t == "ot" else minf(1.0, pay * 2.5) if t != "birikinti" else 1.0
				var c := a.size() / 17
				for i in c:
					if a[i * 17 + 16] >= tp:
						continue
					buf[t].append_array(a.slice(i * 17, i * 17 + 16))
					say[t] += 1
		for t: String in TURLER:
			var mm: MultiMesh = _mm[t]
			mm.instance_count = 0
			mm.instance_count = say[t]
			if say[t] > 0:
				mm.buffer = buf[t]

	func _ekle(arr: PackedFloat32Array, p: Vector3, yon: float, s: Vector3, c: Color, sira: float) -> void:
		var b := Basis(Vector3.UP, yon).scaled(s)
		arr.append_array(PackedFloat32Array([b.x.x, b.y.x, b.z.x, p.x, b.x.y, b.y.y, b.z.y, p.y, b.x.z, b.y.z, b.z.z, p.z,
			c.r, c.g, c.b, c.a, sira]))

	## Alt karenin üstünde bir şey duruyor mu (yapı, döşeme, kaya, güverte): örtü çıkmasın.
	func _dolu(x: float, y: float, z: float) -> bool:
		if not is_inside_tree():
			return false
		var g0 := to_global(Vector3(x, y + 4.0, z))
		var g1 := to_global(Vector3(x, y - 0.3, z))
		var q := PhysicsRayQueryParameters3D.create(g0, g1)
		var h := get_world_3d().direct_space_state.intersect_ray(q)
		if h.is_empty():
			return false
		return to_local(h["position"]).y > y + 0.1

	func _hucre_kur(k: Vector2i) -> Dictionary:
		var out := {}
		for t: String in TURLER:
			out[t] = PackedFloat32Array()
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(Vector3i(k.x, k.y, 1453))
		var Z = load("res://scripts/level/zemin.gd")
		var yog: float = ayar.get("yogunluk", 1.0)
		var su_y := float(Z.malzeme().get_shader_parameter("su_y"))
		var kar_var := float(Z.malzeme().get_shader_parameter("kar")) > 0.3
		var tut: Callable = ayar.get("tut", Callable())
		var x0 := k.x * HUCRE
		var z0 := k.y * HUCRE
		# öbekli dağılım: hücreyi 2 m'lik alt karelere böl, her birinde öbek gürültüsüne göre deneme
		for j in 4:
			for i in 4:
				var cx := x0 + (i + 0.5) * 2.0
				var cz := z0 + (j + 0.5) * 2.0
				if not alan.has_point(Vector2(cx, cz)):
					continue
				var gy: float = yukseklik.call(cx, cz)
				if gy < su_y + 0.25 or _dolu(cx, gy, cz):
					continue
				var ip: Color = renk.call(cx, cz) if renk.is_valid() else Color("6c8644")
				var otp: float = Z.ot_payi(cx, cz, ip)
				var obek: Vector2 = Z._n2(cx, cz, 13.0, 7.0, 0.4)
				var obk2: Vector2 = Z._n2(cx, cz, 9.0, 5.0, 2.0)
				var as_: Color = Z.asinma_oku(cx, cz)
				var cig := maxf(as_.r, as_.g)
				if kar_var:
					otp = 0.0
				var deneme := int(round((1.0 + 4.0 * smoothstep(0.35, 0.7, obek.y)) * otp * yog * (1.0 - cig)))
				for q in deneme:
					var x := cx + rng.randf_range(-1.0, 1.0)
					var z := cz + rng.randf_range(-1.0, 1.0)
					if tut.is_valid() and not tut.call(x, z):
						continue
					var y: float = yukseklik.call(x, z)
					var kuru := clampf(obek.x * 1.2 - 0.2 + rng.randf_range(-0.2, 0.2), 0.0, 1.0)
					var c := Color("66744a").lerp(Color("968c62"), kuru) * rng.randf_range(0.85, 1.05)
					c.a = 1.0
					var s := rng.randf_range(0.7, 1.35)
					_ekle(out["ot"], Vector3(x, y - 0.02, z), rng.randf() * TAU, Vector3(s, s * rng.randf_range(0.8, 1.2), s), c, rng.randf())
				# çiçek öbekleri: seyrek, otun içinde
				var cic: float = ayar.get("cicek", 1.0)
				if otp > 0.6 and obk2.x > 0.66 and rng.randf() < 0.55 * cic:
					var tur := "gelincik" if obk2.y > 0.55 else "papatya"
					for q in rng.randi_range(1, 3):
						var x := cx + rng.randf_range(-0.9, 0.9)
						var z := cz + rng.randf_range(-0.9, 0.9)
						if tut.is_valid() and not tut.call(x, z):
							continue
						var s := rng.randf_range(0.8, 1.2)
						_ekle(out[tur], Vector3(x, yukseklik.call(x, z) - 0.01, z), rng.randf() * TAU, Vector3(s, s, s), Color.WHITE, rng.randf())
				# taş ve çakıl: otsuz yerde daha sık; yuvarlak, yarı gömülü
				var tsk := (0.25 + 1.2 * (1.0 - otp)) * float(ayar.get("tas", 1.0)) * (1.0 - as_.r * 0.6)
				var tn := int(tsk * 1.5 + rng.randf())
				for q in tn:
					var x := cx + rng.randf_range(-1.0, 1.0)
					var z := cz + rng.randf_range(-1.0, 1.0)
					if tut.is_valid() and not tut.call(x, z):
						continue
					var r := rng.randf_range(0.03, 0.09) if rng.randf() < 0.85 else rng.randf_range(0.12, 0.24)
					var g := rng.randf_range(0.82, 1.1)
					_ekle(out["tas"], Vector3(x, yukseklik.call(x, z) - r * 0.25, z), rng.randf() * TAU,
						Vector3(r, r, r) * rng.randf_range(0.9, 1.15), Color(g, g * 0.98, g * 0.94), rng.randf())
				# kuru dal / yaprak: seyrek
				if rng.randf() < 0.07 * float(ayar.get("dal", 1.0)):
					var x := cx + rng.randf_range(-1.0, 1.0)
					var z := cz + rng.randf_range(-1.0, 1.0)
					if not tut.is_valid() or tut.call(x, z):
						var s := rng.randf_range(0.6, 1.4)
						_ekle(out["dal"], Vector3(x, yukseklik.call(x, z), z), rng.randf() * TAU, Vector3(s, s, s), Color.WHITE, rng.randf())
				# su birikintisi: çamurlu, otsuz, nemli yerde
				var nem: Vector2 = Z._n2(cx, cz, 17.0, 11.0, 2.3)
				if (as_.g > 0.5 or (otp < 0.3 and nem.y < 0.3)) and rng.randf() < 0.18 * float(ayar.get("birikinti", 1.0)):
					var x := cx + rng.randf_range(-0.6, 0.6)
					var z := cz + rng.randf_range(-0.6, 0.6)
					if not tut.is_valid() or tut.call(x, z):
						var s := rng.randf_range(0.35, 0.9)
						_ekle(out["birikinti"], Vector3(x, yukseklik.call(x, z) + 0.025, z), rng.randf() * TAU, Vector3(s * 1.4, 1.0, s), Color.WHITE, 0.0)
		return out
