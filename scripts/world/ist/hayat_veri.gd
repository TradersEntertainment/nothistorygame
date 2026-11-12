class_name IstHayatVeri
extends RefCounted
## İstanbul v2 yaşam katmanı VERİSİ: sokak ağından (IstSokak), mahalle türlerinden (IstGeo.mahalle) ve yerlerden kayıt üretir.
## Düğüm kurmaz; IstHayat.attach kayıtları IstHayatKatman görünümlerine döker. Kişiler çarpışmasızdır.
## Tüm insanlar IstGeo.h üstünde yürür; yürüyenler SOKAK/MESE hücrelerinde (IstSokak hücre 1) kalır, duranlar boş hücrede.

const RISE := 1.7                 # IstEvler.RISE
const OVER := 0.7                 # IstEvler.OVER
const GF := 3.0
const UF := 2.7

# insan rolleri → [tunik dizinleri], [başlık dizinleri]
const R_ERKEK := [[0, 1, 2, 3, 4, 5, 7, 14, 12, 15], [0, 1, 3, 6, 7]]
const R_KADIN := [[3, 5, 12, 13, 15, 6, 4], [1, 6, 2, 7]]
const R_KEIS := [[6, 7, 6], [2, 2]]
const R_BIZ_ASKER := [[9, 8, 10, 15], [4, 4, 5]]
const R_OSM_ASKER := [[11, 9, 12, 11, 5], [1, 5, 1, 6]]
const R_HAMAL := [[14, 0, 7, 8], [0, 3]]
const R_BALIKCI := [[12, 4, 15, 7], [3, 0]]
const R_PAPAZ := [[13, 11, 6], [3, 2]]
const R_CIFTCI := [[0, 14, 4, 5], [3, 6, 0]]

var sokak: IstSokak
var gece := false
var rng := RandomNumberGenerator.new()
var K := {}                              # ad → IstHayatKatman
var ist := {}                            # istatistik
var _mc := {}


func _init() -> void:
	rng.seed = 1453
	K["insan"] = IstHayatKatman.new("insan", true, true)
	K["hayvan"] = IstHayatKatman.new("hayvan", true, true)
	K["yuklu"] = IstHayatKatman.new("yuklu", true, true)
	K["tavuk"] = IstHayatKatman.new("tavuk", true, true)
	K["marti"] = IstHayatKatman.new("marti", true, true)
	K["guvercin"] = IstHayatKatman.new("guvercin", true, true)
	K["duman"] = IstHayatKatman.new("duman", false, true)
	K["bez"] = IstHayatKatman.new("bez", true, true)
	K["kutu"] = IstHayatKatman.new("kutu", true, false)
	K["cadir"] = IstHayatKatman.new("cadir", true, false)
	K["pencere"] = IstHayatKatman.new("pencere", true, false)
	K["alev"] = IstHayatKatman.new("alev", false, false)
	K["parilti"] = IstHayatKatman.new("parilti", false, false)


# ---------------------------------------------------------------- yardımcılar

func _mah(p: Vector2) -> Dictionary:
	var key := Vector2i(floori(p.x / 24.0), floori(p.y / 24.0))
	if _mc.has(key):
		return _mc[key]
	var m := IstGeo.mahalle(p.x, p.y)
	_mc[key] = m
	return m


func _h(p: Vector2) -> float:
	return IstGeo.h(p.x, p.y)


func _cell(p: Vector2) -> int:
	return sokak.cell(p.x, p.y) if sokak != null else 0


static func _yaw(d: Vector2) -> float:
	return atan2(-d.x, -d.y)


func _pick(rol: Array) -> Array:
	var t: Array = rol[0]
	var h: Array = rol[1]
	return [t[rng.randi() % t.size()], h[rng.randi() % h.size()]]


## beh: 0 yürü, 1 dur, 2 çalış, 3 eğil, 4 yük, 5 otur
func insan(p0: Vector2, d: Vector2, L: float, spd: float, beh: int, rol: Array, alet := 0, olcek := 1.0, ph := -1.0, y0 := -1000.0) -> void:
	var pk := _pick(rol)
	var ya := _h(p0) if y0 < -999.0 else y0
	var slope := 0.0
	if L > 0.05:
		slope = clampf((_h(p0 + d * L) - ya) / L, -0.44, 0.44) if y0 < -999.0 else 0.0
	var phase := rng.randf() * 0.99 if ph < 0.0 else ph
	var b := Basis(Vector3.UP, _yaw(d)).scaled(Vector3.ONE * olcek)
	var cx := float(pk[0]) + 16.0 * float(pk[1]) + phase
	var cw := float(beh + 8 * alet) + 0.5 + slope
	K["insan"].add(Transform3D(b, Vector3(p0.x, ya + 0.02, p0.y)), Color.WHITE, Color(cx, L, spd, cw))


func hayvan(p0: Vector2, d: Vector2, L: float, spd: float, beh: int, renk: int, olcek: float, yuklu := false, ph := -1.0, y0 := -1000.0) -> void:
	var ya := _h(p0) if y0 < -999.0 else y0
	var slope := 0.0
	if L > 0.05 and y0 < -999.0:
		slope = clampf((_h(p0 + d * L) - ya) / L, -0.44, 0.44)
	var b := Basis(Vector3.UP, _yaw(d)).scaled(Vector3.ONE * olcek)
	K["yuklu" if yuklu else "hayvan"].add(Transform3D(b, Vector3(p0.x, ya + 0.02, p0.y)), Color.WHITE,
		Color(float(renk) + (rng.randf() * 0.99 if ph < 0.0 else ph), L, spd, float(beh) + 0.5 + slope))


