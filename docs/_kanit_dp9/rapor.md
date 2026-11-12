# P9 düzeltme turu — Blakhernai (30, 30o) — geliştirici raporu

Dal: `wip/duzeltme-p9`. Değişen oyun dosyaları yalnız: `scripts/chapter30.gd`, `scripts/chapter30o.gd`,
`scripts/level/blachernae.gd` (yalnız `_field_wear` ve yeni yardımcısı `_wear_bake`). `player.gd`, `stage.gd`,
`shadow_body.gd` vb. değişmedi.

**ÖNCE nasıl kuruldu.** Depo dışında bir kopya proje (`/home/user/once_proj`): `chapter30.gd` ve `chapter30o.gd`
`e551de84`'ten aynen; `blachernae.gd` için `e551de84` sürümü bugünkü ortak dosyalarla derlenmiyor (`shell_parts` yok),
bu yüzden bugünkü dosya alınıp yalnız `_ground` işlevi `e551de84`'teki hâline (altı ova levhası, ayrıntı yok) döndürüldü.
(`a5e8111d` = `e551de84` bu üç dosyada.) Depodaki dosyalara dokunulmadı.

**Kanıt türleri.** (a) Oyun koşusu: ekranlı `PACE=1 RINFO=1 … --autotest --hitchaudit --dialogshots --shotevery=1
--snapevery=0.5`, ÖNCE ve SONRA birer koşu; çiftler aynı replik karesi ya da aynı sıra numaralı anlık kare (`tNNNN`).
(b) Sonda (adı `sonda_`): `tests/_tmp/` altında geçici betikler (gitignore'da; depoya girmedi, oyun koduna kanca
konmadı). **Sondalar oynanışı değiştirir:** 30 sondası dört konumun hepsi sınansın diye bölüme iki merdiven daha ekler
(bot dört merdiveni iter); 30o sondası sur tarafı sınamasında oyuncuyu taşımanın sonunda verilen noktaya ışınlar.

## Madde madde (denetçinin ZORUNLU 1–10'u)

