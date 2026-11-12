class_name IstMahalleDoku
extends Node3D
## İstanbul v2 mahalle dokusunun ikinci katmanı (DOKU-2): IstSokak'ın verisinden
##   1. SOKAK ZEMİNİ: yol/ev/avlu/meydan hücreleri (2 m) üzerinde yürüyen kareler (marching squares) ile tek parça zemin:
##      Mese, forumlar ve meydanlar iri kesme taş döşeme; kapı yolları kaldırım taşı; ara sokaklar ve savunma yolu
##      sıkıştırılmış toprak (kuru/çamurlu lekeler). Yükseklik: arazinin tam yüksekliği ve arazi ağının 6/12/24 m'lik
##      bölünmelerinin en büyüğü + 6 cm (hiçbir ayrıntı düzeyinde araziye gömülmez, z-çakışması yok). 384 m hücre başına
##      iki yüzey (taş, toprak); 1 900 m'ye kadar.
##   2. AVLULAR: ev sırasının arkasında duvar (sık dokuda 2,4 m, seyrekte 1,0 m) + 1,6 m kapı ağzı; içte ağaç, kuyu,
##      çardak/kümes/çamaşır ipi. Duvarlar 192 m hücre başına tek ağ; çarpışma oyuncu/kamera çevresinde (akışla).
##   3. ÖĞELER ("boş alan yok"): kuyu, ağıl ve sürü, çiftlik evi, mezarlık, ağaç kümesi, şapel, bahçe duvarı/çit,
##      ayrıntı köşeleri (pazar, fırın önü, demirci, balıkçı iskelesi, sur onarım şantiyesi, mülteci çadırları, ayin).
##      64 m hücre başına: 380 m'de orta katman (pişmiş tek ağ), 110 m'de yakın (pişmiş ağ + çarpışma).
## Bağlantı: IstMahalleDoku.attach(sehir, sokak) (IstSokak.build sonunda IstSehir.active'e kendiliğinden bağlanır;
## ŞEHİR oturumu açıkça çağırırsa ikinci kez kurulmaz).

const ZEMIN_HUCRE := 384.0
const ZEMIN_UZAK := 1900.0
const DUVAR_HUCRE := 192.0
const DUVAR_UZAK := 700.0
const OGE_HUCRE := 64.0
const OGE_ORTA := 380.0
const OGE_YAKIN := 110.0
const CARP_YAKIN := 150.0

## Zemin renkleri (ISTANBUL_GORUNUS §2: toprak yol kuru #A89677 / çamurlu #7C6B52; kaldırım iri kesme taş #9A9588)
const R_MESE := Color("6f6656")
const R_YOL := Color("706a5e")
const R_TOPRAK := Color("8a785c")
const R_CAMUR := Color("6a5b46")
const R_AVLU := Color("83775f")
const R_SAVUNMA := Color("7e725f")

const SOKAK_ESYA := preload("res://scripts/world/ist/ayrinti_sokak.gd")
static var aktif: IstMahalleDoku
var sokak_esya: RefCounted
static var _kuruldu_sokak: IstSokak

var sk: IstSokak
var gece := false
var _cells := {}                  # Vector2i(64 m) → {oge: [], durum: 0 yok / 1 orta / 2 yakın, node, body}
var _duvar_cells := {}            # Vector2i(192 m) → {boxes: [[Transform3D, Vector3 boy]], body}
var _is_kuyrugu: Array = []       # [Vector2i, hedef durum]
var _son_kontrol := 0.0
var stats := {}
var _yh6 := PackedFloat32Array()
var _yh12 := PackedFloat32Array()
var _yh24 := PackedFloat32Array()
var _gx0 := 0.0
var _gz0 := 0.0
var _gn := Vector3i.ZERO          # 6 m ızgara boyutu (x, z) ve 12/24 için türetilir


## Kur ve bağla. parent: IstSehir (dünya koordinatında). Aynı sokak verisi için bir kez.
static func attach(parent: Node3D, sokak: IstSokak, gece_ := false) -> IstMahalleDoku:
	if sokak == null or _kuruldu_sokak == sokak:
		return aktif
	_kuruldu_sokak = sokak
	var m := IstMahalleDoku.new()
	m.name = "IstMahalleDoku"
	m.sk = sokak
	m.gece = gece_
	parent.add_child(m)
	aktif = m
	m._kur()
	return m


## Bekleyen iş sayısı (kare sondaları akışın bitmesini bekler)
static func bekleyen() -> int:
	if aktif == null or not is_instance_valid(aktif):
		return 0
	return aktif._is_kuyrugu.size() + (aktif.sokak_esya.bekleyen() if aktif.sokak_esya != null else 0) \
		+ aktif._zemin_bekleyen.size() + (1 if aktif._zemin_is >= 0 else 0)


func _kur() -> void:
	var t0 := Time.get_ticks_msec()
	_zemin()
	var t1 := Time.get_ticks_msec()
	_avlular()
	var t2 := Time.get_ticks_msec()
	_oge_hucreleri()
	stats["zemin_ms"] = t1 - t0
	stats["avlu_ms"] = t2 - t1
	stats["oge_ms"] = Time.get_ticks_msec() - t2
	print("ISTDOKU2 ", stats)
	sokak_esya = SOKAK_ESYA.new(self, sk)
	sokak_esya.kur()


# ================================================================ 1. sokak zemini

## Arazi ağının c'lik ızgarasındaki iki üçgen bölünmesinin (her iki köşegen) yüksekliklerinin en büyüğü
func _bol_h(arr: PackedFloat32Array, c: float, nxc: int, x: float, z: float) -> float:
	var fx := (x - _gx0) / c
	var fz := (z - _gz0) / c
	var i := clampi(int(fx), 0, nxc - 2)
	var j := clampi(int(fz), 0, arr.size() / nxc - 2)
	var tx := clampf(fx - i, 0.0, 1.0)
	var tz := clampf(fz - j, 0.0, 1.0)
	var h00 := arr[j * nxc + i]
	var h10 := arr[j * nxc + i + 1]
	var h01 := arr[(j + 1) * nxc + i]
	var h11 := arr[(j + 1) * nxc + i + 1]
	# köşegen 00–11
	var a := h00 + (h10 - h00) * tx + (h11 - h10) * tz if tx >= tz else h00 + (h01 - h00) * tz + (h11 - h01) * tx
	# köşegen 10–01
	var b := h00 + (h10 - h00) * tx + (h01 - h00) * tz if tx + tz <= 1.0 else h11 + (h01 - h11) * (1.0 - tx) + (h10 - h11) * (1.0 - tz)
	return maxf(a, b)


func _izgaralar() -> void:
	# arazi parçalarının ızgarası IstDunya.CX0'dan (24'ün katı) başlar: 6/12/24 m köşeler dünya ızgarasına hizalı
	_gx0 = floorf(sk.x0 / 24.0) * 24.0
	_gz0 = floorf(sk.z0 / 24.0) * 24.0
	var wx := sk.nx * IstSokak.G + 48.0
	var wz := sk.nz * IstSokak.G + 48.0
	for c: float in [6.0, 12.0, 24.0]:
		var n_x := int(wx / c) + 2
		var n_z := int(wz / c) + 2
		var arr := PackedFloat32Array()
		arr.resize(n_x * n_z)
		for j in n_z:
			for i in n_x:
				arr[j * n_x + i] = IstGeo.h(_gx0 + i * c, _gz0 + j * c)
		match int(c):
			6: _yh6 = arr; _gn.x = n_x
			12: _yh12 = arr; _gn.y = n_x
			24: _yh24 = arr; _gn.z = n_x


func _zy(x: float, z: float) -> float:
	var y := IstGeo.h(x, z)
	y = maxf(y, _bol_h(_yh6, 6.0, _gn.x, x, z))
	y = maxf(y, _bol_h(_yh12, 12.0, _gn.y, x, z))
	y = maxf(y, _bol_h(_yh24, 24.0, _gn.z, x, z))
	return y + 0.06


## Hücre türü: 0 yok, 1 taş (döşeme), 2 kaldırım, 3 toprak, 4 savunma, 5 avlu
func _zt(k: int, ek: PackedByteArray) -> int:
	if ek[k] != 0:
		return ek[k]
	var o := sk.occ[k]
	if o == 1:
		var r := sk.rid[k]
		if r < 0:
			return 3
		return _skod[r]
	if o == 2:
		return 3
	if o == 6:
		return 5
	return 0


var _skod := PackedByteArray()

