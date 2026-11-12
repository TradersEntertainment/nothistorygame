# hayat-yakin — rapor (1. gönderim, ilk çalışan hâl)

Dal: `wip/ist-hayat-yakin` (taban `wip/ist2-taban2`). Yeni dosyalar: `scripts/world/ist/hayat_yakin.gd` (`IstHayatYakin`),
`scripts/world/ist/hayat_yakin_govde.gd` (`IstHayatGovde`), `tests/_ist/hayat_yakin_onizleme.{gd,tscn}`.

## Ne var
- `IstHayatYakin.attach(dunya, oyuncu, gece)` (`IstSehir.attach_v2` SONRASI): `IstSehir.sokak`'tan sokak çizgilerini (16 717 nokta,
  630 sokak) 5 m'ye sıklaştırıp 32 m'lik karmaya koyar. Oyuncunun 12–85 m çevresinde kişi doğurur, 105 m ötesini havuza döndürür.
- 49 kişilik havuz (`Person` gövdesi, `Rig` buradan sürülür; CityLife ile aynı dil). Roller: erkek, kadın, çocuk, hamal, keşiş, rahip,
  fenerci, satıcı (tezgâhlı), balıkçı, işçi, nöbetçi, dilenci, çamaşırcı, kapı önü oturan.
- Yürüyenler: sokak çizgisi boyunca sağdan yürür (şerit genişliğe göre; geniş sokakta tezgâh payı bırakır), kavşakta döner, uçta geri
  döner, oyuncu yaklaşınca yana çekilip bakar, tezgâhta durup müşteri olur, ikili yürüyüşte durup sohbet eder, kişisel alan.
- Duranlar: Mese/çarşıda tezgâhlı satıcı (var olan `CL_BARK_*` sözleri), kapı önünde tabureli oturan, leğen başında çamaşırcı,
  dilenci, sur dibinde işçi (çekiç/balta + taş yığını) ve nöbetçi, rıhtımda balıkçı, ikili sohbet.
- Konum her zaman `IstGeo.h/su` ve `IstSokak.cell` (doluluk ızgarası) ile: ev/anıt/sur (2,3,4) hücresine basılmaz; S sabiti koda gömülü değil.
- StreetEye uyumu: düğüm adı `CityLife` ve ajanlar `{body, active, kind, role, look, wait}`: `StreetEye` yakındaki gövdelere
  "E · Konuş" alanı açar, tuhaflığa tepki verdirir. Yeni replik yazılmadı.
- Sayım: `sayim_satiri()` → `ISTKISI <ad> y30 y60 gorunen etkin yuruyen duran evde havada suda ms ms_ort ms_max hedef`.

## Durum (ilk gönderim): KISMEN
Önizleme: `godot --path . res://tests/_ist/hayat_yakin_onizleme.tscn -- shots=KLASÖR gece=0|1 sahne=mese,sokak,iskele,meydan,sur,yakin_satici…`
Yazılımla çizimde ölçüm: ms_ort 0,5–1,9 ms (hedef ≤ 2 ms). Bkz. pafta_1, pafta_2.
Bilinen eksikler (sonraki gönderimde): meydan/iskele yakın çevresinde kişi az, hayvanlar yok, gece karesi yok, oyuncuyla (Player) yürüme
sınaması yok, sayısal denetim satırları (evde/havada/suda) toplu koşu yok.
