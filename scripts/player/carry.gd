class_name Carry
extends Node
## Ortak taşıma hissi (v0.99.91). Eskiden her bölüm yükü kameraya çivi gibi asıyordu: yukarı bakınca kova yüze
## kalkıyor, dönünce yük kameraya yapışık dönüyor, yürürken hiç sallanmıyordu; "şunu al şuraya götür" görevleri hem
## sıkıcı hem biçimsizdi (oynanış hissiyatı denetimi). Bu bileşen yükü kameranın altındaki bir pivota alır:
##   · dönüşte ağırlığıyla gecikir (yük biraz geride kalır, yana yatar), sonra yetişir;
##   · adımda iner kalkar, yana salınır (ağırlığa göre);
##   · yukarı/aşağı bakışın yalnız bir kısmını izler (yük göğüs hizasında kalır);
##   · sol el (free_hold) yükle birlikte hareket eder.
## Sıvı ve tepsi gibi dökülenlerde (opts "balance": true) denge vardır: koşmak, keskin dönmek, zıplamak ve bir şeye
## çarpmak yükü çalkalar, yavaş yürümek durultur. Gösterge yarıyı geçince ekranda belirir; uca varırsa yük taşar
## ("spill" çağrılır, fill azalır), Tolga bağırır. Bölüm teslimde fill'e bakabilir (yarı kova = yarım söndürme).
##   var c := Carry.attach(player, _carry, {"weight": 0.7, "balance": true, "spill": _on_spill})
##   ... teslimde: c.fill · yük silinince (queue_free) ya da gizlenince bileşen kendiliğinden çekilir.
## Otomatik testte denge birikmez (bot yürüyüşü ışınlanmadır); "spill" varyantı ayrı denenir.

var player: Player
var item: Node3D
var pivot: Node3D
var weight := 0.5
var balance := false
var fill := 1.0                      # 1 dolu, her taşma ~1/3 eksiltir
var spills := 0
var wobble := 0.0                    # -1..1
var spill: Callable
var meter: BalanceMeter
var _hand := Vector3.INF             # sol elin pivot yerelindeki tutma noktası
var _hand_written := Vector3.INF     # son yazdığımız free_hold (bölüm değiştirirse el bırakılır)
var _yaw_prev := INF
var _lag := 0.0
var _phase := 0.0
var _vel_prev := Vector3.ZERO
var _cool := 0.0
var _done := false


static func attach(p: Player, node: Node3D, opts := {}) -> Carry:
	if p == null or node == null or p.camera == null:
		return null
	# Aynı yüke ikinci bileşen bağlanmasın (yeniden alınca)
	var old = node.get_meta("carry", null)
	if old is Carry and is_instance_valid(old):
		(old as Carry)._finish()
	var c := Carry.new()
	c.player = p
	c.item = node
	c.weight = float(opts.get("weight", 0.5))
	c.balance = bool(opts.get("balance", false))
	c.spill = opts.get("spill", Callable())
	c.name = "Carry"
	p.add_child(c)
	c.pivot = Node3D.new()
	c.pivot.name = "CarryPivot"
	c.pivot.set_meta("carry_pivot", true)
	p.camera.add_child(c.pivot)
	var xf := node.global_transform
	if node.get_parent():
		node.get_parent().remove_child(node)
	c.pivot.add_child(node)
	node.global_transform = xf
	node.set_meta("carry", c)
	# Sol el: bölüm free_hold'u verdiyse o nokta pivotla taşınır
	if p.free_hold != Vector3.INF:
		c._hand = p.free_hold
		c._hand_written = p.free_hold
	return c


func _process(delta: float) -> void:
	if _done:
		return
	if not is_instance_valid(item) or item.is_queued_for_deletion() or not is_instance_valid(pivot) \
			or item.get_parent() != pivot or not is_instance_valid(player):
		_finish()
		return
	pivot.visible = item.visible
	if not item.visible or get_tree().paused:
		return
	var dt := minf(delta, 0.05)
	var cam := player.camera
	# Dönüş gecikmesi: kameranın dünya yönü değişim hızına karşı yük biraz geride kalır, yana yatar
	var yaw := cam.global_rotation.y
	var rate := 0.0
	if _yaw_prev != INF:
		rate = wrapf(yaw - _yaw_prev, -PI, PI) / maxf(dt, 0.001)
	_yaw_prev = yaw
	var k := 0.5 + weight
	_lag = lerpf(_lag, clampf(-rate * 0.035 * k, -0.22, 0.22), clampf(dt * 7.0, 0.0, 1.0))
	# Bakış: aşağı/yukarı bakışın %55'i geri alınır (yük göğüs hizasında kalır, yukarı bakınca yüze kalkmaz)
	var pitch := cam.rotation.x
	# Adım: yatay hıza göre iner kalkar ve salınır
	var hv := Vector3(player.velocity.x, 0.0, player.velocity.z)
	var spd := hv.length()
	_phase += dt * spd * 2.1
	var amp := clampf(spd / Player.WALK, 0.0, 1.6)
	var bob := -absf(sin(_phase)) * 0.03 * amp * k
	var sway := sin(_phase) * 0.018 * amp * k
	var tilt := wobble * 0.32
	pivot.rotation = Vector3(-pitch * 0.55, _lag, _lag * 0.7 + tilt + sway * 1.5)
	pivot.position = Vector3(sway, bob, 0.0)
	# Sol el yükle birlikte; bölüm free_hold'u kendisi değiştirdiyse (bıraktı, başka yere aldı) karışmaz
	if _hand != Vector3.INF:
		if player.free_hold != _hand_written:
			_hand = Vector3.INF
		else:
			_hand_written = pivot.transform * _hand
			player.free_hold = _hand_written
	if balance:
		_balance_step(dt, rate, spd, hv)


