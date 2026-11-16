extends Node
## YIĞILMA (fizik): ölen, vurulan, itilen, düşen kişi tahta gibi devrilmez, bez bebek gibi yere yığılır.
## Verlet bez bebek (Jakobsen 2001, "Advanced Character Physics"; Müller vd. 2006 "Position Based Dynamics"):
## 13 parçacık (iki kalça, iki omuz, baş, dizler, ayak bilekleri, dirsekler, eller), çubuk kısıtlarıyla bağlı. Gövde
## (kalçalar + omuzlar + baş) altı çubukla katı; uzuvlar kemik boyunda çubuk, diz ve dirsek bükülme sınırı (kalça-ayak,
## omuz-el uzaklığı aralığı), diz yalnız öne bükülür (menteşe), uyluk koni içinde (kalça eklemi sınırı). Ağırlık gövdede.
## Çarpışma: GÖRÜNEN zeminin yükseklik ızgarası (0,2 m hücre, gerekince ışınla doldurulur; Unclip.standable ölçüsü) +
## gövdenin iki küresi (göğüs, karın). Zemine değen parçacık sürtünmeyle durur; hücrenin zemini parçacığın altından
## 28 cm'den yüksekse duvardır (yatayda geçilmez), ayağın altı birden 60 cm'den çok iniyorsa kenardır (düşüş dışında
## geçilmez: ceset sur yolunun, molozun kenarında kalır). Düşüşte (kenardan atılan, merdivenden düşen) kenar serbest.
## Uykuya geçince (ya da en çok `sure` sn sonra) tam ölçülü son oturtma (her parçacığın altına bir ışın) ve DONMA:
## işlem durur, düğümler o duruşta kalır (bütçe). Aynı anda en çok AZAMI kişi; fazlası en eskiyi hemen dondurur.
## Görüntü: gövde düğümü katı gövdenin dönüşümüyle, kol/bacak eklemleri uzuv yönleriyle (LimbAnim._limb ile aynı
## kurgu) yazılır; Rig.lock tutulur (Rig ve LimbAnim yazmaz). Kalkacak olan (tekmeyle yere serilen) `devret` ile LimbAnim'e
## geri verilir: klip yerdeki duruştan harmanlanarak başlar.
##   var y := Yigilma.baslat(kisi, {"itme": Vector3, "h": 1.3, "v0": Vector3, "dusus": false, "sure": 2.0})
##   y.bitti.connect(...)   # dondu (ceset: kan, sayaç)  ·  y.carpti.connect(func(at, hiz): ...)  # ilk yere çarpış
## Kapatma (ÖNCE ölçümü): `--yigilma=0` (eski klip yolu).

const PATH := "res://scripts/npc/yigilma.gd"
static var etkin := not (OS.get_cmdline_user_args().has("--yigilma=0") or OS.get_cmdline_args().has("--yigilma=0"))
static var _aktif: Array = []
const AZAMI := 8
const DT := 1.0 / 30.0
const ADIM_AZAMI := 2
const YINELE := 4
const HUCRE := 0.25
## Kare başına en çok bu kadar yeni zemin ışını (bütün yığılanlar için); bilinmeyen hücrede parçacığın son zemini
const ISIN_KARE := 14
static var _isin_kare := -1
static var _isin_kalan := 0
const YERCEKIMI := 13.0
const DUVAR := 0.28
const KENAR := 0.6

# Parçacıklar
const HL := 0
const HR := 1
const SL := 2
const SR := 3
const BAS := 4
const DZL := 5
const AYL := 6
const DZR := 7
const AYR := 8
const DSL := 9
const ELL := 10
const DSR := 11
const ELR := 12
const N := 13
const YARICAP := [0.09, 0.09, 0.1, 0.1, 0.2, 0.08, 0.07, 0.08, 0.07, 0.06, 0.05, 0.06, 0.05]
const KUTLE := [3.0, 3.0, 3.0, 3.0, 1.5, 1.2, 0.8, 1.2, 0.8, 0.6, 0.4, 0.6, 0.4]
## Gövde küreleri (göğüs, karın): omuz ortasından kalça ortasına oranı ve yarıçap
const KURE := [[0.21, 0.2], [0.855, 0.2]]

signal bitti
signal carpti(at: Vector3, hiz: float)

var kisi: Node3D
var rig: Rig
var p := PackedVector3Array()
var o := PackedVector3Array()
var w := PackedFloat32Array()
var gz := PackedFloat32Array()      # parçacığın son zemini (kenar kuralı)
var _ca := PackedInt32Array()
var _cb := PackedInt32Array()
var _cmin := PackedFloat32Array()
var _cmax := PackedFloat32Array()
var _cmin2 := PackedFloat32Array()
var _cmax2 := PackedFloat32Array()
var _L := PackedFloat32Array([0, 0, 0, 0])   # uyluk, baldır, pazu, önkol
var _gi := PackedFloat32Array()     # bu adımın zemini (parçacık başına)
var _gk := PackedFloat32Array([0, 0])
var _temas := PackedByteArray()
var t := 0.0
var _acc := 0.0
var _uyku := 0
var dusus := false
var sure := 2.0
var kalk := false
var dondu := false
var _carpti := false
var _yc := 0.0
var _derin := 3.0
var _izgara := {}
var _haric: Array[RID] = []
var _her_kati := false
var _anim: Node                    # durdurulan LimbAnim (devret/birak'ta geri)
var _kilit := false
var _govde_dinlen := Transform3D.IDENTITY
var _bas_dinlen := Vector3.ZERO
var _bas_konum := Vector3.ZERO
var _kalca_yerel := Vector3.ZERO     # gövde düğümünde kalça ortası
var _govde_olcek := Vector3.ONE
var _bas_yerel_yon := Vector3.UP
var _cirpin := Vector3.ZERO
var _cirpin_t := 0.0
var _rng := RandomNumberGenerator.new()
var _bas_egim := Vector3.ZERO
var son_govde := Transform3D.IDENTITY
## Düşüşün havadaki evresi: gövde kökü (düellocu, merdivendeki asker) izler: kökün yolu (duvar, korkuluk, su) kökün
## kendi ışınlarıyla çözülür; bez bebek yalnız kökün çevresinde çırpınır ve döner. Kök yere inince (ya da indi())
## yerçekimli, zeminli evre başlar.
var kok: Node3D
var _havada := false
var _kok_son := Vector3.ZERO
var _kok_v := Vector3.ZERO
var _kok_dustu := false
var _g := YERCEKIMI
var olcum_us := 0                  # bu örneğin toplam işlem süresi (µs)
static var toplam_us := 0          # bütün örneklerin (YIGILMAPERF)
static var toplam_n := 0
## Ölçüm (`--yig-olc`): 10 sn'de bir YIGPERF satırı: kare başı işlem süresi, yığılma µs, aynı anda yığılan, en kalabalık kare
static var olc_acik := OS.get_cmdline_user_args().has("--yig-olc")
static var _olc := {"kare": 0, "proc": 0.0, "us": 0, "akt": 0, "t0": 0, "en_n": 0, "en_us": 0, "en_proc": 0.0, "en_pay": 0.0}
static var _olc_frame := -1
static var _olc_son := 0