func _zemin() -> void:
	_izgaralar()
	# DOKU-4 (yükleme): hücre ağlarının dizileri diskte (sokak verisi + arazi ızgaraları + kod aynıysa)
	var imza := IstSokak.onbellek_imza(["res://scripts/world/ist/mahalle_doku.gd", sk.occ, sk.rid, sk.streets.size(), sk.zemin_ek,
		sk.x0, sk.z0, sk.nx, sk.nz, _yh6, _yh24, _gx0, _gz0])
	var gruplar := {}                 # Vector2i → [[verts, cols] taş, [verts, cols] toprak]
	if IstSokak.onbellek_var("zemin", imza):
		# önbellek var: dosya arka plan iş parçacığında okunur, hücre ağları ilk karelerden sonra (kare bütçesiyle,
		# kameraya yakından uzağa) kurulur; zemin yalnız görünüştür (çarpışma arazinin ve evlerin)
		_zemin_imza = imza
		_zemin_is = WorkerThreadPool.add_task(_zemin_oku_is)
		stats["zemin_onbellek"] = "arka_plan"
		return
	else:
		gruplar = _zemin_hesapla()
		IstSokak.onbellek_yaz("zemin", imza, {"gruplar": gruplar, "n_kare": stats.get("zemin_kare", 0)})
	_zemin_kur(gruplar)


var _zemin_imza := ""
var _zemin_is := -1
var _zemin_ob = null
var _zemin_bekleyen: Array = []      # [Vector2i] kurulacak hücreler (okunduktan sonra)
var _zemin_gruplar := {}

func _zemin_oku_is() -> void:
	_zemin_ob = IstSokak.onbellek_oku("zemin", _zemin_imza)


## Kare başına: arka plan okuması bittiyse zemin hücrelerini kur (bütçe içinde; en az bir hücre)
func _zemin_akis(butce_us: int) -> void:
	if _zemin_is >= 0:
		if not WorkerThreadPool.is_task_completed(_zemin_is):
			return
		WorkerThreadPool.wait_for_task_completion(_zemin_is)
		_zemin_is = -1
		if _zemin_ob is Dictionary and (_zemin_ob as Dictionary).has("gruplar"):
			_zemin_gruplar = _zemin_ob["gruplar"]
			stats["zemin_kare"] = _zemin_ob.get("n_kare", 0)
		else:
			# okunamadı: eşzamanlı hesap (yalnız bozuk önbellekte)
			_zemin_gruplar = _zemin_hesapla()
		_zemin_ob = null
		var cp := _cam()
		_zemin_bekleyen = _zemin_gruplar.keys()
		_zemin_bekleyen.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
			return Vector2((a.x + 0.5) * ZEMIN_HUCRE - cp.x, (a.y + 0.5) * ZEMIN_HUCRE - cp.z).length_squared() < Vector2((b.x + 0.5) * ZEMIN_HUCRE - cp.x, (b.y + 0.5) * ZEMIN_HUCRE - cp.z).length_squared())
		return
	if _zemin_bekleyen.is_empty():
		return
	var t0 := Time.get_ticks_usec()
	while not _zemin_bekleyen.is_empty() and Time.get_ticks_usec() - t0 < butce_us:
		var ck: Vector2i = _zemin_bekleyen.pop_front()
		_zemin_kur({ck: _zemin_gruplar[ck]})
		_zemin_gruplar.erase(ck)
	if _zemin_bekleyen.is_empty():
		stats["zemin_hucre"] = get_children().filter(func(c: Node) -> bool: return c.name.begins_with("Zemin_")).size()


func _zemin_hesapla() -> Dictionary:
	_skod.resize(sk.streets.size())
	for i in sk.streets.size():
		_skod[i] = {"mese": 1, "yol": 2, "savunma": 4}.get(String(sk.streets[i]["tur"]), 3)
	var nx := sk.nx
	var nz := sk.nz
	# döşeli meydan diskleri (Augustaion, forumlar, kapı önleri, mahalle meydanları)
	var ek := PackedByteArray()
	ek.resize(nx * nz)
	for z: Dictionary in sk.zemin_ek:
		var c: Vector2 = z["c"]
		var r := float(z["r"])
		var t := 1 if String(z["tur"]) == "mese" else 2
		for j in range(maxi(0, int((c.y - r - sk.z0) / IstSokak.G)), mini(nz, int((c.y + r - sk.z0) / IstSokak.G) + 1)):
			for i in range(maxi(0, int((c.x - r - sk.x0) / IstSokak.G)), mini(nx, int((c.x + r - sk.x0) / IstSokak.G) + 1)):
				var k := j * nx + i
				if sk.cell_c(i, j).distance_to(c) <= r and sk.occ[k] in [0, 1, 5, 6]:
					ek[k] = t
	var tur := PackedByteArray()
	tur.resize(nx * nz)
	for k in nx * nz:
		if sk.occ[k] in [1, 2, 6] or ek[k] != 0:
			tur[k] = _zt(k, ek)
	var ys := PackedFloat32Array()
	ys.resize(nx * nz)
	var cs := PackedColorArray()
	cs.resize(nx * nz)
	for k in nx * nz:
		if tur[k] != 0:
			var cc := sk.cell_c(k % nx, k / nx)
			ys[k] = _zy(cc.x, cc.y)
			cs[k] = _renk(tur[k], cc)
	var gruplar := {}                 # Vector2i → [[verts, cols] taş, [verts, cols] toprak]
	var n_kare := 0
	var G := IstSokak.G
	for j in nz - 1:
		for i in nx - 1:
			var k00 := j * nx + i
			var t00 := tur[k00]
			var t10 := tur[k00 + 1]
			var t01 := tur[k00 + nx]
			var t11 := tur[k00 + nx + 1]
			if t00 == 0 and t10 == 0 and t01 == 0 and t11 == 0:
				continue
			var p0 := Vector2(sk.x0 + (i + 0.5) * G, sk.z0 + (j + 0.5) * G)
			var ck := Vector2i(floori(p0.x / ZEMIN_HUCRE), floori(p0.y / ZEMIN_HUCRE))
			if not gruplar.has(ck):
				gruplar[ck] = [[PackedVector3Array(), PackedColorArray()], [PackedVector3Array(), PackedColorArray()]]
			var cen := Vector2((ck.x + 0.5) * ZEMIN_HUCRE, (ck.y + 0.5) * ZEMIN_HUCRE)
			var q0 := p0 - cen
			var ks := [k00, k00 + 1, k00 + nx + 1, k00 + nx]
			var ts := [t00, t10, t11, t01]
			var tas := 0
			var cnt := 0
			for t in ts:
				if t != 0:
					cnt += 1
					if t == 1 or t == 2:
						tas += 1
			var g: Array = gruplar[ck][0 if tas * 2 > cnt else 1]
			var vv: PackedVector3Array = g[0]
			var cc: PackedColorArray = g[1]
			var pts := [Vector2(0, 0), Vector2(G, 0), Vector2(G, G), Vector2(0, G)]
			var pv: Array = []
			var pc: Array = []
			for q in 4:
				var qn := (q + 1) % 4
				var kq: int = ks[q]
				if ts[q] != 0:
					pv.append(Vector3(q0.x + pts[q].x, ys[kq], q0.y + pts[q].y))
					pc.append(cs[kq])
				if (ts[q] != 0) != (ts[qn] != 0):
					var ka: int = ks[q] if ts[q] != 0 else ks[qn]
					var mid: Vector2 = (pts[q] + pts[qn]) * 0.5
					pv.append(Vector3(q0.x + mid.x, ys[ka], q0.y + mid.y))
					pc.append(cs[ka])
			if pv.size() < 3:
				continue
			for f in range(1, pv.size() - 1):
				vv.append(pv[0]); cc.append(pc[0])
				vv.append(pv[f]); cc.append(pc[f])
				vv.append(pv[f + 1]); cc.append(pc[f + 1])
			g[0] = vv
			g[1] = cc
			n_kare += 1
	stats["zemin_kare"] = n_kare
	return gruplar


var _zm: Array = []

