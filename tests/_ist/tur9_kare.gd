extends "res://tests/_ist/tur7_kare.gd"
## TUR-9: tur7_kare + tanı. --gizle=a,b : yolu bu parçalardan birini içeren görünen ağlar karede gizlenir (kaynak bulmak
## için; çarpışma ve kurulum aynı). Kareler tur7_kare / birlik_kare ile aynı (--set=liste --liste=… --out=…).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur9_kare.tscn --
##       --set=liste --liste=DOSYA --out=KLASÖR [--gizle=kdolgu,Pismis] [--pik=x,y;…]
var _gz: Array = []


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		if s.begins_with("--gizle="):
			_gz = Array(s.trim_prefix("--gizle=").split(","))
	super._ready()


func _shot(ad: String) -> void:
	if not _gz.is_empty():
		await _bekle()
		for n in get_tree().root.find_children("*", "GeometryInstance3D", true, false):
			var yol := str(n.get_path())
			for g: String in _gz:
				if g != "" and yol.contains(g):
					(n as GeometryInstance3D).visible = false
	await super._shot(ad)
