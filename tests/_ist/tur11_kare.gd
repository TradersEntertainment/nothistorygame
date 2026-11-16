extends Node3D
## TUR-11: sur YAKIN kareleri + tuğla ölçümü + sağlam sur kipi kareleri. tur10_yakin ile aynı kurulum ve kameralar (y1…y8)
## ve ek olarak:
##   a1 : Bölüm 25 an_01'in benzeri (oyuncu dış sur yolunda mazgal açıklığında, göz 1,62 m, FOV 72, ovaya bakış)
##   --olc : ışınla tuğla ölçümü (y1 ve a1 kamerasında birkaç piksel sütunu): her pikselin ışını çarpışma yüzüne değdiği dünya
##           y'sinde sur_doku'nun hatıl formülüyle (dönem 2,5 m, kaydırma 0,37, hatıl 0,42 m / 5 sıra = 8,4 cm) sıra indisi;
##           satır: TUR11OLC kam=… sutun=… sira=<i> y0=… y1=… px=<sıranın ekrandaki boyu> uzaklik=… ; korkuluk/diş hizası
##   --saglam : SurOyun.kur(..., {"saglam": true}) — gediksiz kesim; kareler s1 (dış sur yolu, eski gedik yerinde, boyunca),
##              s2 (peribolostan dış sura, eski gedik yeri), s3 (iç sur yolundan eski gedik yerine)
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur11_kare.tscn -- \
##     --out=DIR [--gece] [--onek=ONCE_] [--olc] [--saglam] [--yalniz=y1,a1]
## Her karede çizim çağrısı / ilkel (TUR11KARE).
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")
const SURDOKU := preload("res://scripts/world/ist/sur_doku.gd")

var out := "user://tur11_kare"
var gece := false
var onek := ""
var olc := false
var saglam := false
var s_kam := false     # --s_kam: varsayılan (gedikli) kipte de s1–s3 kameraları (karşılaştırma)
var yalniz: Array = []
var cam: Camera3D


func _ready() -> void:
	for s: String in OS.get_cmdline_user_args():
		var kv := s.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"gece": gece = true
			"onek": onek = kv[1]
			"olc": olc = true
			"saglam": saglam = true
			"yalniz": yalniz = Array(kv[1].split(","))
			"s_kam": s_kam = true
	DirAccess.make_dir_recursive_absolute(out)
	get_window().size = Vector2i(1280, 720)
	if gece:
		var moon := Night.environment(self, 0.006)
		moon.rotation_degrees = Vector3(-34, 160, 0)
	else:
		_gunduz()
	cam = Camera3D.new()
	cam.fov = 75.0
	cam.near = 0.05
	cam.far = 4000.0
	add_child(cam)
	cam.current = true
	_kos.call_deferred()


