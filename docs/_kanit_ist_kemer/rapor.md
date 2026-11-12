# İstanbul 1453 — kemer parçası (dal `wip/ist-kemer`) raporu

Durum: ilk teslim (kaba değil ama derinleştirilecek). Dosyalar: `scripts/world/ist/kemer*.gd` (kit, su, kilise, harabe, ana kayıt),
`tests/_ist/kemer_onizleme.{gd,tscn}`. Var olan hiçbir dosya değiştirilmedi.

## Araştırma özeti (kaynaklı; kestirimler işaretli)
- Valens (Bozdoğan) Kemeri: özgün boy ≈ 971 m, ayakta kalan ≈ 921 m, en yüksek ≈ 28–29 m; 3. ve 4. tepe arasındaki vadiyi geçer;
  18–73. kemerler çift katlı, uçlarda tek katlı (kaynak: Wikipedia "Aqueduct of Valens", kulturenvanteri.com). Osmanlı onarımları
  (II. Mustafa, Süleyman) 1453'ten sonradır, modele KATILMADI. 1453'te kullanımdaydı → durum "saglam".
- Pantokrator (Zeyrek): 4. tepe yamacında, Havariyun'un doğusunda; üç bitişik kilise, güney kilise (katholikon) başkentteki en büyük
  "kapalı haç" planı; 12. yy (≈1118–1136), Hungaria'lı İrini; imparatorluk mezarları; manastır + hastane (xenon) + avlu
  (WMF, istanbulclues, pallasweb). Kubbe çapları kaynaklarda bulunamadı → KESTİRİM.
- Havariyun: Fatih Camii yerinde, 1453'te harap; beş kubbeli haç planı + Konstantin mezar rotundası (Heroon) — plan bilgisi
  genel bilgi; ayrıntı ölçüler KESTİRİM.
- Aspar (Çukurbostan) 152 × 97 m, ≈ 10 m derin, 1453'te içi bostan/köy (genel bilgi). Polyeuktos ≈ 52 × 52 m, 1453'te büyük ölçüde
  yıkık temel. Lips (Fenari İsa) ikiz kilise, Kyriotissa, Vefa, Pantepoptes, Gül: haç planlı/dört sütunlu orta tip (genel bilgi).
- BELİRSİZ: bütün `dogu_m/kuzey_m` konumları ±300 m kestirimdir; `yon_derece` Bozdoğan için 118° kestirim. Ayrıntı ölçüler kestirim.

## Oyuncu yetenekleri (player.gd / traversal.gd'den hesap)
JUMP = 3.6, yerçekimi 9.8 → zıplama = 3.6² / (2·9.8) = **0,66 m**; STEP_H = 0,42 m (zıplamadan çıkılan basamak); VAULT_MAX = 1,1 m;
REACH = 2,3 m (tutunma). Tüm basamaklar 0,28 m (≤ 0,3), eğimli çatılar ≤ 25°, korkuluk 1,1 m, yürüme yolu ≥ 1,5 m, geçit ≥ 3,6 m.

## Öğeler
| id | ne | durum |
|---|---|---|
| bozdogan | iki katlı Valens Kemeri, parametreli uzunluk (k·970 m), altından geçilir, üstü yürünür, uç merdivenleri | TAMAM |
| havariyun | beş kubbeli haç, harap (2 kubbe çökmüş, moloz), Heroon rotundası, ağaçlar | TAMAM (derinleştirilecek) |
| pantokrator | üç bitişik kilise (güney büyük, orta iki kubbeli), ortak narteks, avlu, kuyu başı, hücreler, hastane kalıntısı | TAMAM (derinleştirilecek) |
| lips | ikiz kilise (kuzey kurşun, güney kiremit) | TAMAM |
| kalenderhane, vefa, pantepoptes, gul | haç planlı tek kubbeli kiliseler (narteks, apsisler) | TAMAM (ayırt edici ayrıntı KABA) |
| aspar | sedli açık sarnıç, içi bostan tarhaları, kulübe, kuyu, ağaçlar | TAMAM (zemin çukuru yok: sed yükselir, bkz. kusurlar) |
| polyeuktos | yıkık temel, kırık pilyeler, kemer parçası, devrik sütunlar | KABA |

Beş ayırt edici ayrıntı — Bozdoğan: çift kat yarım daire kemerler, eğimli döşeme, parapet + kanal kapağı, hava bacaları, uç merdivenleri.
Kiliseler: kurşun kaburgalı kubbe + haç, pencereli tambur, tuğla alınlıklı yassı tonoz kollar, apsis konisi, anıtsal kapı + basamak.

