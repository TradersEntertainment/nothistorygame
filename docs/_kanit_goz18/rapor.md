# G18 — Göz kontrolü bulguları: rapor

Dal `wip/goz18`, taban `b1531a7b`. Godot 4.4.1 (resmî linux x86_64). Testler çalışma ağacının eşlerinden koşuldu:
- `~/is/kopya`: taban kod, ÖNCE ölçümleri;
- `~/is/sonra`: dalın kodu, SONRA ölçümleri.

| # | Bulgu | Durum | Kısa |
|---|-------|-------|------|
| 1 | Hub kapı geçidinde toprak döşemenin üstünde | **KISMEN** | Arazi düzeldi: sondada +0,12 → −0,08, 8y ile aynı ölçü. Görünen "toprak yırtığı" arazi DEĞİL; setin kendi eteği (`SurDibiEtek`). Kökü `surlar.gd:634`, çarpışması dondurulmuş, dosya benim değil: **dokunulmadı**, karar sahibinde. |
| 2 | 18b pembe kutu bina | **TAMAM** | Eski dünyanın Blakherna Sarayı temsili (`landmarks1453.gd:638`). Dört cephede pencere, denizlik, iki kapı eklendi. |
| 3 | 25 pastel kutu evler | **TAMAM** (evler) / **KISMEN** (meydan) | `byz_city.gd` `_build_fill`: "aya" parçasında evlerin hepsi kutuydu. Artık hepsi tam model. Koyu meydan duruyor (aşağıda). |
| 4 | 36b hendek dibinde gri düzlemler | **YAPILMADI** (teşhis) | Teras yolundan görünmüyor. Hendeğin içinden (düşülebilir, merdivenli) görünüyor. Kaynak setin hendek ucu parçaları, dosya benim değil. |

---

## 1. Hub kapı geçidi

### Ölçüm (DÜZELTMELER 15): danışmanın sayısal zinciri tuttu

Geçici `print` ile ölçüldü (`baglama.gd`, `IstDunya.build` sonrası; kayıttan önce kaldırıldı):

```
10h: G18OLC bolge=byz_walls romanos_y=14.208 hub_y=14.088 ... fark=0.120
8y : G18OLC bolge=gate8y    romanos_y=14.008 hub_y=14.088 ... fark=-0.080
```

12b, 13, 23, 24, 6 ve 7'de (`cesit=byz`) de fark +0,120 (`testler/once/once_*.log`).

### Seçilen yol: DÜZELTMELER 3 (kaydı kaynağında düzelt)

**`scripts/world/ist/sur_oturtma.gd`**
- `:26` yeni `static var ic_y_ozel := {}` (öğe kimliği → v2 y). `temizle()` bu sözlüğü boşaltmaz.
- `:118-123` `kur` içinde: `dy_kayit`/`oturtma_dy` yazıldıktan sonra, sözlükteki öğe için `g.dy = g.y + g.dy − yeni_y; g.y = yeni_y`.
  - İç kayıtlar (şehir önü, iç kuşak) setin zeminine iner.
  - Dış kayıtların mutlak `y + dy`'si, `dy_kayit` ve `oturtma_dy` aynı kalır.

**`scripts/world/ist/baglama.gd`**
- `:360-362` `IstBaglama.build` başında sözlük her seferinde boşaltılır.
- Yalnız `region_name == "byz_walls" and SurHub.sahnede()` iken `{"romanos": xf.origin.y − 0.08}` yazılır. Bu, hub y 0'ın 8 cm altı; 8y'nin ölçüsüyle aynı.

**Neden bu yol:**
- Hub'ın yeri oynamıyor (madde 2).
- Ek ağ yenilemesi yok: kayıt `OTURTMA.kur`'dan önce oluşuyor, var olan `yenile(alan)` onu kullanıyor.
- Yama eşiği yolu (madde 5) yanlıştı.
- Kapsam kilidi: başka hiçbir bölge ya da yol sözlüğü dolduramaz.

### Sonda (geçit, `sonda=30,5.9,58,5.9`; 10h, 12b, 13, 23, 24, 6, 7 hepsi aynı)

| x | carp_y | arazi ÖNCE | arazi SONRA |
|---|--------|-----------|-------------|
| 30–34 | (aynı) | −0,12 | −0,12 |
| 36 | 12,12 (sur tepesi) | **+0,12** | **−0,08** |
| 38 | 0,13 (etek) | **+0,12** | **−0,08** |
| 40 | 0,12 (etek) | **+0,12** | **−0,08** |
| 42–52 | 0,00 | **+0,12** | **−0,08** |
| 54 | 8,62 (dış sur) | −3,43 | −3,43 |
| 56–58 | köprü rampası | −3,43 | −3,43 |

