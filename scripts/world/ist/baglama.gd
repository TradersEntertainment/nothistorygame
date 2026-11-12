class_name IstBaglama
extends Node
## İstanbul v2'yi OYUNA bağlar (docs/_ajan/gorev/ist2_tur3.md, BAĞLAMA-3): Nihat'ın uçuş bölümleri (7, 11) yeni şehirde
## oynanır. Bölümün kendi sahnesi (ordugâh: CampDay; şehrin sur tarafı: ByzCity) olduğu gibi kurulur; çevresindeki dünya
## eski World1453 yerine İstanbul v2'dir (IstDunya + IstSehir + parçalar).
##
## Nasıl oturur (BAĞLAMA-4, dönüşümlü): v2 kendi çerçevesinde kurulur (IstGeo kaydırmasız); v2'nin kökü (SiegeField kabuğu)
## bölümün çerçevesinde bir dönüşümle durur: kok.transform = xf⁻¹ (xf: bölüm yereli → v2). Eski World1453 de böyleydi
## (f.transform = region⁻¹). Dönüş: bölümün "dış" ekseni v2'de gerçekten dışa bakar (hub'ın iç suru v2 kara surunun
## içine, ordugâhın "sura doğru" ekseni v2 surlarına); yükseklik: bölümün y 0'ı v2 arazisine oturur (çanak yok).
## v2 parçaları izleyiciyi kendi çerçevelerinde okur (to_local; dunya, hayat, hayat_yakin, mahalle_doku, ordugah_yonetici).
##   · camp (Bölüm 11, 7a): CampDay'in otağı (yerel 0, −62) v2 ordugâhının otağının yerinde (sur dışı, Mesoteikhion
##     karşısı); v2'nin otağ çevresindeki ordugâh yapıları ve çadır kanatları kaldırılır (bölümün kendi ordugâhı var).
##   · byz_walls (Bölüm 7b): ByzCity'nin sur parçası Romanos Kapısı'nın iç yanındaki oyun alanında (IstSehir.oyun_alanlari);
##     v2'nin o alandaki yapıları kaldırılır.
## Güvenlik anahtarı: IstBaglama.acik (varsayılan AÇIK). Kapatmak: komut satırı `--eski-dunya` ya da ayar
## GameState.settings["eski_dunya"] = true. Kapalıyken bölümler eski World1453 ile aynen çalışır.

static var acik := true
## Bölümün bildirdiği istek (hazirla): hangi bölüm, gece mi
static var bolum := 0
static var gece := false
## v2 kurulduysa bölge adı ("" = eski dünya)
static var aktif_bolge := ""
static var son: IstBaglama
static var dunya: IstDunya
static var kok: SiegeField
## Ölçümler (rapor): v2 kurulum süresi (ms)
static var kurulum_ms := 0.0
static var _ordu_suzulen := 0

const BOLUMLER := [7, 11]
const BOLGELER := ["camp", "byz_walls"]
## Tolga'nın şehir bölümleri (ByzCity "walls" hub'ı; bölüm dosyasına dokunulmaz: sahnenin betiğinden tanınır). Varsayılan
## AÇIK olanlar yalnız kareleri temiz olanlar (docs/_kanit_ist2_baglama4/rapor.md); öbürleri `--ist2-deneme=<id>` ile denenir.
const TOLGA := ["6", "10h", "12b", "23", "24"]
const TOLGA_ACIK: Array = ["12b", "10h"]
## Bölüm yereli → v2 (dönüşümlü bağlama). kok.transform bunun tersi.
static var xf := Transform3D()
## Bölümün yerel çapası: CampDay.OTAG_POS (v2 otağının yerine), ByzCity sur parçasının ortası (oyun alanının ortasına)
const CAMP_OTAG := Vector2(0.0, -62.0)
const HUB_ORTA := Vector2(-4.0, -13.0)
## Bölümün kendi zemini ve süsü bu yarıçapa kadar (yerel çapa çevresi); ötesi v2 arazisine yumuşak geçer
const YAMA := {"camp": [Vector2(0.0, -20.0), 170.0, 330.0], "byz_walls": [Vector2(-4.0, -13.0), 62.0, 260.0]}
## v2 yapılarının kaldırıldığı alan (yerel; bölümün oynanış alanı + pay)
const TEMIZ := {"camp": Rect2(-150.0, -175.0, 300.0, 300.0), "byz_walls": Rect2(-56.0, -58.0, 104.0, 90.0)}
## Uçuş sisi (NihatPowers._thin_fog hedefi): v2'nin km ölçeği için incelir (eski 0,0007)
const UCUS_SIS := 0.00035
## v2 konma noktası kimliği → yan görevin kimliği
const PERCH_ESLE := {"ist_galata_kulesi": "galata", "ist_konstantin": "column", "ist_ayasofya": "aya"}

