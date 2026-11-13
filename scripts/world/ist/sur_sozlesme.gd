extends RefCounted
## SUR SÖZLEŞMESİ (dondurulmuş ölçüler) — class_name YOK: `preload("res://scripts/world/ist/sur_sozlesme.gd")`.
##
## Bölümlerin sura bağladığı bütün sayıların TEK kaynağı. İki yarısı var:
##  1. `canli(kesim)`: sayıları o anki kurucudan (IstSurlar.dims/_layout/OPTS/_gate_len, IstSehir gedik kuralı) HESAPLAR.
##  2. `DONMUS`: aynı sayıların 13 Kasım 2026'da bir kez hesaplanıp buraya yazılmış hâli. Oynanış arayüzü (sur_oyun.gd)
##     YALNIZ bunu okur: rng sırası, tohum ya da dilimleme değişse de bölümlerin noktaları kaymaz.
## `tests/_ist/sur_sozlesme.tscn` ikisini kıyaslar (canlı ≠ donmuş → FAIL, hangi kalem) ve donmuş tablonun özetini
## depodaki beklenen özetle kıyaslar (biri tabloyu elle değiştirirse → FAIL). Görünüş turları bu sayıları DEĞİŞTİREMEZ;
## değişmesi gerekiyorsa sahibin kararıyla tablo + beklenen özet birlikte güncellenir ve bölümler yeniden doğrulanır.
##
## Kalemler (docs/SUR_BOLUM_TASIMA.md §5.1 → docs/SUR_SOZLESME.md):
##   kesit     dims(K_SUR) + korkuluk/basamak sabitleri
##   kule      iç kule x/en/çıkıntı, dış kule x (kesim başına)
##   kapi      kapı eni/yüksekliği, kapı koşusu boyu, şehirdeki yeri (YER2)
##   gedik     gedik eni, Romanos'tan uzaklıklar, kesim içindeki yerel x
##   merdiven  iç/dış taş merdiven uçları, basamak sayısı/derinliği, kule tepesi merdiveni
##   hendek    rampa uçları ve boyu, hendek z şeritleri
##   carpisma  yürüme yolu enleri, kule geçitleri, korkuluk
##   oyun      bu sözleşmenin eklediği oynanış yerleri (poterna, köprü/dolgu, dayama, batarya) — kesit sayılarından türer

const K := 1.0                       # IstSehir.K_SUR (sehir.gd:1289); değişirse kesit kalemi kırılır
const SURUM := "2026-11-13"

## Oynanış kesimleri: kara surunun IstSurlar ile kurulan yerleri. "blakherna" ve "halic" ayrı kurucular (Blachernae
## kabuğu, IstHalicSur): bu sözleşmede yalnız konum ve kesit (KISMEN; rapor).
## L: oyun dilimi boyu; tohum ve secenek kurucuya aynen gider. gedik_oyun: oyun gediğinin yerel x'i (karar 4-A: 1. gedik).
## L: oyun dilimi boyu. Kapı kesimleri şehirdeki kapı koşusuyla AYNI dilimdir (IstSehir.GATE_L = 60 m, aynı tohum ve
## seçenek: sehir.gd:1733,1947). Mesoteikhion: 190 m'lik dilim, Romanos kapı koşusunun hemen güneyinde biter (şehirde
## kapı koşusu s 925,9–985,9; 1. gedik s 898,6: kapıdan 57 m güneyde) → oyun gediği dilimin içinde (gedik_oyun hesaplanır).
const KESIMLER := {
	"mesoteikhion": {"tur": "kara", "ad": "Mesoteikhion (Lykos vadisi, 1. gedik)", "L": 190.0, "secenek": "mesoteikhion", "capa": "gedik1", "kuzey_kapi": "romanos"},
	"romanos": {"tur": "kara", "ad": "Aziz Romanos Kapısı", "L": 60.0, "secenek": "romanos", "capa": "romanos"},
	"pege": {"tur": "kara", "ad": "Pege Kapısı", "L": 60.0, "secenek": "pege", "capa": "pege"},
	"rhegion": {"tur": "kara", "ad": "Rhegion Kapısı", "L": 60.0, "secenek": "rhegion", "capa": "rhegion"},
	"pempton": {"tur": "kara", "ad": "Pempton Kapısı", "L": 60.0, "secenek": "pempton", "capa": "pempton"},
	"kharisios": {"tur": "kara", "ad": "Kharisios Kapısı", "L": 60.0, "secenek": "kharisios", "capa": "kharisios"},
	"altin_kapi": {"tur": "kara", "ad": "Altın Kapı", "L": 60.0, "secenek": "altin_kapi", "capa": "altin_kapi"},
	"ksylokerkos": {"tur": "kara", "ad": "Ksylokerkos Kapısı", "L": 60.0, "secenek": "ksylokerkos", "capa": "ksylokerkos"},
}
const KESIM_EK := ["blakherna", "halic"]
const GEDIK_UZAK := [110.0, 215.0, 330.0]   # sehir.gd:2843 (Romanos'a en yakın hat noktasından güneye, m)
const GEDIK_RM := Vector2(-4939.29, 1113.20)  # sehir.gd:2828 (gerçek doğu, kuzey)
const YAN_L := 110.0                       # yan dilimler (HAT "kara_suru" max 110: sehir.gd)
const KULE_GECIT_IC := Vector2(2.2, 3.0)   # sur_kule.gd:414-416 kapi_z0/z1, kapi_h
const KULE_GECIT_DIS := 1.8                # surlar.gd:366 gap_w