- `carp_y` sütunu bütün satırlarda önce|sonra aynı (çarpışma değişmedi).
- Ölçüt (madde 8): x 36–52'de arazi −0,08 ∈ [−0,30; −0,03] ✔. x < 34 ve x > 55,1'de önce|sonra aynı ✔.
- x = 54 dış sur gövdesinin içi (52,5–55,1). Orada arazi önce de −3,43'tü ve dış bant gövdenin içinde kesiliyor; görünmez, dokunulmadı.

**Peribolos boyunca** (`sonda=45,-26,45,37`; 10h, 12b, 13):
- z −26 … 30,9 arası +0,12 → −0,08.
- Kesimin ucunda (z 32,9 ve 35,0) arazi **−1,15 / −1,16**, önce de aynıydı. Komşu şehir diliminin kendi kaydı; setin 1,15 m altında, toprak döşemeyi delmiyor.
- Madde 7 gereği komşu sözlüğe eklenmedi.

**Kapalı yollar** (madde 6/14): 8y (`sonda=0,-14,0,30`), 31o (`sonda=0,-15.5,0,28.5`), 7 (=7a uzak hub), 11 ve 19'da sonda satırları ve `OTURTMA kur oge= duz= bant=` satırı önce|sonra **birebir aynı**.

### Asıl görünen kusur: setin eteği (dokunulmadı)

Arazi düzelince `bak=31,1.6,5.9,90` ve `bak=36,1.6,5.9,90` kareleri **değişmedi** (`kare/b1_10h_*`, `kare/b1_13_*`). Bu yüzden görünen ağ ayrıca arandı:
- `goz18_sonda` aracına `bul=` (noktayı kapsayan ağlar) ve `gizle=` (ağı gizleyip kare) eklendi.
- Geçitteki toprak: `SurHub/SurOyun_romanos/OyunDilimi/AzizRomanos/SurDibiEtek`. Gizleyince toprak da yarık da gidiyor (`kare/b1_10h_kapi_ici_TESHIS_etek_gizli.jpg`).
- Kurucusu `scripts/world/ist/sur_oturtma_ag.gd:461` `kur` → `yuz()`: sur dibi toprak eteği, 0,3–0,8 m'lik, duvardan 3–6 m'de sıfıra inen kabarık şerit.
- Çarpışması var: `SurDibiEtekGovde`. Sondada x 38–40'ta `carp_y` 0,12–0,13 bu eteğin üstü.

**Kök:**
- `scripts/world/ist/surlar.gd:634`: `var kp := [[-gw*0.5-0.6, gw*0.5+0.6]] if open_gate else []`.
- Romanos kesimi kapısı kapalı ("harap") kuruluyor; SurOyun kapıyı sonradan `kapi_parca`/`kapi_acik` ile açıyor.
- Sonuç: eteğin kapı kesiği boş kalıyor. Etek iç surun yüzleri boyunca kapı ağzını da geçiyor ve geçidin içine 0,35 m taşıyor.
- Ortadaki "mavimsi yarık", eteğin şeritlerinin kesildiği yerde altta kalan döşeme.

**Aynı görüntü 8y'de de var** (`kare/b1_8y_*_ayni_etek.jpg`). Yani hub'a özgü değil; kesimin kendisinde.

**Neden dokunmadım:**
- Düzeltme (`open_gate` yerine SurOyun'un açık kapısını `kp`'ye katmak) eteğin çarpışmasını (`SurDibiEtekGovde`) değiştirir. Kuralda "Sur ölçüleri ve ÇARPIŞMA DONDU".
- 8y'yi de değiştirir; 8y'nin değişmemesi istendi.
- `surlar.gd` ve `sur_oturtma_ag.gd` dosya sahipliğimde değil.

**Sahibine öneri:** SurOyun açık kapılı kurulumda `kes["kapi"]`'ye kapı aralığını versin. Görünüş ve çarpışma birlikte değişir; `sur_oyun_denetim` ve `sur_oyun_yuru` yeniden dondurulmalı.

### Madde 11 (kapı) ve 12 (yarık)

- Kapı açık (`byz_city.gd:1636`, `kapi_acik: true`). Oyuncu geçide ve peribolosa girebiliyor: geçitte ve peribolosta çarpışma var (sondada `carp_y` 0,00–0,13), `sur_oyun_yuru` yolları PASS.
- Yarık arazi düzeltmesinden sonra da sürüyor. Nedeni madde 12'deki aday değil (eksik döşeme); yukarıdaki etek. Döşeme yerinde, eteğin altında.

