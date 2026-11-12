extends Node
## Otağın kapı dilimi pişiricisi (G2, tek harita). Gerçek ordugâhı (CampDay, in_world: World1453 "camp" bölgesi, gündüz)
## kurar; otağ salonunun (OtagHall) kapısından görülebilen yarım düzlemi salonun yerel koordinatına çevirir, güneşi,
## gök ortam ışığını ve sisi köşe rengine yazar (ışıksız malzeme: salonun kendi ışığı ve ortamı dışarıyı boyamaz),
## kalabalığı (insan, asker, bölük, yürüyen) atar ve tek bir paket sahnede saklar:
##   res://assets/data/otag_door_day.scn
## Salon (OtagHall._build_door_view) bunu yükler: dünya içerideyken kurulmaz, yalnız kapıdan görülen dilim, birleşik.
## Kullanım (ekranlı: başsız sunucu MultiMesh dönüşümlerini/renklerini ve dokuları saklamaz):
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . res://tests/otag_door_bake.tscn [-- --inventory]
## Dünya (CampDay, SiegeField, HornWorld, Landmarks) değişince yeniden çalıştırılır.

const OUT := "res://assets/data/otag_door_day.scn"
## Kapının önü (salon yereli): kapı düzlemi z ≈ 8,8; göz yüksekliği
const DOOR := Vector3(0.0, 1.6, 9.0)
const MAX_D := 900.0             # sis bu uzaklıkta %97: ötesi gökle aynı renk
const NEAR_ANGLE := 82.0         # kapının hemen içinden (giriş, z 7,8) bakınca yarım düzlem görünür
const FAR_ANGLE := 50.0          # 160 m ötesi: geniş açıyla yalnız kapının dibinden görülür
const FAR_FROM := 160.0
## Salonun kendi gövdesi ve dünyadaki otağın kabuğu (yarıçap 7, kapı saçağı z 7–9,8) dilime girmez
const HALL_R := 10.6
## Kamp sahnesinin ışığı (CampDay._build_sky ile aynı)
const SUN_ROT := Vector3(-42.0, 150.0, 0.0)
const SUN_COL := Color("ffe9c7")
const SUN_E := 1.25
const SKY_TOP := Color("3a7fc4")
const SKY_HOR := Color("c4dceb")
const GND_HOR := Color("cfc4aa")
const AMB_E := 0.55
const FOG_COL := Color("c7d7e4")
const FOG_D := 0.004

const SKIP_CLASSES := ["Person", "Soldier", "Hikmet", "Player", "CityLife", "PoseCrew", "Crowd", "Walker", "Horse", "Ox",
	"Goat", "Chicken", "Cat", "Gulls", "ThiefGull", "WallCrowd", "NightArmy", "Garrison", "CannonCrew"]

var inventory := false
var _sun_col := SUN_COL
var _sun_e := SUN_E
var _amb_e := AMB_E
var _fog_d := FOG_D
var _fog_col := FOG_COL
var _exposure := 0.88
var _tex_avg := {}
var _stats := {}


