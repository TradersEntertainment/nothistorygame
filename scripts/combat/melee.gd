class_name Melee
extends Node
## Savaş katmanı ("ultra savaş"): oyuncunun düellosunun çevresinde iki tarafın gerçek çarpışması.
##   · Rakipler giriş noktasından (gedik ağzı, sur yolunun ucu, merdiven başı) bölük hâlinde koşarak gelir: yoktan
##     belirmez (spawn_group). Ardından gelen takviye de aynı yoldan koşar.
##   · Alarm (rally): çevredeki boşta duran, oturan, iş başındaki askerler kalkıp kılıç çeker; kendi tarafımızdakiler
##     dost olur, karşı taraftakiler (sur yolundaki nöbetçiler) üstümüze gelir. Dövüş bitince dostlar yerlerine döner.
##   · Dostlar ve düşmanlar birbirini hedef alır: gerçek vuruş, savuşturma, itme, ölüm (Duelist.npc_hit). Oyuncu
##     hepsine saldırabilir; başkasıyla çarpışan rakibe yandan/arkadan vuruş muhafızı deler (Duel).
##   · Aynı anda oyuncuya en çok max_on_player rakip saldırır; ötekiler dostlarla çarpışır ya da halkada sırasını bekler.
## WaveRunner ve StoryDuel kurar; bölüm doğrudan da kullanabilir (giriş yolları, merdivenler).

var scene: Node3D
var duel: Duel
var player: Player
var side := "byz"                 # oyuncunun tarafı: "byz" (spathion) | "osm" (kilij)
var foes: Array[Duelist] = []
var allies: Array[Duelist] = []
var max_on_player := 2
var water_y := -INF               # güverte savaşında deniz: düşen suya gömülür
var _t := 0.0
## Ayaklanan askerler: {"d": Duelist, "src": kaynak asker (gizlendi), "home": Vector3, "act": String, "back": bool}
var _risen: Array = []
var _cheer_t := 0.0
var rallied_allies := 0
var rallied_foes := 0
var fresh_allies := 0
var hud: Hud
## Kuşatma merdivenleri: {"node": Ladder, "base", "top", "land", "out", "down" (devrik kalan sn), "hold"}
var ladders: Array = []
var pushed_ladders := 0
var _ladder_prompt := false
var _dbg := OS.get_environment("MELEE_DEBUG") != ""
var _dbg_t := 0.0
var pending_foes := 0             # alarmla kalkacak (henüz kalkmamış) düşmanlar: dalga onları da bekler (Duel.reserve)


func _init(p_scene: Node3D, p_duel: Duel, p_player: Player, blade := "spathion") -> void:
	scene = p_scene
	duel = p_duel
	player = p_player
	side = "osm" if blade == "kilij" else "byz"
	name = "Melee"


static func of(p_scene: Node3D, p_duel: Duel, p_player: Player, blade: String) -> Melee:
	var m := Melee.new(p_scene, p_duel, p_player, blade)
	p_scene.add_child(m)
	return m


func add_foe(d: Duelist) -> void:
	d.team = 1
	d.water_y = water_y
	if not d in foes:
		foes.append(d)


func add_ally(d: Duelist) -> void:
	d.team = 0
	d.water_y = water_y
	d.duel = null
	if not d in allies:
		allies.append(d)
	d.died.connect(func(_x): _assign_soon(), CONNECT_ONE_SHOT)


func _assign_soon() -> void:
	_t = minf(_t, 0.05)


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	foes = _prune(foes)
	allies = _prune(allies)
	_t -= delta
	if _t <= 0.0:
		_t = 0.3
		_assign()
	_cheer_t = maxf(0.0, _cheer_t - delta)
	_tick_return(delta)
	if not ladders.is_empty():
		_tick_ladders(delta)
	if _dbg:
		_dbg_t -= delta
		if _dbg_t <= 0.0:
			_dbg_t = 2.0
			var pp := player.global_position
			var parts: Array[String] = []
			for d in foes + allies:
				if not is_instance_valid(d):
					continue
				var tg := "P" if d.target == player else ("D" if d.target != null and is_instance_valid(d.target) and d.target is Duelist else "-")
				var td := -1.0
				if d.target != null and is_instance_valid(d.target):
					td = d.global_position.distance_to(d.target.global_position)
				parts.append("%s%s:%s:%s:%.1f/%.1f:y%.1f:%s%s" % ["F" if d.team == 1 else "A", d.get_instance_id() % 1000, Duelist.St.keys()[d.state],
					tg, d.global_position.distance_to(pp), td, d.global_position.y, "path" if not d.path.is_empty() else "", "H" if d.hold_back else ""])
			print("MELEE p=%s %s" % [pp.snapped(Vector3.ONE * 0.1), " ".join(parts)])