static func olc_tick() -> void:
	var f := Engine.get_process_frames()
	if f == _olc_frame:
		return
	_olc_frame = f
	var us := toplam_us - _olc_son
	_olc_son = toplam_us
	var proc := Performance.get_monitor(Performance.TIME_PROCESS)
	_olc["kare"] += 1
	_olc["proc"] += proc
	_olc["us"] += us
	var n := _aktif.size()
	_olc["akt"] += n
	if n > int(_olc["en_n"]) or (n == int(_olc["en_n"]) and n > 0 and us > int(_olc["en_us"])):
		_olc["en_n"] = n
		_olc["en_us"] = us
		_olc["en_proc"] = proc
	if proc > 0.0:
		_olc["en_pay"] = maxf(float(_olc["en_pay"]), us / (proc * 1e6))
	var now := Time.get_ticks_msec()
	if _olc["t0"] == 0:
		_olc["t0"] = now
	if now - int(_olc["t0"]) >= 10000:
		var k := maxf(1.0, float(_olc["kare"]))
		print("YIGISIN n=%d us=%d" % [isin_n, isin_us])
		isin_n = 0
		isin_us = 0
		print("YIGPERF kare=%d proc_ms=%.3f yig_us=%.1f aktif=%.2f en_aktif=%d en_us=%d en_proc_ms=%.2f en_pay=%.4f etkin=%s" % [
			_olc["kare"], float(_olc["proc"]) * 1000.0 / k, float(_olc["us"]) / k, float(_olc["akt"]) / k, _olc["en_n"],
			_olc["en_us"], float(_olc["en_proc"]) * 1000.0, _olc["en_pay"], str(etkin)])
		_olc = {"kare": 0, "proc": 0.0, "us": 0, "akt": 0, "t0": now, "en_n": 0, "en_us": 0, "en_proc": 0.0, "en_pay": 0.0}


static func of(ch: Node) -> Node:
	if ch == null or not ch.has_meta("yigilma"):
		return null
	var y = ch.get_meta("yigilma")
	return y if is_instance_valid(y) else null


## Kişiyi (Person, Soldier, Hikmet: Rig'li) bez bebeğe çevirir. Döner: örnek (null: iskeleti yok / kapalı).
## sec: itme (m/sn, darbe yönü × güç), h (darbenin yüksekliği, ayaktan m: 1.3 göğüs, 0.9 kalça, 1.6 baş), v0 (bütün
## gövdenin hızı), dusus (kenardan/merdivenden düşüş: kenar serbest, çırpınma), sure (en çok sn), kalk (donunca
## kilit kalır, devret ile kalkar), haric (ışının atlayacağı gövdeler), diz (dizlerin çözülmesi 0..1), donus (rad/sn,
## gövde ekseni çevresinde: patlama).
static func baslat(ch: Node3D, sec := {}) -> Node:
	if not etkin or ch == null or not ch.is_inside_tree():
		return null
	var rg = ch.get("rig")
	if not (rg is Rig) or (rg as Rig).body == null or (rg as Rig).leg_l == null or (rg as Rig).leg_r == null \
			or (rg as Rig).knee_l == null or (rg as Rig).knee_r == null or (rg as Rig).arm_l == null or (rg as Rig).arm_r == null \
			or (rg as Rig).elbow_l == null or (rg as Rig).elbow_r == null or (rg as Rig).head == null:
		return null
	var eski := of(ch)
	if eski:
		eski.call("birak", false)
	var y: Node = (load(PATH) as GDScript).new()
	y.name = "Yigilma"
	ch.add_child(y)
	y.call("_kur", ch, rg, sec)
	return y


