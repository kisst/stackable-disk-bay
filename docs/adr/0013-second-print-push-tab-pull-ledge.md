# 0013 — Second print: push tab, pull ledge, lock, wall tabs

## Context

The 0.2.0 test print found five problems.

1. The push tab at the tray's rear +y corner made the caddy wedge in the
   bay. Pushed at a corner, 48 mm off the centre line, the caddy turned in
   its 0.4 mm side play and jammed, like a drawer pushed at one end. The
   tab also stood too far out behind the bay.
2. The spring lock's click was too soft.
3. The bezel lip was still longer than it needed to be. Only the middle of
   the top plate needs propping.
4. The finger notch did not work with a 3.5" drive in the caddy. There was
   0.5 mm between the drive's front face and the bezel, so a finger had
   nothing to get behind.
5. The walls were still loose in the plates.

## Decision

- **Push tab in the middle.** It is now a tongue on the tray floor's rear
  edge, as thick as the floor and 10 mm wide, with no rib. It sits as
  close to the centre line as the rear panel's open corner allows:
  y −2.2 to 7.8, so its centre is 2.8 mm off the centre line. The corner
  is unchanged. A rib in the middle would hit the SATA plugs, but the
  floor-thick tongue passes under them, as the old floor plate did. Its
  rear corners are rounded in plan, its top rear edge is rounded down
  toward the bed, and it is filleted into the floor's rear edge. It stands
  2 mm proud of the bay's rear face, down from 5 mm.
- **Firmer click.** The lock bump reaches 1.5 mm into the top plate when
  relaxed, up from 1.0 mm. The slit under the beam grows by the same
  amount, to 2.1 mm, so the beam keeps 0.6 mm of room for bridge sag when
  pressed flat. The preload stays at 0.4 mm. The holding ramp now bears
  1.1 mm deep on the slot's edge, up from 0.6 mm. The lock slot grows to
  4.5 mm along the bay.
- **Short lip.** The bezel lip is 10 mm long, centred on the centre line.
- **Pull ledge, at the front, as the push tab is at the rear.** This was the
  printer owner's idea. The tray's floor tab already passes through the bezel's
  bottom slot. It now runs on 10 mm past the bezel's face, as a flat ledge as
  thick as the floor, under the bezel's honeycomb. It leaves the face at the
  tab's full 60 mm width and narrows to 30 mm over 8 mm, on a rounded taper. A 4
  × 18 mm slot through it, with round ends, starts 3 mm from the bezel. A
  fingernail or fingertip hooks its front edge, as does a screwdriver. The pull
  goes into the tray floor, not through the bezel's friction joint. Its corners
  are rounded in plan (3 mm), and the taper is filleted into the straight front
  end (6 mm). A first version was 6 mm long with no slot, its top sloping over
  its whole length; it gave nothing to grab.
- **The ledge locks the bezel on**, also the printer owner's idea. Just in front
  of the bezel's face, 0.1 mm clear of it, the ledge stands 0.4 mm taller than
  the floor, and a 2.4 mm ramp, about 10°, takes it back down to the floor's
  top; the rest of the ledge is flat. The barb spans 44 mm, with square ends
  inside the taper's edges. A first version was 30 mm wide, because the ledge
  was 30 mm wide at the face; the taper widened the locking section. Where the
  barb ran over a plan edge, it left slivers thinner than two perimeters, which
  is why its ends are square. Pressed on from the front, the bezel's bottom slot
  rides up the ramp, springs 0.4 mm, and snaps down behind the step. The bezel
  is then held between the tray's front ends and the step, where before only the
  tabs' friction held it.
- **No finger notch.** It served no purpose any more. The bezel's
  honeycomb now covers the whole face inside a 2 mm rim, centred on the
  face. It leaves out only the whole cells within 1.5 mm of the three tab
  slots and of the lip's foot, which must stand on solid plate.
- **More and longer wall tabs, tighter.** Each long edge of a wall has four
  22 mm tabs, up from three of 14 mm: 88 mm of grip per edge instead of 42.
  They sit at 27 and 60 mm either side of the centre. That keeps them
  symmetric, so one part still serves both sides, and clear of the top
  plate's lock slots by 2.4 mm of plate. The plate slots are now 0.08 mm
  a side across the wall's thickness, the rear panel's friction fit. Along
  the tab's length they stay 0.15 mm, which grips nothing and leaves room
  for elephant foot.
  (Amended by [0014](0014-dovetailed-wall-joint.md): the tabs are now
  dovetails in edge notches, and the walls go in last.)

## Alternatives

- A printed pull hook through the bezel's centre hex cell, catching the
  web under it. It needed a 3.5 mm gap in front of the drive for its tip,
  so every part would grow 3 mm. It was modelled and checked, then dropped
  for the ledge, which needs no extra part and no extra length.

## Consequences

- The tray grows 7 mm overall, to 166.5 mm: the ledge adds 10 mm at the
  front, and the push tab is 3 mm shorter at the rear. The bay's length is
  unchanged.
- The service holes ([ADR 0012](0012-finger-service-holes.md)) are now
  placed from their fingers, 1 mm into each slot's tip corner, and 0.7 mm
  clear of the beam, still on the pin's lattice row. The vent lattice is
  centred on the bay, so a cell picked from it moves whenever the bay's
  length changes. While the hook's longer bay was tried, the rear finger
  had no usable cell left. The wall vents keep a web away from the holes.
- The spring's strain when pressed flat rises from about 0.8 % to 1.2 %,
  which is fine in PETG. Its rate is unchanged, so the release force
  rises with the deeper holding ramp.
- The bezel no longer comes off by hand once it has snapped on; lifting
  the slot's edge over the step with a small screwdriver releases it.
- Checks: the bezel slid 1 mm forward along its tabs hits the barb
  (`bezel_locked`). Snapping on is elastic, so no rigid check covers it.
  The push tab is covered by `plugs_vs_caddy` and
  `path_caddy_past_panel`. The ledge stands in front of the bay, and the
  neighbour and array checks cover it against bays above and beside.
