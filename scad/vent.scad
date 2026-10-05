// Ventilation alignment: how much of the drive's underside sees open air
// straight through both the caddy floor and the bay's bottom plate.
// Each `which` exports a 1 mm extrusion of a 2D region, so its STL volume
// equals the area in mm^2 (scripts/vent.sh reads it back).
include <params.scad>
use <caddy.scad>
use <bay.scad>

which = "through";
$fn = 24;

// footprint under the drive (the region that matters for cooling)
module footprint() square([hdd_l, hdd_w], center = false);
module fp() translate([0, -hdd_w/2]) footprint();

// 2D: open cells of the caddy floor, cut at mid-thickness
module floor_open() difference() { fp(); projection(cut = true) translate([0, 0, -c_floor/2]) caddy_tray(); }
// 2D: open cells of the bay's bottom plate
module plate_open() difference() { fp(); projection(cut = true) translate([0, 0, b_t/2]) rotate([180, 0, 0]) plate("bottom"); }

linear_extrude(height = 1) {
    if (which == "footprint") fp();
    if (which == "floor")     floor_open();
    if (which == "plate")     plate_open();
    if (which == "through")   intersection() { floor_open(); plate_open(); }
}
