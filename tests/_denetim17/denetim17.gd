extends Node
## G17 denetimleri ("HAVADA DURAN HİÇBİR ŞEY OLMAZ"; yalnız otomatik testte: hud yükler, tests/ dışa aktarılmaz).
##   1. Hayvan (VISAUDIT float/sunk who=<sınıf>): "hayvanlar" grubundaki canlıların (CanliKit.dugum kökleri, hipodromun
##      ağları) en alçak ayak noktası ile altındaki görünen katı zemin farkı; aralıksız ≥ 1 sn > 0,15 m (havada) ya da
##      < −0,10 m (gömük). Pişmiş hayvanlar (CK.bld_ekle → "pismis_hayvan" grubu) bir kez, kurulumdan sonra.
##   2. GORUNMEZZEMIN: oyuncu zemindeyken her 0,5 sn ayağının altındaki çarpışma noktasının ±0,35 m'sinde görünen
##      bir ağ yüzeyi var mı (görünen ağlar ayrı bir fizik uzayına üçgen olarak kopyalanır, tests/phys_audit.gd yöntemi).
##   3. ALETAUDIT: Stage.station işçisinin aletinin ucu işin noktasında mı ("is_noktasi"/"is_yaricap" metası).
##   4. DONUKAUDIT (yalnız PACE): oyuncu donuk, meşru sebep yok, konumu ve kamerası kıpırdamıyor, > 4 sn (gerçek zaman).
## Satırlar önce "_ADAY" ekiyle basılır (paketi düşürmez); bir türün sayımı 0 olunca KESIN'de true yapılır.

const KESIN := {"hayvan": false, "zemin": true, "alet": true, "donuk": true}

var hud: Node
var _scene: Node
var _t0 := 0
var _next := 0                 # bir sonraki 0,5 sn'lik örnek (gerçek zaman, ms)
var _next_donuk := 0

# ---- hayvan
var _hy_since := {}            # id -> [tür, başlangıç ms]
var _hy_seen := {}             # id -> true (bildirildi)
var _bot_cache := {}           # Mesh -> PackedVector3Array (ağın yerelinde en alçak noktalar)
var _pismis_done := {}

# ---- görünmez zemin
var _geoms: Array = []          # sahnedeki GeometryInstance3D'ler (ağırlık: node_added ile güncel)
var _vspace: RID
var _vstate: PhysicsDirectSpaceState3D
var _vbuilt := {}              # "id" ya da "id#i" -> [body RID, shape RID, Transform3D]
var _gz_seen := {}
var _gz_n := 0
var _co_last := {}         # çarpan gövde -> son örnekteki yeri

# ---- alet
var _al_min := {}              # istasyon id -> [pencere başı ms, en küçük uzaklık, en büyük]
var _al_out := {}              # stir: id -> ilk dışarıda ms
var _al_seen := {}
var _al_baked_done := {}
var _al_dbg := {}

# ---- donuk
var _dn_start := -1
var _dn_pos := Vector3.INF
var _dn_cam := Basis()
var _dn_seen := 0
var _mini: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_t0 = Time.get_ticks_msec()
	_scene = get_tree().current_scene
	get_tree().node_added.connect(_on_added)
	if _scene:
		for n in _scene.find_children("*", "GeometryInstance3D", true, false):
			_geoms.append(weakref(n))


func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_on_added):
		get_tree().node_added.disconnect(_on_added)
	_free_vis()


func _on_added(n: Node) -> void:
	if n is GeometryInstance3D:
		_geoms.append(weakref(n))
	elif n.get_script() != null and str((n.get_script() as Script).get_global_name()) in ["Drill", "CannonCrew", "Duel", "GunDrill", "Arena"]:
		_mini.append(weakref(n))


func _say(kind: String, line: String) -> void:
	var parts := line.split(" ", false, 1)
	print(parts[0] + ("" if KESIN.get(kind, false) else "_ADAY") + (" " + parts[1] if parts.size() > 1 else ""))


func _sc_name() -> String:
	return _scene.scene_file_path.get_file() if _scene else "?"


func _g(v: Vector3) -> String:
	return "(%.1f,%.1f,%.1f)" % [v.x, v.y, v.z]


func _process(_d: float) -> void:
	if _scene == null or not is_instance_valid(_scene) or _scene != get_tree().current_scene:
		return
	var now := Time.get_ticks_msec()
	if GameState.pace and now >= _next_donuk:
		_next_donuk = now + 100
		_donuk(now)
	if now < _next:
		return
	_next = now + 500
	if get_tree().paused:
		return
	var pl = _scene.get("player")
	if not (pl is Player) or not (pl as Node3D).is_inside_tree():
		return
	var fade: ColorRect = hud.get("_fade")
	if fade and fade.color.a > 0.95:
		return
	var eyes: Array[Vector3] = [(pl as Node3D).global_position]
	var cam := get_viewport().get_camera_3d()
	if cam and cam.global_position.distance_to((pl as Node3D).global_position) > 3.0:
		eyes.append(cam.global_position)
	_hayvan(pl, eyes, now)
	_pismis(now)
	_zemin(pl, now)
	_alet(eyes, now)


