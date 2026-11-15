class_name IstCati
extends RefCounted
## Şehir çatı rotası (docs/ISTANBUL_CATI.md): Ayasofya–Yerebatan–Hipodrom mahallesinde evlerin damları "yere inmeden"
## geçilebilir bir yol olur. Bu dosya (1) mahallenin çatı çözümlemesini (sondalar ve belge), (2) rota planını, (3) rota
## parçalarının (kalas köprü, dam merdiveni, dış merdiven, bakış kulesi, saman) ağ ve çarpışmasını verir.
## Şehir kurucusu (IstSehir._sehir_dokusu_v2) evleri dizdikten sonra uygula(houses) çağırır: rota evlerinin tipine "~dam"
## eki (düz dam) yazılır, parçalar "ev|<kod>|c_<tür>" anahtarıyla aynı hücre katmanlarına (yakında çarpışmalı) eklenir.

# ---------------------------------------------------------------- mahalle

static var _nok := {}

## Dünya (x, z) noktaları: Ayasofya kubbesi, Ayasofya önü (batı, narteks meydanı), Yerebatan girişi, Hipodrom uçları
static func noktalar() -> Dictionary:
	if not _nok.is_empty():
		return _nok
	var aw := IstGeo.w2(0, 0)
	var yb3 := IstGeo.ll(41.0081, 28.9778)
	var hp := IstGeo.w2(-400.0, -300.0)
	_nok = {"ayasofya": aw, "yerebatan": Vector2(yb3.x, yb3.z), "hipodrom": hp}
	return _nok


## Mahalle dikdörtgeni (dünya): Ayasofya, Yerebatan ve Hipodrom'u ZON_PAY payıyla kapsar
const ZON_PAY := 70.0

static func zon() -> Rect2:
	var n := noktalar()
	var r := Rect2(n["ayasofya"], Vector2.ZERO)
	for k: String in n:
		r = r.expand(n[k])
	return r.grow(ZON_PAY)


## Ev kaydının geometrisi: taban dörtgeni, saçak ve sırt yüksekliği (dünya), çatı türü, eğim
static func ev_geo(h: Dictionary) -> Dictionary:
	var v := int(h["v"])
	var tip := String(h["tip"])
	var dm := IstEvler.dims(v)
	var p := IstEvler.plan(dm.x, dm.z, dm.y, IstEvler._tohum(v, tip), tip)
	var c: Vector2 = h["c"]
	var fr: Vector2 = h["on"]
	var y0 := IstGeo.h(fr.x, fr.y) - 0.04
	var yaw := float(h["yaw"])
	var ux := Vector2(cos(yaw), -sin(yaw))
	var uz := Vector2(sin(yaw), cos(yaw))
	var over: float = p["over"]
	var poly := PackedVector2Array()
	for o: Vector2 in [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.5, 0.5), Vector2(-0.5, 0.5)]:
		poly.append(c + ux * o.x * dm.x + uz * o.y * dm.z)
	# dam/çatı dörtgeni: çıkma sokağa taşar
	var dam := PackedVector2Array()
	for o: Vector2 in [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.5, 0.5), Vector2(-0.5, 0.5)]:
		var z := o.y * dm.z + (over if o.y > 0 else 0.0)
		dam.append(c + ux * o.x * dm.x + uz * z)
	var cati := String(p["cati"])
	var sacak := y0 + dm.y
	var sirt := sacak + (IstEvler.RISE - 0.1 if cati in ["kiremit", "harap"] else (0.18 if cati in ["duz", "teras"] else 0.2))
	var egim := rad_to_deg(atan2(IstEvler.RISE - 0.1, (dm.z + over) * 0.5)) if cati in ["kiremit", "harap"] else 0.0
	return {"c": c, "yaw": yaw, "ux": ux, "uz": uz, "L": dm.x, "D": dm.z, "H": dm.y, "over": over, "y0": y0, "poly": poly,
		"dam": dam, "cati": cati, "saçak": sacak, "sirt": sirt, "egim": egim, "v": v, "tip": tip, "sira": int(h.get("sira", -1)),
		"ust": sacak + 0.18}


## Zondaki evler (geometrisiyle), sıra numarası ve evin listedeki yeri ("i")
static func evler(houses: Array, r: Rect2) -> Array:
	var out: Array = []
	for i in houses.size():
		var h: Dictionary = houses[i]
		var c: Vector2 = h["c"]
		if not r.has_point(c):
			continue
		var e := ev_geo(h)
		e["i"] = i
		e["rota"] = bool(h.get("cati_rota", false))
		out.append(e)
	return out


## Başka sıradaki en yakın ev: yatay aralık (çatı dörtgenleri arası) ve dam üstü kot farkı
static func en_yakin_komsu(e: Dictionary, evs: Array) -> Dictionary:
	var best := {}
	var bd := 1e9
	for o: Dictionary in evs:
		if o == e or int(o["sira"]) == int(e["sira"]):
			continue
		var g := IstSokak.poly_gap(e["dam"], o["dam"])
		if g < bd:
			bd = g
			best = {"i": int(o["i"]), "ara": g, "dy": float(o["sirt"]) - float(e["sirt"])}
	return best


