class_name IstOrdugahOba
extends RefCounted
## Çadır kanadı doldurucu (ORDUGÂH-4, docs/ORDUGAH_1453.md §2.1–2.5, §3, §7a–7b): ızgara YOK. Alan, kenarlarında yol
## koridoru (komşu alanla 10–12 m'lik ortak yol) ve ortasında sura koşut bir ara yol bırakılarak OBALARA bölünür: her obada
## ortada bey/oda çadırı ve sancağı, önünde ocak/kazan ve çevresinde oturanlar, etrafında 3–7 m çaplı, üç biçimli (konik,
## çatma, başıbozukta çalı barınağı) çeşitli boy ve tonda çadırlar. Obalar arasında çiğnenmiş zemin, at kazıkları, deve
## çökeği, koyun sürüsü, odun yığını, çamaşır ipi. Renk §2.5: krem/bej/kıl; kırmızı YOK (yalnız otağ ve paşalar).
## Kişiler IstOrdugahKisi ile (lod 0 gerçek model, lod 1 hafif figür).

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const B = K.Bld
const KS = preload("res://scripts/world/ist/ordugah_kisi.gd")

## §2.5 paleti: [renk, ağırlık]
const PALET := {
	"genel": [[Color("d9ccaa"), 40], [Color("b8a882"), 20], [Color("6a563c"), 12], [Color("8f8064"), 10], [Color("efe6cc"), 6], [Color("c4b590"), 12]],
	"yeniceri": [[Color("efe6cc"), 30], [Color("d9ccaa"), 45], [Color("b8a882"), 15], [Color("c4b590"), 10]],
	"basibozuk": [[Color("8f8064"), 35], [Color("6a563c"), 30], [Color("b8a882"), 20], [Color("a09070"), 15]],
}
## Sancak oranı §5.2: kırmızı %45, yeşil %25, beyaz %15, sarı %10, lacivert %5 (hilal YOK)
const SANCAK := [[Color("a8262b"), 45], [Color("3f6b3d"), 25], [Color("ece4cc"), 15], [Color("d0a43c"), 10], [Color("28366a"), 5]]

const TUR := {
	"yeniceri": {"palet": "yeniceri", "oba_ara": 24.0, "oba_r": [10.0, 13.0], "cati": 0.15, "bark": 0.0, "kazan": true,
		"kisi": ["otur", "otur", "otur2", "nobet", "okcu", "uyuyan", "bileyen"], "sipahi": 0.1},
	"anadolu": {"palet": "genel", "oba_ara": 27.0, "oba_r": [10.0, 14.0], "cati": 0.35, "bark": 0.05, "kazan": false,
		"kisi": ["otur2", "otur2", "otur", "azap", "sipahi", "uyuyan", "balta"], "sipahi": 0.35},
	"rumeli": {"palet": "genel", "oba_ara": 27.0, "oba_r": [10.0, 14.0], "cati": 0.3, "bark": 0.05, "kazan": false,
		"kisi": ["otur2", "otur2", "otur", "azap", "sipahi", "uyuyan", "balta"], "sipahi": 0.35},
	"zaganos": {"palet": "genel", "oba_ara": 28.0, "oba_r": [10.0, 13.0], "cati": 0.25, "bark": 0.05, "kazan": false,
		"kisi": ["otur2", "otur", "azap", "azap", "kazma", "balta"], "sipahi": 0.2},
	"basibozuk": {"palet": "basibozuk", "oba_ara": 22.0, "oba_r": [8.0, 12.0], "cati": 0.3, "bark": 0.55, "kazan": false,
		"kisi": ["otur2", "otur2", "azap", "uyuyan", "balta"], "sipahi": 0.0},
	"hizmet": {"palet": "genel", "oba_ara": 24.0, "oba_r": [9.0, 12.0], "cati": 0.5, "bark": 0.1, "kazan": true,
		"kisi": ["asci", "saka", "otur2", "bileyen"], "sipahi": 0.0},
}


static func _sec(r: RandomNumberGenerator, tablo: Array) -> Color:
	var top := 0
	for e: Array in tablo:
		top += int(e[1])
	var x := r.randi() % top
	for e: Array in tablo:
		x -= int(e[1])
		if x < 0:
			return e[0]
	return tablo[0][0]


