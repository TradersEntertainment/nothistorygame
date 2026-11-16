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


static func kamera(ctx: Node) -> Camera3D:
	var f := Engine.get_process_frames()
	if f != _cam_frame:
		_cam_frame = f
		_cam = ctx.get_viewport().get_camera_3d() if ctx.is_inside_tree() else null
	return _cam


var rig: Object      # Rig (döngüsel önyükleme olmasın diye türsüz)
var w := 0.0         # IK ağırlığı (LOD girişte/çıkışta yumuşak)
var mod := 0         # bu karede: 0 kapalı, 1 izdüşüm (FK duruşu + zemin), 2 yürüyüş (basan ayak kilitli)
var basiyor := [false, false]     # denetim: bu ayak şu an yere basmalı mı
var ank_ek := PackedFloat32Array([0.0, 0.0])    # bilek ek eğimi (rad; Rig.extremities okur)
var _yakin := false
var _lod_t := 0.0
var _scope_t := 0.0
var _scope_ok := true
## Geri alma: Rig ve LimbAnim kendi değerlerini bir önceki karenin üstüne (lerp) kurar; IK'nın yazdığı her değer bir
## sonraki karenin başında FK değerine döndürülür (başkası bu arada yazdıysa onunki kalır)
var _has_w := false
var _fk_leg := [Vector3.ZERO, Vector3.ZERO]
var _w_leg := [Basis.IDENTITY, Basis.IDENTITY]
var _fk_knee := PackedFloat32Array([0.0, 0.0])
var _w_knee := PackedFloat32Array([0.0, 0.0])
var _fk_by := 0.0
var _w_by := 0.0
var _w_az := PackedFloat32Array([0.0, 0.0])
var _az_on := false
var pel := 0.0
## Zemin önbelleği (ayak başına; ebeveyn uzayı): ışının indiği nokta, yükseklik, normal
var _g_p := [Vector3.INF, Vector3.INF]
var _g_y := PackedFloat32Array([0.0, 0.0])
var _g_n := [Vector3.UP, Vector3.UP]
var _g_t := PackedFloat32Array([0.0, 0.0])
var _g_ok := [false, false]
## Yürüyüş: basma noktası (ebeveyn uzayında taban), kalkış noktası, iniş noktası
var _planted := [false, false]
var _plant := [Vector3.ZERO, Vector3.ZERO]
var _plant_n := [Vector3.UP, Vector3.UP]
var _lift := [Vector3.ZERO, Vector3.ZERO]
var _lift_n := [Vector3.UP, Vector3.UP]
var _lift_ok := [false, false]
var _land := [Vector3.INF, Vector3.INF]
var _land_n := [Vector3.UP, Vector3.UP]
var _land_ray := [Vector3.INF, Vector3.INF]
var _vel := Vector3.ZERO
var _lp := Vector3.INF
var _last_mod := 0
var _mod_t := 0.0
var _cur := [Vector3.INF, Vector3.INF]      # son taban hedefi (ebeveyn uzayı): kip değişiminde yumuşak geçiş
var _cur_n := [Vector3.UP, Vector3.UP]
var _ankle := [null, null]


func _init(r: Object) -> void:
	rig = r


## Önceki karede yazılanları FK değerine döndür (Rig.update'in ve LimbAnim'in başında)
func geri_al() -> void:
	mod = 0
	if not _has_w:
		return
	_has_w = false
	var body: Node3D = rig.body
	if body and is_equal_approx(body.position.y, _w_by):
		body.position.y = _fk_by
	for s in 2:
		var leg: Node3D = rig.leg_l if s == 0 else rig.leg_r
		var kn: Node3D = rig.knee_l if s == 0 else rig.knee_r
		if leg and leg.basis.is_equal_approx(_w_leg[s]):
			leg.rotation = _fk_leg[s]
		if kn and is_equal_approx(kn.rotation.x, _w_knee[s]):
			kn.rotation.x = _fk_knee[s]


