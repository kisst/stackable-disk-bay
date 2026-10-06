// Assembly steps for docs/assembly.md: one scene per step, in the shared
// frame. `part` selects one class for a per-colour export ("plates",
// "walls", "rears", "trays", "bezels", "hdds"); "" shows everything.
include <params.scad>
use <hdd.scad>
use <caddy.scad>
use <bay.scad>

step = 1;
part = "";
function on(p) = part == "" || part == p;

lift = 30;                                  // how far a part hovers before it goes in
module bottom_plate() rotate([180, 0, 0]) plate("bottom");
module top_plate()    translate([0, 0, b_in_h]) plate("top");
// the drive tilted onto the fixed pins (-y wall), the +y side raised
module hdd_tilted(a, dz) translate([0, -c_in_w/2, dz]) rotate([a, 0, 0]) translate([0, c_in_w/2, 0]) hdd();
module bay_parts() {
    if (on("plates")) { bottom_plate(); top_plate(); }
    if (on("walls"))  walls();
    if (on("rears"))  rear_placed();
}

// 1. the walls slide sideways onto the rear panel's side tabs
if (step == 1) {
    if (on("rears")) rear_placed();
    if (on("walls")) {
        translate([0, -b_in_w/2 - lift, 0]) rotate([90, 0, 0]) wall();
        translate([b_x0 + b_l, b_in_w/2 + lift, 0]) rotate([0, 0, 180]) rotate([90, 0, 0]) wall();
    }
}
// 2. walls and panel, now a U, go down into the bottom plate together
if (step == 2) {
    if (on("plates")) bottom_plate();
    if (on("walls"))  translate([0, 0, lift]) walls();
    if (on("rears"))  translate([0, 0, lift]) rear_placed();
}
// 3. the top plate goes on
if (step == 3) {
    if (on("plates")) { bottom_plate(); translate([0, 0, lift]) top_plate(); }
    if (on("walls"))  walls();
    if (on("rears"))  rear_placed();
}
// 4. the bezel presses onto the tray's tabs
if (step == 4) {
    if (on("trays"))  caddy_tray();
    if (on("bezels")) translate([lift, 0, 0]) bezel();
}
// 5. the drive goes in tilted onto the fixed pins, then pressed down
if (step == 5) {
    if (on("trays"))  caddy_tray();
    if (on("bezels")) bezel();
    if (on("hdds"))   hdd_tilted(12, lift);
}
// 6. the loaded caddy slides into the bay, rear first
if (step == 6) {
    bay_parts();
    translate([1.6 * lift, 0, 0]) {
        if (on("trays"))  caddy_tray();
        if (on("bezels")) bezel();
        if (on("hdds"))   hdd();
    }
}
// 7. seated and locked; 8. the rear +y corner of it, close up, for the push tab
module seated() {
    bay_parts();
    if (on("trays"))  caddy_tray(spring_defl = sp_preload);
    if (on("bezels")) bezel();
    if (on("hdds"))   hdd();
}
if (step == 8) intersection() { seated(); translate([-15, 15, -5]) cube([60, 45, 45]); }
if (step == 7) {
    bay_parts();
    if (on("trays"))  caddy_tray(spring_defl = sp_preload);
    if (on("bezels")) bezel();
    if (on("hdds"))   hdd();
}
