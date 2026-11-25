extends SceneTree
## CI #345 ESYATEST gomuk=1 sondası: kalası, yerelde yakalanan hatalı pozda (ESYA_IZ izi: y 0,020, dönüş (−0,2; −35,8; −7,7),
## alt köşesi 4,8 cm zeminin içinde) zorla dondurur (EsyaFizik._dondur(e, true): uyanık sınırındaki gibi).
## Beklenen (düzeltmeden sonra): gömük sayılmaz, gövde zeminin üstüne alınır.
## Kullanım: godot --headless --path . -s tests/_ci344/esya_gomuk_sonda.gd
func _initialize() -> void:
	_run()


func _run() -> void:
	var P = load("res://scripts/level/props.gd")
	var EF = load("res://scripts/level/esya_fizik.gd")
	var sc := Node3D.new()
	sc.name = "SondaSahne"
	root.add_child(sc)
	current_scene = sc
	# düz zemin (üstü y = 0)
	var zemin := StaticBody3D.new()
	var zs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(20, 1, 20)
	zs.shape = bs
	zemin.add_child(zs)
	zemin.position = Vector3(0, -0.5, 0)
	sc.add_child(zemin)
	await physics_frame
	var sonuc := []
	for poz in [[Vector3(-0.2, -35.8, -7.7), 0.020]]:
		var k: Node3D = P.box(sc, Vector3(0.24, 0.1, 2.4), Vector3(sonuc.size() * 3.0 - 3.0, 0.05, 0), Color("8a6440"))
		EF.kaydet_dugum(k, P.make_solid(k), "kalas")
		for i in 4:
			await physics_frame
		var ef = EF.ben()
		if ef == null:
			print("ESYAGOMUKSONDA esyafizik_yok")
			quit(1)
			return
		var e: Dictionary = {}
		for o in ef.items:
			if o["tur"] == "kalas" and (o["xf"] as Transform3D).origin.distance_to(k.global_position) < 0.5 and not sonuc.has(o["id"]):
				e = o
		if e.is_empty():
			print("ESYAGOMUKSONDA kalas_yok")
			quit(1)
			return
		ef._uyandir(e)
		for i in 3:
			await physics_frame
		var g: RigidBody3D = e["govde"]
		var x0: Vector3 = (e["xf"] as Transform3D).origin
		g.freeze = true
		g.global_transform = Transform3D(Basis.from_euler(Vector3(deg_to_rad(poz[0].x), deg_to_rad(poz[0].y), deg_to_rad(poz[0].z))), Vector3(x0.x, poz[1], x0.z))
		var cs := g.get_child(0) as CollisionShape3D
		var alt0: float = ef._alt_nokta(g, cs)
		var gomuk0: int = int(ef.sayac["gomuk"])
		ef._dondur(e, true)
		var gomuk := int(ef.sayac["gomuk"]) - gomuk0
		var g2 = e["govde"]
		var y1: float = (g2 as Node3D).global_position.y if g2 != null and is_instance_valid(g2) else -99.0
		var alt1: float = ef._alt_nokta(g2, (g2 as Node).get_child(0)) if g2 != null and is_instance_valid(g2) else -99.0
		print("ESYAGOMUKSONDA poz=%s y0=%.3f alt0=%.3f -> gomuk=%d durum=%s y=%.3f alt=%.3f" % [poz[0], poz[1], alt0, gomuk, e["durum"], y1, alt1])
		sonuc.append(e["id"])
	quit(0)