func _zemin_kur(gruplar: Dictionary) -> void:
	if _zm.is_empty():
		_zm = [_zemin_mat(true), _zemin_mat(false)]
	var mt: Material = _zm[0]
	var mt2: Material = _zm[1]
	for ck: Vector2i in gruplar:
		var am := ArrayMesh.new()
		for idx in 2:
			var g: Array = gruplar[ck][idx]
			var vv: PackedVector3Array = g[0]
			if vv.is_empty():
				continue
			var nn := PackedVector3Array()
			nn.resize(vv.size())
			nn.fill(Vector3.UP)
			var arr := []
			arr.resize(Mesh.ARRAY_MAX)
			arr[Mesh.ARRAY_VERTEX] = vv
			arr[Mesh.ARRAY_NORMAL] = nn
			arr[Mesh.ARRAY_COLOR] = g[1]
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
			am.surface_set_material(am.get_surface_count() - 1, mt if idx == 0 else mt2)
		if am.get_surface_count() == 0:
			continue
		var mi := MeshInstance3D.new()
		mi.mesh = am
		mi.position = Vector3((ck.x + 0.5) * ZEMIN_HUCRE, 0, (ck.y + 0.5) * ZEMIN_HUCRE)
		mi.visibility_range_end = ZEMIN_UZAK
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)
		mi.name = "Zemin_%d_%d" % [ck.x, ck.y]
		add_child(mi)
	stats["zemin_hucre"] = gruplar.size()


static func _hs(x: float, y: float, s: int) -> float:
	var v := sin(x * 12.9898 + y * 78.233 + s * 37.719) * 43758.5453
	return v - floorf(v)


## Zemin rengi: tür + leke (iri, 9 m dalga) + tane (hücre) oynaması
func _renk(t: int, p: Vector2) -> Color:
	var leke := 0.5 + 0.25 * sin(p.x * 0.11 + sin(p.y * 0.07) * 2.0) + 0.25 * sin(p.y * 0.13 + p.x * 0.03)
	var tane := _hs(floorf(p.x * 0.5), floorf(p.y * 0.5), t) - 0.5
	var c: Color
	match t:
		1: c = R_MESE.lerp(Color("7b6d5a"), leke * 0.6)
		2: c = R_YOL.lerp(Color("6b665c"), leke * 0.5)
		4: c = R_SAVUNMA.lerp(R_CAMUR, leke * 0.35)
		5: c = R_AVLU.lerp(Color("7a7653"), leke * 0.45)
		_: c = R_TOPRAK.lerp(R_CAMUR, clampf(leke * 0.7 - 0.1, 0.0, 1.0))
	return c.lightened(tane * 0.08) if tane > 0.0 else c.darkened(-tane * 0.08)


func _zemin_mat(tas: bool) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.vertex_color_is_srgb = true
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	if tas:
		# Prokonnesos/kireçtaşı döşeme (kalite notu 17): düzensiz sıralı kesme taş, derz, kırık, otlu derz; 7,2 m'de bir tekrar
		var tex := dosek_tex()
		m.albedo_texture = tex
		var a := World1453._avg(tex)
		# doku parlaklığı 1'e çekilir (renk tonu korunur): görünen renk köşe rengi × taşın kendi tonu
		var l := maxf((a.r + a.g + a.b) / 3.0, 0.3)
		m.albedo_color = Color(1.0 / l, 1.0 / l, 1.0 / l)
		m.uv1_triplanar = true
		m.uv1_world_triplanar = true
		m.uv1_scale = Vector3(1.0 / 7.2, 1.0 / 7.2, 1.0 / 7.2)
	else:
		# toprak: yumuşak gürültü (sıkışmış toprak, çakıl lekeleri); ortalaması 1'e çekilir
		var tex := Props._noise("concrete")
		m.albedo_texture = tex
		m.albedo_color = Color(0.92, 0.9, 0.86)
		m.uv1_triplanar = true
		m.uv1_world_triplanar = true
		m.uv1_scale = Vector3(0.18, 0.18, 0.18)
	return m


static var _dosek: ImageTexture


## Döşeme dokusu (512 px = 7,2 m; dikişsiz): sıra yükseklikleri 0,35–0,75 m, taş boyları 0,4–1,3 m (sıra başına kaydırma),
## taş başına ton (sıcak gri-krem, yer yer pembemsi ve griye kaçan Prokonnesos), aşınma lekesi, kırık çizgisi,
## 2–3 px koyu derz, derzde ve kırık taşta ot.
static func dosek_tex() -> ImageTexture:
	if _dosek != null:
		return _dosek
	# DOKU-4: üretilen doku diskte (aynı kod → aynı doku); piksel döngüsü ~1 sn
	var ob_yol := IstSokak.ONBELLEK_DIR + "dosek_" + IstSokak.onbellek_imza(["res://scripts/world/ist/mahalle_doku.gd"]) + ".png"
	if IstSokak._ob_kip() not in ["yok", "yaz"] and FileAccess.file_exists(ob_yol):
		var oi := Image.load_from_file(ob_yol)
		if oi != null and not oi.is_empty():
			oi.generate_mipmaps()
			_dosek = ImageTexture.create_from_image(oi)
			return _dosek
	const N := 512
	var rng := RandomNumberGenerator.new()
	rng.seed = 17453
	var img := Image.create(N, N, false, Image.FORMAT_RGB8)
	var px := N / 7.2
	var tonlar := [Color(0.80, 0.76, 0.68), Color(0.76, 0.73, 0.67), Color(0.83, 0.78, 0.69), Color(0.72, 0.69, 0.63),
		Color(0.79, 0.73, 0.66), Color(0.70, 0.67, 0.60), Color(0.85, 0.81, 0.72), Color(0.75, 0.70, 0.62)]
	var derz := Color(0.36, 0.33, 0.28)
	var ot := Color(0.34, 0.40, 0.20)
	# sıralar
	var rows: Array = []
	var y := 0
	while y < N:
		var h := int(rng.randf_range(0.35, 0.75) * px)
		if N - (y + h) < int(0.3 * px):
			h = N - y
		rows.append([y, h])
		y += h
	for r: Array in rows:
		var y0: int = r[0]
		var h: int = r[1]
		var x := 0
		var off := rng.randi_range(0, N - 1)
		while x < N:
			var w := int(rng.randf_range(0.4, 1.3) * px)
			if N - (x + w) < int(0.35 * px):
				w = N - x
			var ton: Color = tonlar[rng.randi_range(0, tonlar.size() - 1)]
			ton = ton.lightened(rng.randf_range(0.0, 0.06)) if rng.randf() < 0.5 else ton.darkened(rng.randf_range(0.0, 0.10))
			var kirik := rng.randf() < 0.22
			var otlu := rng.randf() < 0.10
			var ka := rng.randf_range(-0.8, 0.8)
			var kb := rng.randf_range(0.2, 0.8)
			var lk := Vector2(rng.randf_range(0, w), rng.randf_range(0, h))
			var lr := rng.randf_range(4.0, 18.0)
			for j in h:
				for i in w:
					var X := (x + i + off) % N
					var Y := y0 + j
					var c := ton
					var kenar := mini(mini(i, w - 1 - i), mini(j, h - 1 - j))
					if kenar < 2:
						var g := sin((X * 0.37 + Y * 0.21)) * 0.5 + 0.5
						c = derz.lerp(ot, 0.6) if g > 0.93 else derz
					else:
						var n := sin(X * 0.9 + Y * 1.3) * sin(X * 0.31 - Y * 0.57) * 0.035 + rng.randf_range(-0.025, 0.025)
						c = Color(c.r + n, c.g + n, c.b + n * 0.8)
						if kenar < 4:
							c = c.darkened(0.08)
						if Vector2(i, j).distance_to(lk) < lr:
							c = c.darkened(0.06)
						if kirik and absf((float(j) / h) - (kb + ka * (float(i) / w - 0.5))) < 0.012 + 0.006 * sin(i * 0.8):
							c = derz.lerp(c, 0.35)
						if otlu and kenar < 6 and sin(X * 1.7 + Y * 2.3) > 0.2:
							c = ot.lerp(c, 0.3)
					img.set_pixel(X, Y, c)
			x += w
	if IstSokak._ob_kip() != "yok":
		DirAccess.make_dir_recursive_absolute(IstSokak.ONBELLEK_DIR)
		var da := DirAccess.open(IstSokak.ONBELLEK_DIR)
		if da != null:
			for fn: String in da.get_files():
				if fn.begins_with("dosek_") and IstSokak.ONBELLEK_DIR + fn != ob_yol:
					da.remove(fn)
		img.save_png(ob_yol)
	img.generate_mipmaps()
	_dosek = ImageTexture.create_from_image(img)
	return _dosek


# ================================================================ 2. avlular

const AVLU_AGAC := ["erguvan", "incir", "nar", "dut", "servi", "badem", "zeytin"]
const BAHCE_AGAC := ["incir", "dut", "zeytin", "servi", "nar", "erguvan", "badem", "kiraz", "defne"]