func _kur(ch: Node3D, rg: Rig, sec: Dictionary) -> void:
	kisi = ch
	rig = rg
	_rng.seed = ch.get_instance_id()
	dusus = bool(sec.get("dusus", false))
	sure = float(sec.get("sure", 3.2 if dusus else 2.0))
	kalk = bool(sec.get("kalk", false))
	kok = sec.get("kok", null)
	_g = float(sec.get("g", YERCEKIMI))
	_havada = dusus and kok != null
	if kok:
		_kok_son = kok.global_position
		_kok_v = sec.get("v0", Vector3.ZERO)
	for r in sec.get("haric", []):
		_haric.append(r)
	ch.set_meta("yigilma", self)
	rig.lock += 1
	_kilit = true
	# LimbAnim (düellocu) yazmasın
	for c in ch.get_children():
		if c is LimbAnim and (c as Node).is_processing():
			_anim = c
			(c as Node).set_process(false)
	if ch is Soldier:
		(ch as Soldier).pose = "stand"
	_her_kati = false
	var q: Node = ch.get_parent()
	while q != null:
		if q.has_meta("dusus_her_kati"):
			_her_kati = bool(q.get_meta("dusus_her_kati"))
			break
		q = q.get_parent()
	var b := rig.body
	_govde_dinlen = b.transform
	_bas_dinlen = rig.head.rotation
	_bas_konum = rig.head.position
	_kalca_yerel = (rig.leg_l.position + rig.leg_r.position) * 0.5
	_govde_olcek = b.global_basis.get_scale()
	var omuz_yerel := (rig.arm_l.position + rig.arm_r.position) * 0.5
	_bas_yerel_yon = (rig.head.position - omuz_yerel).normalized()
	# Başlangıç duruşu: eklemlerin dünyadaki yerleri
	p.resize(N)
	o.resize(N)
	w.resize(N)
	gz.resize(N)
	_gi.resize(N)
	_temas.resize(N)
	p[HL] = rig.leg_l.global_position
	p[HR] = rig.leg_r.global_position
	p[SL] = rig.arm_l.global_position
	p[SR] = rig.arm_r.global_position
	p[BAS] = rig.head.global_position
	p[DZL] = rig.knee_l.global_position
	p[DZR] = rig.knee_r.global_position
	p[AYL] = CharKit.ankle_of(rig.knee_l).global_position
	p[AYR] = CharKit.ankle_of(rig.knee_r).global_position
	p[DSL] = rig.elbow_l.global_position
	p[DSR] = rig.elbow_r.global_position
	p[ELL] = rig.elbow_l.global_transform * (rig.elbow_l.get_meta("hand", Vector3(0, -0.27, 0.01)) as Vector3)
	p[ELR] = rig.elbow_r.global_transform * (rig.elbow_r.get_meta("hand", Vector3(0, -0.27, 0.01)) as Vector3)
	for i in N:
		w[i] = 1.0 / float(KUTLE[i])
	# Kısıtlar (dinlenme boyları başlangıç duruşundan: kemikler katı)
	var kat := [HL, HR, SL, SR]
	for i in kat.size():
		for j in range(i + 1, kat.size()):
			_cubuk(kat[i], kat[j])
	# Boyun: baş omuzlara ve kalçalara aralıklı bağlı (öne/yana sarkar, gövdenin içine girmez)
	for i in [SL, SR]:
		var d0 := (p[BAS] - p[i]).length()
		_aralik(BAS, i, d0 * 0.86, d0 * 1.02)
	for i in [HL, HR]:
		var d1 := (p[BAS] - p[i]).length()
		_aralik(BAS, i, d1 * 0.86, d1 * 1.0)
	_L[0] = (p[DZL] - p[HL]).length()
	_L[1] = (p[AYL] - p[DZL]).length()
	_L[2] = (p[DSL] - p[SL]).length()
	_L[3] = (p[ELL] - p[DSL]).length()
	for ab: Array in [[HL, DZL], [DZL, AYL], [HR, DZR], [DZR, AYR], [SL, DSL], [DSL, ELL], [SR, DSR], [DSR, ELR]]:
		_cubuk(ab[0], ab[1])
	var bacak := _L[0] + _L[1]
	var kol := _L[2] + _L[3]
	_aralik(HL, AYL, bacak * 0.42, bacak)
	_aralik(HR, AYR, bacak * 0.42, bacak)
	_aralik(SL, ELL, kol * 0.3, kol)
	_aralik(SR, ELR, kol * 0.3, kol)
	_aralik(AYL, AYR, 0.14, 99.0)
	_aralik(DZL, DZR, 0.13, 99.0)
	_aralik(ELL, BAS, 0.24, 99.0)
	_aralik(ELR, BAS, 0.24, 99.0)
	# Hızlar: gövdenin hızı + darbe (yüksekliğe göre dağılır) + dizlerin çözülmesi
	var v0: Vector3 = sec.get("v0", Vector3.ZERO)
	var itme: Vector3 = sec.get("itme", Vector3.ZERO)
	var h: float = sec.get("h", 1.2)
	var diz: float = sec.get("diz", 1.0)
	var ayak_y := minf(p[AYL].y, p[AYR].y)
	var cerceve := _cerceve()
	var on: Vector3 = cerceve[2]
	var yan: Vector3 = cerceve[0]
	var donus: float = sec.get("donus", 0.0)
	var merkez := (p[HL] + p[HR] + p[SL] + p[SR]) * 0.25
	for i in N:
		var yy := p[i].y - ayak_y
		var k := clampf(1.0 - absf(yy - h) / 1.3, 0.12, 1.0)
		var v := (v0 if not _havada else Vector3.ZERO) + itme * k
		if absf(donus) > 0.0:
			v += yan.cross(p[i] - merkez) * donus
		o[i] = p[i] - v * DT
	# Dizler öne çözülür, kalça çöker (gevşeyen kaslar: tahta gibi devrilmesin)
	if diz > 0.0 and not dusus:
		for i in [DZL, DZR]:
			o[i] -= (on * 1.8 + Vector3(0, -0.8, 0)) * diz * DT
		for i in [HL, HR]:
			o[i] -= Vector3(0, -1.6, 0) * diz * DT
		for i in [AYL, AYR]:
			o[i] -= (-on * 0.25) * diz * DT
	# Zemin ızgarası: başlangıçtaki en yüksek noktanın üstünden aşağı
	var tepe := -INF
	for i in N:
		tepe = maxf(tepe, p[i].y)
	_yc = tepe + 0.3
	_derin = 24.0 if dusus else 4.0
	var kok_y := ch.global_position.y
	for i in N:
		gz[i] = kok_y
	_aktif.append(self)
	while _aktif.size() > AZAMI:
		var en_eski = _aktif[0]
		if is_instance_valid(en_eski) and en_eski != self:
			en_eski.call("_bitir")
		else:
			_aktif.pop_front()
	_uygula()


func _exit_tree() -> void:
	_aktif.erase(self)


func _cubuk(a: int, b: int) -> void:
	var d := (p[b] - p[a]).length()
	_aralik(a, b, d, d)


func _aralik(a: int, b: int, mn: float, mx: float) -> void:
	_ca.append(a)
	_cb.append(b)
	_cmin.append(mn)
	_cmax.append(mx)
	# Aralığın içi (karesiyle, kök almadan atlanır); sabit boylu çubukta ±0,5 mm
	_cmin2.append(maxf(0.0, mn - 0.0005) ** 2)
	_cmax2.append((mx + 0.0005) ** 2)


## Gövde çerçevesi: [sağ, yukarı (kalçadan omza), ön]
func _cerceve() -> Array:
	var kalca := (p[HL] + p[HR]) * 0.5
	var omuz := (p[SL] + p[SR]) * 0.5
	var u := (omuz - kalca).normalized()
	var r := (p[HR] - p[HL]) + (p[SR] - p[SL])
	r = (r - u * r.dot(u)).normalized()
	return [r, u, r.cross(u)]