| # | Ne yapıldı (dosya:işlev) | Ölçüm / kare | Durum |
|---|---|---|---|
| 1 | Asıl neden: merdiven başı yürüyüş yolunun yalnız 0,1 m üstündeydi, 1,1 m'lik mazgal dişinin arkasında; hiçbir bakıştan görünmüyordu. `chapter30.gd`: merdiven boyu `LAD_H = WALK + 2,3` (baş dişin 0,6 m üstünde; eğim, ayak–sur uzaklığı, tırmanma süresi `CLIMB_TIME` aynı), `_pole_show`: bakış titremeyen merdiven ekseninde dişin üstündeki noktaya (AIM_Y), pitch −30…+10° sınırlı | sonda dört konum (ekranlı 1280×720, itişin ortası): baş (648–650, 313–316) px, hepsi orta üçte birde, baş 9/9 örnekte örtülmüyor. ÖNCE: baş y = 902 (ekran dışı), x = −12/−4/6'da 0/9 görünür. `pafta_01`, `pafta_02a/b` | DÜZELDİ |
| 2 | `_pole_show`: el noktası kameradan dikmeye giden ışın üstünde 0,62 m derinlikte (Player kutusunun içi); avucun el düğümünden kayması elin dönüş modeliyle düşülür (`_palm_target`); oyuncunun eli hedefi bir kare geç uyguladığı ölçüldü (Player._process bölüm döngüsünden önce) → dikme bir sonraki karenin bakışıyla izdüşürülür | sonda, avuç ortası–dikme noktası: sol 4–8 px, sağ 13–17 px (ekranlı); başsız 2–7 px. Dikme noktası 2/2 dişin üstünde görünür (taşın içinde değil) | DÜZELDİ |
| 3 | `_pole_show`/`_look_back`: itiş başında bakış (yaw, pitch) saklanır, bırakınca 0,3 sn yumuşak (sine) geri; merdiven ovadayken E basılırsa bakış hiç çevrilmez ve geri de çekilmez | sonda: bırakınca pitch −1,0° → −9,1° (itiş öncesi) 0,55 sn içinde, 4/4 itiş. Oyun koşusu `D30_D_DUEL_STAY` ÖNCE ile aynı bakış: `pafta_03` | DÜZELDİ |
| 4 | `_pole_show`: `rotation.x` yalnız `stage == "climb"` ve `state == "up"` merdivende yazılır/sıfırlanır; ovadaki merdivende eller önündeki taşa dayanır, bakış ve merdiven dokunulmaz | sonda (taşınan merdivenin yanında E, 5 kare): `rotation.x` min = max = sonra = 1,850 | DÜZELDİ (kare yok, sayı) |
| 5 | Titreme 0,012 → 0,0014 rad (yalnız tırmanılan merdivende); bakış titremeyen eksenden hesaplanır | sonda: merdiven başı ekran sarsıntısı ±0,5…±1,6 px; kamera pitch'i itişin ikinci yarısında 0,05–0,08° değişiyor (yaklaşma, sarsıntı değil) | DÜZELDİ |
| 6 | `blachernae.gd:_field_wear`: 146 bin → 52 bin üçgen (çakıl/taş/ok/çamur seyreltildi, iz şeritleri 6 → 4 merdiven yerine, sur dibine yakın; 30o açılışına küçük çiğnenmiş alan); x boyunca 5 parça (sert 3, yumuşak 2), her biri görüş konisiyle ayıklanır, `visibility_range_end = 80` | aşağıdaki RINFO tabloları + kesin pay ölçümü | DÜZELDİ (bir RINFO örneği gürültülü, aşağıda) |
| 7 | 30o başlangıç yerinin önüne (oyuncunun gördüğü 4–14 m bandı) saflardan gelen iz şeritleri, çakıl, çamur; izler/çamur zeminden koyu, çakıl açık | `pafta_07`: D30O_N_01 oyun koşusu ÖNCE | SONRA + aynı bakışta 1280 px kırpım: SONRA'da Zağanos'un önünde koyu iz dizisi ve açık çakıl benekleri; soldaki iri beyaz taş ÖNCE'de de var (bana ait değil) | DÜZELDİ |
| 8 | `chapter30o.gd:_carry_ladder/_carry_grip/_carry_pts`: yandaki iki asker merdivenin iki yanında, **yüzü dikmesine dönük** (sura dönükken uzak kol dikmeye yetişmiyordu: ölçülen kol açığı 0,18–0,21 m); arkadaki yüzü sura, basamakta. Ayak oturtma tutuştan (gövde eğiminden) sonra işler. Askerler yerlerine kendi şeritlerinden (merdiven ekseninden 1,9 m) koşar adımla yürür; merdiven kolun yetişeceği yere inmeden tutmazlar | sonda (5 başlangıç), sabit duruşta gerçek avuç (dirsek + el ofseti)–hedef: ≤ 0,049 m; taban–zemin 0,000 m; askerler arası en az 0,94 m (sonda yolu boyunca sürekli). `pafta_08`, `pafta_09` | DÜZELDİ |
| 9 | `_carry_ladder`: oyuncu arkadan (ovadan) geldiyse düz geri (merdiven + 3,6 m); yandan ya da sur tarafından geldiyse adaylar arasından askerlerin duracağı yerlere ve merdiven ayağına en geniş açıklığı bırakan yol (`_path_clear`): önce yana/sur tarafına, sonra yanda geri | sonda, oyuncu–asker (iki örnek arası doğrusal, sürekli): arkadan 1,90 m; (9,4; 6,4) 1,74; (10,8; 6,6) 0,73*; (12,0; 8,2) 1,44; (8,6; 9,0) 1,74. *Oyuncu merdiven ayağının 0,75 m yanında başlıyor; en yakın değer başlangıçta | DÜZELDİ (sur tarafı da sınandı) |
| 10 | Rapor dürüstlüğü: aşağıda "oynanış değişiklikleri" ve `docs/_kanit_p9/rapor.md` sonuna düzeltme notu | — | YAPILDI |

