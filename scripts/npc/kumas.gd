extends RefCounted
## GİYSİ KUMAŞI (oyun geneli; Person ve Soldier): uzun kaftan/cüppe etekleri, kadın etekleri, asker bel eteği, sırttaki
## pelerin, padişah/vezir kaftanının sarkan yenleri, sarık/börk yatırtmaları, püsküller yürürken ve rüzgârda sallanır.
##
## Yöntem: kumaş parçaları kurulurken işaretlenir (Kumas.silindir / Kumas.pano / Kumas.isaretle: kip, bağlandığı yükseklik,
## boy) ve CharKit.bake onları da eklemin tek ağına pişirir; kumaş köşelerine UV (h, kip) yazılır, ağ kumaş gölgelendiricisini
## alır (assets/shaders/giysi_kumas.gdshader*: köşe bükümü + dış hat). Bükümün girdileri ÖRNEK uniform'larıdır (ağ başına,
## malzeme paylaşılır): bu modül kişi başına kare başına yalnız birkaç sayı hesaplar:
##   - Yaylı sarkaç (etek ucunun salınımı, gövde uzayında 2B): gövdenin ivmesine eylemsizlikle karşı koyar (yürüyüşe başlayınca
##     geri savrulur, durunca öne salınıp oturur), göreli rüzgârın sürüklemesine (koşarken arkaya; durunca rüzgâraltına)
##     ve yürüyüşte kalçanın yana salınımına uyar. Burulma: dönüşte etek geride kalır; açılma: hızlı dönüşte ve koşuda.
##   - Bacaklar: kalça, diz, bilek (gövde uzayı): gölgelendirici eteği bacak kapsüllerinin kesitini saracak kadar açar
##     (bacağın içinden geçmez; adım atan diz eteği önden iter), pelerin kapsüllerin dışına itilir.
##   - Zemin: her ayağın altındaki zemin düzlemi (ayak IK'nın ışını; yoksa kökün düzlemi): etek ucu yere/basamağa oturur,
##     girmez. Oturan: oturak yüksekliği (dizlerin gerisindeki kumaş oturağın içine girmez). Yığılan (bez bebek): gövdenin
##     altındaki zemin, yerçekimi gövde uzayında (yatan kişinin eteği yere sarkar).
## Bütçe: kameraya ≤ LOD m ve görüş konisinde; ötesinde DONAR (uniform yazılmaz, son hâlinde kalır). LOD_YARI'dan uzakta
## iki karede bir. Değişmeyen değer yazılmaz (duran kişi oturunca yazım biter; dalga gölgelendiricide zamanla akar).
## Kalabalığın pişmiş kopyaları (Crowd) ve uniform'u hiç yazılmamış örnekler dinlenme duruşunda çizilir.
## Kapatma: --kumas=0 (ÖNCE ölçümü: parçalar eskisi gibi tek halkalı ve kumaşsız pişer).

const SHADER := preload("res://assets/shaders/giysi_kumas.gdshader")
const SHADER_HAT := preload("res://assets/shaders/giysi_kumas_hat.gdshader")
const Ayak_ := preload("res://scripts/npc/ayak.gd")

const LOD := 26.0
const LOD_YARI := 12.0
## Kip: 1 etek/kaftan (gövde ekseni çevresinde), 2 pelerin (sırtta pano), 3 sarkan uç
const ETEK := 1
const PELERIN := 2
const UC := 3
## Rüzgâr (dünya, m/sn): hafif, sahnede tek yön; şiddet yavaşça dalgalanır
static var ruzgar := Vector3(1.4, 0.0, 0.6)

static var etkin := true
static var _arg_ok := false
static var _mats := {}
## Kendi rastgele üreteci: oyunun küresel dizisini (randf) tüketmez (bölümlerin rastgele akışı değişmesin)
static var _rng := RandomNumberGenerator.new()
static var _meshes := {}
## Ölçüm (--kumas-olc; KUMASPERF): kare başına süre ve kişi sayısı
static var olc_acik := false
## Tanı (--kumas-dbg): salınım 0,15 m'yi aşınca bir satır (KUMASDBG)
static var dbg := false
static var olc_us := 0
static var olc_n := 0
static var _olc_frame := -1
static var _olc := {"kare": 0, "proc": 0.0, "us": 0, "n": 0, "t0": 0}


