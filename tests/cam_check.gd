extends Node3D
## Tespit makinesi elde (v0.88): Player.camera_hold / camera_raise / camera_eject ve TespitCam'ın kadraj durumları.
## Denetler: makine gelince kumanda iner; eşya seçilince makine cebe iner, hedef kadraja girince geri kalkar;
## dövüşte cepte kalır ve kalkmaz; kürekte (pinned) cepte başlar, yalnız kadrajda çıkar; baskının üstünde kare var;
## bırakılınca kumanda geri gelir; hedef konide ama menzil dışındaysa vizör "uzak" der ve deklanşör kapalıdır.
## Sonuç: CAMCHECK PASS/FAIL.

var player: Player
var hud: Hud
var ok := true


func _ready() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	add_child(env)
	Props.solid(self, Vector3(20, 0.4, 20), Vector3(0, -0.2, 0), Color("6a6a60"))
	hud = Hud.new()
	add_child(hud)
	player = Player.new()
	add_child(player)
	player.global_position = Vector3(0, 0.05, 4.0)
	_run()


func _expect(cond: bool, what: String) -> void:
	if not cond:
		ok = false
		printerr("CAMCHECK: " + what)


func _wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout


func _run() -> void:
	await _wait(0.3)
	# 1. Elde kumanda varken makine gelir: kumanda iner
	player.show_remote(true)
	await _wait(0.6)
	player.camera_hold(true)
	await _wait(0.6)
	_expect(player._cam != null and player._cam.visible and not player._cam_pocket, "makine ele gelmedi")
	_expect(not player._hand_shown, "makine gelince kumanda inmedi")
	# 2. Eşya seçimi: makine cebe iner, el kalkar
	player.select_item(0)
	await _wait(0.6)
	_expect(player._cam_pocket and not player._cam.visible, "eşya seçilince makine cebe inmedi")
	_expect(player._hand_shown, "eşya seçilince el kalkmadı")
	# 3. Hedef kadrajda: makine cepten göze kalkar, el iner
	player.camera_raise(true)
	await _wait(0.4)
	_expect(not player._cam_pocket and player._cam_up and player._cam.visible, "kadrajda makine kalkmadı")
	_expect(not player._hand_shown, "makine kalkınca el inmedi")
	# 4. Dövüş: makine cebe iner, dövüşte kalkmaz
	player.camera_raise(false)
	player.combat = true
	await _wait(0.4)
	_expect(player._cam_pocket, "dövüşte makine elde kaldı")
	player.camera_raise(true)
	await _wait(0.2)
	_expect(player._cam_pocket and not player._cam_up, "dövüşte makine kalktı")
	player.combat = false
	# 5. Baskı: makine kalkar, deklanşörden sonra yuvadan baskı çıkar, üstünde kare var
	player.camera_raise(true)
	await _wait(0.3)
	var img := Image.create(64, 36, false, Image.FORMAT_RGB8)
	img.fill(Color(0.3, 0.5, 0.7))
	player.camera_eject(img)
	await _wait(0.2)
	var pr := player._cam.get_node_or_null("CameraPrint") if player._cam else null
	_expect(pr != null, "baskı çıkmadı")
	var pic := false
	if pr:
		for c in pr.get_children():
			if c is MeshInstance3D and (c as MeshInstance3D).mesh is PlaneMesh:
				pic = true
	_expect(pic, "baskının üstünde kare yok")
	# 6. Bırakınca makine gider, kumanda geri gelir
	player.camera_hold(false)
	await _wait(0.6)
	_expect(player._cam == null, "makine bırakılmadı")
	_expect(player._hand_shown, "makine bırakılınca kumanda geri gelmedi")
	# 7. Kürekte (pinned): cepte başlar, kadrajda çıkar, kadrajdan çıkınca cebe döner
	player.pinned = true
	player.camera_hold(true)
	await _wait(0.3)
	_expect(player._cam != null and player._cam_pocket and not player._cam.visible, "kürekte makine elde başladı")
	player.camera_raise(true)
	await _wait(0.3)
	_expect(not player._cam_pocket and player._cam_up, "kürekte kadrajda makine çıkmadı")
	player.camera_raise(false)
	await _wait(0.4)
	_expect(player._cam_pocket, "kürekte kadrajdan çıkınca makine cebe dönmedi")
	player.camera_hold(false)
	player.pinned = false
	await _wait(0.4)
	# 8. TespitCam: konide ve menzilde "kadrajda", konide ama uzaksa "uzak" (deklanşör kapalı), dışarıda hiçbiri
	var target := Node3D.new()
	add_child(target)
	target.global_position = Vector3(0, 1.6, -6.0)
	player.face(target.global_position)
	var tc := TespitCam.new(player, hud, target, "siege_test")
	hud.add_child(tc)
	tc.max_dist = 40.0
	tc.cone_deg = 12.0
	tc.start()
	await _wait(0.4)
	_expect(tc._in and not tc._far, "hedef kadrajda sayılmadı")
	_expect(player._cam != null and player._cam_up, "kadrajda makine göze kalkmadı")
	tc.max_dist = 5.0
	await _wait(0.3)
	_expect(tc._far and not tc._in, "uzaktaki hedef 'uzak' sayılmadı")
	_expect(not tc.in_frame(), "uzaktaki hedef çekilebilir sayıldı")
	tc.max_dist = 40.0
	player.face(target.global_position + Vector3(30, 0, 0))
	await _wait(0.4)
	_expect(not tc._in and not tc._far, "hedef dışarıdayken kadrajda sayıldı")
	_expect(player._cam != null and not player._cam_up, "hedef dışarıdayken makine inmedi")
	tc.stop()
	await _wait(0.5)
	_expect(player._cam == null, "TespitCam durunca makine elde kaldı")
	print("CAMCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
