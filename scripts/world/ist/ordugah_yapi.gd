class_name IstOrdugahYapi
extends RefCounted
## Ordugâh tekil yapıları: Sultan'ın otağı külliyesi, toprak tabya (batarya), Şahi topu, mancınık, kuşatma kulesi.
## Yerel çerçeve: zemin y = 0; +x doğu, −z kuzey (yon_derece = 0). Tabya ve toplarda namlu/ön = yerel +z.
## Kuşatma gereçleri (top, kule, mancınık, çadır) gerçek boyda kalır; k yalnız kütleyi (tabya genişliği, külliye çapı) ölçekler.

const K = preload("res://scripts/world/ist/ordugah_kit.gd")
const B = K.Bld


static func kk(k: float) -> float:
	return clampf(0.7 + 0.6 * k, 0.8, 1.2)


## Dışbükey yamuk blok (zemin y0, üst yüksekliği h): taban (bw × bd), tepe (tw × td); merkez (cx, cz). Katı gövde ekler.
static func yamuk(b: B, cx: float, cz: float, y0: float, h: float, bw: float, bd: float, tw: float, td: float,
		col: Color, katı := true, z_kayma := 0.0) -> void:
	var p := [
		Vector3(cx - bw / 2, y0, cz - bd / 2), Vector3(cx + bw / 2, y0, cz - bd / 2),
		Vector3(cx + bw / 2, y0, cz + bd / 2), Vector3(cx - bw / 2, y0, cz + bd / 2),
		Vector3(cx - tw / 2, y0 + h, cz + z_kayma - td / 2), Vector3(cx + tw / 2, y0 + h, cz + z_kayma - td / 2),
		Vector3(cx + tw / 2, y0 + h, cz + z_kayma + td / 2), Vector3(cx - tw / 2, y0 + h, cz + z_kayma + td / 2)]
	var cc := Vector3(cx, y0 + h * 0.5, cz)
	var f := [[0, 1, 2, 3], [4, 7, 6, 5], [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0]]
	for i in f.size():
		var q: Array = []
		var m := Vector3.ZERO
		for j in f[i]:
			q.append(p[j])
			m += p[j]
		m /= 4.0
		var c2 := col
		if i == 1:
			c2 = col.lightened(0.07)
		elif i == 0:
			c2 = col.darkened(0.3)
		elif i in [2, 4]:
			c2 = col.darkened(0.06)
		b.poly(q, m - cc, c2)
	if katı:
		b.solid_hull(PackedVector3Array(p))


static func sancak(b: B, f: B, pos: Vector3, h: float, col: Color, tug := false) -> void:
	b.cylp(pos + Vector3(0, h / 2, 0), 0.05, h, K.AHSAP2, 5)
	b.sph(pos + Vector3(0, h + 0.1, 0), 0.12, K.ALTIN, 4)
	if tug:
		# tuğ: at kuyruğu püskülü
		f.cylp(pos + Vector3(0, h - 0.7, 0), 0.25, 1.1, Color("e9e2d0"), 6, 0.04)
		f.cylp(pos + Vector3(0, h - 1.3, 0), 0.07, 0.3, K.ALTIN, 5)
	else:
		f.box(pos + Vector3(0.45, h - 0.65, 0), Vector3(0.9, 1.2, 0.03), col)
		f.box(pos + Vector3(0.45, h - 0.65, 0.0), Vector3(0.5, 0.4, 0.035), K.KREM)


# ------------------------------------------------------------------ Sultan'ın otağı külliyesi

