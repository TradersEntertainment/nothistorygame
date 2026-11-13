# Bölüm 26 — ara sıra çıkan görsel/silah denetim satırları: kök neden ve düzeltme

Godot 4.4.1 (resmi linux x86_64), `--headless --max-fps 20`, 4 çekirdekte aynı anda 4 süreç.
Komut: `timeout 300 godot --headless --max-fps 20 --path . -- --chapter=26 --autotest=<çeşit>`

---

## 1. Ölçüm

### 1.1 Önce (değişmemiş kod, 5f8cac6b)

| Koşu kümesi | Koşu | AUTOTEST PASS | ARMAUDIT çıkan koşu | `personhidden` çıkan koşu | başka VISAUDIT |
|---|---|---|---|---|---|
| `hold_box` (depo) | 30 | 30 | 0 | 0 | 1 koşuda `overlap` |
| `hold_lose` (depo) | 30 | 30 | **4** | **2** | – |
| `hold_box` (ayrı kopya, doğrulama ölçümü) | 80 | 80 | 0 | **1** (`D26_G_DUEL`) | 1 `insolid`, 1 `sunk` |
| `hold_lose` (ayrı kopya, doğrulama ölçümü) | 80 | 80 | **32** | **1** (`D26_G_REPELLED_2`) | – |

Yani iki hata da gerçekten kararsız: `ARMAUDIT` yük altında `hold_lose`ta koşuların %13–40'ında,
`personhidden` her iki çeşitte de ~%1–7'sinde çıkıyor. Ham çıktı: `olcum_once.txt` (ilk 30+30),
`olcum_once_x80.txt` (ayrı kopyadaki 80+80).

> Görevde verilen `hold_box` örneğindeki anahtarlar (`D26_G_BOX`, `D26_G_STAY`, `D26_K_HOLD_1`) bu 110 `hold_box`
> koşusunda çıkmadı; aynı mekanizma aynı yerde, başka repliklerde (`D26_G_HURT`, `D26_G_WOUND_COLOGNE`,
> `D26_G_DUEL`, `D26_G_REPELLED_2`) yakalandı — hepsinde konuşan Giustiniani, örten kişi `Chapter26>WallFight>Person`.

### 1.2 Sonra (düzeltilmiş kod)

| Çeşit | Koşu | AUTOTEST PASS | ARMAUDIT | `personhidden` |
|---|---|---|---|---|
| `hold_box` | 80 | 80 | **0** | **0** |
| `hold_lose` | 120 | 120 | **0** | **0** |

Ham çıktı: `olcum_sonra.txt`.

---

## 2. Kök neden

### A. `VISAUDIT personhidden` — `Unclip.clear_line`'ın dejenere "yan" yönü

Günlüklü kopyada (`~/is` altında ayrı `git worktree`) `Unclip.clear_line`'ın her yer değiştirmesi ve
`WallFight`'ın kişilerinin her 25 cm'lik hareketi basıldı (`gunluk_A_clear_line.txt`):

```
DBG builder id=29099 pos=(1.8, 0.0, 9.5) ... phase=wave3 frame=598 vis=true act=chop
DBG say key=D26_T_LOST frame=625
DBG clear_line frame=626 who=@Node3D@33997 id=29099 pos=(1.8, 0.0, 9.5) -> (0.4, 0.0, 9.5)
        from=(-0.6, 0.1, 9.8) target=@Node3D@23375 tpos=(3.0, 0.0, 9.4) off=0.01 sg=-1
DBG say key=D26_T_SEE_GUN frame=626
DBG say key=D26_G_HURT frame=643
DBG personhidden id=29099 frame=643
VISAUDIT personhidden key=D26_G_HURT ... by=@Node3D@32863/@Node3D@33997(no_talk,garrison,armed,tool_armed)
        at=(0.3, 0.0, 9.3) eye=(-0.6, 1.6, 9.8) head=(4.3, 0.3, 8.0) src=Chapter26>WallFight>Person
```

- **O kişi kim:** `WallFight.add_builders` (scripts/chapter26.gd:166) ile gediğin önüne konan iki "kazık çakan"dan biri
  (`act=chop`, elinde balta → `tool_armed`). Yürüten döngü yok: yerinde çalışır; **yerini dövüşenlerin itişi**
  (`Person._clear_way`, duelist/BattleExtras kalabalığı) dalgalar boyunca yavaşça kaydırır.
  Günlükte kişinin yeri 3. dalga boyunca (2,4; 11,8) → (1,8; 9,5) diye sürükleniyor; yani oyuncunun
  `_dawn_shot` noktasına (−0,6; 9,8) yaklaşıyor.
