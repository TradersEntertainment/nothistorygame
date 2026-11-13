extends "res://tests/_ist/birlik_kare.gd"
## TUR-7 göz yüksekliği (1,62 m) kareleri: sur kuşağında oyuncunun göreceği 8 bakış (şehir sahnesi, gerçek kurucu).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur7_kare.tscn --
##       --set=uret --out=KLASÖR --kam=DOSYA     (kameraları sözleşme arayüzünden + aşağı ışınla kurar, listeyi yazar)
##       --set=liste --liste=DOSYA --out=KLASÖR  (birlik_kare ile aynı: mutlak liste)
## Konumlar Mesoteikhion / Romanos kesiminin yerel çerçevesinden (sur_oyun.gd arayuz) dünyaya çevrilir; yer yüksekliği
## kare anında aşağı ışınla bulunur (şehir dilimlemesi kesimden 1–2 m sapabilir), göz = yer + 1,62.

const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")
const GOZ := 1.62


func _uret() -> void:
	var a: RefCounted = SurOyun.arayuz("mesoteikhion")
	var r: RefCounted = SurOyun.arayuz("romanos")
	var d: Dictionary = a.d
	var zi0 := float(d["zi0"])
	var zo1 := float(d["zo1"])
	var zm0 := float(d["zm0"])
	var zm1 := float(d["zm1"])
	var OH := float(d["OH"])
	var dy: float = a.dy
	var zc: float = a.zc_dis()
	# [ad, kesim, göz yerel (y: ışın başlangıcı), hedef yerel, ışın]
	var liste := [
		["c1_sur_dibi_ic_yuz", a, Vector3(12.0, 0.0, zi0 - 6.0), Vector3(17.0, 3.0, zi0)],
		["c2_peribolos_iki_sur_arasi", a, Vector3(22.0, 0.0, 10.2), Vector3(52.0, 2.2, 10.0)],
		["c3_dis_sur_dibi_teras", a, Vector3(16.0, dy, (zo1 + zm0) * 0.5 + 1.0), Vector3(-14.0, dy + 3.5, zo1 + 0.5)],
		["c4_hendek_dibinden_yukari", a, Vector3(10.0, dy - 6.0, (zm0 + zm1) * 0.5), Vector3(4.0, dy + 6.0, zo1)],
		["c5_hendek_dis_kiyisindan", a, Vector3(22.0, dy, zm1 + 5.0), Vector3(6.0, dy + 4.0, zo1)],
		["c6_kule_dibinden_yukari", a, Vector3(5.5, 0.0, 13.6), Vector3(-1.6, 17.0, 7.0)],
		["c7_mazgaldan_ordugaha", a, Vector3(4.0, OH, zc), Vector3(4.0, dy - 4.0, 260.0)],
		["c8_romanos_kapi_onu", r, Vector3(-3.0, r.dy, float(r.d["zm1"]) + 12.0), Vector3(0.0, 3.0, float(r.d["zo1"]))],
	]
	for c: Array in liste:
		var k: RefCounted = c[1]
		var gl: Vector3 = c[2]
		var hl: Vector3 = c[3]
		var w: Vector3 = k.dunya(gl)
		var hw: Vector3 = k.dunya(hl)
		cam.global_position = w + Vector3(0, 30.0, 0)
		await _bekle()
		var y := _yer_isin(w, w.y + 30.0 if c[0] != "c7_mazgaldan_ordugaha" else w.y + 4.0)
		if is_nan(y):
			y = w.y
		var goz := Vector3(w.x, y + GOZ, w.z)
		print("TUR7 kam %s beklenen_y=%.2f bulunan_y=%.2f" % [c[0], w.y, y])
		await _bak(c[0], goz, hw)


func _yer_isin(w: Vector3, ust: float) -> float:
	var ss := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(Vector3(w.x, ust, w.z), Vector3(w.x, w.y - 40.0, w.z))
	var h := ss.intersect_ray(q)
	if h.is_empty():
		return NAN
	return (h["position"] as Vector3).y
