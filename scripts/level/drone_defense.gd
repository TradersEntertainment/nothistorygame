class_name DroneDefense
extends Node
## 43O: Büro'nun dronu surların ya da şehrin üstünde alçaktan (22 m altı) uçarsa Bizans savunucuları onu görür:
## bağırırlar, okçular ok, birkaçı tüfek atar (WallCrowd hedefi dron). Kullanıcı: "biraz aşağı inerse bizans askerleri
## tepki versin, vurmaya çalışsınlar, oradan da oyun çıkar".
##   · Hızlı ve alçalıp yükselerek uçan kuş zor vurulur (isabet çarpanı hıza göre); havada asılı kalan kolay vurulur.
##   · Her isabet: görüntü karlanır, kuş sarsılır, pil gider; üçüncüde Büro'nun acil yükselişi kuşu 35 m'ye kaldırır.
##   · Oklara 15 sn yakalanmadan alçakta kalan: Sultan över, başarım (ACH_DRONE_DODGE).
## Yalnız oyuncu uçururken çalışır (Sultan'ın uçuşu ve otomatik dönüş sırasında askerler susar).

const LOW_ALT := 22.0
const ZONE_Z := 375.0            # hendekten öte (43O yerel z): surlar ve şehir
const REARM := 60.0              # kuş bu kadar uzaklaşınca o bölgenin askerleri figüre döner, yenileri canlanır
const DODGE_S := 15.0
## Konuşmacı çiftleri (tools/voice_map.py)
const LINES := [["SPK_DEFENDER", "D43O_B_SPOT"], ["SPK_DEFENDER", "D43O_B_SHOOT"], ["SPK_DEFENDER", "D43O_B_AGAIN"],
	["SPK_TOLGA", "D43O_T_HIT_1"], ["SPK_TOLGA", "D43O_T_HIT_2"], ["SPK_TOLGA", "D43O_T_LIFT"], ["SPK_FATIH", "D43O_F_DODGE"]]

var drone: Drone
var hud: Hud
var scene: Node3D
var player: Player
var crowd: WallCrowd
var hits := 0
var dodged := false
var _center := Vector3.INF
var _low_t := 0.0
var _spotted := 0
var _lifting := false
var _seed := 0


func _init(s: Node3D, d: Drone, h: Hud, p: Player) -> void:
	scene = s
	drone = d
	hud = h
	player = p
	name = "DroneDefense"


func _physics_process(delta: float) -> void:
	if drone == null or not is_instance_valid(drone) or drone.dead or not drone.piloted or _lifting:
		_stand_down()
		return
	var p := drone.global_position
	var low := p.z > ZONE_Z and drone.altitude() < LOW_ALT
	if not low:
		_low_t = 0.0
		if crowd and drone.altitude() > LOW_ALT + 8.0:
			_stand_down()
		return
	if crowd == null or Vector2(p.x - _center.x, p.z - _center.z).length() > REARM:
		_arm(p)
	# Hızlı ve alçalıp yükselen kuş zor vurulur
	var sp := Vector3(drone.vel.x, drone.vel.y * 1.5, drone.vel.z).length()
	crowd.hit_mult = clampf(1.6 - sp / Drone.FAST * 1.4, 0.15, 1.6)
	_low_t += delta
	if _low_t >= DODGE_S and not dodged:
		dodged = true
		GameState.bump_stat("drone_dodge")
		hud.bark("SPK_FATIH", "D43O_F_DODGE", 3.5)


## Kuşun altındaki sur/şehir parçasının savunucuları canlanır
func _arm(p: Vector3) -> void:
	_stand_down()
	_center = p
	_seed += 1
	var box := AABB(Vector3(p.x - 55.0, -20.0, p.z - 55.0), Vector3(110.0, 90.0, 110.0))
	crowd = WallCrowd.make(scene, player, box, "B", 10, _seed, [], drone)
	crowd.on_hit = _hit
	_reinforce(p)
	if crowd.men.is_empty():
		return               # bu parçada kimse yok (bostan, harabe): sessiz
	_spotted += 1
	hud.bark("SPK_DEFENDER", "D43O_B_SPOT" if _spotted == 1 else ("D43O_B_SHOOT" if _spotted == 2 else "D43O_B_AGAIN"), 2.5)
	Audio.sfx("war_cry", -14.0, 1.1)


## Surlar seyrek (her burçta iki üç adam): kuş alçalınca yakındaki okçular koşup gelir. Kuşun arkasına ve yanlarına
## (kameranın görmediği yöne) konurlar: gözün önünde birden belirmesinler. Surun yakınında burçların ve surun üstüne,
## şehrin içinde sokağa.
func _reinforce(p: Vector3) -> void:
	var want := 4 - crowd.men.filter(func(m: Soldier): return m.get_meta("role", "") != "spear").size()
	var space := drone.get_world_3d().direct_space_state
	var back := Basis(Vector3.UP, drone.yaw) * Vector3(0, 0, 1)        # kameranın arkası
	var n := 0
	for k in 8:
		if n >= want:
			break
		var ang := deg_to_rad(-80.0 + 160.0 * float(k) / 7.0) + (0.0 if k % 2 == 0 else 0.3)
		var dir := Basis(Vector3.UP, ang) * back
		var q := p + dir * randf_range(16.0, 30.0)
		if p.z < 445.0:
			q.z = 420.0 if k % 2 == 0 else 401.0            # iç sur ya da dış sur hizası
		var ray := PhysicsRayQueryParameters3D.create(Vector3(q.x, p.y + 40.0, q.z), Vector3(q.x, p.y - 80.0, q.z), 1)
		var hitr := space.intersect_ray(ray)
		if hitr.is_empty() or (hitr["position"] as Vector3).y > p.y - 3.0:
			continue
		crowd.add_archer(hitr["position"], Garrison.COATS[(n + _seed) % Garrison.COATS.size()], p, "SPK_DEFENDER")
		n += 1


func _stand_down() -> void:
	if crowd and is_instance_valid(crowd):
		crowd.finish()
	crowd = null
	_center = Vector3.INF


func _hit(_from: Vector3) -> void:
	if _lifting or drone.dead:
		return
	hits += 1
	Audio.sfx("kick_metal", -6.0, 1.6)
	drone.vel += Vector3(randf_range(-3, 3), -1.5, randf_range(-3, 3))
	drone.battery = maxf(26.0, drone.battery - 6.0)
	drone.set_static(0.85)
	get_tree().create_timer(0.5, false).timeout.connect(func():
		if is_instance_valid(drone) and not drone.lens_covered:
			drone.set_static(0.0))
	if hits < 3:
		hud.bark("SPK_TOLGA", "D43O_T_HIT_1" if hits == 1 else "D43O_T_HIT_2", 2.5, true)
		return
	# Üçüncü isabet: Büro'nun acil yükselişi
	_lifting = true
	_stand_down()
	hud.bark("SPK_TOLGA", "D43O_T_LIFT", 3.0, true)
	var up := Vector3(drone.global_position.x, drone.global_position.y + 0.0, drone.global_position.z)
	up.y = drone.global_position.y - drone.altitude() + 35.0
	await drone.fly_to(up, 9.0)
	drone.auto_target = Vector3.INF
	hits = 0
	_lifting = false
