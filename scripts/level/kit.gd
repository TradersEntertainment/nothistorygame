class_name Kit
extends RefCounted
## Hazır CC0 modeller (Quaternius; assets/models/CREDITS_QUATERNIUS.txt) oyunun toon görünümüyle:
##  · food(...)   — Ultimate Food Pack: ekmek, balık, tencere, tabak... (yalnız 1453'e uyanlar; domates, biber yok)
##  · horse(...)  — Farm Animals: iskeletli at, Idle/Walk/Run/Eat benzeri döngüler; tüy rengi boyanır
##  · house(...)  — Medieval Village MegaKit: 2 m'lik duvar modülleri, kemerli pencere/kapı, kepenk, balkon, oluklu kiremit
## Model bulunamazsa null döner; çağıran kendi ilkel parçasına düşer.

const FOOD_DIR := "res://assets/models/food/%s.obj"
const VILLAGE_DIR := "res://assets/models/village/%s.gltf"
const HORSE_PATH := "res://assets/models/animals/Horse.fbx"
const PROP_DIR := "res://assets/models/props/%s.gltf"

## Gerçek boyut katsayısı (modeller birbirinden farklı ölçekte).
const FOOD_SCALE := {
	"Apple": 0.1, "Apple_Green": 0.1, "Orange": 0.1, "Bread": 0.26, "Bread_Slice": 0.2, "Carrot": 0.12,
	"ChickenLeg": 0.12, "CookingPot": 0.17, "CookingPot_Soup": 0.17, "CookingPot2": 0.17, "CookingPot2_Soup": 0.17,
	"Eggplant": 0.13, "Egg_Whole": 0.07, "Fish": 0.12, "FishBone": 0.12, "FryingPan": 0.22, "Jar_Large": 0.2,
	"Knife": 0.14, "Lettuce_Whole": 0.16, "Lettuce": 0.16, "Mushroom": 0.06, "Plate": 0.14, "Plate2": 0.14,
	"Spoon": 0.12, "Steak": 0.14, "Turnip": 0.1, "Bottle1": 0.2, "Sausage_Cooked": 0.14,
}
const FRUIT := ["Apple", "Apple_Green", "Orange", "Turnip", "Eggplant", "Carrot", "Lettuce_Whole", "Mushroom"]
const HORSE_HEIGHT := 2.15      # başı dik duran atın kulak ucu yüksekliği (m); model buna ölçeklenir

static var _cache := {}
static var _mats := {}           # toon malzeme önbelleği (aynı kaynak + boya = aynı malzeme, çizim birleşir)
static var _horse_scale := 0.0


static func has_food() -> bool:
	return ResourceLoader.exists(FOOD_DIR % "Bread")


static func has_horse() -> bool:
	return ResourceLoader.exists(HORSE_PATH)


static func has_village() -> bool:
	return ResourceLoader.exists(VILLAGE_DIR % "Wall_Plaster_Straight")


static func _load(path: String) -> Resource:
	if _cache.has(path):
		return _cache[path]
	var r: Resource = load(path) if ResourceLoader.exists(path) else null
	_cache[path] = r
	return r


## Toon malzeme (Props.model ile aynı işlem): gölgelendirme basamaklı, parlama yok, dış hat.
## tint_only: boşsa her malzeme boyanır; doluysa yalnız adı bunu içerenler (ör. "Plaster": yalnız sıva).
static func toon(inst: Node, tint := Color(1, 1, 1, 0), outline := true, tint_only := "") -> void:
	for n in inst.find_children("*", "MeshInstance3D", true, false) + ([inst] if inst is MeshInstance3D else []):
		var mi := n as MeshInstance3D
		if mi.mesh == null:
			continue
		for i in mi.mesh.get_surface_count():
			var src := mi.get_active_material(i) as BaseMaterial3D
			var paint := tint.a > 0.0 and (tint_only == "" or (src != null and src.resource_name.contains(tint_only)))
			var key := "%d|%s|%s" % [src.get_instance_id() if src else 0, tint.to_html() if paint else "-", outline]
			if not _mats.has(key):
				var m: BaseMaterial3D = src.duplicate() if src else Props.mat(Color("8a8a8a")).duplicate()     # ortak önbellekteki malzeme değişmesin
				m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
				m.specular_mode = BaseMaterial3D.SPECULAR_TOON
				m.roughness = 0.9
				m.metallic = 0.0
				m.normal_enabled = false
				if paint:
					m.albedo_color = m.albedo_color * tint
				var cut := m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED
				if cut:
					# Kumaş/yaprak kenarları: yarı saydam harmanlama yerine kesme (beyaz hale ve sıralama hatası olmasın)
					m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
					m.alpha_scissor_threshold = 0.5
					m.cull_mode = BaseMaterial3D.CULL_DISABLED
				if outline and Props.outlines and not m.emission_enabled and not cut:
					m.next_pass = Props._outline_mat()
				_mats[key] = m
			mi.set_surface_override_material(i, _mats[key])