var oyuncu: Player
var _yakala_t := 0.0
## Bölüm sahnesinin (CampDay/ByzCity ve bölüm kökü) uzaklık sınırı olmayan çizimleri bu uzaklıkta biter: uçarken 2 km
## ötedeki ordugâhın binlerce süsü çizilmesin (eski dünyada da böyleydi; v2'nin kendi katmanları zaten uzaklıklı)
const SAHNE_UZAK := 650.0
const SAHNE_UZAK_KUCUK := 260.0


func _ready() -> void:
	# Bölüm sahnesi bu düğümden sonra kurulmaya devam eder (CampDay._ready'nin kalanı, bölümün _build'i): iki kare sonra
	for i in 2:
		await get_tree().process_frame
	if is_inside_tree():
		sahne_uzaklik(get_tree().current_scene if get_tree().current_scene else get_parent().get_parent())


## Uzaklık sınırı (görünürlük aralığı): v2 kökünün dışındaki her GeometryInstance3D (oyuncu ve el hariç), küçükler daha
## erken. Döndürür: sınır verilen sayısı
func sahne_uzaklik(kok_: Node) -> int:
	if kok_ == null:
		return 0
	var n := 0
	var yigin: Array = [kok_]
	while not yigin.is_empty():
		var d: Node = yigin.pop_back()
		if d == kok or d is Player or d is CanvasItem or d is CanvasLayer:
			continue
		for c in d.get_children():
			yigin.append(c)
		if d is GeometryInstance3D:
			var gi := d as GeometryInstance3D
			if gi.visibility_range_end > 0.0 or gi.visibility_range_begin > 0.0:
				continue
			var ab := gi.get_aabb()
			var buyuk := ab.size.length() * gi.global_basis.get_scale().length() / 1.732
			if gi is MultiMeshInstance3D:
				buyuk = maxf(buyuk, 40.0)
			gi.visibility_range_end = SAHNE_UZAK if buyuk > 6.0 else SAHNE_UZAK_KUCUK
			gi.visibility_range_end_margin = 30.0
			gi.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
			n += 1
	print("ISTBAGLAMA sahne_uzaklik=%d" % n)
	return n


# ------------------------------------------------------------------ anahtar

static func etkin() -> bool:
	if not acik:
		return false
	for a: String in OS.get_cmdline_user_args() + OS.get_cmdline_args():
		var k := a.trim_prefix("--")
		if k == "eski-dunya" or k == "eski_dunya" or (k.begins_with("eski-dunya=") and k != "eski-dunya=0"):
			return false
	var gs := Engine.get_main_loop() as SceneTree
	if gs and gs.root.has_node("GameState"):
		var st = gs.root.get_node("GameState").get("settings")
		if st is Dictionary and bool((st as Dictionary).get("eski_dunya", false)):
			return false
	# GameState yalnız bilinen ayar anahtarlarını yükler: kayıtlı ayar dosyasından da okunur (set_setting kalıcı olsun)
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK and bool(cfg.get_value("settings", "eski_dunya", false)):
		return false
	return true


## Bölüm, sahnesini kurmadan önce çağırır (Bölüm 7, 11)
static func hazirla(b: int, gece_ := false) -> void:
	bolum = b
	gece = gece_
	aktif_bolge = ""


## Bölümden çıkarken: sonraki bölümler eski dünyayı kurar; v2 ötelemesi sıfırlanır
static func birak() -> void:
	bolum = 0
	gece = false
	aktif_bolge = ""
	son = null
	dunya = null
	kok = null
	xf = Transform3D()
	MapView.v2 = false
	IstGeo.kaydir(Vector2.ZERO)
	_onbellek_sifirla()


static func istek(region_name: String) -> bool:
	if region_name == "byz_walls" and bolum == 0 and tolga_istek():
		return true
	return bolum in BOLUMLER and region_name in BOLGELER and etkin()


## Tolga'nın şehir bölümleri: hub (ByzCity "walls") v2'de. Bölüm, sahnedeki bölüm betiğinin adından (chapter<id>.gd)
## tanınır; TOLGA_ACIK'ta ise varsayılan, değilse yalnız `--ist2-deneme=<id>` ile (eski ad: deneme_12b).
static func deneme_12b() -> bool:
	return tolga_istek()