## Kapsam: IK bu kişide çalışabilir mi (iş, işaret, taşıyıcı). Denetim de aynı ölçüyü kullanır.
static func kapsam_disi(r: Object) -> String:
	var o: Node3D = r.owner
	if o == null or not o.is_inside_tree() or not o.is_visible_in_tree():
		return "gizli"
	var act: String = r.activity
	if act in KAPSAM_DISI or act.begins_with("sit") or act.begins_with("climb"):
		return "is:" + act
	if DurusKit_.var_mi(act) or not (r._durus as Dictionary).is_empty():
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
	if not etkin:
		return
	var o: Node3D = rig.owner
	var body: Node3D = rig.body
	if body == null or rig.leg_l == null or rig.leg_r == null or rig.knee_l == null or rig.knee_r == null:
		return
	if (rig.lock > 0 and not anim):
		_kapat()
		return
	_scope_t -= delta
	if _scope_t <= 0.0:
		_scope_t = 0.5
		_scope_ok = kapsam_disi(rig) == ""
	elif _scope_ok:
		# Ucuz anlık denetim: iş değiştiyse hemen kapanır (oturdu, ata bindi)
		var act: String = rig.activity
		if act in KAPSAM_DISI or DurusKit_.var_mi(act) or o.has_meta("climber"):
			_scope_ok = false
	if not _scope_ok:
		_kapat()
		return
	_lod_t -= delta
	if _lod_t <= 0.0:
		_lod_t = 0.2 + randf() * 0.1
		var cam := kamera(o)
		_yakin = false
		if cam:
			var cp := cam.global_position
			var op := o.global_position
			var d := cp.distance_to(op)
			_yakin = d <= LOD_YAKIN or (d <= LOD and (cam.is_position_in_frustum(op + Vector3(0, 0.5, 0)) \
				or cam.is_position_in_frustum(op + Vector3(0, 1.6, 0))))
	w = move_toward(w, 1.0 if _yakin else 0.0, delta * 4.0)
	if w <= 0.0:
		pel = 0.0
		_planted[0] = false
		_planted[1] = false
		_cur[0] = Vector3.INF
		_cur[1] = Vector3.INF
		_lp = Vector3.INF
		_az_sifirla()
		return
	var t0 := Time.get_ticks_usec()
	_coz(delta, yuru and not anim)
	olc_us += Time.get_ticks_usec() - t0
	olc_n += 1


func _kapat() -> void:
	w = 0.0
	_planted[0] = false
	_planted[1] = false
	_cur[0] = Vector3.INF
	_cur[1] = Vector3.INF
	_lp = Vector3.INF
	pel = 0.0
	_az_sifirla()


func _az_sifirla() -> void:
	if not _az_on:
		return
	_az_on = false
	for s in 2:
		var an: Node3D = _ankle_of(s)
		if an and is_equal_approx(an.rotation.z, _w_az[s]):
			an.rotation.z = 0.0


func _ankle_of(s: int) -> Node3D:
	if _ankle[s] == null:
		var kn: Node3D = rig.knee_l if s == 0 else rig.knee_r
		var a := kn.get_node_or_null("Ankle") if kn else null
		_ankle[s] = a if a else kn
	return _ankle[s]


## Ebeveyn uzayındaki p'nin altındaki görünen zemin (ışın): [y, normal] ebeveyn uzayında; yoksa boş
func _zemin(par_t: Transform3D, p: Vector3, ref_y: float) -> Array:
	var o: Node3D = rig.owner
	var wp := par_t * Vector3(p.x, ref_y, p.z)
	var up := par_t.basis.y.normalized()
	var space := o.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(wp + up * ISIN_UST, wp - up * ISIN_ALT, 1)
	isin_n += 1
	for i in 6:
		var h := space.intersect_ray(q)
		if h.is_empty():
			return []
		var col: Object = h["collider"]
		if col is CollisionObject3D and not Unclip_.standable(col, int(h.get("shape", 0))):
			q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
			continue
		var inv := par_t.affine_inverse()
		var lp := inv * (h["position"] as Vector3)
		var n := (inv.basis * (h["normal"] as Vector3)).normalized()
		if n.y < 0.55:      # duvar yüzü/çok dik: düz say (bacak 56°'den dik eğime basmaz)
			n = Vector3.UP
		return [lp.y, n]
	return []


