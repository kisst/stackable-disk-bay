# Design

## Goals

1. Hold a 3.5" drive (SFF-8301) without screws or tools, and a 2.5" drive
   (SFF-8201) through an adapter that takes the 3.5" drive's place in the
   same caddy, with no change to the caddy or bay.
2. Bays stack vertically and join side by side, with a positive clip-in
   connection; every bay is the same part.
3. Print on a common 220 × 220 mm bed, every part flat, no supports.
4. Keep air moving over and under the drive; stay rigid enough that a stack
   of loaded bays does not rack.

Non-goals for now: backplanes, fans, hot-swap electronics, and any metal
hardware.

## Coordinate frame

Shared by every part so the assembly and the checks need no offsets.

- **x** rear → front. The drive's connector face is at x = 0, the bezel at the
  front.
- **y** width, centred on 0. −y is the fixed-pin wall; +y is the finger
  wall and the side the drive's SATA connector is on (on the left, seen
  from behind with the label up).
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
with honeycomb on the bay wall's lattice, and a front bezel the size of the
bay's face with a finger notch.

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
  gives a fingernail the purchase to release, but a test fit showed that
  is not enough once the pins are in a drive's holes.
- **Service holes**: one honeycomb cell on the wall lattice beside each
  finger's tip, at pin height (the lattice row at 8.25 mm), the first cell
  past the slot's tip corner: x 137.55 for the front finger, 20.55 for the
  rear. It overlaps the slot's end, so hole and slot are one opening, and
  a small screwdriver gets at the tip to pry the pin out of the drive. The
  cell's slanted edges run on to the slot's edges, so no step of wall is
  left where the two meet, and the wedge of wall above and below each
  meeting point is cut flat where it is 1 mm wide, so its first layers are
  not thinner than two perimeters. It
  clears the beam by 0.2 mm (front) and 0.7 mm (rear); `service_holes()`
  asserts that. The 3 mm rim above a finger
  is measured from the slot's highest point, the corner of its ring at the
  root, which sits 3 mm above the beam's centreline.
- **Spring lock** for retention in the bay, on the top edge of both walls.
  A 54 mm slit under the rim (x 56 to 110, between the +y wall's finger
  slots) frees a 2 mm beam anchored at both ends, under a 1.5 mm hump that
  rises from the rim on 15° ramps with 6 mm radii. A bump in the beam's
  middle rides on the top plate's underside. It has a 30° lead-in ramp facing
  the rear, a 45° holding ramp facing the front and a 1.2 mm crest, with
  1.5 mm fillets at its foot and a 1 mm radius on the crest, and reaches
  1.0 mm into the plate when relaxed. Its track
  lies under the plate's solid rim, outside the honeycomb, so it has nothing
  to drop into until it reaches its slot at the seated position. The slot's
  front edge meets the holding ramp with 0.4 mm of deflection left, so the
  spring keeps pushing the caddy down and the bezel onto the bay. Anchored at
  both ends, the beam's underside prints as a bridge; the bump stands upright
  on the edge. The beam rate is about 4 N/mm in PETG and 7 N/mm in PLA per
  side, at 0.8 % strain when pressed flat. A finger in the bezel's notch
  overcomes the 45° ramps.
- **Push tab** at the rear +y corner, so the caddy can be pushed out from
  behind without loading the bezel joint. The tray's floor corner runs back
  through the rear panel's open SATA corner and ends 5 mm behind the bay's
  rear face. It is a floor-level plate 10 mm wide, which passes under the
  SATA plugs (their housings start 2.4 mm up), plus a 6 mm rib in line with
  the side wall that sweeps up into the wall's rear edge on an 8 mm fillet.
  Both rear corners are rounded in plan and the rib's top edge is rounded.
  It prints on the bed with the tray.
- **Wall vents**: the caddy walls reach 27 mm and would otherwise cover
  the bay's side honeycomb, so they carry the same 6 mm lattice, phased to
  the bay wall's, with solid zones round fingers, pins and the bezel tabs.
  The zone round a finger is the bounding box of its slot ring and recess
  plus the 1.5 mm web margin, so no cell comes near a slot's tip corner.
