// Toolless caddy: drive drops in, pins engage the side holes, no screws.
// Two flat prints: the tray (floor, walls, diagonal fingers, pins) on its
// floor, and the bezel (a honeycomb plate) front face down. Tabs on the tray's
// walls and floor pass through slots in the bezel; press fit, glue optional.
include <lib.scad>

// Honeycomb floor inside a solid frame: air reaches the drive's underside
// (where the PCB and motor sit) and the webs keep the tray stiff in torsion.
module caddy_floor() {
    xl = c_body_l - c_rear_gap;
    fc = c_rear_gap + xl/2;                       // this field's centre
    difference() {
        box([c_rear_gap, -c_w/2, 0], [c_body_l, c_w/2, c_floor]);
        // phase the lattice to the bay plate's (centred on b_xc) so the
        // floor's cells sit over the plate's cells when the caddy is in
        translate([fc, 0, c_floor/2])
            honeycomb_cut([xl - 2*c_frame, c_in_w - 2*c_frame], c_floor + 2, c_hex_cell, c_hex_web,
                          [], [b_xc - fc, 0]);
    }
}

module wall_solid(s) {   // s = -1 (fixed pins) or +1 (fingers)
    y0 = s * c_in_w/2;
    box([c_rear_gap, y0, 0], [c_body_l, y0 + s*c_wall, c_wall_top]);
    wall_profile(s) wall_post2d();
}
// the wall's front end raised to the plate's underside, ramped at 45 degrees
// at its rear end; the profile reaches down into the wall so the two join
module wall_post2d() {
    x1 = c_body_l;  x0 = x1 - c_post_l;  rise = c_post_h - c_wall_top;
    polygon([[x0 - rise - 1, c_wall_top - 1], [x0 - rise, c_wall_top], [x0, c_post_h], [x1, c_post_h], [x1, c_wall_top - 1]]);
}

// ---- diagonal cantilever fingers -----------------------------------------
// 2D in the wall's plane (x, z). The beam runs from the tip centre at
// (xp, pin_z) up toward the rim at finger_angle, root direction `dir`.
// The slot round it reaches slot_half above the centreline; the rim is
// measured from there, where the slot's root corner comes closest to the top.
slot_half = finger_w/2 + finger_gap;
function finger_dz(zt)  = c_wall_top - finger_rim - slot_half * cos(finger_angle) - zt;   // rise, tip to root
function finger_len(zt) = finger_dz(zt) / sin(finger_angle);

module finger_beam2d(xp, zt, dir, extra = 0) {
    L = finger_len(zt);
    intersection() {
        translate([xp, zt]) rotate(dir > 0 ? finger_angle : 180 - finger_angle)
            translate([-finger_w/2, -finger_w/2]) square([L + finger_w/2 + extra, finger_w]);
        // cut the lowest corner flat: a corner pointing down starts as a point in the air
        apex = zt - finger_w/2 * (sin(finger_angle) + cos(finger_angle));
        translate([xp - 100, apex + finger_tip_flat/2]) square([200, 200]);
    }
}
// the through-slot: a ring round the beam, cut off beyond the root line
module finger_slot2d(xp, zt, dir) {
    L = finger_len(zt);
    intersection() {
        difference() { offset(delta = finger_gap) finger_beam2d(xp, zt, dir, 20); finger_beam2d(xp, zt, dir, 20); }
        translate([xp, zt]) rotate(dir > 0 ? finger_angle : 180 - finger_angle)
            translate([-20, -20]) square([20 + L, 40]);     // keep the slot only up to the root
    }
}
// extrude a 2D (x, z) profile through a wall at y0 (inner face), outward s
module through_wall(s, y0, depth = c_wall + 2) {
    translate([0, y0 + s * (depth - 1), 0]) rotate([90, 0, 0]) mirror([0, 0, s > 0 ? 0 : 1])
        linear_extrude(height = depth) children();
}

module finger_cuts(s, xp, zt, dir) {
    y0 = s * c_in_w/2;
    // the slot, through the wall
    through_wall(s, y0) finger_slot2d(xp, zt, dir);
    // thin the beam: recess its outer face so it flexes at 1.6 mm
    yo = s * c_w/2;
    translate([0, yo + s * 1, 0])                 // start 1 mm outside the outer face, cut inward
        rotate([90, 0, 0]) mirror([0, 0, s > 0 ? 0 : 1]) linear_extrude(height = (c_wall - finger_t) + 1)
            finger_beam2d(xp, zt, dir, 0);
}

module pin_fingers_cuts() { for (f = fingers) finger_cuts(1, f[0], pin_z, f[1]); }

