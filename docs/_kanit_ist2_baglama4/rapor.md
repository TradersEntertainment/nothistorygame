# İstanbul v2 — BAĞLAMA-4: rapor

Dal: `wip/ist2-baglama4` (taban `wip/ist2-taban4`; `wip/ist2-sur4`, `wip/ist2-ordugah4`, `wip/ist2-cevre4` birleştirildi;
`wip/ist2-doku4` uzakta yoktu). Görev: `docs/_ajan/gorev/ist2_tur4.md` "BAĞLAMA-4".

## 1. Bölüm bölüm durum

@@DURUM@@

## 2. Kendi karelerime bakınca hâlâ kötü olanlar

@@KOTU@@

## 3. Madde madde hüküm

### Madde 1 — Dönüşümlü bağlama (bilinen kusur 1–2)

**Nasıl:** v2 artık ötelenmez (`IstGeo.kaydir` hep 0): v2 kendi çerçevesinde kurulur, kökü (SiegeField kabuğu
`IstBaglamaKok`) bölümün çerçevesinde `xf⁻¹` dönüşümüyle durur (`xf`: bölüm yereli → v2; eski World1453'te de
`f.transform = region⁻¹` idi). `IstBaglama.donusum(bolge)`:
- **byz_walls (hub):** hub'ın iç suru (ByzCity yerel x 34, dış yüz +x) v2 kara surunun iç suru üstünde; yerel +x v2'de
  dışa; hub'ın kapısı (yerel z −31,5, `ByzCity._build_walls`'ın kapısı) v2'nin Romanos Kapısı'nda (gerçek −4621, 823 kara
  suru hattına oturtulur). Bölümün y 0'ı kapıdaki v2 arazisi. Ölçülen: `xf=(-1651.1, 14.2, -331.4) yaw=162.9`.
- **camp (ordugâh):** CampDay'in "sura doğru" ekseni (yerel +z) otağdan en yakın kara suru noktasına; otağ (yerel 0, −62)
  v2 ordugâhının otağında; y 0 otağdaki v2 arazisi. Ölçülen: `xf=(-1909.5, 12.5, -491.5) yaw=61.1`.
- Bölge yaması, deniz-yok ve dışlama alanları v2 çerçevesinde (yerel ↔ v2 çevrimi `IstBaglama.yerel/v2`); bölümün
  alanındaki v2 öğeleri döndürülmüş dikdörtgenle süzülür (`yerel_icinde`); Romanos Kapısı öğesi KORUNUR (hub'ın kapısı onun
  iç yanına oturur, dış sur ve hendek köprüsü kesintisiz kalır).
- **IstSehir oyun alanı ve hub önbelleği** (`_oyun`, `_hub_xf`) IstSehir ağaca girerken bu dönüşümle önceden dolar
  (`child_entered_tree`; `sehir.gd`'ye dokunulmadı): sokak, ev ve yaşam katmanları hub'ın GERÇEK alanını boş bırakır
  (önceki yerinde v2 kişileri hub binalarının içine düşüyordu: `VISAUDIT insolid … IstHayatYakin` 2 satır → 0), ŞEHİR'in
  uzak hub'ı (`hub_sehir`, uçuşta görülen) aynı dönüşümle döndürülür (`ISTBAGLAMA hub_sehir dondu yaw=162.9`): uçuşta
  görülen hub = Tolga'nın oynadığı hub, ikisi de sura gömülü.
- **Kök dönüşümü kurulumdan SONRA verilir:** v2'nin bazı parçaları kurulurken global çerçeveyi v2 sanıyor (Ayasofya'nın
  pişmiş uzak katmanı `Ist_ayasofya/L2/Pismis` 1,7 km'ye yayılıyor, bir parçası hub'ın yanında gökte asılı gri levha
  oluyordu; ikili aramayla bulundu: `HUBDENEY SUCLU …Ist_ayasofya/L2/Pismis aabb=[P: (-1713.983, …), S: (1731.233, …)]`).
  Kurulum birim dönüşümde biter (gezideki gibi), kök sonra oturur: levha kalktı (kare `sonda7`, aşağıda). Kaynak
  ÇEVRE-4/ŞEHİR'de: ORTAK İSTEK 2.

@@M1@@

### Madde 2 — Mini harita v2 (bilinen kusur 3)

`MapView.v2` (bağlama açıkken): aynı W × H × MPP çerçevesi (3,4 × 2,4 km), kuzey yukarı (piksel x = doğu, y = güney),
doku `assets/ui/harita_ist2.res` (içe aktarmasız, sıkıştırılmış Image; `tests/_ist/harita_v2.tscn` pişirir: deniz,
arazi gölgesi, mahalle türleri, kara/Blakherna surları, Mese kolları, ordugâh öğeleri, otağ kırmızı). Alan: v2 kabuğu
(`IstBaglamaKok`, "world1453" grubu; `night_build` = bölümün gecesi), oyuncu kabuğun dönüşümüyle v2 çerçevesine çevrilir;
yön v2'de `atan2(fwd.x, −fwd.z)`. WorldMap bölge adları `MapView.region_labels()` (v2'de v2 konumları), eserler v2
konumlarında (`V2_LL`, `docs/ISTANBUL_YERLER.csv`). İlk koşuda `MiniMap._process` `bool(_field.get("night_build"))`
hatası (alan IstDunya iken) → alan kabuk yapıldı, hata 0.

