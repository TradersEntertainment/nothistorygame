class_name Duelist
extends Node3D
## Kılıçlı rakip. Yönlü dövüş: sol / sağ / üst (oyuncunun bakışına göre: "sol" = oyuncunun solundan gelen).
## Muhafız (guard) bir yöndedir; oyuncunun nişan yönüne tepki süresiyle döner. Saldırıdan önce kolunu o yöne kaldırır
## (WINDUP: HUD'da kırmızı ok), sonra vurur (STRIKE anında Duel sonucu çözer). Savuşturulursa sendeler (STAGGER).
## Görünüş Person'dan; kollar dövüş sırasında elle sürülür (rig.lock).
## Tekme: sendeler (geri sarsak adımlar, kalkan yana savrulur, arkası duvarsa çarpar) ya da saldırı hazırlığındayken,
## sendelerken veya canı azken yere serilir (DOWN: sırtüstü yatar, kalkar). Ölen yere yığılır ve öyle kalır: gözler X,
## kılıç düşer, ceset zemine oturur (eğime uyar), bütün işlem durur; çok ceset birikince en eskisi görüş dışında silinir.

signal died(d: Duelist)

enum St { IDLE, WINDUP, STRIKE, RECOVER, STAGGER, FLINCH, DEAD, DOWN }
const DIR_LEFT := 0
const DIR_RIGHT := 1
const DIR_TOP := 2
const RANGE := 2.1

var body: Person
var sword: Node3D
var shield: Node3D
var duel: Node               # Duel denetleyicisi (vuruş çözümü)
var target: Node3D           # oyuncu
var hp := 100.0
var max_hp := 100.0
var skill := 0.5             # 0..1: muhafız tepkisi, saldırı hızı, aldatma
var damage := 18.0
var name_key := "SPK_SOLDIER"
var state := St.IDLE
var dir := DIR_TOP           # saldırı yönü (WINDUP/STRIKE)
var guard := DIR_TOP         # muhafız yönü
var windup_time := 0.8
var _t := 0.0                # durum sayacı
var _think := 1.4            # bir sonraki saldırıya kadar
var _guard_want := DIR_TOP
var _guard_t := 0.0
var _strafe := 1.0
var _strafe_t := 2.0
var _feint := false
var _y := 0.0
var anim: LimbAnim
var _moving := 0.0
## Saldırı yönü → hazır animasyon (oyuncunun gözünden: soldan gelen darbe B, sağdan A, yukarıdan C)
const ATTACK_CLIP := {0: "Sword_Regular_B", 1: "Sword_Regular_A", 2: "Sword_Regular_C"}
## Yere serilme: düşüş (Hit_Knockback ~0,85 sn), yatış (bitirici penceresi), kalkış (Roll'un son kısmı)
const DOWN_LIE := 2.1
const DOWN_GETUP := 0.75
## Bitirici sürerken Duel bu rakibi sürer (yapay zekâ ve animasyon seçimi durur)
var finishing := false
## Sendelemenin sebebi: "parry" (savuşturma), "kick" (tekme) — bitirici türünü seçer
var stagger_kind := ""
var _kb := Vector3.ZERO        # geri savrulma hızı (m/sn), sürtünmeyle söner
var _lean := 0.0               # ek gövde eğimi (LimbAnim.lean)
var _landed := false
var _shield_mount: Node3D
var _final_clip := ""
var _settled := false
## Cesetler: sahnede en çok bu kadar; fazlası (en eskiler) oyuncunun görüşünden çıkınca yere batıp silinir
const CORPSE_CAP := 12
static var _corpses: Array = []
var _dodge_to := Vector3.INF

## Savaş katmanı (Melee): iki tarafın gerçek çarpışması. Hedef oyuncu ya da başka bir düellocu olabilir (dost ↔ düşman).
var team := 1                    # 0: oyuncunun tarafı (dost), 1: düşman
var hold_back := false           # oyuncunun çevresinde sırasını bekler: halkada dolaşır, saldırmaz
## Giriş yolu: gedikten, sur yolunun ucundan koşarak gelir (yoktan belirmez); yol bitmeden dövüşe girmez
var path: Array[Vector3] = []
var run_speed := 4.2
var _path_best := INF
var _path_stuck := 0.0
var swap_t := 0.0                # Melee: hedef değiştirmeden önce bekleme
var npc_killed := false          # bir NPC'nin darbesiyle düştü (oyuncunun öldürmesi sayılmaz)
var _hit_by_player := 0.0        # son darbeyi oyuncu vurduysa >0 (sn): surdan düşen oyuncunun hanesine yazılır
## Vura vura itme: art arda yenen darbeler (savuşturulsa da) geri iter; üçüncüde sendeleyip savrulur
var _streak := 0
var _streak_t := 0.0
## Kenardan düşüş (sur yolu, mazgal aralığı, küpeşte): balistik yay, çığlık, yere çarpma; düşen ölür
var _falling := false
var _fall_v := Vector3.ZERO
var _fall_t := 0.0
var _fall_over := false
var water_y := -INF              # altında su varsa (güverte): düşen suya gömülür
## Merdivenden sura çıkış: basamak basamak tırmanır, mazgaldan atlar (taş tozu, nara); tırmanırken merdiven itilirse düşer
var _climb := {}
## Ayaklanma: oturan, çömelen, iş başındaki asker kalkıp kılıcını çeker; bu süre bitmeden dövüşmez
var _rise_t := 0.0


func _init(look: Dictionary, blade := "kilij", p_skill := 0.5, with_shield := false) -> void:
	skill = p_skill
	body = Person.new(look)
	body.set_meta("no_talk", true)
	add_child(body)
	windup_time = lerpf(0.95, 0.5, skill)
	set_meta("blade", blade)
	set_meta("with_shield", with_shield)


func _ready() -> void:
	_y = position.y
	add_to_group("sight_dodgers")       # konuşanın önünden çekilir (dodge)
	body.set_meta("no_chat", true)
	body.set_meta("no_yield", true)
	# Yerleştirildikten sonra zemine otur (StoryDuel konumu oyuncunun yüksekliğinden verir: moloz, set, basamak)
	(func(): global_position.y = _ground_y()).call_deferred()
	# Kılıç sağ ön kola, kalkan sol ön kola
	var er: Node3D = body.rig.elbow_r if body.rig else null
	if er:
		var mount := Node3D.new()
		mount.position = Vector3(0, -0.26, 0.02)
		mount.rotation_degrees = Vector3(90, 0, 0)
		er.add_child(mount)
		sword = Blades.kilij(mount) if String(get_meta("blade")) == "kilij" else Blades.spathion(mount)
		sword.scale = Vector3.ONE * 1.25
	var el: Node3D = body.rig.elbow_l if body.rig else null
	if el and bool(get_meta("with_shield")):
		var sm := Node3D.new()
		sm.position = Vector3(0, -0.2, 0.08)
		sm.rotation_degrees = Vector3(0, 0, 0)
		el.add_child(sm)
		shield = Blades.shield(sm, Color("7a2a24"))
		_shield_mount = sm
	if body.rig:
		body.rig.lock = 1
		# Hazır iskelet animasyonları kendi eklemlerimize (LimbAnim): duruş, saldırı, siper, darbe, ölüm
		anim = LimbAnim.new()
		body.add_child(anim)
		anim.bind(body.rig)
		anim.ground_mode = 1        # hiçbir pozda zemine gömülmez
		anim.finished_clip.connect(_on_clip_done)
		anim.play("Idle_Shield_Loop" if shield else "Sword_Idle")


func alive() -> bool:
	return state != St.DEAD


## Saldırının ne kadarı doldu (HUD'daki kırmızı okun dolumu): 0..1, WINDUP dışında -1.
func windup_progress() -> float:
	return clampf(_t / windup_time, 0.0, 1.0) if state == St.WINDUP else -1.0


func time_to_impact() -> float:
	return windup_time - _t if state == St.WINDUP else 99.0


## Oyuncunun vuruşu geldi (Duel çağırır). from: vuranın yeri (geri itme yönü). flank: rakip başkasıyla (dost askerle)
## çarpışırken yandan/arkadan gelen darbe: muhafız tutmaz, daha ağır.
func take_swing(from_dir: int, dmg: float, from := Vector3.INF, flank := false) -> String:
	if state == St.DEAD or _falling:
		return "miss"
	_hit_by_player = 3.0
	if state == St.DOWN:
		# Yerde yatana vuruş: savunmasız, ağır; kalkmaz (yatış sürer)
		hp -= dmg * 1.6
		Vfx.dust(get_parent_node_3d(), global_position + Vector3(0, 0.3, 0), 0.25)
		if hp <= 0.0:
			_die()
			return "kill"
		_lean = 0.2
		return "hit"
	if state in [St.IDLE, St.RECOVER] and guard == from_dir and not flank:
		_t = 0.0
		Audio.sfx("kick_metal", -6.0, 1.5)
		_pushed(from, 1.6)
		return "blocked"
	var mult := (1.6 if state == St.STAGGER else 1.0) * (1.4 if flank else 1.0)
	hp -= dmg * mult
	Vfx.dust(get_parent_node_3d(), global_position + Vector3(0, 1.3, 0), 0.25)
	if hp <= 0.0:
		_die()
		return "kill"
	state = St.FLINCH
	_t = 0.0
	_pushed(from, 2.6)
	return "hit"


