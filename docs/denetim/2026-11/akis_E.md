# Player-guidance audit E: chapters 19, 19o, 20, 20o, 21, 21o, 22

Method and limits
- The flow traces for these chapters do not exist yet (flowall/ has ch4..ch18 only), so everything below comes from the code and strings.csv.
- Frozen durations are ESTIMATES from line length (about 0.065 s per character, voiced, including gaps; real value = voice length x 0.85 + gap). Treat them as +/- 25 %.
- Basics: no chapter in 19..22 calls hud.show_controls (only ch0, ch1, ch2 do). In practice every action carries its key in the prompt or objective ("[E] Al: ...", "(A/D)", "(Space)", "[E basili] Kaz"), and Duel / Handgun / CannonCrew / TespitCam draw their own key hints. So a menu-start player is not lost on keys. Plain WASD / mouse look is never shown (LOW, one line, no fix needed).
- Timed choices (`hud.choose(..., timeout)`) are inactive unless the player enabled "Sureli kararlar" (hud.gd:3031). Timeouts below only matter in that mode.
- Chapter end is clear in all seven: Siege.show_page + flowchart with "UI_FLOW_CONTINUE", outcome node highlighted. Not repeated per chapter.

---------------------------------------------------------------------------
## SUMMARY OF HIGH / MED

HIGH
- H1  ch20  chapter20.gd:523-531, 565-572, 305-310, 265-275 : wrong/stale load cannot be put down -> player stuck carrying until the next cannon hit.

MED
- M1  ch20  chapter20.gd:253-261 : first cannon warning gives "get behind the mantlet" with no marker for the mantlet.
- M2  ch20  chapter20.gd:241-243, 358-398, 527-528 : night clock keeps running during assault + duel while delivering is blocked; real repair window is only about 88 s of the displayed night.
- M3  ch20  chapter20.gd:180-191 : about 31-36 s frozen opener.
- M4  ch19  chapter19.gd:212-224 : about 33 s frozen opener; the sheet mechanic is only taught at the end of it.
- M5  ch19o chapter19o.gd:274 : "find the shadow at the gap" has no marker (25 s auto-spot is the only safety net).
- M6  ch19o chapter19o.gd:260-263 and 422-429 : openers of about 30 s and about 25-34 s frozen.
- M7  ch19o chapter19o.gd:430-432 : gun-phase marker is a static point, the brigantine moves away from it.
- M8  ch20o chapter20o.gd:145-153 : about 31 s frozen opener (up to about 65 s with the optional gun-history lines).
- M9  ch21  chapter21.gd:210-230, 382-384, 396-410 : openers of about 30-38 s, about 33 s, about 40 s frozen.
- M10 ch21o chapter21o.gd:201-205 : about 29 s frozen opener (the photo order is in its last line).
- M11 ch21o chapter21o.gd:397-425 : escape begins facing away from the exit, with an invisible smoke front that fails the player 2 s after control returns.
- M12 ch22  chapter22.gd:188-192 and 203-224 : dawn about 32 s and night about 27 s (plus cologne choice) frozen.
- M13 ch22  chapter22.gd:488-492 : a double tap of E on the chute releases the barrel at fuse 0 and wastes it.

---------------------------------------------------------------------------
## CHAPTER 19 (brigantine in disguise) scripts/chapter19.gd

Flow of required actions
1. Opener, frozen: D19_N_01 (or _NOFEZ), D19_C_01, D19_T_01, D19_C_02, D19_C_SHEET (lines 212-222). Estimate about 33 s, plus title card 2.8 s and fade. Then `_take_sheet()` and objective UI_OBJ19_SHEET "Yelken halatini tut: ruzgara gore sal ya da cek (A/D) - yelken cirpinmasin" (no marker, none needed). BalanceMeter shows keys (show_keys = true). Objective and code agree (A/D axis, error above 0.55 for 1.2 s = flap). Failure = ship slows for 2 s plus a whispered bark, never a fail. Fair.
2. Patrol: frozen, D19_P_01, D19_C_WHISPER, then choice (SALAM / INSURE / SILENT [/ TEZKIRE]). Options are distinct and funny; consequence (suspicion) is only a stat. Pre-choice frozen about 9 s, post-choice about 15 s (up to about 30 s with the tezkire branch). Fine.
3. Aegean: cards, D19_C_EMPTY, D19_T_EMPTY (about 9 s), then free with UI_OBJ19_PHOTO "Tespit et: bos ufuk" and marker on the horizon (line 370). The player is turned toward the captain (line 365), i.e. away from the horizon, but the marker shows the way and TespitCam prints "[E] Tespit et" when in cone. Fine.
4. Vote: frozen D19_C_VOTE, D19_S_FLEE, D19_S_RETURN, [GRAIN], [SAVED], D19_C_ASK, then choice UI_C19_RETURN / UI_C19_FLEE (no timer). Estimated frozen before the choice: about 26 s base, up to about 53 s with GRAIN + SAVED + TEZKIRE lines. After the choice another 15-25 s, then the return scene (D19_NK_01 .. D19_N_END, about 28 s, up to about 40 s) before the chapter page.