## Sebze tarhları ve çalılar (alçak, çarpışmasız): 192 m hücre başına tek ağ (köşe renkli)
static var _tmat: StandardMaterial3D

static func _tarh_mat() -> StandardMaterial3D:
	if _tmat == null:
		_tmat = StandardMaterial3D.new()
		_tmat.vertex_color_use_as_albedo = true
		_tmat.vertex_color_is_srgb = true
		_tmat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		_tmat.roughness = 1.0
	return _tmat


func _tarhlar(tarh: Dictionary) -> void:
	var renk := [Color("4f6a2e"), Color("5e7a34"), Color("6b7a3a"), Color("7a6a48")]
	var mat := _tarh_mat()
	for tk: Vector2i in tarh:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var cen := Vector3((tk.x + 0.5) * DUVAR_HUCRE, 0, (tk.y + 0.5) * DUVAR_HUCRE)
		for e: Array in tarh[tk]:
			var c: Vector2 = e[0]
			var hsh: float = e[1]
			var y := IstGeo.h(c.x, c.y)
			var bas := Basis(Vector3.UP, hsh * 23.0)
			if hsh < 0.52:
				# üç sıra sebze tarhı (toprak + yeşil sıra)
				_kutu(st, Transform3D(bas, Vector3(c.x, y + 0.04, c.y)), Vector3(3.4, 0.12, 3.0), Color("6a5a40"), cen)
				for r in 3:
					_kutu(st, Transform3D(bas, Vector3(c.x, y + 0.2, c.y) + bas * Vector3(0, 0, (r - 1) * 0.95)), Vector3(3.0, 0.22, 0.45), renk[(r + int(hsh * 100.0)) % 3], cen)
			elif hsh < 0.62:
				# çalı kümesi
				for r in 3:
					var o := bas * Vector3((r - 1) * 0.9, 0, (r % 2) * 0.6)
					_kutu(st, Transform3D(bas.rotated(Vector3.UP, r * 0.7), Vector3(c.x, y + 0.35, c.y) + o), Vector3(1.0, 0.75, 0.9), renk[(r + 1) % 4], cen)
			else:
				# DOKU-4 ("boş alan yok"; evlerin arası düz yeşil kalıyordu): parsel dokusu, 6 m ızgaranın kalan noktaları
				var bp := Basis(Vector3.UP, roundf(hsh * 7.0) * 0.08)
				var t := fposmod(hsh * 37.0, 1.0)
				if t < 0.5:
					# sürülmüş bostan toprağı / nadas: yere yatık parsel (köşeler zeminin üstünde), sıra izli
					var sz := Vector2(5.4, 5.0)
					var tc: Color = TOPRAK_PARSEL[int(t * 8.0) % TOPRAK_PARSEL.size()]
					_parsel(st, c, bp, sz, tc, cen)
					for r in 4:
						var q := c + Vector2(0, (r - 1.5) * 1.15).rotated(-bp.get_euler().y)
						_parsel(st, q, bp, Vector2(5.0, 0.35), tc.darkened(0.18), cen, 0.025)
				elif t < 0.78:
					# kuru taş bahçe duvarı (diz boyu, parsel kenarı)
					var cy := IstGeo.h(c.x, c.y)
					_kutu(st, Transform3D(bp, Vector3(c.x, cy + 0.3, c.y + 2.6)), Vector3(5.8, 0.75, 0.55), Color("7d7466").darkened(t * 0.2), cen)
					_kutu(st, Transform3D(bp, Vector3(c.x + 2.6, cy + 0.3, c.y)), Vector3(0.55, 0.75, 5.2), Color("756d60"), cen)
				else:
					# çiğnenmiş patika + seyrek ot öbeği
					_parsel(st, c, bp.rotated(Vector3.UP, 0.6), Vector2(1.4, 6.0), Color("8a7a5e"), cen)
					for r in 3:
						var o := Vector2((r - 1) * 1.7, (r % 2) * 1.3 - 0.6)
						_kutu(st, Transform3D(bp, Vector3(c.x + o.x + 1.6, IstGeo.h(c.x, c.y) + 0.12, c.y + o.y)), Vector3(0.6, 0.3, 0.55), Color("6b7342"), cen)
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		mi.material_override = mat
		mi.position = cen
		mi.visibility_range_end = DUVAR_UZAK
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)
		add_child(mi)

const TOPRAK_PARSEL := [Color("6a5640"), Color("725c42"), Color("5e4c36"), Color("7a6448"), Color("665a3c"), Color("6e6244")]

## Yere yatık parsel dörtgeni: köşeler mahalle zemininin (_zy) üstünde (arazi ağının hiçbir bölünmesine gömülmez)
func _parsel(st: SurfaceTool, c: Vector2, bas: Basis, sz: Vector2, col: Color, cen: Vector3, ek := 0.0) -> void:
	var k: Array = []
	for o: Vector2 in [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.5, 0.5), Vector2(-0.5, 0.5)]:
		var w := bas * Vector3(o.x * sz.x, 0, o.y * sz.y)
		var p := Vector2(c.x + w.x, c.y + w.z)
		k.append(Vector3(p.x, _zy(p.x, p.y) + 0.02 + ek, p.y) - cen)
	st.set_color(col)
	st.set_normal(Vector3.UP)
	for v: Vector3 in [k[0], k[2], k[1], k[0], k[3], k[2]]:
		st.add_vertex(v)


## DOKU-4 (yükleme): avlu katmanının sonucu (ağ dizileri, çarpışma kutuları, avlu öğeleri) diskte
var _kayit = null                 # Array: _avlular sırasında eklenen öğeler (önbelleğe)

func _avlular() -> void:
	var imza := IstSokak.onbellek_imza(["res://scripts/world/ist/mahalle_doku.gd", "res://scripts/world/ist/bitki.gd",
		"res://scripts/world/ist/evler.gd", sk.ob_imza, _yh6])
	var ob = IstSokak.onbellek_oku("avlu", imza) if sk.ob_imza != "" else null
	if ob is Dictionary and ob.has("mi"):
		for r: Array in ob["mi"]:
			var mi := MeshInstance3D.new()
			var am := ArrayMesh.new()
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, r[4])
			mi.mesh = am
			match String(r[3]):
				"duvar": mi.material_override = _duvar_mat()
				"tarh": mi.material_override = _tarh_mat()
				_: mi.material_override = IstBitki.tree_mesh("incir", 1).surface_get_material(0)
			mi.position = r[0]
			mi.visibility_range_end = r[1]
			mi.cast_shadow = r[2]
			mi.set_meta("no_walk", true)
			add_child(mi)
		_duvar_cells = ob["duvar"]
		for o: Dictionary in ob["oge"]:
			_oge_ekle(o)
		for k: String in ob["stats"]:
			stats[k] = ob["stats"][k]
		stats["avlu_onbellek"] = "okundu"
		return
	var once := get_child_count()
	_kayit = []
	_avlular_hesapla()
	var kayit: Array = _kayit
	_kayit = null
	if sk.ob_imza == "":
		return
	var mis: Array = []
	for i in range(once, get_child_count()):
		var mi := get_child(i) as MeshInstance3D
		if mi == null or mi.mesh == null or mi.mesh.get_surface_count() != 1:
			return
		var mk := "agac"
		if mi.material_override == _duvar_mat():
			mk = "duvar"
		elif mi.material_override == _tarh_mat():
			mk = "tarh"
		mis.append([mi.position, mi.visibility_range_end, mi.cast_shadow, mk, mi.mesh.surface_get_arrays(0)])
	IstSokak.onbellek_yaz("avlu", imza, {"mi": mis, "duvar": _duvar_cells, "oge": kayit,
		"stats": {"avlu": stats.get("avlu", 0), "duvar_hucre": stats.get("duvar_hucre", 0), "bahce_agac": stats.get("bahce_agac", 0)}})


