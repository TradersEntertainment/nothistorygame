# İstanbul v2 — ŞEHİR ÇATI ROTASI: rapor

Dal `wip/ist2-cati` (taban `wip/ist2-birlesik`). Kural belgesi: `docs/ISTANBUL_CATI.md`. Kod: `scripts/world/ist/cati.gd`
(yeni, `IstCati`), `evler.gd` (`~dam` eki, `c_*` parça tipleri), `sokak.gd` (build sonunda `IstCati.uygula`), `sehir.gd`
içinde yalnız `_sehir_dokusu_v2` (parçaları katmanlara ekler; çakışan ağaç/doku/meydan kuyusu kurulmaz, rng sırası aynı).
Sondalar: `tests/_ist/cati_hareket.tscn` (hareket), `tests/_ist/cati_sehir.tscn` (envanter/harita/doluluk/bot/kareler).

## Durum özeti

| iş | durum | not |
|---|---|---|
| 1. Hareket ölçümü (iki kip) | **TAMAM** (AÇIK kipte eğim/duvar KISMEN) | `hareket_olcum.txt`; AÇIK kipte eğim ve duvar bölümü zaman aşımına kaldı (eğim `floor_max_angle` kip bağımsız) |
| 1. Mahalle çatı envanteri | **TAMAM** | `cati_envanter_ONCE.md` (94 ev), `harita_ONCE.png`, `dolu_ONCE.png` (ışın doluluğu) |
| 1. Bot ÖNCE | **TAMAM** | 3 rota, iki kip: 0/3 (sokaktan dama çıkış yok) |
| 2. Kural belgesi | **TAMAM** | `docs/ISTANBUL_CATI.md` + "hareket şunu yapabilseydi" listesi |
| 3. Mahallede çatı rotası | **KISMEN** | 3 rota yere inmeden, takılma/düşme/sıkışma 0 (iki kip). Ama R1 ve R3 kısa (aşağıda neden) ve kalas köprü 1 tane |
| Hub pastel ev kümesi | teşhis **TAMAM**, dokunulmadı | aşağıda |
| Bütçe ≤ +%5 | **TAMAM** (en çok +%4,9) | `butce.md`; ölçüm gürültüsü notu orada |
| Testler | **TAMAM** | `testler.txt`: 12 bölüm PASS, denetim 0; parse PASS; sur sözleşmesi aynı |

## 1. Ölçüm

### Hareket (gerçek Player; `hareket_olcum.txt`)

| ölçü | KAPALI | AÇIK |
|---|---|---|
| zıplama tepesi | 0,68 m | 0,68 m |
| yürüyerek basamak | 0,48 m | 0,48 m |
| koşup zıplayarak çıkılan kenar | 0,75 m | 2,55 m |
| düz zeminde koşu atlaması | 4,2 m | 5,9 m |
| yürüyüş atlaması | 2,6 m | 2,6 m |
| aşağı atlama dh 1,0 / 2,4 / 3,4 / 5,8 | 5,2 / 6,1 / 6,7 / 7,9 m | 6,7 / 7,3 / 7,9 / 8,2 m |
| yukarı atlama dh 0,3 / 0,5 / 0,6 | 3,8 / 3,4 / 3,1 m | 4,9 / 4,9 / — |
| durulan / yürünerek çıkılan eğim | 44° / 44° (`floor_max_angle` 45°) | (aynı fizik; ölçüm zaman aşımında) |
| koşup zıplayarak duvara çıkış | 0,70 m | (≈ 2,55 m, kenar ölçümüyle aynı) |
| düşme cezası | yok | 4,0 m üstü sendeleme (`Traversal.STAGGER_FALL`) |

Tahminle karşılaştırma: zıplama tepesi 0,68 (tahmin 0,66); düz atlama 4,2 (tahmin 3,8 — kapsül yarıçapı iki kenarda ~0,3 m kazandırıyor).

### Mahalle (ÖNCE)

- Zonda 94 ev (16 düz dam, 2 teras, 76 kiremit); **hepsi batıda/kuzeyde**. Ayasofya, Yerebatan ve Hipodrom arasında
  hiç ev yok: Ayasofya çevresi (r 70), meydan oyun alanı (55×50, 24/25/26/31o), Augustaion döşemesi, Milion, Hipodrom
  (194×60 m, yaw −35°), Zeuksippos, saray. Sokak genişlikleri: 15 m (Mese) 1, 6 m 5, 5 m 23, 4 m 3.
