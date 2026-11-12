extends Node
## Ortak tırmanma animasyonu (merdiven ve ip). class_name YOK: `preload("res://scripts/npc/climb_anim.gd")` ile kullanılır.
## Tırmanan kişinin (Person / Soldier: `rig` taşıyan her gövde) ÇOCUĞU olarak eklenir; kişinin kendi _process'inden
## SONRA çalışır (ağaç sırası), Rig'i kilitler (lock) ve bütün gövdeyi kendisi yerleştirir:
##  - Kök merdivenin eğimine PARALEL: yerel Y = merdivenin up_dir'i, yüz merdivene dönük; göğüs merdivene ~0,22 m.
##  - Eller GERÇEK basamakları tutar (Rig.reach kol IK'si), ayaklar GERÇEK basamaklara basar (iki kemikli bacak IK'si).
##  - Çapraz döngü: sağ el + sol ayak, sonra sol el + sağ ayak; her adımda gövde bir basamak yükselir, kalkan uzuv iki
##    basamak üste geçer (bırakır → merdivenden biraz açılıp kalkar → uzanır → tutar). Kalça adımla yana salınır, baş
##    yukarı bakar, ara sıra aşağı bakar.
##  - Durumlar: tırman / in (goal), bekle (hold), sıkı tutun (brace: gövde merdivene yapışır, baş eğik), tepeden mazgala
##    geç (mantle), bırak (release: düşüş çağıranın tween'iyle sürer).
##  - Merdiven her karede yeniden okunur: sallanırsa (rotation.z / x) kişi merdivenle birlikte sallanır.
## Merdiven: `Ladder` (point_at/up_dir/front_dir/height, RUNG/WIDTH) ya da set_line() ile verilen genel eğik hat
## (dip, tepe, ön yönü, ilk basamak, basamak aralığı, genişlik). İp için set_rope(): eller üst üste ipte, ayaklar duvara.
## Denetim (susturulamaz, her karede): el–basamak/dikme ≤ 0,06 (tutarken), ayak–basamak ≤ 0,06 (basarken), gövde ekseni
## ile merdiven ekseni ≤ 8°, göğüs–merdiven 0,15–0,35 m, kişi merdivenin ucundan yukarıda değil. Aşan ölçü
## `CLIMBAUDIT <bölüm> <kişi> <ölçü>=<değer>` basar.

const CHEST_R := 0.22          # gövdenin göğüs hizasında yarıçapı (CharKit.torso, genişlik 0,25 → 0,225)
const CHEST_H := 1.08          # göğüs yüksekliği (kök yereli)
const GAP := 0.22              # göğüs ile merdiven düzlemi arası (m)
const LEAN := 0.04             # gövdenin merdivene doğru eğimi (rad, ~2°)
const HAND_X := 0.22           # ellerin basamaktaki yanal yeri (dikme ±0,4)
const FOOT_X := 0.13
const ANKLE_UP := 0.10         # ayak bileği basamağın ekseninden bu kadar yukarıda (taban basamağın üstünde)
const ANKLE_OUT := 0.07        # ve bu kadar önde (topuk merdivenin önünde, parmak ucu basamağın üstünde)
const SOLE := Vector3(0, -0.077, 0.07)    # ayak bileği yerelinde tabanın basamağa değen yeri
const GRIP_OUT := 0.04         # avuç ortası basamak ekseninin önünde ve üstünde (avuç basamağı sarar)
const GRIP_UP := 0.025

## Ölçüler (her ladder için yeniden hesaplanır)
var who: Node3D
var rig: Rig
var ladder: Node3D               # Ladder ya da null (genel hat)
var tag := ""                    # denetim satırındaki bölüm adı
var rope := false                # ip sürümü: eller üst üste ipte, ayaklar duvarda

var _o := Vector3.ZERO            # merdivenin dibi (basamak ölçüsünün sıfırı)
var _u := Vector3.UP              # merdiven boyunca yukarı
var _f := Vector3.BACK            # merdivenin önü (tırmananın durduğu taraf)
var _r := Vector3.RIGHT
var _len := 6.0
var rung0 := 0.3
var gap := 0.36
var width := 0.8
# Genel hat (Ladder yoksa): yerel uçlar, taşıyıcı düğüm varsa onun yerelinde
var _line_frame: Node3D
var _line_base := Vector3.ZERO
var _line_top := Vector3.UP
var _line_front := Vector3.BACK

