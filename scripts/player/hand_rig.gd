class_name HandRig
extends Node3D
## Birinci şahıs el (v0.99.70): avuç, iki boğumlu dört parmak ve iki boğumlu başparmak; eşyaya göre tutuş pozu alır.
## Eskiden el bir top, parmaklar topun yanında üç boncuk, eşya elin önünde havada asılıydı (kullanıcı: "hepsi kötü
## duruyor"). Şimdi parmaklar eşyayı sarar, başparmak üstüne basar, eşya avucun içinde oturur.
##
## Yerel eksen (sağ el): parmaklar -Z, el sırtı +Y (avuç -Y'ye bakar), başparmak -X yanında. Bilek orijinde, avuç
## ortası (0, 0, -PALM_L/2). Kıvrım açıları derece; eksi = parmak avuca doğru bükülür.

const PALM_W := 0.078
const PALM_T := 0.026
const PALM_L := 0.082
const F_R := 0.0085                         # parmak kalınlığı (yarıçap)
const F_LEN := [[0.036, 0.034], [0.04, 0.036], [0.038, 0.034], [0.03, 0.028]]    # işaret, orta, yüzük, serçe
const F_X := [-0.027, -0.009, 0.009, 0.026]
const T_LEN := [0.034, 0.03]

## Tutuşlar. fingers: dört parmağın [kök kıvrımı, uç kıvrımı]; spread: parmakların yana açılması; thumb: [yana (Y),
## öne-aşağı (X), kök kıvrımı, uç kıvrımı]; rig: avucun el düğümündeki dönüşü (z −80: el sıkışma duruşu, avuç sola;
## z 180: avuç yukarı); at: eşyanın tutulan noktasının avuç uzayındaki yeri; rot: eşyanın dönüşü; s: ölçek; grip: eşya
## modelinde tutulan nokta (Items.build birimiyle). Avucun iç yüzü y = −PALM_T/2; tutulan şey y < 0'da durur.
##   Silindir tutuşu: eşyanın ekseni avucun enine (yerel X) yatar, parmaklar önden sarar, başparmak üst uçta;
##   rot (0, 0, 90) eşyanın "yukarı"sını (+Y) yerel −X'e (el sıkışma duruşunda yukarı) çevirir.
##   Düz tutuş: eşya avuçta yatar, yüzü avuçtan dışa (yerel −Y) bakar: rot (0, 0, 180).
const GRIPS := {
	"thermos": {"rig": Vector3(8, -12, -80), "fingers": [[-80, -75], [-82, -75], [-84, -75], [-86, -75]], "spread": [0, 0, 0, 0],
		"thumb": [-30, -25, -35, -30], "at": Vector3(0.0, -0.037, -0.058), "rot": Vector3(0, 0, 90), "s": 0.3, "grip": Vector3(0, 0.22, 0)},
	"cologne": {"rig": Vector3(8, -12, -80), "fingers": [[-80, -75], [-82, -75], [-84, -75], [-86, -75]], "spread": [0, 0, 0, 0],
		"thumb": [-30, -25, -35, -30], "at": Vector3(0.0, -0.038, -0.058), "rot": Vector3(0, 0, 90), "s": 0.41, "grip": Vector3(0, 0.12, 0)},
	"lighter": {"rig": Vector3(8, -12, -80), "fingers": [[-88, -85], [-92, -85], [-95, -85], [-98, -85]], "spread": [0, 0, 0, 0],
		"thumb": [-45, -30, -60, -50], "at": Vector3(0.0, -0.024, -0.058), "rot": Vector3(0, 0, 90), "s": 0.48, "grip": Vector3(0, 0.02, 0)},
	# Düz tutuş: avuç yukarı, eşya avuçta yatar (yüzü yukarı/bakana), parmak uçları uzak kenarı, başparmak yan kenarı tutar
	"phone": {"rig": Vector3(50, 20, 180), "root": [Vector3(-0.1, 0.07, 0.04), Vector3(0, 0, 0)], "fingers": [[-25, -70], [-28, -70], [-30, -70], [-32, -70]], "spread": [3, 0, -3, -6],
		"thumb": [-100, 30, -30, -20], "at": Vector3(0.0, -0.016, -0.048), "rot": Vector3(0, 0, 180), "s": 0.46, "grip": Vector3.ZERO},
	"powerbank": {"rig": Vector3(50, 20, 180), "root": [Vector3(-0.1, 0.07, 0.04), Vector3(0, 0, 0)], "fingers": [[-28, -75], [-30, -75], [-32, -75], [-34, -75]], "spread": [3, 0, -3, -6],
		"thumb": [-100, 30, -30, -20], "at": Vector3(0.0, -0.014, -0.058), "rot": Vector3(0, 0, 180), "s": 0.38, "grip": Vector3.ZERO},
	"book": {"rig": Vector3(50, 20, 180), "root": [Vector3(-0.1, 0.07, 0.04), Vector3(0, 0, 0)], "fingers": [[-30, -80], [-32, -80], [-34, -80], [-36, -80]], "spread": [3, 0, -3, -6],
		"thumb": [-100, 30, -30, -20], "at": Vector3(0.008, -0.016, -0.052), "rot": Vector3(0, 0, 180), "s": 0.26, "grip": Vector3.ZERO},
	"cube": {"rig": Vector3(50, 20, 180), "root": [Vector3(-0.1, 0.07, 0.04), Vector3(0, 0, 0)], "fingers": [[-55, -70], [-58, -70], [-60, -70], [-62, -70]], "spread": [3, 0, -3, -6],
		"thumb": [-60, -20, -40, -30], "at": Vector3(0.0, -0.014, -0.05), "rot": Vector3(0, 25, 180), "s": 0.27, "grip": Vector3(0, 0, 0)},
	# Saplı tutuş (kumanda, selfie çubuğu, bant, leblebi kesesinin ağzı): silindir tutuşunun eğik hâli
	"remote": {"rig": Vector3(8, -12, -80), "fingers": [[-60, -62], [-62, -62], [-64, -62], [-66, -62]], "spread": [0, 0, 0, 0],
		"thumb": [-30, -25, -35, -30], "at": Vector3(0.0, -0.042, -0.06), "rot": Vector3(0, 90, 90), "s": 0.8, "grip": Vector3(0, -0.025, -0.045)},
	"selfie": {"rig": Vector3(8, -12, -80), "fingers": [[-82, -78], [-84, -78], [-86, -78], [-88, -78]], "spread": [0, 0, 0, 0],
		"thumb": [-45, -28, -60, -50], "at": Vector3(0.0, -0.022, -0.058), "rot": Vector3(0, -50, 165), "s": 0.34, "grip": Vector3(-0.42, 0.02, 0)},
	"tape": {"rig": Vector3(8, -12, -80), "fingers": [[-80, -75], [-82, -75], [-84, -75], [-86, -75]], "spread": [0, 0, 0, 0],
		"thumb": [-30, -25, -35, -30], "at": Vector3(0.0, -0.022, -0.058), "rot": Vector3(90, 0, 0), "s": 0.28, "grip": Vector3(0.105, 0.05, 0)},
	"chickpeas": {"rig": Vector3(8, -12, -80), "fingers": [[-85, -80], [-88, -80], [-90, -80], [-92, -80]], "spread": [0, 0, 0, 0],
		"thumb": [-15, -35, -70, -55], "at": Vector3(0.0, -0.02, -0.058), "rot": Vector3(0, 0, 140), "s": 0.38, "grip": Vector3(0, 0.25, 0)},
	"open": {"rig": Vector3(8, -8, -20), "fingers": [[-25, -30], [-28, -30], [-30, -32], [-34, -34]], "spread": [5, 0, -5, -10],
		"thumb": [10, 10, -10, -10], "at": Vector3.ZERO, "rot": Vector3.ZERO, "s": 1.0, "grip": Vector3.ZERO},
}

