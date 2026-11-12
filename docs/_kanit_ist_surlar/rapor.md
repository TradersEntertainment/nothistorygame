# İstanbul 1453 — SURLAR parçası (dal `wip/ist-surlar`)

Dosyalar: `scripts/world/ist/surlar.gd` (`IstSurlar`: ölçüler, yerleşim, sur dilimi, kuleler, hendek, kayıt, sarmalayıcılar),
`surlar_kapi.gd` (`IstSurlarKapi`: kemer, kapı kanatları, mermer kaplama, Romanos koridoru),
`surlar_ayrinti.gd` (`IstSurlarAyrinti`: Nisan 1453 izleri), `tests/_ist/surlar_onizleme.{gd,tscn}`.
Var olan hiçbir dosya değiştirilmedi.

## 1. Araştırma özeti
Kaynaklar: Wikipedia "Walls of Constantinople" (kesit, kule sayıları, kapı listesi; depodaki `docs/ISTANBUL_1453.md` §3 de
aynısını aktarıyor), Livius.org "Theodosian walls" fotoğraf notları, worldhistory.org "Theodosian Walls", Byzantine Legacy
"Golden Gate". Koordinatlar: `CityGeo.ANCHORS` (golden_gate, pege, romanos, harisios) ve aralarında doğrusal kestirim.

- **İç sur:** ~5 m kalın, ~12 m yüksek, kireçtaşı kaplama + tuğla kuşakları (7–11 sıra), harç/kırık tuğla çekirdek. 96 kule,
  çoğu kare, 15–20 m, aralık 21–77 m (ortalama ~55 m). Kule yüksekliği ve aralığı kaynaklarda değişiyor: ortalama alındı.
- **Peribolos:** iki sur arası teras, ~15–20 m (15 alındı).
- **Dış sur:** ~2–2,5 m kalın, 8,5–9 m yüksek, kuleleri 12–14 m, ~4 m geniş, iç kulelerin arasına denk gelir.
- **Parateikhion + hendek:** dış surun önünde teras ve alçak sur; hendek ~20 m geniş, 6–10 m derin (kaynaklar 6–7 ile
  10 arası; 6 alındı), iç yüzünde istinat duvarı, enine bölmeli. Görev metnindeki "18 m" yerine kaynaklardaki 20 m kullanıldı.