## Darbeyle geri itilme (savuşturulsa da): kısa bir savrulma. Art arda üçüncü darbede sendeleyip savrulur (arkası
## mazgalsa, küpeşteyse üstünden devrilebilir: _edge_fall).
func _pushed(from: Vector3, amount: float) -> void:
	if from == Vector3.INF or state in [St.DEAD, St.DOWN] or finishing:
		return
	var away := global_position - from
	away.y = 0.0
	if away.length() < 0.01:
		return
	away = away.normalized()
	_streak = _streak + 1 if _streak_t > 0.0 else 1
	_streak_t = 1.8
	if _streak >= 3:
		_streak = 0
		state = St.STAGGER
		stagger_kind = "kick"
		_t = -0.1
		_kb = away * 4.4
		_lean = -0.5
		if anim:
			anim.fade = 0.05
			anim.play("Idle_Shield_Break", 1.35, false)
		_shield_knock()
		Audio.sfx_at("land_thud", self, -6.0)
		return
	_kb += away * amount


## Bir NPC'nin (dost ya da düşman düellocu) darbesi indi. Muhafızı o yöndeyse tutar (çınlama, kıvılcım, hafif geri
## itilme), değilse yer (kan, sendeleme, geri itilme); canı biterse düşer. Döner: "blocked" | "hit" | "kill" | "miss".
func npc_hit(from_dir: int, dmg: float, from: Vector3) -> String:
	if state == St.DEAD or _falling or finishing or not _climb.is_empty():
		return "miss"
	var away := global_position - from
	away.y = 0.0
	away = away.normalized() if away.length() > 0.01 else -global_transform.basis.z
	var chest := global_position + Vector3(0, 1.3, 0)
	# Kalabalık çarpışmada her darbe tutulmaz (yan yana dövüşenler, ayak kayması): usta olan daha çok tutar
	if state in [St.IDLE, St.RECOVER] and guard == from_dir and randf() < 0.4 + skill * 0.4:
		_t = 0.0
		_kb += away * 1.3
		Audio.sfx_at("sword_clash", self, -8.0)
		Vfx.sparks(get_parent_node_3d(), chest - away * 0.4, 0.6)
		return "blocked"
	var mult := 1.6 if state == St.DOWN else (1.4 if state == St.STAGGER else 1.0)
	hp -= dmg * mult
	Duel.blood(get_parent_node_3d(), chest, away, 0.6)
	Audio.sfx_at("land_thud", self, -12.0)
	if hp <= 0.0:
		npc_killed = true
		_hit_by_player = 0.0
		_kb = away * 2.4
		_die()
		return "kill"
	if state != St.DOWN:
		state = St.FLINCH
		_t = 0.0
		_kb += away * 2.2
	return "hit"


## Bu düellocunun darbesi bir düellocuya (NPC) indi.
func _strike_npc(t: Duelist) -> void:
	if not is_instance_valid(t) or not t.alive():
		return
	var to := t.global_position - global_position
	to.y = 0.0
	if to.length() > RANGE + 1.1 or absf(t.global_position.y - global_position.y) > 1.2:
		return
	# Sersemlemiş ya da toparlanan rakibi ara sıra kalkanla iter / tekmeler: rakip sendeler, arkası boşluksa düşer
	if t.state in [St.STAGGER, St.RECOVER] and randf() < 0.25 + skill * 0.2:
		var r := t.kicked(global_position)
		if r != "":
			Audio.sfx_at("land_thud", t, -6.0)
			Vfx.dust(get_parent_node_3d(), t.global_position + Vector3(0, 1.0, 0), 0.18)
			return
	t.npc_hit(dir, damage, global_position)


## Tekme yedi. Döner: "stagger" (geri sendeler, kalkanı yana savrulur, saldırısı yarıda kalır) ya da "down" (saldırı
## hazırlığındayken, zaten sendelerken ya da canı azken: sırtüstü yere serilir). "" etkisiz.
func kicked(from: Vector3) -> String:
	if state in [St.DEAD, St.DOWN] or finishing:
		return ""
	var back := global_position - from
	back.y = 0.0
	back = back.normalized() if back.length() > 0.01 else -global_transform.basis.z
	if state in [St.WINDUP, St.STAGGER] or hp < max_hp * 0.35:
		knock_down(back * 5.6)
		return "down"
	state = St.STAGGER
	stagger_kind = "kick"
	_t = -0.3              # tekme sersemliği savuşturmadan uzun
	_kb = back * 4.6       # ~1,2 m geri, sarsak adımlarla
	_lean = -0.55          # gövde geriye savrulur
	if anim:
		anim.fade = 0.05
		anim.play("Idle_Shield_Break", 1.35, false)
	_shield_knock()
	return "stagger"


## Sırtüstü yere serilir: geriye savrulur, yere çarpar (toz, gümleme), DOWN_LIE yatar, sonra kalkar.
func knock_down(push: Vector3) -> void:
	state = St.DOWN
	stagger_kind = "down"
	_t = 0.0
	_kb = push
	_lean = 0.0
	_landed = false
	if anim:
		anim.fade = 0.05
		anim.ground_mode = 1
		anim.body_amount = 1.0      # yerde gövde tam yatar (0,7'de göğüs yerden 30° kalkık, havada kalıyordu)
		anim.play("Hit_Knockback", 1.0, false)
	_shield_knock()


## Kalkan kolu yana savrulur, sonra toparlanır (tekme kalkanı açar).
func _shield_knock() -> void:
	if _shield_mount == null:
		return
	var tw := _shield_mount.create_tween()
	tw.tween_property(_shield_mount, "rotation_degrees", Vector3(-35, -70, 40), 0.1).set_ease(Tween.EASE_OUT)
	tw.tween_property(_shield_mount, "rotation_degrees", Vector3.ZERO, 0.8).set_delay(0.5).set_trans(Tween.TRANS_SINE)


## Savuşturuldu: sendeler, açık kalır.
func parried() -> void:
	if state in [St.DEAD, St.DOWN] or finishing:
		return
	state = St.STAGGER
	stagger_kind = "parry"
	_t = 0.0
	_lean = -0.3
	if anim:
		anim.fade = 0.06
		anim.play("Idle_Shield_Break", 1.2, false)


func _die() -> void:
	state = St.DEAD
	hp = 0.0
	_unspeak()
	if has_meta("yield"):
		# Hikâye düellosu: ölmez, kılıcını bırakıp geri çekilir
		if sword:
			var sw := sword
			var at := sw.global_transform
			sw.get_parent().remove_child(sw)
			get_parent().add_child(sw)
			sw.global_transform = at
			var st := sw.create_tween()
			st.tween_property(sw, "global_position:y", global_position.y + 0.05, 0.4).set_ease(Tween.EASE_IN)
			st.parallel().tween_property(sw, "rotation:z", PI / 2.0, 0.4)
		# Geri çekilme yolu: arkası (duvar, barikat, sandık) kapalıysa yana açılır, zemini izler (eskiden 7 m dümdüz
		# geriye kayıp surun ve barikatın içinden geçiyordu)
		var from := global_position
		var to := _retreat_target(global_transform.basis.z)
		var secs := 2.2 * clampf(from.distance_to(to) / 7.0, 0.35, 1.0)
		var tw := create_tween()
		tw.tween_method(func(k: float): _retreat_step(from.lerp(to, k)), 0.0, 1.0, secs).set_delay(0.4)
		tw.parallel().tween_property(self, "scale", Vector3.ONE * 0.98, secs)
		tw.tween_callback(func(): visible = false)
		died.emit(self)
		return
	kill()
	collapse("Death01", 0.0, 1.25)


## Yenilen (geri çekilen ya da bitiriciyle ölen) konuşmacı olmaktan çıkar: sonraki replikte kartta yerde yatan ceset değil,
## ayaktaki biri görünür (30o'da bitiriciyle ölen savunucu "İmparator geldi!" ve tüfekçinin repliğinde kartta kalıyordu)
func _unspeak() -> void:
	if body and body.has_meta("spk"):
		body.remove_meta("spk")


## Öldü: durum, X gözler, kılıç (ve kalkan) elden düşer, oyuncu cesede takılmaz. Yere yığılmayı collapse() oynatır
## (bitiricide ikisi arasında kısa bir an geçer: kılıca saplanmış duruş). by_finisher: hikâyede de gerçekten ölür.
func kill(by_finisher := false) -> void:
	if state == St.DEAD and _final_clip != "":
		return
	state = St.DEAD
	hp = 0.0
	_unspeak()
	if by_finisher and has_meta("yield"):
		remove_meta("yield")
	body.dead_face()
	body.set_meta("no_block", true)
	body.set_meta("corpse", true)      # yerde yatan: üstünden geçilir; kalabalık ve zemin denetimi ayakta biri saymaz
	body.set_meta("no_talk", true)
	drop_weapons(_kb)
	_final_clip = "?"
	died.emit(self)


