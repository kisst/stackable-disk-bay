#!/usr/bin/env python3
"""Shared params + emit helpers for the full SolidCraft port of the disk bay.

Import this from the per-part generators.  `cmds` collects commands; `add()`
appends one.  Constants mirror scad/params.scad.  Honeycomb is emitted as two
staggered `sketch.pattern.rectangular` cuts plus hex plugs over the keep-out
cells (see emit_honeycomb_patterned), not one cut per cell."""
import json, math, sys

# ---- params (scad/params.scad) -------------------------------------------
hdd_w, hdd_l, hdd_h = 101.6, 147.0, 26.1
clr, slide_clr = 0.3, 0.4
c_floor, c_wall, c_wall_h, c_frame = 2.0, 2.4, 25.0, 6.0
c_in_w = hdd_w + 2 * clr
c_w = c_in_w + 2 * c_wall
c_front_gap = 0.5
c_body_l = hdd_l + c_front_gap
b_t, b_wall = 2.4, 2.4
b_in_w = c_w + 2 * slide_clr
b_in_h = c_floor + hdd_h + 1.9
b_w = b_in_w + 2 * b_wall
b_h = b_in_h + 2 * b_t
b_l = c_body_l
b_x0 = -5.0
b_xc = (b_x0 + b_l) / 2.0
tab_len, tab_clr = 14.0, 0.15
tab_x = [b_xc - 54, b_xc, b_xc + 54]

rear_t = 2.4
rear_x = b_x0 + 1.4
rear_tab = 12.0
rear_tab_y_top = [-40, -12, 12, 40]
rear_tab_y_bot = [-40, -12]
rear_fit_clr = 0.08
rear_tab_z = 19.0
wall_slot_x = [rear_x + rear_t / 2, b_x0 + b_l - (rear_x + rear_t / 2)]
rear_clr = 0.2
sata_notch_y, sata_notch_z = -3.0, 12.5

hex_cell, hex_web = 6.0, 1.8
w_hex_cell, w_hex_web = hex_cell, hex_web
b_vent_rim, w_vent_rim = 6.0, 4.0
b_keep_margin = 1.5
c_hex_cell, c_hex_web, c_wall_rim = hex_cell, hex_web, 3.0
bz_hex_cell, bz_hex_web = hex_cell, hex_web

hex_dx = hex_cell + hex_web
hex_dy = hex_dx * math.sqrt(3) / 2
bump_h = 1.4
plate_bump_af = hex_cell - 0.4
wall_bump_af = plate_bump_af


def plate_cell(i, j):
    return [b_xc + i * hex_dx + (0 if j % 2 == 0 else hex_dx / 2), j * hex_dy]


def wall_cell(i, j):
    return [b_xc + i * hex_dx + (0 if j % 2 == 0 else hex_dx / 2), b_in_h / 2 + j * hex_dy]


plate_bump_cells = [[-6, 6], [6, 6], [-4, -6], [8, -6]]
plate_bumps = [plate_cell(c[0], c[1]) for c in plate_bump_cells]
wall_bump_cells = [[-8, 1], [4, 1], [-8, -1], [4, -1]]
wall_bumps = [wall_cell(c[0], c[1]) for c in wall_bump_cells]

# ---- honeycomb reference math (scad/lib.scad hex_holes) -------------------


def bump_keep(x, y, cx, cy, af):
    r = af / math.sqrt(3) + b_keep_margin
    return [x - r - cx, y - r - cy, x + r - cx, y + r - cy]


def hits_keep(cx, cy, r, keep):
    for k in keep:
        if cx + r > k[0] and cx - r < k[2] and cy + r > k[1] and cy - r < k[3]:
            return True
    return False


def _lattice(size, cell, web, keep, phase):
    """Yield (i, j, cx, cy) for whole cells, in the part-local frame."""
    r = cell / math.sqrt(3)
    dx = cell + web
    dy = dx * math.sqrt(3) / 2
    nx = math.ceil(size[0] / dx) + 1
    ny = math.ceil(size[1] / dy) + 1
    for j in range(-ny - 1, ny + 2):
        for i in range(-nx - 1, nx + 2):
            cx = i * dx + (0 if j % 2 == 0 else dx / 2) + phase[0]
            cy = j * dy + phase[1]
            if (abs(cx) + cell / 2 <= size[0] / 2 and abs(cy) + r <= size[1] / 2
                    and not hits_keep(cx, cy, r, keep)):
                yield i, j, cx, cy


def hex_cells(size, cell, web, keep, cx_off, cy_off, phase=(0, 0)):
    """World (x, y) centres of the open cells, matching hex_holes(); returns (cells, r)."""
    r = cell / math.sqrt(3)
    return [(cx + cx_off, cy + cy_off)
            for _, _, cx, cy in _lattice(size, cell, web, keep, phase)], r


# ---- command emission ----------------------------------------------------
cmds = []


def add(c, p):
    cmds.append({"command": c, "params": p})


