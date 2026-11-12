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
const OC = preload("res://scripts/world/ist/ordugah_ocak.gd")

## §2.5 paleti: [renk, ağırlık]
const PALET := {
	"genel": [[Color("d9ccaa"), 40], [Color("b8a882"), 20], [Color("6a563c"), 12], [Color("8f8064"), 10], [Color("efe6cc"), 6], [Color("c4b590"), 12]],
	"yeniceri": [[Color("efe6cc"), 30], [Color("d9ccaa"), 45], [Color("b8a882"), 15], [Color("c4b590"), 10]],
	"basibozuk": [[Color("8f8064"), 35], [Color("6a563c"), 30], [Color("b8a882"), 20], [Color("a09070"), 15]],
}
## Sancak oranı §5.2: kırmızı %45, yeşil %25, beyaz %15, sarı %10, lacivert %5 (hilal YOK)
const SANCAK := [[Color("a8262b"), 45], [Color("3f6b3d"), 25], [Color("ece4cc"), 15], [Color("d0a43c"), 10], [Color("28366a"), 5]]

const TUR := {
	"yeniceri": {"palet": "yeniceri", "oba_ara": 21.0, "oba_r": [11.0, 15.0], "cati": 0.15, "bark": 0.0, "kazan": true,
		"kisi": ["otur", "otur", "otur2", "nobet", "okcu", "uyuyan", "bileyen"], "sipahi": 0.1},
	"anadolu": {"palet": "genel", "oba_ara": 23.0, "oba_r": [12.0, 16.0], "cati": 0.35, "bark": 0.05, "kazan": false,
		"kisi": ["otur2", "otur2", "otur", "azap", "sipahi", "uyuyan", "balta"], "sipahi": 0.35},
	"rumeli": {"palet": "genel", "oba_ara": 23.0, "oba_r": [12.0, 16.0], "cati": 0.3, "bark": 0.05, "kazan": false,
		"kisi": ["otur2", "otur2", "otur", "azap", "sipahi", "uyuyan", "balta"], "sipahi": 0.35},
	"zaganos": {"palet": "genel", "oba_ara": 23.0, "oba_r": [11.0, 15.0], "cati": 0.25, "bark": 0.05, "kazan": false,
		"kisi": ["otur2", "otur", "azap", "azap", "kazma", "balta"], "sipahi": 0.2},
	"basibozuk": {"palet": "basibozuk", "oba_ara": 19.0, "oba_r": [9.0, 13.0], "cati": 0.3, "bark": 0.55, "kazan": false,
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
	var r5 := K.rr(tohum * 7919 + 5)      # ORDUGÂH-5: yeni kararlar ayrı dizide (yerleşim ÖNCE ile aynı kalsın)
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
	for t in 260:
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
	# ORDUGÂH-5: kumaş çadır türleri (ordugah_cadir.gd): tür → [dönüşümler, renkler]
	var cad := {"koni": [round_x, round_c], "catma": [cati_x, cati_c], "barinak": [bark_x, bark_c], "can": [[], []], "buyuk": [[], []], "kil": [[], []]}
	var ocak3: Array = []          # ocak noktaları (Vector3, yerel): duman, ışık
	var ana_ocak: Array = []
	var mesale: Array = []
	var onler: Array = []          # ORDUGÂH-5: çamaşır ipi için çadır noktaları
	var zs := B.new("")            # ORDUGÂH-5: yumuşak kenarlı zemin (lod 0–1)
	var shapes: Array = []
	var fires: Array = []          # yerel (x, z)
	var kisi: Array = []
	var hay := PackedVector3Array()
	# orta/uzak katmanda bütün durağan gereç TEK ağ (çizim bütçesi); yakında desenli ayrı ağlar
	var det := B.new("rubble")
	var met := B.new("") if lod == 0 else det
	var wd := B.new("wood") if lod == 0 else det
	var fl := B.new() if lod == 0 else det
	var an := B.new("") if lod == 0 else det
	var cnt := 0
	var zem := B.new("") if lod == 0 else det
	if lod == 0:
		zem.cast = false
	# çiğnenmiş ara yol (çamur şeridi) sura koşut ve dik
	if lod <= 1:
		OC.yol(zs, Vector2(ic.position.x - pay, ara_y), Vector2(ic.end.x + pay, ara_y), 4.2, Color("7a6648"), r, rot)
		OC.yol(zs, Vector2(ara_x, ic.position.y - pay), Vector2(ara_x, ic.end.y + pay), 3.2, Color("7d6a4c"), r, rot)
	else:
		_serit(zem, rot, Vector2(ic.position.x - pay, ara_y), Vector2(ic.end.x + pay, ara_y), 3.6, Color("7a6648"), r)
		_serit(zem, rot, Vector2(ara_x, ic.position.y - pay), Vector2(ara_x, ic.end.y + pay), 2.6, Color("7d6a4c"), r)
	# ORDUGÂH-5: obalar arası çiğnenmiş, solgun ot örtüsü (yumuşak kenarlı büyük lekeler; düz yeşil çayır kalmasın)
	if lod <= 1:
		var nl := int(clampf(ic.size.x * ic.size.y / 1100.0, 4.0, 16.0)) if lod == 0 else 4
		for t in nl:
			var lp0 := Vector2(r5.randf_range(ic.position.x - 3.0, ic.end.x + 3.0), r5.randf_range(ic.position.y - 3.0, ic.end.y + 3.0))
			if K.filtre.is_valid():
				var lw := rot * lp0
				if not bool(K.filtre.call(lw.x, lw.y)):
					continue
			OC.leke(zs, lp0, r5.randf_range(16.0, 26.0), Color("9c8d5e").lerp(Color("7d6e4c"), r5.randf() * 0.5), r5, rot, 0.55, 12)
	for o: Array in obalar:
		var oc: Vector2 = o[0]
		var R: float = o[1]
		# obanın altı: çiğnenmiş toprak/çamur lekesi (düzensiz on dört köşe, arazi izler)
		if lod <= 1:
			OC.leke(zs, oc, R + 5.0, Color("86714f").lerp(Color("6e5c40"), r.randf() * 0.6), r5, rot, 0.9, 16)
			for q in 14:
				r.randf()          # ÖNCE ile aynı yerleşim: eski _leke'nin rastgele dizisi korunur (yeni karar r5'te)
		else:
			_leke(zem, rot, oc, R + 3.5, Color("86714f").lerp(Color("6e5c40"), r.randf() * 0.6), r)
		# obanın "önü" (ocak, toplanma yeri): rastgele yön
		var fa := r.randf() * TAU
		var fv := Vector2.from_angle(fa)
		# bey/oda çadırı ortada (büyük: 6–8 m çap, bazen çatma 7–9 × 5 m)
		var bey_cap := r.randf_range(6.0, 8.2) if tur != "basibozuk" else r.randf_range(4.6, 5.6)
		var bc := _sec(r, palet).lerp(Color("efe6cc"), 0.35)
		var w0 := rot * oc
		# ORDUGÂH-5: bey/oda çadırı "büyük orta çadırı" (iki direkli, saçaklı) ya da çan çadır; başıbozukta kıl çadır.
		# Kapı (+z) ocağa bakar.
		var fw := rot.basis_xform(fv)
		var kyaw := atan2(fw.x, fw.y)
		var u_eski := r.randf()
		if not (u_eski < 0.3 and tur != "basibozuk"):
			r.randf()
			r.randf()
		if tur == "basibozuk" or r5.randf() < 0.62:
			var bk := "kil" if tur == "basibozuk" else "buyuk"
			var ln := bey_cap * (1.15 if bk == "buyuk" else 1.3)
			var wi := bey_cap * (0.78 if bk == "buyuk" else 0.7)
			(cad[bk][0] as Array).append(Transform3D(Basis(Vector3.UP, kyaw).scaled(Vector3(ln, r5.randf_range(0.95, 1.12), wi)), Vector3(w0.x, K.gy(w0.x, w0.y) - 0.1, w0.y)))
			(cad[bk][1] as Array).append(bc if bk == "buyuk" else K.ton(Color(0.95, 0.93, 0.9), r5, 0.05))
			shapes.append([Vector3(w0.x, K.gy(w0.x, w0.y) + 1.5, w0.y), maxf(ln, wi) * 0.5, -kyaw, ln, wi])
		else:
			var rr := bey_cap * 0.5
			(cad["can"][0] as Array).append(Transform3D(Basis(Vector3.UP, kyaw).scaled(Vector3(rr, r5.randf_range(1.05, 1.2), rr)), Vector3(w0.x, K.gy(w0.x, w0.y) - 0.1, w0.y)))
			(cad["can"][1] as Array).append(bc)
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
		var kazanli: bool = info["kazan"] or r.randf() < 0.35
		# ORDUGÂH-5: taş halka, çatılmış odun, kor, kül; sacayağında kazan ya da şişte et; odun yığını ve balta
		OC.ocak(det, wd, met, Vector3(ocw.x, oy, ocw.y), lod, r5, "kazan" if kazanli else ("sis" if r5.randf() < 0.5 else "sade"))
		if lod <= 1:
			OC.leke(zs, ocl, 2.6, Color("3e3830"), r5, rot, 0.75, 10)
		fires.append(ocw)
		ocak3.append(Vector3(ocw.x, oy, ocw.y))
		ana_ocak.append(Vector3(ocw.x, oy, ocw.y))
		yer.ekle(ocl, 2.3)
		# ocak başında oturanlar (halka) + aşçı
		var nsit := r.randi_range(4, 7) if tur != "basibozuk" else r.randi_range(3, 5)
		var a0 := r.randf() * TAU
		for i in nsit:
			var aa := a0 + i * TAU / nsit + r.randf_range(-0.15, 0.15)
			var pl := ocl + Vector2.from_angle(aa) * r.randf_range(1.9, 2.4)
			var pw := rot * pl
			var tl: Array = info["kisi"]
			var tp: String = "otur" if tur == "yeniceri" else ("otur2" if r.randf() < 0.7 else "otur")
			if i == 0 and (kazanli or tur in ["yeniceri", "hizmet"]):
				tp = "asci"
				pl = ocl + Vector2.from_angle(aa) * 1.05
				pw = rot * pl
			elif i == nsit - 1 and r5.randf() < 0.5:
				tp = "sohbet"             # ayakta, ateşe dönük konuşan
				pl = ocl + Vector2.from_angle(aa) * 2.7
				pw = rot * pl
			elif i == 1 and r5.randf() < 0.35:
				tp = "uyuyan"             # ateş başında uzanmış/uyuklayan
				pl = ocl + Vector2.from_angle(aa) * 2.9
				pw = rot * pl
			var face := (ocw - pw)
			kisi.append([Vector3(pw.x, K.gy(pw.x, pw.y), pw.y), atan2(face.x, face.y), tp])
			yer.ekle(pl, 0.45)
		# çevre çadırları (önde 80°'lik açık kesit)
		var n_t := r.randi_range(13, 24) if tur != "basibozuk" else r.randi_range(10, 18)
		var placed := 0
		for t in n_t * 9:
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
				cati_x.append(Transform3D(Basis.from_euler(Vector3(0, -yaw3, 0)).scaled(Vector3(ln3, r.randf_range(1.0, 1.35), wi3)), Vector3(pw.x, yg - 0.1, pw.y)))
				cati_c.append(c2)
				shapes.append([Vector3(pw.x, yg + 1.2, pw.y), maxf(ln3, wi3) * 0.5, -yaw3, ln3, wi3])
			else:
				var hs := lerpf(0.85, 1.2, inverse_lerp(3.0, 7.0, cap)) * r.randf_range(0.92, 1.1)
				var to_c2 := rot.basis_xform((oc - pl).normalized())
				var yaw4 := atan2(to_c2.x, to_c2.y) + r.randf_range(-0.3, 0.3)       # kapı (+z) obanın ortasına
				# ORDUGÂH-5: koni (tek direkli) / çan (duvarlı, saçaklı) / koyu kıl rengiyse kıl çadır (alçak, çok direkli)
				var ck := "koni"
				if c2.get_luminance() < 0.36:
					ck = "kil"
				elif r5.randf() < (0.55 if tur == "yeniceri" else 0.22):
					ck = "can"
					hs *= 0.92
				if ck == "kil":
					var ln4 := cap * 1.02          # yer dairesine sığsın (kişi/ocak çadırın içine düşmesin)
					var wi4 := cap * 0.66
					(cad["kil"][0] as Array).append(Transform3D(Basis(Vector3.UP, yaw4).scaled(Vector3(ln4, r5.randf_range(0.9, 1.1), wi4)), Vector3(pw.x, yg - 0.1, pw.y)))
					(cad["kil"][1] as Array).append(K.ton(Color(0.95, 0.93, 0.9), r5, 0.06))
					shapes.append([Vector3(pw.x, yg + 0.9, pw.y), maxf(ln4, wi4) * 0.5, -yaw4, ln4, wi4])
				else:
					(cad[ck][0] as Array).append(Transform3D(Basis(Vector3.UP, yaw4).scaled(Vector3(tr, hs, tr)), Vector3(pw.x, yg - 0.1, pw.y)))
					(cad[ck][1] as Array).append(c2)
					shapes.append([Vector3(pw.x, yg + 1.35 * hs, pw.y), tr, 0.0, 0.0, 0.0])
					if lod == 0:
						_cadir_onu(fl, wd, met, Vector2(pw.x, pw.y), Vector2(sin(yaw4), cos(yaw4)), tr, r5)
						onler.append([Vector2(pw.x, pw.y), tr])
			# çadır önünde: uyuklayan, kalkan/mızrak yaslı, halı (seyrek)
			if lod == 0 and r.randf() < 0.18:
				var dp := pl + (oc - pl).normalized() * (tr + 0.9)
				if yer.bos(dp, 0.5):
					var dw := rot * dp
					var fc := rot * oc - dw
					kisi.append([Vector3(dw.x, K.gy(dw.x, dw.y), dw.y), atan2(fc.x, fc.y), "uyuyan" if r.randf() < 0.5 else "bileyen"])
					yer.ekle(dp, 0.5)
		# ORDUGÂH-5: çamaşır ipi (iki komşu çadır arasında, iki sırık; asılı bez ve deri)
		if lod == 0 and onler.size() >= 2:
			_camasir(wd, fl, onler, r5)
		onler.clear()
		# ORDUGÂH-5: §5.3 her 3–5 çadıra bir ocak: çadırların arasına küçük ocaklar (çadır duvarına ≥ 3 m), başında 2–5 kişi
		var n_oc := maxi(1, int(round(placed / 4.0)))
		var kon := 0
		for t in 40:
			if kon >= n_oc:
				break
			var fa2 := r5.randf() * TAU
			var fp := oc + Vector2.from_angle(fa2) * r5.randf_range(bey_cap * 0.5 + 3.5, R + 2.5)
			if not yer.bos(fp, 2.5) or not bool(ok_at.call(fp, 1.2)):
				continue
			yer.ekle(fp, 2.2)
			kon += 1
			var fpw := rot * fp
			var fy := K.gy(fpw.x, fpw.y)
			OC.ocak(det, wd, met, Vector3(fpw.x, fy, fpw.y), lod, r5, "sis" if r5.randf() < 0.35 else ("kazan" if r5.randf() < 0.3 else "sade"), r5.randf() < 0.4)
			if lod <= 1:
				OC.leke(zs, fp, 2.2, Color("3e3830"), r5, rot, 0.7, 10)
			fires.append(fpw)
			if r5.randf() < 0.35:
				ocak3.append(Vector3(fpw.x, fy, fpw.y))      # duman: küçük ocakların üçte biri (70 m'den "çubuk ormanı" olmasın)
			var ns2 := r5.randi_range(2, 5)
			var b0 := r5.randf() * TAU
			for i in ns2:
				var aa2 := b0 + i * TAU / ns2 + r5.randf_range(-0.2, 0.2)
				var tp3: String = ["otur", "otur2", "otur2", "uyuyan", "sohbet", "bileyen"][r5.randi() % 6] if tur != "yeniceri" else ["otur", "otur", "uyuyan", "sohbet"][r5.randi() % 4]
				var dd := 1.95 if tp3 in ["otur", "otur2"] else (2.8 if tp3 == "uyuyan" else 2.5)
				var sp2 := fp + Vector2.from_angle(aa2) * dd
				var sw2 := rot * sp2
				var fc3 := fpw - sw2
				kisi.append([Vector3(sw2.x, K.gy(sw2.x, sw2.y), sw2.y), atan2(fc3.x, fc3.y), tp3])
		# bey çadırı kapısında nöbetçi çifti, obada ayakta sohbet eden ikili/üçlü
		for sd in [-1.0, 1.0]:
			var np_: Vector2 = oc + fv * (bey_cap * 0.5 + 0.9) + fv.orthogonal() * float(sd) * 1.2
			if yer.bos(np_, 0.4):
				var nw: Vector2 = rot * np_
				var fwv := rot.basis_xform(fv)
				kisi.append([Vector3(nw.x, K.gy(nw.x, nw.y), nw.y), atan2(fwv.x, fwv.y), "nobet" if tur == "yeniceri" else ("sipahi" if r.randf() < float(info["sipahi"]) else "azap")])
				yer.ekle(np_, 0.4)
		# ORDUGÂH-5: gece bey çadırı kapısında meşale (yere çakılı sırık + gerçek alev)
		if K.gece and lod <= 1:
			var mp := oc + fv * (bey_cap * 0.5 + 1.0)
			var mw := rot * mp
			var my := K.gy(mw.x, mw.y)
			wd.cylp(Vector3(mw.x, my + 1.05, mw.y), 0.035, 2.1, K.AHSAP2, 5)
			met.cylp(Vector3(mw.x, my + 2.12, mw.y), 0.07, 0.14, Color("2a2622"), 6, 0.09)
			mesale.append(mw)
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
	# --- obalar arası boşluğa tekil/ikili dağınık çadır ve barınak (boş çayır kalmasın; kümeler arası 6–12 m)
	for t in 120:
		var cap2 := _cap(r) * 0.85
		var lp2 := Vector2(r.randf_range(ic.position.x, ic.end.x), r.randf_range(ic.position.y, ic.end.y))
		if not bool(ok_at.call(lp2, cap2 * 0.5 + 0.4)) or not yer.bos(lp2, cap2 * 0.5 + 3.0):
			continue
		yer.ekle(lp2, cap2 * 0.5 + 0.8)
		var pw3 := rot * lp2
		var yg3 := K.gy(pw3.x, pw3.y)
		var c3 := K.ton(_sec(r, palet), r, 0.05)
		if r.randf() < 0.4:
			var yaw5 := ang + r.randf() * TAU
			bark_x.append(Transform3D(Basis.from_euler(Vector3(0, -yaw5, 0)).scaled(Vector3(cap2, r.randf_range(1.0, 1.3), cap2 * 0.75)), Vector3(pw3.x, yg3 - 0.05, pw3.y)))
			bark_c.append(c3.darkened(0.08))
			shapes.append([Vector3(pw3.x, yg3 + 0.7, pw3.y), cap2 * 0.5, -yaw5, cap2, cap2 * 0.75])
		else:
			round_x.append(Transform3D(Basis.from_euler(Vector3(0, r.randf() * TAU, 0)).scaled(Vector3(cap2 * 0.5, r.randf_range(0.85, 1.1), cap2 * 0.5)), Vector3(pw3.x, yg3 - 0.1, pw3.y)))
			round_c.append(c3)
			shapes.append([Vector3(pw3.x, yg3 + 1.3, pw3.y), cap2 * 0.5, 0.0, 0.0, 0.0])
		cnt += 1
	# --- obalar arası: at kazıkları (1–2 sıra), deve çökeği, koyun sürüsü, köpek, saka, yürüyen bölük
	var nat := (1 + int(r.randf() < 0.6)) if lod <= 1 else 0
	for t in nat:
		_at_sirasi(an, wd, r, rot, ok_at, yer, ic, kisi, hay, lod)
	if lod <= 1 and r.randf() < 0.45:
		_deve_cokegi(an, r, rot, ok_at, yer, ic, kisi, hay)
	if lod <= 1 and tur in ["basibozuk", "anadolu", "rumeli", "zaganos"] and r.randf() < 0.45:
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
	# --- çiziciler (ORDUGÂH-5: kumaş çadır ağları, katmana göre; desen yok: bez rengi köşe renginden)
	if lod >= 1:
		# orta/uzak katmanda türler iki ağda birleşir (çizim bütçesi): yuvarlaklar koni, dikdörtgenler çatma siluetiyle;
		# kıl çadırı koyu tonla, barınak alçak ve yamalı tonla
		var birlesik := {"koni": [[], []], "catma": [[], []]}
		for ck: String in cad:
			var hedef := "koni" if ck in ["koni", "can"] else "catma"
			var xs2: Array = cad[ck][0]
			var cs2: Array = cad[ck][1]
			for i in xs2.size():
				var xf2: Transform3D = xs2[i]
				var c3: Color = cs2[i]
				if ck == "kil":
					c3 = Color(0.36, 0.3, 0.25) * c3
				elif ck == "barinak":
					xf2 = Transform3D(xf2.basis * Basis.from_scale(Vector3(1.0, 0.55, 1.0)), xf2.origin)
					c3 = c3 * Color(0.8, 0.74, 0.62)
				(birlesik[hedef][0] as Array).append(xf2)
				(birlesik[hedef][1] as Array).append(c3)
		cad = birlesik
	for ck: String in cad:
		var xs: Array = cad[ck][0]
		if xs.is_empty():
			continue
		K.mm(host, K.tent_lod(ck, lod), xs, cad[ck][1], ck, "", lod == 0)
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
	if lod == 0:
		zem.done(host, "zemin")
		det.done(host, "ocak")
		met.done(host, "kazan")
		wd.done(host, "odun")
		fl.done(host, "bayrak")
		an.done(host, "hayvan")
	elif lod == 1:
		det.cast = false
		det.done(host, "gerec")
	var ncad := 0
	for ck: String in cad:
		ncad += (cad[ck][0] as Array).size()
	if lod <= 1:
		KS.kur(host, kisi, lod)
		host.set_meta("hayvanlar", hay)
		# ORDUGÂH-5: alev gündüz de yanar (gerçek alev, Flame), duman sütunu, gece sınırlı gerçek ışık
		K.ateslar(host, fires, lod, 0.2, true, 0.6, 1.0)
		OC.duman(host, ocak3, lod, r)
		OC.isik(host, ana_ocak, lod, 2)
		if not mesale.is_empty():
			var mf: Array = []
			for q: Vector2 in mesale:
				mf.append(Transform3D(Basis().scaled(Vector3(0.28, 0.5, 0.28)), Vector3(q.x, K.gy(q.x, q.y) + 2.18, q.y)))
			var mfl := Flame.scatter_flames(host, mf)
			mfl.name = "mesaleler"
		OC.zemin_bitir(zs, host)
	else:
		det.cast = false
		det.done(host, "gerec")
		host.set_meta("ates", fires)
	host.set_meta("ocak_sayisi", fires.size())
	host.set_meta("ocaklar", ana_ocak)
	host.set_meta("ocaklar_hepsi", ocak3)
	host.set_meta("cadir_sayisi", ncad)
	return {"cadir": ncad, "oba": obalar.size(), "kisi": kisi.size(), "hayvan": hay.size()}


## Arazi izleyen düzensiz leke (çiğnenmiş zemin): merkez + n köşe, zeminden 4 cm yukarıda, gölge düşürmez
static func _leke(b: B, rot: Transform2D, c: Vector2, R: float, col: Color, r: RandomNumberGenerator) -> void:
	var n := 14
	var cw := rot * c
	var cy := K.gy(cw.x, cw.y) + 0.05
	var pts: Array = []
	for i in n:
		var a := TAU * i / n
		var rr := R * r.randf_range(0.72, 1.12)
		var lp := c + Vector2.from_angle(a) * rr
		var w := rot * lp
		pts.append(Vector3(w.x, K.gy(w.x, w.y) + 0.04, w.y))
	for i in n:
		var j := (i + 1) % n
		var cc := col.darkened(0.04 * (i % 3))
		b.poly([Vector3(cw.x, cy, cw.y), pts[i], pts[j]], Vector3.UP, cc)


## Yol şeridi (yerel a → b, genişlik w), 6 m'lik parçalarla arazi izler
static func _serit(b: B, rot: Transform2D, a: Vector2, c: Vector2, w: float, col: Color, r: RandomNumberGenerator) -> void:
	var L := a.distance_to(c)
	if L < 1.0:
		return
	var d := (c - a) / L
	var nrm := Vector2(-d.y, d.x)
	var n := maxi(1, int(L / 6.0))
	for i in n:
		var p0 := a + d * (L * i / n)
		var p1 := a + d * (L * (i + 1) / n)
		var mw := rot * ((p0 + p1) * 0.5)
		if K.filtre.is_valid() and not bool(K.filtre.call(mw.x, mw.y)):
			continue
		var q: Array = []
		for v: Vector2 in [p0 - nrm * w * 0.5, p1 - nrm * w * 0.5, p1 + nrm * w * 0.5, p0 + nrm * w * 0.5]:
			var ww := rot * v
			q.append(Vector3(ww.x, K.gy(ww.x, ww.y) + 0.06, ww.y))
		b.poly(q, Vector3.UP, col.darkened(r.randf_range(0.0, 0.08)))


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
		an.sph(Vector3(cw.x + i * 0.65, K.gy(cw.x, cw.y) + 0.24, cw.y), 0.4, K.SAMAN.darkened(0.15 * (i % 2)), 6, Vector3(0.78, 0.6, 1.05))   # ORDUGÂH-5: yük çuvalı yuvarlak
		r.randf()
	var dw := rot * (lp + Vector2(1.6, 2.5))
	kisi.append([Vector3(dw.x, K.gy(dw.x, dw.y), dw.y), r.randf() * TAU, "saka"])


static func _deve_yatan(b: B, p: Vector3, yaw: float, col: Color) -> void:
	# CANLI (kalite notu 32): çökmüş deve canli_kit'ten (bacaklar dizden katlı, gövde yerde, boyun kalkık); kutu yok.
	const CK = preload("res://scripts/world/ist/canli_kit.gd")
	var hs := absi(int(p.x * 9.0 + p.z * 13.0))
	CK.bld_ekle(b, "deve", p, yaw, {"renk": col, "poz": "yat", "bas_yaw": float(hs % 5 - 2) * 14.0, "tohum": hs})


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
		# CANLI: koyun canli_kit'ten (yün hacimli gövde, koyu baş ve ince bacaklar); otlayan, duran, yatan karışık
		var hs := absi(int(w.x * 17.0 + w.y * 7.0))
		const CK = preload("res://scripts/world/ist/canli_kit.gd")
		CK.bld_ekle(an, "koyun", Vector3(w.x, y, w.y), yaw, {"renk": c, "poz": ["otla", "otla", "dur", "yat", "otla", "dur"][hs % 6], "bas_yaw": float(hs % 5 - 2) * 15.0, "tohum": hs})
		hay.append(Vector3(w.x, y, w.y))
	var cw := rot * (lp + Vector2(4.5, 0))
	kisi.append([Vector3(cw.x, K.gy(cw.x, cw.y), cw.y), r.randf() * TAU, "seyis"])
	var kw := rot * (lp + Vector2(-4.0, 1.5))
	_kopek(an, Vector3(kw.x, K.gy(kw.x, kw.y), kw.y), r.randf() * 360.0, r)
	hay.append(Vector3(kw.x, K.gy(kw.x, kw.y), kw.y))


static func _kopek(b: B, p: Vector3, yaw: float, r: RandomNumberGenerator) -> void:
	# CANLI (kalite notu 32): çoban köpeği canli_kit'ten; RNG tüketimi aynı (1 randi).
	const CK = preload("res://scripts/world/ist/canli_kit.gd")
	var c: Color = [Color("8a6a46"), Color("a89a80"), Color("5a4a3a"), Color("c8a468")][r.randi() % 4]
	var hs := absi(int(p.x * 7.0 + p.z * 3.0))
	CK.bld_ekle(b, "kopek", p, yaw, {"renk": c, "poz": "dur", "bas_yaw": float(hs % 5 - 2) * 18.0, "tohum": hs})

## ORDUGÂH-5: çadır önü (kapı yönünde): kilim/hasır, mızrak çatkısı, yaslı kalkan, eyer, torba, su kırbası (hepsi yuvarlak
## ya da düz örtü; kutu yok). p: çadır merkezi (yerel), d: kapı yönü, tr: yarıçap.
static func _cadir_onu(det: B, wd: B, met: B, p: Vector2, d: Vector2, tr: float, r: RandomNumberGenerator) -> void:
	var s := d.orthogonal()
	var on := p + d * (tr + 0.9)
	var y := K.gy(on.x, on.y)
	if r.randf() < 0.35:
		# kilim ya da hasır: kapı önünde düz örtü (zemini izler)
		var kc: Color = [Color("7a2a22"), Color("2c3a6a"), Color("b89a5a"), Color("8a6a3a")][r.randi() % 4]
		var w := r.randf_range(0.7, 1.0)
		var L := r.randf_range(1.1, 1.6)
		var q: Array = []
		for v: Vector2 in [on - s * w - d * L * 0.5, on + s * w - d * L * 0.5, on + s * w + d * L * 0.5, on - s * w + d * L * 0.5]:
			q.append(Vector3(v.x, K.gy(v.x, v.y) + 0.035, v.y))
		det.poly(q, Vector3.UP, kc)
		var q2: Array = []
		for v: Vector2 in [on - s * w * 0.7 - d * L * 0.35, on + s * w * 0.7 - d * L * 0.35, on + s * w * 0.7 + d * L * 0.35, on - s * w * 0.7 + d * L * 0.35]:
			q2.append(Vector3(v.x, K.gy(v.x, v.y) + 0.04, v.y))
		det.poly(q2, Vector3.UP, kc.lightened(0.25))
	var u := r.randf()
	var yan := p + d * (tr + 0.5) + s * (tr * 0.75 + 0.4) * (1.0 if r.randf() < 0.5 else -1.0)
	var yy := K.gy(yan.x, yan.y)
	if u < 0.16:
		# mızrak çatkısı: üç mızrak tepede birleşik
		for i in 3:
			var a := TAU * i / 3.0
			var dp := Vector3(cos(a) * 0.45, 0, sin(a) * 0.45)
			OC._kutuk(wd, Vector3(yan.x, yy, yan.y) + dp, Vector3(yan.x, yy + 2.3, yan.y) - dp * 0.15, 0.022, K.AHSAP2)
			met.cyl(Transform3D(Basis(), Vector3(yan.x, yy + 2.42, yan.y) - dp * 0.2), 0.03, 0.22, Color("8a8a90"), 4, 0.0)
	elif u < 0.28:
		# kalkan çadıra yaslı (yuvarlak, ahşap, ortası demir göbek)
		var kp := p + d * (tr + 0.15) + s * 0.9
		var ky := K.gy(kp.x, kp.y)
		var t := Transform3D(Basis.looking_at(Vector3(d.x, -0.35, d.y), Vector3.UP).rotated(Vector3(s.x, 0, s.y), 0.0), Vector3(kp.x, ky + 0.42, kp.y))
		met.cyl(t * Transform3D(Basis(Vector3.RIGHT, PI / 2.0), Vector3.ZERO), 0.4, 0.05, Color("8a5a34"), 10)
		met.cyl(t * Transform3D(Basis(Vector3.RIGHT, PI / 2.0), Vector3(0, 0, -0.03)), 0.09, 0.05, Color("5a5a5e"), 6)
	elif u < 0.38:
		# eyer: yere konmuş (yuvarlak gövde + eyer örtüsü)
		met.sph(Vector3(yan.x, yy + 0.18, yan.y), 0.32, Color("6a4428"), 6, Vector3(1.0, 0.55, 0.7))
		det.sph(Vector3(yan.x, yy + 0.1, yan.y), 0.4, Color("8a2a22"), 6, Vector3(1.0, 0.25, 0.9))
	elif u < 0.62:
		# torba(lar)
		for i in r.randi_range(1, 3):
			det.sph(Vector3(yan.x + i * 0.35, yy + 0.22, yan.y + i * 0.12), 0.24, Color("b8a072").darkened(0.08 * i), 6, Vector3(0.9, 1.1, 0.8))
	elif u < 0.72:
		# su kırbası (deri, şişkin)
		met.sph(Vector3(yan.x, yy + 0.2, yan.y), 0.26, Color("6a4a2e"), 6, Vector3(1.3, 0.75, 0.8))


static func _camasir(wd: B, det: B, onler: Array, r: RandomNumberGenerator) -> void:
	var a: Array = onler[r.randi() % onler.size()]
	var en: Array = []
	var ed := 999.0
	for o: Array in onler:
		var dd := (o[0] as Vector2).distance_to(a[0])
		if dd > 1.0 and dd < ed:
			ed = dd
			en = o
	if en.is_empty() or ed > 14.0:
		return
	var pa: Vector2 = a[0]
	var pb: Vector2 = en[0]
	var dv := (pb - pa).normalized()
	var s := dv.orthogonal() * 1.2
	var p0 := pa + dv * (float(a[1]) + 0.6) + s
	var p1 := pb - dv * (float(en[1]) + 0.6) + s
	if p0.distance_to(p1) < 2.0:
		return
	var y0 := K.gy(p0.x, p0.y)
	var y1 := K.gy(p1.x, p1.y)
	OC._kutuk(wd, Vector3(p0.x, y0, p0.y), Vector3(p0.x, y0 + 1.9, p0.y), 0.03, K.AHSAP2)
	OC._kutuk(wd, Vector3(p1.x, y1, p1.y), Vector3(p1.x, y1 + 1.9, p1.y), 0.03, K.AHSAP2)
	var n := 6
	var renk := [Color("d9ccaa"), Color("8c3a2e"), Color("e8e0c8"), Color("6a563c"), Color("3a4f78")]
	var onceki := Vector3(p0.x, y0 + 1.85, p0.y)
	for i in range(1, n + 1):
		var t := float(i) / n
		var q := p0.lerp(p1, t)
		var yq := lerpf(y0, y1, t) + 1.85 - 0.25 * sin(PI * t)
		var cur := Vector3(q.x, yq, q.y)
		OC._kutuk(wd, onceki, cur, 0.008, Color("8a7a58"))
		if i < n and r.randf() < 0.75:
			# asılı bez: ipten sarkan ince örtü (iki yüzlü)
			var w := 0.17
			var h := r.randf_range(0.35, 0.6)
			var c: Color = renk[r.randi() % renk.size()]
			var dd3 := Vector3(dv.x, 0, dv.y) * w
			var q4: Array = [cur - dd3, cur + dd3, cur + dd3 - Vector3(0, h, 0), cur - dd3 - Vector3(0, h * 0.92, 0)]
			det.poly(q4, Vector3(-dv.y, 0, dv.x), c)
			det.poly(q4, Vector3(dv.y, 0, -dv.x), c.darkened(0.15))
		onceki = cur