func _near(p: Vector3, eyes: Array[Vector3], r: float) -> bool:
	for e in eyes:
		if p.distance_to(e) <= r:
			return true
	return false


# ================================================================ 1. hayvanlar

## Hayvanın sahne betiğindeki düğümü (Goat, Horse...; sınıfsızda canlı kökünün atası) ve sınıf adı
func _owner_of(a: Node) -> Node:
	var q: Node = a
	var best: Node = a.get_parent() if a.get_parent() and a.get_parent().name != "AyakEgim" else a.get_parent().get_parent()
	while q != null and q != _scene:
		if q.get_script() != null and str((q.get_script() as Script).get_global_name()) in ["Goat", "Chicken", "Cat", "Horse", "Ox", "ThiefGull", "Gulls"]:
			return q
		q = q.get_parent()
	return best if best else a


func _cls(n: Node) -> String:
	if n.get_script() != null and str((n.get_script() as Script).get_global_name()) != "":
		return str((n.get_script() as Script).get_global_name())
	return str(n.name)


## Gövdenin dünyadaki en alçak noktası (ayak uçları): her ağın yerelindeki en alçak köşeler bir kez, sonra dönüştürülür
func _lowest(a: Node3D) -> Vector3:
	var best := Vector3.INF
	var meshes: Array = [a] if a is MeshInstance3D else a.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		var mi := m as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree():
			continue
		var pts: PackedVector3Array = _bot_cache.get(mi.mesh, PackedVector3Array())
		if pts.is_empty():
			var f := mi.mesh.get_faces()
			if f.is_empty():
				continue
			var ab := mi.mesh.get_aabb()
			var lim := ab.position.y + ab.size.y * 0.25
			for v in f:
				if v.y <= lim:
					pts.append(v)
			# en çok 64 nokta (seyrek örnek: uçların hepsi kalır, gövde alt yüzü seyrekleşir)
			if pts.size() > 64:
				var s := PackedVector3Array()
				var step := pts.size() / 64.0
				for i in 64:
					s.append(pts[int(i * step)])
				pts = s
			_bot_cache[mi.mesh] = pts
		var xf := mi.global_transform
		for v in pts:
			var w := xf * v
			if w.y < best.y:
				best = w
	return best


## p'nin altındaki görünen katı zemin (Unclip.floor_y gibi; hayvanın kendi gövdesi sayılmaz). Döner [y, çarpan] ya da [NAN].
func _floor_under(own: Node, p: Vector3, up: float, down: float) -> Array:
	var space := (own as Node3D).get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, up, 0), p + Vector3(0, -down, 0), 1)
	for i in 8:
		var h := space.intersect_ray(q)
		if h.is_empty():
			return [NAN]
		var col: Object = h["collider"]
		# ışın bir katının içinde başladı (pişmiş öküzün kendi gövde kutusu: Bld.solid_box): o katı zemin değildir
		var inside := (h["position"] as Vector3).distance_to(q.from) < 0.001
		if col is Node and (inside or own.is_ancestor_of(col) or col == own or not Unclip.standable(col, int(h.get("shape", 0)))):
			q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
			continue
		# taşıyıcıyla kaydırılan gövde (gemi): fizik sunucusundaki yeri bir kare geride, ölçülmez (hud kuralı)
		var phys_xf: Transform3D = PhysicsServer3D.body_get_state((col as CollisionObject3D).get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM)
		if not phys_xf.origin.is_equal_approx((col as Node3D).global_transform.origin):
			return [NAN]
		return [(h["position"] as Vector3).y, col]
	return [NAN]


