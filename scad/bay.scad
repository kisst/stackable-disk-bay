// Bay: two identical plates, two identical walls and a rear panel, all
// printed flat, joined by tabs through slots and dovetailed wall tabs in
// notches at the plates' edges (no glue).
// Plate bumps drop into the honeycomb cells of the bay above and wall bumps
// into the cells of the bay beside, so bays join with no extra part. The
// rear panel squares the back and leaves the SATA plugs clear.
include <lib.scad>

// slot for a tab of length `l` centred at (x, y), through a flat part, with
// clearance `c` a side along the tab's length and `cw` across its thickness
module slot(x, y, l, w, c, cw = undef) let(cw = is_undef(cw) ? c : cw)
    translate([x - l/2 - c, y - w/2 - cw, -1]) cube([l + 2*c, w + 2*cw, 10]);

// wall tab dovetail, in a frame of its own: x along the tab from its centre,
// w from the wall's outer face (0) to its inner face (b_wall), u from the
// plate's inner face (0) to its outer face (b_t). Both ends move out with u
// (the flare) and with w (the splay). The hull of the corners of the block
// u0..u1, w0..w1, ends c further out, exactly (a polyhedron, so faces land
// on the parts' faces); the caller maps (x, w, u) into place.
function tab_end(u, w, c = 0, splay = tab_splay) = tab_len/2 + c + u * tan(tab_flare) + w * tan(splay);
module tab_dovetail(u0, u1, w0, w1, c = 0, splay = tab_splay)
    polyhedron([for (u = [u0, u1]) for (p = [[-1, w0], [1, w0], [1, w1], [-1, w1]])
                    [p[0] * tab_end(u, p[1], c, splay), p[1], u]],
               [[0, 1, 2, 3], [4, 5, 1, 0], [7, 6, 5, 4], [5, 6, 2, 1], [6, 7, 3, 2], [7, 4, 0, 3]]);
// corner reliefs, in the same frame. A notch's inner corners: on its inner
// face, tangent to its dovetail ends, relief_r into the plate. Where the
// caddy's lock bumps ride under the top plate that would leave a pocket on
// their track, so there `into_end` turns it to cut into the dovetail end
// instead, tangent to the inner face.
module notch_reliefs(into_end = false) let(w = b_wall + tab_fit_clr) for (s = [-1, 1])
    if (into_end) relief_rod([s * tab_end(-1, w - relief_r, tab_clr), w, -1], [s * tab_end(b_t + 1, w - relief_r, tab_clr), w, b_t + 1], [0, -1, 0]);
    else relief_rod([s * tab_end(-1, w, tab_clr), w, -1], [s * tab_end(b_t + 1, w, tab_clr), w, b_t + 1], [-s, 0, 0]);
// A wall tab's roots: on the wall's edge (u = 0), tangent to the tab's
// ends, relief_r into the wall, where the notch's corners on the plate's
// inner face seat.
module root_reliefs(splay = tab_splay) for (s = [-1, 1])
    relief_rod([s * tab_end(0, -1, 0, splay), -1, 0], [s * tab_end(0, b_wall + 1, 0, splay), b_wall + 1, 0], [s, 0, 0]);

