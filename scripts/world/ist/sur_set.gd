class_name SurSet
extends RefCounted
## BÖLÜM BAĞDAŞTIRICISI (sur seti ↔ ortak yardımcılar). docs/SUR_SOZLESME.md "Bölüm bağdaştırıcısı".
##
## Assault, Garrison, WallFight, SiegeChaos ve bölümler sura sabit koordinat yazmak yerine bu sınıfa sorar. İki uygulama:
##   SurSet.eski()                → bugünkü LandWalls sabitlerinin AYNISI (eski set; davranış birebir)
##   SurSet.yeni("mesoteikhion")  → SurOyun.arayuz(kesim) sorguları (yeni İstanbul kara suru)
## Yardımcılar bağdaştırıcıyı İSTEĞE BAĞLI alır: verilmezse (null) bugünkü kod yolu hiç değişmeden çalışır.
##
## BÖLÜM ÇERÇEVESİ: bütün noktalar bölümün yerel çerçevesindedir ve bu çerçeve eski setle hizalıdır:
##   x = 0 oyun gediğinin ortası, y = 0 peribolos toprağı, z = 14 dış surun iç (peribolos) yüzü, +z ova.
## Yeni sette sur kesiti farklıdır (dış sur 2,6 m kalın / 8,5 m yüksek, 10 m teras, 20 × 6 m hendek, ova 3,7 m aşağıda):
## eski sayılar ancak bu sınıftan okunursa iki sette de doğru yere düşer. Çerçeve ↔ SurOyun yereli: cerceve = yerel + ofs.
##
## Statik zemin işlevleri (Assault.ground_y) örneksiz çağrılır: yeni set kurulunca SurSet.etkin ona bakar (sahne ağaçtan
## çıkınca sıfırlanır; eski bölümlerde hep null).

const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")

## Yeni set sahnesi kurulduğunda (SurSetSahne) etkin bağdaştırıcı; statik zemin işlevleri buna bakar.
static var etkin: SurSet = null

var eski_mi := true
var ad := "eski"
var a: RefCounted = null            # SurOyun arayüzü (yeni)
var d: Dictionary = {}              # donmuş kesit (yeni)
var ofs := Vector3.ZERO             # SurOyun yereli → bölüm çerçevesi
var _moloz: Array = []              # moloz boy kesiti (çerçeve z, y)
var _engel: Array = []              # çerçevede Rect2 (x/z)


# ------------------------------------------------------------------ kurulum

static func eski() -> SurSet:
	var s := SurSet.new()
	s.eski_mi = true
	s.ad = "eski"
	return s


static func yeni(kesim := "mesoteikhion") -> SurSet:
	var s := SurSet.new()
	s.eski_mi = false
	s.ad = kesim
	s.a = SurOyun.arayuz(kesim)
	s.d = s.a.d
	# çerçeve: gedik x = 0, peribolos toprağı y = 0, dış surun iç yüzü z = 14 (LandWalls.OUTER_Z0)
	s.ofs = Vector3(-float(s.a.gx), -float(s.a.y_peri()), LandWalls.OUTER_Z0 - float(s.d["zo0"]))
	var pr: Dictionary = SurOyun.AG.moloz_profil(s.a)
	for p: Vector2 in pr["pts"]:
		s._moloz.append(Vector2(p.x + s.ofs.z, p.y + s.ofs.y))
	for r: Rect2 in s.a.engeller():
		s._engel.append(Rect2(r.position + Vector2(s.ofs.x, s.ofs.z), r.size))
	return s


## Bölüm başına geri dönüş anahtarı (karar 13): komut satırında `--eskisur` (hepsi) ya da `--eskisur=20,20o`; ya da bölümün
## kendi sabiti (sabit = true). Anahtarsız: yeni sur.
static func eski_istendi(bolum: String, sabit := false) -> bool:
	if sabit:
		return true
	for arg in OS.get_cmdline_user_args():
		if arg == "--eskisur":
			return true
		if arg.begins_with("--eskisur="):
			return bolum in arg.trim_prefix("--eskisur=").split(",", false)
	return false


