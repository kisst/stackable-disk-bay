// Test fit: one assembled unit — bay (plates + walls), caddy, drive — in the
// shared frame. `show_top = false` lifts the top plate off so the drive,
// the pins and the fingers are visible in the render.
include <params.scad>
use <hdd.scad>
use <sata_plugs.scad>
use <caddy.scad>
use <bay.scad>

show_top = true;
// `part` selects one class for a per-colour STL export
// ("plates", "walls", "rears", "trays", "bezels", "hdds", "plugs"); "" shows everything.
part = "";
function on(p) = part == "" || part == p;

if (on("plates"))  color("SteelBlue")    plates(show_top);
if (on("walls"))   color("SeaGreen")     walls();
if (on("rears"))   color("MediumPurple") rear_placed();
if (on("trays"))   color("Orange")       caddy_tray();
if (on("bezels"))  color("Chocolate")    bezel();
if (on("hdds"))    color("DimGray")      hdd();
if (on("plugs"))   color("DarkRed")      sata_plugs();
