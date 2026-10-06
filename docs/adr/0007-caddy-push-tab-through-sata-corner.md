# 0007 — Push tab through the rear panel's SATA corner

> **Mirrored by [0010](0010-sata-connector-on-the-plus-y-side.md):** the
> push tab is on the tray's rear +y corner, following the open corner.
> Otherwise unchanged.

## Context

The caddy comes out by pulling on the bezel, which loads the bezel's tab
joint, a friction fit. If the joint is loose or the notch grip is not
enough, there was no other way to get the caddy out.

## Decision

- The tray's rear −y corner reaches back through the rear panel's open SATA
  corner and ends 5 mm behind the bay's rear face, as a tab to push the
  caddy out from behind.
- It is a floor-level plate, 10 mm wide and 2 mm thick, which passes under
  the SATA plugs, whose housings start 2.4 mm above the floor's underside.
  A 6 mm rib in line with the side wall stiffens it. The rib sweeps up into
  the wall's rear edge on an 8 mm fillet. Both rear corners are rounded in
  plan, and so is the rib's top edge.

## Consequences

- The tray grows 13 mm toward the rear, to 159.5 mm overall, still on a
  220 mm bed and still printing flat with no support.
- The tab sits beside the plugs, so cables must leave room for a finger at
  that corner.
- Checks: the tab clears the mated plugs (`plugs_vs_caddy`). Everything on
  the tray that ends up behind the panel passes through its open corner on
  the way in (`path_caddy_past_panel`).
