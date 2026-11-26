extends RefCounted
## G23 — ESKİ DÜNYANIN KARA SURLARI YENİ KALEMLE (class_name YOK):
##   const EskiSur := preload("res://scripts/world/ist/eski_sur.gd")
##
## Eski dünya (World1453.build → SiegeField `world`, `fill_center`) kara surlarını kutu yerine İstanbul v2'nin sur kalemiyle
## (IstSurlar._run_ic: tuğla hatıllı taş, gerçek kule biçimleri, mazgallar, sur yolu, hendek kıyıları) kurar.
## Eski dünyanın sur hattı DÜZ: x sur boyunca (−578 Blakherna köşe kulesi … 700 Marmara), +z ova. Kalemin yereli dönüşsüz
## oturur: kesim z 0 → dünya z ZC (iç surun şehir yüzü −3,8 = SurHub hizası, K1), y 0 → dünya y 0 (dy 0).
## Kesit: iç sur, peribolos, dış sur sözleşme ölçüsünde; teras ve hendek seçmeli enle (hendeğin uzak yakası z 36: ova
## ve ölü bölge oradan başlar). Kapılar (LAND_GATES) kalemin kapı dilimleri, AÇIK (K2: ≥ 7 m, hendekte dolgu geçit).
## Ayrıntı düzeyi: bölümün kendi oynanış alanına (keep_own) 300 m'ye kadar lod 0, ötesi lod 1 (pişmiş, kutu değil; K4).
## Çarpışma: kalemin gövdeleri (her dilimde, lod'dan bağımsız); görünen ağ `no_walk` (WorldWalk ikinci kez katılaştırmaz).

const SurDoku := preload("res://scripts/world/ist/sur_doku.gd")
const OTURTMA := preload("res://scripts/world/ist/sur_oturtma.gd")
const ZEMIN := preload("res://scripts/world/ist/sur_zemin.gd")

const K := 1.0
## Kesim z 0'ın dünya z'si (iç surun şehir yüzü zi0 = −2,5 → −3,8)
const ZC := -1.3
const X0 := -578.0            # Blakherna köşe kulesinin ortası (Blachernae yerel x 62)
const X1 := 700.0             # Marmara
const PTW := 7.0              # teras (sözleşme 10; dış kulenin önünde 1,2 m geçit kalır)
const MW := 9.3               # hendek eni: uzak yaka + kıyı örtüsü z 36,0'da biter
## Sur yolları (dünya)
const DIS_YOL_Y := 8.5
const DIS_YOL_Z := 17.5
const IC_YOL_Y := 12.0
const IC_YOL_Z := -1.3
## Ayrıntı eşiği (oynanış alanından)
const LOD0_M := 300.0
## Lykos açıklığı (K5: WallRear.STOCKADE x 1…19)
const LYKOS := Vector2(1.0, 19.0)

## Son kurulumun dünya bilgisi (savunan, sancak, WallRear sur işleri sorgular)
static var _ic_kule: Array = []        # [x, en]
static var _dis_kule: Array = []       # x
static var _kesik_dis: Array = []      # dış sur yolunda yürünmeyen aralıklar [a, b]
static var _kesik_ic: Array = []
static var olcum := {}


## Bu SiegeField'de yeni kalem mi (K6: `--eskisur` çıplak ya da bölüm listede → kutu; LandWalls'ın alanı → kutu)
static func istek(f: SiegeField) -> bool:
	if not f.world or not f.fill_center or f.region_name == "landwalls" or f.region_name == "":
		return false
	if "--eski-kalem" in OS.get_cmdline_user_args():
		return false
	return not SurSet.eski_istendi(IstBaglama.sahne_bolumu())


