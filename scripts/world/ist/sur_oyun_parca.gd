extends RefCounted
## SUR OYUN PARÇALARI (kararlar 2, 4, 5, 7, 10; docs/SUR_BOLUM_TASIMA.md §3.3) — class_name YOK, sur_oyun.gd kullanır.
## Hepsi kesim-yerel çerçevede kurulur ve arayüzün yerleştirme noktalarına oturur. Görünüş v2 dilinde: taş IstSurlar
## taş malzemesi (KULE._tas_mat), ahşap C_WOOD tonları, toprak "dirt"; adlar GorselDil kategorisine uyar (Tas_/Ahsap_/
## Toprak_). KUTU YASAĞI: canlı ve yuvarlak nesne kutudan yapılmaz (fıçı, sepet, kazık silindir; kalas/tahta/kiriş düz
## kesitli ahşaptır).
##   Poterna       ac(bool)                     dış surun ova yüzünde küçük kapı; kanat menteşede döner, çarpışmalı
##   KalasKopru    tak() / sok()                hendeği aşan ayaklı kalas (≥ 21,8 m), üstünde yürünür
##   Dolgu         doluluk(f)                   sepet sepet dolan toprak rampa (f 0..1; 1 = kıyıyla aynı düzde set)
##   KapiKopru     hal("saglam"|"yikik")         kapı önü köprüsü (yıkık ayakların arası)
##   HucumMerdiveni (Ladder taşır)  it() / devir() / dik()   dayama noktasına konur; climb_anim Ladder'ı doğrudan okur
##   GedikOnarim   asama(1..4)                   açık → kazık/fıçı → toprak dolgu → barikat tam; moloz rampası hep

const SZ := preload("res://scripts/world/ist/sur_sozlesme.gd")
const KULE := preload("res://scripts/world/ist/sur_kule.gd")
const C_WOOD := Color("7a5634")
const C_TOPRAK := Color("6e5c42")
const C_MOLOZ := Color("7c705c")
const PARCA_ := preload("res://scripts/world/ist/sur_oyun_ag.gd")
const ASAMALAR := ["", "acik", "kazik_fici", "toprak_dolgu", "barikat_tam"]


static func _tas() -> Color:
	return IstSurlar.C_STONE


# ------------------------------------------------------------------ zemin (kesim sahnesi; şehir yokken)

## Şehir önü ve ova levhaları (şehirde bunlar arazidir; kesim sahnesinde düz levha, Mesoteikhion ovası düz: §3.2)
static func zemin(kok: Node3D, a: RefCounted, uzak: bool) -> void:
	var d: Dictionary = a.d
	var Lt: float = a.L + SZ.YAN_L * (6.0 if uzak else 2.0)
	var zi0 := float(d["zi0"])
	var zm1 := float(d["zm1"])
	var z0 := zi0 - 90.0
	var z1 := zi0 - 4.0
	var s := Props.solid(kok, Vector3(Lt, 2.0, z1 - z0), Vector3(0, a.y_peri() - 1.0, (z0 + z1) * 0.5), Color.WHITE)
	Props.set_pattern(s, Color("7d6c52"), "dirt")
	s.name = "Toprak_ZeminSehir"
	var o0 := zm1 + 0.9
	var o1 := zm1 + 190.0
	var s2 := Props.solid(kok, Vector3(Lt, 2.0, o1 - o0), Vector3(0, a.y_ova() - 1.0, (o0 + o1) * 0.5), Color.WHITE)
	Props.set_pattern(s2, Color("80704f"), "dirt")
	s2.name = "Toprak_ZeminOva"


# ------------------------------------------------------------------ hepsini kur

