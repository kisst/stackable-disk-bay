# Design

## Goals

1. Hold a 3.5" drive (SFF-8301) without screws or tools.
2. Bays stack vertically and join side by side, with a positive clip-in
   connection; every bay is the same part.
3. Print on a common 220 × 220 mm bed, every part flat, no supports.
4. Keep air moving over and under the drive; stay rigid enough that a stack
   of loaded bays does not rack.

Non-goals for now: 2.5" drives, backplanes, fans, hot-swap electronics, and
any metal hardware.

## Coordinate frame

Shared by every part so the assembly and the checks need no offsets.

- **x** rear → front. The drive's connector face is at x = 0, the bezel at the
  front.
- **y** width, centred on 0. −y is the fixed-pin wall; +y is the finger
  wall.
- **z** 0 is the caddy floor's underside, which is also the bay floor's top.

## Drive envelope used

| | mm | source |
| --- | --- | --- |
| width | 101.6 | SFF-8301 A3 |
| length | 147.0 max | A4 |
| height | 26.1 max | A1 |
| side holes above bottom | 6.35 | A8 |
| side holes from connector face | 28.5 and 130.1 | A6, A6 + A7 |
| side hole thread | 6-32 UNC, minor ≈ 2.8 | |

The pins are 2.6 mm so they enter the thread's minor diameter with 0.1 mm a
side. Shorter or lower drives (20.2 mm) fit; only the hole positions matter.

## Caddy

A tray: honeycomb floor in a 6 mm solid frame, two 2.4 mm walls 25 mm tall
with honeycomb on the bay wall's lattice, a front bezel the size of the
bay's face, and a grab bar.

- **Fixed pins** on the −y wall at the two hole positions, conical tips.
- **Finger pins** on the +y wall sit at the lower ends of two cantilever
  fingers that run at 45° from the wall's top rim down to the pin, 6 mm wide
  in the wall's plane, 1.6 mm thick (the outer face is recessed 0.8 mm), cut
  free by a 1.2 mm slot. The angle is for printing: every slot face is a 45°
  overhang, so the tray prints flat with no support, where a horizontal
  finger floats over its lower slot on its first layer. The beam's lowest
  corner is cut flat 1.6 mm wide, so its first layer is a bead four lines
  wide rather than a point. The fingers are about 18 mm long; clearing the
  2.1 mm pin takes about 2.3 mm of deflection, which is about 1.5 % strain
  at the root: fine in PETG, acceptable in PLA. The recessed outer face
  gives a fingernail the purchase to release. The 3 mm rim above a finger
  is measured from the slot's highest point, the corner of its ring at the
  root, which sits 3 mm above the beam's centreline.
- **Detent** for retention in the bay: a third finger of the same shape on
  the −y wall carries two 1 mm bumps, one at the tip and one a lattice pitch
  (7.8 mm) up the 45° beam. The bay wall has a 4.5 mm hole for each. While
  the caddy slides in, the bumps cross the wall's honeycomb; because they
  are offset by a pitch in x and by one row in z, one bump is always on a
  web when the other is over a cell, so the finger cannot click into a vent
  hole. Both drop in together only at the seated position. The handle
  overcomes them.
- **Wall vents**: the caddy walls reach 27 mm and would otherwise cover
  the bay's side honeycomb, so they carry the same 6 mm lattice, phased to
  the bay wall's, with solid zones round fingers, pins and the bezel tabs.
  The zone round a finger is the bounding box of its slot ring and recess
  plus the 1.5 mm web margin, so no cell comes near a slot's tip corner.
- **Bezel** is a 2 mm plate the size of the bay's front face. It seats on
  the front edge of the plates and walls, carries a honeycomb intake over
  the drive's front and a low grab bar (44 mm between 4 mm posts, 6 mm
  proud). It is a separate print, front face down, and joins the tray by
  three tabs (one on each wall end, one on the floor) through slots in the
  plate. Its lower edge reaches below the tray's floor, which is why it is
  not part of the tray print.

Clearances: 0.3 mm a side drive-to-caddy, 0.4 mm a side caddy-to-bay.

## Bay

Five flat parts, all 2.4 mm: two identical plates, two identical walls and a
rear panel. Inner section 107.8 × 30.0; the bay runs from 5 mm behind the
drive's connector face to the bezel, 152.5 mm. The bezel stops the caddy.

- **Plate**: honeycomb inside a 6 mm rim, six through-slots for the wall
  tabs, four hex bumps on one face. The bottom plate is the same part turned
  over so its bumps face down.
- **Wall**: honeycomb inside a 4 mm rim, three 14 mm tabs on each long edge,
  four hex bumps on the outer face on the lattice's rows +1 and −1, the
  caddy detent hole. The right wall is the same part turned end for end, which
  puts a second, unused detent hole at the mirrored position.
