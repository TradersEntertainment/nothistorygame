class_name TespitCam
extends Control
## Tespit karesi (Perde IV): Büro'nun tespit makinesi (Nihat'ın verdiği Z-0) elde durur. Hedef nişangâhın çevresindeki
## koniye girince makine göze kalkar, vizör açılır; etkileşim tuşuyla deklanşöre basılır: flaş patlar, kare albüme ve
## Hasar Tespit Dosyası'na gider, makinenin yuvasından baskı çıkar. Baskı çıkınca makine iner; `done` ve `taken` ancak
## o zaman gelir (bölüm hemen stop() derse baskı yarıda kesilmesin).
## Hedefin kadrajda olup olmadığını denetler: yanlış yöne çekilen fotoğraf sayılmaz.

signal taken(path: String)
signal shutter

var player: Player
var hud: Hud
var target: Node3D
var who := ""
var max_dist := 80.0
var cone_deg := 9.0
var active := false
var done := false
var _in := false
var _far := false                    # hedef konide ama menzil dışında: vizör kırmızı, deklanşör kapalı
var _dist := 0.0
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
		_audit_frame()
		_shoot.call_deferred()
		return
	if _player_ok():
		player.camera_hold(true)


func stop() -> void:
	active = false
	_in = false
	if _player_ok():
		player.camera_hold(false)
	queue_redraw()


func _exit_tree() -> void:
	if active and _player_ok():
		player.camera_hold(false)


## Test: bölümün oyuncuyu koyduğu yerden hedefle göz arasında görünen bir engel var mı (önde duran tayfa, sandık,
## duvar). Kart kamerasının engel denetimi (LivePortrait.blocker) burada oyuncunun gözüyle: kişiler hem oyuncunun hem
## hedefin çevresinden toplanır. Yalnız bilgi verir (TESPITBLOCK); oyuncu yerinden oynayıp kareyi açabilir.
func _audit_frame() -> void:
	if target == null or not is_instance_valid(target) or not _player_ok() or not target.is_inside_tree():
		return
	var subj := target.get_parent() as Node3D
	if subj == null:
		return
	var eye := player.camera.global_position
	var head := target.global_position
	var people: Array = []
	for g: String in ["persons", "soldiers", "persons_hikmet"]:
		for q in get_tree().get_nodes_in_group(g):
			var pn := q as Node3D
			if pn == null or pn == subj or pn.is_ancestor_of(subj) or subj.is_ancestor_of(pn) or not pn.is_visible_in_tree() \
					or pn.is_queued_for_deletion() or pn.has_meta("corpse"):
				continue
			if pn.global_position.distance_to(eye) < 8.0 or pn.global_position.distance_to(head) < 4.0:
				people.append(pn)
	var b := LivePortrait.blocker(subj, eye, head, people)
	if b != null:
		var at := (b as Node3D).global_position if b is Node3D else Vector3.ZERO
		var kind: String = b.get_script().resource_path.get_file().get_basename() if b.get_script() else b.get_class()
		print("TESPITBLOCK who=%s blocker=%s/%s (%s) at=%s eye=%s dist=%.1f" % [who, b.get_parent().name if b.get_parent() else "",
			b.name, kind, at.snapped(Vector3.ONE * 0.1), eye.snapped(Vector3.ONE * 0.1), eye.distance_to(head)])


func _player_ok() -> bool:
	return player != null and is_instance_valid(player) and player.is_inside_tree()


func in_frame() -> bool:
	return _aim() == 2


## 0: hedef kadraj dışında, 1: konide ama çok uzak, 2: kadrajda (çekilebilir).
func _aim() -> int:
	if target == null or not is_instance_valid(target) or player == null:
		return 0
	var cam := player.camera
	var to := target.global_position - cam.global_position
	var fwd := -cam.global_transform.basis.z
	if rad_to_deg(fwd.angle_to(to.normalized())) >= cone_deg:
		return 0
	_dist = to.length()
	return 1 if _dist > max_dist else 2


