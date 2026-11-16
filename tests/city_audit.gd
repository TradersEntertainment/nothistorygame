extends Node3D
## Şehir denetimi (docs/ISTANBUL_PLAN.md §5): bir dünya dikdörtgeninde oyuncunun düşebileceği, sıkışabileceği, içine
## girebileceği yerleri ve tırmanma yollarını otomatik sayar. Satırlar `CITYAUDIT …` ile başlar.
##
## Kurulum: Bölüm 6b'nin hub'ı (ByzCity, part "walls": tek haritada World1453.build ile bütün dünya) bu sahnede kurulur;
## WorldWalk dünyayı katılaştırınca denetim dünya koordinatındaki dikdörtgen(ler)de koşar.
##   godot --headless --path . res://tests/city_audit.tscn -- [--rect=x0,z0,x1,z1,ad]… [--grid=0.5]
## Varsayılan dikdörtgenler: "hub" (M01 Romanos/hub, x −140…180, z −330…−4) ve "mese" (dünyanın bugünkü şehri, Tauri
## Forumu çevresi, x −500…−300, z −1240…−1040).
##
## Ölçülenler (ızgara aralığı varsayılan 0,5 m):
##   delik        zeminde delik: yukarıdan aşağı ışın hiçbir şeye çarpmıyor ya da beklenen zeminin 1,5 m altına iniyor
##   dar          girilebilir dar aralık: iki katı arasında 0,6 ≤ genişlik < 0,9 m, sokaktan ulaşılan (küme sayısı)
##   cep          kapalı cep: zemin hücreleri sokaktan yürüyerek ulaşılamayan, kenara değmeyen küme (≥ 1 m²)
##   havada       havada duran yapı: çarpışma kutusunun tabanı ile altındaki yüzey arası > 5 cm (bütün yoklamalarda)
##   gomulu_kapi  zemine gömülü kapı: kapı biçimli ağın (ince, 1,6–2,4 m) altı zeminin 8 cm'den çok altında
##   ic_ice       iç içe yapı: iki ayrı gövdenin kutuları birbirine en küçüğünün hacminin %30'undan çok giriyor
##   sokak_kapali sokağı kapatan yapı: CityPlan sokak ekseninde 1 m'de bir, 1 m yükseklikte katı (örnek / kenar)
##   agsiz_cisim  görünür ağ var ama çarpışma yok (katı görünen ≥ 2 m³ ağ)
##   gorunmez     çarpışma var ama görünür ağ yok (≥ 1 m³ şekil); bilinçli görünmez sınır (ağı gizli gövde) ayrı
##   cati_yolu    sokaktan çatıya yol sayısı (normal kip: yürü 0,42, zıpla 0,6; tırmanma kipi: + tutunup çık 2,3)

const GRID := 0.5
const TOP := 70.0
const ROOF_H := 3.0           # sütunun en alt yüzeyinden bu kadar yüksek yürünür yüzey = çatı/dam
const STEP := 0.42
const JUMP_UP := 0.6
const MANTLE := 2.3
const DROP := 3.5
const LAYERS := 4

var _f: SiegeField
var _city: Node3D
var _space: PhysicsDirectSpaceState3D
var _grid := GRID
var _rects: Array = []
var _rid_ground := {}


func _ready() -> void:
	GameState.autotest = false
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--rect="):
			var p := a.substr(7).split(",")
			_rects.append([Rect2(Vector2(p[0].to_float(), p[1].to_float()), Vector2(p[2].to_float() - p[0].to_float(), p[3].to_float() - p[1].to_float())), p[4] if p.size() > 4 else "rect"])
		elif a.begins_with("--grid="):
			_grid = a.substr(7).to_float()
	if _rects.is_empty():
		_rects = [[Rect2(-140.0, -330.0, 320.0, 326.0), "hub"], [Rect2(-500.0, -1240.0, 200.0, 200.0), "mese"]]
	var t0 := Time.get_ticks_msec()
	var c := ByzCity.new()
	c.part = "walls"
	add_child(c)
	_city = c
	_f = c.world
	# WorldWalk bitene kadar bekle (dünya katılaşır), sonra birkaç fizik karesi
	var ww: WorldWalk = _f.get_node_or_null("WorldWalk") if _f else null
	var t := 0.0
	while ww and not ww.done and t < 600.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	# Şehir parçaları (CityChunks) varsa denetlenen dikdörtgenlerin hepsi yakın katmanda kurulsun
	var ch := _f.get_node_or_null("CityChunks") if _f else null
	if ch and ch.has_method("force_build"):
		for r: Array in _rects:
			await ch.force_build(r[0])
	for i in 6:
		await get_tree().physics_frame
	_space = get_world_3d().direct_space_state
	print("CITYAUDIT kurulum ms=%d chunks=%s" % [Time.get_ticks_msec() - t0, "var" if ch else "yok"])
	for r: Array in _rects:
		_audit(r[0], r[1])
	get_tree().quit(0)


