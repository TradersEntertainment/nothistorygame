# İlk 15 dakika: oyun tasarımı incelemesi (Bölüm 0-3)

Sources: flow traces ch0-ch3 (dialogue timings are real), scripts/chapter0-3.gd, hud.gd, i18n/strings.csv, and contact sheets
0/s000, 1/s002, 1/s005, 1/s006, 2/s000, 2/s003, 3/s001, 3/s009.
Free-roam lengths are **estimates (E)** worked out from the code: walk speed 3.2 m/s (player.gd:11), the distances in each script, plus time a
first-timer spends looking around. Chapter-end flowcharts are counted at about 10 s each. Every dialogue line can be skipped with
E/Space/click (hud.gd:1709). Here "no input" means the player can only press to skip lines: they cannot move, choose or act.

## 1. Timeline (about 30 s per row; "since input" = seconds since the last move, choice or action)

| time | what happens | player knows what to do? | since input |
|---|---|---|---|
| 0:00 | Ch0. Fade-in; place caption types out; objective "Ok demetlerini gedikteki okçulara götür" plus D0_G_ARROWS at 0.7 s; WASD controls shown | YES: the objective, the marker, the spoken order and the controls all arrive together (ch0:206-210) | 0 |
| 0:08 (E) | Bundles handed over (7.6 m walk); D0_S_ARROWS, D20_L_WARN_2, cannon | yes, it's a cutscene | 0 |
| 0:12-0:27 | Freeze-frame: D0_T_FREEZE_1, D0_T_FREEZE_2, D0_N_FREEZE; rewind | no input needed (this is the payoff) | 15 |
| 0:28-0:36 | Ch1 cards: "BEŞ HAFTA ÖNCE / BÖLÜM 1", then "Gece 03.00"; camera turns to the phone | n/a | 23 |
| 0:36 | Prompt "E · Telefonu aç" (answers itself after 9 s) | YES | 0 |
| 0:37-1:16 | Bedroom call: D1P_T_01..D1P_H_06, D1P_T_07, slipper gag, D1P_H_08, D1P_T_09, all on a cinematic camera (no mouse-look) | no input possible | **40** |
| 1:16-1:35 (E) | "Hikmet Amca'nın terliğini al", then "Garaja in (kapı)": prompt and marker | YES | 0 |
| 1:35-2:30 | Fade, intro camera (4.6 s), D1_H_01..D1_H_06, slipper demo, D1_H_DEMO_1..4. D1_H_01 says "hele bir yaklaş" while the player is frozen | no input possible | **55** |
| 2:30 | "Zamanatör'e yaklaş": only 1.3 m to walk (SPAWN z=2.3 to PLATFORM z=-1.6, radius 2.6) | yes, but the task is empty | 0 (one step) |
| 2:32-3:00 | Frozen again: D1_T_07, D1_H_07B, D1_T_07C, D1_H_08, D1_T_09, then fade and "Beş dakika sonra" card | no input possible | **28** (85 s since 1:35 apart from one step) |
| 3:00-4:30 (E 60-120 s) | Bag: "Çantana 5 eşya al (0/5)". Player is free while H_10..H_13 play as a chain. Items have NO marker | partly: the goal is clear but the items are small and unmarked | 0 |
| 4:30-5:00 | 2 s wait, then frozen: D1_H_15, D1_H_16, handover, D1_H_17..D1_H_21 (red button) | no input possible | **29** |
| 5:00-5:20 | "Zamanatör'ün paneline yılı gir", keypad 1453, then frozen D1_H_23..D1_H_25 (10 s); "Platforma çık" | YES (1453 is said several times) | 0-10 |
| 5:20-5:45 | Machine stuck: choice (untimed); kick meter or Hikmet kicks; D1_H_30; vortex | YES (choice) | 0 |
| 5:45-6:00 | Ch1 flowchart, then Ch2 card | n/a | - |
| 6:00-6:33 | Ch2: fall onto the slipway; D2_T_01, D2_H_02, radio CHOICE (6:10), D2_H_RADIO_YES, D2_T_03, D2_H_04, D2_T_05, D2_S_06. Player frozen while the galley approaches | no input except the radio choice | **22** after the choice (33 in all) |
| 6:33-6:50 | KOŞ! Slipway run: UI_RUN_HINT for 6 s; QTE "BOŞLUK: ZIPLA!" and "A / D: KAÇ!" for each obstacle | YES (best moment so far) | 0 |
| 6:50-7:05 | Plunge; D2_T_08, D2_H_09; choice shore or chain | yes | 15 |
| 7:05-7:45 (E 20-40 s) | Free swim: "Kıyıya yüz. Suda kırmızı halka görürsen dal!" plus UI_SWIM_HINT for 6 s | YES | 0 |
| 7:45-8:00 | Caught on the shore (D2_S_14..D2_S_16, D2_H_17); flowchart | n/a | 15 |
| 8:00-8:14 | Ch3 card "Nihat · Zaman Bürosu"; D3_N_01, capsule, D3_N_02 | not yet. Who am I now? (the character swap is only on the card) | 14 |
| 8:14 (E 5 s) | "Masadaki dosyayı al" with marker | YES | 0 |
| 8:19-8:50 | Frozen: D3_N_03, D3_N_04, D3_N_ALARM, D3_M_ALARM. The objective already reads "Başdenetçi'ye rapor ver" | knows the goal but cannot move | **31** |
| 8:50-9:00 (E) | Walk to Müfide; the 2:30 clock starts | YES | 0 |
| 9:00-9:35 | Frozen briefing D3_M_05..D3_M_08, tone CHOICE, D3_M_09A, stamp, D3_M_10. **The lift clock keeps running** | no input possible | **22**, then 12 |
| 9:35-9:45 | D3_M_SECONDS ("find 5 lost seconds") while the objective is "Kostüm deposu" and the clock is ticking | MIXED: explore or hurry? | 0 |
| 9:45-10:12 | Frozen depot: D3_R_11, D3_N_12, D3_R_13, CHOICE, D3_N_14, hat, D3_R_15 (clock still running) | no input possible | 15 / 12 |
| 10:12-10:45 (E) | Free; KIT chain (D3_R_KIT_1..3) plus D3_N_KIT_TRY ("Deneyelim") invites flying; objective "Saha asansörüne bin" | MIXED: fly, find the seconds, or catch the lift? | 0 |
| 10:45-11:18 | Lift: D3_N_16, ride, "2026" card, arrival FX, D3_H_17, D3_N_18 | no input possible | **~30** |
| 11:18-12:20 (E) | Garage, free during the H_19..H_22 chain; "Paradoks İzi: ipuçlarını tara (0/3) · ya da Hikmet'i sorgula" with coloured markers; D3_N_23 explains the glowing rings 17 s in | YES | 0 (each scan freezes 7-12 s) |
| 12:20-14:00 | Interrogation: CHOICE (approach), lie, radio CHOICE, lie CHOICE, then N_EVIDENCE through N_7C_3 (**43 s**), end CHOICE | yes at choices; passive in between | up to **43** |
| 14:00-14:15 | Ending lines, report, flowchart | n/a | - |