# ---------------------------------------------------------------- hedef dağıtımı

## Silinmiş düellocuları (görüş dışında batıp giden ceset, yerine dönen asker) listeden atar. Dizinle okunur:
## silinmiş bir nesneyi türlü değişkene atamak hata verir.
static func _prune(list: Array[Duelist]) -> Array[Duelist]:
	var out: Array[Duelist] = []
	for i in list.size():
		var o = list[i]
		if is_instance_valid(o):
			out.append(o)
	return out


func _live(list: Array[Duelist]) -> Array[Duelist]:
	var out: Array[Duelist] = []
	for d in list:
		if is_instance_valid(d) and d.alive() and not d._falling:
			out.append(d)
	return out


func _ready_to_fight(d: Duelist) -> bool:
	return d.path.is_empty() and d._climb.is_empty() and d._rise_t <= 0.0


func _assign() -> void:
	foes = _live(foes)
	allies = _live(allies)
	var p := player.global_position
	var fighting := duel != null and duel.active
	for d in foes + allies:
		if d.target != null and not is_instance_valid(d.target):
			d.target = null
	if not fighting:
		for d in foes + allies:
			if _ready_to_fight(d):
				_clear_target(d)
		return
	# Düşmanlar: oyuncuya en çok max_on_player saldırır (yakından uzağa); bir dostla göğüs göğüse olan (3,5 m)
	# onu bırakmaz. Kalanlar en az rakibi olan yakın dosta; dost yoksa oyuncunun çevresinde sırasını bekler.
	var ready_f: Array[Duelist] = []
	for d in foes:
		if _ready_to_fight(d):
			ready_f.append(d)
	ready_f.sort_custom(func(a: Duelist, b: Duelist): return a.global_position.distance_squared_to(p) < b.global_position.distance_squared_to(p))
	var on_ally := {}
	for a in allies:
		on_ally[a] = 0
	var on_player := 0
	var rest: Array[Duelist] = []
	for d in ready_f:
		if _engaged(d) and int(on_ally.get(d.target, 0)) < 2:
			on_ally[d.target] = int(on_ally[d.target]) + 1
			continue
		if on_player < max_on_player:
			_set_target(d, player)
			d.hold_back = false
			on_player += 1
			continue
		rest.append(d)
	for d in rest:
		var best: Duelist = null
		var bs := INF
		for a in allies:
			if int(on_ally[a]) >= 2 or not _ready_to_fight(a):
				continue
			var s := a.global_position.distance_to(d.global_position) + int(on_ally[a]) * 3.0
			if s < bs:
				bs = s
				best = a
		if best:
			_set_target(d, best)
			d.hold_back = false
			on_ally[best] = int(on_ally[best]) + 1
		else:
			_set_target(d, player)
			d.hold_back = true
	# Yoldaki (koşarak gelen) rakipler: varınca kime gideceklerini bilsinler (bakış), dağıtım varınca yapılır
	for d in foes:
		if not _ready_to_fight(d) and d.target == null:
			d.target = player
	# Dostlar: kendisine saldıranı, yoksa oyuncuya saldıranlardan dostsuz olanı, yoksa en yakını
	var foe_allies := {}
	for a in allies:
		if not _ready_to_fight(a):
			continue
		var cur: Duelist = a.target as Duelist if (a.target != null and is_instance_valid(a.target) and a.target is Duelist) else null
		if cur and cur.alive() and a.swap_t > 0.0:
			foe_allies[cur] = int(foe_allies.get(cur, 0)) + 1
			continue
		var pick: Duelist = null
		var ps := INF
		for d in foes:
			if not _ready_to_fight(d):
				continue
			var s := a.global_position.distance_to(d.global_position)
			if d.target == a:
				s -= 6.0
			elif d.target == player:
				s -= 2.0
			s += int(foe_allies.get(d, 0)) * 4.0
			if s < ps:
				ps = s
				pick = d
		if pick:
			_set_target(a, pick)
			foe_allies[pick] = int(foe_allies.get(pick, 0)) + 1
		elif a.target != null:
			_clear_target(a)
			_cheer(a)


