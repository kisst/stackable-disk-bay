# 0008 — Accessories: 2.5" adapter, feet, joiner plates

> **Mirrored by [0010](0010-sata-connector-on-the-plus-y-side.md):** the
> 2.5" drive sits in the +y rear corner. The flexible strip is on +y and
> carries the finger pins; the rail is on −y and carries the fixed ones.

## Context

Three additions were asked for: a 2.5" variant that keeps the SATA
connector where a 3.5" drive has it; feet that lift the bottom bay for
air and join by the hex system; and joiner plates, sandwiched between
bays, in one and half sizes that interlock so 0.5 + 1 + 0.5 makes a joint
two bays long.

2.5" drives had been a non-goal in `docs/design.md`; this decision lifts
that, and the goals now name them.

## Decision

- **2.5" as an adapter**, not a second caddy or bay. It replaces a 3.5"
  drive in the caddy and takes the caddy's four pins. SFF-8323 and SFF-8223
  put the SATA connector 13.43 mm from the drive's edge and 3.5 mm up on
  both sizes. So the 2.5" drive sits in the −y rear corner on the caddy
  floor, and its connector matches the 3.5" position. The only offset is
  2.4 mm inboard: the strip that carries the fixed pins plus clearance. The
  2.5" drive hangs on three pins, two fixed on the +y rail and one on the
  flexible −y strip, which the caddy wall then backs.
- The 3.5" reference model's connector moves from a guessed 6.4 mm to the
  standard's 13.43 mm. Only the checks use it; the rear panel's open corner
  already covered both.
- **Feet** lock into three neighbouring open cells with three bump-shaped
  pins. That holds better than one bump in a socket, and a foot can go
  under any cluster of open cells.
- **Joiners** are 2.8 mm thick, twice the bump height, and honeycomb all
  over on the lattice of the bay half each zone lies against, so the bumps
  find cells and air passes. They lock with genderless dovetails: sockets
  at the mirror positions of the tabs, so pieces turn round freely. Half
  pieces lock on their centre-line edge only and end a run flush; turned
  round they serve the other half of a bay. A full piece straddles the seam
  between two bays, and two half pieces cover a single bay. A three-high
  height piece spans from one bay's centre line to the one three bays up.

## Consequences

- No change to caddy, bay or rear panel for 2.5" drives; mixed sizes share
  a stack.
- A joiner adds 2.8 mm to the pitch: 37.6 mm stacked, 115.4 mm side by
  side. Neighbouring bezels no longer meet edge to edge.
- One joiner direction per block: the joined direction's bays touch
  directly, the other is spaced 2.8 mm by the joiners.
- New checks (`check.sh acc`): fit, hold and lock for every accessory.