# ---------------------------------------------------------------- yardımcılar

func _w2s(p: Vector3) -> Vector3:
	return _f.to_global(p)


func _ray(a: Vector3, b: Vector3, inside := false) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(a, b, 1)
	q.hit_from_inside = inside
	q.collide_with_areas = false
	var h := _space.intersect_ray(q)
	# Hareketli gövdeler (karakterler) sayılmaz
	var guard := 0
	while not h.is_empty() and not (h["collider"] is StaticBody3D) and guard < 4:
		q.exclude = q.exclude + [h["rid"]]
		h = _space.intersect_ray(q)
		guard += 1
	return h


## p (sahne) bir katının içinde mi: dışbükey şekil noktayı içeriyor ya da yukarı ışın bir yüzeye arkasından çarpıyor
## (WorldWalk'ın içbükey ağları: arka yüz çarpışmalı)
func _occupied(p: Vector3) -> bool:
	var pq := PhysicsPointQueryParameters3D.new()
	pq.position = p
	pq.collision_mask = 1
	for r: Dictionary in _space.intersect_point(pq, 4):
		if r["collider"] is StaticBody3D:
			return true
	var up := _ray(p, p + Vector3.UP * 40.0)
	if not up.is_empty() and (up["normal"] as Vector3).y > 0.3:
		return true
	return false


# ---------------------------------------------------------------- denetim

