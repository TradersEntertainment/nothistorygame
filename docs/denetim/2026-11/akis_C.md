# akis_C: guidance audit of 10h, 10l, 10z, 11, 12, 12b, 13, 14

Method note. Read-only audit of code, not play.
- Traces: only flowall/ch10l.txt has content. ch10h and ch10z are empty. ch11, ch12, ch12b, ch13 and ch14 do not exist.
- Frozen-time estimates for the other chapters use about 4.6 s per spoken line. That is the ratio in ch10b: 36 lines in 165 s. They are marked UNSURE where it matters.
- Timed choices (`hud.choose(keys, N, ...)`) only run a timer if the setting `timed_choices` is on. It is off by default (hud.gd:3031, game_state.gd:69). By default every "⏱" choice is untimed.
- `hud.choose` hides the objective box, the lore panel, the held label and the chase/gauge box while the buttons are open (hud.gd:3131-3136, `_choice_covers`). This matters in 10l, 11 and 12.

Summary table (severity, chapter, file:line)
- HIGH: 12b `chapter12b.gd:41,366-367`. The torch objective marker can never show.
- MED: 11 `chapter11.gd:200-201,121`. The seek phase has no marker and the scanner reads 0 at the start.
- MED: 11 `chapter11.gd:185-199`. About 35-50 s frozen before control that could be free.
- MED: 11 and 12 `hud.gd:3134`. The persuasion/curiosity gauge is hidden at the moment of choosing.
- MED: 11 `chapter11.gd:485-587`. The arrest rounds never say 70 %, 3 turns or the 50 % run threshold.
- MED: 12 `chapter12.gd:107-129,257,405-423`. No objective, and hidden thresholds for the key-question options.
- MED: 10z `chapter10z.gd:216,224`. The heat bar gets faster each pot, and two overshoots set the kitchen on fire with no retry.
- MED: 10h `chapter10h.gd:327-337`. The night objective lists tasks that can no longer be done.
- MED: 10h `chapter10h.gd:191-206`. No objective during the audience, and about 50 s frozen to the first choice.
- MED: 13 `chapter13.gd:58,252-253,286-317`. The red-button window can be only 3 s.
- MED: 14 `chapter14.gd:94-97,284-302,408-430`. No objective and a long frozen run-up to the report choice.
- LOW: the rest, listed per chapter below.

---------------------------------------------------------------------
## 10h Heyet (delegation)
Flow: card, gate lines, kaftan, `_audience` (3 choices), `_private` (1-2 choices), `_night` (free, 3 tasks + exit), radio, flowchart.

[MED] 10h, `chapter10h.gd:191-206`. Frozen stretch to the first choice, and no stated goal.
- From the first line (`D10H_E_01`, :160) to the first choice (:206) the player is frozen through about 10 lines: E_01, L_02, T_03, (L_KAFTAN), L_04, K_01, TH_01, (TH_PASS), E_OFFER, L_OFFER, TH_OFFER. That is about 45-55 s (UNSURE, no trace).
- Nothing is on screen as an objective for the whole audience (`set_objective` is first called at :337). The player is never told that fixing Lütfi's three mistranslations decides the letter (10H.1) versus disgrace (10H.2). The only score, "Doğruluk", shows in the end-of-chapter stats (`UI_CH10H_STATS`).
- This part cannot be free. There is a fade cut at :175-177 and the audience is staged around the player.
- Fix: set a read-only objective at the start of `_audience`, for example `hud.set_objective(tr("UI_OBJ10H_AUDIENCE"))` with the text "Huzurda: Lütfi yanlış çeviriyor. Gerekirse düzelt (Doğruluk)". Clear it after the third choice at :234.
- The player is frozen, but `set_objective` still draws.

[LOW] 10h, `chapter10h.gd:206,222,232,244,276,285`. The "⏱" prefix on options (`UI_CH10H_FIX_1`, `FIX_2`, `CONFESS`, `CANT_SAY`) suggests a timer. By default there is none. If `timed_choices` is on, the red bar shows the time (8 or 10 s) and a timeout silently becomes the passive branch (:216 `_`, :228, :233 `maxi(c,0)`). Fine either way, but the "⏱" can confuse. Fix: none needed, or drop the symbol when `timed_choices` is off.

