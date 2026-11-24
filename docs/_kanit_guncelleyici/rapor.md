# G16 — Oyun kendini internetten güncellesin: rapor

Dal: `wip/guncelleyici` (taban `wip/ist2-birlesik` = 3f787c70). Yol: **tam ikili değiştirme** (pck gömülü exe / x86_64).

## Özet

| Kalem | Durum |
|---|---|
| 1. CI bildirimi (`release.yml`: ham ikililer `dist_ham/`'e, `guncelleme.json`, yalnız açık depo) | **TAMAM** (yerel kabuk koşusu + YAML ayrıştırma; gerçek yayın koşulmadı, yasak) |
| 2. Denetim (`scripts/ui/guncelleyici.gd`, `class_name Guncelleyici`) | **TAMAM** |
| 3. Menü bandı + "Ne değişti?" + "Sonra" + ayar anahtarı + 30 `UI_GUNC_*` anahtarı (TR/EN) | **TAMAM** |
| 4. Yerinde güncelleme — Linux | **TAMAM** (gerçek paketle uçtan uca, 4 hata durumu) |
| 4. Yerinde güncelleme — Windows | __WINE__ |
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

__DOGRULAMA__

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

__KOTU__
