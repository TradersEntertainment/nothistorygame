extends Node
## Kuralı çiğneyen oyuncu (docs/SENARYO_KURAL_CIGNEME.md). Sahibin sözü: "tolgayla savaş eğitiminden kaçtım ne. geçen
## halka vurmaya çalıştım vurulmadı". Oyun tepkisiz kalmasın: tepki, tırmanma, sonuç; komik ama dünyanın kuralı ciddi.
## Bölüm başına bir düğüm (sahnenin "Kural" çocuğu); iki izleyici:
##   watch_area   görev alanını terk: bölüm alanı (merkez, yarıçap), görev vereni ve kovalayanı bildirir.
##                1 laf (2 sn dışarıda) · 2 seslenme + kovalayan koşar (7 sn ya da 25 m) · 3 yakalanma → angarya kartı,
##                çıktığı yere dönüş · 4 kovalayanı atlattı (60 m ya da 45 sn) → Hikmet telsiz + Nihat, Büro iadesi.
##   watch_hits   sivile vuruş: var olan "kick" (F / sol tık), önündeki 2,3 m içindeki kişi ya da hayvan.
##                erkek sivil: 1 şaşkınlık · 2 kalabalık + karşılık (Tolga yere) · 3 muhafız koşarak gelir → tutuklanma.
##                kadın, çocuk, yaşlı, din adamı: vuruş işlemez (Tolga vazgeçer / biri araya girer / Hikmet paylar).
##                asker, komutan: ayağı yakalar → doğrudan tutuklanma. Fatih, İmparator: scripts/level/huzur.gd (karşı
##                hamle ya da muhafız, sonra sürgün).
##                hayvan: karşılık verir (keçi, at, öküz: yere; tavuk: üstüne atlar; kedi: kaçar).
## Bu davranışları yapmayan oyuncu için hiçbir şey değişmez: izleyiciler yalnız alandan çıkınca / tekmeye basınca çalışır.
## Başka bölüme tek satır: preload("res://scripts/level/kural.gd").hits(self, hud, player)
## Otomatik test: --autotest=krl_hit (3 vuruş → tutuklanma), krl_soft (kadın/çocuk: işlemez), kacak, kacak_iade (talim).

## Sözler (konuşmacı, anahtar): tools/voice_map.py ses haritasına buradan da alır
const LINES := [
	["SPK_AZAPBASI", "KRL_TALIM_O_1"], ["SPK_AZAPBASI", "KRL_TALIM_O_2"], ["SPK_AZAPBASI", "KRL_TALIM_O_AGAIN"],
	["SPK_AZAP", "KRL_TALIM_O_CATCH"], ["SPK_AZAPBASI", "KRL_TALIM_O_PUN_1"], ["SPK_TOLGA", "KRL_TALIM_T_PUN_O"],
	["SPK_AZAPBASI", "KRL_TALIM_O_PUN_2"], ["SPK_AZAPBASI", "KRL_TALIM_O_BACK"],
	["SPK_GIUST", "KRL_TALIM_B_1"], ["SPK_GIUST", "KRL_TALIM_B_2"], ["SPK_GIUST", "KRL_TALIM_B_AGAIN"],
	["SPK_DEFENDER", "KRL_TALIM_B_CATCH"], ["SPK_GIUST", "KRL_TALIM_B_PUN_1"], ["SPK_TOLGA", "KRL_TALIM_T_PUN_B"],
	["SPK_GIUST", "KRL_TALIM_B_PUN_2"], ["SPK_GIUST", "KRL_TALIM_B_BACK"],
	["SPK_HIKMET", "KRL_IADE_H"], ["SPK_NIHAT", "KRL_IADE_N"], ["SPK_TOLGA", "KRL_IADE_T"],
	["SPK_TOLGA", "KRL_T_HIT_1"], ["SPK_TOLGA", "KRL_T_HIT_2"], ["SPK_TOLGA", "KRL_T_HIT_3"],
	["SPK_TOWNSMAN", "KRL_TOWNB_HIT_1"], ["SPK_TOWNSMAN", "KRL_TOWNB_HIT_2"], ["SPK_TOWNSMAN", "KRL_TOWNB_CROWD"],
	["SPK_TOWNSMAN", "KRL_TOWNB_BACK"], ["SPK_TOWNSMAN", "KRL_TOWNB_MARK_1"], ["SPK_TOWNSMAN", "KRL_TOWNB_MARK_2"],
	["SPK_TOWNSMAN", "KRL_TOWNB_SHAME"],
	["SPK_WORKER", "KRL_WORKER_HIT_1"], ["SPK_WORKER", "KRL_WORKER_HIT_2"], ["SPK_WORKER", "KRL_WORKER_CROWD"],
	["SPK_WORKER", "KRL_WORKER_BACK"], ["SPK_WORKER", "KRL_WORKER_MARK_1"], ["SPK_WORKER", "KRL_WORKER_MARK_2"],
	["SPK_WORKER", "KRL_WORKER_SHAME"],
	["SPK_GENOESE", "KRL_GAL_HIT_1"], ["SPK_GENOESE", "KRL_GAL_HIT_2"], ["SPK_GENOESE", "KRL_GAL_CROWD"],
	["SPK_GENOESE", "KRL_GAL_BACK"], ["SPK_GENOESE", "KRL_GAL_MARK_1"], ["SPK_GENOESE", "KRL_GAL_SHAME"],
	["SPK_CITY_GUARD", "KRL_BYZSOL_ARREST"], ["SPK_JANISSARY", "KRL_JAN_ARREST"], ["SPK_GENOESE", "KRL_GENMERC_ARREST"],
	["SPK_CITY_GUARD", "KRL_BYZSOL_CATCH"], ["SPK_JANISSARY", "KRL_JAN_CATCH"], ["SPK_SOLDIER", "KRL_OSMSOL_CATCH"],
	["SPK_GENOESE", "KRL_GENMERC_CATCH"], ["SPK_AZAP", "KRL_AZAP_CATCH"],
	["SPK_CITY_GUARD", "KRL_ZINDAN_G"], ["SPK_TOLGA", "KRL_ZINDAN_T"], ["SPK_NIHAT", "KRL_ZINDAN_N"],
	["SPK_JANISSARY", "KRL_KADI_J"], ["SPK_TOLGA", "KRL_KADI_T"], ["SPK_NIHAT", "KRL_KADI_N"],
	["SPK_GENOESE", "KRL_PODESTA_G"], ["SPK_TOLGA", "KRL_PODESTA_T"], ["SPK_GENOESE", "KRL_PODESTA_G2"],
	["SPK_TOLGA", "KRL_T_NOPE_1"], ["SPK_TOLGA", "KRL_T_NOPE_2"], ["SPK_TOLGA", "KRL_T_NOPE_3"],
	["SPK_TOLGA", "KRL_T_NOPE_PRIEST"], ["SPK_HIKMET", "KRL_H_NOPE"], ["SPK_WOMAN_BYZ", "KRL_WOMB_NOPE"],
	["SPK_NIHAT", "KRL_RULER_N1"], ["SPK_NIHAT", "KRL_RULER_N2"], ["SPK_HIKMET", "KRL_RULER_H"],
	["SPK_TOLGA", "KRL_T_GOAT"], ["SPK_TOLGA", "KRL_T_CHICKEN"], ["SPK_TOLGA", "KRL_T_HORSE"], ["SPK_TOLGA", "KRL_T_CAT"],
	["SPK_TOLGA", "KRL_T_CMD"]]