## Ayağın hemen altında (0,15 m içinde) görünen bir ağ yüzeyi var mı: çarpışmasız görünen eşyanın (çadır, raf, araba)
## üstünde duran havada değildir (10b'de patlamayla çadırın tepesine uçan keçi). Görünen ağlar zemin denetiminin uzayında.
func _gorunen_alt(low: Vector3) -> bool:
	_vis_build_at(low, 0.15)
	if not _vspace.is_valid():
		return false
	# en alçak nokta çoğu kez bir tırnağın ucu: kenarda duranın tırnağı 5-10 cm taşar (10a'da etiket tahtasının kenarındaki
	# tavuk). Ucun 0,1 m çevresinde de yoklanır.
	for o: Vector3 in [Vector3.ZERO, Vector3(0.1, 0, 0), Vector3(-0.1, 0, 0), Vector3(0, 0, 0.1), Vector3(0, 0, -0.1)]:
		var q := PhysicsRayQueryParameters3D.create(low + o + Vector3(0, 0.05, 0), low + o - Vector3(0, 0.15, 0), 1)
		q.hit_back_faces = false
		if not _vstate.intersect_ray(q).is_empty():
			return true
	# üstü kapalı olmayan ince görünen parça (10a'daki rafın etiket tahtası: yalnız ön yüz; tavuk üst kenarında):
	# kutusunun üstü ayağın 0,15 m altı ile 0,05 m üstü arasında ve ucun 0,1 m çevresi kutunun içinde
	for w: WeakRef in _geoms:
		var n = w.get_ref()
		if n == null or not (n is MeshInstance3D) or not (n as Node3D).is_inside_tree() or not (n as GeometryInstance3D).is_visible_in_tree() or _is_char_part(n):
			continue
		var ab := (n as MeshInstance3D).global_transform * (n as MeshInstance3D).get_aabb()
		if ab.end.y < low.y - 0.15 or ab.end.y > low.y + 0.05 or ab.size.x > 40.0 or ab.size.z > 40.0:
			continue
		if low.x > ab.position.x - 0.1 and low.x < ab.end.x + 0.1 and low.z > ab.position.z - 0.1 and low.z < ab.end.z + 0.1:
			return true
	return false


func _skip_animal(a: Node, own: Node) -> String:
	var q: Node = a
	while q != null and q != _scene:
		if q.has_meta("airborne") or q.has_meta("no_audit") or q.has_meta("no_ground"):
			return "airborne"
		if q is ThiefGull and (q as ThiefGull).flying:
			return "flying"
		if q is Ox and (q as Ox).lying:
			return "lying"
		if q is Person or q is Soldier:
			return "carried"      # taşınan (tavuk kucakta)
		q = q.get_parent()
	if own is Gulls:
		return "gulls"
	return ""


func _hayvan(pl: Node, eyes: Array[Vector3], now: int) -> void:
	for n in get_tree().get_nodes_in_group("hayvanlar"):
		var a := n as Node3D
		if a == null or not a.is_visible_in_tree():
			continue
		var id := a.get_instance_id()
		if _hy_seen.has(id):
			continue
		if not _near(a.global_position, eyes, 30.0):
			_hy_since.erase(id)
			continue
		var own := _owner_of(a)
		if _skip_animal(a, own) != "":
			_hy_since.erase(id)
			continue
		var low := _lowest(a)
		if low == Vector3.INF:
			continue
		var fr := _floor_under(own, low, 0.6, 8.0)
		var fy: float = fr[0]
		if is_nan(fy):
			_hy_since.erase(id)
			continue
		var gap := low.y - fy
		var kind := ""
		if gap > 0.15 and not Unclip.on_mesh(a, low) and not _gorunen_alt(low):
			kind = "float"
		elif gap < -0.10 and not Unclip.under(a, low, fy):
			kind = "sunk"
		if kind == "":
			_hy_since.erase(id)
			continue
		var st: Array = _hy_since.get(id, [])
		if st.is_empty() or st[0] != kind:
			_hy_since[id] = [kind, now]
			continue
		if now - int(st[1]) < 1000:
			continue
		_hy_seen[id] = true
		var col: Node = fr[1]
		_say("hayvan", "VISAUDIT %s scene=%s who=%s/%s feet=%s floor=%.2f gap=%.2f by=%s src=%s" % [kind, _sc_name(), _cls(own), a.name,
			_g(low), fy, gap, Hud.audit_src(col) if col else "?", Hud.audit_src(own)])


## Pişmiş hayvanlar (ordugâhın birleşik ağı): kurulumdan 3 sn sonra bir kez, her nokta için zemin farkı
func _pismis(now: int) -> void:
	if now - _t0 < 3000 or not _ww_ok:
		return
	for n in get_tree().get_nodes_in_group("pismis_hayvan"):
		var host := n as Node3D
		if host == null or _pismis_done.has(host.get_instance_id()) or not host.is_inside_tree():
			continue
		_pismis_done[host.get_instance_id()] = true
		var bad := 0
		var first := ""
		var cnt := 0
		var olc := 0
		for e: Array in host.get_meta("hayvan_noktalari", []):
			cnt += 1
			var p: Vector3 = host.global_transform * (e[0] as Vector3)
			var fr := _floor_under(host, p, 0.6, 8.0)
			if is_nan(float(fr[0])):
				continue
			olc += 1
			var gap: float = p.y - float(fr[0])
			if gap > 0.15 or gap < -0.10:
				bad += 1
				if first == "":
					first = "%s at=%s gap=%.2f by=%s" % [e[1], _g(p), gap, Hud.audit_src(fr[1])]
		if bad > 0:
			_say("hayvan", "VISAUDIT %s scene=%s who=pismis n=%d/%d olculen=%d ilk=%s src=%s" % ["float" if first.contains("gap=0") or not first.contains("gap=-") else "sunk",
				_sc_name(), bad, cnt, olc, first, Hud.audit_src(host)])


