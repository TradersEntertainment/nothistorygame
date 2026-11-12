extends RefCounted
## DURUŞ takımı (ortak): oturma, diz çökme, çömelme, uzanma ve iş duruşları EKLEM AÇILARIYLA kurulur. Kişinin kökü
## (Person/Soldier düğümü) hiç yatırılmaz; gövde (Rig.body) KALÇA çevresinde bükülür, bacaklar kalçadan, kollar
## omuzdan iki kemikli IK ile hedef noktalara (ayak bileği, avuç) uzanır. Böylece:
##   - bel bükülürken bacaklar dünyada yerinde kalır (eskiden bacaklar gövdenin çocuğu olduğundan gövde eğilince
##     ayaklar da kalkıyor, kişi "devrilmiş kukla" gibi bütün hâlde yatıyordu: Rig "doze", "stir", "dig");
##   - ayak, diz, kalça ve dirsek zemine DEĞER: hedefler kökün zeminine (y = 0) göre verilir;
##   - kaftan eteği oturuşta gövdenin içinden bacaklara/zemine girmez: eteğin kalça altındaki kısmı kucağa yayılır.
## Kullanım: rig.activity = "bagdas" (Person/Soldier/Crowd pişirmesi aynı); adlar ADLAR'da. Rig bu adları görünce
## kendi eski işlerine (sit_ground, doze, stir…) dokunmadan bu takımı çağırır (eski adların davranışı değişmez).
## Denetim (POSEAUDIT, susturulamaz): duruş yerine oturunca gövdenin en alçak noktası kökün zeminine göre ±6 cm
## dışındaysa `POSEAUDIT ground <kişi> <duruş> <cm>` yazılır.

## ad → [tür, açıklama]. tür: "otur" (yerde/kütükte), "yat", "is" (ayakta iş)
const ADLAR := {
	"bagdas": ["otur", "yerde bağdaş kurmuş, eller dizlerde"],
	"bagdas_ye": ["otur", "bağdaş, sol elde kâse, sağ el ağzına gider gelir (yemek)"],
	"bagdas_bile": ["otur", "bağdaş, kılıç kucakta, sağ elde bileği taşı"],
	"bagdas_ok": ["otur", "bağdaş, ok gövdesini yontar"],
	"bagdas_yaz": ["otur", "bağdaş, kucakta kâğıt, yazar"],
	"bagdas_ekmek": ["otur", "bağdaş, iki elle ekmek böler"],
	"diz_ustu": ["otur", "diz üstü (teşehhüd/namaz oturuşu), eller uyluklarda"],
	"ates_ufle": ["otur", "diz üstü, öne eğik ateşe üfler"],
	"comel": ["otur", "çömelmiş: topuklar yerde, dizler göğüste, kollar dizlerde"],
	"tek_diz": ["otur", "tek diz üstünde çökmüş"],
	"yan_uzan": ["yat", "yan uzanmış, bir dirseğe dayalı, bacaklar hafif bükük"],
	"sirt_uzan": ["yat", "sırtüstü yatıyor (uyuyan), baş altında bohça"],
	"otur_kutuk": ["otur", "kütüğe oturmuş"],
	"otur_sandik": ["otur", "sandığa oturmuş"],
	"otur_eyer": ["otur", "yere konmuş eyere oturmuş"],
	"sirt_dayali": ["otur", "yerde, sırtını yük denginine dayamış, dizler yukarıda"],
	"kazan_kar": ["is", "ocağa eğilip kazan karıştırır (bel bükük, ayaklar yerde)"],
	"odun_at": ["is", "eğilip ateşe odun atar"],
	"balta": ["is", "baltayla odun yarar (dizler hafif bükük, belden eğik)"],
	"kazma": ["is", "kürekle kazar (dizler bükük, belden eğik; kollar küreği tutar)"],
	"yuk_kaldir": ["is", "dizleri bükerek yük kaldırır, sırt düz"],
	"su_ic": ["is", "ayakta, maşrapadan su içer"],
	"at_timar": ["is", "ayakta at tımar eder (fırçayla)"],
	"otur_tabure": ["otur", "tabureye oturmuş (tabure sahnenin; oturak yüksekliği 0,43 m)"],
	"camasir": ["is", "ayakta leğene eğilmiş çamaşır yıkar (leğen sahnenin, ağzı 0,8 m)"],
	"bagdas_olta": ["otur", "bağdaş kurmuş, sağ elde olta (olta sahnenin)"],
	"tas_kir": ["otur", "tek diz üstünde, tokmakla yerdeki taşı kırar"],
}

const _ETEK_KEY := "durus_etek0"
static var _etek_cache := {}


static func var_mi(ad: String) -> bool:
	return ADLAR.has(ad)


static func tur(ad: String) -> String:
	return String((ADLAR.get(ad, ["", ""]) as Array)[0])


## Her karede (Rig._update_core). Hedef duruşu hesaplar ve eklemleri ona doğru yumuşakça götürür (ayaktan oturuşa
## ~0,7 sn). Kişinin kökü döndürülmez.
static func uygula(rg: Rig, delta: float, talking: bool) -> void:
	var st: Dictionary = rg._durus
	var ad := rg.activity
	if String(st.get("ad", "")) != ad:
		_props_sil(rg)
		st.clear()
		st["ad"] = ad
		st["t"] = 0.0
		st["denet"] = false
	st["t"] = float(st["t"]) + delta
	var h := _hedef(rg, ad, rg._t, talking)
	var kb := clampf(1.0 - exp(-delta * 4.6), 0.0, 1.0)
	if float(st["t"]) > 3.0:
		kb = clampf(1.0 - exp(-delta * 14.0), 0.0, 1.0)       # oturduktan sonra canlılık hareketi geç kalmasın
	_uygula_hedef(rg, h, kb)
	_etek(rg, bool(h.get("etek", false)), delta)
	_props(rg, ad, h)
	if not bool(st["denet"]) and float(st["t"]) > 2.2:
		st["denet"] = true
		_zemin_denet(rg, ad)


