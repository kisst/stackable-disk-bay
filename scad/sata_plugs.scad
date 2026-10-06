// Mated SATA cable plugs (nominal housings), positioned on the reference
// drive's device connector. Not a printed part and not part of the drive:
// it exists so the rear panel's cutout can be checked against what has to
// pass through it. Data plug carries its latch bump.
include <params.scad>

plug_data_w = 15.5; plug_data_h = 7.4;  plug_data_latch_h = 2.5;
plug_pwr_w  = 24.5; plug_pwr_h  = 8.4;
plug_len    = 18;                        // housing length behind the connector face

// `dy` shifts both plugs across the bay (for the 2.5" adapter's drive)
module sata_plugs(dy = 0) translate([0, dy, 0]) sata_plugs0();
module sata_plugs0() {
    // data plug: centred on the signal segment, latch on top
    yc = sata_y0 - sata_sig_l/2;                    // segments run from datum B toward -y
    color("DarkRed") {
        translate([-plug_len, yc - plug_data_w/2, sata_z0 - 2.2]) cube([plug_len + sata_tongue_depth - 1, plug_data_w, plug_data_h]);
        translate([-plug_len, yc - 4, sata_z0 - 2.2 + plug_data_h]) cube([plug_len - 2, 8, plug_data_latch_h]);
    }
    // power plug: centred on the power segment
    yp = sata_y0 - (sata_sig_l + sata_key_l + sata_pwr_l/2);
    color("Black") translate([-plug_len, yp - plug_pwr_w/2, sata_z0 - 2.4]) cube([plug_len + sata_tongue_depth - 1, plug_pwr_w, plug_pwr_h]);
}

sata_plugs();
