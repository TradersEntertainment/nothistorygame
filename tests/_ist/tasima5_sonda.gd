extends Node3D
## TAŞIMA-5 sondası: Bölüm 22/22o için yeni setin (SurSetSahne, onarım 10 = aşama 4) sayıları ve dış sur yolunun gedik
## çevresindeki yürünür yüzeyi (sur yolu tahtası), fıçı yuvarlanma yolu (oluk → moloz → teras → dolgu → ova) boyunca zemin.
##   godot --headless --path . tests/_ist/tasima5_sonda.tscn
## Satırlar: SONDA5 ana … | SONDA5 yol x=… z=… y=… ad=… bos=… | SONDA5 iz x=… z=… zemin=… isin=… ad=…

func _ray(space: PhysicsDirectSpaceState3D, p: Vector3, y0: float, y1: float) -> Array:
	var q := PhysicsRayQueryParameters3D.create(Vector3(p.x, y0, p.z), Vector3(p.x, y1, p.z), 1)
	var h := space.intersect_ray(q)
	if h.is_empty():
		return [NAN, "-"]
	var col: Object = h["collider"]
	var ad: String = str((col as Node).name) if col is Node else "?"
	var par: String = str((col as Node).get_parent().name) if col is Node else "?"
	return [(h["position"] as Vector3).y, "%s/%s" % [par, ad]]


func _ready() -> void:
	var sur := SurSet.yeni("mesoteikhion")
	var ss := SurSetSahne.new()
	ss.sur = sur
	add_child(ss)
	ss.set_repair(10)
	for i in 4:
		await get_tree().physics_frame
	print("SONDA5 ana gedik=%s gedik_en=%.2f bosluk=%.2f dis_z0=%.2f dis_z1=%.2f yol_y=%.2f yol_z=%.2f ic_z=%.2f on_z=%.2f" % [
		sur.gedik(), sur.gedik_en(), sur.gedik_bosluk(), sur.dis_sur_z0(), sur.dis_sur_z1(), sur.dis_yol_y(), sur.dis_yol_z(),
		sur.dis_yol_ic_z(), sur.dis_yol_on_z()])
	print("SONDA5 ana teras=%s hendek=[%.2f..%.2f] dip=%.2f ova_y=%.2f ova_ofs=%s gecis=%s" % [sur.teras(), sur.hendek_z0(),
		sur.hendek_z1(), sur.hendek_dip_y(), sur.ova_y(), sur.ova_ofs(), sur.gecisler()])
	print("SONDA5 ana dis_kuleler=%s kule_bosluk=%.2f ic_kuleler=%s ic_yol_y=%.2f ic_yol_z=%.2f depo=%s gedik_onu=%s peribolos=%s poterna=%.2f" % [
		sur.dis_kuleler(), sur.dis_kule_bosluk(), sur.ic_kuleler(), sur.ic_yol_y(), sur.ic_yol_z(), sur.depo(), sur.gedik_onu(),
		sur.peribolos(), sur.poterna_x()])
	var mz: Array = []
	for m: Dictionary in sur.a.mazgallar("dis"):
		var mx: float = (m["ayak"]["yerel"] as Vector3).x + sur.ofs.x
		if mx > -40.0 and mx < 40.0:
			mz.append(snappedf(mx, 0.01))
	mz.sort()
	print("SONDA5 mazgal_dis=%s" % [mz])
	var space := get_world_3d().direct_space_state
	for z: float in [sur.dis_yol_ic_z(), sur.dis_yol_z(), sur.dis_yol_on_z(), sur.dis_sur_z1() - 0.2]:
		var x := -24.0
		while x <= 14.0:
			var r := _ray(space, Vector3(x, 0, z), sur.dis_yol_y() + 3.0, sur.dis_yol_y() - 4.0)
			print("SONDA5 yol x=%.1f z=%.2f y=%.2f ad=%s bos=%s" % [x, z, r[0], r[1], sur.dis_yol_bos(x)])
			x += 0.5
	for x: float in [-3.0, -2.5, 0.0, -6.0, -8.0]:
		var z := sur.dis_sur_z1() - 1.0
		while z < sur.hendek_z1() + 6.0:
			var r := _ray(space, Vector3(x, 0, z), sur.dis_yol_y() - 0.5, -20.0)
			print("SONDA5 iz x=%.1f z=%.1f zemin=%.2f isin=%.2f ad=%s" % [x, z, sur.zemin_y(x, z), r[0], r[1]])
			z += 1.0
	# peribolos noktaları (22: ateş halkaları, onarım ekibi)
	for p: Vector3 in [Vector3(-14, 0, 7.5), Vector3(13, 0, 8.5), Vector3(-27, 0, 8.0), Vector3(9.0, 0, 15.0)]:
		print("SONDA5 engel p=%s engelde=%s" % [p, sur.engelde(p)])
	get_tree().quit(0)
