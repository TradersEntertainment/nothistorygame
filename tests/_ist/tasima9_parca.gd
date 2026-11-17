extends Node3D
## TAŞIMA-9 tanı: Blakherna yeni görünüşünün parçalarını tek tek kurup bir kare alır (beyaz ekran kök nedeni).
##   --parca=zemin|sur|kule|merdiven|saray|bayrak|pavez|hepsi  --cikti=<jpg>
func _ready() -> void:
	var parca := "hepsi"
	var cikti := "/tmp/t9.jpg"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--parca="):
			parca = a.trim_prefix("--parca=")
		if a.begins_with("--cikti="):
			cikti = a.trim_prefix("--cikti=")
	Night.environment(self, 0.008)
	var BLAK := load("res://scripts/world/ist/blak_set.gd")
	var g := Node3D.new()
	add_child(g)
	if parca in ["zemin", "hepsi"]:
		BLAK.zemin(g, -70.0, 70.0, 4.6, 65.8, 0.0, [4.6], "Z")
	if parca in ["sur", "hepsi"]:
		BLAK.sur(g, -60.0, 60.0, 0, {"tohum_L": 120.0, "korkuluk": true})
	if parca in ["merdiven", "hepsi"]:
		BLAK.merdiven(g, Vector3(-14, 0, -6), Vector3(-6, 12, -0.2), 2.4, 0)
	if parca in ["saray", "hepsi"]:
		load("res://scripts/world/ist/sehir_eser.gd").palace(g, 0, true)
	if parca in ["bayrak", "hepsi"]:
		var kb := Node3D.new()
		kb.position = Vector3(0, 20, 6)
		add_child(kb)
		preload("res://scripts/world/ist/kumas.gd").bayrak(kb, Vector3.ZERO, Vector3.BACK, 2.4, 1.6, Color("8a1a2a"), [], 8, "Sancak")
	if parca in ["pavez", "hepsi"]:
		var mi := MeshInstance3D.new()
		mi.mesh = Assault.pavez_ag(2.6, 1.9, 0.1, Color("66502f"), -12.0)
		mi.material_override = Dressing._material()
		mi.position = Vector3(0, 0, 25)
		add_child(mi)
	load("res://scripts/world/ist/sur_doku.gd").uygula(g, 0)
	var cam := Camera3D.new()
	add_child(cam)
	cam.position = Vector3(10, 1.67, 40)
	cam.look_at(Vector3(10, 8, 0), Vector3.UP)
	cam.fov = 72
	cam.make_current()
	for i in 20:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_jpg(cikti, 0.85)
	print("T9PARCA %s %s" % [parca, cikti])
	get_tree().quit(0)
