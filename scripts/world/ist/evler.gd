class_name IstEvler
extends RefCounted
## İstanbul 1453 ev kiti (docs/ISTANBUL_PLAN.md §4). Yapı dili Tolga'nın mektup bölümünün evleri (ByzCity._house):
## kesme taş zemin kat (ashlar), sokağa 0,7 m taşan sıvalı üst kat (cumba) ve altında payandalar, tuğla dişli korniş,
## kiremit beşik çatı, kemerli kepenkli pencereler, saksı, kemerli ahşap kapı + basamak, duvar kandili, devşirme mermer.
##
## Arayüz (docs/_ajan/gorev/_istanbul_ortak.md): build_<tip>(host, k, lod, tohum). Yerel koordinat: taban ortası, zemin
## y 0, sokak cephesi +z (cumba +z'ye taşar), cephe boyu x ekseninde, derinlik z ekseninde. İnsan ölçüsü (kapı, basamak,
## sandık, sundurma) k'den bağımsız; k yalnız kütleyi (cephe boyu, derinlik) ölçekler.
##
## Tırmanma (player.gd: JUMP 3,6 m/sn, STEP_H 0,42 m, g 9,8 → zıplama 0,66 m; Traversal: REACH 2,3, VAULT_MAX 1,1):
##   basamak 0,40 (yürüyerek) · sandık 1,0 (tırmanma kipinde atlanır) · sundurma/tente 2,2 (tutunup çıkılır) ·
##   saçak 3,4 / 5,8 / 8,4 (sundurmadan duvara tutunulur; kule ev ve iki kat üstü dış taş merdivenle).
##   Ara yükseklik yok (0,66–0,95 ve 1,1–2,1 m'de üst yüzey kullanılmaz: yarım tutunma olmasın).
## Şehirde toplu kullanım: mesh(v, lod) ile pişmiş ağ (MultiMesh), shapes(v) ile çarpışma (IstSehir).

const PLASTERS := [Color("e8c890"), Color("d89a78"), Color("efe0c4"), Color("c8a0a0"), Color("b8c4c0"), Color("e0b070"), Color("d8b89a")]
const SHUTTERS := [Color("3a6a5a"), Color("3a5a8a"), Color("6a3a2a"), Color("5a6a3a")]
const STONE := Color("fff4e4")
const WOOD := Color("5e4e3e")
const BRICK := Color("a86a4e")
const DARK := Color("1e1a18")
const GF := 3.0             # zemin kat
const UF := 2.7             # üst kat
const OVER := 0.7           # cumba çıkıntısı
const RISE := 1.7           # çatı sırtı (eğim ≤ 32°: yürünür)
const STEP := 0.40
const CRATE := 1.0
const SHED := 2.2

## CityPlan'ın ev ölçüleri (CityHouses.VARIANTS: [bölme (2 m), derinlik (2 m), kat, …]) ile aynı tabanlar: şehir planı
## değişmeden aynı yerlere bu evler konur. Döner: Vector3(cephe, saçak yüksekliği, derinlik)
static func dims(v: int) -> Vector3:
	var d: Array = CityHouses.VARIANTS[v % CityHouses.VARIANTS.size()]
	var floors := int(d[2])
	var eave := 3.4 if floors <= 1 else GF + (floors - 1) * UF + 0.1
	return Vector3(int(d[0]) * 2.0, eave, int(d[1]) * 2.0)


static func variant_count() -> int:
	return CityHouses.VARIANTS.size()


# ---------------------------------------------------------------- kayıt (arayüz)

## Evler anıt değildir: şehir kurucusu CityPlan'ın sokak kenarlarına dizer. Kayıt yalnız örnek amaçlı (önizleme).
static func catalog() -> Array:
	return []


# ---------------------------------------------------------------- tipler

