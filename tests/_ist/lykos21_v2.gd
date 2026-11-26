extends Node3D
## G21 v2 sondası (ekransız): IstDunya ile v2'yi kurar, Lykos şeridinin dokusunu sayar.
##   godot --headless --path . res://tests/_ist/lykos21_v2.tscn
## Satırlar:
##   LYKOS21V2 serit ev=… doku={…} oge={…} meydan=… avlu=… sokak_m=…   şeridin içindekiler (merkezi şeritte)
##   LYKOS21V2 istbos kare=… bos=… ornek=…                               40 m'lik şerit karelerinde kayıt sayımı
##   LYKOS21V2 yer tur=… gercek=(e,n) dunya=(x,z)                         bakış seçmek için örnek yerler
##   LYKOS21V2 saray c=… yol_uzunluk=… alan_ev=…                         saray alanı (evsiz mi) ve yol

var dunya: IstDunya
var cam: Camera3D


func _ready() -> void:
	cam = Camera3D.new()
	cam.far = 30000.0
	add_child(cam)
	cam.current = true
	var w := IstGeo.w2(-4550.0, 1150.0)
	cam.global_position = Vector3(w.x, 80.0, w.y)
	IstDunya.butce_us = 250000
	dunya = IstDunya.build(self, false, cam.global_position) as IstDunya
	_say.call_deferred()


func _say() -> void:
	var t0 := Time.get_ticks_msec()
	for i in 6:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < 40000:
		var o := dunya.olcum()
		if o["isler"] == 0 and IstMahalleDoku.bekleyen() == 0:
			break
		await get_tree().process_frame
	var sk: IstSokak = IstSehir.sokak
	if sk == null:
		print("LYKOS21V2 sokak yok")
		get_tree().quit(1)
		return
	var ev := 0
	var dk := {}
	var og := {}
	var mey := 0
	var av := 0
	var yer := {}
	for h: Dictionary in sk.houses:
		var c: Vector2 = h["c"]
		if _ser(c.x, c.y) >= 0.5:
			ev += 1
			if not yer.has("ev") or randf() < 0.02:
				yer["ev"] = c
	for d: Dictionary in sk.doku:
		var c: Vector2 = d["c"]
		if _ser(c.x, c.y) >= 0.5:
			var t := String(d["tur"])
			dk[t] = int(dk.get(t, 0)) + 1
			if not yer.has(t):
				yer[t] = c
	for o: Dictionary in sk.oge:
		var c: Vector2 = o["c"]
		if _ser(c.x, c.y) >= 0.5:
			var t := String(o["tur"])
			og[t] = int(og.get(t, 0)) + 1
			if not yer.has("oge_" + t):
				yer["oge_" + t] = c
	var mlist: Array = []
	for m: Dictionary in sk.meydan:
		var c: Vector2 = m["c"]
		if _ser(c.x, c.y) >= 0.5:
			mey += 1
			mlist.append(c)
	for a: Dictionary in sk.avlu:
		var c: Vector2 = a["c"]
		if _ser(c.x, c.y) >= 0.5:
			av += 1
	var sm := 0.0
	var stur := {}
	for s: Dictionary in sk.streets:
		var pl: PackedVector2Array = s["pts"]
		for i in pl.size() - 1:
			var q := (pl[i] + pl[i + 1]) * 0.5
			if _ser(q.x, q.y) >= 0.5:
				var L := pl[i].distance_to(pl[i + 1])
				sm += L
				stur[String(s["tur"])] = float(stur.get(String(s["tur"]), 0.0)) + L
	print("LYKOS21V2 serit ev=%d doku=%s oge=%s meydan=%d avlu=%d sokak_m=%.0f sokak_tur=%s" % [ev, str(dk), str(og), mey, av, sm, str(stur)])
	# ISTBOS (kayıt): 40 m'lik şerit kareleri
	var dolu := {}
	for h: Dictionary in sk.houses:
		var c: Vector2 = h["c"]
		dolu[Vector2i(floori(c.x / 40.0), floori(c.y / 40.0))] = true
	for d: Dictionary in sk.doku:
		var c: Vector2 = d["c"]
		var al: Vector2 = d["alan"]
		for oy in [-0.4, 0.0, 0.4]:
			for ox in [-0.4, 0.0, 0.4]:
				dolu[Vector2i(floori((c.x + al.x * ox) / 40.0), floori((c.y + al.y * oy) / 40.0))] = true
	for arr: Array in [sk.oge, sk.avlu, sk.meydan]:
		for o: Dictionary in arr:
			var c: Vector2 = o["c"]
			dolu[Vector2i(floori(c.x / 40.0), floori(c.y / 40.0))] = true
	var kare := 0
	var bos := 0
	var ornek: Array = []
	var w0 := IstGeo.w2(-5100.0, 400.0)
	var w1 := IstGeo.w2(-3800.0, 2300.0)
	for i in range(floori(minf(w0.x, w1.x) / 40.0), floori(maxf(w0.x, w1.x) / 40.0) + 1):
		for j in range(floori(minf(w0.y, w1.y) / 40.0), floori(maxf(w0.y, w1.y) / 40.0) + 1):
			var c := Vector2((i + 0.5) * 40.0, (j + 0.5) * 40.0)
			if _ser(c.x, c.y) < 0.5:
				continue
			kare += 1
			if not dolu.has(Vector2i(i, j)):
				# anıt / sur bandı / oyun alanı hücreleri (boş hücre yoksa) dolu sayılır (_ogeler ile aynı kural)
				var free := 0
				for dj in 5:
					for di in 5:
						var q := c + Vector2(-16 + di * 8, -16 + dj * 8)
						if sk.cell(q.x, q.y) == 0:
							free += 1
				if free >= 6:
					bos += 1
					var r := IstGeo.real(c.x, c.y)
					ornek.append("(%d,%d)" % [int(r.x), int(r.y)])
	print("LYKOS21V2 istbos kare=%d bos=%d oran=%.1f%% ornek=%s" % [kare, bos, 100.0 * bos / maxf(kare, 1), " ".join(ornek.slice(0, 20))])
	for k in yer:
		var c: Vector2 = yer[k]
		var r := IstGeo.real(c.x, c.y)
		print("LYKOS21V2 yer tur=%s gercek=(%.0f,%.0f) dunya=(%.1f,%.1f)" % [k, r.x, r.y, c.x, c.y])
	for d: Dictionary in sk.doku:
		var c: Vector2 = d["c"]
		if String(d["tur"]) == "harap_kilise":
			var r := IstGeo.real(c.x, c.y)
			print("LYKOS21V2 yer tur=harap_kilise_hepsi gercek=(%.0f,%.0f) dunya=(%.1f,%.1f) alan=%s yaw=%.2f" % [r.x, r.y, c.x, c.y, str(d["alan"]), float(d["yaw"])])
	for c: Vector2 in mlist:
		var r := IstGeo.real(c.x, c.y)
		print("LYKOS21V2 yer tur=meydan gercek=(%.0f,%.0f) dunya=(%.1f,%.1f)" % [r.x, r.y, c.x, c.y])
	var sar: Dictionary = sk.stats.get("saray", {})
	if not sar.is_empty():
		var c: Vector2 = sar["c"]
		var r := IstGeo.real(c.x, c.y)
		var ylen := 0.0
		var ypts: Array = []
		for s: Dictionary in sk.streets:
			if String(s["ad"]) == "saray_yolu":
				var pl: PackedVector2Array = s["pts"]
				for i in pl.size() - 1:
					ylen += pl[i].distance_to(pl[i + 1])
				for p in [pl[0], pl[pl.size() / 2], pl[pl.size() - 1]]:
					var rp := IstGeo.real(p.x, p.y)
					ypts.append("(%.0f,%.0f)" % [rp.x, rp.y])
		var nev := 0
		for h: Dictionary in sk.houses:
			if (h["c"] as Vector2).distance_to(c) < 45.0:
				nev += 1
		print("LYKOS21V2 saray c_gercek=(%.0f,%.0f) c_dunya=(%.1f,%.1f) h=%.2f yol_uzunluk=%.0f yol_noktalar=%s alan_ev45=%d hucre=%d" % [r.x, r.y,
			c.x, c.y, IstGeo.h(c.x, c.y), ylen, " ".join(ypts), nev, int(sar.get("hucre", 0))])
	get_tree().quit(0)


