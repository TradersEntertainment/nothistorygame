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


static func texture() -> Texture2D:
	if _tex == null and ResourceLoader.exists(TEX_PATH):
		_tex = load(TEX_PATH)
	return _tex


## Dünya (x, z) → haritanın pikseli
static func world_pixel(p: Vector2) -> Vector2:
	return Vector2((Z1 - p.y) / MPP, (p.x - X0) / MPP)


## Haritanın pikseli → dünya (x, z)
static func pixel_world(px: Vector2) -> Vector2:
	return Vector2(X0 + px.y * MPP, Z1 - px.x * MPP)


## Dünya (x, z) haritanın içinde mi
static func inside(p: Vector2) -> bool:
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
	# haritada sağ = dünya −z, aşağı = dünya +x: yön (−fwd.z, fwd.x)
	return atan2(-fwd.z, -fwd.x)


## Haritadaki tarihî yapılar: {"key", "name_key", "px": Vector2 (piksel), "seen": bool (keşfedildi mi)}
static func landmarks() -> Array:
	var out: Array = []
	for l: Dictionary in Landmarks1453.all():
		var p: Vector3 = l["pos"]
		out.append({"key": l["key"], "name_key": l["name_key"], "px": world_pixel(Vector2(p.x, p.z)),
			"seen": GameState.discovered.has(str(l["key"]))})
	return out