# ---------------------------------------------------------------- eşya (Fantasy Props MegaKit)

static var _parts := {}
const CLOTH_DEFAULT := Color("a8302a")


static func has_props() -> bool:
	return ResourceLoader.exists(PROP_DIR % "Crate_Wooden")


## Eşya modeli tek düğüm olarak (etkileşimli ya da tek tük yerler için). Ölçek gerçek boyutta.
static func prop(parent: Node3D, name: String, pos: Vector3, yaw := 0.0, scale := 1.0) -> Node3D:
	var ps := _load(PROP_DIR % name) as PackedScene
	if ps == null:
		return null
	var inst: Node3D = ps.instantiate()
	inst.position = pos
	inst.rotation.y = yaw
	inst.scale = Vector3.ONE * scale
	parent.add_child(inst)
	toon(inst, CLOTH_DEFAULT, true, "Banner")
	return inst


## Toplu çizim için: modelin parçaları [[toon malzemeli Mesh, köke göre Transform3D], ...] (önbellekli).
static func prop_parts(name: String) -> Array:
	if _parts.has(name):
		return _parts[name]
	var out: Array = []
	# "Ad#renk": kumaşı (MI_Banner: soluk, boyanmak üzere çizilmiş doku) o renge boya
	var base := name.get_slice("#", 0)
	var cloth := Color(name.get_slice("#", 1)) if name.contains("#") else CLOTH_DEFAULT
	var ps := _load(PROP_DIR % base) as PackedScene
	if ps:
		var root: Node3D = ps.instantiate()
		toon(root, cloth, true, "Banner")
		for n in root.find_children("*", "MeshInstance3D", true, false):
			var mi := n as MeshInstance3D
			var xf := Transform3D.IDENTITY
			var q: Node = mi
			while q != null and q != root:
				if q is Node3D:
					xf = (q as Node3D).transform * xf
				q = q.get_parent()
			var m := mi.mesh.duplicate() as Mesh
			for i in m.get_surface_count():
				m.surface_set_material(i, mi.get_surface_override_material(i))
			out.append([m, xf])
		root.free()
	_parts[name] = out
	return out


## [[ad, Transform3D], ...] listesini model başına tek MultiMeshInstance3D ile sahneye koyar.
static func batch(parent: Node3D, items: Array) -> void:
	var groups := {}
	for it in items:
		if not groups.has(it[0]):
			groups[it[0]] = []
		groups[it[0]].append(it[1])
	for name in groups:
		var xfs: Array = groups[name]
		for part in prop_parts(name):
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = part[0]
			mm.instance_count = xfs.size()
			for i in xfs.size():
				mm.set_instance_transform(i, (xfs[i] as Transform3D) * (part[1] as Transform3D))
			var mmi := MultiMeshInstance3D.new()
			mmi.name = "Props_" + String(name)
			mmi.multimesh = mm
			mmi.set_meta("xforms", xfs.map(func(x: Transform3D) -> Transform3D: return x * (part[1] as Transform3D)))
			parent.add_child(mmi)


# ---------------------------------------------------------------- yiyecek