- Ayasofya önü (avlunun batı kapısı) ile Yerebatan girişi (dünya −70,6 / 19,4) arası ~20 m ve **tamamı meydan oyun alanı**.
- Hipodrom doğu dış duvarı yıkık ve basamaklı (2,8–3,7 m; aralarda 0,8–0,9 m sıçramalar): üstü yol olamaz.
- Hipodrom doğu yakasını 6 m'lik bir yol (lz −69…−47) ve 4 m'lik bir yan yol (lz −12…−23) kesiyor.

### Bot ÖNCE | SONRA (gerçek Player; hücre çarpışması yüklendikten ve arazi yaması `carpisma_yenile` ile yenilendikten sonra)

| rota | ÖNCE KAPALI | ÖNCE AÇIK | SONRA KAPALI | SONRA AÇIK |
|---|---|---|---|---|
| R1 Ayasofya önü → Yerebatan girişi | takıldı wp0 (çıkış yok) | takıldı wp0 | **tamam** 12/12 | **tamam** 12/12 |
| R2 Yerebatan → Hipodrom (KB ucu) | takıldı wp0 | takıldı wp1 | **tamam** 15/15 | **tamam** 15/15 |
| R3 Hipodrom doğu duvarı boyunca | takıldı wp0 | takıldı wp0 | **tamam** 16/16 | **tamam** 16/16 |
| toplam takılma / düşme / sıkışma / yüksüz hücre | 3 / 0 / 0 / 0 | 3 / 0 / 0 / 0 | **0 / 0 / 0 / 0** | **0 / 0 / 0 / 0** |

