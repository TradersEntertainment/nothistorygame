# Akis audit G: chapters 26, 26o, 28o, 29, 29o (guidance, controls, frozen stretches, timers)

Method notes
- No flow traces exist for these chapters (flowall/ only has ch4..ch20), so everything below comes from the code.
- Frozen durations are estimates: about 2.6 words/s for voiced lines, calibrated on ch19o.txt (a 25-word line is about 9.6 s). Mark them "est.".
- Files: scripts/chapter26.gd (G26), chapter26o.gd (extends 26; G26o), chapter28o.gd, chapter29.gd, chapter29o.gd.
  Support code read: hud.gd (say/choose), wave_runner.gd, duel.gd (UI_DUEL_HINT), cannon_crew.gd, gun_range.gd, tespit_cam.gd, row_meter.gd, carry.gd.
- No dialogue cuts or content reductions are proposed. Every fix is about objective, marker, prompt, freeze state or timing.

Per-chapter walk (what tells the player what to do)

26 (Byzantine). Mostly good.
- Wave 1: objectives UI_OBJ26_ARROWS (marker on WELL), UI_OBJ26_ARROWS_GIVE (marker on breach), then UI_OBJ26_LADDER (marker on ladder head). Prompts agree with the code (UI_PROMPT26_ARROWS, UI_PROMPT26_GIVE).
- Wave 1 fight: WaveRunner sets UI_OBJ_WAVE and the duel footer UI_DUEL_HINT is drawn.
- Wave 2: UI_OBJ26_REPAIR (marker on DEPOT), UI_OBJ26_REPAIR_PUT (marker on breach). Cannon hazard: bark D20_L_WARN_1 plus on-screen qte UI_QTE20_COVER 4 s before the shot (G26:2053-2057).
- Wave 3: gun via GunRange, duel, 26.3 choice (UI_C26G_WARN / UI_C26G_WATCH, untimed by default, hud.gd:3031), wound choice, barrels (UI_OBJ26_CLEAR), carry Giustiniani (UI_OBJ26_CARRY, jolt meter), Aya photo (UI_OBJ26_PHOTO, 40 s). All have an objective and a marker.
- Ending: Siege.show_page plus flowchart. The outcome is clear.

26o. Wave 1 (water) and wave 2 (ladders) are clear: objective + marker + prompt, and the objective text switches on pick-up.
- Defects: wave 3 Hasan objective (HIGH), volley with no on-screen cue (MED), long frozen starts.
- Climb: UI_OBJ26O_CLIMB names W. UI_QTE26O_STONE and UI_QTE_OIL exist. The off-ladder reset exists (G26o:391-397).
- Banner: UI_OBJ26O_RAISE tells the player to hold E near the tower, with a marker and a progress bar. No timer, no soft lock.

28o. Stakes (UI_OBJ28O_STAKES plus prompts) has marker bugs. Haul (UI_OBJ28O_HAUL, then ROLLER, then ROLLER_PUT) is clear. The cannon (CannonCrew hint() plus a marker per step, UI_CREW_*) is very good. Photo (UI_OBJ28O_PHOTO, 30 s).

29. Hooks (UI_OBJ29_HOOKS plus UI_PROMPT29_CUT, hold E) is clear. The fire phase has marker and hidden-timer problems. Photo and wind are fine.

29o. Row (UI_OBJ29O_ROW with a marker on the carrack), hooks (UI_OBJ29O_HOOK plus UI_PROMPT29O_HOOK), photo and gun (own objective, Handgun qte prompts). The hooks window is a hidden 40 s.
- The row phase cannot soft-lock. The target speed is 2.4 + 4.4 * speed_factor, and speed_factor is at least 0.35, so about 3.9 m/s even with no presses (G29o:467).

---------------------------------------------------------------------

## HIGH