## Yiyecek/mutfak eşyası: pos tabanın konumu (model zemine oturur). Dış hat yok (küçük parçalarda kalın görünür).
static func food(parent: Node3D, name: String, pos: Vector3, yaw := 0.0, size := 1.0) -> MeshInstance3D:
	var mesh := _load(FOOD_DIR % name) as Mesh
	if mesh == null:
		return null
	var s: float = FOOD_SCALE.get(name, 0.15) * size
	var mi := MeshInstance3D.new()
	mi.name = "Food_" + name
	mi.mesh = mesh
	mi.scale = Vector3.ONE * s
	mi.rotation.y = yaw
	mi.position = pos - Vector3(0, mesh.get_aabb().position.y * s, 0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	toon(mi, Color(1, 1, 1, 0), false)
	return mi


## Tezgâh/masa üstüne karışık sebze-meyve dizisi (w x d alan, merkez pos).
static func produce(parent: Node3D, pos: Vector3, w: float, d: float, rng: RandomNumberGenerator, kinds: Array = FRUIT) -> void:
	var nx := maxi(1, int(w / 0.14))
	var nz := maxi(1, int(d / 0.14))
	for ix in nx:
		for iz in nz:
			if rng.randf() < 0.25:
				continue
			var q := pos + Vector3(-w * 0.5 + (ix + 0.5) * w / nx + rng.randf_range(-0.02, 0.02), 0, -d * 0.5 + (iz + 0.5) * d / nz)
			food(parent, kinds[(ix / 2 + iz) % kinds.size()], q, rng.randf() * TAU, rng.randf_range(0.85, 1.1))


# ---------------------------------------------------------------- at

## İskeletli at modeli. anim: "Idle", "Walk", "WalkSlow", "Run", "Jump", "Death". coat: tüy rengi (boş: modelin kendi).
static func horse(parent: Node3D, pos: Vector3, yaw := 0.0, anim := "Idle", coat := Color(1, 1, 1, 0), solid := true) -> Node3D:
	var ps := _load(HORSE_PATH) as PackedScene
	if ps == null:
		return null
	var h: Node3D = ps.instantiate()
	h.name = "Horse"
	if _horse_scale == 0.0:
		_horse_scale = HORSE_HEIGHT / maxf(0.01, _height(h))
	h.scale = Vector3.ONE * _horse_scale
	parent.add_child(h)
	h.position = pos
	h.rotation.y = yaw
	toon(h, coat)
	var ap := h.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if ap:
		var full := "Armature|" + anim
		if ap.has_animation(full):
			ap.get_animation(full).loop_mode = Animation.LOOP_LINEAR
			ap.play(full)
			ap.seek(randf() * ap.current_animation_length, true)
			ap.speed_scale = randf_range(0.85, 1.1)
	_horse_face(h)
	if solid:
		var body := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(0.7, 1.7, 2.3) / _horse_scale
		cs.shape = bs
		cs.position = Vector3(0, 0.85, 0) / _horse_scale
		body.add_child(cs)
		h.add_child(body)
	return h


## Göz ve burun delikleri: modelde yüz yok; kafa kemiğine bağlı, kemikle birlikte oynar. Arada bir göz kırpar.
## Konumlar iskelet uzayında (Quaternius Horse: -Y ileri, +Z yukarı, 1 birim ≈ 40 m).
const HORSE_EYES := [Vector3(0.0051, -0.0405, 0.0632), Vector3(-0.0051, -0.0405, 0.0632)]
const HORSE_NOSTRILS := [Vector3(0.0021, -0.0503, 0.0545), Vector3(-0.0021, -0.0503, 0.0545)]


static func _horse_face(h: Node3D) -> void:
	var list := h.find_children("*", "Skeleton3D", true, false)
	if list.is_empty():
		return
	var sk := list[0] as Skeleton3D
	var bone := sk.find_bone("Head")
	if bone < 0:
		return
	var att := BoneAttachment3D.new()
	att.bone_name = "Head"
	sk.add_child(att)
	var face := Node3D.new()
	face.transform = sk.get_bone_global_rest(bone).affine_inverse()
	att.add_child(face)
	var eye_m := Props.mat(Color("140e0a"), 0.0, false, "", false)
	var glint_m := Props.mat(Color.WHITE, 0.6, false, "", false)
	var lid_m := Props.mat(Color("1c1410"), 0.0, false, "", false)
	var eyes: Array[Node3D] = []
	for e: Vector3 in HORSE_EYES:
		var eye := Node3D.new()
		eye.position = e
		face.add_child(eye)
		var ball := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.00115
		sm.height = 0.0023
		sm.radial_segments = 10
		sm.rings = 6
		ball.mesh = sm
		ball.scale = Vector3(0.55, 1.0, 0.85)
		ball.material_override = eye_m
		eye.add_child(ball)
		var glint := MeshInstance3D.new()
		var gm := SphereMesh.new()
		gm.radius = 0.00032
		gm.height = 0.00064
		gm.radial_segments = 6
		gm.rings = 3
		glint.mesh = gm
		glint.position = Vector3(signf(e.x) * 0.0006, -0.0004, 0.0004)
		glint.material_override = glint_m
		eye.add_child(glint)
		# Üst kapak (kaş gibi koyu çizgi): bakışa ifade verir
		var lid := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.0004, 0.0028, 0.0005)
		lid.mesh = bm
		lid.position = Vector3(signf(e.x) * 0.0003, 0.0002, 0.0012)
		lid.rotation.x = -0.35
		lid.material_override = lid_m
		eye.add_child(lid)
		eyes.append(eye)
	for n: Vector3 in HORSE_NOSTRILS:
		var nm := MeshInstance3D.new()
		var sm2 := SphereMesh.new()
		sm2.radius = 0.0007
		sm2.height = 0.0014
		sm2.radial_segments = 8
		sm2.rings = 4
		nm.mesh = sm2
		nm.position = n
		nm.scale = Vector3(0.7, 0.5, 1.0)
		nm.material_override = eye_m
		face.add_child(nm)
	# Göz kırpma: 2.5–6 sn'de bir, 0.12 sn
	var timer := Timer.new()
	timer.wait_time = randf_range(2.5, 6.0)
	timer.autostart = true
	h.add_child(timer)
	timer.timeout.connect(func():
		timer.wait_time = randf_range(2.5, 6.0)
		for eye in eyes:
			if is_instance_valid(eye):
				var tw := eye.create_tween()
				tw.tween_property(eye, "scale:z", 0.1, 0.06)
				tw.tween_property(eye, "scale:z", 1.0, 0.08))