### Oynanış değişiklikleri (betikle oyuncu ve dünya)
- 30: E basılıyken bakış merdiven başına çekilir (yumuşak, 5/sn), bırakınca 0,3 sn'de itişten önceki bakışa döner.
  Denetim: E basılıyken fare bakışı ezilir (ÖNCE'de de öyleydi). Merdivenler 1,7 m uzun (görünüş ve tırmananın hızı:
  aynı 11 sn'de 13,2 m yerine 15 m çıkılır). Kazanma/kaybetme, süre, sayaç değişmedi.
- 30o: kaldırma sırasında oyuncunun konumu ve bakışı betikle değişir: 0,9–1,6 sn, 1,5–7 m (sur tarafından gelince en
  uzun), sine yumuşak; ÖNCE'de oyuncu yerinde, merdivene sırtı dönük duruyordu (`pafta_08` sol). Askerlerin yürüyüşü
  0,6 sn'den (11 m/sn'ye varan kayma) 4,5 m/sn koşar adıma çıktı; en uzak asker yerine 1,5–2 sn'de varır (1,3 + 1,2 sn
  bekleme süresi değişmedi).

## RINFO (ekranlı, `--hitchaudit`; her `PACE say key=` satırından sonraki ilk üç RINFO)

| An | Örnek | Çizim ÖNCE→SONRA | Üçgen ÖNCE→SONRA | Δ üçgen |
|---|---|---|---|---|
| 30 `D30_D_LADDERS` | 0/1/2 | 4724→4731 · 4989→5006 · 4771→4825 | 6609k→6669k · 6738k→6776k · 6626k→6668k | +0,9 / +0,6 / +0,6 % |
| 30 `D30_T_EMPEROR` | 0/1/2 | 1967→1950 · 2055→1927 · 1762→2039 | 1365k→1396k · 1361k→1389k · 1347k→1397k | +2,3 / +2,1 / +3,7 % |
| 30 `D30_N_END` | 0/1/2 | 2055→2039 · 1762→1737 · 1780→1766 | 1361k→1397k · 1347k→1381k · 1361k→1406k | +2,6 / +2,5 / +3,3 % |
| 30o `D30O_N_01` | 0/1/2 | 2049→2039 · 1970→1844 · 2177→2436 | 2783k→2748k · 2750k→2922k · 2978k→3189k | −1,3 / +6,3 / +7,1 % |
| 30o `D30O_Z_URBAN` | 0/1/2 | 1970→1844 · 2177→2436 · 2942→3365 | 2750k→2922k · 2978k→3189k · 3581k→3990k | +6,3 / +7,1 / **+11,4 %** |
| 30o `D30O_T_TOWER_WON` | 0/1/2 | 3403→3003 · 3472→3404 · 3655→3595 | 2621k→2137k · 2689k→2686k · 2624k→2632k | −18,5 / −0,1 / +0,3 % |
| 30o `D30O_T_EMPEROR` | 0/1/2 | 3520→3643 · 3863→3742 · 3969→3992 | 2671k→2667k · 2979k→2972k · 3099k→3228k | −0,1 / −0,2 / +4,2 % |
| 30o `D30O_N_END` | 0/1/2 | 5084→5317 · 5109→5074 · 5098→5101 | 4569k→4475k · 4609k→4471k · 4493k→4460k | −2,1 / −3,0 / −0,7 % |

İki koşunun RINFO'su 2 sn'lik oyun zamanında farklı karelere düşüyor (kalabalık, kamera). `Z_URBAN` örnek 2'de (+%11,4)
ve `N_01`/`Z_URBAN` çiziminde −126…+423 fark var; beş ova parçası en çok 5 çizim ekleyebilir, yani bu fark ova
ayrıntısından gelemez. Bunu ayırmak için **aynı koşuda aynı anda ölçüm** (sonda `prinfo`): ova parçaları açık/kapalı
ardışık kareler ve görüş konisine giren parçaların kesin üçgen toplamı (parça ya tümüyle çizilir ya hiç):

| An | Görüşteki parça | Kesin pay (üçgen) | Aç/kapa ardışık kare farkı (3 tekrar) |
|---|---|---|---|
| 30 `D30_D_LADDERS` / itiş | 5/5 | 52.156 = %0,8 | −0,95 / +0,05 / +0,62 % · itiş +3,5 / +0,4 / +1,5 % |
| 30 `D30_T_EMPEROR` | 3/5 | 30.028 = %2,2 | +2,8 / +1,7 / +2,1 % |
| 30 `D30_N_END` | 3/5 | 30.028 = %2,3 | +0,6 / +5,1 / +3,7 % |
| 30o `D30O_N_01` | 4/5 | 49.384 = %1,9 | +5,5 / −0,4 / −2,1 % |
| 30o `D30O_Z_URBAN` | 4/5 | 49.384 = %1,7 | +4,8 / −9,8 / +5,4 % |
| 30o `D30O_T_TOWER_WON` | 3/5 | 30.028 = %1,4 | +2,1 / +1,8 / +1,7 % |