static func kur_hepsi(kok: Node3D, a: RefCounted, sec: Dictionary) -> Dictionary:
	var out := {}
	var p := Node3D.new()
	p.name = "OyunParcalari"
	kok.add_child(p)
	var po := Poterna.new()
	po.name = "Tas_Poterna"
	po.kur(a)
	p.add_child(po)
	po.ac(bool(sec.get("poterna_acik", false)), false)
	out["poterna"] = po
	var h: Dictionary = a.hendek()
	if not h.is_empty():
		for g in h["gecis"]:
			match String(g["tur"]):
				"kalas":
					var k := KalasKopru.new()
					k.name = "Ahsap_KalasKopru"
					k.kur(a, float(g["x"]))
					p.add_child(k)
					if bool(sec.get("kalas", true)):
						k.tak()
					else:
						k.sok()
					out["kalas"] = k
				"dolgu":
					var dl := Dolgu.new()
					dl.name = "Toprak_HendekDolgu"
					dl.kur(a, float(g["x"]), float(g["en"]))
					p.add_child(dl)
					dl.doluluk(float(sec.get("dolgu", 0.0)))
					out["dolgu"] = dl
				"kapi_kopru":
					var kk := KapiKopru.new()
					kk.name = "Ahsap_KapiKopru"
					kk.kur(a)
					p.add_child(kk)
					kk.hal(String(sec.get("kapi_kopru", "saglam")))
					out["kapi_kopru"] = kk
	if not is_nan(a.gx):
		var go := GedikOnarim.new()
		go.name = "Toprak_GedikOnarim"
		go.kur(a)
		p.add_child(go)
		go.asama(a.asama)
		out["gedik"] = go
	var mer: Array = []
	var dl2: Array = a.dayamalar()
	for i in sec.get("merdiven", []):
		if int(i) < 0 or int(i) >= dl2.size():
			continue
		var m := HucumMerdiveni.new()
		m.name = "Ahsap_HucumMerdiveni_%d" % int(i)
		m.kur(dl2[int(i)])
		p.add_child(m)
		mer.append(m)
	out["merdiven"] = mer
	return out


# ------------------------------------------------------------------ POTERNA (karar 10-A)