static func sokaklar(streets: Array, r: Rect2) -> Array:
	var out: Array = []
	for st: Dictionary in streets:
		var pts: PackedVector2Array = st["pts"]
		for p in pts:
			if r.has_point(p):
				out.append(st)
				break
	return out


static func genislik_ozet(yol: Array) -> Dictionary:
	var d := {}
	for st: Dictionary in yol:
		var k := "%.1f" % float(st["w"])
		d[k] = int(d.get(k, 0)) + 1
	return d


# ---------------------------------------------------------------- harita yardımcıları (sondalar)

static var _kopru_ciz: Array = []
static var _rota_ciz: Array = []

static func kopru_cizgileri() -> Array:
	return _kopru_ciz


static func rota_cizgileri() -> Array:
	return _rota_ciz


## Bot rotaları (gerçek Player): [{ad, bas: Vector3 (yerde başlangıç), wps: [Vector3], son_cati: son dam noktasının sırası}]
## Plan sabit ölçülerden (IstGeo.h) hesaplanır: ÖNCE (küme kapalı) ve SONRA aynı noktalar yürünür.
static func rotalar(_houses: Array = []) -> Array:
	return plan()["rotalar"]


## Hipodrom yerel çerçevesi (yaw −35°, k 0,45; IstHipodrom ölçüleri): w = P + X·lx + Z·lz (dünya x, z)
const HIP_P := Vector2(-147.3, 120.4)
const HIP_X := Vector2(0.819, 0.574)
const HIP_Z := Vector2(-0.574, 0.819)

static func hip(lx: float, lz: float) -> Vector2:
	return HIP_P + HIP_X * lx + HIP_Z * lz


static func _k3(p: Vector2, dy: float) -> Vector3:
	return Vector3(p.x, IstGeo.h(p.x, p.y) + dy, p.y)


## Sabit kamera kümesi (ÖNCE ve SONRA aynı): sokaktan 6, çatı hizasından 6, havadan 2. [ad, konum, bakış noktası]
static func kameralar() -> Array:
	return [
		["sokak1_meydan_gd", _k3(Vector2(-72, 10), 1.7), _k3(Vector2(-60, 24), 4.0)],
		["sokak2_yerebatan", _k3(Vector2(-71, 17), 1.7), _k3(Vector2(-75, 30), 4.0)],
		["sokak3_milion", _k3(Vector2(-88, 25), 1.7), _k3(Vector2(-91, 37), 4.0)],
		["sokak4_hip_kuzey", _k3(hip(44.0, -52.0), 1.7), _k3(hip(34, -40), 4.0)],
		["sokak5_hip_orta", _k3(hip(42.5, -34.5), 1.7), _k3(hip(33, -34.5), 4.5)],
		["sokak6_hip_guney", _k3(hip(43, -18), 1.7), _k3(hip(35, -30), 4.0)],
		["cati1_e_sirasi", _k3(Vector2(-58, 8), 7.7), _k3(Vector2(-75, 35), 5.0)],
		["cati2_m1", _k3(Vector2(-64, 30), 7.7), _k3(Vector2(-92, 35), 6.0)],
		["cati3_m2_bakis", _k3(Vector2(-90, 35), 11.0), _k3(hip(-5, -40), 2.0)],
		["cati4_d_kuzey", _k3(hip(35.7, -43.5), 5.3), _k3(hip(35.7, -20), 6.0)],
		["cati5_d_bakis", _k3(hip(32.7, -33.3), 10.7), _k3(hip(-10, -30), 2.0)],
		["cati6_d_ayasofya", _k3(hip(35.7, -26), 7.7), Vector3(0, 40, 0)],
		["hava1_mahalle", Vector3(-60, 170, 140), Vector3(-80, 10, 40)],
		["hava2_hipodrom", Vector3(-200, 90, 60), Vector3(-110, 10, 60)],
	]


# ================================================================ ÇATI MAHALLESİ: plan, uygulama, parçalar

## --cati=0: küme kurulmaz (ÖNCE ölçümleri için; şehir bugünkü hâliyle)
static var _acik_k := -1

static func acik() -> bool:
	if _acik_k < 0:
		_acik_k = 1
		for a: String in OS.get_cmdline_user_args():
			if a == "--cati=0":
				_acik_k = 0
	return _acik_k == 1