var s := 0.0                     # adım (sürekli): tam sayıda iki ayak ve iki el basamakta
var goal := 0.0                  # hedef adım (tam sayı)
var speed := 0.9                 # adım/sn
var brace := 0.0                 # 0..1 sıkı tutunma (çağıran verir; sallantıda)
var side := 0.0                  # merdiven boyunca yanal kayma (m)
var full := true                 # false: ucuz sürüm (IK seyrek: üç karede bir)
var state := "climb"             # climb | mantle | off
var paused := false              # true: hiç dokunma (çağıran başka iş yaptırıyor)
## Kayarak iniş (basamaklara basmadan): eller iki dikmede kayar, ayaklar dikmelerin dışına yaslı; adım döngüsü yok
var sliding := false
## Tepeden bakış (0..1): kalça merdivenin ucuna kadar çıkar (geçmez), eller dikmelerin uçlarını tutar, ayaklar en üst
## basamaklarda; baş ve göğüs mazgalın üstünden görünür (30o: geç kalan azap başını mazgaldan uzatır)
var peek := 0.0
var _slide_root := 0.0

var _kh := 3                     # alçak elin alçak ayaktan kaç basamak yukarıda olduğu
var _root_off := -0.17           # kök (ayak tabanı hizası) ile alçak ayağın basamağı arası, merdiven boyunca
var _hip_h := 0.66
var _sh_h := 1.28
var _t := 0.0
var _look_down := 0.0
var _look_t := 3.0
var _tick := 0
var _audit_next := {}
var _mantle := {}
var _parts := {}
var _scale := 1.0
var _hand_x := HAND_X
var _arm_len := 0.53             # omuz–avuç (kısa kollu gövde merdivene biraz daha yakın durur)
var _blend := 1.0                # bağlanırken eski yerinden merdivene geçiş (0 → 1)
var _from := Vector3.ZERO

static var audit_lines := 0


## Kişiyi merdivene bağlar. at: kökün (ayak tabanı hizası) merdiven boyunca metresi; en yakın tam adıma oturur.
static func attach(p_who: Node3D, p_ladder: Node3D, at := 0.0, p_tag := "") -> Node:
	var old := p_who.get_node_or_null("ClimbAnim")
	if old:
		old.release(false)
		p_who.remove_child(old)
		old.queue_free()
	var a: Node = (load("res://scripts/npc/climb_anim.gd") as GDScript).new()
	a.name = "ClimbAnim"
	a.who = p_who
	a.ladder = p_ladder
	a.tag = p_tag
	p_who.add_child(a)
	a._setup()
	if p_ladder:
		a.set_at(at)
	else:
		a._at0 = at          # genel hat: set_line gelince yerleşir (önce dünyanın ortasına konmasın)
	return a


## Bağlanırken (güverteden merdivene, yerden ilk basamağa) eski yerinden dur sürede geçer
func blend_from(from: Vector3, dur := 0.6) -> void:
	_from = from
	_blend = 0.0
	_blend_dur = maxf(0.05, dur)
var _blend_dur := 0.6
var _at0 := INF
## follow_frac(k, true) (hücum kalabalığı): gövde adım içinde daha düzgün yükselir: arka arkaya çıkanların aralığı korunur
var _driven := false


## Kişi üzerindeki tırmanma animasyonu (yoksa null)
static func of(p_who: Node3D) -> Node:
	return p_who.get_node_or_null("ClimbAnim") if is_instance_valid(p_who) else null


## Genel eğik hat (Ladder düğümü olmayan merdivenler): base/top dip ve tepe; front tırmananın durduğu yön (merdivenden
## dışarı); frame verilirse üçü onun yerelindedir (taşıyıcı gemi, sallanan merdiven düğümü).
func set_line(base: Vector3, top: Vector3, front: Vector3, p_rung0: float, p_gap: float, p_width: float, frame: Node3D = null) -> void:
	ladder = null
	_line_frame = frame
	_line_base = base
	_line_top = top
	_line_front = front
	rung0 = p_rung0
	gap = p_gap
	width = p_width
	_refresh()
	_fit_gait()
	if _at0 != INF:
		var a0 := _at0
		_at0 = INF
		s = maxf(0.0, roundf((a0 - rung0 - _root_off) / gap))
		goal = s