[MED] 10h, `chapter10h.gd:327-337, 346-349, 411-413`. Impossible tasks stay in the objective.
- Night tasks: `_update_objective` always lists all three tasks ("· 📦 Gedik", "· 🔋 Giustiniani", "· 🥜 Niko") and puts a coloured marker on each one not in `_done`.
- If the bag has no tape, `_gedik` only says `D10H_T_K_NOTAPE` and returns (:346-349). If it has no chickpeas, `_niko` returns at :411-413. In both cases `_done` stays unset, so the marker and "·" stay on a task that cannot be done. The player keeps walking back to it.
- Not a soft lock, because the exit is always available.
- Fix: in `_update_objective`, build a `blocked` predicate: `(id == "gedik" and not GameState.has_item("tape")) or (id == "niko" and not GameState.has_item("chickpeas"))`.
  - Use it in the `hud.spots(..., skip)` callable.
  - Prefix such lines with "✗ ".
  - Keep the line so the player knows it exists.

[LOW] 10h, `chapter10h.gd:448-460`. The exit has no confirmation.
- E at the gate with 0/3 tasks done ends the night at once (phase "leaving").
- The objective says "Bitince: beyaz bayrakla kapıdan çık" and the marker is gold, so it is acceptable.
- A guard would help a player who presses E out of habit: if `_done.size() < available tasks`, ask `hud.choose(["Çık","Kal"])`.

[LOW] 10h, `chapter10h.gd:313-314`. The night is the first free phase after about 3 minutes. No controls line is shown. The prompts are in the "E · ..." form (`UI_PROMPT10H_*`). Fine; the player has had 9 chapters of E.

[LOW] 10h. Chapter end is clear (flowchart plus stats line). The 10H.2 shame path ends with a radio line (:495). Good.

Soft-lock check: none. The night loop `while phase == "free"` always has the exit interactable, and `_task` resets `_busy`.

---------------------------------------------------------------------
## 10l Lağım (mine tunnel)
Trace ch10l.txt is available. FROZEN from 0.3 to about 29.5 s (intro). Every dig/listen/prop cycle is 1.2-5 s of dialogue, then a choice. The breakthrough meeting runs 94.8 to 110.4 s (15 s).

[MED/LOW] 10l, `chapter10l.gd:212-218`. The opening frozen stretch is 26 s.
- Trace: BLACK off at t=2.6, first CHOICE at t=29.5. That is 3.5 to 29.5 s of D_01, T_02, D_03, T_04, D_05 with no control, borderline over the 25 s limit.
- It could be free. Dragan stands still, nothing is staged, and there is no camera cut. The rules are repeated by the choice menu itself.
- Fix: replace lines :212-216 with `hud.say_chain([["SPK_MINER","D10L_D_01"],["SPK_TOLGA","D10L_T_02"],["SPK_MINER","D10L_D_03"],["SPK_TOLGA","D10L_T_04"],["SPK_MINER","D10L_D_05"]])`.
  - Call `_give_pick(); phase="free"; player.frozen=false; _update_objective()` right after starting the chain.
  - Use `while hud.chain_busy()` before the first `_work`. `hud.say` already queues behind a running chain.
  - Cost: Dragan's mouth animation. `say_chain` uses `find_speaker`, so it likely animates anyway.

[LOW] 10l, `chapter10l.gd:231`. The objective has no world marker.
- `UI_OBJ10L` "⛏ Surların dibine kaz: %d/%d m · Mum: %d %s" is set without a target. The dig face is 2 m ahead in a dead-straight tunnel and the prompt `UI_PROMPT10L_FACE` ("E · Kazı yüzü") appears on focus, so the player can find it.
- Optional: `hud.set_objective(..., _face, 1.3)`. `hide_near` hides the marker under 4 m, so it would be useless anyway. Skip, or lower `hud.marker.hide_near` to 1.2 as ch1 does.

[LOW] 10l, `chapter10l.gd:243` with `hud.gd:3134`. The ⚠ and the candle gauge are hidden while choosing.
- The ⚠ (unsupported twice) is in the objective text. The candle bar is `set_chase`.
- Both are hidden exactly while the 3-button menu is open (`_choice_covers`). The trace shows OBJ (yok) at every CHOICE for this reason (trace artefact).
- The third unsupported dig collapses the roof (10L.3). It is explained twice: `D10L_D_01` and `D10L_D_WARN`. Still, the information is not on screen at the moment of the click.
- Fix: when `_unsupported >= 2`, swap option text: `keys[0] = "UI_CH10L_DIG_RISK"` ("⚠ Kaz (tavan çöker!)") and keys[1] = "🪵 Tavanı destekle (gerekli)".
  - A one-line string pair is enough; no dialogue is touched.
  - Do the same for the candle: append " · Mum: N" via a new string, or exclude `_chase_box` from `_choice_covers`.

