// Bay: two identical plates, two identical walls and a rear panel, all
// printed flat, joined by tabs through slots (press fit, glue optional).
// Plate bumps drop into the honeycomb cells of the bay above and wall bumps
// into the cells of the bay beside, so bays join with no extra part. The
// rear panel squares the back and leaves the SATA plugs clear.
include <lib.scad>

// slot for a tab of length `l` centred at (x, y), through a flat part
module slot(x, y, l, w, c = tab_clr) translate([x - l/2 - c, y - w/2 - c, -1]) cube([l + 2*c, w + 2*c, 10]);

// ---- plate, own frame: flat, x b_x0..b_l, y centred, z 0..b_t, bumps on +z.
//      The bottom plate is turned over when assembled. The two prints tell
//      themselves apart by their slots: the top carries four rear-panel
//      slots and the two caddy lock slots, the bottom only two rear-panel
//      slots (mirrored, as it is turned over). The rear-panel slots sit at
//      the rear edge, so they also show which way round a plate goes.
module plate(kind = "top") {
    difference() {
        box([b_x0, -b_w/2, 0], [b_l, b_w/2, b_t]);
        for (x = tab_x, s = [-1, 1]) slot(x, s * (b_in_w/2 + b_wall/2), tab_len, b_wall);   // walls
        for (y = rear_slot_y(kind)) slot(rear_x + rear_t/2, y, rear_t, rear_tab, rear_fit_clr);  // rear panel
        // caddy lock slots under both caddy walls, top plate only
        if (kind == "top") for (s = [-1, 1]) box([sp_hole_x[0], s * sp_hole_y[0], -1], [sp_hole_x[1], s * sp_hole_y[1], b_t + 1]);
        translate([b_xc, 0, b_t/2])
            honeycomb_cut([b_l - b_x0 - 2*b_vent_rim, b_in_w - 2*b_vent_rim], b_t + 2, hex_cell, hex_web,
                concat([for (b = plate_bumps) bump_keep(b[0], b[1], b_xc, 0, plate_bump_af)],
                       [for (x = tab_x, s = [-1, 1]) [x - tab_len/2 - b_keep_margin - b_xc, s*b_in_w/2 - 3 - b_keep_margin, x + tab_len/2 + b_keep_margin - b_xc, s*b_in_w/2 + 3 + b_keep_margin]],
                       [for (y = rear_slot_y(kind)) [rear_x - b_keep_margin - b_xc, y - rear_tab/2 - b_keep_margin, rear_x + rear_t + b_keep_margin - b_xc, y + rear_tab/2 + b_keep_margin]],
                       [for (s = [-1, 1]) if (kind == "top") [sp_hole_x[0] - b_keep_margin - b_xc, min(s * sp_hole_y[0], s * sp_hole_y[1]) - b_keep_margin,
                                           sp_hole_x[1] + b_keep_margin - b_xc, max(s * sp_hole_y[0], s * sp_hole_y[1]) + b_keep_margin]]));
    }
    for (b = plate_bumps) translate([b[0], b[1], b_t]) hex_bump(plate_bump_af);
}

// ---- wall, own frame: flat, x b_x0..b_l, y = height 0..b_in_h with tabs
//      beyond, z 0..b_wall, bumps on +z (the outer face when assembled).
module wall() {
    difference() {
        union() {
            box([b_x0, 0, 0], [b_l, b_in_h, b_wall]);
            for (x = tab_x, y0 = [-b_t, b_in_h])
                translate([x - tab_len/2, y0, 0]) cube([tab_len, b_t, b_wall]);
        }
        // rear panel side tab slot, both ends (symmetry), sized to the tab
        for (x = wall_slot_x) slot(x, rear_tab_z, rear_t, rear_tab, rear_fit_clr);
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
