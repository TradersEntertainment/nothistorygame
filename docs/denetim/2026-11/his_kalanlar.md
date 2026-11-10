# Gameplay-feel findings: status against current code (repo /home/user/nothistorygame)

Method: Read/Grep only. Source files read: feel_g1/g2/g3.md, items.gd, player.gd (stow/keep_blade/show_prop), duel.gd stop, gunner.gd, carry.gd, stage.gd, plus targeted greps per chapter.
Totals (81 rows): FIXED 51, PARTIAL 17, OPEN 9, CANNOT TELL 4.
Key mechanisms verified in code:
- Right hand stowed when climbing / swimming / balancing / carrying: player.gd:811-816 (_sync_busy_hands: ladder, floating, _balance, free_hold, traversal.state) -> _stow().
- Sword kept after a duel: duel.gd:199-211 (Duel.stop -> player.keep_drawn_blade, player.gd:1012; keep_blade defaults true, player.gd:1008). Sheathes with a tween when hands are needed (player.gd:1043).
- Items.CHAPTER_HOLD (items.gd:21-61) now has 17, 18b, 19, 19o, 22o, 23, 24, 25, 26o, 27 and 28o-42b. Still missing: chapter2, 3, 5, 8, 14, 29o, 10g (and 43o, intentional per comment items.gd:51). Fallback is still the Buro remote (player.gd:1164-1168).
- show_prop kinds that exist (player.gd:1731-1886): card, tolga_card, book, letter, cube, pole, newspaper, policy, towel, ring, form, knife, powder, torch, handset, hammer, slipper, apron, kaftan, fez, tea, plus bag items. There is NO ladle, screwdriver, plank or rope prop.
- Stage.hammer_swings (stage.gd:132) exists but is called from one place only (chapter18.gd:579); 28o and 22o have their own hammer code.

## Table