func _process(delta: float) -> void:
	if dondu:
		set_process(false)
		return
	if kisi == null or not is_instance_valid(kisi) or not kisi.is_inside_tree():
		return
	if not kisi.is_visible_in_tree():
		_bitir()
		return
	var t0 := Time.get_ticks_usec()
	if _havada:
		_kok_izle(delta)
	_acc += minf(delta, ADIM_AZAMI * DT)
	var n := 0
	while _acc >= DT and n < ADIM_AZAMI:
		_acc -= DT
		n += 1
		_pv = p.duplicate()
		var ta := Time.get_ticks_usec()
		_adim()
		dbg_adim_us += Time.get_ticks_usec() - ta
		dbg_adim_n += 1
		if dondu:
			break
	if dondu:
		return
	if n > 0 or (_acc > 0.0 and _uyku < 3):
		var tu := Time.get_ticks_usec()
		_uygula_ara(clampf(_acc / DT, 0.0, 1.0))
		dbg_uyg_us += Time.get_ticks_usec() - tu
		dbg_uyg_n += 1
	var us := Time.get_ticks_usec() - t0
	olcum_us += us
	toplam_us += us
	toplam_n += 1
	if not _havada and (t >= sure or (_uyku >= 15 and t > 0.45)):
		_bitir()
	elif _havada and t > 6.0:
		indi()


## Havada: kökün bu karedeki yer değişimi bütün parçacıklara (hızları değişmeden); kök durunca iniş.
func _kok_izle(delta: float) -> void:
	if kok == null or not is_instance_valid(kok):
		indi()
		return
	var d := kok.global_position - _kok_son
	_kok_son = kok.global_position
	if d.length() > 3.0:
		return
	for i in N:
		p[i] += d
		o[i] += d
	if delta > 0.0:
		var v := d / delta
		if v.y < -1.5:
			_kok_dustu = true
			_kok_v = v
		elif _kok_dustu and v.y > -0.3:
			indi()


## Kök yere indi: yerçekimi ve zemin başlar; parçacıklar kökün son hızını alır. Izgara buradan yeniden kurulur.
func indi(v := Vector3.INF) -> void:
	if not _havada:
		return
	_havada = false
	var kv := _kok_v if v == Vector3.INF else v
	for i in N:
		o[i] -= kv * DT
	var tepe := -INF
	for i in N:
		tepe = maxf(tepe, p[i].y)
	_yc = tepe + 0.3
	_derin = 6.0
	_izgara.clear()
	_qi.clear()
	var ky := kok.global_position.y if kok and is_instance_valid(kok) else p[HL].y - 0.9
	for i in N:
		gz[i] = ky
	t = minf(t, 0.3)


## Su: düşen suya gömülür (kök batar): bez bebek o duruşta durur, gövde kökle batar.
func durdur() -> void:
	if dondu:
		return
	dondu = true
	_aktif.erase(self)
	set_process(false)


static var dbg_s := [0, 0, 0, 0]
func _adim() -> void:
	var _ta := Time.get_ticks_usec()
	t += DT
	var g := Vector3(0, -(_g if not _havada else 0.0) * DT * DT, 0)
	# Düşüşte havada çırpınır (kollar, bacaklar): ilk yere değişe kadar
	var cirpin := dusus and not _carpti and (_havada or t < 0.35)
	if cirpin:
		_cirpin_t -= DT
		if _cirpin_t <= 0.0:
			_cirpin_t = _rng.randf_range(0.12, 0.22)
			_cirpin = Vector3(_rng.randf_range(-1, 1), _rng.randf_range(-0.3, 1.0), _rng.randf_range(-1, 1)).normalized()
	for i in N:
		var cur := p[i]
		var v := (cur - o[i]) * 0.995
		var a := g
		if cirpin and i >= DSL:
			var s := 1.0 if (i == DSL or i == ELL) else -1.0
			a += (_cirpin * Vector3(s, 1, 1)) * 26.0 * DT * DT
		elif cirpin and (i == DZL or i == DZR or i == AYL or i == AYR):
			var s2 := 1.0 if (i == DZL or i == AYL) else -1.0
			a += Vector3(0, 0, _cirpin.x * s2) * 14.0 * DT * DT
		o[i] = cur
		p[i] = cur + v + a
	if _havada:
		_menteseler()
		for it in YINELE:
			_cubuklar()
		return
	var _tz := Time.get_ticks_usec()
	dbg_s[0] += _tz - _ta
	# Zemin (adım başına bir kez): duvar ve kenar yatayda geçilmez
	for i in N:
		var gg := _zemin_k(i, p[i].x, p[i].z)
		var eski := gz[i]
		var engel := false
		if gg == INF:
			engel = true          # henüz ışınlanmamış hücre: bu adım yatayda bekler (taşın içine girmesin)
		elif is_nan(gg):
			engel = not dusus
		elif gg > p[i].y - float(YARICAP[i]) + 0.02 and gg > eski + DUVAR:
			engel = true
		elif not dusus and gg < eski - KENAR:
			engel = true
		if engel:
			p[i].x = o[i].x
			p[i].z = o[i].z
			gg = _zemin_k(i, p[i].x, p[i].z)
		if is_nan(gg) or gg == INF:
			gg = eski if (not dusus or gg == INF) else -INF
		_gi[i] = gg
		if gg > -INF:
			gz[i] = gg
		_temas[i] = 0
	var kalca := (p[HL] + p[HR]) * 0.5
	var omuz := (p[SL] + p[SR]) * 0.5
	for k in KURE.size():
		var c := omuz.lerp(kalca, float(KURE[k][0]))
		var gk := _zemin_k(N + k, c.x, c.z)
		if gk == INF:
			gk = (gz[SL] + gz[SR]) * 0.5 if k == 0 else (gz[HL] + gz[HR]) * 0.5
		_gk[k] = gk if not is_nan(gk) else -INF
	var hiz_once := 0.0
	for i in 5:
		hiz_once = maxf(hiz_once, (o[i].y - p[i].y) / DT)
	var _tm := Time.get_ticks_usec()
	dbg_s[1] += _tm - _tz
	_menteseler()
	var _tc := Time.get_ticks_usec()
	dbg_s[2] += _tc - _tm
	for it in YINELE:
		_cubuklar()
		_temas_coz()
	dbg_s[3] += Time.get_ticks_usec() - _tc
	# Sürtünme (adım başına bir kez): zemine değen yatayda yavaşlar
	var ilk := -1
	for i in N:
		if _temas[i] != 0:
			o[i].x = lerpf(o[i].x, p[i].x, 0.25)
			o[i].z = lerpf(o[i].z, p[i].z, 0.25)
			if ilk < 0 and i <= BAS:
				ilk = i
	if not _carpti and ilk >= 0:
		_carpti = true
		carpti.emit(p[ilk], hiz_once)
	var en := 0.0
	for i in N:
		en = maxf(en, (p[i] - o[i]).length_squared())
	if en < 0.0025 * 0.0025:
		_uyku += 1
	else:
		_uyku = 0