func _kos() -> void:
	var gx0: float = SurOyun.arayuz("mesoteikhion").gx       # varsayılan kipin oyun gediği (sağlam kipte orada sur var)
	var sec := {"ebeveyn": self, "dunya": false, "uzak": true, "asama": 2, "dolgu": 0.5, "kalas": true, "poterna_acik": false}
	if saglam:
		sec["saglam"] = true
	var k: Dictionary = SurOyun.kur("mesoteikhion", sec)
	var a: RefCounted = k["arayuz"]
	SURDOKU.uygula(k["kok"], 0)
	for i in 30:
		await get_tree().process_frame
	var d: Dictionary = a.d
	var gx: float = gx0
	var zo1 := float(d["zo1"])
	var zo0 := float(d["zo0"])
	var zi1 := float(d["zi1"])
	var OH := float(d["OH"])
	var HW := float(d["HW"])
	var PT := 0.45
	var zd := zo1 - PT       # dış sur korkuluğunun iç yüzü
	var kam := {}
	if saglam or s_kam:
		var yk: Dictionary = a.yol("dis")
		print("TUR11SAGLAM yol_dis kesik=%d gecit=%d mazgal_dis=%d gedik_bos=%s parca_gedik=%s" % [(yk["kesik"] as Array).size(),
			(yk["gecit"] as Array).size(), a.mazgallar("dis").size(), a.gedik().is_empty(), k["parca"].has("gedik")])
		kam["s1_saglam_dis_sur_yolu_gedik_yeri"] = [Vector3(gx + 9.0, OH + 1.62, a.zc_dis()), Vector3(gx - 6.0, OH + 1.0, a.zc_dis() + 0.1)]
		kam["s2_saglam_peribolostan_gedik_yeri"] = [Vector3(gx + 3.0, 1.62, zi1 + 3.0), Vector3(gx - 1.0, OH * 0.6, zo0)]
		kam["s3_saglam_ic_sur_yolundan"] = [Vector3(gx + 6.0, HW + 1.62, 0.6), Vector3(gx - 2.0, OH, zo1)]
	else:
		var mz: Array = a.mazgallar("dis")
		var m1: Vector3 = mz[0]["p"]["yerel"]
		for m in mz:
			var p: Vector3 = m["p"]["yerel"]
			if p.x > gx + 12.0:
				m1 = p
				break
		var mi: Array = a.mazgallar("ic")
		var m2: Vector3 = mi[mi.size() / 2]["p"]["yerel"]
		for m in mi:
			var p: Vector3 = m["p"]["yerel"]
			if p.x > gx + 6.0:
				m2 = p
				break
		var ic_k: Array = a.kesim["kule"]["ic"]
		var kt: Array = ic_k[0]
		for t in ic_k:
			if float(t[0]) > gx:
				kt = t
				break
		var kx := float(kt[0]) - float(kt[1]) * 0.5
		var q := PhysicsRayQueryParameters3D.create(Vector3(kx - 14.0, HW + 4.6, 0.0), Vector3(kx + 4.0, HW + 4.6, 0.0))
		var hit := get_world_3d().direct_space_state.intersect_ray(q)
		if not hit.is_empty():
			kx = float((hit["position"] as Vector3).x)
		# stauroma (fıçı) ara: dış sur yolunda en yakın fıçı sırası (görünen ağ adı yok; çarpışma gövdesi yok) — y7 kamerası
		# Bölüm 25 an_04 gibi sur yolu boyunca −x'e bakar
		kam = {
			"y1_dis_sur_disi_06m": [Vector3(m1.x + 0.2, OH + 1.62, zd - 0.6), Vector3(m1.x + 1.0, OH + 1.35, zo1 + 2.0)],
			"a1_bolum25_an01_benzeri": [Vector3(m1.x, OH + 1.62, a.zc_dis()), Vector3(m1.x, OH + 1.62 + 6.0, zo1 + 300.0)],
			"y2_ic_sur_korkulugu_15m": [Vector3(m2.x - 0.6, HW + 1.62, zi1 - PT - 1.5), Vector3(m2.x + 1.4, HW + 1.1, zi1)],
			"y3_kule_kapisi_2m": [Vector3(kx - 2.0, HW + 1.62, 0.2), Vector3(kx, HW + 1.2, 0.0)],
			"y4_sur_dibinden_2m": [Vector3(m2.x + 3.0, 1.62, zi1 + 2.0), Vector3(m2.x + 5.0, 3.2, zi1)],
			"y5_dis_sur_yolu_boyunca": [Vector3(m1.x - 1.0, OH + 1.62, a.zc_dis()), Vector3(m1.x + 12.0, OH + 1.0, zo1 - 0.2)],
			"y6_dis_sira_ustten_1m": [Vector3(m1.x - 0.5, OH + 2.3, zd - 1.0), Vector3(m1.x + 3.0, OH + 1.6, zo1)],
		}
		kam["y8_fici_gedik_2m"] = [Vector3(gx + 2.6, 2.0, zo0 - 3.6), Vector3(gx + 0.6, 0.6, zo0 - 1.4)]
		var st := _stauroma_x(a, OH, zd)
		if not is_nan(st):
			kam["y7_stauroma_sur_yolu"] = [Vector3(st + 6.5, OH + 1.62, a.zc_dis()), Vector3(st - 4.0, OH + 0.8, zo1 - 0.3)]
			print("TUR11KARE stauroma x=%.2f" % st)
	for ad: String in kam:
		if not yalniz.is_empty() and not yalniz.has(ad.get_slice("_", 0)):
			continue
		var c: Array = kam[ad]
		cam.fov = 72.0 if ad.begins_with("a1") or ad.begins_with("s") else 75.0
		cam.global_position = c[0]
		cam.look_at(c[1], Vector3.UP)
		for i in 10:
			await get_tree().process_frame
		var dc := 0.0
		var pr := 0.0
		for i in 3:
			await RenderingServer.frame_post_draw
			dc += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			pr += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		var img := get_viewport().get_texture().get_image()
		var f := "%s/%s%s%s.jpg" % [out, onek, "gece_" if gece else "gun_", ad]
		img.save_jpg(f, 0.85)
		print("TUR11KARE %s cizim=%.0f ilkel=%.0f kam=%s" % [f.get_file(), dc / 3.0, pr / 3.0, (c[0] as Vector3).snapped(Vector3.ONE * 0.01)])
		if olc and (ad.begins_with("y1") or ad.begins_with("a1")):
			_olc(ad.get_slice("_", 0), OH)
	print("TUR11KARE BITTI")
	get_tree().quit(0)