const REACH := 2.3                # tekmenin yetiştiği uzaklık (ayak ~1,1 m önde; hedef 2,3 m'ye kadar atılarak)
const HIT_WINDOW := 120.0         # tırmanma penceresi: bu kadar saniye içinde yeni vuruş bir sonraki basamaktır
const MARK_COOL := 22.0           # "işte o tekmeci" sözlerinin arası
## Hükümdarlar: vuruş işlemez (Huzur: karşı hamle, sürgün)
const RULERS := ["fatih", "emperor"]
## Sivil erkekler: rolün söz öbeği (KRL_<öbek>_…; öbeğin konuşmacısı SideEvents.STREET_SPK'dan)
const CIV_GROUP := {"TOWNB": "TOWNB", "VENDB": "TOWNB", "PORTER": "TOWNB", "FISHER": "TOWNB", "CIVB": "TOWNB",
	"VEND": "TOWNB", "VENDO": "WORKER", "WORKER": "WORKER", "GAL": "GAL"}
const SOFT := ["WOMB", "CHILDB", "PRIEST", "MONK", "DERV"]
const SOLDIER_CATCH := {"BYZSOL": "KRL_BYZSOL_CATCH", "JAN": "KRL_JAN_CATCH", "OSMSOL": "KRL_OSMSOL_CATCH",
	"AZAP": "KRL_AZAP_CATCH", "GENMERC": "KRL_GENMERC_CATCH"}

var scene: Node3D
var hud: Hud
var player: Player
var busy := false                 # bir tepki sahnesi oynuyor (ikinci tetik beklemez)

# ---- alan
var area_on := false
var area_center := Vector3.ZERO
var area_r := 15.0
var giver: Node3D
var giver_spk := ""
var runner: Person
var side := "O"                   # "O" Osmanlı talimi, "B" Bizans talimi
var _out_t := 0.0
var _step := 0                    # 0 içeride, 1 laf, 2 kovalama
var _exit_at := Vector3.ZERO      # alandan çıktığı son iç nokta (cezadan sonra buraya döner)
var _runner_home := Vector3.INF
var _runner_act := ""
var _runner_rot := 0.0
var _runner_tw: Tween
var escapes := 0                  # bu bölümde kaç kez kaçtı
var caught := 0
var returned := 0                 # Büro iadesi

# ---- vuruş
var hits_on := false
var _hits: Array[float] = []      # pencere içindeki erkek sivil vuruşlarının zamanı
var _clock := 0.0
var _marked := false              # bu bölümde tutuklandı: çevredekiler söylenir
var _mark_t := 0.0
var _soft_n := 0
var arrests := 0
var ruler_tries := 0
var soft_stops := 0
var animal_hits := 0
var last := ""                    # son tepki (test ve kanıt için)
var _bot := ""                    # otomatik testin yaptığı (krl_hit, krl_soft, kacak, kacak_iade)
var _bot_t := 0.0
var _bot_done := false
var log_lines: Array[String] = []


## Sahnenin Kural düğümü (yoksa kurulur)
static func of(p_scene: Node3D, p_hud: Hud, p_player: Player) -> Node:
	var k := p_scene.get_node_or_null("Kural")
	if k == null:
		k = load("res://scripts/level/kural.gd").new()
		k.name = "Kural"
		k.scene = p_scene
		k.hud = p_hud
		k.player = p_player
		p_scene.add_child(k)
	return k


## Tek satırlık bağlantı: sokak/ordugâh bölümü vuruş izleyicisini açar
static func hits(p_scene: Node3D, p_hud: Hud, p_player: Player) -> Node:
	var k := of(p_scene, p_hud, p_player)
	k.hits_on = true
	return k


## Talim alanı: merkez (dünya), yarıçap, görev veren (söz söyler), kovalayan (balyada oturan / kenarda duran biri)
static func area(p_scene: Node3D, p_hud: Hud, p_player: Player, center: Vector3, radius: float, p_giver: Node3D,
		p_giver_spk: String, p_runner: Person, p_side: String) -> Node:
	var k := of(p_scene, p_hud, p_player)
	k.area_on = true
	k.area_center = center
	k.area_r = radius
	k.giver = p_giver
	k.giver_spk = p_giver_spk
	k.runner = p_runner
	k.side = p_side
	k.hits_on = true
	return k


