class_name OilHazard
extends Node
## Merdivende kaynar yağ (Osmanlı tarafı: 26o, 30o). Surdaki kazan önce sallanır (uyarı), sonra merdivenin boyunca
## devrilir. Oyuncu uyarıda A/D ile merdivenin bir yanına sarkarsa (Player.ladder_side) yağ yanından akar; ortada
## kalırsa yanar. Yağ merdivenin dibindeki yoldaşları da tutuşturur (WallFight.pour).
## Tarih: savunanlar sur dibine ve merdivenlere kaynar yağ, zift ve su döktü; azaplar kalkanlarını başlarına kaldırıp
## merdivenin yanına sinerek tırmandı.

const WARN := 1.7          # sallanma (uyarı) süresi
const HIT_FROM := 0.5      # devrildikten sonra yağın merdivene inişi
const HIT_TO := 1.5
const SAFE_SIDE := 0.3     # bu kadar yana sarkan yanmaz

var fight: WallFight
var cauldron: Dictionary
var ladder: Ladder
var player: Player
var hud: Node
var budget := 1
var hits := 0
var dodged := 0
var active := false
var _t := 0.0
var _poured := false
var _hurt := false
var _live := false
## Elde kapla döken savunucu (30o: merdivenin tepesinde): verilirse yağ onun kabından merdiven boyunca akar (kazan uzakta
## kalıyordu, şerit merdivenin yanından görünmeden geçiyordu: "dökülen yağ görünmüyor")
var pourer: Node3D
var _pot: Node3D


static func make(parent: Node, p_fight: WallFight, p_cauldron: Dictionary, p_ladder: Ladder, p_player: Player, p_hud: Node, p_budget := 1) -> OilHazard:
	var o := OilHazard.new()
	o.fight = p_fight
	o.cauldron = p_cauldron
	o.ladder = p_ladder
	o.player = p_player
	o.hud = p_hud
	o.budget = p_budget
	parent.add_child(o)
	return o


## Uyarıyı başlatır (merdivende, belli bir yükseklikte çağrılır). Başladıysa true.
func trigger() -> bool:
	if active or budget <= 0:
		return false
	budget -= 1
	active = true
	_t = 0.0
	_poured = false
	_hurt = false
	hud.set_qte(tr("UI_QTE_OIL"))
	Audio.stinger("warn", -2.0)
	Audio.sfx("fuse_burn", -6.0, 0.5)
	if is_instance_valid(pourer):
		_lift_pot()
		return true
	# Kazan sallanır: devirme kolundaki adam iki kez yoklar
	var pivot: Node3D = cauldron["pivot"]
	var tw := pivot.create_tween()
	for k in 3:
		tw.tween_property(pivot, "rotation:x", deg_to_rad(16.0), 0.22).set_trans(Tween.TRANS_SINE)
		tw.tween_property(pivot, "rotation:x", deg_to_rad(2.0), 0.3).set_trans(Tween.TRANS_SINE)
	return true


func _process(delta: float) -> void:
	if not active:
		return
	_t += delta
	if GameState.autotest and not GameState.autotest_variant.ends_with("lose"):
		# Bot: uyarıyı görünce sola sarkar, yağ geçince bırakır (=lose'da sarkmaz, yanar)
		if _t > 0.4 and _t < WARN + HIT_TO + 0.2:
			Input.action_press("move_left")
		else:
			Input.action_release("move_left")
	if _t >= WARN and not _poured:
		_poured = true
		var foot := ladder.global_position + ladder.front_dir() * 0.9
		if is_instance_valid(pourer):
			_tip_pot()
			_live = fight.pour_from(_pot.global_position + Vector3(0, 0.05, 0.25), foot, 1) > 0.0
		else:
			_live = fight.pour(cauldron, foot, 1) > 0.0
	if _poured and _live and not _hurt and _t >= WARN + HIT_FROM and _t <= WARN + HIT_TO:
		if player.ladder == ladder and absf(player.ladder_side) < SAFE_SIDE:
			_hurt = true
			hits += 1
			player.hurt(35.0, ladder.point_at(ladder.height))
			Fx.edge(Color("ff8a1a"), 0.9, 1.0)
			Audio.sfx("fuse_burn", -2.0, 0.9)
	if _t > WARN + HIT_TO + 0.3:
		active = false
		_stow_pot()
		if not _hurt:
			dodged += 1
		hud.set_qte("")
		if GameState.autotest:
			Input.action_release("move_left")


## Savunucu kızgın yağ kabını mazgalın üstüne kaldırır (kabın ağzında kor rengi yağ, buhar)
func _lift_pot() -> void:
	var rg = pourer.get("rig")
	if rg:
		rg.activity = "throw_up"
	if not is_instance_valid(_pot):
		_pot = Node3D.new()
		pourer.add_child(_pot)
		Props.cyl(_pot, 0.2, 0.32, Vector3.ZERO, Color("2e2c2a"), Vector3.ZERO, 10, 0.17)
		var oil_top := Props.cyl(_pot, 0.18, 0.02, Vector3(0, 0.15, 0), Color("d89a3a"), Vector3.ZERO, 10)
		oil_top.material_override = Props.mat(Color("d89a3a"), 1.2, false, "", false)
		Vfx.steam(_pot, Vector3(0, 0.3, 0))
	_pot.visible = true
	_pot.position = Vector3(0, 2.05, 0.2)
	_pot.rotation = Vector3.ZERO
	Audio.sfx("fuse_burn", -8.0, 0.6)


## Kap devrilir: ağzı merdivene döner
func _tip_pot() -> void:
	var rg = pourer.get("rig")
	if rg:
		rg.activity = "throw_down"
	var tw := _pot.create_tween().set_parallel(true)
	tw.tween_property(_pot, "position", Vector3(0, 1.35, 0.6), 0.25)
	tw.tween_property(_pot, "rotation:x", deg_to_rad(115.0), 0.25)


func _stow_pot() -> void:
	if is_instance_valid(_pot):
		_pot.visible = false
	if is_instance_valid(pourer):
		var rg = pourer.get("rig")
		if rg:
			rg.activity = "lean_down"