Rough share before the bag phase (0:00-3:00): about 25 s of real control in 180 s. The game shows its controls at 0:00 and
then takes them away for most of the next three minutes. That gap is the most likely source of "ne yapacağımız anlaşılmıyor":
by the time the first open task arrives (the bag), players have learned to wait.

## 2. Longest stretches with no input
1. **Ch1 garage arrival, 1:35-3:00: 85 s** with one 1.3 m step in the middle. Lines D1_H_01, H_02, T_03, H_04, T_05, H_06,
   DEMO_1..4 (about 55 s with the intro camera), then D1_T_07, H_07B, T_07C, H_08, T_09 plus the card (about 28 s).
2. **Ch1 bedroom, 0:37-1:16: 40 s** on a cinematic camera. D1P_T_01..D1P_H_06 (27 s), D1P_T_07, D1P_H_08, D1P_T_09 (6.3 s).
3. **Ch2 opening: 33 s** (22 s after the radio choice). D2_T_03 (8.2 s), D2_H_04, D2_T_05, D2_S_06, with the ship visible far off.
4. **Ch3 after taking the file: 31 s**. D3_N_03, D3_N_04 (8.1 s), D3_N_ALARM (7.9 s), D3_M_ALARM (7.1 s), with the objective already showing.
5. **Ch3 lift and arrival: about 30 s**. D3_N_16 (9.9 s), ride, card, FX, D3_H_17, D3_N_18.
6. **Ch1 red-button block: 29 s**. D1_H_15, H_16, H_17 (5.7 s), H_18, H_19, T_20, H_21.
7. **Ch3 interrogation tail: 43 s** between choices. D3_N_EVIDENCE_* (10 s), H_CONFESS_1, H_CONFESS_2, N_7C_1, N_7C_2, H_7C, N_7C_3.
   This is story payoff and N_7C_1 is set up for chapter 13, so I'd leave it unless change 7 (teaching line-skipping) turns out not to be enough.
