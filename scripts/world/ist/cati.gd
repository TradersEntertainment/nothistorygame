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


static func rotalar(_houses: Array) -> Array:
	return []


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
		["sokak4_hip_kuzey", _k3(hip(33, -70), 1.7), _k3(hip(33, -40), 3.0)],
		["sokak5_hip_orta", _k3(hip(32, -40), 1.7), _k3(hip(40, -50), 4.0)],
		["sokak6_hip_guney", _k3(hip(33, -5), 1.7), _k3(hip(40, -20), 4.0)],
		["cati1_e_sirasi", _k3(Vector2(-58, 8), 7.7), _k3(Vector2(-75, 35), 5.0)],
		["cati2_m1", _k3(Vector2(-64, 30), 7.7), _k3(Vector2(-92, 35), 6.0)],
		["cati3_m2_bakis", _k3(Vector2(-90, 35), 11.0), _k3(hip(-5, -40), 2.0)],
		["cati4_d_kuzey", _k3(hip(41, -84), 7.7), _k3(hip(41, -40), 6.0)],
		["cati5_d_bakis", _k3(hip(41, -48), 10.5), _k3(hip(-10, -30), 2.0)],
		["cati6_d_ayasofya", _k3(hip(41, -20), 7.7), Vector3(0, 40, 0)],
		["hava1_mahalle", Vector3(-60, 170, 140), Vector3(-80, 10, 40)],
		["hava2_hipodrom", Vector3(-200, 90, 60), Vector3(-110, 10, 60)],
	]