func _audit(rect: Rect2, label: String) -> void:
	var t0 := Time.get_ticks_msec()
	var nx := int(rect.size.x / _grid)
	var nz := int(rect.size.y / _grid)
	var n := nx * nz
	# Sütunların yürünür yüzeyleri (sahne y), yukarıdan aşağı en çok LAYERS; NAN = yok
	var surf := PackedFloat32Array()
	surf.resize(n * LAYERS)
	surf.fill(NAN)
	var lowest := PackedFloat32Array()
	lowest.resize(n)
	var holes := 0
	var hole_pts: Array = []
	for j in nz:
		for i in nx:
			var wx := rect.position.x + (i + 0.5) * _grid
			var wz := rect.position.y + (j + 0.5) * _grid
			var exp_y := World1453.surface_h(wx, wz)
			var top := _w2s(Vector3(wx, exp_y + TOP, wz))
			var cur := top
			var got: Array = []
			var low := NAN
			for k in 8:
				var h := _ray(cur, cur + Vector3.DOWN * (TOP + 30.0))
				if h.is_empty():
					break
				var hp: Vector3 = h["position"]
				var nrm: Vector3 = h["normal"]
				if nrm.y > 0.6:
					got.append(hp.y)
					low = hp.y
				cur = hp + Vector3.DOWN * 0.03
			var ci := j * nx + i
			var expect_s := _w2s(Vector3(wx, exp_y, wz)).y
			if is_nan(low) or low < expect_s - 1.5:
				if not World1453.is_water(wx, wz):
					holes += 1
					if hole_pts.size() < 8:
						hole_pts.append(Vector2(wx, wz))
				lowest[ci] = NAN
				continue
			lowest[ci] = low
			# Yukarıdan aşağı sıralı; tavanı ≥ 1,8 m olanlar (üstündeki yüzeyle arası) durulabilir
			var keep: Array = []
			for g in got.size():
				var y: float = got[g]
				if g > 0 and float(got[g - 1]) - y < 1.8:
					continue
				keep.append(y)
			keep.reverse()          # aşağıdan yukarı
			for k in mini(keep.size(), LAYERS):
				surf[ci * LAYERS + k] = keep[k]
	# Zemin katmanı: en alt yüzey; içinde katı var mı (0,5 ve 1,4 m)
	var free := PackedByteArray()
	free.resize(n)
	for ci in n:
		if is_nan(lowest[ci]):
			continue
		var i := ci % nx
		var j := ci / nx
		var wx := rect.position.x + (i + 0.5) * _grid
		var wz := rect.position.y + (j + 0.5) * _grid
		var s := _w2s(Vector3(wx, 0, wz))
		s.y = lowest[ci]
		if _occupied(s + Vector3.UP * 0.5) or _occupied(s + Vector3.UP * 1.4):
			continue
		free[ci] = 1
	# Genişlik: yatay ışınlarla iki eksende (x, z) ve iki köşegende; oyuncu (çap 0,6) sığıyor mu, dar mı
	var narrow := PackedByteArray()
	narrow.resize(n)
	var fits := PackedByteArray()
	fits.resize(n)
	var dirs := [Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0.7071, 0, 0.7071), Vector3(0.7071, 0, -0.7071)]
	var basis := _f.global_transform.basis
	for ci in n:
		if free[ci] == 0:
			continue
		var i := ci % nx
		var j := ci / nx
		var s := _w2s(Vector3(rect.position.x + (i + 0.5) * _grid, 0, rect.position.y + (j + 0.5) * _grid))
		s.y = lowest[ci] + 1.0
		var minw := 99.0
		for d: Vector3 in dirs:
			var dd := (basis * d).normalized()
			var a := _ray(s, s + dd * 1.6)
			var b := _ray(s, s - dd * 1.6)
			var wa := s.distance_to(a["position"]) if not a.is_empty() else 1.6
			var wb := s.distance_to(b["position"]) if not b.is_empty() else 1.6
			minw = minf(minw, wa + wb)
		if minw >= 0.6:
			fits[ci] = 1
		if minw >= 0.6 and minw < 0.9:
			narrow[ci] = 1
	# Sokaktan yürüyerek ulaşılan zemin: kenardaki en büyük açık küme (tohum) üzerinden taşma
	var comp := PackedInt32Array()
	comp.resize(n)
	comp.fill(-1)
	var sizes: Array = []
	var border: Array = []
	for ci in n:
		if fits[ci] == 0 or comp[ci] >= 0:
			continue
		var id := sizes.size()
		var q := PackedInt32Array([ci])
		comp[ci] = id
		var cnt := 0
		var touches := false
		var h := 0
		while h < q.size():
			var c := q[h]
			h += 1
			cnt += 1
			var ci_ := c % nx
			var cj := c / nx
			if ci_ == 0 or cj == 0 or ci_ == nx - 1 or cj == nz - 1:
				touches = true
			for o: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var ii := ci_ + o.x
				var jj := cj + o.y
				if ii < 0 or jj < 0 or ii >= nx or jj >= nz:
					continue
				var nb := jj * nx + ii
				if fits[nb] == 0 or comp[nb] >= 0:
					continue
				if absf(lowest[nb] - lowest[c]) > STEP:
					continue
				comp[nb] = id
				q.append(nb)
		sizes.append(cnt)
		border.append(touches)
	var main := -1
	for id in sizes.size():
		if border[id] and (main < 0 or sizes[id] > sizes[main]):
			main = id
	var pockets := 0
	var pocket_cells := 0
	var pocket_pts: Array = []
	for id in sizes.size():
		if id == main or border[id] or int(sizes[id]) * _grid * _grid < 1.0:
			continue
		pockets += 1
		pocket_cells += sizes[id]
	if pockets > 0:
		var seen := {}
		for ci in n:
			var id := comp[ci]
			if id >= 0 and id != main and not border[id] and int(sizes[id]) * _grid * _grid >= 1.0 and not seen.has(id) and pocket_pts.size() < 8:
				seen[id] = true
				pocket_pts.append(Vector2(rect.position.x + (ci % nx + 0.5) * _grid, rect.position.y + (ci / nx + 0.5) * _grid))
	# Dar aralık kümeleri (yalnız ulaşılan kümelerdeki)
	var narrow_cl := 0
	var narrow_pts: Array = []
	var nseen := PackedByteArray()
	nseen.resize(n)
	for ci in n:
		if narrow[ci] == 0 or nseen[ci] == 1 or comp[ci] < 0 or comp[ci] != main:
			continue
		narrow_cl += 1
		if narrow_pts.size() < 8:
			narrow_pts.append(Vector2(rect.position.x + (ci % nx + 0.5) * _grid, rect.position.y + (ci / nx + 0.5) * _grid))
		var q := PackedInt32Array([ci])
		nseen[ci] = 1
		var h := 0
		while h < q.size():
			var c := q[h]
			h += 1
			for o: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var ii := c % nx + o.x
				var jj := c / nx + o.y
				if ii < 0 or jj < 0 or ii >= nx or jj >= nz:
					continue
				var nb := jj * nx + ii
				if narrow[nb] == 1 and nseen[nb] == 0:
					nseen[nb] = 1
					q.append(nb)
	var t_grid := Time.get_ticks_msec() - t0
	# Çatı yolları (normal kip ve tırmanma kipi)
	var paths_n := _roof_paths(surf, lowest, comp, main, nx, nz, rect, false)
	var paths_c := _roof_paths(surf, lowest, comp, main, nx, nz, rect, true)
	# Gövde ve ağ denetimleri
	var bodies := _body_checks(rect)
	var streets := _street_checks(rect)
	print("CITYAUDIT %s rect=(%.0f,%.0f)-(%.0f,%.0f) grid=%.2f hücre=%d delik=%d dar=%d cep=%d (%.0f m²) havada=%d gomulu_kapi=%d ic_ice=%d sokak_kapali=%d/%d kenar=%d agsiz_cisim=%d gorunmez=%d bilincli_sinir=%d cati_yolu_normal=%d cati_yolu_tirmanma=%d ms=%d" % [
		label, rect.position.x, rect.position.y, rect.end.x, rect.end.y, _grid, n, holes, narrow_cl, pockets,
		pocket_cells * _grid * _grid, bodies["floating"], bodies["buried_door"], bodies["nested"], streets["blocked"],
		streets["samples"], streets["edges"], bodies["mesh_nocol"], bodies["col_nomesh"], bodies["bounds"],
		paths_n["count"], paths_c["count"], Time.get_ticks_msec() - t0])
	print("CITYAUDIT %s örnek delik=%s" % [label, _fmt(hole_pts)])
	print("CITYAUDIT %s örnek dar=%s" % [label, _fmt(narrow_pts)])
	print("CITYAUDIT %s örnek cep=%s" % [label, _fmt(pocket_pts)])
	print("CITYAUDIT %s örnek havada=%s" % [label, _fmt(bodies["floating_pts"])])
	print("CITYAUDIT %s örnek gomulu_kapi=%s" % [label, _fmt(bodies["door_pts"])])
	print("CITYAUDIT %s örnek ic_ice=%s" % [label, _fmt(bodies["nested_pts"])])
	print("CITYAUDIT %s örnek sokak_kapali=%s" % [label, _fmt(streets["pts"])])
	print("CITYAUDIT %s örnek agsiz_cisim=%s" % [label, _fmt(bodies["mesh_nocol_pts"])])
	print("CITYAUDIT %s örnek gorunmez=%s" % [label, _fmt(bodies["col_nomesh_pts"])])
	print("CITYAUDIT %s cati_yolu_normal=%s" % [label, _fmt(paths_n["pts"])])
	print("CITYAUDIT %s cati_yolu_tirmanma=%s" % [label, _fmt(paths_c["pts"])])
	print("CITYAUDIT %s süre ızgara=%d ms" % [label, t_grid])