// Service holes: once the pins are in a drive's holes the fingers are hard
// to lift out. One hex cell, the vents' shape and size, opens into each
// slot just beyond the finger's tip, at pin height, so a small screwdriver
// can get at the tip and pry it out. The cell sits on the lattice row at
// pin height, just past the slot's mitred tip corner: it overlaps that
// corner by service_overlap, so the hole and the slot are one opening, and
// stays clear of the beam. Along x it is placed from the finger, not on
// the lattice: the lattice is centred on the bay, so it moves whenever the
// bay's length does, and the fingers (at the drive's holes) do not.
service_overlap = 1.0;
function service_cell(f) = let(j = round((pin_z - b_in_h/2) / hex_dy))
    [f[0] - f[1] * (slot_half * sqrt(2) + c_hex_cell/2 - service_overlap), b_in_h/2 + j * hex_dy];
// The cell's flat side facing the finger meets the slot's 45-degree outer
// edges a little inside its corners, which would leave a small step of wall
// above and below. Each slanted edge is carried on to the slot edge instead,
// with a triangle back to the flat at pin height, so no step is left.
service_flat = 1.0;     // flat left where the wall wedges meet the hole, > 0.8 (two perimeters)
module service_hole2d(f) {
    c  = service_cell(f);
    tw = sign(f[0] - c[0]);                         // toward the finger along x
    h  = c_hex_cell / sqrt(3) / 2;                  // corner height above/below the centre
    xf = c[0] + tw * c_hex_cell/2;                  // the flat facing the finger
    dC = tw * (xf - (f[0] - tw * slot_half * sqrt(2)));   // slot's tip corner to that flat
    k  = tan(30);
    tu = max(0, (c[1] + h - pin_z - dC) / (1 + k));       // where the edges meet the slot
    tl = max(0, (pin_z - dC - c[1] + h) / (1 + k));
    pu = [xf + tw * tu, c[1] + h - tu * k];         // where the cell's edges meet the slot's
    pl = [xf + tw * tl, c[1] - h + tl * k];
    translate(c) rotate(30) circle(r = c_hex_cell / sqrt(3), $fn = 6);
    polygon([[xf, c[1] + h], pu, [xf, pin_z]]);
    polygon([[xf, c[1] - h], pl, [xf, pin_z]]);
    // The wall above and below each meeting point is a wedge whose tip
    // would print as layers thinner than two perimeters. Cut the tip off
    // where the wedge is service_flat wide, so it starts with a flat.
    dz = service_flat / (1 / k + 1);                // cell edge at 30 degrees, slot edge at 45
    for (sg = [1, -1]) let(p = sg > 0 ? pu : pl)
        polygon([p, [p[0] - tw * dz / k, p[1] + sg * dz], [p[0] + tw * dz, p[1] + sg * dz]]);
}
module service_holes() for (f = fingers) {
    c = service_cell(f);
    assert(abs(c[0] - f[0]) - c_hex_cell/2 > finger_w/2 * sqrt(2) + 0.1, "service hole would cut the finger");
    // grown by 0.01 so its edges overlap the slot's rather than coincide with them
    through_wall(1, c_in_w/2) offset(delta = 0.01) service_hole2d(f);
}