func _ready() -> void:
	_bot = GameState.autotest_variant if GameState.autotest and GameState.autotest_variant in ["krl_hit", "krl_soft", "krl_soldier", "krl_animal", "kacak", "kacak_iade"] else ""


func _log(s: String) -> void:
	log_lines.append(s)
	if GameState.autotest:
		print("KURAL " + s)


func _free_to_act(allow_combat := false) -> bool:
	if player == null or not is_instance_valid(player) or not player.is_inside_tree():
		return false
	if player.frozen or (player.combat and not allow_combat) or player.is_down or player.hand_style != "tolga" or player.ladder != null:
		return false
	if player.traversal != null and player.traversal.state != "":
		return false
	if get_tree().paused or hud.line_open:
		return false
	return true


func _physics_process(delta: float) -> void:
	_clock += delta
	if busy or scene == null:
		return
	if _bot != "":
		_bot_tick(delta)
	if area_on:
		_area_tick(delta)
	if hits_on:
		_hits_tick(delta)


# ================================================================ görev alanını terk

func _flat_dist(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _area_tick(delta: float) -> void:
	if not _free_to_act(true):      # kılıç dersinin ortasında da kaçılabilir
		return
	var d := _flat_dist(player.global_position, area_center)
	if d <= area_r:
		_exit_at = player.global_position
		if _step > 0 and _runner_tw == null:
			_step = 0          # kendi döndü: laf yetti
		_out_t = 0.0
		return
	_out_t += delta
	if _step == 0 and _out_t > 2.0:
		_step = 1
		escapes += 1
		GameState.bump_stat("firar")
		GameState.flags["firar_" + ("41o" if side == "O" else "42b")] = escapes
		if escapes >= 2:
			_step = 2          # üstelemek: ilk basamak atlanır
			_say_giver("KRL_TALIM_%s_AGAIN" % side)
			_send_runner()
		else:
			_say_giver("KRL_TALIM_%s_1" % side)
		_log("area step=%d escapes=%d d=%.1f" % [_step, escapes, d])
	elif _step == 1 and (_out_t > 7.0 or d > area_r + 10.0):
		_step = 2
		_say_giver("KRL_TALIM_%s_2" % side)
		_send_runner()
		_log("area step=2 runner")
	elif _step == 2:
		if runner and is_instance_valid(runner) and _flat_dist(runner.global_position, player.global_position) < 2.2:
			_caught()
		elif d > area_r + 45.0 or _out_t > 45.0:
			_buro_return()


func _say_giver(key: String) -> void:
	if giver and is_instance_valid(giver) and giver is Person:
		(giver as Person).look_target = player
		(giver as Person).emote("point" if not key.ends_with("_1") else "surprise")
	hud.bark(giver_spk, key, 3.6, true)


## Kovalayan kalkar, oyuncunun peşinden koşar (yarım saniyede bir hedefi tazeler: kaçan oyuncuyu izler)
func _send_runner() -> void:
	if runner == null or not is_instance_valid(runner):
		return
	if _runner_home == Vector3.INF:
		_runner_home = runner.global_position
		_runner_act = runner.activity
		_runner_rot = runner.global_rotation.y
	# Söz onun ağzından çıksın (portre ve ses yeri): yakalayınca konuşan bu kişi
	runner.set_meta("spk", "SPK_AZAP" if side == "O" else "SPK_DEFENDER")
	# Oturduğu balyadan kalkar: önüne, yere iner (tween balyanın içinden geçiriyordu: WALKTHRU/insolid). Koşarken
	# bakışı yolundadır (look_target yürüyüşü sırtı dönük gösteriyordu: LOOKAUDIT walk); oyuncuya yakalayınca döner
	var fwd := area_center - runner.global_position      # balyada meydana dönük oturur: kalkınca meydan yanına iner
	fwd.y = 0.0
	var up := runner.global_position + fwd.normalized() * 1.15
	up.y = _ground(up, runner.global_position.y)
	runner.look_target = null
	runner.global_position = up
	runner.set_activity("")
	_chase_loop()


func _chase_loop() -> void:
	while _step == 2 and not busy and runner and is_instance_valid(runner) and is_inside_tree():
		var to := player.global_position
		var from := runner.global_position
		var flat := Vector3(to.x - from.x, 0.0, to.z - from.z)
		var dist := flat.length()
		if dist < 2.0:
			break
		var stepv := flat.normalized() * minf(dist - 1.6, 2.6)
		var nxt := from + stepv
		nxt.y = _ground(nxt, from.y)
		runner.face_toward(nxt)
		_runner_tw = runner.create_tween()
		_runner_tw.tween_property(runner, "global_position", nxt, 0.5)       # ~5 m/sn: koşar adım
		await _runner_tw.finished
	_runner_tw = null


func _ground(p: Vector3, fallback: float) -> float:
	var space := scene.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(Vector3(p.x, fallback + 2.0, p.z), Vector3(p.x, fallback - 6.0, p.z), 1)
	var hit := space.intersect_ray(q)
	return float((hit["position"] as Vector3).y) if not hit.is_empty() else fallback


func _caught() -> void:
	busy = true
	caught += 1
	_step = 0
	player.frozen = true
	player.face(runner.global_position + Vector3(0, 1.5, 0))
	runner.face_toward(player.global_position)
	runner.look_target = player
	runner.emote("point")
	last = "caught"
	_log("area caught n=%d" % caught)
	await hud.say("SPK_AZAP" if side == "O" else "SPK_DEFENDER", "KRL_TALIM_%s_CATCH" % side)
	await hud.fade_to(1.0, 0.5)
	await hud.card([[tr("UI_KRL_CARD_PUN"), 40, Color("f2e6c9")],
		[tr("UI_KRL_CARD_KAZAN" if side == "O" else "UI_KRL_CARD_TAS"), 22, Color(1, 1, 1, 0.8)]], 2.4)
	await hud.say(giver_spk, "KRL_TALIM_%s_PUN_1" % side)
	await hud.say("SPK_TOLGA", "KRL_TALIM_T_PUN_%s" % side)
	await hud.say(giver_spk, "KRL_TALIM_%s_PUN_2" % side)
	hud.clear_card()
	_home_back()
	await hud.fade_to(0.0, 0.6)
	player.frozen = false
	busy = false


## Kovalayanı atlattı: Hikmet telsizden, Nihat Büro'dan; Büro iadesi, meydana dönüş, görev veren bekliyor
func _buro_return() -> void:
	busy = true
	returned += 1
	_step = 0
	player.frozen = true
	last = "iade"
	_log("area buro_return n=%d" % returned)
	GameState.bump_stat("buro_iade")
	player.radio_listen(4.0)
	await hud.say("SPK_HIKMET", "KRL_IADE_H")
	await hud.say("SPK_NIHAT", "KRL_IADE_N")
	await hud.say("SPK_TOLGA", "KRL_IADE_T")
	await hud.fade_to(1.0, 0.4, Color(0.92, 0.92, 0.86))
	await hud.card([[tr("UI_KRL_CARD_IADE"), 40, Color("2a2a2a")], [tr("UI_KRL_CARD_IADE_SUB"), 22, Color(0.1, 0.1, 0.1, 0.8)]], 2.4)
	hud.clear_card()
	_home_back()
	await hud.fade_to(0.0, 0.6, Color(0.92, 0.92, 0.86))
	if giver and is_instance_valid(giver):
		player.face(giver.global_position + Vector3(0, 1.5, 0))
	await hud.say(giver_spk, "KRL_TALIM_%s_BACK" % side)
	player.frozen = false
	busy = false


## Ekran kararmışken: oyuncu çıktığı yere, kovalayan yerine döner
func _home_back() -> void:
	if _runner_tw and _runner_tw.is_valid():
		_runner_tw.kill()
	_runner_tw = null
	if runner and is_instance_valid(runner) and _runner_home != Vector3.INF:
		runner.global_position = _runner_home
		runner.global_rotation.y = _runner_rot
		runner.set_activity(_runner_act)        # balyasına oturur (ayakta kalırsa balyanın içinde duruyordu)
		runner.look_target = null
		runner.remove_meta("spk")
	var back := _exit_at
	if _flat_dist(back, area_center) > area_r or back == Vector3.ZERO:
		back = area_center + (back - area_center).normalized() * (area_r - 2.0)
		back.y = _ground(back, area_center.y + 0.5)
	player.global_position = back + Vector3(0, 0.05, 0)
	player.velocity = Vector3.ZERO
	player.face(area_center + Vector3(0, 1.5, 0))
	_out_t = 0.0


# ================================================================ vuruş

func _hits_tick(delta: float) -> void:
	if _marked:
		_mark_tick(delta)
	if not _free_to_act():
		return
	var pressed := Input.is_action_just_pressed("kick") or _bot_kick
	_bot_kick = false
	if not pressed:
		return
	if player.focus_id.begins_with("mg:") or player.focus_id.begins_with("ev:"):
		return            # bölümün kendi işi (mini oyun, olay)
	var t := _target()
	if t.is_empty():
		return
	_on_kick(t)


var _bot_kick := false


## Önündeki kişi ya da hayvan: {"node", "kind": person/soldier/animal, "role"}
func _target() -> Dictionary:
	var fwd := -player.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var me := player.global_position
	var best: Node3D = null
	var bd := REACH
	var kind := ""
	for g in ["persons", "soldiers"]:
		for n in get_tree().get_nodes_in_group(g):
			var c := n as Node3D
			if c == null or not c.is_visible_in_tree() or c.get_meta("hologram", false):
				continue
			var to := c.global_position - me
			to.y = 0.0
			var d := to.length()
			if d > bd or d < 0.05 or to.normalized().dot(fwd) < 0.55 or absf(c.global_position.y - me.y) > 1.6:
				continue
			bd = d
			best = c
			kind = "soldier" if c is Soldier else "person"
	# Hayvanlar (yalnız basışta taranır: her kare maliyet yok)
	for n in scene.find_children("*", "Node3D", true, false):
		if not (n is Goat or n is Chicken or n is Horse or n is Ox or n is Cat):
			continue
		var c := n as Node3D
		if not c.is_visible_in_tree():
			continue
		var to := c.global_position - me
		to.y = 0.0
		var d := to.length()
		if d > bd or d < 0.05 or to.normalized().dot(fwd) < 0.55:
			continue
		bd = d
		best = c
		kind = "animal"
	if best == null:
		return {}
	var ctx := SideEvents.street_ctx(get_tree())
	var role := ""
	if kind != "animal":
		role = SideEvents.street_role(best, ctx)
		# Duelist'in gövdesi (talim arkadaşı) ve hikâye karakterleri: rol yok
	return {"node": best, "kind": kind, "role": role, "ctx": ctx}


func _on_kick(t: Dictionary) -> void:
	var n: Node3D = t["node"]
	var role: String = t["role"]
	var kind: String = t["kind"]
	if kind == "animal":
		_animal(n)
		return
	var p := n as Person
	if p and p.face_id in RULERS and not p.child:
		_ruler(p)
		return
	if n.get_parent() is Duelist:
		_soldier(n, "AZAP" if side == "O" else "BYZSOL")     # talim arkadaşı (Hızır, Leon): asker sayılır
		return
	if p and (p.face_id != "" or n.has_meta("spk")) and role == "":
		_commander(n)
		return
	if role in SOLDIER_CATCH or kind == "soldier":
		_soldier(n, role)
		return
	if role in SOFT or (p and (p.child or p.skirt or bool(p.face_spec.get("wrinkles", false)))):
		_soft(n, role)
		return
	if role == "":
		role = "TOWNB" if str(t["ctx"].get("place", "BYZ")) != "CAMP" else "WORKER"
	_civilian(n, role, t["ctx"])


func _grp(role: String, ctx: Dictionary) -> String:
	if CIV_GROUP.has(role):
		return CIV_GROUP[role]
	if str(ctx.get("place", "")) == "GAL":
		return "GAL"
	return "WORKER" if str(ctx.get("place", "")) == "CAMP" else "TOWNB"


## Bacak kalkar, iner; vuruş işlemez (kadın, çocuk, yaşlı, din adamı, hükümdar)
func _leg_abort() -> void:
	if player.leg == null:
		return
	player.leg.visible = true
	player.leg.position = Vector3(0.12, -0.3, 0.15)
	player.leg.rotation_degrees = Vector3(5, 0, 0)
	var tw := player.create_tween()
	tw.tween_property(player.leg, "rotation_degrees:x", -15.0, 0.14).set_ease(Tween.EASE_OUT)
	tw.tween_property(player.leg, "rotation_degrees:x", 38.0, 0.22).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.35)
	tw.tween_property(player.leg, "rotation_degrees:x", 5.0, 0.4).set_trans(Tween.TRANS_QUAD)
	await tw.finished
	player.leg.visible = false


