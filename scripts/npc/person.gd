class_name Person
extends Node3D
## Genel low-poly insan: Büro memurları, Başdenetçi ve Paradoks İzi'ndeki hologram Tolga.
## Kıyafet, saç, şapka (none/fez/fedora/bun), gözlük ve bıyık seçilebilir.
## Sağ bacak kalçadan döner (tekme), sağ kol omuzdan (el sallama, damga vurma).

signal kick_hit

var coat := Color("3d4a5c")
var pants := Color("2b2f38")
var skin := Color("e0a57e")
var hair := Color("3a2a1e")
var hat := "none"
var glasses := false
var mustache := false
var skirt := false
var beard := false
var apron := Color(0, 0, 0, 0)
var robe := Color(0, 0, 0, 0)
var talking := false
var look_target: Node3D

var _body: Node3D
var activity := ""
var _head: Node3D
var _mouth: MeshInstance3D
var _arm_r: Node3D
var _arm_l: Node3D
var _leg_r: Node3D
var _leg_l: Node3D
var _knee_l: Node3D
var _knee_r: Node3D
var _elbow_l: Node3D
var _elbow_r: Node3D
var _eyes: Node3D
var _brows: Node3D
var _t := 0.0
var _busy := false
var rig: Rig


## Yüz: görünüşte "face" ("fatih" gibi tasarlanmış bir ad ya da sözlük) yoksa görünüşten türeyen tohumla rastgele.
## Aynı görünüşteki figüranlar (kalabalık listeleri) sırayla farklı yüz alır; ilk örnek hep aynı yüzü taşır.
var face_spec: Dictionary = {}
static var _look_count: Dictionary = {}
const SKINS := [Color("e8b894"), Color("e0a882"), Color("d9a07a"), Color("c98e6a"), Color("ecc0a0"), Color("b8805c")]


func _init(p := {}) -> void:
	var seed := hash(str(p))
	var n: int = _look_count.get(seed, 0)
	_look_count[seed] = n + 1
	var fk = p.get("face", null)
	if fk is String and CharKit.FACES.has(fk):
		face_spec = (CharKit.FACES[fk] as Dictionary).duplicate()
	elif fk is Dictionary:
		face_spec = fk
	else:
		face_spec = CharKit.random_face(seed + n * 7919)
		if not p.has("skin"):
			skin = SKINS[absi(seed + n * 31) % SKINS.size()]
	coat = p.get("coat", coat)
	pants = p.get("pants", pants)
	skin = p.get("skin", skin)
	hair = p.get("hair", hair)
	hat = p.get("hat", hat)
	glasses = p.get("glasses", glasses)
	mustache = p.get("mustache", mustache)
	skirt = p.get("skirt", skirt)
	beard = p.get("beard", beard)
	apron = p.get("apron", apron)
	robe = p.get("robe", robe)


