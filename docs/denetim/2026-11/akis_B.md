# Player-guidance audit B: chapters 8, 9, 10, 10a, 10b, 10g

Method: read each chapterN.gd in full, HUD (choose, set_objective, spots, say, say_chain), ObjectiveMarker, KickMeter, Stage.walk_player, HardwareStore, Galata consts, strings.csv and the flow traces. Only code-verified items are listed; guesses are marked UNSURE. No dialogue is cut or rewritten anywhere below; fixes touch objective text (UI_ keys), markers, prompts, timers and when the player is freed.

Global facts that shape the findings
- No HIGH (stuck / permanently lost) was found. No soft lock in any of the six chapters: every phase has a marker + objective or a finite scripted path.
- `hud.choose` timeouts are OFF by default (hud.gd:3031, setting `timed_choices`). The "⏱" icon in several option strings is therefore only a label unless the player turned the setting on. When it is on, the red bar has no number and no text.
- None of the six chapters calls `show_controls` or `set_qte` (grep: no match). Controls are carried by `[E]` focus prompts (fine) and, in 10b only, by the pour meter label. Needed keys (E, WASD, mouse) are known from chapters 1-4; the only new key in this group is the pour press in 10b (shown) and Shift to run in 10g (not shown).
- Marker hides within 4 m (objective_marker.gd:14,150) while the interact ray is 2.4 m (player.gd:158): a 2.4-4 m dead zone with neither marker nor `[E]`. Same in all chapters, noted once here.

## Summary of findings

| # | Sev | Ch | Where | One line |
|---|-----|----|-------|----------|
| 1 | MED | 10b | chapter10b.gd:215 + strings UI_OBJ10B_CAST | Objective says "stop when the mould is full" but full = red spill zone; green is 55-85% |
| 2 | MED | 10g | chapter10g.gd:67 | 45 s ship-bell countdown keeps running while the player is frozen in an optional dialogue |
| 3 | MED | 10 | chapter10.gd:244-249 | Objective never mentions the queue people, who give the only hint for question 3 |
| 4 | MED | 8 | chapter8.gd:213-268 | 60 s uninterrupted frozen stretch (27 s to 88 s) before first free control |
| 5 | MED | 8 | chapter8.gd:20,118-124,184 | Hard 150 s (real, un-paused) deadline never explained as a failure condition |
| 6 | MED | 8 | chapter8.gd:521,543-552 | Tea break (only counter to the torches) is undiscoverable; 18 s window partly eaten by frozen line |
| 7 | MED | 8 | chapter8.gd:192 | Part markers vanish within 4 m in a 14 m shop; parts are small and hidden on shelves |
| 8 | MED | 10a | chapter10a.gd:216-226 | 34 s frozen intro; the actual task is only stated in the last line |
| 9 | MED | 10a | chapter10a.gd:316-381 | 57 s frozen Nihat arrival (53-110 s), 72 s frozen from "sorted" to the cut to the Otag |
| 10 | MED | 9 | chapter9.gd:605-620 | Hikmet (8.4 variant) talk: 10 lines frozen, est. 45 s, no choice |
| 11 | MED | 10b | chapter10b.gd:304-343 | 31 s frozen (53-79 s) Fatih arrival before the powder choice; chapter has no free control at all |
| 12 | LOW | 10b | chapter10b.gd:581-693 | Big Bang variant: est. 70 s frozen (UNSURE, not traced) |
| 13 | LOW | 10g | chapter10g.gd:103 | Run key and climb not hinted for a timed run |
| 14 | LOW | multi | choose timeouts | Timed choices: silent default branch on timeout, unlabeled bar |
| 15 | LOW | 10 | chapter10.gd:329-347 | Item list in the ready menu has no hint what items do |
| 16 | LOW | 10a | chapter10a.gd:244 | Shelf for the held file not marked (colour match by eye) |
| 17 | LOW | 10b | chapter10b | Prompt "E · Topçuların yanına git" flickers during scripted walks (envoy side event) |
| 18 | LOW | 10b | chapter10b.gd:424 | Explosion risk system is hidden |
| 19 | LOW | 8 | chapter8.gd:418,433 | 0.67 s from sight to catch; agents keep walking while player is frozen |