func _kick_land(n: Node3D) -> void:
	var at := n.global_position + Vector3(0, 0.9, 0)
	await player.kick(at, 0.45, func():
		Audio.sfx("land_thud", -6.0, 1.3)
		if n is Person and is_instance_valid(n):
			var tw := n.create_tween()
			var dir := n.global_position - player.global_position
			dir.y = 0.0
			dir = dir.normalized() * 0.35
			tw.tween_property(n, "global_position", n.global_position + dir, 0.18).set_ease(Tween.EASE_OUT))


func _civilian(n: Node3D, role: String, ctx: Dictionary) -> void:
	busy = true
	var g := _grp(role, ctx)
	while not _hits.is_empty() and _clock - _hits[0] > HIT_WINDOW:
		_hits.pop_front()
	_hits.append(_clock)
	var step := _hits.size()
	GameState.bump_stat("tekme_sivil")
	_log("hit civilian role=%s grp=%s step=%d" % [role, g, step])
	await _kick_land(n)
	var p := n as Person
	if p and p.activity != "":
		if not p.has_meta("street_role"):
			p.set_meta("street_role", role)      # rolü işinden çıkıyordu (ordugâhta işçi): iş bırakınca asker sanılmasın
		p.set_meta("krl_act", p.activity)
		p.set_meta("krl_rot", p.global_rotation.y)
		p.set_activity("")          # vurulan elindeki işi bırakır
	if p:
		p.face_toward(player.global_position)
		p.look_target = player
	if step == 1:
		last = "hit1"
		if p:
			p.emote("surprise")
		hud.street_bark(n, role, "KRL_%s_HIT_%d" % [g, 1 + randi() % 2], 3.4, true)
		await get_tree().create_timer(3.6 if not Stage.fast() else 0.2, false).timeout
		hud.bark("SPK_TOLGA", "KRL_T_HIT_%d" % (1 + (int(GameState.stats.get("tekme_sivil", 1)) - 1) % 3), 3.0)
		_release_later(n, 6.0)
		busy = false
		return
	if step == 2:
		last = "hit2"
		_crowd(n, g)
		hud.street_bark(n, role, "KRL_%s_BACK" % g, 2.6, true)
		if p and not p.is_busy():
			p.face_toward(player.global_position)
			p.kick_hit.connect(_kicked_back, CONNECT_ONE_SHOT)
			await p.kick()
		player.down()
		await get_tree().create_timer(2.6 if not Stage.fast() else 0.4, false).timeout
		_release_later(n, 4.0)
		busy = false
		return
	last = "hit3"
	_crowd(n, g)
	await _arrest(ctx, "")
	_hits.clear()
	if is_instance_valid(n) and n.get("look_target") == player:
		n.set("look_target", null)
	_back_to_work(n)


