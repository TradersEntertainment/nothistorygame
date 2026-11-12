class_name IstGuneybati
extends RefCounted
## İstanbul, Nisan 1453: güneybatı parçası (Studios, Peribleptos, Aziz Andreas, Mokios çukur bostanı, Psamathia,
## Altın Kapı kalıntısı, Aziz Diomedes, değirmen, Lykos köprüsü, bağ).
## Arayüz: catalog(), build_<id>(host, k, lod), perches_<id>(k), climbs_<id>(k) + build(id, ...) dağıtıcı.
## Oyuncu: JUMP 3.6 → zıplama 3.6²/(2·9.8) = 0.66 m; STEP_H 0.42 m. Merdiven basamağı 0.24, sandık 0.5 m.
## Ölçek: k yalnız kütleyi ölçekler; kapı/basamak/korkuluk/yürüme yolu gerçek boyda (K = IstGbKit).

const K := preload("res://scripts/world/ist/guneybati_kit.gd")

const IDS := ["studios", "peribleptos", "andreas", "mokios", "psamathia", "altinkapi", "diomedes", "degirmen", "kopru", "bag"]


static func catalog() -> Array:
	return [
		{"id": "studios", "ad": "Studios (Stoudios) Manastırı ve İoannes Prodromos Bazilikası (İmrahor)", "dogu_m": -4300.0, "kuzey_m": -1000.0,
		"gercek_olcu": Vector3(22.0, 14.0, 58.0), "yon_derece": 90.0, "durum": "harap", "tur": "kilise",
		"bakis": Vector3(0, 21.0, 0), "bakis_r": 70.0, "gorev": true},
		{"id": "peribleptos", "ad": "Peribleptos (Sulu) Manastırı", "dogu_m": -4000.0, "kuzey_m": -1150.0,
		"gercek_olcu": Vector3(34.0, 16.0, 38.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
		"bakis": Vector3(0, 20.0, 0), "bakis_r": 50.0, "gorev": false},
		{"id": "andreas", "ad": "Aziz Andreas (Krisei) Kilisesi", "dogu_m": -3750.0, "kuzey_m": -1180.0,
		"gercek_olcu": Vector3(26.0, 17.0, 28.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
		"bakis": Vector3(0, 22.0, 0), "bakis_r": 45.0, "gorev": false},
		{"id": "mokios", "ad": "Mokios Açık Sarnıcı (çukur bostan)", "dogu_m": -2700.0, "kuzey_m": 150.0,
		"gercek_olcu": Vector3(147.0, 12.0, 170.0), "yon_derece": 0.0, "durum": "bostan", "tur": "anit",
		"bakis": Vector3(0, 16.0, 0), "bakis_r": 90.0, "gorev": true},
		{"id": "psamathia", "ad": "Psamathia balıkçı köyü", "dogu_m": -4000.0, "kuzey_m": -1500.0,
		"gercek_olcu": Vector3(40.0, 8.0, 34.0), "yon_derece": 0.0, "durum": "saglam", "tur": "ev",
		"bakis": Vector3(0, 14.0, 0), "bakis_r": 30.0, "gorev": false},
		{"id": "altinkapi", "ad": "Altın Kapı içindeki kale (1391 yıkıntısı)", "dogu_m": -4750.0, "kuzey_m": -1680.0,
		"gercek_olcu": Vector3(30.0, 17.0, 20.0), "yon_derece": 0.0, "durum": "harap", "tur": "kapi",
		"bakis": Vector3(0, 24.0, 0), "bakis_r": 50.0, "gorev": true},
		{"id": "diomedes", "ad": "Aziz Diomedes Kilisesi", "dogu_m": -4400.0, "kuzey_m": -1700.0,
		"gercek_olcu": Vector3(10.0, 8.0, 17.0), "yon_derece": 90.0, "durum": "saglam", "tur": "kilise",
		"bakis": Vector3(0, 13.0, 0), "bakis_r": 25.0, "gorev": false},
		{"id": "degirmen", "ad": "Lykos su değirmeni", "dogu_m": -3500.0, "kuzey_m": -700.0,
		"gercek_olcu": Vector3(14.0, 6.0, 16.0), "yon_derece": 0.0, "durum": "saglam", "tur": "ayrinti",
		"bakis": Vector3(0, 12.0, 0), "bakis_r": 20.0, "gorev": false},
		{"id": "kopru", "ad": "Lykos taş köprüsü", "dogu_m": -3300.0, "kuzey_m": -600.0,
		"gercek_olcu": Vector3(5.0, 3.0, 22.0), "yon_derece": 0.0, "durum": "saglam", "tur": "ayrinti",
		"bakis": Vector3(0, 9.0, 0), "bakis_r": 20.0, "gorev": false},
		{"id": "bag", "ad": "Güneybatı bağı ve bekçi kulübesi", "dogu_m": -3900.0, "kuzey_m": -900.0,
		"gercek_olcu": Vector3(30.0, 4.0, 36.0), "yon_derece": 0.0, "durum": "bostan", "tur": "bitki",
		"bakis": Vector3(0, 10.0, 0), "bakis_r": 25.0, "gorev": false},
	]


# ---------- dağıtıcı ve ortak çıkarım ----------

static func build(id: String, host: Node3D, k: float = 0.5, lod: int = 0) -> void:
	_run(id, host, k, lod, {})


static func perches(id: String, k: float = 0.5) -> Array:
	var out := {}
	_run(id, null, k, 0, out)
	return out.get("perch", [])


static func climbs(id: String, k: float = 0.5) -> Array:
	var out := {}
	_run(id, null, k, 0, out)
	return out.get("climb", [])


static func _run(id: String, h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	match id:
		"studios": _b_studios(h, k, lod, out)
		"peribleptos": _b_church(h, k, lod, out, _P_PERI)
		"andreas": _b_church(h, k, lod, out, _P_AND)
		"diomedes": _b_diomedes(h, k, lod, out)
		"mokios": _b_mokios(h, k, lod, out)
		"psamathia": _b_psamathia(h, k, lod, out)
		"altinkapi": _b_altinkapi(h, k, lod, out)
		"degirmen": _b_degirmen(h, k, lod, out)
		"kopru": _b_kopru(h, k, lod, out)
		"bag": _b_bag(h, k, lod, out)


static func build_studios(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("studios", host, k, lod)
static func perches_studios(k: float = 0.5) -> Array: return perches("studios", k)
static func climbs_studios(k: float = 0.5) -> Array: return climbs("studios", k)
static func build_peribleptos(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("peribleptos", host, k, lod)
static func perches_peribleptos(k: float = 0.5) -> Array: return perches("peribleptos", k)
static func climbs_peribleptos(k: float = 0.5) -> Array: return climbs("peribleptos", k)
static func build_andreas(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("andreas", host, k, lod)
static func perches_andreas(k: float = 0.5) -> Array: return perches("andreas", k)
static func climbs_andreas(k: float = 0.5) -> Array: return climbs("andreas", k)
static func build_mokios(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("mokios", host, k, lod)
static func perches_mokios(k: float = 0.5) -> Array: return perches("mokios", k)
static func climbs_mokios(k: float = 0.5) -> Array: return climbs("mokios", k)
static func build_psamathia(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("psamathia", host, k, lod)
static func perches_psamathia(k: float = 0.5) -> Array: return perches("psamathia", k)
static func climbs_psamathia(k: float = 0.5) -> Array: return climbs("psamathia", k)
static func build_altinkapi(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("altinkapi", host, k, lod)
static func perches_altinkapi(k: float = 0.5) -> Array: return perches("altinkapi", k)
static func climbs_altinkapi(k: float = 0.5) -> Array: return climbs("altinkapi", k)
static func build_diomedes(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("diomedes", host, k, lod)
static func perches_diomedes(k: float = 0.5) -> Array: return perches("diomedes", k)
static func climbs_diomedes(k: float = 0.5) -> Array: return climbs("diomedes", k)
static func build_degirmen(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("degirmen", host, k, lod)
static func perches_degirmen(k: float = 0.5) -> Array: return perches("degirmen", k)
static func climbs_degirmen(k: float = 0.5) -> Array: return climbs("degirmen", k)
static func build_kopru(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("kopru", host, k, lod)
static func perches_kopru(k: float = 0.5) -> Array: return perches("kopru", k)
static func climbs_kopru(k: float = 0.5) -> Array: return climbs("kopru", k)
static func build_bag(host: Node3D, k: float = 0.5, lod: int = 0) -> void: build("bag", host, k, lod)
static func perches_bag(k: float = 0.5) -> Array: return perches("bag", k)
static func climbs_bag(k: float = 0.5) -> Array: return climbs("bag", k)


## Basamak sayısı ve basamak yüksekliği (tam üst yüksekliğe oturur).
static func _nsteps(top: float) -> int:
	return maxi(1, ceili(top / 0.26))


static func _stair_to(h: Node3D, x: float, z: float, top: float, dir: Vector2, out: Dictionary, w := 1.6) -> Vector3:
	var n := _nsteps(top)
	var rise := top / n
	var t := K.stair(h, x, z, 0.0, dir, n, w, K.C_STONE_D, rise, K.STEP_RUN)
	var a := Vector3(x - dir.x * 0.5, 0.0, z - dir.y * 0.5)
	K.out_add(out, "climb", [a, Vector3(t.x + dir.x * 0.25, top, t.z + dir.y * 0.25), "basamak"])
	return t


static func _tree_cypress(h: Node3D, p: Vector3, ht: float) -> void:
	if h == null:
		return
	K.cy(h, 0.18, 1.0, p + Vector3(0, 0.5, 0), K.C_WOOD_D, 6)
	var c := Props.cyl(h, 0.8, ht, p + Vector3(0, 1.0 + ht * 0.5, 0), Color("3d6a3a"), Vector3.ZERO, 7, 0.05)
	Props.make_solid(c, 0.55)


static func _tree_round(h: Node3D, p: Vector3, ht: float, col: Color) -> void:
	if h == null:
		return
	K.cy(h, 0.22, ht * 0.5, p + Vector3(0, ht * 0.25, 0), K.C_WOOD_D, 6)
	K.bl(h, ht * 0.38, p + Vector3(0, ht * 0.62, 0), col, Vector3(1.0, 0.8, 1.0), 8, false)


## Zemin: ince döşeme (üstü 6 cm; yürünür), z-çakışmasını önlemek için zeminden yüksek.
static func _paving(h: Node3D, c: Vector3, sx: float, sz: float, col := Color("bdb094"), pat := "flagstone") -> void:
	K.sb(h, Vector3(sx, 0.06, sz), Vector3(c.x, 0.03, c.z), col, pat)


# ---------- STUDIOS ----------

static func _b_studios(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var Wd := 22.0 * k
	var Lb := 26.0 * k
	var Ha := maxf(9.0 * k, 4.4)
	var Hn := maxf(14.0 * k, 6.4)
	var Hc := maxf(4.8 * k, 3.0)
	var aw := maxf(5.0 * k, 2.2)
	var nw := Wd - 2.0 * aw
	var x0 := -3.0 * k
	var x1 := x0 + Lb
	var t := 0.7
	var wb := K.C_BRICK
	if lod == 2:
		K.silhouette(h, Vector3(Lb + 6.0 * k, Ha, Wd), wb, K.C_TILE, Hn - Ha)
		K.silhouette(h, Vector3(1, 1, 1), wb, K.C_TILE, 0.0) if false else null
		K.out_add(out, "perch", Vector3(0, Hn + 1.0, 0))
		return
	var AL := maxf(19.0 * k, 9.0)
	var NL := maxf(6.0 * k, 3.2)
	var xn0 := x0 - NL
	var xa0 := xn0 - AL
	var hz := Wd * 0.5
	var Hp := 3.6
	# --- gövde: dış duvarlar (kuzey / güney: pencereli, güney ortada yan kapı) ---
	K.wall(h, Vector2(x0, -hz), Vector2(x1, -hz), Ha, t, wb, "brick", [], maxi(3, int(Lb / 3.0)))
	K.wall(h, Vector2(x0, hz), Vector2(x1, hz), Ha, t, wb, "brick", [[Lb * 0.78, K.DOOR_W + 0.3]], maxi(3, int(Lb / 3.0)))
	# doğu uç (kapalı), batı uç (nave kapısı ortada)
	K.wall(h, Vector2(x1, -hz), Vector2(x1, -nw * 0.5), Ha, t, wb, "brick")
	K.wall(h, Vector2(x1, nw * 0.5), Vector2(x1, hz), Ha, t, wb, "brick")
	K.wall(h, Vector2(x1, -nw * 0.5), Vector2(x1, nw * 0.5), Hn, t, wb, "brick", [], 0)
	K.wall(h, Vector2(x0, -hz), Vector2(x0, -nw * 0.5), Ha, t, wb, "brick")
	K.wall(h, Vector2(x0, nw * 0.5), Vector2(x0, hz), Ha, t, wb, "brick")
	K.wall(h, Vector2(x0, -nw * 0.5), Vector2(x0, nw * 0.5), Hn, t, wb, "brick", [[nw * 0.5, K.DOOR_W + 0.9]], 0)
	# --- nave: sütun sıraları + arşitrav + üst pencereli duvar ---
	var ncol := maxi(2, int((Lb - 1.0) / 2.1))
	var sp := (Lb - 1.0) / ncol
	for sg in [-1.0, 1.0]:
		var zc: float = sg * nw * 0.5
		for i in ncol + 1:
			var cx := x0 + 0.5 + i * sp
			if h != null:
				K.cy(h, 0.24, Hc, Vector3(cx, Hc * 0.5, zc), K.C_MARBLE, 10, -1.0, "marble")
				K.cy(h, 0.34, 0.22, Vector3(cx, Hc + 0.11, zc), K.C_STONE, 8, -1.0, "", false)
				K.cy(h, 0.34, 0.2, Vector3(cx, 0.1, zc), K.C_STONE, 8, -1.0, "", false)
		K.sb(h, Vector3(Lb, 0.4, 0.6), Vector3((x0 + x1) * 0.5, Hc + 0.42, zc), K.C_STONE, "ashlar")
		K.wall(h, Vector2(x0, zc), Vector2(x1, zc), Hn - Hc - 0.62, 0.5, wb, "brick", [], maxi(3, int(Lb / 2.6)), Hc + 0.62, -1.0, 1.1)
	# --- yan nef çatıları (eğimli katı levha) ---
	var ar := aw * 0.45
	for sg in [-1.0, 1.0]:
		var ra := Props.ramp(h, Vector3((x0 + x1) * 0.5, Ha, sg * (hz + 0.2)), Vector3((x0 + x1) * 0.5, Ha + ar, sg * (nw * 0.5 + 0.1)), Lb + 0.4, K.C_TILE) if h != null else null
		if ra != null:
			Props.set_pattern(ra, K.C_TILE, "tiles")
	# --- nave çatısı ---
	var nr := nw * 0.32
	K.gable(h, Vector3((x0 + x1) * 0.5, Hn, 0), nw + 0.9, Lb + 0.2, nr, "x", K.C_TILE, wb)
	# --- apsis (dışarıda, duvara bitişik) ---
	var ar_r := nw * 0.5
	K.apse(h, Vector3(x1 + ar_r * 0.55, 0, 0), ar_r, Hn * 0.78, wb, K.C_TILE, 3)
	# --- narteks: düz katı çatı, batıda kemerli cephe ---
	var Hnt := Ha - 0.36
	K.wall(h, Vector2(xn0, -hz), Vector2(x0, -hz), Hnt, t, wb, "brick", [], 2)
	K.wall(h, Vector2(xn0, hz), Vector2(x0, hz), Hnt, t, wb, "brick", [], 2)
	K.wall(h, Vector2(xn0, -hz), Vector2(xn0, hz), Hnt, t, wb, "brick", [[hz, K.DOOR_W + 1.0]], 0)
	K.sb(h, Vector3(NL + t, 0.3, Wd + t), Vector3((xn0 + x0) * 0.5, Hnt + 0.15, 0), K.C_TILE, "tiles")
	if h != null:
		# narteks cephesinde beş kör kemer: sütunlu pilastrlar
		for i in 5:
			var zz := -hz + (i + 0.5) * Wd / 5.0
			if absf(zz) < 1.4:
				continue
			K.vb(h, Vector3(0.1, Hnt * 0.55, 1.2), Vector3(xn0 - t * 0.5 - 0.02, Hnt * 0.4, zz), K.C_DARK)
			var ar2 := Props.ball(h, 0.6, Vector3(xn0 - t * 0.5 - 0.02, Hnt * 0.4 + Hnt * 0.275, zz), K.C_DARK, Vector3(0.1, 0.9, 1.0), 8)
			ar2.scale = Vector3(0.1, 0.9, 1.0)
	# --- atrium: üç yönde duvar + revak (düz katı çatı), orta çeşme ---
	_paving(h, Vector3((xa0 + xn0) * 0.5, 0, 0), AL, Wd + t)
	K.wall(h, Vector2(xa0, -hz), Vector2(xn0, -hz), Hp, t, K.C_PLASTER, "plaster", [], maxi(2, int(AL / 4.0)), 0.0, 1.9, 1.0)
	K.wall(h, Vector2(xa0, hz), Vector2(xn0, hz), Hp, t, K.C_PLASTER, "plaster", [], maxi(2, int(AL / 4.0)), 0.0, 1.9, 1.0)
	K.wall(h, Vector2(xa0, -hz), Vector2(xa0, hz), Hp, t, K.C_PLASTER, "plaster", [[hz, 2.6]], 0)
	var pd := 2.8
	for sg in [-1.0, 1.0]:
		K.sb(h, Vector3(AL, 0.3, pd), Vector3((xa0 + xn0) * 0.5, Hp - 0.15, sg * (hz - pd * 0.5)), K.C_TILE, "tiles")
		var nc := maxi(2, int(AL / 2.2))
		for i in nc + 1:
			var cx2 := xa0 + 1.0 + i * ((AL - 2.0) / nc)
			if h != null:
				K.cy(h, 0.22, Hp - 0.3, Vector3(cx2, (Hp - 0.3) * 0.5, sg * (hz - pd)), K.C_MARBLE, 10, -1.0, "marble")
	var wz := hz - pd
	K.sb(h, Vector3(pd, 0.3, Wd - 2.0 * pd + 0.01), Vector3(xa0 + pd * 0.5, Hp - 0.15, 0), K.C_TILE, "tiles")
	var ncw := maxi(2, int((Wd - 2.0 * pd) / 2.2))
	for i in range(1, ncw):
		var zz2 := -wz + i * (2.0 * wz / ncw)
		if absf(zz2) < 1.4:
			continue
		if h != null:
			K.cy(h, 0.22, Hp - 0.3, Vector3(xa0 + pd, (Hp - 0.3) * 0.5, zz2), K.C_MARBLE, 10, -1.0, "marble")
	# çeşme (phiale)
	var fc := Vector3((xa0 + xn0) * 0.5 + 1.0, 0, 0)
	if h != null:
		K.cy(h, 1.1, 0.6, fc + Vector3(0, 0.3, 0), K.C_STONE, 10, -1.0, "ashlar")
		Props.cyl(h, 0.85, 0.04, fc + Vector3(0, 0.62, 0), K.C_WATER, Vector3.ZERO, 10)
		K.cy(h, 0.14, 1.5, fc + Vector3(0, 0.75, 0), K.C_MARBLE, 6)
		K.bl(h, 0.35, fc + Vector3(0, 1.55, 0), K.C_LEAD, Vector3(1, 0.7, 1), 8)
	_tree_cypress(h, Vector3(xa0 + pd + 1.6, 0, -wz + 1.4), 3.2)
	_tree_cypress(h, Vector3(xa0 + pd + 1.6, 0, wz - 1.4), 3.2)
	# --- hücre sırası (kuzeyde, atriuma bitişik), eğimli katı çatı ---
	var cd := 3.6
	var Hcell := 3.4
	K.sb(h, Vector3(AL + t, Hcell, cd), Vector3((xa0 + xn0) * 0.5, Hcell * 0.5, -hz - cd * 0.5 - t * 0.5), K.C_PLASTER, "plaster")
	if h != null:
		var ramp := Props.ramp(h, Vector3((xa0 + xn0) * 0.5, Hcell, -hz - cd - t * 0.5), Vector3((xa0 + xn0) * 0.5, Hcell + 0.6, -hz - t * 0.5), AL + t + 0.2, K.C_TILE)
		Props.set_pattern(ramp, K.C_TILE, "tiles")
		var ncell := maxi(2, int(AL / 3.0))
		for i in ncell:
			var cx3 := xa0 + (i + 0.5) * AL / ncell
			K.vb(h, Vector3(1.0, 2.0, 0.06), Vector3(cx3, 1.0, -hz - cd - t * 0.5 - 0.02), K.C_DARK)
			K.vb(h, Vector3(0.6, 0.5, 0.06), Vector3(cx3 + 1.0, 1.9, -hz - cd - t * 0.5 - 0.02), K.C_DARK)
	# --- sarnıç (güneyde, sokak aralığıyla): açık, taban yürünür, yan kapı + iç merdiven ---
	var cw := maxf(18.6 * k, 8.0)
	var cl := maxf(26.4 * k, 11.0)
	var cx0 := 5.0 * k
	var cz0 := hz + 5.5
	var Hcis := 3.4
	var tc := 1.5
	var cc := Vector2(cx0 + cw * 0.5, cz0 + cl * 0.5)
	_paving(h, Vector3(cc.x, 0, cc.y), cw, cl, Color("a89c84"), "flagstone")
	K.wall(h, Vector2(cx0, cz0), Vector2(cx0 + cw, cz0), Hcis, tc, K.C_STONE_D, "ashlar", [[cw * 0.5, 2.2]])
	K.wall(h, Vector2(cx0, cz0 + cl), Vector2(cx0 + cw, cz0 + cl), Hcis, tc, K.C_STONE_D, "ashlar")
	K.wall(h, Vector2(cx0, cz0), Vector2(cx0, cz0 + cl), Hcis, tc, K.C_STONE_D, "ashlar")
	K.wall(h, Vector2(cx0 + cw, cz0), Vector2(cx0 + cw, cz0 + cl), Hcis, tc, K.C_STONE_D, "ashlar")
	# 24 sütunun kalanı: 6 × 4 (aralık ≥ 1,9), bir kısmı kırık
	var ccx := maxi(2, int((cw - 2.0 * tc - 2.0) / 2.1))
	var ccz := maxi(2, int((cl - 2.0 * tc - 2.0) / 2.1))
	for i in ccx:
		for j in ccz:
			if (i * 7 + j * 3) % 5 == 0:
				continue
			var px := cx0 + tc + 1.0 + (i + 0.5) * ((cw - 2.0 * tc - 2.0) / ccx)
			var pz := cz0 + tc + 1.0 + (j + 0.5) * ((cl - 2.0 * tc - 2.0) / ccz)
			var ph := 2.8 if (i + j) % 3 != 0 else 1.2
			if h != null:
				K.cy(h, 0.26, ph, Vector3(px, ph * 0.5, pz), K.C_MARBLE, 8, -1.0, "marble")
	# korkuluk (iç ve dış kenar), kapı üstü hariç
	for sg in [0.0, 1.0]:
		K.sb(h, Vector3(cw, 1.0, 0.25), Vector3(cc.x, Hcis + 0.5, cz0 + sg * cl - (tc * 0.5 - 0.12) * (1.0 if sg > 0.5 else -1.0)), K.C_STONE, "ashlar")
	for sg in [0.0, 1.0]:
		K.sb(h, Vector3(0.25, 1.0, cl), Vector3(cx0 + sg * cw - (tc * 0.5 - 0.12) * (1.0 if sg > 0.5 else -1.0), Hcis + 0.5, cc.y), K.C_STONE, "ashlar")
	# --- dış merdivenler ve tırmanış yolları ---
	var xs := x0 + Lb * 0.35
	var top1 := _stair_to(h, xs, hz + 0.5, Ha, Vector2(0, 1), out, 1.8)      # güney yan nef çatısına (orada +z yönünden duvara)
	# merdiven uzaklaşan yönde basamak yükselir: duvar yönüne doğru yükselsin diye ters çevrilir (aşağıda yeniden kurulur)
	# (yukarıdaki çağrı yalnız çıktı kaydı içindi; asıl merdiveni duvara doğru yükselen biçimde kuruyoruz)
	out["climb"] = []
	var n1 := _nsteps(Ha)
	var rise1 := Ha / n1
	for i in n1:
		var ht := rise1 * (i + 1)
		# i = 0 duvardan en uzak (en alçak) basamak
		var zc2 := hz + t * 0.5 + 0.05 + (n1 - 1 - i + 0.5) * K.STEP_RUN
		K.sb(h, Vector3(1.8, ht, K.STEP_RUN + 0.02), Vector3(xs, ht * 0.5, zc2), K.C_STONE_D, "ashlar")
	K.out_add(out, "climb", [Vector3(xs, 0.0, hz + t * 0.5 + 0.05 + n1 * K.STEP_RUN + 0.4), Vector3(xs, Ha, hz + t * 0.5 + 0.2), "basamak"])
	# yan nef çatısından nave saçağına sandık basamakları (yüzey eğimli: y_of)
	var aisle_y := func(_x: float, z: float) -> float:
		return Ha + ar * clampf((hz + 0.2 - z) / (hz + 0.2 - (nw * 0.5 + 0.1)), 0.0, 1.0)
	var zc3 := nw * 0.5 + 0.4 + 0.35
	var y_low: float = aisle_y.call(0.0, zc3 + 1.4)
	var n2 := maxi(1, ceili((Hn - y_low) / 0.5))
	var zbase := zc3 + 0.7 * n2
	var xc3 := x0 + Lb * 0.35
	var tp := K.crates(h, Vector3(xc3, 0.0, zbase), Vector2(0, -1), n2, 1.4, aisle_y, Hn)
	K.out_add(out, "climb", [Vector3(xc3, aisle_y.call(0.0, zbase + 0.9), zbase + 0.9), Vector3(tp.x, Hn, nw * 0.5 + 0.5), "sandik"])
	# kuzey: hücre çatısına merdiven, hücre çatısından revak çatısına adım
	var xa_mid := (xa0 + xn0) * 0.5
	var n3 := _nsteps(Hcell + 0.1)
	var rise3 := (Hcell + 0.1) / n3
	for i in n3:
		var ht3 := rise3 * (i + 1)
		var zc4 := -hz - cd - t * 0.5 - 0.05 - (n3 - 1 - i + 0.5) * K.STEP_RUN
		K.sb(h, Vector3(1.8, ht3, K.STEP_RUN + 0.02), Vector3(xa_mid, ht3 * 0.5, zc4), K.C_STONE_D, "ashlar")
	K.out_add(out, "climb", [Vector3(xa_mid, 0.0, -hz - cd - t * 0.5 - 0.05 - n3 * K.STEP_RUN - 0.4), Vector3(xa_mid, Hcell + 0.1, -hz - cd - t * 0.5 - 0.3), "basamak"])
	# sarnıç: iç merdiven değil; dış merdiven doğu duvarından rim'e
	var n4 := _nsteps(Hcis)
	var rise4 := Hcis / n4
	for i in n4:
		var ht4 := rise4 * (i + 1)
		var xc4 := cx0 + cw + tc * 0.5 + 0.05 + (n4 - 1 - i + 0.5) * K.STEP_RUN
		K.sb(h, Vector3(K.STEP_RUN + 0.02, ht4, 1.8), Vector3(xc4 - tc * 0.5 + 0.0, ht4 * 0.5, cc.y), K.C_STONE_D, "ashlar")
	K.out_add(out, "climb", [Vector3(cx0 + cw + tc * 0.5 + n4 * K.STEP_RUN + 0.5, 0.0, cc.y), Vector3(cx0 + cw, Hcis, cc.y), "basamak"])
	K.out_add(out, "perch", Vector3((x0 + x1) * 0.5, Hn + nr + 0.15, 0))
	K.out_add(out, "perch", Vector3(xa_mid, Hp + 0.1, hz - pd * 0.5))
	top1 = top1


# ---------- kubbeli küçük kiliseler (Peribleptos, Andreas) ----------

const _P_PERI := {"id": "peribleptos", "L": 16.0, "W": 13.0, "Hw": 9.0, "arm": 6.0, "armr": 2.6, "dr": 3.0, "dh": 3.0, "domeh": 2.4, "apr": 2.6, "pre": 38.0, "prw": 32.0}
const _P_AND := {"id": "andreas", "L": 20.0, "W": 16.0, "Hw": 10.0, "arm": 7.0, "armr": 3.0, "dr": 3.6, "dh": 3.5, "domeh": 3.0, "apr": 3.0, "pre": 0.0, "prw": 0.0}


static func _b_church(h: Node3D, k: float, lod: int, out: Dictionary, P: Dictionary) -> void:
	var L: float = maxf(P["L"] * k, 7.0)
	var W: float = maxf(P["W"] * k, 6.0)
	var Hw: float = maxf(P["Hw"] * k, 4.6)
	var arm: float = maxf(P["arm"] * k, 3.4)
	var armr: float = maxf(P["armr"] * k, 1.4)
	var dr: float = maxf(P["dr"] * k, 1.7)
	var dh: float = maxf(P["dh"] * k, 1.6)
	var domeh: float = maxf(P["domeh"] * k, 1.3)
	var apr: float = maxf(P["apr"] * k, 1.6)
	var t := 0.7
	var wb := K.C_BRICK
	var NL := maxf(3.5 * k, 2.4)
	var x0 := -L * 0.5
	var x1 := L * 0.5
	if lod == 2:
		K.silhouette(h, Vector3(L + NL, Hw, W), wb, K.C_TILE, armr, dr)
		K.out_add(out, "perch", Vector3(0, Hw + armr + dh + domeh + 0.3, 0))
		return
	var hz := W * 0.5
	# gövde duvarları (batıda kapı)
	K.wall(h, Vector2(x0, -hz), Vector2(x1, -hz), Hw, t, wb, "brick", [], maxi(2, int(L / 3.5)), 0.0, Hw * 0.5, 1.4)
	K.wall(h, Vector2(x0, hz), Vector2(x1, hz), Hw, t, wb, "brick", [], maxi(2, int(L / 3.5)), 0.0, Hw * 0.5, 1.4)
	K.wall(h, Vector2(x1, -hz), Vector2(x1, hz), Hw, t, wb, "brick")
	K.wall(h, Vector2(x0, -hz), Vector2(x0, hz), Hw, t, wb, "brick", [[hz, K.DOOR_W + 0.7]])
	# banding: taş kuşaklar
	if h != null:
		var yb := 1.6
		while yb < Hw - 0.5:
			for sg in [-1.0, 1.0]:
				K.vb(h, Vector3(L + 0.15, 0.16, 0.08), Vector3(0, yb, sg * (hz + t * 0.5 + 0.02)), K.C_STONE)
			K.vb(h, Vector3(0.08, 0.16, W + 0.15), Vector3(x1 + t * 0.5 + 0.02, yb, 0), K.C_STONE)
			yb += 1.7
	# düz katı tavan, üstte haç çatı kolları
	K.sb(h, Vector3(L + t, 0.3, W + t), Vector3(0, Hw + 0.15, 0), K.C_TILE, "tiles")
	K.gable(h, Vector3(0, Hw + 0.3, 0), arm, L + 0.2, armr, "x", K.C_TILE, wb)
	K.gable(h, Vector3(0, Hw + 0.3 + 0.02, 0), arm, W + 0.2, armr, "z", K.C_TILE, wb)
	K.dome(h, Vector3(0, Hw + 0.3 + armr * 0.55, 0), dr, dh, domeh)
	# apsis ve narteks
	K.apse(h, Vector3(x1 + apr * 0.55, 0, 0), apr, Hw * 0.7, wb, K.C_TILE, 3)
	var Hn := Hw * 0.62
	K.wall(h, Vector2(x0 - NL, -hz), Vector2(x0, -hz), Hn, t, wb, "brick", [], 1)
	K.wall(h, Vector2(x0 - NL, hz), Vector2(x0, hz), Hn, t, wb, "brick", [], 1)
	K.wall(h, Vector2(x0 - NL, -hz), Vector2(x0 - NL, hz), Hn, t, wb, "brick", [[hz, K.DOOR_W + 0.5]])
	K.sb(h, Vector3(NL + t, 0.3, W + t), Vector3(x0 - NL * 0.5, Hn + 0.15, 0), K.C_TILE, "tiles")
	# narteks çatısına sandık / dış merdiven
	var xs := x0 - NL * 0.5
	var n1 := _nsteps(Hn)
	var r1 := Hn / n1
	for i in n1:
		var ht := r1 * (i + 1)
		var zc := hz + t * 0.5 + 0.05 + (n1 - 1 - i + 0.5) * K.STEP_RUN
		K.sb(h, Vector3(1.6, ht, K.STEP_RUN + 0.02), Vector3(xs, ht * 0.5, zc), K.C_STONE_D, "ashlar")
	K.out_add(out, "climb", [Vector3(xs, 0.0, hz + t * 0.5 + 0.05 + n1 * K.STEP_RUN + 0.4), Vector3(xs, Hn, hz + t * 0.5 + 0.2), "basamak"])
	# narteks çatısından gövde tavanına (Hw): sandık basamakları gövde duvarına dayalı
	var hdiff := Hw + 0.3 - Hn - 0.3
	var n2 := maxi(1, ceili(hdiff / K.CRATE_H))
	var tp := K.crates(h, Vector3(x0 - 0.35 - 0.7 * n2 + 0.0, Hn + 0.3, -hz * 0.4), Vector2(1, 0), n2, 1.4)
	K.out_add(out, "climb", [Vector3(tp.x - 0.7 * n2, Hn + 0.3, -hz * 0.4), Vector3(x0 + 0.3, Hw + 0.3, -hz * 0.4), "sandik"])
	# etek: avlu ve çevre duvarı (Peribleptos)
	if P["pre"] > 0.0:
		var pm := maxf(8.0 * k, 4.0)
		var pL := L + NL + 2.0 * pm + apr
		var pW := W + 2.0 * pm
		var pcx := (x1 + apr - (x0 - NL)) * 0.5 + (x0 - NL) - (L + NL + apr) * 0.0
		pcx = ((x0 - NL) + (x1 + apr)) * 0.5
		var px0 := pcx - pL * 0.5
		var px1 := pcx + pL * 0.5
		var pz := pW * 0.5
		var tw := 1.5
		var Hwl := 3.6
		_paving(h, Vector3(pcx, 0, 0), pL, pW, Color("b5a88c"), "cobble")
		K.wall(h, Vector2(px0, -pz), Vector2(px1, -pz), Hwl, tw, K.C_STONE_D, "ashlar")
		K.wall(h, Vector2(px0, pz), Vector2(px1, pz), Hwl, tw, K.C_STONE_D, "ashlar", [[pL * 0.4, 2.6]])
		K.wall(h, Vector2(px1, -pz), Vector2(px1, pz), Hwl, tw, K.C_STONE_D, "ashlar")
		K.wall(h, Vector2(px0, -pz), Vector2(px0, pz), Hwl, tw, K.C_STONE_D, "ashlar", [[pz, 2.6]])
		for sg in [-1.0, 1.0]:
			K.sb(h, Vector3(pL, 1.0, 0.25), Vector3(pcx, Hwl + 0.5, sg * (pz - tw * 0.5 + 0.12)), K.C_STONE, "ashlar")
			K.sb(h, Vector3(pL, 1.0, 0.25), Vector3(pcx, Hwl + 0.5, sg * (pz + tw * 0.5 - 0.12)), K.C_STONE, "ashlar")
		_tree_cypress(h, Vector3(px0 + 2.4, 0, -pz + 2.4), 3.6)
		_tree_cypress(h, Vector3(px1 - 2.4, 0, pz - 2.4), 3.6)
		_tree_cypress(h, Vector3(px1 - 2.4, 0, -pz + 2.4), 3.0)
		var ns := _nsteps(Hwl)
		var rs := Hwl / ns
		for i in ns:
			var hh := rs * (i + 1)
			var zz := -pz - tw * 0.5 - 0.05 - (ns - 1 - i + 0.5) * K.STEP_RUN
			K.sb(h, Vector3(1.8, hh, K.STEP_RUN + 0.02), Vector3(pcx, hh * 0.5, zz), K.C_STONE_D, "ashlar")
		K.out_add(out, "climb", [Vector3(pcx, 0.0, -pz - tw * 0.5 - ns * K.STEP_RUN - 0.4), Vector3(pcx, Hwl, -pz - tw * 0.5 - 0.1), "basamak"])
	K.out_add(out, "perch", Vector3(0, Hw + 0.3 + armr * 0.55 + dh + domeh + 1.3, 0))
	K.out_add(out, "perch", Vector3(xs, Hn + 0.3, 0))


static func _b_diomedes(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var L := maxf(11.0 * k, 6.0)
	var W := maxf(7.0 * k, 4.4)
	var Hw := maxf(5.5 * k, 3.6)
	var t := 0.6
	var hz := W * 0.5
	var x0 := -L * 0.5
	var x1 := L * 0.5
	if lod == 2:
		K.silhouette(h, Vector3(L, Hw, W), K.C_PLASTER, K.C_TILE, W * 0.3)
		K.out_add(out, "perch", Vector3(0, Hw + W * 0.3 + 0.5, 0))
		return
	K.wall(h, Vector2(x0, -hz), Vector2(x1, -hz), Hw, t, K.C_PLASTER, "plaster", [], 2, 0.0, Hw * 0.5, 1.2)
	K.wall(h, Vector2(x0, hz), Vector2(x1, hz), Hw, t, K.C_PLASTER, "plaster", [], 2, 0.0, Hw * 0.5, 1.2)
	K.wall(h, Vector2(x1, -hz), Vector2(x1, hz), Hw, t, K.C_PLASTER, "plaster")
	K.wall(h, Vector2(x0, -hz), Vector2(x0, hz), Hw, t, K.C_PLASTER, "plaster", [[hz, K.DOOR_W + 0.3]])
	var rise := (W + 0.9) * 0.3
	K.gable(h, Vector3(0, Hw, 0), W + 0.9, L + 0.3, rise, "x", K.C_TILE, K.C_PLASTER)
	K.apse(h, Vector3(x1 + W * 0.18, 0, 0), W * 0.3, Hw * 0.7, K.C_PLASTER, K.C_TILE, 1)
	# çan duvarı yok (1453'te belirsiz); batı alınlığında haç
	if h != null:
		K.vb(h, Vector3(0.12, 1.0, 0.12), Vector3(x0 - 0.0, Hw + rise + 0.5, 0), K.C_STONE)
		K.vb(h, Vector3(0.5, 0.12, 0.12), Vector3(x0 - 0.0, Hw + rise + 0.72, 0), K.C_STONE)
	# sandık yığını: yan duvara dayalı, çatıya
	var n := maxi(1, ceili(Hw / K.CRATE_H))
	var tp := K.crates(h, Vector3(0, 0.0, hz + 0.35 + 0.7 * n), Vector2(0, -1), n, 1.4)
	K.out_add(out, "climb", [Vector3(0, 0.0, hz + 0.35 + 0.7 * n + 0.9), Vector3(0, Hw, hz + 0.3), "sandik"])
	K.out_add(out, "perch", Vector3(0, Hw + rise + 0.15, 0))
	tp = tp
	_tree_cypress(h, Vector3(x0 - 2.2, 0, hz + 1.8), 3.0)


# ---------- MOKİOS ----------

static func _b_mokios(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var PW := maxf(147.0 * k, 40.0)
	var PL := maxf(170.0 * k, 46.0)
	var D := maxf(12.0 * k, 5.0)
	var tw := 2.2
	var hx := PW * 0.5
	var hz := PL * 0.5
	var col := Color("b39d78")
	if lod == 2:
		K.sb(h, Vector3(PW + tw, D, tw), Vector3(0, D * 0.5, -hz), col)
		K.sb(h, Vector3(PW + tw, D, tw), Vector3(0, D * 0.5, hz), col)
		K.sb(h, Vector3(tw, D, PL), Vector3(-hx, D * 0.5, 0), col)
		K.sb(h, Vector3(tw, D, PL), Vector3(hx, D * 0.5, 0), col)
		_paving(h, Vector3.ZERO, PW, PL, K.C_GRASS, "")
		K.out_add(out, "perch", Vector3(0, D + 1.0, -hz))
		return
	# taban: toprak yürüme zemini (ince katı) + yeşil tarhlar
	_paving(h, Vector3.ZERO, PW, PL, Color("8c7a55"), "")
	# duvarlar (kapı: güney duvarı, ortada 3 m)
	K.wall(h, Vector2(-hx - tw * 0.5, -hz), Vector2(hx + tw * 0.5, -hz), D, tw, col, "ashlar_far", [], 0)
	K.wall(h, Vector2(-hx - tw * 0.5, hz), Vector2(hx + tw * 0.5, hz), D, tw, col, "ashlar_far", [[PW * 0.5 + tw * 0.5, 3.2]], 0, 0.0, -1.0, 1.3, 3.0)
	K.wall(h, Vector2(-hx, -hz), Vector2(-hx, hz), D, tw, col, "ashlar_far", [], 0)
	K.wall(h, Vector2(hx, -hz), Vector2(hx, hz), D, tw, col, "ashlar_far", [], 0)
	# kapı üstü taş çerçeve
	K.vb(h, Vector3(4.4, 0.5, tw + 0.2), Vector3(0, 3.1, hz), K.C_STONE)
	# duvar üstü korkuluk: iç ve dış kenarda 1 m; araları 1,4+ yürüme yolu; kapı sütunu yok
	for sg in [-1.0, 1.0]:
		var oz: float = sg * (hz + tw * 0.5 - 0.15)
		var iz: float = sg * (hz - tw * 0.5 + 0.15)
		K.sb(h, Vector3(PW + tw, 1.0, 0.3), Vector3(0, D + 0.5, oz), K.C_STONE, "ashlar")
		K.sb(h, Vector3(PW - tw, 1.0, 0.3), Vector3(0, D + 0.5, iz), K.C_STONE, "ashlar")
		var ox: float = sg * (hx + tw * 0.5 - 0.15)
		var ix: float = sg * (hx - tw * 0.5 + 0.15)
		K.sb(h, Vector3(0.3, 1.0, PL - tw), Vector3(ox, D + 0.5, 0), K.C_STONE, "ashlar")
		K.sb(h, Vector3(0.3, 1.0, PL - tw), Vector3(ix, D + 0.5, 0), K.C_STONE, "ashlar")
	# payandalar (dışta, dik duvara pilastr): görsel-katı, 1,2 m taşar
	var np := maxi(4, int(PW / 14.0))
	for i in np + 1:
		var px := -hx + i * PW / np
		for sg in [-1.0, 1.0]:
			K.sb(h, Vector3(1.4, D * 0.92, 0.8), Vector3(px, D * 0.46, sg * (hz + tw * 0.5 + 0.4)), K.C_STONE_D, "ashlar")
	# tarhlar: tek gövde, çok kutu şekli (tepe 0,18 m); aralar 1,7 m yol
	var bed_w := 1.6
	var pitch_z := 3.3
	var bed_l := minf(14.0, PW * 0.2)
	var pitch_x := bed_l + 1.8
	var body := StaticBody3D.new()
	var cropx: Array = []
	var cropx2: Array = []
	var bedx: Array = []
	var nz := int((PL - 2.0 * tw - 6.0) / pitch_z)
	var nx := int((PW - 2.0 * tw - 6.0) / pitch_x)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1453
	for j in nz:
		for i in nx:
			var cx := -((nx - 1) * pitch_x) * 0.5 + i * pitch_x
			var cz := -((nz - 1) * pitch_z) * 0.5 + j * pitch_z
			# orta alanı kuyu / kulübe için boş bırak
			if absf(cx) < 12.0 and absf(cz) < 8.0:
				continue
			# giriş yolu (güney kapı) boş
			if absf(cx) < bed_l * 0.5 + 1.2 and cz > hz - 12.0:
				continue
			if h != null:
				var cs := CollisionShape3D.new()
				var bs := BoxShape3D.new()
				bs.size = Vector3(bed_l, 0.18, bed_w)
				cs.shape = bs
				cs.position = Vector3(cx, 0.06 + 0.09, cz)
				body.add_child(cs)
			bedx.append(Transform3D(Basis(), Vector3(cx, 0.15, cz)))
			var kind := (i + j * 2) % 3
			var nc := int(bed_l / 0.9)
			for q in nc:
				var qx := cx - bed_l * 0.5 + (q + 0.5) * bed_l / nc
				for rz in [-0.4, 0.4]:
					var jit := rng.randf_range(-0.04, 0.04)
					var tr := Transform3D(Basis().scaled(Vector3(1, 1, 1) * (0.9 + rng.randf() * 0.3)), Vector3(qx + jit, 0.32, cz + rz))
					if kind == 0:
						cropx.append(tr)
					elif kind == 1:
						cropx2.append(Transform3D(Basis(), Vector3(qx, 0.45, cz + rz)))
					else:
						cropx.append(Transform3D(Basis().scaled(Vector3(0.7, 1.0, 0.7)), Vector3(qx, 0.30, cz + rz)))
	if h != null:
		h.add_child(body)
		K.mm(h, K.box_mesh(Vector3(bed_l, 0.18, bed_w)), Color("5e4a2e"), bedx, "")
		var sph := SphereMesh.new()
		sph.radius = 0.28
		sph.height = 0.46
		sph.radial_segments = 6
		sph.rings = 3
		K.mm(h, sph, Color("78a043"), cropx)
		K.mm(h, K.cone_mesh(0.16, 0.7, 5), Color("a8c05a"), cropx2)
	# kuyu çıkrığı
	if h != null:
		K.cy(h, 1.0, 0.9, Vector3(0, 0.45, 0), K.C_STONE, 10, -1.0, "ashlar")
		for sx in [-1.0, 1.0]:
			K.sb(h, Vector3(0.18, 2.2, 0.18), Vector3(sx * 1.1, 1.1, 0), K.C_WOOD_D, "wood")
		K.sb(h, Vector3(2.6, 0.18, 0.18), Vector3(0, 2.25, 0), K.C_WOOD_D, "wood")
		K.cy(h, 0.12, 2.4, Vector3(0, 1.9, 0), K.C_WOOD, 6, -1.0, "", false).rotation_degrees = Vector3(0, 0, 90)
	# bostancı kulübesi (saman çatı), kuzey doğuda: ön yüz kapılı, içi basit
	var hc := Vector2(hx * 0.5, -hz * 0.55)
	K.wall(h, hc + Vector2(-2, -1.8), hc + Vector2(2, -1.8), 2.8, 0.5, K.C_PLASTER, "plaster")
	K.wall(h, hc + Vector2(-2, 1.8), hc + Vector2(2, 1.8), 2.8, 0.5, K.C_PLASTER, "plaster", [[2.0, K.DOOR_W]])
	K.wall(h, hc + Vector2(-2, -1.8), hc + Vector2(-2, 1.8), 2.8, 0.5, K.C_PLASTER, "plaster")
	K.wall(h, hc + Vector2(2, -1.8), hc + Vector2(2, 1.8), 2.8, 0.5, K.C_PLASTER, "plaster")
	K.gable(h, Vector3(hc.x, 2.8, hc.y), 4.9, 5.0, 1.3, "x", Color("c8a85a"), K.C_PLASTER)
	# ağaçlar: incir, kavak
	_tree_round(h, Vector3(-hx * 0.55, 0, hz * 0.4), 4.2, Color("5f8a3c"))
	_tree_round(h, Vector3(hx * 0.3, 0, hz * 0.55), 3.8, Color("6a9444"))
	_tree_cypress(h, Vector3(-hx + 3.0, 0, -hz + 3.0), 6.0)
	_tree_cypress(h, Vector3(-hx + 3.0, 0, -hz + 6.0), 5.0)
	# iç merdiven: doğu duvarının iç yüzünde, duvar boyunca yükselir (güneyden kuzeye); genişlik 1,8
	var n := _nsteps(D)
	var rise := D / n
	var sx0 := hx - tw * 0.5 - 1.0
	for i in n:
		var ht := rise * (i + 1)
		var zc := hz - 8.0 - i * K.STEP_RUN - K.STEP_RUN * 0.5
		K.sb(h, Vector3(2.0, ht, K.STEP_RUN + 0.02), Vector3(sx0, ht * 0.5, zc), K.C_STONE_D, "ashlar")
	var z_top := hz - 8.0 - n * K.STEP_RUN
	K.sb(h, Vector3(2.0, D, 1.4), Vector3(sx0, D * 0.5, z_top - 0.7 + 0.0), K.C_STONE_D, "ashlar")
	K.out_add(out, "climb", [Vector3(sx0, 0.0, hz - 8.0 + 0.6), Vector3(hx - tw * 0.4, D, z_top - 0.6), "basamak"])
	# iç merdiven tepesinden duvar yoluna 1 m'lik sahanlık: duvar üstü ile aynı yükseklikte olduğundan doğrudan geçilir
	# dış merdiven: kuzey duvarına
	var n2 := _nsteps(D)
	var r2 := D / n2
	for i in n2:
		var ht2 := r2 * (i + 1)
		var zc2 := -hz - tw * 0.5 - 0.05 - (n2 - 1 - i + 0.5) * K.STEP_RUN
		K.sb(h, Vector3(1.8, ht2, K.STEP_RUN + 0.02), Vector3(-hx * 0.3, ht2 * 0.5, zc2), K.C_STONE_D, "ashlar")
	K.out_add(out, "climb", [Vector3(-hx * 0.3, 0.0, -hz - tw * 0.5 - n2 * K.STEP_RUN - 0.4), Vector3(-hx * 0.3, D, -hz - tw * 0.5 - 0.1), "basamak"])
	K.out_add(out, "perch", Vector3(0, D + 1.1, -hz))
	K.out_add(out, "perch", Vector3(hx, D + 1.1, 0))


# ---------- PSAMATHİA ----------

static func _house(h: Node3D, c: Vector2, w: float, d: float, ht: float, door_dir: int, col: Color, roof: Color, out: Dictionary, climb := false) -> void:
	var t := 0.45
	var x0 := c.x - w * 0.5
	var x1 := c.x + w * 0.5
	var z0 := c.y - d * 0.5
	var z1 := c.y + d * 0.5
	var dn: Array = [[d * 0.5, K.DOOR_W]]
	var ds: Array = [[w * 0.5, K.DOOR_W]]
	K.wall(h, Vector2(x0, z0), Vector2(x1, z0), ht, t, col, "plaster", ds if door_dir == 0 else [], 1 if door_dir != 0 else 0, 0.0, ht * 0.5, 1.0)
	K.wall(h, Vector2(x0, z1), Vector2(x1, z1), ht, t, col, "plaster", ds if door_dir == 2 else [], 1 if door_dir != 2 else 0, 0.0, ht * 0.5, 1.0)
	K.wall(h, Vector2(x0, z0), Vector2(x0, z1), ht, t, col, "plaster", dn if door_dir == 3 else [], 0)
	K.wall(h, Vector2(x1, z0), Vector2(x1, z1), ht, t, col, "plaster", dn if door_dir == 1 else [], 0)
	var rise := minf(w, d) * 0.32
	K.gable(h, Vector3(c.x, ht, c.y), (d if w >= d else w) + 0.7, (w if w >= d else d) + 0.3, rise, "x" if w >= d else "z", roof, col)
	if h != null:
		var chx := Props.box(h, Vector3(0.6, 1.2, 0.6), Vector3(c.x + w * 0.25, ht + rise * 0.6 + 0.2, c.y), Color("a89478"))
		Props.make_solid(chx)
	if climb:
		var n := maxi(1, ceili(ht / K.CRATE_H))
		var side := 1.0 if door_dir != 2 else -1.0
		K.crates(h, Vector3(c.x - w * 0.25, 0.0, c.y + side * (d * 0.5 + 0.35 + 0.7 * n)), Vector2(0, -side), n, 1.2)
		K.out_add(out, "climb", [Vector3(c.x - w * 0.25, 0.0, c.y + side * (d * 0.5 + 0.35 + 0.7 * n + 0.9)), Vector3(c.x - w * 0.25, ht, c.y + side * (d * 0.5 + 0.2)), "sandik"])
	K.out_add(out, "perch", Vector3(c.x, ht + rise + 0.2, c.y))


static func _b_psamathia(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var s := maxf(k, 0.0)
	var hw := maxf(5.5 * k, 3.6)
	var hd := maxf(4.2 * k, 3.2)
	var ht := maxf(3.4 * k, 2.8)
	# ev yerleşimi: ızgara, ev aralığı 2,4 m
	var gap := maxf(5.0 * k, 2.4)
	var cols := [Color("e4d3b0"), Color("d8c29a"), Color("ceb892"), Color("e9dcc0"), Color("d1b48a"), Color("dbc8a0")]
	var roofs := [K.C_TILE, Color("a8492f"), Color("9a5a3a"), K.C_TILE, Color("c05d3f"), Color("a8492f")]
	if lod == 2:
		for i in 6:
			var gx := (i % 3 - 1) * (hw + gap)
			var gz := (i / 3 - 0.5) * (hd + gap)
			K.silhouette(h.get_child(0) if false else h, Vector3(hw, ht, hd), cols[i], roofs[i], hd * 0.3) if false else null
			if h != null:
				var n := Node3D.new()
				n.position = Vector3(gx, 0, gz)
				h.add_child(n)
				K.silhouette(n, Vector3(hw, ht, hd), cols[i], roofs[i], hd * 0.3)
		K.out_add(out, "perch", Vector3(0, ht + hd * 0.3 + 0.2, 0))
		return
	for i in 6:
		var gx := (i % 3 - 1) * (hw + gap)
		var gz := (i / 3 - 0.5) * (hd + gap)
		_house(h, Vector2(gx, gz), hw, hd, ht, 0 if i >= 3 else 2, cols[i], roofs[i], out, i == 4 or i == 1)
	# orta alan: kuyu, ağ kurutma direkleri, kayık, amfora yığını
	var well_p := Vector3(0, 0, 0)
	if h != null:
		K.cy(h, 0.8, 0.9, well_p + Vector3(0, 0.45, 0), K.C_STONE, 10, -1.0, "ashlar")
		for sx in [-1.0, 1.0]:
			K.sb(h, Vector3(0.14, 2.0, 0.14), well_p + Vector3(sx * 0.9, 1.0, 0), K.C_WOOD_D, "wood")
		K.sb(h, Vector3(2.0, 0.14, 0.14), well_p + Vector3(0, 2.0, 0), K.C_WOOD_D, "wood")
	# ağ direkleri (güney)
	var nz := (hd + gap) * 1.5 + hd * 0.5 + 3.0
	if h != null:
		for sx in [-1.0, 1.0]:
			K.sb(h, Vector3(0.16, 2.6, 0.16), Vector3(sx * 3.0, 1.3, nz), K.C_WOOD_D, "wood")
		var net := Props.box(h, Vector3(6.0, 1.7, 0.03), Vector3(0, 1.6, nz), Color(0.35, 0.3, 0.22, 0.75))
		K.sb(h, Vector3(6.2, 0.14, 0.14), Vector3(0, 2.55, nz), K.C_WOOD_D, "wood")
		net = net
		# kayık (kızakta): gövde üç parça, katı
		var bz := nz + 3.4
		K.sb(h, Vector3(4.6, 0.5, 1.5), Vector3(0, 0.55, bz), Color("8b5a2b"), "wood")
		K.sb(h, Vector3(3.8, 0.4, 1.9), Vector3(0, 0.75, bz), Color("a0693a"), "wood")
		K.sb(h, Vector3(0.3, 0.9, 1.2), Vector3(2.4, 0.8, bz), Color("8b5a2b"), "wood")
		K.sb(h, Vector3(5.0, 0.3, 0.9), Vector3(0, 0.15, bz), K.C_WOOD_D, "wood")
		# amfora
		for q in 3:
			K.cy(h, 0.28, 0.9, Vector3(-4.2 + q * 0.7, 0.45, nz + 0.2), Color("b0733f"), 8, 0.18)
		_tree_round(h, Vector3(-hw - gap - 1.0, 0, nz - 2.0), 3.8, Color("7a8f4a"))
	var rx := (hw + gap) * 1.5 + hw * 0.5 + 2.0
	# çit (örgü, 1,0 m) kuzey ve doğu kenar
	if h != null:
		K.sb(h, Vector3(0.12, 1.0, hd * 1.0), Vector3(rx, 0.5, -((hd + gap) * 0.5) - 0.0), K.C_WOOD, "wood")
		K.sb(h, Vector3(0.12, 1.0, hd), Vector3(rx, 0.5, (hd + gap) * 0.5), K.C_WOOD, "wood")
	K.out_add(out, "perch", Vector3(0, 2.2, nz))


# ---------- ALTIN KAPI KALINTISI ----------

static func _b_altinkapi(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var GW := maxf(20.0 * k, 12.0)
	var GH := maxf(15.0 * k, 7.0)
	var GT := maxf(6.0 * k, 4.0)
	var TW := maxf(9.0 * k, 5.0)
	var marble := K.C_MARBLE
	var rub := Color("a39275")
	if lod == 2:
		K.sb(h, Vector3(GW, GH, GT), Vector3(0, GH * 0.5, 0), marble)
		for sx in [-1.0, 1.0]:
			K.sb(h, Vector3(TW, GH * 0.7, TW), Vector3(sx * (GW * 0.5 + TW * 0.5), GH * 0.35, 0), rub)
		K.out_add(out, "perch", Vector3(0, GH + 0.3, 0))
		return
	var oh := minf(GH - 1.5, 5.4)
	var ow := 3.6
	var hz := GT * 0.5
	# kapı bloğu: üç geçit (orta geniş, yanlar dar), kuzey-güney yönünde geçilir
	var doors := [[GW * 0.5, ow + 0.8], [GW * 0.5 - (ow + 2.4), ow - 0.6], [GW * 0.5 + (ow + 2.4), ow - 0.6]]
	K.wall(h, Vector2(-GW * 0.5, 0), Vector2(GW * 0.5, 0), GH, GT, marble, "marble", doors, 0, 0.0, -1.0, 1.3, oh)
	# kemer kabartması: mermer kuşaklar ve koyu iç
	if h != null:
		for dr in doors:
			var cxx: float = -GW * 0.5 + dr[0]
			for sz in [-1.0, 1.0]:
				var arch := Props.ball(h, dr[1] * 0.5, Vector3(cxx, oh, sz * (hz + 0.03)), K.C_STONE_D, Vector3(1.0, 0.45, 0.06), 12)
				arch = arch
		# alınlık sırası: mermer kuşak
		K.vb(h, Vector3(GW + 0.3, 0.4, GT + 0.3), Vector3(0, GH - 0.2, 0), K.C_STONE)
	# parapet (yürüme yolu GT-1,2) iki kenarda
	for sz in [-1.0, 1.0]:
		K.sb(h, Vector3(GW, 1.0, 0.3), Vector3(0, GH + 0.5, sz * (hz - 0.15)), K.C_STONE, "ashlar")
	# yan kuleler: yıkık, farklı yükseklikte moloz katılar
	var th := [GH * 0.72, GH * 0.5]
	var tx := [-1.0, 1.0]
	for i in 2:
		var cx: float = tx[i] * (GW * 0.5 + TW * 0.5)
		K.sb(h, Vector3(TW, th[i], TW), Vector3(cx, th[i] * 0.5, 0), rub, "rubble")
		# yıkık tepe: kırık duvar dişleri
		if h != null:
			for q in 3:
				var ox := -TW * 0.5 + (q + 0.5) * TW / 3.0
				var hh := 0.8 + ((q * 7 + i * 3) % 4) * 0.45
				K.sb(h, Vector3(TW / 3.0 - 0.1, hh, 0.9), Vector3(cx + ox, th[i] + hh * 0.5, -TW * 0.5 + 0.55), rub.darkened(0.08), "rubble")
		# moloz yamacı (basamaklı), tırmanma yolu
	var cxl: float = -(GW * 0.5 + TW * 0.5)
	var h1: float = th[0]
	var n := _nsteps(h1)
	var r1: float = h1 / n
	for i in n:
		var ht: float = r1 * (i + 1)
		var zc := TW * 0.5 + 0.05 + (n - 1 - i + 0.5) * K.STEP_RUN
		K.sb(h, Vector3(2.0, ht, K.STEP_RUN + 0.02), Vector3(cxl, ht * 0.5, zc), rub.darkened(0.1), "rubble")
	K.out_add(out, "climb", [Vector3(cxl, 0.0, TW * 0.5 + 0.05 + n * K.STEP_RUN + 0.4), Vector3(cxl, h1, TW * 0.5 + 0.2), "basamak"])
	# kule tepesinden kapı üstüne: sandık basamakları (kapı üstü GH)
	var hd: float = GH - h1
	var n2 := maxi(1, ceili(hd / K.CRATE_H))
	var xr: float = cxl + TW * 0.5
	K.crates(h, Vector3(xr + 0.35 + 0.7 * n2 - 0.0, h1, 0.0), Vector2(-1, 0), n2, 1.6)
	K.out_add(out, "climb", [Vector3(xr + 0.35 + 0.7 * n2 + 0.9, h1, 0.0), Vector3(-GW * 0.5 + 0.2, GH, 0.0), "sandik"])
	# bitki ve moloz
	_tree_round(h, Vector3(GW * 0.5 + TW + 3.0, 0, 3.0), 4.0, Color("6a8a3c"))
	if h != null:
		for q in 6:
			K.sb(h, Vector3(1.0 + (q % 3) * 0.5, 0.4 + (q % 2) * 0.3, 0.8), Vector3(-GW * 0.5 - 3.0 + q * 1.6, 0.25, GT * 0.5 + TW + 1.0 + (q % 3)), rub, "rubble")
	K.out_add(out, "perch", Vector3(0, GH + 0.15, 0))
	K.out_add(out, "perch", Vector3(GW * 0.5 + TW * 0.5, th[1] + 0.2, 0))


# ---------- DEĞİRMEN, KÖPRÜ, BAĞ ----------

static func _water(h: Node3D, c: Vector3, len: float, w: float, along_x: bool) -> void:
	if h == null:
		return
	var sz := Vector3(len, 0.02, w) if along_x else Vector3(w, 0.02, len)
	var m := Props.box(h, sz, Vector3(c.x, 0.04, c.z), K.C_WATER)
	m = m
	# taş yatak kenarları (alçak, katı)
	for sg in [-1.0, 1.0]:
		var o: float = (w * 0.5 + 0.2) * sg
		var bs := Vector3(len, 0.22, 0.4) if along_x else Vector3(0.4, 0.22, len)
		var bp := Vector3(c.x, 0.11, c.z + o) if along_x else Vector3(c.x + o, 0.11, c.z)
		K.sb(h, bs, bp, Color("9b8c70"), "rubble")


static func _b_degirmen(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var w := maxf(7.0 * k, 4.6)
	var d := maxf(6.0 * k, 4.2)
	var ht := maxf(5.0 * k, 3.4)
	var sw := 3.2
	if lod == 2:
		K.silhouette(h, Vector3(w, ht, d), Color("cdbb96"), K.C_TILE, d * 0.3)
		K.out_add(out, "perch", Vector3(0, ht + d * 0.3 + 0.3, 0))
		return
	_water(h, Vector3(0, 0, d * 0.5 + sw * 0.5 + 0.9), 24.0, sw, true)
	# değirmen binası dere kıyısında
	K.wall(h, Vector2(-w * 0.5, -d * 0.5), Vector2(w * 0.5, -d * 0.5), ht, 0.5, Color("cdbb96"), "ashlar", [], 1, 0.0, ht * 0.5, 1.0)
	K.wall(h, Vector2(-w * 0.5, d * 0.5), Vector2(w * 0.5, d * 0.5), ht, 0.5, Color("cdbb96"), "ashlar", [], 1, 0.0, ht * 0.5, 1.0)
	K.wall(h, Vector2(-w * 0.5, -d * 0.5), Vector2(-w * 0.5, d * 0.5), ht, 0.5, Color("cdbb96"), "ashlar", [[d * 0.5, K.DOOR_W]])
	K.wall(h, Vector2(w * 0.5, -d * 0.5), Vector2(w * 0.5, d * 0.5), ht, 0.5, Color("cdbb96"), "ashlar")
	K.gable(h, Vector3(0, ht, 0), d + 0.7, w + 0.3, d * 0.3, "x", K.C_TILE, Color("cdbb96"))
	# su çarkı: güney yüze bitişik (dere kıyısı), dikey disk
	var wr := 1.5
	var wheel_z := d * 0.5 + 0.45 + 0.0
	if h != null:
		var disc := Props.cyl(h, wr, 0.8, Vector3(0, wr + 0.05, wheel_z + 0.0), K.C_WOOD_D, Vector3(90, 0, 0), 14)
		Props.set_pattern(disc, K.C_WOOD_D, "wood")
		Props.make_solid(disc, 0.95)
		for i in 8:
			var a := TAU * i / 8.0
			var pd := Props.box(h, Vector3(0.25, 0.4, 0.9), Vector3(sin(a) * wr, wr + 0.05 + cos(a) * wr, wheel_z), K.C_WOOD, Vector3(rad_to_deg(a), 0, 0) * 0.0 + Vector3(0, 0, -rad_to_deg(a)))
			pd = pd
	# gerisinde taş yığını (çuvallar)
	for q in 3:
		K.sb(h, Vector3(0.7, 0.6, 0.5), Vector3(-w * 0.5 - 1.2, 0.3 + q * 0.0, -d * 0.2 + q * 0.7), Color("d8c9a4"))
	# çatıya sandık basamağı
	var n := maxi(1, ceili(ht / K.CRATE_H))
	K.crates(h, Vector3(w * 0.25, 0.0, -d * 0.5 - 0.35 - 0.7 * n), Vector2(0, 1), n, 1.4)
	K.out_add(out, "climb", [Vector3(w * 0.25, 0.0, -d * 0.5 - 0.35 - 0.7 * n - 0.9), Vector3(w * 0.25, ht, -d * 0.5 - 0.2), "sandik"])
	K.out_add(out, "perch", Vector3(0, ht + d * 0.3 + 0.15, 0))


static func _b_kopru(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var span := maxf(8.0 * k, 5.0)
	var dh := 1.6
	var runL := dh / tan(deg_to_rad(14.0))
	var w := 3.4
	if lod == 2:
		K.sb(h, Vector3(w, dh, span), Vector3(0, dh * 0.5, 0), Color("b8a888"))
		K.out_add(out, "perch", Vector3(0, dh + 0.3, 0))
		return
	_water(h, Vector3(0, 0, 0), 22.0, 2.6, true)
	# gövde: tam dolu taş blok (altı kör kemerli), üstü yürünür
	K.sb(h, Vector3(w, dh, span), Vector3(0, dh * 0.5, 0), Color("b8a888"), "ashlar")
	for sg in [-1.0, 1.0]:
		K.sb(h, Vector3(0.35, 1.0, span + 0.0), Vector3(sg * (w * 0.5 - 0.18), dh + 0.5, 0), Color("c4b494"), "ashlar")
	# kör kemerler (görsel): iki yan yüzde
	if h != null:
		for sg in [-1.0, 1.0]:
			var ar := Props.ball(h, 1.1, Vector3(sg * (w * 0.5 + 0.02), 0.5, 0), K.C_DARK, Vector3(0.05, 0.8, 1.0), 10)
			ar = ar
			K.vb(h, Vector3(0.05, 0.5, 2.2), Vector3(sg * (w * 0.5 + 0.02), 0.25, 0), K.C_DARK)
	# rampalar (≈ 14°)
	for sg in [-1.0, 1.0]:
		var a := Vector3(0, dh, sg * (span * 0.5))
		var b := Vector3(0, 0.0, sg * (span * 0.5 + runL))
		if h != null:
			var rp := Props.ramp(h, a, b, w, Color("b8a888"))
			Props.set_pattern(rp, Color("b8a888"), "cobble")
		K.out_add(out, "climb", [Vector3(0, 0.0, sg * (span * 0.5 + runL + 0.6)), Vector3(0, dh, sg * (span * 0.5 - 0.2)), "basamak"])
		# korkuluk rampa boyunca (görsel+katı eğik)
		for sx in [-1.0, 1.0]:
			if h != null:
				var mid := (a + b) * 0.5 + Vector3(sx * (w * 0.5 - 0.18), 0.5, 0)
				K.sb(h, Vector3(0.35, 1.0, a.distance_to(b)), mid, Color("c4b494"), "ashlar", Vector3(-sg * rad_to_deg(atan2(dh, runL)) * -1.0, 0, 0))
	K.out_add(out, "perch", Vector3(0, dh + 1.15, 0))


static func _b_bag(h: Node3D, k: float, lod: int, out: Dictionary) -> void:
	var PW := maxf(30.0 * k, 16.0)
	var PL := maxf(36.0 * k, 18.0)
	var hx := PW * 0.5
	var hz := PL * 0.5
	if lod == 2:
		_paving(h, Vector3.ZERO, PW, PL, Color("7e9a4a"), "")
		K.out_add(out, "perch", Vector3(0, 2.6, 0))
		return
	_paving(h, Vector3.ZERO, PW, PL, Color("8f9c58"), "")
	# kuru taş duvar (1 m), güney kapı 2,4 m
	K.wall(h, Vector2(-hx, -hz), Vector2(hx, -hz), 1.0, 0.5, Color("a39578"), "rubble")
	K.wall(h, Vector2(-hx, hz), Vector2(hx, hz), 1.0, 0.5, Color("a39578"), "rubble", [[hx, 2.4]])
	K.wall(h, Vector2(-hx, -hz), Vector2(-hx, hz), 1.0, 0.5, Color("a39578"), "rubble")
	K.wall(h, Vector2(hx, -hz), Vector2(hx, hz), 1.0, 0.5, Color("a39578"), "rubble")
	# omcalar: sıralar x yönünde, aralık 1,7 m; kütük + kazık MultiMesh, her sıra tek katı çubuk (0,5 × 1,1)
	var pitch := 2.3
	var nrows := int((PL - 8.0) / pitch)
	var stems: Array = []
	var posts: Array = []
	var leaves: Array = []
	for j in nrows:
		var z := -hz + 4.0 + j * pitch
		if z > hz - 7.0 and absf(z) < 0.0:
			continue
		K.sb(h, Vector3(PW - 8.0, 1.1, 0.5), Vector3(0, 0.55, z), Color("6d8a3a"))
		var np := int((PW - 8.0) / 3.0)
		for i in np + 1:
			var x := -(PW - 8.0) * 0.5 + i * (PW - 8.0) / np
			posts.append(Transform3D(Basis(), Vector3(x, 0.75, z)))
			stems.append(Transform3D(Basis(), Vector3(x + 1.5, 0.35, z)))
			leaves.append(Transform3D(Basis().scaled(Vector3(1.6, 0.7, 0.9)), Vector3(x + 0.7, 1.0, z)))
	if h != null:
		K.mm(h, K.box_mesh(Vector3(0.1, 1.5, 0.1)), K.C_WOOD_D, posts)
		var sp := SphereMesh.new()
		sp.radius = 0.45
		sp.height = 0.7
		sp.radial_segments = 6
		sp.rings = 3
		K.mm(h, sp, Color("4f7a2a"), leaves)
		K.mm(h, K.box_mesh(Vector3(0.18, 0.7, 0.18)), Color("5a4630"), stems)
	# bekçi kulübesi (güney doğu): taş, düz katı çatı 2,6 m
	var hc := Vector2(hx - 3.0, hz - 3.0)
	K.wall(h, hc + Vector2(-1.6, -1.6), hc + Vector2(1.6, -1.6), 2.6, 0.45, Color("c9b690"), "rubble")
	K.wall(h, hc + Vector2(-1.6, 1.6), hc + Vector2(1.6, 1.6), 2.6, 0.45, Color("c9b690"), "rubble")
	K.wall(h, hc + Vector2(-1.6, -1.6), hc + Vector2(-1.6, 1.6), 2.6, 0.45, Color("c9b690"), "rubble", [[1.6, K.DOOR_W]])
	K.wall(h, hc + Vector2(1.6, -1.6), hc + Vector2(1.6, 1.6), 2.6, 0.45, Color("c9b690"), "rubble")
	K.gable(h, Vector3(hc.x, 2.6, hc.y), 3.9, 4.0, 1.0, "z", Color("c8a85a"), Color("c9b690"))
	var n := maxi(1, ceili(2.6 / K.CRATE_H))
	K.crates(h, Vector3(hc.x - 2.3 - 0.7 * n - 0.35, 0.0, hc.y), Vector2(1, 0), n, 1.4)
	K.out_add(out, "climb", [Vector3(hc.x - 2.3 - 0.7 * n - 1.3, 0.0, hc.y), Vector3(hc.x - 1.8, 2.6, hc.y), "sandik"])
	_tree_round(h, Vector3(-hx + 2.0, 0, -hz + 2.0), 4.0, Color("6f8f3f"))
	K.out_add(out, "perch", Vector3(hc.x, 3.7, hc.y))
