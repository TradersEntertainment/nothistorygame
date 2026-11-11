extends Node
## Sokak gözü: oyuncu tuhaf bir şey yapınca (zıplama, insanlara koşup çarpma, telefon, selfie çubuğu, kolonya, çakmak,
## leblebi, küp, kendi etrafında dönme, birine dik dik bakma, elde kılıçla dolaşma, fesi takıp çıkarma, eğilerek yürüme)
## çevredeki kişiler kademeli tepki verir: baş çevirir → gövdeyle döner → işini bırakır (CityLife) → jest yapar (gösterir,
## güler, şaşırır; çocuk sevinir) → kısa bir söz söyler (DST_ODD_*, fısıltı, çocuk taklidi). Sahnenin "ilgisi" birikirse
## yakındaki bir nöbetçi döner, gösterir ve uyarır (DST_WARN_*); Tolga da laf eder (DST_T_ODD_*).
## Kişi başına dikkat (0..1,3; söner), sahne başına ilgi (söner); söz için sahnede 7 sn, kişi başına 40 sn bekleme.
## Ayrıca sokaktakilerle konuşmayı açar: CityLife'ın yakındaki (4 m) gövdelerine ve yakındaki askerlere (Soldier)
## "npc:crowd" etkileşim alanı (konuşma SideEvents.street_talk).
## Bölüm sonuçlarına, dengeye, sayaçlara, görevlere dokunmaz. Gizlilik kuralı olan bölümlerde (4, 25, 16, 5, 8, 21o ve
## Trespass kuranlar) yalnız baş çevrilir (Rig.stare_t: gövde yönü değişmez, söz yok, yeni konuşma yok). Ara sahne,
## konuşma (oyuncu donuk), dövüş, merdiven, yerde olma, tavuk, Nihat görünmez/uçarken kapalı.
## Hud kurar (hud.gd STREET_EYE). Otomatik testte kapalı; tests/street_check açar (test_on) ya da STREET_EYE_TEST ortam
## değişkeni (bölüm koşusunda zorla açar ve birkaç saniyede bir yapay tuhaflık üretir: gizlilik bölümleri denetimi).
## Bütçe: 10 Hz düşünme, kare başına en çok 3 görüş ışını; ölçüm prof_sum_us / prof_n.

const STEALTH := ["4", "16", "25", "5", "8", "21o", "20o", "22o", "28o", "32o", "37o"]
const SCAN_R := 25.0
const TALK_R := 4.0
## Basamak eşikleri: baş, gövde, iş bırakma, jest, söz
const LEVELS := [0.2, 0.45, 0.7, 0.85, 1.0]
## tür -> [güç, yarıçap]
const KINDS := {"jump": [0.3, 12.0], "bump": [0.6, 6.0], "phone": [0.7, 14.0], "selfie": [0.75, 12.0],
	"stare": [0.9, 0.0], "spin": [0.75, 12.0], "sword": [0.5, 10.0], "fez": [0.5, 8.0], "cologne": [0.65, 7.0],
	"lighter": [0.6, 10.0], "chick": [0.6, 8.0], "cube": [0.5, 7.0], "crouch": [0.45, 8.0], "item": [0.3, 6.0]}
const ITEM_KIND := {"phone": "phone", "selfie": "selfie", "cologne": "cologne", "lighter": "lighter", "chickpeas": "chick",
	"cube": "cube"}
const DECAY := 0.12          # dikkat sönümü (/sn)
const STEP_GAP := 0.3        # iki basamak arası
const BARK_GAP := 7.0
const PERSON_BARK_GAP := 40.0
const GESTURE_GAP := 6.0
const WARN_AT := 2.2
const WARN_GAP := 30.0
const TOLGA_AT := 1.6
const RAYS_PER_FRAME := 3
const GUARDS := ["BYZSOL", "JAN", "GENMERC", "OSMSOL", "AZAP"]
## Konuşmacı öbekleri: bir tepki repliğini kişiye uygun konuşmacıdan seçmek için
const SPK_GROUP := {"SPK_TOWNSMAN": "BM", "SPK_PORTER": "BM", "SPK_PRIEST": "BM", "SPK_STREET_MONK": "BM",
	"SPK_FISHMONGER": "BM", "SPK_GENOESE": "BM", "SPK_WOMAN_BYZ": "BF", "SPK_CHILD_BYZ": "BC", "SPK_CITY_GUARD": "BG",
	"SPK_SOLDIER": "O", "SPK_AZAP": "O", "SPK_WORKER": "O", "SPK_JANISSARY": "O", "SPK_SUTLER": "O", "SPK_DERVISH": "O"}