## Oyuncuya bakış: baş omuz üstünden döner, gövde dönmez (Rig.stare_t; sokak gözünün yolu). Yürüyen ya da iş başındaki
## kişiye look_target vermek gövdeyi işinden/yolundan çeviriyordu (LOOKAUDIT). Döner: işi yok mu (jest yapabilir mi)
func _look(c: Node3D, secs := 4.0) -> bool:
	if c == null or not is_instance_valid(c):
		return false
	var rg = c.get("rig")
	if rg is Rig:
		(rg as Rig).stare_t = maxf((rg as Rig).stare_t, secs)
	if c is Soldier:
		return (c as Soldier).pose == "stand"
	return str(c.get("activity") if "activity" in c else "") == "" and not (c is Person and (c as Person).is_busy())


## Bir süre sonra bakışı bırakır (sokaktaki kişi yoluna/işine döner; CityLife bakan kişiyi bekletir)
func _release_later(n: Node3D, secs: float) -> void:
	await get_tree().create_timer(secs, false).timeout
	if is_instance_valid(n) and n.get("look_target") == player:
		n.set("look_target", null)
	_back_to_work(n)


## Vurulan, bakışı bırakınca elindeki işe döner (ressam boyamaya)
func _back_to_work(n: Node3D) -> void:
	if n is Person and is_instance_valid(n) and n.has_meta("krl_act"):
		n.global_rotation.y = float(n.get_meta("krl_rot", n.global_rotation.y))     # işine dönük
		(n as Person).set_activity(str(n.get_meta("krl_act")))
		n.remove_meta("krl_act")
		n.remove_meta("krl_rot")


func _kicked_back() -> void:
	player.shake(0.8)
	Audio.sfx("land_thud", -2.0, 0.9)


