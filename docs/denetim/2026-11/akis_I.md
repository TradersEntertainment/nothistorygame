# Guidance audit I: chapters 33o, 34o, 35o, 36b

Method: code walk only. The flow traces (flowall/ch33o, 34o, 35o, 36b) do not exist, so every duration below is an ESTIMATE.
I estimated spoken lines at about 14 characters per second from the Turkish text in i18n/strings.csv.
Paths: scripts/chapter33o.gd (A), chapter34o.gd (B), chapter35o.gd (C), chapter36b.gd (D). Shared code: scripts/combat/cannon_crew.gd, scripts/ui/gun_drill.gd, balance_meter.gd, row_meter.gd.
No findings on dialogue content. All fixes concern guidance and control only.

## Summary table

| # | Sev | Ch | Where | Problem |
|---|-----|----|-------|---------|
| 1 | HIGH | 35o | C:921-966 | The 6 s "move the rope" countdown does not warn that the brake needle keeps climbing unattended. A slide ("lost a day") costs 35O.1. |
| 2 | HIGH | 36b | D:535, 546, 667-676 | The objective says only "Get back to the postern". Leon (the key choice) has no marker or objective. Arriving ends the chapter and abandons him. A hidden ~34 s timer also removes him. |
| 3 | HIGH (UNSURE) | 36b | D:220, D:99-106 | Bridge has no rails. A fall into the 2.9 m moat has no rescue and no hint. |
| 4 | MED | 33o | A:138-142 | About 45 s frozen at the start. |
| 5 | MED | 33o | A:627-633 | About 48 s frozen briefing at the quay. |
| 6 | MED | 33o | A:491, 1311, 1334 | A stray E press during the 6 s hoist is latched and spoils the next stone. |
| 7 | MED | 33o | A:481-490 | The crane's "green" window is not visible, and there is no stone timer. |
| 8 | MED | 33o | A:1313-1330, 874-885 | Customs hold: the key action (lift the light bale) has no marker and no feedback. |
| 9 | MED | 33o | A:992-999 | The warning-shot objective is rewritten every frame. It wipes the crew's marker and step text. |
| 10 | MED | 33o | A:1068-1079, 1046 | Recoil zone: the aiming spot is inside it, the zone is not drawn, and the hit costs 30 hp. |
| 11 | MED | 33o | A:1107-1125 | Big-gun window shrinks with the time spent on the warning shot. Running out gives a silent miss with a misleading line. |
| 12 | MED | 34o | B:163-168 | About 41 s frozen at the start. |
| 13 | MED | 34o | B:902, 950, 857-868 | The sled children can be saved only in short windows. The marker sends you to a child you cannot help. |
| 14 | MED | 34o | B:1144, 1182-1192 | After the misfire the player stands about 2 m from the touch hole. Nothing says "step back 4 m" and the grace is 2.5 s. |
| 15 | MED | 35o | C:133-138 | About 39 s frozen at the start. |
| 16 | MED (UNSURE) | 35o | C:615-673 | About 25-29 s frozen watching the convoy, with no objective. |
| 17 | MED | 35o | C:901-904, 969 | The brake bar has no "loose / tight" captions, so the red sides are not explained. |
| 18 | MED | 36b | D:203-210 | About 46 s frozen at the start. |

Lower-severity items are listed per chapter below.

---

## Chapter 33o (Rumeli Hisarı)

Step walk-through (first column is the step, then what tells the player, then whether it agrees with the code):

1. **Intro** (A:138-142). Five `hud.say` lines with the player frozen, then `_scaffold`. After the title card, N_01 + T_01 + M_01 + T_02 + M_02 is about 45 s (estimate). See finding 4.
2. **Scaffold** (A:159-277).
   - Objective `UI_OBJ33O_CLIMB` "İskeleden kulenin tepesine çık: çıkrığa". The marker moves ladder1 -> ladder3 top -> arm pivot, and the text matches the code.
   - The break cut-scene freezes the player about 4-5 s (tweens 1.2 + 0.45 + 0.8 + 1.6). This is fine.
   - Plank step: QTE `UI_HINT33O_PLANK` "Kalas çatırdıyor! Durma!" and a 1.5 s plank timer. A fall (y < WALK_Y-1.5) gives -15 hp and a return to deck 2, with `D33O_M_FALL` explaining it. The retry is fair.
   - A 240 s failsafe teleports the player up (A:275). There is no soft lock.
   - LOW: ladder climbing (walk into it and hold W) is never taught here. Only `UI_HINT33O_ROLL` mentions W, much later. Fix: for the first ~6 s of `_scaffold`, show `hud.set_qte("Merdivene yürü, W basılı tut")` (a new string is fine), cleared when `player.ladder != null`.
   - LOW: `_drop_tool` (A:336) is never called, so `UI_HINT33O_ABOVE` never shows. Dead code, no player impact.
