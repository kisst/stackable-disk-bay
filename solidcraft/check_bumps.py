#!/usr/bin/env python3
"""No-extra-part joining invariant: each bump centre must be an open
(un-plugged) honeycomb cell of the mating part (scad hex_holes cell centres)."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_full as g

TOL = 1e-6


def open_cells(size, keep, cx, cy):
    return g.hex_cells(size, g.hex_cell, g.hex_web, keep, cx, cy)[0]


def near(p, cells):
    d = min(((p[0] - c[0]) ** 2 + (p[1] - c[1]) ** 2) ** 0.5 for c in cells)
    return d


ok = True
pt, pb = g.plate_geometry("top"), g.plate_geometry("bottom")
ot = open_cells(pt["size"], pt["keep"], g.b_xc, 0.0)
ob = open_cells(pb["size"], pb["keep"], g.b_xc, 0.0)
for nm, bumps, cells in (("top bumps -> bottom open cells", pt["bumps"], ob),
                         ("bottom bumps -> top open cells", pb["bumps"], ot)):
    for b in bumps:
        d = near(b, cells)
        ok &= d < TOL
        print(f"{nm}: bump ({b[0]:.3f},{b[1]:.3f}) nearest open-cell distance {d:.6f}")
wsize = [g.b_l - g.b_x0 - 2 * g.w_vent_rim, g.b_in_h - 2 * g.w_vent_rim]
ow = open_cells(wsize, g.wall_keep(), g.b_xc, g.b_in_h / 2)
# wall_r is wall_l turned 180 deg about z (x -> b_x0+b_l-x), same height y
for b in g.wall_bumps:
    p = (g.b_x0 + g.b_l - b[0], b[1])
    d = near(p, ow)
    ok &= d < TOL
    print(f"wall_r bump world-x/h ({p[0]:.3f},{p[1]:.3f}) -> wall_l open cell distance {d:.6f}")
print("BUMP-INVARIANT", "OK" if ok else "FAIL")
sys.exit(0 if ok else 1)
