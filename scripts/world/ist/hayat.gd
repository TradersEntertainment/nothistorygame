class_name IstHayat
extends Node3D
## İstanbul v2 yaşam katmanı: insanlar, hayvanlar, kuşlar, duman, sancak/çamaşır, ateşler, gece ışıkları.
## Şehre bağlama (ORTAK DOSYA ÖNERİSİ: IstDunya.build / IstSehir.attach_v2 sonunda): IstHayat.attach(dunya, gece)
##
## Mimari: IstHayatVeri bütün kayıtları BİR KEZ üretir (sokak ağı, mahalle türü, yerler); IstHayatKatman kayıtları 48 m'lik hücrelerde
## tutar ve izleyiciye göre (≈ 25 m kayınca) yakından uzağa MultiMesh arabelleğine doldurur: 170 m çevresi ayrıntılı insan (≈ 70 üçgen),
## 170–720 m nokta-figür (≈ 20 üçgen). Hareket (yürüyüş, kol-bacak, sancak, duman, kuş dönüşü) tamamen gölgelendiricide.

const SH := "res://assets/shaders/"
const UZAK_ISIK := preload("res://scripts/world/ist/hayat_uzak_isik.gd")
const YAKIN := 170.0
const UZAK := 720.0
const KAYMA := 25.0

var dunya: Node3D
var gece := false
var veri: IstHayatVeri
var K: Dictionary = {}
var izle: Node3D = null            # yoksa etkin kamera
var _son := Vector3(1e9, 0, 1e9)
var _kuyruk: Array = []
var _day_t := 0.0
var _mats := {}
var kur_ms := 0.0
## Oyuncunun çevresindeki gerçek kişi katmanı (IstHayatYakin): IstHayat.attach zincirinden kurulur (şehre ek çağrı gerekmez).
## Kapalıysa (yakin_acik = false) küp figürler yakında da görünür (eski davranış).
static var yakin_acik := true
const YAKIN_BOS := {0: 88.0, 1: 66.0, 2: 40.0}     # mod → figürün kaybolduğu kamera uzaklığı (insan, dört ayaklı, tavuk)
var yakin: IstHayatYakin = null
var _yakin_olacak := false


static func attach(dunya_: Node3D, gece_ := false) -> IstHayat:
	var h := IstHayat.new()
	h.name = "IstHayat"
	h.dunya = dunya_
	h.gece = gece_
	dunya_.add_child(h)
	h._kur()
	return h


func _sh(ad: String, mode := 0) -> ShaderMaterial:
	var key := "%s|%d" % [ad, mode]
	if _mats.has(key):
		return _mats[key]
	var m := ShaderMaterial.new()
	m.shader = load(SH + ad + ".gdshader")
	if ad == "ist_insan":
		m.set_shader_parameter("mode", mode)
	m.set_shader_parameter("gece", 1.0 if gece else 0.0)
	if ad == "ist_insan" and _yakin_olacak:
		m.set_shader_parameter("yakin_bos", float(YAKIN_BOS.get(mode, 0.0)))
	_mats[key] = m
	return m


