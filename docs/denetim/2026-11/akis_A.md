# Guidance audit A: chapters 4, 5, 6, 7

Read-only audit of scripts/chapter4.gd, chapter5.gd, chapter6.gd and chapter7.gd, plus scripts/ui/hud.gd, radio_tuner.gd, camp.gd, garage.gd and i18n/strings.csv.

Traces used: flowall/ch4..ch7.txt. They cover one variant each (4a.1, 5.1, 6a.1, 7.1). Everything about 4b, 6b, 7b and the other variants comes from the code, with durations estimated from line length (about 0.045 s per character plus 1.5 s).

Timed choices (hud.choose with timeout) are off by default. They only run if the "timed_choices" setting is on (hud.gd:3031). The 5 s, 6 s and 8 s choices below are therefore not real timers for most players. The bar is shown when they are on.

Severity follows the brief. Nothing is marked HIGH on proven soft-lock grounds. No hard soft locks were found: every free phase keeps an objective and every blocking step has an exit. The HIGH is an unfair-failure finding.

---------------------------------------------------------------------

## Chapter 4 (First Night)

### 4-1 HIGH, 4a: guards catch the player during the radio chat, and nothing tells them
File: scripts/chapter4.gd:187-193, 202-226 (clamp at 207-208, sight test at 222-225), 189 (hint).

What the player experiences:
- The player is freed at t≈9.8 s with the objective "Çıkıştaki nöbetçileri atlat" (UI_OBJ4A_ESCAPE) and a marker on the exit.
- The spawn is about 10 m from the guards (tent spawn (-3.7,-3.4), guards at z=6.7). Walking toward the marker puts them inside VIEW_RANGE 8.5 after about 1.5 m.
- The radio chain (D4A_H_02, D4A_T_03, D4A_T_04) runs about 16.6 s in the trace (9.6 → 26.4). While it runs, `_sneak_step` forces `_guard_t = minf(_guard_t, WATCH_TIME)`. The guards therefore never start arguing, so `_sees()` stays active the whole time.
- Whoever follows the marker is "seen" during the chat. That means HA_STOP and HU_STOP, then the item/bluff choice. A bluff or a non-working item gives `catches += 1` and a return to the tent. A second catch gives 4a.3 and the dishes (lines 396-401).
- The only explanation is UI_HINT4A ("Tartışırken birbirlerine bakarlar…"). It disappears after 7 s (line 189) and says nothing about the 17 s in which they do NOT argue.
- A first-time player can reach the dishes ending within the first minute without understanding why.

Fix (minimal):
- In `_sneak_step`, skip the sight test while the radio chat plays: `if hud.chain_busy() and not _arguing: pass` before the `for g in [...]` loop. Guards keep standing still and the player can approach the first crates in peace.
- Or start `_set_arguing(true)` immediately and drop the clamp. The clamp exists only so the bark lines do not talk over the radio.
- Also keep the hint up longer. Re-issue `_flash_prompt(tr("UI_HINT4A"), 7.0)` when the first argument starts (inside `_set_arguing(true)` the first time).

### 4-2 MED, 4a: the catch counter is hidden
File: chapter4.gd:396-406, 448.
- Every wrong item (phone, lighter, book, powerbank, selfie) and the bluff counts as a catch. Calming items (chickpeas, cologne) do not.
- The second catch ends the escape (kitchen/dishes). D4A_T_AGAIN ("Tamam. Bir daha…") and D4A_HU_CAUGHT do not say that the next one is the last.
- The choice list (hud.choose, 0 s timeout) names no consequences. That is the puzzle, but the counter should not be secret.

Fix:
- After the first catch, change the objective to a variant that reads "Bir kez daha yakalanırsan mutfağa" (new key UI_OBJ4A_LAST). Do this at the end of `_back_to_start(true)` with `hud.set_objective(tr("UI_OBJ4A_LAST"), Vector3(0,1.2,Camp.ESCAPE_Z))`.