| # | ch | finding | status | evidence | if open: smallest fix |
|---|----|---------|--------|----------|----------------------|
| 1 | 4 | chain/quay balance shows default item | FIXED | player.gd:812 (`_balance != INF` -> stow); chapter4.gd:622,1338 BalanceMeter | |
| 2 | 2 | slipway run and swim show remote | FIXED | player.gd:1115 (remote pocketed until taken), :812 floating stow; chapter2.gd:313 press_red raises it | |
| 3 | 6 | roof climb shows leblebi | FIXED | player.gd:813 (traversal.state) ; chapter6.gd:674 enable_climb | |
| 4 | 10g | letter not visible | FIXED | chapter10g.gd:154,243 show_prop("letter") | |
| 5 | all | general rule: stow while climb/balance/swim/carry | FIXED | player.gd:805-816 | |
| 6 | 10b | cast: no ladle/pour tool | OPEN | chapter10b.gd:225-266 crucible tilts by itself, no player hold/gesture | add "ladle" case to Player.show_prop (or hold_model a small ladle) at loop start (10b:224) + hand_gesture("pour") |
| 7 | 10b | powder sack | FIXED | chapter10b.gd:394 show_prop("powder") | |
| 8 | 10b | torch | FIXED | chapter10b.gd:450,460 show_prop lighter/torch | |
| 9 | 5 | tape seal | FIXED | chapter5.gd:413-414 show_prop("tape")+rub | |
| 10 | 5 | screwdriver for dismantling | PARTIAL | chapter5.gd:444 hand_gesture("reach") only, no tool | add "screwdriver" prop in show_prop, call at 5:441 |
| 11 | 3 | file in hand | FIXED | chapter3.gd:271 show_prop("form") | |
| 12 | 10h | breach planks tool | PARTIAL | chapter10h.gd:353 tape shown, planks/hammer never | add Stage.hammer_swings(player,3) after 10h:354 |
| 13 | 9 | Kadri trial | PARTIAL | chapter9.gd:859-861 gesture only (Urban uses phone, :848; miner ducks, :853) | show_prop("tea"/"knife") in _trial_action "kadri" |
| 14 | 7 | scanner as default | FIXED | chapter7.gd:155 player.set_scanner; items.gd:25 | |
| 15 | 0 | arrows handover | FIXED | chapter0.gd:282-295 bundles reach to defender | |
| 16 | 0 | arrows: drop per hit | PARTIAL | chapter0.gd:123-132 bundles are static camera children, speed_mult 0.9 only | Carry.attach(player,_carry,{weight 0.4}) and hide one bundle on player.hurt |
| 17 | 6 | tray carry has no balance | OPEN | chapter6.gd:1477 player.hold_model(tray), tween only | replace with camera child + free_hold + Carry.attach(...,{"weight":0.35,"balance":true}) as chapter25.gd:264-265 |
| 18 | 10 | tray carry has no balance | OPEN | chapter10.gd:521 player.hold_model(tray) | same as 17 |
| 19 | 6 | goat on rope | FIXED | chapter6.gd:502 reach_grab horns, :1508 _lead_goat | |
| 20 | 5 | parts carry speed+shake | PARTIAL | chapter5.gd:555 hold_model(_held); no speed_mult/Carry in file | speed_mult 0.85 while _held valid; shake on drop |
| 21 | 10a | files timer | PARTIAL | chapter10a.gd:256-261 file held via hold_model; no timer/penalty found | CANNOT confirm timer; add hud.set_chase countdown in file loop |
| 22 | 8 | basket | PARTIAL | chapter8.gd:489-506 part shown in hand, goes to basket; caught mechanic exists (:436) | acceptable; optional free_hold for basket handle |
| 23 | 10g | letter thief | OPEN | chapter10g.gd has no thief/gull; thief_gull.gd used only in ch6 (:795) | spawn ThiefGull near quay while show_prop("letter") |
| 24 | 10h | planks carry | OPEN | chapter10h.gd no plank carry at all (only :353 tape) | pickup planks via hold_model + Carry.attach(weight 0.8) |
| 25 | 8 | phone call, no receiver | FIXED | chapter8.gd:579 show_prop("handset", 60) | |
| 26 | 3 | tea | PARTIAL | chapter3.gd:553 TeaStation built for Hikmet; no show_prop("tea") in file (only ch13:851) | call player.show_prop("tea",2.2) at the tea choice (3:758 region) |
| 27 | 10l | dig as presses | FIXED | chapter10l.gd:217 _give_pick, :437 pick in right hand | |
| 28 | 20,26,20o,21o,22o,26o | Duel.stop makes sword vanish | FIXED | duel.gd:199-211, player.gd:1012-1028 keep_drawn_blade | |
| 29 | rifle phases | sword/rifle returns to default item | CANNOT TELL | looked for rifle keep logic in handgun.gd and Handover.hand_rifle; only saw hand_rifle calls (ch20:496, 26:549) | |
| 30 | 17,18b,19,19o,22o,23,24,25,26o,27 | missing CHAPTER_HOLD | FIXED | items.gd:52-54 | |
| 31 | siege | fallback should be empty hand | PARTIAL | player.gd:1164-1168 still select_item(0) (remote) when no match; missing: 2,3,5,8,14,29o,10g | in _auto_hold return without select_item for chapters >= 17 |
| 32 | cannon crew | _take: left-hand items, right item shown | FIXED | cannon_crew.gd:382,387 free_hold -> stow | |
| 33 | 20,20o,26,26o,22o,30o | gunner throws loaded gun unfired | FIXED | gunner.gd:226-237 (_engage fires first), :149 point_blank; chapter30o.gd:617 | |
| 34 | 20 | 8 trips, load vanishes on hit | PARTIAL | chapter20.gd:550 Carry.attach (sway), :555-562 _drop() just queue_free; Niko free loads :265-275 | on gunfire hit spawn falling load prop before free |
| 35 | 22 | barrel/fuse free_hold stays after hide | FIXED | chapter22.gd:320,338 reset to INF | |
| 36 | 22o | 7 trips, two-man hide | FIXED | chapter22o.gd:717 Carry, :485-499 hammer in right hand + free_hold | |
| 37 | 26 | wounded Giustiniani by NPC bearers | FIXED | chapter26.gd:643-666 bearers, :1054-1130 stretcherless carry with sway | |
| 38 | 26 | bundles/barrels | FIXED | chapter26.gd:1972-1986 free_hold + Carry.attach | |
| 39 | 26o | bucket/ladder | FIXED | chapter26o.gd:725,745 Carry.attach, :724,744 free_hold | |
| 40 | 24o | tray | FIXED | chapter24o.gd:399-400 | |
| 41 | 25 | tray | FIXED | chapter25.gd:264-265 | |
| 42 | 17o | bucket chain | FIXED | chapter17o.gd:893 Carry balance | |
| 43 | 18 | bridge planks/hammer | FIXED | chapter18.gd:579 Stage.hammer_swings, :470 _hand_work | |
| 44 | 20o | tape applied instantly from 5 m | FIXED | chapter20o.gd:384-393 walks to gun, show_prop tape | |
| 45 | 21 | bowls | FIXED | chapter21.gd:249-262 bowl lowered by hand | |
| 46 | 21o | supports | FIXED | chapter21o.gd:540-547,577-598 | |
| 47 | interlude edirne | skewers; CHAPTER_HOLD entry dead | PARTIAL | items.gd:48 key "interlude_edirne" but interlude runs inside chapter17 scene (chapter17.gd:457 `EdirneInterlude.new().run`; no interlude .tscn exists) so hold is chapter17's lighter/tape; skewers only hand_gesture (interlude_edirne.gd:1158,1204) | delete items.gd:48 key; call player.hold_now("book"/"cube") inside interlude; add skewer prop |
| 48 | 22o | fire rescue | CANNOT TELL | grepped hide/rescue/fire in chapter22o.gd; RESCUE_TIME const :29 but no hand/prop call located | |
| 49 | 26 | dressing wound | FIXED | chapter26.gd:342-363 duck, hold_now(item), reach gesture | |
| 50 | 13 | lighter fallback | FIXED | chapter13.gd:768-769 hold_now("lighter") | |
| 51 | 12b,12,14 | frozen cutscenes | PARTIAL | frozen=true: 12 x3, 12b x5, 14 x2; each has props (12:342,722; 14:227) but few player verbs; ch14 is Nihat watching typewriter by design (14:16) | CANNOT judge feel by code; add one interact (e.g. 12 letter hand-over via Handover.pass_to) |
| 52 | 19 | sail nothing to do | FIXED | chapter19.gd:621-660 sheet rope free_hold + BalanceMeter :623 | |
| 53 | 24 | litter meter cosmetic | PARTIAL | chapter24.gd:586-599 tilt, stagger, flail; slip event fires at fixed SLIP_AT=0.72 (:17,:601) not tied to stumbles | tie slip outcome to `stumbles` in the slip phase |
| 54 | 21 | RUN choice is a cutscene | OPEN | chapter21.gd:468-476 scripted tween of janissary | low priority; give a short sprint with hud.set_chase |
| 55 | 28o-43o | not in CHAPTER_HOLD, remote always in hand | FIXED | items.gd:55-60 (all but 29o, 43o) | add chapter29o to items.gd (e.g. ["chickpeas","thermos"]) |
| 56 | 28o-43o | Duel.stop -> show_remote(true) | FIXED | player.gd:1062-1063 only if hand was open before fight; keep_drawn path duel.gd:199 | |
| 57 | 30o | sword -> remote -> sword | PARTIAL | wave_runner.gd:133-135 keeps sword between waves, sheathes after last wave, then tower ladder, then StoryDuel (chapter30o.gd:632) | acceptable; call Duel.stop(true) after last wave if a duel follows |
| 58 | 30o | gunner throws loaded gun | FIXED | chapter30o.gd:617 point_blank | |
| 59 | 30o | ladder carry floating, no left hand | FIXED | chapter30o.gd:198 free_hold, :189-229 visual ladder with carriers | |
| 60 | 30o | wounded carry, remote under box | FIXED | chapter30o.gd:1603 Carry.attach weight 1.0 (free_hold stows right hand) | |
| 61 | 30o | wounded carry has no threat | CANNOT TELL | did not trace threats during retreat phase (chapter30o.gd ~1590-1620) | |
| 62 | 30o | top stone-thrower walks away | PARTIAL | chapter30o.gd:360-362 he deliberately retreats via _top_leave when player is near top | keep him in place (skip _top_leave) until player.ladder == null |
| 63 | 30o | first 3 min no combat | CANNOT TELL | header lists arrows at ladder carry (:6) but I did not measure duration | |
| 64 | all | ladder climb with remote | FIXED | player.gd:812 | |
| 65 | drill | duel.stop between lessons | FIXED | drill.gd:204,276 use default stop -> kept blade; duel.gd:153 reuses it | |
| 66 | 37o | wounded drag rope from "hand", remote shown | OPEN | chapter37o.gd:862 rope end is world point at player+0.9 m; :947-948 free_hold=INF and show_remote(true) before drag | in _drag set player.free_hold to a point at rope end and show_remote(false) |
| 67 | 37o | hook thrown with cymbals in hands | OPEN | chapter37o.gd:251 cymbals in both hands, :630-645 hook from world point beside player | hide right cymbal / hand_gesture("throw") in _throw_hook |
| 68 | 37o | plank carry | PARTIAL | chapter37o.gd:996-999 free_hold + static camera child, no Carry sway; speed_mult 0.6 | Carry.attach(player,_plank_carried,{weight 0.9}) |
| 69 | 36b | torch burn with remote | FIXED | chapter36b.gd:406-425 man hands lit torch | |
| 70 | 36b | sword vanishes before torch | FIXED | player.gd:1043-1058 sheathe tween, torch after (:390) | |
| 71 | 29 | rope cut with no blade | FIXED | chapter29.gd:503 show_prop("knife") | |
| 72 | 29 | bucket pour instant | FIXED | chapter29.gd:476 tilt-and-pour | |
| 73 | 29 | water carry no stakes | FIXED | chapter29.gd:440-468 Carry balance, fill < 0.4 | |
| 74 | 28o | stakes instant | FIXED | chapter28o.gd:625-628 _hammer_in 3 strokes | |
| 75 | 28o | roller | FIXED | chapter28o.gd:631-648 pick/place, Carry :693 | |
| 76 | 31o | lash/mat with remote | FIXED | chapter31o.gd:1402-1403 free_hold + Carry; :973 | |
| 77 | 39o | flag plant | FIXED | chapter39o.gd:176,371-383 bundle, pole from bundle, reach | |
| 78 | 30 | ladder push no pole | FIXED | chapter30.gd:214-221 _pole_show | |
| 79 | 35o | rope pull | OPEN | chapter35o.gd:802-830 _heave: no hand_gesture/free_hold on strokes (only bundles carried :777) | hand_gesture("reach",0.3) per good stroke or free_hold at rope |
| 80 | 32o | throw no gesture | PARTIAL | chapter32o.gd:577 free_hold carry, :591-604 _throw_in tween only; no hand_gesture, no Carry sway | add player.hand_gesture("throw") at top of _throw_in; Carry.attach at :577 |
| 81 | 43o | cuffs | FIXED | chapter43o.gd:722-749 cuffs model | |