## Duruştan çıkınca (activity başka bir şey oldu): eklemlerin y/z artıkları ve gövdenin x/z kayması sıfıra döner,
## etek ve eşyalar kalkar. Rig'in kendi işleri yalnız x eksenini yazdığından bu adım gerekli.
static func birak(rg: Rig, delta: float) -> void:
	var st: Dictionary = rg._durus
	if not st.has("cik"):
		_props_sil(rg)
		_etek(rg, false)
		st["cik"] = 0.0
	st["cik"] = float(st["cik"]) + delta
	var k := clampf(delta * 6.0, 0.0, 1.0)
	for n: Node3D in [rg.leg_l, rg.leg_r, rg.knee_l, rg.knee_r, rg.arm_l, rg.arm_r, rg.elbow_l, rg.elbow_r]:
		if n:
			var r := n.rotation
			n.rotation = Vector3(r.x, lerpf(r.y, 0.0, k), lerpf(r.z, 0.0, k) if n == rg.knee_l or n == rg.knee_r or n == rg.elbow_l or n == rg.elbow_r else r.z)
	if rg.body:
		rg.body.position = Vector3(lerpf(rg.body.position.x, 0.0, k), rg.body.position.y, lerpf(rg.body.position.z, 0.0, k))
		rg.body.rotation = Vector3(rg.body.rotation.x, lerpf(rg.body.rotation.y, 0.0, k), rg.body.rotation.z)
	for side in 2:
		var an: Node3D = rg._ankles[side]
		if an:
			an.rotation = an.rotation.lerp(Vector3(an.rotation.x, 0, 0), k)
	if float(st["cik"]) > 1.2:
		st.clear()


## Ayak bilekleri: Rig.extremities() x açısıyla düzlüyor; bu takımda bacak tam dönüşle kurulduğundan taban yönü
## hedeften yazılır (extremities'ten sonra çağrılır).
static func bilekler(rg: Rig) -> void:
	var st: Dictionary = rg._durus
	var tb: Array = st.get("taban_q", [])
	if tb.size() < 2:
		return
	# extremities() bileği her karede kendi açısına yazar: takımın bilek açısı ayrıca tutulur ve oradan hedefe gider
	# (yoksa her kare extremities'in açısından küçük bir adım atılır, taban hedefe hiç oturmaz: ayak ucu zemine gömülür)
	var cur: Array = st.get("bilek_q", [])
	if cur.size() < 2:
		cur = [null, null]
	for side in 2:
		var an: Node3D = rg._ankles[side]
		if an and tb[side] is Quaternion:
			var q0: Quaternion = cur[side] if cur[side] is Quaternion else an.quaternion
			cur[side] = q0.slerp(tb[side], clampf(float(st.get("kb", 1.0)), 0.0, 1.0))
			an.quaternion = cur[side]
			rg._ank_v[side] = 99.0      # çıkışta extremities yeniden yazsın
	st["bilek_q"] = cur


# ---------------------------------------------------------------- duruş hedefleri (kökün yereli, +z ön, zemin y = 0)

## İki yanlı simetrik nokta: v sağ yan (x > 0) için verilir, sol yan aynalanır. Dizi sırası Rig'deki gibi [_l, _r]
## (leg_l x < 0).
static func _s(v: Vector3) -> Array:
	return [Vector3(-v.x, v.y, v.z), v]


