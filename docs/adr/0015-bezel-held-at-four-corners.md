# 0015 — Bezel held at four corners; more caddy wall vents

## Context

The bezel joined the tray by one 8 mm tab low on each wall, at the finger
height, and the long floor tab. There was no recorded reason for a single
tab: it dated from the first design. Only the floor barb (ADR 0013) and
friction held the bezel on, all of it in the bottom third of the plate, so
its top could peel forward about the low tabs. The caddy walls' front 8 mm
is solid anyway, so taller or more tabs cost the tray nothing; the bezel
loses cells beside the slots.

The bay's wall joint (ADR 0014) gets its hold from two dovetail angles,
one steep and one shallow, because the wall slides in sideways along an
open notch. The bezel cannot: it goes on straight along the tabs through
closed slots, and a steep undercut there could never be passed.

Separately, the caddy walls' vent keep-outs were boxes square to the wall:
a 4 mm square each side of a fixed pin, and the bounding box of each 45°
finger. They blanked cells where there was room.

## Decision

- **Two tabs on each wall**, 8 mm tall, centred at the finger height
  (8.35 mm) and as far under the bay's top (21.65 mm), with the floor tab
  five in all. The bezel is now held at its top as well as its bottom.
- **The wall tabs' outer faces lean out 4°** toward the bezel's face,
  0.14 mm over its 2 mm, and the slots fit that face with no clearance
  (0.08 mm stays on the inner face). Pressing on, the bezel snaps over the
  slope as the wall flexes in, and is then locked on at four corners as
  well as by the floor barb. It is the shallow, snapping angle of the bay
  joint; there is no room for the steep one.
- **Caddy wall vents**: the keep-out round a fixed pin is the pin plus the
  1.5 mm web margin, and round a finger its slot ring and recess plus the
  margin, slanted with the beam. Honeycomb keep-outs can now be slanted
  rectangles (`hits_keep` in `scad/lib.scad`).

## Alternatives

- **A bay-style double dovetail** with the bezel slid on sideways or down.
  Sideways, one slot's entry would have to lie outboard of its wall, in
  the bezel's 2.8 mm side rim; down, the floor tab's closed slot and the
  pull ledge's barb would have to change too, and the bezel would need
  something else to keep it from sliding back up out of the bay.
- **Taller plain tabs.** Hold at the top, but by friction only, which
  ADR 0005 and 0014 found unreliable.
- **A slope on both faces of each tab.** The tab would have to squeeze
  through the slot; with one face sloped the wall flexes instead.

## Consequences

- Two cells lost at the top of each side of the bezel; four more cells in
  the fixed-pin wall, two above each pin, and one more beside each finger.
- The lower wall tabs sit where the wall is stiffest; whether they snap by
  hand is for the next print, `bz_tab_splay` the parameter.
- Taking the bezel off means pushing the wall tabs in from outside as well
  as lifting the bottom slot over the barb.
- Checks: `bezel_tabs_locked`, the bezel slid 1 mm forward cuts into the
  wall tabs alone, and fails with `bz_tab_splay` at 0. `check.sh` and
  `thin.sh` now also fail when OpenSCAD reports an undefined value: a
  forward reference left the new tabs undefined, and the bezel checks
  passed without them.
