class_name IstHalicKapi
extends RefCounted
## Petrion ve Fener (Phanarion) kapıları: Haliç suru üzerinde iki kuleli kapı yapısı. Yerel: merkez kapı geçidi, deniz -z.
## Geçit 3,4 m x 3,6 m; kapı üstü yürüme yolu; kule merdiveni şehir yüzünde.

const K = preload("res://scripts/world/ist/halic_kit.gd")


static func dims(k: float) -> Dictionary:
	var kk := clampf(k, 0.3, 1.0)
	return {"H": maxf(7.0, 12.0 * kk), "TW": maxf(5.0, 6.0 * kk + 1.0), "TD": maxf(5.2, 7.0 * kk), "wall_H": maxf(5.4, 9.0 * kk)}


static func build(host: Node3D, k: float, lod: int, which: String) -> void:
	var d := dims(k)
	var H: float = d["H"]
	var TW: float = d["TW"]
	var TD: float = d["TD"]
	var root := Node3D.new()
	root.name = "HalicKapi_" + which
	host.add_child(root)
	var gw := 3.4
	var gh := 3.6
	var col := Color("bfae90") if which == "fener" else Color("c4b494")
	var half := gw * 0.5 + TW
	if lod >= 2:
		K.slab(root, -half, half, -TD * 0.5, TD * 0.5, 0, H, col)
		return
	# İki kule + geçit üstü köprü (gövde) + sur kolları
	for s in [-1.0, 1.0]:
		var x0: float = s * gw * 0.5
		var x1: float = s * (gw * 0.5 + TW)
		K.slab(root, minf(x0, x1), maxf(x0, x1), -TD * 0.5, TD * 0.5, 0, H, col, "ashlar").name = "Kule"
		# tuğla bantlar ve mazgallar
		for y in [2.0, H * 0.5, H - 1.0]:
			Props.box(root, Vector3(TW + 0.06, 0.3, 0.05), Vector3((x0 + x1) * 0.5, y, -TD * 0.5 - 0.03), K.BRICK)
			Props.box(root, Vector3(TW + 0.06, 0.3, 0.05), Vector3((x0 + x1) * 0.5, y, TD * 0.5 + 0.03), K.BRICK)
		for q in [-1.0, 1.0]:
			Props.box(root, Vector3(0.18, 0.9, 0.06), Vector3((x0 + x1) * 0.5 + q * TW * 0.2, H * 0.62, -TD * 0.5 - 0.04), Color("17130f"))
		# Sur kolu
		var sx1: float = s * (gw * 0.5 + TW + 12.0)
		K.slab(root, minf(x1, sx1), maxf(x1, sx1), -1.4, 1.4, 0, d["wall_H"], Color("c9b89a"), "ashlar").name = "SurKol"
		K.slab(root, minf(x1, sx1), maxf(x1, sx1), -1.4, -1.0, d["wall_H"], d["wall_H"] + 1.05, Color("cdbd9f"), "ashlar")
		K.slab(root, minf(x1, sx1), maxf(x1, sx1), 1.0, 1.4, d["wall_H"], d["wall_H"] + 1.05, Color("cdbd9f"), "ashlar")
		K.merlons(root, minf(x1, sx1), maxf(x1, sx1), -1.2, d["wall_H"] + 1.05, Color("cdbd9f"))
	# Geçit üstü: kapı kemeri altında lento ve yürüme yolu (kule tepeleri arası tek düz yol)
	K.slab(root, -gw * 0.5, gw * 0.5, -TD * 0.5, TD * 0.5, gh, H, col, "ashlar").name = "KapiUst"
	# Kemer çerçevesi iki yüzde
	for z in [-TD * 0.5 - 0.06, TD * 0.5 + 0.06]:
		K.arch_front(root, 0.0, 0.0, z, gw, gh, Color("b6a583"))
	# Parapetler (deniz yüzü sürekli, şehir yüzü sürekli), kapı üstü açık geçit; kule tepeleri aynı seviye
	var hw := gw * 0.5 + TW
	K.slab(root, -hw, hw, -TD * 0.5, -TD * 0.5 + 0.4, H, H + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, -hw, -hw + 0.4, -TD * 0.5 + 0.4, TD * 0.5 - 0.4, H, H + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, hw - 0.4, hw, -TD * 0.5 + 0.4, TD * 0.5 - 0.4, H, H + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, -hw, -2.0, TD * 0.5 - 0.4, TD * 0.5, H, H + 1.05, Color("cdbd9f"), "ashlar")
	K.slab(root, 2.0, hw, TD * 0.5 - 0.4, TD * 0.5, H, H + 1.05, Color("cdbd9f"), "ashlar")
	K.merlons(root, -hw, hw, -TD * 0.5 + 0.2, H + 1.05, Color("cdbd9f"), 1.4)
	# Merdiven: şehir yüzünde ortada, tepeye (kapı üstüne)
	var n := int(ceil(H / K.STEP_RISE))
	K.stair(root, Vector3(0, 0, TD * 0.5 + 0.34 * n), Vector3(0, 0, -1), H, 1.8, Color("b4a384"))
	# Kapı kanatları (açık, geçit duvarlarına yaslı) ve eşik
	for s in [-1.0, 1.0]:
		Props.box(root, Vector3(0.12, gh - 0.4, 1.4), Vector3(s * (gw * 0.5 - 0.07), gh * 0.5 - 0.1, -TD * 0.5 + 0.9), Color("5a3a22"))
	Props.set_pattern(Props.solid(root, Vector3(gw, 0.1, TD + 0.2), Vector3(0, 0.05, 0), Color("a89878")), Color("a89878"), "flagstone")
	if which == "petrion":
		# Haç kabartması ve Meryem ikonu nişi (Petrion: Rum mahallesi)
		Props.box(root, Vector3(0.18, 1.1, 0.08), Vector3(0, gh + 1.1, TD * 0.5 + 0.08), Color("b8932f"))
		Props.box(root, Vector3(0.7, 0.18, 0.08), Vector3(0, gh + 1.25, TD * 0.5 + 0.08), Color("b8932f"))
		Props.box(root, Vector3(0.8, 1.1, 0.12), Vector3(-gw * 0.5 - TW * 0.5, 2.6, TD * 0.5 + 0.06), Color("3a2a1a"))
		Props.box(root, Vector3(0.5, 0.8, 0.06), Vector3(-gw * 0.5 - TW * 0.5, 2.6, TD * 0.5 + 0.12), Color("d9b43a"))
		Flame.add(root, Vector3(-gw * 0.5 - TW * 0.5, 3.3, TD * 0.5 + 0.3), 0.14, 0.26)
	else:
		# Fener (Phanarion): sağ kulenin tepesinde ışık ocağı; kapı yanında iki büyük fener
		K.blk(root, Vector3(1.2, 1.4, 1.2), Vector3(gw * 0.5 + TW * 0.5, H + 0.7, 0.0), Color("4a4a4a"), "ashlar")
		Flame.add(root, Vector3(gw * 0.5 + TW * 0.5, H + 1.4, 0.0), 0.55, 1.1)
	for s in [-1.0, 1.0]:
		Props.box(root, Vector3(0.3, 0.2, 0.3), Vector3(s * (gw * 0.5 + 0.5), 3.4, -TD * 0.5 - 0.2), Color("5e4e3e"))
		Flame.add(root, Vector3(s * (gw * 0.5 + 0.5), 3.55, -TD * 0.5 - 0.2), 0.2, 0.36)
	# Bayrak
	Props.cyl(root, 0.06, 4.0, Vector3(-hw + 0.8, H + 2.0, -TD * 0.5 + 1.0), Color("3a2a1a"), Vector3.ZERO, 6)
	Props.box(root, Vector3(1.4, 0.9, 0.04), Vector3(-hw + 1.5, H + 3.4, -TD * 0.5 + 1.0), Color("a82a2a"))
	Props.box(root, Vector3(0.12, 0.6, 0.05), Vector3(-hw + 1.5, H + 3.4, -TD * 0.5 + 1.0), Color("d9b43a"))
	# Sur kolu merdivenleri
	var wh: float = d["wall_H"]
	var sn := int(ceil(wh / K.STEP_RISE))
	K.stair(root, Vector3(hw + 12.0 - 1.0, 0, 1.4 + 0.34 * sn), Vector3(0, 0, -1), wh, 1.8, Color("b4a384"))


static func perches(k: float) -> Array:
	var d := dims(k)
	var gw := 3.4
	return [Vector3(gw * 0.5 + d["TW"] * 0.5, d["H"] + 1.05, -d["TD"] * 0.5 + 0.3), Vector3(0, d["H"] + 1.0, 0)]


static func climbs(k: float) -> Array:
	var d := dims(k)
	var H: float = d["H"]
	var n := int(ceil(H / K.STEP_RISE))
	return [[Vector3(0, 0, d["TD"] * 0.5 + 0.34 * n + 0.4), Vector3(0, H, d["TD"] * 0.5 - 0.3), "basamak"]]