func tavuk(p0: Vector2, d: Vector2, renk: int) -> void:
	var b := Basis(Vector3.UP, _yaw(d))
	K["tavuk"].add(Transform3D(b, Vector3(p0.x, _h(p0) + 0.02, p0.y)), Color.WHITE,
		Color(float(renk) + rng.randf() * 0.99, 0.0, 0.0, 0.5))


func kutu(pos: Vector3, boyut: Vector3, yaw: float, renk: Color, egim := Vector3.ZERO) -> void:
	var b := Basis.from_euler(Vector3(egim.x, yaw, egim.z)).scaled(boyut)
	K["kutu"].add(Transform3D(b, pos), renk)


func duman(pos: Vector3, tur: int, boy := 1.0) -> void:
	var rise := 11.0 * boy if tur == 0 else (17.0 * boy if tur == 1 else 20.0 * boy)
	var sz := 1.4 * boy if tur == 0 else (2.4 * boy if tur == 1 else 3.0 * boy)
	var per := 9.0 + rng.randf() * 3.0
	var ph0 := rng.randf()
	for i in 4:
		K["duman"].add(Transform3D(Basis.from_scale(Vector3(sz, sz, 1)), pos), Color.WHITE, Color(fposmod(ph0 + i * 0.25, 1.0), rise, per, float(tur)))


func alev(pos: Vector3, w: float, h: float, hale := 0.0) -> void:
	K["alev"].add(Transform3D(Basis.from_scale(Vector3(w, h, w)), pos))
	if hale > 0.0:
		K["parilti"].add(Transform3D(Basis.from_scale(Vector3.ONE * hale), pos + Vector3(0, h * 0.4, 0)))


## Sancak: direk (kutu) + bez. yer: direk dibi, boy: direk boyu
func sancak(yer: Vector3, yaw: float, boy: float, a: int, b: int, desen: int, en := 3.0, yuk := 2.0) -> void:
	kutu(yer + Vector3(0, boy * 0.5, 0), Vector3(0.14, boy, 0.14), 0.0, Color(0.34, 0.26, 0.18))
	kutu(yer + Vector3(0, boy + 0.1, 0), Vector3(0.24, 0.24, 0.24), 0.0, Color(0.85, 0.7, 0.25))
	var r := Vector3(cos(yaw), 0, -sin(yaw))
	var bs := Basis(Vector3.UP, yaw).scaled(Vector3(en, yuk, 1.0))
	K["bez"].add(Transform3D(bs, yer + Vector3(0, boy - 0.05, 0) + r * (en * 0.5 + 0.07)), Color.WHITE, Color(a, b, desen, 0))


# ---------------------------------------------------------------- ana giriş

func uret(sokak_: IstSokak, gece_: bool) -> void:
	sokak = sokak_
	gece = gece_
	var t0 := Time.get_ticks_msec()
	if sokak != null:
		_sokak_yuruyusu()
		_evler()
		_meydanlar()
		_doku()
		_alay()
	_surlar()
	_ordugah()
	_siginmacilar()
	_manastirlar()
	_limanlar()
	_kuslar()
	for k: String in K:
		ist[k] = (K[k] as IstHayatKatman).n
	ist["ms"] = Time.get_ticks_msec() - t0


# ---------------------------------------------------------------- sokaklar

func _adim(tur: String) -> float:
	match tur:
		"carsi": return 4.0
		"liman": return 5.0
		"sik": return 8.5
		"seyrek": return 22.0
		"sur_dibi": return 40.0
	return 70.0


func _rol_sec(tur: String) -> Array:
	var r := rng.randf()
	if tur == "carsi":
		if r < 0.45: return R_ERKEK
		if r < 0.7: return R_KADIN
		if r < 0.85: return R_HAMAL
		if r < 0.92: return R_PAPAZ
		return R_KEIS
	if tur == "liman":
		if r < 0.5: return R_HAMAL
		if r < 0.7: return R_BALIKCI
		if r < 0.85: return R_ERKEK
		return R_KADIN
	if r < 0.55: return R_ERKEK
	if r < 0.85: return R_KADIN
	if r < 0.93: return R_KEIS
	return R_CIFTCI


