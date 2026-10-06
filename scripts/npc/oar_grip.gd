class_name OarGrip
extends Node
## Kürekçinin elleri küreğin sapında. Kürek kendi başına sallanmaz: her karede kürekçinin çekiş evresinden
## (Rig.row_phase; 0 = pala suya girer) sapın gideceği yer bulunur (yakalayışta önde, bitişte karnının önünde),
## palanın yüksekliği (çekerken suyun içinde, geri alırken suyun üstünde, yatık) seçilir; kürek ıskarmozun çevresinde
## o yöne döner, gövde uzanmak için öne eğilir / çekerken geriye yaslanır, iki el (Rig.reach) sapa oturur.
## Bütün Person ve bölüm _process'lerinden sonra çalışır (PRIORITY): kürek ve eller aynı karede, son sözle.
## Kürekçisi olmayan kürek ya hayalet bir kürekçinin yerinden aynı yolla döner (Tolga'nın yeri, `phantom`), ya da
## dinlenir (`rest`: sap içeride, pala suyun hemen üstünde, kıpırdamaz).
## Kürek düğümü (make_oar): kökü ıskarmozda; yerel +x * side palaya doğru, sap öbür yanda.

const PRIORITY := 100
const METER_CATCH := 0.81      # RowMeter'in iyi penceresinin ortası: pala o anda suya girer
const DRIVE := 0.42            # çekişin evredeki payı (gerisi geri alış)
const TEMPO := 0.55            # kendi temposuyla çeken (row_phase -1): saniyede çekiş
const Z_FIN := 0.18            # sapın kürekçinin önündeki uzaklığı: bitiş / yakalayış
const Z_CATCH := 0.85
const LEAN_FIN := -0.15
const LEAN_CATCH := 0.38
const R_REST := 0.3

var rower: Node3D              # rig'i olan kürekçi (Person, Soldier); null ise hayalet
var frame: Node3D              # hayaletin yeri ve yönü
var oars: Array = []           # [{"node": Node3D, "hand": "both" | "auto", "x": float}]
var water_y := 0.0
var phase := Rig.ROW_REST      # hayaletin evresi (bölüm yazar)
var push := false              # hayalet pruvaya bakıyor: sapı iterek çeker
var reach_miss := 0.0          # son karede ellerin sapa kalan en büyük uzaklığı (test)
var _boat: Node3D
var _seat: Transform3D
var _w := 0.0


func _ready() -> void:
	process_priority = PRIORITY


## Kürek kur: `lock` teknenin yerelinde ıskarmoz, `side` +1 / -1 (yerel x yönünde dışarı). İçeride `inboard` m sap,
## palanın ortası dışarıda `outboard` m. Iskarmozda iki kısa dikme (kürek bunlara dayanır, havada durmaz).
static func make_oar(boat: Node3D, lock: Vector3, side: float, inboard: float, outboard: float, r := 0.04,
		blade := Vector2(0.7, 0.22), pin := 0.16) -> Node3D:
	var p := Node3D.new()
	p.position = lock
	p.set_meta("side", side)
	p.set_meta("inboard", inboard)
	p.set_meta("blade", outboard)
	boat.add_child(p)
	var far := outboard + blade.x * 0.5
	Props.cyl(p, r, inboard + far, Vector3(side * (far - inboard) * 0.5, 0, 0), Color("c9a878"), Vector3(0, 0, 90), 5)
	Props.box(p, Vector3(blade.x, 0.03, blade.y), Vector3(side * outboard, 0, 0), Color("b8905a"))
	Props.ball(p, r * 1.15, Vector3(-side * inboard, 0, 0), Color("a88a5a"), Vector3(1.4, 1, 1), 5)    # sap ucu
	if pin > 0.0:
		for dz: float in [-0.075, 0.075]:
			Props.cyl(boat, 0.022, pin + 0.1, lock + Vector3(0, -pin * 0.5 + 0.05, dz), Color("4a3422"), Vector3.ZERO, 4)
	rest(p)
	return p


## Kürekçiye kürek(ler)ini bağla. `list`: [[kürek, "both"]] (iki elle tek kürek) ya da [[sol, "auto"], [sağ, "auto"]]
## (her ele bir kürek: en yakın omuz). Kürekçinin çocuğu olur (kürekçiyle silinir).
static func attach(p_rower: Node3D, list: Array, p_water_y := 0.0) -> OarGrip:
	var g := OarGrip.new()
	g.rower = p_rower
	g.water_y = p_water_y
	for it: Array in list:
		g.oars.append({"node": it[0], "hand": it[1], "x": 0.0 if it[1] == "both" else 0.2 * signf(_lateral(p_rower, it[0]))})
	p_rower.add_child(g)
	return g


