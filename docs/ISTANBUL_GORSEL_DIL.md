# İstanbul v2 — Görsel Dil (BİRLİK)

Sahibinin sözü: *"duvarın görselliğiyle çadırların görselliği başka oyunlardanmış gibi."*
Bu belge İstanbul v2'nin bütün parçalarının (sur, ordugâh, çadır, zemin, bitki, insan, eşya) **tek oyunun parçası**
gibi görünmesi için ortak kuralı koyar. Kural kodda tek yerde yaşar: `scripts/world/ist/gorsel_dil.gd`
(class_name yok; `const GD := preload("res://scripts/world/ist/gorsel_dil.gd")`).

Ölçü: oyunun **yayındaki** bölümleri (Bölüm 24 şehir sokağı, 9 ordugâh, 8 / 8y sur dibi, 4 zincir kulesi, 12b).
Ölçüm aracı: `tests/_ist/birlik_ref.tscn` (yayındaki bölüm, oyuncu kamerası) ve `tests/_ist/birlik_kare.tscn` (v2) →
her kare için kategori kimlik karesi (`tests/_ist/birlik_id.gd`) → `tests/_ist/birlik_olc.py`.

## 1. Teşhis: aynı karede üç çizim dili

| | Sur | Çadır | Zemin |
|---|---|---|---|
| Doku | yordamsal taş, blok blok SERT ton farkı (±%12, keskin kenarlı) → "piksel/dama" | YOK (düz boya) | yumuşak, bulanık, ayrıntısız |
| Renk | soluk-kirli kireçtaşı | doygun açık mavi / bembeyaz / kırmızı | yeşil halı |
| Gölgeleme | toon | IstHayat: lambert (toon değil); ordugâh: toon | lambert |
| Uzak katman | aynı | **beyaza patlıyor** (uzak pişmiş ağ: yakın malzemenin 0,78 renk çarpanı yok, köşe rengi sRGB) | — |

Üç ayrı çadır sistemi: ordugâhın yakın kumaş çadırları (`ordugah_cadir.gd`, köşe renkli, toon), ordugâhın uzak
pişmiş hücre ağı (`ordugah_yonetici.gd _uzak_mat`), `IstHayat` katmanının kutu gövdeli çadırları (`hayat_mesh.gd
cadir()`: kare kutu + piramit; örnek rengi beyaz / kırmızı / sarı / **mavi**; lambert; sur dibinde ve hendek
kenarında da çıkıyordu). Işık: v2 göğünün "yer" yarısı mavi-gri (b8c4c8 / 5a6a70), yayındakiler sıcak toprak
(cfc4aa / 7a6a50): ortam ışığı v2'yi gölgede soğuk-mavi gösteriyordu.

## 2. Ölçüm tablosu (referans | v2 ÖNCE | v2 SONRA)

Bkz. `docs/_kanit_ist2_birlik/olcum.md` (tam tablo, kare kare JSON). Özet bu bölüme işlenir.

## 3. Palet (28 adlı renk, sRGB)

| grup | ad | renk |
|---|---|---|
| taş (5) | tas_kirec, tas_kirec_koyu, tas_gri, tas_kumtasi, tas_harc | b2a58b, 8b806c, 878277, b09670, c2b79f |
| sıva (3) | siva_kirec, siva_asi, siva_gul | cbbea4, b99467, b48c7a |
| kiremit (2) | kiremit, kiremit_koyu | 9a5a44, 764434 |
| ahşap (3) | ahsap_acik, ahsap, ahsap_koyu | 9a7b58, 76593d, 52402d |
| toprak (4) | toprak, toprak_kuru, camur, cakil | 8a7358, a6926e, 5c4b3a, 938876 |
| ot (3) | ot, ot_koyu, ot_kuru | 7b8653, 5a683f, a19865 |
| kumaş (6) | keten, devetuyu, boz · kokboya, civit, cehri | d3c9b1, b39a75, 8b8070 · 8f4434, 4d5b74, b29c58 |
| metal (2) | demir, bakir | 4d4b48, 946543 |

Kullanım: `GD.renk("keten")`; yeni malzeme: `GD.malzeme("kumas", "keten", vc)`.

## 4. Kategori kuralı

Doygunluk ve parlaklık sRGB HSV'de, malzemenin **taban rengi** (albedo × köşe rengi × örnek rengi × doku) üstünde,
gölgelendiricide sıkıştırılır (renk palete çekilmez, yalnız tavana).

| kategori | doygunluk tavanı | parlaklık | ayrıntı dokusu | döşeme | 10 m'de öğe | kir (dip) | güneş solması (üst) |
|---|---|---|---|---|---|---|---|
| taş | 0,30 | 0,22–0,82 | taş yumrusu | 2,4 m | ~0,45 m ≈ 23 px | — | 0,08 |
| sıva | 0,34 | 0,25–0,84 | leke + seyrek çatlak | 3,2 m | ~0,8 m ≈ 41 px | — | 0,08 |
| kiremit | 0,50 | 0,20–0,70 | taş yumrusu | 1,6 m | ~0,3 m ≈ 15 px | — | 0,10 |
| ahşap | 0,46 | 0,12–0,70 | tahta + lif | 1,6 m | 0,2 m ≈ 10 px | 0,25 / 0,5 m | 0,12 |
| zemin | 0,36 | 0,16–0,74 | toprak lekesi + çakıl | 3,6 m | ~0,6 m ≈ 31 px | — | — |
| bitki | 0,44 | 0,10–0,70 | ot lekesi | 2,8 m | ~0,5 m ≈ 26 px | — | 0,06 |
| kumaş | 0,50 | 0,18–0,84 | dikiş (0,6 m) + atkı + ince dokuma | 1,2 m | 0,6 m ≈ 31 px | 0,55 / 0,6 m | 0,16 |
| kişi/canlı | 0,52 | 0,08–0,84 | ince dokuma | 0,9 m | ~0,45 m | — | — |
| metal | 0,36 | 0,10–0,66 | taş yumrusu (ince) | 0,8 m | ~0,15 m | — | — |
| yapı (pişmiş karışık) | 0,42 | 0,12–0,84 | sıva | 3,2 m | ~0,8 m | — | 0,06 |

