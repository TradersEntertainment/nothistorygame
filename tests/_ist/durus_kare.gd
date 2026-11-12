extends Node3D
## DURUŞ sondası: düz nötr zeminde her duruşu (scripts/npc/durus_kit.gd) gerçek kişi modeliyle çizer, 3 m'den yandan
## ve önden kare alır (Soldier: börklü yeniçeri; Person: uzun kaftanlı sivil). Ayrıca ayaktan bağdaşa geçiş dizisi
## (6 kare) ve Crowd pişirmesi (ordugâhın donmuş kalabalığı) aynı duruşla.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/durus_kare.tscn -- --out=KLASÖR [--set=pafta,gecis,crowd]
## Satırlar: DURUSKARE ad zemin_cm=  ·  POSEAUDIT … (takımın kendi denetimi)

const DK := preload("res://scripts/npc/durus_kit.gd")

var out := "user://durus"
var set_ := "pafta,gecis,crowd"
var cam: Camera3D
var only := ""


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
		elif a.begins_with("--set="):
			set_ = a.substr(6)
		elif a.begins_with("--only="):
			only = a.substr(7)
	DirAccess.make_dir_recursive_absolute(out)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("a9c4dc")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.62, 0.62, 0.66)
	e.ambient_light_energy = 0.75
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 30, 0)
	sun.shadow_enabled = true
	add_child(sun)
	var zem := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(60, 60)
	zem.mesh = pm
	var zm := StandardMaterial3D.new()
	zm.albedo_color = Color("9a9478")
	zem.material_override = zm
	add_child(zem)
	# 10 cm ızgara çizgileri: zemine değme okunur
	for i in range(-15, 16):
		var ln := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.006, 0.002, 3.0) if i % 5 != 0 else Vector3(0.012, 0.002, 3.0)
		ln.mesh = bm
		ln.position = Vector3(i * 0.1, 0.001, 0)
		var lm := StandardMaterial3D.new()
		lm.albedo_color = Color("6a6650")
		ln.material_override = lm
		add_child(ln)
	cam = Camera3D.new()
	cam.fov = 40
	add_child(cam)
	cam.make_current()
	await get_tree().process_frame
	var ss := set_.split(",")
	if "pafta" in ss:
		await _pafta()
	if "gecis" in ss:
		await _gecis()
	if "crowd" in ss:
		await _crowd()
	print("DURUSKARE BITTI")
	get_tree().quit(0)


func _kisi(tur: int) -> Node3D:
	if tur == 0:
		return Soldier.new(Color("cdbf9a"), "stand", "bork")
	return Person.new({"coat": Color("3a6a8a"), "robe": Color("6a563c"), "hat": "turban", "mustache": true, "beard": true, "n": 41})


func _pafta() -> void:
	for ad: String in DK.ADLAR:
		if only != "" and not ad in only.split(","):
			continue
		for tur in 2:
			var k := _kisi(tur)
			add_child(k)
			await get_tree().process_frame
			var rg = k.get("rig")
			if tur == 0 and ad == "kazma":
				k.call("give_tool", "shovel", {"activity": ad})
			elif tur == 0 and ad == "kazan_kar":
				k.call("give_tool", "ladle", {"activity": ad})
			elif tur == 0 and ad == "balta":
				k.call("give_tool", "axe", {"activity": ad})
			else:
				(rg as Rig).activity = ad
			for i in 75:
				await get_tree().process_frame
			var nm := "sonda_%s_%s" % [ad, ["asker", "sivil"][tur]]
			print("DURUSKARE %s zemin_cm=%s" % [nm, str((rg as Rig)._durus.get("zemin_cm", "?"))])
			await _cek(nm + "_yan", Vector3(3.0, 1.0, 0.25), Vector3(0, 0.55, 0.15))
			await _cek(nm + "_on", Vector3(0.4, 1.1, 3.0), Vector3(0, 0.55, 0.0))
			await _cek(nm + "_capraz", Vector3(-2.1, 1.6, 2.1), Vector3(0, 0.5, 0.1))
			k.queue_free()
			await get_tree().process_frame


func _gecis() -> void:
	var k := _kisi(0)
	add_child(k)
	for i in 30:
		await get_tree().process_frame
	(k.get("rig") as Rig).activity = "bagdas"
	var t0 := Time.get_ticks_msec()
	for f in 6:
		while Time.get_ticks_msec() - t0 < f * 160:
			await get_tree().process_frame
		await _cek("sonda_gecis_%d" % f, Vector3(-2.1, 1.4, 2.1), Vector3(0, 0.6, 0.1))
	k.queue_free()
	await get_tree().process_frame


## Ordugâhın yakın katmanı Crowd ile donmuş kopya pişirir: aynı duruşlar pişmiş ağda da aynı mı
func _crowd() -> void:
	var x := -3.0
	var adlar := ["bagdas", "bagdas_ye", "diz_ustu", "comel", "sirt_uzan", "yan_uzan", "kazan_kar", "sirt_dayali"]
	for ad: String in adlar:
		var arm := "tool:ladle" if ad == "kazan_kar" else ""
		var m := Crowd.ottoman(Color("cdbf9a"), "bork", arm, ad)
		var mi := MeshInstance3D.new()
		mi.mesh = m
		mi.material_override = Crowd.material()
		mi.position = Vector3(x, 0, 0)
		mi.name = "crowd_" + ad
		add_child(mi)
		x += 1.1
	await _cek("sonda_crowd_on", Vector3(1.0, 1.8, 4.6), Vector3(0.9, 0.4, 0))
	await _cek("sonda_crowd_yan", Vector3(-6.5, 1.5, 1.2), Vector3(0, 0.4, 0))
	for c in get_children():
		if String(c.name).begins_with("crowd_"):
			c.queue_free()


func _cek(nm: String, at: Vector3, look: Vector3) -> void:
	cam.global_position = at
	cam.look_at(look)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_jpg(out.path_join(nm + ".jpg"), 0.85)
