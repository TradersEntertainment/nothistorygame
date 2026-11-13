extends RefCounted
## SUR OYNANIŞ ARAYÜZÜ (İstanbul v2 kara suru) — class_name YOK: `const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")`
##
## Bölümler sura sabit koordinat yazmaz; kesim adıyla sorar. Bütün sayılar DONMUŞ sözleşmeden (sur_sozlesme.gd) gelir.
##   var a = SurOyun.arayuz("mesoteikhion")        # yalnız veri (kurulum yok): dünya yerleşimi + sorgular
##   var k = SurOyun.kur("mesoteikhion", {...})    # kesim sahnesi: {"kok": Node3D, "arayuz": a, "parca": {...}, "ms": ...}
## Sorgular yerel çerçevede (IstSurlar ile aynı: +x sur boyunca, +z ova, z=0 iç sur ortası, y=0 dilim tabanı) nokta verir;
## her nokta {"yerel": Vector3, "dunya": Vector3} (dunya = a.xf * yerel). Bölüm yerel çalışır: kökünü a.xf'e koyar.
##
## Sorgu listesi: yol(kat), cikislar(), dayamalar(), mazgallar(kat), bataryalar(), gedik(), hendek(), kapi(), poterna(),
## alanlar(), dogma(alan, n), engeller(), noktalar() (denetim: hepsi tek listede, tür etiketiyle).

const SZ := preload("res://scripts/world/ist/sur_sozlesme.gd")
const PARCA := preload("res://scripts/world/ist/sur_oyun_parca.gd")
const AG := preload("res://scripts/world/ist/sur_oyun_ag.gd")

var id := ""
var kesim: Dictionary = {}       # sözleşme (donmuş) kesim satırı
var d: Dictionary = {}           # donmuş kesit
var L := 190.0
var xf := Transform3D()          # kesim kökünün dünya dönüşümü
var dy := 0.0                    # dış kuşak (teras, hendek, ova) kademesi (IstSurlar.dis_dy)
var gx := NAN                    # oyun gediği yerel x (yoksa NAN)
var asama := 1                   # gedik onarım aşaması 1..4 (PARCA.ASAMALAR; kurulunca parça günceller)
var gedik_w: Array = []          # üç gediğin dünya noktası (Vector2, şehir kuralı sehir.gd:2824-2853)


# ------------------------------------------------------------------ kurulum (veri)

static func arayuz(p_id: String) -> RefCounted:
	var a: RefCounted = (load("res://scripts/world/ist/sur_oyun.gd") as GDScript).new()
	a._kur_veri(p_id)
	return a


func _kur_veri(p_id: String) -> void:
	id = p_id
	kesim = SZ.kesim(id)
	d = SZ.kesit()
	var tanim: Dictionary = SZ.KESIMLER[id]
	L = float(tanim["L"])
	var g: Array = kesim["gedik"]["x"]
	gx = float(g[0]) if g.size() > 0 else NAN
	var y: Dictionary = kesim["yer"]
	xf = SZ.xf_of(y)
	dy = float(y["dy"])
	gedik_w.clear()
	for w in y["gedik_w"]:
		gedik_w.append(Vector2(float(w[0]), float(w[1])))


## Dekor gedikler (oyun gediği dışındakiler; karar 4-A): kesim-yerel x
func dekor_gedik() -> Array:
	var g: Array = kesim["gedik"]["x"]
	return g.slice(1)


func n(v: Vector3) -> Dictionary:
	return {"yerel": v, "dunya": xf * v}


func dunya(v: Vector3) -> Vector3:
	return xf * v


func yerel(w: Vector3) -> Vector3:
	return xf.affine_inverse() * w


# ------------------------------------------------------------------ yükseklikler (yerel)

const ZEMIN_Y := -0.12           # şehir önü, peribolos ve teras toprağının üstü (surlar.gd:440-462 levhaları)

func y_peri() -> float:
	return ZEMIN_Y

func y_teras() -> float:
	return dy + ZEMIN_Y

func y_ova() -> float:
	return dy - 0.02

func y_hendek_dip() -> float:
	return dy - float(d["MD"])

func zc_dis() -> float:
	return (float(d["zo0"]) + float(d["zo1"])) * 0.5


# ------------------------------------------------------------------ sorgular