func _fmt(a: Array) -> String:
	var s: Array = []
	for p in a:
		var v: Vector2 = p
		s.append("(%.1f,%.1f)" % [v.x, v.y])
	return "[" + ", ".join(s) + "]"


## Sokaktan (ana zemin kümesi) çatıya (sütunun en alt yüzeyinden ≥ ROOF_H yukarıda yürünür yüzey) ulaşan yollar:
## çatıdan geriye doğru (ters kenarlarla) ulaşılabilen düğümler bulunur; sokaktaki düğümlerden bu kümeye yukarı bir
## adımla girilen yerler "giriş"tir; girişler 4 m'lik kümelere toplanır, her küme bir yol sayılır.
func _roof_paths(surf: PackedFloat32Array, lowest: PackedFloat32Array, comp: PackedInt32Array, main: int, nx: int, nz: int, rect: Rect2, climb: bool) -> Dictionary:
	var n := nx * nz
	var reach := PackedByteArray()
	reach.resize(n * LAYERS)
	var q := PackedInt32Array()
	for ci in n:
		if is_nan(lowest[ci]):
			continue
		for k in LAYERS:
			var y := surf[ci * LAYERS + k]
			if is_nan(y):
				break
			if y - lowest[ci] >= ROOF_H:
				reach[ci * LAYERS + k] = 1
				q.append(ci * LAYERS + k)
	var offs: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]
	if climb:
		offs += [Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]
	var h := 0
	while h < q.size():
		var b := q[h]
		h += 1
		var bc := b / LAYERS
		var yb := surf[b]
		var bi := bc % nx
		var bj := bc / nx
		for o: Vector2i in offs:
			var ii := bi + o.x
			var jj := bj + o.y
			if ii < 0 or jj < 0 or ii >= nx or jj >= nz:
				continue
			var ac := jj * nx + ii
			for k in LAYERS:
				var a := ac * LAYERS + k
				var ya := surf[a]
				if is_nan(ya):
					break
				if reach[a] == 1:
					continue
				var up := yb - ya             # a'dan b'ye çıkış
				var ok := false
				if absf(o.x) + absf(o.y) <= 2 and absf(o.x) <= 1 and absf(o.y) <= 1:
					ok = (up <= JUMP_UP and up >= -DROP)
				if climb and not ok and up > JUMP_UP and up <= MANTLE:
					ok = true
				if ok:
					reach[a] = 1
					q.append(a)
	# Girişler: ana kümedeki zemin düğümü, roof'a ulaşan; komşusunda ondan ≥ 0,3 m yüksek ulaşan bir düğüm var
	var entries := {}
	for ci in n:
		if comp[ci] != main or comp[ci] < 0:
			continue
		var g := ci * LAYERS
		if reach[g] == 0:
			continue
		var bi := ci % nx
		var bj := ci / nx
		var ya := surf[g]
		var found := false
		for o: Vector2i in offs:
			var ii := bi + o.x
			var jj := bj + o.y
			if ii < 0 or jj < 0 or ii >= nx or jj >= nz:
				continue
			var bc := jj * nx + ii
			for k in LAYERS:
				var b := bc * LAYERS + k
				if is_nan(surf[b]):
					break
				if reach[b] == 1 and surf[b] - ya >= 0.3 and (comp[bc] != main or k > 0 or surf[b] - lowest[bc] > 0.3):
					found = true
		if found:
			var key := Vector2i(floori(bi * _grid / 4.0), floori(bj * _grid / 4.0))
			if not entries.has(key):
				entries[key] = Vector2(rect.position.x + (bi + 0.5) * _grid, rect.position.y + (bj + 0.5) * _grid)
	# Bitişik 4 m hücreleri tek yol say
	var keys: Array = entries.keys()
	var seen := {}
	var count := 0
	var pts: Array = []
	for k0: Vector2i in keys:
		if seen.has(k0):
			continue
		count += 1
		if pts.size() < 12:
			pts.append(entries[k0])
		var st: Array = [k0]
		seen[k0] = true
		while not st.is_empty():
			var k: Vector2i = st.pop_back()
			for dx in [-1, 0, 1]:
				for dz in [-1, 0, 1]:
					var kk := k + Vector2i(dx, dz)
					if entries.has(kk) and not seen.has(kk):
						seen[kk] = true
						st.append(kk)
	return {"count": count, "pts": pts}


