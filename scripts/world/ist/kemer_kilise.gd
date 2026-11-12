class_name IstKemerKilise
extends RefCounted
## Parametreli Bizans kilisesi kurucusu (kemer parçası): haç planlı / dört sütunlu orta tip, beş kubbeli haç ve harabe.
## Yerel eksen: apsis +x (doğu). Dönüş `rot` ile verilir. Kütle k ile ölçeklenir; basamak 0,28 m, kapı 2,2 m sabittir.
## Dönüş değeri: {"perches": [Vector3], "climbs": [[alt, ust, tür]], "top": float} (kilise düğümünün yerel koordinatı değil,
## `host` koordinatı).

const KIT := preload("res://scripts/world/ist/kemer_kit.gd")


static func _rot(v: Vector3, deg: float) -> Vector3:
	return v.rotated(Vector3.UP, deg_to_rad(deg))


## o: pos (host koordinatı, taban merkezi), rot (derece), W, D (gerçek m, narteks hariç), Hc (köşe/bitişik yükseklik),
## ext (kolların köşeden fazlası), dome_d, narthex (m, 0 = yok), col (BRICK/STONE), roof (LEAD/TILE),
## five (beş kubbeli haç), ruin (0–1), seed, apses (0–3), tag
static func church(host: Node3D, o: Dictionary, k: float, lod: int) -> Dictionary:
	var c := Node3D.new()
	c.name = String(o.get("tag", "Kilise"))
	c.position = o.get("pos", Vector3.ZERO)
	c.rotation_degrees.y = float(o.get("rot", 0.0))
	host.add_child(c)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(o.get("seed", 1))
	var W: float = float(o["W"]) * k
	var D: float = float(o["D"]) * k
	var Hc: float = maxf(float(o["Hc"]) * k, 3.2)
	var ext: float = maxf(float(o.get("ext", 5.0)) * k, 1.6)
	var Hw := Hc + ext
	var s := maxf(float(o["dome_d"]) * k + 1.0, 3.2)        # merkez kare
	var col: Color = o.get("col", KIT.BRICK)
	var roof: Color = o.get("roof", KIT.LEAD)
	var five: bool = o.get("five", false)
	var ruin: float = float(o.get("ruin", 0.0))
	var nd: float = float(o.get("narthex", 0.0)) * k
	var pat := "ashlar"
	var out := {"perches": [], "climbs": [], "top": Hw}
	var cw := col.lightened(0.12)

	# --- Gövde (köşe katı): bütün plan
	var body := KIT.blk(c, Vector3(W, Hc, D), Vector3.ZERO, cw, pat)
	body.name = "Gövde"
	# alt sıra kesme taş şeridi + üst tuğla bant (opus mixtum izlenimi); yalnız görsel
	if lod < 2:
		KIT.vis(c, Vector3(W + 0.3, 0.9, D + 0.3), Vector3(0, 0.0, 0), KIT.STONE, "ashlar")
		KIT.vis(c, Vector3(W + 0.2, 0.28, D + 0.2), Vector3(0, Hc - 0.28, 0), KIT.STONE_D)

	# --- Köşe çatıları: düz kiremit (yürünür), kuzey-güney tarafında eğimli görünüm yok; üstü bitmiş
	if lod < 2:
		var cr := KIT.vis(c, Vector3(W - 0.2, 0.15, D - 0.2), Vector3(0, Hc, 0), KIT.TILE, "tiles")
		cr.name = "KöşeÇatı"
		# kiremit kenar saçağı
		KIT.vis(c, Vector3(W + 0.5, 0.18, D + 0.5), Vector3(0, Hc - 0.02, 0), KIT.TILE.darkened(0.2))

	# --- Kollar ve kubbeler
	var domes_top := Hw
	if five:
		# Beş kubbeli haç: merkez + dört kol kubbeli bay
		var bays := [Vector3(0, 0, 0), Vector3(s, 0, 0), Vector3(-s, 0, 0), Vector3(0, 0, s), Vector3(0, 0, -s)]
		var idx := 0
		for bpos: Vector3 in bays:
			var big := bpos == Vector3.ZERO
			var broken := ruin > 0.45 and (idx == 2 or idx == 3)
			var tp := _domed_bay(c, bpos, s, Hc, Hw, col, roof, big, broken, rng, lod)
			if tp > 0.0:
				domes_top = maxf(domes_top, tp)
			idx += 1
	else:
		# Haç kolları: yassı tonozlu iki kol (x ve z) + merkez kubbe
		var arm_x := KIT.blk(c, Vector3(W, ext, s), Vector3(0, Hc, 0), cw, pat)
		var arm_z := KIT.blk(c, Vector3(s, ext, D), Vector3(0, Hc, 0), cw, pat)
		arm_x.name = "KolX"
		arm_z.name = "KolZ"
		for ax in [true, false]:
			var len: float = W if ax else D
			var mi := Props.cyl(c, s * 0.5, len - 0.1, Vector3(0, Hw, 0), roof, Vector3(0, 0, 90) if ax else Vector3(90, 0, 0), 14)
			mi.material_override = Props.mat(roof, 0.0, false, "tiles" if roof == KIT.TILE else "")
			# yassı: dikeyde 0,42
			if ax:
				mi.scale = Vector3(0.42, 1.0, 1.0)
			else:
				mi.scale = Vector3(1.0, 1.0, 0.42)
			Props.make_solid(mi, 1.0)
			# alınlıkta kemerli üçlü pencere + tuğla çerçeve (kol uçları)
			if lod == 0:
				for sg in [-1.0, 1.0]:
					var wp := Vector3(sg * (len * 0.5 + 0.04), Hw + 0.2, 0) if ax else Vector3(0, Hw + 0.2, sg * (len * 0.5 + 0.04))
					var face := Vector3(0.12, 1.0, 0.45) if ax else Vector3(0.45, 1.0, 0.12)
					for j in [-1, 0, 1]:
						var off := (Vector3(0, 0, j * 0.6) if ax else Vector3(j * 0.6, 0, 0))
						Props.box(c, face, wp + off, KIT.DARK)
		# merkez tambur + kubbe
		var dr := s * 0.5 * 1.04
		var dh := s * 0.5 * 0.42 + 2.4
		if ruin > 0.45:
			dh *= 0.55
		KIT.drum(c, dr, dh, Vector3(0, Hw, 0), col, 12 if k > 0.4 else 8, lod)
		if ruin > 0.45:
			KIT.rubble(c, Vector3(0, Hw + dh, 0), dr * 0.9, 1.2, int(o.get("seed", 1)))
			domes_top = Hw + dh + 1.2
		else:
			domes_top = KIT.dome(c, dr + 0.15, Vector3(0, Hw + dh, 0), roof, 16, 0.55, true, lod)

	# --- Apsisler (+x)
	var ap := int(o.get("apses", 1))
	if ap >= 1:
		var ar := minf(s * 0.5, D * 0.4)
		var ah := Hc + ext * 0.7
		var apx := W * 0.5
		KIT.cylinder_solid(c, ar, ah, Vector3(apx, 0, 0), cw, pat, 14 if lod == 0 else 8)
		var cone := Props.cyl(c, 0.2, ar * 0.7, Vector3(apx, ah + ar * 0.35, 0), roof, Vector3.ZERO, 14, ar * 1.05)
		Props.make_solid(cone)
		if lod == 0:
			for j in [-1, 0, 1]:
				var a: float = float(j) * 0.5
				Props.box(c, Vector3(0.5, 1.4, 0.14), Vector3(apx + cos(a) * (ar + 0.04), ah * 0.55, sin(a) * (ar + 0.04)), KIT.DARK, Vector3(0, -rad_to_deg(a), 0))
		if ap >= 3:
			for sg in [-1.0, 1.0]:
				var sr := ar * 0.55
				KIT.cylinder_solid(c, sr, Hc * 0.9, Vector3(apx - 0.2, 0, sg * (ar + sr + 0.5)), cw, pat, 10)
				# apsis arası dolgu: iki apsis arasında girilebilir daracık aralık bırakma
				KIT.blk(c, Vector3(1.2, Hc * 0.9, sr * 2.0 + 0.6), Vector3(apx - 1.0, 0, sg * (ar + sr + 0.5)), cw, pat)
				if ar + sr + 0.5 - sr - ar > 0.0:
					KIT.blk(c, Vector3(1.0, Hc * 0.9, 0.5 + 0.05), Vector3(apx - 0.5, 0, sg * (ar + 0.25)), cw, pat)

	# --- Narteks (batı)
	if nd > 0.0:
		var hn := Hc * 0.85
		var nx := -W * 0.5 - nd * 0.5
		var nb := KIT.blk(c, Vector3(nd, hn, D), Vector3(nx, 0, 0), cw, pat)
		nb.name = "Narteks"
		KIT.vis(c, Vector3(nd + 0.2, 0.14, D + 0.2), Vector3(nx, hn, 0), KIT.TILE, "tiles")
		KIT.vis(c, Vector3(nd + 0.3, 0.3, D + 0.3), Vector3(nx, hn - 0.3, 0), KIT.STONE_D)
		if lod == 0:
			# Anıtsal kapı: mermer çerçeve, kemerli koyu boşluk, üç basamak
			var gx := -W * 0.5 - nd - 0.04
			Props.box(c, Vector3(0.22, 3.2, 2.9), Vector3(gx - 0.03, 1.6, 0), Color("e6dcc8"))
			Props.box(c, Vector3(0.24, 2.3, 1.7), Vector3(gx - 0.1, 1.15, 0), Color("4a3524"))
			Props.ball(c, 0.85, Vector3(gx - 0.1, 2.3, 0), Color("4a3524"), Vector3(0.14, 0.72, 1.0), 10)
			for j in 3:
				KIT.blk(c, Vector3(0.5 + 0.5 * (2 - j), 0.16 * (j + 1), 3.4), Vector3(gx - 0.1 - 0.25 - 0.25 * (2 - j) - 0.0, 0, 0), KIT.STONE, "ashlar")
			# Pencereler (narteks yan yüzleri ve cephe)
			var wxs: Array = []
			for sg in [-1.0, 1.0]:
				for j in 2:
					wxs.append(Transform3D(Basis.IDENTITY, Vector3(nx + (j - 0.5) * nd * 0.5, hn * 0.6, sg * (D * 0.5 + 0.03))))
			KIT.multi(c, BoxMesh.new() if false else _bm(Vector3(0.5, 1.1, 0.1)), Props.mat(KIT.DARK, 0.0, false, "", false), wxs)
		if hn > 3.0 and ruin < 0.5:
			var dr2 := maxf(nd * 0.4, 1.4)
			for sg in [-1.0, 1.0]:
				KIT.cylinder_solid(c, dr2, 1.4, Vector3(nx, hn + 0.14, sg * D * 0.27), col, "brick", 10)
				var dm := KIT.dome(c, dr2 * 1.05, Vector3(nx, hn + 1.54, sg * D * 0.27), roof, 8, 0.6, true, lod)
				domes_top = maxf(domes_top, dm - 3.0)

	# --- Duvar süsleri (yalnız lod 0): payandalar, kemerli pencereler (MultiMesh), korniş
	if lod == 0:
		var xs: Array = []
		var n_w := maxi(3, int(W / 4.0))
		for sg in [-1.0, 1.0]:
			for j in n_w:
				var wx := -W * 0.5 + (j + 0.5) * W / n_w
				if absf(wx) < s * 0.5 + 0.2:
					continue
				xs.append(Transform3D(Basis.IDENTITY, Vector3(wx, Hc * 0.55, sg * (D * 0.5 + 0.03))))
		KIT.multi(c, _bm(Vector3(0.55, minf(Hc * 0.5, 2.2), 0.1)), Props.mat(KIT.DARK, 0.0, false, "", false), xs)
		var buttress: Array = []
		for sg in [-1.0, 1.0]:
			for j in 4:
				var bx := -W * 0.5 + (j + 0.5) * W / 4.0
				buttress.append(Transform3D(Basis.IDENTITY, Vector3(bx, Hc * 0.5, sg * (D * 0.5 + 0.25))))
		KIT.multi(c, _bm(Vector3(0.5, Hc, 0.5)), Props.mat(col.darkened(0.1), 0.0, false, "", false), buttress)
		# payandalar ayrıca katı: 0,5 m çıkıntı, dışa taşan gövde ile bitişik
		for sg in [-1.0, 1.0]:
			for j in 4:
				var bx2 := -W * 0.5 + (j + 0.5) * W / 4.0
				var b := StaticBody3D.new()
				var cs := CollisionShape3D.new()
				var bs := BoxShape3D.new()
				bs.size = Vector3(0.5, Hc, 0.5)
				cs.shape = bs
				b.add_child(cs)
				b.position = Vector3(bx2, Hc * 0.5, sg * (D * 0.5 + 0.25))
				c.add_child(b)

	# --- Harabe: moloz ve ot, sütun kütükleri, üstü yıkık duvar dişleri
	if ruin > 0.0:
		_ruin_dress(c, W + nd * 2.0, D, Hc, ruin, rng, lod)

	# --- ikinci kubbe (Eleousa tipi uzun orta kilise)
	if o.get("second", false):
		var dx := -W * 0.5 + s * 0.9
		var r2 := s * 0.5 * 0.95
		var dh2 := s * 0.5 * 0.42 + 2.0
		KIT.drum(c, r2, dh2, Vector3(dx, Hw, 0), col, 12 if lod == 0 else 8, lod)
		var dt := KIT.dome(c, r2 + 0.12, Vector3(dx, Hw + dh2, 0), roof, 14, 0.55, true, lod)
		out["perches"].append(_rot(Vector3(dx, dt, 0), c.rotation_degrees.y) + c.position)
		domes_top = maxf(domes_top, dt)
	# --- Tırmanma yolları: dış taş merdiven (zeminden köşe çatısına), sonra kol çatısına
	if o.get("no_stair", false):
		out["perches"].append(_rot(Vector3(0, domes_top, 0), c.rotation_degrees.y) + c.position)
		out["top"] = domes_top + c.position.y
		return out
	var stair_z := D * 0.5 + 1.0
	var n1 := int(ceil(Hc / 0.28))
	var rise1 := Hc / n1
	var run1 := 0.5
	var x_end := -W * 0.5 - nd + 0.2 + n1 * run1
	x_end = minf(x_end, W * 0.5 - s)
	var x0 := x_end - n1 * run1
	var s1_top := KIT.stairs(c, Vector3(x0, 0, stair_z), Vector3(1, 0, 0), n1, rise1, run1, 2.0, Color("cdb88e"))
	# merdivenin dış yan duvarı (düşme tutamağı)
	KIT.blk(c, Vector3(n1 * run1, 0.5, 0.35), Vector3(x0 + n1 * run1 * 0.5, 0, stair_z + 1.17), KIT.STONE_D, "ashlar").rotation_degrees.x = 0.0
	out["climbs"].append([_rot(Vector3(x0 - 0.3, 0, stair_z), c.rotation_degrees.y) + c.position, _rot(Vector3(x_end - 0.3, Hc + 0.15, stair_z), c.rotation_degrees.y) + c.position, "basamak"])
	var tp := Vector3(x_end - 0.1, Hc + 0.15, D * 0.5 - 1.0)
	out["perches"].append(_rot(Vector3(0, domes_top, 0), c.rotation_degrees.y) + c.position)
	out["perches"].append(_rot(tp, c.rotation_degrees.y) + c.position)
	out["roof_pt"] = _rot(tp, c.rotation_degrees.y) + c.position
	out["top"] = domes_top + c.position.y
	return out


