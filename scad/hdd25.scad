// Reference 2.5" drive (SFF-8201) for fit checks, with every mounting hole
// the spec defines (four side, four bottom), placed as the 2.5" adapter
// holds it: connector face at x = 0, bottom on the caddy floor, +y edge at
// h25_y1. Not a printed part. The SATA plug sits where SFF-8223 puts it,
// which is where SFF-8323 puts a 3.5" drive's relative to the +y edge and
// the bottom.
include <params.scad>
use <hdd.scad>

h25_hole_depth = 3.0;                 // A38 max penetration for drives over 7 mm
h25_bot_depth  = 2.5;                 // A41 max penetration, bottom holes

module hdd25(h = h25_h) {
    color("SlateGray", 0.95) difference() {
        translate([0, h25_y1 - h25_w, c_floor]) cube([h25_l, h25_w, h]);
        // side holes, M3
        for (x = h25_hole_x, y = [h25_y1 - h25_w - 0.1, h25_y1 - h25_hole_depth])
            translate([x, y, c_floor + h25_hole_z])
                rotate([-90, 0, 0]) cylinder(d = h25_hole_minor_d, h = h25_hole_depth + 0.1);
        // bottom holes, M3 (SFF-8201 makes them optional at 7 mm and under)
        for (x = h25_bot_hole_x, y = h25_bot_hole_y)
            translate([x, h25_y1 - y, c_floor - 0.1]) cylinder(d = h25_hole_minor_d, h = h25_bot_depth + 0.1);
        // connector pocket, as on the 3.5" model
        connector_pocket(sata_y0 + h25_dy, min(sata_pocket_h, h - 1));
    }
    color("Black") tongue(sata_y0 + h25_dy);
}

hdd25();
