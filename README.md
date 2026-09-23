# Gerçek Tarih Bu Değil · Not a History Game

Birinci şahıs, Monty Python tarzı bir zaman yolculuğu komedisi. Emekli komşusunun koli bandıyla tutturulmuş zaman makinesine binen bir belgesel bağımlısı, **1453 İstanbul kuşatmasının** ortasına düşer ve "gelecekten gelen bilgisiyle" Fatih Sultan Mehmet'e yardım etmeye çalışır. Üstünde 400 yıl erken bir fes, elinde bir mektup, yolu ise belki Bizans'tan geçiyor.

*A first-person, Monty Python-style time travel comedy. First episode: the 1453 siege of Constantinople.*

![Hikmet'in garajı](docs/screenshots/02_giris.png)

## Oynamak

**Durum:** Bölüm 1 (Zamanatör) baştan sona oynanabilir: açılış, kostüm, çanta (10 eşyadan 5), Telsiz-Kumanda, 1453 → 14:53 paneli, süreli karar, 3 farklı sonuç ve akış şeması.

1. **Godot 4.4**'ü indir: <https://godotengine.org/download> (standart sürüm, kurulum gerektirmez).
2. Bu repoyu bilgisayarına indir (GitHub Desktop → *Clone repository* ya da *Code → Download ZIP*).
3. Godot'u aç → **Import** → repodaki `project.godot` dosyasını seç → **Import & Edit**.
4. **F5** (ya da sağ üstteki ▶) ile oyna.

İlk açılışta Godot projeyi içe aktarırken birkaç saniye bekler; bu normal.

### Kontroller
| Tuş | Eylem |
|-----|-------|
| WASD / oklar | Yürü |
| Fare | Bak |
| Shift | Koş |
| E | Etkileşim / diyaloğu ilerlet |
| H | Fesi tak / çıkar |
| Tab | Çanta (1–5 ile eşyayı geri koy) |
| R (3 sn basılı) | Kırmızı düğme (Telsiz-Kumanda'dan sonra) |
| 1 / 2 | Seçimler |
| Esc | Duraklat (L: dil, Q: çık) |
| L | Başlık ekranında dil değiştir (Türkçe / English) |

## Belgeler
- **Oyun yapısı (Detroit tarzı: 3 karakter, 16 bölüm, akış şemaları, 357 final kombinasyonu):** [docs/CHAPTERS.md](docs/CHAPTERS.md)
- **Tasarım belgesi:** [docs/GDD.md](docs/GDD.md)
- **Hikaye kalite kontrolü:** [docs/STORY_REVIEW.md](docs/STORY_REVIEW.md)
- **Tolga'nın 1453 dalları ve dünya sonuçları:** [docs/STORY_BRANCHES.md](docs/STORY_BRANCHES.md)
- **Eşya tepki matrisi:** [docs/ITEM_REACTIONS.md](docs/ITEM_REACTIONS.md) (260 tepki + seçim/son matrisi)

## Proje yapısı
```
project.godot            Godot 4.4, GL Compatibility (web'e de çıkabilir)
scenes/main.tscn         Bölüm 1 sahnesi
scripts/
  chapter1.gd            Bölüm 1 akışı (diyaloglar, aşamalar, sonlar, akış şeması)
  autoload/game_state.gd Bayraklar, göstergeler, meta kayıt, tuş haritası
  level/garage.gd        Garaj (bütün geometri kodla kurulur)
  level/items.gd         10 eşyanın modelleri
  level/props.gd         Low-poly parça yardımcıları
  npc/hikmet.gd          Hikmet Amca
  player/player.gd       Birinci şahıs oyuncu
  ui/                    Arayüz, akış şeması, fes püskülü, mırıltı sesi
i18n/strings.csv         Bütün metinler (keys, tr, en)
tests/run_tests.sh       Bölüm 1'i üç yoldan otomatik oynatan test
docs/                    Tasarım belgeleri ve ekran görüntüleri
```

**Görseller:** Şu an bütün modeller kodla üretilen low-poly şekillerdir (harici dosya yok). Portreler, ikonlar ve dokular geldikçe `assets/art/` klasörüne eklenecek.

## Testler
```bash
GODOT=/path/to/godot tests/run_tests.sh
```
Bölüm 1'i ekransız olarak üç yoldan oynatır (Hikmet tekme atar → 1.1, Tolga tekme atar → 1.2, kırmızı düğme → 1.3) ve sonuçları doğrular.

Ekran görüntülerini yeniden üretmek için:
```bash
godot --path . --rendering-driver opengl3 -- --shots=docs/screenshots
```
