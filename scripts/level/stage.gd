class_name Stage
## Sahne hareketleri (animasyon denetimi): bir karakter birine bir şey yapacaksa (yakalamak, bağlamak, vermek)
## önce yürüyerek yanına gelir, sonra eli uzanır. Eskiden pek çok sahnede askerler 3-7 m öteden bağırıp yok oluyordu
## ya da biri tek karede oyuncunun yanına ışınlanıyordu (Bölüm 4 şikâyeti; QA_DERSLER). Person, Soldier ve Hikmet'le
## çalışır (üçünün de rig'i ve face_toward'ı var). Otomatik testte (PACE dışında) hemen biter.


static func fast() -> bool:
	return GameState.autotest and not GameState.pace


## who, target'ın stop metre önüne kadar yürür (yükseklik korunur; ground verilirse varış yüksekliği oradan),
## varınca target'a döner. side: varış noktasına eklenecek yan kayma (iki kişi aynı yere yürümesin).
static func approach(who: Node3D, target: Vector3, stop := 1.3, speed := 1.6, side := Vector3.ZERO, ground := Callable()) -> void:
	if not is_instance_valid(who) or not who.is_inside_tree():
		return
	var from := who.global_position
	var flat := Vector3(target.x - from.x, 0.0, target.z - from.z)
	var d := flat.length()
	if d <= stop + 0.05 and side == Vector3.ZERO:
		face(who, target)
		return
	var to := from + flat.normalized() * maxf(0.0, d - stop) + side
	to.y = float(ground.call(to.x, to.z)) if ground.is_valid() else from.y
	face(who, to)
	if fast():
		who.global_position = to      # otomatik testte doğrudan: kısa tween'in ara karesinde havada sayılıyordu (CI VISAUDIT float)
		face(who, target)
		return
	var t := clampf(from.distance_to(to) / maxf(speed, 0.1), 0.25, 6.0)
	var tw := who.create_tween()
	tw.tween_property(who, "global_position", to, t)
	who.set_meta("stage_walk", true)
	await tw.finished
	if is_instance_valid(who):
		who.remove_meta("stage_walk")
		face(who, target)


## Beklenmeden başlatılmış bir approach (konuşurken yürür) bitene kadar bekler: aynı kişiye ikinci yürüyüş
## verilmeden ya da "yanına gelince" söylenecek söz başlamadan önce.
static func settle(who: Node3D) -> void:
	while is_instance_valid(who) and who.is_inside_tree() and who.get_meta("stage_walk", false):
		await who.get_tree().process_frame


## Yalnız yatay dönüş (karakter öne/arkaya yatmaz).
static func face(who: Node3D, p: Vector3) -> void:
	if who.has_method("face_toward"):
		who.call("face_toward", p)
		return
	var to := p - who.global_position
	if Vector2(to.x, to.z).length() > 0.01:
		who.global_rotation = Vector3(0, atan2(to.x, to.z), 0)


## Kol dünyadaki bir noktaya uzanır (yakadan tutmak, kolundan yakalamak, bir şey vermek), hold sn orada kalır,
## geri çekilir. Kol IK'si: Rig.reach (Person.reach_to'nun rig'li herkes için hâli).
static func reach(who: Node3D, target: Vector3, hold := 0.5, left := false) -> void:
	var rg := Handover.rig_of(who)
	if rg == null or not who.is_inside_tree():
		return
	var arm := rg.arm_l if left else rg.arm_r
	var el := rg.elbow_l if left else rg.elbow_r
	if arm == null or el == null:
		rg.emote("point")
		return
	var turned := await work_turn(who, target)
	if not is_instance_valid(who):
		return
	rg.lock += 1
	var r0 := arm.rotation
	var e0 := el.rotation
	Rig.reach(arm, el, target, Vector3.DOWN + who.global_transform.basis.x * (-0.6 if left else 0.6))
	var r1 := arm.rotation
	var e1 := el.rotation
	arm.rotation = r0
	el.rotation = e0
	var f := fast()
	var tw := who.create_tween()
	tw.tween_property(arm, "rotation", r1, 0.05 if f else 0.35).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(el, "rotation", e1, 0.05 if f else 0.35)
	tw.tween_interval(0.05 if f else hold)
	tw.tween_property(arm, "rotation", r0, 0.05 if f else 0.3).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(el, "rotation", e0, 0.05 if f else 0.3)
	await tw.finished
	if rg:
		rg.lock = maxi(0, rg.lock - 1)
	if turned:
		work_end(who)


## Oyuncunun kolu/omzu hizası (yakalayan buraya uzanır): kameranın biraz altı ve yanı.
static func player_arm(player: Player, left := false) -> Vector3:
	return player.camera.global_transform * Vector3(-0.3 if left else 0.3, -0.45, -0.15)


## Oyuncu kendi ayağıyla (fizikle, duvarlara takılarak) bir noktaya yürür: target'ın stop metre önünde durur ve
## look'a döner. Sahne bir şeyi "Tolga yapar" diyorsa (çatlağa bant, namluya barut, fitile çakmak) 5 m öteden
## yapılmasın (Bölüm 4'teki chapter4._walk_to'nun ortak hâli). En çok max_t sn sürer; otomatik testte ışınlanır.
static func walk_player(player: Player, target: Vector3, stop := 0.9, look := Vector3.INF, max_t := 6.0) -> void:
	var pp := player.global_position
	var flat := Vector3(target.x - pp.x, 0.0, target.z - pp.z)
	var to := pp + flat.normalized() * maxf(0.0, flat.length() - stop) if flat.length() > stop else pp
	var lk := look if look != Vector3.INF else Vector3(target.x, target.y if target.y > pp.y + 0.5 else pp.y + 1.4, target.z)
	if flat.length() - stop < 0.25:
		player.face(lk)
		return
	if fast():
		player.global_position = Vector3(to.x, pp.y, to.z)
		player.face(lk)
		return
	player.face(Vector3(to.x, pp.y + 1.5, to.z))
	var mode := player.move_mode
	var was_frozen := player.frozen
	player.move_mode = "script"
	player.frozen = false
	var t := 0.0
	var tree := player.get_tree()
	while t < max_t and is_instance_valid(player):
		var d := Vector3(to.x - player.global_position.x, 0.0, to.z - player.global_position.z)
		if d.length() < 0.25:
			break
		player.script_velocity = d.normalized() * Player.WALK
		await tree.physics_frame
		if not tree.paused:
			t += player.get_physics_process_delta_time()
	if is_instance_valid(player):
		player.script_velocity = Vector3.ZERO
		player.move_mode = mode
		player.frozen = was_frozen
		player.face(lk)