func _ready() -> void:
	_t = randf() * 10.0
	add_to_group("persons")
	_body = Node3D.new()
	add_child(_body)
	# Bacaklar (kalçadan döner), yuvarlak ayakkabılar — CharKit: yumuşak, karikatür oranlı parçalar
	var shoe := Color("2a2420")
	_leg_l = Node3D.new()
	_leg_l.position = Vector3(-0.1, 0.66, 0)
	_body.add_child(_leg_l)
	_knee_l = CharKit.leg(_leg_l, pants, shoe)
	_leg_r = Node3D.new()
	_leg_r.position = Vector3(0.1, 0.66, 0)
	_body.add_child(_leg_r)
	_knee_r = CharKit.leg(_leg_r, pants, shoe)
	if skirt:
		Props.cyl(_body, 0.2, 0.45, Vector3(0, 0.55, 0), pants, Vector3.ZERO, 14, 0.25)
	# Gövde, boyun, yaka (sakallı/bıyıklı olanlar biraz göbekli: mizah)
	CharKit.torso(_body, coat, skin, 0.25, 0.6 if beard else 0.0)
	if robe.a > 0.0:
		# Uzun kaftan / cüppe: dizlere kadar, etekte hafif açılır
		Props.cyl(_body, 0.32, 0.78, Vector3(0, 0.56, 0), robe, Vector3.ZERO, 14, 0.25)
		Props.cyl(_body, 0.325, 0.06, Vector3(0, 0.2, 0), robe.darkened(0.18), Vector3.ZERO, 14)
	if apron.a > 0.0:
		Props.box(_body, Vector3(0.38, 0.62, 0.03), Vector3(0, 0.8, 0.25), apron)
	Props.prism(_body, Vector3(0.17, 0.12, 0.04), Vector3(0, 1.3, 0.21), Color("f1ede2"), Vector3(180, 0, 0))
	# Kollar
	_arm_l = Node3D.new()
	_arm_l.position = Vector3(-0.3, 1.28, 0)
	_body.add_child(_arm_l)
	_elbow_l = CharKit.arm(_arm_l, coat, skin)
	_arm_r = Node3D.new()
	_arm_r.position = Vector3(0.3, 1.28, 0)
	_body.add_child(_arm_r)
	_elbow_r = CharKit.arm(_arm_r, coat, skin)
	# Kafa: iri gözler, iri burun, kalın kaşlar
	_head = Node3D.new()
	_head.position = Vector3(0, 1.58, 0)
	_body.add_child(_head)
	_eyes = Node3D.new()
	_head.add_child(_eyes)
	_brows = Node3D.new()
	_head.add_child(_brows)
	_mouth = CharKit.face(_head, _eyes, _brows, skin, hair, 0.2, 1.15 if mustache else 1.0, face_spec)
	if mustache:
		CharKit.mustache(_head, hair, 0.2, 1.1 if beard else 1.0, str(face_spec.get("mustache", "curl")))
	if beard:
		CharKit.beard(_head, hair, 0.2, str(face_spec.get("beard", "full")))
	if glasses:
		Props.ring(_head, 0.045, 0.058, Vector3(-0.072, 0.05, 0.2), Color("222222"), Vector3(90, 0, 0))
		Props.ring(_head, 0.045, 0.058, Vector3(0.072, 0.05, 0.2), Color("222222"), Vector3(90, 0, 0))
		Props.box(_head, Vector3(0.05, 0.01, 0.01), Vector3(0, 0.055, 0.205), Color("222222"))
	# Saç ve şapka (şapkalılarda ense ve favoriler görünür)
	if hat in ["fez", "fedora", "cook", "helm", "plume", "turban", "sultan", "condottiero", "kalpak", "vizier", "galero", "berretta"]:
		CharKit.hair_under_hat(_head, hair)
	match hat:
		"fez":
			Props.cyl(_head, 0.15, 0.2, Vector3(0, 0.25, 0), Color("b3262d"), Vector3.ZERO, 8, 0.12)
			Props.cyl(_head, 0.008, 0.16, Vector3(0.08, 0.28, -0.06), Color("141414"), Vector3(0, 0, 30), 4)
		"fedora":
			Props.cyl(_head, 0.3, 0.03, Vector3(0, 0.17, 0), Color("4a4038"), Vector3(-6, 0, 0), 10)
			Props.cyl(_head, 0.19, 0.18, Vector3(0, 0.27, 0), Color("4a4038"), Vector3.ZERO, 8, 0.16)
			Props.cyl(_head, 0.195, 0.05, Vector3(0, 0.2, 0), Color("1f1b18"), Vector3.ZERO, 8)
		"helm":
			# Bizans miğferi: sivri, burun korumalı, altında zincir zırh
			# Kenarı kaşların üstünde: gözler görünsün
			Props.cyl(_head, 0.235, 0.24, Vector3(0, 0.24, -0.01), Color("8e949c"), Vector3.ZERO, 8, 0.02)
			Props.cyl(_head, 0.24, 0.05, Vector3(0, 0.13, -0.01), Color("6e747c"), Vector3.ZERO, 8)
			Props.box(_head, Vector3(0.035, 0.1, 0.03), Vector3(0, 0.1, 0.225), Color("8e949c"))
			Props.cyl(_head, 0.24, 0.2, Vector3(0, -0.12, -0.03), Color("7a7f86"), Vector3.ZERO, 8, 0.22)
		"cook":
			# Aşçıbaşı külahı: uzun, beyaz, hafif şişkin
			Props.cyl(_head, 0.2, 0.08, Vector3(0, 0.15, 0), Color("e8e2d4"), Vector3.ZERO, 8)
			Props.cyl(_head, 0.2, 0.42, Vector3(0, 0.38, 0), Color("f6f2e8"), Vector3.ZERO, 8, 0.24)
		"turban":
			Props.ball(_head, 0.25, Vector3(0, 0.16, 0), Color("f3efe4"), Vector3(1.1, 0.75, 1.1), 10)
			Props.ball(_head, 0.06, Vector3(0, 0.26, 0.2), Color("2f5fa8"), Vector3.ONE, 6)
		"sultan":
			_sultan()
		"stemma":
			_basileus()
		"condottiero":
			_condottiero()
		"kalpak":
			_kalpak()
		"vizier":
			_vizier()
		"galero":
			_galero()
		"berretta":
			_berretta()
		"crown":
			# İmparator: altın taç, mor kenar
			Props.ball(_head, 0.215, Vector3(0, 0.06, -0.03), hair, Vector3(1.02, 0.9, 1.0), 10)
			Props.cyl(_head, 0.2, 0.14, Vector3(0, 0.2, 0), Color("d8b040"), Vector3.ZERO, 10)
			Props.cyl(_head, 0.205, 0.03, Vector3(0, 0.14, 0), Color("5a2a6a"), Vector3.ZERO, 10)
			for i in 4:
				var a := TAU * i / 4.0
				Props.ball(_head, 0.03, Vector3(sin(a) * 0.2, 0.22, cos(a) * 0.2), Color("c8323a"), Vector3.ONE, 5)
		"hood":
			Props.ball(_head, 0.25, Vector3(0, 0.04, -0.04), Color("2a2a30"), Vector3(1.0, 1.1, 1.05), 10)
		"kamelaukion":
			# Bizans memur külahı: silindir, kırmızı
			Props.ball(_head, 0.215, Vector3(0, 0.06, -0.03), hair, Vector3(1.02, 0.9, 1.0), 10)
			Props.cyl(_head, 0.19, 0.26, Vector3(0, 0.27, 0), Color("8a2b22"), Vector3.ZERO, 8, 0.2)
			Props.cyl(_head, 0.2, 0.04, Vector3(0, 0.16, 0), Color("c49a45"), Vector3.ZERO, 8)
		"plume":
			# Cenevizli komutan: miğfer ve kırmızı sorguç
			Props.cyl(_head, 0.235, 0.22, Vector3(0, 0.22, -0.01), Color("a8aeb6"), Vector3.ZERO, 8, 0.18)
			Props.box(_head, Vector3(0.05, 0.3, 0.2), Vector3(0, 0.44, -0.02), Color("c8262f"), Vector3(-15, 0, 0))
		"bun":
			Props.ball(_head, 0.215, Vector3(0, 0.05, -0.02), hair, Vector3(1.02, 1.0, 1.02), 10)
			Props.ball(_head, 0.1, Vector3(0, 0.2, -0.16), hair, Vector3.ONE, 8)
		_:
			CharKit.hair_cap(_head, hair)

	# Parçaları hareketli düğüm başına tek ağda birleştir (60 parça yerine ~9 çizim)
	CharKit.bake(self, [_body, _leg_l, _leg_r, _knee_l, _knee_r, _arm_l, _arm_r, _elbow_l, _elbow_r, _head, _eyes, _brows], [_mouth], [_eyes, _brows])
	_make_rig()


