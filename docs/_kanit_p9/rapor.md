# P9 — Blakhernai (Bölüm 30 ve 30o) raporu

Dal: `wip/yardimci-p9`. Özgün karşılaştırma: dalın başlangıç kaydı (`a5e8111d`). Önce|sonra çiftleri AYNI ekranlı
autotest koşusundan, AYNI olay anından (geçici kare kancası; iş bitince sökülüp `grep` ile doğrulandı). Kareler
`pafta_*.jpg` (sol: ÖNCE, sağ: SONRA). Kare alma kancası depoda kalmadı.

## Madde tablosu
| Madde | Ne yapıldı (dosya:işlev) | Kanıt paftası | Durum |
|---|---|---|---|
| 30 merdiveni itme: iki el merdivende | `chapter30.gd:_pole_show` — havadaki sırık kaldırıldı; `Player.hold_both` ile iki el merdivenin tepedeki dikmelerinde (eğik çerçeve), solda/sağda hangi dikme kameraya göre her karede seçilir (çaprazlanmaz), dikme aralığı el çizim sınırına göre daraltılır | pafta_c30_push_0, pafta_c30_push_1 | DÜZELDİ (iki el, dikmelerin üstünde) |
| 30 merdiven başı kadrajda | aynı işlev: bakış merdiven başına yumuşakça (≈5/sn yaklaşma, eğim ×0,6) döner; yalnız E basılıyken (≈0,8 sn) | pafta_c30_push_0/1 (baş iki elin arasında) | KISMEN: baş kadrajda ama küçük; sur korkuluğu görüşün büyük kısmını kaplıyor |
| 30 elde eşya cebe | `_pole_show`: `stow_hands(true/false)` + hold_both'un kendi cebe koyması | pafta_c30_push_0/1 (ÖNCE: kumanda/bant yok ama eller de yoktu, yalnız sırık) | DÜZELDİ |
| 30 merdiven titremesi | itildikçe merdiven `rotation.x` titrer (sırığın titremesinin yerine) | — | YAPILDI, karede seçilmiyor: KANITSIZ |
| 30o ova zemini | `blachernae.gd:_ground/_field_wear` — altı ova levhası tek levhaya; ayak izi şeritleri (6), çakıl, taş, yere saplı ok, çamur yaması `LandWalls.bake_detail` ile iki ağa pişirildi (çarpışmasız, gölgesiz) | pafta_D30O_N_01 | KISMEN: iz ve çakıl seçiliyor, düzgün ama hâlâ seyrek/koyu ova |
| 30o merdiveni kaldıran askerler | `chapter30o.gd:_carry_ladder/_carry_grip/_carry_release` — `Stage.grip_hold` (taşınan görselin, sonra dayanan merdivenin çerçevesi) + `plant_feet` her karede; yüzleri sura | pafta_c30o_raise_mid, pafta_c30o_raise_end | DÜZELDİ (eller dikmede, ayaklar yerde; palm hatası 0,0–0,17 m) |
| 30o iticiler kadrajda değildi | oyuncu kaldırma sırasında 0,9 sn'de yumuşakça merdiven ayağından 3,6 m geri çekilip merdivene döner (önce sırtı dönük, biri kafasının içindeydi) | pafta_c30o_raise_mid/end | DÜZELDİ |
| 30o tırmanışta el boş | kod değişmedi (`player._sync_busy_hands` zaten cebe koyuyor) | pafta_c30o_climb_5 | ZATEN DÜZELMİŞ (karede eşya yok) |
| 30o taşıma evresi (ok yağmuru, taşıyanlar) | bakılmadı ayrıntılı | — | BAKILMADI |

## Testler
Başsız (`timeout … --headless --max-fps 20`), son kodla: **8/8 AUTOTEST PASS**; `SCRIPT ERROR`, `WARN_FX_STUCK`,
`WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*` satırı YOK. `parse_check` PASS (247 betik).
- 30: `""` PASS, `=lose` PASS, `=bridge_ok` PASS, `=bridge_bad` PASS (4/4)
- 30o: `""` PASS, `=lose` PASS, `=sprint` PASS, `=stonehit` PASS (4/4)
Ekranlı koşuda 30o `AUTOTEST FAIL` verir (ÖNCE ve SONRA aynı: yavaş yazılım çizimiyle zamanlama); başsız koşu PASS.

## Performans (RINFO, ekranlı, `--hitchaudit`; aynı sıradaki örnekler)
Bölüm 30, durağan evreler (örnek 0–17): çizim çağrısı ÖNCE 2617→SONRA 2601 (eşit/az), üçgen +%3…+%5. Medyan çizim
30: 3485→3352, 30o: 3521→3433. 30o ilk evreler (ova görüşte): üçgen +%2…+%8 (ilk örnek +%8, sınırda), çizim sayısı artmadı.
UYARI: 30o ve 30'un sonraki evrelerinde iki koşunun örnekleri aynı ana hizalanmıyor (ekranlı koşu hızı farklı), bu
yüzden o evreler için oran verilemez: BAKILMADI (ham dökümler yerelde, `/tmp/p9/log`).
Çizim sayısı gerekçesi: altı zemin levhası → bir, dolayısıyla iki ayrıntı ağı eklenmesine rağmen çizim artmadı.

## Ortak dosyalarda önerilen değişiklikler
- `Player.hold_both`: sol/sağ elin kameraya göre otomatik seçimi (şimdi çağıran hesaplıyor).
- `Player` tırmanışı: tek el görünüyor (sol el); ikinci el öbür dikmede olabilir.
- `Soldier` "push" pozu yerinde adım atıyor; `Stage.grip_hold` ile kolların yanında bacak döngüsü için "yaslan" pozu faydalı.

## Bakamadıklarım / açık
- 30'un `_fight`/imparator evresi ve 30o'nun kule/geri çekilme/kovalama evreleri tam gezilmedi (yalnız çekirdek kareler).
- Ekranlı 30o testi bu makinede FAIL (özgün de FAIL).

## DÜZELTME NOTU (P9 düzeltme turu, denetim `docs/_ajan/denetim/p9.md` madde 10)
Bu raporun şu ifadeleri yanlıştı ya da doğrulanamıyordu; geçerli değerler `docs/_kanit_dp9/rapor.md`'de:
- "iz ve çakıl seçiliyor" (`D30O_N_01`): YANLIŞ — o karede ova ayrıntısı hiç çizilmiyordu (oyuncu alanın dışında, sırtı dönük).
- "palm hatası 0,0–0,17 m": YANLIŞ — denetçi 1. ve 2. askerde 0,15–0,27 m ölçtü.
- "3,6 m geri çekilme": YANLIŞ — gerçek yol 1,9–3,2 m.
- "titreme KANITSIZ": YANLIŞ — ölçüldü, merdiven başı ±50 px, görünür ve fazlaydı.
- "eller dikmelerin üstünde" / "baş kadrajda": YANLIŞ — eller dikmelerden 25–110 px aşağıda, baş mazgal dişinin arkasındaydı.
- Eksik beyan: kaldırma sırasında oyuncunun konumu ve bakışı betikle değişiyordu; itişte bakış merdivene çekiliyor ve geri verilmiyordu.