## Bölümün sur seti: eski ya da yeni (SurSet.eski_istendi ile seçilir).
static func sec(bolum: String, sabit := false, kesim := "mesoteikhion") -> SurSet:
	return eski() if eski_istendi(bolum, sabit) else yeni(kesim)


## SurOyun yereli → çerçeve
func c(v: Vector3) -> Vector3:
	return v + ofs


## Çerçeve → SurOyun yereli
func y(v: Vector3) -> Vector3:
	return v - ofs


## Kesim kökünün çerçevedeki dönüşümü (SurOyun.kur köke "dunya": false ile; ebeveyn bu dönüşümle konur)
func cerceve() -> Transform3D:
	return Transform3D(Basis.IDENTITY, ofs)


# ------------------------------------------------------------------ dış sur ve gedik

## Gediğin ortası (LandWalls.BREACH): dış surun orta çizgisinde, peribolos zemininde
func gedik() -> Vector3:
	if eski_mi:
		return LandWalls.BREACH
	return Vector3(0.0, 0.0, dis_yol_z())


## Gedik eni (LandWalls.BREACH_W)
func gedik_en() -> float:
	return LandWalls.BREACH_W if eski_mi else IstSurlar.GEDIK_W


## Dış sur yolunun gedik çevresinde kullanılamayan yarı eni (eski: BREACH_W/2 + EDGE_W kırık kenar kuşağı)
func gedik_bosluk() -> float:
	if eski_mi:
		return LandWalls.BREACH_W * 0.5 + LandWalls.EDGE_W
	return IstSurlar.GEDIK_W * 0.5 + 0.5


## Gediğin peribolos yanındaki önü (onarım ekibinin, teslim yerinin önü; eski BREACH + (0, 0, −3,4))
func gedik_onu() -> Vector3:
	if eski_mi:
		return LandWalls.BREACH + Vector3(0, 0, -3.4)
	return Vector3(0.0, 0.0, dis_sur_z0() - 3.2)


## Barikatın ön yüzü (teslim hedefi, bant çekilen yer): eski BREACH + (0, 2,2, −1,2) ↔ yeni aşama fıçılarının önü
func barikat() -> Vector3:
	if eski_mi:
		return LandWalls.BREACH + Vector3(0, 2.2, -1.2)
	return Vector3(0.0, moloz_y(0.0, dis_sur_z0() - 1.4) + 0.9, dis_sur_z0() - 1.6)


## Moloz sırtı: düelloda gedikten inen/gediğe çıkanların yeri. Eski: dış yüzün 0,2 m DIŞI (z 16,2), bütün barikat
## aşamalarının (gediğin iç yarısı, z 13,6–15,6) ova tarafı. Yeni: aynı anlam: dış yüzün önünde, aşama 4'ün dış yüzdeki kazık
## çitinin (GedikOnarim, dış yüz +0,1 ± 0,2; moloz üstünden ≈2 m) ova tarafında, çitten bir kişi payı (≈1 m) uzakta. Duvarın
## ortasında (çitin içinde) ya da çitin dibinde (dış yüz +0,7) gedik sağlamken düello çitin dibine sıkışıyordu: 20o =wide
## dalgaları 13/11 → 41/43 sn; çit çarpışması kapalı denemede 11/15 sn (docs/_kanit_ist2_pilot20/rapor.md).
func moloz_sirti() -> Vector3:
	if eski_mi:
		return LandWalls.on_rubble(LandWalls.BREACH + Vector3(0, 0, 1.2))
	var z := dis_sur_z1() + 1.4
	return Vector3(0.0, moloz_y(0.0, z), z)


func dis_sur_z0() -> float:
	return LandWalls.OUTER_Z0 if eski_mi else float(d["zo0"]) + ofs.z


func dis_sur_z1() -> float:
	return LandWalls.OUTER_Z1 if eski_mi else float(d["zo1"]) + ofs.z


## Dış sur yürüme yolunun yüksekliği (LandWalls.OUTER_H)
func dis_yol_y() -> float:
	return LandWalls.OUTER_H if eski_mi else float(d["OH"]) + ofs.y


