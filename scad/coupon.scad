// Pin coupon: a 34 mm slice of the caddy holding one fixed pin and one
// finger pin, plus the floor between them. Prints in well under an hour and
// answers the first questions a real drive asks: do 2.6 mm pins seat in the
// tapped holes, is the finger stiff enough, does the fingernail groove work.
// Hook the drive's rear side holes onto it exactly as into the full caddy.
include <params.scad>
use <caddy.scad>

testfit_x = [18, 52];   // covers finger 1 (22.6..46.3) and the rear pin (28.5), stops short of the spring lock (53..113)

intersection() {
    caddy();
    translate([testfit_x[0], -100, -1]) cube([testfit_x[1] - testfit_x[0], 200, 50]);
}