## Sur yürüme yolu: {"kat", "y", "en", "z", "nokta": [n…] (çoklu çizgi; dış surda kule tepesine basamakla çıkıp iner),
## "gecit": [[x0, x1, tür]…] (kule geçidi/üstü), "kesik": [[x0, x1, neden]…] (yürünmez: gedik)}
func yol(kat := "ic") -> Dictionary:
	var x0 := -L * 0.5 + 1.0
	var x1 := L * 0.5 - 1.0
	var pts: Array = []
	var gec: Array = []
	var kes: Array = []
	if kat == "ic":
		var y := float(d["HW"])
		pts.append(n(Vector3(x0, y, 0.0)))
		for t in kesim["kule"]["ic"]:
			var cx := float(t[0])
			var w := float(t[1])
			gec.append([cx - w * 0.5, cx + w * 0.5, "ic_kule_gecidi %.1fx%.1f" % [SZ.KULE_GECIT_IC.x, SZ.KULE_GECIT_IC.y]])
			pts.append(n(Vector3(cx - w * 0.5 - 0.3, y, 0.0)))
			pts.append(n(Vector3(cx + w * 0.5 + 0.3, y, 0.0)))
		pts.append(n(Vector3(x1, y, 0.0)))
		return {"kat": kat, "y": y, "en": float(SZ.ortak()["carpisma"]["yol_ic_en"]), "z": 0.0, "nokta": pts, "gecit": gec, "kesik": kes}
	var yo := float(d["OH"])
	var zc := zc_dis()
	var ow := float(d["OTW"])
	var lt: int = int(kesim["merdiven"]["kule_ust_n"])
	var tr: float = float(kesim["merdiven"]["kule_ust_tread"])
	var oth := float(d["OTH"])
	pts.append(n(Vector3(x0, yo, zc)))
	var olaylar: Array = []
	for cx in kesim["kule"]["dis"]:
		olaylar.append([float(cx), "kule"])
	for cx in kesim["kule"].get("dis_yikik", []):
		olaylar.append([float(cx), "yikik"])
	if not is_nan(gx):
		olaylar.append([gx, "gedik"])
	for dg in dekor_gedik():
		olaylar.append([float(dg), "dekor"])
	olaylar.sort_custom(func(a, b): return float(a[0]) < float(b[0]))
	for o in olaylar:
		var cx := float(o[0])
		if o[1] == "kule":
			var a := cx - ow * 0.5 - lt * tr
			gec.append([a, cx + ow * 0.5 + lt * tr, "dis_kule_ustu (basamak %d×%.2f, korkuluk geçidi %.1f)" % [lt, tr, SZ.KULE_GECIT_DIS]])
			pts.append(n(Vector3(a - 0.4, yo, zc)))
			pts.append(n(Vector3(cx - ow * 0.5, oth, zc)))
			pts.append(n(Vector3(cx + ow * 0.5, oth, zc)))
			pts.append(n(Vector3(cx + ow * 0.5 + lt * tr + 0.4, yo, zc)))
		elif o[1] == "yikik":
			# BULGU (v2, görünüş değiştirilmedi): gedik yanındaki dış kule kurulmuyor ama iki yanındaki kule tepesi
			# basamakları kuruluyor (surlar.gd _run "for cx3 in otx"); sur yolu orada basamakla 13 m'ye çıkıp boşluğa biter
			var a2 := cx - ow * 0.5 - lt * tr
			kes.append([a2, cx + ow * 0.5 + lt * tr, "yikik_dis_kule (basamak boşluğa çıkar)"])
			pts.append(n(Vector3(a2 - 0.4, yo, zc)))
		elif o[1] == "dekor":
			gec.append([cx - IstSurlar.GEDIK_W * 0.5, cx + IstSurlar.GEDIK_W * 0.5, "dekor_gedik_tahtasi (stauroma)"])
		else:
			var h := IstSurlar.GEDIK_W * 0.5
			if asama >= 4:
				gec.append([cx - h, cx + h, "gedik_tahtasi (asama %d)" % asama])
			else:
				kes.append([cx - h, cx + h, "gedik (asama %d: yol kesik)" % asama])
			pts.append(n(Vector3(cx - h - 0.4, yo, zc)))
			pts.append(n(Vector3(cx + h + 0.4, yo, zc)))
	pts.append(n(Vector3(x1, yo, zc)))
	return {"kat": kat, "y": yo, "en": float(SZ.ortak()["carpisma"]["yol_dis_en"]), "z": zc, "nokta": pts, "gecit": gec, "kesik": kes}


## Taş merdivenler (karar 2-A: savunma tarafı): [{"ad", "alt", "ust", "yol" (sur yolundaki çıkış), "en", "basamak"}]
func cikislar() -> Array:
	var out: Array = _cikis(kesim["merdiven"], 0.0, "")
	for yn: Dictionary in kesim["yan"]:
		for c: Dictionary in _cikis(yn["merdiven"], float(yn["x"]), String(yn["ad"]) + "/"):
			# dekor gediğin stauroması merdivenin önüne düşüyorsa (şehirdeki gibi) bu çıkış kullanılamaz: verilmez
			var ax2: float = (c["alt"]["yerel"] as Vector3).x
			var ux2: float = (c["ust"]["yerel"] as Vector3).x
			var kapali := false
			for g2 in yn["gedik"]:
				var gxx := float(yn["x"]) + float(g2)
				if gxx > minf(ax2, ux2) - IstSurlar.GEDIK_W * 0.5 - 2.0 and gxx < maxf(ax2, ux2) + IstSurlar.GEDIK_W * 0.5 + 2.0:
					kapali = true
			if not kapali:
				out.append(c)
	return out