(10 m'de 1 m ≈ 51 px: 720 satır, dikey görüş 70°.) Ayrıntı 25–70 m arasında söner, ötesinde düz renk (mip de
ortalamaya iner): **uzakta gürültü yok**. Desenli dokuların (Props `ashlar`, `wood` …) karşıtlığı kendi ortalamasına
doğru kategori çarpanıyla iner (taş 0,62, ahşap 0,75 …). Filtre tek tip: doğrusal + mip + anizotropik.

Gölgeleme: yayındaki `Props.mat` ile aynı — toon dağınık ışık + toon parlama, pürüz 0,9, parlama 0,2, kenar ışığı
0,2 / tonu 0,6; dış çizgi kaynağınki (ters kabuk, `Props._outline_mat`). Kişi ve kumaş lambert idiyse toon'a geçer.
Zemin ve ot lambert kalır (yayındaki zemin de lambert).

## 5. Yıpranma kuralı

* **Kir aşağıda:** model uzayında y = 0 zemin olan ağlarda (çadır, ahşap eşya) dipten `kir_h` yüksekliğe çamur
  (`camur`) karışır (karesel sönüm).
* **Güneş solması yukarıda:** yukarı bakan yüzler (çadır tepesi, çatı, sur harpuştası) %55 doygunluğa ve biraz açığa.
* Sur taşının kendi yağmur akıntısı / dipte koyulaşma / yosunu (sur_doku.gd) korunur.

## 6. Yasaklar

1. Düz, doygun, tek renk büyük yüzey (> 4 m², dokusuz ve ayrıntısız).
2. Saf beyaz (V > 0,95, S < 0,06). Bütün tavanlar ≤ 0,84.
3. Saf siyah (her kategoride V ≥ 0,08 taban).
4. Açık camgöbeği / bebek mavisi kumaş; bütün çadır düz mavi ya da düz kırmızı (padişah otağı hariç: kök boya).
   Boya (kök boya, çivit, cehri) yalnız şerit, etek, saçak, alem gibi küçük alanlarda.
5. Fosforlu yeşil (ot tavanı 0,44 doygunluk, 0,70 parlaklık).
6. Kutu: canlılar ve yuvarlak nesneler kutudan yapılmaz (kalite notu 32).

## 7. Yakın / orta / uzak aynı renk

Aynı nesnenin yakın (lod 0), orta (lod 1) ve uzak (pişmiş hücre ağı, MultiMesh) katmanı AYNI kategori kuralından
geçer; uzak pişmiş ağ yakın malzemenin renk çarpanını ve köşe rengi uzayını kullanır (ordugâh: 0,78 / 0,76 / 0,72,
doğrusal köşe rengi). Uzaklaşınca beyaza patlama ya da kararma yok.

## 8. Çadır dili

Ağartılmamış keten / keçe tonları (keten, devetüyü, boz) gövdede; dönem boyaları (kök boya kırmızısı, soluk çivit
laciverdi, soluk cehri sarısı) yalnız şerit/etek/saçak/alemde. Dokuma dokusu, 0,6 m'de bir dikiş hattı, etekte
çamur, tepede güneş solması. Sur dibindeki 12 m'lik kuşakta ve hendekte çadır/sancak yok (OTURTMA kuşak maskesi).
IstHayat'ın kutu gövdeli çadırı yuvarlak alaçıkla (on dilimli hafif eğik duvar, konik çatı, kök boya saçak, alem)
değiştirildi.

## 9. Işık ve hava

Gündüz: gök "yer" yarısı cfc4aa / 7a6a50, ortam ışığı 0,52, güneş ffe9c7 × 1,25 (yayındaki ordugâh gündüzü
`camp_day.gd` ile aynı kaynak); bölüm havası `Look.apply_env` ("ottoman") her iki tarafta aynı. Gece: v2'nin gece
ayarı.

## 10. Uygulama

* Uyum geçişi: `GD.kur(dunya)` (IstDunya.build sonunda tek satır kanca). İlk karede bütün ağaç; sonra `node_added`
  ile akışla eklenen her geometri bir kare sonra (kurucusu malzemeyi atasın, sur taşı/pişirme bitsin) kurala çekilir.
* Önbellek: aynı kaynak malzeme + kategori + kir → aynı uyumlu malzeme. Tek yüzeyli MultiMesh'te `material_override`,
  MeshInstance'ta yüzey üstüne yazma (ağ kaynağı değişmez: yayındaki bölümlerle paylaşılan ağlar etkilenmez), çok
  yüzeyli MultiMesh'te ağın uyumlu kopyası. Çizim çağrısı artmaz.
* Var olan gölgelendiriciler kopyalanıp sona aynı işlem eklenir (`enjekte`); v2'ye ait malzemelerde (sur taşı, v2
  zemini, insan, bez) kopya gölgelendirici yerinde takılır (sonradan gelen parametre güncellemeleri kaybolmaz).
* Denetim: `tests/_ist/birlik_denetim.tscn`, son satır
  `BIRLIK malzeme=<n> kategorisiz=<n> doygunluk_asan=<n> duz_buyuk_yuzey=<n> saf_beyaz=<n>`.
