extends Node3D
## STREETCHECK: sokak insanı (SideEvents.street_* ve scripts/street_eye.gd).
##   (a) her rol için bir kişi kurulur, oyuncu ona bakıp E'ye basar: "npc:crowd" odağı gelir, rolün havuzundan bir söz
##       söylenir (konuşmacısı rolünki); her rol × dönem × fes × gece × yer havuzunun anahtarları tr ve en'de var
##   (b) aynı kişiye 5 kez: 1-2 olağan, 3 AGAIN_1, 4 AGAIN_2 (yoksa AGAIN), 5 AGAIN
##   (c) her tuhaflık türü: çevredeki kişilerde basamaklar sırayla (baş 1 → gövde 2 → ... → söz 5), söz o türün
##       repliği; sahne soğuması (hemen tekrarında söz yok), kişi soğuması (aynı kişi yine söylemez); nöbetçi uyarısı
##   (f) tepki sözünü söyleyen kişi oyuncunun görüş alanında (kadraj), tepki veriyor, satırın konuşmacısı kişinin rolüyle
##       uyumlu, altyazı adı kişinin rol etiketi; kimse uygun değilse söz yok (100 rastgele olayda ihlal 0)
##   (g) sokak satırında portre kişinin kendi kafasıdır (Hud.last_line_who) ya da gizli; tek konuşan; altyazı sürerken
##       tepki sözü yok (street_busy), ara sahne/seçim/replik sırasında da yok
##   (d) gizlilik kipi ("glance", bölüm 4/25/16...): yalnız baş; gövde yönü, bakış hedefi değişmez, söz yok
##   (e) Bölüm 24'ün şehrinde (CityLife): yakındaki gövdelere konuşma alanı açılır, StreetEye kare süresi ortalaması
##       ≤150 µs; CityLife'ın kare süresi StreetEye açık/kapalı aynı (fark < %10)
## Henüz içe aktarılmamış yeni metinler (i18n/strings.csv → .translation) testte strings.csv'den yüklenir.

const ROLES := ["BYZSOL", "GENMERC", "OSMSOL", "JAN", "AZAP", "VENDB", "VENDO", "PORTER", "WORKER", "PRIEST", "MONK", "DERV",
	"WOMB", "CHILDB", "FISHER", "TOWNB"]
## Kişinin görünüşü (rol işareti olmadan çıkarılabilenler); Soldier: [şapka]
const LOOK := {"BYZSOL": {"hat": "helm"}, "GENMERC": {"hat": "helm", "armor": "mail"}, "OSMSOL": ["turban"], "JAN": ["bork"],
	"AZAP": ["azap"], "VENDB": {"apron": Color("e8dcc0")}, "PRIEST": {"hat": "priest", "robe": Color("1e1c1e")},
	"MONK": {"hat": "hood", "robe": Color("2a2226")}, "WOMB": {"skirt": true, "hat": "scarf"}, "CHILDB": {"child": true},
	"TOWNB": {}}
const KINDS := ["jump", "bump", "phone", "selfie", "stare", "spin", "sword", "fez", "cologne", "lighter", "chick", "cube",
	"crouch"]

var player: Player
var hud: Hud
var eye: Node
var _fail: Array[String] = []
var _shown: Array[String] = []
var _hold := Vector3.INF


func _ready() -> void:
	GameState.autotest = true
	GameState.settings["auto_advance"] = false
	var shim := _shim_strings()
	if shim > 0:
		print("STREETCHECK not: %d yeni anahtar henüz içe aktarılmamış, test için strings.csv'den yüklendi" % shim)
	if OS.has_environment("STREET_SHOTS"):
		await _shots(OS.get_environment("STREET_SHOTS"))
		get_tree().quit(0)
		return
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	add_child(env)
	Props.solid(self, Vector3(60, 0.4, 60), Vector3(0, -0.2, 0), Color("6a6a60"))
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.global_position = Vector3(0, 0.05, 0)
	await _frames(4)
	eye = hud.street_eye
	eye.set("test_on", true)
	eye.set("force_mode", "full")
	hud.line_shown.connect(func(k: String): _shown.append(k))
	_pools()
	await _talk_roles()
	await _events()
	await _view_trials()
	await _real_input()
	await _glance()
	# (e) bölümün kendi oyuncusu ve Hud'u gelsin: bu sahnenin oyuncusu kalkar
	player.queue_free()
	hud.queue_free()
	player = null
	hud = null
	await _frames(3)
	await _city()
	print("STREETCHECK %s%s" % ["PASS" if _fail.is_empty() else "FAIL", "" if _fail.is_empty() else ": " + "; ".join(_fail)])
	get_tree().quit(0 if _fail.is_empty() else 1)


func _process(_d: float) -> void:
	if _dir != "" and is_instance_valid(player):
		player.frozen = false          # kare kipi: bölümün açık konuşması oyuncuyu dondurmasın
		player.pinned = false          # Bölüm 24'ün açılışında oyuncu yerine sabit
	if _hold != Vector3.INF and is_instance_valid(player):
		player.global_position = _hold
		player.velocity = Vector3.ZERO


func _bad(msg: String) -> void:
	_fail.append(msg)
	print("STREETCHECK hata: ", msg)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


## strings.csv'de olup çeviri sunucusunda olmayan sokak anahtarları: test için çeviriye eklenir
func _shim_strings() -> int:
	var f := FileAccess.open("res://i18n/strings.csv", FileAccess.READ)
	if f == null:
		return 0
	var ttr := Translation.new()
	ttr.locale = "tr"
	var ten := Translation.new()
	ten.locale = "en"
	var n := 0
	f.get_csv_line()
	while not f.eof_reached():
		var r := f.get_csv_line()
		if r.size() < 3:
			continue
		var k := r[0]
		if not (k.begins_with("DST_") or k.begins_with("UI_STREET_") or k in ["SPK_STREET_MONK", "SPK_WOMAN_BYZ",
				"SPK_CHILD_BYZ", "SPK_PORTER", "SPK_WORKER", "SPK_SUTLER"]):
			continue
		if TranslationServer.translate(k) != k:
			continue
		ttr.add_message(k, r[1])
		ten.add_message(k, r[2])
		n += 1
	if n > 0:
		TranslationServer.add_translation(ttr)
		TranslationServer.add_translation(ten)
	return n