static func _hedef(rg: Rig, ad: String, t: float, talking: bool) -> Dictionary:
	var br := sin(t * 1.55)                         # nefes
	var sh := sin(t * 0.43) + 0.35 * sin(t * 0.17 + 1.3)   # ağırlık değiştirme
	var look := _bakis(rg, t, talking)
	var h := {"P": Vector3(0, 0.2, 0), "bel": 0.0, "yan": 0.0, "don": 0.0,
		"ayak": _s(Vector3(0.16, 0.077, 0.1)), "diz": _s(Vector3(0.3, 0.2, 1.0)),
		"taban": [[Vector3(0, 0, 1), Vector3.UP], [Vector3(0, 0, 1), Vector3.UP]],
		"el": [null, null], "dirsek": _s(Vector3(0.7, -0.4, -0.6)), "bas": look, "etek": true}
	match ad:
		"bagdas", "bagdas_ye", "bagdas_bile", "bagdas_ok", "bagdas_yaz", "bagdas_ekmek":
			h["P"] = Vector3(0, 0.2, -0.04 + br * 0.003)
			h["bel"] = 0.08 + br * 0.018
			h["ayak"] = [Vector3(-0.07, 0.085, 0.2), Vector3(0.07, 0.075, 0.12)]
			h["diz"] = _s(Vector3(1.0, 0.25, 0.55))
			h["taban"] = [[Vector3(0.75, -0.1, 0.65), Vector3(-0.45, 0.85, 0.1)], [Vector3(-0.75, -0.1, 0.65), Vector3(0.45, 0.85, 0.1)]]
			h["el"] = _s(Vector3(0.27, 0.27, 0.2))
			h["dirsek"] = _s(Vector3(1.0, -0.3, -0.5))
			h["etek"] = true
			match ad:
				"bagdas_ye":
					var ph := fmod(t * 0.23, 1.0)
					var up := smoothstep(0.45, 0.6, ph) * (1.0 - smoothstep(0.75, 0.9, ph))
					h["el"] = [Vector3(-0.05, 0.42, 0.3), Vector3(0.04, 0.46, 0.3).lerp(Vector3(0.05, 0.98, 0.2), up)]
					h["dirsek"] = [Vector3(-1, -0.6, -0.3), Vector3(1, -0.8, -0.2)]
					h["bas"] = Vector3(0.32 - up * 0.25, look.y * 0.4, 0)
				"bagdas_bile":
					var ph := sin(t * 2.4)
					h["el"] = [Vector3(-0.24, 0.36, 0.3), Vector3(0.02 + ph * 0.13, 0.42, 0.31)]
					h["dirsek"] = [Vector3(-1, -0.6, -0.4), Vector3(1, -0.6, -0.4)]
					h["bas"] = Vector3(0.45, -0.1 + look.y * 0.2, 0)
					h["bel"] = 0.2 + br * 0.015
				"bagdas_ok":
					var ph := fmod(t * 0.8, 1.0)
					h["el"] = [Vector3(-0.1, 0.44, 0.3), Vector3(0.05 + ph * 0.1, 0.45, 0.31)]
					h["dirsek"] = [Vector3(-1, -0.6, -0.4), Vector3(1, -0.6, -0.4)]
					h["bas"] = Vector3(0.42, look.y * 0.2, 0)
					h["bel"] = 0.18 + br * 0.015
				"bagdas_yaz":
					h["el"] = [Vector3(-0.1, 0.37, 0.3), Vector3(0.05 + sin(t * 3.0) * 0.03, 0.38 + absf(sin(t * 9.0)) * 0.01, 0.31 + sin(t * 1.1) * 0.03)]
					h["dirsek"] = [Vector3(-1, -0.6, -0.4), Vector3(1, -0.6, -0.4)]
					h["bas"] = Vector3(0.5, look.y * 0.15, 0)
					h["bel"] = 0.22 + br * 0.015
				"bagdas_olta":
					h["el"] = [Vector3(-0.2, 0.3, 0.2), Vector3(0.1, 0.5 + sin(t * 0.7) * 0.02, 0.36)]
					h["dirsek"] = [Vector3(-1, -0.4, -0.4), Vector3(1, -0.8, -0.2)]
					h["bas"] = Vector3(0.0 + look.x * 0.3, look.y * 0.4, 0)
				"bagdas_ekmek":
					var ph := 0.5 + 0.5 * sin(t * 0.9)
					h["el"] = [Vector3(-0.06 - ph * 0.08, 0.46, 0.3), Vector3(0.06 + ph * 0.08, 0.46, 0.3)]
					h["dirsek"] = [Vector3(-1, -0.6, -0.4), Vector3(1, -0.6, -0.4)]
					h["bas"] = Vector3(0.38, look.y * 0.3, 0)
		"tas_kir":
			var ph := fmod(t * 1.1, 1.0)
			var up := smoothstep(0.0, 0.65, ph) if ph < 0.65 else 1.0 - smoothstep(0.65, 0.78, ph)
			h["P"] = Vector3(0, 0.43, -0.02)
			h["bel"] = 0.35 - up * 0.12
			h["ayak"] = [Vector3(-0.12, 0.155, -0.33), Vector3(0.17, 0.077, 0.3)]
			h["diz"] = [Vector3(0, -1.0, 0.35), Vector3(0.3, 0.5, 1.0)]
			h["taban"] = [[Vector3(0, -0.75, 0.6), Vector3(0, 0.6, 0.75)], [Vector3(0.1, 0, 1), Vector3.UP]]
			h["el"] = [Vector3(-0.12, 0.42, 0.42), Vector3(0.08, 0.3 + up * 0.62, 0.62 - up * 0.2)]
			h["dirsek"] = [Vector3(-0.8, -0.4, -0.4), Vector3(0.9, -0.6, -0.3)]
			h["bas"] = Vector3(0.38, 0, 0)
			h["etek"] = true
		"diz_ustu":
			h["P"] = Vector3(0, 0.33 + br * 0.004, -0.06)
			h["bel"] = 0.05 + br * 0.015
			h["ayak"] = _s(Vector3(0.09, 0.075, -0.1))
			h["diz"] = _s(Vector3(0.12, -0.25, 1.0))
			h["taban"] = [[Vector3(0, -0.45, -1), Vector3(0, -1, 0)], [Vector3(0, -0.45, -1), Vector3(0, -1, 0)]]
			h["el"] = _s(Vector3(0.13, 0.32, 0.2))
			h["dirsek"] = _s(Vector3(0.8, -0.3, -0.6))
			h["bas"] = Vector3(0.18 + look.x * 0.3, look.y * 0.5, 0)
			h["etek"] = true
		"ates_ufle":
			var blow := smoothstep(0.55, 0.7, fmod(t * 0.4, 1.0)) * (1.0 - smoothstep(0.8, 0.98, fmod(t * 0.4, 1.0)))
			h["P"] = Vector3(0, 0.4, -0.02)
			h["bel"] = 0.74 + blow * 0.12
			h["ayak"] = _s(Vector3(0.11, 0.095, -0.24))
			h["diz"] = _s(Vector3(0.15, -0.6, 1.0))
			h["taban"] = [[Vector3(0, -0.45, -1), Vector3(0, -1, 0)], [Vector3(0, -0.45, -1), Vector3(0, -1, 0)]]
			h["el"] = _s(Vector3(0.2, 0.27, 0.42 + blow * 0.04))
			h["dirsek"] = _s(Vector3(1.0, 0.2, -0.3))
			h["bas"] = Vector3(-0.35 - blow * 0.1, 0, 0)
			h["etek"] = true
		"comel":
			h["P"] = Vector3(sh * 0.01, 0.34 + br * 0.004, -0.08)
			h["bel"] = 0.32 + br * 0.015
			h["ayak"] = _s(Vector3(0.17, 0.077, 0.08))
			h["diz"] = _s(Vector3(0.45, 0.3, 1.0))
			h["taban"] = [[Vector3(-0.2, 0, 1), Vector3.UP], [Vector3(0.2, 0, 1), Vector3.UP]]
			h["el"] = _s(Vector3(0.12, 0.38, 0.44))
			h["dirsek"] = _s(Vector3(0.8, -0.2, -0.3))
			h["bas"] = Vector3(-0.18 + look.x * 0.3, look.y, 0)
			h["etek"] = true
		"tek_diz":
			h["P"] = Vector3(0, 0.43 + br * 0.004, -0.02)
			h["bel"] = 0.08 + br * 0.015
			h["ayak"] = [Vector3(-0.12, 0.155, -0.33), Vector3(0.15, 0.077, 0.3)]
			h["diz"] = [Vector3(0, -1.0, 0.35), Vector3(0.1, 0.5, 1.0)]
			h["taban"] = [[Vector3(0, -0.75, 0.6), Vector3(0, 0.6, 0.75)], [Vector3(0.1, 0, 1), Vector3.UP]]
			h["el"] = [Vector3(-0.15, 0.4, 0.15), Vector3(0.14, 0.55, 0.3)]
			h["dirsek"] = _s(Vector3(0.8, -0.4, -0.4))
			h["etek"] = true
		"yan_uzan":
			h["P"] = Vector3(0.06, 0.27, 0.0)
			h["yan"] = 0.95 + br * 0.01
			h["ayak"] = [Vector3(0.68, 0.085, 0.02), Vector3(0.55, 0.2, 0.24)]
			h["diz"] = [Vector3(0, 0.1, 1.0), Vector3(0, 0.2, 1.0)]
			h["taban"] = [[Vector3(0.95, 0, 0.3), Vector3(0, 0.6, -0.8)], [Vector3(0.9, 0, 0.4), Vector3(0, 0.8, -0.6)]]
			h["el"] = [Vector3(-0.6, 0.06, 0.3), Vector3(0.05, 0.42, 0.18)]
			h["dirsek"] = [Vector3(-0.1, -1.0, -0.2), Vector3(0.3, 0.6, 0.6)]
			h["bas"] = Vector3(0.05, look.y * 0.5, -0.55)
		"sirt_uzan":
			h["P"] = Vector3(0, 0.29 + br * 0.006, 0.0)
			h["bel"] = -PI * 0.5
			h["ayak"] = _s(Vector3(0.17, 0.115, 0.55))
			h["diz"] = _s(Vector3(0.2, 1.0, 0.1))
			h["taban"] = [[Vector3(-0.3, 1, 0.1), Vector3(0, 0, -1)], [Vector3(0.3, 1, 0.1), Vector3(0, 0, -1)]]
			h["el"] = _s(Vector3(0.1, 0.52 + br * 0.008, -0.3))
			h["dirsek"] = _s(Vector3(1.0, -0.4, 0.0))
			h["bas"] = Vector3(0.38, 0.25, 0)
		"otur_kutuk", "otur_sandik", "otur_eyer", "otur_tabure":
			var y := {"otur_kutuk": 0.5, "otur_sandik": 0.52, "otur_eyer": 0.4, "otur_tabure": 0.51}.get(ad, 0.5) as float
			h["P"] = Vector3(sh * 0.006, y + br * 0.004, -0.06)
			h["bel"] = 0.1 + br * 0.015
			h["ayak"] = _s(Vector3(0.17, 0.077, 0.34 if y > 0.45 else 0.42))
			h["diz"] = _s(Vector3(0.2, 0.5, 1.0))
			h["taban"] = [[Vector3(-0.1, 0, 1), Vector3.UP], [Vector3(0.1, 0, 1), Vector3.UP]]
			h["el"] = _s(Vector3(0.16, y + 0.07, 0.24))
			h["dirsek"] = _s(Vector3(0.9, -0.3, -0.5))
			h["etek"] = true
		"sirt_dayali":
			h["P"] = Vector3(0, 0.2 + br * 0.003, -0.04)
			h["bel"] = -0.36 + br * 0.012
			h["ayak"] = _s(Vector3(0.17, 0.077, 0.44))
			h["diz"] = _s(Vector3(0.3, 1.0, 0.4))
			h["taban"] = [[Vector3(-0.15, 0, 1), Vector3.UP], [Vector3(0.15, 0, 1), Vector3.UP]]
			h["el"] = _s(Vector3(0.15, 0.4, 0.26))
			h["dirsek"] = _s(Vector3(0.9, -0.4, -0.4))
			h["bas"] = Vector3(0.22 + look.x * 0.3, look.y, 0)
			h["etek"] = true
		"kazan_kar":
			var w := t * 2.6
			h["P"] = Vector3(sh * 0.012, 0.63, -0.14)
			h["bel"] = 0.42 + sin(w) * 0.04
			h["ayak"] = [Vector3(-0.17, 0.077, -0.06), Vector3(0.18, 0.077, 0.12)]
			h["diz"] = _s(Vector3(0.15, 0.0, 1.0))
			h["taban"] = [[Vector3(-0.25, 0, 1), Vector3.UP], [Vector3(0.1, 0, 1), Vector3.UP]]
			h["el"] = [Vector3(-0.16, 0.55, 0.24), Vector3(0.06 + cos(w) * 0.09, 0.86, 0.5 + sin(w) * 0.07)]
			h["dirsek"] = [Vector3(-1.0, -0.2, -0.5), Vector3(1.0, -0.5, -0.4)]
			h["bas"] = Vector3(0.1, look.y * 0.3, 0)
		"odun_at":
			var ph := fmod(t * 0.32, 1.0)
			var sw := smoothstep(0.0, 0.55, ph) * (1.0 - smoothstep(0.72, 1.0, ph))   # öne savurur, geri alır
			h["P"] = Vector3(0, 0.6 - sw * 0.03, -0.12 + sw * 0.05)
			h["bel"] = 0.62 - sw * 0.22
			h["ayak"] = [Vector3(-0.17, 0.077, -0.04), Vector3(0.18, 0.077, 0.16)]
			h["diz"] = _s(Vector3(0.15, 0.0, 1.0))
			h["taban"] = [[Vector3(-0.2, 0, 1), Vector3.UP], [Vector3(0.1, 0, 1), Vector3.UP]]
			h["el"] = _s(Vector3(0.15, 0.5 + sw * 0.32, 0.44 + sw * 0.16))
			h["dirsek"] = _s(Vector3(0.8, -0.5, -0.3))
			h["bas"] = Vector3(-0.15, 0, 0)
		"balta":
			var ph := fmod(t * 0.9, 1.0)
			var up := smoothstep(0.0, 0.6, ph) if ph < 0.6 else 1.0 - smoothstep(0.6, 0.75, ph)
			h["P"] = Vector3(0, 0.62 + up * 0.03, -0.08)
			h["bel"] = 0.32 - up * 0.3
			h["ayak"] = [Vector3(-0.2, 0.077, 0.08), Vector3(0.2, 0.077, -0.04)]
			h["diz"] = _s(Vector3(0.2, 0.0, 1.0))
			h["taban"] = [[Vector3(-0.25, 0, 1), Vector3.UP], [Vector3(0.25, 0, 1), Vector3.UP]]
			h["el"] = [Vector3(-0.02, 0.62 + up * 0.95, 0.42 - up * 0.25), Vector3(0.06, 0.66 + up * 0.95, 0.44 - up * 0.25)]
			h["dirsek"] = _s(Vector3(0.9, -0.6, -0.3))
			h["bas"] = Vector3(0.2 - up * 0.15, 0, 0)
		"kazma":
			var ph := fmod(t * 0.45, 1.0)
			var push := smoothstep(0.0, 0.3, ph) * (1.0 - smoothstep(0.42, 0.62, ph))
			h["P"] = Vector3(0, 0.6 - push * 0.05, -0.08)
			h["bel"] = 0.3 + push * 0.15
			h["ayak"] = [Vector3(-0.18, 0.077, 0.18), Vector3(0.18, 0.077, -0.1)]
			h["diz"] = _s(Vector3(0.2, 0.0, 1.0))
			h["taban"] = [[Vector3(-0.1, 0, 1), Vector3.UP], [Vector3(0.3, 0, 1), Vector3.UP]]
			h["el"] = [Vector3(-0.05, 0.75, 0.45), Vector3(0.05, 1.0, 0.3)]
			h["bas"] = Vector3(0.25, 0, 0)
		"yuk_kaldir":
			var ph := fmod(t * 0.22, 1.0)
			var lift := smoothstep(0.2, 0.5, ph) * (1.0 - smoothstep(0.7, 0.95, ph))
			h["P"] = Vector3(0, lerpf(0.4, 0.62, lift), -0.12)
			h["bel"] = lerpf(0.5, 0.18, lift)
			h["ayak"] = _s(Vector3(0.21, 0.077, 0.04))
			h["diz"] = _s(Vector3(0.5, 0.2, 1.0))
			h["taban"] = [[Vector3(-0.3, 0, 1), Vector3.UP], [Vector3(0.3, 0, 1), Vector3.UP]]
			h["el"] = _s(Vector3(0.19, 0.28 + lift * 0.3, 0.38 - lift * 0.08))
			h["dirsek"] = _s(Vector3(1.0, -0.3, -0.2))
			h["bas"] = Vector3(-0.2 + lift * 0.15, 0, 0)
			h["yuk"] = lift
		"su_ic":
			var ph := fmod(t * 0.2, 1.0)
			var up := smoothstep(0.35, 0.5, ph) * (1.0 - smoothstep(0.75, 0.9, ph))
			h["P"] = Vector3(sh * 0.025, 0.675 + br * 0.004, 0)
			h["bel"] = -up * 0.06
			h["ayak"] = _s(Vector3(0.13, 0.077, 0.02))
			h["diz"] = _s(Vector3(0.1, 0.0, 1.0))
			h["taban"] = [[Vector3(-0.15, 0, 1), Vector3.UP], [Vector3(0.15, 0, 1), Vector3.UP]]
			h["el"] = [null, Vector3(0.1, 1.02, 0.27).lerp(Vector3(0.04, 1.43, 0.2), up)]
			h["dirsek"] = [Vector3(-0.5, -1, -0.5), Vector3(1.0, -0.6, -0.2)]
			h["bas"] = Vector3(-up * 0.4 + (1.0 - up) * look.x, (1.0 - up) * look.y, 0)
		"camasir":
			var w := t * 3.2
			h["P"] = Vector3(sh * 0.01, 0.64, -0.12)
			h["bel"] = 0.5 + sin(w) * 0.03
			h["ayak"] = [Vector3(-0.18, 0.077, -0.02), Vector3(0.18, 0.077, 0.06)]
			h["diz"] = _s(Vector3(0.15, 0.0, 1.0))
			h["taban"] = [[Vector3(-0.2, 0, 1), Vector3.UP], [Vector3(0.2, 0, 1), Vector3.UP]]
			h["el"] = [Vector3(-0.1 + sin(w) * 0.06, 0.84, 0.5 + cos(w) * 0.04), Vector3(0.1 - sin(w) * 0.06, 0.84, 0.5 - cos(w) * 0.04)]
			h["dirsek"] = _s(Vector3(0.9, -0.5, -0.3))
			h["bas"] = Vector3(0.15, 0, 0)
		"at_timar":
			var w := sin(t * 2.2)
			h["P"] = Vector3(sh * 0.02, 0.665, -0.02)
			h["bel"] = 0.06 + br * 0.01
			h["ayak"] = [Vector3(-0.16, 0.077, -0.04), Vector3(0.15, 0.077, 0.1)]
			h["diz"] = _s(Vector3(0.1, 0.0, 1.0))
			h["taban"] = [[Vector3(-0.2, 0, 1), Vector3.UP], [Vector3(0.1, 0, 1), Vector3.UP]]
			h["el"] = [Vector3(-0.2, 1.14, 0.48), Vector3(0.08 + w * 0.2, 1.1 + cos(t * 2.2) * 0.05, 0.5)]
			h["dirsek"] = [Vector3(-1, -0.6, -0.2), Vector3(1, -0.7, -0.2)]
			h["bas"] = Vector3(0.1, 0.1 + w * 0.1, 0)
	return h


