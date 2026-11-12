extends Node3D
## OTURTMA denetimi: kara surunun iç sur, dış sur, hendek iç ve dış kenarı boyunca 5 m adımla, her iki yüzde GÖRÜNEN ağlardan
## (ekranda çizilen MeshInstance3D üçgenleri: arazi parçaları IstDunya/Arazi_*, sur dilimleri, köşe dolguları, kapı koşuları,
## sur dibi eteği) dikey ışınla ölçer. Gerçek oyun kurucusu (IstDunya.build → IstSehir.attach_v2), yakın katman.
##   xvfb-run -a godot --path . --rendering-driver opengl3 res://tests/_ist/oturtma_denetim.tscn [-- --adim=5 --bas=0 --son=1]
## Ölçütler (eşikler sabit; gevşetme yok):
##   bosluk: duvarın görünen alt kenarı (yüzün 0,3 m içinde en alt sur yüzeyi) yüzün 0,3 m dışındaki görünen zeminin
##           (arazi / etek / sur zemini) 2 cm'den fazla üstünde, ya da yüz önünde hiç zemin yok (gök/boşluk)
##   gomuk : arazi ağı yüz önünde dilim tabanının 1,0 m'den fazla üstünde (arazi sura taşmış) ya da duvarın içinde duvar
##           tepesinden yukarı çıkıyor
##   yarik : hendek kıyısında (harpuştanın 0,3 m dışı) zemin ile harpuşta üstü arasında > 0,15 m açıklık ya da zemin yok;
##           ya da hendek ortasında arazi ağı tabanın 0,5 m'den fazla üstünden geçiyor (çukurun üstünde / içine sarkan arazi)
##   levha : peribolos ortası, teras ortası ve şehir önünde görünen en üst yatay sur yüzeyi arazinin 0,10 m'den fazla
##           üstünde (araziye değmeyen yatay yüzey)

var adim := 5.0
var bas := 0.0
var son := 1.0
var hata := -1.0          # --hata=sv: o noktada ayrıntı dök
var dunya: Node3D
var cam: Camera3D
const IZ := 2.0

var say := {"ornek": 0, "bosluk": 0, "gomuk": 0, "yarik": 0, "levha": 0, "kule_atla": 0}
var yerler := {"bosluk": [], "gomuk": [], "yarik": [], "levha": []}


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"adim": adim = kv[1].to_float()
			"bas": bas = kv[1].to_float()
			"son": son = kv[1].to_float()
			"hata": hata = kv[1].to_float()
	cam = Camera3D.new()
	cam.far = 30000.0
	add_child(cam)
	cam.current = true
	var pl := IstSehir._sade(IstGeo.yol("kara_suru"))
	dunya = IstDunya.build(self, false, Vector3(pl[0].x, 20.0, pl[0].y))
	IstDunya.butce_us = 250000
	await get_tree().process_frame
	await _calis()
	get_tree().quit(0)


func _bekle() -> void:
	for i in 3:
		await get_tree().process_frame
	var s := IstSehir.active
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 90000:
		var bos := true
		if dunya.has_method("olcum") and int(dunya.olcum()["isler"]) > 0:
			bos = false
		if s != null:
			s._last_cam = Vector3.INF
			for k in 400:
				s._process(0.0)
				if s._queue.is_empty():
					break
			if not s._queue.is_empty():
				bos = false
		if bos:
			break
		await get_tree().process_frame
	for i in 2:
		await get_tree().process_frame


static func _hat_at(pl: PackedVector2Array, sv: float) -> Dictionary:
	var acc := 0.0
	for i in pl.size() - 1:
		var l := pl[i].distance_to(pl[i + 1])
		if acc + l >= sv or i == pl.size() - 2:
			var d := (pl[i + 1] - pl[i]) / l
			return {"p": pl[i] + d * clampf(sv - acc, 0.0, l), "d": d, "i": i}
		acc += l
	return {"p": pl[0], "d": Vector2.RIGHT, "i": 0}