3. **Crane** (A:418-546). The player is frozen on purpose. A/D steer the guide rope and E lowers.
   - Objective `UI_OBJ33O_CRANE` plus the balance bar with the keys shown. The text and the code agree.
   - See findings 6 and 7. The 240 s timer is hidden. Penalties: a bad drop costs 6 s, and three drops cost a further 15 s (A:509, 527).
   - Time-out is soft: the masters set the remaining stones (`D33O_M_DONE_LATE`). No unfair fail.
   - Gust: 1 s warning (`UI_HINT33O_GUST`), tight but not harmful.
   - After the crane: M_DONE, then a bark, 2.5 s, T_04, and optionally F_EDIRNE_x and T_EDIRNE. About 30 s frozen (estimate) on the tower top (A:544-553). UNSURE whether they could play free: a free player on the scaffold edge can fall, and `_process` only rescues falls into the sea. Leave it frozen, or free the player only after teleporting to the quay.
4. **Toll, rowing** (A:604-757).
   - Objective `UI_OBJ33O_ROW` has a marker on the bow, and the RowMeter is shown. Space (jump action) is correct.
   - Rocks: a 4 s window, 2 good strokes, `UI_HINT33O_ROCKS`. Failure rotates the boat, costs 10 s, and does not lose progress. Fair.
   - ROW_TIME runs out only to a blank-charge bark, which is harmless.
5. **Toll, boarding** (A:761-836). `UI_OBJ33O_BOARD` plus `UI_HINT33O_ROLL` (1 s warning, then 0.6 s roll). The whole climb progress resets to 0 after a slip (A:815). The retry is fair because the climb needs only ~4 s of W. LOW: a 1 s warning is short. Fix: `roll_t < 1.5`, which is a one-number change at A:789.
6. **Hold** (A:866-922). See finding 8. LOW: both choices say "beş kalem" / "Şarap almıyorum" even when `hidden_found` is false (A:904, `UI_C33O_REFUSE` "Yazıyorum: beş kalem"). Fix: when `not hidden_found`, use the existing neutral choice text, or add a `_FAST` variant of the string.
7. **Warning shot** (A:956-1025). See finding 9. The 75 s window has an in-text countdown. Timeout -> `warn="miss"` with `D33O_FZ_WARN_MISS`, which is clear. Frozen ~4.5 s of barks (A:983-990) with an empty objective: LOW.
8. **Big gun** (A:1089-1157). See findings 10 and 11. LOW: Urban says "Tokmağı al" (A:1099), but the crew's first step is "Barut fıçısından torba al". Fix: swap the bark line for a generic one, or `crew.spawn` order. Not a dialogue cut, just ordering.
   - Photo (A:1134-1153): `UI_OBJ33O_PHOTO` with a marker and 20 s. TespitCam shows its own prompt. If it times out the chapter still ends. Fine.
   - Sink watch before the photo: frozen ~4 s on the miss path (A:1126-1131) with an empty objective. LOW.
9. **Coast and end** (A:1193-1257). Roughly N_END 16 s + T_END 6 s + U_END 9 s = ~31 s frozen (estimate). It is the epilogue and nobody needs a fixed spot, so LOW. Fix: `hud.say_chain` and set an objective "Dinle". The chapter end is clear (page, then flowchart).

### Findings, 33o

**4. MED, A:138-142, long frozen start (~45 s, estimate).**
- N_01 ~10 s, T_01 ~8 s, M_01 ~8.5 s, T_02 ~6 s, M_02 ~12.5 s, with the player standing still. Nobody needs a fixed spot and there is no camera cut.
- Fix: keep `D33O_N_01`, `D33O_T_01` and `D33O_M_01` frozen (about 26 s), and play `D33O_T_02` and `D33O_M_02` with `hud.say_chain([["SPK_TOLGA","D33O_T_02"],["SPK_MASON","D33O_M_02"]])`.
- Set `player.frozen = false` and `hud.set_objective(tr("UI_OBJ33O_CLIMB"), level.ladder1.global_position + Vector3(0,1.6,0))` before the chain, then go straight into `_scaffold` (without `await hud.chain_busy()` blocking it).
- UNSURE: the first scaffold barks (`D33O_S_LADDER_B`, A:198) may collide with a still-running chain. To be safe, `while hud.chain_busy(): await get_tree().process_frame` before the ladder-break trigger at A:177.

