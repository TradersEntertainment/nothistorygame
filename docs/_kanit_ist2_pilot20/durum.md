# PİLOT-20 doğrulama — durum (her kayıtta güncellenir)

Taban kayıt: `9f32c394` (önceki oturum; kanıtsız).

## Biten
- 1. Kurulum + ayrıştırma: Godot 4.4.1, `--import`, `PARSECHECK PASS scripts=354`; Bölüm 20 yeni sette ilk koşu PASS.
- 2. Test matrisi ilk tur (66 koşu): hepsi `AUTOTEST PASS`, denetim satırı 0 (`testler/`). Bulgular:
  - yeni sette `=hit`/`=lose`'da `WARN_PORTRAIT_STUDIO SPK_LOOKOUT` → gözcü canlı değildi (en yakın kurulu dış kule x 35,4 >
    yakın aralık 32). Düzeltildi (`garrison.gd _land_walls_sur`).
  - 20o `=wide` düellosu 41/43 sn (eski 13/11): `SurSet.moloz_sirti()` duvarın ortasındaydı (aşama 4 çitinin içi).
    Sırt dış yüz +1,4'e alındı → 2. dalga 22 sn, 1. dalga hâlâ 35–41 sn (KISMEN; neden aşama 4 dış çit, deneyle kanıtlı).
- 3. Öteki bölümler: 21 bölüm varsayılan PASS, denetim 0. 26 `=hold_box`: 6+8 koşuda 2 `VISAUDIT overlap`; taban
  kayıtta (20948418) da 12'de 1 (Squad/Squad) → pilot öncesinden. `spear_loop` hedef ayırma eklendi (yarış durumu).

- 4. Sözleşme: `SURSOZLESME PASS kalem=13 kesim=8`, `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`,
  `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`.
- 5. Yürüyüş: iki sette 10 bacak, takılma 0, düşme 0, etkileşim eksiği 0 (`testler/yuruyus_*.txt`).

## Süren
- 6. Kareler: `=kare` ışınlamalı (yazılımsal GL'de gerçek yürüyüşle saatler sürüyordu); tüfek evresi bu çeşitte atlanır.
- 8. Bütçe: ilk ölçüm (eşzamanlı koşu; eski "hava" eksik) `testler/butce_*_ilk.txt`; tek başına yeniden ölçülecek.

## Sıradaki
- 5. yürüyüş, 6. kareler, 7. görsel kusurlar (teşhis aracı hazır), 8. bütçe, son tam matris, 9. rapor.
