class_name Ayrinti
extends RefCounted
## İstanbul 1453, sokak hayatı ayrıntı kitaplığı. Her öğe: build_<id>(host, k, lod); hazır köşeler: build_set_<ad>.
## Öğe kodları ayrinti_a/b/c/d.gd içinde; burada kayıt, kurucu (lod, çarpışma, siluet) ve konma/tırmanma yolları var.
## Ölçek: öğe her zaman gerçek insan ölçüsündedir (k yalnız köşe/kümelerdeki yerleşim aralığını ölçekler).

const L := preload("res://scripts/world/ist/ayrinti_lib.gd")
const PARTS := [
	preload("res://scripts/world/ist/ayrinti_a.gd"),
	preload("res://scripts/world/ist/ayrinti_b.gd"),
	preload("res://scripts/world/ist/ayrinti_c.gd"),
	preload("res://scripts/world/ist/ayrinti_d.gd"),
]
const SETS := preload("res://scripts/world/ist/ayrinti_set.gd")

const GROUP_COLOR := {
	"carsi": Color("b0432f"), "kap": Color("b9683a"), "liman": Color("8a5a35"), "ev": Color("e6dabd"),
	"ciftlik": Color("c9a547"), "su": Color("9d978b"), "tasima": Color("8a5a35"), "yigin": Color("77726a"),
	"yapi": Color("a8553a"), "mutfak": Color("a8553a"), "kutsal": Color("d2a33a"), "harabe": Color("e4ded0"),
	"bahce": Color("62863f"), "hayvan": Color("7a5a3c"), "savas": Color("6e717a"), "kamp": Color("e6dabd"),
	"zanaat": Color("484a52"), "mezar": Color("9d978b"), "bitki": Color("62863f"), "ayin": Color("6b3a6e"),
}


static func _rows() -> Array:
	var out: Array = []
	for p in PARTS:
		for r in p.ITEMS:
			out.append([p, r])
	return out


static func ids() -> Array:
	var out: Array = []
	for pr in _rows():
		out.append(pr[1][0])
	return out


static func _find(id: String) -> Array:
	for pr in _rows():
		if pr[1][0] == id:
			return pr
	return []


## Kayıt: şehir kurucusu bunu okuyup serpiştirir. Konum alanları 0 kalır.
static func catalog() -> Array:
	var out: Array = []
	for pr in _rows():
		var r: Array = pr[1]
		out.append({
			"id": r[0], "ad": r[1], "dogu_m": 0.0, "kuzey_m": 0.0,
			"gercek_olcu": Vector3(r[2], r[3], r[4]), "yon_derece": 0.0, "durum": "saglam", "tur": "ayrinti",
			"grup": r[6], "carpisma": r[5],
		})
	for sd in SETS.SET_DEFS:
		out.append({
			"id": "set_" + sd[0], "ad": sd[1], "dogu_m": 0.0, "kuzey_m": 0.0,
			"gercek_olcu": sd[2], "yon_derece": 0.0, "durum": "saglam", "tur": "ayrinti",
			"grup": "kume", "carpisma": "ozel",
		})
	return out


## Tek öğe kurucu. k yalnız kümelerde yerleşim aralığını etkiler; tek öğe her zaman gerçek ölçüdedir.
static func build(id: String, host: Node3D, k: float = 0.5, lod: int = 0) -> Node3D:
	if id.begins_with("set_"):
		return SETS.build_set(id.substr(4), host, k, lod)
	var pr := _find(id)
	if pr.is_empty():
		push_warning("Ayrinti: bilinmeyen öğe " + id)
		return null
	var r: Array = pr[1]
	var root := Node3D.new()
	root.name = id
	host.add_child(root)
	L.lod = lod
	if lod >= 2:
		var col: Color = GROUP_COLOR.get(r[6], Color("8a5a35"))
		Props.box(root, Vector3(r[2], r[3], r[4]), Vector3(0, r[3] * 0.5, 0), col)
	else:
		pr[0].call("build_" + id, root)
		if r[5] == "kutu" and lod == 0:
			L.col_box(root, Vector3(r[2], r[3], r[4]), Vector3(0, r[3] * 0.5, 0))
	L.lod = 0
	return root


static func perches(id: String, _k: float = 0.5) -> Array:
	if id.begins_with("set_"):
		return SETS.perches_set(id.substr(4))
	var pr := _find(id)
	if pr.is_empty():
		return []
	var r: Array = pr[1]
	if r[5] == "yok" or r[3] < 0.6:
		return []
	match id:
		"tente", "asma_cardagi":
			return [Vector3(0, r[3] + 0.0, 0)]
		"guvercinlik":
			return [Vector3(0, 3.15, 0)]
		"kuyu":
			return [Vector3(0, 0.85, 0)]
	return [Vector3(0, r[3], 0)]


static func climbs(id: String, _k: float = 0.5) -> Array:
	if id.begins_with("set_"):
		return SETS.climbs_set(id.substr(4))
	match id:
		"sandik_yigini":
			return [[Vector3(0, 0, 1.4), Vector3(0, 0.52, 0.5), "sandik"], [Vector3(0, 0.52, 0.5), Vector3(0, 1.04, -0.5), "sandik"]]
		"merdiven":
			return [[Vector3(0, 0, 0.9), Vector3(0, 3.0, -0.4), "merdiven"]]
		"kayik":
			return [[Vector3(0, 0, 1.9), Vector3(0, 0.45, 0.8), "basamak"]]
	return []
