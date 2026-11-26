extends Node
## G23 (D18): yeni sette ve v2'de oynanan bölümler bit bit aynı mı. Bölümü açar, sabit kare sayısı bekler, sahnedeki
## MeshInstance3D sayısı, köşe toplamı ve (ad, köşe sayısı) karmasını basar. ÖNCE | SONRA aynı satır = aynı sahne.
##   godot --headless --path . res://tests/_ist/sur23_karma.tscn -- bolum=20 [kare=600]
## Satır: SUR23KARMA bolum=… mesh=… kose=… karma=…

var bolum := "20"
var kare := 600


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() == 2 and kv[0] == "bolum":
			bolum = kv[1]
		elif kv.size() == 2 and kv[0] == "kare":
			kare = kv[1].to_int()
	GameState.autotest = false
	_kos.call_deferred()


func _kos() -> void:
	match bolum:
		"23", "24":
			GameState.chapter_outcomes[8] = "8.1"
	var ch := (load("res://scenes/chapter%s.tscn" % bolum) as PackedScene).instantiate()
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	for k in kare:
		await get_tree().process_frame
	# (a) sur seti: SurOyun_* kökleri altındaki her ağ (kökten göreli yol, köşe sayısı, yuvarlanmış konum);
	# (b) kişi/parçacık dışı bütün durağan ağların sayısı ve köşe toplamı
	var n := 0
	var v := 0
	var sn := 0
	var sv := 0
	var satir: Array = []
	for mi in get_tree().root.find_children("*", "MeshInstance3D", true, false):
		var m := (mi as MeshInstance3D).mesh
		if m == null:
			continue
		var kok: Node = null
		var canli := false
		var q: Node = mi
		while q != null:
			if q is Person or q is Soldier or q is CharacterBody3D or q is CPUParticles3D or q is GPUParticles3D or q is CanvasLayer:
				canli = true
			if kok == null and String(q.name).begins_with("SurOyun_"):
				kok = q
			q = q.get_parent()
		if canli:
			continue
		var c := 0
		for si in m.get_surface_count():
			c += (m.surface_get_arrays(si)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
		n += 1
		v += c
		if kok != null:
			sn += 1
			sv += c
			var o := (mi as Node3D).global_position
			satir.append("%s|%d|%d,%d,%d" % [String(kok.get_path_to(mi)).replace("@", ""), c, roundi(o.x * 10.0), roundi(o.y * 10.0), roundi(o.z * 10.0)])
	satir.sort()
	var h := 0
	for a in satir:
		h = hash([h, a])
	print("SUR23KARMA bolum=%s sur_mesh=%d sur_kose=%d sur_karma=%d durgun_mesh=%d durgun_kose=%d" % [bolum, sn, sv, h, n, v])
	get_tree().quit()