## Hat dilimleri (dünya x): kapı dilimleri kapının ortasında; aralar ~110 m sur dilimi
static func dilimler(lykos: bool) -> Array:
	var kapilar := {-460.0: ["kharisios", 60.0], -230.0: ["pempton", 60.0], 37.0: ["romanos", 76.0], 170.0: ["rhegion", 60.0],
		340.0: ["pege", 60.0], 520.0: ["ksylokerkos", 60.0], 650.0: ["altin_kapi", 100.0]}
	var out: Array = []
	var x := X0
	var keys: Array = kapilar.keys()
	keys.sort()
	var fi := 0
	for g: float in keys:
		var id: String = kapilar[g][0]
		var L: float = kapilar[g][1]
		var ga := g - L * 0.5
		if ga > x + 1.0:
			var n := maxi(1, roundi((ga - x) / 110.0))
			var st := (ga - x) / n
			for i in n:
				out.append({"x0": x + st * i, "x1": x + st * (i + 1), "id": "", "tohum": 1453 + 7 * fi})
				fi += 1
		out.append({"x0": ga, "x1": g + L * 0.5, "id": id, "tohum": 1000 + id.hash() % 997})
		x = g + L * 0.5
	if x < X1 - 1.0:
		out.append({"x0": x, "x1": X1, "id": "", "tohum": 1453 + 7 * fi})
	for i in out.size():
		var dl: Dictionary = out[i]
		var o: Dictionary
		if String(dl["id"]) == "":
			o = {"ad": "SurDilimi"}
		else:
			o = (IstSurlar.OPTS[String(dl["id"])] as Dictionary).duplicate()
			# K2: yedi kapı açık ve yürünür; açıklık ≥ 7 m; kanatlar kurulmaz (geçit açık); hendekte dolgu geçit
			o["kapali"] = false
			o["mermer"] = false
			o["gw"] = maxf(float(o.get("gw", 0.0)), 7.0)
			o["gh"] = maxf(float(o.get("gh", 3.6)), 4.4)
			o["kanat_disarida"] = true
			o["kapi_dolgu"] = true
			o["hendek"] = true
		o["ptw"] = PTW
		o["mw"] = MW
		o["uc_dolgu"] = [i == 0, i == out.size() - 1]
		var xc := (float(dl["x0"]) + float(dl["x1"])) * 0.5
		if lykos and float(dl["x0"]) < LYKOS.x and float(dl["x1"]) > LYKOS.y:
			var gx := (LYKOS.x + LYKOS.y) * 0.5 - xc
			o["gedik"] = [gx]
			o["gedik_sade"] = [gx]
			o["gedik_w"] = LYKOS.y - LYKOS.x
		dl["o"] = o
		dl["L"] = float(dl["x1"]) - float(dl["x0"])
		dl["xc"] = xc
	return out


static func _rect_mesafe(a: Rect2, b: Rect2) -> float:
	var dx := maxf(maxf(a.position.x - b.end.x, b.position.x - a.end.x), 0.0)
	var dz := maxf(maxf(a.position.y - b.end.y, b.position.y - a.end.y), 0.0)
	return sqrt(dx * dx + dz * dz)


static func lod_sec(f: SiegeField, x0: float, x1: float) -> int:
	var r := Rect2(x0, -6.0, x1 - x0, 42.0)
	var dmin := INF
	for k: Rect2 in f.keep_own:
		dmin = minf(dmin, _rect_mesafe(k, r))
	return 0 if dmin <= LOD0_M else 1