func _cikis(m: Dictionary, ox: float, on_ek: String) -> Array:
	var out: Array = []
	var zi0 := float(d["zi0"])
	var zo0 := float(d["zo0"])
	if m.has("in_x0"):
		out.append({"ad": on_ek + "ic_sur", "alt": n(Vector3((ox + float(m["in_x0"])) - 0.8, y_peri(), zi0 - 0.9)), "ust": n(Vector3((ox + float(m["in_x1"])) + 0.7, float(d["HW"]), zi0 - 0.9)),
			"yol": n(Vector3((ox + float(m["in_x1"])) + 0.7, float(d["HW"]), 0.0)), "en": 1.8, "basamak": [int(m["in_n"]), float(m["in_tread"]), IstSurlar.STEP_RISE], "taraf": "sehir"})
	if m.has("out_x0"):
		out.append({"ad": on_ek + "dis_sur", "alt": n(Vector3((ox + float(m["out_x0"])) - 0.8, y_peri(), zo0 - 0.9)), "ust": n(Vector3((ox + float(m["out_x1"])) + 0.5, float(d["OH"]), zo0 - 0.9)),
			"yol": n(Vector3((ox + float(m["out_x1"])) + 0.5, float(d["OH"]), zc_dis())), "en": 1.8, "basamak": [int(m["out_n"]), float(m["out_tread"]), IstSurlar.STEP_RISE], "taraf": "peribolos"})
	return out


## Dış yüzde el merdiveni dayama noktaları (karar 2-A hücum tarafı, 8-A sayı 5): {"x", "tepe", "ayak", "egim" (derece,
## Ladder.tilt), "boy" (Ladder.height), "on" (merdivenin önü: +z), "yol" (tepeden inilen sur yolu noktası)}
## Ladder kuralı (scripts/level/ladder.gd): düğüm "ayak"ta, dönüşsüz (yerel +z ön), tilt arkaya: tepe = ayak + boy·(0, cos, −sin).
func dayamalar() -> Array:
	var out: Array = []
	var eg: float = float(kesim["oyun"]["dayama_egim"])
	var pay: float = float(kesim["oyun"]["dayama_ust_pay"])
	var zo1 := float(d["zo1"])
	for x in kesim["oyun"]["dayama"]:
		var gy := y_teras()
		var ty := float(d["OH"]) + pay
		var boy := (ty - gy) / cos(deg_to_rad(eg))
		var ayak := Vector3(float(x), gy, zo1 + 0.12 + boy * sin(deg_to_rad(eg)))
		var tepe := ayak + Vector3(0.0, boy * cos(deg_to_rad(eg)), -boy * sin(deg_to_rad(eg)))
		out.append({"x": float(x), "ayak": n(ayak), "tepe": n(tepe), "egim": eg, "boy": boy, "on": Vector3.BACK,
			"yol": n(Vector3(float(x), float(d["OH"]), zc_dis())), "basamak_araligi": Ladder.RUNG, "en": Ladder.WIDTH})
	return out


## Mazgallar (dişler arası açıklık): {"p" (açıklığın dibi, korkuluk üstü), "ayak" (savunucunun durduğu yer), "bakis"}
func mazgallar(kat := "dis") -> Array:
	var out: Array = []
	var y: float
	var z: float
	var cut: Array = []
	var zayak: float
	if kat == "ic":
		y = float(d["HW"])
		z = float(d["zi1"]) - IstSurlar.PARAPET_T * 0.5
		zayak = 1.2
		for t in kesim["kule"]["ic"]:
			cut.append([float(t[0]) - float(t[1]) * 0.5, float(t[0]) + float(t[1]) * 0.5])
	else:
		y = float(d["OH"])
		z = float(d["zo1"]) - IstSurlar.PARAPET_T * 0.5
		zayak = zc_dis()
		var bas := float(kesim["merdiven"]["kule_ust_n"]) * float(kesim["merdiven"]["kule_ust_tread"]) + 0.6
		for cx in (kesim["kule"]["dis"] as Array) + (kesim["kule"].get("dis_yikik", []) as Array):
			cut.append([float(cx) - float(d["OTW"]) * 0.5 - bas, float(cx) + float(d["OTW"]) * 0.5 + bas])
		for g2 in kesim["gedik"]["x"]:
			cut.append([float(g2) - IstSurlar.GEDIK_W * 0.5 - 0.5, float(g2) + IstSurlar.GEDIK_W * 0.5 + 0.5])
		var gw := float(kesim["kapi"]["gw"])
		if gw > 0.0:
			cut.append([-gw * 0.5, gw * 0.5])
	for s in IstSurlar._segs(-L * 0.5, L * 0.5, cut):
		var a := float(s[0])
		var b := float(s[1])
		var m := floori((b - a) / 1.8)
		var off := ((b - a) - m * 1.8) * 0.5
		for i in m - 1:
			var xx := a + off + 0.9 + i * 1.8 + 0.9          # iki diş arası (surlar.gd _parapet_x)
			out.append({"p": n(Vector3(xx, y + IstSurlar.PARAPET_H, z)), "ayak": n(Vector3(xx, y, zayak)), "bakis": Vector3.BACK})
	return out


