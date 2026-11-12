Oyuncunun ayaklarından başlayan, insan biçimli bir gölge gövdesi ekledim. 8y'de artık adamın gölgesi ve elinden uzanan sırık gölgesi görünüyor. Ayakta, çömelme, oturma ve uçuşta çalışıyor. Yürüyüşte bacak salınımı ve oturma gölgesi karede seçilmiyor, aşağıda KANITSIZ yazdım.

**Kök neden.** Birinci şahısta oyuncunun gövdesi hiç çizilmiyor. Yerde yalnız `hand_rig`, `carry` ve bölüm eşyalarının gölgesi kalıyordu; gölge atan tek kol parçası serbest elin 34 cm'lik kolluğuydu (`player.gd` `_build_free_hand`). Ek olarak `chapter34o.gd:105` (`_no_hand_shadow`) kameradaki her şeyin gölgesini kapatıp sorunu kendi bölümünde gizlemiş. Aynı sorun güneşli ve ay ışıklı bütün bölümlerde vardı.

**Eklenenler.**
- **Yeni dosya `scripts/player/shadow_body.gd`** (`class_name` yok, `persons` grubuna ve çarpışmaya girmez):
  - Tek iskelet ve tek ArrayMesh, `SHADOWS_ONLY`, 376–440 üçgen. Ağ yalnız karakter, fes veya kaftan değişince yeniden kurulur; her karede yalnız kemikler güncellenir.
  - Karakter: Tolga fesli (fes takılıysa; `wears_fez()`), kaftanlı ya da redingotlu; Nihat fötrlü; Hikmet şapkasız.
  - Kollar iki kemikli yönelimle `hand` ve `free_hand` düğümlerine uzanır, `hold_both` dahil. Bacaklar ayağı yere basar; çömelme, oturma, yürürken salınım ve tekme için ayrı durumlar var.
  - Gizlendiği anlar: oyuncu kamerası etkin değilken (ara sahne, fotoğraf, selfie, düello bitirici, `outfit_view`), Nihat görünmezken, merdiven, tırmanma, yüzme, yere serilme, emekleme ve tavuk. Oyuncunun kendi üçüncü şahıs modeli yanında görünürse de gizlenir.
- **`player.gd` içinde şunlar eklendi:**
  - `preload` ve `_ready` içinde kurulum.
  - Serbest el kolluğunun, `BothSleeve`'in ve tekme bacağının gölgesi kapatıldı (çift kol/bacak gölgesi olmasın).
  - `select_item` içinde eldeki eşyanın gölgesi kapatıldı.
- **`nihat_powers.gd`, `hand_rig.gd`, `carry.gd` değişmedi.**
- **Çakışma:** `grep` ile başka bölümde oyuncu gölgesi taklidi bulunmadı; tek çakışma `chapter34o`'daki kapatma.

**Durum.** Karelerin hepsi `$S/nihat/golge/cift/` altında, indeks `INDEKS.md`'de.

| Durum | Kare | Sonuç |
|---|---|---|
| 8y havlu, adam + sırık | `sonda_once_8y_p50` / `sonda_sonra_8y_p50` `towel.png` | DÜZELDİ |
| 8y oynanış (ok anı, sahibin kare) | `once_8y_warn` / `sonra_8y_warn` `c_ok_1.jpg` | KISMEN: güneş önde, gövde gölgesi kadraj dışında; güneş arkadayken aynı kodla sonda karesinde görünüyor |
| ayakta (kızak, 28o) | `sonda_*_2`, `sonda_*_28o_b` `stand.png` | DÜZELDİ |
| çömelme | `sonda_sonra_28o_b/crouch.png` | DÜZELDİ (yassı, kambur silüet) |
| oturma (`seated` bayrağı) | `sonda_sonra_28o_b/seat.png` | KANITSIZ: şekil çömelmeye benziyor, oturma olduğu ayırt edilmiyor |
| uçuş / görünmezlik (Nihat, bölüm 11) | `sonda_*_11` `fly.png` / `cloak.png` | DÜZELDİ: uçuşta yere düşen adam gölgesi, `cloak.png`'de gölge yok |
| üçüncü şahıs anı | `sonda_sonra_28o_d/outfit_*.png` | GİZLENDİ: kamera oyuncunun değil, gölge gövdesi kapalı |
| iki el, taşıma | 8y `towel.png` | iki el DÜZELDİ; `carry.gd` taşıma KANITSIZ |
| tekme | `sonda_sonra_2_b/kick.png` | KISMEN: sağ bacak ayak bileğine yöneliyor, silüet net değil |
| yürüyüş | `sonda_sonra_2_b/walk.png` | KANITSIZ: bacak salınımı seçilmiyor |
| kayık (`pinned`) | — | KANITSIZ: 17. bölümde `pinseat` kare almayı denedim, bölüm kayık değil bir iç mekân çıktı |
| gece sahnesi | `sonda_*_11` `stand.png` | DÜZELDİ: ay ışığı fötrlü gölgeyi atıyor |
| aynada `Person` ikizi | — | KANITSIZ: aynadaki ikiz çifte gölge verebilir; ikiz `persons` grubundan çıkarıldığı için algılanmıyor |

