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
4. `steamcmd +login <kullanıcı> +run_app_build <depo yolu>/tools/steam/app_build.vdf +quit` (tam yol verilir)
5. Steamworks → Builds: yüklenen yapıyı "default" dalına al.

## 5. Fragman ve dikey kısalar (Instagram Reels, TikTok, YouTube Shorts)
Görüntü oyunun içinden kaydedilir; yazılar (altyazı, üst yazı, kanca cümlesi, kapanış kartı) sonradan
`tools/trailer/cut.py` ile basılır. Kayıt "-- clean" ile yazısızdır; satırların zamanı kayıt günlüğüne yazılır.

**1. Sahneli fragman** (soğuk açılış, garaj, kızak, otağ, Nihat'ın uçuşu, kuşatma, büyük top, kapanış):

```
godot --path . --write-movie fragman_tr.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn -- clean > fragman_tr.log
python3 tools/trailer/cut.py trailer fragman_tr.avi fragman_tr.log fragman_tr.mp4      # 16:9, altyazılı
python3 tools/trailer/cut.py shorts  fragman_tr.avi fragman_tr.log kisalar/            # 7 dikey kısa (01-07)
```

**2. Konuşma kesitleri** (Vlad'a Kale Kasko, Giustiniani'ye "kuşatma hariç" poliçe, Madde 9, Model Z-0, ters kürek,
1977'de genç Hikmet, iki tünel tek poliçe, Boğaz gümrüğü): bölümler test botuyla, seslendirme süresince oynanır;
pencere ilk replikle açılır, son replik bitince kapanır (`tools/trailer/montage.gd` SHORT_CLIPS).

```
godot --path . --write-movie kesitler.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/gameplay.tscn -- set=shorts clean > kesitler.log
python3 tools/trailer/cut.py shorts kesitler.avi kesitler.log kisalar/                 # 08-15
```

**3. Oynanış montajı** (kılıç, top, tüfek, kürek, uçuş, şehir, Sonsuz Kuşatma):

```
godot --path . --write-movie oynanis.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/gameplay.tscn -- clean > oynanis.log
python3 tools/trailer/cut.py shorts oynanis.avi oynanis.log kisalar/                   # 16-17
```

Kısa süresi: kart dahil en çok 30 sn (`MAX_TOTAL`). Uzun konuşmada SHORTS'taki `keep` hangi replik gruplarının
kalacağını seçer (ör. `[[0, 1], [3, 4]]`: ilk iki replik, atlama, 4. ve 5. replik); replik ortasından kesilmez. Sınırı
aşan kısa, sığan son repliğin bitişinde kesilir ve uyarı yazılır. `--dry` kesmeden süreleri ve kalan replikleri
listeler. Son replikten sonra 0,4 sn donuk kare, sonra kart gelir. Altyazıda baştaki sahne notu ("(Daktiloya yazar)")
yazılmaz.

Uzun kayıt bölünebilir (bulut oturumunda arka plan işi 2 saatte durur): fragman `-- clean only=boom,end` ile kalan
bölümlerden sürdürülür ve `cut.py trailer fragman_tr.avi fragman_tr.log fragman_tr.mp4 --append fragman_tr2.avi
fragman_tr2.log` ile eklenir; kesitler `only=0,1,2` gibi parçalarla çekilir. Yarıda kesilen kaydın açık kesiti,
günlükteki son olayda kapanmış sayılır.

İngilizce: kayıt argümanlarına `en` eklenir, günlük adı `_en.log` biter. Ekran kartlı bilgisayarda birkaç dakika sürer.
Ekran kartsız (bulut, Xvfb + llvmpipe) da çalışır ama yavaştır (kuşatma dünyası kare başına birkaç saniye): orada
`CAPTURE_AA=fxaa` ortam değişkeniyle 4x MSAA yerine FXAA kullanılır, görüntü farkı küçültmede kaybolur.

Dikey kısanın yerleşimi (1080x1920): üstte kanca cümlesi, ortada kaydın ortasından 1080x1080 kare kesit (gerekirse
`x` ile kaydırılır), arkada aynı görüntü bulanık, altta konuşanın adı ve büyük altyazı, sonda 2,6 sn kapanış kartı
(logo, "27 final · kuşatma iki taraftan", "Steam'de istek listene ekle"). Ses -14 LUFS'a eşitlenir. Kanca cümleleri
ve hangi kesitin hangi kısaya gittiği `cut.py` başındaki SHORTS listesindedir.

## 6. Steam Deck
- Kol desteği tam: bütün eylemler, menüler, mini oyunlar ve foto modu; ekrandaki ipuçları kol düğmelerine döner.
- Önerilen ayarlar: Grafik kalitesi **Orta**, altyazı boyutu **%120**.
- Linux sürümü Deck'te doğrudan çalışır.

## 7. macOS
Sürüm universal olarak dışa aktarılır (Intel ve Apple Silicon'da doğal çalışır) ve yalnızca ad-hoc imzalıdır.
İlk açılışta: sağ tık → **Aç**. Steam'den dağıtımda uyarı çıkmaz. İleride Apple Developer hesabıyla imzalanıp
noter onayı alınabilir (`export_presets.cfg` → macOS → codesign / notarization).