## Bir dostla göğüs göğüse mi (hedefi canlı bir dost ve 3,5 m içinde)
func _engaged(d: Duelist) -> bool:
	if d.target == null or not is_instance_valid(d.target) or not (d.target is Duelist):
		return false
	var a := d.target as Duelist
	return a.alive() and a.team == 0 and a.global_position.distance_to(d.global_position) < 3.5


func _clear_target(d: Duelist) -> void:
	d.target = null
	d.hold_back = false
	if d.state in [Duelist.St.WINDUP, Duelist.St.STRIKE, Duelist.St.RECOVER, Duelist.St.FLINCH]:
		d.state = Duelist.St.IDLE
		d._t = 0.0


func _set_target(d: Duelist, t: Node3D) -> void:
	if d.target == t:
		return
	d.target = t
	d.swap_t = randf_range(2.0, 3.5)
	if d.state in [Duelist.St.WINDUP, Duelist.St.STRIKE]:
		d.state = Duelist.St.IDLE
		d._t = 0.0
	d._think = maxf(d._think, randf_range(0.3, 0.8))


## Rakibi düşen dost bir an kılıcını kaldırır (zafer narası; sık değil).
func _cheer(a: Duelist) -> void:
	if _cheer_t > 0.0 or not is_instance_valid(a):
		return
	_cheer_t = 2.5
	Audio.sfx_at("war_cry", a, -10.0)


# ---------------------------------------------------------------- giriş: bölük hâlinde koşarak gelme

## Rakibi (StoryDuel.make'in kurduğu, henüz sahnede olmayan) giriş noktasından getirir: from'da (boş bir yerde) doğar,
## via noktalarından geçip dest'e koşar. Görüş dışında başlaması yeğlenir; değilse yine koşarak gelir.
func arrive(d: Duelist, from: Vector3, dest: Vector3, via: Array = [], delay := 0.0) -> void:
	var at := free_near(from)
	d.position = at
	if not d.is_inside_tree():
		scene.add_child(d)
	d.global_position = at
	var to := dest - at
	if Vector2(to.x, to.z).length() > 0.1:
		d.rotation.y = atan2(to.x, to.z)
	var pts: Array[Vector3] = []
	for v: Vector3 in via:
		pts.append(v)
	pts.append(dest)
	d.path = pts
	d.run_speed = randf_range(3.9, 4.6)
	if delay > 0.0:
		d.visible = false
		d.set_process(false)
		var tw := d.create_tween()
		tw.tween_interval(delay)
		tw.tween_callback(func():
			d.visible = true
			d.set_process(true))


## from çevresinde gövde sığan, altında görünen zemin olan boş bir yer (oyuncunun çevresinde değil: giriş noktasının).
func free_near(want: Vector3) -> Vector3:
	var space := scene.get_world_3d().direct_space_state
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.7
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.collision_mask = 1
	q.exclude = [player.get_rid()]
	for rr: float in [0.0, 0.7, 1.4, 2.1, 2.8]:
		for k in (1 if rr == 0.0 else 10):
			var p := want + Vector3(sin(k * TAU / 10.0), 0, cos(k * TAU / 10.0)) * rr
			var fy := Unclip.floor_y(player, p, 2.0, 3.0)
			if is_nan(fy) or absf(fy - want.y) > 2.0:
				continue
			p.y = fy
			q.transform = Transform3D(Basis(), p + Vector3(0, 1.0, 0))
			if space.intersect_shape(q, 1).is_empty() and not Unclip.crowded(player, p, 0.6):
				return p
	return want


