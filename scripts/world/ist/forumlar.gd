class_name IstForumlar
extends RefCounted
## İstanbul, Nisan 1453: Mese, forumlar ve anıt sütunlar.
## Öğeler: mese, konstantin, tauri, amastrianon, bovis, arkadius, markianos, myrelaion, philadelphion, kapitolion,
## anemodoulion. Her biri build_x / perches_x / climbs_x ile (dondurulmuş arayüz). Yerel koordinat: merkez = tabanın
## ortası, zemin y = 0, +x doğu, -z kuzey. k yalnız kütleyi ölçekler; insan ölçüsü sabit.
## Oyuncu: JUMP 3,6 → zıplama 0,66 m; STEP_H 0,42; tırmanma kipinde REACH 2,3 / VAULT 1,1 (bkz. rapor).

const Y = preload("res://scripts/world/ist/forumlar_yapi.gd")

const IDS := ["mese", "konstantin", "tauri", "amastrianon", "bovis", "arkadius", "markianos", "myrelaion",
	"philadelphion", "kapitolion", "anemodoulion"]


## Kayıt: şehir kurucusu bunu okuyup yerleştirir. Konumlar (Ayasofya kubbesi 0,0; doğu/kuzey metre) KESTİRİM,
## ±100–200 m belirsiz; CityGeo dayanakları (Tauri, Havariyun, Konstantin Sütunu) gelince şehir kurucusu düzeltir.
static func catalog() -> Array:
	return [
		{"id": "mese", "ad": "Mese (Orta Cadde) revaklı dilimi", "dogu_m": -1000.0, "kuzey_m": -250.0,
			"gercek_olcu": Vector3(28.0, 11.0, 120.0), "yon_derece": 255.0, "durum": "harap", "tur": "ayrinti",
			"bakis": Vector3(0, 20.0, 0), "bakis_r": 40.0},
		{"id": "konstantin", "ad": "Konstantin Forumu ve Porfir Sütun", "dogu_m": -1160.0, "kuzey_m": -330.0,
			"gercek_olcu": Vector3(150.0, 38.0, 105.0), "yon_derece": 255.0, "durum": "harap", "tur": "anit",
			"bakis": Vector3(0, 46.0, 0), "bakis_r": 55.0, "gorev": true},
		{"id": "tauri", "ad": "Theodosius (Tauri) Forumu: zafer takı ve sütun", "dogu_m": -1750.0, "kuzey_m": -380.0,
			"gercek_olcu": Vector3(120.0, 40.0, 90.0), "yon_derece": 255.0, "durum": "harap", "tur": "anit",
			"bakis": Vector3(0, 48.0, 0), "bakis_r": 55.0, "gorev": true},
		{"id": "amastrianon", "ad": "Amastrianon meydanı", "dogu_m": -2050.0, "kuzey_m": -520.0,
			"gercek_olcu": Vector3(52.0, 8.0, 42.0), "yon_derece": 255.0, "durum": "harap", "tur": "ayrinti"},
		{"id": "bovis", "ad": "Forum Bovis (Öküz Forumu)", "dogu_m": -2300.0, "kuzey_m": -640.0,
			"gercek_olcu": Vector3(60.0, 8.0, 50.0), "yon_derece": 255.0, "durum": "harap", "tur": "anit",
			"bakis": Vector3(0, 14.0, 0), "bakis_r": 30.0},
		{"id": "arkadius", "ad": "Arkadius Sütunu", "dogu_m": -3100.0, "kuzey_m": -1250.0,
			"gercek_olcu": Vector3(11.0, 48.0, 11.0), "yon_derece": 0.0, "durum": "harap", "tur": "anit",
			"bakis": Vector3(0, 58.0, 0), "bakis_r": 60.0, "gorev": true},
		{"id": "markianos", "ad": "Markianos Sütunu (Kız Taşı)", "dogu_m": -1750.0, "kuzey_m": 1050.0,
			"gercek_olcu": Vector3(4.0, 14.0, 4.0), "yon_derece": 0.0, "durum": "saglam", "tur": "anit",
			"bakis": Vector3(0, 22.0, 0), "bakis_r": 30.0, "gorev": true},
		{"id": "myrelaion", "ad": "Myrelaion (Bodrum) kilisesi ve rotundası", "dogu_m": -2000.0, "kuzey_m": -1100.0,
			"gercek_olcu": Vector3(26.0, 18.0, 26.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
			"bakis": Vector3(0, 28.0, 0), "bakis_r": 40.0},
		{"id": "philadelphion", "ad": "Philadelphion dörtkapılı tak (tetrapylon)", "dogu_m": -2150.0, "kuzey_m": -760.0,
			"gercek_olcu": Vector3(26.0, 16.0, 26.0), "yon_derece": 255.0, "durum": "harap", "tur": "anit",
			"bakis": Vector3(0, 24.0, 0), "bakis_r": 35.0},
		{"id": "kapitolion", "ad": "Kapitolion kalıntısı", "dogu_m": -1200.0, "kuzey_m": 150.0,
			"gercek_olcu": Vector3(26.0, 14.0, 40.0), "yon_derece": 255.0, "durum": "harap", "tur": "anit",
			"bakis": Vector3(0, 22.0, 0), "bakis_r": 35.0},
		{"id": "anemodoulion", "ad": "Anemodoulion (rüzgâr kulesi)", "dogu_m": -2250.0, "kuzey_m": -330.0,
			"gercek_olcu": Vector3(8.0, 32.0, 8.0), "yon_derece": 0.0, "durum": "harap", "tur": "anit",
			"bakis": Vector3(0, 40.0, 0), "bakis_r": 40.0, "gorev": true},
	]


# ---------------------------------------------------------------------------------------------------------
# Dondurulmuş arayüz: sarmalayıcılar
# ---------------------------------------------------------------------------------------------------------
static func build_mese(host: Node3D, uzunluk := 96.0, k: float = 0.5, lod: int = 0) -> void:
	_kur("mese", host, k, lod, {"uzunluk": uzunluk})
static func perches_mese(k: float = 0.5, uzunluk := 96.0) -> Array: return _meta("mese", k, "perches", {"uzunluk": uzunluk})
static func climbs_mese(k: float = 0.5, uzunluk := 96.0) -> Array: return _meta("mese", k, "climbs", {"uzunluk": uzunluk})

static func build_konstantin(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("konstantin", host, k, lod)
static func perches_konstantin(k: float = 0.5) -> Array: return _meta("konstantin", k, "perches")
static func climbs_konstantin(k: float = 0.5) -> Array: return _meta("konstantin", k, "climbs")

static func build_tauri(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("tauri", host, k, lod)
static func perches_tauri(k: float = 0.5) -> Array: return _meta("tauri", k, "perches")
static func climbs_tauri(k: float = 0.5) -> Array: return _meta("tauri", k, "climbs")

static func build_amastrianon(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("amastrianon", host, k, lod)
static func perches_amastrianon(k: float = 0.5) -> Array: return _meta("amastrianon", k, "perches")
static func climbs_amastrianon(k: float = 0.5) -> Array: return _meta("amastrianon", k, "climbs")

static func build_bovis(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("bovis", host, k, lod)
static func perches_bovis(k: float = 0.5) -> Array: return _meta("bovis", k, "perches")
static func climbs_bovis(k: float = 0.5) -> Array: return _meta("bovis", k, "climbs")

static func build_arkadius(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("arkadius", host, k, lod)
static func perches_arkadius(k: float = 0.5) -> Array: return _meta("arkadius", k, "perches")
static func climbs_arkadius(k: float = 0.5) -> Array: return _meta("arkadius", k, "climbs")

static func build_markianos(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("markianos", host, k, lod)
static func perches_markianos(k: float = 0.5) -> Array: return _meta("markianos", k, "perches")
static func climbs_markianos(k: float = 0.5) -> Array: return _meta("markianos", k, "climbs")

static func build_myrelaion(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("myrelaion", host, k, lod)
static func perches_myrelaion(k: float = 0.5) -> Array: return _meta("myrelaion", k, "perches")
static func climbs_myrelaion(k: float = 0.5) -> Array: return _meta("myrelaion", k, "climbs")

static func build_philadelphion(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("philadelphion", host, k, lod)
static func perches_philadelphion(k: float = 0.5) -> Array: return _meta("philadelphion", k, "perches")
static func climbs_philadelphion(k: float = 0.5) -> Array: return _meta("philadelphion", k, "climbs")

static func build_kapitolion(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("kapitolion", host, k, lod)
static func perches_kapitolion(k: float = 0.5) -> Array: return _meta("kapitolion", k, "perches")
static func climbs_kapitolion(k: float = 0.5) -> Array: return _meta("kapitolion", k, "climbs")

static func build_anemodoulion(host: Node3D, k: float = 0.5, lod: int = 0) -> void: _kur("anemodoulion", host, k, lod)
static func perches_anemodoulion(k: float = 0.5) -> Array: return _meta("anemodoulion", k, "perches")
static func climbs_anemodoulion(k: float = 0.5) -> Array: return _meta("anemodoulion", k, "climbs")


## Kimliğe göre kur (önizleme ve şehir kurucusu için).
static func build(id: String, host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_kur(id, host, k, lod)


static func perches(id: String, k: float = 0.5, opt := {}) -> Array: return _meta(id, k, "perches", opt)
static func climbs(id: String, k: float = 0.5, opt := {}) -> Array: return _meta(id, k, "climbs", opt)


static func _kur(id: String, host: Node3D, k: float, lod: int, opt := {}) -> Node3D:
	var n := Node3D.new()
	n.name = "Ist_" + id
	host.add_child(n)
	_dispatch(id, n, k, lod, opt)
	return n


static func _dispatch(id: String, n: Node3D, k: float, lod: int, opt: Dictionary) -> void:
	n.set_meta("perches", [])
	n.set_meta("climbs", [])
	match id:
		"mese": _mese(n, k, lod, float(opt.get("uzunluk", 96.0)))
		"konstantin": _konstantin(n, k, lod)
		"tauri": _tauri(n, k, lod)
		"amastrianon": _amastrianon(n, k, lod)
		"bovis": _bovis(n, k, lod)
		"arkadius": _arkadius(n, k, lod)
		"markianos": _markianos(n, k, lod)
		"myrelaion": _myrelaion(n, k, lod)
		"philadelphion": _philadelphion(n, k, lod)
		"kapitolion": _kapitolion(n, k, lod)
		"anemodoulion": _anemodoulion(n, k, lod)


## konma/tırmanma verisi: lod 2 ile geçici kurup meta'yı okur (düğüm sahne ağacına girmez).
static func _meta(id: String, k: float, anahtar: String, opt := {}) -> Array:
	var n := Node3D.new()
	_dispatch(id, n, k, 2, opt)
	var r: Array = (n.get_meta(anahtar) as Array).duplicate()
	n.free()
	return r


static func _perch(n: Node3D, p: Vector3) -> void:
	(n.get_meta("perches") as Array).append(p)


static func _climb(n: Node3D, a: Vector3, b: Vector3, tip := "merdiven") -> void:
	(n.get_meta("climbs") as Array).append([a, b, tip])


static func _zemin_serpinti(n: Node3D, rng: RandomNumberGenerator, rx: float, rz: float, adet: int, lod: int) -> void:
	if lod > 0:
		return
	for i in adet:
		var a := rng.randf() * TAU
		var d := rng.randf_range(0.55, 1.0)
		Y.ot(n, Vector3(cos(a) * rx * d, 0.1, sin(a) * rz * d), rng.randf_range(0.3, 0.7), rng)


# ---------------------------------------------------------------------------------------------------------
# MESE: revaklı cadde dilimi (uzunluk z boyunca). Sol/sağ revak + dükkân sırası; yer yer yıkık.
# ---------------------------------------------------------------------------------------------------------
static func _mese(n: Node3D, k: float, lod: int, uzunluk: float) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	var rw := maxf(11.0 * k, 9.0) * 0.5          # yol yarı genişliği (araba + yaya)
	var pd := maxf(4.5 * k, 3.2)                  # revak derinliği
	var sd := maxf(4.0 * k, 3.2)                  # dükkân derinliği
	var sp := maxf(5.0 * k, 3.6)                  # sütun aralığı
	var ph := maxf(5.0 * k, 3.4)                  # revak serbest yüksekliği
	var wh := ph + maxf(2.4 * k, 1.8)             # dükkân sırası duvar yüksekliği
	var cr := 0.42                                # sütun yarıçapı
	var nb := maxi(2, int(uzunluk / sp))
	var len := nb * sp
	# Yol: büyük kesme taş döşeme; kenarda çim ve ot
	Y.box(n, Vector3(rw * 2.0, 0.1, len), Vector3(0, 0.05, 0), Y.TAS, "flagstone", col)
	var half_w := rw + pd + sd
	if lod == 2:
		for s: int in [-1, 1]:
			Y.box(n, Vector3(pd + sd, wh, len), Vector3(s * (rw + (pd + sd) * 0.5), wh * 0.5, 0), Y.TAS, "", false)
			Y.box(n, Vector3(pd + sd + 0.6, 0.8, len), Vector3(s * (rw + (pd + sd) * 0.5), wh + 0.4, 0), Y.KIREMIT, "", false)
		_perch(n, Vector3(rw + pd + sd * 0.5, wh + 0.9, len * 0.5 - 2.0))
		return
	# Ruins: sütun ayakta mı?
	var alive := {}
	for s: int in [-1, 1]:
		for j in nb + 1:
			var ok := rng.randf() > 0.2 or j == 0 or j == nb
			alive[Vector2i(s, j)] = ok
	for s: int in [-1, 1]:
		var xr := s * rw                             # yol kenarı
		var xs := s * (rw + pd)                      # revak içi duvar (dükkân önü)
		# revak zemini (yoldan 0,28 yüksek, tek basamak)
		Y.box(n, Vector3(pd, 0.28, len), Vector3(s * (rw + pd * 0.5), 0.14, 0), Y.TAS_K, "flagstone", col)
		# dükkân sırası gövdesi (kesme taş + tuğla bant)
		Y.box(n, Vector3(sd, wh, len), Vector3(s * (rw + pd + sd * 0.5), wh * 0.5, 0), Y.TAS, "ashlar", col)
		# dükkân sırası çatısı (beşik, sırt z boyunca): gövdenin üstünde
		Y.roof(n, sd + 0.9, len + 0.6, wh, 1.4, Vector2(s * (rw + pd + sd * 0.5), 0), Y.KIREMIT, col)
		# revak çatısı: dükkân duvarından yola doğru hafif eğimli kiremitli plaka
		var rise := 0.8
		var slope := rad_to_deg(atan2(rise, pd))
		var roof_len := len
		var rc := Vector3(s * (rw + pd * 0.5), ph + 0.2 + rise * 0.5, 0)
		var slab := Props.solid(n, Vector3(pd / cos(deg_to_rad(slope)) + 0.1, 0.35, roof_len), rc, Y.KIREMIT, Vector3(0, 0, s * slope))
		if not col:
			slab.queue_free()
			Y.box(n, Vector3(pd, 0.35, roof_len), rc, Y.KIREMIT, "tiles", false, Vector3(0, 0, s * slope))
		else:
			Props.set_pattern(slab, Y.KIREMIT.lerp(Color.WHITE, 0.4), "tiles")
		# yola bakan kiriş (mimari) üzeri; ayrıca yan yüzeyi kapatan dolgu duvar ph..ph+rise (revak çatısı altı)
		Y.box(n, Vector3(0.4, rise + 0.35, len), Vector3(s * (rw + pd - 0.2), ph + (rise + 0.35) * 0.5 - 0.05, 0), Y.TAS, "ashlar", col)
		# sütunlar
		var cx := s * (rw + 0.5)
		for j in nb + 1:
			var z := -len * 0.5 + j * sp
			if alive[Vector2i(s, j)]:
				Y.cyl(n, cr, ph - 0.5, Vector3(cx, 0.28 + (ph - 0.5) * 0.5, z), Y.MERMER, cr * 0.9, 10, col, "marble")
				Y.box(n, Vector3(cr * 2.6, 0.3, cr * 2.6), Vector3(cx, 0.28 + ph - 0.5 + 0.15, z), Y.MERMER, "", col)
				Y.box(n, Vector3(cr * 2.2, 0.18, cr * 2.2), Vector3(cx, 0.28 + 0.09, z), Y.MERMER, "", col)
			else:
				# yıkık sütun: kütük ve moloz
				var sh := rng.randf_range(0.7, 1.9)
				Y.cyl(n, cr, sh, Vector3(cx, 0.28 + sh * 0.5, z), Y.MERMER, cr * 0.95, 8, col, "marble")
				Y.moloz(n, Vector3(cx + s * 0.4, 0.28, z + rng.randf_range(-1.0, 1.0)), 1.6, 1.4, 2, rng, col)
		# mimari kiriş (sütun başlığı üzeri): iki ucu da ayakta olan açıklıklar
		for j in nb:
			if alive[Vector2i(s, j)] and alive[Vector2i(s, j + 1)]:
				var zc := -len * 0.5 + (j + 0.5) * sp
				Y.box(n, Vector3(0.7, 0.5, sp - 0.1), Vector3(cx, 0.28 + ph - 0.5 + 0.55, zc), Y.TAS, "", col)
		# dükkân kapıları, pencereler, tente: revak içindeki cephede
		if lod == 0:
			var xf_front := s * (rw + pd) - s * 0.03
			for j in nb:
				var zc2 := -len * 0.5 + (j + 0.5) * sp
				var dh := 2.3
				Y.box(n, Vector3(0.1, dh, 1.5), Vector3(xf_front, 0.28 + dh * 0.5, zc2), Color("3e2a1c"), "wood", false)
				Y.box(n, Vector3(0.12, 0.3, 1.9), Vector3(xf_front, 0.28 + dh + 0.15, zc2), Y.MERMER, "", false)
				if rng.randf() < 0.65:
					# kepenk/tezgâh
					Y.box(n, Vector3(0.6, 1.0, 1.4), Vector3(xf_front - s * 0.5, 0.28 + 0.5, zc2 + 0.0), Y.AHSAP, "wood", col)
					# tente
					Y.box(n, Vector3(0.9, 0.06, 2.6), Vector3(xf_front - s * 0.5, 0.28 + 2.55, zc2), [Color("b8452f"), Color("e0b24a"), Color("3f6f8c")][rng.randi() % 3], "", false, Vector3(0, 0, s * 12))
				# üst pencere sırası: sıva üzerinde
				Y.box(n, Vector3(0.1, 0.9, 0.8), Vector3(s * (rw + pd) - s * 0.03, ph + 0.8, zc2), Color("1e1a18"), "", false)
	# yol ortasında anıt kaideleri (devşirme heykel postamentleri) ve su teknesi
	if lod == 0:
		var zc3 := -len * 0.5 + sp * 2.0
		while zc3 < len * 0.5 - 6.0:
			Y.box(n, Vector3(1.4, 1.2, 1.4), Vector3(0, 0.1 + 0.6, zc3), Y.MERMER, "marble", col)
			Y.box(n, Vector3(1.8, 0.18, 1.8), Vector3(0, 0.1 + 1.29, zc3), Y.TAS_K, "", col)
			zc3 += maxf(28.0 * k, 12.0)
		for j in 3:
			var wz := rng.randf_range(-len * 0.4, len * 0.4)
			Y.box(n, Vector3(0.9, 0.9, 0.9), Vector3(rng.randf_range(-rw * 0.5, rw * 0.5), 0.55, wz), Y.AHSAP, "wood", col)   # sandık
	_zemin_serpinti(n, rng, rw + pd, len * 0.5, 14, lod)
	# dış merdiven: kuzey ucundan sol revak çatısına, güney ucundan sağ dükkân sırasına (revak çatısı üstü)
	var top_y := ph + 0.2 + 0.8 + 0.2
	var s0 := Vector3(-(rw + pd * 0.5), 0.0, -len * 0.5 - 0.15)
	var nn := Y.stairs(n, s0 + Vector3(0, 0, -(ceili(top_y / Y.ADIM_H) * Y.ADIM_D)), Vector3(0, 0, 1), top_y - 0.05, 1.8, Y.TAS, col)
	_climb(n, s0 + Vector3(0, 0.02, -(nn * Y.ADIM_D) + 0.4), Vector3(-(rw + pd * 0.5), top_y - 0.1, -len * 0.5 + 1.2))
	var s1 := Vector3(rw + pd * 0.5, 0.0, len * 0.5 + 0.15)
	var nn2 := Y.stairs(n, s1 + Vector3(0, 0, ceili(top_y / Y.ADIM_H) * Y.ADIM_D), Vector3(0, 0, -1), top_y - 0.05, 1.8, Y.TAS, col)
	_climb(n, s1 + Vector3(0, 0.02, nn2 * Y.ADIM_D - 0.4), Vector3(rw + pd * 0.5, top_y - 0.1, len * 0.5 - 1.2))
	_perch(n, Vector3(-(rw + pd + sd * 0.5), wh + 1.1, 0))
	_perch(n, Vector3(rw + pd + sd * 0.5, wh + 1.1, len * 0.25))
	# kırık sütun üstlerinden "yıkık duvar basamakları"
	_climb(n, Vector3(rw + 0.5, 0.0, 0), Vector3(rw + 0.5, 0.28 + 0.1, 0), "basamak")
	var _hw := half_w


# ---------------------------------------------------------------------------------------------------------
# KONSTANTİN FORUMU: oval meydan, porfir sütun (demir çemberli, tepede haç), iki kemerli kapı kalıntısı
# ---------------------------------------------------------------------------------------------------------
static func _konstantin(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 330
	var a := 75.0 * k
	var b := 52.0 * k
	Y.disk(n, a, b, 0.1, Vector3(0, 0.05, 0), Y.TAS, 56 if lod < 2 else 24, col, "flagstone" if lod < 2 else "")
	if lod >= 1:
		pass
	var o := {"kaide_w": 7.0, "kaide_h": 6.5, "govde_r": 1.6, "govde_h": 27.0, "tambur": 8, "renk": Y.PORFIR, "cember": true,
		"baslik": "hac", "kaide_renk": Y.MERMER, "merdiven_yon": Vector3(0, 0, 1)}
	var r := Y.sutun(n, Vector3.ZERO, k, o, lod)
	_perch(n, Vector3(0, float(r["ust"]) - 2.2, 0))
	_climb(n, r["merdiven_alt"], r["merdiven_ust"])
	# iki kapı: batıda sağlam, doğuda yıkık
	var ac := maxf(6.0 * k, 3.6)
	var yay := maxf(6.0 * k, 3.4)
	var ust := yay + ac * 0.5 + 1.8
	for sd: int in [-1, 1]:
		var g := Node3D.new()
		g.position = Vector3(sd * (a + 3.0), 0.0, 0.0)
		g.rotation_degrees = Vector3(0, 90, 0)
		n.add_child(g)
		Y.kapi_kemeri(g, Vector3.ZERO, ac, yay, ust, maxf(4.0 * k, 3.0), maxf(3.0 * k, 2.2), Y.TAS, 1 if sd == 1 else 0, col)
		if sd == -1:
			_perch(n, Vector3(sd * (a + 3.0), ust + 0.55, 0))
	_climb(n, Vector3(a + 3.0, 0.0, maxf(3.0 * k, 2.2) + ac * 0.5 + 1.5), Vector3(a + 3.0, 0.8, ac * 0.5 + maxf(3.0 * k, 2.2) * 0.5), "basamak")
	if lod == 2:
		return
	# çevre revak kalıntısı: elips boyunca sütun kütükleri ve kırık sütunlar
	var cnt := 16
	for i in cnt:
		var t := TAU * (i + 0.5) / cnt
		if absf(cos(t)) > 0.93:
			continue
		var p := Vector3(cos(t) * (a - 1.5), 0.0, sin(t) * (b - 1.5))
		var hgt := rng.randf_range(1.0, 4.2)
		Y.cyl(n, 0.5, hgt, p + Vector3(0, hgt * 0.5 + 0.2, 0), Y.MERMER, 0.46, 8, col, "marble")
		Y.box(n, Vector3(1.4, 0.2, 1.4), p + Vector3(0, 0.1, 0), Y.TAS_K, "", col)
		if lod == 0:
			Y.moloz(n, p + Vector3(rng.randf_range(-1.5, 1.5), 0, 1.8), 1.8, 1.4, 2, rng, col)
	_zemin_serpinti(n, rng, a, b, 40, lod)
	# devşirme mermer bloklar
	if lod == 0:
		for i in 6:
			var ang := rng.randf() * TAU
			Y.box(n, Vector3(rng.randf_range(1.2, 2.4), 0.5, rng.randf_range(0.8, 1.4)), Vector3(cos(ang) * a * 0.55, 0.35, sin(ang) * b * 0.55), Y.MERMER, "marble", col, Vector3(0, rng.randf() * 180, 0))


# ---------------------------------------------------------------------------------------------------------
# TAURİ (Theodosius) FORUMU: zafer takı kalıntısı (gözyaşı sütunlu), Theodosius Sütunu (sarmal kabartmalı)
# ---------------------------------------------------------------------------------------------------------
static func _tauri(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 386
	var wx := 60.0 * k
	var wz := 45.0 * k
	Y.box(n, Vector3(wx * 2.0, 0.1, wz * 2.0), Vector3(0, 0.05, 0), Y.TAS, "flagstone" if lod < 2 else "", col)
	# Theodosius Sütunu (ortada, doğuya kayık)
	var o := {"kaide_w": 8.0, "kaide_h": 8.0, "govde_r": 1.5, "govde_h": 30.0, "tambur": 10, "renk": Y.MERMER,
		"baslik": "duz", "desen": "spiral", "sarim": 8, "kaide_renk": Y.MERMER, "merdiven_yon": Vector3(0, 0, 1)}
	var r := Y.sutun(n, Vector3(wx * 0.3, 0, 0), k, o, lod)
	_perch(n, Vector3(wx * 0.3, float(r["ust"]), 0))
	_climb(n, r["merdiven_alt"], r["merdiven_ust"])
	# zafer takı (batı ucu): üç gözlü; ortada yüksek, yanlarda alçak; sağ yarı yıkık
	var g := Node3D.new()
	g.position = Vector3(-wx * 0.95, 0, 0)
	g.rotation_degrees = Vector3(0, 90, 0)
	n.add_child(g)
	var ac := maxf(8.0 * k, 3.6)
	var yay := maxf(8.0 * k, 3.4)
	var ust := yay + ac * 0.5 + maxf(3.0 * k, 2.0)
	var ayw := maxf(3.4 * k, 2.4)
	Y.kapi_kemeri(g, Vector3.ZERO, ac, yay, ust, maxf(5.0 * k, 3.0), ayw, Y.TAS, -1, col)
	_perch(n, Vector3(-wx * 0.95, ust + 0.5, 0))
	# yan kapılar: alçak, ortaya bitişik değil (aradaki boşluk 0 ya da ≥ 1,4 m): 2,4 m aralıklı dış kemerler
	var yan := ac * 0.5 + ayw + ayw * 0.0 + 3.2
	Y.kapi_kemeri(g, Vector3(yan + ac * 0.25, 0, 0), maxf(ac * 0.5, 3.0), yay * 0.9, yay * 0.9 + maxf(ac * 0.5, 3.0) * 0.5 + 1.0, maxf(5.0 * k, 3.0), ayw * 0.8, Y.TAS, 0, col)
	# gözyaşı sütunları (iki adet), takın önünde; biri yarıda kırık
	var po := {"kaide_w": 3.0, "kaide_h": 3.0, "govde_r": 0.9, "govde_h": 13.0, "tambur": 4, "renk": Y.GRANIT,
		"baslik": "korint", "desen": "gozyasi", "kaide_renk": Y.MERMER, "merdiven": false}
	Y.sutun(n, Vector3(-wx * 0.95 + 5.0 * 0 + 0, 0, -(ac * 0.5 + ayw + 4.5)), k, po, lod)
	var po2 := po.duplicate()
	po2["govde_h"] = 6.5
	po2["baslik"] = "yok"
	Y.sutun(n, Vector3(-wx * 0.95, 0, (ac * 0.5 + ayw + 4.5)), k, po2, lod)
	_climb(n, Vector3(-wx * 0.95 - ayw - 4.0, 0.0, -ac * 0.5 - 1.0), Vector3(-wx * 0.95 - ayw, 0.8, -ac * 0.5 - 1.0), "basamak")
	if lod == 2:
		return
	for i in 10:
		var p := Vector3(rng.randf_range(-wx, wx), 0, rng.randf_range(-wz, wz))
		if absf(p.x - wx * 0.3) < 6.0 or p.x < -wx * 0.7:
			continue
		Y.box(n, Vector3(rng.randf_range(0.8, 1.8), 0.4, rng.randf_range(0.6, 1.2)), p + Vector3(0, 0.3, 0), Y.MERMER, "marble", col, Vector3(0, rng.randf() * 180, 0))
	_zemin_serpinti(n, rng, wx, wz, 28, lod)


# ---------------------------------------------------------------------------------------------------------
# AMASTRİANON: pazar meydanı (KESTİRİM yerleşimi): sekizgen havuz, çınarlar, tezgâhlar, yıkık revak köşesi
# ---------------------------------------------------------------------------------------------------------
static func _amastrianon(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 500
	var wx := 26.0 * k + 8.0
	var wz := 21.0 * k + 8.0
	Y.box(n, Vector3(wx * 2.0, 0.12, wz * 2.0), Vector3(0, 0.06, 0), Y.TAS, "cobble" if lod < 2 else "", col)
	# sekizgen havuz (phiale): dört sütunlu, konik çatılı
	Y.cyl(n, 2.4, 0.9, Vector3(0, 0.12 + 0.45, 0), Y.MERMER, 2.3, 8, col, "marble")
	if lod < 2:
		Y.cyl(n, 2.0, 0.08, Vector3(0, 0.12 + 0.86, 0), Color("3d7a96"), -1.0, 8, false)
		for i in 4:
			var t := TAU * i / 4.0 + PI / 4
			Y.cyl(n, 0.22, 3.4, Vector3(cos(t) * 1.7, 0.12 + 0.9 + 1.7, sin(t) * 1.7), Y.MERMER, 0.2, 8, col)
		Props.cyl(n, 2.5, 1.0, Vector3(0, 0.12 + 0.9 + 3.4 + 0.5, 0), Y.KURSUN, Vector3.ZERO, 8, 0.1)
	_perch(n, Vector3(0, 0.12 + 0.9 + 3.4 + 0.3, 0))
	# çınarlar
	for p in [Vector3(-wx * 0.6, 0, -wz * 0.5), Vector3(wx * 0.62, 0, wz * 0.45), Vector3(-wx * 0.55, 0, wz * 0.55), Vector3(wx * 0.5, 0, -wz * 0.6)]:
		Y.cyl(n, 0.4, 3.0, p + Vector3(0, 1.5, 0), Y.AHSAP, 0.32, 6, col)
		Y.ball(n, 3.2, p + Vector3(0, 5.2, 0), Y.OT, Vector3(1.0, 0.8, 1.0), 8)
		Y.ball(n, 2.2, p + Vector3(1.6, 4.4, 0.9), Y.OT_K, Vector3(1.0, 0.8, 1.0), 6)
	# yıkık revak köşesi (kuzey ve doğu kenar): 4 sütun ve kiriş
	var d := 0
	for j in 5:
		var z := -wz + 2.0 + j * (wz * 2.0 - 4.0) / 4.0
		if j == 2:
			Y.moloz(n, Vector3(wx - 2.0, 0.12, z), 2.2, 1.8, 2, rng, col)
			continue
		Y.cyl(n, 0.4, 3.6, Vector3(wx - 2.0, 0.12 + 1.8, z), Y.MERMER, 0.36, 8, col, "marble")
		d += 1
	Y.box(n, Vector3(0.6, 0.45, wz * 0.7), Vector3(wx - 2.0, 0.12 + 3.85, -wz * 0.55), Y.TAS, "", col)
	Y.box(n, Vector3(3.2, 0.3, wz * 0.7), Vector3(wx - 0.4, 0.12 + 4.2, -wz * 0.55), Y.KIREMIT, "tiles", col)
	if lod == 0:
		# tezgâhlar ve sepetler
		for i in 7:
			var p2 := Vector3(rng.randf_range(-wx * 0.8, wx * 0.5), 0, rng.randf_range(-wz * 0.8, wz * 0.8))
			if p2.length() < 5.0:
				continue
			Y.box(n, Vector3(2.0, 0.9, 0.9), p2 + Vector3(0, 0.12 + 0.45, 0), Y.AHSAP, "wood", col, Vector3(0, rng.randf() * 90, 0))
			Y.box(n, Vector3(2.4, 0.06, 1.6), p2 + Vector3(0, 0.12 + 2.5, 0), [Color("b8452f"), Color("e0b24a"), Color("3f6f8c")][i % 3], "", false)
			for st in [-1, 1]:
				Y.cyl(n, 0.04, 2.5, p2 + Vector3(st * 1.1, 0.12 + 1.25, 0.7), Y.AHSAP, -1.0, 5, false)
	_climb(n, Vector3(wx - 6.0, 0.12, -wz * 0.55 - 1.0), Vector3(wx - 2.0, 0.12 + 0.5, -wz * 0.55 + 0.0), "basamak")


# ---------------------------------------------------------------------------------------------------------
# FORUM BOVİS: meydan, kaide üstünde bronz boğa (KESTİRİM: 1453'te yerinde olup olmadığı belirsiz), yıkık dükkân sırası
# ---------------------------------------------------------------------------------------------------------
static func _bovis(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 51
	var wx := 30.0 * k + 8.0
	var wz := 25.0 * k + 8.0
	Y.box(n, Vector3(wx * 2.0, 0.12, wz * 2.0), Vector3(0, 0.06, 0), Y.TAS_K, "flagstone" if lod < 2 else "", col)
	# kaide: üç basamak + mermer blok
	for i in 3:
		var w := 6.0 - i * 0.7
		Y.box(n, Vector3(w, 0.28 * (i + 1), w), Vector3(0, 0.12 + 0.28 * (i + 1) * 0.5, 0), Y.TAS_K, "ashlar", col)
	var ph := 0.12 + 0.84
	Y.box(n, Vector3(3.6, 1.4, 6.0), Vector3(0, ph + 0.7, 0), Y.MERMER, "marble", col)
	Y.box(n, Vector3(4.0, 0.2, 6.4), Vector3(0, ph + 1.5, 0), Y.TAS_K, "", col)
	var by := ph + 1.6
	# bronz boğa (yaklaşık): gövde, kafa, boynuz, bacaklar
	var bz := Vector3(0, by, 0)
	Y.box(n, Vector3(1.5, 1.5, 3.2), bz + Vector3(0, 1.45, 0), Y.BRONZ, "", col)
	Y.ball(n, 0.95, bz + Vector3(0, 1.75, -0.9), Y.BRONZ, Vector3(0.95, 0.9, 1.35), 8)
	Y.ball(n, 0.75, bz + Vector3(0, 1.95, 1.75), Y.BRONZ, Vector3(0.8, 0.8, 0.95), 8)
	Y.box(n, Vector3(0.9, 0.7, 0.9), bz + Vector3(0, 1.85, 2.2), Y.BRONZ, "", false)
	for sd: int in [-1, 1]:
		Y.cyl(n, 0.06, 0.8, bz + Vector3(sd * 0.55, 2.3, 2.1), Y.MERMER, 0.02, 5, false, "")
		Y.cyl(n, 0.2, 1.0, bz + Vector3(sd * 0.5, 0.5, -1.1), Y.BRONZ, 0.17, 6, col)
		Y.cyl(n, 0.2, 1.0, bz + Vector3(sd * 0.5, 0.5, 1.1), Y.BRONZ, 0.17, 6, col)
	_perch(n, bz + Vector3(0, 2.5, 0))
	var ust := ph + 1.6
	# kaideye tırmanma: dört yandan merdiven
	var nn := Y.stairs(n, Vector3(0, 0, 3.2 + ceili((ph + 1.5) / Y.ADIM_H) * Y.ADIM_D), Vector3(0, 0, -1), ph + 1.5, 1.8, Y.TAS, col)
	_climb(n, Vector3(0, 0.02, 3.2 + nn * Y.ADIM_D + 0.6), Vector3(0, ph + 1.52, 2.5))
	if lod == 2:
		return
	# yıkık dükkân sırası (kuzey kenar): tonozlu odalar duvarı, kırık
	var wl := wx * 1.6
	Y.box(n, Vector3(wl, 3.2, 3.0), Vector3(0, 0.12 + 1.6, -wz + 1.6), Y.TAS, "ashlar", col)
	Y.box(n, Vector3(wl, 0.5, 4.0), Vector3(0, 0.12 + 3.45, -wz + 1.6), Y.KIREMIT, "tiles", col)
	if lod == 0:
		for i in 6:
			var x := -wl * 0.45 + i * wl * 0.18
			Y.box(n, Vector3(1.4, 2.2, 0.1), Vector3(x, 0.12 + 1.1, -wz + 3.07), Color("3e2a1c"), "wood", false)
	_zemin_serpinti(n, rng, wx, wz, 20, lod)
	_climb(n, Vector3(0, 0.12, -wz + 5.0), Vector3(0, 0.12 + 3.45 + 0.25 - 0.1, -wz + 2.0), "basamak")


# ---------------------------------------------------------------------------------------------------------
# ARKADİUS SÜTUNU: Xerolophos tepesi, ~50 m, sarmal kabartma, kaidede iç merdiven kapısı, tepe heykeli düşmüş
# ---------------------------------------------------------------------------------------------------------
static func _arkadius(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 421
	Y.box(n, Vector3(24.0 * k + 8.0, 0.14, 24.0 * k + 8.0), Vector3(0, 0.07, 0), Y.TAS_K, "flagstone" if lod < 2 else "", col)
	var o := {"kaide_w": 10.0, "kaide_h": 9.0, "govde_r": 1.9, "govde_h": 38.0, "tambur": 12, "renk": Y.MERMER,
		"baslik": "duz", "desen": "spiral", "sarim": 14, "kaide_renk": Y.MERMER, "merdiven_yon": Vector3(0, 0, 1)}
	var p0 := Vector3(0, 0.14, 0)
	var r := Y.sutun(n, p0, k, o, lod)
	_perch(n, Vector3(0, float(r["ust"]) + 0.14, 0))
	_climb(n, r["merdiven_alt"], r["merdiven_ust"])
	var kw := maxf(10.0 * k, 3.0)
	# kaide kabartmaları + iç merdiven kapısı (görsel), arka yüz de aynı özenle
	if lod == 0:
		for sd: int in [-1, 1]:
			Y.box(n, Vector3(0.12, 1.0, kw * 0.6), Vector3(sd * (kw * 0.5 + 0.03), 0.14 + 3.0 * k + 1.0, 0), Y.TAS_K, "", false)
			Y.box(n, Vector3(kw * 0.6, 1.0, 0.12), Vector3(0, 0.14 + 3.0 * k + 1.0, -sd * (kw * 0.5 + 0.03)), Y.TAS_K, "", false)
		Y.box(n, Vector3(1.1, 2.1, 0.1), Vector3(0, 0.14 + 1.05 + 1.0, -kw * 0.5 - 0.04), Color("1e1a18"), "", false)
		for i in 3:
			Y.ot(n, Vector3(rng.randf_range(-4, 4), 0.14, rng.randf_range(-4, 4)), rng.randf_range(0.4, 0.8), rng)
	# düşmüş heykel parçaları (kaidenin dibinde): başsız gövde ve blok
	if lod == 0:
		Y.box(n, Vector3(1.4, 0.9, 2.4), Vector3(kw * 0.5 + 3.5, 0.14 + 0.45, -kw * 0.3), Y.MERMER, "marble", col, Vector3(0, 25, 8))
		Y.moloz(n, Vector3(kw * 0.5 + 3.0, 0.14, kw * 0.3), 2.4, 2.0, 2, rng, col)
		_climb(n, Vector3(kw * 0.5 + 6.0, 0.14, kw * 0.3), Vector3(kw * 0.5 + 3.0, 0.7, kw * 0.3), "basamak")


# ---------------------------------------------------------------------------------------------------------
# MARKİANOS SÜTUNU (Kız Taşı): gri granit tek parça gövde, Korint başlığı, kaidede Nike madalyonları, tepede kartallar
# ---------------------------------------------------------------------------------------------------------
static func _markianos(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 450
	Y.box(n, Vector3(16.0, 0.1, 16.0), Vector3(0, 0.05, 0), Y.TAS, "flagstone" if lod < 2 else "", col)
	var o := {"kaide_w": 3.6, "kaide_h": 3.4, "govde_r": 0.62, "govde_h": 10.0, "tambur": 1, "renk": Y.GRANIT,
		"baslik": "korint", "kaide_renk": Y.MERMER, "merdiven_yon": Vector3(0, 0, 1)}
	# bu anıt küçük: k'den bağımsız (gerçek ölçü), sütun gövdesi k ile %100 – ama tırmanış için kaide kk=1
	var kk := maxf(k, 0.6)
	var p0 := Vector3(0, 0.1, 0)
	var r := Y.sutun(n, p0, kk, o, lod)
	var kw := maxf(3.6 * kk, 3.0)
	var kh := maxf(3.4 * kk, 1.4)
	_perch(n, Vector3(0, float(r["ust"]) + 0.1, 0))
	_climb(n, r["merdiven_alt"], r["merdiven_ust"])
	if lod == 0:
		# Nike madalyonları (dört yüz) – iki tur kabartma çember
		for sd: int in [-1, 1]:
			Y.cyl(n, 0.55, 0.06, Vector3(sd * (kw * 0.5 + 0.03), 0.1 + kh * 0.55, 0), Y.BRONZ, -1.0, 12, false)
			(Props.cyl(n, 0.4, 0.08, Vector3(sd * (kw * 0.5 + 0.05), 0.1 + kh * 0.55, 0), Y.TAS_K, Vector3.ZERO, 10) as Node3D).rotation_degrees = Vector3(0, 0, 90)
		# kaide yüzlerindeki madalyon düzeltmesi: yatık disk (x'e dik)
		for c in n.get_children():
			if c is MeshInstance3D and (c as MeshInstance3D).mesh is CylinderMesh and (c as MeshInstance3D).mesh.get_aabb().size.y < 0.1:
				(c as MeshInstance3D).rotation_degrees = Vector3(0, 0, 90)
		# başlık tepesinde dört kartal (abakus köşeleri)
		var ty := float(r["ust"]) + 0.1
		for sx: int in [-1, 1]:
			for sz: int in [-1, 1]:
				var gr := 0.62 * kk
				Y.box(n, Vector3(0.4, 0.5, 0.3), Vector3(sx * gr * 1.4, ty + 0.25, sz * gr * 1.4), Y.MERMER, "", false)
				Y.ball(n, 0.12, Vector3(sx * gr * 1.4, ty + 0.62, sz * gr * 1.4), Y.MERMER, Vector3.ONE, 5)
		# çevreye iki taş sıra (kapı önü): oturak
		Y.box(n, Vector3(2.4, 0.5, 0.6), Vector3(5.0, 0.35, 0), Y.TAS_K, "ashlar", col)
		Y.box(n, Vector3(2.4, 0.5, 0.6), Vector3(-5.0, 0.35, 0), Y.TAS_K, "ashlar", col)
		_zemin_serpinti(n, rng, 7.0, 7.0, 10, lod)


# ---------------------------------------------------------------------------------------------------------
# MYRELAION (Bodrum) kilisesi ve rotundası: yuvarlak alt yapı üstünde haç-planlı, üç apsisli tuğla-taş kilise
# ---------------------------------------------------------------------------------------------------------
static func _myrelaion(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 920
	var rr := maxf(12.0 * k, 5.5)                 # rotunda yarıçapı (KESTİRİM ~12 m)
	var rh := maxf(7.0 * k, 3.4)                  # alt yapı yüksekliği
	var cw := rr * 1.25                           # kilise kenarı (kare)
	var wh := maxf(8.0 * k, 4.0)                  # kilise duvar yüksekliği
	Y.box(n, Vector3(rr * 2 + 14, 0.1, rr * 2 + 14), Vector3(0, 0.05, 0), Y.TAS_K, "flagstone" if lod < 2 else "", col)
	# rotunda alt yapı (tuğla-taş bantlı), tam kabuk çarpışma
	var rot := Props.cyl(n, rr, rh, Vector3(0, 0.1 + rh * 0.5, 0), Y.TUGLA, Vector3.ZERO, 20 if lod < 2 else 12)
	rot.material_override = Props.mat(Y.TUGLA.lerp(Color.WHITE, 0.5), 0.0, false, "ashlar")
	if col:
		Props.make_solid(rot, 1.0)
	var ty := 0.1 + rh
	# teras
	Y.box(n, Vector3(cw + 2.0, 0.3, cw + 2.0), Vector3(0, ty + 0.15, 0), Y.TAS, "flagstone", col)
	ty += 0.3
	# kilise gövdesi: kare gövde, opus mixtum
	Y.box(n, Vector3(cw, wh, cw), Vector3(0, ty + wh * 0.5, 0), Y.TUGLA, "ashlar", col)
	Y.box(n, Vector3(cw + 0.5, 0.4, cw + 0.5), Vector3(0, ty + wh + 0.2, 0), Y.TAS_K, "", col)
	var cy := ty + wh + 0.4
	# haç kolları: kısa beşik tonozlar (görsel, yüksekliği ≤ 1,3)
	if lod < 2:
		for ax: int in [0, 1]:
			var v := Props.cyl(n, 1.5, cw * 0.98, Vector3(0, cy + 0.2, 0), Y.KURSUN, Vector3(90 if ax == 0 else 0, 0, 0 if ax == 0 else 90), 8)
			v.scale = Vector3(1.0, 1.0, 1.0)
			v.position = Vector3(0, cy + 0.0, 0)
	# yürünür çatı terası: kolların altındaki düz örtü (yüzey cy)
	Y.box(n, Vector3(cw - 0.4, 0.05, cw - 0.4), Vector3(0, cy + 0.025, 0), Y.KURSUN, "", col)
	# kubbe: sekizgen kasnak + pencere + kurşun kubbe + haç
	var dr := cw * 0.2
	var dh := maxf(wh * 0.45, 1.8)
	Y.cyl(n, dr, dh, Vector3(0, cy + dh * 0.5, 0), Y.TAS, -1.0, 8, col, "ashlar")
	if lod < 2:
		for i in 8:
			var t := TAU * i / 8.0 + PI / 8
			Y.box(n, Vector3(0.7, 1.2, 0.15), Vector3(cos(t) * (dr * 0.93), cy + dh * 0.5, sin(t) * (dr * 0.93)), Color("2a2622"), "", false, Vector3(0, -rad_to_deg(t) + 90, 0))
	Y.ball(n, dr, Vector3(0, cy + dh, 0), Y.KURSUN, Vector3(1.0, 0.7, 1.0), 12)
	Y.hac(n, Vector3(0, cy + dh + dr * 0.7, 0), 1.2)
	# üç apsis (doğu cephe): yarım silindir çıkıntılar
	for i in 3:
		var az := (i - 1) * cw * 0.3
		var ar := cw * 0.12 if i == 1 else cw * 0.09
		Y.cyl(n, ar, wh * (0.9 if i != 1 else 1.0), Vector3(cw * 0.5 + ar * 0.55, ty + wh * (0.45 if i != 1 else 0.5), az), Y.TUGLA, -1.0, 8, col, "ashlar")
		Props.cyl(n, ar * 1.05, 0.3, Vector3(cw * 0.5 + ar * 0.55, ty + wh * (0.9 if i != 1 else 1.0) + 0.1, az), Y.KIREMIT, Vector3.ZERO, 8, ar * 0.05)
	# narteks (batı)
	Y.box(n, Vector3(3.2, wh * 0.7, cw * 0.8), Vector3(-cw * 0.5 - 1.6, ty + wh * 0.35, 0), Y.TUGLA, "ashlar", col)
	Y.roof(n, 3.8, cw * 0.82, ty + wh * 0.7, 0.9, Vector2(-cw * 0.5 - 1.6, 0), Y.KIREMIT, col)
	if lod == 0:
		# narteks kapısı (kemerli), pencere sırası, alt yapıdaki kör nişler
		Y.box(n, Vector3(0.1, 2.3, 1.4), Vector3(-cw * 0.5 - 3.2 - 0.02, ty + 1.15, 0), Color("3e2a1c"), "wood", false)
		for sd: int in [-1, 1]:
			for j in 3:
				Y.box(n, Vector3(0.1, 1.3, 0.6), Vector3(-cw * 0.5 - 3.2 - 0.02, ty + 3.0, sd * (j + 1) * 1.4), Color("1e1a18"), "", false)
		for i in 10:
			var t2 := TAU * (i + 0.5) / 10.0
			Y.box(n, Vector3(0.1, rh * 0.55, 1.5), Vector3(cos(t2) * (rr + 0.02), 0.1 + rh * 0.5, sin(t2) * (rr + 0.02)), Color("3a2d24"), "", false, Vector3(0, -rad_to_deg(t2), 0))
		# kilise gövdesinde pencereler (dört cephe)
		for sd: int in [-1, 1]:
			for j in 3:
				Y.box(n, Vector3(0.1, 1.8, 0.8), Vector3(sd * (cw * 0.5 + 0.03), ty + wh * 0.62, (j - 1) * cw * 0.28), Color("1e1a18"), "", false)
				Y.box(n, Vector3(0.8, 1.8, 0.1), Vector3((j - 1) * cw * 0.28, ty + wh * 0.62, sd * (cw * 0.5 + 0.03)), Color("1e1a18"), "", false)
		Y.moloz(n, Vector3(rr + 1.5, 0.1, rr * 0.5), 2.4, 2.0, 2, rng, col)
	# dış merdiven: rotunda'nın güneyinden terasa (tam kabuğa dayanır)
	var hh := rh + 0.3
	var run := ceili(hh / Y.ADIM_H) * Y.ADIM_D
	var sx := -rr * 0.3
	var sz2 := sqrt(maxf(rr * rr - sx * sx, 1.0)) + run - 0.1
	var nn := Y.stairs(n, Vector3(sx, 0.1, sz2), Vector3(0, 0, -1), hh, 2.0, Y.TAS, col)
	# merdiven rotunda gövdesine ~ (0,0.1 yükseklik) bitişir; üst basamak terasa kadar gelmeli: teras kenar cw/2+1.0
	_climb(n, Vector3(sx, 0.12, sz2 + 0.6), Vector3(sx, ty + 0.02, sqrt(maxf(rr * rr - sx * sx, 1.0)) - 0.4))
	_perch(n, Vector3(0, cy + dh + dr * 0.7 + 1.0, 0))
	_perch(n, Vector3(cw * 0.3, cy + 0.05, cw * 0.3))
	var _unused := nn


# ---------------------------------------------------------------------------------------------------------
# PHİLADELPHİON: dört ayaklı tak (tetrapylon), dört yöne kemerli; üst tonoz kısmen yıkık
# ---------------------------------------------------------------------------------------------------------
static func _philadelphion(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 1204
	var span := maxf(9.0 * k, 4.2)               # ayaklar arası açıklık
	var pw := maxf(3.4 * k, 2.4)                 # ayak kalınlığı
	var ph := maxf(8.0 * k, 3.6)                 # kemer başlangıcı
	var tepe := ph + span * 0.5
	var ust := tepe + maxf(2.6 * k, 1.8)
	var half := span * 0.5 + pw * 0.5
	Y.box(n, Vector3(span + pw * 2 + 20, 0.12, span + pw * 2 + 20), Vector3(0, 0.06, 0), Y.TAS, "flagstone" if lod < 2 else "", col)
	# dört ayak
	for sx: int in [-1, 1]:
		for sz: int in [-1, 1]:
			Y.box(n, Vector3(pw, ph, pw), Vector3(sx * half, 0.12 + ph * 0.5, sz * half), Y.TAS, "ashlar", col)
			Y.box(n, Vector3(pw + 0.4, 0.3, pw + 0.4), Vector3(sx * half, 0.12 + ph + 0.15, sz * half), Y.TAS_K, "", col)
			Y.box(n, Vector3(pw + 0.5, 0.5, pw + 0.5), Vector3(sx * half, 0.12 + 0.25, sz * half), Y.TAS_K, "", col)
	# dört kemer: kuzey/güney (x boyunca) ve doğu/batı (z boyunca)
	var gap := 0
	for i in 4:
		var yaw := i * 90.0
		var g := Node3D.new()
		g.rotation_degrees = Vector3(0, yaw, 0)
		g.position = Vector3(0, 0.12, 0)
		n.add_child(g)
		var off := half
		# kemer taşları
		Y.kemer_taslar(g, Vector3(0, ph + 0.3, off), span * 0.5, 0.55, pw, Y.TAS_K, 13)
		# köşelikler + üst gövde (yıkık olan taraf: i == 1 ortası açık)
		var h2 := ust - (ph + 0.3)
		if i == 1:
			Y.box(g, Vector3(span * 0.5, h2 * 0.6, pw), Vector3(-span * 0.25, ph + 0.3 + h2 * 0.3, off), Y.TAS, "ashlar", col)
			Y.moloz(g, Vector3(span * 0.25, 0, off + 0.0), 2.4, pw, 2, rng, col)
			gap += 1
		else:
			Y.box(g, Vector3(span + 0.4, h2 - span * 0.5, pw), Vector3(0, ph + 0.3 + span * 0.5 + (h2 - span * 0.5) * 0.5, off), Y.TAS, "ashlar", col)
			for sd: int in [-1, 1]:
				Y.box(g, Vector3(span * 0.25, span * 0.5, pw), Vector3(sd * (span * 0.375 + 0.0), ph + 0.3 + span * 0.25, off), Y.TAS, "ashlar", col)
	# üst: korniş + yıkık tuğla kubbe halkası (yarım)
	Y.box(n, Vector3(span + pw * 2 + 0.6, 0.5, span + pw * 2 + 0.6), Vector3(0, 0.12 + ust + 0.25 + 0.0, 0), Y.TAS_K, "", col)
	var top := 0.12 + ust + 0.5
	Y.box(n, Vector3(span + pw * 2 - 0.4, 0.4, span + pw * 2 - 0.4), Vector3(0, top + 0.2, 0), Y.TUGLA, "brick", col)
	for i in 6:
		var t := PI * i / 5.0 + PI * 0.0
		Y.box(n, Vector3(0.9, 1.2 + (i % 2) * 0.4, 0.9), Vector3(cos(t) * span * 0.42, top + 0.4 + 0.6, sin(t) * span * 0.42), Y.TUGLA, "brick", col, Vector3(0, rad_to_deg(-t), 0))
	_perch(n, Vector3(0, top + 0.45, 0))
	# yer: dört kütük sütun ve çalı
	if lod < 2:
		for i in 4:
			var t2 := TAU * (i + 0.5) / 4.0
			var p := Vector3(cos(t2) * (half + pw + 5.0), 0.12, sin(t2) * (half + pw + 5.0))
			var hh2 := rng.randf_range(1.2, 3.0)
			Y.cyl(n, 0.42, hh2, p + Vector3(0, hh2 * 0.5, 0), Y.MERMER, 0.4, 8, col, "marble")
	_zemin_serpinti(n, rng, span, span, 12, lod)
	# tırmanış: çatıya yıkık moloz-basamak hattı + dış merdiven (güneybatı ayağı)
	var h3 := 0.12 + ph + 0.3
	var run := ceili(h3 / Y.ADIM_H) * Y.ADIM_D
	var st := Vector3(half + pw * 0.5 + run, 0.0, half)
	var nn := Y.stairs(n, st, Vector3(-1, 0, 0), h3, 1.8, Y.TAS, col)
	_climb(n, st + Vector3(0.6, 0.02, 0), Vector3(half + pw * 0.5 - 0.2, h3 + 0.02, half))
	var _g := gap + nn


# ---------------------------------------------------------------------------------------------------------
# KAPİTOLİON kalıntısı: yüksek podyum, kırık Korint sütunları, hücre duvarı, ön geniş merdiven
# ---------------------------------------------------------------------------------------------------------
static func _kapitolion(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 330
	var pw := 24.0 * k + 4.0
	var pl := 36.0 * k + 6.0
	var ph := maxf(5.0 * k, 2.2)
	Y.box(n, Vector3(pw + 16, 0.1, pl + 24), Vector3(0, 0.05, 0), Y.TOPRAK, "rubble" if lod < 2 else "", col)
	# podyum
	Y.box(n, Vector3(pw, ph, pl), Vector3(0, 0.1 + ph * 0.5, 0), Y.TAS, "ashlar", col)
	Y.box(n, Vector3(pw + 0.8, 0.4, pl + 0.8), Vector3(0, 0.1 + ph + 0.2, 0), Y.TAS_K, "", col)
	var top := 0.1 + ph + 0.4
	# ön (güney, +z) geniş merdiven
	var sw := minf(pw * 0.5, 8.0)
	var nn := Y.stairs(n, Vector3(0, 0.1, pl * 0.5 + 0.4 + ceili((top - 0.1) / Y.ADIM_H) * Y.ADIM_D), Vector3(0, 0, -1), top - 0.1, sw, Y.TAS, col)
	_climb(n, Vector3(0, 0.12, pl * 0.5 + 0.4 + nn * Y.ADIM_D + 0.6), Vector3(0, top + 0.02, pl * 0.5 - 0.2))
	if lod == 2:
		_perch(n, Vector3(0, top + 3.0, 0))
		return
	# ön sıra: altı sütun (bazıları kırık)
	var hs := [5.8, 6.4, 2.4, 6.4, 1.6, 5.8]
	for i in 6:
		var x := -pw * 0.38 + i * pw * 0.76 / 5.0
		var hh := minf(float(hs[i]) * maxf(k, 0.5) * 1.1, 8.0)
		Y.box(n, Vector3(1.6, 0.3, 1.6), Vector3(x, top + 0.15, pl * 0.5 - 2.6), Y.TAS_K, "", col)
		Y.cyl(n, 0.55, hh, Vector3(x, top + 0.3 + hh * 0.5, pl * 0.5 - 2.6), Y.MERMER, 0.5, 10, col, "marble")
		if hh > 5.0:
			var bh := Y.korint_baslik(n, 0.5, Vector3(x, top + 0.3 + hh, pl * 0.5 - 2.6), Y.MERMER, col, lod == 0)
	# kırık alınlık parçaları: yerde
	Y.box(n, Vector3(5.0, 0.9, 1.8), Vector3(-pw * 0.2, top + 0.45, pl * 0.5 - 6.0), Y.MERMER, "marble", col, Vector3(0, 18, 4))
	# hücre (cella) duvarları: arka ve yan, yıkık kenarlı; kemerli niş
	var cl := pl * 0.55
	Y.box(n, Vector3(1.5, minf(8.0, ph + 4.0), cl), Vector3(-pw * 0.4, top + minf(8.0, ph + 4.0) * 0.5, -pl * 0.2), Y.TUGLA, "ashlar", col)
	Y.box(n, Vector3(pw * 0.8, minf(8.0, ph + 4.0) * 0.8, 1.5), Vector3(0, top + minf(8.0, ph + 4.0) * 0.4, -pl * 0.5 + 1.5), Y.TUGLA, "ashlar", col)
	Y.box(n, Vector3(1.5, 3.2, cl * 0.6), Vector3(pw * 0.4, top + 1.6, -pl * 0.3), Y.TUGLA, "ashlar", col)
	for i in 3:
		Y.moloz(n, Vector3(pw * 0.1 + i * 3.0 - 3.0, top, -pl * 0.1 + rng.randf_range(-2, 2)), 3.0, 2.4, 2, rng, col)
	_zemin_serpinti(n, rng, pw * 0.6, pl * 0.6, 18, lod)
	_perch(n, Vector3(-pw * 0.4, top + minf(8.0, ph + 4.0) + 0.2, -pl * 0.2))
	_perch(n, Vector3(0, top + 0.02, 0))


# ---------------------------------------------------------------------------------------------------------
# ANEMODOULİON: dört yüzlü kesik piramit kule (bronz levhalı), tepesinde dönen bronz figür (KESTİRİM: harap, figür devrilmiş)
# ---------------------------------------------------------------------------------------------------------
static func _anemodoulion(n: Node3D, k: float, lod: int) -> void:
	var col := lod == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 33
	var bw := maxf(8.0 * k, 3.6)
	var th := 28.0 * k
	Y.box(n, Vector3(bw * 2.2 + 6, 0.1, bw * 2.2 + 6), Vector3(0, 0.05, 0), Y.TAS_K, "flagstone" if lod < 2 else "", col)
	# kaide: iki kademe
	Y.box(n, Vector3(bw * 1.7, 0.28, bw * 1.7), Vector3(0, 0.1 + 0.14, 0), Y.TAS_K, "ashlar", col)
	Y.box(n, Vector3(bw * 1.45, 0.56, bw * 1.45), Vector3(0, 0.1 + 0.28 + 0.28, 0), Y.TAS_K, "ashlar", col)
	var y0 := 0.1 + 0.84
	# gövde: dört kenarlı kesik piramit (silindir, 4 yüz), kenarlar eksene hizalı olsun diye 45° döndürülür
	var seg_h := th / 4.0
	var r0 := bw * 0.72
	for i in 4:
		var rb := r0 * (1.0 - 0.15 * i)
		var rt := r0 * (1.0 - 0.15 * (i + 1))
		var mi := Props.cyl(n, rb, seg_h, Vector3(0, y0 + seg_h * (i + 0.5), 0), Y.TAS, Vector3(0, 45, 0), 4, rt)
		mi.material_override = Props.mat(Y.TAS.lerp(Color.WHITE, 0.5), 0.0, false, "ashlar")
		if col:
			Props.make_solid(mi, 1.0)
		if lod < 2:
			# bronz kabartma levhaları (dört yüz): tarla, kuş, hayvan sahneleri
			for f in 4:
				var ang := f * 90.0
				var dist := (rb + rt) * 0.5 * 0.7071 + 0.03
				var pos := Vector3(sin(deg_to_rad(ang)) * dist, y0 + seg_h * (i + 0.5), cos(deg_to_rad(ang)) * dist)
				Y.box(n, Vector3((rb + rt) * 0.5 * 0.9, seg_h * 0.5, 0.06), pos, Y.BRONZ, "", false, Vector3(0, ang, 0))
			Y.box(n, Vector3((rt + rb) * 0.5 * 1.45, 0.25, (rt + rb) * 0.5 * 1.45), Vector3(0, y0 + seg_h * (i + 1), 0), Y.TAS_K, "", false, Vector3(0, 45, 0)) if i < 3 else null
	var ty := y0 + th
	var rtop := r0 * 0.4
	# tepe platformu (çarpışmalı), korkuluk yok ama geniş
	Y.box(n, Vector3(rtop * 2.0 + 1.0, 0.4, rtop * 2.0 + 1.0), Vector3(0, ty + 0.2, 0), Y.TAS_K, "ashlar", col)
	# devrilmiş bronz figür (kanatlı rüzgâr figürü, yan yatmış) ve kırık direk
	Y.cyl(n, 0.12, 1.6, Vector3(0.0, ty + 1.2, 0), Y.DEMIR, 0.08, 5, false)
	var fig := Y.box(n, Vector3(0.5, 1.4, 0.3), Vector3(0.7, ty + 0.75, 0.2), Y.BRONZ, "", false, Vector3(0, 20, 78))
	Y.box(n, Vector3(1.6, 0.06, 0.5), Vector3(0.7, ty + 0.9, 0.2), Y.BRONZ, "", false, Vector3(0, 20, 12))
	var _f := fig
	# giriş kapısı (kuzey yüz), kemerli, görsel
	if lod == 0:
		Y.box(n, Vector3(1.3, 2.3, 0.1), Vector3(0, y0 + 1.15, -(r0 * 0.7071) - 0.04), Color("1e1a18"), "", false)
		Y.box(n, Vector3(1.9, 0.3, 0.14), Vector3(0, y0 + 2.45, -(r0 * 0.7071) - 0.04), Y.TAS_K, "", false)
	_perch(n, Vector3(0, ty + 0.45, 0))
	# kule tabanından kaideye üç basamak: kaide en az bir yandan 0,28'lik adımlarla; kapı önünde merdiven
	_climb(n, Vector3(bw * 1.2, 0.0, 0), Vector3(bw * 0.8, 0.84, 0), "basamak")
	Y.stairs(n, Vector3(bw * 0.85 + 1.3, 0.1, 0), Vector3(-1, 0, 0), 0.84 - 0.0, 2.0, Y.TAS, col)
