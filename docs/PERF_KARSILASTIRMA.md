# Çizim bütçesi: 0.99.112 önce/sonra

Değişiklik: dış çizgi malzemesi gölge ve derinlik geçişine girmiyor (`Props._outline_mat`, `CharKit._outline`:
`depth_draw_mode = DEPTH_DRAW_DISABLED`). Ölçüm `tests/perf_run.sh` ile, varsayılan kalite, 1280×720, bölüm başına en çok
7 dakika. Sayılar karedeki çizim çağrısı (ortanca ve en yüksek) ve üçgen (bin, ortanca).

| Sahne | Çizim önce | Çizim sonra | Fark | En yüksek önce | En yüksek sonra | Üçgen önce (k) | Üçgen sonra (k) |
|---|---:|---:|---:|---:|---:|---:|---:|
| chapter26 | 12853 | 8231 | -36% | 14630 | 11813 | 12760 | 12770 |
| chapter0 | 9140 | 7273 | -20% | 13031 | 9955 | 11700 | 11699 |
| chapter20 | 10612 | 7984 | -25% | 10916 | 8093 | 11034 | 10958 |
| chapter25 | 8294 | 9152 | +10% | 13484 | 11656 | 6451 | 8460 |
| chapter26o | 8826 | 5771 | -35% | 10738 | 9194 | 6826 | 6704 |
| chapter10g | 7854 | 7098 | -10% | 9711 | 7322 | 2827 | 2829 |
| chapter22 | 6758 | 5353 | -21% | 7243 | 5774 | 7686 | 7689 |
| chapter22o | 7517 | 5538 | -26% | 9714 | 7508 | 4901 | 4845 |
| chapter12b | 7169 | 6020 | -16% | 7989 | 6833 | 6828 | 6853 |
| chapter2 | 5603 | 5293 | -6% | 7680 | 6903 | 6224 | 6178 |
| chapter9 | 5344 | 4539 | -15% | 7124 | 6262 | 6223 | 6230 |
| chapter18 | 5804 | 5652 | -3% | 6589 | 6109 | 7664 | 7675 |

