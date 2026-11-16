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
const C_CUVAL := Color("806b4c")
const C_IP := Color("6a5a40")
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
	Props.set_pattern(s, Color("6c6a45"), "grass")
	s.name = "Toprak_ZeminSehir"
	var o0 := zm1 + 0.9
	var o1 := zm1 + 190.0
	var s2 := Props.solid(kok, Vector3(Lt, 2.0, o1 - o0), Vector3(0, a.y_ova() - 1.0, (o0 + o1) * 0.5), Color.WHITE)
	Props.set_pattern(s2, Color("6c6a45"), "grass")
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
					if not bool(a.kesim["kapi"]["kapali"]):
						var kn := KapiKanat.new()
						kn.name = "Ahsap_KapiKanat"
						kn.kur(a)
						p.add_child(kn)
						kn.ac(bool(sec.get("kapi_acik", false)), false)
						out["kapi_kanat"] = kn
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
	for k in ["kalas", "kapi_kopru"]:
		if out.has(k):
			for c in (out[k] as Node3D).get_children():
				if c is Node3D:
					PARCA_.pis(c)
			PARCA_.pis(out[k])
	if out.has("poterna"):
		(out["poterna"] as Poterna).kanat.set_meta("no_bake", true)
		PARCA_.pis(out["poterna"])
	for m in mer:
		PARCA_.pis((m as HucumMerdiveni).lad)
	return out


# ------------------------------------------------------------------ POTERNA (karar 10-A)

