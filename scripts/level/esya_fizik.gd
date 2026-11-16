class_name EsyaFizik
extends Node3D
## Dekor eşyasının fiziği (fıçı, sandık, küçük eşya): "uyuyan dekor → çarpınca canlanan gövde".
##
## Eşya kurulurken yalnız KAYDA geçer (kurucu bugünkü gibi durağan çizer: MultiMesh örneği ya da tek düğüm; maliyet yok).
## Oyuncu tekmelediğinde (kick), koşarak çarptığında, yakınında patlama olduğunda ya da altındaki destek gidince o an
## gerçek gövdeye (RigidBody3D) döner: fıçı silindir gövde (yan yatınca yuvarlanır, dik dururken itilince devrilir),
## sandık kutu gövde (kenarından devrilir, itilince sürtünerek kayar), küçük eşya seker. Durunca zemine oturduğu
## denetlenir ve DONAR (freeze, durağan kip: fizik sunucusunda statik gövde, betik maliyeti yok); yeniden tekmelenebilir.
## Aynı anda en çok AZAMI_UYANIK gövde uyanık; fazlası gelince en eskisi zemine oturtulup dondurulur.
##
## Denetim (ESYAAUDIT): zemin altına düşen (kendi zemininin 2 m altı) → yerine konur ve sayılır; havada donan → zemine
## indirilir ve sayılır; duvara gömülen → ilk yerine konur ve sayılır; yol tıkayan (dar geçitte, korunan noktanın
## yanında donan) → kenara itilir ve sayılır; uyanık sınırı aşımı sayılır. Sahne kapanırken özet satırı yazılır.
##
## Oynanış eşyası (görev, yol, barikat, merdiven, taşıma nesnesi, sur sözleşmesi parçası) KAYDA GEÇMEZ: kayıt yalnız
## dekor kurucularındadır. Ayrıca korunan noktalar (koru()) yakınındaki eşya uyanmaz.

const AZAMI_UYANIK := 12
const HUCRE := 4.0                # yer ızgarası (m)
const TEKME_MENZIL := 1.45        # oyuncu merkezinden eşyanın yakın kenarına
const TEKME_BOY := 1.6            # bundan uzun eşya tekmelenmez
const KOSU_HIZ := 4.0             # koşarak çarpma eşiği (m/s)
const DUR_LIN := 0.06
const DUR_ACI := 0.12
const DUR_SURE := 0.45
const AZAMI_SURE := 9.0           # uyanık kalma sınırı (sn); sonra zorla oturtulup donar
const DUSME_PAYI := 2.0

# tür → [kütle kg, sürtünme, sekme, şekil, ses]
const TUR := {
	"fici": [45.0, 0.55, 0.12, "silindir", "land_thud"],
	"fici_bos": [16.0, 0.55, 0.2, "silindir", "land_thud"],
	"sandik": [28.0, 0.62, 0.08, "kutu", "footstep_wood"],
	"kalas": [14.0, 0.6, 0.1, "kutu", "footstep_wood"],
	"testi": [3.0, 0.5, 0.32, "silindir", "land_pot"],
	"gulle": [60.0, 0.5, 0.15, "kure", "kick_metal"],
}

# ---- kayıt (kurucular çağırır; sahne kurulurken)
static var _bek_mm := {}          # "Ad|x|y|z" -> tür   (Dressing: MultiMesh örneği, kök-yerel çerçevede)
static var _bek_dugum: Array = [] # [MeshInstance3D, StaticBody3D, tür]
static var _korunan: Array = []   # [Vector3 (dünya), yarıçap]
static var _ben: EsyaFizik = null
static var _kurulacak := false

var items: Array = []             # Dictionary
var uyanik: Array = []            # uyanık eşyalar (sıra: en eski önde)
var _izgara := {}                 # Vector2i -> Array[Dictionary]
var _taranan := {}                # MultiMeshInstance3D örnek kimliği -> true
var _tara_t := 0.0
var _bek_sayi := -1
var _player: Player
var _temas := {}                  # eşya kimliği -> yürüyerek dayanma süresi
var _son_hiz := 0.0
var _sira := 0
var sayac := {"kayit": 0, "uyanan": 0, "tekme": 0, "kosu": 0, "itme": 0, "patlama": 0, "destek": 0,
	"dusme": 0, "havada": 0, "gomuk": 0, "tikama": 0, "sinir": 0}
var olcum := {"en_cok_uyanik": 0}
var denetim_acik := false


# ======================================================================== kayıt API

## Dressing (crate/barrel): model() ile MultiMesh'e giden örnek. xf: Dressing kökünün yerel çerçevesinde örneğin
## dönüşümü (model'e verilenin aynısı), ad: Kit model adı.
static func kaydet_mm(ad: String, xf: Transform3D, tur: String) -> void:
	_bek_mm[_anahtar(ad, xf.origin)] = tur
	_kur()


## Tek düğüm eşya (Props.cyl + make_solid): görünen düğüm ve onun durağan gövdesi.
static func kaydet_dugum(gorunen: Node3D, govde: StaticBody3D, tur: String) -> void:
	if gorunen == null:
		return
	_bek_dugum.append([gorunen, govde, tur])
	_kur()


## Oynanış noktası: bu dairenin içindeki eşya uyanmaz, uyanan eşya burada donarsa kenara itilir.
static func koru(p: Vector3, r: float) -> void:
	_korunan.append([p, r])


## Oyuncunun tekme darbesi (Player.kick darbe anı). Önündeki eşyaya itki verir.
static func darbe(oyuncu: Node3D, hedef: Vector3, guc: float) -> void:
	if _ben == null or not is_instance_valid(_ben):
		return
	_ben._darbe(oyuncu, hedef, guc)


## Patlama/gülle: yakındaki eşyalar uyanır, dışa doğru savrulur.
static func patlama(p: Vector3, boy := 1.0) -> void:
	if _ben == null or not is_instance_valid(_ben):
		return
	_ben._patlama(p, boy)