## §2.5 çap dağılımı: küçük 3,0–3,6 %35; orta 4,2–5,0 %45; büyük 5,5–7,0 %20
static func _cap(r: RandomNumberGenerator) -> float:
	var x := r.randf()
	if x < 0.35:
		return r.randf_range(3.0, 3.6)
	if x < 0.8:
		return r.randf_range(4.2, 5.0)
	return r.randf_range(5.5, 7.0)


class Yer:
	var daire: Array = []          # [Vector2, r]
	func bos(p: Vector2, r: float) -> bool:
		for d: Array in daire:
			if p.distance_to(d[0]) < r + float(d[1]):
				return false
		return true
	func ekle(p: Vector2, r: float) -> void:
		daire.append([p, r])


static func build(host: Node3D, alan: PackedVector2Array, tur: String, k: float, lod: int, tohum := 1) -> Dictionary:
	var info: Dictionary = TUR.get(tur, TUR["rumeli"])
	var r := K.rr(tohum)
	var palet: Array = PALET[info["palet"]]
	var ang := 0.0
	if alan.size() >= 2:
		var e := alan[1] - alan[0]
		ang = atan2(e.y, e.x)
	var rot := Transform2D(ang, Vector2.ZERO)
	var inv := rot.affine_inverse()
	var lp := PackedVector2Array()
	for p in alan:
		lp.append(inv * p)
	var bb := K.poly_bounds(lp)
	var yer := Yer.new()
	# --- kenar yolları (komşu alanla ortak) ve ara yol: bb'nin içinde 5,5 m pay; ortada sura koşut 4 m'lik yol
	var pay := 5.5
	var ic := bb.grow(-pay)
	var ara_y := ic.position.y + ic.size.y * r.randf_range(0.42, 0.58)
	var ara_x := ic.position.x + ic.size.x * r.randf_range(0.35, 0.65)
	var ok_at := func(lpos: Vector2, rad: float) -> bool:
		if not ic.grow(-rad).has_point(lpos):
			return false
		if absf(lpos.y - ara_y) < 2.2 + rad or absf(lpos.x - ara_x) < 1.6 + rad:
			return false
		var w := rot * lpos
		if not K.in_poly(w, alan):
			return false
		if K.filtre.is_valid() and not bool(K.filtre.call(w.x, w.y)):
			return false
		return true
	# --- oba merkezleri (dart atışı)
	var obalar: Array = []          # [lpos, R]
	var ara: float = info["oba_ara"]
	for t in 90:
		var lpos := Vector2(r.randf_range(ic.position.x, ic.end.x), r.randf_range(ic.position.y, ic.end.y))
		var R := r.randf_range(info["oba_r"][0], info["oba_r"][1])
		if not bool(ok_at.call(lpos, 3.5)):
			continue
		var uzak := true
		for o: Array in obalar:
			if lpos.distance_to(o[0]) < ara:
				uzak = false
				break
		if uzak:
			obalar.append([lpos, R])
	var round_x: Array = []
	var round_c: Array = []
	var cati_x: Array = []
	var cati_c: Array = []
	var bark_x: Array = []
	var bark_c: Array = []
	var shapes: Array = []
	var fires: Array = []          # yerel (x, z)
	var kisi: Array = []
	var hay := PackedVector3Array()
	var det := B.new("rubble")
	var met := B.new("")
	var wd := B.new("wood")
	var fl := B.new()
	var an := B.new("")
	var cnt := 0
	for o: Array in obalar:
		var oc: Vector2 = o[0]
		var R: float = o[1]
		# obanın "önü" (ocak, toplanma yeri): rastgele yön
		var fa := r.randf() * TAU
		var fv := Vector2.from_angle(fa)
		# bey/oda çadırı ortada (büyük: 6–8 m çap, bazen çatma 7–9 × 5 m)
		var bey_cap := r.randf_range(6.0, 8.2) if tur != "basibozuk" else r.randf_range(4.6, 5.6)
		var bc := _sec(r, palet).lerp(Color("efe6cc"), 0.35)
		var w0 := rot * oc
		if r.randf() < 0.3 and tur != "basibozuk":
			var ln := bey_cap * 1.15
			var wi := bey_cap * 0.7
			var yaw := ang + fa + PI / 2.0
			cati_x.append(Transform3D(Basis.from_euler(Vector3(0, -yaw, 0)).scaled(Vector3(ln, 1.9, wi)), Vector3(w0.x, K.gy(w0.x, w0.y) - 0.1, w0.y)))
			cati_c.append(bc)
			shapes.append([Vector3(w0.x, K.gy(w0.x, w0.y) + 1.5, w0.y), maxf(ln, wi) * 0.5, -yaw, ln, wi])
		else:
			var rr := bey_cap * 0.5
			round_x.append(Transform3D(Basis.from_euler(Vector3(0, r.randf() * TAU, 0)).scaled(Vector3(rr, r.randf_range(1.35, 1.6), rr)), Vector3(w0.x, K.gy(w0.x, w0.y) - 0.1, w0.y)))
			round_c.append(bc)
			shapes.append([Vector3(w0.x, K.gy(w0.x, w0.y) + 1.6, w0.y), rr, 0.0, 0.0, 0.0])
		yer.ekle(oc, bey_cap * 0.5 + 0.8)
		cnt += 1
		# sancak bey çadırının yanında (her obada değil: üçte iki)
		var sp_l := oc + fv.rotated(0.9) * (bey_cap * 0.5 + 1.2)
		if r.randf() < 0.66:
			var swp := rot * sp_l
			_sancak(wd, fl, Vector3(swp.x, K.gy(swp.x, swp.y), swp.y), r.randf_range(5.0, 7.5), _sec(r, SANCAK), lod, r.randf() < 0.12)
			yer.ekle(sp_l, 0.4)
		# ocak/kazan önde
		var ocl := oc + fv * (bey_cap * 0.5 + 4.2)
		var ocw := rot * ocl
		var oy := K.gy(ocw.x, ocw.y)
		det.cylp(Vector3(ocw.x, oy + 0.1, ocw.y), 0.75, 0.22, K.TAS.darkened(0.25), 8)
		det.cylp(Vector3(ocw.x, oy + 0.22, ocw.y), 0.45, 0.06, Color("2a2420"), 8)
		var kazanli: bool = info["kazan"] or r.randf() < 0.35
		if kazanli and lod <= 1:
			met.cylp(Vector3(ocw.x, oy + 0.62, ocw.y), 0.5, 0.62, K.BRONZ.lightened(0.08), 10, 0.58)
			met.cylp(Vector3(ocw.x, oy + 0.95, ocw.y), 0.6, 0.06, K.BRONZ.darkened(0.25), 10)
			if lod == 0:
				for q in 3:
					var qa := q * TAU / 3.0
					wd.rod(Vector3(ocw.x + cos(qa) * 0.9, oy, ocw.y + sin(qa) * 0.9), Vector3(ocw.x, oy + 1.6, ocw.y), 0.06, K.AHSAP2)
		fires.append(ocw)
		yer.ekle(ocl, 1.0)
		# ocak başında oturanlar (halka) + aşçı
		var nsit := r.randi_range(4, 7) if tur != "basibozuk" else r.randi_range(3, 5)
		var a0 := r.randf() * TAU
		for i in nsit:
			var aa := a0 + i * TAU / nsit + r.randf_range(-0.15, 0.15)
			var pl := ocl + Vector2.from_angle(aa) * r.randf_range(1.9, 2.4)
			var pw := rot * pl
			var tl: Array = info["kisi"]
			var tp: String = "otur" if tur == "yeniceri" else ("otur2" if r.randf() < 0.7 else "otur")
			if i == 0 and tur in ["yeniceri", "hizmet"]:
				tp = "asci"
				pl = ocl + Vector2.from_angle(aa) * 1.05
				pw = rot * pl
			var face := (ocw - pw)
			kisi.append([Vector3(pw.x, K.gy(pw.x, pw.y), pw.y), atan2(face.x, face.y), tp])
			yer.ekle(pl, 0.45)
		# çevre çadırları (önde 80°'lik açık kesit)
		var n_t := r.randi_range(7, 16) if tur != "basibozuk" else r.randi_range(6, 12)
		var placed := 0
		for t in n_t * 6:
			if placed >= n_t:
				break
			var cap := _cap(r)
			var tr := cap * 0.5
			var aa := r.randf() * TAU
			if absf(wrapf(aa - fa, -PI, PI)) < 0.7:
				continue
			var dist := r.randf_range(bey_cap * 0.5 + tr + 1.6, R + tr)
			var pl := oc + Vector2.from_angle(aa) * dist
			if not bool(ok_at.call(pl, tr + 0.4)) or not yer.bos(pl, tr + 1.0):
				continue
			yer.ekle(pl, tr + 0.7)
			placed += 1
			cnt += 1
			var pw := rot * pl
			var yg := K.gy(pw.x, pw.y)
			var c2 := K.ton(_sec(r, palet), r, 0.04)
			var u := r.randf()
			if u < float(info["bark"]):
				var ln2 := r.randf_range(2.6, 4.0)
				var wi2 := r.randf_range(2.2, 3.0)
				var yaw2 := ang + r.randf() * TAU
				bark_x.append(Transform3D(Basis.from_euler(Vector3(0, -yaw2, 0)).scaled(Vector3(ln2, r.randf_range(1.0, 1.4), wi2)), Vector3(pw.x, yg - 0.05, pw.y)))
				bark_c.append(c2.darkened(0.1))
				shapes.append([Vector3(pw.x, yg + 0.7, pw.y), maxf(ln2, wi2) * 0.5, -yaw2, ln2, wi2])
			elif u < float(info["bark"]) + float(info["cati"]):
				var ln3 := cap * r.randf_range(1.05, 1.3)
				var wi3 := cap * r.randf_range(0.7, 0.85)
				# kapı obanın ortasına bakar
				var to_c := oc - pl
				var yaw3 := ang + atan2(to_c.y, to_c.x) + PI / 2.0 + r.randf_range(-0.2, 0.2)
				cati_x.append(Transform3D(Basis.from_euler(Vector3(0, -yaw3, 0)).scaled(Vector3(ln3, r.randf_range(1.2, 1.7), wi3)), Vector3(pw.x, yg - 0.1, pw.y)))
				cati_c.append(c2)
				shapes.append([Vector3(pw.x, yg + 1.2, pw.y), maxf(ln3, wi3) * 0.5, -yaw3, ln3, wi3])
			else:
				var hs := lerpf(0.85, 1.3, inverse_lerp(3.0, 7.0, cap)) * r.randf_range(0.92, 1.1)
				var to_c2 := (oc - pl).normalized()
				var yaw4 := atan2(-(rot.basis_xform(to_c2)).y, (rot.basis_xform(to_c2)).x) + PI / 2.0
				round_x.append(Transform3D(Basis.from_euler(Vector3(0, yaw4 + r.randf_range(-0.3, 0.3), 0)).scaled(Vector3(tr, hs, tr)), Vector3(pw.x, yg - 0.1, pw.y)))
				round_c.append(c2)
				shapes.append([Vector3(pw.x, yg + 1.35 * hs, pw.y), tr, 0.0, 0.0, 0.0])
			# çadır önünde: uyuklayan, kalkan/mızrak yaslı, halı (seyrek)
			if lod == 0 and r.randf() < 0.18:
				var dp := pl + (oc - pl).normalized() * (tr + 0.9)
				if yer.bos(dp, 0.5):
					var dw := rot * dp
					var fc := rot * oc - dw
					kisi.append([Vector3(dw.x, K.gy(dw.x, dw.y), dw.y), atan2(fc.x, fc.y), "uyuyan" if r.randf() < 0.5 else "bileyen"])
					yer.ekle(dp, 0.5)
		# bey çadırı kapısında nöbetçi çifti, obada ayakta sohbet eden ikili/üçlü
		for sd in [-1.0, 1.0]:
			var np_: Vector2 = oc + fv * (bey_cap * 0.5 + 0.9) + fv.orthogonal() * float(sd) * 1.2
			if yer.bos(np_, 0.4):
				var nw: Vector2 = rot * np_
				var fwv := rot.basis_xform(fv)
				kisi.append([Vector3(nw.x, K.gy(nw.x, nw.y), nw.y), atan2(fwv.x, fwv.y), "nobet" if tur == "yeniceri" else ("sipahi" if r.randf() < float(info["sipahi"]) else "azap")])
				yer.ekle(np_, 0.4)
		var grp := oc + fv.rotated(r.randf_range(-1.2, 1.2)) * (R + 2.5)
		var ng := r.randi_range(2, 3)
		var gc := rot * grp
		for i in ng:
			var gp := grp + Vector2.from_angle(i * TAU / ng + 0.4) * 0.85
			if not yer.bos(gp, 0.4) or not bool(ok_at.call(gp, 0.2)):
				continue
			var gw := rot * gp
			var fc2 := gc - gw
			var tl2: Array = info["kisi"]
			kisi.append([Vector3(gw.x, K.gy(gw.x, gw.y), gw.y), atan2(fc2.x, fc2.y), tl2[r.randi() % tl2.size()] if r.randf() < 0.4 else ("sipahi" if r.randf() < float(info["sipahi"]) else "azap")])
			yer.ekle(gp, 0.45)
		# odun yığını ve baltacı
		var odl := ocl + fv.orthogonal() * 3.4
		if yer.bos(odl, 1.2) and bool(ok_at.call(odl, 1.0)):
			var odw := rot * odl
			var oyy := K.gy(odw.x, odw.y)
			for q in 5:
				wd.cylp(Vector3(odw.x, oyy + 0.12 + (q % 2) * 0.2, odw.y - 0.5 + q * 0.25), 0.1, 1.3, K.AHSAP_A, 5, -1.0, Vector3(0, 0, 90), rad_to_deg(-ang))
			yer.ekle(odl, 1.0)
			if r.randf() < 0.5:
				var bl := odl + fv * 1.3
				var bw := rot * bl
				kisi.append([Vector3(bw.x, K.gy(bw.x, bw.y), bw.y), atan2((odw - bw).x, (odw - bw).y), "balta"])
	# --- obalar arası: at kazıkları (1–2 sıra), deve çökeği, koyun sürüsü, köpek, saka, yürüyen bölük
	var nat := 1 + int(r.randf() < 0.6)
	for t in nat:
		_at_sirasi(an, wd, r, rot, ok_at, yer, ic, kisi, hay, lod)
	if r.randf() < 0.45:
		_deve_cokegi(an, r, rot, ok_at, yer, ic, kisi, hay)
	if tur in ["basibozuk", "anadolu", "rumeli", "zaganos"] and r.randf() < 0.45:
		_koyun(an, r, rot, ok_at, yer, ic, kisi, hay)
	for t in r.randi_range(1, 2):
		var dl := Vector2(r.randf_range(ic.position.x, ic.end.x), ara_y + r.randf_range(-1.0, 1.0))
		var dw2 := rot * dl
		_kopek(an, Vector3(dw2.x, K.gy(dw2.x, dw2.y), dw2.y), r.randf() * 360.0, r)
		hay.append(Vector3(dw2.x, K.gy(dw2.x, dw2.y), dw2.y))
	# ara yolda yürüyen bölük (yeniçeri/azap kolu) ve sakalar
	if r.randf() < 0.6:
		var x0 := r.randf_range(ic.position.x + 6.0, ic.end.x - 20.0)
		var tp2 := "yuruyen" if tur == "yeniceri" else "azap"
		var dirv := rot.basis_xform(Vector2(1, 0))
		var yw := atan2(dirv.x, dirv.y)
		for i in r.randi_range(6, 10):
			var pl2 := Vector2(x0 + (i / 2) * 1.4, ara_y + (-0.55 if i % 2 == 0 else 0.55))
			var pw2 := rot * pl2
			if K.filtre.is_valid() and not bool(K.filtre.call(pw2.x, pw2.y)):
				continue
			kisi.append([Vector3(pw2.x, K.gy(pw2.x, pw2.y), pw2.y), yw, tp2])
	for t in r.randi_range(1, 3):
		var sl := Vector2(ara_x + r.randf_range(-0.6, 0.6), r.randf_range(ic.position.y, ic.end.y))
		var sw := rot * sl
		if K.filtre.is_valid() and not bool(K.filtre.call(sw.x, sw.y)):
			continue
		var dv := rot.basis_xform(Vector2(0, 1 if r.randf() < 0.5 else -1))
		kisi.append([Vector3(sw.x, K.gy(sw.x, sw.y), sw.y), atan2(dv.x, dv.y), "saka"])
	# --- çiziciler
	var mesh_round := K.tent_mesh("yuvarlak" if lod == 0 else "sade")
	K.mm(host, mesh_round, round_x, round_c, "yuvarlak", "plaster", lod == 0)
	K.mm(host, K.tent_mesh("cati" if lod == 0 else "sade_cati"), cati_x, cati_c, "cati", "plaster", lod == 0)
	K.mm(host, K.tent_mesh("bark" if lod == 0 else "sade_cati"), bark_x, bark_c, "bark", "plaster", lod == 0)
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
	if lod <= 1:
		det.done(host, "ocak")
		met.done(host, "kazan")
		wd.done(host, "odun")
		fl.done(host, "bayrak")
		an.done(host, "hayvan")
		KS.kur(host, kisi, lod)
		host.set_meta("hayvanlar", hay)
		K.ateslar(host, fires, lod)
	else:
		fl.done(host, "bayrak")
	host.set_meta("cadir_sayisi", round_x.size() + cati_x.size() + bark_x.size())
	return {"cadir": round_x.size() + cati_x.size() + bark_x.size(), "oba": obalar.size(), "kisi": kisi.size(), "hayvan": hay.size()}