# ---- şerit tanımının kopyası (IstGeo.lykos_seridi ile aynı; tabanda da sayılabilsin diye bağımsız)
var _ks := PackedFloat32Array()
var _sr := 0.0
var _sp := 0.0

func _iz(r: Vector2) -> Vector2:
	var K := IstGeo.R_KARA
	if _ks.size() != K.size():
		_ks.resize(K.size())
		var acc := 0.0
		for i in K.size():
			if i > 0:
				acc += K[i - 1].distance_to(K[i])
			_ks[i] = acc
		_sr = _iz(Vector2(-4836.7, 889.4)).x
		_sp = _iz(Vector2(-4199.1, 1822.6)).x
	var bd := INF
	var bs := 0.0
	for i in K.size() - 1:
		var q := Geometry2D.get_closest_point_to_segment(r, K[i], K[i + 1])
		var d := r.distance_squared_to(q)
		if d < bd:
			bd = d
			bs = _ks[i] + K[i].distance_to(q)
	return Vector2(bs, sqrt(bd))

func _ser(x: float, z: float) -> float:
	var r := IstGeo.real(x, z)
	if r.x < -5250.0 or r.x > -3500.0 or r.y < 300.0 or r.y > 2400.0 or not IstGeo.sehir_ici(x, z):
		return 0.0
	var iz := _iz(r)
	var t := (iz.x - _sr) / (_sp - _sr)
	var d := iz.y * IstGeo.S - 9.0
	if t < -0.3 or t > 1.212 or d < -6.0:
		return 0.0
	var ft := smoothstep(-0.3, -0.23, t) * (1.0 - smoothstep(1.142, 1.212, t))
	var D := clampf(200.0 + 30.0 * sin(t * 6.3 + 0.5) + 20.0 * sin(t * 15.1 + 2.1), 150.0, 250.0)
	return ft * (1.0 - smoothstep(D - 14.0, D + 14.0, d))