## Dış sur yolunun ortası (z)
func dis_yol_z() -> float:
	return (LandWalls.OUTER_Z0 + LandWalls.OUTER_Z1) * 0.5 if eski_mi else float(a.zc_dis()) + ofs.z


## Dış sur yolunda iç korkuluğa yakın duruş (Garrison sırası; eski 14,72) ve dış korkuluğa yakın (eski 15,28)
func dis_yol_ic_z() -> float:
	return 14.72 if eski_mi else dis_sur_z0() + IstSurlar.PARAPET_T + 0.32


func dis_yol_on_z() -> float:
	return 15.28 if eski_mi else dis_sur_z1() - IstSurlar.PARAPET_T - 0.32


func ic_yol_y() -> float:
	return LandWalls.INNER_H if eski_mi else float(d["HW"]) + ofs.y


## İç sur yolunda kişinin durduğu z (peribolos tarafındaki korkuluğun ardı; eski −2,1)
func ic_yol_z() -> float:
	return -2.1 if eski_mi else float(d["zi1"]) - IstSurlar.PARAPET_T - 0.5 + ofs.z


## İç surun peribolos yüzü (LandWalls.INNER_Z1)
func ic_sur_z1() -> float:
	return LandWalls.INNER_Z1 if eski_mi else float(d["zi1"]) + ofs.z


## Dış kuleler (çerçeve x). Yeni: kurulu + yıkık (yıkığın tepe basamakları kurulu; sur yolu orada kesik).
func dis_kuleler() -> Array:
	if eski_mi:
		return [-16.0, 16.0]
	var out: Array = []
	for cx in (a.kesim["kule"]["dis"] as Array) + (a.kesim["kule"].get("dis_yikik", []) as Array):
		out.append(float(cx) + ofs.x)
	return out


## Kurulu (tepesi olan) dış kuleler
func dis_kuleler_kurulu() -> Array:
	if eski_mi:
		return [-16.0, 16.0]
	var out: Array = []
	for cx in a.kesim["kule"]["dis"]:
		out.append(float(cx) + ofs.x)
	return out


## Dış sur yolunda kulenin çevresinde kimsenin durmayacağı yarı en (yeni: kule + tepe basamakları)
func dis_kule_bosluk() -> float:
	if eski_mi:
		return 3.3
	return float(d["OTW"]) * 0.5 + float(a.kesim["merdiven"]["kule_ust_n"]) * float(a.kesim["merdiven"]["kule_ust_tread"]) + 0.6


## Dış kule tepesinin ortası (gözcü yeri)
func dis_kule_tepe(tx: float) -> Vector3:
	if eski_mi:
		return Vector3(tx, LandWalls.OUTER_H + 3.0, LandWalls.OUTER_Z1 + 1.6)
	return Vector3(tx, float(d["OTH"]) + ofs.y, float(d["zo0"]) + 0.5 * (float(d["OT"]) + float(d["OTP"])) + ofs.z)


## İç kuleler (çerçeve x)
func ic_kuleler() -> Array:
	if eski_mi:
		return [-24.0, 24.0]
	var out: Array = []
	for t in a.kesim["kule"]["ic"]:
		out.append(float(t[0]) + ofs.x)
	for yn in a.kesim["yan"]:
		for t in yn["kule"]["ic"]:
			out.append(float(yn["x"]) + float(t[0]) + ofs.x)
	return out


func ic_kule_bosluk() -> float:
	return 5.2


func ic_kule_tepe(tx: float) -> Vector3:
	if eski_mi:
		return Vector3(tx, LandWalls.INNER_H + 6.0, 1.8)
	return Vector3(tx, float(d["HT"]) + ofs.y, 0.5 * float(d["TP"]) + ofs.z)


## Dış sur yolunda sağlam bir x (LandWalls.walk_x): gedik ve dış kuleler dışında
func dis_yol_x(x: float) -> float:
	if eski_mi:
		return LandWalls.walk_x(x)
	var gap := gedik_bosluk() + 0.8
	if absf(x) < gap:
		x = gap if x >= 0.0 else -gap
	for tx: float in dis_kuleler():
		var b := dis_kule_bosluk()
		if absf(x - tx) < b:
			x = tx + (b if x >= tx else -b)
	return x


