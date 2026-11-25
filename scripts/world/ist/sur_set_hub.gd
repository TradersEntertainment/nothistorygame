extends RefCounted
## TAŞIMA-10 — HUB SURU (ByzCity "walls" hub'ı: Bölüm 6b, 7b, 10h, 12b) — class_name YOK:
##   const SurHub := preload("res://scripts/world/ist/sur_set_hub.gd")
##
## Hub'ın kendi kutu iç suru, kuleleri ve süslü Romanos kapısı yerine YENİ SURUN "romanos" kesimi (SurOyun.kur, aynı kurucu
## IstSurlar._run; şehirdeki Romanos kapı koşusunun aynısı: aynı boy, tohum, seçenek) hub çerçevesine oturur:
##   kesim yereli (+x sur boyunca, +z ova, z 0 iç sur ortası) → hub yereli (iç sur x 34 hattında, dış yüz +x):
##   kesim +z → hub +x; kesim +x → hub −z; kapı ortası (kesim x 0) → hub z EXIT_POS.z (çıkış kapısı, 5,5);
##   iç surun şehir yüzü (zi0) → hub x HUB_IC_X (32,5: eski iç surun şehir yüzü, ByzCity._build_gate fx);
##   peribolos toprağı (y_peri −0,12) → hub y 0.
## İstanbul v2 içinde (IstBaglama): hub, kesimin GERÇEK dünya yerine oturur (hub_v2 = a.xf · M⁻¹); şehrin kendi "romanos"
## kapı dilimi kaldırılır, yerine bu oynanır kesim kurulur (kapı kanatları açılır, köprü yürünür). Komşu sur dilimleri şehrin.
## Geri dönüş (karar 13): `--eskisur` ya da `--eskisur=12b,10h,6,7` → eski kutu sur (ByzCity eski kod yolu) ve eski yerleşim.

const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")

## Yeni hub suru kullanan bölümler (kimlik: IstBaglama.sahne_bolumu, betik adı chapter<id>.gd)
const BOLUMLER := ["6", "7", "10h", "12b", "13", "23", "24"]     # TAŞIMA-12: 13 (yalnız şehir dalı), 23, 24 (ilk yarı)
const KESIM := "romanos"
## Eski iç surun şehir yüzü (ByzCity: x 34 − 1,5) ve çıkış kapısı (ByzCity.EXIT_POS)
const HUB_IC_X := 32.5
const KAPI_Z := 5.5

static var _a: RefCounted = null


## Bu bölüm yeni hub surunu mu kullanır (bölüm listesinde ve geri dönüş istenmemiş)
static func yeni(bolum: String) -> bool:
	# v2 kapalıysa (`--eski-dunya`, güvenlik anahtarı) eski dünyanın kutu surları kesimi çevirirdi: eski sur
	return bolum in BOLUMLER and not SurSet.eski_istendi(bolum) and IstBaglama.etkin()


## Bölüm 8y (Beyaz Havlu) yeni surda mı (`--eskisur=8y` ya da `--eskisur` eski)
static func yeni8y() -> bool:
	# TAŞIMA-12: geçici eski set kalktı (VISAUDIT float Station_coil_rope'un kök nedeni Stage.station'ın plant_feet'iydi,
	# ızgara değil: chapter8y.gd _build_lines; docs/_kanit_ist2_tasima12/rapor.md)
	return not SurSet.eski_istendi("8y") and IstBaglama.etkin()


## TAŞIMA-12 — uzak hub (IstSehir "hub_sehir": hub'ı oynamayan v2 bölümlerinde uzaktan görünen şehir; 7a, 11 uçuşu) yeni
## surla mı: hub kesimin gerçek yerinde (hub_v2), kutu iç sur/kuleler/Romanos kemeri kurulmaz (v2'nin kendi dilimleri).
## `--eskisur`, `--eskisur=<sahnedeki bölüm>` ya da `--eskisur=hub` eski (eski yer ve kutu sur).
static func uzak_yeni() -> bool:
	return IstBaglama.etkin() and not SurSet.eski_istendi(IstBaglama.sahne_bolumu()) and not SurSet.eski_istendi("hub")


## Kesim yereli → 8y bölge yereli (x 0 kapı ortası, +z ova, −z şehir): dönüşsüz; iç sur ortası z 0, peribolos toprağı y 0
static func M8() -> Transform3D:
	return Transform3D(Basis.IDENTITY, Vector3(0.0, -arayuz().y_peri(), 0.0))


## 8y bölge yereli → İstanbul v2 (kesimin gerçek yeri)
static func gate8y_v2() -> Transform3D:
	return arayuz().xf * M8().affine_inverse()


## Sahnedeki bölüm için (IstBaglama ve ByzCity aynı kararı verir)
static func sahnede() -> bool:
	return yeni(IstBaglama.sahne_bolumu())


static func arayuz() -> RefCounted:
	if _a == null:
		_a = SurOyun.arayuz(KESIM)
	return _a


## Kesim yereli → hub yereli
static func M() -> Transform3D:
	var a := arayuz()
	var b := Basis(Vector3.UP, PI * 0.5)
	return Transform3D(b, Vector3(HUB_IC_X - float(a.d["zi0"]), -a.y_peri(), KAPI_Z))