static func build_otag(host: Node3D, k: float, lod: int) -> void:
	var r := K.rr(1453)
	var cloth := B.new("plaster")
	var wood := B.new("wood")
	var earth := B.new("rubble")
	wood.no_climb = false
	cloth.no_climb = true
	var R := 8.5
	var kz := kk(k)
	var fence_r := 26.0 * kz
	# Halı zemini (otağın önü ve çevresi)
	earth.cylp(Vector3(0, 0.1, 0), fence_r - 1.0, 0.2, Color("8d7a58"), 20)
	earth.solid_cyl(Vector3(0, 0.1, 0), fence_r - 1.0, 0.2)
	# Otağ
	cloth.cylp(Vector3(0, 2.5, 0), R, 5.0, K.KIRMIZI, 18)
	cloth.cylp(Vector3(0, 7.0, 0), R + 0.7, 4.2, K.KIRMIZI.lightened(0.05), 18, 0.5)
	cloth.cylp(Vector3(0, 0.3, 0), R + 0.03, 0.55, K.ALTIN, 18)
	cloth.cylp(Vector3(0, 5.05, 0), R + 0.05, 0.4, K.ALTIN, 18)
	cloth.cylp(Vector3(0, 9.6, 0), 0.09, 2.6, K.ALTIN, 6)
	cloth.sph(Vector3(0, 11.0, 0), 0.4, K.ALTIN, 6)
	cloth.cylp(Vector3(0, 11.6, 0), 0.35, 0.07, K.ALTIN, 10, -1.0, Vector3(90, 0, 0))
	cloth.sph(Vector3(0, 11.62, 0), 0.14, K.ALTIN, 4)
	# kapı: koyu açıklık + altın söve
	cloth.box(Vector3(0, 1.7, R + 0.04), Vector3(2.4, 3.4, 0.14), K.KOYU)
	cloth.box(Vector3(-1.4, 1.9, R + 0.08), Vector3(0.28, 3.8, 0.12), K.ALTIN)
	cloth.box(Vector3(1.4, 1.9, R + 0.08), Vector3(0.28, 3.8, 0.12), K.ALTIN)
	cloth.box(Vector3(0, 3.7, R + 0.08), Vector3(3.1, 0.28, 0.12), K.ALTIN)
	if lod <= 1:
		# rumi/aplike panolar
		for i in 16:
			var a := TAU * (i + 0.5) / 16.0
			if absf(a - PI / 2.0) < 0.28:
				continue          # kapı
			var rd := rad_to_deg(a)
			var wp := Vector3(cos(a) * (R + 0.03), 2.6, sin(a) * (R + 0.03))
			var yaw := -rd + 90.0
			cloth.box(wp, Vector3(1.5, 2.8, 0.06), K.KREM, yaw)
			cloth.box(wp + Vector3(0, 0.0, 0) , Vector3(1.0, 2.0, 0.08), K.LACI, yaw)
			cloth.box(wp + Vector3(cos(a), 0, sin(a)) * 0.02 + Vector3(0, 1.0, 0), Vector3(0.7, 0.7, 0.09), K.ALTIN, yaw, Vector3(0, 0, 45))
		# çatı dilim çizgileri
		for i in 18:
			var a2 := TAU * i / 18.0
			cloth.rod(Vector3(cos(a2) * (R + 0.72), 5.05, sin(a2) * (R + 0.72)), Vector3(cos(a2) * 0.55, 9.1, sin(a2) * 0.55), 0.09, K.ALTIN.darkened(0.15))
	# otağ katı (tırmanılmaz çadır bezi)
	cloth.solid_cyl(Vector3(0, 3.0, 0), R + 0.1, 6.0)
	cloth.solid_cyl(Vector3(0, 8.0, 0), 4.0, 4.0)
	cloth.solid_cyl(Vector3(0, 11.0, 0), 0.5, 1.2)       # alem (Nihat konma noktası)
	# kapı saçağı (sayeban): iki direk + kırmızı gölgelik
	for sx in [-2.2, 2.2]:
		wood.cylp(Vector3(sx, 1.8, R + 5.2), 0.1, 3.6, K.ALTIN, 6)
		wood.solid_cyl(Vector3(sx, 1.8, R + 5.2), 0.12, 3.6)
	cloth.box(Vector3(0, 3.7, R + 2.7), Vector3(5.4, 0.12, 5.6), K.KIRMIZI, 0.0, Vector3(-7, 0, 0))
	cloth.box(Vector3(0, 3.55, R + 5.45), Vector3(5.4, 0.45, 0.05), K.ALTIN)
	# halılar (önünde ve çevresinde)
	for i in 5:
		var cc: Color = [K.KIRMIZI2, K.LACI, K.YESIL, K.KIRMIZI2, K.LACI][i]
		cloth.box(Vector3(0, 0.23 + i * 0.002, R + 2.0 + i * 1.3), Vector3(4.2 - i * 0.25, 0.03, 1.2), cc)
		cloth.box(Vector3(0, 0.235 + i * 0.002, R + 2.0 + i * 1.3), Vector3(3.2 - i * 0.25, 0.03, 0.5), K.KREM)
	# Kazık çit (palisade) çevre: kapı +z yönünde 4 m, arka kapı 2,4 m
	var N := 40
	for i in N:
		var a0 := TAU * i / N
		var a1 := TAU * (i + 1) / N
		var am := (a0 + a1) * 0.5
		var gate_front := absf(wrapf(am - PI / 2.0, -PI, PI)) < 0.085 * 26.0 / fence_r * 1.5
		var gate_back := absf(wrapf(am + PI / 2.0, -PI, PI)) < 0.045 * 26.0 / fence_r * 1.5
		if gate_front or gate_back:
			continue
		var p0 := Vector3(cos(a0) * fence_r, 0, sin(a0) * fence_r)
		var p1 := Vector3(cos(a1) * fence_r, 0, sin(a1) * fence_r)
		var ln := p0.distance_to(p1)
		var mid := (p0 + p1) * 0.5
		var yaw := -rad_to_deg(atan2(p1.z - p0.z, p1.x - p0.x))
		wood.box(mid + Vector3(0, 1.1, 0), Vector3(ln, 2.2, 0.3), K.AHSAP, yaw)
		wood.solid_box(mid + Vector3(0, 1.1, 0), Vector3(ln, 2.2, 0.3), yaw)
		if lod == 0:
			var ns := int(ln / 0.42)
			for s in ns:
				var tt := (s + 0.5) / ns - 0.5
				var q := mid + (p1 - p0).normalized() * (tt * ln)
				wood.box(q + Vector3(0, 2.35, 0), Vector3(0.2, 0.7, 0.2), K.AHSAP_A, yaw, Vector3(0, 45, 0))
			wood.box(mid + Vector3(0, 1.6, 0), Vector3(ln, 0.12, 0.38), K.AHSAP2, yaw)
	# Divan çadırları (iki yan) ve hazine çadırı (arka)
	for sd in [[-15.0 * kz, 6.0], [15.0 * kz, 6.0]]:
		var pos := Vector3(sd[0], 0, sd[1])
		cloth.box(pos + Vector3(0, 1.3, 0), Vector3(9.0, 2.6, 5.6), K.KIRMIZI2)
		cloth.prism(B.xf(pos + Vector3(0, 2.6, 0)), Vector3(9.6, 2.0, 6.2), K.KIRMIZI)
		cloth.box(pos + Vector3(0, 2.62, 0), Vector3(9.7, 0.1, 0.25), K.ALTIN)
		cloth.box(pos + Vector3(0, 1.1, 2.82), Vector3(2.0, 2.2, 0.08), K.KOYU)
		cloth.solid_box(pos + Vector3(0, 2.3, 0), Vector3(9.2, 4.6, 5.8))
	var tp := Vector3(0, 0, -R - 7.0)
	cloth.cylp(tp + Vector3(0, 1.4, 0), 3.4, 2.8, K.KREM, 14)
	cloth.cylp(tp + Vector3(0, 3.6, 0), 3.6, 1.8, K.KREM.darkened(0.08), 14, 0.2)
	cloth.cylp(tp + Vector3(0, 1.6, 0), 3.42, 0.25, K.LACI, 14)
	cloth.solid_cyl(tp + Vector3(0, 2.2, 0), 3.5, 4.4)
	# Tuğlar ve sancaklar (kapıya doğru)
	var sb := B.new()
	var sf := B.new()
	sb.no_climb = false
	for sx in [-7.5, -5.2, 5.2, 7.5]:
		sancak(sb, sf, Vector3(sx, 0, R + 9.0), 9.0 if absf(sx) > 6 else 8.0, K.KIRMIZI if sx < 0 else K.YESIL, absf(sx) < 6)
	sb.solid_cyl(Vector3(-7.5, 4.5, R + 9.0), 0.1, 9.0)
	# Gözcü kulesi ve merdiven
	_kule_ahsap(wood, Vector3(-17.0 * kz, 0, -14.0), 6.4, lod)
	# Yeniçeri çadır halkası (çit dışı)
	var ring: Array = []
	var cols: Array = []
	var rr_ := fence_r + 12.0
	var cnt := 22
	for i in cnt:
		var a := TAU * (i + 0.5) / cnt
		if absf(wrapf(a - PI / 2.0, -PI, PI)) < 0.2:
			continue
		var s := 2.5
		var p := Vector3(cos(a) * rr_, 0, sin(a) * rr_)
		ring.append(Transform3D(Basis.from_euler(Vector3(0, -a, 0)).scaled(Vector3(s, 1.35, s)), p))
		cols.append(K.ton(Color("f1ead6"), r, 0.04))
		cloth.solid_cyl(p + Vector3(0, 1.6, 0), s * 0.97, 3.2)
	K.mm(host, K.tent_mesh("yuvarlak"), ring, cols, "ring", "plaster", true)
	cloth.done(host, "bez")
	wood.done(host, "ahsap")
	earth.done(host, "zemin")
	sb.done(host, "dir")
	sf.done(host, "flama")
	if K.gece:
		for i in 6:
			var a3 := TAU * i / 6.0
			var tpos := Vector3(cos(a3) * (fence_r - 2.0), 1.9, sin(a3) * (fence_r - 2.0))
			if absf(wrapf(a3 - PI / 2.0, -PI, PI)) < 0.2:
				continue
			Flame.add(host, tpos, 0.35, 0.6)