## Chapter 8 (hardware store)

Flow (trace ch8.txt): card, 4 Hikmet lines + van line (3.4-26.2 s frozen, 22.8 s, OK), FREE with objective "Nöbetçi Hırdavat'a gir" (UI_OBJ8_ENTER) and a marker on the door (chapter8.gd:196). Walking past z<-1.5 triggers `_enter_store` (:174). Then Cemil + agents entrance 27.4-87.7 s frozen. Then FREE with `UI_OBJ8` "Makinenin parçalarını topla · Saat 05:00 (servis 07:30) · yakalanma 0/3" plus a checklist and one coloured marker per missing part (`hud.spots`, :192). After all parts: "Hepsi tamam: Cemil'e öde (tezgâh)" (UI_OBJ8_PAY) with marker on Cemil. Objective text, marker and code agree (interact id `part:<id>`, `cemil`).

Checks passed: objective is cleared during frozen scenes (:216, :628, :693) so no stale objective; catch -> teleport to counter -> objective rebuilt (:470); end of chapter is clear (garage card with clock, `UI_CH8_RIDE/STAY` choice, flowchart). Failure by 3 catches or by late clock is explained by dedicated lines (D8_H_FAIL_*), retry is the replay button only (by design, it is a story branch 8.2).

Problems

1. MED (frozen 60 s) chapter8.gd:213-268, lines D8_C_01 (27.4 s) .. D8_H_AGENTS (end ~87 s). First 35 s is Cemil conversation (D8_C_01, D8_H_C_02, D8_C_03, D8_H_LIST, D8_C_WHERE), then 25 s of agents arriving (D8_A1_ENTER, D8_C_TAPE, D8_C_TEA, D8_A2_ENTER, D8_A1/A2_KNOWN/UNKNOWN, D8_H_AGENTS). The player has only mouse-look. D8_C_WHERE (48.4 s, "kondansatörler birinci reyonda... antenler en arkada") is exactly the information that the world markers would give, but no objective/markers are set yet. Fix (minimal, no line cut): before `await _say("SPK_CEMIL", "D8_C_WHERE...")` (:230) call `hud.set_objective(...)` with the `_update_objective()` parts list + markers (set `phase="store"`-style display only, keep player.frozen), so the markers are visible while Cemil explains. If the owner wants real freedom: the agent entrance (:233-264) is tween-driven and has `player.face()` calls (:234,249,253), so freeing there is UNSURE; do not free it.

2. MED (unexplained deadline) chapter8.gd:20,118-124, UI_OBJ8. `_clock` advances 1 game-minute per real second only while not `_busy`; 05:00 to 07:30 = 150 s of free time, each catch costs 10 s (:432). At 07:30 `_fail("late")` fires (:123) even if all parts are in the basket. The only explanation is the text "Saat 05:00 (servis 07:30)" which ticks fast; no line or prompt says "this is a time limit and running out ends the chapter in failure". New players read it as flavour. Fix: at the moment of freeing (:265-267) fire a one-off `hud.bark("SPK_HIKMET", <existing key or new UI key>, 4.0)` or, cheaper, change UI_OBJ8 / UI_OBJ8_HEIST to read "... · Saat %s (07:30'da servis: geç kalma) · yakalanma %d/%d". Also consider `hud.set_chase` style bar for the clock. Note: with all parts in hand the late-fail still triggers (the D8_H_FAIL_LATE_PARTS line exists, so it is intended); LOW unfairness, the marker to Cemil is clear.

3. MED (undiscoverable help, partly wasted window) chapter8.gd:521, :543-552. Talking to Cemil before the tea is used offers "☕ 'Cemil, beylere birer çay koy.'" vs "'Neyin nerede olduğunu bir daha söyle.'" (UI_CH8_TEA / UI_CH8_HINT). Nothing says that tea blinds the agents for 18 s (vision check is skipped while `_tea_left > 0`, :375-391), and Cemil has no marker/objective until the basket is full, so most players never talk to him. Also `_tea_left = TEA_SECONDS` (:547) is set before `await hud.say("SPK_HIKMET","D8_H_TEA")` (:552) while the player is frozen, and `_patrol` ticks it regardless of `_busy` (:125), so about 4-6 s of the 18 s are lost in a frozen line, and the HUD shows "Ajanlar çayda: 18 sn" counting down before the player can move. Fix: (a) append to UI_CH8_TEA "(ajanlar 18 sn oyalanır)" (UI text, not dialogue); (b) move `_tea_left = TEA_SECONDS` to after the `D8_H_TEA` say (swap :547 and :552); (c) optional: in `_update_objective` add the Cemil spot as a second coloured choice marker labelled "Cemil: çay" (`hud.spots`-style) until `_tea_used`.

