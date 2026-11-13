extends RefCounted
## TUR-7: sur kuşağının GÖRÜNÜŞÜ (çarpışmasız). Kesim sahnesinin (SurOyun.kur) zemin levhaları şehirdeki zemin kitaplığına
## (zemin_v2 gölgelendiricisi: köşe rengi + köşe alfası = çıplaklık; aynı palet OTURTMA R_*) çekilir: yamalı (kuru ot,
## çıplak toprak, çamur lekesi), sura doğru taş tozu ve çıplak toprak, hafif engebe (yürüme yüksekliği AYNI: çarpışma
## kutusu yerinde; görünen yüz ±5 cm), yer örtüsü (ot tutamı, düşmüş taş) tek MultiMesh'lerde; levhanın ucunda ufka
## doğru alçak tepelerle uzanan görünen arazi (düz ova kenarı gökyüzüne kesilmesin).
## Çağıran: gorsel_dil.gd kur() (SurOyun_* kökü bulunca). class_name YOK.

const OTURTMA := preload("res://scripts/world/ist/sur_oturtma.gd")
const OTAG := preload("res://scripts/world/ist/sur_oturtma_ag.gd")

static var _ot_m: Material


static func _h(a: int, b: int) -> float:
	var h := (a * 73856093) ^ (b * 19349663)
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return float(h & 0xffff) / 65535.0


## Değer gürültüsü (0..1), ölçek s m
static func gn(x: float, z: float, s: float, t := 0) -> float:
	var fx := x / s
	var fz := z / s
	var i := floori(fx)
	var j := floori(fz)
	var u := fx - i
	var v := fz - j
	u = u * u * (3.0 - 2.0 * u)
	v = v * v * (3.0 - 2.0 * v)
	var a := _h(i + t * 911, j)
	var b := _h(i + 1 + t * 911, j)
	var c := _h(i + t * 911, j + 1)
	var d := _h(i + 1 + t * 911, j + 1)
	return lerpf(lerpf(a, b, u), lerpf(c, d, u), v)


## Zemin rengi ve çıplaklık: w = surun en yakın yüzüne uzaklık (m). Döner [renk, çıplaklık 0..1]
static func zemin_renk(x: float, z: float, w: float) -> Array:
	var n1 := gn(x, z, 23.0, 1) * 0.65 + gn(x, z, 7.0, 2) * 0.35
	var n2 := gn(x, z, 11.0, 3)
	var n3 := gn(x, z, 3.1, 4)
	var col := OTURTMA.R_TOPRAK.lerp(OTURTMA.R_OT, clampf(0.15 + (n1 - 0.35) * 1.6, 0.0, 0.85))
	col = col.lerp(OTURTMA.R_OT2, clampf((n2 - 0.55) * 2.2, 0.0, 0.55))
	# kuru ot yamaları (saman sarısı) ve çıplak toprak adaları
	col = col.lerp(Color("a6926e"), clampf((gn(x, z, 17.0, 5) - 0.6) * 2.6, 0.0, 0.7))
	var cp := clampf(0.8 - (n1 - 0.5) * 2.2 + (n3 - 0.5) * 0.35, 0.12, 0.97)
	# çıplak yerde toprak rengi baskın (ot rengi yalnız ot adasında)
	col = col.lerp(OTURTMA.R_TOPRAK.lerp(Color("a6926e"), n3 * 0.5), clampf((cp - 0.55) * 1.6, 0.0, 0.7))
	# sura doğru (0–7 m) taş tozu + çıplak toprak; 0–2 m ıslak koyu taban
	var t := clampf(1.0 - w / 7.0, 0.0, 1.0)
	t = t * t * (3.0 - 2.0 * t)
	col = col.lerp(OTURTMA.R_TOZ.lerp(OTURTMA.R_TOPRAK, n2 * 0.6), t * 0.8)
	cp = lerpf(cp, 0.95, t)
	var ts := clampf(1.0 - w / 2.2, 0.0, 1.0)
	col = col.lerp(OTURTMA.R_KOYU, ts * 0.5 * (0.6 + 0.4 * n3))
	if n2 > 0.74:
		col = col.lerp(OTURTMA.R_KOYU, (n2 - 0.74) * 2.2)
	return [col, cp]


