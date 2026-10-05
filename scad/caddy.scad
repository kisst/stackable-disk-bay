// Toolless caddy: drive drops in, pins engage the side holes, no screws.
// Two flat prints: the tray (floor, walls, diagonal fingers, pins) on its
// floor, and the bezel (plate, handle) front face down. Tabs on the tray's
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
module detent_finger_cut() { finger_cuts(-1, detent_x, pin_z, detent_dir); }

// keep-out rectangle (field frame centred at cx, cz) round a finger: the
// bounding box of the slot ring and the recess, which reach slot_half beside
// the beam and finger_w/2 past its root, plus the web margin
function finger_corners(xp, zt, dir) = let(L = finger_len(zt), a = dir > 0 ? finger_angle : 180 - finger_angle)
    [for (u = [-slot_half, L + finger_w/2], v = [-slot_half, slot_half])
        [xp + u * cos(a) - v * sin(a), zt + u * sin(a) + v * cos(a)]];
function finger_keep(xp, zt, dir, cx, cz) = let(c = finger_corners(xp, zt, dir), m = b_keep_margin)
    [min([for (p = c) p[0]]) - m - cx, min([for (p = c) p[1]]) - m - cz,
     max([for (p = c) p[0]]) + m - cx, max([for (p = c) p[1]]) + m - cz];

// honeycomb in the caddy walls, on the bay wall's lattice so the cells line up
module wall_vents(s) {
    fc_x = (c_rear_gap + c_body_l) / 2;  fc_z = c_wall_top / 2;
    keep = concat(
        s > 0 ? [for (f = fingers) finger_keep(f[0], pin_z, f[1], fc_x, fc_z)]
              : [finger_keep(detent_x, pin_z, detent_dir, fc_x, fc_z)],
        s < 0 ? [for (x = hdd_side_hole_x) [x - 4 - fc_x, pin_z - 4 - fc_z, x + 4 - fc_x, pin_z + 4 - fc_z]] : [],
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

module detent_bump() {
    for (d = detent_pts) translate([d[0], -c_w/2 - detent_out + detent_d/2, d[1]]) sphere(d = detent_d);
}

// tabs on the tray that pass through the bezel plate
module bezel_tabs() {
    x0 = c_body_l;
    for (s = [-1, 1])   // wall tabs
        box([x0 - 0.01, s * c_in_w/2, pin_z - bz_tab_h/2], [x0 + bezel_t, s * (c_in_w/2 + c_wall), pin_z + bz_tab_h/2]);
    box([x0 - 0.01, -bz_tab_w/2, 0], [x0 + bezel_t, bz_tab_w/2, c_floor]);   // floor tab
}
module bezel_slots() {
    x0 = c_body_l;
    c = bz_tab_clr;
    for (s = [-1, 1])
        box([x0 - 1, s * c_in_w/2 - s*c, pin_z - bz_tab_h/2 - c], [x0 + bezel_t + 1, s * (c_in_w/2 + c_wall) + s*c, pin_z + bz_tab_h/2 + c]);
    box([x0 - 1, -bz_tab_w/2 - c, -c], [x0 + bezel_t + 1, bz_tab_w/2 + c, c_floor + c]);
}

// Bezel: a 2 mm plate the size of the bay's front face. It seats on the
// front edge of the plates and walls, carries the intake honeycomb and a
// low grab bar, and joins the tray through three tab slots.
module bezel() {
    x0 = c_body_l;
    difference() {
        box([x0, -b_w/2, b_z0], [x0 + bezel_t, b_w/2, b_z1]);
        bezel_slots();
        // honeycomb intake over the drive's front face, solid behind the posts
        // and around the tab slots
        difference() {
            translate([x0 + bezel_t/2, 0, b_in_h/2]) rotate([0, 90, 0])
                honeycomb_cut([b_in_h - 8, b_in_w - 16], bezel_t + 2, bz_hex_cell, bz_hex_web);
            for (s = [-1, 1])
                translate([x0 - 1, s*handle_w/2 - handle_post/2 - 2, b_in_h/2 - handle_bar_h/2 - 2])
                    cube([bezel_t + 2, handle_post + 4, handle_bar_h + 4]);
            box([x0 - 1, -bz_tab_w/2 - 3, -1], [x0 + bezel_t + 1, bz_tab_w/2 + 3, c_floor + 3]);
            for (s = [-1, 1])
                box([x0 - 1, s * (c_in_w/2 - 3), pin_z - bz_tab_h/2 - 3], [x0 + bezel_t + 1, s * (c_w/2 + 3), pin_z + bz_tab_h/2 + 3]);
        }
    }
    // handle: two posts and a bar (bridge)
    xf = x0 + bezel_t;
    zc = b_in_h/2;
    for (s = [-1, 1])
        translate([xf, s*handle_w/2 - handle_post/2, zc - handle_bar_h/2])
            cube([handle_depth, handle_post, handle_bar_h]);
    translate([xf + handle_depth - handle_bar_t, -handle_w/2 - handle_post/2, zc - handle_bar_h/2])
        cube([handle_bar_t, handle_w + handle_post, handle_bar_h]);
}

// tray: the print that lies on its floor. `protrusions = false` leaves off
// the pins and detent bumps (round, horizontal) for the thin-section check.
module caddy_tray(protrusions = true) {
    difference() {
        union() {
            caddy_floor();
            wall_solid(-1);
            wall_solid(1);
            bezel_tabs();
        }
        pin_fingers_cuts();
        detent_finger_cut();
        wall_vents(1);
        wall_vents(-1);
    }
    if (protrusions) { pins(); detent_bump(); }
}

// assembled caddy for views and checks
module caddy() { caddy_tray(); bezel(); }

part = "";   // "" both, "tray", "bezel"
if (part == "")      caddy();
if (part == "tray")  caddy_tray();
if (part == "bezel") bezel();