## İp: eller üst üste ipte (basamak yerine ip üstünde gap aralıklı tutuş yerleri), ayaklar ipin arkasındaki duvara
## basar. front: ipten tırmananın durduğu yöne. (Şimdilik kullanan yok: 29o ipinde yalnız oyuncu tırmanır.)
func set_rope(base: Vector3, top: Vector3, front: Vector3, frame: Node3D = null, p_gap := 0.3) -> void:
	rope = true
	set_line(base, top, front, 0.2, p_gap, 0.0, frame)


func _setup() -> void:
	rig = who.get("rig")
	_scale = who.global_basis.get_scale().y
	if rig:
		rig.lock += 1
		rig.activity = "climb_a"         # Unclip/yürüme denetimi tırmanma işini tanır
	_parts = {}
	if rig and rig.leg_l and rig.knee_l:
		_hip_h = rig.leg_l.position.y + (rig.body.position.y if rig.body else 0.0)
	if rig and rig.arm_l:
		_sh_h = rig.arm_l.position.y
	if rig and rig.elbow_l:
		var hm: Vector3 = rig.elbow_l.get_meta("hand", Vector3(0, -0.27, 0.01))
		_arm_len = rig.elbow_l.position.length() + hm.length()
	if rig and rig.arm_r:
		_hand_x = clampf(absf(rig.arm_r.position.x) - 0.07, 0.18, 0.34)     # el omzun hemen içinde (geniş omuzlu asker)
	set_process(true)
	_refresh()
	_fit_gait()


## Basamak aralığına göre el/ayak dizilişi: alçak ayak n'de, yüksek ayak n+1'de; eller omzun biraz üstünde.
func _fit_gait() -> void:
	# Alçak ayağın bileği kalçanın (0,20 + g/2) altında, yüksek ayak (0,20 − g/2) altında
	var hip_u := ANKLE_UP + 0.2 + gap * 0.5 if not rope else 0.55
	_root_off = hip_u - _hip_h
	var sh_u := _root_off + _sh_h
	var hi := roundi((sh_u + 0.22 - GRIP_UP) / gap) if not rope else roundi((sh_u + 0.12) / gap)
	_kh = maxi(1, hi - 1)


func set_at(at: float) -> void:
	s = maxf(0.0, roundf((at - rung0 - _root_off) / gap))
	goal = s
	_pose()


## Kökün (ayak tabanı hizası) şu anki merdiven metresi
func at_m() -> float:
	return rung0 + _root_off + gap * (floorf(s) + smoothstep(0.05, 0.85, s - floorf(s)))


## Hedef: merdiven metresi (kök); tam adıma yuvarlanır. Hız m/sn.
func go_to(at: float, mps := -1.0) -> void:
	goal = clampf(roundf((at - rung0 - _root_off) / gap), 0.0, max_step())
	if mps > 0.0:
		speed = mps / gap


## Sahne betiği tırmanışın zamanlamasını kendisi yürütüyorsa (bölümün süresi, hücum hızı): kökün merdiven metresi her
## karede buradan verilir; adım evresi bu metreden çıkar (yürütme aynı, yalnız gövde basamaklara oturur).
func follow(at: float) -> void:
	s = clampf((at - rung0 - _root_off) / gap, 0.0, max_step())
	goal = s


## follow'un oranlı biçimi: sahnenin tırmanış ilerlemesi k (0 dip, 1 tepe) merdivenin çıkılabilir boyuna (en yüksek
## adım) eşlenir. Aynı merdivende arka arkaya çıkanlar tepede aynı adıma sıkışıp iç içe girmez (aralık oranla korunur).
func follow_frac(k: float, even := false) -> void:
	_driven = even
	s = clampf(k, 0.0, 1.0) * max_step()
	goal = s


## Kişinin merdivenin ucunu geçmeden çıkabileceği en yüksek adım (yüksek el en üst basamakta)
func max_step() -> float:
	var top_rung := floorf((_len - rung0 - 0.05) / gap)
	return maxf(0.0, top_rung - _kh - 1.0)


func at_top() -> bool:
	return s >= max_step() - 0.001


