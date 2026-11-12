extends Node
## Hükümdara el kaldırmak (docs/SENARYO_KURAL_CIGNEME.md §6). Sahibin sözü (12 Kasım, 2. tur): "hükümdara vurmaya
## kalkarsa vuramasın bir şekilde: ya hükümdar ya da oradaki askerler düşürsün bizi ... Sonrasında bizi karşı tarafa
## sürsünler: surların dışına, ordugâha doğru, bayraksız; ya da tersinde surlara doğru ... karşı tarafa geçince de o
## tarihten devam."
## Bölüm başına bir düğüm (sahnenin "Huzur" çocuğu). Sahnedeki hükümdarları (Person.face_id "fatih" / "emperor";
## çocuk Mehmed sayılmaz) kendisi bulur; bölüm yalnız bağlar:  preload("res://scripts/level/huzur.gd").watch(self, hud, player)
## Tetik (var olan girdiler, yeni tuş yok):
##   · serbest yürürken: tekme (F / sol tık) hükümdar FREE_REACH içinde ve bakış konisindeyken
##   · replikte ya da replik arasında (oyuncu donuk): yalnız F (sol tık replik ilerletir: kaza olmasın), LUNGE_REACH içinde
##     bakılan hükümdara atılır
##   · elde çantadan sert bir eşya (HARD_ITEMS) varken tekme: eşyayla vurmaya kalkar
##   · elde kılıç (dövüşte ya da dövüş bitip kılıç elde kaldıysa): kılıç sallama (sol tık / F) SWORD_REACH içinde
## Sonuç hep aynı: VURAMAZ. Yakınsa ve önündeyse hükümdarın karşı hamlesi (Mehmed genç ve çevik: bileği havada yakalar,
## yarım adımla boşa çıkarıp omuzdan yere bırakır; kılıçlıya tek parad, silah düşer · Konstantinos tecrübeli asker:
## omuzdan iter, ayağını çeler; kılıçlıya kabzayla süpürür), uzaksa ya da arkadan gelindiyse iki muhafız mızrak
## saplarıyla yere indirir. Sonra hüküm:
##   exile   kendi tarafının hükümdarı, kuşatmanın iki taraflı günlerinde: karşı tarafa sürgün (chapter8s, bayraksız)
##   pending kendi tarafının hükümdarı, kuşatmadan önce (Perde II, 34o): "kuşatmada karşımda görmek isterim"; kapı
##           dışarı, bölüm sürer; sürgün Büro'da (Perde II) ya da ilk iki taraflı sayfaya geçerken (34o) gerçekleşir
##   enemy   karşı tarafın hükümdarı (26'nın sonunda Fatih, 30o'da İmparator): geldiği yere geri itilir, bölüm sürer
##   ban     üçüncü kez: "bu adamı bir daha huzuruma getirmeyin"; sürgün yok, bölüm sürer; sonra hükümdara BAN_DIST'ten
##           fazla yaklaşamaz (muhafız önünü keser)
## Kuralı çiğnemeyen oyuncu için hiçbir şey değişmez: düğüm yalnız hükümdara dönük tekme/kılıç girdisinde çalışır.
## Otomatik test: --autotest=huzur (boş elle, replik arasında), huzur_sword (kılıçla), huzur_item (eşyayla),
## huzur_guard (arkadan: muhafız). Bot bölümün koyduğu anda değil, hükümdar ilk kez erişilebilir olunca çalışır.

const Kural := preload("res://scripts/level/kural.gd")

const LINES := [
	["SPK_FATIH", "HZR_FATIH_COUNTER"], ["SPK_FATIH", "HZR_FATIH_COUNTER_SWORD"],
	["SPK_EMPEROR", "HZR_EMP_COUNTER"], ["SPK_EMPEROR", "HZR_EMP_COUNTER_SWORD"],
	["SPK_FATIH", "HZR_FATIH_VERDICT"], ["SPK_EMPEROR", "HZR_EMP_VERDICT"],
	["SPK_FATIH", "HZR_FATIH_PRE"], ["SPK_EMPEROR", "HZR_EMP_PRE"],
	["SPK_FATIH", "HZR_FATIH_ENEMY"], ["SPK_EMPEROR", "HZR_EMP_ENEMY"],
	["SPK_FATIH", "HZR_FATIH_BAN"], ["SPK_EMPEROR", "HZR_EMP_BAN"],
	["SPK_JANISSARY", "HZR_JAN_GUARD"], ["SPK_CITY_GUARD", "HZR_BYZ_GUARD"],
	["SPK_JANISSARY", "HZR_JAN_BLOCK"], ["SPK_CITY_GUARD", "HZR_BYZ_BLOCK"],
	["SPK_TOLGA", "HZR_T_DOWN_1"], ["SPK_TOLGA", "HZR_T_DOWN_2"], ["SPK_TOLGA", "HZR_T_DOWN_3"],
	["SPK_TOLGA", "HZR_T_SWORD"],
	["SPK_NIHAT", "HZR_N_BURO_O"], ["SPK_NIHAT", "HZR_N_BURO_B"],
	["SPK_NIHAT", "HZR_N_BURO_BOTH"], ["SPK_TOLGA", "HZR_T_BURO"]]

## ---- ayar sabitleri (denge ve gizli süreler sahibin kararı; rapor2 §ayarlar)
const FREE_REACH := 2.4           # serbest yürürken tekmenin hükümdara yetiştiği uzaklık (Kural.REACH ile aynı aralık)
const LUNGE_REACH := 7.5          # replik sırasında (donuk) atılabildiği uzaklık: birkaç hızlı adım ve atılış (huzurda
                                  # hükümdar 6 m dolayında: 12'de taht 6,1 m, 30'da İmparator 6,3 m; ölçüm §6.6)
