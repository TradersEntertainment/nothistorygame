# Oynanışı epik yapmak

Görsel yenileme yerine oynanışı güçlendirme planı. Her aşama ayrı bir sürümdür.

| Aşama | İçerik | Sürüm | Durum |
|---|---|---|---|
| 1 | Vuruş hissi: Fx (donma, ağır çekim, sarsıntı, görüş darbesi, ekran kenarı), müzik yoğunluğu, vurgu sesleri | 0.41.0 | bitti |
| 2 | Gerçek risk: oyuncu canı, hikâye düellolarında yenilgi, siper cezası. Ölüm yok, ceza var | 0.42.0 | bitti |
| 3 | Doruk sahneleri oynanabilir savaş: dalga motoru, Bölüm 26 gedik savunması, 26o merdiven ve sancak, 20 Şahi atışı | 0.43.0 | |
| 4 | Dövüş derinliği: tekme, hedef değiştirme, bitirici darbe; arenada top dalgası ve değiştiriciler | 0.44.0 | |

## Fx (`scripts/autoload/fx.gd`)

| Çağrı | Ne yapar | Nerede kullanılıyor |
|---|---|---|
| `Fx.hitstop(sec)` | Zaman bir anlığına neredeyse durur (vuruş "oturur") | Parry 0,08 sn; isabet 0,06 sn; son darbe 0,09 sn; yakına düşen gülle |
| `Fx.slowmo(scale, sec, ease)` | Ağır çekim, sonra tabana yumuşak dönüş; sesler de hafif yavaşlar | Parry, son darbe, son rakip düşünce, topla isabet |
| `Fx.trauma(a)` | Birikimli sarsıntı (`player.shake` üzerinden) | Gülle, isabet |
| `Fx.fov_punch(deg, sec)` | Görüş açısı bir an daralır | Son darbe, parry, top atışı |
| `Fx.edge(renk, güç, sec)` | Ekran kenarı rengi | Kırmızı: hasar ve ok. Altın: parry. Beyaz: top ve Şahi parlaması |

Zaman ölçeği:
- Bölümler otomatik testte `Engine.time_scale`'i 2,5–3'e çeker. Fx bu değeri taban sayar ve etkiyi onun üstüne çarpar.
- Fx'in yazmadığı bir değer görülürse yeni taban odur. Sahne değişince bütün etkiler sıfırlanır.
- Hiçbir etki 6 sn'den uzun sürmez. Sürerse bekçi sıfırlar ve testte `WARN_FX_STUCK` yazılır; test takımı bunu hata sayar.
- `tests/fx_check.tscn` 1× ve 3× tabanda dönüşü ve tabanın üzerine yazılmasını denetler.

Ayar `fx` (0–1, "Ağır çekim ve sarsıntı"): 0'da donma, ağır çekim, sarsıntı ve görüş darbesi kapanır. Kenar rengi (hasar uyarısı) yarım güçte kalır.

## Müzik (`scripts/autoload/audio.gd`)

`Audio.intensity(0..3)` aynı bölümün parçasından bir üst gerilim parçasına geçer:
- Sırası: `walls_night`, `tension`, `confrontation`, `chase`. Ordugâh ve Bizans parçaları için de aynı sıra kullanılır.
- Dalga başında 1–2, düelloda 3, dalga püskürtülünce 0.

`Audio.stinger(ad)`:
- Mevcut seslerden kısa bir vurgu yapar: `parry`, `hit`, `hurt`, `kill`, `victory`, `cannon`, `banner`, `heart`, `warn`.
- Çalarken müziği bir an kısar; bunu `Music` veri yolundaki yükseltici yapar (`Audio.duck`).

## Can ve yenilgi (Aşama 2)

**Oyuncu canı** (`Player.hp`, 100):
- `player.hurt(miktar, kaynak)`: Can düşer, ekran kenarı kızarır, kamera darbenin geldiği yana yatar.
- Can 0'a inince `player.down()` çalışır:
  - Oyuncu ölmez. Kamera yere iner, ekran kızıl kararır, kalp atışı duyulur, Nihat telsizden takılır.
  - 40 canla ayağa kalkılır. `player.downs` bir artar ve `downed` sinyali yayınlanır.
- Can, son darbeden 4 sn sonra saniyede 8 dolar (dövüşte dolmaz).
- Can 25'in altındayken oyuncu %20 yavaş yürür ve kalp atışı duyulur.
- Can eksikken sol altta ince bir can şeridi görünür.

**Hasar kaynakları:**

| Kaynak | Hasar | Bölüm |
|---|---|---|
| Siperde değilken Şahi güllesi | 40 | 20, 26 |
| Siperde değilken ok yaylımı | 30 | 22o, 26o |
| Kılıç darbesi (rakip `damage`) | 18 | 20, 22o, 26, 26o |

**Hikâye düellosu** (`StoryDuel.fight`):
- Düellonun canı oyuncunun canıdır (`Duel.link_player`). Rakipler 80 can taşır ve 18 hasar verir.
- Can biterse düello kaybedilir, oyuncu yere düşer, rakipler geri çekilir. Süre dolarsa da kaybedilmiş sayılır.
- Dönüş değeri: `{won, hits_taken, parries, kills, time}`.

**Yenilginin sonucu bozduğu yerler:**

| Bölüm | Yenilgi | Sonuç |
|---|---|---|
| 20 Gedik | Düello kaybı ya da iki kez yere düşme: gedik sabaha yetişmez | 20.3 |
| 22o Kule | Bir marangoz kulede kalır | 22O.2 |
| 26 Şafak (Bizans) | Tolga yerdeyken tüfekçi ateş eder, uyaramaz: saldırı püskürtülemez | 26.3 kapanır |
| 26o Son hücum | Fatih'in girişi kaçar, kare yok | 26.2 |

**Testler:**
- `--autotest=lose` (20, 22o, 26o) ve `--autotest=hold_lose` (26): bot düelloda savunmasız durur.
- Beklenen kötü sonuç, `player.downs >= 1` ve kaybedilmiş düello denetlenir.