## Kesimin kurucu seçenekleri (IstSurlar._run'a giden sözlük). gedik listesi oyun gediğini içerir.
static func secenek(id: String, gx := NAN) -> Dictionary:
	var k: Dictionary = KESIMLER[id]
	var o: Dictionary = (IstSurlar.OPTS[String(k["secenek"])] as Dictionary).duplicate()
	if not is_nan(gx):
		o["gedik"] = [gx]
	return o


## Hat üstünde yay boyu (kara_suru, sade): kapılar YER2'den, gedikler Romanos katalog noktasından (sehir.gd:2824-2844)
static func hat_s() -> Dictionary:
	var pl := IstSehir._sade(IstGeo.yol("kara_suru"))
	var out := {}
	var sn := IstSehir._snap(pl, IstGeo.w2(GEDIK_RM.x, GEDIK_RM.y))
	for i in GEDIK_UZAK.size():
		out["gedik%d" % (i + 1)] = float(sn["s"]) - float(GEDIK_UZAK[i])
	for id in ["altin_kapi", "ksylokerkos", "pege", "rhegion", "romanos", "pempton", "kharisios"]:
		var y: Dictionary = IstSehir.YER2[id]
		out[id] = float(IstSehir._snap(pl, IstGeo.w2(float(y["e"]), float(y["n"])))["s"])
	return out


## Oyun gediğinin dilim içindeki yerel x'i (yerel +x hat boyunca güneye: yay boyu azalır). Dilim kuzey kapının koşusuna
## taşmaz: dilim ortası s_c = s_kapı − GATE_L/2 − L/2; gx = s_c − s_gedik.
static func gedik_oyun_x(id: String) -> float:
	var k: Dictionary = KESIMLER[id]
	if String(k.get("capa", "")) != "gedik1":
		return NAN
	var hs := hat_s()
	var sc := float(hs[String(k["kuzey_kapi"])]) - IstSehir.GATE_L * 0.5 - float(k["L"]) * 0.5
	return snappedf(sc - float(hs["gedik1"]), 0.1)


static func tohum(id: String) -> int:
	return 1000 + String(KESIMLER[id]["secenek"]).hash() % 997


static func _r(v: float, n := 3) -> float:
	return snappedf(v, pow(10.0, -n))