4. MED (marker vanishes) chapter8.gd:192 (no `hide_near` change anywhere in the file). The store is 14 m deep, aisles 3.5 m wide; parts are 0.8 m trigger boxes on shelf sides (PARTS in hardware_store.gd:21-29). The marker hides at 4 m, so the last 4 m (an entire aisle) must be solved by eye with the `[E] Al:` prompt only appearing within 2.4 m. Chapter 1 lowered the value in a small room for the same reason (chapter1.gd:160). Fix: `hud.marker.hide_near = 1.5` when `phase = "store"` is set (:265) and restore at checkout. Visual conspicuity of the parts is UNSURE (not checked in a render).

5. LOW chapter8.gd:418,433. Detection fills at `1.5 * _alert` per second: 0.67 s (0.48 s with the "known" suspicion). The 🔦 gauge exists (UI_CH8_AWARE) but there is no grace after unfreezing from a pick animation or a Cemil hint speech: the agents keep patrolling while the player is frozen (`_patrol` runs when busy, only the vision check is skipped, :410), so the player can be released next to a lit agent. Fix: after any `_busy` section ends, set `st["aware"] = -0.5` (or skip vision for 0.8 s).

6. LOW chapter8.gd:712. The 10 s ride/stay timer exists only with the setting on; both options are described, consequence of "Makineye bin" is clear. OK.

Not a problem: controls (movement + E) are covered by prompts; Phone has `D8_H_NO_CARD` bark; nothing can soft-lock (all parts reachable, Cemil always accepts payment once `_all_parts()`).

## Chapter 9 (offers)

Flow (ch9.txt): card, D9_T_A, radio call (`D9_H_CALL`) + 6 s timed Answer/Not now choice (chapter9.gd:298), D9_T_ANSWER, D9_H_8_1, D9_T_GOAL (3.5-31.8 s frozen, 28 s, of which the choice is interactive; acceptable). FREE with `UI_OBJ9` "Otağ kapısına git ve huzura çık. Yol üstündeki teklifler hikâyeyi başka yöne çevirir." Gold marker on the guards (the main path), each open offer a coloured marker with legend ("Kadri: Ziyafet"...), declined ones struck through. Objective, markers, and the `[E] Konuş:` prompt agree. Every talk re-runs `_update_objective` (:375). Offers have a trial choice (three clear options each) and a separate "✔ Evet, bu yoldan giderim / ↩ Dur, bir düşüneyim" confirmation (`_sure`, :531), so branch commitment is clear. The gate choice ("Kapıda bekle: huzura çık" / "Henüz değil") is preceded by D9_T_GATE_OPEN ("Burada beklersem hepsine hayır demiş olurum") when offers remain, so the consequence is hinted. Chapter end: farewell card per outcome (`UI_CH9_END_*`) then flowchart. Goat is harmless (it only flees, npc/goat.gd:64).

Problems

1. MED (frozen, freeable) chapter9.gd:605-620, keys D9_T_H2_1, D9_H2_2, D9_T_H2_3, D9_H2_4, D9_T_H2_GUN, D9_H2_GUN, D9_T_H2_GUN2, D9_H2_GUN2, D9_T_H2_5, D9_H2_6 (8.4 variant only; not in the trace, estimate ~40-50 s from average line length). Nobody needs to stand still; there is no camera cut and no choice. Fix: in `_hikmet()` replace the sequential `await _t/_say` chain by `hud.say_chain([...])`, keep `player.frozen = false`, set `_cur_npc = "hikmet"` for the whole chain (so `_hikmet_flee` at :221 keeps him still) and keep the objective visible; `while hud.chain_busy()` before ending. `_busy` must stay true so a second E does nothing. UNSURE: Hikmet's `look_target = player`, so turning away looks fine.

