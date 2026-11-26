extends "res://tests/_ist/tasima12_kare.gd"
## G22b kare aracı (tasima12_kare'nin sürüşü; arayüz gizli): sur ardı dolgusunun bakışları. ÖNCE (37ae2b7d) ve SONRA aynı
## araçla, aynı kamerayla.
##   xvfb-run … godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/g22b_kare.tscn -- \
##       bolum=23|6|uzak7 shots=KLASÖR [yalniz=a,b]
## Satırlar: T10KARE_YUKLE · T10KARE ad=… cizim=… ilkel=… · G22BKARE ad=… goz=… · T10KARE_BITTI


## Hub yereli (sur parçası; y hub kökenine göre) → sahne
func _hub(l: Vector3) -> Vector3:
	var w: Vector3 = SurHub.hub_v2() * l
	return IstBaglama.kok.to_global(w)


## v2 dünya (x, z) → sahne; y arazinin üstünde
func _yer(w: Vector2, dy: float) -> Vector3:
	return IstBaglama.kok.to_global(Vector3(w.x, IstGeo.h(w.x, w.y) + dy, w.y))


## Hub yereli (x, z) → arazinin üstünde dy
func _hub_yer(x: float, z: float, dy: float) -> Vector3:
	var w: Vector3 = SurHub.hub_v2() * Vector3(x, 0.0, z)
	return _yer(Vector2(w.x, w.z), dy)


func _bakislar() -> Array:
	match bolum:
		"23":
			var out: Array = []
			for b: Array in super._bakislar():
				if String(b[0]) in ["01_caddeden_sur", "05_tepeden"]:
					out.append(b)
			var so := SurHub.SARAY_OFS
			out.append(["11_yol_kapiya", _hub_yer(-30.0, -14.25, 1.7), _hub(Vector3(33.0, 3.5, 5.5)), null])
			var sk: IstSokak = IstSehir.sokak
			for lx: float in [-20.0, -24.0, -28.0, -30.0, -34.0, -40.0]:
				var lz := -14.25 if lx > -24.0 else -14.25 + (lx + 24.0) * -0.25
				var w3: Vector3 = SurHub.hub_v2() * Vector3(lx, 0.0, lz)
				var md = IstMahalleDoku.aktif
				var k := sk._ix(w3.x, w3.z)
				var sp := IstBaglama.kok.get_world_3d().direct_space_state
				var g0 := IstBaglama.kok.to_global(Vector3(w3.x, 50.0, w3.z))
				var hit := sp.intersect_ray(PhysicsRayQueryParameters3D.create(g0, g0 + Vector3(0, -100, 0)))
				if lx == -30.0:
					var pp := IstBaglama.kok.to_global(Vector3(w3.x, 14.0, w3.z))
					for mi: MeshInstance3D in get_tree().root.find_children("*", "MeshInstance3D", true, false):
						if not mi.is_visible_in_tree() or mi.mesh == null:
							continue
						var bb := mi.global_transform * mi.get_aabb()
						if pp.x > bb.position.x and pp.x < bb.end.x and pp.z > bb.position.z and pp.z < bb.end.z and bb.end.y > pp.y - 1.0 and bb.position.y < pp.y + 1.0:
							print("G22BKARE dbg_mesh %s aabb_y=%.3f..%.3f boy=%s" % [mi.get_path(), bb.position.y, bb.end.y, bb.size])
				print("G22BKARE dbg lx=%.0f occ=%d rid=%d h=%.3f zy=%.3f hub_y=%.3f carp=%s %s" % [lx, sk.occ[k], sk.rid[k], IstGeo.h(w3.x, w3.z), md._zy(w3.x, w3.z) if md != null else -99.0, SurHub.hub_v2().origin.y, IstBaglama.kok.to_local(hit["position"]).y if hit else -99.0, hit["collider"].name if hit else ""])
			var J: Vector2 = _dl(sk).get("J", Vector2.INF) if sk != null else Vector2.INF
			if J != Vector2.INF:
				out.append(["12_yol_saraya", _yer(J, 1.7), _hub(so + Vector3(-14.0, 6.0, -13.0)), null])
			else:
				out.append(["12_yol_saraya", _hub_yer(-48.0, -14.0, 1.7), _hub(so + Vector3(-14.0, 6.0, -13.0)), null])
			out.append(["17_nobet_acikligi", _hub_yer(-6.0, -24.0, 2.5), _hub_yer(12.0, -2.0, 0.5), null])
			out.append(["18_kenar_bordur", _hub_yer(12.5, -31.0, 1.3), _hub(Vector3(18.0, 0.0, -24.0)), null])
			out.append(["19_tepeden_yakin", _hub(Vector3(-25.0, 70.0, -12.0)), _hub(Vector3(-10.0, 0.0, -8.0)), null])
			out.append(["24_dik_tepeden", _hub(Vector3(-18.0, 110.0, -6.0)), _hub(Vector3(-18.0, 0.0, -10.0)), null])
			out.append(["25_kapi_onu", _hub_yer(6.0, -6.0, 1.7), _hub(Vector3(26.0, 3.0, 4.0)), null])
			out.append(["28_yol_bati_ustten", _hub_yer(-26.0, -30.0, 18.0), _hub_yer(-30.0, -12.0, 0.0), null])
			if "--arazi-gizle" in OS.get_cmdline_user_args():
				for n: Node in get_tree().root.find_children("Arazi_*", "", true, false):
					(n as Node3D).visible = false
			out.append(["27_bant_yakin", _hub_yer(5.0, -24.0, 1.6), _hub_yer(11.0, -19.0, 0.0), null])
			out.append(["26_yoldan_kapi_yakin", _hub_yer(-4.0, -14.25, 1.7), _hub(Vector3(34.0, 6.0, -6.0)), null])
			out.append(["20_saray_kose", _hub(so + Vector3(40.0, 40.0, 40.0)), _hub(so + Vector3(-14.0, 0.0, -13.0)), null])
			if sk != null and _dl(sk).has("taban"):
				out.append_array(_yakinlar(sk))
			return out
		"uzak7", "uzak11":
			# G22b: uzak bakışlarda v2'nin yakın katmanları (evler, yamalar, öğeler) kameraya göre akışla kurulur: ağaç
			# duraklatılmışken (tasima12) akış durur, kamera hub'a gidince yakın katman hiç gelmez. Kareler için akış açık.
			get_tree().paused = false
			var out: Array = []
			for b: Array in super._bakislar():
				if String(b[0]) in ["03_uzak_saray_havadan", "04_uzak_iki_parca"]:
					out.append(b)
			# D13: hub dairesine 150 m, 400 m ve 1 km'den (yakın–uzak geçişinde dolgu kaybolmamalı)
			var hv: Transform3D = IstBaglama.kok.global_transform * SurHub.hub_v2()
			var hedef := hv * Vector3(-20.0, 0.0, -10.0)
			out.append(["29_uzak_dik", hv * Vector3(-20.0, 160.0, -9.0), hedef, null])
			out.append(["30_uzak_bant", hv * Vector3(-8.0, 14.0, -50.0), hv * Vector3(8.0, 0.0, -28.0), null])
			for e: Array in [["21_d13_150m", 150.0], ["22_d13_400m", 400.0], ["23_d13_1km", 1000.0]]:
				var d := float(e[1])
				var yon := (hv.basis * Vector3(-0.55, 0.0, 0.8)).normalized()
				out.append([e[0], hedef + yon * d * 0.85 + Vector3(0, d * 0.5, 0), hedef, null])
			# arazinin yakın katmanı izleyiciye (oyuncu) göre kurulur: oyuncu kameranın 3 m altına (uçuşta Nihat oradadır)
			for b: Array in out:
				b[3] = (b[1] as Vector3) + Vector3(0, -3.0, 0)
			return out
	return super._bakislar()


