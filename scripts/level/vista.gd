class_name Vista
extends Node3D
## Seyir noktası: yüksek bir yere (çatı sırtı, kule) çıkan oyuncu E'ye basınca kamera şehrin üstünde süzülür,
## Tolga kısa bir şey söyler. Uzaktan görünsün diye noktanın üstünde güvercinler döner.
## Bulunanlar oyunlar arasında saklanır (GameState.stats["vista_<anahtar>_<n>"]).
##   Vista.make(sahne, "6b", 1, konum, bakış, "D6B_T_VISTA_1")

signal seen(id: String)

const REACH := 1.6

var id := ""
var look := Vector3.ZERO
var line := ""
var done := false
var _player: Player
var _hud: Hud
var _birds: Node3D
var _t := 0.0
var _busy := false
var _prompted := false


static func make(scene: Node3D, key: String, n: int, at: Vector3, look_at_point: Vector3, line_key: String) -> Vista:
	var v := Vista.new()
	v.id = "vista_%s_%d" % [key, n]
	v.look = look_at_point
	v.line = line_key
	v._player = scene.player
	v._hud = scene.hud
	scene.add_child(v)
	v.global_position = at
	v.done = int(GameState.stats.get(v.id, 0)) > 0 and not GameState.autotest
	v._build()
	return v


static func count(key: String, total: int) -> int:
	var n := 0
	for i in range(1, total + 1):
		if int(GameState.stats.get("vista_%s_%d" % [key, i], 0)) > 0:
			n += 1
	return n


func _build() -> void:
	# Taş işaret (küçük haç taşı) ve üstünde dönen üç güvercin
	Props.box(self, Vector3(0.18, 0.5, 0.12), Vector3(0, 0.25, 0), Color("d8d0c0"))
	Props.box(self, Vector3(0.4, 0.1, 0.12), Vector3(0, 0.38, 0), Color("d8d0c0"))
	_birds = Node3D.new()
	_birds.position = Vector3(0, 3.0, 0)
	add_child(_birds)
	for k in 3:
		var b := Node3D.new()
		_birds.add_child(b)
		var a := TAU * k / 3.0
		b.position = Vector3(cos(a) * 1.4, sin(a * 2.0) * 0.2, sin(a) * 1.4)
		Props.ball(b, 0.1, Vector3.ZERO, Color("e8e8e8"), Vector3(1.0, 0.7, 1.6), 6)
		Props.box(b, Vector3(0.5, 0.02, 0.14), Vector3(0, 0.03, 0), Color("d8d8d8"))
	_birds.visible = not done


func _process(delta: float) -> void:
	_t += delta
	if _birds:
		_birds.rotation.y = _t * 0.9
	if done or _busy or not is_instance_valid(_player):
		return
	var near := _player.global_position.distance_to(global_position) < REACH
	if near and not _player.frozen:
		_hud.set_prompt(tr("UI_VISTA_PROMPT"))
		_prompted = true
		if Input.is_action_just_pressed("interact") or GameState.autotest:
			_view()
	elif _prompted:
		_prompted = false
		_hud.set_prompt("")


## Kamera oyuncunun gözünden yükselip bakış noktasına doğru süzülür, geri iner
func _view() -> void:
	_busy = true
	_hud.set_prompt("")
	var cam := _player.camera
	var was_frozen := _player.frozen
	_player.frozen = true
	var from := cam.global_transform
	var high := from.origin + Vector3(0, 3.5, 0)
	var dir := (look - high).normalized()
	var to := Transform3D(Basis.looking_at(dir, Vector3.UP), high)
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_method(func(k: float): cam.global_transform = from.interpolate_with(to, k), 0.0, 1.0, 1.4)
	await tw.finished
	Audio.sfx("whoosh_fly", -14.0, 0.7)
	_hud.bark("SPK_TOLGA", line, 3.5)
	# Bakışta yavaşça döner
	var t2 := create_tween().set_trans(Tween.TRANS_SINE)
	var side := Transform3D(Basis.looking_at(dir.rotated(Vector3.UP, 0.35), Vector3.UP), high + Vector3(0, 0.4, 0))
	t2.tween_method(func(k: float): cam.global_transform = to.interpolate_with(side, k), 0.0, 1.0, 2.6)
	await t2.finished
	var back := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	back.tween_method(func(k: float): cam.global_transform = side.interpolate_with(from, k), 0.0, 1.0, 1.0)
	await back.finished
	cam.global_transform = from
	_player.frozen = was_frozen
	done = true
	_birds.visible = false
	GameState.bump_stat(id, 1, true)
	Audio.stinger("banner", -10.0)
	seen.emit(id)
	_busy = false