@@M2@@

### Madde 3 — Tolga'nın şehir bölümleri

Bölüm dosyalarına dokunulmadı: `IstBaglama.tolga_istek()` sahnedeki bölüm betiğinin adından (chapter<id>.gd) tanır;
`TOLGA = [6, 10h, 12b, 23, 24]`, varsayılan açık olanlar `TOLGA_ACIK`, öbürleri `--ist2-deneme=<id>`. Bölüm 7'nin 7b'si
(Nihat bölümü) zaten v2'de (varsayılan).

**12b'de üçüncü turdaki görsel kusurlar ve bu turdaki karşılığı:**
1. Hub'ın kendi suru şehrin içinde ikinci bir sur (v2 kara surunun 75 m iç yanında, doğuya bakan) → sura gömülü
   (dönüşüm); pafta `pafta_12b_hub.jpg` 04 ve 06.
2. Hub y 0'da, v2 arazisi ~14 m: 260 m'lik sığ çanak → bölümün y 0'ı v2 arazisine oturur (dikey öteleme 14,2 m).
3. v2 sokak/ev/kişi katmanları hub'ın eski (75 m içerdeki) oyun alanına göre boş bırakılıyordu → hub'ın gerçek alanına
   göre (kişiler hub binalarının içinde değil: VISAUDIT 0).
4. Uçuşta görülen uzak hub yanlış yönde (yaw 0) → döndürülmüş.
5. Gökte asılı gri levha (dönüşümle ortaya çıkan Ayasofya uzak katmanı parçası) → kalktı.
6. Mini harita yok → v2 haritası.

@@M3@@

### Madde 4 — Ordugâhta geçen bölümler (döküm; kod yok)

Hepsi `CampDay` (bölge "camp"); v2'de oturacağı yer bu turdaki dönüşümle AYNI: otağ (yerel 0, −62) v2 ordugâhının
otağında (`IstOrdugah.plan` "otag"), yerel +z en yakın kara suru noktasına (yaw 61,1°), y 0 = otağın v2 arazisi (12,5 m).
Bağlamak için gereken: `BOLUMLER`'e numara ya da `tolga_istek` benzeri sahne tanıma + bölümün kendi gece/gündüz bayrağı.

| bölüm | CampDay'den kullandığı | gündüz/gece | v2'de |
|---|---|---|---|
| 6 (6a) | OTAG_POS ×3, URBAN_POS, SPAWN, KITCHEN_SPAWN | gündüz | otağ önü + Urban'ın topu sura bakar (yerel +z) |
| 7 (7a) | URBAN_POS ×2, LUTFI_POS ×2, SPAWN, KADRI_POS | gündüz | BAĞLI (v2, varsayılan) |
| 9 | SPAWN, LUTFI_POS | gündüz | otağ çevresi; Lütfi'nin masası |
| 10, 10b, 10z | OTAG_POS ×7 (10); kendi çadırları (10b: GOAT_TENT, Night.tent) | 10b gece | otağ çevresi; 10b çadırları CampDay alanında kalır |
| 11 | SPAWN | gece | BAĞLI (v2, varsayılan) |
| 13 | URBAN_POS ×3, KITCHEN_SPAWN, `fire_cannon`, `open_window_at_crack` | gündüz | top sura bakar: atış yönü yerel +z = v2'de kara suruna (kontrol edilmeli: gülle hedefi) |
| 16 | CampDay (genel) | – | otağ çevresi |
| 24o | CampDay + Night.tent | gece | otağ çevresi |
| 25 | KITCHEN_SPAWN ×2, OTAG_POS, KADRI_POS + ByzCity "aya" | gündüz | iki bölge aynı sahnede: tek kök dönüşümü yetmez (iki kök gerekir) |
| 43o | OTAG_POS | – | otağ çevresi |
| 35o | ("camp" bölgesi adıyla) | – | BAKILMADI (CampDay.new yok) |

### Madde 5 — Kanıt: paftalar ve `rinfo.md`

@@M5@@

## 4. Testler

@@TEST@@

## 5. Dokunulan v2 satırları (yalnız izleyici okuma; dönüşümlü bağlama için `to_local`)

