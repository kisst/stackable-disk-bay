// Bay: two identical plates, two identical walls and a rear panel, all
// printed flat, joined by tabs through slots (press fit, glue optional).
// Plate bumps drop into the honeycomb cells of the bay above and wall bumps
// into the cells of the bay beside, so bays join with no extra part. The
// rear panel squares the back and leaves the SATA plugs clear.
include <lib.scad>

// slot for a tab of length `l` centred at (x, y), through a flat part
module slot(x, y, l, w) translate([x - l/2 - tab_clr, y - w/2 - tab_clr, -1]) cube([l + 2*tab_clr, w + 2*tab_clr, 10]);

// ---- plate, own frame: flat, x b_x0..b_l, y centred, z 0..b_t, bumps on +z.
//      Same geometry top and bottom; the bottom plate is turned over when
//      assembled. Only the engraved mark differs so the two prints can be told
//      apart: top = arrow, bottom = arrow over a bar (the "floor").
module plate(kind = "top") {
    difference() {
        box([b_x0, -b_w/2, 0], [b_l, b_w/2, b_t]);
        for (x = tab_x, s = [-1, 1]) slot(x, s * (b_in_w/2 + b_wall/2), tab_len, b_wall);   // walls
        for (y = rear_slot_y) slot(rear_x + rear_t/2, y, rear_t, rear_tab);                // rear panel, both mirror images
        translate([b_xc, 0, b_t/2])
            honeycomb_cut([b_l - b_x0 - 2*b_vent_rim, b_in_w - 2*b_vent_rim], b_t + 2, hex_cell, hex_web,
                concat([for (b = plate_bumps) bump_keep(b[0], b[1], b_xc, 0, plate_bump_af)],
                       [for (x = tab_x, s = [-1, 1]) [x - tab_len/2 - b_keep_margin - b_xc, s*b_in_w/2 - 3 - b_keep_margin, x + tab_len/2 + b_keep_margin - b_xc, s*b_in_w/2 + 3 + b_keep_margin]],
                       [for (y = rear_slot_y) [rear_x - b_keep_margin - b_xc, y - rear_tab/2 - b_keep_margin, rear_x + rear_t + b_keep_margin - b_xc, y + rear_tab/2 + b_keep_margin]],
                       [[label_x - 9 - b_xc, -12, label_x + 9 - b_xc, 9]]));   // solid pad for the mark
        // orientation mark on the bump face: arrow toward the front,
        // plus a bar under it on the bottom plate
        translate([label_x, 0, b_t - groove_d]) linear_extrude(height = groove_d + 1) {
            polygon([[-mark_size, -mark_size], [-mark_size, mark_size], [mark_size, 0]]);
            if (kind == "bottom") translate([-mark_size, -mark_size - 3.5]) square([2*mark_size, 1.5]);
        }
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
        // rear panel side tab, both ends (symmetry); the slot runs one plate
        // thickness below the tab so the wall can slide in sideways while lifted
        for (x = wall_slot_x) slot(x, rear_tab_z - b_t/2, rear_t, wall_panel_slot_h);
        // orientation groove along the outer face, low down
        translate([b_x0 - 1, groove_z - groove_w/2, b_wall - groove_d]) cube([b_l - b_x0 + 2, groove_w, groove_d + 1]);
        // caddy detent holes (on the other wall they land mirrored, harmless)
        for (d = detent_pts) translate([d[0], d[1], -1]) cylinder(d = detent_hole_d, h = b_wall + 2);
        translate([b_xc, b_in_h/2, b_wall/2])
            honeycomb_cut([b_l - b_x0 - 2*w_vent_rim, b_in_h - 2*w_vent_rim], b_wall + 2, w_hex_cell, w_hex_web,
                concat([for (b = wall_bumps) bump_keep(b[0], b[1], b_xc, b_in_h/2, wall_bump_af)],
                       [for (d = detent_pts) [d[0] - detent_hole_d/2 - 3 - b_xc, d[1] - detent_hole_d/2 - 3 - b_in_h/2,
                                              d[0] + detent_hole_d/2 + 3 - b_xc, d[1] + detent_hole_d/2 + 3 - b_in_h/2]],
                       [for (x = wall_slot_x) [x - rear_t/2 - b_keep_margin - b_xc, -50, x + rear_t/2 + b_keep_margin - b_xc, 50]]));
    }
    for (b = wall_bumps) translate([b[0], b[1], b_wall]) hex_bump(wall_bump_af);
}

// ---- rear panel, own frame: flat, x = across the bay (centred), y = height
//      0..b_in_h, tabs beyond on all four edges, z 0..rear_t. The lower -y
//      corner is open for the SATA plugs.
module rear() {
    w = b_in_w - 2*rear_clr;
    difference() {
        union() {
            box([-w/2, 0, 0], [w/2, b_in_h, rear_t]);
            for (y = rear_tab_y, z0 = [-b_t, b_in_h])                       // into the plates
                translate([y - rear_tab/2, z0, 0]) cube([rear_tab, b_t, rear_t]);
            for (s = [-1, 1])                                               // into the walls
                translate([s > 0 ? w/2 : -w/2 - b_wall, rear_tab_z - rear_tab/2, 0]) cube([b_wall, rear_tab, rear_t]);
        }
        // SATA notch: open at the bottom edge and the -y edge
        translate([-w/2 - b_wall - 1, -b_t - 1, -1]) cube([w/2 + b_wall + 1 + sata_notch_y, b_t + 1 + sata_notch_z, rear_t + 2]);
        // orientation groove on the outer face (z = 0 side, which faces the rear when assembled)
        translate([-w/2 - b_wall - 1, groove_z - groove_w/2, -1]) cube([w + 2*b_wall + 2, groove_w, groove_d + 1]);
        // exhaust honeycomb over the rest
        translate([0, b_in_h/2, rear_t/2])
            honeycomb_cut([w - 2*b_vent_rim, b_in_h - 2*w_vent_rim], rear_t + 2, w_hex_cell, w_hex_web,
                [[-100, -100, sata_notch_y + b_keep_margin + 2, sata_notch_z + b_keep_margin + 2 - b_in_h/2]]);
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
