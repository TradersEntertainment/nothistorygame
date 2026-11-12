extends Node3D
## Gezi sondası (ordugah-kanat; yalnız test dosyası). Oyun kodu DEĞİŞMEZ.
##   -- --set=plan                       plan öğelerinin gerçek koordinatları (PLAN satırları)
##   -- --set=yuru --route=N [--hiz=3.2] gerçek Player ile güzergâh yürüyüşü: GEZI_OLAY <tür> <doğu> <kuzey> ...
const ROUTES := {
	1: [[-5650, -1450], [-5650, -900], [-5650, -400], [-5650, 100], [-5650, 520]],
	2: [[-5250, -400], [-5700, -400], [-6100, -400], [-6500, -400]],
	3: [[-5000, 2000], [-4700, 2320], [-4400, 2666], [-4100, 3000], [-3980, 3250]],
	4: [[-4850, 2387], [-5200, 2420], [-5472, 2484], [-5800, 2350]],
	5: [[-6500, -1000], [-6450, -300], [-6350, 200], [-6200, 800]],
	6: [[-900, 2900], [-500, 3050], [-100, 3250], [300, 3400], [700, 3500]],
	7: [[-4550, 2368], [-4489, 2691], [-4615, 2937], [-4521, 3500]],
}
var set_ := "plan"
var route := 1
var hiz := 3.2
var _pl: CharacterBody3D
var olay := {}


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"set": set_ = kv[1]
			"route": route = int(kv[1])
			"hiz": hiz = kv[1].to_float()
	if set_ == "plan":
		for it: Dictionary in IstOrdugah.plan():
			var p: Vector2 = it["pos"]
			var r := IstGeo.real(p.x, p.y)
			print("PLAN %s %s e=%d n=%d r=%.0f" % [it["kind"], it["id"], r.x, r.y, float(it["r"])])
		get_tree().quit(0)
		return
	if set_ == "yuru":
		_yuru.call_deferred()


func _koy(e: float, n: float, dy := 0.6) -> void:
	var w := IstGeo.w2(e, n)
	_pl.global_position = Vector3(w.x, maxf(IstGeo.h(w.x, w.y), 0.0) + dy, w.y)
	_pl.velocity = Vector3.ZERO


func _olay(tur: String, ek := "") -> void:
	var r := IstGeo.real(_pl.global_position.x, _pl.global_position.z)
	olay[tur] = int(olay.get(tur, 0)) + 1
	print("GEZI_OLAY %s %d %d %s" % [tur, r.x, r.y, ek])


func _bloke_eden(fw: Vector3) -> String:
	var sp := get_world_3d().direct_space_state
	var s := ""
	for hh: float in [0.25, 0.9, 1.6]:
		var rq := PhysicsRayQueryParameters3D.create(_pl.global_position + Vector3(0, hh, 0), _pl.global_position + Vector3(0, hh, 0) + fw * 1.2)
		rq.exclude = [_pl.get_rid()]
		var h := sp.intersect_ray(rq)
		if not h.is_empty() and h["collider"] is Node:
			var c := h["collider"] as Node
			var yol := String(c.get_path())
			s += "h%.2f=%s " % [hh, yol.substr(maxi(0, yol.length() - 70))]
	return s if s != "" else "(ışın yok: görünmez)"


func _yuru() -> void:
	var P = load("res://scripts/player/player.gd")
	_pl = P.new()
	var wp: Array = ROUTES[route]
	var w0 := IstGeo.w2(wp[0][0], wp[0][1])
	var dunya := IstDunya.build(self, false, Vector3(w0.x, 0, w0.y))
	add_child(_pl)
	dunya.izle = _pl
	IstDunya.butce_us = 20000
	_koy(wp[0][0], wp[0][1], 1.0)
	dunya.carpisma_yenile(_pl.global_position)
	Engine.time_scale = 3.0
	for i in 60:
		await get_tree().physics_frame
	var toplam := 0.0
	var t_basla := Time.get_ticks_msec()
	_pl.set("frozen", false)
	_pl.set("move_mode", "script")
	for li in range(1, wp.size()):
		var hedef: Vector2 = IstGeo.w2(wp[li][0], wp[li][1])
		var t := 0.0
		var son_p := Vector2(_pl.global_position.x, _pl.global_position.z)
		var son_t := 0.0
		var ilk_p := son_p
		var tak_t := 0.0
		var en_yakin := son_p.distance_to(hedef)
		while t < 200.0:
			await get_tree().physics_frame
			var dt := get_physics_process_delta_time()
			t += dt
			var p := Vector2(_pl.global_position.x, _pl.global_position.z)
			var to := Vector3(hedef.x - p.x, 0, hedef.y - p.y)
			if to.length() < 2.0:
				break
			_pl.rotation.y = atan2(-to.x, -to.z)
			_pl.set("script_velocity", to.normalized() * hiz)
			var g := maxf(IstGeo.h(p.x, p.y), 0.0)
			if _pl.global_position.y < g - 2.5 and not IstGeo.su(p.x, p.y):
				_olay("dusme", "y=%.1f zemin=%.1f" % [_pl.global_position.y, g])
				_koy(IstGeo.real(p.x, p.y).x, IstGeo.real(p.x, p.y).y, 2.0)
			elif _pl.is_on_floor() and _pl.global_position.y > g + 3.0:
				_olay("yuksekte", "y=%.1f zemin=%.1f (çatı/duvar/çadır üstü?)" % [_pl.global_position.y, g])
			if t - son_t > 0.5:
				toplam += p.distance_to(son_p)
				son_p = p
				son_t = t
				var kalan := p.distance_to(hedef)
				if kalan < en_yakin - 0.8:
					en_yakin = kalan
					tak_t = 0.0
				else:
					tak_t += 0.5
					if _pl.is_on_floor() and int(tak_t * 2.0) % 4 == 0:
						_pl.velocity.y = 3.6
					if tak_t >= 6.0:
						_olay("takilma", _bloke_eden(Vector3(to.x, 0, to.z).normalized()))
						var ileri := p + Vector2(to.x, to.z).normalized() * 3.0
						var r2 := IstGeo.real(ileri.x, ileri.y)
						_koy(r2.x, r2.y, 1.5)
						tak_t = 0.0
						en_yakin = Vector2(ileri.x, ileri.y).distance_to(hedef)
						son_p = ileri
		print("GEZI_YURU route=%d bacak=%d bitti t=%.0f sn konum_hedefe=%.1f m" % [route, li, t, Vector2(_pl.global_position.x, _pl.global_position.z).distance_to(hedef)])
	print("GEZI_YURU route=%d toplam_dunya_m=%.0f gercek_m=%.0f olaylar=%s sure_ms=%d" % [route, toplam, toplam / IstGeo.S, str(olay), Time.get_ticks_msec() - t_basla])
	get_tree().quit(0)