- **Replik başlarken neden tam önünde:** `_dawn_shot` (scripts/chapter26.gd:765) oyuncuyu ve hedefleri yerleştirdikten
  sonra `Unclip.clear_line(player, [gunner, giust])` çağırıyor; bu, çizgiye 1 m'den yakın herkesi yana çeker.
  Kişi çizginin **tam üstündeydi** (`off=0.01`). O durumda eski kod yan yönü sabit `Vector2(1, 0)` alıyordu
  (unclip.gd:587). Oyuncu→Giustiniani çizgisi burada neredeyse x ekseni boyunca uzandığı için ( (−0,6; 9,8) →
  (3,0; 9,4) ) "yana çekilme" **çizgi boyunca** oldu: kişi (1,8; 9,5)'ten (0,4; 9,5)'e, yani oyuncunun gözünün
  ~1 m önüne, konuşanla oyuncunun tam arasına taşındı. Denetim de onu orada yakaladı.
- **Işınlanma mı, gerçek oyuncunun da başına gelir mi:** oyuncunun o noktaya konması testin botuna özel değil —
  `_dawn_shot` her oyunda oyuncuyu oraya ışınlar (chapter26.gd:763). Kişinin oraya sürüklenmesi de kalabalığın
  itişinden, test botundan değil. Yani **gerçek oyuncunun da başına gelir**: şafak sahnesinde yaralı/konuşan
  Giustiniani'nin yüzünü balta tutan bir kazıkçı kapatır. Kararsızlık yalnızca sürüklenmenin ne kadar ilerlediğine bağlı.

### B. `ARMAUDIT unarmed` — yenilgide kılıcın kına girmesiyle yere serilmenin bir kare kayması

Düello, yenilgi ve `player.down()` anları basıldı (`gunluk_B_arm.txt`):

```
DBG duel lost(b) frame=565
DBG arm frame=565 hp=0.0 is_down=false frozen=false duel.active=false pivot=<null>
        foe=@Node3D@68798 state=IDLE hp=80.0 withdrawn=false
ARMAUDIT unarmed scene=chapter26.tscn foe_dist=3.2 duel_active=false
DBG wr down frame=566
```

- **Kılıç ne zaman gidiyor:** `Duel` canı sıfırlanınca aynı karede `stop()` çağırıp (`duel.gd:697/751`) kılıcı
  kınına koyuyor (`sword_pivot` siliniyor → `pivot=<null>`), sonra `finished.emit(false)`.
- **Oyuncu ne zaman yere seriliyor:** `WaveRunner` yalnız `st["lost"]` bayrağını kuruyordu; `player.down()`
  ise `while duel.active …` döngüsü **bir sonraki karede** uyanınca çalışıyordu (`frame=566`).
- **Düşman neden hâlâ saldırgan:** rakipler ancak `down()`tan sonra (`withdraw()`) çekiliyor; o tek karede
  `state=IDLE, hp=80, withdrawn=false` ve 1,5–7 m mesafede.
- Yani **tam bir kare** boyunca oyuncu ayakta, elinde kılıç yok, yanı başında canlı saldırgan var.
  `Melee._arm_audit` 0,25 sn'de bir baktığı için bu kareye ancak bazen denk geliyordu (ölçümde %13–40).
- **Gerçek oyuncu:** evet, aynı kare gerçek oyunda da var — yenildiği an eli bir karelik boşalıyor
  (kılıç kına girdi, "yere düşme" karartması henüz başlamadı). Gözle zor seçilir ama durum yanlış.

---

## 3. Düzeltme (en küçük, oyuncu için de doğru)

