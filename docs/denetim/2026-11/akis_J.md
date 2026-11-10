# Player-guidance audit: 37o, 38o, 39o, 41o, 42b, 43o

Method: code walk only (flow traces were missing). All durations are ESTIMATES: speech length ~ chars / 17 per second
(hud.say uses 0.85 x voice length, so real values can be +-30 percent). File paths are relative to /home/user/nothistorygame.
No dialogue changes are proposed anywhere. "Free" = say_chain / bark while player.frozen = false.

Severity summary
- HIGH: 1 (37o ditch before the plank, UNSURE)
- MED: 37o x5, 38o x2, 39o x4, 41o x1, 42b x2, 43o x3
- Everything else is LOW and listed at the end of each chapter.

---------------------------------------------------------------------------------------------------------------------
## 37o  scripts/chapter37o.gd  (first assault)

Step walk
1. Intro (214-219): Nihat, Tolga, Urban, Tolga, Urban, Turgut, Tolga, then FREE with objective UI_OBJ37O_URBAN
   "Urban'ın bataryasına git" + marker on Turgut (240). E prompt UI_PROMPT37O_CYMBAL exists.
2. March (269-366): objective UI_OBJ37O_BEAT "Davulla birlikte zili çal (işaret yeşilken Space)", qte UI_OBJ37O_SHIELD
   "Ok! Kalkanı kaldır (C basılı), ritmi bırakma". Arrow window 2.4 s, hit is judged at its end (347-357), arrows are
   spawned at 0.4 s with 2.0 s flight (346), so visual and judgement agree. Failure = hurt 20 (not lethal), no progress lost.
3. Plank (407-497): objective with marker, prompts E, then A/D balance. BalanceMeter draws the A/D key names itself
   (scripts/ui/balance_meter.gd:40-46), so the keys ARE shown. Falling = 20 dmg, objective CLIMBOUT "(Space)", marker. Fair.
4. Stockade (508-606): objective UI_OBJ37O_HOOK "(E) fıçı n/5" + marker on the next barrel, then UI_OBJ37O_PULL "Space on the
   green". Hook cone 9 deg / 18 m. Cut rope on a bad pull -> throw again (fair). 180 s cap (545) ends silently.
5. Sally (749-781): duel; sword HUD hint is permanent (scripts/combat/duel.gd:1065), fine. Lost duel ends the phase with a
   spoken line + card UI_CH37O_SALLY_LOST. Clear.
6. Drag (793-905): objective DRAG "(W basılı · ip kayınca E)" + marker, prompt GRIP, fire pots telegraphed by shadow. OK.
7. Dawn/end (953-969): spoken wrap-up, dossier page, flowchart with 37O.1/37O.2. Clear.

### HIGH
- [HIGH, UNSURE] 37o | chapter37o.gd:410-437 (+ scripts/level/land_walls.gd:781) | Climbing is only enabled at line 437, AFTER
  the plank is down. The pad ends exactly at the ditch (z 36, line 124-129); there is no railing, the E-trigger "edge" is
  only 1.6 m deep (137). A player who runs past it (or walks off before picking up the plank) drops 2.9 m into the ditch with
  can_climb = false (scripts/player/player.gd:123), cannot get back up the 3 m solid wall (line 128-131), and the loop
  `while not _plank_down` (413) has no timeout. The tongue at the breach lets them walk out on the far side, where Trespass
  (110) puts them at _stockade_spot, still below the near bank. Player: stuck, plank pile unreachable, chapter cannot advance.
  UNSURE only because I could not verify the ditch ends at |x| > 32. Fix: call
  `player.enable_climb([Rect2(-32.0, 14.0, 64.0, 98.0)])` at line 410 (same rect as 437) and also add a 120 s fallback
  in the loop at 413 that teleports the player to PLANK_PILE and says nothing (or barks UI hint).

