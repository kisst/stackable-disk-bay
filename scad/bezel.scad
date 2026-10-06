// Caddy bezel (a flat plate, print front face down). Slots take the tray's
// tabs; the notch in the top edge is the finger pull.
include <params.scad>
use <caddy.scad>
translate([0, 0, c_body_l + bezel_t]) rotate([0, 90, 0]) bezel();   // front face on the bed
