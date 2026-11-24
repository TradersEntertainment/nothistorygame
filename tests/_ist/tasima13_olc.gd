extends Node
## TAŞIMA-13 ölçümü (31o yeni sette, v2 şehri): bölümü gerçek akışında açar (ilk konuşmada bekler) ve ölçer:
##   · v2 evleri: caddenin şeridinin (IstBaglama.OYUN_31O) çevresinde uzaklık kuşaklarında ev sayısı (boşluk ne kadar);
##   · cadde temiz mi: caddenin oyun alanında (OYUN_31O, 1 m içeride) v2 evi ve kalabalıktan kişi yok (20 sn boyunca);
##   · kalabalık: etkin kişi, oyuncuya 90 m içinde sivil/devriye.
##   godot --headless --path . res://tests/_ist/tasima13_olc.tscn -- --yenisur=31o
## Satırlar: T13OLC … · T13OLC PASS|FAIL

var ok := true


func _ready() -> void:
	GameState.settings["auto_advance"] = false
	var ch := (load("res://scenes/chapter31o.tscn") as PackedScene).instantiate() as Node3D
	get_tree().root.add_child.call_deferred(ch)
	_olc.call_deferred(ch)


func _olc(ch: Node3D) -> void:
	var t := 0.0
	while (ch.get("city") == null or not IstBaglama.aktif()) and t < 200.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	if not IstBaglama.aktif():
		print("T13OLC v2 yok (eski set?)")
		print("T13OLC FAIL")
		get_tree().quit(1)
		return
	for i in 60:
		await get_tree().process_frame
	var kok := IstBaglama.kok
	var sahne := kok.get_parent() as Node3D
	var oy: Rect2 = IstBaglama.OYUN_31O
	# v2 evleri (IstSehir sokak planı): kuşaklar
	var s := IstSehir.active
	var sk = s.get("sokak") if s != null else null
	var kus := {}
	var icerde := 0
	if sk != null:
		for h: Dictionary in sk.houses:
			var c: Vector2 = h["c"]
			var q := sahne.to_local(kok.to_global(Vector3(c.x, 0.0, c.y)))
			var dx := maxf(0.0, maxf(oy.position.x - q.x, q.x - oy.end.x))
			var dz := maxf(0.0, maxf(oy.position.y - q.z, q.z - oy.end.y))
			var d := Vector2(dx, dz).length()
			if d <= 0.0:
				icerde += 1
			elif d < 100.0:
				var k := int(d / 10.0) * 10
				kus[k] = int(kus.get(k, 0)) + 1
	var ks := kus.keys()
	ks.sort()
	var satir := ""
	for k in ks:
		satir += " %d-%d:%d" % [k, k + 10, kus[k]]
	print("T13OLC evler_cadde_icinde=%d kusaklar(m:ev)%s" % [icerde, satir])
	# caddenin çevresinde v2'nin mahalle türü (ev sıklığını v2'nin mahalle haritası belirler)
	var tr_ := ""
	for p: Vector3 in [Vector3(-40, 0, -20), Vector3(40, 0, -20), Vector3(-40, 0, -70), Vector3(40, 0, -70), Vector3(0, 0, -130), Vector3(-90, 0, -60), Vector3(90, 0, -60)]:
		var w := kok.to_local(sahne.to_global(p))
		tr_ += " (%.0f,%.0f):%s" % [p.x, p.z, String(IstGeo.mahalle(w.x, w.z).get("tur", "?"))]
	print("T13OLC mahalle%s" % tr_)
	if icerde > 0:
		ok = false
	# kalabalık: 20 sn, caddenin içine giren var mı
	var yk := IstHayatYakin.aktif
	var giren := 0
	var en_yakin := INF
	var tt := 0.0
	while tt < 20.0:
		await get_tree().process_frame
		tt += get_process_delta_time()
		if yk == null or not is_instance_valid(yk):
			break
		var g := (yk.get_parent() as Node3D).global_transform
		for ag in yk.active_list():
			var q := sahne.to_local(g * (ag.pos as Vector3))
			if oy.grow(-1.0).has_point(Vector2(q.x, q.z)):
				giren += 1
			var dx := maxf(0.0, maxf(oy.position.x - q.x, q.x - oy.end.x))
			var dz := maxf(0.0, maxf(oy.position.y - q.z, q.z - oy.end.y))
			en_yakin = minf(en_yakin, Vector2(dx, dz).length())
	var pl := get_tree().get_first_node_in_group("player") as Node3D
	var civ := 0
	var pat := 0
	if yk != null and is_instance_valid(yk):
		var g := (yk.get_parent() as Node3D).global_transform
		for ag in yk.active_list():
			if (g * (ag.pos as Vector3)).distance_to(pl.global_position) <= IstHayatYakin.NEAR:
				if ag.kind == "patrol":
					pat += 1
				else:
					civ += 1
	print("T13OLC kalabalik etkin=%d sivil90=%d devriye90=%d caddeye_giren_ornek=%d caddeye_en_yakin_m=%.1f" % [
		yk.active_list().size() if yk != null and is_instance_valid(yk) else 0, civ, pat, giren, en_yakin])
	if giren > 0:
		ok = false
	print("T13OLC %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