const DASH_SPEED := 8.0           # atılışın hızı (m/sn): uzaktan atılış ışınlanma gibi görünmesin
const SWORD_REACH := 3.0          # kılıç sallamanın yetiştiği uzaklık
const CONE := 0.86                # bakış konisi (cos ~30°): hükümdara bakılıyor olmalı
const COUNTER_DIST := 3.4         # bu uzaklıkta ve önündeyse hükümdarın kendisi karşılar; değilse muhafızlar
const BEHIND_DOT := -0.25         # hükümdarın önüne göre oyuncu bu açının arkasındaysa "arkadan geldi" (muhafız)
const LOOK_BACK := 1.2            # yere indikten sonra bakış bu kadar saniyede geri gelir (şart: ≤ 1,5 sn)
const BAN_DIST := 3.0             # üçüncü kezden sonra hükümdara bu kadar yaklaşılamaz
const EXILE_LIMIT := 2            # bu kadar sürgünden (ya da bekleyen sürgünden) sonra üçüncü deneme "ban" olur
const HOLD_LINE_MAX := 1.6        # tetikte açık replik en çok bu kadar beklenir (sesi kesilir)
const HARD_ITEMS := ["phone", "cube", "thermos", "powerbank", "lighter", "book", "cologne", "tape"]
## İki tarafın aynı günlerde yürüdüğü ilk sayfa (Siege.ORDER içindeki sıra): 42 (7 Nisan, Bizans) ve sonrası.
## Bundan önceki sayfalar (33o, 34o, 35o: 1452 ve kış) yalnız Osmanlı tarafında: orada sürgün bekletilir.
const TWO_SIDED_FROM := 42
const SURGUN_SCENE := "res://scenes/chapter8s.tscn"

var scene: Node3D
var hud: Hud
var player: Player
var busy := false
var rulers: Array[Person] = []
var _scan_t := 0.0
var _bot := ""
var _bot_t := 0.0
var _bot_done := false
var _bot_go := false
var last := ""                    # son olay (test için): counter_fatih, counter_emperor, guards, exile, pending, enemy, ban
var mode := ""                    # son hüküm
var log_lines: Array[String] = []
var _block_t := 0.0
var nearest_free := INF           # ölçüm: hükümdarın serbest anda oyuncuya en yakın uzaklığı (fırsat tablosu)


static func of(p_scene: Node3D, p_hud: Hud, p_player: Player) -> Node:
	var h := p_scene.get_node_or_null("Huzur")
	if h == null:
		h = load("res://scripts/level/huzur.gd").new()
		h.name = "Huzur"
		h.scene = p_scene
		h.hud = p_hud
		h.player = p_player
		p_scene.add_child(h)
	return h


## Tek satırlık bağlantı (bölüm, player ve hud kurulduktan sonra)
static func watch(p_scene: Node3D, p_hud: Hud, p_player: Player) -> Node:
	return of(p_scene, p_hud, p_player)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if GameState.autotest and GameState.autotest_variant.begins_with("huzur"):
		# Bölüm kendi varsayılan yolunu oynar (bilinmeyen varyant sonucunu bozmasın); bot burada, sürgün sahnesi
		# (chapter8s) zinciri flags.huzur_test'ten okur
		_bot = GameState.autotest_variant
		GameState.flags["huzur_test"] = _bot
		GameState.autotest_variant = ""
	elif GameState.autotest and GameState.flags.has("huzur_test") and GameState.autotest_variant == "":
		_bot = ""          # sürgünden sonra açılan sayfa: bot yeniden saldırmaz


func _log(s: String) -> void:
	log_lines.append(s)
	if GameState.autotest:
		print("HUZUR " + s)


# ================================================================ hükümdarları bul

func _scan() -> void:
	rulers.clear()
	for n in get_tree().get_nodes_in_group("persons"):
		var p := n as Person
		if p == null or p.child or not p.face_id in ["fatih", "emperor"]:
			continue
		rulers.append(p)


static func ruler_side(p: Person) -> String:
	return "O" if p.face_id == "fatih" else "B"


func _visible_ruler(p: Person) -> bool:
	return is_instance_valid(p) and p.is_inside_tree() and p.is_visible_in_tree() and not p.get_meta("hologram", false)


## Bakılan ve uzanılabilen hükümdar (yoksa null)
func _target(reach: float, cone := CONE) -> Person:
	var cam := player.camera
	var fwd := -cam.global_transform.basis.z
	fwd.y = 0.0
	if fwd.length() < 0.01:
		return null
	fwd = fwd.normalized()
	var best: Person = null
	var bd := reach
	for p in rulers:
		if not _visible_ruler(p):
			continue
		var to := p.global_position - player.global_position
		var dy := absf(to.y)
		to.y = 0.0
		var d := to.length()
		if d > bd or d < 0.05 or dy > 1.8 or to.normalized().dot(fwd) < cone:
			continue
		if not _clear(player.camera.global_position, p.global_position + Vector3(0, 1.5, 0), p):
			continue
		bd = d
		best = p
	return best


## Aradaki yol açık mı (duvar, perde, masa yok)
func _clear(a: Vector3, b: Vector3, who: Node3D) -> bool:
	var space := player.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(a, b, 1, [player.get_rid()])
	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return true
	var c = hit.get("collider")
	if c is Node and (c == who or who.is_ancestor_of(c)):
		return true
	return (hit["position"] as Vector3).distance_to(b) < 1.2      # tahtın basamağı, masanın kenarı: hükümdarın dibi


# ================================================================ girdi

func _physics_process(delta: float) -> void:
	if scene == null or player == null or not is_instance_valid(player) or not player.is_inside_tree():
		return
	_scan_t -= delta
	if _scan_t <= 0.0:
		_scan_t = 0.5
		_scan()
	if rulers.is_empty() or busy:
		return
	_measure()
	if GameState.flags.get("huzur_ban", false):
		_ban_tick(delta)
	if _bot != "":
		_bot_tick(delta)
	var kind := _input_kind()
	if kind == "":
		return
	var reach := FREE_REACH
	var cone := CONE
	if player.frozen:
		reach = LUNGE_REACH
		cone = 0.9
	elif kind == "sword":
		reach = SWORD_REACH
	var p := _target(reach, cone)
	if p == null:
		return
	attempt(p, kind)