## Top yuvaları (ovada): {"p", "bakis" (gediğe/kapıya)}
func bataryalar() -> Array:
	var out: Array = []
	var hedef := Vector3(0.0 if is_nan(gx) else gx, 4.0, float(d["zo1"]))
	for b in kesim["oyun"]["batarya"]:
		var p := Vector3(float(b[0]), y_ova(), float(b[1]))
		out.append({"p": n(p), "bakis": (hedef - p).normalized()})
	return out


## Oyun gediği (karar 4-A): {"x", "dikdortgen" (Rect2 x/z), "beden_y", "asama", "moloz": {"peri", "tepe", "teras", "hendek"}}
func gedik() -> Dictionary:
	if is_nan(gx):
		return {}
	var zo0 := float(d["zo0"])
	var zo1 := float(d["zo1"])
	var h := IstSurlar.GEDIK_W * 0.5
	var r := AG.moloz_profil(self)
	return {"x": gx, "dikdortgen": Rect2(gx - h, zo0, IstSurlar.GEDIK_W, zo1 - zo0), "beden_y": 0.8, "asama": asama,
		"moloz": {"peri": n(Vector3(gx, r["peri_y"], r["peri_z"])), "tepe": n(Vector3(gx, r["tepe_y"], zc_dis())),
			"teras": n(Vector3(gx, r["teras_y"], r["teras_z"])), "hendek": n(Vector3(gx, y_hendek_dip(), r["dip_z"]))},
		"asamalar": PARCA.ASAMALAR}


## Hendek: kıyılar, dip, rampalar ve geçiş yerleri (karar 7-A). gecis: [{"tur", "x", "en", "yakin", "uzak"}]
func hendek() -> Dictionary:
	if not bool(kesim["kapi"]["hendek"]):
		return {}
	var zm0 := float(d["zm0"])
	var zm1 := float(d["zm1"])
	var gec: Array = []
	for g in kesim["oyun"]["gecis"]:
		var x := float(g["x"])
		var tur := String(g["tur"])
		var za := zm0 - 2.4 if tur != "kapi_kopru" else zm0 + 4.5
		var zb := zm1 + 1.5 if tur != "kapi_kopru" else zm1 - 4.5
		var ya := y_teras()
		if tur == "dolgu" and not is_nan(gx) and absf(x - gx) < 1.0:
			ya = AG._profil_y(AG.moloz_profil(self)["pts"], za)
		gec.append({"tur": tur, "x": x, "en": float(g["en"]), "yakin": n(Vector3(x, ya, za)), "uzak": n(Vector3(x, y_ova(), zb))})
	var h: Dictionary = kesim["hendek"]
	var rl := float(h["ramp_len"])
	var ax := float(h["ramp_a_x"])
	var bx := float(h["ramp_b_x"])
	# kısa kapı koşusunda (60 m) rampa ayağı dilimin dışına, komşu dilimin hendek uç bölmesine düşer: yürünür değil
	var rampa: Array = []
	if ax - rl - 1.0 > -L * 0.5 + 3.5:
		rampa.append({"ust": n(Vector3(ax - 0.4, y_teras(), zm0 - 2.4)), "alt": n(Vector3(ax - rl - 1.0, y_hendek_dip(), zm0 + 1.3))})
	if bx + rl + 1.0 < L * 0.5 - 3.5:
		rampa.append({"ust": n(Vector3(bx + 0.4, y_ova(), zm1 + 1.5)), "alt": n(Vector3(bx + rl + 1.0, y_hendek_dip(), zm1 - 1.3))})
	return {"yakin_z": zm0, "uzak_z": zm1, "yaka_y": dy, "dip_y": y_hendek_dip(), "en": float(d["MW"]), "derinlik": float(d["MD"]),
		"yakin_kiyi": n(Vector3(0.0, dy, zm0)), "uzak_kiyi": n(Vector3(0.0, dy, zm1)),
		"rampa": rampa,
		"gecis": gec}