### H1. 26o wave 3: objective says "give Hasan water" while the bucket is empty; the barrel is never marked
- File: scripts/chapter26o.gd:587
- Code: `hud.set_objective(tr("UI_OBJ26O_HASAN"), hasan.global_position + Vector3(0, 1.8, 0))`.
- Why it is wrong: at this point `carrying == ""` (the bucket in hand is the decorative _empty bucket). The code on Hasan only reacts when `carrying == "water"` (G26o:825, prompt at :807-809).
- What the player sees: "Hasan'a su ver" ("Give Hasan some water") with a marker on Hasan. Walking to Hasan gives no [E] prompt and E does nothing. The barrel (O_WATER, 2.5-3 m from the spawn point) has no marker, and the marker hides within 4 m of Hasan.
- Contradiction: the code already has the right step. `_update_objective()` "o3" (G26o:664-668) shows UI_OBJ26O_WATER1 "Fıçıdan bir kova su al" with a marker on the barrel when `carrying == ""`. Line 587 bypasses it.
- Fix: replace line 587 with `_update_objective()`. Optionally set `player.free_hold` as in `_empty_bucket()`. Nothing else is needed.
- Why HIGH: a player starting from the chapter menu, or one who skipped the Hasan line, will stand at Hasan pressing E. The barrel is close, so it is not a hard lock, but the objective sends the player to the wrong place.

---------------------------------------------------------------------

## MED

### M1. 28o stakes: marker and prompt point at already-planted holes (the marker follows an index, not a state)
- File: scripts/chapter28o.gd:577-585 (marker), :601-604 (prompt), :618-622 (action).
- Marker target is `_holes[stakes]` (index = number planted). The pile is at x=18 and the holes at x = 2.5, 6.7, 10.9, 15.1, so the nearest hole to the pile is hole_3. A natural nearest-first order is 3, 2, 1, 0.
  - After the 2nd stake (hole_2) the marker is on `_holes[2]`, which is done.
  - After the 3rd (hole_1) the marker is on `_holes[3]`, which is done.
  - The last hole has no marker and the marker sits on a finished hole.
- `_on_focus` shows "E: kazığı çak" (UI_PROMPT28O_PLANT) on a done hole, and `_on_interact` silently returns (:621). So the player gets a prompt and a dead key press.
- Also the first marker sends the player past three holes to the farthest one (hole_0, x=2.5).
- Fix: in `_update_objective` "stakes", pick the nearest hole where `not h.has_meta("done")` to the player. In `_on_focus`, show PLANT only if `not _holes[i].has_meta("done")`.

### M2. 28o stakes: race leaves the player unfrozen during the closing dialogue, with no objective
- Files: scripts/chapter28o.gd:251-262 and :653-675.
- `_on_interact` is not awaited. `stakes += 1` runs before `await _hammer_in()`, so the loop (:251) exits on the next frame, sets `player.frozen = true`, clears the objective and starts D28O_U_STAKES / D28O_T_STAKES.
- `_hammer_in` captured `was = false` and ends with `player.frozen = was` (:675), about 0.8 s later. The player becomes free mid-dialogue with objective "" (engine WARN_FREE_NO_OBJECTIVE).
- `_process` (:711) still runs the cannonball bark and `player.duck` while `phase == "stakes"` and the player is free.
- Fix: increment `stakes` after `await _hammer_in(...)`, or add a `_hammering` flag and make the loop wait for it. Alternatively set `phase = "stakes_done"` before the dialogue.

### M3. 26o wave 2: arrow volley has no on-screen cue and no marker for cover
- Files: scripts/chapter26o.gd:688-708 (hazard), O_COVERS :15. String D26O_S_VOLLEY (only a 4 s bark).
- The hazard is 30 damage plus stagger, every 20 s, from 8 s after the player is freed. It only matters if the player is outside every 3 m cover circle (:671-676).
- The bark says "Fıçıların, yığının arkasına" (barrels, pile) but the covers are four spots, two of which are the pavez arcs the bark does not name. There is no marker and no `hud.set_qte`.
- Compare ch26 wave 2, which shows `set_qte(UI_QTE20_COVER)` for the whole 4 s warning (G26:2053-2057).
- A ladder carrier moves at 0.7 speed. Four seconds is enough if the player knows where to go; a first-time player does not.
- Fix: at `_vwarn = 0.0` (:707) call `hud.set_qte(tr("UI_QTE26O_COVER"))` (new string, e.g. "OKLAR! Kalkanın / fıçının arkasına geç!"). Clear it when `_vwarn` ends (:695-697) and at :321. Optionally use `hud.spots([...])` for the nearest cover for those 4 s.

