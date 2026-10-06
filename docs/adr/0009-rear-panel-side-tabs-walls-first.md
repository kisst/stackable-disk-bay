# 0009 — Rear panel side tabs back; walls onto the panel first

## Context

ADR 0005 replaced the rear panel's side tabs with tongues in blind grooves
on the walls' inner faces, so the panel could drop in last with no slack.
From the outside the panel then showed no join to the walls at all, which
the owner did not want: the side tabs of v0.1.0 should stay, with only the
loose slot fixed. v0.1.0's slot was loose because the panel went into the
bottom plate first and each wall was slid onto its tab while lifted one
plate thickness, so the slot had to be 2.4 mm taller than the tab.

## Decision

- The panel has a tab on each side edge again, 12 mm long at 13 to 25 mm,
  through a slot in each wall, as in v0.1.0. The slot fits the tab at
  0.08 mm a side, like the panel's other slots. The grooves are gone.
- New assembly order: slide the walls sideways onto the panel's side tabs,
  with no plate yet; lower that U into the bottom plate, where all five
  bottom tabs drop in together; then the top plate. Each slot sees one
  direction of travel only, so none needs extra length.

## Consequences

- The panel joins every neighbour by tabs: four into the top plate, two
  into the bottom plate, one into each wall.
- The U is loose at the front until it is in the bottom plate; hold the
  walls while lowering it.
- Checks: a wall approaching the panel sideways, the U half-way down into
  the bottom plate, and the top plate half-way down clear everything; the
  panel shifted 1 mm hits the walls alone (`rear_in_walls`).
