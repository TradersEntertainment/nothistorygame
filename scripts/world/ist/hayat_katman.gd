class_name IstHayatKatman
extends RefCounted
## İstanbul v2 yaşam katmanı: tek tür örneğin (insan, duman, pencere …) kayıtları + mesafeye göre akan MultiMesh görünümleri.
## Kayıtlar hücre başına (48 m) düz kayan nokta dizisinde tutulur (MultiMesh arabellek düzeninde: 12 dönüşüm [+ 4 renk] [+ 4 özel]);
## yenile() izleyiciye yakın hücreleri (yakından uzağa) arabelleğe kopyalar: CPU maliyeti ~ hücre sayısı, çizim = görünüm sayısı.

const CELL := 48.0

var ad := ""
var renkli := false
var ozel := false
var stride := 12
var cells := {}                  # Vector2i → PackedFloat32Array
var n := 0
var views: Array = []            # {mesh, mat, d0, d1, cap, mm, mmi, n}


func _init(ad_: String, renkli_ := false, ozel_ := false) -> void:
	ad = ad_
	renkli = renkli_
	ozel = ozel_
	stride = 12 + (4 if renkli else 0) + (4 if ozel else 0)


func add(xf: Transform3D, renk := Color.WHITE, ozel_veri := Color(0, 0, 0, 0)) -> void:
	var o := xf.origin
	var key := Vector2i(floori(o.x / CELL), floori(o.z / CELL))
	var a: PackedFloat32Array = cells.get(key, PackedFloat32Array())
	var b := xf.basis
	a.append_array(PackedFloat32Array([b.x.x, b.y.x, b.z.x, o.x, b.x.y, b.y.y, b.z.y, o.y, b.x.z, b.y.z, b.z.z, o.z]))
	if renkli:
		a.append_array(PackedFloat32Array([renk.r, renk.g, renk.b, renk.a]))
	if ozel:
		a.append_array(PackedFloat32Array([ozel_veri.r, ozel_veri.g, ozel_veri.b, ozel_veri.a]))
	cells[key] = a
	n += 1


## Görünüm: mesh, malzeme, hücre-merkezi uzaklık bandı [d0, d1), üst sınır
func gorunum(mesh: Mesh, mat: Material, d0: float, d1: float, cap: int) -> Dictionary:
	var v := {"mesh": mesh, "mat": mat, "d0": d0, "d1": d1, "cap": cap, "n": 0}
	views.append(v)
	return v


func kur(parent: Node3D) -> void:
	for v: Dictionary in views:
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_colors = renkli
		mm.use_custom_data = ozel
		mm.mesh = v["mesh"]
		mm.instance_count = v["cap"]
		mm.visible_instance_count = 0
		var mi := MultiMeshInstance3D.new()
		mi.name = "Hayat_%s" % ad
		mi.multimesh = mm
		mi.material_override = v["mat"]
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.custom_aabb = AABB(Vector3(-6000, -300, -6000), Vector3(12000, 900, 12000))
		mi.set_meta("no_walk", true)
		mi.set_meta("soft", true)
		parent.add_child(mi)
		v["mm"] = mm
		v["mmi"] = mi


func yenile(p: Vector3) -> void:
	for v: Dictionary in views:
		_yenile_gorunum(v, p)


func _yenile_gorunum(v: Dictionary, p: Vector3) -> void:
	var d0: float = v["d0"]
	var d1: float = v["d1"]
	var cap: int = v["cap"]
	var i0 := floori((p.x - d1) / CELL)
	var i1 := floori((p.x + d1) / CELL)
	var j0 := floori((p.z - d1) / CELL)
	var j1 := floori((p.z + d1) / CELL)
	var list: Array = []
	for i in range(i0, i1 + 1):
		for j in range(j0, j1 + 1):
			var key := Vector2i(i, j)
			if not cells.has(key):
				continue
			var dd := Vector2((i + 0.5) * CELL - p.x, (j + 0.5) * CELL - p.z).length()
			if dd >= d0 and dd < d1:
				list.append([dd, key])
	list.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	var out := PackedFloat32Array()
	var cnt := 0
	for e: Array in list:
		var a: PackedFloat32Array = cells[e[1]]
		var m := a.size() / stride
		if cnt + m > cap:
			m = cap - cnt
			out.append_array(a.slice(0, m * stride))
			cnt += m
			break
		out.append_array(a)
		cnt += m
	var mm: MultiMesh = v["mm"]
	v["n"] = cnt
	out.resize(cap * stride)
	mm.buffer = out
	mm.visible_instance_count = cnt