## Dolgunun içinden 0,5–3 m yakın: bostan, bağ, ev, harabe
func _yakinlar(sk: IstSokak) -> Array:
	var tb: Dictionary = _dl(sk)["taban"]
	var out: Array = []
	var bul := {}
	for i in range(int(tb["doku"]), sk.doku.size()):
		var d: Dictionary = sk.doku[i]
		var t := String(d["tur"])
		var k := "harabe" if (t.begins_with("harabe") or t == "harap_kilise") else t
		if not bul.has(k):
			bul[k] = d
	for k: String in ["bostan", "bag", "bahce", "harabe"]:
		if not bul.has(k):
			continue
		var d: Dictionary = bul[k]
		var c: Vector2 = d["c"]
		var al: Vector2 = d["alan"]
		var yw := float(d["yaw"])
		var u := Vector2(cos(yw), -sin(yw))
		var v := Vector2(sin(yw), cos(yw))
		var goz := c + v * (al.y * 0.5 + 2.2) + u * (al.x * 0.2)
		out.append(["3%d_yakin_%s" % [out.size(), k], _yer(goz, 1.6), _yer(c + u * (al.x * 0.1), 0.4), null])
		print("G22BKARE ad=%s c=%s alan=%s" % [k, c, al])
	if sk.houses.size() > int(tb["houses"]):
		var h: Dictionary = sk.houses[int(tb["houses"])]
		var c: Vector2 = h["c"]
		var on: Vector2 = h["on"]
		var goz := on + (on - c).normalized() * 2.6 + (on - c).normalized().orthogonal() * 1.5
		out.append(["3%d_yakin_ev" % out.size(), _yer(goz, 1.6), _yer(c, 2.2), null])
		print("G22BKARE ad=ev c=%s" % [c])
	return out


## IstSokak.dolgu (tabanda — 37ae2b7d — yok: boş)
func _dl(sk: IstSokak) -> Dictionary:
	var d = sk.get("dolgu")
	return d if d is Dictionary else {}


## Uzak bakışlarda arazi parçaları kameraya (izleyici yoksa kamera) göre yeniden kurulur (kare bütçesiyle): çekimden önce
## bekle, yakın parçalar gelsin (yoksa kaba katman hub düzlemesini örter: G22'nin sahip_3 karesi)
func _cek(ad: String) -> void:
	if bolum.begins_with("uzak"):
		await _bekle(14.0)
	await super._cek(ad)