static func _bm(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b


## Beş kubbeli haçın bir kubbeli bayı
static func _domed_bay(c: Node3D, bpos: Vector3, s: float, Hc: float, Hw: float, col: Color, roof: Color, big: bool, broken: bool, rng: RandomNumberGenerator, lod: int) -> float:
	var bw := KIT.blk(c, Vector3(s, Hw - Hc, s), bpos + Vector3(0, Hc, 0), col.lightened(0.12), "ashlar")
	var r := s * 0.5 * (1.04 if big else 0.9)
	var dh := s * 0.3 + 1.6 if big else s * 0.25 + 1.2
	if broken:
		dh *= 0.45
	KIT.drum(c, r, dh, bpos + Vector3(0, Hw, 0), col, 12 if lod == 0 else 8, lod)
	if broken:
		KIT.rubble(c, bpos + Vector3(0, Hw + dh, 0), r * 0.9, 1.4, int(bpos.x * 7 + bpos.z * 3 + 11))
		return Hw + dh + 1.4
	return KIT.dome(c, r + 0.12, bpos + Vector3(0, Hw + dh, 0), roof, 14 if big else 10, 0.55, true, lod)


static func _ruin_dress(c: Node3D, W: float, D: float, Hc: float, ruin: float, rng: RandomNumberGenerator, lod: int) -> void:
	# Yıkık duvar dişleri (kenar boyunca) ve kenarda moloz yığınları (zemin basamakları)
	var teeth := int(8 + 12 * ruin)
	for i in teeth:
		var side := 1.0 if rng.randf() > 0.5 else -1.0
		var x := rng.randf_range(-W * 0.5 + 1.0, W * 0.5 - 1.0)
		var tw := rng.randf_range(0.8, 1.6)
		var th := rng.randf_range(0.3, 0.9)
		KIT.blk(c, Vector3(tw, th, 0.8), Vector3(x, Hc + 0.15, side * (D * 0.5 - 0.4)), KIT.STONE_D, "rubble")
	for i in int(3 + 4 * ruin):
		var ang := rng.randf() * TAU
		var rr := Vector3(cos(ang) * (W * 0.5 + 2.5), 0, sin(ang) * (D * 0.5 + 2.8))
		KIT.rubble(c, rr, rng.randf_range(1.2, 2.2), rng.randf_range(0.6, 1.4), i + 5)
	if lod == 0:
		for i in 6:
			var ang2 := rng.randf() * TAU
			var rp := Vector3(cos(ang2) * (W * 0.5 + 4.5), 0, sin(ang2) * (D * 0.5 + 4.5))
			KIT.tree(c, rp, rng.randf_range(3.5, 5.5), "incir" if i % 2 == 0 else "selvi")
		# ot tutamları köşe çatıda
		for i in 5:
			Props.box(c, Vector3(rng.randf_range(0.8, 1.8), 0.14, rng.randf_range(0.6, 1.2)), Vector3(rng.randf_range(-W * 0.4, W * 0.4), Hc + 0.22, rng.randf_range(-D * 0.4, D * 0.4)), KIT.MOSS)
