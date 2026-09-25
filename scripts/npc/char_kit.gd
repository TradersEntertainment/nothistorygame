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
	cm.radial_segments = SEG
	cm.rings = 1
	_mi(n, cm, Vector3.ZERO, c, Vector3.ZERO, Vector3.ONE, outline)
	_mi(n, _sphere(r, 10), Vector3(0, -body * 0.5, 0), c, Vector3.ZERO, Vector3.ONE, outline)
	_mi(n, _sphere(rt, 10), Vector3(0, body * 0.5, 0), c, Vector3.ZERO, Vector3.ONE, outline)
	return n


static func _sphere(r: float, rings := 10) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = SEG + 2
	s.rings = rings
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
	# Ayakkabı: burnu yukarı kalkık, yassı yuvarlak (hafif palyaço)
	ball(knee, 0.075, Vector3(0, -shin + 0.045, 0.05), shoe, Vector3(1.0, 0.62, 1.75))
	ball(knee, 0.05, Vector3(0, -shin + 0.06, 0.15), shoe.lightened(0.05), Vector3(1.1, 0.7, 1.0), false)
	return knee


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
	ball(elbow, 0.058, Vector3(0, -fore - 0.01, 0.01), skin, Vector3(0.9, 1.1, 0.75))
	ball(elbow, 0.022, Vector3(0.0, -fore + 0.01, 0.055), skin, Vector3(1, 1.3, 1), false)
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