## Sıralar (dünya; cephe çizgisi p0'dan d = (−n.y, n.x) yönünde; n cepheden evin içine). evler: [[cephe m, kat], …]
## E: meydanın doğu kıyısı (Ayasofya avlusunun önü), cephe batıya (meydana). M1a/M1b: meydanın güney kıyısı (Yerebatan),
## cephe kuzeye. M2: Milion'un batısı, Hipodrom'un kuzeybatı ucu. Ds/Dn: Hipodrom'un yıkık doğu dış duvarına sırtını
## vermiş evler (arka duvar lx 30,2; cephe doğuya, sokağa). Doğu yakasını çapraz kesen 6 m'lik yol (lz −69…−47) ile
## güneydeki yan yol (lz −12…−23) arasında kalır (sokaklara ev konmaz; NPC'ler sokakta yürür).
static func siralar() -> Array:
	return [
		{"ad": "E", "p0": Vector2(-61.5, 13.0), "n": Vector2(1, 0), "evler": [[5, 2], [5, 2], [4, 2]], "maxd": 8.0},
		{"ad": "M1a", "p0": Vector2(-66.0, 27.0), "n": Vector2(0, 1), "evler": [[6, 2]], "maxd": 7.0},
		{"ad": "M1b", "p0": Vector2(-73.25, 26.6), "n": Vector2(0, 1), "evler": [[5, 2], [5, 2]], "maxd": 7.0},
		{"ad": "M2", "p0": Vector2(-83.6, 32.0), "n": Vector2(0, 1), "evler": [[6, 2], [5, 2]], "maxd": 7.0},
		{"ad": "Ds", "p0": hip(37.2, -24.0), "n": -HIP_X, "evler": [[5, 2], [6, 2], [5, 1], [5, 1]], "maxd": 7.0},
	]


## Cephe ve kata uyan en derin örnek (YENI tablosu); biçim tohumdan
static func _sec(cephe: float, kat: int, maxd: float, tohum: int) -> int:
	var best := -1
	var bd := 0.0
	for i in IstEvler.YENI.size():
		var r: Array = IstEvler.YENI[i]
		if is_equal_approx(float(r[0]), cephe) and int(r[2]) == kat and float(r[1]) <= maxd + 0.01 and float(r[1]) > bd:
			bd = float(r[1])
			best = i
	if best < 0:
		return -1
	return IstEvler.eski_sayi() + best * IstEvler.BICIM + tohum % IstEvler.BICIM


static var _plan := {}