2. LOW Hikmet (8.4) and Çandarlı's hooded man are talk-only NPCs with no marker and not named in the objective; players may never find the Hikmet scene. Optional: add Hikmet as an extra coloured choice in `_update_objective` (:326 loop) while `ch9_met_hikmet` is false.

3. LOW chapter9.gd:298. With timed choices on, 6 s to answer the radio, and timing out costs one telsiz bar (:310) without saying so. Only relevant with the setting on.

4. LOW chapter9.gd:536-565. Following the gold main marker (the objective's first sentence) leads straight to the 9.6 branch; the confirmation exists only as the D9_T_GATE_OPEN line, not as the `_sure()` card used for the other branches. Consistent fix: wrap `c == 0` in `_sure()` for symmetry (only when `open > 0`).

## Chapter 10 (Otağ gate, Question Agha)

Flow (ch10.txt): card, 3 intro lines (3.4-22 s frozen), FREE with `UI_OBJ10O` "Sorucu Ağa'nın üç sorusunu geç · kalan deneme: 3" and a marker on the Agha (chapter10.gd:249). The Agha is reached with E; `_trial` walks the player to him (:322), so a far press is fine. Q1 and Q2 are 3-option (4 with the letter), Q3 is 4-option, and "Bilmiyorum" and the counter-question both pass, so only B/C style answers fail. Failure: Hasan and Hüseyin carry the player back, `D10O_A_NEXT`, objective tries counter drops before the line (:495), `D10O_T_THROWN_n` explains. Retry is fair (no timer between tries, `_know` persists, Q3 is the same question: `_q3` fixed at _ready). Third failure leads to Kadri/kitchen with lines (10O.2). Chapter end is explicit (flowchart).

Problems

1. MED chapter10.gd:244-249. The objective never tells the player that the three queue people (camel driver, dervish, tailor) hold the answer to question 3. Only one Tolga line (D10O_T_02, "sıradakilere bir sorayım") hints at it, and it is spoken during the frozen intro. They have `[E] Konuş:` prompts but no marker. A player who goes straight to the Agha has a 1/3 chance on Q3 (but can safely say "Bilmiyorum"). Fix: add an optional line and coloured markers using the existing pattern: `hud.set_objective(head + hints, hud.spot("aga"), 0.9, hud.spots(["cameleer","dervish","tailor"], func(id): return _talked.has(id), {"cameleer": tr("SPK_CAMELEER"), ...}, 1.4), "")` plus an extra objective line "(isteğe bağlı) Sıradakilere sor: üçüncü soruyu bilirler" (new UI key). Skip-callable prevents re-marking talked ones.

2. LOW chapter10.gd:329-347. The first menu after D10O_A_INTRO lists "Sorulara hazırım" plus every bag item (Telefon (%14), Koli Bandı, Leblebi, Rubik Küpü, Kolonya in the trace). Nothing says what showing an item does (leblebi skips Q1, selfie stick skips one question, thermos/chickpeas are spent). Not harmful. Optional: show hud.bark/objective sub-line "Eşya gösterebilirsin" via `UI_` key above the choice.

3. LOW chapter10.gd:406,422. With timed choices on, question timers are 9 s (Q1/Q2) and 12 s (Q3), the bar has no number; timeout gives D10O_A_TIMEOUT which explains the failure. OK.

4. LOW chapter10.gd:583-607 (envoy variant, not traced): Q3 comes with no chance to ask the queue; wrong answer still passes (`D10O_A_ENVOY_WRONG`), no problem.

5. LOW (UNSURE) The throw-out (`_thrown`, :454-496) is frozen about 12-15 s per failure; acceptable.

## Chapter 10a (Byzantine archive)

Flow (ch10a.txt): intro 3.5-37.6 s frozen, then FREE with `UI_OBJ10A` "Dosyaları renk rafına yerleştir (0/6): masadan al, rafa koy" + marker on the table (chapter10a.gd:244) and "Elinde: yeşil dosya" while holding. Prompts: `E · Dosya al` (UI_PROMPT10A_TAKE) and `E · Yeşil rafa koy` (UI_PROMPT10A_SHELF). Wrong shelf: Theodoros barks D10A_TH_WRONG_n, no penalty, no counter loss; empty-handed shelf press barks D10A_TH_EMPTY. Counter and held-colour update immediately. Everything agrees with the code (`DOCS[_doc]` == shelf id). Objective is cleared when sorted (:299). After that the rest is scripted: Nihat arrives, Form Z-1, cut to Otag, signing choice, meeting. Chapter end is clear: card ("İlk Büro toplantısı"), flowchart; refusing is clearly worded ("Ben sigortacıyım. Büro kuramam.") and has its own card.

Problems

1. MED (frozen, task stated last) chapter10a.gd:216-225, keys D10A_TH_01, D10A_T_02, D10A_TH_03, D10A_T_04(_CUBE), D10A_TH_05 (3.5-37.6 s, 34 s). The assignment ("Renk kodu... Deneyin. Lütfen.") is the last line. Fix with the existing chain pattern: after D10A_TH_03 set `phase="free"; player.frozen=false; _update_objective()` and play `D10A_T_04(_CUBE)` and `D10A_TH_05` as `hud.say_chain([["SPK_TOLGA", ...], ["SPK_THEODOROS", "D10A_TH_05"]])`; the loop at :229 must also wait `while hud.chain_busy()`. The two `player.face()` calls (:217, :220) are gags during frozen lines; if freed, drop the second (facing Theodoros) so the player is not yanked.

2. MED (frozen) chapter10a.gd:316-381: from D10A_TH_DONE_CLEAN (43 s) through D10A_N_FORM_6 (~110 s) is 57-72 s with no input, then the Otag scene (:385-419, 113-146 s, 33 s) and sign choice. Lines: D10A_N_01, D10A_T_N_02_NEW, D10A_N_INTRO, D10A_N_03, D10A_N_FORM_1, D10A_N_FORM_2 (53-87 s, 34 s) have no choice and no required position for the player (Nihat walks to the frame under his own tween, :365-368). Could run as `say_chain` with the player free and an objective "Nihat'ı dinle"; but `Stage.approach(nihat, player.global_position)` at :359 and `Stage.walk_player` at :375 then re-pull the player, so this is UNSURE. A safe first step: only free the player for D10A_N_01 + D10A_T_N_02_NEW + D10A_N_INTRO (before Nihat walks to the form), with objective "Yeni gelen adamı dinle". The Otag scene (cut, `OtagHall.TOLGA_SPOT`) should stay frozen.

3. LOW chapter10a.gd:244. While a file is held (`_doc >= 0`) the marker is dropped (`null`), per the comment "rafı bulmak oyuncuda". The room is 26 m long and dim; the three shelves are 6-10 m from the table. New players were reported to ask "where do I put it". Fix with the stated pattern: when `_doc >= 0`, pass `hud.spots(["shelf_red","shelf_blue","shelf_green"], Callable(), {"shelf_red": tr("UI_CH10A_COLOR_RED")...}, 3.0)` as choices and no main target; this keeps the colour match as the puzzle but shows where the shelves are. (Mind the 4 m hide_near: set `hud.marker.hide_near = 2.0`.)

4. LOW chapter10a.gd:429. "⏱ İmzala" has a 10 s timer only with the setting on; on timeout the code takes the sign branch (`c == 1` is refuse), i.e. the main route to chapter 13. Consequence of each option is not hinted beyond the wording. Optional: `_sure`-like confirm for the sign branch is not needed; leave.

5. LOW the final meeting (D10A_N_MEET_1..5, 159-197 s, 38 s) is frozen epilogue; acceptable.

## Chapter 10b (the big shot)

Flow (ch10b.txt): the whole chapter is cutscene + choices; the only moment of real input besides choices is the pour meter. Objective exists only during the cast (UI_OBJ10B_CAST); between choices the player is frozen, so no "(yok)" gap matters. Choices: name (clear), tape yes/no (clear), powder (3 options with hints "Sultan izliyor", "ekstra enerji"), angle (phone / eye / cube) and fuse. Results are distinct (10B.1/2/3); end is a flowchart with the Risk number shown in the footer (`UI_CH10B_STATS`).

Problems

1. MED (objective contradicts the meter) UI_OBJ10B_CAST "Bronzu kalıplara dök (3 kalıp): kalıp dolunca dur" (strings.csv:1976) and the spoken D10B_U_CAST_INTRO "Kalıp dolunca dur". In code the mould visibly fills with the cursor (`sc = 0.15 + 0.85 * v`, chapter10b.gd:253) and `KickMeter` zones are weak <0.55, green 0.55-0.85, red >0.85 (kick_meter.gd:6-7). A player who stops when the mould "looks full" is in the red zone and gets D10B_U_CAST_SPILL. The meter label does say "E ya da sol tık: dökmeyi durdur (yeşilde)" (UI_CH10B_POUR), so the contradiction is between objective/voice and label. Fix (UI string only): UI_OBJ10B_CAST -> "Bronzu kalıplara dök (3 kalıp): çubuk yeşildeyken dur (E ya da sol tık)". Optionally change the mould fill so 100% is drawn at v=0.85 (`sc = 0.15 + 0.85 * clampf(v / 0.85, 0.0, 1.0)`), making "dolunca dur" true.

2. MED (frozen 31 s) chapter10b.gd:304-343: BLACK 53 s -> D10B_T_ARRIVE, D10B_U_BOW, D10B_F_01, D10B_U_TAPED/UNTAPED, D10B_F_02, then D10B_U_POWDER and the choice (79 s). Pure listening, no choice in the middle; Fatih walks in with a tween (:325-332) and `player.face` is repeatedly forced (:331,336), so freeing is UNSURE. If wanted: keep the player free during the first two lines only (D10B_T_ARRIVE + the drum + walk-in), with an objective "Sultan sahaya geliyor". Low gain; mainly flagged because the entire chapter has zero free control.

3. LOW (UNSURE, untraced) chapter10b.gd:581-693 Big Bang variant: B3_1, T_B3_2, 1.3 s x 5 slow-motion fall, T_B3_3 and 10 lines of Fatih/Urban/Tolga/Kadri, then radio: estimated 70 s frozen. The post-landing conversation (F_B3_1 .. F_B3_5, KADRI_B3) needs no fixed position, but `player.face` retargets constantly (:673-680).

4. LOW chapter10b.gd:244-262. Pour meter is a timed key press with no practice, no retry (three single attempts, then the result is baked into risk), and the green window is 30% of a 1.2-1.8 s sweep (cursor speed `POUR_SPEED * (1 + i*0.25)`: sweeps in 1.8 s, 1.45 s, 1.2 s). Failures are explained by Urban (CAST_COLD / CAST_SPILL). Never a stuck state. Optional kindness: make the second and third pour sweep speed equal to the first.

5. LOW chapter10b.gd:424. Risk (no tape + quality<2 + double/powerbank powder >= 2 -> explosion) is entirely hidden; the explosion is a story outcome and the footer shows Risk at the end only. Optional: Urban's D10B_U_CAST_BAD/GOOD already hint; no change needed.

6. LOW The trace shows "PROMPT E · Topçuların yanına git" (UI_PROMPT_EV_ENVOY, side_events.gd) for a moment at 85 s: during `Stage.walk_player` (player briefly unfrozen) the CampDay envoy side event is focusable because 10b moves the envoy and Saruca to (7.6,-12.4) (chapter10b.gd:311-315). A misleading prompt in the middle of a cutscene, and E there would start side-event barks (side_events.gd:106-108). Fix: in `_fatih_arrives` hide or remove the CampDay envoy/saruca interact (`day.get_node_or_null("Interact_envoy")` then `queue_free()`/`collision_layer = 0`) or free them as in the earlier `day.ring_node.queue_free()` pattern (:68).

7. LOW With timed choices on: calc 10 s -> "eye" (:418), fuse 6 s -> Urban lights (:446); neither is announced. Default off.

## Chapter 10g (Galata errands, ship bell)

Flow (ch10g.txt): intro 3.5-19 s frozen (2 lines), FREE with `UI_OBJ10G_0..3` and a marker on the current NPC (`hud.set_objective(tr("UI_OBJ10G_%d" % _step), galata.npcs.get(who))`, :117). Objective follows `_step` in order (fish, wine, notary, captain), wrong-order NPCs answer with EARLY lines and do not advance (so no confusion, no stuck). Wine choice (3 options) is clear. After the notary's D10G_N_5 the bell is set to 45 s (:162), the HUD shows "⏱ Gemi çanı: %d sn" through `set_chase` (:69) and objective changes to "✉ Venedik kaptanı: iskeleye koş!" with a marker on the captain. Distance notary (6,-10) to gangway (17,0.6) is about 15 m; player walk 3.2 m/s, run 5.2 m/s (player.gd:11-12), so 45 s is generous on its own. Missing the ship is explained by D10G_T_MISSED/C_MISSED/T_MISSED_2 and becomes the letter-to-Fatih branch (10G.2): not a dead end. Gangway choice and both endings are clear (card "Mektup geri götürülüyor", flowchart).

Problems

1. MED (timer runs while frozen) chapter10g.gd:67: `if _bell >= 0.0 and phase == "free"` has no `not _busy`. `_talk` freezes the player (:126) but phase stays "free", so the countdown keeps running during any dialogue after the bell: the double (D10G_D_1, D10G_T_D_2, D10G_D_3 about 15 s, he is at (-8,-2), 14 m from the notary), repeated wine/notary/fisher AGAIN lines, and any `Lore.scatter` pickup. If it hits zero while busy, `_missed` waits for the dialogue to end (:209-211) and then fails; the player is released and instantly sees the ship leave. Fix (one line): `if _bell >= 0.0 and phase == "free" and not _busy:`. Alternative: pause the countdown also during `get_tree().paused` (already true for _process).

2. LOW chapter10g.gd:98-104. The bell run is the one timed movement section in this group and no key hint is shown: Shift to run is not mentioned and climbing (`enable_climb`, :103) is not mentioned either (UI_CLIMB_HINT exists). Fix: when the bell starts (:162) `hud.show_controls(true, "UI_CONTROLS_CH0")` ("WASD: yürü · Fare: bak · Shift: koş") and `hud.show_controls(false)` in `_gangway` (:189) and `_missed` (:213).

3. LOW chapter10g.gd:198. "⏱ Gemiye bin" vs "'Mektubu Fatih'e götüreceğim.'" is clearly worded; timeout (setting on) boards the ship (skips chapter 11, W6). Boarding has no "are you sure" like ch9, but the captain's own lines (D10G_C_1, C_3 "Ya bin ya mektubu geri götür") state the stakes. OK.

4. LOW Optional: the double and the two `mg:haggle_*` stalls (galata.gd:577-578) are fully optional and unmarked. If a haggle minigame is entered during the bell, the countdown continues in `_process` (UNSURE whether the minigame pauses the tree); with fix #1 above, add `and not _busy` plus a check for the minigame flag if it exists.

## What is fine (one line each)

- 8: objective/marker/prompt agree, catches and clock are visible, ending clear.
- 9: offers system is well signposted (markers with legend, strike-through, confirmation card); only the Hikmet scene is long.
- 10: question flow, retries and failure explanations are good; only the queue hint is missing.
- 10a: file sorting is easy to understand once started; frozen sections are the issue.
- 10b: choices are well worded; the pour objective text needs a fix.
- 10g: errand chain is well signposted; fix the bell pause.

## Suggested fix order (smallest effort first)

1. chapter10g.gd:67 add `and not _busy` (1 line, removes the only unfair-fail path).
2. strings.csv UI_OBJ10B_CAST wording (1 string).
3. chapter8.gd:547/552 swap `_tea_left` assignment after the Hikmet line; append benefit to UI_CH8_TEA; add "servis 07:30'da: geç kalma" to UI_OBJ8/UI_OBJ8_HEIST.
4. chapter8.gd:265 lower `hud.marker.hide_near` while in the store.
5. chapter10.gd:249 add queue spots + optional objective line.
6. chapter10a.gd:216-226 free the player for the last intro lines (say_chain).
7. chapter9.gd:605-620 Hikmet scene as say_chain with the player free.
8. chapter10g.gd:162 `show_controls` run hint; chapter10b.gd:311 remove envoy interact during the scene.