## Basit ahşap gözcü kulesi + yan merdiven (basamak ≤ 0,28 m). Tepe zemini h; platform üstü katı.
static func _kule_ahsap(w: B, p: Vector3, h: float, lod: int) -> void:
	var s := 3.2
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			w.box(p + Vector3(sx * s / 2, h / 2, sz * s / 2), Vector3(0.28, h, 0.28), K.AHSAP2)
	for lv in [1.6, 3.4]:
		for sd in [-1, 1]:
			w.box(p + Vector3(0, lv, sd * s / 2), Vector3(s, 0.14, 0.14), K.AHSAP)
			w.box(p + Vector3(sd * s / 2, lv + 0.7, 0), Vector3(0.14, 0.14, s), K.AHSAP)
		w.rod(p + Vector3(-s / 2, lv - 1.6 if lv > 1.7 else 0.0, s / 2), p + Vector3(s / 2, lv + 1.7 if lv < 2 else lv + 1.7, s / 2), 0.12, K.AHSAP)
	# platform
	w.box(p + Vector3(0, h, 0), Vector3(s + 0.8, 0.2, s + 0.8), K.AHSAP_A)
	w.solid_box(p + Vector3(0, h, 0), Vector3(s + 0.8, 0.2, s + 0.8))
	# korkuluk 1,05
	w.box(p + Vector3(0, h + 0.62, -(s + 0.8) / 2), Vector3(s + 0.8, 1.05, 0.1), K.AHSAP)
	w.box(p + Vector3(-1.7, h + 0.62, (s + 0.8) / 2), Vector3(0.6, 1.05, 0.1), K.AHSAP)
	w.box(p + Vector3(1.8, h + 0.62, (s + 0.8) / 2), Vector3(0.4, 1.05, 0.1), K.AHSAP)
	for sd in [-1, 1]:
		w.box(p + Vector3(sd * (s + 0.8) / 2, h + 0.62, 0), Vector3(0.1, 1.05, s + 0.8), K.AHSAP)
	w.solid_box(p + Vector3(0, h + 0.62, -(s + 0.8) / 2), Vector3(s + 0.8, 1.05, 0.12))
	w.solid_box(p + Vector3(-(s + 0.8) / 2, h + 0.62, 0), Vector3(0.12, 1.05, s + 0.8))
	w.solid_box(p + Vector3((s + 0.8) / 2, h + 0.62, 0), Vector3(0.12, 1.05, s + 0.8))
	# ön korkuluk: ortası (x −1,4 … +1,6) merdiven girişi için açık
	w.solid_box(p + Vector3(-1.7, h + 0.62, (s + 0.8) / 2), Vector3(0.6, 1.05, 0.12))
	w.solid_box(p + Vector3(1.8, h + 0.62, (s + 0.8) / 2), Vector3(0.4, 1.05, 0.12))
	# çatı
	w.cylp(p + Vector3(0, h + 3.2, 0), 3.2, 1.3, K.SAMAN, 8, 0.1)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			w.box(p + Vector3(sx * (s + 0.5) / 2, h + 1.7, sz * (s + 0.5) / 2), Vector3(0.12, 2.0, 0.12), K.AHSAP2)
	# merdiven: ön yüz boyunca (z = +s/2 + 1,0), üst basamak x = −0,9; alçak basamaklar doğuya uzanır
	var steps := int(ceil(h / 0.27))
	var rise := h / steps
	var run := 0.34
	for i in steps:
		var sx2 := p.x - 0.9 + (steps - 1 - i) * run
		var sp := Vector3(sx2, rise * (i + 1) * 0.5, p.z + s / 2 + 1.0)
		w.box(sp, Vector3(run + 0.02, rise * (i + 1), 1.2), K.AHSAP_A if i % 2 == 0 else K.AHSAP)
		w.solid_box(sp, Vector3(run + 0.02, rise * (i + 1), 1.2))


