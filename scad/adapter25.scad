// 2.5" drive adapter (print flat on its base). Goes into the caddy like a
// 3.5" drive; the 2.5" drive hangs on its three pins.
include <params.scad>
use <accessories.scad>
translate([0, 0, -c_floor]) adapter25();