## Dış sur yolunda x kullanılabilir mi (gedik, kule ve kule basamakları dışında)
func dis_yol_bos(x: float) -> bool:
	if eski_mi:
		return absf(x) > gedik_bosluk() and absf(absf(x) - 16.0) > 3.3
	if absf(x) < gedik_bosluk():
		return false
	for tx: float in dis_kuleler():
		if absf(x - tx) < dis_kule_bosluk():
			return false
	return true


## İç sur yolunda x kullanılabilir mi (iç kulelerin dışında)
func ic_yol_bos(x: float) -> bool:
	for tx: float in ic_kuleler():
		if absf(x - tx) <= ic_kule_bosluk():
			return false
	return true


# ------------------------------------------------------------------ zemin

## Gedik molozunun yüksekliği (LandWalls.rubble_y): molozun dışında 0 (peribolos)
func moloz_y(x: float, z: float) -> float:
	if eski_mi:
		return LandWalls.rubble_y(x, z)
	return maxf(0.0, _moloz_ust(x, z))


## Moloz tümseğinin üstü (yoksa −INF): SurOyunAg._tumsek ile aynı kesit (orta 2,1 m düz, omuz 3 m'de %35 alçak, 4,6'da taban)
func _moloz_ust(x: float, z: float) -> float:
	if _moloz.is_empty() or z < (_moloz[0] as Vector2).x or z > (_moloz[_moloz.size() - 1] as Vector2).x:
		return -INF
	var yc := _profil(z)
	var tb := _taban(z)
	var dx := absf(x)
	if dx <= 1.05:
		return yc
	if dx <= 3.0:
		return lerpf(yc, lerpf(yc, tb, 0.35), (dx - 1.05) / 1.95)
	if dx <= 4.6:
		return lerpf(lerpf(yc, tb, 0.35), tb, (dx - 3.0) / 1.6)
	return -INF


func _profil(z: float) -> float:
	for i in _moloz.size() - 1:
		var p: Vector2 = _moloz[i]
		var q: Vector2 = _moloz[i + 1]
		if z >= p.x and z <= q.x:
			return lerpf(p.y, q.y, (z - p.x) / maxf(q.x - p.x, 0.001))
	return (_moloz[0] as Vector2).y if z < (_moloz[0] as Vector2).x else (_moloz[_moloz.size() - 1] as Vector2).y


## Molozsuz zemin (çerçeve): peribolos 0, teras, hendek dibi, ova
func _taban(z: float) -> float:
	if z < dis_sur_z1():
		return 0.0
	if z < hendek_z0():
		return teras_y()
	if z < hendek_z1():
		return hendek_dip_y()
	return ova_y()


func on_rubble(p: Vector3) -> Vector3:
	if eski_mi:
		return LandWalls.on_rubble(p)
	return Vector3(p.x, maxf(p.y, moloz_y(p.x, p.z)), p.z)


## Surun önündeki görünen zemin (Assault.ground_y): moloz, teras, parateikhion, hendek (dolgu ve kalas köprü üstü), ova.
## Eski: Assault'un kendi kesiti.
func zemin_y(x: float, z: float) -> float:
	if eski_mi:
		return Assault._ground_y_eski(x, z)
	var yy := _taban(z)
	var zm0 := hendek_z0()
	var zm1 := hendek_z1()
	if z >= dis_sur_z1() and z < zm0:
		# parateikhion (alçak sur, 1,6 m) ve hendek iç yakası (kapak taşı): geçişlerin önünde açık
		if z >= zm0 - 1.8 and z < zm0 - 0.9 and not _gecis_onunde(x, 0.3):
			yy = teras_y() + 1.6 + 0.12
		elif z >= zm0 - 0.9:
			yy = teras_y() + 0.12
	elif z >= zm0 and z <= zm1:
		for g: Dictionary in gecisler():
			var hw := float(g["en"]) * 0.5
			var dxg := absf(x - float(g["x"]))
			if String(g["tur"]) == "dolgu" and dxg <= hw + 2.0:
				var top := ova_y() + 0.06
				yy = maxf(yy, top if dxg <= hw else lerpf(top, hendek_dip_y(), (dxg - hw) / 2.0))
			elif String(g["tur"]) == "kalas" and dxg <= 0.8:
				yy = maxf(yy, ova_y() + 0.04)
	elif z > zm1 and z < zm1 + 0.9:
		yy = ova_y() + 0.02
	var m := _moloz_ust(x, z)
	return maxf(yy, m) if m > -INF else yy