## Kesim sahnesi: zemin levhalarını görünür zemin ağıyla değiştir (çarpışma kutuları aynen kalır, yalnız kutu ağı gizlenir);
## peribolos ve teras (dilimlerin "dirt" tabanı, pişmiş) üstüne 1,5 cm yukarıda aynı zemin
static func kesim_zemin(kok: Node3D) -> void:
	if kok.has_meta("tur7_zemin"):
		return
	kok.set_meta("tur7_zemin", true)
	var id := String(kok.name).trim_prefix("SurOyun_")
	var a: RefCounted = (load("res://scripts/world/ist/sur_oyun.gd") as GDScript).arayuz(id)
	var d: Dictionary = a.d
	var yuzler := [float(d["zi0"]), float(d["zi1"]), float(d["zo0"]), float(d["zo1"]), float(d["zm0"]), float(d["zm1"])]
	var ot: Array = []
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var xa := 0.0
	var xb := 0.0
	for n in kok.get_children():
		if not (n is StaticBody3D) or not String(n.name).begins_with("Toprak_Zemin"):
			continue
		var body := n as StaticBody3D
		var cs: CollisionShape3D = null
		for c in body.get_children():
			if c is CollisionShape3D:
				cs = c
			elif c is MeshInstance3D:
				(c as MeshInstance3D).visible = false
		if cs == null or not (cs.shape is BoxShape3D):
			continue
		var sz: Vector3 = (cs.shape as BoxShape3D).size
		var p := body.position
		var y := p.y + sz.y * 0.5
		xa = p.x - sz.x * 0.5
		xb = p.x + sz.x * 0.5
		var z0 := p.z - sz.z * 0.5
		var z1 := p.z + sz.z * 0.5
		var ova := z0 > 0.0
		_levha(st, xa, xb, z0, z1, y, 1 if ova else -1, yuzler, ot)
	if xb > xa:
		# TUR-7 (ikinci geçiş): 1,5 cm arayla alttaki "dirt" levhasıyla uzakta z-çakışması (gece testere dişli kenar,
		# dikdörtgen yamalar) yapıyordu: 4,5 cm yukarıda, engebe ±1,6 cm (yürüme yüksekliği yine ±5 cm içinde)
		_levha(st, xa, xb, float(d["zi1"]), float(d["zo0"]), -0.12 + 0.045, 0, yuzler, ot)
		_levha(st, xa, xb, float(d["zo1"]), float(d["zm0"]) - 0.9, a.dy - 0.12 + 0.045, 0, yuzler, ot)
	var mi := MeshInstance3D.new()
	mi.name = "Toprak_KesimZemin"
	mi.mesh = st.commit()
	mi.material_override = OTAG.etek_malzeme()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	kok.add_child(mi)
	_ortu(kok, ot)
	# TUR-7 (ikinci geçiş): oyun parçalarının toprak/moloz yığınları (hendek dolgusu, gedik moloz rampası, gedik seti) Props
	# "rubble" deseninde kiremit dama gibi okunuyordu: aynı zemin dilinde döküm toprak (otsuz, çiğnenmiş, köşe rengi yok)
	var rub: Texture2D = Props.mat(Color.WHITE, 0.0, false, "rubble").albedo_texture
	for n2 in kok.find_children("*", "MeshInstance3D", true, false):
		var m := n2 as MeshInstance3D
		if m.mesh == null or not String(m.get_path()).contains("OyunParcalari"):
			continue
		for si in m.mesh.get_surface_count():
			var sm := m.get_active_material(si) as StandardMaterial3D
			if sm != null and sm.albedo_texture == rub:
				m.set_surface_override_material(si, _moloz_mat(sm.albedo_color))
	# poterna kanadı: ahşap okunsun (gölgede griye kaçan koyu-soğuk kahve yerine sıcak meşe; tahta deseni)
	for n in kok.find_children("Ahsap_PoternaTahta", "MeshInstance3D", true, false):
		(n as MeshInstance3D).material_override = Props.mat(Color("8c6038"), 0.0, false, "wood")