## Bütün küme: evler (ad → kayıt), parçalar [[anahtar, Transform3D]], rotalar, köprü/rota çizgileri (harita)
static func plan() -> Dictionary:
	if not _plan.is_empty():
		return _plan
	var evler_ := {}
	var sira_no := 9000
	for r: Dictionary in siralar():
		var n: Vector2 = r["n"]
		var d := Vector2(-n.y, n.x)
		var x := 0.0
		var k := 0
		for sp: Array in r["evler"]:
			var v := _sec(float(sp[0]), int(sp[1]), float(r["maxd"]), sira_no * 3 + k)
			var dm := IstEvler.dims(v)
			var p0: Vector2 = r["p0"]
			var fr := p0 + d * (x + dm.x * 0.5)
			var h := {"c": fr + n * (dm.z * 0.5), "yaw": atan2(-n.x, -n.y), "v": v, "tip": "sira~dam", "sira": sira_no, "on": fr,
				"cati_rota": true, "cati_ad": "%s%d" % [r["ad"], k]}
			evler_["%s%d" % [r["ad"], k]] = h
			x += dm.x
			k += 1
		sira_no += 1
	var g := {}
	for ad: String in evler_:
		g[ad] = ev_geo(evler_[ad])
	var parca: Array = []
	_kopru_ciz = []
	# --- dış merdivenler (sokaktan dama; yan duvar boyunca, cepheden arkaya çıkar)
	var m_e := _dis_merdiven(parca, g["E0"], -1)          # Ayasofya önü
	var m_y := _dis_merdiven(parca, g["M1a0"], 1, false)  # Yerebatan girişi (M1a ile M1b arasındaki dar geçitte; korkuluksuz)
	var m_h := _dis_merdiven(parca, g["M21"], 1)          # Hipodrom kuzeybatı ucu
	var m_dk := _dis_merdiven(parca, g["Ds3"], 1)         # Hipodrom doğu, kuzey uç
	var m_dg := _dis_merdiven(parca, g["Ds0"], -1)        # Hipodrom doğu, güney uç (kathisma yolu)
	# --- dam merdiveni (aynı sırada kat farkı): tek katlı Ds2'den iki katlı Ds1'e
	_dam_merdiveni(parca, g["Ds2"], g["Ds1"])
	# --- kalas köprüler (sokak/geçit üstü)
	var k1a := Vector2(-59.8, 25.8)
	var k1b := Vector2(-67.4, 28.6)
	_kalas(parca, k1a, float(g["E2"]["ust"]), k1b, float(g["M1a0"]["ust"]))
	# --- bakış kuleleri (dam üstünde taş köşk; merdivenle çıkılır)
	var tk_m := _kule(parca, g["M20"], Vector2(-1.2, -1.7), Vector2(1, 0))
	var tk_d := _kule(parca, g["Ds1"], Vector2(1.4, -1.7), Vector2(-1, 0))
	# --- iniş: saman yığınları (Ds'nin kuzey merdiveni yanında; E–M1a köprüsünün altı)
	for sp: Vector2 in [hip(40.0, -46.6), Vector2(-62.0, 25.9)]:
		parca.append(["ev|1|c_saman", Transform3D(Basis(Vector3.UP, 0.4), Vector3(sp.x, IstGeo.h(sp.x, sp.y) - 0.05, sp.y))])
	# --- rotalar
	var ro: Array = []
	var tE := float(g["E0"]["ust"])
	var tM := float(g["M1a0"]["ust"])
	# R1: Ayasofya önü → E damları → kalas → M1a → geçit merdiveniyle Yerebatan girişine
	var w1: Array = []
	w1.append_array(m_e["cik"])
	w1.append(Vector3(-60.0, tE, 16.0))
	w1.append(Vector3(-60.0, tE, 24.6))
	w1.append(Vector3(k1a.x, tE, k1a.y))
	w1.append(Vector3(k1b.x, tM, k1b.y))
	w1.append(Vector3(-69.5, tM, 30.5))
	var s1 := w1.size() - 1
	w1.append_array(m_y["in"])
	ro.append({"ad": "R1_ayasofya_onu_yerebatan", "bas": m_e["bas"], "wps": w1, "son_cati": s1})
	# R2: Yerebatan girişi → geçit merdiveni → M1b → M2 → bakış kulesi (gidiş-dönüş) → Hipodrom kuzeybatı merdiveni
	var w2: Array = []
	var ct: Array = m_y["cik_ters"]
	w2.append_array(ct.slice(0, ct.size() - 1))           # sahanlığa kadar; oradan batıya, M1b'nin damına
	var tB := float(g["M1b0"]["ust"])
	var t2 := float(g["M20"]["ust"])
	w2.append(Vector3(-74.6, tB, 33.1))
	w2.append(Vector3(-76.0, tB, 31.6))
	w2.append(Vector3(-82.6, tB, 32.4))
	w2.append(Vector3(-85.5, t2, 33.2))
	w2.append(Vector3(-91.2, t2, 34.2))
	w2.append_array(tk_m["git"])
	w2.append(Vector3(-93.9, t2, 37.4))
	var s2 := w2.size() - 1
	w2.append_array(m_h["in"])
	ro.append({"ad": "R2_yerebatan_hipodrom", "bas": m_y["bas"], "wps": w2, "son_cati": s2})
	# R3: Hipodrom doğu duvarı boyunca: kuzey merdiven → Ds3/Ds2 (tek kat) → dam merdiveni → Ds1 → bakış kulesi
	# (gidiş-dönüş) → Ds0 → güney merdiven
	var w3: Array = []
	w3.append_array(m_dk["cik"])
	w3.append(_v3(hip(35.7, -41.0), float(g["Ds3"]["ust"])))
	w3.append(_v3(hip(35.7, -38.0), float(g["Ds2"]["ust"])))
	w3.append(_v3(hip(35.7, -36.0), (float(g["Ds2"]["ust"]) + float(g["Ds1"]["ust"])) * 0.5))
	w3.append(_v3(hip(35.7, -33.6), float(g["Ds1"]["ust"])))
	w3.append(_v3(hip(35.7, -29.2), float(g["Ds1"]["ust"])))
	w3.append_array(tk_d["git"])
	w3.append(_v3(hip(35.7, -26.0), float(g["Ds0"]["ust"])))
	var s3 := w3.size() - 1
	w3.append_array(m_dg["in"])
	ro.append({"ad": "R3_hipodrom_boyunca", "bas": m_dk["bas"], "wps": w3, "son_cati": s3})
	_rota_ciz = []
	for r: Dictionary in ro:
		var pl: Array = []
		for w: Vector3 in r["wps"]:
			pl.append(Vector2(w.x, w.z))
		_rota_ciz.append(pl)
	_plan = {"evler": evler_, "geo": g, "parca": parca, "rotalar": ro, "cikis": 5, "bakis": 2, "kopru": 1, "inis": 2}
	return _plan


static func _v3(p: Vector2, y: float) -> Vector3:
	return Vector3(p.x, y, p.y)


## Evin yerel noktası (lx: cephe boyunca, lz: +cephe) → dünya (x, z)
static func _yerel(e: Dictionary, lx: float, lz: float) -> Vector2:
	return (e["c"] as Vector2) + (e["ux"] as Vector2) * lx + (e["uz"] as Vector2) * lz


const MERD_RUN := 0.30
const MERD_RISE := 0.30

