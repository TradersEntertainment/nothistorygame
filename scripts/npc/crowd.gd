class_name Crowd
extends RefCounted
## Kalabalık: gerçek karakter modelinin (Soldier / Person) birebir donmuş kopyası. Model bir kez kurulur; yüz,
## bıyık, börk ya da miğfer, kaftan, silah dahil bütün parçaları tek ağa pişirilir ve MultiMesh ile çoğaltılır.
## Yakından bakınca canlı askerle aynıdır (yalnız nefes almaz). Uzaklık katmanı: NEAR metreye kadar bu ağ, ötesinde
## (seçilemeyecek uzaklıkta) hafif siluet. Parçalar 64 m'lik hücrelere bölünür; her hücre kendi uzaklığına göre seçilir.
##
## Kullanım: Crowd.place(parent, [[Transform3D, {"side": "O", "coat": Color, "hat": "bork", "arm": "spear"}], ...])

const NEAR := 150.0
const CELL := 64.0
const OTT_COATS := [Color("b3262d"), Color("2f5fa8"), Color("3a6b3a"), Color("8a6a4a"), Color("6a4a3a"), Color("c98a3a")]
const BYZ_COATS := [Color("7a2a24"), Color("5a6a7a"), Color("8a8e96"), Color("4a3a2e"), Color("6a5a48"), Color("3a4a6a")]

static var _meshes := {}
static var _mat_cache: StandardMaterial3D


## Osmanlı askeri. hat: "bork" ya da "turban"; arm: "spear", "bow", "sword_shield", "" (boş el).
## pose: "" (ayakta) ya da bir Rig işi ("sit_ground": ateş başında bağdaş kurmuş).
## arm "tool:<alet>" (yayma P0, Stage.station donuk istasyon): iş aleti (Items.TOOLS) pozdan sonra ele verilir,
## pişmiş modelde avuçta durur (pose aletin işi olmalı: "tool:mallet" + "hammer").
static func ottoman(coat: Color, hat := "bork", arm := "spear", pose := "") -> ArrayMesh:
	var key := "O|%s|%s|%s|%s" % [coat.to_html(), hat, arm, pose]
	if arm.begins_with("tool:"):
		key += "|" + FileAccess.get_md5("res://scripts/level/items.gd")      # alet modeli değişince yeniden pişer
	if not _meshes.has(key) and not _from_disk(key):
		var s := Soldier.new(coat, "stand", hat)
		_meshes[key] = _bake(s, func():
			if arm != "" and not arm.begins_with("tool:"):
				s.equip(arm)
			_pose(s, pose)
			if arm.begins_with("tool:"):
				var t := s.give_tool(arm.substr(5), {"activity": pose, "phase": 0.3, "frozen": true})
				if t:
					Items._tool_pose(s, t))
		_to_disk(key)
	return _meshes[key]


## Rig'in işini (oturuş vb.) donmuş modele uygular: iş hareketi birkaç adımda yerine oturur.
static func _pose(n: Node3D, pose: String) -> void:
	if pose == "":
		return
	var rg = n.get("rig")
	if not (rg is Rig):
		return
	(rg as Rig).activity = pose
	for i in 60:
		(rg as Rig).update(0.1, false, false)


## Bizans savunanı: miğfer, zincir zırh; arm: "spear", "bow", "spear_shield", "".
## pose "aim": okçu yayı germiş (sol kol öne, yay dik; sağ el çenede, kiriş çekili).
static func byzantine(coat: Color, arm := "spear", pose := "") -> ArrayMesh:
	var key := "B|%s|%s|%s" % [coat.to_html(), arm, pose]
	if not _meshes.has(key) and not _from_disk(key):
		var i := BYZ_COATS.find(coat)
		var p := Person.new({"coat": coat, "pants": [Color("3a2a22"), Color("2a2a30"), Color("4a3a2a")][maxi(i, 0) % 3], "hat": "helm",
			"beard": i % 3 != 1, "mustache": i % 2 == 0, "n": 900 + i})
		p.set_meta("no_talk", true)
		_meshes[key] = _bake(p, func():
			if arm != "":
				p.equip(arm, BYZ_COATS[(maxi(i, 0) + 2) % BYZ_COATS.size()])
			_pose(p, pose)
			if pose == "aim":
				# Yay dirseğe bağlı: kol öne kalkınca yay da yatar; dik tutulsun
				var bw := p.find_child("Bow", true, false) as Node3D
				if bw:
					bw.rotation.x = 1.45)
		_to_disk(key)
	return _meshes[key]