## Çevredekiler: şaşırır, biri bağırır (vurulan değil)
func _crowd(victim: Node3D, g: String) -> void:
	var shout: Node3D = null
	for q in get_tree().get_nodes_in_group("persons"):
		var c := q as Person
		if c == null or c == victim or not c.is_visible_in_tree() or c.face_id != "" or c.has_meta("spk"):
			continue
		if c.global_position.distance_to(player.global_position) > 12.0:
			continue
		if not _look(c):
			continue
		c.emote("surprise")
		if shout == null and not c.child:
			shout = c
	if shout:
		var role := SideEvents.street_role(shout, SideEvents.street_ctx(get_tree()))
		hud.street_bark(shout, role if role != "" else "TOWNB", "KRL_%s_CROWD" % g, 2.6, true)


## Muhafız görüş dışından (oyuncunun arkasından) koşarak gelir; tutuklanma kartı ve üç söz; aynı yere dönüş
func _arrest(ctx: Dictionary, catch_key: String) -> void:
	busy = true
	arrests += 1
	GameState.bump_stat("tutuklama")
	var place := str(ctx.get("place", "BYZ"))
	var era := str(ctx.get("era", "siege"))
	var who := "B"
	if place == "CAMP" or era == "conq":
		who = "O"
	elif place == "GAL":
		who = "G"
	var role: String = {"B": "BYZSOL", "O": "JAN", "G": "GENMERC"}[who]
	_log("arrest who=%s n=%d" % [who, arrests])
	var guard: Node3D = null
	if catch_key == "":
		guard = await _guard_run(who, role)
		if guard:
			hud.street_bark(guard, role, "KRL_%s_ARREST" % role, 2.8, true)
			await get_tree().create_timer(2.6 if not Stage.fast() else 0.2, false).timeout
	player.frozen = true
	last = "arrest"
	await hud.fade_to(1.0, 0.6)
	var card: String = {"B": "UI_KRL_CARD_ZINDAN", "O": "UI_KRL_CARD_KADI", "G": "UI_KRL_CARD_PODESTA"}[who]
	await hud.card([[tr(card), 40, Color("f2e6c9")], [tr(card + "_SUB"), 22, Color(1, 1, 1, 0.8)]], 2.4)
	match who:
		"B":
			await hud.say("SPK_CITY_GUARD", "KRL_ZINDAN_G")
			await hud.say("SPK_TOLGA", "KRL_ZINDAN_T")
			await hud.say("SPK_NIHAT", "KRL_ZINDAN_N")
		"O":
			await hud.say("SPK_JANISSARY", "KRL_KADI_J")
			await hud.say("SPK_TOLGA", "KRL_KADI_T")
			await hud.say("SPK_NIHAT", "KRL_KADI_N")
		_:
			await hud.say("SPK_GENOESE", "KRL_PODESTA_G")
			await hud.say("SPK_TOLGA", "KRL_PODESTA_T")
			await hud.say("SPK_GENOESE", "KRL_PODESTA_G2")
	hud.clear_card()
	if guard and is_instance_valid(guard) and guard.get_meta("krl_spawned", false):
		guard.queue_free()
	_marked = true
	_mark_t = 8.0
	await hud.fade_to(0.0, 0.7)
	player.frozen = false
	busy = false


