// Interference checks. Each `check` exports the intersection of two bodies;
// scripts/check.sh asserts the STL is empty (face contact allowed).
// Select with: openscad -D check=\"stack\" ...
include <params.scad>
use <hdd.scad>
use <sata_plugs.scad>
use <caddy.scad>
use <bay.scad>

check = "stack";
$fn = 24;   // checks are booleans, not prints; coarse arcs keep CGAL fast

module unit() { bay(); caddy(); hdd(); }
module u(i, j) translate([0, i * pitch_y, j * pitch_z]) children();

// ---- one unit ---------------------------------------------------------------
// expected EMPTY / face contact
if (check == "walls_in_plates") intersection() { plates(); walls(); }   // tabs in slots, wall foot on plate
if (check == "rear_in_bay")     intersection() { rear_placed(); union() { plates(); walls(); } }
if (check == "hdd_vs_rear")     intersection() { rear_placed(); union() { hdd(); caddy(); } }
// expected EMPTY: mated SATA data and power plugs pass through the rear cutout
if (check == "plugs_vs_rear")   intersection() { rear_placed(); sata_plugs(); }
// expected NON-EMPTY: the plugs really reach the tongue (sanity check of the plug model)
if (check == "plugs_on_tongue") intersection() { sata_plugs(); translate([0, -hdd_w/2, c_floor]) cube([hdd_l, hdd_w, hdd_h]); }
if (check == "caddy_in_bay") intersection() { bay(); union() { caddy(); hdd(); } }
if (check == "bezel_on_tray") intersection() { caddy_tray(); bezel(); }   // tabs in slots, faces touch
// expected NON-EMPTY: bezel shifted 1 mm sideways hits the tray's tabs
if (check == "bezel_engaged") intersection() { caddy_tray(); translate([0, 1.0, 0]) bezel(); }
if (check == "hdd_in_caddy") intersection() { caddy(); hdd(); }
// expected NON-EMPTY: the tabs really sit in the slots (a wall shifted 1 mm
// along the bay hits plate material; lifting cannot catch a through-slot)
if (check == "tabs_engaged") intersection() {
    rotate([180, 0, 0]) plate();
    translate([1.0, -b_in_w/2, 0]) rotate([90, 0, 0]) wall();
}
// expected NON-EMPTY: rear panel tabs engage (panel shifted 1 mm across hits walls/plates)
if (check == "rear_engaged") intersection() { translate([0, 1.0, 0]) rear_placed(); union() { plates(); walls(); } }
// expected NON-EMPTY: the bezel seats on the bay's front face (bay pushed
// 1 mm forward hits the bezel plate)
if (check == "bezel_seats") intersection() { bezel(); translate([1.0, 0, 0]) bay(); }

// ---- insertion path: panel into the bottom plate, walls slid in from the
//      sides while lifted one plate thickness, dropped, top plate on ------------
module bottom_plate() rotate([180, 0, 0]) plate("bottom");
module left_wall_at(dy, dz) translate([0, -b_in_w/2 - dy, dz]) rotate([90, 0, 0]) wall();
// expected EMPTY / face contact at every station
if (check == "path_panel_drop")  intersection() { translate([0, 0, b_t/2]) rear_placed(); bottom_plate(); }
if (check == "path_wall_side")   intersection() { left_wall_at(4, b_t);   union() { bottom_plate(); rear_placed(); } }   // approaching, tab not yet in
if (check == "path_wall_lifted") intersection() { left_wall_at(0, b_t);   union() { bottom_plate(); rear_placed(); } }   // in place sideways, still lifted
if (check == "path_wall_drop")   intersection() { left_wall_at(0, b_t/2); union() { bottom_plate(); rear_placed(); } }   // half way down
if (check == "path_top_drop")    intersection() { translate([0, 0, b_in_h + b_t/2]) plate("top"); union() { walls(); rear_placed(); } }
// expected NON-EMPTY: the sideways slide really engages the panel tab (wall
// lifted and 1 mm too far inward hits the panel)
if (check == "path_wall_engages") intersection() { left_wall_at(-1, b_t); rear_placed(); }

// ---- neighbours ---------------------------------------------------------------
// The lower bay's plate bumps sit inside open cells of the upper bay's bottom
// plate; the left bay's wall bumps inside open cells of the right bay's wall.
// expected EMPTY / face contact
if (check == "stack")        intersection() { u(0,0) unit(); u(0,1) unit(); }
if (check == "side")         intersection() { u(0,0) unit(); u(1,0) unit(); }
// expected NON-EMPTY: a neighbour shifted 1 mm along the bay hits the bumps
// (they really sit in cells)
if (check == "stack_holds")  intersection() { bay(); translate([1, 0, pitch_z]) bay(); }
if (check == "side_holds")   intersection() { bay(); translate([1, pitch_y, 0]) bay(); }

// ---- 2 x 2 combo, every bay loaded -----------------------------------------
if (check == "array_diag_a") intersection() { u(0,0) unit(); u(1,1) unit(); }
if (check == "array_diag_b") intersection() { u(0,1) unit(); u(1,0) unit(); }
if (check == "array_stack2") intersection() { u(1,0) unit(); u(1,1) unit(); }
if (check == "array_side2")  intersection() { u(0,1) unit(); u(1,1) unit(); }
if (check == "array_caddy_vs_neighbours")
    intersection() { union() { caddy(); hdd(); }
                     union() { u(0,1) bay(); u(1,0) bay(); } }