func _avlular_hesapla() -> void:
	var gruplar := {}                 # Vector2i(192) → SurfaceTool
	var agac := {}                    # Vector2i(64) → {tür: [Transform3D]}
	var n := 0
	for a: Dictionary in sk.avlu:
		var c: Vector2 = a["c"]
		var u: Vector2 = a["u"]
		var v: Vector2 = a["v"]
		var hx := float(a["hx"])
		var hz := float(a["hz"])
		var h := float(a["h"])
		var kapi := int(a["kapi"])
		var tohum := int(a["tohum"])
		var col: Color = IstEvler.P_TAS[tohum % 4] if h > 2.0 else IstEvler.P_KERPIC[tohum % 3].lerp(IstEvler.P_TAS[0], 0.4)
		var ck := Vector2i(floori(c.x / DUVAR_HUCRE), floori(c.y / DUVAR_HUCRE))
		if not gruplar.has(ck):
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			gruplar[ck] = st
			_duvar_cells[ck] = {"boxes": [], "body": null}
		var cen := Vector3((ck.x + 0.5) * DUVAR_HUCRE, 0, (ck.y + 0.5) * DUVAR_HUCRE)
		var th := 0.4
		# arka duvar (+v kenarı), sol (−u) ve sağ (+u) duvarlar (ön kenar ev sırasının arka cephesi)
		var kenarlar := [
			[c + v * (hz - th * 0.5) - u * hx, c + v * (hz - th * 0.5) + u * hx, 2],
			[c - u * (hx - th * 0.5) - v * hz, c - u * (hx - th * 0.5) + v * hz, 0],
			[c + u * (hx - th * 0.5) - v * hz, c + u * (hx - th * 0.5) + v * hz, 1],
		]
		for e: Array in kenarlar:
			var p: Vector2 = e[0]
			var q: Vector2 = e[1]
			var L := p.distance_to(q)
			if L < 0.5:
				continue
			var dd := (q - p) / L
			var parcalar: Array = [[0.0, L]]
			if int(e[2]) == kapi:
				var m := L * 0.5 if int(e[2]) == 2 else L * 0.6
				parcalar = [[0.0, m - 0.8], [m + 0.8, L]]
			for pr: Array in parcalar:
				var s0 := float(pr[0])
				var s1 := float(pr[1])
				var t := s0
				while t < s1 - 0.05:
					var t2 := minf(t + 4.0, s1)
					var a2 := p + dd * t
					var b2 := p + dd * t2
					var lo := minf(IstGeo.h(a2.x, a2.y), IstGeo.h(b2.x, b2.y))
					var hi := maxf(IstGeo.h(a2.x, a2.y), IstGeo.h(b2.x, b2.y))
					var mid := (a2 + b2) * 0.5
					var boy := Vector3(t2 - t, hi - lo + h + 0.3, th)
					var bas := Basis(Vector3.UP, atan2(-dd.y, dd.x))
					var xf := Transform3D(bas, Vector3(mid.x, lo - 0.3 + boy.y * 0.5, mid.y))
					_kutu(gruplar[ck], xf, boy, col, cen)
					# kapak taşı
					_kutu(gruplar[ck], Transform3D(bas, Vector3(mid.x, lo - 0.3 + boy.y + 0.06, mid.y)), Vector3(boy.x + 0.04, 0.12, th + 0.12), col.darkened(0.12), cen)
					(_duvar_cells[ck]["boxes"] as Array).append([xf, boy])
					t = t2
			# kapı ağzının iki yanında ahşap kanat izi (açık)
		# iç: ağaç (bir ya da iki), kuyu ya da çardak (64 m hücrelerin öğe listesine)
		var ic := c + v * (hz * 0.3) + u * (hx * 0.35 * (1.0 if tohum % 2 == 0 else -1.0))
		var ak := Vector2i(floori(ic.x / OGE_HUCRE), floori(ic.y / OGE_HUCRE))
		var tur: String = AVLU_AGAC[tohum % AVLU_AGAC.size()]
		if not agac.has(ak):
			agac[ak] = {}
		if not agac[ak].has(tur):
			agac[ak][tur] = []
		agac[ak][tur].append(Transform3D(Basis(Vector3.UP, tohum * 0.37).scaled(Vector3.ONE * (0.8 + (tohum % 5) * 0.08)), Vector3(ic.x, IstGeo.h(ic.x, ic.y) - 0.05, ic.y)))
		if hx > 5.0 and hz > 2.5:
			var ic2 := c - u * (hx * 0.4 * (1.0 if tohum % 2 == 0 else -1.0)) + v * (hz * 0.1)
			var oz: String = ["kuyu", "asma_cardagi", "kumes", "camasir_ipi", "kuyu", "odun_yigini"][tohum % 6]
			_oge_ekle({"tur": oz, "c": ic2, "yaw": atan2(-v.x, -v.y), "tohum": tohum, "avlu": true})
		n += 1
	for ck: Vector2i in gruplar:
		var st: SurfaceTool = gruplar[ck]
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		mi.material_override = _duvar_mat()
		mi.position = Vector3((ck.x + 0.5) * DUVAR_HUCRE, 0, (ck.y + 0.5) * DUVAR_HUCRE)
		mi.visibility_range_end = DUVAR_UZAK
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		mi.set_meta("no_walk", true)
		add_child(mi)
	# blok içlerinde kalan boş yerler: bahçe ağaçları ve tarhlar (her 6 m'de; çevresi 3 × 3 hücre boşsa: geçit tıkanmaz)
	var nb := 0
	var tarh := {}
	for j in range(1, sk.nz - 1, 3):
		for i in range(1, sk.nx - 1, 3):
			var k := j * sk.nx + i
			if sk.occ[k] != 0:
				continue
			var bos := true
			for dj in range(-1, 2):
				for di in range(-1, 2):
					if sk.occ[k + dj * sk.nx + di] != 0:
						bos = false
			if not bos:
				continue
			var c := sk.cell_c(i, j)
			if not (IstGeo.sehir_ici(c.x, c.y) or IstGeo.galata_ici(c.x, c.y)):
				continue
			var hsh := _hs(float(i), float(j), 3)
			c += Vector2(_hs(float(i), float(j), 5) - 0.5, _hs(float(i), float(j), 6) - 0.5) * 1.6
			if hsh < 0.42:
				var ak := Vector2i(floori(c.x / OGE_HUCRE), floori(c.y / OGE_HUCRE))
				var tur: String = BAHCE_AGAC[int(hsh * 1000.0) % BAHCE_AGAC.size()]
				if not agac.has(ak):
					agac[ak] = {}
				if not agac[ak].has(tur):
					agac[ak][tur] = []
				agac[ak][tur].append(Transform3D(Basis(Vector3.UP, hsh * 40.0).scaled(Vector3.ONE * (0.75 + hsh * 0.5)), Vector3(c.x, IstGeo.h(c.x, c.y) - 0.05, c.y)))
				nb += 1
			else:
				var tk := Vector2i(floori(c.x / DUVAR_HUCRE), floori(c.y / DUVAR_HUCRE))
				if not tarh.has(tk):
					tarh[tk] = []
				tarh[tk].append([c, hsh])
	stats["bahce_agac"] = nb
	_tarhlar(tarh)
	# avlu ağaçları: 192 m hücre başına TEK ağ (bütün türler birleşik; IstBitki tek malzeme), 380 m'ye kadar
	var ag2 := {}
	for ak: Vector2i in agac:
		for tur: String in agac[ak]:
			for x: Transform3D in agac[ak][tur]:
				var k2 := Vector2i(floori(x.origin.x / DUVAR_HUCRE), floori(x.origin.z / DUVAR_HUCRE))
				if not ag2.has(k2):
					ag2[k2] = []
				ag2[k2].append([tur, x])
	for k2: Vector2i in ag2:
		if not _duvar_cells.has(k2):
			_duvar_cells[k2] = {"boxes": [], "body": null}
		for e: Array in ag2[k2]:
			var x: Transform3D = e[1]
			(_duvar_cells[k2]["boxes"] as Array).append([Transform3D(Basis.IDENTITY, x.origin + Vector3(0, 1.1, 0)), Vector3(0.45, 2.2, 0.45)])
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var cen := Vector3((k2.x + 0.5) * DUVAR_HUCRE, 0, (k2.y + 0.5) * DUVAR_HUCRE)
		var mat: Material = null
		for e: Array in ag2[k2]:
			var m: Mesh = IstBitki.tree_mesh(String(e[0]), 1)
			if m == null:
				continue
			var x: Transform3D = e[1]
			for si in m.get_surface_count():
				if mat == null:
					mat = m.surface_get_material(si)
				st.append_from(m, si, Transform3D(x.basis, x.origin - cen))
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		if mat:
			mi.material_override = mat
		mi.position = cen
		mi.visibility_range_end = OGE_ORTA
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		mi.set_meta("no_walk", true)
		add_child(mi)
	stats["avlu"] = n
	stats["duvar_hucre"] = gruplar.size()
	_cati_gecitleri()


