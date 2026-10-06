# 0005 — Top-edge spring lock, grooved rear panel, tighter press fits

> **Partly superseded by [0009](0009-rear-panel-side-tabs-walls-first.md)**:
> the rear panel's grooves gave way to side tabs again, with the walls going
> onto the panel first. The spring lock and the clearances stand.

## Context

The first test print found four problems.

1. The rear panel was loose in the walls. Its side tab sat in a slot 2.4 mm
   taller than the tab, because the lifted-wall assembly path of 0004 needed
   that slack.
2. The caddy never clicked in. The detent bumps sat on a 45° finger whose
   outer face was recessed 0.8 mm. Only about 0.6 mm reached past the 0.4 mm
   slide clearance, and the thin finger just yielded inward. The bumps were
   also horizontal spheres on a vertical face, which print poorly.
3. The bezel tab slots, the long floor slot most of all, were too loose to
   hold without glue.
4. The rear panel's plate slots were too loose for a friction fit.

## Decision

- **Spring lock on the top edge** (proposed by the printer's owner). Each caddy
  wall has a 54 mm slit under its top rim. That frees a 2 mm beam anchored at
  both ends, under a 1.5 mm hump. A bump in the beam's middle has a 30°
  lead-in ramp at the rear, a 45° holding ramp at the front and a 1.2 mm
  crest. It rises 1.0 mm above the top plate's underside when relaxed. The
  bump runs under the plate's solid rim, outside the honeycomb, and drops
  into a slot when the caddy seats. The slot's front edge is placed so the
  holding ramp bears on it with 0.4 mm of deflection left. The spring then
  pushes the caddy down and the bezel onto the bay, so the caddy is tight as
  well as locked.
- The beam is anchored at both ends, not a cantilever. Its underside then
  prints as a bridge between two anchors; a cantilever's underside would be
  a 54 mm line extruded into air from its root. The fixed-fixed beam is also
  64 times stiffer for its length. That is why a 2 mm beam gives a useful
  preload at under 1 % strain.
- The bump prints upright on the wall's top edge, so nothing horizontal is
  left on the outside of the tray. The side detent finger and the bay wall's
  detent holes are gone.
- **Rear panel in grooves.** The walls carry a 1.2 mm deep groove on their
  inner face, open at the top edge. The panel's side edges are tongues from
  13 mm up to the top. The walls drop into the bottom plate first, then the
  panel drops in from above, then the top plate goes on. The tongue fills its
  groove with no slack, and the top plate caps it. A through-slot open at the
  top would have left a 1.3 mm prong at the wall's end; a blind groove keeps
  the wall whole.
- **Clearances.** Panel tabs in plate slots and tongues in grooves are 0.08 mm
  a side. Bezel wall tabs are 0.08 mm across their thickness, and the floor
  tab is 0.05 mm. Along a tab's length the clearance stays 0.15 mm, which
  grips nothing and leaves room for elephant foot. Wall tabs in plates keep
  0.15 mm, since the print showed no problem there.

## Consequences

- Assembly is simpler: no lifting and sliding.
- The plates carry only the two rear-panel slots each one uses: the top and
  bottom prints mirror each other, dropping 0004's two unused slots.
- Each plate has two lock slots, 3.1 × 3.4 mm, one per side. The bottom
  plate's pair is unused.
- The pin coupon shrinks to 34 mm so it stops short of the spring slit.
- Checks: the seated caddy pulled 1 mm out hits the slots (`caddy_locked`).
  The sliding caddy with the bumps pressed flat clears the bay
  (`path_caddy_slide`). The bump track from the front edge to the slot is
  solid plate (`lock_track`). The panel shifted 1 mm along the bay hits the
  walls alone (`rear_in_grooves`). The new insertion path is swept.
- The spring rate depends on the filament. At 2 mm beam depth it is about
  4 N/mm in PETG and 7 N/mm in PLA, per side. `sp_h`, `sp_lock` and
  `sp_preload` tune it. The friction clearances are a second guess at the
  printer's tolerance, worth one more print.
