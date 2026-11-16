extends RefCounted
## AYAK YERLEŞTİRME (oyun geneli, Rig kullanan bütün insanlar: Person, Soldier, Hikmet, düellocu gövdeleri).
## Kişinin kökü tek bir yükseklikte durur; eğimde, basamakta, molozda iki ayak aynı yükseklikte kalıyordu (biri havada,
## öteki zeminin içinde; 37o barikat sırtı). Bu modül Rig'in kurduğu duruşun (FK) ÜSTÜNE biner:
##   1. Her ayağın altına seyrek ışın (Unclip.floor_y'nin ölçüsü: yalnız görünen/basılabilir zemin): yükseklik ve eğim.
##   2. Kalça (gövde kökü, Rig.body) iki ayaktan alçak olanının zeminine göre iner (ya da gömülüyse çıkar); gövde DİK
##      kalır: yalnız kaydırılır, döndürülmez.
##   3. Her bacak iki kemikli IK ile hedef bileğe uzanır (uyluk = diz düğümünün kalçaya uzaklığı, baldır = bileğin dize
##      uzaklığı: CharKit.leg'in kemik boyları); diz kendi bükülme düzleminde bükülür (FK'nin düzleminden en kısa dönüş).
##   4. Taban zemin eğimine döner (Rig.extremities bilek açısına ek: ank_ek; yanal eğim bileğin z'si).
##   Yürürken basan ayak zemine KİLİTLENİR (ebeveyn uzayında sabit nokta, kayma yok); salınan ayak bir sonraki basma
##   noktasına (gidiş hızından öngörülür) yay çizerek gider. Adım uzunluğu hızdan: kadans Rig._walk_phase'i sürer.
## Bütçe: yalnız kameraya LOD metreden yakın ve görünen kişilerde; ışın yalnız adımda (basarken ve salınım başında)
## ya da dururken ayak 6 cm'den çok kayınca / iki saniyede bir. Uzaktakiler Rig'in eski yolunda (kök Unclip.rest_settle
## ile zemine oturur).
## Kapsam dışı (IK kapalı): oturan, yatan/ölü, tırmanan, ata binen, taşınan, uçan/yüzen, DurusKit duruşları,
## iskeleti kilitli (Rig.lock: elle oynatılan) olanlar; LimbAnim'le oynatılan düellocu ise LimbAnim'in kendi
## duruşunun üstüne izdüşüm kipinde (ayaklar o duruşta yere basar).
## Ölçüm için --ayak-ik=0 (kullanıcı argümanı): modül ve yeni kadans kapalı (ÖNCE ölçümü; varsayılan açık).

const Unclip_ := preload("res://scripts/npc/unclip.gd")
const DurusKit_ := preload("res://scripts/npc/durus_kit.gd")

## Kamera uzaklığı sınırı (m): ötesinde IK kapalı
const LOD := 28.0
## Bu uzaklığın içinde görüş konisine bakılmaz (kameranın hemen yanındaki, kenarda kalan ayaklar)
const LOD_YAKIN := 6.0
## Ayak bileğinden taban (CharKit.leg: ayakkabı yuvarı bileğin 3 cm altında, yarıçapı 0,075 × 0,62)
const TABAN := 0.0765
## Taban ortası bileğin bu kadar önünde (ayakkabı yuvarı z +0,05): zemin buradan örneklenir
const TABAN_Z := 0.05
## Işın: zeminin kökten en çok bu kadar üstünde/altında aranır (basamak, moloz; masa/kiriş üstü değil)
const ISIN_UST := 0.5
const ISIN_ALT := 0.9
## Kalça en çok bu kadar iner/çıkar (kökün yanlış yüksekliği bundan büyükse VISAUDIT float/sunk'ın işi)
const PEL_ALT := -0.5
const PEL_UST := 0.4
## IK'nın kapalı olduğu işler (Rig.SEATED de)
const KAPSAM_DISI := ["ride", "swim", "fly", "hover", "fall", "dead", "lie", "sleep", "row", "leap", "climb_a", "climb_b",
	"sit", "sit_ground", "write", "whittle", "read_ground", "doze", "write_desk", "sit_astride"]