**5. MED, A:627-633, quay briefing (~48 s frozen, estimate).**
- FZ_01 ~15 s, T_05 ~6 s, FZ_02 ~13 s, T_06 ~7 s, FZ_03 ~7 s.
- The only scene change is `player.face(genoa...)` at A:630. The boat teleport happens later, after a fade.
- Fix: say `D33O_FZ_01` and `D33O_T_05` frozen (about 21 s). Then free the player and play `D33O_FZ_02`, `D33O_T_06` and `D33O_FZ_03` through `say_chain`. Use `hud.set_objective(tr("UI_OBJ33O_LISTEN"), firuz.global_position + Vector3(0,2,0))`, with a new string such as "Firuz Ağa'yı dinle" ("listen to X" pattern). `while hud.chain_busy()` before the fade at A:635.
- Keep `player.face(...)` out of the free part (set it before unfreezing).

**6. MED, A:491-492, 1311, 1334-1335, latched lower request.**
- `_lower_req` is set by any E press during the crane phase, including the 6 s while the stone is still being hoisted (`lift < 1`). The flag is only cleared inside the `lift >= 1.0` branch.
- A player who mashes E because the objective says "yeşilde E" gets an automatic lowering the instant the lift ends. That lowering may be at a bad theta, which means -6 s, a wall hit and a mason scolding.
- Fix: inside the loop, add `if lift < 1.0: _lower_req = false` (before line 491).

**7. MED, A:481-490, invisible window and timer.**
- Success needs |theta| < 0.22, so |bar value| < 0.244. The BalanceMeter only draws a green-to-red gradient (balance_meter.gd:28-32), with no marked window.
- The objective says "yeşilde E", but the prompt "E: İndir!" appears whenever `lift >= 1`, even when the stone swings badly. The 240 s timer is not shown at all.
- Fix (minimal):
  - Prompt only when `ok`: `hud.set_prompt(tr("UI_PROMPT33O_LOWER") if lift >= 1.0 and ok else "")`, and show "Sallanıyor…" via a new string or `hud.set_qte` otherwise.
  - Or at least colour `balance.label_text`.
  - Optionally add `· %d sn` to `UI_OBJ33O_CRANE`, using `int(left)`.

**8. MED, A:1313-1330 and A:874-885, hold puzzle.**
- Objective `UI_OBJ33O_HOLD` ("beyanda dört kalem, ambarda beş") has no marker. There are six identical-looking crates.
- First E on any crate only wobbles it and plays a sound. For the light bale (`hemp_2`) there is no cue that it is special. The prompt switches to "E: balyayı kaldır" only if the crosshair is still on it afterwards.
- Pressing again does the lift. Most players will inspect each item once and miss the fifth.
- Fix:
  - `hud.set_objective(tr("UI_OBJ33O_HOLD") % ceili(left), hud.spot(["fish","hemp_1","hemp_2","hemp_3","honey","wine"], func(id): return _inspected.has(id) and id != "hemp_2" or hidden_found))`.
  - On the first inspect of `hemp_2` (A:1315 branch) add `hud.bark("SPK_TOLGA", "...")` or a QTE hint "Bu balya hafif. Bir daha E" (new string).

**9. MED, A:992-999 vs cannon_crew.gd:275, warning-shot objective overwrite.**
- `CannonCrew._update_marker` sets `hud.set_objective(hint(), supply_position + ...)` on each step change.
- The chapter loop then calls `hud.set_objective(tr("UI_OBJ33O_WARN") % n)` every frame with no target. This removes the marker diamond and the step text ("Barut fıçısından torba al" / "Tapa" / "Tokmağı al" / "Topun arkasına geç") within one frame.
- The floor ring and the right-hand GunDrill step list remain, and the near-prompt "[E] ..." still appears. So the player is not lost, but the main marker is gone.
- This chapter's big gun (A:1104-1113) does not overwrite, so the two shots behave differently.
- Fix: compose both: `hud.set_objective("%s · %d sn" % [crew.hint(), ceili(left)], crew._spot() + Vector3(0,1,0))`. Or move the countdown to the QTE line (`hud.set_qte`).