// ---- top-edge spring lock (both walls) ----------------------------------
// 2D in the wall's plane (x, z), extruded through wall s at its exact
// thickness. A low hump over the slit; the beam is the hump plus the rim
// between it and the slit, anchored at both ends.
module wall_profile(s, grow = 0) {
    translate([0, (s > 0 ? c_in_w/2 + c_wall : -c_in_w/2) + grow, 0]) rotate([90, 0, 0])
        linear_extrude(height = c_wall + 2*grow) children();
}
// The hump rises from the rim on shallow ramps, every corner rounded. The
// profile reaches beyond each ramp foot and well down into the wall, so the
// foot is a concave corner it can fillet and the offsets never erase it;
// everything at or below the rim is wall anyway, and the slit, finger and
// vent cuts come after.
module spring_hump2d() {
    a = sp_x[0] - 3;  b = sp_x[1] + 3;                        // crest of the hump, full height
    run = sp_rise / tan(sp_hump_ramp);  ext = run + 2 * sp_hump_r;
    zr = c_wall_top;  zb = c_wall_top - 3 * sp_hump_r;        // deep enough that the rounding offsets keep a core
    offset(r = sp_hump_r) offset(delta = -sp_hump_r)           // round the convex corners
    offset(r = -sp_hump_r) offset(delta = sp_hump_r)           // fillet the concave ones
        polygon([[a - ext, zb], [a - ext, zr], [a - run, zr], [a, sp_top], [b, sp_top],
                 [b + run, zr], [b + ext, zr], [b + ext, zb]]);
}
// slit with round ends; its top is the beam's underside, a bridge between the anchors
module spring_slit2d() {
    r = sp_gap / 2;
    hull() for (x = [sp_x[0] + r, sp_x[1] - r]) translate([x, sp_slit_z + r]) circle(r = r);
}
// the bump: a shallow lead-in ramp facing the rear, a steeper holding ramp
// facing the front, a short flat crest. `defl` lowers it by the beam's
// deflection, for views and checks of the caddy in the bay.
module spring_bump2d(defl = 0) {
    x0 = sp_bump_x - sp_flat/2;  x1 = sp_bump_x + sp_flat/2;
    zb = sp_top - defl - 0.01;   zt = sp_top + sp_bump_h - defl;
    polygon([[x0 - (zt - zb) / tan(sp_lead), zb], [x0, zt], [x1, zt], [x1 + (zt - zb) / tan(sp_hold), zb]]);
}
module spring_cuts() for (s = [-1, 1]) wall_profile(s, 1) spring_slit2d();
// hump and bump as one profile: fillets where the bump's ramps leave the
// hump, a rounded crest. Radii are small enough that the straight part of
// the holding ramp still meets the plate's slot edge (0.6 mm under the crest).
module spring_profile2d(defl = 0) {
    offset(r = sp_crest_r) offset(delta = -sp_crest_r)
    offset(r = -sp_fillet_r) offset(delta = sp_fillet_r)
        union() { spring_hump2d(); spring_bump2d(defl); }
}
module spring_bumps(defl = 0) for (s = [-1, 1]) wall_profile(s) spring_profile2d(defl);

// keep-out round a finger (field frame centred at cx, cz), slanted with the
// beam: the slot ring and the recess, which reach slot_half beside the beam
// and finger_w/2 past its root, plus the web margin. A box square to the
// wall would also blank the two triangles beside the slot.
function finger_keep(xp, zt, dir, cx, cz) = let(L = finger_len(zt), m = b_keep_margin)
    [xp - cx, zt - cz, dir > 0 ? finger_angle : 180 - finger_angle,
     -slot_half - m, L + finger_w/2 + m, -slot_half - m, slot_half + m];

// honeycomb in the caddy walls, on the bay wall's lattice so the cells line up
module wall_vents(s) {
    fc_x = (c_rear_gap + c_body_l) / 2;  fc_z = c_wall_top / 2;
    keep = concat(
        s > 0 ? [for (f = fingers) finger_keep(f[0], pin_z, f[1], fc_x, fc_z)] : [],
        s > 0 ? [for (f = fingers) let(c = service_cell(f), r = c_hex_cell / sqrt(3) + b_keep_margin)
                    [c[0] - r - fc_x, c[1] - r - fc_z, c[0] + r - fc_x, c[1] + r - fc_z]] : [],
        [[sp_x[0] - b_keep_margin - fc_x, sp_slit_z - b_keep_margin - fc_z, sp_x[1] + b_keep_margin - fc_x, 50]],
        s < 0 ? [for (x = hdd_side_hole_x) let(r = pin_d/2 + b_keep_margin)
                    [x - r - fc_x, pin_z - r - fc_z, x + r - fc_x, pin_z + r - fc_z]] : [],
        [[c_body_l - 8 - fc_x, -50, c_body_l + 5 - fc_x, 50]]);   // bezel tab zone
    translate([fc_x, s * (c_in_w/2 + c_wall/2), fc_z]) rotate([90, 0, 0])
        honeycomb_cut([c_body_l - c_rear_gap - 2*c_wall_rim, c_wall_top - 2*c_wall_rim], c_wall + 2,
                      c_hex_cell, c_hex_web, keep, [b_xc - fc_x, b_in_h/2 - fc_z]);
}

module pins() {
    // fixed pins on the -y wall, pointing +y into the drive
    for (x = hdd_side_hole_x)
        translate([x, -c_in_w/2 - 0.01, pin_z]) rotate([-90, 0, 0]) pin();
    // finger pins on the +y wall, pointing -y
    for (f = fingers)
        translate([f[0], c_in_w/2 + 0.01, pin_z]) rotate([90, 0, 0]) pin();
}