static var etkin := true
static var _arg_ok := false
static var _cam_frame := -1
static var _cam: Camera3D
## Ölçüm: bu karede IK'ya harcanan süre (µs) ve etkin kişi sayısı (AYAKPERF)
static var olc_us := 0
static var olc_n := 0
static var isin_n := 0


static func ayarla() -> void:
	if _arg_ok:
		return
	_arg_ok = true
	for a in OS.get_cmdline_user_args() + OS.get_cmdline_args():
		if a == "--ayak-ik=0":
			etkin = false
		elif a == "--ayak-olc":
			olc_acik = true


## Ölçüm (--ayak-olc): her karede bir kez (ilk Rig.update) önceki karenin betik süresi (Performance.TIME_PROCESS),
## IK süresi ve sayıları toplanır; on saniyede bir "AYAKPERF" satırı (ortalamalar, ms/µs)
static var olc_acik := false
static var _olc_frame := -1
static var _olc := {"kare": 0, "proc": 0.0, "us": 0, "n": 0, "isin": 0, "t0": 0}


static func olc_tick() -> void:
	var f := Engine.get_process_frames()
	if f == _olc_frame:
		return
	_olc_frame = f
	_olc["kare"] += 1
	_olc["proc"] += Performance.get_monitor(Performance.TIME_PROCESS)
	_olc["us"] += olc_us
	_olc["n"] += olc_n
	_olc["isin"] += isin_n
	olc_us = 0
	olc_n = 0
	isin_n = 0
	var now := Time.get_ticks_msec()
	if _olc["t0"] == 0:
		_olc["t0"] = now
	if now - int(_olc["t0"]) >= 10000:
		var k := maxf(1.0, float(_olc["kare"]))
		print("AYAKPERF kare=%d proc_ms=%.3f ik_us=%.1f ik_kisi=%.2f isin=%.3f etkin=%s" % [_olc["kare"], float(_olc["proc"]) * 1000.0 / k,
			float(_olc["us"]) / k, float(_olc["n"]) / k, float(_olc["isin"]) / k, str(etkin)])
		_olc = {"kare": 0, "proc": 0.0, "us": 0, "n": 0, "isin": 0, "t0": now}


static var _cam_pos := Vector3.ZERO
static var _cam_fwd := Vector3.FORWARD
static var _cam_cos := 0.5


static func kamera(ctx: Node) -> Camera3D:
	var f := Engine.get_process_frames()
	if f != _cam_frame:
		_cam_frame = f
		_cam = ctx.get_viewport().get_camera_3d() if ctx.is_inside_tree() else null
		if _cam:
			var ct := _cam.global_transform
			_cam_pos = ct.origin
			_cam_fwd = -ct.basis.z.normalized()
			# Görüş konisi: köşegen yarı açısı (en-boy oranıyla) + pay
			var vp := _cam.get_viewport().get_visible_rect().size
			var asp := vp.x / maxf(vp.y, 1.0)
			var tv := tan(deg_to_rad(_cam.fov) * 0.5)
			_cam_cos = cos(minf(atan(tv * sqrt(1.0 + asp * asp)) + 0.1, 1.5))
	return _cam


## Kişi (kök op) kameranın görüş konisinde mi; d2: uzaklığın karesi. Gövde ~1 m: koni kenarında pay.
static func gorunur(op: Vector3, d2: float) -> bool:
	var dv := op + Vector3(0, 0.9, 0) - _cam_pos
	var dl := sqrt(maxf(d2, 0.0001))
	return dv.dot(_cam_fwd) > _cam_cos * dl - 1.2


