extends RefCounted
## Yerleşim denetimi (v0.99.101). Test botuyla oynanırken LAYOUTAUDIT=1 ise Hud her replikte çağırır; oyuncu yeni
## bir yere geldiğinde (12 m ya da 8 sn) çevresini (40 m) tarar ve her bulguyu bir kez "LAYOUT tür ..." diye basar.
## Kullanıcının Büro'da bulduğu hata türleri oyunun geri kalanında da aranır:
##   FLOAT     hiçbir şeye değmeyen küçük parça kümesi (direkten 5 cm açıkta asılı palto, havada şapka)
##   TEXTOVER  arkasındaki tabeladan/karttan taşan yazı
##   DOORWALL  açık duran kapı kanadının yanındaki kapı boşluğu duvarla kapalı (kapı açık ama ardı duvar)
##   SITWALL   oturan kişinin yüzü 0,75 m içinde duvara dönük (duvara yapışık oturan memur)
##   MIDCOR    dar geçidin tam ortasında duran kişi (koridorun ortasındaki Başdenetçi)
##   SHADOWJAG gölgeli ışığın dibinde ince uzun gölge atan parça (ofis kirişlerinin testere dişi gölgesi)
##   SHADOWLIGHT / SUNSHADOW  gölgeli ışıkların dökümü
## LAYOUTSHOT=klasör verilirse (sanal ekranla, başsız değil) her bulgunun yakın planı PNG olarak kaydedilir.

const RADIUS := 40.0
const ANCHOR := 12.0      # bu boydan büyük parça zemin sayılır (arazi, deniz, döşeme)
const GROW := 0.02

static var _seen := {}
static var _last_t := -100.0
static var _last_pos := Vector3.INF
static var _busy := false
static var _shots := 0


static var _pending: Array = []


static func maybe_scan(tree: SceneTree) -> void:
	if _busy:
		return
	var sc := tree.current_scene
	if sc == null:
		return
	# Bekleyen "havada" bulguları: o zamandan beri yerinde duruyorsa gerçek
	var found: Array = []
	var keep: Array = []
	var now_ms := Time.get_ticks_msec()
	for pd in _pending:
		if not is_instance_valid(pd[0]):
			continue      # silinmiş (düşen taş, sönen ateş)
		var m: MeshInstance3D = pd[0]
		if not m.is_inside_tree() or not m.is_visible_in_tree():
			continue
		if m.global_position.distance_to(pd[1]) > 0.02:
			continue
		if pd.size() < 8:
			pd.append(now_ms)
			keep.append(pd)
			continue
		if now_ms - int(pd[7]) < 1500:
			keep.append(pd)
			continue
		_emit(pd[2], pd[3], pd[4], pd[5], pd[6], found)
	_pending = keep
	var pl = sc.get("player")
	if not (pl is Node3D) or not (pl as Node3D).is_inside_tree():
		return
	var pp := (pl as Node3D).global_position
	var now := Time.get_ticks_msec() / 1000.0
	if not (now - _last_t < 8.0 and _last_pos != Vector3.INF and pp.distance_to(_last_pos) < 12.0):
		_last_t = now
		_last_pos = pp
		_busy = true
		found.append_array(scan(sc, pl as Node3D))
		_busy = false
	var dir := OS.get_environment("LAYOUTSHOT")
	if dir != "" and DisplayServer.get_name() != "headless" and found.size() > 0:
		_shot_q.append_array(found)
		if not _shooting:
			_shoot(tree, sc, pl as Node3D, dir)


static func _emit(kind: String, scene: String, key: String, line: String, at: Vector3, found: Array) -> void:
	var k := kind + "|" + scene + "|" + key
	if _seen.has(k):
		return
	_seen[k] = true
	var shot := "%s_%s_%d" % [scene.get_basename(), kind, _seen.size()]
	print("LAYOUT %s scene=%s %s shot=%s" % [kind, scene, line, shot])
	found.append([kind, at, shot])