## Tekme tuşuna basıldığında tekmelenecek dekor eşyası var mı (Traversal tırmanmaya başlamasın diye sorar).
static func tekme_var(oyuncu: Node3D) -> bool:
	if _ben == null or not is_instance_valid(_ben):
		return false
	if oyuncu is Player and not _ben._tekme_serbest(oyuncu as Player):
		return false
	return not _ben._tekme_hedefi(oyuncu).is_empty()


## Düşen/atılan eşya: düğüm (görünüşü olduğu gibi) o an gövdeye döner, verilen hızla düşer, seker, yuvarlanır, durunca
## donar. Düğüm sonradan silinirse gövde de kalkar. tur boşsa ağdan tahmin edilir (silindir → fıçı, uzun → kalas,
## yoksa sandık). Başarılıysa true (çağıran tween'i kurmasın).
static func dusur(n: Node3D, tur := "", hiz := Vector3.ZERO, donus := Vector3.ZERO) -> bool:
	if n == null or not n.is_inside_tree():
		return false
	if _ben == null or not is_instance_valid(_ben):
		_ekle()
	if _ben == null or not is_instance_valid(_ben) or not _ben.is_inside_tree():
		return false
	return _ben._dusur(n, tur, hiz, donus)


static func ben() -> EsyaFizik:
	return _ben if _ben != null and is_instance_valid(_ben) else null


static func _anahtar(ad: String, p: Vector3) -> String:
	return "%s|%d|%d|%d" % [ad, roundi(p.x * 50.0), roundi(p.y * 50.0), roundi(p.z * 50.0)]


static func _kur() -> void:
	if (_ben != null and is_instance_valid(_ben)) or _kurulacak:
		return
	_kurulacak = true
	_ekle.call_deferred()


static func _ekle() -> void:
	_kurulacak = false
	if _ben != null and is_instance_valid(_ben):
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.current_scene == null:
		return
	var n := EsyaFizik.new()
	n.name = "EsyaFizik"
	_ben = n
	tree.current_scene.add_child(n)


# ======================================================================== düğüm

func _ready() -> void:
	process_physics_priority = 10      # oyuncudan sonra (hızı bu karede güncel)
	denetim_acik = GameState.autotest or OS.has_environment("ESYAAUDIT") or get_tree().current_scene.name.begins_with("Esya")
	get_tree().node_added.connect(_dugum_eklendi)


func _exit_tree() -> void:
	if _ben == self:
		_ben = null
	_bek_mm.clear()
	_bek_dugum.clear()
	_korunan.clear()
	if denetim_acik:
		print("ESYAAUDIT OZET kayit=%d uyanan=%d tekme=%d kosu=%d itme=%d patlama=%d destek=%d en_cok_uyanik=%d sorun=%d (dusme=%d havada=%d gomuk=%d tikama=%d sinir=%d)" % [
			sayac["kayit"], sayac["uyanan"], sayac["tekme"], sayac["kosu"], sayac["itme"], sayac["patlama"], sayac["destek"],
			olcum["en_cok_uyanik"], sorun(), sayac["dusme"], sayac["havada"], sayac["gomuk"], sayac["tikama"], sayac["sinir"]])


func sorun() -> int:
	return int(sayac["dusme"]) + int(sayac["havada"]) + int(sayac["gomuk"]) + int(sayac["tikama"]) + int(sayac["sinir"])


func _physics_process(delta: float) -> void:
	# kayıt bekleyen var: kısa aralıkla tara (kurulum karelere yayılabilir)
	_tara_t -= delta
	if _tara_t <= 0.0 and (_bek_sayi != _bek_mm.size() + _bek_dugum.size() or not _bek_dugum.is_empty()):
		_tara_t = 0.5
		_tara()
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Player
	if _player != null and _player.is_inside_tree():
		_oyuncu(delta)
	if not uyanik.is_empty():
		_uyaniklar(delta)


# ======================================================================== tarama: kayıtları eşyaya çevir

# Oynanış düğümleri (adlarında geçen): yanındaki eşya kayda geçmez, donan eşya üstlerinden kenara itilir
const KORU_AD := ["Merdiven", "Ladder", "Kopru", "Poterna", "Gedik", "Kapi", "Door", "Gate", "FicStack", "Pile", "Depo"]
var _koru_tarandi := false


func _koru_tara() -> void:
	_koru_tarandi = true
	var sc := get_tree().current_scene
	for ad in KORU_AD:
		for n in sc.find_children("*%s*" % ad, "Node3D", true, false):
			var p := (n as Node3D).global_position
			if absf(p.x) > 1.0e5:
				continue
			_korunan.append([p, 1.4])