class Poterna extends Node3D:
	var kanat: Node3D
	var kanat_govde: StaticBody3D
	var acik := false
	var x := 0.0
	var basamak_uc := Vector3.INF      # dış basamağın teras ucu (yoksa INF)
	var ic := false                    # TAŞIMA-8: iç surun peribolos yüzünde (26: Giustiniani'nin taşındığı kapı)

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
		# dış kuşak aşağıdaysa (dy < 0; Mesoteikhion −3,7 m): kapının önünde taş sahanlık ve sur yüzü boyunca +x'e
		# inen taş basamak (0,26 × 0,32), terasa
		var dis_y: float = a.y_teras()
		if dis_y < -0.3:
			var rise := -0.02 - dis_y
			var nst := ceili(rise / IstSurlar.STEP_RISE)
			var tr := 0.32
			var sw := 1.3
			IstSurlar._s(self, Vector3(x - w * 0.5 - 0.5, dis_y - 0.5, zo1), Vector3(x + w * 0.5 + 0.4, -0.02, zo1 + sw), tas, "flagstone", 0)
			IstSurlar._stairs_x(self, x + w * 0.5 + 0.4 + nst * tr, -1.0, zo1 + sw * 0.5, sw, dis_y, rise, nst, tr, tas, 0)
			basamak_uc = Vector3(x + w * 0.5 + 0.4 + nst * tr + 0.9, dis_y, zo1 + sw * 0.5)
		kanat_govde = StaticBody3D.new()
		var kc := CollisionShape3D.new()
		var kb := BoxShape3D.new()
		kb.size = Vector3(w - 0.06, h, 0.12)
		kc.shape = kb
		kanat_govde.add_child(kc)
		kanat_govde.position = Vector3((w - 0.06) * 0.5, h * 0.5, -0.01)
		kanat.add_child(kanat_govde)

	## TAŞIMA-8 (Bölüm 26, sahibinin kararı: poterna İÇ SURDA, şehre açılan küçük kapı): iç surun peribolos yüzünde (zi1)
	## aynı söve, kemerli alın taşı ve kanat. Sur gövdesi oyulmaz (surlar.gd değişmez): kanadın ardında söve derinliğinde
	## karanlık geçit (kapı aralığı) görünür; kanat peribolosa (+z) açılır. Eşik peribolos toprağıyla aynı düzde, önde.
	## px: kesim-yerel x (SurOyun.ic_poterna). Varsayılan Poterna (kur) hiç değişmez.
	func kur_ic(a: RefCounted, px: float) -> void:
		ic = true
		var d: Dictionary = a.d
		x = px
		var zf := float(d["zi1"])
		var w := IstSurlar.POTERNA_W
		var h := IstSurlar.POTERNA_H
		var tas := IstSurlar.C_STONE.darkened(0.1)
		var ag = KULE.Ag.new()
		# söve (iki yanda çıkıntılı taş pervaz) ve kemerli alın taşı, peribolos yüzünde
		for s: float in [-1.0, 1.0]:
			var sx := x + s * (w * 0.5 + 0.14)
			ag.kutu(Vector3(sx, -0.05, zf), Vector3.RIGHT, Vector3.BACK, 0.28, h + 0.05, 0.16)
		var n := 7
		var r := w * 0.5 + 0.14
		for i in n:
			var a0 := PI * float(i) / n
			var a1 := PI * float(i + 1) / n
			var p0 := Vector3(x + cos(a0) * r, h - 0.35 + sin(a0) * 0.55, zf + 0.17)
			var p1 := Vector3(x + cos(a1) * r, h - 0.35 + sin(a1) * 0.55, zf + 0.17)
			var q0 := Vector3(x + cos(a0) * (r + 0.32), h - 0.35 + sin(a0) * 0.87, zf + 0.17)
			var q1 := Vector3(x + cos(a1) * (r + 0.32), h - 0.35 + sin(a1) * 0.87, zf + 0.17)
			ag.quad(p0, p1, q1, q0, Vector3.BACK, Color(1, 1, 1) if i % 2 == 0 else Color(0.86, 0.82, 0.76))
		# kemerin ardındaki dolgu taşı (söve ile kemer arasındaki yarım ay: duvar yüzü)
		for i in n:
			var a0 := PI * float(i) / n
			var a1 := PI * float(i + 1) / n
			ag.tri(Vector3(x, h - 0.35, zf + 0.012), Vector3(x + cos(a1) * r, h - 0.35 + sin(a1) * 0.55, zf + 0.012),
				Vector3(x + cos(a0) * r, h - 0.35 + sin(a0) * 0.55, zf + 0.012), Vector3.BACK, Color(0.8, 0.76, 0.7))
		# eşik taşı (peribolos toprağıyla aynı düzde, kapının önünde)
		ag.kutu(Vector3(x, -0.12, zf), Vector3.RIGHT, Vector3.BACK, w + 0.3, 0.1, 0.7)
		ag.mesh_ekle(self, KULE._tas_mat(tas, 0), "Tas_PoternaSove")
		# karanlık geçit: kanat açılınca görünen kapı aralığı (sur gövdesinin içi; söve derinliğinde koyu yüz)
		var kag0 = KULE.Ag.new()
		kag0.quad(Vector3(x - w * 0.5, -0.02, zf + 0.008), Vector3(x + w * 0.5, -0.02, zf + 0.008),
			Vector3(x + w * 0.5, h - 0.35, zf + 0.008), Vector3(x - w * 0.5, h - 0.35, zf + 0.008), Vector3.BACK, Color(1, 1, 1))
		kag0.mesh_ekle(self, Props.mat(Color("15110e"), 0.0, false, ""), "Tas_PoternaGecit")
		var esik := StaticBody3D.new()
		esik.name = "Tas_PoternaEsik_Carp"
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(w + 0.3, 0.12, 0.7)
		cs.shape = bs
		esik.add_child(cs)
		esik.position = Vector3(x, -0.08, zf + 0.35)
		add_child(esik)
		# kanat: menteşe söve içinde (x − w/2), duvar yüzünün 0,12 m önünde; peribolosa (+z) açılır
		kanat = Node3D.new()
		kanat.name = "Ahsap_PoternaKanat"
		kanat.position = Vector3(x - w * 0.5 + 0.03, 0.0, zf + 0.125)
		add_child(kanat)
		var kag = KULE.Ag.new()
		var tw := (w - 0.06) / 5.0
		for i in 5:
			var hh := h - 0.4 - (0.1 if i in [0, 4] else 0.0)
			kag.kutu(Vector3(tw * (i + 0.5), 0.0, -0.05), Vector3.RIGHT, Vector3.BACK, tw - 0.012, hh, 0.09, Color(1, 1, 1) if i % 2 == 0 else Color(0.9, 0.87, 0.82))
		kag.mesh_ekle(kanat, Props.mat(C_WOOD.darkened(0.15), 0.0, false, "wood"), "Ahsap_PoternaTahta")
		var dag = KULE.Ag.new()
		for yy: float in [0.35, h - 0.85]:
			dag.kutu(Vector3((w - 0.06) * 0.5, yy, 0.04), Vector3.RIGHT, Vector3.BACK, w - 0.16, 0.07, 0.025)
		dag.mesh_ekle(kanat, Props.mat(Color("3a3634"), 0.0, false, ""), "Demir_PoternaKusak")
		kanat_govde = StaticBody3D.new()
		var kc := CollisionShape3D.new()
		var kb := BoxShape3D.new()
		kb.size = Vector3(w - 0.06, h - 0.4, 0.12)
		kc.shape = kb
		kanat_govde.add_child(kc)
		kanat_govde.position = Vector3((w - 0.06) * 0.5, (h - 0.4) * 0.5, -0.01)
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
		PARCA_.pis(self)




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
		# dış kuşak aşağıdaysa (dy < 0): dış kapı eşiğinden terasa toprak rampa (≈ 21°; köprünün hâlinden bağımsız)
		if a.y_teras() < -0.3:
			var zo1 := float(d["zo1"])
			var rp := [Vector2(zo1 - 0.3, -0.02), Vector2(zo1 + 0.6, -0.04), Vector2(float(d["zm0"]) - 0.9, dy + 0.02), Vector2(float(d["zm0"]) + 0.2, dy + 0.02)]
			var rng0 := RandomNumberGenerator.new()
			rng0.seed = 5
			var tb := func(z: float) -> float:
				return a.y_teras() if z > zo1 else 0.0
			PARCA_._tumsek(self, 0.0, rp, gw + 0.4, 1.4, tb, C_TOPRAK, "Toprak_KapiRampasi", rng0)
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