- **Bezel** is a flat 2 mm plate the size of the bay's front face. It seats
  on the front edge of the plates and walls and carries a honeycomb intake
  over the drive's front. There is no handle. A drawer-style notch in the
  top edge near the +y corner, 36 mm wide, 14 mm deep, with rounded corners,
  gives a place to pull by; the honeycomb stays solid round it. It joins the
  tray by three tabs, one on each wall end and one on the floor, through
  slots in the plate. It is a separate print, front face down, because its
  lower edge reaches below the tray's floor.
- **Bezel lip**: a 2 mm lip on the bezel's back face at the top, 1.4 mm
  thick, 3.5 lattice pitches (27.3 mm) long, from y −26.1 to 1.2: the
  middle, where the top plate sags most, on the fixed-pin side and clear of
  the finger notch. When the caddy is seated it sits under the top plate's
  solid front rim, its top 0.2 mm under the plate's underside, and props the
  plate up. A 0.5 mm chamfer on its rear top edge lets a sagging plate ride
  up onto it. It reaches 1.5 mm over the drive's front edge, 0.3 mm above
  a 26.1 mm drive. The drive goes in fixed-pin edge first and sits lowest
  there, and passes under the lip by flexing the bezel as the other edge
  is pressed down. Checks: `bezel_lip_holds` (the plate let down 0.4 mm
  hits it) and `path_bezel_lip` (3 mm from seated, the lip is already
  under the rim and clears the bay).
- **Wall front posts**: near its edges the top plate is propped by the
  caddy walls instead. Over their last 8 mm at the bezel end both walls
  rise from 27 mm to 29.8 mm, 0.2 mm under the plate's underside, with a
  45° ramp behind that lifts a sagging plate as the caddy goes in. The
  0.2 mm gap, like the lip's, keeps them from binding in a bay printed a
  little short. Check: `posts_hold`.

Clearances: 0.3 mm a side drive-to-caddy, 0.4 mm a side caddy-to-bay.

## Bay

Five flat parts, all 2.4 mm: two identical plates, two identical walls and a
rear panel. Inner section 107.8 × 30.0; the bay runs from 5 mm behind the
drive's connector face to the bezel, 152.5 mm. The bezel stops the caddy.

- **Plate**: honeycomb inside a 6 mm rim, six through-slots for the wall
  tabs, rear-panel slots (four in the top plate, two in the bottom), two
  lock slots for the caddy's spring bumps in the top plate only, four hex
  bumps on one face. The bottom plate is turned over so its bumps face
  down.
- **Wall**: honeycomb inside a 4 mm rim, three 14 mm tabs on each long edge,
  four hex bumps on the outer face on the lattice's rows +1 and −1, and a
  slot for the rear panel's side tab, sized to the tab. The right wall is
  the same part turned end for end, so the slot is cut at both ends; the
  front one is unused, behind the bezel.
- **Rear panel**: an L. The lower +y corner is open from the bottom edge
  and the side edge up to 12.5 mm, just under the wall tab, for the SATA
  power and data plugs; a closed window there would leave slivers weaker
  than no material. Exhaust honeycomb over the rest, four tabs along the
  top edge into the top plate, two on the −y half of the bottom edge into
  the bottom plate, and one tab on each side edge, 13 to 25 mm up, through
  a slot in each wall. Each plate carries only the slots the
  panel's tabs use; the bottom plate's are mirrored, as it is turned over.
  The panel sits 1.2 mm behind the drive's connector face.
- **Front**: with the caddy in, its tray sits inside the bay at 0.4 mm a
  side, which keeps the walls from spreading; the bezel plate only seats on
  the front edge. The rear panel squares the back.
- **Orientation marks**: a 1 mm groove, 0.6 mm deep, runs along the outside
  of both walls and the rear panel 1.8 mm above the inner floor. When the
  three grooves line up in one low line round the bay, every part is the
  right way up; a wall or panel put in upside down shows its groove near the
  top. The plates need no mark. Their rear-panel slots sit at the rear
  edge, which shows which way round a plate goes, and the bumps face out.
  Top and bottom are separate prints told apart by their slots: the top
  plate has six (four for the rear panel, two for the caddy lock), the
  bottom plate two (the rear panel's, mirrored because it is turned
  over). The wall has a rear-panel slot at both ends so one part serves
  both sides without a mirror image; the unused front slot sits behind the
  bezel.
- **Fit**: wall tabs are 0.15 mm a side smaller than their plate slots. The
  rear panel's tabs are 0.08 mm a side in every slot, a friction fit. Press
  together; a drop of glue at the tabs makes it permanent.

### Joining bays