### 4-3 MED, 4b: gate scene is about 42 s of frozen dialogue before the first choice
File: chapter4.gd:844-852 (`_gate`), 902-935 (`_eclipse`).
- Frozen sequence: fade, then eclipse lines D4B_N_ECLIPSE_1, D4B_T_ECLIPSE_1, D4B_N_ECLIPSE_2, D4B_T_ECLIPSE_2, D4B_N_ECLIPSE_3, D4B_T_ECLIPSE_3 (about 34 s including the 5 s `_wait`), then D4B_N_GATE and D4B_N_CHICKEN.
- The first thing the player can do is the item choice. The camera is forced to the moon (`player.face(moon…)`, 910) and the trace does not cover this branch.
- Could it be free? Mostly yes. Niko stands at a fixed spot and there is no cut, camera move or choice inside the six eclipse lines.

Fix:
- `hud.say_chain([["SPK_NIKO","D4B_N_ECLIPSE_1"],["SPK_TOLGA","D4B_T_ECLIPSE_1"],["SPK_NIKO","D4B_N_ECLIPSE_2"],["SPK_TOLGA","D4B_T_ECLIPSE_2"],["SPK_NIKO","D4B_N_ECLIPSE_3"],["SPK_TOLGA","D4B_T_ECLIPSE_3"]])`, then `while hud.chain_busy()`. Free the player with the objective "Niko'yu dinle" (new key). Keep the flash-light line order via `_light_suffix()`.
- Caveat: with the player free, `phase == "gate"` has no kill/bounds check. The `_quay_step` y-test (726-733) only runs in phase "quay". Either keep the player in `move_mode="script"` with zero velocity (look-only, today's behaviour) or add the same y-check. UNSURE how the scene handles walking off the quay.
- Cheaper alternative if freeing is too risky: leave it frozen but let the mouse look around (already allowed).

### 4-4 MED, 4b: 34 s frozen after the fez choice
File: chapter4.gd:879-895.
- After `hud.choose(fez_keys…)` comes D4B_N_SPY or D4B_N_MERCHANT, D4B_T_SPY or D4B_T_MERCHANT, D4B_N_SPY2 or D4B_N_MERCHANT2, D4B_T_ISTANBUL, D4B_N_ISTANBUL (about 150 characters), D4B_T_ISTANBUL_2, then `walls.open_gate`. That is about 34 s of frozen dialogue with no input.
- The gate opens by timer, so nothing needs the player at a spot. D4B_T_ISTANBUL, D4B_N_ISTANBUL and D4B_T_ISTANBUL_2 (lines 891-893, about 20 s) are the natural block to move to `say_chain` with the objective "Niko'yla kapıdan gir". Same bounds caveat as 4-3. LOW to MED depending on whether the scene allows it.

### 4-5 LOW, 4b: balance has no warm-up and the A/D direction is not stated
File: chapter4.gd:620-632, 672-705; strings UI_HINT4B ("A / D: dengeni koru. İbre ortada kalsın.").
- The chain walk starts the moment the hint appears. Noise and the self-reinforcing `_tilt*1.1` term act at once. The hint shows for 5 s and does not say that D pushes the needle right, A left.
- Falling = 4b.3 (cell). There is no retry. The fall is explained afterwards (D2_T_FALL_SCREAM, cell lines).
- Fix: hold `_chain_s` at 0 and ramp the noise over the first 2.5 s. Extend the hint with "Sola kayıyorsa D" (new key). UNSURE how hard this is in practice.

### 4-6 LOW, 4b: quay has a hidden 3-hit limit
File: chapter4.gd:798-817. The third hit throws the player into the sea (4b.3). The hit barks D4B_T_HIT_1..3 escalate but there is no counter. Fix: append " · Darbe %d/3" to UI_OBJ4B_GATE with `hud.set_objective` after each hit (line 801).

### 4-7 LOW: scripted walk with free flag and no objective
File: chapter4.gd:514-533, 566-571. `_walk_to` sets `player.frozen = false` (move_mode "script") after `_escape_lines` cleared the objective. The engine may log WARN_FREE_NO_OBJECTIVE. UNSURE whether it checks move_mode. At most a 6 s scripted walk. Fix: leave `frozen = true` and move with `script_velocity` only, or set an objective "Otağa yürü" for the walk.

### 4-8 LOW: no movement controls shown
Ch4 never calls `hud.show_controls`. A player starting from the menu after a break sees no WASD/Shift line. Prompts show [E] on focus, the choice list shows numbers. Fix: `hud.show_controls(true, "UI_CONTROLS_CH1")` for 8 s after the first unfreeze (key exists, with a _PAD variant), then hide.

Chapter end (4): clear. Flowchart shows the outcome (4a.1/2/3, 4b.1/2/3); `_act_end` cinematic precedes it (about 15 s, intentional). The longest frozen stretch in the 4a trace (32 s, 26.4 → 58) is escape lines + `_act_end` and is fine.

---------------------------------------------------------------------

## Chapter 5 (Garage at night)

### 5-1 MED: radio-tuning timer has no retry and failure is silent
File: chapter5.gd:15 (TUNE_TIME 20), 638-695, failure at 692-695; outcome at 789-790; ui/radio_tuner.gd.
- The window is 20 s and starts after D5_H_TUNE. Failing sets `_tuned = false` and the chapter drifts to 5.4: -2 Radio-Bond, a Bureau interception, and the Nihat card call is dropped (lines 295, 748-752).
- The player gets no "you lost the signal" cue. The tuner just vanishes and a fade follows. Only D5_H_CONF_0_NO ("Cızırtı. Sadece cızırtı.") explains it afterwards.
- Difficulty: dial speed is a fixed 4 MHz/s (digital A/D). The lock band is strength > 0.8, i.e. ±0.6 MHz, and the player must hold E for about 0.83 s. A tap of 50 ms moves 0.2 MHz.
- The target is fixed by `rng.seed = 26` (always the same frequency).
- The hint text UI_TUNER_HINT is clear, and the timer bar is visible.
- Fix (smallest): one automatic retry. In `_tune_step`, when `left <= 0.0` and not yet retried, reset `left = TUNE_TIME * 0.6`, set `_retry = true`, `hud.bark("SPK_HIKMET", "D5_H_TUNE_AGAIN", 2.5)` (new key). Or slow the dial: use `dir * 4.0 * delta` only while no key is held longer than 0.3 s.

### 5-2 MED: free-machine variant has no marker until the machine is taken apart
File: chapter5.gd:309-319 and ui/hud.gd:765-804.
- For machine == "free" the objective UI_OBJ5_HIDE ("Makineyi sök, parçaları bodruma sakla (0/3)") is set with `null` main target and `hud.spots(PART_NAMES.keys()…)`.
- The part nodes do not exist before `_dismantle()` (created at lines 476-479). The marker therefore shows nothing at all until the machine is dismantled.
- The sealed variant does get `hud.spot("machine")` (line 315). The first step in the free variant has no world pointer, only the [E] prompt when the crosshair lands on the machine (UNSURE: spawn is 3.9 m from the machine and the interact ray length was not checked).
- Fix: `if not _done.has("dismantled"): hud.set_objective(tr("UI_OBJ5_HIDE") % _hidden_parts, hud.spot("machine"), 0.4)` for machine free and sealed-after-seal; keep the parts spots afterwards.

### 5-3 LOW: beam catches the player on the very first unfrozen frame
File: chapter5.gd:274-277, 340-362, 17 (SEEN_TIME 0.9).
- `phase = "protect"` and `player.frozen = false` start the beam check at once. The player spawns at z=2.3 and the beam source is at z=3.5, so the spawn is under the sweep.
- 0.9 s in the beam gives a catch (V_1, `_suspicion` 1). The consequence is mild (bark, carried part returns), but the third catch triggers the knock cutscene (`_knock`, 385-402) with frozen lines.
- The hint UI_HINT5_BEAM is a 6 s prompt that any `_on_focus` call overwrites.
- Fix: `_caught_cd = 3.0` at line 275 (grace period). Show the beam rule as the objective suffix instead of a prompt, or re-send the hint if `_suspicion == 0` and the player is in the beam.

### 5-4 LOW: pre-free intro is 31 s of frozen dialogue split by one cut
File: chapter5.gd:251-270. Outside: D5_H_01 and D5_H_02 (about 11 s). After the fade: D5_RADIO_01, D5_H_03(+_NOLEB/_CONF), D5_H_WHY_FREE/_SEALED (about 19 s). Neither half exceeds 25 s, so no change is needed.
If wanted: D5_H_WHY_FREE (or _SEALED) could play as `say_chain` while free if `phase="protect"` and the objective are set first. It would need the beam grace from 5-3.

### 5-5 LOW: 1977 confession is about 40 s frozen
File: chapter5.gd:701-752 and the card/call flow 755-775. Trace: 60.2 → 107 s with one choice (the card call).
- Player is seated (`sit_view`, `reach_grab`), the camera is set, music is dropped for the 3.2 s silence.
- This cannot be freed without breaking the scene (position/camera set, a 3 s silence is the point). Leave it.
- Optional: before the fade add a brief prompt "Telsize konuş" so the sudden loss of control is announced.

### 5-6 LOW: first control hints
Ch5 is the first Hikmet chapter. The only control text is the per-object [E] prompts and the tuner line. No WASD/look line. Fix as 4-8.

Chapter end (5): `_ending` plays D5_H_END, then the flowchart with the outcome (5.1-5.4). Clear.
Other checks that came out fine:
- Pick/hatch counters ("Bodruma kondu: n/3").
- Parts that were dropped by a catch return to their spot and their markers reappear (hud `_interact_live`).
- Confiscated variant: markers on unsearched spots, counter "(%d yer arandı)". The last spot is found after 3 searches by design.

---------------------------------------------------------------------

## Chapter 6 (Camp / inside the walls)

### 6-1 MED, 6a: open route's marker points away from the NPC the player must return to
File: chapter6.gd:193-209 (`_route_spot`), 212-222 (`_update_objective`), 363-368 and 431-458.
- Giving chickpeas or the lighter to Kadri sets `_open["A"]`. The route is then finished only by talking to Kadri again WITHOUT a fez (line 437-438). Lütfi, route B, needs the fez ON.
- `_route_spot` skips every route that is already open and returns the nearest unopened of A/B/C (line 201). After A opens, the marker moves to Lütfi or Urban. The objective text only shows "A: Kadri ✓" (✓ means "route open", which reads as "done").
- Fix: in `_route_spot`, first return the NPC of any open route (`for pair in [...]: if _open.has(pair[0]): return _npc_node(pair[1])`). Change the objective part for an open route to "A: Kadri ✓ (fesi çıkar [H], tekrar konuş)" and "B: Lütfi ✓ (fesi tak [H], tekrar konuş)", using new keys with a _PAD variant.

### 6-2 MED, 6a: Kadri and Lütfi repeat their fez line and an empty item menu in between
File: chapter6.gd:264-277 with 431-449.
- On the second visit to an open route with the wrong fez state, `_talk` calls `_try_complete` at line 264. It speaks D6_KADRI_FEZ_OFF (or D6_LUTFI_FEZ_ON) and returns false. The code carries on to the item menu (lines 267-272).
- After the player picks any option, `_try_complete` runs again at line 277 and speaks the same line a second time.
- The H toggle cannot be pressed while `_busy` (line 114). The player gets the same line twice with a pointless menu between, and cannot act on it before the menu closes.
- The kitchen start (4a.3) hits this on the very first talk: `_open["A"]` is already true (line 157).
- Fix: make `_try_complete` return a tri-state or set a `_fez_blocked` flag. In `_talk`, if the first call was blocked: `_update_objective(); player.frozen=false; _busy=false; return`. Do not show the menu and do not call `_try_complete` again.
- The "(H)" in the spoken lines is not converted for gamepad (hud.gd only converts objective, prompt and QTE text). LOW, pad-only.

### 6-3 MED, 6a: market route (Y) has no pointers at all
File: chapter6.gd:212-222, 493-540, 1330-1331.
- The objective shows "Pazar: tüccarın üç işi %d/3" (UI_OBJ6A_Y) but the marker only ever targets A/B/C NPCs, or the merchant after all three are done.
- The player has to find the merchant, the goat, the ring and the letter soldier unaided. The merchant's job list (D6A_M_JOBS) is spoken only on talking to him, and he has no marker.
- Prompts only appear when the crosshair is on goat, ring or soldier.
- A player with a bag that fits none of A/B/C (see the fuzz-test note at line 620) has no path and no pointer.
- Fix: add choices to the objective: `hud.set_objective(text, _route_spot(), 1.6, hud.spots(["goat","ring","letter"], func(id): return _favors.has(id), {"goat": tr("UI_Y_GOAT"), "ring": tr("UI_Y_RING"), "letter": tr("UI_Y_LETTER")}, 1.0), "")`, plus the merchant as a labeled spot until `_favors.size() >= 3`. New short labels only.

### 6-4 MED, 6b: Giustiniani scene is about 35 s frozen before the first choice
File: chapter6.gd:916-941 (`_gull_caught`), 1006-1042.
- After the grab animation the sequence is D6B_T_CAUGHT, D6B_G_GULL, then `_giust()` re-freezes at once: D6_GIUST_HELLO, D6B_T_INSURANCE, D6B_G_INSURANCE, D6B_T_INSURANCE2, D6B_G_INSURANCE2.
- That is about 35 s continuous, and the first decision is the book choice (only if the book is in the bag) or the warn/silent choice (1045).
- Could it be free? The hello and insurance lines (1014-1018, about 20 s) have no cut, camera move or choice in the middle. Giustiniani is stationary and the table is the gull's last perch.
- Fix: `hud.say_chain([["SPK_GIUST","D6_GIUST_HELLO"],["SPK_TOLGA","D6B_T_INSURANCE"],["SPK_GIUST","D6B_G_INSURANCE"],["SPK_TOLGA","D6B_T_INSURANCE2"],["SPK_GIUST","D6B_G_INSURANCE2"]])` with the player freed and the objective "Giustiniani'yi dinle". Wait for `chain_busy()` before the choose.
- Caveat: `player.face()` keeps the camera on him today; a free player may look away or walk off, which is harmless but needs the choose to wait. UNSURE. Estimated durations.

### 6-5 LOW, 6b: Emperor audience is about 35 s frozen
File: chapter6.gd:1080-1090 (D6B_E_01, D6B_N_E_01, D6B_T_E_02, D6B_E_03, letter hand-over, D6B_N_E_03, D6B_E_04, D6B_N_E_04, D6B_N_FRIEND). It is split by `_take_from` (hand-over animation). Neither half exceeds about 20 s. Fade-in staging puts the player and Niko at fixed spots, so leave it.

### 6-6 LOW, 6b: gull chase hint
File: chapter6.gd:783-870 (objective UI_OBJ6B_CHASE).
- "Martıyı yakala!" with the misses and a countdown is good. The catch needs no key, only to get within REACH 3.2 m horizontally, but the text says nothing about approaching. A player may press E at the gull.
- The chase is fair otherwise. The three-miss rule is visible (kaçırma n/3), failure is explained (D6B_T_LOST) and the outcome is a branch (6b.3).
- Fix: append "· yanına yaklaş" to UI_OBJ6B_CHASE.

### 6-7 LOW: radio answer choice
File: chapter6.gd:180. 5 s answer/ignore choice (only when timed choices are on). Ignoring costs one Radio-Bond signal; the label "Şimdi olmaz" does not hint it. Acceptable.

### 6-8 LOW: no movement controls shown
Same as 4-8. Climbing on the 6b roofs (ROOF_BOUNDS, `enable_climb`) is optional and never taught; the vistas are a bonus only.

Chapter end (6): clear. `_complete()` fades and plays D6A_T_ROAD_*; 6b ends with D6B_N_BYE on the white-flag card. `_end_chapter` shows the flowchart. 6b.3 (dungeon) ends after D6B_N_DUNGEON*.
Other checks that came out fine:
- 6b objective chain Niko, Theodoros (marker on the last clerk), exit the hall, gull, Giustiniani, Emperor, exit. Each step has a marker.
- Letter open has a double confirm.
- Chase timer is not run in dialogue; it only runs after the player is freed (line 827).

---------------------------------------------------------------------

## Chapter 7 (Field work)

### 7-1 MED: typewriter report can be triggered at the start and cannot be cancelled
File: chapter7.gd:256-278 (door at spawn+2.6, trigger box 2.6x2.4x1.2), 886-910, 1357-1366.
- The player spawns 1.2 m in front of the door. The typewriter's interact box starts about 0.3 m behind the spawn point. Turning round shows "[E] Daktilo: raporu yaz" (UI_PROMPT7_REPORT) immediately.
- `_report()` runs without any check on `_scanned`. It freezes the player and offers five locations (LOC7_*) with no "not yet" option. A blind guess (20 % chance) ends the chapter, and a wrong one means 7.2 (Bureau pressure +2).
- Fix: add a cancel option when nothing has been scanned. In `_report`, if `_scanned.is_empty() and _time_left()`, append `"UI_CH7_NOT_YET"` (new key "Henüz değil") to `keys`. If it is chosen, set `phase="free"`, `_busy=false`, `_reporting=false`, unfreeze and return. Also set `phase="report"` only after the choice is confirmed.

### 7-2 MED: no marker to the report door until 16:00 or all traces scanned
File: chapter7.gd:433-442.
- `ids.append("report")` only if all traces are scanned or `_hour >= SUNSET - 1.0`. A player who scans a "hot" trace at 13:00 (D7_N_HOT: "İz sıcak… Şüpheli buraya bağlı") has no pointer back to the typewriter. The objective still reads "konumunu raporla".
- The door is a grey frame near the spawn. After flying around, the player may not find it.
- Fix: also add the report spot when `_scanned.size() >= 1` (or when a hot trace has been scanned, tracked in `_scan`). Add " · rapor: kapıdaki daktilo" to the objective once ids contains "report".

### 7-3 MED: 31 s frozen intro that can play free
File: chapter7.gd:415-419; trace 3.4 → 34.7.
- Lines: D7_N_ARRIVE, D7_M_BRIEF, D7_N_BRIEF, D7_M_BUDGET, D7_N_SCANNER. They are radio/inner lines at the door. Nobody has to stand at a spot, there is no cut and no choice, and the clock only advances on scans and talks, not in real time.
- The scanner and clock explanation (D7_N_SCANNER) matters more once the player can see the HUD scanner bar and the objective.
- Fix: after `await _n("D7_N_ARRIVE")` (line 415): `phase = "free"; Lore.scatter(self, "7"); player.frozen = false; _update_objective(); hud.say_chain([["SPK_MUFIDE","D7_M_BRIEF"],["SPK_NIHAT","D7_N_BRIEF"],["SPK_MUFIDE","D7_M_BUDGET"],["SPK_NIHAT","D7_N_SCANNER"]]); while hud.chain_busy(): await get_tree().process_frame`. The first free seconds are not time-pressured (no real-time timer), so this is safe.

### 7-4 LOW: found-from-afar sequence and report typing are about 30 s frozen
File: chapter7.gd:886-1060. Trace: choice at 69.9, next choice at 101.2. It has two fades, a teleport and the typewriter card. This is a cutscene payoff and cannot be freed.

### 7-5 LOW: a hot scan is about 18 s frozen
File: chapter7.gd:463-498. Trace: 48.9 → 66.6 = scan bar, TRACE line, hologram line (D7_N_HOLO_*), D7_N_HOT. The hologram needs the camera facing it. Leave it.

### 7-6 LOW: delaying the report has an unannounced QTE
File: chapter7.gd:1039-1056, 1063-1109.
- UI_CH7_DELAY ("Raporu… biraz bekletsem?") leads to the "Yönetmelik Duvarı" QTE if loyalty < 35. This is a 22-press mash in 7 s.
- The QTE text itself is clear ("[E] [E] [E] FORMU YIRT!" with a countdown, and `advance` or `interact` count).
- Failure is a branch (7.5b, loyalty reset to 50), not a punishment loop. The choice does not hint that a prompt is coming. Acceptable; optional hint is a new line in the choice label.

### 7-7 LOW: witnesses are unmarked
The five traces get markers from the start (`hud.spots`, line 442), but the talkable witnesses (Kadri, Lütfi, Urban, guards; Niko, Theodoros, Giustiniani, Emperor) do not. D7_N_SCANNER says "her sohbet yarım saat", so cost is announced. The benefit (hints to the truth) is not. Optional: add " · tanıkla konuşmak ipucu verir" to UI_OBJ7.

Controls: the power strip UI_POW_FLY / UI_POW_CLOAK is permanent (nihat_powers.gd:398-405). Scanner hint, [E] scan prompt and QTE are shown on first need. Movement is not shown (same LOW as 4-8).

Chapter end (7): clear. Sunset forces the report with D7_N_SUNSET (line 453). The result is shown by the found/lost scene and the flowchart (7.1/7.2 plus extras).

Soft-lock check: none. The clock only advances on scans and talks, so wandering costs nothing.

---------------------------------------------------------------------

## Summary table (HIGH and MED)

| # | Sev | Ch | File:line | Issue |
|---|-----|----|-----------|-------|
| 4-1 | HIGH | 4a | chapter4.gd:187-193, 202-226 | guards watch (not arguing) for the 17 s radio chat; following the marker gets the player caught, 2 catches = dishes |
| 4-2 | MED | 4a | chapter4.gd:396-406 | hidden 2-catch limit |
| 4-3 | MED | 4b | chapter4.gd:848-852, 902-935 | about 42 s frozen before the first choice (eclipse) |
| 4-4 | MED | 4b | chapter4.gd:879-895 | about 34 s frozen after the fez choice |
| 5-1 | MED | 5 | chapter5.gd:638-695 | 20 s tuner: no retry, silent failure, permanent -2 and 5.4 |
| 5-2 | MED | 5 | chapter5.gd:309-319 | no marker for the free-machine first step |
| 6-1 | MED | 6a | chapter6.gd:193-222 | marker leaves the open route; ✓ reads as done |
| 6-2 | MED | 6a | chapter6.gd:264-277, 431-449 | fez line spoken twice with an empty menu between |
| 6-3 | MED | 6a | chapter6.gd:212-222, 493-540 | Y route has no pointers |
| 6-4 | MED | 6b | chapter6.gd:916-1042 | about 35 s frozen Giustiniani intro |
| 7-1 | MED | 7 | chapter7.gd:886-910 | accidental, uncancellable report next to spawn |
| 7-2 | MED | 7 | chapter7.gd:440-442 | no report marker until 16:00 |
| 7-3 | MED | 7 | chapter7.gd:415-419 | 31 s frozen intro, free-able with say_chain |
