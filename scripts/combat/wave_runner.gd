class_name WaveRunner
extends RefCounted
## Hikâyede dalgalı çarpışma ("ultra savaş", Melee): dalganın rakipleri giriş noktasından (gedik ağzı, sur yolunun ucu,
## merdiven başı) bölük hâlinde koşarak gelir, yoktan belirmez. Aynı anda oyuncuya en çok `max_active` saldırır;
## ötekiler dost askerlerle çarpışır ya da sırasını bekler. Kalan takviye düştükçe aynı yoldan koşarak gelir.
## Alarm: çevredeki adsız askerler (kendi tarafımız) silahlanıp kalkar ve dövüşe katılır; karşı taraftan çevredekiler
## (nöbetçiler) de üstümüze gelir. Dövüşten sonra dostlar yerlerine döner.
## Can oyuncunun canıdır (StoryDuel gibi): ölüm yok, can biterse oyuncu yere düşer ve çarpışma kaybedilir.
##
## waves: [{"specs": [StoryDuel spec...], "max_active": 3, "allies": 0, "limit": 60.0, "skill": 0.4,
##          "from": Vector3 | [Vector3...] (giriş noktaları; yoksa dövüş yerinin ötesinde kendiliğinden),
##          "via": [Vector3...] (giriş yolunun ara noktaları), "group": 4 (ilk bölük kaç kişi; yoksa max_active + 2),
##          "rally": 16.0 (alarm yarıçapı; 0 kapalı), "rally_foes": 0 (karşı taraftan kalkacak en çok),
##          "ally_from": Vector3 (taze dostların koşup geldiği yer; yoksa oyuncunun arkası),
##          "ladders": [{"base", "top", "land"}] (rakipler bu merdivenlerden tırmanıp mazgaldan atlar),
##          "intro": Callable (dalga başında beklenir, ör. replik)}]
## Süre dolduğunda oyuncu ayaktaysa dalga tutulmuş sayılır. Dalga arasında +35 can.
## Döner: {"won": bool (bütün dalgalar), "waves_won": int, "hits_taken", "parries", "kills", "thrown"}