## Elde tokmak, n kez kalkıp iner (kalas, kazık, direk çakarken): kameranın sağ altında geçici bir tokmak. Her inişte
## on_hit (varsa) çağrılır. Otomatik testte hızlı. Beklenebilir; beklenmeden de çalışır.
static func hammer_swings(player: Player, n := 3, on_hit := Callable()) -> void:
	if player == null or player.camera == null or not player.is_inside_tree():
		return
	var hm := Node3D.new()
	hm.set_meta("transient", true)
	player.camera.add_child(hm)
	hm.position = Vector3(0.22, -0.3, -0.55)
	hm.rotation_degrees = Vector3(-40, 0, -10)
	Props.cyl(hm, 0.014, 0.32, Vector3(0, -0.06, 0), Color("6a4a2c"), Vector3.ZERO, 6)
	Props.cyl(hm, 0.045, 0.14, Vector3(0, 0.1, 0), Color("8a6a44"), Vector3(0, 0, 90), 8)
	Props.strip_outlines(hm)
	var f := fast()
	for k in n:
		if not is_instance_valid(hm):
			return
		var tw := hm.create_tween()
		tw.tween_property(hm, "rotation_degrees", Vector3(55, 0, -10), 0.03 if f else 0.16).set_trans(Tween.TRANS_SINE)
		tw.tween_property(hm, "rotation_degrees", Vector3(-40, 0, -10), 0.03 if f else 0.09).set_ease(Tween.EASE_IN)
		await tw.finished
		if on_hit.is_valid():
			on_hit.call(k)
		if is_instance_valid(player):
			player.shake(0.03)
	if is_instance_valid(hm):
		hm.queue_free()


# ---------------------------------------------------------------- ortak parçalar (Bölüm 2, tur 2; bütün oyuna yayılır)
# ---------------------------------------------------------------- bakış / iş ayrımı
# İskelette bel eklemi yok: look_target verilen kişinin BÜTÜN gövdesi hedefe döner. İş yapan (sürgü kaldıran, yük
# taşıyan, aletle çalışan, yürüyen) kişi oyuncuya bakarken işini sırtında bırakıyordu (8y kapı nöbetçisi). gaze_dir,
# Person ve Soldier'ın look_target dönüşünü işe göre yönlendirir: konuşma bakışlarına dokunmaz.

## Bu etkinliklerde (boşta, yük taşıma, oturuş) look_target gövdeyi çevirebilir; öbürlerinde (alet işi, kürek, uyku...) çevirmez.
const GAZE_FREE_ACT := ["", "carry", "sit", "sit_ground", "write", "write_desk", "sit_astride", "read_ground"]


## İş odağı aç/kapa (grip_hold dışındaki işler için: kapı kanadı çekmek, kol çevirmek): açıkken look_target gövdeyi
## çevirmez, gövde at'a (dünya noktası; verilmezse olduğu yerde) döner. Her work_begin için bir work_end.
static func work_begin(who: Node3D, at := Vector3.INF) -> void:
	if is_instance_valid(who) and "work_focus" in who:
		who.work_focus += 1
		if at != Vector3.INF:
			who.work_at = at


static func work_end(who: Node3D) -> void:
	if is_instance_valid(who) and "work_focus" in who:
		who.work_focus = maxi(0, who.work_focus - 1)
		if who.work_focus == 0:
			who.work_at = Vector3.INF


## Uzanma gibi hedefe kilitli bir işe girerken look_target gövdeyi hedeften başka yöne (oyuncuya) çevirmişse kolun
## uzanış açısı yanlış kalırdı (hedef omuz arkasında, el havaya): önce gövde hedefe döner (work_begin; çağıran işi bitirince
## work_end). Döner: work_begin yapıldı mı. Otomatik testte (PACE dışı) hemen döner.
static func work_turn(who: Node3D, target: Vector3) -> bool:
	if not is_instance_valid(who) or not ("work_focus" in who) or who.get("look_target") == null or not who.is_inside_tree():
		return false
	var to := target - who.global_position
	to.y = 0.0
	var fwd := who.global_transform.basis.z
	fwd.y = 0.0
	if to.length() < 0.4 or fwd.length() < 0.01 or fwd.normalized().angle_to(to.normalized()) < deg_to_rad(50.0):
		return false
	if fast():
		face(who, target)
		work_begin(who, target)
		return true
	work_begin(who, target)
	for i in 40:
		await who.get_tree().process_frame
		if not is_instance_valid(who):
			return true
		var f2 := who.global_transform.basis.z
		f2.y = 0.0
		if f2.normalized().angle_to(to.normalized()) < deg_to_rad(15.0):
			break
	return true


## look_target'in gövdeyi çevireceği yatay yön (kişinin ebeveyn çerçevesinde). Vector3.ZERO: çevirme.
## to: hedefe yön (yerel, yatay); mv: bu karedeki yerel yer değişimi; act: iş hareketi; talking: kişi konuşuyor.
##  1) Yürüyen (>0.6 m/s) kişi (konuşurken de) gittiği yöne bakar (geri geri yürüyecekse meta "walk_back").
##  2) work_focus > 0 (grip_hold): gövde işin noktasına (work_at) döner; noktası yoksa olduğu yerde kalır.
##  3) Alet işi yapan ve konuşmayan kişi gövdesini çevirmez (konuşurken döner).
##  4) Öbürleri: hedefe döner (konuşma bakışı, değişmedi).
static func gaze_dir(who: Node3D, act: String, talking: bool, to: Vector3, mv: Vector3, delta: float) -> Vector3:
	if delta > 0.0 and not who.has_meta("walk_back"):
		var hv := Vector3(mv.x, 0.0, mv.z)
		if hv.length() / delta > 0.6 and hv.length() < 2.0:
			return hv
	if int(who.get("work_focus")) > 0:
		var wa = who.get("work_at")
		if wa is Vector3 and wa != Vector3.INF:
			var d: Vector3 = wa - who.global_position
			var par := who.get_parent() as Node3D
			if par:
				d = par.global_transform.basis.inverse() * d
			d.y = 0.0
			return d if d.length() > 0.25 else Vector3.ZERO
		return Vector3.ZERO
	if not act in GAZE_FREE_ACT:
		# 3 m içindeki muhatap (Tolga yanındaysa) konuşma sayılır: SAYFACE'e takılmadan dönüp bakar
		talking = talking or to.length() < 3.0
		# Alet işi: yalnız konuşurken Tolga'ya döner, konuşma bitince işinin yönüne (dönmeden önceki yön) geri döner
		if who.has_meta("gaze_seen") and absf(angle_difference(float(who.get_meta("gaze_seen")), who.rotation.y)) > 0.6:
			who.remove_meta("gaze_home")      # sahne betiği kişiyi başka yöne çevirdi: eski yönü geçersiz
		who.set_meta("gaze_seen", who.rotation.y)
		if talking:
			if not who.has_meta("gaze_home"):
				who.set_meta("gaze_home", who.rotation.y)
			who.set_meta("gaze_idle", 0.0)
			return to
		if who.has_meta("gaze_home"):
			# konuşma aralarında (Tolga'nın repliği) dönüp durmasın: 2,5 sn susarsa işine döner
			var idle := float(who.get_meta("gaze_idle", 0.0)) + delta
			who.set_meta("gaze_idle", idle)
			if idle < 2.5:
				return to
			var h := float(who.get_meta("gaze_home"))
			if absf(angle_difference(who.rotation.y, h)) < 0.05:
				who.remove_meta("gaze_home")
				return Vector3.ZERO
			return Vector3(sin(h), 0.0, cos(h))
		return Vector3.ZERO
	return to