var rig: Rig
var w := 0.0         # IK ağırlığı (LOD girişte/çıkışta yumuşak)
var mod := 0         # bu karede: 0 kapalı, 1 izdüşüm (FK duruşu + zemin), 2 yürüyüş (basan ayak kilitli)
var basiyor := [false, false]     # denetim: bu ayak şu an yere basmalı mı
var ank_ek := PackedFloat64Array([0.0, 0.0])    # bilek ek eğimi (rad; Rig.extremities okur)
var pel := 0.0       # kalçanın (gövdenin) FK'ye göre inişi/çıkışı (m)
## Düğümler ve kemik boyları (bir kez): uyluk L1 = dizin kalçaya, baldır L2 = bileğin dize uzaklığı
var _ok := false
var _legs: Array[Node3D] = []
var _knees: Array[Node3D] = []
var _anks: Array[Node3D] = []
var _apos := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])
var _L1 := 0.33
var _L2 := 0.255
var _R := 0.576
var _par: Node3D
var _yakin := false
var _kon := false      # bir önceki ölçümde görüş konisindeydi
var _lod_t := 0.0
var _scope_t := 0.0
var _scope_ok := true
## Geri alma: Rig ve LimbAnim kendi değerlerini bir önceki karenin üstüne (lerp) kurar; IK'nın yazdığı her değer bir
## sonraki karenin başında FK değerine döndürülür (başkası bu arada yazdıysa onunki kalır)
var _has_w := false
var _fk_leg := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])
var _w_leg: Array[Basis] = [Basis.IDENTITY, Basis.IDENTITY]
var _fk_knee := PackedFloat64Array([0.0, 0.0])
var _w_knee := PackedFloat64Array([0.0, 0.0])
var _fk_by := 0.0
var _w_by := 0.0
var _w_az := PackedFloat64Array([0.0, 0.0])
var _az_on := false
## Zemin önbelleği (ayak başına; ebeveyn uzayı): ışının indiği nokta, yükseklik, normal, yaş
var _g_p := PackedVector3Array([Vector3.INF, Vector3.INF])
var _g_y := PackedFloat64Array([0.0, 0.0])
var _g_n := PackedVector3Array([Vector3.UP, Vector3.UP])
var _g_t := PackedFloat64Array([0.0, 0.0])
var _g_ok := [false, false]
## Yürüyüş: basma noktası (ebeveyn uzayında taban), kalkış noktası (ve kalçaya göre yeri), iniş noktası
var _planted := [false, false]
var _plant := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])
var _plant_n := PackedVector3Array([Vector3.UP, Vector3.UP])
var _lift := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])
var _lift_n := PackedVector3Array([Vector3.UP, Vector3.UP])
var _lift_rel := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])
var _lift_ok := [false, false]
var _land := PackedVector3Array([Vector3.INF, Vector3.INF])
var _land_n := PackedVector3Array([Vector3.UP, Vector3.UP])
var _land_ray := PackedVector3Array([Vector3.INF, Vector3.INF])
var _vel := Vector3.ZERO
var _lp := Vector3.INF
var _last_mod := 0
var _mod_t := 0.0
var _cur := PackedVector3Array([Vector3.INF, Vector3.INF])    # son taban hedefi (ebeveyn uzayı): kip geçişi
var _cur_n := PackedVector3Array([Vector3.UP, Vector3.UP])
## Kare başı ara değerler (yeniden kullanılır: her karede dizi kurulmasın)
var _hip := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])
var _fks := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])
var _tgt := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])
var _tn := PackedVector3Array([Vector3.UP, Vector3.UP])
var _al := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])
var _grd := [true, true]


func _init(r: Rig) -> void:
	rig = r
	if r.leg_l == null or r.leg_r == null or r.knee_l == null or r.knee_r == null or r.body == null:
		return
	_legs = [r.leg_l, r.leg_r]
	_knees = [r.knee_l, r.knee_r]
	for s in 2:
		var a := _knees[s].get_node_or_null("Ankle") as Node3D
		_anks.append(a if a else _knees[s])
		_apos[s] = a.position if a else Vector3(0, -0.255, 0)
	_L1 = absf(_knees[0].position.y)
	_L2 = absf(_apos[0].y)
	_R = (_L1 + _L2) * 0.985
	_ok = _L1 > 0.05 and _L2 > 0.05