## Ölü yere yığılır: clip (from sn'den) oynar; bitince ceset zemine oturur ve donar. Yere çarptığı an toz ve gümleme.
func collapse(clip := "Death01", from := 0.0, speed := 1.25) -> void:
	if _settled:
		return
	_final_clip = clip
	if anim == null:
		var tw := create_tween().set_parallel()
		tw.tween_property(body, "rotation:x", deg_to_rad(-88), 0.6).set_ease(Tween.EASE_IN)
		tw.tween_property(body, "position:y", 0.22, 0.6)
		tw.chain().tween_callback(_settle)
		return
	anim.ground_mode = 1
	anim.body_amount = 1.0
	if anim.clip == clip and not anim.loop:
		# Zaten bu klipte (yere serilmiş): bitmişse hemen oturur, bitmemişse sonunda
		if anim.done():
			_settle()
		return
	anim.create_tween().tween_property(anim, "lean", 0.0, 0.3)
	anim.fade = 0.15
	anim.play(clip, speed, false, from)
	# Yere çarpma anı (kalça yere indiğinde): Death01 ~1,15 sn, Hit_Knockback ~0,4 sn
	var hit_t: float = {"Death01": 1.15, "Hit_Knockback": 0.4}.get(clip, 0.5)
	if hit_t > from:
		# Düğüme bağlı tween: ceset silinirse zamanlayıcı da gider
		var tw := create_tween()
		tw.tween_interval((hit_t - from) / speed)
		tw.tween_callback(func():
			Audio.sfx("land_thud", -5.0, 0.7)
			Vfx.dust(get_parent_node_3d(), global_position + Vector3(0, 0.15, 0) + global_transform.basis.z * -0.6, 0.35))


func _on_clip_done() -> void:
	if state == St.DEAD and anim and anim.clip == _final_clip and not _settled:
		_settle()


## Ceset son hâlini alır: zemine (eğime) oturur, en alçak uzuv tam zeminde; sonra bütün işlem durur (kıpırdamaz).
func _settle() -> void:
	if _settled or not is_inside_tree():
		return
	_settled = true
	_kb = Vector3.ZERO
	global_position.y = _ground_y()
	_fit_slope()
	if anim:
		anim.ground_mode = 2
		anim.speed = 0.0
	# Birkaç kare zemine otursun, sonra dondur (düğüme bağlı tween: sahne kapanırsa yarıda kalmaz, hata vermez)
	var tw := create_tween()
	tw.tween_interval(0.06)
	tw.tween_callback(_freeze)


func _freeze() -> void:
	_lift_over_ground()
	_blood_pool()
	if anim:
		anim.set_process(false)
	set_process(false)
	_add_corpse(self)


## Eğimli zeminde ceset yamaca yatar: kök düğüm zemin normaline döner (en çok ~25°).
func _fit_slope() -> void:
	var p := global_position
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 1.0, 0), p + Vector3(0, -2.0, 0), 1)
	q.exclude = _excl()
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return
	var n := (hit["normal"] as Vector3).normalized()
	if n.y < 0.9:
		n = Vector3.UP.slerp(n, clampf(0.42 / Vector3.UP.angle_to(n), 0.0, 1.0)) if Vector3.UP.angle_to(n) > 0.42 else n
	var b := global_transform.basis.orthonormalized()
	var axis := Vector3.UP.cross(n)
	if axis.length() > 0.001:
		b = Basis(axis.normalized(), Vector3.UP.angle_to(n)) * b
	global_transform.basis = b


## Gövdenin altında zemin daha yüksekse (moloz, basamak) gövde o çıkıntının üstüne kalkar: hiçbir yeri gömülmez.
func _lift_over_ground() -> void:
	if body.rig == null:
		return
	var space := get_world_3d().direct_space_state
	var up := global_transform.basis.y.normalized()
	var lift := 0.0
	for n: Node3D in [body.rig.head, body.rig.body, body.rig.knee_l, body.rig.knee_r]:
		if n == null:
			continue
		var at := n.global_position if n != body.rig.body else n.global_transform * Vector3(0, 1.0, 0)
		var q := PhysicsRayQueryParameters3D.create(at + Vector3(0, 0.8, 0), at + Vector3(0, -1.0, 0), 1)
		q.exclude = _excl()
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			continue
		var ground := hit["position"] as Vector3
		# Zemin, gövdenin yerel düzlemine göre ne kadar yukarıda (gövde yarıçapı ~0,1–0,2 m payıyla)
		lift = maxf(lift, (ground - global_position).dot(up) - (at - global_position).dot(up) + 0.12)
	if lift > 0.01:
		global_position += up * minf(lift, 0.6)