static func kule_merdiven_ucu(p: Vector3, h: float) -> Array:
	var steps := int(ceil(h / 0.27))
	return [Vector3(p.x - 0.9 + (steps - 1) * 0.34 + 0.6, 0.0, p.z + 3.2 / 2 + 1.0), Vector3(p.x - 0.9, h + 0.05, p.z + 2.6)]


# ------------------------------------------------------------------ Toprak tabya (batarya)

## opt: {"n": top sayısı (1–4), "buyuk": Şahi topu mu}
static func build_batarya(host: Node3D, k: float, lod: int, tohum := 7, opt := {}) -> void:
	var r := K.rr(tohum)
	var n: int = int(opt.get("n", 3))
	var buyuk: bool = bool(opt.get("buyuk", false))
	var earth := B.new("rubble")
	var wood := B.new("wood")
	var metal := B.new("")
	var cl := B.new("plaster")
	var kz := kk(k)
	var sp := (12.0 if buyuk else 8.5)
	var W := n * sp + 8.0
	var D := 15.0 if buyuk else 11.0
	var TH := 1.0            # teras
	var PH := 2.6 if buyuk else 1.5   # sedde (parapet) üstü
	# Teras
	yamuk(earth, 0, 0, 0, TH, W + 3.0, D + 3.0, W, D, K.TOPRAK)
	# Sedde (ön) — top boşlukları 2,6 m
	var fz := D / 2.0 - 2.2
	var seg_w := (W - n * 2.6) / (n + 1.0)
	var x0 := -W / 2.0
	for i in n + 1:
		var cx := x0 + seg_w * 0.5
		yamuk(earth, cx, fz, TH, PH, seg_w + 1.4, 4.4, seg_w, 2.4, K.TOPRAK2, true, 0.0)
		x0 += seg_w + 2.6
	# Top boşluğu önünde ahşap kaplamalı yanaklar (kereste)
	x0 = -W / 2.0 + seg_w
	var gun_x: Array = []
	for i in n:
		var gx := x0 + 1.3
		gun_x.append(gx)
		for sd in [-1, 1]:
			wood.box(Vector3(gx + sd * 1.42, TH + PH * 0.5, fz), Vector3(0.2, PH, 2.6), K.AHSAP)
		wood.box(Vector3(gx, TH + 0.05, fz + 0.9), Vector3(2.4, 0.1, 1.5), K.AHSAP2)
		x0 += seg_w + 2.6
	# Gabyon (sepet siper) sırası, sedde önünde (zemin üstü)
	var gz := D / 2.0 + 1.7
	var gcount := int((W + 2.0) / 0.95)
	for i in gcount:
		var gx2 := -W / 2.0 - 1.0 + (i + 0.5) * ((W + 2.0) / gcount)
		earth.cylp(Vector3(gx2, 0.62, gz), 0.46, 1.24, K.SEPET.darkened(0.04 * (i % 3)), 8)
		if lod == 0:
			earth.cylp(Vector3(gx2, 1.27, gz), 0.5, 0.07, K.SEPET.darkened(0.25), 8)
			earth.cylp(Vector3(gx2, 0.62, gz), 0.485, 0.05, K.AHSAP2, 8)
			earth.sph(Vector3(gx2, 1.32, gz), 0.36, K.TOPRAK2, 5, Vector3(1, 0.4, 1))
	earth.solid_box(Vector3(0, 0.62, gz), Vector3(W + 2.0, 1.24, 1.0))
	# Gabyon sırası ile teras arasındaki toprak dolgu
	yamuk(earth, 0, D / 2.0 + 0.55, 0, 0.9, W + 1.0, 1.6, W + 0.4, 0.9, K.TOPRAK2, false)
	# Arka rampa (zemin → teras, 2,8 m geniş, 5 m, eğim ≈ 11°) ve yan rampa
	earth_rampa(earth, Vector3(W * 0.5 - 3.0, 0, -D / 2.0 - 1.5), Vector3(W * 0.5 - 3.0, TH, -D / 2.0 + 3.0), 3.0, K.TOPRAK)
	# Sedde üstüne çıkış: terasın yan ucundan bir kademeli rampa (yan taraf)
	earth_rampa(earth, Vector3(-W * 0.5 + 0.0, TH, -D / 2.0 + 3.2), Vector3(-W * 0.5 + 0.0, TH + PH, fz - 0.4), 2.2, K.TOPRAK2, true)
	# Toplar
	for gx3 in gun_x:
		_top(metal, wood, Vector3(gx3, TH, fz - 3.2), buyuk, lod, r)
	# Sepet kalkan / mantlet ve alet
	if lod == 0:
		for gx4 in gun_x:
			for sd in [-1, 1]:
				wood.box(Vector3(gx4 + sd * 1.8, TH + PH + 0.55, fz), Vector3(1.4, 1.1, 0.12), K.AHSAP_A, 0.0, Vector3(-18, 0, 0))
	# Gülle yığınları (piramit) ve barut fıçıları
	var spc: Array = []
	for i in n:
		var gx5: float = (gun_x[i] as float) + 3.2
		if i == n - 1:
			gx5 = (gun_x[i] as float) - 3.2
		spc.append(gx5)
	for gx6 in spc:
		_gulle_piramit(metal, Vector3(gx6, TH, fz - 4.6), 0.32 if not buyuk else 0.4, 4 if lod == 0 else 3, K.TAS if buyuk else K.DEMIR)
		for q in 5 if lod == 0 else 2:
			var bx: float = gx6 + 1.2 + (q % 3) * 0.85
			var bz := fz - 6.4 - (q / 3) * 0.9
			wood.cylp(Vector3(bx, TH + 0.45, bz), 0.4, 0.9, K.AHSAP, 8)
			wood.cylp(Vector3(bx, TH + 0.25, bz), 0.415, 0.06, K.DEMIR, 8)
			wood.cylp(Vector3(bx, TH + 0.68, bz), 0.415, 0.06, K.DEMIR, 8)
			wood.solid_cyl(Vector3(bx, TH + 0.45, bz), 0.4, 0.9)
	# Top arabası ve öküzler (arkada)
	if lod <= 1:
		_araba(wood, Vector3(-W * 0.25, 0, -D / 2.0 - 5.5), 15.0, r)
		_okuz(wood, Vector3(-W * 0.25 + 2.7, 0, -D / 2.0 - 8.5), 90.0, r)
		_okuz(wood, Vector3(-W * 0.25 + 2.7, 0, -D / 2.0 - 10.5), 90.0, r)
	# Çadır (top ustaları) arkada
	var tr: Array = []
	var tc: Array = []
	tr.append(Transform3D(Basis.from_euler(Vector3(0, 0.3, 0)).scaled(Vector3(2.2, 1.2, 2.2)), Vector3(W * 0.5 - 6.0, 0, -D / 2.0 - 8.0)))
	tc.append(K.BEZ)
	cl.solid_cyl(Vector3(W * 0.5 - 6.0, 1.4, -D / 2.0 - 8.0), 2.15, 2.8)
	K.mm(host, K.tent_mesh("yuvarlak"), tr, tc, "usta_cadiri", "plaster", true)
	# Sancak
	var sf := B.new()
	sancak(wood, sf, Vector3(W * 0.5 - 1.2, TH, 0.5), 5.0, K.KIRMIZI)
	wood.solid_cyl(Vector3(W * 0.5 - 1.2, TH + 2.5, 0.5), 0.08, 5.0)
	earth.done(host, "toprak")
	wood.done(host, "ahsap")
	metal.done(host, "demir")
	cl.done(host, "bez")
	sf.done(host, "bayrak")
	if K.gece:
		for sx in [-1, 1]:
			Flame.add(host, Vector3(sx * (W * 0.5 - 0.6), TH + 2.2, fz - 3.0), 0.3, 0.5)