## ISTAUDIT (k = 0,5; 0,35; 1,0 — lod 0)
```
ISTAUDIT id=bozdogan k=0.5 lod=0 tris=15496 draws=106 delik=0 dar=0 havada=0 cati_yolu=2/2
ISTAUDIT id=havariyun k=0.5 lod=0 tris=8374 draws=167 delik=1 dar=24 havada=1 cati_yolu=1/1
ISTAUDIT id=pantokrator k=0.5 lod=0 tris=14046 draws=249 delik=43 dar=2 havada=0 cati_yolu=1/1
ISTAUDIT id=lips k=0.5 lod=0 tris=12232 draws=172 delik=10 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=kalenderhane k=0.5 lod=0 tris=6256 draws=98 delik=8 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=vefa k=0.5 lod=0 tris=4084 draws=81 delik=2 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=pantepoptes k=0.5 lod=0 tris=6220 draws=95 delik=8 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=gul k=0.5 lod=0 tris=6244 draws=97 delik=6 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=aspar k=0.5 lod=0 tris=3880 draws=86 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=polyeuktos k=0.5 lod=0 tris=1456 draws=63 delik=29 dar=9 havada=0 cati_yolu=1/1
ISTAUDIT id=bozdogan k=0.35 lod=0 tris=9676 draws=90 delik=0 dar=0 havada=0 cati_yolu=2/2
ISTAUDIT id=havariyun k=0.35 lod=0 tris=8362 draws=166 delik=0 dar=24 havada=1 cati_yolu=1/1
ISTAUDIT id=pantokrator k=0.35 lod=0 tris=13698 draws=244 delik=36 dar=10 havada=0 cati_yolu=1/1
ISTAUDIT id=lips k=0.35 lod=0 tris=7660 draws=143 delik=0 dar=2 havada=0 cati_yolu=1/1
ISTAUDIT id=kalenderhane k=0.35 lod=0 tris=3988 draws=81 delik=2 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=vefa k=0.35 lod=0 tris=3928 draws=80 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=pantepoptes k=0.35 lod=0 tris=3928 draws=80 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=gul k=0.35 lod=0 tris=3928 draws=80 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=aspar k=0.35 lod=0 tris=3316 draws=74 delik=0 dar=3 havada=0 cati_yolu=1/1
ISTAUDIT id=polyeuktos k=0.35 lod=0 tris=1324 draws=57 delik=0 dar=6 havada=0 cati_yolu=1/1
ISTAUDIT id=bozdogan k=1.0 lod=0 tris=21224 draws=132 delik=0 dar=0 havada=0 cati_yolu=2/2
ISTAUDIT id=havariyun k=1.0 lod=0 tris=8614 draws=179 delik=26 dar=10 havada=4 cati_yolu=1/1
ISTAUDIT id=pantokrator k=1.0 lod=0 tris=14334 draws=265 delik=59 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=lips k=1.0 lod=0 tris=12424 draws=188 delik=11 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=kalenderhane k=1.0 lod=0 tris=6472 draws=116 delik=6 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=vefa k=1.0 lod=0 tris=6340 draws=105 delik=9 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=pantepoptes k=1.0 lod=0 tris=6388 draws=109 delik=5 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=gul k=1.0 lod=0 tris=6436 draws=113 delik=5 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=aspar k=1.0 lod=0 tris=10012 draws=160 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=polyeuktos k=1.0 lod=0 tris=1804 draws=87 delik=128 dar=3 havada=0 cati_yolu=1/1
```
lod 2 üçgen (k=0,5): `ISTTRIS id=bozdogan lod=2 tris=308; ISTTRIS id=havariyun lod=2 tris=314; ISTTRIS id=pantokrator lod=2 tris=566; ISTTRIS id=lips lod=2 tris=340; ISTTRIS id=kalenderhane lod=2 tris=170; ISTTRIS id=vefa lod=2 tris=170; ISTTRIS id=pantepoptes lod=2 tris=170; ISTTRIS id=gul lod=2 tris=170; ISTTRIS id=aspar lod=2 tris=60; ISTTRIS id=polyeuktos lod=2 tris=12`; lod 1: Bozdoğan 1216, Havariyun 564, Pantokrator 1056, Lips 600, diğer kiliseler 300 (hepsi ≤ %15).
lod 0 üçgen üst sınırı 60 bin: en büyüğü Bozdoğan k=1 → 21 bin.

## Bilinen kusurlar
- `delik` sayıları çoğunlukla kubbe/koni yan yüzlerindeki yanlış-pozitif (dik kenarda 3 cm daraltılmış dışbükey kabuk) ve Polyeuktos'un
  kaba kırık pilye başlıkları; Pantokrator'da avlu ağaç tacı. Polyeuktos pilye başlıkları katı yapıldı (k=1 delik=0, k=0,5 delik=2).
- `dar` (Havariyun 24): Heroon duvar parçaları ve moloz arası aralıklar; düzeltilecek.
- Aspar'da zemin çukuru yapılamadı (yerel zemin y=0 sarnıç tabanı; sed yükselir). Şehir kurucusu zemini alçaltırsa sed yerine kullanılabilir.
- `havada` denetimi çok parçalı gövdede (Bozdoğan) atlanır; Havariyun'da 1 kutu (moloz tabakası) işaretli.
- Kiliselerin içi katıdır (girilmez). Kemer çarpışmaları yarım daire yerine kutu + kırık yüzey (kemer köşeleri yaklaşık).
- Işık: önizleme sahnesi şehir ışığından farklı; renkler oyunda sınanmadı.

## Bakamadıklarım
Oyuncu gözünden çatı karelerine (`*_ust_goz*`) kısmen bakıldı; Aspar ve Polyeuktos yakın plan, Havariyun çatı karesi, lod1 kareleri
henüz incelenmedi. Gerçek `Player` ile yürüme sınanmadı (yalnız CharacterBody3D benzetimi).

## Paftalar (`*.jpg`, 1280×720)
bozdogan kuş 15 m ve doğu eşik; havariyun kuş + güney göz; pantokrator kuş + çatı göz; lips güney; kalenderhane kuş; vefa batı;
aspar kuş; polyeuktos kuş; gul tepe.
