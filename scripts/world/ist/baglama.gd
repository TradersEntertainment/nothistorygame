class_name IstBaglama
extends Node
## İstanbul v2'yi OYUNA bağlar (docs/_ajan/gorev/ist2_tur3.md, BAĞLAMA-3): Nihat'ın uçuş bölümleri (7, 11) yeni şehirde
## oynanır. Bölümün kendi sahnesi (ordugâh: CampDay; şehrin sur tarafı: ByzCity) olduğu gibi kurulur; çevresindeki dünya
## eski World1453 yerine İstanbul v2'dir (IstDunya + IstSehir + parçalar).
##
## Nasıl oturur: v2 dünyası yatayda ötelenir (IstGeo.kaydir): bölümün yerel çerçevesi = sahne = dünya çerçevesi (dönüşüm
## yok; bütün parçalar global konumla doğru çalışır). Yalnız öteleme olduğu için yönler v2'ninkidir (+x doğu, −z kuzey) ve
## deniz düzeyi y = 0'dır: bölümün zemini (y 0) v2 arazisine bölge yamasıyla (IstGeo.yama_ekle) yumuşak geçer.
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
## Bölümün yerel çapası: CampDay.OTAG_POS (v2 otağının yerine), ByzCity sur parçasının ortası (oyun alanının ortasına)
const CAMP_OTAG := Vector2(0.0, -62.0)
const HUB_ORTA := Vector2(-4.0, -13.0)
## Bölümün kendi zemini ve süsü bu yarıçapa kadar (yerel çapa çevresi); ötesi v2 arazisine yumuşak geçer
const YAMA := {"camp": [Vector2(0.0, -20.0), 170.0, 330.0], "byz_walls": [Vector2(-4.0, -13.0), 62.0, 170.0]}
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
	IstGeo.kaydir(Vector2.ZERO)
	_onbellek_sifirla()


static func istek(region_name: String) -> bool:
	if region_name == "byz_walls" and bolum == 0 and deneme_12b():
		return true
	return bolum in BOLUMLER and region_name in BOLGELER and etkin()


## Görev 6 denemesi (KAPALI; yalnız `--ist2-deneme=12b` ile): Tolga'nın mektup bölümü (12b) hub'ı v2'de. Bölüm dosyasına
## dokunulmaz: hub ByzCity'nin "walls" parçası, bölüm GameState.current_chapter 12.
static func deneme_12b() -> bool:
	if not etkin():
		return false
	var var_ := false
	for a: String in OS.get_cmdline_user_args() + OS.get_cmdline_args():
		if a.trim_prefix("--") == "ist2-deneme=12b":
			var_ = true
	if not var_:
		return false
	var gs := Engine.get_main_loop() as SceneTree
	if gs and gs.root.has_node("GameState"):
		return int(gs.root.get_node("GameState").get("current_chapter")) == 12
	return false


static func aktif() -> bool:
	return aktif_bolge != ""


# ------------------------------------------------------------------ yerleşim