## Fatih'in padişah kıyafeti (Nakkaş Sinan Bey ve Bellini portrelerinden): kırmızı kavuğun çevresine sarılmış iri
## beyaz kavuk sarığı, önde mücevherli sorguç ve tüy; samur kürk yakalı ve kürk şeritli kapaniçe (üst kaftan),
## çintemani desenli etek, arkadan sarkan uzun yenler, mücevherli kuşak ve hançer. Başka kimse böyle giyinmez.
func _sultan() -> void:
	var white := Color("f6f2e6")
	var red := Color("c8262f")
	var gold := Color("e0b440")
	var fur := Color("5a3a22")
	# Kavuk: uzun kırmızı külah ve çevresinde iri, yumurta biçimli beyaz sarık
	Props.cyl(_head, 0.12, 0.34, Vector3(0, 0.6, -0.01), red, Vector3.ZERO, 10, 0.08)
	Props.ball(_head, 0.3, Vector3(0, 0.36, -0.02), white, Vector3(1.2, 0.78, 1.15), 12)
	for k in 3:
		Props.ring(_head, 0.3 - k * 0.02, 0.33 - k * 0.02, Vector3(0, 0.25 + k * 0.09, -0.02), Color("e6dcc6"), Vector3(8 - k * 6, 0, 0))
	# Sorguç: altın ve yakut broş, beyaz balıkçıl tüyü
	Props.ball(_head, 0.055, Vector3(0, 0.4, 0.34), gold, Vector3(1, 1, 0.5), 8)
	Props.ball(_head, 0.03, Vector3(0, 0.4, 0.37), Color("b0101a"), Vector3.ONE, 6)
	Props.box(_head, Vector3(0.025, 0.34, 0.08), Vector3(0.0, 0.6, 0.29), white, Vector3(-18, 0, 0))
	Props.box(_head, Vector3(0.02, 0.24, 0.05), Vector3(0.05, 0.57, 0.28), Color("1a1a1a"), Vector3(-22, 0, 12))
	# Kapaniçe: samur kürk yaka ve önde kürk şeritler, kırmızı-altın kaftan
	Props.ring(_body, 0.2, 0.31, Vector3(0, 1.33, 0), fur, Vector3(-6, 0, 0))
	for sx in [-0.09, 0.09]:
		Props.box(_body, Vector3(0.07, 1.05, 0.05), Vector3(sx, 0.72, 0.3), fur)
	Props.box(_body, Vector3(0.1, 1.0, 0.04), Vector3(0, 0.72, 0.29), gold.darkened(0.15))
	# Çintemani: eteğe üçlü altın benekler
	for i in 8:
		var a := TAU * (i + 0.5) / 8.0
		if absf(wrapf(a, -PI, PI)) < 0.5:
			continue
		for k in 3:
			var off := Vector3(0.035 * (k - 1), 0.02 if k == 1 else 0.0, 0).rotated(Vector3.UP, a)
			Props.ball(_body, 0.022, Vector3(sin(a) * 0.3, 0.42, cos(a) * 0.3) + off, gold, Vector3(1, 1, 0.5), 5)
	# Mücevherli kuşak ve hançer
	Props.cyl(_body, 0.27, 0.08, Vector3(0, 0.98, 0), gold, Vector3.ZERO, 12)
	Props.ball(_body, 0.035, Vector3(0, 0.98, 0.27), Color("2a8a4a"), Vector3.ONE, 6)
	Props.box(_body, Vector3(0.05, 0.22, 0.03), Vector3(0.12, 0.93, 0.26), gold, Vector3(0, 0, -25))
	# Arkadan sarkan uzun yenler
	for arm in [_arm_l, _arm_r]:
		Props.box(arm, Vector3(0.13, 0.75, 0.05), Vector3(0, -0.42, -0.12), robe if robe.a > 0.0 else red)