var hud: Node
var enabled := true
var test_on := false                 # tests/street_check: otomatik testte de çalışır (söz Hud'a gitmez, said'e yazılır)
var force_mode := ""                 # test: kapı denetimlerini atlayıp bu kipe geçer ("full" | "glance")
var plain := false                   # test: fısıltı ve çocuk taklidi yok (söz hep tuhaflığın kendi repliği)
var barkers: Array = []              # söyleyenlerin kimlikleri (said ile aynı sırada; Tolga: 0)
var said_roles: Array = []           # söyleyenlerin rolü (said ile aynı sırada; Tolga: "")
var mode := ""                       # "" kapalı · "glance" yalnız baş · "full"
var interest := 0.0
var said: Array[String] = []         # söylenen (ya da testte söylenecek) sözler
var steps: Array = []                # [kişinin kimliği, basamak (1..5)] — test okur
var counts := {"events": 0, "stares": 0, "turns": 0, "stops": 0, "gestures": 0, "barks": 0, "warns": 0, "talks": 0}
var prof_sum_us := 0.0
var prof_n := 0

var _player: Player
var _scene: Node
var _chapter := ""
var _ctx := {}
var _env_test := false
var _env_t := 3.0
var _near: Array = []
var _st := {}                        # kimlik -> durum
var _pending: Array = []             # [kişi, katkı, tür, sessiz]
var _cl: Node                        # CityLife
var _cl_t := 0.0
var _agents := {}                    # gövde kimliği -> CityLife ajanı
var _talk_bodies := {}               # gövde kimliği -> [gövde, etkileşim alanı]
var _soldiers_on := {}               # kimlik -> Soldier
var _soldiers: Array = []
var _tick := 0.0
var _scan_t := 0.0
var _talk_t := 0.0
var _gate_t := 0.0
var _bark_cd := 0.0
var _warn_cd := 0.0
var _tolga_done := {}
var _tolga_armed := true
var _last_kind := ""
var _clock := 0.0
var _was_floor := true
var _jumps: Array[float] = []
var _jump_lock := 0.0
var _spoke := {}                     # kişi kimliği -> son söz anı (kişi başına bekleme)
var _spin := 0.0
var _last_yaw := INF
var _spin_cd := 0.0
var _bump_cd := 0.0
var _stare_n: Node3D
var _stare_t := 0.0
var _sword_t := 0.0
var _fez := -1
var _crouch_t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_env_test = OS.has_environment("STREET_EYE_TEST")
	enabled = not OS.has_environment("STREET_EYE_OFF")      # ölçüm: açık/kapalı karşılaştırması
	if _env_test:
		tree_exiting.connect(func(): print("STREETEYE chapter=%s mode=%s %s" % [_chapter, mode, str(counts)]))


func _process(delta: float) -> void:
	_clock += delta
	_gate_t -= delta
	if _gate_t <= 0.0:
		_gate_t = 0.1
		var m := _gate()
		if m != mode:
			if mode != "" and m != "full":
				_release_all()
			mode = m
	if mode == "":
		if not _talk_bodies.is_empty() or not _soldiers_on.is_empty():
			_talk_off()
		return
	var t0 := Time.get_ticks_usec()
	_detect(delta)
	_rays()
	_tick -= delta
	if _tick <= 0.0:
		_tick = 0.1
		_scan_t -= 0.1
		if _scan_t <= 0.0:
			_scan_t = 0.5
			_scan()
		_think()
	_talk_t -= delta
	if _talk_t <= 0.0:
		_talk_t = 0.25
		_talk_update()
	if _env_test:
		_env_t -= delta
		if _env_t <= 0.0:
			_env_t = 1.5
			for k: String in ["jump", "phone", "spin", "selfie"]:
				event(k, 1.0)
			if int(counts["events"]) % 40 == 0:
				print("STREETEYE chapter=%s mode=%s %s" % [_chapter, mode, str(counts)])
	prof_sum_us += float(Time.get_ticks_usec() - t0)
	prof_n += 1


# ---------------------------------------------------------------- kapı

