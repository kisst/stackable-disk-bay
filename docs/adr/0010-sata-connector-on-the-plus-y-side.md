# 0010 — SATA connector on the +y side

## Context

The reference drive put the SATA connector at the −y edge: on the right,
seen from behind with the label up. SFF-8323 and SFF-8223 give the
connector's distance from "the drive's edge" (13.43 mm) but the model
guessed which edge. A real drive showed the connector on the other side,
at the left. Everything built around the connector was mirrored: the
rear panel's open corner would have been on the wrong side and the plugs
would have hit the panel.

## Decision

- The connector sits at the +y edge, 13.43 mm in; its segments run toward
  −y, data plug outermost. `sata_y0` is +37.37. The drive models draw the
  tongue and its pocket in a frame mirrored onto that edge
  (`at_connector()` in `scad/hdd.scad`); the cable plugs follow.
- Everything that follows the connector is mirrored with it, about y = 0:
  - the rear panel's open corner is now the lower +y corner, and its two
    bottom tabs sit on the −y half (−40 and −12 mm);
  - so the bottom plate's two rear-panel slots move to the other side.
    The top plate's four slots are symmetric and unchanged;
  - the caddy's push tab is at the tray's rear +y corner;
  - the 2.5" adapter: the drive sits in the +y rear corner, the flexible
    strip on +y carries the finger pins, the rail on −y the fixed ones.
- The fixed pins stay on −y and the fingers on +y. The connector does not
  care which wall flexes, and moving the fingers would touch every part of
  the caddy for nothing.

## Consequences

- Rear panel, bottom plate, caddy tray and adapter must be reprinted;
  top plate, walls, bezel, feet and joiners are unchanged.
- The adapter's strip now sits against the finger wall. Its pin, 14 mm
  from the rear, is backed by solid wall ahead of the first finger's slot,
  and the finger pins go through the strip as they went through the rail.
  The adapter goes in rail side first onto the fixed pins, strip side
  pressed down past the fingers.
- Seen from behind, the open corner, the plugs and the push tab are all at
  the bottom left.