static func earth_rampa(b: B, a: Vector3, c: Vector3, w: float, col: Color, tirmanis := false) -> void:
	# a (alçak uç) → c (yüksek uç) dolgu rampa: yan duvarlı yamuk, üstü yüzey
	var d := c - a
	var dh := Vector3(d.x, 0, d.z)
	var ln := dh.length()
	if ln < 0.01:
		return
	var f := dh / ln
	var s := Vector3(-f.z, 0, f.x)
	var h0 := a.y
	var h1 := c.y
	var p := [a - s * w / 2, a + s * w / 2, c + s * w / 2, c - s * w / 2]
	# gövde: taban zeminde y = h0 - 0.3, üst yüzey eğimli
	var top := [Vector3(p[0].x, h0, p[0].z), Vector3(p[1].x, h0, p[1].z), Vector3(p[2].x, h1, p[2].z), Vector3(p[3].x, h1, p[3].z)]
	var low: Array = []
	for t in top:
		low.append(Vector3(t.x, h0 - 0.3, t.z))
	var cc: Vector3 = (top[0] + top[2]) * 0.5 - Vector3(0, 1, 0)
	b.poly(top, Vector3.UP, col.lightened(0.1))
	b.poly([top[0], top[3], low[3], low[0]], -s, col.darkened(0.1))
	b.poly([top[1], low[1], low[2], top[2]], s, col.darkened(0.1))
	b.poly([top[0], low[0], low[1], top[1]], -f, col.darkened(0.2))
	b.poly([top[3], top[2], low[2], low[3]], f, col.darkened(0.1))
	var pts := PackedVector3Array(top + low)
	b.solid_hull(pts)


static func _gulle_piramit(b: B, p: Vector3, r: float, katman: int, col: Color) -> void:
	for ly in katman:
		var m := katman - ly
		for ix in m:
			for iz in m:
				var off := (m - 1) * r
				b.sph(p + Vector3(ix * 2 * r - off, r + ly * r * 1.7, iz * 2 * r - off), r, col.darkened(0.05 * ((ix + iz) % 2)), 5)
	var base_w := katman * 2 * r
	b.solid_box(p + Vector3(0, katman * r * 0.9, 0), Vector3(base_w, katman * r * 1.8, base_w))


