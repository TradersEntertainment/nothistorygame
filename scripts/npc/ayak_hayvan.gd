extends RefCounted
## Hayvanlarda zemine uyum (fizik-ayak, ikinci öncelik): at, öküz, keçi, tavuk, kedi. Kökle gövde arasına yalnız bu
## modülün yazdığı bir "AyakEgim" düğümü girer. Dört ayaklıda ön ve arka ayak çiftinin altındaki zeminin farkı gövdeye
## eğim (burun yukarı/aşağı) verir, gövde iki çiftin zeminine göre iner/çıkar; bacaklar eğimin tersine dönüp dik kalır
## (hayvanın betiği `egim`i bacak açısına ekler). İki ayaklı/küçükte (tavuk, kedi) yalnız yükseklik.
## Bütçe: kameraya LOD metreden yakında; ışın yürürken çeyrek saniyede bir, dururken iki saniyede bir (iki ışın).
## Kök, çarpışma gövdesi (öküzün OxBody'si) ve yol aynı kalır.

const Ayak := preload("res://scripts/npc/ayak.gd")
const LOD := 30.0
const EGIM_EN := 0.3      # rad (~17°): binicinin eğimi POSEAUDIT sınırının (20°) altında kalsın

var h: Node3D
var dugum: Node3D
var on_z := 0.5
var arka_z := -0.5
var dort := true
var egim := 0.0           # rad, burun yukarı artı
var dy := 0.0             # gövdenin köke göre inişi/çıkışı (m)
var _hf := 0.0
var _hr := 0.0
var _t := 0.0
var _lp := Vector3.INF


## h'nin çocuklarından `tasinan`ları yeni AyakEgim düğümüne taşır (yerel dönüşümleri aynı). on_z/arka_z: ön ve arka
## ayak çiftinin hayvanın yerel z'si (dört ayaklı değilse ikisi de 0).
static func kur(p_h: Node3D, tasinan: Array, p_on_z: float, p_arka_z: float):
	var a = new()
	a.h = p_h
	a.on_z = p_on_z
	a.arka_z = p_arka_z
	a.dort = absf(p_on_z - p_arka_z) > 0.1
	var e := Node3D.new()
	e.name = "AyakEgim"
	p_h.add_child(e)
	for n: Node3D in tasinan:
		if n != e and n.get_parent() == p_h:
			p_h.remove_child(n)
			e.add_child(n)
	a.dugum = e
	return a


func guncelle(delta: float) -> void:
	if not h.is_inside_tree() or not Ayak.etkin:
		return
	var cam := Ayak.kamera(h)
	var yakin := cam != null and h.global_position.distance_squared_to(Ayak._cam_pos) < LOD * LOD
	var k := clampf(delta * 6.0, 0.0, 1.0)
	if not yakin:
		if absf(egim) + absf(dy) > 0.0005:
			egim = lerpf(egim, 0.0, k)
			dy = lerpf(dy, 0.0, k)
			_yaz()
		_lp = Vector3.INF
		return
	_t -= delta
	var root := h.position
	var moved := _lp.x == INF or root.distance_squared_to(_lp) > 0.0025
	if _t <= 0.0 or (moved and _t < 1.75):
		_t = 2.0
		_lp = root
		var par := h.get_parent() as Node3D
		var pt := par.global_transform if par else Transform3D.IDENTITY
		var ot := h.transform
		if dort:
			_hf = _zemin(pt, ot * Vector3(0, 0, on_z), root.y)
			_hr = _zemin(pt, ot * Vector3(0, 0, arka_z), root.y)
		else:
			_hf = _zemin(pt, root, root.y)
			_hr = _hf
		# Kökün tam altında 25 cm içinde çarpışma zemini yoksa (görünen-çarpışmasız güverte/döşeme ağı: ışın alttakini
		# görür) gövde yerinde kalır. Eğimde arka toynağın alçak olması doğal: yalnız kökün altına bakılır.
		# (Unclip.on_mesh sorulmaz: sahnenin bütün ağacını tarıyor)
		if minf(_hf, _hr) < -0.12 and (not dort or _zemin(pt, root, root.y) < -0.24):
			_hf = 0.0
			_hr = 0.0
	var te := 0.0
	var ty := _hf
	if dort:
		var s := clampf((_hf - _hr) / (on_z - arka_z), -sin(EGIM_EN), sin(EGIM_EN))
		te = asin(s)
		ty = _hf - on_z * s
	egim = lerpf(egim, te, k)
	dy = lerpf(dy, ty, k)
	_yaz()


func _yaz() -> void:
	dugum.position.y = dy
	dugum.rotation.x = -egim


## Ebeveyn uzayındaki p'nin altındaki görünen zemin, köke (ref_y) göre; bulunmazsa 0 (kök zeminde sayılır) ve
## kısa sürede yeniden denenir (sahnenin ilk karesinde fizik uzayı henüz kurulmamış olabilir)
func _zemin(pt: Transform3D, p: Vector3, ref_y: float) -> float:
	var wp := pt * Vector3(p.x, ref_y, p.z)
	var y := Unclip.floor_y(h, wp, 0.5, 0.8)
	if is_nan(y):
		_t = minf(_t, 0.25)
		return 0.0
	var lp := pt.affine_inverse() * Vector3(wp.x, y, wp.z)
	return clampf(lp.y - ref_y, -0.5, 0.4)
