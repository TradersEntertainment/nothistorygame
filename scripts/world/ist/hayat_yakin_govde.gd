class_name IstHayatGovde
extends RefCounted
## İstanbul v2 yakın hayat: kişi gövdeleri (Person), roller, tezgâh ve küçük sahne eşyaları (docs/_ajan/gorev/istanbul_parcalar.md
## "hayat-yakin"). Yalnız kurar; davranış IstHayatYakin'de. Görünüş CityLife._civ_body ile aynı dil (Person parametreleri).

## Havuz: [rol, adet]. Gövde bir kez kurulur (6-17 ms), rol havuzda sabit kalır; davranışı doğuşta seçilir.
## Gece: tezgâh direklerine fener (pişirmeden önce IstHayatYakin ayarlar)
static var gece_mod := false

const POOL := [
	["man", 9], ["woman", 10], ["child", 6], ["porter", 7], ["monk", 2], ["priest", 2], ["lantern", 3],
	["vendor", 5], ["fisher", 2], ["worker", 5], ["guard", 3], ["beggar", 1], ["washer", 1], ["sitter", 2],
]

## Rolün StreetEye/SideEvents sokak rolü (konuşma replik havuzu: DST_<ROL>_…)
const STREET_ROLE := {
	"man": "TOWNB", "woman": "WOMB", "child": "CHILDB", "porter": "PORTER", "monk": "MONK", "priest": "PRIEST",
	"lantern": "TOWNB", "vendor": "VENDB", "fisher": "FISHER", "worker": "TOWNB", "guard": "BYZSOL",
	"beggar": "TOWNB", "washer": "WOMB", "sitter": "TOWNB",
}


static func pool_roles(gece := false) -> Array:
	var out: Array = []
	var left := {}
	for e: Array in POOL:
		left[e[0]] = int(e[1])
	if gece:
		# gece sokakta fener taşıyanlar çoğalır: erkek ve kadın sayısının bir kısmı fenerci olur
		left["man"] = 4
		left["woman"] = 5
		left["lantern"] = 3 + 5 + 3
	# karışık sırada ver: ilk doğanlar da çeşitli olsun
	var more := true
	while more:
		more = false
		for e: Array in POOL:
			if left[e[0]] > 0:
				left[e[0]] -= 1
				out.append(e[0])
				more = true
	return out


