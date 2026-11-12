class_name IstForumlarYapi
extends RefCounted
## Forumlar paketinin ortak yapı taşları (Props üstüne ince katman): kutu/silindir/merdiven/kemer/çatı/sütun.
## Ölçek: k yalnız kütleyi ölçekler; insan ölçüsü (basamak ≤ 0,3 m, geçit ≥ 3 m yükseklik, ≥ 2,4 m genişlik) sabit.

const TAS := Color("dccfb0")        # sarı kesme taş
const TAS_K := Color("c2b08c")      # koyu taş
const MERMER := Color("ebe5d6")
const TUGLA := Color("b8694a")
const PORFIR := Color("84384e")
const GRANIT := Color("8f9296")
const KIREMIT := Color("b9593b")
const OT := Color("6f8e3e")
const OT_K := Color("587a30")
const KURSUN := Color("8e969c")
const BRONZ := Color("a9803a")
const DEMIR := Color("2c2a2a")
const TOPRAK := Color("9a7a52")
const MOLOZ := Color("a89a80")
const AHSAP := Color("6a4a2c")

const ADIM_H := 0.28      # merdiven basamak yüksekliği (STEP_H 0,42 altında)
const ADIM_D := 0.42


## Kutu: solid ise çarpışmalı. pat verilirse desenli (taş, tuğla...).
static func box(h: Node3D, size: Vector3, pos: Vector3, col: Color, pat := "", solid := true, rot := Vector3.ZERO) -> Node3D:
	if solid:
		var b := Props.solid(h, size, pos, col, rot)
		if pat != "":
			Props.set_pattern(b, col.lerp(Color.WHITE, 0.5), pat)
		return b
	var m := Props.box(h, size, pos, col, rot)
	if pat != "":
		m.material_override = Props.mat(col.lerp(Color.WHITE, 0.5), 0.0, false, pat)
	return m


## Silindir / kesik koni (pos = orta nokta). solid ise dışbükey kabuk çarpışma.
static func cyl(h: Node3D, r: float, height: float, pos: Vector3, col: Color, top_r := -1.0, segs := 10, solid := true, pat := "") -> MeshInstance3D:
	var mi := Props.cyl(h, r, height, pos, col, Vector3.ZERO, segs, top_r)
	if pat != "":
		mi.material_override = Props.mat(col.lerp(Color.WHITE, 0.5), 0.0, false, pat)
	if solid:
		Props.make_solid(mi, 0.98)
	return mi


## Elips plaka (oval meydan): yarıçaplar rx, rz; üst yüzey y = pos.y + height/2.
static func disk(h: Node3D, rx: float, rz: float, height: float, pos: Vector3, col: Color, segs := 48, solid := true, pat := "") -> MeshInstance3D:
	var mi := Props.cyl(h, 1.0, height, pos, col, Vector3.ZERO, segs, 1.0)
	mi.scale = Vector3(rx, 1.0, rz)
	if pat != "":
		mi.material_override = Props.mat(col.lerp(Color.WHITE, 0.5), 0.0, false, pat)
	if solid:
		Props.make_solid(mi, 1.0)
	return mi


## Yaprak/süs küresi: çarpışmasız, denetimde "delik" sayılmaz (meta dekor).
static func yaprak(h: Node3D, r: float, pos: Vector3, col: Color, sc := Vector3.ONE, segs := 8) -> MeshInstance3D:
	var m := Props.ball(h, r, pos, col, sc, segs)
	m.set_meta("dekor", true)
	return m


static func ball(h: Node3D, r: float, pos: Vector3, col: Color, sc := Vector3.ONE, segs := 8) -> MeshInstance3D:
	return Props.ball(h, r, pos, col, sc, segs)


## Yinelenen parçalar tek MultiMesh'te.
static func multi(h: Node3D, mesh: Mesh, xforms: Array, col: Color, pat := "") -> void:
	if xforms.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i] as Transform3D)
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = Props.mat(col.lerp(Color.WHITE, 0.4) if pat != "" else col, 0.0, false, pat, false)
	h.add_child(mi)