## Top 12 OPEN/PARTIAL by player visibility (early chapters and long carry/tool runs first)

1. Ch6 and ch10 tray carry (rows 17, 18), OPEN. chapter6.gd:1477 and chapter10.gd:521 call `player.hold_model(tray)` and the tray is static. Replace with the chapter25.gd:264-265 pattern: add tray to `player.camera`, set `player.free_hold`, `Carry.attach(player, tray, {"weight": 0.35, "balance": true})`, and free both at delivery.
2. Ch10b cast ladle (row 6), OPEN. Three-pour minigame (chapter10b.gd:222-267) has no player tool. Add a "ladle" case to `Player.show_prop` (player.gd ~1836 next to "powder") or `hold_model` a small ladle, and `hand_gesture("pour")` each pour.
3. Ch5 dismantle and parts (rows 10, 20), PARTIAL. chapter5.gd:444 only `hand_gesture("reach")` for ~12 parts; add a "screwdriver" prop in `show_prop`, call at 5:441; give `_held` (5:555) `speed_mult` 0.85 and `player.shake` on drop.
4. Ch3 tea (row 26), PARTIAL. TeaStation exists (chapter3.gd:553) but Tolga's drink is never in hand. Call `player.show_prop("tea", 2.2)` (supported, player.gd:1886) in the tea branch near chapter3.gd:758.
5. Ch10h breach (rows 12, 24), OPEN/PARTIAL. Only tape is shown (chapter10h.gd:353). Add `Stage.hammer_swings(player, 3)` after the tape and a plank pickup via `hold_model` + `Carry.attach(weight 0.8)` for the "planks" in the objective.
6. Ch0 arrows (row 16), PARTIAL. First scene of the game: bundles are static (chapter0.gd:123-132). Attach with `Carry.attach(player, _carry, {"weight": 0.4})` and hide one bundle in `player.hurt` so "drop per hit" exists.
7. Ch37o drag and hook (rows 66, 67), OPEN. In `_drag` (chapter37o.gd:793) after `_drop_cymbal_and_shield` set `player.free_hold` to the rope end and call `player.show_remote(false)` instead of line 948's `show_remote(true)`; in `_throw_hook` (:630) add `player.hand_gesture("throw")` and drop the right cymbal first.
8. Ch35o rope pull (row 79), OPEN. In `_heave` (chapter35o.gd:808) call `player.hand_gesture("reach", 0.3)` on every stroke and set `free_hold` at the rope point while phase == "mud".
9. Ch20 load drop (row 34), PARTIAL. `_drop()` (chapter20.gd:555) frees the load silently when the shout/gun knocks the player; spawn a falling copy of `_carry_node` (barrel/earth/plank) and `Audio.sfx("land_thud")` before `queue_free`.
10. Ch24 litter and ch37o plank, ch32o throw (rows 53, 68, 80), PARTIAL. 24: make the slip phase read `stumbles` (chapter24.gd:601). 37o: `Carry.attach(player,_plank_carried,{"weight":0.9})` at chapter37o.gd:999. 32o: `player.hand_gesture("throw")` first line of `_throw_in` (chapter32o.gd:591).
11. Ch10g/10a/9 small verbs (rows 13, 21, 23), PARTIAL/OPEN. 10g: spawn the existing ThiefGull (scripts/npc/thief_gull.gd, as chapter6.gd:795) while the letter is shown; 9: Kadri trial gets `show_prop("tea")` (chapter9.gd:859); 10a: add a visible countdown to the file loop.
12. Fallback and dead keys (rows 31, 47, 55), PARTIAL. Delete dead `interlude_edirne` key (items.gd:48) and use `hold_now` inside the interlude; add `chapter29o` to CHAPTER_HOLD; consider `_auto_hold` (player.gd:1164-1168) leaving the hand empty for siege chapters instead of the remote.

Not ranked: rows 51 (12/12b/14 frozen scenes, cannot judge feel from code) and 54 (ch21 RUN cutscene, low).