## Bir kişinin gövdesi. idx: havuz sırası (tohum), gece: fener rolü
static func body(role: String, idx: int, gece: bool) -> Person:
	var r := RandomNumberGenerator.new()
	r.seed = 9101 + idx * 211
	var earth := [Color("6a5038"), Color("7a6a50"), Color("5a5a48"), Color("8a6a4a"), Color("6a4a3a"), Color("4a5a6a"), Color("8a7a5a"), Color("5a4a40")]
	var bright := [Color("a84a3a"), Color("3a6a8a"), Color("7a8a4a"), Color("b8885a"), Color("6a4a7a"), Color("c8a868")]
	var pants := [Color("3a3028"), Color("4a3a2a"), Color("2a2a30"), Color("5a4a3a")]
	var p := {"coat": earth[r.randi() % earth.size()], "pants": pants[r.randi() % pants.size()], "n": 5000 + idx}
	match role:
		"vendor":
			p["coat"] = bright[r.randi() % bright.size()]
			p["apron"] = Color("e8dcc0")
			p["mustache"] = r.randf() < 0.6
			p["beard"] = r.randf() < 0.4
		"fisher":
			p["coat"] = [Color("3a5a7a"), Color("5a6a6a"), Color("6a5a48")][r.randi() % 3]
			p["hat"] = "hood" if r.randf() < 0.3 else "none"
			p["beard"] = r.randf() < 0.6
		"porter":
			p["coat"] = [Color("8a7050"), Color("7a6040"), Color("6a6050")][r.randi() % 3]
			p["mustache"] = true
		"priest":
			p["coat"] = Color("1e1c1e")
			p["pants"] = Color("1e1c1e")
			p["robe"] = Color("1e1c1e")
			p["hat"] = "priest"
			p["beard"] = true
			p["hair"] = [Color("2a2420"), Color("6a6662"), Color("8a8682")][r.randi() % 3]
		"monk":
			p["coat"] = Color("2a2226")
			p["pants"] = Color("2a2226")
			p["robe"] = Color("2a2226")
			p["hat"] = "hood"
			p["beard"] = true
		"woman", "washer":
			p["coat"] = bright[r.randi() % bright.size()].darkened(0.15)
			p["pants"] = [Color("5a3a4a"), Color("3a4a5a"), Color("6a5a3a"), Color("4a3a30")][r.randi() % 4]
			p["skirt"] = true
			p["hat"] = "scarf" if r.randf() < 0.75 else "bun"
			p["scarf"] = [Color("e8e0d0"), Color("3a3a5a"), Color("8a3a3a"), Color("5a6a4a"), Color("c8b088")][r.randi() % 5]
		"child":
			p["coat"] = bright[r.randi() % bright.size()]
			p["child"] = true
		"lantern":
			p["coat"] = earth[r.randi() % earth.size()].darkened(0.1)
			p["hat"] = "hood" if r.randf() < 0.5 else "none"
			p["mustache"] = r.randf() < 0.5
		"worker":
			p["coat"] = [Color("8a7a5a"), Color("7a6a4a"), Color("9a8a6a")][r.randi() % 3]
			p["apron"] = Color("6a5a40")
			p["mustache"] = r.randf() < 0.7
			p["beard"] = r.randf() < 0.3
		"guard":
			p["coat"] = Crowd.BYZ_COATS[r.randi() % Crowd.BYZ_COATS.size()]
			p["pants"] = Color("3a2a22")
			p["hat"] = "helm"
			p["beard"] = r.randf() < 0.6
			p["mustache"] = r.randf() < 0.5
		"beggar":
			p["coat"] = Color("5a5044")
			p["pants"] = Color("3a3630")
			p["hat"] = "hood"
			p["beard"] = true
		"sitter":
			p["mustache"] = r.randf() < 0.6
			p["beard"] = r.randf() < 0.5
			if r.randf() < 0.3:
				p["hat"] = "hood"
		_:
			p["mustache"] = r.randf() < 0.6
			p["beard"] = r.randf() < 0.45
			if r.randf() < 0.15:
				p["hat"] = "hood"
	var pr := Person.new(p)
	pr.set_meta("no_chat", true)
	pr.set_meta("citylife", true)
	pr.set_meta("street_role", STREET_ROLE.get(role, "TOWNB"))
	pr.set_meta("hayat_yakin", true)
	return pr


## Gövde ağaca girdikten sonra eşya ve ölçek (Person._ready bitince)
static func dress(pr: Person, role: String, idx: int, gece: bool) -> void:
	match role:
		"porter":
			pr.carry(["basket", "sack", "barrel", "crate", "earth"][idx % 5])
		"lantern":
			if gece:
				pr.equip("lamp")
		"guard":
			pr.equip("spear_shield" if idx % 2 == 0 else "spear", Color("7a2a24"))
		"fisher":
			var rod := Node3D.new()
			pr._elbow_r.add_child(rod)
			rod.position = Vector3(0, -0.28, 0.06)
			rod.rotation_degrees = Vector3(62, 0, 0)
			Props.cyl(rod, 0.016, 3.0, Vector3(0, 1.4, 0), Color("8a6a3a"), Vector3.ZERO, 4, 0.006)
			Props.cyl(rod, 0.003, 1.6, Vector3(0, 2.5, 0.6), Color("d8d0c0"), Vector3(-62, 0, 0), 3)
	if role == "child":
		pr.scale = Vector3.ONE * 0.62


# ---------------------------------------------------------------- eşyalar (yerel +z = ön)

