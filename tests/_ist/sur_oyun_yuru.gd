extends Node3D
## SUR OYUN yürüyüş kanıtı (başsız): gerçek Player botu arayüzün verdiği yolları yürür (Mesoteikhion kesimi, kök orijinde
## = yerel çalışma). Her yol: süre, yol uzunluğu, takılma (8 sn ilerleme yok), düşme (dikey hız < −7 m/sn), son nokta.
##   timeout 400 godot --headless --path . res://tests/_ist/sur_oyun_yuru.tscn
## Satır: WALKTHRU <yol> sure=… yol=… takilma=<n> dusme=<n> son=(x,y,z) | wp günlüğü ; son satır WALKTHRU OZET …
## Hedef: takilma=0 dusme=0 (eşik sabit).
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")

var pl: Player
var a: RefCounted
var ozet := {"yol": 0, "takilma": 0, "dusme": 0, "tamam": 0}


func _ready() -> void:
	_kos.call_deferred()


func _kos() -> void:
	var k: Dictionary = SurOyun.kur("mesoteikhion", {"ebeveyn": self, "dunya": false, "uzak": false, "asama": 1, "dolgu": 1.0,
		"kalas": true, "poterna_acik": true, "merdiven": [1]})
	a = k["arayuz"]
	pl = Player.new()
	add_child(pl)
	pl.show_remote(false)
	for i in 8:
		await get_tree().physics_frame
	var d: Dictionary = a.d
	var HW := float(d["HW"])
	var OH := float(d["OH"])
	var zi0 := float(d["zi0"])
	var zo0 := float(d["zo0"])
	var zo1 := float(d["zo1"])
	var zm0 := float(d["zm0"])
	var zm1 := float(d["zm1"])
	var zc: float = a.zc_dis()
	var yt: float = a.y_teras()
	var yo: float = a.y_ova()
	var dy: float = a.dy
	# 1) şehir önü → iç taş merdiven (eteğin önünden, 3 m geriden) → iç sur yolu → dilimin +x ucu (kule geçidi dâhil)
	var ci: Dictionary = a.cikislar()[0]
	var ia: Vector3 = ci["alt"]["yerel"]
	var iu: Vector3 = ci["ust"]["yerel"]
	_tp(ia + Vector3(-3.0, 0.15, 0))
	await _bot("sehir_icmerdiven_icyol_uc", [ia + Vector3(1.6, 0.3, 0), iu, ci["yol"]["yerel"], Vector3(a.L * 0.5 - 2.0, HW, 0.0)])
	# 2) peribolos → dış taş merdiven → dış sur yolu → −x (dış kule üstünden)
	var cd: Dictionary = a.cikislar()[1]
	var da: Vector3 = cd["alt"]["yerel"]
	_tp(da + Vector3(-3.0, 0.15, 0))
	await _bot("peribolos_dismerdiven_disyol_kule", [da + Vector3(1.6, 0.3, 0), cd["ust"]["yerel"], cd["yol"]["yerel"], Vector3(-50.0, OH, zc)])
	# 3) teras → dayalı el merdiveni (dayama 1) → dış sur yolu → kule geçidi (−32,3) → öbür yan
	var dm: Dictionary = a.dayamalar()[1]
	var ay: Vector3 = dm["ayak"]["yerel"]
	_tp(Vector3(ay.x, yt + 0.15, ay.z + 3.0))
	await _bot("teras_eldmerdiven_disyol_kulegecidi", [Vector3(ay.x, yt, ay.z + 0.6), Vector3(ay.x, OH, zc), Vector3(-46.0, OH, zc)], 60.0, true)
	# 4) peribolos → poterna (açık) → sahanlık + dış basamak → teras → kalas köprü → ova → geri
	var pt: Dictionary = a.poterna()
	var px := float(pt["x"])
	var pdis: Vector3 = pt["dis"]["yerel"]
	_tp(Vector3(px, -0.12 + 0.15, zo0 - 3.0))
	await _bot("poterna_dasbasamak_kalas_ova_geri", [Vector3(px, -0.02, zc), Vector3(px, -0.02, zo1 + 0.65), pdis, Vector3(px, yt, zm0 - 2.4),
		Vector3(px, dy, zm1 + 2.0), Vector3(px, yo, zm1 + 12.0), Vector3(px, dy, zm1 + 2.0), Vector3(px, yt, zm0 - 2.4), pdis,
		Vector3(px, -0.02, zo1 + 0.65), Vector3(px, -0.12, zo0 - 3.0)])
	# 5) peribolos → gedik molozu (tepe) → teras → dolgu (dolu) → karşı yaka → ova
	var g: Dictionary = a.gedik()
	var gx: float = g["x"]
	_tp(Vector3(gx, -0.12 + 0.15, zo0 - 4.0))
	await _bot("gedik_moloz_dolgu_hendek_gecis", [g["moloz"]["tepe"]["yerel"], g["moloz"]["teras"]["yerel"],
		Vector3(gx, dy, zm0 + 5.0), Vector3(gx, dy, zm1 + 3.0), Vector3(gx, yo, zm1 + 10.0)])
	# 6) (karşılaştırma) hendek dolgusu yarımken: gedikten hendek dibine iniş (moloz dili) ve dolgu ucuna
	(k["parca"]["dolgu"]).doluluk(0.5)
	for i in 4:
		await get_tree().physics_frame
	_tp((g["moloz"]["teras"]["yerel"] as Vector3) + Vector3(0, 0.3, 0))
	await _bot("gedik_moloz_hendekdibine_dolgu_yarim", [Vector3(gx, dy, zm0 + 3.0), Vector3(gx + 4.5, a.y_hendek_dip(), zm0 + 17.5)])
	# 7) Romanos kesimi: şehir yakası → kapı eşiği → peribolos → dış kapı → kapı köprüsü (sağlam) → ova (4e: kapıda etek)
	(k["kok"] as Node).queue_free()
	for i in 3:
		await get_tree().physics_frame
	var k2: Dictionary = SurOyun.kur("romanos", {"ebeveyn": self, "dunya": false, "uzak": false, "kapi_kopru": "saglam", "kapi_acik": true})
	a = k2["arayuz"]
	for i in 6:
		await get_tree().physics_frame
	var kp: Dictionary = a.kapi()
	var ie: Vector3 = kp["ic_esik"]["yerel"]
	_tp(ie + Vector3(0, 0.15, -4.0))
	await _bot("romanos_kapi_peribolos_diskapi_kopru_ova", [ie, kp["peri"]["yerel"], kp["dis_esik"]["yerel"], kp["kopru_yakin"]["yerel"],
		kp["kopru_uzak"]["yerel"], Vector3(0.0, a.y_ova(), float(a.d["zm1"]) + 8.0)])
	print("WALKTHRU OZET yol=%d tamam=%d takilma=%d dusme=%d" % [ozet["yol"], ozet["tamam"], ozet["takilma"], ozet["dusme"]])
	get_tree().quit(0)