## sv'deki öğe (dilim / kapı koşusu; köşe dolgusu ve köşe kulesi değil): [öğe, taban y, dış kademe]
func _oge(sv: float) -> Array:
	var s := IstSehir.active
	for it: Dictionary in s.hat_items + s.items:
		var on := String(it.get("hat", "")) == "kara_suru" or String(it.get("kapi_hat", "")) == "kara_suru"
		var id := String(it["id"])
		if not on or not it.has("s0") or id.begins_with("kdolgu") or id.begins_with("kose_"):
			continue
		if sv >= float(it["s0"]) + 3.5 and sv <= float(it["s1"]) - 3.5:
			return [it, float(it["pos"].y), s._dis_dy(it)]
	return []


# ------------------------------------------------------------------ görünen üçgenler (dünya), 2 m ızgara

var _tri: Array = []        # [a, b, c (Vector3), tür]
var _izg := {}

func _topla(alan: Rect2) -> void:
	_tri.clear()
	_izg.clear()
	var s := IstSehir.active
	var sur_ad := {}
	for it: Dictionary in s.hat_items + s.items:
		var on := String(it.get("hat", "")) == "kara_suru" or String(it.get("kapi_hat", "")) == "kara_suru"
		if on:
			sur_ad["Ist_" + String(it["id"])] = true
	for c in get_tree().root.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree() or mi.visibility_range_begin > 0.0:
			continue
		var yol := String(mi.get_path())
		var tur := ""
		if yol.contains("/Arazi_"):
			tur = "arazi"
		elif yol.contains("SurDibiEtek"):
			tur = "etek"
		elif yol.contains("SurDibiBant") or yol.contains("SurDibiOt") or yol.contains("SurDibiCali") or yol.contains("SurDibiTas"):
			continue
		else:
			for k: String in sur_ad:
				if yol.contains("/" + k + "/"):
					tur = "sur"
					break
		if tur == "":
			continue
		if yol.contains("HendekKaplama") or yol.contains("HendekToprak"):
			tur = "hendek"
		var xf := mi.global_transform
		var ab := xf * mi.mesh.get_aabb()
		if not Rect2(ab.position.x, ab.position.z, ab.size.x, ab.size.z).intersects(alan):
			continue
		var f := mi.mesh.get_faces()
		for k in range(0, f.size(), 3):
			var a := xf * f[k]
			var b := xf * f[k + 1]
			var cc := xf * f[k + 2]
			var lo := Vector2(minf(a.x, minf(b.x, cc.x)), minf(a.z, minf(b.z, cc.z)))
			var hi := Vector2(maxf(a.x, maxf(b.x, cc.x)), maxf(a.z, maxf(b.z, cc.z)))
			if hi.x < alan.position.x or lo.x > alan.end.x or hi.y < alan.position.y or lo.y > alan.end.y:
				continue
			# dikey yüzler (izdüşüm alanı ~0) dikey ışına görünmez: alt/üst yüzler ölçülür
			var ar := absf((b.x - a.x) * (cc.z - a.z) - (cc.x - a.x) * (b.z - a.z))
			if ar < 1e-5:
				continue
			_tri.append([a, b, cc, tur, yol.get_slice("IstSehir/", 1) if hata >= 0.0 else ""])
			var idx := _tri.size() - 1
			for gx in range(floori(lo.x / IZ), floori(hi.x / IZ) + 1):
				for gz in range(floori(lo.y / IZ), floori(hi.y / IZ) + 1):
					var key := Vector2i(gx, gz)
					if not _izg.has(key):
						_izg[key] = []
					(_izg[key] as Array).append(idx)