func _ww_done() -> bool:
	if _scene == null:
		return false
	for ww in _scene.find_children("WorldWalk", "", true, false):
		if not bool(ww.get("done")):
			return false
	return true


# ================================================================ 2. görünmez zemin

var _ww_ok := false
var _ww_chk := 0
var _ww_bekle := -1

func _zemin(pl: Player, now: int) -> void:
	if now - _t0 < 3000:
		return
	if not _ww_ok:
		if now < _ww_chk:
			return
		_ww_chk = now + 2000
		if _ww_done():
			# Dünya katılaşınca GameState'in havada-kişi taraması koşar; ağır kopyalama o karelere binmesin (22o'da
			# denetim açıkken o tarama yük altında 3/7 koşuda bir kişiyi havada yakalıyordu, kapalıyken 0/4)
			_ww_ok = _ww_bekle >= 0 and now >= _ww_bekle
			if _ww_bekle < 0:
				_ww_bekle = now + 3000
		if not _ww_ok:
			return
	if not pl.is_on_floor() or pl.move_mode != "walk" or pl.pinned or pl.ladder != null or pl.floating or not pl.visible:
		return
	if pl.traversal and pl.traversal.get("climbing") == true:
		return
	var feet := pl.global_position
	var space := pl.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(feet + Vector3(0, 0.3, 0), feet + Vector3(0, -0.6, 0), pl.collision_mask)
	q.exclude = [pl.get_rid()]
	var h := space.intersect_ray(q)
	if h.is_empty():
		return
	var col: Object = h["collider"]
	if not (col is CollisionObject3D) or col is RigidBody3D or col is CharacterBody3D or col is AnimatableBody3D:
		return
	# hareketli taşıyıcı (gemi, kayık, sal): fizik yeri düğümünden ayrı ya da düğüm kıpırdıyor
	var co := col as CollisionObject3D
	var phys_xf: Transform3D = PhysicsServer3D.body_get_state(co.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM)
	if not phys_xf.origin.is_equal_approx(co.global_transform.origin):
		return
	# kıpırdayan taşıyıcı (29'da gemi rotasında ilerler; düğümü her karede kaydırılır): son örnekten beri yer değiştirdi
	var cid := co.get_instance_id()
	var first := not _co_last.has(cid)
	var was: Vector3 = _co_last.get(cid, co.global_position)
	_co_last[cid] = co.global_position
	if first or _moving(co) or was.distance_to(co.global_position) > 0.01:
		return      # ilk örnekte yalnız yeri yazılır (kıpırdıyor mu bir sonraki örnekte belli olur)
	var shp := int(h.get("shape", 0))
	var p: Vector3 = h["position"]
	# Görünmez sınır duvarı (ince, uzun kutu: korkuluk arkası, küpeşte üstü) zemin değildir (ölçüt); üstünde durmak ayrı
	# bir sınıftır: bilgi satırı (paketi düşürmez), bölüm başına bir kez
	if _sinir_duvari(co, shp):
		if not _gz_seen.has("sinir"):
			_gz_seen["sinir"] = true
			print("GORUNMEZSINIR scene=%s at=%s collider=%s" % [_sc_name(), _g(p), _col_src(co, shp)])
		return
	var key := "%d#%d#%s" % [co.get_instance_id(), co.shape_find_owner(shp), str(Vector2i(floori(p.x / 3.0), floori(p.z / 3.0)))]
	if _gz_seen.has(key):
		return
	if _vis_hit(p, false):
		return
	# önbellekte yok: bu noktayı kapsayan görünen ağlar kopyalanır (tembel), yeniden sorulur
	_vis_build_at(p)
	if _vis_hit(p, true):
		return
	# Dünya arazisi (IstDunya) parçalarını yeniden kuruyor (düzleme sonrası, ayrıntı düzeyi; hızlı testte yürüyüş
	# kurulumdan hızlı): görünen parça eski. Çarpışma noktası arazinin gerçek yüksekliğindeyse (IstGeo.h, kurulum
	# bitince görünecek yüzey) bulgu sayılmaz; değilse (rampa, döşeme: arazi değil) sayılır.
	var dy := _dunya_bekleyen(p)
	if not is_nan(dy) and absf(dy) <= 0.35:
		return
	_gz_seen[key] = true
	_gz_n += 1
	if _gz_n > 12:
		return
	_say("zemin", "GORUNMEZZEMIN scene=%s at=%s collider=%s shape=%s" % [_sc_name(), _g(p), _col_src(co, shp), _shape_kind(co, shp)])
	if OS.has_environment("D17_DBG"):
		_dbg_column(p)