## Önceki karede yazılanları FK değerine döndür (Rig.update'in ve LimbAnim'in başında)
func geri_al() -> void:
	mod = 0
	if not _has_w:
		return
	_has_w = false
	var body := rig.body
	if is_equal_approx(body.position.y, _w_by):
		body.position.y = _fk_by
	for s in 2:
		var leg := _legs[s]
		if leg.basis.is_equal_approx(_w_leg[s]):
			leg.rotation = _fk_leg[s]
		var kn := _knees[s]
		if is_equal_approx(kn.rotation.x, _w_knee[s]):
			kn.rotation.x = _fk_knee[s]


## Kapsam: IK bu kişide çalışabilir mi (iş, işaret, taşıyıcı). Denetim de aynı ölçüyü kullanır.
static func kapsam_disi(r: Rig) -> String:
	var o: Node3D = r.owner
	if o == null or not o.is_inside_tree() or not o.is_visible_in_tree():
		return "gizli"
	var act: String = r.activity
	if act in KAPSAM_DISI or act.begins_with("sit") or act.begins_with("climb"):
		return "is:" + act
	if DurusKit_.var_mi(act) or not r._durus.is_empty():
		return "durus"
	for m in ["climber", "corpse", "no_ground", "hologram", "airborne", "cameo"]:
		if o.has_meta(m):
			return "meta:" + m
	if o.global_basis.y.normalized().dot(Vector3.UP) < 0.95:
		return "egik"
	var a: Variant = o.get("activity")
	if a is String and ((a as String).begins_with("sit") or a in KAPSAM_DISI):
		return "is:" + str(a)
	if o.get("pose") is String and not (str(o.get("pose")) in ["", "stand"]):
		return "poz:" + str(o.get("pose"))
	var q: Node = o.get_parent()
	var i := 0
	while q != null and i < 6:
		if q is Horse or q is Player or Unclip_._is_char(q):
			return "tasinan"
		q = q.get_parent()
		i += 1
	return ""


## Rig.update'in (ve LimbAnim'in) sonunda, Rig.extremities'ten önce. yuru: Rig bu karede yürüyüş salınımını kurdu.
## anim: LimbAnim çağırıyor (Rig.lock > 0 olsa da çalışır).
func uygula(delta: float, yuru: bool, anim := false) -> void:
	basiyor[0] = false
	basiyor[1] = false
	ank_ek[0] = 0.0
	ank_ek[1] = 0.0
	if not etkin or not _ok:
		return
	var o: Node3D = rig.owner
	if rig.lock > 0 and not anim:
		_kapat()
		return
	_scope_t -= delta
	if _scope_t <= 0.0:
		_scope_t = 0.4 + randf() * 0.2
		_scope_ok = kapsam_disi(rig) == ""
		_par = o.get_parent() as Node3D
	elif _scope_ok:
		# Ucuz anlık denetim: iş değiştiyse hemen kapanır (oturdu, ata bindi)
		var act: String = rig.activity
		if act in KAPSAM_DISI or not rig._durus.is_empty() or DurusKit_.var_mi(act) or o.has_meta("climber"):
			_scope_ok = false
	if not _scope_ok:
		_kapat()
		return
	# LOD: uzaktakiler yarım saniyede bir, LOD sınırına yakın olanlar her karede (ucuz koni testi). Kamera kesmesinde
	# görüşe yeni giren kişide IK anında açılır (bir önceki karede görünmüyordu: geçiş görünmez); yürüyerek LOD
	# sınırını geçende yumuşak (0,25 sn).
	_lod_t -= delta
	if _lod_t <= 0.0:
		var cam := kamera(o)
		var hedef := false
		if cam:
			var op := o.global_position
			var d2 := op.distance_squared_to(_cam_pos)
			_lod_t = 0.0 if d2 < (LOD + 6.0) * (LOD + 6.0) else 0.4 + randf() * 0.2
			var kon := d2 < LOD_YAKIN * LOD_YAKIN or gorunur(op, d2)
			hedef = kon and d2 <= LOD * LOD
			if kon and not _kon:
				w = 1.0 if hedef else 0.0
			_kon = kon
		else:
			_lod_t = 0.5
			_kon = false
		_yakin = hedef
	w = move_toward(w, 1.0 if _yakin else 0.0, delta * 4.0)
	if w <= 0.0:
		_kapat()
		return
	var t0 := Time.get_ticks_usec()
	_coz(delta, yuru and not anim)
	olc_us += Time.get_ticks_usec() - t0
	olc_n += 1


