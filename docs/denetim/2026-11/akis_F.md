# Akis_F: guidance audit of chapters 22o, 23, 24, 24o, 25, 27

Method and limits
- Code walked in order, with strings read from i18n/strings.csv. The flow traces flowall/ch22o, ch23, ch24, ch24o, ch25 and ch27 did not exist when I checked, so I used code only.
- Frozen-stretch lengths are ESTIMATES: text length at about 14 characters per second, plus pauses. They are not trace timings (voice length x 0.85 in hud.say). Items that depend on them are marked UNSURE.
- No dialogue is cut or rewritten below. All proposals are about guidance and control.
- No chapter calls hud.show_controls. Controls are taught only through the objective text, the prompt (E / hold E) and the Carry and BalanceMeter labels. That is acceptable, since every step has a prompt that names its key.

Summary (HIGH / MED)
- HIGH  25   Eavesdropping behind the tent: the prompt says "kipirdama" (stay still), but staying still at the wall gets the player caught. The guards' sight rule is invisible, and the second catch ends the scene without a warning. chapter25.gd:161-170, 683-694, 348-349, UI_PROMPT25_LISTEN.
- MED   22o  The "Siper!" (cover) warning is a normal bark. It can be delayed or dropped while another bark's voice is playing, it gives no marker for a cover, and it is only 3 s long while carrying. chapter22o.gd:796-823.
- MED   22o  Opening is frozen for about 45-60 s before any objective. chapter22o.gd:599-622.
- MED   23   About 55 s frozen before the first choice; the whole chapter is conversation. chapter23.gd:204-252.
- MED   24o  Opening is frozen for about 45-50 s, plus 14 s more with variants. chapter24o.gd:217-248.
- MED   25   Opening (Kadri, tray) is frozen for about 35 s. chapter25.gd:190-193.
- MED   25   Hagia Sophia half is frozen for about 45-60 s before the candle objective. chapter25.gd:614-631.
- MED   27   Intro is frozen for about 30-50 s. chapter27.gd:246-254.
- MED   27   The charter reading is frozen for about 60 s. chapter27.gd:378-384.
- MED   27   The Bureau epilogue is frozen for about 70 s on top of the 25 s before it. chapter27.gd:405-407, 452-466.

---------------------------------------------------------------------
## Chapter 22o (siege tower, rescue the carpenters)  scripts/chapter22o.gd

Flow as the player experiences it
1. Frozen opening: N_01, H_01 (or _KNOWN), T_01, optional H_CAPTIVE/T_CAPTIVE or H_BLAKH_OK/BAD, H_02, optional HU_01 (lines 599-622). Then free, with an objective on the earth pile.
2. Build phase, all with set_objective and a marker:
   - UI_OBJ22O_BASKET "Sepet al: toprak yigini · hendek %d/%d" -> PILE.
   - UI_OBJ22O_DROP "Sepeti hendegin kiyisina dok" -> DROP.
   - UI_OBJ22O_TAKEHIDE -> HIDE_PILE.
   - UI_OBJ22O_HIDE / _HAUL -> tower front.
   - UI_OBJ22O_WATER, then UI_OBJ22O_WET.
   Prompts, one per step: [E] Sepet al, [E] Topragi dok, [E] Deri al, [E] Deriyi ustalara ver, [E basili] Deriyi cak / Halati cek, [E] Kova al, [E] Derilere su dok. Objective, prompt and code agree; the keys are named in every step.