---

## 2. 18b: penceresiz pembe kutu

**Teşhis:**
- `bul=`/`gizle=` ile ikiye bölerek bulundu: `World1453.build` (eski dünya, `horn_bridge`) → `HornWorld` → tohumu 1453 olan `Dressing` (`Landmarks1453.build`).
- Simge döngüsü geçici bir `print`'le dökülünce `blachernae_palace` bölüm yerelinde **(−18; 1,55; 94)** çıktı. Oyuncunun başlangıcından ~35 m.

**Kök:** `scripts/world/landmarks1453.gd:638` `_blachernae_palace`.
- 26×16×14'lük tuğla kutu, üç açık renkli kat silmesi ("beyaz kat çizgileri").
- Pencereler yalnız +x ve +z cephesinde; kapı yok.
- 18b'nin sur yolundan görünen −z ve −x cepheleri tamamen kördü.

Uzak LOD ya da sadeleştirilmiş şehir bloğu değil; **eski dünyanın simge temsili**.

**Düzeltme (`landmarks1453.gd:643-669`):**
- Üç kat (2,6 / 7,6 / 13,0) pencere dört cephede; zemin katta küçük pencereler, hepsinin altında taş denizlik.
- −z ve −x cephelerinde birer ahşap kapı, taş lento.
- Kulenin önüne düşen pencere konmuyor.

**Kapsam:**
- Aynı kaynak eski dünyayı kuran bütün bölgelerde aynı (Blakherna yakınındaki Haliç bölümleri); düzeltme hepsine geçer.
- `Dressing.box` rastgele sayı tüketmiyor; komşu süs yerinden oynamaz.
- `landmarks1453.gd` sahiplik listemde yoktu ama kimseye de atanmamıştı (G17 dalı dokunmamış). Kök orada olduğu için en az değişiklikle oradan düzeltildi.

Kareler: `kare/b2_18b_{ileri,sol}_{once,sonra}.jpg`, `kare/sahip_1_18b_saray_pencereli.jpg`.

---

## 3. 25: pastel kutu evler, koyu meydan

**Görünüyor mu:** Evet. Ayin evresinde (`bekle=city`, ByzCity "aya" parçası) göz −47,9/1,6/−71,1'den dört yönde kutu evler ve meydan görünüyor. Aynı parça 24 (ikinci yarı), 26, 31o ve 44b'de de kullanılıyor.

**Kök:** `scripts/level/byz_city.gd:1154` (eski `:1147`) `_build_fill`. "Yakın ev" ölçüsü hub'ın ortasına, (0, −10)'dan 45 m'ye göreydi.
- "aya" parçasının (z < −40) evlerinin **hepsi** uzak sayılıyordu: penceresiz, kapısız tek parça sıvalı kutu (pastel palet).
- Hub'ın ("walls") köşelerindeki evler de aynı durumdaydı.

31o'nun bilinen "pastel kutu ev" notu ve `_kanit_ist2_cati`'daki "hub pastel küme" teşhisi aynı aileden.

**Düzeltme (`byz_city.gd:1132-1133`, `:1147-1176`):**
- Sahnedeki tek harita parçalarında ("walls", "aya") evlerin hepsi tam model: taş zemin kat, sıvalı üst kat, pencereli cephe, kapı, kiremit.
- Uzak hub (`far_hub`, sahne dışında pişirilir; `is_inside_tree()` yanlış) eskisi gibi.
- Ana sayı dizisi aynı kalsın diye ek evlerin kapı/kepenk seçimi ayrı diziden (`ek_rng`, tohum 1205). Evlerin yeri, boyu, rengi değişmez.
- Cephe süsü (`face_dress`, kendi dizisi) daha çok cephe kurduğu için öteki evlerin pencere/kepenk ayrıntısı biraz değişebilir; yalnız görünüş, çarpışmasız.
- Ek evlere `wall` metası konmadı; sokak dolgusunun eşya dağılımı aynı.

**Hâlâ duran:** "koyu boş meydan".
- Parçanın zemin levhası (`_fbox` "concrete", `byz_city.gd:1129`) gün batımı ışığında koyu mor okunuyor; boş alan Ayasofya meydanının batısı.
- Kutu değil, havada değil; bu turda dokunulmadı.

Kareler: `kare/b3_25_yon{0..3}_{once,sonra}.jpg`, `kare/sahip_2_*`, `kare/sahip_3_*`.

---

## 4. 36b: hendek dibinde gri düzlemler (aday, düşük)