func _tara() -> void:
	if not _koru_tarandi:
		_koru_tara()
	# tek düğümler
	var kalan: Array = []
	for b in _bek_dugum:
		var g: Node3D = b[0]
		if not is_instance_valid(g):
			continue
		if not g.is_inside_tree():
			kalan.append(b)
			continue
		_dugum_esya(g, b[1], b[2])
	_bek_dugum = kalan
	# Dressing MultiMesh örnekleri
	if not _bek_mm.is_empty():
		var adlar := {}
		for k in _bek_mm:
			adlar[String(k).get_slice("|", 0)] = true
		var parca_ag := {}       # Mesh -> [ad, parça sırası]
		for ad in adlar:
			var parts: Array = Kit.prop_parts(ad)
			for i in parts.size():
				parca_ag[parts[i][0]] = [ad, i]
		var gruplar := {}        # kök kimliği|ad -> {parça sırası: mmi}
		for n in get_tree().current_scene.find_children("*", "MultiMeshInstance3D", true, false):
			var mmi := n as MultiMeshInstance3D
			if _taranan.has(mmi.get_instance_id()) or mmi.multimesh == null or not parca_ag.has(mmi.multimesh.mesh):
				continue
			_taranan[mmi.get_instance_id()] = true
			var pa: Array = parca_ag[mmi.multimesh.mesh]
			var gk := "%d|%s" % [mmi.get_parent().get_instance_id(), pa[0]]
			if not gruplar.has(gk):
				gruplar[gk] = {}
			gruplar[gk][pa[1]] = mmi
		for gk in gruplar:
			var ad: String = String(gk).get_slice("|", 1)
			var parts: Array = Kit.prop_parts(ad)
			var g: Dictionary = gruplar[gk]
			if not g.has(0):
				continue
			var m0: MultiMeshInstance3D = g[0]
			var n0 := m0.multimesh.instance_count
			for i in n0:
				var x0: Transform3D = WorldWalk.inst_xf(m0, i) * (parts[0][1] as Transform3D).affine_inverse()
				var k := _anahtar(ad, x0.origin)
				if not _bek_mm.has(k):
					continue
				var mm: Array = []
				for pi in parts.size():
					if g.has(pi):
						mm.append([g[pi], i, parts[pi][1]])
				_mm_esya(ad, x0, m0.get_parent() as Node3D, mm, String(_bek_mm[k]))
	_bek_sayi = _bek_mm.size() + _bek_dugum.size()


func _mm_esya(ad: String, x_yerel: Transform3D, kok: Node3D, mm: Array, tur: String) -> void:
	var ab := AABB()
	var ilk := true
	for p in Kit.prop_parts(ad):
		var a: AABB = (p[1] as Transform3D) * (p[0] as Mesh).get_aabb()
		ab = a if ilk else ab.merge(a)
		ilk = false
	var xw := kok.global_transform * x_yerel
	var sc := xw.basis.get_scale()
	var e := _yeni(tur, Transform3D(xw.basis.orthonormalized(), xw.origin), AABB(ab.position * sc, ab.size * sc))
	e["kaynak"] = "mm"
	e["mm"] = mm
	e["kok"] = kok
	e["olcek"] = sc
	_yerlestir(e)


func _dugum_esya(g: Node3D, govde: StaticBody3D, tur: String) -> void:
	var mi := g as MeshInstance3D
	var ab := mi.mesh.get_aabb() if mi and mi.mesh else AABB(Vector3(-0.3, -0.45, -0.3), Vector3(0.6, 0.9, 0.6))
	var xw := g.global_transform
	var sc := xw.basis.get_scale()
	var e := _yeni(tur, Transform3D(xw.basis.orthonormalized(), xw.origin), AABB(ab.position * sc, ab.size * sc))
	e["kaynak"] = "dugum"
	e["dugum"] = g
	e["statik"] = govde
	_yerlestir(e)


func _yeni(tur: String, xf: Transform3D, ab: AABB) -> Dictionary:
	_sira += 1
	return {"id": _sira, "tur": tur, "xf": xf, "ab": ab, "durum": "uyur", "govde": null, "ilk_xf": xf,
		"zemin_y": (xf * ab.position).y, "t": 0.0, "dur_t": 0.0, "son_ses": 0.0}


func _yerlestir(e: Dictionary) -> void:
	var c := _merkez(e)
	for k in _korunan:
		if Vector2(c.x - (k[0] as Vector3).x, c.z - (k[0] as Vector3).z).length() < float(k[1]):
			return
	items.append(e)
	sayac["kayit"] += 1
	_izgaraya(e)


func _hucre(p: Vector3) -> Vector2i:
	return Vector2i(floori(p.x / HUCRE), floori(p.z / HUCRE))


func _izgaraya(e: Dictionary) -> void:
	var h := _hucre(_merkez(e))
	e["hucre"] = h
	if not _izgara.has(h):
		_izgara[h] = []
	_izgara[h].append(e)


func _izgaradan(e: Dictionary) -> void:
	var h: Vector2i = e.get("hucre", Vector2i.MAX)
	if _izgara.has(h):
		_izgara[h].erase(e)


func _yakin(p: Vector3, r: float) -> Array:
	var out: Array = []
	var a := _hucre(p - Vector3(r, 0, r))
	var b := _hucre(p + Vector3(r, 0, r))
	for x in range(a.x, b.x + 1):
		for z in range(a.y, b.y + 1):
			var h := Vector2i(x, z)
			if _izgara.has(h):
				out.append_array(_izgara[h])
	return out


## Eşyanın dünyadaki ağırlık merkezi (sınır kutusunun ortası)
func _merkez(e: Dictionary) -> Vector3:
	if e["govde"] != null and is_instance_valid(e["govde"]):
		return (e["govde"] as Node3D).global_position
	return (e["xf"] as Transform3D) * (e["ab"] as AABB).get_center()


func _yaricap(e: Dictionary) -> float:
	var s: Vector3 = (e["ab"] as AABB).size
	return maxf(s.x, s.z) * 0.5


# ======================================================================== oyuncu: tekme, koşarak çarpma, itme