## Ayak s'nin zemin önbelleği p'ye (ebeveyn uzayı) göre güncel mi; değilse ışın
func _zemin_ayak(s: int, par_t: Transform3D, p: Vector3, ref_y: float, delta: float, esik := 0.06) -> void:
	_g_t[s] -= delta
	var gp: Vector3 = _g_p[s]
	if gp != Vector3.INF and _g_t[s] > 0.0 and Vector2(gp.x - p.x, gp.z - p.z).length() < esik:
		return
	_g_p[s] = p
	_g_t[s] = 2.0 + randf() * 0.5
	var z := _zemin(par_t, p, ref_y)
	_g_ok[s] = not z.is_empty()
	if _g_ok[s]:
		_g_y[s] = z[0]
		_g_n[s] = z[1]


func _coz(delta: float, yuru: bool) -> void:
	var o: Node3D = rig.owner
	var body: Node3D = rig.body
	var par := o.get_parent() as Node3D
	var par_t := par.global_transform if par else Transform3D.IDENTITY
	var ot := o.transform           # ebeveyn uzayında kök
	var oinv := ot.affine_inverse()
	var root := ot.origin
	var legs: Array = [rig.leg_l, rig.leg_r]
	var knees: Array = [rig.knee_l, rig.knee_r]
	# Hız (ebeveyn uzayı): ışınlanma kilitleri bırakır
	if _lp == Vector3.INF or root.distance_to(_lp) > 1.5:
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
	var bxf := body.transform           # kök uzayında gövde
	var hip_l: Array = [bxf * (legs[0] as Node3D).position, bxf * (legs[1] as Node3D).position]
	var fk_sole: Array = [Vector3.ZERO, Vector3.ZERO]
	for s in 2:
		var an := _ankle_of(s)
		var kn := knees[s] as Node3D
		var lg := legs[s] as Node3D
		var ak := lg.transform * (kn.transform * (an.position if an != kn else Vector3(0, -0.255, 0)))
		fk_sole[s] = bxf * ak - Vector3(0, TABAN, 0)
	# Hedef taban noktaları (ebeveyn uzayı) ve normaller
	var tgt: Array = [Vector3.ZERO, Vector3.ZERO]
	var tn: Array = [Vector3.UP, Vector3.UP]
	var grounded := [true, true]
	if m == 1:
		for s in 2:
			var fs: Vector3 = fk_sole[s]
			var pp: Vector3 = ot * Vector3(fs.x, 0.0, fs.z)
			_zemin_ayak(s, par_t, pp, root.y, delta)
			var gy: float = _g_y[s] if _g_ok[s] else root.y
			# FK'nin tabanı kaldırdığı kadar (tekme, adım pozu) zeminin üstünde kalır
			var lift := maxf(0.0, fs.y)
			grounded[s] = fs.y < 0.05
			basiyor[s] = grounded[s] and _g_ok[s]
			tgt[s] = Vector3(pp.x, gy + lift, pp.z)
			tn[s] = _g_n[s] if _g_ok[s] else Vector3.UP
	else:
		_yuruyus(delta, par_t, ot, root, hip_l, tgt, tn)
		grounded = [basiyor[0] or _planted[0], basiyor[1] or _planted[1]]
	# Kip değişiminde yumuşak geçiş
	for s in 2:
		var c: Vector3 = _cur[s]
		if c == Vector3.INF or _mod_t <= 0.0:
			_cur[s] = tgt[s]
			_cur_n[s] = tn[s]
		else:
			var kk := clampf(delta * 12.0, 0.0, 1.0)
			_cur[s] = c.lerp(tgt[s], kk)
			_cur_n[s] = (_cur_n[s] as Vector3).lerp(tn[s], kk).normalized()
	# Kalça: kök uzayında; her ayağın bileğine kalçanın en çok ne kadar yüksekte olabileceği
	var L1 := absf((knees[0] as Node3D).position.y)
	var a0 := _ankle_of(0)
	var L2 := absf(a0.position.y) if a0 != knees[0] else 0.255
	var R := (L1 + L2) * 0.985
	var p_t := INF
	var any_g := false
	var a_loc: Array = [Vector3.ZERO, Vector3.ZERO]
	for s in 2:
		var sl: Vector3 = oinv * (_cur[s] as Vector3)
		var nl := (oinv.basis * (_cur_n[s] as Vector3)).normalized()
		var al := sl + nl * TABAN
		a_loc[s] = al
		var h: Vector3 = hip_l[s]
		var hd := Vector2(h.x - al.x, h.z - al.z).length()
		var maxh := al.y + sqrt(maxf(R * R - hd * hd, 0.0))
		if m == 1 and not grounded[s]:
			continue
		any_g = true
		p_t = minf(p_t, maxh - h.y)
	if not any_g:
		p_t = 0.0
	if m == 1:
		# Durunca: ayakların ikisi de bükülmesin diye kalça FK'deki gibi (aşağı inmesi gerekiyorsa iner, yukarı
		# çıkması gerekiyorsa çıkar), ama düzde FK yüksekliğinde kalır
		p_t = minf(p_t, _ust_sinir(hip_l, a_loc, grounded, fk_sole))
	p_t = clampf(p_t, PEL_ALT, PEL_UST)
	var kp := clampf(delta * (20.0 if p_t < pel else 8.0), 0.0, 1.0)
	pel = lerpf(pel, p_t, kp)
	# Uygula: gövde (dik) iner/çıkar
	_fk_by = body.position.y
	body.position.y = _fk_by + pel * w
	_w_by = body.position.y
	var bt := body.transform
	var binv := bt.affine_inverse()
	_az_on = true
	for s in 2:
		var lg := legs[s] as Node3D
		var kn := knees[s] as Node3D
		_fk_leg[s] = lg.rotation
		_fk_knee[s] = kn.rotation.x
		var fk_a: Vector3 = fk_sole[s] + Vector3(0, TABAN + pel * w, 0)
		var al: Vector3 = (a_loc[s] as Vector3).lerp(fk_a, 1.0 - w)
		_iki_kemik(lg, kn, binv * al, L1, L2)
		_w_leg[s] = lg.basis
		_w_knee[s] = kn.rotation.x
		# Taban eğimi (kök uzayında normal): ileri eğim bileğin x'ine ek, yanal eğim bileğin z'si
		var nl := (oinv.basis * (_cur_n[s] as Vector3)).normalized()
		ank_ek[s] = clampf(atan2(nl.z, nl.y), -0.6, 0.6) * w
		var an := _ankle_of(s)
		if an != kn:
			var rz := clampf(atan2(-nl.x, nl.y) - body.rotation.z - lg.rotation.z, -0.4, 0.4) * w
			if absf(an.rotation.z - rz) > 0.004:
				an.rotation.z = rz
			_w_az[s] = an.rotation.z
	_has_w = true