## Kürekçisi olmayan ama çekilen kürek (oyuncunun yeri): `seat` teknenin yerelinde hayalet kürekçinin duruşu (+z bakar).
static func phantom(boat: Node3D, seat: Transform3D, list: Array, p_water_y := 0.0, p_push := false) -> OarGrip:
	var f := Node3D.new()
	f.transform = seat
	boat.add_child(f)
	var g := OarGrip.new()
	g.frame = f
	g.water_y = p_water_y
	g.push = p_push
	for it: Array in list:
		g.oars.append({"node": it[0], "hand": it[1], "x": 0.0 if it[1] == "both" else 0.2 * signf(_lateral(f, it[0]))})
	f.add_child(g)
	return g


## RowMeter evresinden çekiş evresi (pala iyi pencerenin ortasında suya girer).
static func meter(p: float) -> float:
	return fmod(p - METER_CATCH + 1.0, 1.0)


static func _lateral(fr: Node3D, oar: Node3D) -> float:
	return (fr.transform.basis.inverse() * (oar.position - fr.position)).x


## Dinlenen kürek: teknenin ortasına dik, pala suyun hemen üstünde, yatık.
static func rest(oar: Node3D, p_water_y := 0.0, raise := 0.15) -> void:
	if not oar.is_inside_tree():
		return
	var side: float = oar.get_meta("side", 1.0)
	var boat := oar.get_parent() as Node3D
	var hd := -boat.global_transform.basis.x.normalized() * side
	hd.y = 0.0
	hd = hd.normalized()
	var t := oar.global_position
	var a := asin(clampf((t.y - (p_water_y + raise)) / float(oar.get_meta("blade", 2.0)), -0.9, 0.9))
	_pose(oar, hd * cos(a) + Vector3.UP * sin(a), 0.0)


## Küreği yönelt: `u` ıskarmozdan sapa (dünya), `roll` palanın sap çevresinde dönüşü (0 yatık, PI/2 dik).
static func _pose(oar: Node3D, u: Vector3, roll: float) -> void:
	var side: float = oar.get_meta("side", 1.0)
	var xw := (-u * side).normalized()
	var y0 := (Vector3.UP - xw * Vector3.UP.dot(xw)).normalized()
	var z0 := xw.cross(y0)
	var yw := y0 * cos(roll) + z0 * sin(roll)
	var zw := -y0 * sin(roll) + z0 * cos(roll)
	var par := oar.get_parent() as Node3D
	var pb := par.global_transform.basis.orthonormalized() if par else Basis()
	oar.basis = pb.inverse() * Basis(xw, yw, zw)