func _oyuncu(delta: float) -> void:
	var p := _player
	# tekme: boş elle, serbest yürüyüşte, bakılan kişi/nesne yokken
	if Input.is_action_just_pressed("kick") and _tekme_serbest(p):
		var e := _tekme_hedefi(p)
		if not e.is_empty():
			sayac["tekme"] += 1
			var c := _merkez(e)
			p.kick(c, 0.75, func() -> void: pass)
	var v := Vector3(p.velocity.x, 0.0, p.velocity.z)
	var hiz := v.length()
	# Yön: gerçek hız; duvara (uyuyan eşyanın katısına) dayanınca hız sıfırlanır, o zaman oyuncunun bastığı yön.
	var yon := Vector3.ZERO
	if hiz >= 0.8:
		yon = v / hiz
	elif not p.frozen and p.move_mode == "walk":
		var inp := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var ist := p.global_transform.basis * Vector3(inp.x, 0.0, inp.y)
		ist.y = 0.0
		if ist.length() > 0.3:
			yon = ist.normalized()
	var carp := maxf(hiz, _son_hiz)        # çarpma anında move_and_slide hızı bu karede sıfırlamış olabilir
	_son_hiz = hiz
	if yon == Vector3.ZERO or p.frozen:
		_temas.clear()
		return
	var pp := p.global_position
	var dokunan := {}
	for e in _yakin(pp, 2.5):
		var c := _merkez(e)
		var d := Vector3(c.x - pp.x, 0.0, c.z - pp.z)
		var r := _yaricap(e)
		var bosluk := d.length() - r - 0.32
		if bosluk > 0.3 + carp * 0.06 or absf(c.y - (pp.y + 0.5)) > 1.2:
			continue
		if d.length() < 0.01 or d.normalized().dot(yon) < 0.5:
			continue
		var m: float = TUR[e["tur"]][0]
		if e["durum"] == "uyanik":
			# uyanık gövdeyi yürüyerek it: ağır eşya yavaş (kuvvet sınırlı)
			var g := e["govde"] as RigidBody3D
			var istenen := minf(maxf(hiz, 1.2), 2.6 * clampf(30.0 / m, 0.25, 1.0))
			var fark := istenen - g.linear_velocity.dot(yon)
			if fark > 0.0:
				g.apply_central_force(yon * minf(fark * m * 6.0, 520.0))
			continue
		if carp >= KOSU_HIZ:
			# koşarak çarpma: hafif eşya itilir, ağır eşya kıpırdar
			sayac["kosu"] += 1
			_uyandir(e)
			var j := minf(carp * 0.55 * m, 75.0)
			_itki(e, yon * j, Vector3(0, (e["ab"] as AABB).size.y * 0.2, 0))
			continue
		# yürüyerek dayanma: 0,35 sn dayanınca uyanır, sonra yukarıdaki kuvvetle yavaşça itilir
		if bosluk > 0.3:
			continue
		var t: float = _temas.get(e["id"], 0.0) + delta
		dokunan[e["id"]] = t
		if t >= 0.35:
			sayac["itme"] += 1
			_uyandir(e)
	_temas = dokunan


func _tekme_serbest(p: Player) -> bool:
	if p.frozen or p.move_mode != "walk" or p.focus_id != "" or p.hand_style != "tolga" or p.held != 0:
		return false
	if p.traversal and p.traversal.state != "":
		return false
	if p.leg == null or p.leg.visible:
		return false
	return p.is_on_floor()


func _tekme_hedefi(oyuncu: Node3D) -> Dictionary:
	var pp := oyuncu.global_position
	var fwd := -oyuncu.global_transform.basis.z
	fwd.y = 0.0
	if fwd.length() < 0.01:
		return {}
	fwd = fwd.normalized()
	var en: Dictionary = {}
	var en_d := INF
	for e in _yakin(pp, 2.5):
		if (e["ab"] as AABB).size.y > TEKME_BOY and e["durum"] == "uyur":
			continue
		var c := _merkez(e)
		if c.y - pp.y > 1.2 or pp.y - c.y > 0.9:
			continue
		var d := Vector3(c.x - pp.x, 0.0, c.z - pp.z)
		var kenar := d.length() - _yaricap(e)
		if kenar > TEKME_MENZIL or d.length() < 0.01:
			continue
		if d.normalized().dot(fwd) < 0.6:
			continue
		if not _ustu_bos(e):
			continue     # üstünde başka eşya duran (yığının altı) tekmelenmez: önce üsttekiler
		if kenar < en_d:
			en_d = kenar
			en = e
	return en


func _ustu_bos(e: Dictionary) -> bool:
	if e["durum"] != "uyur":
		return true
	var c := _merkez(e)
	var ust := c.y + (e["ab"] as AABB).size.y * 0.5
	var r := _yaricap(e)
	for o in _yakin(c, 1.0):
		if o == e or o["durum"] != "uyur":
			continue
		var oc := _merkez(o)
		var alt := oc.y - (o["ab"] as AABB).size.y * 0.5
		if absf(alt - ust) < 0.12 and Vector2(oc.x - c.x, oc.z - c.z).length() < r + _yaricap(o) * 0.6:
			return false
	return true


func _darbe(oyuncu: Node3D, hedef: Vector3, guc: float) -> void:
	var pp := oyuncu.global_position
	var e: Dictionary = {}
	var en_d := 1.3
	for o in _yakin(hedef, 1.5):
		var c := _merkez(o)
		var d := Vector2(c.x - hedef.x, c.z - hedef.z).length() - _yaricap(o)
		if d < en_d and absf(c.y - hedef.y) < 1.0:
			en_d = d
			e = o
	if OS.has_environment("ESYA_HATA"):
		print("ESYADBG darbe hedef=%s oyuncu=%s bulunan=%s" % [str(hedef), str(pp), str(e.get("id", -1))])
	if e.is_empty():
		return
	_uyandir(e)
	var g := e["govde"] as RigidBody3D
	if g == null:
		return
	var c := _merkez(e)
	var yon := Vector3(c.x - pp.x, 0.0, c.z - pp.z).normalized()
	var m: float = TUR[e["tur"]][0]
	var boy: float = (e["ab"] as AABB).size.y
	# Sert tekme itkisi ~55–80 N·s (bacak + gövde ağırlığıyla; hafif eşyada hız sınırı 7 m/s): 3 kg testi uçar, 45 kg
	# dolu fıçı karnından itilince devrilir (devrilme eşiği ≈ 40 J), sandık kayar ya da kenarından döner.
	var j := minf(lerpf(55.0, 80.0, guc), m * 7.0)
	var yuk := clampf(0.72 * boy, 0.2, 0.75)                  # ayak eşyanın karnına / üst yarısına değer
	_itki(e, yon * j + Vector3.UP * j * 0.12, -g.global_basis.y * boy * 0.5 + Vector3.UP * yuk - yon * _yaricap(e) * 0.9)
	_ses(e, 1.0)