func _process(delta: float) -> void:
	_t += delta
	if _busy:
		return
	if not active or done:
		if _in or _far:
			_in = false
			_far = false
			queue_redraw()
		return
	var aim := _aim()
	var now := aim == 2
	var far := aim == 1
	if now != _in or far != _far:
		_in = now
		_far = far
		hud.set_prompt(tr("UI_PROMPT_TESPIT") if now else (tr("UI_PROMPT_TESPIT_FAR") % int(max_dist) if far else ""))
		if _player_ok():
			# Uzak hedefte makine yakınlaştırır (29'da 80 m'deki Sultan karede seçilsin): 8 m'de 0,86, 60 m'de 0,5
			player.camera_raise(now or far, lerpf(0.86, 0.5, clampf((_dist - 8.0) / 52.0, 0.0, 1.0)))
	queue_redraw()
	if _in and not _busy and Input.is_action_just_pressed("interact"):
		_shoot()


func _shoot() -> void:
	if _busy or done:
		return
	_busy = true
	hud.set_prompt("")
	var real := not GameState.autotest and _player_ok()
	shutter.emit()
	if real:
		player.camera_flash()
		player.camera_visible(false)
	var path: String = await hud.snap_photo(who, not real)
	_in = false
	_far = false
	queue_redraw()
	if real and _player_ok():
		player.camera_visible(true)
		player.camera_eject(hud.last_snap)
		await get_tree().create_timer(1.8).timeout        # makine dönsün, baskı yuvadan çıksın, kare belirsin
		if _player_ok():
			player.camera_hold(false)
		hud.show_polaroid(who)                            # makine inince köşede baskının kendisi
	done = true
	active = false
	_busy = false
	taken.emit(path)


## Vizör: dışı kararır, köşe çizgileri, üçte bir ızgarası, merkez artısı, kayıt noktası ve dosyadaki kare sayısı.
func _draw() -> void:
	if not (_in or _far):
		return
	var vs := size
	var w := minf(vs.y * 0.66, vs.x * 0.7)
	var h := w * 0.74
	var r := Rect2((vs - Vector2(w, h)) * 0.5 - Vector2(0, vs.y * 0.05), Vector2(w, h))
	var dark := Color(0, 0, 0, 0.4)
	draw_rect(Rect2(0, 0, vs.x, r.position.y), dark)
	draw_rect(Rect2(0, r.end.y, vs.x, vs.y - r.end.y), dark)
	draw_rect(Rect2(0, r.position.y, r.position.x, h), dark)
	draw_rect(Rect2(r.end.x, r.position.y, vs.x - r.end.x, h), dark)
	var c := Color(1, 1, 1, 0.78 + 0.22 * sin(_t * 6.0))
	if _far:
		c = Color(1, 0.42, 0.36, 0.85)
	var k := 28.0
	for corner in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
		var sx := 1.0 if corner.x < vs.x * 0.5 else -1.0
		var sy := 1.0 if corner.y < r.get_center().y else -1.0
		draw_line(corner, corner + Vector2(k * sx, 0), c, 3.0)
		draw_line(corner, corner + Vector2(0, k * sy), c, 3.0)
	var faint := Color(1, 1, 1, 0.16)
	for i: int in [1, 2]:
		var x: float = r.position.x + w * i / 3.0
		var y: float = r.position.y + h * i / 3.0
		draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), faint, 1.0)
		draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), faint, 1.0)
	var mid := r.get_center()
	draw_line(mid - Vector2(11, 0), mid + Vector2(11, 0), c, 1.5)
	draw_line(mid - Vector2(0, 11), mid + Vector2(0, 11), c, 1.5)
	var font := ThemeDB.fallback_font
	var back := Color(0, 0, 0, 0.45)                     # yazılar açık gökte, denizde de okunsun
	draw_rect(Rect2(r.position + Vector2(10, 10), Vector2(64, 24)), back)
	draw_circle(r.position + Vector2(22, 22), 6.0, Color(1, 0.25, 0.2, c.a))
	draw_string(font, r.position + Vector2(36, 28), "Z-0", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, c)
	var label := tr("UI_CAM_TEST")
	if _far:
		label = tr("UI_CAM_FAR") % int(_dist)
	elif who != "siege_test":
		label = "%s %d/%d" % [tr("UI_CAM_FRAME"), mini(Siege.page_count() + 1, Siege.page_total()), Siege.page_total()]
	var lw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	draw_rect(Rect2(Vector2(r.end.x - lw - 26, r.end.y - 34), Vector2(lw + 16, 24)), back)
	draw_string(font, Vector2(r.end.x - lw - 18, r.end.y - 16), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, c)