class Poterna extends Node3D:
	var kanat: Node3D
	var kanat_govde: StaticBody3D
	var acik := false
	var x := 0.0

	func kur(a: RefCounted) -> void:
		var d: Dictionary = a.d
		var pt: Dictionary = a.poterna()
		x = float(pt["x"])
		var zo0 := float(d["zo0"])
		var zo1 := float(d["zo1"])
		var w := IstSurlar.POTERNA_W
		var h := IstSurlar.POTERNA_H
		var tas := IstSurlar.C_STONE.darkened(0.1)
		var ag = KULE.Ag.new()
		# söve (iki yanda çıkıntılı taş pervaz, ova yüzünde) ve kemerli alın taşı (yarım daire kama taşları)
		for s: float in [-1.0, 1.0]:
			var sx := x + s * (w * 0.5 + 0.14)
			ag.kutu(Vector3(sx, -0.05, zo1), Vector3.RIGHT, Vector3.BACK, 0.28, h + 0.05, 0.12)
			ag.kutu(Vector3(sx, -0.05, zo0 - 0.12), Vector3.RIGHT, Vector3.BACK, 0.28, h + 0.05, 0.12)
		var n := 7
		var r := w * 0.5 + 0.14
		for i in n:
			var a0 := PI * float(i) / n
			var a1 := PI * float(i + 1) / n
			for zf: float in [zo1, zo1 + 0.13]:
				pass
			var p0 := Vector3(x + cos(a0) * r, h - 0.35 + sin(a0) * 0.55, zo1 + 0.13)
			var p1 := Vector3(x + cos(a1) * r, h - 0.35 + sin(a1) * 0.55, zo1 + 0.13)
			var q0 := Vector3(x + cos(a0) * (r + 0.32), h - 0.35 + sin(a0) * 0.87, zo1 + 0.13)
			var q1 := Vector3(x + cos(a1) * (r + 0.32), h - 0.35 + sin(a1) * 0.87, zo1 + 0.13)
			ag.quad(p0, p1, q1, q0, Vector3.BACK, Color(1, 1, 1) if i % 2 == 0 else Color(0.86, 0.82, 0.76))
		# eşik taşı (iki yandaki toprakla aynı düzde)
		ag.kutu(Vector3(x, -0.12, zo0 - 0.4), Vector3.RIGHT, Vector3.BACK, w + 0.1, 0.1, zo1 - zo0 + 0.8)
		ag.mesh_ekle(self, KULE._tas_mat(tas, 0), "Tas_PoternaSove")
		var esik := StaticBody3D.new()
		esik.name = "Tas_PoternaEsik_Carp"
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(w + 0.1, 0.12, zo1 - zo0 + 0.8)
		cs.shape = bs
		esik.add_child(cs)
		esik.position = Vector3(x, -0.08, (zo0 + zo1) * 0.5)
		add_child(esik)
		# kanat: menteşe dış yüzün içinde (x − w/2), ova yüzünden 0,12 m geride; dışarı açılır
		kanat = Node3D.new()
		kanat.name = "Ahsap_PoternaKanat"
		kanat.position = Vector3(x - w * 0.5 + 0.03, 0.0, zo1 - 0.14)
		add_child(kanat)
		var kag = KULE.Ag.new()
		var tw := (w - 0.06) / 5.0
		for i in 5:
			var hh := h - 0.05 - (0.12 if i in [0, 4] else 0.0)
			kag.kutu(Vector3(tw * (i + 0.5), 0.0, -0.05), Vector3.RIGHT, Vector3.BACK, tw - 0.012, hh, 0.09, Color(1, 1, 1) if i % 2 == 0 else Color(0.9, 0.87, 0.82))
		kag.mesh_ekle(kanat, Props.mat(C_WOOD.darkened(0.15), 0.0, false, "wood"), "Ahsap_PoternaTahta")
		var dag = KULE.Ag.new()
		for yy: float in [0.35, h - 0.55]:
			dag.kutu(Vector3((w - 0.06) * 0.5, yy, 0.04), Vector3.RIGHT, Vector3.BACK, w - 0.16, 0.07, 0.025)
		dag.mesh_ekle(kanat, Props.mat(Color("3a3634"), 0.0, false, ""), "Demir_PoternaKusak")
		kanat_govde = StaticBody3D.new()
		var kc := CollisionShape3D.new()
		var kb := BoxShape3D.new()
		kb.size = Vector3(w - 0.06, h, 0.12)
		kc.shape = kb
		kanat_govde.add_child(kc)
		kanat_govde.position = Vector3((w - 0.06) * 0.5, h * 0.5, -0.01)
		kanat.add_child(kanat_govde)

	## Kanadı açar/kapar (dışarı, 100°). anim: tween ile 0,8 sn
	func ac(p_acik: bool, anim := true) -> void:
		acik = p_acik
		var hedef := deg_to_rad(-100.0) if acik else 0.0
		if anim and is_inside_tree():
			create_tween().tween_property(kanat, "rotation:y", hedef, 0.8).set_trans(Tween.TRANS_SINE)
		else:
			kanat.rotation.y = hedef


# ------------------------------------------------------------------ KALAS KÖPRÜ (karar 7-A; 36b, 37o)

