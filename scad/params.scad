// Stackable 3.5" disk bay — shared parameters.
// All parts share one coordinate frame:
//   x: rear (connector face of the drive, x = 0) -> front (bezel)
//   y: width, centred on 0
//   z: 0 = underside of the caddy floor (= top of the bay floor)
// Units: mm.

$fn = $preview ? 32 : 72;

// ---------------------------------------------------------------- 3.5" drive
// SFF-8301 envelope and mounting holes, all measured from the connector end.
hdd_w = 101.6;                 // A3
hdd_l = 147.0;                 // A2 max; short drives are fine, they just sit deeper
hdd_h = 26.1;                  // A1 max; 20.2 mm drives also fit
hdd_side_hole_z = 6.35;        // A10, above the drive's bottom face
hdd_side_hole_x = [28.5, 130.1]; // A8, A8 + A9
hdd_bot_hole_x = [41.28, 85.73, 117.48]; // A7, A7 + A6, A7 + A13
hdd_bot_hole_y = 95.25/2;      // A4, centred
hdd_hole_minor_d = 2.8;        // 6-32 UNC tapped hole, thread minor diameter
hdd_hole_depth = 3.56;         // the drive takes this much fastener penetration

// ---- SATA device plug (SATA-IO internal device plug, nominal) -----------
// Shared by the drive model and the cable-plug model.
sata_pitch        = 1.27;
sata_sig_pins     = 7;
sata_pwr_pins     = 15;
sata_sig_l        = 10.4;              // signal segment
sata_key_l        = 2.4;               // gap between segments
sata_pwr_l        = 20.6;              // power segment
sata_edge_off     = 13.43;             // signal segment's outer edge (datum B) from the drive's +y
                                      // edge (datum Y): SFF-8323 A13 for 3.5", SFF-8223 A13 for 2.5",
                                      // the same on both so one backplane takes either. Viewed from
                                      // the rear, label up, that edge is on the left (checked on a
                                      // real drive); the segments run from it toward -y
sata_tongue_t     = 1.6;               // blade thickness
sata_tongue_z     = 2.6;               // blade underside above the drive's bottom
sata_tongue_depth = 6.0;               // how far the blade reaches into the pocket
sata_pocket_h     = 9.0;
sata_pocket_d     = 6.5;               // pocket depth into the drive from the connector face
sata_pocket_pad   = 1.5;               // pocket wider than the tongue each side

sata_y0  = hdd_w/2 - sata_edge_off;                        // 37.37, outer edge of the signal segment
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

// bezel. A flat honeycomb plate, printed front face down, that joins the
// tray by tabs through slots, so neither part needs support. No handle and
// no notch: the caddy is pulled by the tray's pull ledge, under the bezel.
bezel_t      = 2;                     // a flat plate the size of the bay's front face
bz_rim       = 2;                     // solid rim round the honeycomb, > 0.8 (two perimeters)
bz_tab_h     = 8;                     // wall tab height (z)
bz_tab_splay = 4;                     // deg: each wall tab's outer face leans out toward the bezel's
                                      // face, so the bezel snaps over it (0.14 mm) and is locked on
bz_tab_w     = 60;                    // floor tab width (y)
bz_tab_clr   = 0.08;                  // on a wall tab's inner face; none on its sloped outer face
bz_floor_clr = 0.05;                  // per side across the floor tab's thickness (the long slot)
bz_end_clr   = 0.15;                  // per side along a tab's length: no grip there, room for elephant foot

// ---------------------------------------------------------------- bay
// Four flat parts: two identical plates (top/bottom), two identical walls,
// joined by tabs through slots. Every part prints flat with no supports.
b_t     = 2.4;                        // plate thickness
b_wall  = 2.4;                        // wall thickness
b_in_w  = c_w + 2*slide_clr;          // 107.8
b_in_h  = c_floor + hdd_h + 1.9;      // 30.0
b_w     = b_in_w + 2*b_wall;          // 112.6
b_h     = b_in_h + 2*b_t;             // 34.8
bz_tab_z = [pin_z, b_in_h - pin_z];  // bezel wall tabs, two a wall, centres: at the finger height and
                                      // as far under the bay's top, so the bezel is held at its top too