## Modelin yerleşik (iskelet dahil) yüksekliği: meshin dünya AABB'si.
static func _height(n: Node3D) -> float:
	var top := 0.0
	for m in n.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		var xf := Transform3D.IDENTITY
		var p: Node = mi
		while p != null and p != n:
			if p is Node3D:
				xf = (p as Node3D).transform * xf
			p = p.get_parent()
		var ab := xf * mi.get_aabb()
		top = maxf(top, ab.end.y)
	return top


# ---------------------------------------------------------------- ev

const ROOFS := [["Roof_RoundTiles_4x4", 5.52, 5.56], ["Roof_RoundTiles_4x6", 5.52, 7.58], ["Roof_RoundTiles_4x8", 5.52, 9.68],
	["Roof_RoundTiles_6x10", 8.24, 11.85]]
const ROOF_RISE := 4.25          # modelin saçaktan mahyaya yüksekliği (ölçeklemeden önce)


## Oluklu kiremit beşik çatı. pos: saçak seviyesinde çatı ortası. Mahya yerel z boyunca; span_x saçaktan saçağa,
## len_z mahya boyu, rise mahya yüksekliği. toon_it: false ise çağıran sonra toon() uygular.
static func roof(parent: Node3D, pos: Vector3, yaw: float, span_x: float, len_z: float, rise: float, toon_it := true) -> Node3D:
	var best: Array = ROOFS[0]
	var ratio := len_z / maxf(span_x, 0.1)
	for r in ROOFS:
		if absf(float(r[2]) / float(r[1]) - ratio) < absf(float(best[2]) / float(best[1]) - ratio):
			best = r
	var sc := Vector3(span_x / float(best[1]), rise / ROOF_RISE, len_z / float(best[2]))
	var inst := piece(parent, best[0], Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(sc), pos + Vector3(0, 0.52 * sc.y, 0)))
	if inst and toon_it:
		toon(inst)
	return inst


static func piece(parent: Node3D, name: String, xf: Transform3D) -> Node3D:
	var ps := _load(VILLAGE_DIR % name) as PackedScene
	if ps == null:
		return null
	var inst: Node3D = ps.instantiate()
	inst.transform = xf
	parent.add_child(inst)
	return inst