## Son Bizans imparatoru XI. Konstantinos Palaiologos: kubbeli altın stemma tacı, iki yanda inci sarkıtlar (pendilia),
## tepede haç; mor kaftanın üstünde çapraz mücevherli altın loros, göğüste Palaiologos'ların çift başlı kartalı,
## ayakta imparatorluk kırmızısı çizmeler (tzangia).
func _basileus() -> void:
	var gold := Color("e0b440")
	var pearl := Color("f4f0e6")
	Props.ball(_head, 0.215, Vector3(0, 0.06, -0.03), hair, Vector3(1.02, 0.9, 1.0), 10)
	Props.cyl(_head, 0.2, 0.1, Vector3(0, 0.19, 0), gold, Vector3.ZERO, 12)
	Props.ball(_head, 0.2, Vector3(0, 0.23, 0), gold, Vector3(1, 0.75, 1), 12)
	for i in 6:
		var a := TAU * i / 6.0
		Props.ball(_head, 0.03, Vector3(sin(a) * 0.205, 0.19, cos(a) * 0.205), Color("b0101a") if i % 2 == 0 else Color("1a7a4a"), Vector3.ONE, 5)
	Props.box(_head, Vector3(0.03, 0.12, 0.03), Vector3(0, 0.43, 0), gold)
	Props.box(_head, Vector3(0.08, 0.03, 0.03), Vector3(0, 0.45, 0), gold)
	for sx in [-1, 1]:
		for k in 4:
			Props.ball(_head, 0.022, Vector3(sx * 0.2, 0.12 - k * 0.055, 0.04), pearl, Vector3.ONE, 5)
	# Loros: omuzdan çapraz inen mücevherli altın kuşak
	for sx in [-1, 1]:
		Props.box(_body, Vector3(0.1, 0.75, 0.03), Vector3(sx * 0.1, 0.95, 0.27), gold, Vector3(0, 0, sx * 22))
	Props.box(_body, Vector3(0.12, 0.6, 0.03), Vector3(0, 0.45, 0.33), gold)
	for k in 5:
		Props.ball(_body, 0.02, Vector3(0, 0.25 + k * 0.1, 0.35), Color("b0101a") if k % 2 == 0 else Color("1a7a4a"), Vector3.ONE, 5)
	# Çift başlı kartal (Palaiologos arması)
	Props.ball(_body, 0.055, Vector3(0, 1.12, 0.265), gold, Vector3(1.4, 1, 0.3), 6)
	for sx in [-1, 1]:
		Props.ball(_body, 0.025, Vector3(sx * 0.05, 1.19, 0.27), gold, Vector3.ONE, 5)
	# Tzangia: kırmızı imparatorluk çizmeleri
	for leg in [_knee_l, _knee_r]:
		Props.box(leg, Vector3(0.14, 0.12, 0.22), Vector3(0, -0.3, 0.04), Color("b0101a"))