class KalasKopru extends Node3D:
	var govde: StaticBody3D
	var boy := 21.8

	func kur(a: RefCounted, x: float) -> void:
		var d: Dictionary = a.d
		var dy: float = a.dy
		var za := float(d["zm0"]) - 0.95
		var zb := float(d["zm1"]) + 0.95
		boy = zb - za
		var y := dy + 0.02
		var MD := float(d["MD"])
		var rng := RandomNumberGenerator.new()
		rng.seed = int(absf(x * 31.0)) + 7
		var ag = KULE.Ag.new()
		# iki uzun kiriş (boydan boya), üstte enine tahtalar (1,6 m), aralarda hafif boşluk
		for s: float in [-0.62, 0.62]:
			ag.kutu(Vector3(x + s, y - 0.24, za), Vector3.RIGHT, Vector3.BACK, 0.18, 0.2, boy)
		var zz := za + 0.05
		while zz < zb - 0.2:
			var tw := rng.randf_range(0.26, 0.34)
			ag.kutu(Vector3(x + rng.randf_range(-0.04, 0.04), y - 0.04, zz), Vector3.RIGHT, Vector3.BACK, 1.6 + rng.randf_range(-0.08, 0.06), 0.06, tw,
				Color(1, 1, 1) if int(zz * 3.0) % 2 == 0 else Color(0.88, 0.84, 0.78))
			zz += tw + 0.035
		# ayaklar: hendek dibine inen iki A-sehpa (üçte bir, üçte iki), çapraz bağ
		for t: float in [0.36, 0.64]:
			var zc := lerpf(za, zb, t)
			for s2: float in [-0.7, 0.7]:
				var top := Vector3(x + s2 * 0.85, y - 0.26, zc)
				var dip := Vector3(x + s2 * 1.25, dy - MD, zc)
				_dikme(ag, dip, top, 0.16)
			_dikme(ag, Vector3(x - 1.1, dy - MD + 0.8, zc), Vector3(x + 0.85, y - 0.6, zc), 0.1)
			ag.kutu(Vector3(x, y - 0.42, zc - 0.1), Vector3.RIGHT, Vector3.BACK, 2.0, 0.16, 0.2)
		ag.mesh_ekle(self, Props.mat(C_WOOD, 0.0, false, "wood"), "Ahsap_KalasTahta")
		govde = StaticBody3D.new()
		govde.name = "Ahsap_Kalas_Carp"
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(1.6, 0.12, boy)
		cs.shape = bs
		govde.add_child(cs)
		govde.position = Vector3(x, y - 0.06, (za + zb) * 0.5)
		add_child(govde)

	static func _dikme(ag, a: Vector3, b: Vector3, t: float) -> void:
		# kare kesitli ahşap dikme (a → b)
		var u := (b - a)
		var L := u.length()
		var f := u / L
		var r := f.cross(Vector3.BACK).normalized() if absf(f.z) < 0.9 else f.cross(Vector3.RIGHT).normalized()
		var q := f.cross(r).normalized()
		var c: Array = []
		for s in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
			c.append(r * s.x * t * 0.5 + q * s.y * t * 0.5)
		for i in 4:
			var j := (i + 1) % 4
			var nrm: Vector3 = (c[i] + c[j]).normalized()
			ag.quad(a + c[i], a + c[j], b + c[j], b + c[i], nrm)

	func tak() -> void:
		visible = true
		govde.get_child(0).set_deferred("disabled", false)

	func sok() -> void:
		visible = false
		govde.get_child(0).set_deferred("disabled", true)


# ------------------------------------------------------------------ HENDEK DOLGUSU (22o, 26o, 32o)