## Kapı (kapı kesimlerinde): {"en", "boy", "kapali", "ic_esik", "dis_esik", "kopru_yakin", "kopru_uzak"}
func kapi() -> Dictionary:
	var gw := float(kesim["kapi"]["gw"])
	if gw <= 0.0:
		return {}
	return {"en": gw, "boy": float(kesim["kapi"]["gh"]), "kapali": bool(kesim["kapi"]["kapali"]),
		"ic_esik": n(Vector3(0.0, y_peri(), float(d["zi0"]) - 1.5)), "peri": n(Vector3(0.0, y_peri(), (float(d["zi1"]) + float(d["zo0"])) * 0.5)),
		"dis_esik": n(Vector3(0.0, y_teras() if y_teras() > -0.3 else lerpf(-0.04, dy + 0.02, (1.5 - 0.6) / (float(d["zm0"]) - 0.9 - float(d["zo1"]) - 0.6)), float(d["zo1"]) + 1.5)),
		"kopru_yakin": n(Vector3(0.0, dy, float(d["zm0"]) + 4.5)), "kopru_uzak": n(Vector3(0.0, dy, float(d["zm1"]) - 4.5))}


## Poterna (karar 10-A): {"x", "en", "boy", "ic" (peribolos tarafı), "dis" (teras tarafı), "esik"}
func poterna() -> Dictionary:
	var x := float(kesim["oyun"]["poterna"])
	var dis := Vector3(x, y_teras(), float(d["zo1"]) + 1.6)
	var sah := Vector3(x, -0.02, float(d["zo1"]) + 0.65)
	if y_teras() < -0.3:
		# dış kuşak aşağıda: kapı önünde sahanlık, sur yüzü boyunca +x'e inen taş basamak (sur_oyun_parca Poterna)
		var nst := ceili((-0.02 - y_teras()) / IstSurlar.STEP_RISE)
		dis = Vector3(x + IstSurlar.POTERNA_W * 0.5 + 0.4 + nst * 0.32 + 0.9, y_teras(), float(d["zo1"]) + 0.65)
	return {"x": x, "en": IstSurlar.POTERNA_W, "boy": IstSurlar.POTERNA_H, "esik": n(Vector3(x, y_peri(), zc_dis())),
		"ic": n(Vector3(x, y_peri(), float(d["zo0"]) - 1.4)), "sahanlik": n(sah), "dis": n(dis)}


## Yürünür alanlar (yerel Rect2 x/z + y). Engeller ayrı (engeller()).
func alanlar() -> Dictionary:
	var x0 := -L * 0.5 + 2.0
	var w := L - 4.0
	return {
		"sehir": {"r": Rect2(x0, float(d["zi0"]) - 36.0, w, 33.0), "y": y_peri()},
		"peribolos": {"r": Rect2(x0, float(d["zi1"]) + 3.4, w, float(d["PW"]) - 6.8), "y": y_peri()},
		"teras": {"r": Rect2(x0, float(d["zo1"]) + 2.9, w, float(d["PTW"]) - 2.9 - 4.3), "y": y_teras()},
		"ova": {"r": Rect2(x0, float(d["zm1"]) + 3.0, w, 110.0), "y": y_ova()},
		"hendek_dibi": {"r": Rect2(x0 + 3.5, float(d["zm0"]) + 1.0, w - 7.0, float(d["MW"]) - 2.0), "y": y_hendek_dip()},
	}


