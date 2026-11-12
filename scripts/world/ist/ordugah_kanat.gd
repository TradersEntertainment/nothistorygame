class_name IstOrdugahKanat
extends RefCounted
## Alan doldurucu: bir çokgeni (host yerel x,z) çadır sıralarıyla, ocaklarla ve sancaklarla doldurur.
## tur: "yeniceri" | "anadolu" | "rumeli" | "basibozuk" | "zaganos" | "hizmet"
## Çadırlar MultiMesh (havadan "çadır denizi"); lod 0'da katı (çadır bezi, tırmanılmaz), lod 1–2'de yalnız görsel.
## Çadır aralığı ≥ 2,2 m (yürünür sokak); çadır yarıçapı 2,0–2,5 m (gerçek boy, k'den bağımsız).

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const B = K.Bld

const TURLER := {
	"yeniceri": {"aralik": 6.6, "ana": [Color("f1ead6"), Color("e8dcc0")], "bant": Color("2c3f7a"), "tip": "yuvarlak", "cati_orani": 0.15},
	"anadolu": {"aralik": 7.0, "ana": [Color("d9c7a0"), Color("c9b588"), Color("b8c19a")], "bant": Color("3f6b3d"), "tip": "yuvarlak", "cati_orani": 0.35},
	"rumeli": {"aralik": 7.0, "ana": [Color("e4d8b8"), Color("d6c8a4")], "bant": Color("b3262d"), "tip": "yuvarlak", "cati_orani": 0.3},
	"basibozuk": {"aralik": 6.4, "ana": [Color("a8987a"), Color("8f8064"), Color("b2a07c")], "bant": Color("5c4a34"), "tip": "bark", "cati_orani": 0.75},
	"zaganos": {"aralik": 7.6, "ana": [Color("ebe3cc"), Color("d9cfb0")], "bant": Color("3f6b3d"), "tip": "yuvarlak", "cati_orani": 0.25},
	"hizmet": {"aralik": 7.0, "ana": [Color("cbb98e"), Color("b8a67c")], "bant": Color("7a5634"), "tip": "yuvarlak", "cati_orani": 0.5},
}