## CANLI hesap (bugünkü kurucudan). Dönen sözlük DONMUS[id] ile aynı biçimde.
static func canli(id: String) -> Dictionary:
	var k: Dictionary = KESIMLER[id]
	var L: float = k["L"]
	var gx := gedik_oyun_x(id)
	var y := yer(id, gx)
	var o := secenek(id, gx)
	if not is_nan(gx):
		o["gedik"] = [gx] + _dekor(y, 0.0, L, gx)
	var lay := IstSurlar._layout(L, K, tohum(id), o)
	var d: Dictionary = lay["d"]
	var out := {}
	# kule
	var itx: Array = []
	for t: Dictionary in lay["itx"]:
		itx.append([_r(float(t["x"])), _r(float(t["w"])), _r(float(t["p"]))])
	# dış kule: gediğe yakın olan kurulmaz (surlar.gd _run: |gedik − kule| < GEDIK_W/2 + OTW/2 + 1 → moloz içinde yıkık)
	var otx: Array = []
	var oty: Array = []
	for x in lay["otx"]:
		var yik := false
		for g in o.get("gedik", []):
			if absf(float(g) - float(x)) < IstSurlar.GEDIK_W * 0.5 + float(d["OTW"]) * 0.5 + 1.0:
				yik = true
		(oty if yik else otx).append(_r(float(x)))
	out["kule"] = {"ic": itx, "dis": otx, "dis_yikik": oty}
	# kapı
	var gh := 0.0
	if float(lay["gw"]) > 0.0:
		gh = minf(float(o.get("gh", 3.6)), float(d["OH"]) - 1.0)
	out["kapi"] = {"gw": _r(float(o.get("gw", 0.0))), "gh": _r(gh),
		"kapali": bool(o.get("kapali", false)), "hendek": bool(o.get("hendek", true)), "L": _r(L), "gx": _r(float(lay["gx"]))}
	# gedik
	var gl: Array = []
	for g in o.get("gedik", []):
		gl.append(_r(float(g)))
	out["gedik"] = {"x": gl, "en": IstSurlar.GEDIK_W, "oyun": 0 if gl.size() > 0 else -1}
	out["yer"] = y
	# merdiven
	var m := {}
	for key in ["in_x0", "in_x1", "in_tread", "in_n", "out_x0", "out_x1", "out_tread", "out_n"]:
		if lay.has(key):
			m[key] = _r(float(lay[key]))
	m["kule_ust_n"] = ceili(float(d["OTH"] - d["OH"]) / IstSurlar.STEP_RISE)
	m["kule_ust_tread"] = 0.42
	m["en"] = 1.8
	out["merdiven"] = m
	# hendek
	out["hendek"] = {"ramp_a_x": _r(float(lay["ramp_a_x"])), "ramp_b_x": _r(float(lay["ramp_b_x"])), "ramp_len": _r(float(lay["ramp_len"])), "ramp_en": 2.6}
	# oyun yerleri (bu sözleşmenin kararı; kesit ve yerleşimden türer)
	out["oyun"] = _oyun_yerleri(lay, o, L)
	# yan dilimler (kesim sahnesinde iki yanda; Mesoteikhion'un kuzeyi şehirdeki Romanos kapı koşusu)
	var yl: Array = []
	for yn: Dictionary in yanlar(id):
		var ly := IstSurlar._layout(float(yn["L"]), K, int(yn["tohum"]), IstSurlar.OPTS.get(String(yn["secenek"]), {"ad": "SurDilimi"}))
		var ym := {}
		for key in ["in_x0", "in_x1", "in_tread", "in_n", "out_x0", "out_x1", "out_tread", "out_n"]:
			if ly.has(key):
				ym[key] = _r(float(ly[key]))
		var yo: Array = []
		for x2 in ly["otx"]:
			yo.append(_r(float(x2)))
		var yi: Array = []
		for t2: Dictionary in ly["itx"]:
			yi.append([_r(float(t2["x"])), _r(float(t2["w"])), _r(float(t2["p"]))])
		yl.append({"ad": yn["ad"], "x": _r(float(yn["x"])), "L": yn["L"], "tohum": yn["tohum"], "secenek": yn["secenek"],
			"merdiven": ym, "kule": {"ic": yi, "dis": yo}, "gedik": _dekor(y, float(yn["x"]), float(yn["L"]), gx) if String(yn["secenek"]) == "SurDilimi" else []})
	out["yan"] = yl
	return out