8. **Ch3 briefing: 22 s** before the tone choice. D3_M_05, D3_N_06, D3_M_07, D3_M_08.

## 3. Where a first-timer gets lost
1. **Ch1 "Zamanatör'e yaklaş" (chapter1.gd:109-121)** is an empty task. It is satisfied after 1.3 m, and the game then freezes for 28 s.
   Players learn that objectives don't matter and that they should wait. This is the clearest cause of "what are we supposed to do".
2. **Ch1 garage start (ch1:99-108):** D1_H_01 says "hele bir yaklaş" while the player is frozen. The spoken instruction contradicts what the player can do.
   The unused key UI_OBJ_HIKMET ("Hikmet Amca'nın yanına git") already exists for this beat.
3. **Ch1 bag (ch1:139-145, 922-924):** `_update_bag_objective` sets no target, so the items have no marker. In the contact sheet (1/s002) the
   shelf items are thumbnail-sized. The explanation D1_H_13 is the 4th line of the chain, about 12 s after the objective appears.
4. **Ch3 alarm clock (ch3:73-78, 873):** the 150 s countdown keeps running through frozen dialogue: the briefing (~34 s incl. choice)
   and the depot (~27 s). About 40% of the time limit goes to lines the player cannot skip past without skipping the story. On top of that,
   three different calls to action arrive at once: D3_M_SECONDS (explore for 5 seconds, ch3:212), D3_N_KIT_TRY (try flying, ch3:343)
   and the lift clock. A first-timer cannot tell which one matters, and nothing says the timer only costs loyalty (D3_M_LATE).
5. **Ch3 file to alarm (ch3:268-272):** the objective switches to "rapor ver" at 8:19, but the player stays frozen for 31 s.
6. **Ch3 opening:** the swap to Nihat is shown only by the card subtitle. Ch0 introduced Nihat as a voice on the radio. This is acceptable because D3_N_01 does the job,
   but it is one more reason the player has no task in the first 14 s.
7. **Skipping lines is never taught.** The hint "E / Boşluk / Tık: devam" sits in tiny grey text inside the subtitle box (sheets 1/s005, 2/s000).
   Players who don't see it sit through every stretch above at full length.
8. Ch2 opening: 33 s frozen, facing a galley that is still far away. "KOŞ!" then lands with QTE prompts at the very first frame of the run (trace 33.0).
   This is clear, but it comes right after a long passive stretch.

## 4. Proposed changes (ranked by impact)