static var _moloz: Dictionary = {}


## Döküm toprak / moloz: sur kuşağının zemin malzemesi (zemin_v2), ipucu = yığının rengi, ot yok, tam çiğnenmiş
static func _moloz_mat(c: Color) -> Material:
	var k := c.to_html()
	if not _moloz.has(k):
		var m: ShaderMaterial = (load("res://scripts/world/ist/sur_zemin.gd")._mat() as ShaderMaterial).duplicate()
		m.set_shader_parameter("ipucu", Color(c.r, c.g, c.b, 1.0).lerp(Color(0.62, 0.52, 0.40), 0.35))
		m.set_shader_parameter("ot_carpan", 0.08)
		m.set_shader_parameter("cignenme", 1.0)
		_moloz[k] = m
	return _moloz[k]


static func _uzak_sur(z: float, yuzler: Array) -> float:
	var w := INF
	for f: float in yuzler:
		w = minf(w, absf(z - f))
	return w


## Satır z'leri: sur yanındaki kenardan (yon +1: z0 kenarı, −1: z1 kenarı) 20 m boyunca 2,5 m, sonra 6 m, sonra 15 m
static func _satirlar(z0: float, z1: float, yon: int) -> Array:
	var out: Array = []
	var L := z1 - z0
	var t := 0.0
	while t < L:
		out.append(t)
		t += 2.5 if t < 20.0 else (6.0 if t < 70.0 else 15.0)
	out.append(L)
	var zs: Array = []
	for v: float in out:
		zs.append(z0 + v if yon >= 0 else z1 - v)
	zs.sort()
	return zs


