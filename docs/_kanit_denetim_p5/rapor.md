# P5 bağımsız denetim raporu (talim alanı ve bataryalar: 41o, 42b, 20o, 32o)

Denetlenen: `1e3a9b60` (ÖNCE) → `efca085b` (SONRA, `wip/yardimci-p5` ucu). Değişen dosyalar: `chapter20o.gd`, `chapter32o.gd`,
`chapter41o.gd`, `level/training_yard.gd` (`chapter42b.gd` değişmedi). Oyun koduna dokunulmadı; ÖNCE = depo dışında
`~/w/once` kopyası (aynı 4 dosya `git show 1e3a9b60:` ile eski hâle getirildi), SONRA = depo. Karelerde kullanılan tek
fark, İKİ kopyaya da (depoya değil) konan aynı ölçüm satırı: her replik karesinde `DSHOT key draws prims` ve her snap'te
`SNAP` (`RenderingServer` sayaçları, RINFO ile aynı). Ekranlı koşular: xvfb 1280×720, `PACE=1 RINFO=1 --dialogshots
--shotevery=1 --snapevery=0.5`, kareler replik anahtarıyla eşleşir. `tests/_tmp` boş, `git status` temiz (yalnız bu klasör).

## 1. Madde madde hüküm

| # | Madde (geliştirici durumu) | Hüküm | Gerekçe (kare) |
|---|---|---|---|
| 1 | 41o/42b ip çit (DÜZELDİ) | **DOĞRULANDI** | 01, 03, 04: ÖNCE düz kalın çubuk; SONRA ince, kazıkta sarımlı, sarkan ip. Girişte ip yok (aynı). Kazıktan kazığa iki uçta bağlı. Yakın planda iç yüz/gri şerit görülmedi. |
| 2 | 41o/42b zemin diskleri (DÜZELDİ) | **DOĞRULANDI** | 02, 03: ÖNCE düzgün koyu diskler; SONRA ince iz, çakıl, yonga, saman, kırık ok. Kuşbakışı ızgara/yama görülmedi. Aşırı koyu leke yok. 42b'de taş döşeme üstünde de oturuyor (04). |
| 3 | 41o su kabı (KANITSIZ) | **KANITSIZ** (benim karelerimde de) | 12: azap iskelenin üstünde, kap hiçbir karede seçilmiyor. Kod (`_hold_pot`, `_pour`) okundu, testler geçti; görünüm doğrulanamadı. |
| 4 | Arkadaki talim edenler (çiftler zaten düzelmiş; oturanlar DURUYOR) | **KANITSIZ** | Değişiklik yok (diff'te yok). Oturanların donukluğuna ayrıca bakılmadı. |
| 5 | 20o top tayfası (KISMEN) | **KISMEN (geliştiricinin dediği gibi)** | 05, 06: ÖNCE tayfa kare dışı/boş dikili; SONRA dördüncü topçunun elinde kova seçiliyor (05) ve top ateşinde iki tayfa namlu çevresinde (06, biri sağda namlunun yanında). Kepçe/manivela/gülle işi bakış açısından Urban ve namlunun ardında kalıyor: KANITSIZ. |
| 6 | 20o batarya zemini (KISMEN) | **KISMEN** | 05/06: SONRA ince saman ve çakıl çubukları seçiliyor, petek taş artık aynı; barut lekesi/ayak izi bu açılarda zor görünüyor. ÖNCE'ye göre kötüleşme yok. |
| 7 | 32o çakan ustalar (KISMEN) | **KISMEN → eller/çekiç DOĞRULANDI** | 07, 08: SONRA sehpa üstü merdiven tezgâhı ve elinde çekiç (mavi marangozun kolu havada, 07) görünüyor; ÖNCE aletsiz. Çekicin kirişe indiği an kadrajda değil: KANITSIZ. |
| 8 | 32o manto iten (KISMEN) | **KISMEN** | 10 (snap t0350 ÖNCE / t0357 SONRA, manto itme evresi): iki avuç mantonun kenarında/arka yüzünde; ÖNCE'de de el kenardaydı, fark küçük. Ayak/zemin teması kare dışı. |
| 9 | 32o hendek kıyısı (KISMEN) | **KISMEN** | 07/08'de saman çöpü ve taş görünüyor; patika ve tekerlek izi seçilmedi → KANITSIZ. |
| 10 | 32o bataryası yamakları (KISMEN) | **KISMEN** | 09: SONRA iki yamak (kırmızı, mavi) topun arkasında duman içinde duruyor, ellerinde alet seçilmiyor; batarya evresinin girişinde (karartma sonrası) biri Ali'nin solunda dikili, ani "belirme" kadrajda görülmedi. |
| 11 | 32o demet taşıyan eli (KANITSIZ) | **KANITSIZ** | Yan bölük hiçbir karede yok. |
| 12 | Çizim bütçesi | **DOĞRULANDI (41o, 20o, 32o); 42b'de KANITLANAMADI** | Bkz. §4. |

Geliştirici raporunda yanlış çıkan: "ekranlı koşularda 41o ve 42b AUTOTEST FAIL, özgünde de aynı" — benim ekranlı
koşularımda 41o (ÖNCE ve SONRA) ve 42b (ÖNCE ve SONRA) **PASS** verdi: iddia yeniden üretilemedi (yanlış/koşula bağlı).

## 2. `VISAUDIT overlap CityLife` (42b)
Yirmişer başsız koşu (`--chapter=42b --autotest`, ÖNCE kopyası ve SONRA): **ÖNCE 1/20** (`o_42b_19`, at=(-7.4,0,-42.8)),
**SONRA 1/20** (`s_42b_6`, at=(-42.4,0,-44.7)). İkisinde de `a=CityLife b=CityLife`, `src=...LandWalls>SiegeField>CityLife>Person`.
Hüküm: **paketten gelmiyor**, özgün kodda da var (rastgele CityLife yayası örtüşmesi). Geliştiricinin 0/9 ÖNCE sayımı örneklem
küçüklüğü. Bu denetimde ek olarak `lose` (63 sn) varyantı temiz.

## 3. Yeni kusur araması
Gezilen: 41o, 42b, 20o, 32o ekranlı tam koşular (SONRA'da ~1000-1300 snap; her 35. kare + replik kareleri + 32o manto/batarya
evresi snap'leri). Bulunan **yeni** kusur: yok. Not edilenler:
- 32o U_END (11): SONRA'da Mahmud'un yanında dikey kırmızı çubuk "havada gibi" — `chapter32o.gd:208` hendek kıyısı
  kazığı (`Props.cyl 0.04×1.2 b3262d`), **ÖNCE'de de var** (yalnız ÖNCE karesinde Mahmud'un gövdesi kadrajı kapatıyor). Kusur yeni değil, pakette değil.
- 20o/32o yamakları namlu ardında ve duman içinde; bakışa girmiyorlar (geliştirici de yazmış).
- Gövdeye giren ip, eli boş çalışan usta (32o marangozlar elinde çekiç var), küp ateş, dev alet, yanlış yöne bakan kişi: görülmedi.
- Gece evreleri (20o hücum, 32o ateşler) görsel incelenmedi (kısmen kare listesine bakıldı): BAKILMADI.

## 4. Kurallara uygunluk
- Diff taraması: replik anahtarı/sırası, süre, sayaç, sonuç koşulu, kalabalık sayısı, bot yolu **değişmemiş**. Tek oynanışa değen
  değişiklik: 32o marangozların ve mantoyu itenlerin sahne konumu (`chapter32o.gd` `_build_people`: `BENCH+(-2.2+i*2.2, 0, -2.7)`;
  `_process`: iticiler `mantlet.position + (±1.4, 0, 0.8)`); bot yolu/sayaç etkilenmedi (testler aynı çıktı).
- Kanca/DBG/sonda/`no_audit`/`_ok` meta: `git diff 1e3a9b60 HEAD -- scripts` taramasında **yok** (`print`, `DBG`, `_hk_` sıfır);
  tests/_tmp yok. Susturulmuş denetim yok.
- Kullanılan `Props.bake_static` birleştirmeleri hareketli parçalara dokunmuyor (Carriage/Pivot Node3D, `gun.get_children()` yalnız duran MeshInstance3D); koşularda `SCRIPT ERROR` yok.
- `chapter32o.gd:_push_grip` içinde kapanmayan döngülü Tween (`set_loops`, `plant_feet`) iticiler gizlenince `is_visible_in_tree` ile boş döner; sızıntı küçük (iki Tween) ama `grip_release` onu öldürmüyor (ZORUNLU değil, öneri).

## 5. Testler (başsız, `--max-fps 20`) ve RINFO
| Bölüm | Koşu | Sonuç |
|---|---|---|
| 41o | "", lose | 2/2 PASS, kötü satır 0 |
| 42b | "" ×20, lose | 21/21 PASS; 1 `VISAUDIT` (bkz. §2; ÖNCE'de de 1/20), diğer kötü satır 0 |
| 20o | "", wide, lose, hot, hot_taped, hot_tape, named, flawed, edirne, edirne_ok | 10/10 PASS, kötü satır 0 |
| 32o | "", late, cracked, gunner, named, council_ok, council_bad | 7/7 PASS, kötü satır 0 |
| 20, 28o, 35o | "" | 3/3 PASS, kötü satır 0 |
| Ekranlı | 41o, 42b, 20o, 32o (ÖNCE ve SONRA) | 8/8 PASS (SONRA 41o'nun tam 1280 koşusu arka plan süre sınırıyla bitiş satırından hemen önce kesildi (34 replik karesi alınmıştı); 640 px koşusu tam: PASS) |
`ERROR: ... still in use at exit` / `Pages in use` satırları ÖNCE'de de var (özgün gürültü).

RINFO (aynı replik anı, ÖNCE→SONRA; `rinfo_ozet.txt`, `rinfo_karsilastir.py`):
| Bölüm | Ortak an | Çizim (ortanca / en kötü) | Üçgen (ortanca / en kötü) | Hüküm |
|---|---|---|---|---|
| 41o | 34 | −180 / −85 (hiç artmadı) | −0,3% / +1,7% | **UYGUN** |
| 20o | 17 | −109 / −51 (hiç artmadı) | +1,3% / +4,4% | **UYGUN** |
| 32o | 41 | −293 / +174 | +0,9% / +9,9% (D32O_U_END) | **AÇIK**: tek an çizim +174, üçgen +%9,9 (kadrajda rastgele patlama/duman; geliştirici de bu an için ±200 oynama gördü). |
| 42b | 44 | −132 / +1483 | +1,8% / +54,6% | Sahnelenmiş anlar (N_01, HELLO, T_01, H_02, P_HELLO, T_02, H_03, 42b ortak kare): çizim −178…−195, üçgen −2,0…+2,4% → **UYGUN**. Düello/bitiriş anları (FIN_*, PARRY_*) ±1000 çizim oynuyor: kamera/rakip konumu koşudan koşuya farklı → **KANITLANAMADI**; H_LADDER_1 (+313 çizim, +13,6%) karede kamera farkı var (04). |
Her aynı-andan üç örnek: 42b H_02/H_03/T_01 (çizim −186/−195/−184; üçgen +1,0/−1,0/+1,8%), 20o U_01/U_02/HIT_1 (−99/−83/−163; +1,7/+1,8/+4,4%), 41o H_02/DIR_1/LADDER_1 (hepsi çizim azalır; üçgen ≤ +%1,7).

## 6. Paftalar
`01…12_*.jpg` (solda ÖNCE, sağda SONRA, üstte anahtar; ≤ 300 KB). Ham satırlar: `ham_autotest.txt`.

## GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL
İp ve zemin işleri (41o/42b) ve 32o/20o alet-tezgâh ekleri gerçek ve ÖNCE'ye göre iyi; testler hep geçiyor, kural ihlali yok.
Çekirdek iddialar (tayfanın çalıştığı an, manto/ayak teması, su kabı, demet eli) görsel olarak tam kanıtlanamadı.

ZORUNLU düzeltmeler:
1. `docs/_kanit_p5/rapor.md` "Testler" bölümü: "ekranlı koşularda 41o ve 42b AUTOTEST FAIL, özgünde de aynı" ve "42b VISAUDIT özgünde 0/9" cümlelerini düzelt (ekranlı koşular PASS veriyor; VISAUDIT özgünde de 1/20, paketten gelmiyor).
2. `chapter32o.gd:_gun_hands` / `_battery_ground` (batarya evresi): D32O_U_END anında üçgen +%9,9 ve çizim +174 → bütçeyi aynı anda ÖNCE/SONRA tekrar ölç (rastgele duman dışlanarak); ≥ +%8 sürerse yamak/zemin ayrıntısını seyrelt. Beklenen: çizim artmaz, üçgen ≤ +%8.
3. `chapter42b`/`training_yard.gd`: düello dışı sabit bir kadrajda (ör. H_LADDER_1'deki ladder anı, kamera aynı) ÖNCE/SONRA RINFO'yu tekrarla; +%13,6 çıkıyorsa iskele/merdiven dekor birleştirme kapsamını genişlet.
4. Kanıtsız kalan 41o `_hold_pot`, 32o `_shoulder_grip`, `_gun_hands` (kepçe/manivela) için sondayla değil oynanış karesiyle (oyuncu bakışında) görünür kıl ya da raporda "KANITSIZ" kalsın ve "DÜZELDİ" deme.