## Ordugâh ya da şehir halkı (kaftanlı, sarıklı / başı açık).
static func civilian(coat: Color, hat := "turban", pose := "") -> ArrayMesh:
	var key := "C|%s|%s|%s" % [coat.to_html(), hat, pose]
	if not _meshes.has(key) and not _from_disk(key):
		var p := Person.new({"coat": coat, "pants": Color("3a3028"), "hat": hat, "mustache": true, "beard": hat == "turban",
			"skin": Color("d9a07a"), "n": 700})
		p.set_meta("no_talk", true)
		_meshes[key] = _bake(p, func(): _pose(p, pose))
		_to_disk(key)
	return _meshes[key]


## Pişmiş modellerin disk önbelleği (user://crowd_cache): her asker türü ~0,1 sn'de pişer, bir bölümde 25–30 tür
## olur; önbellek olmadan her bölüm yüklemesi ve ana menüye dönüş saniyelerce donuyordu. Model kodu değişince
## BAKE_VERSION artırılır (ya da karakter betikleri değişir: anahtara dosya özetleri katılır).
const BAKE_VERSION := 1
const CACHE_DIR := "user://crowd_cache"
static var _salt := ""


static func _cache_path(key: String) -> String:
	if _salt == "":
		var parts: String = str(BAKE_VERSION) + str(Engine.get_version_info()["string"])
		for f in ["res://scripts/npc/soldier.gd", "res://scripts/npc/person.gd", "res://scripts/npc/char_kit.gd", "res://scripts/npc/rig.gd"]:
			if FileAccess.file_exists(f):
				parts += FileAccess.get_md5(f)
		_salt = parts.md5_text()
	return CACHE_DIR.path_join((key + _salt).md5_text() + ".res")


static func _from_disk(key: String) -> bool:
	var path := _cache_path(key)
	if not FileAccess.file_exists(path):
		return false
	var m := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as ArrayMesh
	if m == null:
		return false
	_meshes[key] = m
	return true


static func _to_disk(key: String) -> void:
	if not _meshes.has(key):
		return
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)
	# Önce geçici dosyaya, sonra yerine taşı: aynı anda koşan iki oyun (paralel testler) yarım yazılmış dosyayı okumasın
	var path := _cache_path(key)
	var tmp := path.get_basename() + ".%d.tmp.res" % OS.get_process_id()
	if ResourceSaver.save(_meshes[key], tmp, ResourceSaver.FLAG_COMPRESS) == OK:
		DirAccess.rename_absolute(tmp, path)