func _ready() -> void:
	inventory = "--inventory" in OS.get_cmdline_user_args()
	GameState.autotest = false
	var t0 := Time.get_ticks_msec()
	var camp := CampDay.new()
	add_child(camp)
	# Dünya ve dekor karelere yayılarak katılaşır/kurulur: birkaç saniye bekle
	for i in 90:
		await get_tree().process_frame
	print("BAKE camp built %d ms" % (Time.get_ticks_msec() - t0))
	# Salon yereli -> kamp sahnesi (CampDay kökü dünyanın "camp" bölgesinin yerelidir)
	var to_camp: Transform3D = World1453.region("camp").affine_inverse() * World1453.region("otag")
	var to_hall := to_camp.affine_inverse()
	print("BAKE otag(hall 0) in camp local = ", to_camp.origin, "  world = ", World1453.region("otag").origin)
	var sun_dir := -(Basis.from_euler(SUN_ROT * (PI / 180.0)).z)       # ışığın gittiği yön
	# Sahnedeki gerçek güneş ve ortam (CampDay._build_sky): sabitler yalnız yedek
	var suns := camp.find_children("*", "DirectionalLight3D", true, false)
	if not suns.is_empty():
		var sl := suns[0] as DirectionalLight3D
		sun_dir = -sl.global_transform.basis.z
		_sun_col = sl.light_color
		_sun_e = sl.light_energy
	var envs := camp.find_children("*", "WorldEnvironment", true, false)
	if not envs.is_empty():
		var e := (envs[0] as WorldEnvironment).environment
		_amb_e = e.ambient_light_energy
		_fog_d = e.fog_density if e.fog_enabled else 0.0
		_fog_col = e.fog_light_color
		_exposure = e.tonemap_exposure
	print("BAKE sun dir=%s col=%s e=%.2f amb=%.2f fog=%.4f exp=%.2f" % [sun_dir, _sun_col, _sun_e, _amb_e, _fog_d, _exposure])
	sun_dir = (to_hall.basis * sun_dir).normalized()
	var to_sun := -sun_dir
	# Parçalar: yakın ve orta bant üç açı diliminde (sol, orta, sağ), uzak tek: görmeyen kamera (Sultan'a, yan
	# duvarlara bakış) parçanın sınır kutusunu kesmez, çizmez
	var bands: Array = []
	for i in PART_NAMES.size():
		var b := SurfaceTool.new()
		b.begin(Mesh.PRIMITIVE_TRIANGLES)
		bands.append(b)
	var tris := [0, 0, 0]
	# Kalabalık (Crowd.scatter: yakın figürler ve uzak ikizleri) dilime girmez
	for n in camp.find_children("*", "MultiMeshInstance3D", true, false):
		if n.has_meta("crowd_spec"):
			n.set_meta("no_bake", true)
			var tw = n.get_meta("crowd_twin", null)
			if tw is Node:
				(tw as Node).set_meta("no_bake", true)
	var stack: Array = [camp]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if _skip(n):
			continue
		stack.append_array(n.get_children())
		if not (n is GeometryInstance3D) or not (n as Node3D).is_visible_in_tree():
			continue
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if mi.mesh:
				_emit(mi.mesh, [to_hall * mi.global_transform], mi.material_override, mi, bands, tris, to_sun)
		elif n is MultiMeshInstance3D:
			var mmi := n as MultiMeshInstance3D
			var mm := mmi.multimesh
			if mm == null or mm.mesh == null:
				continue
			var xfs: Array = []
			var cnt := mm.visible_instance_count if mm.visible_instance_count >= 0 else mm.instance_count
			var meta: Array = mmi.get_meta("xforms", [])
			for k in cnt:
				var ix: Transform3D = meta[k] if meta.size() == mm.instance_count else mm.get_instance_transform(k)
				xfs.append(to_hall * mmi.global_transform * ix)
			_emit(mm.mesh, xfs, mmi.material_override, mmi, bands, tris, to_sun, mm)
	if inventory:
		var keys := _stats.keys()
		keys.sort_custom(func(a, b): return int(_stats[a][2]) > int(_stats[b][2]))
		for k in keys.slice(0, 80):
			print("INV %-70s inst=%d tris=%d far=%d" % [k, _stats[k][0], _stats[k][1], _stats[k][2]])
	print("BAKE tris near=%d mid=%d far=%d parts=%s" % [tris[0], tris[1], tris[2], _part_tris])
	if inventory:
		get_tree().quit()
		return
	var root := Node3D.new()
	root.name = "OtagDoorDay"
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for i in PART_NAMES.size():
		if _part_tris[i] == 0:
			continue
		var s: SurfaceTool = bands[i]
		s.index()
		var mesh := s.commit()
		var out := MeshInstance3D.new()
		out.name = PART_NAMES[i]
		out.mesh = mesh
		out.material_override = mat
		out.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(out)
		out.owner = root
	var sky := _sky_dome(to_sun)
	root.add_child(sky)
	sky.owner = root
	sky.material_override = mat
	var ps := PackedScene.new()
	ps.pack(root)
	var err := ResourceSaver.save(ps, OUT, ResourceSaver.FLAG_COMPRESS)
	print("BAKE saved %s err=%d total %d ms" % [OUT, err, Time.get_ticks_msec() - t0])
	get_tree().quit()