static func bmesh(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b


static func xf(pos: Vector3, rot_deg := Vector3.ZERO) -> Transform3D:
	var b := Basis.from_euler(Vector3(deg_to_rad(rot_deg.x), deg_to_rad(rot_deg.y), deg_to_rad(rot_deg.z)))
	return Transform3D(b, pos)


## Taş merdiven: a = ilk basamağın ÖNÜ (zemin), dir = yatay yön, yukarı doğru; toplam yükseklik hh. Her basamak
## zemine kadar dolu. Dönüş: basamak sayısı. Üst yüzey y = a.y + hh.
static func stairs(h: Node3D, a: Vector3, dir: Vector3, hh: float, w: float, col: Color, solid := true, pat := "ashlar") -> int:
	var n := maxi(1, ceili(hh / ADIM_H - 0.001))
	var sh := hh / n
	var d := Vector3(dir.x, 0, dir.z).normalized()
	var yaw := rad_to_deg(atan2(d.x, d.z))
	for i in n:
		var top := sh * (i + 1)
		var c := a + d * (ADIM_D * (i + 0.5))
		var ww := w - 0.03 * i
		box(h, Vector3(ww, top, ADIM_D), Vector3(c.x, a.y + top * 0.5, c.z), col, pat, solid, Vector3(0, yaw, 0))
	return n


## Beşik çatı (sırt z boyunca). Kiremit desenli prizma; solid ise üçgen prizma çarpışma (eğim ≤ ~32°).
static func roof(h: Node3D, w: float, d: float, y_base: float, rise: float, pos_xz: Vector2, col := KIREMIT, solid := true) -> void:
	var r := minf(rise, w * 0.31)
	var pm := PrismMesh.new()
	pm.size = Vector3(w, r, d)
	var mi := MeshInstance3D.new()
	mi.mesh = pm
	mi.position = Vector3(pos_xz.x, y_base + r * 0.5, pos_xz.y)
	mi.material_override = Props.mat(col.lerp(Color.WHITE, 0.4), 0.0, false, "tiles")
	h.add_child(mi)
	if solid:
		var body := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var cv := ConvexPolygonShape3D.new()
		cv.points = PackedVector3Array([Vector3(-w / 2, 0, -d / 2), Vector3(w / 2, 0, -d / 2), Vector3(0, r, -d / 2),
			Vector3(-w / 2, 0, d / 2), Vector3(w / 2, 0, d / 2), Vector3(0, r, d / 2)])
		cs.shape = cv
		body.position = Vector3(pos_xz.x, y_base, pos_xz.y)
		body.add_child(cs)
		h.add_child(body)


## Yarım daire kemer (XY düzleminde, açıklık +z/-z'ye bakar). c = yay başlangıç (kemer merkezi) noktası.
static func kemer_taslar(h: Node3D, c: Vector3, r: float, kalin: float, derin: float, col: Color, adet := 11) -> void:
	var xs: Array = []
	var bm := bmesh(Vector3(kalin, PI * (r + kalin * 0.5) / adet * 1.02, derin))
	for i in adet:
		var a := PI * (i + 0.5) / adet
		var rr := r + kalin * 0.5
		xs.append(xf(c + Vector3(cos(a) * rr, sin(a) * rr, 0), Vector3(0, 0, rad_to_deg(a))))
	multi(h, bm, xs, col)


## Zafer takı / kapı kemeri. Açıklık genişliği ac, yaydan önce serbest yükseklik yay (>= 3 m). Dönüş: üst yüzey y.
## Çarpışma: iki ayak + yay üstü gövde; açıklıkta delik yok ama geçilir. tam = false: bir ayağı yıkık (moloz).
static func kapi_kemeri(h: Node3D, pos: Vector3, ac: float, yay: float, ust: float, derin: float, ayak_w: float, col: Color, yikik := 0, solid := true) -> void:
	var tw := ac + ayak_w * 2.0
	var r := ac * 0.5
	var tepe := yay + r
	# ayaklar
	for sd: int in [-1, 1]:
		var broken: bool = (yikik == sd)
		var ph := yay if not broken else yay * 0.55
		box(h, Vector3(ayak_w, ph, derin), pos + Vector3(sd * (ac * 0.5 + ayak_w * 0.5), ph * 0.5, 0), col, "ashlar", solid)
		if not broken:
			# kemer omuzluğu (kornişin altından taşan)
			box(h, Vector3(ayak_w + 0.3, 0.3, derin + 0.3), pos + Vector3(sd * (ac * 0.5 + ayak_w * 0.5), yay + 0.15, 0), TAS_K, "", solid)
			# yay ile dış köşe arası dolgu (kemer köşelikleri), kemerin yan hizasında
			var hh := maxf(ust - yay, 0.5)
			box(h, Vector3(ayak_w, hh, derin), pos + Vector3(sd * (ac * 0.5 + ayak_w * 0.5), yay + hh * 0.5, 0), col, "ashlar", solid)
		else:
			# yıkık ayağın üstü: kırık taş yığını (basamak gibi çıkılır)
			box(h, Vector3(ayak_w * 0.9, 0.5, derin * 0.7), pos + Vector3(sd * (ac * 0.5 + ayak_w * 0.5), ph + 0.25, 0.1), MOLOZ, "rubble", solid, Vector3(0, 12, 6))
	# kemer taşları + üst gövde
	kemer_taslar(h, pos + Vector3(0, yay, 0), r, 0.55, derin, TAS_K, 13)
	if yikik == 0:
		box(h, Vector3(tw, ust - tepe - 0.55, derin), pos + Vector3(0, tepe + 0.55 + (ust - tepe - 0.55) * 0.5, 0), col, "ashlar", solid)
		box(h, Vector3(tw + 0.5, 0.45, derin + 0.5), pos + Vector3(0, ust + 0.225, 0), TAS_K, "", solid)
	else:
		box(h, Vector3(tw * 0.5, ust - tepe - 0.55, derin), pos + Vector3(-yikik * tw * 0.25, tepe + 0.55 + (ust - tepe - 0.55) * 0.5, 0), col, "ashlar", solid)
		box(h, Vector3(tw * 0.5 + 0.5, 0.45, derin + 0.5), pos + Vector3(-yikik * tw * 0.25, ust + 0.225, 0), TAS_K, "", solid)
	# yay üstündeki sürekli gövde (kapatma): kemer açıklığının üstünü kapatan çarpışma (yayın içinde gizli, 3 m üstü)
	if solid:
		var bd := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(ac + 0.2, ust - yay, derin)
		cs.shape = bs
		bd.position = pos + Vector3(0, yay + (ust - yay) * 0.5, 0)
		bd.add_child(cs)
		h.add_child(bd)


## Moloz yığını: üst üste basamaklanan alçak kutular (adım ≤ 0,28), çıkılabilir.
static func moloz(h: Node3D, pos: Vector3, w: float, d: float, kat: int, rng: RandomNumberGenerator, solid := true) -> void:
	for i in kat:
		var sh := 0.26
		var ww := w * (1.0 - 0.28 * i)
		var dd := d * (1.0 - 0.28 * i)
		box(h, Vector3(ww, sh * (i + 1), dd), pos + Vector3(rng.randf_range(-0.1, 0.1) * i, sh * (i + 1) * 0.5, rng.randf_range(-0.1, 0.1) * i),
			MOLOZ if i % 2 == 0 else TAS_K, "rubble", solid, Vector3(0, rng.randf_range(-20, 20), 0))


## Ot/çalı tutamı (görsel).
static func ot(h: Node3D, pos: Vector3, r: float, rng: RandomNumberGenerator) -> void:
	ball(h, r, pos + Vector3(0, r * 0.45, 0), OT if rng.randf() < 0.5 else OT_K, Vector3(1, 0.6, 1), 6)


## Haç: bronz, dikilebilir (görsel).
static func hac(h: Node3D, pos: Vector3, s: float, col := BRONZ) -> void:
	box(h, Vector3(0.18 * s, 1.5 * s, 0.18 * s), pos + Vector3(0, 0.75 * s, 0), col, "", false)
	box(h, Vector3(0.9 * s, 0.18 * s, 0.18 * s), pos + Vector3(0, 1.05 * s, 0), col, "", false)
	box(h, Vector3(0.5 * s, 0.12 * s, 0.14 * s), pos + Vector3(0, 0.45 * s, 0), col, "", false)


## Korint başlığı (yaklaşık): gövde koni + yaprak sırası (MultiMesh) + abaküs.
static func korint_baslik(h: Node3D, r: float, pos: Vector3, col: Color, solid := true, detay := true) -> float:
	var hh := r * 1.9
	cyl(h, r * 1.05, hh * 0.7, pos + Vector3(0, hh * 0.35, 0), col, r * 1.35, 10, false)
	if detay:
		var xs: Array = []
		var bm := bmesh(Vector3(r * 0.5, hh * 0.55, r * 0.14))
		for i in 8:
			var a := TAU * i / 8.0
			xs.append(xf(pos + Vector3(cos(a) * r * 1.12, hh * 0.3, sin(a) * r * 1.12), Vector3(0, -rad_to_deg(a) + 90, 0)))
		multi(h, bm, xs, col.darkened(0.08))
	box(h, Vector3(r * 3.2, hh * 0.3, r * 3.2), pos + Vector3(0, hh * 0.85, 0), col, "", solid)
	return hh


## Ağaç (selvi): gövde + koni, görsel (çarpışmalı gövde).
static func selvi(h: Node3D, pos: Vector3, boy: float, solid := true) -> void:
	cyl(h, 0.12, boy * 0.2, pos + Vector3(0, boy * 0.1, 0), AHSAP, -1.0, 5, solid)
	var mi := Props.cyl(h, boy * 0.12, boy * 0.85, pos + Vector3(0, boy * 0.58, 0), Color("2f5a34"), Vector3.ZERO, 6, 0.02)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


## Sütun kaide + gövde + başlık: tüm anıt sütunlarının ortak kurgusu. Dönüş: {"ust": başlık üst y, "kaide_ust": y, "r": gövde yarıçapı}
## o: kaide_w, kaide_h (gerçek), govde_r, govde_h (gerçek), tambur, renk, desen ("spiral"|"hoop"|"gozyasi"|"duz"),
##    baslik ("korint"|"duz"|"hac"|"yok"), cember (bool), kaide_renk, merdiven_yon (Vector3)
static func sutun(n: Node3D, p: Vector3, k: float, o: Dictionary, lod: int) -> Dictionary:
	var col := lod == 0
	var kw := maxf(float(o.get("kaide_w", 6.0)) * k, 3.0)
	var kh := maxf(float(o.get("kaide_h", 5.0)) * k, 1.4)
	var gr := maxf(float(o.get("govde_r", 1.4)) * k, 0.45)
	var gh := float(o.get("govde_h", 25.0)) * k
	var renk: Color = o.get("renk", GRANIT)
	var kcol: Color = o.get("kaide_renk", MERMER)
	# basamaklı taban (3 kademe, 0.28 m)
	var st_n := 0 if bool(o.get("merdiven", true)) else 3
	for i in st_n:
		var w := kw + 1.6 - i * 0.55
		box(n, Vector3(w, ADIM_H * (i + 1), w), p + Vector3(0, ADIM_H * (i + 1) * 0.5, 0), TAS_K, "ashlar", col)
	var y0 := ADIM_H * st_n
	var kd := kh - y0
	if kd < 0.5:
		kd = 0.5
	box(n, Vector3(kw, kd, kw), p + Vector3(0, y0 + kd * 0.5, 0), kcol, "marble" if lod < 2 else "", col)
	var ky := y0 + kd
	# kaide saçağı (korniş)
	box(n, Vector3(kw + 0.5, 0.35, kw + 0.5), p + Vector3(0, ky + 0.175, 0), TAS_K, "", col)
	ky += 0.35
	# plinth
	box(n, Vector3(gr * 2.6, 0.3, gr * 2.6), p + Vector3(0, ky + 0.15, 0), kcol, "", col)
	ky += 0.3
	var tn := int(o.get("tambur", 8))
	var dh := gh / tn
	var hoops: Array = []
	for i in tn:
		var rr := gr * (1.0 - 0.07 * float(i) / tn)
		var rt := gr * (1.0 - 0.07 * float(i + 1) / tn)
		cyl(n, rr, dh, p + Vector3(0, ky + dh * (i + 0.5), 0), renk, rt, 12 if lod == 0 else 8, col, "marble" if (renk == MERMER and lod < 2) else "")
		if bool(o.get("cember", false)) and lod < 2 and i < tn - 1:
			cyl(n, rt + 0.06, 0.14, p + Vector3(0, ky + dh * (i + 1), 0), DEMIR, -1.0, 12, false)
	var desen := String(o.get("desen", "duz"))
	if lod == 0 and desen == "spiral":
		# sarmal kabartma bandı: gövdeyi 14 kez saran küçük plaka dizisi
		var xs: Array = []
		var turns := int(o.get("sarim", 10))
		var per := 18
		var tot := turns * per
		var bm := bmesh(Vector3(gr * 0.5, gh / tot * 1.8, gr * 0.18))
		for i in tot:
			var t := float(i) / tot
			var a := TAU * turns * t
			var rr := gr * (1.0 - 0.07 * t) + 0.02
			xs.append(xf(p + Vector3(cos(a) * rr, ky + gh * t, sin(a) * rr), Vector3(0, -rad_to_deg(a) + 90, 0)))
		multi(n, bm, xs, TAS_K)
	elif lod == 0 and desen == "gozyasi":
		var xs2: Array = []
		var rows := int(gh / 0.9)
		var sm := SphereMesh.new()
		sm.radius = 0.2
		sm.height = 0.5
		sm.radial_segments = 5
		sm.rings = 3
		for rw in rows:
			for j in 8:
				var a2 := TAU * (j + 0.5 * (rw % 2)) / 8.0
				var b := Basis.from_euler(Vector3(0, -a2 + PI / 2, 0))
				xs2.append(Transform3D(b, p + Vector3(cos(a2) * (gr + 0.01), ky + 0.5 + rw * 0.9, sin(a2) * (gr + 0.01))))
		multi(n, sm, xs2, TAS_K.lightened(0.1))
	var ty := ky + gh
	var out := {"kaide_ust": y0 + kd + 0.35, "r": gr, "ust": ty}
	var bas := String(o.get("baslik", "korint"))
	if bas == "korint":
		var bh := korint_baslik(n, gr, p + Vector3(0, ty, 0), MERMER, col, lod == 0)
		ty += bh
	elif bas == "duz" or bas == "hac":
		box(n, Vector3(gr * 3.0, 0.5, gr * 3.0), p + Vector3(0, ty + 0.25, 0), TAS_K, "", col)
		ty += 0.5
		if bas == "hac":
			hac(n, p + Vector3(0, ty, 0), 1.6)
			ty += 2.4
	out["ust"] = ty
	# kaideye çıkan dış merdiven (yön = merdiven_yon), ayakta üst plinthe
	var dirv: Vector3 = o.get("merdiven_yon", Vector3(0, 0, 1))
	if bool(o.get("merdiven", true)):
		var edge := kw * 0.5 + 0.25
		var hh := ky - 0.3
		var run := ceili(hh / ADIM_H) * ADIM_D
		var start := p + dirv.normalized() * (edge + run)
		start.y = 0.0
		stairs(n, start, -dirv, hh, 1.8, TAS, col)
		out["merdiven_alt"] = start + dirv.normalized() * 0.8 + Vector3(0, 0.02, 0)
		out["merdiven_ust"] = p + dirv.normalized() * (kw * 0.5 - 0.3) + Vector3(0, ky + 0.02, 0)
	return out