b_l     = c_body_l;                   // 147.5 — front face; bezel sits outside
b_x0    = -5;                         // rear face; room for the rear panel behind the drive
b_xc    = (b_x0 + b_l) / 2;           // part centre along x (patterns are symmetric about it)
b_z0    = -b_t;                       // bottom of the bay
b_z1    = b_in_h + b_t;               // top of the bay

// corner reliefs. A printed inside corner comes out rounded, about half a
// line wide, and the mating part's sharp corner then stands off it: the
// faces either side do not close without cleaning up. So every inside
// corner a mating corner seats in gets a round pocket this radius: a
// T-bone, tangent to the face that keeps the fit and this deep into the
// other, or centred on the corner where it is acute (the joiners).
relief_r = 0.5;

// wall tabs into the plates: four long ones, for grip. Symmetric about
// b_xc so both walls are one part, and clear of the top plate's lock slots
// (x 80 to 85) and their mirror image. Each plate's notch is open at its
// edge (a box corner), so each tab end is dovetailed on both free axes:
//   flare: wider toward the plate's outer face, so the wall cannot lift off
//          the plate. The critical load, so steep.
//   splay: wider toward the wall's inner face, so the wall cannot slide out
//          off the plate's edge. The wall slides in sideways past it, so it
//          is shallow: b_wall * tan(tab_splay), 0.06 mm a tab end, a light
//          snap. At 4 degrees (0.17 mm) with the 15-degree flare, the
//          walls of the third print would not go in (ADR 0016).
tab_len  = 22;                        // along the wall's outer face, where the tab leaves the wall
tab_x    = [b_xc - 60, b_xc - 27, b_xc + 27, b_xc + 60];
tab_flare = 15;                       // deg
tab_splay = 1.5;                      // deg
tab_reach = b_t * tan(tab_flare) + b_wall * tan(tab_splay);   // 0.71, the tab end's widest point past tab_len/2
tab_clr  = 0;                         // per end, on the dovetail faces: none. The shallow splay turns play
                                      // into slop: 0.05 mm would let a wall slide out 1.9 mm
tab_fit_clr = 0.08;                   // per side across the wall's thickness, against the notch's inner face

// rear panel: semi-closed back, tabs into the plates and walls, SATA cutout
rear_t     = 2.4;
rear_x     = b_x0 + 1.4;              // panel spans rear_x .. rear_x + rear_t; 1.2 mm clear of the drive
rear_tab   = 12;                      // tab length along the panel edges
rear_tab_y_top = [-40, -12, 12, 40];  // tabs into the top plate, along the full top edge
rear_tab_y_bot = [-40, -12];          // tabs into the bottom plate: the +y half of the bottom
                                      // edge is the SATA notch
// slots for those tabs, in each plate's own frame: the top plate takes its
// four as they are; the bottom plate is turned over (y mirrored), so its two
// are the mirror image. Each print carries only the slots it uses.
function rear_slot_y(kind) = kind == "bottom" ? [for (y = rear_tab_y_bot) -y] : rear_tab_y_top;
rear_fit_clr = 0.08;                  // per side, every rear panel tab in its slot: a friction
                                      // fit, tighter than tab_clr