## Kesimin dünyadaki yeri: şehir kurucusunun kuralıyla (sehir.gd _hat_piece): hat üstüne oturur, yerel +z şehir dışına
## bakar, taban hat boyunca yedi örneğin ortancası; dy = dış kuşak kademesi (IstSurlar.dis_dy; şehirde OTURTMA kaydı
## yoksa arazi). gedik_w: üç gediğin dünya noktası (x, z). Kapı kesimleri kapının hat üstündeki noktasında ortalanır.
static func yer(id: String, gx := NAN) -> Dictionary:
	var k: Dictionary = KESIMLER[id]
	var L: float = k["L"]
	var pl := IstSehir._sade(IstGeo.yol("kara_suru"))
	var sn := IstSehir._snap(pl, IstGeo.w2(GEDIK_RM.x, GEDIK_RM.y))
	var gw: Array = []
	for u in GEDIK_UZAK:
		var q: Vector2 = IstSehir._hat_nokta(pl, float(sn["s"]) - float(u))["p"]
		gw.append([_r(q.x), _r(q.y)])
	var p: Vector2
	var dd: Vector2
	if String(k["capa"]) == "gedik1":
		var hn := IstSehir._hat_nokta(pl, float(sn["s"]) - float(GEDIK_UZAK[0]))
		p = hn["p"]
		dd = hn["d"]
	else:
		var y2: Dictionary = IstSehir.YER2[String(k["capa"])]
		var s2 := IstSehir._snap(pl, IstGeo.w2(float(y2["e"]), float(y2["n"])))
		p = s2["p"]
		dd = s2["d"]
	var yaw := IstSehir._yaw_x(dd, p, "kara_suru")
	var ex := Basis(Vector3.UP, yaw) * Vector3.RIGHT
	var ed := Vector2(ex.x, ex.z)
	if not is_nan(gx):
		p -= ed * gx
	var hs: Array = []
	for i in 7:
		var q2 := p + ed * L * (i / 6.0 - 0.5)
		hs.append(IstGeo.h(q2.x, q2.y))
	hs.sort()
	var lo := maxf(float(hs[3]), IstSurlar.OTURTMA.Y_MIN)
	var xf := Transform3D(Basis(Vector3.UP, yaw), Vector3(p.x, lo - 0.05, p.y))
	var dy := IstSurlar.dis_dy(xf, L, K) if bool((IstSurlar.OPTS[String(k["secenek"])] as Dictionary).get("hendek", true)) else 0.0
	return {"o": [_r(xf.origin.x), _r(xf.origin.y), _r(xf.origin.z)], "yaw": _r(rad_to_deg(yaw), 4), "dy": _r(dy), "gedik_w": gw}


static func xf_of(y: Dictionary) -> Transform3D:
	var o: Array = y["o"]
	return Transform3D(Basis(Vector3.UP, deg_to_rad(float(y["yaw"]))), Vector3(float(o[0]), float(o[1]), float(o[2])))


## Dilimde (orta ox, boy Ly; kesim-yerel) düşen dekor gedikleri: şehir kuralı (sehir.gd:2848-2852: hatta 15 m'den yakın,
## dilim ucuna 9 m'den uzak); oyun gediği hariç. Dilim-yerel x.
static func _dekor(y: Dictionary, ox: float, Ly: float, gx: float) -> Array:
	var inv := xf_of(y).affine_inverse()
	var out: Array = []
	for w in y["gedik_w"]:
		var lv := inv * Vector3(float(w[0]), float(y["o"][1]), float(w[1]))
		var lx := lv.x - ox
		if absf(lv.z) < 15.0 and absf(lx) < Ly * 0.5 - 9.0 and (is_nan(gx) or absf(lv.x - gx) > 1.0):
			out.append(_r(lx, 2))
	return out


## Yan dilimler: {"ad", "x" (kesim-yerel orta), "L", "tohum", "secenek" (OPTS anahtarı ya da "SurDilimi")}
static func yanlar(id: String) -> Array:
	var k: Dictionary = KESIMLER[id]
	var L: float = k["L"]
	var out: Array = []
	for s: float in [-1.0, 1.0]:
		if s < 0.0 and k.has("kuzey_kapi"):
			var kid := String(k["kuzey_kapi"])
			out.append({"ad": "YanKapi_" + kid, "x": -(L * 0.5 + IstSehir.GATE_L * 0.5), "L": IstSehir.GATE_L,
				"tohum": 1000 + kid.hash() % 997, "secenek": kid})
			continue
		out.append({"ad": "YanDilim_%s" % ("eksi" if s < 0.0 else "arti"), "x": s * (L * 0.5 + YAN_L * 0.5), "L": YAN_L,
			"tohum": tohum(id) + (7 if s < 0.0 else 13), "secenek": "SurDilimi"})
	return out