// ---- plate, own frame: flat, x b_x0..b_l, y centred, z 0..b_t, bumps on +z.
//      The bottom plate is turned over when assembled. The two prints tell
//      themselves apart by their slots: the top carries four rear-panel
//      slots and the two caddy lock slots, the bottom only two rear-panel
//      slots (mirrored, as it is turned over). The rear-panel slots sit at
//      the rear edge, so they also show which way round a plate goes.
module plate(kind = "top") {
    difference() {
        box([b_x0, -b_w/2, 0], [b_l, b_w/2, b_t]);
        // wall notches, open at the edge: (x, w, u) -> (x, edge - w, u)
        for (x = tab_x, s = [-1, 1]) translate([x, s * (b_in_w/2 + b_wall), 0]) mirror([0, s < 0 ? 1 : 0, 0])
            multmatrix([[1, 0, 0, 0], [0, -1, 0, 0], [0, 0, 1, 0]]) { tab_dovetail(-1, b_t + 1, -1, b_wall + tab_fit_clr, tab_clr);
                notch_reliefs(kind == "top" && x + tab_len/2 + tab_reach > sp_hole_x[1]); }
        for (y = rear_slot_y(kind)) slot(rear_x + rear_t/2, y, rear_t, rear_tab, rear_fit_clr);  // rear panel
        // caddy lock slots under both caddy walls, top plate only
        if (kind == "top") for (s = [-1, 1]) box([sp_hole_x[0], s * sp_hole_y[0], -1], [sp_hole_x[1], s * sp_hole_y[1], b_t + 1]);
        translate([b_xc, 0, b_t/2])
            honeycomb_cut([b_l - b_x0 - 2*b_vent_rim, b_in_w - 2*b_vent_rim], b_t + 2, hex_cell, hex_web,
                concat([for (b = plate_bumps) bump_keep(b[0], b[1], b_xc, 0, plate_bump_af)],
                       [for (x = tab_x, s = [-1, 1]) [x - tab_len/2 - tab_reach - b_keep_margin - b_xc, s*b_in_w/2 - 3 - b_keep_margin, x + tab_len/2 + tab_reach + b_keep_margin - b_xc, s*b_in_w/2 + 3 + b_keep_margin]],
                       [for (y = rear_slot_y(kind)) [rear_x - b_keep_margin - b_xc, y - rear_tab/2 - b_keep_margin, rear_x + rear_t + b_keep_margin - b_xc, y + rear_tab/2 + b_keep_margin]],
                       [for (s = [-1, 1]) if (kind == "top") [sp_hole_x[0] - b_keep_margin - b_xc, min(s * sp_hole_y[0], s * sp_hole_y[1]) - b_keep_margin,
                                           sp_hole_x[1] + b_keep_margin - b_xc, max(s * sp_hole_y[0], s * sp_hole_y[1]) + b_keep_margin]]));
    }
    for (b = plate_bumps) translate([b[0], b[1], b_t]) hex_bump(plate_bump_af);
}

// ---- wall, own frame: flat, x b_x0..b_l, y = height 0..b_in_h with tabs
//      beyond, z 0..b_wall, bumps on +z (the outer face when assembled).
//      `splay` is for the checks only: 0 shows the sideways path without the snap.
module wall(splay = tab_splay) {
    difference() {
        union() {
            box([b_x0, 0, 0], [b_l, b_in_h, b_wall]);
            // dovetailed tabs: (x, w, u) -> (x, -u, b_wall - w) at the bottom,
            // (x, b_in_h + u, b_wall - w) at the top
            for (x = tab_x) translate([x, 0, b_wall]) {
                multmatrix([[1, 0, 0, 0], [0, 0, -1, 0], [0, -1, 0, 0]]) tab_dovetail(-0.01, b_t, 0, b_wall, 0, splay);
                translate([0, b_in_h, 0]) multmatrix([[1, 0, 0, 0], [0, 0, 1, 0], [0, -1, 0, 0]]) tab_dovetail(-0.01, b_t, 0, b_wall, 0, splay);
            }
        }
        for (x = tab_x) translate([x, 0, b_wall]) {
            multmatrix([[1, 0, 0, 0], [0, 0, -1, 0], [0, -1, 0, 0]]) root_reliefs(splay);
            translate([0, b_in_h, 0]) multmatrix([[1, 0, 0, 0], [0, 0, 1, 0], [0, -1, 0, 0]]) root_reliefs(splay);
        }
        // rear panel side tab slot, both ends (symmetry), sized to the tab
        for (x = wall_slot_x) slot(x, rear_tab_z, rear_t, rear_tab, rear_fit_clr);
        // its corner reliefs, two diagonal corners, centred on the corner;
        // they also take a drop of glue
        for (x = wall_slot_x, s = [-1, 1])
            let(c = [x + s * (rear_t/2 + rear_fit_clr), rear_tab_z + s * (rear_tab/2 + rear_fit_clr)])
                relief_rod([c[0], c[1], -1], [c[0], c[1], b_wall + 1]);
        // orientation groove along the outer face, low down
        translate([b_x0 - 1, groove_z - groove_w/2, b_wall - groove_d]) cube([b_l - b_x0 + 2, groove_w, groove_d + 1]);
        translate([b_xc, b_in_h/2, b_wall/2])
            honeycomb_cut([b_l - b_x0 - 2*w_vent_rim, b_in_h - 2*w_vent_rim], b_wall + 2, w_hex_cell, w_hex_web,
                concat([for (b = wall_bumps) bump_keep(b[0], b[1], b_xc, b_in_h/2, wall_bump_af)],
                       [for (x = wall_slot_x) [x - rear_t/2 - b_keep_margin - b_xc, -50, x + rear_t/2 + b_keep_margin - b_xc, 50]]));
    }
    for (b = wall_bumps) translate([b[0], b[1], b_wall]) hex_bump(wall_bump_af);
}