## Giriş noktası verilmemişse: dövüş yerinin oyuncudan öte yanında, 7-11 m geride görünen zemin (gedik ağzı, sur yolu).
## Bulunamazsa INF (rakip eskisi gibi dövüş yerinde doğar).
func auto_entry(dest: Vector3) -> Vector3:
	var away := dest - player.global_position
	away.y = 0.0
	away = away.normalized() if away.length() > 0.1 else -player.global_transform.basis.z
	var space := scene.get_world_3d().direct_space_state
	for dist: float in [10.0, 8.0, 6.0]:
		for a: float in [0.0, 0.35, -0.35, 0.7, -0.7]:
			var p := dest + away.rotated(Vector3.UP, a) * dist
			var fy := Unclip.floor_y(player, p, 2.5, 3.0)
			if is_nan(fy) or absf(fy - dest.y) > 2.5:
				continue
			p.y = fy
			# Arada duvar yok (gövde hizasında): koşarak gelebilsin
			var q := PhysicsRayQueryParameters3D.create(p + Vector3(0, 1.1, 0), dest + Vector3(0, 1.1, 0), 1, [player.get_rid()])
			var h := space.intersect_ray(q)
			if not h.is_empty() and Unclip.visible_body(h["collider"]):
				continue
			if Unclip.in_solid(player, p, 0.25) or not walkable(p, dest):
				continue
			return p
	return Vector3.INF


## a'dan b'ye gövde boyu (dizden başa) bir kapsül engelsiz geçer mi (barikat kütüğü, sandık, siper yolu kesmesin).
## Yükseklik farkı (moloz yamacı) adım adım izlenir: yol üç parçada, her parça zemine oturtulup denenir.
func walkable(a: Vector3, b: Vector3) -> bool:
	var space := scene.get_world_3d().direct_space_state
	var cap := CapsuleShape3D.new()
	cap.radius = 0.24
	cap.height = 1.0
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.collision_mask = 1
	q.exclude = [player.get_rid()]
	var prev := a
	for k in range(1, 4):
		var p := a.lerp(b, k / 3.0)
		var fy := Unclip.floor_y(player, p, 1.5, 2.0)
		if is_nan(fy):
			return false
		p.y = fy
		q.transform = Transform3D(Basis(), prev + Vector3(0, 1.0, 0))
		q.motion = p - prev
		var r := space.cast_motion(q)
		if r.size() > 0 and r[0] < 0.98:
			# Görünmez sınırlar (yalnız oyuncuyu tutan korkuluk) yürüyeni durdurmaz; görünen bir katı durdurur
			var mid := prev.lerp(p, r[0]) + Vector3(0, 1.0, 0)
			var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(mid - (p - prev).normalized() * 0.3, mid + (p - prev).normalized() * 0.5, 1, [player.get_rid()]))
			if hit.is_empty() or Unclip.visible_body(hit["collider"]):
				return false
		prev = p
	return true


# ---------------------------------------------------------------- alarm: çevredeki askerler ayaklanır

## center çevresindeki (radius, aynı katta, arada duvar yok) adsız askerler ayaklanır. Kendi tarafımızdan en çok
## max_allies dost, karşı taraftan en çok max_foes düşman (dalgaya eklenir). Önce irkilip döner (yakından uzağa
## yayılan alarm), sonra kılıç çekip kalkar. Döner: ayaklanan düşmanlar (dalga onları da bekler).
func rally(center: Vector3, radius := 16.0, max_allies := 4, max_foes := 0, foe_skill := 0.35) -> Array[Duelist]:
	var out: Array[Duelist] = []
	var cands: Array = []
	var seen := {}
	for n in get_tree().get_nodes_in_group("soldiers") + get_tree().get_nodes_in_group("persons"):
		if seen.has(n) or not _eligible(n, center, radius):
			continue
		seen[n] = true
		cands.append(n)
	cands.sort_custom(func(a: Node3D, b: Node3D): return a.global_position.distance_squared_to(center) < b.global_position.distance_squared_to(center))
	for n: Node3D in cands:
		var s := side_of(n)
		var team := -1
		if s == side and rallied_allies < max_allies:
			team = 0
			rallied_allies += 1
		elif s != "" and s != side and rallied_foes < max_foes:
			team = 1
			rallied_foes += 1
		if team < 0:
			continue
		var delay := 0.15 + n.global_position.distance_to(center) * 0.06 + randf_range(0.0, 0.25)
		# İrkilme: başını çevirir, şaşırır (alarm yakından uzağa yayılır)
		if n.get("look_target") != null or n is Soldier or n is Person:
			n.set("look_target", player)
		if n.has_method("emote") and (not (n is Soldier) or (n as Soldier).pose == "stand"):
			n.call("emote", "surprise")
		var d := _make_risen(n, team, foe_skill)
		if team == 1:
			out.append(d)
			pending_foes += 1
		var tw := create_tween()
		tw.tween_interval(delay)
		tw.tween_callback(_raise.bind(n, d))
	if GameState.autotest:
		print("RALLY scene=%s allies=%d foes=%d cands=%d" % [scene.scene_file_path.get_file(), rallied_allies, rallied_foes, cands.size()])
	return out


