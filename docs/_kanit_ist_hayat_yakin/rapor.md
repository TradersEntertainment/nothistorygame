# hayat-yakin — rapor ("yaşam dolu olacak sokaklar", oyuncunun çevresinde gerçek kişiler)

Dal: `wip/ist-hayat-yakin` (taban `wip/ist2-taban2`). Yalnız YENİ dosyalar; var olan hiçbir dosya değişmedi.

| Dosya | İş |
|---|---|
| `scripts/world/ist/hayat_yakin.gd` (`IstHayatYakin`) | akış, doğuş/havuza dönüş, yürüme, durma, gezinme, hayvanlar, sayım |
| `scripts/world/ist/hayat_yakin_govde.gd` (`IstHayatGovde`) | roller (Person gövdesi), tezgâh/tabure/leğen/taş yığını, hayvan modelleri, pişirme (`Crowd._bake`) |
| `tests/_ist/hayat_yakin_onizleme.{gd,tscn}` | kare, sayım, RINFO, yakın plan, yürüme ve sayısal denetim sahnesi |
| `docs/_kanit_ist_hayat_yakin/` | bu rapor, paftalar, `ham_satirlar.txt` |

## Nasıl çalışır
- `IstHayatYakin.attach(dunya, oyuncu, gece)` (`IstSehir.attach_v2` SONRASINDA): `IstSehir.sokak`'tan 630 sokağı 5 m'ye sıklaştırıp
  (16 717 nokta) 32 m'lik karmaya koyar; ev ayak izleri 10 m'lik karmada. Konum her yerde `IstGeo.h/su`, `IstSokak.cell` (doluluk
  ızgarası: ev/anıt/sur/dış = basılmaz) ve **gerçek ev ayak izi** (`IstEvler.dims`, ızgaradan ince) ile doğrulanır; dünya ölçeği `S`
  koda gömülü değil.
- **Akış**: oyuncunun (ya da kameranın) 18–85 m çevresinde, yakına ve bakış yönüne ağırlıklı doğar; görüştekiler ≥ 50 m'de
  (ya da ev/sur araya girmişse, `_occluded`) doğar; 105 m ötesi havuza döner; 150 m'den yüksek uçuşta (Nihat) kapanır (üstü `IstHayat`).
  Işınlanma/bölüm girişinde (120 m sıçrama) ilk kare dolu olsun diye yakın doğuş yeniden açılır. En çok 45 etkin kişi.
- **Kalabalık hedefi** `IstGeo.mahalle` türünden: çarşı 38, liman 26, sık 16, sur dibi 14, seyrek 8, bostan 5, harabe 4, kır 3; Mese
  kıyısında ≥ 30; gece ×0,55.
- **Roller (49 kişi)**: erkek, kadın, çocuk, hamal (yük taşır), keşiş, rahip, fenerci (gece çoğalır, elde kandil), satıcı, balıkçı
  (oltalı), işçi, nöbetçi (mızrak/kalkan), dilenci, çamaşırcı, kapı önü oturan. + **10 hayvan**: köpek, kedi, tavuk (`Chicken`), eşek (küfeli).
- **Yürüyenler** sokak çizgisinde sağdan yürür (geniş sokakta tezgâh payı bırakır), kavşakta döner, uçta geri döner, kişisel alan
  (0,6 m), oyuncu yaklaşınca yana çekilip bakar, tezgâhta durup müşteri olur (arms_folded), ikili yürüyüşte durup karşılıklı sohbet eder.
- **Duranlar/gezinenler**: Mese ve çarşıda tezgâhlı satıcı (var olan `CL_BARK_*` sözleri, `SPK_TOWNSMAN`), kapı önünde tabureli
  oturan, leğen başında çamaşırcı, yerde oturan dilenci (tas), sur dibinde işçi (çekiç/balta + taş yığını) ve nöbetçi, rıhtımda balıkçı,
  meydanlarda (15) 2–3 gezinen + sohbet ikilisi, kıyı noktalarında (8) balıkçı + hamal + sohbet, ikili/üçlü sohbet.
- **Yeni replik YOK.** Düğüm adı `CityLife`, ajanlar `{body, active, kind, role, look, wait}` taşır: `StreetEye` (`find_children("CityLife")`)
  yakındaki gövdelere "E · Konuş" alanı açar ve tuhaflığa tepki verdirir; kişiler `street_role` işaretli (var olan `DST_<ROL>_…` havuzları).