Problems
- M4 (MED) chapter19.gd:212-224. The opener is about 33 s frozen and the only mechanic of the chapter (sheet, A/D) is introduced at its very end. The ship does not move before `phase = "sail"` (line 226), the player is pinned, so freeing him earlier gives nothing by itself. Minimal fix: move `_take_sheet()`, `hud.set_objective(tr("UI_OBJ19_SHEET"))`, `player.frozen = false`, `phase = "sail"` to right after D19_N_01 + D19_C_01/D19_T_01, and play `hud.say_chain([["SPK_BRIG","D19_C_02"],["SPK_BRIG","D19_C_SHEET"]])` while the player already trims. The patrol is about 18 s of sailing away (PATROL_AT 0.62 of 104 m at 3.6 m/s), so add `while hud.chain_busy(): await get_tree().process_frame` at the top of `_patrol_scene` (line 246) before it freezes the player and shows the boat. Net: frozen stretch drops from about 33 s to about 17 s and the sheet is learned in the first minute.
- LOW chapter19.gd:325. After the patrol the objective becomes UI_OBJ19_SAIL2 "Marmara'ya acil" but the sheet meter and flap penalty continue until line 345 (`_aegean`). The A/D reminder disappears from the objective while it still matters. Fix: reuse UI_OBJ19_SHEET text at line 325 (or append the key hint to SAIL2).
- LOW chapter19.gd:378-386. The photo wait ends silently after 45 s (3 s in tests) and Nihat then says D19_N_EMPTY "Bir hicligi fotograflad..." even when no photo was taken. Fix: after about 20 s without `cam.done`, `hud.bark("SPK_NIHAT", ...)` with an existing Nihat hint, or at least skip the "you photographed" wording by checking `cam.done`. (Same pattern in every Tespit step of this audit: 19o:394, 20:659, 20o:458, 21:341, 21o:221, 22:453.)
- LOW chapter19.gd:291 and 467. With "timed decisions" ON, patrol timeout (10 s) falls in the `_` branch = silent (same as option 3) and the red bar is the only warning. Acceptable.
- LOW vote scene (chapter19.gd:447-464) is a pure listening scene with nothing to do; its worst case about 53 s is a cutscene by nature (choice at the end, nothing to control). If shortened is wanted, the two optional memory lines (D19_S_GRAIN_*, D19_S2_SAVED) could be `say_chain` with objective "Tayfayi dinle" but the gain is only freedom to look around, which already works frozen.
- No soft lock found: sail progress depends on distance only; photo step is time-limited; all other steps are cutscenes.

---------------------------------------------------------------------------
## CHAPTER 19o (patrol) scripts/chapter19o.gd

Flow
1. Opener frozen: D19O_N_01, D19O_R_01, D19O_T_01, D19O_R_02 (lines 260-263), about 30 s. R_02 is the rowing tutorial ("Yesilde cek"); objective UI_OBJ19O_ROW "Kurek cek (ibre yesildeyken Space)" (pad variant exists) is shown only after it. Marker: none (not needed). Row speed never drops below 2 m/s, so doing nothing cannot soft-lock (about 20 s to the spotting point).
2. Watch: objective UI_OBJ19O_WATCH "Zincirin acikligindaki golgeyi bul ve goster (bak + E)" with NO target (line 274). Condition: E while the camera is within 12 degrees of the brigantine (line 284), or auto-spot after 25 s. The ship starts about 100 m away at night; the line D19O_R_WATCH gives no direction.
3. Meet: frozen D19_P_01, D19O_C_ANSWER, D19O_T_NOTICE (about 18 s), then choice UI_C19O_TELL / WISH / SILENT, then 8-12 s of consequences. Consequence is only the ending line and note; options are distinct. OK.
4. Photo: UI_OBJ19O_PHOTO with moving marker (ship child target), 30 s window, ship leaves at 4 m/s and exceeds the 120 m camera range after about 28 s (lines 376-402). Window and range roughly agree. OK.
5. Chase intro frozen: D19O_R_BACK, D19O_T_BACK, D19O_R_GUN, handover, [HOOKS line] (lines 422-429), about 25 s, up to about 34 s. Then GunRange (4/5/2 shots, objective with count). Then the chase.

