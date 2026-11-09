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