### M4. 29 fire phase: marker points at a fire, not at the barrel; the 45 s limit is hidden; carry balance is unexplained
- File: scripts/chapter29.gd:197-207 (objective), :293 (FIRE_TIME), :462-474 (_pick), :441-448 (empty bucket).
- `_update_objective` "fire" always targets `_fires.keys()[0]`. The first thing the player must do is take a bucket from the barrel (UI_PROMPT29_FILL). The barrel has no marker.
- `_pick()` does not call `_update_objective`, so after picking up the bucket nothing changes either.
- The text UI_OBJ29_FIRE "(fıçıdan kova)" does mention the barrel, and the barrel is next to the player's start spot, so this is confusing rather than blocking.
- Hidden limit: `FIRE_TIME := 45.0` ends the phase abruptly (:293, then :309 freeze, drop and dialogue). No countdown, and neither D29_C_FIRE nor the objective mention a time. The consequence is only 29.2 plus D29_T_FIRE_BAD, which is mild but abrupt.
- Balance: the bucket is `Carry` with `balance: true`. Two spills (fill < 0.4) make the next pour fail with the bark D_CARRY_EMPTY, and the trip is lost (:441-448). The objective does not say "koşma" (compare UI_OBJ26_CARRY), and the BalanceMeter shows only after the wobble passes half.
- Fix:
  1. In `_update_objective` "fire", target the barrel (`carrack.to_global(Vector3(1.2, DECK + 1.2, 2.6))`) when `carrying == ""` and the fire when `carrying == "water"`. Call it from `_pick()` and `_drop()` in the fire phase.
  2. Show the remaining time, e.g. `hud.set_chase(tr("UI_CH29_FIRE_T"), 1.0 - t / FIRE_TIME)`, or at least a bark at 30 s.
  3. Add "· koşma" to UI_OBJ29_FIRE (UI string only).

### M5. Frozen stretches over 25 s that can be played free (all est.)
The main one is item (a), the chapter openings. (b)-(g) are the other stretches the task asked about. Each stretch lists line keys and code lines.

(a) Chapter openings: all five chapters sit frozen for 28-45 s before the first objective. Each already has an objective that the last line explains, so the lines can be a `say_chain` with the player free and the first objective already visible. (G26o is the only one of the five that has no `UI_OBJ_LISTEN`-style fix needed; the others need a new listening string.)

- 26: G26:225-230, 380-392 -> `D26_N_01`, `D26_T_01`, `D26_G_01`, then `D26_T_25*` / `D26_G_25*` (est. 20 s plus up to 20 s of council memory), then `D0_G_ARROWS` frozen at :392 (est. 7 s). Total about 45 s before UI_OBJ26_ARROWS.
  - Fix: after the card, call `_update_objective()` for wave1, then `say_chain` of the lines. Giustiniani does not need a fixed spot for audio. The `Stage.approach(giust, ...)` calls (:224, :229) can stay.
  - Gap check: `_wave_start` and `_update_objective` only need `phase = "wave1"`, which is set at :390.
- 26o: G26o:204-257 -> `D26O_N_01` (12 s) + `D26O_T_01` (10 s) + `D26O_S_WAVE1` (6 s), plus `D26O_K_WATER` (11 s) when Kadri is an ally and `D26O_AZ_LATE` + 6 s voice wait when 32O.2. Total about 28-45 s.
  - Fix: set the objective, then `say_chain([N_01, T_01, S_WAVE1])` and `while hud.chain_busy()`. The Kadri scene (`_kadri_water`) needs him to approach and face the player, so keep it frozen (it is 11 s).
- 28o: G28o:237-239 -> `D28O_N_01` + `D28O_U_01` + `D28O_T_01` (est. 31 s). `D28O_U_01` is the task ("Kazıkları siperin arkasına").
  - Fix: `_stakes_phase()` first, then the three lines as a chain while the player is free with the stakes objective and marker. The _ball_t barks (:711-726) should wait: set `_ball_t = 10.0` or check `hud.chain_busy()`.