## Baş: ara sıra çevresine bakar (Rig'in bakınma zamanlayıcısıyla); konuşurken hafif başını sallar
static func _bakis(rg: Rig, t: float, talking: bool) -> Vector3:
	if talking:
		return Vector3(sin(t * 5.2) * 0.06, sin(t * 1.3) * 0.12, 0)
	rg._look_t -= 0.016
	if rg._look_t <= 0.0:
		rg._look_t = randf_range(2.5, 6.0)
		rg._look_yaw = randf_range(-0.5, 0.5) if randf() < 0.6 else 0.0
		rg._look_pitch = randf_range(-0.1, 0.12)
	return Vector3(rg._look_pitch, rg._look_yaw, 0)


# ---------------------------------------------------------------- çözüm: gövde + iki kemikli IK

static func _uygula_hedef(rg: Rig, h: Dictionary, kb: float) -> void:
	var body := rg.body
	if body == null or rg.leg_l == null or rg.leg_r == null:
		return
	rg._durus["kb"] = kb
	var hip0 := (rg.leg_l.position + rg.leg_r.position) * 0.5
	var bb := Basis(Vector3.UP, float(h["don"])) * Basis(Vector3.RIGHT, float(h["bel"])) * Basis(Vector3.BACK, float(h["yan"]))
	var bpos: Vector3 = h["P"] - bb * hip0
	var bxf := Transform3D(bb, bpos)
	body.quaternion = body.quaternion.slerp(bb.get_rotation_quaternion(), kb)
	body.position = body.position.lerp(bpos, kb)
	var bi := bb.inverse()
	var tq: Array = [null, null]
	for side in 2:
		var leg: Node3D = rg.leg_l if side == 0 else rg.leg_r
		var knee: Node3D = rg.knee_l if side == 0 else rg.knee_r
		if knee == null:
			continue
		var an: Node3D = rg._ankles[side] if rg._ext_ready else knee.get_node_or_null("Ankle")
		var l1 := -knee.position.y
		var l2 := -an.position.y if an else 0.3
		var hip := bxf * leg.position
		var A: Vector3 = (h["ayak"] as Array)[side]
		var pole: Vector3 = (h["diz"] as Array)[side]
		var K := _iki(hip, A, pole, l1, l2)
		var d := bi * ((K - hip) / l1)
		var s := bi * (A - K).normalized()
		var lb := _kemik(d, s, true)
		leg.quaternion = leg.quaternion.slerp(lb[0], kb)
		knee.quaternion = knee.quaternion.slerp(Quaternion(Vector3.RIGHT, lb[1]), kb)
		if an:
			var tb: Array = (h["taban"] as Array)[side]
			var fz: Vector3 = (tb[0] as Vector3).normalized()
			var fy: Vector3 = tb[1]
			fy = (fy - fz * fy.dot(fz)).normalized()
			var foot := Basis(fy.cross(fz), fy, fz)
			var kbw := bb * Basis(lb[0]) * Basis(Vector3.RIGHT, lb[1])
			tq[side] = (kbw.inverse() * foot).get_rotation_quaternion()
	rg._durus["taban_q"] = tq
	for side in 2:
		var arm: Node3D = rg.arm_l if side == 0 else rg.arm_r
		var el: Node3D = rg.elbow_l if side == 0 else rg.elbow_r
		if arm == null or el == null:
			continue
		var W = (h["el"] as Array)[side]
		if W == null:
			# Serbest kol: yana sarkar (gövdeye göre), hafif bükük
			var sx := -1.0 if side == 0 else 1.0
			arm.quaternion = arm.quaternion.slerp(Quaternion.from_euler(Vector3(-0.08, 0, sx * (rg.arm_rest_z + 0.04))), kb)
			el.quaternion = el.quaternion.slerp(Quaternion(Vector3.RIGHT, -0.2), kb)
			continue
		var lu := -el.position.y
		var hv: Vector3 = el.get_meta("hand", Vector3(0, -lu - 0.01, 0.01))
		var lf := hv.length()
		var shd := bxf * arm.position
		var E := _iki(shd, W, (h["dirsek"] as Array)[side], lu, lf)
		var u := bi * ((E - shd) / lu)
		var f := bi * ((W as Vector3) - E).normalized()
		var ab := _kemik(u, f, false)
		arm.quaternion = arm.quaternion.slerp(ab[0], kb)
		el.quaternion = el.quaternion.slerp(Quaternion(Vector3.RIGHT, ab[1]), kb)
	if rg.head:
		var hb: Vector3 = h["bas"]
		rg.head.quaternion = rg.head.quaternion.slerp(Quaternion.from_euler(hb), clampf(kb * 0.8, 0.0, 1.0))


