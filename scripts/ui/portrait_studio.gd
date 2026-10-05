class_name PortraitStudio
extends SubViewport
## Konuşma kartının stüdyosu: konuşan sahnede değilse (oyuncunun kendisi, telsiz, uzak ses) kart onun canlı bir
## kopyasını gösterir. Kendi küçük dünyasında, ışıklı bir fonun önünde PortraitLooks görünüşüyle kurulan bir kafa:
## ağzı sesle oynar (LipSync), göz kırpar, kameraya bakar. Kopyalar konuşmacı başına bir kez kurulur ve saklanır.
## Konuşan sahnedeyse Hud LivePortrait'i kullanır (oyundaki hâli); eski düz çizimler hiç kullanılmaz.

const SIZE := 224
## Kafa yerine cihazın (telsiz, hoparlör) ve tavuğun bakılan noktası
const DEVICE_AIM := Vector3(0, 0.32, 0)
const CHICKEN_AIM := Vector3(0, 0.4, 0.08)

var box: Control          # altyazı kutusu: kapanınca çekim durur
var _cam: Camera3D
var _stage: Node3D
var _eye: Marker3D        # kopyanın baktığı nokta (kamera)
var _backdrop: MeshInstance3D
var _grad: Gradient
var _cache := {}          # imza -> kopya
var _cur: Node3D
var _cur_kind := ""


func _init() -> void:
	size = Vector2i(SIZE, SIZE)
	own_world_3d = true
	world_3d = World3D.new()
	transparent_bg = false
	render_target_update_mode = SubViewport.UPDATE_DISABLED
	msaa_3d = Viewport.MSAA_2X
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("15181e")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c4c8d4")
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	# Üç nokta ışık: sıcak ana ışık soldan önden, serin dolgu sağdan, arkadan kenar ışığı (saç ve omuz çizgisi)
	var key := DirectionalLight3D.new()
	key.light_color = Color("ffe6c8")
	key.light_energy = 1.25
	key.rotation_degrees = Vector3(-28, -32, 0)
	add_child(key)
	var fill := OmniLight3D.new()
	fill.light_color = Color("b8cce8")
	fill.light_energy = 0.55
	fill.omni_range = 6.0
	fill.position = Vector3(1.6, 1.7, 1.6)
	add_child(fill)
	var rim := OmniLight3D.new()
	rim.light_color = Color("fff0d8")
	rim.light_energy = 1.1
	rim.omni_range = 4.0
	rim.position = Vector3(-0.7, 2.3, -1.2)
	add_child(rim)
	# Fon: başın arkasında konuşmacının renginde yumuşak bir ışık lekesi (merkezde açık, kenarlara doğru koyu)
	_grad = Gradient.new()
	_grad.set_color(0, Color("4a5260"))
	_grad.set_color(1, Color("15181e"))
	var gt := GradientTexture2D.new()
	gt.gradient = _grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.42)
	gt.fill_to = Vector2(0.5, 1.05)
	gt.width = 128
	gt.height = 128
	var bm := StandardMaterial3D.new()
	bm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bm.albedo_texture = gt
	var q := QuadMesh.new()
	q.size = Vector2(3.2, 3.2)
	_backdrop = MeshInstance3D.new()
	_backdrop.mesh = q
	_backdrop.material_override = bm
	add_child(_backdrop)
	_stage = Node3D.new()
	add_child(_stage)
	_cam = Camera3D.new()
	_cam.fov = 24.0
	_cam.near = 0.05
	_cam.far = 20.0
	add_child(_cam)
	_eye = Marker3D.new()
	add_child(_eye)


## Konuşmacının kopyasını göster; true: portre hazır. soot: yüzü isli (patlamadan sonra Tolga).
func show_for(speaker_key: String, tint := Color("8ecbff"), soot := false) -> bool:
	var lk := PortraitLooks.look(speaker_key)
	var sig := str(lk["sig"]) + (":soot" if soot else "")
	var n: Node3D = _cache.get(sig)
	if n == null or not is_instance_valid(n):
		n = _build(lk)
		if n == null:
			return false
		if soot:
			Vfx.soot(n)
		_cache[sig] = n
	if _cur and _cur != n and is_instance_valid(_cur):
		_park(_cur)
	_cur = n
	_cur_kind = str(lk["kind"])
	n.visible = true
	n.process_mode = Node.PROCESS_MODE_INHERIT
	_talk(n, true)
	_grad.set_color(0, tint.darkened(0.45).lerp(Color("4a5260"), 0.35))
	_place()
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	return true


func stop() -> void:
	if _cur and is_instance_valid(_cur):
		_talk(_cur, false)
	render_target_update_mode = SubViewport.UPDATE_DISABLED


## Önceden kur (bölüm başında boşta): ilk replikte kurulum takılması olmasın
func prewarm(keys: Array) -> void:
	for k: String in keys:
		var lk := PortraitLooks.look(k)
		var sig := str(lk["sig"])
		if _cache.has(sig):
			continue
		var n := _build(lk)
		if n:
			_cache[sig] = n
			_park(n)
		await get_tree().process_frame


## Kurulan kopya: dünyadaki kişiyle aynı sınıf (Person / Hikmet / Tavuk) ya da konuşan bir cihaz
func _build(lk: Dictionary) -> Node3D:
	var n: Node3D
	match str(lk["kind"]):
		"person":
			n = Person.new(lk["p"])
		"hikmet":
			n = Hikmet.new()
		"chicken":
			n = Chicken.new()
		"radio", "loudspeaker":
			n = _device(str(lk["kind"]))
		_:
			return null
	# Sahnenin işlerine karışmasın: konuşmacı aranırken bulunmaz, kalabalık sohbeti/zemine oturtma yok
	n.set_meta("portrait_double", true)
	n.set_meta("no_talk", true)
	n.set_meta("no_unclip", true)
	_stage.add_child(n)
	for g in ["persons", "persons_hikmet", "soldiers", "chickens"]:
		if n.is_in_group(g):
			n.remove_from_group(g)
	n.set("look_target", _eye)
	return n