## Sıra ev: iki katlı, cumbalı, kiremitli (mektup bölümünün evi)
static func build_sira_ev(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	var v := tohum % variant_count()
	var d := dims(v)
	ev(host, d.x * maxf(k, 0.6), d.z * maxf(k, 0.6), d.y, tohum, lod, "sira")


## Dükkânlı ev: zemin katta kemerli dükkân ağzı, tezgâh ve tente (tente 2,2 m: sandıktan tutunulur)
static func build_dukkanli_ev(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	var v := tohum % variant_count()
	var d := dims(v)
	ev(host, d.x * maxf(k, 0.6), d.z * maxf(k, 0.6), d.y, tohum, lod, "dukkan")


## Kule ev: dar, üç katlı, düz damlı ve mazgallı (sur dibi); dış taş merdivenle dama çıkılır
static func build_kule_ev(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	ev(host, 6.0, 6.0, 9.8, tohum, lod, "kule")


## Harabe: yıkık zemin kat duvarları (≤ 0,4 m'lik kırık basamaklarla üstüne çıkılır), ot, moloz
static func build_harabe(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum * 131 + 7
	var L := rng.randf_range(6.0, 10.0) * maxf(k, 0.6)
	var D := rng.randf_range(5.0, 8.0) * maxf(k, 0.6)
	var hs := [1.2, 2.0, 2.8, 0.8]
	for i in 4:
		var h: float = hs[(i + tohum) % 4]
		var horiz := i % 2 == 0
		var sz := Vector3(L, h, 0.6) if horiz else Vector3(0.6, h, D - 1.2)
		var p := Vector3(0, h * 0.5, (D * 0.5 - 0.3) * (1 if i == 0 else -1)) if horiz else Vector3((L * 0.5 - 0.3) * (1 if i == 1 else -1), h * 0.5, 0)
		if i == 0:
			# sokak cephesi: kapı boşluğu (1,6 m) iki yanında iki parça
			var w := (L - 1.6) * 0.5
			for sd in [-1, 1]:
				_block(host, Vector3(w, h, 0.6), Vector3(sd * (0.8 + w * 0.5), h * 0.5, D * 0.5 - 0.3), STONE, "ashlar", lod)
			continue
		_block(host, sz, p, STONE, "ashlar", lod)
	if lod >= 2:
		return
	# Kırık köşede basamaklar (0,4 m adım): sokaktan en yüksek duvarın üstüne
	var top: float = hs[(2 + tohum) % 4]
	var n := int(ceil(top / STEP))
	for s in n:
		var hh := minf((s + 1) * STEP, top)
		_block(host, Vector3(0.9, hh, 0.7), Vector3(-L * 0.5 + 0.9 + s * 0.7, hh * 0.5, -D * 0.5 + 0.95), STONE.darkened(0.08), "ashlar", lod)
	if lod == 0:
		for i in 6:
			var q := Vector3(rng.randf_range(-L * 0.35, L * 0.35), 0.15, rng.randf_range(-D * 0.3, D * 0.3))
			Props.box(host, Vector3(rng.randf_range(0.4, 0.9), 0.3, rng.randf_range(0.3, 0.7)), q, STONE.darkened(0.2), Vector3(0, rng.randf() * 90.0, 0))
			Props.ball(host, rng.randf_range(0.3, 0.6), q + Vector3(0.8, 0.0, 0.5), Color("6a8a3a"), Vector3(1, 0.5, 1), 6)
		Props.box(host, Vector3(L - 1.2, 0.04, D - 1.2), Vector3(0, 0.02, 0), Color("7a8a4a"))


## Sundurma: 2,2 m düz damlı ahşap sundurma (sokaktan çatıya yolun ikinci basamağı). Yerel: duvara +z'den yaslanır.
static func build_sundurma(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	var w := 2.6
	var d := 1.8
	if lod >= 2:
		return
	for sx in [-1, 1]:
		Props.box(host, Vector3(0.16, SHED, 0.16), Vector3(sx * (w * 0.5 - 0.1), SHED * 0.5, d - 0.1), WOOD)
	var roof := Props.solid(host, Vector3(w, 0.16, d), Vector3(0, SHED - 0.08, d * 0.5), Color("8a5a3a"))
	roof.set_meta("climb_top", true)
	if lod == 0:
		for i in 5:
			Props.box(host, Vector3(0.48, 0.05, d + 0.1), Vector3(-w * 0.5 + 0.26 + i * 0.52, SHED + 0.02, d * 0.5), Color("a8673e").darkened(0.05 * (i % 2)))


## Sandık yığını: 1,0 m (tırmanma kipinde atlanır), yanında 0,40 m'lik basamak taşı (yürüyerek)
static func build_sandik(host: Node3D, k: float = 1.0, lod: int = 0, tohum: int = 0) -> void:
	if lod >= 2:
		return
	Props.solid(host, Vector3(1.0, CRATE, 1.0), Vector3(0, CRATE * 0.5, 0), Color("9a7048"))
	Props.solid(host, Vector3(0.9, STEP, 0.9), Vector3(0, STEP * 0.5, 1.0), Color("c8b8a0"))
	if lod == 0:
		for y in [0.25, 0.75]:
			Props.box(host, Vector3(1.02, 0.06, 1.02), Vector3(0, y, 0), Color("6a4a2e"))


## Dış taş merdiven: 0,30 m'lik basamaklarla yükseklik h'ye (yerel: +x yönünde çıkar, duvar −z'de)
static func build_merdiven(host: Node3D, h: float, lod: int = 0) -> void:
	var n := int(ceil(h / 0.30))
	var rise := h / n
	for i in n:
		var hh := (i + 1) * rise
		_block(host, Vector3(0.34, hh, 1.1), Vector3(i * 0.32, hh * 0.5, 0), STONE.darkened(0.06), "ashlar", lod)
	if lod == 0:
		# korkuluk (dış yan), sahanlık
		Props.box(host, Vector3(n * 0.32, 0.06, 0.06), Vector3(n * 0.16 - 0.16, h * 0.5 + 1.0, 0.52), WOOD, Vector3(0, 0, rad_to_deg(atan2(h, n * 0.32))))


# ---------------------------------------------------------------- ev gövdesi

## Ev: L cephe (x), D derinlik (z), H saçak; tip "sira" | "dukkan" | "kule". lod 0 tam ayrıntı + çarpışma; lod 1 gövde,
## cumba, çatı, koyu pencere/kapı boşlukları (çarpışma aynı); lod 2 gövde + çatı (çarpışmasız, uzak siluet).
static func ev(host: Node3D, L: float, D: float, H: float, tohum: int, lod: int, tip := "sira") -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum * 97 + 13
	var plaster: Color = PLASTERS[tohum % PLASTERS.size()]
	var shutter: Color = SHUTTERS[(tohum * 3) % SHUTTERS.size()]
	var kule := tip == "kule"
	var over := 0.0 if kule else OVER
	var gf := minf(GF, H)
	var fz := D * 0.5                       # sokak cephesinin z'si
	if lod >= 2:
		Props.box(host, Vector3(L, gf, D), Vector3(0, gf * 0.5, 0), STONE.darkened(0.12))
		if H > gf:
			Props.box(host, Vector3(L, H - gf, D + over), Vector3(0, gf + (H - gf) * 0.5, over * 0.5), plaster)
		if kule:
			Props.box(host, Vector3(L + 0.2, 0.9, D + 0.2), Vector3(0, H + 0.45, 0), STONE.darkened(0.1))
		else:
			Props.prism(host, Vector3(D + over + 1.0, RISE, L + 0.8), Vector3(0, H + RISE * 0.5, over * 0.5), Color("b8603e"), Vector3(0, 90, 0))
		return
	# Zemin kat (kesme taş): katı
	_block(host, Vector3(L, gf, D), Vector3(0, gf * 0.5, 0), STONE, "ashlar", lod)
	# Üst kat(lar): sıvalı, sokağa taşan; katı
	if H > gf + 0.1:
		var up := _block(host, Vector3(L, H - gf, D + over), Vector3(0, gf + (H - gf) * 0.5, over * 0.5), plaster, "plaster", lod)
		up.set_meta("facade", true)
	# Çatı: beşik (mahya cepheye paralel, x ekseninde); çarpışması duvar hizasında biter, sırt kiremidin biraz altında
	if kule:
		_block(host, Vector3(L, 0.2, D), Vector3(0, H + 0.1, 0), STONE.darkened(0.1), "ashlar", lod)
		# mazgallı korkuluk (1,0 m): dama düşmeden çıkılır
		for sd in [-1, 1]:
			_block(host, Vector3(L, 1.0, 0.4), Vector3(0, H + 0.7, sd * (D * 0.5 - 0.2)), STONE.darkened(0.06), "ashlar", lod)
			_block(host, Vector3(0.4, 1.0, D - 0.8), Vector3(sd * (L * 0.5 - 0.2), H + 0.7, 0), STONE.darkened(0.06), "ashlar", lod)
		if lod == 0:
			for i in int(L / 1.2):
				for sd in [-1, 1]:
					Props.box(host, Vector3(0.5, 0.45, 0.42), Vector3(-L * 0.5 + 0.6 + i * 1.2, H + 1.42, sd * (D * 0.5 - 0.2)), STONE.darkened(0.06))
	else:
		_roof(host, L + 0.8, D + over + 1.0, Vector3(0, H, over * 0.5), lod)
		var body := StaticBody3D.new()
		body.name = "Roof"
		host.add_child(body)
		var cs := CollisionShape3D.new()
		var conv := ConvexPolygonShape3D.new()
		var z0 := -D * 0.5
		var z1 := D * 0.5 + over
		var zm := (z0 + z1) * 0.5
		var xr := L * 0.5
		conv.points = PackedVector3Array([Vector3(-xr, H, z0), Vector3(-xr, H, z1), Vector3(-xr, H + RISE - 0.1, zm),
			Vector3(xr, H, z0), Vector3(xr, H, z1), Vector3(xr, H + RISE - 0.1, zm)])
		cs.shape = conv
		body.add_child(cs)
	# Korniş (tuğla dişli) ve kat kirişi
	if not kule:
		Props.box(host, Vector3(L + 0.1, 0.16, 0.14), Vector3(0, H - 0.1, fz + over), BRICK)
		Props.box(host, Vector3(L + 0.1, 0.2, 0.18), Vector3(0, gf + 0.05, fz + over), WOOD)
	# Pencereler: üst katta kemerli, kepenkli
	var floors := maxi(1, int(round((H - gf) / UF)))
	var wn := 2 if L < 6.0 else 3
	for fl in floors:
		var wy := gf + UF * (fl + 0.5)
		if H <= gf + 0.1:
			break
		for i in wn:
			var x := -L * 0.5 + (i + 0.5) * L / wn
			_window(host, Vector3(x, wy, fz + over + 0.03), shutter, rng, lod)
	if H <= gf + 0.1:
		_window(host, Vector3(L * 0.25, 1.9, fz + 0.03), shutter, rng, lod)
	# Kapı (sokak cephesi) ve basamak (0,14: eşik)
	var dx := rng.randf_range(-L * 0.2, L * 0.2)
	if tip == "dukkan":
		dx = -L * 0.5 + 1.1
	Props.box(host, Vector3(1.1, 1.9, 0.06), Vector3(dx, 0.95, fz + 0.02), Color("5a3a22"))
	if lod == 0:
		Props.cyl(host, 0.55, 0.06, Vector3(dx, 1.9, fz + 0.02), Color("5a3a22"), Vector3(90, 0, 0), 10)
		Props.box(host, Vector3(1.4, 0.25, 0.12), Vector3(dx, 2.35, fz + 0.06), Color("c8b894"))
		Props.box(host, Vector3(1.4, 0.14, 0.5), Vector3(dx, 0.07, fz + 0.25), Color("b0a48c"))
		for i in 3:
			Props.ball(host, 0.025, Vector3(dx + 0.3, 0.6 + i * 0.4, fz + 0.06), Color("2a2a2a"), Vector3.ONE, 4)
	if tip == "dukkan":
		_shop(host, L, fz, rng, lod)
	if lod != 0:
		return
	# Cumbanın altında payandalar
	if not kule:
		for i in 4:
			var x := -L * 0.5 + 0.5 + i * (L - 1.0) / 3.0
			Props.box(host, Vector3(0.12, 0.12, 0.9), Vector3(x, gf - 0.25, fz + 0.35), WOOD, Vector3(-40, 0, 0))
	# Baca
	if rng.randf() < 0.6 and not kule:
		Props.box(host, Vector3(0.5, 1.4, 0.5), Vector3(rng.randf_range(-L * 0.3, L * 0.3), H + 1.2, -D * 0.2), Color("a8674a"))
	# Duvar kandili (her ikinci ev)
	if tohum % 2 == 0:
		var lx := dx + 0.9
		Props.box(host, Vector3(0.035, 0.035, 0.48), Vector3(lx, 2.72, fz + 0.24), Color("26221e"))
		Props.ball(host, 0.1, Vector3(lx, 2.36, fz + 0.46), Color("a8783a"), Vector3(1, 0.42, 1), 8)
		Props.ball(host, 0.025, Vector3(lx, 2.44, fz + 0.46), Color("ffc060"), Vector3(1, 2.2, 1), 5, 1.2)
	# Devşirme mermer (spolia)
	if rng.randf() < 0.45:
		for sd in [-0.72, 0.72]:
			Props.cyl(host, 0.09, 1.95, Vector3(dx + sd, 0.97, fz + 0.1), Color("e4ded2"), Vector3.ZERO, 8)
		Props.box(host, Vector3(1.7, 0.16, 0.2), Vector3(dx, 2.12, fz + 0.1), Color("e0d8c8"))


## Katı blok: lod 0 ve 1'de çarpışmalı (Props.solid + desen), lod 2'de yalnız görüntü
static func _block(host: Node3D, size: Vector3, pos: Vector3, col: Color, pattern: String, lod: int) -> Node3D:
	if lod >= 2:
		return Props.box(host, size, pos, col.darkened(0.08))
	var b := Props.solid(host, size, pos, Color.WHITE if pattern != "" else col)
	if pattern != "":
		Props.set_pattern(b, col, pattern)
	return b


## Kiremit beşik çatı (mahya x ekseninde) ve saçak tahtası
static func _roof(host: Node3D, w: float, d: float, base: Vector3, lod: int) -> void:
	var pm := PrismMesh.new()
	pm.size = Vector3(d, RISE, w)
	var roof := MeshInstance3D.new()
	roof.mesh = pm
	roof.position = base + Vector3(0, RISE * 0.5, 0)
	roof.rotation_degrees = Vector3(0, 90, 0)
	roof.material_override = Props.mat(Color("fff0e8"), 0.0, false, "tiles")
	host.add_child(roof)
	Props.box(host, Vector3(w + 0.1, 0.12, d + 0.1), base + Vector3(0, 0.02, 0), Color("5a3a24"))
	if lod == 0:
		# mahya kiremidi
		Props.cyl(host, 0.14, w, base + Vector3(0, RISE + 0.02, 0), Color("a8583a"), Vector3(0, 0, 90), 6)


## Kemerli, kepenkli, saksılı pencere (cephe +z)
static func _window(host: Node3D, p: Vector3, shutter: Color, rng: RandomNumberGenerator, lod: int) -> void:
	Props.box(host, Vector3(0.7, 1.0, 0.05), p, DARK)
	if lod != 0:
		return
	Props.cyl(host, 0.35, 0.05, p + Vector3(0, 0.5, 0), DARK, Vector3(90, 0, 0), 10)
	for v in 7:
		var va := PI * v / 6.0
		Props.box(host, Vector3(0.13, 0.1, 0.05), p + Vector3(cos(va) * 0.43, 0.5 + sin(va) * 0.43, 0.01), BRICK, Vector3(0, 0, rad_to_deg(va)))
	Props.box(host, Vector3(0.9, 0.08, 0.16), p + Vector3(0, -0.55, 0.05), Color("d8d0bc"))
	var open := rng.randf() < 0.6
	for sd in [-1, 1]:
		if open:
			Props.box(host, Vector3(0.04, 1.0, 0.36), p + Vector3(sd * 0.55, 0, 0.2), shutter, Vector3(0, sd * 20, 0))
		else:
			Props.box(host, Vector3(0.34, 1.0, 0.04), p + Vector3(sd * 0.18, 0, 0.03), shutter)
	if rng.randf() < 0.55:
		Props.cyl(host, 0.1, 0.16, p + Vector3(-0.2, -0.43, 0.1), Color("b8603a"), Vector3.ZERO, 7, 0.12)
		Props.ball(host, 0.14, p + Vector3(-0.2, -0.27, 0.1), Color("4a7a3a"), Vector3(1, 0.8, 1), 6)
		if rng.randf() < 0.6:
			Props.ball(host, 0.05, p + Vector3(-0.15, -0.2, 0.15), Color("d83a4a"), Vector3.ONE, 5)


## Dükkân ağzı: kemerli açıklık (koyu), tezgâh (1,0 m), çizgili tente (2,2 m, düz katı üst: tırmanma basamağı)
static func _shop(host: Node3D, L: float, fz: float, rng: RandomNumberGenerator, lod: int) -> void:
	var w := minf(L - 2.6, 3.4)
	if w < 1.6:
		return
	var cx := L * 0.5 - 0.6 - w * 0.5
	Props.box(host, Vector3(w, 2.2, 0.05), Vector3(cx, 1.1, fz + 0.03), Color("2a2220"))
	var awn: Color = [Color("b8503a"), Color("3a6a8a"), Color("c8a040"), Color("5a7a3a")][rng.randi() % 4]
	var t := Props.solid(host, Vector3(w + 0.4, 0.12, 1.4), Vector3(cx, SHED - 0.06, fz + 0.7), awn)
	t.set_meta("climb_top", true)
	Props.solid(host, Vector3(w, CRATE, 0.7), Vector3(cx, CRATE * 0.5, fz + 0.35), Color("8a6a48"))
	if lod != 0:
		return
	for i in 4:
		Props.box(host, Vector3((w + 0.4) / 8.0, 0.13, 1.42), Vector3(cx - (w + 0.4) * 0.5 + (i * 2 + 0.5) * (w + 0.4) / 8.0, SHED - 0.05, fz + 0.7), Color("efe6d0"))
	for sx in [-1, 1]:
		Props.box(host, Vector3(0.08, SHED - 0.12, 0.08), Vector3(cx + sx * (w * 0.5 + 0.1), (SHED - 0.12) * 0.5, fz + 1.35), WOOD)
	for i in 3:
		var c: Color = [Color("c84a3a"), Color("e8c040"), Color("6a9a3a"), Color("d88a3a")][(i + rng.randi()) % 4]
		Props.ball(host, 0.2, Vector3(cx - w * 0.3 + i * w * 0.3, CRATE + 0.12, fz + 0.4), c, Vector3(1, 0.6, 1), 6)


# ---------------------------------------------------------------- şehirde toplu kullanım (pişmiş ağ + çarpışma)

static var _mesh_cache := {}        # "v|tip|lod" → Mesh

## Örneğin pişmiş ağı (MultiMesh için). lod 0 tam (dokulu), lod 1 sade (dokulu), lod 2 tek yüzey (köşe rengi).
## Bir kez kurulur; oyun boyunca saklanır (aynı ev her bölümde aynı).
static func mesh(v: int, tip: String, lod: int) -> Mesh:
	var key := "%d|%s|%d" % [v, tip, lod]
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var tmp := Node3D.new()
	var d := dims(v)
	ev(tmp, d.x, d.z, d.y, v * 7 + (3 if tip == "dukkan" else 0), lod, tip)
	var list: Array = []
	for n in tmp.find_children("*", "MeshInstance3D", true, false):
		list.append(n)
	var holder := Node3D.new()
	var mi := World1453.bake(list, tmp, Transform3D.IDENTITY, holder, "Ev", 0.03, 0, lod >= 2)
	var m := mi.mesh
	holder.free()
	tmp.free()
	_mesh_cache[key] = m
	return m


## Örneğin çarpışma şekilleri (yerel): [[Shape3D, Transform3D], …] — gövde, üst kat, çatı (lod 0/1 ile aynı)
static func shapes(v: int, tip: String) -> Array:
	var d := dims(v)
	var L := d.x
	var D := d.z
	var H := d.y
	var out: Array = []
	var gf := minf(GF, H)
	var b0 := BoxShape3D.new()
	b0.size = Vector3(L, gf, D)
	out.append([b0, Transform3D(Basis.IDENTITY, Vector3(0, gf * 0.5, 0))])
	if H > gf + 0.1:
		var b1 := BoxShape3D.new()
		b1.size = Vector3(L, H - gf, D + OVER)
		out.append([b1, Transform3D(Basis.IDENTITY, Vector3(0, gf + (H - gf) * 0.5, OVER * 0.5))])
	var conv := ConvexPolygonShape3D.new()
	var z0 := -D * 0.5
	var z1 := D * 0.5 + OVER
	var zm := (z0 + z1) * 0.5
	conv.points = PackedVector3Array([Vector3(-L * 0.5, H, z0), Vector3(-L * 0.5, H, z1), Vector3(-L * 0.5, H + RISE - 0.1, zm),
		Vector3(L * 0.5, H, z0), Vector3(L * 0.5, H, z1), Vector3(L * 0.5, H + RISE - 0.1, zm)])
	out.append([conv, Transform3D.IDENTITY])
	if tip == "dukkan" and minf(L - 2.6, 3.4) >= 1.6:
		var w := minf(L - 2.6, 3.4)
		var cx := L * 0.5 - 0.6 - w * 0.5
		var a := BoxShape3D.new()
		a.size = Vector3(w + 0.4, 0.12, 1.4)
		out.append([a, Transform3D(Basis.IDENTITY, Vector3(cx, SHED - 0.06, D * 0.5 + 0.7))])
		var c := BoxShape3D.new()
		c.size = Vector3(w, CRATE, 0.7)
		out.append([c, Transform3D(Basis.IDENTITY, Vector3(cx, CRATE * 0.5, D * 0.5 + 0.35))])
	return out


## Sokaktan çatıya yollar (yerel): dükkânlı evde sandık (1,0) → tente (2,2) → üst kat duvarı (tırmanma kipi)
static func climbs(v: int, tip: String) -> Array:
	var d := dims(v)
	if tip != "dukkan":
		return []
	var w := minf(d.x - 2.6, 3.4)
	var cx := d.x * 0.5 - 0.6 - w * 0.5
	return [[Vector3(cx, 0, d.z * 0.5 + 1.2), Vector3(0, d.y + RISE * 0.5, OVER * 0.5), "sandik"]]


## Uçuş konma noktası (yerel): çatının sırtı
static func perches(v: int) -> Array:
	var d := dims(v)
	return [Vector3(0, d.y + RISE - 0.1, OVER * 0.5 - 0.0)]