[LOW] 10l, `chapter10l.gd:268-271`. Objective and candle number are updated only after the line ends (`_update_objective` at :271), so they are stale during the dig line (trace: "2/12 m" appears 1.2 s after the click). Harmless.

[LOW] 10l. The candle can only run out by spamming "listen" (0.5 each) or support (0.5 each). A minimal run costs 10 of 14. Each of the other actions is cheap, so a fair player cannot lose by accident. Failure (`_candle_out`, 10L.2) is explained by `D10L_T_CANDLE` and `D10L_D_CANDLE`. OK.

Chapter end: clear (title cards, 10L.1 card "Tünel Sulhu", flowchart). The breakthrough choice has 3 distinct options. Chickpeas gone: `say_gone` explains (:379).

---------------------------------------------------------------------
## 10z Ziyafet (feast)
The player is frozen the whole chapter (never `frozen=false`). There are only choices plus one reaction-time bar. No trace.

[MED] 10z, `chapter10z.gd:216,224`. The heat bar is harsh and gets faster on each pot.
- Bar: `val = pingpong(t * (0.6 + i*0.2), 1.0)` (cursor speed 0.6, 0.8, 1.0 per second). The green zone is 0.55-0.85 (`KickMeter`), 30 % of the sweep.
- Window on the green: about 0.5 s on pot 1, 0.375 s on pot 2 and 0.3 s on pot 3. A mouse/keyboard player has about 0.15-0.2 s of variance, so a second burn is likely on at least one pot.
- Two overshoots end the chapter in a kitchen fire (10Z.2, :256, `_burnt >= 2`) with no retry. `D10Z_K_TASTE_BURNT` does warn ("Bir tane daha yakarsan...").
- Also the stop key (interact/kick, :224) is the same key that skips dialogue. A player tapping E to skip `D10Z_K_STOVE`/walk can stop the bar at about 0.0 (zone "weak" gives a raw pot with no harm, but wastes a pot).
- Fix, minimal and about guidance: (a) speeds 0.55, 0.65, 0.75 (`0.55 + i*0.1`); (b) ignore input for the first 0.5 s of each bar (`if t_since_start < 0.5: continue` before :224); (c) optionally mark the pot-2/pot-3 bar with the burnt count in the objective: `UI_OBJ10Z_COOK` + " · Yanan: N/2".
- UNSURE whether the ladder was meant to rise in difficulty. The comic design is clear, but there is no way to retry.

[LOW] 10z, `chapter10z.gd:103-106`. About 15-20 s of K_01, T_02, K_03, ASK_SOUP before `set_objective(UI_OBJ10Z_MENU)` at :161. The objective is empty for the first lines. Move `set_objective` to just after the card (:102). Cheap.

[LOW] 10z, `chapter10z.gd:312-353` (`_feast`). The finale is fully frozen with no objective: WAIT, T_WAIT, Fatih enters (tween), T_ENTER, F_01, taste, F_WHO, BOTH, F_STAY, T_TITLE, K_TITLE, T_TITLE_2, (RADIO) is about 13-14 lines, roughly 60 s (UNSURE).
- It cannot be free. Fatih walks to a fixed spot, there is a staged taste, and the player is faced (:329).
- Acceptable as a cutscene, but a one-line objective would help: "Fatih'in tadımını bekle".

[LOW] 10z, `chapter10z.gd:169-179`. The menu loop is untimed; "modern" answers loop until an old-style dish is picked (explained by Kadri each time). Not a soft lock. Three modern picks in a row is just three jokes. OK.

Choices: `UI_CH10Z_CRIT_YES` / `FUSION` / `LEBLEBI` are distinguishable (💼 and 🥜 icons). Consequences are hidden, but the leblebi option is labelled "Gizli malzeme". OK.

Chapter end: clear (flowchart, 10Z.1 or 10Z.2). The fire is explained by `D10Z_K_FIRE_*`.

