# İstanbul, Nisan 1453: bitki parçası (`wip/ist-bitki`) — ara rapor

Durum: KABA→ORTA. Ağaçlar, alan doldurucular ve yer öğeleri kuruldu, Godot'ta çalıştırıldı ve karelere bakıldı (3 tur).
Bu rapor ilk teslimdir; derinleştirme sürüyor.

## Araştırma (kısa, kaynaklı; sınırlı)
- Erguvan (Cercis siliquastrum) İstanbul'un simgesi, Nisan'ın ikinci yarısında çiçek açar
  ([Wikipedia](https://en.wikipedia.org/wiki/Cercis_siliquastrum), [insideoutinistanbul](https://www.insideoutinistanbul.com/judas-tree)).
  "1453'te erguvanlar çiçekteydi" iddiası kaynaklarda doğrulanmamış söylence olarak geçiyor: BELİRSİZ; Nisan renk seçimi buna değil iklime dayanıyor.
- Sur kesimlerinin barışta mezarlık ve sebze bahçesi olarak kullanıldığı anılıyor
  ([Koç Üniv. sur çalışması üzerinden](https://turkeytravelplanner.com/?p=2131)); Bizans bahçelerine dair bilgi kıt
  ([Gothein](https://www.gardenvisit.com/history_theory/library_online_ebooks/ml_gothein_history_garden_art_design/islamic_garden_design_history)).
- 1453'te iç şehirde bağ, bostan ve meyve bahçesi yoğunluğunu doğrudan belgeleyen kaynak BULUNAMADI. Şehir planındaki
  "boşluklar bostan/bağ" kabulü ve tür seçimi (badem, kiraz, incir, nar, zeytin, dut, servi, çınar, defne) KESTİRİM.
- Domates, mısır, biber ve patates bilerek yok (Yeni Dünya bitkisi).

## Oyuncu ölçüleri (player.gd / traversal.gd)
JUMP 3,6 m/s, yerçekimi 9,8 → zıplama ≈ 0,66 m; STEP_H 0,42 m; tutunma REACH 2,3, VAULT_MAX 1,1.
Bahçe duvarı 0,9 m: uçlarda 0,4 ve 0,7 m taş basamak (adımlar ≤ 0,42 ve ≤ 0,66). Teras kenarı 0,28 m (zıplamasız çıkılır).
Sarmaşıklı harabe duvarı basamakları: 0,35 / 0,70 / 1,05 / 1,60 / 2,10 / 2,70 m (en büyük adım 0,55 < 0,66).

## Öğe listesi
Ağaç (tek, gövde katı, taç/çalı çarpışmasız; `build_<tur>`): erguvan, badem, kiraz, çınar, servi, incir, defne, nar, zeytin, dut — TAMAM (kaba/orta).
Alan doldurucu (`build_patch_<tur>(host, alan, k, lod, tohum)`, MultiMesh; lod 2'de yalnız dokulu zemin): bag (teraslı),
bostan (bakla/soğan/marul), bugday, cayir (gelincik, papatya), bahce (meyve bahçesi), sazlik, kumsal, kaya, mezarlik (servili),
patika, toprak_yol, tas_yol — TAMAM (kaba/orta); bağ terası katı basamak.
Yer öğeleri: bahce_duvari (katı, üstü yürünür, basamaklı), cit (katı), dere (Lykos; sığ, görsel su), kopru (taş, rampalı, korkuluklu),
pinar, sarmasik (yıkık duvar + sarmaşık + ot) — KABA.
YAPILMADI: ayrı "kır çiçekleri" yaması (cayir içinde), zeytin/asma tek ağaç ayrıntısı, rüzgâr salınımı, dere kıyısında yürünür taban çukuru.

## ISTAUDIT (k = 0,5, lod 0 / 1 / 2 üçgen)
```
erguvan      tris 322 / 143 / 72     katı=1 havada=0
bag          33448 / 15991 / 2       katı=1 havada=0
bostan       26493 / 11990 / 2
bahce        51741 / 14049 / 2       katı=23 havada=0
cayir        51960 / 15508 / 2
bugday       51554 / 15422 / 2
bahce_duvari 1682 / 581 / 581        katı=5 havada=0
dere         6040 / 2095 / 4
kopru        60 / 60 / 60            katı=5 havada=0
```
Not: lod 2'de duvar ve köprü sadeleşmiyor (lod 2 ≤ 600 üçgen kuralı duvarda 581 ile tutuyor); ağaç lod 2'si ≈ 72 üçgen.
Diğer ağaç türleri, mezarlık, kumsal, kaya, sazlık, pınar, çit, sarmaşık ve yollar henüz denetim koşusundan geçmedi.
Çarpışmalı `delik`, `dar`, `cati_yolu` hesabı ve gerçek CharacterBody3D ile `climbs_*` sınaması YAPILMADI (denetim yalnız üçgen, çizim, katı sayısı ve havada kütleyi basıyor).

## Bilinen kusurlar
- Tüm ağaç tacı basit blob (düşük poligon); çınar/servi/zeytin kareleri bu turda incelenmedi.
- Köprü yalnız yukarıdan bakıldı; rampa eğimi gözle doğrulanmadı. Dere suyu düz yüzey.
- Yolların kenarı belirsiz; bağda ağaç yok, asma dalları basit.
- `catalog()`: konum alanları 0; `bakis`/`gorev` yok (bitki "ünlü eser" değil, gerekmiyor).
- Katalog `perches` yalnız ağaç gövde tepesi (çarpışma gövde tepesinde biter).

## Paftalar
Bu klasördeki `*.jpg`: erguvan yerden (doğu), bahçe kuş bakışı 15 m, bağ 15 m, dere 15 m, bahçe duvarı yerden, köprü 15 m, çayır 15 m.