## Toon kan: cesedin altında yavaşça büyüyen koyu kırmızı leke (ince, mat).
func _blood_pool() -> void:
	if body.rig == null or not is_inside_tree():
		return
	var at := body.rig.body.global_transform * Vector3(0, 1.0, 0)
	var pool := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.5
	cm.bottom_radius = 0.5
	cm.height = 0.01
	cm.radial_segments = 18
	pool.mesh = cm
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.3, 0.03, 0.04, 0.9)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED     # gökyüzünü yansıtıp mora çalmasın: düz, mat

	pool.material_override = m
	pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(pool)
	pool.global_position = Vector3(at.x, global_position.y, at.z) + global_transform.basis.y * 0.012
	pool.scale = Vector3(0.05, 1.0, 0.05)
	pool.create_tween().tween_property(pool, "scale", Vector3(1.0, 1.0, 0.75), 6.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Kılıç ve kalkan elden düşer: dünyaya geçer, hafif savrulup yere yatar, metal tıngırtısı.
func drop_weapons(push := Vector3.ZERO) -> void:
	var i := 0
	for w: Node3D in [sword, shield]:
		if w == null or not is_instance_valid(w) or not is_inside_tree():
			continue
		w.reparent(get_parent())
		var from := w.global_transform
		var side := global_transform.basis.x * (0.5 if i == 0 else -0.45)
		var to_p := from.origin + side + push.limit_length(2.0) * 0.25
		var q := PhysicsRayQueryParameters3D.create(to_p + Vector3(0, 1.0, 0), to_p + Vector3(0, -3.0, 0), 1)
		q.exclude = _excl()
		var hit := get_world_3d().direct_space_state.intersect_ray(q)
		to_p.y = ((hit["position"] as Vector3).y if not hit.is_empty() else global_position.y) + (0.03 if i == 0 else 0.05)
		# Yatık: kılıcın namlusu (+Y) ve kalkanın yüzü (+Z) yataya / yukarı
		var flat := Basis(Vector3.UP, randf() * TAU) * (Basis(Vector3.RIGHT, PI / 2.0) if i == 0 else Basis(Vector3.RIGHT, -PI / 2.0))
		var q0 := from.basis.orthonormalized().get_rotation_quaternion()
		var q1 := flat.get_rotation_quaternion()
		var scl := from.basis.get_scale()
		var tw := w.create_tween()
		tw.tween_method(func(k: float):
			var o := from.origin.lerp(to_p, k)
			o.y += sin(k * PI) * 0.25
			w.global_transform = Transform3D(Basis(q0.slerp(q1, k)).scaled(scl), o), 0.0, 1.0, 0.5).set_ease(Tween.EASE_IN)
		tw.tween_callback(Audio.sfx.bind("kick_metal", -14.0, 0.75 if i == 0 else 0.55))
		i += 1
	sword = null
	shield = null


## Yeni bir tablo kurulurken (ara sahne, saatler sonrası): dövüşte olmayan düellocular (dövüşten sonra nefeslenen
## dostlar) kalkar; yeni dizilen kalabalığın (yol boyu yeniçeriler, alay) içinde dikilmesinler. Cesetler kalır.
## Konuşma sırasında görüş çizgisi (Hud._clear_sightline, "sight_dodgers"): dövüşmeyen düellocu kameradan konuşanın
## başına uzanan çizginin üstündeyse yana çekilir. Bölüm 20'de dövüşten sonra nefeslenen dost asker Giustiniani'nin
## önünde kalıyor, komutan konuşurken görünmüyordu (VISAUDIT personhidden).
func dodge(eye: Vector3, head: Vector3, speaker: Node3D) -> void:
	# Yenilip geri çekilen hikâye rakibi de çekilir (22o'da yenilen oyuncunun önünden geçerken Hasan'ı kapatıyordu)
	var retreating := state == St.DEAD and has_meta("yield") and not has_meta("retreat_stop")
	if (not retreating and (target != null or state == St.DEAD or state == St.DOWN)) or body == null or not body.visible \
			or not is_inside_tree() or speaker == body or is_ancestor_of(speaker):
		return
	var here := global_position
	var flat := Vector3(head.x - eye.x, 0, head.z - eye.z)
	if flat.length() < 0.5:
		return
	var dir := flat.normalized()
	var raw := (here - eye).dot(dir)
	if raw <= 0.0 or raw >= flat.length():
		return
	var foot := Vector3(eye.x, here.y, eye.z) + dir * raw
	var off := Vector3(here.x - foot.x, 0, here.z - foot.z)
	if off.length() > 1.0:
		return
	var side := off.normalized() if off.length() > 0.05 else dir.cross(Vector3.UP)
	# Önce sıkı (düz zemin, kimsenin dibi değil), olmazsa daha uzak ve gevşek (moloz yamacı, kalabalık gedik): yerinde
	# kalıp konuşanı kapatmasın. 20'nin sonunda (zor zorluk) gedikte kalan dost düellocu Giustiniani'yi kapatıyordu.
	var to := _dodge_spot(foot, side, here.y, true)
	if to == Vector3.INF:
		to = _dodge_spot(foot, side, here.y, false)
	if to != Vector3.INF:
		if retreating:
			# Geri çekilme yolu yana kayar (adım adım; testte hemen)
			var d := to - global_position
			d.y = 0.0
			if GameState.autotest:
				global_position = to
				set_meta("retreat_dev", get_meta("retreat_dev", Vector3.ZERO) + d)
			else:
				set_meta("retreat_dodge", get_meta("retreat_dodge", Vector3.ZERO) + d)
		elif GameState.autotest:
			global_position = to
		else:
			_dodge_to = to
		return


## Konuşanın önünden çekilecek yer: çizgiden yana 1,5 m'den başlayıp uzaklaşan adaylar. strict: düz zemin (≤ 0,8 m
## fark), gövde payı 0,25, kalabalık 0,6; değilse yamaç (≤ 1,5 m), 0,18 ve 0,35, 4,5 m'ye kadar. Bulunamazsa INF.
func _dodge_spot(foot: Vector3, side: Vector3, y0: float, strict: bool) -> Vector3:
	var steps: Array = [1.0, -1.0, 1.6, -1.6] if strict else [1.0, -1.0, 1.6, -1.6, 2.2, -2.2, 3.0, -3.0]
	for k: float in steps:
		var to := foot + side * k * 1.5
		var gy := Unclip.floor_y(self, to, 1.0 if strict else 1.6, 2.0)
		if is_nan(gy) or absf(gy - y0) > (0.8 if strict else 1.5):
			continue
		to.y = gy
		if Unclip.in_solid(self, to, 0.25 if strict else 0.18) or Unclip.crowded(body, to, 0.6 if strict else 0.35):
			continue
		return to
	return Vector3.INF


static func dismiss_idle(root: Node) -> void:
	for n in root.find_children("*", "Node3D", true, false):
		if n is Duelist and is_instance_valid(n) and (n as Duelist).target == null and (n as Duelist).state != St.DEAD:
			n.queue_free()


## Ceset sayacı: sınır aşılınca en eski ceset oyuncunun görüşünden çıkınca batıp silinir.
static func _add_corpse(d: Node3D) -> void:
	_corpses = _corpses.filter(func(c): return is_instance_valid(c))
	_corpses.append(d)
	while _corpses.size() > CORPSE_CAP:
		var old: Duelist = _corpses.pop_front()
		old._fade_when_unseen()


func _fade_when_unseen() -> void:
	if not is_inside_tree():
		return
	# Yarım saniyede bir bakar (düğüme bağlı Timer): görüşteyse bekler
	var tm := Timer.new()
	tm.wait_time = 0.5
	tm.autostart = true
	add_child(tm)
	tm.timeout.connect(func():
		var cam := get_viewport().get_camera_3d()
		if cam == null or not cam.is_position_in_frustum(global_position + Vector3(0, 0.3, 0)) \
				or cam.global_position.distance_to(global_position) > 35.0:
			tm.stop()
			_sink())
	tm.timeout.emit()


func _sink() -> void:
	var tw := create_tween()
	tw.tween_property(self, "global_position:y", global_position.y - 0.7, 1.5)
	tw.tween_callback(queue_free)


func _process(delta: float) -> void:
	if _falling:
		_fall_tick(delta)
		return
	if state == St.DEAD:
		_knockback(delta)        # bitiricide savrulan ceset kayar, sonra durur (_settle işlemi kapatır)
		return
	_hit_by_player = maxf(0.0, _hit_by_player - delta)
	_streak_t = maxf(0.0, _streak_t - delta)
	swap_t = maxf(0.0, swap_t - delta)
	if not _climb.is_empty():
		_climb_tick(delta)
		return
	if _rise_t > 0.0:
		# Ayaklanıyor: kalkış klibi sürer, hedefe döner
		_rise_t -= delta
		if target and is_instance_valid(target):
			var tr_to := target.global_position - global_position
			if Vector2(tr_to.x, tr_to.z).length() > 0.1:
				rotation.y = lerp_angle(rotation.y, atan2(tr_to.x, tr_to.z), clampf(delta * 4.0, 0.0, 1.0))
		return
	if not path.is_empty():
		_path_tick(delta)
		return
	# Hedefi (dost ya da düşman düellocu) düştüyse yeni hedefi Melee verir; o zamana kadar boşta
	if target != null and (not is_instance_valid(target) or (target is Duelist and (not (target as Duelist).alive() \
			or (target as Duelist)._falling))):
		target = null
		if state in [St.WINDUP, St.STRIKE]:
			state = St.IDLE
			_t = 0.0
	if target == null:
		# Hedefsiz kalan (rakibi düştü, dövüş bitti) yarım kalan hamlesini bırakır, duruşa döner
		if state in [St.WINDUP, St.STRIKE, St.RECOVER, St.FLINCH]:
			state = St.IDLE
			_t = 0.0
		if anim and state == St.IDLE and not _falling:
			_anim_tick(delta)
		# Konuşanın önünden çekilme (dodge): kısa adımlarla yana
		if _dodge_to != Vector3.INF and body and body.visible and state != St.DOWN:
			var dd := _dodge_to - global_position
			dd.y = 0.0
			if dd.length() < 0.05:
				_dodge_to = Vector3.INF
			else:
				_walk(dd.limit_length(2.4 * delta))
				global_position.y = _ground_y()
			return
		# Dövüşten sonra nefeslenen dost: yanından geçen (taşıyıcı, komutan) olursa yol verir (iç içe durmasınlar)
		if body and body.visible and state != St.DOWN:
			var sep := Unclip.push(body, global_position, 0.6)
			sep.y = 0.0
			if sep != Vector3.ZERO:
				_walk(sep.limit_length(1.0) * 1.5 * delta)
				global_position.y = _ground_y()
		return
	_t += delta
	_knockback(delta)
	_lean = lerpf(_lean, 0.0, clampf(delta * 2.2, 0.0, 1.0))
	if anim:
		anim.lean = _lean
	if finishing:
		return                   # bitirici: Duel sürer
	var to := target.global_position - global_position
	to.y = 0.0
	var dist := to.length()
	# Gövde hep düellocunun önüne (Person'un kendi sohbet/yürüme dönüşleri yüzünü rakipten çeviriyordu)
	body.rotation.y = 0.0
	body.position = Vector3(0.0, body.position.y, 0.0)
	# Bitirici sürerken öbür rakipler saldırmaz (kamera başka yerde): hazırlık bozulur, bekler
	var hold: bool = duel != null and bool(duel.get("killcam"))
	if hold and state == St.WINDUP:
		state = St.IDLE
		_t = 0.0
	if hold:
		_think = maxf(_think, 0.6)
	# Yüzü hep hedefe (yerde yatarken dönmez: eskiden sırtüstü yatan asker yerde fırıl fırıl dönüyordu)
	if dist > 0.05 and state != St.DOWN:
		rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 8.0, 0.0, 1.0))
	# Mesafe ve yan adım (sendelerken ve vururken kıpırdamaz). Sırasını bekleyen (hold_back) oyuncunun çevresinde
	# daha geniş halkada dolaşır.
	# Dost ↔ düşman: biraz daha yakın dururlar (itişip kakışan iki asker darbe menzilinin dışında salınıp duruyordu)
	var npc := target is Duelist
	var want_r := RANGE + (1.6 if hold_back else 0.0) - (0.2 if npc else 0.0)
	if state in [St.IDLE, St.RECOVER]:
		var fwd := to.normalized() if dist > 0.01 else Vector3.FORWARD
		var side := fwd.cross(Vector3.UP)
		var v := Vector3.ZERO
		if dist > want_r + 2.5:
			v += fwd * 3.6               # uzaktaki hedefe koşar
		elif dist > want_r + 0.3:
			v += fwd * 2.4
		elif dist < want_r - 0.5:
			v -= fwd * 1.4
		_strafe_t -= delta
		if _strafe_t <= 0.0:
			_strafe_t = randf_range(1.2, 2.8)
			_strafe = [-1.0, 0.0, 1.0][randi() % 3]
		v += side * _strafe * 0.7
		# Kişisel alan: öbür rakiplerden, dost askerlerden, ayaktaki herkesten ayrı durur (aynı halkaya gelen iki
		# rakip, çarpışan iki dost iç içe giriyordu)
		v += Unclip.push(body, global_position, 0.95) * 3.0
		_walk(v * delta)
		global_position.y = _ground_y()
		if body.rig:
			body.rig.speed = v.length()
		# Takılma: hedefe uzakken ilerleyemiyorsa (barikat, sandık, siper) yandan dolanır; o da olmazsa görüş dışında
		# hedefin yakınına geçer (dalga uzakta takılı kalan biri yüzünden süre dolana dek sürüyordu)
		if dist > want_r + 1.2:
			if dist < _stuck_best - 0.15:
				_stuck_best = dist
				_stuck_t = 0.0
			else:
				_stuck_t += delta
				if _stuck_t > 2.5:
					_unstick(to)
		else:
			_stuck_best = INF
			_stuck_t = 0.0
			_unstick_n = 0
	elif state in [St.WINDUP, St.STRIKE, St.STAGGER, St.FLINCH]:
		# Saldırırken ve sendelerken de iç içe kalmaz (yavaşça ayrılır)
		var sep := Unclip.push(body, global_position, 0.75)
		if sep != Vector3.ZERO:
			_walk(sep * 1.6 * delta)
			global_position.y = _ground_y()
	# Muhafız: oyuncunun nişanına (ya da karşısındaki düellocunun kaldırdığı kola) tepki süresiyle döner
	var aim: int = DIR_TOP
	if target is Duelist:
		var td := target as Duelist
		aim = td.dir if td.state == St.WINDUP else _guard_want
	elif duel:
		aim = duel.player_aim()
	if aim != _guard_want:
		_guard_want = aim
		_guard_t = lerpf(0.75, 0.18, skill) + randf_range(0.0, 0.25)
	if guard != _guard_want:
		_guard_t -= delta
		if _guard_t <= 0.0:
			guard = _guard_want
	match state:
		St.IDLE:
			_think -= delta
			if _think <= 0.0 and dist < RANGE + (1.0 if npc else 0.6) and not hold_back:
				_start_attack()
		St.WINDUP:
			if _feint and _t > windup_time * 0.55:
				# Aldatma: kolu indirir, yeniden bekler
				state = St.IDLE
				_think = randf_range(0.3, 0.8)
				_t = 0.0
			elif _t >= windup_time:
				state = St.STRIKE
				_t = 0.0
				if target is Duelist:
					Audio.sfx_at("whoosh_fly", self, -12.0)
					_strike_npc(target as Duelist)
				else:
					Audio.sfx("whoosh_fly", -10.0, 1.6)
					if duel:
						duel.enemy_strike(self, dir)
		St.STRIKE:
			if _t >= 0.18:
				state = St.RECOVER
				_t = 0.0
		St.RECOVER:
			if _t >= lerpf(0.7, 0.4, skill):
				state = St.IDLE
				_think = randf_range(lerpf(1.6, 0.6, skill), lerpf(2.8, 1.4, skill))
				if target is Duelist:
					_think *= 0.6          # dostla düşman arasında tempo daha yüksek (kalabalık çarpışma)
		St.STAGGER:
			if _t >= 1.0:
				state = St.IDLE
				stagger_kind = ""
				_think = randf_range(0.8, 1.6)
		St.DOWN:
			if _t >= 0.42 and not _landed:
				# Sırt yere çarptı
				_landed = true
				Audio.sfx("land_thud", -3.0, 0.75)
				Vfx.dust(get_parent_node_3d(), global_position + Vector3(0, 0.1, 0) - global_transform.basis.z * 0.7, 0.4)
				if anim:
					anim.ground_mode = 2
			if _t >= DOWN_LIE and anim and anim.clip != "Roll":
				# Kalkış: yuvarlanmanın son yarısı (oturur, dizine gelir, doğrulur)
				anim.fade = 0.3
				anim.ground_mode = 1
				anim.create_tween().tween_property(anim, "body_amount", 0.7, 0.5)
				anim.play("Roll", 1.0, false, 0.8)
			if _t >= DOWN_LIE + DOWN_GETUP:
				state = St.IDLE
				stagger_kind = ""
				_think = randf_range(0.5, 1.0)
		St.FLINCH:
			if _t >= 0.35:
				state = St.IDLE
				_think = maxf(_think, 0.5)
	if anim:
		_anim_tick(delta)
	else:
		_pose(delta)