func _sokak_yuruyusu() -> void:
	var n_y := 0
	for st: Dictionary in sokak.streets:
		var pts: PackedVector2Array = st["pts"]
		var w := float(st["w"])
		var stur := String(st["tur"])
		for i in pts.size() - 1:
			var a := pts[i]
			var b := pts[i + 1]
			var seg := a.distance_to(b)
			if seg < 4.0:
				continue
			var d := (b - a) / seg
			var perp := Vector2(-d.y, d.x)
			var s := rng.randf() * 4.0
			while s < seg - 3.0:
				var q := a + d * s
				var m := _mah(q)
				var tur := String(m["tur"])
				var step := _adim(tur) * (0.45 if stur == "mese" else 1.0) * rng.randf_range(0.6, 1.4)
				s += step
				if tur == "kir" or tur == "bostan" and rng.randf() < 0.6:
					continue
				var L := minf(rng.randf_range(6.0, 26.0), seg - s - 0.5)
				if L < 3.0:
					continue
				var half := maxf(w * 0.5 - 1.0, 0.3)
				var off := rng.randf_range(-1.0, 1.0) * half
				var p0 := a + d * (s - step * 0.0) + perp * off
				var p1 := p0 + d * L
				ist["aday"] = int(ist.get("aday", 0)) + 1
				if _cell(p0) != 1 or _cell(p1) != 1 or _cell((p0 + p1) * 0.5) != 1:
					ist["ret_hucre"] = int(ist.get("ret_hucre", 0)) + 1
					continue
				var dd := d
				if rng.randf() < 0.5:
					p0 = p1
					dd = -d
				var r := rng.randf()
				var rol := _rol_sec(tur)
				var olcek := rng.randf_range(0.94, 1.06)
				if rng.randf() < 0.1:
					olcek = rng.randf_range(0.6, 0.78)
					rol = R_ERKEK
				var spd := rng.randf_range(0.9, 1.5)
				if stur == "mese" and rng.randf() < 0.06 and (tur == "carsi" or tur == "sik"):
					# Mese'de eşek kervanı / at
					var pq := rng.randf() * 0.99
					if rng.randf() < 0.6:
						hayvan(p0, dd, L, 1.1, 0, rng.randi() % 7, 1.0, true, pq)
						insan(p0 + dd * (-1.8), dd, L, 1.1, 0, R_HAMAL, 0, 1.0, pq)
					else:
						hayvan(p0, dd, L, 1.6, 0, rng.randi() % 8, 1.12, false, pq)
						insan(p0 + dd * (-1.7), dd, L, 1.6, 0, R_ERKEK, 0, 1.0, pq)
					n_y += 2
					continue
				if tur == "liman" and r < 0.25:
					insan(p0, dd, L, 0.9, 4, R_HAMAL, 0, olcek)
				elif r < 0.12 and (tur == "carsi" or tur == "sik"):
					# dükkâncı/satıcı kapı önünde durur
					var sd := signf(rng.randf() - 0.5)
					var pe := p0 + perp * sd * half
					if _cell(pe) == 1:
						insan(pe, -perp * sd, 0.0, 0.0, 1, rol, 0, olcek)
				elif r < 0.17:
					hayvan(p0, dd, L, rng.randf_range(0.9, 1.4), 0, rng.randi() % 8, rng.randf_range(0.34, 0.42))      # sokak köpeği
				elif r < 0.2 and tur != "carsi":
					insan(p0, dd, L, spd, 4, R_HAMAL, 0, olcek)
				else:
					insan(p0, dd, L, spd, 0, rol, 0, olcek)
				n_y += 1
	ist["yuruyen"] = n_y


# ---------------------------------------------------------------- evler: baca, duman, çamaşır, gece pencere/kandil, tavuk

