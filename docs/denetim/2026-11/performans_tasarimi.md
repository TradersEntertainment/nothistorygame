# P2: draw-call and triangle reduction design (picture stays the same)

Repo: /home/user/nothistorygame (Godot 4.4.1, gl_compatibility). Everything below comes from reading the code only.
Line numbers are for the files as they are now. Nothing in the repo was changed.

## 0. Where the cost comes from (what the code shows)

- **Every opaque mesh is drawn twice.** `Props.mat()` (props.gd:83-84), `Dressing._material()` (dressing.gd:219-220),
  `Kit` (kit.gd:77) and `CharKit.vc_mat(true)` (char_kit.gd:526-527) attach an inverted-hull outline as `next_pass`.
  The outline pass is a separate surface, so it is a separate draw. In the GLES3 scene renderer, an opaque
  `next_pass` material (depth_draw OPAQUE, no alpha) gets the OPAQUE, DEPTH and **SHADOW** pass flags. So I expect
  that outlines are also drawn into every directional shadow split, where they only add a 1.2 cm larger copy of the
  caster (UNSURE U1).
- **Live character rigs are the biggest draw-call source in the land-walls scenes.** `CharKit.bake` (char_kit.gd:534-609)
  merges parts per pivot (pelvis, chest, head, upper and lower arms, wrists, thighs, shins, ankles, FaceDetail), so a
  Person is about 16-20 MeshInstances. Each has an outline, and equipment is added later as separate meshes
  (`Person.equip`, `Blades.*`, `BattleExtras.overhead_shield/kalkan`). Within shadow range a rig costs roughly
  20 x (2 colour + 2 splits x 2) = about 120 draws.
  - ch20: `Garrison.land_walls` with near [-32,32] plus inner_near [-14,14] gives about 36 live rigs. Four
    `fire_ring` groups, `WallFight`, `BattleExtras` and `SiegeChaos` add more, for 80+ rigs in total.
  - ch26 and ch0: the same set, plus 5 BattleExtras lanes (35 runners, 25 dead) and 2 squads (18).
- **MultiMesh crowds draw hidden instances.** `Assault._wave_runners` (assault.gd:248-298) builds 3 pose
  MultiMeshes per coat, and each one holds all runners of that coat. Two thirds of the instances are "hidden" by
  scaling them to 0.001 and moving them to y=-200 (assault.gd:349, 397), but they are still fully transformed and
  rasterised, in both the colour pass and the outline pass. The -200 point also makes the AABB huge, so these
  MultiMeshes are never frustum- or occlusion-culled. `PoseCrew` (pose_crew.gd:22, 98-115, 119-127) does the same,
  with 2-5 poses per kind.
- **Static scenery is built from hundreds of single Props meshes and never merged.** `Props.bake_static` exists
  (props.gd:608) but only `slipway.gd` (68, 837) calls it. Examples:
  - `ByzCity._house` creates about 90-110 meshes per house (byz_city.gd:362-434: brackets, 21 arch bricks, shutters,
    pots, lamp chains, spolia).
  - `LandWalls._broken_edge` and `_build_rubble`: about 170 + 70 meshes.
  - `Assault._ladders`: 8 ladders x about 19 = 152 meshes. `_ladder_team`: 5 x 17. Banners/tugs: about 7-10 each.
    Batteries and earthworks: about 70. Trebuchets: about 16 each.
  - Galata tower `_tw_seg`: 24 segments x about 10 rings, each a `Props.solid` mesh (galata.gd:363-515).
- **Positional lights are not the problem.** None of `Night.torch`, `Night.campfire`, the gun flashes
  (assault.gd:628, siege_field.gd:1297) or the camp lights enable shadows. The only shadow-casting lights in these
  scenes are the moon/sun (night.gd:40, 35 m; byz_city 80 m and galata 70 m, capped to 70 by
  game_state.gd:1202-1203; 2 splits by look.gd:156). No positional light shadow can be switched off, because none is
  on.

## 1. Ranked changes (expected saving / risk)

### #1 Keep outlines out of the shadow maps (global, 2 lines)
- **Where:** props.gd:89-97 `_outline_mat()` and char_kit.gd:32-40 `_outline()`.
- **Change:**
  ```
  + _outline.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED   # likewise _ol
  ```
  A material with depth_draw DISABLED is classified alpha-pass-only, so it gets no SHADOW or DEPTH flag. The outline
  is still depth-tested against the opaque depth buffer and still draws in the colour (alpha) pass, so the silhouette
  lines look the same.