func _tp(p: Vector3) -> void:
	pl.global_position = p
	pl.velocity = Vector3.ZERO


func _bot(etiket: String, wps: Array, limit := 120.0, merdiven := false) -> void:
	pl.frozen = false
	Input.action_release("sprint")
	var t := 0.0
	var i := 0
	var iz := 0.0
	var best_d := 1e9
	var son := pl.global_position
	var yol := 0.0
	var logs: Array = []
	var takil := 0
	var dus := 0
	var dus_on := false
	while i < wps.size() and t < limit:
		var wp: Vector3 = wps[i]
		pl.face(Vector3(wp.x, pl.global_position.y + 1.4, wp.z))
		Input.action_press("move_forward")
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		t += dt
		yol += pl.global_position.distance_to(son)
		son = pl.global_position
		var p := pl.global_position
		if pl.velocity.y < -7.0 and not dus_on:
			dus += 1
			dus_on = true
			logs.append("DUSME wp%d at (%.1f,%.1f,%.1f)" % [i, p.x, p.y, p.z])
		elif pl.velocity.y > -2.0:
			dus_on = false
		var dd := Vector2(p.x - wp.x, p.z - wp.z).length()
		if pl.ladder != null:
			dd = absf(p.y - wp.y) + Vector2(p.x - wp.x, 0).length()
		if dd < best_d - 0.3:
			best_d = dd
			iz = t
		if Vector2(p.x - wp.x, p.z - wp.z).length() < 0.9 and absf(p.y - wp.y) < 1.2:
			logs.append("wp%d t=%.1f y=%.2f" % [i, t, p.y])
			i += 1
			iz = t
			best_d = 1e9
		elif t - iz > 8.0:
			takil += 1
			logs.append("TAKILDI wp%d at (%.1f,%.2f,%.1f) t=%.1f merdiven=%s" % [i, p.x, p.y, p.z, t, pl.ladder != null])
			break
	Input.action_release("move_forward")
	for k in 3:
		await get_tree().physics_frame
	var bitti := i >= wps.size()
	ozet["yol"] += 1
	ozet["takilma"] += takil + (0 if bitti or takil > 0 else 1)
	ozet["dusme"] += dus
	if bitti:
		ozet["tamam"] += 1
	print("WALKTHRU %s sure=%.1f yol=%.1f takilma=%d dusme=%d bitti=%s son=(%.1f,%.2f,%.1f) | %s" % [etiket, t, yol, takil, dus, bitti,
		pl.global_position.x, pl.global_position.y, pl.global_position.z, " | ".join(logs)])
