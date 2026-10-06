// Reference 3.5" drive (SFF-8301) for fit checks. Not a printed part.
//
// Placed in the shared frame: connector face at x = 0, bottom on the caddy
// floor. Every mounting hole SFF-8301 defines is drawn, from the connector
// end: two each side (A8, A8 + A9, 6.35 mm up), six in the bottom (A7,
// A7 + A6, A7 + A13, 95.25 mm apart across), all 6-32 UNC, as deep as the
// longest fastener the drive must take.
//
// The SATA plug follows the SATA-IO internal device plug: a horizontal
// L-shaped tongue, signal segment (7 contacts) nearest the drive's +y edge,
// power segment (15) inboard, both at 1.27 mm pitch, recessed in a pocket.
// SFF-8323 puts its outer edge 13.43 mm from that edge, where the real drive
// on the bench has it. The 2.5" drive (scad/hdd25.scad) uses the same tongue.
include <params.scad>

hdd_r     = 2.54;                   // plan radius on the body's vertical edges
hdd_lid   = 0.75;                   // top cover, raised above the rim
hdd_lid_in = 5.6;                   // and inset from every edge

// Connector frame: y becomes u, the distance inboard from datum B at y0. The
// segments run from the +y edge toward -y, so u = y0 - y.
module at_connector(y0 = sata_y0) translate([0, y0, 0]) mirror([0, 1, 0]) children();

module tongue(y0 = sata_y0) at_connector(y0) {
    // signal blade
    translate([0.3, 0, sata_z0]) cube([sata_tongue_depth, sata_sig_l, sata_tongue_t]);
    // power blade
    translate([0.3, sata_sig_l + sata_key_l, sata_z0]) cube([sata_tongue_depth, sata_pwr_l, sata_tongue_t]);
    // the L: a foot along the inboard-bottom edge of each blade, which keys the plug
    for (u = [0, sata_sig_l + sata_key_l])
        translate([0.3, u, sata_z0 - 1.0]) cube([sata_tongue_depth, 0.8, 1.0]);
    // contact grooves on the top face, for the picture
    color("Goldenrod") for (i = [0 : sata_sig_pins - 1])
        translate([0.3, 1.4 + i * sata_pitch, sata_z0 + sata_tongue_t - 0.05]) cube([sata_tongue_depth - 0.6, 0.7, 0.1]);
    color("Goldenrod") for (i = [0 : sata_pwr_pins - 1])
        translate([0.3, sata_sig_l + sata_key_l + 1.4 + i * sata_pitch, sata_z0 + sata_tongue_t - 0.05]) cube([sata_tongue_depth - 0.6, 0.7, 0.1]);
}
// the pocket the tongue sits in, `h` tall from the drive's bottom
module connector_pocket(y0 = sata_y0, h = sata_pocket_h) at_connector(y0)
    translate([-0.1, -sata_pocket_pad, c_floor - 0.1]) cube([sata_pocket_d + 0.1, sata_l + 2*sata_pocket_pad, h + 0.1]);

// a tapped hole drilled from a face inward along +z, `d` deep
module tapped_hole(d = hdd_hole_depth) translate([0, 0, -0.1]) cylinder(d = hdd_hole_minor_d, h = d + 0.1);

// plan outline, x 0..l, y centred
module rounded_rect(l, w, r) hull() for (x = [r, l - r], y = [-w/2 + r, w/2 - r]) translate([x, y]) circle(r = r);

module hdd() {
    color("SlateGray") difference() {
        translate([0, 0, c_floor]) {
            linear_extrude(height = hdd_h - hdd_lid) rounded_rect(hdd_l, hdd_w, hdd_r);
            translate([hdd_lid_in, 0, 0]) linear_extrude(height = hdd_h)
                rounded_rect(hdd_l - 2*hdd_lid_in, hdd_w - 2*hdd_lid_in, hdd_r);
        }
        // side holes, both sides
        for (x = hdd_side_hole_x, s = [-1, 1])
            translate([x, s * hdd_w/2, c_floor + hdd_side_hole_z]) rotate([s * 90, 0, 0]) tapped_hole();
        // bottom holes
        for (x = hdd_bot_hole_x, s = [-1, 1])
            translate([x, s * hdd_bot_hole_y, c_floor]) tapped_hole();
        connector_pocket();
    }
    color("Black") tongue();
}

hdd();