## Ayaklanabilir mi: adsız (konuşmacı, tasarlanmış yüz değil), asker kılıklı, görünür, ayakta ya da oturur (yaralı,
## ölü, merdivendeki, havadaki değil), dövüş yerine yakın ve aynı katta, arada duvar yok.
func _eligible(n: Node, center: Vector3, radius: float) -> bool:
	var p := n as Node3D
	if p == null or not p.is_inside_tree() or not p.is_visible_in_tree() or p.get_parent() is Duelist:
		return false
	# Uzak kalabalığın, merdiven bölüklerinin, top ekibinin parçası değil (onları kendi düzenekleri yürütür)
	var anc := p.get_parent()
	while anc != null and anc != scene:
		if anc is Assault or anc is CannonCrew or anc.has_meta("no_rally"):
			return false
		anc = anc.get_parent()
	for m in ["spk", "speaker", "no_rally", "climber", "corpse", "airborne", "no_ground", "carried", "named"]:
		if p.has_meta(m):
			return false
	if p is Person:
		var pp := p as Person
		if pp.face_id != "" or pp.child or pp.activity in ["lie", "dead", "sleep", "row", "ride", "swim"] \
				or (pp.rig and pp.rig.lock > 0):
			return false
	elif p is Soldier:
		if (p as Soldier).pose == "aim":
			return false            # tüfekçi kendi işinde (Gunner)
	else:
		return false
	if side_of(p) == "":
		return false
	var gp := p.global_position
	if Vector2(gp.x - center.x, gp.z - center.z).length() > radius or absf(gp.y - center.y) > 2.5:
		return false
	var q := PhysicsRayQueryParameters3D.create(gp + Vector3(0, 1.4, 0), center + Vector3(0, 1.4, 0), 1, [player.get_rid()])
	var h := scene.get_world_3d().direct_space_state.intersect_ray(q)
	if not h.is_empty() and Unclip.visible_body(h["collider"]) and not Duelist._is_person_part(h["collider"]):
		return false
	return true


## Tarafı: "side" işareti, yoksa başlığından (Bizans miğferi / Osmanlı börkü, sarığı, çiçağı). Sivil: "".
static func side_of(n: Node) -> String:
	if n.has_meta("side"):
		return str(n.get_meta("side"))
	var hat := str(n.get("hat"))
	if hat in ["helm", "plume", "condottiero"]:
		return "byz"
	if hat in ["bork", "turban", "azap", "helmet", "cicak"]:
		return "osm"
	return ""


static func look_of(n: Node) -> Dictionary:
	if n is Person:
		var p := n as Person
		return {"coat": p.coat, "pants": p.pants, "hat": p.hat, "mustache": p.mustache, "beard": p.beard, "skin": p.skin, "armor": p.armor}
	var hat := str(n.get("hat"))
	if hat == "helmet":
		hat = "cicak"
	var coat: Color = n.get("coat") if n.get("coat") is Color else Color("7a2a24")
	return {"coat": coat, "pants": Color("3a2a22") if hat == "helm" else Color("e8e0d0"), "hat": hat, "mustache": true,
		"beard": hash(n.name) % 3 == 0}


