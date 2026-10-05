// Reference 3.5" drive (SFF-8301) for fit checks. Not a printed part.
//
// Envelope and hole positions are from SFF-8301. The SATA device plug follows
// the SATA-IO internal device plug: a horizontal L-shaped tongue at the
// bottom of the connector face, signal segment (7 contacts) nearest the
// drive's edge, power segment (15 contacts) inboard, both at 1.27 mm pitch,
// recessed in a pocket so nothing protrudes past the 147 mm envelope.
// Viewed from the rear with the label up, the connector is at the right-hand
// edge, which is -y in the shared frame. Segment lengths and the pocket are
// nominal; confirm the cutout against a real drive before printing the rear
// panel in quantity.
include <params.scad>

// ---- casting and PCB ---------------------------------------------------------
hdd_bottom_hole_x = [41.28, 142.88];   // from the connector face, 101.6 apart
hdd_bottom_hole_y = 95.25 / 2;         // half of the across-drive spacing
hdd_hole_depth    = 3.2;               // usable thread depth, side and bottom
hdd_pcb_recess    = 2.2;               // drop from the frame rails to the PCB's underside
hdd_pcb_t         = 1.6;
hdd_pcb_l         = 0.62 * hdd_l;      // PCB runs from the connector face forward
hdd_rail_w        = 8;                 // solid frame rails either side of the PCB
hdd_cover_inset   = 0.4;               // top cover sits slightly below the casting rim
hdd_cover_edge    = 4;

// ---- jumper header (2 x 4, 2.0 mm pitch) inboard of the power segment ------
jmp_y0 = sata_y0 + sata_l + 6;
jmp_pins = 4; jmp_pitch = 2.0;

module tongue() {
    // signal blade
    translate([0.3, sata_y0, sata_z0]) cube([sata_tongue_depth, sata_sig_l, sata_tongue_t]);
    // power blade
    translate([0.3, sata_y0 + sata_sig_l + sata_key_l, sata_z0]) cube([sata_tongue_depth, sata_pwr_l, sata_tongue_t]);
    // the L: a foot along the inboard-bottom edge of each blade, which keys the plug
    for (y = [sata_y0, sata_y0 + sata_sig_l + sata_key_l])
        translate([0.3, y, sata_z0 - 1.0]) cube([sata_tongue_depth, 0.8, 1.0]);
    // contact grooves on the top face, for the picture
    color("Goldenrod") for (i = [0 : sata_sig_pins - 1])
        translate([0.3, sata_y0 + 1.4 + i * sata_pitch, sata_z0 + sata_tongue_t - 0.05]) cube([sata_tongue_depth - 0.6, 0.7, 0.1]);
    color("Goldenrod") for (i = [0 : sata_pwr_pins - 1])
        translate([0.3, sata_y0 + sata_sig_l + sata_key_l + 1.4 + i * sata_pitch, sata_z0 + sata_tongue_t - 0.05]) cube([sata_tongue_depth - 0.6, 0.7, 0.1]);
}

module hdd(with_connectors = true) {
    // casting
    color("SlateGray", 0.95) difference() {
        translate([0, -hdd_w/2, c_floor]) cube([hdd_l, hdd_w, hdd_h]);
        // side holes, tapped 6-32
        for (x = hdd_side_hole_x, s = [-1, 1])
            translate([x, s * (hdd_w/2 - hdd_hole_depth), c_floor + hdd_side_hole_z])
                rotate([s * -90, 0, 0]) cylinder(d = hdd_hole_minor_d, h = hdd_hole_depth + 0.1);
        // bottom holes, tapped 6-32
        for (x = hdd_bottom_hole_x, s = [-1, 1])
            if (x < hdd_l - 2)
                translate([x, s * hdd_bottom_hole_y, c_floor - 0.1])
                    cylinder(d = hdd_hole_minor_d, h = hdd_hole_depth + 0.1);
        // PCB recess between the frame rails, open toward the connector face
        translate([-0.1, -hdd_w/2 + hdd_rail_w, c_floor - 0.1])
            cube([hdd_pcb_l + 0.1, hdd_w - 2*hdd_rail_w, hdd_pcb_recess + hdd_pcb_t + 0.1]);
        // connector pocket in the rear face
        translate([-0.1, sata_y0 - sata_pocket_pad, c_floor - 0.1])
            cube([sata_pocket_d + 0.1, sata_l + 2*sata_pocket_pad, sata_pocket_h + 0.1]);
        // jumper header pocket
        translate([-0.1, jmp_y0 - 1.5, c_floor - 0.1]) cube([6, jmp_pins * jmp_pitch + 3, 8]);
        // top cover inset
        translate([hdd_cover_edge, -hdd_w/2 + hdd_cover_edge, c_floor + hdd_h - hdd_cover_inset])
            cube([hdd_l - 2*hdd_cover_edge, hdd_w - 2*hdd_cover_edge, hdd_cover_inset + 0.1]);
    }
    // PCB, motor hub
    color("DarkOliveGreen") translate([sata_pocket_d, -hdd_w/2 + hdd_rail_w + 1, c_floor + hdd_pcb_recess])
        cube([hdd_pcb_l - sata_pocket_d - 1, hdd_w - 2*hdd_rail_w - 2, hdd_pcb_t]);
    color("Silver") translate([hdd_l * 0.55, 0, c_floor + 0.05]) cylinder(d = 26, h = hdd_pcb_recess - 0.05);   // hub sits inside the envelope
    // top cover and label
    color("LightSlateGray") translate([hdd_cover_edge, -hdd_w/2 + hdd_cover_edge, c_floor + hdd_h - hdd_cover_inset - 0.01])
        cube([hdd_l - 2*hdd_cover_edge, hdd_w - 2*hdd_cover_edge, 0.01]);
    color("WhiteSmoke") translate([hdd_l * 0.15, -hdd_w * 0.35, c_floor + hdd_h - hdd_cover_inset]) cube([hdd_l * 0.6, hdd_w * 0.7, 0.05]);
    if (with_connectors) {
        color("Black") tongue();
        // jumper pins
        color("Goldenrod") for (i = [0 : jmp_pins - 1], r = [0, 1])
            translate([0.5, jmp_y0 + i * jmp_pitch, c_floor + 2 + r * jmp_pitch]) cube([5, 0.64, 0.64]);
    }
}

hdd();