static func tolga_istek() -> bool:
	if not etkin():
		return false
	var id := sahne_bolumu()
	if id == "" or not (id in TOLGA):
		return false
	if id in TOLGA_ACIK:
		return true
	for a: String in OS.get_cmdline_user_args() + OS.get_cmdline_args():
		if a.trim_prefix("--") == "ist2-deneme=" + id:
			return true
	return false


## Sahnedeki bölümün kimliği (betik adı chapter<id>.gd): "12b", "10h", "23" …; yoksa ""
static func sahne_bolumu() -> String:
	var gs := Engine.get_main_loop() as SceneTree
	if gs == null or gs.root == null:
		return ""
	var yigin: Array = [gs.root]
	var derin := 0
	while not yigin.is_empty() and derin < 400:
		derin += 1
		var d: Node = yigin.pop_front()
		var sc = d.get_script()
		if sc is Script:
			var f := (sc as Script).resource_path.get_file()
			if f.begins_with("chapter") and f.ends_with(".gd"):
				return f.trim_prefix("chapter").trim_suffix(".gd")
		if d == gs.root or d == gs.current_scene or d.get_parent() == gs.root:
			for c in d.get_children():
				if not (c is CanvasLayer):
					yigin.append(c)
	return ""


static func aktif() -> bool:
	return aktif_bolge != ""


# ------------------------------------------------------------------ yerleşim

## Hub'ın iç suru (ByzCity yerel x 34) ve Romanos Kapısı (ByzCity._build_walls'ın kapısı: World1453.LAND_GATES'ten)
const HUB_SUR_X := 34.0
static func hub_kapi_z() -> float:
	for g: float in World1453.LAND_GATES:
		var lz: float = (World1453.region("byz_walls").affine_inverse() * Vector3(g, 0.0, -2.3)).z
		if lz > -13.0 - 35.0 + 4.0 and lz < -13.0 + 35.0 - 4.0:
			return lz
	return -31.5


## Bölümün yereli → kaydırmasız v2 (dönüşümlü bağlama). camp: CampDay'in "sura doğru" ekseni (yerel +z) otağdan en yakın
## kara suru noktasına; otağ v2 ordugâhının otağında. byz_walls: hub'ın iç suru (yerel x 34, dış yüz +x) v2 kara surunun
## iç suru üstünde (dış yanı dışa), hub'ın kapısı v2'nin Romanos Kapısı'nda. Yükseklik: bölümün y 0'ı çapanın v2 arazisi.
static func donusum(region_name: String) -> Transform3D:
	IstGeo.kaydir(Vector2.ZERO)
	_onbellek_sifirla()
	match region_name:
		"camp":
			var o := _otag_v2()
			var kp := _en_yakin(IstGeo.yol("kara_suru"), o)
			var dir: Vector2 = (kp[0] as Vector2 - o).normalized()
			var b := Basis(Vector3.UP, atan2(dir.x, dir.y))          # yerel +z → dir
			var t := Vector3(o.x, IstGeo.h(o.x, o.y), o.y) - b * Vector3(CAMP_OTAG.x, 0.0, CAMP_OTAG.y)
			return Transform3D(b, t)
		"byz_walls":
			var kp := _hub_kapi_v2()
			var p: Vector2 = kp[0]
			var dis: Vector2 = kp[1]
			var b := Basis(Vector3.UP, atan2(-dis.y, dis.x))         # yerel +x → dış
			var t := Vector3(p.x, IstGeo.h(p.x, p.y), p.y) - b * Vector3(HUB_SUR_X, 0.0, hub_kapi_z())
			return Transform3D(b, t)
	return Transform3D()


## Eski arayüz (öteleme): artık dönüşüm kullanılır; öteleme hep 0
static func ofset(_region_name: String) -> Vector2:
	return Vector2.ZERO


static func v2(p: Vector3) -> Vector3:
	return xf * p


static func yerel(p: Vector3) -> Vector3:
	return xf.affine_inverse() * p


## Yerel dikdörtgen → v2'deki sınır kutusu
static func v2_rect(r: Rect2) -> Rect2:
	return _rect_xf(xf, r)


## v2 noktası bölümün yerel dikdörtgeninde mi (döndürülmüş dikdörtgen)
static func yerel_icinde(r: Rect2, x: float, z: float) -> bool:
	var q := yerel(Vector3(x, 0.0, z))
	return r.has_point(Vector2(q.x, q.z))