**10. MED, A:1046, 1068-1079, recoil zone.**
- `aim_spot = gun.to_global(Vector3(0,0,6.5))`. The gun root is rotated by PI (bogaz.gd:338), so this is BIG_GUN + (0, 0, -6.5).
- `before_fire` hurts the player if `abs(p.x) < 2.2 and -7 < p.z < 0.5` (relative to BIG_GUN). The aiming spot (z -6.5) is therefore inside the zone. The player must move at least 0.6 m or 2.2 m sideways within 2 s.
- The comment says a "red area", but nothing is drawn. The only cues are `UI_HINT33O_RECOIL` "Arkadan çekil!" and the bark. Cost: -30 hp and a stagger of 1.5 s.
- Fix: increase the window to 3 s (A:1075), and draw a red box with `Props.box` or `Props.ring(self, ...)` at BIG_GUN + (0,0.05,-3.5) for those 2-3 s. Or move the zone so it ends before the aim spot (z > -5.5).
- UNSURE: whether `hurt(30)` can kill the player. I did not check.

**11. MED, A:1107-1125 and A:21, 979, big-gun window.**
- The ship moves from the moment the warning-shot card ends (`_ship_moving`, 1.8 m/s). The big-gun loop ends when `rizzo.x >= BIG_GUN.x + 120` (x = 152).
- If the warning shot takes the full 75 s, only ~71 s remain for the whole load/aim/fire sequence (computed from the constants). The window is invisible.
- On timeout `drill.stop()` fires nothing, and the line is `D33O_U_MISS` "Kıçının arkasına!", which implies a shot was fired.
- Fix: show the remaining time in the objective. Or pause the ship during the warning-shot loading steps (`_ship_moving = false` until the player reaches the aim step). Or on timeout use a different bark for "no shot".

---

## Chapter 34o (Edirne, casting the cannon)

Step walk-through:

1. **Intro** (B:163-168). N_01 ~13 s, T_01 ~6 s, U_01 ~8 s, U_02 ~14 s: about 41 s frozen (estimate). See finding 12.
2. **Break the mould** (B:208-257).
   - Objective `UI_OBJ34O_BREAK` "Kil kalıbı tokmakla kır (işaret yeşildeyken E) · 0/8" with a marker on the gun, and the prompt `UI_PROMPT34O_STRIKE` when near. The text agrees with the code (`_input` handles E).
   - 40 s window, an error gives a nick and the narrative `D34O_U_HIT_BAD` explains it. The workers finish the clay at the end. No soft lock. Fine.
3. **Crank** (B:323-406).
   - Space (jump) is named in the objective and the RowMeter is shown. A BalanceMeter shows the tilt.
   - Pawl `UI_OBJ34O_PAWL` "Mandalı indir (E)!" has a 1.5 s window. The fail penalty is -0.5 m with a bark. Fair.
   - Slip: out of balance >1 s -> -0.5 m. Fair and explained by `D34O_U_SLIP`.
   - 90 s limit with a safe fallback. LOW: no fade at B:328; the player is teleported to the windlass directly after the mould phase. LOW: the counter shows `int(avg)` of 3 (B:384, 396), so it reads "0/3 m" for ~12 s. Fix: use `"%.1f"` in the string and `%` args.
4. **Balls** (B:555-667).
   - M_01 frozen ~9 s, then the objective with a marker at the ring and the prompt near the ball. The text has E/F with `tr_pad`.
   - 5 s per-ball timer (B:607): hidden but hinted by `D34O_M_01` "gülle beklemez, yuvarlanır". A missed decision causes the runaway ball.
   - E/F work from any distance (`_input`); only the prompt needs <4 m. Fine.
   - LOW: the crack mesh is only visible within 2.2 m (B:589), but the prompt appears at 4 m. A player waiting at 3 m never sees the crack and accepts the cracked ball. Fix: `visibility_range_end = 4.0`.
   - Ball 4 always runs (B:600): objective `UI_OBJ34O_RUNAWAY` with a marker following the ball, prompt `UI_PROMPT34O_CHOCK`. The ball starts next to the chute, so it is catchable. Failure is soft (people at the fire flee).
   - LOW: 1.5 s free with an empty objective at B:570-575, and during the runaway intro (1.2 s) the objective is stale "x/8".
