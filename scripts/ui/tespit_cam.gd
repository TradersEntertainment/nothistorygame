class_name TespitCam
extends Control
## Tespit karesi (Perde IV): hedef nişangâhın çevresindeki koniye girince vizör köşeleri belirir;
## etkileşim tuşuyla telefon fotoğrafı çekilir, albüme ve Hasar Tespit Dosyası'na gider.
## Hedefin kadrajda olup olmadığını denetler: yanlış yöne çekilen fotoğraf sayılmaz.

signal taken(path: String)

var player: Player
var hud: Hud
var target: Node3D
var who := ""
var max_dist := 80.0
var cone_deg := 9.0
var active := false
var done := false
var _in := false
var _t := 0.0
var _busy := false


func _init(p_player: Player, p_hud: Hud, p_target: Node3D, p_who: String) -> void:
	player = p_player
	hud = p_hud
	target = p_target
	who = p_who


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func start() -> void:
	active = true
	done = false
	if GameState.autotest:
		_shoot.call_deferred()


func stop() -> void:
	active = false
	_in = false
	queue_redraw()


func in_frame() -> bool:
	if target == null or not is_instance_valid(target) or player == null:
		return false
	var cam := player.camera
	var to := target.global_position - cam.global_position
	if to.length() > max_dist:
		return false
	var fwd := -cam.global_transform.basis.z
	return rad_to_deg(fwd.angle_to(to.normalized())) < cone_deg


func _process(delta: float) -> void:
	_t += delta
	if not active or done:
		if _in:
			_in = false
			queue_redraw()
		return
	var now := in_frame()
	if now != _in:
		_in = now
		hud.set_prompt(tr("UI_PROMPT_TESPIT") if now else "")
	queue_redraw()
	if _in and not _busy and Input.is_action_just_pressed("interact"):
		_shoot()


func _shoot() -> void:
	if _busy or done:
		return
	_busy = true
	hud.set_prompt("")
	var path: String = await hud.snap_photo(who)
	done = true
	active = false
	_in = false
	_busy = false
	queue_redraw()
	taken.emit(path)


func _draw() -> void:
	if not _in:
		return
	var vs := size
	var w := vs.y * 0.42
	var h := w * 0.66
	var r := Rect2((vs - Vector2(w, h)) * 0.5, Vector2(w, h))
	var c := Color(1, 1, 1, 0.75 + 0.25 * sin(_t * 6.0))
	var k := 26.0
	for corner in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
		var sx := 1.0 if corner.x < vs.x * 0.5 else -1.0
		var sy := 1.0 if corner.y < vs.y * 0.5 else -1.0
		draw_line(corner, corner + Vector2(k * sx, 0), c, 3.0)
		draw_line(corner, corner + Vector2(0, k * sy), c, 3.0)
	draw_circle(r.position + Vector2(18, 18), 6.0, Color(1, 0.25, 0.2, c.a))
