class_name IstHipodrom
extends RefCounted
## İstanbul, Nisan 1453: Hipodrom (At Meydanı) ve çevresi. Kayıt `catalog()`, kurucular `build_<id>`, konma ve tırmanma
## noktaları `perches_<id>` / `climbs_<id>`. Küme kurucu: `build(id, host, k, lod)`, `perches(id, k)`, `climbs(id, k)`.
## Diğer yapılar: hipodrom_saray.gd (IstHipoSaray), hipodrom_aug.gd (IstHipoAug).
##
## Yerel eksen: +x doğu, -z kuzey (yon_derece = 0). Hipodromun uzun ekseni z boyunca; kuzey ucunda (−z) carceres,
## güney ucunda (+z) sphendone (yarım daire biçimli kavisli uç). Gerçekte uzun eksen KD–GB'dir (kestirim ~35°).
## k yalnız KÜTLEYİ ölçekler; basamak (0,4 × 0,9 m), kapı (2,2 m), yürüme yolu (≥ 1,4 m) gerçek boyda kalır.

const K := preload("res://scripts/world/ist/hipodrom_kit.gd")

# Gerçek ölçüler (metre). Kaynaklar: raporun başı. Kestirim işaretlileri rapor.md'de.
const REAL_L := 430.0         # toplam uzunluk (kestirim; ~117 × ~430 m)
const REAL_ARENA_HALF := 36.0 # pist yarı genişliği (kestirim)
const TIER_RISE := 0.40
const TIER_RUN := 0.90

static func catalog() -> Array:
	var out: Array = [{
		"id": "hipodrom", "ad": "Hipodrom (At Meydanı)",
		"dogu_m": -235.0, "kuzey_m": -285.0,
		"gercek_olcu": Vector3(117.0, 14.0, 430.0),
		"yon_derece": 35.0, "durum": "harap", "tur": "anit",
		"bakis": Vector3(0, 28.0, -10.0), "bakis_r": 70.0, "gorev": true,
	}]
	out.append_array(IstHipoSaray.catalog())
	out.append_array(IstHipoAug.catalog())
	return out