5. **Crowd and ice** (B:773-1045). See finding 13. The ice has the A/D bar with keys (`show_keys = true`) and a bark. Falling costs 3 s down and 5 hp. Fair. LOW: 3 s free with no objective at B:853.
6. **Test shot** (B:1058-1325). See finding 14. Crew hints and the markers work (no per-frame overwrite here). The `lines` are barks. Frozen between the shot and the photo is about 12 s (estimate), empty objective, LOW. Photo 15 s (B:1300), soft time-out. End: N_END ~11 s + U_END ~9 s = ~20 s frozen. Fine.

Chapter end is clear: page + flowchart, with a "kısa / işarette" stat.

### Findings, 34o

**12. MED, B:163-168, long frozen start (~41 s, estimate).**
- Fix: keep N_01 and T_01 frozen (about 19 s). Then `hud.say_chain([["SPK_URBAN", "D34O_U_01_ALT" if lost33 else "D34O_U_01"], ["SPK_URBAN","D34O_U_02"]])` with the player free, while `_break_mould()` (which unfreezes) starts and sets its objective.
- UNSURE: `D34O_U_HIT_OK` (B:285) is a bark and may collide with the chain. Hold the first strike barks until `not hud.chain_busy()`.

**13. MED, B:902, 950, 857-868, children on sleds.**
- A kid can be stopped only in state "slide" with `s > 0.55`.
- Timing (from the recurrences at B:917, 931): the slide window is about 3 s per ~29 s cycle per child. After reaching the bottom the kid is in "climb" (about 20 s) and unsavable.
- `_nearest_folk_pos` (B:857) does not skip those kids. The marker leads to a child you cannot currently help, with no prompt and no explanation. The counter "x/6 · 90 sn" then looks stuck.
- Failure is soft: it only changes `crowd_saved` (`D34O_U_LATE`). It is also where the ice pond is, so the player falls on the ice while chasing the marker.
- Fix:
  - Make kids saveable in "climb" state and for any `s > 0.2` (B:902, 950), with the same `UI_PROMPT34O_SLED`. Or have `_nearest_folk_pos` skip kids that cannot currently be saved and return the sled's `top` position when only kids are left.
  - Optionally add a `D34O_T_KIDS`-style QTE hint "Kızak hızlanınca E".

**14. MED, B:1144, 1182-1192, 1186, misfire grace.**
- `aim_spot = gun.to_global(0,0,BARREL_LEN*0.5+1.4)` = world z -5.0 (gun root rotated PI). The touch hole is at local z +2.9 = world z -2.9 (edirne_yard.gd:351). Distance is about 2.1 m, inside the 4 m spark radius (B:1254).
- At the misfire the player is unfrozen (B:1182) with `_grace = 2.5` s. The objective `UI_OBJ34O_HANG` says "topa yaklaşma" ("do not approach"), but the player is already near and is not told to step away or by how much. Most first-time players get a spark: -25 hp, thrown back 3.5 m, and the 8-12 s smoke timer resets. This is a teaching punishment, not a lock.
- Fix: change the text to include "4 m geri çekil" (new string text), and give the grace 4.5 s (B:1186). Or show a ring at 4 m with `Props.ring`, like A:340. A marker at a point behind the rope via `hud.set_objective(tr("UI_OBJ34O_HANG"), Vector3(0,1,EdirneYard.ROPE_Z - 2.0))` also works.

Further LOW items:
- B:1224 shows only a bare number as QTE during the 4 s run; the objective stays the stale "Falyaya taze barut koy" text. Fix: `hud.set_qte(tr("UI_HINT34O_RUN") % run_t)` with a new "İpin arkasına! %.1f", and set the objective to "İpin arkasına koş" once primed (B:1216 already switches the marker, but not the text, which is the same key).
- `UI_OBJ34O_LOAD` (strings.csv:6743) is never used. The crew's hints replace it, so no player impact.

---

## Chapter 35o (Edirne road)

Step walk-through:

1. **Intro** (C:133-138). N_01 ~15 s, T_01 ~7 s, approach ~2 s, D_01 ~15 s: about 39 s frozen (estimate). See finding 15.
2. **Bridge** (C:173-234).
   - Qte `UI_HINT35O_BEAM` shows the whole recipe for 8 s only (C:180-182). Then the objective `UI_OBJ35O_LASH` (count + timer) with an adaptive marker: pile -> empty slot -> lash post. Prompts: `UI_PROMPT35O_TAKE`, `_PLACE`, `_LASH`. Everything agrees with the code (distances 2.6 / 2.1 / 2.2 m).
   - A fall into the stream gives the rope (E, 6 s, auto-continue), a lost plank returns to the pile, and a bark explains it. Fair.
   - 240 s is generous; time-out gives loose planks, and with 2 or more the wheel goes through (more bundles later, plus 35O.2). `D35O_D_LASH_BAD` explains it afterwards, and the timer is visible in the text. Fair.
   - Ends frozen 2-4 s. Fine.