func _evler() -> void:
	var nb := 0
	var nd := 0
	var rr := RandomNumberGenerator.new()
	rr.seed = 77
	for h: Dictionary in sokak.houses:
		var v := int(h["v"])
		var dm := IstEvler.dims(v)
		var c: Vector2 = h["c"]
		var yaw := float(h["yaw"])
		var fr: Vector2 = h["on"]
		var y := IstGeo.h(fr.x, fr.y) - 0.04
		var bas := Basis(Vector3.UP, yaw)
		var o3 := Vector3(c.x, y, c.y)
		var tur := String(_mah(c)["tur"])
		var pd := 0.22
		match tur:
			"carsi": pd = 0.2
			"sik", "liman": pd = 0.24
			"seyrek": pd = 0.3
			"bostan", "harabe", "sur_dibi": pd = 0.12
		if gece:
			pd *= 1.3
		var L := dm.x
		var H := dm.y
		var D := dm.z
		var sg := -1.0 if rr.randf() < 0.5 else 1.0
		var cl := Vector3(sg * L * rr.randf_range(0.18, 0.34), H + RISE * 0.45 + 0.55, -D * 0.2)
		if rr.randf() < pd:
			# evin kendi bacasına ek, dumanı olan ikinci baca (sırtın öbür ucunda)
			var cp := o3 + bas * cl
			kutu(cp, Vector3(0.55, 1.5, 0.55), yaw, Color(0.62, 0.52, 0.44) if rr.randf() < 0.5 else Color(0.66, 0.4, 0.3))
			nb += 1
			duman(cp + Vector3(0, 0.95, 0), 0, rr.randf_range(0.8, 1.15))
			nd += 1
		# fırın (çarşı)
		if tur == "carsi" and rr.randf() < 0.035:
			var cp := o3 + bas * Vector3(0, H + RISE * 0.6 + 0.9, -D * 0.1)
			kutu(cp, Vector3(0.9, 2.0, 0.9), yaw, Color(0.7, 0.52, 0.4))
			duman(cp + Vector3(0, 1.3, 0), 1, 1.0)
			var fp := o3 + bas * Vector3(L * 0.3, 1.0, D * 0.5 + 0.5)
			alev(fp, 0.5, 0.8, 2.2)
		elif (tur == "carsi" or tur == "liman") and rr.randf() < 0.02:
			# demirci: ocak ateşi + kapı önünde çekiçleyen usta
			var cp := o3 + bas * Vector3(-L * 0.3, H + RISE * 0.5 + 0.8, -D * 0.2)
			kutu(cp, Vector3(0.8, 1.8, 0.8), yaw, Color(0.32, 0.28, 0.26))
			duman(cp + Vector3(0, 1.1, 0), 2, 1.0)
			var fw := o3 + bas * Vector3(-L * 0.3, 0.9, D * 0.5 + 0.7)
			alev(fw, 0.55, 0.85, 2.4)
			# usta ocağın yanında, sokağa dönük değil ocağa dönük
			var pu := Vector2(fw.x, fw.z) + Vector2(cos(yaw), -sin(yaw)) * 1.0 + Vector2(sin(yaw), cos(yaw)) * 0.6
			insan(pu, Vector2(-cos(yaw), sin(yaw)), 0.0, 0.0, 2, R_HAMAL, 0, 1.0, -1.0, y + 0.0)
		# ev önünde insan: sokağa çıkan, kapıda duran ya da kısa yürüyen
		var pp := 0.0
		match tur:
			"carsi": pp = 0.3
			"liman": pp = 0.22
			"sik": pp = 0.14
			"seyrek": pp = 0.07
			"bostan", "sur_dibi", "harabe": pp = 0.03
		if rr.randf() < pp:
			var out := (fr - c).normalized()
			var tg := Vector2(out.y, -out.x)
			var q := fr + out * rng.randf_range(0.9, 2.4) + tg * rng.randf_range(-L * 0.35, L * 0.35)
			if _cell(q) in [0, 1]:
				var rr2 := rng.randf()
				var rol := _rol_sec(tur)
				if rr2 < 0.5:
					insan(q, -out if rng.randf() < 0.6 else tg, 0.0, 0.0, 1, rol)
				else:
					var L2 := rng.randf_range(4.0, 12.0)
					var dd := tg if rng.randf() < 0.5 else -tg
					if _cell(q + dd * L2) in [0, 1] and _cell(q + dd * L2 * 0.5) in [0, 1]:
						insan(q, dd, L2, rng.randf_range(0.9, 1.4), 4 if (tur == "liman" and rng.randf() < 0.5) else 0, rol)
		# tavuk
		if (tur == "seyrek" or tur == "bostan" or tur == "sur_dibi") and rr.randf() < 0.12:
			var q := fr + (fr - c).normalized() * 1.4
			if _cell(q) == 1 or _cell(q) == 0:
				for k in rng.randi_range(2, 4):
					var qq := q + Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0))
					if _cell(qq) == 1 or _cell(qq) == 0:
						tavuk(qq, Vector2.from_angle(rng.randf() * TAU), rng.randi() % 8)
		# gece: pencere ışıkları, kandil
		if gece:
			var floors := maxi(1, int(round((H - GF) / UF)))
			var wn := 2 if L < 6.0 else 3
			var pl := 0.55 if tur == "carsi" else (0.45 if tur == "sik" or tur == "liman" else 0.3)
			var fz := D * 0.5
			if H > GF + 0.1:
				for fl in floors:
					var wy := GF + UF * (fl + 0.5)
					for i in wn:
						if rr.randf() > pl:
							continue
						var x := -L * 0.5 + (i + 0.5) * L / wn
						var wp := o3 + bas * Vector3(x, wy, fz + OVER + 0.06)
						K["pencere"].add(Transform3D(bas, wp), Color(rr.randf_range(0.85, 1.0), rr.randf_range(0.55, 0.72), rr.randf_range(0.2, 0.34)))
			else:
				if rr.randf() < pl:
					var wp := o3 + bas * Vector3(L * 0.25, 1.9, fz + 0.06)
					K["pencere"].add(Transform3D(bas, wp), Color(1.0, 0.65, 0.28))
			if rr.randf() < 0.14 and (tur == "carsi" or tur == "sik" or tur == "liman"):
				var kp := o3 + bas * Vector3(-L * 0.35, 2.5, fz + 0.45)
				alev(kp, 0.16, 0.26, 1.7)
	ist["baca"] = nb
	ist["duman_sutun"] = nd
	# çamaşır ipi: dar sokakta iki cephe arasında
	var n_c := 0
	for st: Dictionary in sokak.streets:
		if String(st["tur"]) != "sokak" or float(st["w"]) > 4.6:
			continue
		var pts: PackedVector2Array = st["pts"]
		for i in pts.size() - 1:
			var a := pts[i]
			var b := pts[i + 1]
			var seg := a.distance_to(b)
			if seg < 7.0 or rng.randf() > 0.28:
				continue
			var d := (b - a) / seg
			var perp := Vector2(-d.y, d.x)
			var q := a + d * rng.randf_range(2.5, seg - 2.5)
			var w2 := float(st["w"]) * 0.5
			if _cell(q + perp * (w2 + 1.0)) != 2 or _cell(q - perp * (w2 + 1.0)) != 2:
				continue
			var yy := _h(q) + 3.7
			var half := w2 + 0.1
			var p1 := Vector3(q.x + perp.x * half, yy, q.y + perp.y * half)
			var p2 := Vector3(q.x - perp.x * half, yy, q.y - perp.y * half)
			kutu((p1 + p2) * 0.5, Vector3(0.025, 0.025, p1.distance_to(p2)), atan2(perp.x, perp.y), Color(0.3, 0.25, 0.2))
			var yaw_c := atan2(-d.x, -d.y) + PI * 0.5
			var cnt := rng.randi_range(2, 4)
			for k in cnt:
				var t := (k + 0.5) / cnt - 0.5
				var cp := (p1 + p2) * 0.5 + (p1 - p2) * t * 0.8
				var bs := Basis(Vector3.UP, atan2(d.x, d.y) + PI * 0.5).scaled(Vector3(0.55, rng.randf_range(0.6, 0.95), 1.0))
				K["bez"].add(Transform3D(bs, cp - Vector3(0, 0.05, 0)), Color.WHITE, Color(rng.randi() % 12, rng.randi() % 12, 4, 1))
			n_c += 1
	ist["camasir"] = n_c