## Geri savrulma: hız duvarları dinleyerek (_walk) uygulanır, sürtünmeyle söner; zemin hep izlenir (yokuşta, molozda
## gömülmez). Sendelerken arkası duvarsa çarpar: gümleme, toz, daha uzun sersemlik.
func _knockback(delta: float) -> void:
	if _kb.length_squared() < 0.0004:
		return
	delta = minf(delta, 0.05)       # takılan bir karede (yükleme, donma) metrelerce uçmasın
	if state != St.DEAD and _edge_fall():
		return
	var before := global_position
	var step := _kb * delta
	_walk(step)
	var moved := Vector2(global_position.x - before.x, global_position.z - before.z).length()
	if moved < step.length() * 0.4 and _kb.length() > 1.8 and state in [St.STAGGER, St.DOWN]:
		_kb = Vector3.ZERO
		Audio.sfx_at("land_thud", self, -2.0)
		Audio.sfx_at("kick_metal", self, -14.0)
		Vfx.dust(get_parent_node_3d(), global_position + Vector3(0, 1.0, 0) - global_transform.basis.z * 0.35, 0.3)
		Fx.trauma(0.2 * _cam_near())
		_lean = 0.3                 # duvardan öne seker
		if state == St.STAGGER:
			_t = minf(_t, -0.4)
	else:
		_kb = _kb.move_toward(Vector3.ZERO, 9.0 * delta)
	global_position.y = _ground_y()


## Kameraya yakınlık (0..1): uzaktaki çarpışmaların sarsıntısı oyuncunun ekranını sallamasın.
func _cam_near() -> float:
	var cam := get_viewport().get_camera_3d() if is_inside_tree() else null
	if cam == null:
		return 0.0
	return clampf(1.0 - (cam.global_position.distance_to(global_position) - 3.0) / 9.0, 0.0, 1.0)


# ---------------------------------------------------------------- kenardan düşüş

## Geri savrulurken arkası boşluksa (sur yolunun dış kenarı, mazgal aralığı, küpeşte, moloz yarı) düşer. Göğüs hizasında
## görünür bir duvar varsa düşmez (çarpar). Alçak görünür bir korkuluğun (mazgal dişi, küpeşte) üstünden yalnız güçlü
## itişte (tekme, art arda darbe) devrilir. Görünmez sınırlar (oyuncuyu tutan korkuluk) düellocuyu tutmaz.
func _edge_fall() -> bool:
	var dir := _kb
	dir.y = 0.0
	var spd := dir.length()
	if spd < 1.0 or not is_inside_tree() or finishing or not _climb.is_empty():
		return false
	dir /= spd
	var p := global_position
	var fy := _drop_floor(p + dir * 0.6)
	if not is_nan(fy) and fy > p.y - 2.6:
		return false              # önü zemin (ya da bir iki basamak): düşüş yok
	var space := get_world_3d().direct_space_state
	var ex := _excl()
	var ray := func(h: float) -> bool:
		var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, h, 0), p + Vector3(0, h, 0) + dir * 1.0, 1, ex)
		var hit := space.intersect_ray(q)
		return not hit.is_empty() and Unclip.visible_body(hit["collider"]) and not _is_person_part(hit["collider"])
	if ray.call(1.4):
		return false              # göğüs hizasında duvar (kule, yüksek mazgal dişi): çarpar, düşmez
	# Bel ya da diz hizasında alçak korkuluk (küpeşte, iç korkuluk): yalnız güçlü itişte (tekme, art arda darbe) devrilir
	var low: bool = ray.call(0.95) or ray.call(0.3)
	if low and spd < 3.0:
		return false
	fall_off(dir, low or spd >= 3.0)
	return true


static func _is_person_part(n: Object) -> bool:
	var o := n as Node
	while o != null:
		if o is Person or o is Soldier or o is Duelist:
			return true
		o = o.get_parent()
	return false


## p'nin altındaki görünen zemin (8 m'ye kadar); yoksa NAN. Su yüzeyi zemin sayılmaz.
func _drop_floor(p: Vector3) -> float:
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 0.8, 0), p + Vector3(0, -8.0, 0), 1)
	q.exclude = _excl()
	var space := get_world_3d().direct_space_state
	for i in 6:
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			break
		var col: Object = hit["collider"]
		if (hit["normal"] as Vector3).y <= 0.6 or (col is CollisionObject3D and not Unclip.standable(col, int(hit.get("shape", 0)))) \
				or _is_person_part(col):
			if col is CollisionObject3D:
				q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
				continue
			break
		return (hit["position"] as Vector3).y
	return NAN