3. **Crossing** (C:615-673). Frozen with no objective. See finding 16.
4. **Mud** (C:689-756).
   - `UI_OBJ35O_BUNDLE` with markers (pile, then the front wheel) and prompts (`_BUNDLE`, `_WHEEL`). Then `UI_OBJ35O_HEAVE` with Space and the RowMeter. Texts agree with the code.
   - No time limit and no soft lock (6 bundles for 3-4 needed; bundles cannot be wasted).
   - Hey-yap: a red press slides back 1 m and adds tension; two warnings (`D35O_U_ROPE`), and the third snaps the rope. The QTE `UI_HINT35O_SNAP` gives 0.8 s to leave the whip zone (C:825). The penalty is -20 hp, no lost progress. Fair enough. Note `_snap_resolve` does not block heaving for the 6 s (it only runs `await` in the background), so the "men fall for 6 s" is visual only.
   - LOW: Space also makes the free player jump (player.gd:493), so each heave hops. Fix: `player.speed_mult`-style gating is not available; simplest is `player.frozen = true` once `_bundles_set >= _bundles_needed` (the player no longer needs to move). Add a short sentence in `UI_OBJ35O_HEAVE`: "çekmeden önce tekerden uzaklaş".
   - LOW: the RowMeter is visible during the bundle step (C:697) although Space then only slides the wagon back. Fix: set `meter.enabled = _bundles_set >= _bundles_needed`.
   - LOW: 2.5 s free with no objective at C:754-756.
5. **Slope** (C:879-1009). See findings 1 and 17. Intro lines: U_SLOPE ~8 s + T_SLOPE ~5 s frozen, after a card and fades; fine. Then the player is frozen on purpose and holds E. Objective `UI_OBJ35O_BRAKE` includes the key and a post marker. Slide/snap are explained (`D35O_U_SLIDE`, `D35O_U_SNAP`).
6. **Night** (C:1067-1131).
   - `UI_OBJ35O_OXEN` with a marker on the nearest runner and prompt `UI_PROMPT35O_OX` at 1.6 m. The held-ox bar has A/D keys. `D35O_DR_GOT` says to call its name, and `UI_PROMPT35O_NAME` appears after 4 s in the green.
   - LOW: the 120 s limit is hidden (C:1099). A time-out ends the section quietly with fewer than 3 caught, with no explanation; the outcome is unaffected.
   - Fall in the mud: 3 s down, one bark. Fair.
7. **Photo** (C:1261-1302). 60 s, soft. End lines: U_DAY ~8 s, T_DAY ~5 s, U_END ~6 s, N_END ~16 s, T_END ~6 s: about 41 s frozen (estimate). Epilogue, LOW. Fix: `say_chain` with a "Dinle" objective if wanted.

### Findings, 35o

**1. HIGH, C:921-966 (with C:949-962, 971-977), unannounced needle rise during the transfer.**
- At t > 30 s the code starts `transfer_t`. `holding` is forced false and the needle gets +0.18/s (C:922-924), plus the bump of +0.28 every 3-5 s (C:933-937). The objective shows a 6 s countdown and `D35O_U_POST`.
- Nothing tells the player that the brake no longer works during this time. The player is simultaneously unfrozen, must walk ~7 m, and press E within 2 m of POST2.
- The needle at transfer start is whatever the player had (typically 0 to 0.4). From 0.2, with one bump, it passes 0.8 in about 2 s and the slide (`_red_r >= 1.0`) fires about 1 s later, so about 3 s. The displayed 6 s is misleading.
- A slide costs the day (`slides += 1`), which changes the outcome 35O.1 -> 35O.2 and shows `D35O_U_SLIDE`. The player cannot counter it, because holding E is ignored (C:922-923).
- My estimate of the needle value and timing is approximate because the gravity noise is random (+-0.1). The code path is verified.
- Fix, either:
  - freeze the red timer during the transfer: in the `if balance.value > 0.8` block at C:971 add `and transfer_t < 0.0`; or
  - clamp: `balance.value = minf(balance.value, 0.7)` while `transfer_t >= 0`; or
  - keep the brake working during the transfer: remove `holding = false` (C:922).