static func _top(m: B, w: B, p: Vector3, buyuk: bool, lod: int, r: RandomNumberGenerator) -> void:
	# p: top yatağının arka ucu kaide üstü; namlu +z yönüne. Uzunluk 4 m (Şahi: 8 m), çap 0,6 (1,3)
	var L := 8.2 if buyuk else 3.8
	var R0 := 0.62 if buyuk else 0.3
	var R1 := 0.5 if buyuk else 0.25
	var cy := R0 + 0.55 if not buyuk else R0 + 0.9
	# yatak: iki boyuna kiriş + kayma kirişleri
	var bw := 2.0 if buyuk else 1.3
	for sd in [-1, 1]:
		w.box(p + Vector3(sd * bw / 2, 0.3, L * 0.5 - 1.0), Vector3(0.3, 0.6, L + 1.6), K.AHSAP2)
	for zz in [0.0, L * 0.45, L * 0.9]:
		w.box(p + Vector3(0, 0.45, zz), Vector3(bw + 0.3, 0.3, 0.35), K.AHSAP)
	if buyuk:
		w.box(p + Vector3(0, 0.95, -0.2), Vector3(bw + 0.5, 0.9, 1.3), K.AHSAP2)        # arka dayanak bloğu
		w.box(p + Vector3(0, 1.6, L * 0.3), Vector3(bw + 0.3, 0.5, 0.5), K.AHSAP)
	# namlu: iki kısım (kama bölümü + gülle odası), halkalar, ağız
	var t := B.xf(p + Vector3(0, cy, L * 0.5), 0.0, Vector3(90, 0, 0))
	m.cyl(t, R0 * 0.82, L, K.BRONZ, 12, R1 * 0.95)
	var seg := 4 if buyuk else 3
	for i in seg:
		var zz2 := (i + 0.5) / seg * L * 0.92
		var rad := lerpf(R0 * 0.82, R1 * 0.95, zz2 / L) + 0.04
		m.cyl(B.xf(p + Vector3(0, cy, zz2), 0.0, Vector3(90, 0, 0)), rad, 0.2, K.BRONZ.darkened(0.25), 12)
	m.cyl(B.xf(p + Vector3(0, cy, L - 0.05), 0.0, Vector3(90, 0, 0)), R1 + 0.07, 0.22, K.BRONZ.lightened(0.1), 12)
	m.cyl(B.xf(p + Vector3(0, cy, L + 0.065), 0.0, Vector3(90, 0, 0)), R1 * 0.55, 0.03, K.KOYU, 10)
	m.cyl(B.xf(p + Vector3(0, cy, -0.18), 0.0, Vector3(90, 0, 0)), R0 * 0.7, 0.34, K.BRONZ.darkened(0.15), 12)
	m.sph(p + Vector3(0, cy, -0.35), R0 * 0.55, K.BRONZ, 6)
	m.solid_box(p + Vector3(0, cy * 0.75, L * 0.5), Vector3(bw + 0.3, cy * 1.5, L + 0.8))
	if lod <= 1 and not buyuk:
		w.cylp(p + Vector3(-bw / 2 - 0.1, 0.35, 0.8), 0.45, 0.14, K.AHSAP, 8, -1.0, Vector3(0, 0, 90))
		w.cylp(p + Vector3(bw / 2 + 0.1, 0.35, 0.8), 0.45, 0.14, K.AHSAP, 8, -1.0, Vector3(0, 0, 90))


static func _araba(w: B, p: Vector3, yaw: float, r: RandomNumberGenerator) -> void:
	w.box(p + Vector3(0, 0.9, 0), Vector3(1.9, 0.25, 4.2), K.AHSAP, yaw)
	for sd in [-1, 1]:
		var wp := p + Vector3(sd * 1.1, 0.7, 0.6).rotated(Vector3.UP, deg_to_rad(yaw))
		w.cyl(B.xf(wp, yaw, Vector3(0, 0, 90)), 0.7, 0.14, K.AHSAP2, 10)
		var wp2 := p + Vector3(sd * 1.1, 0.7, -1.2).rotated(Vector3.UP, deg_to_rad(yaw))
		w.cyl(B.xf(wp2, yaw, Vector3(0, 0, 90)), 0.7, 0.14, K.AHSAP2, 10)
	w.rod(p + Vector3(0, 0.9, -2.0).rotated(Vector3.UP, deg_to_rad(yaw)), p + Vector3(0, 0.9, -5.0).rotated(Vector3.UP, deg_to_rad(yaw)), 0.14, K.AHSAP2)
	w.solid_box(p + Vector3(0, 0.7, -0.3).rotated(Vector3.UP, deg_to_rad(yaw)), Vector3(2.6, 1.4, 4.4), yaw)
	# yük: taş gülleler kasada
	for i in 3:
		w.sph(p + Vector3(0, 1.3, -1.3 + i * 1.1).rotated(Vector3.UP, deg_to_rad(yaw)), 0.4, K.TAS, 6)


static func _okuz(w: B, p: Vector3, yaw: float, r: RandomNumberGenerator) -> void:
	var d := Vector3.UP
	var f := func(v: Vector3) -> Vector3:
		return p + v.rotated(d, deg_to_rad(yaw))
	var col := Color("6e5238").lerp(Color("a08462"), r.randf())
	w.box(f.call(Vector3(0, 1.0, 0)), Vector3(0.9, 0.95, 2.1), col, yaw)
	w.box(f.call(Vector3(0, 1.15, 1.35)), Vector3(0.55, 0.55, 0.6), col.darkened(0.1), yaw)
	w.box(f.call(Vector3(0, 1.35, -0.3)), Vector3(0.5, 0.3, 0.6), col.lightened(0.05), yaw)         # hörgüç
	for sx in [-1, 1]:
		w.box(f.call(Vector3(sx * 0.35, 1.5, 1.45)), Vector3(0.5, 0.07, 0.07), Color("eee6d0"), yaw, Vector3(0, 0, sx * 25))
		for sz in [-0.7, 0.7]:
			w.box(f.call(Vector3(sx * 0.28, 0.35, sz)), Vector3(0.18, 0.7, 0.18), col.darkened(0.2), yaw)
	w.box(f.call(Vector3(0, 1.45, 0.9)), Vector3(1.0, 0.1, 0.12), K.AHSAP2, yaw)         # boyunduruk
	w.solid_box(f.call(Vector3(0, 0.95, 0.2)), Vector3(1.0, 1.9, 2.6), yaw)


