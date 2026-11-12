# Mesafe haritası — Grup C (dilim 6, `D<n>O_*` Osmanlı dalları)

Kapsam: `ceviri_dilim.py 6` çıktısının konuşmacısı dolu 1104 satırı (D10O, D17O–D43O; 24 bölüm). Her satır için betikte
anahtarın geçtiği yer bulundu; `kanit` sütunu `dosya:satır + sahne notu` içerir (boş satır yok). Oyun dosyalarına ve
`VOICE_MAP.csv`'ye dokunulmadı; ses üretilmedi.

## Sınıf sayıları

| sınıf | adet |
|---|---|
| `yakin` | 450 |
| `yakin_yuksek` | 244 |
| `ic_ses` | 167 |
| `uzak` | 110 |
| `telsiz` | 93 |
| `fisilti` | 21 |
| `belirsiz` | 19 |

## Yöntem ve varsayımlar

- Konum kanıtı: sahne kurulumundaki `position`/`global_position` sabitleri (Tolga ile konuşan arası uzaklık),
  `Stage.approach`/`walk_player` yaklaşma mesafeleri, `hud.bark` ve `hud.say` ayrımı, `set_meta("afar")`, `say_chain`.
- Nihat (1977 Büro) kuşatma bölümlerinde sahnede bedensel olarak yok → hep `telsiz`. 43O'daki "görünmez Nihat" de telsiz.
- Tolga'nın kendi kendine yorumları (`_t(...)`, anlatı, parantezli iç ses, vurulunca tepkiler) → `ic_ses`. Vurulma/ünlem
  tepkileri (ör. `D22O_T_ARROW_1`, `D30O_T_PANIC`) kimseye seslenmediği için `ic_ses`; `[shouting]` ile çelişmeleri aşağıda.
- `yakin_yuksek`: savaş/top/yangın gürültüsü içinde ya da emir/panik verirken 8 m'den yakın konuşma.
- `uzak`: ≥ ~8 m ya da yükseklik/engel farkı (tırmanma, sur dibi, kıyıdan gemiye, tellal, kule tepesi).
- Fatih ve İmparator bağırmaz: uzak sayıldıkları yerde `not` sütununa "vakur, taşan ses" yazıldı.
- Dinamik anahtarlar (örn. `"D20O_U_HIT_%d" % n`, `_key("h_"+k)`) kullanıldıkları satıra bağlandı; kanıtta belirtildi.
- Aynı anahtar birden çok yerde geçiyorsa ilk/en sık kullanım alındı (`D10O_A_SHOUT`: sahnede kapıdan 14 m `say` → `uzak`).
- Lağım (D21O) ve gece devriyesi (D19O, D17O gözcülük) konuşmaları, kodda "bağırma"/"sur duyar" kanıtı ve `ton=[whispers]` ile uyumlu olarak `fisilti`.

## `ton` sütunuyla çelişenler

### 1. `[shouting]` ama sahnede bağırmaya gerek yok (yakın / iç ses / telsiz / fısıltı)
Çoğu Tolga'nın kendi kendine ünlemli tepkisi (ok/kova/çadır); bağırma etiketi mesafe açısından gereksiz.
| anahtar | VOICE_MAP.ton | mesafe | metre |
|---|---|---|---|
| `D17O_T_POUR_3` | [shouting] | ic_ses | - |
| `D22O_T_ARROW_1` | [shouting] | ic_ses | - |
| `D24O_S_1_JOKE` | [shouting] | yakin | 2 |
| `D24O_T_TIED_1` | [shouting] | ic_ses | - |
| `D24O_T_TIED_1_NOFEZ` | [shouting] | ic_ses | - |
| `D24O_T_TIED_2` | [shouting] | ic_ses | - |
| `D24O_T_TIED_3` | [shouting] | ic_ses | - |
| `D24O_K_LOST_0` | [shouting] | yakin | 2 |
| `D29O_B_END` | [shouting] | yakin | 5 |
| `D41O_P_FIN_THRUST` | [shouting] | yakin | 2.5 |
| `D37O_T_BURN` | [shouting] | ic_ses | - |
| `D38O_S2_02` | [shouting] | yakin | 4.6 |
| `D31O_AZ_01` | [shouting] | yakin | 1.5 |
| `D34O_U_HIT_BAD` | [shouting] | yakin | 2.2 |
| `D38O_T_ARROW_HIT` | [shouting] | ic_ses | - |
| `D38O_T_STONE_HIT` | [shouting] | ic_ses | - |
| `D38O_T_OIL_HIT` | [shouting] | ic_ses | - |
| `D20O_U_01_ULIGHTER` | [shouting] | yakin | 3.4 |
| `D30O_T_PANIC` | [shouting] | ic_ses | - |
| `D43O_T_HIT_1` | [shouting] | ic_ses | - |
| `D43O_T_HIT_2` | [shouting] | ic_ses | - |
| `D31O_AZ_01_BLAK` | [shouting] | yakin | 1.5 |

