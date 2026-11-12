extends Node3D
## İstanbul v2 gezi denetimi, bölge kara-orta: gerçek oyuncuyla (Player) yürüyüş. YALNIZ test dosyası.
##   godot --headless --path . res://tests/_ist/gezi_kara-orta.tscn -- --rota=DOSYA [--ad=R1,R2] [--out=DOSYA]
## DOSYA satırı: "ad e,n;e,n;…" (gerçek metre). Her ~12 m'lik dilimde oyuncu hedefe yürür; takılma (3 sn'de < 0,7 m),
## düşme (başlangıç yüksekliğinden > 2,5 m aşağı / arazinin 1,5 m altı), boşluğa basma (zemin yok) GEZI_OLAY satırı.
## GEZI_OLAY <tür> <doğu> <kuzey> [ayrıntı]; özet: GEZI_ROTA ad uzunluk gecti dilim olay.

var _pl: CharacterBody3D
var dunya: Node3D
var rota := ""
var ad_f: PackedStringArray = []


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"rota": rota = kv[1]
			"ad": ad_f = kv[1].split(",")
	var cam := Camera3D.new()
	add_child(cam)
	cam.current = true
	var ilk := _oku()
	var p0: Vector2 = Vector2.ZERO
	if ilk.size() > 0:
		p0 = (ilk[0]["p"] as Array)[0]
	var w0 := IstGeo.w2(p0.x, p0.y)
	cam.global_position = Vector3(w0.x, IstGeo.h(w0.x, w0.y) + 10.0, w0.y)
	dunya = IstDunya.build(self, false, cam.global_position)
	IstDunya.butce_us = 250000
	await get_tree().process_frame
	_yuru.call_deferred(ilk)


func _oku() -> Array:
	var out: Array = []
	var f := FileAccess.open(rota, FileAccess.READ)
	if f == null:
		return out
	while not f.eof_reached():
		var s := f.get_line().strip_edges()
		if s == "":
			continue
		var pr := s.split(" ", false)
		if ad_f.size() > 0 and not (pr[0] in ad_f):
			continue
		var pts: Array = []
		for t: String in pr[1].split(";"):
			var xy := t.split(",")
			pts.append(Vector2(xy[0].to_float(), xy[1].to_float()))
		out.append({"ad": pr[0], "p": pts})
	return out


func _akis(p: Vector3) -> void:
	var s := IstSehir.active
	dunya.carpisma_yenile(p)
	for i in 3:
		await get_tree().process_frame
	if s != null:
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 30000:
			s._last_cam = Vector3.INF
			for k in 400:
				s._process(0.0)
				if s._queue.is_empty():
					break
			if s._queue.is_empty() and int(dunya.olcum()["isler"]) == 0:
				break
			await get_tree().process_frame
	for i in 3:
		await get_tree().physics_frame


