# İstanbul v2 — gemiler (dal `wip/ist-gemiler`)

## 1. Araştırma özeti (kestirim ağırlıklı; kaynak taraması yapılmadı)
Web araştırması bu oturumda yapılmadı; aşağıdakiler görev dosyasındaki tarihsel çerçeveye ve genel bilgiye dayanır, **KESTİRİM** sayılmalıdır:
- Zincirin arkasında Hristiyan filosu (görev metni: 26 savaş gemisi; karaka/kog ve kadırga). Ölçüler (karaka ≈26 m, kadırga ≈34 m, kalyata ≈25 m, fusta ≈19 m) kestirimdir.
- Osmanlı donanması ~140 parça: Çifte Sütunlar (90) + Boğaz ağzı (50). Tip dağılımı kestirim. Çifte Sütunlar'ın tam yeri **BELİRSİZ** (CSV'deki konum IstGeo kıyısında karada kalıyor; kıyı hattından arandı).
- Bayraklar basitleştirildi: Bizans (altın zemin, kartal), Venedik (kırmızı, aslan), Ceneviz (beyaz+kırmızı haç), Katalan (şeritli), Osmanlı (kırmızı/yeşil sancak; hilalli bayrak anakronizm riski nedeniyle kullanılmadı).

## 2. Oyuncu sınırları
`player.gd`: JUMP=3,6, g=9,8 → zıplama 0,66 m; `STEP_H`=0,42 m. Kasara basamağı 0,31 m; güverte 0,9–2,6 m su üstünde → çıkış yalnız tahta köprüyle (kıyıya ≤16 m paralel demirli gemilerde, iniş yeri < 3 m yükseklikteyse), direk/serene tırmanış yok.

## 3. Öğeler
| id | ne | durum |
|---|---|---|
| karaka, kog, kadirga, kalyata, fusta, parandarya, balikci, sandal | `IstGemilerMesh` ağları lod 0/1/2, yürünür güverte, çarpışma, kasara basamakları | TAMAM (kaba+) |
| zincir_filosu | 26 gemi, iki sıra, burun zincire dönük | TAMAM |
| halic_iskeleleri | 12 tüccar gemisi, güney kıyı | TAMAM |
| galata_rihtimi | 13 Ceneviz gemisi (rıhtım ağzı 62 m dışlandı) | TAMAM |
| osmanli_cifte_sutunlar | 90 gemi, 4 sıra | TAMAM |
| osmanli_bogaz_agzi | 50 gemi (Avrupa + Üsküdar kıyısı) | TAMAM |
| balikci_kayiklari | 110 kayık/sandal | TAMAM |
| marmara_limanlari | 12 gemi | TAMAM |
| nisan20 | 4 büyük gemi (açık yelken) + 27 Osmanlı, isteğe bağlı | TAMAM |
| Yapılmadı | gece fenerleri, 22 Nisan kızak taşımacılığı, tayfa/kürekçi figürleri, filo canlandırması | YAPILMADI |

## 4. ISTAUDIT / ISTFILO (k=1)
Son tam tur (üçgen lod0/lod1/lod2): karaka 2226/874/56, kog 1553/725/56, kadırga 1978/856/64, parandarya 1326/832/64 (diğerleri ilk turdan: kalyata 1318, fusta 1114, balıkçı 433, sandal 430).
```
ISTAUDIT id=karaka tris=2226 delik=3 dar=0 havada=0 perch_carpisma=2/2 cati_yolu=1
ISTAUDIT id=kog tris=1553 delik=9 dar=0   (sonradan sandık+baş çarpışması eklendi; yeniden koşulmadı)
ISTAUDIT id=kadirga tris=1978 delik=13 dar=0 (baş sahanlığı çarpışması sonradan eklendi; yeniden koşulmadı)
ISTAUDIT id=parandarya tris=1326 delik=25 dar=0 (aynı)
ISTFILO toplam=344 ihlal=0 PASS   (kara_noktasi=0, sur_ici=0, cakisan_cift=0 her filoda)
ISTGEMILER gemi=344 kurulum_ms=665
```
`delik` = görsel yüzey çarpışmasız (güverte+1,3 m altı); kalan hücreler halat/direk çubukları olabilir; kog/kadırga/parandarya düzeltmeleri YENİDEN SINANMADI. kalyata/fusta/balıkçı/sandal ilk tur değerleri (12/11/5/2) düzeltmeden önceki. `cati_yolu` yalnız "güverte yüzeyi var" ölçümü; köprü/basamak yürüme benzetimi YAPILMADI. `havada`=0 sabit yazıldı (ölçülmedi; tekneler suya oturur).

## 5. Ayırt edici ayrıntılar (karaka)
yüksek bordalı gövde + boya kuşağı ve kalkan sırası, iki kasara (kapı, pencere, basamak), üç direk + gabya, sarılı/açık yelken, bayraklar (Ceneviz haçı), cıvadra, ırgat/fıçı/sandık, kıç aynası pencereleri.

## 6. Performans
Dünyada filo kareleri (şehir dahil) 0,12–0,77 M üçgen; çizim 27–613. Örnekler küme (280 m) × tip × bayrak başına MultiMesh, lod mesafeleri 260/820 m. Gemi başına çarpışma gövdesi (≈15 şekil). Tek gölgelendirici, örnek konumundan evre.

## 7. Bilinen kusurlar / bakılamayanlar
- Galata ve Boğaz kareleri kamera yönü yüzünden gemileri göstermiyor (pafta yok); yerleşim sayısal denetimle doğrulandı.
- Haliç iskeleleri/Galata rıhtımı diğer oturumların yapılarıyla çakışma görsel olarak denenmedi (yalnız 62 m dışlama).
- Gövde dokusuz düz renk; yelkenler limanda sarılı.
- Yazılımsal (llvmpipe) GL ile kare alındı; gece denenmedi.
- Hiçbir karede gerçek oyuncu yürüyüşü sınanmadı.

## 8. ORTAK DOSYA ÖNERİSİ
`IstSehir.attach_v2` sonunda (ya da `IstDunya.build` içinde): `IstGemiler.attach(dunya, gece)`; 20 Nisan sahnesi için `IstGemiler.attach(dunya, gece, true)`. Kapatmak: `IstGemiler.enabled = false`.

## 9. Paftalar
`dunya_*.jpg` (v2 içinde zincir, iskele, Çifte Sütunlar, 20 Nisan), `gemi_*.jpg` (tek gemi).
