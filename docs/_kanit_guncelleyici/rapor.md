# G16 — Oyun kendini internetten güncellesin: rapor

Dal: `wip/guncelleyici` (taban `wip/ist2-birlesik` = 3f787c70). Yol: **tam ikili değiştirme** (pck gömülü exe / x86_64).

## Özet

| Kalem | Durum |
|---|---|
| 1. CI bildirimi (`release.yml`: ham ikililer `dist_ham/`'e, `guncelleme.json`, yalnız açık depo) | **TAMAM** (yerel kabuk koşusu + YAML ayrıştırma; gerçek yayın koşulmadı, yasak) |
| 2. Denetim (`scripts/ui/guncelleyici.gd`, `class_name Guncelleyici`) | **TAMAM** |
| 3. Menü bandı + "Ne değişti?" + "Sonra" + ayar anahtarı + 30 `UI_GUNC_*` anahtarı (TR/EN) | **TAMAM** |
| 4. Yerinde güncelleme — Linux | **TAMAM** (gerçek paketle uçtan uca, 4 hata durumu) |
| 4. Yerinde güncelleme — Windows | **KISMEN**: kod yolu yazıldı ve birim testinde aynı işlevler sınandı; wine bu kapsayıcıda hiç açılmadığı için gerçek Windows değiştirmesi **denenemedi** (aşağıda) |
| 4. macOS | **TAMAM** (yalnız bant + indirme sayfası; birim testinde) |
| 5. Test bayrakları (`--guncelleme-kaynak/-oto/-yalniz-denetle`, çocuk süreç için `--guncelleme-surum-yaz`) | **TAMAM** |
| Birim testi `tests/guncelleme_check` (`run_tests.sh`'a tek blok, ağsız) | **TAMAM** — `GUNCELLEMECHECK PASS denetim=189 hata=0` |
| Kareler (TR+EN, 1280×720, xvfb pencereli) | **TAMAM** (bant/ilerleme/sayfa yolu/ayar durumu sahte bildirimle kuruldu, bkz. "hâlâ kötü") |

## Akış

```
Açılış (GameState._ready)
  ├─ bayraklar (-- sonrası): --guncelleme-kaynak / -oto / -yalniz-denetle / -surum-yaz
  ├─ açılış temizliği (yalnız dışa aktarılmış pakette): <exe>.eski sil; 10 dk'dan eski <exe>.yeni sil (kilitliyse sessizce sonraki açılışa)
  └─ Guncelleyici düğümü GameState'in çocuğu (PROCESS_MODE_ALWAYS; menü silinse de indirme sürer)
        oto / yalniz-denetle → hemen denetle (menüsüz; başlık ekranı tuş bekler)

Ana menü kökü ilk açıldığında (bu açılışta bir kez; autotest/shots/başsız/editör/ayar kapalı → HİÇ istek yok)
  GET https://github.com/TradersEntertainment/nothistorygamedemo/releases/latest/download/guncelleme.json
      (8 sn; tek başlık User-Agent: GercekTarihBuDegil/<sürüm>; 403/404/429/ağ yok/bozuk JSON → sessiz, bant yok)
  uzak > yerel? (segment segment sayısal, baştaki v atılır, bozuk = yeni yok)
     hayır → bitti
     evet  → önkoşullar: (a) platform girdisi (b) motor == Engine (major.minor.patch) (paket mi)
                         (c) exe klasörü yazılabilir (benzersiz adlı dosya) (d) boş yer ≥ boyut×1,1 (0/hata = bilinmiyor)
        tutmayan var → bant: "Yeni sürüm var" + kısa neden + [İndirme sayfasını aç] [Ne değişti?] [Sonra]
        hepsi tutar → bant: "Yeni sürüm var: X (sende Y) · ≈1,2 GB" + [Güncelle] [Ne değişti?] [Sonra]
[Güncelle]
  ilk adres .../nothistorygamedemo/releases/ ile başlamıyorsa indirme yok (yönlendirmenin alan adı serbest)
  HTTPRequest(download_file=<exe>.yeni, use_threads, timeout=0, gzip yok, 4 MB parça) + bekçi (30 sn ilerleme yoksa iptal)
  bant: çubuk, "486 / 1187 MB · kalan ≈7 dk", [İptal]; oyuncu oynayabilir
  bitti → bir kare bekle → boyut == manifest → SHA-256 (Thread, 4 MB'lık parçalar) == manifest
        → chmod 0755 (Linux; düşerse ve x biti yoksa sayfa yolu) → HAZIR
  her hata/iptal: yarım .yeni silinir → sayfa yolu (kısa neden)
HAZIR → yalnız ana menüde: "Güncelleme hazır ... kayıtların yerinde kalır" [Yeniden başlat ve güncelle] [Sonra]
[Yeniden başlat ve güncelle] → TEK işlev, arada await yok, res:// okuması yok:
  (.eski varsa sil; silinemezse dur) → <exe> → <exe>.eski → <exe>.yeni → <exe>  (her adlandırma 5 deneme, 0,5 sn arayla)
     2. adım tutmazsa: .eski → <exe> (geri al), sayfa yolu
  OS.create_process(<açılışta saklanan exe yolu>, normalde [] / oto'da ["--headless","--","--guncelleme-surum-yaz"])
     -1 ise: <exe> → .yeni, .eski → <exe> (geri al), sayfa yolu
  get_tree().quit()
Yeni süreç açılır → açılış temizliği .eski'yi siler
```

## Doğrulama (kanıt: `docs/_kanit_guncelleyici/testler/`)

| Kalem | Sonuç | Kanıt |
|---|---|---|
| Birim `tests/guncelleme_check.tscn` (ağsız) | `GUNCELLEMECHECK PASS denetim=189 hata=0` | `guncelleme_check.log` |
| — sürüm tablosu | 20 durum (eşit/büyük/küçük, `v`/`V` önekli, 0.99.9<0.99.10, 0.99<0.100, 0.99=0.99.0, boşluklu, 8 bozuk) | |
| — bildirim | eksik/yanlış tür `surum`, bozuk JSON, dizi, motor yanlış tür, 15 kötü platform girdisi (`../`, `/`, `\`, `:`, boş ad, sayı ad, string/negatif/kesirli/eksik boyut, kısa/onaltılık olmayan sha) | |
| — önkoşullar | linux/windows tamam, macOS ve girdisiz platform → sayfa, motor uyuşmazlığı ("4.5" = "4.5.0"), motor yok, yazılamaz, yer az (×1,1), yer bilinmiyor, paket değil | |
| — dosyalar (`~/is/gunc_birim`) | değiştirme; ikinci adım bozukken geri alma (eski exe yerinde, `.eski` yok); artık `.eski` önce silinir; başlatma geri alması; `.eski` temizliği yalnız pakette; taze `.yeni` kalır, 20 dk'lık silinir; sha256("abc") | |
| — akış | sahte yanıtla: yeni var (editörde → "geliştirme" sayfa yolu), motor uyuşmazlığı, eski sürüm, bozuk JSON, 404, ağ yok → sessiz; autotest'te `menu_acildi` istek atmaz | |
| — bant | TR ve EN, 19 durum (yeni, nedenli, uzun sürüm notu, ilerleme, doğrulama, hazır, 12 hata nedeni): dikdörtgen 1280×720 içinde ve x ≥ 560 (menü sütununa binmez), içerik taşmaz; ilerlemede düğme yeniden kurulmaz; Sonra gizler; menü kökünde var, ayarlarda ve duraklatmada yok; ayar satırı var, varsayılan açık | |
| Uçtan uca Linux (`tests/_guncelleme/e2e.sh`, gerçek 1,26 GB paketler, 127.0.0.1 sunucu) | **E2E PASS** | `e2e_linux.log` |
| — başarılı A(0.99.900)→B(0.99.901) | klasördeki ikilinin sha256'sı = B; yeniden başlayan süreç `GUNCELLEME surum=0.99.901`; `-rwxr-xr-x`; sonraki açılışta `.eski` yok, klasörde yalnız ikili; `user://` sınama kaydı + `settings.cfg` sha256 aynı; B ile yeniden denetim `yeni=hayir` | |
| — bozuk sha256 | `sayfa neden=UI_GUNC_N_BOZUK`, A sağlam, klasör temiz | |
| — motor uyuşmazlığı (4.5.0) | `sayfa neden=UI_GUNC_N_MOTOR`, indirme hiç başlamadı, A sağlam, klasör temiz | |
| — yazılamaz klasör | `sayfa neden=UI_GUNC_N_YAZMA`, A sağlam, klasör temiz (root olduğu için `chmod a-w` + `chattr +i`; ilk koşuda yalnız chmod vardı, root yazabildiği için güncelleme gerçekten yapıldı — `e2e_linux_ilk_kosu_root_chmod.log`, bu da başarılı yolun ikinci kanıtı) | |
| — indirme yarıda (50 MB'ta sunucu `kill <pid>`) | `indirme hatasi sonuc=2` → `UI_GUNC_N_INDIRME`, yarım `.yeni` silindi, A sağlam | |
| — istek başlıkları (sunucu günlüğü) | oyunun her isteğinde yalnız `User-Agent, Host, Accept(, Accept-Encoding)` | |
| Windows (wine) | **denenemedi**: Ubuntu `wine64` 9.0 kuruldu ama `wineserver` ve `wine64 cmd /c echo` bile `double free or corruption` ile çöküyor (kapsayıcı çekirdeği/ortamı). Windows dışa aktarımı üretildi (1 290 452 640 bayt < 2 GiB) | `e2e_wine.log`, betik `tests/_guncelleme/e2e_wine.sh` hazır |
| Gerçek ağ dumanı (`--headless -- --guncelleme-yalniz-denetle`) | `GUNCELLEME uzak=yok yerel=0.99.125 yeni=hayir sonuc=0 kod=404 (manifest yok -> yeni yok)` — GitHub'a ulaşıldı, yönlendirme izlendi, bildirim henüz yayında yok (curl -L aynı 404) | `ag_dumani.log` |
| CI adımı yerelde (sahte `dist/`) | `guncelleme.json` üretildi (aşağıda), ikililer `build/`'den `dist_ham/`'e taşındı; YAML ayrıştırma OK; `files:` yalnız açık depoda `dist/*` + `dist_ham/*`, gizli depo `dist/*`, artifact `dist/*` aynı | `ci_manifest.log` |
| Paket kalemleri | parse PASS (369 betik); `SURSOZLESME PASS kalem=13 kesim=8`; `ESYATEST PASS`; check_keys (sorun 0) / check_inline / check_voice_rules / check_export_refs PASS; `UIFIT PASS`; `QUIPCHECK PASS`; `--chapter=0 --autotest` ve `--chapter=1 --autotest` AUTOTEST PASS; `menu_return.tscn` 26 ve 20o MENURETURN PASS | `*.log` |

CI'ın ürettiği bildirim örneği (sahte ikililerle):
```
{"surum":"0.99.127","motor":"4.4.1","windows":{"ad":"GercekTarihBuDegil.exe","boyut":3000000,"sha256":"2162…3899"},"linux":{"ad":"GercekTarihBuDegil.x86_64","boyut":2500000,"sha256":"037f…55c4"}}
```

Windows kod yolunun gerekçesi (denenemediği için): çalışan exe Windows'ta silinemez ama **yeniden adlandırılabilir**
(görüntü eşlemesi silmeye izin verir); hedef varken adlandırma başarısız olduğundan eski `.eski` önce silinir (silinemezse
sayfa yolu); virüs tarayıcısının kısa kilidi için her adlandırma 5 kez 0,5 sn arayla denenir; o anda pck için açık bir
`FileAccess` kalmışsa (Godot dosyaları paylaşım silmesiz açar) adlandırma düşer ve geri alma eski exe'yi yerine koyar.
Yol `OS.get_executable_path()` ile açılışta bir kez saklanır, `create_process` bu yolla çağrılır.

Kareler (`docs/_kanit_guncelleyici/*.jpg`, 1280×720, xvfb pencereli, `tests/_guncelleme/kare.tscn`): `bant_yeni_{tr,en}`,
`bant_ne_degisti_{tr,en}` (gerçek 0.99.125 sürüm notuyla), `ilerleme_{tr,en}`, `hazir_{tr,en}`, `sayfa_yolu_motor_{tr,en}`,
`hata_dogrulama_{tr,en}`, `ayar_{tr,en}`.

## Güvenlik notları

- **Yalnız HTTPS** (normal yol): bildirim ve ikili sabit `https://github.com/TradersEntertainment/nothistorygamedemo/...`
  adreslerinden; ikili adresi bu önekle başlamıyorsa indirme yok. "Ne değişti?" yalnız
  `https://raw.githubusercontent.com/TradersEntertainment/nothistorygamedemo/main/data/changelog.json` (varsayılan dal `main`,
  şema `{"<sürüm>": {"tr": …, "en": …}}` elle doğrulandı; alınamazsa sürüm sayfası açılır). Sertifika doğrulaması Godot'nun
  varsayılanı (kapatılmadı).
- **Bütünlük:** boyut ve SHA-256 manifestle karşılaştırılır (manifest esas). Tutmazsa dosya silinir, değiştirme yok.
  Not: manifest ve ikili aynı yerden geldiği için bu **bütünlük** denetimidir, **kimlik** denetimi değil (imza yok).
- **Geri alma:** iki adlandırma ve süreç başlatma arasında her hatada eski exe yerine döner; oyun hiçbir durumda eksik ya da
  bozuk exe ile kalmaz (birim testi + e2e "A sağlam, klasör temiz").
- **Kimlik gönderilmez:** istekte yalnız `User-Agent: GercekTarihBuDegil/<sürüm>` (e2e sunucusu gelen başlıkları yazdı:
  yalnız `Host, User-Agent, Accept, Accept-Encoding` — sonuncular Godot'nun varsayılanı). Çerez, kimlik, makine bilgisi yok.
- **Yerel kaynak** (`--guncelleme-kaynak`) yalnız `http://127.0.0.1` ve `http://localhost` (öteki her şey reddedilir, `@` da).
- **Dosya adı:** manifestteki `ad` içinde `/`, `\`, `..`, `:`, baş/son boşluk reddedilir (yol kaçışı yok); indirilen dosya
  her zaman `<exe>.yeni`.
- **Testte ağ yok:** `autotest`, `--shots`, `--dialogshots`, `--exitcheck`, başsız (`DisplayServer == headless`) ve editörde
  istek atılmaz; `run_tests.sh` ağsız aynı geçer. Değiştirme ve açılış temizliği yalnız `OS.has_feature("template")` iken
  (testlerde exe Godot'nun kendisidir, ona dokunulmaz).

## Bilinen sınırlar

- Her güncelleme **≈1,2 GB tam indirme** (delta/parça yaması kapsam dışı).
- **Motor sürümü değişince elle kurulum:** manifest `motor` ≠ oyunun motoru → sayfa yolu. Bu teknik zorunluluk değil,
  yayıncının "bu sürüm elle kurulsun" anahtarı (CI `GODOT_VERSION`'ı yazar).
- **NSIS `DisplayVersion` eski kalır** (Programlar ve Özellikler'de eski sürüm görünür; kaldırma yine çalışır).
- **İmzasız exe:** SmartScreen/virüs tarayıcısı yeni exe'yi ilk açılışta yine uyarabilir; tarayıcı dosyayı kilitlerse
  adlandırma 5 kez denenir, olmazsa geri alınır.
- **İki pencere:** iki örnek açıkken biri değiştirirse ötekinin pck okuması bozulur (gömülü pck yol adıyla yeniden açılır).
  Açılış temizliği yalnız 10 dakikadan eski `.yeni`'yi siler (öteki örneğin süren indirmesine dokunmaz).
- Program Files gibi yazılamayan yerlerde (ya da FAT/exFAT'te chmod düşerse) yalnız sayfa yolu.
- GitHub API kullanılmaz (60/saat sınırı yok); `digest` çapraz denetimi bu yüzden düştü.

## Hâlâ kötü olanlar (dürüst)

- **Windows değiştirmesi gerçek bir Windows'ta (ya da wine'da) hiç çalıştırılmadı.** İlk sürümden önce bir Windows
  makinede `tests/_guncelleme/e2e_wine.sh`'in adımları elle denenmeli (özellikle: çalışan exe'nin adlandırılması, virüs
  tarayıcısı kilidi, SmartScreen).
- Kareler gerçek indirmeden değil, güncelleyicinin durumu sahte bildirimle elle kurularak alındı (gerçek indirme e2e'de
  başsız koşuldu; başsızda bant çıkmaz).
- Değiştirme ile `quit()` arasında aynı karede başka bir düğüm `res://` okursa (ör. ilk kez çalınan bir ses) gömülü pck
  yeni dosyadan okunur; pencere sıfırlanmadan kapandığı için pratikte görülmedi ama sıfır değil.
- "Sonra" ile ertelenen hazır indirme sonraki açılışta yeniden kullanılmaz (10 dk sonra silinir, ≈1,2 GB yeniden indirilir).
- İlerleme yalnız ana menüde görünür; oyun içindeyken indirmenin bittiğini oyuncu menüye dönünce görür.
- Bildirim ve ikili aynı GitHub sürümünden gelir: SHA-256 bozulmaya karşı korur, depo ele geçirilirse korumaz (imza yok).
- Hızlı çıkışta Godot "ObjectDB instances leaked / resources still in use" uyarıları basar (SCRIPT ERROR değil; CI'ın
  aradığı kalıplara girmez).
- Ayar satırı "Oyun testi" başlığının altına düştü (ayrı başlık açmamak için); yeri tartışılabilir.