## Kenardan düşüş başlar: geriye devrilir (alçak korkuluğun üstünden), kollar havada, çığlık; yere çarpınca ölür.
## over: korkuluğun üstünden devrilme (önce yukarı kalkar). Oyuncunun darbesiyle düştüyse ağır çekim ve vurgu.
func fall_off(dir: Vector3, over := false) -> void:
	if _falling or not is_inside_tree():
		return
	var by_player := _hit_by_player > 0.0 and not npc_killed
	if has_meta("yield"):
		remove_meta("yield")      # surdan düşen teslim olup çekilemez
	_falling = true
	_fall_t = 0.0
	_fall_over = over
	_fall_v = dir * (2.4 if over else 3.0) + Vector3(0, 2.6 if over else 0.8, 0)
	_kb = Vector3.ZERO
	finishing = false
	remove_from_group("sight_dodgers")
	if body:
		body.set_meta("airborne", true)
		body.set_meta("no_audit", true)
	npc_killed = not by_player       # kill() düşüşü duyurur (Duel oyuncunun hanesine yazar ya da yazmaz)
	kill(false)
	if anim:
		anim.fade = 0.08
		anim.ground_mode = 0
		anim.body_amount = 1.0
		anim.lean = 0.0
		anim.play("Hit_Knockback", 0.7, false)
	Audio.sfx_at("fall_scream", self, 2.0)
	Audio.sfx_at("whoosh_fly", self, -6.0)
	if by_player:
		GameState.bump_stat("thrown_off")
		GameState.combat_add("thrown")
		Fx.slowmo(0.3, 0.9, 0.35)
		var d := duel as Duel
		if d and d.active:
			d.thrown(self)


func _fall_tick(delta: float) -> void:
	delta = minf(delta, 0.05)
	_fall_t += delta
	_fall_v.y -= 16.0 * delta
	var from := global_position
	var to := from + _fall_v * delta
	# Geriye devrilir, düşerken baş aşağı döner (devrilme önce hızlı)
	rotation.x = maxf(rotation.x - delta * (4.2 if _fall_t < 0.35 else 2.2), -2.7)
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from + Vector3(0, 0.25, 0), to + Vector3(0, -0.05, 0), 1, _excl())
	var hit := space.intersect_ray(q)
	if not hit.is_empty() and not _is_person_part(hit["collider"]) and Unclip.visible_body(hit["collider"]) \
			and (_fall_t > 0.3 or (hit["normal"] as Vector3).y > 0.6):
		var n := hit["normal"] as Vector3
		if n.y > 0.6 and Unclip.standable(hit["collider"], int(hit.get("shape", 0))):
			_fall_land(hit["position"] as Vector3)
			return
		if n.y <= 0.6:
			# Duvar yüzüne çarptı: yüzden sekip aşağı kayar
			_fall_v = _fall_v.slide(n) * 0.5 + n * 0.6
			to = from + _fall_v * delta
	if to.y < water_y:
		_fall_splash(Vector3(to.x, water_y, to.z))
		return
	global_position = to
	if _fall_t > 4.0:
		# Altında görünen zemin bulunamadı (uçurum, haritanın dışı): gözden kaybolur
		_falling = false
		visible = false
		set_process(false)


## Yere çarptı: gümleme, toz, kan, sarsıntı (yakınsa); ceset orada yatar.
func _fall_land(at: Vector3) -> void:
	_falling = false
	var drop := _fall_v.length()
	global_position = at
	rotation.x = 0.0
	if body:
		body.remove_meta("airborne")
	var par := get_parent_node_3d()
	Audio.sfx_at("land_thud", self, 4.0)
	Audio.sfx_at("drum_boom", self, -6.0)
	Vfx.dust(par, at + Vector3(0, 0.2, 0), 0.9)
	Duel.blood(par, at + Vector3(0, 0.3, 0), Vector3.UP, 0.8)
	Fx.trauma(clampf(drop / 30.0, 0.1, 0.4) * _cam_near())
	collapse("Death01", 0.85, 2.2)


func _fall_splash(at: Vector3) -> void:
	_falling = false
	Audio.sfx_at("splash", self, 2.0)
	Vfx.splash(get_parent_node_3d(), at, 1.0)
	global_position = at
	if body:
		body.remove_meta("airborne")
	var tw := create_tween()
	tw.tween_property(self, "global_position:y", at.y - 2.2, 1.6).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		visible = false
		set_process(false))


# ---------------------------------------------------------------- giriş: koşarak gelme, merdivenden çıkma, ayaklanma

## Giriş yolunda koşar: noktadan noktaya, engelden dolanarak (_walk); takılırsa sonraki noktaya geçer. Hedefine 3 m
## yaklaşınca yolu bırakıp dövüşe girer.
func _path_tick(delta: float) -> void:
	var to := path[0] - global_position
	to.y = 0.0
	var d := to.length()
	if d < 0.45:
		path.remove_at(0)
		_path_best = INF
		_path_stuck = 0.0
		if path.is_empty():
			_think = randf_range(0.3, 0.9)
		return
	if target and is_instance_valid(target) and target.global_position.distance_to(global_position) < 3.0:
		path.clear()
		_think = randf_range(0.3, 0.9)
		return
	var v := to / d * run_speed + Unclip.push(body, global_position, 0.8) * 2.0
	_walk(v * delta)
	global_position.y = _ground_y()
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), clampf(delta * 10.0, 0.0, 1.0))
	body.rotation.y = 0.0
	body.position = Vector3(0.0, body.position.y, 0.0)
	if d < _path_best - 0.05:
		_path_best = d
		_path_stuck = 0.0
	else:
		_path_stuck += delta
		if _path_stuck > 1.2:
			path.remove_at(0)
			_path_best = INF
			_path_stuck = 0.0
	if anim:
		anim.fade = 0.18
		anim.play("Sprint_Loop" if run_speed > 3.6 else "Jog_Fwd_Loop", 1.0)
	if body.rig:
		body.rig.speed = run_speed


## Merdivenden sura çıkış. base: merdivenin dibi, top: tepesi (mazgal hizası), land: sur yolunda atlayacağı yer.
## Basamak basamak tırmanır (Rig'in tırmanma pozları), tepede mazgaldan atlar (ClimbUp), taş tozu ve nara.
func climb_in(base: Vector3, top: Vector3, land: Vector3, delay := 0.0) -> void:
	_climb = {"base": base, "top": top, "land": land, "t": -delay, "len": base.distance_to(top), "vault": -1.0}
	global_position = base
	visible = delay <= 0.0
	if body:
		body.set_meta("climber", true)
		body.set_meta("no_audit", true)      # ipte, merdivende, mazgaldan atlarken (küpeşteden geçer)
	if anim:
		anim.stop_driving()
	if body and body.rig:
		body.rig.lock = 0
		body.set_activity("climb_a")
	var out := base - land
	out.y = 0.0
	if out.length() > 0.01:
		rotation.y = atan2(-out.x, -out.z)


func climbing() -> bool:
	return not _climb.is_empty() and float(_climb["vault"]) < 0.0


func _climb_tick(delta: float) -> void:
	var c := _climb
	c["t"] = float(c["t"]) + delta
	var t: float = c["t"]
	if t < 0.0:
		return
	visible = true
	var base: Vector3 = c["base"]
	var top: Vector3 = c["top"]
	var len: float = c["len"]
	if float(c["vault"]) < 0.0:
		var rung := t * 3.0                     # saniyede 3 basamak (0,45 m): 8 m'lik merdiven ~6 sn
		var h := minf(rung * 0.45, len)
		var ph := fmod(rung, 1.0)
		global_position = base.lerp(top, minf((floorf(rung) + smoothstep(0.1, 0.85, ph)) * 0.45 / maxf(len, 0.1), 1.0))
		if body and body.rig:
			body.set_activity("climb_a" if int(rung) % 2 == 0 else "climb_b")
		if h >= len:
			c["vault"] = 0.0
			c["from"] = global_position
			if body and body.rig:
				body.set_activity("")
				body.rig.lock = 1
			if anim:
				anim.fade = 0.06
				anim.ground_mode = 0
				anim.play("ClimbUp_1m", 1.4, false)
			var par := get_parent_node_3d()
			var land: Vector3 = c["land"]
			var outd := (top - land)
			outd.y = 0.0
			Vfx.ledge(par, top + Vector3(0, 0.9, 0), outd.normalized() if outd.length() > 0.01 else Vector3.BACK)
			Vfx.dust(par, top + Vector3(0, 1.0, 0), 0.35)
			Audio.sfx_at("war_cry", self, -2.0 + randf_range(-2.0, 1.0))
		return
	# Mazgaldan atlayış: yay çizip sur yoluna iner
	c["vault"] = float(c["vault"]) + delta
	var k := clampf(float(c["vault"]) / 0.55, 0.0, 1.0)
	var from: Vector3 = c["from"]
	var land2: Vector3 = c["land"]
	var p := from.lerp(land2, k)
	p.y += sin(k * PI) * 0.7 + (1.0 - k) * 0.0
	global_position = p
	if k >= 1.0:
		_climb = {}
		if body:
			body.remove_meta("climber")
			body.remove_meta("no_audit")
		Audio.sfx_at("land_thud", self, -4.0)
		Vfx.dust(get_parent_node_3d(), land2 + Vector3(0, 0.1, 0), 0.3)
		if anim:
			anim.ground_mode = 1
			anim.fade = 0.2
			anim.play("Idle_Shield_Loop" if shield else "Sword_Idle")
		_think = randf_range(0.4, 1.0)
		global_position.y = _ground_y()