## Hub yereli → İstanbul v2 (kaydırmasız dünya): kesimin gerçek yeri
static func hub_v2() -> Transform3D:
	return arayuz().xf * M().affine_inverse()


## Kesim yerelindeki bir noktanın hub yereli
static func h(v: Vector3) -> Vector3:
	return M() * v


# ------------------------------------------------------------------ sorgular (hub yereli)

## İç surun şehir yüzü (hub x), peribolos yüzü, dış surun iç/dış yüzü
static func ic_yuz_x() -> float:
	return HUB_IC_X

static func ic_sur_dis_x() -> float:
	return h(Vector3(0, 0, float(arayuz().d["zi1"]))).x

static func dis_sur_ic_x() -> float:
	return h(Vector3(0, 0, float(arayuz().d["zo0"]))).x

static func dis_sur_dis_x() -> float:
	return h(Vector3(0, 0, float(arayuz().d["zo1"]))).x

## İç sur yolunun yüksekliği (hub y) ve ortası (hub x)
static func ic_yol_y() -> float:
	return h(Vector3(0, float(arayuz().d["HW"]), 0)).y

static func ic_yol_x() -> float:
	return h(Vector3.ZERO).x

## İç kuleler: [{"z" (hub, kule ortası), "w" (sur boyunca en), "p" (peribolosa taşma)}] — kesim yerelinden
static func ic_kuleler() -> Array:
	var out: Array = []
	for t in arayuz().kesim["kule"]["ic"]:
		out.append({"z": h(Vector3(float(t[0]), 0, 0)).z, "w": float(t[1]), "p": float(t[2])})
	return out

## Kapı (hub yereli): {"z", "en", "boy", "ic_esik", "peri", "dis_esik", "kopru_yakin", "kopru_uzak"}
static func kapi() -> Dictionary:
	var k: Dictionary = arayuz().kapi()
	var out := {"z": KAPI_Z, "en": float(k["en"]), "boy": float(k["boy"])}
	for ad in ["ic_esik", "peri", "dis_esik", "kopru_yakin", "kopru_uzak"]:
		out[ad] = h((k[ad] as Dictionary)["yerel"])
	return out


# ------------------------------------------------------------------ kurulum

## Kesimi hub'ın içine kurar. sec: "yan" (yan dilimler, varsayılan false: v2'de komşu dilimler şehrin), "uzak" (false),
## "zemin" (kesimin düz şehir/ova levhaları; v2'de arazi var: false), "kapi_acik", "kapi_kopru" ("saglam").
## Dönen: {"kok", "tutucu", "arayuz", "parca": {"kapi_kanat", "kapi_kopru"}, "ms"}
static func kur(host: Node3D, sec := {}) -> Dictionary:
	var t0 := Time.get_ticks_usec()
	var tut := Node3D.new()
	tut.name = "SurHub"
	tut.transform = sec.get("cerceve", M())
	host.add_child(tut)
	var k: Dictionary = SurOyun.kur(KESIM, {"ebeveyn": tut, "dunya": false, "parca": false, "kanca": false, "kapi_parca": true,
		"kapi_acik": bool(sec.get("kapi_acik", false)), "kapi_kopru": String(sec.get("kapi_kopru", "saglam")),
		"yan": bool(sec.get("yan", false)), "uzak": bool(sec.get("uzak", false))})
	if not bool(sec.get("zemin", false)):
		for ad in ["Toprak_ZeminSehir", "Toprak_ZeminOva"]:
			var z := (k["kok"] as Node).find_child(ad, false, false)
			if z != null:
				z.get_parent().remove_child(z)
				z.free()
	k["tutucu"] = tut
	(k["ms"] as Dictionary)["hub_ms"] = (Time.get_ticks_usec() - t0) / 1000.0
	if GameState.autotest:
		print("SURHUB kur bolum=%s kesim=%s ms=%.0f ic_yuz_x=%.2f ic_yol_y=%.2f dis_sur_dis_x=%.2f" % [IstBaglama.sahne_bolumu(), KESIM,
			float(k["ms"]["hub_ms"]), ic_yuz_x(), ic_yol_y(), dis_sur_dis_x()])
	return k


# ------------------------------------------------------------------ G21: saray avlusu ve kançılaryanın yeni yeri

## Bizans meydanının saray avlusu + kançılaryası (G22 kurar) hub yerelinde buraya taşınır: Lykos vadisinin kuzey yamacı
## (site A ölçülerek kuzeye kaydırıldı: güney terası %7,5 eğimli ve Lykos çizgisine sınırdaydı), iç surun şehir yüzünden
## ~430 m içeri, 84 × 70 m'lik alan (eğim ≤ %3; anıt, sarnıç ve Lykos çizgisiyle çakışmaz; ölçüm tests/_ist/lykos21_olc,
## docs/_kanit_lykos21/rapor.md). v2'de kapıdan buraya açık bir sokak gider (IstSokak._saray_yolu).
const SARAY_OFS := Vector3(-400.0, 0.0, 130.0)

## SARAY_OFS'un İstanbul v2 dünya konumu (kaydırmasız; y = hub yereli 0, arazi IstGeo.h ile okunur)
static func saray_v2() -> Vector3:
	return hub_v2() * SARAY_OFS