| dosya | işlev | satır (önce → sonra) |
|---|---|---|
| `scripts/world/ist/hayat.gd` | `_bakan` | `return izle.global_position` → `return to_local(izle.global_position)`; `return c.global_position` → `return to_local(c.global_position)` |
| `scripts/world/ist/hayat_yakin.gd` | `_process`, `doldur` | `_pw = ref.global_position` → `_pw = to_local(ref.global_position)` (2 yer) |
| `scripts/world/ist/hayat_yakin.gd` | `_view_cone` | `_cam_at = cam.global_position` → `to_local(…)`; `_cam_fwd = (-cam.global_basis.z).normalized()` → `(global_basis.inverse() * -cam.global_basis.z).normalized()` |
| `scripts/world/ist/mahalle_doku.gd` | `_cam` | `return vp.get_camera_3d().global_position` → `return to_local(vp.get_camera_3d().global_position)` |
| `scripts/world/ist/ordugah_yonetici.gd` | `_cam_pos` | `return bakan.global_position` → `to_local(…)`; `return c.global_position` → `to_local(…)` |

Benim dosyalarım (ayrıca): `geo.gd` değişmedi; `dunya.gd` `_bakan` (to_local ×2), `_yakalayici` (`izle.global_position =
to_global(…)`); `baglama.gd` (dönüşüm, yerleşim, harita, Tolga anahtarı); `scripts/ui/map_view.gd` (v2 kipi: ekleme);
`scripts/ui/world_map.gd` 1 satır (`MapView.REGION_LABELS` → `MapView.region_labels()`); `tests/flight_check.gd` 1 satır
(`carpisma_yenile(kok.to_local(p))`), `tests/_ist/baglama_ucus.gd` (v2 yüksekliği/gerçek konum kök çerçevesinde);
yeni: `tests/_ist/hub_kare.*`, `tests/_ist/harita_v2.*`, `assets/ui/harita_ist2.res`. Bölüm dosyalarına,
`world1453.gd`'ye, `nihat_powers.gd`'ye, `world_flight.gd`'ye bu turda dokunulmadı.

## 6. ORTAK İSTEK / ORTAK BİLGİ

1. **ÇEVRE-4 (`sehir.gd`) — hub'ın yeri ve yönü:** `oyun_alanlari()` ve `hub_xf()` hub'ı Romanos'un 75 m iç yanına, yaw 0
   ile koyuyor; bu tur hub sura gömülü ve döndürülmüş oturdu. Ben IstSehir'in önbelleğini (`_oyun`, `_hub_xf`) bağlama
   sırasında dolduruyorum; gezi/önizlemede (bağlama yok) uzak hub hâlâ eski yerde ve yaw 0. Önerilen kalıcı kural (aynı
   sonucu bağlamasız da verir):
   ```gdscript
   func hub_xf() -> Transform3D:
       if _hub_xf != Transform3D():
           return _hub_xf
       _hub_xf = IstBaglama.donusum("byz_walls")      # ByzCity "walls" yereli → v2 (kaydırmasız)
       return _hub_xf
   # oyun_alanlari(): hub dikdörtgeni = IstBaglama._rect_xf(hub_xf(), Rect2(-46, -48, 84, 70).grow(2))
   # _v2_item("hub_sehir", hx.origin, hx.basis.get_euler().y, …)   # yaw 0 yerine
   ```
   ve `_place_v2`'deki "oyun_hub" adayı (Romanos'un 75 m iç yanı, r 55) aynı merkeze.
2. **ÇEVRE-4 / ŞEHİR — global çerçeve varsayımı:** (a) Ayasofya'nın uzak katmanı (`Ist_ayasofya/L2/Pismis`) bir parçayı
   dünya başlangıcına göre konumluyor (kök dönüşümlüyken AABB 1,7 km; parça hub'ın yanında gökte); kaynak bulunamadı
   (BAKILMADI: `_make_aya`/`sehir_eser` Ayasofya çevresi parçalarından biri). (b) SUR-4: `sehir.gd` `_dis_dy` →
   `h.global_transform` (v2 çerçevesi değil): `h.transform` olmalı (tutucu IstSehir'in doğrudan çocuğu). Benim tarafta
   kök dönüşümü kurulumdan sonra verildiği için ikisi de bugün zararsız; ama akışla SONRADAN kurulan parçalarda aynı
   varsayım varsa yanlış yere düşer.
3. **Herkes — öteleme kuralı yerine dönüşüm kuralı:** v2 kodu `global_*` okumasın/yazmasın; izleyici `to_local`, yerleşim
   yerel. Yeni durağan dünya önbelleği eklenirse `IstBaglama._onbellek_sifirla`'ya.
4. **ORDUGÂH-4 — BİLGİ:** bölümün ordugâhı (CampDay) v2'de döndürülmüş oturuyor (yaw 61,1°); bölüm alanındaki plan öğeleri
   döndürülmüş dikdörtgenle süzülüyor (`ISTBAGLAMA temizle … ordugah_oge=30`). Kimlik/arayüz değişikliğiniz (ARAYÜZ
   DEĞİŞİKLİĞİ) bağlamayı bozmadı: 7 ve 11'in 20 varyantı PASS.
5. **DOKU-4 — yükleme:** bağlamada v2 kurulumu başsız ~35–45 sn (iki koşu aynı anda; tek koşu ölçümü `rinfo.md`).

## 7. SAHİBİNE GÖSTERİLECEK 8 KARE

@@SEKIZ@@