func _patlama(p: Vector3, boy: float) -> void:
	var r := maxf(3.0, 4.5 * boy)
	for e in _yakin(p, r):
		var c := _merkez(e)
		var d := c - p
		var l := d.length()
		if l > r:
			continue
		sayac["patlama"] += 1
		_uyandir(e)
		var g := e["govde"] as RigidBody3D
		if g == null:
			continue
		var m: float = TUR[e["tur"]][0]
		var k := 1.0 - l / r
		var yon := (Vector3(d.x, 0.0, d.z).normalized() + Vector3.UP * 0.8).normalized()
		_itki(e, yon * minf(m * 6.0 * k * boy, m * 8.0), Vector3(randf_range(-0.1, 0.1), 0.15, randf_range(-0.1, 0.1)))


func _dugum_eklendi(n: Node) -> void:
	# Vfx.explosion'un ışığı (renk ffb050, güç 9): patlamanın yeri (Vfx'e dokunmadan; kanca isteği raporda)
	if n is OmniLight3D:
		var l := n as OmniLight3D
		if is_equal_approx(l.light_energy, 9.0) and l.light_color.is_equal_approx(Color("ffb050")):
			_patlama(l.global_position - Vector3(0, 1.0, 0), l.omni_range / 26.0)


# ======================================================================== düşen eşya

func _dusur(n: Node3D, tur: String, hiz: Vector3, donus: Vector3) -> bool:
	var ab := AABB()
	var ilk := true
	var silindir := false
	var inv := n.global_transform.affine_inverse()
	for c in n.find_children("*", "MeshInstance3D", true, false) + ([n] if n is MeshInstance3D else []):
		var mi := c as MeshInstance3D
		if mi.mesh == null or not mi.visible:
			continue
		if mi.mesh is CylinderMesh and (mi.mesh as CylinderMesh).height > 0.5:
			silindir = true
		var a := (inv * mi.global_transform) * mi.mesh.get_aabb()
		ab = a if ilk else ab.merge(a)
		ilk = false
	if ilk:
		return false
	if tur == "":
		var s := ab.size
		tur = "fici" if silindir else ("kalas" if maxf(s.x, s.z) > 2.2 * maxf(minf(s.x, s.z), s.y) else "sandik")
	var xf := n.global_transform
	var sc := xf.basis.get_scale()
	var e := _yeni(tur, Transform3D(xf.basis.orthonormalized(), xf.origin), AABB(ab.position * sc, ab.size * sc))
	e["kaynak"] = "dugum"
	e["dugum"] = n
	e["statik"] = null
	e["dusen"] = true
	# zemin: düşülen yerin altı (düşme denetimi buna göre)
	var c0 := (e["xf"] as Transform3D) * (e["ab"] as AABB).get_center()
	var q := PhysicsRayQueryParameters3D.create(c0, c0 + Vector3.DOWN * 40.0)
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	e["zemin_y"] = (hit["position"] as Vector3).y if not hit.is_empty() else c0.y - 2.0
	items.append(e)
	sayac["kayit"] += 1
	_izgaraya(e)
	_uyandir(e)
	var g := e["govde"] as RigidBody3D
	if g == null:
		return false
	g.linear_velocity = hiz
	g.angular_velocity = donus
	n.tree_exiting.connect(_dusen_silindi.bind(e), CONNECT_ONE_SHOT)
	sayac["dusen"] = int(sayac.get("dusen", 0)) + 1
	return true


func _dusen_silindi(e: Dictionary) -> void:
	# düşen eşyanın düğümü silindi (bölüm birkaç sn sonra kaldırır): gövde de kalkar
	uyanik.erase(e)
	_izgaradan(e)
	items.erase(e)
	var g = e.get("govde")
	if g != null and is_instance_valid(g):
		(g as Node).queue_free()
	e["govde"] = null


# ======================================================================== uyandırma