# ---------------------------------------------------------------- meydanlar

func _meydanlar() -> void:
	for m: Dictionary in sokak.meydan:
		var c: Vector2 = m["c"]
		var cnt := rng.randi_range(5, 10)
		for i in cnt:
			var ang := rng.randf() * TAU
			var rad := rng.randf_range(2.8, 7.0)
			var p := c + Vector2.from_angle(ang) * rad
			if _cell(p) in [2, 3, 4]:
				continue
			var face := (c - p).normalized()
			var r := rng.randf()
			if r < 0.25:
				insan(p, face, 0.0, 0.0, 1, R_KADIN)                 # çeşme başında kadınlar
			elif r < 0.5:
				insan(p, Vector2.from_angle(rng.randf() * TAU), rng.randf_range(4.0, 9.0), 1.1, 0, R_ERKEK)
			elif r < 0.7:
				insan(p, face, 0.0, 0.0, 1, R_ERKEK)
			elif r < 0.85:
				insan(p, Vector2.from_angle(rng.randf() * TAU), 0.0, 0.0, 5, R_HAMAL)       # oturan
			else:
				hayvan(p, Vector2.from_angle(rng.randf() * TAU), 0.0, 0.0, 1, rng.randi() % 7, 1.0, true)
		# güvercin
		_surut(c, 7.0, 14.0, 5.0, 11.0, 5, true)


# ---------------------------------------------------------------- doku: bostan, bağ, tarla, bahçe

func _doku() -> void:
	var nc := 0
	for dk: Dictionary in sokak.doku:
		var tur := String(dk["tur"])
		var c: Vector2 = dk["c"]
		var alan: Vector2 = dk["alan"]
		var yw := float(dk["yaw"])
		if tur in ["bostan", "bag", "bugday", "bahce"]:
			var u := Vector2(cos(-yw), sin(-yw))
			var v := Vector2(-u.y, u.x)
			var cnt := clampi(int(alan.x * alan.y / 220.0), 1, 5)
			for i in cnt:
				var p := c + u * rng.randf_range(-0.34, 0.34) * alan.x + v * rng.randf_range(-0.34, 0.34) * alan.y
				var beh := 3 if rng.randf() < 0.65 else 2
				var d2 := Vector2.from_angle(rng.randf() * TAU)
				insan(p, d2, 0.0, 0.0, beh, R_CIFTCI if tur != "bahce" else R_KADIN)
				nc += 1
			if tur == "bostan" and rng.randf() < 0.5:
				var p := c + u * alan.x * 0.55
				hayvan(p, Vector2.from_angle(rng.randf() * TAU), 0.0, 0.0, 1, rng.randi() % 7, 1.0, true)
		elif tur == "cayir":
			for i in rng.randi_range(2, 5):
				var p := c + Vector2(rng.randf_range(-0.4, 0.4) * alan.x, rng.randf_range(-0.4, 0.4) * alan.y)
				hayvan(p, Vector2.from_angle(rng.randf() * TAU), rng.randf_range(0.0, 3.0), 0.3, 2, rng.randi() % 4 + 2, rng.randf_range(0.5, 0.58))   # keçi/koyun otlar
			if rng.randf() < 0.6:
				insan(c + Vector2(alan.x * 0.45, 0), Vector2.from_angle(rng.randf() * TAU), 0.0, 0.0, 1, R_CIFTCI, 1)    # çoban sopalı
			nc += 1
	ist["doku_isi"] = nc


# ---------------------------------------------------------------- Mese alayı

func _alay() -> void:
	var ms := IstGeo.yol("mese")
	if ms.size() < 3:
		return
	# Ayasofya'ya yakın düz bir Mese kesiti: uzun düz parçayı bul
	var best := -1
	var bl := 0.0
	for i in ms.size() - 1:
		var l := ms[i].distance_to(ms[i + 1])
		var mid := (ms[i] + ms[i + 1]) * 0.5
		if l > bl and mid.length() < 700.0:
			bl = l
			best = i
	if best < 0:
		return
	var a := ms[best]
	var b := ms[best + 1]
	var d := (b - a).normalized()
	var perp := Vector2(-d.y, d.x)
	var L := minf(bl - 6.0, 90.0)
	var st := a + d * 3.0 + perp * 3.0
	# Ayasofya doğuda (ms yönü?): alay Ayasofya'ya doğru
	var to := (Vector2.ZERO - (a + b) * 0.5)
	var dd := d if to.dot(d) > 0 else -d
	var p0 := st if dd == d else st + d * L
	var spd := 0.9
	var n := 16
	for i in n:
		var ph := float(i) * 1.7 / (2.0 * L)
		var rol := R_PAPAZ if i < 6 else (R_KEIS if i < 11 else R_ERKEK)
		insan(p0, dd, L, spd, 0, rol, 1 if i == 0 or i == 3 else 0, 1.0, fposmod(ph, 1.0))
	ist["alay"] = n