## Kesimden bağımsız kalemler (kesit, gedik kuralı, çarpışma)
static func canli_ortak() -> Dictionary:
	var d := IstSurlar.dims(K)
	var kes := {}
	for key in d:
		kes[key] = _r(float(d[key]))
	kes["PARAPET_H"] = IstSurlar.PARAPET_H
	kes["PARAPET_T"] = IstSurlar.PARAPET_T
	kes["STEP_RISE"] = IstSurlar.STEP_RISE
	kes["K_SUR"] = IstSehir.K_SUR
	kes["moat_z0"] = _r(float(IstSurlar.moat_strip(K)["z0"]))
	kes["moat_z1"] = _r(float(IstSurlar.moat_strip(K)["z1"]))
	var car := {
		"yol_ic_en": _r(float(d["T"]) - 2.0 * IstSurlar.PARAPET_T),
		"yol_dis_en": _r(float(d["OT"]) - 2.0 * IstSurlar.PARAPET_T),
		"kule_gecit_ic": [KULE_GECIT_IC.x, KULE_GECIT_IC.y],
		"kule_gecit_dis": KULE_GECIT_DIS,
		"korkuluk": [IstSurlar.PARAPET_T, IstSurlar.PARAPET_H],
		"dis_kule_gap_w": 1.8,
	}
	var gate := {}
	for id in IstSurlar.OPTS:
		var o: Dictionary = IstSurlar.OPTS[id]
		gate[id] = [_r(float(o.get("gw", 0.0))), _r(float(o.get("gh", 0.0))), _r(IstSurlar._gate_len(id, K)), IstSehir.GATE_L]
	var yer := {}
	for id in ["altin_kapi", "ksylokerkos", "pege", "rhegion", "romanos", "pempton", "kharisios", "kerkoporta"]:
		var y: Dictionary = IstSehir.YER2[id]
		yer[id] = [float(y["e"]), float(y["n"])]
	var hs := hat_s()
	for k2 in hs:
		yer["s_" + k2] = _r(float(hs[k2]), 1)
	return {"kesit": kes, "carpisma": car, "kapi_olcu": gate, "kapi_yer": yer,
		"gedik_kural": {"en": IstSurlar.GEDIK_W, "uzak": GEDIK_UZAK, "rm": [GEDIK_RM.x, GEDIK_RM.y]}}


## Oyun yerleri: poterna, hendek geçişleri (köprü/dolgu), dayama noktaları, batarya, kapı köprüsü.
## Kural (sözleşmeye yazılan, sonra donan): her şey kule/merdiven/gedik/kapı boşluklarından en az 3 m uzakta.
static func _oyun_yerleri(lay: Dictionary, o: Dictionary, L: float) -> Dictionary:
	var d: Dictionary = lay["d"]
	var dolu: Array = []        # dış surun ova yüzünde dolu aralıklar
	var ow: float = d["OTW"]
	for x in lay["otx"]:
		dolu.append([float(x) - ow * 0.5 - 3.0, float(x) + ow * 0.5 + 3.0])
	for g in o.get("gedik", []):
		dolu.append([float(g) - IstSurlar.GEDIK_W * 0.5 - 3.0, float(g) + IstSurlar.GEDIK_W * 0.5 + 3.0])
	var gw: float = lay["gw"]
	if gw > 0.0:
		dolu.append([-gw * 0.5 - 4.0, gw * 0.5 + 4.0])
	# iç yüzde dış merdiven (poterna içeriden peribolosa açılır: merdivenin önüne düşmesin)
	var ic_dolu: Array = dolu.duplicate()
	if lay.has("out_x0"):
		ic_dolu.append([float(lay["out_x0"]) - 3.0, float(lay["out_x1"]) + 3.0])
	var xa := -L * 0.5 + 8.0
	var xb := L * 0.5 - 8.0
	# poterna: oyun gediğinden ya da kapıdan dilimin ortasına en yakın serbest yer (Mesoteikhion'da gediğin şehir-yanı
	# değil, sur boyunca 14–40 m yanında: 26'da "poternadan çık, gediğe koş"; 36b'de gizli çıkış)
	var g0: float = float((o.get("gedik", []) as Array)[0]) if (o.get("gedik", []) as Array).size() > 0 else 0.0
	var pot := _bos_yakin(IstSurlar._segs(xa, xb, ic_dolu), g0 - 22.0, 1.4)
	# dayama noktaları (el merdiveni; karar 8-A: sayı aynı = 5): serbest dış yüz parçalarında eşit dağıt
	var day: Array = []
	var serbest := IstSurlar._segs(xa, xb, dolu + [[pot - 3.0, pot + 3.0]])
	var top := 0.0
	for s in serbest:
		top += float(s[1]) - float(s[0])
	var n := 5
	for i in n:
		var hedef := top * (i + 0.5) / n
		var acc := 0.0
		for s in serbest:
			var sl := float(s[1]) - float(s[0])
			if acc + sl >= hedef:
				day.append(_r(float(s[0]) + hedef - acc, 2))
				break
			acc += sl
	# hendek geçişleri (karar 7-A): kalas köprü ve dolgu yerleri; gediğin önü (dolgu: 22o/26o/32o) ve poterna önü (kalas: 36b, 37o)
	var ramp_a: float = lay["ramp_a_x"]
	var gec: Array = []
	var dolgu_x := g0 if (o.get("gedik", []) as Array).size() > 0 else _bos_yakin(IstSurlar._segs(xa, xb, dolu), L * 0.18, 1.0)
	gec.append({"tur": "dolgu", "x": _r(dolgu_x, 2), "en": 10.0})
	var kalas_x := _bos_yakin(IstSurlar._segs(xa, xb, dolu + [[dolgu_x - 9.0, dolgu_x + 9.0], [ramp_a - 12.0, ramp_a + 4.0]]), pot, 1.0)
	gec.append({"tur": "kalas", "x": _r(kalas_x, 2), "en": 1.6})
	if gw > 0.0:
		gec.append({"tur": "kapi_kopru", "x": 0.0, "en": gw + 1.2})
	# batarya: hendeğin dış yakasından 45 m ötede, gediğe/kapıya bakan iki yuva (eski set z 92–94: hendek kıyısı 36 + 56)
	var bat: Array = []
	for dx: float in [-24.0, 18.0]:
		bat.append([_r(g0 + dx, 2), _r(float(d["zm1"]) + 45.0, 2)])
	return {"poterna": _r(pot, 2), "dayama": day, "gecis": gec, "batarya": bat, "dayama_egim": 16.0, "dayama_ust_pay": 1.5}


