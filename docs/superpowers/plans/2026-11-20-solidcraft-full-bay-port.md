# SolidCraft Full-Fidelity Bay Port — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reproduce the entire assembled stackable disk bay — every printed part plus the reference drive — natively in SolidCraft's `.sc`/JSON command format at full fidelity, assembled into one unit.

**Architecture:** A Python generator (`solidcraft/gen_full.py`) emits one SolidCraft JSON command script per part. Each part is one `component`; geometry is built from `solid.box` primitives, `sketch.*` profiles (for arcs/fillets/polygons the box approach can't express), `solid.extrude` (join/cut), and the honeycomb hex-cell routine proven in the two-part prototype. Parts are placed into the assembled frame with `solid.move` using the exact transforms from `scad/bay.scad` and `scad/caddy.scad`. Every ported part is verified geometrically against the OpenSCAD original rendered to STL (the oracle).

**Tech Stack:** SolidCraft `solidcraft-cli` (flatpak `io.tangencylabs.solidcraft`), Python 3 (stdlib only) for generation, Docker `openscad/openscad:2021.01` for the oracle STLs, `admesh`/numpy-free volume math for comparison.

**Spec:** The OpenSCAD source is the spec. Primary files: `scad/params.scad` (all dimensions), `scad/lib.scad` (honeycomb, bumps, pins), `scad/bay.scad` (plates, walls, rear, assembly transforms), `scad/caddy.scad` (tray, bezel, fingers, springs, posts, push tab), `scad/hdd.scad` (3.5" drive + SATA tongue), `scad/accessories.scad` (2.5" adapter — out of scope unless drive=25). This plan targets the `drive="35"`, `part=""` configuration of `scad/assembled.scad`.

## Global Constraints

- All dimensions come from `scad/params.scad` verbatim — never re-derive or round. The generator imports them as literals/expressions matching the OpenSCAD names.
- Shared coordinate frame (from `params.scad`): x = rear→front (connector face at x=0), y = width centred on 0, z = 0 at caddy-floor underside / bay-floor top. Units mm.
- Honeycomb lattice: `hex_cell=6.0`, `hex_web=1.8`, pitch `hex_dx=7.8`, row pitch `hex_dy=hex_dx*√3/2`. Cells are whole-only, staggered (odd rows shifted `hex_dx/2`), rotated 30°, with keep-out rects around every slot/tab/bump/hole exactly as `lib.scad:hits_keep` computes. Phase per part so cells line up when assembled (`plate_cell`/`wall_cell`/caddy phase offsets in `params.scad`).
- **Honeycomb is emitted as PATTERNS, not per-cell cuts** (verified: `sketch.pattern.rectangular` on one inscribed hex `l1..l6`, then one `solid.extrude cut`, does 77 cells in 708 ms and a 190 KB `.sc` — vs ~26 MB and multi-minute for per-cell). Per field: draw ONE hex, pattern it for the EVEN rows (`spacing=hex_dx`, `spacing2=2*hex_dy`), one cut; a SECOND sketch+pattern for the ODD rows offset `hex_dx/2` in x and `hex_dy` in y, one cut. The pattern is clipped to the field rectangle by the base slab's extent. **Keep-outs:** the uniform pattern cannot skip cells, so after cutting the full staggered grid, `join` a solid box over each keep-out rect (≈10/part) to plug the holes that would hit a slot/tab/bump. Net: ~4 features/field instead of ~208. Verify the resulting open-cell set equals `lib.scad`'s `hex_holes(...)` set (same centers present, keep-out centers absent).
- Clearances are real and must be preserved: `tab_clr=0.15`, `rear_fit_clr=0.08`, `slide_clr=0.4`, `clr=0.3`, bezel `bz_tab_clr`/`bz_floor_clr`/`bz_end_clr`, spring `sp_*`.
- Each part is its own SolidCraft `component`, named as in the oracle (`plate_top`, `plate_bottom`, `wall_l`, `wall_r`, `rear`, `tray`, `bezel`, `hdd`).
- Flatpak sandbox: `solidcraft-cli` only sees paths passed via `--filesystem=`. All generated/oracle files live under `solidcraft/` in the repo (already granted via Flatseal).
- `.sc` files are large (~26 MB for one honeycomb part). Do not commit them without the user's say-so; the generator + JSON scripts are the source of truth.

## Review Focus

Inputs/conditions the spec implies but that per-part volume checks won't catch, most likely to bite first:

- **Joint interference across parts.** A part can match its own volume yet collide with its neighbour when placed. Every assembly task runs `inspect.interference` on the newly-placed part against all seated parts; expected `count: 0` (press-fit tabs sit in slot voids, touching, zero solid overlap). Covered in Tasks 8–11.
- **Honeycomb cell count / keep-out correctness.** A wrong phase or keep-out silently shifts vents onto a slot or bump. Each honeycomb task asserts the emitted cell count equals the OpenSCAD cell count for that field (extracted from the oracle) and that no cell center falls inside a keep-out rect. Covered per flat-part task.
- **Spring finger / cantilever printability (45° overhangs).** The diagonal fingers and spring humps must keep their overhang geometry or they're not the same part. Task 6 verifies the finger beam angle and slot clearance against `finger_angle`/`finger_gap` and checks bounding box vs oracle.
- **SATA pocket & tongue placement.** The drive's connector must land at the spec'd y/z or the rear-panel notch won't clear it. Task 7 verifies the tongue's outer edge at `sata_y0` and pocket depth `sata_pocket_d` against the oracle bbox of the connector region.
- **Mirror/turn symmetry of shared parts.** `wall_r` is `wall_l` turned end-for-end; `plate_bottom` is `plate_top` turned over. A bad transform makes bumps land on pads instead of open cells. Tasks 8–9 verify the turned part's bump centers fall in the neighbour's open cells (the whole point of the no-extra-part joining scheme).

---

## Task 0: Oracle harness + generator skeleton

**Files:**
- Create: `solidcraft/oracle.sh` (render one OpenSCAD part to STL + print volume/bbox)
- Create: `solidcraft/gen_full.py` (shared params + emit helpers; proven honeycomb routine lifted from the prototype `gen.py`)
- Create: `solidcraft/verify.py` (compare a SolidCraft `eval` result's volume/bbox to an oracle STL's, within tolerance)

**Interfaces:**
- Produces: `oracle.sh <part> <drive>` → writes `solidcraft/oracle/<part>.stl` and prints `{volume_mm3, bbox:[x0,y0,z0,x1,y1,z1]}`.
- Produces: `gen_full.py` exposes `emit_hex(cx,cy,r,z0,dist,op,targets)` (single hex, for bumps), `emit_honeycomb_patterned(size,keep,cx_off,cy_off,z0,t,phase)` (two staggered `sketch.pattern.rectangular` cuts + keep-out plug boxes — the primary honeycomb emitter), `hex_cells(...)` (reference cell set, for verification only), all the `params.scad` constants, and `add(cmd,params)`.
- Produces: `verify.py <sc_or_json> <part_name> <oracle_stl>` → exits 0 and prints `MATCH vol Δ=… bbox Δ=…` when within tolerance (volume ±2%, bbox ±0.2 mm), else exits 1.

- [ ] **Step 1: Write `oracle.sh`** — `docker run --rm -v "$PWD":/work -w /work openscad/openscad:2021.01 openscad -D 'part="<p>"' -D 'drive="<d>"' -o solidcraft/oracle/<p>.stl scad/assembled.scad`, then compute volume (signed-tetrahedron sum over STL triangles) and bbox via a small inline `python3 -I`.
- [ ] **Step 2: Render the oracle for `plate_bottom`** and record volume+bbox. Expected: a watertight STL, volume > 0.
- [ ] **Step 3: Write `emit_honeycomb_patterned`** — compute the field's even/odd row+column counts from `size` and the pitches; emit two `sketch.pattern.rectangular` cuts (even rows, then odd rows offset `hex_dx/2`,`hex_dy`); then emit a `join` plug box over each keep-out rect. The single-hex `emit_hex` (for bumps) ports from the prototype `gen.py` unchanged. Verify on `plate_bottom`: the open-cell set equals `hex_cells(...)` and the `.sc` is < 1 MB.
- [ ] **Step 4: Write `verify.py`** — load the SolidCraft `--results`/`eval` JSON for a body, compare `volume_mm3` and bbox to the oracle's within tolerance.
- [ ] **Step 5: Commit** `solidcraft/oracle.sh solidcraft/gen_full.py solidcraft/verify.py` — "Add SolidCraft port oracle + generator skeleton".

## Task 1: `plate_top` (and parametric `plate_bottom`)

**Files:** Modify `solidcraft/gen_full.py` (plate emitter).

**Interfaces:**
- Consumes: Task 0 helpers.
- Produces: `emit_plate(kind)` → emits a plate component (`kind` ∈ {"top","bottom"}) with wall-tab slots (`tab_x` × both rails), rear-panel slots (`rear_slot_y(kind)`), caddy-lock slots (top only), honeycomb (phase `[b_xc,0]`), and joining bumps (`plate_bumps`). Bottom plate built flipped (z∈[−b_t,0], bumps −z) per the prototype fix.

- [ ] **Step 1:** Emit `plate_top`: base box `b_x0..b_l × ±b_w/2 × 0..b_t`; cut 6 wall slots, 4 rear slots (`rear_tab_y_top`), 2 caddy-lock slots (`sp_hole_x`×`sp_hole_y`); honeycomb with all four keep-out families from `bay.scad:plate`; add `plate_bumps` on +z.
- [ ] **Step 2:** Render oracle `plate_top`; run `verify.py`. Expected: MATCH (vol ±2%, bbox ±0.2).
- [ ] **Step 3:** Assert emitted honeycomb cell count == oracle cell count (count closed vent loops in the STL via Euler characteristic, or compare to a cell-count printed by the generator against a reference value recorded here on first green run).
- [ ] **Step 4:** Emit `plate_bottom` via the same function with `kind="bottom"` (2 mirrored rear slots, no caddy slots, flipped). Render oracle `plate_bottom`; verify MATCH.
- [ ] **Step 5: Commit** — "Port bay plate (top + bottom) to SolidCraft".

## Task 2: `wall_l` (and parametric `wall_r`)

**Files:** Modify `solidcraft/gen_full.py` (wall emitter).

**Interfaces:**
- Consumes: Task 0 helpers.
- Produces: `emit_wall()` → wall component: base `b_x0..b_l × 0..b_in_h × 0..b_wall`, 6 tabs (`tab_x` × {−b_t, b_in_h}), rear-panel side-tab slots at both `wall_slot_x`, orientation groove, honeycomb (phase `[b_xc, b_in_h/2]`), `wall_bumps` on +z.

- [ ] **Step 1:** Emit the wall flat (own frame). Include the groove as a shallow cut on the outer face, and both `wall_slot_x` slots (end-symmetry).
- [ ] **Step 2:** Render oracle `wall_l`; `verify.py`. Expected MATCH.
- [ ] **Step 3:** Verify bump centers (`wall_bumps`) fall in open cells and the groove depth == `groove_d`.
- [ ] **Step 4: Commit** — "Port bay wall to SolidCraft".

## Task 3: `rear` panel

**Files:** Modify `solidcraft/gen_full.py` (rear emitter).

**Interfaces:**
- Produces: `emit_rear()` → rear panel in its own frame (x across the bay centred, y = height 0..b_in_h, z 0..rear_t): body `±(b_in_w/2−rear_clr)`, tabs on all four edges (`rear_tab_y_top`/`_bot` into plates, side tabs at `rear_tab_z` into walls), SATA notch (open at bottom + +y edge, to `sata_notch_y`/`sata_notch_z`), orientation groove, exhaust honeycomb with the notch keep-out.

- [ ] **Step 1:** Emit the rear panel with all tabs, the SATA notch (box cut open at two edges), groove, and honeycomb.
- [ ] **Step 2:** Render oracle `rear`; `verify.py`. Expected MATCH.
- [ ] **Step 3:** Verify the SATA notch bbox matches `sata_notch_y`/`sata_notch_z` exactly.
- [ ] **Step 4: Commit** — "Port rear panel to SolidCraft".

## Task 4: `bezel` (flat plate, notch, lip, intake)

**Files:** Modify `solidcraft/gen_full.py` (bezel emitter).

**Interfaces:**
- Produces: `emit_bezel()` → bezel component: flat plate `c_body_l..+bezel_t × ±b_w/2 × b_z0..b_z1`; tab slots (`bezel_slots`); finger notch (trapezoid, rounded bottom corners `bz_pull_r`, eased mouth `bz_pull_f`) via a **sketch** (arcs); intake honeycomb with `notch_keep`; the back-face lip (`bezel_lip`, chamfered rear-top edge) via a sketch.

- [ ] **Step 1:** Emit the plate + tab slots (boxes). 
- [ ] **Step 2:** Add the finger notch as a sketched profile (lines + fillet arcs at `bz_pull_r`, mouth ease `bz_pull_f`), cut through `bezel_t`. Verify the notch outline against `finger_notch2d` corner coordinates.
- [ ] **Step 3:** Add the lip as a sketched profile (chamfer `bz_lip_c`) extruded over `bz_lip_w`, joined.
- [ ] **Step 4:** Add the intake honeycomb with `notch_keep` + tab-zone keep-outs.
- [ ] **Step 5:** Render oracle `bezel`; `verify.py`. Expected MATCH.
- [ ] **Step 6: Commit** — "Port bezel to SolidCraft".

## Task 5: `tray` — floor, walls, posts, pins, bezel-tabs, push-tab (no fingers/springs yet)

**Files:** Modify `solidcraft/gen_full.py` (tray base emitter).

**Interfaces:**
- Produces: `emit_tray_base()` → tray component minus the cantilever fingers and spring lock: honeycomb floor (phase to plate lattice), both solid walls (`wall_solid`) with raised front posts (`wall_post2d`, 45° rear ramp), fixed pins (−y wall) + finger pins (+y wall) as cones, bezel tabs (wall + floor), push tab (rib + fillet + rounded plan).

- [ ] **Step 1:** Emit the honeycomb floor (box minus honeycomb, phase `[b_xc−fc,0]`).
- [ ] **Step 2:** Emit both walls with the raised front post profile (sketch: the 5-point `wall_post2d` polygon with the 45° ramp).
- [ ] **Step 3:** Emit pins (cylinders + conical tips) at `hdd_side_hole_x` (−y, +y rails) and the push tab (sketched rib profile with `push_fillet`/`push_nose` fillets, rounded plan via `push_r`).
- [ ] **Step 4:** Emit bezel tabs (boxes). Render oracle with a **fingers/springs-suppressed variant**? No — oracle has them. Instead verify bbox + wall/floor/post volumes against hand-computed sub-volumes recorded here (fingers/springs added in Task 6 before the full-tray verify).
- [ ] **Step 5: Commit** — "Port caddy tray base (floor, walls, posts, pins, tabs) to SolidCraft".

## Task 6: `tray` — diagonal cantilever fingers + top-edge spring lock

**Files:** Modify `solidcraft/gen_full.py` (finger + spring emitters).

**Interfaces:**
- Consumes: Task 5 tray base.
- Produces: `emit_fingers()` (through-slot `finger_slot2d` + outer-face recess `finger_beam2d`, both sketched profiles extruded through the +y wall; service holes `service_hole2d`) and `emit_spring_lock()` (hump+bump profile `spring_profile2d` with fillets `sp_fillet_r`/`sp_crest_r`, slit `spring_slit2d`, both walls).

- [ ] **Step 1:** Emit the finger slots as sketched profiles (the offset-ring `finger_slot2d`: beam grown by `finger_gap`, minus beam, clipped at root) extruded through the wall at `finger_angle`.
- [ ] **Step 2:** Emit the beam outer-face recess (`finger_beam2d`, flat-cut lowest corner `finger_tip_flat`) so the beam flexes at `finger_t`.
- [ ] **Step 3:** Emit the service holes (`service_hole2d`: hex cell + two triangles to the slot edges + wedge-tip flats). Assert `service_cell` clears the finger (the `assert` in `caddy.scad`).
- [ ] **Step 4:** Emit the spring lock: slit (rounded-end `hull` → sketch with two arcs), hump+bump profile (sketch with `sp_fillet_r`/`sp_crest_r`/`sp_hump_r` fillet arcs) on both walls.
- [ ] **Step 5:** Render oracle `tray`; `verify.py` against the **full tray** now. Expected MATCH (vol ±2%, bbox ±0.2).
- [ ] **Step 6:** Verify finger beam angle == `finger_angle` and slot gap == `finger_gap` from the ported geometry.
- [ ] **Step 7: Commit** — "Port caddy fingers + spring lock to SolidCraft".

## Task 7: `hdd` — 3.5" reference drive + SATA tongue

**Files:** Modify `solidcraft/gen_full.py` (drive emitter).

**Interfaces:**
- Produces: `emit_hdd()` → drive component: rounded-rect body (`hdd_r`) with raised inset lid (`hdd_lid`/`hdd_lid_in`), side + bottom tapped holes (`hdd_hole_minor_d`), connector pocket (`connector_pocket`), L-shaped SATA tongue (signal + power blades, keying feet) at `sata_y0`.

- [ ] **Step 1:** Emit the body as two stacked rounded-rect extrudes (sketch: `rounded_rect` via `sketch.polygon`/arcs or a filleted rectangle) — base to `hdd_h−hdd_lid`, inset lid to `hdd_h`.
- [ ] **Step 2:** Cut side holes (6, horizontal cylinders), bottom holes (6, vertical), connector pocket (box).
- [ ] **Step 3:** Emit the SATA tongue: signal blade + power blade + two keying feet (boxes) at `sata_y0`, `sata_z0`.
- [ ] **Step 4:** Render oracle `hdd`; `verify.py`. Expected MATCH.
- [ ] **Step 5:** Verify the tongue outer edge sits at `sata_y0` and pocket depth == `sata_pocket_d`.
- [ ] **Step 6: Commit** — "Port 3.5\" reference drive to SolidCraft".

## Task 8: Assembly — plates + walls (the bay shell)

**Files:** Create `solidcraft/assemble_full.py` (or an assembly section in `gen_full.py`) that imports all part emitters and places them.

**Interfaces:**
- Consumes: Tasks 1–2 emitters.
- Produces: the bay-shell assembly: `plate_bottom` flipped (z∈[−b_t,0]), `plate_top` at +b_in_h, `wall_l` (`translate([0,−b_in_w/2,0]) rotate([90,0,0])`), `wall_r` (same part, `rotate([0,0,180]) rotate([90,0,0])`, translated to +y).

- [ ] **Step 1:** Place both plates and both walls using the exact `bay.scad` transforms.
- [ ] **Step 2:** `inspect.interference` on {plate_top, plate_bottom, wall_l, wall_r}. Expected `count: 0`.
- [ ] **Step 3:** Verify `wall_r` bump centers land in `wall_l`'s open cells (and plate bumps in open cells of the opposite plate) — the no-extra-part joining invariant.
- [ ] **Step 4:** Snapshot iso + top; visually confirm tabs seated.
- [ ] **Step 5: Commit** — "Assemble bay shell (plates + walls) in SolidCraft".

## Task 9: Assembly — rear panel into the shell

**Files:** Modify `solidcraft/assemble_full.py`.

- [ ] **Step 1:** Place `rear` via `translate([rear_x,0,0]) rotate([90,0,90])`.
- [ ] **Step 2:** `inspect.interference` on rear vs {plates, walls}. Expected `count: 0` (rear tabs in plate + wall slot voids).
- [ ] **Step 3:** Verify the SATA notch clears the drive connector region (no overlap with the `hdd` tongue bbox once the drive is placed in Task 11).
- [ ] **Step 4: Commit** — "Seat rear panel in SolidCraft assembly".

## Task 10: Assembly — caddy (tray + bezel) seated in the bay

**Files:** Modify `solidcraft/assemble_full.py`.

- [ ] **Step 1:** Place `tray` (shared frame already; spring bumps drawn at `sp_preload` deflection for the seated view — emit a seated variant) and `bezel` (shared frame).
- [ ] **Step 2:** `inspect.interference` tray vs bay shell. Expected: spring bumps touch the top-plate lock slots (near-zero), fingers clear. Record any intentional preload contact.
- [ ] **Step 3:** Verify bezel tabs seat in tray slots (`inspect.interference` bezel vs tray → `count: 0`).
- [ ] **Step 4: Commit** — "Seat caddy (tray + bezel) in SolidCraft assembly".

## Task 11: Assembly — drive in the caddy + whole-bay verification

**Files:** Modify `solidcraft/assemble_full.py`.

- [ ] **Step 1:** Place `hdd` (connector at x=0, bottom on caddy floor — shared frame, no transform).
- [ ] **Step 2:** Verify drive pins engage: `hdd` side holes align with tray pins (`hdd_side_hole_x`, `pin_z`); the tongue enters the rear-panel SATA notch.
- [ ] **Step 3:** Whole-assembly `inspect.interference` on all parts. Expected: only the intended press-fit/preload contacts; no gross overlaps. Record the full report.
- [ ] **Step 4:** Save `solidcraft/bay_full.sc`, export `solidcraft/bay_full.step`, render iso/top/front/section snapshots.
- [ ] **Step 5:** Compare whole-assembly bbox to the oracle `assembled.scad` (part="") bbox. Expected: within ±0.3 mm.
- [ ] **Step 6: Commit** — "Assemble full bay (all parts + drive) in SolidCraft".

---

## Notes for the executor

- **Renders are slow** (each honeycomb part re-tessellates ~250 cells; a full-assembly snapshot can exceed 2 min). Run renders/`eval`/`interference` in the background and wait for completion rather than polling.
- **Flatpak paths:** always pass `--filesystem=<abs dir>` to `solidcraft-cli`, or rely on the Flatseal grant for `~/git/kisst/stackable-disk-bay`.
- **Oracle is truth:** when a ported part's volume/bbox disagrees with the OpenSCAD STL beyond tolerance, the port is wrong — fix the generator, don't loosen the tolerance.
- **`.sc` size:** honeycomb parts produce ~26 MB `.sc` files. Keep the generator + JSON as the committed source; treat `.sc`/`.step` as build artifacts (gitignore unless the user wants them tracked).
- **Sketch features** (fingers, springs, notch, lip, rounded-rect, tongue feet) are where fidelity is hardest — verify each against the OpenSCAD 2D profile's exact coordinates before extruding.