# ------------------------------------------------------------------ Şahi topu bataryası

static func build_sahi_top(host: Node3D, k: float, lod: int, tohum := 11) -> void:
	build_batarya(host, k, lod, tohum, {"n": 1, "buyuk": true})
	var w := B.new("wood")
	var m := B.new("")
	var r := K.rr(tohum)
	# arkada: kereste vinç (kren) + gülle yığını + öküz sırası + ağır sürükleme kızağı
	var D := 15.0
	w.box(Vector3(11.0, 2.0, -D / 2.0 - 4.0), Vector3(0.35, 4.0, 0.35), K.AHSAP2)
	w.box(Vector3(12.8, 2.0, -D / 2.0 - 4.0), Vector3(0.35, 4.0, 0.35), K.AHSAP2)
	w.rod(Vector3(11.0, 4.0, -D / 2.0 - 4.0), Vector3(15.5, 3.2, -D / 2.0 - 4.0), 0.3, K.AHSAP)
	w.rod(Vector3(15.5, 3.2, -D / 2.0 - 4.0), Vector3(15.5, 0.9, -D / 2.0 - 4.0), 0.04, K.DEMIR)
	w.box(Vector3(15.5, 0.8, -D / 2.0 - 4.0), Vector3(0.7, 0.4, 0.7), K.TAS)
	w.solid_box(Vector3(11.9, 2.0, -D / 2.0 - 4.0), Vector3(2.2, 4.0, 0.5))
	_gulle_piramit(m, Vector3(-11.5, 0, -D / 2.0 - 3.5), 0.38, 4, K.TAS)
	if lod <= 1:
		for i in 6:
			_okuz(w, Vector3(-4.0 + i * 2.2, 0, -D / 2.0 - 10.0), 0.0, r)
		w.box(Vector3(-4.0 + 5 * 1.1, 0.1, -D / 2.0 - 10.0), Vector3(12.0, 0.1, 0.1), K.AHSAP2)
	w.done(host, "ahsap2")
	m.done(host, "tas")


# ------------------------------------------------------------------ Mancınık

static func build_mancinik(host: Node3D, k: float, lod: int, tohum := 5) -> void:
	var w := B.new("wood")
	var t := B.new("rubble")
	var r := K.rr(tohum)
	var H := 6.0           # eksen yüksekliği
	# tabanda iki boyuna kiriş, dört çerçeve ayağı (A)
	for sd in [-1, 1]:
		w.box(Vector3(sd * 1.9, 0.3, 0), Vector3(0.45, 0.6, 12.0), K.AHSAP2)
		w.solid_box(Vector3(sd * 1.9, 0.3, 0), Vector3(0.45, 0.6, 12.0))
	w.box(Vector3(0, 0.3, -5.8), Vector3(4.2, 0.5, 0.5), K.AHSAP2)
	w.box(Vector3(0, 0.3, 5.8), Vector3(4.2, 0.5, 0.5), K.AHSAP2)
	for sd in [-1, 1]:
		for fz in [-1.0, 1.0]:
			w.rod(Vector3(sd * 1.9, 0.5, fz * 2.2), Vector3(sd * 0.3, H, 0.0), 0.34, K.AHSAP)
	for sd in [-1, 1]:
		w.solid_box(Vector3(sd * 1.1, 3.2, 0), Vector3(0.9, 6.0, 4.8))
		w.box(Vector3(sd * 0.3, H, 0), Vector3(0.5, 0.5, 0.7), K.AHSAP2)
	w.cylp(Vector3(0, H, 0), 0.22, 3.2, K.DEMIR, 8, -1.0, Vector3(0, 0, 90))   # eksen
	# kol: eksenin önünde uzun (7,5 m), arkada kısa (2,5)
	var a0 := Vector3(0, H, -2.6)
	var a1 := Vector3(0, H + 0.0, 7.4)
	w.rod(Vector3(0, H + 0.25, -2.5), Vector3(0, H + 2.0, 7.0), 0.36, K.AHSAP_A)       # uzun kol yukarı kalkmış (fırlatma anı)
	# karşı ağırlık sandığı (kısa kolda asılı), taş dolu
	w.box(Vector3(0, H - 2.0, -3.1), Vector3(2.1, 2.1, 2.1), K.AHSAP)
	t.box(Vector3(0, H - 1.9, -3.1), Vector3(1.7, 1.7, 1.7), K.TAS)
	w.rod(Vector3(0, H + 0.1, -2.5), Vector3(-0.8, H - 1.0, -3.1), 0.1, K.DEMIR)
	w.rod(Vector3(0, H + 0.1, -2.5), Vector3(0.8, H - 1.0, -3.1), 0.1, K.DEMIR)
	w.solid_box(Vector3(0, H - 2.0, -3.1), Vector3(2.1, 2.1, 2.1))
	# sapan ve kese
	w.rod(Vector3(0, H + 2.0, 7.0), Vector3(0, H + 0.8, 8.4), 0.04, K.DERI)
	t.sph(Vector3(0, H + 0.6, 8.5), 0.34, K.TAS, 5)
	# vinç (windlass) arkada ve sandık merdiveni
	w.cylp(Vector3(0, 0.9, 6.9), 0.3, 3.0, K.AHSAP2, 8, -1.0, Vector3(0, 0, 90))
	# sandık yığını: sokaktan çalışma platformuna (1,1 m) basamak
	w.box(Vector3(-3.4, 0.28, 2.0), Vector3(1.0, 0.56, 1.0), K.AHSAP_A)
	w.solid_box(Vector3(-3.4, 0.28, 2.0), Vector3(1.0, 0.56, 1.0))
	w.box(Vector3(-3.4, 0.56, 1.0), Vector3(1.0, 1.12, 1.0), K.AHSAP)
	w.solid_box(Vector3(-3.4, 0.56, 1.0), Vector3(1.0, 1.12, 1.0))
	w.box(Vector3(-2.7, 0.56, -0.2), Vector3(1.2, 0.12, 4.4), K.AHSAP_A)
	# Gülle yığını
	_gulle_piramit(t, Vector3(4.0, 0, 3.0), 0.3, 3, K.TAS)
	w.done(host, "mancinik")
	t.done(host, "tas")