## Dış taş merdiven: evin yan duvarı (s: +1 yerel +x yanı, −1 −x yanı) boyunca cepheden arkaya, dam üstüne (+0,02).
## Döner: {bas: yerde başlangıç, cik: [çıkış noktaları … dama adım], in: [damdan merdivene … yere], cik_ters: in'in tersi}
static func _dis_merdiven(parca: Array, e: Dictionary, s: int, korkuluk := true) -> Dictionary:
	var L: float = e["L"]
	var D: float = e["D"]
	var y0: float = e["y0"]
	var top: float = float(e["ust"]) + 0.02 - y0
	var n := int(ceil(top / MERD_RISE))
	var r := top / n
	var run := minf(MERD_RUN, (D - 0.3) / (n + 1))          # son basamak çift derin: sahanlık
	var lx := s * (L * 0.5 + 0.62)                          # dam döşemesinin 0,1 m'lik saçağından açıkta
	var a := _yerel(e, lx, D * 0.5)                       # alt (cephe hizası)
	var ux: Vector2 = e["ux"]
	var uz: Vector2 = e["uz"]
	var zdir := Vector3(-uz.x, 0, -uz.y)                  # merdivenin +z'si: arkaya
	var xa := Vector3.UP.cross(zdir).normalized()
	var duvar := Vector3(-ux.x * s, 0, -ux.y * s)          # merdivenden eve doğru
	var tip := "c_dmerdL" if xa.dot(duvar) > 0.0 else "c_dmerdR"   # korkuluk açık yanda
	if not korkuluk:
		tip = "c_dmerd0"                                  # iki duvar arasındaki dar geçitte korkuluk yok
	var v := n * 100000 + int(round(r * 1000.0)) * 100 + int(round(run * 100.0))
	parca.append(["ev|%d|%s" % [v, tip], Transform3D(Basis(xa, Vector3.UP, zdir), Vector3(a.x, y0, a.y))])
	var ust_y := y0 + top
	var b := _yerel(e, lx, D * 0.5 - n * run)               # sahanlık (son basamak) ortası
	var dam := _yerel(e, s * (L * 0.5 - 0.9), D * 0.5 - n * run)
	var on_ := _yerel(e, lx, D * 0.5 + 1.6)
	var alt := _yerel(e, lx, D * 0.5 - run * 0.5)          # ilk basamağın ortası (yüksekliği kesin: y0 + r)
	# merdiven ekseni düz: dip → sahanlık (ara nokta yok; basamak kuantası ara noktanın yüksekliğini tutturmaz)
	var cik := [_v3(alt, y0 + r), _v3(b, ust_y), _v3(dam, float(e["ust"]))]
	var in_ := [_v3(dam, float(e["ust"])), _v3(b, ust_y), _v3(alt, y0 + r), _v3(on_, y0)]
	var ters := [_v3(alt, y0 + r), _v3(b, ust_y), _v3(dam, float(e["ust"]))]
	return {"bas": _v3(on_, y0 + 0.1), "cik": cik, "in": in_, "cik_ters": ters}


## Dam merdiveni: alçak evin (a) damında, yüksek komşusunun (b) duvarına doğru çıkar (rota çizgisi: cepheden 1,5 m içeride)
static func _dam_merdiveni(parca: Array, a: Dictionary, b: Dictionary) -> void:
	var dy := float(b["ust"]) - float(a["ust"])
	if dy < 0.42:
		return
	var n := int(ceil(dy / MERD_RISE))
	var r := dy / n
	var run := 0.32
	var ca: Vector2 = a["c"]
	var cb: Vector2 = b["c"]
	var ux: Vector2 = a["ux"]
	var yon := 1.0 if (cb - ca).dot(ux) > 0.0 else -1.0
	var lz := float(a["D"]) * 0.5 - 1.5
	var bas := _yerel(a, yon * (float(a["L"]) * 0.5 - n * run), lz)
	var zdir := Vector3(ux.x * yon, 0, ux.y * yon)
	var xa := Vector3.UP.cross(zdir).normalized()
	var v := n * 100000 + int(round(r * 1000.0)) * 100 + int(round(run * 100.0))
	parca.append(["ev|%d|c_merd" % v, Transform3D(Basis(xa, Vector3.UP, zdir), Vector3(bas.x, float(a["ust"]), bas.y))])


## Kalas köprü: a (dam üstü, ya) → b (dam üstü, yb); uçlar damlara 0,4 m biner; 5 m'den uzunsa ortada ayak
static func _kalas(parca: Array, a: Vector2, ya: float, b: Vector2, yb: float) -> void:
	var A := Vector3(a.x, ya + 0.02, a.y)
	var B := Vector3(b.x, yb + 0.02, b.y)
	var dz := (B - A).normalized()
	A -= dz * 0.4
	B += dz * 0.4
	var L := A.distance_to(B)
	var xa := Vector3.UP.cross(dz).normalized()
	var ya_ := dz.cross(xa).normalized()
	parca.append(["ev|%d|c_kalas" % int(round(L * 10.0)), Transform3D(Basis(xa, ya_, dz), A)])
	_kopru_ciz.append([a, b])
	if L > 5.0:
		var m := (A + B) * 0.5
		var g := IstGeo.h(m.x, m.z) - 0.1
		var hh := m.y - 0.12 - g
		parca.append(["ev|%d|c_ayak" % int(round(hh * 10.0)), Transform3D(Basis(Vector3.UP, atan2(dz.x, dz.z)), Vector3(m.x, g, m.z))])


## Bakış kulesi (taş köşk): evin damında, yerel konum lp (lx, lz), merdiven yönü yon (evin yerelinde; kule +z'si).
## Döner: {git: [merdiven dibi, kule tepesi, merdiven dibi]}
const KULE_H := 3.0
const KULE_RISE := 0.25
const KULE_RUN := 0.36

