extends Node3D
## TUR-6 HAVADA denetimi (gerçek kurucu: IstDunya.build → IstSehir.attach_v2 → görsel birlik):
##   xvfb-run -a godot --path . --rendering-driver opengl3 res://tests/_ist/havada_denetim.tscn
## Son satır: HAVADA pencere=<n> esya=<n> cati=<n>
##   pencere: v2 evlerinin (IstSokak.houses; her ev kendi örneği ve türüyle) üst kat pencereleri: penceresi (kemer + denizlik,
##            ±0,75 m) saçağın (H) üstüne taşan ya da zemin kat duvarına inen pencere. Gece yanan pencereler aynı kuraldan.
##            Aynı sayım eski kuralla (max(1, kat) — yayındaki bölümün davranışı) "HAVADA_ESKI" satırında (karşılaştırma).
##   esya:    IstHayat "kutu" katmanında (sandık, yük, tezgâh, baca, direk) (a) düz birim KÜP ağıyla çizilen kayıt ve
##            (b) zemine oturmayan kayıt: alt yüzü zeminden 0,4–3 m yukarıda ve 8 m çevresinde ev olmayan (çatı bacası,
##            direk tepesi ve ip sayılmaz: ince/uzun ya da evin üstündekiler).
##   cati:    ev tabanının dört köşesinin de suda (IstGeo.h < 0,1 m) olduğu evler (suda yüzen çatı).
## Kapsam (dürüst): pencere sayımı v2 ev kurucusunun (evler.gd) pencereleri; öteki parça kurucularının (Haliç mahallesi,
## kuzeybatı semti, Galata) kendi pencereleri bu sayıma girmez.

var dunya: Node3D


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	dunya = IstDunya.build(self, false, Vector3(-1200.0, 20.0, -200.0))
	print("HAVADA yukleme_ms=%d" % (Time.get_ticks_msec() - t0))
	for i in 60:
		await get_tree().process_frame
	var g = load("res://scripts/world/ist/gorsel_dil.gd").aktif
	if g != null:
		g.bitir()
	await get_tree().process_frame
	var pen := _pencere(true)
	var pen_eski := _pencere(false)
	var es := _esya()
	var ca := _cati()
	print("HAVADA_ESKI pencere=%d" % pen_eski)
	print("HAVADA ayrinti kup=%d havada_esya=%d ev=%d" % [es[0], es[1], IstSehir.sokak.houses.size() if IstSehir.sokak else 0])
	print("HAVADA pencere=%d esya=%d cati=%d" % [pen, es[0] + es[1], ca])
	get_tree().quit(0)


func _pencere(v2: bool) -> int:
	var say := 0
	if IstSehir.sokak == null:
		return -1
	for h: Dictionary in IstSehir.sokak.houses:
		var v := int(h["v"])
		var tip := String(h["tip"])
		var d := IstEvler.dims(v)
		var p := IstEvler.plan(d.x, d.z, d.y, IstEvler._tohum(v, tip), tip)
		var gf: float = p["gf"]
		var H := d.y
		if H <= gf + 0.1:
			continue
		var floors := maxi(1, int(round((H - gf) / IstEvler.UF)))
		for fl in floors:
			var wy := IstEvler.pencere_y(gf, H, fl, v2)
			if wy < 0.0:
				continue
			if wy + 0.6 > H - 0.05 or wy - 0.6 < gf - 0.35:
				say += 1
	return say


func _esya() -> Array:
	var kup := 0
	var havada := 0
	var h: Node = null
	for c in get_tree().root.find_children("IstHayat", "", true, false):
		h = c
		break
	if h == null or not ("K" in h):
		return [-1, -1]
	var K: Dictionary = h.get("K")
	if not K.has("kutu"):
		return [0, 0]
	var kt = K["kutu"]
	var kup_ag: Mesh = load("res://scripts/world/ist/hayat_mesh.gd").kutu()
	var kup_view := false
	for vw: Dictionary in kt.views:
		if vw.get("mesh") == kup_ag:
			kup_view = true
	# ev ızgarası (8 m)
	var evg := {}
	if IstSehir.sokak:
		for e: Dictionary in IstSehir.sokak.houses:
			var c: Vector2 = e["c"]
			for dx in [-1, 0, 1]:
				for dz in [-1, 0, 1]:
					evg[Vector2i(floori(c.x / 8.0) + dx, floori(c.y / 8.0) + dz)] = true
	var stride: int = kt.stride
	for key in kt.cells:
		var a: PackedFloat32Array = kt.cells[key]
		for i in a.size() / stride:
			var o := i * stride
			var b := Basis(Vector3(a[o], a[o + 4], a[o + 8]), Vector3(a[o + 1], a[o + 5], a[o + 9]), Vector3(a[o + 2], a[o + 6], a[o + 10]))
			var pos := Vector3(a[o + 3], a[o + 7], a[o + 11])
			var sc := b.get_scale()
			if kup_view:
				kup += 1
			if minf(sc.x, sc.z) < 0.2 or sc.y > 2.5:
				continue      # direk, ip, baca
			var alt := pos.y - sc.y * 0.5
			var yer := IstGeo.h(pos.x, pos.z)
			if alt - yer > 0.4 and alt - yer < 3.0 and not evg.has(Vector2i(floori(pos.x / 8.0), floori(pos.z / 8.0))):
				havada += 1
	return [kup, havada]


func _cati() -> int:
	var say := 0
	if IstSehir.sokak == null:
		return -1
	for e: Dictionary in IstSehir.sokak.houses:
		var d := IstEvler.dims(int(e["v"]))
		var c: Vector2 = e["c"]
		var bas := Basis(Vector3.UP, float(e["yaw"]))
		var su := 0
		for o: Vector3 in [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(-0.5, 0, 0.5), Vector3(0.5, 0, 0.5)]:
			var q := Vector3(c.x, 0, c.y) + bas * (o * Vector3(d.x, 0, d.z))
			if IstGeo.h(q.x, q.z) < 0.1:
				su += 1
		if su == 4:
			say += 1
	return say