func _make_risen(n: Node3D, team: int, foe_skill: float) -> Duelist:
	var s := side_of(n)
	var byz := s == "byz"
	var shield := byz or hash(n.name) % 2 == 0
	var sk := clampf((0.42 if team == 0 else foe_skill) + GameState.diff("foe_skill") * (0.0 if team == 0 else 1.0), 0.1, 0.9)
	var d := Duelist.new(look_of(n), "spathion" if byz else "kilij", sk, shield)
	d.team = team
	d.name_key = "SPK_DEFENDER" if byz else ("SPK_AZAP" if str(n.get("hat")) in ["azap", "turban"] else "SPK_JANISSARY")
	if team == 0:
		d.max_hp = 110.0
		d.damage = 16.0
	else:
		d.max_hp = 70.0 * GameState.diff("foe_hp")
		d.damage = 15.0 * GameState.diff("foe_dmg")
		d.set_meta("yield", true)
	d.hp = d.max_hp
	return d


func _raise(n: Node3D, d: Duelist) -> void:
	if is_instance_valid(d) and d.team == 1:
		pending_foes = maxi(0, pending_foes - 1)
		if duel:
			duel.reserve = maxi(0, duel.reserve - 1)      # bekleyen kalktı: artık dalganın canlı rakibi
	if not is_instance_valid(n) or not is_instance_valid(d) or not n.is_inside_tree():
		if is_instance_valid(d) and not d.is_inside_tree():
			d.free()
		return
	var act := ""
	if n is Person:
		act = (n as Person).activity
	elif n is Soldier:
		act = (n as Soldier).pose
	var xf := n.global_transform
	n.visible = false
	n.process_mode = Node.PROCESS_MODE_DISABLED
	d.position = xf.origin
	scene.add_child(d)
	d.global_position = xf.origin
	d.rotation.y = xf.basis.get_euler().y
	d.rise_from(act)
	Audio.sfx_at("cloth", d, -10.0)
	_risen.append({"d": d, "src": n, "home": xf.origin, "yaw": xf.basis.get_euler().y, "back": false, "t": 0.0})
	if d.team == 0:
		add_ally(d)
	else:
		add_foe(d)
		if duel and duel.active:
			duel.add_enemy(d)


## Dövüş bitti: ayaklananlardan sağ kalanlar yerlerine döner (koşarak), varınca eski hâllerine (oturan oturur, iş başındaki
## işine). Ölen dostun kaynağı gizli kalır (o asker artık yok).
func stand_down() -> void:
	for r: Dictionary in _risen:
		var d = r["d"]
		if not is_instance_valid(d) or not d.alive() or r["src"] == null:
			continue
		d.target = null
		d.hold_back = false
		var home: Vector3 = r["home"]
		var pts: Array[Vector3] = [home]
		d.path = pts
		d.run_speed = 2.6
		r["back"] = true
		r["t"] = 0.0


func _tick_return(delta: float) -> void:
	for r: Dictionary in _risen:
		if not r["back"]:
			continue
		var d = r["d"]
		r["t"] = float(r["t"]) + delta
		if not is_instance_valid(d) or not d.alive():
			r["back"] = false
			continue
		if d.path.is_empty() or float(r["t"]) > 6.0:
			var n = r["src"]
			r["back"] = false
			if n != null and is_instance_valid(n):
				n.visible = true
				n.process_mode = Node.PROCESS_MODE_INHERIT
				if n.get("look_target") != null:
					n.set("look_target", null)
			d.queue_free()


## Bölüm sahneyi değiştirirken (ışınlama, kararma): dönüşü beklemeden herkes yerine.
func restore_now() -> void:
	for r: Dictionary in _risen:
		var d = r["d"]
		var n = r["src"]
		if n == null:
			continue                  # yardıma gelen taze dost: dövüşten sonra nefeslenip kalır (konuşanın önünden çekilir)
		if is_instance_valid(d) and d.alive():
			if n != null and is_instance_valid(n):
				n.visible = true
				n.process_mode = Node.PROCESS_MODE_INHERIT
			d.queue_free()
	_risen.clear()


# ---------------------------------------------------------------- kuşatma merdivenleri