func _kapat() -> void:
	w = 0.0
	pel = 0.0
	_planted[0] = false
	_planted[1] = false
	_cur[0] = Vector3.INF
	_cur[1] = Vector3.INF
	_lp = Vector3.INF
	_az_sifirla()


func _az_sifirla() -> void:
	if not _az_on:
		return
	_az_on = false
	for s in 2:
		var an := _anks[s]
		if an != _knees[s] and is_equal_approx(an.rotation.z, _w_az[s]):
			an.rotation.z = 0.0


## Ebeveyn uzayındaki p'nin altındaki görünen zemin (ışın; Unclip.floor_y'nin ölçüsü). Bulursa true; _zy, _zn'ye
## ebeveyn uzayında yükseklik ve normal.
var _zy := 0.0
var _zn := Vector3.UP


func _zemin(p: Vector3, ref_y: float) -> bool:
	var par_t := _par.global_transform if is_instance_valid(_par) else Transform3D.IDENTITY
	var wp := par_t * Vector3(p.x, ref_y, p.z)
	var up := par_t.basis.y.normalized()
	var space := rig.owner.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(wp + up * ISIN_UST, wp - up * ISIN_ALT, 1)
	isin_n += 1
	for i in 6:
		var h := space.intersect_ray(q)
		if h.is_empty():
			return false
		var col: Object = h["collider"]
		if col is CollisionObject3D and not Unclip_.standable(col, int(h.get("shape", 0))):
			q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
			continue
		var inv := par_t.affine_inverse()
		_zy = (inv * (h["position"] as Vector3)).y
		_zn = (inv.basis * (h["normal"] as Vector3)).normalized()
		if _zn.y < 0.55:      # duvar yüzü/çok dik: düz say (bacak 56°'den dik eğime basmaz)
			_zn = Vector3.UP
		return true
	return false


## Ayak s'nin zemin önbelleği p'ye (ebeveyn uzayı) göre güncel mi; değilse ışın (zorla: esik < 0)
func _zemin_ayak(s: int, p: Vector3, ref_y: float, delta: float, esik := 0.06) -> void:
	_g_t[s] -= delta
	var gp := _g_p[s]
	if esik > 0.0 and gp.x != INF and _g_t[s] > 0.0 and Vector2(gp.x - p.x, gp.z - p.z).length() < esik:
		return
	_g_p[s] = p
	_g_t[s] = 2.0 + randf() * 0.5
	_g_ok[s] = _zemin(p, ref_y)
	if _g_ok[s]:
		_g_y[s] = _zy
		_g_n[s] = _zn