## Pazar tezgâhı: masa, direkler, çizgili saçak, mal. Ön (müşteri) tarafı +z. Katı kutu (1,95 × 1 × 1) kendi gövdesinde.
static func stall(seed: int) -> Node3D:
	var st := Node3D.new()
	st.name = "Tezgah%d" % seed
	var wood := Color("7a5634")
	var cloth: Array = [[Color("c8463a"), Color("efe2c0")], [Color("3a6a9a"), Color("e8dcc0")], [Color("6a8a3a"), Color("efe2c0")], [Color("b8883a"), Color("6a3a2a")]][seed % 4]
	Props.box(st, Vector3(1.9, 0.08, 0.9), Vector3(0, 0.86, 0), wood)
	for sx: float in [-0.85, 0.85]:
		for sz: float in [-0.38, 0.38]:
			Props.box(st, Vector3(0.07, 0.86, 0.07), Vector3(sx, 0.43, sz), wood.darkened(0.2))
		Props.box(st, Vector3(0.08, 2.3, 0.08), Vector3(sx, 1.15, -0.5), wood.darkened(0.25))
		Props.box(st, Vector3(0.06, 1.9, 0.06), Vector3(sx, 0.95, 0.55), wood.darkened(0.25))
	for k in 5:
		Props.box(st, Vector3(0.42, 0.03, 1.5), Vector3(-0.84 + k * 0.42, 2.12, 0.0), cloth[k % 2], Vector3(16, 0, 0))
	for k in 6:
		var gx := -0.7 + (k % 3) * 0.7
		var gz := -0.18 + (k / 3) * 0.36
		match seed % 4:
			0:
				Props.cyl(st, 0.2, 0.14, Vector3(gx, 0.97, gz), Color("9a7a48"), Vector3.ZERO, 8, 0.24)
				Props.ball(st, 0.17, Vector3(gx, 1.05, gz), [Color("d8452a"), Color("e8a020"), Color("8ab840")][k % 3], Vector3(1, 0.5, 1), 8)
			1:
				Props.ball(st, 0.15, Vector3(gx, 0.96, gz), Color("c8904a"), Vector3(1.3, 0.55, 1.0), 8)
			2:
				Props.cyl(st, 0.1, 0.55, Vector3(gx, 1.0, gz), [Color("8a2a4a"), Color("2a5a8a"), Color("c8a040")][k % 3], Vector3(0, 0, 90), 8)
			_:
				Props.ball(st, 0.15, Vector3(gx, 1.04, gz), Color("b8683a"), Vector3(1, 1.2, 1), 8)
				Props.cyl(st, 0.06, 0.1, Vector3(gx, 1.22, gz), Color("a8582a"), Vector3.ZERO, 8)
	if gece_mod:
		for sx: float in [-0.85, 0.85]:
			Props.cyl(st, 0.03, 0.14, Vector3(sx, 1.97, 0.55), Color("3a3430"), Vector3.ZERO, 5)
			Props.box(st, Vector3(0.13, 0.17, 0.13), Vector3(sx, 1.82, 0.55), Color("ffcf80"), Vector3.ZERO, 2.2)
	var sb := StaticBody3D.new()
	sb.collision_layer = 1
	sb.collision_mask = 0
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.95, 1.0, 1.0)
	cs.shape = bs
	cs.position = Vector3(0, 0.5, 0)
	sb.add_child(cs)
	st.add_child(sb)
	return st


## Üç ayaklı basit tabure (kapı önünde oturan için); oturan kişi tabure yüzünde
static func stool() -> Node3D:
	var n := Node3D.new()
	n.name = "Tabure"
	var w := Color("7a5634")
	Props.cyl(n, 0.2, 0.05, Vector3(0, 0.4, 0), w, Vector3.ZERO, 8)
	for a in 3:
		var ang := a * TAU / 3.0
		Props.cyl(n, 0.025, 0.4, Vector3(cos(ang) * 0.13, 0.2, sin(ang) * 0.13), w.darkened(0.2), Vector3.ZERO, 4)
	return n