## Giovanni Giustiniani Longo: Milano işi tam plaka zırh (göğüslük, omuzluklar), üstte Ceneviz haçlı (Aziz George)
## beyaz tabar, sorguçlu miğfer, belde kılıç.
func _condottiero() -> void:
	var steel := Color("a8aeb6")
	Props.cyl(_head, 0.235, 0.22, Vector3(0, 0.22, -0.01), steel, Vector3.ZERO, 8, 0.18)
	Props.cyl(_head, 0.24, 0.04, Vector3(0, 0.12, -0.01), steel.darkened(0.2), Vector3.ZERO, 8)
	Props.box(_head, Vector3(0.05, 0.3, 0.2), Vector3(0, 0.44, -0.02), Color("c8262f"), Vector3(-15, 0, 0))
	Props.box(_head, Vector3(0.05, 0.22, 0.15), Vector3(0, 0.42, -0.14), Color("f4f0e6"), Vector3(-30, 0, 0))
	for arm in [_arm_l, _arm_r]:
		Props.ball(arm, 0.13, Vector3(0, -0.02, 0), steel, Vector3(1.1, 0.8, 1.1), 8)
	Props.box(_body, Vector3(0.44, 0.62, 0.03), Vector3(0, 0.88, 0.25), Color("f4f0e6"))
	Props.box(_body, Vector3(0.09, 0.62, 0.035), Vector3(0, 0.88, 0.26), Color("c8262f"))
	Props.box(_body, Vector3(0.44, 0.09, 0.035), Vector3(0, 1.0, 0.26), Color("c8262f"))
	Props.box(_body, Vector3(0.05, 0.6, 0.04), Vector3(-0.3, 0.55, 0.12), Color("6a6e74"), Vector3(0, 0, 10))
	Props.box(_body, Vector3(0.16, 0.03, 0.05), Vector3(-0.31, 0.86, 0.12), Color("c49a45"))


## Macar işi kalpak (Urban, Macar elçisi): kürk, kumaş tepe; elçide mücevherli balıkçıl tüyü (forgó) ve tek omza atılmış
## kürk yakalı mente.
func _kalpak() -> void:
	var fur := Color("4a3222")
	Props.cyl(_head, 0.21, 0.24, Vector3(0, 0.22, 0), fur, Vector3.ZERO, 12, 0.19)
	Props.ball(_head, 0.17, Vector3(0.05, 0.36, -0.02), coat.darkened(0.1), Vector3(1, 0.5, 1), 8)
	if apron.a <= 0.0:
		Props.ball(_head, 0.035, Vector3(0.12, 0.26, 0.17), Color("e0b440"), Vector3.ONE, 6)
		Props.box(_head, Vector3(0.02, 0.3, 0.05), Vector3(0.14, 0.42, 0.14), Color("f4f0e6"), Vector3(-10, 0, -15))
		Props.box(_body, Vector3(0.5, 0.85, 0.04), Vector3(-0.08, 0.85, -0.26), coat.darkened(0.25), Vector3(0, 0, -8))
		Props.ring(_body, 0.18, 0.26, Vector3(-0.06, 1.33, -0.02), fur, Vector3(-8, 0, 12))
		for k in 4:
			Props.ball(_body, 0.025, Vector3(0, 0.75 + k * 0.12, 0.26), Color("e0b440"), Vector3.ONE, 5)