func _uyandir(e: Dictionary) -> void:
	if e["durum"] == "uyanik":
		return
	if e["durum"] == "donmus":
		var g0 := e["govde"] as RigidBody3D
		if g0 and is_instance_valid(g0):
			_sinir_kontrol()
			g0.freeze = false
			g0.sleeping = false
			e["durum"] = "uyanik"
			e["t"] = 0.0
			e["dur_t"] = 0.0
			uyanik.append(e)
			sayac["uyanan"] += 1
			olcum["en_cok_uyanik"] = maxi(olcum["en_cok_uyanik"], uyanik.size())
			return
	_sinir_kontrol()
	var t: Array = TUR[e["tur"]]
	var xf: Transform3D = e["xf"]
	var ab: AABB = e["ab"]
	var g := RigidBody3D.new()
	g.name = "Esya_%s_%d" % [e["tur"], e["id"]]
	g.mass = t[0]
	var pm := PhysicsMaterial.new()
	pm.friction = t[1]
	pm.bounce = t[2]
	g.physics_material_override = pm
	g.continuous_cd = true
	g.angular_damp = 0.12 if String(t[3]) in ["silindir", "kure"] else 0.6     # yuvarlak eşya yuvarlanmayı sürdürür
	g.linear_damp = 0.05
	g.can_sleep = true
	g.contact_monitor = true
	g.max_contacts_reported = 2
	g.set_meta("esya", true)
	var cs := CollisionShape3D.new()
	match String(t[3]):
		"silindir":
			# 16 kenarlı dışbükey silindir (GodotPhysics'in CylinderShape'i kutu üstünde titriyor, batıyordu)
			cs.shape = _silindir_sekli(maxf(ab.size.x, ab.size.z) * 0.5 * 0.94, ab.size.y)
		"kure":
			var s := SphereShape3D.new()
			s.radius = maxf(ab.size.x, maxf(ab.size.y, ab.size.z)) * 0.5
			cs.shape = s
		_:
			var s := BoxShape3D.new()
			s.size = ab.size * Vector3(0.97, 1.0, 0.97)
			cs.shape = s
	g.add_child(cs)
	var gxf := Transform3D(xf.basis, xf * ab.get_center())
	add_child(g)
	g.global_transform = gxf
	# görünüş: kaynağın aynısı gövdeye taşınır
	if e["kaynak"] == "mm":
		var kok: Node3D = e["kok"]
		for m in e["mm"]:
			var mmi: MultiMeshInstance3D = m[0]
			var i: int = m[1]
			var dunya: Transform3D = kok.global_transform * WorldWalk.inst_xf(mmi, i)
			var mi := MeshInstance3D.new()
			mi.mesh = mmi.multimesh.mesh
			mi.cast_shadow = mmi.cast_shadow
			g.add_child(mi)
			mi.global_transform = dunya
			WorldWalk.hide_inst(mmi, i)
		_ortak_kati_ayir(e)
	else:
		var d: Node3D = e["dugum"]
		var st: StaticBody3D = e.get("statik")
		if st and is_instance_valid(st):
			for c in st.get_children():
				if c is CollisionShape3D:
					(c as CollisionShape3D).disabled = true
		if is_instance_valid(d):
			var dx := d.global_transform
			d.get_parent().remove_child(d)
			g.add_child(d)
			d.global_transform = dx
	g.body_entered.connect(_carpti.bind(e))
	e["govde"] = g
	e["kare"] = 0
	e["durum"] = "uyanik"
	e["t"] = 0.0
	e["dur_t"] = 0.0
	uyanik.append(e)
	sayac["uyanan"] += 1
	olcum["en_cok_uyanik"] = maxi(olcum["en_cok_uyanik"], uyanik.size())
	# üstündeki eşyalar desteksiz kaldı: onlar da uyanır (havada durmasın)
	var ust := (xf * ab.get_center()).y + ab.size.y * 0.5
	var c0 := xf * ab.get_center()
	for o in _yakin(c0, 1.2):
		if o["durum"] != "uyur":
			continue
		var oc := _merkez(o)
		var alt := oc.y - (o["ab"] as AABB).size.y * 0.5
		if absf(alt - ust) < 0.15 and Vector2(oc.x - c0.x, oc.z - c0.z).length() < _yaricap(e) + _yaricap(o) * 0.8:
			sayac["destek"] += 1
			_uyandir.call_deferred(o)


## Dressing yığınlarının ortak çarpışma kutusu (crates/barrels: grubun kaplamı): uyanan eşyayla kesişen kutular kapanır,
## grupta uyumaya devam eden eşyalara kendi kutuları verilir (ne görünmez duvar kalsın ne de uyuyanın içinden geçilsin).
func _ortak_kati_ayir(e: Dictionary) -> void:
	var kok: Node3D = e["kok"]
	var ab_d := _dunya_ab(e)
	for st in kok.get_children():
		if not st is StaticBody3D:
			continue
		var kapanan: Array = []
		for c in st.get_children():
			var cs := c as CollisionShape3D
			if cs == null or cs.disabled or not cs.shape is BoxShape3D or cs.has_meta("esya_kendi"):
				continue
			var cab := (st as Node3D).global_transform * cs.transform * AABB(-(cs.shape as BoxShape3D).size * 0.5, (cs.shape as BoxShape3D).size)
			if cab.grow(-0.02).intersects(ab_d):
				cs.disabled = true
				kapanan.append(cab)
		if kapanan.is_empty():
			continue
		for o in items:
			if o == e or o["durum"] != "uyur" or o.get("kok") != kok or o.get("kendi_kati") != null:
				continue
			var oab := _dunya_ab(o)
			for cab in kapanan:
				if (cab as AABB).grow(0.05).intersects(oab):
					var cs2 := CollisionShape3D.new()
					var bs := BoxShape3D.new()
					var ab: AABB = o["ab"]
					var r := "silindir" == String(TUR[o["tur"]][3])
					bs.size = ab.size * (Vector3(0.85, 1.0, 0.85) if r else Vector3(0.95, 1.0, 0.95))
					cs2.shape = bs
					cs2.set_meta("esya_kendi", true)
					st.add_child(cs2)
					cs2.global_transform = Transform3D((o["xf"] as Transform3D).basis, (o["xf"] as Transform3D) * ab.get_center())
					o["kendi_kati"] = cs2
					break
	# kendisine verilmiş kutu varsa o da kapanır
	var kk = e.get("kendi_kati")
	if kk != null and is_instance_valid(kk):
		(kk as CollisionShape3D).disabled = true
		e["kendi_kati"] = null


## İtki: yeni kurulan gövdenin kütlesi fizik sunucusunda bir adım sonra işlenir (GodotPhysics kütle özelliklerini
## adımda günceller; o ana kadar ters kütle 1). Bu yüzden ilk karede gelen itki bir kare bekletilir.
func _itki(e: Dictionary, j: Vector3, nokta := Vector3.ZERO) -> void:
	var g := e["govde"] as RigidBody3D
	if g == null:
		return
	if int(e.get("kare", 99)) < 2:
		e["bekleyen"] = (e.get("bekleyen", []) as Array) + [[j, nokta]]
		return
	g.apply_impulse(j, nokta)


func _dunya_ab(e: Dictionary) -> AABB:
	return (e["xf"] as Transform3D) * (e["ab"] as AABB)


func _sinir_kontrol() -> void:
	while uyanik.size() >= AZAMI_UYANIK:
		var en_eski: Dictionary = uyanik[0]
		_dondur(en_eski, true)