## Dış zemin (LandWalls.outside_y eşi)
func dis_zemin_y(x: float, z: float) -> float:
	if eski_mi:
		return LandWalls.outside_y(x, z)
	return zemin_y(x, z)


func _gecis_onunde(x: float, pay: float) -> bool:
	for g: Dictionary in gecisler():
		if absf(x - float(g["x"])) < float(g["en"]) * 0.5 + 0.3 + pay:
			return true
	return false


# ------------------------------------------------------------------ teras, hendek, ova

func teras_y() -> float:
	return 0.0 if eski_mi else float(a.y_teras()) + ofs.y


## Teras (dış surun dibi ile parateikhion arası): {z0, z1, y}. Eski: sur dibi ile korkuluk arası set (z 16–18,4)
func teras() -> Dictionary:
	if eski_mi:
		return {"z0": LandWalls.OUTER_Z1, "z1": 18.4, "y": 0.0}
	return {"z0": dis_sur_z1(), "z1": hendek_z0() - 1.8, "y": teras_y()}


func hendek_z0() -> float:
	return 20.0 if eski_mi else float(d["zm0"]) + ofs.z


func hendek_z1() -> float:
	return 36.0 if eski_mi else float(d["zm1"]) + ofs.z


func hendek_dip_y() -> float:
	return -2.9 if eski_mi else float(a.y_hendek_dip()) + ofs.y


## Hendek içinde t (0 yakın yaka … 1 uzak yaka) oranındaki z: eski hendek kesitindeki bir yeri yenisine taşımak için
func hendek_z(t: float) -> float:
	return lerpf(hendek_z0(), hendek_z1(), t)


## Ovanın başladığı z (hendeğin uzak yakası) ve yüksekliği
func ova_z0() -> float:
	return 36.0 if eski_mi else hendek_z1()


func ova_y() -> float:
	return 0.0 if eski_mi else float(a.y_ova()) + ofs.y


## Ova düğümünün kaydırması: eski setin ova koordinatları (z ≥ 36 düz y = 0; SiegeField, Assault'un ordusu, bataryalar,
## büyük top) bu kaydırmayla yeni ovaya iner (ovanın başı eski z 36 ↔ yeni hendek uzak yakası; düzlem eski y 0 ↔ yeni ova).
func ova_ofs() -> Vector3:
	if eski_mi:
		return Vector3.ZERO
	return Vector3(0.0, ova_y() - SiegeField.flat_y, ova_z0() - 36.0)


## Hendek geçişleri (karar 7-A): [{"tur": dolgu|kalas, "x", "en", "yakin" (teras ucu), "uzak" (ova ucu)}]. Eski: yok.
func gecisler() -> Array:
	if eski_mi:
		return []
	var out: Array = []
	var h: Dictionary = a.hendek()
	for g: Dictionary in h.get("gecis", []):
		out.append({"tur": g["tur"], "x": float(g["x"]) + ofs.x, "en": float(g["en"]),
			"yakin": c(g["yakin"]["yerel"]), "uzak": c(g["uzak"]["yerel"])})
	return out


