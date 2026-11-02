# 0017 — Corner reliefs at the wall joint, glue holes elsewhere

## Context

Every printed inside corner comes out rounded, by about half a line
width, while the corner that seats in it on the mating part comes out
sharp. The sharp corner then stands off the rounded one, and the faces
either side of the joint do not close until the corner is cleaned out by
hand. The third print needed that clean-up on the wall joint, the one
joint that has given trouble.

## Decision

- **A round relief, `relief_r` = 0.5 mm, in the wall joint's inside
  corners**, through the part, so the mating corner lands in free space.
- **T-bones, as the corners are square.** The relief is tangent to the
  face that carries the fit and cuts 0.5 mm into the other face, so the
  fit is untouched:
  - plate wall notches: at the inner corners, into the plate along the
    inner face; the dovetail ends keep their full face
  - wall tab roots: into the wall's edge beside each tab, where the
    notch's corners on the plate's inner face seat
- **The lock bump's track stays solid.** On the top plate, the notches
  the caddy's spring bumps ride past would have put a pocket at the edge
  of their track. Those four take the relief into the dovetail end
  instead, tangent to the inner face.
- **The joiner plates' dovetails too**, centred on the corner as it is
  acute: the tab roots and the sockets' deep corners. They edge-join flat
  pieces whose seams must close.
- **Two diagonal corners as glue holes** on the joints that fit without
  them: each of the walls' rear-panel slots, and the bezel's two upper
  wall-tab slots. Centred on the corner, not a T-bone: a round hole in
  the corner itself, cutting a quarter circle into both faces. The hole
  beside the tab lets a drop of thin superglue run down into
  the joint, for a bay or caddy that is meant to stay together. Two
  corners are enough for the glue; the other two keep the slot's ends
  whole.

## Not relieved

- The rest of the rear panel's joint (its slots in the plates, its tab
  roots) and of the bezel's (its lower wall-tab slots and floor-tab slot,
  the tray's tab roots). Both joints have gone together without trouble
  on every print, so they keep only the glue holes.
- The hex bumps in their cells: they taper into the cell and do not
  bottom out in a corner.

## Consequences

- The plates, walls, bezel and joiners change for the reliefs. The rear
  panel and the tray's tabs do not.
- On the four top-plate notches relieved into their ends, the dovetail
  face is 1 mm shorter at the inner face. The lift and slide locks are
  checked on the bottom plate, which keeps the full face.
- `relief_r` is the one parameter. Make it bigger for a wider nozzle.