## Serbest aralıklarda hedefe en yakın, kenara en az `pay` uzaklıktaki x
static func _bos_yakin(segs: Array, hedef: float, pay: float) -> float:
	var best := hedef
	var bd := INF
	for s in segs:
		var a := float(s[0]) + pay
		var b := float(s[1]) - pay
		if b < a:
			continue
		var x := clampf(hedef, a, b)
		if absf(x - hedef) < bd:
			bd = absf(x - hedef)
			best = x
	return best


# ------------------------------------------------------------------ DONMUŞ TABLO
## Üretim: `tests/_ist/sur_sozlesme.tscn -- --uret` (yalnız ilk kurulumda; sonra elle değiştirilmez)
const DONMUS_YOL := "res://scripts/world/ist/sur_sozlesme_donmus.json"
static var _donmus: Dictionary = {}

static func donmus() -> Dictionary:
	if _donmus.is_empty():
		var f := FileAccess.open(DONMUS_YOL, FileAccess.READ)
		if f == null:
			push_error("SURSOZLESME donmus tablo yok: " + DONMUS_YOL)
			return {}
		_donmus = JSON.parse_string(f.get_as_text())
	return _donmus


static func kesim(id: String) -> Dictionary:
	return (donmus().get("kesim", {}) as Dictionary).get(id, {})


static func ortak() -> Dictionary:
	return donmus().get("ortak", {})


static func kesit() -> Dictionary:
	return ortak().get("kesit", {})


## Sözlüğü kararlı metne çevirir (anahtar sırası sabit; özet için)
static func duz(v: Variant) -> String:
	if v is Dictionary:
		var ks: Array = (v as Dictionary).keys()
		ks.sort()
		var p: Array = []
		for k2 in ks:
			p.append("%s:%s" % [k2, duz(v[k2])])
		return "{" + ",".join(p) + "}"
	if v is Array:
		var q: Array = []
		for e in v:
			q.append(duz(e))
		return "[" + ",".join(q) + "]"
	if v is float or v is int:
		return "%.3f" % float(v)
	return str(v)


## Kalem kalem özet (sha256'nın ilk 12 hanesi)
static func ozet(tablo: Dictionary) -> Dictionary:
	var out := {}
	var o: Dictionary = tablo.get("ortak", {})
	for k2 in ["kesit", "carpisma", "kapi_olcu", "kapi_yer", "gedik_kural"]:
		out[k2] = duz(o.get(k2, {})).sha256_text().substr(0, 12)
	var ks: Dictionary = tablo.get("kesim", {})
	for kalem in ["yer", "kule", "kapi", "gedik", "merdiven", "hendek", "oyun", "yan"]:
		var parca: Array = []
		var ids: Array = ks.keys()
		ids.sort()
		for id in ids:
			parca.append("%s=%s" % [id, duz((ks[id] as Dictionary).get(kalem, {}))])
		out[kalem] = ";".join(parca).sha256_text().substr(0, 12)
	return out


static func canli_tablo() -> Dictionary:
	var ks := {}
	for id in KESIMLER:
		ks[id] = canli(id)
	return {"surum": SURUM, "ortak": canli_ortak(), "kesim": ks}