## Hata ayıklama: noktanın dikey sütunundaki bütün görünen ağlar (kutu y aralığı, görünürlük)
func _dbg_column(p: Vector3) -> void:
	var col := AABB(Vector3(p.x - 0.05, p.y - 30.0, p.z - 0.05), Vector3(0.1, 60.0, 0.1))
	for w: WeakRef in _geoms:
		var n = w.get_ref()
		if n == null or not (n as Node).is_inside_tree():
			continue
		var gi := n as GeometryInstance3D
		var ab := gi.global_transform * gi.get_aabb()
		if not ab.intersects(col):
			continue
		var y := NAN
		if gi is MeshInstance3D and (gi as MeshInstance3D).mesh:
			var f := (gi as MeshInstance3D).mesh.get_faces()
			var xf := gi.global_transform
			for i in range(0, f.size(), 3):
				var r = Geometry3D.ray_intersects_triangle(Vector3(p.x, p.y + 30.0, p.z), Vector3.DOWN, xf * f[i], xf * f[i + 1], xf * f[i + 2])
				if r != null and (is_nan(y) or absf((r as Vector3).y - p.y) < absf(y - p.y)):
					y = (r as Vector3).y
		var lodtxt := ""
		if gi.get_parent() is IstDunya:
			for k in (gi.get_parent() as IstDunya).get("_chunks"):
				if (gi.get_parent() as IstDunya).get("_chunks")[k]["mi"] == gi:
					lodtxt = " lod=%d jobs=%d" % [(gi.get_parent() as IstDunya).get("_chunks")[k]["lod"], ((gi.get_parent() as IstDunya).get("_jobs") as Array).size()]
		print("  D17DBG%s %s vis=%s rng=%.0f-%.0f aby=%.2f..%.2f hit=%.2f %s" % [lodtxt, Hud.audit_src(gi), gi.is_visible_in_tree(), gi.visibility_range_begin, gi.visibility_range_end,
			ab.position.y, ab.end.y, y, gi.get_class()])


var _dunyalar: Array = []
var _dunya_ara := false

## Kurulumu süren bir dünya varsa: p ile o dünyanın gerçek arazi yüksekliği farkı; yoksa NAN
func _dunya_bekleyen(p: Vector3) -> float:
	if not _dunya_ara:
		_dunya_ara = true
		for d in _scene.find_children("*", "Node3D", true, false):
			if d is IstDunya:
				_dunyalar.append(weakref(d))
	for w: WeakRef in _dunyalar:
		var d = w.get_ref()
		if d == null or not (d as Node3D).is_inside_tree():
			continue
		var busy := not (d.get("_jobs") as Array).is_empty() or not (d.get("_job") as Dictionary).is_empty()
		for k in d.get("_chunks"):
			if int(d.get("_chunks")[k]["lod"]) < 0:
				busy = true
		if not busy:
			continue
		var lp := (d as Node3D).to_local(p)
		var wy := (d as Node3D).to_global(Vector3(lp.x, IstGeo.h(lp.x, lp.z), lp.z)).y
		return p.y - wy
	return NAN


func _moving(n: Node) -> bool:
	var q: Node = n
	while q != null and q != _scene:
		if q.has_meta("carrier") or q is PathFollow3D or q is VehicleBody3D:
			return true
		q = q.get_parent()
	return false


func _sinir_duvari(co: CollisionObject3D, shp: int) -> bool:
	var own := co.shape_find_owner(shp)
	if own < 0 or co.shape_owner_get_shape_count(own) == 0:
		return false
	var s := co.shape_owner_get_shape(own, 0)
	if not (s is BoxShape3D):
		return false
	var o := co.shape_owner_get_owner(own)
	if o is Node3D:
		for c in (o as Node).get_children() + co.get_children():
			if c is GeometryInstance3D and (c as GeometryInstance3D).visible:
				return false
	var sz := (s as BoxShape3D).size * co.global_basis.get_scale()
	return sz.y >= 1.5 and minf(sz.x, sz.z) <= 0.5


func _shape_kind(co: CollisionObject3D, shp: int) -> String:
	var own := co.shape_find_owner(shp)
	if own < 0:
		return "?"
	var s := co.shape_owner_get_shape(own, 0) if co.shape_owner_get_shape_count(own) > 0 else null
	return s.get_class() if s else "?"


## Çarpışmanın kaynağı: WorldWalk'ta şeklin kaynağı (_src), öbürlerinde düğümün yolu
func _col_src(co: CollisionObject3D, shp: int) -> String:
	var own := co.shape_find_owner(shp)
	var ww := co.get_parent()
	if ww and ww.get_script() != null and str((ww.get_script() as Script).get_global_name()) == "WorldWalk":
		var src: Dictionary = ww.get("_src")
		if src.has(own):
			var s = src[own]
			if s is Array:
				return "WorldWalk<" + Hud.audit_src(s[0]) + "#" + str(s[1]) + ">"
			return "WorldWalk<" + Hud.audit_src(s) + ">"
		return "WorldWalk<?>"
	var sn := ""
	if own >= 0:
		var o := co.shape_owner_get_owner(own)
		if o is Node and o != co:
			sn = "/" + str((o as Node).name)
	return Hud.audit_src(co) + sn