## Kişi konamayacak taban alanları (yerel Rect2 x/z, 0,4 m paylı): kuleler, merdivenler, gedik molozu, rampa, köprü/dolgu,
## kapı geçidi, parateikhion duvarı, dayalı merdiven ayakları
func engeller() -> Array:
	var r: Array = []
	var zi0 := float(d["zi0"])
	var zi1 := float(d["zi1"])
	var zo0 := float(d["zo0"])
	var zo1 := float(d["zo1"])
	for t in kesim["kule"]["ic"]:
		# kule + dibindeki etek (OTURTMA: 3 m)
		r.append(Rect2(float(t[0]) - float(t[1]) * 0.5 - 3.0, zi0 - 1.5, float(t[1]) + 6.0, zi1 + float(t[2]) - zi0 + 4.5))
	for cx in kesim["kule"]["dis"]:
		r.append(Rect2(float(cx) - float(d["OTW"]) * 0.5 - 1.0, zo0 - 1.0, float(d["OTW"]) + 2.0, float(d["OT"]) + float(d["OTP"]) + 2.5))
	var m: Dictionary = kesim["merdiven"]
	if m.has("in_x0"):
		r.append(Rect2(float(m["in_x0"]) - 1.5, zi0 - 3.0, float(m["in_x1"]) - float(m["in_x0"]) + 3.5, 3.0))
	if m.has("out_x0"):
		r.append(Rect2(float(m["out_x0"]) - 1.5, zo0 - 3.0, float(m["out_x1"]) - float(m["out_x0"]) + 3.0, 3.0))
	for g2 in kesim["gedik"]["x"]:
		r.append(Rect2(float(g2) - 7.0, zo0 - 9.0, 14.0, float(d["zm0"]) - zo0 + 9.0))
	r.append(Rect2(-L * 0.5, float(d["zm0"]) - 2.6, L, 2.6))            # parateikhion + hendek kıyısı
	r.append(Rect2(-L * 0.5, zi0 - 0.6, L, zi1 - zi0 + 1.2))
	r.append(Rect2(-L * 0.5, zo0 - 0.6, L, zo1 - zo0 + 1.2))
	for g in kesim["oyun"]["gecis"]:
		r.append(Rect2(float(g["x"]) - float(g["en"]) * 0.5 - 1.5, float(d["zm0"]) - 4.0, float(g["en"]) + 3.0, float(d["MW"]) + 8.0))
	var gw := float(kesim["kapi"]["gw"])
	if gw > 0.0:
		r.append(Rect2(-gw * 0.5 - 2.0, zi0 - 3.0, gw + 4.0, float(d["zm1"]) - zi0 + 6.0))
	var pt := float(kesim["oyun"]["poterna"])
	r.append(Rect2(pt - 2.0, zo0 - 3.0, 10.0, float(d["OT"]) + 6.0))
	for dm in dayamalar():
		var ay: Vector3 = dm["ayak"]["yerel"]
		r.append(Rect2(float(dm["x"]) - 1.5, zo1, 3.0, ay.z - zo1 + 2.0))
	var h: Dictionary = kesim["hendek"]
	for rx in [float(h["ramp_a_x"]) - float(h["ramp_len"]) * 0.5, float(h["ramp_b_x"]) + float(h["ramp_len"]) * 0.5]:
		r.append(Rect2(rx - float(h["ramp_len"]) * 0.5 - 2.0, float(d["zm0"]), float(h["ramp_len"]) + 4.0, float(d["MW"])))
	for b in kesim["oyun"]["batarya"]:
		r.append(Rect2(float(b[0]) - 5.0, float(b[1]) - 5.0, 10.0, 10.0))
	# hendek uç bölmeleri (surlar.gd _build_moat: dilim uçlarında 3 m tam yükseklik dolgu)
	r.append(Rect2(-L * 0.5, float(d["zm0"]), 4.0, float(d["MW"])))
	r.append(Rect2(L * 0.5 - 4.0, float(d["zm0"]), 4.0, float(d["MW"])))
	return r


## Güvenli doğma noktaları: alanın içinde, engellerin dışında, tohumla belirli; "katida/havada" ışınla doğrulanır
## (denetim). Dönen: [n…] (y = alanın zemini).
func dogma(alan: String, sayi := 12, tohum := 1453) -> Array:
	var a: Dictionary = alanlar()[alan]
	var rr: Rect2 = a["r"]
	var en := engeller()
	var rng := RandomNumberGenerator.new()
	rng.seed = tohum + alan.hash()
	var out: Array = []
	var dene := 0
	while out.size() < sayi and dene < sayi * 60:
		dene += 1
		var p := Vector2(rng.randf_range(rr.position.x, rr.end.x), rng.randf_range(rr.position.y, rr.end.y))
		var bos := true
		for e: Rect2 in en:
			if e.grow(0.4).has_point(p):
				bos = false
				break
		for q in out:
			var v: Vector3 = q["yerel"]
			if Vector2(v.x, v.z).distance_to(p) < 1.6:
				bos = false
		if bos:
			out.append(n(Vector3(p.x, float(a["y"]), p.y)))
	return out