func _both(k: String) -> bool:
	var loc := TranslationServer.get_locale()
	TranslationServer.set_locale("tr")
	var a := TranslationServer.translate(k) != k
	TranslationServer.set_locale("en")
	var b := TranslationServer.translate(k) != k
	TranslationServer.set_locale(loc)
	return a and b


# ---------------------------------------------------------------- (a) havuzlar

func _pools() -> void:
	var n := 0
	for role: String in ROLES + ["GAL"]:
		for era: String in ["siege", "conq"]:
			for fez in [true, false]:
				for night in [true, false]:
					for place: String in ["BYZ", "GAL", "CAMP"]:
						for ch: String in ["24", "41o"]:
							var ctx := {"chapter": ch, "era": era, "place": place, "night": night, "tolga": true, "fez": fez}
							for v in [1, 2, 3, 4, 5]:
								for i in 4 if v < 3 else 1:
									var k := SideEvents.street_pick(role, ctx, v)
									n += 1
									if k == "" or not _both(k):
										_bad("havuz %s %s v%d: anahtar yok ya da çevirisi eksik (%s)" % [role, str(ctx), v, k])
										return
									var spk := SideEvents.street_speaker(k)
									if not _both(spk):
										_bad("konuşmacı adı eksik: %s (%s)" % [spk, k])
										return
	for pr: Array in SideEvents.STREET_EVENT_LINES:
		if not _both(pr[1]):
			_bad("tepki satırı eksik: %s" % pr[1])
	for r: String in ROLES:
		var lb: String = SideEvents.STREET_LABEL.get(r, "")
		if lb != "" and not _both("UI_STREET_" + lb):
			_bad("istem adı eksik: UI_STREET_" + lb)
	print("STREETCHECK (a) havuz: %d seçim, hepsi tr+en" % n)


# ---------------------------------------------------------------- (a)+(b) E: Konuş

func _make(role: String) -> Node3D:
	var lk = LOOK.get(role, {})
	var n: Node3D
	if lk is Array:
		n = Soldier.new(Color("b3262d"), "stand", lk[0])
	else:
		var spec: Dictionary = (lk as Dictionary).duplicate()
		spec["coat"] = Color("6a5040")
		n = Person.new(spec)
		if not LOOK.has(role):
			n.set_meta("street_role", role)          # görünüşten çıkmayan roller (CityLife bunu koyar)
	add_child(n)
	return n


func _talk_roles() -> void:
	var ok_roles := 0
	for role: String in ROLES:
		var n := _make(role)
		n.global_position = Vector3(0, 0, -1.6)
		n.rotation.y = 0.0                 # yüzü +z: oyuncuya dönük
		player.global_position = Vector3(0, 0.05, 0)
		player.face(Vector3(0, 1.2, -1.6))
		var t := 0
		while player.focus_id != "npc:crowd" and t < 90:
			await get_tree().physics_frame
			t += 1
		if player.focus_id != "npc:crowd":
			_bad("%s: E · Konuş istemi gelmedi (odak '%s')" % [role, player.focus_id])
			n.queue_free()
			await _frames(3)
			continue
		var prompt := SideEvents.prompt("npc:crowd")
		var got: Array[String] = []
		for i in 5:
			_shown.clear()
			var ev := InputEventAction.new()
			ev.action = "interact"
			ev.pressed = true
			player._unhandled_input(ev)
			await _frames(3)
			got.append(_shown[0] if not _shown.is_empty() else "")
			# (g) altyazıdaki ad kişinin rol etiketi, portre sahibi kişinin kendisi, konuşurken ağzı oynar
			if hud.get("last_line_who") != n or hud.get("last_line_name") != SideEvents.role_label(role) or not n.get("talking"):
				_bad("%s: konuşma kartı kişiyle uyuşmuyor (portre sahibi=%s ad=%s ağız=%s)" % [role, str(hud.get("last_line_who")),
					str(hud.get("last_line_name")), str(n.get("talking"))])
		var g: String = SideEvents.STREET_AGAIN.get(role, "CIVB")
		var pool_ok := true
		for i in 2:
			var k := got[i]
			var own := k.begins_with("DST_%s_" % role) or (role == "TOWNB" and k.begins_with("NPC_CROWD_BYZ")) \
				or (role == "OSMSOL" and k.begins_with("NPC_CROWD_CAMP"))
			if not own or not _both(k):
				pool_ok = false
		var a1 := "DST_%s_AGAIN_1" % g
		var a2 := "DST_%s_AGAIN_2" % g
		var a0 := "DST_%s_AGAIN" % g
		var want3 := a1 if SideEvents._has(a1) else a0
		var want4 := a2 if SideEvents._has(a2) else a0
		if not pool_ok:
			_bad("%s: ilk sözler rolün havuzundan değil %s" % [role, str(got)])
		elif got[2] != want3 or got[3] != want4 or got[4] != a0:
			_bad("%s: tırmanan sıra yanlış %s (beklenen %s, %s, %s)" % [role, str(got), want3, want4, a0])
		else:
			ok_roles += 1
		print("STREETCHECK (a/b) %-7s istem='%s' %s" % [role, prompt, str(got)])
		n.queue_free()
		await _frames(4)
	print("STREETCHECK (a/b) %d/%d rol konuştu, tırmanma doğru" % [ok_roles, ROLES.size()])


# ---------------------------------------------------------------- (c) tuhaflık basamakları

func _ring() -> Array:
	var out: Array = []
	var specs := ["TOWNB", "WOMB", "BYZSOL", "PRIEST", "PORTER", "OSMSOL", "JAN", "AZAP", "WORKER"]
	for i in specs.size():
		var n := _make(specs[i])
		if specs[i] == "WORKER":
			n.set_meta("street_role", "WORKER")
		var a := -1.2 + 2.4 * i / float(specs.size() - 1)
		n.global_position = Vector3(sin(a) * 5.5, 0, -cos(a) * 5.5)
		n.look_at(Vector3(0, 0, 0), Vector3.UP, true)
		n.rotation.x = 0.0
		n.rotation.z = 0.0
		out.append(n)
	return out