static func _en_yakin(poly: PackedVector2Array, g: Vector2) -> Array:
	var best := INF
	var p := g
	var d := Vector2(0, 1)
	for i in poly.size() - 1:
		var q := Geometry2D.get_closest_point_to_segment(g, poly[i], poly[i + 1])
		if q.distance_to(g) < best:
			best = q.distance_to(g)
			p = q
			d = (poly[i + 1] - poly[i]).normalized()
	return [p, d]


## v2'nin Romanos Kapısı (kara suru hattında; IstSehir'in kapı kaydıyla aynı gerçek konum) ve dış yön
static func _hub_kapi_v2() -> Array:
	var kara := IstGeo.yol("kara_suru")
	var kp := _en_yakin(kara, IstGeo.w2(-4621.0, 823.0))
	var d: Vector2 = kp[1]
	var n := Vector2(-d.y, d.x)
	if IstGeo.sehir_ici(kp[0].x + n.x * 40.0, kp[0].y + n.y * 40.0):
		n = -n
	return [kp[0], n]


## v2 ordugâhının otağı (kaydırmasız dünya x,z). Parça yoksa DÜNYA-2 dökümündeki yer.
static func _otag_v2() -> Vector2:
	var scr = load("res://scripts/world/ist/ordugah.gd") if ResourceLoader.exists("res://scripts/world/ist/ordugah.gd") else null
	if scr != null:
		for it: Dictionary in scr.call("plan"):
			if String(it.get("id", "")) == "otag":
				var p: Vector2 = it["pos"]
				return p
	return IstGeo.w2(-4789.0, 1101.0)


## Romanos Kapısı'nın iç yanındaki oyun alanının ortası (IstSehir.oyun_alanlari ile aynı kural: kapıdan surun iç
## yüzüne dik 75 m). Kapı: Topkapı (gerçek −4837, 889) kara suru hattına oturtulur.
static func _hub_v2() -> Vector2:
	var kara := IstGeo.yol("kara_suru")
	var g := IstGeo.w2(-4837.0, 889.0)
	var best := INF
	var p := g
	var d := Vector2(0, 1)
	for i in kara.size() - 1:
		var q := Geometry2D.get_closest_point_to_segment(g, kara[i], kara[i + 1])
		if q.distance_to(g) < best:
			best = q.distance_to(g)
			p = q
			d = (kara[i + 1] - kara[i]).normalized()
	var n := Vector2(-d.y, d.x)
	if not IstGeo.sehir_ici(p.x + n.x * 40.0, p.y + n.y * 40.0):
		n = -n
	return p + n * 75.0


## Önbellekli parça planları (dünya konumu tutanlar) öteleme değişince yeniden kurulur
static func _onbellek_sifirla() -> void:
	var o = load("res://scripts/world/ist/ordugah.gd") if ResourceLoader.exists("res://scripts/world/ist/ordugah.gd") else null
	if o != null:
		o.set("_plan", [])
		o.set("_wall", PackedVector2Array())
		o.set("_arcs", PackedFloat32Array())
		o.set("_len", 0.0)
	var g = load("res://scripts/world/ist/gemiler.gd") if ResourceLoader.exists("res://scripts/world/ist/gemiler.gd") else null
	if g != null:
		g.set("_plan_onbellek", {})


# ------------------------------------------------------------------ kurulum (World1453.build buraya yönlendirir)