## (x, z) noktasında bütün yüzeylerin y'leri: [[y, tür], …] (yükseklik sırası, yukarıdan aşağı)
func _isin(q: Vector2) -> Array:
	var o: Array = []
	var l = _izg.get(Vector2i(floori(q.x / IZ), floori(q.y / IZ)))
	if l == null:
		return o
	for idx: int in l:
		var t: Array = _tri[idx]
		var a: Vector3 = t[0]
		var b: Vector3 = t[1]
		var c: Vector3 = t[2]
		var v0 := Vector2(b.x - a.x, b.z - a.z)
		var v1 := Vector2(c.x - a.x, c.z - a.z)
		var v2 := Vector2(q.x - a.x, q.y - a.z)
		var den := v0.x * v1.y - v1.x * v0.y
		if absf(den) < 1e-9:
			continue
		var u := (v2.x * v1.y - v1.x * v2.y) / den
		var w := (v0.x * v2.y - v2.x * v0.y) / den
		if u < -1e-4 or w < -1e-4 or u + w > 1.0001:
			continue
		o.append([a.y + u * (b.y - a.y) + w * (c.y - a.y), t[3], t[4]])
	o.sort_custom(func(x: Array, y: Array) -> bool: return float(x[0]) > float(y[0]))
	return o


## Görünen zemin: tavanın altındaki en üst yüzey (arazi / etek / sur / hendek); yoksa NAN
static func _zemin(h: Array, tavan: float, turler: Array) -> float:
	for e: Array in h:
		if float(e[0]) <= tavan and turler.has(String(e[1])):
			return float(e[0])
	return NAN


static func _en_alt(h: Array, tur: String) -> float:
	var m := INF
	for e: Array in h:
		if String(e[1]) == tur:
			m = minf(m, float(e[0]))
	return m


static func _ust(h: Array, tur: String, tavan: float) -> float:
	for e: Array in h:
		if String(e[1]) == tur and float(e[0]) <= tavan:
			return float(e[0])
	return NAN


func _kayit(tur: String, sv: float, ne: String, p: Vector2) -> void:
	say[tur] = int(say[tur]) + 1
	if (yerler[tur] as Array).size() < 12:
		var r := IstGeo.real(p.x, p.y)
		(yerler[tur] as Array).append("s=%.0f %s (e=%.0f n=%.0f)" % [sv, ne, r.x, r.y])


## Duvar yüzü: c_yuz (yerel), dış yön (−1 şehir/peribolos tarafı, +1 dış), taban y
func _yuz(sv: float, p: Vector2, o: Vector2, c_yuz: float, yon: float, y: float, ad: String) -> void:
	var qi := p + o * (c_yuz - yon * 0.3)
	var qo := p + o * (c_yuz + yon * 0.3)
	var hi := _isin(qi)
	var ho := _isin(qo)
	# yüzün önü bir kulenin içindeyse (dışarıda da gövde var) atla: kule yüzü ayrı örneklenmez
	for e: Array in ho:
		if String(e[1]) == "sur" and float(e[0]) > y + 2.5:
			say["kule_atla"] = int(say["kule_atla"]) + 1
			return
	say["ornek"] = int(say["ornek"]) + 1
	var wb := _en_alt(hi, "sur")
	var g := _zemin(ho, y + 2.0, ["arazi", "etek", "sur", "hendek"])
	if is_nan(g):
		_kayit("bosluk", sv, ad + " zemin yok", qo)
	elif wb < INF and wb > g + 0.02:
		_kayit("bosluk", sv, ad + " alt kenar %.2f m yukarıda" % (wb - g), qo)
	var ga := _ust(ho, "arazi", y + 30.0)
	if not is_nan(ga) and ga > y + 1.0:
		_kayit("gomuk", sv, ad + " arazi tabanın %.2f m üstünde" % (ga - y), qo)
	var gi := _ust(hi, "arazi", y + 40.0)
	var top := -INF
	for e: Array in hi:
		if String(e[1]) == "sur":
			top = maxf(top, float(e[0]))
	if not is_nan(gi) and top > -INF and gi > top:
		_kayit("gomuk", sv, ad + " arazi duvar tepesinin üstünde", qi)


