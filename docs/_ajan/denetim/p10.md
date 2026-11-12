# P10 bağımsız denetim raporu (iç mekânlar ve tüneller)

Denetlenen: `wip/yardimci-p10` ucu (`9b87906f`), ÖNCE = `a5e8111d`. Denetçi dalı: `wip/denetim-p10`.
Yöntem: ÖNCE koşuları `git archive a5e8111d` ile depo dışında (`~/w/once`) ayrı proje olarak kuruldu; oyun kodu değiştirilmedi.
Kareler ekranlı koşudan (`PACE=1 xvfb-run 1280x720 --dialogshots --shotevery=1 --snapevery=0.5`), ÖNCE | SONRA aynı varyantta, aynı replik anahtarından
(ya da aynı replikten sonra gelen `tNNNN` anlık karelerinden) alındı. Kareler 640 px; yakın ayrıntı için kareler kırpılıp büyütüldü, ölçümler ayrıca
geçici sondayla (`tests/_tmp/`, iş bitince silindi) alındı.

## GENEL HÜKÜM: RET (küçük düzeltmelerle yeniden denetim)

Gerekçe: kabul kareleri 4 ana maddede (kumanda, kol, 21o/10l kazmacılar) ya KISMEN çıktı ya da kazmacılarda alet duvara gömülüyor; 10l'de çizim sayısı
tekrarlanabilir biçimde artıyor (kural: artmaz); 10l yan kazmacılar sahnede oyuncuya sırtını dönüyor (ÖNCE'de dönük değildi). Düzeltmeler küçük (konum/ofset); aşağıdaki liste.
Geliştiricinin raporu dürüst: zaten KISMEN dediği maddelerde haklı; "DÜZELDİ" dediği 3 maddede (10l Dragan, 10l/21o oyuncu kazması) iddia karelerle desteklenmiyor.

## Madde madde hüküm

| # | Madde (geliştirici iddiası) | Hüküm | Kanıt (pafta, an) ve neden |
|---|---|---|---|
| 1 | Bölüm 1 kumanda elden ele (DÜZELDİ) | **KISMEN** | P01. ÖNCE: Hikmet'in eli boş, kumanda Tolga'nın elinde birden beliriyor. SONRA: kumanda D1_H_16'dan beri Hikmet'in elinde (iyileşme doğru). Ama t0268–t0270: Tolga'nın eli Hikmet'in **göğsüne** (`hikmet.global_position+(0,1.1,0)`) uzanıyor, kumandanın 25 cm yanına; kumanda 0,4 sn elden çıkıp kameraya süzülüyor (t0269'da ne Hikmet'in elinde ne Tolga'nın elinde). Yani "elden ele" temas yok, kısa süzülme var. WARN_FLY_ITEM yok (kol boyu içinde). |
| 2 | Bölüm 13 kol tutuşu (DÜZELDİ; "kamerasız") | **KISMEN** | P02. Kamera çevrilmiyor (ÖNCE/SONRA aynı görünüm: DOĞRULANDI), bakış betikle dönmüyor, kameraya giren gövde yok (kol alttan gelen oyuncunun kolu). Ama QTE karelerinde yumruk topuzun yaklaşık 10 cm **üstünde/ötesinde**, kolun gövdesi kolun kendisini örtüyor (kol seçilmiyor), el kolu kavramıyor. t0058 → t0059 → D13_H_OPEN'da yumruk aynı yükseklikte: kol inerken elin onunla indiği **görünmüyor**. Kabul karesi D13_H_LEVER (diyalog anı) ÖNCE ile aynı: tutuş QTE'de başlıyor. |
| 3 | Bölüm 3 kol (KANITSIZ) | **DOĞRULANDI (iddia)** | `grep lever|knob|kol çek scripts/chapter3.gd` boş: orada kol sahnesi yok. 3 (6 varyantın ilki) PASS. |
| 4 | 12 kâtip yazarken kalem (KISMEN) | **KISMEN (doğru)** | P07 ve sonda: kâtip oturmuş, kalem sağ elde (iyi). Sonda ölçümü: kalem ucu x=-4,55 / y=0,52–0,58 / z=-2,40; kâğıt x∈[-4,45;-3,95], y=0,51: kalem kâğıdın **~10 cm soluna, masa ahşabının 1–8 cm üstüne** yazıyor. Diz ağları masa ön yüzünü (z=-2,10) ~12 cm geçiyor (AABB, kaba). Oynanış karelerinde kâtip kadrajda değil (P07). |
| 5 | 21o kazmacı kazmasız (KISMEN) | **KISMEN → kusur bulundu** | Sonda (60 Hz, 8 sn): alet gerçek ölçüde (AABB 0,17×0,40×0,78 m, sap 0,74 m: dev değil), gövdeye girmiyor (uç yerelde x=+0,45, gövde dışında). **Ama vuruş hedefe inmiyor, içine gömülüyor:** kazmacı yüzden 1,0 m önde (`_place_crew` fz+1,0), uç y.1,2 m ileride → baş merkezi yüz levhasının (0,4 m kalın, ön yüz fz+0,2) **0,4 m içinde**, levhanın arka yüzünde. Kazma başı bu yüzden karede seçilmiyor (geliştirici "karanlık" demişti; asıl neden gömülme). |
| 6 | 21o oyuncu kazma modeli (DÜZELDİ) | **KISMEN** | P05. Model yenilendi (ÖNCE düz levha/tokmak, SONRA çift başlı kazma, gerçek ölçü). Ama kazma **elsiz havada duruyor** (hiçbir el sapı tutmuyor; öteki yumruk kumandada); bu ÖNCE'de de vardı, düzelmemiş. |
| 7 | 10l Dragan kazması (DÜZELDİ) | **KISMEN** | P03. Dragan'ın elinde dik sap var (ÖNCE boş el). Ama sap uçtan görünüyor: T-baş seçilmiyor, **mızrak/asa gibi okunuyor** (kırpma büyütmesi: iğne uç, çapraz baş yok). |
| 8 | 10l oyuncu kazması (DÜZELDİ) | **DOĞRULANDI** | P03 alt satır (D10L_D_DIG_1): ÖNCE düz levha, SONRA gerçek kazma, sap elin arkasında. Sonda boyutu 7/21o ile aynı. |
| 9 | 10l yan kazmacılar (KISMEN) | **YANLIŞ (yeni kusur)** | P04. Sonda: kazmacı (ch+(±1,4;0;-1,6)), baş merkezi z=-18,4; oda arka duvarı iç yüz z=-17,95 (0,3 kalın, dış yüz -18,25): baş **0,45 m duvar içinde, 0,15 m dışarı taşmış** → kazma görünmez. Ayrıca `rotation.y=PI` ile kazmacılar oyuncuya **sırtını dönük** donmuş duruyor (G_MEET_2, 6 anlık kare t0198–t0214: hiç kıpırdamıyor); ÖNCE'de oyuncuya dönüktüler ("Üç adam, herkes donup kalır" metnine uyardı). |
| 10 | 15 toplantı baş sallaması (KISMEN) | **KISMEN (doğru)** | P06. Baş sallama var, ince (yeşil/mavi çalışan t0093–t0099); titreme yok (`Rig.emote` lock'lı, nod 2×0,14 sn), zamanlayıcılar bağımsız (3–9 sn rastgele) → eşzamanlı robot hareketi yok; konuşana bakış (kameraya/müdüre) bozulmuyor. ÖNCE'de de nefes hareketi var (tam donuk değildi), fark küçük. Not: `randf()` genel RNG'yi tüketiyor (testler etkilenmedi). |
| 11 | 12/10a/13/14/15 vezirlerde `idle_vary` (KISMEN) | **KANITSIZ** | Kendi oynanış karelerimde vezirler kadrajda değil/çok küçük; yalnız testler (hepsi PASS) ve diff incelemesi. |
| 12 | bureau işçilerine alet | **YAPILMADI** (yasak dosya, doğru) | — |
| 13 | 5, 8, 14, 10a kare gezisi (KANITSIZ) | **BAKILMADI** | Bu denetimde de yalnız testler koşuldu (10a, 14 PASS); 5 ve 8 değişmedi, koşulmadı. |

## Yeni kusurlar (liste dışı)

| Kusur | ÖNCE'de var mıydı? | Yer |
|---|---|---|
| 21o ve 10l kazmacı kazma başı duvara/yüze gömülü (madde 5, 9) | Hayır (alet yoktu; yeni) | P04, sonda |
| 10l yan kazmacılar oyuncuya sırtı dönük, donuk (madde 9) | Hayır (dönüktüler) | P04 |
| 21o oyuncu kazması elsiz havada (madde 6) | Evet (levha da elsizdi) | P05 |
| 10l Dragan'ın kazması mızrak gibi (madde 7) | Hayır | P03 |
| 12 kâtip kalemi kâğıdın dışında, dizler masaya giriyor (madde 4) | Hayır (kâtip ayaktaydı) | P07, sonda |
| 13 `Lambda capture at index 0 was freed` (13 `=depot`, bölüm sonunda) | **Evet**, ÖNCE'de de (`ONCE_13_depot.log`) | yeni değil |

Küp gibi ateş/meşale, dev alet, birden beliren kişi: taranan karelerde (1, 13, 10l, 21o, 12, 15 kare dizileri) görülmedi; 5/8/14/10a BAKILMADI.

## Kurallara uygunluk (diff `a5e8111d..9b87906f -- scripts`)

- Replik anahtarı/sırası: değişmemiş. Süre: **`chapter1.gd:_pass_remote`** `Handover.wait(0,6)` sonrasına 0,4 sn'lik tween ekliyor (+0,4 sn; hızlı kipte 0,05) — "süre değişmez" kuralına küçük aykırılık. Sayaç/sonuç koşulu/kalabalık sayısı/bot yolu: değişmemiş.
- Kanca/DBG/sonda: `grep GECICI_SONDA|P10PROBE|DBG` ilgili 6 dosyada boş; `tests/_tmp/` depoda izlenmiyor. `no_audit`/`_ok` meta: yeni yok (`chapter13.gd:584,665,678` `no_audit` ÖNCE'den).
- `chapter10l.gd:129–130` Dragan'a elle `set_meta("armed", true)`: `Person.give_tool`'un yaptığıyla aynı (rig boşta kıpırdanma kolu aleti sokmasın); denetim susturma değil, sorun yok. `_give_pick` içinde kalkıyor.
- `chapter1.gd` yeni işlev `_remote_prop` oyuncunun özel alanına (`player._remote_model`) erişiyor (kod kokusu, kural dışı değil).
- Ortak dosya: diff'te ortak dosya değişikliği yok (yalnız 6 yetkili dosya).
- Dalda 74 ses `.import` kaydı (`9b87906f`) var: dokunulmadı.

## Testler (başsız, `--headless --max-fps 20`, son kod `9b87906f`)

Hata satırı (SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, JOURNEY_MISS/OVERLAP): **0**. (`JOURNEY cards=…` bilgi satırları hata değil.)

| Bölüm | Koşu | Sonuç |
|---|---|---|
| 1 (`""`, kick, red) | 3 | 3 PASS |
| 10l (`""`, collapse, retreat, leb, next) | 5 | 5 PASS |
| 13 (10 run_tests varyantı + next, wrong_next, gidak) | 13 | 13 PASS |
| 15 (run_tests.sh tam liste) | 33 | 33 PASS |
| 21o (`""`, smoke, lose, ear) | 4 | 4 PASS |
| 10a, 12, 14, 21, 3 (birer) | 5 | 5 PASS |
| Ekranlı (1, 13, 10l, 21o, 12, 15; ÖNCE ve SONRA) | 12 | 12 PASS |

Toplam başsız 63 PASS + ekranlı 12 PASS. Ham: `ham/autotest_basluk.txt`, `ham/autotest_ekranli.txt`, `ham/ozet_*.txt`.
Yalnız ERROR satırları: çıkışta "resources still in use" (tüm koşularda, ÖNCE dahil) ve 13 `=depot`'ta ÖNCE'de de bulunan lambda hatası.

## RINFO (`tests/perf_run.sh`, 1280×720, xvfb, ÖNCE | SONRA; çizim çağrısı, gerçek üçgen "RTRI real")

Örnekleme 2 sn'de bir ve **hizasız** (otomatik bot hızlı; PACE'siz) — aynı replik anı garantili değil; ÖNCE'nin kendi iki koşusu bile aynı t'de farklı (13 t=3: 463 vs 622; 12 t=7: 632 vs 814). Bu yüzden iki tur koşuldu (`ham/rinfo_*.txt`), tekrarlanabilir olan alındı.

| Bölüm | Çizim (ort. ÖNCE→SONRA) | Üçgen (aynı t örnekleri) | Hüküm |
|---|---|---|---|
| 1 | t=3 449→447, t=7 698→691, t=9 1501→1522 (+1,4%) | 177→174k, 323→319k, 729→745k (+2,2%) | artış yok (gürültü içinde) |
| **10l** | **t=3 652→666, t=7 671→685, t=9 503→517 (+%2,1–2,8, tutarlı +14)** | 97→98k, 96→96k, 96→96k (+0–1%) | **çizim artıyor: kural ihlali** (geliştirici +21 yazmıştı) |
| 12 | 2. turda t=3 626→638, t=7 814→814, t=9 650→650 | 144→146k, 147→147k, 144→144k | artış yok (1. turdaki +%28,8 faz gürültüsü, ÖNCE'de de 814 çıktı) |
| 13 | t=1 598→598, t=5 6964→6966 (tepe) | 76→76k; tepe 12024→12024k | artış yok; ara örnekler faz farkı |
| 14 | 3446→3446, 3441→3448 (2 örnek) | 797→796k, 775→747k | artış yok (yalnız 2 örnek) |
| 15 | 637→636, 554→554, 670→670 | 106→106k, 520→520k, 529→529k | değişmedi |
| 21o | t=5 484→482, t=9 479→476, t=20 282→284 | 98→97k, 92→89k | artış yok |

Üçgen hiçbir bölümde +%8'i aşmıyor.

## ZORUNLU düzeltmeler

1. **`chapter21o.gd:_place_crew`** (satır ~180): kazmacı konumu `fz + 1.0` → yaklaşık `fz + 1.45` (baş merkezi yüz önünde, ön yüz fz+0,2). Beklenen: kazma başı (iki uçlu) vuruşta yüze iniyor, yüzün içinde kaybolmuyor; sap ve baş karelerde seçiliyor.
2. **`chapter10l.gd:_build`** (satır ~151): yan kazmacıları `ch+Vector3(±1.4, 0, -1.6)` → `-1.0` (baş merkezi iç duvar yüzünden ≥ 0,1 m önde). Ayrıca "herkes donup kalır" sahnesinde (D10L_T_MEET_1 öncesi) oyuncuya yumuşak dönsün (`look_target = player` ya da 0,5 sn tween) ve alet bırakılsın; beklenen: G_MEET_2'de ÖNCE'deki gibi yüzleri oyuncuya dönük.
3. **`chapter13.gd:_lever_knob/_open_window`**: tutuş noktasını gerçek topuz düğümünün dünya konumuna bağla (şimdi `lever.to_global(-0.1,0.39,0)` ~10 cm hatalı); el topuzu sarsın, kol kadrajda görünür kalsın (kolun önünde değil yanında); 0,35 sn kol inişinde el ≥ 20 cm iniş göstersin. Beklenen: QTE karesinde yumruk kırmızı topuzun üstünde, kol inince el onunla iniyor.
4. **`chapter1.gd:_pass_remote`**: Tolga'nın uzanan elini kumandanın bulunduğu **eline** hedefle (`reach_grab(rm.global_position)` Hikmet elindeyken), kumanda ancak temastan sonra ele geçsin ve toplam ek süre ≤ ÖNCE akışı (+0,4 sn'yi sıfırla: bekleme 0,6'ya katıl). Beklenen: t0268 benzeri karede iki el kumandada birleşiyor, havada boş süzülme yok.
5. **`chapter21o.gd:_give_pick`, `chapter10l.gd:_give_pick`**: kazma sapını tutan görünür bir el (ör. `Player.hold_both`/sap kavrama); beklenen: elsiz havada duran kazma yok.
6. **`chapter10l.gd:_build` (Dragan)**: kazmayı baş yan görünecek şekilde döndür (sap ekseninde 90°). Beklenen: D10L_T_04'te T biçimli kazma başı seçiliyor, mızrak gibi okunmuyor.
7. **`scripts/level/otag_hall.gd:_build_people` (kâtip)**: kâtibi kâğıda hizala (x ≈ -3.85 ya da kalem ofseti) ve `z` -1,75 → ~-1,65: kalem ucu kâğıdın üzerinde (x∈[-4,45;-3,95]), dizler masa ön yüzünü (z=-2,10) geçmesin. Beklenen: sonda/oynanış karesinde kalem kâğıtta.
8. **10l çizim sayısı**: Dragan + 2 kazmacı aletleri çizimi +14 artırıyor; alet parçalarını birleştir (tek ağ) ya da kazmacı aletlerini sahne görününce kur; beklenen: 10l RINFO çizimi ÖNCE ile aynı (≤ +0) üç hizalı örnekte.
9. (Küçük) `chapter15.gd:_nod_later`: `randf()` yerine yerel `RandomNumberGenerator`.

## Bakılmadı / sınırlar

Bölüm 5, 8, 10a, 14 kare gezisi; vezirlerde `idle_vary` (madde 11); kâtip oynanış karesi (kadrajda yok); RINFO `PACE`'siz hizasız (yukarıda).
Ortam: Godot 4.4.1 içe aktarma `i18n/*.translation` dosyalarını değiştirdi ve `docs/_kanit_p10/*.jpg.import` üretti; ikisi de geri alındı/kaydedilmedi.

Paftalar: P01 kumanda, P02 kol 13, P03 10l Dragan+oyuncu kazma, P04 10l yan kazmacılar, P05 21o kazma, P06 15 toplantı, P07 12 kâtip (kadraj).