func _skip(n: Node) -> bool:
	if n is CharacterBody3D or n is CPUParticles3D or n is GPUParticles3D or n is Light3D or n is Label3D:
		return true
	var s := n.get_script() as Script
	if s and s.get_global_name() in SKIP_CLASSES:
		return true
	return n.has_meta("no_bake")


func _owner_tag(n: Node) -> String:
	var a := n
	var parts := PackedStringArray()
	while a and parts.size() < 3:
		var s := a.get_script() as Script
		if s and s.get_global_name() != "":
			parts.append(s.get_global_name())
		a = a.get_parent()
	return "%s/%s" % ["<".join(parts), n.name.left(24)]


## Bir ağın üçgenlerini (her dönüşüm için) dilime süzer, aydınlatıp sisleyip banda yazar
func _emit(mesh: Mesh, xfs: Array, override: Material, gi: GeometryInstance3D, bands: Array, tris: Array, to_sun: Vector3,
		mm: MultiMesh = null) -> void:
	var tpi := 0
	if mesh is ArrayMesh:
		for si in mesh.get_surface_count():
			var am := mesh as ArrayMesh
			tpi += am.surface_get_array_index_len(si) / 3 if am.surface_get_array_index_len(si) > 0 else am.surface_get_array_len(si) / 3
	var key := "%s %s tpi=%d sz=%.1f vr=%.0f-%.0f" % [_owner_tag(gi), mesh.resource_name.left(20), tpi, mesh.get_aabb().size.length(), gi.visibility_range_begin, gi.visibility_range_end]
	if not _stats.has(key):
		_stats[key] = [0, 0, 0]
	_stats[key][0] = int(_stats[key][0]) + xfs.size()
	var laabb := mesh.get_aabb()
	for si in mesh.get_surface_count():
		var mat := override if override else mesh.surface_get_material(si)
		if gi is MeshInstance3D and (gi as MeshInstance3D).get_surface_override_material(si):
			mat = (gi as MeshInstance3D).get_surface_override_material(si)
		var base := _base_color(mat)
		if base.a < 0.0:
			continue                          # saydam/ışıyan: dilime girmez (duman, hale)
		# Arazi gölgelendiricisi (ground.gdshader) köşe rengini lekelerle kırar: ortalamada yeşil/doygunluk düşer
		var ground := mat is ShaderMaterial and (mat as ShaderMaterial).shader and (mat as ShaderMaterial).shader.resource_path.ends_with("ground.gdshader")
		var unshaded := mat is BaseMaterial3D and (mat as BaseMaterial3D).shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED
		var use_vc := mat is BaseMaterial3D and (mat as BaseMaterial3D).vertex_color_use_as_albedo
		if mat == null or mat is ShaderMaterial:
			use_vc = true
		# Köşe ve örnek rengi: Compatibility çizicisi köşe rengini her zaman sRGB sayıp doğrusala çevirir
		# (ground.gdshader'daki not; vertex_color_is_srgb ile aynı sonuç)
		var vc_srgb := true
		# Godot toon yayılımı: smoothstep(−pürüzlülük, pürüzlülük, N·L) (pürüzlülük 1: güneşe dik yüz yarı ışıkta)
		var toon := -1.0
		if mat is BaseMaterial3D and (mat as BaseMaterial3D).diffuse_mode == BaseMaterial3D.DIFFUSE_TOON:
			toon = maxf((mat as BaseMaterial3D).roughness, 0.01)
		var lod := _lods(mesh, si)
		var arr: Array = lod[0]
		var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var cols = arr[Mesh.ARRAY_COLOR]
		for xi in xfs.size():
			var xf: Transform3D = xfs[xi]
			# Nesne süzgeci: kutusu dilimin dışındaysa ya da uzaklığına göre çok küçükse
			var wa: AABB = xf * laabb
			var c := wa.get_center()
			var dc := Vector2(c.x - DOOR.x, c.z - DOOR.z).length()
			var big := wa.size.length()
			if wa.end.z < DOOR.z - 0.4 and big < 200.0:
				continue
			if dc - big * 0.5 > MAX_D:
				continue
			if big < 200.0 and big < (dc - 30.0) * 0.006:
				continue
			# Oyunun kendi ayrıntı katmanları: kapıdan bu uzaklıkta görünmeyen katman dilime girmez
			if gi.visibility_range_end > 0.0 and dc - big * 0.5 > gi.visibility_range_end:
				continue
			if gi.visibility_range_begin > 0.0 and dc + big * 0.5 < gi.visibility_range_begin:
				continue
			# Uzaklığa göre ayrıntı: yakın tam, orta yarı, uzak en sade (sis zaten siler)
			var lods: Array = lod[1]
			var li := clampi(int(floor(log(maxf(dc, 1.0) / 16.0) / log(2.0))) + 1, 0, lods.size() - 1)
			if dc > FAR_FROM:
				li = lods.size() - 1
			var idx: PackedInt32Array = lods[li]
			var count := idx.size()
			var mc := Color.WHITE
			if mm and mm.use_colors:
				mc = mm.get_instance_color(xi)        # örnek rengi çevrilmeden çarpılır (karşılaştırmada çadırlar böyle)
			var j := 0
			while j + 2 < count:
				var i0: int = idx[j]
				var i1: int = idx[j + 1]
				var i2: int = idx[j + 2]
				j += 3
				var a: Vector3 = xf * verts[i0]
				var b: Vector3 = xf * verts[i1]
				var d: Vector3 = xf * verts[i2]
				var band := _band((a + b + d) / 3.0)
				if band < 0:
					continue
				if _behind_walls(a, b, d):
					continue
				var nrm := (d - a).cross(b - a)          # Godot: ön yüz saat yönünde
				if nrm.length_squared() < 1e-12:
					continue
				nrm = nrm.normalized()
				# Kapıdan görülen yüz: arka yüzü görünen ince parça (sancak, perde) Godot'daki gibi çevrilmiş normalle ışır
				if nrm.dot(DOOR - (a + b + d) / 3.0) < 0.0:
					nrm = -nrm
				tris[band] = int(tris[band]) + 1
				_stats[key][1] = int(_stats[key][1]) + 1
				if band == 2:
					_stats[key][2] = int(_stats[key][2]) + 1
				if inventory:
					continue
				var ps: Array = [a, b, d]
				var cs: Array = []
				for q in 3:
					var vi: int = [i0, i1, i2][q]
					var col := base * mc
					if use_vc and cols != null and (cols as PackedColorArray).size() > vi:
						var vc: Color = (cols as PackedColorArray)[vi]
						col = col * (vc.srgb_to_linear() if vc_srgb else vc)
					if ground:
						var lum := col.get_luminance()
						col = col.lerp(Color(lum, lum, lum), 0.1) * 0.7
					cs.append(_shade(col, nrm, ps[q], to_sun, unshaded, toon))
				var part := _part(band, (a + b + d) / 3.0)
				_put(bands[part], ps, cs, part)