## Gövde ve ağ denetimleri: havada duran, iç içe, gömülü kapı, ağsız cisim, görünmez çarpışma
func _body_checks(rect: Rect2) -> Dictionary:
	var inv := _f.global_transform.affine_inverse()
	var shapes: Array = []          # [aabb (dünya), body, bilinçli sınır mı]
	for b: Node in get_tree().root.find_children("*", "StaticBody3D", true, false):
		var sb := b as StaticBody3D
		if (sb.collision_layer & 1) == 0:
			continue
		var hidden := false
		for chn in sb.get_children():
			if chn is MeshInstance3D and not (chn as MeshInstance3D).visible:
				hidden = true
		for own in sb.get_shape_owners():
			var oxf := sb.global_transform * sb.shape_owner_get_transform(own)
			for si in sb.shape_owner_get_shape_count(own):
				var sh := sb.shape_owner_get_shape(own, si)
				var ab := AABB()
				if sh is BoxShape3D:
					var bs := (sh as BoxShape3D).size
					ab = AABB(-bs * 0.5, bs)
				elif sh is CylinderShape3D:
					var cy := sh as CylinderShape3D
					ab = AABB(Vector3(-cy.radius, -cy.height * 0.5, -cy.radius), Vector3(cy.radius * 2, cy.height, cy.radius * 2))
				elif sh is ConvexPolygonShape3D:
					var pts: PackedVector3Array = (sh as ConvexPolygonShape3D).points
					if pts.is_empty():
						continue
					ab = AABB(pts[0], Vector3.ZERO)
					for p in pts:
						ab = ab.expand(p)
				else:
					continue                  # içbükey (zemin, WorldWalk ağları) ayrı denetlenmez
				var wab := inv * oxf * ab
				var c := wab.get_center()
				if not rect.has_point(Vector2(c.x, c.z)):
					continue
				if wab.size.x > 60.0 or wab.size.z > 60.0:
					continue                  # zemin levhası, sur boyu
				shapes.append([wab, sb, hidden, oxf * ab])
	var floating := 0
	var fl_pts: Array = []
	var bounds := 0
	for s: Array in shapes:
		var wab: AABB = s[0]
		var sab: AABB = s[3]
		if s[2]:
			bounds += 1
			continue
		if wab.size.y < 0.15:
			continue
		var bottom := sab.position.y
		var any := false
		var c := sab.get_center()
		var hx := sab.size.x * 0.4
		var hz := sab.size.z * 0.4
		for o in [Vector2.ZERO, Vector2(hx, hz), Vector2(-hx, hz), Vector2(hx, -hz), Vector2(-hx, -hz)]:
			var from := Vector3(c.x + o.x, bottom + 0.02, c.z + o.y)
			var q := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 0.09, 1, [(s[1] as StaticBody3D).get_rid()])
			q.hit_from_inside = true
			if not _space.intersect_ray(q).is_empty():
				any = true
				break
			# Başka bir şeklin içinde (gövdenin kendi öbür şekli de olabilir: kat kat ev)
			var pq := PhysicsPointQueryParameters3D.new()
			pq.position = from + Vector3.DOWN * 0.05
			pq.collision_mask = 1
			if not _space.intersect_point(pq, 1).is_empty():
				any = true
				break
		if not any:
			floating += 1
			if fl_pts.size() < 8:
				fl_pts.append(Vector2(wab.get_center().x, wab.get_center().z))
	# İç içe: farklı gövdelerin kutuları (≥ 4 m³), örtüşme > küçüğün %30'u
	var nested := 0
	var nested_pts: Array = []
	var cell := {}
	for i in shapes.size():
		var ab: AABB = shapes[i][0]
		if ab.get_volume() < 4.0 or shapes[i][2]:
			continue
		var k := Vector2i(floori(ab.get_center().x / 16.0), floori(ab.get_center().z / 16.0))
		for dx in [-1, 0, 1]:
			for dz in [-1, 0, 1]:
				for jdx in cell.get(k + Vector2i(dx, dz), []):
					var j: int = jdx
					if shapes[j][1] == shapes[i][1]:
						continue
					var bb: AABB = shapes[j][0]
					var it := ab.intersection(bb)
					if it.get_volume() > 0.3 * minf(ab.get_volume(), bb.get_volume()):
						nested += 1
						if nested_pts.size() < 8:
							nested_pts.append(Vector2(it.get_center().x, it.get_center().z))
		if not cell.has(k):
			cell[k] = []
		cell[k].append(i)
	# Görünür ağlar (MeshInstance3D ve çoklu ağ örnekleri): dünya AABB'leri
	var vis: Array = []             # [aabb dünya, kapı adayı mı, sahne aabb]
	for m: Node in _f.get_parent().find_children("*", "GeometryInstance3D", true, false):
		var gi := m as GeometryInstance3D
		if not gi.is_visible_in_tree() or _person(gi):
			continue
		if gi is MeshInstance3D:
			var mi := gi as MeshInstance3D
			if mi.mesh == null or _see_through(mi.material_override if mi.material_override else (mi.mesh.surface_get_material(0) if mi.mesh.get_surface_count() > 0 else null)):
				continue
			var sab := mi.global_transform * mi.get_aabb()
			var wab := inv * sab
			var c := wab.get_center()
			if not rect.grow(4.0).has_point(Vector2(c.x, c.z)) or wab.size.x > 60.0 or wab.size.z > 60.0:
				continue
			var door := false
			if mi.mesh is BoxMesh:
				var bs := (mi.mesh as BoxMesh).size * mi.global_transform.basis.get_scale()
				var thin := minf(bs.x, bs.z)
				var wide := maxf(bs.x, bs.z)
				door = thin <= 0.12 and bs.y >= 1.6 and bs.y <= 2.4 and wide >= 0.7 and wide <= 1.5
			vis.append([wab, door, sab, mi.has_meta("no_walk"), mi])
		elif gi is MultiMeshInstance3D:
			var mmi := gi as MultiMeshInstance3D
			if mmi.multimesh == null or mmi.multimesh.mesh == null:
				continue
			var mab := mmi.multimesh.mesh.get_aabb()
			var xfs: Array = mmi.get_meta("xforms", [])
			var cnt := xfs.size() if not xfs.is_empty() else mmi.multimesh.instance_count
			for ii in cnt:
				var ixf := mmi.global_transform * (xfs[ii] as Transform3D if not xfs.is_empty() else mmi.multimesh.get_instance_transform(ii))
				var sab := ixf * mab
				var wab := inv * sab
				var c := wab.get_center()
				if not rect.grow(4.0).has_point(Vector2(c.x, c.z)):
					continue
				vis.append([wab, false, sab, true, mmi])
	# Ağsız cisim: katı görünen (her kenarı ≥ 0,8 m, hacmi ≥ 2 m³) ağın içinde çarpışma yok
	var mesh_nocol := 0
	var mnc_pts: Array = []
	var buried := 0
	var door_pts: Array = []
	var vcell := {}
	for vi in vis.size():
		var wab: AABB = vis[vi][0]
		var sab: AABB = vis[vi][2]
		var k := Vector2i(floori(wab.get_center().x / 16.0), floori(wab.get_center().z / 16.0))
		if not vcell.has(k):
			vcell[k] = []
		vcell[k].append(vi)
		var c := wab.get_center()
		if not rect.has_point(Vector2(c.x, c.z)):
			continue
		if vis[vi][1]:
			# Kapı: altının iki yanında zemin; zemin kapının alt kenarından 8 cm'den yüksekse gömülü
			var bot := sab.position.y
			var top := 0.0
			var cc := sab.get_center()
			for side: float in [-1.0, 1.0]:
				var dir := Vector3(1, 0, 0) if sab.size.x < sab.size.z else Vector3(0, 0, 1)
				var p := cc + dir * side * 0.35
				var hit := _ray(Vector3(p.x, bot + 0.6, p.z), Vector3(p.x, bot - 1.0, p.z))
				if not hit.is_empty():
					top = maxf(top, (hit["position"] as Vector3).y - bot)
			if top > 0.08:
				buried += 1
				if door_pts.size() < 8:
					door_pts.append(Vector2(c.x, c.z))
			continue
		if wab.size.x < 0.8 or wab.size.y < 0.8 or wab.size.z < 0.8 or wab.get_volume() < 2.0:
			continue
		var sc := sab.get_center()
		var has := _occupied(sc)
		if not has:
			var sq := PhysicsShapeQueryParameters3D.new()
			var bx := BoxShape3D.new()
			bx.size = sab.size * 0.9
			sq.shape = bx
			sq.transform = Transform3D(Basis.IDENTITY, sc)
			sq.collision_mask = 1
			for r: Dictionary in _space.intersect_shape(sq, 4):
				if r["collider"] is StaticBody3D:
					has = true
					break
		if not has:
			mesh_nocol += 1
			if mnc_pts.size() < 8:
				mnc_pts.append(Vector2(c.x, c.z))
	# Görünmez çarpışma: şeklin ≥ %30'unu kaplayan görünür ağ yok
	var col_nomesh := 0
	var cnm_pts: Array = []
	for s: Array in shapes:
		var ab: AABB = s[0]
		if s[2] or ab.get_volume() < 1.0:
			continue
		var k := Vector2i(floori(ab.get_center().x / 16.0), floori(ab.get_center().z / 16.0))
		var cover := 0.0
		for dx in [-1, 0, 1]:
			for dz in [-1, 0, 1]:
				for vi2 in vcell.get(k + Vector2i(dx, dz), []):
					var vab: AABB = vis[vi2][0]
					cover += ab.intersection(vab).get_volume()
		if cover < 0.3 * ab.get_volume():
			col_nomesh += 1
			if cnm_pts.size() < 8:
				cnm_pts.append(Vector2(ab.get_center().x, ab.get_center().z))
	return {"floating": floating, "floating_pts": fl_pts, "nested": nested, "nested_pts": nested_pts, "buried_door": buried,
		"door_pts": door_pts, "mesh_nocol": mesh_nocol, "mesh_nocol_pts": mnc_pts, "col_nomesh": col_nomesh,
		"col_nomesh_pts": cnm_pts, "bounds": bounds}


