class_name StoryDuel
extends RefCounted
## Hikâyede düello: hazır Duel/Duelist sistemi, hikâyeye göre ayarlı.
##   Oyuncunun canı gerçek (Player.hp): darbeler can götürür, can biterse oyuncu yere düşer ve düello kaybedilir.
##   Ölüm yok, ama yenilgi bölüm sonucunu kötüleştirir (bölüm `won`a bakar). Rakipler ölmez: canı bitince kılıcını
##   bırakıp geri çekilir. Süre dolarsa (rakipler hâlâ ayaktaysa) düello kaybedilmiş sayılır.
## specs: [{"pos": Vector3, "look": Dictionary, "blade": "kilij"|"spathion", "shield": bool, "name": "SPK_…"}]

## Döner: {"won", "hits_taken", "parries", "kills", "time"}.
static func fight(scene: Node3D, hud: Hud, player: Player, specs: Array, p_blade := "spathion", skill := 0.35, limit := 75.0) -> Dictionary:
	var duel := Duel.new()
	duel.link_player = true
	# Test: yenilgi denenmiyorsa bot şansa kalmasın (yenilgi yolu =lose varyantlarıyla denenir)
	duel.god = GameState.autotest and not GameState.autotest_variant.ends_with("lose")
	hud.add_child(duel)
	var list: Array[Duelist] = []
	for sp in specs:
		list.append(make(scene, player, sp, skill))
	player.face(list[0].global_position + Vector3(0, 1.5, 0))
	hud.set_objective(TranslationServer.translate("UI_OBJ_DUEL") % list.size())
	duel.start(player, list, p_blade)
	# Müzik göğüs göğüse çarpışma yoğunluğuna çıkar, sonra önceki seviyeye döner
	var prev_level := Audio.intensity_level()
	Audio.intensity(3)
	var side_fights := _skirmish(scene, player, list, specs, p_blade)
	# Lambda yerel değişkeni kopyalar: sonucu paylaşılan sözlükte tut
	var st := {"won": false, "lost": false}
	duel.finished.connect(func(w: bool):
		st["won"] = w
		st["lost"] = not w)
	var t := 0.0
	while duel.active and t < limit:
		await scene.get_tree().process_frame
		t += scene.get_process_delta_time()
	var won: bool = st["won"]
	if st["lost"]:
		# Yenildi: oyuncu yere düşer; rakipler zafer narasıyla geri çekilir (hikâye durmaz)
		player.down()
		for d in duel.alive_enemies():
			d.hp = 0.0
			d._die()
	if duel.active:
		# Süre doldu: kalanlar geri çekilir (hikâye durmaz)
		for d in duel.alive_enemies():
			d.hp = 0.0
			d._die()
		duel.stop()
	hud.set_objective("")
	Audio.intensity(maxi(prev_level, 1))
	# Yan çarpışmalar: düşmanlar geri çekilir, bizimkiler nefeslenip durur
	for pair in side_fights:
		var foe: Duelist = pair[1]
		if is_instance_valid(foe):
			foe.hp = 0.0
			foe._die()
		var ally: Duelist = pair[0]
		if is_instance_valid(ally):
			ally.target = null
	if GameState.autotest:
		print("STORYDUEL won=%s kills=%d parries=%d hits_taken=%d t=%.1f" % [won, duel.kills, duel.parries, duel.hits_taken, t])
	var res := {"won": won, "hits_taken": duel.hits_taken, "parries": duel.parries, "kills": duel.kills, "time": t}
	await scene.get_tree().create_timer(1.2).timeout
	while player.is_down:
		await scene.get_tree().process_frame
	duel.queue_free()
	return res


## Hikâye rakibi: ölmez (teslim olur), 80 can, 18 hasar; boş bir yerde, oyuncuya dönük doğar.
static func make(scene: Node3D, player: Player, sp: Dictionary, skill: float) -> Duelist:
	var sk: float = clampf(float(sp.get("skill", skill)) + GameState.diff("foe_skill"), 0.1, 0.95)
	var d := Duelist.new(sp["look"], sp.get("blade", "kilij"), sk, sp.get("shield", false))
	d.name_key = sp.get("name", "SPK_SOLDIER")
	d.set_meta("yield", true)
	d.damage = float(sp.get("damage", 18.0)) * GameState.diff("foe_dmg")
	d.max_hp = float(sp.get("hp", 80.0)) * GameState.diff("foe_hp")
	d.hp = d.max_hp
	var at := _free_spot(player, sp["pos"])      # sahneye girmeden: kendi gövdesi (henüz kökte) yeri dolu göstermesin
	d.position = at          # _ready'deki son yükseklik doğduğu yer olsun (zemin bulunamazsa y 0'a düşmesin)
	scene.add_child(d)
	d.global_position = at
	d.look_at(Vector3(player.global_position.x, d.global_position.y, player.global_position.z), Vector3.UP)
	d.rotate_y(PI)
	return d


