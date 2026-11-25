extends Node
## G21 ölçümü (ekransız): SARAY_OFS adaylarının eğimi, Lykos çizgisine / anıtlara uzaklığı; şeridin geometri denetimi.
##   godot --headless --path . res://tests/_ist/lykos21_olc.tscn
## Satırlar:
##   LYKOS21 hub …            hub kökeni, iç yüz, kara suru çizgisine uzaklık
##   LYKOS21 serit …          kapıların t'si, şeridin örnek noktaları
##   LYKOS21 saray_aday …     aday (hub x, z) → v2, ortalama y, eğim (en büyük / düzlem), Lykos uzaklığı, en yakın yer
##   LYKOS21 saray_secim …    SurHub.SARAY_OFS ölçümü

const SurHub := preload("res://scripts/world/ist/sur_set_hub.gd")
const ALAN := Vector2(84.0, 70.0)


func _ready() -> void:
	var xf: Transform3D = SurHub.hub_v2()
	var o := xf.origin
	var ic := xf * Vector3(SurHub.HUB_IC_X, 0, SurHub.KAPI_Z)
	var kara := IstGeo.yol("kara_suru")
	print("LYKOS21 hub kok=(%.1f,%.1f,%.1f) yaw=%.1f ic_yuz=(%.1f,%.1f) ic_yuz_kara_uzak=%.1f kok_kara_uzak=%.1f" % [o.x, o.y, o.z,
		rad_to_deg(atan2(xf.basis.x.z, xf.basis.x.x)), ic.x, ic.z, IstGeo.cizgi_uzak(Vector2(ic.x, ic.z), kara), IstGeo.cizgi_uzak(Vector2(o.x, o.z), kara)])
	var tdr := IstGeo.serit_td(IstGeo.w2(IstGeo.SERIT_ROMANOS.x, IstGeo.SERIT_ROMANOS.y).x, IstGeo.w2(IstGeo.SERIT_ROMANOS.x, IstGeo.SERIT_ROMANOS.y).y)
	var p2 := IstGeo.w2(IstGeo.SERIT_PEMPTON.x, IstGeo.SERIT_PEMPTON.y)
	var tdp := IstGeo.serit_td(p2.x, p2.y)
	print("LYKOS21 serit romanos_t=%.3f pempton_t=%.3f sur_boyu_gercek=%.0f" % [tdr.x, tdp.x, IstGeo._serit_sp - IstGeo._serit_sr])
	for hx: float in [0.0, -50.0, -100.0, -150.0, -200.0, -250.0, -300.0]:
		var q := xf * Vector3(hx, 0, 0)
		var td := IstGeo.serit_td(q.x, q.z)
		var m := IstGeo.mahalle(q.x, q.z)
		print("LYKOS21 serit hub_x=%.0f v2=(%.0f,%.0f) t=%.3f d=%.0f D=%.0f w=%.2f mahalle=%s/%s serit=%s" % [hx, q.x, q.z, td.x, td.y,
			IstGeo.serit_derinlik(td.x), IstGeo.lykos_seridi(q.x, q.z), m["tur"], m["alt"], str(m.get("serit", false))])
	# Kapsama: şeridin içindeki 24 m'lik hücrelerin tür dağılımı
	var say := {}
	var n := 0
	var lo := IstGeo.w2(-5000, 500)
	var hi := IstGeo.w2(-3900, 2200)
	var x := minf(lo.x, hi.x)
	while x < maxf(lo.x, hi.x):
		var z := minf(lo.y, hi.y)
		while z < maxf(lo.y, hi.y):
			if IstGeo.lykos_seridi(x, z) >= 0.5:
				var m := IstGeo.mahalle(x, z)
				var k := "%s/%s" % [m["tur"], m["alt"]]
				say[k] = int(say.get(k, 0)) + 1
				n += 1
			z += 24.0
		x += 24.0
	var parts: Array = []
	for k in say:
		parts.append("%s=%d(%.0f%%)" % [k, say[k], 100.0 * say[k] / maxf(n, 1)])
	print("LYKOS21 serit_hucre n=%d alan_ha=%.1f %s" % [n, n * 24.0 * 24.0 / 10000.0, " ".join(parts)])
	# Mozaik tuzu araması: alan oranları hedefe en yakın tuz (hub çevresi canlı tür: köy mahallesi ya da bostan)
	var hedef := {"bostan/bostan": 0.27, "bostan/bag": 0.15, "harabe/harabe": 0.14, "seyrek/": 0.30, "seyrek/manastir": 0.07, "seyrek/mezarlik": 0.07}
	var pts: Array = []
	x = minf(lo.x, hi.x)
	while x < maxf(lo.x, hi.x):
		var z := minf(lo.y, hi.y)
		while z < maxf(lo.y, hi.y):
			if IstGeo.lykos_seridi(x, z) >= 0.5:
				pts.append(IstGeo.real(x, z))
			z += 24.0
		x += 24.0
	var hubn: Array = []
	for hx2: float in [0.0, -40.0, -80.0, 30.0]:
		for hz2: float in [-60.0, 0.0, 60.0]:
			var q := xf * Vector3(hx2, 0, hz2)
			hubn.append(IstGeo.real(q.x, q.z))
	for tuz in 60:
		var d := {}
		for r: Vector2 in pts:
			var m := IstGeo._serit_ada(r, tuz)
			var k := "%s/%s" % [m["tur"], m["alt"]]
			d[k] = int(d.get(k, 0)) + 1
		var skor := 0.0
		for k in hedef:
			skor += absf(float(d.get(k, 0)) / maxf(pts.size(), 1) - float(hedef[k]))
		var canli := 0
		for r: Vector2 in hubn:
			var m := IstGeo._serit_ada(r, tuz)
			if String(m["tur"]) == "seyrek" and String(m["alt"]) == "":
				canli += 1
		var parts2: Array = []
		for k in d:
			parts2.append("%s=%.0f%%" % [k, 100.0 * d[k] / maxf(pts.size(), 1)])
		print("LYKOS21 tuz=%d skor=%.3f hub_koy=%d/%d %s" % [tuz, skor, canli, hubn.size(), " ".join(parts2)])
	# SARAY adayları
	var lyk := IstGeo.Y_LYKOS
	var best: Array = []
	for hx in range(-360, -421, -10):
		for hz in range(-120, 201, 10):
			var r := _olc(xf, Vector3(hx, 0, hz), lyk)
			print("LYKOS21 saray_aday hub=(%d,%d) v2=(%.0f,%.0f) y=%.2f egim_max=%.1f%% egim_duz=%.1f%% lykos=%.0f yer=%s/%.0f serit=%.2f" % [hx, hz,
				r["c"].x, r["c"].z, r["y"], r["egim_max"], r["egim_duz"], r["lykos"], r["yer"], r["yer_d"], r["serit"]])
	var s := _olc(xf, SurHub.SARAY_OFS, lyk)
	print("LYKOS21 saray_secim ofs=%s v2=(%.1f,%.2f,%.1f) saray_v2=%s y=%.2f egim_max=%.1f%% egim_duz=%.1f%% lykos=%.0f yer=%s/%.0f serit=%.2f" % [
		str(SurHub.SARAY_OFS), s["c"].x, s["y"], s["c"].z, str(SurHub.saray_v2()), s["y"], s["egim_max"], s["egim_duz"], s["lykos"], s["yer"], s["yer_d"], s["serit"]])
	var eski := Vector2(5.5 - SurHub.SARAY_OFS.z, -36.3 + SurHub.SARAY_OFS.x)
	print("LYKOS21 saray_eski_dunya x=%.1f z=%.1f" % [eski.x, eski.y])
	get_tree().quit()