---------------------------------------------------------------------
## 11 Yüzleşme (Nihat hunts, then control swaps to Tolga)
No trace. The player is free once (seek), then frozen with choices.

[MED] 11, `chapter11.gd:200-201,121-122`. The seek phase has no marker, and the scanner gauge is 0 at the start.
- The objective is `UI_OBJ11` "Tarayıcıyı takip et: Tolga'yı bul". It is set without a target.
- The scanner is only a hot/cold gauge. `_process` computes `v = clampf(1 - d/45, 0, 1)` (:121). It has no direction.
- The player spawns at `door.position + (0.9, 0.05, -2.2)`, with `CampDay.SPAWN` (0,0,4) and the door at (0,0,6.6). The default Tolga spot is `TOLGA_POS` (-4,0,-43), which is 47.7 m away. Gauge = 0 for the first ~3 m, silent except for a slow beep, and the whole camp is lit (`D11_N_ILLUM`), so the cue "ateşin başında" (`D11_N_FOUND`) does not narrow it down.
- The player can fly, but must guess direction from distance only.
- Chapter 7 already uses `hud.spots`. The kitchen and cannon variants are close (15 m and 22 m) and are fine.
- Fix: pass a marker target. Simplest: `hud.set_objective(tr("UI_OBJ11"), hud.spot("tolga"), 1.6)` at :201. The "tolga" interactable exists (:151).
  - To keep the hunting feel, add the marker after a delay: a `_process` timer; after 40 s in "seek" call `hud.set_objective(tr("UI_OBJ11"), tolga_npc, 1.6)` or a short bark "Kuzey." Also `hud.marker.hide_near` can stay at 4 m (the prompt `UI_PROMPT11_TOLGA` takes over).
- UNSURE: whether the plan wants a pure hot/cold hunt. New players "wait too long", so a delayed marker is the safe form.

[MED] 11, `chapter11.gd:185-199`. Frozen run-up, likely over 25 s.
- Lines: D11_N_ARRIVE, N_ILLUM, M_ILLUM, N_ILLUM_2, (RUMOR_1, RUMOR_2, N_RUMOR), M_FOUND, N_FOUND. That is 7 lines (about 32 s, UNSURE), or 10 lines (about 46 s) when `flying_legend` is set.
- They could be free. They are a radio and a monologue. Nothing is staged and there is no camera cut. The only scripted facing is `player.face(door)` at :180, before the lines.
- Fix: `phase="seek"; hud.set_objective(UI_OBJ11, ...); player.frozen=false; hud.say_chain([...lines :185-199...])`. Move the objective before the chain and do not `await` the chain. `_confront` is only reachable by E on Tolga and `hud.say` queues behind a chain. Keep the `_lost()` branch (:195) as is, because it ends the chapter frozen.
- Note: `_n`/`_say` mouth animation is lost for Nihat monologue. Irrelevant (no NPC speaks).

[LOW] 11, `chapter11.gd:236-240`. Controls for the Nihat powers (fly, cloak) are displayed on the HUD line by `NihatPowers` (`UI_POW_FLY`, `UI_POW_CLOAK`, nihat_powers.gd:401-403). Good, so no gap. First-time barks `D_NIHAT_FLY_FIRST` exist.

[MED] 11, `chapter11.gd:485-587` with `hud.gd:3134`. Persuasion thresholds are hidden and the gauge is hidden at the choice.
- `_show_persuade()` draws "İkna olasılığı: %N" as a `set_chase` gauge (:625). Rules: 3 turns (`TURNS`), win at >= 70 (:581), "Kaç!" works only if `_persuade >= 50` (:540,552), and each timeout costs -10 (:513).
- The gauge is hidden by `_choice_covers` (it is `_chase_box`) while the 4-6 buttons are shown. The player never sees 70 % or 50 % as a goal, and cannot see the current value at the click.
- Failure is explained (D11_N_RUN_FAIL, D11_N_TIME_UP, then `_arrested`), but the outcome 11.1 is a branch (Bölüm 14 waiting room), so a lost gauge game feels like a punishment.
- Fix (guidance only): (a) make the label `UI_CH11_PERSUADE` carry the target, "İkna olasılığı: %%%d (hedef %%70)"; (b) in `_choice_covers`, skip `_chase_box` when `hud.keep_gauge_in_choice` is set (a new bool the chapter sets), or show the value as a first line of the choice; (c) add a short tag to the "Kaç!" option when `_persuade < 50`: "Kaç! (şansın düşük)". Option text only, no dialogue changes.
- (c) uses `UI_CH11_T_RUN` and is a string swap.