## Hangi saldırı girdisi (yoksa ""). Seçim kutusunda, menüde, merdivende, yerdeyken, kamera başkasındayken yok.
func _input_kind() -> String:
	var bot := _bot_go
	_bot_go = false
	if get_tree().paused or hud.is_choosing() or player.is_down or player.ladder != null or player.look_lock:
		return ""
	if not player.camera.current or hud.is_bag_open():
		return ""
	if player.traversal != null and player.traversal.state != "":
		return ""
	var blade := _player_blade() != null
	# Replik açıkken (ya da oyuncu donukken) sol tık replik ilerletir: yalnız ilerletmeyen tuş (F, kolda tetik) saldırıdır
	var advancing := Input.is_action_just_pressed("advance") and (hud.line_open or player.frozen)
	if blade:
		if bot or ((Input.is_action_just_pressed("sword_attack") or Input.is_action_just_pressed("kick")) and not advancing):
			return "sword"
		return ""
	if player.hand_style != "tolga":
		return ""
	var pressed := bot or Input.is_action_just_pressed("kick")
	if not pressed:
		return ""
	if not bot and advancing:
		return ""
	if player.focus_id.begins_with("mg:") or player.focus_id.begins_with("ev:"):
		return ""
	return "item" if player.held_item() in HARD_ITEMS else "kick"


## Oyuncunun elindeki kılıç: dövüş sürüyorsa Duel'in kılıcı, bittiyse elde bırakılan kılıç
func _player_blade() -> Node3D:
	if player.has_kept_blade():
		return player._kept.get("sword") as Node3D
	if not player.combat:
		return null
	var d := _duel()
	if d and d.active and d.sword and is_instance_valid(d.sword) and d.sword.is_visible_in_tree():
		return d.sword
	return null


func _duel() -> Duel:
	for n in scene.find_children("*", "Node", true, false):
		if n is Duel:
			return n as Duel
	return null


# ================================================================ deneme

func attempt(p: Person, kind: String) -> void:
	if busy or not _visible_ruler(p):
		return
	busy = true
	var rs := ruler_side(p)
	mode = _verdict_mode(rs)
	var dist := Vector2(p.global_position.x - player.global_position.x, p.global_position.z - player.global_position.z).length()
	var rf := p.global_transform.basis.z
	rf.y = 0.0
	var to_pl := player.global_position - p.global_position
	to_pl.y = 0.0
	var front := rf.normalized().dot(to_pl.normalized()) if rf.length() > 0.01 and to_pl.length() > 0.01 else 1.0
	var counter := "ruler" if dist <= COUNTER_DIST and front >= BEHIND_DOT and _bot != "huzur_guard" else "guards"
	_log("attempt ruler=%s kind=%s dist=%.1f front=%.2f counter=%s mode=%s ch=%d side=%s" % [p.face_id, kind, dist, front,
		counter, mode, GameState.current_chapter, Siege.side()])
	GameState.bump_stat("tarihe_tekme")      # ACH_TARIHE_TEKME karşı hamle anında (Hud saniyede bir bakar)
	var was_frozen := player.frozen
	var was_free_look := player.free_look
	player.frozen = true
	await _hold_dialogue()
	var origin := player.global_position
	if counter == "ruler":
		last = "counter_" + p.face_id
		if p.face_id == "fatih":
			await _counter_mehmed(p, kind)
		else:
			await _counter_konstantinos(p, kind)
	else:
		last = "guards"
		if not await _guards(p, kind, rs):
			# Görünürde ve yolda muhafız yok (çadırın içi, dar sur yolu): hükümdar kendisi karşılar
			last = "counter_" + p.face_id
			if p.face_id == "fatih":
				await _counter_mehmed(p, kind)
			else:
				await _counter_konstantinos(p, kind)
	# Bakış geri gelir (donukken de fare: Player.free_look)
	await get_tree().create_timer(LOOK_BACK if not Stage.fast() else 0.05, false).timeout
	player.free_look = true
	var line_key := ""
	match mode:
		"exile":
			line_key = "HZR_FATIH_VERDICT" if rs == "O" else "HZR_EMP_VERDICT"
		"pending":
			line_key = "HZR_FATIH_PRE" if rs == "O" else "HZR_EMP_PRE"
		"enemy":
			line_key = "HZR_FATIH_ENEMY" if rs == "O" else "HZR_EMP_ENEMY"
		_:
			line_key = "HZR_FATIH_BAN" if rs == "O" else "HZR_EMP_BAN"
	p.look_target = player
	await _say(_spk(p), line_key)
	var n_down := int(GameState.stats.get("tarihe_tekme", 1))
	await _say("SPK_TOLGA", "HZR_T_SWORD" if kind == "sword" else "HZR_T_DOWN_%d" % (1 + (n_down - 1) % 3))
	match mode:
		"exile":
			await _exile(p, rs)
			return            # sahne değişti
		"pending":
			_record_pending(rs)
			await _put_out(origin, p)
		"enemy":
			await _put_out(origin, p)
		_:
			GameState.flags["huzur_ban"] = true
			await _put_out(origin, p)
	_restore_blade()
	player.free_look = was_free_look
	_release_dialogue()
	player.frozen = was_frozen
	p.look_target = null
	_log("done mode=%s last=%s surgun_n=%d pending=%s ban=%s" % [mode, last, int(GameState.flags.get("surgun_n", 0)),
		str(GameState.flags.get("surgun_pending", {})), str(GameState.flags.get("huzur_ban", false))])
	busy = false


func _spk(p: Person) -> String:
	return "SPK_FATIH" if p.face_id == "fatih" else "SPK_EMPEROR"


