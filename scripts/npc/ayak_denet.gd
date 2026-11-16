extends RefCounted
## AYAKAUDIT (otomatik testte; VISAUDIT/POSEAUDIT kalıbı): kameranın gördüğü 40 m içindeki her ayaktaki insanın
## (persons, soldiers) her ayağının tabanı ile altındaki GÖRÜNEN zemin (Unclip.floor_y) arasındaki fark. Yalnız o an
## yere basması gereken ayak ölçülür: dururken ikisi (FK duruşunun kaldırmadığı), yürürken basma evresinin ortasındaki.
## Taban görünen ama çarpışmasız bir ağın üstündeyse (Unclip.on_mesh) fark 0 (VISAUDIT float gibi).
## Kapsam dışı (Ayak.kapsam_disi: oturan, yatan, tırmanan, binen, taşınan, duruş takımı…) ölçülmez.
## Havada > 6 cm ya da gömük > 6 cm iki ardışık ölçümde (yarım saniye arayla) sürüyorsa bir kez yazar:
##   "AYAKAUDIT yakin|uzak scene=… who=Sınıf/ad(üst) ayak=L|R fark=+0.12 d=… at=… durum=dur|yuru|anim act=…"
## (fark artı: havada, eksi: gömük; yakin: kameraya ≤ 25 m). Testi düşürmez; sayım ÖNCE|SONRA raporu için.

const Ayak := preload("res://scripts/npc/ayak.gd")
const ESIK := 0.06
const YAKIN := 25.0
const MENZIL := 40.0
const TABAN_P := Vector3(0, -0.0765, 0.05)

static var _t_ms := 0
static var _rr := 0
static var _bad := {}
static var _seen := {}
static var _scene := ""


static func tick(ctx: Node3D) -> void:
	if not GameState.autotest:
		return
	var now := Time.get_ticks_msec()
	if now - _t_ms < 500:
		return
	_t_ms = now
	var tree := ctx.get_tree()
	var sc := tree.current_scene if tree else null
	if sc == null:
		return
	if sc.scene_file_path != _scene:
		_scene = sc.scene_file_path
		_seen.clear()
		_bad.clear()
	var cam := Ayak.kamera(ctx)
	if cam == null:
		return
	var cp := cam.global_position
	var list: Array = tree.get_nodes_in_group("persons") + tree.get_nodes_in_group("soldiers")
	var n := list.size()
	if n == 0:
		return
	var lim := mini(n, 40)
	for i in lim:
		var who := list[(_rr + i) % n] as Node3D
		if who == null or not is_instance_valid(who):
			continue
		_olc(who, cp, cam, sc)
	_rr = (_rr + lim) % n


static func _olc(who: Node3D, cp: Vector3, cam: Camera3D, sc: Node) -> void:
	var rg = who.get("rig")
	if not (rg is Rig):
		return
	var r := rg as Rig
	var d := cp.distance_to(who.global_position)
	if d > MENZIL:
		return
	if d > 6.0 and not cam.is_position_in_frustum(who.global_position + Vector3(0, 0.3, 0)):
		return
	if Ayak.kapsam_disi(r) != "":
		return
	if r.leg_l == null or r.knee_l == null or r.knee_r == null:
		return
	var inv := who.global_transform.affine_inverse()
	var durum := "yuru" if r.yuruyor else ("anim" if r.lock > 0 else "dur")
	for s in 2:
		var key := who.get_instance_id() * 2 + s
		if _seen.has(key):
			continue
		var kn: Node3D = r.knee_l if s == 0 else r.knee_r
		var an := kn.get_node_or_null("Ankle") as Node3D
		if an == null:
			continue
		var exp := false
		if r.ayak and r.ayak.mod > 0:
			exp = r.ayak.basiyor[s]
		elif r.yuruyor:
			var u := fposmod((r._walk_phase + PI * 0.5) / TAU + 0.5 * s, 1.0)
			exp = u > 0.08 and u < 0.42
		else:
			exp = (inv * (an.global_transform * Vector3(0, -0.0765, 0))).y < 0.05
		if not exp:
			_bad.erase(key)
			continue
		var sole := an.global_transform * TABAN_P
		var fy := Unclip.floor_y(who, sole, 0.5, 1.0)
		if is_nan(fy):
			_bad.erase(key)
			continue
		var gap := sole.y - fy
		# Görünen ama çarpışmasız bir ağın (döşeme, tabla) üstündeki taban havada değildir (VISAUDIT float'ın ölçüsü)
		if gap > ESIK and Unclip.on_mesh(who, sole):
			gap = 0.0
		if absf(gap) <= ESIK:
			_bad.erase(key)
			continue
		var c: int = _bad.get(key, 0) + 1
		_bad[key] = c
		if c < 2:
			continue
		_seen[key] = true
		var par := who.get_parent()
		var ik := "yok"
		if r.ayak:
			ik = "w%.1f/m%d/pel%+.2f/g%s/gy%+.2f/zemin%+.2f" % [r.ayak.w, r.ayak.mod, r.ayak.pel, "1" if r.ayak._g_ok[s] else "0",
				r.ayak._g_y[s] - who.position.y, fy - who.global_position.y]
		print("AYAKAUDIT %s scene=%s who=%s/%s(%s) ayak=%s fark=%+.2f d=%.1f at=%s durum=%s act=%s ik=%s" % ["yakin" if d <= YAKIN else "uzak",
			sc.scene_file_path.get_file(), (who.get_script() as Script).get_global_name() if who.get_script() else who.get_class(),
			who.name, par.name if par else "", "L" if s == 0 else "R", gap, d, sole.snapped(Vector3.ONE * 0.1), durum, r.activity, ik])