## Görünen zemin ağı. uzat: +1 ova (levha ucundan ufka 1200 m alçak tepeler), −1 şehir (400 m), 0 yok (şerit).
static func _levha(st: SurfaceTool, x0: float, x1: float, z0: float, z1: float, y: float, uzat: int,
		yuzler: Array, ot: Array) -> void:
	var xs: Array = []
	if uzat != 0:
		for k in [-900.0, -450.0, -180.0]:
			xs.append(x0 + k)
	var nx := int(ceil((x1 - x0) / (2.5 if uzat == 0 else 4.0)))      # TUR-7: ince ızgara (8 m sütunlar dikdörtgen yama çiziyordu)
	for i in nx + 1:
		xs.append(lerpf(x0, x1, float(i) / nx))
	if uzat != 0:
		for k in [180.0, 450.0, 900.0]:
			xs.append(x1 + k)
	var zs: Array = []
	if uzat < 0:
		for k in [-400.0, -150.0, -50.0]:
			zs.append(z0 + k)
	zs.append_array(_satirlar(z0, z1, 1 if uzat >= 0 else -1))
	if uzat > 0:
		for k in [40.0, 120.0, 300.0, 600.0, 1200.0]:
			zs.append(z1 + k)
	var hy := func(x: float, z: float) -> float:
		# levha içinde ±4 cm (yürüme yüksekliği aynı); dışında uzaklıkla büyüyen alçak tepeler
		var dx := maxf(0.0, maxf(x0 - x, x - x1))
		var dz := maxf(0.0, maxf(z0 - z, z - z1))
		var dd := sqrt(dx * dx + dz * dz)
		var ic := (gn(x, z, 5.0, 7) - 0.5) * (0.08 if uzat != 0 else 0.032)
		if dd <= 0.0:
			return y + ic
		var tep := (gn(x, z, 180.0, 8) * 0.7 + gn(x, z, 60.0, 9) * 0.3) * minf(dd * 0.08, 28.0)
		return y + tep - minf(dd * 0.01, 2.0)
	var W := xs.size()
	var H := zs.size()
	var vs: Array = []
	var cs: Array = []
	for j in H:
		for i in W:
			var x: float = xs[i]
			var z: float = zs[j]
			var rc: Array = zemin_renk(x, z, _uzak_sur(z, yuzler))
			var c: Color = rc[0]
			c.a = 1.0 - float(rc[1])
			vs.append(Vector3(x, hy.call(x, z), z))
			cs.append(c)
	for j in H - 1:
		for i in W - 1:
			var a0 := j * W + i
			for tri: Array in [[a0, a0 + W, a0 + 1], [a0 + 1, a0 + W, a0 + W + 1]]:
				var q0: Vector3 = vs[tri[0]]
				var q1: Vector3 = vs[tri[1]]
				var q2: Vector3 = vs[tri[2]]
				# Godot ön yüz: normal tarafından saat yönü → (q1−q0)×(q2−q0) aşağı bakmalı
				var nn := (q1 - q0).cross(q2 - q0)
				if nn.y > 0.0:
					tri = [tri[0], tri[2], tri[1]]
				else:
					nn = -nn
				nn = nn.normalized()
				for k in 3:
					st.set_color(cs[tri[k]])
					st.set_normal(nn)
					st.add_vertex(vs[tri[k]])
	# yer örtüsü: kümelenmiş ot tutamları (ot yamasında), düşmüş taş (sura yakın) — yalnız levhanın sura yakın 40 m'sinde
	var zA := z0 if uzat >= 0 else maxf(z0, z1 - 25.0)
	var zB := minf(z1, z0 + 25.0) if uzat >= 0 else z1
	var adim := 3.2
	var x := x0 + 1.0
	while x < x1:
		var zz := zA + 0.6
		while zz < zB - 0.4:
			var hz := _h(roundi(x * 3.0), roundi(zz * 3.0))
			var hz2 := _h(roundi(x * 5.0) + 17, roundi(zz * 7.0))
			var px := x + (hz - 0.5) * adim
			var pz := clampf(zz + (hz2 - 0.5) * adim, zA + 0.3, zB - 0.3)
			var w := _uzak_sur(pz, yuzler)
			var cp := float(zemin_renk(px, pz, w)[1])
			var yama := gn(px, pz, 6.0, 11)
			if w > 0.8 and hz < (1.0 - cp) * 0.9 * smoothstep(0.45, 0.7, yama):
				var sc := 0.35 + hz2 * 0.4
				ot.append(Transform3D(Basis(Vector3.UP, hz * TAU).scaled(Vector3(sc * 1.3, sc * (0.6 + hz2 * 0.5), sc * 1.3)), Vector3(px, hy.call(px, pz) - 0.03, pz)))
			zz += adim
		x += adim


## Yer örtüsü: ot tutamları iki MultiMesh'te (sol/sağ yarı; düşmüş taşlar sur dibinde OTURTMA'nın SurDibiTas'ında)
static func _ortu(kok: Node3D, ot: Array) -> void:
	if _ot_m == null:
		_ot_m = load("res://scripts/level/bitki_kit.gd").mat()
	var po := {}
	for t: Transform3D in ot:
		var k := 0 if t.origin.x < 0.0 else 1
		if not po.has(k):
			po[k] = []
		(po[k] as Array).append(t)
	for k in po:
		_mm(kok, OTAG.ot_mesh(), po[k], _ot_m, "Bitki_KesimOt_%d" % k)


static func _mm(p: Node3D, mesh: Mesh, xfs: Array, mat: Material, ad: String) -> void:
	if xfs.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xfs.size()
	for i in xfs.size():
		mm.set_instance_transform(i, xfs[i])
	var mi := MultiMeshInstance3D.new()
	mi.name = ad
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.add_child(mi)