**1. Ch1: turn the empty "Zamanatör'e yaklaş" step into a real walk with the dialogue running.** chapter1.gd `_run`, lines 116-129.
Delete `player.frozen = true` (117) and the two `player.face` calls (120, 122). Replace the awaited `_t/_h` calls 121-129 with
`hud.say_chain([["SPK_TOLGA","D1_T_07"], (TR only: ["SPK_HIKMET","D1_H_07B"],["SPK_TOLGA","D1_T_07C"]), ["SPK_HIKMET","D1_H_08"],["SPK_TOLGA","D1_T_09"]])`
followed by `while hud.chain_busy(): await get_tree().process_frame`, then the existing fade at 130. The same pattern is already used for the bag (144).
Why: removes 28 s of forced waiting and stops teaching players that objectives are fake. Risk: low. The garage is enclosed (gate hint at 772).
Check that the "mirror" and "hikmet" idle barks are blocked while the chain runs; `hud.is_talking()` already guards them (826-841).

**2. Ch1: let the player move during the red-button explanation.** ch1:153-177. Keep D1_H_15, D1_H_16 and the handover frozen (about 8 s).
Then set `player.frozen = false` and play D1_H_17, H_18, H_19, T_20, H_21 with `say_chain`. Keep `phase = "remote"` until the chain
ends, so R, panel E and Tab are inert (they check phase "panel"). After that, set the panel objective, D1_H_22 and UI_RED_HINT exactly as now.
Why: 29 s of frozen time becomes free look-around time. Risk: low. If phase stays "remote", there is no chance of an accidental early end mid-explanation.

**3. Ch3: stop the lift clock during forced dialogue and separate the optional asks.** ch3.gd `_process`, line 73: change it to
`if _clock > 0.0 and not _busy:` (`_busy` is true for the whole of `_take_file`, `_briefing`, `_depot` and `_lift`).
Delete the bark at line 212 (D3_M_SECONDS). Play it instead on the first repeat talk to Müfide, in the `_on_interact` mufide-done branch (1303-1304),
with D3_M_IDLE on later talks. Why: the timer then measures only the player's own walking, and "find 5 seconds" becomes optional for
curious players instead of a third instruction competing with the clock. Risk: the run becomes easier. If the tension drops, lower 150.0 at line 873 to about 100 s.
The late path (D3_M_LATE) is unchanged.

**4. Ch3: shorten the frozen stretch after taking the file and let the alarm play while the player is free.** ch3 `_take_file` 260-274.
Trim D3_N_04: its content is repeated by D3_M_07 (koli bandı, elektrikçi) and D3_M_08 ("garaja inin"). Then set `player.frozen = false`
before `await _alarm_start()`, so D3_N_ALARM and D3_M_ALARM play while the player turns toward the red beacons and the chicken (ch3:855-870).
Keep `_busy` true until the alarm finishes; the Müfide prompt is hidden while `_busy` (1278), so there is no false affordance.
Why: 31 s of freeze becomes 5 s of freeze plus 15 s free, and the "Başdenetçi" objective can be acted on straight away.
Risk: low. A fast player may reach Müfide about 5 s before the alarm lines end and wait silently. It is acceptable, or have `_on_interact` queue the briefing.

**5. Ch1: put markers on the bag items.** ch1 `_update_bag_objective` 922-924: pass the remaining item spots in the same way ch3 `_trace_objective`
(ch3:231-233) does, e.g. `hud.set_objective(text, null, 1.6, hud.spots(item_ids_not_in_bag, ...))`. Also move D1_H_13 to
second place in the chain at line 144 (H_10, H_13, T_11, H_12), so the instruction comes 4 s in rather than 12 s in.
Why: this is the first open-ended task, and the targets are small and unmarked. Risk: medium. Five markers in a small room may clutter the screen.
Use the low height (0.4) and hide the markers once the bag is full.

**6. Ch1: give back control on arrival in the garage, matching D1_H_01.** ch1 `_run` 99-103: after `_intro_camera()`, set
`player.frozen = false` with `hud.set_objective(tr("UI_OBJ_HIKMET"), hikmet.global_position + Vector3(0,1.6,0))` (the key already exists).
Play D1_H_01 ("hele bir yaklaş") as `hud.bark`, then `await _wait_near(Garage.HIKMET_POS, 1.8)`. After that, freeze and continue from D1_H_02.
The slipper handover in `_slipper_demo` already starts from the player's position (454-456).
Why: it breaks the 55 s block, and the spoken line becomes an instruction the player can follow. Risk: low. Spawn to Hikmet is about 3 m.