# ------------------------------------------------------------------ Kuşatma kulesi (hazırlık)

static func build_kule(host: Node3D, k: float, lod: int, tohum := 9) -> void:
	var w := B.new("wood")
	var d := B.new("rubble")
	var r := K.rr(tohum)
	var S := 4.6
	var H := 13.0
	# tekerlekler + kızak
	w.box(Vector3(0, 0.55, 0), Vector3(S + 1.0, 0.5, S + 1.0), K.AHSAP2)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			w.cyl(B.xf(Vector3(sx * (S / 2 + 0.55), 0.8, sz * (S / 2 - 0.2)), 0.0, Vector3(0, 0, 90)), 0.8, 0.28, K.AHSAP2, 10)
			w.cyl(B.xf(Vector3(sx * (S / 2 + 0.55), 0.8, sz * (S / 2 - 0.2)), 0.0, Vector3(0, 0, 90)), 0.2, 0.34, K.DEMIR, 6)
	# gövde: yaş deri örtülü, üç kat
	w.box(Vector3(0, 0.8 + H / 2.0, 0), Vector3(S, H, S), K.DERI)
	w.solid_box(Vector3(0, 0.8 + H / 2.0, 0), Vector3(S, H, S))
	d.box(Vector3(0, 0.8 + H / 2.0, 0), Vector3(S + 0.05, H - 0.2, S - 0.1), K.DERI.darkened(0.08))
	# köşe direkleri ve çapraz payandalar (dışa görünür)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			w.box(Vector3(sx * (S / 2 + 0.05), 0.8 + H / 2.0, sz * (S / 2 + 0.05)), Vector3(0.3, H, 0.3), K.AHSAP2)
	for lv in 3:
		var y0 := 0.9 + lv * (H / 3.0)
		for sd in [-1, 1]:
			w.box(Vector3(0, y0, sd * (S / 2 + 0.06)), Vector3(S + 0.3, 0.28, 0.12), K.AHSAP)
			w.box(Vector3(sd * (S / 2 + 0.06), y0, 0), Vector3(0.12, 0.28, S + 0.3), K.AHSAP)
		w.rod(Vector3(-S / 2, y0, S / 2 + 0.1), Vector3(S / 2, y0 + H / 3.0, S / 2 + 0.1), 0.14, K.AHSAP)
		w.rod(Vector3(S / 2, y0, S / 2 + 0.1), Vector3(-S / 2, y0 + H / 3.0, S / 2 + 0.1), 0.14, K.AHSAP)
	# mazgal: üst kat korkuluk
	w.box(Vector3(0, 0.8 + H + 0.55, 0), Vector3(S + 0.4, 1.1, S + 0.4), K.AHSAP_A)
	for i in 6:
		w.box(Vector3(-S / 2 + 0.2 + i * (S - 0.4) / 5.0, 0.8 + H + 1.3, S / 2 + 0.2), Vector3(0.35, 0.6, 0.2), K.AHSAP)
	w.solid_box(Vector3(0, 0.8 + H + 0.55, 0), Vector3(S + 0.4, 1.1, S + 0.4))
	# köprü (indirme kapağı) öne doğru kalkık
	w.rod(Vector3(0, 0.8 + H * 0.6, S / 2 + 0.2), Vector3(0, 0.8 + H * 0.6 + 3.2, S / 2 + 1.6), 0.12, K.AHSAP2, 3.0)
	# zincir/halat
	w.rod(Vector3(0, 0.8 + H - 1.5, S / 2 + 0.1), Vector3(0, 0.8 + H * 0.6 + 3.2, S / 2 + 1.6), 0.04, K.DERI.darkened(0.3))
	# sancak tepede
	var sf := B.new()
	sancak(w, sf, Vector3(0, 0.8 + H + 1.1, 0), 3.4, K.KIRMIZI)
	w.solid_cyl(Vector3(0, 0.8 + H + 1.1 + 1.7, 0), 0.08, 3.4)
	# yan merdiven: zeminden birinci kat sahanlığına (4,3 m) — x yönünde kuleye yaslı
	var plat_y := 0.8 + H / 3.0 + 0.1
	var steps := int(ceil(plat_y / 0.27))
	var rise := plat_y / steps
	var run := 0.34
	for i in steps:
		var sx2 := -S / 2 - 1.8 - (steps - 1 - i) * run
		var sp := Vector3(sx2, rise * (i + 1) * 0.5, -S / 2 + 1.1)
		w.box(sp, Vector3(run + 0.02, rise * (i + 1), 1.4), K.AHSAP_A if i % 2 == 0 else K.AHSAP)
		w.solid_box(sp, Vector3(run + 0.02, rise * (i + 1), 1.4))
	w.box(Vector3(-S / 2 - 0.9, plat_y - 0.1, -S / 2 + 1.1), Vector3(1.8, 0.2, 1.6), K.AHSAP_A)
	w.solid_box(Vector3(-S / 2 - 0.9, plat_y - 0.1, -S / 2 + 1.1), Vector3(1.8, 0.2, 1.6))
	w.done(host, "kule")
	d.done(host, "deri")
	sf.done(host, "bayrak")