### 2. Etiketsiz (boş `ton`) ama uzaktan seslenme (gerçekten bağırmalı)
| anahtar | VOICE_MAP.ton | mesafe | metre |
|---|---|---|---|
| `D17O_A_BURNED` | (boş) | uzak | 13 |
| `D22O_H_SAFE` | (boş) | uzak | 12 |
| `D28O_F_01` | (boş) | uzak | 9.5 |
| `D28O_F_02` | (boş) | uzak | 9.5 |
| `D32O_AZ_SAFE` | (boş) | uzak | 10 |
| `D32O_F_01` | (boş) | uzak | 8 |
| `D32O_F_02` | (boş) | uzak | 8 |
| `D41O_H_LADDER_DRY` | (boş) | uzak | 8 |
| `D41O_H_LADDER_TOP` | (boş) | uzak | 8 |
| `D41O_H_LADDER_TOP_2` | (boş) | uzak | 8 |
| `D38O_R_03` | (boş) | uzak | 16 |
| `D38O_R_UP` | (boş) | uzak | 16 |
| `D38O_R_BACK` | (boş) | uzak | 16 |
| `D39O_C_FLAG_OK` | (boş) | uzak | 25 |
| `D39O_C_FLAG_WRONG` | (boş) | uzak | 25 |
| `D39O_C_LATE` | (boş) | uzak | 15 |
| `D31O_CARP_KNOT_OK` | (boş) | uzak | 9 |
| `D31O_CARP_LATE` | (boş) | uzak | 9 |
| `D33O_M_FALL` | (boş) | uzak | 12 |
| `D33O_M_WATER` | (boş) | uzak | 15 |
| `D33O_Z_01` | (boş) | uzak | 22 |
| `D33O_H_01` | (boş) | uzak | 22 |
| `D33O_M_STONE_1` | (boş) | uzak | 20 |
| `D33O_M_STONE_BAD` | (boş) | uzak | 20 |
| `D33O_M_DONE` | (boş) | uzak | 20 |
| `D33O_M_DONE_LATE` | (boş) | uzak | 20 |
| `D33O_F_01` | (boş) | uzak | 20 |
| `D34O_M_01` | (boş) | uzak | 21 |
| `D34O_M_BIG` | (boş) | uzak | 21 |
| `D34O_M_CRACK` | (boş) | uzak | 21 |
| `D34O_M_GOOD` | (boş) | uzak | 21 |
| `D34O_M_WRONG` | (boş) | uzak | 21 |
| `D34O_M_REJ_GOOD` | (boş) | uzak | 21 |
| `D34O_M_STOP` | (boş) | uzak | 21 |
| `D34O_M_DONE` | (boş) | uzak | 21 |
| `D34O_F_01` | (boş) | uzak | 14 |
| `D34O_U_F1` | (boş) | uzak | 8 |
| `D34O_F_02` | (boş) | uzak | 14 |
| `D34O_U_F2` | (boş) | uzak | 8 |
| `D34O_F_03` | (boş) | uzak | 14 |
| `D35O_D_LASH_OK` | (boş) | uzak | 10 |
| `D35O_D_LASH_BAD` | (boş) | uzak | 10 |
| `D35O_K_01` | (boş) | uzak | 40 |
| `D35O_U_K1` | (boş) | uzak | 37 |
| `D35O_K_02` | (boş) | uzak | 40 |
| `D22O_HU_CARRY` | (boş) | uzak | 9 |
| `D33O_F_EDIRNE_HIZIR` | (boş) | uzak | 20 |
| `D33O_F_EDIRNE_TIME` | (boş) | uzak | 20 |
| `D33O_F_EDIRNE_GREEK` | (boş) | uzak | 20 |

