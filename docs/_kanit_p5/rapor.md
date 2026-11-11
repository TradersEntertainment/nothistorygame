# P5 — Talim alanı ve Osmanlı bataryaları (41o, 42b, 20o, 32o): rapor

Dal: `wip/yardimci-p5` (başlangıç kaydı `1e3a9b60`). Değişen dosyalar: `scripts/level/training_yard.gd`,
`scripts/chapter41o.gd`, `scripts/chapter20o.gd`, `scripts/chapter32o.gd` (`chapter42b.gd` değişmedi: 42b'nin bütün
işi talim alanında). Ortak dosyaya dokunulmadı; yeni `class_name` yok; replik, oynanış, sayaç, kalabalık sayısı aynı.

## Kanıt yöntemi
- ÖNCE: başlangıç kaydının ayrı bir çalışma kopyası; SONRA: aynı kopya + yalnız benim dört dosyam. İkisi de ekranlı
  (`xvfb-run`, 1280×720), `--autotest --dialogshots --shotevery=1`; kareler replik anahtarıyla eşlenir (aynı an).
- Replik olmayan anlar için iki kopyaya da (depoya değil) AYNI ölçüm kancası kondu: top doldururken durum değişince
  `CREW_<adım>_<n>` karesi (cannon_crew.gd) ve 32o'da manto z = 58 / 50'yi geçince `MANTLET_58/50` karesi. Kancalar
  depoda yok (`grep _hk_ scripts` boş).
- Perf: aynı kancada her karede `RenderingServer` çizim ve üçgen (`prims`) sayısı (RINFO ile aynı sayaç).

## Madde tablosu