static func ayarla() -> void:
	if _arg_ok:
		return
	_arg_ok = true
	for a in OS.get_cmdline_user_args() + OS.get_cmdline_args():
		if a == "--kumas=0":
			etkin = false
		elif a == "--kumas-olc":
			olc_acik = true
		elif a == "--kumas-dbg":
			dbg = true


## Kumaş gölgelendiricili köşe renkli malzeme (CharKit.vc_mat'ın eşi); outline: dış hat (aynı bükümle)
static func malzeme(outline: bool) -> ShaderMaterial:
	var key := "%s|%s" % [outline, Props.outlines]
	if _mats.has(key):
		return _mats[key]
	var m := ShaderMaterial.new()
	m.shader = SHADER
	if outline and Props.outlines:
		var o := ShaderMaterial.new()
		o.shader = SHADER_HAT
		o.set_shader_parameter("renk", Props.OUTLINE_COLOR)
		o.set_shader_parameter("buyume", Props.OUTLINE_WIDTH * 0.7)
		m.next_pass = o
	_mats[key] = m
	return m


## Kumaş silindiri (Props.cyl'in eşi; aynı ölçü, aynı görünüş): boyuna halkalı (bükülebilsin). ust/boy: bağlandığı
## yükseklik ve boy (ebeveyn uzayında; verilmezse silindirin kendi üstü ve boyu). Eteğin ucundaki şerit gibi parçalar
## eteğin ust/boy'unu alır: etekle birlikte bükülür.
static func silindir(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color, segments := 14, top_radius := -1.0,
		kip := ETEK, ust := NAN, boy := NAN) -> MeshInstance3D:
	ayarla()
	if not etkin:
		return Props.cyl(parent, radius, height, pos, color, Vector3.ZERO, segments, top_radius)
	var rings := clampi(int(height / 0.07), 1, 10)
	var key := "c%.4f|%.4f|%.4f|%d|%d" % [radius, top_radius, height, segments, rings]
	var m: Mesh = _meshes.get(key)
	if m == null:
		var c := CylinderMesh.new()
		c.bottom_radius = radius
		c.top_radius = radius if top_radius < 0.0 else top_radius
		c.height = height
		c.radial_segments = segments
		c.rings = rings
		m = c
		_meshes[key] = m
	var mi := Props._place(parent, m, pos, color)
	isaretle(mi, kip, pos.y + height * 0.5 if is_nan(ust) else ust, height if is_nan(boy) else boy)
	return mi


## Kumaş panosu (Props.box'ın eşi): pelerin, yen, yatırtma. Boyuna ve enine bölünmüş.
static func pano(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rot_deg := Vector3.ZERO, kip := PELERIN,
		ust := NAN, boy := NAN) -> MeshInstance3D:
	ayarla()
	if not etkin:
		return Props.box(parent, size, pos, color, rot_deg)
	var sh := clampi(int(size.y / 0.07), 1, 12)
	var sw := clampi(int(size.x / 0.12), 0, 5)
	var key := "b%s|%d|%d" % [size, sh, sw]
	var m: Mesh = _meshes.get(key)
	if m == null:
		var b := BoxMesh.new()
		b.size = size
		b.subdivide_height = sh
		b.subdivide_width = sw
		m = b
		_meshes[key] = m
	var mi := Props._place(parent, m, pos, color, rot_deg)
	isaretle(mi, kip, pos.y + size.y * 0.5 if is_nan(ust) else ust, size.y if is_nan(boy) else boy)
	return mi