## Hüküm: kendi tarafının hükümdarı mı, kuşatmanın iki taraflı günlerinde mi, kaçıncı kez
func _verdict_mode(rs: String) -> String:
	var ch := GameState.current_chapter
	var siege: bool = ch in Siege.ORDER and bool(GameState.flags.get("siege_bureau_done", true))
	var own := true
	if siege:
		own = Siege.side() == rs
	if not own:
		return "enemy"
	if int(GameState.flags.get("surgun_n", 0)) >= EXILE_LIMIT or GameState.flags.get("huzur_ban", false):
		return "ban"
	if siege and two_sided(ch):
		return "exile"
	return "pending"


## Bu sayfa iki tarafın da yürüdüğü günlerde mi (7 Nisan ve sonrası)
static func two_sided(ch: int) -> bool:
	return Siege.ORDER.find(ch) >= Siege.ORDER.find(TWO_SIDED_FROM)


# ================================================================ replik akışını tutmak

var _holding := false


## Açık replik kısa sürede kapanır (sesi kesilir); sonra Hud'un replik yeri tutulur: bölümün sıradaki repliği
## (Hud.say "line_open" bekler) bu sahne bitene kadar sırada kalır. Seçim kutusu açıkken tetik yoktur.
func _hold_dialogue() -> void:
	if hud.line_open:
		hud.cut_voice()
		var t := 0.0
		while hud.line_open and t < HOLD_LINE_MAX:
			await get_tree().process_frame
			t += get_process_delta_time()
	hud.line_open = true
	_holding = true


func _release_dialogue() -> void:
	if _holding:
		_holding = false
		hud.line_open = false


func _say(spk: String, key: String) -> void:
	if _holding:
		hud.line_open = false
	await hud.say(spk, key)
	if _holding:
		hud.line_open = true


# ================================================================ karşı hamleler

## Oyuncunun uzanan uzvu: tekmede ayak, eşyada/boş elde el, kılıçta kılıcın kabzası (dünya)
func _limb_point(kind: String) -> Vector3:
	match kind:
		"kick":
			if player.leg:
				return player.leg.to_global(Vector3(0, -1.0, -0.1))
		"sword":
			var b := _player_blade()
			if b:
				return b.global_position
	if player.hand:
		return player.hand.global_position
	return player.camera.global_position + (-player.camera.global_transform.basis.z) * 0.6 + Vector3(0, -0.3, 0)


## Uzuv öne çıkar (tekme: bacak kalkar; el/eşya: el öne uzanır; kılıç: kılıç kalkar), oyuncu hükümdara yarım adım atılır
func _lunge(p: Person, kind: String) -> void:
	var to := p.global_position - player.global_position
	to.y = 0.0
	var stop := 1.05 if kind != "sword" else 1.5
	var dest := player.global_position + to.normalized() * maxf(0.0, to.length() - stop)
	dest.y = player.global_position.y
	player.face(p.global_position + Vector3(0, 1.4, 0))
	dest = _safe(player.global_position, dest)
	var t := 0.05 if Stage.fast() else 0.22 + maxf(0.0, player.global_position.distance_to(dest) - 1.0) / DASH_SPEED
	var tw := player.create_tween().set_parallel()
	tw.tween_property(player, "global_position", dest, t).set_trans(Tween.TRANS_QUAD)
	match kind:
		"kick":
			if player.leg:
				player.leg.visible = true
				player.leg.position = Vector3(0.12, -0.3, 0.15)
				player.leg.rotation_degrees = Vector3(5, 0, 0)
				tw.tween_property(player.leg, "rotation_degrees:x", 70.0, t).set_trans(Tween.TRANS_BACK)
				tw.tween_property(player.leg, "position", Vector3(0.05, -0.22, -0.05), t)
		"sword":
			var b := _player_blade()
			if b:
				tw.tween_property(b, "rotation_degrees:x", b.rotation_degrees.x + 55.0, t)
		_:
			if player.hand:
				tw.tween_property(player.hand, "position", Vector3(0.12, -0.08, -0.62), t).set_trans(Tween.TRANS_BACK)
	Audio.sfx("whoosh_fly", -14.0, 1.4)
	await tw.finished


## Uzuv yerine döner
func _limb_back() -> void:
	if player.leg and player.leg.visible:
		var tw := player.create_tween()
		tw.tween_property(player.leg, "rotation_degrees:x", 5.0, 0.05 if Stage.fast() else 0.3)
		await tw.finished
		player.leg.visible = false
	if player.hand:
		var tw2 := player.create_tween()
		tw2.tween_property(player.hand, "position", player._hand_base, 0.05 if Stage.fast() else 0.35)


## Hükümdarın eli uzva yapışık kalır (her karede): IK kolu oyuncunun eline/ayağına uzatır
func _grip(p: Person, kind: String, left: bool, secs: float) -> void:
	var rg := p.rig
	if rg == null:
		return
	rg.lock += 1
	var arm: Node3D = rg.arm_l if left else rg.arm_r
	var el: Node3D = rg.elbow_l if left else rg.elbow_r
	if arm == null or el == null:
		rg.lock = maxi(0, rg.lock - 1)
		return
	var r0 := arm.rotation
	var e0 := el.rotation
	var t := 0.0
	var dur := secs if not Stage.fast() else 0.1
	while t < dur and is_instance_valid(p) and is_instance_valid(player):
		Rig.reach(arm, el, _limb_point(kind), Vector3.DOWN + p.global_transform.basis.x * (-0.6 if left else 0.6))
		await get_tree().process_frame
		t += get_process_delta_time()
	if is_instance_valid(p):
		var tw := p.create_tween().set_parallel()
		tw.tween_property(arm, "rotation", r0, 0.05 if Stage.fast() else 0.35)
		tw.tween_property(el, "rotation", e0, 0.05 if Stage.fast() else 0.35)
		await tw.finished
		rg.lock = maxi(0, rg.lock - 1)