func _std(unshaded := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.roughness = 1.0
	m.cull_mode = BaseMaterial3D.CULL_DISABLED if unshaded else BaseMaterial3D.CULL_BACK
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func _kur() -> void:
	var t0 := Time.get_ticks_msec()
	_yakin_olacak = yakin_acik and not OS.has_environment("NO_CITYLIFE") and not GameState.exitcheck \
			and not dunya.has_node("CityLife") and IstSehir.sokak != null
	veri = IstHayatVeri.new()
	veri.uret(IstSehir.sokak, gece)
	K = veri.K
	var mi := _sh("ist_insan", 0)
	(K["insan"] as IstHayatKatman).gorunum(IstHayatMesh.insan(), mi, 0.0, YAKIN, 1100)
	(K["insan"] as IstHayatKatman).gorunum(IstHayatMesh.insan_uzak(), mi, YAKIN, UZAK, 3200)
	(K["hayvan"] as IstHayatKatman).gorunum(IstHayatMesh.hayvan(false), _sh("ist_insan", 1), 0.0, 520.0, 500)
	(K["yuklu"] as IstHayatKatman).gorunum(IstHayatMesh.hayvan(true), _sh("ist_insan", 1), 0.0, 520.0, 300)
	(K["tavuk"] as IstHayatKatman).gorunum(IstHayatMesh.tavuk(), _sh("ist_insan", 2), 0.0, 170.0, 200)
	(K["marti"] as IstHayatKatman).gorunum(IstHayatMesh.kus(false), _sh("ist_kus"), 0.0, 1500.0, 400)
	(K["guvercin"] as IstHayatKatman).gorunum(IstHayatMesh.kus(true), _sh("ist_kus"), 0.0, 900.0, 220)
	(K["duman"] as IstHayatKatman).gorunum(IstHayatMesh.puf(), _sh("ist_duman"), 0.0, 800.0, 3200)
	(K["bez"] as IstHayatKatman).gorunum(IstHayatMesh.bez(), _sh("ist_bez"), 0.0, 900.0, 900)
	(K["kutu"] as IstHayatKatman).gorunum(IstHayatMesh.kutu(), _std(false), 0.0, 420.0, 3500)
	(K["cadir"] as IstHayatKatman).gorunum(IstHayatMesh.cadir(), _std(false), 0.0, 1800.0, 1200)
	if gece:
		var qm := QuadMesh.new()
		qm.size = Vector2(0.5, 0.8)
		(K["pencere"] as IstHayatKatman).gorunum(qm, _std(true), 0.0, 450.0, 5000)
	(K["alev"] as IstHayatKatman).gorunum(Flame.flame_mesh(), Flame.mat("flame", 1.5), 0.0, 800.0, 900)
	(K["parilti"] as IstHayatKatman).gorunum(Flame.glow_mesh(), Flame.mat("glow", 0.55, Color("ffd890"), Color("ff7a20")), 0.0, 1000.0, 1500)
	for k: String in K:
		var kt: IstHayatKatman = K[k]
		if kt.views.is_empty():
			continue
		kt.kur(self)
	if gece:
		print("ISTUZAKISIK ", UZAK_ISIK.kur(self, K, IstSehir.sokak))
	kur_ms = Time.get_ticks_msec() - t0
	print("ISTHAYAT kur_ms=%d %s" % [kur_ms, veri.ist])
	print("ISTEVONBELLEK ", IstEvler.ob_say)
	if _yakin_olacak and yakin == null:
		var t1 := Time.get_ticks_msec()
		yakin = IstHayatYakin.attach(dunya, null, gece)
		print("ISTHAYAT yakin_kur_ms=%d" % (Time.get_ticks_msec() - t1))
	yenile_hepsi()


func _bakan() -> Vector3:
	if izle != null and is_instance_valid(izle) and izle.is_inside_tree():
		return to_local(izle.global_position)
	var c := get_viewport().get_camera_3d() if is_inside_tree() else null
	if c != null:
		return to_local(c.global_position)
	return Vector3.ZERO


func yenile_hepsi() -> void:
	var p := _bakan()
	_son = p
	for k: String in K:
		(K[k] as IstHayatKatman).yenile(p)
	_kuyruk.clear()


func _process(dt: float) -> void:
	var p := _bakan()
	if Vector2(p.x - _son.x, p.z - _son.z).length() > KAYMA and _kuyruk.is_empty():
		_son = p
		_kuyruk = K.keys()
	if not _kuyruk.is_empty():
		# kare başına en çok iki katman (sıçrama önlenir)
		for i in 2:
			if _kuyruk.is_empty():
				break
			var k: String = _kuyruk.pop_back()
			(K[k] as IstHayatKatman).yenile(_son)
	_day_t += dt
	if _day_t > 0.6:
		_day_t = 0.0
		Flame.update_day(get_viewport())


## Denetim: çizilen örnek ve üçgen sayısı
func olcum() -> Dictionary:
	var d := 0
	var tris := 0
	var inst := 0
	for k: String in K:
		for v: Dictionary in (K[k] as IstHayatKatman).views:
			if v.get("mm") == null:
				continue
			var n: int = v["n"]
			if n > 0:
				d += 1
				inst += n
				var m: Mesh = v["mesh"]
				var t := 0
				if m is ArrayMesh:
					var ar := (m as ArrayMesh).surface_get_arrays(0)
					t = (ar[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3 if ar[Mesh.ARRAY_INDEX] != null else (ar[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
				else:
					t = 2
				tris += t * n
	return {"cizim": d, "ornek": inst, "ucgen": tris}
