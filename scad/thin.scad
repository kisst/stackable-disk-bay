// Thin-section check. Slices a part, in its print orientation, along one
// axis and emits the material thinner than `min_section` in each slice as
// a 0.2 mm wafer at the slice's position (in the part's own frame). A
// second group of wafers, shifted by `off` along the slice axis, marks
// where each thin region meets the thick material around it, so
// scripts/thin.sh can tell a neck or a roof (two or more contacts) from
// the harmless tapering tail a slice leaves when it grazes a sharp corner
// (one contact, short), and drop the 0.4 mm nibs the round dilation takes
// off every convex corner.
//   openscad -D part=\"wall\" -D axis=\"z\" -D pitch=0.4 -o out.stl scad/thin.scad
include <params.scad>
use <caddy.scad>
use <bay.scad>
use <accessories.scad>

part = "caddy_tray";
axis = "z";            // slice normal
pitch = 0.4;           // slice spacing; slices sit at the centres of the pitch
min_section = 0.8;     // two 0.4 mm perimeters
$fn = 24;

// each part as it lies on the bed
module body() {
    if (part == "caddy_tray") caddy_tray(protrusions = false);
    if (part == "bezel")      translate([0, 0, c_body_l + bezel_t]) rotate([0, 90, 0]) bezel();
    if (part == "plate")      plate("bottom");
    if (part == "wall")       wall();
    if (part == "rear")       rear();
    if (part == "adapter25")  translate([0, 0, -c_floor]) adapter25(protrusions = false);
    if (part == "foot")       translate([0, 0, foot_h]) foot();
    if (part == "joiner_w1" || part == "joiner_w05" || part == "joiner_h1" || part == "joiner_h05" || part == "joiner_h3") joiner_part(substr4(part));
}
// [[x0, x1], [y0, y1], [z0, z1]] of the body
ext = part == "caddy_tray" ? [[push_x1, c_body_l + bezel_t], [-c_w/2, c_w/2], [0, sp_top + sp_bump_h]] :
      part == "bezel"      ? [[b_z0, b_z1], [-b_w/2, b_w/2], [0, bezel_t]] :
      part == "plate"      ? [[b_x0, b_l], [-b_w/2, b_w/2], [0, b_t + bump_h]] :
      part == "wall"       ? [[b_x0, b_l], [-b_t, b_in_h + b_t], [0, b_wall + bump_h]] :
      part == "rear"       ? [[-b_in_w/2 - b_wall, b_in_w/2 + b_wall], [-b_t, b_in_h + b_t], [0, rear_t]] :
      part == "adapter25"  ? [[c_rear_gap, ad_len], [-hdd_w/2, hdd_w/2], [0, ad_h]] :
      part == "foot"       ? [[-foot_af, foot_af], [-foot_af, foot_af], [0, foot_h + foot_pin_h]] :
      part == "joiner_w1"  ? [[b_x0, b_l], [-jn_dt_depth, 2 * jn_w_zone + jn_dt_depth], [0, jn_t]] :
      part == "joiner_w05" ? [[b_x0, b_l], [0, jn_w_zone + jn_dt_depth], [0, jn_t]] :
      part == "joiner_h1"  ? [[b_x0, b_l], [-jn_dt_depth, 2 * jn_h_zone + jn_dt_depth], [0, jn_t]] :
      part == "joiner_h05" ? [[b_x0, b_l], [0, jn_h_zone + jn_dt_depth], [0, jn_t]] :
      part == "joiner_h3"  ? [[b_x0, b_l], [-jn_dt_depth, 6 * jn_h_zone + jn_dt_depth], [0, jn_t]] : undef;
// "joiner_w05" -> "w05"
function substr4(s) = str(s[7], s[8], len(s) > 9 ? s[9] : "");
ai = axis == "x" ? 0 : axis == "y" ? 1 : 2;
range = ext[ai];

// rotate the body so the slice normal is z, and back
module to_z()   { if (ai == 0) rotate([0, -90, 0]) children(); else if (ai == 1) rotate([90, 0, 0]) children(); else children(); }
module from_z() { if (ai == 0) rotate([0, 90, 0]) children();  else if (ai == 1) rotate([-90, 0, 0]) children(); else children(); }
function shift(s) = ai == 0 ? [-s, 0, 0] : ai == 1 ? [0, -s, 0] : [0, 0, -s];

module slice(s) projection(cut = true) to_z() translate(shift(s)) body();
// the slice opened by min_section/2: everything at least min_section thick.
// Erode with straight (mitred) edges, dilate with round ones: a mitred
// dilation would rebuild a sharp wedge exactly, however thin it gets.
module opened(s) { e = min_section / 2; offset(r = e) offset(delta = -e) slice(s); }
// what the opening removed: material thinner than min_section. The round
// dilation leaves zero-width slivers along the edges it rebuilt; a 0.02 mm
// opening drops those before they are measured or offset.
module thin2d(s) offset(delta = 0.01) offset(delta = -0.01) difference() { slice(s); opened(s); }
// where the thin material joins the thick: a hair-thin strip per contact
module contact2d(s) intersection() { offset(delta = 0.05) thin2d(s); opened(s); }

off = 1000;
n = floor((range[1] - range[0]) / pitch);
for (k = [0 : n]) {
    s = range[0] + pitch/2 + k * pitch;
    if (s < range[1]) {
        translate(-shift(s))       from_z() linear_extrude(height = 0.2, center = true) thin2d(s);
        translate(-shift(s + off)) from_z() linear_extrude(height = 0.2, center = true) contact2d(s);
    }
}