[LOW] 11, `chapter11.gd:389` (`UI_CH11_ARREST` "⏱ Tutukla"). The "⏱" is on the first option only. By default there is no timer. With `timed_choices` on, a timeout takes the arrest path (`D11_N_FROZE`, :390-392). Same remark as 10h.

[LOW] 11, `chapter11.gd:399`. `RegulationWall.run` (7 s, 22 presses, about 3.1 taps/s). The prompt `UI_CH7_TEAR` ("[E] [E] [E] FORMU YIRT!") is set via `set_qte`, which converts keys for a gamepad (hud.gd:943). It starts right after the `D11_N_WALL` line with no run-up. Failure is explained (`D11_N_WALL_KEPT`) and mitigated (the branch falls to "release"). If it is the first time here, a 1 s lead-in ("Hazır... YIRT!") would be kind. Cheap: `await get_tree().create_timer(0.8, false).timeout` before the loop (regulation_wall.gd:83).

[LOW] 11, Hikmet/Niko interrupts (:294-359). Frozen cutscenes of about 8-10 lines (about 40 s, UNSURE). Tolga flees on a fixed timeline. Cannot be free. Fine.

Soft-lock check: `_confront` needs the player to be near and look at "tolga" (interactable box 1.4 m). If flying (`powers.flying`), UNSURE whether the interact ray works. No timeout or reminder in "seek" if the player wanders off: only the scanner. Add the delayed marker above.

Chapter end: clear (outcome flowchart; `_next_scene` varies; footer line names the next chapter).

---------------------------------------------------------------------
## 12 Huzur (audience with the Sultan)
No trace. The player is frozen the whole time, with no objective, one gauge ("Sultan'ın merakı: %N", `UI_CH12_PERSUADE`) and choices.

[MED] 12, `chapter12.gd:107-129`. No objective at all, and a long frozen intro.
- No `set_objective` anywhere in the chapter. The player sees only the curiosity gauge from `_show_persuade()` (:124) and the choices.
- Intro before the first choice (:212): ENTER, (HIKMET lines x2), F_01, (companion lines up to 6), F_WHO, (F_EDIRNE). That is 4 to 12 lines, about 20-55 s (UNSURE).
- It cannot be free. It is a fixed audience, and the player is walked in (`_walk_in`), faced to the speaker (`_look_at_speaker`) and the page/handover animation moves around.
- Fix: `hud.set_objective(tr("UI_OBJ12"))` right after the card (:110-114), for example "Sultan'ın merakını uyandır (merak göstergesi)". Clear it in `_ending`.
  - Optional second line under the gauge on the first show: bark "Merak %10: mutfağa gönderilirsin" is not needed; the objective text is enough.

[MED] 12, `chapter12.gd:257,397-423`. The outcome thresholds are not signalled.
- `_merak < 1` (gauge 10 %) sends you to the kitchen (:257). It is not shown anywhere that 10 % means failure.
- Key answers B ("Evet. 29 Mayıs'ta...") and C ("ortak kullanım modeli") need hidden states: B needs `leblebi_given` and `book_shown_sultan` (:412), and C needs the letter delivered and paradox >= 40 (:419). Otherwise `_kitchen()` is called, which is a first failure with one retry (second failure gives 12.5). The player can pick them without any hint.
- Failure is explained (`D12_F_KEY_B_NO`, `D12_F_KEY_C_NO`, `D12_F_KITCHEN`, then `UI_CH12_KITCHEN` card). The retry resets `_shown` items but the flags stay, so a second attempt is possible.
- Fix: (a) the gauge hides in the choice (hud.gd:3134), so apply the same fix as in 11 to keep it visible during the key question; (b) mark A as the safe answer by option text only: `UI_CH12_KEY_A` already "Bunu size söyleyemem". Do not rewrite dialogue; add small suffixes when the precondition is false: "(Riskli)" appended to B and C via a new string pair.

[LOW] 12, `chapter12.gd:263-296` (`_items`). The "Bu kadar" option is option 1 (`UI_CH12_ENOUGH`). A habitual "1" ends the item showing immediately. Reorder with "Bu kadar" last, or add a pre-delay of 0.4 s so the habit key press from the previous line does not select it. Cheap.