# ---------------------------------------------------------------- surlar

func _surlar() -> void:
	var hatlar := [["kara_suru", "kara"], ["marmara_suru", "marmara"], ["halic_suru", "halic"], ["blakherna_suru", "blakherna"]]
	var n_n := 0
	var n_f := 0
	for h: Array in hatlar:
		var pl := IstGeo.yol(String(h[0]))
		if pl.size() < 2:
			continue
		var hy := IstSehir._walk_h(String(h[1]))
		var tw := IstSehir._walk_w(String(h[1]))
		var acc := 0.0
		var next := rng.randf() * 30.0
		for i in pl.size() - 1:
			var a := pl[i]
			var b := pl[i + 1]
			var seg := a.distance_to(b)
			if seg < 0.5:
				continue
			var d := (b - a) / seg
			var perp := Vector2(-d.y, d.x)
			while next < acc + seg:
				var s := next - acc
				var p := a + d * s
				var ya := _h(p) + hy
				var out := perp if not IstGeo.sehir_ici(p.x + perp.x * 20.0, p.y + perp.y * 20.0) else -perp
				var latmax := maxf(tw * 0.5 - 0.7, 0.1)
				var step := 52.0 if h[1] == "kara" else 70.0
				var r := rng.randf()
				if r < 0.4:
					# nöbetçi: surun dışına bakar, mızraklı
					var q := p + perp * rng.randf_range(-1.0, 1.0) * latmax
					insan(q, out, 0.0, 0.0, 1, R_BIZ_ASKER, 1, 1.0, -1.0, ya)
					n_n += 1
				elif r < 0.7:
					var L := minf(rng.randf_range(10.0, 26.0), seg - s - 0.5)
					if L > 4.0:
						var q := p + perp * rng.randf_range(-0.5, 0.5) * latmax
						insan(q, d if rng.randf() < 0.5 else d, L, 1.0, 0, R_BIZ_ASKER, 1, 1.0, -1.0, ya)
						n_n += 1
				else:
					# onarım işçileri (çekiç, kürek): 2–3 kişi + kasalar
					for k in rng.randi_range(2, 3):
						var q := p + d * (k * 1.3) + perp * rng.randf_range(-0.8, 0.8) * latmax
						insan(q, perp * (1.0 if k % 2 == 0 else -1.0), 0.0, 0.0, 2, R_HAMAL, 0, 1.0, -1.0, ya)
						n_f += 1
					kutu(Vector3(p.x - d.x * 1.2, ya + 0.35, p.y - d.y * 1.2), Vector3(0.9, 0.7, 0.9), _yaw(d), Color(0.58, 0.44, 0.28))
				next += step * rng.randf_range(0.7, 1.3)
			acc += seg
	ist["nobetci"] = n_n
	ist["isci"] = n_f


# ---------------------------------------------------------------- ordugâh

func _ordugah() -> void:
	var tents := 0
	var fires := 0
	var sold := 0
	for y: Dictionary in IstGeo.yerler():
		if String(y["tur"]) != "ordugah":
			continue
		var w: Vector3 = y["w"]
		var c := Vector2(w.x, w.z)
		var nm := String(y["ad"])
		var big := nm.contains("otağı")
		var cnt := 60 if big else 42
		# Padişah otağı: iri kırmızı-altın çadır + sancaklar
		if big:
			var yy := _h(c)
			K["cadir"].add(Transform3D(Basis.from_scale(Vector3(2.4, 2.2, 2.4)), Vector3(c.x, yy, c.y)), Color(0.78, 0.2, 0.16))
			sancak(Vector3(c.x + 7.0, yy, c.y), 0.0, 9.0, 0, 1, 3, 4.5, 3.0)
			sancak(Vector3(c.x - 7.0, yy, c.y + 2.0), 0.4, 8.0, 0, 1, 3, 4.0, 2.7)
			tents += 1
			cnt = 70
		for i in cnt:
			var rad := (14.0 if big else 4.0) + sqrt(rng.randf()) * (150.0 if big else 110.0)
			var p := c + Vector2.from_angle(rng.randf() * TAU) * rad
			if IstGeo.su(p.x, p.y) or IstGeo.sehir_ici(p.x, p.y) or IstGeo.galata_ici(p.x, p.y):
				continue
			var hp := _h(p)
			if hp < 1.0:
				continue
			var sl := absf(_h(p + Vector2(4, 0)) - hp) + absf(_h(p + Vector2(0, 4)) - hp)
			if sl > 2.2:
				continue
			var s := rng.randf_range(0.7, 1.05)
			var rc := rng.randf()
			var col := Color(0.92, 0.9, 0.82) if rc < 0.45 else (Color(0.78, 0.3, 0.22) if rc < 0.7 else (Color(0.82, 0.68, 0.42) if rc < 0.88 else Color(0.35, 0.45, 0.62)))
			var yaw := rng.randf_range(-0.3, 0.3) + float(i % 4) * 0.0
			K["cadir"].add(Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3(s, s, s)), Vector3(p.x, hp - 0.05, p.y)), col)
			tents += 1
			# her ikinci-üçüncü çadırın yanında ateş ve askerler
			if i % 3 == 0:
				var fp := p + Vector2.from_angle(rng.randf() * TAU) * 5.5
				if not IstGeo.su(fp.x, fp.y):
					var fh := _h(fp)
					alev(Vector3(fp.x, fh, fp.y), 0.55, 0.85, 4.0)
					fires += 1
					for k in rng.randi_range(2, 5):
						var sp := fp + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(1.2, 2.6)
						var beh := 5 if rng.randf() < 0.35 else 1
						insan(sp, (fp - sp).normalized(), 0.0, 0.0, beh, R_OSM_ASKER, 1 if beh == 1 and rng.randf() < 0.3 else 0)
						sold += 1
			elif i % 5 == 1:
				# devriye
				var dd := Vector2.from_angle(rng.randf() * TAU)
				insan(p + Vector2(5, 0), dd, rng.randf_range(15.0, 40.0), 1.3, 0, R_OSM_ASKER, 1)
				sold += 1
		# sancak
		for k in 3:
			var p := c + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(30.0, 110.0)
			if IstGeo.su(p.x, p.y) or IstGeo.sehir_ici(p.x, p.y):
				continue
			sancak(Vector3(p.x, _h(p), p.y), rng.randf() * TAU, 6.0, 0, 1, 3, 3.0, 2.0)
	ist["cadir"] = tents
	ist["ordu_ates"] = fires
	ist["ordu_asker"] = sold