No extra parts in either direction. Every bump is 5.6 mm across flats,
1.4 mm tall, and stands on its part's own 6 mm honeycomb lattice, placed so
that when the identical part is turned for the opposite face, each bump of
one bay arrives in an open cell of the neighbour's part.

**Stacking.** The plate bumps sit at columns −6 and +6 of row +6 and
columns −4 and +8 of row −6. Turning the plate over for the bottom mirrors
y, so each bump lands two cells from any pad: an open cell. Stack pitch is
the bay height, 34.8 mm. The offset depends on both bays facing the same
way, front to front.

**Side by side.** The walls share the 6 mm lattice (three rows fit in the
30 mm height; the bumps use rows +1 and −1 and leave row 0 for venting).
The right wall is the left wall turned end for end, which maps column i to
−i−1 on those rows. Bumps at columns −8 and +4 land at +7 and −5, three
cells from any pad. Bays touch; lateral pitch is the bay width, 112.6 mm,
and neighbouring bezels meet edge to edge.

Both joints locate and square the array and stop sliding; neither carries
a bay if its neighbour is lifted. Glue the bumps for that.

To join, set the next bay on top, or bring it in from the right, facing the
same way; its cells drop over the bumps and the faces
touch. The array grows as high and as wide as you like.

### Assembling a bay

Insertion order and directions; [assembly.md](assembly.md) has the same steps
with pictures:

1. **Walls onto the rear panel.** Panel groove low, SATA notch at the
   bottom on the +y side, the drive's connector side. Slide each wall
   sideways onto the panel's side tab, wall groove low on the outside;
   either end of a wall may face the rear. Panel and walls now stand as a
   U.
2. **Into the bottom plate.** The plate with two slots, bumps down, slots
   at the rear. Lower the U onto it: the walls' three bottom tabs and the
   panel's two bottom tabs all drop into their slots together.
3. **Top plate on.** The one with six slots, bumps up, the row of four at
   the rear; it drops over the walls' top tabs and the panel's four top
   tabs. Glue the tabs if the bay will be moved about.

Because the walls go onto the panel before either meets a plate, every
slot only ever sees one direction of travel and fits its tab exactly; the
v0.1.0 order, panel in the plate first and walls slid on lifted, needed a
side slot 2.4 mm too tall. `scripts/check.sh` proves the path: a wall
approaching the panel sideways, the U half-way down into the bottom plate,
and the top plate half-way down all clear the parts already placed. A
panel shifted 1 mm along the bay hits the walls alone, so the side tabs
really sit in the slots.

### Venting

Honeycomb (6 mm cells, 1.8 mm web) through both plates, both walls and the
rear panel, stopping 6 mm from the plate edges and 4 mm from the wall edges.
The walls fit three rows; the bumps take rows +1 and −1 and row 0 vents.
Cells are skipped within 1.5 mm of a bump, a tab slot, a lock slot or the
SATA cutout. Air enters through the
bezel, passes over and under the drive, and leaves through the rear panel.

The caddy floor and the bay's bottom plate are two honeycombs in series
under the drive. They use the same 6 mm lattice and the caddy's grid is
phased to the plate's centre, so the cells coincide when the caddy is in.
`scripts/vent.sh` sections both at mid-thickness and intersects them:

| | open area | of drive footprint |
| --- | --- | --- |
| caddy floor alone | 6955 mm² | 46.6 % |
| bay bottom plate alone | 6485 mm² | 43.4 % |
| straight through both | 6105 mm² | 40.9 % |

The remaining loss is the plate's solid pads around bumps and tab slots,
which the floor cannot see past. The script fails if
the through-open area drops under 85 % of the smaller layer, which is what
a drift between the two lattices would look like. The open floor lets air
reach the drive's underside, where the PCB and spindle motor are. The
bezel uses the same 6 mm cells as every other part.

## Accessories

### 2.5" adapter

The adapter takes the place of a 3.5" drive in an ordinary caddy, so the
caddy, bay and rear panel are unchanged. It is 101.6 mm wide with holes for
the caddy's four pins: teardrop holes through a strip along the +y wall for
the finger pins, and through an outer rail on the −y side for the fixed
pins.