- Also tell the player in the objective, for example "kazığa yürü, ibre bu sırada oynamaz".

**15. MED, C:133-138, long frozen start (~39 s, estimate).**
- Fix: keep N_01 and T_01 frozen (about 22 s). Then `Stage.approach(...)` and `D35O_D_01` through `hud.say_chain` with the player free. `_bridge()` already sets the QTE hint and the objective. Because `_bridge()` sets the qte hint at C:179, make that call wait `while hud.chain_busy()` for the 8 s hint to start only after the chain (so the hint is not drowned by the subtitle).
- The carpenter's walk-up (`Stage.approach` to the player's position) works with a moving player; the target is the player's position at call time, so set `player.frozen` only for the approach itself if the carpenter must stand at a fixed spot.

**16. MED (UNSURE), C:615-673, convoy crossing frozen with an empty objective.**
- The convoy moves from CONVOY_WAIT -54 to S_MUD 25.6 at 3.2 m/s: 79.6 / 3.2 = about 25 s. If the bridge breaks, add 3.5 s + 0.8 s, so about 29 s (estimate).
- Player frozen, objective empty; only the `D35O_DR_01` bark. No information about what is happening or when it ends.
- Possible fix: free the player, which is risky because the stream is next to the spot (C:617). Safer: set `hud.set_objective(tr("UI_OBJ35O_WATCH"))`, a new "Konvoyun geçişini izle" string, and shorten the speed to 4.0 m/s. UNSURE whether freeing would be safe, so I only recommend the objective and a faster crossing.

**17. MED, C:901-904, 969, brake bar has no captions.**
- `balance.show_keys = false` and `label_text` is empty during the slope. The bar has a plain green-red gradient with no indication which side is "too loose" (runaway, right) and which is "too tight" (snap, left).
- The objective lists the keys but not the sides. The barks only come after 0.3 s in red (`D35O_U_RUN`) or at the "too tight" warning.
- Fix: set `balance.label_text = tr("UI_LABEL35O_BRAKE")`, a new string such as "◀ sıkı · gevşek ▶". Optionally set `balance.show_keys = true` and describe E as the left pull.

---

## Chapter 36b (sortie from the walls)

Step walk-through:

1. **Intro** (D:203-210). N_01 ~16 s, G_01 ~10 s, T_01 ~8 s, G_02 ~8 s, L_01 ~5 s: about 46 s frozen (estimate). See finding 18.
2. **Cross** (D:212-221). Objective `UI_OBJ36_CROSS` "Kalas köprüden hendeği geç" with a marker at the far end. The blocking loop is `while z < 40`. No reminder and no timer, which is acceptable. See finding 3 for the moat trap.
3. **Fight** (D:354-374). G_GO (~3 s), then the WaveRunner with `UI_OBJ_WAVE` and the Duel on-screen hints (`UI_DUEL_HINT`). The 75 s limit is soft. Losing a fight does not repeat it and does not change the chapter result. Controls for sword fighting are shown by the Duel code.
4. **Burn** (D:386-404). G_BURN ~8 s, torch handover ~1.6 s, T_TORCH ~7 s: about 17 s frozen, fine. Then `UI_OBJ36_BURN (%d/3)` with the marker on the next unburnt screen, and `UI_PROMPT36_BURN` (pad variant exists). The text agrees with the code. No timer. The marker hides within 4 m but the prompt takes over when focused. Fine.
5. **Photo** (D:488-510). N_PHOTO ~7 s frozen. `UI_OBJ36_PHOTO` with a marker and 40 s. A time-out continues silently. Fine.
6. **Retreat** (D:514-550, 579-601, 667-676). See finding 2. The riders bar `UI_CH36_RIDERS` ("Sipahiler") fills in 34 s. LOW: its meaning is not explained (D:583). Fix: add the consequence to the bar label, or a bark when it passes 70%.
7. **Back inside and end** (D:679-724). 36.1: G_ALL ~5 s + L_THANKS ~4 s + G_ORDER ~12 s + N_END ~6 s = ~27 s; 36.2: ~28 s (estimate). Epilogue, LOW. The result is clear: the lines differ, the flowchart marks 36.1 / 36.2, and `leon_saved` is stored.

### Findings, 36b