## Tepeden mazgala geçiş: el tepede, bir bacağını atar, içeri çekilir; `to` (dünya) ayakta durduğu yer, face bakış.
## Bitince kilit açılır, düğüm kendini siler (kişi ayakta, dik).
func mantle(to: Vector3, face: Vector3, dur := 1.6) -> void:
	_mantle = {"t": 0.0, "dur": dur, "from": who.global_transform, "to": to, "face": face, "s": s}
	state = "mantle"


## Bırak: Rig kilidi açılır, gövde dikleşir (yaw korunur); düşüşü çağıran yürütür. act: bırakınca verilecek iş.
func release(free := true, act := "fall") -> void:
	if state == "off":
		return
	state = "off"
	if rig:
		rig.lock = maxi(0, rig.lock - 1)
		rig.activity = act
		if rig.body:
			rig.body.position = Vector3.ZERO
			rig.body.rotation = Vector3.ZERO
	if is_instance_valid(who):
		var yaw := atan2(-_f.x, -_f.z)
		var sc := who.global_basis.get_scale()
		who.global_basis = Basis(Vector3.UP, yaw).scaled(sc)
		if who.has_method("set_activity"):
			who.call("set_activity", act)
	set_process(false)
	if free:
		queue_free()


func _refresh() -> void:
	if ladder and is_instance_valid(ladder):
		_o = ladder.global_position
		_u = ladder.call("up_dir")
		_f = ladder.call("front_dir")
		_r = _u.cross(-_f).normalized()      # tırmananın sağı (yüzü merdivene dönük)
		_len = float(ladder.get("height"))
		rung0 = 0.3
		gap = Ladder.RUNG
		width = Ladder.WIDTH
		return
	var b := _line_base
	var t := _line_top
	var fr := _line_front
	if _line_frame and is_instance_valid(_line_frame):
		var g := _line_frame.global_transform
		b = g * b
		t = g * t
		fr = g.basis * fr
	_o = b
	_len = (t - b).length()
	_u = (t - b) / maxf(_len, 0.001)
	_f = (fr - _u * fr.dot(_u)).normalized()
	_r = _u.cross(-_f).normalized()      # tırmananın sağı (yüzü merdivene dönük)


func _rung_u(k: float) -> float:
	return rung0 + k * gap


## Uzuv kaçıncı basamakta (adım n, evre p): çift a (sağ el + sol ayak) çift adımlarda, b (sol el + sağ ayak) tek
## adımlarda kalkar ve iki basamak üste geçer. Döner: [başlangıç basamağı, kalkış ilerlemesi 0..1]
func _limb(pair: int, n: int, p: float) -> Vector2:
	var low := (n % 2 == 0) == (pair == 0)
	var r := float(n) if low else float(n) + 1.0
	if low:
		return Vector2(r, smoothstep(0.2, 0.8, p))
	return Vector2(r, 0.0)


## Ayak elden sonra kalkar ve gövde yükselirken yeni basamağa basar
func _foot_q(pair: int, n: int, p: float) -> float:
	return smoothstep(0.25, 0.9, p) if (n % 2 == 0) == (pair == 0) else 0.0


func _process(delta: float) -> void:
	if state == "off" or paused or not is_instance_valid(who):
		return
	_t += delta
	_refresh()
	if state == "mantle":
		_mantle_tick(delta)
		return
	# İlerleme: tam adımda durur; hedefe doğru (yukarı ya da aşağı)
	var g := clampf(goal, 0.0, max_step())
	if absf(g - s) > 0.0001:
		s = move_toward(s, g, speed * delta * (1.0 - brace * 0.85))
	_tick += 1
	# Ucuz sürüm: kök, gövde ve baş her kare (sahne betiği kökü mantık yerine koymuş olabilir), uzuv IK'si üç karede bir
	var limbs := full or _tick % 3 == 0
	_pose(limbs)
	if limbs:
		_audit()