## Ovadan surun dibindeki hedefe koşu yolu (çoklu çizgi). Eski: düz çizgi [ova, hedef] (hendeğe iner, karşıdan çıkar).
## Yeni: hendek ancak dolgudan geçilir (karar 7-A): ova → dolgunun uzak ucu → dolgunun yakın ucu → (teras boyunca) hedef.
func kosu_yolu(from: Vector3, to: Vector3) -> Array:
	if eski_mi:
		return [from, to]
	var dl: Dictionary = {}
	for g: Dictionary in gecisler():
		if String(g["tur"]) == "dolgu":
			dl = g
	if dl.is_empty():
		return [from, to]
	var hw := float(dl["en"]) * 0.5 - 1.2
	var gx := float(dl["x"])
	var x_uzak := clampf(from.x * 0.08, gx - hw, gx + hw)
	var x_yakin := clampf(to.x * 0.12, gx - hw, gx + hw)
	var out: Array = [from]
	out.append(Vector3(x_uzak, ova_y(), hendek_z1() + 1.5))
	out.append(Vector3(x_yakin, teras_y(), hendek_z0() - 2.6))
	out.append(to)
	for i in out.size():
		var p: Vector3 = out[i]
		p.y = zemin_y(p.x, p.z)
		out[i] = p
	return out


## Dış surun önündeki hücum merdivenleri (Assault'un dekor merdivenleri; karar 8-A sayı aynı): [{"x", "ayak", "tepe"}].
## Eski: Assault'un sekiz merdiveni (ayak z 18,35, tepe y 7,7). Yeni: önce sözleşmenin dayamaları, sonra dış sur yolunda
## kule, gedik, poterna ve geçişlerden uzak eşit aralıklı yerler (dayama kuralıyla: eğim 16°, tepe korkuluğun 1,5 m üstü).
func hucum_merdivenleri(xs_eski: Array, span: float) -> Array:
	var out: Array = []
	if eski_mi:
		for x: float in xs_eski:
			out.append({"x": x, "ayak": Vector3(x, 0.0, 18.35), "tepe": Vector3(x, 7.7, 16.25)})
		return out
	var dm: Array = a.dayamalar()
	var eg := deg_to_rad(float(dm[0]["egim"])) if not dm.is_empty() else deg_to_rad(16.0)
	var secilen: Array = []
	for m: Dictionary in dm:
		var x := float(m["x"]) + ofs.x
		if absf(x) < span and _merdiven_bos(x, secilen):
			secilen.append(x)
	# eski düzenin x'lerini yeni engellerden kaydırarak tamamla (aynı sayı)
	for x0: float in xs_eski:
		if secilen.size() >= xs_eski.size():
			break
		for k in 40:
			var x := x0 + (0.5 * k if k % 2 == 0 else -0.5 * k)
			if absf(x) < span and _merdiven_bos(x, secilen):
				secilen.append(x)
				break
	secilen.sort()
	var ty := dis_yol_y() + float(a.kesim["oyun"]["dayama_ust_pay"])
	for x: float in secilen:
		var gy := teras_y()
		var boy := (ty - gy) / cos(eg)
		var ayak := Vector3(x, gy, dis_sur_z1() + 0.12 + boy * sin(eg))
		var tepe := ayak + Vector3(0.0, boy * cos(eg), -boy * sin(eg))
		out.append({"x": x, "ayak": ayak, "tepe": tepe})
	return out


func _merdiven_bos(x: float, secilen: Array) -> bool:
	if not dis_yol_bos(x) or absf(x) < gedik_bosluk() + 2.0:
		return false
	for g: Dictionary in gecisler():
		if absf(x - float(g["x"])) < float(g["en"]) * 0.5 + 2.5:
			return false
	if absf(x - poterna_x()) < 4.0:
		return false
	for s: float in secilen:
		if absf(x - s) < 5.0:
			return false
	return true


func poterna_x() -> float:
	if eski_mi:
		return LandWalls.DEPOT.x + 3.5
	return float(a.kesim["oyun"]["poterna"]) + ofs.x


## Ovadaki top yuvaları, OVA koordinatında (Assault.gun_spots; ova düğümü ova_ofs ile kayar). Eski: aynen. Yeni: sözleşmenin
## iki bataryası + aynı aralıkla iki yanda birer (sayı aynı: 4).
func top_yuvalari(eski_liste: Array) -> Array:
	if eski_mi:
		return eski_liste
	var bs: Array = a.bataryalar()
	var xs: Array = []
	for b: Dictionary in bs:
		xs.append(float(b["p"]["yerel"].x) + ofs.x)
	xs.sort()
	var z := float(bs[0]["p"]["yerel"].z) + ofs.z - ova_ofs().z
	var ara: float = (xs[1] - xs[0]) if xs.size() > 1 else 42.0
	var out: Array = [Vector3(xs[0] - ara, 0, z)]
	for x: float in xs:
		out.append(Vector3(x, 0, z))
	out.append(Vector3(xs[xs.size() - 1] + ara, 0, z))
	return out


