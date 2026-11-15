extends "res://tests/_ist/tur7_kare.gd"
## TUR-9: tur7_kare + tanı. --gizle=a,b : yolu bu parçalardan birini içeren görünen ağlar karede gizlenir (kaynak bulmak
## için; çarpışma ve kurulum aynı). Kareler tur7_kare / birlik_kare ile aynı (--set=liste --liste=… --out=…).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur9_kare.tscn --
##       --set=liste --liste=DOSYA --out=KLASÖR [--gizle=kdolgu,Pismis] [--pik=x,y;…]
## Listede adı "CIT_<uzaklık>_<yan>" olan satır: kamera önce satırdaki yere gider (alan yüklensin), sonra en yakın ordugâh
## kazık çitinin ("cit" ağı) ortasına sur yönünden <uzaklık> m, yana <yan> m (göz 1,62 m) konur, çite bakar.
var _gz: Array = []


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		if s.begins_with("--gizle="):
			_gz = Array(s.trim_prefix("--gizle=").split(","))
	super._ready()


func _shot(ad: String) -> void:
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
			var hedef := Vector3(-1750.0, c2.y, -334.0)        # sur yönü (Romanos Kapısı)
			var dr := (hedef - c2)
			dr.y = 0.0
			dr = dr.normalized()
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
