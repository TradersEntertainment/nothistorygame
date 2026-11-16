extends Node
func _ready():
	await get_tree().create_timer(3.0).timeout
	for n in get_parent().get_children():
		if n is Horse or n is Ox or n is Chicken:
			var a = n._ah
			var wp: Vector3 = n.global_transform * Vector3(0, 0, a.on_z)
			print("DBG ", n.name, " pos=", n.global_position, " egim=", a.egim, " dy=", a.dy, " hf=", a._hf, " hr=", a._hr, " fy=", Unclip.floor_y(n, wp, 0.5, 0.8), " wp=", wp, " z=", a._zemin(n.get_parent().global_transform, n.transform * Vector3(0, 0, a.on_z), n.position.y))
	get_tree().quit()