static func run(scene: Node3D, hud: Hud, player: Player, waves: Array, p_blade := "spathion") -> Dictionary:
	var duel := Duel.new()
	duel.link_player = true
	# Test: yenilgi denenmiyorsa bot şansa kalmasın (yenilgi yolu =lose varyantlarıyla denenir)
	duel.god = GameState.autotest and not GameState.autotest_variant.ends_with("lose")
	hud.add_child(duel)
	var melee := Melee.of(scene, duel, player, p_blade)
	melee.hud = hud
	var sea = scene.get("sea_y")
	melee.water_y = float(sea) if sea != null else -INF
	var res := {"won": false, "waves_won": 0, "hits_taken": 0, "parries": 0, "kills": 0, "thrown": 0}
	var prev_level := Audio.intensity_level()
	for wi in waves.size():
		var w: Dictionary = waves[wi]
		var skill: float = w.get("skill", 0.4)
		var st := {"queue": (w["specs"] as Array).duplicate(), "won": false, "lost": false, "n": 0}
		var max_active: int = w.get("max_active", 3)
		melee.max_on_player = max_active
		# Sura dayalı merdivenler: [[Ladder, sur yolunda atlanacak yer], ...]
		for ln: Array in w.get("ladder_nodes", []):
			if melee.ladders.filter(func(l): return l["node"] == ln[0]).is_empty():
				melee.add_ladder(ln[0], ln[1])
		var group: int = w.get("group", max_active + 2)
		var list: Array[Duelist] = []
		# İlk bölük: hepsi birlikte, giriş noktasından koşarak (yoktan belirmez)
		while list.size() < group and not (st["queue"] as Array).is_empty():
			var sp: Dictionary = (st["queue"] as Array).pop_front()
			list.append(_enter(scene, player, melee, sp, w, skill, int(st["n"])))
			st["n"] = int(st["n"]) + 1
		Audio.sfx("war_cry", -3.0, randf_range(0.95, 1.05))
		# Dalganın ilk rakipleri gelmişken replik: haykıran (30o'da "İmparator geldi!" diyen savunucu) sahnededir
		if w.has("intro") and (w["intro"] as Callable).is_valid():
			await (w["intro"] as Callable).call()
		duel.reserve = (st["queue"] as Array).size()
		var spawn_next := func(_d: Duelist) -> void:
			var q: Array = st["queue"]
			if q.is_empty() or not duel.active:
				return
			var nd := _enter(scene, player, melee, q.pop_front(), w, skill, int(st["n"]))
			st["n"] = int(st["n"]) + 1
			duel.reserve = q.size() + melee.pending_foes
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
		for d in list:
			melee.add_foe(d)
		Audio.intensity(3)
		# Alarm: çevredekiler kalkar (dostlar ve, istenirse, karşı taraftan nöbetçiler)
		var rr: float = w.get("rally", 16.0)
		if rr > 0.0:
			# Kaybetme testi: yardıma kalkan dost yok (dövüşü savunmasız oyuncunun yenilgisi belirlesin; 37o'da kalkan azaplar
			# Cenevizlileri yenip "lose" testini düşürüyordu)
			var ally_cap := 0 if _lose_test() else maxi(int(w.get("allies", 0)) + 2, 3)
			var risen := melee.rally(player.global_position, rr, ally_cap, int(w.get("rally_foes", 0)), skill)
			duel.reserve = (st["queue"] as Array).size() + melee.pending_foes
			for d in risen:
				d.died.connect(spawn_next)
		# Taze dostlar: alarmla yeterince kalkmadıysa arkadan koşarak (ya da oyuncunun peşinden merdivenle) gelirler
		var want_allies := int(w.get("allies", 0))
		if want_allies > melee.rallied_allies + melee.fresh_allies and w.has("ally_ladder"):
			var al: Dictionary = w["ally_ladder"]
			melee.reinforce_climb(want_allies - melee.rallied_allies - melee.fresh_allies, al["base"], al["top"], al["land"])
		if want_allies > melee.rallied_allies + melee.fresh_allies:
			var from: Vector3 = w.get("ally_from", Vector3.INF)
			if from == Vector3.INF:
				from = _behind(player, melee, list)
			if from != Vector3.INF:
				melee.reinforce(want_allies - melee.rallied_allies - melee.fresh_allies, from, player.global_position)
		var limit: float = w.get("limit", 60.0)
		var t := 0.0
		while duel.active and t < limit:
			await scene.get_tree().process_frame
			t += scene.get_process_delta_time()
		duel.finished.disconnect(on_fin)
		res["hits_taken"] += duel.hits_taken
		res["parries"] += duel.parries
		res["kills"] += duel.kills
		res["thrown"] += duel.thrown_off
		duel.hits_taken = 0
		duel.kills = 0
		duel.thrown_off = 0
		# Süre dolup oyuncu hâlâ ayaktaysa hat tutulmuştur (takılan rakip yüzünden kaybedilmez)
		var won: bool = st["won"] or not st["lost"]
		if st["lost"]:
			player.down()
		# Kalanlar geri çekilir (yenilgide de, süre dolunca da: hikâye durmaz); merdivende olan geri iner (gizlenir)
		duel.reserve = 0
		for d in duel.alive_enemies():
			d.hp = 0.0
			if d.climbing():
				d.visible = false
				d.set_process(false)
			d._die()
		if duel.active:
			duel.stop()
		melee.idle_allies()
		hud.set_objective("")
		if GameState.autotest:
			print("WAVERUNNER wave=%d/%d won=%s t=%.1f pw=%.2f foe_dmg=%.1f allies=%d+%d rally_foes=%d thrown=%d" % [wi + 1, waves.size(), won,
				t, duel.parry_win, list[0].damage if not list.is_empty() and is_instance_valid(list[0]) else -1.0,
				melee.rallied_allies, melee.fresh_allies, melee.rallied_foes, int(res["thrown"])])
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
	# Dövüş bitti: ayaklananlar yerlerine, yardıma gelenler geldikleri yere döner
	melee.stand_down()
	res["won"] = res["waves_won"] == waves.size()
	Audio.intensity(maxi(prev_level, 1))
	await scene.get_tree().create_timer(1.0).timeout
	duel.queue_free()
	_cleanup(melee)
	return res


