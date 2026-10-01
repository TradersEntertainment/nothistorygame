class_name WaveRunner
extends RefCounted
## Hikâyede dalgalı çarpışma: aynı anda en çok `max_active` rakip, kalanı düştükçe takviye olarak gelir
## (merdiven başından, gedik ağzından yürüyüp gelir). Can oyuncunun canıdır (StoryDuel gibi): ölüm yok, can biterse
## oyuncu yere düşer ve çarpışma kaybedilir; bölüm sonuca bakar.
##
## waves: [{"specs": [StoryDuel spec...], "max_active": 3, "allies": 0, "limit": 60.0, "skill": 0.4,
##          "intro": Callable (dalga başında beklenir, ör. replik)}]
## Süre dolduğunda oyuncu ayaktaysa dalga tutulmuş sayılır. Dalga arasında +35 can.
## Döner: {"won": bool (bütün dalgalar), "waves_won": int, "hits_taken", "parries", "kills"}

static func run(scene: Node3D, hud: Hud, player: Player, waves: Array, p_blade := "spathion") -> Dictionary:
	var duel := Duel.new()
	duel.link_player = true
	# Test: yenilgi denenmiyorsa bot şansa kalmasın (yenilgi yolu =lose varyantlarıyla denenir)
	duel.god = GameState.autotest and not GameState.autotest_variant.ends_with("lose")
	hud.add_child(duel)
	var res := {"won": false, "waves_won": 0, "hits_taken": 0, "parries": 0, "kills": 0}
	var prev_level := Audio.intensity_level()
	for wi in waves.size():
		var w: Dictionary = waves[wi]
		if w.has("intro") and (w["intro"] as Callable).is_valid():
			await (w["intro"] as Callable).call()
		var skill: float = w.get("skill", 0.4)
		var st := {"queue": (w["specs"] as Array).duplicate(), "won": false, "lost": false}
		var max_active: int = w.get("max_active", 3)
		var list: Array[Duelist] = []
		while list.size() < max_active and not (st["queue"] as Array).is_empty():
			list.append(StoryDuel.make(scene, player, (st["queue"] as Array).pop_front(), skill))
		duel.reserve = (st["queue"] as Array).size()
		var spawn_next := func(_d: Duelist) -> void:
			var q: Array = st["queue"]
			if q.is_empty() or not duel.active:
				return
			var nd := StoryDuel.make(scene, player, q.pop_front(), skill)
			duel.reserve = q.size()
			nd.died.connect(st["spawn"])
			duel.add_enemy(nd)
		st["spawn"] = spawn_next
		for d in list:
			d.died.connect(spawn_next)
		var on_fin := func(won: bool) -> void:
			st["won"] = won
			st["lost"] = not won
		duel.finished.connect(on_fin)
		player.face(list[0].global_position + Vector3(0, 1.5, 0))
		hud.set_objective(TranslationServer.translate("UI_OBJ_WAVE") % [wi + 1, waves.size(), (w["specs"] as Array).size()])
		duel.start(player, list, p_blade)
		Audio.intensity(3)
		var side_fights: Array = []
		if int(w.get("allies", 0)) > 0:
			side_fights = StoryDuel._skirmish(scene, player, list, w["specs"], p_blade)
		var limit: float = w.get("limit", 60.0)
		var t := 0.0
		while duel.active and t < limit:
			await scene.get_tree().process_frame
			t += scene.get_process_delta_time()
		duel.finished.disconnect(on_fin)
		res["hits_taken"] += duel.hits_taken
		res["parries"] += duel.parries
		res["kills"] += duel.kills
		duel.hits_taken = 0
		duel.kills = 0
		# Süre dolup oyuncu hâlâ ayaktaysa hat tutulmuştur (takılan rakip yüzünden kaybedilmez)
		var won: bool = st["won"] or not st["lost"]
		if st["lost"]:
			player.down()
		# Kalanlar geri çekilir (yenilgide de, süre dolunca da: hikâye durmaz)
		duel.reserve = 0
		for d in duel.alive_enemies():
			d.hp = 0.0
			d._die()
		if duel.active:
			duel.stop()
		for pair in side_fights:
			for k in 2:
				var x: Duelist = pair[k]
				if is_instance_valid(x):
					if k == 1:
						x.hp = 0.0
						x._die()
					else:
						x.target = null
		hud.set_objective("")
		if GameState.autotest:
			print("WAVERUNNER wave=%d/%d won=%s t=%.1f pw=%.2f foe_dmg=%.1f" % [wi + 1, waves.size(), won, t, duel.parry_win,
				list[0].damage if not list.is_empty() and is_instance_valid(list[0]) else -1.0])
		while player.is_down:
			await scene.get_tree().process_frame
		if not won:
			break
		res["waves_won"] += 1
		if wi < waves.size() - 1:
			# Dalga arası: nefeslen (arenadaki gibi +35 can)
			player.hp = minf(Player.MAX_HP, player.hp + 35.0)
			Audio.intensity(1)
			await scene.get_tree().create_timer(1.5).timeout
	res["won"] = res["waves_won"] == waves.size()
	Audio.intensity(maxi(prev_level, 1))
	await scene.get_tree().create_timer(1.0).timeout
	duel.queue_free()
	return res