- **Kapılar (kuzeyden güneye):** Kharisios (Edirnekapı), Pempton/5. Askerî (Sulukule), Aziz Romanos (Topkapı; ~26,5 m derin
  kapı yapısı), Rhegion (Mevlanakapı; en iyi korunan), Pege (Silivrikapı), Ksylokerkos (Belgrat; 1189'da örülmüş), Altın
  Kapı (mermer üçlü kemer, iki mermer kule; 1453'te kapalı olduğu BELİRSİZ, kapalı alındı), Kaligaria/Eğrikapı (Blakhernai
  kesimi, hendeksiz), Kerkoporta (kule 96 yakını; yeri kazıyla doğrulanmadı, kestirim).
- **Mesoteikhion:** Lykos vadisinin sura değdiği alçalan kesim; 1453'te en ağır bombardıman burada. Yükseklik farkı kaynakta
  yok: kestirim olarak aynı kesit + en yoğun hasar/stauroma + vadi suyu geçidi (BELİRSİZ) yapıldı.
- **Nisan 1453:** top oyukları, kazık-fıçı-toprak onarımı (stauroma; Barbaro/Kritovulos anlatımı), iskeleler, mancınık ve taş
  gülle yığınları; sancaklar kestirim (kırmızı-altın Palaiologos, mavi-beyaz Ceneviz payı).
- **Anakronizm taraması:** minare, cam, barut varil/siper yok; tüfek/humbara yok (top gülleleri yalnız iz olarak).

## 2. Oyuncu ölçüleri (hesap)
`player.gd`: `JUMP = 3.6`, yerçekimi 9,8 → zıplama yüksekliği 3,6² / (2 · 9,8) = **0,66 m**; `STEP_H = 0,42 m` (basamak
zıplamadan çıkılır); `traversal.gd`: `REACH = 2,3 m`, `VAULT_MAX = 1,1 m`. Basamaklar 0,26 m yükseklik × 0,42 m ayak (< 0,42).
Korkuluk 1,2 m (> VAULT_MAX: aşılamaz), sur gövdeleri `no_climb`: yüksek yüz düz ve tutunmasız.

## 3. Öğeler
| id | ne | durum |
|---|---|---|
| `sur` (`build_run(host, uzunluk, k, lod, tohum)`) | parametreli sur dilimi: iç sur + kuleler + peribolos + dış sur + kuleler + parateikhion + hendek | TAMAM |
| `altin_kapi` | mermer üçlü kemer (iç ve dış yüz), mermer sütun çiftleri, silme, iki büyük mermer kule, tuğla ile örülü geçit | TAMAM |
| `ksylokerkos` | örülmüş kapı (1189), dar kule çifti | TAMAM |
| `pege` | açık kapı, kanatlar duvara yaslı, iki kule | TAMAM |
| `rhegion` | açık kapı, uzun çıkıntılı kuleler | TAMAM |
| `romanos` | açık kapı + iki duvarlı kapı koridoru (peribolos boyunca), büyük kuleler, en çok hasar | TAMAM |
| `pempton` | küçük askerî kapı, ağır hasar | TAMAM |
| `kharisios` | büyük kapı, en derin kule çıkıntısı | TAMAM |
| `kaligaria` | Blakhernai kesimi kapısı, hendeksiz | KABA (yer ve ayrıntı kestirim) |
| `kerkoporta` | küçük kapı, hendeksiz kısa kesim | KABA (kapı yüksek eşikli değil; yeri kestirim) |
| `mesoteikhion` | Lykos vadisi kesimi: en yoğun top izi ve stauroma | KABA (vadi eğimi ve dere geçidi yapılmadı) |

Her öğede: `build_X(host,k,lod)`, `perches_X(k)`, `climbs_X(k)`, `catalog()` kaydı (`bakis`, `bakis_r`, `gorev`). Ek: `IstSurlar.dims(k)`
(ölçüler), `moat_strip(k)` (hendeğin oyacağı şerit: şehir zemini bu şeridi açık bırakmalı; surlar kendi zeminini kurar),
`route()` (hat dayanakları), `build_by_id(host,id,k,lod)`.

**Yerleştirme notu (şehir kurucusu için):** yerel çerçeve: +x sur boyunca, +z dış yüz (ova/hendek), -z şehir, z = 0 iç sur ortası.
`yon_derece` = yerel +x ekseninin kuzeyden saat yönü açısı; host'u `rotation.y = -deg_to_rad(yon_derece) + PI/2` ile döndürün
(+x doğu iken 90°). Her öğe kendi zeminini (kaldırım, peribolos, teras, hendek) 1,5 m kalın katı levha olarak kurar: aynı
yerdeki şehir zemini bu şeridi (~z −15 … +50 m × k'ya bağlı) oymalı ya da altta kalmalıdır. Kapılar `build_run`'dan uzun
(150 × k, en az 90 m) bir kesittir; iki yanı `sur` dilimiyle uç uca eklenir (uçlarda tam yükseklikli hendek geçidi vardır).

## 4. Ayırt edici ayrıntılar (beşten çok)
Sur dilimi: (1) taş-tuğla şeritli kaplama (opus mixtum), (2) iki katlı iç kuleler: yan kapılı gerçek oda, çatı levhası, mazgallı
tepe, (3) dış kulelere sur üstünden merdivenli çıkış, (4) alçak parateikhion + 20 m'lik bölmeli hendek ve rampaları, (5) top oyukları
ve kazık-fıçı-toprak onarımı (stauroma), (6) iskele, mancınık, taş gülle yığını, nöbetçi kulübesi, sancaklar, sarmaşık.
Altın Kapı: mermer cephe, üçlü kemer, sütun çiftleri + silme, örülü kemer, mermer kule çifti. Romanos: duvarlı koridor kapısı.
Kapılar: tuğla kemer kama taşları, demir bağlı açık kanatlar, lento şeridi.

## 5. ISTAUDIT (k = 0,35 / 0,5 / 1,0; lod 0)
Katı çarpışmalı sınama: yukarıdan 0,5 m ızgara (delik), 0,1 m aralıkla nokta sorgusu (dar), taban desteği ışını (havada), gerçek
CharacterBody3D (kapsül 0,35 × 1,8, basamak 0,42) ile `climbs_X` girişleri (cati_yolu).
```
ISTAUDIT id=sur k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=altin_kapi k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=ksylokerkos k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=pege k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=rhegion k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=romanos k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=pempton k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=kharisios k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=kaligaria k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=5/5
ISTAUDIT id=kerkoporta k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=5/5
ISTAUDIT id=mesoteikhion k=0.35 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=sur k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=altin_kapi k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=ksylokerkos k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=pege k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=rhegion k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=romanos k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=pempton k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=kharisios k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=kaligaria k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=5/5
ISTAUDIT id=kerkoporta k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=5/5
ISTAUDIT id=mesoteikhion k=0.50 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=sur k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=romanos k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=ksylokerkos k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=pege k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=rhegion k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=pempton k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=kharisios k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=kaligaria k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=5/5
ISTAUDIT id=kerkoporta k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=5/5
ISTAUDIT id=mesoteikhion k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7
ISTAUDIT id=altin_kapi k=1.00 lod=0 delik=0 dar=0 havada=0 cati_yolu=7/7   (sütun yerleşimi düzeltildikten sonra yeniden koşuldu; k=0,5 de yeniden: 0/0/0, 7/7)
```
33 koşu: hepsinde delik = dar = havada = 0; çatı yolu 7/7 (hendeksiz kesimlerde 5/5).

## 6. Üçgen ve çizim sayıları (k = 0,5)
Çizim sayısı: lod 0'da durağan görseller `Props.bake_static` ile birleştirilir (`IstSurlar.bake`; denetim kapatıp bakar).
| id | lod 0 üçgen | lod 0 çizim (ham / birleşik) | lod 1 üçgen | lod 2 üçgen |
|---|---|---|---|---|
| sur | 16280 | 511 / 14 | 860 | 276 |
| altin_kapi | 15614 | 577 / 15 | 944 | 360 |
| ksylokerkos | 17810 | 590 / 14 | 920 | 336 |
| pege | 16876 | 597 / 14 | 956 | 372 |
| rhegion | 16212 | 576 / 14 | 956 | 372 |
| romanos | 18656 | 663 / 16 | 956 | 372 |
| pempton | 17546 | 654 / 14 | 956 | 372 |
| kharisios | 19294 | 672 / 14 | 956 | 372 |
| kaligaria | 15158 | 543 / 13 | 820 | 264 |
| kerkoporta | 14698 | 520 / 13 | 820 | 264 |
| mesoteikhion | 26016 | 850 / 14 | 896 | 312 |

Bütçe: lod 0 ≤ 60 bin (en çok ~29 bin, mesoteikhion k=1'de ~40 bin); lod 1 ≈ %4–6 (≤ %15); lod 2 ≤ 600 (en çok 372).

## 7. Bilinen kusurlar
- **Kule tepelerine yürüyerek çıkış yok** (iç kule tepesi sur üstünden 7 m yukarıda); tepeler Nihat konma noktasıdır
  (çarpışmalı). Dış kule tepelerine merdiven var. İç kulelerin odalarına sur üstünden girilir (kapılı).
- Sur gövdesi tek parça düz levha: kule dışında payanda, kemerli niş ve kesme taş sırası detayı yok; doku (`ashlar`) görünümü
  verir. Yakından tuğla bantları iri.
- Mesoteikhion'da vadi eğimi, su geçidi ve gerçek gedik (yıkık dış sur parçası) yok; yalnız hasar yoğunluğu artırıldı. Gerçekte dış sur
  burada açılmıştı: delik olmaması kuralı gereği gedik yerine stauroma yığınları kullanıldı.
- Kerkoporta'nın yüksek eşikli küçük kapısı ayrıca modellenmedi (genel kapı kesiti).
- Altın Kapı'nın 1453'te kapalı olup olmadığı BELİRSİZ; kapalı alındı. Kule/oda iç dekoru (mobilya) yok.
- Hendek rampaları yalnız iki yerde (yakın yaka x ≈ −0,32 L, karşı yaka x ≈ +0,32 L); bölme duvarı yok, uçlar tam yükseklikli set.
- Sancak renkleri ve mancınık biçimi kestirim. Işık ve ateş (`Flame`) kullanılmadı (gündüz sahne); gece sürümü şehir kurucusuna bırakıldı.
- lod 1/lod 2'de kütle çarpışması yalnız lod 1'de var; lod 2 görsel.

## 8. Bakılamayanlar
Oyun içi Nihat uçuşu (yan görev işareti) ve şehir kurucusunun `catalog()` okuması sınanmadı; gece/ateşli görünüm; gerçek
`world1453.gd` içinde yerleşim; çok kuleli uzun dizi (1 km+) performansı.

## 9. Paftalar
- `pafta_01_kapi_a1_dis_orta.jpg`
- `pafta_02_kapi_e1_45_gb.jpg`
- `pafta_03_a4_sehir.jpg`
- `pafta_04_c1_sur_ustu.jpg`
- `pafta_05_c2_dis_sur_ustu.jpg`
- `pafta_06_c4_kule_cati.jpg`
- `pafta_07_d1_kus_15m.jpg`
- `pafta_08_a2_dis_sol.jpg`
- `pafta_09_d2_kus_60m.jpg`
- `pafta_10_d3_tepe.jpg`
- `pafta_11_e2_45_gd.jpg`
- `pafta_12_f2_lod2.jpg`
