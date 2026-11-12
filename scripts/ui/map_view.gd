class_name MapView
extends RefCounted
## 1453 İstanbul haritası (v0.90): pişmiş doku (assets/ui/map1453.png, tools/map_bake.gd) ile dünya arasındaki
## dönüşüm. Kuzey yukarı: dünya −x yukarı, −z sağa (doğu, Boğaz). Dünya = World1453 / SiegeField koordinatı.
## Harita yalnız 1453 dünyası kurulan bölümlerde açılır: SiegeField dünyayı kurunca "world1453" grubuna girer (World1453.build
## ve LandWalls); oyuncunun dünyadaki yeri o alanın dönüşümünün tersiyle bulunur. Sağ alttaki MiniMap ve M ile açılan
## WorldMap bu sınıfı kullanır.

const TEX_PATH := "res://assets/ui/map1453.png"
const X0 := -1450.0     # kuzey kenar (Galata'nın ardı)
const X1 := 950.0       # güney kenar (Marmara)
const Z0 := -2450.0     # doğu kenar (Asya yakası)
const Z1 := 950.0       # batı kenar (ova, ordugâhın ardı)
const MPP := 1.5        # piksel başına metre
const W := 2267         # roundi((Z1 - Z0) / MPP)
const H := 1600         # roundi((X1 - X0) / MPP)
const GROUP := "world1453"

## Haritadaki bölge adları: [metin anahtarı, dünya (x, z), yazı boyu, eğim (radyan, yatayla)]
const REGION_LABELS := [
	["UI_MAP_HORN", Vector2(-812.0, -820.0), 22, 0.0],
	["UI_MAP_MARMARA", Vector2(560.0, -1350.0), 26, 0.0],
	["UI_MAP_BOSPHORUS", Vector2(-760.0, -1930.0), 22, -1.571],
	["UI_MAP_GALATA", Vector2(-1110.0, -1330.0), 20, 0.0],
	["UI_MAP_USKUDAR", Vector2(-640.0, -2300.0), 20, 0.0],
	["UI_MAP_CAMP", Vector2(60.0, 560.0), 20, 0.0],
	["UI_MAP_EYUP", Vector2(-640.0, 300.0), 16, 0.0],
	["UI_MAP_LANDWALLS", Vector2(250.0, 40.0), 15, -1.571],
	["UI_MAP_CITY", Vector2(-180.0, -560.0), 26, 0.0],
]

static var _tex: Texture2D

## İstanbul v2 (IstBaglama, BAĞLAMA-4): bölüm v2'de oynanırken harita v2'nin haritasıdır. Alan: v2 kökü (IstDunya; "world1453"
## grubunda), koordinat v2 dünyası (+x doğu, −z kuzey). Kuzey yukarı: piksel x = doğu, piksel y = güney. Aynı W × H × MPP
## (3,4 × 2,4 km) çerçeve: MiniMap ve WorldMap değişmeden çalışır. Doku: tests/_ist/harita_v2.gd'nin pişirdiği resim.
static var v2 := false
const V2_TEX_PATH := "res://assets/ui/harita_ist2.res"
const V2_X0 := -2250.0  # batı kenar (ordugâhın ardı)
const V2_Z0 := -1250.0  # kuzey kenar (Galata'nın ardı)
static var _tex_v2: Texture2D
## v2 bölge adları: [metin anahtarı, gerçek (enlem, boylam), yazı boyu, eğim]
const V2_LABELS := [
	["UI_MAP_HORN", Vector2(41.030, 28.958), 22, -0.5],
	["UI_MAP_MARMARA", Vector2(40.996, 28.955), 26, 0.0],
	["UI_MAP_BOSPHORUS", Vector2(41.022, 29.000), 22, -1.2],
	["UI_MAP_GALATA", Vector2(41.028, 28.976), 20, 0.0],
	["UI_MAP_USKUDAR", Vector2(41.024, 29.015), 20, 0.0],
	["UI_MAP_CAMP", Vector2(41.022, 28.905), 20, 0.0],
	["UI_MAP_EYUP", Vector2(41.047, 28.934), 16, 0.0],
	["UI_MAP_LANDWALLS", Vector2(41.016, 28.921), 15, -1.4],
	["UI_MAP_CITY", Vector2(41.014, 28.955), 26, 0.0],
]
## Landmarks1453 anahtarı → gerçek (enlem, boylam) (docs/ISTANBUL_YERLER.csv)
const V2_LL := {
	"ayasofya": Vector2(41.0086, 28.98), "aya_irini": Vector2(41.0093, 28.9811), "augustaion": Vector2(41.008, 28.979),
	"cistern": Vector2(41.0081, 28.9778), "hippodrome": Vector2(41.0064, 28.9758), "great_palace": Vector2(41.0058, 28.9772),
	"forum_constantine": Vector2(41.0086, 28.9711), "forum_tauri": Vector2(41.0097, 28.9636),
	"aqueduct": Vector2(41.0159, 28.9556), "apostles": Vector2(41.0197, 28.9497), "pantokrator": Vector2(41.0197, 28.9572),
	"khora": Vector2(41.0312, 28.939), "pammakaristos": Vector2(41.0292, 28.9464), "studios": Vector2(40.9961, 28.9286),
	"golden_gate": Vector2(40.9925, 28.9225), "harbor_theodosius": Vector2(41.0, 28.9535),
	"harbor_kontoskalion": Vector2(41.001, 28.969), "quay_venice": Vector2(41.02, 28.969),
	"quay_amalfi": Vector2(41.0235, 28.9645), "quay_genoa": Vector2(41.0215, 28.973),
	"galata_tower": Vector2(41.0256, 28.9742),
}