## Oyuncu yere iner: kamera sarsılır, yana yatar, göz hizası yere iner; dest'e (yerde) kayar, bakış up_at'e
func _fall(dest: Vector3, roll: float, up_at: Vector3, secs := 0.55) -> void:
	player.shake(0.9)
	Audio.sfx("land_thud", -2.0, 0.85)
	var t := 0.05 if Stage.fast() else secs
	dest = _safe(player.global_position, dest)
	var tw := player.create_tween().set_parallel()
	tw.tween_property(player, "global_position", dest, t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(player, "eye_height", 0.42, t).set_ease(Tween.EASE_IN)
	tw.tween_property(player.camera, "rotation:z", roll, t * 0.6).set_trans(Tween.TRANS_SINE)
	await tw.finished
	player.shake(0.5)
	var tw2 := player.create_tween().set_parallel()
	tw2.tween_property(player.camera, "rotation:z", roll * 0.25, 0.05 if Stage.fast() else 0.4).set_trans(Tween.TRANS_SINE)
	await tw2.finished
	player.face(up_at)


## Yere iniş noktası duvarın/katının içinde olmasın: aradaki yol kapalıysa kısalt
func _safe(from: Vector3, to: Vector3) -> Vector3:
	var space := player.get_world_3d().direct_space_state
	var a := from + Vector3(0, 0.6, 0)
	var b := Vector3(to.x, a.y, to.z)
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(a, b, 1, [player.get_rid()]))
	if hit.is_empty():
		return Vector3(to.x, from.y, to.z)
	var hp: Vector3 = hit["position"]
	var back := (a - hp)
	back.y = 0.0
	var p := hp + back.normalized() * 0.5
	return Vector3(p.x, from.y, p.z)


## Kalkış: göz hizası ve kamera yerine (sahne sürerken; sürgünde kararmadan sonra)
func _get_up() -> void:
	var t := 0.05 if Stage.fast() else 0.7
	var tw := player.create_tween().set_parallel()
	tw.tween_property(player, "eye_height", player.eye_rest, t).set_trans(Tween.TRANS_SINE)
	tw.tween_property(player.camera, "rotation:z", 0.0, t)
	await tw.finished


## Mehmed: genç ve çevik. Uzanan bileği (ayağı) havada yakalar, yarım adım yana çekilip çevirir, omzundan yere bırakır.
## Kılıçla gelene: kendi kılıcını çeker, tek parad; bileği çevirir, oyuncunun kılıcı yere düşer.
func _counter_mehmed(p: Person, kind: String) -> void:
	p.look_target = player
	p.face_toward(player.global_position)
	var own: Node3D = null
	if kind == "sword":
		own = _ruler_blade(p, "kilij")
	await _lunge(p, kind)
	var side := p.global_transform.basis.x
	side.y = 0.0
	side = side.normalized()
	var p0 := p.global_position
	# Yarım adım: gövde oyuncunun hattından çıkar (ayaklar yerde, y değişmez)
	var step := p.create_tween()
	step.tween_property(p, "global_position", p0 + side * 0.42, 0.05 if Stage.fast() else 0.2).set_trans(Tween.TRANS_SINE)
	if kind == "sword" and own:
		Audio.sfx("sword_clash", -4.0, 1.1)
		var swing := own.create_tween()
		swing.tween_property(own, "rotation_degrees:x", own.rotation_degrees.x - 70.0, 0.05 if Stage.fast() else 0.16)
		_disarm()
	_grip(p, kind, false, 0.9)
	await get_tree().create_timer(0.05 if Stage.fast() else 0.35, false).timeout
	# Çevirir ve bırakır: oyuncu hükümdarın yanından geçip yere (hükümdarın arkasına değil, yanına) iner
	var fwd := p0 - player.global_position
	fwd.y = 0.0
	var dest := p0 + side * 1.2 + fwd.normalized() * 0.4
	await _limb_back()
	await _fall(dest, deg_to_rad(-58.0), p.global_position + side * 0.42 + Vector3(0, 1.65, 0))
	if own:
		var tw := own.create_tween()
		tw.tween_property(own, "rotation_degrees:x", own.rotation_degrees.x + 70.0, 0.05 if Stage.fast() else 0.4)
	await _say(_spk(p), "HZR_FATIH_COUNTER_SWORD" if kind == "sword" else "HZR_FATIH_COUNTER")
	var back := p.create_tween()
	back.tween_property(p, "global_position", p0, 0.05 if Stage.fast() else 0.5).set_trans(Tween.TRANS_SINE)
	p.face_toward(player.global_position)


## Konstantinos: tecrübeli asker. Sol eliyle göğsünden iter, sağ ayağıyla ayağını çeler: oyuncu sırtüstü düşer.
## Kılıçla gelene: kendi kılıcının kabzasıyla oyuncunun kılıcını süpürür, kılıç düşer.
func _counter_konstantinos(p: Person, kind: String) -> void:
	p.look_target = player
	p.face_toward(player.global_position)
	var own: Node3D = null
	if kind == "sword":
		own = _ruler_blade(p, "spathion")
	await _lunge(p, kind)
	if kind == "sword" and own:
		Audio.sfx("sword_clash", -4.0, 0.9)
		var sw := own.create_tween()
		sw.tween_property(own, "rotation_degrees:z", own.rotation_degrees.z + 80.0, 0.05 if Stage.fast() else 0.18)
		sw.tween_property(own, "rotation_degrees:z", own.rotation_degrees.z, 0.05 if Stage.fast() else 0.4)
		_disarm()
	# Göğse sol el (her karede oyuncunun göğsünde), sağ bacak çeler
	var rg := p.rig
	if rg and rg.leg_r:
		var l0 := rg.leg_r.rotation
		var lt := p.create_tween()
		lt.tween_property(rg.leg_r, "rotation:x", deg_to_rad(-38.0), 0.05 if Stage.fast() else 0.22).set_trans(Tween.TRANS_BACK)
		lt.tween_interval(0.05 if Stage.fast() else 0.35)
		lt.tween_property(rg.leg_r, "rotation", l0, 0.05 if Stage.fast() else 0.4)
	_grip_chest(p, 0.8)
	await get_tree().create_timer(0.05 if Stage.fast() else 0.3, false).timeout
	var away := player.global_position - p.global_position
	away.y = 0.0
	var dest := player.global_position + away.normalized() * 1.1
	await _limb_back()
	await _fall(dest, deg_to_rad(18.0), p.global_position + Vector3(0, 1.7, 0), 0.6)
	await _say(_spk(p), "HZR_EMP_COUNTER_SWORD" if kind == "sword" else "HZR_EMP_COUNTER")
	p.face_toward(player.global_position)


