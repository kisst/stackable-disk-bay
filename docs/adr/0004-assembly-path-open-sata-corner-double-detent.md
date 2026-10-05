# 0004 — A provable assembly path, an open SATA corner, two detent bumps

## Context

Three problems the model has to rule out. A closed SATA window in the rear
panel leaves a 0.5 mm strip under it and a 1.7 mm strip beside it, weaker
than no material. A single detent bump on the caddy clicks into every
honeycomb cell it crosses on the way in. And with closed slots everywhere,
the bay cannot be assembled: a wall would have to move sideways onto the
panel's tab and downward into the plate at the same time.

## Decision

- The rear panel's lower −y corner is cut away from the bottom edge and the
  side edge up to 12.5 mm. The wall tab sits at 13 to 25 mm, the plate
  tabs on the +y half (12 and 40 mm), and the plate carries both mirror
  images of the slots so it stays one part.
- The detent finger carries two bumps a lattice pitch apart along its 45°
  beam (7.8 mm in x, 7.8 mm in z); the bay wall has a hole for each. One
  bump is on a web whenever the other is over a cell.
- Assembly order is fixed as: panel into the bottom plate; walls slid in
  from the sides, lifted one plate thickness, then dropped; top plate on.
  The wall's panel slot extends one plate thickness below the tab so the
  lifted wall can take the tab sideways. Six checks sweep that path.

## Consequences

- The panel is an L; its stiffness comes from the full-height +y half and
  the top strip, which is what the plugs leave room for anyway.
- Two unused slots in each plate, 2.4 × 12.3 mm, a little more venting.
- The tab sits at the top of a slot 2.4 mm taller than itself; the plate
  tabs fix the wall's height, so the slack is harmless.
