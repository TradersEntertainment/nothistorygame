# ZEMİN — ara rapor (ilk gönderim, 18:25)

Bu ara rapordur; son rapor aynı dosyanın üstüne yazılacak.

## ÖNCE | SONRA paftaları (ilk)
- `pafta_b2_kizak.jpg` — Bölüm 2 kızak yolu (aynı kamera, `tests/_ist/zemin_kare.tscn`).
- `pafta_campday.jpg` — Gündüz ordugâhı (CampDay, Bölüm 9).
- `pafta_v2_surdisi_ilk.jpg` — v2 sur dışı (DEĞİŞMEDİ: bkz. aşağı).

## Kendi karelerime bakınca hâlâ kötü olanlar
- Bölüm 2: yeşil çokgen yüzler ve oyuncak yeşili gitti, ot tutamı/dal örtüsü geldi; AMA zemin fazla solgun/kremsi
  (güneşte kuru bozkır gibi), bahar yeşili yeterince okunmuyor. Düzeltiliyor.
- CampDay: leke damgaları gitti, çamur öbekleri yumuşak kenarlı; zemin ÖNCE'ye göre griye kaçmış, sıcaklık azalmış.
- v2 sur dışı: kare AYNI kaldı. O bölgede zemini SUR-4'ün `sur_zemin.gd` ateş alanı örtüsü çiziyor (bulanık gürültü
  dokulu düz yeşil). Bu gönderimde onun `_mat()` gövdesi ortak zemine çevrildi; SONRA karesi henüz alınmadı (KANITSIZ).
- v2 ordugâh: oba aralarını ORDUGÂH'ın `ordugah_oba.gd` düz bej lekeleri (`zem.done(host, "zemin")`, `Bld.vmat`) çiziyor;
  dokunmam yasak → ORTAK BİLGİ: API (son raporda örnek kod).

## Yapılanlar (kod)
- YENİ `scripts/level/zemin.gd` (class_name yok; `preload/load` ile) + `assets/shaders/zemin.gdshader` +
  `assets/textures/zemin_gurultu.png` (256 px döşemesiz gürültü: R,G fbm; B hücresel; A hücre kimliği).
- `Nature.ground_material()` → ortak zemin; `LowPoly.terrain` köşe başına renk + kendiliğinden yer örtüsü;
  `Nature.ground_detail` leke türleri (çamur, iz, kül, ıslak) → sahnenin aşınma maskesi; yapı dibi teması kendiliğinden.
- v2: `dunya.gd` arazi malzemesi + yer örtüsü; `bitki_yama.gd` doğal yamalar; `mahalle_doku.gd` toprak sokak;
  `sur_zemin.gd` `_mat()`.
- Testler (başsız, yasak satır 0): 2, 4, 9, 17, 20, 28o PASS. Ayrıştırma PASS.