## Var olan bir parçayı kumaşa kat (eteğin üstündeki süs, kürk şerit): ust/boy eteğinki (ebeveyn = eklem uzayında)
static func isaretle(mi: MeshInstance3D, kip: int, ust: float, boy: float) -> void:
	ayarla()
	if etkin and mi:
		mi.set_meta("kumas", Vector3(kip, ust, maxf(boy, 0.01)))


## CharKit.bake için: bu parçanın köşelerinin (eklem uzayında) UV'si; kumaş değilse boş
static func uv_of(mi: MeshInstance3D, verts_p: PackedVector3Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(verts_p.size())
	if not mi.has_meta("kumas"):
		return out
	var k: Vector3 = mi.get_meta("kumas")
	for i in verts_p.size():
		out[i] = Vector2(clampf((k.y - verts_p[i].y) / k.z, 0.0, 1.0), k.x)
	return out


# ---------------------------------------------------------------- kişi başı

var rig: Rig
var _ok := false
var _gov: Array[GeometryInstance3D] = []      # gövdenin pişmiş ağı (etek, pelerin)
var _ek: Array[GeometryInstance3D] = []       # baş/kol ağları (sarkan uçlar)
var _ankles: Array[Node3D] = [null, null]
var _hip := Vector4(-0.1, 0.66, 0.1, 0.66)
var _lr := 0.09
var _s := Vector2.ZERO        # etek ucunun salınımı (gövde uzayı, m)
var _sv := Vector2.ZERO
var _tw := 0.0                # burulma
var _twv := 0.0
var _fl := 0.0                # açılma
var _lp := Vector3.INF
var _lv := Vector3.ZERO
var _la := Vector3.ZERO
var _lyaw := INF
var _faz := 0.0
var _acc := 0.0
var _kare := 0
var _yakin := false
var _lod_t := 0.0
var _zy_t := 0.0
var _zy := NAN                # yığılanın gövdesinin altındaki zemin (dünya y)
var _son: Array = []          # son yazılan değerler (değişmeyen yazılmaz)
const PARAMS := ["kk_ek", "kk_sw", "kk_dg", "kk_hp", "kk_ul", "kk_al", "kk_ur", "kk_ar", "kk_zl", "kk_zr"]


func _init(r: Rig) -> void:
	rig = r
	_faz = _rng.randf() * 20.0
	var o := r.owner
	if o == null:
		return
	for mi in o.find_children("Baked", "MeshInstance3D", true, false):
		if mi.has_meta("kumas_baked"):
			if mi.get_parent() == r.body:
				_gov.append(mi)
			else:
				_ek.append(mi)
	if _gov.is_empty() and _ek.is_empty():
		return
	if r.leg_l and r.leg_r:
		_hip = Vector4(r.leg_l.position.x, r.leg_l.position.y, r.leg_r.position.x, r.leg_r.position.y)
	for s in 2:
		var kn: Node3D = r.knee_l if s == 0 else r.knee_r
		if kn:
			_ankles[s] = kn.get_node_or_null("Ankle") as Node3D
	_lr = 0.1 if o is Soldier else 0.088
	_son.resize(PARAMS.size())
	_ok = r.leg_l != null and r.leg_r != null and r.knee_l != null and r.knee_r != null


## Kişi bu karede (Rig.update'in sonunda; ayak IK'dan sonra). Kumaşı yoksa hiçbir şey yapmaz.
func uygula(delta: float) -> void:
	if not _ok or not etkin:
		return
	var o: Node3D = rig.owner
	if o == null or not o.is_inside_tree() or not o.is_visible_in_tree():
		_dinlen()
		return
	# LOD: uzaktaki ya da görüş dışındaki donar; LOD_YARI'dan uzakta iki karede bir
	_lod_t -= delta
	var gp := o.global_position
	if _lod_t <= 0.0:
		var cam := Ayak_.kamera(o)
		_yakin = false
		if cam:
			var d2 := gp.distance_squared_to(Ayak_._cam_pos)
			_yakin = d2 <= LOD * LOD and (d2 < 36.0 or Ayak_.gorunur(gp, d2))
			_lod_t = 0.0 if d2 < (LOD + 4.0) * (LOD + 4.0) else 0.4 + _rng.randf() * 0.2
			if d2 > LOD_YARI * LOD_YARI:
				_kare = 1
			else:
				_kare = 0
		else:
			_lod_t = 0.5
	if not _yakin:
		_dinlen()
		return
	_acc += delta
	if _kare == 1 and Engine.get_process_frames() % 2 == (get_instance_id() & 1):
		return
	var dt := _acc
	_acc = 0.0
	if dt <= 0.0:
		return
	var t0 := Time.get_ticks_usec()
	_coz(dt, gp)
	if olc_acik:
		olc_us += Time.get_ticks_usec() - t0
		olc_n += 1


func _coz(dt: float, gp: Vector3) -> void:
	var o: Node3D = rig.owner
	var body := rig.body
	var bxf := body.global_transform
	var B := bxf.basis.orthonormalized()
	var Binv := B.transposed()
	# Gövdenin hızı ve ivmesi (dünya); ışınlanma sıfırlar
	# Işınlanma (sahne betiği kişiyi bir karede taşıdı: 12 m/sn'den hızlı ya da 0,8 m'den uzun) hız/ivme sayılmaz
	var v_w := Vector3.ZERO
	var isin := _lp.x == INF
	if not isin:
		var d := gp - _lp
		isin = d.length() > 0.8 or d.length() / dt > 12.0
		if not isin:
			v_w = d / dt
	if isin:
		_lv = Vector3.ZERO
		_la = Vector3.ZERO
	var a_w := Vector3.ZERO if isin else (v_w - _lv) / dt
	_lp = gp
	_lv = _lv.lerp(v_w, clampf(dt * 15.0, 0.0, 1.0))
	_la = _la.lerp(a_w.limit_length(15.0), clampf(dt * 12.0, 0.0, 1.0))
	var a_l := Binv * _la
	# Göreli rüzgâr (rüzgâr − gövde hızı) kumaşı sürükler; şiddet yavaş dalgalanır
	var tt := Time.get_ticks_msec() * 0.001 + _faz
	var ruz := ruzgar * (0.75 + 0.35 * sin(tt * 0.55) + 0.15 * sin(tt * 1.7))
	var rel_l := Binv * (ruz - _lv)
	var g_l := Binv * Vector3.DOWN
	var hedef := Vector2(rel_l.x, rel_l.z) * 0.045
	hedef = hedef.limit_length(0.24)
	# Yatan/eğik gövde: etek yere doğru sarkar
	hedef += Vector2(g_l.x, g_l.z) * 0.32
	# Yürüyüşte kalça yana salınır: kumaş izler
	var spd := Vector2(_lv.x, _lv.z).length()
	if rig.yuruyor:
		# Kalça her adımda yana salınır, öne basan bacak eteği önden iter: etek ucu adımla sağa-sola ve öne-arkaya
		var gk := clampf(spd / 1.4, 0.0, 1.2)
		hedef.x += sin(rig._walk_phase) * 0.04 * gk
		hedef.y += cos(rig._walk_phase * 2.0) * 0.018 * gk
	# Yaylı sarkaç (etek ucu ~1,1 Hz, az sönümlü): ivmeye eylemsizlikle karşı koyar
	# Yarı örtük Euler, en çok 1/60 sn'lik alt adımlar (karede en çok 0,1 sn): yavaş karede (0,5 sn) açık Euler
	# kararsızlaşıp eteği sınıra savuruyordu
	var K := 48.0
	var C := 3.2
	var ia := Vector2(a_l.x, a_l.z) * 0.9
	var kalan := minf(dt, 0.1)
	while kalan > 0.0:
		var h := minf(kalan, 1.0 / 60.0)
		kalan -= h
		_sv += ((hedef - _s) * K - _sv * C - ia) * h
		_s += _sv * h
	if _s.length() > 0.34:
		_s = _s.limit_length(0.34)
		_sv *= 0.5
	if dbg and _s.length() > 0.15:
		print("KUMASDBG %s/%s s=%s hedef=%s a_l=%s v=%s dt=%.3f g=%s act=%s" % [o.get_class() if o.get_script() == null else (o.get_script() as Script).get_global_name(),
			o.name, _s, hedef, a_l, _lv, dt, g_l, rig.activity])
	# Dönüş: burulma (gecikme) ve açılma
	var yaw := o.global_rotation.y
	var w := 0.0
	if _lyaw != INF and not isin:
		var dy := wrapf(yaw - _lyaw, -PI, PI)
		# Bir karede 0,6 rad'dan çok dönüş sahne betiğinin bir anda çevirmesidir (yüzünü döndür): dönüş hızı sayılmaz
		if absf(dy) < 0.6:
			w = dy / dt
	_lyaw = yaw
	var kt := minf(dt, 0.1)
	while kt > 0.0:
		var h2 := minf(kt, 1.0 / 60.0)
		kt -= h2
		_twv += ((-w * 0.1 - _tw) * 30.0 - _twv * 3.5) * h2
		_tw = clampf(_tw + _twv * h2, -0.7, 0.7)
	_fl = lerpf(_fl, clampf(absf(w) * 0.035 + spd * 0.012, 0.0, 0.22), clampf(dt * 6.0, 0.0, 1.0))
	var amp := clampf(0.004 + rel_l.length() * 0.0035, 0.0, 0.02)
	if _gov.is_empty():
		# Yalnız sarkan uçlar (sarık yatırtması, yen): bacak ve zemin gerekmez
		_yaz(0, Vector4(0.45, 1.0, _lr, 0.0))
		_yaz(1, Vector4(_s.x, _s.y, _tw, _fl))
		_yaz(2, Vector4(rel_l.x, rel_l.z, amp, _faz))
		return
	# Bacaklar (gövde uzayı)
	var ll: Node3D = rig.leg_l
	var lr: Node3D = rig.leg_r
	var kl := ll.transform * rig.knee_l.position
	var kr := lr.transform * rig.knee_r.position
	var al := ll.transform * (rig.knee_l.transform * (_ankles[0].position if _ankles[0] else Vector3(0, -0.255, 0)))
	var ar := lr.transform * (rig.knee_r.transform * (_ankles[1].position if _ankles[1] else Vector3(0, -0.255, 0)))
	# Zemin düzlemleri (gövde uzayı)
	var binv := bxf.affine_inverse()
	var zl := Vector4(0, 1, 0, 10)
	var zr := Vector4(0, 1, 0, 10)
	var bolge := 0.45
	var otur := 0.0
	var yatik := B.y.dot(Vector3.UP) < 0.8 or o.has_meta("yigilma")
	if yatik:
		# Yığılan/yatan: gövdenin altındaki görünen zemin (yarım saniyede bir ışın)
		_zy_t -= dt
		if _zy_t <= 0.0:
			_zy_t = 0.5
			_zy = Unclip.floor_y(o, bxf.origin + Vector3(0, 0.3, 0), 1.2, 2.0)
		if not is_nan(_zy):
			zl = _duzlem(binv, Vector3(bxf.origin.x, _zy, bxf.origin.z), Vector3.UP)
			zr = zl
			bolge = 5.0
	else:
		var ay = rig.ayak
		var par := o.get_parent() as Node3D
		var par_t := par.global_transform if par else Transform3D.IDENTITY
		var up := par_t.basis.y.normalized()
		for s in 2:
			var z := _duzlem(binv, gp, up)
			if ay and ay.w > 0.5 and ay._g_ok[s]:
				var gpp: Vector3 = ay._g_p[s]
				z = _duzlem(binv, par_t * Vector3(gpp.x, ay._g_y[s], gpp.z), (par_t.basis * (ay._g_n[s] as Vector3)).normalized())
			if s == 0:
				zl = z
			else:
				zr = z
		if rig.activity in Rig.SEATED and rig.activity != "sit_astride":
			otur = 0.55
	_yaz(0, Vector4(bolge, 1.0, _lr, otur))
	_yaz(1, Vector4(_s.x, _s.y, _tw, _fl))
	_yaz(2, Vector4(rel_l.x, rel_l.z, amp, _faz))
	_yaz(3, _hip)
	_yaz(4, Vector4(kl.x, kl.y, kl.z, 0.0))
	_yaz(5, Vector4(al.x, al.y, al.z, 0.0))
	_yaz(6, Vector4(kr.x, kr.y, kr.z, 0.0))
	_yaz(7, Vector4(ar.x, ar.y, ar.z, 0.0))
	_yaz(8, zl)
	_yaz(9, zr)


## Kumaş donarken (uzakta, görüş dışında, gizli) dinlenme duruşuna döner: savrulmuş hâliyle donup kalmasın (görüşe
## yeniden girdiğinde ya da kamera kesmesinde savrulmuş görünüyordu). Uzakta/görüş dışında olduğundan geçiş görünmez.
func _dinlen() -> void:
	_lp = Vector3.INF
	if _s == Vector2.ZERO and _son.size() > 0 and not (_son[0] is Vector4 and (_son[0] as Vector4).y > 0.5):
		return
	_s = Vector2.ZERO
	_sv = Vector2.ZERO
	_tw = 0.0
	_twv = 0.0
	_fl = 0.0
	_lyaw = INF
	if _son.size() > 0 and _son[0] is Vector4:
		var e: Vector4 = _son[0]
		_yaz(0, Vector4(e.x, 0.0, e.z, e.w))


static func _duzlem(binv: Transform3D, p_w: Vector3, n_w: Vector3) -> Vector4:
	var p := binv * p_w
	var n := (binv.basis * n_w).normalized()
	return Vector4(n.x, n.y, n.z, -n.dot(p))


## Değişen değer yazılır (yarım milimetreden küçük oynamalar değil); gövde ağına hepsi, baş/kol ağlarına sallanma ve dalga
func _yaz(i: int, v: Vector4) -> void:
	var e = _son[i]
	if e is Vector4 and (e as Vector4).is_equal_approx(v):
		return
	if e is Vector4 and i != 2 and ((e as Vector4) - v).abs().dot(Vector4.ONE) < 0.0015:
		return
	if e is Vector4 and i == 2 and absf((e as Vector4).z - v.z) < 0.0008 and Vector2((e as Vector4).x - v.x, (e as Vector4).y - v.y).length() < 0.15:
		return
	_son[i] = v
	var nm: StringName = PARAMS[i]
	for mi in _gov:
		mi.set_instance_shader_parameter(nm, v)
	if i <= 2:
		for mi in _ek:
			mi.set_instance_shader_parameter(nm, v)


## Ölçüm satırı (KUMASPERF): on saniyede bir kare başı betik süresi, kumaş µs, kişi
static func olc_tick() -> void:
	var f := Engine.get_process_frames()
	if f == _olc_frame:
		return
	_olc_frame = f
	_olc["kare"] += 1
	_olc["proc"] += Performance.get_monitor(Performance.TIME_PROCESS)
	_olc["us"] += olc_us
	_olc["n"] += olc_n
	olc_us = 0
	olc_n = 0
	var now := Time.get_ticks_msec()
	if _olc["t0"] == 0:
		_olc["t0"] = now
	if now - int(_olc["t0"]) >= 10000:
		var k := maxf(1.0, float(_olc["kare"]))
		print("KUMASPERF kare=%d proc_ms=%.3f kumas_us=%.1f kumas_kisi=%.2f etkin=%s" % [_olc["kare"], float(_olc["proc"]) * 1000.0 / k,
			float(_olc["us"]) / k, float(_olc["n"]) / k, str(etkin)])
		_olc = {"kare": 0, "proc": 0.0, "us": 0, "n": 0, "t0": now}
