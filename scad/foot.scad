// Foot (print flat, pins up). Four under the bottom bay, pins into three
// neighbouring open cells of its bottom plate.
include <params.scad>
use <accessories.scad>
translate([0, 0, foot_h]) foot();
