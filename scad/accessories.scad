// Accessories: the 2.5" drive adapter, feet, and joiner plates. Modules in
// the shared frame where they have a natural place (adapter in the caddy,
// foot under a bottom plate), in their own flat frame otherwise.
include <lib.scad>

// horizontal hole along y through a wall, teardrop-pointed up so it prints
// without support (the wall stands vertical on the bed)
module teardrop_y(x, z, d, y0, y1) {
    translate([x, max(y0, y1), z]) rotate([90, 0, 0]) linear_extrude(height = abs(y1 - y0)) {
        circle(d = d);
        rotate(45) square(d / 2);            // 90-degree point up
    }
}
// pin along +y (s = 1) or -y from a wall face at y0, conical tip
module side_pin(x, z, y0, s, d, len) {
    translate([x, y0 - s * 0.01, z]) rotate([s > 0 ? -90 : 90, 0, 0]) {
        cylinder(d = d, h = len - 0.8 + 0.01);
        translate([0, 0, len - 0.8]) cylinder(d1 = d, d2 = d * 0.45, h = 0.8);
    }
}

// ---- 2.5" adapter ------------------------------------------------------------
// In the caddy in place of a 3.5" drive (shared frame, z from the caddy
// floor up). The drive sits against the +y side, where its SATA connector
// is. It hangs on three pins: two on the -y rail, one on the +y strip near
// its free end. Tilt the drive onto the rail's pins, press the other side
// down: the strip flexes out and its pin snaps in. In the caddy the strip is
// backed by the caddy wall, so the drive cannot come out.
module adapter25(protrusions = true) {
    x0 = c_rear_gap;  x1 = ad_len;
    ys = hdd_w/2;     yr = -hdd_w/2;                 // strip side (+y), rail side (-y)
    z0 = c_floor;     zt = c_floor + ad_h;
    yo = yr + ad_wall;                               // outer rail's inner face
    difference() {
        union() {
            box([x0, ys, z0], [x1, ys - ad_strip_t, zt]);                 // +y strip
            box([x0, ad_in_y, z0], [h25_x1 + ad_wall, ad_in_y - ad_wall, zt]);   // -y inner rail, beside the drive
            box([x0, yo, z0], [x1, yr, zt]);                               // -y outer rail
            box([x0, ad_in_y, z0], [x1, yr, z0 + ad_base]);                // base beside the drive
            box([h25_x1, ys, z0], [x1, yr, z0 + ad_base]);                 // base in front of it
            box([h25_x1, ys, z0], [h25_x1 + ad_wall, yr, zt]);             // cross rib at the drive's front
            box([x1 - ad_wall, ys, z0], [x1, yr, zt]);                     // front end rib
            for (x = [x0, (x0 + h25_x1) / 2 - ad_wall / 2])                // ribs across the -y rail
                box([x, ad_in_y, z0], [x + ad_wall, yr, zt]);
        }
        // the caddy's pins: finger ones through the strip, fixed ones through the outer rail
        for (x = hdd_side_hole_x) {
            teardrop_y(x, pin_z, ad_hole_d, ys + 1, ys - ad_strip_t - 1);
            teardrop_y(x, pin_z, ad_hole_d, yo + 1, yr - 1);
        }
        // vents in the base, on the caddy floor's lattice (y ranges as [from, to])
        for (r = [[ad_in_y - ad_wall, yo, x0 + ad_wall, h25_x1], [ys - ad_strip_t, yo, h25_x1 + ad_wall, x1 - ad_wall]]) {
            cx = (r[2] + r[3]) / 2;  cy = (r[0] + r[1]) / 2;
            translate([cx, cy, z0 + ad_base / 2])
                honeycomb_cut([r[3] - r[2] - 3, abs(r[1] - r[0]) - 3], ad_base + 2, c_hex_cell, c_hex_web,
                              [[(x0 + h25_x1) / 2 - ad_wall / 2 - 2 - cx, -50, (x0 + h25_x1) / 2 + ad_wall / 2 + 2 - cx, 50]],
                              [b_xc - cx, -cy]);
        }
    }
    // pins into the 2.5" drive: two from the -y rail, one from the +y strip
    if (protrusions) for (x = h25_hole_x) side_pin(x, c_floor + h25_hole_z, ad_in_y, 1, ad_pin_d, ad_pin_len + ad_clr);
    if (protrusions) side_pin(h25_hole_x[0], c_floor + h25_hole_z, ys - ad_strip_t, -1, ad_pin_d, ad_pin_len + ad_clr);
}

// ---- foot --------------------------------------------------------------------
// Own frame: top face at z = 0, body below, pins up. foot_placed() puts one
// under a bottom plate at cell cluster c = [i, j].
function foot_pins() = [[-hex_dx / 2, -hex_dy / 3], [hex_dx / 2, -hex_dy / 3], [0, 2 * hex_dy / 3]];
module foot() {
    translate([0, 0, -foot_h]) linear_extrude(height = foot_h) rotate(30) circle(r = foot_af / sqrt(3), $fn = 6);
    for (p = foot_pins()) translate([p[0], p[1], 0])
        linear_extrude(height = foot_pin_h, scale = 0.93) rotate(30) circle(r = plate_bump_af / sqrt(3), $fn = 6);
}
function foot_centre(c) = let(a = plate_cell(c[0], c[1])) [a[0] + hex_dx / 2, a[1] + hex_dy / 3];
module foot_placed(c) translate([foot_centre(c)[0], foot_centre(c)[1], b_z0]) foot();