## İki kemik: a kökten c uca, pole tarafına bükülen orta eklemin noktası (ulaşılamazsa düz uzanır)
static func _iki(a: Vector3, c: Vector3, pole: Vector3, l1: float, l2: float) -> Vector3:
	var ac := c - a
	var dl := ac.length()
	var u := ac / dl if dl > 0.0001 else Vector3.DOWN
	var d := clampf(dl, absf(l1 - l2) + 0.002, l1 + l2 - 0.0008)
	var x := (l1 * l1 - l2 * l2 + d * d) / (2.0 * d)
	var hh := sqrt(maxf(l1 * l1 - x * x, 0.0))
	var v := pole - u * pole.dot(u)
	if v.length() < 0.0001:
		v = u.cross(Vector3.RIGHT if absf(u.x) < 0.9 else Vector3.FORWARD)
	return a + u * x + v.normalized() * hh


## Üst kemik yönü d (gövde yerelinde, kökten uca), alt kemik yönü s → [üst kemiğin dönüşü (Quaternion), orta eklemin
## x açısı]. Bacakta diz artı açıyla (baldır geriye), kolda dirsek eksi açıyla (önkol öne) bükülür: alt kemiğin
## düzlemi orta eklemin yerel z ekseniyle kurulur.
static func _kemik(d: Vector3, s: Vector3, bacak: bool) -> Array:
	var y := -d.normalized()
	var dn := -y
	var sp := s - dn * s.dot(dn)
	var z: Vector3
	if sp.length() < 0.001:
		z = (Vector3.BACK - y * Vector3.BACK.dot(y))
		if z.length() < 0.001:
			z = Vector3.UP - y * Vector3.UP.dot(y)
		z = z.normalized()
		if bacak:
			z = -z
	else:
		z = (-sp if bacak else sp).normalized()
	var x := y.cross(z)
	var ang := acos(clampf(s.normalized().dot(dn), -1.0, 1.0))
	return [Basis(x, y, z).orthonormalized().get_rotation_quaternion(), ang if bacak else -ang]