## Osmanlı veziri (Çandarlı Halil, Saruca): padişahınkinden sade, beyaz, yüksek kallavi sarık; sorguçsuz; kürk yakalı
## uzun kaftan.
func _vizier() -> void:
	Props.cyl(_head, 0.16, 0.36, Vector3(0, 0.34, -0.02), Color("f6f2e6"), Vector3.ZERO, 10, 0.12)
	Props.ball(_head, 0.27, Vector3(0, 0.2, -0.02), Color("f3efe4"), Vector3(1.15, 0.72, 1.1), 10)
	Props.ring(_head, 0.27, 0.3, Vector3(0, 0.18, -0.02), Color("e6dcc6"), Vector3(10, 0, 0))
	Props.ring(_body, 0.2, 0.29, Vector3(0, 1.33, 0), Color("6a4a30"), Vector3(-6, 0, 0))
	for arm in [_arm_l, _arm_r]:
		Props.box(arm, Vector3(0.12, 0.6, 0.05), Vector3(0, -0.38, -0.11), robe if robe.a > 0.0 else coat)


## Kardinal Isidoros: geniş kenarlı kırmızı kardinal şapkası (galero) ve sarkan püsküller, kırmızı pelerin (cappa).
func _galero() -> void:
	var red := Color("b3262d")
	Props.ball(_head, 0.215, Vector3(0, 0.06, -0.03), hair, Vector3(1.02, 0.9, 1.0), 10)
	Props.cyl(_head, 0.38, 0.03, Vector3(0, 0.19, 0), red, Vector3.ZERO, 16)
	Props.cyl(_head, 0.19, 0.1, Vector3(0, 0.25, 0), red, Vector3.ZERO, 12, 0.17)
	for sx in [-1, 1]:
		Props.cyl(_head, 0.008, 0.45, Vector3(sx * 0.32, -0.04, 0), red.darkened(0.2), Vector3.ZERO, 4)
		Props.ball(_head, 0.03, Vector3(sx * 0.32, -0.28, 0), red, Vector3(1, 1.4, 1), 5)
	Props.ball(_body, 0.34, Vector3(0, 1.18, 0), red.darkened(0.05), Vector3(1.0, 0.45, 0.9), 12)
	Props.box(_body, Vector3(0.05, 0.12, 0.02), Vector3(0, 1.08, 0.3), Color("e0b440"))
	Props.box(_body, Vector3(0.1, 0.03, 0.02), Vector3(0, 1.1, 0.3), Color("e0b440"))


## Venedik baylosu Girolamo Minotto: Venedik soylusu; kırmızı toga, yumuşak siyah berretta, omuzda siyah stola.
func _berretta() -> void:
	Props.ball(_head, 0.215, Vector3(0, 0.06, -0.03), hair, Vector3(1.02, 0.9, 1.0), 10)
	Props.ball(_head, 0.22, Vector3(0, 0.2, -0.02), Color("1a1a1e"), Vector3(1.05, 0.5, 1.05), 10)
	Props.box(_body, Vector3(0.1, 0.8, 0.04), Vector3(0.14, 0.9, 0.26), Color("1a1a1e"))
	Props.box(_body, Vector3(0.12, 0.5, 0.04), Vector3(0.14, 1.05, -0.26), Color("1a1a1e"))


## Sürekli iş hareketi (Rig.activity): sit, sit_ground, stir, hammer, write, paint, carry.
func set_activity(a: String) -> void:
	activity = a
	if rig:
		rig.activity = a


## Önünde yük taşır (sandık, sepet ya da çuval) ve "carry" hareketine geçer.
func carry(kind := "crate") -> void:
	var c := Node3D.new()
	c.position = Vector3(0, 0.98, 0.34)
	_body.add_child(c)
	match kind:
		"basket":
			Props.cyl(c, 0.2, 0.2, Vector3.ZERO, Color("b8904a"), Vector3.ZERO, 8, 1.2)
			for i in 4:
				Props.ball(c, 0.06, Vector3(-0.08 + (i % 2) * 0.16, 0.12, -0.05 + (i / 2) * 0.1), [Color("d83a2a"), Color("e8a020"), Color("8ab840")][i % 3], Vector3.ONE, 5)
		"sack":
			Props.ball(c, 0.2, Vector3(0, 0.04, 0), Color("c8b48a"), Vector3(1.2, 0.9, 0.9), 6)
		_:
			Props.box(c, Vector3(0.4, 0.3, 0.3), Vector3.ZERO, Color("8a6440"))
	set_activity("carry")