## Yüzeyin dizinli köşeleri ve ayrıntı katmanları: [diziler, [tam dizin, LOD1, ...]] (meshoptimizer, ImporterMesh)
var _lod_cache := {}
func _lods(mesh: Mesh, si: int) -> Array:
	var key := "%d|%d" % [mesh.get_instance_id(), si]
	if _lod_cache.has(key):
		return _lod_cache[key]
	var arr := mesh.surface_get_arrays(si)
	var idx = arr[Mesh.ARRAY_INDEX]
	if idx == null or (idx as PackedInt32Array).is_empty():
		var st := SurfaceTool.new()
		st.create_from_arrays(arr)
		st.index()
		arr = st.commit_to_arrays()
		idx = arr[Mesh.ARRAY_INDEX]
	var out: Array = [idx]
	if (idx as PackedInt32Array).size() >= 90:
		var im := ImporterMesh.new()
		im.add_surface(Mesh.PRIMITIVE_TRIANGLES, arr)
		im.generate_lods(25.0, 60.0, [])
		for k in im.get_surface_lod_count(0):
			var li := im.get_surface_lod_indices(0, k)
			if li.size() >= 18:
				out.append(li)
	var res := [arr, out]
	_lod_cache[key] = res
	return res


const PART_NAMES := ["NearL", "NearC", "NearR", "MidL", "MidC", "MidR", "Far"]
## Kapı çizgisinin gerisi (salonun yanları ve arkası) kırpılır: büyük arazi üçgenleri parçanın kutusunu salonun
## arkasına uzatmasın (Sultan'a bakan kamera da çizerdi)
const CLIP_Z := 7.0
const SECTOR := 28.0             # orta dilimin yarı açısı (°)
var _part_tris := [0, 0, 0, 0, 0, 0, 0]