## Çatallı flama (hilalsiz, düz renk; ortasında okunmaz hat çizgisi) ya da tuğ (at kuyruğu)
static func _sancak(w: B, f: B, p: Vector3, h: float, col: Color, lod: int, tug := false) -> void:
	w.cylp(p + Vector3(0, h * 0.5, 0), 0.05, h, K.AHSAP2, 5)
	if lod == 0:
		w.solid_cyl(p + Vector3(0, h * 0.5, 0), 0.07, h)
	f.sph(p + Vector3(0, h + 0.12, 0), 0.12, K.ALTIN, 4)
	if tug:
		f.cylp(p + Vector3(0, h - 0.75, 0), 0.26, 1.2, [Color("1e1a16"), Color("e9e2d0"), Color("8a2a22")][int(absf(p.x)) % 3], 6, 0.04)
		f.cylp(p + Vector3(0, h - 0.1, 0), 0.08, 0.25, K.ALTIN, 5)
		return
	var y0 := h - 0.15
	var L := 1.9
	var H := 0.9
	# iki uçlu (çatallı) flama: üst ve alt dil
	f.poly([p + Vector3(0.05, y0, 0), p + Vector3(L, y0 - 0.25, 0), p + Vector3(L * 0.7, y0 - H * 0.5, 0), p + Vector3(0.05, y0 - H * 0.5, 0)], Vector3(0, 0, 1), col)
	f.poly([p + Vector3(0.05, y0, 0), p + Vector3(L, y0 - 0.25, 0), p + Vector3(L * 0.7, y0 - H * 0.5, 0), p + Vector3(0.05, y0 - H * 0.5, 0)], Vector3(0, 0, -1), col.darkened(0.1))
	f.poly([p + Vector3(0.05, y0 - H * 0.5, 0), p + Vector3(L * 0.7, y0 - H * 0.5, 0), p + Vector3(L, y0 - H + 0.1, 0), p + Vector3(0.05, y0 - H, 0)], Vector3(0, 0, 1), col)
	f.poly([p + Vector3(0.05, y0 - H * 0.5, 0), p + Vector3(L * 0.7, y0 - H * 0.5, 0), p + Vector3(L, y0 - H + 0.1, 0), p + Vector3(0.05, y0 - H, 0)], Vector3(0, 0, -1), col.darkened(0.1))
	if lod == 0:
		var hc := Color("efe6cc") if col.get_luminance() < 0.6 else Color("6a3a20")
		f.box(p + Vector3(0.6, y0 - H * 0.42, 0), Vector3(0.75, 0.06, 0.035), hc)