Problems
- M5 (MED) chapter19o.gd:274. Add the pattern already used at line 441: `hud.set_objective(GameState.tr_pad("UI_OBJ19O_WATCH"), ship, 3.0)`. Without it a first-time player scans a dark sea for up to 25 s and may never learn that E is the action; the auto-spot then plays "Orada!" without any input.
- M6a (MED) chapter19o.gd:260-263. About 30 s frozen before the first rowing stroke. Fix: set `phase = "row"`, `player.frozen = false`, `meter.enabled = true` and the ROW objective right after D19O_R_01, and `hud.say_chain([["SPK_TOLGA","D19O_T_01"],["SPK_PATROL","D19O_R_02"]])`. Rowing takes about 20 s before the watch step; line 275 `await hud.say("SPK_PATROL","D19O_R_WATCH")` waits for the chain automatically (hud.gd:1594). Frozen drops to about 14 s.
- M6b (MED) chapter19o.gd:422-429. Chase intro is 25-34 s frozen and opens with a shouted "Kurek! Zincire girmeden yetisin!" that is followed by "Kurek dursun!" 20 s later. The player is pinned in the boat, so freeing him changes nothing; the useful move is a shorter wait before the GunRange: start the GunRange objective right after the handover and play D19O_R_HOOKS_OK/BAD (line 474/478, optional, about 9 s) as `say_chain` during the first seconds of the shooting (the shot limit is 22 s plus 5.5 s per extra shot). Set `_rifle_shots` before the chain so the count is right.
- M7 (MED) chapter19o.gd:432. `"look": ship.global_position + Vector3(0, 2.0, 0)` is a fixed point, but during phase "shoot" the ship moves toward the chain at 2 m/s (line 510-511) for up to 22+ s, about 40 m. The gold marker drifts away from the targets. GunRange passes `look` straight to hud.set_objective (gun_range.gd:55), which accepts a Node3D, so use `"look": ship` (marker follows; offset via the default height or `Callable`).
- LOW chapter19o.gd:441-465. "Kurek cek: brigantine zincirden once yetis" suggests a catch-or-lose race, but `_outcome` depends only on `told` (line 465); `gap` is a stat and only changes one line. Not a guidance break, but players who row hard get no visible stake. Optional: no change.
- LOW chapter19o.gd:394-403 silent Tespit timeout (see ch19).
- Soft lock: none.

---------------------------------------------------------------------------
## CHAPTER 20 (breach: carry loads, take cover) scripts/chapter20.gd

Flow
1. Opener frozen: D20_N_01, D20_G_01 (Giustiniani walks up while Nihat speaks), D20_T_01, D20_G_02, D20_G_03, [LEON line] (lines 180-191), about 31-36 s. G_02 gives the order barrel -> earth -> plank, G_03 explains the cannon warning ("siperin arkasina gec").
2. Work: objective UI_OBJ20_FETCH "Depodan getir: %s (barikat %d/%d)" with marker on DEPOT, then UI_OBJ20_BRING "Gedige goturdugun..." with marker on the breach. Item prompts "[E] Al: fici" / "[E] Barikata koy". Clock: hud.set_chase "Saat 21.00 - safaga kadar" with bar (hud.set_chase at line 244). Objective, markers, prompts agree with the code (picks, delivery at "breach" interactable, order checked by `needed()`).
3. Cannon: lookout bark + stinger + QTE text UI_QTE20_COVER "TOP! Siperin arkasina gec!" 4 s before the shot (first one 16 s after control), slow motion. Cover is checked by `_exposed()` (x within 1.5 of a mantlet, z behind it, or farther than 9 m from the breach, or within 4.5 m of the depot). Hit = 40 damage, stagger, load dropped, minus 5 s, and every shot (covered or not) removes one repair row (line 307).
4. Assault at about 88 s: G_ASSAULT, objective "Hucum! Ok sandigini al" marker on crate, then "okcularin" marker; 30 s window; failure just a bark. Then gun phase (GunRange 4 shots), breach duel (2 waves), D20_G_REPELLED, back to work.
5. Dawn: UNFINISHED/DONE line, fade, optional tape choice, photo (UI_OBJ20_PHOTO + marker, 40 s), closing lines (about 25 s).

