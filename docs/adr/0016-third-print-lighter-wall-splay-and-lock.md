# 0016 — Third print: lighter wall splay, softer spring lock

## Context

The 0.3.0 test print found two problems.

1. The caddy tray fits as intended, but the spring lock now holds too
   hard. Its bump reaching 1.5 mm into the top plate (ADR 0013) was more
   than needed; 0.2.0's 1.0 mm clicked too softly.
2. The dovetailed wall joint (ADR 0014) holds, but far too tight: with
   both slopes at their 0.3.0 angles and no clearance on the dovetail
   faces, the bay could hardly be assembled. Two slopes at once may work
   in another material or on a printer with tighter tolerances, not on
   this one. The printer owner was clear that one slope may stay as it
   is, even if the prints need cleaning up, but not both.

## Decision

- **The flare stays at 15°.** It holds the critical load, the top plate
  pulled off the walls, and it runs along the wall's sliding path, so it
  costs friction but no snap.
- **The splay drops from 4° to 1.5°.** The snap at each tab end falls
  from 0.17 mm to 0.06 mm, about a third. It is no longer a firm snap,
  more a light detent that keeps the wall from creeping out; the wall's
  thickness across the notch (0.08 mm a side) and the flare's friction do
  the rest.
- **No clearance on the dovetail faces, still.** At 1.5° play becomes
  even more slop than at 4°: 0.05 mm an end would let a wall slide out
  1.9 mm.
- **The spring lock's bump reaches 1.25 mm** into the top plate, between
  0.2.0's 1.0 mm and 0.3.0's 1.5 mm. The slit follows it, to 1.85 mm, so
  the beam keeps its 0.6 mm of room for bridge sag. The preload stays at
  0.4 mm, so the holding ramp bears 0.85 mm deep on the slot's edge, and
  the slot in the top plate shortens to match.

## Alternatives

- **Splay to 0.** The wall would slide in on friction alone and nothing
  but that friction would stop it sliding back out. Kept as the next step
  if 1.5° is still too hard.
- **Keep the splay, drop the flare.** The splay alone does not stop the
  critical load: the top plate lifting off the walls would then be held
  only by the rear panel.
- **Clearance on the dovetail faces instead of a lower angle.** At either
  angle it turns into slop along the slope's shallow direction, which is
  what the zero clearance was there to avoid.

## Consequences

- Reprint the plates, the walls and the caddy tray. The top plate's lock
  slots move with the bump; the bottom plate changes only in its notches.
- Assembly may still need a light clean-up of the notches' sloped ends
  (their corners are relieved since [0017](0017-corner-reliefs-at-joint-corners.md))
  and the tabs' ends; the 15° flare's faces slide with no clearance.
- `wall_out_locked` still passes, but only just: the 1.5° splay is all
  that blocks a wall slid outward, with a small overlap volume.
- `tab_splay` is the parameter: 0 if a wall is still too hard to slide in,
  2° if it slides back out. `sp_lock` for the spring.