# ---------------------------------------------------------------- etek (kaftan) ve eşyalar

## Kaftan eteği (Rig.body'nin "Baked" ağında kalçanın altında kalan kısım: kaftan, cüppe, önlük) UYLUKLARA BAĞLANIR:
## her köşe, x'ine göre sol/sağ uyluğun dönüşünü (ortada ikisinin karışımı) alır; diz boyundan aşağısı dizden sonra
## yerçekimiyle aşağı sarkar; zeminin (kökün y = 0) altına inen köşe zemine yatırılır. Böylece oturuşta etek kucağa ve
## dizlerin üstüne yayılır, bacakların ve zeminin içinden geçmez; eğilen gövdeyle de dimdik "çan" gibi öne yatmaz.
## Geçişte (ilk ~1,3 sn) 0,12 sn'de bir yeniden hesaplanır; sonra son biçim (ağ + duruş adına göre) önbelleğe alınır
## ve aynı ağlı, aynı duruşlu kişiler onu paylaşır.
static func _etek(rg: Rig, on: bool, delta := 0.016) -> void:
	if rg.body == null:
		return
	var mi := rg.body.get_node_or_null("Baked") as MeshInstance3D
	if mi == null or mi.mesh == null:
		return
	var st: Dictionary = rg._durus
	if not on:
		if mi.has_meta(_ETEK_KEY):
			mi.mesh = mi.get_meta(_ETEK_KEY)
			mi.remove_meta(_ETEK_KEY)
		return
	if rg.leg_l == null or rg.leg_r == null or rg.knee_l == null:
		return
	var src: ArrayMesh = mi.get_meta(_ETEK_KEY) if mi.has_meta(_ETEK_KEY) else mi.mesh as ArrayMesh
	if src == null:
		return
	if bool(st.get("etek_son", false)):
		return
	var key := "%d|%s" % [src.get_instance_id(), String(st.get("ad", ""))]
	var t := float(st.get("t", 0.0))
	if _etek_cache.has(key) and t < 1.3 and not st.has("etek_t"):
		# aynı ağ + duruş daha önce çözülmüş: hemen son biçim
		_etek_tak(mi, src, _etek_cache[key])
		st["etek_son"] = true
		return
	st["etek_t"] = float(st.get("etek_t", 0.0)) - delta
	if t >= 1.3:
		if not _etek_cache.has(key):
			_etek_cache[key] = _etek_mesh(src, rg)
		_etek_tak(mi, src, _etek_cache[key])
		st["etek_son"] = true
	elif float(st["etek_t"]) <= 0.0:
		st["etek_t"] = 0.12
		_etek_tak(mi, src, _etek_mesh(src, rg))


static func _etek_tak(mi: MeshInstance3D, src: ArrayMesh, m: ArrayMesh) -> void:
	if m == null:
		return
	if not mi.has_meta(_ETEK_KEY):
		mi.set_meta(_ETEK_KEY, src)
	mi.mesh = m