static func kur(f: SiegeField) -> Node3D:
	var t0 := Time.get_ticks_usec()
	_ic_kule.clear()
	_dis_kule.clear()
	_kesik_dis.clear()
	_kesik_ic.clear()
	var kok := Node3D.new()
	kok.name = "EskiSur"
	kok.set_meta("no_walk", true)        # görünen ağ katılaştırılmaz: çarpışma kalemin gövdeleri
	f.add_child(kok)
	# Ortak statikler (v2 sızıntısı, D6): kurulum boyunca boş/sabit, sonra geri
	var s_kusak := OTURTMA.kusak.duplicate()
	var s_kizg: Dictionary = OTURTMA._kizg.duplicate()
	var s_bant := OTURTMA.bantlar.duplicate()
	var s_bizg: Dictionary = OTURTMA._bizg.duplicate()
	var s_dy := OTURTMA.dy_kayit.duplicate()
	var s_gedik := IstSurlar.gedik_dunya.duplicate()
	var s_pen := IstSurlar.pencere
	var s_carp := IstSurlar.carp_only
	var s_bake := IstSurlar.bake
	var s_v2 := IstSehir.v2
	var s_xfv := ZEMIN.xf_var
	OTURTMA.kusak.clear()
	OTURTMA._kizg.clear()
	OTURTMA.bantlar.clear()
	OTURTMA._bizg.clear()
	OTURTMA.dy_kayit.clear()
	IstSurlar.pencere = Vector2(-1e9, 1e9)
	IstSurlar.carp_only = false
	IstSurlar.bake = true
	ZEMIN.xf_var = false
	var lykos := WallRear.stockade_on(f)
	var dl := dilimler(lykos)
	var say := [0, 0]
	for i in dl.size():
		var d: Dictionary = dl[i]
		LoadingScreen.nabiz("eskisur")
		var host := Node3D.new()
		host.name = "Dilim_%02d" % i
		host.position = Vector3(float(d["xc"]), 0.0, ZC)
		kok.add_child(host)
		var g := host.global_position
		OTURTMA.dy_kayit.append([Vector2(g.x, g.z), 0.0])
		var lod := lod_sec(f, float(d["x0"]), float(d["x1"]))
		say[lod] += 1
		IstSehir.v2 = true
		var r := IstSurlar._run_ic(host, float(d["L"]), K, lod, int(d["tohum"]), d["o"])
		IstSehir.v2 = s_v2
		if r == null:
			continue
		if lod >= 1:
			Props.bake_static(r, [r])
		SurDoku.uygula(r, 0)
		IstSurlar._levha_zemin_v2(r)
		for c in r.find_children("*", "GeometryInstance3D", true, false):
			(c as Node).set_meta("no_walk", true)
		_kayit(d, lod)
	_uclar(kok, f)
	OTURTMA.kusak = s_kusak
	OTURTMA._kizg = s_kizg
	OTURTMA.bantlar = s_bant
	OTURTMA._bizg = s_bizg
	OTURTMA.dy_kayit = s_dy
	IstSurlar.gedik_dunya = s_gedik
	IstSurlar.pencere = s_pen
	IstSurlar.carp_only = s_carp
	IstSurlar.bake = s_bake
	ZEMIN.xf_var = s_xfv
	if lykos:
		_kesik_dis.append([LYKOS.x - 1.0, LYKOS.y + 1.0])
	olcum = {"dilim": dl.size(), "lod0": say[0], "lod1": say[1], "ms": (Time.get_ticks_usec() - t0) / 1000.0}
	print("ESKISUR region=%s dilim=%d lod0=%d lod1=%d lykos=%s ms=%.0f" % [f.region_name, dl.size(), say[0], say[1], str(lykos), olcum["ms"]])
	return kok


## Hattın iki ucu (K: uçlar açıkta kalmaz). Kuzey: dış sur, Blakherna köşe kulesinin önünden (z 6,8) dış surun ova
## yüzüne kadar bir dönüş duvarıyla kapanır. Güney (Marmara): iç surun ucunda köşe kulesi, peribolos ve dış sur dönüş
## duvarıyla kapanır. Aynı kalem (_s gövde + korkuluk, kule kalemi), aynı gölgelendirici; çarpışma gövdeleri.
static func _uclar(kok: Node3D, f: SiegeField) -> void:
	var d := IstSurlar.dims(K)
	var OT: float = d["OT"]
	var OH: float = d["OH"]
	var zo1: float = d["zo1"]
	var zi1: float = d["zi1"]
	var stone := IstSurlar.C_STONE.darkened(0.04)
	for uc in 2:
		var x := X0 if uc == 0 else X1
		var lod := lod_sec(f, x - 40.0, x + 40.0)
		var h := Node3D.new()
		h.name = "Uc_%s" % ["Kuzey", "Guney"][uc]
		h.position = Vector3(x, 0.0, ZC)
		kok.add_child(h)
		var mer: Array = []
		var xa := 0.0 if uc == 0 else -OT
		var xb := OT if uc == 0 else 0.0
		# kuzeyde Blakherna köşe kulesinin ön yüzü (dünya z 6,8) → yerel; güneyde iç surun peribolos yüzü
		var za := (6.6 - ZC) if uc == 0 else zi1
		IstSurlar._s(h, Vector3(xa, -1.0, za), Vector3(xb, OH, zo1), stone, "ashlar", lod, true)
		IstSurlar._parapet_z(h, za + 0.5, zo1, xa + IstSurlar.PARAPET_T * 0.5, OH, stone.darkened(0.03), 0 if lod == 0 else 1, mer)
		IstSurlar._parapet_z(h, za + 0.5, zo1, xb - IstSurlar.PARAPET_T * 0.5, OH, stone.darkened(0.03), 0 if lod == 0 else 1, mer)
		if uc == 1:
			IstSurlar._inner_tower(h, d, {"x": -4.5, "w": 9.0, "p": float(d["TP"])}, lod, mer, {"tohum_k": 7}, 1)
		if mer.size() > 0:
			IstSurlar.KULE.disler_ag(h, mer, stone.darkened(0.06), 1453 + uc)
		Props.bake_static(h, [h])
		SurDoku.uygula(h, 0)
		for c in h.find_children("*", "GeometryInstance3D", true, false):
			(c as Node).set_meta("no_walk", true)