static func build(id: String, host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	match id:
		"hipodrom": build_hipodrom(host, k, lod)
		"buyuk_saray": IstHipoSaray.build_buyuk_saray(host, k, lod)
		"khalke": IstHipoSaray.build_khalke(host, k, lod)
		"zeuksippos": IstHipoSaray.build_zeuksippos(host, k, lod)
		"nea": IstHipoSaray.build_nea(host, k, lod)
		"augustaion": IstHipoAug.build_augustaion(host, k, lod)
		"milion": IstHipoAug.build_milion(host, k, lod)
		"aya_irini": IstHipoAug.build_aya_irini(host, k, lod)
		"sergios": IstHipoAug.build_sergios(host, k, lod)


static func perches(id: String, k: float = 0.5) -> Array:
	match id:
		"hipodrom": return perches_hipodrom(k)
		"buyuk_saray": return IstHipoSaray.perches_buyuk_saray(k)
		"khalke": return IstHipoSaray.perches_khalke(k)
		"zeuksippos": return IstHipoSaray.perches_zeuksippos(k)
		"nea": return IstHipoSaray.perches_nea(k)
		"augustaion": return IstHipoAug.perches_augustaion(k)
		"milion": return IstHipoAug.perches_milion(k)
		"aya_irini": return IstHipoAug.perches_aya_irini(k)
		"sergios": return IstHipoAug.perches_sergios(k)
	return []


static func climbs(id: String, k: float = 0.5) -> Array:
	match id:
		"hipodrom": return climbs_hipodrom(k)
		"buyuk_saray": return IstHipoSaray.climbs_buyuk_saray(k)
		"khalke": return IstHipoSaray.climbs_khalke(k)
		"zeuksippos": return IstHipoSaray.climbs_zeuksippos(k)
		"nea": return IstHipoSaray.climbs_nea(k)
		"augustaion": return IstHipoAug.climbs_augustaion(k)
		"milion": return IstHipoAug.climbs_milion(k)
		"aya_irini": return IstHipoAug.climbs_aya_irini(k)
		"sergios": return IstHipoAug.climbs_sergios(k)
	return []


# ---- geometri parametreleri (k'ye bağlı) -------------------------------------------------------------------------
static func _n_tiers(k: float) -> int:
	return maxi(8, roundi(26.0 * k))

static func _arena_half(k: float) -> float:
	return maxf(REAL_ARENA_HALF * k, 14.0)

static func _len(k: float) -> float:
	return REAL_L * k

static func _band(k: float) -> float:
	return _n_tiers(k) * TIER_RUN

static func _wall_t(_k: float) -> float:
	return 3.0

## Sphendone yarım dairesinin merkezi z'si
static func _sph_cz(k: float) -> float:
	return _len(k) * 0.5 - (_arena_half(k) + _band(k) + _wall_t(k))

## Spina üstündeki anıtların z konumları (carceres'ten sphendone'ya)
static func _spina_z(k: float) -> Dictionary:
	var L := _len(k)
	return {"obelisk": -L * 0.16, "yilanli": -L * 0.02, "orme": L * 0.16, "kolon1": -L * 0.09, "kolon2": L * 0.07,
			"bas": -L * 0.26, "son": _sph_cz(k) - 12.0 * k}


static func build_hipodrom(host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var L := _len(k)
	var A := _arena_half(k)
	var n := _n_tiers(k)
	var band := _band(k)
	var wt := _wall_t(k)
	var cz := _sph_cz(k)
	var z_n := -L * 0.5
	var out_x := A + band + wt           # dış duvarın dış yüzü
	var top_h := n * TIER_RISE
	if lod >= 2:
		K.ground_box(host, out_x * 2.0, top_h + 2.0, cz - z_n, 0, (cz + z_n) * 0.5, K.STONE_D)
		K.dome(host, out_x, top_h + 2.0, Vector3(0, 0, cz), K.STONE_D, 8)
		K.ground_box(host, 3.0, 20.0 * k + 6.0, 3.0, 0, -L * 0.16, K.GRANITE)
		return
	# ---- pist: kumlu ot döşeme (zemin y=0'ın 3 cm üstünde ince katı) ----
	K.sb(host, Vector3(A * 2.0, 0.06, cz - z_n), Vector3(0, 0.03, (cz + z_n) * 0.5), K.SAND, "")
	_sphendone_floor(host, A, cz)
	# ---- oturma basamakları (iki uzun kenar), yıkık ----
	var seg := maxf(14.0, 40.0 * k)
	for sx: float in [-1.0, 1.0]:
		var z := z_n + 14.0 * k          # carceres'ten sonra
		var idx := 0
		while z < cz - 2.0:
			var len := minf(seg * rng.randf_range(0.7, 1.4), cz - z)
			# orta kesim (z ≈ 0 çevresi) her iki kenarda sağlam: tırmanma yolu
			var near_mid: bool = absf(z + len * 0.5 - L * 0.04) < seg * 0.9
			var keep: float = 1.0 if near_mid else rng.randf_range(0.35, 1.0)
			var gap := (not near_mid) and rng.randf() < 0.2
			if gap:
				keep = 0.3
			var nr := _fix_nr(maxi(2, roundi(n * keep)), n)
			_tier_block(host, sx, z, len, A, nr, n, rng, lod, (idx % 2) == 0)
			_back_wall(host, sx, z, len, A + band, wt, top_h, keep, rng, lod)
			z += len
			idx += 1
	# ---- sphendone ----
	_sphendone(host, A, band, wt, cz, n, rng, lod)
	# ---- carceres (kuzey ucu) ----
	_carceres(host, A, z_n, k, rng, lod)
	# ---- spina ----
	_spina(host, k, rng, lod)
	# ---- kathisma kalıntısı (doğu duvarına yaslı, imparator locası) ----
	_kathisma(host, A, band, wt, k, rng, lod)
	# ---- dış duvar taş basamağı (sokaktan seyirci basamağına yol), doğu kenar ----
	_outer_stairs(host, k)
	# ---- ot, moloz, hayvan ----
	K.scatter(host, Rect2(-A + 1.0, z_n + 6.0, A * 2.0 - 2.0, cz - z_n - 10.0), int(300 * k + 60), rng, 0.06, "ot")
	K.scatter(host, Rect2(-A, z_n + 4.0, A * 2.0, cz - z_n), int(80 * k + 20), rng, 0.06, "moloz")
	_hayvanlar(host, A, cz, z_n, rng)


## Kırık basamak ile arkadaki duvar arası ya 0 ya ≥ 1,4 m olsun (dar aralık yok)
static func _fix_nr(nr: int, n: int) -> int:
	return n if n - nr < 2 else nr


## Düz kenar basamak bloğu: nr basamak kalmış (içten dışa), n toplam. Her basamak kendi katı kutusu (tabanı zeminde).
static func _tier_block(host: Node3D, sx: float, z: float, len: float, A: float, nr: int, _n: int, rng: RandomNumberGenerator, lod: int, alt: bool) -> void:
	var col := K.STONE if alt else K.LIGHT.darkened(0.06)
	for i in nr:
		var h := (i + 1) * TIER_RISE
		var x0 := A + i * TIER_RUN
		var cx := sx * (x0 + TIER_RUN * 0.5)
		var c := col.darkened(0.03 * (i % 3))
		K.ground_box(host, TIER_RUN, h, len, cx, z + len * 0.5, c, "ashlar")
	# kırık uçta moloz yığını
	if lod == 0 and nr < _n:
		var top := nr * TIER_RISE
		for j in 3:
			var r := Vector3(rng.randf_range(0.5, 1.2), rng.randf_range(0.3, 0.7), rng.randf_range(0.5, 1.4))
			K.vb(host, r, Vector3(sx * (A + nr * TIER_RUN + rng.randf_range(0.3, 1.5)), top + r.y * 0.5 - 0.1 + 0.02, z + rng.randf() * len), K.STONE_D, Vector3(0, rng.randf() * 90.0, 0))


## Oturma basamaklarının arkasındaki iki katlı kemerli dış duvar (alt yapı): keep = sağlam oranı
static func _back_wall(host: Node3D, sx: float, z: float, len: float, x_in: float, wt: float, top_h: float, keep: float, rng: RandomNumberGenerator, lod: int) -> void:
	var h := top_h + 1.6
	if keep < 0.8:
		h = maxf(top_h * keep + 1.0, 2.8)
	var cx := sx * (x_in + wt * 0.5)
	K.ground_box(host, wt, h, len, cx, z + len * 0.5, K.BRICK2.lerp(K.STONE_D, 0.45), "brick")
	if lod == 0:
		# dış yüzde iki sıra kemer boşluğu (koyu) ve üstte silme
		var face_x := sx * (x_in + wt) + sx * 0.02
		var storeys := 2 if h > 6.0 else 1
		K.arcade_face(host, Vector3(face_x, 0.0, z + len * 0.5), Vector3(sx, 0, 0), len, h - 0.4, 4.2, 1.1, K.BRICK2, storeys)
		# üst silme (parapet): yürünebilir tepe üstünde ot
		K.vb(host, Vector3(wt + 0.3, 0.22, len), Vector3(cx, h + 0.11, z + len * 0.5), K.STONE_D)
		K.vb(host, Vector3(wt * 0.8, 0.12, len * 0.8), Vector3(cx, h + 0.28, z + len * 0.5), K.MOSS)


static func _sphendone_floor(host: Node3D, A: float, cz: float) -> void:
	# yarım daire pist ucu: 10 dilimlik düz kapaklar (dişli çokgen), üstleri 6 cm
	var n := 10
	for i in n:
		var a0 := PI * i / n
		var a1 := PI * (i + 1) / n
		var m := (a0 + a1) * 0.5
		var r := A * 0.5
		var chord := 2.0 * A * sin((a1 - a0) * 0.5) * 1.05
		var cx := cos(m) * r
		var cy := cz + sin(m) * r
		var body := K.sb(host, Vector3(A * 1.02, 0.06, chord * 0.75), Vector3(cx, 0.03, cy), K.SAND, "", Vector3(0, -rad_to_deg(m), 0))
		body.name = "SphFloor"


static func _sphendone(host: Node3D, A: float, band: float, wt: float, cz: float, n: int, rng: RandomNumberGenerator, lod: int) -> void:
	var segs := 14
	for s in segs:
		var a0 := PI * s / segs
		var a1 := PI * (s + 1) / segs
		var m := (a0 + a1) * 0.5
		# bu dilimdeki kalan basamak sayısı: sağlam çoğunluk, birkaç kırık
		var nr := n
		for i in nr:
			var r_in := A + i * TIER_RUN
			var r_mid := r_in + TIER_RUN * 0.5
			var h := (i + 1) * TIER_RISE
			var chord := 2.0 * (r_in + TIER_RUN) * tan((a1 - a0) * 0.5) + 0.08
			var pos := Vector3(cos(m) * r_mid, h * 0.5, cz + sin(m) * r_mid)
			K.sb(host, Vector3(TIER_RUN, h, chord), pos, K.STONE.darkened(0.03 * (i % 3)), "ashlar", Vector3(0, -rad_to_deg(m), 0))
		# alt yapı duvarı (kemerli, iki kat)
		var r_o := A + band
		var hh := n * TIER_RISE + 1.6
		if nr < n:
			hh = maxf(nr * TIER_RISE + 1.0, 3.0)
		var chord2 := 2.0 * (r_o + wt) * tan((a1 - a0) * 0.5) + 0.08
		var rot := Vector3(0, -rad_to_deg(m), 0)
		var pos2 := Vector3(cos(m) * (r_o + wt * 0.5), hh * 0.5, cz + sin(m) * (r_o + wt * 0.5))
		K.sb(host, Vector3(wt, hh, chord2), pos2, K.BRICK2.lerp(K.STONE_D, 0.45), "brick", rot)
		if lod == 0:
			var out := Vector3(cos(m), 0, sin(m))
			var fp := Vector3(cos(m) * (r_o + wt) + out.x * 0.02, 0.0, cz + sin(m) * (r_o + wt) + out.z * 0.02)
			K.arcade_face(host, fp, out, chord2, hh - 0.4, 4.2, 1.1, K.BRICK2, 2 if hh > 6.0 else 1)
			K.vb(host, Vector3(wt + 0.3, 0.22, chord2), pos2 + Vector3(0, hh * 0.5 + 0.11, 0), K.STONE_D, rot)


static func _carceres(host: Node3D, A: float, z_n: float, k: float, rng: RandomNumberGenerator, lod: int) -> void:
	# kuzey ucu: iki kule arasında on iki kapılı başlangıç binası, tepesi düz (tonoz sırtı, ot), kapı boşlukları koyu
	var w := (A + _band(k) + _wall_t(k)) * 2.0
	var depth := 12.0
	var h := maxf(9.0 * k + 3.0, 7.0)
	var cz := z_n + depth * 0.5 - 0.0
	K.ground_box(host, w, h, depth, 0, cz, K.BRICK.lerp(K.STONE, 0.4), "brick")
	if lod == 0:
		# 12 kapı: pist yüzüne (+z) bakan koyu kemerli girintiler
		var face_z := z_n + depth + 0.02
		var nn := 12
		for i in nn:
			var x := (i + 0.5 - nn * 0.5) * (2.0 * A / nn)
			K.vb(host, Vector3(2.0 * A / nn - 1.0, 3.4, 0.08), Vector3(x, 1.7, face_z), K.DARK)
			K.vb(host, Vector3(2.0 * A / nn - 0.8, 0.2, 0.12), Vector3(x, 3.5, face_z + 0.02), K.LIGHT)
		K.vb(host, Vector3(w, 0.3, depth + 0.4), Vector3(0, h + 0.15, cz), K.STONE_D)
		K.vb(host, Vector3(w * 0.9, 0.15, depth * 0.8), Vector3(0, h + 0.38, cz), K.MOSS)
		# yıkık çatı tepeleri ve ot
		K.scatter(host, Rect2(-w * 0.45, cz - depth * 0.4, w * 0.9, depth * 0.8), int(60 * k + 20), rng, h + 0.3, "ot")
	# iki kule (tepeleri düz, mazgallı)
	for sx: float in [-1.0, 1.0]:
		var tx := sx * (w * 0.5 - 6.0)
		var th := h + 6.0
		K.ground_box(host, 10.0, th, 10.0, tx, cz, K.BRICK.lerp(K.STONE, 0.3), "brick")
		K.vb(host, Vector3(10.6, 0.3, 10.6), Vector3(tx, th + 0.15, cz), K.STONE_D)
		if lod == 0:
			for j in 4:
				for e in 2:
					var o := (j - 1.5) * 2.4
					K.vb(host, Vector3(1.2, 0.55, 0.5), Vector3(tx + o, th + 0.55, cz + (-5.0 if e == 0 else 5.0)), K.STONE_D)
					K.vb(host, Vector3(0.5, 0.55, 1.2), Vector3(tx + (-5.0 if e == 0 else 5.0), th + 0.55, cz + o), K.STONE_D)
			# kule penceresi
			K.vb(host, Vector3(1.0, 1.6, 0.08), Vector3(tx, th * 0.7, cz + 5.02), K.DARK)


static func _spina(host: Node3D, k: float, rng: RandomNumberGenerator, lod: int) -> void:
	var z := _spina_z(k)
	var z0: float = z["bas"]
	var z1: float = z["son"]
	var len := z1 - z0
	var cz := (z0 + z1) * 0.5
	# alçak taş platform (1,0 m, iki basamaklı): uçlarda 0,5 m'lik ara basamak
	K.ground_box(host, 6.0, 1.0, len, 0, cz, K.STONE.darkened(0.08), "ashlar")
	K.ground_box(host, 7.6, 0.5, len + 3.2, 0, cz, K.STONE_D, "ashlar")
	if lod == 0:
		# su kanalı / kenar silmesi
		K.vb(host, Vector3(0.3, 0.14, len), Vector3(-2.8, 1.07, cz), K.LIGHT)
		K.vb(host, Vector3(0.3, 0.14, len), Vector3(2.8, 1.07, cz), K.LIGHT)
	# --- Teodosius Dikilitaşı (Mısır): kaide + bronz küpler + granit gövde + piramidyon ---
	var oz: float = z["obelisk"]
	var ow := maxf(1.9 * k + 0.8, 1.5)
	var oh := 19.6 * k + 4.0
	K.ground_box(host, 7.0 * k + 3.0, 2.4, 7.0 * k + 3.0, 0, oz, K.MARBLE.darkened(0.06), "marble", 1.0)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			K.ground_box(host, 0.9, 0.7, 0.9, sx * 1.0, oz + sz * 1.0, K.BRONZE, "", 3.4)
	K.ground_box(host, ow * 1.6, 0.4, ow * 1.6, 0, oz, K.BRONZE.darkened(0.1), "", 4.1)
	var shaft := K.sc(host, ow * 0.5, oh, Vector3(0, 4.5 + oh * 0.5, oz), K.GRANITE, 4, ow * 0.3, Vector3(0, 45, 0), 1.0)
	var piramid := K.sc(host, ow * 0.3, 0.9, Vector3(0, 4.5 + oh + 0.45, oz), K.GOLD.darkened(0.15), 4, 0.02, Vector3(0, 45, 0), 1.0)
	if lod == 0:
		# hiyeroglif şeritleri (koyu, hafif çıkıntı) dört yüzde
		for yy in 6:
			var y := 4.5 + oh * (0.18 + 0.13 * yy)
			var wdt := lerpf(ow * 0.85, ow * 0.6, (y - 4.5) / oh)
			for f in 4:
				var ang := f * 90.0 + 45.0
				var dir := Vector3(sin(deg_to_rad(ang + 45.0)), 0, cos(deg_to_rad(ang + 45.0)))
				K.vb(host, Vector3(wdt * 0.55, 0.5, 0.05), Vector3(dir.x * wdt * 0.5 * 0.74, y, oz + dir.z * wdt * 0.5 * 0.74), K.GRANITE.darkened(0.3), Vector3(0, ang + 45.0 + 90.0, 0))
	# --- Yılanlı Sütun: üç yılanın sarılı gövdesi (bronz), üç baş, kaide çukuru ---
	var yz: float = z["yilanli"]
	K.ground_box(host, 3.4, 0.7, 3.4, 0, yz, K.STONE.darkened(0.1), "ashlar", 1.0)
	var sh := maxf(8.0 * k + 3.0, 6.5)
	K.sc(host, 0.62, sh, Vector3(0, 1.7 + sh * 0.5, yz), K.BRONZE, 10, 0.42, Vector3.ZERO, 1.0)
	if lod == 0:
		for i in 9:
			var y2 := 1.9 + i * (sh - 0.6) / 9.0
			var rr := lerpf(0.66, 0.46, float(i) / 9.0)
			K.vb(host, Vector3(rr * 2.0 + 0.1, 0.12, rr * 2.0 + 0.1), Vector3(0, y2, yz), K.BRONZE.lightened(0.12), Vector3(0, i * 33.0, 0))
		for hh in 3:
			var a := TAU * hh / 3.0
			Props.ball(host, 0.3, Vector3(cos(a) * 0.38, 1.7 + sh + 0.1, yz + sin(a) * 0.38), K.BRONZE.darkened(0.12), Vector3(1.2, 0.8, 1.2), 6)
	# --- Örme Dikilitaş (Konstantinos Porphyrogennetos): kaba taş, bronz levhaları sökülmüş ---
	var mz: float = z["orme"]
	var mw := maxf(3.4 * k + 1.2, 2.4)
	var mh := 32.0 * k * 0.55 + 4.0
	K.ground_box(host, mw + 1.4, 1.6, mw + 1.4, 0, mz, K.STONE.darkened(0.12), "ashlar", 1.0)
	var ob := K.sc(host, mw * 0.5, mh, Vector3(0, 2.6 + mh * 0.5, mz), Color("a89472"), 4, mw * 0.4, Vector3(0, 45, 0), 1.0)
	if lod == 0:
		# sıra sıra taş dizisi ve bronz levha çivi delikleri (koyu noktalar)
		for r in 14:
			var yy2 := 2.8 + r * (mh - 0.4) / 14.0
			K.vb(host, Vector3(mw * 0.95, 0.05, mw * 0.95), Vector3(0, yy2, mz), Color("8f7c5c"), Vector3(0, 45, 0))
		for sp in 8:
			var sy := 3.0 + rng.randf() * (mh - 1.0)
			K.vb(host, Vector3(0.35, 0.28, 0.06), Vector3(rng.randf_range(-0.5, 0.5) * mw * 0.5, sy, mz + mw * 0.3), K.DARK.lightened(0.15), Vector3(0, 45, 0))
		K.sc(host, 0.3, 0.8, Vector3(0, 2.6 + mh + 0.4, mz), K.GOLD.darkened(0.2), 4, 0.02, Vector3(0, 45, 0), 1.0)
	# --- birkaç yıkık sütun / kaide ---
	for key in ["kolon1", "kolon2"]:
		var cz2: float = z[key]
		var ch := rng.randf_range(2.5, 5.0)
		K.sc(host, 0.5, ch, Vector3(0, 1.0 + ch * 0.5, cz2), K.MARBLE.darkened(0.05), 10, 0.45, Vector3.ZERO, 1.0)
		K.vb(host, Vector3(1.4, 0.3, 1.4), Vector3(0, 1.0 + ch + 0.15, cz2), K.LIGHT)
	# spina uçlarında "meta" (dönüş direği) kaideleri
	for zz in [z0, z1]:
		K.ground_box(host, 2.2, 2.0, 2.2, 0, zz + (1.2 if zz == z0 else -1.2), K.MARBLE.darkened(0.1), "marble", 0.5)
		K.sc(host, 0.35, 3.0, Vector3(0, 2.5 + 1.5, zz + (1.2 if zz == z0 else -1.2)), K.GOLD.darkened(0.25), 8, 0.2, Vector3.ZERO, 1.0)


static func _kathisma(host: Node3D, A: float, band: float, wt: float, k: float, rng: RandomNumberGenerator, lod: int) -> void:
	# doğu kenarının ortasında, dış duvardan dışarı taşan tuğla kütle: iç loca kemeri, yarı çökmüş kubbe kasnağı
	var x_out := A + band + wt
	var cz := _len(k) * 0.04
	var hh := (_n_tiers(k) * TIER_RISE) + 5.0
	K.ground_box(host, 14.0, hh, 24.0, x_out + 5.0, cz, K.BRICK, "brick")
	if lod == 0:
		# sahne yüzünde üç kemerli ön
		for j in 3:
			K.vb(host, Vector3(0.08, 4.2, 4.0), Vector3(x_out + 12.02, 3.0, cz - 7.0 + j * 7.0), K.DARK)
			K.vb(host, Vector3(0.12, 0.2, 4.4), Vector3(x_out + 12.04, 5.2, cz - 7.0 + j * 7.0), K.LIGHT)
		# kasnak: yarım yıkılmış (düz kesik)
		K.sc(host, 4.0, 3.0, Vector3(x_out + 5.0, hh + 1.5, cz), K.BRICK2, 12, 3.8)
		for i in 5:
			var a := PI * 0.1 + PI * 0.8 * i / 4.0
			K.vb(host, Vector3(0.8, 1.4, 0.12), Vector3(x_out + 5.0 + cos(a) * 3.95, hh + 1.5, cz + sin(a) * 3.95), K.DARK, Vector3(0, -rad_to_deg(a) + 90.0, 0))
		K.vb(host, Vector3(9.0, 0.3, 9.0), Vector3(x_out + 5.0, hh + 3.15, cz), K.STONE_D)
		K.scatter(host, Rect2(x_out + 1.0, cz - 3.0, 8.0, 6.0), 30, rng, hh + 3.3, "ot")
	# zeminden kathisma'ya taş basamak sırası (sokaktan çıkış): her biri 0,4 m
	var steps := int(hh / 0.4)
	for s in steps:
		K.ground_box(host, 0.6, (s + 1) * 0.4, 3.0, x_out + 12.3 + (steps - 1 - s) * 0.6, cz + 8.0, K.STONE_D, "ashlar")


static func _outer_stairs(host: Node3D, k: float) -> void:
	# batı kenar dışından yıkık duvar boyunca moloz basamakları → son oturma basamağının üstü
	var A := _arena_half(k)
	var x_out := A + _band(k) + _wall_t(k)
	var z := _len(k) * -0.12
	var wall_h := _n_tiers(k) * TIER_RISE + 1.6
	# rampa değil: 0,4 m'lik taş basamaklar, duvar yüksekliğine kadar (geniş 2 m)
	var steps := int(wall_h / 0.4) + 1
	for s in steps:
		K.ground_box(host, 0.6, (s + 1) * 0.4, 2.4, -(x_out + 0.3 + (steps - 1 - s) * 0.6), z, K.STONE.darkened(0.08), "ashlar")


static func _hayvanlar(host: Node3D, A: float, cz: float, z_n: float, rng: RandomNumberGenerator) -> void:
	# otlayan koyun/at. CANLI (kalite notu 32): görünüş canli_kit'ten (kesit halkalı, orta katman); kutu yok. Çarpışma
	# kutuları, yerleri, RNG tüketimi ve sayısı eskisi gibi (görünmez katı).
	const CK = preload("res://scripts/world/ist/canli_kit.gd")
	for i in 9:
		var p := Vector3(rng.randf_range(-A * 0.8, A * 0.8), 0.0, rng.randf_range(z_n + 20.0, cz - 10.0))
		var horse := (i % 3) == 0
		var bc := Color("8a6a4a") if horse else Color("ece4d2")
		var sz := Vector3(0.5, 0.7, 1.4) if horse else Vector3(0.45, 0.5, 0.8)
		var body := _gorunmez_kati(host, sz, Vector3(p.x, sz.y * 0.5 + (0.45 if horse else 0.0), p.z))
		if horse:
			_gorunmez_kati(host, Vector3(0.4, 0.45, 1.0), Vector3(p.x, 0.225, p.z)).rotation.y = rng.randf() * TAU
		body.rotation.y = rng.randf() * TAU
		var mi := MeshInstance3D.new()
		mi.mesh = CK.mesh("at" if horse else "koyun", 1, {"renk": bc, "poz": "otla" if i % 2 == 0 else "dur"})
		mi.material_override = CK.mat()
		mi.position = p
		mi.rotation.y = body.rotation.y
		host.add_child(mi)


static func _gorunmez_kati(host: Node3D, size: Vector3, pos: Vector3) -> StaticBody3D:
	var b := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	b.add_child(cs)
	b.position = pos
	host.add_child(b)
	return b


# ---- konma noktaları ve tırmanma yolları -------------------------------------------------------------------------
static func perches_hipodrom(k: float = 0.5) -> Array:
	var z := _spina_z(k)
	var oh := 19.6 * k + 4.0
	var out: Array = []
	out.append(Vector3(0, 4.5 + oh + 0.9, z["obelisk"]))           # Mısır Dikilitaşı piramidyonu
	var mh := 32.0 * k * 0.55 + 4.0
	out.append(Vector3(0, 2.6 + mh + 0.8, z["orme"]))               # Örme Dikilitaş
	var sh := maxf(8.0 * k + 3.0, 6.5)
	out.append(Vector3(0, 1.7 + sh + 0.55, z["yilanli"]))           # Yılanlı Sütun başları
	var w := (_arena_half(k) + _band(k) + _wall_t(k)) * 2.0
	out.append(Vector3(-(w * 0.5 - 6.0), maxf(9.0 * k + 3.0, 7.0) + 6.3, -_len(k) * 0.5 + 6.0))   # carceres kulesi
	return out


static func climbs_hipodrom(k: float = 0.5) -> Array:
	var A := _arena_half(k)
	var n := _n_tiers(k)
	var band := _band(k)
	var x_out := A + band + _wall_t(k)
	var wall_h := n * TIER_RISE + 1.6
	var out: Array = []
	# pist → orta kesim basamakları (her iki yan): alt = pist kenarı, üst = en üst basamak
	for sx: float in [-1.0, 1.0]:
		out.append([Vector3(sx * (A - 0.8), 0, _len(k) * 0.04), Vector3(sx * (A + (n - 1) * TIER_RUN + 0.45), n * TIER_RISE, _len(k) * 0.04), "basamak"])
	# sokak → dış taş basamak → duvar tepesi
	var ws := int(wall_h / 0.4) + 1
	out.append([Vector3(-(x_out + 0.3 + (ws - 1) * 0.6 + 1.4), 0, -_len(k) * 0.12), Vector3(-(x_out + 0.3), ws * 0.4, -_len(k) * 0.12), "basamak"])
	# kathisma basamakları
	var hh := n * TIER_RISE + 5.0
	var steps := int(hh / 0.4)
	out.append([Vector3(x_out + 12.3 + (steps - 1) * 0.6 + 1.4, 0, _len(k) * 0.04 + 8.0), Vector3(x_out + 12.3, steps * 0.4, _len(k) * 0.04 + 8.0), "basamak"])
	# spina platformu: uç basamak (0,5 m) → 1,0 m platform
	var z := _spina_z(k)
	var zm := (float(z["obelisk"]) + float(z["kolon1"])) * 0.5
	out.append([Vector3(4.9, 0, zm), Vector3(0, 1.0, zm), "basamak"])
	return out
