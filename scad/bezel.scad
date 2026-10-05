// Caddy bezel (print flat, FRONT FACE DOWN: the handle bar lies on the bed).
// Slots take the tray's tabs.
include <params.scad>
use <caddy.scad>
rotate([0, -90, 0]) bezel();   // lay it front-face down for the STL