## Yüz: kafa küresi, kulaklar, iri burun, ak+bebekli gözler (eyes düğümüne), kaşlar (brows), ağız.
## Döner: ağız (konuşma animasyonu ölçekler).
## Yüz: kişiye özgü. spec (hepsi isteğe bağlı): head (baş ölçeği), nose ("round"/"long"/"hook"/"button"/"bulb"),
## nose_s, eye_s, eye_gap, lid (göz kapağı 0..0.6), brow (kalınlık), brow_tilt (derece; + kızgın, - endişeli),
## unibrow, ears, mouth_w, blush, wrinkles, chin (çene çıkıntısı 0..1), bags (göz altı torbası).
static func face(head: Node3D, eyes: Node3D, brows: Node3D, skin: Color, hair: Color, r := 0.2, nose := 1.0, spec := {}) -> MeshInstance3D:
	var hs: Vector3 = spec.get("head", Vector3(1.0, 1.06, 0.98))
	ball(head, r, Vector3.ZERO, skin, hs)
	var fz := r * hs.z             # yüz yüzeyi (z)
	# Kulaklar
	var es: float = spec.get("ears", 1.0)
	for sx: int in [-1, 1]:
		ball(head, r * 0.24 * es, Vector3(sx * r * 0.98 * hs.x, -0.01, -0.01), skin.darkened(0.04), Vector3(0.55, 1.0, 0.85))
	# Burun
	var ns: float = spec.get("nose_s", 1.0) * nose
	var nc := skin.darkened(0.1)
	match str(spec.get("nose", "round")):
		"long":
			ball(head, r * 0.17 * ns, Vector3(0, -0.01, fz * 0.98), nc, Vector3(0.85, 1.0, 1.9))
		"hook":
			# Kemerli (Fatih portrelerindeki gibi): köprüde çıkıntı, ucu aşağı eğik
			ball(head, r * 0.15 * ns, Vector3(0, r * 0.06, fz * 0.97), nc, Vector3(0.75, 1.5, 1.35))
			ball(head, r * 0.14 * ns, Vector3(0, -r * 0.1, fz * 1.12), nc, Vector3(0.9, 1.0, 1.0))
		"button":
			ball(head, r * 0.13 * ns, Vector3(0, -0.02, fz * 0.99), nc, Vector3(1.1, 0.9, 1.0))
		"bulb":
			ball(head, r * 0.3 * ns, Vector3(0, -0.035, fz * 0.94), skin.lerp(Color("d0605a"), 0.25).darkened(0.05), Vector3(1.05, 0.95, 1.0))
		_:
			ball(head, r * 0.23 * ns, Vector3(0, -0.02, fz * 0.96), nc, Vector3(1.0, 1.05, 1.1))
	# Yanak kızarıklığı
	if spec.get("blush", true):
		for sx: int in [-1, 1]:
			ball(head, r * 0.16, Vector3(sx * r * 0.52 * hs.x, -0.06, fz * 0.78), skin.lerp(Color("e0706a"), 0.3), Vector3(1.0, 0.6, 0.4), false)
	# Çene
	var chin: float = spec.get("chin", 0.0)
	if chin > 0.0:
		ball(head, r * (0.3 + chin * 0.15), Vector3(0, -r * 0.82 * hs.y, fz * 0.55), skin, Vector3(1.2, 0.7, 0.9))
	# Kırışıklıklar ve göz altı torbaları
	if spec.get("wrinkles", false):
		for k in 2:
			var w := capsule(head, r * 0.018, r * 0.5 - k * r * 0.1, Vector3(0, r * (0.72 + k * 0.12), fz * 0.72 - k * r * 0.08), skin.darkened(0.28), Vector3(0, 0, 90), -1.0, false)
			w.scale = Vector3(1, 1, 0.5)
	# Gözler: ak (yassı), bebek (koyu), parlama noktası; göz düğümü kırpma/bakış için Rig'e gider
	var eys: float = spec.get("eye_s", 1.0)
	var gap: float = spec.get("eye_gap", 0.36)
	var lid: float = spec.get("lid", 0.0)
	eyes.position = Vector3(0, r * 0.25, fz * 0.88)
	for sx: int in [-1, 1]:
		var x := sx * r * gap
		ball(eyes, r * 0.2 * eys, Vector3(x, 0, 0), Color("f6f2ea"), Vector3(0.9, 1.1, 0.5), false)
		ball(eyes, r * 0.11 * eys * float(spec.get("pupil", 1.0)), Vector3(x, -0.005, r * 0.08), Color("1a1614"), Vector3(1, 1.15, 0.6), false)
		ball(eyes, r * 0.035 * eys, Vector3(x + r * 0.035, r * 0.04, r * 0.12), Color.WHITE, Vector3.ONE, false)
		if lid > 0.0:
			# Göz kapağı: gözün üst kısmını örten deri (uykulu, yorgun ya da şüpheci bakış)
			ball(eyes, r * 0.215 * eys, Vector3(x, r * 0.2 * eys * (1.0 - lid) , r * 0.03), skin.darkened(0.06), Vector3(0.95, 0.6, 0.62), false)
		if spec.get("bags", false):
			ball(head, r * 0.13 * eys, Vector3(x, r * 0.02, fz * 0.83), skin.darkened(0.14), Vector3(1.2, 0.45, 0.4), false)
	# Kaşlar
	var bt: float = spec.get("brow", 1.0)
	var tilt: float = spec.get("brow_tilt", 8.0)
	brows.position = Vector3(0, r * (0.52 + (0.04 if eys > 1.1 else 0.0)), fz * 0.92)
	var bc := hair.darkened(0.15)
	if spec.get("unibrow", false):
		var u := capsule(brows, r * 0.07 * bt, r * 0.95, Vector3(0, 0, 0), bc, Vector3(0, 0, 90), r * 0.05 * bt, false)
		u.scale = Vector3(1, 1, 0.7)
	else:
		for sx: int in [-1, 1]:
			var b := capsule(brows, r * 0.07 * bt, r * 0.42, Vector3(sx * r * gap, 0, 0), bc, Vector3(0, 0, 90 - sx * tilt), r * 0.05 * bt, false)
			b.scale = Vector3(1, 1, 0.7)
	# Ağız: koyu, yuvarlak uçlu çizgi
	var mouth := ball(head, r * 0.2 * float(spec.get("mouth_w", 1.0)), Vector3(0, -r * 0.52, fz * 0.92), Color("5a2420"), Vector3(1.0, 0.22, 0.4), false)
	return mouth