## Rakip duvarın, çitin, sandığın içinde ya da bir başkasının (önceki rakip, dost asker, figüran) üstünde doğmasın:
## istenen noktada gövde boyu bir kapsül boş değilse ya da 0,8 m içinde ayakta biri varsa oyuncunun çevresinde (aynı
## uzaklıkta) açıyı kaydırarak ilk boş yeri bul.
static func _free_spot(player: Player, want: Vector3, strict := false) -> Vector3:
	var space := player.get_world_3d().direct_space_state
	var cap := CapsuleShape3D.new()
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.collision_mask = 1
	q.exclude = [player.get_rid()]
	var c := player.global_position
	var off := want - c
	off.y = 0.0
	var r := maxf(off.length(), 2.5)
	var a0 := atan2(off.x, off.z)
	# Önce geniş kapsül (kılıç sallayacak yer); dar yerde (sur yolu, güverte) gövde kalınlığı yeter. Altında istenen
	# yükseklikte görünen zemin olmalı: sur yolunun, rıhtımın kenarından dışarı (havaya) konmaz.
	for rad: float in [0.4, 0.22]:
		cap.radius = rad
		cap.height = maxf(1.7, rad * 2.0)
		for k in 19:          # bütün çember (dar sur yolunda boş yer oyuncunun arkasında olabilir)
			var a := a0 + (k + 1) / 2 * 0.35 * (1.0 if k % 2 == 0 else -1.0)
			for rr: float in [r, r - 0.8, r + 0.8, r + 1.6]:
				var p := c + Vector3(sin(a), 0, cos(a)) * rr
				p.y = want.y
				# Önce görünen zemin (gedikte moloz basamakları, dil: istenen yükseklikten 1,5 m'ye kadar), kapsül onun üstünde
				var fy := Unclip.floor_y(player, p, 1.6, 1.6)
				if is_nan(fy) or absf(fy - want.y) > 1.5:
					continue
				p.y = fy
				q.transform = Transform3D(Basis(), p + Vector3(0, 1.0, 0))
				if not space.intersect_shape(q, 1).is_empty() or Unclip.crowded(player, p, 0.8):
					continue
				return p
	# Boş yer yok: istenen yerin görünen üst yüzeyi (moloz katmanının altında, içinde kalmasın)
	var top := Unclip.floor_y(player, want, 3.0, 3.0)
	if not is_nan(top) and not Unclip.in_solid(player, Vector3(want.x, top, want.z), 0.2):
		return Vector3(want.x, top, want.z)
	# Kalabalık dar yer (29'da altı kişinin çıktığı güverte): istenen yerin çevresinde, kalabalığa bakmadan ama bir
	# katının içine değil (eskiden istenen nokta olduğu gibi dönüyordu: düellocu kasara perdesinin içinde doğuyordu)
	cap.radius = 0.22
	cap.height = 1.7
	for rr: float in [0.6, 1.2, 1.8, 2.4, 3.2, 4.0]:
		for k in 12:
			var p := want + Vector3(sin(k * TAU / 12.0), 0, cos(k * TAU / 12.0)) * rr
			var fy := Unclip.floor_y(player, p, 1.6, 1.6)
			if is_nan(fy) or absf(fy - want.y) > 1.5:
				continue
			p.y = fy
			q.transform = Transform3D(Basis(), p + Vector3(0, 1.0, 0))
			if space.intersect_shape(q, 1).is_empty() and not Unclip.crowded(player, p, 0.45):
				return p
	return Vector3.INF if strict else want


## Oyuncunun düellosu sürerken iki yanda da çarpışma olsun (bizim askerler seyirci gibi dikilmesin): birer dost ve
## birer düşman düellocu birbirini hedef alır; Duel denetleyicisine bağlı değiller, yani kimse ölmez, yalnız
## hamle, siper ve yan adım görünür. Düellonun sonunda düşmanlar geri çekilir.
static func _skirmish(scene: Node3D, player: Player, foes: Array[Duelist], specs: Array, p_blade: String) -> Array:
	var out: Array = []
	if foes.is_empty():
		return out
	var c := player.global_position
	var to := foes[0].global_position - c
	to.y = 0.0
	to = to.normalized() if to.length() > 0.1 else Vector3(0, 0, 1)
	var side := to.cross(Vector3.UP).normalized()
	var ottoman := p_blade == "kilij"
	var ally_look := {"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true} if ottoman \
		else {"coat": Color("8a8e96"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true, "beard": true}
	var foe_look: Dictionary = specs[0].get("look", {})
	for k in 2:
		var s := -1.0 if k == 0 else 1.0
		var base := c + side * s * 4.5 + to * 2.5
		var ally := Duelist.new(ally_look, p_blade, 0.5, k == 1)
		var foe := Duelist.new(foe_look, specs[0].get("blade", "kilij"), 0.5, k == 0)
		for d: Duelist in [ally, foe]:
			d.set_meta("skirmish", true)
			d.hp = 999.0
			d.max_hp = 999.0
		# Yer sahneye girmeden seçilir (yeni gövde henüz kökte durup yeri dolu göstermesin); düşman dostun yanını boş bulur
		var aat := _free_spot(player, base - to * 1.0, true)
		var fat := _free_spot(player, base + to * 1.2, true)
		if aat == Vector3.INF or fat == Vector3.INF:
			ally.free()
			foe.free()
			continue      # dar yerde yan çarpışmaya yer yok: bir duvarın içinde dövüşmesinler
		ally.position = aat
		scene.add_child(ally)
		ally.global_position = aat
		fat = _free_spot(player, base + to * 1.2, true)      # dost yerleşti: düşman onun yanını boş bulsun
		if fat == Vector3.INF:
			ally.queue_free()
			foe.free()
			continue
		foe.position = fat
		scene.add_child(foe)
		foe.global_position = fat
		ally.target = foe
		foe.target = ally
		out.append([ally, foe])
	return out