[LOW] 12, `chapter12.gd:364`. `hud.choose([...CONFESS, HIDE], 8.0, 0)`: a timeout is treated as silence and is fair (`c < 0: pass`). Good.

[LOW] 12, `chapter12.gd:483-492`. The ending (3 lines plus the tezkire hand-over sequence) is about 40-50 s frozen (UNSURE). It is a staged cutscene (page walks, remote repair). Cannot be free.

Chapter end: clear (title card per outcome, flowchart, stats line `UI_CH12_STATS`).

---------------------------------------------------------------------
## 12b Son Akşam (last evening on the walls)
No trace. Frozen conversation, then ONE free task (light the torches), then radio and flowchart.

[HIGH] 12b, `chapter12b.gd:41,366-367`. The torch objective marker never shows.
- `hud.set_cinematic(true)` is set at :41 and is never turned off.
- `ObjectiveMarker` returns false when `hud.cinematic and not hud.marker_in_cinematic` (objective_marker.gd:116). `marker_in_cinematic` is false by default; only ch16 sets it.
- Even without that, `hide_near` is 4 m. The player starts at `WALL_TOP` (33.3, 12.05, -11.2) and the first torch (`left[0]`, z = -14.2) is 3.05 m away. Torches 2 and 3 (z = -7.4, -5.8) are 3.8 m and 5.4 m away. The whole 9 m walkway is inside the hide radius for most targets.
- What the player has: the objective text "Surun meşalelerini yak · 0/3" (`UI_OBJ12B_TORCHES`), unlit dark torches at dusk, no crosshair (cinematic hides it) and a prompt only within 1.6 m (`UI_PROMPT12B_TORCH`, :378-383). After 90 s of fruitless wandering (`t0 < 90.0`) the sentries light them (:399-400). The chapter does not soft-lock, but the player may wait up to 90 s with control and no cue.
- Control returns abruptly after the Emperor walks off through the door. There is no bark or line saying "now you are free".
- Fix: in `_light_torches_yourself` (before :366) set `hud.marker_in_cinematic = true` and `hud.marker.hide_near = 1.2`; restore `ObjectiveMarker.HIDE_NEAR` at :401. Optionally `hud.bark("SPK_TOLGA", "D12B_T_TORCH_HINT", 4.0)` ("Meşaleler sönük...") if a line already exists, but only if allowed; the marker is enough. Also turn the crosshair on: `hud.set_cinematic(false)` just before the loop (bag and signal return, which is fine).

[MED/UNSURE] 12b, `chapter12b.gd:226-269`. Long frozen conversation.
- Lines: K_01, T_02, (K_LETTER), 1-4 DONE lines, DONE_SON, K_SHIPS, T_SHIPS, K_03, T_04, K_COUNT, T_COUNT, K_COUNT2, K_Q. That is 12-17 lines before the choice, about 55-80 s (UNSURE, no trace).
- Parts of it could be free: K_03 to K_COUNT2 is a monologue by the Emperor on the wall, with fires lighting (`_light_fires(9.0)`). But the code forces `player.face(...)` at :257 and :264 and Sfrancis emotes. Cinematic framing is deliberate.
- Fix options: UNSURE and a design call. Minimal: add an objective during the talk, "İmparator'u dinle", set at :225 and cleared at :287. If the owner wants free time: `say_chain` for `D12B_K_SHIPS` .. `D12B_K_COUNT2` (:251-268) with `cinematic=false` and remove the two `player.face` calls. Not recommended without a play test.

[LOW] 12b, `chapter12b.gd:271`. `UI_CH12B_CANT_SAY` has the "⏱" prefix with no timer by default. Three options are distinguishable and the mirror meaning with chapter 12 is clear. OK.

[LOW] 12b, `chapter12b.gd:384`. `interact` as `just_pressed` inside the loop is the only trigger. A `hud.set_prompt` shows at <1.6 m only (see above). OK once the marker is fixed.

Chapter end: fade, radio (Hikmet line or Tolga line), flowchart. Clear enough; the outcome 12B.x is a world note, not a visible success/fail. `UI_CH12B_STATS` footer says "Hükmü kuşatma verecek". Good.

