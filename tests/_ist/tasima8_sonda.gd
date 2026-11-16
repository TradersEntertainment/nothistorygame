extends SceneTree
## TAŞIMA 8 sondası: yeni setin bölüm çerçevesindeki yerleri (26/26o bağları için)
func _init() -> void:
	var s := SurSet.yeni("mesoteikhion")
	print("OFS ", s.ofs, " gedik ", s.gedik(), " dis_z0 ", s.dis_sur_z0(), " dis_z1 ", s.dis_sur_z1(), " dis_y ", s.dis_yol_y(), " dis_yol_z ", s.dis_yol_z())
	print("ic_z1 ", s.ic_sur_z1(), " ic_yol_y ", s.ic_yol_y(), " teras_y ", s.teras_y(), " hendek ", s.hendek_z0(), "..", s.hendek_z1(), " dip ", s.hendek_dip_y(), " ova ", s.ova_y(), " ova_ofs ", s.ova_ofs())
	print("ic_kuleler ", s.ic_kuleler())
	print("dis_kuleler ", s.dis_kuleler(), " kurulu ", s.dis_kuleler_kurulu(), " bosluk ", s.dis_kule_bosluk())
	print("poterna_x ", s.poterna_x(), " peribolos ", s.peribolos(), " depo ", s.depo(), " dogus ", s.dogus())
	for g in s.gecisler():
		print("gecis ", g)
	var dm: Array = s.a.dayamalar()
	for m in dm:
		print("dayama x=", float(m["x"]) + s.ofs.x)
	print("hucum ", s.hucum_merdivenleri([-10.5, 9.5, -24.0, 22.0, 28.0], 40.0))
	for yn in s.a.kesim["yan"]:
		print("yan ", yn["ad"], " x=", float(yn["x"]) + s.ofs.x, " L=", yn["L"], " sec=", yn["secenek"], " ickule=", yn["kule"]["ic"], " diskule=", yn["kule"]["dis"], " mer=", yn["merdiven"])
	print("merdiven ", s.a.kesim["merdiven"])
	for c in s.a.cikislar():
		print("cikis ", c["ad"], " alt ", s.c(c["alt"]["yerel"]), " ust ", s.c(c["ust"]["yerel"]))
	var mz: Array = s.a.mazgallar("dis")
	var xs := []
	for m in mz:
		var x: float = (m["ayak"]["yerel"] as Vector3).x + s.ofs.x
		if absf(x) < 45.0:
			xs.append(snappedf(x, 0.1))
	print("mazgal_dis ", xs)
	for r: Rect2 in s.a.engeller():
		var rr := Rect2(r.position + Vector2(s.ofs.x, s.ofs.z), r.size)
		if rr.intersects(Rect2(-70, -12, 110, 30)):
			print("engel ", rr)
	var ra = load("res://scripts/world/ist/sur_oyun.gd").arayuz("romanos")
	print("romanos kapi ", ra.kesim["kapi"], " d.zi0 ", ra.d["zi0"], " zi1 ", ra.d["zi1"], " zo0 ", ra.d["zo0"], " zo1 ", ra.d["zo1"])
	quit()
