# İstanbul 1453: forumlar paketi (dal `wip/ist-forumlar`)

Dosyalar: `scripts/world/ist/forumlar.gd` (`IstForumlar`: catalog, build_*/perches_*/climbs_*), `scripts/world/ist/forumlar_yapi.gd`
(`IstForumlarYapi`: ortak yapı taşları), `tests/_ist/forumlar_onizleme.{gd,tscn}`. Var olan hiçbir dosya değiştirilmedi.

## Araştırma özeti (kaynaklı; kısa tutuldu)
- Arkadius Sütunu: Xerolophos tepesinde, 421'de tamamlandı; yükseklik kaynağa göre ~40–50 m; sarmal kabartma 14 tur
  (Freshfield Albümü, 1574 çizimi); heykel 704/740'ta düşmüş; 1715–1719'da yıkıldı (yani 1453'te ayakta).
  Kaynak: Wikipedia "Column of Arcadius", livius.org. Gövde çapı için kaynak bulamadım → kestirim (≈ 3,8 m).
- Konstantin Sütunu: oval forumun ortasında, porfir tamburlar (7–11 sayı kaynağa göre değişir), beyaz mermer kaide;
  toplam yükseklik ~35–40 m (heykelsiz). Demir çemberlerin tarihi belirsiz (Osmanlı ~1515 ya da daha önce).
  Kaynak: Wikipedia "Column of Constantine". Tepedeki haç (1081 sonrası) → yapıda haç var.
- Tauri (Theodosius) Forumu: ortada sütun (sarmal kabartma, tepede heykel; ~40 m kestirim), batıda üç gözlü zafer takı kalıntısı.
  Kaynak: cavac.at "Forum of Theodosius", livius.org, Columbia Istanbul Documentation Project. Sütunun 1500'e kadar
  ayakta olduğu bilgisi kaynaklarda dolaylı → ayakta kabul ettim (kestirim).
- BELİRSİZ / KESTİRİM: Amastrianon'un 1453'teki düzeni (pazar meydanı kurguladım), Forum Bovis'te bronz boğanın 1453'te yerinde
  olup olmadığı, Anemodoulion'un 1453'te ayakta olup olmadığı (harap + devrik figür kurguladım), Myrelaion rotunda çapı
  (~24 m kestirim), Kapitolion'un yerleşimi ve boyutları, Philadelphion tetrapylon'un ayrıntıları. Konumlar (catalog)
  ±100–200 m belirsiz; CityGeo dayanakları gelince şehir kurucusu düzeltmelidir.
- Mese: 1453'te revaklar yer yer yıkık, dükkân olmuş; ölçüler (yol 11 m + iki revak 4,5 m + dükkân 4 m ≈ 28 m) kestirim.

## Oyuncu yetenekleri (koddan)
`player.gd`: JUMP = 3,6, yerçekimi 9,8 → zıplama h = 3,6² / (2·9,8) = **0,66 m**; `STEP_H` = 0,42 m (yürüyerek çıkılır);
`traversal.gd` (tırmanma kipi): REACH 2,3 m, VAULT_MAX 1,1 m. Bu pakette tüm yollar **yürüyerek**: basamak 0,28 m (≤ 0,42), tırmanma kipi gerekmez.

## Öğe listesi
| id | ne | durum |
|---|---|---|
| mese | revaklı cadde dilimi (parametreli uzunluk), yıkık sütunlar, dükkân, çatılar, dış merdiven | TAMAM (v1) |
| konstantin | oval forum, porfir sütun (demir çember, haç), iki kapı (biri yıkık) | TAMAM (v1) |
| tauri | zafer takı kalıntısı, gözyaşı sütunları, Theodosius Sütunu (sarmal) | TAMAM (v1) |
| amastrianon | pazar meydanı, havuz, çınarlar, yıkık revak köşesi | KABA/TAMAM (kestirim) |
| bovis | meydan, bronz boğa kaidesi, yıkık dükkân sırası | KABA/TAMAM (kestirim) |
| arkadius | sarmal kabartmalı ~50 m sütun, kaide, iç merdiven kapısı | TAMAM (v1) |
| markianos | granit tek parça sütun, Korint başlık, Nike madalyonları, kartallar | TAMAM (v1) |
| myrelaion | rotunda alt yapı + haç planlı üç apsisli kilise, kubbe | TAMAM (v1) |
| philadelphion | tetrapylon (dört kemer, bir yüzü yıkık) | TAMAM (v1) |
| kapitolion | podyum, kırık Korint sütunları, alınlık parçası, hücre duvarları | TAMAM (v1) |
| anemodoulion | dört yüzlü piramit kule, bronz levhalar, devrik figür | TAMAM (v1) |