## Kişilerin sözleri (Tolga'nın DST_T_ sözleri sayılmaz)
func _npc(said: Array) -> int:
	return said.filter(func(k): return not str(k).begins_with("DST_T_")).size()


func _events() -> void:
	var ring := _ring()
	_hold = Vector3(0, 0.05, 0)
	player.face(Vector3(0, 1.6, -5.0))
	await _frames(10)
	eye.set("plain", true)
	var ok_kinds := 0
	for kind: String in KINDS:
		eye.call("reset_test")
		eye.set("_warn_cd", 999.0)
		var target: Node3D = ring[4] if kind in ["bump", "stare"] else null
		for i in 8:
			eye.call("event", kind, -1.0, target)
			await get_tree().create_timer(0.35).timeout
			if _npc(eye.get("said")) > 0:
				break
		await get_tree().create_timer(2.2).timeout
		var said: Array = eye.get("said")
		var steps: Array = eye.get("steps")
		# Basamak sırası: bir kişinin kayıtları 1'den başlayıp artarak gider, en az 1 ve 2 var
		var by := {}
		for s: Array in steps:
			if not by.has(s[0]):
				by[s[0]] = []
			(by[s[0]] as Array).append(s[1])
		var ordered := not by.is_empty()
		var full := false
		for id in by:
			var seq: Array = by[id]
			if seq[0] != 1:
				ordered = false
			for j in range(1, seq.size()):
				if seq[j] <= seq[j - 1]:
					ordered = false
			if 1 in seq and 2 in seq and 5 in seq:
				full = true
		var spoke := false
		for k: String in said:
			if k.begins_with("DST_ODD_%s_" % kind.to_upper()):
				spoke = true
		# Sahne soğuması: hemen yeniden aynı tuhaflık → yeni söz yok
		var n0 := _npc(said)
		eye.call("event", kind, 1.0, target)
		await get_tree().create_timer(1.6).timeout
		var cool_scene: bool = _npc(eye.get("said")) == n0
		# Kişi soğuması: sahne beklemesi bitse de aynı kişi yine söylemez
		var b0: Array = (eye.get("barkers") as Array).duplicate()
		eye.set("_bark_cd", 0.0)
		eye.call("event", kind, 1.0, target)
		await get_tree().create_timer(1.6).timeout
		var b1: Array = eye.get("barkers")
		var cool_person := true
		for j in range(b0.size(), b1.size()):
			if b1[j] in b0 and b1[j] != 0:
				cool_person = false
		if ordered and full and spoke and cool_scene and cool_person:
			ok_kinds += 1
		else:
			_bad("%s: sıra=%s tam=%s söz=%s sahne_soğuma=%s kişi_soğuma=%s basamaklar=%s sözler=%s" % [kind, ordered, full,
				spoke, cool_scene, cool_person, str(by.values()), str(said)])
		print("STREETCHECK (c) %-7s kişi=%d basamaklar=%s söz=%s" % [kind, by.size(), str(by.values().slice(0, 3)), str(said)])
		eye.call("reset_test")
		await get_tree().create_timer(2.0).timeout
	# Nöbetçi uyarısı: ilgi birikince en yakın asker uyarır
	eye.call("reset_test")
	eye.set("_warn_cd", 0.0)
	for i in 6:
		eye.call("event", "jump", 0.6)
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(1.5).timeout
	var warned := false
	for k: String in eye.get("said"):
		if k.begins_with("DST_WARN_"):
			warned = true
	if not warned:
		_bad("nöbetçi uyarısı gelmedi: %s" % str(eye.get("said")))
	print("STREETCHECK (c) %d/%d tuhaflık türü sırayla tepki aldı; uyarı=%s %s" % [ok_kinds, KINDS.size(), warned, str(eye.get("said"))])
	eye.call("reset_test")
	eye.set("plain", false)
	for n in ring:
		n.queue_free()
	_hold = Vector3.INF
	await _frames(4)



# ---------------------------------------------------------------- (f)(g) konuşan = görünen

func _circle() -> Array:
	var out: Array = []
	var specs := ["TOWNB", "WOMB", "BYZSOL", "PRIEST", "PORTER", "OSMSOL", "JAN", "AZAP", "GENMERC", "CHILDB", "MONK", "VENDB",
		"FISHER", "TOWNB", "BYZSOL", "WOMB"]
	for i in specs.size():
		var n := _make(specs[i])
		var a := TAU * i / float(specs.size()) + 0.17
		var r := 3.5 + 3.0 * float((i * 7) % 5) / 4.0
		n.global_position = Vector3(sin(a) * r, 0, -cos(a) * r)
		n.look_at(Vector3(0, 0, 0), Vector3.UP, true)
		n.rotation.x = 0.0
		n.rotation.z = 0.0
		out.append(n)
	return out


func _in_frustum(n: Node3D) -> bool:
	return player.camera.is_position_in_frustum(n.global_position + Vector3(0, 1.5 * n.scale.y, 0))