func _vis_hit(p: Vector3, fresh: bool) -> bool:
	if not _vspace.is_valid():
		return false
	var a := p + Vector3(0, 0.35, 0)
	var b := p - Vector3(0, 0.35, 0)
	var excl: Array[RID] = []
	for i in 6:
		var q := PhysicsRayQueryParameters3D.create(a, b, 1, excl)
		q.hit_back_faces = true
		var hh := _vstate.intersect_ray(q)
		if hh.is_empty():
			return false
		var rid: RID = hh["rid"]
		var info = _vinfo.get(rid)
		# kopyalandığından beri gizlenen ya da kıpırdayan ağ sayılmaz (yeniden kopyalanır)
		if info == null or not _still_visible(info, p):
			excl.append(rid)
			if info != null and not fresh:
				_vbuilt.erase(info[0])
			continue
		return true
	return false


var _vinfo := {}   # body RID -> [anahtar, node weakref, Transform3D]

func _still_visible(info: Array, p: Vector3) -> bool:
	var n = (info[1] as WeakRef).get_ref()
	if n == null or not (n as GeometryInstance3D).is_visible_in_tree():
		return false
	if not _range_ok(n as GeometryInstance3D, p):
		return false
	# ağ değişti (dünya arazisinin parçası yeni ayrıntı düzeyiyle yeniden kuruldu): kopya eskidi
	var cur = (n as MultiMeshInstance3D).multimesh if n is MultiMeshInstance3D else (n as MeshInstance3D).mesh
	if cur != info[3]:
		return false
	return (n as Node3D).global_transform.is_equal_approx(info[2])


func _range_ok(gi: GeometryInstance3D, p: Vector3) -> bool:
	if gi.visibility_range_begin <= 0.0 and gi.visibility_range_end <= 0.0:
		return true
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return true
	var d := cam.global_position.distance_to(gi.global_position)
	if gi.visibility_range_end > 0.0 and d > gi.visibility_range_end + gi.visibility_range_end_margin + 2.0:
		return false
	if gi.visibility_range_begin > 0.0 and d < gi.visibility_range_begin - gi.visibility_range_begin_margin - 2.0:
		return false
	return true


func _vis_build_at(p: Vector3, r := 0.05) -> void:
	if not _vspace.is_valid():
		_vspace = PhysicsServer3D.space_create()
		PhysicsServer3D.space_set_active(_vspace, true)
		_vstate = PhysicsServer3D.space_get_direct_state(_vspace)
	var probe := AABB(p - Vector3(r, 0.4, r), Vector3(r * 2.0, 0.8, r * 2.0))
	var keep: Array = []
	for w: WeakRef in _geoms:
		var n = w.get_ref()
		if n == null:
			continue
		keep.append(w)
		var gi := n as GeometryInstance3D
		if not gi.is_inside_tree() or not gi.is_visible_in_tree() or _is_char_part(gi):
			continue
		if not _range_ok(gi, p):
			continue
		if gi is MeshInstance3D:
			var mi := gi as MeshInstance3D
			if mi.mesh == null:
				continue
			if not (mi.global_transform * mi.get_aabb()).grow(0.05).intersects(probe):
				continue
			var k := str(mi.get_instance_id())
			if _vbuilt.has(k):
				continue
			_add_vis(k, mi, mi.mesh.get_faces(), mi.global_transform, mi.global_transform)
		elif gi is MultiMeshInstance3D:
			var mmi := gi as MultiMeshInstance3D
			var mm := mmi.multimesh
			if mm == null or mm.mesh == null or mm.transform_format != MultiMesh.TRANSFORM_3D:
				continue
			if not (mmi.global_transform * mmi.get_aabb()).grow(0.05).intersects(probe):
				continue
			var lab := mm.mesh.get_aabb()
			var cnt := mm.instance_count if mm.visible_instance_count < 0 else mini(mm.visible_instance_count, mm.instance_count)
			var faces := PackedVector3Array()
			for i in cnt:
				var xf: Transform3D = mmi.global_transform * WorldWalk.inst_xf(mmi, i)
				if absf(xf.basis.determinant()) < 1e-6 or not (xf * lab).grow(0.05).intersects(probe):
					continue
				var k := "%d#%d" % [mmi.get_instance_id(), i]
				if _vbuilt.has(k):
					continue
				if faces.is_empty():
					faces = mm.mesh.get_faces()
				_add_vis(k, mmi, faces, xf, mmi.global_transform)
	_geoms = keep


func _is_char_part(n: Node) -> bool:
	var q: Node = n
	while q != null and q != _scene:
		if q is Person or q is Soldier or q is Player or q.is_in_group("hayvanlar"):
			return true
		q = q.get_parent()
	return false


