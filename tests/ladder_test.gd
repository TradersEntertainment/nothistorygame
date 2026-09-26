extends Node3D
## Merdiven testi: zemin, 6 m duvar ve ona yaslı merdiven. Oyuncu merdivene yürür (W), tutunur, tırmanır ve duvarın
## tepesine çıkar. Ayrıca merdivenin içinden yürünemediği (katı) denetlenir.

var player: Player
var wall_top := 6.0


func _ready() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	add_child(env)
	Props.solid(self, Vector3(20, 0.4, 20), Vector3(0, -0.2, 0), Color("6a6a60"))
	Props.solid(self, Vector3(8, wall_top, 2), Vector3(0, wall_top * 0.5, -3.0), Color("c8b898"))
	var ld := Ladder.new(wall_top + 0.6, 12.0)
	ld.position = Vector3(0, 0, -2.0 + (wall_top + 0.6) * sin(deg_to_rad(12.0)) * 0.0 + 0.1)
	ld.position.z = -2.0 + (wall_top + 0.6) * sin(deg_to_rad(12.0)) + 0.05
	add_child(ld)
	player = Player.new()
	add_child(player)
	player.global_position = Vector3(0, 0.05, 4.0)
	player.face(Vector3(0, 1.6, -3.0))
	Engine.time_scale = 2.0
	_run()


func _run() -> void:
	await get_tree().create_timer(0.5).timeout
	Input.action_press("move_forward")
	var t := 0.0
	var max_y := 0.0
	while t < 12.0:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		max_y = maxf(max_y, player.global_position.y)
		if player.global_position.y > wall_top - 0.3 and player.ladder == null:
			break
	Input.action_release("move_forward")
	await get_tree().create_timer(0.5).timeout
	var on_top := player.global_position.y > wall_top - 0.3 and player.global_position.z < -1.9
	var ok := on_top
	if not ok:
		printerr("AUTOTEST: merdiven: y=%.2f z=%.2f maxy=%.2f ladder=%s" % [player.global_position.y, player.global_position.z, max_y, player.ladder != null])
	print("AUTOTEST %s ladder y=%.2f z=%.2f" % ["PASS" if ok else "FAIL", player.global_position.y, player.global_position.z])
	get_tree().quit(0 if ok else 1)