## World1453.build'in v2 karşılığı: bölümün yerel çerçevesinde v2 dünyasını kurar. Dönen SiegeField kurulmamış bir
## kabuktur (bölümün `world` değişkeni ve set_mode için); v2 onun çocuğu.
static func build(parent: Node3D, region_name: String, keep_local: Array, _night := true, blend_local: Array = []) -> SiegeField:
	var t0 := Time.get_ticks_msec()
	var hub_x := donusum("byz_walls")
	xf = donusum(region_name)
	IstGeo.kaydir(Vector2.ZERO)
	_onbellek_sifirla()
	aktif_bolge = region_name
	MapView.v2 = true
	# Eski dünyanın arazi işlevleri (CampDay.height ızgara dışında World1453/SiegeField.surf okur): World1453.build ile aynı
	# durağan ayarlar (kurulmadan); bölge yamasının işlevi bunlarla sürekli olur
	var oxf := World1453.region(region_name)
	var keep_w: Array = []
	for r: Rect2 in keep_local:
		keep_w.append(World1453.world_rect(oxf, r))
	SiegeField.flat_rects = keep_w.duplicate()
	SiegeField.flat_y = oxf.origin.y - 0.8 if oxf.origin.y < -0.1 else -0.03
	if World1453.BLEND.has(region_name):
		SiegeField.flat_y = oxf.origin.y - 0.05
	SiegeField.flat_blend = World1453.BLEND.get(region_name, 0.0)
	var br: Array = []
	for r: Rect2 in blend_local:
		br.append(World1453.world_rect(oxf, r))
	SiegeField.blend_rects = br
	# Arazi yaması (v2 çerçevesinde): içte bölümün zemini (yerel y → v2 y = yerel + xf.origin.y), dışta v2'ye yumuşak geçiş
	var ym: Array = YAMA[region_name]
	var ic := Rect2()
	for r: Rect2 in keep_local:
		ic = r if ic.size == Vector2.ZERO else ic.merge(r)
	var dy := xf.origin.y
	var mv := xf * Vector3(ym[0].x, 0.0, ym[0].y)
	if region_name == "camp":
		var grid := Rect2(CampDay.GRID_X0, CampDay.GRID_Z0, CampDay.GRID_N * CampDay.GRID_STEP, CampDay.GRID_N * CampDay.GRID_STEP)
		IstGeo.yama_ekle(Vector2(mv.x, mv.z), ym[1], ym[2], func(x: float, z: float) -> float:
			# ızgaranın içinde bölümün kendi arazisi görünür (v2 0,35 m altında); dışında bölümün süsünün oturduğu yüzey
			var q := IstBaglama.yerel(Vector3(x, 0.0, z))
			return dy + CampDay.height(q.x, q.z) - (0.35 if grid.grow(-0.5).has_point(Vector2(q.x, q.z)) else 0.03))
	else:
		var zr := ic.grow(4.0)
		IstGeo.yama_ekle(Vector2(mv.x, mv.z), ym[1], ym[2], func(x: float, z: float) -> float:
			var q := IstBaglama.yerel(Vector3(x, 0.0, z))
			return dy + (-0.35 if zr.has_point(Vector2(q.x, q.z)) else -0.05))
	var temiz: Rect2 = TEMIZ[region_name]
	IstGeo.dislanan = [v2_rect(temiz)]
	# bölümün zemini ve geçiş halkası denizin altında kalmasın (bölüm alanı karada)
	var yr: float = ym[2]
	IstGeo.deniz_yok = [Rect2(Vector2(mv.x, mv.z) - Vector2(yr, yr), Vector2(yr, yr) * 2.0).merge(v2_rect(temiz))]
	var n_su := 0
	var dr: Rect2 = IstGeo.deniz_yok[0]
	for i in int(dr.size.x / 20.0):
		for j in int(dr.size.y / 20.0):
			if IstGeo.su(dr.position.x + i * 20.0, dr.position.y + j * 20.0):
				n_su += 1
	print("ISTBAGLAMA deniz_yok=%s gercek_deniz_nokta=%d" % [dr, n_su])
	# Ordugâh planı (önbellekli; IstOrdugah.attach aynı diziyi okur) kurulmadan süzülür: bölümün alanındaki öğeler çıkar
	_ordu_suzulen = 0
	var oscr = load("res://scripts/world/ist/ordugah.gd") if ResourceLoader.exists("res://scripts/world/ist/ordugah.gd") else null
	if oscr != null:
		var pl: Array = oscr.call("plan")
		for i in range(pl.size() - 1, -1, -1):
			var it: Dictionary = pl[i]
			var pp: Vector2 = it["pos"]
			if yerel_icinde(temiz.grow(float(it.get("r", 0.0))), pp.x, pp.y):
				pl.remove_at(i)
				_ordu_suzulen += 1
	# Kabuk: v2'nin kökü bölümün çerçevesinde xf⁻¹ ile durur (World1453: region⁻¹)
	var f := SiegeField.new()
	f.name = "IstBaglamaKok"
	f.region_name = region_name
	f.keep = keep_local.duplicate()
	f.near_works = false
	f.world = false
	f.set("_smoke_root", Node3D.new())
	f.add_child(f.get("_smoke_root"))
	parent.add_child(f)
	kok = f
	f.set_meta("ucus_tarama_yok", true)       # NihatPowers.ensure_flight_solids v2'yi taramaz (v2 çarpışması kendinde)
	# v2: gök bölümün (gündüz CampDay/ByzCity, gece Night.environment); öbür her şey v2'nin
	IstDunya.gok_kur = false
	var merkez := Vector3(mv.x, dy + 2.0, mv.z)
	# Hub'ın v2'deki yeri ve yönü (bütün bölümlerde aynı; uçuşta görülen hub = Tolga'nın oynadığı hub): IstSehir kurulurken
	# oyun alanı ve hub dönüşümü önbelleği (oyun_alanlari / hub_xf) bu dönüşümle önceden dolar; sokak, ev ve yaşam
	# katmanları hub'ın alanını boş bırakır, hub şehri (ŞEHİR'in uzak hub'ı) surun içine dönük ve sura gömülü durur
	var hub_alan := _rect_xf(hub_x, Rect2(-46.0, -48.0, 84.0, 70.0).grow(2.0))
	var dinle := func(n: Node) -> void:
		if n is IstDunya:
			(n as Node).child_entered_tree.connect(func(m: Node) -> void:
				if m is IstSehir and (m as IstSehir).get("_oyun") is Array and ((m as IstSehir).get("_oyun") as Array).is_empty():
					m.set("_hub_xf", hub_x)
					m.set("_oyun", [hub_alan, IstSehir._meydan_rect()]))
	f.child_entered_tree.connect(dinle)
	dunya = IstDunya.build(f, gece, merkez) as IstDunya
	f.child_entered_tree.disconnect(dinle)
	IstDunya.gok_kur = true
	# Dönüşüm kurulumdan SONRA: v2 parçalarının bir kısmı kurulurken/pişirirken global çerçeveyi v2 sanıyor (gezide doğru):
	# Ayasofya'nın uzak katmanında bir parça dünya başlangıcına, sur dilimlerinin dış kademesi h.global_transform'a göre.
	# Kurulum birim dönüşümde biter, kök sonra bölümün çerçevesine oturur (ORTAK İSTEK 2)
	f.transform = xf.affine_inverse()
	_hub_dondur(hub_x)
	# harita (MiniMap, WorldMap): kabuğun dönüşümü (xf⁻¹) oyuncuyu v2 çerçevesine çevirir
	f.night_build = gece
	f.add_to_group(MapView.GROUP)
	_temizle(region_name, temiz)
	var b := IstBaglama.new()
	b.name = "IstBaglama"
	f.add_child(b)
	son = b
	kurulum_ms = Time.get_ticks_msec() - t0
	var yaw := rad_to_deg(xf.basis.get_euler().y)
	print("ISTBAGLAMA bolge=%s bolum=%s gece=%s xf=(%.1f, %.1f, %.1f) yaw=%.1f kurulum_ms=%.0f" % [region_name, bolum if bolum != 0 else sahne_bolumu(), gece, xf.origin.x, xf.origin.y, xf.origin.z, yaw, kurulum_ms])
	return f


