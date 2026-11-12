extends "res://tests/_ist/gezi.gd"
## BİTKİ yer sondası (4. tur): gezi kareleri bittikten sonra (bos=1 ile) dünyadaki bütün kit ağaçlarını sayar.
##   godot --path . res://tests/_ist/bitki_yer_sonda.tscn -- liste=DOSYA shots=KLASÖR bos=1
## Ağaç = ağı "bitki_kit" imli MultiMesh örneği ya da MeshInstance3D (çalı ve kütük ayrı sayılır).
## yolda: IstSokak sokak çizgisine (genişlik/2 − 0,3 m) içinde; evde: şehir ev MultiMesh örneğinin taban kutusu
## (0,3 m içeri) içinde; suda: IstGeo.su; ates: sur dışı (şehir ve Galata dışı), kara suruna 260 m'den yakın
## (hendekten ~200 m). Satır: ISTBITKI agac=… yolda=… evde=… suda=… ates=… kutuk_ates=… beyaz=…


func _bos_say() -> void:
	var t0 := Time.get_ticks_msec()
	var agaclar: Array = []          # [Vector3, tur]
	var evler: Array = []            # [Transform3D (global), AABB]
	var meshler := {}
	var yigin: Array = [get_tree().root]
	while not yigin.is_empty():
		var n: Node = yigin.pop_back()
		for c in n.get_children():
			yigin.append(c)
		if n is MultiMeshInstance3D:
			var mm := (n as MultiMeshInstance3D).multimesh
			if mm == null or mm.mesh == null:
				continue
			var gt := (n as Node3D).global_transform
			var cnt := mm.visible_instance_count if mm.visible_instance_count >= 0 else mm.instance_count
			if mm.mesh.has_meta("bitki_kit"):
				meshler[mm.mesh] = true
				for k in cnt:
					agaclar.append([gt * mm.get_instance_transform(k).origin, String(mm.mesh.get_meta("bitki_kit"))])
			elif _ev_mi(n):
				var ab := mm.mesh.get_aabb()
				var anah := "%d_%d" % [int(ab.size.x), int(ab.size.y)]
				_ust_say[anah] = int(_ust_say.get(anah, 0)) + cnt
				for k in cnt:
					var xf := gt * mm.get_instance_transform(k)
					var sc := xf.basis.get_scale()
					var ws := ab.size * sc
					if ws.y > 2.5 and ws.x > 2.5 and ws.z > 2.5 and ws.x < 40.0 and ws.z < 40.0:
						evler.append([xf, ab])
		elif n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if mi.mesh != null and mi.mesh.has_meta("bitki_kit"):
				meshler[mi.mesh] = true
				if mi.has_meta("bitki_konum"):
					for kt: Array in mi.get_meta("bitki_konum"):
						agaclar.append([mi.global_transform * (kt[0] as Vector3), String(kt[1])])
				else:
					agaclar.append([mi.global_position, String(mi.mesh.get_meta("bitki_kit"))])
	# sokak ızgarası
	var izg := {}
	var sk: IstSokak = IstSehir.sokak
	if sk != null:
		for s: Dictionary in sk.streets:
			var pl: PackedVector2Array = s["pts"]
			var w: float = s["w"]
			for i in pl.size() - 1:
				var nn := maxi(1, int(pl[i].distance_to(pl[i + 1]) / 2.0))
				for k in nn + 1:
					var q := pl[i].lerp(pl[i + 1], float(k) / nn)
					var key := Vector2i(floori(q.x / 20.0), floori(q.y / 20.0))
					if not izg.has(key):
						izg[key] = []
					(izg[key] as Array).append([q, w])
	var evizg := {}
	for e: Array in evler:
		var o: Vector3 = (e[0] as Transform3D).origin
		var key := Vector2i(floori(o.x / 40.0), floori(o.z / 40.0))
		if not evizg.has(key):
			evizg[key] = []
		(evizg[key] as Array).append(e)
	var sur := IstGeo.yol("kara_suru")
	var say := {"agac": 0, "yolda": 0, "evde": 0, "suda": 0, "ates": 0, "kutuk_ates": 0, "cali": 0}
	var ornek: Dictionary = {"yolda": [], "evde": [], "suda": [], "ates": []}
	for a: Array in agaclar:
		var p: Vector3 = a[0]
		var tur: String = a[1]
		var p2 := Vector2(p.x, p.z)
		if tur == "kutuk":
			if not IstGeo.sehir_ici(p.x, p.z) and not IstGeo.galata_ici(p.x, p.z) and sur.size() > 1 and IstGeo.cizgi_uzak(p2, sur) < 260.0:
				say["kutuk_ates"] += 1
			continue
		if tur == "cali":
			say["cali"] += 1
		else:
			say["agac"] += 1
		var hatalar: Array = []
		if IstGeo.su(p.x, p.z):
			hatalar.append("suda")
		if tur != "cali" and not IstGeo.sehir_ici(p.x, p.z) and not IstGeo.galata_ici(p.x, p.z) and sur.size() > 1 and IstGeo.cizgi_uzak(p2, sur) < 260.0:
			hatalar.append("ates")
		var key := Vector2i(floori(p.x / 20.0), floori(p.z / 20.0))
		var yolda := false
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				for q: Array in izg.get(key + Vector2i(dx, dz), []):
					if (q[0] as Vector2).distance_to(p2) < float(q[1]) * 0.5 - 0.3:
						yolda = true
						break
		if yolda:
			hatalar.append("yolda")
		var ek := Vector2i(floori(p.x / 40.0), floori(p.z / 40.0))
		var evde := false
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				for e: Array in evizg.get(ek + Vector2i(dx, dz), []):
					var lp: Vector3 = (e[0] as Transform3D).affine_inverse() * (p + Vector3(0, 0.5, 0))
					var ab: AABB = (e[1] as AABB).grow(-0.3)
					if lp.x > ab.position.x and lp.x < ab.end.x and lp.z > ab.position.z and lp.z < ab.end.z:
						evde = true
						break
		if evde:
			hatalar.append("evde")
		for h: String in hatalar:
			say[h] += 1
			if (ornek[h] as Array).size() < 6:
				var r := IstGeo.real(p.x, p.z)
				(ornek[h] as Array).append("%s(%d,%d)" % [tur, int(r.x), int(r.y)])
	var beyaz := 0
	for m: Mesh in meshler:
		if m.has_meta("bitki_carpan"):
			continue        # karşı kıyı: köşe rengi ton çarpanı, asıl renk örnek rengiyle çarpımı (ayrıca sayılmaz)
		var cs = m.surface_get_arrays(0)[Mesh.ARRAY_COLOR]
		if cs != null:
			for c: Color in cs:
				if maxf(c.r, maxf(c.g, c.b)) > 0.92:
					beyaz += 1
	print("ISTBITKI agac=%d cali=%d yolda=%d evde=%d suda=%d ates=%d kutuk_ates=%d beyaz=%d ag=%d ev_ornek=%d sokak_hucre=%d sure_ms=%d" % [
		say["agac"], say["cali"], say["yolda"], say["evde"], say["suda"], say["ates"], say["kutuk_ates"], beyaz,
		meshler.size(), evler.size(), izg.size(), Time.get_ticks_msec() - t0])
	if evler.is_empty():
		print("ISTBITKI ev_tani ", _ust_say)
	for h: String in ornek:
		if not (ornek[h] as Array).is_empty():
			print("ISTBITKI ornek %s: %s" % [h, " ".join(ornek[h])])


## Şehir evi MultiMesh'i: IstSehir altında, ağı IstEvler'den (ev boyu kutu). Ad denetimi yok; boyut süzgeci.
var _ust_say := {}
func _ev_mi(n: Node) -> bool:
	var p := n.get_parent()
	while p != null:
		if p is IstSehir:
			return true
		p = p.get_parent()
	return false