## Tırmanırken merdiven itildi: geriye savrulup düşer.
func ladder_pushed(out: Vector3) -> void:
	if _climb.is_empty():
		return
	_climb = {}
	if body:
		body.remove_meta("climber")
		if body.rig:
			body.set_activity("")
			body.rig.lock = 1
	_hit_by_player = 3.0
	out.y = 0.0
	fall_off(out.normalized() if out.length() > 0.01 else Vector3.BACK, false)


var _stuck_t := 0.0
var _stuck_best := INF
var _unstick_n := 0


func _unstick(to: Vector3) -> void:
	_stuck_t = 0.0
	_stuck_best = INF
	_unstick_n += 1
	var fwd := to.normalized() if to.length() > 0.01 else global_transform.basis.z
	var side := fwd.cross(Vector3.UP)
	if _unstick_n <= 3:
		var sgn := 1.0 if _unstick_n % 2 == 1 else -1.0
		for s: float in [3.5, 5.0, 2.2]:
			var w := global_position + side * s * sgn + fwd * 1.2
			var fy := _floor_at(w)
			if is_nan(fy) or absf(fy - global_position.y) > 1.5:
				continue
			w.y = fy
			if Unclip.in_solid(self, w, 0.25) or not _swept_free(global_position, w - global_position):
				continue
			path.clear()
			path.append(w)
			return
	# Son çare: ekranda değilse hedefin yakınında (görüş dışında kalan) boş bir yere geçer
	var cam := get_viewport().get_camera_3d() if is_inside_tree() else null
	if cam and cam.is_position_in_frustum(global_position + Vector3(0, 1.0, 0)) and _unstick_n < 8:
		return
	var tp := target.global_position
	for k in 12:
		var a := k * TAU / 12.0
		var w := tp + Vector3(sin(a), 0, cos(a)) * (RANGE + 1.4)
		var fy := _floor_at(w)
		if is_nan(fy) or absf(fy - tp.y) > 1.2:
			continue
		w.y = fy
		if cam and cam.is_position_in_frustum(w + Vector3(0, 1.0, 0)):
			continue
		if Unclip.in_solid(self, w, 0.25) or (body and Unclip.crowded(body, w, 0.6)):
			continue
		global_position = w
		_unstick_n = 0
		return


## Ayaklanma (alarm): oturan/çömelen asker kalkar (yuvarlanmanın son yarısı), ayaktaki kılıcını çekip toparlanır.
func rise_from(activity: String) -> void:
	var low := activity.begins_with("sit") or activity in ["crouch", "kneel", "lie", "sleep", "work", "dig"]
	_rise_t = 0.8 if low else 0.35
	if anim == null:
		return
	if low:
		anim.fade = 0.0
		anim.ground_mode = 1
		anim.play("Roll", 1.0, false, 0.8)
	else:
		anim.fade = 0.15
		anim.play("Shield_OneShot" if shield else "Sword_Idle", 1.3, not shield)


## Geri çekilme noktası: arkasına (dir) doğru en çok 7 m; kapalıysa ±35°, ±70°, ±105° dener, en açık yönü seçer.
## Geri çekilmenin bir adımı: yeni yer bir katının (moloz katmanı, siper) içi ya da ayakta birinin üstüyse durur
## (yolun geri kalanında da kalır; sonunda zaten gizlenir). Eskiden yol düz bir çizgiydi: zemini izlerken katmanın
## altına iniyor, öbür çekilenin içinden geçiyordu.
func _retreat_step(p: Vector3) -> void:
	if has_meta("retreat_stop"):
		return
	var old := global_position
	var dev: Vector3 = get_meta("retreat_dev", Vector3.ZERO)
	var dg: Vector3 = get_meta("retreat_dodge", Vector3.ZERO)
	if dg != Vector3.ZERO:
		var sd := dg.limit_length(0.08)      # konuşanın önünden yana: karede 8 cm (sıçramasın)
		dev += sd
		set_meta("retreat_dev", dev)
		set_meta("retreat_dodge", dg - sd if (dg - sd).length() > 0.01 else Vector3.ZERO)
	var want := p + dev - old
	want.y = 0.0
	# Önü doluysa (ayakta biri, katı) yana açılarak geçer; hiçbir yan açık değilse durur
	for a: float in [0.0, 0.8, -0.8, 1.57, -1.57]:
		var m := want.rotated(Vector3.UP, a)
		var np := old + m
		np.y = _ground_y_at(np)
		if Unclip.in_solid(self, np, 0.18) or (body and (Unclip.blocks_step(body, old, np, 0.5) or Unclip.steps_into(body, old, np, 0.45))) \
				or not _swept_free(old, m):
			continue
		global_position = np
		if a != 0.0:
			set_meta("retreat_dev", dev + (m - want))
		return
	set_meta("retreat_stop", true)


## Adım boyunca gövde (dizden başa ince kapsül) bir katıya çarpmıyor mu: yalnız varılan yere bakmak ince bir duvarın
## (kasara perdesi, 0,2 m) öbür yanına geçirebiliyordu (29'da yenilen oyuncudan çekilen düellocu perdenin içinde kaldı).
func _swept_free(from: Vector3, m: Vector3) -> bool:
	m.y = 0.0
	if m.length_squared() < 1e-8 or not is_inside_tree():
		return true
	var cap := CapsuleShape3D.new()
	cap.radius = 0.14
	cap.height = 0.9
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.collision_mask = 1
	q.exclude = _excl()
	q.transform = Transform3D(Basis(), from + Vector3(0, 1.05, 0))
	q.motion = m
	var r := get_world_3d().direct_space_state.cast_motion(q)
	return r.size() == 0 or r[0] >= 0.999


## Bir noktanın altındaki görünen zemin (_ground_y'nin aynısı; düğümü taşımadan). Bulamazsa şimdiki yükseklik.
func _ground_y_at(p: Vector3) -> float:
	var y := _floor_at(p) if is_inside_tree() else NAN
	return global_position.y if is_nan(y) else y


func _retreat_target(dir: Vector3) -> Vector3:
	dir.y = 0.0
	dir = dir.normalized() if dir.length() > 0.01 else Vector3.BACK
	if not is_inside_tree():
		return global_position + dir * 7.0
	if _step_q == null:
		var cap := CapsuleShape3D.new()
		cap.radius = 0.26
		cap.height = 1.1
		_step_q = PhysicsShapeQueryParameters3D.new()
		_step_q.shape = cap
		_step_q.collision_mask = 1
	_step_q.exclude = _excl()
	var space := get_world_3d().direct_space_state
	var best := global_position
	var best_len := -1.0
	for a: float in [0.0, 0.6, -0.6, 1.2, -1.2, 1.8, -1.8]:
		var d := dir.rotated(Vector3.UP, a) * 7.0
		_step_q.transform = Transform3D(Basis(), global_position + Vector3(0, 1.05, 0))
		_step_q.motion = d
		var r := space.cast_motion(_step_q)
		var free := (r[0] if r.size() > 0 else 1.0) * 7.0 - 0.3
		# Yolda ayakta biri varsa (kaptan, dost asker, figüran) onun içinden geçmez: önünde durur
		var dn := d.normalized()
		var s := 0.5
		while s <= free and body:
			if Unclip.crowded(body, global_position + dn * s, 0.55):
				free = s - 0.6
				break
			s += 0.5
		if free > best_len + 0.5:
			best_len = free
			best = global_position + d.normalized() * maxf(free, 0.0)
		if free >= 6.5:
			break
	return best


## Sorgularda sayılmayanlar: rakip (oyuncu) ve yalnız oyuncuyu durduran görünmez sınırlar ("player_only": gedik
## tepesindeki korkuluk gibi; düellocu gedikten içeri girebilmeli)
func _excl() -> Array[RID]:
	var ex: Array[RID] = []
	if target != null and is_instance_valid(target) and target is CollisionObject3D:
		ex.append((target as CollisionObject3D).get_rid())
	for n in get_tree().get_nodes_in_group("player_only"):
		if n is CollisionObject3D:
			ex.append((n as CollisionObject3D).get_rid())
	return ex


## Bir adım: duvara, sandığa, surun içine yürümesin. Gövde boyu kapsül (dizden başa; alçak basamaklar engel değil)
## adım boyunca süpürülür; önü kapalıysa eksenlerden biri boyunca kayar, o da kapalıysa yerinde kalır.
var _step_q: PhysicsShapeQueryParameters3D
var _detour := 1.0         # engelin hangi yanından dolanılır