static func _kule(parca: Array, e: Dictionary, lp: Vector2, yon: Vector2) -> Dictionary:
	var c := _yerel(e, lp.x, lp.y)
	var ux: Vector2 = e["ux"]
	var uz: Vector2 = e["uz"]
	var zw := ux * yon.x + uz * yon.y
	var zdir := Vector3(zw.x, 0, zw.y).normalized()
	var xa := Vector3.UP.cross(zdir).normalized()
	var y := float(e["ust"])
	parca.append(["ev|%d|c_kule" % int(round(KULE_H * 10.0)), Transform3D(Basis(xa, Vector3.UP, zdir), Vector3(c.x, y, c.y))])
	var n := int(ceil(KULE_H / KULE_RISE))
	var dip := c + zw.normalized() * (1.6 + n * KULE_RUN + 0.7)
	var tepe := c
	return {"git": [_v3(dip, y), _v3(tepe, y + KULE_H), _v3(dip, y)]}


## Şehir kurucusu çağırır (IstSehir._sehir_dokusu_v2, sokak.build'den hemen sonra): kümenin evleri sokak verisine eklenir
## (doluluk 2, NPC'ler ve dokular görsün), sığmayan ev atlanır (CATI RED satırı). Döner: parçalar [[anahtar, Transform3D]].
static var yerlesen: Array = []
static var red: Array = []

static func uygula(sk: IstSokak) -> Array:
	yerlesen = []
	red = []
	if not acik() or sk == null:
		return []
	var pl := plan()
	var alanlar: Array = []
	if IstSehir.active != null:
		alanlar = IstSehir.active.oyun_alanlari()
	for ad: String in pl["evler"]:
		var h: Dictionary = pl["evler"][ad]
		var e: Dictionary = pl["geo"][ad]
		var neden := _sigmaz(sk, e, alanlar)
		if neden != "":
			red.append("%s:%s" % [ad, neden])
			print("CATI RED %s %s" % [ad, neden])
			continue
		sk.houses.append(h.duplicate())
		yerlesen.append(e)
	# doluluk (ev = 2) bütün sınamalardan SONRA (kümenin bitişik evleri birbirini engellemesin)
	for e: Dictionary in yerlesen:
		var poly: PackedVector2Array = e["dam"]
		for eski: int in [0, 3, 5]:
			sk._fill_poly(poly, 2, eski)
	print("CATI ev=%d red=%d parca=%d rota=%d" % [yerlesen.size(), red.size(), (pl["parca"] as Array).size(), (pl["rotalar"] as Array).size()])
	return pl["parca"]


## Ev sığar mı: taban (çıkma dahil) 0,5 m ızgarada yol/ev/avlu/şehir dışı hücresine, oyun alanına, başka eve değmez
static func _sigmaz(sk: IstSokak, e: Dictionary, alanlar: Array) -> String:
	var poly: PackedVector2Array = e["dam"]
	var c: Vector2 = e["c"]
	var ux: Vector2 = e["ux"]
	var uz: Vector2 = e["uz"]
	var L: float = e["L"]
	var D: float = e["D"]
	var i := -L * 0.5 + 0.3
	while i <= L * 0.5 - 0.3:
		var j := -D * 0.5 + 0.3
		while j <= D * 0.5 - 0.3:
			var q := c + ux * i + uz * j
			var cv := sk.cell(q.x, q.y)
			if cv in [1, 2, 4, 6]:
				return "hucre%d(%.1f,%.1f)" % [cv, q.x, q.y]
			j += 0.5
		i += 0.5
	for a: Rect2 in alanlar:
		for p in poly:
			if a.has_point(p):
				return "oyun_alani"
	for h: Dictionary in sk.houses:
		var hc: Vector2 = h["c"]
		if hc.distance_to(c) > 30.0 or h.get("cati_rota", false):
			continue
		var o := ev_geo(h)
		if IstSokak.poly_gap(poly, o["dam"]) < 0.8:
			return "ev_cakisma(%.1f,%.1f)" % [hc.x, hc.y]
	return ""


## Dokunun (ağaç, yama, harabe, meydan kuyusu) bu noktada yeri var mı: kümenin evlerinin 2,5 m yakınında yok
static func bos_mu(p: Vector2, r := 0.0) -> bool:
	for e: Dictionary in yerlesen:
		var poly: PackedVector2Array = e["dam"]
		if Geometry2D.is_point_in_polygon(p, poly):
			return false
		var c: Vector2 = e["c"]
		if p.distance_to(c) < maxf(float(e["L"]), float(e["D"])) * 0.5 + 2.5 + r:
			return false
	return true


# ---------------------------------------------------------------- parça ağları (IstEvler.mesh "c_*" tipleri)

const C_AHSAP := Color("64523e")
const C_AHSAP_K := Color("4a3a2a")
const C_HALAT := Color("8a7a5a")
const C_SAMAN := Color("85744a")

static func _cozum(v: int) -> Vector3:
	# merdiven kodu: n·100000 + yükselti(mm)·100 + basamak derinliği (cm)
	return Vector3(v / 100000, float((v / 100) % 1000) / 1000.0, float(v % 100) / 100.0)


