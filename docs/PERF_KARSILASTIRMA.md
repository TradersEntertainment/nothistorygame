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
