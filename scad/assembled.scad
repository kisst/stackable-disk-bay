// One fully assembled unit for export: bay, caddy (springs preloaded under
// the top plate) and drive, without the SATA plugs. `drive` picks the 3.5"
// drive or the 2.5" drive in its adapter; `part` selects one printed part
// for a per-colour STL export ("plate_top", "plate_bottom", "wall_l",
// "wall_r", "rear", "tray", "bezel", "adapter", "hdd"); "" shows everything.
include <params.scad>
use <hdd.scad>
use <hdd25.scad>
use <caddy.scad>
use <bay.scad>
use <accessories.scad>

drive = "35";   // "35" or "25"
part = "";
function on(p) = part == "" || part == p;

if (on("plate_bottom")) color("SteelBlue")    rotate([180, 0, 0]) plate("bottom");
if (on("plate_top"))    color("LightSkyBlue") translate([0, 0, b_in_h]) plate("top");
if (on("wall_l"))       color("SeaGreen")     translate([0, -b_in_w/2, 0]) rotate([90, 0, 0]) wall();
if (on("wall_r"))       color("YellowGreen")  translate([b_x0 + b_l, b_in_w/2, 0]) rotate([0, 0, 180]) rotate([90, 0, 0]) wall();
if (on("rear"))         color("MediumPurple") rear_placed();
if (on("tray"))         color("Orange")       caddy_tray(spring_defl = sp_preload);
if (on("bezel"))        color("Chocolate")    bezel();
if (drive == "25" && on("adapter")) color("Gold") adapter25();
if (on("hdd")) color("DimGray") { if (drive == "25") hdd25(); else hdd(); }