func _gate() -> String:
	if not enabled or not is_inside_tree() or hud == null:
		return ""
	if GameState.autotest and not test_on and not _env_test:
		return ""
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != _player:
		if _player and is_instance_valid(_player) and _player.item_used.is_connected(_on_item):
			_player.item_used.disconnect(_on_item)
		_player = p
		_st.clear()
		_near.clear()
		_pending.clear()
		_agents.clear()
		_talk_bodies.clear()
		_soldiers_on.clear()
		_cl = null
		_fez = -1
		_last_yaw = INF
		_tolga_done.clear()
		if p:
			p.item_used.connect(_on_item)
			_chapter = CityLife.chapter_of(p)
			_scene = p.get_parent()
	if p == null or not p.is_inside_tree():
		return ""
	if force_mode != "":
		return force_mode
	var stealth: bool = _chapter in STEALTH or (_scene != null and is_instance_valid(_scene) and _scene.get_node_or_null("Trespass") != null)
	if _env_test and stealth:
		return "glance"          # gizlilik denetimi: konuşmada, ara sahnede de açık (yalnız baş)
	if not p.hand_style in ["tolga", "nihat"] or p.step_voice != "":
		return ""
	if p.frozen or p.combat or p.is_down or p.pinned or p.ladder != null or p.seated:
		return ""
	var pw = p.get("powers")
	if pw != null and (bool(pw.get("cloaked")) or bool(pw.get("flying"))):
		return ""
	if bool(hud.get("cinematic")):
		return ""
	var sc := get_tree().current_scene
	if sc and sc.has_meta("cinematic") and sc.get_meta("cinematic"):
		return ""
	if stealth:
		return "glance"
	return "full"


func is_night() -> bool:
	return _cl != null and is_instance_valid(_cl) and bool(_cl.get("night"))


# ---------------------------------------------------------------- oyuncunun hareketlerinden olay

func _detect(delta: float) -> void:
	var p := _player
	var on_floor := p.is_on_floor()
	# Zıplama: tuşa basıldığı an (yerdeyken) ya da yerden kalkış (kare hızı düşükse kalkış anı kaçabilir)
	var jumped := Input.is_action_just_pressed("jump") and on_floor
	_jump_lock -= delta
	if jumped or (_jump_lock <= 0.0 and _was_floor and not on_floor and p.velocity.y > 1.5):
		_jump_lock = 0.5
		on_floor = false
		_jumps.append(_clock)
		while not _jumps.is_empty() and _clock - _jumps[0] > 4.0:
			_jumps.pop_front()
		event("jump", minf(0.6, 0.22 + 0.1 * (_jumps.size() - 1)))
	_was_floor = on_floor
	var y := p.rotation.y
	if _last_yaw != INF:
		_spin = maxf(0.0, _spin - delta * 1.5) + absf(angle_difference(_last_yaw, y))
	_last_yaw = y
	_spin_cd -= delta
	if _spin > 9.0 and _spin_cd <= 0.0:
		_spin = 0.0
		_spin_cd = 4.0
		event("spin")
	if p.hand_style == "tolga" and hud.has_method("tolga_wears_fez"):
		var f := 1 if hud.call("tolga_wears_fez") else 0
		if _fez >= 0 and f != _fez:
			event("fez")
		_fez = f
	if p.has_kept_blade() and p.horizontal_speed() > 0.5:
		_sword_t -= delta
		if _sword_t <= 0.0:
			_sword_t = 4.0
			event("sword")
	if p.eye_height < p.eye_rest - 0.3 and p.horizontal_speed() > 0.4:
		_crouch_t += delta
		if _crouch_t >= 1.0:
			_crouch_t = -4.0
			event("crouch")
	elif _crouch_t > 0.0:
		_crouch_t = 0.0
	else:
		_crouch_t = minf(0.0, _crouch_t + delta)


func _on_item(target: String, item: String) -> void:
	if mode == "":
		return
	var who: Node3D = null
	if target == "npc:crowd":
		who = SideEvents.street_focus(get_tree())
	# Birine gösterilen eşyaya o kişi kendi repliğiyle cevap verir: seyirciler yalnız bakar (söz yok)
	event(ITEM_KIND.get(item, "item"), -1.0, who, target != "")


## Tuhaflık olayı: çevredeki kişilerin dikkatini artırır (target: doğrudan muhatap). quiet: söz yok
func event(kind: String, strength := -1.0, target: Node3D = null, quiet := false) -> void:
	if mode == "" or _player == null:
		return
	counts["events"] += 1
	var spec: Array = KINDS.get(kind, [0.3, 8.0])
	var s: float = spec[0] if strength < 0.0 else strength
	var r: float = spec[1]
	_last_kind = kind
	if mode == "full":
		interest += s
	var pp := _player.global_position
	if _near.is_empty():
		_scan()
	for n: Node3D in _valid(_near):
		if not is_instance_valid(n):
			continue
		var rel := Vector3(pp.x - n.global_position.x, 0, pp.z - n.global_position.z)
		var d := rel.length()
		var add := 0.0
		if n == target:
			add = s * 1.6
		elif d <= r:
			var fwd := n.global_basis.z
			fwd.y = 0.0
			var face := fwd.normalized().dot(rel / maxf(d, 0.01))
			add = s * (1.0 - 0.6 * d / r) * (1.0 if face > 0.3 else (0.6 if face > -0.3 else 0.3))
		else:
			continue
		if d < 3.0 or n == target:
			_apply(n, add, kind, quiet)
		else:
			_pending.append([n, add, kind, quiet])
	while _pending.size() > 24:
		_pending.pop_front()