def add_params():
    for n, v in [("b_l", b_l), ("b_x0", b_x0), ("b_in_w", b_in_w), ("b_w", b_w),
                 ("b_t", b_t), ("b_wall", b_wall), ("b_in_h", b_in_h),
                 ("tab_len", tab_len), ("tab_clr", tab_clr),
                 ("b_xc", "(b_x0 + b_l) / 2")]:
        add("parameters.add", {"name": n, "expression": str(v), "unit": "mm"})


def emit_hex(cx, cy, r, z0, dist, op, targets=None):
    """Sketch one hex (circumradius r, rotated 30deg) on XY at z0, extrude."""
    add("sketch.create", {"plane": "XY", "offset": round(z0, 4)})
    add("sketch.polygon.inscribed", {"center": [round(cx, 4), round(cy, 4)],
                                      "radius": round(r, 4), "sides": 6, "angle": 30})
    add("sketch.finish", {})
    p = {"distance": dist, "operation": op}
    if targets:
        p["targets"] = targets
    add("solid.extrude", p)


def emit_honeycomb_patterned(size, keep, cx_off, cy_off, z0, t, phase=(0, 0),
                             cell=hex_cell, web=hex_web, targets=None):
    """Cut the staggered honeycomb through [z0, z0+t] with two rectangular
    patterns (even rows, odd rows), then join hex plugs back over every cell
    the keep-outs excluded.  Returns (n_open_cells, n_plugs)."""
    r = cell / math.sqrt(3)
    dx = cell + web
    dy = dx * math.sqrt(3) / 2
    full = list(_lattice(size, cell, web, [], phase))
    kept = {(i, j) for i, j, _, _ in _lattice(size, cell, web, keep, phase)}
    for par in (0, 1):
        sel = [c for c in full if c[1] % 2 == par]
        if not sel:
            continue
        iset = sorted({c[0] for c in sel})
        jset = sorted({c[1] for c in sel})
        assert iset == list(range(iset[0], iset[-1] + 1)), "non-contiguous columns"
        assert jset == list(range(jset[0], jset[-1] + 2, 2)), "non-contiguous rows"
        assert len(sel) == len(iset) * len(jset), "field is not rectangular"
        x0 = iset[0] * dx + (0 if par == 0 else dx / 2) + phase[0] + cx_off
        y0 = jset[0] * dy + phase[1] + cy_off
        add("sketch.create", {"plane": "XY", "offset": round(z0 - 1, 4)})
        add("sketch.polygon.inscribed", {"center": [round(x0, 4), round(y0, 4)],
                                          "radius": round(r, 4), "sides": 6, "angle": 30})
        pat = {"entities": ["l1", "l2", "l3", "l4", "l5", "l6"],
               "count": len(iset), "spacing": round(dx, 4)}
        if len(jset) > 1:
            pat.update({"count2": len(jset), "spacing2": round(2 * dy, 4)})
        add("sketch.pattern.rectangular", pat)
        add("sketch.finish", {})
        add("solid.extrude", {"distance": str(t + 2), "operation": "cut"})
    plugs = [(cx + cx_off, cy + cy_off) for i, j, cx, cy in full if (i, j) not in kept]
    if plugs:
        add("sketch.create", {"plane": "XY", "offset": round(z0, 4)})
        for cx, cy in plugs:
            add("sketch.polygon.inscribed", {"center": [round(cx, 4), round(cy, 4)],
                                              "radius": round(r, 4), "sides": 6, "angle": 30})
        add("sketch.finish", {})
        p = {"distance": str(t), "operation": "join"}
        if targets:
            p["targets"] = targets
        add("solid.extrude", p)
    return len(kept), len(plugs)


def dump(path):
    with open(path, "w") as f:
        json.dump(cmds, f, indent=1)


def _demo(path):
    """Plate-sized slab with the bottom plate's honeycomb (bumps + slots as keep-outs)."""
    add("solid.box", {"length": str(b_l - b_x0), "width": str(b_w), "height": str(b_t),
                      "corner": [str(b_x0), str(-b_w / 2), str(-b_t)],
                      "operation": "new", "name": "slab", "body_name": "slab"})
    keep = [bump_keep(b[0], b[1], b_xc, 0, plate_bump_af) for b in plate_bumps]
    for x in tab_x:
        for s in (-1, 1):
            keep.append([x - tab_len / 2 - b_keep_margin - b_xc,
                         s * b_in_w / 2 - 3 - b_keep_margin,
                         x + tab_len / 2 + b_keep_margin - b_xc,
                         s * b_in_w / 2 + 3 + b_keep_margin])
    size = [b_l - b_x0 - 2 * b_vent_rim, b_in_w - 2 * b_vent_rim]
    n, plugs = emit_honeycomb_patterned(size, keep, b_xc, 0.0, -b_t, b_t, targets=["slab"])
    dump(path)
    print(f"open cells {n}, plugs {plugs}, commands {len(cmds)}")
    return n, size, keep


if __name__ == "__main__":
    _demo(sys.argv[1] if len(sys.argv) > 1 else "hc_demo.json")