### MED
- [MED] 37o | chapter37o.gd:571 (+ 540, 601, ui/tespit_cam.gd:135) | The hook is thrown with `interact` (E), and so is the Tespit
  photo. TespitCam is active the whole stockade phase and the whole sally (cam.stop only at 601), target = Giustiniani who
  stands on the crest right next to the barrels (178, 531), cone 12 deg. Aiming at a barrel very likely has Giustiniani in the
  cone, so the prompt "[E] Tespit et (fotoğraf)" appears while the objective says "(E) fıçı". One E press both throws the hook and
  takes a photo (flash, camera_hide, 1.8 s hold). During the sally the same E is the finishing key (UI_DUEL_FINISH_HINT) and
  also fires the camera. Player: first E does something else than the objective said, later E in the fight triggers a photo.
  UNSURE only about exact geometry. Fix: in the loop gate the hook with `and not cam.in_frame()` is wrong (blocks the hook);
  rather start the camera in two steps: `cam.start()` at 540 only after barrels_down >= 1 with an objective "Giustiniani'yi
  kadraja al (E)" (UI_OBJ37O_PHOTO already exists in strings.csv:6139 but is never used), and call `cam.stop()` before
  `_sally()` (line 591), restart after it.
- [MED] 37o | chapter37o.gd:240 + strings.csv:6130 | Objective UI_OBJ37O_URBAN says "Urban'ın bataryasına git" ("Go to Urban's
  battery") but the marker is on Turgut (240) and the action is "E: zili al" from Turgut. The player is already standing at Urban's
  battery (208), so the text reads as "you are there" while the cymbal giver is 8 m away. Fix: new/updated string
  "Azap Bölükbaşı Turgut'tan zili al (E)" and keep the marker.
- [MED] 37o | chapter37o.gd:310-318, 338 + UI_OBJ37O_SHIELD | The arrow prompt says "ritmi bırakma" (keep the rhythm) but while the
  shield is up every Space stroke is judged bad: `good = pop_front() and not shield_up` (314); result is half a step and the bark
  D37O_AB_BEAT_BAD each time. Player is told to press and is punished. 38o handles the same case correctly
  (chapter38o.gd:439 skips meter.press while crouching). Fix: guard line 310 with `and not shield_up`, and change the qte string
  to "Ok! Kalkanı kaldır (C basılı) — ritim bekler".
- [MED] 37o | chapter37o.gd:214-219, 237-238 | Frozen intro ~59 s (N_01 14, T_01 9, U_01 10, T_U1 8, U_02 5, then AB_01 10, T_02 4) before
  the first control. Free candidates with no cut/choice: N_01 + T_01 (the radio briefing, ~23 s) via `hud.say_chain` while the
  player is free with objective UI_OBJ37O_URBAN; Urban lines stay frozen (the player stands 3.4 m in front of him, 208).
  Result: longest frozen stretch ~36 s. Honest note: the gain is small because Urban/Turgut need the player near them.
- [MED] 37o | chapter37o.gd:962-967 | End talk after the drag: HZ_02/AB_06 ~12 s, then T_END_x 7, U_03 2, T_U2 4, U_04 8, N_END 16 = ~49 s
  frozen with nothing to decide. Could be say_chain with objective "Urban'ı dinle" (UI_OBJ-style) but there is no action; value
  low, listed only because of the 25 s rule.

### LOW
- chapter37o.gd:433-434: objective cleared and `T_PLANK` (~5 s) spoken while the player is free -> ~5 s free with no objective.
- chapter37o.gd:630-655: hook that misses (no barrel within 9 deg / 18 m, or Giustiniani/other) just falls and reels in after 1.6 s,
  no bark or text. Loop picks the LAST barrel index in the cone (638-640), not the one the marker shows. Fix: bark
  D37O-style hint or short qte "Fıçının çemberine nişan al" on a miss.
- chapter37o.gd:839-854: rope slip window is 1.0 s and first slip comes at 6 s; stake (Hızır's fate, 900-902) not signalled.
  Fix: raise window to 1.5 s for the first slip, and add "(Hızır'ı düşürme)" to UI_OBJ37O_DRAG when `_hizir`.
- chapter37o.gd:541: photo only announced by a 4 s bark; objective is overwritten every frame by `_stockade_objective` (551).
- chapter37o.gd:545: the 180 s stockade cap ends the phase without any spoken or visual cause.

---------------------------------------------------------------------------------------------------------------------
## 38o  scripts/chapter38o.gd  (Golden Horn walls)

Step walk
1. Intro (322-329): 6 lines frozen (~55 s), then a phase banner.
2. Row (420-491): objective UI_OBJ38O_ROW2 "çizgi YEŞİL alandayken Space · iyi vuruş n" + marker on the wall; qte UI_OBJ38O_COVER
   "Çömel (C basılı)" for 2.2 s, judged at the end (475-483), arrows land at 1.6-2.1 s: consistent. No Space stroke while crouched (439). OK.
3. Ladder hold (530-663): 45 s, objective HOLD2 with seconds, A/D keys drawn by the meter, fork qte "SPACE" 2.0 s window (Fork 3 times),
   fire qte 10 s with objective SAND + marker, then THROW + marker. Slips are explained (bark) and cost nothing but a flag. Fair.
4. Climb (796-851), Explore (857-923): objective with marker; QTE for stone/oil; explore has a visible countdown and "continue" key. OK.
5. Dawn (955-1033), rope (1113-1197), rescue (1200-1310): objective + prompt + chase bars + qte; rope capped at 40 s, rescue at 30 s with a
   graceful fallback (old sailor pulls). Fair.
6. Petrion choice (1341): two clearly different options. 7. Chase (1350-1482): objective CHASE2 + marker, ring qte with A/D. 8. End talk.

### MED
- [MED] 38o | chapter38o.gd:322-329 | Frozen intro ~55 s (N_01 15, T_01 8, R_01 10, T_R1 3, N_BRIEF ~9, R_02 11) with the player seated
  (pinned, 316). Only R_02 (rowing instruction, "Yeşil yerde çek") must come immediately before the row. Lines N_01..N_BRIEF
  (~45 s) can run as `hud.say_chain` with `player.frozen = false` (looking around only; no cut, no choice, speakers are fixed on the
  boat) and an objective like "Reisi dinle" with the marker on the wall; keep R_02 frozen. Gain is small (seated player), so
  LOW-MED.
- [MED] 38o | chapter38o.gd:1485-1490 | After the chase the player is frozen for N_BOOM 12 + N_CRETE 11 + R_END 8 + T_END 10 + N_END 8 =
  ~49 s with no action (the boat is stopped). Candidate for say_chain + objective "Kaydı dinle" or at least split by the stats page.
  Also 955-1033 (dawn, S2_02..R_04 ~27 s) is borderline.

### LOW
- chapter38o.gd:1386-1396: the chase has a hard 42 s timer (1406) and an optional photo; objective UI_OBJ38O_CHASE2 mentions only the
  rowing. The photo key (E) is shown only by the TespitCam prompt when the ship is in the 14 deg cone. Fix: add "gemiyi kadraja al (E)" to
  UI_OBJ38O_CHASE2.
- chapter38o.gd:583: while the player is away at the fire (`_holding` false) the ladder gets random pushes with no input, so a slip can
  happen unattended (594-603, costs only a bark and 1.2 s). Fix: skip the random term when `_fire_t >= 0`.
- chapter38o.gd:1163-1164: rope: let-go qte appears at tension 0.65, snap at 0.9; at high drift (rate ~0.8/s) that is only ~0.3 s. The
  tension bar is visible all the time, snap only loses the current wrap, so LOW.
- chapter38o.gd:929-938: stone qte gives 0.8 s of fall time; a first-time player who keeps holding W takes 30 damage.
- chapter38o.gd:1341-1344: Petrion choice consequences are not hinted (Çavuş's later line in 39o depends on it).
- chapter38o.gd:1491: 38O.1 needs forks_braced >= 2, fire_ok and tolga_pulled, all hidden until the stats line.

---------------------------------------------------------------------------------------------------------------------
## 39o  scripts/chapter39o.gd  (banners, church door, fire, watch)

Step walk
1. Intro (146-153): N_01 14, T_01 6, C_01 9, (C_01_ADD 9 if petrion_word == add), C_02 9, TW_01 10, T_02 4 = ~52-61 s frozen.
2. Banners (168-243): objective UI_OBJ39O_FLAG "Listedeki kapılara Sultan'ın sancağını dik (E) · n/6" + six riddle hints, NO marker (251).
   Prompt E on every door (313-316); a wrong door gives a bark + stagger 0.4 s (338-341). Cap 180 s (18), looters at 50/100/150 s (179).
3. Church door (440-581): objective changes (DOOR/FIND/COMING/LEAD), door bar UI_CH39O_DOOR visible, door breaks after ~50 s base (+15 s per
   shown warrant, up to 3); 100 s if 38O.1 helper. Break at 0 -> çavuş comes by himself after 40 s (529-531). No soft lock.
4. Fire (751-897): objective with countdown, smoke C, lowering E + A/D (keys drawn by the meter). 90 s cap, then roof falls (explained by J_ROOF).
5. Watch (930-1005): objective SIT; 3-way answer; photo objective with marker; spoken ending; 39O.1/39O.2.

### MED
- [MED] 39o | chapter39o.gd:251, 277-305, 179-182 | Doors are found only by six riddle lines, no marker at all, a hidden 180 s cap,
  and three looter runs (50/100/150 s) that each take the door FARTHEST from the player (286-292). The looter announcement is a 2.5 s bark
  D39O_SA_FLAG + crowd sound (304-305): it does not say which door. Player: after the first "Bu kapı benim!" they cannot tell
  which door to defend; 39O.1 needs at most one lost door (1003). Fix: (a) when a looter is sent, pass the contested door as marker:
  `hud.set_objective(text, city.door_pos(idx) + Vector3(0,2.6,0))` for the run duration; (b) after 40 s without a planted banner, mark the
  nearest unflagged LISTED door the same way; (c) mention the Space-over-rubble shortcut in UI_OBJ39O_FLAG (it is only in UI_OBJ39O_FIND,
  line 504, a later phase, while climbing is already enabled at 171).
- [MED] 39o | chapter39o.gd:146-153 | Frozen intro ~52-61 s. Free candidates: N_01 + T_01 (~20 s radio-style briefing) as say_chain while the
  player stands in front of the çavuş is awkward (he looks at them); better TW_01 (the riddles, 10 s) as a chain DURING the banner phase with
  the objective already visible, because it carries the door clues. Fix: after C_02 call
  `hud.say_chain([["SPK_TOWNSMAN","D39O_TW_01"],["SPK_TOLGA","D39O_T_02"]])`, free the player and run the flag loop while `hud.chain_busy()`.
- [MED] 39o | chapter39o.gd:571-581 | After the door: C_03 7, T_DOOR_BROKE 6.5 (conditional), SA_02 6.5, C_04 7, T_04 6.5, PR_02 7, T_05 3 =
  ~37-44 s frozen (sailors walk away with a tween at 575-577, Stage.walk at 568 is script-driven). The conversation has no cut and no choice;
  after the Stage.walk the last four lines (C_04, T_04, PR_02, T_05) can be a say_chain with the player free and an objective like
  "Papaza ve çavuşa kulak ver" before `_fire()` starts. Same for 461-466 (PR_01, T_03, SA_01 + memory SA_38_x/T_38_x, 13-29 s): fine as is.
- [MED] 39o | chapter39o.gd:1000-1002, 999 | After the photo: N_PHOTO_OK 6, C_END 8, T_END 7, N_END 7 = ~27 s frozen, preceded by watch dialog
  J_01 7 + SA_03 5 + J_x 5 + N_EMP 12 = ~29 s before the photo (choice in the middle). Borderline; list only.

### LOW
- chapter39o.gd:797-798: when `_man_follow` is true but the player is outside the room (`inside` false) the objective falls back to
  UI_OBJ39O_FIRE "Ev yanıyor! Cumbaya tırman" (stale). Fix: pick LOWER whenever `_man_follow`.
- chapter39o.gd:322-336, 354-355: the axe-handle struggle (door_hp < 25) is only discoverable by looking at the sailor (prompt
  UI_PROMPT39O_AXE). Fix: add it to UI_OBJ39O_DOOR when door_hp < 25.
- chapter39o.gd:979-981, 988: photo prompt/key only from the camera; objective UI_OBJ39O_PHOTO has no key name.
- chapter39o.gd:968: answer options are distinct; consequence hint is the spoken reply, none shown. OK.

---------------------------------------------------------------------------------------------------------------------
## 41o  scripts/chapter41o.gd + scripts/combat/drill.gd

Step walk
1. Intro (178-185): N_01, (teacher walks), H_HELLO, T_01, H_02, T_02, H_03.
2. Drill.directions (drill.gd:249-276): frozen dir_1 + dir_2, then objective UI_DRILL_DIR_x per guard, bark help at 14 s, auto-advance at 45 s.
3. blocking (285-322): objective UI_DRILL_BLOCK; 70 s cap; teacher barks on misses.
4. parrying (325-358): UI_DRILL_PARRY, 8 tries / 80 s cap, teacher soft-passes.
5. kicking (430-533): demo, then UI_DRILL_KICK / KICK_FOLLOW / KICK_DOWN; caps 70/80 s; teacher soft-passes.
6. finishing (579-662): UI_DRILL_FIN_x per step with the keys written; 60 s cap per step; wrong-move bark.
7. Ladder (chapter41o.gd:216-261): H_LADDER_1/2 + T_LADDER ~23 s frozen, objective UI_OBJ41O_CLIMB (W, stop for bag, A/D for water) + marker,
   QTE UI_QTE41O_BAG / WATER. Bag lands 1.25 s after the QTE (302-310); hit = fall, retry, nothing lost. Fair.
8. spar (drill.gd:707-751): objective UI_DRILL_SPAR (4 clean blows or one finisher), 75 s, god mode, loss explained by H_SPAR_STOP.
9. Photo (393-415), end talk (418-424) ~19 s, outcome in flowchart. Clear.

Verdict: the drill is well-guided (every lesson shows its own keys, has a time cap and a teacher fallback, no soft lock, player cannot die).
Findings:

### MED
- [MED] 41o | chapter41o.gd:178-185 + scripts/combat/drill.gd:255-256 | The first control comes after ~70 s of frozen talk: N_01 10, walk 3,
  H_HELLO 10, T_01 8, H_02 10, T_02 5, H_03 10 (~56 s), then dir_1 7 + dir_2 7 in the first lesson with the duel already running. Free
  candidates without any cut: `D41O_H_DIR_1` and `D41O_H_DIR_2` (Drill._say_h at drill.gd:255-256) can run as `hud.say_chain` while
  the objective UI_DRILL_DIR_TOP (261) is already shown and the dummy stands (the lesson re-explains itself through the objective and
  `_bark_h("dir_help")`). Same helper applies to 42b. Partial fix for the intro: T_02 + H_03 as chain with the objective
  "Turgut'u dinle: sonra kuklaya vur" (the dummy is shown at the same time).

### LOW
- drill.gd:430-447: kick demo run: P_KICK 6 + H_KICK_DEMO 3 + walk/kick/P_KICK_DEMO ~12 + H_KICK_1 9 = ~30 s frozen; justified
  (the player must watch; `player.face` is scripted at 413).
- chapter41o.gd:401, strings.csv:6178: photo objective "Tespit karesi: talim eden bölük" does not name E; the prompt appears only
  when the target is in the 20 deg cone and within 30 m. 40 s cap then moves on silently.
- drill.gd:325-358: after parry_ok a 3 s `_wait_idle` plus bark runs with the player free and no objective (357); trivial.

---------------------------------------------------------------------------------------------------------------------
## 42b  scripts/chapter42b.gd + scripts/combat/drill.gd

Same Drill (see 41o). Chapter-specific part is the ladder push (204-366): H_LADDER_1/2 frozen (~12 s), objective UI_OBJ42_UP + marker on the
platform head, then rounds: prompt UI_PROMPT42_PUSH "E basılı tut: merdiveni it" when near the head, bar UI_CH42_PUSH, late = climber pokes,
bark H_PUSH_LATE, fade-reset, up to 4 tries per round, then moves on. Climb speeds 0.55 / 0.85 m/s. Fair, no soft lock (90 s fallback at 216-222).

### MED
- [MED] 42b | chapter42b.gd:223 | `hud.set_objective("")` is called as soon as the player reaches the ladder head, then the player is
  FREE for the whole push drill (2 rounds, ~20-40 s plus retries) with no objective (WARN_FREE_NO_OBJECTIVE territory). The only guide is the
  E prompt, shown only while standing within 1.6 m of the head (280-282) and during a climb. If the player wanders to look at the climber
  or walks back down, there is no text telling them to return. Fix: replace line 223 with
  `hud.set_objective(tr("UI_OBJ42_PUSH"), _head())` ("Gönüllü tırmanınca merdivenin başında E basılı tut") and clear it after the second push (before 245).
- [MED] 42b | chapter42b.gd:162-171 + drill.gd:255-256 | Frozen intro ~70 s: N_01 12, walk 3, H_HELLO 9, T_01 7, H_02 2, Leon walks (167) 4,
  P_HELLO 7, T_02 7, H_03 7, dir_1 6, dir_2 6. Same fix as 41o (dir_1/dir_2 as say_chain after the objective is shown; P_HELLO..T_02 could
  be a chain while the player walks to the dummy).

### LOW
- chapter42b.gd:378, strings.csv:7988: photo objective "Tespit karesi: talimi izleyen Giustiniani" without key name; 40 s cap.
- chapter42b.gd:225-241: a missed round is explained (H_PUSH_LATE) and restarted with a black dip; up to 4 tries then silently counts as
  done (pushed stays lower). Fine.

---------------------------------------------------------------------------------------------------------------------
## 43o  scripts/chapter43o.gd  (drone for the Sultan)

Step walk
1. Radio intro (211-217): 6 lines frozen ~35 s. 2. Walk (220-239): objective UI_OBJ43O_OTAG + marker. 3. Box scene (242-268): ~32 s, a
choice (Q1), ~14 s after.
4. Power (272-292): objective UI_OBJ43O_POWER + marker, E prompt; flight help line UI_DRONE_HELP (all keys, pad variant) shown at 292.
5. Flight goals: HOVER 5 m (295), KITCHEN with marker (301), lens-covered choice (310), HIGH + face the walls with marker (328). Each `_until`
   has a 240 s cap and a battery floor of 25 percent (813). Fair.
6. Sultan learns (336-418): three quizzes; no timer; only `lessons` counts, no penalty.
7. Sees (421-455): ~50 s of Sultan flying + dialogue; choice ST at 442.
8. Photo (458-484): objective + marker on the Sultan, 40 s cap.
9. Last flight (487-573): objective CAULDRON + beacon + battery on feed, 70 s / battery cap; miss -> "djinn" ending branch; end talk.

### MED
- [MED] 43o | chapter43o.gd:259, 313, 319, 447, 450, 554, 39 (BAD_LIMIT), 577 | Hidden strike counter. Q1 "Uçmaz" +1 (259), DARK A and C +1 each
  (313, 319), ST B and C +1 each (447, 450), missing the cauldron +1 (554). Three strikes -> 43O.2 (chains, 585 `_chained`). Nothing on
  screen shows the tally, the limit or which options count: "cloud" (DARK A) is penalised while "shy bird" (B) is not, and Nihat's whisper
  ("Uçmaz deyin") pushes the player toward the penalised Q1 option. Player: ends in chains without knowing why. Fix: show a small bar for 3 s
  after each choice with `hud.set_chase(tr("UI_CH43O_SUSPICION"), bad / float(BAD_LIMIT))` (new string, e.g. "Zağanos'un şüphesi"), and
  keep the final stats line (945). No dialogue touched.
- [MED] 43o | chapter43o.gd:246-268 (+ choice at 256) | Box scene is ~32 s of frozen talk before the first choice (U_01 7, Z_01 8, F_01 1,
  T_READ 8, F_02 6, N_WHISPER 3). No cut or camera path is involved, but `player.face` is scripted at 244, 250, 252, so a free player would be
  yanked. Possible: U_01..F_02 as `say_chain` with the objective "Sultan'ı dinle" and the three `player.face` calls dropped (the camera
  focus is done by hud). UNSURE, because the scripted look is part of the staging.
- [MED] 43o | chapter43o.gd:424-436 | Sees: fly_to front (~11 s) + F_VIEW1 6, Z_VIEW1 3, F_VIEW2 6, fly 10 + F_OVER 4, T_OVER 4, F_FENCE2 3, F_VIEW3 6
  = ~50 s with no input, player frozen since 286. Not guidance-fixable without gameplay change; option: keep `drone.pilot(true)` and leave the
  player flying (the Sultan's autopilot is replaced by a marker "Surların içine geç") — but that is a design change, so only flagged.

### LOW
- strings.csv:8436-8452 vs 8377-8378: quiz options talk about "left stick / right stick" (UP_A "Sol çubuğu yukarı itin", TURN_A, FWD_A) while the
  player's own flight help is "W/S/A/D, Space: yüksel, Fare: yön". A keyboard player cannot derive the right option from what they flew; the
  pad scheme is also different (A climbs, right stick turns). No penalty (only `lessons`, 355/376/402), so LOW. Fix: show the DRONE_HELP prompt
  while the quiz is open, or accept anything silently.
- chapter43o.gd:552-556: failing the last flight is explained only by dialogue; the feed shows battery (drone.gd:462) but no "battery low"
  message. Fix: `hud.bark`-style qte "Pil bitiyor!" at battery < 12 percent, as in the feed.
- chapter43o.gd:466, strings.csv:8386: photo objective has no key name; 40 s cap.
- chapter43o.gd:489: `while drone.auto_target != Vector3.INF` has no timeout (UNSURE, fly_to should always finish).
- chapter43o.gd:575-589: end talk ~35 s frozen (F_END 16, N_END 12, T_END 3, N_END2 3); no action possible.

---------------------------------------------------------------------------------------------------------------------
## Quick matrix (what tells the player what to do)

| Chapter | Objective + marker | First-time controls shown | Hidden timers | Soft lock |
|---|---|---|---|---|
| 37o | yes (Turgut text wrong) | E, Space, C, W in strings; A/D from meter | 180 s stockade, hidden 120 s Hızır | ditch before plank (UNSURE) |
| 38o | yes | yes (keys in every objective/qte) | 42 s chase, 45 s ladder (shown) | none |
| 39o | flags: no marker | E, C, A/D; Space rubble only later | 180 s flags, door ~50-100 s (bar) | none |
| 41o | yes | yes (Drill strings) | caps with teacher fallback | none |
| 42b | yes until head, then none | yes | 90 s fallback | none |
| 43o | yes | DRONE_HELP | 70 s last flight, 240 s caps | none |