func _add_vis(key: String, node: Node, faces: PackedVector3Array, xf: Transform3D, node_xf: Transform3D) -> void:
	if faces.size() < 3:
		_vbuilt[key] = []
		return
	var w := PackedVector3Array()
	w.resize(faces.size())
	for i in faces.size():
		w[i] = xf * faces[i]
	var shape := PhysicsServer3D.concave_polygon_shape_create()
	PhysicsServer3D.shape_set_data(shape, {"faces": w, "backface_collision": true})
	var body := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body, PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_add_shape(body, shape)
	PhysicsServer3D.body_set_collision_layer(body, 1)
	PhysicsServer3D.body_set_collision_mask(body, 0)
	PhysicsServer3D.body_set_space(body, _vspace)
	_vbuilt[key] = [body, shape]
	_vinfo[body] = [key, weakref(node), node_xf, (node as MultiMeshInstance3D).multimesh if node is MultiMeshInstance3D else (node as MeshInstance3D).mesh]


func _free_vis() -> void:
	for k in _vbuilt:
		var e: Array = _vbuilt[k]
		if e.size() == 2:
			PhysicsServer3D.free_rid(e[0])
			PhysicsServer3D.free_rid(e[1])
	_vbuilt.clear()
	_vinfo.clear()
	if _vspace.is_valid():
		PhysicsServer3D.free_rid(_vspace)
	_vspace = RID()


# ================================================================ 3. iş istasyonu aleti

func _tool_of(w: Node) -> Node3D:
	for t in w.find_children("Tool_*", "", true, false):
		if t is Node3D and t.has_meta("tool_kind") and (t as Node3D).is_visible_in_tree():
			return t
	return null


## Aletin ölçülen noktası ile işin noktası arasındaki uzaklık: "fwd" aletlerinde (testere, fırça) ağzın tamamı işe
## değer, sap–uç doğru parçasının en yakın noktası; öbürlerinde uç (kökten "len" kadar ileride)
func _tool_dist(t: Node3D, target: Vector3) -> float:
	var tip := t.global_transform * Vector3(0, 0, float(t.get_meta("len", 0.4)))
	if str(t.get_meta("tool_mode", "")) == "fwd":
		return Geometry3D.get_closest_point_to_segment(target, t.global_position, tip).distance_to(target)
	return tip.distance_to(target)


func _alet(eyes: Array[Vector3], now: int) -> void:
	for n in get_tree().get_nodes_in_group("is_istasyonu"):
		var st := n as Node3D
		if st == null or not st.is_visible_in_tree() or not st.has_meta("is_noktasi"):
			continue
		var sid := st.get_instance_id()
		if _al_seen.has(sid) or not _near(st.global_position, eyes, 30.0):
			continue
		var target: Vector3 = st.global_transform * (st.get_meta("is_noktasi") as Vector3)
		var r: float = st.get_meta("is_yaricap", 0.3)
		var kind := str(st.name).trim_prefix("Station_")
		for w in st.get_meta("who", []):
			if not is_instance_valid(w) or not (w is Person or w is Soldier):
				continue
			var t := _tool_of(w)
			if t == null:
				continue
			var d := _tool_dist(t, target)
			if OS.has_environment("D17_DBG") and not _al_dbg.has(sid):
				_al_dbg[sid] = true
				print("  D17DBG alet kind=%s d=%.2f pay=%.2f who=%s" % [kind, d, r, _cls(w)])
			if kind == "stir_pot":
				# kepçe hep kazanın içinde: 1 sn aralıksız dışarıda kalırsa
				if d > r:
					if not _al_out.has(sid):
						_al_out[sid] = now
					elif now - int(_al_out[sid]) >= 1000:
						_al_seen[sid] = true
						_alet_say(st, w, t, target, d, r, "disarida")
				else:
					_al_out.erase(sid)
				continue
			var win: Array = _al_min.get(sid, [])
			if win.is_empty():
				_al_min[sid] = [now, d]
				continue
			win[1] = minf(float(win[1]), d)
			if now - int(win[0]) >= 3000:
				if float(win[1]) > r:
					_al_seen[sid] = true
					_alet_say(st, w, t, target, float(win[1]), r, "pencere3sn")
				_al_min[sid] = [now, d]
	_alet_baked()


func _alet_say(st: Node3D, w: Node3D, t: Node3D, target: Vector3, d: float, r: float, why: String) -> void:
	var tip := t.global_transform * Vector3(0, 0, float(t.get_meta("len", 0.4)))
	var hand := t.global_position
	var yaw := wrapf(w.global_rotation.y - st.global_rotation.y, -PI, PI)
	var lt = w.get("look_target")
	_say("alet", "ALETAUDIT scene=%s kind=%s who=%s tool=%s d=%.2f pay=%.2f neden=%s tip=%s hedef=%s el_hedef=%.2f yaw=%.2f kok=%s look=%s act=%s src=%s" % [_sc_name(),
		str(st.name).trim_prefix("Station_"), _cls(w), t.get_meta("tool_kind", "?"), d, r, why, _g(tip), _g(target), hand.distance_to(target), yaw,
		_g(st.to_local(w.global_position)), "var" if lt is Node3D and is_instance_valid(lt) else "yok", _act(w), Hud.audit_src(st)])