## Bütün gövdeyi yerleştirir: kök, gövde eğimi, kalça salınımı, baş, iki kol ve iki bacak (IK)
func _pose(limbs := true) -> void:
	if not rig or not is_instance_valid(who):
		return
	var n := int(floorf(s))
	var p := s - float(n)
	var rise := smoothstep(0.0, 1.0, p) if _driven else smoothstep(0.05, 0.85, p)
	var root_u := rung0 + _root_off + gap * (float(n) + rise)
	if peek > 0.0:
		root_u = lerpf(root_u, _len - _hip_h - 0.03, peek)     # kalça merdivenin ucunda (geçmez)
	# Kalça hareketli ayak tarafına salınır (a çiftinde sol ayak kalkar: kalça sağa)
	var dir := 1.0 if n % 2 == 0 else -1.0
	var sway := sin(p * PI) * 0.035 * dir * (1.0 - brace)
	var hip_out := 0.47 - clampf(0.53 - _arm_len, 0.0, 0.05) * 2.5 - brace * 0.03
	var sc := who.global_basis.get_scale()
	var basis := Basis(_u.cross(-_f).normalized(), _u, -_f)
	var pos := _o + _u * root_u + _f * hip_out + _r * side
	if _blend < 1.0:
		_blend = minf(1.0, _blend + get_process_delta_time() / _blend_dur) if is_inside_tree() else 1.0
		var kb := smoothstep(0.0, 1.0, _blend)
		pos = _from.lerp(pos, kb) + Vector3.UP * sin(kb * PI) * 0.15
	who.global_transform = Transform3D(basis.scaled(sc), pos)
	var body := rig.body
	if body:
		body.position = Vector3(sway, 0, 0)
		body.rotation = Vector3(LEAN + brace * 0.02, 0, -sway * 0.8)
	if rig.head:
		_look_t -= get_process_delta_time() if is_inside_tree() else 0.0
		if _look_t <= 0.0:
			_look_t = randf_range(4.0, 8.0)
			_look_down = 1.4
		_look_down = maxf(0.0, _look_down - get_process_delta_time()) if is_inside_tree() else 0.0
		var down := smoothstep(0.0, 0.3, _look_down) * smoothstep(1.4, 1.1, _look_down)
		var pitch := lerpf(-0.32, 0.45, down)
		pitch = lerpf(pitch, 0.38, brace)
		rig.head.rotation = Vector3(pitch, sway * 3.0, 0)
	if not limbs:
		return
	_slide_root = root_u
	if sliding:
		_slide_limbs(root_u)
		return
	if peek > 0.0:
		_peek_limbs(root_u)
		return
	# Uzuvlar
	for pair in 2:
		var l := _limb(pair, n, p)
		# Kol: çift 0 sağ el, çift 1 sol el; bacak: çift 0 sol ayak, çift 1 sağ ayak
		var hand_side := 1.0 if pair == 0 else -1.0
		var arm: Node3D = rig.arm_r if pair == 0 else rig.arm_l
		var elbow: Node3D = rig.elbow_r if pair == 0 else rig.elbow_l
		var leg: Node3D = rig.leg_l if pair == 0 else rig.leg_r
		var knee: Node3D = rig.knee_l if pair == 0 else rig.knee_r
		var hk0 := l.x + float(_kh)
		var hq := l.y
		var hand := _hand_at(hk0, hand_side).lerp(_hand_at(hk0 + 2.0, hand_side), hq)
		hand += _f * sin(hq * PI) * 0.12      # kalkan el merdivenden açılır (basamaklara sürtünmez)
		if arm and elbow:
			Rig.reach(arm, elbow, hand, -_u + _r * hand_side * 0.9 + _f * 0.35)
		# Ayak kolundan biraz geç kalkar (önce el tutar, sonra ayak basar)
		var fq := _foot_q(pair, n, p)
		var foot := _foot_at(l.x, -hand_side).lerp(_foot_at(l.x + 2.0, -hand_side), fq)
		foot += _f * sin(fq * PI) * 0.14 + _u * sin(fq * PI) * 0.05
		if leg and knee:
			_leg_reach(leg, knee, foot, -_f + _u * 0.35 - _r * hand_side * 0.25)
			var an := knee.get_node_or_null("Ankle") as Node3D
			if an:
				an.global_basis = Basis(_u.cross(-_f).normalized(), _u, -_f).scaled(an.global_basis.get_scale())