static func build_parca(host: Node3D, v: int, tip: String, lod: int) -> void:
	match tip:
		"c_kalas":
			var L := v / 10.0
			_kutu(host, Vector3(0.9, 0.12, L), Vector3(0, -0.06, L * 0.5), C_AHSAP, "", lod)
			if lod >= 2:
				return
			# iki kiriş (alttan) ve uç takozları: tek tahta değil, çakılmış kalas
			for sx in [-0.3, 0.3]:
				Props.box(host, Vector3(0.12, 0.14, L - 0.2), Vector3(sx, -0.18, L * 0.5), C_AHSAP_K)
			if lod == 0:
				for i in int(L / 0.9):
					Props.box(host, Vector3(0.92, 0.02, 0.05), Vector3(0, 0.005, 0.45 + i * 0.9), C_AHSAP_K)
				# halat korkuluk: uçlarda dikmeler (kalasa çakılı), aralarında gergin halat
				for sx in [-0.42, 0.42]:
					for z in [0.15, L - 0.15]:
						Props.box(host, Vector3(0.07, 0.95, 0.07), Vector3(sx, 0.47, z), C_AHSAP_K)
					Props.cyl(host, 0.025, L - 0.3, Vector3(sx, 0.9, L * 0.5), C_HALAT, Vector3(90, 0, 0), 5)
		"c_ayak":
			var hh := v / 10.0
			_kutu(host, Vector3(0.2, hh, 0.2), Vector3(0, hh * 0.5, 0), C_AHSAP_K, "", lod)
			if lod < 2:
				Props.box(host, Vector3(1.1, 0.14, 0.24), Vector3(0, hh - 0.07, 0), C_AHSAP_K)
				Props.box(host, Vector3(0.5, 0.3, 0.5), Vector3(0, 0.15, 0), IstEvler.P_TAS[1])
		"c_merd", "c_dmerdL", "c_dmerdR", "c_dmerd0":
			var k := _cozum(v)
			var n := int(k.x)
			var dis := tip != "c_merd"
			var dip := -1.6 if dis else 0.0
			if dis:
				# dipte sokağa doğru üç ek basamak (üstleri −0,02 / −0,32 / −0,62): sokak evin tabanından alçaksa ilk basamak
				# yine ≤ 0,32 m kalır (eğimli zemin, düzlenmiş meydan kıyısı)
				for j in 3:
					var ust := -0.02 - j * 0.3
					_kutu(host, Vector3(1.0, ust - dip, 0.32), Vector3(0, (ust + dip) * 0.5, -0.16 - j * 0.3), IstEvler.P_TAS[1], "ashlar", lod)
			for i in n:
				var hh := (i + 1) * k.y
				var dz := k.z * (2.0 if dis and i == n - 1 else 1.0)
				var zc := i * k.z + dz * 0.5
				_kutu(host, Vector3(1.0, hh - dip, dz + 0.02), Vector3(0, (hh + dip) * 0.5, zc), IstEvler.P_TAS[1], "ashlar", lod)
				if dis and tip != "c_dmerd0":
					var sx := -0.58 if tip == "c_dmerdL" else 0.58
					_kutu(host, Vector3(0.16, hh + 1.0 - dip, dz + 0.02), Vector3(sx, (hh + 1.0 + dip) * 0.5, zc), IstEvler.P_TAS[0], "ashlar", lod)
		"c_kule":
			var hh := v / 10.0
			var tas: Color = IstEvler.P_TAS[0]
			_kutu(host, Vector3(3.2, hh, 3.2), Vector3(0, hh * 0.5, 0), tas, "ashlar", lod)
			# korkuluk (1,0 m): üç yan tam, merdiven yanında 1,2 m ağız
			_kutu(host, Vector3(3.2, 1.0, 0.3), Vector3(0, hh + 0.5, -1.45), tas, "ashlar", lod)
			for sx in [-1, 1]:
				_kutu(host, Vector3(0.3, 1.0, 2.6), Vector3(sx * 1.45, hh + 0.5, 0.0), tas, "ashlar", lod)
				_kutu(host, Vector3(0.4, 1.0, 0.3), Vector3(sx * 1.1, hh + 0.5, 1.45), tas, "ashlar", lod)
			var n := int(ceil(hh / KULE_RISE))
			var r := hh / n
			for i in n:
				var h2 := (i + 1) * r
				_kutu(host, Vector3(1.6, h2, KULE_RUN + 0.02), Vector3(0, h2 * 0.5, 1.6 + (n - 1 - i + 0.5) * KULE_RUN), IstEvler.P_TAS[1], "ashlar", lod)
			# köşk başlığı: korkuluğun dört köşesinde ahşap dikme, üstünde evlerin kiremit beşik çatısı (kutu gibi durmasın;
			# çatı dikmelere oturur, havada değil; altında 2,3 m baş yüksekliği)
			for cx in [-1.45, 1.45]:
				for cz in [-1.45, 1.45]:
					_kutu(host, Vector3(0.24, 1.4, 0.24), Vector3(cx, hh + 1.0 + 0.7, cz), C_AHSAP_K, "", lod)
			IstEvler._roof(host, 3.6, 3.6, Vector3(0, hh + 2.4, 0), IstEvler.P_KIREMIT[1], lod, false, 1)
			if lod < 2:
				# tuğla şerit ve korniş (sur ve evlerle aynı dil)
				Props.box(host, Vector3(3.24, 0.22, 3.24), Vector3(0, hh * 0.55, 0), IstEvler._dk(IstEvler.P_TUGLA, ""))
				Props.box(host, Vector3(3.36, 0.14, 3.36), Vector3(0, hh - 0.07, 0), IstEvler._dk(IstEvler.P_TUGLA, ""))
		"c_saman":
			# saman yığını: yuvarlak, yere basık (kutu değil)
			Props.ball(host, 1.0, Vector3(0, 0.3, 0), C_SAMAN, Vector3(1.4, 0.62, 1.15), 10 if lod == 0 else 6)
			if lod < 2:
				Props.ball(host, 0.7, Vector3(0.5, 0.55, -0.2), C_SAMAN.darkened(0.06), Vector3(1.0, 0.55, 0.9), 8)