## Görüş denetimi: kişinin gözünden oyuncunun gözüne katı yoksa dikkat eklenir (kare başına en çok 3)
func _rays() -> void:
	if _pending.is_empty():
		return
	var cam := _player.camera
	var to := cam.global_position if cam else _player.global_position + Vector3(0, 1.6, 0)
	var space := _player.get_world_3d().direct_space_state
	for i in RAYS_PER_FRAME:
		if _pending.is_empty():
			return
		var e: Array = _pending.pop_front()
		if not is_instance_valid(e[0]):
			continue
		var n := e[0] as Node3D
		if n == null or not n.is_inside_tree():
			continue
		var q := PhysicsRayQueryParameters3D.create(n.global_position + Vector3(0, 1.55 * n.scale.y, 0), to, 1, [_player.get_rid()])
		if space.intersect_ray(q).is_empty():
			_apply(n, e[1], e[2], e[3])


func _apply(n: Node3D, add: float, kind: String, quiet: bool) -> void:
	var id := n.get_instance_id()
	var st: Dictionary = _st.get(id, {})
	if st.is_empty():
		st = {"n": n, "a": 0.0, "lvl": 0, "next": 0.0, "bark_cd": 0.0, "gest_cd": 0.0, "own": false, "look_t": 0.0,
			"whisper": false}
		_st[id] = st
	st["a"] = minf(1.3, float(st["a"]) + add)
	st["kind"] = kind
	st["quiet"] = quiet
	st["seen"] = _clock


# ---------------------------------------------------------------- 10 Hz

func _scan() -> void:
	_near.clear()
	_soldiers.clear()
	var pp := _player.global_position
	for g: String in ["persons", "soldiers"]:
		for x in get_tree().get_nodes_in_group(g):
			var n := x as Node3D
			if n == null or not n.is_visible_in_tree() or n.has_meta("corpse") or n.get_meta("hologram", false) \
					or n.has_meta("no_react") or n.get("rig") == null or _player.is_ancestor_of(n):
				continue
			var d := Vector2(n.global_position.x - pp.x, n.global_position.z - pp.z).length()
			if d > SCAN_R or absf(n.global_position.y - pp.y) > 6.0:
				continue
			_near.append(n)
			if n is Soldier:
				_soldiers.append(n)
	if _cl == null or not is_instance_valid(_cl):
		_cl_t -= 0.5
		if _cl_t <= 0.0:
			_cl_t = 3.0
			_cl = null
			var w := get_tree().get_first_node_in_group("player")
			var root: Node = _scene if _scene else (w.get_parent() if w else null)
			if root:
				for c in root.find_children("CityLife", "Node3D", true, false):
					_cl = c
	_agents.clear()
	if _cl != null and is_instance_valid(_cl):
		for ag in _cl.get("agents"):
			if ag.body != null:
				_agents[ag.body.get_instance_id()] = ag
	_ctx = SideEvents.street_ctx(get_tree(), is_night())


func _think() -> void:
	_bark_cd -= 0.1
	_warn_cd -= 0.1
	interest = maxf(0.0, interest - 0.15 * 0.1)
	if interest < 0.8:
		_tolga_armed = true
	var p := _player
	# Koşup birine çarpma
	_bump_cd -= 0.1
	if _bump_cd <= 0.0 and p.horizontal_speed() > 4.0:
		for n: Node3D in _valid(_near):
			if is_instance_valid(n) and Vector2(n.global_position.x - p.global_position.x, n.global_position.z - p.global_position.z).length() < 0.9:
				_bump_cd = 1.5
				event("bump", -1.0, n)
				break
	# Dik dik bakma: bakış ışını aynı kişide 3,5 sn
	var f: Node3D = null
	if p.focus_id == "npc:crowd":
		f = SideEvents.street_focus(get_tree())
	if f != null and f == _stare_n:
		_stare_t += 0.1
		if _stare_t >= 3.5:
			_stare_t = -6.0
			event("stare", -1.0, f)
	else:
		_stare_n = f
		_stare_t = 0.0
	# Kişiler: dikkat söner, basamaklar sırayla
	for id in _st.keys():
		var st: Dictionary = _st[id]
		if not is_instance_valid(st["n"]) or not (st["n"] as Node3D).is_visible_in_tree():
			_st.erase(id)
			continue
		var n := st["n"] as Node3D
		st["bark_cd"] = float(st["bark_cd"]) - 0.1
		st["gest_cd"] = float(st["gest_cd"]) - 0.1
		if _clock - float(st.get("seen", 0.0)) > 1.0:
			st["a"] = float(st["a"]) - DECAY * 0.1
		var a: float = st["a"]
		if st["own"]:
			st["look_t"] = float(st["look_t"]) - 0.1
			if float(st["look_t"]) <= 0.0 or a < 0.3:
				_unturn(st)
		if a < 0.15:
			_unturn(st)
			_st.erase(id)
			continue
		var want := 0
		for l: float in LEVELS:
			if a >= l:
				want += 1
		var lvl: int = st["lvl"]
		if want > lvl and _clock >= float(st["next"]):
			lvl += 1
			st["lvl"] = lvl
			st["next"] = _clock + STEP_GAP
			_level(st, lvl)
		elif want < lvl:
			st["lvl"] = want
		elif want == 5 and lvl == 5 and float(st["bark_cd"]) <= 0.0 and _clock >= float(st["next"]):
			st["next"] = _clock + 1.0
			_bark(st)          # yeni bir tuhaflık: aynı kişi (soğuması bittiyse) yine söylenir
		if want >= 1 and mode != "":
			_stare(n, 1.5)
	if mode == "full" and interest >= WARN_AT and _warn_cd <= 0.0:
		_warn()
	if mode == "full" and interest >= TOLGA_AT and _tolga_armed:
		_tolga_armed = false
		_tolga_odd()