static func _rastgele(r: RandomNumberGenerator, ic: Rect2, ok_at: Callable, yer: Yer, rad: float) -> Vector2:
	for t in 40:
		var lp := Vector2(r.randf_range(ic.position.x, ic.end.x), r.randf_range(ic.position.y, ic.end.y))
		if bool(ok_at.call(lp, rad)) and yer.bos(lp, rad):
			return lp
	return Vector2.INF


## At kazığı sırası (6–10 at) + seyis
static func _at_sirasi(an: B, wd: B, r: RandomNumberGenerator, rot: Transform2D, ok_at: Callable, yer: Yer, ic: Rect2, kisi: Array, hay: PackedVector3Array, lod: int) -> void:
	var n := r.randi_range(6, 10)
	var span := 2.2
	var lp := _rastgele(r, ic, ok_at, yer, n * span * 0.5 + 2.0)
	if lp == Vector2.INF:
		return
	yer.ekle(lp, n * span * 0.5 + 1.5)
	var dirl := Vector2(1, 0)
	var x0 := lp - dirl * (n - 1) * span * 0.5
	var pa := rot * (x0 - dirl * 1.0)
	var pb := rot * (x0 + dirl * ((n - 1) * span + 1.0))
	var ya := K.gy(pa.x, pa.y)
	var yb := K.gy(pb.x, pb.y)
	wd.rod(Vector3(pa.x, ya + 1.15, pa.y), Vector3(pb.x, yb + 1.15, pb.y), 0.04, K.DERI.darkened(0.3))
	for i in n + 1:
		var q := rot * (x0 + dirl * (i - 0.5) * span)
		wd.cylp(Vector3(q.x, K.gy(q.x, q.y) + 0.7, q.y), 0.07, 1.4, K.AHSAP2, 5)
	var dv := rot.basis_xform(Vector2(0, 1))
	var yaw := rad_to_deg(atan2(dv.x, dv.y))
	var renk := [Color("6a4a30"), Color("8a6a46"), Color("3a2e26"), Color("a88a62"), Color("c9b080"), Color("5a4434")]
	for i in n:
		var q2 := rot * (x0 + dirl * i * span + Vector2(0, 1.5))
		var y := K.gy(q2.x, q2.y)
		IstOrdugahYapi2._at(an, Vector3(q2.x, y, q2.y), yaw + r.randf_range(-8, 8), renk[r.randi() % renk.size()], false)
		hay.append(Vector3(q2.x, y, q2.y))
		# yem (saman)
		var q3 := rot * (x0 + dirl * i * span + Vector2(0, -0.9))
		an.cylp(Vector3(q3.x, K.gy(q3.x, q3.y) + 0.2, q3.y), 0.45, 0.4, K.SAMAN, 6, 0.1)
	# seyis: atın yanında (tımar)
	var sl := x0 + dirl * r.randi_range(0, n - 1) * span + Vector2(0.9, 1.5)
	var sw := rot * sl
	var fv := rot.basis_xform(Vector2(-1, 0))
	kisi.append([Vector3(sw.x, K.gy(sw.x, sw.y), sw.y), atan2(fv.x, fv.y), "seyis"])
	var sl2 := x0 + dirl * (n + 0.5) * span + Vector2(0, -0.5)
	var sw2 := rot * sl2
	kisi.append([Vector3(sw2.x, K.gy(sw2.x, sw2.y), sw2.y), atan2(fv.x, fv.y), "saka"])