func _peek_limbs(root_u: float) -> void:
	# İki ayak aynı basamakta (bilek kalçanın 0,10–0,46 m altında: bacak erişiminde); bakış yarıyı geçince eller
	# dikmeleri bırakıp (beşte biri geçince) mazgalın üstünde havaya kalkar (ÖNCE'deki el sallayışı), öncesinde dikmeler boyunca yükselir
	var fk := roundf((root_u + _hip_h - 0.28 - ANKLE_UP - rung0) / gap)
	var up := smoothstep(0.2, 0.5, peek)
	for sd: float in [1.0, -1.0]:
		var arm: Node3D = rig.arm_r if sd > 0.0 else rig.arm_l
		var el: Node3D = rig.elbow_r if sd > 0.0 else rig.elbow_l
		if arm and el:
			var hu := minf(_len - 0.03, root_u + _sh_h + 0.15)
			Rig.reach(arm, el, _o + _u * hu + _r * sd * width * 0.5 + _f * 0.03, -_u + _r * sd + _f * 0.3)
			if up > 0.0:
				var wave := sin(_t * 9.0 + sd) * 0.25
				arm.rotation = arm.rotation.lerp(Vector3(-2.7 + wave, 0, sd * 0.35), up)
				el.rotation = el.rotation.lerp(Vector3(-0.35, 0, 0), up)
		var leg: Node3D = rig.leg_r if sd > 0.0 else rig.leg_l
		var knee: Node3D = rig.knee_r if sd > 0.0 else rig.knee_l
		if leg and knee:
			_leg_reach(leg, knee, _foot_at(fk, sd), -_f + _u * 0.35)
			var an := knee.get_node_or_null("Ankle") as Node3D
			if an:
				an.global_basis = Basis(_u.cross(-_f).normalized(), _u, -_f).scaled(an.global_basis.get_scale())


func _slide_limbs(root_u: float) -> void:
	for sd: float in [1.0, -1.0]:
		var arm: Node3D = rig.arm_r if sd > 0.0 else rig.arm_l
		var el: Node3D = rig.elbow_r if sd > 0.0 else rig.elbow_l
		var rail := _o + _r * sd * width * 0.5 + _f * 0.03
		if arm and el:
			# Eller dikmede omzun biraz altında; omuz merdivenin ucunu aşmışsa (tepeden kaymaya başlarken) eller havada
			var hu := root_u + _sh_h - 0.15
			Rig.reach(arm, el, rail + _u * minf(hu, _len - 0.03), -_u + _r * sd + _f * 0.3)
			if hu > _len - 0.03:
				arm.rotation = Vector3(-2.7, 0, sd * 0.35)
				el.rotation = Vector3(-0.35, 0, 0)
		var leg: Node3D = rig.leg_r if sd > 0.0 else rig.leg_l
		var knee: Node3D = rig.knee_r if sd > 0.0 else rig.knee_l
		if leg and knee:
			_leg_reach(leg, knee, rail + _u * maxf(root_u + 0.25, 0.0) + _f * 0.12 + _r * sd * 0.06, -_f + _u * 0.4)


func _hand_at(k: float, sd: float) -> Vector3:
	if rope:
		return _o + _u * (_rung_u(k) + 0.0) + _f * 0.05 + _r * sd * 0.03
	return _o + _u * (_rung_u(k) + GRIP_UP) + _f * GRIP_OUT + _r * clampf(sd * _hand_x + side, -width * 0.45, width * 0.45)


func _foot_at(k: float, sd: float) -> Vector3:
	if rope:
		# İpte ayaklar duvara (ipin arkasındaki yüz) basar: bilek ip hizasının biraz önünde
		return _o + _u * (_rung_u(k) - 0.05) + _f * 0.12 + _r * sd * 0.14
	return _o + _u * (_rung_u(k) + ANKLE_UP) + _f * ANKLE_OUT + _r * clampf(sd * FOOT_X + side * 0.6, -width * 0.4, width * 0.4)