## Kişinin tepki sınırı: 1 yalnız baş (hikâye karakteri, nöbetteki, oturan/iş yapan, sahne hareketindeki, gizlilik bölümü)
func _cap(n: Node3D) -> int:
	if mode != "full":
		return 1
	if n.has_meta("spk") or (n.has_meta("speaker") and not n.has_meta("street_speaking")) or n.has_meta("garrison") \
			or n.has_meta("no_turn") or n.has_meta("no_talk"):
		return 1
	if n.get("talking") == true:
		return 1
	if n is Person:
		var p := n as Person
		if p.face_id != "" or p.is_busy() or not p.activity in ["", "carry"]:
			return 1
	elif n is Soldier:
		if (n as Soldier).pose != "stand":
			return 1
	var lt = n.get("look_target")
	if lt != null and is_instance_valid(lt) and lt != _player:
		return 1
	return 5


func _level(st: Dictionary, lvl: int) -> void:
	var n := st["n"] as Node3D
	if lvl > _cap(n):
		return
	steps.append([n.get_instance_id(), lvl])
	match lvl:
		1:
			_stare(n, 5.0)
			counts["stares"] += 1
		2:
			_turn(st)
		3:
			var ag = _agents.get(n.get_instance_id())
			if ag != null:
				ag.wait = maxf(ag.wait, 3.0)
			counts["stops"] += 1
		4:
			_gesture(st)
		5:
			_bark(st)


func _stare(n: Node3D, secs: float) -> void:
	var rg = n.get("rig")
	if rg is Rig:
		(rg as Rig).stare_t = maxf((rg as Rig).stare_t, secs)


func _turn(st: Dictionary) -> void:
	var n := st["n"] as Node3D
	counts["turns"] += 1
	var ag = _agents.get(n.get_instance_id())
	if ag != null:
		ag.look = maxf(ag.look, 4.0)
		return
	if n.get("look_target") == null:
		n.set("look_target", _player)
		st["own"] = true
		st["look_t"] = 5.0


func _unturn(st: Dictionary) -> void:
	if not st["own"]:
		return
	st["own"] = false
	if is_instance_valid(st["n"]) and (st["n"] as Node).get("look_target") == _player:
		(st["n"] as Node).set("look_target", null)


func _release_all() -> void:
	for id in _st.keys():
		_unturn(_st[id])
	_st.clear()
	_pending.clear()


func _valid(a: Array) -> Array:
	return a.filter(func(x): return is_instance_valid(x))


func _role(n: Node3D) -> String:
	return SideEvents.street_role(n, _ctx)


func _side(role: String) -> String:
	var s: String = SideEvents.STREET_SIDE.get(role, "")
	if s == "":
		s = "O" if _ctx.get("place", "BYZ") == "CAMP" else "B"
	return s


func _gesture(st: Dictionary) -> void:
	var n := st["n"] as Node3D
	if float(st["gest_cd"]) > 0.0 or not n.has_method("emote"):
		return
	st["gest_cd"] = GESTURE_GAP
	counts["gestures"] += 1
	var role := _role(n)
	var kind: String = st.get("kind", "")
	var em := "surprise"
	if role == "CHILDB":
		em = "cheer"
	elif role in GUARDS:
		em = "point" if randf() < 0.6 else "arms_cross"
	elif kind in ["jump", "spin", "selfie", "fez"]:
		em = ["laugh", "point", "facepalm"][randi() % 3]
	elif kind == "stare":
		em = "shrug"
	elif kind == "bump":
		em = "facepalm"
	n.call("emote", em)
	# Yanındakine fısıldar: komşu da başını çevirir
	for o: Node3D in _valid(_near):
		if o != n and is_instance_valid(o) and o.global_position.distance_to(n.global_position) < 2.4:
			st["whisper"] = randf() < 0.45
			_stare(o, 4.0)
			break