func _coz(delta: float, yuru: bool) -> void:
	var body := rig.body
	var ot := (rig.owner as Node3D).transform           # ebeveyn uzayında kök
	var root := ot.origin
	# Hız (ebeveyn uzayı): ışınlanma kilitleri bırakır
	if _lp.x == INF or root.distance_squared_to(_lp) > 2.25:
		_planted[0] = false
		_planted[1] = false
		_vel = Vector3.ZERO
		_cur[0] = Vector3.INF
		_cur[1] = Vector3.INF
	elif delta > 0.0:
		var v := (root - _lp) / delta
		v.y = 0.0
		_vel = _vel.lerp(v, clampf(delta * 8.0, 0.0, 1.0))
	_lp = root
	var m := 2 if yuru else 1
	if m != _last_mod:
		_mod_t = 0.3
		_last_mod = m
		if m == 2:
			_planted[0] = false
			_planted[1] = false
			_lift_ok[0] = false
			_lift_ok[1] = false
	_mod_t = maxf(0.0, _mod_t - delta)
	mod = m
	# FK'den: kökün yerel uzayında kalça ve taban (Rig'in kurduğu duruş)
	var bxf := body.transform
	for s in 2:
		var lg := _legs[s]
		_hip[s] = bxf * lg.position
		_fks[s] = bxf * (lg.transform * (_knees[s].transform * _apos[s])) - Vector3(0, TABAN, 0)
	# Hedef taban noktaları (ebeveyn uzayı) ve normaller
	if m == 1:
		for s in 2:
			var fs := _fks[s]
			var pp := ot * Vector3(fs.x, 0.0, fs.z + TABAN_Z)
			_zemin_ayak(s, pp, root.y, delta)
			var gok: bool = _g_ok[s]
			# FK'nin tabanı kaldırdığı kadar (tekme, adım pozu) zeminin üstünde kalır
			_grd[s] = fs.y < 0.05
			basiyor[s] = _grd[s] and gok
			_tgt[s] = Vector3(pp.x, (_g_y[s] if gok else root.y) + maxf(0.0, fs.y), pp.z)
			_tn[s] = _g_n[s] if gok else Vector3.UP
		# Düz zemin ve kök tam zeminde: IK sonucu FK'nin aynısı; hiçbir şey yazılmaz (şehirde duranların çoğu)
		if _mod_t <= 0.0 and absf(pel) < 0.004 and _g_ok[0] and _g_ok[1] and absf(_g_y[0] - root.y) < 0.015 \
				and absf(_g_y[1] - root.y) < 0.015 and _g_n[0].y > 0.996 and _g_n[1].y > 0.996:
			pel = 0.0
			_cur[0] = _tgt[0]
			_cur[1] = _tgt[1]
			_cur_n[0] = _tn[0]
			_cur_n[1] = _tn[1]
			_az_sifirla()
			return
	else:
		_yuruyus(ot, root)
		_grd[0] = basiyor[0] or _planted[0]
		_grd[1] = basiyor[1] or _planted[1]
	# Kip değişiminde yumuşak geçiş
	var gecis := _mod_t > 0.0
	var kk := clampf(delta * 12.0, 0.0, 1.0)
	for s in 2:
		var c := _cur[s]
		if c.x == INF or not gecis:
			_cur[s] = _tgt[s]
			_cur_n[s] = _tn[s]
		else:
			_cur[s] = c.lerp(_tgt[s], kk)
			_cur_n[s] = _cur_n[s].lerp(_tn[s], kk).normalized()
	# Kalça: kök uzayında; her ayağın bileğine kalçanın en çok ne kadar yüksekte olabileceği
	var oinv := ot.affine_inverse()
	var R := _R
	var p_t := INF
	var up_t := INF
	for s in 2:
		var nl := (oinv.basis * _cur_n[s]).normalized()
		var al := oinv * _cur[s] + nl * TABAN - Vector3(0, 0, TABAN_Z)
		_al[s] = al
		var h := _hip[s]
		var hd := Vector2(h.x - al.x, h.z - al.z).length()
		if m == 2:
			# Yürürken salınan ayak kalçayı bağlamaz; basan ayak adımın iki ucunda topuktan/parmaktan yuvarlanır
			# (taban tam düz değil): kalça adım uzunluğunun ancak bir kısmı kadar iner (yoksa her adımda çöküyordu)
			if not _planted[s]:
				continue
			hd *= 0.6
		elif not _grd[s]:
			continue
		p_t = minf(p_t, al.y + sqrt(maxf(R * R - hd * hd, 0.0)) - h.y)
		if m == 1:
			# Durunca kalça yukarı ancak gerektiği kadar: düzde FK yüksekliği, gömülü ayakta zemine çıkacak kadar
			up_t = minf(up_t, al.y - (_fks[s].y + TABAN))
	if p_t == INF:
		p_t = 0.0
	if up_t < INF:
		p_t = minf(p_t, up_t)
	p_t = clampf(p_t, PEL_ALT, PEL_UST)
	pel = lerpf(pel, p_t, clampf(delta * (20.0 if p_t < pel else 8.0), 0.0, 1.0))
	# Uygula: gövde (dik) iner/çıkar; bacaklar IK
	var pw := pel * w
	_fk_by = body.position.y
	body.position.y = _fk_by + pw
	_w_by = body.position.y
	bxf.origin.y += pw
	var binv := bxf.affine_inverse()
	var bz := body.rotation.z
	_az_on = true
	for s in 2:
		var lg := _legs[s]
		var kn := _knees[s]
		_fk_leg[s] = lg.rotation
		_fk_knee[s] = kn.rotation.x
		var al := _al[s]
		if w < 1.0:
			al = al.lerp(_fks[s] + Vector3(0, TABAN + pw, 0), 1.0 - w)
		_iki_kemik(lg, kn, binv * al, _L1, _L2)
		_w_leg[s] = lg.basis
		_w_knee[s] = kn.rotation.x
		# Taban eğimi (kök uzayında normal): ileri eğim bileğin x'ine ek, yanal eğim bileğin z'si
		var nl := (oinv.basis * _cur_n[s]).normalized()
		ank_ek[s] = clampf(atan2(nl.z, nl.y), -0.6, 0.6) * w
		var an := _anks[s]
		if an != kn:
			var rz := clampf(atan2(-nl.x, nl.y) - bz - lg.rotation.z, -0.4, 0.4) * w
			if absf(an.rotation.z - rz) > 0.004:
				an.rotation.z = rz
			_w_az[s] = an.rotation.z
	_has_w = true


