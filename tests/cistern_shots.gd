extends Node3D
## Bölüm 44 (Sarnıç) sonda kareleri ve kapak: oyun akışının dışında, mekânı tek başına kurar. Eskiden chapter44b.gd
## içindeki _run_shots'tu (--shots); sürümden çıkarıldı (denetim K9).
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 res://tests/cistern_shots.tscn -- --shots=KLASÖR
## Kareler adında "sonda_": oyuncu kamerası değildir, kanıt yerine geçmez (yalnız ayar/kapak için).

const CisternLevel := preload("res://scripts/level/cistern.gd")

var cis: Node3D
var cam: Camera3D
var spot: SpotLight3D
var fill: OmniLight3D


func _ready() -> void:
	var dir := GameState.shots_dir if GameState.shots_dir != "" else "user://cistern_shots"
	DirAccess.make_dir_recursive_absolute(dir)
	cis = CisternLevel.new()
	add_child(cis)
	cis.call("set_light", 0.6, 1.0)
	cis.call("well_mouth_light", false)
	cam = Camera3D.new()
	cam.fov = 72.0
	add_child(cam)
	cam.current = true
	spot = SpotLight3D.new()
	spot.light_color = Color("f4f0ff")
	spot.light_energy = 6.0
	spot.spot_range = 45.0
	spot.spot_angle = 36.0
	spot.spot_angle_attenuation = 1.6
	spot.spot_attenuation = 0.8
	spot.position = Vector3(0.18, -0.22, -0.1)
	cam.add_child(spot)
	fill = OmniLight3D.new()
	fill.light_color = Color("b8c8d8")
	fill.omni_range = 16.0
	fill.light_energy = 0.5
	fill.position = Vector3(0, 2.6, -4.0)
	cam.add_child(fill)
	await get_tree().process_frame
	var fw: Vector3 = cis.get("fall_well")
	var w := CisternLevel.WATER_Y
	var mc := CisternLevel.column(1, 1)
	var mc2 := CisternLevel.column(2, 1)
	var ex: Vector3 = cis.get("exit_well")
	var he := CisternLevel.column(CisternLevel.HEN_EYE[0], CisternLevel.HEN_EYE[1])
	var crown := CisternLevel.IMPOST_Y + CisternLevel.VAULT_H
	var shots := [
		["sonda_awe_1.png", Vector3(fw.x, w + 0.35, fw.z + 0.6), Vector3(fw.x - 20, w + 1.2, fw.z - 3), true],
		["sonda_awe_2.png", Vector3(fw.x, w + 0.35, fw.z + 0.6), Vector3(fw.x - 3, w + 3.5, fw.z - 18), true],
		["sonda_awe_3.png", Vector3(fw.x, w + 0.35, fw.z + 0.6), Vector3(fw.x - 8, w + 7.0, fw.z + 6), true],
		["sonda_dark.png", Vector3(fw.x, w + 0.35, fw.z + 0.6), Vector3(fw.x - 20, w + 1.2, fw.z - 3), false],
		["sonda_well_up.png", Vector3(fw.x - 0.14, crown + 2.8, fw.z), Vector3(fw.x - 0.1, crown + 9.0, fw.z - 0.4), false],
		["sonda_well_down.png", Vector3(fw.x - 0.14, crown + 0.6, fw.z), Vector3(fw.x - 0.2, w, fw.z - 2.0), false],
		["sonda_medusa_pair.png", Vector3((mc.x + mc2.x) * 0.5, w + 1.55, mc.z + 4.4), Vector3((mc.x + mc2.x) * 0.5, 1.1, mc.z + 0.4), true],
		["sonda_medusa_side.png", mc + Vector3(0.3, w + 0.9, 2.4), mc + Vector3(0, 1.0, 0.4), true],
		["sonda_medusa_inv.png", mc2 + Vector3(-0.3, w + 0.9, 2.4), mc2 + Vector3(0, 1.0, 0.4), true],
		["sonda_medusa_side_yakin.png", mc + Vector3(0.9, w - 0.25, 2.9), mc + Vector3(0, 1.36, 0.6), true],
		["sonda_medusa_inv_yakin.png", mc2 + Vector3(-0.9, w - 0.25, 2.9), mc2 + Vector3(0, 1.36, 0.6), true],
		["sonda_medusa_ikisi_kandil.png", Vector3((mc.x + mc2.x) * 0.5, w + 0.9, mc.z + 4.6), Vector3((mc.x + mc2.x) * 0.5, 1.4, mc.z + 0.5), false],
		["sonda_heneye.png", he + Vector3(1.5, w + 0.6, 1.8), he + Vector3(0, 4.0, 0), true],
		["sonda_cellar.png", Vector3(ex.x, crown + 4.6 + 1.5, ex.z + 0.9), Vector3(ex.x, crown + 4.6 + 1.2, ex.z + 4.0), false],
		["sonda_ladder.png", Vector3(ex.x, w + 1.5, ex.z + 0.15), Vector3(ex.x, crown + 3.0, ex.z - 0.4), false],
	]
	cis.call("cellar_on", true)
	var lamp := OmniLight3D.new()
	lamp.light_color = Color("ffb868")
	lamp.light_energy = 3.4
	lamp.omni_range = 6.5
	add_child(lamp)
	lamp.global_position = Vector3((mc.x + mc2.x) * 0.5, w + 0.3, mc.z + 1.9)
	cis.call("clear_water", (mc + mc2) * 0.5 + Vector3(0, 0, 0.4), 4.4)
	# --only=önek: yalnız adı bu önekle başlayan kareler (ayar için hızlı koşu)
	var only := ""
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.trim_prefix("--only=")
	for s: Array in shots:
		if only != "" and not String(s[0]).begins_with(only):
			continue
		cam.global_position = s[1]
		cam.look_at(s[2], Vector3.UP if absf((s[2] - s[1]).normalized().y) < 0.98 else Vector3.FORWARD)
		cis.set("focus", s[1])
		spot.visible = s[3]
		fill.visible = s[3]
		cis.call("well_mouth_light", String(s[0]).begins_with("sonda_well"))
		cis.call("beam_visible", Vector2i(CisternLevel.WELLS[0][0], CisternLevel.WELLS[0][1]), not String(s[0]).begins_with("sonda_well"))
		await _shot(dir, s[0])
	if only != "":
		get_tree().quit()
		return
	# Bölüm kapağı (assets/art/covers/ch44b.png): hayranlık anı
	cis.call("cellar_on", false)
	cam.global_position = Vector3(fw.x, w + 0.45 + 1.12, fw.z + 0.6)
	cam.look_at(Vector3(fw.x - 3, w + 3.2, fw.z - 18), Vector3.UP)
	spot.visible = true
	fill.visible = true
	await _shot(dir, "ch44b_cover.png")
	get_tree().quit()


func _shot(dir: String, nm: String) -> void:
	for k in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir.path_join(nm))
	print("SHOT %s draws=%d prims=%d" % [nm, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