## DOKU-4 madde 2 (çatıdan çatıya): aynı sıradaki bitişik iki evin yürünür üstü (kiremit sırtı H+1,6; düz dam H+0,18;
## teras/kule korkuluğu H+1,2) arasında > 0,35 m fark ya da korkuluk varsa iki evin sırt noktalarını birleştiren hat
## üstünde ahşap basamaklı çatı geçidi: basamak ≤ 0,30 m (evlerin dış merdiveniyle aynı kural; STEP_H 0,42), sınırın
## üstünde 0,9 m'lik sahanlık. Görünüş avlu duvarı ağına (köşe renkli ahşap), çarpışma avlu duvarı akışına (kutular).
const GECIT_RISE := 0.30
const GECIT_EN := 1.3
const GECIT_RENK := Color("6b5640")

func _ev_ust(h: Dictionary) -> Dictionary:
	var v := int(h["v"])
	var tip := String(h["tip"])
	var d := IstEvler.dims(v)
	var key := "%d|%s" % [v, tip]
	var p: Dictionary
	if _plan_cache.has(key):
		p = _plan_cache[key]
	else:
		p = IstEvler.plan(d.x, d.z, d.y, IstEvler._tohum(v, tip), tip)
		_plan_cache[key] = p
	var on: Vector2 = h["on"]
	var y0 := IstGeo.h(on.x, on.y) - 0.04
	var cati := String(p["cati"])
	var yuz := y0 + d.y + 0.18
	var engel := yuz
	match cati:
		"kiremit":
			yuz = y0 + d.y + IstEvler.RISE - 0.1
			engel = yuz
		"teras":
			engel = y0 + d.y + 1.18
		"mazgal":
			yuz = y0 + d.y + 0.2
			engel = y0 + d.y + 1.2
	var yaw := float(h["yaw"])
	var lz := Vector2(sin(yaw), cos(yaw))
	var c: Vector2 = h["c"]
	return {"yuz": yuz, "engel": engel, "sirt": c + lz * float(p["over"]) * 0.5, "L": d.x, "cati": cati}

var _plan_cache := {}

func _cati_gecitleri() -> void:
	var gr := {}
	var n := 0
	var sigmadi := 0
	var mahya_n := 0
	var mahyali := {}
	var hs: Array = sk.houses
	var parca_ekle := func(m: Vector2, y_alt: float, y_ust: float, boy_u: float, en: float, bas: Basis, renk: Color) -> void:
		var boy := Vector3(boy_u, y_ust - y_alt, en)
		var xf := Transform3D(bas, Vector3(m.x, (y_alt + y_ust) * 0.5, m.y))
		var ck := Vector2i(floori(m.x / DUVAR_HUCRE), floori(m.y / DUVAR_HUCRE))
		if not gr.has(ck):
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			gr[ck] = st
		if not _duvar_cells.has(ck):
			_duvar_cells[ck] = {"boxes": [], "body": null}
		_kutu(gr[ck], xf, boy, renk, Vector3((ck.x + 0.5) * DUVAR_HUCRE, 0, (ck.y + 0.5) * DUVAR_HUCRE))
		(_duvar_cells[ck]["boxes"] as Array).append([xf, boy])
	for i in hs.size() - 1:
		var A: Dictionary = hs[i]
		var B: Dictionary = hs[i + 1]
		if int(A["sira"]) != int(B["sira"]):
			continue
		var yaw := float(A["yaw"])
		var lx := Vector2(cos(yaw), -sin(yaw))
		var ca: Vector2 = A["c"]
		var cb: Vector2 = B["c"]
		var la := IstEvler.dims(int(A["v"])).x
		var lb := IstEvler.dims(int(B["v"])).x
		if absf(absf((cb - ca).dot(lx)) - (la + lb) * 0.5) > 0.25:
			continue                                    # bitişik değil (arada geçit/merdiven payı)
		var ua := _ev_ust(A)
		var ub := _ev_ust(B)
		var P := maxf(float(ua["engel"]), float(ub["engel"]))
		var sa := float(ua["yuz"])
		var sb := float(ub["yuz"])
		var ra: Vector2 = ua["sirt"]
		var rb: Vector2 = ub["sirt"]
		var u := (rb - ra).normalized()
		var ux := absf(u.dot(lx))
		if ux < 0.5:
			continue
		var Q := ra + u * (la * 0.5 / ux)
		var bas := Basis(Vector3.UP, atan2(u.x, u.y) + PI * 0.5)
		var parcalar: Array = []                        # [konum, alt y, üst y, boy (u yönünde)]
		var sigdi := true
		for yan: int in [-1, 1]:
			var s0 := sa if yan < 0 else sb
			var L := la if yan < 0 else lb
			var dy := P - s0
			if dy <= 0.2:
				continue
			var nb := ceili(dy / GECIT_RISE)
			var rise := dy / nb
			var yer := L / ux - 0.75                   # sınırdan evin öbür ucuna kalan boy (sahanlık ve pay düşülür)
			var tread := minf(0.55, yer / maxf(nb - 1, 1))
			if tread < 0.3:
				sigdi = false
				break
			for k in range(1, nb):
				# k = 1 sınıra en yakın (en yüksek) basamak; en üstü sahanlık
				var top := P - k * rise
				var mid := Q + u * float(yan) * (0.45 + (k - 0.5) * tread)
				parcalar.append([mid, top - 0.3, top, tread + 0.02])
		if not sigdi:
			sigmadi += 1
			continue
		parcalar.append([Q, P - 0.3, P, 0.9])
		for pc: Array in parcalar:
			parca_ekle.call(pc[0], float(pc[1]), float(pc[2]), float(pc[3]), GECIT_EN, bas, GECIT_RENK.darkened(0.08 * float(int((pc[0] as Vector2).x * 7.0) % 3)))
		# mahya: kiremit sırtının üstünde yürünür kalas (bıçak sırtta kapsül kayıyordu); evin boyunca, 0,5 m
		for e: Array in [[A, ua, la], [B, ub, lb]]:
			var h: Dictionary = e[0]
			var uu: Dictionary = e[1]
			var key: Vector2 = h["c"]
			if mahyali.has(key) or String(uu["cati"]) != "kiremit":
				continue
			mahyali[key] = true
			var by := float(uu["yuz"])
			parca_ekle.call(uu["sirt"], by - 0.08, by + 0.06, float(e[2]) + 0.1, 0.5, Basis(Vector3.UP, float(h["yaw"])), Color("5a3a2e"))
			mahya_n += 1
		n += 1
	for ck: Vector2i in gr:
		var mi := MeshInstance3D.new()
		mi.mesh = (gr[ck] as SurfaceTool).commit()
		mi.material_override = _duvar_mat()
		mi.position = Vector3((ck.x + 0.5) * DUVAR_HUCRE, 0, (ck.y + 0.5) * DUVAR_HUCRE)
		mi.visibility_range_end = DUVAR_UZAK * 0.6
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		mi.set_meta("no_walk", true)
		add_child(mi)
	stats["cati_gecit"] = n
	stats["mahya"] = mahya_n
	stats["cati_gecit_sigmadi"] = sigmadi


static var _dmat: StandardMaterial3D

func _duvar_mat() -> StandardMaterial3D:
	if _dmat == null:
		var m := StandardMaterial3D.new()
		m.vertex_color_use_as_albedo = true
		m.vertex_color_is_srgb = true
		m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		var tex := Props._pattern_tex("rubble")
		m.albedo_texture = tex
		var a := World1453._avg(tex)
		m.albedo_color = Color(minf(1.0 / maxf(a.r, 0.3), 1.6), minf(1.0 / maxf(a.g, 0.3), 1.6), minf(1.0 / maxf(a.b, 0.3), 1.6))
		m.uv1_triplanar = true
		m.uv1_world_triplanar = true
		m.uv1_scale = Vector3(0.5, 0.5, 0.5)
		_dmat = m
	return _dmat


static func _kutu(st: SurfaceTool, xf: Transform3D, sz: Vector3, col: Color, cen: Vector3) -> void:
	var h := sz * 0.5
	var c := [Vector3(-h.x, -h.y, -h.z), Vector3(h.x, -h.y, -h.z), Vector3(h.x, -h.y, h.z), Vector3(-h.x, -h.y, h.z),
		Vector3(-h.x, h.y, -h.z), Vector3(h.x, h.y, -h.z), Vector3(h.x, h.y, h.z), Vector3(-h.x, h.y, h.z)]
	var lx := Transform3D(xf.basis, xf.origin - cen)
	st.set_color(col)
	for f: Array in [[0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7], [4, 5, 6, 7]]:
		var a: Vector3 = lx * c[f[0]]
		var b: Vector3 = lx * c[f[1]]
		var cc: Vector3 = lx * c[f[2]]
		var d: Vector3 = lx * c[f[3]]
		st.set_normal((b - a).cross(d - a).normalized() * -1.0)
		for vv: Vector3 in [a, cc, b, a, d, cc]:
			st.add_vertex(vv)