Problems
- H1 (HIGH) chapter20.gd:523-531, 565-572, 305-310, 265-275. There is no way to put a load down. `_pick` accepts any pile regardless of `needed()` (line 523-532), `_deliver` with the wrong item only barks D20_G_WRONG_* and returns (569-572), and picking while carrying only barks D20_T_FULL (524-526). `_drop()` is only called from the cannon knock (333), assault start (344), gun phase (487), duel (403), dawn (605) and a successful delivery. The wrong-load state is reachable without any mistake by the player:
  a) the player carries a barrel at repair 3; Niko (niko_friend) delivers every 15 s (265-275) -> repair 4 -> needed() = earth -> the barrel in hand is now "wrong";
  b) the player stands safely behind a mantlet carrying earth at repair 4; the shot removes a row (307) -> repair 3 -> needed() = barrel. Same at 6 -> 5 with a plank.
  The objective even keeps saying "Gedige goturdugun: toprak sepeti" (line 236 uses `carrying`), the marker points to the breach, and Giustiniani answers "Fici dedim" on every attempt. Escape is only the next exposed knock (which costs health, 5 s and another row) or the assault. Fix, two lines using existing strings: (1) in `_deliver` line 570-572 replace `return` by `_drop()` after the bark (the load goes back to the pile), and (2) in `_pick` after the `carrying != ""` check add `if phase == "work" and kind != needed(): hud.bark("SPK_GIUST", "D20_G_WRONG_" + needed().to_upper(), 3.0); return`, so the wrong pile is refused instead of taken. Also call `_drop()` when `repair` changes under a held load in `_fire` (after line 308) and in the Niko block (after line 270) if `carrying != needed()`.