// ---- joiner plates -----------------------------------------------------------
// Own frame: u = x along the bay (b_x0 .. b_l), v across the joint from 0 to
// n half zones, w = 0 .. jn_t. fam "w" (between stacked bays, zones half a
// bay wide) or "h" (between bays side by side, zones half a bay high).
// lock_lo / lock_hi: dovetails on the v = 0 / v = top edge.
function jn_zone(fam) = fam == "w" ? jn_w_zone : jn_h_zone;
module dovetail2d(u, v, dir, grow = 0) {       // neck on v, head toward dir (+1 / -1)
    offset(delta = grow) polygon([[u - jn_dt_neck / 2, v - dir * 0.01], [u + jn_dt_neck / 2, v - dir * 0.01],
                                  [u + jn_dt_head / 2, v + dir * jn_dt_depth], [u - jn_dt_head / 2, v + dir * jn_dt_depth]]);
}
// honeycomb cells of zone k: a bay half's lattice, rows counted from the
// zone edge that lies on the bay's centre line (`from` = 0: the lower edge,
// 1: the upper edge). Whole cells only, a web from every edge and dovetail.
module jn_cells(fam, n, k, from, lock_lo, lock_hi) {
    Z = jn_zone(fam);  V = n * Z;  r = hex_cell / sqrt(3);  m = jn_edge;
    v0 = from == 0 ? k * Z : (k + 1) * Z;  sg = from == 0 ? 1 : -1;
    dts = concat(lock_hi ? [for (t = jn_dt) [b_xc + t, V], for (t = jn_dt) [b_xc - t, V]] : [],
                 lock_lo ? [for (t = jn_dt) [b_xc - t, 0], for (t = jn_dt) [b_xc + t, 0]] : []);
    for (j = [0 : ceil(Z / hex_dy)], i = [-12 : 12]) {
        u = b_xc + i * hex_dx + (j % 2 == 0 ? 0 : hex_dx / 2);
        v = v0 + sg * j * hex_dy;
        near_dt = len([for (d = dts) if (abs(u - d[0]) < jn_dt_head / 2 + hex_cell / 2 + m &&
                                         abs(v - d[1]) < jn_dt_depth + r + m) 1]) > 0;
        if (u - hex_cell / 2 >= b_x0 + m && u + hex_cell / 2 <= b_l - m &&
            v - r >= k * Z + m && v + r <= (k + 1) * Z - m && !near_dt)
            translate([u, v]) rotate(30) circle(r = r, $fn = 6);
    }
}
module joiner2d(fam, n, lock_lo = true, lock_hi = true) {
    Z = jn_zone(fam);  V = n * Z;
    difference() {
        union() {
            translate([b_x0, 0]) square([b_l - b_x0, V]);
            if (lock_hi) for (t = jn_dt) dovetail2d(b_xc + t, V, 1);        // tabs up
            if (lock_lo) for (t = jn_dt) dovetail2d(b_xc - t, 0, -1);       // tabs down, mirrored
        }
        if (lock_hi) for (t = jn_dt) dovetail2d(b_xc - t, V, -1, jn_dt_clr);   // sockets for the piece above
        if (lock_lo) for (t = jn_dt) dovetail2d(b_xc + t, 0, 1, jn_dt_clr);    // and below
        // half piece: its upper edge is a bay's centre line. Longer pieces
        // run from one bay's centre line to another's, so the zones alternate:
        // even ones count rows from their lower edge, odd ones from their upper
        if (n == 1) jn_cells(fam, 1, 0, 1, lock_lo, lock_hi);
        else for (k = [0 : n - 1]) jn_cells(fam, n, k, k % 2 == 0 ? 0 : 1, lock_lo, lock_hi);
    }
}
module joiner(fam, n, lock_lo = true, lock_hi = true) linear_extrude(height = jn_t) joiner2d(fam, n, lock_lo, lock_hi);
// the half pieces lock on their upper (centre-line) edge only; turn one round
// for the other half
module joiner_part(kind) {
    if (kind == "w1")  joiner("w", 2);
    if (kind == "w05") joiner("w", 1, lock_lo = false);
    if (kind == "h1")  joiner("h", 2);
    if (kind == "h05") joiner("h", 1, lock_lo = false);
    if (kind == "h3")  joiner("h", 6);              // three bays high
}
// placed in the shared frame: a width joiner on top of the bay at the origin,
// starting at y = y0; a height joiner on the +y face of that bay, starting
// at z = z0
module joiner_w_at(n, y0, lock_lo = true, lock_hi = true, turned = false)
    translate([0, y0, b_z1]) turn_uv(turned, n * jn_w_zone) joiner("w", n, lock_lo, lock_hi);
module joiner_h_at(n, z0, lock_lo = true, lock_hi = true, turned = false)
    translate([0, b_w / 2 + jn_t, z0]) rotate([90, 0, 0]) turn_uv(turned, n * jn_h_zone) joiner("h", n, lock_lo, lock_hi);
// in-plane half turn of a piece about its centre
module turn_uv(turned, V) {
    if (turned) translate([b_x0 + b_l, V, 0]) rotate([0, 0, 180]) children();
    else children();
}