// ---- rear panel, own frame: flat, x = across the bay (centred), y = height
//      0..b_in_h, tabs beyond all four edges (four into the top plate, two
//      into the bottom plate, one into each wall), z 0..rear_t. The lower +y
//      corner is open for the SATA plugs.
module rear() {
    w = b_in_w - 2*rear_clr;
    difference() {
        union() {
            box([-w/2, 0, 0], [w/2, b_in_h, rear_t]);
            for (y = rear_tab_y_bot) translate([y - rear_tab/2, -b_t, 0]) cube([rear_tab, b_t, rear_t]);     // into the bottom plate
            for (y = rear_tab_y_top) translate([y - rear_tab/2, b_in_h, 0]) cube([rear_tab, b_t, rear_t]);   // into the top plate
            for (s = [-1, 1])                                               // into the walls
                translate([s > 0 ? w/2 : -w/2 - b_wall, rear_tab_z - rear_tab/2, 0]) cube([b_wall, rear_tab, rear_t]);
        }
        // SATA notch: open at the bottom edge and the +y edge
        box([sata_notch_y, -b_t - 1, -1], [w/2 + b_wall + 1, sata_notch_z, rear_t + 1]);
        // orientation groove on the outer face (z = 0 side, which faces the rear when assembled)
        translate([-w/2 - b_wall - 1, groove_z - groove_w/2, -1]) cube([w + 2*b_wall + 2, groove_w, groove_d + 1]);
        // exhaust honeycomb over the rest
        translate([0, b_in_h/2, rear_t/2])
            honeycomb_cut([w - 2*b_vent_rim, b_in_h - 2*w_vent_rim], rear_t + 2, w_hex_cell, w_hex_web,
                [[sata_notch_y - b_keep_margin - 2, -100, 100, sata_notch_z + b_keep_margin + 2 - b_in_h/2]]);
    }
}

// ---- assembled bay in the shared frame -----------------------------------
module plates(top = true) {
    rotate([180, 0, 0]) plate("bottom");                         // bottom, bumps down
    if (top) translate([0, 0, b_in_h]) plate("top");             // top, bumps up
}
module walls() {
    translate([0, -b_in_w/2, 0]) rotate([90, 0, 0]) wall();      // -y wall, bumps out
    translate([b_x0 + b_l, b_in_w/2, 0]) rotate([0, 0, 180]) rotate([90, 0, 0]) wall();  // +y wall, same part turned
}
module rear_placed() translate([rear_x, 0, 0]) rotate([90, 0, 90]) rear();   // panel x -> y, y -> z, z -> x
module bay(top = true) { plates(top); walls(); rear_placed(); }


top = true;   // -D top=false renders the bay without its top plate
bay(top = top);