static func build_kanat(host: Node3D, alan: PackedVector2Array, tur: String, k: float, lod: int, tohum := 1) -> Dictionary:
	var info: Dictionary = TURLER.get(tur, TURLER["rumeli"])
	var r := K.rr(tohum)
	var sp: float = info["aralik"]
	if lod >= 2:
		sp *= 1.0
	var ang := 0.0
	if alan.size() >= 2:
		var e := alan[1] - alan[0]
		ang = atan2(e.y, e.x)
	var rot := Transform2D(ang, Vector2.ZERO)
	var inv := rot.affine_inverse()
	# dönük kutuda ızgara
	var lp := PackedVector2Array()
	for p in alan:
		lp.append(inv * p)
	var bb := K.poly_bounds(lp)
	var round_x: Array = []
	var round_c: Array = []
	var cati_x: Array = []
	var cati_c: Array = []
	var fire_pts: Array = []
	var flag_pts: Array = []
	var shapes: Array = []         # [pos, r, h]
	var banner_every := 7
	var count := 0
	var row := 0
	var y := bb.position.y + sp * 0.5
	var mesh_round := K.tent_mesh("yuvarlak" if lod == 0 else "sade")
	var tipi: String = info["tip"]
	while y < bb.end.y:
		var x := bb.position.x + sp * (0.5 if row % 2 == 0 else 1.0)
		while x < bb.end.x:
			var jx := r.randf_range(-0.4, 0.4)
			var jy := r.randf_range(-0.4, 0.4)
			var lpos := Vector2(x + jx, y + jy)
			var wpos := rot * lpos
			x += sp
			if not K.in_poly(wpos, alan):
				continue
			if K.filtre.is_valid() and not bool(K.filtre.call(wpos.x, wpos.y)):
				continue
			# kenardan en az 2 m içeride
			var ok := true
			for q in 4:
				var off := Vector2(2.6, 0).rotated(q * PI / 2.0)
				if not K.in_poly(wpos + off, alan):
					ok = false
					break
			if not ok:
				continue
			count += 1
			var yg := K.gy(wpos.x, wpos.y)
			var base_c: Color = (info["ana"] as Array)[r.randi() % (info["ana"] as Array).size()]
			var c2 := K.ton(base_c, r, 0.05)
			if r.randf() < float(info["cati_orani"]):
				# ridge/çatma ya da başıbozuk barınağı
				var len := r.randf_range(4.8, 5.6) if tipi != "bark" else r.randf_range(3.0, 4.2)
				var wid := r.randf_range(3.2, 3.9) if tipi != "bark" else r.randf_range(2.4, 3.2)
				var yaw := ang + (0.0 if r.randf() < 0.5 else PI / 2.0) + r.randf_range(-0.1, 0.1)
				var sy := 1.5 if tipi != "bark" else 1.2
				var b := Basis.from_euler(Vector3(0, -yaw, 0)).scaled(Vector3(len, sy, wid))
				cati_x.append(Transform3D(b, Vector3(wpos.x, yg - 0.1, wpos.y)))
				cati_c.append(c2)
				shapes.append([Vector3(wpos.x, yg + 1.2, wpos.y), maxf(len, wid) * 0.5, -yaw, len, wid])
			else:
				var rad := r.randf_range(2.0, 2.5)
				var b2 := Basis.from_euler(Vector3(0, r.randf() * TAU, 0)).scaled(Vector3(rad, r.randf_range(0.95, 1.2), rad))
				round_x.append(Transform3D(b2, Vector3(wpos.x, yg - 0.1, wpos.y)))
				round_c.append(c2)
				shapes.append([Vector3(wpos.x, yg + 1.35, wpos.y), rad, 0.0, 0.0, 0.0])
			if count % 5 == 3:
				var fp := wpos + Vector2(sp * 0.45, sp * 0.0).rotated(ang)
				if K.in_poly(fp, alan):
					fire_pts.append(Vector2(fp.x, fp.y))
			if count % banner_every == 4:
				flag_pts.append(wpos + Vector2(0, 3.1))
		y += sp
		row += 1
	var mi1 := K.mm(host, mesh_round, round_x, round_c, "yuvarlak", "plaster", lod <= 1)
	var mesh_cati := K.tent_mesh(("cati" if tipi != "bark" else "bark") if lod == 0 else "sade_cati")
	var mi2 := K.mm(host, mesh_cati, cati_x, cati_c, "cati", "plaster", lod <= 1)
	var tris := 0
	# Katı: yalnız lod 0 (çadır bezi, tırmanılmaz)
	if lod == 0:
		var body := StaticBody3D.new()
		body.name = "cadirlar_kati"
		body.set_meta("no_climb", true)
		for s in shapes:
			var cs := CollisionShape3D.new()
			if (s[3] as float) > 0.0:
				var bs := BoxShape3D.new()
				bs.size = Vector3(s[3], 2.4, s[4])
				cs.shape = bs
				cs.position = s[0]
				cs.rotation.y = s[2]
			else:
				var cy := CylinderShape3D.new()
				cy.radius = (s[1] as float) * 0.97
				cy.height = 2.7
				cs.shape = cy
				cs.position = s[0]
			body.add_child(cs)
		host.add_child(body)
	# Ocak taşları ve odun (lod 0–1), sancaklar
	var det := B.new("rubble")
	var wd := B.new("wood")
	var fl := B.new()
	if lod <= 1:
		for fp2 in fire_pts:
			var fy := K.gy(fp2.x, fp2.y)
			det.cylp(Vector3(fp2.x, fy + 0.08, fp2.y), 0.65, 0.18, K.TAS.darkened(0.2), 8)
			det.cylp(Vector3(fp2.x, fy + 0.2, fp2.y), 0.35, 0.1, Color("2a2420"), 8)
			if lod == 0:
				for q in 3:
					wd.cylp(Vector3(fp2.x + cos(q * 2.1) * 0.9, fy + 0.15, fp2.y + sin(q * 2.1) * 0.9), 0.08, 0.7, K.AHSAP_A, 5, -1.0, Vector3(90, q * 60.0, 0))
				det.solid_cyl(Vector3(fp2.x, fy + 0.1, fp2.y), 0.6, 0.2)
	if K.gece and lod == 0:
		# alev yalnız yakın katmanda ve üç ocaktan birinde (ŞEHİR-3: sık çadır denizinde gece 5–10 bin çizim oluyordu;
		# uzak ordu ateşleri IstHayat'ın "ordu_ates" katmanında)
		var fi := 0
		for fp3 in fire_pts:
			fi += 1
			if fi % 3 == 0:
				Flame.add(host, Vector3(fp3.x, K.gy(fp3.x, fp3.y) + 0.22, fp3.y), 0.4, 0.6)
	for bp in flag_pts:
		var by := K.gy(bp.x, bp.y)
		var col: Color = info["bant"]
		wd.cylp(Vector3(bp.x, by + 3.0, bp.y), 0.05, 6.0, K.AHSAP2, 5)
		fl.box(Vector3(bp.x + 0.5, by + 5.3, bp.y), Vector3(1.0, 1.3, 0.03), col)
		fl.box(Vector3(bp.x + 0.5, by + 5.3, bp.y), Vector3(0.5, 0.5, 0.035), K.KREM)
		if lod == 0:
			fl.sph(Vector3(bp.x, by + 6.1, bp.y), 0.11, K.ALTIN, 4)
			wd.solid_cyl(Vector3(bp.x, by + 3.0, bp.y), 0.08, 6.0)
	det.done(host, "ocak")
	wd.done(host, "odun")
	fl.done(host, "bayrak")
	host.set_meta("cadir_sayisi", round_x.size() + cati_x.size())
	return {"cadir": round_x.size() + cati_x.size(), "ocak": fire_pts.size(), "bayrak": flag_pts.size()}