func _make_rig() -> void:
	rig = Rig.new(self, {"body": _body, "head": _head, "arm_l": _arm_l, "arm_r": _arm_r, "leg_l": _leg_l,
		"leg_r": _leg_r, "eyes": _eyes, "brows": _brows, "arm_rest_z": 0.1,
		"knee_l": _knee_l, "knee_r": _knee_r, "elbow_l": _elbow_l, "elbow_r": _elbow_r})
	rig.activity = activity


func _process(delta: float) -> void:
	_t += delta
	if not _busy:
		_body.rotation.z = sin(_t * 1.1) * 0.02
	_mouth.scale.y = 0.22 * (1.0 + (absf(sin(_t * 14.0)) * 2.5 if talking else 0.0))
	if look_target and not _busy:
		var to := look_target.global_position - global_position
		to.y = 0.0
		if to.length() > 0.1:
			rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 4.0, 0.0, 1.0))
	rig.update(delta, talking, _busy)


## Bir noktaya en yakın karakter (eşya gösterince, selfie'de tepki için).
static func nearest(tree: SceneTree, point: Vector3, max_dist := 2.5, exclude: Node = null) -> Person:
	var best: Person = null
	var bd := max_dist
	for n in tree.get_nodes_in_group("persons"):
		var p := n as Person
		if p and p != exclude and p.is_visible_in_tree():
			var d := (p.global_position + Vector3(0, 1.0, 0)).distance_to(point)
			if d < bd:
				bd = d
				best = p
	return best


## Tepki animasyonları (Rig): "surprise", "laugh", "shrug", "wave", "nod", "facepalm", "cheer".
func emote(kind: String) -> void:
	if _busy:
		return
	await rig.emote(kind)


## Damga vurma / masaya vurma: sağ kol kalkar ve iner.
func stamp() -> void:
	rig.lock += 1
	var tw := create_tween()
	tw.tween_property(_arm_r, "rotation:x", -2.2, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(_arm_r, "rotation:x", -0.9, 0.08)
	tw.tween_property(_arm_r, "rotation:x", 0.0, 0.3)
	await tw.finished
	rig.lock -= 1


## Tekme (hologram Tolga): geri çekiş, savuruş, darbe sinyali, geri dönüş.
func kick() -> void:
	_busy = true
	var tw := create_tween()
	tw.tween_property(_leg_r, "rotation:x", deg_to_rad(40), 0.35).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_body, "rotation:x", -0.1, 0.35)
	tw.tween_interval(0.12)
	tw.tween_property(_leg_r, "rotation:x", deg_to_rad(-85), 0.13).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_body, "rotation:x", 0.15, 0.13)
	tw.tween_callback(func(): kick_hit.emit())
	tw.tween_interval(0.3)
	# "Ay, ayağım!": ayağını tutup zıplar
	tw.tween_property(_leg_r, "rotation:x", deg_to_rad(-30), 0.2)
	tw.parallel().tween_property(_body, "rotation:x", 0.0, 0.2)
	tw.tween_property(self, "position:y", position.y + 0.15, 0.15)
	tw.tween_property(self, "position:y", position.y, 0.15)
	tw.tween_property(self, "position:y", position.y + 0.15, 0.15)
	tw.tween_property(self, "position:y", position.y, 0.15)
	tw.tween_property(_leg_r, "rotation:x", 0.0, 0.25)
	await tw.finished
	_busy = false


func is_busy() -> bool:
	return _busy


## Bütün parçaları yarı saydam, parlayan hologram malzemesine çevirir.
static func make_hologram(node: Node, color := Color(0.35, 0.95, 1.0, 0.45)) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.emission_enabled = true
	m.emission = Color(color.r, color.g, color.b)
	m.emission_energy_multiplier = 1.5
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_apply(node, m)


static func _apply(node: Node, m: Material) -> void:
	for c in node.get_children():
		if c is MeshInstance3D:
			(c as MeshInstance3D).material_override = m
		_apply(c, m)