static func _path(n: Node, sc: Node) -> String:
	var parts: Array = []
	var q := n
	var d := 0
	while q != null and q != sc and d < 4:
		parts.push_front(String(q.name))
		q = q.get_parent()
		d += 1
	return "/".join(parts)


## Kişi gibi davranan, kendi gövdesini kuran düğümler (asker, düellocu, sur muhafızı, savaş figüranı, duman):
## parçaları zemine değmeden durabilir (yürürken bacak havada), "havada eşya" sayılmaz
const ACTOR_GROUPS := ["soldiers", "sight_dodgers", "garrison", "battle_extras", "scenery_smoke", "persons"]
static func _is_actor(n: Node) -> bool:
	for g in ACTOR_GROUPS:
		if n.is_in_group(g):
			return true
	return false


## Sahnedeki görünür MeshInstance3D'ler (kişiler, oyuncu, ayrı dünyalar hariç), oyuncunun RADIUS çevresinde
static func _meshes(sc: Node, pl: Node3D) -> Array:
	var out: Array = []
	var pp := pl.global_position
	var st: Array = [sc]
	while st.size() > 0:
		var n: Node = st.pop_back()
		if n == pl or n is Person or n is SubViewport or n is CanvasLayer or _is_actor(n):
			continue
		if n is Node3D and not (n as Node3D).visible:
			continue
		st.append_array(n.get_children())
		if n is MeshInstance3D and (n as MeshInstance3D).mesh:
			var mi := n as MeshInstance3D
			var ab: AABB = mi.global_transform * mi.get_aabb()
			var c := ab.get_center()
			if Vector2(c.x - pp.x, c.z - pp.z).length() - ab.size.length() * 0.5 > RADIUS:
				continue
			out.append([mi, ab])
	return out


static func scan(sc: Node, pl: Node3D) -> Array:
	var found: Array = []
	var scene := sc.scene_file_path.get_file()
	var ms := _meshes(sc, pl)
	_float(sc, pl, scene, ms, found)
	_text(sc, pl, scene, ms, found)
	_doors(sc, scene, ms, found)
	_people(sc, pl, scene, ms, found)
	_shadows(sc, pl, scene, ms, found)
	return found


# ---------------------------------------------------------------- FLOAT

