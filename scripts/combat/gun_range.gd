class_name GunRange
extends RefCounted
## Tüfek sahnesi (hikâye ve arena): oyuncu Handgun'la hedeflere ateş eder; sahne sonucu döndürür.
## Bölüm oyuncuyu yerine koyar ve sonra geri alır (saat durdurma, ışınlama bölümde kalır).
##
## spec:
##   "runners": [{"coat", "hat", "path": [Vector3...], "delay": sn, "ladder": bool}]   koşarak yaklaşan (yolun sonuna varan kaçar; ladder: omzunda merdiven)
##   "peek":    [{"coat", "hat", "pos", "face", "phase": sn}]            mazgalda görünüp saklanan (yerinde durur)
##   "targets": [Node3D...]   sahnenin kendi hareket ettirdiği hedefler (ör. gemideki tayfa); GunRange onları silmez
##   "ground":  Callable (x, z) -> y   koşanların zemini (yoksa yol noktasının y'si)
##   "shots": 4, "limit": 25.0, "speed": 2.1, "objective": metin, "look": Vector3 (hedef işareti)
## Döner: {"shots", "hits", "missed", "reached"}

const PEEK_UP := 2.2          # mazgalda görünme süresi
const PEEK_DOWN := 1.6        # siperin ardında saklanma
const PEEK_DROP := 1.0        # saklanırken ne kadar çöker (m)


static func run(scene: Node3D, hud: Hud, player: Player, spec: Dictionary) -> Dictionary:
	var men: Array = []
	for r: Dictionary in spec.get("runners", []):
		var s := _man(scene, r)
		s.set_meta("path", r["path"])
		s.set_meta("t", -float(r.get("delay", 0.0)))
		s.visible = false
		men.append(s)
	for r: Dictionary in spec.get("peek", []):
		var s := _man(scene, r)
		s.global_position = r["pos"]
		s.face_toward(r.get("face", player.global_position))
		s.set_meta("base", r["pos"])
		s.set_meta("t", float(r.get("phase", 0.0)))
		s.set_meta("peek", true)
		men.append(s)
	var ext: Array = (spec.get("targets", []) as Array).filter(func(n): return is_instance_valid(n) and n.visible)
	var was_frozen := player.frozen
	player.frozen = false
	var gun := Handgun.new()
	scene.add_child(gun)
	gun.targets = func() -> Array: return men + ext
	gun.begin(player, hud)
	var shots: int = spec.get("shots", 4)
	var limit: float = spec.get("limit", 25.0)
	var speed: float = spec.get("speed", 2.1)
	var ground: Callable = spec.get("ground", Callable())
	if spec.has("objective"):
		hud.set_objective(spec["objective"], spec.get("look", null))
	var t := 0.0
	var reached := 0
	while gun.shots < shots and t < limit:
		await scene.get_tree().process_frame
		# Takılan karede (yükleme, ağır sahne) koşanlar metrelerce ilerlemesin: hedefler nişan alınamadan kaçıyordu
		# (26 hold_lose: üç atış beklenirken iki)
		var dt := minf(scene.get_process_delta_time(), 0.05)
		t += dt
		reached = 0
		for s: Soldier in men:
			if s.has_meta("gun_down"):
				continue
			var st: float = float(s.get_meta("t")) + dt
			s.set_meta("t", st)
			if s.has_meta("peek"):
				_peek(s, st)
				continue
			if st < 0.0:
				continue
			var path: Array = s.get_meta("path")
			var p := along(path, st * speed)
			if p == Vector3.INF:
				s.visible = false
				reached += 1
				continue
			s.visible = true
			if ground.is_valid():
				p.y = ground.call(p.x, p.z)
			s.global_position = p
			s.face_toward(path[-1])
			if s.rig:
				s.rig.activity = "run_a" if fmod(st * 2.6, 1.0) < 0.5 else "run_b"
		if reached + gun.hits >= men.size() + ext.size():
			break
	# Son atışın dumanı dağılsın
	await scene.get_tree().create_timer(0.6).timeout
	if gun.shots >= 4 and gun.hits == gun.shots:
		GameState.bump_stat("gun_perfect", 1, true)
	var res := {"shots": gun.shots, "hits": gun.hits, "missed": men.size() + ext.size() - gun.hits, "reached": reached}
	print("GUN shots=%d hits=%d missed=%d" % [gun.shots, gun.hits, res["missed"]])
	gun.end()
	gun.queue_free()
	player.frozen = was_frozen
	hud.set_objective("")
	for s in men:
		s.queue_free()
	return res


static func _man(scene: Node3D, r: Dictionary) -> Soldier:
	var s := Soldier.new(r.get("coat", Color("8a6a4a")), "stand", r.get("hat", "turban"))
	s.set_meta("no_talk", true)
	s.set_meta("climber", true)          # hendekte, dilde, mazgalda: zemin çarpışması aranmasın
	scene.add_child(s)
	if r.get("ladder", false):
		# Omuzda merdiven (yatay, adamın yanında boylu boyunca): koşan "merdiven taşıyan" olduğu görünsün
		var lad := Node3D.new()
		lad.position = Vector3(0.32, 1.55, -0.6)
		s.add_child(lad)
		for sx: float in [-0.28, 0.28]:
			Props.cyl(lad, 0.045, 5.2, Vector3(sx, 0, 0), Color("6a4a2c"), Vector3(90, 0, 0), 5)
		for k in 12:
			Props.box(lad, Vector3(0.56, 0.04, 0.04), Vector3(0, 0, -2.4 + k * 0.42), Color("5a3e24"))
		if s.rig:
			s.rig.activity = ""
	return s


## Mazgaldaki savunucu: bir süre görünür (vurulabilir), sonra siperin ardına çöker (ışın taşa çarpar)
static func _peek(s: Soldier, st: float) -> void:
	var cyc := fmod(maxf(st, 0.0), PEEK_UP + PEEK_DOWN)
	var up := cyc < PEEK_UP
	var base: Vector3 = s.get_meta("base")
	var k := 1.0
	if up:
		k = clampf(cyc / 0.25, 0.0, 1.0) * clampf((PEEK_UP - cyc) / 0.25, 0.0, 1.0)
	else:
		k = 0.0
	s.global_position = base - Vector3(0, PEEK_DROP * (1.0 - k), 0)
	# Çökmüşken gövdesi siperin (surun taşının) ardında: denetçi onu taşın içinde saymasın (görünür kalır; görünmez yapmak
	# tüfek botunun hedeflerini azaltıyordu)
	if k > 0.45:
		s.remove_meta("no_audit")
	else:
		s.set_meta("no_audit", true)
	s.set_meta("up_t", cyc if up else 99.0)       # ne zamandır görünüyor (bot taze beliren hedefi seçer)
	if k > 0.6:
		if s.has_meta("ducked"):
			s.remove_meta("ducked")
	else:
		s.set_meta("ducked", true)


## Kırık çizgi boyunca d metre ilerideki nokta (sonu geçtiyse INF)
static func along(path: Array, d: float) -> Vector3:
	for i in path.size() - 1:
		var a: Vector3 = path[i]
		var b: Vector3 = path[i + 1]
		var l := a.distance_to(b)
		if d <= l:
			return a.lerp(b, d / l)
		d -= l
	return Vector3.INF