# ------------------------------------------------------------------ KAPI KANATLARI (26 / 8y / 31o: kapı açılır)

## İç surda ve dış surun geçidinde ikişer kanat (IstSurlarKapi'nin kapalı kanatlarıyla aynı yer ve ölçü: zk = zi0/zo0 + 0,45,
## kalınlık 0,28, boy gh − 0,2); menteşe kenarda, kanat şehir yanına (−z) 95° açılır. Çarpışma kanatla döner.
class KapiKanat extends Node3D:
	var kanatlar: Array = []
	var acik := false

	func kur(a: RefCounted) -> void:
		var d: Dictionary = a.d
		var gw := float(a.kesim["kapi"]["gw"])
		var gh := float(a.kesim["kapi"]["gh"])
		var OH := float(d["OH"])
		for zk: float in [float(d["zi0"]) + 0.45, float(d["zo0"]) + 0.45]:
			var hk := gh - 0.2 if zk < float(d["zi1"]) else minf(gh, OH - 1.0) - 0.2
			for sx: float in [-1.0, 1.0]:
				var mente := Node3D.new()
				mente.position = Vector3(sx * gw * 0.5, 0.0, zk + 0.14)
				mente.set_meta("yon", sx)
				add_child(mente)
				var ag = KULE.Ag.new()
				var w := gw * 0.5
				var n := 4
				for i in n:
					var x0 := -sx * (w * float(i) / n)
					var x1 := -sx * (w * float(i + 1) / n)
					ag.kutu(Vector3((x0 + x1) * 0.5, 0.0, -0.14), Vector3.RIGHT, Vector3.BACK, absf(x1 - x0) - 0.01, hk, 0.28,
						Color(1, 1, 1) if i % 2 == 0 else Color(0.9, 0.86, 0.8))
				ag.mesh_ekle(mente, Props.mat(IstSurlarKapi.C_WOOD, 0.0, false, "wood"), "Ahsap_KanatTahta")
				var dg = KULE.Ag.new()
				for yy: float in [0.7, hk * 0.5, hk - 0.7]:
					dg.kutu(Vector3(-sx * w * 0.5, yy, -0.17), Vector3.RIGHT, Vector3.BACK, w - 0.2, 0.14, 0.03)
				dg.mesh_ekle(mente, Props.mat(IstSurlarKapi.C_IRON, 0.0, false, ""), "Demir_KanatKusak")
				var b := StaticBody3D.new()
				var cs := CollisionShape3D.new()
				var bs := BoxShape3D.new()
				bs.size = Vector3(w, hk, 0.28)
				cs.shape = bs
				b.add_child(cs)
				b.position = Vector3(-sx * w * 0.5, hk * 0.5, 0.0)
				mente.add_child(b)
				kanatlar.append(mente)

	func ac(p_acik: bool, anim := true) -> void:
		acik = p_acik
		for m: Node3D in kanatlar:
			var hedef := deg_to_rad(95.0) * float(m.get_meta("yon")) if acik else 0.0
			if anim and is_inside_tree():
				create_tween().tween_property(m, "rotation:y", hedef, 1.6).set_trans(Tween.TRANS_SINE)
			else:
				m.rotation.y = hedef


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
	## Aşama 4 kazık çitinin dış surun iç yüzünden (zo0) şehir yanına uzaklığı: teslim yerinin (zo0 − 3,2) 2,8 m gerisi. 5,0 iken
	## depodan gelen taşıyıcı şeridi çitin sol ucunu sıyırıyordu (VISAUDIT insolid WallFight carry x −4,1); 6,0 ile uçta 1,7 m açık
	const CIT_Z_PAY := 6.0
	## Toprak dolgu yığınının sırt yüksekliği (moloz profilinin üstü): fıçıların (≈1 m) üstünden görünsün; tepesi eski hapın
	## tepesiyle aynı (≈2,1 m; çarpışma kutusu aynı kaldığı için daha yükseği gedikten geçen düellocuyu daha çok örterdi)
	const YIGIN_H := 1.1
	var a_ref: RefCounted
	var asama_n := 1
	var _katman: Node3D
	## Aşamanın görünen katı gövdeleri (toprak set, kazık çit): kurulurken içinde kalan kişi dışarı alınır
	## (SurSetSahne.set_repair → _kutudan_cikar)
	var _katilar: Array = []

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
			# tümseğin enine kesitiyle (SurOyunAg._tumsek: orta ±1,05 düz, ±3,0'da %35 alçak, ±4,6'da taban). Eskiden orta
			# yükseklik ±3'e dek sürüyordu: yamaçta (sırtla teras arası) yandaki taşlar 0,8 m'ye dek havada (TAŞIMA-6, 37o an_04/05)
			var yc := PARCA_._profil_y(pr["pts"], z)
			var tb: float = taban.call(z)
			var dxk := absf(xx - a.gx)
			var y := yc
			if dxk > 1.05:
				y = lerpf(yc, lerpf(yc, tb, 0.35), clampf((dxk - 1.05) / 1.95, 0.0, 1.0))
			if dxk > 3.0:
				y = lerpf(lerpf(yc, tb, 0.35), tb, clampf((dxk - 3.0) / 1.6, 0.0, 1.0))
			y = maxf(y, tb)
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
		_katilar.clear()
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
			# toprak dolgu (fıçı sırasının ardında, gediğin iç yarısında): sepetle dökülmüş yumrulu toprak yığını, tepesinde ve
			# fıçıların arkasında kum çuvalları, eteğinde taş, içine çakılı kazık ve yatık kütükler. Eskiden tek pürüzsüz hap
			# (Props.ball 8,6 × 1,5 × 2,0; docs/_kanit_ist2_tasima2 an_06). Çarpışma aynı yerde, aynı boyda (aşağıda).
			var zt := zs + 1.05
			var yag = KULE.Ag.new()
			_toprak_yigin(yag, gx - h - 0.15, gx + h + 0.15, zs + 0.1, zs + 2.2, YIGIN_H, pr["pts"], rng)
			yag.mesh_ekle(_katman, Props.mat(C_TOPRAK, 0.0, false, "rubble"), "Toprak_GedikSet")
			# kum çuvalları: dolgun, ağzı bağlı, tuğla dizisi gibi üst üste (üst sıradaki her çuval alttaki iki çuvalın
			# arasına oturur; en alttakiler yığına gömülü). Fıçıların arkasına yaslı duvar (ortada 3 sıra) ve yığının sırtında
			# bir duvar (ortada 2 sıra). Eskiden tek tek basık top (Props.ball): karede "yassı disk/somun" (tasima3 an_06).
			var cag0 = KULE.Ag.new()
			var yf := func(x: float, z: float) -> float:
				return _yigin_y(x, z, gx - h - 0.15, gx + h + 0.15, zs + 0.1, zs + 2.2, YIGIN_H, pr["pts"])
			for duvar: Array in [[zs + 0.6, 3, 2.6], [zs + 1.02, 2, 1.8]]:
				_cuval_duvar(cag0, gx - h + 0.3, gx + h - 0.3, float(duvar[0]), int(duvar[1]), float(duvar[2]), gx, yf, rng)
			cag0.mesh_ekle(_katman, Props.mat(C_CUVAL.lightened(0.18), 0.0, false, "rubble"), "Toprak_Cuval")      # çuval bezi topraktan açık (gece karesinde yığınla karışıyordu)
			# eteğe taşlar (yarı gömülü) ve yığına çakılı kazıklar, yatık kütükler
			var tl: Array = []
			for i in 22:
				var tx := rng.randf_range(gx - h, gx + h)
				var tz := rng.randf_range(zs + 0.15, zs + 2.15)
				var sc := rng.randf_range(0.14, 0.32)
				var ty := _yigin_y(tx, tz, gx - h - 0.15, gx + h + 0.15, zs + 0.1, zs + 2.2, YIGIN_H, pr["pts"])
				tl.append(Transform3D(Basis.from_euler(Vector3(rng.randf_range(-0.5, 0.5), rng.randf() * TAU, rng.randf_range(-0.5, 0.5))).scaled(Vector3(sc * 1.3, sc * 0.7, sc)), Vector3(tx, ty + sc * 0.05, tz)))
			Scenery.scatter(_katman, KULE.kaya_mesh(), tl, [], Props.mat(IstSurlar.C_STONE.darkened(0.2), 0.0, false, "ashlar_far"))
			var kag = KULE.Ag.new()
			for i in 7:
				var kx := gx - h + 0.7 + i * (2.0 * h - 1.4) / 6.0 + rng.randf_range(-0.25, 0.25)
				var kz := zs + rng.randf_range(1.2, 1.9)
				var ky := _yigin_y(kx, kz, gx - h - 0.15, gx + h + 0.15, zs + 0.1, zs + 2.2, YIGIN_H, pr["pts"])
				var boy := rng.randf_range(0.9, 1.5)
				var ust := Vector3(kx + rng.randf_range(-0.25, 0.25), ky + boy, kz + rng.randf_range(0.15, 0.45))
				_kazik(kag, Vector3(kx, ky - 0.3, kz), ust, rng.randf_range(0.06, 0.08), 0.22, C_WOOD.darkened(rng.randf_range(0.05, 0.3)))
			for k in 2:
				var lx := gx + (-2.2 if k == 0 else 1.6) + rng.randf_range(-0.3, 0.3)
				var lz := zs + 1.6
				var ly := _yigin_y(lx, lz, gx - h - 0.15, gx + h + 0.15, zs + 0.1, zs + 2.2, YIGIN_H, pr["pts"])
				_cubuk(kag, Vector3(lx - 1.2, ly + 0.02, lz - 0.2), Vector3(lx + 1.2, ly + 0.18, lz + 0.15), 0.11, 7, C_WOOD.darkened(0.2))
			kag.mesh_ekle(_katman, Props.mat(C_WOOD, 0.0, false, "wood"), "Ahsap_GedikDolguKazik")
			var b := StaticBody3D.new()
			b.name = "Toprak_GedikSet_Carp"
			var cs := CollisionShape3D.new()
			var bs := BoxShape3D.new()
			bs.size = Vector3(IstSurlar.GEDIK_W + 0.4, 1.4, 1.2)
			cs.shape = bs
			b.add_child(cs)
			b.position = Vector3(gx, ys + 0.6, zs)
			# Görünen toprak setin ve fıçı sırasının kutusu: düellocuların giriş seçimi (Melee.auto_entry, Unclip.visible_body)
			# onu görünen bir katı saymalı; yoksa savunanın girişi barikatın arkasından seçiliyor, barikatın içinde kalıyordu
			# (20o =wide: bir savunan z 11,7'de 30 sn; docs/_kanit_ist2_tasima2/rapor.md)
			b.set_meta("wall", true)
			_katman.add_child(b)
			_katilar.append(b)
		if asama_n >= 4:
			# sur yolu tahtası: iki kırık sur ucuna gömülü iki boyuna kiriş (köprü gibi), üstte enine tahtalar; kirişleri sur
			# uçlarından çıkan kısa payandalar taşır. Eskiden molozdan sur
			# yolu hizasına (7 m) çıkan altı dikme ve kirişler: gece karanlık bir iskele gibi okunuyordu (tasima2 an_07).
			var ag = KULE.Ag.new()
			var zk: Array = [zo0 + 0.35, zo1 - 0.35]
			for z: float in zk:
				ag.kutu(Vector3(gx, OH - 0.32, z - 0.12), Vector3.RIGHT, Vector3.BACK, 2.0 * h + 0.9, 0.24, 0.24, Color(0.9, 0.86, 0.8))
				for sx: float in [-1.0, 1.0]:
					# sur ucundan kirişe kısa çapraz payanda (dikme yok: gökyüzüne karşı iskele gibi okunmasın)
					_cubuk(ag, Vector3(gx + sx * (h + 0.05), OH - 1.7, z), Vector3(gx + sx * (h - 1.3), OH - 0.34, z), 0.1, 6, Color(0.95, 0.9, 0.84))
			var tx := gx - h - 0.35
			while tx < gx + h + 0.3:
				var tw := rng.randf_range(0.24, 0.32)
				ag.kutu(Vector3(tx + tw * 0.5, OH - 0.08 + rng.randf_range(-0.012, 0.012), zo0 + 0.08), Vector3.RIGHT, Vector3.BACK, tw, 0.07, zo1 - zo0 - 0.16,
					Color(1, 1, 1) if rng.randf() < 0.5 else Color(0.86, 0.82, 0.76))
				tx += tw + rng.randf_range(0.02, 0.05)
			ag.mesh_ekle(_katman, Props.mat(C_WOOD.darkened(0.12), 0.0, false, "wood"), "Ahsap_GedikTahta")
			# ikinci sıra kazık çit (insan boyu): savunanın ARKASINDA, şehir tarafında (sahibin kararı: "çit oyuncunun arkasına").
			# Eskiden dış yüzdeydi: oyuncuyla saldırganların arasında kalıp görüşü kapatıyor, düelloyu uzatıyordu (Bölüm 20 2. dalga
			# azapları çite çarpıp terasa kayıyordu; 20o =wide 32–41 sn). Şimdi barikat ekibinin (teslim yeri, işçiler) ardında,
			# gedik eni kadar; iki ucu açık (depodan gelen yol ve siperler ucun dışından geçer). Kazıklar yuvarlak, sivri uçlu,
			# boyları ve aralıkları düzensiz, yer yer eğik (ovaya ve yana); iki kuşak iple bağlı (sarkık). Eskiden düz kesitli
			# eşit kazık + iki kalas kuşak: "bahçe çiti" (tasima2 an_07). Çarpışma aynı (aşağıda, 8 × 2,4 × 0,4).
			var cag = KULE.Ag.new()
			var iag = KULE.Ag.new()
			var zc := zo0 - CIT_Z_PAY
			var yc: float = a.y_peri()
			var kaziklar: Array = []
			var kx2 := gx - h + 0.18
			while kx2 < gx + h - 0.12:
				var boy2 := rng.randf_range(1.75, 2.3)
				if rng.randf() < 0.12:
					boy2 = rng.randf_range(1.2, 1.5)          # kısa (kırık/eksik) kazık
				var egx := rng.randf_range(-0.1, 0.1) + (rng.randf_range(-0.16, 0.16) if rng.randf() < 0.25 else 0.0)
				var dip2 := Vector3(kx2, yc - 0.25, zc + rng.randf_range(-0.03, 0.05))
				var ust2 := Vector3(clampf(kx2 + egx * boy2, gx - h + 0.05, gx + h - 0.05), yc + boy2, zc + 0.14 + rng.randf_range(0.0, 0.14))
				_kazik(cag, dip2, ust2, rng.randf_range(0.06, 0.085), rng.randf_range(0.18, 0.28), Color(1, 1, 1).darkened(rng.randf_range(0.0, 0.22)))
				kaziklar.append([dip2, ust2])
				kx2 += rng.randf_range(0.27, 0.4)
			for ky: float in [0.65, 1.45]:
				for i in kaziklar.size() - 1:
					var k0: Array = kaziklar[i]
					var k1: Array = kaziklar[i + 1]
					var h0 := ky + rng.randf_range(-0.05, 0.05)
					var h1 := ky + rng.randf_range(-0.05, 0.05)
					var p0: Vector3 = (k0[0] as Vector3).lerp(k0[1], (h0 + 0.25) / ((k0[1] as Vector3).y - (k0[0] as Vector3).y)) + Vector3(0, 0, -0.07)
					var p1: Vector3 = (k1[0] as Vector3).lerp(k1[1], (h1 + 0.25) / ((k1[1] as Vector3).y - (k1[0] as Vector3).y)) + Vector3(0, 0, -0.07)
					if (k0[1] as Vector3).y < yc + ky + 0.1 or (k1[1] as Vector3).y < yc + ky + 0.1:
						continue                                  # kısa kazığın üstünden ip geçmez
					var orta := (p0 + p1) * 0.5 + Vector3(0, -0.035, 0)
					_cubuk(iag, p0, orta, 0.018, 4, Color(1, 1, 1))
					_cubuk(iag, orta, p1, 0.018, 4, Color(1, 1, 1))
			cag.mesh_ekle(_katman, Props.mat(C_WOOD.lightened(0.08), 0.0, false, "wood"), "Ahsap_GedikCit")
			iag.mesh_ekle(_katman, Props.mat(C_IP, 0.0, false), "Ip_GedikCit")
		PARCA_.pis(_katman)
		if asama_n >= 4:
			for spec in [[Vector3(gx, OH - 0.06, (zo0 + zo1) * 0.5), Vector3(IstSurlar.GEDIK_W + 0.6, 0.12, zo1 - zo0)],
					[Vector3(gx, float(a.y_peri()) + 1.1, zo0 - CIT_Z_PAY + 0.15), Vector3(IstSurlar.GEDIK_W, 2.4, 0.4)]]:
				var b2 := StaticBody3D.new()
				if (spec[1] as Vector3).y > 1.0:
					b2.name = "Ahsap_GedikCit_Carp"
					b2.set_meta("wall", true)     # görünen kazık çitin kutusu (giriş seçimi ve görüş denetimi onu görsün)
					_katilar.append(b2)
				var cs2 := CollisionShape3D.new()
				var bs2 := BoxShape3D.new()
				bs2.size = spec[1]
				cs2.shape = bs2
				b2.add_child(cs2)
				b2.position = spec[0]
				_katman.add_child(b2)

	## Aşamanın görünen katılarının dünya kutuları (AABB). Ağaçta değilse boş.
	func kati_kutular() -> Array:
		var out: Array = []
		for b in _katilar:
			if not is_instance_valid(b) or not (b as Node3D).is_inside_tree():
				continue
			var cs := (b as Node).get_child(0) as CollisionShape3D
			var sz: Vector3 = (cs.shape as BoxShape3D).size
			out.append((b as Node3D).global_transform * AABB(-sz * 0.5, sz))
		return out

	## Toprak dolgu yığını (x0..x1 boyunca, z0..z1 enine): sırtı H, uçlara ve kenarlara yumuşak iner, yüzü yumrulu; renk lekeli.
	static func _toprak_yigin(ag, x0: float, x1: float, z0: float, z1: float, H: float, pts: Array, rng: RandomNumberGenerator) -> void:
		var nx := 18
		var nz := 7
		var rows: Array = []
		for j in nz + 1:
			var row: Array = []
			for i in nx + 1:
				var x := lerpf(x0, x1, float(i) / nx)
				var z := lerpf(z0, z1, float(j) / nz)
				var y := _yigin_y(x, z, x0, x1, z0, z1, H, pts)
				var ic := i > 0 and i < nx and j > 0 and j < nz
				if ic:
					y += rng.randf_range(-0.09, 0.11)
					x += rng.randf_range(-0.07, 0.07)
					z += rng.randf_range(-0.06, 0.06)
				row.append(Vector3(x, y, z))
			rows.append(row)
		for j in nz:
			for i in nx:
				var a: Vector3 = rows[j][i]
				var b: Vector3 = rows[j][i + 1]
				var c: Vector3 = rows[j + 1][i + 1]
				var d: Vector3 = rows[j + 1][i]
				for t in [[a, b, c], [a, c, d]]:
					var nrm: Vector3 = ((t[1] as Vector3) - t[0]).cross((t[2] as Vector3) - t[0])
					if nrm.y < 0.0:
						nrm = -nrm
					var k := rng.randf_range(0.82, 1.1)
					if rng.randf() < 0.12:
						k *= 0.78                                     # ıslak/koyu leke
					ag.tri(t[0], t[1], t[2], nrm, Color(k, k * 0.98, k * 0.94))

	## Yığının (x, z)'deki yüksekliği (gürültüsüz): moloz profili + sırt (enine sin, uçlarda yumuşak iniş)
	static func _yigin_y(x: float, z: float, x0: float, x1: float, z0: float, z1: float, H: float, pts: Array) -> float:
		var yb := PARCA_._profil_y(pts, z) - 0.06
		var t := clampf((z - z0) / (z1 - z0), 0.0, 1.0)
		var u := clampf((x - x0) / (x1 - x0), 0.0, 1.0)
		var uc := smoothstep(0.0, 0.09, minf(u, 1.0 - u))
		return yb + H * pow(sin(PI * t), 0.65) * uc

	## Yuvarlak (çokgen kesitli) kazık, sivri uçlu: a dip, b uç; uc: sivri kısmın boyu
	static func _kazik(ag, a: Vector3, b: Vector3, r: float, uc: float, col: Color) -> void:
		var f := (b - a).normalized()
		var r1 := f.cross(Vector3.FORWARD if absf(f.z) < 0.9 else Vector3.RIGHT).normalized()
		var r2 := f.cross(r1).normalized()
		var m := b - f * uc
		var n := 6
		for i in n:
			var d0 := r1 * cos(TAU * i / n) + r2 * sin(TAU * i / n)
			var d1 := r1 * cos(TAU * (i + 1) / n) + r2 * sin(TAU * (i + 1) / n)
			var dn := (d0 + d1).normalized()
			ag.quad(a + d0 * r, a + d1 * r, m + d1 * r, m + d0 * r, dn, col)
			ag.tri(m + d0 * r, m + d1 * r, b, (dn + f * 0.5).normalized(), col.lightened(0.08))

	## Yuvarlak çubuk (kütük, dikme, ip): a → b, n kenarlı
	static func _cubuk(ag, a: Vector3, b: Vector3, r: float, n: int, col: Color) -> void:
		var f := (b - a).normalized()
		var r1 := f.cross(Vector3.FORWARD if absf(f.z) < 0.9 else Vector3.RIGHT).normalized()
		var r2 := f.cross(r1).normalized()
		for i in n:
			var d0 := r1 * cos(TAU * i / n) + r2 * sin(TAU * i / n)
			var d1 := r1 * cos(TAU * (i + 1) / n) + r2 * sin(TAU * (i + 1) / n)
			ag.quad(a + d0 * r, a + d1 * r, b + d1 * r, b + d0 * r, (d0 + d1).normalized(), col)

	## Çuval duvarı: x0..x1 boyunca z hattında, `kat` sıra; üst sıralar yalnız |x − ox| < yari içinde. Alt sıra yığına gömülür
	## (çuvalın altı, ayak izinin en alçak zemininin 3 cm altında: havada kalmaz); üst sıradaki her çuval alttaki iki komşunun
	## arasına, ikisinin alçak sırtına oturur (tuğla dizisi). yf(x, z): zemin yüksekliği.
	static func _cuval_duvar(ag, x0: float, x1: float, z: float, kat: int, yari: float, ox: float, yf: Callable, rng: RandomNumberGenerator) -> void:
		var L := 0.6
		var alt: Array = []          # [x, üst y]
		var x := x0 + L * 0.5
		while x <= x1 - L * 0.5 + 0.01:
			var cx := x + rng.randf_range(-0.04, 0.04)
			var cz := z + rng.randf_range(-0.06, 0.06)
			var zemin := INF
			for dx: float in [-0.26, 0.0, 0.26]:
				for dz: float in [-0.15, 0.0, 0.15]:
					zemin = minf(zemin, float(yf.call(cx + dx, cz + dz)))
			alt.append([cx, _cuval(ag, Vector3(cx, zemin - 0.03, cz), rng)])
			x += L * rng.randf_range(0.93, 0.99)
		for k in range(1, kat):
			var ust: Array = []
			for i in alt.size() - 1:
				var xa: float = (alt[i][0] + alt[i + 1][0]) * 0.5
				if absf(xa - ox) > yari - 0.05 * k:
					continue
				var taban := minf(float(alt[i][1]), float(alt[i + 1][1])) - 0.05
				ust.append([xa, _cuval(ag, Vector3(xa + rng.randf_range(-0.03, 0.03), taban, z + rng.randf_range(-0.05, 0.05) - 0.03 * k), rng)])
			if ust.size() < 2:
				break
			alt = ust

	## Tek kum çuvalı (yatık, boyu x yönünde ± küçük sapma): alt orta noktası `dip`. Gövde dolgun (süperelips kesit, altı
	## yüküyle basık), uçları dikişli/büzük; bir ucunda iple bağlı ağız ve püskül. Yumuşak normaller. Döner: sırtının y'si.
	static func _cuval(ag, dip: Vector3, rng: RandomNumberGenerator) -> float:
		var L := rng.randf_range(0.56, 0.64) * 0.5
		var W := rng.randf_range(0.34, 0.39) * 0.5
		var H := rng.randf_range(0.21, 0.25) * 0.5
		var yaw := rng.randf_range(-0.14, 0.14)
		var bas := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, rng.randf_range(-0.05, 0.05))
		var yon := 1.0 if rng.randf() < 0.5 else -1.0          # ağzın yanı
		var alt_bas := 0.5                                      # alt yarı yükle basık
		var merkez := dip + Vector3(0, H * alt_bas, 0)
		var renk := Color(1, 1, 1).darkened(rng.randf_range(0.0, 0.22))
		var ns := 8
		var nt := 10
		var nok := func(s: float, t: float) -> Vector3:
			# s ∈ [−1, 1] boyuna, t açısı; f: boy profili (dolgun gövde, uçta büzülür)
			var f := pow(maxf(0.0, 1.0 - pow(absf(s), 3.2)), 0.42)
			var c := cos(t)
			var sn := sin(t)
			var zz := signf(c) * pow(absf(c), 0.7) * W * f
			var yy := signf(sn) * pow(absf(sn), 0.7) * H * f * (1.0 if sn > 0.0 else alt_bas)
			return merkez + bas * Vector3(s * L * yon, yy, zz)
		var nrm := func(s: float, t: float) -> Vector3:
			var e := 0.02
			var du: Vector3 = nok.call(minf(s + e, 1.0), t) - nok.call(maxf(s - e, -1.0), t)
			var dv: Vector3 = nok.call(s, t + e) - nok.call(s, t - e)
			var n := du.cross(dv)
			var dis: Vector3 = nok.call(s, t) - merkez
			if n.dot(dis) < 0.0:
				n = -n
			return n.normalized() if n.length_squared() > 1e-12 else dis.normalized()
		var izgara: Array = []
		for i in ns + 1:
			var s := -0.985 + 1.97 * float(i) / ns
			var sat: Array = []
			for j in nt:
				var t := TAU * float(j) / nt
				sat.append([nok.call(s, t), nrm.call(s, t)])
			izgara.append(sat)
		var ekle := func(v: Array) -> void:
			ag.st.set_color(renk)
			ag.st.set_normal(v[1])
			ag.st.add_vertex(v[0])
		for i in ns:
			for j in nt:
				var a: Array = izgara[i][j]
				var b: Array = izgara[i + 1][j]
				var c2: Array = izgara[i + 1][(j + 1) % nt]
				var d: Array = izgara[i][(j + 1) % nt]
				# sarım: dış normale göre (Ag.tri ile aynı kural)
				var cr: Vector3 = ((b[0] as Vector3) - (a[0] as Vector3)).cross((c2[0] as Vector3) - (a[0] as Vector3))
				var dis: Vector3 = a[1]
				if cr.dot(dis) > 0.0:
					for v in [a, c2, b, a, d, c2]:
						ekle.call(v)
				else:
					for v in [a, b, c2, a, c2, d]:
						ekle.call(v)
				ag.n += 2
		# uç kapakları (dikişli dip ve büzük ağız)
		for uc: int in [0, ns]:
			var sat: Array = izgara[uc]
			var m := Vector3.ZERO
			for v: Array in sat:
				m += v[0]
			m /= float(nt)
			var dis2 := bas * Vector3((1.0 if uc == ns else -1.0) * yon, 0, 0)
			for j in nt:
				ag.tri(sat[j][0], sat[(j + 1) % nt][0], m, dis2, renk)
		# bağlı ağız: büzük boyun (koni), iple sarılı halka, püskül
		var ax := bas * Vector3(yon, 0, 0)
		var agiz := merkez + ax * (L * 0.97) + Vector3(0, H * 0.15, 0)
		var ipr := Color(0.62, 0.54, 0.42)
		_cubuk(ag, agiz - ax * 0.02, agiz + ax * 0.05, 0.045, 6, renk.darkened(0.08))
		_cubuk(ag, agiz + ax * 0.035, agiz + ax * 0.06, 0.05, 6, ipr)
		var pus := agiz + ax * 0.06
		var r1 := ax.cross(Vector3.UP).normalized()
		for j in 6:
			var d0 := r1.rotated(ax, TAU * j / 6.0)
			var d1 := r1.rotated(ax, TAU * (j + 1) / 6.0)
			ag.tri(pus + d0 * 0.02, pus + d1 * 0.02, pus + ax * 0.07 + (d0 + d1) * 0.04 + Vector3(0, -0.02, 0), (d0 + d1).normalized(), renk.darkened(0.12))
		return merkez.y + H * 0.92
