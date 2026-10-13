class_name CharKit
extends RefCounted
## Karakter parçaları (Person, Hikmet, Soldier ortak): oyuncak blok yerine yuvarlak, yumuşak ışıklı,
## karikatür oranlı gövde. İskelet (kalça, omuz, baş, göz düğümleri) aynı kalır: Rig animasyonları değişmez.
## Mizah yüzde: büyük gözler (ak + bebek), iri burun, kalın kaşlar, kıvrık bıyık.

const SEG := 14
static var _mats: Dictionary = {}


## Karakter malzemesi: sarmalayan yumuşak ışık (toon değil), hafif kenar ışığı; dış hat korunur.
static func mat(c: Color, outline := true) -> StandardMaterial3D:
	var key := "%s|%s|%s" % [c.to_html(), outline, Props.outlines]
	if _mats.has(key):
		return _mats[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT_WRAP
	m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	m.roughness = 0.78
	m.metallic_specular = 0.25
	m.rim_enabled = true
	m.rim = 0.22
	m.rim_tint = 0.5
	if outline and Props.outlines:
		m.next_pass = _outline()
	_mats[key] = m
	return m


static var _ol: StandardMaterial3D
static func _outline() -> StandardMaterial3D:
	if _ol == null:
		_ol = StandardMaterial3D.new()
		_ol.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_ol.albedo_color = Props.OUTLINE_COLOR
		_ol.cull_mode = BaseMaterial3D.CULL_FRONT
		_ol.grow = true
		_ol.grow_amount = Props.OUTLINE_WIDTH * 0.7
	return _ol


static func _mi(parent: Node3D, mesh: Mesh, pos: Vector3, c: Color, rot := Vector3.ZERO, scl := Vector3.ONE, outline := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(c, outline)
	mi.position = pos
	mi.rotation_degrees = rot
	mi.scale = scl
	parent.add_child(mi)
	return mi


## Yuvarlak uçlu, istenirse incelen boru (uzuv, gövde). pos: merkez.
static func capsule(parent: Node3D, r: float, h: float, pos: Vector3, c: Color, rot := Vector3.ZERO, r_top := -1.0, outline := true) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = rot
	parent.add_child(n)
	var rt := r if r_top < 0.0 else r_top
	var body := h - (r + rt) * 0.5
	var cm := CylinderMesh.new()
	cm.bottom_radius = r
	cm.top_radius = rt
	cm.height = maxf(body, 0.01)
	cm.radial_segments = SEG if maxf(r, rt) >= 0.045 else 10
	cm.rings = 1
	_mi(n, cm, Vector3.ZERO, c, Vector3.ZERO, Vector3.ONE, outline)
	_mi(n, _sphere(r, 10), Vector3(0, -body * 0.5, 0), c, Vector3.ZERO, Vector3.ONE, outline)
	_mi(n, _sphere(rt, 10), Vector3(0, body * 0.5, 0), c, Vector3.ZERO, Vector3.ONE, outline)
	return n


static func _sphere(r: float, rings := 10) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	# Küçük parçalar (dudak, burun kanadı, kirpik ucu, parmak) daha az dilimle: kafa başına ~4 bin köşe azalır,
	# pişirme (CharKit.bake) ve kalabalıkta kurulum süresi düşer; o boyutta köşeli görünmez
	s.radial_segments = SEG + 2 if r >= 0.045 else (12 if r >= 0.025 else 10)
	s.rings = rings if r >= 0.045 else mini(rings, 7 if r >= 0.025 else 6)
	return s


static func ball(parent: Node3D, r: float, pos: Vector3, c: Color, scl := Vector3.ONE, outline := true) -> MeshInstance3D:
	return _mi(parent, _sphere(r), pos, c, Vector3.ZERO, scl, outline and r >= 0.04)


## Bacak: kalçadan (pivot) aşağı uyluk, dizde ikinci eklem (döner: dizden aşağısı), baldır ve yuvarlak ayakkabı.
## Döner: diz düğümü (Rig bükülmeyi buradan verir). length: kalça-taban.
static func leg(pivot: Node3D, pants: Color, shoe: Color, length := 0.66, r := 0.085) -> Node3D:
	var thigh := length * 0.5
	capsule(pivot, r, thigh + r * 0.5, Vector3(0, -thigh * 0.5, 0), pants, Vector3.ZERO, r * 0.92)
	var knee := Node3D.new()
	knee.name = "Knee"
	knee.position = Vector3(0, -thigh, 0)
	pivot.add_child(knee)
	var shin := length - thigh
	capsule(knee, r * 0.88, shin, Vector3(0, -shin * 0.5 + 0.02, 0), pants, Vector3.ZERO, r * 0.8)
	# Ayak bileği (üçüncü eklem): ayakkabı buna bağlı; Rig tabanı zemine paralel tutar (yürürken basar, otururken düz)
	var ankle := Node3D.new()
	ankle.name = "Ankle"
	ankle.position = Vector3(0, -shin + 0.075, 0)
	knee.add_child(ankle)
	ball(ankle, 0.075, Vector3(0, -0.03, 0.05), shoe, Vector3(1.0, 0.62, 1.75))
	ball(ankle, 0.05, Vector3(0, -0.015, 0.15), shoe.lightened(0.05), Vector3(1.1, 0.7, 1.0), false)
	return knee


## Dizin ayak bileği düğümü (ayakkabıya eklenen çizme, terlik buraya); yoksa diz
static func ankle_of(knee: Node3D) -> Node3D:
	var a := knee.get_node_or_null("Ankle") as Node3D
	return a if a else knee


## Kol: omuzdan (pivot) aşağı pazu, dirsekte ikinci eklem (önkol, bilek, eldiven gibi el, başparmak).
## Döner: dirsek düğümü.
static func arm(pivot: Node3D, sleeve: Color, skin: Color, length := 0.52, r := 0.068) -> Node3D:
	var upper := length * 0.5
	capsule(pivot, r * 0.95, upper + r * 0.4, Vector3(0, -upper * 0.5 + 0.01, 0), sleeve, Vector3.ZERO, r)
	var elbow := Node3D.new()
	elbow.name = "Elbow"
	elbow.position = Vector3(0, -upper, 0)
	pivot.add_child(elbow)
	var fore := length - upper
	capsule(elbow, r * 0.82, fore, Vector3(0, -fore * 0.5 + 0.02, 0), sleeve, Vector3.ZERO, r * 0.92)
	ball(elbow, r * 0.95, Vector3(0, -fore + 0.06, 0), sleeve.darkened(0.12), Vector3(1.05, 0.45, 1.05), false)
	# El bileği (üçüncü eklem): el ve başparmak buna bağlı; Rig önkolun salınımını hafif gecikmeyle izletir
	var wrist := Node3D.new()
	wrist.name = "Wrist"
	wrist.position = Vector3(0, -fore + 0.035, 0.005)
	elbow.add_child(wrist)
	ball(wrist, 0.058, Vector3(0, -0.045, 0.005), skin, Vector3(0.9, 1.1, 0.75))
	ball(wrist, 0.022, Vector3(0.0, -0.025, 0.05), skin, Vector3(1, 1.3, 1), false)
	elbow.set_meta("hand", Vector3(0, -fore - 0.01, 0.01))     # avucun ortası (Rig.reach eli buraya götürür)
	return elbow


## Gövde: yuvarlak omuzlu, bele doğru daralan (ya da göbekli) gövde; boyun.
static func torso(body: Node3D, coat: Color, skin: Color, width := 0.25, belly := 0.0, neck_y := 1.32) -> void:
	capsule(body, width * 0.9, 0.62, Vector3(0, 1.0, 0), coat, Vector3.ZERO, width)
	# Omuz yuvarlaklığı
	ball(body, width * 1.02, Vector3(0, 1.2, 0), coat, Vector3(1.12, 0.55, 0.85))
	if belly > 0.0:
		# Göbek: gövdeden taşan ayrı bir top değil, gövdenin önünü hafifçe dolduran yumru
		ball(body, width * 0.92, Vector3(0, 0.9, 0.02 + belly * 0.05), coat, Vector3(1.0, 1.05, 0.9 + belly * 0.15), false)
	var nm := CylinderMesh.new()
	nm.top_radius = 0.065
	nm.bottom_radius = 0.075
	nm.height = 0.14
	nm.radial_segments = SEG
	_mi(body, nm, Vector3(0, neck_y, 0), skin, Vector3.ZERO, Vector3.ONE, false)


## Yüz hizaları (r biriminde): göz, kaş, burun ucu, ağız. Gözlük ve yüz eşyaları bunlara göre konur.
const EYE_Y := 0.08
const BROW_Y := 0.3
const NOSE_Y := -0.27
const MOUTH_Y := -0.58


## Yüz: kafa (kafatası + çene), kulaklar, burun (köprü, uç, kanatlar), badem gözler (ak, iris, bebek, kapak ve kirpik
## çizgisi; eyes düğümüne), ince kaşlar (brows), dudaklı ağız. Döner: ağız açıklığı (konuşma animasyonu ölçekler).
## Olgun oranlı: yüzün alt yarısı uzun, gözler küçük ve kapaklı, burun yüze oturur (eski iri top burun ve patlak
## gözler çocuksu duruyordu).
## spec (hepsi isteğe bağlı): head (baş ölçeği), nose ("round"/"long"/"hook"/"button"/"bulb"/"potato"), nose_s, eye_s, eye_gap,
## lid (göz kapağı 0..0.6), brow (kalınlık), brow_tilt (derece; + kızgın, - endişeli), unibrow, ears, mouth_w, blush,
## wrinkles, chin (çene çıkıntısı 0..1), bags (göz altı torbası), eye_color, young (çocuk: yumuşak hatlar).
static func face(head: Node3D, eyes: Node3D, brows: Node3D, skin: Color, hair: Color, r := 0.2, nose := 1.0, spec := {}) -> MeshInstance3D:
	var hs: Vector3 = spec.get("head", Vector3(1.0, 1.06, 0.98))
	var young: bool = spec.get("young", false)
	ball(head, r, Vector3.ZERO, skin, hs)
	# Çene ve yanaklar: yüzün alt yarısı kafatasından aşağı uzar (bebek kafası gibi tek küre durmasın)
	var jaw := 0.85 if young else 1.0
	ball(head, r * 0.74, Vector3(0, -r * 0.5 * jaw, r * 0.1), skin, Vector3(hs.x * (0.98 if young else 0.94), 0.8 * jaw, hs.z * 1.04))
	var fd := face_detail(head)
	var chin: float = spec.get("chin", 0.0)
	ball(fd, r * (0.24 + chin * 0.08), Vector3(0, -r * (0.9 if not young else 0.78), r * (0.56 + chin * 0.06)), skin,
		Vector3(1.2, 0.78, 0.92), false)
	# Kulaklar: küçük, kafaya yatık
	var es: float = spec.get("ears", 1.0)
	for sx: int in [-1, 1]:
		ball(head, r * 0.17 * es, Vector3(sx * r * 0.96 * hs.x, -r * 0.08, -0.005), skin.darkened(0.05), Vector3(0.42, 1.0, 0.72), false)
	# Burun: alından inen köprü, uç, iki kanat (çizgisiz: yüze oturur)
	var ns: float = spec.get("nose_s", 1.0) * lerpf(1.0, nose, 0.4)
	var nc := skin.darkened(0.07)
	var nt := str(spec.get("nose", "round"))
	# "potato": Hikmet amcanın burnu (karakteristik ve karikatür: iri, hafif sarkık, ucu pembe, kanatları dolgun)
	var tip_y := r * NOSE_Y * (1.15 if nt == "long" else (0.8 if nt == "button" else (1.04 if nt == "potato" else 1.0)))
	var tip_z := _surf(r, hs, 0.0, tip_y) + r * 0.13 * ns * (1.2 if nt in ["long", "hook"] else (0.8 if nt == "button" else (1.35 if nt == "potato" else 1.0)))
	var top_y := r * (EYE_Y - 0.02)
	var top_z := _surf(r, hs, 0.0, top_y) + r * 0.02
	var mid := Vector3(0, (top_y + tip_y) * 0.5, (top_z + tip_z) * 0.5 - r * 0.03)
	var blen := Vector3(0, top_y - tip_y, top_z - tip_z).length()
	var ang := rad_to_deg(atan2(top_z - tip_z, top_y - tip_y))
	var br := capsule(fd, r * 0.078 * ns, blen, mid, nc, Vector3(ang, 0, 0), r * 0.055 * ns, false)
	br.scale = Vector3(1.0, 1.0, 1.15)
	if young:
		br.visible = false
	var tip_r := r * 0.095 * ns * (1.45 if nt == "bulb" else (0.8 if nt == "button" else (1.8 if nt == "potato" else 1.0)))
	var tip_c := nc.lerp(Color("c86a5e"), 0.18) if nt == "bulb" else (nc.lerp(Color("d0706a"), 0.3) if nt == "potato" else nc)
	ball(fd, tip_r, Vector3(0, tip_y - (r * 0.02 if nt == "hook" else (r * 0.03 if nt == "potato" else 0.0)), tip_z - tip_r * 0.5), tip_c,
		Vector3(1.12, 1.05, 1.0) if nt == "potato" else Vector3(1.12, 0.95, 1.0), false)
	if nt == "hook":
		# Kemerli burun (Fatih portrelerindeki gibi): köprünün ortasında çıkıntı
		ball(fd, r * 0.06 * ns, mid + Vector3(0, r * 0.03, r * 0.045), nc, Vector3(0.9, 1.4, 1.0), false)
	var wing := 1.6 if nt == "potato" else 1.0
	for sx: int in [-1, 1]:
		ball(fd, r * 0.055 * ns * wing, Vector3(sx * r * 0.075 * ns * (1.45 if nt == "potato" else 1.0), tip_y - r * 0.035 * wing, tip_z - r * 0.07 * wing),
			nc.darkened(0.03), Vector3(1.0, 0.8, 0.9), false)
	# Hafif yanak kızarıklığı (yalnız tarifte istenirse, çok soluk)
	if spec.get("blush", false):
		for sx: int in [-1, 1]:
			var bx := sx * r * 0.5 * hs.x
			ball(fd, r * 0.15, Vector3(bx, -r * 0.3, _surf(r, hs, bx, -r * 0.3) - r * 0.06), skin.lerp(Color("d8706a"), 0.14), Vector3(1.0, 0.6, 0.35), false)
	# Kırışıklıklar: alın çizgileri ve burun-ağız çizgileri; göz altı torbaları
	var wc := skin.darkened(0.22)
	if spec.get("wrinkles", false):
		for k in 2:
			var wy := r * (0.52 + k * 0.1)
			var w := capsule(fd, r * 0.01, r * (0.46 - k * 0.08), Vector3(0, wy, _surf(r, hs, 0.0, wy) - r * 0.008), wc, Vector3(0, 0, 90), -1.0, false)
			w.scale = Vector3(1, 1, 0.5)
		for sx: int in [-1, 1]:
			var fy := r * (MOUTH_Y + NOSE_Y) * 0.5
			var fx := sx * r * 0.2
			var f := capsule(fd, r * 0.01, r * 0.3, Vector3(fx, fy, _surf(r, hs, fx, fy) + r * 0.02), wc, Vector3(0, 0, sx * 22.0), -1.0, false)
			f.scale = Vector3(1, 1, 0.5)
	# Gözler: badem biçimli ak, renkli iris, bebek, parlama; üst kapak ve kirpik çizgisi gözü daraltır.
	# Göz düğümü kırpma/bakış için Rig'e gider (kırparken düğüm dikeyde ezilir).
	var eys: float = spec.get("eye_s", 1.0)
	eys = lerpf(1.0, eys, 0.5) * (1.12 if young else 1.0)
	var gap: float = lerpf(0.33, float(spec.get("eye_gap", 0.36)), 0.5)
	var lid: float = spec.get("lid", 0.0)
	var iris_c: Color = spec.get("eye_color", Color("4a3222"))
	var ey := r * EYE_Y
	eyes.position = Vector3(0, ey, _surf(r, hs, r * gap, ey) - r * 0.045)
	var lid_c := skin.darkened(0.04)
	for sx: int in [-1, 1]:
		var x := sx * r * gap
		ball(eyes, r * 0.145 * eys, Vector3(x, 0, 0), Color("ece6dc"), Vector3(1.2, 0.78, 0.55), false)
		ball(eyes, r * 0.08 * eys, Vector3(x, -r * 0.004, r * 0.052), iris_c, Vector3(1.0, 1.0, 0.45), false)
		ball(eyes, r * 0.04 * eys, Vector3(x, -r * 0.004, r * 0.075), Color("120e0c"), Vector3(1.0, 1.0, 0.4), false)
		ball(eyes, r * 0.017 * eys, Vector3(x + r * 0.026, r * 0.024, r * 0.088), Color.WHITE, Vector3.ONE, false)
		# Üst kapak (deri): akın üst dörtte birini örter; lid ile ağırlaşır (uykulu, yorgun, şüpheci)
		var ly := r * (0.135 - lid * 0.055) * eys
		ball(eyes, r * 0.15 * eys, Vector3(x, ly, r * 0.012), lid_c, Vector3(1.24, 0.5, 0.62), false)
		# Kirpik çizgisi: kapağın alt kenarında koyu ince çizgi
		var lash := capsule(eyes, r * 0.013, r * 0.3 * eys, Vector3(x, ly - r * 0.07 * eys, r * 0.062), Color("2a1c16"), Vector3(0, 0, 90 - sx * 7.0), r * 0.008, false)
		lash.scale = Vector3(1, 1, 0.55)
		# Alt kapak: akın altını hafifçe örter (badem biçimi)
		ball(eyes, r * 0.13 * eys, Vector3(x, -r * 0.135 * eys, r * 0.008), lid_c, Vector3(1.22, 0.42, 0.58), false)
		if spec.get("bags", false):
			ball(eyes, r * 0.12 * eys, Vector3(x, -r * 0.16 * eys, r * 0.014), skin.darkened(0.12), Vector3(1.15, 0.3, 0.5), false)
	# Kaşlar: ince, uca doğru incelen; + iç uçlar aşağı (kızgın, sert), - iç uçlar yukarı (endişeli, çekingen)
	var bt: float = spec.get("brow", 1.0)
	var tilt: float = spec.get("brow_tilt", 8.0) * 0.7
	var by := r * BROW_Y
	brows.position = Vector3(0, by, _surf(r, hs, r * gap, by) - r * 0.015)
	var bc := hair.darkened(0.2)
	var thick := r * (0.028 + 0.016 * bt) * (0.8 if young else 1.0)
	if spec.get("unibrow", false):
		var u := capsule(brows, thick, r * 0.86, Vector3(0, 0, 0), bc, Vector3(0, 0, 90), thick * 0.75, false)
		u.scale = Vector3(1, 1, 0.6)
	else:
		for sx: int in [-1, 1]:
			var b := capsule(brows, thick, r * 0.36, Vector3(sx * r * (gap + 0.02), 0, 0), bc, Vector3(0, 0, 90 + sx * tilt), thick * 0.55, false)
			b.scale = Vector3(1, 1, 0.6)
	# Ağız: dudaklar (üst ince, alt dolgun) ve aralarındaki koyu açıklık (konuşurken açılır)
	var mw: float = lerpf(1.0, float(spec.get("mouth_w", 1.0)), 0.6)
	var my := r * MOUTH_Y * (0.92 if young else 1.0)
	var mz := maxf(_surf(r, hs, 0.0, my), r * 0.72) + r * 0.08
	var lip := skin.darkened(0.2).lerp(Color("a8544c"), 0.3)
	ball(fd, r * 0.13 * mw, Vector3(0, my + r * 0.032, mz - r * 0.02), lip, Vector3(1.0, 0.22, 0.42), false)
	ball(fd, r * 0.115 * mw, Vector3(0, my - r * 0.036, mz - r * 0.018), lip.lightened(0.06), Vector3(1.0, 0.3, 0.45), false)
	var mouth := ball(head, r * 0.12 * mw, Vector3(0, my, mz - r * 0.012), Color("3a1a18"), Vector3(1.0, 0.22, 0.35), false)
	return mouth


## Kafanın dış hatsız yüz ayrıntısı düğümü (yoksa kurulur)
static func face_detail(head: Node3D) -> Node3D:
	var fd := head.get_node_or_null("FaceDetail") as Node3D
	if fd == null:
		fd = Node3D.new()
		fd.name = "FaceDetail"
		head.add_child(fd)
	return fd


## Yüz yüzeyi: (x, y) noktasında kafa küresinin önünün z'si (yüz öğeleri yüze otursun diye)
static func _surf(r: float, hs: Vector3, x: float, y: float) -> float:
	var k := 1.0 - pow(x / (r * hs.x), 2.0) - pow(y / (r * hs.y), 2.0)
	return r * hs.z * sqrt(maxf(k, 0.05))


## Tasarlanmış yüzler (ana ve tarihî karakterler). Person görünüşünde "face": "fatih" gibi verilir.
const FACES := {
	"tolga": {"nose": "button", "nose_s": 1.2, "eye_s": 1.22, "eye_gap": 0.38, "brow": 0.9, "brow_tilt": -14.0, "head": Vector3(0.98, 1.1, 0.98), "mouth_w": 1.1},
	"fatih": {"nose": "hook", "nose_s": 1.15, "eye_s": 0.9, "eye_gap": 0.34, "lid": 0.3, "brow": 1.1, "brow_tilt": 12.0, "head": Vector3(0.94, 1.12, 0.98), "blush": false, "chin": 0.3},
	"emperor": {"nose": "long", "nose_s": 1.1, "eye_s": 0.9, "lid": 0.4, "bags": true, "wrinkles": true, "brow_tilt": -6.0, "head": Vector3(0.92, 1.15, 0.98), "blush": false},
	"giustiniani": {"nose": "long", "eye_s": 0.9, "brow": 1.3, "brow_tilt": 4.0, "chin": 0.8, "head": Vector3(1.06, 1.06, 0.98), "blush": false, "beard": "short"},
	"urban": {"nose": "bulb", "nose_s": 1.1, "eye_s": 1.05, "brow": 1.6, "brow_tilt": 16.0, "head": Vector3(1.12, 1.0, 1.0), "ears": 1.3, "mustache": "walrus"},
	"kadri": {"nose": "bulb", "eye_s": 0.85, "lid": 0.25, "brow": 1.4, "brow_tilt": 18.0, "head": Vector3(1.15, 1.02, 1.0), "mouth_w": 1.3, "mustache": "chevron"},
	"nihat": {"nose": "long", "nose_s": 0.9, "eye_s": 0.88, "lid": 0.35, "brow": 0.8, "brow_tilt": 0.0, "head": Vector3(0.9, 1.2, 0.98), "blush": false, "mouth_w": 0.8, "mustache": "pencil"},
	"lutfi": {"nose": "long", "nose_s": 1.2, "eye_s": 1.1, "brow_tilt": -14.0, "brow": 0.9, "head": Vector3(0.95, 1.1, 0.98), "mouth_w": 1.25},
	"niko": {"nose": "round", "nose_s": 1.2, "eye_s": 1.1, "brow": 1.3, "unibrow": true, "head": Vector3(1.1, 1.0, 1.0), "mouth_w": 1.3},
	"candarli": {"nose": "hook", "nose_s": 1.0, "eye_s": 0.85, "lid": 0.5, "wrinkles": true, "bags": true, "brow": 1.3, "brow_tilt": 14.0, "blush": false},
	"cardinal": {"nose": "long", "eye_s": 0.95, "lid": 0.3, "wrinkles": true, "brow_tilt": -4.0, "head": Vector3(0.95, 1.12, 0.98)},
}

const NOSES := ["round", "round", "long", "hook", "button", "bulb"]


## Figüranlar için tohumdan (seed) tutarlı ama birbirinden farklı yüz.
static func random_face(seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var heads := [Vector3(1.0, 1.06, 0.98), Vector3(0.92, 1.16, 0.98), Vector3(1.12, 0.98, 1.0), Vector3(1.04, 1.1, 1.0)]
	return {
		"head": heads[rng.randi() % heads.size()],
		"nose": NOSES[rng.randi() % NOSES.size()],
		"nose_s": rng.randf_range(0.85, 1.2),
		"eye_s": rng.randf_range(0.82, 1.2),
		"eye_gap": rng.randf_range(0.31, 0.41),
		"lid": 0.0 if rng.randf() < 0.6 else rng.randf_range(0.2, 0.5),
		"brow": rng.randf_range(0.75, 1.5),
		"brow_tilt": rng.randf_range(-12.0, 16.0),
		"unibrow": rng.randf() < 0.07,
		"ears": rng.randf_range(0.8, 1.3),
		"mouth_w": rng.randf_range(0.8, 1.25),
		"blush": rng.randf() < 0.5,
		"chin": 0.0 if rng.randf() < 0.7 else rng.randf_range(0.3, 0.9),
		"wrinkles": rng.randf() < 0.2,
		"bags": rng.randf() < 0.15,
		"mustache": ["curl", "walrus", "pencil", "chevron"][rng.randi() % 4],
		"beard": ["full", "goatee", "short"][rng.randi() % 3],
	}


## Bıyık: kıvrık ("curl"), pala ("walrus"), ince ("pencil"), kalın düz ("chevron").
static func mustache(head: Node3D, c: Color, r := 0.2, big := 1.0, style := "curl") -> void:
	# Burun ucuyla üst dudak arası; yüzeye yatık ve yassı, dış hatsız (yüz ayrıntısı)
	var fd := face_detail(head)
	var y := r * (MOUTH_Y + 0.13)
	var z := r * 0.9
	var bg := sqrt(big)
	match style:
		"walrus":
			ball(fd, r * 0.2 * bg, Vector3(0, y - r * 0.03, z), c, Vector3(1.5, 0.55, 0.45), false)
		"pencil":
			for sx: int in [-1, 1]:
				var p := capsule(fd, r * 0.018, r * 0.24, Vector3(sx * r * 0.12, y + r * 0.01, z + r * 0.03), c, Vector3(0, 0, 90 + sx * 8), -1.0, false)
				p.scale = Vector3(1, 1, 0.6)
		"chevron":
			for sx: int in [-1, 1]:
				var m := capsule(fd, r * 0.065 * bg, r * 0.3 * bg, Vector3(sx * r * 0.14, y, z + r * 0.01), c, Vector3(0, 0, 90 + sx * 10), r * 0.045 * bg, false)
				m.scale = Vector3(1, 1, 0.55)
		_:
			# Kıvrık: ortadan iki yana incelip ucu hafifçe kalkan, yassı bıyık
			for sx: int in [-1, 1]:
				var m := capsule(fd, r * 0.055 * bg, r * 0.36 * bg, Vector3(sx * r * 0.17 * minf(bg, 1.2), y - r * 0.01, z), c, Vector3(0, 0, 90 + sx * 14), r * 0.028 * bg, false)
				m.scale = Vector3(1, 1, 0.55)
				ball(fd, r * 0.028 * bg, Vector3(sx * r * 0.34 * minf(bg, 1.25), y + r * 0.04, z - r * 0.08), c, Vector3.ONE, false)


## Sakal: dolu ("full"), keçi ("goatee"), kısa ("short"). Çene ve yanakları örter, ağzın altından başlar.
static func beard(head: Node3D, c: Color, r := 0.2, style := "full") -> void:
	match style:
		"goatee":
			ball(head, r * 0.22, Vector3(0, -r * 0.88, r * 0.62), c, Vector3(0.9, 1.25, 0.75))
		"short":
			ball(head, r * 0.82, Vector3(0, -r * 0.48, r * 0.12), c, Vector3(1.0, 0.8, 1.0))
		_:
			ball(head, r * 0.66, Vector3(0, -r * 0.74, r * 0.34), c, Vector3(1.05, 0.95, 0.78))


## Şapka altından görünen saç: ense ve favoriler (fes, fötr, külah; kafa kel görünmesin).
static func hair_under_hat(head: Node3D, c: Color, r := 0.2, hs := Vector3.ZERO) -> void:
	if hs != Vector3.ZERO:
		# Şapkanın altında kafanın tepesini örten saç: fes, kavuk ya da börk kenarından deri değil saç görünür
		# (eskiden yalnız ense ve favoriler vardı; şapkalılar kel görünüyordu)
		_ell(head, Vector3(0, r * hs.y * 0.22, -r * hs.z * 0.12), Vector3(r * hs.x * 1.06, r * hs.y * 0.82, r * hs.z * 1.03), c)
	# Ense: kafanın arkasından taşan saç (yandan ve önden kenarı görünür)
	ball(head, r * 1.05, Vector3(0, r * 0.12, -r * 0.14), c, Vector3(1.03, 0.62, 0.95))
	for sx: int in [-1, 1]:
		# Favori: kulağın önünde, şapka kenarından aşağı
		ball(head, r * 0.24, Vector3(sx * r * 0.88, r * 0.28, r * 0.3), c, Vector3(0.55, 1.1, 0.9), false)


## Saç tipleri (şapkasız başlar). Kafa elipsoidinin (r · hs) üstünü tam örten bir kep üzerine kurulur: kepin önü
## alında kafanın içinde kalır, saç çizgisi kaşların üstünde belirir (eski kep kafanın tepesine yetişmiyordu: herkes
## tepeden kel görünüyordu). "bald" gerçekten keldir: yalnız ense ve yanlarda saç.
const HAIR_STYLES := ["short", "swept", "curly", "receding", "bald", "quiff", "long", "buzz", "bun", "wavy"]
const HAIR_COLORS := [Color("1a1614"), Color("2a1d16"), Color("3a2a1e"), Color("4a3222"), Color("5a3a1e"), Color("6a3a22"),
	Color("7a3a1a"), Color("a8864a"), Color("7a7470"), Color("b4b0a8")]


## Rastgele (tohumlu) saç: tip ve renk. Kadınlarda kel ve dökük yok; yaşlı yüzlerde (kırışık) kır saç ve dökük daha sık.
static func random_hair(seed: int, woman := false, old := false) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 2654435761 + 97
	var styles: Array
	var w: Array
	if woman:
		styles = ["long", "bun", "wavy", "curly", "swept"]
		w = [34, 30, 18, 10, 8]
	else:
		styles = ["short", "swept", "curly", "receding", "bald", "quiff", "long", "buzz", "wavy"]
		w = [26, 15, 11, 11 if not old else 22, 10 if not old else 24, 8, 4, 9, 6]
	var style: String = styles[_pick(rng, w)]
	var ci: int
	if old or rng.randf() < 0.08:
		ci = 8 + rng.randi() % 2
	else:
		ci = _pick(rng, [18, 20, 24, 14, 10, 7, 3, 3])
	var c: Color = HAIR_COLORS[ci]
	# Aynı renk ailesinde küçük ton farkı (kalabalıkta birebir aynı renk olmasın)
	c = c.lightened(rng.randf_range(0.0, 0.08)) if rng.randf() < 0.5 else c.darkened(rng.randf_range(0.0, 0.08))
	return {"style": style, "color": c}


static func _pick(rng: RandomNumberGenerator, weights: Array) -> int:
	var total := 0.0
	for x in weights:
		total += float(x)
	var v := rng.randf() * total
	for i in weights.size():
		v -= float(weights[i])
		if v <= 0.0:
			return i
	return weights.size() - 1


## Saçı kurar. hs: yüz tanımındaki kafa ölçeği (face spec "head").
static func hair(head: Node3D, c: Color, style: String, hs := Vector3(1.0, 1.06, 0.98), r := 0.2) -> void:
	var H := r * hs.y
	var W := r * hs.x
	var D := r * hs.z
	var dark := c.darkened(0.12)
	match style:
		"bald":
			# Tepe açık: ense ve kulak üstlerinde kalan saç
			_ell(head, Vector3(0, H * 0.02, -D * 0.22), Vector3(W * 1.05, H * 0.56, D * 0.9), c)
		"receding":
			_ell(head, Vector3(0, H * 0.22, -D * 0.3), Vector3(W * 1.05, H * 0.84, D * 0.92), c)
		"buzz":
			_ell(head, Vector3(0, H * 0.18, -D * 0.1), Vector3(W * 1.03, H * 0.86, D * 1.0), c)
		_:
			_ell(head, Vector3(0, H * 0.25, -D * 0.12), Vector3(W * 1.07, H * 0.83, D * 1.03), c)
	match style:
		"swept":
			# Yana taranmış perçem
			ball(head, 1.0, Vector3(W * 0.28, H * 0.78, D * 0.5), c, Vector3(W * 0.62, H * 0.24, D * 0.42), false)
			ball(head, 1.0, Vector3(-W * 0.35, H * 0.86, D * 0.25), dark, Vector3(W * 0.5, H * 0.2, D * 0.5), false)
		"curly":
			var k := 0
			for ring: float in [0.0, 0.55, 0.85]:
				var n := 1 if ring == 0.0 else (6 if ring < 0.8 else 8)
				for i in n:
					var a := TAU * (i + 0.5 * k) / float(n)
					var p := Vector3(sin(a) * W * ring * 0.95, H * (1.02 - ring * 0.42), cos(a) * D * ring * 0.9 - D * 0.1)
					if p.z > D * 0.55 and p.y < H * 0.75:
						continue
					ball(head, r * 0.26, p, c if (i + k) % 2 == 0 else dark, Vector3.ONE, false)
				k += 1
		"quiff":
			# Önde kabarık kâkül
			ball(head, 1.0, Vector3(0, H * 0.98, D * 0.32), c, Vector3(W * 0.72, H * 0.32, D * 0.6), false)
		"wavy":
			for i in 5:
				var a := -1.1 + i * 0.55
				ball(head, 1.0, Vector3(sin(a) * W * 0.8, H * 0.7, cos(a) * D * 0.25 - D * 0.35), dark if i % 2 == 0 else c,
					Vector3(W * 0.36, H * 0.3, D * 0.4), false)
			ball(head, 1.0, Vector3(0, -H * 0.05, -D * 0.62), c, Vector3(W * 0.95, H * 0.62, D * 0.42), false)
		"long":
			# Omuza dökülen saç: ense ve iki yan
			ball(head, 1.0, Vector3(0, -H * 0.45, -D * 0.55), c, Vector3(W * 1.0, H * 0.95, D * 0.45), false)
			for sx: int in [-1, 1]:
				ball(head, 1.0, Vector3(sx * W * 0.86, -H * 0.2, -D * 0.12), c, Vector3(W * 0.28, H * 0.75, D * 0.62), false)
		"bun":
			ball(head, r * 0.42, Vector3(0, H * 0.72, -D * 0.72), dark, Vector3.ONE, false)
	# Favoriler (kısa saçlarda kulağın önünde)
	if style in ["short", "swept", "receding", "buzz", "bald", "quiff", "curly"]:
		for sx: int in [-1, 1]:
			ball(head, r * 0.17, Vector3(sx * W * 0.9, H * 0.12, D * 0.22), c, Vector3(0.5, 1.15, 0.8), false)


## Birim küre, yarıçapları doğrudan ölçekle (dış hatlı: saç kütlesi karikatür çizgisini alır).
static func _ell(parent: Node3D, pos: Vector3, radii: Vector3, c: Color) -> void:
	_mi(parent, _sphere(1.0), pos, c, Vector3.ZERO, radii, true)


## Saç: kafanın üstünü ve arkasını saran kep, favoriler.
static func hair_cap(head: Node3D, c: Color, r := 0.2, volume := 1.0) -> void:
	ball(head, r * 1.04, Vector3(0, r * 0.18, -r * 0.1), c, Vector3(1.0, 0.72 * volume, 1.0))
	for sx: int in [-1, 1]:
		ball(head, r * 0.18, Vector3(sx * r * 0.9, r * 0.15, r * 0.25), c, Vector3(0.5, 1.2, 0.8), false)


# ---------------------------------------------------------------- birleştirme (performans)

static var _vc: Dictionary = {}

## Köşe renkli ortak karakter malzemesi (birleştirilmiş parçalar tek çizimde).
static func vc_mat(outline: bool) -> StandardMaterial3D:
	var key := "%s|%s" % [outline, Props.outlines]
	if _vc.has(key):
		return _vc[key]
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.vertex_color_is_srgb = true
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT_WRAP
	m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	m.roughness = 0.78
	m.metallic_specular = 0.25
	m.rim_enabled = true
	m.rim = 0.22
	m.rim_tint = 0.5
	# Karakterler gölge almaz (kendileri gölge düşürür): şapka, kavuk ya da çadır gölgesinde yüzler kararmasın
	m.disable_receive_shadows = true
	if outline and Props.outlines:
		m.next_pass = _outline()
	_vc[key] = m
	return m


## Karakteri kuruldu kurulalı birleştirir: her hareketli düğümün (pivots) altındaki sabit parçalar tek bir
## köşe renkli ağa dönüşür. keep: ayrı kalacak (canlandırılan) parçalar. no_outline: dış hatsız düğümler (göz, kaş).
static func bake(root: Node3D, pivots: Array, keep: Array = [], no_outline: Array = []) -> void:
	# Yüz ayrıntıları (burun, dudak, bıyık, kırışık): kafayla aynı ağa girerse her birinin çevresine dış hat çizilir;
	# ayrı ve dış hatsız pişirilir (kafayla birlikte döner, çünkü kafanın çocuğudur)
	pivots = pivots.duplicate()
	no_outline = no_outline.duplicate()
	for fd in root.find_children("FaceDetail", "Node3D", true, false):
		pivots.append(fd)
		no_outline.append(fd)
	# El ve ayak bilekleri ayrı döner: kendi ağlarına pişirilir
	for nm in ["Wrist", "Ankle"]:
		for j in root.find_children(nm, "Node3D", true, false):
			pivots.append(j)
	# Pişirilen parçaların boşalan kapları (capsule düğümleri): ağaçta kalırsa her harekette dönüşüm yayılımı onlardan da
	# geçer (şehirde onlarca kişi: kişi başına ~18 boş düğüm). Yalnız içinden parça alınmış kaplar silinir; baştan boş
	# duran çapa düğümlerine dokunulmaz.
	var emptied := {}
	for p in pivots:
		if p == null or not is_instance_valid(p):
			continue
		var list: Array = []
		_collect(p, p, pivots, keep, list)
		if list.size() < 2:
			continue
		for mi: MeshInstance3D in list:
			if mi.get_parent() != p:
				emptied[mi.get_parent()] = p
		var verts := PackedVector3Array()
		var norms := PackedVector3Array()
		var cols := PackedColorArray()
		var idx := PackedInt32Array()
		for mi: MeshInstance3D in list:
			var m := mi.material_override as StandardMaterial3D
			var c := m.albedo_color if m else Color.WHITE
			var xf: Transform3D = (p as Node3D).global_transform.affine_inverse() * mi.global_transform
			var nb := xf.basis.inverse().transposed()
			# Eşit ölçekte (kürenin kendisi basık değilse) normal dönüşümü dönmedir: köşeler, normaller ve renk motorun
			# toplu işlemleriyle (GDScript döngüsü yalnız basık parçaların normallerinde ve indekslerde)
			var sx := xf.basis.x.length()
			var uni := absf(xf.basis.y.length() - sx) < sx * 0.001 and absf(xf.basis.z.length() - sx) < sx * 0.001
			for si in mi.mesh.get_surface_count():
				var arr := mi.mesh.surface_get_arrays(si)
				var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				var n: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
				var ix: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
				var base := verts.size()
				verts.append_array(xf * v)
				if n.size() == v.size() and uni:
					norms.append_array(Transform3D(xf.basis / sx, Vector3.ZERO) * n)
				else:
					for k in v.size():
						norms.append((nb * n[k]).normalized() if n.size() > k else Vector3.UP)
				var cc := PackedColorArray()
				cc.resize(v.size())
				cc.fill(c)
				cols.append_array(cc)
				if ix.is_empty():
					for k in v.size():
						idx.append(base + k)
				else:
					for k in ix:
						idx.append(base + k)
			mi.get_parent().remove_child(mi)
			mi.queue_free()
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = verts
		arrays[Mesh.ARRAY_NORMAL] = norms
		arrays[Mesh.ARRAY_COLOR] = cols
		arrays[Mesh.ARRAY_INDEX] = idx
		var am := ArrayMesh.new()
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var out := MeshInstance3D.new()
		out.name = "Baked"
		out.mesh = am
		out.material_override = vc_mat(not (p in no_outline))
		(p as Node3D).add_child(out)
	var more := true
	while more:
		more = false
		for c: Node in emptied.keys():
			if not is_instance_valid(c) or c.is_queued_for_deletion():
				emptied.erase(c)
				continue
			if c.get_child_count() > 0 or c.get_class() != "Node3D" or c.get_script() != null or c in pivots or c in keep:
				continue
			var par := c.get_parent()
			var piv: Node = emptied[c]
			emptied.erase(c)
			par.remove_child(c)
			c.queue_free()
			# Üst kap da boşaldıysa o da gider (pivota kadar)
			if par != piv and par.get_class() == "Node3D":
				emptied[par] = piv
			more = true


static func _collect(pivot: Node, n: Node, pivots: Array, keep: Array, out: Array) -> void:
	for c in n.get_children():
		if c in pivots or c in keep:
			continue
		if c is MeshInstance3D:
			var mi := c as MeshInstance3D
			var m := mi.material_override as StandardMaterial3D
			# Dokulu, saydam ya da ışıyan parçalar kendi malzemesiyle kalır
			if mi.mesh and (m == null or (m.albedo_texture == null and m.albedo_color.a >= 1.0 and not m.emission_enabled)):
				out.append(mi)
		if c is Node3D and not (c is CollisionObject3D) and c.get_child_count() > 0:
			_collect(pivot, c, pivots, keep, out)
