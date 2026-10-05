// Helpers shared by the parts.
include <params.scad>

// box from corner a to corner b
module box(a, b) {
    translate([min(a[0],b[0]), min(a[1],b[1]), min(a[2],b[2])])
        cube([abs(b[0]-a[0]), abs(b[1]-a[1]), abs(b[2]-a[2])]);
}

// ---- pins ---------------------------------------------------------------
// Pin along +z from z=0: cylinder + conical tip.
module pin() {
    cylinder(d = pin_d, h = pin_len - pin_tip + 0.01);
    translate([0, 0, pin_len - pin_tip])
        cylinder(d1 = pin_d, d2 = 1.0, h = pin_tip);
}

// ---- hex bump --------------------------------------------------------
// Hexagonal bump standing on the XY plane, slight taper for a lead-in.
// Same orientation as the honeycomb cells (rotate(30)), so a plate bump
// drops straight into a cell of the plate above.
module hex_bump(af) {
    r = af / sqrt(3);
    translate([0, 0, -0.3])
        linear_extrude(height = bump_h + 0.3, scale = 0.93) rotate(30) circle(r = r, $fn = 6);
}
module hex_hole(af, t) {
    r = af / sqrt(3);
    translate([0, 0, -1]) linear_extrude(height = t + 2) rotate(30) circle(r = r, $fn = 6);
}
// keep-out rectangle for a hex bump (or hole) in a centred 2D field
function bump_keep(x, y, cx, cy, af = wall_bump_af) = let(r = af / sqrt(3) + b_keep_margin)
    [x - r - cx, y - r - cy, x + r - cx, y + r - cy];

// ---- honeycomb -----------------------------------------------------------
// 2D field of hexagonal holes filling a `size` = [w, h] rectangle centred on
// the origin. Only whole cells are emitted, so the border stays a clean web.
// `keep` lists [x0, y0, x1, y1] rectangles (same frame) no cell may touch.
function hits_keep(cx, cy, r, keep) =
    len([for (k = keep) if (cx + r > k[0] && cx - r < k[2] && cy + r > k[1] && cy - r < k[3]) 1]) > 0;

// `phase` shifts the cell grid so two fields on different parts can share
// one lattice (their cells then line up when assembled).
module hex_holes(size, cell, web, keep = [], phase = [0, 0]) {
    r  = cell / sqrt(3);            // circumradius for across-flats = cell
    dx = cell + web;
    dy = dx * sqrt(3) / 2;
    nx = ceil(size[0] / dx) + 1;
    ny = ceil(size[1] / dy) + 1;
    for (j = [-ny - 1 : ny + 1], i = [-nx - 1 : nx + 1]) {
        cx = i * dx + (j % 2 == 0 ? 0 : dx / 2) + phase[0];
        cy = j * dy + phase[1];
        if (abs(cx) + cell/2 <= size[0]/2 && abs(cy) + r <= size[1]/2
            && !hits_keep(cx, cy, r, keep))
            translate([cx, cy]) rotate(30) circle(r = r, $fn = 6);
    }
}

// Through-cut for a wall: hex field extruded `t` thick, centred on z = 0.
module honeycomb_cut(size, t, cell, web, keep = [], phase = [0, 0]) {
    linear_extrude(height = t, center = true) hex_holes(size, cell, web, keep, phase);
}
