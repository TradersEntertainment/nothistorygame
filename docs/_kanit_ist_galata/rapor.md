# Galata (Pera, Ceneviz kolonisi) — parça raporu

Dal: `wip/ist-galata`. Dosyalar: `scripts/world/ist/galata*.gd` (giriş: `IstGalata`), `tests/_ist/galata_onizleme.*`.

## 1. Araştırma özeti (Nisan 1453)
- Galata'da Ceneviz kolonisi (Pera) var; surlu, kendi podestàsı (Angelo Giovanni Lomellino) ile yönetiliyor, kuşatmada resmen tarafsız. 1 Haziran 1453'te ahidnameyle teslim. Kaynak: Wikipedia "Galata" (https://en.wikipedia.org/wiki/Galata); Cambridge IJMES "The Genoese in Galata, 1453–1682"; medievalists.net "The Genoese Colonies in Front of the Turkish Advance".
- Christea Turris (Galata Kulesi): 1348'de Cenevizliler yaptı, surların en yüksek noktasında; yerine eski Bizans "Megalos Pyrgos" kulesi. Dış çap 16,45 m, iç çap 8,95 m (kaynak: Wikipedia "Galata Tower"); yükseklik kaynaklarda 62,6–69,9 m arası değişir, modelde ~67 m alındı. Konik külah 1875 fırtınasında yıkılıp 1965–67'de yeniden yapıldı; 1453'te konik külahlı sayıldı (KESTİRİM: malzeme, çatı pencereleri).
- Surlar: koloni büyüdükçe yeni surlar eklendi, yamaçlarda hendek; 1864'ten sonra yıkıldı, kalıntı kule çevresinde (Wikipedia "Galata"). Kapı sayısı/şekli, burç aralığı, hendek ölçüsü BELİRSİZ: model kestirimdir.
- Palazzo del Comune (podestà sarayı): 1314'te yapıldı, 1315 yangını, 1316 onarım; Cenova'daki Palazzo San Giorgio örnek alındı (Wikipedia "Galata"). Yeri ve cephesi KESTİRİM (üç kemerli giriş, mazgallı teras, Aziz Georg armaları).
- San Domenico (sonradan Arap Camii, 1325 anılır): çan kuleli gotik kilise modeli. San Francesco, San Michele, San Benedetto: ad ve varlıkları anılır, yerleri ve biçimleri KESTİRİM (bu oturumda kaynak bulunamadı).
- Konum: kule Ayasofya'ya göre (−504 m D, +1892 m K) (`CityGeo.ANCHORS` ile aynı). Diğer yapıların konumu kestirimdir.
- Anakronizm yok: minare/cam/asfalt yok; bayrak = beyaz üzerine kırmızı haç (Cenova).

## 2. Oyuncu kabiliyetleri (kodtan hesap)
- `JUMP = 3.6`, g = 9,8 → zıplama = 3,6² / (2·9,8) = **0,66 m**; `STEP_H = 0,42 m` (zıplamadan basamak); `traversal.gd`: `REACH = 2,3 m`, `VAULT_MAX = 1,1 m` (tutunma açık bölümlerde).
- Tüm `climbs` yolları 0,30 m'lik basamak/ 0,4 m'lik sandık adımlarıdır (≤ STEP_H).

## 3. Öğe listesi
| id | ne | durum |
|---|---|---|
| galata_kulesi | Christea Turris | TAMAM (tepe yalnız Nihat'a; sundurma çatısına basamaklı yol) |
| galata_sur | kara suru, çift burçlu kapı, hendek sırtı | TAMAM |
| san_domenico / san_francesco / san_michele / san_benedetto | kiliseler | TAMAM |
| palazzo_comune | podestà sarayı | TAMAM |
| galata_loca | açık revaklı loca | TAMAM |
| ceneviz_evi | taş-ahşap ev | TAMAM |
| galata_rihtim | rıhtım, iskeleler, kadırga, vinç | TAMAM |
| galata_ambar | taş ambar | TAMAM |
| galata_tersane | kızak, yapım hâlinde kadırga, iskele | TAMAM (KABA hissi: gövde basit blok) |
| galata_bag / galata_mezarlik | bağ yamacı / mezarlık | TAMAM |

Her yapı: `build_<id>`, `perches_<id>`, `climbs_<id>` (galata.gd), ayrıca genel `IstGalata.build/perches/climbs(id,…)` ve `IstGalata.catalog()` (bakis, bakis_r, gorev).

## 4. Denetim
Önizleme: `xvfb-run … res://tests/_ist/galata_onizleme.tscn -- ist=<id|all> k=0.5 mod=audit|shots shots=KLASÖR`.
`cati_yolu` gerçek bir CharacterBody3D ile değil, `climbs` doğrusu boyunca 0,17 m aralıkla yükseklik profilinden (adım ≤ 0,43 m ve uç nokta yüksekliği) hesaplanır. `dar` 0,5 m ızgara + 5 örnekli (0,15 m) tarama olduğundan aşırı tutucudur (≈1,2–1,5 m aralıklar da işaretlenebilir).

## 5. ISTAUDIT (k = 0,5; k = 0,35 ve 1,0 de koşuldu: delik 0, havada 0, cati_yolu tam)
```
ISTAUDIT id=galata_kulesi k=0.50 tris=2924/192/192 draws=85/4/4 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=galata_sur k=0.50 tris=1956/60/60 draws=89/5/5 delik=0 dar=2 havada=0 cati_yolu=1/1
ISTAUDIT id=san_domenico k=0.50 tris=1576/60/60 draws=94/4/4 delik=0 dar=1 havada=0 cati_yolu=1/1
ISTAUDIT id=san_francesco k=0.50 tris=1540/60/60 draws=91/4/4 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=san_michele k=0.50 tris=1228/24/24 draws=73/2/2 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=san_benedetto k=0.50 tris=1540/60/60 draws=91/4/4 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=palazzo_comune k=0.50 tris=1480/24/24 draws=98/2/2 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=galata_loca k=0.50 tris=1080/36/36 draws=44/3/3 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=ceneviz_evi k=0.50 tris=718/24/24 draws=53/2/2 delik=0 dar=1 havada=0 cati_yolu=1/1
ISTAUDIT id=galata_rihtim k=0.50 tris=1926/36/36 draws=63/3/3 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=galata_ambar k=0.50 tris=940/24/24 draws=47/2/2 delik=0 dar=1 havada=0 cati_yolu=1/1
ISTAUDIT id=galata_tersane k=0.50 tris=1090/36/36 draws=48/3/3 delik=0 dar=3 havada=0 cati_yolu=1/1
ISTAUDIT id=galata_bag k=0.50 tris=4432/36/36 draws=24/3/3 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=galata_mezarlik k=0.50 tris=1348/60/60 draws=35/5/5 delik=0 dar=0 havada=0 cati_yolu=1/1
```
Üçgen sütunu: lod0/lod1/lod2 (lod 1 ve 2 aynı sadeleştirilmiş kütle). PARSECHECK PASS.

## 6. Bilinen kusurlar / bakılamayanlar
- Kule tepesine yürüyerek çıkış yok (yalnız Nihat; konma noktaları: külah ucu, şerefe korkuluğu); sundurma çatısına basamak var.
- Surun hendeği oyuk değil, zemin düzeyinde hendek + karşı sırt olarak kuruldu.
- Yapı konumları (kule hariç) ve kilise/saray biçimleri kestirimdir.
- lod 1 ayrı bir ara model değil, lod 2 ile aynı sade kütle.
- Tersane kadırgası blok gövde; mezarlık ve ambar kareleri 'kapı önü' dışında ayrıntılı incelenmedi (üç tur: k1 kule/kilise, k2 hepsi, k3 hepsi).
- dar-aralık denetimi tutucu ızgara; kalan 1–3 uyarı sınır sayımı olabilir.

## 7. Paftalar
- galata_bag_k50_kus15.jpg
- galata_kulesi_k50_cati.jpg
- galata_kulesi_k50_kus15.jpg
- galata_kulesi_k50_yaklasma_on.jpg
- galata_rihtim_k50_kus15.jpg
- galata_sur_k50_kus15.jpg
- galata_tersane_k50_kus15.jpg
- palazzo_comune_k50_cati.jpg
- palazzo_comune_k50_yaklasma_on.jpg
- san_domenico_k50_kus15.jpg
- san_domenico_k50_yaklasma_on.jpg
- san_michele_k50_yaklasma_on.jpg