## Modüler ev (yerel: cephe z=0'da, sokağa +z bakar, kök cephe ortasının dibi). bays: 2 m'lik bölme sayısı,
## floors: kat (3.12 m). brick: zemin kat düzensiz tuğla (Bizans işi), üstler sıvalı. Yanlar ve arka düz duvar.
## Döner: ev düğümü (çarpışma kutusu dahil).
static func house(parent: Node3D, pos: Vector3, yaw: float, bays: int, floors: int, rng: RandomNumberGenerator, opts := {}) -> Node3D:
	if not has_village():
		return null
	var root := Node3D.new()
	root.name = "KitHouse"
	root.position = pos
	root.rotation.y = yaw
	parent.add_child(root)
	var depth: int = opts.get("depth", 3)                       # derinlik (bölme)
	var brick_ground: bool = opts.get("brick", true)
	var tint: Color = opts.get("tint", Color(1, 1, 1, 0))
	var W := bays * 2.0
	var D := depth * 2.0
	var FH := 3.12
	var door_bay := rng.randi_range(0, bays - 1) if opts.get("door", true) else -1
	# Cephe (+z), arka (-D), yanlar
	for f in floors:
		var y := f * FH
		var ground := f == 0
		var mat := "UnevenBrick" if ground and brick_ground else "Plaster"
		for b in bays:
			var x := -W * 0.5 + 1.0 + b * 2.0
			var nm := "Wall_%s_Straight" % mat
			var shut := ""
			if ground and b == door_bay:
				nm = "Wall_%s_Door_Round" % mat
			elif not ground or rng.randf() < 0.4:
				var wide := rng.randf() < 0.45
				nm = "Wall_%s_Window_%s_Round" % [mat, "Wide" if wide else "Thin"]
				shut = "WindowShutters_%s_Round_%s" % ["Wide" if wide else "Thin", "Open" if rng.randf() < 0.6 else "Closed"]
			if ground and mat == "Plaster" and nm.ends_with("Straight"):
				nm = "Wall_Plaster_Straight_Base"
			piece(root, nm, Transform3D(Basis.IDENTITY, Vector3(x, y, 0)))
			if ground and b == door_bay:
				piece(root, "Door_2_Round", Transform3D(Basis.IDENTITY, Vector3(x - 0.53, y, -0.1)))
			if shut != "":
				piece(root, "Window_%s_Round1" % ("Wide" if shut.contains("Wide") else "Thin"), Transform3D(Basis.IDENTITY, Vector3(x, y, -0.05)))
				piece(root, shut, Transform3D(Basis.IDENTITY, Vector3(x, y, 0)))
			# Balkon: üst katlarda ara sıra
			if f >= 1 and rng.randf() < float(opts.get("balcony", 0.25)) and not shut.contains("Closed"):
				piece(root, "Balcony_Simple_Straight" if rng.randf() < 0.6 else "Balcony_Cross_Straight",
					Transform3D(Basis.IDENTITY, Vector3(x, y, -0.9)))
			# Arka duvar
			piece(root, "Wall_%s_Straight" % mat, Transform3D(Basis(Vector3.UP, PI), Vector3(x, y, -D)))
		for s in [-1, 1]:
			for d in depth:
				var z := -1.0 - d * 2.0
				piece(root, "Wall_%s_Straight" % mat, Transform3D(Basis(Vector3.UP, s * PI * 0.5), Vector3(s * W * 0.5, y, z)))
		# Köşe taşları
		for c in [Vector3(-W * 0.5, y, 0), Vector3(W * 0.5, y, 0)]:
			piece(root, "Corner_Exterior_Brick", Transform3D(Basis(Vector3.UP, PI * 0.5 if c.x < 0 else 0.0), c))
	# Çatı: oluklu kiremit, mahya sokağa paralel
	var top := floors * FH
	roof(root, Vector3(0, top, -D * 0.5), PI * 0.5, D + 0.6, W + 0.6, 2.2 + depth * 0.3, false)
	if rng.randf() < 0.6:
		piece(root, "Prop_Chimney2", Transform3D(Basis.IDENTITY, Vector3(rng.randf_range(-W * 0.3, W * 0.3), top, -D * 0.7)))
	if rng.randf() < float(opts.get("vine", 0.3)):
		piece(root, "Prop_Vine1", Transform3D(Basis.IDENTITY, Vector3(rng.randf_range(-W * 0.4, W * 0.4), FH * 1.4, 0.12)))
	toon(root, tint, true, "Plaster")
	# Çarpışma: tek kutu
	var body := StaticBody3D.new()
	body.set_meta("facade", true)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(W, top, D)
	cs.shape = bs
	cs.position = Vector3(0, top * 0.5, -D * 0.5)
	body.add_child(cs)
	root.add_child(body)
	return root