func _calis() -> void:
	var pl := IstSehir._sade(IstGeo.yol("kara_suru"))
	var L := 0.0
	for i in pl.size() - 1:
		L += pl[i].distance_to(pl[i + 1])
	var dm := IstSurlar.dims(1.0)
	var zi0 := float(dm["zi0"])
	var zi1 := float(dm["zi1"])
	var zo0 := float(dm["zo0"])
	var zo1 := float(dm["zo1"])
	var zm0 := float(dm["zm0"])
	var zm1 := float(dm["zm1"])
	var MD := float(dm["MD"])
	var c1 := zm1 + 0.9
	var sv0 := L * bas
	var sv1 := L * son
	var kam := sv0 + 50.0
	var t0 := Time.get_ticks_msec()
	while kam - 50.0 < sv1:
		var q := _hat_at(pl, kam)
		var pc: Vector2 = q["p"]
		cam.global_position = Vector3(pc.x, IstGeo.h(pc.x, pc.y) + 20.0, pc.y)
		await _bekle()
		var a0 := maxf(sv0, kam - 50.0)
		var a1 := minf(sv1, kam + 50.0)
		var alan := Rect2(pc, Vector2.ZERO).grow(150.0)
		_topla(alan)
		var sv := ceilf(a0 / adim) * adim + adim * 0.5
		while sv < a1:
			var hq := _hat_at(pl, sv)
			var p: Vector2 = hq["p"]
			var d: Vector2 = hq["d"]
			var o := IstSehir._out(d, p, "kara_suru")
			var og := _oge(sv)
			if og.is_empty():
				sv += adim
				continue
			var y: float = og[1]
			var y2: float = y + float(og[2])
			if hata >= 0.0 and absf(sv - hata) < adim * 0.5:
				print("HATA sv=%.1f id=%s y=%.2f dy=%.2f yaw=%.3f pos=%s" % [sv, og[0]["id"], y, float(og[2]), float(og[0]["yaw"]), og[0]["pos"]])
				for cc: float in [-10.0, 0.0, 10.0, 19.0, 21.0, 24.0, 27.0, 29.0, 40.0, 52.0, 56.0, 62.0]:
					var qq := p + o * cc
					var hs := ""
					for e: Array in _isin(qq):
						hs += "%s:%.2f[%s] " % [e[1], e[0], String(e[2]).right(40)]
					var nd := 0
					var ds := ""
					for ii in IstGeo._duz.size():
						var e2: Array = IstGeo._duz[ii]
						if (e2[0] as Vector2).distance_to(qq) < float(e2[1]) + float(e2[3]):
							nd += 1
							ds += "#%d(r%.1f y%.2f g%.1f) " % [ii, e2[1], e2[2], e2[3]]
					if cc == 10.0:
						print("HATA duz ", ds, " toplam=", IstGeo._duz.size())
					print("HATA c=%.0f h=%.2f duz=%d isin=%s" % [cc, IstGeo.h(qq.x, qq.y), nd, hs])
			var hendekli := not (String(og[0]["id"]) in ["kaligaria", "kerkoporta"])
			_yuz(sv, p, o, zi0, -1.0, y, "ic_sur_sehir")
			_yuz(sv, p, o, zi1, 1.0, y, "ic_sur_peribolos")
			_yuz(sv, p, o, zo0, -1.0, y, "dis_sur_peribolos")
			if hendekli:
				_yuz(sv, p, o, zo1, 1.0, y2, "dis_sur_teras")
				# hendek dış kıyısı
				say["ornek"] = int(say["ornek"]) + 1
				var hl := _isin(p + o * (c1 + 0.3))
				var hm := _isin(p + o * (c1 - 0.2))
				var g := _zemin(hl, y2 + 2.0, ["arazi", "etek", "sur", "hendek"])
				var cp := _zemin(hm, y2 + 1.0, ["hendek", "sur"])
				# iç kırıkta komşu dilimin hendeği bu noktayı kaplıyor (görünen en üst yüzey hendek tabanı düzeyinde): kıyı değil
				var komsu := not is_nan(g) and g < y2 - MD * 0.5
				if is_nan(g):
					for e: Array in hl:
						if (String(e[1]) == "hendek" or String(e[1]) == "sur") and float(e[0]) < y2 - MD * 0.5:
							komsu = true
				if komsu:
					say["ornek"] = int(say["ornek"]) - 1
				elif is_nan(g):
					_kayit("yarik", sv, "dış kıyı zemin yok", p + o * (c1 + 0.3))
				elif not is_nan(cp) and absf(g - cp) > 0.15:
					_kayit("yarik", sv, "dış kıyı açıklık %.2f m" % (g - cp), p + o * (c1 + 0.3))
				# hendek iç kıyısı (parateikhion önü): harpuşta / alçak duvar dibi ile teras zemini
				say["ornek"] = int(say["ornek"]) + 1
				var hl2 := _isin(p + o * (zm0 - 1.8 - 0.3))
				var g2 := _zemin(hl2, y2 + 2.0, ["arazi", "etek", "sur", "hendek"])
				if is_nan(g2):
					_kayit("yarik", sv, "iç kıyı zemin yok", p + o * (zm0 - 2.1))
				# hendek ortası: arazi çukurun üstünden geçiyor / içine sarkıyor mu
				for zc: float in [zm0 + 2.0, (zm0 + zm1) * 0.5, zm1 - 2.0]:
					say["ornek"] = int(say["ornek"]) + 1
					var ha := _ust(_isin(p + o * zc), "arazi", y2 + 30.0)
					if not is_nan(ha) and ha > y2 - MD + 0.5:
						_kayit("yarik", sv, "arazi hendeğin üstünde/içinde (z=%.0f, %.2f m)" % [zc, ha - (y2 - MD)], p + o * zc)
				# teras ortası levha
				say["ornek"] = int(say["ornek"]) + 1
				_levha(sv, p + o * ((zo1 + zm0 - 1.8) * 0.5), y2, "teras")
			say["ornek"] = int(say["ornek"]) + 2
			_levha(sv, p + o * ((zi1 + zo0) * 0.5), y, "peribolos")
			_levha(sv, p + o * (zi0 - 8.0), y, "sehir_onu")
			sv += adim
		kam += 100.0
	print("OTURTMA sure_s=%.0f kule_atla=%d" % [(Time.get_ticks_msec() - t0) / 1000.0, int(say["kule_atla"])])
	for k: String in yerler:
		for s: String in yerler[k]:
			print("OTURTMA yer %s %s" % [k, s])
	print("OTURTMA ornek=%d bosluk=%d gomuk=%d yarik=%d levha=%d" % [say["ornek"], say["bosluk"], say["gomuk"], say["yarik"], say["levha"]])