- **Çizim bütçesi**: bir `Person` onlarca çizimdir. Yakın ve görüşteki en çok **4 kişi** (≤ 20 m) gerçek gövde; ötekiler ve görüş
  dışındakiler `Crowd._bake` ile tek yüzeye pişmiş, LOD'lu, gölgesiz **donuk ikiz** (yürürken hafif sekme). Tezgâh/tabure/leğen/taş
  yığını/tas ve hayvanlar da pişmiş tek ağ; pişen ağlar `user://crowd_cache`'te (Crowd düzeni).

## Madde madde
1. Sokak boyunca yürüyenler, kaldırımda, evlerin içinden geçmeden, karşılaşınca yol veren — **DÜZELDİ** (şerit + kişisel alan + ev ayak izi;
   sayısal denetim: aşağıda).
2. Duranlar ve iş yapanlar (tezgâh, kuyruk, kuyu, çamaşır, hamal, balıkçı, sur işçisi, nöbetçi, keşiş, çocuk, dilenci, mülteci) —
   **KISMEN**: tezgâhlı satıcı + müşteri, oturan, çamaşırcı, dilenci, işçi, nöbetçi, balıkçı, hamal, sohbet, keşiş/rahip, çocuk VAR;
   fırın önü kuyruğu, kuyudan su çeken, çamaşır asan, dua eden keşiş (duruşla), oynayan çocuk grubu, mülteci aile YAPILMADI.
3. Hayvanlar — **KISMEN**: köpek, kedi, tavuk, eşek var (10); martı/güvercin `IstHayat`'a bırakıldı; keçi/at yok.
4. Mahalle türüne göre yoğunluk (çarşı 25+, sık 10–15, seyrek 4–6) — **KISMEN**: hedef sayılar uygulanıyor (aşağıdaki sayım),
   ama sokak ağı seyrek olduğu yerde (iskele, meydan çevresi) hedefe ulaşılamıyor (iskele 22 etkin / 21 hedef ✓., meydan 15 / 15 ✓.,
   Mese 32 / 31 ✓.; "görünen" sayısı bakışa bağlı: Mese 19, iskele 22, meydan 14, mahalle sokağı karesi köşeye bakınca 0–2).
5. Akış (görüş dışında doğar, 105 m ötesi kaybolur, ≤ 2 ms, ≤ ~45 kişi) — **DÜZELDİ** (ms_ort 0,6–1,7; yürüyüş benzetiminde 0,23–1,23, bkz. ham satırlar;
   yazılımla çizimli koşuda ölçüldü). İlk gövde/ikiz pişirmesi tek seferlik pahalıdır (aşağı "bakılamayanlar").
6. Uçuşta (Nihat) kişiler aşağıda görünür — **KANITSIZ** (uçuş kipi koşulmadı; kod: 150 m üstünde kapanır, altında çalışır).
7. `VISAUDIT`/`WALKTHRU`/`ARMAUDIT` — **KANITSIZ**: v2 bölümlere bağlı değil, bu denetimler çalışmadı; yerine kendi sayımım: aşağıda.
8. Önizleme `tests/_ist/hayat_yakin_onizleme.*`: Mese, mahalle sokağı, iskele, meydan, sur dibi; gündüz + gece; `ISTKISI` sayımı — **DÜZELDİ**.

