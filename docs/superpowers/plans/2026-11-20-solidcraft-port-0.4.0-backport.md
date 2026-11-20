# SolidCraft Port — Backport to v0.4.0

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use `- [ ]`.

**Goal:** Update the existing SolidCraft port (currently reproducing OpenSCAD v0.2.0) to match the current source at **v0.4.0** (origin/main `a6c2813`), so the SolidCraft model is faithful to the live design again.

**Context:** The branch `solidcraft-port` was built against v0.2.0, then rebased onto v0.4.0. The generator infrastructure (`gen_full.py` honeycomb-pattern emitter, `assemble_full.py`, `oracle.sh`, `verify.py`, `probe.py`, `check_bumps.py`) all carries over unchanged. Only the per-part geometry that v0.3.0/v0.4.0 changed needs re-porting. The oracle is now v0.4.0 (`scad/assembled.scad` on this branch).

**Spec:** The current `scad/*.scad` (v0.4.0) on this branch. Authority: `scad/params.scad`, `scad/bay.scad`, `scad/caddy.scad`, `scad/bezel.scad`, `scad/lib.scad` (now has `relief_rod`/corner reliefs and slanted keep-outs), plus ADRs 0013–0017 and release notes v0.3.0/v0.4.0 for the *why*.

## Global Constraints
- Same as the original port: dims verbatim from `scad/params.scad` (v0.4.0 values now); honeycomb patterned + hex plugs; parts built in assembled position (R4); feature cuts after honeycomb plugs (R9); keep-out cells plugged with exact hexes (R2); verify geometric vs the v0.4.0 oracle (vol ±2%, bbox ±0.2mm) + probe.py + interference; commits single-line atomic, NO attribution.
- **First: update `gen_full.py`'s hand-copied param block to v0.4.0 values** (tab_len 14→22, new tab_x/tab_flare/tab_splay/tab_reach/tab_clr/tab_fit_clr/relief_r, bezel bz_rim/bz_tab_splay/bz_tab_z and removal of bz_pull_*, spring sp_lock 1.0→1.25/sp_gap derived, push_* changes, new pull_* ledge block). This is the root of every part change.
- `lib.scad` gained `relief_rod` (corner-relief rods) and slanted keep-out rects (`hits_slant`, 7-element keep entries). The honeycomb emitter may need to handle slanted keep-outs if any ported part uses them.

## Review Focus
- **Dovetail tab geometry (walls + plate notches).** 4 tabs with flare (15°) + splay (1.5°), tab_clr=0 on dovetail faces. A wrong flare/splay direction makes the joint not lock or not assemble. Each wall/plate task probes the tab/notch region and checks the dovetail angles from the emitted vertices.
- **Corner reliefs.** `relief_r` T-bone pockets at inside corners — small but they affect fit; a missing relief passes volume but changes the joint. Verify present where `bay.scad`/`caddy.scad` place them.
- **Bezel reconception.** Finger notch GONE; honeycomb plate held at 4 corners (bz_tab_z). Don't carry over the old notch. Verify the 4-corner tab pattern + honeycomb + resized lip.
- **Pull ledge (tray).** New feature (pull_* params): barb/ramp/grip-slot/taper. A sketched profile like the old push-tab. Verify it's present and the barb snaps (geometry, not just volume).
- **Spring lock softening.** sp_lock 1.0→1.25, sp_gap derived, sp_bump_h changed. The tray's spring must match the new crest height (31.25 relaxed).

---

