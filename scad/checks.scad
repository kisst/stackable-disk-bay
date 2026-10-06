// Interference checks. Each `check` exports the intersection of two bodies;
// scripts/check.sh asserts the STL is empty (face contact allowed).
// Select with: openscad -D check=\"stack\" ...
include <params.scad>
use <hdd.scad>
use <sata_plugs.scad>
use <caddy.scad>
use <bay.scad>
use <hdd25.scad>
use <accessories.scad>

check = "stack";
$fn = 24;   // checks are booleans, not prints; coarse arcs keep CGAL fast

// an unknown name would export nothing, which check.sh reads as a pass
checks = ["walls_in_plates", "rear_in_bay", "hdd_vs_rear", "plugs_vs_rear", "plugs_on_tongue",
          "caddy_in_bay", "bezel_on_tray", "bezel_engaged", "hdd_in_caddy", "tabs_engaged",
          "rear_engaged", "rear_in_walls", "bezel_seats", "caddy_locked", "path_caddy_slide",
          "lock_track", "bezel_lip_holds", "posts_hold", "path_bezel_lip", "plugs_vs_caddy", "path_caddy_past_panel", "path_wall_onto_panel", "path_u_drop", "path_top_drop", "stack", "side", "stack_holds",
          "side_holds", "array_diag_a", "array_diag_b", "array_stack2", "array_side2",
          "array_caddy_vs_neighbours",
          "adapter_in_caddy", "hdd25_in_adapter", "plugs25_vs_rear", "adapter_held", "hdd25_held",
          "feet_in_plate", "feet_hold", "joiner_w_stack", "joiner_w_holds", "joiner_w_run", "joiner_w_locks",
          "joiner_h_side", "joiner_h_holds", "joiner_h_run", "joiner_h_locks", "joiner_h3_run", "joiner_h3_locks"];
assert(search([check], checks) != [[]], str("unknown check: ", check));

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
// expected NON-EMPTY: the panel's side tabs sit in the wall slots (panel
// shifted 1 mm along the bay hits the walls alone, not just the plate slots)
if (check == "rear_in_walls") intersection() { translate([1.0, 0, 0]) rear_placed(); walls(); }
// expected NON-EMPTY: the bezel seats on the bay's front face (bay pushed
// 1 mm forward hits the bezel plate)
if (check == "bezel_seats") intersection() { bezel(); translate([1.0, 0, 0]) bay(); }

// ---- bezel lip --------------------------------------------------------------
// expected NON-EMPTY: the lip props the top plate (it sits 0.2 mm under the
// plate; a plate sagging 0.4 mm hits it)
if (check == "bezel_lip_holds") intersection() { bezel(); translate([0, 0, b_in_h - 0.4]) plate("top"); }
// expected NON-EMPTY: the caddy walls' front posts prop it too (0.2 mm under
// the plate; a plate sagging 0.4 mm hits them; the spring bumps further back
// are cut away)
if (check == "posts_hold") intersection() {
    caddy_tray(spring_defl = sp_preload);
    translate([0, 0, b_in_h - 0.4]) plate("top");
    translate([c_body_l - c_post_l - 1, -b_w, -1]) cube([c_post_l + 2, 2 * b_w, 50]);
}
// expected EMPTY / face contact: 3 mm from seated, the lip already under the
// top plate's rim, the bezel clears the bay
if (check == "path_bezel_lip") intersection() { bay(); translate([3, 0, 0]) bezel(); }

