// Stackable 3.5" disk bay — shared parameters.
// All parts share one coordinate frame:
//   x: rear (connector face of the drive, x = 0) -> front (bezel)
//   y: width, centred on 0
//   z: 0 = underside of the caddy floor (= top of the bay floor)
// Units: mm.

$fn = $preview ? 32 : 72;

// ---------------------------------------------------------------- 3.5" drive
// SFF-8301 envelope and side-hole positions.
hdd_w = 101.6;
hdd_l = 147.0;                 // max; short drives are fine, they just sit deeper
hdd_h = 26.1;                  // max; 20.2 mm drives also fit
hdd_side_hole_z = 6.35;        // above the drive's bottom face
hdd_side_hole_x = [28.5, 130.1]; // from the connector face
hdd_hole_minor_d = 2.8;        // 6-32 UNC tapped hole, thread minor diameter

// ---- SATA device plug (SATA-IO internal device plug, nominal) -----------
// Shared by the drive model and the cable-plug model.
sata_pitch        = 1.27;
sata_sig_pins     = 7;
sata_pwr_pins     = 15;
sata_sig_l        = 10.4;              // signal segment
sata_key_l        = 2.4;               // gap between segments
sata_pwr_l        = 20.6;              // power segment
sata_edge_off     = 6.4;               // signal segment's outer edge from the drive's -y edge
sata_tongue_t     = 1.6;               // blade thickness
sata_tongue_z     = 2.6;               // blade underside above the drive's bottom
sata_tongue_depth = 6.0;               // how far the blade reaches into the pocket
sata_pocket_h     = 9.0;
sata_pocket_d     = 6.5;               // pocket depth into the drive from the connector face
sata_pocket_pad   = 1.5;               // pocket wider than the tongue each side

sata_y0  = -hdd_w/2 + sata_edge_off;                       // -44.4, outer edge of the signal segment
sata_l   = sata_sig_l + sata_key_l + sata_pwr_l;           // 33.4


// ---------------------------------------------------------------- clearances
clr       = 0.3;   // drive <-> caddy, per side
slide_clr = 0.4;   // caddy <-> bay, per side

// ---------------------------------------------------------------- caddy
c_floor      = 2.0;
c_wall       = 2.4;
c_wall_h     = 25;   // wall height above the floor top (room for the diagonal fingers)
c_rear_gap   = 3;    // caddy starts here so the connector face stays clear
c_front_gap  = 0.5;  // drive front face <-> bezel
c_frame      = 6;    // solid frame around the honeycomb floor

c_in_w   = hdd_w + 2*clr;             // 102.2
c_w      = c_in_w + 2*c_wall;         // 107.0
c_body_l = hdd_l + c_front_gap;       // 147.5 — walls run 0 .. c_body_l
c_wall_top = c_floor + c_wall_h;      // 27.0
pin_z    = c_floor + hdd_side_hole_z; // 8.35
sata_z0  = c_floor + sata_tongue_z;   // tongue underside in the shared frame

// pins that engage the drive's side holes
pin_d    = 2.6;          // < 2.8 minor diameter
pin_len  = clr + 1.8;    // protrusion from the wall's inner face (1.8 mm into the hole)
pin_tip  = 1.2;          // conical tip length (cams the finger open)

// Cantilever fingers carrying the +y pins. They run at 45 degrees from the
// wall's top rim down to the pin, so every slot face is a 45-degree overhang
// and the tray prints flat with no support. A horizontal finger would float
// over its lower slot on its first layer.
finger_angle = 45;       // from horizontal; 45 is the shallowest that prints unsupported
finger_w   = 6;          // beam width, in the plane of the wall
finger_t   = 1.6;        // beam thickness (the outer face is recessed from the 2.4 wall)
finger_gap = 1.2;        // through-slot around each finger
finger_rim = 3;          // wall left above the slot's highest point (its corner at the root,
                         // which sits (finger_w/2 + finger_gap) * cos(angle) above the beam's centreline)
finger_tip_flat = 1.6;   // the beam's lowest corner is cut flat this wide: its first layer is
                         // a bead four lines wide and 1.6 mm long, not a knife edge
// [pin x, direction the root goes along x]
fingers = [ [hdd_side_hole_x[0], +1],
            [hdd_side_hole_x[1], -1] ];

// Detent finger on the -y wall that clicks the caddy into the bay; same
// shape. It carries TWO bumps, one lattice pitch apart along the 45-degree
// beam, so while the caddy slides past the bay wall's honeycomb one bump is
// always on a web when the other is over a cell: no false clicks until both
// reach their holes.
detent_x  = 97;
detent_dir = -1;
detent_d  = 3.0;         // bump sphere
detent_out = 1.0;        // bump protrusion beyond the wall
detent_hole_d = 4.5;     // matching holes in the bay wall

// bezel and handle. The bezel is a separate flat print (front face down) that
// joins the tray by tabs through slots, so neither part needs support.
bezel_t      = 2;                     // a flat plate the size of the bay's front face
bz_tab_h     = 8;                     // wall tab height (z), centred on the finger height
bz_tab_w     = 60;                    // floor tab width (y)
bz_tab_clr   = 0.15;                  // per side
handle_w     = 44;       // between post centres
handle_depth = 6;        // how far the bar stands off the bezel
handle_bar_h = 6;
handle_bar_t = 3;
handle_post  = 4;