static func _rect_xf(t: Transform3D, r: Rect2) -> Rect2:
	var out := Rect2()
	for i in 4:
		var q := t * Vector3(r.position.x + (r.size.x if i & 1 else 0.0), 0.0, r.position.y + (r.size.y if i & 2 else 0.0))
		out = Rect2(Vector2(q.x, q.z), Vector2.ZERO) if i == 0 else out.expand(Vector2(q.x, q.z))
	return out


## ŞEHİR'in uzak hub öğesi (hub_sehir) yaw 0 ile kurulur: tutucusu hub dönüşümüne çevrilir (ByzCity yereli → v2)
static func _hub_dondur(hub_x: Transform3D) -> void:
	var s := IstSehir.active
	if s == null:
		return
	for it: Dictionary in s.items:
		if String(it.get("id", "")) == "hub_sehir":
			var h = it.get("holder")
			if h is Node3D and is_instance_valid(h):
				(h as Node3D).transform = hub_x
				it["yaw"] = hub_x.basis.get_euler().y
				it["pos"] = hub_x.origin
				print("ISTBAGLAMA hub_sehir dondu yaw=%.1f" % rad_to_deg(float(it["yaw"])))


## Bölümün alanında kalsa da kaldırılmayan v2 öğeleri: Romanos Kapısı (hub'ın kapısı onun iç yanına oturur; dış sur, hendek
## köprüsü kesintisiz kalır)
const KORU := ["romanos"]

## Bölümün alanındaki v2 yapıları (IstSehir öğeleri, ordugâh öğeleri) kaldırılır: bölüm orada kendi sahnesini kurar
static func _temizle(region_name: String, alan: Rect2) -> void:
	var n_s := 0
	var s := IstSehir.active
	if s != null:
		for i in range(s.items.size() - 1, -1, -1):
			var it: Dictionary = s.items[i]
			var p: Vector3 = it["pos"]
			var r := float(it.get("r", 0.0))
			if String(it.get("id", "")) in KORU:
				continue
			if yerel_icinde(alan.grow(r * 0.5), p.x, p.z):
				it["want"] = 99            # kuyrukta bekleyen işi kurulmaz
				var h = it.get("holder")
				if h is Node and is_instance_valid(h):
					(h as Node).queue_free()
				s.items.remove_at(i)
				n_s += 1
	var n_o := _ordu_suzulen        # ordugâh planı kurulmadan süzüldü (build)
	print("ISTBAGLAMA temizle bolge=%s sehir_oge=%d ordugah_oge=%d" % [region_name, n_s, n_o])