Gece sahnesi için 20. bölümü denedim; gün batımında gölge yoktu, o yüzden 11'i kanıt aldım. Yeni bir kare isterseniz 30o'yu denerim.

**El eşyaları (önce).**

| Eşya | Gölge (önce) | Gölge (şimdi) |
|---|---|---|
| telefon (13,8 cm) | atıyordu | yok |
| kitap (iki parça, ~10 cm) | atıyordu | yok |
| termos (12 cm) | atıyordu | yok |
| selfie çubuğu (27 cm) | atıyordu | yok |
| kumanda, çakmak, leblebi, powerbank, bant, kolonya, küp | atmıyordu | yok |

Hiçbiri yerde devasa görünmüyordu. Bölüm yükleri (havlu sırığı, kova, kalas) gerçek boyutuyla gölge atmaya devam ediyor. Bu tabloyu `select_item` içinde bir döngüyle tutarlı yaptım; kameraya bağlı diğer eşyalara (`show_prop`, `hold_model`, `carry`) dokunmadım.

**Testler.**
- `parse_check` PASS.
- Aşağıdaki bölümlerin hepsi RUNOK (`testler_sonuc.txt` dosyasında 0, 2 ve `=next` dahil 8 varyant, 7, 8y, 11 ve diğerleri): 0, 2, 7, 8y, 9, 10b, 11, 17, 20, 28o, 30o, 35o, 43o.
- `CAMCHECK`, `FXCHECK`, `FOCUSCHECK` PASS.
- `prun_say.sh` VISAUDIT, WALKTHRU, ARMAUDIT, HELDAUDIT ve SCRIPT ERROR'da RUNFAIL basıyor. Hiçbir koşuda RUNFAIL çıkmadı.
- 9, 10b ve 11'de yalnız varsayılan koşu geçti (11'in tüm varyantları geçti); 9'un diğer 11 varyantını koşmadım.
- Aşağıdaki RINFO karşılaştırmasının "sonra" tarafı, değişiklik tamamlanmadan önce çekilmiş olabilir; ağır siege bölümünde (20) sonra koşusu hâlâ sürüyordu. Aynı anlarda alınmadığı için dalgalanma var.

**RINFO** (medyan çizim / üçgen k / gölge üçgeni k):

| Bölüm | Önce | Sonra |
|---|---|---|
| 8y `=warn` | 4306 / 5623 / 986 | 4221 / 5297 / 940 |
| 20 | 7917 / 10092 / 3345 | 7885 / 10079 / 3342 |

Sabit sahnede gölge gövdesi açıp kapayınca gölge geçişinde +880 üçgen çıktı (440 üçgen × 2 kademe, yani en çok +2 çizim). Çizim ve üçgen artışı gürültünün altında kaldı.

**Açık kalanlar ve öneriler.**
- `chapter34o.gd` içindeki `_no_hand_shadow` artık gereksiz; silinirse havan/tokmak ve kol gölgesi görünür (bu dosyaya dokunmadım).
- Aynadaki ikiz çifte gölge verebilir (`mirror.gd` `_me` `persons` grubundan çıkarılmış). İstenirse `_me`'ye bir işaret koyulup gölge gövdesi buna göre kapatılır.
- Merdiven, tırmanma ve yüzmede gölge bilerek kapalı.

`tests/_tmp` içindeki geçici sonda dosyaları silindi (kareler scratchpad'de). `git` ile yalnız `scripts/player/player.gd` değişti, bir de `shadow_body.gd` yeni dosya.