static func _etek_mesh(src: ArrayMesh, rg: Rig) -> ArrayMesh:
	if src == null:
		return null
	var legs: Array = [rg.leg_l, rg.leg_r]
	var knees: Array = [rg.knee_l, rg.knee_r]
	var M: Array = []
	var hy: Array = []
	var l1: Array = []
	for side in 2:
		var lg: Node3D = legs[side]
		var kn: Node3D = knees[side] if knees[side] != null else knees[0]
		M.append(lg.transform * Transform3D(Basis(), lg.position).affine_inverse())
		hy.append(lg.position.y)
		l1.append(-kn.position.y if kn else 0.3)
	var hip_y := (float(hy[0]) + float(hy[1])) * 0.5
	var bx := rg.body.transform                     # gövde → kök (kökün zemini y = 0)
	var bi := bx.affine_inverse()
	var down := (bi.basis * Vector3.DOWN).normalized()
	var out := ArrayMesh.new()
	for si in src.get_surface_count():
		var arr := src.surface_get_arrays(si)
		var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var nr = arr[Mesh.ARRAY_NORMAL]
		var has_n: bool = nr != null and (nr as PackedVector3Array).size() == v.size()
		for i in v.size():
			var p := v[i]
			var dy := hip_y - p.y
			if dy <= 0.0:
				continue
			var wr := smoothstep(-0.07, 0.07, p.x)        # leg_r x > 0
			var q := Vector3.ZERO
			var nb := Vector3.ZERO
			for side in 2:
				var w := wr if side == 1 else 1.0 - wr
				if w <= 0.0:
					continue
				var m: Transform3D = M[side]
				var lim: float = float(hy[side]) - float(l1[side]) * 1.05
				var pk := Vector3(p.x, maxf(p.y, lim), p.z)
				var qs := m * pk
				if p.y < lim:
					qs += down * (lim - p.y) * 0.75
				q += qs * w
				if has_n:
					nb += (m.basis * (nr as PackedVector3Array)[i]) * w
			# zeminin altına inen köşe zemine yatar (kumaş yere serilir)
			var g := bx * q
			if g.y < 0.012:
				g.y = 0.012 + (0.012 - g.y) * 0.02
				q = bi * g
			v[i] = q
			if has_n and nb.length() > 0.0001:
				(nr as PackedVector3Array)[i] = nb.normalized()
		arr[Mesh.ARRAY_VERTEX] = v
		if has_n:
			arr[Mesh.ARRAY_NORMAL] = nr
		arr[Mesh.ARRAY_TANGENT] = null
		out.add_surface_from_arrays(src.surface_get_primitive_type(si), arr)
		out.surface_set_material(si, src.surface_get_material(si))
	return out


## Duruşun eşyaları (kâse, bileği taşı, kılıç, ok gövdesi, kâğıt, maşrapa, fırça, odun, yük, bohça, kütük/sandık/eyer):
## kökün çocuğu ("DurusProp"), ele bağlı olanlar her karede elin yerine konur. Pişmiş kalabalıkta da ağa girer.
static func _props(rg: Rig, ad: String, h: Dictionary) -> void:
	var st: Dictionary = rg._durus
	if not st.has("props"):
		st["props"] = _props_kur(rg, ad)
	var pr: Dictionary = st["props"]
	if pr.is_empty() or rg.owner == null:
		return
	var hand := [_el_nokta(rg, 0), _el_nokta(rg, 1)]
	if pr.has("sol"):
		(pr["sol"] as Node3D).position = hand[0]
	if pr.has("sag"):
		(pr["sag"] as Node3D).position = hand[1]
	if pr.has("iki"):
		var n := pr["iki"] as Node3D
		n.position = (hand[0] + hand[1]) * 0.5
		var ax: Vector3 = hand[1] - hand[0]
		if ax.length() > 0.05:
			n.basis = Basis(Vector3.UP, atan2(-ax.z, ax.x))
	if pr.has("yuk"):
		(pr["yuk"] as Node3D).position = Vector3(0, 0.15 + float(h.get("yuk", 0.0)) * 0.3, 0.38)


## Avucun kökteki yeri (gövde → kol → dirsek zinciri yerel dönüşümlerden; ağaçta olmasa da çalışır)
static func _el_nokta(rg: Rig, side: int) -> Vector3:
	var arm: Node3D = rg.arm_l if side == 0 else rg.arm_r
	var el: Node3D = rg.elbow_l if side == 0 else rg.elbow_r
	if arm == null or el == null or rg.body == null:
		return Vector3.ZERO
	var hv: Vector3 = el.get_meta("hand", Vector3(0, -0.27, 0.01))
	return rg.body.transform * (arm.transform * (el.transform * hv))