# Eller nesneye, ayaklar zemine, halatın iki ucu bir yere bağlı: havada iş yapan, havada duran, havada gerili ip kalmasın.

static var _rope_mat: StandardMaterial3D


## Eli nesneye oturt: who'nun (rig'li Soldier/Person) eli frame'in yerelindeki noktaya uzanır (Rig.reach). Bir nokta: ona
## yakın el; iki nokta: iki el, kollar çaprazlanmadan. Kişinin kendi pozu yazıldıktan SONRA çağrılır (yüksek
## process_priority'li bir _process'te ya da grip_hold ile). Döner: avucun hedefe kalan en büyük uzaklığı (m).
## Örnek: Stage.grip(asker, kirik_kol, [Vector3(0, 1, 1.1), Vector3(0, 1, 1.6)]) — ırgat kolu, kürek, halat, kıç aynası.
static func grip(who: Node3D, frame: Node3D, pts: Array) -> float:
	var rg := Handover.rig_of(who)
	if rg == null or rg.arm_l == null or rg.arm_r == null or rg.elbow_l == null or rg.elbow_r == null or pts.is_empty():
		return INF
	var w: Array = []
	for p: Vector3 in pts:
		w.append(frame.to_global(p) if frame else p)
	var al := rg.arm_l
	var ar := rg.arm_r
	var pairs: Array = []
	if w.size() == 1:
		var left: bool = al.global_position.distance_to(w[0]) < ar.global_position.distance_to(w[0])
		pairs.append([al if left else ar, rg.elbow_l if left else rg.elbow_r, w[0]])
	else:
		var straight: bool = al.global_position.distance_to(w[0]) + ar.global_position.distance_to(w[1]) <= \
			al.global_position.distance_to(w[1]) + ar.global_position.distance_to(w[0])
		pairs.append([al, rg.elbow_l, w[0] if straight else w[1]])
		pairs.append([ar, rg.elbow_r, w[1] if straight else w[0]])
	var err := 0.0
	for pr: Array in pairs:
		var arm: Node3D = pr[0]
		var out := arm.global_position - who.global_position
		out.y = 0.0
		err = maxf(err, Rig.reach(arm, pr[1], pr[2], Vector3.DOWN + (out.normalized() * 0.6 if out.length() > 0.01 else Vector3.ZERO)))
	return err


## grip'i her karede, kişinin kendi pozundan sonra uygular (bir Tween'le: Tween'ler düğümlerin _process'inden sonra
## işler). seconds < 0: grip_release(who) çağrılana ya da kişi silinene dek. Yakalayan asker, halatı tutan, kürekçi.
## Örnek: Stage.grip_hold(muhafiz, oyuncu.hand, [Vector3(0, 0.035, 0.07)], 4.0) — oyuncunun görünen bileğinden tutar.
## lean: tutarken gövde öne eğilir (radyan; kol boyu yetmeyen yakına uzanır).
static func grip_hold(who: Node3D, frame: Node3D, pts: Array, seconds := -1.0, lean := 0.0) -> void:
	if not is_instance_valid(who) or not who.is_inside_tree():
		return
	grip_release(who)
	var rg := Handover.rig_of(who)
	if rg:
		rg.lock += 1      # rig'in kendi kol jesti (konuşma, işaret) araya girmesin
	if "work_focus" in who:
		who.work_focus += 1      # iş sürerken look_target gövdeyi çevirmez (gaze_dir)
	var tw := who.create_tween()
	var apply := func(_t: float) -> void:
		if is_instance_valid(who) and (frame == null or is_instance_valid(frame)):
			if lean != 0.0 and rg and rg.body:
				rg.body.rotation.x = lean
			if "work_at" in who and not pts.is_empty():
				var c := Vector3.ZERO
				for q: Vector3 in pts:
					c += frame.to_global(q) if frame else q
				who.work_at = c / float(pts.size())
			grip(who, frame, pts)
	if seconds < 0.0:
		tw.set_loops()
		tw.tween_method(apply, 0.0, 1.0, 1.0)
	else:
		tw.tween_method(apply, 0.0, 1.0, maxf(seconds, 0.05))
		tw.tween_callback(func(): grip_release(who))
	who.set_meta("grip_tw", tw)


## grip_hold'u bırakır (kol kişinin kendi pozuna döner).
static func grip_release(who: Node3D) -> void:
	if not is_instance_valid(who) or not who.has_meta("grip_tw"):
		return
	var tw = who.get_meta("grip_tw")
	who.remove_meta("grip_tw")
	if tw is Tween and (tw as Tween).is_valid():
		(tw as Tween).kill()
	var rg := Handover.rig_of(who)
	if rg:
		rg.lock = maxi(0, rg.lock - 1)
	if "work_focus" in who:
		who.work_focus = maxi(0, who.work_focus - 1)
		if who.work_focus == 0:
			who.work_at = Vector3.INF