func _process(delta: float) -> void:
	var fr := rower if rower else frame
	if fr == null or not is_instance_valid(fr) or not fr.is_inside_tree():
		return
	if _boat == null:
		_boat = fr.get_parent() as Node3D
		_seat = fr.transform
	if fr.get_parent() != _boat:
		return      # kayıktan indi
	var rig: Rig = null
	if rower:
		rig = rower.get("rig")
		if rig == null or rig.activity != "row" or rig.arm_l == null or rig.arm_r == null:
			return
	var ph: float = rig.row_phase if rig else phase
	var resting := ph <= Rig.ROW_REST + 0.5
	if ph < 0.0 and not resting:
		ph = fmod(Time.get_ticks_msec() * 0.001 * TEMPO, 1.0)
	_w = move_toward(_w, 0.0 if resting else 1.0, delta * 1.5)
	# Çekiş: r 1 yakalayış (sap önde) → 0 bitiş; depth 1 pala suda
	var rp: float
	var depth := 0.0
	if ph < DRIVE:
		rp = 0.5 + 0.5 * cos(PI * ph / DRIVE)
		depth = 1.0 - smoothstep(DRIVE - 0.06, DRIVE + 0.02, ph)
	else:
		rp = 0.5 - 0.5 * cos(PI * (ph - DRIVE) / (1.0 - DRIVE))
		depth = smoothstep(0.93, 1.0, ph)
	var r := lerpf(R_REST, rp, _w)
	depth *= _w
	var blade_y := water_y + lerpf(lerpf(0.12, 0.32, _w), -0.12, depth)
	var roll := depth * PI * 0.5
	var sg := _boat.global_transform * _seat
	var rz := (1.0 - r) if push else r
	var lean := lerpf(0.05, lerpf(LEAN_FIN, LEAN_CATCH, r), _w)
	var body: Node3D = rig.body if rig else null
	if body:
		body.rotation.x = lean
	var sy := 0.0
	if rig:
		sy = (rig.arm_l.global_position.y + rig.arm_r.global_position.y) * 0.5
	# Kürekler
	var poses: Array = []
	for e: Dictionary in oars:
		var o: Node3D = e["node"]
		if not is_instance_valid(o) or not o.is_visible_in_tree():
			poses.append(null)
			continue
		var inboard: float = o.get_meta("inboard", 0.8)
		var bl: float = o.get_meta("blade", 2.5)
		var t := o.global_position
		var q := sg * Vector3(e["x"], 0.8, lerpf(Z_FIN, Z_CATCH, rz))
		var hd := q - t
		hd.y = 0.0
		hd = hd.normalized() if hd.length() > 0.01 else -_boat.global_transform.basis.x * float(o.get_meta("side", 1.0))
		var sa := clampf((t.y - blade_y) / bl, -0.9, 0.9)
		if rig:
			# Sap kürekçinin karnı ile göğsü arasında kalsın (ulaşılmaz yükseklikte pala suya girmez, el sapı bırakmaz)
			var grip_d := inboard - (0.25 if e["hand"] == "both" else 0.07)
			var hy := clampf(t.y + grip_d * sa, sy - 0.55, sy + 0.06)
			sa = clampf((hy - t.y) / grip_d, -0.9, 0.9)
		var u := hd * cos(asin(sa)) + Vector3.UP * sa
		_pose(o, u, roll)
		poses.append([o, t, u.normalized(), inboard])
	if rig == null:
		return
	# Eller: iki elle tek kürek → omuzların sap üstündeki en yakın noktaları; her ele bir kürek → sap ucu
	var arms := [[rig.arm_l, rig.elbow_l], [rig.arm_r, rig.elbow_r]]
	var targets: Array = [null, null]
	for i in oars.size():
		var pz = poses[i]
		if pz == null:
			continue
		var t: Vector3 = pz[1]
		var u: Vector3 = pz[2]
		var inboard: float = pz[3]
		if oars[i]["hand"] == "both":
			var ds: Array = []
			for a in arms:
				ds.append(clampf(((a[0] as Node3D).global_position - t).dot(u), 0.25, inboard - 0.05))
			if absf(ds[0] - ds[1]) < 0.24:
				var m := clampf((ds[0] + ds[1]) * 0.5, 0.37, inboard - 0.17)
				var sgn := 1.0 if ds[0] >= ds[1] else -1.0
				ds = [m + 0.12 * sgn, m - 0.12 * sgn]
			for k in 2:
				targets[k] = t + u * float(ds[k]) + Vector3.UP * 0.02
		else:
			var g := t + u * (inboard - 0.07) + Vector3.UP * 0.02
			var dl := (rig.arm_l.global_position - t).length()
			var dr := (rig.arm_r.global_position - t).length()
			var k := 0 if dl < dr else 1
			if targets[k] != null:
				k = 1 - k
			targets[k] = g
	# Uzanamıyorsa biraz daha öne eğil
	if body:
		var worst := 0.0
		for k in 2:
			if targets[k] == null:
				continue
			var a: Node3D = arms[k][0]
			var el: Node3D = arms[k][1]
			var ln := (-el.position.y + (el.get_meta("hand", Vector3(0, -0.27, 0)) as Vector3).length()) * a.global_transform.basis.get_scale().x
			worst = maxf(worst, ((targets[k] as Vector3) - a.global_position).length() - ln * 0.97)
		if worst > 0.0:
			body.rotation.x = clampf(lean + worst / 1.1, -0.3, 0.65)
	reach_miss = 0.0
	var fb := sg.basis.orthonormalized()
	for k in 2:
		if targets[k] == null:
			continue
		var a: Node3D = arms[k][0]
		var sx := signf(a.position.x) if absf(a.position.x) > 0.01 else (1.0 if k == 1 else -1.0)
		reach_miss = maxf(reach_miss, Rig.reach(a, arms[k][1], targets[k], fb * Vector3(sx * 0.7, -0.5, -0.6)))