- M1 (MED) chapter20.gd:253-261. The warning text names a "siper" but nothing marks it. The mantlets are at x -5.5 / 5.5, z 10 (land_walls.gd:20), three metres from the delivery spot, and a first-time player has had one line (G_03) about it. Fix: when the warning fires and `_exposed()` is true, `hud.set_objective(tr("UI_OBJ20_COVER"), nearest_mantlet + Vector3(0, 1.2, 0))` with a new key UI_OBJ20_COVER "Siperin arkasina gec"; `_fire()` already calls `_update_objective()` at line 313 and restores the normal objective. Alternatively `hud.spots` on the two mantlets for the 4 s.
- M2 (MED, UNSURE about intent) chapter20.gd:241-243, 358-398, 527-528. `_process` returns only for phases other than work/assault, so `_time` keeps draining during the whole assault, including the breach duel (limit 60 s per wave, line 436-445), while `_pick` refuses every pile except arrows (527-529) and phase "gun" refuses all interaction. The gun phase is explicitly paused (line 489), the duel is not. Result: the player has about 88 s of real repair time before the assault (night 170 s x 0.52), during which 2-3 cannon shots each undo a row and a trip depot -> breach -> depot takes roughly 10 s. Eight rows plus the rows lost need about 10-11 deliveries, so nearly every real player ends in 20.3 "yarim kaldi" (Giustiniani's D20_G_UNFINISHED is kind, but the clock gave no sign). Fix: tick the clock only in work: line 243 `if phase == "work": _time -= delta` (keep the HUD update), or at least bark the assault time ("Hucum gece yarisi") at the start. Decide by design; the trace will show the real numbers when recorded.
- M3 (MED) chapter20.gd:180-191. About 31-36 s frozen. Candidate for "free to listen": after D20_N_01 and `Stage.settle(giust)`, play D20_G_02, D20_G_03 and the LEON line as `hud.say_chain` while `player.frozen = false` with an objective "Giustiniani'yi dinle" marked on `giust` (the listen pattern). Keep `phase = "intro"` (so `_process` and `_on_interact` stay inactive: line 241, 692) until `hud.chain_busy()` is false, then `phase = "work"`, `_set_crew(true)`, `_update_objective()`. Nobody needs a fixed spot, no cut, no choice. Gain is about 14 s of free look/walk toward the depot.
- LOW chapter20.gd:343-344. The assault silently drops a carried load (`_drop()` in `_start_assault`); only the objective changes. A bark like D20_G_ARROWS_FIRST at that moment would explain. Same at 487 and 403.
- LOW chapter20.gd:607. A second knock-down (`player.downs >= 2`) makes the breach "incomplete" even with 8 rows; nothing ever tells the player. Optional bark at the second down (existing D20_T_KNOCK_3 already reacts).
- UNSURE LOW chapter20.gd:418 and 460-461 with GunRange ending `hud.set_objective("")` (gun_range.gd:106): between the gun phase and the duel the player may be free (frozen state is `was`, false) with an empty objective while D20_T_GUN_GOOD / D20_G_DUEL play; engine warns only after a blackout release, which does not happen here. Optional objective "Gedigi tut" with marker on the breach.
- Photo step OK (marker + prompt), silent timeout as noted.

---------------------------------------------------------------------------
## CHAPTER 20o (cool Urban's cannon with olive oil) scripts/chapter20o.gd

Flow
1. Opener frozen: D20O_N_01, U_01, T_01, U_02 (loading order and oil), U_SEVEN (lines 145-151) about 31 s; then optional named-gun lines (NAME_x about 10 s, FLAW about 8 s), gun history (EDIRNE_SHORT/OK about 10 s, BED_* about 9 s). Worst case about 65 s before the first interaction.
2. Three shots. Objective UI_OBJ20O_LOAD "Buyuk topu doldur ve nisan al (atis n/3)" is immediately overwritten by CannonCrew's own per-step objective with marker (cannon_crew.gd:275: take powder, wad, ball, rammer, load, ram "E when the marker is in the green", aim "Fare / A-D / W-S / E"). Steps, prompts and key hints are complete and match the code. Good.
3. Cooling: after each shot except the last. Objective UI_OBJ20O_COOL "Namluyu zeytinyagiyla sogut (topun yaninda E basili tut)" with marker above the gun; prompt "[E basili] Yag dok" only within 5 m of the gun point; needs 2.4 s of holding within a 10 s window that starts AFTER Urban's D20O_U_COOL line. Failure = crack (power -10 % per crack, explained by D20O_U_CRACK + D20O_U_LESS, tape option if in bag). Retry: next shot. Fair and explained.
4. Evening photo: UI_OBJ20O_PHOTO + marker, 40 s. Night: rifle handover, GunRange (peek targets, objective with marker on the battlement), duel waves, closing lines.

Problems
- M8 (MED) chapter20o.gd:145-153. The first 31 s are the story, but the optional history lines (`_named_gun`, `_gun_history`, lines 152-153) add up to about 35 s more with nothing to do. Their effects are pure state (`cracks`, `_flawed`, `_edirne_crack`, `_bed`, `gun_crew.tolerance`). Fix: set the state synchronously, then play the lines as `hud.say_chain` while drill 1 starts (the first CannonCrew step "take powder" has a marker and is physical). Set `cracks` before `drill.start(...)` (line 161 uses it). U_01..U_SEVEN (the explanation) can stay frozen.
- LOW chapter20o.gd:158 the "atis n/3" counter is lost as soon as CannonCrew writes its hint; add the counter to the CannonCrew hint or accept.
- LOW chapter20o.gd:350, UNSURE: the cooling prompt uses the distance to `gun.global_position + (0,0,-1)` only. If the gun origin is not near the barrel's middle the prompt may not appear at the muzzle or the breech. The marker (above the gun origin) leads the player to the right spot, so this is acceptable unless the trace shows otherwise.
- Soft lock: none. Cooling and every drill step are bounded or repeatable; Tespit timeout silent (LOW).

---------------------------------------------------------------------------
## CHAPTER 21 (mine: find the tunnel with water bowls) scripts/chapter21.gd

Flow
1. Opener frozen: D21_G_01(+_KNOWN), D21_T_01, D21_G_02 (the bowl rule), D21_N_01 (+ `say_gone` powerbank, + D21_T_EAR) (lines 210-230). About 29-38 s. Then objective UI_OBJ21_BOWLS "Kabi topraga koy (E): dalgalanma en guclu nerede? (%d kap kaldi)" (no marker; it is a search task), a phone meter in the corner (heat bar + wave line, label UI_CH21_APP), barks D21_T_COLD / TEPID / WARM after each bowl.
2. Rule in code: E with no focus puts a bowl 0.9 m ahead (line 1026-1029); success if within 2.6 m of the hidden mine (FOUND_R). The heat bar uses the player's own distance (14 m scale, line 988), the barks use the bowl's. After all bowls Grant finds it (21.2). No fail state.
3. Photo of the strongest bowl: UI_OBJ21_PHOTO + marker, 40 s. D21_G_DIG.
4. Tunnel: card, `D21_G_TUNNEL`, `D21_N_MAP`, `D21_T_MAP` frozen (about 22 s plus fade), then objective UI_OBJ21_FACE "Kazi yuzunu dinle" with marker at the face and prompt "[E] Kulagini daya, dinle" (lines 382-388).
5. Listening cutscene (lean, 3 taps, wall falls: about 9 s), D21_M_1, D21_T_FACE, D21_N_WHO (long, paginated), D21_J_CALL, D21_N_DANGER, then choice UI_C21_LEB_HUSH / UI_C21_HUSH vs UI_C21_RUN (timer 8 s only in timed mode; timeout = freeze = fight).
6. Branch cutscene (peace about 35-40 s, fight about 25 s), fire seal (about 20 s), D21_G_FIRE, D21_T_END, fade, interrogation room: D21_N_CAP (about 19 s), G_CAP1, G_Q1, choice Q1 (A literal / B soften / C ask his name), Kasim's answer, Mirko line, G_Q2, choice Q2, then talk or iron, closing lines.

Problems
- M9a (MED) chapter21.gd:210-230. About 30-38 s frozen, and the opener contains flavour (N_01, say_gone, T_EAR) after the rule (G_02). Fix: free the player after D21_G_02 with the bowl objective already set (`_update_objective()`, `_meter.visible = true`) and play `hud.say_chain([["SPK_NIHAT", "D21_N_01..."], ["SPK_TOLGA","D21_T_EAR"]])`; do the `GameState.spend("powerbank", ...)` synchronously (line 222) and put the `say_gone` into the chain as well (it takes an item key and speaks, so wrap in a small helper or keep it before the chain). Keep `phase = "bowls"` after the chain so `_place_bowl` still works; or set `phase` at once and rely on the chain waiting inside `hud.say`. Bowl barks (hud.bark) wait their turn, so nothing overlaps.
- M9b (MED) chapter21.gd:382-384. Tunnel entrance: G_DIG + fade + G_TUNNEL + N_MAP + T_MAP is about 33 s frozen, and the objective that G_TUNNEL describes ("Kazi yuzunu dinle") only appears after N_MAP and T_MAP (two jokes). Fix: after D21_G_TUNNEL set the objective, `player.frozen = false`, `_taps_on = true` and play N_MAP, T_MAP as `say_chain` while the player walks the 16 m. The face interaction is not affected (it only needs `phase == "tunnel"`; dialogue lines are queued by `hud.say`). The breakthrough starts a cutscene with `hud.say`, which waits for the chain to finish, so no overlap.
- M9c (MED, UNSURE) chapter21.gd:396-410. From the E press to the choice: lean + taps + wall + `D21_M_1`, `D21_T_FACE`, `D21_N_WHO` (about 260 chars), `D21_J_CALL`, `D21_N_DANGER`: about 40 s with no control. The miner and janissary stand still, so `D21_N_WHO` / `D21_J_CALL` / `D21_N_DANGER` could be `say_chain` with an objective "Madenciye bak" and the player free (he can already look around). Risk: a free player can walk toward the open Ottoman tunnel; `Handover.pass_to` (line 440) needs him in front of the miner. Only do it if the player is held by an invisible block, otherwise leave.
- LOW chapter21.gd:284/293. In `_place_bowl` the call `_offer_thermos()` is not awaited, so `_update_objective()` immediately writes "(0 kap kaldi)" behind the choice; harmless because the HUD hides the objective box during a choice, but if the player declines the thermos the stale "0 bowls left" returns for one frame before `_found()` clears it (line 312). Cosmetic.
- LOW chapter21.gd:1026. E is ignored silently when the crosshair rests on anything interactable (Lore page, Grant). Optional bark "Bir yere bak, bos zemine koy".
- LOW chapter21.gd:625-662. The trust rule (two of: Q1 soften/ask name, tunnel hush, Q2 soften) is hidden, but the results are narrated (D21_N_TALK vs D21_G_TAKE + D21_N_TORTURE), so the consequence is explained after the fact. Fine for a moral choice.
- Choice 1 (HUSH vs RUN): labels are distinct and D21_N_DANGER spells out the stake. OK.
- Soft lock: none (bowls end after 4-6, photo 40 s timeout, tunnel face needs only E at the end of one corridor).

---------------------------------------------------------------------------
## CHAPTER 21o (dig with Dragan, escape smoke) scripts/chapter21o.gd

Flow
1. Opener frozen: D21O_Z_01, D21O_D_01 (the three rules: do not shout, prop every two digs, candle), D21O_T_01, D21O_D_02 ("take your picture of the work first, then grab the pick") (lines 201-205), about 29 s. Then free: objective UI_OBJ21O_PHOTO "Tespit et: is basindaki madenciler" + marker, 30 s window, then pick.
2. Dig loop (phase "dig"): objective UI_OBJ21O_DIG "Kazi yuzunu kaz (E basili) %d/6" + marker on the face; prompt "[E basili] Kaz" (needs focus on the face, 1.4 s hold, progress decays when released); every even dig needs a prop: objective UI_OBJ21O_SUPPORT "Tavani destekle: girisdeki direklerden al (E)" with marker on the pile, then UI_OBJ21O_SUPPORT_CARRY "Diregi kazi yuzune tasi..." with marker on the face. Objective, markers, prompts and code agree.
3. Raid at dig 3: frozen D21O_D_RAID, teleport of the player (line 304) without fade, WaveRunner (one foe at a time, the Duel draws its own hint line); failure = `dug - 1` and D21O_D_COLLAPSE explains it; retry is fair.
4. Breach: Dragan walks up, listen lines, T_FACE, choice UI_C21_WAVE / UI_C21_LEB (no timer), D21O_D_FIRE (about 9 s, includes "Girise kos").
5. Escape: objective UI_OBJ21O_ESCAPE "Duman gelmeden girise kos" with marker at the exit, HUD countdown "Duman 14 sn" (hud.set_chase). Failure = fade, Dragan drags him out, outcome 21O.2, explained by D21O_D_PULLED.

Problems
- M10 (MED) chapter21o.gd:201-205. About 29 s frozen. D21O_D_02 already contains the order, so the first three lines can be a `say_chain` after the photo objective is set: keep Z_01 frozen (Zaganos is leaving afterwards, line 206 needs `chain_busy()` to be false before `zaganos.leave`), then `player.frozen = false` + photo objective + `say_chain` D_01, T_01, D_02. Zaganos stands behind the player's shoulder and does not need the player to stay put; wait for `chain_busy()` before line 206.
- M11 (MED) chapter21o.gd:371-372, 397-425. At the end of the breach the player is placed 2.2 m in front of the face and looks at the enemy (line 372), i.e. into the tunnel. Escape begins with the player free but facing away from the exit, and the real fail condition is invisible: the smoke front starts at the face and moves at 1.125 m/s (line 418), so a player who needs more than about 2 s to turn and move is "caught" (line 424) although the HUD says 14 s. Fix, two lines at the start of `_escape()`: `player.face(Vector3(0, 1.5, 2.5))` and start `smoke_z` 2 m further back (`var smoke_z := face.position.z - 2.0`). Optional: a short tick sound or the fog is already the cue.
- LOW chapter21o.gd:303-306. The raid teleports the player without a fade (global_position jump while the camera is facing Dragan). Cosmetic; a 0.15 s fade would hide it.
- LOW chapter21o.gd:378. Choice of wave or chickpeas has no mechanical consequence; fine.
- Soft lock: none. Every step is retryable; the raid has a 50 s limit; the escape has a 14 s limit.

---------------------------------------------------------------------------
## CHAPTER 22 (siege tower: drop the fused barrel at the right time) scripts/chapter22.gd

Flow
1. Dawn, frozen: D22_T_01, D22_G_01, D22_T_02, D22_G_02, D22_N_01 (lines 188-192), about 32 s; fade to night card.
2. Night, frozen: D22_G_03 ("Oluga koy, fitili yak, birak"), D22_G_04 (too early / too late consequences), D22_T_03, [BLAKH line], [cologne choice + 2 lines] (lines 203-224), about 27 s (up to about 35 s with cologne). Explains the mechanic well. Choice labels UI_C22_COLOGNE / UI_C22_NOCOLOGNE do not name the effect but the following lines do.
3. Barrels: objective UI_OBJ22_TAKE "Barut ficisini al (%d kaldi)" marker on the barrels; prompt "[E] Barut ficisini al"; then UI_OBJ22_CHUTE "Olugu goturup fitili yak (isabet n, atilan m)" marker on the chute; prompt "[E] Oluga koy, fitili yak". On lighting, the player is frozen, a bar "Fitil" with a green window (default 0.42-0.68 of 2.6 s = 0.68 s wide; 30.1 wide 0.99 s; 30.2 narrow 0.47 s) and the red last 10 %, prompt "[E] BIRAK! (yesilde)". E releases (chapter22.gd:488-492). Results are spoken: EARLY, LATE, HIT_n, SINGED. Three barrels, ends after two hits. The first barrel works as the learning attempt. The bar, prompt, explanation and code agree.
4. Photo of the burning tower (UI_OBJ22_PHOTO + marker, 40 s), walk to Giustiniani, two closing lines.

Problems
- M12 (MED) chapter22.gd:188-192 and 203-224. Dawn scene about 32 s and night scene about 27 s frozen. Nothing in either needs a fixed spot (Giustiniani stands still; no cuts inside; the only choice is the cologne one at the very end). Fix dawn: `player.frozen = false` after the fade-in with a "listen" objective (target `giust`, text like "Giustiniani'yi dinle" new key) and `hud.say_chain` for T_01..N_01, then `while hud.chain_busy(): await get_tree().process_frame` before the fade at line 193. Fix night: after the fade-in free the player, set `_update_objective()` and play D22_G_03, D22_G_04, D22_T_03 as `say_chain` (the player can already walk to the barrels), then wait for the chain, play BLAKH, show the cologne choice with `player.frozen = true`, then continue. Important: `phase` stays "intro" until the chain is done so `_on_interact` cannot start a fuse while the explanation plays (line 480 has no phase check, so add `if phase != "barrels": return` there).
- M13 (MED) chapter22.gd:488-492 with 312-328. E at the chute lights the fuse and the very next E (even a nervous double tap or key auto-repeat of 0.1-0.2 s) releases the barrel at fuse 0.0-0.1, which is "early" and costs one of only three barrels. Fix: in `_unhandled_input` ignore the press while `_fuse < 0.15`.
- LOW chapter22.gd:259-261. While the fuse burns the objective still reads "Olugu goturup fitili yak ..." (stale). Set `hud.set_objective(tr("UI_PROMPT22_RELEASE"))` in `_light()` or clear it. The prompt line carries the instruction, so this is only a duplication risk.
- LOW chapter22.gd:473-478. If the focus returns to "chute" while the fuse burns, `_on_focus("chute")` writes the LIGHT prompt over the RELEASE prompt only when `carrying and _fuse < 0.0`, so safe; the `_` branch is also guarded. Verified, no fix.
- Soft lock: none (barrels end in 3 releases at the latest; the fuse bursts at 1.0 and still resolves).

---------------------------------------------------------------------------
## Fix list ordered by value

1. H1 (ch20): drop-on-wrong-delivery and refuse-wrong-pile: chapter20.gd:523 and 570. Two small edits; prevents a 30-80 s stuck state in a 170 s night.
2. M1 (ch20): cover marker at the warning.
3. M2 (ch20): clock semantics during assault (design decision; then no more silent 20.3).
4. M4 / M6a / M9a / M10 / M12 / M3: turn the long openers into "free + objective + say_chain" using the listening objective pattern; each removes 12-20 s of frozen time without touching any line.
5. M5 (19o watch marker), M7 (19o gun marker as Node), M11 (21o escape facing/grace), M13 (22 double tap guard).
6. Silent Tespit timeouts (all chapters) and the LOW cosmetics.

Chapters with no HIGH/MED beyond the above: 20o cooling/drill flow is clear, bounded and fair; 21 bowl search and the interrogation choices are clear; 22 barrel loop is clear once the explanation has been heard.
