extends RefCounted
## İstanbul v2 DOKU-4: GECE UZAK IŞIKLAR (class_name yok; IstHayat preload eder, yalnız gece kurulur).
## Galata'dan ve uçuştan bakınca şehir karanlık kalıyordu: yakın katmanın pencere dörtgenleri 450 m'de, alevler 800 m'de,
## haleler 1 000 m'de biter. Bu katman ışık KAYNAĞI değil: ekranda sabit piksel boyunda ışıyan noktalar (tek MultiMesh,
## tek çizim, gölgelendiricide billboard + uzaklığa göre belirme). 280–420 m arasında yavaşça belirir (yakında gerçek
## pencere/alev görünür), 6 km'ye kadar sürer.
##   pencere: yaşam katmanının gece pencereleri + evlerin bir kısmı (sık dokuda daha çok), sıcak sarı, 2 px
##   kandil/meşale/ateş haleleri: yaşam katmanının "parilti" kayıtları, turuncu, 3–4 px
##   surlarda nöbet ateşleri: kara suru ~45 m'de bir (kule ve beden üstü), deniz surları ~70 m'de bir, Galata suru
##   ordugâh: ordugâh yerlerinin çevresinde kamp ateşleri (ORDUGÂH-4'ün yakın ateşleriyle aynı yerde değil: yalnız uzak nokta)

const SHADER := """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled, skip_vertex_transform, shadows_disabled;
uniform float px_birim = 0.0022;   // 1 px'in 1 m uzaklıktaki boyu (720 satır, ~75° görüş)
uniform float bel0 = 280.0;
uniform float bel1 = 420.0;
uniform float son = 6000.0;
varying vec4 renk;
varying float sol;
void vertex() {
	vec3 o = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float d = length(o - CAMERA_POSITION_WORLD);
	float boy = COLOR.a * 8.0 * px_birim * d;
	vec3 sag = INV_VIEW_MATRIX[0].xyz;
	vec3 yuk = INV_VIEW_MATRIX[1].xyz;
	vec3 w = o + (sag * VERTEX.x + yuk * VERTEX.y) * boy;
	VERTEX = (VIEW_MATRIX * vec4(w, 1.0)).xyz;
	renk = vec4(COLOR.rgb, 1.0);
	sol = smoothstep(bel0, bel1, d) * (1.0 - smoothstep(son * 0.8, son, d));
}
void fragment() {
	float r = length(UV - vec2(0.5)) * 2.0;
	float a = (1.0 - smoothstep(0.35, 1.0, r)) * sol;
	ALBEDO = renk.rgb * a;
}
"""

const ORAN := {"carsi": 0.42, "liman": 0.38, "sik": 0.34, "sur_dibi": 0.3}
const R_PENCERE := Color(1.0, 0.72, 0.34)
const R_ATES := Color(1.0, 0.52, 0.16)