## Çamaşır leğeni (yerde, ayakta duran yıkayıcının önünde; yerel +z ön)
static func tub() -> Node3D:
	var n := Node3D.new()
	n.name = "Leğen"
	Props.cyl(n, 0.34, 0.36, Vector3(0, 0.62, 0), Color("8a6a3e"), Vector3.ZERO, 12, 0.3)
	Props.cyl(n, 0.3, 0.02, Vector3(0, 0.78, 0), Color("c8d4d8"), Vector3.ZERO, 12)
	Props.ball(n, 0.12, Vector3(0.06, 0.8, 0.02), Color("efe8d8"), Vector3(1.3, 0.5, 1.0), 6)
	for sx: float in [-0.25, 0.25]:
		Props.cyl(n, 0.03, 0.46, Vector3(sx, 0.23, 0), Color("6a4a2a"), Vector3.ZERO, 5)
	return n


## Taş yığını + takoz (sur dibinde onarım işçisi): yerel +z ön
static func rubble() -> Node3D:
	var n := Node3D.new()
	n.name = "TasYigini"
	for i in 9:
		var a := i * 2.1
		var r := 0.18 + (i % 3) * 0.06
		Props.box(n, Vector3(r * 1.6, r, r * 1.3), Vector3(cos(a) * 0.32, r * 0.5, sin(a) * 0.26), [Color("9a8e78"), Color("8a8068"), Color("a89c84")][i % 3], Vector3(0, i * 31, i * 7))
	Props.box(n, Vector3(0.38, 0.3, 0.3), Vector3(0.75, 0.15, 0.1), Color("a89c84"), Vector3(0, 12, 0))
	Props.box(n, Vector3(0.28, 0.22, 0.26), Vector3(0.7, 0.41, 0.1), Color("b0a48c"), Vector3(0, -20, 0))
	return n


## Kapı önü kuyruğu/fırın tezgâhı yerine: küçük sepetli yer sergisi (dilenci önünde bakır tas)
static func bowl() -> Node3D:
	var n := Node3D.new()
	n.name = "Tas"
	Props.cyl(n, 0.1, 0.05, Vector3(0, 0.03, 0), Color("b87333"), Vector3.ZERO, 8, 0.07)
	return n


# ---------------------------------------------------------------- hayvanlar (+z ileri; ucuz, çarpışmasız)

const ANIMALS := [["dog", 2], ["cat", 2], ["hen", 4], ["donkey", 2]]


static func animal(kind: String, seed: int) -> Node3D:
	var r := RandomNumberGenerator.new()
	r.seed = 733 + seed * 17
	if kind == "hen":
		var c := Chicken.new()
		c.name = "Tavuk%d" % seed
		return c
	var n := Node3D.new()
	n.name = "Hayvan_%s%d" % [kind, seed]
	var legs: Array = []
	# CANLI (kalite notu 32): köpek, kedi, eşek canli_kit'ten (kesit halkalı gövde, türün başı, eklemli bacak); kutu yok.
	var fur: Color
	# çizim bütçesi: gövde + boyun + baş + kulak tek ağ, alt bacak üst bacağa pişer (hayvan başına 6 ağ)
	var opt := {"lod": 0, "birlestir": ["kulak", "boyun", "bas", "d"], "golge": kind == "donkey"}
	var tur := "kopek"
	match kind:
		"dog":
			fur = [Color("8a6a46"), Color("a89a80"), Color("5a4a3a"), Color("c8a468")][r.randi() % 4]
		"cat":
			fur = [Color("d8843a"), Color("6a6a70"), Color("e8e2d4"), Color("3a3430")][r.randi() % 4]
			tur = "kedi"
		"donkey":
			fur = [Color("7a6e62"), Color("8a7a66"), Color("5e5650")][r.randi() % 3]
			tur = "esek"
			opt["takim"] = ["yuk", "yular"]
	opt["renk"] = fur
	var kit: Dictionary = preload("res://scripts/world/ist/canli_kit.gd").dugum(tur, opt)
	n.add_child(kit["root"])
	var kp: Dictionary = kit["p"]
	for i in 4:
		legs.append(kp["b%d" % i])
	n.set_meta("tail", kp["kuyruk"])
	n.set_meta("legs", legs)
	return n