## Ayağı zemine oturt: kişinin iki tabanından alçak olanı zemine değecek kadar kök dikine kayar (yalnız y). ground:
## (x, z) -> dünya y; verilmezse aşağı ışın (kişinin kendi gövdesi sayılmaz). Pozu (öne yatma, adım) yazıldıktan sonra
## her karede çağrılır; kendini düzeltir (taban zemindeyse kayma 0). İten, çeken, yokuşta ya da güvertede çalışan herkes.
## Örnek: Stage.plant_feet(itici, func(x, z): return yol.y_at(x, z)). Döner: uygulanan kayma (m).
static func plant_feet(who: Node3D, ground := Callable(), max_shift := 0.45) -> float:
	var rg := Handover.rig_of(who)
	if rg == null or rg.knee_l == null or rg.knee_r == null or not who.is_inside_tree():
		return 0.0
	var low := Vector3.INF
	var gy := 0.0
	for kn: Node3D in [rg.knee_l, rg.knee_r]:
		var an := CharKit.ankle_of(kn)
		var sole := an.to_global(Vector3(0, -0.075, 0.05))
		var g := _ground_under(who, sole, ground)
		if low == Vector3.INF or sole.y - g < low.y - gy:
			low = sole
			gy = g
	var d := clampf(gy - low.y, -max_shift, max_shift)
	who.global_position += Vector3(0, d, 0)
	return d


static func _ground_under(who: Node3D, p: Vector3, ground: Callable) -> float:
	if ground.is_valid():
		return float(ground.call(p.x, p.z))
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 0.9, 0), p + Vector3(0, -1.2, 0))
	var ex: Array[RID] = []
	for c in who.find_children("*", "CollisionObject3D", true, false):
		ex.append((c as CollisionObject3D).get_rid())
	q.exclude = ex
	var hit := who.get_world_3d().direct_space_state.intersect_ray(q)
	return (hit["position"] as Vector3).y if not hit.is_empty() else p.y


## Halat: iki ucu bağlı (a, b parent'ın yerelinde), sag kadar sarkan, burgulu kalın ip: tek ağ, köşe rengi şeritleri
## (bir koyu bir açık, sarmal) ve dış çizgi. Ucu bir şeye bağlı olmayan, havada gerili ip kurmayın.
## Örnek: var r := Stage.rope(gemi, baba, kazik, 0.2, 0.04); hareket edince Stage.rope_to(r, [baba, ..., kazik]).
## Kullanım: fren halatı, çekme halatı, kayık bağı, vinç, çan ipi, zincir (koyu renk).
static func rope(parent: Node3D, a: Vector3, b: Vector3, sag := 0.0, r := 0.03, col := Color("b89a6a"), n := 8) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.set_meta("rope", [r, col])
	mi.set_meta("no_walk", true)       # WorldWalk: ip zemin değildir
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.material_override = rope_material()
	parent.add_child(mi)
	rope_to(mi, sag_points(a, b, sag, n if sag > 0.0 else 1))
	return mi


## Halatı yeni noktalardan geçirir (parent'ın yerelinde). Noktalar 5 mm'den az değiştiyse ağ yeniden kurulmaz.
static func rope_to(mi: MeshInstance3D, pts: Array) -> void:
	if not is_instance_valid(mi) or pts.size() < 2:
		return
	var last: Array = mi.get_meta("rope_pts", [])
	if last.size() == pts.size():
		var same := true
		for i in pts.size():
			if (last[i] as Vector3).distance_squared_to(pts[i]) > 0.000025:
				same = false
				break
		if same:
			return
	mi.set_meta("rope_pts", pts.duplicate())
	var spec: Array = mi.get_meta("rope", [0.03, Color("b89a6a")])
	mi.mesh = rope_mesh(pts, float(spec[0]), spec[1])


## Sarkan ipin noktaları: a'dan b'ye, ortası sag kadar aşağıda (n parça için n+1 nokta; zincir eğrisine yakın parabol).
static func sag_points(a: Vector3, b: Vector3, sag: float, n := 8) -> Array:
	var pts: Array = []
	n = maxi(1, n)
	for i in n + 1:
		var t := float(i) / n
		pts.append(a.lerp(b, t) + Vector3.DOWN * sag * 4.0 * t * (1.0 - t))
	return pts


## Yerde kangal: düz sarmal (dıştan içe turns tur), merkez p (parent'ın yerelinde), r dış yarıçap. Üstte ip ucu.
## Örnek: Stage.rope_coil(iskele, Vector3(1, 0, 2), 0.3) — kazığın dibinde, güvertede, kayıkta.
static func rope_coil(parent: Node3D, p: Vector3, r := 0.3, turns := 3.5, thick := 0.03, col := Color("b89a6a")) -> MeshInstance3D:
	var pts: Array = []
	var steps := int(turns * 14.0)
	for i in steps + 1:
		var t := float(i) / steps
		var a := t * turns * TAU
		var rr := lerpf(r, r * 0.35, t)
		pts.append(p + Vector3(cos(a) * rr, thick + t * thick * 1.6, sin(a) * rr))
	var mi := MeshInstance3D.new()
	mi.set_meta("no_walk", true)
	mi.mesh = rope_mesh(pts, thick, col)
	mi.material_override = rope_material()
	parent.add_child(mi)
	return mi


## Bir direğe/kazığa sarılmış ip turları: center (parent yerelinde) dikey eksen, y0'dan y1'e turns tur. Dönüş: sarımın
## son noktası (ip oradan devam eder).
static func rope_wrap(parent: Node3D, center: Vector3, radius: float, y0: float, y1: float, turns := 3.0, thick := 0.032,
		col := Color("b89a6a"), phase := 0.0) -> MeshInstance3D:
	var pts: Array = []
	var steps := int(turns * 12.0)
	for i in steps + 1:
		var t := float(i) / steps
		var a := phase + t * turns * TAU
		pts.append(center + Vector3(cos(a) * radius, lerpf(y0, y1, t), sin(a) * radius))
	var mi := MeshInstance3D.new()
	mi.set_meta("no_walk", true)
	mi.set_meta("end", pts[-1])
	mi.mesh = rope_mesh(pts, thick, col)
	mi.material_override = rope_material()
	parent.add_child(mi)
	return mi