- **Scenes:** all of them. Shadow share is 46% in ch26, 45% in ch22o, 36% in 26o, 35% in ch20, 32-34% in 10g, ch9
  and 10z, and 27% in ch0.
- **Estimate:** assume half of all shadow-pass draws are outline surfaces, since almost every caster has one.
  - ch26: about -2900 draws (12850 x 0.46 / 2).
  - ch20: about -1850. ch22o: -1700. ch26o: -1600. ch0: -1230. ch10g: -1250.
  - Triangles: if the outline share of shadow triangles is also about half, then -1.5..-3 M in ch26, ch0 and ch20.
    The ch0 bisect put the shadow pass at about 6 M; it is now smaller after the 35 m change.
- **Why the picture stays the same:** the outline shell only grows the shadow caster by 1.2 cm (0.84 cm on
  characters). That is below one shadow texel at 35-70 m distance.
- **What could go wrong:**
  - Outlines now sort with the transparent objects (flames, glows, smoke). Where a large glow halo
    (`Flame.scatter_glows`) or smoke is sorted after a silhouette that is in front of it, a few 1-px outline pixels
    may get tinted.
  - Outlines no longer write depth, so a transparent object behind a silhouette edge can show through by one pixel.
  - The water (city_panorama.gd:260, `water.gdshader`) is opaque, so submerged outlines do not leak.
- **Verify:** run `tests/perf_run.sh` on ch26, ch20 and ch0. The RINFO shadow split should fall about 50% and colour
  draws should stay the same. Then take screenshots before and after (the shots mode in chapter scripts) and compare
  them pixel by pixel around the silhouettes near torches and smoke.

### #2 Compact the pose MultiMeshes instead of hiding instances (Assault, PoseCrew)
- **Where:** assault.gd:276-282 (build), 358-401 `_update_runner` (writes `_hidden`); pose_crew.gd:79-127 `build`,
  `_show`, and `suppress` (59-71).
- **Change (pseudo-diff):** each pose MultiMesh keeps a dense slot list.
  - `slot_of[man]` and `man_at[pose][slot]`.
  - To show man m in pose p: move the last visible instance of his old pose into his old slot (swap-remove), append
    him to pose p, then `mm.visible_instance_count = count[p]`.
  - Set `mmi.visible = count[p] > 0`, which removes the colour, outline and shadow draws of empty pose meshes.
  - Remove the `_hidden` transform writes.
  - For runners, also set `mm.custom_aabb = AABB(Vector3(-wall_len/2, -4, 12), Vector3(wall_len, 10, 52))`. PoseCrew
    already has a custom AABB (pose_crew.gd:107).
- **Scenes:** 0, 20, 22o, 26, 26o, 36b and 37o (runners), plus every scene with `Garrison.land_walls(busy=true)` or
  SiegeField `wall_crew` (PoseCrew).
- **Estimate:**
  - ch26 has n = int(140 x 1.5) + 40 = 250 runners and 750 drawn instances, 500 of them hidden. The army bisect gives
    4.7 M for about 2000 near soldiers, so about 2.3 k triangles per crowd figure (UNSURE U3). 500 x 2.3 k x 2
    (colour + outline) is about **-2.3 M triangles**.
  - ch0 and ch20 (n = 180/173): about -1.6 M.
  - PoseCrew with about 70 crew, an average of 2.5 poses and 2.3 k triangles: about -0.5 M.
  - Draws: -10..-40 (empty pose meshes).
  - With the tight AABB, the runners are also culled by the existing wall occluders when the camera is inside the
    city.
- **Why the picture stays the same:** the hidden instances are 1 mm big and 200 m underground. Nobody ever sees them.
- **What could go wrong:**
  - Swap-remove bookkeeping bugs can make a figure flicker or appear twice. Unit-test it by checking that the sum of
    the counts equals the number of men every frame.
  - The torch flame MultiMesh (`_run_flames`) keeps using its own index map and is unaffected.
- **Verify:** RINFO triangles should drop with draws unchanged. `bisect_probe` on the "Assault" node before and after
  should show the runner share fall by about two thirds.

