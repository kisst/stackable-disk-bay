# 0014 — Dovetailed wall joint; walls go in last

## Context

The walls were still loose in the plates after the second print's longer,
tighter tabs (ADR 0013). A tighter plain fit does not help: the window
that works is about as wide as the printer's tolerance, so a tight print
jams and a loose one rattles.

The joint is a box corner, not a T: each plate's notches are open at its
edge, and the wall's outer face is flush with it. A plain tab in such a
notch is held along the bay by the notch's ends and inward by its inner
face, but nothing stops the wall lifting off the plate or sliding out off
its edge. Each of those two directions needs a slope of its own.

## Decision

- **Each wall tab end is a dovetail on both free axes.**
  - **Flare, 15°**: the tab widens toward the plate's outer face, 0.64 mm
    an end. The wall cannot lift off. This is the critical load, the top
    plate pulled off the walls, so it gets the steep angle.
  - **Splay, 4°**: the tab widens toward the wall's inner face, 0.17 mm an
    end. The wall cannot slide outward.
    (Amended by [0016](0016-third-print-lighter-wall-splay-and-lock.md):
    1.5°, as the third print's walls would not go in.)
- **The walls slide in sideways, last.** The flare runs along that path,
  so only the splay has to be passed, and it snaps: that is why it is the
  shallow angle. The order becomes rear panel into the bottom plate, top
  plate onto the panel, walls in from the sides. A wall meets its notches
  and the panel's side tab in the same direction, so no slot or notch
  needs extra length (the reason for ADR 0009's order still holds).
- **No clearance on the dovetail faces.** A shallow angle turns play into
  slop: 0.05 mm an end would let a wall slide out 0.7 mm. Across the
  wall's thickness the fit stays 0.08 mm a side.
- **Still flat and support-free.** The wall's flare lies in its own plane
  and its splay leans inward from the bed (inner face down). The plate's
  splay lies in its plane and its flare widens upward from the bed.

## Alternatives

Mocked up and set aside:

- A closed slot (a T joint) with spring tabs, detents or crush ribs. The
  joint is an edge joint, so these did not apply as drawn.
- Relief-cut spring fingers at the tab ends: the fingers left at 2.4 mm
  thickness were too short and stiff to flex.
- A detent bump and groove: too small a detail for a normal print.
- A single dovetail. Splay alone leaves lifting free, flare alone leaves
  sliding out free.
- Both slopes shallow, the wall dropped in from above as before. The steep
  flare holds the critical load far better, and putting the snap on the
  splay costs only the change of order.

## Consequences

- A wall is locked in every direction once in. To remove it, push it out
  sideways from the inside, evenly.
- The plates are held only by the panel at the rear while the walls go
  in; hold their front ends apart by hand.
- The snap, 0.17 mm a tab end, is about the size of the printer's
  tolerance. The tabs are solid, so the snap is taken by the printed
  edges, and the fit will differ from printer to printer. The splay
  angle and the face clearance are the parameters to tune
  (`tab_splay`, `tab_clr`). Slicer elephant-foot compensation matters,
  since the first layers of both parts are the tight ones.
- Checks: `path_rear_drop`, `path_top_drop` and `path_wall_onto_panel`
  clear; `path_wall_slide`, a wall half-way in with its splay set to 0,
  clears both plates, which shows the splay is all that snaps.
  `wall_lift_locked` and `wall_out_locked`: a wall lifted or slid outward
  1 mm cuts into the bottom plate. These two demand overlap volume, not
  just shared faces, since a face the wall slides along also shares facets;
  each fails with its own angle set to 0 (`tab_flare`, `tab_splay`).
  `path_u_drop` is gone.