## Dilimin kule ve kesik aralıklarını dünya x'inde kaydeder (sur yolu sorguları)
static func _kayit(dl: Dictionary, _lod: int) -> void:
	var o: Dictionary = dl["o"]
	var L: float = dl["L"]
	var xc: float = dl["xc"]
	var lay := IstSurlar._layout(L, K, int(dl["tohum"]), o)
	var d: Dictionary = lay["d"]
	for tw in lay["itx"]:
		_ic_kule.append([xc + float(tw["x"]), float(tw["w"])])
	var gedikler: Array = o.get("gedik", [])
	var gwg := float(o.get("gedik_w", IstSurlar.GEDIK_W))
	var otw := float(d["OTW"])
	var lt := ceili(float(d["OTH"] - d["OH"]) / IstSurlar.STEP_RISE) * 0.42
	for ox in lay["otx"]:
		var yakin := false
		for gx in gedikler:
			if absf(float(gx) - float(ox)) < gwg * 0.5 + otw * 0.5 + 1.0:
				yakin = true
		if yakin:
			continue
		_dis_kule.append(xc + float(ox))
		_kesik_dis.append([xc + float(ox) - otw * 0.5 - lt, xc + float(ox) + otw * 0.5 + lt])
	var gw: float = lay["gw"]
	if gw > 0.0:
		_kesik_dis.append([xc - gw * 0.5 - 1.0, xc + gw * 0.5 + 1.0])
	if lay.has("out_x1"):
		_kesik_dis.append([xc + float(lay["out_x1"]) - 1.0, xc + float(lay["out_x1"]) + 1.5])
	for tw in lay["itx"]:
		_kesik_ic.append([xc + float(tw["x"]) - float(tw["w"]) * 0.5, xc + float(tw["x"]) + float(tw["w"]) * 0.5])
	for gx in gedikler:
		_kesik_dis.append([xc + float(gx) - gwg * 0.5 - 1.0, xc + float(gx) + gwg * 0.5 + 1.0])


static func _bos(liste: Array, x: float, pay: float) -> bool:
	if x < X0 + 3.0 + pay or x > X1 - 3.0 - pay:
		return false
	for k: Array in liste:
		if x > float(k[0]) - pay and x < float(k[1]) + pay:
			return false
	return true


## Dış sur yolunda x boş mu (dış kule ve tepe basamakları, kapı, merdiven sahanlığı, gedik dışı)
static func dis_yol_bos(x: float, pay := 0.5) -> bool:
	return _bos(_kesik_dis, x, pay)


## İç sur yolunda x boş mu (iç kuleler dışı)
static func ic_yol_bos(x: float, pay := 0.5) -> bool:
	return _bos(_kesik_ic, x, pay)


## sx yanındaki (x ≥ 0: +1, x < 0: −1) k. iç kulenin tepesi (merkezden uzaklaşan sırayla); yoksa null
static func sancak_yeri(sx: float, k: int) -> Variant:
	var xs: Array = []
	for t: Array in _ic_kule:
		var x := float(t[0])
		if (sx > 0.0 and x >= 0.0) or (sx < 0.0 and x < 0.0):
			xs.append(x)
	xs.sort_custom(func(a, b): return absf(a) < absf(b))
	if k >= xs.size():
		return null
	var d := IstSurlar.dims(K)
	# kule tepesinin ortası (kule yerelde −T/2 … T/2 + TP; tepe döşemesi HT)
	var zc := ZC + (float(d["T"]) * 0.5 + float(d["TP"]) - float(d["T"]) * 0.5) * 0.5
	return Vector3(float(xs[k]), float(d["HT"]), zc)


static func dis_kuleler() -> Array:
	return _dis_kule.duplicate()