Çizim: ova parçaları görüşte en çok 5 çizim ekler; ÖNCE'deki altı ova levhası bire indi (−5). Aç/kapa farkı +0…+21
(kalabalık gürültüsü dahil). Sonuç: ova ayrıntısının payı her ölçülen anda ≤ %2,3; ham RINFO'daki tek +%8 üstü örnek
gürültü (yukarıdaki gerekçe). Bunu kesin değil "ölçüm yöntemi farkı" olarak not ediyorum.

## Testler (başsız, `--max-fps 20`, son kod)
- 30: `""`, `lose`, `bridge_ok`, `bridge_bad` → **4/4 PASS** (son 30 değişikliğinden sonra yeniden koşuldu).
- 30o: `""`, `lose`, `sprint`, `stonehit` → **4/4 PASS** (30o ve blachernae son hâli).
- 24 (5), 25 (7), 26 (14), 31o (4) → **30/30 PASS** (Blachernae yalnız 30/30o'da kullanılıyor).
- Yasaklı satırlar (`SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`,
  `ARMAUDIT`, `HELDAUDIT`, `LOOKAUDIT backturn`, `JOURNEY_*`): **hiçbirinde yok** (30o `lose` dahil). `parse_check` PASS (248).
- Ekranlı: 30 ÖNCE/SONRA PASS; 30o ÖNCE PASS; 30o SONRA resmi koşu oturum yeniden başlarken son replikte
  (`D30O_N_END`) kesildi, AUTOTEST satırı yazılamadı (karelerin ve RINFO'nun hepsi alınmıştı); aynı kodla iki ayrı
  ekranlı 30o koşusu (prinfo, sonda) PASS.

## Gölge gövdesi (dosyaya dokunulmadı)
- 30o taşıma (`pafta_10`): yerde tek insan gölgesi, kolu taşınan merdivenin gölgesine uzanıyor; çifte gölge yok.
- 30 itiş: gece, sur taşının üstünde oyuncu gölgesi karelerde seçilmiyor → kolların ellere uzanıp uzanmadığı **KANITSIZ**.

## Ortak dosya önerileri
- `Player._hold_both_tick` hedefi bir kare geç uyguluyor (bölüm döngüsü `process_frame`'de, oyuncu `_process`'i
  önce işliyor gibi). Bölümler bunu bilmeden hedef verirse bakış dönerken eller kayar. Öneri: hedef `target` düğümüne
  bağlıyken noktayı tick anında okumak zaten yapılıyor; kamera yerelindeki hedefler için `hold_both`'a "dünya noktası +
  derinlik" biçimi:
  ```gdscript
  func hold_both_ray(left_w: Vector3, right_w: Vector3, depth := 0.62) -> void:   # tick anında kamerayla izdüşür
  	_both_ray = [left_w, right_w, depth]
  ```
- `_hold_both_points` kutusu (y ≤ 0,05, z ≥ −0,75): bu turda kutunun içine düşen noktalar seçildi; değişiklik gerekmedi.

## Bakamadıklarım / açık
- 30o yan kamerada askerlerin avuçları: `sonda_p30o_capraz` paftası raporla aynı kayıtta değilse (koşu sürüyordu)
  bir sonraki kayıtta eklenir; sayısal ölçüm yukarıda.
- 30o `lose/sprint/stonehit` ekranlı koşu: BAKILMADI (başsız PASS).
- Gerçek fare/klavye ile itiş: BAKILMADI (bot ve sonda).

## Paftalar
`pafta_01` (30 itiş, oyun) · `pafta_02a/b` (sonda, dört konum) · `pafta_03` (itiş sonrası bakış, DUEL_STAY) ·
`pafta_06a/06b` (bütçe anlarının görünüşü) · `pafta_07` (30o N_01 ova) · `pafta_08` (30o kaldırma, oyun) ·
`pafta_09` (sonda, 30o kaldırma çapraz kamera) · `pafta_10` (gölge, taşıma).
