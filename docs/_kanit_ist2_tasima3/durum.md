# TAŞIMA-3 durum (her kayıtta güncel)

Dal `wip/ist2-tasima3`, taban `wip/ist2-birlesik` ee2ee089.

## Biten
- Kurulum: Godot 4.4.1 resmi, `--import` rc=0. Taban sözleşme: `SURSOZLESME PASS kalem=13 kesim=8`, `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`.
- Madde 1 kök neden (sonda `testler/sonda/`, 12 koşu): şafakta (sayaç 5 → 10, aşama 2 → 4) toprak setin kutusu gedikte
  duran DOST düellocunun (team 0, IDLE, hedefsiz; 5/12) ve cesetlerin (7/12) üstüne kuruluyordu; `dismiss_idle` kutudan
  SONRA çağrılıyordu. Düzeltme: dostlar barikattan önce çekilir (+1 kare), `SurSetSahne._kutudan_cikar` aşama yükselince
  kutudakileri şehir yanına alır. Sonra (`testler/sonda_sonra/`, 12 koşu): kutuda 0.
- Madde 2 kod: toprak yığını + çuval + taş + kazık; düzensiz sivri kazık çit + ip; köprü kirişli sur yolu (kare bekleniyor).
- Madde 3 kod: 21'de depo 7 m sola (`DEPO_KAYDIR_21`).

## Süren
- Bölüm 20 ÖNCE/SONRA kareleri (`kare/c20_once`, `kare/c20_sonra`).

## Sıradaki
- Ölçüm: `=late` ×20, `=lose` ×5, 20 ×2, 20o ×1, 21 ×1; sözleşme üçlüsü.
- 4 Bölüm 0 taşıma; 25 yetişirse.
