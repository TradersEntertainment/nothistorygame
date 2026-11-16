extends "res://tests/_ist/tur7_kare.gd"
## TUR-9: tur7_kare + tanı. --gizle=a,b : yolu bu parçalardan birini içeren görünen ağlar karede gizlenir (kaynak bulmak
## için; çarpışma ve kurulum aynı). Kareler tur7_kare / birlik_kare ile aynı (--set=liste --liste=… --out=…).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur9_kare.tscn --
##       --set=liste --liste=DOSYA --out=KLASÖR [--gizle=kdolgu,Pismis] [--pik=x,y;…]
## Listede adı "CIT_<uzaklık>_<yan>" olan satır: kamera önce satırdaki yere gider (alan yüklensin), sonra en yakın ordugâh
## kazık çitinin ("cit" ağı) ortasına sur yönünden <uzaklık> m, yana <yan> m (göz 1,62 m) konur, çite bakar.
## Adı "YER_" ile başlayan satır: y yok sayılır, kamera (x, z)'de zeminin 1,62 m üstüne konur (aşağı ışın).
var _gz: Array = []


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		if s.begins_with("--gizle="):
			_gz = Array(s.trim_prefix("--gizle=").split(","))
	super._ready()


func _shot(ad: String) -> void:
	if ad.begins_with("YER_"):
		await _bekle()
		var q := PhysicsRayQueryParameters3D.create(Vector3(cam.global_position.x, 400.0, cam.global_position.z), Vector3(cam.global_position.x, -50.0, cam.global_position.z))
		var hit := get_viewport().world_3d.direct_space_state.intersect_ray(q)
		if not hit.is_empty():
			cam.global_position.y = float(hit["position"].y) + GOZ
		print("TUR9YER %s %s" % [ad, cam.global_position])
	if ad.begins_with("CIT_"):
		await _bekle()
		var p := ad.split("_")
		var uz := p[1].to_float()
		var yan := p[2].to_float()
		var en_iyi: MeshInstance3D = null
		var ed := INF
		for n in get_tree().root.find_children("cit", "MeshInstance3D", true, false):
			var mi := n as MeshInstance3D
			if mi.mesh == null or not mi.is_visible_in_tree():
				continue
			var c := (mi.global_transform * mi.get_aabb()).get_center()
			var dd := c.distance_to(cam.global_position)
			if dd < ed:
				ed = dd
				en_iyi = mi
		if en_iyi != null:
			var ab := en_iyi.global_transform * en_iyi.get_aabb()
			var c2 := ab.get_center()
			# hat AABB'nin uzun ekseni boyunca; kamera hatta DİK, sur tarafında (+x: sur doğuda)
			var dr := Vector3(1, 0, 0) if ab.size.z >= ab.size.x else Vector3(0, 0, 1)
			if dr.dot(Vector3(-1750.0, 0, -334.0) - c2) < 0.0:
				dr = -dr
			var yn := dr.cross(Vector3.UP).normalized()
			var cp := c2 + dr * uz + yn * yan
			cp.y = ab.position.y + 0.25 + GOZ
			cam.global_position = cp
			cam.look_at(Vector3(c2.x, ab.position.y + 1.0, c2.z), Vector3.UP)
			print("TUR9CIT %s cit=%s aabb=%s kam=%s" % [ad, en_iyi.get_path(), ab, cp])
	if not _gz.is_empty():
		await _bekle()
		for n in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
			var yol := str(n.get_path())
			for g: String in _gz:
				if g != "" and yol.contains(g):
					(n as GeometryInstance3D).visible = false
	await super._shot(ad)