## Karakteri sahneye koymadan önce görünmez kurar, bütün görünür parçalarını kök uzayında tek yüzeye toplar.
static func _bake(n: Node3D, after: Callable) -> ArrayMesh:
	var tree := Engine.get_main_loop() as SceneTree
	n.visible = false
	# Sahne kurulurken kök düğüm meşguldür: model, her zaman ağaçta olan GameState'in altında kurulur
	var holder: Node = tree.root.get_node_or_null("GameState")
	if holder == null:
		holder = tree.root
	holder.add_child(n)          # _ready: parçalar kurulur, CharKit.bake birleştirir
	if after.is_valid():
		after.call()
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	var inv := n.global_transform.affine_inverse()
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null or not mi.visible:
			continue
		var m := mi.material_override as StandardMaterial3D
		if m and (m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or m.albedo_color.a < 0.99):
			continue
		var tint := Color.WHITE if (m == null or m.vertex_color_use_as_albedo) else m.albedo_color
		var xf := inv * mi.global_transform
		var nb := xf.basis.inverse().transposed()
		for si in mi.mesh.get_surface_count():
			var arr := mi.mesh.surface_get_arrays(si)
			var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var nr: PackedVector3Array = arr[Mesh.ARRAY_NORMAL] if arr[Mesh.ARRAY_NORMAL] != null else PackedVector3Array()
			var vc: PackedColorArray = arr[Mesh.ARRAY_COLOR] if arr[Mesh.ARRAY_COLOR] != null else PackedColorArray()
			var ix: PackedInt32Array = arr[Mesh.ARRAY_INDEX] if arr[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			var sm := mi.get_surface_override_material(si) as StandardMaterial3D
			var st := tint
			if m == null and sm == null and mi.mesh.surface_get_material(si) is StandardMaterial3D:
				var mm := mi.mesh.surface_get_material(si) as StandardMaterial3D
				if not mm.vertex_color_use_as_albedo:
					st = mm.albedo_color
			var base := verts.size()
			for k in v.size():
				verts.append(xf * v[k])
				norms.append((nb * nr[k]).normalized() if nr.size() > k else Vector3.UP)
				var col := vc[k] if vc.size() > k else Color.WHITE
				cols.append(Color(col.r * st.r, col.g * st.g, col.b * st.b, 1.0))
			if ix.is_empty():
				for k in v.size():
					idx.append(base + k)
			else:
				for k in ix:
					idx.append(base + k)
	holder.remove_child(n)
	n.queue_free()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = norms
	arrays[Mesh.ARRAY_COLOR] = cols
	arrays[Mesh.ARRAY_INDEX] = idx
	# Uzaklığa göre sadeleşen ayrıntı katmanları (LOD): yakında tam model, uzaklaştıkça daha az üçgen
	var im := ImporterMesh.new()
	im.add_surface(Mesh.PRIMITIVE_TRIANGLES, arrays)
	im.generate_lods(25.0, 60.0, [])
	return im.get_mesh()


static func material() -> StandardMaterial3D:
	return CharKit.vc_mat(true)


## Bir öğenin ağı (yakın) ve uzak silueti.
static func _near_mesh(spec: Dictionary) -> ArrayMesh:
	match str(spec.get("side", "O")):
		"B":
			return byzantine(spec.get("coat", BYZ_COATS[0]), str(spec.get("arm", "spear")), str(spec.get("pose", "")))
		"C":
			return civilian(spec.get("coat", Color("8a6a4a")), str(spec.get("hat", "turban")), str(spec.get("pose", "")))
		_:
			return ottoman(spec.get("coat", OTT_COATS[0]), str(spec.get("hat", "bork")), str(spec.get("arm", "spear")), str(spec.get("pose", "")))


static func _far_mesh(spec: Dictionary) -> ArrayMesh:
	match str(spec.get("side", "O")):
		"B":
			return Assault.defender_mesh(spec.get("coat", BYZ_COATS[0]))
		_:
			return Assault.soldier_mesh(spec.get("coat", OTT_COATS[0]))


## items: [[Transform3D, spec], ...]. Hücre ve ağ türüne göre gruplar; her grup için yakın (gerçek model) ve uzak
## (siluet) MultiMesh kurar. far := false ise uzak katman kurulmaz (hep gerçek model). Kurulan düğümleri döndürür.
static func place(parent: Node3D, items: Array, far := true, solid := false) -> Array:
	var groups := {}
	for it in items:
		var xf: Transform3D = it[0]
		var spec: Dictionary = it[1]
		var cell := Vector2i(floori(xf.origin.x / CELL), floori(xf.origin.z / CELL))
		var key := "%s|%s|%s|%s|%s|%s|%s" % [cell, spec.get("side", "O"), (spec.get("coat", Color.WHITE) as Color).to_html(),
			spec.get("hat", ""), spec.get("arm", ""), spec.get("pose", ""), far]
		if not groups.has(key):
			groups[key] = [spec, []]
		(groups[key][1] as Array).append(xf)
	var out: Array = []
	for key in groups:
		var spec: Dictionary = groups[key][0]
		var xs: Array = groups[key][1]
		var nm := _near_mesh(spec)
		var near := Scenery.scatter(parent, nm, xs, [], material())
		near.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		near.set_meta("crowd_spec", spec)      # WallCrowd: tüfek sahnesinde figür gerçek askere dönüşebilir
		out.append(near)
		if solid:
			# Oyuncunun yürüdüğü yerdeki donmuş kopyalar katı (içlerinden geçilmesin): gövde boyu dar kutu
			# (mızrak, kılıç kutuya girmez; oturanın kutusu alçak)
			var h := minf(nm.get_aabb().size.y, 1.75)
			Scenery.solidify(near, AABB(Vector3(-0.25, 0.0, -0.22), Vector3(0.5, h, 0.44)), xs, 1.0)
		if far:
			near.visibility_range_end = NEAR
			near.visibility_range_end_margin = 10.0
			var f := Scenery.scatter(parent, _far_mesh(spec), xs, [], Scenery._vc_mat())
			f.visibility_range_begin = NEAR
			f.visibility_range_begin_margin = 10.0
			near.set_meta("crowd_twin", f)
			out.append(f)
	return out


## Yardımcı: Osmanlı / Bizans spec'i (renk sırası ve silah dönüşümlü).
static func ott(i: int, arm := "spear", coat := Color(0, 0, 0, 0)) -> Dictionary:
	return {"side": "O", "coat": coat if coat.a > 0.0 else OTT_COATS[i % OTT_COATS.size()], "hat": "bork" if i % 3 != 2 else "turban", "arm": arm}


static func byz(i: int, arm := "spear", coat := Color(0, 0, 0, 0)) -> Dictionary:
	return {"side": "B", "coat": coat if coat.a > 0.0 else BYZ_COATS[i % BYZ_COATS.size()], "arm": arm}


# ---------------------------------------------------------------- kalabalık kıpırtısı (yayma P0)

## Donuk duran sıraya / kalabalığa canlılık. people: canlı Person/Soldier'lar ve/veya Crowd.place'in döndürdüğü
## düğümler (MultiMeshInstance3D; uzak siluet katmanı atlanır).
##  · Canlı kişi: 5-14 sn'de bir kısa jest (opts "emotes"; varsayılan nod, cross_self, whisper, shrug, arms_cross);
##    konuşurken, kilitliyken (emote/grip), yürürken, iş başındayken (activity) ya da "no_vary" işaretliyse atlanır.
##    Rig saati zaten kişiden kişiye rastgele başlar (nefes, kıpırdanma fazları ayrı).
##  · Donuk çoklu ağ: 2-4 sn'de bir birkaç örnek (opts "max_mm", 6) ±turn rad döner (ağırlık değiştirir, yana bakar),
##    1,5-4 sn sonra yerine döner. Ucuz: yalnız o örneklerin dönüşümü yazılır.
## opts: "emotes" (Array), "every" (Vector2: canlı jest aralığı sn), "turn" (0,25 rad), "max_mm".
## Örnek: Crowd.idle_vary(kuyruktakiler); Crowd.idle_vary(Crowd.place(self, sira), {"turn": 0.3})
static func idle_vary(people: Array, opts := {}) -> void:
	for w in people:
		if w is MultiMeshInstance3D:
			var mmi := w as MultiMeshInstance3D
			if mmi.visibility_range_begin > 0.0 or mmi.multimesh == null or mmi.multimesh.instance_count == 0:
				continue
			var base: Array = []
			for i in mmi.multimesh.instance_count:
				base.append(mmi.multimesh.get_instance_transform(i))
			mmi.set_meta("vary_base", base)
			_vary_mm_next(mmi, opts)
		elif w is Node3D and Handover.rig_of(w) != null:
			_vary_next(w, opts, true)


static func _vary_next(w: Node3D, opts: Dictionary, first := false) -> void:
	if not is_instance_valid(w) or not w.is_inside_tree():
		return
	var ev: Vector2 = opts.get("every", Vector2(5.0, 14.0))
	var wait := randf_range(ev.x, ev.y) * (randf_range(0.2, 1.0) if first else 1.0)
	w.get_tree().create_timer(wait, false).timeout.connect(func():
		if not is_instance_valid(w) or not w.is_inside_tree():
			return
		var rg := Handover.rig_of(w)
		var talking: bool = w.get("talking") == true
		if rg and rg.lock == 0 and rg.speed < 0.2 and rg.activity == "" and not talking and not w.has_meta("no_vary") \
				and w.is_visible_in_tree():
			var em: Array = opts.get("emotes", ["nod", "cross_self", "whisper", "shrug", "arms_cross", "nod"])
			rg.emote(em[randi() % em.size()])
		_vary_next(w, opts))


static func _vary_mm_next(mmi: MultiMeshInstance3D, opts: Dictionary) -> void:
	if not is_instance_valid(mmi) or not mmi.is_inside_tree():
		return
	mmi.get_tree().create_timer(randf_range(2.0, 4.0), false).timeout.connect(func():
		if not is_instance_valid(mmi) or not mmi.is_inside_tree():
			return
		var base: Array = mmi.get_meta("vary_base", [])
		var busy: Dictionary = mmi.get_meta("vary_busy", {})
		var n := mini(int(opts.get("max_mm", 6)), maxi(1, base.size() / 4))
		var turn: float = opts.get("turn", 0.25)
		for k in n:
			var i := randi() % base.size()
			if busy.has(i):
				continue
			busy[i] = true
			var b0: Transform3D = base[i]
			var a := randf_range(-turn, turn)
			var tw := mmi.create_tween()
			var put := func(v: float) -> void:
				if is_instance_valid(mmi) and i < mmi.multimesh.instance_count:
					mmi.multimesh.set_instance_transform(i, Transform3D(Basis(Vector3.UP, v) * b0.basis, b0.origin))
			tw.tween_method(put, 0.0, a, 0.8).set_trans(Tween.TRANS_SINE)
			tw.tween_interval(randf_range(1.5, 4.0))
			tw.tween_method(put, a, 0.0, 0.9).set_trans(Tween.TRANS_SINE)
			tw.tween_callback(func(): busy.erase(i))
		mmi.set_meta("vary_busy", busy)
		_vary_mm_next(mmi, opts))


## Olay anı (bağırış, patlama, içeri giren Sultan): herkes 0..max_delay sn gecikmeyle target'a döner (look_target);
## seconds > 0 ise o kadar sonra eski bakışına döner. İş yapanlar (alet işi, grip_hold) gövdelerini çevirmez (Stage.gaze_dir),
## uyuyan/yatan dönmez. Örnek: Crowd.look_at_event(kalabalik, fatih, 4.0)
static func look_at_event(people: Array, target: Node3D, seconds := 0.0, max_delay := 1.5) -> void:
	for w in people:
		if not (w is Node3D) or not is_instance_valid(w) or not (w as Node3D).is_inside_tree() or not ("look_target" in w):
			continue
		var act = w.get("activity")
		if act is String and act in ["sleep", "lie", "doze", "swim"]:
			continue      # uyuyan, yatan, yüzen olaya dönmez
		var old = w.get("look_target")
		(w as Node3D).get_tree().create_timer(randf_range(0.0, max_delay), false).timeout.connect(func():
			if is_instance_valid(w) and is_instance_valid(target):
				w.set("look_target", target)
				if seconds > 0.0:
					(w as Node3D).get_tree().create_timer(seconds, false).timeout.connect(func():
						if is_instance_valid(w) and w.get("look_target") == target:
							w.set("look_target", old if is_instance_valid(old) else null)))