## Tepki sözü. Önce konuşacak KİŞİ seçilir: tepki veren (iş bırakıp jest yapan), oyuncunun görüş alanında (kamera
## kadrajında, arası açık), söz hakkı olan kişiler; tetikleyen ilk, sonra en yakınlar. Satır, o kişinin KENDİ rolünün
## (konuşmacısının, yoksa aynı öbeğin) havuzundan seçilir. O kişi için bu tuhaflıkta satır yoksa aynı taraftan sıradaki aday
## denenir; hiçbirinde yoksa söz yok (yalnız jest). Görünmeyen birine söz verilmez; söz her zaman bir ağzı oynayan kişinindir.
func _bark(st: Dictionary) -> void:
	if mode != "full" or st["quiet"] or float(st["bark_cd"]) > 0.0 or _bark_cd > 0.0 or _ctx.get("era", "") == "pre":
		return
	if not _can_speak():
		return
	var cands: Array = []
	for id in _st:
		var c: Dictionary = _st[id]
		var cn = c["n"]
		if not is_instance_valid(cn) or c["quiet"] or int(c["lvl"]) < 4 or float(c["bark_cd"]) > 0.0:
			continue
		if _cap(cn) < 4 or _spoke_recently(cn) or not _in_view(cn):
			continue
		cands.append(c)
	var pp := _player.global_position
	cands.sort_custom(func(a, b):
		if a == st or b == st:
			return a == st
		return (a["n"] as Node3D).global_position.distance_squared_to(pp) < (b["n"] as Node3D).global_position.distance_squared_to(pp))
	var side0 := ""
	for c: Dictionary in cands:
		var n := c["n"] as Node3D
		var role := _role(n)
		var side := _side(role)
		if side0 == "":
			side0 = side
		elif side != side0:
			continue          # yedek konuşan aynı taraftan olmalı
		var key := _line_for(c, role, side)
		if key == "":
			continue
		c["bark_cd"] = PERSON_BARK_GAP
		st["bark_cd"] = maxf(float(st["bark_cd"]), 2.0)
		_bark_cd = BARK_GAP
		_say(role, key, n)
		return
	st["bark_cd"] = 4.0          # kimse söyleyemedi (görünmüyor ya da satır yok): yalnız jest; biraz sonra yine bakılır


## Kişinin rolüne uyan tepki satırı ("" = bu kişi için yok)
func _line_for(c: Dictionary, role: String, side: String) -> String:
	var kind: String = c.get("kind", "")
	var my_spk: String = SideEvents.STREET_SPK.get(role, "")
	if my_spk == "" and not plain:
		return ""
	var key := ""
	if plain:
		pass
	elif role == "CHILDB" and kind in ["jump", "spin", "phone"]:
		key = {"jump": "DST_CHILD_COPY_1", "spin": "DST_CHILD_COPY_2", "phone": "DST_CHILD_COPY_3"}[kind]
	elif c["whisper"]:
		key = _pick_line("DST_WHISPER_%s_" % ("O" if side == "O" else "B"), my_spk)
	if key == "":
		key = _pick_line("DST_ODD_%s_%s_" % [kind.to_upper(), "O" if side == "O" else "B"], my_spk)
	return key


## Önekin satırlarından kişinin konuşmacısına (yoksa aynı öbeğe) uyan biri; uymazsa ""
func _pick_line(prefix: String, my_spk: String) -> String:
	if my_spk == "":
		return ""
	var exact: Array = []
	var group: Array = []
	var my_g: String = SPK_GROUP.get(my_spk, "")
	for pr: Array in SideEvents.STREET_EVENT_LINES:
		var k: String = pr[1]
		if not k.begins_with(prefix):
			continue
		if prefix.contains("_CLIMB_") or not SideEvents._has(k):
			continue
		if pr[0] == my_spk:
			exact.append(k)
		elif my_g != "" and SPK_GROUP.get(pr[0], "") == my_g:
			group.append(k)
	if not exact.is_empty():
		return SideEvents.street_bag(prefix + my_spk, exact)
	if not group.is_empty():
		return SideEvents.street_bag(prefix + my_g, group)
	return ""