## Çökmüş deve grubu (3–5) + yük
static func _deve_cokegi(an: B, r: RandomNumberGenerator, rot: Transform2D, ok_at: Callable, yer: Yer, ic: Rect2, kisi: Array, hay: PackedVector3Array) -> void:
	var lp := _rastgele(r, ic, ok_at, yer, 6.0)
	if lp == Vector2.INF:
		return
	yer.ekle(lp, 6.0)
	for i in r.randi_range(3, 5):
		var q := lp + Vector2.from_angle(i * 1.7) * r.randf_range(1.5, 4.0)
		var w := rot * q
		var y := K.gy(w.x, w.y)
		var yaw := r.randf() * 360.0
		_deve_yatan(an, Vector3(w.x, y, w.y), yaw, Color("b49a6c").lerp(Color("8a7048"), r.randf()))
		hay.append(Vector3(w.x, y, w.y))
	# yük çuvalları
	var cw := rot * (lp + Vector2(0, 2.5))
	for i in 4:
		an.box(Vector3(cw.x + i * 0.65, K.gy(cw.x, cw.y) + 0.25, cw.y), Vector3(0.6, 0.45, 0.85), K.SAMAN.darkened(0.15 * (i % 2)), rad_to_deg(r.randf()))
	var dw := rot * (lp + Vector2(1.6, 2.5))
	kisi.append([Vector3(dw.x, K.gy(dw.x, dw.y), dw.y), r.randf() * TAU, "saka"])