class Dolgu extends Node3D:
	var a_ref: RefCounted
	var x := 0.0
	var en := 10.0
	var f := 0.0
	const SEPET := 12          # dolgu sepet sepet: f 1/12'lik adımlarla

	func kur(a: RefCounted, p_x: float, p_en: float) -> void:
		a_ref = a
		x = p_x
		en = p_en

	## f: 0 (boş) … 1 (kıyıyla aynı düzde set). Yakın yakadan karşıya doğru dolar: dolu kısım düz, ucu 32° şevle dibe iner.
	func doluluk(p_f: float) -> void:
		f = clampf(p_f, 0.0, 1.0)
		var adim := floorf(f * SEPET + 0.001) / SEPET
		for c in get_children():
			remove_child(c)
			c.queue_free()
		if adim <= 0.0:
			return
		var d: Dictionary = a_ref.d
		var dy: float = a_ref.dy
		var zm0 := float(d["zm0"])
		var zm1 := float(d["zm1"])
		var MD := float(d["MD"])
		var dip := dy - MD
		var plato := zm0 + adim * (zm1 - zm0)
		var sev := MD / tan(deg_to_rad(32.0))
		var pts: Array = [Vector2(zm0 - 1.2, dy + 0.04), Vector2(zm0, dy + 0.02)]
		if adim >= 1.0:
			pts.append(Vector2(zm1, dy + 0.02))
			pts.append(Vector2(zm1 + 1.2, dy + 0.04))
		else:
			pts.append(Vector2(maxf(plato - 0.3, zm0 + 0.1), dy + 0.0))
			pts.append(Vector2(minf(plato + sev, zm1 - 0.05), dip + 0.02 + maxf(0.0, MD - (zm1 - 0.05 - plato) * MD / sev)))
		var rng := RandomNumberGenerator.new()
		rng.seed = int(adim * 100.0) + 3
		var taban := func(z: float) -> float:
			return dip if z > zm0 and z < zm1 else dy
		PARCA_._tumsek(self, x, pts, en, 2.0, taban, C_TOPRAK, "Toprak_DolguSet", rng)
		# dökülmüş sepetler (örgü sepet: silindir, kutu değil) ve bir iki küfe toprak izi
		for i in 3:
			var sz := zm0 - 2.0 - i * 0.7
			var sp := Props.cyl(self, 0.3, 0.42, Vector3(x - en * 0.5 - 1.2 + i * 0.9, dy + 0.1, sz), Color("8a6d40"), Vector3(70.0 if i == 1 else 0.0, 0, 15.0 * i), 9, 0.36)
			sp.name = "Ahsap_Sepet_%d" % i




# ------------------------------------------------------------------ KAPI KÖPRÜSÜ (8y, 26/31o Romanos)

class KapiKopru extends Node3D:
	var saglam: Node3D
	var yikik: Node3D
	var govde: StaticBody3D

	func kur(a: RefCounted) -> void:
		var d: Dictionary = a.d
		var dy: float = a.dy
		var gw := float(a.kesim["kapi"]["gw"])
		var w := gw + 0.6
		var za := float(d["zm0"]) + 4.3
		var zb := float(d["zm1"]) - 4.3
		var y := dy + 0.02
		saglam = Node3D.new()
		saglam.name = "Ahsap_KapiKopruSaglam"
		add_child(saglam)
		var ag = KULE.Ag.new()
		for s in 5:
			var sx := -w * 0.5 + 0.2 + s * (w - 0.4) / 4.0
			ag.kutu(Vector3(sx, y - 0.34, za), Vector3.RIGHT, Vector3.BACK, 0.24, 0.3, zb - za)
		var zz := za
		var i := 0
		while zz < zb - 0.1:
			ag.kutu(Vector3(0, y - 0.05, zz), Vector3.RIGHT, Vector3.BACK, w, 0.07, 0.36, Color(1, 1, 1) if i % 2 == 0 else Color(0.87, 0.83, 0.77))
			zz += 0.39
			i += 1
		for s2: float in [-1.0, 1.0]:
			for t in 4:
				var pz := lerpf(za + 0.3, zb - 0.3, t / 3.0)
				KalasKopru._dikme(ag, Vector3(s2 * (w * 0.5 - 0.1), y, pz), Vector3(s2 * (w * 0.5 - 0.1), y + 1.05, pz), 0.12)
			ag.kutu(Vector3(s2 * (w * 0.5 - 0.1), y + 0.95, za + 0.2), Vector3.RIGHT, Vector3.BACK, 0.1, 0.1, zb - za - 0.4)
		ag.mesh_ekle(saglam, Props.mat(C_WOOD.darkened(0.08), 0.0, false, "wood"), "Ahsap_KapiKopruTahta")
		govde = StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(w, 0.12, zb - za + 0.4)
		cs.shape = bs
		govde.add_child(cs)
		govde.position = Vector3(0, y - 0.06, (za + zb) * 0.5)
		saglam.add_child(govde)
		for s3: float in [-1.0, 1.0]:
			var kor := StaticBody3D.new()
			var kc := CollisionShape3D.new()
			var kbs := BoxShape3D.new()
			kbs.size = Vector3(0.12, 1.0, zb - za)
			kc.shape = kbs
			kor.add_child(kc)
			kor.position = Vector3(s3 * (w * 0.5 - 0.1), y + 0.5, (za + zb) * 0.5)
			saglam.add_child(kor)
		# yıkık hâl: iki uçtan sarkan kırık kalaslar (yalnız görünüm)
		yikik = Node3D.new()
		yikik.name = "Ahsap_KapiKopruYikik"
		add_child(yikik)
		var yag = KULE.Ag.new()
		var rng := RandomNumberGenerator.new()
		rng.seed = 77
		for s4: float in [-1.0, 1.0]:
			var z0 := za if s4 < 0.0 else zb
			for k in 4:
				var x0 := -w * 0.5 + 0.4 + k * (w - 0.8) / 3.0
				var ln := rng.randf_range(1.6, 3.4)
				var dip := Vector3(x0 + rng.randf_range(-0.3, 0.3), y - 0.2 - ln * rng.randf_range(0.5, 0.9), z0 - s4 * ln * 0.5)
				KalasKopru._dikme(yag, Vector3(x0, y - 0.1, z0), dip, 0.22)
		yag.mesh_ekle(yikik, Props.mat(C_WOOD.darkened(0.25), 0.0, false, "wood"), "Ahsap_KapiKopruKirik")

	func hal(h: String) -> void:
		var ok := h == "saglam"
		saglam.visible = ok
		yikik.visible = not ok
		for cs in saglam.find_children("*", "CollisionShape3D", true, false):
			(cs as CollisionShape3D).set_deferred("disabled", not ok)