## Burgulu ip ağı: noktalardan geçen 6 yüzlü boru; ~9 cm'de bir halka, yüzler bir açık bir koyu (sarmal şerit).
static func rope_mesh(pts: Array, r: float, col: Color) -> ArrayMesh:
	const SIDES := 6
	var ring_pts: Array = []
	var ring_t: Array = []
	for i in pts.size() - 1:
		var a: Vector3 = pts[i]
		var b: Vector3 = pts[i + 1]
		var m := maxi(1, int(ceil(a.distance_to(b) / 0.09)))
		for k in m:
			ring_pts.append(a.lerp(b, float(k) / m))
	ring_pts.append(pts[-1])
	var n := ring_pts.size()
	var dark := col.darkened(0.3)
	var light := col.lightened(0.08)
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var cols := PackedColorArray()
	var rings: Array = []
	var prev_side := Vector3.ZERO
	for i in n:
		var p: Vector3 = ring_pts[i]
		var tan: Vector3 = ((ring_pts[mini(i + 1, n - 1)] as Vector3) - (ring_pts[maxi(i - 1, 0)] as Vector3))
		tan = tan.normalized() if tan.length() > 0.0001 else Vector3.UP
		var side := prev_side - tan * prev_side.dot(tan) if prev_side != Vector3.ZERO else Vector3.ZERO
		if side.length() < 0.001:
			side = tan.cross(Vector3.UP if absf(tan.y) < 0.95 else Vector3.RIGHT)
		side = side.normalized()
		prev_side = side
		var up := side.cross(tan).normalized()
		var ring: Array = []
		for k in SIDES:
			var ang := TAU * k / SIDES
			ring.append(side * cos(ang) + up * sin(ang))
		rings.append([p, ring])
	for i in n - 1:
		var p0: Vector3 = rings[i][0]
		var p1: Vector3 = rings[i + 1][0]
		var r0: Array = rings[i][1]
		var r1: Array = rings[i + 1][1]
		for k in SIDES:
			var k2 := (k + 1) % SIDES
			var c := light if (k + i) % 2 == 0 else dark      # her halkada bir yüz kayar: sarmal burgu
			var q := [p0 + (r0[k] as Vector3) * r, p0 + (r0[k2] as Vector3) * r, p1 + (r1[k2] as Vector3) * r, p1 + (r1[k] as Vector3) * r]
			var qn := [r0[k], r0[k2], r1[k2], r1[k]]
			for j: int in [0, 1, 2, 0, 2, 3]:      # Godot'da ön yüz saat yönünde
				verts.append(q[j])
				norms.append(qn[j])
				cols.append(c)
	# Uçlar kapalı ve yuvarlatılmış (tur 3: açık uçlu ip yerde sert kenarlı boru gibi görünüyordu)
	if n >= 2:
		for e in 2:
			var ri: int = 0 if e == 0 else n - 1
			var rp: Vector3 = rings[ri][0]
			var rr: Array = rings[ri][1]
			var tdir: Vector3 = ((ring_pts[ri] as Vector3) - (ring_pts[1 if e == 0 else n - 2] as Vector3))
			tdir = tdir.normalized() if tdir.length() > 0.0001 else Vector3.UP
			var tip := rp + tdir * r * 0.7
			for k in SIDES:
				var k2 := (k + 1) % SIDES
				var tri := [rp + (rr[k] as Vector3) * r, tip, rp + (rr[k2] as Vector3) * r]
				for j: int in [0, 1, 2, 2, 1, 0]:      # iki yüzlü: sarım yönünden bağımsız görünür
					verts.append(tri[j])
					norms.append(((tri[j] as Vector3) - rp + tdir * r * 0.3).normalized())
					cols.append(dark)
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_COLOR] = cols
	var am := ArrayMesh.new()
	if verts.size() > 0:
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return am


## İp malzemesi: köşe rengi, çizgi film gölgesi, dış çizgi (Props malzemesinin köşe renkli kopyası).
static func rope_material() -> StandardMaterial3D:
	if _rope_mat == null:
		_rope_mat = Props.mat(Color.WHITE).duplicate() as StandardMaterial3D
		_rope_mat.vertex_color_use_as_albedo = true
		_rope_mat.vertex_color_is_srgb = true
	return _rope_mat


## approach'un zemini izleyen hâli: who target'a (tam o noktaya) yürür, her adımda ayağı ground(x, z)'ye basar (eğimde,
## kumda doğrusal tween karakteri havada ya da gömülü yürütüyordu: VISAUDIT float). Varınca face_at'e döner (verilmezse
## yürüdüğü yöne bakar). Otomatik testte (PACE dışı) hemen varır. settle() ile beklenebilir ("stage_walk").
## Örnek: await Stage.walk_on_ground(asker, oyuncu_onu, _ground_y, 3.2, oyuncu.global_position)
static func walk_on_ground(who: Node3D, target: Vector3, ground: Callable, speed := 1.6, face_at := Vector3.INF) -> void:
	if not is_instance_valid(who) or not who.is_inside_tree():
		return
	var from := who.global_position
	var to := Vector3(target.x, float(ground.call(target.x, target.z)), target.z)
	face(who, to)
	if fast() or Vector2(to.x - from.x, to.z - from.z).length() < 0.05:
		who.global_position = to
		if face_at != Vector3.INF:
			face(who, face_at)
		return
	var t := clampf(Vector2(to.x - from.x, to.z - from.z).length() / maxf(speed, 0.1), 0.25, 8.0)
	who.set_meta("stage_walk", true)
	var tw := who.create_tween()
	tw.tween_method(func(k: float) -> void:
		if is_instance_valid(who):
			var q := from.lerp(to, k)
			who.global_position = Vector3(q.x, float(ground.call(q.x, q.z)), q.z), 0.0, 1.0, t)
	await tw.finished
	if is_instance_valid(who):
		who.remove_meta("stage_walk")
		if face_at != Vector3.INF:
			face(who, face_at)


# ---------------------------------------------------------------- iş istasyonları (yayma P0)
# Bölüm 2 kızağındaki yol kenarı işlerinin (slipway._job_*) ortak hâli: figür + aleti + işlenen nesne + yerde izi.
# Kimse havaya iş yapmaz: alet elde (Items.attach_tool), nesne aletin vurduğu yerde, ayak zeminde.

const STATION_KINDS := ["hammer_log", "chop_log", "saw_log", "stir_pot", "dig", "sweep", "paint_wall", "grease_log",
	"carry_sack", "carry_crate", "carry_basket", "carry_plank", "carry_earth", "carry_barrel", "log_pair", "drink",
	"report", "coil_rope"]