func _levha(sv: float, q: Vector2, y: float, ad: String) -> void:
	var h := _isin(q)
	var ga := _ust(h, "arazi", y + 3.0)
	var top_sur := NAN
	for e: Array in h:
		if String(e[1]) == "sur" and float(e[0]) <= y + 1.5 and float(e[0]) >= y - 1.5:
			top_sur = float(e[0])
			break
	if is_nan(top_sur):
		return
	if is_nan(ga):
		# arazi yok: sur yüzeyi zemin; altında başka yüzey yoksa ve kenarı görünüyorsa levha sayılmaz (zemin o)
		return
	# yalnız YATAY yüzey (moloz yığını, fıçı, basamak değil): 0,7 m çevresinde aynı yükseklikte (±3 cm)
	for dq: Vector2 in [Vector2(0.7, 0), Vector2(-0.7, 0), Vector2(0, 0.7), Vector2(0, -0.7)]:
		var ok := false
		for e: Array in _isin(q + dq):
			if String(e[1]) == "sur" and absf(float(e[0]) - top_sur) < 0.03:
				ok = true
				break
		if not ok:
			return
	if top_sur > ga + 0.10:
		_kayit("levha", sv, ad + " sur yüzeyi arazinin %.2f m üstünde" % (top_sur - ga), q)