# ------------------------------------------------------------------ HÜCUM MERDİVENİ (karar 2-A, 3, 8-A)

## Dayama noktasına konan el merdiveni. İçindeki `lad` gerçek `Ladder`: Player.ladder ve climb_anim.attach(who, lad, at)
## onu doğrudan okur (basamak aralığı Ladder.RUNG 0,36, en Ladder.WIDTH 0,8; eğim/boy arayüzden). İtme/devirme bölümlerin
## var olan mantığıyla aynı: Ladder düğümünün rotation.x'i tween'lenir (chapter30.gd _push): it() bunu yapar, isteyen
## bölüm kendi tween'ini de kurabilir.
class HucumMerdiveni extends Node3D:
	var lad: Ladder
	var dayama: Dictionary
	var durum := "dayali"          # dayali | itildi | yerde

	func kur(dm: Dictionary) -> void:
		dayama = dm
		lad = Ladder.new(float(dm["boy"]), float(dm["egim"]), C_WOOD.darkened(0.12))
		lad.name = "Ladder"
		lad.position = dm["ayak"]["yerel"]
		add_child(lad)

	## climb_anim.set_line için genel hat (Ladder yerine düz hat isteyen bölüm): kesim-yerel uçlar
	func cizgi() -> Dictionary:
		var ay: Vector3 = dayama["ayak"]["yerel"]
		var tp: Vector3 = dayama["tepe"]["yerel"]
		return {"dip": ay, "tepe": tp, "on": Vector3.BACK, "ilk_basamak": 0.3, "aralik": Ladder.RUNG, "en": Ladder.WIDTH}

	## Duvardan iter: merdiven arkaya (ovaya) devrilir; süre sn. Bölüm tırmananı climb_anim.release ile ayrıca düşürür.
	func it(sure := 1.0) -> void:
		if durum != "dayali":
			return
		durum = "itildi"
		var tw := create_tween()
		tw.tween_property(lad, "rotation:x", deg_to_rad(70.0), sure).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(func(): durum = "yerde")

	## Anında yere (devrik) — kare/test için
	func devir() -> void:
		lad.rotation.x = deg_to_rad(70.0 + float(dayama["egim"]))
		durum = "yerde"

	func dik() -> void:
		lad.rotation.x = 0.0
		durum = "dayali"