# ---------------------------------------------------------------- sur dibinde mülteciler

func _siginmacilar() -> void:
	if sokak == null:
		return
	var pl := IstGeo.yol("kara_suru")
	if pl.size() < 2:
		return
	var acc := 0.0
	var next := 90.0
	var nk := 0
	for i in pl.size() - 1:
		var a := pl[i]
		var b := pl[i + 1]
		var seg := a.distance_to(b)
		if seg < 1.0:
			continue
		var d := (b - a) / seg
		var perp := Vector2(-d.y, d.x)
		while next < acc + seg:
			var p := a + d * (next - acc)
			var inn := perp if IstGeo.sehir_ici(p.x + perp.x * 40.0, p.y + perp.y * 40.0) else -perp
			var q := p + inn * rng.randf_range(34.0, 52.0)
			next += rng.randf_range(110.0, 220.0)
			if not IstGeo.sehir_ici(q.x, q.y) or sokak.cell(q.x, q.y) != 0:
				continue
			# küçük kamp: ateş, çuvallar, oturan/ayakta kişiler
			var ok := true
			for k in 8:
				if sokak.cell(q.x + cos(k * 0.785) * 4.0, q.y + sin(k * 0.785) * 4.0) in [2, 3, 4]:
					ok = false
			if not ok:
				continue
			alev(Vector3(q.x, _h(q), q.y), 0.45, 0.7, 3.2)
			for k in rng.randi_range(4, 8):
				var sp := q + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(1.0, 3.2)
				var beh := 5 if rng.randf() < 0.5 else 1
				insan(sp, (q - sp).normalized(), 0.0, 0.0, beh, R_KADIN if rng.randf() < 0.4 else R_ERKEK, 0, 0.7 if rng.randf() < 0.2 else 1.0)
			for k in rng.randi_range(2, 4):
				var sp := q + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(2.5, 4.0)
				kutu(Vector3(sp.x, _h(sp) + 0.3, sp.y), Vector3(rng.randf_range(0.6, 0.9), 0.55, 0.6), rng.randf() * TAU, Color(0.62, 0.5, 0.34))
			if rng.randf() < 0.4:
				hayvan(q + Vector2(3.5, 1.0), Vector2.from_angle(rng.randf() * TAU), 0.0, 0.0, 2, rng.randi() % 4 + 2, 0.5)
			nk += 1
		acc += seg
	ist["siginmaci_kamp"] = nk


# ---------------------------------------------------------------- manastırlar

func _manastirlar() -> void:
	var nm := 0
	for y: Dictionary in IstGeo.yerler():
		var tur := String(y["tur"])
		if tur != "manastir" and not (tur == "kilise" and String(y["ad"]).contains("Khora")):
			continue
		var w: Vector3 = y["w"]
		var c := Vector2(w.x, w.z)
		# yapının etrafında dolaşan keşişler (boş hücre bulunan halkada)
		var placed := 0
		for t in 60:
			if placed >= 7:
				break
			var rad := rng.randf_range(12.0, 30.0)
			var ang := rng.randf() * TAU
			var p := c + Vector2.from_angle(ang) * rad
			var tg := Vector2(-sin(ang), cos(ang))
			var L := rng.randf_range(5.0, 12.0)
			var ok := true
			for k in 4:
				var q := p + tg * L * float(k) / 3.0
				if sokak != null and sokak.cell(q.x, q.y) in [2, 3, 4] or IstGeo.su(q.x, q.y):
					ok = false
			if not ok:
				continue
			if rng.randf() < 0.55:
				insan(p, tg, L, 0.75, 0, R_KEIS)
			else:
				insan(p, tg, 0.0, 0.0, 1, R_KEIS)
			placed += 1
			nm += 1
	ist["kesis"] = nm


# ---------------------------------------------------------------- limanlar