- 29: G29:138-141 -> `D29_N_01` (10 s) + `D29_C_01` (8 s) + `D29_T_01` (6 s) + `D29_C_02` (7 s) = est. 31 s. `D29_C_02` is the task. The first hook spawns 1 s after freedom (:155, `next := 1.0`).
  - Fix: chain `N_01, C_01, T_01, C_02` with the player free and a listening objective (new `UI_OBJ29_LISTEN`, e.g. "Kaptan Cattaneo'yu dinle"). Delay the first hook until `not hud.chain_busy()`.
- 29o: G29o:188-191 -> `D29O_N_01` (12 s) + `D29O_B_01` (8 s) + `D29O_T_01` (10 s) + `D29O_B_02` (6 s) = est. 36 s, with the player seated and pinned.
  - Fix: chain `N_01, B_01, T_01` (est. 30 s) with a listening objective. Then `B_02` ("Çek!") plays as the row phase starts, with the meter already visible so the player can practise the first strokes while it speaks. The seated player gains little beyond mouse look, so UNSURE about the value, but it removes dead time.

(b) 26o wave 3 opening: G26o:569-585 -> `D26O_H_01*` (est. 8 s), `D26O_H_CREW*` / `D26O_H_BACK` (est. 12 s), `D26O_T_02` (3 s), and the conditional `D26O_T_TAPE` + `D26O_N_TAPE` (est. 18 s). Total est. 25-45 s frozen. After this the player must still fill a bucket.
  - Fix: finish with `H_01*` frozen (Hasan is greeting the player). Then `say_chain` the CREW/BACK, T_02 and TAPE lines with the player free and the WATER1 objective (see H1). Hasan stands 6 m from the barrel and nobody needs a fixed spot.

(c) 29o hooks to photo: G29o:250-378 -> `D29O_B_HOOKS_*`, `B_CLIMB*`, `T_CLIMB`, climb cutscene (about 3 s), `T_FELL`, `N_FELL`, then `B_SHORE`. Est. 40 s with no input at all after the last hook.
  - The climb itself (B_CLIMB, T_CLIMB, tween) is a scripted fall and must stay frozen, about 20 s.
  - `T_FELL` (7 s), `N_FELL` (11 s) and `B_SHORE` (4 s) follow `_stand()` at :369, so the player is already on the deck. Chain them with the UI_OBJ29O_PHOTO objective already visible (:385) and start the camera after the chain.