// A tab on each side edge goes through a slot in each wall, as in v0.1.0,
// but the slot fits the tab exactly: the walls slide onto the panel's side
// tabs first, and the panel and walls then go down into the bottom plate
// together, so no slot needs room for a second direction of travel.
rear_tab_z = 19;                      // side tab centre, above the SATA notch (13 to 25)
// the wall gets this slot at BOTH ends so it stays end-symmetric (one part
// serves left and right); the unused front slot sits behind the bezel
wall_slot_x = [rear_x + rear_t/2, b_x0 + b_l - (rear_x + rear_t/2)];
rear_clr   = 0.2;                     // panel body to walls/plates
// SATA notch: open at the bottom and at the +y side, up to just under the wall
// tab. A closed window left slivers that were weaker than no material.
sata_notch_y = -3;                    // notch runs from the +y edge to here: past the power plug
                                      // of a 2.5" drive in the adapter, 2.4 mm further inboard
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
bz_hex_cell = hex_cell;               // bezel intake: the same cells as everywhere else
bz_hex_web  = hex_web;

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
// The plates need no mark: their slots tell top from bottom and front
// from back.
groove_z = 1.8;                       // height above the bay's inner floor
groove_w = 1.0;
groove_d = 0.6;                       // engraving depth

// ---------------------------------------------------------------- caddy spring lock
// Spring lock on the top edge of both caddy walls, clicking into the bay's
// top plate. A leaf spring anchored at both ends: a slit under the wall's
// top rim frees a beam, and a ramped bump on the beam's middle rides on the
// top plate's underside and drops into a slot in it when the caddy seats.
// The bump runs under the plate's solid rim (outside its honeycomb), so
// there is nothing to click into on the way. Anchored at both ends, the
// beam's underside prints as a bridge; a cantilever's would float.
// The spring sits between the +y wall's finger slots (x 46..112).
sp_x       = [56, 110];  // slit span along x: the beam's free length
sp_rise    = 1.5;        // beam top above the wall rim (a low hump over the slit)
sp_h       = 2.0;        // beam depth (z)
sp_lock    = 1.25;       // how far a relaxed bump would reach into the top plate
sp_gap     = sp_lock + 0.6;  // slit height: room for the deflection plus bridge sag
sp_preload = 0.4;        // deflection left when seated: keeps the caddy down and the bezel home
sp_flat    = 1.2;        // flat on the bump's crest
sp_lead    = 30;         // rear ramp (meets the plate's front edge going in), from horizontal
sp_hold    = 45;         // front ramp (bears on the slot's front edge), from horizontal
sp_hole_clr = 0.3;       // slot clearance behind the bump along x
sp_hump_ramp = 15;       // the hump's end ramps, from horizontal
sp_hump_r  = 6;          // radius on the hump's ramp corners
sp_fillet_r = 1.5;       // fillet where the bump's ramps meet the hump
sp_crest_r = 1.0;        // radius on the bump's crest corners
sp_top     = c_wall_top + sp_rise;         // 28.5, beam top at rest
sp_bump_h  = b_in_h - sp_top + sp_lock;    // 2.75, crest at 31.25 relaxed, 30.0 while sliding
sp_bump_x  = (sp_x[0] + sp_x[1]) / 2;      // crest centre
sp_slit_z  = sp_top - sp_h - sp_gap;       // slit bottom
// slot in the top plate: its front edge sits where the 45-degree front ramp
// meets the plate's underside with sp_preload of deflection left, so the
// ramp bears on that edge and pulls the bezel onto the bay's front face
sp_hole_x  = [sp_bump_x - sp_flat/2 - (sp_lock - sp_preload) / tan(sp_lead) - sp_hole_clr,
              sp_bump_x + sp_flat/2 + (sp_lock - sp_preload) / tan(sp_hold)];
// across: from the bump's innermost reach (caddy pushed to the far wall) to
// the bay wall's inner face, so the slot never runs under the wall's foot
sp_hole_y  = [c_in_w/2 - slide_clr - 0.15, b_in_w/2];

// ---------------------------------------------------------------- bezel lip
// A short lip on the bezel's back face, at the top, reaches under the top
// plate's solid front rim when the caddy is seated and props the plate up
// in the middle, where it sags most, and nowhere else. Near the edges the
// caddy walls' front posts hold the plate instead. It reaches 1.5 mm over
// the drive's front edge; the drive passes under it by flexing the bezel.
bz_lip_w  = 10;                               // along y, centred
bz_lip_y1 = bz_lip_w / 2;                     // +y end
bz_lip_y0 = bz_lip_y1 - bz_lip_w;             // -y end
bz_lip_d  = 2;                                // into the bay, on the plate's solid rim
bz_lip_t  = 1.4;                              // its underside 0.3 above a 26.1 mm drive's top
bz_lip_top = b_in_h - 0.2;                    // 0.2 under the plate: catches a sagging plate,
                                              // never binds in a bay printed a little short