# ================================================================ 3. öğeler (akışla)

func _oge_ekle(o: Dictionary) -> void:
	if _kayit is Array:
		(_kayit as Array).append(o)
	var c: Vector2 = o["c"]
	var ck := Vector2i(floori(c.x / OGE_HUCRE), floori(c.y / OGE_HUCRE))
	if not _cells.has(ck):
		_cells[ck] = {"oge": [], "durum": 0, "node": null, "body": null}
	_cells[ck]["oge"].append(o)


func _oge_hucreleri() -> void:
	for o: Dictionary in sk.oge:
		_oge_ekle(o)
	stats["oge"] = sk.oge.size()
	stats["oge_hucre"] = _cells.size()
	_oge_uzak()
	# başlangıç: kameranın çevresi hemen
	var cp := _cam()
	_planla(cp)
	var t0 := Time.get_ticks_msec()
	while not _is_kuyrugu.is_empty() and Time.get_ticks_msec() - t0 < 8000:
		_is_yap(_is_kuyrugu.pop_front())


## Öğelerin uzak görünüşü (380 m'den sonra): 384 m hücre başına tek ağ, öğe başına birkaç kütle (köşe renkli)
func _oge_uzak() -> void:
	var gr := {}
	for o: Dictionary in sk.oge:
		var c: Vector2 = o["c"]
		var ck := Vector2i(floori(c.x / ZEMIN_HUCRE), floori(c.y / ZEMIN_HUCRE))
		if not gr.has(ck):
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			gr[ck] = st
		var cen := Vector3((ck.x + 0.5) * ZEMIN_HUCRE, 0, (ck.y + 0.5) * ZEMIN_HUCRE)
		var y := IstGeo.h(c.x, c.y)
		var bas := Basis(Vector3.UP, float(o.get("yaw", 0.0)))
		var st: SurfaceTool = gr[ck]
		var tur := String(o["tur"])
		var p := Vector3(c.x, y, c.y)
		match tur:
			"yama_duvar":
				var al: Vector2 = o["alan"]
				for e: Array in [[Vector3(0, 0, -al.y * 0.5 - 0.6), Vector3(al.x, 0.9, 0.5)], [Vector3(-al.x * 0.5 - 0.6, 0, 0), Vector3(0.5, 0.9, al.y)], [Vector3(al.x * 0.5 + 0.6, 0, 0), Vector3(0.5, 0.9, al.y)]]:
					var q: Vector3 = p + bas * (e[0] as Vector3)
					var sz: Vector3 = e[1]
					_kutu(st, Transform3D(bas, Vector3(q.x, IstGeo.h(q.x, q.z) + sz.y * 0.5, q.z)), sz, Color("7a7262"), cen)
			"agil", "ciftlik":
				for i in 6:
					var a := i * TAU / 6.0
					_kutu(st, Transform3D(Basis(Vector3.UP, -a), p + Vector3(cos(a) * 4.5, 0.6, sin(a) * 4.5)), Vector3(0.2, 1.2, 4.5), Color("6a5440"), cen)
				_kutu(st, Transform3D(bas, p + Vector3(0, 0.45, 0)), Vector3(3.0, 0.9, 2.0), Color("c8c0b0"), cen)
				if tur == "ciftlik":
					_kutu(st, Transform3D(bas, p + bas * Vector3(-9.0, 1.7, -2.0)), Vector3(7.0, 3.4, 6.0), IstEvler.P_KERPIC[0], cen)
			"manastir", "sapel_kucuk", "mezarlik":
				var sz := Vector3(14, 8, 20) if tur == "manastir" else (Vector3(5, 5, 9) if tur == "sapel_kucuk" else Vector3(14, 0.8, 14))
				_kutu(st, Transform3D(bas, p + Vector3(0, sz.y * 0.5, 0)), sz, IstEvler.P_TAS[0] if tur != "mezarlik" else Color("8a8678"), cen)
			"agac_kumesi":
				for i in 3:
					_kutu(st, Transform3D(bas, p + bas * Vector3((i - 1) * 3.0, 2.5, (i % 2) * 2.0)), Vector3(3.0, 3.6, 3.0), Color("4e6a34"), cen)
			_:
				# ayrıntı köşesi / kuyu: tezgâh, çuval, kuyu bileziği boyunda birkaç kütle
				var n := 1 if tur in ["kuyu", "asma_cardagi", "kumes", "camasir_ipi", "odun_yigini"] else 4
				for i in n:
					var q := p + bas * Vector3((i - 1.5) * 2.2 if n > 1 else 0.0, 0.0, (i % 2) * 1.6)
					_kutu(st, Transform3D(bas, Vector3(q.x, IstGeo.h(q.x, q.z) + 0.5, q.z)), Vector3(1.6, 1.0, 1.2), Color("8a7458") if i % 2 == 0 else Color("a8553a"), cen)
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.roughness = 1.0
	for ck: Vector2i in gr:
		var mi := MeshInstance3D.new()
		mi.mesh = (gr[ck] as SurfaceTool).commit()
		mi.material_override = mat
		mi.position = Vector3((ck.x + 0.5) * ZEMIN_HUCRE, 0, (ck.y + 0.5) * ZEMIN_HUCRE)
		mi.visibility_range_begin = OGE_ORTA - 40.0
		mi.visibility_range_end = ZEMIN_UZAK
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)
		mi.name = "OgeUzak_%d_%d" % [ck.x, ck.y]
		add_child(mi)


func _cam() -> Vector3:
	var vp := get_viewport()
	if vp and vp.get_camera_3d():
		return to_local(vp.get_camera_3d().global_position)
	return Vector3.ZERO


func _planla(cp: Vector3) -> void:
	_is_kuyrugu.clear()
	var p := Vector2(cp.x, cp.z)
	var hedefler: Array = []
	for ck: Vector2i in _cells:
		var c := Vector2((ck.x + 0.5) * OGE_HUCRE, (ck.y + 0.5) * OGE_HUCRE)
		var d := c.distance_to(p) - OGE_HUCRE * 0.7
		var hedef := 2 if d < OGE_YAKIN else (1 if d < OGE_ORTA else 0)
		if int(_cells[ck]["durum"]) != hedef:
			hedefler.append([d, ck, hedef])
	hedefler.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for hd: Array in hedefler:
		_is_kuyrugu.append([hd[1], hd[2]])
	# avlu duvarlarının (ve çatı geçitlerinin) çarpışması: kameranın ve oyuncunun çevresinde
	var pl := get_tree().get_first_node_in_group("player") as Node3D if is_inside_tree() else null
	var pll := to_local(pl.global_position) if pl != null else Vector3(p.x, 0, p.y)
	var p2 := Vector2(pll.x, pll.z)
	for ck: Vector2i in _duvar_cells:
		var c := Vector2((ck.x + 0.5) * DUVAR_HUCRE, (ck.y + 0.5) * DUVAR_HUCRE)
		var yakin := minf(c.distance_to(p), c.distance_to(p2)) < CARP_YAKIN + DUVAR_HUCRE * 0.71
		var dc: Dictionary = _duvar_cells[ck]
		if yakin and dc["body"] == null:
			var body := StaticBody3D.new()
			body.name = "AvluDuvar"
			for bx: Array in dc["boxes"]:
				var cs := CollisionShape3D.new()
				var bs := BoxShape3D.new()
				bs.size = bx[1]
				cs.shape = bs
				cs.transform = bx[0]
				body.add_child(cs)
			add_child(body)
			dc["body"] = body
		elif not yakin and dc["body"] != null:
			(dc["body"] as Node).queue_free()
			dc["body"] = null


## DOKU-4: kare başına iş süresi (uçuş takılması payı); çıkışta ISTPROF satırı
var _prof := {"n": 0, "ust16": 0, "ust33": 0, "en_ms": 0.0}

func _exit_tree() -> void:
	print("ISTPROF mahalle_doku ", _prof)


func _process(dt: float) -> void:
	var tp := Time.get_ticks_usec()
	_process_ic(dt)
	var ms := (Time.get_ticks_usec() - tp) / 1000.0
	_prof["n"] += 1
	if ms > 16.0:
		_prof["ust16"] += 1
	if ms > 33.0:
		_prof["ust33"] += 1
	_prof["en_ms"] = maxf(_prof["en_ms"], snappedf(ms, 0.1))


