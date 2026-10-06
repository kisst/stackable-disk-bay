# 0012 — Service holes at the finger tips

## Context

On a test fit, a drive whose pins had engaged was almost impossible to
take out of the caddy. The fingers' recessed outer faces give a fingernail
too little to pull on against the pin's grip in the hole.

## Decision

- A honeycomb cell through the finger wall beside each finger's tip, on
  the wall's own lattice so it reads as part of the vent pattern. It sits
  on the lattice row at pin height (8.25 mm against 8.35 mm), and is the
  first cell past the slot's mitred tip corner: x 137.55 for the front
  finger, 20.55 for the rear one.
- The cell overlaps the end of the slot, so the hole and the slot are one
  opening and a screwdriver reaches the finger's tip. It does not touch
  the beam: 0.2 mm clear at the front finger, 0.7 mm at the rear one, and
  `service_holes()` asserts a clearance so a parameter change cannot cut
  into a finger.

## Consequences

- To remove a drive: pry each finger tip out through its hole, then lift.
- Where the cell's flat side meets the slot's 45° edges it would leave a
  small step of wall above and below; the cell's slanted edges are carried
  on to the slot edges instead, so the opening is clean. The wedges of
  wall left above and below each meeting point are cut flat where they
  are 1 mm wide: the thin-section check caught their tips printing as
  layers under 0.8 mm.
- Two more openings in the finger wall, both on the lattice, and no
  slivers where they meet their slots.
- The front hole reaches to 7 mm from the wall's front end, inside the
  zone otherwise kept solid round the bezel's wall tab.