## Sura dayalı bir merdiven (sahnede, sura yaslı Ladder): rakipler bundan tırmanıp mazgaldan land'e atlar. Oyuncu
## tırmanamaz (yalnız düşmanın yolu). Döner: merdiven kaydı (WaveRunner "ladders" ile kullanılır).
func add_ladder(node: Ladder, land: Vector3) -> Dictionary:
	if node.is_in_group("ladder"):
		node.remove_from_group("ladder")
	var h := node.height
	var out := node.front_dir()
	out.y = 0.0
	var l := {"node": node, "base": node.point_at(0.0) + node.front_dir() * 0.35, "top": node.point_at(h - 0.3) + node.front_dir() * 0.3,
		"land": land, "out": out.normalized(), "down": 0.0, "hold": 0.0}
	ladders.append(l)
	return l


## Merdiven devrik mi (itildi, aşağıdakiler henüz yeniden dayamadı)
func ladder_down(l: Dictionary) -> bool:
	return float(l["down"]) > 0.0


func _climbers_on(l: Dictionary) -> Array[Duelist]:
	var out: Array[Duelist] = []
	foes = _prune(foes)
	for d in foes:
		if is_instance_valid(d) and d.climbing() and (d._climb["base"] as Vector3).is_equal_approx(l["base"]):
			out.append(d)
	return out


## Oyuncu bir merdivenin tepesindeyken (sur yolunda, 2 m içinde) E basılı: merdiven itilir. Testte bot, tırmanan
## yarıyı geçince iter (yürüyüş yolunda merdivenin başında duruyorsa).
func _tick_ladders(delta: float) -> void:
	var near: Dictionary = {}
	var pp := player.global_position
	for l: Dictionary in ladders:
		if float(l["down"]) > 0.0:
			l["down"] = float(l["down"]) - delta
			if float(l["down"]) <= 0.0:
				_raise_ladder(l)
			continue
		var land: Vector3 = l["land"]
		if Vector2(pp.x - land.x, pp.z - land.z).length() < 2.2 and absf(pp.y - land.y) < 1.5 and not _climbers_on(l).is_empty():
			near = l
	var active := duel != null and duel.active and not near.is_empty()
	if not active:
		if _ladder_prompt and hud:
			hud.set_prompt("")
			hud.set_chase("", 0.0)
			_ladder_prompt = false
		for l: Dictionary in ladders:
			l["hold"] = 0.0
		return
	_ladder_prompt = true
	if hud:
		hud.set_prompt(tr("UI_PROMPT30_PUSH"))
	var press := Input.is_action_pressed("interact")
	if GameState.autotest and pushed_ladders == 0:
		for d in _climbers_on(near):
			if float(d._climb["t"]) * 3.0 * 0.45 > float(d._climb["len"]) * 0.5:
				press = true
	if press:
		near["hold"] = float(near["hold"]) + delta
		if hud:
			hud.set_chase(tr("UI_CH30_PUSH"), float(near["hold"]) / 0.8)
		if float(near["hold"]) >= 0.8:
			push_ladder(near)
	else:
		near["hold"] = 0.0
		if hud:
			hud.set_chase("", 0.0)