// wall tab plan (x, y) on the +y side, grown by c on its inner face and run
// on by e past both of the bezel's faces: the outer face leans out by
// bz_tab_splay toward the bezel's face, from the wall's outer face at the
// bezel's back face. The slot fits that face with no clearance: a shallow
// slope turns any play into slop, as on the bay's wall tabs.
module bz_tab2d(c = 0, e = 0) {
    x0 = c_body_l;  x1 = x0 + bezel_t;  t = tan(bz_tab_splay);  yo = c_w/2;
    polygon([[x0 - e, c_in_w/2 - c], [x1 + e, c_in_w/2 - c], [x1 + e, yo + (bezel_t + e) * t], [x0 - e, yo - e * t]]);
}
module bz_wall_tabs(c = 0, e = 0, ce = 0)
    for (s = [-1, 1], z = bz_tab_z) mirror([0, s < 0 ? 1 : 0, 0])
        translate([0, 0, z - bz_tab_h/2 - ce]) linear_extrude(height = bz_tab_h + 2 * ce) bz_tab2d(c, e);
// tabs on the tray that pass through the bezel plate
module bezel_tabs() {
    x0 = c_body_l;
    intersection() {   // wall tabs, starting just inside the wall's front end
        bz_wall_tabs(0, 0.01);
        translate([x0 - 0.01, -b_w, -1]) cube([bezel_t + 0.01, 2 * b_w, b_h + 2]);
    }
    box([x0 - 0.01, -bz_tab_w/2, 0], [x0 + bezel_t, bz_tab_w/2, c_floor]);   // floor tab
}
// pull ledge: plan (x, y) of the ledge and the floor tab's end it leaves,
// the floor tab's width at the bezel's face, tapering to pull_w, convex
// corners rounded, the taper's inside corners filleted; side profile (x, z):
// flat from the chamfered front end, then the barb's short ramp up to the step
module pull_plan2d() {
    xf = c_body_l + bezel_t;                       // the bezel's face
    x1 = xf + pull_x;                              // the front end
    w0 = bz_tab_w / 2;  w1 = pull_w / 2;  xt = xf + pull_taper;
    offset(r = -pull_root_r) offset(delta = pull_root_r)
    offset(r = pull_r) offset(delta = -pull_r)
        polygon([[c_body_l - 2 * pull_r, -w0], [xf, -w0], [xt, -w1], [x1, -w1],
                 [x1, w1], [xt, w1], [xf, w0], [c_body_l - 2 * pull_r, w0]]);
}
module pull_side2d() {
    xs = c_body_l + bezel_t + pull_barb_gap;        // the step's face
    x1 = c_body_l + bezel_t + pull_x;               // the front end
    polygon([[c_body_l - 1, 0], [x1, 0], [x1, c_floor - pull_chamfer], [x1 - pull_chamfer, c_floor],
             [xs + pull_ramp, c_floor], [xs, c_floor + pull_barb], [xs, c_floor], [c_body_l - 1, c_floor]]);
}
// the grip slot, a stadium in plan
module pull_hole2d() {
    r = pull_hole[0] / 2;  x = c_body_l + bezel_t + pull_hole_x + r;
    hull() for (s = [-1, 1]) translate([x, s * (pull_hole[1] / 2 - r)]) circle(r = r);
}
module pull_ledge() {
    difference() {
        intersection() {
            linear_extrude(height = c_floor + pull_barb) pull_plan2d();
            translate([0, b_w, 0]) rotate([90, 0, 0]) linear_extrude(height = 2 * b_w) pull_side2d();
            // only in front of the bezel's face: the tab in the slot is bezel_tabs();
            // the barb only across pull_barb_w, square ends inside the taper's edges
            translate([c_body_l + bezel_t - 0.01, 0, 0]) union() {
                translate([0, -b_w, -1]) cube([pull_x + 1, 2 * b_w, c_floor + 1]);
                translate([0, -pull_barb_w/2, 0]) cube([pull_x + 1, pull_barb_w, c_floor + pull_barb + 1]);
            }
        }
        translate([0, 0, -1]) linear_extrude(height = c_floor + pull_barb + 2) pull_hole2d();
    }
}
module bezel_slots() {
    x0 = c_body_l;
    c = bz_tab_clr;  cf = bz_floor_clr;  ce = bz_end_clr;   // a wall tab's inner face, across the floor tab, along a tab
    bz_wall_tabs(c, 1, ce);
    box([x0 - 1, -bz_tab_w/2 - ce, -cf], [x0 + bezel_t + 1, bz_tab_w/2 + ce, c_floor + cf]);
}