func _yuru(rotalar: Array) -> void:
	var P = load("res://scripts/player/player.gd")
	_pl = P.new()
	add_child(_pl)
	dunya.izle = _pl
	var top_len := 0.0
	for r: Dictionary in rotalar:
		var pts: Array = r["p"]
		var w := IstGeo.w2((pts[0] as Vector2).x, (pts[0] as Vector2).y)
		_pl.global_position = Vector3(w.x, IstGeo.h(w.x, w.y) + 0.6, w.y)
		_pl.velocity = Vector3.ZERO
		await _akis(_pl.global_position)
		var dilim := 0
		var gecti := 0
		var olay := 0
		var uzun := 0.0
		var t_r := Time.get_ticks_msec()
		for i in pts.size() - 1:
			var a: Vector2 = pts[i]
			var b: Vector2 = pts[i + 1]
			var seg := a.distance_to(b)
			var n := maxi(1, int(ceil(seg / 12.0)))
			for k in n:
				var hedef := IstGeo.w2(a.lerp(b, float(k + 1) / n).x, a.lerp(b, float(k + 1) / n).y)
				var p0 := Vector2(_pl.global_position.x, _pl.global_position.z)
				var y0 := _pl.global_position.y
				var t := 0.0
				var son_p := p0
				var son_t := 0.0
				var sonuc := "tak"
				var zipla := 0
				var yak_say := 0
				while t < 9.0:
					await get_tree().physics_frame
					t += get_physics_process_delta_time()
					var pp := Vector2(_pl.global_position.x, _pl.global_position.z)
					var to := Vector3(hedef.x - pp.x, 0, hedef.y - pp.y)
					if to.length() < 1.5:
						sonuc = "ok"
						break
					_pl.rotation.y = atan2(-to.x, -to.z)
					_pl.set("frozen", false)
					_pl.set("move_mode", "script")
					_pl.set("script_velocity", to.normalized() * 3.2)
					var gy := maxf(IstGeo.h(pp.x, pp.y), 0.0)
					if _pl.global_position.y < gy - 1.0 or _pl.global_position.y < -5.0:
						sonuc = "bosluk"
						break
					if _pl.global_position.y < y0 - 8.0:
						sonuc = "dus"
						break
					if t - son_t > 0.5:
						if pp.distance_to(son_p) < 0.15 and _pl.is_on_floor():
							_pl.velocity.y = 3.6
							zipla += 1
						if t - son_t > 3.0 and pp.distance_to(son_p) < 0.7:
							break
						son_p = pp
						son_t = t
				var r2 := IstGeo.real(_pl.global_position.x, _pl.global_position.z)
				dilim += 1
				_pl.set("script_velocity", Vector3.ZERO)
				match sonuc:
					"ok":
						gecti += 1
						uzun += 12.0
					"tak":
						olay += 1
						print("GEZI_OLAY takilma %.0f %.0f rota=%s zipla=%d yerde=%s %s" % [r2.x, r2.y, r["ad"], zipla, _pl.is_on_floor(), _engel(hedef)])
						# 6 m ileri koy
						var dir := (hedef - Vector2(_pl.global_position.x, _pl.global_position.z)).normalized()
						_pl.global_position += Vector3(dir.x, 0.8, dir.y) * 6.0
					"bosluk", "dus":
						olay += 1
						print("GEZI_OLAY %s %.0f %.0f rota=%s y0=%.1f y=%.1f" % ["bosluk" if sonuc == "bosluk" else "dusme", r2.x, r2.y, r["ad"], y0, _pl.global_position.y])
						_pl.global_position = Vector3(hedef.x, IstGeo.h(hedef.x, hedef.y) + 1.0, hedef.y)
						_pl.velocity = Vector3.ZERO
				if dilim % 10 == 0:
					await _akis(_pl.global_position)
		top_len += uzun
		print("GEZI_ROTA %s dilim=%d gecti=%d olay=%d yurunen_m=%.0f sure_ms=%d" % [r["ad"], dilim, gecti, olay, uzun, Time.get_ticks_msec() - t_r])
	print("GEZI_BITTI toplam_m=%.0f" % top_len)
	get_tree().quit(0)


## Önde 1,2 m: hangi nesne yolu kesiyor (düğüm adı)
func _engel(hedef: Vector2) -> String:
	var pp := _pl.global_position
	var fw := Vector3(hedef.x - pp.x, 0, hedef.y - pp.z).normalized()
	var sp := get_world_3d().direct_space_state
	var s := ""
	for hh: float in [0.3, 1.0, 1.7]:
		var rq := PhysicsRayQueryParameters3D.create(pp + Vector3(0, hh, 0), pp + Vector3(0, hh, 0) + fw * 1.5)
		rq.exclude = [_pl.get_rid()]
		var h := sp.intersect_ray(rq)
		if h.is_empty():
			s += "|%.1f:-" % hh
		else:
			var c := h["collider"] as Node
			var yol := String(c.get_path()).replace("/root/GeziKaraOrta/", "")
			s += "|%.1f:%s" % [hh, "/".join(yol.split("/").slice(0, 5))]
	return s