| Dosya:satır | Değişiklik |
|---|---|
| `scripts/npc/unclip.gd:586-590` | `clear_line`: kişi çizginin tam üstündeyken (yatay sapma ≤ 5 cm) yan yön artık sabit `(1, 0)` değil, **çizginin kendisine dik**. Böylece yana çekilme her zaman görüşün dışına çıkarır (sapma 5 cm'den büyükken zaten diklemesine çekiliyordu; davranış değişmedi). |
| `scripts/combat/wave_runner.gd:76-79` | Dalga kaybedilince `player.down()` artık `finished` işleyicisinde, **kılıcın kına girdiği kareyle aynı karede** çağrılıyor. Döngüden sonraki eski `player.down()` çağrısı duruyor (`Player.down` kendini tekrar etmez: `if is_down: return`), böylece sayaç (`downs`, `combat_add`) ve süre değişmedi; yalnız serilmenin başlangıcı bir kare öne alındı. |

Denetim susturulmadı, eşik gevşetilmedi, kimse denetimden muaf tutulmadı; süre, denge, sayaç, replik ve ses
dosyalarına dokunulmadı. Düzeltmeler oyunda hâlihazırdaki kalıpları izliyor (`wave_runner.gd` ≈273,
`duelist.gd` ≈632, `drill.gd` ≈170 yorumlarındaki "konuşanın önüne girme / çizgiden çık" çözümü).

---

## 4. Doğrulama

| Koşu | Sonuç |
|---|---|
| `--autotest=hold_box` ×80 | 80/80 `AUTOTEST PASS`; `VISAUDIT personhidden` 0, `ARMAUDIT` 0 |
| `--autotest=hold_lose` ×120 | 120/120 `AUTOTEST PASS`; `VISAUDIT personhidden` 0, `ARMAUDIT` 0 |
| Bölüm 26'nın `tests/run_tests.sh` içindeki 14 çeşidi ×2 (28 koşu) | 28/28 PASS (`dogrulama_paketi.txt`) |
| Değişen ortak dosyaları kullanan bölümler ×1 — `Unclip.clear_line`: 8, 20, 26o, 31o; `WaveRunner`: 20, 20o, 21o, 26o, 30o, 36b, 37o; ayrıca 0 (WallFight/SiegeChaos) ve her birinin `lose` yolu | 16/16 PASS |
| `tests/parse_check.tscn` | `PARSECHECK PASS scripts=252` |

Ham çıktılar: `olcum_once.txt`, `olcum_sonra.txt`, `dogrulama_paketi.txt`, günlükler
`gunluk_A_clear_line.txt`, `gunluk_B_arm.txt`.

---

## 5. Kalan (bu görevin dışında, düzeltilmedi) — ölçülmüş, eski hatalar

Düzeltilmiş kodda `personhidden`/`ARMAUDIT` sıfır; ama Bölüm 26'da **başka**, daha da seyrek denetim satırları var.
Hepsi değişmemiş kodda da çıkıyor (ayrı kopyada ×80 ölçüldü), yani bu düzeltmenin getirdiği hatalar değil:

| Satır | Değişmemiş kodda | Düzeltilmiş kodda | Not |
|---|---|---|---|
| `VISAUDIT sunk … spk=SPK_AZAP feet=(…, 1.8, ~15.6) floor=2.28` | 1/80 `hold_box` | 2/80 `hold_box` | Gedik ağzındaki `Duelist` azap, moloz tablasının (shape (8,6; 0,55; 2,4)@(0; 2; 15,6)) içine 0,5 m gömülü görünüyor |
| `VISAUDIT overlap a=Chapter26(SPK_DEFENDER) b=WallFight{chop}` | 1/30 `hold_box` | 1/80 `hold_box` | Barikat arkasındaki `no_yield` savunucu ile kazıkçı iç içe |
| `VISAUDIT insolid who=Duelist/…{carry}` | 1/80 `hold_box` | 1/120 `hold_lose` | Düellocu/taşıyıcı ince bir duvar panelinin kenarına giriyor |
| `WALKTHRU … at=(31.5, 1.0, 5.0)` (yalnız `kasim` çeşidinde 1 kez) | ölçülmedi (`kasim` ×30: 0) | 1/(28+30) | Peribolosun doğu ucundaki ara duvarın geçidi (`BattleExtras` şeridi); `Unclip.clear_line` oraya hiç uğramıyor |

Bunların kök nedenini bu görevde aramadım; **tahmini düzeltme göndermedim**. Hepsi yayındaki sürümde de var ve
`tests/run_tests.sh` bunları da hata sayar, yani Bölüm 26 hâlâ ara sıra (ölçüme göre koşuların ~%2–4'ünde)
bir denetim satırı basabilir — ama artık bu iki kök nedenden değil.