## Sol el oyuncunun göğsüne (kameranın 0,45 m altı, 0,3 m önü)
func _grip_chest(p: Person, secs: float) -> void:
	var rg := p.rig
	if rg == null or rg.arm_l == null or rg.elbow_l == null:
		return
	rg.lock += 1
	var r0 := rg.arm_l.rotation
	var e0 := rg.elbow_l.rotation
	var t := 0.0
	var dur := secs if not Stage.fast() else 0.1
	while t < dur and is_instance_valid(p):
		var cam := player.camera.global_transform
		var chest := cam.origin + Vector3(0, -0.45, 0) + (-cam.basis.z) * 0.3
		Rig.reach(rg.arm_l, rg.elbow_l, chest, Vector3.DOWN - p.global_transform.basis.x * 0.6)
		await get_tree().process_frame
		t += get_process_delta_time()
	if is_instance_valid(p):
		var tw := p.create_tween().set_parallel()
		tw.tween_property(rg.arm_l, "rotation", r0, 0.05 if Stage.fast() else 0.35)
		tw.tween_property(rg.elbow_l, "rotation", e0, 0.05 if Stage.fast() else 0.35)
		await tw.finished
		rg.lock = maxi(0, rg.lock - 1)


## Hükümdarın kendi kılıcı: sağ önkolda (yoksa takılır; sahne bitince kalır, kılıç kuşanmış hükümdar)
func _ruler_blade(p: Person, kind: String) -> Node3D:
	var el: Node3D = p.rig.elbow_r if p.rig else null
	if el == null:
		return null
	var b := el.get_node_or_null("HuzurBlade") as Node3D
	if b == null:
		b = Node3D.new()
		b.name = "HuzurBlade"
		el.add_child(b)
		b.position = Vector3(0, -0.3, 0.05)
		b.rotation_degrees = Vector3(-80, 0, 0)
		if kind == "kilij":
			Blades.kilij(b)
		else:
			Blades.spathion(b)
		Props.strip_outlines(b)
	p.set_meta("armed", true)
	return b


var _dropped: Node3D
var _blade_hidden: Node3D