// ---------------------------------------------------------------- bay
// Four flat parts: two identical plates (top/bottom), two identical walls,
// joined by tabs through slots. Every part prints flat with no supports.
b_t     = 2.4;                        // plate thickness
b_wall  = 2.4;                        // wall thickness
b_in_w  = c_w + 2*slide_clr;          // 107.8
b_in_h  = c_floor + hdd_h + 1.9;      // 30.0
b_w     = b_in_w + 2*b_wall;          // 112.6
b_h     = b_in_h + 2*b_t;             // 34.8
b_l     = c_body_l;                   // 147.5 — front face; bezel sits outside
b_x0    = -5;                         // rear face; room for the rear panel behind the drive
b_xc    = (b_x0 + b_l) / 2;           // part centre along x (patterns are symmetric about it)
b_z0    = -b_t;                       // bottom of the bay
b_z1    = b_in_h + b_t;               // top of the bay

// wall tabs through the plates
tab_len  = 14;
tab_x    = [b_xc - 54, b_xc, b_xc + 54];  // symmetric so both walls are one part
tab_clr  = 0.15;                      // per side, tab in slot

// rear panel: semi-closed back, tabs into the plates and walls, SATA cutout
rear_t     = 2.4;
rear_x     = b_x0 + 1.4;              // panel spans rear_x .. rear_x + rear_t; 1.2 mm clear of the drive
rear_tab   = 12;                      // tab length along the panel edges
rear_tab_y = [12, 40];                // tabs into the plates, top and bottom edge (the -y
                                      // half of the bottom edge is the SATA notch)
rear_slot_y = [-40, -12, 12, 40];     // the plate carries both mirror images, so one plate
                                      // serves top (turned over) and bottom
rear_tab_z = 19;                      // tab into each wall, above the SATA notch
// the wall gets this slot at BOTH ends so it stays end-symmetric (one part
// serves left and right); the unused front slot hides under the bezel
wall_slot_x = [rear_x + rear_t/2, b_x0 + b_l - (rear_x + rear_t/2)];
// Assembly: the wall slides in sideways while lifted one plate thickness,
// so its panel slot extends that far below the tab's resting place.
wall_panel_slot_h = rear_tab + b_t;
rear_clr   = 0.2;                     // panel body to walls/plates
// SATA notch: open at the bottom and at the -y side, up to just under the wall
// tab. A closed window left slivers that were weaker than no material.
sata_notch_y = 0;                     // notch runs from the -y edge to here
sata_notch_z = 12.5;                  // and from the bottom edge up to here


// honeycomb vents (hex across-flats `hex_cell`, web `hex_web`)
hex_cell = 6.0;                       // plates and rear panel
hex_web  = 1.8;
w_hex_cell = hex_cell;                // walls share the 6 mm lattice so their bumps can use it too
w_hex_web  = hex_web;
b_vent_rim = 6;                       // solid rim kept along every plate edge
w_vent_rim = 4;                       // walls
b_keep_margin = 1.5;                  // web left between a cell and a bump/slot/hole
c_hex_cell = hex_cell;                // caddy floor and walls: same lattice as the bay, so the
c_hex_web  = hex_web;                 // cells line up and air goes straight through both
c_wall_rim = 3;                       // solid rim round the caddy wall honeycomb
bz_hex_cell = 4.0;                    // bezel intake
bz_hex_web  = 1.4;

// ---------------------------------------------------------------- joining bays
// No extra parts. Every bump sits on its part's own honeycomb lattice and is
// placed so that, when the identical part is turned for the opposite face
// (plate turned over, wall turned end for end), each bump of one bay arrives
// in an OPEN cell of the neighbour's part.
hex_dx = hex_cell + hex_web;                 // lattice pitch along x
hex_dy = hex_dx * sqrt(3) / 2;               // row pitch along y
// plate cell (i, j): column i, row j, in the shared frame (rows alternate by half a pitch)
function plate_cell(i, j) = [b_xc + i * hex_dx + (j % 2 == 0 ? 0 : hex_dx / 2), j * hex_dy];
plate_bump_cells = [[-6, 6], [6, 6], [-4, -6], [8, -6]];   // +y pair, then -y pair shifted 2 cells
plate_bumps = [for (c = plate_bump_cells) plate_cell(c[0], c[1])];
plate_bump_af = hex_cell - 0.4;              // 5.6 across flats drops into a 6.0 cell, 0.2 a side
bump_h   = 1.4;                              // bump height, plates and walls

// wall bumps: the same trick. The right wall is the left wall turned end for
// end (x -> 2*b_xc - x), which maps lattice column i to -i-1 on the odd rows
// the bumps sit on. Bumps at columns -8 and +4 land at +7 and -5: three cells
// from any pad, so open. Rows +1/-1 keep row 0 free for venting.
function wall_cell(i, j) = [b_xc + i * hex_dx + (j % 2 == 0 ? 0 : hex_dx / 2), b_in_h/2 + j * hex_dy];
wall_bump_cells = [[-8, 1], [4, 1], [-8, -1], [4, -1]];
wall_bumps = [for (c = wall_bump_cells) wall_cell(c[0], c[1])];
wall_bump_af = plate_bump_af;

// pitches (bays are identical, faces touch, bumps inside the neighbour's cells)
pitch_z = b_h;                               // 34.8
pitch_y = b_w;                               // 112.6

// ---------------------------------------------------------------- orientation marks
// A groove runs round the outside of both walls and the rear panel, low
// down: when the three grooves line up, every part is the right way up.
// The plates carry an engraved arrow on the bump face, pointing to the
// front; the bottom plate's arrow has a bar under it.
groove_z = 1.8;                       // height above the bay's inner floor
groove_w = 1.0;
groove_d = 0.6;                       // engraving depth (all marks)
label_x  = b_l - 15;                  // centre of the plate mark
mark_size = 5;                        // arrow half-size

// the two detent bumps: at the finger tip and one lattice pitch up the beam
detent_pts = [[detent_x, pin_z], [detent_x + detent_dir * hex_dx, pin_z + hex_dx]];