## İki kemikli bacak IK'si: ayak bileğini (Ankle) target'a götürür, dizi pole tarafına (merdivene) büker.
## Kalça (leg) dönüşünü ve diz açısını yazar. Döner: bileğin hedefe kalan uzaklığı.
static func _leg_reach(leg: Node3D, knee: Node3D, target: Vector3, pole: Vector3) -> float:
	var an := knee.get_node_or_null("Ankle") as Node3D
	var sc := leg.global_transform.basis.get_scale().x
	var a := knee.position.length() * sc
	var b := (an.position.length() if an else 0.3) * sc
	var hp := leg.global_position
	var to := target - hp
	var want := to.length()
	var d := clampf(want, absf(a - b) + 0.02, a + b - 0.001)
	var dir := to / maxf(want, 0.0001)
	var al := acos(clampf((a * a + d * d - b * b) / (2.0 * a * d), -1.0, 1.0))
	var pz := pole - dir * pole.dot(dir)
	if pz.length() < 0.0001:
		pz = dir.cross(Vector3.RIGHT)
	pz = pz.normalized()
	var thigh := dir * cos(al) + pz * sin(al)
	var kb := PI - acos(clampf((a * a + b * b - d * d) / (2.0 * a * b), -1.0, 1.0))
	var y := -thigh
	var z := (pz - thigh * pz.dot(thigh)).normalized()
	var wb := Basis(y.cross(z), y, z)
	var par := leg.get_parent() as Node3D
	var pb := par.global_transform.basis.orthonormalized() if par else Basis()
	leg.basis = pb.inverse() * wb
	knee.rotation = Vector3(kb, 0, 0)
	return absf(want - d)


func _mantle_tick(delta: float) -> void:
	var m := _mantle
	m["t"] = float(m["t"]) + delta
	var k := clampf(float(m["t"]) / float(m["dur"]), 0.0, 1.0)
	var from: Transform3D = m["from"]
	var to: Vector3 = m["to"]
	var face: Vector3 = m["face"]
	face.y = 0.0
	if face.length() < 0.01:
		face = -_f
		face.y = 0.0
	var yaw := atan2(face.x, face.z)
	var sc := who.global_basis.get_scale()
	var up_b := Basis(Vector3.UP, yaw)
	var lad_b := from.basis.orthonormalized()
	# Yol: önce merdiven boyunca yukarı (kalça tepeye), sonra tepeden içeri (yay), sonra ayakta
	var top := _o + _u * _len
	var mid := top + Vector3(0, 0.25, 0) - _f * 0.25 - Vector3(0, _hip_h, 0)
	var k1 := smoothstep(0.0, 0.45, k)
	var k2 := smoothstep(0.35, 1.0, k)
	var p := from.origin.lerp(mid, k1).lerp(to, k2)
	p += Vector3.UP * sin(k2 * PI) * 0.12
	var bq := Quaternion(lad_b).slerp(Quaternion(up_b), smoothstep(0.3, 0.9, k))
	who.global_transform = Transform3D(Basis(bq).scaled(sc), p)
	if rig.body:
		rig.body.position = rig.body.position.lerp(Vector3.ZERO, 0.2)
		rig.body.rotation = Vector3(lerpf(0.5, 0.0, smoothstep(0.5, 1.0, k)) * sin(k * PI), 0, 0)
	# Eller tepede (merdivenin ucu / mazgal ağzı) tutar; ikinci yarıda bırakır
	if k < 0.75:
		for sd: float in [-1.0, 1.0]:
			var arm: Node3D = rig.arm_r if sd > 0.0 else rig.arm_l
			var el: Node3D = rig.elbow_r if sd > 0.0 else rig.elbow_l
			if arm and el:
				Rig.reach(arm, el, top + _r * sd * 0.3 + _u * 0.02, -_u + _r * sd + _f * 0.3)
	else:
		for arm: Node3D in [rig.arm_l, rig.arm_r]:
			if arm:
				arm.rotation = arm.rotation.lerp(Vector3(-0.2, 0, 0), 0.15)
		for el: Node3D in [rig.elbow_l, rig.elbow_r]:
			if el:
				el.rotation = el.rotation.lerp(Vector3(-0.2, 0, 0), 0.15)
	# Bacak: önce sağ bacak yukarı atılır (diz göğüse), sonra sol; sonda ikisi düz
	var lift_r := sin(clampf((k - 0.25) / 0.45, 0.0, 1.0) * PI)
	var lift_l := sin(clampf((k - 0.5) / 0.4, 0.0, 1.0) * PI)
	if rig.leg_r:
		rig.leg_r.rotation = Vector3(-1.6 * lift_r, 0, 0.15 * lift_r)
	if rig.knee_r:
		rig.knee_r.rotation = Vector3(1.6 * lift_r, 0, 0)
	if rig.leg_l:
		rig.leg_l.rotation = Vector3(-1.2 * lift_l, 0, -0.1 * lift_l)
	if rig.knee_l:
		rig.knee_l.rotation = Vector3(1.4 * lift_l, 0, 0)
	if rig.head:
		rig.head.rotation = rig.head.rotation.lerp(Vector3(0.1, 0, 0), 0.1)
	if k >= 1.0:
		who.global_transform = Transform3D(up_b.scaled(sc), to)
		release(true, "")


