# Niko'nun vedası (Bölüm 24) ve Tolga'nın `D9_T_DEPORTED` repliği: rapor

Sahibin rapordaki sorulara verdiği cevaplar uygulandı: soru 1 (`D4B_N_02_NOFEZ` kalır), soru 4 (`D9_T_DEPORTED` düzeltilir),
soru 8 (Bölüm 24'ün sonuna veda eklenir). Ses üretilmedi. Değişen dosyalar yalnız görevde sayılanlar.

## 1. Replikler (TR / EN ve espri notu)

| Anahtar | Konuşan | TR | EN |
|---|---|---|---|
| `D24_NK_VEDA` (yeni) | Niko | Ben anneme, Petrion'a. Bu da geçer, Tolga. …Geçer. | Petrion. My mother's. It'll blow over, Tolga. …It'll blow over. |
| `D24_NK_VEDA_LATE` (yeni, varyant eşi) | Niko | Ben anneme, Petrion'a. …Geçer. | Petrion. My mother's. …It'll blow over. |
| `D9_T_DEPORTED` (değişti) | Tolga | Niko sabah beni zindandan çıkardı: 'Sınır dışı.' **Kapıya kadar götürdü. Gerisini bana bıraktı.** Şimdi Osmanlı ordugâhındayım. Formum hâlâ açık. | Niko let me out of the dungeon this morning: 'Deported.' **He saw me to the gate. Past that, I wasn't covered.** Now I'm in the Ottoman camp. My form's still open. |

Eski `D9_T_DEPORTED`: "…Kapıdan itti. …" / "…He pushed me through the gate. …". Cümlenin geri kalanı aynen kaldı.

**Notlar:**
- **`D24_NK_VEDA`, TR.** "Bu da geçer" Türkçenin eski avuntu sözü; Niko'nun Türkçesi kayıkçılardan, onun ağzına oturuyor. İkinci söyleyişte "Bu da" düşüyor: söz yarıya iniyor, inancı da (yön belgesindeki "Geçer, gittikçe azalan bir inançla"). "Ben anneme" fiilsiz bir gidiş bildirimi, kahvede kalkan adamın lafı. Bağırmıyor, iki kısa cümle ve bir tekrar.
- **`D24_NK_VEDA`, EN.** "Blow over" fırtınanın deyimi. Selin ve sağanağın ortasında hem düz anlamıyla (yağmur dinecek) hem kuşatma için umutla söyleniyor. Tekrarı daha düz okunur. Çeviri değil: Türkçedeki atasözü yerine İngilizcede aynı işi gören hava deyimi kondu.
- **`D24_NK_VEDA_LATE`.** `D24_NK_LATE` zaten "Kurtulur, Tolga. Kurtulur." tekrarıyla bitiyor. Ardından bir de "Bu da geçer, Tolga. …Geçer." gelirse aynı kalıp üst üste düşer. Bu yüzden çocuk kaçtığında geriye tek bir "…Geçer." kalıyor: umut çocuğa harcandı. İngilizcesi de tek "…It'll blow over.", adıyla seslenmeden.
- **`D9_T_DEPORTED`, TR.** Satır `D8Y_NIKO_DEP` ("Kapıya kadar ben götürüyorum, ötesi Tanrı'ya emanet") ve yön B ile artık çelişmiyor. "Gerisini bana bıraktı" Tolga'nın kendine acıyan kuru mizahı: iki ordu arasındaki yol, devredilen bir iş gibi anlatılıyor.
- **`D9_T_DEPORTED`, EN.** "Past that, I wasn't covered." Tolga'nın sigortacı ağzı: poliçe kapıda bitiyor.
- **Uzunluk.** `VEDA` İngilizcesi Türkçesinin 1,26 katı, `VEDA_LATE` 1,30 katı (sınır ±%30).
- Tolga vedaya cevap vermiyor. Sonraki var olan replik (`D24_T_FOG`, sis gününde) aynen akıyor.

## 2. Ne nereye eklendi (dosya:satır)

**`scripts/chapter24.gd`**
- `:463`: `_run()` içinde `await _kid_step()` ile `await _fog_day()` arasına `await _niko_veda()`.
- `:831-852`: yeni `_niko_veda()`. Yalnız Niko varsa ve görünürse çalışır.
  - Niko Tolga'ya döner ve `:840` vedayı söyler: çocuk kurtarıldıysa `D24_NK_VEDA`, kaçtıysa `D24_NK_VEDA_LATE`.
  - Sonra var olan `Person.leave()` ile kuzeye yürür (şehrin içi, alayın geldiği cadde; Ayasofya ve Haliç tarafı): 14 m, yaklaşık 2,2 m/sn. Yürüyüş beklenmez.
  - Bakış uzaklaşan Niko'yu en çok 1,4 sn izler (sınır 2 sn).
  - Ardından var olan `_fog_day()` kararması (0,8 sn) başlar. Niko kararma sırasında da yürüyor, birden yok olmuyor. Var olan `niko.visible = false` ("ertesi gün surda") onu siyah ekranın altında gizler.
- Başka satır değişmedi: süre, sayaç, sonuç, bot akışı ve öbür replikler aynı.

**Veri dosyaları**

| Dosya | Satır | Ne |
|---|---|---|
| `i18n/strings.csv` | 1197 | `D9_T_DEPORTED` metni |
| | 7660, 7661 | `D24_NK_VEDA`, `D24_NK_VEDA_LATE` eklendi |
| | | LF ve tırnaklama korundu; yalnız bu 3 satır |
| `docs/voice/VOICE_MAP.csv` | 2641 | `D9_T_DEPORTED` (`tr`, `en`) |
| | 4460, 4461 | iki yeni satır: `SPK_NIKO`, ton boş, `ton_elle=0`, kaynak `kod` |
| | | CRLF korundu |
| `docs/voice/MESAFE.csv` | 2543, 2544 | `D24_NK_VEDA(_LATE),yakin,3`, kanıt `chapter24.gd:840` |
| | 4040 | `D4B_N_02_NOFEZ,uzak,12` (soru 1), `D4B_N_02` ile aynı sınıf ve metre |
| `docs/voice/INLINE.json` | 1617-1622 | iki yeni İngilizce satır içi okuma (aşağıda) |
| `docs/voice/REGEN_NIKO_TR.txt` | +2 | `D24_NK_VEDA`, `D24_NK_VEDA_LATE` (85 anahtar) |
| `docs/voice/REGEN_NIKO_EN.txt` | +2 | aynı iki anahtar (84 anahtar) |
| `docs/voice/REGEN_NIKO_DIGER_TR.txt`, `_EN.txt` | | `D9_T_DEPORTED` (ikisinde de 1 anahtar) |
| `docs/_niko/once_sonra.md` | | Bölüm 24'e "Veda" alt başlığı; 8Y'nin altına "Bölüm 9" alt başlığı (`D9_T_DEPORTED`); baştaki sayılar |
| `docs/_niko/niko_b.csv` | | üç satır eklendi |

Ek açıklamalar:
- **VOICE_MAP ton sütunu.** Var olan Niko satırlarının kuralı uygulandı: `tools/voice_map.py`'nin `guess_tone`'u. Satırda ünlem yok ve yalnız bir "…" var, bu yüzden ton boş.
- **INLINE.json.** Bölüm 24'teki bütün Niko satırlarının İngilizce satır içi okuması var, bu ikisine de yazıldı:
  - `[quiet] Petrion. My mother's. [tired] It'll blow over, Tolga. [softly] …It'll blow over.`
  - `[quiet] Petrion. My mother's. [softly] …It'll blow over.`
- `D9_T_DEPORTED` için INLINE girdisi yoktu, eklenmedi.

## 3. Hangi yolda söyleniyor

| Yol | Niko var mı | Veda |
|---|---|---|
| Dost Niko + çocuk kurtarıldı (`niko`, `niko_slow`; gerçek oyunda `niko_friend` + 24.1) | var | `D24_NK_VEDA`, `D24_NK_SAVED`'den sonra |
| Dost Niko + çocuk kaçtı (gerçek oyunda `niko_friend` + 24.2; otomatik testte varyantı yok) | var | `D24_NK_VEDA_LATE`, `D24_NK_LATE`'ten sonra. Sondayla denendi (aşağıda) |
| `""`, `late`, `eclipse` (dost değil) | yok | söylenmez (`niko == null`) |

## 4. Süre

Bölüm 24 ekranlı PACE koşuları, `niko` varyantı. Ölçü, `D24_NK_SAVED`'in başından sis gününe geçişin ölü süresinin başına kadar:

| | Süre |
|---|---|
| ÖNCE | 7,4 sn |
| SONRA | 11,9 sn |
| **Fark** | **+4,5 sn** (sınır 5 sn) |

Hesap: veda satırı sessiz altyazı olarak 3,5 sn tutuyor (`PACE say len=3.5 key=D24_NK_VEDA`), bakış izleme 1,4 sn. İlk denemede izleme 1,6 sn'ydi ve toplam 5,1 sn çıktı; 1,4'e indirildi. Ses dosyası yokken replik sessiz altyazı olarak aktı, hata yok.

## 5. Testler

**Başsız** (`--headless --max-fps 20`). "Yasak" sütunu, görev listesindeki yasak satırların sayısı.

| Koşu | Sonuç | Yasak |
|---|---|---|
| 24 `""` | `AUTOTEST PASS chapter=24 variant= outcome=24.1 … niko=false` | 0 |
| 24 `late` | `AUTOTEST PASS … variant=late outcome=24.2 … niko=false` | 0 |
| 24 `niko` | `AUTOTEST PASS … variant=niko outcome=24.1 stumbles=0 kid=true niko=true steadied=1` | 0 |
| 24 `niko_slow` | `AUTOTEST PASS … variant=niko_slow outcome=24.1 … niko=true steadied=2 kid_t=23.8` | 0 |
| 24 `eclipse` | `AUTOTEST PASS … variant=eclipse outcome=24.1` | 0 |
| 9 `cell` (`D9_T_DEPORTED` buradan geçer: 6b.3) | `AUTOTEST PASS chapter=9 variant=cell … outcome=9.6` | 0 |
| 25 `""` | `AUTOTEST PASS chapter=25 variant= outcome=25.1` | 0 |
| 23 `""` | `AUTOTEST PASS chapter=23 variant= outcome=23.1` | 0 |

- Bölüm 24'ün beş varyantı son kodla koşuldu. 9, 25 ve 23 ilk sürümle koşuldu; `chapter24.gd`'deki sonraki değişiklik o bölümlere dokunmaz.
- **Ekranlı (PACE), `niko`:** SONRA PASS, yasak 0; ÖNCE PASS, yasak 0.
- **Sonda `niko_late`** (depo dışındaki kopyada geçici kanca: `late` dalı `niko_late` için de seçildi):
  - `D24_NK_VEDA_LATE` söylendi (`SAYDIST key=D24_NK_VEDA_LATE`), yasak 0.
  - `AUTOTEST FAIL … outcome=24.2 … niko=true` yalnız beklenen sonuç tablosunda bu uydurma varyantın adı olmadığı için (24.1 bekleniyor).
  - Kanca söküldü: `grep niko_late scripts/chapter24.gd` → 0.
- **Denetimler:**
  - `PARSECHECK PASS scripts=248`
  - `check_keys.py`: anahtar 6772, sorun 0
  - `check_speakers.py`: `SPEAKERCHECK PASS`
  - `check_voice_rules.py`: `VOICERULES PASS (9668 anahtar, 0 sorun)`
  - `check_inline.py`: `INLINECHECK PASS (725 anahtar, 0 sorun)`
  - `check_tween_await.py`: çıkış 0
- **Bilgi (testi düşürmez):** `SAYDIST key=D24_NK_VEDA … d=5.5–5.9`. Otomatik testte oyuncu saçağa gitmediği için Niko 5,5–5,9 m uzakta kalıyor. Aynı uzaklık var olan `D24_NK_SAVED` için de basılıyor; vedanın getirdiği yeni bir şey değil.

## 6. Kareler ve paftalar

**Ham klasörler** (depo dışında):
- `~/is/kare_sonra2`: SONRA, otomatik test.
- `~/is/kare_sonda`: sonda, gerçek oyundaki yer.
- `~/is/kare_once`: ÖNCE.

**Sonda nedir:** otomatik testte bot çocuğu saçağa yürütmüyor (`_on_interact` + ışınlama), oyuncu sedyenin yanında, Niko'nun kuzeyinde kalıyor. Gerçek oyunda ise oyuncu çocuğu saçağa getirdiği için Niko'nun güneydoğusundadır. `sonda_` kareleri bunu gösterir: depo dışındaki kopyada, yalnız `SONDA_GERCEK` ortam değişkeniyle, vedadan hemen önce oyuncu saçağın önüne (2.7, 0, 3.9) konur. Sonda depoya girmedi.

**Paftalar:**
- `docs/_niko/pafta_veda_once_sonra.jpg`
  - ÖNCE `kare_once/t0124`: `SAVED`'den sonra, kararmadan önceki son kare (Niko bekliyor).
  - SONRA `kare_sonra2/D24_NK_VEDA`: veda anı, altyazı görünür.
- `docs/_niko/pafta_sonda_uzaklasma.jpg`:
  - `sonda_D24_NK_VEDA`: veda, saçağın önünde.
  - `sonda_t0128`: yürüyor, sırtı dönük.
  - `sonda_t0132`: uzakta.
  - `sonda_t0137`: kararma başladı, hâlâ yürüyor, küçük.
  - Birden yok olmuyor.
- `docs/_niko/pafta_otomatik_yurume.jpg`:
  - Otomatik test yerleşimi (`kare_sonra2/t0128`, `t0131`, `t0134`).
  - Oyuncu Niko'nun kuzeyinde durduğu için Niko kameraya doğru, yanından geçecek biçimde yürüyor. Bakış onu izliyor.
  - Bu yerleşim yalnız botun ışınlamasından doğuyor. **KISMEN**: gerçek oyunda oyuncu başka bir yerde durursa (örneğin çocuğu saçağa getirdikten sonra caddenin kuzeyine yürüdüyse) Niko yine onun yanından geçer.

## 7. Bakılmayanlar / notlar

- **`.translation` dosyaları.** Godot içe aktarması `i18n/strings.*.translation` dosyalarını yeniden üretti. Önceki Niko işinde olduğu gibi bunlar kayda katılmadı (görev listesinde yok); oyun CSV'den yeniden içe aktarınca yeni anahtarları alır.
- **`docs/_niko/niko_b.csv` içe aktarması.** Godot bu dosyayı da çeviri CSV'si sanıp `docs/_niko/niko_b.*.translation` ve `.import` üretti. Bunlar kayda katılmadı. **ORTAK DOSYA ÖNERİSİ:** `docs/_niko/` altına boş bir `.gdignore` dosyası konursa Godot bu klasörü içe aktarmaz.
- **İngilizce okuma.** İngilizce veda satırının seslendirmeyle süresi bilinmiyor (ses üretilmedi). Kısa bir satır, en çok 3,5 sn civarı beklenir: **KANITSIZ**.