# ------------------------------------------------------------------ peribolos

## Peribolosta kişilerin dolaştığı kuşak (SiegeChaos.area). Yeni: SurOyun alanlar()["peribolos"] (sur dibi etekleri dışında)
func peribolos() -> Rect2:
	if eski_mi:
		return Rect2(-44.0, 1.4, 88.0, 10.6)
	var r: Rect2 = a.alanlar()["peribolos"]["r"]
	var rr := Rect2(r.position + Vector2(ofs.x, ofs.z), r.size)
	return rr.intersection(Rect2(-44.0, -10.0, 88.0, 40.0))


## Peribolosta dolaşanların girmeyeceği çemberler [[Vector3, yarıçap]]: iç kuleler (+ etek). Eski: yok.
func peribolos_engelleri(x0 := -60.0, x1 := 60.0) -> Array:
	if eski_mi:
		return []
	var out: Array = []
	for t in a.kesim["kule"]["ic"]:
		var x := float(t[0]) + ofs.x
		if x > x0 and x < x1:
			var zc := float(d["zi1"]) + float(t[2]) * 0.5 + ofs.z
			out.append([Vector3(x, 0.0, zc), float(t[1]) * 0.5 + 3.4])
	var px := poterna_x()
	if px > x0 and px < x1:
		out.append([Vector3(px, 0.0, dis_sur_z0() - 0.5), 2.2])
	return out


## Nokta (çerçeve) kişi konamayacak bir yerde mi (SurOyun.engeller(): kule + etek, merdiven, gedik molozu, sur gövdesi…).
## gedik_haric: gediğin molozu (onarım ekibi, düello) sayılmaz.
func engelde(p: Vector3, gedik_haric := true) -> bool:
	if eski_mi:
		return false
	var q := Vector2(p.x, p.z)
	for r: Rect2 in _engel:
		if gedik_haric and absf(r.get_center().x) < 0.5 and r.size.x < 15.0:
			continue
		if r.has_point(q):
			return true
	return false


## Güvenli doğma noktaları (SurOyun.dogma): çerçevede
func dogma(alan: String, n: int, tohum := 1453) -> Array:
	if eski_mi:
		return []
	var out: Array = []
	for p in a.dogma(alan, n, tohum):
		out.append(c(p["yerel"]))
	return out


# ------------------------------------------------------------------ set dekoru (depo, siper, doğuş, top)
## Bölümlerin LandWalls'tan aldığı set noktaları. Yeni yerleşim (karar 1-A): depo gediğe 15–19 m, eski yürüme mesafesine yakın;
## iç kulenin (x 0,2…9,2, eteğiyle −2,8…12,2; z ≤ 8) ve poternanın (x −17,9) dışında.

func depo() -> Vector3:
	return LandWalls.DEPOT if eski_mi else Vector3(-11.5, 0.0, 4.2)


func dogus() -> Vector3:
	return LandWalls.SPAWN if eski_mi else Vector3(-9.6, 0.05, 7.2)


func siperler() -> Array:
	return LandWalls.MANTLETS if eski_mi else [Vector3(-5.5, 0.0, 10.5), Vector3(5.5, 0.0, 10.5)]


## Urban'ın büyük topu (LandWalls.CANNON): ova kaydırmasıyla
func top() -> Vector3:
	return LandWalls.CANNON + ova_ofs()


## Barikat aşaması (oyunun 10'luk onarım sayacı → görselin 4 aşaması; karar 5-B). Eski: aynı sayı.
## 0–2 → 1 (açık), 3–5 → 2 (kazık/fıçı), 6–8 → 3 (toprak dolgu), 9–10 → 4 (barikat tam)
static func asama_of(onarim: int) -> int:
	if onarim <= 2:
		return 1
	if onarim <= 5:
		return 2
	if onarim <= 8:
		return 3
	return 4