## İş istasyonu kurar: at (dünya; y ground'dan) noktasında, face yönüne bakan işçi(ler) ve işi. Döner: kök düğüm
## (meta "who": figürler — canlıysa Person/Soldier, donuksa Crowd çoklu ağı). Faz: her figürün Rig saati rastgele
## başlar, yan yana iki istasyon aynı anda vurmaz.
## kind: STATION_KINDS. opts: "ground": Callable(x, z) -> y (nesneler ve ayaklar zemine oturur; canlı figürün tabanı
##   her karede zemine basar), "live" (true: canlı figür; false: Crowd donuk figürü, aleti pişmiş — ucuz, uzak sıralar
##   için; yalnız tek kişilik işler), "coat", "hat" ("bork", "turban"...), "person" (true: Person, false: Soldier;
##   taşıyıcılar hep Person), "fire" (stir_pot: kazanın altında ateş, true), "seed".
## Örnek: Stage.station(self, "hammer_log", Vector3(4, 0, 9), Vector3.LEFT, {"ground": _ground_y})
## Örnek: for i in 6: Stage.station(ordugah, ["dig", "sweep", "stir_pot"][i % 3], noktalar[i], yonler[i], {"live": false})
static func station(parent: Node3D, kind: String, at: Vector3, face_dir: Vector3, opts := {}) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(opts.get("seed", hash(Vector3i(roundi(at.x * 10), 0, roundi(at.z * 10)))))
	var ground: Callable = opts.get("ground", Callable())
	var root := Node3D.new()
	root.name = "Station_" + kind
	parent.add_child(root)
	var y0 := float(ground.call(at.x, at.z)) if ground.is_valid() else at.y
	var f := Vector3(face_dir.x, 0, face_dir.z)
	f = f.normalized() if f.length() > 0.01 else Vector3.BACK
	root.global_transform = Transform3D(Basis(Vector3.UP, atan2(f.x, f.z)), Vector3(at.x, y0, at.z))
	var live: bool = opts.get("live", true)
	var coats := [Color("7a5232"), Color("2f5fa8"), Color("b3262d"), Color("3f7a3a"), Color("c98a3a"), Color("6a5040")]
	var coat: Color = opts.get("coat", coats[rng.randi() % coats.size()])
	var hat: String = opts.get("hat", ["bork", "turban", "turban", "azap"][rng.randi() % 4])
	var who: Array = []
	var gy := func(lp: Vector3) -> float:       # yerel noktanın altındaki zemin (kökün yerelinde y)
		if not ground.is_valid():
			return 0.0
		var g := root.to_global(Vector3(lp.x, 0, lp.z))
		return float(ground.call(g.x, g.z)) - y0
	var on_ground := func(lp: Vector3) -> Vector3:
		return Vector3(lp.x, lp.y + gy.call(lp), lp.z)
	var tool := ""
	var act := ""
	match kind:
		"hammer_log":
			tool = "mallet"
			act = "hammer"
			# Kütük iki takozun üstünde, tokmağın indiği yükseklikte; üstünde çakılan kama
			var b: Vector3 = on_ground.call(Vector3(0, 0, 0.62))
			for sx: float in [-0.6, 0.6]:
				Props.box(root, Vector3(0.3, 0.32, 0.36), on_ground.call(Vector3(sx, 0.16, 0.62)), Color("6a4a2e"))
			_st_log(root, b + Vector3(0, 0.5, 0), Vector3.RIGHT, 1.8, 0.19)
			Props.prism(root, Vector3(0.12, 0.14, 0.16), b + Vector3(0.05, 0.74, 0), Color("b08a5c"))
			_st_chips(root, rng, on_ground, Vector3(0, 0, 0.5), 5, Color("d8c090"))
		"chop_log":
			tool = "axe"
			act = "chop"
			var b: Vector3 = on_ground.call(Vector3(0.05, 0, 0.82))
			Props.cyl(root, 0.26, 0.62, b + Vector3(0, 0.31, 0), Color("6b4a2e"), Vector3.ZERO, 9)
			Props.cyl(root, 0.24, 0.02, b + Vector3(0, 0.625, 0), Color("c8a878"), Vector3.ZERO, 9)
			_st_log(root, b + Vector3(0, 0.74, 0), Vector3.RIGHT, 0.5, 0.11)
			_st_chips(root, rng, on_ground, Vector3(0, 0, 0.8), 7, Color("d8c090"))
		"saw_log":
			tool = "saw"
			act = "saw"
			var b: Vector3 = on_ground.call(Vector3(0, 0, 0.75))
			for sx: float in [-0.55, 0.55]:
				for sz: float in [-0.18, 0.18]:
					_st_rod(root, b + Vector3(sx, 0, sz), b + Vector3(sx * 0.95, 0.62, 0), 0.03, Color("5f4329"))
			_st_log(root, b + Vector3(0, 0.74, 0), Vector3.RIGHT, 1.7, 0.15)
			_st_chips(root, rng, on_ground, Vector3(0, 0, 0.75), 8, Color("e8d4a0"), 0.03)
		"stir_pot":
			tool = "ladle"
			act = "stir"
			var b: Vector3 = on_ground.call(Vector3(0, 0, 0.8))
			for k in 3:
				var a := k * TAU / 3.0 + 0.3
				_st_rod(root, b + Vector3(cos(a) * 0.42, 0, sin(a) * 0.42), b + Vector3(cos(a) * 0.3, 0.42, sin(a) * 0.3), 0.025, Color("2a2622"))
			Props.cyl(root, 0.36, 0.42, b + Vector3(0, 0.6, 0), Color("3a3634"), Vector3.ZERO, 12, 0.33)
			Props.cyl(root, 0.33, 0.02, b + Vector3(0, 0.79, 0), Color("8a6a3a"), Vector3.ZERO, 12)
			if opts.get("fire", true):
				Vfx.fire(root, b + Vector3(0, 0.08, 0), 0.4)
				for k in 5:
					var a := k * 1.3
					Props.cyl(root, 0.04, 0.5, b + Vector3(cos(a) * 0.15, 0.05, sin(a) * 0.15), Color("4a3422"), Vector3(90, rad_to_deg(a), 0), 5)
		"dig":
			tool = "shovel"
			act = "dig"
			Props.ball(root, 0.45, on_ground.call(Vector3(0.75, 0.0, 0.55)), Color("5a4630"), Vector3(1.2, 0.42, 1.0), 8)
			Props.cyl(root, 0.32, 0.02, on_ground.call(Vector3(0.08, 0.005, 0.95)), Color("3a2c1e"), Vector3.ZERO, 10)
			_st_chips(root, rng, on_ground, Vector3(0.3, 0, 0.8), 6, Color("4a3a28"), 0.06)
		"sweep":
			tool = "broom"
			act = "sweep"
			_st_chips(root, rng, on_ground, Vector3(0.1, 0, 1.1), 9, Color("9a8a5a"), 0.05)
		"paint_wall":
			tool = "brush"
			act = "paint"
			var b: Vector3 = on_ground.call(Vector3(0, 0, 0.72))
			for i in 4:
				Props.box(root, Vector3(0.36, 1.6, 0.05), b + Vector3(-0.54 + i * 0.36, 0.8, 0), Color("a88058").lerp(Color("8a6440"), i % 2))
			Props.box(root, Vector3(0.7, 0.5, 0.01), b + Vector3(-0.1, 1.1, -0.03), Color("c0402a"))
			_st_bucket(root, on_ground.call(Vector3(0.45, 0, 0.25)), Color("c0402a"))
		"grease_log":
			tool = "brush"
			act = "paint"
			var b: Vector3 = on_ground.call(Vector3(0, 0, 0.62))
			for sx: float in [-0.7, 0.7]:
				_st_rod(root, b + Vector3(sx, 0, -0.18), b + Vector3(sx, 0.62, 0), 0.035, Color("5f4329"))
				_st_rod(root, b + Vector3(sx, 0, 0.18), b + Vector3(sx, 0.62, 0), 0.035, Color("5f4329"))
			_st_log(root, b + Vector3(0, 0.78, 0), Vector3.RIGHT, 2.0, 0.17)
			Props.box(root, Vector3(0.6, 0.012, 0.2), b + Vector3(-0.3, 0.955, 0), Color("e8cf7a"))
			_st_bucket(root, on_ground.call(Vector3(0.5, 0, 0.2)), Color("e8cf7a"))
		"carry_sack", "carry_crate", "carry_basket", "carry_plank", "carry_earth", "carry_barrel":
			var p := _st_person(root, coat, hat, on_ground.call(Vector3.ZERO))
			p.carry(kind.substr(6))
			who.append(p)
		"log_pair":
			var log := Node3D.new()
			root.add_child(log)
			log.position = Vector3(0, gy.call(Vector3.ZERO) + 1.0, 0.45)
			_st_log(log, Vector3.ZERO, Vector3.RIGHT, 2.6, 0.15)
			for sx: float in [-0.95, 0.95]:
				var p := _st_person(root, coats[(rng.randi() + int(sx > 0)) % coats.size()], hat if sx < 0 else "turban", on_ground.call(Vector3(sx, 0, 0)))
				p.set_activity("carry")
				who.append(p)
				grip_hold(p, log, [Vector3(sx - 0.2, 0.02, 0.05), Vector3(sx + 0.2, 0.02, 0.05)], -1.0, 0.08)
		"drink":
			var s := Soldier.new(coat, "stand", hat)
			root.add_child(s)
			s.position = on_ground.call(Vector3.ZERO)
			s.set_meta("no_talk", true)
			var el: Node3D = s.rig.elbow_r if s.rig else null
			if el:
				var jug := Node3D.new()
				el.add_child(jug)
				jug.position = el.get_meta("hand", Vector3(0, -0.26, 0.01)) + Vector3(0, -0.05, 0.05)
				Props.cyl(jug, 0.09, 0.22, Vector3.ZERO, Color("b86a3a"), Vector3.ZERO, 8, 0.07)
				Props.cyl(jug, 0.035, 0.08, Vector3(0, 0.14, 0), Color("a85e32"), Vector3.ZERO, 6)
			var tw := s.create_tween().set_loops()
			var k := [0]
			tw.tween_interval(rng.randf_range(2.6, 4.2))
			tw.tween_callback(func():
				if s.rig and s.rig.lock == 0 and s.is_visible_in_tree():
					k[0] += 1
					s.rig.emote("sip" if k[0] % 3 != 0 else "facepalm"))
			who.append(s)
		"report":
			var a := _st_person(root, Color("3f7a3a"), "turban", on_ground.call(Vector3(-0.55, 0, 0)))
			a.rotation.y = PI * 0.5
			a.set_activity("hold_paper")
			var pp := Node3D.new()
			a._elbow_r.add_child(pp)
			pp.position = a._elbow_r.get_meta("hand", Vector3(0, -0.27, 0.01)) + Vector3(-0.05, 0.0, 0.06)
			Props.box(pp, Vector3(0.24, 0.32, 0.006), Vector3(0, 0.1, 0), Color("efe6cf"), Vector3(-20, 0, 0))
			var b := Soldier.new(Color("b3262d"), "stand", "azap")
			root.add_child(b)
			b.position = on_ground.call(Vector3(0.55, 0, 0))
			b.rotation.y = -PI * 0.5
			b.rig.activity = "arms_folded"
			b.set_meta("no_talk", true)
			who.append_array([a, b])
		"coil_rope":
			var p := _st_person(root, coat, hat, on_ground.call(Vector3.ZERO))
			p.set_activity("crouch")
			who.append(p)
			var c: Vector3 = on_ground.call(Vector3(0.1, 0, 0.55))
			rope_coil(root, c, 0.26, 4.0, 0.026)
			var rp := rope(root, c + Vector3(0.05, 0.08, 0), c + Vector3(0, 0.6, -0.1), 0.05, 0.022)
			var tw := p.create_tween().set_loops()
			tw.tween_method(func(_k: float) -> void:
				if is_instance_valid(p) and is_instance_valid(rp) and p.rig and p.rig.elbow_r:
					var h := root.to_local(p.rig.elbow_r.to_global(p.rig.elbow_r.get_meta("hand", Vector3(0, -0.27, 0.01))))
					rope_to(rp, sag_points(c + Vector3(0.05, 0.08, 0), h, 0.06, 6)), 0.0, 1.0, 1.0)
		_:
			push_warning("Stage.station: bilinmeyen tür " + kind)
	if tool != "":
		if live:
			var w: Node3D
			if opts.get("person", rng.randf() < 0.4):
				w = _st_person(root, coat, hat, on_ground.call(Vector3.ZERO))
				(w as Person).set_activity(act)
			else:
				w = Soldier.new(coat, "stand", hat)
				root.add_child(w)
				w.position = on_ground.call(Vector3.ZERO)
				w.set_meta("no_talk", true)
			var t_opts := {"activity": act}
			if kind == "stir_pot":
				t_opts["aim"] = root.to_global(on_ground.call(Vector3(0, 0.66, 0.8)))
				t_opts["aim_world"] = true
			w.call("give_tool", tool, t_opts)
			who.append(w)
		else:
			var xf := root.global_transform * Transform3D(Basis.from_scale(Vector3.ONE * rng.randf_range(0.95, 1.05)), on_ground.call(Vector3.ZERO))
			var nodes := Crowd.place(parent, [[parent.global_transform.affine_inverse() * xf,
				{"side": "O", "coat": coat, "hat": hat if hat in ["bork", "turban"] else "bork", "arm": "tool:" + tool, "pose": act}]], true, false)
			who.append_array(nodes)
	# Ayaklar zeminde (canlı figürler; eğimde, kütüğe dayanırken)
	if ground.is_valid():
		for w in who:
			if w is Person or w is Soldier:
				var tw := (w as Node3D).create_tween().set_loops()
				tw.tween_method(func(_k: float) -> void:
					if is_instance_valid(w) and (w as Node3D).is_visible_in_tree():
						plant_feet(w, ground, 0.25), 0.0, 1.0, 0.5)
	root.set_meta("who", who)
	return root