### #3 Make `Props.bake_static` safe to use broadly (enabler for #4-#8)
- **Where:** props.gd:608-665.
- **Change:**
  - (a) Add a size class to the group key, using the same rules as `cull_small` (props.gd:580-599): <0.3 m, <1 m,
    <3 m, <8 m and larger. Set the output's `visibility_range_end` to the cull_small value for that class times k.
    Without this, small parts that cull_small hides beyond 40/90 m would be drawn at all distances after merging.
    That is more triangles and a slightly different far picture.
  - (b) Add `mi.visibility_range_end` and `mi.layers` to the key and copy them over.
  - (c) Make `out.set_meta("no_walk", true)` optional (`walk := false` parameter). Baking under a WorldWalk root
    (SiegeField, World1453; world_walk.gd:158) would otherwise remove walkable collision that came from the
    MeshInstances.
  - (d) Skip nodes with meta `flag`, nodes named `Flame`/`Lens`, and subtrees with `no_bake`.
  - (e) Keep the group key on cast_shadow and next_pass, as it already is. That preserves the `_place` rules
    (no outline <0.1 m, no shadow <0.3 m).
  - Bake **per sub-assembly root** (one house, one ladder, one battery), never across a whole level. This keeps
    frustum, occlusion and shadow-split culling granular.
- **Why the picture stays the same:** the merged meshes reuse a duplicate of the same toon material with
  vertex_color_use_as_albedo, as slipway already does. Outline shells grow per vertex normal, and the vertices are
  not welded, so the merged outline equals the union of the old outlines.

### #4 Bake the static decoration of LandWalls, Assault and Ladder (land-walls family, 9 scenes)
- **Where and what to bake:**
  - land_walls.gd: end of `_broken_edge` (381-440). The rows, cores, overhanging stones, cracks and soot are direct
    children of `self`, so wrap them in a `Node3D "EdgeDecor"` per side and bake that.
  - land_walls.gd: end of `_build_rubble` (537-614), wrapped as `RubbleDecor`. Smolder VFX is skipped because it is
    transparent.
  - land_walls.gd: `_build_depot` (618-639); the tower window boxes (287); the stakes (229); the postern (290-291);
    and the mantlet children `mn` (515-529; bake each `mn`, it is static).
  - assault.gd: `_batteries` g (594-599, before the crew scatter); `_earthwork` g (682-693); `_trebuchet`, baking r's
    static frame (704-710) separately from `arm` and `cw` (each baked as its own root, because they rotate);
    `_sancak`/`_tug` poles; `_ladders` l (419-422); `_ladder_team` lad (825-828), where `lad` moves as a whole so its
    baked child moves with it.
  - ladder.gd:27-31: bake the `frame` after building.
  - Do **not** bake: the `_wall` bodies (the gate plug is freed, land_walls.gd:299), the `stages` (shown one by one),
    or anything in `Garrison`.