## Dış sur yolunda stauroma fıçısı ara: sur yolu boyunca (korkuluğun iç yüzünden 0,3 m içeride, 0,5 m yükseklikte) −x/+x
## ışın; ilk çarpan çarpışma gövdesi korkuluk/kule değilse fıçıdır (dışbükey kabuk)
func _stauroma_x(a: RefCounted, OH: float, zd: float) -> float:
	var ss := get_world_3d().direct_space_state
	var x: float = -float(a.L) * 0.5 + 2.0
	while x < float(a.L) * 0.5 - 2.0:
		var q := PhysicsRayQueryParameters3D.create(Vector3(x, OH + 0.45, zd - 1.3), Vector3(x, OH + 0.45, zd + 0.02))
		var h := ss.intersect_ray(q)
		if not h.is_empty():
			var col: Object = h["collider"]
			var cs: Node = (col as Node).get_child(0) if col is Node and (col as Node).get_child_count() > 0 else null
			if cs is CollisionShape3D and (cs as CollisionShape3D).shape is ConvexPolygonShape3D and (h["position"] as Vector3).z < zd - 0.2:
				return x
		x += 0.5
	return NAN


## Işınla tuğla ölçümü: dört piksel sütununda (x = 200, 480, 800, 1080) her satırın ışını; sur_doku hatıl formülü
func _olc(kad: String, OH: float) -> void:
	var ss := get_world_3d().direct_space_state
	for sx in [200, 480, 800, 1080]:
		var son_sira := -999
		var bas_px := 0
		var bas_y := 0.0
		var bas_d := 0.0
		var satir: Array = []
		for py in range(0, 720):
			var o := cam.project_ray_origin(Vector2(sx, py))
			var dr := cam.project_ray_normal(Vector2(sx, py))
			var h := ss.intersect_ray(PhysicsRayQueryParameters3D.create(o, o + dr * 30.0))
			var sira := -999
			var y := 0.0
			var uz := 0.0
			if not h.is_empty():
				y = (h["position"] as Vector3).y
				uz = o.distance_to(h["position"])
				var yy := y + 0.37
				var per := floorf(yy / 2.5)
				var pyy := yy - per * 2.5
				if pyy < 0.42:
					sira = int(per) * 10 + int(floorf(pyy / 0.084))
			if sira != son_sira:
				if son_sira != -999:
					satir.append("sira=%d y=%.3f..%.3f (OH%+.2f) px=%d uz=%.2f" % [son_sira % 10, bas_y, y, bas_y - OH, py - bas_px, bas_d])
				son_sira = sira
				bas_px = py
				bas_y = y
				bas_d = uz
		print("TUR11OLC kam=%s sutun=%d hatil_sira_sayisi=%d | %s" % [kad, sx, satir.size(), " | ".join(satir)])


func _gunduz() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f7fc4")
	sm.sky_horizon_color = Color("cfdde6")
	sm.ground_horizon_color = Color("b8c4c8")
	sm.ground_bottom_color = Color("5a6a70")
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.48
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.9
	e.fog_enabled = true
	e.fog_light_color = Color("d6dcd8")
	e.fog_density = 0.0015
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.08
	e.adjustment_contrast = 1.05
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-36, 38, 0)
	sun.light_color = Color("ffe2b8")
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 140.0
	add_child(sun)