func _process_ic(dt: float) -> void:
	_son_kontrol -= dt
	if _son_kontrol <= 0.0:
		_son_kontrol = 0.4
		_planla(_cam())
	var butce := maxi(IstDunya.butce_us, 4000)
	if _zemin_is >= 0 or not _zemin_bekleyen.is_empty():
		_zemin_akis(butce)
	var t0 := Time.get_ticks_usec()
	var n := 0
	while not _is_kuyrugu.is_empty() and (n == 0 or Time.get_ticks_usec() - t0 < butce):
		_is_yap(_is_kuyrugu.pop_front())
		n += 1
	if sokak_esya != null:
		sokak_esya.akis(_cam(), maxi(1500, butce - int(Time.get_ticks_usec() - t0)))


func _is_yap(job: Array) -> void:
	var ck: Vector2i = job[0]
	var hedef: int = job[1]
	var cd: Dictionary = _cells[ck]
	if int(cd["durum"]) == hedef:
		return
	if cd["node"] != null:
		(cd["node"] as Node).queue_free()
		cd["node"] = null
	if cd["body"] != null:
		(cd["body"] as Node).queue_free()
		cd["body"] = null
	cd["durum"] = hedef
	if hedef == 0:
		return
	var lod := 0 if hedef == 2 else 1
	var tmp := Node3D.new()
	for o: Dictionary in cd["oge"]:
		var c: Vector2 = o["c"]
		var host := Node3D.new()
		host.position = Vector3(c.x, IstGeo.h(c.x, c.y) - 0.03, c.y)
		host.rotation.y = float(o.get("yaw", 0.0))
		tmp.add_child(host)
		_oge_kur(host, o, lod)
	# görüntü tek ağa pişirilir; çarpışma gövdeleri ayrı bir düğüme taşınır (yakın)
	var list: Array = []
	for m in tmp.find_children("*", "MeshInstance3D", true, false):
		list.append(m)
	var holder := Node3D.new()
	holder.name = "Oge_%d_%d" % [ck.x, ck.y]
	add_child(holder)
	if not list.is_empty():
		var mi := World1453.bake(list, tmp, Transform3D.IDENTITY, holder, "Ag", 0.03, 0, lod >= 1)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if lod == 0 else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)
	# MultiMesh (ot, sürü) olduğu gibi taşınır
	for mm in tmp.find_children("*", "MultiMeshInstance3D", true, false):
		var gx := (mm as Node3D).global_transform if (mm as Node3D).is_inside_tree() else _yerel(mm as Node3D, tmp)
		mm.get_parent().remove_child(mm)
		holder.add_child(mm)
		(mm as Node3D).transform = gx
	if lod == 0:
		var body := StaticBody3D.new()
		body.name = "OgeCarpisma"
		for sb in tmp.find_children("*", "StaticBody3D", true, false):
			var bx := _yerel(sb as Node3D, tmp)
			for cs in sb.get_children():
				if cs is CollisionShape3D:
					var ncs := CollisionShape3D.new()
					ncs.shape = (cs as CollisionShape3D).shape
					ncs.transform = bx * (cs as CollisionShape3D).transform
					body.add_child(ncs)
		add_child(body)
		cd["body"] = body
	tmp.free()
	cd["node"] = holder


static func _yerel(n: Node3D, top: Node) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var cur: Node = n
	while cur != null and cur != top:
		if cur is Node3D:
			xf = (cur as Node3D).transform * xf
		cur = cur.get_parent()
	return xf


## Tek öğe (yerel: taban ortası, zemin 0)
func _oge_kur(host: Node3D, o: Dictionary, lod: int) -> void:
	var tur := String(o["tur"])
	var tohum := int(o.get("tohum", 0))
	match tur:
		"yama_duvar":
			_yama_duvar(host, o, lod)
		"agil":
			_agil(host, tohum, lod)
		"ciftlik":
			IstEvler.ev(host, 7.0, 6.0, 3.4, tohum, lod, "teras" if tohum % 2 == 0 else "kulube")
			var n2 := Node3D.new()
			n2.position = Vector3(9.0, 0, 2.0)
			host.add_child(n2)
			_agil(n2, tohum + 1, lod)
		"kulube_bag":
			IstEvler.ev(host, 4.0, 4.0, IstEvler.KULUBE_H, tohum, lod, "kulube")
		"mezarlik":
			IstKiliseler.build("mezarlik", host, 0.5, lod)
		"manastir":
			IstKiliseler.build("manastir", host, 0.6, lod)
		"sapel_kucuk":
			IstKiliseler.build("sapel", host, 0.75, lod)
		"agac_kumesi":
			for i in 3 + tohum % 4:
				var t := Node3D.new()
				t.position = Vector3(sin(i * 2.4 + tohum) * (2.0 + i * 1.3), 0, cos(i * 2.4 + tohum) * (2.0 + i * 1.3))
				host.add_child(t)
				var mi := MeshInstance3D.new()
				mi.mesh = IstBitki.tree_mesh(String(AVLU_AGAC[(tohum + i) % AVLU_AGAC.size()]), lod)
				t.add_child(mi)
		"mumcu":
			Ayrinti.build("tezgah", host, 1.0, lod)
			var m2 := Node3D.new()
			m2.position = Vector3(1.6, 0, 0.4)
			host.add_child(m2)
			Ayrinti.build("mum_sehpasi", m2, 1.0, lod)
			var m3 := Node3D.new()
			m3.position = Vector3(-1.6, 0, 0.2)
			host.add_child(m3)
			Ayrinti.build("tente", m3, 1.0, lod)
		_:
			if tur.begins_with("set_") or Ayrinti._find(tur).size() > 0:
				Ayrinti.build(tur, host, 1.0, lod)


## Ağıl: çit halkası (kapı ağzıyla), içinde 5–9 koyun/keçi, saman yığını, yalak
func _agil(host: Node3D, tohum: int, lod: int) -> void:
	var r := 4.5
	var n := 6
	for i in n:
		if i == 0:
			continue                      # kapı ağzı
		var a := (i + 0.5) * TAU / n
		var seg := Node3D.new()
		seg.position = Vector3(cos(a) * r, 0, sin(a) * r)
		seg.rotation.y = -a + PI * 0.5
		host.add_child(seg)
		IstBitkiYama.build_cit(seg, 0.5, lod, 2.0 * r * sin(PI / n))
	for i in 5 + tohum % 5:
		var hv := Node3D.new()
		var a := tohum * 0.7 + i * 1.9
		hv.position = Vector3(cos(a) * (1.0 + (i % 3)), 0, sin(a) * (1.0 + (i % 3)))
		hv.rotation.y = a * 2.0
		host.add_child(hv)
		Ayrinti.build("koyun" if (i + tohum) % 3 != 0 else "keci", hv, 1.0, lod)
	var s := Node3D.new()
	s.position = Vector3(-r - 2.0, 0, 0)
	host.add_child(s)
	Ayrinti.build("saman_yigini", s, 1.0, lod)


## Yamanın kenarı: arkada ve yanlarda bahçe duvarı ya da çit (sokak yanı açık: patika), kapı ağzı
func _yama_duvar(host: Node3D, o: Dictionary, lod: int) -> void:
	var al: Vector2 = o["alan"]
	var tohum := int(o["tohum"])
	var cit := String(o.get("yama", "")) in ["bag", "bugday", "cayir"] or tohum % 3 == 0
	# host merkezde; yama yerel x (en) / z (boy). Üç kenar: −z (arka), −x, +x; +z açık
	var kenarlar := [[Vector3(0, 0, -al.y * 0.5 - 0.6), 0.0, al.x], [Vector3(-al.x * 0.5 - 0.6, 0, 0), PI * 0.5, al.y], [Vector3(al.x * 0.5 + 0.6, 0, 0), PI * 0.5, al.y]]
	for e: Array in kenarlar:
		var L := float(e[2])
		var parca := 2 if L > 14.0 else 1
		for k in parca:
			var boy := L / parca - (2.0 if parca == 2 else 0.0)
			var n := Node3D.new()
			var off := (k - (parca - 1) * 0.5) * (L / parca)
			var dir := Vector3(cos(float(e[1])), 0, -sin(float(e[1])))
			n.position = (e[0] as Vector3) + dir * off
			n.rotation.y = float(e[1])
			host.add_child(n)
			if cit:
				IstBitkiYama.build_cit(n, 0.5, lod, boy)
			else:
				IstBitkiYama.build_bahce_duvari(n, 0.5, lod, boy)