// ---- caddy push tab -----------------------------------------------------------
// expected EMPTY: the push tab clears the mated SATA plugs
if (check == "plugs_vs_caddy") intersection() { sata_plugs(); caddy_tray(); }
// expected EMPTY: sliding in, every part of the tray that ends up behind the
// rear panel's front face passes it: the tray against the panel's outline
// swept forward from the panel (its open corner and vents stay open)
if (check == "path_caddy_past_panel") intersection() {
    caddy_tray(spring_defl = sp_lock);
    translate([rear_x + rear_t - 40, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = 40) projection() rear();
}

// ---- caddy spring lock -----------------------------------------------------
// expected NON-EMPTY: the seated caddy is locked (pulled 1 mm out, the bumps,
// still preloaded, hit the top plate's slot edges)
if (check == "caddy_locked") intersection() { bay(); translate([1.0, 0, 0]) caddy_tray(spring_defl = sp_preload); }
// expected EMPTY / face contact: sliding in, the bumps pressed flat against
// the top plate's underside clear the bay
if (check == "path_caddy_slide") intersection() { bay(); translate([30, 0, 0]) caddy_tray(spring_defl = sp_lock); }
// expected EMPTY: the bumps' track under the top plate, from the bay's front
// edge to the lock slot, is solid plate: nothing to click into on the way
if (check == "lock_track") for (s = [-1, 1]) difference() {
    box([sp_hole_x[1] + 0.01, s * c_in_w/2, b_in_h], [b_l, s * (c_in_w/2 + c_wall), b_in_h + 0.5]);
    plates();
}

// ---- insertion path: walls slid onto the panel's side tabs (a U, in the
//      air), the U lowered into the bottom plate, top plate on ----------------
module bottom_plate() rotate([180, 0, 0]) plate("bottom");
module left_wall_at(dy) translate([0, -b_in_w/2 - dy, 0]) rotate([90, 0, 0]) wall();
// expected EMPTY / face contact at every station
if (check == "path_wall_onto_panel") intersection() { left_wall_at(4); rear_placed(); }                  // approaching sideways
if (check == "path_u_drop")      intersection() { translate([0, 0, b_t/2]) { walls(); rear_placed(); } bottom_plate(); }   // half way down
if (check == "path_top_drop")    intersection() { translate([0, 0, b_in_h + b_t/2]) plate("top"); union() { walls(); rear_placed(); } }

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

// ---- accessories ---------------------------------------------------------------
// 2.5" adapter. expected EMPTY / face contact
if (check == "adapter_in_caddy") intersection() { caddy(); adapter25(); }
if (check == "hdd25_in_adapter") intersection() { hdd25(); union() { caddy(); adapter25(); } }
if (check == "plugs25_vs_rear")  intersection() { rear_placed(); sata_plugs(h25_dy); }
// expected NON-EMPTY: the caddy's pins hold the adapter, the adapter's the drive
if (check == "adapter_held") intersection() { caddy_tray(); translate([1.0, 0, 0]) adapter25(); }
if (check == "hdd25_held")   intersection() { adapter25(); translate([1.0, 0, 0]) hdd25(); }

// feet under a bottom plate. expected EMPTY / face contact, then NON-EMPTY
// for a foot shifted 1 mm (its pins sit in cells)
if (check == "feet_in_plate") intersection() { bay(); for (c = foot_cells) foot_placed(c); }
if (check == "feet_hold")     intersection() { bay(); translate([1.0, 0, 0]) foot_placed(foot_cells[0]); }

// width joiners between stacked bays: bay, joiner, bay
// columns touch directly; each layer sits on the joiner
module bays_w(cols) for (i = [0 : cols - 1]) translate([0, i * pitch_y, 0]) { bay(); translate([0, 0, pitch_z + jn_t]) bay(); }
// one bay: 0.5 + 0.5, the second turned round
module pair_w() { joiner_w_at(1, -b_w / 2, lock_lo = false); joiner_w_at(1, 0, lock_lo = false, turned = true); }
// a run of 0.5 + 1 + 0.5 across two columns, seams mid-bay
module run_w(k = -1) {
    if (k < 0 || k == 0) joiner_w_at(1, -b_w / 2, lock_lo = false);
    if (k < 0 || k == 1) joiner_w_at(2, 0);
    if (k < 0 || k == 2) joiner_w_at(1, b_w, lock_lo = false, turned = true);
}
// expected EMPTY / face contact: a pair of half joiners between two bays
if (check == "joiner_w_stack") intersection() { pair_w(); bays_w(1); }
// expected NON-EMPTY: the pair shifted 1 mm hits the bumps of both bays
if (check == "joiner_w_holds") intersection() { translate([1.0, 0, 0]) pair_w(); bays_w(1); }
// expected EMPTY / face contact: the run between two columns, and its pieces with each other
if (check == "joiner_w_run") union() {
    intersection() { run_w(); bays_w(2); }
    intersection() { run_w(0); run_w(1); }
    intersection() { run_w(1); run_w(2); }
}
// expected NON-EMPTY: the dovetails lock (end piece pulled 1 mm away hits the middle piece)
if (check == "joiner_w_locks") intersection() { run_w(1); translate([0, 1.0, 0]) run_w(2); }
// rows touch directly; columns are spaced by the joiner

// height joiners between bays side by side
module bays_h(rows) for (j = [0 : rows - 1]) translate([0, 0, j * pitch_z]) { bay(); translate([0, pitch_y + jn_t, 0]) bay(); }
module run_h(k = -1) {
    if (k < 0 || k == 0) joiner_h_at(1, b_z0, lock_lo = false);
    if (k < 0 || k == 1) joiner_h_at(2, b_z0 + jn_h_zone);
    if (k < 0 || k == 2) joiner_h_at(1, b_z0 + 3 * jn_h_zone, lock_lo = false, turned = true);
}
// expected EMPTY / face contact: two half pieces cover one bay height
if (check == "joiner_h_side") intersection() {
    union() { joiner_h_at(1, b_z0, lock_lo = false); joiner_h_at(1, b_z0 + jn_h_zone, lock_lo = false, turned = true); }
    bays_h(1);
}
if (check == "joiner_h_holds") intersection() { translate([1.0, 0, 0]) joiner_h_at(1, b_z0, lock_lo = false); bays_h(1); }
if (check == "joiner_h_run") union() {
    intersection() { run_h(); bays_h(2); }
    intersection() { run_h(0); run_h(1); }
    intersection() { run_h(1); run_h(2); }
}
if (check == "joiner_h_locks") intersection() { run_h(1); translate([0, 0, 1.0]) run_h(2); }
// three-high piece: 0.5 + 3 + 0.5 over four rows
module run_h3(k = -1) {
    if (k < 0 || k == 0) joiner_h_at(1, b_z0, lock_lo = false);
    if (k < 0 || k == 1) joiner_h_at(6, b_z0 + jn_h_zone);
    if (k < 0 || k == 2) joiner_h_at(1, b_z0 + 7 * jn_h_zone, lock_lo = false, turned = true);
}
if (check == "joiner_h3_run") union() {
    intersection() { run_h3(); bays_h(4); }
    intersection() { run_h3(0); run_h3(1); }
    intersection() { run_h3(1); run_h3(2); }
}
if (check == "joiner_h3_locks") intersection() { run_h3(1); translate([0, 0, 1.0]) run_h3(2); }