## Denetim için bütün noktalar: [{"tur", "ad", "n", "bek"}] bek: "zemin" (altında zemin, üstü boş), "duvar" (dış yüze dayalı)
func noktalar() -> Array:
	var out: Array = []
	for k in ["ic", "dis"]:
		var yy: Dictionary = yol(k)
		var i := 0
		for p in yy["nokta"]:
			var kes := false
			var v: Vector3 = p["yerel"]
			for kk in yy["kesik"]:
				if v.x > float(kk[0]) - 0.5 and v.x < float(kk[1]) + 0.5:
					kes = true
			if not kes:
				out.append({"tur": "yol_" + k, "ad": "%d" % i, "n": p, "bek": "zemin"})
			i += 1
	for c in cikislar():
		for u in ["alt", "ust", "yol"]:
			out.append({"tur": "cikis", "ad": "%s_%s" % [c["ad"], u], "n": c[u], "bek": "zemin"})
	for dm in dayamalar():
		out.append({"tur": "dayama_ayak", "ad": "%.1f" % float(dm["x"]), "n": dm["ayak"], "bek": "zemin"})
		out.append({"tur": "dayama_tepe", "ad": "%.1f" % float(dm["x"]), "n": dm["tepe"], "bek": "duvar"})
		out.append({"tur": "dayama_yol", "ad": "%.1f" % float(dm["x"]), "n": dm["yol"], "bek": "zemin"})
	for k in ["ic", "dis"]:
		for mz in mazgallar(k):
			out.append({"tur": "mazgal_" + k, "ad": "%.1f" % float(mz["p"]["yerel"].x), "n": mz["ayak"], "bek": "zemin"})
	for b in bataryalar():
		out.append({"tur": "batarya", "ad": "", "n": b["p"], "bek": "zemin"})
	var g := gedik()
	if not g.is_empty():
		for u in ["peri", "tepe", "teras", "hendek"]:
			out.append({"tur": "gedik_moloz", "ad": u, "n": g["moloz"][u], "bek": "zemin"})
	var h := hendek()
	if not h.is_empty():
		for r in h["rampa"]:
			out.append({"tur": "hendek_rampa", "ad": "ust", "n": r["ust"], "bek": "zemin"})
			out.append({"tur": "hendek_rampa", "ad": "alt", "n": r["alt"], "bek": "zemin"})
		for gc in h["gecis"]:
			out.append({"tur": "gecis_" + String(gc["tur"]), "ad": "yakin", "n": gc["yakin"], "bek": "zemin"})
			out.append({"tur": "gecis_" + String(gc["tur"]), "ad": "uzak", "n": gc["uzak"], "bek": "zemin"})
	var kp := kapi()
	if not kp.is_empty() and not bool(kp["kapali"]):
		for u in ["ic_esik", "peri", "dis_esik"]:
			out.append({"tur": "kapi", "ad": u, "n": kp[u], "bek": "zemin"})
	var pt := poterna()
	for u in ["ic", "esik", "sahanlik", "dis"]:
		out.append({"tur": "poterna", "ad": u, "n": pt[u], "bek": "zemin"})
	for al in ["sehir", "peribolos", "teras", "ova"]:
		for q in dogma(al, 10):
			out.append({"tur": "dogma_" + al, "ad": "", "n": q, "bek": "zemin"})
	return out


# ------------------------------------------------------------------ KESİM SAHNESİ KURUCUSU (karar 12: ölçülür)