- **Scenes:** 0, 20, 22, 22o, 25 (walls branch), 26, 26o, 36b, 37o, 32o and 28o.
- **Estimate:**
  - About 650 meshes in Assault and about 280 in LandWalls become about 100.
  - Colour pass: 830 x 2 (with outline) x about 50% in view is about -800 draws.
  - Shadow pass (35 m moon): the LandWalls decoration is near the player. About 250 meshes x 2 splits x 1 (after #1)
    becomes about 20, which is about -460.
  - **Total about -1200 draws** per land-walls scene. Triangles: about 0, or slightly up for parts that cull_small
    used to drop. (a) keeps that change small.
- **What could go wrong:**
  - Code that later grabs a part by `get_child(0)` or by name. I found none for these decor parts. `set_repair` only
    toggles `stages`.
  - Collision from `Props.make_solid` stays, because it is a sibling StaticBody. Bake after make_solid has run.
- **Verify:** RINFO draws should drop. Run the existing WALKTHRU/VISAUDIT CI checks (insolid, overlap) for ch26/ch20.
  `bisect_probe` per new "…Decor" node.

### #5 Bake each `ByzCity._house` and the street furniture (Byzantine city scenes)
- **Where:** byz_city.gd:314-434 (`_house`). Add `Props.bake_static(h, [h], walk)` at the end. Do the same for the
  `_build_street` stalls, arches and laundry (437-515) via a `StreetDecor` holder. Leave out `_ground_mat` (set_wet)
  and the labels.
- **Scenes:** 12b, the Byzantine phases of 2, 6, 7, 9, 10x, 11, 24 and 25, and wherever ByzCity is built (26 late
  phase).
- **Estimate:**
  - 8 street houses x about 100 meshes is about 800, which becomes about 8 x 5 = 40.
  - Sun shadow at 70 m covers the whole street, so the saving per part is 2 colour + 2 splits x 1-2 shadow, which is
    -3000..-4000 draws in 12b if the street fills the view.
  - Even with 50% in view, about -2000. That alone would take 12b (7170) below 6000.
- **Risk:** low.
  - Climbable "facade" bodies keep their collision. The `Upper` StaticBody keeps its shapes, and only the
    MeshInstance is baked.
  - `Kit.roof` instances are multi-surface .glb, so bake_static skips them automatically (surface_count != 1).
- **Verify:** perf_run on ch12b; screenshot compare of the street at dusk (`make_sunset`) and at night.

### #6 Galata: bake the tower ring segments and the back-row window boxes
- **Where:**
  - galata.gd:363-371 `_tw_seg`: create a holder per ring (`TowerShell`, `TowerFloors`) and bake it after
    `_build_tower_climb` (373-540). The hidden segments (`show=false`) are skipped, because they are invisible.
  - galata.gd:232-238: the window and sill boxes of each back-row house.
  - galata.gd:255-272: the tower windows and the 24 consoles.
- **Scenes:** 10g, and 10b/10h if they build Galata (UNSURE).
- **Estimate:**
  - About 240 tower segments + 48 tower trims + about 250 window boxes (about 540 meshes) become about 20.
  - About -1000 colour draws and -500..-1000 shadow draws when the tower is in view.
  - The 9700 / 8.8 M peak (tower climb) should improve most.
- **Risk:** low. The tower segments are `Props.solid`, so collision stays.

### #7 Merge hand-held and attached props on live characters (all live-rig scenes)
- **Where:**
  - battle_extras.gd:103-117 `kalkan` (11 meshes, including 3 TorusMesh rings of 192 triangles each) and
    137-151 `arrow_bundle` (18 MeshInstances, **no material**).
  - battle_extras.gd:291-322 `_debris` and 325-330 `_stick`.
  - blades.gd:9-64 (kilij about 10 meshes, bow about 10, spathion 5, shield 3).
  - person.gd:1142+ `equip` and soldier.gd:331 `equip`.
- **Change:**
  - For `kalkan`, `Blades.*` and `equip`: call `Props.bake_static(item_root, [item_root])` before returning. Put
    `no_bake` on sub-nodes that are animated or looked up by name: the bowstring, if the Rig draws it;
    `find_child("Bow")` in crowd.gd:60 is the bow root itself, which is fine; `Lamp/Flame`, `Flashlight/Lens`.
  - For `arrow_bundle`: replace the 18 MeshInstances with one `MultiMeshInstance3D` with 18 instances, no material
    override and default shadow ON. It looks the same as before (default material).
- **Estimate:**
  - ch26: 8 bundles x 18 arrows sit next to the WELL on the player's path, inside shadow range. That is 144
    instances x (1 colour + 2 shadow) = about 430 draws, which become 24.
  - Equipped rigs: about 60 per land-walls scene x about 5 extra meshes x (2 + 2 shadow), which is -1000..-1500
    draws in ch26, ch0 and ch20.
- **Risk:** medium. The Rig attaches the shield via `shield_node` (battle_extras.gd:131-132). Bake inside the shield
  child `n`, not above it.
- **Verify:** run the `bisect_probe` group "battle_extras" before and after, then do a close-up screenshot of the
  depot and the shield wall.

### #8 Bake `Night.tent` and the static part of `Night.campfire` (camp scenes)
- **Where:** night.gd:155-183 (bake t after the parts are built; the body is a sibling) and 101-115 (stones and logs).
  Also camp_day.gd:1004-1011 (40 tents) and 843-865 (16 otağ ring tents), camp.gd:167-179 (34 tents), and
  siege_field.gd:1131 (gunners' camp).
- **Estimate:** a tent is 9 meshes (incl. a TorusMesh) and becomes 2-3. In camp_day night that is about 90 tents x 7
  = -630 meshes, which is about -1200 colour draws plus the shadow share.
- **Scenes:** 25 (Ottoman branch), 11, 4, 10z(?), 24o.
- **Risk:** low.

### #9 Cheap occluders on big opaque boxes that have none
Use `Props.occluder` with the default inset of 0.35.
- siege_field.gd:428: inner towers 9 x h x 8.1. Add `Props.occluder(self, Vector3(9, h, 8.1), Vector3(wx, h*0.5, 0))`.
- siege_field.gd:444: outer towers 5 x 11 x 5.
- byz_city.gd:327: house ground floor (depth x 3 x length). Also add the upper block (bm.size at `upper.position`).
- galata.gd:227 and 332: house bodies.
- sea_walls.gd:153, 174, 203, 214: wall bodies and towers.
- What this saves: Crowd cells, Dressing chunks, CityLife walkers and fill houses behind house rows (byz, galata), and
  the city behind the inner-wall extension.
- Sea walls: the city behind is one 620-house MultiMesh (sea_walls.gd:267). Occlusion can only cull it whole, so the
  gain there is small unless that MultiMesh is split into 64 m cells.
- **Estimate:** UNSURE. It depends on the view. Expect -200..-800 draws in byz street views and galata alleys, and
  little on the walls.
- **Risk:** very low; occluders are strictly inside solid boxes. CPU cost: a few dozen boxes.
- **Verify:** RINFO draws at fixed camera positions. The probe hides the occluders to compare.

### #10 Bake the static hull furniture of `SeaBattle.war_galley` (sea scenes)
- **Where:** sea_battle.gd:199-214. Bake the deck, rails, ram, awning posts, awning, mast, yard, furled sail, flag and
  crescent into g, using a holder `Static` and calling bake_static after building.
- Do **not** bake the oars (`OarGrip`) or the rowers.
- **Estimate:** about 16 meshes per galley become about 3. With 12 galleys in ch29 that is -150 meshes, about -300
  colour draws (shadow share there is only 6%). ch18 and ch17 are similar.
- **Risk:** low. The rails are `Props.solid`, so collision stays.
- **Note:** this does not explain the 7 M triangles in ch29/18 (see U8).

### #11 Turn off shadows on flush decals and floor slabs (no visible shadow)
- **Where:**
  - Blood pools: battle_extras.gd:263 and 322, 0.01 m thick.
  - Cracks and soot on the wall face: land_walls.gd:429-440, 0.02-0.04 m thick. Their shadow lies on the wall
    itself.
  - Dark window and door panels flush with walls: land_walls.gd:287 and 290-291; galata.gd:234, 261.
  - Floor slabs at walking level with nothing below them: land_walls.gd:173-174, 179 and 199 (top slabs only, not the
    3 m scarps); siege_field.gd:381-383.
  - The change: `mi.cast_shadow = SHADOW_CASTING_SETTING_OFF`.
- **Estimate:** -50..-150 shadow draws per land-walls scene. That is small, but it is free. If #4 bakes them, put
  them in the no-shadow group.
- **Risk:** very low. Do not apply this to the sancak cloth (0.03 m, its shadow is visible), to laundry, or to awnings.

### #12 (Prototype, largest potential) One skinned mesh per character rig
- **Where:** char_kit.gd:534-609 `bake`, plus the Rig update.
- **Change:**
  - Bake all pivot groups of a character into **one** ArrayMesh with `ARRAY_BONES`/`ARRAY_WEIGHTS`. Each vertex is
    weighted 1.0 to its pivot's bone. Use two surfaces: outlined, and FaceDetail without outline.
  - Add a `Skeleton3D` with one bone per pivot.
  - After `rig.update`, copy `skel.global_transform.affine_inverse() * pivot.global_transform` into the bone pose for
    each bone. Keep the pivot node tree for the gameplay code.
- **Estimate:** a rig drops from about 18 MeshInstances to 2 surfaces.
  - ch20 and ch26 have about 80-100 rigs, so 100 x 16 x (2 + 2..4) is about **-6000..-9000 draws**. This one change
    would take every land-walls scene under budget.
  - Triangles are unchanged.
- **Why the picture stays the same:** rigid skinning reproduces the pivot transforms exactly.
- **What could go wrong (high):**
  - The skinning path in compat. Per-frame CPU for the bone copy.
  - Equipment attached under pivots and `Unclip`/audit code that walks MeshInstances.
  - cull_small's per-part 25 m range for eyes (props.gd:585) is lost; that is a tiny triangle increase.
  - Do it last, behind a flag, on one scene first.

## 2. Expected result (rough, additive where the items do not overlap)

| scene | now draws / tris | after #1-#8 (estimate) |
|---|---|---|
| ch26 | 12850 / 12.8 M | about 6000-7000 / about 9 M |
| ch0 | 9140 / 11.7 M | about 5500-6000 / about 8.5 M |
| ch20 | 10600 / 11.0 M | about 6000-6500 / about 8 M |
| ch12b | 7170 | about 4500-5000 |
| ch10g | 7850 | about 5000-5500 |

The triangle budget (5 M) will not be met in the land-walls scenes by #1-#2 alone. The remaining triangles are the
near army (Crowd, 2.3 k per figure) and the rigs. Without reducing the picture, the next step is checking that mesh
LOD actually applies to MultiMesh in compat (U3).

## 3. What I could NOT determine from the code (UNSURE) and the single measurement that settles each

- **U1 Are outline next_pass surfaces really drawn into the shadow maps in 4.4 compat?**
  Run perf_run on ch26 once with `Props.outlines = false` (game_state.gd:1159-1163 already switches it by quality,
  so use quality 0 with the shadow cap held at 70). If shadow draws halve, #1 pays as estimated. If they do not
  change, #1 saves nothing.
- **U2 Does compat add an extra colour pass per object for the shadowed directional light?**
  Toggle `moon.shadow_enabled` in ch0 and compare the non-shadow draws. If they drop about 40-50%, then the shadowed
  moon also doubles the colour pass. That would make the moon's shadow far more expensive than the "shadow share"
  column shows, and would be worth a separate decision with the owner.
- **U3 Triangles per Crowd figure, and whether compat applies `generate_lods` LODs to MultiMesh.**
  Print `Crowd.ottoman(...).get_faces().size()/3` and, with `bisect_probe`, hide one army cell at 100 m and at 20 m
  and compare the triangle delta per instance.
- **U4 What share of ch20/ch26 draws is live rigs vs. static decoration.**
  Run `bisect_probe` hiding all Person/Soldier nodes as one group, then all MeshInstances without a Person ancestor.
  This decides between #12 and #4-#8.
- **U5 ch25: which branch is measured** (Byzantine walls night vs. Ottoman camp; `Siege.side()`, chapter25.gd:71),
  **and what causes the 13.5 k peak** (the ByzCity/Ayasofya phase?). Print RINFO per phase.
- **U6 Kit.house / Kit.roof draw count per house in Galata** (.glb multi-surface; bake_static cannot merge it).
  Count MeshInstances under one `Kit.house`.
- **U7 Does WorldWalk need the MeshInstances that #3-#5 would bake** (world_walk.gd:150-161)?
  Run the WALKTHRU test after baking. If walkable surfaces are lost, bake with `walk=true`.
- **U8 Why ch29/ch18 have about 7 M triangles with only 6% shadow.**
  The candidates are the 36 rower rigs + 20 carrack crew, the 46 shore Soldier rigs (`SeaBattle.shore`), the World1453
  horn region (`in_world = true`, sea_walls.gd:36) and the 900x600 water at 180x120 subdivisions (only 43 k
  triangles). Run `bisect_probe` on the children of `walls.world` and the galleys.
- **U9 Whether the `stages`, banner `fl` and trebuchet parts are touched by code I did not read** (chapter scripts
  using find_child on them). Grep `find_child(`/`get_node(` against names in each baked holder before merging.

## 4. Verification protocol (for every item)
1. Run `tests/perf_run.sh <scene>` before and after, and compare the RINFO draws, tris and shadow split medians on
   the same samples.
2. Run `tests/_tmp/bisect_probe.gd` on the changed builder's node (Assault, LandWalls decor holders, ByzCity houses)
   to attribute the delta.
3. Take screenshots from the same camera with the chapter shots mode and diff them. A pixel diff of 0 is expected
   for #2-#11; for #1, at most single-pixel differences at silhouettes next to transparent effects.
4. Run the CI audits (WALKTHRU, VISAUDIT insolid/overlap/sunk, hud `_ground_audit`) for the scenes touched by #4-#8
   and #10.