func _view_trials() -> void:
	var ring := _circle()
	_hold = Vector3(0, 0.05, 0)
	await _frames(8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260511
	var groups: Dictionary = (eye.get_script() as GDScript).get_script_constant_map()["SPK_GROUP"]
	var kinds := KINDS
	var viol := 0
	var spoke := 0
	var silent := 0
	var shown_ok := 0
	var ctx := SideEvents.street_ctx(get_tree())
	for t in 100:
		eye.call("reset_test")
		eye.set("_warn_cd", 999.0)
		var yaw := rng.randf() * TAU
		player.face(player.global_position + Vector3(sin(yaw), 0, -cos(yaw)) * 5.0 + Vector3(0, 1.6, 0))
		await get_tree().physics_frame
		eye.call("_scan")
		var picks: Array = ring.duplicate()
		picks.shuffle()
		picks = picks.slice(0, rng.randi_range(2, 6))
		var react: Dictionary = {}
		for n: Node3D in picks:
			eye.call("_apply", n, 1.3, kinds[rng.randi() % kinds.size()], false)
			var st: Dictionary = (eye.get("_st") as Dictionary)[n.get_instance_id()]
			st["lvl"] = 5
			react[n.get_instance_id()] = true
		var st0: Dictionary = (eye.get("_st") as Dictionary)[(picks[0] as Node3D).get_instance_id()]
		eye.call("_bark", st0)
		var said: Array = eye.get("said")
		if said.is_empty():
			silent += 1
			continue
		spoke += 1
		var who := instance_from_id(int((eye.get("barkers") as Array)[0])) as Node3D
		var key: String = said[0]
		var role: String = (eye.get("said_roles") as Array)[0]
		var why := ""
		if who == null or not is_instance_valid(who):
			why = "konuşan yok"
		elif not react.has(who.get_instance_id()):
			why = "tepki vermeyen konuştu"
		elif not _in_frustum(who):
			why = "konuşan görüş alanında değil"
		elif SideEvents.street_role(who, ctx) != role:
			why = "rol uyuşmuyor %s/%s" % [SideEvents.street_role(who, ctx), role]
		else:
			var my: String = SideEvents.STREET_SPK.get(role, "")
			var ks := SideEvents.street_speaker(key)
			if ks != my and (groups.get(my, "") == "" or groups.get(ks, "") != groups.get(my, "")):
				why = "satırın konuşmacısı (%s) kişinin rolüne (%s) uymuyor: %s" % [ks, role, key]
		if why == "":
			# (g) kart: ad = rol etiketi, portre sahibi = kişi; sonra başkasının sözü öncekini susturur
			hud.street_bark(who, role, key, 3.0)
			if hud.get("last_line_who") != who or hud.get("last_line_name") != SideEvents.role_label(role) or not who.get("talking"):
				why = "kart kişiyle uyuşmuyor"
			else:
				shown_ok += 1
		if why != "":
			viol += 1
			_bad("(f) deneme %d: %s (söz=%s rol=%s)" % [t, why, key, role])
	print("STREETCHECK (f) 100 rastgele olay: söz=%d sessiz=%d ihlal=%d kart_uyumlu=%d" % [spoke, silent, viol, shown_ok])
	if spoke < 25:
		_bad("(f) deneme anlamsız: yalnız %d olayda söz çıktı" % spoke)
	if silent == 0:
		_bad("(f) hiç sessiz kalan olay yok: görüş alanı kuralı denenmedi")
	# (g) tek konuşan: ikinci kişinin sözü birincinin ağzını durdurur; hikâye/diğer satır portre sahibini silmez
	var a := ring[0] as Node3D
	var b := ring[1] as Node3D
	hud.street_bark(a, "TOWNB", "DST_TOWNB_IDLE_1", 3.0)
	await _frames(2)
	hud.street_bark(b, "WOMB", "DST_WOMB_IDLE_1", 3.0, true)
	await _frames(2)
	if a.get("talking") or not b.get("talking") or hud.get("last_line_who") != b:
		_bad("(g) iki kişi aynı anda konuşuyor (a=%s b=%s)" % [str(a.get("talking")), str(b.get("talking"))])
	hud.bark("SPK_SOLDIER", "NPC_CROWD_BYZ_1", 3.0, true)
	await _frames(2)
	if b.get("talking") or hud.get("last_line_who") != null:
		_bad("(g) başka bir satır geldi ama sokak konuşanı susmadı / portre sahibi kaldı")
	# Tepki sözü kapısı: altyazı sürerken, replik/seçim/ara sahne varken söylenmez (gerçek oyun kipinde)
	GameState.autotest = false
	hud.street_bark(a, "TOWNB", "DST_TOWNB_IDLE_2", 3.0, true)
	var gate_talk: bool = eye.call("_can_speak")
	hud.cut_voice(0.01)
	await _frames(2)
	var gate_free: bool = eye.call("_can_speak")
	hud.line_open = true
	var gate_line: bool = eye.call("_can_speak")
	hud.line_open = false
	hud.set_cinematic(true)
	var gate_cine: bool = eye.call("_can_speak")
	hud.set_cinematic(false)
	GameState.autotest = true
	if gate_talk or gate_line or gate_cine or not gate_free:
		_bad("(g) tepki sözü kapısı: altyazı=%s replik=%s ara sahne=%s boşta=%s" % [gate_talk, gate_line, gate_cine, gate_free])
	print("STREETCHECK (g) kart kişiye uyuyor; tek konuşan; kapı altyazı=%s replik=%s ara_sahne=%s boşta=%s" % [gate_talk, gate_line,
		gate_cine, gate_free])
	hud.cut_voice(0.01)
	eye.call("reset_test")
	for n in ring:
		n.queue_free()
	_hold = Vector3.INF
	await _frames(4)

# ---------------------------------------------------------------- (c2) gerçek girdi: zıplama tuşu, telefon kullanımı

func _real_input() -> void:
	var ring := _ring()
	_hold = Vector3.INF
	player.global_position = Vector3(0, 0.05, 0)
	player.face(Vector3(0, 1.6, -5.0))
	await get_tree().create_timer(1.0).timeout
	eye.call("reset_test")
	var floor0 := player.is_on_floor()
	for i in 3:
		Input.action_press("jump")
		await get_tree().process_frame
		await get_tree().physics_frame
		Input.action_release("jump")
		await get_tree().create_timer(0.9).timeout
	var jumps: int = eye.get("counts")["events"]
	eye.call("reset_test")
	if not "phone" in GameState.bag:
		GameState.bag.append("phone")
	player.select_item(GameState.bag.find("phone") + 1)
	await get_tree().create_timer(0.6).timeout
	player._use_held()
	await get_tree().create_timer(1.0).timeout
	var phone: int = eye.get("counts")["events"]
	print("STREETCHECK (c2) gerçek girdi: zıplama olayı=%d (yerde=%s) telefon olayı=%d" % [jumps, floor0, phone])
	if jumps < 3 or phone < 1:
		_bad("gerçek girdi olay üretmedi: zıplama=%d telefon=%d" % [jumps, phone])
	player.select_item(0)
	for n in ring:
		n.queue_free()
	await _frames(4)


# ---------------------------------------------------------------- (d) gizlilik kipi

func _glance() -> void:
	var ring := _ring()
	_hold = Vector3(0, 0.05, 0)
	await _frames(6)
	eye.call("reset_test")
	eye.set("force_mode", "glance")
	await _frames(4)
	var rot := {}
	var looks := {}
	for n: Node3D in ring:
		rot[n] = n.global_rotation.y
		looks[n] = n.get("look_target")
	for kind: String in KINDS:
		eye.call("event", kind, 1.0, ring[0] if kind in ["bump", "stare"] else null)
		await get_tree().create_timer(0.25).timeout
	await get_tree().create_timer(2.0).timeout
	var bad := 0
	for n: Node3D in ring:
		if absf(angle_difference(rot[n], n.global_rotation.y)) > 0.01 or n.get("look_target") != looks[n]:
			bad += 1
	var c: Dictionary = eye.get("counts")
	var only_head := true
	for s: Array in eye.get("steps"):
		if s[1] != 1:
			only_head = false
	var stared := 0
	for n: Node3D in ring:
		var rg = n.get("rig")
		if rg is Rig and (rg as Rig).stare_t > 0.0:
			stared += 1
	if bad > 0 or int(c["turns"]) > 0 or int(c["barks"]) > 0 or int(c["gestures"]) > 0 or not only_head or stared == 0:
		_bad("gizlilik kipi: gövdesi/bakışı değişen=%d sayaçlar=%s yalnız baş=%s bakan=%d" % [bad, str(c), only_head, stared])
	print("STREETCHECK (d) gizlilik kipi: %d kişiden %d başını çevirdi, gövde/bakış değişen=%d, sayaçlar=%s" % [ring.size(),
		stared, bad, str(c)])
	eye.set("force_mode", "full")
	for n in ring:
		n.queue_free()
	_hold = Vector3.INF
	await _frames(4)


# ---------------------------------------------------------------- (e) Bölüm 24 şehri

func _city() -> void:
	GameState.autotest = false          # bölümün kendi otomatik akışı sahneyi kapatmasın
	set_meta("citylife", true)
	var root: Node = (load("res://scenes/chapter24.tscn") as PackedScene).instantiate()
	add_child(root)
	var cl: CityLife = null
	var t := 0.0
	while t < 150.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		for c in root.find_children("CityLife", "Node3D", true, false):
			cl = c as CityLife
		if cl and cl.graph_ready and cl.is_processing() and cl._built >= cl.agents.size():
			break
	if cl == null or not cl.graph_ready:
		_bad("Bölüm 24: CityLife hazır değil")
		return
	player = get_tree().get_first_node_in_group("player") as Player
	hud = get_tree().get_first_node_in_group("hud") as Hud
	eye = hud.street_eye
	eye.set("test_on", true)
	eye.set("force_mode", "full")
	var w := cl.world
	var best := -1
	var bd := INF
	for i in cl.nodes.size():
		var d := Vector2(cl.nodes[i].x + 313.0, cl.nodes[i].z + 930.0).length()
		if d < bd and cl._nstate[i] == 1:
			bd = d
			best = i
	if best < 0:
		_bad("Bölüm 24: açık sokak düğümü yok")
		return
	_hold = w.global_transform * (cl.nodes[best] + Vector3(0, 0.05, 0))
	player.global_position = _hold
	await get_tree().create_timer(3.0).timeout
	# Ölçüm: StreetEye açık (her 0,5 sn bir tuhaflık) / kapalı, art arda iki tur
	var on_us: Array[float] = []
	var off_us: Array[float] = []
	var eye_us: Array[float] = []
	for rr in 2:
		for on in [true, false]:
			eye.set("enabled", on)
			await get_tree().create_timer(0.6).timeout
			cl.prof_sum_us = 0.0
			cl.prof_n = 0
			eye.set("prof_sum_us", 0.0)
			eye.set("prof_n", 0)
			var tt := 0.0
			var fire := 0.0
			while tt < 5.0:
				await get_tree().process_frame
				tt += get_process_delta_time()
				fire -= get_process_delta_time()
				if on and fire <= 0.0:
					fire = 0.5
					eye.call("event", ["jump", "phone", "spin", "selfie"][randi() % 4], 0.5)
			var m := cl.prof_sum_us / maxf(cl.prof_n, 1)
			if on:
				on_us.append(m)
				eye_us.append(float(eye.get("prof_sum_us")) / maxf(float(eye.get("prof_n")), 1.0))
			else:
				off_us.append(m)
	eye.set("enabled", true)
	var on_m := (on_us[0] + on_us[1]) * 0.5
	var off_m := (off_us[0] + off_us[1]) * 0.5
	var eye_m := (eye_us[0] + eye_us[1]) * 0.5
	print("STREETCHECK (e) CityLife µs açık=%s kapalı=%s (ort %.0f / %.0f, fark %+.1f%%) · StreetEye µs=%s ort %.0f" % [str(on_us),
		str(off_us), on_m, off_m, (on_m - off_m) / maxf(off_m, 1.0) * 100.0, str(eye_us), eye_m])
	if eye_m > 150.0:
		_bad("StreetEye kare süresi %.0f µs > 150" % eye_m)
	if on_m > off_m * 1.10 + 30.0:
		_bad("CityLife kare süresi StreetEye açıkken %%%.0f arttı" % ((on_m - off_m) / off_m * 100.0))
	# Yakındaki bir CityLife kişisinin yanına git: konuşma alanı açılır, odak "npc:crowd", rolünün sözü
	var talked := false
	var roles_seen := {}
	for ag in cl.agents:
		if not ag.active or ag.body == null:
			continue
		ag.wait = 6.0
		var b: Node3D = ag.body
		var fwd := b.global_basis.z
		fwd.y = 0.0
		fwd = fwd.normalized()
		_hold = b.global_position + fwd * 1.5 + Vector3(0, 0.05, 0)
		player.global_position = _hold
		player.face(b.global_position + Vector3(0, 1.2, 0))
		var k := 0
		while player.focus_id != "npc:crowd" and k < 40:
			player.frozen = false           # bölümün açılış konuşması oyuncuyu donduruyor: odak donukken gelmez
			await get_tree().physics_frame
			ag.wait = 6.0
			k += 1
		if player.focus_id != "npc:crowd":
			continue
		var who := SideEvents.street_focus(get_tree())
		var ctx := SideEvents.street_ctx(get_tree())
		var role := SideEvents.street_role(who, ctx)
		var key := SideEvents.street_pick(role, ctx, 1)
		roles_seen[role] = SideEvents.prompt("npc:crowd")
		if who == b and role != "" and _both(key):
			talked = true
		if roles_seen.size() >= 4:
			break
	_hold = Vector3.INF
	if not talked:
		_bad("Bölüm 24: CityLife kişisiyle konuşma alanı/odağı gelmedi")
	print("STREETCHECK (e) CityLife ile konuşma: %s istemler=%s" % [talked, str(roles_seen)])
	root.queue_free()
	await _frames(3)


# ---------------------------------------------------------------- ekranlı kanıt kareleri (STREET_SHOTS=klasör)
# xvfb-run ... godot --path . --resolution 1280x720 res://tests/street_check.tscn  (ortamda STREET_SHOTS)

var _dir := ""
var _cur: Node


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("STREETSHOT ", name, " (başsız: kare yok)")
		return
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_jpg(_dir.path_join(name + ".jpg"), 0.85)
	print("STREETSHOT ", name)


## Bölümün açılış kartını, karartmayı ve açık replik kutusunu kaldırır; oyuncu yürür
func _clean() -> void:
	hud.set_fade(0.0)
	hud.clear_card()
	if hud.cinematic:
		hud.set_cinematic(false)
	var sb = hud.get("_sub_box")
	if sb is Control:
		(sb as Control).visible = false
	hud.line_open = false
	player.frozen = false


func _load(ch: String) -> CityLife:
	if _cur:
		_cur.queue_free()
		player = null
		hud = null
		await _frames(4)
	get_viewport().disable_3d = true          # yüklenirken çizim yok (yazılım çiziciyle kare başına saniyeler)
	_cur = (load("res://scenes/chapter%s.tscn" % ch) as PackedScene).instantiate()
	add_child(_cur)
	var cl: CityLife = null
	var t0 := Time.get_ticks_msec()
	var last := 0
	while true:
		await get_tree().process_frame
		var t := (Time.get_ticks_msec() - t0) / 1000.0
		if cl == null:
			for c in _cur.find_children("CityLife", "Node3D", true, false):
				cl = c as CityLife
		if int(t / 20.0) != last:
			last = int(t / 20.0)
			print("STREETSHOT yükleniyor %s: %.0f sn, fps %.1f, gövde %s" % [ch, t, Engine.get_frames_per_second(),
				str(cl._built) if cl else "-"])
		if (t > 20.0 and (cl == null or (cl.graph_ready and cl._built >= cl.agents.size()))) or t > 400.0:
			break
	player = get_tree().get_first_node_in_group("player") as Player
	hud = get_tree().get_first_node_in_group("hud") as Hud
	eye = hud.street_eye
	eye.set("force_mode", "full")
	eye.set("test_on", true)
	get_viewport().disable_3d = false
	get_viewport().scaling_3d_scale = 0.6
	if player.camera:
		player.camera.far = 70.0                 # uzak şehir çizilmesin (yazılım çizici)
	return cl


func _face_to(target: Node3D, dist := 1.7) -> void:
	var fwd := target.global_basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	_hold = target.global_position + fwd * dist + Vector3(0, 0.05, 0)
	player.global_position = _hold
	player.face(target.global_position + Vector3(0, 1.45 * target.scale.y, 0))


func _press_e() -> void:
	var ev := InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	player._unhandled_input(ev)


func _talk_agent(cl: CityLife, kind: String, shot_a: String, shot_b: String) -> bool:
	var pp := player.global_position
	var cands: Array = []
	for ag in cl.agents:
		if ag.active and ag.body != null and (ag.kind == "patrol") == (kind == "patrol") and (kind != "patrol" or ag.slot == 0):
			cands.append(ag)
	cands.sort_custom(func(a, b): return a.body.global_position.distance_to(pp) < b.body.global_position.distance_to(pp))
	for ag in cands.slice(0, 6):
		ag.wait = 30.0
		_face_to(ag.body)
		var k := 0
		while player.focus_id != "npc:crowd" and k < 60:
			_clean()
			ag.wait = 30.0
			await get_tree().physics_frame
			k += 1
		if player.focus_id != "npc:crowd":
			continue
		await get_tree().create_timer(0.4).timeout
		if shot_a != "":
			await _snap(shot_a)
		_press_e()
		await get_tree().create_timer(0.9).timeout
		await _snap(shot_b)
		print("STREETSHOT %s: %s" % [shot_b, SideEvents.street_role(ag.body, SideEvents.street_ctx(get_tree()))])
		await get_tree().create_timer(3.5).timeout
		return true
	print("STREETSHOT %s: uygun kişi bulunamadı" % shot_b)
	return false


func _shots(dir: String) -> void:
	_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	GameState.autotest = false
	set_meta("citylife", true)
	Engine.max_fps = 30
	var cl := await _load("24")
	if cl == null:
		print("STREETSHOT bölüm 24: CityLife yok")
		return
	var w := cl.world
	var best := -1
	var bd := INF
	for i in cl.nodes.size():
		var d := Vector2(cl.nodes[i].x + 479.0, cl.nodes[i].z + 1237.0).length()
		if d < bd and cl._nstate[i] == 1:
			bd = d
			best = i
	_hold = w.global_transform * (cl.nodes[best] + Vector3(0, 0.05, 0))
	player.global_position = _hold
	for i in 40:
		_clean()
		await get_tree().create_timer(0.1).timeout
	var only := OS.has_environment("STREET_ONLY")          # yalnız 06 (zıplama) ve 09 (Ceneviz'e telefon) kareleri
	if not only:
		await _talk_agent(cl, "civ", "01_istem", "02_sivil_cevap")
		await _talk_agent(cl, "patrol", "", "03_devriye")
	# Zıplama: önce / sonra. Kalabalık bir yer (yakında devriye de olan) bulunur, oyuncu en yakın açık sokak düğümüne
	# konur, kalabalığa bakar; kalabalık yerinde durur (bekler) ki karede kalsın
	var center := Vector3.INF
	var best_score := -1
	for a in cl.agents:
		if not a.active:
			continue
		var cnt := 0
		var guard := false
		for b in cl.agents:
			if b.active and b.body.global_position.distance_to(a.body.global_position) < 12.0:
				cnt += 1
				guard = guard or b.kind == "patrol"
		if cnt + (6 if guard else 0) > best_score:
			best_score = cnt + (6 if guard else 0)
			center = a.body.global_position
	# Meydanın ortası (duvardan uzak: zıplama tırmanmaya, telefon duvara tutunmaya gitmesin), kalabalığa en yakın meydan
	var inv := w.global_transform.affine_inverse()
	var lc := inv * center
	var bp := Vector3.INF
	var bdd := INF
	var br := 10.0
	for pl: Dictionary in cl.plazas:
		var pp: Vector3 = pl.get("pos", Vector3.INF)
		var d := Vector2(pp.x - lc.x, pp.z - lc.z).length()
		if d < bdd:
			bdd = d
			bp = pp
			br = float(pl.get("r", 10.0))
	if bdd > 40.0:
		bp = lc
	center = w.global_transform * bp
	var agn := 0
	for ag in cl.agents:
		if ag.active and ag.body.global_position.distance_to(center) < 20.0:
			agn += 1
	print("STREETSHOT meydan: uzaklık %.0f m, yakındaki kişi %d" % [bdd, agn])
	# Meydanın ortasında anıt olabilir: kalabalığa doğru yarıçapın yarısı kadar kenara
	var toward := Vector3(lc.x - bp.x, 0, lc.z - bp.z)
	if toward.length() > 0.5:
		bp += toward.normalized() * minf(br * 0.5, toward.length())
	bp.y = cl._surf(bp.x, bp.z)
	_hold = w.global_transform * (bp + Vector3(0, 0.05, 0))
	var cc := Vector3.ZERO
	var cn := 0
	for ag in cl.agents:
		if ag.active and ag.body.global_position.distance_to(_hold) < 20.0:
			cc += ag.body.global_position
			cn += 1
	if cn > 0:
		center = cc / cn
	# Kalabalık uzaktaysa (söz için yeterli dikkat toplanmaz) en yakın kişinin 5,5 m önüne gelinir
	var near_b: Node3D = null
	for ag in cl.agents:
		if ag.active and ag.kind != "patrol" and ag.body != null and (near_b == null or ag.body.global_position.distance_to(_hold) < near_b.global_position.distance_to(_hold)):
			near_b = ag.body
	if near_b != null and near_b.global_position.distance_to(_hold) > 7.0:
		var away := Vector3(_hold.x - near_b.global_position.x, 0, _hold.z - near_b.global_position.z).normalized()
		_hold = near_b.global_position + away * 5.5 + Vector3(0, 0.05, 0)
		center = near_b.global_position
	player.global_position = _hold
	player.face(center + Vector3(0, 1.2, 0))
	for ag in cl.agents:
		if ag.active and ag.body.global_position.distance_to(_hold) < 20.0:
			ag.wait = 60.0
	print("STREETSHOT tırmanma=%s pinned=%s mode=%s down=%s aynı_oyuncu=%s bağlı=%s oyuncu_sayısı=%d hud_sayısı=%d" % [player.can_climb,
		player.pinned, player.move_mode, player.is_down, eye.get("_player") == player,
		player.item_used.get_connections().size(), get_tree().get_nodes_in_group("player").size(),
		get_tree().get_nodes_in_group("hud").size()])
	player.can_climb = false             # meydanda tırmanılacak duvar yok; zıplama tırmanmaya gitmesin
	eye.call("reset_test")
	await get_tree().create_timer(1.5).timeout
	_hold = Vector3.INF                   # yere otursun (zıplamak için)
	await get_tree().create_timer(1.5).timeout
	_clean()
	await _snap("05_zipla_once")
	hud.set("last_line_who", null)
	hud.set("last_line_name", "")
	for i in 4:
		_clean()
		var fl := player.is_on_floor()
		Input.action_press("jump")
		await get_tree().process_frame
		await get_tree().physics_frame
		Input.action_release("jump")
		await get_tree().create_timer(0.7).timeout
		print("STREETSHOT zıplama %d: yerde=%s donuk=%s y=%.2f olay=%s" % [i, fl, player.frozen, player.global_position.y,
			str(eye.get("counts")["events"])])
	# Birinin sözü altyazıya çıkana kadar (en çok 14 sn; sessizse yine zıplanır) bekle, çıkınca hemen çek
	var wt := 0.0
	while hud.get("last_line_who") == null and wt < 14.0:
		_clean()
		if int(wt) % 4 == 3:
			Input.action_press("jump")
			await get_tree().process_frame
			await get_tree().physics_frame
			Input.action_release("jump")
		await get_tree().create_timer(0.5).timeout
		wt += 0.5
	await get_tree().create_timer(0.4).timeout
	var lw = hud.get("last_line_who")
	if lw is Node3D:
		var lwn := lw as Node3D
		print("STREETSHOT 06 konuşan: rol=%s ad=%s kadrajda=%s uzaklık=%.1f portre_gizli=%s" % [SideEvents.street_role(lwn, SideEvents.street_ctx(get_tree())),
			tr(str(hud.get("last_line_name"))), _in_frustum(lwn), lwn.global_position.distance_to(player.global_position),
			not (hud.get("_portrait") as TextureRect).visible])
	else:
		print("STREETSHOT 06 konuşan: kimse söylemedi (yalnız jest)")
	await _snap("06_zipla_sonra")
	var looking := 0
	for ag in cl.agents:
		if ag.active and (ag.look > 0.0 or (ag.rig and ag.rig.stare_t > 0.0)):
			looking += 1
	print("STREETSHOT 06_zipla_sonra: bakan %d kişi, sözler %s sayaç %s konuşuyor=%s replik=%s" % [looking,
		str(eye.get("said")), str(eye.get("counts")), hud.is_talking(), hud.line_open])
	print("STREETSHOT tanı: yakın=%d bekleyen=%d durum=%d kip=%s fps=%.1f" % [(eye.get("_near") as Array).size(),
		(eye.get("_pending") as Array).size(), (eye.get("_st") as Dictionary).size(), eye.get("mode"), Engine.get_frames_per_second()])
	# Telefon (Tolga'nın kendi eylemi: fener)
	await get_tree().create_timer(8.0).timeout
	eye.call("reset_test")
	if not only and not "phone" in GameState.bag:
		GameState.bag.append("phone")
	var pi := GameState.bag.find("phone")
	if pi >= 0 and not only:
		player.select_item(pi + 1)
		await get_tree().create_timer(1.0).timeout
		_clean()
		print("STREETSHOT telefon: elde=%s meşgul=%s" % [player.held_item(), player.get("_item_busy")])
		player._use_held()
		await get_tree().create_timer(2.0).timeout
		player._use_held()              # ikinci kez: yakındakiler söylenir
		await get_tree().create_timer(2.2).timeout
		await _snap("07_telefon")
		print("STREETSHOT 07_telefon: sözler %s sayaç %s" % [str(eye.get("said")), str(eye.get("counts"))])
	# Nöbetçi uyarısı: art arda tuhaflık
	await get_tree().create_timer(8.0).timeout
	# Devriyenin önüne (7 m): uyarıyı nöbetçi verir
	var lead = null
	var ld := INF
	for ag in cl.agents:
		if ag.active and ag.kind == "patrol" and ag.slot == 0 and ag.body.global_position.distance_to(player.global_position) < ld:
			ld = ag.body.global_position.distance_to(player.global_position)
			lead = ag
	if lead != null and not only:
		lead.wait = 60.0
		for f in lead.squad.slice(1):
			if f is Object:
				f.set("wait", 60.0)
		_face_to(lead.body, 7.0)
		await get_tree().create_timer(2.0).timeout
	eye.call("reset_test")
	eye.set("_warn_cd", 0.0)
	var warned := false
	for i in (0 if only else 12):
		_clean()
		eye.call("event", "spin", 0.8)
		await get_tree().create_timer(0.4).timeout
		for k: String in eye.get("said"):
			if k.begins_with("DST_WARN_"):
				warned = true
		if warned:
			break
	await get_tree().create_timer(0.8).timeout
	if not only:
		await _snap("08_uyari")
	print("STREETSHOT 08_uyari: %s %s sayaç %s" % [warned, str(eye.get("said")), str(eye.get("counts"))])
	# Ceneviz paralı askerine telefon göster: satır kalabalık satırı, ad "Ceneviz paralı askeri"
	var gen = null
	for ag in cl.agents:
		if ag.active and ag.kind == "patrol" and ag.body != null and not (ag.body is Soldier) and str(ag.body.get("armor")) == "mail":
			if gen == null or ag.body.global_position.distance_to(player.global_position) < gen.body.global_position.distance_to(player.global_position):
				gen = ag
	if gen == null:
		print("STREETSHOT 09_ceneviz_telefon: Ceneviz askeri bulunamadı")
	else:
		eye.call("reset_test")
		var pi2 := GameState.bag.find("phone")
		if pi2 < 0:
			GameState.bag.append("phone")
			pi2 = GameState.bag.find("phone")
		player.select_item(pi2 + 1)
		for use in 2:
			var kk := 0
			while kk < 90 and (kk == 0 or player.focus_id != "npc:crowd"):
				_clean()
				gen.wait = 60.0
				_face_to(gen.body, 1.7)
				await get_tree().physics_frame
				kk += 1
			await get_tree().create_timer(0.6).timeout
			_clean()
			print("STREETSHOT 09 odak=%s rol=%s elde=%s" % [player.focus_id, SideEvents.street_role(gen.body, SideEvents.street_ctx(get_tree())), player.held_item()])
			player._use_held()
			await get_tree().create_timer(1.2 if use == 0 else 0.8).timeout
		print("STREETSHOT 09 kart: ad=%s sahibi_gen=%s portre_gizli=%s" % [tr(str(hud.get("last_line_name"))), hud.get("last_line_who") == gen.body,
			not (hud.get("_portrait") as TextureRect).visible])
		await _snap("09_ceneviz_telefon")
		player.select_item(0)
	# Ordugâh: Bölüm 10, askerle konuşma
	if only:
		return
	_hold = Vector3.INF
	await _load("10")
	for i in 30:
		_clean()
		await get_tree().create_timer(0.1).timeout
	var ctx := SideEvents.street_ctx(get_tree())
	var done := false
	for g: String in ["soldiers", "persons"]:
		for x in get_tree().get_nodes_in_group(g):
			var n := x as Node3D
			if done or n == null or not n.is_visible_in_tree() or not SideEvents.street_role(n, ctx) in ["OSMSOL", "JAN", "AZAP"]:
				continue
			_face_to(n, 1.6)
			var k := 0
			while player.focus_id != "npc:crowd" and k < 45:
				_clean()
				await get_tree().physics_frame
				k += 1
			if player.focus_id != "npc:crowd":
				continue
			await get_tree().create_timer(0.3).timeout
			await _snap("04_ordugah_istem")
			_press_e()
			await get_tree().create_timer(0.9).timeout
			await _snap("04_ordugah_cevap")
			print("STREETSHOT 04_ordugah: %s %s" % [SideEvents.street_role(n, ctx), n.name])
			done = true
	if not done:
		print("STREETSHOT 04_ordugah: uygun asker bulunamadı")