## Adım: moving iken çapraz bacaklar sallanır; kuyruk hafif oynar
static func animate(n: Node3D, t: float, moving: bool) -> void:
	var legs: Array = n.get_meta("legs", [])
	for i in legs.size():
		var leg := legs[i] as Node3D
		var ph := 0.0 if (i == 0 or i == 3) else PI
		leg.rotation.x = sin(t * 7.0 + ph) * 0.55 if moving else lerpf(leg.rotation.x, 0.0, 0.2)
	var tail := n.get_meta("tail", null) as Node3D
	if tail:
		tail.rotation.z = sin(t * 3.0 + n.get_instance_id() % 7) * 0.25


# ---------------------------------------------------------------- pişirme (çizim sayısı için)
## Bir kişi ~40 ağ parçasıdır; 30 kişi + tezgâhlar Mese'de +1300 çizim yapıyordu. Yakın (≤ 26 m) gerçek gövde, uzakta ve
## görünmeyende Crowd._bake ile tek yüzeye pişmiş donuk ikiz (vertex renkli, LOD'lu); tezgâh ve eşyalar da pişmiş tek ağ.
## Pişen ağlar user://crowd_cache'te saklanır (Crowd'un düzeni): ikinci açılışta pişirme yok.

static var _salt2 := ""


static func _key(kind: String) -> String:
	if _salt2 == "":
		_salt2 = FileAccess.get_md5("res://scripts/world/ist/hayat_yakin_govde.gd")
	return "HY|%s|%s" % [kind, _salt2]


static func _cached(key: String, build: Callable) -> ArrayMesh:
	if not Crowd._meshes.has(key) and not Crowd._from_disk(key):
		Crowd._meshes[key] = build.call()
		Crowd._to_disk(key)
	return Crowd._meshes[key]


## Kişinin donuk ikizi: rolün çalışma duruşunda (oturan oturur, işçi çekiç tutar)
static func twin_mesh(prol: String, idx: int, gece: bool) -> ArrayMesh:
	var pose := {"fisher": "sit_ground", "beggar": "sit_ground", "worker": "hammer", "washer": "stir", "sitter": "sit"}.get(prol, "") as String
	return _cached(_key("kisi|%s|%d|%s" % [prol, idx, gece]), func() -> ArrayMesh:
		var pr := body(prol, idx, gece)
		return Crowd._bake(pr, func():
			dress(pr, prol, idx, gece)
			Crowd._pose(pr, pose))
	)


## Sahne eşyası (tezgâh, tabure, leğen, taş yığını, tas) tek ağ; tezgâhın katı kutusu ayrı
static func prop(kind: String, seed: int) -> Node3D:
	var m := _cached(_key("esya|%s|%d|%s" % [kind, seed % 4 if kind == "stall" else 0, gece_mod]), func() -> ArrayMesh:
		var src: Node3D
		match kind:
			"stall": src = stall(seed)
			"stool": src = stool()
			"tub": src = tub()
			"rubble": src = rubble()
			_: src = bowl()
		return Crowd._bake(src, Callable())
	)
	var n := Node3D.new()
	n.name = "Esya_" + kind
	var mi := MeshInstance3D.new()
	mi.mesh = m
	mi.material_override = Crowd.material()
	n.add_child(mi)
	if kind == "stall":
		var sb := StaticBody3D.new()
		sb.collision_layer = 1
		sb.collision_mask = 0
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(1.95, 1.0, 1.0)
		cs.shape = bs
		cs.position = Vector3(0, 0.5, 0)
		sb.add_child(cs)
		n.add_child(sb)
	return n


static func animal_twin(kind: String, idx: int) -> ArrayMesh:
	return _cached(_key("hayvan|%s|%d" % [kind, idx]), func() -> ArrayMesh:
		return Crowd._bake(animal(kind, idx), Callable())
	)