static func _kutu(host: Node3D, s: Vector3, p: Vector3, col: Color, desen: String, lod: int) -> void:
	if lod >= 2:
		Props.box(host, s, p, col)
	elif desen != "":
		IstEvler._block(host, s, p, col, desen, lod)
	else:
		Props.box(host, s, p, col)


static func shapes_parca(v: int, tip: String) -> Array:
	var out: Array = []
	match tip:
		"c_kalas":
			var L := v / 10.0
			out.append([IstEvler._bs(Vector3(0.9, 0.12, L)), Transform3D(Basis.IDENTITY, Vector3(0, -0.06, L * 0.5))])
		"c_ayak":
			var hh := v / 10.0
			out.append([IstEvler._bs(Vector3(0.2, hh, 0.2)), Transform3D(Basis.IDENTITY, Vector3(0, hh * 0.5, 0))])
		"c_merd", "c_dmerdL", "c_dmerdR", "c_dmerd0":
			var k := _cozum(v)
			var dip := -1.6 if tip != "c_merd" else 0.0
			if tip != "c_merd":
				for j in 3:
					var ust := -0.02 - j * 0.3
					out.append([IstEvler._bs(Vector3(1.0, ust - dip, 0.32)), Transform3D(Basis.IDENTITY, Vector3(0, (ust + dip) * 0.5, -0.16 - j * 0.3))])
			var n := int(k.x)
			for i in n:
				var hh := (i + 1) * k.y
				var dz := k.z * (2.0 if tip != "c_merd" and i == n - 1 else 1.0)
				var zc := i * k.z + dz * 0.5
				out.append([IstEvler._bs(Vector3(1.0, hh - dip, dz + 0.02)), Transform3D(Basis.IDENTITY, Vector3(0, (hh + dip) * 0.5, zc))])
				if tip in ["c_dmerdL", "c_dmerdR"]:
					var sx := -0.58 if tip == "c_dmerdL" else 0.58
					out.append([IstEvler._bs(Vector3(0.16, hh + 1.0 - dip, dz + 0.02)), Transform3D(Basis.IDENTITY, Vector3(sx, (hh + 1.0 + dip) * 0.5, zc))])
		"c_kule":
			var hh := v / 10.0
			out.append([IstEvler._bs(Vector3(3.2, hh, 3.2)), Transform3D(Basis.IDENTITY, Vector3(0, hh * 0.5, 0))])
			out.append([IstEvler._bs(Vector3(3.2, 1.0, 0.3)), Transform3D(Basis.IDENTITY, Vector3(0, hh + 0.5, -1.45))])
			for cx in [-1.45, 1.45]:
				for cz in [-1.45, 1.45]:
					out.append([IstEvler._bs(Vector3(0.24, 1.4, 0.24)), Transform3D(Basis.IDENTITY, Vector3(cx, hh + 1.7, cz))])
			for sx in [-1, 1]:
				out.append([IstEvler._bs(Vector3(0.3, 1.0, 2.6)), Transform3D(Basis.IDENTITY, Vector3(sx * 1.45, hh + 0.5, 0.0))])
				out.append([IstEvler._bs(Vector3(0.4, 1.0, 0.3)), Transform3D(Basis.IDENTITY, Vector3(sx * 1.1, hh + 0.5, 1.45))])
			var n := int(ceil(hh / KULE_RISE))
			var r := hh / n
			for i in n:
				var h2 := (i + 1) * r
				out.append([IstEvler._bs(Vector3(1.6, h2, KULE_RUN + 0.02)), Transform3D(Basis.IDENTITY, Vector3(0, h2 * 0.5, 1.6 + (n - 1 - i + 0.5) * KULE_RUN))])
		"c_saman":
			var cy := CylinderShape3D.new()
			cy.radius = 1.2
			cy.height = 0.6
			out.append([cy, Transform3D(Basis.IDENTITY, Vector3(0, 0.3, 0))])
	return out