---------------------------------------------------------------------
## 13 Dönüş Penceresi (return window)
No trace. The player is frozen for the whole chapter. Inputs are read directly (`_tune`, `_hold_qte`, `_red_button`). Versions: garage, depot, 1453, w4, meclis.

[MED] 13, `chapter13.gd:58,252-253,286-317`. The red-button window can be only 3 s.
- `_window = 3.0 + telsiz_bag * 1.8` (3-12 s). With a weak radio bond (0 to 1) that is 3.0-4.8 s. Hold needed: `HOLD_RED = 1.2` s; releasing drains twice as fast (:307).
- The window starts the instant control comes back from the Hikmet to Tolga switch: card (:245, `UI_CH13_SWITCH_SUB` "Kırmızı düğmeyi basılı tut!" tells the key), fade 0.4, radio sfx, `bark D13_H_PRESS` and `_red_button()` (:252-253) with no pause. The key is spelled in the qte line `UI_CH13_PRESS` ("[R] basılı tut"). The R key is also on `UI_CONTROLS` and ch1's `UI_RED_HINT`, so a player in ch13 from a break might not remember it.
- Miss means 13.2 (explained by D13_T_MISSED and D13_H_MISSED). In the kitchen variant with Sinerji it jumps to chapter 16, so no "kapandı" line.
- Fix: floor the window: `_window = maxf(6.0, 3.0 + GameState.telsiz_bag * 1.8)`. If the owner wants the radio bond to matter, raise the base to 5.0. And/or: begin the countdown 1.0 s after the QTE text appears (`await get_tree().create_timer(1.0, false).timeout` after `hud.set_qte`) with `show_controls(true, "UI_RED_HINT")` during the window. The footer `UI_CH13_STATS` shows the window length after the fact.

[LOW] 13, `chapter13.gd:151-176, 900-942` (tune). `_tune` has a 19 s dial (11.4 s when parts are missing in 8.2). Hint line `UI_TUNER_HINT` is displayed. Timer is visible (`tuner.time_left`). A failure leads to the wrong-year branch (13.3, 1977 wedding) and then 14/15. The reason is spoken (`D13_H_WRONG`). Reasonable. The player does not know before the minigame that the failure is a story branch rather than a retry, but the line after it explains it. 8.2 difficulty (0.6x time) is not signalled. LOW.

[LOW] 13, `chapter13.gd:946-960`. `_hold_qte` (lever and cannon) has no time limit, the label is explicit (`UI_CH13_LEVER`, `UI_CH13_FIRE`), and there is a bar. Fine.

[MED/UNSURE] 13, depot version `chapter13.gd:708-723`. About 7 lines frozen before the tuner: DEPOT_1, R_OPEN or R_CARD, OPEN_THANKS or H_CARD, R_CARD_OK, H_FOUND, TUNE_DEPOT. About 30-35 s (UNSURE). A staged scene with Rıza looking at the card, so it cannot be free. Acceptable. 1453 version: H3_00_CITY, H3_01, T3_02, U3_03, H3_TUNE is about 25 s before the tuner. OK.

[LOW] 13, `chapter13.gd:342-437`. Wrong-year wedding scene is about 60 s frozen, scripted (Tolga auto-joins the halay at :423-428). Intentional comedy. The only issue is that no objective or cue says "this is the wrong-year result"; the card `UI_CH13_1977` does. OK.

[LOW] 13, `chapter13.gd:787`. `hud.choose([TOGETHER, HE_STAYS], 8.0, ...)` is fine with no timeout by default. Both options are distinct and their consequences (13.4 versus 13.5) are in the option text. Good.

Chapter end: clear (flowchart plus outcomes).

---------------------------------------------------------------------
## 14 Son Form (Nihat types the report)
No trace. The player is frozen for the whole chapter. Interactions: a choice, typing (`hud.typewriter_keys`), and an E to stamp (`_press_e`).