func _carpti(diger: Node, e: Dictionary) -> void:
	var g := e["govde"] as RigidBody3D
	if g == null:
		return
	var v := g.linear_velocity.length()
	var simdi := Time.get_ticks_msec() / 1000.0
	if v > 1.2 and simdi - float(e["son_ses"]) > 0.25:
		e["son_ses"] = simdi
		_ses(e, clampf(v / 5.0, 0.2, 1.0))
	if diger is CharacterBody3D and not diger.is_in_group("player"):
		pass    # kişi: yalnız kendi çarpışmasından seker (yığılma sistemine bağlanmaz)


func _ses(e: Dictionary, guc: float) -> void:
	var g := e["govde"] as Node3D
	if g == null or not is_instance_valid(g):
		return
	var ad: String = TUR[e["tur"]][4]
	if ad == "footstep_wood":
		ad = "footstep_wood_%d" % randi_range(1, 4)
	Audio.sfx_at(ad, g, lerpf(-16.0, -4.0, guc))


# ======================================================================== uyanık gövdeler: izleme, donma, denetim

func _uyaniklar(delta: float) -> void:
	for e in uyanik.duplicate():
		var g := e["govde"] as RigidBody3D
		if g == null or not is_instance_valid(g):
			uyanik.erase(e)
			continue
		e["kare"] = int(e.get("kare", 99)) + 1
		if int(e["kare"]) >= 2 and e.has("bekleyen"):
			for b in e["bekleyen"]:
				g.apply_impulse(b[0], b[1])
			e.erase("bekleyen")
		e["t"] = float(e["t"]) + delta
		var c := g.global_position
		# zemin altına düştü (başlangıç zemininin 2 m altında VE altında zemin yok ya da üstünde zemin var): ilk yerine.
		# Yokuştan, merdivenden yuvarlanıp inen meşrudur: altında zemin, üstünde boşluk vardır.
		if c.y < float(e["zemin_y"]) - DUSME_PAYI and int(e["kare"]) % 6 == 0 and _zemin_alti(g):
			sayac["dusme"] += 1
			_rapor("dusme", e, c)
			_ilk_yere(e)
			continue
		var lv := g.linear_velocity.length()
		var av := g.angular_velocity.length()
		if g.sleeping or (lv < DUR_LIN and av < DUR_ACI):
			e["dur_t"] = float(e["dur_t"]) + delta
		else:
			e["dur_t"] = 0.0
		if float(e["dur_t"]) >= DUR_SURE or (g.sleeping and float(e["t"]) > 0.3):
			_dondur(e, false)
		elif float(e["t"]) > AZAMI_SURE:
			_dondur(e, true)


static var _sil_sekil := {}


static func _silindir_sekli(r: float, h: float) -> ConvexPolygonShape3D:
	var k := "%.3f|%.3f" % [r, h]
	if _sil_sekil.has(k):
		return _sil_sekil[k]
	var pts := PackedVector3Array()
	for i in 16:
		var a := TAU * i / 16.0
		for y: float in [-h * 0.5, h * 0.5]:
			pts.append(Vector3(cos(a) * r, y, sin(a) * r))
	var s := ConvexPolygonShape3D.new()
	s.points = pts
	_sil_sekil[k] = s
	return s


func _zemin_alti(g: RigidBody3D) -> bool:
	var space := g.get_world_3d().direct_space_state
	var c := g.global_position
	var q := PhysicsRayQueryParameters3D.create(c, c + Vector3.DOWN * 60.0)
	q.exclude = [g.get_rid()]
	if space.intersect_ray(q).is_empty():
		return true
	var u := PhysicsRayQueryParameters3D.create(c, c + Vector3.UP * 4.0)
	u.exclude = [g.get_rid()]
	u.hit_back_faces = true
	var h := space.intersect_ray(u)
	return not h.is_empty() and not (h["collider"] as Node).has_meta("esya")


## Gövdeyi durdurur: önce zemine oturduğu (havada değil, gömük değil, yol tıkamıyor) denetlenir, sonra donar.
func _dondur(e: Dictionary, zorla: bool) -> void:
	var g := e["govde"] as RigidBody3D
	uyanik.erase(e)
	if g == null or not is_instance_valid(g):
		return
	if zorla and uyanik.size() + 1 >= AZAMI_UYANIK and float(e["t"]) < AZAMI_SURE:
		pass   # sınır: en eskisi oturtuluyor (sorun değil, ölçülür)
	var bosluk := _zemin_boslugu(g)
	if bosluk > 0.06:
		if not zorla:
			# henüz oturmadı (bir kenara yaslı ya da dengede): biraz daha simüle et
			uyanik.append(e)
			e["dur_t"] = 0.0
			g.sleeping = false
			g.apply_central_impulse(Vector3.DOWN * 0.01)
			return
		if bosluk < 50.0:
			g.global_position -= Vector3(0, bosluk, 0)
		else:
			sayac["havada"] += 1
			_rapor("havada", e, g.global_position)
			_ilk_yere(e)
			return
	if _gomuk(g):
		sayac["gomuk"] += 1
		_rapor("gomuk", e, g.global_position)
		_ilk_yere(e)
		return
	_yol_temizle(e)
	g.linear_velocity = Vector3.ZERO
	g.angular_velocity = Vector3.ZERO
	g.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	g.freeze = true
	g.contact_monitor = false
	e["durum"] = "donmus"
	# ızgarada yeni yerine
	_izgaradan(e)
	_izgaraya(e)
	g.contact_monitor = true


## Gövdenin en alt noktasının altındaki zemine uzaklığı (m). Zemin bulunamazsa 99.
func _zemin_boslugu(g: RigidBody3D) -> float:
	var cs := g.get_child(0) as CollisionShape3D
	var alt := _alt_nokta(g, cs)
	var space := g.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(Vector3(g.global_position.x, alt + 0.4, g.global_position.z), Vector3(g.global_position.x, alt - 60.0, g.global_position.z))
	q.exclude = [g.get_rid()]
	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return 99.0
	var y: float = (hit["position"] as Vector3).y
	# eğik duran gövdede merkezin altı alt noktadan yüksek olabilir: alt noktanın kendisinde de dene
	return maxf(0.0, alt - y) if absf(alt - y) < 0.4 or alt > y else 0.0