func _person(n: Node) -> bool:
	var cur := n
	while cur != null:
		if cur is Person or cur is CharacterBody3D:
			return true
		cur = cur.get_parent()
	return false


func _see_through(m: Material) -> bool:
	if m is ShaderMaterial:
		return true
	if m is BaseMaterial3D:
		var bm := m as BaseMaterial3D
		if bm.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and bm.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR:
			return true
		if bm.emission_enabled and bm.emission_energy_multiplier > 0.5:
			return true
	return false


## CityPlan sokakları: eksen üstünde 1 m'de bir, zeminden 1 m yukarıda katı var mı (bölümün keep alanı atlanır)
func _street_checks(rect: Rect2) -> Dictionary:
	var g := CityPlan.graph()
	var nodes: PackedVector3Array = g["nodes"]
	var edges: Array = g["edges"]
	var blocked := 0
	var samples := 0
	var ed := 0
	var pts: Array = []
	for e: Vector2i in edges:
		var a := nodes[e.x]
		var b := nodes[e.y]
		if not (rect.has_point(Vector2(a.x, a.z)) or rect.has_point(Vector2(b.x, b.z))):
			continue
		var len := Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
		var hit := false
		var t := 0.5
		while t < len:
			var p := a.lerp(b, t / len)
			t += 1.0
			if not rect.has_point(Vector2(p.x, p.z)):
				continue
			var skip := false
			for r: Rect2 in _f.keep:
				if r.has_point(Vector2(p.x, p.z)):
					skip = true
			if skip:
				continue
			samples += 1
			var s := _w2s(Vector3(p.x, 0, p.z))
			var gh := _ray(s + Vector3.UP * (p.y + 30.0), s + Vector3.DOWN * 20.0)
			var gy: float = (gh["position"] as Vector3).y if not gh.is_empty() else _w2s(p).y
			# zemin ışını bir çatıya çarptıysa (yol bir evin içinden geçiyor) zemin beklenen yükseklik
			if gy > _w2s(p).y + 2.0:
				gy = _w2s(p).y
			if _occupied(Vector3(s.x, gy + 1.0, s.z)):
				blocked += 1
				hit = true
				if pts.size() < 8:
					pts.append(Vector2(p.x, p.z))
		if hit:
			ed += 1
	return {"blocked": blocked, "samples": samples, "edges": ed, "pts": pts}