(d) Endings (wind + closing lines), all frozen and can be free:
  - 29: G29:388-416 -> `D29_C_WIND`, 9 s sail, `D29_C_END`(_HURT), `D29_T_END`, `D29_N_END` = est. 38 s. The player is glued to the deck each frame (:410: `player.global_position = carrack.to_global(local)`), where `local` is captured once at :397. Fix: update `local` each frame (`local = carrack.to_local(player.global_position)` before the next frame's move), unfreeze, and use a short objective ("Zincirden içeri giriyorsun").
  - 29o: G29o:432-459 -> `D29O_T_WIND`, 9 s sail, `B_END`, `T_END`, `N_END` = est. 43 s. The galley does not move, so only the forced `player.face(...)` at :453 needs removing. Chain the three end lines while free.
  - 28o: G28o:518-523 -> `D28O_F_02`, walk, `U_SEVEN` (10 s), `T_END` (9 s), `N_END` (14 s) = est. 40 s. The scripted walk to Urban (:520) is the only fixed step; the three lines after it can be a chain, free, with objective "Usta Urban'ı dinle" (new string).

(e) 26 entry procession: G26:1347-1356 -> `D26O_N_HIDE`/`D26_N_HIDE`, `T_HIDE`, `D26_N_ENTRY`, `T_ENTRY`, ride, `N_ENTRY_2`, `T_ENTRY_2` = est. 55 s frozen. The code frees the player only afterwards (:1362), with `UI_OBJ26_FOLLOW`.
  - The horse rides concurrently with the lines (`riding = _ride(...)` at :1342). Fix: create the `back` barrier (:1358-1360) and unfreeze with `UI_OBJ26_FOLLOW` before :1347. Remove the `player.face(horse...)` at :1349 (or keep it for the first beat only) and use `say_chain` for the lines.
  - The barrier placement at z 12.6 is only needed after the horse reaches the breach, but placing it earlier is harmless because the player starts at z 0.8.

(f) 26 Hagia Sophia cinematic: G26:1874-1905 -> `T_AYA`, `N_ANGEL`, `N_EARTH`, walk (5 s), pans, `F_STOP`, `S_AXE`, `F_TRUST`, `N_AYA` = est. 65 s frozen. Not freeable. `player.face()` and `_pan_to()` drive the camera to Fatih and the axeman (camera cuts). UNSURE whether a player-controlled camera could still show the beats. Leave as is.

(g) 26 ending in the breach: G26:689-717 -> `T_GONE`, banner, `L_BANNER`, `N_BANNER`, `K_LAST`, emperor walk, `N_OUT`, `T_OUT` = est. 42 s frozen. Also camera-directed (`player.face`, `_clear_line`). Not freeable.

### M6. 28o roller: the cue arrives after the next stroke window
- File: scripts/chapter28o.gd:381-384, 395-416, 331-334.
- `need_roller = true` is set at the moment of the heave (:383). The roller leaves the sled via `tw.tween_callback(_roller_out)` after 0.5 s, and its animation takes 0.7 s. The objective change (UI_OBJ28O_ROLLER) and the bark D28O_U_ROLLER arrive about 1.2 s later (:415-416).
- The RowMeter period is 1.5 s (row_meter.gd PERIOD), so the next good-press window opens 0.3 s after the cue. A player in rhythm presses Space and gets "Kütük yok!" plus a slip (outcome 28O.2, UI_CH28O stats "Kızak kayması").
- The slip is explained (UI_HAUL_SLIP, D28O_U_SLIP) and D28O_U_HAUL warns about rollers, so this is a fairness issue, not a block. The autotest hides it: the bot sets `meter.enabled = false` when `need_roller` (:306).
- Fix: when `need_roller` is set (:383), immediately `meter.say(tr("UI_OBJ28O_ROLLER_SHORT"), Color("ff9a6a"), 2.0)` and `hud.set_objective(...)`; or call `_update_objective()` right there instead of after the tween (the marker can point at the sled rear until `_free_roller` exists, as :590 already does).

(The 28o slip penalty is therefore rated MED because it silently turns a successful chapter into 28O.2.)

---------------------------------------------------------------------

## LOW

L1. 29o hooks: hidden 40 s (`HOOK_TIME`, G29o:224) and unseen rope cut time. The objective shows only caught/4. If the player misses or the ropes are cut (3.5-6 s, :280) the phase ends at 40 s with no warning. Fix: show a countdown with `hud.set_chase` or bark `D29O_B_MISS`-style at 30 s. Failure is explained (`D29O_B_HOOKS_*`) and no progress is lost; both outcomes lead on.

L2. 29o prompt flicker: `hud.set_prompt` is cleared during the 1.2 s cooldown (G29o:479). The "E: kanca at" hint blinks between throws. Fix: keep the prompt and only dim it, or show it always while `phase == "hooks"`.

L3. 29o row: RowMeter shows orange noise bars (row_meter.gd:128) that mean nothing in 29o. 28o sets `show_noise = false` (G28o:292); 29o does not. A mistimed press only flashes red. Fix: `meter.show_noise = false` and optionally call `meter.say(...)` from `stroke` as 28o does. Timing also barely matters (see walk above), so "Space when green" is optional; harmless.

L4. 29 hooks: hooks have a hidden 9 s life (`HOOK_LIFE`) and the marker follows the oldest hook only (G29:199-202, refreshed on spawn/cut/board). Up to three hooks at once, spread over about 10 m of rail; the other two have no marker. Failure is explained by D29_C_BOARD. Fix: use `hud.spots(ids, ...)` for all live hooks, or add a small timer ring on each rope.

L5. 29 objective counter: "Kancaların iplerini kes %d/%d" can end at, e.g., 4/6 and nobody says why that is fine (G29:202). Add "(kesilmeyen ipten biri çıkar)" to the string or leave as is.

L6. 26 barrel objective wording: UI_OBJ26_CLEAR says "fıçıları çek" (pull) but the prompt UI_PROMPT26_BLOCK and the action say "devir" (tip over). Marker is on the postern, not the barrels (G26:680), but the barrels are 2-3 m away and the marker hides within 4 m. Align the verb ("devir").

L7. 26 wave 2 cannon: the shot lands on a carrying player at the breach (all deliveries are at the breach, `safe` needs >9 m or mantlet or depot, G26:2075-2078) and drops the load (:2083). First shot at 20 s. The qte warns 4 s before. Acceptable, but a first-time player does not know where "siper" is. Fix: add `hud.spots()` markers on the mantlets during the warning.

L8. No control hints for first-time players. None of the five chapters calls `hud.show_controls` (only ch0-2 do). A player who starts at 26/28o/29 from the chapter menu never sees move/look/interact keys. Fix: one `hud.show_controls(true, "UI_CONTROLS_...")` for the first 10 s of the first free phase, as chapter1.gd:198-199 does.

L9. Duel controls: the only teach is the 14 px, 60 % alpha footer UI_DUEL_HINT drawn by duel.gd:1065, with no gamepad variant (compare UI_DRILL_*_PAD). UNSURE whether pad users get a different hint elsewhere. Fix: for the first duel of a chapter start from the menu, `hud.set_qte(GameState.tr_pad("UI_DUEL_FIRST"))` for 6 s.

L10. GunRange limits are hidden: 25 s default, 24 s in 29o (G29o:423), 28 s in 26o (G26o:349). The phase ends with fewer shots if time runs out; no warning. UI_OBJ29O_GUN says "4 atış". Fix: add a short countdown or append "· süre sınırlı" to the objective strings.

L11. 28o: ball barks D28O_S_BALL plus `player.duck` every 6-9 s (G28o:711-726) while the player is trying to read prompts; harmless, but the duck briefly lowers the view while aiming at holes. Fix: skip `duck` when `carrying != ""` or when the player is within 2 m of a hole.

L12. 26 dawn-shot choice labels: UI_C26G_WARN starts with a clock icon ("⏱"), which implies a timer, but choices are untimed unless the "timed_choices" setting is on (hud.gd:3031). Fine; only noting that the icon can read as a timer to players who have the setting off.

---------------------------------------------------------------------

## Checked, nothing wrong found
- Soft locks: none found in these five chapters. Every loop is bounded by a timer (hooks, fire 45 s, photo 30-40 s, GunRange limit, WaveRunner limit 60-95 s) or by an objective with a marker (water/ladders/stakes/banner). 26o ladder fall is recovered by the teleport at G26o:391-397.
- Objective gaps (free with "(yok)"): the only one found is M2 (28o after the 4th stake). The rest keep a live objective whenever player.frozen is false. The 26 wave 1 G_LADDER line (G26:407) plays while free but the objective UI_OBJ26_LADDER with marker is already set, so that is correct.
- Timers while frozen: all timer loops skip `get_tree().paused`; hook life (29), fire time (29), hook time (29o) only run while the player is free (phases set `player.frozen = false` right before). No timer runs during dialogue.
- Choices: 26 has three (UI_C26G_*, UI_C26_WOUND_*, UI_C26_PHOTO/POCKET). The consequence is hinted in each label; none has a visible hidden timer by default.
- Chapter end: all five end with Siege.show_page and a flowchart that lists the outcome (26.1/26.2/26.3, 28O.1/2, 29.1/2, 29O.1/2) and stats. Clear.
- 28o cannon, TespitCam prompts (UI_PROMPT_TESPIT / _FAR) and Handgun qte prompts are consistent with the code.

Priority order if only a few things get fixed
1. H1 (one line).
2. M1, M2 (28o stakes).
3. M4 (29 fire marker plus timer).
4. M3 (26o volley cue).
5. M5(a) chapter-opening chains (five chapters), then M5(d),(b),(c),(e).