## Kesim sahnesi: oyun dilimi (yakın, çarpışmalı, lod 0) + iki yanında birer yan dilim (lod 0, çarpışmalı; Mesoteikhion'da
## 2. gedik dekor/kapalı, karar 4-A) + uzak katman (her yanda iki 110 m dilim lod 2, çarpışmasız) + zemin levhaları.
## secenekler: "uzak" (bool, true), "yan" (bool, true), "parca" (bool, true: poterna/köprü/dolgu/gedik/merdiven),
##   "asama" (0..3 gedik onarımı), "kalas" (bool), "dolgu" (0..1), "kapi_kopru" ("saglam"|"yikik"), "merdiven" (dayama
##   indisleri dizisi), "poterna_acik" (bool), "dunya" (true: kök a.xf'e konur; false: kök orijinde, yerel çalışma)
static func kur(p_id: String, sec := {}) -> Dictionary:
	var t0 := Time.get_ticks_usec()
	var a: RefCounted = arayuz(p_id)
	var kok := Node3D.new()
	kok.name = "SurOyun_" + p_id
	if bool(sec.get("dunya", true)):
		kok.transform = a.xf
	var hedef: Node = sec.get("ebeveyn", null)
	if hedef != null:
		hedef.add_child(kok)
	var olc := {}
	var t1 := Time.get_ticks_usec()
	a.asama = int(sec.get("asama", 1))
	# oyun dilimi
	var o: Dictionary = SZ.secenek(p_id, a.gx)
	o["gedik"] = (a.kesim["gedik"]["x"] as Array).duplicate()
	var kanca := bool(sec.get("kanca", true))      # false: şehirdeki dilimin aynısı (ÖNCE karesi; poterna/geçit/sade gedik yok)
	var pot := float(a.kesim["oyun"]["poterna"])
	if kanca:
		o["poterna"] = pot
	var pg: Array = []
	for g in a.kesim["oyun"]["gecis"]:
		if String(g["tur"]) != "kapi_kopru":
			pg.append([float(g["x"]), float(g["en"]) + 0.6])
	if kanca:
		o["para_gecit"] = pg
	if kanca and not is_nan(a.gx):
		o["gedik_sade"] = [a.gx]
	if kanca and float(a.kesim["kapi"]["gw"]) > 0.0 and not bool(a.kesim["kapi"]["kapali"]) and bool(sec.get("parca", true)):
		o["kanat_disarida"] = true
	var oyun := Node3D.new()
	oyun.name = "OyunDilimi"
	kok.add_child(oyun)
	if not kok.is_inside_tree():
		push_warning("SurOyun.kur: ebeveyn verilmedi; dış kademe (dy) sözleşmeden okunamaz, 0 kabul edilir")
	a._dy_kaydet(oyun)
	IstSurlar._run(oyun, a.L, SZ.K, 0, SZ.tohum(p_id), o)
	olc["oyun_ms"] = (Time.get_ticks_usec() - t1) / 1000.0
	# yan dilimler
	var t2 := Time.get_ticks_usec()
	if bool(sec.get("yan", true)):
		for yn: Dictionary in a.yanlar():
			var yd := Node3D.new()
			yd.name = String(yn["ad"])
			yd.position.x = float(yn["x"])
			kok.add_child(yd)
			a._dy_kaydet(yd)
			IstSurlar._run(yd, float(yn["L"]), SZ.K, 0, int(yn["tohum"]), yn["secenek"])
	olc["yan_ms"] = (Time.get_ticks_usec() - t2) / 1000.0
	# uzak katman
	var t3 := Time.get_ticks_usec()
	if bool(sec.get("uzak", true)):
		for s: float in [-1.0, 1.0]:
			for k in 2:
				var ud := Node3D.new()
				ud.name = "Uzak_%d_%d" % [int(s), k]
				ud.position.x = s * (a.yan_uc(s) + SZ.YAN_L * (0.5 + k))
				kok.add_child(ud)
				a._dy_kaydet(ud)
				IstSurlar._run(ud, SZ.YAN_L, SZ.K, 2, SZ.tohum(p_id) + 31 + k + (0 if s < 0.0 else 5), {"ad": "SurDilimi"})
	olc["uzak_ms"] = (Time.get_ticks_usec() - t3) / 1000.0
	# zemin
	var t4 := Time.get_ticks_usec()
	PARCA.zemin(kok, a, bool(sec.get("uzak", true)))
	olc["zemin_ms"] = (Time.get_ticks_usec() - t4) / 1000.0
	# oynanış parçaları
	var t5 := Time.get_ticks_usec()
	var parca := {}
	if bool(sec.get("parca", true)):
		parca = PARCA.kur_hepsi(kok, a, sec)
	olc["parca_ms"] = (Time.get_ticks_usec() - t5) / 1000.0
	olc["toplam_ms"] = (Time.get_ticks_usec() - t0) / 1000.0
	return {"kok": kok, "arayuz": a, "parca": parca, "ms": olc}


## Yan dilimler: {"ad", "x" (orta, kesim-yerel), "L", "tohum", "secenek"}. Mesoteikhion'un kuzeyinde (−x) şehirdeki
## Romanos kapı koşusu (aynı boy/tohum/seçenek: kapı, köprü ayakları ve kuleler şehirle aynı); öbür yanlar 110 m sur dilimi.
func yanlar() -> Array:
	var out: Array = []
	for yn: Dictionary in kesim["yan"]:
		var sec_ad := String(yn["secenek"])
		var o: Dictionary = {"ad": "SurDilimi", "gedik": yn["gedik"]} if sec_ad == "SurDilimi" else IstSurlar.OPTS[sec_ad]
		out.append({"ad": yn["ad"], "x": float(yn["x"]), "L": float(yn["L"]), "tohum": int(yn["tohum"]), "secenek": o,
			"merdiven": yn["merdiven"], "kule": yn["kule"]})
	return out


## Dilim kurulmadan önce: kurucu dış kademeyi (dy) OTURTMA kaydından okur (IstSurlar.dis_dy → OTURTMA.dy_bul). Kesim
## sahnesinde bütün dilimler sözleşmedeki tek dy'yi kullanır (teras/hendek dilimden dilime aynı düzde; yerel kipte kök
## orijinde olsa da doğru).
func _dy_kaydet(host: Node3D) -> void:
	if not host.is_inside_tree():
		return
	var g := host.global_position
	IstSurlar.OTURTMA.dy_kayit.append([Vector2(g.x, g.z), dy])


## Yan dilimin dış ucu (|x|)
func yan_uc(s: float) -> float:
	for yn: Dictionary in yanlar():
		if signf(float(yn["x"])) == signf(s):
			return absf(float(yn["x"])) + float(yn["L"]) * 0.5
	return L * 0.5


## Gediklerin kesim-yerel konumu (denetim: 2. ve 3. gedik hattan ne kadar sapıyor)
func gedikler_yerel() -> Array:
	var out: Array = []
	var inv := xf.affine_inverse()
	for w: Vector2 in gedik_w:
		out.append(inv * Vector3(w.x, xf.origin.y, w.y))
	return out