var skin := Color("e6ad88")
var sleeve := Color("2b2f38")
var cuff := Color("f4f1ea")
var palm: Node3D
var fingers: Array = []          # [[kök, uç], ...] eklem düğümleri
var thumb: Array = []            # [yön, kök, uç]
var socket: Node3D               # eşyanın takıldığı yer (avuç uzayı)
var grip := "open"


func _init(p_skin := Color("e6ad88"), p_sleeve := Color("2b2f38"), p_cuff := Color("f4f1ea")) -> void:
	skin = p_skin
	sleeve = p_sleeve
	cuff = p_cuff
	name = "HandRig"


func _ready() -> void:
	_build()
	pose("open")


func _seg(parent: Node3D, length: float, r: float, c: Color) -> void:
	var m := CapsuleMesh.new()
	m.radius = r
	m.height = length + r * 2.0
	m.radial_segments = 8
	m.rings = 2
	Props._place(parent, m, Vector3(0, 0, -length * 0.5), c, Vector3(90, 0, 0), 0.0)


func _build() -> void:
	# Kol ve manşet bileğin arkasında
	Props.cyl(self, 0.042, 0.18, Vector3(0, 0.002, 0.1), sleeve, Vector3(90, 0, 0), 8)
	Props.cyl(self, 0.04, 0.028, Vector3(0, 0.002, 0.012), cuff, Vector3(90, 0, 0), 8)
	palm = Node3D.new()
	add_child(palm)
	# Avuç: yassı kutu ve yumuşak kenarlar (bilekte ve parmak köklerinde yuvarlak)
	# Avuç: tek parça yassı elips (kutu el sırtında köşeli duruyordu; kutu+top denemesi sırtta daire bırakıyordu)
	Props.ball(palm, 0.05, Vector3(0, 0, -PALM_L * 0.5), skin, Vector3(PALM_W * 1.08, PALM_T * 1.25, PALM_L * 1.12) / 0.1, 14)
	Props.ball(palm, PALM_T * 0.55, Vector3(0, 0, -0.004), skin, Vector3(PALM_W / PALM_T * 0.95, 1.0, 1.1), 8)
	Props.ball(palm, PALM_T * 0.5, Vector3(0, -0.001, -PALM_L + 0.006), skin, Vector3(PALM_W / PALM_T * 1.02, 1.0, 1.0), 10)
	# Başparmak kökündeki tümsek (avuç içi)
	Props.ball(palm, 0.02, Vector3(-PALM_W * 0.35, -0.008, -0.022), skin, Vector3(1.0, 0.8, 1.4), 8)
	for i in 4:
		var base := Node3D.new()
		base.position = Vector3(F_X[i], 0, -PALM_L)
		palm.add_child(base)
		Props.ball(base, F_R * 1.05, Vector3.ZERO, skin, Vector3.ONE, 6)
		_seg(base, F_LEN[i][0], F_R, skin)
		var tip := Node3D.new()
		tip.position = Vector3(0, 0, -F_LEN[i][0])
		base.add_child(tip)
		_seg(tip, F_LEN[i][1], F_R * 0.93, skin)
		fingers.append([base, tip])
	var tdir := Node3D.new()
	tdir.position = Vector3(-PALM_W * 0.5, -0.004, -0.018)
	palm.add_child(tdir)
	var t1 := Node3D.new()
	tdir.add_child(t1)
	Props.ball(t1, F_R * 1.25, Vector3.ZERO, skin, Vector3.ONE, 6)
	_seg(t1, T_LEN[0], F_R * 1.15, skin)
	var t2 := Node3D.new()
	t2.position = Vector3(0, 0, -T_LEN[0])
	t1.add_child(t2)
	_seg(t2, T_LEN[1], F_R * 1.05, skin)
	thumb = [tdir, t1, t2]
	socket = Node3D.new()
	socket.name = "Socket"
	palm.add_child(socket)
	Props.strip_outlines(self)


