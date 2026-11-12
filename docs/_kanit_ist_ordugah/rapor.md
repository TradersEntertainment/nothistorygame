# İstanbul v2 — ordugâh (wip/ist-ordugah) raporu

Durum: ÇALIŞIR ama BİTMEDİ. Tek tur görsel düzeltme + bir tur denetim yapıldı (görev en az üç tur istiyor: YAPILMADI).

## Araştırma (kaynaklı; kısa)
- Zağanos Paşa Haliç'in kuzeyinde, Galata'yı gözleyen tepelerde: hurriyetdailynews.com "The beginning of the end of Constantinople"; worldhistory.org 1453 makalesi.
- Büyük top Aziz Romanos (Topkapı/Mesoteikhion) karşısında, öküz ve ~200 kişiyle sürüklendi (aynı kaynaklar). Karaca Paşa Rumeli beylerbeyi (aynı).
- Gemilerin karadan yürütülmesi 21–22 Nisan 1453; güzergâh kaynakta değişiyor: Tophane–Kumbaracı–Asmalımescit–Tepebaşı–Kasımpaşa (milliyet.com.tr) ya da Dolmabahçe–Kasımpaşa (Wikipedia, Kasımpaşa). Ben ilkini aldım: KESTİRİM.
- Ön safın sura ~760 m uzaklığı tek kaynakta; ben surdan 112 m (dünya, = 224 m gerçek) siper kurdum: KESTİRİM (görev ~400 m×0,5 = 200 m dedi).
- Maltepe otağı, İshak Paşa konumu, 14 bataryanın tek tek yeri, Çifte Sütunlar'ın biçimi, fıçı köprüsünün tam yeri: kaynak BULUNAMADI → hepsi KESTİRİM. Konumlar `kara_suru` hattından (ark uzunluğu u, dış yön d) türetildi; Mesoteikhion ≈ u 1540.
- Oyuncu sıçrama yüksekliği: JUMP 3,6 → 3,6²/(2×9,8) = 0,66 m; STEP_H 0,42; tutunma REACH 2,3; VAULT_MAX 1,1 (player.gd, traversal.gd). Basamaklar 0,27 m.

## Öğeler
| id | ne | durum |
|---|---|---|
| otag | otağ + kazık çit + divan/hazine çadırı + yeniçeri halkası + gözcü kulesi (merdivenli) + tuğlar | TAMAM (ilk tur) |
| sahi_top | Şahi topu bataryası (8,2 m top, vinç, öküz sırası) | TAMAM (ilk tur) |
| batarya_01..13 | toprak tabya, gabyon, top, gülle, fıçı, araba, öküz | TAMAM (ilk tur) |
| mancinik ×4, kule ×3 | mancınık, kuşatma kulesi (yan merdiven) | TAMAM (ilk tur) |
| mescit, pazar, mutfak, ahir (×3 bölge) | servis alanları | KABA |
| siper (24 dilim) | sedde + kazık çit + gabyon + hendek ŞERİDİ | KABA: hendek gerçek çukur değil (arazi ağı oyulmuyor) |
| kanat_* (≈85 hücre) | Anadolu, Rumeli, yeniçeri, başıbozuk, Zağanos çadır alanları (MultiMesh) | TAMAM (ilk tur) |
| diplokionion | Çifte Sütunlar, iskele, stokta gemiler, depo | KABA |
| kizak | kızak yolu (güverte + ray + yağ izi) | KABA: eğim yok (parçalar düz, yamaçta basamaklı) |
| fici_kopru | Haliç fıçı köprüsü | KABA: uçlarda kıyıya bağlantı doğrulanmadı |

Arayüz: `IstOrdugah.catalog()`, `build_<x>(host,k,lod)`, `perches_<x>`, `climbs_<x>`, `build_kanat(host, alan, tur, k, lod, tohum)`, `attach(dunya, gece)` (akışlı lod 2→1→0; `IstOrdugahYonetici`).
Gereçler gerçek boyda; k yalnız tabya/külliye genişliğini etkiler. k = 0,35 ve 1,0 ile ayrıca bakılmadı: YAPILMADI.

## ISTAUDIT (lod 0, k=0,5; ham)
```
otag tris=10492 draws=6 delik=666 gorunmez=928 dar=0 havada=8 cati_yolu=1/1
sahi_top tris=5226 delik=122 gorunmez=161 dar=124 havada=3 cati_yolu=2/2
batarya tris=7902 delik=128 gorunmez=190 dar=192 havada=5 cati_yolu=2/2
mancinik tris=434 cati_yolu=1/1 ; kule tris=932 cati_yolu=1/1
mescit 516 ; pazar 2896 (delik=480) ; mutfak 2096 ; ahir 1756 ; siper 3516 (dar=59)
diplokionion 2546 (delik=512, havada=12, cati_yolu=1/1) ; kizak 3392
fici_kopru 65532 (düzeltmeden önce; sonra yeniden ölçülmedi) ; kanat_yeniceri 27052 ; kanat_anadolu 21192
```
Ölçüm sınırları (dürüstçe): `delik`/`gorunmez` görsel yüzeyle çarpışma yüksekliği farkını sayar; çadır MultiMesh'leri yaklaşık kutuyla temsil edildiği için çadırlı yerlerde sayılar büyük ve kısmen yapay (kanat_* delik 2000–6000 hücre: gerçek delik mi ölçüm yapaylığı mı AYRIŞTIRILMADI). `cati_yolu` gerçek Player ile değil, yedek bir CharacterBody3D (0,42 m basamak + 0,66 m sıçrama) ile sınandı; ilk otağ koşusu 0/1 çıktı (sınama noktası yanlıştı), nokta düzeltilince 1/1. Kızak ve siper tırmanma yolu sınanmadı. lod 1/2 üçgenleri: otağ 5932/5212, batarya 4152/3504 (lod 2 hedefi ≤600'ün ÜSTÜNDE: KUSUR).

## v2 içinde (gerçek yerinde)
`tests/_ist/ordugah_onizleme.tscn -- v2=1 liste=docs/_kanit_ist_ordugah/v2_liste.txt`: IstDunya + IstSehir.attach_v2 + IstOrdugah.attach; 10 kare, kuyruk 0'a indi, SCRIPT ERROR yok. Çadır denizi, otağ külliyesi ve siper hattı görünür. Performans (RINFO) ölçülmedi.

## Bilinen kusurlar
- Önizleme aydınlatması soluk; ahşap dokusu aşırı turuncu (ikinci turda koyulaştırıldı; yeniden kare alınmadı).
- Siper çiti düz levha (kazık sırası yalnız lod 0'da üstte).
- Gemi gövdeleri (stok) kaba bloklar; gemiler oturumunun gemileri ayrı.
- Zemin eğimi: yapılar tek yükseklik örneğiyle oturuyor, eğimli yerde etek yok.
- Gece (Flame) yalnız kodlandı, karelenmedi.

## Şehre bağlama önerisi (ORTAK DOSYA ÖNERİSİ)
`IstSehir.attach_v2` sonunda (veya IstDunya.build içinde): `IstOrdugah.attach(dunya, gece_)`.
Havadan kare: `IstOrdugahYonetici.kurulan`/`kuyruk` akış durumunu verir.

## Paftalar
`pafta/` altında 12 JPEG: tekil yapılar (önizleme) ve v2 kareleri.