# ---------------------------------------------------------------- denetim

func _audit() -> void:
	if not rig or state != "climb" or _blend < 1.0:
		return
	var n := int(floorf(s))
	var p := s - float(n)
	# Gövde ekseni ile merdiven ekseni
	if rig.body:
		var ax := rig.body.global_basis.y.normalized()
		var ang := rad_to_deg(acos(clampf(ax.dot(_u), -1.0, 1.0)))
		if ang > 8.0:
			_report("axis_deg", ang)
		var chest := rig.body.global_transform * Vector3(0, CHEST_H, 0)
		var gap_m := (chest - _o).dot(_f) / _scale - CHEST_R
		if rope:
			gap_m += 0.0
		if gap_m < 0.15 or gap_m > 0.35:
			_report("chest_gap", gap_m)
	for pair in 2:
		var l := _limb(pair, n, p)
		var slide_hold := sliding and _slide_root + _sh_h - 0.15 <= _len - 0.03
		var holding := slide_hold or (not sliding and peek > 0.0 and peek < 0.2) or (peek <= 0.0 and (l.y <= 0.0 or l.y >= 1.0))
		var elbow: Node3D = rig.elbow_r if pair == 0 else rig.elbow_l
		if holding and elbow:
			var hm: Vector3 = elbow.get_meta("hand", Vector3(0, -0.27, 0.01))
			var hp := elbow.global_transform * hm
			var dh := _grip_dist(hp)
			if dh > 0.06:
				_report("hand_" + ("r" if pair == 0 else "l"), dh)
		var knee: Node3D = rig.knee_l if pair == 0 else rig.knee_r
		var fq := _foot_q(pair, n, p)
		if knee and (fq <= 0.0 or fq >= 1.0 or peek > 0.0) and not rope and not sliding:
			var an := knee.get_node_or_null("Ankle") as Node3D
			var sp := (an if an else knee).global_transform * SOLE
			var df := _rung_dist(sp)
			if df > 0.06:
				_report("foot_" + ("l" if pair == 0 else "r"), df)
	# Merdivenin ucunu geçen: kalça tepeden yukarıda
	var hip_u := (who.global_position - _o).dot(_u) + _hip_h * _scale
	if hip_u > _len + 0.05:
		_report("over_top", hip_u - _len)


## Noktanın en yakın basamağa (ya da dikmeye) uzaklığı
func _grip_dist(pt: Vector3) -> float:
	var d := _rung_dist(pt)
	if rope or width <= 0.0:
		return d
	var q := pt - _o
	var u := clampf(q.dot(_u), 0.0, _len)
	for sd: float in [-0.5, 0.5]:
		var c := _o + _u * u + _r * sd * width
		d = minf(d, pt.distance_to(c))
	return d


func _rung_dist(pt: Vector3) -> float:
	var q := pt - _o
	var u := q.dot(_u)
	if rope:
		# İp: ip ekseni (merdiven ekseni) çizgisine uzaklık
		var uc := clampf(u, 0.0, _len)
		return pt.distance_to(_o + _u * uc)
	var k := clampf(roundf((u - rung0) / gap), 0.0, floorf((_len - rung0) / gap))
	var c := _o + _u * _rung_u(k)
	var x := clampf(q.dot(_r), -width * 0.5, width * 0.5)
	return pt.distance_to(c + _r * x)


func _report(what: String, v: float) -> void:
	audit_lines += 1
	var key := what
	var now := Time.get_ticks_msec()
	if int(_audit_next.get(key, 0)) > now:
		return
	_audit_next[key] = now + 1000
	var t := tag
	if t == "" and who.is_inside_tree() and who.get_tree().current_scene:
		var sc: Script = who.get_tree().current_scene.get_script()
		t = sc.resource_path.get_file().get_basename() if sc else "?"
	print("CLIMBAUDIT %s %s %s=%.3f" % [t, who.name, what, v])