**7. Teach line-skipping once, early.** hud.gd `say()` (1592): the first time it is called in a run (a GameState flag), also show
`set_qte(tr("UI_CONTINUE"))` (or a short "E / Boşluk: geç") centred for the first two lines. The best spot is the bedroom D1P_T_01.
Why: every stretch in section 2 gets shorter for players who want it shorter, without cutting any content. Risk: very low.

**8. Ch1 bedroom: shorten the cinematic.** ch1 `_bedroom` 351-353: move `player.frozen = false` and the slipper objective (354)
before D1P_T_09, and play D1P_T_09 as `hud.bark("SPK_TOLGA","D1P_T_09",6.3)` instead of awaiting it.
Optionally trim the pair D1P_T_03 and D1P_H_04 ("Saat gecenin üçü..." / "Güzel, demek dinlendin"), about 7 s. The joke beat is already carried by D1P_H_06 and D1P_T_07.
Why: 40 s becomes about 27 s, and the player gets control while Tolga is still talking. Risk: low.

**9. Ch2 opening: allow mouse-look while frozen.** ch2 `_run` 94-97: before D2_T_03, set `player.move_mode = "script"` with
`player.script_velocity = Vector3.ZERO` and `player.frozen = false`. The player can then turn and watch the galley slide toward them
while D2_T_03..D2_S_06 play, and the run setup at 107-109 is unchanged. Why: 22 s of passive time becomes "I'm looking at the threat",
and the KOŞ cut lands harder. Risk: medium. Check that script mode ignores WASD and doesn't let gravity drift the player before `is_on_floor` (104).
If it does, use a look-only flag instead.

**10. Ch3: stop inviting the player to fly while the lift clock runs.** ch3 `_depot` line 343: drop
`hud.bark("SPK_NIHAT","D3_N_KIT_TRY",4.0)` ("Deneyelim. Koridorda."). The KIT chain (342) already explains both powers, and the small
"F · Uç  Q · Zaman Perdesi" panel shows the keys (sheet 3/s001). Why: together with change 3, the lift objective becomes the only
spoken instruction under the timer. Curious players still discover flying from the panel. Risk: low; it is a single bark.
(I considered trimming D3_N_7C_1 from the 43 s interrogation tail and rejected it: chapter13.gd:1079 shows a "Yönetmelik 7/c" prop as a callback, so that line is setup.)

Total effect of changes 1, 2, 4, 6 and 8: about 115 s less forced waiting in the first 11 minutes. The only story line removed is D3_N_04
(and optionally D1P_T_03 and D1P_H_04).

## 5. What already works (keep as is)
- **Ch0 opening order (ch0:203-214):** controls, objective with marker and spoken order all at 0.7 s. The centred first-step hint
  (227-240) and Giustiniani's repeated nudge (245-260) are the right way to start.
- **Dialogue while the player is free:** the ch1 bag chain (144), the ch3 garage intro with Hikmet brewing tea (497-509) and the ch3 KIT chain
  (341-343). Apply this pattern more widely (changes 1, 2 and 4) rather than inventing new ones.
- **Ch2 slipway run:** QTE prompts only appear inside the valid window (ch2:189-196), there is a soldier shout for each obstacle, and the "KADIRGA" chase bar.
  It is the clearest and most fun minute of the opening.
- **Ch3 dual-path objective** with coloured spots ("tara ... ya da Hikmet'i sorgula", ch3:231-233). The objective counter updates right away (636).
- **Choices are untimed by default** (hud.gd:3030-3032). First-timers are never punished for reading.
- **Show, don't tell:** the slipper demo (the slipper comes back with an arrow in it) proves the machine works without exposition.
- The locked-gate prompt (ch1:771-776). It turns an invisible wall into a joke.
