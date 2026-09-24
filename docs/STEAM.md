# Steam'e çıkış

Oyunun Steam tarafı hazır, ama iki şey senin elinden geçmeli: **App ID** (Steamworks hesabı) ve **GodotSteam eklentisi**.
Eklenti kurulmadan oyun her yerde aynı çalışır; kurulunca başarımlar kendiliğinden Steam'e gider.

## 1. Steamworks ve App ID
1. https://partner.steamgames.com adresinden Steamworks hesabı aç, uygulama ücretini (Steam Direct, oyun başına 100 $) öde.
2. Yeni uygulama oluştur: bir **App ID** alırsın (örn. `3456780`).
3. Mağaza sayfası için görseller hazır: `store/` klasörü (kapsüller, arka plan, logo). Ekran görüntüleri: `docs/screenshots/`.

## 2. GodotSteam eklentisi
1. Godot'da projeyi aç → **AssetLib** → "GodotSteam GDExtension" ara → Godot 4.4 sürümünü indir ve kur
   (`addons/godotsteam/` klasörü oluşur). Godot'yu yeniden başlat.
2. Geliştirirken: proje klasörüne `steam_appid.txt` dosyası koy, içine yalnızca App ID'yi yaz. Steam açıkken oyunu çalıştır.
   Oyun başlarken `SteamBridge.init()` bağlanır (`scripts/autoload/steam_bridge.gd`).
3. Steam'den dağıtılan sürümde `steam_appid.txt` gerekmez (Steam kendisi verir).

## 3. Başarımlar
Steamworks → **Stats & Achievements** → her satır için `docs/STEAM_ACHIEVEMENTS.md` listesindeki kimliği (`ACH_...`),
Türkçe ve İngilizce ad ve açıklamayı gir. Kilitli simgeler için 64×64 JPG gerekir.
Kimlikler oyundakiyle birebir aynı olmalı. Oyunda daha önce açılmış başarımlar ilk Steam açılışında eşitlenir.

## 4. Yükleme (SteamPipe)
1. Steamworks SDK'yı indir, `tools/ContentBuilder/` klasörünü kullan.
2. GitHub Releases'teki Windows, Linux ve macOS zip'lerini aç: `content/windows`, `content/linux`, `content/macos`.
3. `tools/steam/app_build.vdf` ve `depot_*.vdf` dosyalarındaki `APPID` / `DEPOTID` değerlerini kendi numaralarınla değiştir.
4. `steamcmd +login <kullanıcı> +run_app_build ../scripts/app_build.vdf +quit`
5. Steamworks → Builds: yüklenen yapıyı "default" dalına al.

## 5. Fragman
Oyunun içinden 45 saniyelik bir kamera turu kaydedilir (10 sahne + kapanış kartı), arayüz yoktur:

```
godot --path . --write-movie fragman.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn
```

Kendi bilgisayarında (ekran kartıyla) çalıştır: yaklaşık 2-3 dakikada `fragman.avi` çıkar. Kurgu programında müzik ve
yazılarla birleştir. Çekim listesi: `tools/trailer/trailer.gd`.

## 6. Steam Deck
- Kol desteği tam: bütün eylemler, menüler, mini oyunlar ve foto modu; ekrandaki ipuçları kol düğmelerine döner.
- Önerilen ayarlar: Grafik kalitesi **Orta**, altyazı boyutu **%120**.
- Linux sürümü Deck'te doğrudan çalışır.

## 7. macOS
Sürüm universal olarak dışa aktarılır (Intel ve Apple Silicon'da doğal çalışır) ve yalnızca ad-hoc imzalıdır.
İlk açılışta: sağ tık → **Aç**. Steam'den dağıtımda uyarı çıkmaz. İleride Apple Developer hesabıyla imzalanıp
noter onayı alınabilir (`export_presets.cfg` → macOS → codesign / notarization).