static func _float(sc: Node, pl: Node3D, scene: String, ms: Array, found: Array) -> void:
	var items: Array = []      # [aabb, mi]
	var anchors: Array = []
	for e in ms:
		var mi: MeshInstance3D = e[0]
		var ab: AABB = e[1]
		if mi.mesh is QuadMesh or mi.mesh is PlaneMesh:
			continue      # ışık lekesi, çıkartma: yüzeye yapışık, fiziksel değil
		if ab.size.x > ANCHOR or ab.size.y > ANCHOR or ab.size.z > ANCHOR:
			anchors.append(ab.grow(GROW))
		else:
			items.append([ab.grow(GROW), mi])
	# Kişiler ve askerler de tutar (elindeki eşya, omzundaki çuval): gövde kutusu
	for g in ["persons", "soldiers", "sight_dodgers"]:
		for p in sc.get_tree().get_nodes_in_group(g):
			var pn := p as Node3D
			if pn and pn.is_visible_in_tree():
				anchors.append(AABB(pn.global_position + Vector3(-0.4, -0.05, -0.4), Vector3(0.8, 2.0, 0.8)))
	var n := items.size()
	var parent: Array = []      # Array: başvuruyla geçer (PackedInt32Array kopyalanıyordu, birleştirme kayboluyordu)
	parent.resize(n)
	for i in n:
		parent[i] = i
	# 1 m ızgara
	var grid := {}
	for i in n:
		var ab: AABB = items[i][0]
		var lo := Vector3i(floori(ab.position.x), floori(ab.position.y), floori(ab.position.z))
		var hi := Vector3i(floori(ab.end.x), floori(ab.end.y), floori(ab.end.z))
		if (hi.x - lo.x + 1) * (hi.y - lo.y + 1) * (hi.z - lo.z + 1) > 400:
			continue      # çok büyük (uzun duvar): komşuluğu ayrıca yoklanır
		for x in range(lo.x, hi.x + 1):
			for y in range(lo.y, hi.y + 1):
				for z in range(lo.z, hi.z + 1):
					var k := Vector3i(x, y, z)
					if not grid.has(k):
						grid[k] = []
					(grid[k] as Array).append(i)
	var big: Array = []
	for i in n:
		var ab: AABB = items[i][0]
		var lo := Vector3i(floori(ab.position.x), floori(ab.position.y), floori(ab.position.z))
		var hi := Vector3i(floori(ab.end.x), floori(ab.end.y), floori(ab.end.z))
		if (hi.x - lo.x + 1) * (hi.y - lo.y + 1) * (hi.z - lo.z + 1) > 400:
			big.append(i)
	for k in grid:
		var arr: Array = grid[k]
		for a in arr.size():
			var ia: int = arr[a]
			var aa: AABB = items[ia][0]
			for b in range(a + 1, arr.size()):
				var ib: int = arr[b]
				if _find(parent, ia) == _find(parent, ib):
					continue
				if aa.intersects(items[ib][0]):
					_union(parent, ia, ib)
	for ib in big:
		var bb: AABB = items[ib][0]
		for i in n:
			if i != ib and _find(parent, i) != _find(parent, ib) and bb.intersects(items[i][0]):
				_union(parent, i, ib)
	var comps := {}
	for i in n:
		var r := _find(parent, i)
		if not comps.has(r):
			comps[r] = []
		(comps[r] as Array).append(i)
	var space := pl.get_world_3d().direct_space_state
	for r in comps:
		var idx: Array = comps[r]
		var u: AABB = items[idx[0]][0]
		for i in idx:
			u = u.merge(items[i][0])
		if u.size.x > 4.0 or u.size.y > 4.0 or u.size.z > 4.0:
			continue
		var touch := false
		for an in anchors:
			if (an as AABB).intersects(u):
				# kümenin parçalarından biri gerçekten değiyor mu
				for i in idx:
					if (an as AABB).intersects(items[i][0]):
						touch = true
						break
			if touch:
				break
		if touch:
			continue
		# Işık/parıltı/buhar: bütün parçaları ışıyan ya da saydamsa bilerek havada (Glint, kıvılcım, buhar topu)
		var effect := true
		for i in idx:
			var mm: MeshInstance3D = items[i][1]
			var mat = mm.material_override
			if mat == null and mm.mesh.get_surface_count() > 0:
				mat = mm.mesh.surface_get_material(0)
			if mat is ShaderMaterial:
				effect = true      # ateş, su, parıltı gölgelendiricisi: efekt
				break
			if not (mat is BaseMaterial3D and ((mat as BaseMaterial3D).emission_enabled or (mat as BaseMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED)):
				effect = false
				break
		if effect:
			continue
		var real := u.grow(-GROW)
		var c := real.get_center()
		var q := PhysicsRayQueryParameters3D.create(Vector3(c.x, real.position.y - 0.005, c.z), Vector3(c.x, real.position.y - 60.0, c.z))
		q.exclude = [(pl as CollisionObject3D).get_rid()] if pl is CollisionObject3D else []
		var h := space.intersect_ray(q)
		if h.is_empty():
			continue      # altı boşluk (deniz, gök): denetlenmez
		var gap: float = real.position.y - (h["position"] as Vector3).y
		if gap < 0.06 or gap > 12.0:
			continue      # yerde duruyor ya da gökte (kuş, bulut, güneş): bilerek havada
		var mi0: MeshInstance3D = items[idx[0]][1]
		# Hareket eden (uçan ok, düşen taş, kuş) bir sonraki replikte yeri değişmişse sayılmaz: önce beklemeye alınır
		_pending.append([mi0, mi0.global_position, "FLOAT", scene, "%s" % c.snapped(Vector3.ONE * 0.5), "at=%s size=%s gap=%.2f parts=%d src=%s" % [c.snapped(Vector3.ONE * 0.01),
			real.size.snapped(Vector3.ONE * 0.01), gap, idx.size(), _path(mi0, sc)], c])
		continue
		_emit("FLOAT", scene, "%s" % c.snapped(Vector3.ONE * 0.5), "at=%s size=%s gap=%.2f parts=%d src=%s" % [c.snapped(Vector3.ONE * 0.01),
			real.size.snapped(Vector3.ONE * 0.01), gap, idx.size(), _path(mi0, sc)], c, found)


static func _find(p: Array, i: int) -> int:
	while p[i] != i:
		p[i] = p[p[i]]
		i = p[i]
	return i


static func _union(p: Array, a: int, b: int) -> void:
	var ra := _find(p, a)
	var rb := _find(p, b)
	if ra != rb:
		p[ra] = rb


# ---------------------------------------------------------------- TEXTOVER

## Kutunun 8 köşesi (dönük kutu için gerçek sınır)
static func _corners(mi: MeshInstance3D) -> Array:
	var ab := mi.get_aabb()
	var out: Array = []
	for i in 8:
		var v := Vector3(ab.end.x if i & 1 else ab.position.x, ab.end.y if i & 2 else ab.position.y, ab.end.z if i & 4 else ab.position.z)
		out.append(mi.global_transform * v)
	return out


static func _in_obb(mi: MeshInstance3D, p: Vector3, pad := 0.0) -> bool:
	var lp := mi.global_transform.affine_inverse() * p
	var ab := mi.get_aabb().grow(pad)
	return ab.has_point(lp)


static func _text(sc: Node, pl: Node3D, scene: String, ms: Array, found: Array) -> void:
	var pp := pl.global_position
	var boxes: Array = []
	for e in ms:
		if (e[0] as MeshInstance3D).mesh is BoxMesh:
			boxes.append(e)
	for l in sc.find_children("*", "Label3D", true, false):
		var lb := l as Label3D
		if not lb.is_visible_in_tree() or lb.billboard != BaseMaterial3D.BILLBOARD_DISABLED or lb.text.strip_edges() == "":
			continue
		var anc := lb.get_parent()
		var in_person := false
		while anc != null and anc != sc:
			if anc is Person or anc is SubViewport:
				in_person = anc is SubViewport
				break
			anc = anc.get_parent()
		if in_person:
			continue
		var lp := lb.global_position
		if Vector2(lp.x - pp.x, lp.z - pp.z).length() > RADIUS:
			continue
		var font := lb.font if lb.font else ThemeDB.fallback_font
		var wpx := lb.width if lb.autowrap_mode != TextServer.AUTOWRAP_OFF else -1.0
		var sz := font.get_multiline_string_size(lb.text, lb.horizontal_alignment, wpx, lb.font_size)
		var bs := lb.global_basis
		var r := bs.x
		var u := bs.y
		var nrm := bs.z.normalized()
		var w := sz.x * lb.pixel_size * r.length()
		var hh := sz.y * lb.pixel_size * u.length()
		r = r.normalized()
		u = u.normalized()
		var x0 := -w * 0.5
		if lb.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT:
			x0 = 0.0
		elif lb.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			x0 = -w
		var y0 := -hh * 0.5
		x0 += lb.offset.x * lb.pixel_size
		y0 += lb.offset.y * lb.pixel_size
		# Yazının ardındaki levha: yazı düzleminin 1-5 cm gerisinde, yazının ortasını taşıyan en küçük kutu
		var board: MeshInstance3D = null
		var best := INF
		for e in boxes:
			var mi: MeshInstance3D = e[0]
			var ab: AABB = e[1]
			if not ab.grow(0.06).has_point(lp):
				continue
			for d: float in [0.008, 0.02, 0.045]:
				if _in_obb(mi, lp - nrm * d, 0.002):
					var vol := ab.size.x * ab.size.y * ab.size.z
					if vol < best:
						best = vol
						board = mi
					break
		if board == null:
			continue
		var bx0 := INF
		var bx1 := -INF
		var by0 := INF
		var by1 := -INF
		for cpt in _corners(board):
			var dv: Vector3 = cpt - lp
			bx0 = minf(bx0, dv.dot(r))
			bx1 = maxf(bx1, dv.dot(r))
			by0 = minf(by0, dv.dot(u))
			by1 = maxf(by1, dv.dot(u))
		if bx1 - bx0 > 8.0 or by1 - by0 > 8.0:
			continue      # ardı duvar: yazı duvara boyalı, taşma yok
		if bx1 - bx0 < w * 0.4 or by1 - by0 < hh * 0.4:
			continue      # ardındaki ince çizgi/çubuk (şemadaki bağlantı çizgisi) yazının levhası değil
		# Yazının ortasındaki boşluk (sağ/sol kenar boşluğu yazı tipinde) 1 cm hoşgörü
		var ox := maxf(bx0 - x0, (x0 + w) - bx1)
		var oy := maxf(by0 - y0, (y0 + hh) - by1)
		# Dikeyde satır yüksekliği yazının görünen boyundan büyüktür: yarısı kadar hoşgörü
		if ox > 0.01 or oy > hh * 0.3 + 0.01:
			_emit("TEXTOVER", scene, "%s|%s" % [lb.text, lp.snapped(Vector3.ONE * 0.1)], "text=\"%s\" over_x=%.3f over_y=%.3f text_w=%.2f board_w=%.2f at=%s src=%s" % [
				lb.text.replace("\n", "/"), ox, oy, w, bx1 - bx0, lp.snapped(Vector3.ONE * 0.01), _path(lb, sc)], lp, found)


# ---------------------------------------------------------------- DOORWALL

static func _doors(sc: Node, scene: String, ms: Array, found: Array) -> void:
	var tall: Array = []
	var leaves: Array = []
	for e in ms:
		var mi: MeshInstance3D = e[0]
		var ab: AABB = e[1]
		if not (mi.mesh is BoxMesh):
			continue
		var s: Vector3 = (mi.mesh as BoxMesh).size * mi.global_basis.get_scale()
		var bs := mi.global_basis.orthonormalized()
		# dikey ekseni hangisi
		var vi := -1
		for k in 3:
			if absf(bs[k].y) > 0.97:
				vi = k
		if vi < 0:
			continue
		var h := s[vi]
		var o := [s[(vi + 1) % 3], s[(vi + 2) % 3]]
		var thin := minf(o[0], o[1])
		var wide := maxf(o[0], o[1])
		if h >= 2.0 and wide >= 1.2:
			tall.append(e)
		if h >= 1.75 and h <= 2.7 and wide >= 0.55 and wide <= 1.5 and thin >= 0.02 and thin <= 0.14:
			leaves.append([mi, ab, bs, vi, s])
	for lf in leaves:
		var mi: MeshInstance3D = lf[0]
		var bs: Basis = lf[2]
		var vi: int = lf[3]
		var s: Vector3 = lf[4]
		var ti := (vi + 1) % 3 if s[(vi + 1) % 3] < s[(vi + 2) % 3] else (vi + 2) % 3
		var wi := 3 - vi - ti
		var leaf_n := Vector3(bs[ti].x, 0, bs[ti].z).normalized()
		var leaf_w := Vector3(bs[wi].x, 0, bs[wi].z).normalized()
		var c := mi.global_position
		# Menteşe: kanadın iki dikey kenarından bir duvara (uzun, yüksek kutu) en yakın olanı
		var best_wall: MeshInstance3D = null
		var best_d := 0.6
		var hinge := Vector3.ZERO
		for sgn: float in [-1.0, 1.0]:
			var edge: Vector3 = c + leaf_w * (s[wi] * 0.5) * sgn
			for e in tall:
				var wm: MeshInstance3D = e[0]
				var wab: AABB = e[1]
				if wm == mi:
					continue
				var probe := Vector3(edge.x, clampf(c.y, wab.position.y, wab.end.y), edge.z)
				if not wab.grow(0.6).has_point(probe):
					continue
				var lp := wm.global_transform.affine_inverse() * probe
				var lab := wm.get_aabb()
				var cl := Vector3(clampf(lp.x, lab.position.x, lab.end.x), clampf(lp.y, lab.position.y, lab.end.y), clampf(lp.z, lab.position.z, lab.end.z))
				var dist := (wm.global_transform * cl).distance_to(probe)
				if dist < best_d:
					best_d = dist
					best_wall = wm
					hinge = edge
		if best_wall == null:
			continue
		# Duvarın normali: yatay eksenlerinden en incesi
		var wb := best_wall.global_basis.orthonormalized()
		var ws: Vector3 = best_wall.get_aabb().size * best_wall.global_basis.get_scale()
		var wt := -1
		for k in 3:
			if absf(wb[k].y) < 0.5 and (wt < 0 or ws[k] < ws[wt]):
				wt = k
		if wt < 0:
			continue
		var wall_n := Vector3(wb[wt].x, 0, wb[wt].z).normalized()
		var ang := rad_to_deg(acos(clampf(absf(leaf_n.dot(wall_n)), 0.0, 1.0)))
		if ang < 12.0 or ang > 78.0:
			continue      # kapalı (duvara yaslı) ya da tam açık: boşluğun yönü belirsiz
		# Kapı boşluğu: menteşeden duvar boyunca kanadın durduğu yana, kanat genişliğinin yarısı
		var t := wall_n.cross(Vector3.UP).normalized()
		var side := signf((c - hinge).dot(t))
		var mid := hinge + t * side * (s[wi] * 0.5)
		var wc := best_wall.global_position
		mid -= wall_n * (mid - wc).dot(wall_n)
		mid.y = c.y
		var blocked: MeshInstance3D = null
		for e in tall:
			var wm: MeshInstance3D = e[0]
			if wm == mi or not (e[1] as AABB).grow(0.1).has_point(mid):
				continue
			if _in_obb(wm, mid, 0.0):
				blocked = wm
				break
		if blocked:
			_emit("DOORWALL", scene, "%s" % c.snapped(Vector3.ONE * 0.2), "at=%s angle=%.0f doorway=%s leaf=%s wall=%s" % [c.snapped(Vector3.ONE * 0.01), ang,
				mid.snapped(Vector3.ONE * 0.01), _path(mi, sc), _path(blocked, sc)], mid, found)


# ---------------------------------------------------------------- SITWALL / MIDCOR

static func _people(sc: Node, pl: Node3D, scene: String, ms: Array, found: Array) -> void:
	var space := pl.get_world_3d().direct_space_state
	var pp := pl.global_position
	var tallm: Array = []
	for e in ms:
		var ab: AABB = e[1]
		# yalnız kutu: arazi, çadır, ağaç gibi düzensiz parçaların sınır kutusu havayı da kapsar
		if ab.size.y >= 1.5 and (e[0] as MeshInstance3D).mesh is BoxMesh:
			tallm.append(e)
	for p in sc.get_tree().get_nodes_in_group("persons"):
		var pn := p as Person
		if pn == null or not pn.is_visible_in_tree() or pn == pl:
			continue
		var g := pn.global_position
		if Vector2(g.x - pp.x, g.z - pp.z).length() > RADIUS:
			continue
		var fwd := Vector3(pn.global_basis.z.x, 0, pn.global_basis.z.z).normalized()
		var right := fwd.cross(Vector3.UP).normalized()
		var act := String(pn.get("activity")) if pn.get("activity") != null else ""
		var who := String(pn.get_meta("spk", pn.name))
		if act.begins_with("sit") or act in ["write", "whittle", "read_ground"]:
			# yüzüne bakan yükseklikte (oturan baş ~1,2 m) önünde duvar
			var hit_d := INF
			var hy := g.y + (0.7 if act == "sit_ground" else 1.15)
			for d: float in [0.3, 0.45, 0.6, 0.75]:
				var pt := Vector3(g.x, hy, g.z) + fwd * d
				for e in tallm:
					if (e[1] as AABB).has_point(pt) and (e[1] as AABB).end.y > g.y + 1.7 and _in_obb(e[0], pt):
						hit_d = minf(hit_d, d)
						break
				if hit_d < INF:
					break
			var q := PhysicsRayQueryParameters3D.create(Vector3(g.x, hy, g.z) + fwd * 0.2, Vector3(g.x, hy, g.z) + fwd * 0.75)
			var h := space.intersect_ray(q)
			# yalnız dik ve başın üstüne uzanan yüzey (duvar); kazan, ateş taşı, masa, eğimli arazi sayılmaz
			if not h.is_empty() and not _is_person(h["collider"]) and absf((h["normal"] as Vector3).y) < 0.4:
				var q2 := PhysicsRayQueryParameters3D.create(Vector3(g.x, g.y + 1.7, g.z) + fwd * 0.2, Vector3(g.x, g.y + 1.7, g.z) + fwd * 0.9)
				var h2 := space.intersect_ray(q2)
				if not h2.is_empty() and not _is_person(h2["collider"]):
					hit_d = minf(hit_d, (h["position"] as Vector3).distance_to(Vector3(g.x, hy, g.z)))
			if hit_d < INF:
				_emit("SITWALL", scene, _path(pn, sc), "who=%s at=%s act=%s wall_d=%.2f" % [who, g.snapped(Vector3.ONE * 0.01), act, hit_d],
					g + Vector3(0, 1.0, 0), found)
			continue
		if pn.has_meta("walker") or pn.get("walking") == true:
			continue
		var dl := _ray_len(space, g + Vector3(0, 1.0, 0), -right, 2.6)
		var dr := _ray_len(space, g + Vector3(0, 1.0, 0), right, 2.6)
		if dl >= 2.6 or dr >= 2.6:
			continue
		var df := _ray_len(space, g + Vector3(0, 1.0, 0), fwd, 3.0)
		var db := _ray_len(space, g + Vector3(0, 1.0, 0), -fwd, 3.0)
		# Kişinin yanlarından da yoklanır: koridor kişinin baktığı yöne dik de olabilir
		var dl2 := _ray_len(space, g + Vector3(0, 1.0, 0), fwd, 2.6)
		var dr2 := _ray_len(space, g + Vector3(0, 1.0, 0), -fwd, 2.6)
		var ok := false
		var w := dl + dr
		if w < 3.6 and absf(dl - dr) < 0.5 and df >= 3.0 and db >= 3.0:
			ok = true
		elif dl2 < 2.6 and dr2 < 2.6 and dl2 + dr2 < 3.6 and absf(dl2 - dr2) < 0.5 and _ray_len(space, g + Vector3(0, 1.0, 0), right, 3.0) >= 3.0 \
				and _ray_len(space, g + Vector3(0, 1.0, 0), -right, 3.0) >= 3.0:
			ok = true
			w = dl2 + dr2
		if ok:
			_emit("MIDCOR", scene, _path(pn, sc), "who=%s at=%s width=%.2f" % [who, g.snapped(Vector3.ONE * 0.01), w], g + Vector3(0, 1.0, 0), found)


static func _is_person(o) -> bool:
	var q = o
	while q != null and q is Node:
		if q is Person:
			return true
		q = (q as Node).get_parent()
	return false


static func _ray_len(space: PhysicsDirectSpaceState3D, from: Vector3, dir: Vector3, mx: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(from, from + dir * mx)
	var h := space.intersect_ray(q)
	if h.is_empty() or _is_person(h["collider"]):
		return mx
	return from.distance_to(h["position"])


# ---------------------------------------------------------------- SHADOWS

static func _shadows(sc: Node, pl: Node3D, scene: String, ms: Array, found: Array) -> void:
	for l in sc.find_children("*", "Light3D", true, false):
		var lt := l as Light3D
		if not lt.is_visible_in_tree() or not lt.shadow_enabled:
			continue
		var lp := lt.global_position
		if lt is DirectionalLight3D:
			var dl := lt as DirectionalLight3D
			_emit("SUNSHADOW", scene, _path(lt, sc), "mode=%d max_dist=%.0f blur=%.2f bias=%.2f nbias=%.2f src=%s" % [dl.directional_shadow_mode,
				dl.directional_shadow_max_distance, dl.shadow_blur, dl.shadow_bias, dl.shadow_normal_bias, _path(lt, sc)], pl.global_position, [])
			continue
		var rng: float = lt.get("omni_range") if lt is OmniLight3D else lt.get("spot_range")
		if Vector2(lp.x - pl.global_position.x, lp.z - pl.global_position.z).length() > RADIUS:
			continue
		_emit("SHADOWLIGHT", scene, _path(lt, sc), "type=%s at=%s range=%.1f blur=%.2f nbias=%.2f src=%s" % [lt.get_class(), lp.snapped(Vector3.ONE * 0.01), rng,
			lt.shadow_blur, lt.shadow_normal_bias, _path(lt, sc)], lp, [])
		for e in ms:
			var mi: MeshInstance3D = e[0]
			var ab: AABB = e[1]
			if mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
				continue
			# Kiriş/çubuk biçimi: iki boyutu ince, biri uzun (pano, tavan levhası değil)
			var ds := [ab.size.x, ab.size.y, ab.size.z]
			ds.sort()
			if float(ds[1]) > 0.3 or float(ds[2]) < 0.8 or float(ds[2]) > 8.0:
				continue
			var cp := Vector3(clampf(lp.x, ab.position.x, ab.end.x), clampf(lp.y, ab.position.y, ab.end.y), clampf(lp.z, ab.position.z, ab.end.z))
			var d := cp.distance_to(lp)
			if d > 1.6 or d < 0.05:
				continue
			_emit("SHADOWJAG", scene, _path(mi, sc), "light=%s caster=%s size=%s dist=%.2f src=%s" % [lp.snapped(Vector3.ONE * 0.01),
				ab.get_center().snapped(Vector3.ONE * 0.01), ab.size.snapped(Vector3.ONE * 0.01), d, _path(mi, sc)], ab.get_center(), found)


# ---------------------------------------------------------------- yakın plan

static var _shot_q: Array = []
static var _shooting := false


static func _shoot(tree: SceneTree, sc: Node, pl: Node3D, dir: String) -> void:
	_shooting = true
	DirAccess.make_dir_recursive_absolute(dir)
	var vp := sc.get_viewport()
	var prev := vp.get_camera_3d()
	var cam := Camera3D.new()
	cam.fov = 60.0
	sc.add_child(cam)
	while _shot_q.size() > 0 and is_instance_valid(sc) and is_instance_valid(pl) and pl.is_inside_tree():
		var f: Array = _shot_q.pop_front()
		if _shots > 400:
			break
		var at: Vector3 = f[1]
		var from: Vector3 = pl.global_position + Vector3(0, 1.6, 0)
		var off := Vector3(from.x - at.x, 0, from.z - at.z)
		if off.length() < 0.5:
			off = Vector3(1, 0, 0)
		var dist := 2.2 if String(f[0]) in ["FLOAT", "TEXTOVER", "SITWALL", "SHADOWJAG"] else 3.5
		cam.global_position = at + off.normalized() * dist + Vector3(0, 0.35, 0)
		cam.look_at(at, Vector3.UP)
		cam.current = true
		await tree.process_frame
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		vp.get_texture().get_image().save_png(dir.path_join(String(f[2]) + ".png"))
		_shots += 1
	if is_instance_valid(cam):
		cam.current = false
		cam.queue_free()
	if is_instance_valid(prev):
		prev.current = true
	_shot_q.clear()
	_shooting = false