### 3. `[whispers]` ama fısıltı/iç ses değil
| anahtar | VOICE_MAP.ton | mesafe | metre |
|---|---|---|---|
| `D21O_D_PULLED` | [whispers] | yakin | 1.5 |
| `D19O_T_TELL` | [whispers] | yakin_yuksek | 5 |
| `D43O_N_WHISPER` | [whispers] | telsiz | - |
| `D43O_N_HAND` | [whispers] | telsiz | - |
| `D43O_N_STATIC` | [whispers] | telsiz | - |
| `D43O_N_END_BAD` | [whispers] | telsiz | - |

### 4. Etiketsiz ama fısıltı
| anahtar | VOICE_MAP.ton | mesafe | metre |
|---|---|---|---|
| `D21O_T_01` | (boş) | fisilti | 1.5 |

## Belirsizler (19)

- `D17O_A_DAWN` — chapter17o.gd:842 şafak kartından sonra oyuncu ışınlanmıyor; Topçu-Tolga uzaklığı oyuncunun kıyıda nerede olduğuna bağlı — konum bağlı değil
- `D17O_A_DAWN_SAVED` — chapter17o.gd:842 şafak kartından sonra oyuncu ışınlanmıyor; Topçu-Tolga uzaklığı oyuncunun kıyıda nerede olduğuna bağlı — konum bağlı değil
- `D25O_N_VIGIL` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_H_1` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_T_1` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_H_2` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_T_LEB` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_H_LEB` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_T_WATER` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_H_WATER` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_T_SIT` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_H_SIT` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_H_3` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_T_END` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D25O_N_END` — docs/OTTOMAN_STORY.md:445 "D25O_H_* emekliye ayrılır": ateş başı sahnesi (_vigil) kaldırıldı; hiçbir betikte çağrılmıyor — kod yok. İçerik: ateş başında yakın sohbet (N_*: telsiz, T_END/T_SIT: ic_ses); 32o'da yedek ise oradaki konuma bakılmalı
- `D33O_S_LADDER` — chapter33o.gd taraması: anahtar hiçbir betikte geçmiyor (dinamik üretim de yok) — kullanılmayan/yedek satır; içerik Tolga iç sesi (ic_ses) ya da asker uyarısı
- `D33O_T_CLIMB` — chapter33o.gd taraması: anahtar hiçbir betikte geçmiyor (dinamik üretim de yok) — kullanılmayan/yedek satır; içerik Tolga iç sesi (ic_ses) ya da asker uyarısı
- `D33O_T_03` — chapter33o.gd taraması: anahtar hiçbir betikte geçmiyor (dinamik üretim de yok) — kullanılmayan/yedek satır; içerik Tolga iç sesi (ic_ses) ya da asker uyarısı
- `D33O_T_WATER` — chapter33o.gd taraması: anahtar hiçbir betikte geçmiyor (dinamik üretim de yok) — kullanılmayan/yedek satır; içerik Tolga iç sesi (ic_ses) ya da asker uyarısı

## Konumu koddan kesin çıkmayan (yaklaşık) sınıflar

`not` sütununda "mesafe tahmini / konum bağlı değil / yaklaşık" geçen satırlar: oyuncunun serbest dolaştığı evreler
(ör. D17O şafak sonrası `A_OUT`, D26O dalga komutları, D32O hendek barkları, D39O sancak evresi, D31O `AK_NO`).
Bu satırlarda sınıf en olası konuma göre verildi.