Notlar:
- Üçgen sayısı değişmedi: kazanç çizim çağrısında. Üçgen bütçesini (5 M) aşan sahnelerde yük yakın ordu (Crowd) ve canlı
  karakter iskeletleri; sıradaki işler `docs/denetim/2026-11/performans_tasarimi.md` içinde (#3-#8: sabit süsleri
  alt parça başına birleştirmek, #12: karakter başına tek ağ).
- Bölüm 25'in iki koşusu farklı aşamaları örnekledi (bölüm iki yarılı, 7 dakikalık sınırda 8 ölçüm): ortanca artmış
  görünüyor, en yüksek değer düştü. Bu satır karşılaştırma için güvenilir değil.
- "Gizli koşan örneklerini çizme" (tasarımda #2) uygulandı, ölçümde fark çıkmadı, geri alındı.
- Görüntü: Bölüm 0, 3 ve 6'da önce/sonra kareler yan yana incelendi; dış çizgiler yerinde.

# Üçgen dökümü ve sıkı poz ağları (0.99.113 sonrası)

Ölçüm: geçici `tests/_tmp/tri_groups` sondası (bölüm test botuyla açılır, belirli anda ağaç durdurulur, çizilen her
GeometryInstance3D bir gruba ayrılıp grup grup gizlenir; fark görünür ve gölge geçişindeki üçgen, bin). Kamera iki
bölümde de sur yolunda (-10..-12, 9.6, 15). ±100 k gürültü (Bölüm 26 t=25'te kamera kıpırdıyordu).

| Grup (üçgen, k: görünür / gölge) | Bölüm 20 t=10 | Bölüm 20 t=22 | Bölüm 26 t=9 | Bölüm 26 t=25 |
|---|---:|---:|---:|---:|
| Toplam | 6905 / 3922 | 6676 / 3989 | 5550 / 6412 | 9999 / 3916 |
| (a) ordu, yakın figür (Crowd, ≤150 m) | 487 / 640 | 453 / 579 | 69 / 591 | 422 / 292 |
| (a) ordu, uzak siluet (Crowd, >150 m; ~2200 çizim) | 2906 / 0 | 2674 / 0 | 0 / 0 | 1100 / 0 |
| (a) SiegeField'ın öteki çoklu ağları | 1431 / 65 | 1137 / 41 | 591 / 41 | 1237 / 42 |
| (b) Assault koşanları | 288 / 24 | 246 / 0 | 258 / 0 | 347 / 0 |
| (b) PoseCrew (sur yolundaki iş yapanlar) | 772 / 24 | 733 / 0 | 3217 / 0 | 3315 / 0 |
| (b) SiegeChaos + HornWorld çoklu ağları | 472 / 71 | 429 / 30 | 437 / 30 | 650 / 31 |
| (c) canlı karakterler (Person/Soldier) | 215 / 3037 | 408 / 3138 | 743 / 5470 | 2977 / 3341 |
| (d) sabit dekor (LandWalls, Assault, SiegeField, HornWorld tek ağları, merdiven) | ~350 / ~180 | ~250 / ~30 | ~140 / ~190 | ~870 / ~140 |

Okuma:
- Gölge geçişinin %77-85'i canlı karakterler (Bölüm 26'da 5,5 M). Bir karakter ~23 parça, ~23 bin üçgen; parçalarda
  ayrıntı katmanı (LOD) yok.
- Görünür geçişte en büyük kalemler uzak siluet katmanı (Bölüm 20'de 2,7-2,9 M: ~2200 hücre×tür ağı), SiegeField'ın
  öteki çoklu ağları (1,1-1,4 M), PoseCrew (Bölüm 26'da 3,2 M) ve yakındaki canlı karakterler.
- Sabit dekor üçgende önemsiz (çizimde değil: LandWalls ~800-1200, Assault ~900-1900 çizim). Duvar arkası kırpma (#9)
  bu sahnelerde üçgen kazandırmaz: kamera sur yolunda, ordu önünde açıkta.

U3 (küçük sonda, tek MultiMesh, 200 örnek):
- Bir Crowd figürü **19.747 üçgen** (tasarımdaki 2,3 k tahmini yanlış); `generate_lods` 9 katman üretmiş, uyumluluk
  çizicisi MultiMesh'te LOD **uyguluyor** (ağın kutusuna olan uzaklığa göre, bütün ağ için tek katman).
- **RINFO `prims` çoklu ağda örnek sayısını saymıyor**: çizim başına (seçilen LOD'un üçgeni × geçiş) bir kez sayılır.
  200 örnek → 50 (`visible_instance_count`) sayıyı hiç değiştirmedi. Geri alınan #2'nin ölçümde fark göstermemesinin
  nedeni bu: kazanç gerçek (köşe işi), sayaç onu görmüyor. Bütçedeki 5 M çoklu ağların gerçek yükünü olduğundan çok
  düşük gösterir.
- Gizleme yöntemi (0.001 ölçek, y=-200) ağın kutusunu büyütür, LOD en ince katmana kilitlenir (sondada 6 m'de 8,7 k →
  19,7 k).

U2: Bölüm 26 t=9'da ay gölgesi kapatılınca görünür üçgen aynı kaldı (4186 k): gölgeli ışık renk geçişini ikilemiyor.
Ama görünür çizim 6602 → 1585 düştü: uyumluluk çizicisinde gölge geçişinin çizim çağrıları "vis/draws" sütununa
sayılıyor (gölge sütunu hep 0). O anda çizimlerin ~%76'sı gölge geçişi.

## Değişiklik: sıkı poz ağları (görüntü aynı)

- `scripts/level/pose_crew.gd` (`build`, `_show`, yeni `_take_out`, `suppress`): her poz ağında yalnız o pozdaki kişiler,
  art arda yuvalarda (`visible_instance_count`); boş poz ağı görünmez. Kutu (custom_aabb) eskisi gibi.
- `scripts/level/assault.gd` (`_update_runners`, `_update_runner`): koşanlar her kare yalnız kendi pozunun ağına art arda
  yazılır, ağ yalnız o kadar örnek çizer; boş ağ görünmez. Ağın kutusu eskisi gibi hesaplanıp `custom_aabb` olarak
  verilir (kırpma ve LOD seçimi değişmesin). Her kare 750 yerine 250 dönüşüm yazılır.

Bölüm başına RINFO (aynı örnek anları; önce = `tests/out/perf`, üçgen k):

| Sahne, an | Çizim önce → sonra | Üçgen önce → sonra | Fark |
|---|---:|---:|---:|
| chapter26 t=5 | 6889 → 6859 | 11592 → 10423 | -10% |
| chapter26 t=9 | 7024 → 7146 | 11826 → 10786 | -9% |
| chapter26 t=13/14 | 7472 → 7546 | 12164 → 11034 | -9% |
| chapter26 t=18/19 | 8231 → 8158 | 12770 → 11715 | -8% |
| chapter26 t=25/26 | 11143 → 11093 | 13742 → 12555 | -9% |
| chapter0 t=1 | 9955 → 9821 | 14634 → 13432 | -8% |
| chapter0 t=3 | 8016 → 8004 | 12294 → 11542 | -6% |
| chapter0 t=5 | 4435 → 4388 | 9304 → 8397 | -10% |
| chapter0 t=7 | 6531 → 6511 | 11104 → 10148 | -9% |
| chapter20 t=1 | 5852 → 5784 | 8731 → 8047 | -8% |
| chapter20 t=10 | 7706 → 7665 | 10862 → 10685 | -2% |
| chapter20 t=13/12 | 8040 → 7937 | 11132 → 10846 | -3% |
| chapter20 t=15/14 | 7996 → 7871 | 11177 → 10823 | -3% |

- RINFO'daki düşüş boş poz ağlarının çizilmemesinden (Bölüm 26 t=9'da PoseCrew 152 → 107 ağ, 3220 k → 2035 k).
- Sayacın görmediği gerçek köşe işi (örnek × LOD0 üçgen, üst sınır, Bölüm 26): koşanlar 15,9 M → 5,8 M, PoseCrew
  12,1 M → 4,4 M.
- Kare süresi ölçülemedi: yazılım çizicisinde öteki işler yüzünden aynı karenin süresi 2,4-10 sn arasında oynuyor.
- Görüntü: eski ve yeni betik aynı sabit adımlarla, aynı kameradan (geçici sonda): PoseCrew 3 karede 0 piksel fark;
  koşanlarda fark yalnız zamanla oynayan alevlerde ve gediğin dibinde aynı noktada üst üste yatan iki koşanda (hangisinin
  önde çizileceği çizim sırasına bağlı; eskiden de keyfiydi). Bölüm 20 kare kipinde önce/sonra yan yana: aynı.
- Testler: 0, 20, 22, 26, 26o, 36b, 37o RUNOK; PARSECHECK PASS.

Not (değiştirilmedi): PoseCrew'de ilk pozu "" (ayakta) olan kişiler, ilk poz değişimine kadar (en çok ~6,5 sn)
görünmüyor (`"shown": ""` başlangıç değeri `_show`'u erken döndürüyor). Düzeltmek görüntüyü değiştirir; sahibine.

Sıradaki öneriler (üçgen):
1. Canlı karakter parçalarına LOD (`CharKit.bake` içinde `generate_lods`, Crowd'daki gibi): gölge geçişindeki 3-5,5 M'nin
   kaynağı. Godot 1 piksel eşiğiyle seçer; uzak/yakın karelerle kanıtlanmalı (char_kit.gd bu işin dosyaları dışında).
2. Uzak siluet katmanı: hücre × kaftan × başlık × silah başına ayrı ağ yerine hücre başına tek ağ ve örnek rengi
   (renk aynı kalırsa görüntü aynı): Bölüm 20'de ~2200 çizim ve ~2,5 M sayılan üçgen.
3. Bütçe ölçümüne çoklu ağların örnek sayısıyla çarpılmış üçgenini ekle (RINFO bunu göstermiyor).

# 0.99.114: PoseCrew hatası, karakter LOD'u, örnekli üçgen sütunu

## PoseCrew: ilk pozu "ayakta" olanlar görünmüyordu (düzeltildi)
`scripts/level/pose_crew.gd` (`add`: `"shown"` başlangıcı `""` yerine `"#none"`). İlk pozu "" olan kişi, `_show` erken
döndüğü için ilk poz değişimine kadar (en çok ~6,5 sn) hiçbir ağda yoktu. Sınama: 48 kişilik ekip kurulur kurulmaz
önce 29, sonra 48 kişi görünüyor.

## Canlı karakter parçalarına ayrıntı katmanı (LOD)
`scripts/npc/char_kit.gd` (`bake` → `_lod_assign`, `_lod_work`, `_lod_pump`): pişirilen her parça Crowd'daki ayarla
(`generate_lods(25, 60)`) katman alır, `lod_bias = 12` (Godot'nun 1 piksel eşiği 12 kat uzağa kayar).
- Yakın plan: aynı donuk karakterler katmansız / katmanlı, aynı kameradan. 1-4 m'de üçgen ve kare birebir aynı (0 piksel),
  6 m'ye kadar tam ağ. 12 m'de 5 piksel, 40 m'de 20 piksel fark (1280×720'de); siluet ve dış çizgi aynı.
- Tek karakter grubu (4 kişi, görünür üçgen): 12 m -4%, 20 m -16%, 40 m -45%, 70 m -64%; gölge geçişi aynı oranda.
- Sahnede (aynı koşu, aynı kare, katman açık ↔ kapalı):

| Sahne, an | Gölge üçgeni (k) | Görünür (k) | Toplam (k) |
|---|---:|---:|---:|
| chapter26 t=5 | 6306 → 5107 (-19%) | 4310 → 4311 | 10619 → 9420 (-11%) |
| chapter26 t=14 | 6805 → 5341 (-22%) | 4434 → 4361 | 11241 → 9705 (-14%) |
| chapter26 t=22 | 7079 → 5592 (-21%) | 4666 → 4548 | 11748 → 10143 (-14%) |
| chapter26 t=27 | 4085 → 3019 (-26%) | 9113 → 8206 (-10%) | 13201 → 11228 (-15%) |
| chapter20 t=6 | 2917 → 2400 (-18%) | 7837 → 7373 (-6%) | 10757 → 9775 (-9%) |
| chapter20 t=16 | 4213 → 3428 (-19%) | 6830 → 6730 | 11045 → 10160 (-8%) |
| chapter20 t=24 | 3968 → 3309 (-17%) | 6712 → 6598 | 10682 → 9910 (-7%) |

- Açılış süresi: katman üretimi pahalı (~10 ms / parça, bir bölümde 700-1200 ayrı biçim; eşzamanlı yapılınca Bölüm 26
  açılışı 12 → 21 sn, +%72). Bu yüzden: katmanlar biçime bağlı önbellekte (aynı biçim bir kez), `user://charkit_lod`
  altında diskte; önbellekte yoksa parça önce tam ağla konur, katmanlar tek arka iş parçacığında üretilip hazır olunca
  takılır. Açılış (görüntülü, ortam gürültülü): Bölüm 26 32,0 / 32,5 sn (katmanlı) - 27,1 / 34,0 sn (katmansız), Bölüm 20
  20,1 / 19,1 - 20,4 sn: fark gürültü içinde. Başsız koşuda katman üretilmez.
- `char_kit.gd` değişince Crowd'un disk önbelleği (anahtarında bu dosyanın özeti var) bir kez yeniden pişer (ilk
  açılış uzun sürer, sonra eski hızına döner).

## Örnekli üçgen sütunu
`tests/perf_run.sh` oyunu geçici bir sarmalayıcıyla açar (koşu süresince `tests/_tmp/perf_tris.*`, sonunda silinir); RINFO
ile birlikte `RTRI ... real=` yazılır: RINFO üçgeni + çoklu ağların sayılmayan örnekleri (görünür örnek × Godot'nun
seçeceği LOD'un üçgeni × renk/dış çizgi geçişi; kamera dışı ve görünürlük aralığı dışı ağlar sayılmaz; gölgede yaklaşık).
`tools/perf_report.py` tabloya "Örnekli üçgen ort./en yüksek" sütunlarını ekler; bütçe kararı RINFO'ya göre kalır.
`PERF_OUT` ve `PERF_MD` ile ölçüm ve tablo başka yere yazılabilir. Örnek, Bölüm 20: RINFO ortanca 10,0 M, örnekli 20,0 M
(en yüksek 29,3 M): kalabalıkların gerçek yükü sayacın gösterdiğinin iki katı.