func _alt_nokta(g: RigidBody3D, cs: CollisionShape3D) -> float:
	var b := g.global_basis
	var s := cs.shape
	if s is BoxShape3D:
		var h := (s as BoxShape3D).size * 0.5
		var en := INF
		for x in [-1, 1]:
			for y in [-1, 1]:
				for z in [-1, 1]:
					en = minf(en, (g.global_position + b * Vector3(h.x * x, h.y * y, h.z * z)).y)
		return en
	if s is CylinderShape3D:
		var cy := s as CylinderShape3D
		var ax := b.y.normalized()
		var dik := sqrt(maxf(0.0, 1.0 - ax.y * ax.y))
		return g.global_position.y - absf(ax.y) * cy.height * 0.5 - dik * cy.radius
	if s is SphereShape3D:
		return g.global_position.y - (s as SphereShape3D).radius
	if s is ConvexPolygonShape3D:
		var en := INF
		var xf := g.global_transform * cs.transform
		for p in (s as ConvexPolygonShape3D).points:
			en = minf(en, (xf * p).y)
		return en
	return g.global_position.y


## Gövde durağan dünyanın içine gömük mü (kendi şeklinin %70'i küçültülmüşü durağan bir şeyle kesişiyor)
func _gomuk(g: RigidBody3D) -> bool:
	var cs := g.get_child(0) as CollisionShape3D
	var s: Shape3D = cs.shape.duplicate()
	if s is BoxShape3D:
		(s as BoxShape3D).size *= 0.6
	elif s is CylinderShape3D:
		(s as CylinderShape3D).radius *= 0.6
		(s as CylinderShape3D).height *= 0.6
	elif s is SphereShape3D:
		(s as SphereShape3D).radius *= 0.6
	elif s is ConvexPolygonShape3D:
		var pts := PackedVector3Array()
		for p in (s as ConvexPolygonShape3D).points:
			pts.append(p * 0.6)
		(s as ConvexPolygonShape3D).points = pts
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = s
	q.transform = g.global_transform
	q.exclude = [g.get_rid()]
	q.collide_with_areas = false
	for r in g.get_world_3d().direct_space_state.intersect_shape(q, 4):
		var o: Object = r["collider"]
		if o is StaticBody3D and not (o as Node).has_meta("esya"):
			return true
	return false


## Donan gövde korunan noktanın (kapı, merdiven ağzı, görev yeri) ya da dar geçidin (sur yolu, sokak arası) üstündeyse
## kenara itilir: geçidin yakın duvarına yaslanır.
func _yol_temizle(e: Dictionary) -> void:
	var g := e["govde"] as RigidBody3D
	var c := g.global_position
	var r := _yaricap(e)
	for k in _korunan:
		var kp: Vector3 = k[0]
		var d := Vector2(c.x - kp.x, c.z - kp.z)
		if d.length() < float(k[1]) + r and absf(c.y - kp.y) < 2.5:
			sayac["tikama"] += 1
			_rapor("tikama_nokta", e, c)
			var dis := Vector3(d.x, 0.0, d.y).normalized() if d.length() > 0.01 else Vector3.RIGHT
			g.global_position = Vector3(kp.x, c.y, kp.z) + dis * (float(k[1]) + r + 0.1)
			g.global_position -= Vector3(0, minf(_zemin_boslugu(g), 2.0), 0)
			return
	# dar geçit: iki yatay eksende yan duvarlar arası
	var space := g.get_world_3d().direct_space_state
	var y := c.y
	for ax in [Vector3.RIGHT, Vector3.BACK]:
		var a := _duvar(space, g, Vector3(c.x, y, c.z), ax, 2.5)
		var b := _duvar(space, g, Vector3(c.x, y, c.z), -ax, 2.5)
		if a + b < 2.6:
			# geçidin genişliği < 2,6 m: eşya ortadaysa (iki yanda da oyuncu kapsülü + pay kadar yer yoksa) kenara it
			var bos := maxf(a, b) - r
			if minf(a, b) - r > 0.12 and bos < 0.85:
				sayac["tikama"] += 1
				_rapor("tikama_gecit", e, c)
			var yan: Vector3 = ax if a < b else -ax
			var ne := minf(a, b) - r - 0.03
			if ne > 0.05:
				g.global_position += yan * ne
			return


func _duvar(space: PhysicsDirectSpaceState3D, g: RigidBody3D, p: Vector3, ax: Vector3, l: float) -> float:
	var q := PhysicsRayQueryParameters3D.create(p, p + ax * l)
	q.exclude = [g.get_rid()]
	var hit := space.intersect_ray(q)
	return (p.distance_to(hit["position"])) if not hit.is_empty() else l


func _ilk_yere(e: Dictionary) -> void:
	var g := e["govde"] as RigidBody3D
	uyanik.erase(e)
	var xf: Transform3D = e["ilk_xf"]
	var ab: AABB = e["ab"]
	g.linear_velocity = Vector3.ZERO
	g.angular_velocity = Vector3.ZERO
	g.global_transform = Transform3D(xf.basis, xf * ab.get_center())
	g.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	g.freeze = true
	e["durum"] = "donmus"
	_izgaradan(e)
	_izgaraya(e)


func _rapor(ne: String, e: Dictionary, p: Vector3) -> void:
	if denetim_acik:
		print("ESYAAUDIT %s tur=%s id=%d at=(%.1f,%.1f,%.1f) zemin=%.2f" % [ne, e["tur"], e["id"], p.x, p.y, p.z, e["zemin_y"]])