func _balance_step(dt: float, rate: float, spd: float, hv: Vector3) -> void:
	_cool = maxf(0.0, _cool - dt)
	if GameState.autotest and GameState.autotest_variant != "spill":
		return
	# Çalkalayanlar: koşu, keskin dönüş, ani duruş/çarpma (hız değişimi), havada olmak
	var acc := (hv - _vel_prev).length() / maxf(dt, 0.001)
	_vel_prev = hv
	var push := 0.0
	# Koşu, yük altındaki yürüyüş hızına göre ölçülür (taşıma bölümlerinde speed_mult 0,6-0,85)
	var walk := Player.WALK * clampf(player.speed_mult, 0.3, 1.0)
	if spd > walk * 1.15:
		push += (spd / walk - 1.15) * 0.75
	push += maxf(0.0, absf(rate) - 1.6) * 0.18
	push += maxf(0.0, acc - 14.0) * 0.012
	if not player.is_on_floor() and player.ladder == null:
		push += 0.9
	var dir := signf(wobble) if absf(wobble) > 0.05 else (1.0 if randf() < 0.5 else -1.0)
	wobble += dir * push * dt * (0.6 + weight * 0.6)
	# Yavaş yürüyüş ya da durmak durultur
	var calm := 0.7 if spd <= walk * 1.05 else 0.15
	wobble = move_toward(wobble, 0.0, calm * dt)
	wobble = clampf(wobble, -1.0, 1.0)
	_meter_show(absf(wobble) > 0.45)
	if meter:
		meter.value = wobble
	if absf(wobble) >= 1.0 and _cool <= 0.0:
		_spill()


func _spill() -> void:
	spills += 1
	fill = maxf(0.0, fill - 0.34)
	wobble = 0.35 * signf(wobble)
	_cool = 1.2
	var at := item.global_position + Vector3(0, 0.1, 0)
	var sc := player.get_tree().current_scene
	if sc:
		Vfx.splash(sc, at, 0.5)
	Audio.sfx("splash", -10.0, 1.4)
	player.shake(0.12)
	if GameState.autotest:
		print("CARRY spill n=%d fill=%.2f" % [spills, fill])
	var hud := player.get_tree().get_first_node_in_group("hud") as Hud
	if hud and player.hand_style == "tolga":
		match (spills - 1) % 3:
			0:
				hud.bark("SPK_TOLGA", "D_CARRY_SPILL_1", 1.8)
			1:
				hud.bark("SPK_TOLGA", "D_CARRY_SPILL_2", 2.4)
			_:
				hud.bark("SPK_TOLGA", "D_CARRY_SPILL_3", 2.0)
	if spill.is_valid():
		spill.call(self)


func _meter_show(on: bool) -> void:
	if on and meter == null:
		var hud := player.get_tree().get_first_node_in_group("hud") as Hud
		if hud == null:
			return
		meter = BalanceMeter.new()
		meter.label_text = tr("UI_CARRY_STEADY")
		hud.add_child(meter)
		meter.place_bottom()
	if meter:
		meter.visible = on or absf(wobble) > 0.3


## Bileşen çekilir: yük (hâlâ varsa) eski yerine, kameranın doğrudan çocuğu olarak döner; el bırakılır.
func _finish() -> void:
	if _done:
		return
	_done = true
	if is_instance_valid(item) and not item.is_queued_for_deletion() and is_instance_valid(pivot) and item.get_parent() == pivot \
			and is_instance_valid(player) and player.camera:
		var xf := item.transform
		pivot.remove_child(item)
		player.camera.add_child(item)
		item.transform = xf
		item.remove_meta("carry")
	if is_instance_valid(player) and _hand != Vector3.INF and player.free_hold == _hand_written:
		player.free_hold = Vector3.INF
	if is_instance_valid(meter):
		meter.queue_free()
	if is_instance_valid(pivot):
		pivot.queue_free()
	queue_free()


## Bölüm yükü kendisi bırakırken (teslim, yere koyma) çağırabilir; yük silinince zaten kendiliğinden çekilir.
func release() -> void:
	_finish()
