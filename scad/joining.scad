// How bays join: exploded views of two bays stacked and two side by side
// (bumps into the neighbour's honeycomb cells, no extra part), plus cropped
// close-ups of one stacking joint and one side joint.
// `part` selects a class for per-colour export: "lower", "upper" for the
// joining views; "plates", "walls", "rears" for the assembly drawing.
include <params.scad>
use <bay.scad>

mode = "stack";     // "stack" | "side" | "detail"
part = "";
explode = 40;       // how far the upper/next bay is lifted away
function on(p) = part == "" || part == p;

module stack_scene(e = explode) {
    if (on("lower")) color("SteelBlue") bay();
    if (on("upper")) color("Orange")    translate([0, 0, pitch_z + e]) bay();
}
module side_scene(e = explode) {
    if (on("lower")) color("SteelBlue") bay();
    if (on("upper")) color("Orange")    translate([0, pitch_y + e, 0]) bay();
}

// assembly drawing: bottom plate, panel standing in it, walls out to the
// sides and lifted one plate thickness, top plate above
module assembly_scene(e = 30) {
    if (on("plates")) color("SteelBlue") { rotate([180, 0, 0]) plate("bottom"); translate([0, 0, b_in_h + e * 1.4]) plate("top"); }
    if (on("rears"))  color("MediumPurple") rear_placed();
    if (on("walls"))  color("SeaGreen") {
        translate([0, -b_in_w/2 - e, b_t]) rotate([90, 0, 0]) wall();
        translate([b_x0 + b_l, b_in_w/2 + e, b_t]) rotate([0, 0, 180]) rotate([90, 0, 0]) wall();
    }
}
if (mode == "assembly") assembly_scene();
if (mode == "stack") stack_scene();
if (mode == "side")  side_scene();
// close-up: one wall bump of the left bay under the open cell of the right bay's wall
if (mode == "detail_side") intersection() {
    side_scene(10);
    translate([wall_bumps[1][0] - 16, b_w/2 - 6, wall_bumps[1][1] - 16]) cube([32, 10 + 2.4 + 8 + 6, 32]);
}
// close-up: one plate bump of the lower bay under the open cell it drops into
if (mode == "detail") intersection() {
    stack_scene(10);
    translate([plate_bumps[0][0] - 16, plate_bumps[0][1] - 16, b_z1 - 6]) cube([32, 32, 10 + 2.4 + 8 + 6]);
}