## Kişi oyuncunun görüş alanında mı: kameranın kadrajında ve gözle baş arası açık (kişi, oyuncu ve su katı sayılmaz)
func _in_view(n: Node3D) -> bool:
	var cam := _player.camera if _player else null
	if cam == null or not cam.is_inside_tree() or not n.is_inside_tree():
		return false
	var head := n.global_position + Vector3(0, 1.5 * n.scale.y, 0)
	if not cam.is_position_in_frustum(head):
		return false
	var to := head.move_toward(cam.global_position, 0.35)
	var q := PhysicsRayQueryParameters3D.create(cam.global_position, to, 1, [_player.get_rid()])
	return _player.get_world_3d().direct_space_state.intersect_ray(q).is_empty()


func _can_speak() -> bool:
	if GameState.autotest:
		return true          # testte Hud'a gitmez (said'e yazılır)
	if hud == null or SideEvents._playing:
		return false
	return not bool(hud.call("street_busy"))          # altyazı, replik, ara sahne, seçim, ses sürerken tepki sözü yok


func _spoke_recently(n: Node3D) -> bool:
	return _clock - float(_spoke.get(n.get_instance_id(), -999.0)) < PERSON_BARK_GAP


func _say(role: String, key: String, who: Node3D) -> void:
	_spoke[who.get_instance_id()] = _clock
	said.append(key)
	barkers.append(who.get_instance_id())
	said_roles.append(role)
	counts["barks"] += 1
	if GameState.autotest:
		return
	hud.call("street_bark", who, role, key, 3.0)


## Nöbetçi uyarısı: sahnenin ilgisi birikince en yakın (görmüş) asker döner, gösterir ve uyarır
func _warn() -> void:
	if not _can_speak() or _bark_cd > 0.0:
		return
	var best: Node3D = null
	var bd := 18.0
	var bkey := ""
	for n: Node3D in _valid(_near):
		if not is_instance_valid(n) or _cap(n) < 2 or not _role(n) in GUARDS:
			continue
		var seen: bool = _st.has(n.get_instance_id())
		var d := n.global_position.distance_to(_player.global_position)
		if not ((seen or d < 8.0) and d < bd) or not _in_view(n):
			continue          # görünmeyen nöbetçi uyarmaz
		var r := _role(n)
		var k := _pick_line("DST_WARN_%s_" % _side(r), SideEvents.STREET_SPK.get(r, ""))
		if k == "":
			continue          # bu nöbetçinin rolüne uyan uyarı satırı yok
		bd = d
		best = n
		bkey = k
	if best == null:
		return
	var key := bkey
	_warn_cd = WARN_GAP
	_bark_cd = BARK_GAP
	interest = 0.8
	counts["warns"] += 1
	var st: Dictionary = _st.get(best.get_instance_id(), {})
	if st.is_empty():
		_apply(best, 0.5, _last_kind, true)
		st = _st[best.get_instance_id()]
	_stare(best, 6.0)
	_turn(st)
	steps.append([best.get_instance_id(), 6])
	if best.has_method("emote"):
		best.call("emote", "point")
	_say(_role(best), key, best)
	if _player.hand_style == "tolga" and not _tolga_done.has("warn"):
		_tolga_done["warn"] = true
		_later_tolga("DST_T_ODD_5", 3.5)


## Herkes bakınca Tolga'nın sözü (bölümde her biri bir kez)
func _tolga_odd() -> void:
	if _player.hand_style != "tolga":
		return
	var k := ""
	if _last_kind == "jump" and not _tolga_done.has("DST_T_ODD_2"):
		k = "DST_T_ODD_2"
	elif _last_kind == "selfie" and not _tolga_done.has("DST_T_ODD_4"):
		k = "DST_T_ODD_4"
	else:
		for c: String in ["DST_T_ODD_1", "DST_T_ODD_3"]:
			if not _tolga_done.has(c):
				k = c
				break
	if k == "":
		return
	_tolga_done[k] = true
	_later_tolga(k, 3.2)


func _later_tolga(key: String, secs: float) -> void:
	if GameState.autotest:
		said.append(key)
		barkers.append(0)
		said_roles.append("")
		return
	get_tree().create_timer(secs, false).timeout.connect(_tolga_fire.bind(key, secs))


func _tolga_fire(key: String, secs: float) -> void:
	if mode == "full" and _can_speak():
		said.append(key)
		barkers.append(0)
		said_roles.append("")
		hud.call("bark", "SPK_TOLGA", key, secs)


## Test: durumu sıfırlar (kişilerin dikkati, sözler, bekleme süreleri)
func reset_test() -> void:
	_release_all()
	said.clear()
	barkers.clear()
	said_roles.clear()
	steps.clear()
	interest = 0.0
	_bark_cd = 0.0
	_warn_cd = 0.0
	_tolga_done.clear()
	_tolga_armed = true
	_spoke.clear()
	for k in counts:
		counts[k] = 0