3. Dawn: Tolga walks to Hasan by script, then the photo (40 s, no marker problem), then the rooftop gun (GunRange, with the UI_HGUN_AIM hint).
4. Night 2: fire, sortie duel (the duel's shared objective UI_OBJ_DUEL), then the rescue hold at the ladder. UI_OBJ22O_RESCUE with a marker; the fire timer is 26 s; the hold is 1.5 s per man, so 4.5 s in total. It is fair and fully explained. If the timer runs out, Hasan carries the last man down (H_CARRY, outcome 22O.2). Nothing is lost.

Problems

[MED] chapter22o.gd:796-823 (_volley_tick): "Siper!" warning is weak
- What the player experiences:
  - Hasan's warning is `hud.bark("SPK_HASAN","D22O_H_VOLLEY",_warn_time)` with interrupt = false (line 822).
  - hud.bark waits for any earlier bark voice (H_BASKET_n, H_HIDE_n, H_WET, T_RESCUE) and drops the line if the wait exceeds 6 s (hud.gd:2903-2913).
  - The 3 s warning counter `_warn` runs from the tick, not from when the bark is spoken. The player can get no audible "Siper!" at all, and then 30 HP of arrow damage (6 for the first arrow if they wear the fez).
  - There is no marker for a cover. COVERS are four spots (two wicker screens, the earth pile, the water barrel) plus the tower foot, and the text only says "Hasirin arkasina". When carrying a basket to the moat edge (z 37-38), the nearest cover is more than 7 m away. At 0.75 or 0.6 speed and a 3 s warning, the player cannot reach it.
  - The volley comes every 22 s for the whole build phase. The player is "downed" (down(), fade, get up with 40 HP) when HP runs out; there is no progress loss, but it feels unfair and unexplained.
- Fix, minimal and using the existing patterns:
  - (a) Line 822: pass interrupt = true (`hud.bark(..., _warn_time, true)`, the pattern already used for screams).
  - (b) When `_warn` starts, call `hud.set_objective(tr("UI_OBJ22O_COVER"), nearest_cover + Vector3(0,1.5,0))` (new key, e.g. "Siper! En yakin hasira / kulenin dibine"). When `_warn` ends or the volley lands, call `_update_objective()` to restore the old objective. `_covered()` already defines the cover circles.
  - (c) Make the warning at least 4 s while the player is carrying (use `_warn_time + 1.5` if `carrying != ""`).
  - (d) Optionally add a one-line explanation in the first H_BASKET or H_02 flow. The text of H_02 is not visible to me (long line), so I did not check whether it already says "Siper denince hasira / kuleye kos". UNSURE.

[MED] chapter22o.gd:599-622 (frozen opening)
- N_01 + H_01 + T_01 + (blakherna or captive line) + H_02 + (HU_01): about 600-900 characters, so about 45-60 s frozen with no objective and no way to move. The first free moment comes only after H_02/HU_01.
- Could they play free? Yes. Nobody needs to stand at a fixed spot, there is no camera cut and no choice. The only coupling is `player.face(huseyin...)` at line 621 and hasan.look_target.
- Fix: set the first objective before the lines (hud.set_objective(tr("UI_OBJ22O_BASKET") % [0,3], PILE + Vector3(0,1.2,0)), which is already what `_update_objective()` does at phase "build"). Replace lines 599-622 with `hud.say_chain([[...],...])` for N_01, H_01, T_01, the branch lines and H_02, then `while hud.chain_busy(): await get_tree().process_frame`. Keep HU_01 as the last chain entry. Drop the `player.face(huseyin)` call or run it before the chain. The player will have walked off while Hasan talks; Hasan's `look_target = player` already tracks them. The side effect of an early objective is that `phase` must already be "build" for `_update_objective()` to act, so set `phase = "build"` before the chain.
- Estimate; UNSURE about exact seconds (no trace).

[LOW] chapter22o.gd:643-647 (objective text with a hide in hand)
- `_update_objective()` treats `carrying == "hide"` and `_hide_set` the same. From the second hide on, someone who is carrying a hide (not yet handed over) reads UI_OBJ22O_HAUL "Kulenin onunde halati cek (E basili)". The first thing needed is [E] Deriyi ustalara ver. The prompt does show this once the player is at the front, so the player is not stuck.
- Fix: for `carrying == "hide"` and `not _hide_set`, always use UI_OBJ22O_HIDE-style text ("Deriyi kulenin onune goturup ustalara ver"). Use _HAUL only when `_hide_set`.

[LOW/UNSURE] chapter22o.gd:379-385 and 533 (where hides can be handled)
- The "hides" zone is `|lp.x|<2.7 and lp.z<-2.0` (world z<38). The tower base collider ends at z 37.6 and the moat wall is at z 36.2-36.6. With the player radius of 0.3 the free strip is about 0.4 m wide (z 36.9-37.3). The marker sits in the strip at z 37.1. It is reachable by walking along the front, and the autotest teleports there, but a live player has to find a 0.4 m corridor. The comment at line 533 mentions "the right corner" too, which the code does not implement.
- Fix: widen the zone to `lp.z < -1.0` or add a second invisible interact box at the right corner, or just move the marker/zone away from the wall (change the tower collider to leave 1.2 m of strip).

[LOW] chapter22o.gd:869-874 (dawn photo)
- 40 s timeout, silent: if the player does not shoot, the chapter just goes on. There is no on-screen hint about which key takes the photo until the target is in the cone (the prompt UI_PROMPT_TESPIT appears only when aimed). Fine for repeat players; for a menu-start player the objective only says "Tespit et: ...". Optional: show `hud.show_controls(true, "UI_PROMPT_TESPIT")`-style hint for the first 6 s after cam.start().

[LOW] chapter22o.gd:885, 895 (rooftop gun)
- D22O_H_GUN says "Cik tepeye, al su tufegi" but the code fades and teleports the player to the top. No control is lost; the line is slightly inconsistent with what happens, not a guidance defect.

No other issues: rescue timer fair and visible, no soft lock (carry/dropping is always possible; `_crew_relocate` only moves the crew when the player looks away).

---------------------------------------------------------------------
## Chapter 23 (envoy, faithful translation)  scripts/chapter23.gd

Flow: all dialogue, three 3-way/2-way choices, one photo, one card choice. No walking.

Choices (lines 252, 270, 287, 343)
- Options are clearly worded: "Kelimesi kelimesine cevir" / "Yumusat: ..." / "Ekle: ...". The "Tercuman sapmasi" bar (UI_CH23_METER) is shown from line 246. It is not explained, but D23_TH_01 ("Kelimesi kelimesine") plus the option names carry the idea.
- No hidden timer (choose(…, 0.0, …)).
- Chapter end: D23_N_END_TRUE / _CREATIVE says which variant happened. Clear.

Problems

[MED] chapter23.gd:204-252 (frozen opening)
- D23O_N_01/D23_N_01, (D23O_I_01), D23_TH_01, D23_T_01, (SINGED lines), (PASS scene), D23_K_KNOWN, D23_I_KNOWN, D23_I_LETTER, D23_I_OFFER_1, D23_I_OFFER_2: about 800-1100 characters, so about 55-80 s frozen before the first choice. The player has no objective and nothing to do.
- Could it play free? Partly. Lines 205-216 (the first N/TH/T lines, about 20-25 s) have no positional dependence. The PASS scene (lines 221-232) needs Theodoros to walk to the player (`_approach`) and a hand-over, so keep it as is. The OFFER lines lead directly into the choice and look best frozen.
- Fix: set `hud.set_objective(tr("UI_OBJ23_LISTEN"), city.emperor)` (new key, e.g. "Heyeti dinle, tercuman sensin") and play lines 205-210 via say_chain with player.frozen = false, then freeze before `_approach`/choices. Gain: about 20 s. UNSURE on seconds.

[MED/UNSURE] chapter23.gd:255-286 (frozen between choices)
- After choice 1: T_1_TRUE + K_1_TRUE + K_ANSWER_1 + K_ANSWER_2 is about 450 characters, about 30 s frozen. After choice 2: T_2_* + I_2_* + I_ASIDE is about 25-30 s. This is the chapter's nature (conversation). I would not change it, other than the optional objective above; flagged only because of the >25 s rule.

[LOW] chapter23.gd:287-293 (hidden consequence)
- "Kendine sakla." (UI_C23_3_KEEP) raises the drift by 1 (line 292) and so turns 23.1 into 23.2, but it looks like the neutral choice. The "Il et" option is the faithful one. Hinting: change the option label to e.g. "Kendine sakla (cevirmedigin bir soz)" would be a text change, so instead flash the drift bar (already updated by _deviate) and bark D23_T_3_KEEP is thought only. Optional: show `_meter` pulse on every _deviate so the cause is visible. Not required.

[LOW] chapter23.gd:329-337 (photo timeout)
- 45 s then silently skipped, no feedback. The line D23_TH_PHOTO (Be quick) implies urgency but nothing enforces it. Fine.

---------------------------------------------------------------------
## Chapter 24 (omens: carry the icon litter in the storm)  scripts/chapter24.gd

Flow
1. Frozen intro: N_01, T_01, M_01, (T_ECLIPSE think), (NK_01, T_NK_01 with Niko) (lines 436-450). About 20 s base, 32-50 s with variants.
2. Carry phase (38 s): player.pinned = true (cannot walk), BalanceMeter label UI_CH24_BALANCE "Sirigi dengede tut (A / D)" (pad aware through GameState.pad_text in the meter). Objective UI_OBJ24_CARRY "Alayla yuru, sirigi dengede tut".
3. Slip: frozen M_SLIP, T_SLIP, N_SLIP, M_STOP (about 17 s).
4. Flood/child: 22 s (+7 with Niko) countdown "Sel yukseliyor · N sn", objective UI_OBJ24_KID with marker on the child, prompt UI_PROMPT24_KID "[E] Elini tut", then UI_OBJ24_SHELTER with marker. Failure: the child runs off on his own (K D24_T_KID_RAN), outcome 24.2, explained. Timing check: the player starts about 8.7 m from the child, the shelter is about 8 m beyond; about 8-10 s of the 22 s are needed. Fair.
5. Fog day: free with UI_OBJ24_WAIT for 14 s, then M_LIGHT, then UI_OBJ24_PHOTO with marker on the dome (max 160 m, the dome is about 51 m away); 60 s timeout.

Problems

[LOW/MED] chapter24.gd:428, 455 (objective text vs control)
- The player is pinned: no walking. The objective says "Alayla yuru" (Walk with the procession) and the player may press W with no effect while the only real input is A/D. The meter label does say A/D.
- Fix: UI_OBJ24_CARRY -> "Sirigi dengede tut (A / D)" or keep the text and add that the procession moves by itself.

[LOW] chapter24.gd:888-890 (stale objective during the key line)
- `hud.say("SPK_MONK","D24_M_LIGHT")` is played while the player is free and the objective is still UI_OBJ24_WAIT "Sisli sehirde dolas; aksami bekle". The photo objective with the dome marker is set only after the line ends (line 890). Fix: move `hud.set_objective(tr("UI_OBJ24_PHOTO"), DOME_LIGHT)` before the `say` (the same order chapters 23 and 27 already use).

[LOW] chapter24.gd:874-878 (14 s of idle)
- After N_FOG the player is free for a fixed 14 s with "wander; wait for evening" and no marker. The player has control, so it is not a freeze. If it feels long, point a marker at the dome (`hud.set_objective(..., DOME_LIGHT)`) from the start, since the dome is visible once the light is on, or shorten to about 8 s.

[LOW] chapter24.gd:870, 873 (climb)
- N_FOG says "Gezin, tirmanin"; enable_climb is on but no key is named anywhere in the chapter. The photo needs no climbing (dome visible from the court), so this is harmless. Optional hint with the climb control.

[LOW] chapter24.gd:898-903 (photo timeout)
- Silent 60 s timeout, then T_PHONE. The outcome flag does not depend on the photo. Fine.

[LOW] chapter24.gd:436-450 (frozen variants)
- With niko_friend + eclipse_seen the opening is about 50 s frozen. The player is pinned and seated anyway, so the loss is only that the camera cannot be moved. Could be say_chain with the pinned player (mouse look already works while frozen). Not important.

No soft locks: the carry phase ends at 72% of the route regardless of balance (stumbles are only counted), the flood phase always ends by the timer.

---------------------------------------------------------------------
## Chapter 24o (omens in camp: soup, calm soldiers, tent ropes)  scripts/chapter24o.gd

Flow
1. Frozen intro (lines 217-248): N_01, K_01, (MENU), T_01, (THERMOS), eclipse starts with a camera turn, K_02, (ECLIPSE_AGAIN), dervish walks up, D_01.
2. Moon photo (UI_OBJ24O_PHOTO, marker 300 m toward the moon, 30 s).
3. Soup: the tray is given AFTER the photo (line 254). UI_OBJ24O_CALM "Ates baslarina corba goturup askerlerle konus · %d/3" with a marker on the first uncalmed fire. Prompt UI_PROMPT24O_TALK "[E] Corba ver, konus". The countdown "Ay geri gelene kadar" is 75 s and stops while talking or choosing (lines 267-272). The choice is science / soup / joke (+ tea with the thermos); every option calms the fire; no hidden timer. Fair.
4. Storm: K_STORM (frozen), then UI_OBJ24O_ROPE with a marker on the first untied peg, prompt UI_PROMPT24O_ROPE "[E basili] Ipi kaziga sar", progress "Ip sariliyor NN%" and a "Ruzgar" bar. Failure: the tent flies (K_FLY), explained, no retry (only the flavour line K_LOST_n differs).

Problems

[MED] chapter24o.gd:217-248 (frozen opening)
- N_01 (about 230 characters) + K_01 + T_01 are about 460 characters, about 32 s frozen before the eclipse. After the eclipse starts: K_02 + D_01 about 14 s more. With ch10z_menu, thermos or eclipse_seen the total reaches about 60-70 s. There is no objective and the player cannot do anything.
- Could the first three lines be free? Yes. They need no fixed position; the eclipse turn (`_clear_moon_view` teleport + `player.face(moon)` at lines 234-235) comes after them.
- Fix: before line 217, `hud.set_objective(tr("UI_OBJ24O_KADRI"), day.kadri)` (new key, e.g. "Asci Kadri'yi dinle"), `player.frozen = false`, and play N_01, K_01, (MENU), T_01, (THERMOS) via say_chain with `while hud.chain_busy()`. Then `player.frozen = true`, `hud.set_objective("")` and continue with the eclipse. The teleport in `_clear_moon_view` happens after the freeze. Saves about 30 s of "frozen".

[LOW] chapter24o.gd:252-254 (soup objective hidden by the photo)
- K_01 says the soup is to be taken round; the tray appears only after the photo (up to 30 s later), and until then the objective is the moon photo. Fine, but if the photo is not obvious the player waits up to 30 s with no soup objective. Fix: give the tray before the photo, or let the photo objective say "(sonra corba)". The photo timeout is 30 s and silent.

[LOW] chapter24o.gd:460-476, 565-578 (first rope window)
- Each tent flies at 9 s, 13.5 s, 18 s after the player is freed. Walking: peg 0 is about 6.3 m from the start point, pegs 1 and 2 are about 7.5 m apart; hold time 2.2 s. A fast player finishes at about 4.5 s, 9 s, 13.5 s (margin about 4.5 s each). A player who has not yet understood "E basili" (the K_STORM line is the only explanation before the objective appears) will lose the first tent. There is no retry, but only a flavour line changes.
- Cheap guard: start the gust offsets later for the first tent (e.g. `_gust[i] = -0.3 - i*0.5`), or show the prompt/tutorial line while frozen. The `tape` item shortcut (line 643) is never hinted; fine (optional).

[LOW] chapter24o.gd:399 (tray carry)
- The soup tray uses Carry.attach(... balance true) with no spill callback, so the "Dengede tut: kosma, sert donme" meter appears with no consequence. This can make players think spilling matters (it does not). Optional: drop `balance` for the tray, or add a minimal spill reaction.

No soft lock: the calm loop ends at 3/3 calmed or when the 75 s counter is out, and the storm loop ends when all tents are decided or 40 s pass.

---------------------------------------------------------------------
## Chapter 25 (last evening: eavesdrop behind the tent, Hagia Sophia candle)  scripts/chapter25.gd

Two sides share the file: Ottoman half (lines 184-221, tray -> listen -> lights photo -> handoff) and Byzantine half (walls photo -> Hagia Sophia -> candle). The chapter "always" ends with the liturgy only on the Byzantine side.

Flow, Ottoman half
1. Frozen: N_01, K_01, T_01, K_02 (lines 190-193), then the tray appears in the hand.
2. UI_OBJ25_TRAY with a marker on the door guard, prompt UI_PROMPT25_TRAY "[E] Tepsiyi ver". Clear. The guard walks the tray in and the player is free at once.
3. Listen (lines 272-305, 670-694): UI_OBJ25_LISTEN "Otagin arkasinda meclisi dinle; nobetcilere gorunme" with a marker at the back of the tent. One bark D25_T_LISTEN (3.5 s) "Nobetciler donuyor, arkalarina denk gelmeliyim." A bar "Meclis". Prompt UI_PROMPT25_LISTEN "Dinliyor... kipirdama".
4. Lights photo (UI_OBJ25_PHOTO, 45 s), then handoff.

Problems

[HIGH] chapter25.gd:144-170, 683-694, 348-349; UI_PROMPT25_LISTEN - stealth rule is hidden and the prompt contradicts it
- What the code checks:
  - The two guards circle the tent at radius GUARD_R 10.6, 0.16 rad/s (about 1.7 m/s), always 180 degrees apart, starting the moment the scene is built.
  - `_seen()` fires if a guard is within 4.2 m and the player is in front of it (dot > 0.3 on the guard's direction of travel). Walls and the tent are ignored.
  - The listening spot is `_at_wall()`: radius below 8.6 m from the tent centre, in the back half. The tent collider is 7.15 m, so the player can stand at radius 7.5 to 8.6, i.e. only about 2.0 to 3.1 m from the guards' path.
  - At that radial distance a guard always sees a stationary player for the whole approach (the guard is within 4.2 m with the player 20-70 degrees off its heading), so every pass of a guard through the back arc catches a player who stands still. The only way to avoid it is to keep walking ahead of or behind a guard, or step out of the ring.
- What the player experiences: the prompt says "Dinliyor... kipirdama" (stay still), the objective says "gorunme". The player stands still and is caught each time a guard comes round (a pass every roughly 20 s; the council lasts about 40-60 s, based on `_listen_total`). The sight range (4.2 m) and the cone are never drawn. Being caught shows only a bark (D25_G_CAUGHT_1) and a fade to the kitchen side (a walk back of 16+ m, crossing the guard ring again).
- Consequences are not announced: `_caught_once` increments `caught`; the SECOND catch ends the eavesdrop at once (line 348-349, `phase = "listened"`; outcome 25.2 and T_HALF). D25_G_CAUGHT_2 ("Yine mi sen? Bir daha gorursem...") sounds like a warning although it is the final strike.
- Progress is kept across the first catch (good).
- Fix, minimal:
  1. Change UI_PROMPT25_LISTEN to say what is true, e.g. "Dinliyor... nobetcinin onune cikma" (or "gozden uzak dur"). Do not say "stay still".
  2. After the first catch add a bark or objective update (new key, e.g. "Bir kez daha gorulursen meclisin sonu kacar") in `_caught_once` when `caught == 1`, and optionally show the remaining chances in the chase bar label ("Meclis · gorulme 1/2").
  3. Show the guard's danger: e.g. a faint cone or a small "!" over a guard when it is within 6 m and the player is in its front arc, or a bark "Nobetci geliyor!" from Tolga (hud.bark) when a guard comes within 6 m of the player in the listening area.
  4. Optional balance: give the player a margin: raise the listening radius so players can stand at radius greater than or equal to about 8.2 m and reduce the view range to about 3.4 m, or make the guards pause for 1-2 s at the door side. UNSURE: tuning is the owner's call; the numbers above are from the code, not from a trace or play test.
- Also repeat the rule: the single D25_T_LISTEN bark (3.5 s) is the only place the rule is stated and it may be queued behind D25_G_TRAY (bark waits for the previous voice, up to 6 s, hud.gd:2903-2913). Consider `interrupt = true` or re-showing it as the objective text.

[MED] chapter25.gd:190-193 (frozen opening)
- N_01, K_01, T_01, K_02: about 470 characters, about 33 s frozen. Could be say_chain with the first objective (UI_OBJ25_TRAY, marker on the door guard) set already; `_give_tray()` must still come after K_02 (call it after `while hud.chain_busy()`), because K_02 says "Tepsiyi kapidaki nobetciye ver". Or give the tray first and let the player walk while Kadri talks. No position dependence. UNSURE seconds.

[MED] chapter25.gd:614-631 (Hagia Sophia, frozen before the candle)
- D25_N_AYA, D25_T_AYA, the emperor's 5 s walk (awaited, line 617-619), K_1, K_2, (PASS scene), I_1, N_ISI (about 270 characters): about 650-900 characters, about 45-60 s frozen. The candle objective comes only afterwards.
- What can be freed: D25_N_AYA + D25_T_AYA (about 12 s) before the emperor enters, and D25_N_ISI (about 19 s, line 630). Both are narration and need no fixed spot. The emperor's speech (K_1/K_2) and the "afar" staging should stay frozen (camera/face).
- Fix: play N_ISI as a say_chain while the player is already free with the candle objective (move the `hud.say("SPK_NIHAT","D25_N_ISI")` to a `hud.say_chain` after line 635, since the candle loop waits up to 30 s anyway). Set the objective before it. `met_isidore` flag is set at line 631 and can move with it.

[LOW] chapter25.gd:635, 597 (candle marker hidden)
- For the default spawn (AYA + (-4,0,9)) the stand is only about 2.1 m away, so the marker is inside hide_near (4 m) and never shows; the text says "mumluga bir mum yak" and the stand is in front. For the palace spawn (2.0, 6.5) the distance is 7.6 m and the marker shows. Acceptable; optional: lower `hud.marker.hide_near` to 1.5 for this step.

[LOW] chapter25.gd:448-481 (walls night, Byzantine half)
- N_1, S_1, T_1, S_2, T_2 are about 415 characters, about 30 s frozen before the photo. Slightly over 25 s. UNSURE. Same pattern as the other openings: can be say_chain with the photo objective already set (target is straight ahead, the player already faces it).

[LOW] chapter25.gd:366-379, 462-476 (photo timeouts silent, 45 s)

[LOW] chapter25.gd:211-213 (no reminder)
- A player who never goes to the back of the tent gets no further reminder after the single bark and the objective; there is no soft lock, because the objective and marker stay.

Chapter end: both halves end with a Siege.record plus the flowchart. Outcome 25.1/25.2 is stated by T_HEARD vs T_HALF. Clear.

---------------------------------------------------------------------
## Chapter 27 (ahidname at Galata quay)  scripts/chapter27.gd

Flow
1. Frozen intro (lines 246-254): N_01, T_01, N_02, optional N_ISI / N_BRIG / N_GENOESE.
2. Free: UI_OBJ27_TALK "Kararsizlarla konus (%d/3)" with a marker on the first undecided NPC (wine seller, notary, fishmonger). Prompt UI_PROMPT3_TALK "[E] Konus: ...". Each NPC: first line, a choice ("Kalin." / "Gidin."), Tolga's reason, the NPC's reply. N_ADVICE after the first.
3. When all three have been advised: N_SQUARE, objective UI_OBJ27_SQUARE with a marker, 90 s limit, then a fade-and-teleport if the player is still more than 11 m away (safe fallback, no soft lock).
4. Ceremony: Z_01-Z_04, P_01, T_GREEK, Z_05 (frozen), then UI_OBJ27_PHOTO (objective set before the N_PHOTO line, good), 45 s, then N_END_*, T_END, N_LONDON, show_page, the Bureau epilogue, flowchart.

Problems

[MED] chapter27.gd:246-254 (frozen intro)
- N_01 (about 170 characters), T_01 (130), N_02 (150) plus up to three more N lines (about 80 each): about 450-700 characters, about 30-50 s frozen before the first free moment.
- Could be free: yes. The player stands at the spawn and nothing is staged. The N_ISI/N_BRIG/N_GENOESE lines point at NPCs ("Gemi kuyrugundaki ak sakalliya bakin") and make more sense while the player can look and walk.
- Fix: call `_update_objective()` and `player.frozen = false` first, with `phase = "free"`, and play lines 246-254 through `hud.say_chain` (with `_t(...)` replaced by `["SPK_TOLGA", key]`). Do not forget `_talk()` already waits on `_busy`; a talk started mid-chain would overlap, so either block interaction until `hud.chain_busy()` is false (`_on_interact` returns while chain_busy), or only chain the first three lines.

[MED] chapter27.gd:378-384 (charter reading)
- Z_01, Z_02, Z_03, Z_04, P_01, T_GREEK, Z_05 are about 880 characters, about 60 s frozen with the player facing Zaganos. It is the longest uninterrupted frozen stretch in the six chapters (estimate; UNSURE on seconds).
- Could be free: yes. There is no camera cut, no choice, nobody needs the player at a spot (the player is teleported to CER+(0,0,5.8) only if far). `_say` also drives the speakers' mouths; say_chain does the same through find_speaker.
- Fix: `hud.set_objective(tr("UI_OBJ27_LISTEN"), zaganos)` (new key, e.g. "Ahitnamenin okunusunu dinle"), `player.frozen = false`, `hud.say_chain([["SPK_ZAGANOS","D27_Z_01"], ..., ["SPK_ZAGANOS","D27_Z_05"]])`, `while hud.chain_busy()`, then continue to the photo step. Keep `player.face(zaganos...)` at line 372 before. If the player walks away during the reading the photo objective already brings them back (max_dist 16).

[MED] chapter27.gd:405-407, 452-466 (epilogue, frozen)
- N_END_*, T_END, N_LONDON (about 330 characters, about 23 s) are followed by Siege.show_page and the Bureau scene: N_EPI_1, N_EPI_ALL/_SOME, T_EPI, N_EPI_2, (PHONE_BACK pair + hand-over), N_RETURN, T_RETURN: about 600-800 characters, about 45-55 s. Everything is frozen. This is the end of the siege act, so the player is only listening for about 70 s.
- Fix (optional): in the Bureau, set an objective "Nihat'i dinle" and play D26_N_EPI_1 .. D26_N_EPI_2 via say_chain with the player free (lines 452-456). Keep the phone hand-over (Handover.pass_to needs the player near Nihat) and the final lines frozen. UNSURE: the owner may want a cinematic ending.

[LOW] chapter27.gd:273-346 (optional NPCs)
- Isidore, the captain (brig), the Genoese merchant and "double"/"captain" have a talk prompt but no marker, and the objective counter only counts the three undecided. The brig and Genoese NPCs can add to `stayed` (27.1 needs 2), and N_BRIG/N_GENOESE nudge the player toward them. A player who finishes 3/3 immediately never sees them. Not a block (by design), but the player is never told that these matter. Optional: hud.spots for the optional NPCs while `_advised.size() < 3`.

[LOW] chapter27.gd:316-326 (choice hint)
- "Kalin." / "Gidin." are bare. D27_N_02 and D27_N_ADVICE say advice does not change history and "dosyaya yalnizca ne oldugu yazilir". The 27.1/27.2 threshold ("en az iki kisi") is not stated; the end-of-chapter flowchart shows it. Acceptable.

[LOW] chapter27.gd:389-400 (photo)
- UI_OBJ27_PHOTO says "ahitname, pasa ve podesta ayni karede", but TespitCam is aimed at the scroll only (cone 12 degrees). The text is stricter than the check (generous, no failure). 45 s timeout is silent.

No soft lock found: talking to all three is enough, an unreachable square falls back at 90 s, all loops have exits.

---------------------------------------------------------------------
## Cross-chapter notes
- Controls: the E / hold E prompts exist at every step in all six chapters; no chapter relies on a key that is never named, except the climb in ch24 (harmless) and the quiet photo aim (prompt appears only when aimed).
- Photo steps are all silent after their timeout (22o 40 s, 23 45 s, 24 60 s, 24o 30 s, 25 45 s, 27 45 s). Not harmful.
- Photo, rope-hold and listen steps are the first uses of their controls in these chapters for a menu-start player; the chapter menu allows that.
- No `(yok)` objective gaps found while the player is free, except the brief stale objectives noted (24:888, 24o photo before soup).
