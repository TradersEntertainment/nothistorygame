class_name Chaos
extends Node
## Kaos botu (v0.99.22, --chaos=TOHUM): bölümün kendi test botu (--autotest) ilerlerken araya "yaramaz oyuncu"
## girdileri sokar: yanlış anda zıplar, eli boşaltır, çantayı/haritayı açıp kapar, fesi çıkarır, tekme atar, döner,
## duraklatıp sürdürür, etkileşime basar. Amaç: düz yolu oynayan testin göremediği hatalar (kaybolan kılıç, elde kalan
## eşya, açık kalan menü, takılan akış). Bulgu aynı tohumla yeniden üretilir; her girdi "CHAOS t=.. act=.." diye yazılır.
## Denetimler (VISAUDIT, HELDAUDIT, ARMAUDIT, WARN_VOID_TELEPORT, SCRIPT ERROR) ve AUTOTEST PASS koşulu aynen geçerli.

const ACTS := ["jump", "hands_free", "bag", "map", "fez", "kick", "sprint", "turn", "pause", "interact", "use_item", "outfit"]

var rng := RandomNumberGenerator.new()
var _t := 3.0
var _clock := 0.0
var _release: Array = []          # [kalan süre, eylem]: basılı tutulan eylemi bırak
var _reopen: Array = []           # [kalan süre, eylem]: açılan menüyü kapat (ikinci basış)


func _init(seed_v: int) -> void:
	rng.seed = seed_v
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "Chaos"


var _last_ms := 0


func _process(_delta: float) -> void:
	# Gerçek saat: oyun durduğunda ya da ağır çekimde (Fx, zaman ölçeği 0,02) da menüyü kapatabilsin; oyunun delta'sıyla
	# sayınca harita bir vuruş anında açıldığında kapatma girdisi dakikalarca gecikiyor, test boşuna takılıyordu
	var now := Time.get_ticks_msec()
	var delta := 0.0 if _last_ms == 0 else minf((now - _last_ms) / 1000.0, 0.25)
	_last_ms = now
	_clock += delta
	for i in range(_release.size() - 1, -1, -1):
		_release[i][0] -= delta
		if _release[i][0] <= 0.0:
			_send(_release[i][1], false)
			_release.remove_at(i)
	for i in range(_reopen.size() - 1, -1, -1):
		_reopen[i][0] -= delta
		if _reopen[i][0] <= 0.0:
			_tap(_reopen[i][1])
			_reopen.remove_at(i)
	if get_tree().paused and _reopen.is_empty():
		return                          # duraklatma menüsünü kendisi açmadıysa (bölümün kendi duruşu) karışmaz
	_t -= delta
	if _t > 0.0:
		return
	_t = rng.randf_range(1.5, 4.0)
	var sc := get_tree().current_scene
	if sc == null or not (sc.get("player") is Player):
		return
	var act: String = ACTS[rng.randi() % ACTS.size()]
	print("CHAOS t=%.1f act=%s scene=%s" % [_clock, act, sc.scene_file_path.get_file()])
	match act:
		"turn":
			var p: Player = sc.get("player")
			var ev := InputEventMouseMotion.new()
			ev.relative = Vector2(rng.randf_range(-600, 600), rng.randf_range(-150, 150))
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and p.is_inside_tree():
				Input.parse_input_event(ev)
		"bag", "map", "pause":
			_tap(act)
			_reopen.append([rng.randf_range(0.4, 1.6), act])
		"sprint":
			_send(act, true)
			_release.append([rng.randf_range(0.5, 2.0), act])
		_:
			_tap(act)


func _tap(act: String) -> void:
	_send(act, true)
	_release.append([0.06, act])


func _send(act: String, pressed: bool) -> void:
	if not InputMap.has_action(act):
		return
	var ev := InputEventAction.new()
	ev.action = act
	ev.pressed = pressed
	Input.parse_input_event(ev)
