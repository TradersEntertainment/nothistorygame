# Kuzeybati (Khora, Pammakaristos, Tekfur, Blakhernai çevresi) — rapor

Dal: `wip/ist-kuzeybati`. Dosyalar: `scripts/world/ist/kuzeybati*.gd`, `tests/_ist/kuzeybati_onizleme.{gd,tscn}`.
Aşağıdaki "Denetim" bölümü son koşudan doldurulur (aşağıya bakın). Araştırma özeti: `arastirma.md` (kaynaklı).

## Arayüz notları (şehir kurucusu için)
- Giriş: `IstKuzeybati.catalog()`, `IstKuzeybati.build(id, host, k, lod)`, `perches(id, k)`, `climbs(id, k)`.
  Ayrıca her öğe için `build_<id>`, `perches_<id>`, `climbs_<id>` (sınıflar: `IstKbKilise`, `IstKbSaray`, `IstKbSemt`).
- Yerel çerçeve PUSULA HİZALIDIR (+x doğu, -z kuzey); yapının `yon_derece` dönüşü kurucu içinde uygulanmıştır
  (pivot). Yerleştirici yalnız şehrin pusula→dünya dönüşümünü uygular; `yon_derece` bilgi amaçlıdır.
- `perches_*` ve `climbs_*` kurucudan toplanır (`IstKbCtx.harvest`); önbelleklidir.
- k yalnız kütleyi ölçekler; kapı, basamak (≤ 0,34 m), sandık (≤ 0,6 m), siperlik (1,1 m), mazgal, tezgâh sabit boydadır.
  Kaligaria evleri k < 0,7 iken tek kat, taban en az 0,7 ölçeğinde (insan ölçüsü alt sınırı).
- Oyuncu sınırları: JUMP 3,6 m/sn, g 9,8 → zıplama 0,66 m; STEP_H 0,42 m; tutunma REACH 2,3 m.

## Öğeler
| id | ne | durum |
|---|---|---|
| khora | Kariye: naos + 6 kubbe, parekklesion, iki nartheks, apsisler, payandalar | TAMAM (ayrıntı derinleştirilebilir) |
| pammakaristos | ana kilise + beş kubbeli parekklesion, dolaşma yolu | TAMAM |
| tekfur | üç katlı saray, mermer revak, tuğla geometrik cephe, sur kesiti, kuleler | TAMAM (turret→çatı yolu k ≤ 0,5'te başarısız) |
| anemas | sekizgen kule, kareli kule, tonozlu zindan taraçası | TAMAM |
| blakhernai_kilise | 1434 yangın harabesi + ayazma | TAMAM |
| petra | küçük çapraz-kare manastır + avlu duvarı | TAMAM |
| aetios | açık sarnıç bostanı (244 × 85 m, MultiMesh sebze/bağ) | TAMAM |
| kaligaria | iki sıra ayakkabıcı dükkânı, sundurma, tezgâh | KABA-TAMAM |
| kynegion | yıkık eliptik arena (bitişik kademeler) | KABA-TAMAM |
| ayvansaray_iskele | rıhtım, ahşap iskele, kayıklar, fener | KABA-TAMAM |

## Bilinen kusurlar
- `dar` (0,2–1,4 m girilebilir aralık) sayıları sıfır değil: Blakhernai (6–7), Kynegion (5–6), Kaligaria (2–6),
  Pammakaristos (2–3), Petra (≤ 4), Tekfur (≤ 4), Khora (≤ 3). Çoğu moloz/duvar-ağaç gövdesi arası dar yarıklar.
- Tekfur: sur kuleli yürüme yolundan saray çatısına sandık yolu k = 0,35 ve 0,5'te hedefe 0,7 m kala takılıyor (1,0'da geçiyor).
- Kynegion ve Aetios'ta lod 1 ≈ lod 0 (kasıtlı basit); büyük anıtlarda lod 1 oranı hedef %15'in üstünde olabilir.
- Su (iskele) ince saydam levha, yürünebilir sığ su; deniz seviyesi şehir kurucusuna bağlı.
- Önizleme zemini düz; yamaç (Haliç eğimi) yok: Aetios taban/çevre set yüksekliği şehir arazisine uydurulmalı.
- Nihat bakış noktaları `catalog()` içinde (`bakis`, `bakis_r`, `gorev`); kubbe tepelerinde katı fener var.