static func _deve_yatan(b: B, p: Vector3, yaw: float, col: Color) -> void:
	var f := func(v: Vector3) -> Vector3:
		return p + v.rotated(Vector3.UP, deg_to_rad(yaw))
	b.box(f.call(Vector3(0, 0.45, 0)), Vector3(0.95, 0.75, 2.0), col, yaw)
	b.sph(f.call(Vector3(0, 1.0, -0.1)), 0.48, col.darkened(0.05), 5, Vector3(1.0, 0.9, 1.3))
	b.rod(f.call(Vector3(0, 0.7, 0.9)), f.call(Vector3(0, 1.6, 1.4)), 0.26, col)
	b.box(f.call(Vector3(0, 1.65, 1.65)), Vector3(0.28, 0.28, 0.6), col.darkened(0.08), yaw)
	b.box(f.call(Vector3(0, 0.12, 0)), Vector3(1.4, 0.22, 2.2), col.darkened(0.2), yaw)     # kıvrık bacaklar


## Koyun sürüsü (12–24) + çoban + köpek
static func _koyun(an: B, r: RandomNumberGenerator, rot: Transform2D, ok_at: Callable, yer: Yer, ic: Rect2, kisi: Array, hay: PackedVector3Array) -> void:
	var lp := _rastgele(r, ic, ok_at, yer, 7.0)
	if lp == Vector2.INF:
		return
	yer.ekle(lp, 7.0)
	var yon := r.randf() * 360.0
	for i in r.randi_range(12, 24):
		var q := lp + Vector2(r.randfn(0.0, 2.6), r.randfn(0.0, 1.8))
		var w := rot * q
		var y := K.gy(w.x, w.y)
		var c := Color("e4dccb").lerp(Color("8a7a66"), r.randf() * r.randf())
		var yaw := yon + r.randf_range(-40, 40)
		var f := func(v: Vector3) -> Vector3:
			return Vector3(w.x, y, w.y) + v.rotated(Vector3.UP, deg_to_rad(yaw))
		an.sph(f.call(Vector3(0, 0.5, 0)), 0.38, c, 5, Vector3(0.85, 0.75, 1.3))
		an.box(f.call(Vector3(0, 0.55, 0.5)), Vector3(0.18, 0.2, 0.28), Color("3a3028"), yaw)
		an.box(f.call(Vector3(0, 0.17, 0)), Vector3(0.36, 0.34, 0.6), Color("4a3e34"), yaw)
		hay.append(Vector3(w.x, y, w.y))
	var cw := rot * (lp + Vector2(4.5, 0))
	kisi.append([Vector3(cw.x, K.gy(cw.x, cw.y), cw.y), r.randf() * TAU, "seyis"])
	var kw := rot * (lp + Vector2(-4.0, 1.5))
	_kopek(an, Vector3(kw.x, K.gy(kw.x, kw.y), kw.y), r.randf() * 360.0, r)
	hay.append(Vector3(kw.x, K.gy(kw.x, kw.y), kw.y))


static func _kopek(b: B, p: Vector3, yaw: float, r: RandomNumberGenerator) -> void:
	var c: Color = [Color("8a6a46"), Color("a89a80"), Color("5a4a3a"), Color("c8a468")][r.randi() % 4]
	var f := func(v: Vector3) -> Vector3:
		return p + v.rotated(Vector3.UP, deg_to_rad(yaw))
	b.box(f.call(Vector3(0, 0.42, 0)), Vector3(0.26, 0.26, 0.7), c, yaw)
	b.box(f.call(Vector3(0, 0.58, 0.42)), Vector3(0.2, 0.2, 0.3), c.darkened(0.08), yaw)
	for sx in [-1, 1]:
		for sz in [-0.25, 0.25]:
			b.box(f.call(Vector3(sx * 0.09, 0.15, sz)), Vector3(0.07, 0.3, 0.07), c.darkened(0.2), yaw)
	b.box(f.call(Vector3(0, 0.55, -0.42)), Vector3(0.05, 0.05, 0.3), c, yaw, Vector3(-40, 0, 0))
