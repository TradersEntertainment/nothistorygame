class_name StoryDuel
extends RefCounted
## Hikâyede kısa düello: hazır Duel/Duelist sistemi, hikâyeye göre ayarlı.
##   Oyuncu ölmez (god: en az 1 can kalır). Rakipler ölmez: canı bitince kılıcını bırakıp geri çekilir.
##   Rakiplerin becerisi düşük-orta (hikâye bölümünde öğretici gibi); tuş ipucunu Duel kendisi altta gösterir.
## specs: [{"pos": Vector3, "look": Dictionary, "blade": "kilij"|"spathion", "shield": bool, "name": "SPK_…"}]

## Döner: oyuncu kazandıysa true (god açıkken hep true; süre dolarsa rakipler geri çekilir).
static func fight(scene: Node3D, hud: Hud, player: Player, specs: Array, p_blade := "spathion", skill := 0.35, limit := 75.0) -> bool:
	var duel := Duel.new()
	duel.god = true
	hud.add_child(duel)
	var list: Array[Duelist] = []
	for sp in specs:
		var d := Duelist.new(sp["look"], sp.get("blade", "kilij"), skill, sp.get("shield", false))
		d.name_key = sp.get("name", "SPK_SOLDIER")
		d.set_meta("yield", true)
		d.damage = 12.0
		d.max_hp = 60.0
		d.hp = d.max_hp
		scene.add_child(d)
		d.global_position = _free_spot(player, sp["pos"])
		d.look_at(Vector3(player.global_position.x, d.global_position.y, player.global_position.z), Vector3.UP)
		d.rotate_y(PI)
		list.append(d)
	player.face(list[0].global_position + Vector3(0, 1.5, 0))
	hud.set_objective(TranslationServer.translate("UI_OBJ_DUEL") % list.size())
	duel.start(player, list, p_blade)
	var won := true
	var t := 0.0
	while duel.active and t < limit:
		await scene.get_tree().process_frame
		t += scene.get_process_delta_time()
	if duel.active:
		# Süre doldu: kalanlar geri çekilir (hikâye durmaz)
		for d in duel.alive_enemies():
			d.hp = 0.0
			d._die()
		duel.stop()
	hud.set_objective("")
	if GameState.autotest:
		print("STORYDUEL kills=%d parries=%d hits_taken=%d t=%.1f" % [duel.kills, duel.parries, duel.hits_taken, t])
	await scene.get_tree().create_timer(1.2).timeout
	duel.queue_free()
	return won


## Rakip duvarın, çitin, sandığın içinde doğmasın: istenen noktada gövde boyu bir kapsül boş değilse
## oyuncunun çevresinde (aynı uzaklıkta) açıyı kaydırarak ilk boş yeri bul.
static func _free_spot(player: Player, want: Vector3) -> Vector3:
	var space := player.get_world_3d().direct_space_state
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.7
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.collision_mask = 1
	q.exclude = [player.get_rid()]
	var c := player.global_position
	var off := want - c
	off.y = 0.0
	var r := maxf(off.length(), 2.5)
	var a0 := atan2(off.x, off.z)
	for k in 13:
		var a := a0 + (k + 1) / 2 * 0.35 * (1.0 if k % 2 == 0 else -1.0)
		for rr: float in [r, r - 0.8, r + 0.8]:
			var p := c + Vector3(sin(a), 0, cos(a)) * rr
			p.y = want.y
			q.transform = Transform3D(Basis(), p + Vector3(0, 1.0, 0))
			if space.intersect_shape(q, 1).is_empty():
				return p
	return want