## Oyuncunun kılıcı elinden fırlar ve yere düşer (görünen kılıç gizlenir, yere aynı biçimde bir kılıç iner)
func _disarm() -> void:
	var b := _player_blade()
	if b == null:
		return
	var at := b.global_position
	_blade_hidden = b
	b.visible = false
	_dropped = Node3D.new()
	scene.add_child(_dropped)
	_dropped.global_position = at
	if Siege.side() == "O":
		Blades.kilij(_dropped)
	else:
		Blades.spathion(_dropped)
	_dropped.set_meta("transient", true)
	var fwd := -player.camera.global_transform.basis.z
	fwd.y = 0.0
	var land := at + fwd.normalized() * 1.4 + player.camera.global_transform.basis.x * 0.6
	land.y = player.global_position.y + 0.04
	var tw := _dropped.create_tween().set_parallel()
	tw.tween_property(_dropped, "global_position", land, 0.05 if Stage.fast() else 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(_dropped, "global_rotation", Vector3(deg_to_rad(90.0), randf() * TAU, 0.0), 0.05 if Stage.fast() else 0.45)
	await tw.finished
	Audio.sfx("land_thud", -10.0, 1.6)


## Kılıç geri verilir (sürgünsüz sonuçlarda: muhafız yerden alıp uzatır; kararmada)
func _restore_blade() -> void:
	if is_instance_valid(_dropped):
		_dropped.queue_free()
	_dropped = null
	if is_instance_valid(_blade_hidden):
		_blade_hidden.visible = true
	_blade_hidden = null


## Muhafızlar: en yakın iki asker (sahnede duran) koşarak araya girer; yoksa görüş dışından iki muhafız gelir. Mızrak
## sapları çaprazlanır, oyuncu geri itilip yere iner.
func _guards(p: Person, kind: String, rs: String) -> bool:
	var gs := _nearest_guards(p, 2)
	var spawned: Array[Node3D] = []
	var k := Kural.of(scene, hud, player)
	var tries := 0
	while gs.size() < 2 and tries < 2:
		tries += 1
		var g: Node3D = await k._guard_run("O" if rs == "O" else "B", "JAN" if rs == "O" else "BYZSOL")
		if g == null:
			break
		g.set_meta("huzur_guard", true)
		if g is Person and (g as Person).rig and (g as Person).rig.elbow_r and (g as Person).rig.elbow_r.get_node_or_null("Spear") == null:
			(g as Person).equip("spear")
		gs.append(g)
		spawned.append(g)
	if gs.is_empty():
		return false
	await _lunge(p, kind)
	if kind == "sword":
		_disarm()
	var me := player.global_position
	var i := 0
	for g in gs:
		var side := player.camera.global_transform.basis.x * (0.75 if i == 0 else -0.75)
		await Stage.approach(g, me + side, 0.7, 4.6)
		if is_instance_valid(g):
			g.set("look_target", player)
		i += 1
	if not gs.is_empty():
		_say("SPK_JANISSARY" if rs == "O" else "SPK_CITY_GUARD", "HZR_JAN_GUARD" if rs == "O" else "HZR_BYZ_GUARD")
		for g in gs:
			if g is Person:
				(g as Person).reach_to(player.camera.global_position + Vector3(0, -0.5, 0), 0.6)
	await _limb_back()
	var away := player.global_position - p.global_position
	away.y = 0.0
	await _fall(player.global_position + away.normalized() * 1.3, deg_to_rad(12.0), p.global_position + Vector3(0, 1.6, 0), 0.5)
	while hud.is_talking():
		await get_tree().process_frame
	for g in spawned:
		g.set_meta("huzur_spawned", true)
	_spawned = spawned
	return true


var _spawned: Array[Node3D] = []


func _nearest_guards(p: Person, n: int) -> Array[Node3D]:
	var out: Array[Node3D] = []
	var cands: Array = []
	for g in ["soldiers", "persons"]:
		for q in get_tree().get_nodes_in_group(g):
			var c := q as Node3D
			if c == null or c == p or not c.is_visible_in_tree() or c.get_meta("hologram", false) or c.has_meta("spk"):
				continue
			if c is Person and ((c as Person).face_id != "" or (c as Person).child or (c as Person).skirt or (c as Person).is_busy()):
				continue
			if c is Soldier and (c as Soldier).pose != "stand":
				continue
			if not (c is Soldier or c.get_meta("street_role", "") in ["JAN", "BYZSOL", "OSMSOL", "AZAP"]):
				continue
			var d := c.global_position.distance_to(player.global_position)
			if d > 18.0 or absf(c.global_position.y - player.global_position.y) > 1.5:
				continue
			cands.append([d, c])
	cands.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for it in cands:
		if out.size() >= n:
			break
		out.append(it[1])
	return out


# ================================================================ hükümler

## Kapı dışarı / geri itilme (sürgünsüz): kararır, oyuncu hükümdardan uzak bir yere (geldiği yere) konur, kalkar
func _put_out(origin: Vector3, p: Person) -> void:
	await hud.fade_to(1.0, 0.5)
	_restore_blade()
	for g in _spawned:
		if is_instance_valid(g):
			g.queue_free()
	_spawned.clear()
	var away := origin - p.global_position
	away.y = 0.0
	var back := origin + (away.normalized() if away.length() > 0.1 else Vector3.ZERO) * 2.5
	player.global_position = _safe(origin, back)
	player.eye_height = player.eye_rest
	player.camera.rotation.z = 0.0
	player.face(p.global_position + Vector3(0, 1.6, 0))
	await hud.fade_to(0.0, 0.6)


## Bekleyen sürgün (kuşatmadan önce): Büro tarafı karşıya yazar (Perde II) ya da ilk iki taraflı sayfaya geçerken
## yürüyüş (34o). Sayılır (üçüncüsü "ban").
func _record_pending(rs: String) -> void:
	var f := GameState.flags
	var pend: Dictionary = f.get("surgun_pending", {})
	if not pend.is_empty() and String(pend.get("from", "")) != rs:
		f["surgun_pending_both"] = true      # iki hükümdar da: Büro'da Nihat söyler, taraf serbest kalır
	f["surgun_pending"] = {"from": rs, "ruler": "fatih" if rs == "O" else "emperor", "ch": GameState.current_chapter}
	f["surgun_n"] = int(f.get("surgun_n", 0)) + 1
	_log("pending from=%s n=%d" % [rs, int(f["surgun_n"])])


## Sürgün: askerler kapıya götürür (kararma), yürüyüş sahnesi açılır. Hedef: karşı tarafın bu sayfadan sonraki ilk sayfası.
func _exile(p: Person, rs: String) -> void:
	var ch := GameState.current_chapter
	var to_side := "B" if rs == "O" else "O"
	_log("exile from=%s ch=%d" % [rs, ch])
	await hud.fade_to(1.0, 0.7)
	_restore_blade()
	GameState.change_scene(prepare_walk(ch, rs, to_side, "fatih" if rs == "O" else "emperor"), false)


## Sürgün yürüyüşünü kurar, sahnesinin yolunu döner (Siege.next_path de çağırır: 34o'dan gelen bekleyen sürgün)
static func prepare_walk(from_ch: int, from_side: String, to_side: String, ruler: String) -> String:
	var f := GameState.flags
	var target := next_on(from_ch, to_side)
	f["surgun_walk"] = {"from_ch": from_ch, "from": from_side, "to": to_side, "ruler": ruler,
		"to_ch": target, "to_path": Siege.scene_path(target, to_side) if target > 0 else Siege.return_path()}
	f["surgun_n"] = int(f.get("surgun_n", 0)) + (0 if f.get("surgun_from_pending", false) else 1)
	f.erase("surgun_from_pending")
	GameState.bump_stat("surgun")
	return SURGUN_SCENE


## Karşı tarafın verilen sayfadan sonraki ilk sayfası (yoksa 0: kuşatma bitti, dönüş yolu)
static func next_on(ch: int, sd: String) -> int:
	var i := Siege.ORDER.find(ch)
	for k in range(i + 1, Siege.ORDER.size()):
		var c: int = Siege.ORDER[k]
		if Siege._plays(c, true, sd):
			return c
	return 0


## Siege.next_path'ten: bekleyen sürgün (34o) iki taraflı günlere geçerken yürüyüşe döner (true: prepare_walk'ın
## yolu açılmalı). Kendi tarafında oynuyorsa ve sıradaki sayfa iki taraflı günlerdeyse.
static func pending_walk(ch: int, next_ch: int) -> bool:
	var pend: Dictionary = GameState.flags.get("surgun_pending", {})
	if pend.is_empty() or GameState.flags.get("surgun_pending_both", false):
		return false
	if String(pend.get("from", "")) != Siege.side() or not two_sided(next_ch):
		return false
	GameState.flags.erase("surgun_pending")
	GameState.flags["surgun_from_pending"] = true
	return true


## Büro (chapter17, taraf seçiminden önce): Perde II'de bekleyen sürgün tarafı belirler. Döner: zorlanan taraf ("" serbest).
static func bureau_side(p_hud: Hud) -> String:
	var f := GameState.flags
	var pend: Dictionary = f.get("surgun_pending", {})
	if pend.is_empty():
		return ""
	if f.get("surgun_pending_both", false):
		await p_hud.say("SPK_NIHAT", "HZR_N_BURO_BOTH")
		f.erase("surgun_pending")
		f.erase("surgun_pending_both")
		f["huzur_ban"] = true
		return ""
	var from := String(pend.get("from", "O"))
	await p_hud.say("SPK_NIHAT", "HZR_N_BURO_" + ("B" if from == "O" else "O"))
	await p_hud.say("SPK_TOLGA", "HZR_T_BURO")
	f.erase("surgun_pending")
	f["surgun_bureau"] = from
	var hist: Array = f.get("surgun_log", [])
	hist.append({"ch": int(pend.get("ch", 0)), "from": from, "to": "B" if from == "O" else "O", "at": Siege.BUREAU})
	f["surgun_log"] = hist
	GameState.bump_stat("surgun")
	return "B" if from == "O" else "O"


# ================================================================ ban: muhafız önünü keser

func _ban_tick(delta: float) -> void:
	_block_t = maxf(0.0, _block_t - delta)
	if player.frozen or _block_t > 0.0:
		return
	for p in rulers:
		if not _visible_ruler(p) or ruler_side(p) != _own_side():
			continue
		var to := player.global_position - p.global_position
		to.y = 0.0
		if to.length() < BAN_DIST and to.length() > 0.05:
			_block_t = 6.0
			var push := p.global_position + to.normalized() * (BAN_DIST + 0.6)
			player.global_position = _safe(player.global_position, Vector3(push.x, player.global_position.y, push.z))
			hud.bark("SPK_JANISSARY" if ruler_side(p) == "O" else "SPK_CITY_GUARD",
				"HZR_JAN_BLOCK" if ruler_side(p) == "O" else "HZR_BYZ_BLOCK", 3.0)
			_log("ban block")
			return


func _own_side() -> String:
	return Siege.side() if GameState.current_chapter in Siege.ORDER else ruler_side(rulers[0]) if not rulers.is_empty() else ""


# ================================================================ ölçüm ve test

var nearest_any := INF          # ölçüm: donukken de (replik sırasında) en yakın uzaklık
var _seen_t := 0.0                # hükümdar görünürken geçen süre
var _free_t := 0.0                # hükümdar görünür ve oyuncu serbestken geçen süre
var _blade_t := 0.0               # hükümdar görünür ve elde kılıç varken geçen süre


## Fırsat tablosu ölçümü: hükümdara en yakın yatay uzaklık (serbestken ve her an), görünür/serbest/kılıçlı süreler.
## Otomatik testte bölüm sahnesi kapanırken tek satır (HUZUR summary).
func _measure() -> void:
	var dt := get_physics_process_delta_time()
	var any := false
	for p in rulers:
		if not _visible_ruler(p):
			continue
		any = true
		var d := Vector2(p.global_position.x - player.global_position.x, p.global_position.z - player.global_position.z).length()
		nearest_any = minf(nearest_any, d)
		if not player.frozen:
			nearest_free = minf(nearest_free, d)
	if any:
		_seen_t += dt
		if not player.frozen:
			_free_t += dt
		if _player_blade() != null:
			_blade_t += dt


func _exit_tree() -> void:
	if GameState.autotest:
		print("HUZUR summary ch=%d rulers=%s seen=%.0fs free=%.0fs blade=%.0fs nearest_free=%.1f nearest_any=%.1f last=%s" % [
			GameState.current_chapter, ",".join(PackedStringArray(rulers.map(func(r): return r.face_id if is_instance_valid(r) else "?"))),
			_seen_t, _free_t, _blade_t, nearest_free, nearest_any, last])


## Bot: hükümdar ilk kez görünür ve oyuncu serbestken (ya da bir replik açıkken) yanına yürür, bakar, saldırır.
## huzur_guard: arkasına geçer (muhafızlar). huzur_sword: elde kılıç olmalı (bölüm kılıcı verdiyse). huzur_item: elde eşya.
func _bot_tick(delta: float) -> void:
	if _bot_done:
		return
	_bot_t += delta
	if _bot_t < 1.0:
		return
	var p: Person = null
	for r in rulers:
		if _visible_ruler(r):
			p = r
			break
	if p == null:
		return
	if _bot == "huzur_sword" and _player_blade() == null:
		return
	if hud.is_choosing() or player.is_down or not player.camera.current:
		return
	var d := Vector2(p.global_position.x - player.global_position.x, p.global_position.z - player.global_position.z).length()
	if (player.frozen and d > LUNGE_REACH) or d > 14.0:
		return
	if player.frozen and not _clear(player.camera.global_position, p.global_position + Vector3(0, 1.5, 0), p):
		return
	_bot_done = true
	var fwd := p.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var spot := p.global_position + fwd * 1.8
	if _bot == "huzur_guard":
		spot = p.global_position - fwd * 1.8
	spot = _safe(player.global_position, Vector3(spot.x, player.global_position.y, spot.z))
	if _bot in ["huzur", "huzur_guard", "huzur_next", "huzur_save"] and not player.frozen and player.held != 0:
		player.select_item(0)          # boş el (kumanda cepte değil elde: eşya sayılmaz)
	if _bot == "huzur_item":
		for it in HARD_ITEMS:
			if it in GameState.bag:
				player.select_item(GameState.bag.find(it) + 1)
				break
	if not player.frozen:
		player.global_position = spot
	player.face(p.global_position + Vector3(0, 1.4, 0))
	_log("bot go d=%.1f frozen=%s line=%s" % [d, str(player.frozen), str(hud.line_open)])
	_bot_go = true


func test_line() -> String:
	return "huzur last=%s mode=%s nearest_free=%.1f" % [last, mode, nearest_free]