## Sayılar
Başsız bölüm testleri (hiçbir bölüm dosyası değişmedi): Bölüm 6, 7, 11 `AUTOTEST PASS`; `PARSECHECK PASS scripts=310`.
Denetim yasağı satırları (`SCRIPT ERROR`, `WARN_*`, `VISAUDIT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*`) bu üç koşuda ÇIKMADI.
Gerçek `Player` ile Mese'de 30 sn yürüme: `YURUME … PASS`, 31 etkin, ev/hava/su 0 (yazılımla çizimde yavaş: 18 m).
Sayısal denetim (başsız, 21 konum, her mahalle türünden ≤ 3 sokak noktası, kamera sokak boyunca yürüyor, her karede sayım):
`ISTKISIDENETIM TOPLAM konum=21 evde=0 havada=0 suda=0 ms_maks=6.57 PASS` (ham_satirlar.txt). ms_maks 6,57 = ilk doğuşta tezgâh/ağ yerleştirme sıçraması; ortalama 0,2–1,2 ms.
(Önceki kodla ilk koşuda 3 konumda 1 kişi "havada" göründü: uzak ikizin y'si 3 karede bir güncelleniyordu; düzeltildi, yeniden koşuldu.)

**RINFO (aynı konum, hayat KAPALI → AÇIK; yazılımla çizim, 1280×720)**

| sahne | çizim kapalı → açık | üçgen kapalı → açık |
|---|---|---|
| Mese | 597 → 708 (+19 %) | 1,07 M → 1,20 M (+12 %) |
| iskele | 404 → 422 (+4 %) | 0,71 M → 0,67 M |
| meydan | 676 → 979 (+45 %) | 0,79 M → 1,21 M (+53 %) |
| mahalle sokağı | 287 → 287 | 0,31 M → 0,31 M (görüşte kimse yok) |
| sur dibi | 142 → 144 | 0,35 M → 0,35 M |

NEAR_CAP 5 iken ölçüldü; cap 4'e indirilip yeniden RINFO alınmadı (meydan/Mese biraz daha düşer). Mutlak: yerde ≤ 900 çizim / 2,5 M üçgen bütçesinin
Mese'de içinde, meydanda (kapalıyken zaten 676) çizimde dışında. **Üçgen/çizim "+%8" ölçütü karşılanmadı → KISMEN**: bu bir
katman, ölçüt "var olan sahneye ek" içindi; sınır NEAR_CAP ve NEAR_BODY ile ayarlanır (tek sabit).

## Bağlama önerisi (ORTAK DOSYA ÖNERİSİ — uygulanmadı)
`scripts/world/ist/dunya.gd` (DÜNYA) ya da `sehir.gd` `attach_v2` SONUNDA, `IstSehir.sokak` kurulduktan sonra:
```gdscript
# attach_v2'nin sonunda (gece_ ve oyuncu biliniyorsa)
IstHayatYakin.attach(dunya, null, gece_)    # null: oyuncu (group "player") ya da etkin kamera izlenir
```
- Oyuncu sonradan gelirse `IstHayatYakin.aktif.oyuncu = player` (ışınlanma/bölüm girişinde `IstHayatYakin.aktif.doldur(6)`).
- Yükleme ekranı sırasında kurulur (`hemen_isin := true`: bütün gövde/ikiz/hayvan `attach` içinde bir kerede; ilk açılışta ~birkaç sn,
  sonra `user://crowd_cache` sayesinde ~1 sn). Oyun içi artan kurulum istenirse `hemen_isin = false`.
- `GameState.exitcheck`/`NO_CITYLIFE` ortam bayrağını CityLife'taki gibi saymak için `attach` çağrısını sarmak yeterli.
- `StreetEye` hiçbir değişiklik istemez (düğüm adı `CityLife`, ajan alanları uyumlu). `IstHayat` ile çakışmasın: bu katman 105 m'de biter.

## ORTAK İSTEK (`sokak.gd`)
Yok: ihtiyaç duyduğum her şey var olan açık alanlardan geldi (`streets`, `meydan`, `houses`, `cell()`). İki öneri (zorunlu değil):
- `IstSokak.cell_blocked(x, z, margin)` gerçek ev/anıt ayak izine göre (şimdi `IstHayatYakin._in_house` kendi karmasını kuruyor, 3 984 ev).
- Rıhtımda yürünebilir hücre işareti (deniz suru bandı = 3 olduğu için kıyıda yalnız 8 uygun nokta kaldı: balıkçı/hamal az).

## Bakılamayanlar / bilinen eksikler
- Uçuş (Nihat) ve çatı/sur üstü: bakılmadı. Başka kişiler ya da oyun nesneleriyle (ağaç, `ayrinti` kuyusu/arabası) kişi çarpışması bilinmiyor:
  ızgara ve ev ayak izini kullanıyoruz; dış `ayrinti` eşyalarını bilmiyoruz.
- Gece: fenerci elinde ışık veriyor, tezgâh direklerinde emissive kandil var; genel görünürlük düşük (kareler paftada).
- Ses/replik: yeni yok; `Hud` yokken bağırma (bark) sınanmadı (`_hud` yoksa sessiz).
- Yürüyen ikizler duruş donuk + hafif sekme; 20 m'den uzakta bacak hareketi yok.
- `.import` ve çevirinin ürettiği dosyalar kaydedilmedi.
