# ZFIGHT (titreşen yüzey) düzeltme raporu — dal `wip/duzeltme-zfight`

Denetim: `godot --headless --path . -s tests/zfight_check.gd -- res://scenes/<sahne>.tscn` (Godot 4.4.1). Denetim, eşik ve test betiği değişmedi; hiçbir kutu gizlenmedi, malzeme aynılaştırılmadı. Her düzeltme, ortak yüzü tek bir kutuda 5–10 mm kaydırır ya da uzatır.

## Bulgular ve düzeltmeler

| # | Sahne(ler) | Dosya:satır | Ne değişti |
|---|---|---|---|
| 1 | 3, 14, 17 | `scripts/level/bureau.gd:1463` (`_build_corridor`) | Koridor kilimindeki altın kenar şeritleri (0,06 × 0,014) kilimle 1 cm örtüşüyordu; üst yüzleri 2 mm farktaydı. Kenar şeridi 0,014'ten 0,02 m'ye yükseldi (üst yüz 8 mm yukarı). |
| 2 | 3, 14, 17 | `bureau.gd:2976-2978` (`_rc_archive`) | Arşiv lambrisi (3 parça) çekmece duvarlarıyla duvara bakan yüzde aynı düzlemdeydi. Lambri 0,04'ten 0,048 m'ye kalınlaştı ve duvarın içine doğru 8 mm uzadı; oda tarafındaki yüz yerinde kaldı. Görünüş ve çarpışma aynı. |
| 3 | 22o | `scripts/chapter22o.gd:320` | Islatma teknesinin su yüzü, tekne kenarıyla aynı yükseklikteydi (0,45). Su kutusu 8 mm yükseldi (0,04 → 0,048 kalınlık, merkez 0,434). |
| 4 | 43o | `scripts/chapter43o.gd:115-116` | Otağ halısının altın ve bordo katmanları birbirinden ≤2,5 mm farkla üst üsteydi. Katmanlar 8 mm basamakla yükseldi: altın üst yüzü 0,0225 → 0,030; bordo üst yüzü 0,024 → 0,038. |
| 5 | 44b | `scripts/level/ayasofya.gd:286` (`_floor`) | Omphalion karesi, "cennet ırmağı" şeridiyle 2,5 mm farkla çakışıyordu. Omphalion ve ona bağlı daireler/etkileşim noktası 8 mm yukarı alındı (`om.y` 0,03 → 0,038). |
| 6 | 8y | `scripts/chapter8y.gd:292` | Kaldırım derz taşları, kaldırım üst yüzünden 2,5 mm yüksekteydi. Üst yüz 8 mm yükseldi (0,045 → 0,048 kalınlık, merkez y 0,004). |

Not: `ayasofya.gd` Ayasofya iç mekânını kuran ortak koddur. 44b dışında 26 ve 24 bölümleri de bunu kullanıyor, bu yüzden onlar da test edildi.

## ÖNCE / SONRA (7 sahne)

ÖNCE (`ZFIGHT` satırları):
```
chapter3.tscn  axis=1 side=1 area=0.84 face=0.01  A=(-0.7,0.0,-83.8) (1.4,0.01,83.6)  B=(-0.75,0.0,-83.8) (0.06,0.01,83.6)
chapter3.tscn  axis=2 side=1 area=2.52 face=-13.00 A=(-11.0,0.0,-13.04) (8.8,0.9,0.04) B=(-10.4,0.0,-13.6) (2.8,2.9,0.6)
chapter3.tscn  axis=2 side=0 area=2.52 face=-24.00 A=(-11.0,0.0,-24.0) (8.8,0.9,0.04)  B=(-10.4,0.0,-24.0) (2.8,2.9,0.6)
chapter3.tscn  axis=0 side=0 area=3.87 face=-11.00 A=(-11.0,0.0,-23.9) (0.04,0.9,10.8) B=(-11.0,0.0,-17.9) (0.6,2.9,4.3)
(chapter14 ve chapter17: aynı 4 satır)
chapter22o.tscn axis=1 side=1 area=0.63 face=0.45
chapter43o.tscn axis=1 side=1 area=5.04 face=0.02
chapter44b.tscn axis=1 side=1 area=2.34 face=0.04
chapter8y.tscn  axis=1 side=1 area=0.76 face=0.02
```
SONRA:
```
ZSCENE chapter3.tscn   boxes=912 found=0
ZSCENE chapter14.tscn  boxes=911 found=0
ZSCENE chapter17.tscn  boxes=917 found=0
ZSCENE chapter22o.tscn boxes=433 found=0
ZSCENE chapter43o.tscn boxes=368 found=0
ZSCENE chapter44b.tscn boxes=657 found=0
ZSCENE chapter8y.tscn  boxes=345 found=0
```

## Tam döngü
`for f in scenes/chapter*.tscn` ile aynı komut (her biri `timeout 150`): 62 sahne işlendi (62 `ZSCENE` satırı), **toplam ZFIGHT satırı = 0**. Yeni bulgu çıkmadı.

## Diğer doğrulamalar
- `tests/parse_check.tscn`: `PARSECHECK PASS scripts=251`.
- `--max-fps 20 --chapter=<N> --autotest` (`timeout 300`): N = 3, 14, 17, 22o, 43o, 44b, 8y ve Büro/Ayasofya kullanan 13, 15, 26, 27, 24, 38o. Hepsinde `AUTOTEST PASS` var. `SCRIPT ERROR`, `VISAUDIT`, `WALKTHRU`, `HELDAUDIT`, `ARMAUDIT`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `WARN_VOID_TELEPORT` satırı yok (13 logda da 0).

## Kapsam
Replik, denge, süre ve yerleşim değişmedi. Kaydırmalar en çok 8 mm. Godot'nun ürettiği `.import` yan dosyaları kayda eklenmedi.
