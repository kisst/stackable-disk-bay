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
// to lift out. One honeycomb cell, on the wall lattice, opens into each
// slot just beyond the finger's tip, at pin height, so a small screwdriver
// can get at the tip and pry it out. The cell is the first one on the
// pin's row past the slot's mitred tip corner; it overlaps that corner,
// so the hole and the slot are one opening, and stays clear of the beam.
function service_cell(f) = let(
        j  = round((pin_z - b_in_h/2) / hex_dy),
        x0 = b_xc + (j % 2 == 0 ? 0 : hex_dx/2),
        xt = f[0] - f[1] * (slot_half * sqrt(2) + c_hex_cell/2),
        i  = round((xt - x0) / hex_dx))
    [x0 + i * hex_dx, b_in_h/2 + j * hex_dy];
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
        s > 0 ? [for (f = fingers) finger_keep(f[0], pin_z, f[1], fc_x, fc_z)] : [],
        [[sp_x[0] - b_keep_margin - fc_x, sp_slit_z - b_keep_margin - fc_z, sp_x[1] + b_keep_margin - fc_x, 50]],
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

// tabs on the tray that pass through the bezel plate
module bezel_tabs() {
    x0 = c_body_l;
    for (s = [-1, 1])   // wall tabs
        box([x0 - 0.01, s * c_in_w/2, pin_z - bz_tab_h/2], [x0 + bezel_t, s * (c_in_w/2 + c_wall), pin_z + bz_tab_h/2]);
    box([x0 - 0.01, -bz_tab_w/2, 0], [x0 + bezel_t, bz_tab_w/2, c_floor]);   // floor tab
}
module bezel_slots() {
    x0 = c_body_l;
    c = bz_tab_clr;  cf = bz_floor_clr;  ce = bz_end_clr;   // across the tab, across the floor tab, along a tab
    for (s = [-1, 1])
        box([x0 - 1, s * c_in_w/2 - s*c, pin_z - bz_tab_h/2 - ce], [x0 + bezel_t + 1, s * (c_in_w/2 + c_wall) + s*c, pin_z + bz_tab_h/2 + ce]);
    box([x0 - 1, -bz_tab_w/2 - ce, -cf], [x0 + bezel_t + 1, bz_tab_w/2 + ce, c_floor + cf]);
}

// finger notch in the bezel's top edge, (y, z): a trapezoid with round
// bottom corners, its mouth eased into the top edge
module finger_notch2d() {
    y = bz_pull_y;  zt = b_z1;  zb = b_z1 - bz_pull_d;
    offset(r = -bz_pull_f) offset(delta = bz_pull_f)               // ease the mouth
    union() {
        offset(r = bz_pull_r) offset(delta = -bz_pull_r)          // round the bottom
            polygon([[y - bz_pull_w/2, zt + 10], [y - bz_pull_wb/2, zb], [y + bz_pull_wb/2, zb], [y + bz_pull_w/2, zt + 10]]);
        translate([-b_w, zt]) square([2 * b_w, 20]);              // everything above the top edge
    }
}

// keep-out for the bezel honeycomb round the notch, in the field's frame
// (u = b_in_h/2 - z, v = y): the trapezoid in 1 mm bands, each as wide as
// the notch at its upper edge, grown by one web
function notch_keep() = let(m = bz_hex_web, zb = b_z1 - bz_pull_d, n = ceil(bz_pull_d))
    [for (i = [0 : n - 1]) let(z0 = zb + i * bz_pull_d / n, z1 = zb + (i + 1) * bz_pull_d / n,
                               hw = (bz_pull_wb + (bz_pull_w - bz_pull_wb) * (z1 - zb) / bz_pull_d) / 2 + m)
        [b_in_h/2 - z1, bz_pull_y - hw, b_in_h/2 - z0 + m, bz_pull_y + hw]];

// lip profile in (x, z), from the bezel's back face rearward, chamfered on
// the rear top edge so a sagging top plate rides up onto it
module bezel_lip() {
    x0 = c_body_l + 0.01;  x1 = c_body_l - bz_lip_d;  zt = bz_lip_top;  zb = zt - bz_lip_t;
    translate([0, bz_lip_y1, 0]) rotate([90, 0, 0]) linear_extrude(height = bz_lip_w)
        polygon([[x0, zb], [x1, zb], [x1, zt - bz_lip_c], [x1 + bz_lip_c, zt], [x0, zt]]);
}

// Bezel: a flat 2 mm plate the size of the bay's front face. It seats on
// the front edge of the plates and walls, carries the intake honeycomb and
// the finger notch, joins the tray through three tab slots, and carries the
// lip that props up the top plate.
module bezel() {
    x0 = c_body_l;
    bezel_lip();
    difference() {
        box([x0, -b_w/2, b_z0], [x0 + bezel_t, b_w/2, b_z1]);
        bezel_slots();
        translate([x0 - 1, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = bezel_t + 2) finger_notch2d();
        // honeycomb intake over the drive's front face: only the cells that
        // would come within a web of the notch are skipped, and the zones
        // round the tab slots stay solid
        difference() {
            translate([x0 + bezel_t/2, 0, b_in_h/2]) rotate([0, 90, 0])
                honeycomb_cut([b_in_h - 8, b_in_w - 16], bezel_t + 2, bz_hex_cell, bz_hex_web, notch_keep());
            box([x0 - 1, -bz_tab_w/2 - 3, -1], [x0 + bezel_t + 1, bz_tab_w/2 + 3, c_floor + 3]);
            for (s = [-1, 1])
                box([x0 - 1, s * (c_in_w/2 - 3), pin_z - bz_tab_h/2 - 3], [x0 + bezel_t + 1, s * (c_w/2 + 3), pin_z + bz_tab_h/2 + 3]);
        }
    }
}

// ---- push tab at the rear +y corner ---------------------------------------
// rib profile in the wall's plane (x, z): a block from the rear end into the
// wall, filleted into the wall's rear edge, top rear edge rounded. The stub
// into the wall lies inside wall material; the wall's cuts come after.
module push_rib2d() {
    offset(r = push_nose) offset(delta = -push_nose)
    offset(r = -push_fillet) offset(delta = push_fillet)
    union() {
        translate([push_x1, 0]) square([c_rear_gap + 6 - push_x1, push_h]);
        translate([c_rear_gap, 0]) square([6, c_wall_top - 3]);
    }
}
module push_tab() {
    y0 = c_w/2 - push_w;                           // inner edge; the tab runs to the tray's +y outer face
    intersection() {
        union() {
            wall_profile(1) push_rib2d();
            box([push_x1, y0, 0], [c_rear_gap + 6, c_w/2, c_floor]);
        }
        // plan: both rear corners rounded
        translate([0, 0, -1]) linear_extrude(height = c_wall_top + 2)
            offset(r = push_r) offset(delta = -push_r)
                translate([push_x1, y0]) square([c_rear_gap + 20 - push_x1, push_w]);
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