- **Rear panel**: an L. The lower −y corner is open from the bottom edge
  and the side edge up to 12.5 mm, just under the wall tab, for the SATA
  power and data plugs; a closed window there would leave slivers weaker
  than no material. Exhaust honeycomb over the rest, two tabs into each
  plate on the +y half, one tab into each wall at 13 to 25 mm. The plate
  carries both mirror images of the tab slots so one plate still serves top
  and bottom. The panel sits 1.2 mm behind the drive's connector face.
- **Front**: with the caddy in, its tray sits inside the bay at 0.4 mm a
  side, which keeps the walls from spreading; the bezel plate only seats on
  the front edge. The rear panel squares the back.
- **Orientation marks**: a 1 mm groove, 0.6 mm deep, runs along the outside
  of both walls and the rear panel 1.8 mm above the inner floor. When the
  three grooves line up in one low line round the bay, every part is the
  right way up; a wall or panel put in upside down shows its groove near the
  top. The plates carry an engraved arrow on the bump face, on a solid pad in
  the honeycomb, pointing to the front, so the rear-panel slots end up at the
  back and the bumps face out. Top and bottom plates share one geometry but
  are separate prints: the bottom plate's arrow has a bar under it, so the
  two can be told apart on the bench. The wall has a rear-panel slot at
  both ends so one part serves both sides without a mirror image; the
  unused front slot is hidden under the bezel flange.
- **Fit**: tabs are 0.15 mm a side smaller than their slots. Press together;
  a drop of glue at the tabs makes it permanent.

### Joining bays

No extra parts in either direction. Every bump is 5.6 mm across flats,
1.4 mm tall, and stands on its part's own 6 mm honeycomb lattice, placed so
that when the identical part is turned for the opposite face, each bump of
one bay arrives in an open cell of the neighbour's part.

**Stacking.** The plate bumps sit at columns −6 and +6 of row +6 and
columns −4 and +8 of row −6. Turning the plate over for the bottom mirrors
y, so each bump lands two cells from any pad: an open cell. Stack pitch is
the bay height, 34.8 mm. The arrows keep both plates pointing the same way,
which the offset depends on.

**Side by side.** The walls share the 6 mm lattice (three rows fit in the
30 mm height; the bumps use rows +1 and −1 and leave row 0 for venting).
The right wall is the left wall turned end for end, which maps column i to
−i−1 on those rows. Bumps at columns −8 and +4 land at +7 and −5, three
cells from any pad. Bays touch; lateral pitch is the bay width, 112.6 mm,
and neighbouring bezels meet edge to edge.

Both joints locate and square the array and stop sliding; neither carries
a bay if its neighbour is lifted. Glue the bumps for that.

To join, set the next bay on top, or bring it in from the right, with its
arrows pointing the same way; its cells drop over the bumps and the faces
touch. The array grows as high and as wide as you like.

### Assembling a bay

Insertion order and directions (see the assembly drawing, `assembly_steps.png`):

1. **Rear panel into the bottom plate.** Bottom plate arrow with a bar,
   bumps down. Stand the panel in it, groove low, SATA notch at the bottom
   on the −y side; its two bottom tabs drop into the plate's slots.
2. **Walls slid in from the sides.** Hold a wall level, lifted one plate
   thickness (2.4 mm) above the plate, groove low, and slide it inward.
   The panel's side tab enters the wall's slot, which runs 2.4 mm below the
   tab's resting place for exactly this. When the wall is over its plate
   slots, let it drop: its three bottom tabs enter the plate and the panel
   tab rises to the top of its slot. Either end of a wall may face the rear.
3. **Top plate on.** Arrow only, bumps up, arrow toward the front; it drops
   over the walls' top tabs and the panel's top tabs. Glue the tabs if the
   bay will be moved about.

`scripts/check.sh` proves the path: the panel half-way down, a wall
approaching lifted and 4 mm out, the wall lifted in place, the wall half-way
down, and the top plate half-way down all clear the parts already placed,
and a lifted wall pushed 1 mm too far hits the panel, so the sideways slide
really engages the tab.

### Venting

Honeycomb (6 mm cells, 1.8 mm web) through both plates, both walls and the
rear panel, stopping 6 mm from the plate edges and 4 mm from the wall edges.
The walls fit three rows; the bumps take rows +1 and −1 and row 0 vents.
Cells are skipped within 1.5 mm of a bump, a tab slot, the SATA cutout or
the detent hole. Air enters through the
bezel, passes over and under the drive, and leaves through the rear panel.

The caddy floor and the bay's bottom plate are two honeycombs in series
under the drive. They use the same 6 mm lattice and the caddy's grid is
phased to the plate's centre, so the cells coincide when the caddy is in.
`scripts/vent.sh` sections both at mid-thickness and intersects them:

| | open area | of drive footprint |
| --- | --- | --- |
| caddy floor alone | 6976 mm² | 46.7 % |
| bay bottom plate alone | 6173 mm² | 41.3 % |
| straight through both | 5793 mm² | 38.8 % |

The remaining loss is the plate's solid pads around bumps, tab slots and
the orientation mark, which the floor cannot see past. The script fails if
the through-open area drops under 85 % of the smaller layer, which is what
a drift between the two lattices would look like. The open floor lets air
reach the drive's underside, where the PCB and spindle motor are; the bezel
is a finer honeycomb (4 mm cells).

## Print orientation

Everything flat, nothing needs support.

| Part | Footprint | Notes |
| --- | --- | --- |
| Caddy tray | 107 × 150.5 mm, 27 mm tall | pins and detent bump are small horizontal protrusions; finger slots are 45° |
| Caddy bezel | 112.6 × 34.8 mm, 8 mm tall | front face down; the bar lies on the bed |
| Plate, top and bottom | 112.6 × 152.5 mm | bumps up; marks differ |
| Wall | 152.5 × 34.8 mm | bumps up |
| Rear panel | 112.6 × 34.8 mm | |
| Coupon | 50 × 107 mm | |

## Verification

`scripts/check.sh` proves, by boolean intersection in OpenSCAD:

- the walls' and rear panel's tabs sit in their slots without overlap, and a
  wall or panel shifted 1 mm hits plate or wall material (the tabs engage);
- the rear panel clears the drive and its connectors, and the bezel seats on
  the bay's front face (a bay pushed 1 mm forward hits it);
- the caddy with a drive sits inside the bay touching only where the bezel
  seats; the drive touches the caddy only on the floor (pins are inside the
  holes);
- stacked and side-by-side neighbours touch only on their faces, and a
  neighbour shifted 1 mm along the bay hits the bumps (they sit in open
  cells of the neighbour's part);
- in a 2 × 2 array with a caddy and drive in every bay, no loaded unit
  overlaps any other, including the diagonals, and a loaded caddy never
  reaches a neighbour's bumps.

`scripts/thin.sh` proves that no printed part has material thinner than two
perimeters (0.8 mm). It slices each part in its print orientation every
0.4 mm along z and every 2 mm along x and y, opens each slice by 0.4 mm
(straight-edged erosion, round dilation, so a tapering wedge is caught as
well as a parallel sliver) and exports what the opening removed. The round
dilation also nibbles every convex corner by 0.4 mm: a right-angle nib is
0.034 mm², two of them merged across a hair-thin slit about 0.07 mm², so
anything under 0.1 mm² is dropped; a real thin wedge, such as one over a
finger root, is 0.3 mm² or more. What remains is classified by how
it joins the thick material: at two or more places it is a neck or a roof
and fails; over more than 1.5 mm it is a fin and fails; at none it is an
island, which fails in the z pass (a first layer in the air, or a pillar)
and passes in the x and y passes, where an island is the apex of a corner
pointing along the slice normal and anything real there is a neck or fin
in another pass; a single short contact is the tail a slice leaves when it
grazes a sharp corner, and passes. Pins and detent bumps are left off the
tray for this check: a horizontal cylinder sliced near its tangent is
always thin.

The reference drive (`scad/hdd.scad`) is the full SFF-8301 envelope with
tapped side and bottom holes, the recessed PCB and motor hub, the jumper
header, and a SATA device plug modelled to the SATA-IO layout: horizontal
L-shaped tongue at the bottom of the connector face, 7-contact signal
segment nearest the drive's edge, 15-contact power segment inboard, 1.27 mm
pitch, in a pocket inside the 147 mm envelope. A separate model,
`scad/sata_plugs.scad`, holds the mated data and power cable plugs, and a
check proves they pass through the rear panel's cutout. Segment lengths
and pocket depth are nominal, so the cutout should be confirmed against a
real drive before printing many rear panels.

## What the first print has to answer

1. Finger stiffness at 1.5 % strain in the chosen filament, and whether
   2.6 mm pins seat in the tapped holes of the drives on hand.
2. Fit of the 5.6 mm bumps in the 6.0 mm cells; one parameter.
3. Tab-in-slot fit at 0.15 mm a side, and whether the pressed bay is square
   and stiff enough without glue.
4. Bezel-to-tray tab fit at 0.15 mm a side.
5. Rigidity of a loaded 2 × 2 block located by bumps alone; if it racks,
   glue the bumps.

## Open questions

- The bottom row stands on its 1.4 mm bumps; print the bottom plates without
  bumps, or add a foot tile?