// keep-outs for the bezel honeycomb, in the field's frame (u = b_in_h/2 - z,
// v = y): whole cells stay a margin away from the tab slots and from the
// lip's foot, which must stand on solid plate
function bz_zone(z0, z1, y0, y1, m = b_keep_margin) = [b_in_h/2 - z1 - m, min(y0, y1) - m, b_in_h/2 - z0 + m, max(y0, y1) + m];
function bezel_keep() = concat(
    [bz_zone(-bz_floor_clr, c_floor + bz_floor_clr, -bz_tab_w/2 - bz_end_clr, bz_tab_w/2 + bz_end_clr)],
    [for (s = [-1, 1], z = bz_tab_z) bz_zone(z - bz_tab_h/2 - bz_end_clr, z + bz_tab_h/2 + bz_end_clr,
                               s * (c_in_w/2 - bz_tab_clr), s * (c_w/2 + bezel_t * tan(bz_tab_splay)))],
    [bz_zone(bz_lip_top - bz_lip_t, bz_lip_top, bz_lip_y0, bz_lip_y1)]);

// lip profile in (x, z), from the bezel's back face rearward, chamfered on
// the rear top edge so a sagging top plate rides up onto it
module bezel_lip() {
    x0 = c_body_l + 0.01;  x1 = c_body_l - bz_lip_d;  zt = bz_lip_top;  zb = zt - bz_lip_t;
    translate([0, bz_lip_y1, 0]) rotate([90, 0, 0]) linear_extrude(height = bz_lip_w)
        polygon([[x0, zb], [x1, zb], [x1, zt - bz_lip_c], [x1 + bz_lip_c, zt], [x0, zt]]);
}

// Bezel: a flat 2 mm plate the size of the bay's front face. It seats on
// the front edge of the plates and walls, is honeycomb over its whole face
// inside a narrow rim, joins the tray through three tab slots, and carries
// the lip that props up the top plate. The tray's pull ledge stands out
// under it.
module bezel() {
    x0 = c_body_l;
    bezel_lip();
    difference() {
        box([x0, -b_w/2, b_z0], [x0 + bezel_t, b_w/2, b_z1]);
        bezel_slots();
        // honeycomb over the whole face, centred on it
        translate([x0 + bezel_t/2, 0, b_in_h/2]) rotate([0, 90, 0])
            honeycomb_cut([b_h - 2 * bz_rim, b_w - 2 * bz_rim], bezel_t + 2, bz_hex_cell, bz_hex_web, bezel_keep());
    }
}

// ---- push tab in the middle of the rear edge --------------------------------
// plan (x, y): the tongue with rounded rear corners, filleted into a strip
// of the floor's solid rear frame (the strip lies inside the floor)
module push_plan2d() {
    offset(r = -push_root_r) offset(delta = push_root_r) union() {
        offset(r = push_r) offset(delta = -push_r)
            translate([push_x1, push_y0]) square([c_rear_gap + 2 * push_r - push_x1, push_w]);
        translate([c_rear_gap, push_y0 - 3 * push_root_r]) square([c_frame, push_w + 6 * push_root_r]);
    }
}
// side profile (x, z): the floor's thickness, its top rear edge rounded down
module push_side2d() {
    offset(r = push_nose) offset(delta = -push_nose) translate([push_x1, -push_nose]) square([c_rear_gap + c_frame - push_x1, c_floor + push_nose]);
}
module push_tab() {
    intersection() {
        linear_extrude(height = c_floor) push_plan2d();
        translate([0, b_w, 0]) rotate([90, 0, 0]) linear_extrude(height = 2 * b_w) push_side2d();
    }
}

// tray: the print that lies on its floor. `protrusions = false` leaves off
// the pins (round, horizontal) for the thin-section check. `spring_defl`
// draws the lock bumps pushed down that far (0 = as printed).
module caddy_tray(protrusions = true, spring_defl = 0) {
    difference() {
        union() {
            caddy_floor();
            wall_solid(-1);
            wall_solid(1);
            bezel_tabs();
            pull_ledge();
            spring_bumps(spring_defl);
            push_tab();
        }
        pin_fingers_cuts();
        service_holes();
        spring_cuts();
        wall_vents(1);
        wall_vents(-1);
    }
    if (protrusions) pins();
}

// assembled caddy for views and checks: seated in a bay, so the lock bumps
// are drawn with their preload deflection, bearing on the top plate's slots
module caddy(spring_defl = sp_preload) { caddy_tray(spring_defl = spring_defl); bezel(); }

part = "";   // "" both, "tray", "bezel"
if (part == "")      caddy();
if (part == "tray")  caddy_tray();
if (part == "bezel") bezel();