func _cubuklar() -> void:
	for c in _ca.size():
		var ia := _ca[c]
		var ib := _cb[c]
		var d := p[ib] - p[ia]
		var l2 := d.length_squared()
		if l2 > _cmin2[c] and l2 < _cmax2[c]:
			continue
		var l := sqrt(l2)
		if l < 0.0001:
			continue
		var hedef := clampf(l, _cmin[c], _cmax[c])
		if absf(l - hedef) < 0.0005:
			continue
		var wa := w[ia]
		var wb := w[ib]
		var corr := d * ((l - hedef) / (l * (wa + wb)))
		p[ia] += corr * wa
		p[ib] -= corr * wb


func _temas_coz() -> void:
	for i in N:
		var r: float = YARICAP[i]
		if p[i].y < _gi[i] + r:
			p[i].y = _gi[i] + r
			o[i].y = p[i].y
			_temas[i] = 1
	var kalca := (p[HL] + p[HR]) * 0.5
	var omuz := (p[SL] + p[SR]) * 0.5
	for k in KURE.size():
		var c := omuz.lerp(kalca, float(KURE[k][0]))
		var dy := _gk[k] + float(KURE[k][1]) - c.y
		if dy > 0.0:
			# Küre merkezi omuz ve kalça noktalarının ağırlıklı ortası: düzeltme kaldıraçla dağılır (gövde döner, dik
			# oturup kalmaz); hız korunur (yalnız gömülme geri alınır)
			var tt := float(KURE[k][0])
			var a_s := (1.0 - tt) * 0.5
			var a_h := tt * 0.5
			var lam := dy / (2.0 * a_s * a_s + 2.0 * a_h * a_h)
			var ds := a_s * lam
			var dh := a_h * lam
			p[SL].y += ds
			p[SR].y += ds
			o[SL].y += ds * 0.7
			o[SR].y += ds * 0.7
			p[HL].y += dh
			p[HR].y += dh
			o[HL].y += dh * 0.7
			o[HR].y += dh * 0.7
			if a_s > 0.25:
				_temas[SL] = 1
				_temas[SR] = 1
			if a_h > 0.25:
				_temas[HL] = 1
				_temas[HR] = 1


## Diz yalnız öne bükülür; uyluk kalça ekleminin konisi içinde.
func _menteseler() -> void:
	var cv := _cerceve()
	var r: Vector3 = cv[0]
	var u: Vector3 = cv[1]
	var f: Vector3 = cv[2]
	for s in 2:
		var hi := HL if s == 0 else HR
		var di := DZL if s == 0 else DZR
		var ai := AYL if s == 0 else AYR
		var hp := p[hi]
		# Uyluk konisi (gövde çerçevesinde): geri en çok ~33°, yukarı ~30° (öne bükükken), içe çapraz ~15°, dışa ~45°
		var th := p[di] - hp
		var l := th.length()
		if l > 0.001:
			var vx := th.dot(r) / l
			var vy := th.dot(u) / l
			var vz := th.dot(f) / l
			var dis := vx if s == 1 else -vx
			var ok := true
			if vz < -0.55:
				vz = -0.55
				ok = false
			if vy > 0.5:
				vy = 0.5
				ok = false
			if dis > 0.7:
				dis = 0.7
				ok = false
			elif dis < -0.26:
				dis = -0.26
				ok = false
			if not ok:
				vx = dis if s == 1 else -dis
				var nv := (r * vx + u * vy + f * vz).normalized()
				p[di] = p[di].lerp(hp + nv * l, 0.6)
		# Menteşe: diz kalça-ayak çizgisinin önünde
		var mid := (hp + p[ai]) * 0.5
		var leg := p[ai] - hp
		var ll := leg.length()
		var fwd := f
		if ll > 0.01:
			var ld := leg / ll
			fwd = (f - ld * f.dot(ld))
			if fwd.length() < 0.05:
				fwd = (u - ld * u.dot(ld)) * -1.0
			fwd = fwd.normalized()
		var dd := (p[di] - mid).dot(fwd)
		if dd < 0.015:
			p[di] += fwd * (0.015 - dd) * 0.7


# ---------------------------------------------------------------- zemin ızgarası

## Parçacık başına önbellekli zemin (k: 0..N-1 parçacık, N, N+1 gövde küreleri): aynı hücre dörtlüsünde kaldıkça
## sözlüğe bakılmaz (adımın en pahalı kısmıydı).
var _qi := PackedInt32Array()
var _qh := PackedFloat32Array()
func _zemin_k(k: int, x: float, z: float) -> float:
	if _qi.is_empty():
		_qi.resize((N + 2) * 3)
		_qh.resize((N + 2) * 4)
		for m in N + 2:
			_qi[m * 3 + 2] = 0
	var fx := x / HUCRE
	var fz := z / HUCRE
	var i0 := floori(fx)
	var j0 := floori(fz)
	var oi := roundi(fx) - i0
	var oj := roundi(fz) - j0
	var b := k * 4
	if _qi[k * 3 + 2] == 0 or _qi[k * 3] != i0 or _qi[k * 3 + 1] != j0:
		var h00 := _hucre(i0, j0)
		var h10 := _hucre(i0 + 1, j0)
		var h01 := _hucre(i0, j0 + 1)
		var h11 := _hucre(i0 + 1, j0 + 1)
		if h00 == INF or h10 == INF or h01 == INF or h11 == INF:
			_qi[k * 3 + 2] = 0
			return INF
		_qi[k * 3] = i0
		_qi[k * 3 + 1] = j0
		_qi[k * 3 + 2] = 1
		_qh[b] = h00
		_qh[b + 1] = h10
		_qh[b + 2] = h01
		_qh[b + 3] = h11
	var own := _qh[b + oi + oj * 2]
	if is_nan(own):
		return NAN
	var a00 := _qh[b]
	var a10 := _qh[b + 1]
	var a01 := _qh[b + 2]
	var a11 := _qh[b + 3]
	if is_nan(a00) or absf(a00 - own) > 0.12:
		a00 = own
	if is_nan(a10) or absf(a10 - own) > 0.12:
		a10 = own
	if is_nan(a01) or absf(a01 - own) > 0.12:
		a01 = own
	if is_nan(a11) or absf(a11 - own) > 0.12:
		a11 = own
	var ax := fx - i0
	var az := fz - j0
	return lerpf(lerpf(a00, a10, ax), lerpf(a01, a11, ax), az)