**2. HIGH, D:535, 546, 594-595, 667-676, 742-743, Leon is not guided.**
- After `D36_G_BACK` ("Geri! Hepiniz köprüye!") and `D36_L_HELP` ("Tercüman! Bacağım... ok yedim! Kalkamıyorum!"), the objective is only `UI_OBJ36_BACK` "Poternaya dön" with a marker on the postern. Nothing marks Leon.
- The camera is not turned to him (unlike the intro, D:209). The pickup prompt `UI_PROMPT36_LEON` ("E: Leon'u kaldır") appears only when the crosshair is on him (`_on_focus`, D:742).
- Reaching the postern radius ends the phase immediately (`_arrived`, D:667-676), which means 36.2, and the riders then take Leon. A player who follows the objective abandons him with no warning, no confirmation and no hint that this was a choice.
- Hidden timer: the riders bar reaches 1.0 after `RIDE_TIME` (34 s) and `_leon_taken()` removes the interaction for good (D:594-595, 654).
- Fix, small and in code only:
  - `player.face(leon.global_position + Vector3(0,1.0,0))` right before `player.frozen = false` at D:528.
  - `hud.set_objective(tr("UI_OBJ36_BACK"), RETURN + Vector3(0,1.6,0), 1.6, [[LEON_AT + Vector3(0,1.2,0), "Leon"]], "Poterna")` so both are shown as coloured markers with a legend (the `choices` / `main_label` pattern). After the lift (D:752 branch) call `set_objective` again without choices.
  - Or a new string "Poternaya dön · Leon'u kaldırmak için ona E" as a second line. Add the key (`UI_PROMPT36_LEON` already carries it).
  - Optionally add a bark (new line) 15 s into the retreat while Leon is not lifted.

**3. HIGH (UNSURE), D:220-221, 99-106, assault.gd:316-320, bridge without rails or rescue.**
- The plank bridge is a 2 m wide solid box with no side rails (D:93-98), over a 2.9 m deep moat (`Assault.ground_y`: -2.9 for z 20.8-34.8). The moat floor and walls are solid (land_walls.gd:177, 202). The player's jump is `JUMP := 3.6` (about 0.66 m), and `can_climb` is not enabled in this chapter. The fall guard only triggers 20 m below (player.gd:329).
- A player who steps off the planks lands in the moat with no rescue. The cross loop (D:220) just keeps waiting, and the `retreat` phase never ends because `_arrived` needs |y| < 1 (D:598).
- The only exits I could find are stone ramps at |x| 38-47 (assault.gd:329-330), 14-23 m along the moat from the lane (x = -24).
- UNSURE: whether those ramps lead out onto the near side. I did not verify the exit geometry.
- Fix: a rescue check in the cross loop and in `_process` during `retreat`: if `player.global_position.y < -1.5 and abs(player.global_position.x - LANE_X) < 6.0`, then `player.global_position = RETURN + Vector3(1.5, 0.05, 0.3)`, `player.velocity = Vector3.ZERO`, and `hud.bark("SPK_GIUST", ...)` with an existing line or a new one. Add hurt(10, Vector3.INF, true) if a penalty is wanted. This matches the 33o `_fish_out` pattern (A:1277).

**18. MED, D:203-210, long frozen start (~46 s, estimate).**
- Only the camera turn at D:209 (`player.face(leon...)`) needs a frozen player.
- Fix: keep `D36_N_01` and `D36_G_01` frozen (about 26 s). Then `hud.say_chain([["SPK_TOLGA","D36_T_01"],["SPK_GIUST","D36_G_02"],["SPK_LEON", leon_key]])` with the player free, and an objective with a "listen" text (new string, such as "Giustiniani'yi dinle") and a marker on `giust`.
- Do not start `_advance_men()` or the cross objective until `while hud.chain_busy(): await get_tree().process_frame`. Remove or keep the `player.face(leon)` before the chain so the camera does not snap.
- A free player can walk ahead; to prevent early crossing, start the chain when the player is still at the ramp foot (RETURN) and `phase = "cross"` only after the chain.

---

## Cross-chapter notes

- Gamepad: all objectives and prompts go through `pad_text` or `tr_pad`, so key names are fine.
- Controls for ladders (33o), the RowMeter (Space) and the crew steps are shown by the objective or prompt where needed. Only the ladder (W) is untaught (LOW, above).
- Chapters 34o and 35o can be started from the menu without earlier context. Every key is introduced where it is first used (E, F, Space, A/D, hold E), except the ladder in 33o.
- No stale-objective findings above LOW. Free windows with an empty objective: A:983-990 (frozen, so fine), B:570-575 (1.5 s), B:853 (3 s), C:754-756 (2.5 s).