# ------------------------------------------------------------------ uçuş

## Bölümün uçuşunu v2'ye bağlar (WorldFlight.attach + flight_data karşılığı): yer işaretleri, parçalar, konma
## noktaları, uçuş sisi, harita sınırı; su ve zemin yakalayıcı bu düğümün _physics_process'inde.
static func ucus_bagla(pw: NihatPowers, reach: float, alt: float) -> void:
	if son == null:
		return
	son.oyuncu = pw.player
	if dunya != null:
		dunya.izle = null          # su yakalayıcıyı biz yaparız (Nihat yeniden havalanır)
	var fd := flight_data()
	pw.add_landmarks(fd["landmarks"], reach, alt)
	pw.add_forms(fd["forms"])
	pw.add_perches(fd["perches"])
	pw.ucus_sis = UCUS_SIS
	pw.sinir = sinir()


## IstSehir.flight_data_v2: ilk dokuzu kayıtlı kimlikler; ardından yan görev eserleri (adı yazılı olanlar)
static func flight_data() -> Dictionary:
	var fd: Dictionary = IstSehir.flight_data_v2(kok)
	var lms: Array = []
	for i in (fd["landmarks"] as Array).size():
		var l: Array = fd["landmarks"][i]
		if i < NihatPowers.LANDMARK_IDS.size() or TranslationServer.translate("LM_" + String(l[0])) != "LM_" + String(l[0]):
			lms.append(l)
	fd["landmarks"] = lms
	# Konma noktaları: yan görevin kimlikleri (aya, galata, column: D_PERCH_* replikleri ve "perch" bayrakları) v2'deki
	# yapılara eşlenir; repliği olmayan v2 konma noktaları yan göreve girmez (ham anahtar balonu çıkmasın)
	var per: Array = []
	var var_ := {}
	for pe: Array in fd["perches"]:
		var id := String(PERCH_ESLE.get(String(pe[0]), pe[0]))
		if var_.has(id) or TranslationServer.translate("D_PERCH_" + id.to_upper()) == "D_PERCH_" + id.to_upper():
			continue
		var_[id] = true
		per.append([id, pe[1], pe[2]])
	fd["perches"] = per
	return fd


## Uçuşun yumuşak sınırı (dünya x,z): yarımada + Galata + bölümün alanı + yan görev noktaları, 300 m pay
static func sinir() -> Rect2:
	var r := Rect2()
	var bos := true
	for poly in [IstGeo.kiyi("yarimada"), IstGeo.kiyi("galata")]:
		for p: Vector2 in poly:
			var q := yerel(Vector3(p.x, 0.0, p.y))          # v2 → bölümün çerçevesi (sınır sahne koordinatında)
			r = Rect2(Vector2(q.x, q.z), Vector2.ZERO) if bos else r.expand(Vector2(q.x, q.z))
			bos = false
	r = r.merge(TEMIZ.get(aktif_bolge, Rect2()))
	var fd := flight_data()
	for k in ["landmarks", "forms"]:
		for l: Array in fd[k]:
			var p: Vector3 = l[1]
			r = r.expand(Vector2(p.x, p.z))
	return r.grow(300.0)


## Bölümün ortamı (CampDay/ByzCity gökyüzü, gece Night.environment) km ölçeğine uyar: yerdeki sis tavanı (Look.apply_env
## "fog_cap" ile uyar), hava perspektifi v2'deki gibi 0,1 (Look 0,3 veriyordu: 1-2 km ötedeki şehir gök rengine dönüyordu)
const SIS_YER := 0.0009
const SIS_YER_GECE := 0.002
var _sis_t := 0.0
var _envler: Array = []
var _bul_n := 0