[MED] 14, `chapter14.gd:84-97,280-302`. There is no objective, and the run-up to the one decision is long.
- No `set_objective` in the whole chapter. The player sits through D14_N_01, (waiting-room x4 for 11.1), M_02, N_03, (N_SEEN x2), `_sicil` (M_SICIL, tube delivery, card, N_SICIL, (31O line), (Edirne line)), (T3 lines), N_Z1, walk-to-chair, sit. That is 6 to 16 lines, about 30 to 75 s (UNSURE) before the first control.
- `D14_N_TYPE` ("Daktilonun başına oturur...") exists but is only used in `_run_shots`, so nothing in the game tells the player that the choice that follows is "the report that decides the world".
- Fix: `hud.set_objective(tr("UI_OBJ14"))` after the title card (:89), text like "Raporu yaz: dünyanın ne olacağına sen karar ver", and `hud.set_objective("")` at :331. This is the guidance frame for the frozen stretch, no dialogue touched.
- The sicil block (:408-430) is the only part that could be free: the player could walk to the chair while the chain plays: `hud.set_objective(tr("UI_OBJ14_CHAIR"), CHAIR)` and `say_chain` for M_SICIL..N_SICIL_*. It needs `_tube_delivery()` (:200) to stop calling `player.face(...)`. UNSURE and low value, so the objective is the minimum.

[LOW] 14, `chapter14.gd:304-332`. Report options: `UI_CH14_R_FIXED_OPT` / `FORGE_OPT` / `RECRUIT_OPT` / `RESIGN_OPT`. The text names the content but not the effect (world fixed, falsified, recruit, resign). The forge option has a hint ("leave everything as it is"). Add a short consequence tag to the other three, as a string-only change. The option list is conditional, so unavailable reports simply do not appear; the player has no sign that more options exist.

[LOW] 14, `chapter14.gd:392-404`. `_press_e`: prompt `UI_PROMPT14_STAMP` or `UI_PROMPT14_BADGE`, auto-continues after 8 s. Fair. The typewriter step (`hud.typewriter_keys`) shows `UI_TYPE_HINT` ("tuşlara bas") and continues alone after 4 s idle, and accepts keyboard, mouse and gamepad buttons (hud.gd:3216-3217). No soft lock.

[LOW] 14, the waiting-room branch (:128-153): about 4 lines plus a card. OK.

[LOW] 14, new-model branch (`_new_model`, :101-124): the choice is skipped, so the outcome 14.5 is explained only by cards and lines (`UI_CH14_R_FIXED`, `D14_NN_5`). The player never touches the typewriter. Clear enough from the lines.

Chapter end: clear (flowchart with the five outcomes, stats line).

---------------------------------------------------------------------
## Cross-chapter items
1. Gauge hidden in choices (hud.gd:3134). `_chase_box` is in `_covers_hidden`. Affects 10l (candle), 11 (persuade) and 12 (curiosity). Proposed API: `hud.choice_keep_gauge := true` that excludes `_chase_box` from `_choice_covers`, and a shift of the choice box down by the gauge height (the comment at hud.gd:3128 says the cover was added because of overlap). UNSURE about layout; test at 16:9 and 4:3.
2. "⏱" prefixes on options without a default timer (10h, 11, 12b). Not harmful. If `timed_choices` is off, no option is timed. Either strip the symbol when off, or leave.
3. `hide_near = 4 m` makes markers vanish in small spaces (12b walkway, 10l tunnel). Use `hud.marker.hide_near = 1.2` as ch1/ch3 do.
4. `set_cinematic(true)` suppresses markers. In 12b it also hides the crosshair and held item during a free phase. Only ch16 sets `marker_in_cinematic`.
5. Timed windows that start with the control hand-over (13 red button, 11 wall) have no lead-in. A 0.8-1.0 s grace would help everywhere.

## Ranked fix list (smallest first)
1. 12b: `hud.marker_in_cinematic = true`, `hud.marker.hide_near = 1.2`, `hud.set_cinematic(false)` before `chapter12b.gd:366`.
2. 13: `_window = maxf(6.0, ...)` at `chapter13.gd:58`, and a 1 s grace in `_red_button`.
3. 11: marker after 40 s (or immediately) via `hud.spot("tolga")`, plus the pre-seek `say_chain` at `chapter11.gd:185-201`.
4. Objectives for the audience/report stretches: `UI_OBJ10H_AUDIENCE`, `UI_OBJ12`, `UI_OBJ14` (three new strings, one `set_objective` call each).
5. 10h: skip predicate for blocked tasks at `chapter10h.gd:336`.
6. 10z: bar speed and an input-ignore window at `chapter10z.gd:216,224`.
7. Gauge visible during choices (hud.gd:3134), then "(hedef %70)" in `UI_CH11_PERSUADE`.