func _walk(d: Vector3) -> void:
	d.y = 0.0
	if d.length_squared() < 1e-10 or not is_inside_tree():
		return
	if _step_q == null:
		var cap := CapsuleShape3D.new()
		cap.radius = 0.26
		cap.height = 1.1
		_step_q = PhysicsShapeQueryParameters3D.new()
		_step_q.shape = cap
		_step_q.collision_mask = 1
	_step_q.exclude = _excl()
	var space := get_world_3d().direct_space_state
	# Önce doğrudan, sonra eksenler boyunca kayarak, sonra engelin yanından (45°, 90°) dolanarak. Her yön önce yerden,
	# sonra 0,3 m yukarıdan denenir: moloz basamağına, eşiğe çıkar (gedikteki 0,5 m'lik basamaklarda ve barikatın
	# önünde takılıp kalıyordu)
	var tries: Array[Vector3] = [d, Vector3(d.x, 0, 0), Vector3(0, 0, d.z)]
	for a: float in [0.8, 1.57]:
		tries.append(d.rotated(Vector3.UP, a * _detour))
		tries.append(d.rotated(Vector3.UP, -a * _detour))
	for i in tries.size():
		var m: Vector3 = tries[i]
		if m.length_squared() < 1e-10:
			continue
		# Ayakta birinin (dost asker, figüran, başka bir rakip) içine adım atmaz: yanından dolanır
		if body and Unclip.blocks_step(body, global_position, global_position + m, 0.5):
			continue
		# Görünen bir katının (siper, sandık, sur) içine girmez: süpürme sorgusu gövde zaten bir katıya değerken adımı
		# serbest sayıyordu, düellocu siperin tahtasına yavaş yavaş gömülüyordu
		if Unclip.in_solid(self, global_position + m, 0.2) and not Unclip.in_solid(self, global_position, 0.2):
			continue
		# Basamaktan, katmanın kenarından inerken vardığı zeminde bir katının (hendeğin karşı duvarı) içine düşmez
		# (eskiden katmanın kenarından hendeğin dibine, karşı duvarın içine iniyordu)
		var gy := _ground_y_at(global_position + m)
		if Unclip.in_solid(self, Vector3(global_position.x + m.x, gy, global_position.z + m.z), 0.2) and not Unclip.in_solid(self, global_position, 0.2):
			continue
		for lift: float in [0.0, 0.3]:
			_step_q.transform = Transform3D(Basis(), global_position + Vector3(0, 1.05 + lift, 0))
			_step_q.motion = m
			var r := space.cast_motion(_step_q)
			if r.size() > 0 and r[0] >= 0.999:
				global_position += m
				if i >= 3 and (i - 3) % 2 == 1:
					_detour = -_detour      # öbür yandan dolandı: o yana devam etsin (sağa sola titremesin)
				return


## Ayağının altındaki GÖRÜNEN zemin (0,8 m yukarıdan, en çok bir basamak, 4 m aşağıya ışın; kendi gövdesi ve oyuncu
## hariç). Görünmez çarpışma kutuları (barikatın gizli aşaması, sınırlar) ve dik yüzler (siper tahtasının üst kenarı)
## atlanır: eskiden ilk çarpana bakıyordu, ışın siperin kenarına değince y güncellenmiyor, alçak eşyanın içinde kalıyordu.
## Bulamazsa son y.
func _ground_y() -> float:
	if not is_inside_tree():
		return _y
	var y := _floor_at(global_position)
	if is_nan(y):
		# Ayakları bir yamacın (moloz dili, set) yüzeyinin altında kalmış: daha yukarıdan bak (ışın katının içinden
		# başlayınca onu görmüyor, düellocu molozun altından tünel açar gibi yürüyordu)
		y = _floor_at(global_position + Vector3(0, 1.7, 0))
	if not is_nan(y):
		_y = y
	return _y


## p'nin altındaki görünen zemin (yoksa NAN): 0,8 m yukarıdan 4 m aşağıya; görünmez gövdeler ve dik yüzler atlanır.
func _floor_at(p: Vector3) -> float:
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 0.8, 0), p + Vector3(0, -4.0, 0), 1)
	q.exclude = _excl()
	var space := get_world_3d().direct_space_state
	for i in 6:
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			break
		var col: Object = hit["collider"]
		if (hit["normal"] as Vector3).y <= 0.6 or (col is CollisionObject3D and not Unclip.standable(col, int(hit.get("shape", 0)))):
			if col is CollisionObject3D:
				q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
				continue
			break
		return (hit["position"] as Vector3).y
	return NAN


func _start_attack() -> void:
	state = St.WINDUP
	_t = 0.0
	# Usta rakip oyuncunun nişan yönünden (karşısındaki düellocunun muhafızından) kaçınır (orası muhafızlı sayılır)
	var aim: int = (target as Duelist).guard if target is Duelist else (duel.player_aim() if duel else -1)
	var choices := [DIR_LEFT, DIR_RIGHT, DIR_TOP]
	if skill > 0.45 and randf() < skill:
		choices.erase(aim)
	dir = choices[randi() % choices.size()]
	_feint = skill > 0.6 and randf() < (skill - 0.55) * 0.5
	windup_time = lerpf(0.95, 0.5, skill) * randf_range(0.9, 1.15)


## Animasyon seçimi: saldırı darbe anı oyun mantığındaki STRIKE anına denk getirilir.
func _anim_tick(delta: float) -> void:
	var v := body.rig.speed if body.rig else 0.0
	_moving = lerpf(_moving, v, clampf(delta * 6.0, 0.0, 1.0))
	match state:
		St.WINDUP:
			var c: String = ATTACK_CLIP[dir]
			anim.fade = 0.08
			anim.scrub(c, LimbAnim.hit_time(c) * clampf(_t / windup_time, 0.0, 1.0))
		St.STRIKE, St.RECOVER:
			var c2: String = ATTACK_CLIP[dir]
			var tt := LimbAnim.hit_time(c2) + (_t if state == St.STRIKE else 0.18 + _t)
			anim.scrub(c2, minf(tt, LimbAnim.length(c2)))
		St.STAGGER, St.DOWN:
			pass                    # klibi olay seçti (kicked / parried / knock_down)
		St.FLINCH:
			anim.play("Hit_Chest", 1.4, false)
		St.IDLE:
			anim.fade = 0.2
			if _moving > 2.8:
				anim.play("Jog_Fwd_Loop", 1.0)
			elif _moving > 0.6:
				anim.play("Walk_Loop", clampf(_moving / 1.4, 0.6, 1.6))
			elif (duel and target is Player and duel.blocking_visible_for(self)) \
					or (target is Duelist and (target as Duelist).state == St.WINDUP and guard == (target as Duelist).dir):
				anim.play("Sword_Block")
			else:
				anim.play("Idle_Shield_Loop" if shield else "Sword_Idle")


## Kol pozları (oyuncunun gözünden: "sağ" = rakibin +X yanı, kılıç kolunun yanı).
func _pose(delta: float) -> void:
	if body.rig == null:
		return
	var ar: Node3D = body.rig.arm_r
	var er: Node3D = body.rig.elbow_r
	var al: Node3D = body.rig.arm_l
	if ar == null:
		return
	var want := Vector3(-1.1, 0, 0.1)
	var elbow := -0.8
	var k := clampf(delta * 12.0, 0.0, 1.0)
	match state:
		St.IDLE, St.RECOVER, St.FLINCH:
			match guard:
				DIR_RIGHT:
					want = Vector3(-1.2, 0, 0.75)
					elbow = -1.25
				DIR_LEFT:
					want = Vector3(-1.35, 0, -0.75)
					elbow = -1.35
				_:
					want = Vector3(-2.2, 0, 0.3)
					elbow = -1.3
			if state == St.FLINCH:
				want.x += 0.5
		St.WINDUP:
			var p := windup_progress()
			match dir:
				DIR_RIGHT:
					want = Vector3(-2.3, 0, 1.7)
					elbow = -1.3
				DIR_LEFT:
					want = Vector3(-2.4, 0, -1.25)
					elbow = -1.5
				_:
					want = Vector3(-3.1, 0, 0.1)
					elbow = -1.2
			k = clampf(delta * (4.0 + p * 6.0), 0.0, 1.0)
		St.STRIKE:
			match dir:
				DIR_RIGHT:
					want = Vector3(-1.2, 0, -0.7)
				DIR_LEFT:
					want = Vector3(-1.2, 0, 1.0)
				_:
					want = Vector3(-0.8, 0, 0.1)
			elbow = -0.1
			k = clampf(delta * 30.0, 0.0, 1.0)
		St.STAGGER:
			want = Vector3(-0.4, 0, 0.9)
			elbow = -0.3
			body.rotation.x = lerpf(body.rotation.x, -0.15, k)
	if state != St.STAGGER:
		body.rotation.x = lerpf(body.rotation.x, 0.0, k)
	ar.rotation = ar.rotation.lerp(want, k)
	if er:
		er.rotation.x = lerpf(er.rotation.x, elbow, k)
	if al:
		al.rotation = al.rotation.lerp(Vector3(-0.9, 0, -0.25) if shield else Vector3(-0.2, 0, -0.2), k)