static func _st_person(root: Node3D, coat: Color, hat: String, p: Vector3) -> Person:
	var ps := Person.new({"coat": coat, "pants": Color("3a3028"), "hat": hat if hat in ["turban", "none", "kalpak"] else "turban",
		"mustache": true, "beard": randf() < 0.4, "skin": Color("d9a07a")})
	ps.set_meta("no_talk", true)
	root.add_child(ps)
	ps.position = p
	return ps


static func _st_rod(parent: Node3D, a: Vector3, b: Vector3, r: float, col: Color, seg := 6) -> MeshInstance3D:
	var d := b - a
	if d.length() < 0.01:
		return null
	var mi := Props.cyl(parent, r, d.length(), (a + b) * 0.5, col, Vector3.ZERO, seg)
	var y := d.normalized()
	var x := y.cross(Vector3.UP if absf(y.y) < 0.95 else Vector3.RIGHT).normalized()
	mi.basis = Basis(x, y, x.cross(y))
	return mi


## Yatık kütük: kabuklu gövde, iki ucunda açık renk kesik yüz.
static func _st_log(parent: Node3D, c: Vector3, along: Vector3, length: float, r: float) -> void:
	var u := along.normalized()
	_st_rod(parent, c - u * length * 0.5, c + u * length * 0.5, r, Color("7e5634"), 8)
	for sgn: float in [-1.0, 1.0]:
		_st_rod(parent, c + u * (length * 0.5 - 0.005) * sgn, c + u * (length * 0.5 + 0.012) * sgn, r * 0.92, Color("d8b888"), 8)