## Tasarlanmış yüzler (ana ve tarihî karakterler). Person görünüşünde "face": "fatih" gibi verilir.
const FACES := {
	"tolga": {"nose": "button", "nose_s": 1.2, "eye_s": 1.22, "eye_gap": 0.38, "brow": 0.9, "brow_tilt": -8.0, "head": Vector3(0.98, 1.1, 0.98), "mouth_w": 1.1},
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
	match style:
		"walrus":
			ball(head, r * 0.3 * big, Vector3(0, -r * 0.36, r * 0.9), c, Vector3(1.45, 0.62, 0.5), false)
		"pencil":
			for sx: int in [-1, 1]:
				var p := capsule(head, r * 0.035, r * 0.34, Vector3(sx * r * 0.18, -r * 0.33, r * 0.95), c, Vector3(0, 0, 90 + sx * 6), -1.0, false)
				p.scale = Vector3(1, 1, 0.7)
		"chevron":
			for sx: int in [-1, 1]:
				var m := capsule(head, r * 0.13 * big, r * 0.4 * big, Vector3(sx * r * 0.2, -r * 0.34, r * 0.93), c, Vector3(0, 0, 90 + sx * 4), r * 0.1 * big, false)
				m.scale = Vector3(1, 1, 0.8)
		_:
			for sx: int in [-1, 1]:
				var m := capsule(head, r * 0.12 * big, r * 0.55 * big, Vector3(sx * r * 0.26 * minf(big, 1.2), -r * 0.32, r * 0.92), c, Vector3(0, 0, 90 + sx * 16), r * 0.06 * big, false)
				m.scale = Vector3(1, 1, 0.85)
				ball(head, r * 0.06 * big, Vector3(sx * r * 0.52 * big, -r * 0.2, r * 0.8), c, Vector3.ONE, false)


## Sakal: dolu ("full"), keçi ("goatee"), kısa ("short").
static func beard(head: Node3D, c: Color, r := 0.2, style := "full") -> void:
	match style:
		"goatee":
			ball(head, r * 0.26, Vector3(0, -r * 0.8, r * 0.72), c, Vector3(0.9, 1.3, 0.8))
		"short":
			ball(head, r * 0.98, Vector3(0, -r * 0.3, r * 0.08), c, Vector3(1.02, 0.72, 0.96))
		_:
			ball(head, r * 0.72, Vector3(0, -r * 0.62, r * 0.4), c, Vector3(1.05, 0.9, 0.7))


## Şapka altından görünen saç: ense ve favoriler (fes, fötr, külah; kafa kel görünmesin).
static func hair_under_hat(head: Node3D, c: Color, r := 0.2) -> void:
	# Ense: kafanın arkasından taşan saç (yandan ve önden kenarı görünür)
	ball(head, r * 1.05, Vector3(0, r * 0.12, -r * 0.14), c, Vector3(1.03, 0.62, 0.95))
	for sx: int in [-1, 1]:
		# Favori: kulağın önünde, şapka kenarından aşağı
		ball(head, r * 0.24, Vector3(sx * r * 0.88, r * 0.28, r * 0.3), c, Vector3(0.55, 1.1, 0.9), false)


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
	for p in pivots:
		if p == null or not is_instance_valid(p):
			continue
		var list: Array = []
		_collect(p, p, pivots, keep, list)
		if list.size() < 2:
			continue
		var verts := PackedVector3Array()
		var norms := PackedVector3Array()
		var cols := PackedColorArray()
		var idx := PackedInt32Array()
		for mi: MeshInstance3D in list:
			var m := mi.material_override as StandardMaterial3D
			var c := m.albedo_color if m else Color.WHITE
			var xf: Transform3D = (p as Node3D).global_transform.affine_inverse() * mi.global_transform
			var nb := xf.basis.inverse().transposed()
			for si in mi.mesh.get_surface_count():
				var arr := mi.mesh.surface_get_arrays(si)
				var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				var n: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
				var ix: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
				var base := verts.size()
				for k in v.size():
					verts.append(xf * v[k])
					norms.append((nb * n[k]).normalized() if n.size() > k else Vector3.UP)
					cols.append(c)
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
