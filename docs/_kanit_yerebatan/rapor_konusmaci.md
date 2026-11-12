# Rapor: Eudokia ve Yakovos'a ayrı konuşmacı kimliği

Durum: **DÜZELDİ** (kimlikler açıldı, bağlandı; ses dosyası üretilmedi).

## Dokunulan dosyalar
| Dosya | Değişiklik |
|---|---|
| `scripts/chapter44b.gd` | Eudokia: `eudokia.set_meta("spk")` ve `D44B_E_01/02/03/BACK/BLAB/KEEP` `hud.say` çağrıları → `SPK_EUDOKIA`. Yakovos: `_make_yakovos` meta ve 17 `D44B_Y_*` çağrısı → `SPK_YAKOVOS`. |
| `scripts/chapter25.gd` | `_cistern_neighbor`: meta ve `D25_E_CISTERN_1/2` çağrısı → `SPK_EUDOKIA` (konuşan kişi kodda Bölüm 44'ün kuyusundan gelen Eudokia, doğrulandı). |
| `scripts/ui/hud.gd` | Renk tablosuna `SPK_YAKOVOS` (Balıkçı rengi `a8c0d0`; Eudokia'nın tabloda rengi yoktu, öyle kaldı). `VOICE` perde tablosuna `SPK_EUDOKIA: 215.0` (Kadın ile aynı; Yakovos'un da tabloda girdisi yoktu, öyle kaldı). |
| `scripts/ui/portrait_looks.gd` | `SPK_EUDOKIA` / `SPK_YAKOVOS` için Kadın / Balıkçı görünümünün aynısı. |
| `i18n/strings.csv` | `SPK_EUDOKIA,Kadın,Woman`; `SPK_YAKOVOS,Balıkçı,The fishmonger` (görünen ad değişmedi; yalnız 2 satır eklendi, LF korundu). |
| `docs/voice/cast.json`, `cast_en.json` | İki girdi: `tarif`, `gender`, `age`, geçici `same_as` (`SPK_WOMAN_BYZ` / `SPK_FISHMONGER`). |
| `docs/voice/VOICE_MAP.csv` | 25 satırın `konusmaci` değeri (CRLF korundu). |

## Kimliği değişen anahtarlar
- **Eudokia: 8** — `D44B_E_01, _02, _03, _BACK, _BLAB, _KEEP`, `D25_E_CISTERN_1, _2`.
- **Yakovos: 17** — `D44B_Y_*` (01–05, 04_KID, QUAKE, TORCH, LAMP, RESCUE, RESCUE_2, STONE, MEDUSA, BUCKET, BUCKET_KID, BLAB, KEEP).

Başka bölümlerdeki `SPK_WOMAN_BYZ` / `SPK_FISHMONGER` kullanımlarına dokunulmadı.

## Denetimler
- `check_keys`: 6904 anahtar, 0 sorun · `check_speakers`: PASS · `check_voice_rules`: PASS (9783 anahtar) · `check_inline`: PASS (723 anahtar).
- Ayrıştırma: `PARSECHECK PASS scripts=250`.
- Başsız: 44b `""`, blab, dark, kid, nophone, hit — hepsi `AUTOTEST PASS`; 25 `""`, cistern, cistern_blab — PASS; 24 — PASS. Yasak satırlar (SCRIPT ERROR, WARN_*, *AUDIT, WALKTHRU, JOURNEY_*): hepsinde 0.
- Ses dosyası olmayan replik testte hata vermedi (log'larda yalnız çıkışta bellek sızıntısı ve `user://house_cache` uyarıları var; değişiklikle ilgisiz).

## Yöneticinin ses için doldurması gereken yerler
- `docs/voice/cast.json`: `SPK_EUDOKIA`, `SPK_YAKOVOS` — `same_as` yerine `voice_id`/`voice_name`/`stability`/`similarity`/`style`/`design`.
- `docs/voice/cast_en.json`: aynı iki girdi (İngilizce ses).
- Ses üretimi `VOICE_MAP.csv` anahtarları üzerinden: 25 anahtar yukarıda.

## Emin olamadıklarım / notlar
- `MESAFE.csv` depoda yok; `INLINE.json` ve `tests/check_speakers.py` bu anahtarlarda tablo tutmuyor → dokunulmadı.
- `tools/voice_map.py` konuşmacıyı koddan okur; yeniden üretilirse yeni kimlikleri kendisi alır (çalıştırılmadı).
- `docs/voice/design/design.json` ve `SPEAKERS_SEEN.csv` bu anahtarları içermiyor; dokunulmadı.
- `street_eye.gd` `SPK_GROUP` (sokak tepki öbeği) ve `rig.gd` `_STERN` listesine eklenmedi; iki karakter sokak insanı değil, "spk" işaretli hikâye kişisi.
- Ekran karesi / RINFO alınmadı: görsel değişiklik yok (renk, görünüm, ad aynen kopyalandı) — KANITSIZ değil, BAKILMADI.
- Testlerde ilk denemede yanlışlıkla 10 koşu birden başlatıldı (en çok 2 kuralı); durdurulup 2'şerli yeniden koşuldu, sonuçlar yeniden koşudan.