func _olc(xf: Transform3D, ofs: Vector3, lyk: PackedVector2Array) -> Dictionary:
	var c := xf * ofs
	var hs: Array = []
	var pts: Array = []
	var smax := 0.0
	var serit := 0.0
	for j in 8:
		for i in 9:
			var l := ofs + Vector3(-ALAN.x * 0.5 + ALAN.x * i / 8.0, 0, -ALAN.y * 0.5 + ALAN.y * j / 7.0)
			var p := xf * l
			var y := IstGeo.h(p.x, p.z)
			hs.append(y)
			pts.append(Vector3(l.x, y, l.z))
			serit = maxf(serit, IstGeo.lykos_seridi(p.x, p.z))
	# komşu örnekler arası en büyük eğim
	for j in 8:
		for i in 9:
			var k := j * 9 + i
			if i < 8:
				smax = maxf(smax, absf(hs[k + 1] - hs[k]) / (ALAN.x / 8.0))
			if j < 7:
				smax = maxf(smax, absf(hs[k + 9] - hs[k]) / (ALAN.y / 7.0))
	# düzlem (en küçük kareler): y = a x + b z + c
	var sx := 0.0; var sz := 0.0; var sy := 0.0; var sxx := 0.0; var szz := 0.0; var sxz := 0.0; var sxy := 0.0; var szy := 0.0
	var n := float(pts.size())
	for p: Vector3 in pts:
		sx += p.x; sz += p.z; sy += p.y; sxx += p.x * p.x; szz += p.z * p.z; sxz += p.x * p.z; sxy += p.x * p.y; szy += p.z * p.y
	var mx := sx / n; var mz := sz / n; var my := sy / n
	var cxx := sxx / n - mx * mx; var czz := szz / n - mz * mz; var cxz := sxz / n - mx * mz
	var cxy := sxy / n - mx * my; var czy := szy / n - mz * my
	var det := cxx * czz - cxz * cxz
	var a := (cxy * czz - czy * cxz) / det
	var b := (czy * cxx - cxy * cxz) / det
	var yer := ""
	var yd := INF
	for y: Dictionary in IstGeo.yerler():
		var w: Vector3 = y["w"]
		var d := Vector2(w.x, w.z).distance_to(Vector2(c.x, c.z))
		if d < yd:
			yd = d
			yer = String(y["ad"])
	return {"c": c, "y": my, "egim_max": smax * 100.0, "egim_duz": sqrt(a * a + b * b) * 100.0,
		"lykos": IstGeo.cizgi_uzak(Vector2(c.x, c.z), lyk), "yer": yer.replace(" ", "_"), "yer_d": yd, "serit": serit}