## Ötelemeden önceki (kaydırmasız) v2'de bölümün çapasının yeri → öteleme
static func ofset(region_name: String) -> Vector2:
	IstGeo.kaydir(Vector2.ZERO)
	_onbellek_sifirla()
	match region_name:
		"camp":
			return CAMP_OTAG - _otag_v2()
		"byz_walls":
			return HUB_ORTA - _hub_v2()
	return Vector2.ZERO


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
	var ofs := ofset(region_name)
	IstGeo.kaydir(ofs)
	_onbellek_sifirla()
	aktif_bolge = region_name
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
	# Arazi yaması: bölümün zemini (yerel = dünya)
	var ym: Array = YAMA[region_name]
	var ic := Rect2()
	for r: Rect2 in keep_local:
		ic = r if ic.size == Vector2.ZERO else ic.merge(r)
	if region_name == "camp":
		var grid := Rect2(CampDay.GRID_X0, CampDay.GRID_Z0, CampDay.GRID_N * CampDay.GRID_STEP, CampDay.GRID_N * CampDay.GRID_STEP)
		IstGeo.yama_ekle(ym[0], ym[1], ym[2], func(x: float, z: float) -> float:
			# ızgaranın içinde bölümün kendi arazisi görünür (v2 0,35 m altında); dışında bölümün süsünün oturduğu yüzey
			return CampDay.height(x, z) - (0.35 if grid.grow(-0.5).has_point(Vector2(x, z)) else 0.03))
	else:
		var zr := ic.grow(4.0)
		IstGeo.yama_ekle(ym[0], ym[1], ym[2], func(x: float, z: float) -> float:
			return -0.35 if zr.has_point(Vector2(x, z)) else -0.05)
	var temiz: Rect2 = TEMIZ[region_name]
	IstGeo.dislanan = [temiz]
	# Ordugâh planı (önbellekli; IstOrdugah.attach aynı diziyi okur) kurulmadan süzülür: bölümün alanındaki öğeler çıkar
	_ordu_suzulen = 0
	var oscr = load("res://scripts/world/ist/ordugah.gd") if ResourceLoader.exists("res://scripts/world/ist/ordugah.gd") else null
	if oscr != null:
		var pl: Array = oscr.call("plan")
		for i in range(pl.size() - 1, -1, -1):
			var it: Dictionary = pl[i]
			if temiz.grow(float(it.get("r", 0.0))).has_point(it["pos"] as Vector2):
				pl.remove_at(i)
				_ordu_suzulen += 1
	# Kabuk
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
	var merkez := Vector3(ym[0].x, 2.0, ym[0].y)
	dunya = IstDunya.build(f, gece, merkez) as IstDunya
	IstDunya.gok_kur = true
	_temizle(region_name, temiz)
	var b := IstBaglama.new()
	b.name = "IstBaglama"
	f.add_child(b)
	son = b
	kurulum_ms = Time.get_ticks_msec() - t0
	print("ISTBAGLAMA bolge=%s bolum=%d gece=%s ofset=(%.1f, %.1f) kurulum_ms=%.0f" % [region_name, bolum, gece, ofs.x, ofs.y, kurulum_ms])
	return f


## Bölümün alanındaki v2 yapıları (IstSehir öğeleri, ordugâh öğeleri) kaldırılır: bölüm orada kendi sahnesini kurar
static func _temizle(region_name: String, alan: Rect2) -> void:
	var n_s := 0
	var s := IstSehir.active
	if s != null:
		for i in range(s.items.size() - 1, -1, -1):
			var it: Dictionary = s.items[i]
			var p: Vector3 = it["pos"]
			var r := float(it.get("r", 0.0))
			if alan.grow(r * 0.5).has_point(Vector2(p.x, p.z)):
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
	for poly in [IstGeo.kiyi("yarimada"), IstGeo.kiyi("galata")]:
		for p: Vector2 in poly:
			r = Rect2(p, Vector2.ZERO) if r.size == Vector2.ZERO and r.position == Vector2.ZERO else r.expand(p)
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
	var p := oyuncu.global_position
	# Bölümün kendi alanında bölümün zemini geçerli (yakalayıcı yok)
	if IstGeo.dislanan_mi(p.x, p.z) and TEMIZ.has(aktif_bolge) and (TEMIZ[aktif_bolge] as Rect2).grow(-20.0).has_point(Vector2(p.x, p.z)):
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
				oyuncu.global_position = k + Vector3(0, 1.0, 0)
				oyuncu.velocity = Vector3.ZERO
	elif not IstGeo.su(p.x, p.z) and p.y < g - 1.2:
		# Arazinin altına düştü (çarpışma akışı yetişmedi): yüzeye çıkar
		oyuncu.global_position = Vector3(p.x, g + 0.6, p.z)
		oyuncu.velocity.y = maxf(oyuncu.velocity.y, 0.0)
		if dunya != null:
			dunya.carpisma_yenile(oyuncu.global_position)
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