static func _st_bucket(parent: Node3D, p: Vector3, inside: Color) -> void:
	Props.cyl(parent, 0.15, 0.3, p + Vector3(0, 0.15, 0), Color("6b4a2e"), Vector3.ZERO, 9, 0.17)
	Props.cyl(parent, 0.155, 0.02, p + Vector3(0, 0.29, 0), inside, Vector3.ZERO, 9)


## Yere saçılmış talaş/toprak parçacıkları (yassı, zemine oturur).
static func _st_chips(parent: Node3D, rng: RandomNumberGenerator, on_ground: Callable, c: Vector3, n: int, col: Color, s := 0.08) -> void:
	for i in n:
		var p: Vector3 = on_ground.call(c + Vector3(rng.randf_range(-0.6, 0.6), 0.008, rng.randf_range(-0.45, 0.45)))
		Props.box(parent, Vector3(s, 0.012, s * 0.5), p, col, Vector3(0, rng.randf() * 180.0, 0))


# ---------------------------------------------------------------- zincir (yayma P0)
static var _link_mesh: Mesh


## Zincir: iki ucu bağlı (a, b parent'ın yerelinde), sag kadar sarkan, halka halka demir zincir (her halka bir
## öncekine dik, oval); tek çoklu ağ (tek çizim). link: bir halkanın genişliği (m). Hareket ederse chain_to.
## Örnek: var z := Stage.chain(gemi, baba, capa_deligi, 0.3, 0.1) — çapa zinciri, Haliç zinciri (yakın çekim),
## makara zinciri (34o), öküz koşum zinciri (35o). Uzak çekimde Stage.rope koyu renk yeter (daha ucuz).
static func chain(parent: Node3D, a: Vector3, b: Vector3, sag := 0.1, link := 0.09, col := Color("3a3a40")) -> MultiMeshInstance3D:
	var mmi := MultiMeshInstance3D.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	if _link_mesh == null:
		var tm := TorusMesh.new()
		tm.inner_radius = 0.3
		tm.outer_radius = 0.5
		tm.rings = 8
		tm.ring_segments = 4
		_link_mesh = tm
	mm.mesh = _link_mesh
	mmi.multimesh = mm
	mmi.material_override = Props.mat(col)
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.set_meta("chain", link)
	mmi.set_meta("no_walk", true)
	parent.add_child(mmi)
	chain_to(mmi, sag_points(a, b, sag, 12 if sag > 0.0 else 1))
	return mmi


## Zinciri yeni noktalardan geçirir (parent'ın yerelinde): halkalar yay boyunca eşit aralıkla yeniden dizilir.
static func chain_to(mmi: MultiMeshInstance3D, pts: Array) -> void:
	if not is_instance_valid(mmi) or pts.size() < 2:
		return
	var link: float = mmi.get_meta("chain", 0.09)
	var gap := link * 1.12
	var total := 0.0
	for i in pts.size() - 1:
		total += (pts[i] as Vector3).distance_to(pts[i + 1])
	var n := maxi(2, int(total / gap) + 1)
	var mm := mmi.multimesh
	mm.instance_count = n
	var seg := 0
	var seg_start := 0.0
	for k in n:
		var d := minf(k * gap, total)
		while seg < pts.size() - 2 and seg_start + (pts[seg] as Vector3).distance_to(pts[seg + 1]) < d:
			seg_start += (pts[seg] as Vector3).distance_to(pts[seg + 1])
			seg += 1
		var p0: Vector3 = pts[seg]
		var p1: Vector3 = pts[seg + 1]
		var sl := maxf(p0.distance_to(p1), 0.0001)
		var p := p0.lerp(p1, clampf((d - seg_start) / sl, 0.0, 1.0))
		var tan := (p1 - p0).normalized()
		var up := Vector3.UP if absf(tan.y) < 0.95 else Vector3.RIGHT
		var side := up.cross(tan).normalized()
		var ax := side if k % 2 == 0 else tan.cross(side).normalized()      # her halka öncekine dik
		var x := ax.cross(tan).normalized()
		var b := Basis(x, ax, tan) * Basis.from_scale(Vector3(link, link, link * 1.55))
		mm.set_instance_transform(k, Transform3D(b, p))