## Task 1: Update params + re-port the PLATES to v0.4.0
**Files:** solidcraft/gen_full.py (param block + emit_plate).
- [ ] Update the whole hand-copied param block in gen_full.py to v0.4.0 (diff `git diff e018310..a6c2813 -- scad/params.scad`). This unblocks all later tasks.
- [ ] Update emit_plate for the v0.4.0 wall-tab NOTCHES: 4 tabs at tab_x=[b_xc∓60, b_xc∓27], dovetailed (the plate's notch is open at its edge — a box corner — each tab end dovetailed on both free axes). Add corner reliefs (relief_r) where bay.scad:plate places them. Lock-slot x moved — use the v0.4.0 sp_hole_x.
- [ ] Oracle `plate_top`/`plate_bottom` (v0.4.0), verify.py MATCH + probe.py. Probe the tab-notch + relief regions.
- [ ] Commit.

## Task 2: Re-port the WALLS to v0.4.0 (4 dovetail tabs + reliefs)
**Files:** solidcraft/gen_full.py (emit_wall).
- [ ] Rewrite emit_wall's tabs: 4 tabs (tab_x), each flared (tab_flare 15° — wider toward plate outer face) + splayed (tab_splay 1.5° — wider toward wall inner face), tab_reach past tab_len/2, tab_clr=0 on dovetail faces, tab_fit_clr across thickness. Add corner reliefs.
- [ ] Oracle `wall_l`/`wall_r` (v0.4.0), verify + probe. Confirm dovetail flare/splay angles from emitted vertices (the structural fit — a reviewer check).
- [ ] Commit.

## Task 3: Re-port the REAR panel to v0.4.0 (light — check the delta)
**Files:** solidcraft/gen_full.py (emit_rear).
- [ ] Diff `git diff e018310..a6c2813 -- scad/bay.scad` for rear() changes (corner reliefs? tab changes?). Apply whatever changed; if rear() is unchanged, just re-verify against the v0.4.0 oracle.
- [ ] Oracle `rear`, verify + probe.
- [ ] Commit.

## Task 4: Re-port the BEZEL to v0.4.0 (notch removed → honeycomb + 4-corner tabs)
**Files:** solidcraft/gen_full.py (emit_bezel).
- [ ] REMOVE the finger-notch entirely. Build the v0.4.0 bezel: honeycomb plate with bz_rim solid rim; wall tabs now 2 per wall at bz_tab_z=[pin_z, b_in_h-pin_z] (held at 4 corners), splayed (bz_tab_splay 4°); floor tab; resized lip (bz_lip_w=10). Follow bezel() in scad/bezel.scad + caddy.scad (v0.4.0).
- [ ] Oracle `bezel`, verify + probe. Confirm no notch, 4-corner tab pattern, honeycomb present.
- [ ] Commit.

## Task 5: Re-port the TRAY to v0.4.0 (pull ledge, push-tab tongue, softened spring)
**Files:** solidcraft/gen_full.py (tray emitters).
- [ ] Update the spring lock for sp_lock 1.25 / derived sp_gap / new sp_bump_h (crest 31.25 relaxed, still 30.0 sliding; preloaded z per oracle).
- [ ] Replace the push-tab: v0.4.0 is a centred floor-level TONGUE (push_x1=b_x0-2, push_y0, push_w, push_r, push_root_r, push_nose 1.5), not the old rib.
- [ ] ADD the PULL LEDGE (new pull_* block): the floor tab's middle runs past the bezel face as a ledge with a barb (pull_barb 0.4 on a pull_ramp), a grip slot (pull_hole, chamfered), taper (pull_taper/pull_w), fillets (pull_r/pull_root_r). Sketched profiles like the push-tab. See the pull-ledge module in caddy.scad (v0.4.0).
- [ ] Keep fingers/service-holes/floor/walls/posts/pins as-is unless the v0.4.0 caddy.scad changed them (diff `git diff e018310..a6c2813 -- scad/caddy.scad` — check wall splay/corner reliefs too).
- [ ] Oracle `tray` (v0.4.0, caddy_tray(spring_defl=sp_preload)), verify + probe. Probe spring region + pull-ledge + push-tongue.
- [ ] Commit.

## Task 6: Re-verify the DRIVE + re-assemble the whole bay
**Files:** solidcraft/gen_full.py (emit_hdd — likely unchanged), assemble_full.py, solidcraft/VERIFICATION.md.
- [ ] Diff `git diff e018310..a6c2813 -- scad/hdd.scad scad/params.scad` for hdd/SATA changes (likely none — drive is SFF spec). Re-verify emit_hdd vs v0.4.0 oracle `hdd`; fix only if changed.
- [ ] Re-run assemble_full.py with all updated parts → whole-assembly inspect.interference (expect count:0), bump invariant, bbox vs v0.4.0 oracle part="". Re-export bay_full.sc/.step, re-render.
- [ ] Update solidcraft/VERIFICATION.md with the v0.4.0 numbers and note "port tracks v0.4.0 (a6c2813)".
- [ ] Commit.

## Notes for the executor
- Renders/interference slow — background, wait, don't poll.
- Flatpak: pass --filesystem for solidcraft/ (repo granted via Flatseal).
- The v0.4.0 oracle is the current scad/ on this branch: `bash solidcraft/oracle.sh <part> 35`.
- Build artifacts (.sc, per-part .json) are gitignored (R16) — may need `rm` before a rebase/regen; they regenerate from the .py.
- Carry forward all original rulings R2/R4/R9/R13 (they still hold).