## Tutuş pozuna geçer (anında). Eşyayı tutmak için attach() ile birlikte.
var rig_override := Vector3.INF        # galeri: avucun dönüşünü denemek için


func pose(g: String) -> void:
	var d: Dictionary = GRIPS.get(g, GRIPS["open"])
	grip = g
	palm.rotation_degrees = d["rig"] if rig_override == Vector3.INF else rig_override
	# Bazı tutuşlarda el bütünüyle kayar (telefon ve kitap ortaya, göz hizasına kalkar: ekran bakana döner)
	var root: Array = d.get("root", [Vector3.ZERO, Vector3.ZERO])
	position = root[0]
	rotation_degrees = root[1]
	for i in 4:
		var f: Array = d["fingers"][i]
		(fingers[i][0] as Node3D).rotation_degrees = Vector3(f[0], d["spread"][i], 0)
		(fingers[i][1] as Node3D).rotation_degrees = Vector3(f[1], 0, 0)
	var t: Array = d["thumb"]
	# Başparmak avuçtan öne çıkar, avucun karşısına döner (görsel denetim: dışarı açık başparmak eşyaya sarılmıyordu)
	(thumb[0] as Node3D).rotation_degrees = Vector3(-20 + t[1], 10 + t[0], -30)
	(thumb[1] as Node3D).rotation_degrees = Vector3(t[2], 0, 0)
	(thumb[2] as Node3D).rotation_degrees = Vector3(t[3], 0, 0)
	socket.position = d["at"]
	socket.rotation_degrees = d["rot"]
	socket.scale = Vector3.ONE * float(d["s"])
	for m in socket.get_children():
		(m as Node3D).position = -(d["grip"] as Vector3)