## SideEvents.street_talk bildirir (test sayar)
func note_talk(_who: Node3D, _key: String) -> void:
	counts["talks"] += 1


# ---------------------------------------------------------------- konuşma alanları

func _talk_update() -> void:
	var allow: bool = mode == "full" and _ctx.get("era", "siege") != "pre"
	var pp := _player.global_position
	# CityLife: yakındaki gövdeye geçici alan (uzaklaşınca, havuza dönünce silinir)
	if _cl != null and is_instance_valid(_cl):
		for ag in _cl.get("agents"):
			var b: Node3D = ag.body
			if b == null:
				continue
			var id := b.get_instance_id()
			var d := Vector2(b.global_position.x - pp.x, b.global_position.z - pp.z).length() if ag.active else INF
			var has := _talk_bodies.has(id)
			if allow and ag.active and d < TALK_R and not has:
				b.set_meta("street_role", _agent_role(ag, b))
				var sb := Props.interactable(b, "npc:crowd", Vector3(0.9, 1.9, 0.9), Vector3(0, 0.95, 0))
				sb.set_meta("street_tmp", true)
				_talk_bodies[id] = [b, sb]
			elif has and (not allow or not ag.active or d > TALK_R + 1.5):
				var sb2 = _talk_bodies[id][1]
				if is_instance_valid(sb2):
					sb2.queue_free()
				_talk_bodies.erase(id)
			if not ag.active and b.has_meta("street_n"):
				b.remove_meta("street_n")
	# Askerler (Soldier): kendi kapalı "soldier" alanı yakındayken "npc:crowd" olarak açılır
	for s: Node3D in _valid(_soldiers):
		if not is_instance_valid(s) or _agents.has(s.get_instance_id()):
			continue
		var id := s.get_instance_id()
		var d := s.global_position.distance_to(pp)
		var on := _soldiers_on.has(id)
		if allow and d < TALK_R and not on and _soldier_ok(s as Soldier):
			var ib := s.get_node_or_null("Interact_soldier") as StaticBody3D
			if ib:
				ib.set_meta("interact_id", "npc:crowd")
				ib.collision_layer = 2
				_soldiers_on[id] = s
		elif on and (not allow or d > TALK_R + 1.5):
			_soldier_off(s)
			_soldiers_on.erase(id)


func _soldier_ok(s: Soldier) -> bool:
	if s.has_meta("street_ok"):
		return bool(s.get_meta("street_ok"))
	var ok: bool = s.pose == "stand" and not (s.has_meta("spk") or s.has_meta("speaker") or s.has_meta("no_talk") \
		or s.has_meta("garrison") or s.has_meta("citylife") or s.get_meta("hologram", false))
	if ok:
		# Yakında (2,2 m) başka bir etkileşim alanı varsa (görev, mini oyun, kişi) asker konuşma alanı açmaz
		var own := s.get_node_or_null("Interact_soldier")
		var sh := SphereShape3D.new()
		sh.radius = 2.2
		var q := PhysicsShapeQueryParameters3D.new()
		q.shape = sh
		q.collision_mask = 2
		q.transform = Transform3D(Basis(), s.global_position + Vector3(0, 1.0, 0))
		for h in s.get_world_3d().direct_space_state.intersect_shape(q, 8):
			var c = h.get("collider")
			if c != own and c is Node and not (c as Node).has_meta("street_tmp"):
				ok = false
				break
	s.set_meta("street_ok", ok)
	return ok


func _soldier_off(s) -> void:
	if not is_instance_valid(s):
		return
	var ib := (s as Node).get_node_or_null("Interact_soldier") as StaticBody3D
	if ib:
		ib.collision_layer = 0
		ib.set_meta("interact_id", "soldier")


func _talk_off() -> void:
	for id in _talk_bodies.keys():
		var sb = _talk_bodies[id][1]
		if is_instance_valid(sb):
			sb.queue_free()
	_talk_bodies.clear()
	for id in _soldiers_on.keys():
		_soldier_off(_soldiers_on[id])
	_soldiers_on.clear()


## CityLife ajanının rolü
func _agent_role(ag, b: Node3D) -> String:
	match str(ag.kind):
		"patrol":
			if b is Soldier:
				return "JAN"
			return "GENMERC" if str(b.get("armor")) == "mail" else "BYZSOL"
		"vendor":
			return "VENDB"
		"fisher":
			return "FISHER"
	match str(ag.role):
		"porter": return "PORTER"
		"priest": return "PRIEST"
		"monk": return "MONK"
		"woman": return "WOMB"
		"child": return "CHILDB"
	return "TOWNB"