func _guard_look(who: String) -> Dictionary:
	match who:
		"O":
			return {"coat": Color("1f3f7a"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true}
		"G":
			return {"coat": Color("8a8e96"), "pants": Color("2a2a30"), "hat": "helm", "armor": "mail", "beard": true}
	return {"coat": Color("7a2a24"), "pants": Color("3a2a22"), "hat": "helm", "mustache": true}


## Görüş dışından koşan muhafız: oyuncunun arkasında, aradaki yol açık ve aynı zeminde bir nokta
func _guard_run(who: String, role: String) -> Node3D:
	var me := player.global_position
	var back := player.global_transform.basis.z
	back.y = 0.0
	back = back.normalized()
	var space := scene.get_world_3d().direct_space_state
	var spot := Vector3.INF
	for dist: float in [16.0, 12.0, 9.0]:
		for ang: float in [0.0, 0.5, -0.5, 0.9, -0.9]:
			var dir := back.rotated(Vector3.UP, ang)
			var c := me + dir * dist
			var eye := me + Vector3(0, 1.0, 0)
			var los := space.intersect_ray(PhysicsRayQueryParameters3D.create(eye, Vector3(c.x, eye.y, c.z), 1, [player.get_rid()]))
			if not los.is_empty():
				continue
			var y := _ground(c, me.y)
			if absf(y - me.y) > 1.2:
				continue
			spot = Vector3(c.x, y, c.z)
			break
		if spot != Vector3.INF:
			break
	if spot == Vector3.INF:
		return null
	var g := Person.new(_guard_look(who))
	g.set_meta("street_role", role)
	g.set_meta("speaker", SideEvents.STREET_SPK.get(role, "SPK_CITY_GUARD"))
	g.set_meta("krl_spawned", true)
	scene.add_child(g)
	g.global_position = spot
	g.face_toward(me)
	await Stage.approach(g, player.global_position, 1.6, 4.6, Vector3.ZERO, func(x: float, z: float) -> float:
		return _ground(Vector3(x, 0, z), me.y))
	if is_instance_valid(g):
		g.look_target = player
		player.face(g.global_position + Vector3(0, 1.5, 0))
	return g


func _soft(n: Node3D, role: String) -> void:
	busy = true
	soft_stops += 1
	_soft_n += 1
	GameState.bump_stat("utanc")
	last = "soft"
	_log("soft role=%s n=%d" % [role, _soft_n])
	await _leg_abort()
	if _look(n):
		(n as Person).emote("surprise")
	var g := _grp("", SideEvents.street_ctx(get_tree()))
	match (_soft_n - 1) % 4:
		0:
			hud.bark("SPK_TOLGA", "KRL_T_NOPE_PRIEST" if role in ["PRIEST", "MONK", "DERV"] else "KRL_T_NOPE_1", 3.4)
		1:
			var by := _bystander(n)
			if by:
				hud.street_bark(by, SideEvents.street_role(by, SideEvents.street_ctx(get_tree())), "KRL_%s_SHAME" % g, 3.4, true)
			elif role == "WOMB":
				hud.street_bark(n, role, "KRL_WOMB_NOPE", 3.0, true)
			else:
				hud.bark("SPK_TOLGA", "KRL_T_NOPE_2", 3.0)
		2:
			player.radio_listen(3.6)
			hud.bark("SPK_HIKMET", "KRL_H_NOPE", 3.6)
		_:
			hud.bark("SPK_TOLGA", "KRL_T_NOPE_3", 3.0)
	await get_tree().create_timer(1.2 if not Stage.fast() else 0.2, false).timeout
	busy = false


func _bystander(not_this: Node3D) -> Node3D:
	var best: Node3D = null
	var bd := 10.0
	for q in get_tree().get_nodes_in_group("persons"):
		var c := q as Person
		if c == null or c == not_this or c.child or c.skirt or c.face_id != "" or c.has_meta("spk") or not c.is_visible_in_tree():
			continue
		var d := c.global_position.distance_to(player.global_position)
		if d < bd:
			bd = d
			best = c
	return best


func _soldier(n: Node3D, role: String) -> void:
	busy = true
	last = "soldier"
	GameState.bump_stat("tekme_asker")
	_log("soldier role=%s" % role)
	await _leg_abort()
	var key: String = SOLDIER_CATCH.get(role, "KRL_OSMSOL_CATCH")
	if n.has_method("face_toward") and str(n.get("activity") if "activity" in n else "") == "" \
			and not (n is Soldier and (n as Soldier).pose != "stand"):
		n.call("face_toward", player.global_position)
	_look(n)
	hud.street_bark(n, role if role != "" else "OSMSOL", key, 3.0, true)
	await get_tree().create_timer(2.8 if not Stage.fast() else 0.2, false).timeout
	player.down()
	await get_tree().create_timer(2.0 if not Stage.fast() else 0.3, false).timeout
	var ctx := SideEvents.street_ctx(get_tree())
	await _arrest(ctx, key)


## Hikâye karakteri (komutan, usta): kendisi karışmaz; Tolga son anda "şaka"ya vurur, en yakın asker tutuklar
func _commander(n: Node3D) -> void:
	busy = true
	last = "commander"
	_log("commander")
	await _leg_abort()
	_look(n)
	hud.bark("SPK_TOLGA", "KRL_T_CMD", 3.0)
	await get_tree().create_timer(3.0 if not Stage.fast() else 0.2, false).timeout
	await _arrest(SideEvents.street_ctx(get_tree()), "")


## Hükümdar (docs/SENARYO_KURAL_CIGNEME.md §6): vuramaz; karşı hamle / muhafız, sonra sürgün (scripts/level/huzur.gd).
## Eski davranış (Büro acil iadesi, bölüm baştan) kaldırıldı (sahibin kararı, 2. tur).
func _ruler(p: Person) -> void:
	ruler_tries += 1
	last = "ruler"
	_log("ruler face=%s -> huzur" % p.face_id)
	load("res://scripts/level/huzur.gd").of(scene, hud, player).attempt(p, "kick")


func _animal(n: Node3D) -> void:
	busy = true
	last = "animal"
	animal_hits += 1
	GameState.bump_stat("tekme_hayvan")
	_log("animal %s" % n.get_class())
	await _kick_land(n)
	if n is Goat or n is Horse or n is Ox:
		var tw := n.create_tween()
		var to := player.global_position - n.global_position
		to.y = 0.0
		var p0 := n.global_position
		tw.tween_property(n, "global_position", p0 + to.normalized() * 0.4, 0.15)
		tw.tween_property(n, "global_position", p0, 0.3)
		Audio.sfx("land_thud", -2.0, 0.7)
		player.down()
		await get_tree().create_timer(2.4 if not Stage.fast() else 0.3, false).timeout
		hud.bark("SPK_TOLGA", "KRL_T_GOAT" if n is Goat else "KRL_T_HORSE", 3.2)
	elif n is Chicken:
		player.flail(0.9)
		player.shake(0.5)
		Audio.sfx("cloth", -6.0, 1.4)
		hud.bark("SPK_TOLGA", "KRL_T_CHICKEN", 2.6, true)
	else:
		hud.bark("SPK_TOLGA", "KRL_T_CAT", 3.0)
	await get_tree().create_timer(1.0 if not Stage.fast() else 0.2, false).timeout
	busy = false


## Tutuklandıktan sonra o bölümde: yakından geçenler arada bir söylenir, şaşırıp bakar (kalıcı iz)
func _mark_tick(delta: float) -> void:
	_mark_t -= delta
	if _mark_t > 0.0 or hud.line_open or hud.is_talking() or not _free_to_act():
		return
	_mark_t = 2.0
	var ctx := SideEvents.street_ctx(get_tree())
	for q in get_tree().get_nodes_in_group("persons"):
		var c := q as Person
		if c == null or not c.is_visible_in_tree() or c.face_id != "" or c.has_meta("spk") or c.child:
			continue
		if c.global_position.distance_to(player.global_position) > 5.0:
			continue
		var role := SideEvents.street_role(c, ctx)
		if role == "" or role in SOFT or role in SOLDIER_CATCH:
			continue
		var g := _grp(role, ctx)
		var key := "KRL_%s_MARK_%d" % [g, 1 + randi() % 2] if g != "GAL" else "KRL_GAL_MARK_1"
		if not _look(c):
			continue
		c.emote("surprise")
		hud.street_bark(c, role, key, 3.0)
		_mark_t = MARK_COOL
		_log("mark %s" % key)
		return


# ================================================================ otomatik test (yalnız krl_*/kacak* varyantları)

var _bot_home := Vector3.INF
var _bot_open := false
var _bot_dir := Vector3.ZERO


## Kaçış yönü: alanın dışında, meydanı engelsiz gören (çadır dibine düşen kare hiçbir şey göstermiyordu)
func _clear_dir() -> Vector3:
	var space := scene.get_world_3d().direct_space_state
	var base := player.global_position - area_center
	base.y = 0.0
	base = base.normalized() if base.length() > 0.5 else Vector3(0, 0, 1)
	for k in 16:
		var dir := base.rotated(Vector3.UP, TAU * k / 16.0)
		var p := area_center + dir * (area_r + 5.0)
		p.y = _ground(p, area_center.y + 1.0) + 1.6
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(p, area_center + Vector3(0, 1.6, 0) + dir * (area_r - 4.0), 1,
			[player.get_rid()]))
		if hit.is_empty():
			_log("bot dir=%s spot=%s" % [dir, p])
			return dir
	return base