# ------------------------------------------------------------------ GEDİK ONARIMI (karar 4-A, 5-B)

class GedikOnarim extends Node3D:
	var a_ref: RefCounted
	var asama_n := 1
	var _katman: Node3D

	func kur(a: RefCounted) -> void:
		a_ref = a
		var rng := RandomNumberGenerator.new()
		rng.seed = 1453 + int(absf(a.gx))
		var pr := PARCA_.moloz_profil(a)
		var d: Dictionary = a.d
		var zo0 := float(d["zo0"])
		var zo1 := float(d["zo1"])
		var zm0 := float(d["zm0"])
		var zm1 := float(d["zm1"])
		var dy: float = a.dy
		var MD := float(d["MD"])
		var taban := func(z: float) -> float:
			if z < zo0:
				return a.y_peri()
			if z < zo1:
				return 0.0
			if z < zm0:
				return a.y_teras()
			return dy - MD if z < zm1 else dy
		PARCA_._tumsek(self, a.gx, pr["pts"], 6.0, 1.6, taban, C_MOLOZ, "Toprak_GedikMolozRampa", rng)
		# üstte kırık taşlar (kaya ağı; kutu değil)
		var kl: Array = []
		for i in 40:
			var z := rng.randf_range(zo0 - 6.0, zm0 + 10.0)
			var xx: float = a.gx + rng.randf_range(-3.6, 3.6)
			var y := PARCA_._profil_y(pr["pts"], z) - (absf(xx - a.gx) - 3.0) * 0.3 * float(absf(xx - a.gx) > 3.0)
			var sc := rng.randf_range(0.18, 0.55)
			kl.append(Transform3D(Basis.from_euler(Vector3(rng.randf_range(-0.6, 0.6), rng.randf() * TAU, rng.randf_range(-0.6, 0.6))).scaled(Vector3(sc * 1.3, sc * 0.6, sc)), Vector3(xx, y + sc * 0.12, z)))
		Scenery.scatter(self, KULE.kaya_mesh(), kl, [], Props.mat(IstSurlar.C_STONE.darkened(0.14), 0.0, false, "ashlar_far"))
		_katman = Node3D.new()
		_katman.name = "Asama"
		add_child(_katman)

	## 1 açık · 2 kazık/fıçı (ortada geçit) · 3 toprak dolgu (geçit kapalı, 1,3 m set) · 4 barikat tam (kazık çit + sur yolu
	## tahtası: dış sur yolu gedikte birleşir)
	func asama(n_: int) -> void:
		asama_n = clampi(n_, 1, 4)
		a_ref.asama = asama_n
		for c in _katman.get_children():
			_katman.remove_child(c)
			c.queue_free()
		if asama_n <= 1:
			return
		var a = a_ref
		var d: Dictionary = a.d
		var zo0 := float(d["zo0"])
		var zo1 := float(d["zo1"])
		var OH := float(d["OH"])
		var gx: float = a.gx
		var h := IstSurlar.GEDIK_W * 0.5
		var pr: Dictionary = PARCA_.moloz_profil(a)
		var zs := zo0 - 1.4
		var ys := PARCA_._profil_y(pr["pts"], zs)
		var rng := RandomNumberGenerator.new()
		rng.seed = 91 + asama_n
		var bx := gx - h + 0.5
		while bx < gx + h - 0.3:
			var orta := absf(bx - gx) < 1.1
			if not (orta and asama_n == 2):
				IstSurlarAyrinti._barrel(_katman, Vector3(bx, ys - 0.06 - absf(bx - gx) * 0.03, zs + rng.randf_range(-0.12, 0.12)))
			bx += 0.95
		# öne eğik kazıklar (sivri uç ovaya)
		for i in int(IstSurlar.GEDIK_W / 0.5):
			var kx := gx - h + 0.25 + i * 0.5
			if asama_n == 2 and absf(kx - gx) < 1.1:
				continue
			var kz := Props.cyl(_katman, 0.07, 2.2, Vector3(kx, ys + 0.9, zs + 0.75), C_WOOD.darkened(0.2), Vector3(-26.0 + rng.randf_range(-5.0, 5.0), 0, rng.randf_range(-4.0, 4.0)), 6, 0.015)
			kz.name = "Ahsap_Kazik"
		if asama_n >= 3:
			# toprak set (fıçıların arkasında, yuvarlak toprak yığın) ve çarpışma: gediği kapatır
			var tset := Props.ball(_katman, 0.5, Vector3(gx, ys + 0.45, zs - 1.25), C_TOPRAK, Vector3(IstSurlar.GEDIK_W + 0.6, 1.5, 2.4), 10)
			tset.name = "Toprak_GedikSet"
			var b := StaticBody3D.new()
			b.name = "Toprak_GedikSet_Carp"
			var cs := CollisionShape3D.new()
			var bs := BoxShape3D.new()
			bs.size = Vector3(IstSurlar.GEDIK_W + 0.4, 1.4, 1.2)
			cs.shape = bs
			b.add_child(cs)
			b.position = Vector3(gx, ys + 0.6, zs)
			_katman.add_child(b)
		if asama_n >= 4:
			# sur yolu tahtası: sehpalar üstünde, dış sur yolu hizasında (iki yandaki surla birleşir)
			var ag = KULE.Ag.new()
			for sx: float in [-1.0, 0.0, 1.0]:
				var px := gx + sx * (h - 0.8)
				for sz: float in [zo0 + 0.4, zo1 - 0.4]:
					var yb := PARCA_._profil_y(pr["pts"], sz)
					KalasKopru._dikme(ag, Vector3(px, yb - 0.1, sz), Vector3(px, OH - 0.1, sz), 0.18)
				ag.kutu(Vector3(px, OH - 0.32, zo0), Vector3.RIGHT, Vector3.BACK, 0.2, 0.22, zo1 - zo0)
			for i in 9:
				var pz := zo0 + 0.1 + i * (zo1 - zo0 - 0.2) / 9.0
				ag.kutu(Vector3(gx, OH - 0.08, pz), Vector3.RIGHT, Vector3.BACK, IstSurlar.GEDIK_W + 0.6, 0.07, (zo1 - zo0 - 0.2) / 9.0 - 0.02,
					Color(1, 1, 1) if i % 2 == 0 else Color(0.88, 0.84, 0.78))
			# ikinci sıra kazık çit (dış yüzde, insan boyu)
			for i in int(IstSurlar.GEDIK_W / 0.42):
				var kx2 := gx - h + 0.2 + i * 0.42
				KalasKopru._dikme(ag, Vector3(kx2, PARCA_._profil_y(pr["pts"], zo1 - 0.2) - 0.2, zo1 - 0.2), Vector3(kx2 + rng.randf_range(-0.05, 0.05), PARCA_._profil_y(pr["pts"], zo1) + 2.2, zo1 + 0.5), 0.12)
			ag.mesh_ekle(_katman, Props.mat(C_WOOD.darkened(0.12), 0.0, false, "wood"), "Ahsap_GedikTahta")
			for spec in [[Vector3(gx, OH - 0.06, (zo0 + zo1) * 0.5), Vector3(IstSurlar.GEDIK_W + 0.6, 0.12, zo1 - zo0)],
					[Vector3(gx, 1.9, zo1 + 0.1), Vector3(IstSurlar.GEDIK_W, 2.4, 0.4)]]:
				var b2 := StaticBody3D.new()
				var cs2 := CollisionShape3D.new()
				var bs2 := BoxShape3D.new()
				bs2.size = spec[1]
				cs2.shape = bs2
				b2.add_child(cs2)
				b2.position = spec[0]
				_katman.add_child(b2)