| # | Bölüm · madde | Ne yapıldı (dosya:işlev) | Pafta | Durum |
|---|---|---|---|---|
| 1 | 41o/42b ip çit: kazıklar arası düz çubuk | `training_yard.gd:_ring`, `_fence_rope_points`, `_tube`: her kazığa 2 tur sarım, iki kazık arasında sarkan (3 m'de ~13 cm) yuvarlak kesitli ince ip (8 köşe, `ThraceRoad.tube_material`: dış çizgisiz, arka yüz ayıklı); girişteki uç kazıklarda bitiş sarımı. Her açıklık ayrı düğüm (düello kamerası "cam_fence" parçayı gizleyebilsin) | 01, 02, 11, 12, 13 | DÜZELDİ |
| 2 | 41o/42b kum zemin düz, 26 koyu disk leke | `training_yard.gd:_ground_detail`: diskler kalktı; halkada çiğnenmiş yumuşak çamur ve ayak izi, merdiven dibi çiğnenmiş, meydanda seyrek iz, çakıl, kuklanın ve silah sehpasının dibinde kırık tahta yonga, balya dibinde saman (42b'de devrilen merdivenin balyalarında da), hedeflerin çevresinde yere saplı kırık ok. Tür başına tek çoklu ağ | 01, 02, 13, 14 | DÜZELDİ |
| 3 | 41o su kabı azabın önünde havada | `chapter41o.gd:_hold_pot`: iki avuç kabın iki yanında (`Stage.grip_hold`), dökerken bırakır, dönünce yeniden tutar | — | KANITSIZ (kap iskelenin mazgallarının ardında; hiçbir karede seçilmiyor) |
| 4 | 41o/42b arkadaki talim edenler | Değişiklik yok: talim çiftleri gerçek düello yapay zekâsı (bağımsız), okçular `archer_loop` rastgele zamanlayıcı; karelerde aynı anda aynı pozda değiller. Balyada oturan ikişer kişi donuk (`Crowd.idle_vary` oturanı atlıyor) | — | Çiftler/okçular ZATEN DÜZELMİŞ; oturanlar DURUYOR |
| 5 | 20o top tayfası boş dikiliyor | `chapter20o.gd:_battery_crew`: `CannonCrew.add_crew` (kepçeci barut kepçesini namluya sürer, gülleci yığından gülleyi iki elle getirir, manivelacı nişanda kuyruğu çevirir); doldurma başlamadan kepçe ve manivela dik elde; dördüncü topçunun elinde soğutma kovası | 03, 04 | KISMEN: kepçeci namlu ağzında kepçesiyle seçiliyor (03), kova elde (04); gülleci ve manivelacı oyuncunun bakışında namlunun ardında kalıyor (KANITSIZ) |
| 6 | 20o batarya zemini düz petek | `chapter20o.gd:_battery_ground`: petek taşın üstünde çiğnenmiş çamur, ayak izi, fıçıların ve namlu ağzının önünde barut lekesi (kara, yumuşak) ve kömür kırıntısı, tapa samanı, çakıl (kızağın, siperliğin, sepetlerin altı boş) | 05 | KISMEN: saman ve barut lekesi seçiliyor; ayak izi zayıf |
| 7 | 32o basamak çakan ustalar aletsiz | `chapter32o.gd` `_build_people` + `_carpenter_bench`: üç marangozun elinde çekiç (faz kişiden kişiye ayrı), önlerinde üç sehpa üstünde yatan merdiven; kirişin üstü vuruş yüksekliğinde (sondayla ölçüldü: Soldier "hammer" vuruşunun en alçak noktası kişinin 0,34 m önü, 0,66 m yüksek); dipte talaş | 06, 07 | KISMEN: çekiçler ve tezgâh seçiliyor; çekicin kirişe indiği an ana tezgâhın ardında, KANITSIZ |
| 8 | 32o mantoyu iten asker "push" pozunda | `chapter32o.gd:_push_grip` + `_process`: iki avuç mantonun arka yüzünde köşeye yakın (tekerleğin dışında durur), gövde öne yatık, ayak tabanı her karede yerde (`Stage.plant_feet`); bitince bırakır | 08 | KISMEN: eller mantoda; özgün karede de el mantonun kenarına yakındı, fark küçük |
| 9 | 32o hendek kıyısı/ova düz | `chapter32o.gd:_field_ground` (yalnız bu bölümün alanı): yığından ve sepetlerden kıyıya giden ayak izi patikası (kıyı boyunca), mantonun tekerlek izi, kıyıda çiğnenmiş çamur, çalı çırpısı, taş | 10 | KISMEN: kıyıda saman çöpü/taş seçiliyor; patika ve tekerlek izi karede seçilmiyor (KANITSIZ) |
| 10 | 32o bataryası bomboş (envanter: "tayfa boş") | `chapter32o.gd:_gun_hands`: batarya evresine geçerken (kararmada) iki marangoz çekiçlerini bırakıp topa yamak olur (kepçeci + manivelacı; üçüncüsü tezgâhta çakmayı sürdürür). Kalabalık sayısı aynı. Batarya zemini 20o ile aynı (`_battery_ground`) | 09 | KISMEN: kepçeci namlu ağzında kepçesiyle seçiliyor; manivelacı kadraj dışında |
| 11 | 32o demet taşıyanların eli boş (demet başın üstünde kendi duruyor) — yeni bulgu | `chapter32o.gd:_shoulder_grip`: avuçlar demetin ön ucunun altında; demet atılınca bırakır | — | KANITSIZ (yan bölük hiçbir karede kadraja girmiyor) |
| 12 | Çizim bütçesi | Duran desensiz parçalar tek ağ (`Props.bake_static`): talim alanında iskele / silah sehpası / balyalar ayrı kümeler (`training_yard.gd:_bake_decor`), 20o ve 32o'da topun mevzisi (`_bake_gun_yard`), 32o'da demet yığını, sepetler, kalaslar | — | bkz. perf |

Paftalar (`docs/_kanit_p5/`, solda ÖNCE, sağda SONRA): 01 41o D41O_H_02 · 02 aynısı yakın · 03 20o CREW_ball_1 yakın ·
04 20o D20O_U_SEVEN yakın · 05 20o D20O_U_HIT_1 · 06 32o D32O_T_U1 yakın · 07 32o D32O_U_02 · 08 32o MANTLET_50 yakın ·
09 32o CREW_ball_1 yakın · 10 32o D32O_T_03 yakın · 11 41o D41O_H_DIR_1 · 12 42b D42B_H_LADDER_1 · 13 42b D42B_H_DIR_1 · 14 42b D42B_H_03.
Kabul kareleri: 41o ip çit → 01/11; 42b ip çit → 12/13; 20o tayfa → 03/04; 32o çakan ustalar → 06/07; 32o manto → 08.

## Testler (başsız, `--max-fps 20`, son kod; `/tmp/p5/tests4`)
| Bölüm | Varyant | Sonuç |
|---|---|---|
| 41o | "", lose | 2/2 AUTOTEST PASS, kötü satır 0 |
| 42b | "", lose | 2/2 AUTOTEST PASS; "" koşusunda 1 satır: `VISAUDIT overlap scene=chapter42b.tscn a=CityLife b=CityLife at=(-7.9, 0.0, -47.9)` |
| 20o | "", wide, lose, hot, hot_taped, hot_tape, named, flawed, edirne, edirne_ok | 10/10 PASS, kötü satır 0 |
| 32o | "", late, cracked, gunner, named, council_ok, council_bad | 7/7 PASS, kötü satır 0 |

`parse_check`: PARSECHECK PASS scripts=247. 42b'deki satır talim alanından ~28 m ötede iki şehir yayasının
örtüşmesi; `city_life.gd:1210` bunu bilinen seyrek sorun olarak anıyor ("dört koşuda bir"). Sayım: son kodla 42b
başsız 10 koşuda 1, ekranlı 1 koşuda 1; özgün kodla başsız 9 koşuda 0, ekranlı 2 koşuda 0. Benim dosyalarımdan
gelmediğini kanıtlayamadım (rastgele zamanlamaya bağlı; CityLife benim paketimde değil): AÇIK.
Ekranlı koşularda 41o ve 42b `AUTOTEST FAIL` (bot iki bitirici yapıyor, üç bekleniyor) ÖZGÜN kodda da aynı; başsızda geçiyor.

## Performans (aynı replik anı, ÖNCE → SONRA; `prims` = üçgen)
| Bölüm | Çizim farkı (ortanca / en kötü) | Üçgen farkı (ortanca / en kötü) | Not |
|---|---|---|---|
| 41o | −173 / −33 (hiçbir anda artmadı) | +%0,1 / +%6,8 (iskele tepesi) | 36 an |
| 42b | −131 / +132 | +%0,4 / +%27,6 | sahnelenmiş anlar (giriş, merdiven, son): çizim −186…+132, üçgen ≤ +%7,2. Düello anlarında kamera ve kadrajdaki kişiler koşudan koşuya değişiyor: ÖZGÜN kodun iki koşusu arasında aynı anlar çizim +605 / −1288, üçgen +%38,5 / −%30. Merdiven anı özgün↔özgün −504 çizim. |
| 20o | −107 / +42 (gece hücumu D20O_U_CHARGE; iki özgün koşu arasında da 28 oynuyor) | +%2,3 / +%7,2 (doldurma, kadrajda yeni tayfa) | 27 an |
| 32o | −161 / +412 (D32O_N_DITCH) | +%2,7 / +%8,5 (D32O_N_DITCH) | batarya evresi ≤ +%7,5, çizim her anda azaldı. N_DITCH karesinde rastgele Rum ateşi/patlama dumanı farklı (iki karede ateşin yeri ve dumanı ayrı; pafta depoya konmadı), aynı evrenin öbür anları (T_02, AZ_02, T_03) çizim −24…−31, üçgen ≤ +%1,6. N_DITCH, H_01 (+359), U_END (+205) üç sonra-koşusunda farklı değerler aldı (+467/+412; +185/+359; −195/+205): KANITLANAMADI, AÇIK. |

Talim alanının sabit eki (sondayla): 9 ip parçası toplam 9 168 üçgen; zemin 6 çoklu ağ (ayak izi ağı tanesi 342
üçgen olduğu için yoğunluk düşük tutuldu: iskele tepesinden bakışta ilk sürüm +%20,8'di). Üç yamak birden kadraja
girince 32o bataryası +%9,1; 20o'nun ilk sürümünde (kovalı topçu namlunun soluna alınmış, zemin daha yoğun) +%10'du:
ikisi geri alındı (32o'da yamak 2, 20o'da kovalı yerinde, iz/çakıl seyrek).

## Ortak dosyalar için öneriler (uygulanmadı)
1. `land_walls.gd:build_great_gun` (1091-1093): topun arkasındaki çit iki düz `Props.box` çubuk (20o/32o'da
   seyirci askerlerin önünde, "çubuk halat"). Öneri:
   ```gdscript
   for y: float in [0.55, 1.0]:
       for i in 8:
           var a := Vector3(-11.0 + i * 2.75, y, 11.6)
           Stage.rope(g, a, a + Vector3(2.75, 0, 0), 0.07, 0.016)
   ```
2. `land_walls.gd:_great_gun_model` siperlik halatı (1175) ve halat bağı (1196) düz `Props.cyl`: `Stage.rope` ile
   makaradan bocurgata sarkan halat.
3. `Nature.DETAIL`'de `cobble_wear` yok (ortak_eksikler §10'da var); batarya döşemesinde `camp_mud` kullandım.
4. `Nature.detail_mesh("footprint")` 342 üçgen: kuşbakışı/geniş alanlarda bütçeyi yiyor; ~60 üçgenlik hâli önerilir.
5. `Props.bake_static` UV taşımıyor: desenli (dokulu) parçalar birleştirilemiyor (dışarıda bıraktım).
6. `CannonCrew._crew_spots`: gülle ve manivela yerleri büyük topta oyuncunun bakışında namlunun ardında; oyuncu
   tarafına (side +) alınırsa tayfa okunur.

## Bakamadıklarım
- 41o su kabı tutuşu, 32o demet taşıyanların tutuşu, 32o mantonun tekerlek izi, çekicin kirişe indiği an: kadrajda yok.
- 42b'de okçu oklarının düştüğü yerin talim alanı yüzeyine oturması (`archer_loop` `Assault.ground_y` kullanıyor): bakılmadı.
- Gece evreleri (20o hücum, 32o ateşler) yalnız perf için ölçüldü; görsel inceleme yapılmadı.