## Otomatik testin penceresi: bölüm, testin güvenli bir anında (oyuncu serbest, bölümün kendi botu beklerken) çağırır.
## Varsayılan ve öbür varyantlarda hemen döner: test botunun yolu değişmez.
func bot_window() -> void:
	if _bot == "" or _bot_done or player == null:
		return
	var was := player.frozen
	player.frozen = false
	_bot_open = true
	_bot_t = 0.0
	var t := 0.0
	while (not _bot_done or busy) and t < 150.0:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	_bot_open = false
	_bot_done = true
	if _bot_home != Vector3.INF:
		player.global_position = _bot_home          # bölümün kendi botu kaldığı yerden sürsün
	_log("bot done " + test_line())
	player.frozen = was


func _bot_tick(delta: float) -> void:
	if not _bot_open or _bot_done or not _free_to_act(area_on):
		return
	_bot_t += delta
	match _bot:
		"krl_hit", "krl_soft", "krl_soldier":
			if _bot_t < 0.6:
				return
			var want_soft := _bot == "krl_soft"
			if (not want_soft and arrests >= 1) or (want_soft and soft_stops >= 2):
				_bot_done = true
				return
			var c := _bot_victim(_bot)
			if c == null:
				if _bot_t > 20.0:
					_bot_done = true
					_log("bot no-victim")
				return
			if _bot_home == Vector3.INF:
				_bot_home = player.global_position
			var off := player.global_position - c.global_position
			off.y = 0.0
			if off.length() < 0.2:
				off = Vector3(0, 0, 1)
			player.global_position = c.global_position + off.normalized() * 1.7 + Vector3(0, 0.05, 0)
			player.face(c.global_position + Vector3(0, 1.0, 0))
			_bot_kick = true
			_bot_t = 0.0
		"krl_animal":
			if animal_hits >= 1:
				_bot_done = true
				return
			if _bot_t < 0.6:
				return
			var a: Node3D = null
			var ad := 80.0
			for n in scene.find_children("*", "Node3D", true, false):
				if (n is Goat or n is Chicken or n is Horse or n is Ox or n is Cat) and (n as Node3D).is_visible_in_tree():
					var d := (n as Node3D).global_position.distance_to(player.global_position)
					if d < ad:
						ad = d
						a = n
			if a == null:
				_bot_done = true
				_log("bot no-animal")
				return
			if _bot_home == Vector3.INF:
				_bot_home = player.global_position
			var off2 := player.global_position - a.global_position
			off2.y = 0.0
			if off2.length() < 0.2:
				off2 = Vector3(0, 0, 1)
			player.global_position = a.global_position + off2.normalized() * 1.5 + Vector3(0, 0.05, 0)
			player.global_position.y = _ground(player.global_position, a.global_position.y + 0.5) + 0.05
			player.face(a.global_position + Vector3(0, 0.4, 0))
			_bot_kick = true
			_bot_t = 0.0
		"kacak", "kacak_iade":
			if (_bot == "kacak" and caught >= 1) or (_bot == "kacak_iade" and returned >= 1):
				_bot_done = true
				return
			if _bot_home == Vector3.INF:
				_bot_home = player.global_position
			# Alanın dışına (iade: kovalayanı atlatacak kadar uzağa)
			if _bot_dir == Vector3.ZERO:
				_bot_dir = _clear_dir()
			var away := _bot_dir
			var far := area_r + (5.0 if _step < 2 else (47.0 if _bot == "kacak_iade" else 3.0))
			if _flat_dist(player.global_position, area_center) < far - 0.5:
				var p := area_center + away * far
				p.y = _ground(p, player.global_position.y)
				player.global_position = p + Vector3(0, 0.05, 0)
				player.face(area_center + Vector3(0, 1.5, 0))     # kaçan geriye, meydana bakar (seslenen ve koşan görünsün)


func _bot_victim(mode: String) -> Person:
	var ctx := SideEvents.street_ctx(get_tree())
	var best: Person = null
	var bd := 40.0
	for q in get_tree().get_nodes_in_group("persons"):
		var c := q as Person
		if c == null or not c.is_visible_in_tree() or c.face_id != "" or c.has_meta("spk") or c.get_parent() is Duelist:
			continue
		var role := SideEvents.street_role(c, ctx)
		var is_soft := role in SOFT or c.child or c.skirt or bool(c.face_spec.get("wrinkles", false))
		var ok := false
		match mode:
			"krl_soft": ok = is_soft and role != ""
			"krl_soldier": ok = role in SOLDIER_CATCH
			_: ok = role != "" and not is_soft and not role in SOLDIER_CATCH
		if not ok:
			continue
		var d := c.global_position.distance_to(player.global_position)
		if d < bd:
			bd = d
			best = c
	return best


## Bölümün otomatik test raporu için: varyantın beklediği oldu mu
func test_ok() -> bool:
	match _bot:
		"krl_hit", "krl_soldier": return arrests >= 1
		"krl_animal": return animal_hits >= 1
		"krl_soft": return soft_stops >= 2 and arrests == 0
		"kacak": return caught >= 1
		"kacak_iade": return returned >= 1
	return true


func test_line() -> String:
	return "kural=%s caught=%d iade=%d arrests=%d soft=%d animal=%d last=%s" % [_bot, caught, returned, arrests, soft_stops,
		animal_hits, last]