## Kırmızı düğmeye basma (0..1): başparmak tutuşun üstüne bir miktar daha bükülür.
func press(v: float) -> void:
	var d: Dictionary = GRIPS.get(grip, GRIPS["open"])
	var t: Array = d["thumb"]
	(thumb[1] as Node3D).rotation_degrees = Vector3(t[2] - 22.0 * v, 0, 0)
	(thumb[2] as Node3D).rotation_degrees = Vector3(t[3] - 15.0 * v, 0, 0)


## Serbest el (sol el): avuç düz kalır, parmaklar tek açıyla bükülür (c: derece, 0 açık, -85 sıkı yumruk). Tutunma,
## kulaç, savrulma Player._animate_free_hand'den sürülür.
func curl(c: float) -> void:
	var k := clampf(c / -85.0, 0.0, 1.2)
	for i in 4:
		(fingers[i][0] as Node3D).rotation_degrees = Vector3(c * (0.85 + 0.04 * i), (1.5 - i) * 4.0 * (1.0 - k), 0)
		(fingers[i][1] as Node3D).rotation_degrees = Vector3(minf(c * 1.15, -8.0), 0, 0)
	# Yumrukta başparmak işaret parmağının üstüne yatar (dışarı bakmaz)
	(thumb[0] as Node3D).rotation_degrees = Vector3(-20 - 10.0 * k, 10 - 65.0 * k, -30)
	(thumb[1] as Node3D).rotation_degrees = Vector3(c * 0.35, 0, 0)
	(thumb[2] as Node3D).rotation_degrees = Vector3(c * 0.4, 0, 0)


## Eşya modelini avuca takar (eskisini kaldırmaz; çağıran yönetir).
func attach(model: Node3D) -> void:
	if model.get_parent():
		model.get_parent().remove_child(model)
	socket.add_child(model)
	model.position = -(GRIPS.get(grip, GRIPS["open"])["grip"] as Vector3)
	model.rotation = Vector3.ZERO
	model.scale = Vector3.ONE