func _zemin(x: float, z: float) -> float:
	var fx := x / HUCRE
	var fz := z / HUCRE
	var i0 := floori(fx)
	var j0 := floori(fz)
	var ax := fx - i0
	var az := fz - j0
	var own := _hucre(roundi(fx), roundi(fz))
	if is_nan(own) or own == INF:
		return own
	var h00 := _hucre(i0, j0)
	var h10 := _hucre(i0 + 1, j0)
	var h01 := _hucre(i0, j0 + 1)
	var h11 := _hucre(i0 + 1, j0 + 1)
	# Basamak, duvar dibi: komşusu çok farklı köşe yerine kendi hücresi (keskin kenar rampaya dönmesin)
	if is_nan(h00) or absf(h00 - own) > 0.12:
		h00 = own
	if is_nan(h10) or absf(h10 - own) > 0.12:
		h10 = own
	if is_nan(h01) or absf(h01 - own) > 0.12:
		h01 = own
	if is_nan(h11) or absf(h11 - own) > 0.12:
		h11 = own
	return lerpf(lerpf(h00, h10, ax), lerpf(h01, h11, ax), az)


func _hucre(i: int, j: int) -> float:
	var key := Vector2i(i, j)
	var v = _izgara.get(key)
	if v != null:
		return v
	var f := Engine.get_process_frames()
	if f != _isin_kare:
		_isin_kare = f
		_isin_kalan = ISIN_KARE
	if _isin_kalan <= 0:
		return INF
	_isin_kalan -= 1
	var h := _isin(Vector3(i * HUCRE, _yc, j * HUCRE), _derin, true)
	_izgara[key] = h
	return h


## Yukarıdan aşağı ilk katı zemin (Unclip.standable; yeni sette "dusus_her_kati" sahnesinde her StaticBody3D). İçinden
## başlanan katı: duvar (başlangıç yüksekliği). Yoksa NAN.
static var dbg_adim_us := 0
static var dbg_adim_n := 0
static var dbg_uyg_us := 0
static var dbg_uyg_n := 0
static var isin_n := 0
static var isin_us := 0
func _isin(from: Vector3, derin: float, icten: bool) -> float:
	var t0 := Time.get_ticks_usec()
	var r := _isin0(from, derin, icten)
	isin_n += 1
	isin_us += Time.get_ticks_usec() - t0
	return r


func _isin0(from: Vector3, derin: float, icten: bool) -> float:
	if kisi == null or not kisi.is_inside_tree():
		return NAN
	var space := kisi.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, from - Vector3(0, derin, 0), 1, _haric)
	q.hit_from_inside = icten
	for k in 8:
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			return NAN
		var col: Object = hit["collider"]
		if not kati(col, int(hit.get("shape", 0)), _her_kati):
			if col is CollisionObject3D:
				q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
				continue
			return NAN
		if (hit["normal"] as Vector3) == Vector3.ZERO:
			return from.y
		return (hit["position"] as Vector3).y
	return NAN


static func kati(col: Object, shape: int, her_kati: bool) -> bool:
	if not (col is CollisionObject3D):
		return false
	if Unclip.standable(col, shape):
		return true
	if her_kati and col is StaticBody3D and not (col as Node).is_queued_for_deletion():
		var q: Node = col as Node
		while q != null:
			if Unclip._is_char(q):
				return false
			q = q.get_parent()
		return true
	return false


# ---------------------------------------------------------------- görüntü

## Adımlar arası (30 Hz benzetim, her karede görüntü): önceki ve son adımın arası
var _pv := PackedVector3Array()
func _uygula_ara(a: float) -> void:
	if _pv.size() != N or a >= 0.999:
		_uygula()
		return
	var keep := p
	var q := PackedVector3Array()
	q.resize(N)
	for i in N:
		q[i] = _pv[i].lerp(keep[i], a)
	p = q
	_uygula()
	p = keep


func _uygula() -> void:
	var cv := _cerceve()
	var r: Vector3 = cv[0]
	var u: Vector3 = cv[1]
	var f: Vector3 = cv[2]
	var R := Basis(r, u, f)
	var B := Basis(r * _govde_olcek.x, u * _govde_olcek.y, f * _govde_olcek.z)
	var kalca := (p[HL] + p[HR]) * 0.5
	var xf := Transform3D(B, kalca - B * _kalca_yerel)
	rig.body.global_transform = xf
	son_govde = xf
	var ri := R.transposed()
	_uzuv(rig.arm_l, rig.elbow_l, ri * (p[DSL] - p[SL]).normalized(), ri * (p[ELL] - p[DSL]).normalized(), false)
	_uzuv(rig.arm_r, rig.elbow_r, ri * (p[DSR] - p[SR]).normalized(), ri * (p[ELR] - p[DSR]).normalized(), false)
	_uzuv(rig.leg_l, rig.knee_l, ri * (p[DZL] - p[HL]).normalized(), ri * (p[AYL] - p[DZL]).normalized(), true)
	_uzuv(rig.leg_r, rig.knee_r, ri * (p[DZR] - p[HR]).normalized(), ri * (p[AYR] - p[DZR]).normalized(), true)
	# Baş: boyun parçacığı (sarkar); düğüm o yere taşınır, boyun yönüne döner
	var hl := ri * ((p[BAS] - xf.origin))
	hl = Vector3(hl.x / _govde_olcek.x, hl.y / _govde_olcek.y, hl.z / _govde_olcek.z)
	rig.head.position = hl
	var omuz_l := (rig.arm_l.position + rig.arm_r.position) * 0.5
	var nd := (hl - omuz_l).normalized()
	rig.head.basis = Basis(Quaternion(_bas_yerel_yon, nd))