bz_lip_c  = 0.5;                              // lead-in chamfer on the rear top edge (0.9 left at the tip)

// ---------------------------------------------------------------- caddy wall front posts
// The front end of each caddy wall rises nearly to the full inner height of
// the bay, 0.2 under the top plate's underside, so the plate is held up
// near its edges as well as by the bezel lip in the middle. A 45-degree ramp
// at the post's rear end lifts a sagging plate as the caddy goes in.
c_post_l = 8;                                 // flat top, back from the wall's front end
c_post_h = b_in_h - 0.2;                      // 29.8: catches a sagging plate, never binds in
                                              // a bay printed a little short

// ---------------------------------------------------------------- caddy push tab
// A floor-level tongue in the middle of the tray's rear edge reaches back
// through the rear panel's open SATA corner and just past the bay's rear
// face, so the caddy can be pushed out from behind without pulling on the
// bezel joint. Pushed near its centre line, the caddy slides straight; a
// push at a corner racked it in the bay. It is the floor's thickness and
// runs under the SATA plugs (their housings start 2.4 mm up). It starts
// as close to the centre line as the panel's open corner allows.
push_x1     = b_x0 - 2;          // rear end, 2 mm proud of the bay's rear face
push_y0     = sata_notch_y + 0.8; // -y edge: clear of the corner's edge with the caddy's side play
push_w      = 10;                // width (y): -2.2 .. 7.8, its centre 2.8 mm off the centre line
push_r      = 3;                 // plan radius on the two rear corners
push_root_r = 3;                 // plan fillet where it leaves the floor's rear edge
push_nose   = 1.5;               // its top rear edge rounded down toward the bed

// ================================================================ accessories
// ---------------------------------------------------------------- 2.5" drive (SFF-8201)
h25_w = 69.85;                        // A4
h25_l = 100.45;                       // A6 max
h25_h = 9.5;                          // A1; the adapter takes 5 to 15 mm drives
h25_hole_x = [14.0, 90.6];            // side holes from the connector end (A52, A53)
h25_hole_z = 3.0;                     // above the bottom (A23)
h25_hole_minor_d = 2.46;              // M3 thread minor diameter
h25_bot_hole_x = [14.0, 90.6];        // bottom holes from the connector end (A50, A51)
h25_bot_hole_y = [4.07, 4.07 + 61.72];  // from the +y edge (A28, A28 + A29)

// ---------------------------------------------------------------- 2.5" adapter
// The adapter takes the place of a 3.5" drive in the caddy: 101.6 wide, holes
// for the caddy's four pins. The 2.5" drive sits in its +y rear corner, on the
// caddy floor with its connector face at x = 0. SATA puts the connector at the
// same place relative to the +y edge and the bottom on both sizes, so the
// connector lands where a 3.5" drive's would, moved inboard only by the strip
// that carries the caddy's finger pins.
ad_strip_t = 2.2;                     // +y strip between the caddy wall and the drive
ad_clr     = 0.2;                     // per side, 2.5" drive in the adapter
ad_h       = 12;                      // wall height above the caddy floor
ad_wall    = 2.4;
ad_base    = 2.0;                     // base plate where there is no drive (front, -y side)
ad_len     = hdd_l - 0.5;             // 146.5, like a 3.5" drive
ad_pin_d   = 2.3;                     // pins into the 2.5" side holes (M3, minor 2.46)
ad_pin_len = 1.5;                     // reach into the hole
ad_hole_d  = pin_d + 0.3;             // holes for the caddy's pins
h25_y1 = hdd_w/2 - ad_strip_t - ad_clr;            // the 2.5" drive's +y (connector) edge
h25_dy = h25_y1 - hdd_w/2;                         // its connector, relative to a 3.5" drive's
h25_x1 = h25_l + 0.5;                              // front of the 2.5" drive pocket
ad_in_y = h25_y1 - h25_w - ad_clr;                 // inner face of the -y rail

