# Rapor: kuralı çiğneyen oyuncu (talimden kaçmak, halka vurmak)

Dal: `wip/senaryo-kacak` (taban `f0250c48`, 0.99.119). Senaryo: `docs/SENARYO_KURAL_CIGNEME.md`.

## 1. Bugünkü davranış (bulunan)
- **Talim** (41o Turgut, 42b Giustiniani; `Drill` + `TrainingYard`): meydanın çevresinde yalnız ip çit var; sınır da
  görünmez duvar da yok. Kılıç derslerinde (`player.combat`) ve merdiven/fotoğraf evresinde oyuncu meydandan çıkıp
  ordugâha/şehre yürüyebiliyor. Hoca yerinde bekliyor, ders süresi (`t < 45`) dolunca dersi kendisi geçiriyor:
  **hiç kimse bir şey demiyor**. ÖNCE kareleri: özgün kodla (depo dışı kopya + oyuncuyu meydanın 22 m dışına koyan
  geçici sonda), 24 sn boyunca hiçbir tepki yok (`pafta_talim.jpg` üst sıra).
- **Vuruş**: serbest dolaşımda `kick` (F / sol tık) yalnız tırmanmaya gidiyor (`Traversal._click`); bir kişiye
  bakılıyorsa (`focus_id` dolu) tık hiç işlenmiyor. Yumruk yok. Sivile, askere, keçiye tekme: **bacak bile
  kalkmıyor, kimse tepki vermiyor**. ÖNCE kareleri: özgün 24 + bir sivilin 1,7 m önünde üç kez `kick` basan geçici
  sonda (`pafta_tekme.jpg` üst sıra).

## 2. Yapılanlar
| Madde | Durum | Nerede |
|---|---|---|
| Ortak düzenek (alan izleyici + vuruş yakalayıcı) | DÜZELDİ | `scripts/level/kural.gd` (yeni, `class_name` yok) |
| Talimden kaçmak: laf → seslenme + kovalayan koşar → yakalanma → CEZA kartı ve üç söz → kaçtığı yere dönüş | DÜZELDİ | 41o, 42b |
| Kaçış başarılı: Hikmet telsiz, Nihat, "İADE" kartı, görev veren bekliyor | DÜZELDİ | 41o, 42b |
| Gönderme (kaçan oyuncuya): 37o Turgut, 36b Leon | DÜZELDİ (koşusu yok: KANITSIZ) | `chapter37o.gd`, `chapter36b.gd` |
| Erkek sivile tekme: 3 basamak + tutuklanma (zindan / kadı / podestà) + mahallede "işte o tekmeci" | DÜZELDİ | 24, 10g, 39o, 31o, 6, 24o |
| Kadın, çocuk, yaşlı, din adamı: vuruş işlemez, rezillik Tolga'da | DÜZELDİ | aynı bölümler |
| Askere tekme: ayak yakalanır, yere, tutuklanma | DÜZELDİ | aynı + talim meydanı |
| Hayvan karşılık verir | DÜZELDİ | aynı |
| Komutana tekme | KISMEN (kodda, koşusu yok: KANITSIZ) | |
| Fatih / İmparator: Büro acil iadesi, bölüm baştan | KISMEN (kodda, koşusu yok: KANITSIZ) | |
| Oynanabilir angarya / zindan | YAPILMADI (kart + söz; sahibin kararı) | |
| Paradoks / Kural Sadakati'ne yazmak | YAPILMADI (bilerek: 12. bölümün sonucu paradoksa bakıyor) | |

- **Yeni replik**: 75 seslendirilecek (tr+en, `i18n/strings.csv` + `docs/voice/VOICE_MAP.csv`, liste:
  `yeni_replikler.txt`) + 19 arayüz/başarım metni. Ses ÜRETİLMEDİ. `tools/voice_map.py` depo dışı kopyada yeniden
  koşuldu: 75 anahtarın 75'i aynı konuşmacıya düşüyor. Var olan hiçbir replik metnine dokunulmadı.
- **Sayaçlar** (`GameState.stats`, kalıcı): `firar`, `buro_iade`, `tekme_sivil`, `tutuklama`, `utanc`,
  `tekme_asker`, `tekme_hayvan`, `tarihe_tekme`. Bayrak: `firar_41o`, `firar_42b` (37o/36b okur).
- **Başarımlar** (gizli): `ACH_FIRAR` Firari Kâtip (3 kaçış), `ACH_KADI` Kadı Huzurunda (1 tutuklanma),
  `ACH_TARIHE_TEKME` Tarihe Tekme. `achievements.gd`, `STEAM_ACHIEVEMENTS.md`, `tests/ach_check.gd`.
- **Yeni test varyantları** (`tests/run_tests.sh`): 41o/42b `kacak`, `kacak_iade`; 24 `krl_hit`, `krl_soft`;
  10g, 39o, 24o `krl_hit`; 6 `krl_hit`, `krl_soldier`, `krl_animal`. Bot yalnız bölümün koyduğu
  `kural.bot_window()` anında çalışır; öbür varyantlarda hemen döner (test botunun yolu değişmez).

## 3. Testler
(aşağıda: `testler.txt` ham satırlar)

TESTLER_YER

## 4. Görsel kurallar
- Muhafız birden belirmez: oyuncunun arkasında, arada duvar olmayan, aynı zemindeki 9–16 m'lik bir noktadan
  koşarak gelir (`_guard_run`); tutuklama kararmasında sahneden kalkar.
- Kovalayan, meydanda zaten oturan azap/gönüllüdür: balyadan kalkar (0,35 sn), koşar; cezadan sonra balyasına oturur
  (ilk sürümde ayakta kalıp balyanın içinde duruyordu: VISAUDIT insolid; düzeltildi).
- Bakış: kalabalık ve mahalle tepkisi baş çevirmesiyle (`Rig.stare_t`), gövde çevrilmez (ilk sürümde iş başındaki
  ressama look_target veriliyordu: LOOKAUDIT backturn; düzeltildi).
- Tekme hedefe iner (`Player.kick` hedefin 1,1 m önüne atılır); işlemeyen tekmede bacak yarıda geri iner.

## 5. Performans
Varsayılan yolda yeni ağ, ışık, kişi yok: bölüme bir `Node` (`_physics_process` birkaç karşılaştırma; hayvan taraması
yalnız tekmeye basıldığında). RINFO ölçülmedi: BAKILMADI.

## 6. Sahibin kararı
1. Hükümdara tekme bölümü baştan başlatıyor: sert mi? 2. Tutuklanma ve angarya kart + söz: oynanabilir olsun mu
(Kadri'nin kazanı mini oyunu, 7. bölüm zindanı)? 3. Başarım adları. 4. Paradoksa yazılsın mı?
5. Osmanlı tarafı cezada "falaka" sözü geçiyor (gösterilmiyor; kadı kırk dilekçeye çeviriyor): kalsın mı?

## 7. Ortak dosya önerisi
Yok: ortak dosyalara (player, person, hud, street_eye) dokunulmadı. Öneri: `StreetEye` tekmeyi de bir "tuhaflık"
olarak saysa (`DST_ODD_KICK_*`), düzenek bölüm bağlantısı olmadan her sokakta çalışır:
`hud.street_eye` kurulurken `preload("res://scripts/level/kural.gd").hits(sc, self, player)`.

## 8. Bakılmayanlar
Hükümdar ve komutan yolları koşulmadı; 37o/36b göndermesi kaçan rotayla koşulmadı; 31o'ya varyant eklenmedi (raporu
bilinmeyen varyantı "late" gibi sayıyor); RINFO.