static func _props_kur(rg: Rig, ad: String) -> Dictionary:
	var pr := {}
	var o := rg.owner
	if o == null:
		return pr
	var holder := Node3D.new()
	holder.name = "DurusProp"
	o.add_child(holder)
	pr["holder"] = holder
	var wood := Color("7a5634")
	var sack := Color("b9a47a")
	match ad:
		"bagdas_ye":
			var b := Node3D.new()
			holder.add_child(b)
			Props.cyl(b, 0.085, 0.07, Vector3(0, 0.0, 0.01), Color("8a6440"), Vector3.ZERO, 10, 0.11)
			Props.cyl(b, 0.075, 0.012, Vector3(0, 0.035, 0.01), Color("c9a86a"), Vector3.ZERO, 10)
			pr["sol"] = b
			var e := Node3D.new()
			holder.add_child(e)
			Props.box(e, Vector3(0.07, 0.035, 0.05), Vector3(0, 0.0, 0.03), Color("d8b070"))
			pr["sag"] = e
		"bagdas_bile":
			var k := Node3D.new()
			holder.add_child(k)
			k.position = Vector3(0, 0.37, 0.3)
			Props.box(k, Vector3(0.62, 0.012, 0.04), Vector3(0.06, 0, 0), Color("b8bec8"))
			Props.box(k, Vector3(0.14, 0.03, 0.03), Vector3(-0.3, 0, 0), wood)
			Props.box(k, Vector3(0.02, 0.03, 0.12), Vector3(-0.23, 0, 0), Color("8a7a4a"))
			var s := Node3D.new()
			holder.add_child(s)
			Props.box(s, Vector3(0.1, 0.03, 0.04), Vector3(0, -0.02, 0.02), Color("7a7a72"))
			pr["sag"] = s
		"bagdas_ok":
			var a := Node3D.new()
			holder.add_child(a)
			Props.cyl(a, 0.008, 0.7, Vector3.ZERO, Color("c8a870"), Vector3(0, 0, 90), 5)
			pr["iki"] = a
		"bagdas_yaz":
			var p := Node3D.new()
			holder.add_child(p)
			p.position = Vector3(-0.02, 0.36, 0.3)
			Props.box(p, Vector3(0.26, 0.012, 0.2), Vector3.ZERO, Color("6a4a2e"))
			Props.box(p, Vector3(0.21, 0.004, 0.16), Vector3(0, 0.008, 0), Color("ece2c8"))
			var q := Node3D.new()
			holder.add_child(q)
			Props.cyl(q, 0.004, 0.16, Vector3(0, 0.03, 0.03), Color("3a2a1a"), Vector3(30, 0, 0), 4)
			pr["sag"] = q
		"bagdas_ekmek":
			var l := Node3D.new()
			holder.add_child(l)
			Props.ball(l, 0.06, Vector3(0, 0, 0.02), Color("c99a5a"), Vector3(1.2, 0.6, 1.0), 8)
			pr["sol"] = l
			var r := Node3D.new()
			holder.add_child(r)
			Props.ball(r, 0.06, Vector3(0, 0, 0.02), Color("c99a5a"), Vector3(1.2, 0.6, 1.0), 8)
			pr["sag"] = r
		"sirt_uzan":
			Props.box(holder, Vector3(0.44, 0.14, 0.32), Vector3(0, 0.07, -0.93), sack)
			Props.ball(holder, 0.12, Vector3(0.0, 0.1, -0.93), sack.darkened(0.08), Vector3(1.7, 0.6, 1.2), 8)
		"yan_uzan":
			Props.box(holder, Vector3(0.5, 0.06, 0.4), Vector3(-0.55, 0.03, 0.12), Color("8a4a32"))       # yere serili keçe
		"otur_kutuk":
			Props.cyl(holder, 0.2, 0.75, Vector3(0, 0.2, -0.1), Color("6a4a2e"), Vector3(0, 0, 90), 9)
			Props.cyl(holder, 0.17, 0.01, Vector3(0.376, 0.2, -0.1), Color("b89a6a"), Vector3(0, 0, 90), 9)
			Props.cyl(holder, 0.17, 0.01, Vector3(-0.376, 0.2, -0.1), Color("b89a6a"), Vector3(0, 0, 90), 9)
		"otur_sandik":
			Props.box(holder, Vector3(0.66, 0.42, 0.42), Vector3(0, 0.21, -0.12), Color("6a4a2e"))
			Props.box(holder, Vector3(0.68, 0.04, 0.44), Vector3(0, 0.4, -0.12), Color("4a3a2a"))
		"otur_eyer":
			Props.box(holder, Vector3(0.36, 0.26, 0.55), Vector3(0, 0.13, -0.1), Color("5a3a24"))
			Props.box(holder, Vector3(0.5, 0.05, 0.3), Vector3(0, 0.29, -0.1), Color("8a2a22"))
			Props.box(holder, Vector3(0.34, 0.12, 0.06), Vector3(0, 0.34, -0.36), Color("5a3a24"))
		"sirt_dayali":
			Props.box(holder, Vector3(0.62, 0.5, 0.3), Vector3(0, 0.25, -0.6), sack)
			Props.cyl(holder, 0.006, 0.64, Vector3(0, 0.4, -0.45), Color("6a5a3a"), Vector3(0, 0, 90), 4)
		"odun_at":
			var w := Node3D.new()
			holder.add_child(w)
			Props.cyl(w, 0.06, 0.55, Vector3.ZERO, Color("6a4a2e"), Vector3(0, 0, 90), 7)
			pr["iki"] = w
		"yuk_kaldir":
			var y := Node3D.new()
			holder.add_child(y)
			Props.box(y, Vector3(0.36, 0.3, 0.3), Vector3.ZERO, sack)
			Props.cyl(y, 0.005, 0.37, Vector3(0, 0.1, 0), Color("6a5a3a"), Vector3(0, 0, 90), 4)
			pr["yuk"] = y
		"su_ic":
			var c := Node3D.new()
			holder.add_child(c)
			Props.cyl(c, 0.04, 0.1, Vector3(0, 0.02, 0.04), Color("9a7a5a"), Vector3.ZERO, 8, 0.045)
			pr["sag"] = c
		"tas_kir":
			var tk := Node3D.new()
			holder.add_child(tk)
			Props.cyl(tk, 0.016, 0.3, Vector3(0, 0.0, 0.12), wood, Vector3(90, 0, 0), 5)
			Props.box(tk, Vector3(0.12, 0.07, 0.07), Vector3(0, 0, 0.27), Color("5a5c62"))
			pr["sag"] = tk
			Props.box(holder, Vector3(0.24, 0.16, 0.2), Vector3(0.1, 0.08, 0.62), Color("a89c84"), Vector3(0, 20, 0))
		"at_timar":
			var f := Node3D.new()
			holder.add_child(f)
			Props.box(f, Vector3(0.12, 0.04, 0.07), Vector3(0, -0.01, 0.04), Color("5a4030"))
			pr["sag"] = f
	if holder.get_child_count() == 0:
		holder.queue_free()
		pr.erase("holder")
	return pr


static func _props_sil(rg: Rig) -> void:
	var st: Dictionary = rg._durus
	if st.has("props"):
		var pr: Dictionary = st["props"]
		if pr.has("holder") and is_instance_valid(pr["holder"]):
			(pr["holder"] as Node).queue_free()
		st.erase("props")


# ---------------------------------------------------------------- denetim

## Duruş yerine oturduğunda gövdenin (pişmiş "Baked" parçalar: gövde, bacaklar, kollar, baş) en alçak noktası kökün
## zeminine (y = 0) göre: oturan/yatan duruşta ±6 cm, ayaktaki işte −6 cm altı (gömülü) denetlenir.
static func _zemin_denet(rg: Rig, ad: String) -> void:
	var o := rg.owner
	if o == null or rg.body == null:
		return
	var lo := INF
	for c in rg.body.find_children("Baked*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null or not mi.visible:
			continue
		var xf := _rel(mi, o)
		for si in mi.mesh.get_surface_count():
			var v: PackedVector3Array = mi.mesh.surface_get_arrays(si)[Mesh.ARRAY_VERTEX]
			for p in v:
				var y := (xf * p).y
				if y < lo:
					lo = y
	if lo == INF:
		return
	var sc := o.scale.y if o is Node3D else 1.0
	var cm := lo * sc * 100.0
	var oturan := tur(ad) in ["otur", "yat"]
	if cm < -6.0 or (oturan and cm > 6.0):
		print("POSEAUDIT ground %s %s %.1f" % [o.name, ad, cm])
	rg._durus["zemin_cm"] = cm


static func _rel(n: Node3D, top: Node3D) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var c: Node = n
	while c != null and c != top:
		if c is Node3D:
			xf = (c as Node3D).transform * xf
		c = c.get_parent()
	return xf