## Dururken kalça yukarı ancak gerektiği kadar: düzde FK'nin yüksekliği (0), ayak(lar) zemine gömülüyse en alçak
## gömülü ayağın zemini kadar çıkar.
func _ust_sinir(hip_l: Array, a_loc: Array, grounded: Array, fk_sole: Array) -> float:
	var up := INF
	for s in 2:
		if not grounded[s]:
			continue
		var fk_a: Vector3 = fk_sole[s] + Vector3(0, TABAN, 0)
		up = minf(up, (a_loc[s] as Vector3).y - fk_a.y)
	return up if up < INF else 0.0


## Yürüyüş kipi: her ayak Rig'in evresinden (sol ayak evre -π/2'de öne basar) basar/salınır.
func _yuruyus(delta: float, par_t: Transform3D, ot: Transform3D, root: Vector3, hip_l: Array, tgt: Array, tn: Array) -> void:
	var rate: float = maxf(rig.faz_hiz, 0.5)
	var phase: float = rig._walk_phase
	var spd := _vel.length()
	var run := clampf((spd - 3.2) / 2.0, 0.0, 1.0)
	var D := lerpf(0.56, 0.3, run)
	var Tc := TAU / rate
	var fwd := _vel / spd if spd > 0.2 else (ot.basis.z * Vector3(1, 0, 1)).normalized()
	var amp := clampf(spd / 3.0, 0.35, 1.0)
	var lift_h := (0.08 + 0.1 * run) * amp + 0.03
	var reach := 0.6
	for s in 2:
		var u := fposmod((phase + PI * 0.5) / TAU + 0.5 * s, 1.0)
		var hp: Vector3 = ot * Vector3((hip_l[s] as Vector3).x, 0.0, 0.0)      # kalçanın zemindeki izdüşümü (yanal)
		if u < D:
			if not _planted[s]:
				var p: Vector3 = _land[s]
				if p == Vector3.INF or Vector2(p.x - hp.x, p.z - hp.z).length() > reach:
					p = hp + fwd * (spd * D * Tc * 0.5) * (1.0 - 2.0 * u / D)
				_zemin_ayak(s, par_t, p, root.y, 0.0, 0.0)
				_plant[s] = Vector3(p.x, _g_y[s] if _g_ok[s] else root.y, p.z)
				_plant_n[s] = _g_n[s] if _g_ok[s] else Vector3.UP
				_planted[s] = true
			var pl: Vector3 = _plant[s]
			if Vector2(pl.x - hp.x, pl.z - hp.z).length() > reach:
				# Kilit koptu (yerinde dönüş, ani hız değişimi): ayak kalçanın altına alınır
				var p2 := hp
				_zemin_ayak(s, par_t, p2, root.y, 0.0, 0.0)
				_plant[s] = Vector3(p2.x, _g_y[s] if _g_ok[s] else root.y, p2.z)
				_plant_n[s] = _g_n[s] if _g_ok[s] else Vector3.UP
			tgt[s] = _plant[s]
			tn[s] = _plant_n[s]
			basiyor[s] = u > 0.06 and u < D - 0.06
			_land[s] = Vector3.INF
			_land_ray[s] = Vector3.INF
		else:
			if _planted[s]:
				_planted[s] = false
				_lift[s] = _plant[s]
				_lift_n[s] = _plant_n[s]
				_lift_ok[s] = true
			elif not _lift_ok[s]:
				var c: Vector3 = _cur[s]
				_lift[s] = c if c != Vector3.INF else Vector3(hp.x, root.y, hp.z)
				_lift_n[s] = _cur_n[s]
				_lift_ok[s] = true
			var sw := (u - D) / (1.0 - D)
			var t_left := (1.0 - u) * Tc
			var land := hp + _vel * t_left + fwd * (spd * D * Tc * 0.5)
			var lr: Vector3 = _land_ray[s]
			if lr == Vector3.INF or Vector2(lr.x - land.x, lr.z - land.z).length() > 0.15:
				_land_ray[s] = land
				var z := _zemin(par_t, land, root.y)
				_land_n[s] = z[1] if not z.is_empty() else Vector3.UP
				land.y = z[0] if not z.is_empty() else root.y
			else:
				land.y = (_land[s] as Vector3).y if (_land[s] as Vector3) != Vector3.INF else root.y
			_land[s] = land
			var lf: Vector3 = _lift[s]
			if Vector2(lf.x - hp.x, lf.z - hp.z).length() > reach * 1.5:
				lf = Vector3(hp.x, root.y, hp.z)
				_lift[s] = lf
			var e := smoothstep(0.0, 1.0, sw)
			var p := lf.lerp(land, e)
			p.y = lerpf(lf.y, land.y, e) + lift_h * sin(PI * sw)
			tgt[s] = p
			tn[s] = (_lift_n[s] as Vector3).lerp(_land_n[s], e).normalized()


## İki kemikli IK (gövde uzayında): kalça (leg) ve diz (knee). Diz açısı kosinüs yasasından; uyluk, FK'nin bükülme
## düzlemini koruyan en kısa dönüşle hedefe çevrilir. Diz yalnız öne bükülür (Rig: diz açısı artı).
static func _iki_kemik(leg: Node3D, knee: Node3D, target: Vector3, L1: float, L2: float) -> void:
	var H := leg.position
	var d_v := target - H
	var d := clampf(d_v.length(), absf(L1 - L2) + 0.02, (L1 + L2) * 0.9995)
	var ck := clampf((L1 * L1 + L2 * L2 - d * d) / (2.0 * L1 * L2), -1.0, 1.0)
	var k := PI - acos(ck)
	knee.rotation.x = k
	var e := leg.basis * (Vector3(0, -L1, 0) + Basis(Vector3.RIGHT, k) * Vector3(0, -L2, 0))
	if e.length_squared() < 1e-6 or d_v.length_squared() < 1e-6:
		return
	var a := e.normalized()
	var b := d_v.normalized()
	if a.dot(b) > 0.99999:
		return
	leg.basis = Basis(Quaternion(a, b)) * leg.basis