SATA puts the connector at the same place on both sizes: SFF-8323 (3.5")
and SFF-8223 (2.5") both give 13.43 mm from the drive's edge to the blade
and 3.5 mm up from the bottom. So the 2.5" drive sits in the adapter's +y
rear corner, on the caddy floor with its connector face at x = 0. Its
connector then lands where a 3.5" drive's would, moved inboard only by the
2.2 mm strip that carries the finger pins plus 0.2 mm clearance. The plugs
still pass through the rear panel's open corner.

The 2.5" drive hangs on three pins into its M3 side holes (SFF-8201: 3 mm
up, 14.0 and 90.6 mm from the connector end): two on the −y rail, one on
the +y strip near its free end. Tilt the drive onto the rail's pins and
press the other side down; the strip flexes out and its pin snaps in. In
the caddy the strip is backed by the caddy wall, so the drive cannot come
out; at the strip's pin, 14 mm from the rear, that wall is solid, ahead of
the first finger's slot. The base beside and in front of the drive
carries honeycomb on the caddy floor's lattice. Drives 5 to 15 mm tall fit.

### Feet

A hexagonal foot, 24 mm across flats, lifts the bottom bay 12 mm for air
under it. Three hex pins, the bumps' shape and 2.0 mm tall, drop into three
neighbouring open cells of the bottom plate, two in one row and one in the
row above between them. The pins stay inside the 2.4 mm plate, clear of
the caddy floor. Four feet go near the corners, at the cell clusters in
`foot_cells`; any cluster of three open cells works.

### Joiner plates

A joiner is sandwiched between two bays: bay, joiner, bay. It is 2.8 mm
thick, twice a bump's height, so each bay's bumps drop 1.4 mm into holes
from its own side. Width joiners go between stacked bays and come one or
half a bay wide. Height joiners go between bays side by side and come
three, one or half a bay high. All are as long as the bay.

Pieces lock edge to edge with dovetails, two tabs and two sockets per
edge. The sockets sit at the mirror positions of the tabs, so a piece
turned round still mates. Half pieces lock on one edge only, so they end a
run flush. 0.5 + 1 + 0.5 lays a joint two bays long whose seams fall at
mid-bay, tying the two bays together like bricks; 0.5 + 0.5 covers a single
bay.

The plates are honeycomb all over, on the lattice of the bay half each
zone lies against, so every bump lands in a cell and air passes straight
through. The lattice is symmetric about a bay's centre line, so a half
piece cut for the half on one side of it serves the other half turned
round. A full piece straddles the seam between two bays, as in a run; a
single bay takes two half pieces. The three-high piece runs from one bay's
centre line to the one three bays up, so 0.5 + 3 + 0.5 joins four rows.
Width zones fit seven rows of cells. Height zones, 17.4 mm high, fit only
the bump row, with cells skipped next to the dovetails.

Columns of a block with width joiners touch directly, and so do the rows
of a block with height joiners. Use one joiner direction per block: either
direction already ties the block together. Stacked pitch with a joiner is
37.6 mm, side-by-side pitch 115.4 mm.

## Print orientation

Everything flat, nothing needs support.

| Part | Footprint | Notes |
| --- | --- | --- |
| Caddy tray | 107 × 159.5 mm, 31 mm tall | pins are small horizontal protrusions; finger slots are 45°; the spring slits bridge 54 mm |
| Caddy bezel | 112.6 × 34.8 mm, 4 mm tall | front face down; a flat plate with the 2 mm lip standing up |
| Plate, top and bottom | 112.6 × 152.5 mm | bumps up; slots differ |
| Wall | 152.5 × 34.8 mm | bumps up |
| Rear panel | 112.6 × 34.8 mm | |
| Coupon | 34 × 107 mm | |
| 2.5" adapter | 143.5 × 101.6 mm, 12 mm tall | caddy-pin holes are teardrops; the drive pins are small horizontal protrusions |
| Foot | 24 mm across flats, 14 mm tall | pins up |
| Width joiner | 152.5 × 112.6 (1) or 56.3 mm (0.5), 2.8 mm | |
| Height joiner | 152.5 × 104.4 (3), 34.8 (1) or 17.4 mm (0.5), 2.8 mm | |

## Verification

`scripts/check.sh` proves, by boolean intersection in OpenSCAD:

- the walls' and rear panel's tabs sit in their slots without overlap, and a
  wall or panel shifted 1 mm hits plate or wall material (the tabs engage);
- the rear panel clears the drive and its connectors, and the bezel seats on
  the bay's front face (a bay pushed 1 mm forward hits it);
- the caddy with a drive sits inside the bay touching only where the bezel
  seats and where the preloaded lock bumps bear on their slots' front edges;
  the drive touches the caddy only on the floor (pins are inside the holes);
- the push tab clears the mated SATA plugs, and every part of the tray that
  ends up behind the rear panel passes through the panel's open corner on
  the way in;
- the seated caddy pulled 1 mm out hits the lock slots; while sliding in,
  with the bumps pressed flat, it clears the bay; the bumps' track from the
  bay's front edge to the slot is solid plate;
- stacked and side-by-side neighbours touch only on their faces, and a
  neighbour shifted 1 mm along the bay hits the bumps (they sit in open
  cells of the neighbour's part);
- in a 2 × 2 array with a caddy and drive in every bay, no loaded unit
  overlaps any other, including the diagonals, and a loaded caddy never
  reaches a neighbour's bumps;
- accessories (`check.sh acc`): the 2.5" adapter sits in the caddy and the
  2.5" drive in the adapter, its plugs pass the rear panel, and each is held
  by the pins; the feet sit in the bottom plate's cells and hold; width and
  height joiners sit between their bays, a 0.5 + 1 + 0.5 run fits both
  ways, its dovetails lock, and a joiner shifted 1 mm hits the bumps.

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
grazes a sharp corner, and passes. Pins are left off the tray for this
check: a horizontal cylinder sliced near its tangent is
always thin.

The reference drives (`scad/hdd.scad`, `scad/hdd25.scad`) carry a SATA
device plug to the SATA-IO layout, horizontal L-shaped tongue at the bottom
of the connector face, 7-contact signal segment nearest the drive's edge,
15-contact power segment inboard, 1.27 mm pitch, in a pocket. A separate
model, `scad/sata_plugs.scad`, holds the mated data and power cable plugs,
and a check proves they pass through the rear panel's cutout. The
connector's position is from SFF-8323: the blade starts 13.43 mm from the
drive's edge (dimension A13) and sits 3.5 mm up from the bottom (A7).
SFF-8223 gives the same two numbers for 2.5" drives. The edge is the +y one:
seen from behind with the label up, the connector is at the left, data plug
outermost. A real drive shows this; the first model had it mirrored ([ADR
0010](adr/0010-sata-connector-on-the-plus-y-side.md)). Segment lengths and
pocket depth are nominal, so the cutout should still be confirmed against a
real drive before printing many rear panels.

## First print

The first test print found:

1. The rear panel was loose in the walls: the side tab sat in a slot 2.4 mm
   taller than itself, slack the old lifted-wall assembly needed. Now the
   walls go onto the panel first and the slot fits the tab exactly.
2. The caddy never clicked into the bay: the detent bumps on the side finger
   barely reached past the slide clearance and the finger yielded inward.
   Now a leaf spring on each wall's top edge locks into the top plate.
3. The bezel tab slots, the long floor slot above all, were too loose to
   hold without glue. Now 0.08 mm a side across the wall tabs and 0.05 mm
   across the floor tab.
4. The rear panel's plate slots were too loose. Now 0.08 mm a side.

See [ADR 0005](adr/0005-top-edge-spring-lock-grooved-rear-panel.md).

After the print, the bezel's handle was replaced by a finger notch, so it
prints as a flat plate; see
[ADR 0006](adr/0006-bezel-finger-notch-instead-of-handle.md).

## What the next print has to answer

1. Whether the tighter friction fits (bezel tabs, rear panel) press home by
   hand and hold without glue.
2. Spring lock: click, hold and release force, and whether the 54 mm slit
   bridges cleanly in the chosen filament.
3. Whether the bezel notch gives enough grip to pull the caddy out against
   the spring lock.
4. Drive in caddy, still untested: finger stiffness at 1.5 % strain, and
   whether 2.6 mm pins seat in the tapped holes of the drives on hand.
5. Fit of the 5.6 mm bumps in the 6.0 mm cells; one parameter.
6. Rigidity of a loaded 2 × 2 block located by bumps alone; if it racks,
   glue the bumps.
7. Whether a drive goes into a caddy with its bezel on, under the bezel's
   lip, by flexing the bezel, and whether the lip holds the top plate up.
8. The rear panel's open corner on the +y side against the real drive's
   plugs ([ADR 0010](adr/0010-sata-connector-on-the-plus-y-side.md)).

## Open questions

- None at the moment.