func _process(dt: float) -> void:
	_sis_t -= dt
	if _sis_t > 0.0:
		return
	_sis_t = 0.5
	var cap := SIS_YER_GECE if gece else SIS_YER
	var sc := get_tree().current_scene
	if _envler.is_empty() or not is_instance_valid(_envler[0]):
		_envler.clear()
		if sc != null:
			for c in sc.get_children():
				if c is WorldEnvironment:
					_envler.append(c)
				for c2 in c.get_children():
					if c2 is WorldEnvironment:
						_envler.append(c2)
	var ucuyor := oyuncu != null and is_instance_valid(oyuncu) and oyuncu.powers != null and oyuncu.powers.flying
	for we in _envler:
		if not is_instance_valid(we):
			continue
		var e := (we as WorldEnvironment).environment
		if e == null:
			continue
		we.set_meta("fog_cap", cap)
		e.fog_aerial_perspective = minf(e.fog_aerial_perspective, 0.1)
		e.fog_sky_affect = 0.0
		if not ucuyor:
			e.fog_density = minf(e.fog_density, cap)
	if oyuncu != null and is_instance_valid(oyuncu) and oyuncu.powers != null:
		var f0 = oyuncu.powers.get("_fog0")
		if f0 is float and float(f0) > cap:
			oyuncu.powers.set("_fog0", cap)
	_bul_n += 1
	if _bul_n % 10 == 0:
		_envler.clear()        # gece ortamı sonradan kurulabilir (make_night): 5 sn'de bir yeniden bul


func _physics_process(_dt: float) -> void:
	if oyuncu == null or not is_instance_valid(oyuncu) or not oyuncu.is_inside_tree():
		return
	# v2 çerçevesinde (dönüşümlü bağlama); sahneye dönüşte kok.to_global
	var gp := oyuncu.global_position
	var p := kok.to_local(gp) if kok != null and is_instance_valid(kok) else gp
	# Bölümün kendi alanında bölümün zemini geçerli (yakalayıcı yok)
	var lp := (kok.get_parent() as Node3D).to_local(gp) if kok != null and is_instance_valid(kok) and kok.get_parent() is Node3D else gp
	if TEMIZ.has(aktif_bolge) and (TEMIZ[aktif_bolge] as Rect2).grow(-20.0).has_point(Vector2(lp.x, lp.z)):
		return
	_yakala_t -= _dt
	var g := IstGeo.h(p.x, p.z)
	if IstGeo.su(p.x, p.z) and p.y < 0.4:
		# Suya inen Nihat yeniden havalanır (eski su yakalayıcılarıyla aynı: NihatPowers.on_water)
		if _yakala_t <= 0.0:
			_yakala_t = 0.6
			if oyuncu.powers:
				oyuncu.powers.on_water()
			else:
				var k := IstDunya.kiyi_bul(p)
				oyuncu.global_position = kok.to_global(k + Vector3(0, 1.0, 0))
				oyuncu.velocity = Vector3.ZERO
	elif not IstGeo.su(p.x, p.z) and p.y < g - 1.2:
		# Arazinin altına düştü (çarpışma akışı yetişmedi): yüzeye çıkar
		oyuncu.global_position = kok.to_global(Vector3(p.x, g + 0.6, p.z))
		oyuncu.velocity.y = maxf(oyuncu.velocity.y, 0.0)
		if dunya != null:
			dunya.carpisma_yenile(Vector3(p.x, g + 0.6, p.z))
		print("ISTBAGLAMA zemin_yakalayici %s" % p)


## Bölüm biterken v2'nin ağaç dışında bekleyen düğümleri (ön-pişmiş katmanlar, akıştan düşmüş hücre gövdeleri) serbest
## bırakılır: sahne değişince bellek ve fizik gövdesi sızmasın
func _exit_tree() -> void:
	if bolum == 0 and aktif_bolge != "":
		# deneme (bölüm hazirla/birak çağırmıyor): sonraki bölümler eski dünyayı kursun
		birak.call_deferred()
	var s := IstSehir.active
	if s == null:
		return
	var n := 0
	for kap in [s.items, s.hat_items, s.get("_cells0")]:
		if kap is Array:
			n += _bosalt(kap)
	if n > 0:
		print("ISTBAGLAMA bosalt dugum=%d" % n)


static func _bosalt(v: Variant, derin := 0) -> int:
	if derin > 4:
		return 0
	var n := 0
	if typeof(v) == TYPE_OBJECT:
		if not is_instance_valid(v) or not (v is Node):
			return 0
		var nd := v as Node
		if not nd.is_inside_tree() and nd.get_parent() == null:
			nd.free()
			return 1
		return 0
	if v is Array:
		for x in v:
			n += _bosalt(x, derin + 1)
	elif v is Dictionary:
		for x in (v as Dictionary).values():
			n += _bosalt(x, derin + 1)
	return n