## Bölge adları (WorldMap): v2'de v2 konumlarıyla
static func region_labels() -> Array:
	if not v2:
		return REGION_LABELS
	var out: Array = []
	for r: Array in V2_LABELS:
		var p := IstGeo.ll((r[1] as Vector2).x, (r[1] as Vector2).y)
		out.append([r[0], Vector2(p.x, p.z), r[2], r[3]])
	return out


static func texture() -> Texture2D:
	if v2:
		if _tex_v2 == null and ResourceLoader.exists(V2_TEX_PATH):
			var im = load(V2_TEX_PATH)
			if im is Image:
				_tex_v2 = ImageTexture.create_from_image(im)
			elif im is Texture2D:
				_tex_v2 = im
		return _tex_v2
	if _tex == null and ResourceLoader.exists(TEX_PATH):
		_tex = load(TEX_PATH)
	return _tex


## Dünya (x, z) → haritanın pikseli
static func world_pixel(p: Vector2) -> Vector2:
	if v2:
		return Vector2((p.x - V2_X0) / MPP, (p.y - V2_Z0) / MPP)
	return Vector2((Z1 - p.y) / MPP, (p.x - X0) / MPP)


## Haritanın pikseli → dünya (x, z)
static func pixel_world(px: Vector2) -> Vector2:
	if v2:
		return Vector2(V2_X0 + px.x * MPP, V2_Z0 + px.y * MPP)
	return Vector2(X0 + px.y * MPP, Z1 - px.x * MPP)


## Dünya (x, z) haritanın içinde mi
static func inside(p: Vector2) -> bool:
	if v2:
		return p.x >= V2_X0 and p.x <= V2_X0 + W * MPP and p.y >= V2_Z0 and p.y <= V2_Z0 + H * MPP
	return p.x >= X0 and p.x <= X1 and p.y >= Z0 and p.y <= Z1


## Şu anki bölümün 1453 dünyası (yoksa null)
static func field(tree: SceneTree) -> Node3D:
	if tree == null:
		return null
	for n in tree.get_nodes_in_group(GROUP):
		if is_instance_valid(n) and (n as Node3D).is_inside_tree():
			return n
	return null


## Sahnedeki bir noktanın dünya (x, z)'si
static func to_world(f: Node3D, global_pos: Vector3) -> Vector2:
	var p := f.global_transform.affine_inverse() * global_pos
	return Vector2(p.x, p.z)


## Bakış yönünün haritadaki açısı: kuzeyden (yukarıdan) saat yönünde, radyan
static func heading(f: Node3D, b: Basis) -> float:
	var fwd := f.global_transform.basis.inverse() * (-b.z)
	if v2:
		return atan2(fwd.x, -fwd.z)          # v2: yukarı = −z (kuzey), sağ = +x (doğu)
	# haritada sağ = dünya −z, aşağı = dünya +x: yön (−fwd.z, fwd.x)
	return atan2(-fwd.z, -fwd.x)


## Haritadaki tarihî yapılar: {"key", "name_key", "px": Vector2 (piksel), "seen": bool (keşfedildi mi)}
static func landmarks() -> Array:
	var out: Array = []
	for l: Dictionary in Landmarks1453.all():
		var p: Vector3 = l["pos"]
		if v2:
			if not V2_LL.has(str(l["key"])):
				continue
			var ll: Vector2 = V2_LL[str(l["key"])]
			p = IstGeo.ll(ll.x, ll.y)
		out.append({"key": l["key"], "name_key": l["name_key"], "px": world_pixel(Vector2(p.x, p.z)),
			"seen": GameState.discovered.has(str(l["key"]))})
	return out