## Merdiveni it: tepesi dışa devrilir, üstündekiler düşer; dipte bekleyenler yeniden dayayana kadar bekler.
func push_ladder(l: Dictionary) -> void:
	var lad: Ladder = l["node"]
	l["down"] = 7.0
	l["hold"] = 0.0
	pushed_ladders += 1
	foes = _prune(foes)
	if hud:
		hud.set_chase("", 0.0)
		hud.set_prompt("")
		hud.bark("SPK_TOLGA", "D30_T_PUSH", 2.0)
	_ladder_prompt = false
	Audio.sfx_at("wood_creak", lad, 0.0)
	Audio.sfx("whoosh_fly", -4.0, 0.6)
	var tw := lad.create_tween()
	tw.tween_property(lad, "rotation:x", deg_to_rad(78.0), 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var out: Vector3 = l["out"]
	tw.tween_callback(func():
		Audio.sfx_at("land_thud", lad, 2.0)
		Vfx.dust(scene, (l["base"] as Vector3) + out * lad.height * 0.9 + Vector3(0, 0.2, 0), 1.0))
	for d in foes:
		if not is_instance_valid(d) or d._climb.is_empty() or not (d._climb["base"] as Vector3).is_equal_approx(l["base"]):
			continue
		if d.climbing() and float(d._climb["t"]) >= 0.0:
			d.ladder_pushed(out)
		elif float(d._climb["t"]) < 0.0:
			d._climb["t"] = minf(float(d._climb["t"]), -float(l["down"]) - 1.2)     # dipte bekleyen: merdiven yeniden dayanınca
	if GameState.autotest:
		print("LADDER pushed at=%s" % (l["base"] as Vector3).snapped(Vector3.ONE * 0.1))


func _raise_ladder(l: Dictionary) -> void:
	var lad: Ladder = l["node"]
	var tw := lad.create_tween()
	tw.tween_property(lad, "rotation:x", 0.0, 1.3).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func():
		Audio.sfx_at("land_thud", lad, -4.0)
		Vfx.ledge(scene, l["top"] as Vector3 + Vector3(0, 0.6, 0), l["out"]))


# ---------------------------------------------------------------- taze dostlar (yardıma koşanlar)

func _fresh_ally(i: int) -> Duelist:
	var byz := side == "byz"
	var look := {"coat": [Color("7a2a24"), Color("5a6a7a"), Color("6a5a3a")][i % 3], "pants": Color("3a2a22"), "hat": "helm",
		"mustache": true, "beard": i % 2 == 0} if byz else {"coat": [Color("2f5fa8"), Color("b3262d"), Color("6a4a3a")][i % 3],
		"pants": Color("e8e0d0"), "hat": ["bork", "azap", "turban"][i % 3], "mustache": true, "beard": i % 2 == 1}
	var d := Duelist.new(look, "spathion" if byz else "kilij", 0.45, i % 2 == 0)
	d.team = 0
	d.name_key = "SPK_DEFENDER" if byz else "SPK_AZAP"
	d.max_hp = 110.0
	d.hp = d.max_hp
	d.damage = 16.0
	return d


## Oyuncunun arkasından merdivenle sura tırmanan dostlar (hücumda azaplar oyuncunun peşinden çıkar): mazgaldan
## atlayıp dövüşe katılır.
func reinforce_climb(n: int, base: Vector3, top: Vector3, land: Vector3) -> void:
	for i in n:
		var d := _fresh_ally(i)
		scene.add_child(d)
		var side_v := (land - base)
		side_v.y = 0.0
		side_v = side_v.normalized().cross(Vector3.UP) if side_v.length() > 0.01 else Vector3.RIGHT
		d.climb_in(base, top, land + side_v * (0.6 if i % 2 == 0 else -0.6), 0.8 + i * 1.6)
		add_ally(d)
		fresh_allies += 1
		_risen.append({"d": d, "src": null, "home": land, "yaw": 0.0, "back": false, "t": 0.0})


## Oyuncunun arkasından (from) koşarak gelen dost askerler: n kişi, tarafın kılığında.
func reinforce(n: int, from: Vector3, near: Vector3) -> void:
	for i in n:
		var d := _fresh_ally(i)
		var side_v := (near - from).cross(Vector3.UP).normalized() if (near - from).length() > 0.1 else Vector3.RIGHT
		var start := from + side_v * (i - (n - 1) * 0.5) * 1.2
		arrive(d, start, near + side_v * (i - (n - 1) * 0.5) * 1.6, [], i * 0.3)
		add_ally(d)
		fresh_allies += 1
		# Dövüşten sonra geldikleri yere döner, orada gözden çıkar (sahnede birikmesinler)
		_risen.append({"d": d, "src": null, "home": d.global_position, "yaw": 0.0, "back": false, "t": 0.0})


## Dövüşten sonra taze dostlar: kalırlar (dövüşten sonra nefeslenen dostlar gibi, konuşanın önünden çekilirler).
func idle_allies() -> void:
	allies = _prune(allies)
	for a in allies:
		if is_instance_valid(a) and a.alive():
			_clear_target(a)
