// 2 x 2 combo: four loaded units, touching, located by bumps in cells.
include <params.scad>
use <hdd.scad>
use <caddy.scad>
use <bay.scad>

// `part` selects one class of part for a per-colour STL export
// ("plates", "walls", "rears", "caddies", "hdds"); "" shows everything.
part = "";
// `unit` selects one bay position for a per-unit export: 0 = (0,0), 1 = (0,1)
// [stacked], 2 = (1,0) [beside], 3 = (1,1); -1 = all
unit = -1;
function on(p) = part == "" || part == p;
function unit_on(i, j) = unit < 0 || unit == i * 2 + j;

module u(i, j) translate([0, i * pitch_y, j * pitch_z]) children();

for (i = [0, 1], j = [0, 1]) if (unit_on(i, j)) u(i, j) {
    if (on("plates"))  color("SteelBlue")  plates();
    if (on("walls"))   color("SeaGreen")   walls();
    if (on("rears"))   color("MediumPurple") rear_placed();
    if (on("caddies")) color("Orange")     caddy();
    if (on("hdds"))    color("DimGray")    hdd();
}