func _part(band: int, c: Vector3) -> int:
	if band == 2:
		return 6
	var ang := rad_to_deg(atan2(c.x - DOOR.x, maxf(c.z - DOOR.z, 0.001)))
	var sec := 1 if absf(ang) <= SECTOR else (0 if ang > 0.0 else 2)
	return band * 3 + sec


## Üçgeni z ≥ CLIP_Z yarı uzayına kırpar (renk doğrusal ara değerle), yelpaze üçgenleriyle yazar
func _put(st: SurfaceTool, ps: Array, cs: Array, part: int) -> void:
	var inside := 0
	for p: Vector3 in ps:
		if p.z >= CLIP_Z:
			inside += 1
	if inside == 0:
		return
	var poly_p: Array = ps
	var poly_c: Array = cs
	if inside < 3:
		poly_p = []
		poly_c = []
		for i in 3:
			var p0: Vector3 = ps[i]
			var p1: Vector3 = ps[(i + 1) % 3]
			var c0: Color = cs[i]
			var c1: Color = cs[(i + 1) % 3]
			var in0 := p0.z >= CLIP_Z
			var in1 := p1.z >= CLIP_Z
			if in0:
				poly_p.append(p0)
				poly_c.append(c0)
			if in0 != in1:
				var t := (CLIP_Z - p0.z) / (p1.z - p0.z)
				poly_p.append(p0.lerp(p1, t))
				poly_c.append(c0.lerp(c1, t))
	for k in range(1, poly_p.size() - 1):
		for v in [0, k, k + 1]:
			st.set_color(poly_c[v])
			st.add_vertex(poly_p[v])
		_part_tris[part] = int(_part_tris[part]) + 1


## Üçgen merkezine göre bant: -1 dilim dışı, 0 yakın (<60 m), 1 orta (<FAR_FROM), 2 uzak
func _band(p: Vector3) -> int:
	if Vector2(p.x, p.z).length() < HALL_R:
		return -1
	if p.z < DOOR.z - 0.3:
		return -1
	var dz := p.z - DOOR.z
	var d := Vector2(p.x - DOOR.x, dz).length()
	if d > MAX_D:
		return -1
	var ang := rad_to_deg(atan2(absf(p.x), maxf(dz, 0.001)))
	if ang > (NEAR_ANGLE if d < FAR_FROM else FAR_ANGLE):
		return -1
	return 0 if d < 60.0 else (1 if d < FAR_FROM else 2)


## Kara surlarının (iç sur tepesi 12 m, dünya z ≈ −2) ardında, kapıdaki gözden görüş çizgisinin altında kalan üçgen
## (şehrin döşemesi, çarşısı): görünmez. Salon yerelinde sur z ≈ 482.
const WALL_LOCAL_Z := 482.0
const WALL_TOP := 12.0
func _behind_walls(a: Vector3, b: Vector3, d: Vector3) -> bool:
	var zmin := minf(a.z, minf(b.z, d.z))
	if zmin < WALL_LOCAL_Z + 2.0:
		return false
	var ytop := maxf(a.y, maxf(b.y, d.y))
	var dist := Vector2((a.x + b.x + d.x) / 3.0 - DOOR.x, zmin - DOOR.z).length()
	var dw := WALL_LOCAL_Z - DOOR.z
	return ytop < DOOR.y + (WALL_TOP - 0.5 - DOOR.y) * dist / dw


## Malzemenin temel rengi (doğrusal). a < 0: dilime girmez
func _base_color(mat: Material) -> Color:
	if mat == null:
		return Color(0.8, 0.8, 0.8)
	if mat is BaseMaterial3D:
		var m := mat as BaseMaterial3D
		if m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and m.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR:
			return Color(0, 0, 0, -1)
		if m.emission_enabled and m.emission_energy_multiplier > 0.5:
			return Color(0, 0, 0, -1)
		var c := m.albedo_color
		if m.albedo_texture:
			c = c * _avg(m.albedo_texture)
		return c.srgb_to_linear()
	if mat is ShaderMaterial:
		var sm := mat as ShaderMaterial
		for p in ["albedo", "color", "base_color", "tint"]:
			var v = sm.get_shader_parameter(p)
			if v is Color:
				return (v as Color).srgb_to_linear()
		return Color(1, 1, 1)
	return Color(0.8, 0.8, 0.8)