## Bir rakibi dalgaya sokar: merdivenden tırmanarak (ladders), giriş noktasından koşarak (from ya da kendiliğinden
## bulunan giriş) ya da giriş yolu yoksa eskisi gibi dövüş yerinde. i: dalgadaki sırası (giriş noktaları ve
## merdivenler sırayla paylaşılır).
static func _lose_test() -> bool:
	return GameState.autotest and GameState.autotest_variant.ends_with("lose")


static func _enter(scene: Node3D, player: Player, melee: Melee, sp: Dictionary, w: Dictionary, skill: float, i: int) -> Duelist:
	var d := StoryDuel.make(scene, player, sp, skill, false)
	var lads: Array = w.get("ladders", [])
	if lads.is_empty() and w.has("ladder_nodes"):
		lads = melee.ladders
	if not lads.is_empty():
		var l: Dictionary = lads[i % lads.size()]
		scene.add_child(d)
		var delay := float(i / lads.size()) * 2.4 + float(i % lads.size()) * 0.7
		if l.has("down") and float(l["down"]) > 0.0:
			delay += float(l["down"]) + 1.2       # merdiven devrik: yeniden dayanınca çıkar
		d.climb_in(l["base"], l["top"], l["land"], delay)
		melee.add_foe(d)
		return d
	# Olduğu yerde (sahnede zaten görünen biri dövüşe geçiyor: sur yoluna çıkmış tırmanan)
	if sp.get("here", false):
		d.position = sp["pos"]
		scene.add_child(d)
		d.global_position = sp["pos"]
		d.look_at(Vector3(player.global_position.x, d.global_position.y, player.global_position.z), Vector3.UP)
		d.rotate_y(PI)
		melee.add_foe(d)
		return d
	var dest := StoryDuel._free_spot(player, sp["pos"])
	var from = w.get("from", null)
	var src := Vector3.INF
	if from is Vector3:
		src = from
	elif from is Array and not (from as Array).is_empty():
		src = (from as Array)[i % (from as Array).size()]
	if src == Vector3.INF:
		src = melee.auto_entry(dest)
	if src == Vector3.INF:
		# Giriş yolu bulunamadı (dar yer): dövüş yerinde doğar
		d.position = dest
		scene.add_child(d)
		d.global_position = dest
		d.look_at(Vector3(player.global_position.x, d.global_position.y, player.global_position.z), Vector3.UP)
		d.rotate_y(PI)
		melee.add_foe(d)
		return d
	melee.arrive(d, src, dest, w.get("via", []), float(i % 4) * 0.35)
	melee.add_foe(d)
	return d


## Taze dostların geleceği yer: oyuncunun arkasında (rakiplerin öbür yanında), 5-9 m, yürünür ve arada duvar yok.
static func _behind(player: Player, melee: Melee, foes: Array[Duelist]) -> Vector3:
	var c := Vector3.ZERO
	for d in foes:
		c += d.global_position
	var to := (c / maxf(1.0, foes.size())) - player.global_position
	to.y = 0.0
	var dir := -to.normalized() if to.length() > 0.1 else player.global_transform.basis.z
	var space := player.get_world_3d().direct_space_state
	for dist: float in [9.0, 7.0, 5.0]:
		for a: float in [0.0, 0.4, -0.4, 0.8, -0.8]:
			var p := player.global_position + dir.rotated(Vector3.UP, a) * dist
			var fy := Unclip.floor_y(player, p, 2.0, 2.5)
			if is_nan(fy) or absf(fy - player.global_position.y) > 2.0:
				continue
			p.y = fy
			var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 1.1, 0), player.global_position + Vector3(0, 1.1, 0), 1, [player.get_rid()])
			var h := space.intersect_ray(q)
			if not h.is_empty() and Unclip.visible_body(h["collider"]):
				continue
			if Unclip.in_solid(player, p, 0.25):
				continue
			return melee.free_near(p)
	return Vector3.INF


## Dönüşler bitince yönetici sahneden çıkar (dönemeyen kalmışsa beklemeden yerine konur).
static func _cleanup(melee: Melee) -> void:
	if not is_instance_valid(melee):
		return
	var tw := melee.create_tween()
	tw.tween_interval(6.5)
	tw.tween_callback(func():
		melee.restore_now()
		melee.queue_free())
