extends Node3D
## Akıcılık denetimi: oyuncu düz zeminde yürür, ekran fizik adımından hızlı çizilir (--max-fps 144, fizik 60 Hz).
## Kameranın her karedeki ilerlemesi ölçülür: adımlar düzgünse kamera kaygan (ara değerleme), fizik adımı olmayan
## karelerde yerinde sayıyorsa titrek. SMOOTHCHECK PASS: kare başına ilerlemenin değişim katsayısı < 0,35.
##   godot --headless --max-fps 144 --path . res://tests/smooth_check.tscn

var steps: Array[float] = []
var last := Vector3.INF
var p: Player
var sampling := false


func _process(_d: float) -> void:
	if not sampling:
		return
	var c := p.camera.global_position
	if last != Vector3.INF:
		steps.append(Vector2(c.x - last.x, c.z - last.z).length())
	last = c


func _ready() -> void:
	GameState.autotest = true
	var floor := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(200, 0.2, 200)
	cs.shape = bs
	floor.add_child(cs)
	floor.position = Vector3(0, -0.1, 0)
	add_child(floor)
	p = Player.new()
	add_child(p)
	p.global_position = Vector3(0, 0.05, 0)
	_run.call_deferred()


func _run() -> void:
	await get_tree().create_timer(0.8).timeout
	Input.action_press("move_forward")
	await get_tree().create_timer(0.6).timeout
	var t0 := Time.get_ticks_msec()
	# Örnek, bütün _process'lerden sonra çalışan düğümde alınır (çizilen kamera): process_frame sinyali _process'lerden
	# önce gelir, o anda fizik yazmış ama ara değerleme uygulanmamış kamera görünür
	sampling = true
	process_priority = 1000
	while Time.get_ticks_msec() - t0 < 2500:
		await get_tree().process_frame
	sampling = false
	Input.action_release("move_forward")
	var mean := 0.0
	for s in steps:
		mean += s
	mean /= maxf(1.0, steps.size())
	var v := 0.0
	for s in steps:
		v += (s - mean) * (s - mean)
	var cv := sqrt(v / maxf(1.0, steps.size())) / maxf(mean, 0.000001)
	var zero := steps.filter(func(s: float): return s < mean * 0.2).size()
	print("SMOOTHCHECK frames=%d mean_step=%.4f cv=%.2f still_frames=%d" % [steps.size(), mean, cv, zero])
	print("SMOOTHCHECK %s" % ("PASS" if cv < 0.35 and steps.size() > 60 else "FAIL"))
	get_tree().quit(0 if cv < 0.35 else 1)