// ---------------------------------------------------------------- pull ledge
// The front counterpart of the push tab: the middle of the floor tab, which
// passes through the bezel's bottom slot, runs on past the bezel's face as a
// ledge. A slot through it takes a fingernail or fingertip, and the pull
// goes into the tray's floor, not through the bezel joint. It also locks
// the bezel on: just in front of the bezel's face, where it is still almost
// the floor tab's full width, it stands pull_barb taller than the floor, on a
// short ramp; the rest of it is flat, and narrows on a rounded taper to the
// front end. The
// bezel's slot rides up the ramp as the bezel is pressed on, snaps down
// behind the step, and can then not slide forward off the tray.
pull_x      = 10;                // how far it stands proud of the bezel's face
pull_w      = 30;                // width (y) at its front end, centred
pull_taper  = 8;                 // it narrows from the floor tab's width at the bezel's face to pull_w over this length
pull_r      = 3;                 // plan radius on its convex corners
pull_root_r = 6;                 // plan fillet where the taper meets the straight front end
pull_barb_w = 44;                // the step's width (y), centred: ends square, inside the taper
pull_barb   = 0.4;               // step above the floor's top: what the bezel's slot snaps over
pull_barb_gap = 0.1;             // the step's face, in front of the bezel's face
pull_ramp   = 2.4;               // the ramp's length, from the step down to the floor's top (~10 degrees)
pull_hole   = [4, 18];           // grip slot through the ledge (x, y), round ends
pull_hole_x = 3;                 // its rear edge, from the bezel's face: clear of the ramp
pull_chamfer = 0.5;              // 45-degree chamfer on its top front edge

// ---------------------------------------------------------------- feet
// A foot locks into three neighbouring open cells of a bottom plate with three
// hex pins, the same shape as the bumps, and lifts the bay off the surface.
foot_h     = 12;                      // lift
foot_af    = 24;                      // body, across flats
foot_pin_h = b_t - 0.4;               // stays inside the plate, clear of the caddy floor
// cells (i, j), j even: pins in (i, j), (i + 1, j) and (i + 1/2, j + 1)
foot_cells = [[-7, 2], [6, 2], [-7, -4], [6, -4]];

// ---------------------------------------------------------------- joiner plates
// Sandwiched between two bays: bay, joiner, bay. Twice a bump's height thick,
// so each bay's bumps drop into holes from its own side. Sizes come in half
// bays; pieces lock edge to edge with dovetails so 0.5 + 1 + 0.5 lays a
// joint two bays long whose seams fall mid-bay, like bricks.
jn_t     = 2 * bump_h;                // 2.8
jn_dt    = [-15, 47];                 // dovetail tabs on the +v edge, x from the bay centre; the
                                      // -v edge takes them mirrored, so a piece turned round mates
jn_dt_neck = 8; jn_dt_head = 12; jn_dt_depth = 5;
jn_dt_clr = 0.1;                      // per side
jn_edge  = 1.5;                       // web kept along every edge and round the dovetails
// The plate is honeycomb all over, on the lattice of the bay half it lies
// against, so every bump finds a cell. Zones are half a bay: wide for the
// width joiners (between stacked bays), high for the height joiners
// (between bays side by side). A half piece is cut for the half on the near
// side of a bay's centre line and locks on its centre-line edge; turned
// round it serves the other half. A full piece straddles the seam between
// two bays, as in a run. Columns (width) or rows (height) of a block touch
// directly: use one joiner direction per block.
jn_w_zone = b_w / 2;
jn_h_zone = b_h / 2;
