extends Node3D
## SUR OYUN arayüzü denetimi (başsız): kesim sahnesini SurOyun.kur ile kurar, arayüzün her noktasını gerçek çarpışmayla
## doğrular (dünya koordinatında ışın ve şekil sorgusu).
##   timeout 300 godot --headless --path . res://tests/_ist/sur_oyun_denetim.tscn [-- --kesim=mesoteikhion,romanos]
## Ölçütler (sabit; gevşetme yok):
##   zemin noktası: noktanın 1,0 m üstünden aşağı ışın; ilk çarpma |y − nokta.y| ≤ 0,25 → tamam;
##     çarpma yok ya da 0,25 m'den aşağıda → havada; 0,25 m'den yukarıda → gomuk
##     ayrıca nokta +0,5 ve +1,2 m'de 0,25 m yarıçaplı küre bir katıya değiyorsa → katida (kişi duramaz)
##   duvar noktası (dayama tepesi): tepenin 0,6 m altında ovadan duvara yatay ışın; dış yüze (zo1) 0,3 m'den uzaksa → havada
## Son satır: SUROYUN nokta=<n> havada=<n> gomuk=<n> katida=<n>
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")

var kesimler := ["mesoteikhion", "romanos", "kharisios"]
var top := {"nokta": 0, "havada": 0, "gomuk": 0, "katida": 0}


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--kesim="):
			kesimler = Array(a.trim_prefix("--kesim=").split(","))
	_kos.call_deferred()


func _kos() -> void:
	for id: String in kesimler:
		var t0 := Time.get_ticks_msec()
		var k: Dictionary = SurOyun.kur(id, {"ebeveyn": self, "uzak": false, "asama": 1, "dolgu": 1.0, "kalas": true, "poterna_acik": true, "merdiven": []})
		print("SUROYUN_KUR %s ms=%d %s" % [id, Time.get_ticks_msec() - t0, k["ms"]])
		for i in 6:
			await get_tree().physics_frame
		_denetle(id, k["arayuz"])
		(k["kok"] as Node).queue_free()
		for i in 3:
			await get_tree().physics_frame
	print("SUROYUN nokta=%d havada=%d gomuk=%d katida=%d" % [top["nokta"], top["havada"], top["gomuk"], top["katida"]])
	get_tree().quit(0)


func _ray(a: Vector3, b: Vector3) -> Dictionary:
	var sp := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(a, b)
	return sp.intersect_ray(q)


func _kure(p: Vector3, r: float) -> Array:
	var sp := get_world_3d().direct_space_state
	var sh := SphereShape3D.new()
	sh.radius = r
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = sh
	q.transform = Transform3D(Basis(), p)
	return sp.intersect_shape(q, 4)


func _denetle(id: String, a: RefCounted) -> void:
	var say := {}
	var kotu: Array = []
	var up: Vector3 = a.xf.basis * Vector3.UP
	var ez: Vector3 = a.xf.basis * Vector3.BACK
	for nk: Dictionary in a.noktalar():
		var tur := String(nk["tur"])
		var p: Vector3 = nk["n"]["dunya"]
		if not say.has(tur):
			say[tur] = [0, 0, 0, 0]
		say[tur][0] += 1
		top["nokta"] += 1
		var sonuc := "tamam"
		if String(nk["bek"]) == "duvar":
			var yp := p - up * 0.6
			var h := _ray(yp + ez * 2.0, yp - ez * 2.0)
			if h.is_empty():
				sonuc = "havada"
			else:
				var lz := (a.yerel(h["position"]) as Vector3).z
				if absf(lz - float(a.d["zo1"])) > 0.3:
					sonuc = "havada"
		else:
			var h2 := _ray(p + up * 1.0, p - up * 3.0)
			if h2.is_empty():
				sonuc = "havada"
			else:
				var hy: float = (h2["position"] as Vector3).y
				if hy < p.y - 0.25:
					sonuc = "havada"
				elif hy > p.y + 0.25:
					sonuc = "gomuk"
			if sonuc == "tamam":
				var c1 := _kure(p + up * 0.5, 0.25)
				var c2 := _kure(p + up * 1.2, 0.25)
				if not c1.is_empty() or not c2.is_empty():
					sonuc = "katida"
		if sonuc != "tamam":
			var ix: int = {"havada": 1, "gomuk": 2, "katida": 3}[sonuc]
			say[tur][ix] += 1
			top[sonuc] += 1
			var lv: Vector3 = nk["n"]["yerel"]
			var ek := ""
			if sonuc != "katida" and String(nk["bek"]) != "duvar":
				var h3 := _ray(p + up * 1.0, p - up * 3.0)
				ek = " zemin=%s" % ("yok" if h3.is_empty() else "%.2f" % (a.yerel(h3["position"]) as Vector3).y)
			elif sonuc == "katida":
				var c := _kure(p + up * 0.5, 0.25) + _kure(p + up * 1.2, 0.25)
				var co: Object = c[0]["collider"] if c.size() > 0 else null
				ek = " carpan=%s" % (str(co.get_path()).get_slice("/", 4) + "/" + (co as Node).name if co is Node else "?")
			kotu.append("%s/%s %s yerel=(%.1f,%.2f,%.1f)%s" % [tur, nk["ad"], sonuc, lv.x, lv.y, lv.z, ek])
	var turler: Array = say.keys()
	turler.sort()
	for t in turler:
		print("SUROYUN_TUR %s %s nokta=%d havada=%d gomuk=%d katida=%d" % [id, t, say[t][0], say[t][1], say[t][2], say[t][3]])
	for s in kotu.slice(0, 60):
		print("SUROYUN_KOTU %s %s" % [id, s])
	# yer bilgisi (dünya)
	print("SUROYUN_YER %s xf_origin=%s yaw=%.1f dy=%.2f gx=%s gedikler_yerel=%s" % [id, a.xf.origin, rad_to_deg(a.xf.basis.get_euler().y), a.dy, a.gx,
		a.gedikler_yerel() if a.id == "mesoteikhion" else []])