func _act(n: Node) -> String:
	var a = n.get("activity")
	if a != null and str(a) != "":
		return str(a)
	var rg = n.get("rig")
	if rg != null and rg is Rig:
		return str((rg as Rig).activity)
	return ""


## Donuk (Crowd pişmiş) figürlerin aleti: kurulumda bir kez (Stage.station "is_baked" metası: pişmiş aletin ucu)
func _alet_baked() -> void:
	for n in get_tree().get_nodes_in_group("is_istasyonu_donuk"):
		var st := n as Node3D
		if st == null or _al_baked_done.has(st.get_instance_id()) or not st.has_meta("is_baked_tip"):
			continue
		_al_baked_done[st.get_instance_id()] = true
		var target: Vector3 = st.global_transform * (st.get_meta("is_noktasi") as Vector3)
		var tip: Vector3 = st.get_meta("is_baked_tip")
		var r: float = st.get_meta("is_yaricap", 0.3)
		if tip.distance_to(target) > r:
			_say("alet", "ALETAUDIT scene=%s kind=%s who=donuk d=%.2f pay=%.2f tip=%s hedef=%s src=%s" % [_sc_name(), str(st.name).trim_prefix("Station_"),
				tip.distance_to(target), r, _g(tip), _g(target), Hud.audit_src(st)])


# ================================================================ 4. donuk bekleme (PACE)

func _donuk(now: int) -> void:
	var pl = _scene.get("player")
	if not (pl is Player) or not (pl as Node3D).is_inside_tree():
		_dn_start = -1
		return
	var p := pl as Player
	var cam := get_viewport().get_camera_3d()
	var legit := ""
	if not p.frozen:
		legit = "serbest"
	elif get_tree().paused:
		legit = "duraklatma"
	elif hud.call("street_busy"):
		legit = "replik/secim"
	elif hud.call("is_faded"):
		legit = "karartma/kart"
	elif bool(hud.get("cinematic")):
		legit = "sinematik"
	elif p.move_mode == "script":
		legit = "script"
	elif p.pinned:
		legit = "pinned"
	elif _mini_live():
		legit = "mini"
	elif hud.get_node_or_null("Flowchart") != null or _flow_open():
		legit = "akis"
	elif cam and _izlenen_is(p, cam):
		legit = "izlenen_is"
	var cp := cam.global_position if cam else Vector3.ZERO
	var cb := cam.global_basis if cam else Basis()
	var still := _dn_pos != Vector3.INF and p.global_position.distance_to(_dn_pos) < 0.02 and cp.distance_to(_dn_cam_p) < 0.02 \
		and cb.z.dot(_dn_cam.z) > 0.9995
	_dn_pos = p.global_position
	_dn_cam = cb
	_dn_cam_p = cp
	if legit != "" or not still:
		if _dn_start >= 0 and now - _dn_start > 4000:
			_say("donuk", "DONUKAUDIT scene=%s t=%.1f len=%.1f after=%s at=%s" % [_sc_name(), (_dn_start - _t0) / 1000.0, (now - _dn_start) / 1000.0,
				str(hud.get("_pace_key")), _g(p.global_position)])
		_dn_start = -1
		return
	if _dn_start < 0:
		_dn_start = now


var _dn_cam_p := Vector3.ZERO


## Oyuncunun önünde (8 m, bakış konisinde) sahne betiğinin yürüttüğü ya da işe tuttuğu biri var: oyuncu bir işi izliyor
## (8y nöbetçisinin kapıyı açması). Pazarda uzaktaki Hasan'ı beklemek (24 sn) bu değildir: o 8 m'nin dışında.
func _izlenen_is(p: Player, cam: Camera3D) -> bool:
	var fw := -cam.global_basis.z
	for n in get_tree().get_nodes_in_group("persons") + get_tree().get_nodes_in_group("soldiers"):
		var c := n as Node3D
		if c == null or not c.is_visible_in_tree() or not (c.has_meta("stage_walk") or c.has_meta("grip_tw")):
			continue
		var to := c.global_position + Vector3(0, 1.0, 0) - cam.global_position
		if to.length() > 8.0 or to.normalized().dot(fw) < 0.6:
			continue
		return true
	return false


func _mini_live() -> bool:
	for w: WeakRef in _mini:
		var n = w.get_ref()
		if n != null and (n as Node).is_inside_tree() and (not (n is Node3D) or (n as Node3D).is_visible_in_tree()) and (not (n is CanvasItem) or (n as CanvasItem).is_visible_in_tree()):
			return true
	return false


func _flow_open() -> bool:
	for c in hud.get_children():
		if c.get_script() != null and str((c.get_script() as Script).get_global_name()) == "Flowchart" and c is CanvasItem and (c as CanvasItem).visible:
			return true
	return false