static func kur(parent: Node3D, K: Dictionary, sokak: IstSokak) -> Dictionary:
	var t0 := Time.get_ticks_msec()
	var xs: Array = []          # [Vector3, Color(rgb, boy/8)]
	var say := {"pencere": 0, "hale": 0, "sur": 0, "ordu": 0}
	# 1. yaşam katmanının gece kayıtları
	for ad: String in ["pencere", "parilti"]:
		var kt: IstHayatKatman = K.get(ad)
		if kt == null:
			continue
		for key: Vector2i in kt.cells:
			var a: PackedFloat32Array = kt.cells[key]
			var i := 0
			while i + 11 < a.size():
				var p := Vector3(a[i + 3], a[i + 7], a[i + 11])
				if ad == "pencere":
					xs.append([p, Color(R_PENCERE.r, R_PENCERE.g, R_PENCERE.b, 0.26)])
					say["pencere"] += 1
				else:
					xs.append([p, Color(R_ATES.r, R_ATES.g, R_ATES.b, 0.42)])
					say["hale"] += 1
				i += kt.stride
	# 2. evlerin bir kısmında yanan pencere (yakın katmanın pencere kaydı olmayanlar da uzaktan seçilsin)
	if sokak != null:
		var n := 0
		for h: Dictionary in sokak.houses:
			n += 1
			var c: Vector2 = h["c"]
			var on: Vector2 = h["on"]
			var oran := float(ORAN.get(String(sokak._mah(c).get("tur", "")), 0.18))
			if float((n * 7919 + 13) % 1000) / 1000.0 > oran:
				continue
			var dm := IstEvler.dims(int(h["v"]))
			var dis := (on - c).normalized()
			var yan := Vector2(-dis.y, dis.x) * (float((n * 31) % 5) - 2.0) / 5.0 * dm.x * 0.6
			var q := on + dis * 0.8 + yan
			var y := IstGeo.h(on.x, on.y) + clampf(dm.y - 1.6, 1.6, 7.0)
			xs.append([Vector3(q.x, y, q.y), Color(R_PENCERE.r, R_PENCERE.g * (0.92 + 0.08 * float(n % 3)), R_PENCERE.b, 0.24)])
			say["pencere"] += 1
	# 3. surlarda nöbet ateşleri (beden üstü, yürüme yolu + 1,2 m)
	for hat: Array in [["kara_suru", "kara", 45.0], ["blakherna_suru", "blakherna", 45.0], ["marmara_suru", "marmara", 70.0],
			["halic_suru", "halic", 70.0], ["galata_suru", "galata", 60.0]]:
		var pl := IstGeo.yol(String(hat[0]))
		if pl.size() < 2:
			continue
		var hy := IstSehir._walk_h(String(hat[1])) if String(hat[1]) != "galata" else 10.0
		for p: Vector2 in nokta_dizisi(pl, float(hat[2])):
			xs.append([Vector3(p.x, IstGeo.h(p.x, p.y) + hy + 1.2, p.y), Color(R_ATES.r, R_ATES.g, R_ATES.b, 0.5)])
			say["sur"] += 1
	# 4. ordugâh: kamp ateşleri (yerin çevresinde dağınık)
	var rng := RandomNumberGenerator.new()
	rng.seed = 14530529
	for y: Dictionary in IstGeo.yerler():
		if String(y["tur"]) != "ordugah":
			continue
		var w: Vector3 = y["w"]
		var c := Vector2(w.x, w.z)
		var buyuk := String(y["ad"]).contains("otağı")
		for i in (60 if buyuk else 34):
			var p := c + Vector2.from_angle(rng.randf() * TAU) * (8.0 + sqrt(rng.randf()) * (190.0 if buyuk else 130.0))
			if IstGeo.su(p.x, p.y) or IstGeo.sehir_ici(p.x, p.y) or IstGeo.galata_ici(p.x, p.y):
				continue
			xs.append([Vector3(p.x, IstGeo.h(p.x, p.y) + 1.0, p.y), Color(R_ATES.r, R_ATES.g * rng.randf_range(0.85, 1.1), R_ATES.b, rng.randf_range(0.38, 0.55))])
			say["ordu"] += 1
	if xs.is_empty():
		return say
	var q := QuadMesh.new()
	q.size = Vector2(1, 1)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = q
	mm.instance_count = xs.size()
	for i in xs.size():
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, xs[i][0]))
		mm.set_instance_color(i, xs[i][1])
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER
	mat.shader = sh
	var mi := MultiMeshInstance3D.new()
	mi.name = "UzakIsiklar"
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.custom_aabb = AABB(Vector3(-8000, -300, -8000), Vector3(16000, 1200, 16000))
	mi.set_meta("no_walk", true)
	mi.set_meta("soft", true)
	parent.add_child(mi)
	say["toplam"] = xs.size()
	say["ms"] = Time.get_ticks_msec() - t0
	return say


static func nokta_dizisi(pl: PackedVector2Array, adim: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var acc := adim * 0.5
	for i in pl.size() - 1:
		var a := pl[i]
		var b := pl[i + 1]
		var L := a.distance_to(b)
		while acc < L:
			out.append(a.lerp(b, acc / L))
			acc += adim
		acc -= L
	return out