Çıktılar: `bot_ONCE_kapali.txt`, `bot_ONCE_acik.txt`, `bot_SONRA_kapali.txt`, `bot_SONRA_acik.txt`.
Bot kuralı: düşme = ilk damdan sonra son dam noktasına kadar zemine (arazi + 1 m altı) basmak; takılma = 8 sn ilerleme
yok; sıkışma = havada hızsız 0,6 sn. Bot diz hizası engelde zıplamaz (rotada 0,30'dan yüksek basamak yok), kenarda zıplar.

## 3. Uygulama

Rota haritası (üstten, sarı = küme evi, kırmızı = bot rotası, kahve = kalas): `rota_haritasi_SONRA.png`,
tam: `harita_SONRA.png`, doluluk: `dolu_SONRA.png`. Envanter: `cati_envanter_SONRA.md` (106 ev).

| öğe | adet | yer |
|---|---|---|
| yeni ev (`sira~dam`, düz dam, kitle aynı) | 12 | E (3, meydanın doğu kıyısı) · M1a (1) · M1b (2) · M2 (2, Milion'un batısı) · Ds (4, Hipodrom doğu duvarına sırtı dayalı) |
| dış taş merdiven (çıkış/iniş) | 5 | Ayasofya önü (E), Yerebatan girişi (M1a–M1b geçidi), Hipodrom KB ucu (M2), Hipodrom doğu kuzey ve güney (Ds) |
| dam merdiveni | 1 | Ds2 (tek kat) → Ds1 (iki kat) |
| kalas köprü (ayaklı, halat korkuluklu) | 1 | E damı → M1a damı, meydan köşesi üstü (8,1 m) |
| bakış kulesi (köşk başlıklı) | 2 | M2 (Hipodrom + Ayasofya manzarası), Ds1 (Hipodrom pisti) |
| iniş (saman) | 2 | köprünün altı, Ds kuzey merdiveni yanı |

Rotalar: **R1** Ayasofya önü → E merdiveni → E damları → kalas → M1a → geçit merdiveniyle Yerebatan girişine (~45 m).
**R2** Yerebatan geçidi → M1b → M2 → kule (gidiş-dönüş) → Hipodrom KB merdiveni (~35 m). **R3** Ds kuzey merdiveni →
Ds3/Ds2 (tek kat) → dam merdiveni → Ds1 → kule → Ds0 → güney merdiveni (~21 m dam).

Bot sınamasında bulunup KÖK NEDENİ düzeltilenler: (1) dam döşemesinin 0,1 m saçağı merdivenin üstüne biniyordu →
merdiven duvardan 0,12 m açıkta + tepede sahanlık; (2) gerçek zemin `IstGeo.h`'ten ≤ 0,6 m alçak olabiliyor →
merdiven dibine üç ek basamak; (3) 0,30/0,32'lik dar kule merdiveninde `step_up` kapsül konumuna göre takılıyordu →
kule merdiveni 0,25/0,36, 1,6 m; (4) sondanın kendisi: ışınlama sonrası arazi çarpışma yaması eski (düzleme öncesi)
yükseklikte kalıyordu → bot `IstDunya.carpisma_yenile` çağırır (oyunun ışınlama yolu).

## Kareler (ÖNCE | SONRA, `kare/ONCE_*.jpg` · `kare/SONRA_*.jpg`; 1280×720, kalite 85)

Her SONRA karesi için tek cümle:

- **sokak1_meydan_gd**: meydanın güneydoğu köşesinden E sırası (solda dış merdiven) ve M1a; evler kitin taş-tuğla/sıva dilinde, zemine oturuyor, kutu ya da havada nesne yok; meydanın çınarı E'nin önünde (meydan kitinin, eski).
- **sokak2_yerebatan**: M1a ile M1b arasındaki geçit merdiveni (Yerebatan girişi) ve sol üstte kalas; aynı ressamın elinden, havada nesne yok; kalasın ince çizgisi uzaktan zor seçiliyor (zayıf).
- **sokak3_milion**: M2'nin cephesi; evler zemine oturuyor; önündeki iki amfora yere sivri ucuyla değiyor (eski ayrıntı, bu işin değil) — dikkat çekiyor.
- **sokak4_hip_kuzey**: Ds sırası, kuzey dış merdiven (basamaklı taş kütle), damda köşk başlıklı bakış kulesi, önde saman; kule artık kutu gibi değil (kiremit başlık dikmelere oturuyor); **saman ışıkta hâlâ fazla sarı (kötü)**.
- **sokak5_hip_orta**: Ds cephesine çok yakından (ahşap çıkma, eski sundurma, sandık); bilgi az, kamera iyi seçilmemiş (zayıf), havada nesne yok.
- **sokak6_hip_guney**: Ds'nin güney dış merdiveni ve cephesi, arkada Ayasofya; zemine oturuyor; dış merdivenin yan yüzü düz taş üçgen (evlerin eski dış merdiveniyle aynı dil).
- **cati1_e_sirasi**: E damından meydana bakış; düz dam döşemesi tek renk ve geniş (dokusuz, kötü sayılabilir: kitin `duz` damı böyle).
- **cati2_m1**: M1a damından batıya; kalasın ucu, halat korkuluk dikmeleri; dikmeler kalasa oturuyor; dam yüzeyi yine düz ve boş.
- **cati3_m2_bakis**: M2 kulesi yüksekliğinden Hipodrom; manzara açık; ön planda Hipodrom'un yeşil üstlü kuzey duvarı (eski).
- **cati4_d_kuzey**: Ds3 damından kuleye; 12 basamaklı kule merdiveni, köşk başlığı; zemine oturuyor; kule gövdesi tuğla şeritli kesme taş.
- **cati5_d_bakis**: kule tepesinden Hipodrom pisti ve dikilitaşlar; korkuluklar görünüyor; iyi manzara.
- **cati6_d_ayasofya**: Ds1 damından Ayasofya'ya; minare yok (Nisan 1453); damlar düz.
- **hava1_mahalle**: yüksekten mahalle; yeni evler meydan kıyısında açık renkli düz damlar olarak okunuyor, şehrin dokusu bozulmamış.
- **hava2_hipodrom**: Hipodrom ve Milion; Ds sırası doğu duvarına yaslı, M kümesi Milion'un yanında; uçuş görünüşü bozulmamış (43o PASS).

## Hâlâ kötü olanlar

- **R1 ve R3 kısa.** Ayasofya önü ile Yerebatan arası 20 m'lik meydan oyun alanı; ev konamadığı için R1 meydanın doğu ve
  güney kıyısını dolaşıyor. Hipodrom doğu yakasında kesintisiz yer yalnız lz −24…−45 (21 m); "Hipodrom boyunca"nın
  gerisi için doğu yakasını kesen 6 m'lik yolun yeniden çizilmesi gerekir (sokak üreteci; şehrin bütün o bölgesini değiştirir).
- **Kalas köprü 1 tane.** Kümeler bitişik yerleşti; ikinci sokak üstü köprü yok. Kemer/sabat (sokak üstü örtülü köprü) SONRAKİ iş.
- Düz dam yüzeyi geniş ve dokusuz (kitin `duz` damı); damlarda hayat (çamaşır, küp, çardak) yok — rotayı kesmeyecek biçimde eklenmeli.
- Saman yığını toon ışıkta fazla sarı.
- Ölçüm gürültüsü: kare başına çizim sayısı akışa göre ±%20 oynayabiliyor (`butce.md`).
- `evler.gd`'nin `duz` damındaki "saman/küp" kutusu (`Props.box`, çarpışmasız) eski evlerde duruyor: içinden geçiliyor (rota evlerinde kaldırıldı).
- Bölüm koşularından 11 tanesi kule başlığı ve saman rengi değişikliğinden önce koşuldu (43o ve parse sonra yeniden: PASS).

## Hub pastel ev kümesi (teşhis; DOKUNULMADI)

Kaynak `scripts/level/byz_city.gd` → `ByzCity._build_fill()` (hub `IstSehir._make_hub` bunu çağırır):
- Duvarlar: `plasters = [e8c890, d89a78, efe0c4, c8a0a0 (pembe), b8c4c0 (mavi-gri), e0b070, d8b89a]`, `_fill_mat(pm, "plaster")`
  = `Props.mat(renk, …, "plaster")`: renk `albedo_color`, desen dokusu çarpılır.
- Çatılar: yakındakiler `Kit.roof(...)` (köy kitinin kendi dokulu ağı, `toon`), uzaktakiler `roof_m = _fill_mat(fff0e8, "tiles")`:
  **turuncu, `tiles` dokusunun kendisinde**, `albedo_color` neredeyse beyaz. Kubbeler `b5533a`.
- `IstSehir._hub_palet` (TUR-6, kapalı) neden işe yaramadı: `_hub_renk` yalnız `albedo_color`'ı değiştiriyor; `fff0e8`
  doygunluğu 0,09 < 0,12 olduğundan hiç dokunulmuyor ve turuncu dokudan geliyor; `Kit.roof` ağlarının rengi de kitin
  dokusunda. Doğru düzeltme (sahibine istek): hub kopyasında çatıya v2 `P_KIREMIT` renginde ve `_dk` ile dokuya bölünmüş
  albedo ya da dokusuz malzeme; sıva paletinin pembe/mavi tonlarının `P_SIVA`'ya eşlenmesi.

## Bütçe

`butce.md`: 14 kamera, en büyük artış çizim +%4,9 (sokak5), ilkel +%3,8 (sokak1). Sınır +%5 içinde.

## Testler (`testler.txt`)

`tests/parse_check.tscn` PASS (356 betik). `grep -rln "IstDunya\|IstBaglama\|World1453" scripts/chapter*.gd` → 7, 8y, 11,
17o, 18, 18b, 31o, 38o, 43o; ayrıca 44b, 10h, 12b: 12'si de `AUTOTEST PASS`, tam süzgeçte denetim satırı 0.
`sur_sozlesme` → `SURSOZLESME PASS kalem=13 kesim=8`; `sur_oyun_denetim` → `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`;
`sur_oyun_yuru` → `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`.

## X'e istek

- **Hub sahibine** (`byz_city.gd` / `_make_hub`): yukarıdaki renk kaynağı.
- **Sokak üreteci için sonraki çatı turu**: Hipodrom doğu yakasını kesen 6 m'lik yolun Hipodrom duvarından 15 m açıktan
  geçmesi, "Hipodrom boyunca" rotası 21 m'den ~120 m'ye uzar.
- **Hareket (player)**: `docs/ISTANBUL_CATI.md` §9.