**Kareler:**
- `kare/b4_36b_yonetici_gozu.jpg`: göz −37,2/−7,9/30,0. Kesimin ucunda, teras/ova zemininin (−3,56) 4 m altında.
- `kare/b4_36b_terastan_uca.jpg`: terastan uca bakış.
- `kare/b4_36b_hendek_ici_uca.jpg`: hendeğin içinden uca bakış.

**Sonuç:**
- Teras yolundan (sur dibi patikası) **görünmüyor**.
- Hendeğin içinden açık gri, düz kama/levhalar **görünüyor**. Oyuncu hendeğe düşebiliyor ve merdivenle çıkıyor (`chapter36b.gd:161-170`), yani erişilebilir.
- Aday kaynak: setin hendek ucu / hendek rampası parçaları (`sur_zemin.gd:748` "hendek rampası", SurSetSahne kesim ucu). Çarpışmalı set parçası ve dosya benim değil: **dokunulmadı**.
- Bölüm dosyası (`chapter36b.gd`) değişmedi.

---

## Doğrulama (`testler/`)

**Sözleşme altılısı (sonra)**, `sozlesme_ve_denetim_sonra.txt`:
- `SURSOZLESME PASS kalem=13 kesim=8`
- `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`
- `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`
- `ESYATEST PASS`
- `HALICSONDA OZET carp=661 karma=3854034809`
- `MARMARASONDA OZET carp=1837 karma=2250736444`

**Öteki testler:**
- `PARSECHECK PASS scripts=369`. `STREETCHECK PASS`. `CITYCHECK PASS`.
- **CITYCHECK µs** (tek başına, sırayla koşuldu; `citycheck_once_sonra.txt`), en kötü nokta ortalaması:
  - 24: 882 → 815;
  - 31o: 956 → 997. Gürültü içinde. 3 paralel süreçle koşulan ilk sonra ölçümü 1149'du; adil değil, tekrarlandı.
- **Açılış** (`ISTBAGLAMA kurulum_ms`, `acilis_once_sonra.txt`), önce → sonra:

| 10h | 12b | 13 | 23 | 24 | 6 | 7 |
|-----|-----|----|----|----|---|---|
| 950 → 1000 | 990 → 1064 | 1022 → 1126 | 1046 → 1099 | 998 → 982 | 1114 → 1010 | 1073 → 1010 |

  Tek ölçüm; iki yönde ±%10, gürültü düzeyinde. Değişiklik yeni ağ yenilemesi eklemiyor.

**Otomatik test ×2** (`otomatik_test_sonra.txt`), **hepsi PASS**:
- 10h, 12b, 13 `=city`, 23, 24, 6 `=byz`, 7 `=byz`, 18b, 25, 36b.
- Kapalı yollar ×1: 8y, 31o, 7 (=7a), 11, 19 PASS.

**Diğer:**
- **MENURETURN** `--chapter=26` ve `--chapter=20o` PASS.
- **ZFIGHT:** 10h, 13, 18b, 24, 25, 31o → `found=0`.

## Araç

`tests/_ist/goz18_sonda.gd` (+`.tscn`, bakis_kare'den kalıtım; pakete bağlı değil):
- hub bekleme (`GOZ18_HUB`, 120 sn);
- `bekle=<özellik>` (ör. 25'te `city`);
- `bul=x,y,z;…`: noktayı kapsayan ağlar, MultiMesh örnekleri, üst düğüm/tohum bilgisi;
- `gizle=<yol parçası>`: teşhis için ağ gizleme.

## Hâlâ kötü olanlar (dürüst)

1. **Hub ve 8y geçidindeki toprak eteği** duruyor. Görünen kusurun asıl kaynağı bu (`surlar.gd:634`). Çarpışma donduğu için karar sahibinde. Bu turdaki arazi düzeltmesi sondada doğru, ama oyuncunun karesinde görünür fark yaratmıyor (arazi döşemenin ve eteğin altında kalıyor).
2. Kesimin iki ucunda (hub z 32,9–35,5) arazi set zemininin 1,15 m altında: komşu dilimin kaydı. Delme yok, ama orada boşluk görünebilir; ölçülmedi.
3. 25'teki koyu meydan zemini (gün batımında koyu mor beton levha).
4. Blakherna Sarayı temsili hâlâ düz yüzlü bir Dressing kütlesi. Pencereli ve kapılı ama ayrıntı düzeyi düşük; ayrıca üç silme hâlâ beyaza yakın.
5. 36b hendek ucu gri levhalar (hendek içinden görünüyor) — dokunulmadı.
6. Açılış süresi tek ölçümle karşılaştırıldı; gürültü payı geniş.
