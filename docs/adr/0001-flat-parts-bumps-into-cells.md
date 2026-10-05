# 0001 — Bay is five flat parts; bays join by bumps in the neighbour's honeycomb

## Context

Bays must sit on top of and beside each other, every bay identical, every
part printed flat with no supports, and come apart again by hand. A stack
only has to stay put: the loads are shear (stop a bay sliding off) and a
little tension. Anything stronger can be had by gluing.

## Decision

- The bay is two identical plates, two identical walls and a rear panel,
  each printed flat with no supports, pressed together with tabs through
  slots. The rear panel squares the back; the caddy's tray inside the bay
  holds the front.
- Plates and walls carry a 6 mm honeycomb, and a hex bump is the same shape
  as a cell. Every outer face carries four bumps, 5.6 mm across flats and
  1.4 mm tall, on the part's own lattice, placed so that the identical part
  turned for the opposite face presents an open cell where each bump
  arrives.
- Plates: bumps at columns −6/+6 of row +6 and −4/+8 of row −6. The plate
  turned over for the bottom mirrors y; each bump lands two cells from any
  pad. Stack pitch 34.8 mm.
- Walls: bumps at columns −8/+4 of rows +1 and −1. The wall turned end for
  end maps column i to −i−1 on those rows; each bump lands three cells from
  any pad. Lateral pitch 112.6 mm.
- No connector part of any kind.

## Consequences

- Six part types per drive and bay, none of them a connector.
- Bumps locate and stop sliding; they do not lock. Glue them if a block
  must lift as one.
- The arrows matter: the offsets assume neighbouring plates and walls point
  the same way.
- Wall venting is three rows of 6 mm cells with row 0 kept clear.
- Bay stiffness comes from the tab joints plus the rear panel and the
  inserted caddy; glue is recommended for a stack that will be moved.
- Checks: a neighbour shifted 1 mm along the bay, stacked or beside, must
  hit the bumps.