func _park(n: Node3D) -> void:
	_talk(n, false)
	n.visible = false
	n.process_mode = Node.PROCESS_MODE_DISABLED


func _talk(n: Node3D, on: bool) -> void:
	if "talking" in n:
		n.set("talking", on)
	elif "flapping" in n:
		n.set("flapping", false)


func _process(_delta: float) -> void:
	if render_target_update_mode == SubViewport.UPDATE_DISABLED or _cur == null:
		return
	if not is_instance_valid(_cur) or (box and not box.visible):
		stop()
		return
	_place()
	# Konuşan cihazın ızgarası sesle parlar (ses ölçülemiyorsa ritmik)
	var g = _cur.get_meta("grille") if _cur.has_meta("grille") else null
	if g is MeshInstance3D:
		var m := (g as MeshInstance3D).material_override as StandardMaterial3D
		var l := LipSync.level()
		var top: float = _cur.get_meta("glow", 2.6)   # hoparlörün geniş ağzı az ışır: kare beyaza kesmesin
		m.emission_energy_multiplier = 0.3 + (l * top if l >= 0.0 else absf(sin(Time.get_ticks_msec() * 0.012)) * top * 0.6)


## Kamera yüzün önünde, hafif yandan ve göz hizasının biraz üstünden (LivePortrait ile aynı "görüntülü arama" açısı;
## başlığın tepesi de kareye girer); fon başın arkasında. Cihaz ve tavuk biraz daha uzaktan, ortadan çekilir.
func _place() -> void:
	var h: Vector3
	var dist := LivePortrait.DIST
	match _cur_kind:
		"chicken":
			h = _cur.global_position + CHICKEN_AIM
			dist = 1.05
		"radio":
			h = _cur.global_position + DEVICE_AIM
			dist = 1.75
		"loudspeaker":
			h = _cur.global_position + Vector3(-0.05, 0.26, 0.02)
			dist = 1.7
		_:
			h = LivePortrait.head_of(_cur) + LivePortrait.AIM_UP
			if _cur.get("child"):
				dist *= 1.25       # çocuğun kafası gövdesine göre büyük: kare dolmasın
	_cam.global_position = h + Vector3.BACK * dist + Vector3(0.16, 0.06, 0)
	_cam.look_at(h, Vector3.UP)
	_eye.global_position = _cam.global_position
	_backdrop.global_position = h + Vector3(0, -0.1, -1.6)


## Konuşan cihaz: Büro'nun telsizi / garajın radyosu ya da minibüsün hoparlörü. Hoparlör ızgarası sesle parlar.
func _device(kind: String) -> Node3D:
	var n := Node3D.new()
	var grille: MeshInstance3D
	if kind == "loudspeaker":
		# Boru hoparlör: direğe kelepçeli, dar boyunlu, genişleyen ağızlı; dörtte üç açıdan (ağız ve boru birlikte görünür)
		n.rotation_degrees.y = -35.0
		Props.cyl(n, 0.025, 0.56, Vector3(0, -0.02, -0.12), Color("4a4a50"), Vector3.ZERO, 8)
		Props.box(n, Vector3(0.05, 0.05, 0.12), Vector3(0, 0.27, -0.08), Color("4a4a50"))
		Props.cyl(n, 0.045, 0.34, Vector3(0, 0.3, 0.0), Color("9aa09a"), Vector3(90, 0, 0), 16, 0.17)
		Props.cyl(n, 0.075, 0.12, Vector3(0, 0.3, -0.23), Color("4a4d4a"), Vector3(90, 0, 0), 12)
		Props.cyl(n, 0.178, 0.025, Vector3(0, 0.3, 0.17), Color("5a5e56"), Vector3(90, 0, 0), 16)
		grille = Props.cyl(n, 0.155, 0.01, Vector3(0, 0.3, 0.172), Color("ffd890"), Vector3(90, 0, 0), 16)
		n.set_meta("glow", 0.9)
	else:
		Props.box(n, Vector3(0.46, 0.3, 0.16), Vector3(0, 0.3, 0), Color("3a3a32"))
		Props.box(n, Vector3(0.44, 0.04, 0.165), Vector3(0, 0.43, 0), Color("6a5a40"))
		Props.cyl(n, 0.012, 0.42, Vector3(0.17, 0.62, -0.03), Color("9aa0a8"), Vector3(0, 0, -12), 6)
		Props.cyl(n, 0.035, 0.03, Vector3(0.14, 0.26, 0.085), Color("c8c0a8"), Vector3(90, 0, 0), 10)
		Props.box(n, Vector3(0.16, 0.05, 0.01), Vector3(0.12, 0.36, 0.082), Color("e8d8a0"), Vector3.ZERO, 0.6)
		grille = Props.cyl(n, 0.09, 0.01, Vector3(-0.1, 0.3, 0.082), Color("6ff2c8"), Vector3(90, 0, 0), 14)
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("2a3a34") if kind != "loudspeaker" else Color("3e3a30")
	m.emission_enabled = true
	m.emission = Color("6ff2c8") if kind != "loudspeaker" else Color("ffd890")
	m.emission_energy_multiplier = 0.4
	grille.material_override = m
	n.set_meta("grille", grille)
	return n