func _avg(t: Texture2D) -> Color:
	if _tex_avg.has(t):
		return _tex_avg[t]
	var c := Color.WHITE
	var img := t.get_image()
	if img:
		if img.is_compressed():
			img.decompress()
		img.resize(1, 1, Image.INTERPOLATE_LANCZOS)
		c = img.get_pixel(0, 0)
		c.a = 1.0
	_tex_avg[t] = c
	return c


## Kamp sahnesinin ışığı: gök ortamı (yukarı bakan yüz göğü, aşağı bakan yeri görür) + güneş (yumuşak kademe) + sis
func _shade(col: Color, n: Vector3, p: Vector3, to_sun: Vector3, unshaded: bool, toon_r := -1.0) -> Color:
	var lit := col
	if not unshaded:
		var up := clampf(n.y * 0.5 + 0.5, 0.0, 1.0)
		var sky := SKY_HOR.srgb_to_linear().lerp(SKY_TOP.srgb_to_linear(), 0.15)
		var amb := GND_HOR.srgb_to_linear().lerp(sky, up) * _amb_e
		var ndl := n.dot(to_sun)
		var k := smoothstep(-toon_r, toon_r, ndl) if toon_r > 0.0 else maxf(ndl, 0.0)
		var l := amb + _sun_col.srgb_to_linear() * _sun_e * k
		lit = Color(col.r * l.r, col.g * l.g, col.b * l.b)
	var d := Vector2(p.x - DOOR.x, p.z - DOOR.z).length()
	var f := 1.0 - exp(-_fog_d * d)
	lit = lit.lerp(_fog_col.srgb_to_linear(), clampf(f, 0.0, 1.0))
	lit = lit * _exposure
	lit.a = 1.0
	return lit.linear_to_srgb()        # çizici köşe rengini sRGB'den doğrusala çevirir


## Kapının önündeki gök (yarım kubbe, MAX_D'nin ötesinde): ufukta sis rengi, tepeye doğru gök mavisi
func _sky_dome(to_sun: Vector3) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r := MAX_D + 40.0
	var seg := 24
	var rings := 10
	var pt := func(i: int, k: int) -> Vector3:
		var az := deg_to_rad(-88.0 + 176.0 * i / seg)       # kutusu kapı çizgisinin önünde kalır (z ≥ 9)
		var el := deg_to_rad(-6.0 + 96.0 * k / rings)
		return DOOR + Vector3(sin(az) * cos(el) * r, sin(el) * r, cos(az) * cos(el) * r)
	var colf := func(p: Vector3) -> Color:
		# ProceduralSkyMaterial: c = 1 − açı/90°, gök = mix(ufuk, tepe, 1 − (1 − c)^(1/sky_curve)), sky_curve 0,15
		var el := asin(clampf((p.y - DOOR.y) / r, -1.0, 1.0))
		var c := FOG_COL.srgb_to_linear()
		if el > 0.0:
			var cc := el / (PI * 0.5)
			var t := clampf(1.0 - pow(1.0 - cc, 1.0 / 0.15), 0.0, 1.0)
			c = SKY_HOR.srgb_to_linear().lerp(SKY_TOP.srgb_to_linear(), t) * 0.95
			c = c.lerp(FOG_COL.srgb_to_linear(), 0.35 * (1.0 - smoothstep(0.0, 0.12, cc)))     # ufukta sis
		c = c * _exposure
		c.a = 1.0
		return c.linear_to_srgb()
	for i in seg:
		for k in rings:
			var q := [pt.call(i, k), pt.call(i + 1, k), pt.call(i + 1, k + 1), pt.call(i, k + 1)]
			for t in [[0, 1, 2], [0, 2, 3]]:
				for v in t:
					st.set_color(colf.call(q[v]))
					st.add_vertex(q[v])
	var mi := MeshInstance3D.new()
	mi.name = "Sky"
	mi.mesh = st.commit()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi
