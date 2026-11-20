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
bezel_t = 2.0
pin_z = c_floor + 6.35
b_z0, b_z1 = -b_t, b_in_h + b_t
bz_pull_y = b_w / 2 - 8 - 36.0 / 2
bz_pull_w, bz_pull_wb, bz_pull_d, bz_pull_r, bz_pull_f = 36.0, 20.0, 10.0, 4.0, 3.0
bz_tab_h, bz_tab_w = 8.0, 60.0
bz_tab_clr, bz_floor_clr, bz_end_clr = 0.08, 0.05, 0.15
bz_lip_d, bz_lip_t, bz_lip_c = 2.0, 1.4, 0.5

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

# caddy-lock slot (scad/params.scad sp_*): derived from sp_x as there
sp_x = [56, 110]
sp_lock, sp_preload, sp_flat, sp_lead, sp_hold, sp_hole_clr = 1.0, 0.4, 1.2, 30.0, 45.0, 0.3
sp_bump_x = (sp_x[0] + sp_x[1]) / 2
sp_hole_x = [sp_bump_x - sp_flat / 2 - (sp_lock - sp_preload) / math.tan(math.radians(sp_lead)) - sp_hole_clr,
             sp_bump_x + sp_flat / 2 + (sp_lock - sp_preload) / math.tan(math.radians(sp_hold))]
sp_hole_y = [c_in_w / 2 - slide_clr - 0.15, b_in_w / 2]
b_in_h_top = b_in_h  # assembled z of the top plate's underside

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


def plate_geometry(kind):
    """Plate features in the ASSEMBLED frame (scad/assembled.scad).  The bottom
    plate is rotate([180,0,0]), so local (y, z) -> world (-y, -z).  Returns a
    dict: z0 (underside z of the slab, world), sy (+1/-1 y mirror), slots
    [(cx, cy, l, w, clr)], caddy [(x0, y0, x1, y1)], bumps [(x, y)], keep
    [rects relative to (b_xc, 0)], size."""
    assert kind in ("top", "bottom")
    sy = 1 if kind == "top" else -1
    rear_y = rear_tab_y_top if kind == "top" else [-y for y in rear_tab_y_bot]
    slots = [(x, s * (b_in_w / 2 + b_wall / 2), tab_len, b_wall, tab_clr)
             for x in tab_x for s in (-1, 1)]
    slots += [(rear_x + rear_t / 2, y, rear_t, rear_tab, rear_fit_clr) for y in rear_y]
    caddy = []
    if kind == "top":
        for s in (-1, 1):
            ys = sorted([s * sp_hole_y[0], s * sp_hole_y[1]])
            caddy.append((sp_hole_x[0], ys[0], sp_hole_x[1], ys[1]))
    keep = [bump_keep(b[0], b[1], b_xc, 0, plate_bump_af) for b in plate_bumps]
    keep += [[x - tab_len / 2 - b_keep_margin - b_xc, s * b_in_w / 2 - 3 - b_keep_margin,
              x + tab_len / 2 + b_keep_margin - b_xc, s * b_in_w / 2 + 3 + b_keep_margin]
             for x in tab_x for s in (-1, 1)]
    keep += [[rear_x - b_keep_margin - b_xc, y - rear_tab / 2 - b_keep_margin,
              rear_x + rear_t + b_keep_margin - b_xc, y + rear_tab / 2 + b_keep_margin]
             for y in rear_y]
    keep += [[c[0] - b_keep_margin - b_xc, c[1] - b_keep_margin,
              c[2] + b_keep_margin - b_xc, c[3] + b_keep_margin] for c in caddy]
    bumps = [list(b) for b in plate_bumps]
    if sy < 0:  # local -> world y mirror (slots, keep-outs and bumps alike)
        slots = [(x, -y, l, w, c) for x, y, l, w, c in slots]
        keep = [[k[0], -k[3], k[2], -k[1]] for k in keep]
        bumps = [[b[0], -b[1]] for b in bumps]
    return {"z0": b_in_h_top if kind == "top" else -b_t, "sy": sy, "slots": slots,
            "caddy": caddy, "bumps": bumps, "keep": keep,
            "size": [b_l - b_x0 - 2 * b_vent_rim, b_in_w - 2 * b_vent_rim]}


def emit_plate(kind):
    """Emit a complete plate component (body `plate_<kind>`) in the assembled
    frame: top at z [b_in_h, b_in_h+b_t] with bumps +z, bottom at z [-b_t, 0]
    with bumps -z.  Returns (n_open_cells, n_plugs)."""
    g = plate_geometry(kind)
    z0, name = g["z0"], f"plate_{kind}"
    zc = z0 + b_t / 2
    add_params()
    add("component.create", {"name": f"Plate_{kind}", "activate": True})
    add("solid.box", {"length": "b_l - b_x0", "width": "b_w", "height": "b_t",
                      "corner": ["b_x0", "-b_w/2", str(z0)],
                      "operation": "new", "name": name, "body_name": name})
    for cx, cy, l, w, c in g["slots"]:
        add("solid.box", {"length": str(round(l + 2 * c, 4)), "width": str(round(w + 2 * c, 4)),
                          "height": "b_t + 2", "center": [str(round(cx, 4)), str(round(cy, 4)), str(zc)],
                          "operation": "cut"})
    for x0, y0, x1, y1 in g["caddy"]:
        add("solid.box", {"length": str(round(x1 - x0, 4)), "width": str(round(y1 - y0, 4)),
                          "height": "b_t + 2",
                          "center": [str(round((x0 + x1) / 2, 4)), str(round((y0 + y1) / 2, 4)), str(zc)],
                          "operation": "cut"})
    n, plugs = emit_honeycomb_patterned(g["size"], g["keep"], b_xc, 0.0, z0, b_t, targets=[name])
    r = plate_bump_af / math.sqrt(3)
    for bx, by in g["bumps"]:
        zs = z0 + b_t if kind == "top" else z0 - bump_h
        emit_hex(bx, by, r, zs, str(bump_h), "join", [name])
    ref, _ = hex_cells(g["size"], hex_cell, hex_web, g["keep"], b_xc, 0.0)
    assert n == len(ref), f"open cells {n} != hex_cells {len(ref)}"
    return n, plugs


groove_z, groove_w, groove_d = 1.8, 1.0, 0.6


def wall_keep():
    """Honeycomb keep-out rects of the wall, relative to (b_xc, b_in_h/2)."""
    keep = [bump_keep(b[0], b[1], b_xc, b_in_h / 2, wall_bump_af) for b in wall_bumps]
    keep += [[x - rear_t / 2 - b_keep_margin - b_xc, -50, x + rear_t / 2 + b_keep_margin - b_xc, 50]
             for x in wall_slot_x]
    return keep


def emit_wall(kind):
    """Emit a wall (`wall_l` / `wall_r`).  Built in its own frame (x along the
    bay, y height, z thickness, bumps +z) like scad/bay.scad:wall(), then moved
    by a rigid matrix into the assembled pose of scad/bay.scad:walls():
    l: translate([0,-b_in_w/2,0]) rotate([90,0,0]); r: the same turned 180 deg
    about z at x = b_x0 + b_l, y = +b_in_w/2.  Returns (n_open_cells, n_plugs)."""
    assert kind in ("l", "r")
    name = f"wall_{kind}"
    add_params()
    add("component.create", {"name": f"Wall_{kind}", "activate": True})
    add("solid.box", {"length": "b_l - b_x0", "width": "b_in_h", "height": "b_wall",
                      "corner": ["b_x0", "0", "0"], "operation": "new", "name": name, "body_name": name})
    for x in tab_x:
        for y0 in (-b_t, b_in_h):
            add("solid.box", {"length": "tab_len", "width": "b_t", "height": "b_wall",
                              "corner": [str(round(x - tab_len / 2, 4)), str(round(y0, 4)), "0"],
                              "operation": "join", "targets": [name]})
    for x in wall_slot_x:
        c = rear_fit_clr
        add("solid.box", {"length": str(round(rear_t + 2 * c, 4)), "width": str(round(rear_tab + 2 * c, 4)),
                          "height": "b_wall + 2",
                          "center": [str(round(x, 4)), str(rear_tab_z), "b_wall/2"], "operation": "cut",
                          "targets": [name]})
    add("solid.box", {"length": "b_l - b_x0 + 2", "width": str(groove_w), "height": str(groove_d + 1),
                      "corner": ["b_x0 - 1", str(round(groove_z - groove_w / 2, 4)), str(round(b_wall - groove_d, 4))],
                      "operation": "cut", "targets": [name]})
    size = [b_l - b_x0 - 2 * w_vent_rim, b_in_h - 2 * w_vent_rim]
    keep = wall_keep()
    n, plugs = emit_honeycomb_patterned(size, keep, b_xc, b_in_h / 2, 0.0, b_wall, targets=[name])
    r = wall_bump_af / math.sqrt(3)
    for bx, by in wall_bumps:
        emit_hex(bx, by, r, b_wall, str(bump_h), "join", [name])
    ref, _ = hex_cells(size, hex_cell, hex_web, keep, b_xc, b_in_h / 2)
    assert n == len(ref), f"open cells {n} != hex_cells {len(ref)}"
    if kind == "l":
        m = [[1, 0, 0, 0], [0, 0, -1, -b_in_w / 2], [0, 1, 0, 0]]
    else:
        m = [[-1, 0, 0, b_x0 + b_l], [0, 0, 1, b_in_w / 2], [0, 1, 0, 0]]
    add("solid.move", {"bodies": [name], "matrix": [[round(v, 6) for v in row] for row in m]})
    return n, plugs


def emit_rear():
    """Emit the rear panel (`rear`).  Built in its own frame like
    scad/bay.scad:rear() (x across, y height 0..b_in_h, z thickness, outer
    face z=0), then moved by a rigid matrix into the assembled pose of
    rear_placed(): translate([rear_x,0,0]) rotate([90,0,90]) (x->y, y->z, z->x).
    Returns (n_open_cells, n_plugs)."""
    name = "rear"
    w = b_in_w - 2 * rear_clr
    add_params()
    add("component.create", {"name": "Rear", "activate": True})
    add("solid.box", {"length": str(round(w, 4)), "width": "b_in_h", "height": str(rear_t),
                      "corner": [str(round(-w / 2, 4)), "0", "0"],
                      "operation": "new", "name": name, "body_name": name})

    def tab(x0, y0, l, wd):
        add("solid.box", {"length": str(round(l, 4)), "width": str(round(wd, 4)), "height": str(rear_t),
                          "corner": [str(round(x0, 4)), str(round(y0, 4)), "0"],
                          "operation": "join", "targets": [name]})
    for y in rear_tab_y_bot:
        tab(y - rear_tab / 2, -b_t, rear_tab, b_t)
    for y in rear_tab_y_top:
        tab(y - rear_tab / 2, b_in_h, rear_tab, b_t)
    for s in (-1, 1):
        tab(w / 2 if s > 0 else -w / 2 - b_wall, rear_tab_z - rear_tab / 2, b_wall, rear_tab)
    size = [w - 2 * b_vent_rim, b_in_h - 2 * w_vent_rim]
    keep = [[sata_notch_y - b_keep_margin - 2, -100, 100, sata_notch_z + b_keep_margin + 2 - b_in_h / 2]]
    n, plugs = emit_honeycomb_patterned(size, keep, 0.0, b_in_h / 2, 0.0, rear_t, targets=[name])
    ref, _ = hex_cells(size, hex_cell, hex_web, keep, 0.0, b_in_h / 2)
    assert n == len(ref), f"open cells {n} != hex_cells {len(ref)}"
    # cut after the honeycomb: the keep-out plugs would refill them otherwise
    # SATA notch: open at the bottom edge and the +x edge
    nx1, ny0 = w / 2 + b_wall + 1, -b_t - 1
    add("solid.box", {"length": str(round(nx1 - sata_notch_y, 4)), "width": str(round(sata_notch_z - ny0, 4)),
                      "height": str(rear_t + 2),
                      "corner": [str(sata_notch_y), str(round(ny0, 4)), "-1"],
                      "operation": "cut", "targets": [name]})
    add("solid.box", {"length": str(round(w + 2 * b_wall + 2, 4)), "width": str(groove_w),
                      "height": str(groove_d + 1),
                      "corner": [str(round(-w / 2 - b_wall - 1, 4)), str(round(groove_z - groove_w / 2, 4)), "-1"],
                      "operation": "cut", "targets": [name]})
    m = [[0, 0, 1, rear_x], [1, 0, 0, 0], [0, 1, 0, 0]]
    add("solid.move", {"bodies": [name], "matrix": [[round(v, 6) for v in row] for row in m]})
    return n, plugs


def notch_keep():
    """scad notch_keep(): keep-out rects (u, v) = (b_in_h/2 - z, y) round the notch."""
    m, zb = bz_hex_web, b_z1 - bz_pull_d
    n = math.ceil(bz_pull_d)
    out = []
    for i in range(n):
        z0 = zb + i * bz_pull_d / n
        z1 = zb + (i + 1) * bz_pull_d / n
        hw = (bz_pull_wb + (bz_pull_w - bz_pull_wb) * (z1 - zb) / bz_pull_d) / 2 + m
        out.append([b_in_h / 2 - z1, bz_pull_y - hw, b_in_h / 2 - z0 + m, bz_pull_y + hw])
    return out


def emit_bezel():
    """Emit the bezel in the shared frame.  The plate is built in a local
    frame (u = b_in_h/2 - z, v = y, w = x - c_body_l) so the intake honeycomb
    is an ordinary XY field, then moved to the assembled pose.  Order matters
    (R9): honeycomb cuts + keep-out plugs first, then the tab-zone solids, the
    slots and the finger notch (which would otherwise be re-plugged), then the
    lip.  Returns (n_open_cells, n_plugs)."""
    name = "bezel"
    x0 = c_body_l
    H2 = b_in_h / 2
    add_params()
    add("component.create", {"name": "Bezel", "activate": True})
    add("solid.box", {"length": str(round(b_z1 - b_z0, 4)), "width": str(round(b_w, 4)),
                      "height": str(bezel_t),
                      "corner": [str(round(H2 - b_z1, 4)), str(round(-b_w / 2, 4)), "0"],
                      "operation": "new", "name": name, "body_name": name})
    size = [b_in_h - 8, b_in_w - 16]
    keep = notch_keep()
    n, plugs = emit_honeycomb_patterned(size, keep, 0.0, 0.0, 0.0, bezel_t, targets=[name])
    ref, _ = hex_cells(size, hex_cell, hex_web, keep, 0.0, 0.0)
    assert n == len(ref), f"open cells {n} != hex_cells {len(ref)}"
    m = [[0, 0, 1, x0], [0, 1, 0, 0], [-1, 0, 0, H2]]
    add("solid.move", {"bodies": [name], "matrix": [[round(v, 6) for v in row] for row in m]})

    def box(lo, hi, op):
        add("solid.box", {"length": str(round(hi[0] - lo[0], 4)), "width": str(round(hi[1] - lo[1], 4)),
                          "height": str(round(hi[2] - lo[2], 4)),
                          "corner": [str(round(v, 4)) for v in lo], "operation": op, "targets": [name]})
    # tab zones stay solid: the scad subtracts them from the cut (geometric
    # difference, so cells are truncated, not dropped) -> join them back
    box([x0, -bz_tab_w / 2 - 3, -1], [x0 + bezel_t, bz_tab_w / 2 + 3, c_floor + 3], "join")
    for s in (-1, 1):
        ya, yb = sorted([s * (c_in_w / 2 - 3), s * min(c_w / 2 + 3, b_w / 2)])  # clipped to the plate
        box([x0, ya, pin_z - bz_tab_h / 2 - 3], [x0 + bezel_t, yb, pin_z + bz_tab_h / 2 + 3], "join")
    # tab slots
    c, cf, ce = bz_tab_clr, bz_floor_clr, bz_end_clr
    for s in (-1, 1):
        ya, yb = sorted([s * c_in_w / 2 - s * c, s * (c_in_w / 2 + c_wall) + s * c])
        box([x0 - 1, ya, pin_z - bz_tab_h / 2 - ce], [x0 + bezel_t + 1, yb, pin_z + bz_tab_h / 2 + ce], "cut")
    box([x0 - 1, -bz_tab_w / 2 - ce, -cf], [x0 + bezel_t + 1, bz_tab_w / 2 + ce, c_floor + cf], "cut")
    # finger notch: sketch on YZ (sketch x = y, sketch y = z); outline = the
    # trapezoid joined to everything above the top edge; bottom corners r =
    # bz_pull_r (convex), mouth corners eased r = bz_pull_f
    yc, zt, zb = bz_pull_y, b_z1, b_z1 - bz_pull_d
    k = (bz_pull_w - bz_pull_wb) / 2 / (bz_pull_d + 10)       # side slope dy/dz
    hw_top = bz_pull_wb / 2 + k * bz_pull_d                    # half width at z = zt
    yl, yr = -b_w / 2 - 2, b_w / 2 + 2
    pts = [[yl, zt], [yc - hw_top, zt], [yc - bz_pull_wb / 2, zb], [yc + bz_pull_wb / 2, zb],
           [yc + hw_top, zt], [yr, zt], [yr, zt + 5], [yl, zt + 5]]
    add("sketch.create", {"plane": "YZ", "offset": round(x0 - 1, 4)})
    add("sketch.line", {"points": [[round(a, 4), round(b, 4)] for a, b in pts], "closed": True})
    add("sketch.fillet", {"a": "l2", "b": "l3", "radius": str(bz_pull_r)})
    add("sketch.fillet", {"a": "l3", "b": "l4", "radius": str(bz_pull_r)})
    add("sketch.fillet", {"a": "l1", "b": "l2", "radius": str(bz_pull_f)})
    add("sketch.fillet", {"a": "l4", "b": "l5", "radius": str(bz_pull_f)})
    add("sketch.finish", {})
    add("solid.extrude", {"distance": str(bezel_t + 2), "operation": "cut", "targets": [name]})
    # lip: sketch on XZ (sketch x = x, sketch y = -z), chamfered rear-top edge
    lx0, lx1 = x0 + 0.01, x0 - bz_lip_d
    lt = b_in_h - 0.2
    lb = lt - bz_lip_t
    lw = 3.5 * hex_dx
    ly1 = 1.2
    ly0 = ly1 - lw
    lp = [[lx0, lb], [lx1, lb], [lx1, lt - bz_lip_c], [lx1 + bz_lip_c, lt], [lx0, lt]]
    add("sketch.create", {"plane": "XZ", "offset": round(ly0, 4)})
    add("sketch.line", {"points": [[round(a, 4), round(-b, 4)] for a, b in lp], "closed": True})
    add("sketch.finish", {})
    add("solid.extrude", {"distance": str(round(lw, 4)), "operation": "join", "targets": [name]})
    return n, plugs


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
    if len(sys.argv) > 3 and sys.argv[1] == "wall":
        n, plugs = emit_wall(sys.argv[2])
        dump(sys.argv[3])
        print(f"wall_{sys.argv[2]}: open cells {n}, plugs {plugs}, commands {len(cmds)}")
        sys.exit(0)
    if len(sys.argv) > 2 and sys.argv[1] == "rear":
        n, plugs = emit_rear()
        dump(sys.argv[2])
        print(f"rear: open cells {n}, plugs {plugs}, commands {len(cmds)}")
        sys.exit(0)
    if len(sys.argv) > 2 and sys.argv[1] == "bezel":
        n, plugs = emit_bezel()
        dump(sys.argv[2])
        print(f"bezel: open cells {n}, plugs {plugs}, commands {len(cmds)}")
        sys.exit(0)
    if len(sys.argv) > 2 and sys.argv[1] == "plate":
        n, plugs = emit_plate(sys.argv[2])
        dump(sys.argv[3])
        print(f"plate_{sys.argv[2]}: open cells {n}, plugs {plugs}, commands {len(cmds)}")
        sys.exit(0)
    _demo(sys.argv[1] if len(sys.argv) > 1 else "hc_demo.json")
