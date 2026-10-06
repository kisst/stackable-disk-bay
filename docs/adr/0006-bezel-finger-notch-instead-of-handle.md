# 0006 — Bezel finger notch instead of a handle

## Context

The bezel's grab bar stood 6 mm proud on two posts. Printed as a flat
plate, the bar is either a bridge over the posts or the plate floats on
them, so the part needed support. The handle exists only to pull the caddy
out.

## Decision

- No handle. The bezel is a flat 2 mm plate with a drawer-style notch in its
  top edge near the +y corner, as proposed by the printer's owner. The notch
  is 36 mm wide at the edge and 20 mm at the bottom, 14 mm deep, with 4 mm
  radii in the bottom corners and the mouth eased into the edge.
- The honeycomb intake stays solid round the notch.

## Consequences

- The bezel prints front face down, a plain plate: no bridge, no support,
  less material and time.
- The notch is the only grip. Whether it holds well enough against the
  spring lock is for the next print; the lock's release force is set by
  `sp_hold`, `sp_lock` and `sp_preload`.
- The thin check now places the bezel on the bed. Its old bounds missed the
  part entirely, so its layer slices had been testing nothing.