## LimbAnim._limb ile aynı: omuz/kalça ekseninin yerel -Y'si üst uzva, dirsek/diz X çevresinde alt uzva.
static func _uzuv(pivot: Node3D, joint: Node3D, u: Vector3, l: Vector3, bacak: bool) -> void:
	var y_axis := -u
	var perp := l - u * l.dot(u)
	if perp.length() < 0.02:
		perp = Vector3(0, 0, 1) - u * u.z
		if perp.length() < 0.02:
			perp = Vector3(0, 1, 0) - u * u.y
	perp = perp.normalized()
	var z_axis := -perp if bacak else perp
	var x_axis := y_axis.cross(z_axis).normalized()
	z_axis = x_axis.cross(y_axis).normalized()
	pivot.basis = Basis(x_axis, y_axis, z_axis)
	if joint:
		var ang := acos(clampf(u.dot(l), -1.0, 1.0))
		joint.rotation = Vector3(ang if bacak else -ang, 0, 0)


# ---------------------------------------------------------------- bitiş

## Uyku ya da süre: son oturtma (her parçacığın altında tam ışın), görüntü, donma.
func _bitir() -> void:
	if dondu:
		return
	dondu = true
	_aktif.erase(self)
	if kisi == null or not is_instance_valid(kisi) or not kisi.is_inside_tree():
		return
	var t0 := Time.get_ticks_usec()
	_son_oturt()
	_uygula()
	set_process(false)
	olcum_us += Time.get_ticks_usec() - t0
	toplam_us += Time.get_ticks_usec() - t0
	if GameState.autotest:
		denetle(kisi, "fizik")
	bitti.emit()


func _son_oturt() -> void:
	var ge := PackedFloat32Array()
	ge.resize(N)
	for i in N:
		var gg := _isin(Vector3(p[i].x, p[i].y + 0.6, p[i].z), 1.8, false)
		ge[i] = gg if not is_nan(gg) else gz[i]
	var kc := PackedFloat32Array()
	var kalca := (p[HL] + p[HR]) * 0.5
	var omuz := (p[SL] + p[SR]) * 0.5
	for k: Array in KURE:
		var c := omuz.lerp(kalca, float(k[0]))
		var gg := _isin(Vector3(c.x, c.y + 0.6, c.z), 1.8, false)
		kc.append(gg if not is_nan(gg) else NAN)
	for it in 14:
		for i in N:
			if is_nan(ge[i]):
				continue
			var r: float = YARICAP[i]
			var gap := p[i].y - r - ge[i]
			if gap < 0.0:
				p[i].y -= gap
			elif gap > 0.02:
				p[i].y -= minf(gap, 0.04)
		kalca = (p[HL] + p[HR]) * 0.5
		omuz = (p[SL] + p[SR]) * 0.5
		for k in KURE.size():
			if is_nan(kc[k]):
				continue
			var c := omuz.lerp(kalca, float(KURE[k][0]))
			var dy: float = kc[k] + float(KURE[k][1]) - c.y
			if dy > 0.0:
				var tt := float(KURE[k][0])
				var lam := dy / (2.0 * pow((1.0 - tt) * 0.5, 2) + 2.0 * pow(tt * 0.5, 2))
				for i in [SL, SR]:
					p[i].y += (1.0 - tt) * 0.5 * lam
				for i in [HL, HR]:
					p[i].y += tt * 0.5 * lam
		for c in _ca.size():
			var ia := _ca[c]
			var ib := _cb[c]
			var d := p[ib] - p[ia]
			var l := d.length()
			if l < 0.0001:
				continue
			var hedef := clampf(l, _cmin[c], _cmax[c])
			if absf(l - hedef) < 0.0005:
				continue
			var wa := w[ia]
			var wb := w[ib]
			var corr := d * ((l - hedef) / (l * (wa + wb)))
			p[ia] += corr * wa
			p[ib] -= corr * wb
	# Son bir kez: hiçbir parçacık zemine gömük kalmasın (kısıt düzeltmesi geri itmiş olabilir)
	for i in N:
		if not is_nan(ge[i]) and p[i].y - float(YARICAP[i]) < ge[i]:
			p[i].y = ge[i] + float(YARICAP[i])


## Hemen dondur (ceset sınırı, sahne değişimi).
func dondur() -> void:
	_bitir()


## Kök (düellocu) cesedin kalçasının altına taşındıktan sonra gövde dünyadaki yerinde kalsın.
func yeniden() -> void:
	if rig and rig.body and is_instance_valid(rig.body):
		rig.body.global_transform = son_govde


## Kalkacak olan: yerdeki duruşu LimbAnim'in harmanına verir (klip bu duruştan başlar), kilidi bırakır.
func devret(anim: LimbAnim) -> void:
	if anim == null:
		birak(false)
		return
	var inv := (kisi as Node3D).global_basis.orthonormalized().transposed()
	var cv := _cerceve()
	var cur := {}
	cur["sp"] = (inv * (cv[1] as Vector3)).normalized()
	cur["ua_r"] = (inv * (p[DSR] - p[SR])).normalized()
	cur["la_r"] = (inv * (p[ELR] - p[DSR])).normalized()
	cur["ua_l"] = (inv * (p[DSL] - p[SL])).normalized()
	cur["la_l"] = (inv * (p[ELL] - p[DSL])).normalized()
	cur["th_r"] = (inv * (p[DZR] - p[HR])).normalized()
	cur["ca_r"] = (inv * (p[AYR] - p[DZR])).normalized()
	cur["th_l"] = (inv * (p[DZL] - p[HL])).normalized()
	cur["ca_l"] = (inv * (p[AYL] - p[DZL])).normalized()
	cur["hd"] = cur["sp"]
	anim.set("_cur", cur)
	birak(false)
	if anim and is_instance_valid(anim):
		anim.set_process(true)