func _limanlar() -> void:
	var nh := 0
	for y: Dictionary in IstGeo.yerler():
		var tur := String(y["tur"])
		if tur != "liman" and tur != "iskele":
			continue
		var w: Vector3 = y["w"]
		var c := Vector2(w.x, w.z)
		# kıyıya inen yön: suya doğru en yakın su noktası
		var water := Vector2.INF
		for r in range(10, 140, 6):
			for k in 16:
				var q := c + Vector2.from_angle(k * TAU / 16.0) * float(r)
				if IstGeo.su(q.x, q.y):
					water = q
					break
			if water != Vector2.INF:
				break
		if water == Vector2.INF:
			continue
		var land := c
		var dir := (water - c).normalized()
		# kıyı çizgisi: su ile kara arasındaki sınıra ikili arama
		var lo := 0.0
		var hi := c.distance_to(water)
		for it in 12:
			var mid := (lo + hi) * 0.5
			var q := c + dir * mid
			if IstGeo.su(q.x, q.y):
				hi = mid
			else:
				lo = mid
		var shore := c + dir * lo
		var tng := Vector2(-dir.y, dir.x)
		for i in 26:
			var along := rng.randf_range(-38.0, 38.0)
			var back := rng.randf_range(1.5, 14.0)
			var p := shore + tng * along - dir * back
			if IstGeo.su(p.x, p.y):
				continue
			if sokak != null and sokak.cell(p.x, p.y) in [2, 3]:
				continue
			var r := rng.randf()
			var L := rng.randf_range(6.0, 18.0)
			var q2 := p + tng * L
			if r < 0.4:
				if IstGeo.su(q2.x, q2.y) or (sokak != null and sokak.cell(q2.x, q2.y) in [2, 3]):
					continue
				insan(p, tng if rng.randf() < 0.5 else -tng, L, 0.9, 4, R_HAMAL)
			elif r < 0.6:
				insan(p, dir, 0.0, 0.0, 5 if rng.randf() < 0.4 else 1, R_BALIKCI, 1)         # olta/zıpkınlı balıkçı
			elif r < 0.85:
				insan(p, Vector2.from_angle(rng.randf() * TAU), 0.0, 0.0, 2, R_HAMAL)       # yük istifleyen
			else:
				hayvan(p, tng, minf(L, 10.0), 1.0, 0, rng.randi() % 7, 1.0, true)
			nh += 1
		# istif kasaları
		for i in 8:
			var p := shore + tng * rng.randf_range(-30.0, 30.0) - dir * rng.randf_range(2.0, 9.0)
			if IstGeo.su(p.x, p.y) or (sokak != null and sokak.cell(p.x, p.y) in [2, 3]):
				continue
			kutu(Vector3(p.x, _h(p) + 0.45, p.y), Vector3(rng.randf_range(0.9, 1.4), 0.9, rng.randf_range(0.9, 1.3)), rng.randf() * TAU, Color(0.58, 0.44, 0.28))
		_surut(shore - dir * 6.0, 18.0, 40.0, 12.0, 24.0, 7, false)
	ist["liman_isi"] = nh


# ---------------------------------------------------------------- kuşlar

## merkez c, yarıçap aralığı, yükseklik aralığı (zeminden), adet
func _surut(c: Vector2, r0: float, r1: float, h0: float, h1: float, cnt: int, guvercin: bool) -> void:
	var sc := 0.62 if guvercin else 1.0
	var yy := maxf(_h(c), 0.0)
	var rad := rng.randf_range(r0, r1)
	var hh := rng.randf_range(h0, h1)
	var sp := rng.randf_range(0.16, 0.3) / maxf(rad / 20.0, 1.0)
	if rng.randf() < 0.5:
		sp = -sp
	for i in cnt:
		var ang := rng.randf() * TAU
		K["guvercin" if guvercin else "marti"].add(
			Transform3D(Basis.from_scale(Vector3.ONE * sc), Vector3(c.x, yy, c.y)), Color.WHITE,
			Color(rad * rng.randf_range(0.85, 1.15) / sc, (hh + rng.randf_range(-3.0, 3.0)) / sc, sp * 3.0 * rng.randf_range(0.9, 1.1), ang))


func _kuslar() -> void:
	var pl := IstGeo.kiyi("yarimada")
	var acc := 0.0
	var next := 100.0
	var nf := 0
	for i in pl.size():
		var a := pl[i]
		var b := pl[(i + 1) % pl.size()]
		var seg := a.distance_to(b)
		if seg < 0.5:
			continue
		var d := (b - a) / seg
		while next < acc + seg:
			var p := a + d * (next - acc)
			next += rng.randf_range(240.0, 420.0)
			# denize doğru ötele
			var perp := Vector2(-d.y, d.x)
			var q := p + perp * 35.0
			if not IstGeo.su(q.x, q.y):
				q = p - perp * 35.0
			_surut(q, 22.0, 60.0, 16.0, 42.0, rng.randi_range(4, 8), false)
			nf += 1
		acc += seg
	# güvercin sürüleri: forumlar, kiliseler, Hipodrom
	for y: Dictionary in IstGeo.yerler():
		var tur := String(y["tur"])
		if tur in ["kilise", "forum", "sutun", "saray"] or String(y["ad"]).contains("Hipodrom"):
			var w: Vector3 = y["w"]
			_surut(Vector2(w.x, w.z), 10.0, 22.0, 9.0, 18.0, rng.randi_range(5, 9), true)
			nf += 1
	ist["kus_suru"] = nf