## Yürüyüş kipi: her ayak Rig'in evresinden (sol ayak evre -π/2'de öne basar) basar/salınır. Basma süresi D (evrenin
## payı: yürürken 0,56, koşarken 0,25–0,35), adım uzunluğu ve kilit hızdan; iniş noktası şimdiki hızla öngörülür.
func _yuruyus(ot: Transform3D, root: Vector3) -> void:
	var rate: float = maxf(rig.faz_hiz, 0.5)
	var phase: float = rig._walk_phase
	var spd := _vel.length()
	var run := clampf((spd - 3.2) / 2.0, 0.0, 1.0)
	# Basma payı hızla kısalır (koşuda ayak yerde kısa kalır; uzun basmada bacak adımın uçlarına yetişmiyordu)
	var D := clampf(0.56 - 0.1 * (spd - 1.5), 0.25, 0.56)
	var Tc := TAU / rate
	var fwd := _vel / spd if spd > 0.2 else (ot.basis.z * Vector3(1, 0, 1)).normalized()
	var amp := clampf(spd / 3.0, 0.35, 1.0)
	var lift_h := (0.08 + 0.1 * run) * amp + 0.03
	var half := spd * D * Tc * 0.5
	var reach := 0.6
	for s in 2:
		var u := fposmod((phase + PI * 0.5) / TAU + 0.5 * s, 1.0)
		var hp := ot * Vector3(_hip[s].x, 0.0, TABAN_Z)      # kalçanın altındaki taban ortası (yanal)
		if u < D:
			if not _planted[s]:
				var p := _land[s]
				if p.x == INF or Vector2(p.x - hp.x, p.z - hp.z).length() > reach:
					p = hp + fwd * half * (1.0 - 2.0 * u / D)
				_zemin_ayak(s, p, root.y, 0.0, -1.0)
				_plant[s] = Vector3(p.x, _g_y[s] if _g_ok[s] else root.y, p.z)
				_plant_n[s] = _g_n[s] if _g_ok[s] else Vector3.UP
				_planted[s] = true
			var pl := _plant[s]
			if Vector2(pl.x - hp.x, pl.z - hp.z).length() > reach:
				# Kilit koptu (yerinde dönüş, ani hız değişimi): ayak kalçanın altına alınır
				_zemin_ayak(s, hp, root.y, 0.0, -1.0)
				_plant[s] = Vector3(hp.x, _g_y[s] if _g_ok[s] else root.y, hp.z)
				_plant_n[s] = _g_n[s] if _g_ok[s] else Vector3.UP
			_tgt[s] = _plant[s]
			_tn[s] = _plant_n[s]
			basiyor[s] = u > 0.06 and u < D - 0.06
			_land[s] = Vector3.INF
			_land_ray[s] = Vector3.INF
		else:
			if _planted[s]:
				_planted[s] = false
				_lift[s] = _plant[s]
				_lift_n[s] = _plant_n[s]
				_lift_rel[s] = _plant[s] - hp
				_lift_ok[s] = true
			elif not _lift_ok[s]:
				var c := _cur[s]
				_lift[s] = c if c.x != INF else Vector3(hp.x, root.y, hp.z)
				_lift_n[s] = _cur_n[s]
				_lift_rel[s] = _lift[s] - hp
				_lift_ok[s] = true
			var sw := (u - D) / (1.0 - D)
			var land := hp + _vel * ((1.0 - u) * Tc) + fwd * half
			var lr := _land_ray[s]
			if lr.x == INF or Vector2(lr.x - land.x, lr.z - land.z).length() > 0.15:
				_land_ray[s] = land
				if _zemin(land, root.y):
					land.y = _zy
					_land_n[s] = _zn
				else:
					land.y = root.y
					_land_n[s] = Vector3.UP
			else:
				land.y = _land[s].y if _land[s].x != INF else root.y
			_land[s] = land
			var lf := _lift[s]
			if Vector2(lf.x - hp.x, lf.z - hp.z).length() > reach * 1.5:
				lf = Vector3(hp.x, root.y, hp.z)
				_lift[s] = lf
				_lift_rel[s] = Vector3.ZERO
			# Kalçaya göre aradeğer (sarkaç): dünya uzayında aradeğerlenince hızlı koşuda salınan ayak geride gerili
			# kalıyordu (kalkış noktası kalçanın 1 m gerisinde)
			var e := smoothstep(0.0, 1.0, sw)
			var p := hp + _lift_rel[s].lerp(land - hp, e)
			p.y = lerpf(lf.y, land.y, e) + lift_h * sin(PI * sw)
			_tgt[s] = p
			_tn[s] = _lift_n[s].lerp(_land_n[s], e).normalized()


## İki kemikli IK (gövde uzayında): kalça (leg) ve diz (knee). Diz açısı kosinüs yasasından; uyluk, FK'nin bükülme
## düzlemini koruyan en kısa dönüşle hedefe çevrilir. Diz yalnız öne bükülür (Rig: diz açısı artı).
static func _iki_kemik(leg: Node3D, knee: Node3D, target: Vector3, L1: float, L2: float) -> void:
	var d_v := target - leg.position
	var dl := d_v.length()
	var d := clampf(dl, absf(L1 - L2) + 0.02, (L1 + L2) * 0.9995)
	var k := PI - acos(clampf((L1 * L1 + L2 * L2 - d * d) / (2.0 * L1 * L2), -1.0, 1.0))
	knee.rotation.x = k
	var lb := leg.basis
	var e := lb * Vector3(0, -L1 - L2 * cos(k), -L2 * sin(k))
	if dl < 1e-3:
		return
	var a := e.normalized()
	var b := d_v / dl
	if a.dot(b) > 0.99999:
		return
	leg.basis = Basis(Quaternion(a, b)) * lb