static func birak_kisi(ch: Node) -> void:
	var y := of(ch)
	if y:
		y.call("birak", true)


## Bırak: gövde ve baş dinlenme dönüşümüne (geri_kur), kilit kalkar, LimbAnim yeniden çalışır.
func birak(geri_kur := true) -> void:
	if not dondu:
		dondu = true
		_aktif.erase(self)
	if kisi and is_instance_valid(kisi):
		if kisi.get_meta("yigilma", null) == self:
			kisi.remove_meta("yigilma")
		if geri_kur and rig and rig.body:
			rig.body.transform = _govde_dinlen
			rig.head.rotation = _bas_dinlen
			rig.head.position = _bas_konum
	if _kilit and rig:
		rig.lock = maxi(0, rig.lock - 1)
		_kilit = false
	if _anim and is_instance_valid(_anim) and geri_kur:
		_anim.set_process(true)
	queue_free()


# ---------------------------------------------------------------- tüfekle vurulan (Handgun._down → kişinin shot())

## Tüfekle vurulan asker/kişi: atıcıdan uzağa geriye yığılır (bez bebek); eski devrilmenin süresi kadar (0,45 + 2 sn)
## yatar, sonra gizlenir (oynanış aynı). Yığılma kapalıysa Handgun'ın eski devrilmesi birebir.
static func vuruldu(ch: Node3D, from: Vector3) -> void:
	var rg = ch.get("rig")
	if rg is Rig:
		(rg as Rig).set("activity", "fall")
	var away := ch.global_position - from
	away.y = 0.0
	var y: Node = null
	if etkin:
		var dir := away.normalized() if away.length() > 0.01 else -ch.global_basis.z
		y = baslat(ch, {"itme": dir * 3.0 + Vector3(0, 0.4, 0), "h": 1.4, "v0": dir * 0.6, "diz": 0.8})
	if y != null:
		ch.set_meta("corpse", true)
		ch.set_meta("no_block", true)
		var tw := ch.create_tween()
		tw.tween_interval(2.45)
		tw.tween_property(ch, "visible", false, 0.0)
		return
	var head := ch.global_position + Vector3(0, 1.6, 0)
	var axis := ch.global_transform.basis.x
	var sgn := 1.0
	var a := Basis(axis, deg_to_rad(85.0)) * (head - ch.global_position)
	var b := Basis(axis, deg_to_rad(-85.0)) * (head - ch.global_position)
	if a.dot(away) < b.dot(away):
		sgn = -1.0
	var tw2 := ch.create_tween()
	tw2.tween_property(ch, "rotation", (Basis(axis, deg_to_rad(85.0) * sgn) * ch.global_transform.basis).get_euler(), 0.45).set_ease(Tween.EASE_IN)
	tw2.tween_interval(2.0)
	tw2.tween_property(ch, "visible", false, 0.0)


# ---------------------------------------------------------------- denetim

static var _sayac := {}

## YIGILMAAUDIT: yığılma bitince cesedin her uzvunun (baş, gövde, eller, ayaklar) altındaki görünen zemine uzaklığı.
## Havada > 8 cm ya da gömük > 8 cm ise satır (kişi başına bir kez). ÖNCE (klip yolu) da aynı ölçüyle çağrılır.
static func denetle(ch: Node3D, kip: String) -> void:
	if ch == null or not is_instance_valid(ch) or not ch.is_inside_tree() or not ch.is_visible_in_tree():
		return
	var rg = ch.get("rig")
	if not (rg is Rig) or (rg as Rig).body == null:
		return
	var r := rg as Rig
	var her := false
	var q: Node = ch.get_parent()
	while q != null:
		if q.has_meta("dusus_her_kati"):
			her = bool(q.get_meta("dusus_her_kati"))
			break
		q = q.get_parent()
	var b := r.body.global_transform
	var parca := [["bas", r.head.global_position, 0.2],
		["govde", b * Vector3(0, 1.15, 0), 0.2], ["govde", b * Vector3(0, 0.75, 0), 0.2],
		["el_l", r.elbow_l.global_transform * (r.elbow_l.get_meta("hand", Vector3(0, -0.27, 0.01)) as Vector3), 0.05],
		["el_r", r.elbow_r.global_transform * (r.elbow_r.get_meta("hand", Vector3(0, -0.27, 0.01)) as Vector3), 0.05],
		["ayak_l", CharKit.ankle_of(r.knee_l).global_position, 0.07],
		["ayak_r", CharKit.ankle_of(r.knee_r).global_position, 0.07]]
	var space := ch.get_world_3d().direct_space_state
	var kotu: Array = []
	for pr: Array in parca:
		var at: Vector3 = pr[1]
		var rad: float = pr[2]
		var g := _denet_zemin(space, at, her)
		if is_nan(g):
			continue
		var fark := at.y - rad - g
		if fark > 0.08 or fark < -0.08:
			kotu.append("%s=%+.2f" % [pr[0], fark])
	if kotu.is_empty():
		return
	var sc := ch.get_tree().current_scene
	var id := ch.get_instance_id()
	if _sayac.has(id):
		return
	_sayac[id] = true
	var par := ch.get_parent()
	print("YIGILMAAUDIT %s scene=%s who=%s/%s(%s) at=%s %s" % [kip, sc.name if sc else "", "Soldier" if ch is Soldier else ("Person" if ch is Person else ch.get_class()), ch.name,
		par.name if par else "", ch.global_position.snapped(Vector3.ONE * 0.1), " ".join(kotu)])


## Uzvun altındaki görünen zemin: uzvun 0,6 m üstünden 1,8 m aşağıya (içinden başlanan katı sayılmaz).
static func _denet_zemin(space: PhysicsDirectSpaceState3D, at: Vector3, her: bool) -> float:
	var q := PhysicsRayQueryParameters3D.create(at + Vector3(0, 0.6, 0), at - Vector3(0, 1.8, 0), 1)
	for k in 8:
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			return NAN
		var col: Object = hit["collider"]
		if not kati(col, int(hit.get("shape", 0)), her):
			if col is CollisionObject3D:
				q.exclude = q.exclude + [(col as CollisionObject3D).get_rid()]
				continue
			return NAN
		return (hit["position"] as Vector3).y
	return NAN
