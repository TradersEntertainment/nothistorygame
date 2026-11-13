# PİLOT-20 — Bölüm 20 ve 20o yeni İstanbul surunda (Mesoteikhion kesimi): doğrulama raporu

> Dal `wip/ist2-pilot-20`. Taban: önceki oturumun kanıtsız kaydı `9f32c394`. Bu oturum: kur, koş, bul, düzelt, kanıtla.
> Sur görünüşü dosyalarına (`surlar*.gd`, `sur_oturtma_ag.gd`, `sur_gorunus.gd`, `sur_zemin.gd`, `sur_doku.gd`, `sur_kule.gd`,
> `gorsel_dil.gd`, `ordugah*`) ve `sur_sozlesme_donmus.json`'a dokunulmadı. Denge, hasar, sayaç, replik metni, ses: değişmedi.
> Ham çıktılar `testler/`, kareler `kare/`. Makine: 4 çekirdek, ekransız testler `--max-fps 20`; kareler xvfb + Mesa llvmpipe
> (yazılımsal GL, kare başına ≈1,3 sn).

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | Kurulum + ayrıştırma | **TAMAM** | Godot 4.4.1 resmi, `--import`, `PARSECHECK PASS scripts=354`; Bölüm 20 yeni sette ilk koşu PASS |
| 2 | Testler (20 ×3 + eski ×1; 20o ×2 + eski ×1) | **TAMAM** (bir madde KISMEN) | ilk tur 66/66 PASS, denetim 0; bulunan 4 kusur düzeltildi; son tur aşağıda. 20o `=wide` düellosu hâlâ eskiden uzun (KISMEN) |
| 3 | Öteki bölümler | **TAMAM** | 21 bölüm PASS, denetim 0. 26 `=hold_box`'ta seyrek `VISAUDIT overlap` **taban kayıtta da var** (pilot öncesi) |
| 4 | Sözleşme | **TAMAM** | `SURSOZLESME PASS kalem=13 kesim=8`; `SUROYUN … havada=0 gomuk=0 katida=0`; `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` |
| 5 | Gerçek yürüyüş | **TAMAM** | iki sette 10 bacak, takılma 0, düşme 0, etkileşim eksiği 0 |
| 6 | Kareler | **TAMAM** (Bölüm 20: 10 çift) / bkz. 20o | oyuncunun kamerasından 1280×720 jpg 85 + pafta |
| 7 | Yöneticinin gördükleri | **KISMEN** | bant ve dikdörtgen yama = sur kesiminin `SurDibiEtek`'i (tur 7'ye istek, teşhis karesiyle); set dekoru yerleşimi düzeltildi |
| 8 | Bütçe | **TAMAM** | yeni set eski setten HAFİF (çizim −%25…−%45); kurulum ölçüldü |
| 9 | Rapor | **TAMAM** | bu belge |

## Bu oturumda bulunan ve düzeltilen kusurlar (kök neden → düzeltme → kanıt)

1. **Gözcü canlı değildi** (yeni sette `=hit`/`=lose`'da `WARN_PORTRAIT_STUDIO speaker=SPK_LOOKOUT`, eskide yok). Yeni kesimde gediğe
   en yakın kurulu dış kule x 35,4 (eskide ±16); bölümün "yakın" aralığı ±32 olduğundan kule gözcüsü uzak siluet (MultiMesh)
   kalıyor, "Top geliyor!" sahnede yüzü olmayana düşüyordu. → `Garrison._land_walls_sur`: yakın aralık verilmişse gediğe en
   yakın kurulu dış kulenin gözcüleri canlı (eski anlam). Kanıt `testler/ara_c20_yeni_*_fix*.txt`, son matris.
2. **Moloz sırtı yanlış yerdeydi** (20o `=wide` düellosu 41/43 sn ↔ eski 13/11). `SurSet.moloz_sirti()` duvarın ortasını veriyordu;
   eskide sırt dış yüzün 0,2 m DIŞI, bütün barikat aşamalarının ova tarafıydı. Aşama 4'te `GedikOnarim` dış yüze insan boyu kazık
   çit (çarpışmalı) kurar: azaplar çitin içinde, oyuncu dışında kalıyordu. → sırt dış yüz + 1,4 m (çitin bir kişi payı önü).
   Sonuç: 20o `=wide` 2. dalga 43 → 22 sn; Bölüm 20 2. dalgası 31 → 17 sn (eski 24). **1. dalga hâlâ 35–41 sn (KISMEN)**:
   deneyle kanıtlı neden aşama 4'ün dış çiti (çit çarpışması kapalı denemede 11/15 sn, `testler/ara_deneme_citsiz_wide*.txt`;
   deneme kayda girmedi). Çit sözleşme parçası: bkz. "tur 7'ye istekler".
3. **Komutan taşıyıcıların arkasında kalıyordu** (`VISAUDIT personhidden key=D20_G_ASSAULT / D20_G_DUEL speaker=SPK_GIUST
   by=WallFight>Person`, kare koşusunda). Yeni sette depo ve taşıyıcı şeridi gediğin SOLUNDA; Giustiniani de soldaydı, şeride
   0,7 m. Eskide komutan şeritlerin karşı yanındaydı ("işçilerin ve taşıyıcı şeritlerinin dışında"). → Giustiniani ve Leon
   gediğin sağında (iç kulenin önü, işçilerle sağ siperin arası); doğuştan uzaklık eskiyle aynı (≈14 m). Engel denetimi 0.
4. **Okçular gedikten 21,8 m uzaktaydı** (eski 9,8). Gedik düellosu oyuncunun durduğu yerde başlar (azaplar oyuncunun gedik
   yönünde 3,6 m önünde doğar): ok teslim eden oyuncu için düello peribolosun ortasında açılıyordu. → okçular eskideki yerine
   (−9; 0; 11), ok sandığı depo yanına, iç surun dibine (−16; 0; 1,2). Hücumdaki ok koşusu eski 31,6 ↔ yeni 30,1 m (yürüyüşte
   26,7 ↔ 26,2 m).
5. **Mini harita yeni sette yoktu** (pafta: eskide sağ altta var). Yeni ova `SiegeField.world = false` kurulur; harita alanı
   (`MapView.GROUP`) yalnız `world` kurulumunda gruba giriyordu. → `SurSetSahne._harita()`: kesimin gerçek dünya yeri
   (`SurOyun a.xf`) ile IstBaglama'nın yaptığı gibi v2 harita alanı + `MapView.v2` (sahneden çıkınca kapanır).
6. Küçükler: `Assault` yeni sette tabya ve mancınık yönü ova kaydırmasını hesaba katıyor (bataryayla aynı); `spear_loop`
   yer değiştirirken komşunun VARACAĞI yeri de dolu sayar (yarış durumu; 26'daki overlap'ı tek başına çözmedi, aşağıda).
7. Test aracı: `=kare` bacakları ışınlar (yazılımsal GL'de gerçek yürüyüşle saatler sürüyordu; yürüme `=yuru`'da ölçülür),
   tüfek evresini atlar, karede gece saati gerçekçi (eskiden HUD'da "Saat −9.−31"), onarım karesi taşıyıcıların varış
   noktasının yanından. Teşhis aracı `tests/_ist/pilot20_teshis.tscn` (sur dışındakileri gizleyip kesimin adlı düğümlerini
   tek tek gizler).

<!-- DEVAMI: test tabloları, mesafe, bağdaştırıcı, kareler, bütçe, replikler, kılavuz, istekler -->
