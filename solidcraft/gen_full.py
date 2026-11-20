#!/usr/bin/env python3
"""Shared params + emit helpers for the full SolidCraft port of the disk bay.

Import this from the per-part generators.  `cmds` collects commands; `add()`
appends one.  Constants mirror scad/params.scad.  Honeycomb is emitted as two
staggered `sketch.pattern.rectangular` cuts plus hex plugs over the keep-out
cells (see emit_honeycomb_patterned), not one cut per cell."""
import json, math, sys

# NOTE: values copied from scad/params.scad - that file is the authority.
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
relief_r = 0.5
tab_len = 22.0
tab_x = [b_xc - 60, b_xc - 27, b_xc + 27, b_xc + 60]
tab_flare, tab_splay = 15.0, 1.5
tab_reach = b_t * math.tan(math.radians(tab_flare)) + b_wall * math.tan(math.radians(tab_splay))
tab_clr, tab_fit_clr = 0.0, 0.08

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
bz_rim = 2.0
bz_tab_h, bz_tab_w, bz_tab_splay = 8.0, 60.0, 4.0
bz_tab_clr, bz_floor_clr, bz_end_clr = 0.08, 0.05, 0.15
bz_tab_z = [pin_z, b_in_h - pin_z]
bz_lip_w = 10.0
bz_lip_y1 = bz_lip_w / 2
bz_lip_y0 = bz_lip_y1 - bz_lip_w
bz_lip_d, bz_lip_t, bz_lip_c = 2.0, 1.4, 0.5
bz_lip_top = b_in_h - 0.2

# ---- caddy tray (scad/params.scad c_*, push_*, pin_*, finger_*, sp_*) -----
c_rear_gap = 3.0
c_wall_top = c_floor + c_wall_h
c_post_l = 8.0
c_post_h = b_in_h - 0.2
push_x1 = b_x0 - 2
push_y0 = sata_notch_y + 0.8
push_w, push_r, push_root_r, push_nose = 10.0, 3.0, 3.0, 1.5
# pull ledge (front counterpart of the push tab)
pull_x, pull_w, pull_taper, pull_r, pull_root_r = 10.0, 30.0, 8.0, 3.0, 6.0
pull_barb_w, pull_barb, pull_barb_gap, pull_ramp = 44.0, 0.4, 0.1, 2.4
pull_hole, pull_hole_x, pull_chamfer = [4.0, 18.0], 3.0, 0.5
pin_d, pin_tip = 2.6, 1.2
pin_len = clr + 1.8
hdd_side_hole_x = [28.5, 130.1]
finger_angle, finger_w, finger_gap, finger_rim = 45.0, 6.0, 1.2, 3.0
fingers = [[hdd_side_hole_x[0], 1], [hdd_side_hole_x[1], -1]]
sp_rise, sp_h = 1.5, 2.0
sp_lock = 1.25
sp_gap = sp_lock + 0.6
sp_top = c_wall_top + sp_rise
sp_slit_z = sp_top - sp_h - sp_gap

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
sp_preload, sp_flat, sp_lead, sp_hold, sp_hole_clr = 0.4, 1.2, 30.0, 45.0, 0.3
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
    """scad hits_keep(): k = [x0, y0, x1, y1] box, or slant [ox, oy, a, u0, u1, v0, v1] (cell as a circle)."""
    for k in keep:
        if len(k) == 4:
            if cx + r > k[0] and cx - r < k[2] and cy + r > k[1] and cy - r < k[3]:
                return True
        else:
            dx, dy, a = cx - k[0], cy - k[1], math.radians(k[2])
            u = dx * math.cos(a) + dy * math.sin(a)
            v = -dx * math.sin(a) + dy * math.cos(a)
            if u + r > k[3] and u - r < k[4] and v + r > k[5] and v - r < k[6]:
                return True
    return False


def mirror_keep_x(k):
    """Keep-out reflected x -> -x (box or slant)."""
    if len(k) == 4:
        return [-k[2], k[1], -k[0], k[3]]
    return [-k[0], k[1], 180 - k[2], k[3], k[4], -k[6], -k[5]]


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
        cut = {"distance": str(t + 2), "operation": "cut"}
        if targets:
            cut["targets"] = targets     # multi-body parts: never cut a neighbour
        add("solid.extrude", cut)
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
    slots = [(rear_x + rear_t / 2, y, rear_t, rear_tab, rear_fit_clr) for y in rear_y]
    caddy = []
    if kind == "top":
        for s in (-1, 1):
            ys = sorted([s * sp_hole_y[0], s * sp_hole_y[1]])
            caddy.append((sp_hole_x[0], ys[0], sp_hole_x[1], ys[1]))
    keep = [bump_keep(b[0], b[1], b_xc, 0, plate_bump_af) for b in plate_bumps]
    keep += [[x - tab_len / 2 - tab_reach - b_keep_margin - b_xc, s * b_in_w / 2 - 3 - b_keep_margin,
              x + tab_len / 2 + tab_reach + b_keep_margin - b_xc, s * b_in_w / 2 + 3 + b_keep_margin]
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


def tab_end(u, w, c=0.0, splay=tab_splay):
    """scad/bay.scad tab_end(): half-length of a wall tab / notch at (u, w)."""
    return (tab_len / 2 + c + u * math.tan(math.radians(tab_flare))
            + w * math.tan(math.radians(splay)))


_sk = [0]


def _sketch_name(tag):
    _sk[0] += 1
    return f"{tag}{_sk[0]}"


def _loft_cut(sections, name):
    """Cut a ruled loft through sections [(plane, offset, entity-emitter)] from body `name`."""
    names = []
    for plane, off, draw in sections:
        n = _sketch_name("lf")
        add("sketch.create", {"plane": plane, "offset": round(off, 4), "name": n})
        draw()
        add("sketch.finish", {})
        names.append(n)
    add("solid.loft", {"sections": [{"sketch": n} for n in names], "operation": "cut",
                       "targets": [name]})


def emit_notches(kind, name):
    """The v0.4.0 wall-tab notches: for each tab x and wall side, a dovetail
    polyhedron tab_dovetail(-1, b_t+1, -1, b_wall+tab_fit_clr, tab_clr) in the
    frame (x, w, u) -> (x, s*(edge - w), z0in + zs*u), plus notch_reliefs.
    Built as a ruled loft between the two w sections (the end faces are
    planar, so this is exactly the polyhedron).  Returns (n_notches, n_reliefs)."""
    top = kind == "top"
    zin, zs = (b_in_h_top, 1) if top else (0.0, -1)
    edge = b_in_w / 2 + b_wall
    w1 = b_wall + tab_fit_clr
    nn = nr = 0
    for x in tab_x:
        into_end = top and (x + tab_len / 2 + tab_reach > sp_hole_x[1])
        for sw in (-1, 1):
            def quad(w, sw=sw, x=x):
                pts = []
                for u in (-1.0, b_t + 1):
                    pts.append((u, tab_end(u, w, tab_clr)))
                pl = [[x + e, -(zin + zs * u)] for u, e in pts]          # +x side, u ascending
                mi = [[x - e, -(zin + zs * u)] for u, e in pts]
                poly = [pl[0], pl[1], mi[1], mi[0]]
                def draw():
                    add("sketch.line", {"points": [[round(a, 4), round(b, 4)] for a, b in poly],
                                        "closed": True})
                return draw
            _loft_cut([("XZ", sw * (edge - (-1.0)), quad(-1.0)),
                       ("XZ", sw * (edge - w1), quad(w1))], name)
            nn += 1
            for sx in (-1, 1):
                if into_end:
                    wc = w1 - relief_r
                    cx = lambda u: x + sx * tab_end(u, wc, tab_clr)
                else:
                    wc = w1
                    cx = lambda u: x + sx * (tab_end(u, w1, tab_clr) - relief_r)
                cy = sw * (edge - wc)
                def circ(u, cx=cx, cy=cy):
                    def draw():
                        add("sketch.circle.center", {"center": [round(cx(u), 4), round(cy, 4)],
                                                     "radius": relief_r})
                    return draw
                _loft_cut([("XY", zin + zs * -1.0, circ(-1.0)),
                           ("XY", zin + zs * (b_t + 1), circ(b_t + 1))], name)
                nr += 1
    return nn, nr


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
    emit_notches(kind, name)
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


def emit_wall_tabs(name):
    """scad/bay.scad:wall() dovetail tabs + root_reliefs.  tab_dovetail(-0.01,
    b_t, 0, b_wall, 0, splay) in the frame (x, w, u) -> (x, -u, b_wall - w) at
    the bottom, (x, b_in_h + u, b_wall - w) at the top: the same flared
    (with u) and splayed (with w) shape as the plate notch, as a ruled loft
    between its w=0 (z=b_wall) and w=b_wall (z=0) sections.  Roots: relief
    rods on the wall edge (u=0), centred relief_r outside each tab end, axis
    along w.  Returns (n_tabs, n_root_reliefs)."""
    nt = nr = 0
    for x in tab_x:
        for yo, ys in ((0.0, -1), (b_in_h, 1)):          # y = yo + ys*u
            def quad(w, x=x, yo=yo, ys=ys):
                us = (-0.01, b_t)
                pl = [[x + tab_end(u, w, 0.0), yo + ys * u] for u in us]
                mi = [[x - tab_end(u, w, 0.0), yo + ys * u] for u in us]
                poly = [pl[0], pl[1], mi[1], mi[0]]
                def draw():
                    add("sketch.line", {"points": [[round(a, 4), round(b, 4)] for a, b in poly],
                                        "closed": True})
                return draw
            names = []
            for w in (0.0, b_wall):
                n = _sketch_name("tb")
                add("sketch.create", {"plane": "XY", "offset": round(b_wall - w, 4), "name": n})
                quad(w)()
                add("sketch.finish", {})
                names.append(n)
            add("solid.loft", {"sections": [{"sketch": n} for n in names], "operation": "join",
                               "targets": [name]})
            nt += 1
    for x in tab_x:
        for yo in (0.0, b_in_h):
            for sg in (-1, 1):
                def circ(w, x=x, yo=yo, sg=sg):
                    def draw():
                        add("sketch.circle.center", {
                            "center": [round(x + sg * (tab_end(0, w, 0.0) + relief_r), 4), round(yo, 4)],
                            "radius": relief_r})
                    return draw
                ws = (-1.0, b_wall + 1)
                _loft_cut([("XY", b_wall - w, circ(w)) for w in ws], name)
                nr += 1
    return nt, nr


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
    emit_wall_tabs(name)
    for x in wall_slot_x:
        c = rear_fit_clr
        add("solid.box", {"length": str(round(rear_t + 2 * c, 4)), "width": str(round(rear_tab + 2 * c, 4)),
                          "height": "b_wall + 2",
                          "center": [str(round(x, 4)), str(rear_tab_z), "b_wall/2"], "operation": "cut",
                          "targets": [name]})
    for x in wall_slot_x:   # scad/bay.scad:wall() rear-slot corner reliefs, through the wall
        for sg in (-1, 1):
            add("sketch.create", {"plane": "XY", "offset": -1.0})
            add("sketch.circle.center", {"center": [round(x + sg * (rear_t / 2 + rear_fit_clr), 4),
                                                    round(rear_tab_z + sg * (rear_tab / 2 + rear_fit_clr), 4)],
                                         "radius": relief_r})
            add("sketch.finish", {})
            add("solid.extrude", {"distance": round(b_wall + 2, 4), "operation": "cut", "targets": [name]})
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


def bz_zone(z0, z1, y0, y1, m=b_keep_margin):
    """scad bz_zone(): keep-out rect in the field frame (u = b_in_h/2 - z, v = y)."""
    return [b_in_h / 2 - z1 - m, min(y0, y1) - m, b_in_h / 2 - z0 + m, max(y0, y1) + m]


def bezel_keep():
    """scad bezel_keep(): floor-tab zone, the four wall-tab zones, the lip zone."""
    t = math.tan(math.radians(bz_tab_splay))
    keep = [bz_zone(-bz_floor_clr, c_floor + bz_floor_clr, -bz_tab_w / 2 - bz_end_clr,
                    bz_tab_w / 2 + bz_end_clr)]
    for s in (-1, 1):
        for z in bz_tab_z:
            keep.append(bz_zone(z - bz_tab_h / 2 - bz_end_clr, z + bz_tab_h / 2 + bz_end_clr,
                                s * (c_in_w / 2 - bz_tab_clr), s * (c_w / 2 + bezel_t * t)))
    keep.append(bz_zone(bz_lip_top - bz_lip_t, bz_lip_top, bz_lip_y0, bz_lip_y1))
    return keep


def emit_bezel():
    """Emit the v0.4.0 bezel in the shared frame: a plate with a whole-face
    honeycomb (bz_rim solid rim, no notch), a back-face lip, splayed wall-tab
    slots (2 a side), the floor-tab slot and the slot corner reliefs.  The
    plate is built in a local frame (u = b_in_h/2 - z, v = y, w = x - c_body_l)
    so the honeycomb is an ordinary XY field, then moved to the assembled pose.
    R9: honeycomb cuts + keep-out plugs first, the slots and reliefs after, so
    no plug can re-close a slot.  Returns (n_open_cells, n_plugs)."""
    name = "bezel"
    x0 = c_body_l
    H2 = b_in_h / 2
    add_params()
    add("component.create", {"name": "Bezel", "activate": True})
    add("solid.box", {"length": str(round(b_z1 - b_z0, 4)), "width": str(round(b_w, 4)),
                      "height": str(bezel_t),
                      "corner": [str(round(H2 - b_z1, 4)), str(round(-b_w / 2, 4)), "0"],
                      "operation": "new", "name": name, "body_name": name})
    size = [b_h - 2 * bz_rim, b_w - 2 * bz_rim]
    keep = bezel_keep()
    n, plugs = emit_honeycomb_patterned(size, keep, 0.0, 0.0, 0.0, bezel_t, cell=bz_hex_cell,
                                        web=bz_hex_web, targets=[name])
    ref, _ = hex_cells(size, bz_hex_cell, bz_hex_web, keep, 0.0, 0.0)
    assert n == len(ref), f"open cells {n} != hex_cells {len(ref)}"
    m = [[0, 0, 1, x0], [0, 1, 0, 0], [-1, 0, 0, H2]]
    add("solid.move", {"bodies": [name], "matrix": [[round(v, 6) for v in row] for row in m]})

    def box(lo, hi, op):
        add("solid.box", {"length": str(round(hi[0] - lo[0], 4)), "width": str(round(hi[1] - lo[1], 4)),
                          "height": str(round(hi[2] - lo[2], 4)),
                          "corner": [str(round(v, 4)) for v in lo], "operation": op, "targets": [name]})
    # lip: sketch on XZ (sketch x = x, sketch y = -z), chamfered rear-top edge
    lx0, lx1 = x0 + 0.01, x0 - bz_lip_d
    lt, lb = bz_lip_top, bz_lip_top - bz_lip_t
    lp = [[lx0, lb], [lx1, lb], [lx1, lt - bz_lip_c], [lx1 + bz_lip_c, lt], [lx0, lt]]
    add("sketch.create", {"plane": "XZ", "offset": round(bz_lip_y0, 4)})
    add("sketch.line", {"points": [[round(a, 4), round(-b, 4)] for a, b in lp], "closed": True})
    add("sketch.finish", {})
    add("solid.extrude", {"distance": str(round(bz_lip_w, 4)), "operation": "join", "targets": [name]})
    # splayed wall-tab slots, bz_tab2d(c, e=1) over bz_tab_h + 2*ce
    c, ce, e = bz_tab_clr, bz_end_clr, 1.0
    t = math.tan(math.radians(bz_tab_splay))
    yo = c_w / 2
    for s in (-1, 1):
        poly = [[x0 - e, s * (c_in_w / 2 - c)], [x0 + bezel_t + e, s * (c_in_w / 2 - c)],
                [x0 + bezel_t + e, s * (yo + (bezel_t + e) * t)], [x0 - e, s * (yo - e * t)]]
        for z in bz_tab_z:
            add("sketch.create", {"plane": "XY", "offset": round(z - bz_tab_h / 2 - ce, 4)})
            add("sketch.line", {"points": [[round(a, 4), round(b, 4)] for a, b in poly], "closed": True})
            add("sketch.finish", {})
            add("solid.extrude", {"distance": str(round(bz_tab_h + 2 * ce, 4)), "operation": "cut",
                                  "targets": [name]})
    cf = bz_floor_clr
    box([x0 - 1, -bz_tab_w / 2 - ce, -cf], [x0 + bezel_t + 1, bz_tab_w / 2 + ce, c_floor + cf], "cut")
    # slot corner reliefs (upper slots): inner face's lower corner, sloped
    # outer face's upper corner; rods along x (the outer one leans with the splay)
    yi = c_in_w / 2 - c
    z = bz_tab_z[1]
    zl, zh = z - bz_tab_h / 2 - ce, z + bz_tab_h / 2 + ce
    xa, xb = x0 - 1, x0 + bezel_t + 1
    for s in (-1, 1):
        for (ya, yb, zz) in ((yi, yi, zl), (yo - t, yo + (bezel_t + 1) * t, zh)):
            names = []
            for xx, yy in ((xa, ya), (xb, yb)):
                nm = _sketch_name("rl")
                add("sketch.create", {"plane": "YZ", "offset": round(xx, 4), "name": nm})
                add("sketch.circle.center", {"center": [round(s * yy, 4), round(zz, 4)], "radius": relief_r})
                add("sketch.finish", {})
                names.append(nm)
            add("solid.loft", {"sections": [{"sketch": q} for q in names], "operation": "cut",
                               "targets": [name]})
    return n, plugs


def finger_keep(xp, zt, d, cx, cz):
    """scad finger_keep(): slant keep-out along the finger beam (slot ring + recess, plus the web margin)."""
    slot_half = finger_w / 2 + finger_gap
    L = (c_wall_top - finger_rim - slot_half * math.cos(math.radians(finger_angle)) - zt) \
        / math.sin(math.radians(finger_angle))
    m = b_keep_margin
    return [xp - cx, zt - cz, finger_angle if d > 0 else 180 - finger_angle,
            -slot_half - m, L + finger_w / 2 + m, -slot_half - m, slot_half + m]


def tray_wall_keep(s, fc_x, fc_z):
    """scad wall_vents(s) keep-outs (the full set, finger and spring ones too:
    those cells stay solid, Task 6 cuts the fingers/slits into them)."""
    keep = []
    if s > 0:
        keep += [finger_keep(f[0], pin_z, f[1], fc_x, fc_z) for f in fingers]
    if s > 0:
        r = c_hex_cell / math.sqrt(3) + b_keep_margin
        for f in fingers:
            c = service_cell(f)
            keep.append([c[0] - r - fc_x, c[1] - r - fc_z, c[0] + r - fc_x, c[1] + r - fc_z])
    keep.append([sp_x[0] - b_keep_margin - fc_x, sp_slit_z - b_keep_margin - fc_z,
                 sp_x[1] + b_keep_margin - fc_x, 50])
    if s < 0:
        r = pin_d / 2 + b_keep_margin
        keep += [[x - r - fc_x, pin_z - r - fc_z, x + r - fc_x, pin_z + r - fc_z] for x in hdd_side_hole_x]
    keep.append([c_body_l - 8 - fc_x, -50, c_body_l + 5 - fc_x, 50])
    return keep


def emit_tray_base():
    """Emit the caddy tray WITHOUT fingers/slots/service holes/spring slits/
    bumps (Task 6): floor, both walls (full wall_vents honeycomb, keep-outs
    incl. finger/spring ones), front posts, bezel tabs, push tab, pins.  Built
    in the shared frame, body `tray`.  Returns a dict of counts."""
    name = "tray"
    xl = c_body_l - c_rear_gap
    fc = c_rear_gap + xl / 2
    add_params()
    add("component.create", {"name": "Tray", "activate": True})
    add("solid.box", {"length": str(round(xl, 4)), "width": str(round(c_w, 4)), "height": str(c_floor),
                      "corner": [str(c_rear_gap), str(round(-c_w / 2, 4)), "0"],
                      "operation": "new", "name": name, "body_name": name})
    fsize = [xl - 2 * c_frame, c_in_w - 2 * c_frame]
    fn, fplugs = emit_honeycomb_patterned(fsize, [], fc, 0.0, 0.0, c_floor,
                                          phase=(b_xc - fc, 0.0), cell=c_hex_cell, web=c_hex_web,
                                          targets=[name])
    ref, _ = hex_cells(fsize, c_hex_cell, c_hex_web, [], fc, 0.0, (b_xc - fc, 0.0))
    assert fn == len(ref), f"floor cells {fn} != hex_cells {len(ref)}"
    # walls: local frame (x along, y = world z, z = thickness out from the
    # inner face), honeycomb as an XY field, then a rigid move + join.  The +y
    # wall is turned 180 deg (x -> c_rear_gap + c_body_l - x) to stay a rotation.
    fc_z = c_wall_top / 2
    wsize = [xl - 2 * c_wall_rim, c_wall_top - 2 * c_wall_rim]
    wcells = {}
    for s in (-1, 1):
        wn = f"tw_{'p' if s > 0 else 'm'}"
        add("solid.box", {"length": str(round(xl, 4)), "width": str(c_wall_top), "height": str(c_wall),
                          "corner": [str(c_rear_gap), "0", "0"], "operation": "new",
                          "name": wn, "body_name": wn})
        keep = tray_wall_keep(s, fc, fc_z)
        ph = (b_xc - fc, b_in_h / 2 - fc_z)
        if s > 0:   # mirrored in x
            keep = [mirror_keep_x(k) for k in keep]
            ph = (-ph[0], ph[1])
        n, plugs = emit_honeycomb_patterned(wsize, keep, fc, fc_z, 0.0, c_wall, phase=ph,
                                            cell=c_hex_cell, web=c_hex_web, targets=[wn])
        r2, _ = hex_cells(wsize, c_hex_cell, c_hex_web, keep, fc, fc_z, ph)
        assert n == len(r2), f"wall cells {n} != hex_cells {len(r2)}"
        wcells[s] = (n, plugs)
        if s < 0:
            m = [[1, 0, 0, 0], [0, 0, -1, -c_in_w / 2], [0, 1, 0, 0]]
        else:
            m = [[-1, 0, 0, c_rear_gap + c_body_l], [0, 0, 1, c_in_w / 2], [0, 1, 0, 0]]
        add("solid.move", {"bodies": [wn], "matrix": [[round(v, 6) for v in row] for row in m]})
        add("solid.combine", {"target": name, "tools": [wn], "operation": "join"})
    # raised front posts: 5-point profile in the wall plane (sketch on XZ: x, -z)
    x1 = c_body_l
    x0 = x1 - c_post_l
    rise = c_post_h - c_wall_top
    post = [[x0 - rise - 1, c_wall_top - 1], [x0 - rise, c_wall_top], [x0, c_post_h],
            [x1, c_post_h], [x1, c_wall_top - 1]]
    for s in (-1, 1):
        add("sketch.create", {"plane": "XZ", "offset": round(c_in_w / 2 if s > 0 else -c_in_w / 2 - c_wall, 4)})
        add("sketch.line", {"points": [[round(a, 4), round(-b, 4)] for a, b in post], "closed": True})
        add("sketch.finish", {})
        add("solid.extrude", {"distance": str(c_wall), "operation": "join", "targets": [name]})
    # push tab (+y rear corner): rib profile in the wall plane, closed with a
    # concave fillet r=push_fillet into the wall's rear edge and convex
    # rounds r=push_nose on the rear corners; plus the floor box; plan rear
    # corners rounded r=push_r.  Built as its own body, trimmed at x = c_rear_gap+2
    # (the wall is solid there: its honeycomb starts at c_rear_gap + c_wall_rim,
    # so the stub must not re-plug cells) and joined.
    pb = "push"
    xe = c_rear_gap + 6
    rib = [[push_x1, 0], [xe, 0], [xe, c_wall_top - 3], [c_rear_gap, c_wall_top - 3],
           [c_rear_gap, push_h], [push_x1, push_h]]
    add("sketch.create", {"plane": "XZ", "offset": round(c_in_w / 2, 4)})
    add("sketch.line", {"points": [[round(a, 4), round(-b, 4)] for a, b in rib], "closed": True})
    add("sketch.fillet", {"a": "l4", "b": "l5", "radius": str(push_fillet)})
    add("sketch.fillet", {"a": "l5", "b": "l6", "radius": str(push_nose)})
    add("sketch.fillet", {"a": "l6", "b": "l1", "radius": str(push_nose)})
    add("sketch.finish", {})
    add("solid.extrude", {"distance": str(c_wall), "operation": "new", "name": pb, "body_name": pb})
    y0 = c_w / 2 - push_w
    add("solid.box", {"length": str(round(xe - push_x1, 4)), "width": str(push_w), "height": str(c_floor),
                      "corner": [str(push_x1), str(round(y0, 4)), "0"], "operation": "join", "targets": [pb]})
    xt = c_rear_gap + 2
    add("solid.box", {"length": "30", "width": "20", "height": "40", "corner": [str(xt), str(round(y0 - 5, 4)), "-5"],
                      "operation": "cut", "targets": [pb]})
    add("sketch.create", {"plane": "XY", "offset": -1})
    add("sketch.rectangle.rounded", {"p0": [push_x1, round(y0, 4)], "p1": [c_rear_gap + 20, round(c_w / 2, 4)],
                                     "radius": str(push_r)})
    add("sketch.finish", {})
    add("solid.extrude", {"distance": str(c_wall_top + 2), "operation": "intersect", "targets": [pb]})
    add("solid.combine", {"target": name, "tools": [pb], "operation": "join"})
    # bezel tabs

    def box(lo, hi):
        add("solid.box", {"length": str(round(hi[0] - lo[0], 4)), "width": str(round(hi[1] - lo[1], 4)),
                          "height": str(round(hi[2] - lo[2], 4)),
                          "corner": [str(round(v, 4)) for v in lo], "operation": "join", "targets": [name]})
    # wall tabs: scad bz_tab2d (outer face splayed bz_tab_splay), two a wall, clipped to the bezel's thickness
    x0, x1, e = c_body_l, c_body_l + bezel_t, 0.01
    t = math.tan(math.radians(bz_tab_splay))
    for s in (-1, 1):
        quad = [(x0 - e, c_in_w / 2), (x1, c_in_w / 2), (x1, c_w / 2 + bezel_t * t), (x0 - e, c_w / 2 - e * t)]
        quad = [(a, s * b) for a, b in quad]
        for z in bz_tab_z:
            _xy_poly(quad if s > 0 else quad[::-1], z - bz_tab_h / 2, bz_tab_h, "join", [name])
    box([c_body_l - 0.01, -bz_tab_w / 2, 0], [c_body_l + bezel_t, bz_tab_w / 2, c_floor])
    # pins: cylinder + conical tip; base sunk 0.4 into the wall (solid there) so the join overlaps
    sink = 0.4
    npins = 0
    for x, d in [(hdd_side_hole_x[0], 1), (hdd_side_hole_x[1], 1)] + [(f[0], -1) for f in fingers]:
        yb = -c_in_w / 2 - 0.01 if d > 0 else c_in_w / 2 + 0.01
        ax = [0, d, 0]
        add("solid.cylinder", {"diameter": str(pin_d), "height": str(round(pin_len - pin_tip + 0.01 + sink, 4)),
                               "base": [str(x), str(round(yb - d * sink, 4)), str(round(pin_z, 4))],
                               "axis": ax, "operation": "join", "targets": [name]})
        add("solid.cone", {"diameter": str(pin_d), "height": str(pin_tip), "top_diameter": "1.0",
                           "base": [str(x), str(round(yb + d * (pin_len - pin_tip), 4)), str(round(pin_z, 4))],
                           "axis": ax, "operation": "join", "targets": [name]})
        npins += 1
    return {"floor": (fn, fplugs), "walls": wcells, "pins": npins}


# ---- fingers + spring lock (Task 6): polygons computed from caddy.scad's 2D math ----
finger_t, finger_tip_flat = 1.6, 1.6
sp_hump_ramp, sp_hump_r, sp_fillet_r, sp_crest_r = 15.0, 6.0, 1.5, 1.0
sp_bump_h = b_in_h - sp_top + sp_lock
slot_half = finger_w / 2 + finger_gap
service_flat = 1.0
service_overlap = 1.0


def service_cell(f):
    """scad service_cell(): the service hole's hex centre (x, z), toward the finger's slot."""
    j = round((pin_z - b_in_h / 2) / hex_dy)
    return [f[0] - f[1] * (slot_half * math.sqrt(2) + c_hex_cell / 2 - service_overlap), b_in_h / 2 + j * hex_dy]


def _clip(poly, nrm, c):
    """Sutherland-Hodgman: keep points with dot(nrm, p) <= c."""
    out = []
    for i, p in enumerate(poly):
        q = poly[(i + 1) % len(poly)]
        dp = nrm[0] * p[0] + nrm[1] * p[1] - c
        dq = nrm[0] * q[0] + nrm[1] * q[1] - c
        if dp <= 1e-12:
            out.append(p)
        if (dp < -1e-12 and dq > 1e-12) or (dp > 1e-12 and dq < -1e-12):
            t = dp / (dp - dq)
            out.append((p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])))
    return out


def _offset_convex(poly, d):
    """Mitred offset (OpenSCAD offset(delta=d)) of a convex CCW polygon."""
    n = len(poly)
    lines = []
    for i in range(n):
        p, q = poly[i], poly[(i + 1) % n]
        ex, ey = q[0] - p[0], q[1] - p[1]
        ln = math.hypot(ex, ey)
        nx, ny = ey / ln, -ex / ln
        lines.append((nx, ny, nx * p[0] + ny * p[1] + d))
    out = []
    for i in range(n):
        a, b = lines[i - 1], lines[i]
        det = a[0] * b[1] - a[1] * b[0]
        out.append(((a[2] * b[1] - b[2] * a[1]) / det, (a[0] * b[2] - b[0] * a[2]) / det))
    return out


def finger_len(zt):
    return (c_wall_top - finger_rim - slot_half * math.cos(math.radians(finger_angle)) - zt) \
        / math.sin(math.radians(finger_angle))


def finger_beam_pts(xp, zt, d, extra=0.0):
    L = finger_len(zt)
    a = math.radians(finger_angle if d > 0 else 180 - finger_angle)
    ca, sa = math.cos(a), math.sin(a)
    loc = [(-finger_w / 2, -finger_w / 2), (L + finger_w / 2 + extra, -finger_w / 2),
           (L + finger_w / 2 + extra, finger_w / 2), (-finger_w / 2, finger_w / 2)]
    pts = [(xp + u * ca - v * sa, zt + u * sa + v * ca) for u, v in loc]
    apex = zt - finger_w / 2 * (math.sin(math.radians(finger_angle)) + math.cos(math.radians(finger_angle)))
    return _clip(pts, (0, -1), -(apex + finger_tip_flat / 2))   # keep z >= apex + flat/2


def finger_slot_pts(xp, zt, d):
    """finger_slot2d: ring (offset gap of the long beam minus the beam), kept up to the root line."""
    L = finger_len(zt)
    a = math.radians(finger_angle if d > 0 else 180 - finger_angle)
    ex, ey = math.cos(a), math.sin(a)
    pe = finger_beam_pts(xp, zt, d, 20)
    oe = _offset_convex(pe, finger_gap)
    c = xp * ex + zt * ey + L                      # root line: u = L
    o2, p2 = _clip(oe, (ex, ey), c), _clip(pe, (ex, ey), c)

    def on(q):
        return abs(q[0] * ex + q[1] * ey - c) < 1e-6
    # clip edge = consecutive pair of on-line vertices (CCW order)
    def clip_edge(poly):
        n = len(poly)
        for i in range(n):
            if on(poly[i]) and on(poly[(i + 1) % n]):
                return i
    ia, ic = clip_edge(o2), clip_edge(p2)
    n, m = len(o2), len(p2)
    A, B = o2[ia], o2[(ia + 1) % n]
    C, D = p2[ic], p2[(ic + 1) % m]
    path = [o2[(ia + 1 + k) % n] for k in range(n)]           # B ... A (CCW)
    path += [p2[(ic - k) % m] for k in range(m)]               # C, prev ... D (reversed)
    return path


def _r(p):
    return [round(p[0], 5), round(-p[1], 5)]       # XZ sketch: (x, -z)


def _cut_xz(pts, y_off, dist, targets, op="cut"):
    add("sketch.create", {"plane": "XZ", "offset": round(y_off, 4)})
    add("sketch.line", {"points": [_r(p) for p in pts], "closed": True})
    add("sketch.finish", {})
    add("solid.extrude", {"distance": str(round(dist, 4)), "operation": op, "targets": targets})


def emit_fingers(name="tray"):
    """Diagonal cantilever fingers on the +y wall: through slot, outer-face
    recess (beam thinned to finger_t), and the service holes."""
    y0 = c_in_w / 2
    for xp, d in fingers:
        _cut_xz(finger_slot_pts(xp, pin_z, d), y0 - 1, c_wall + 2, [name])
        rec = c_wall - finger_t
        _cut_xz(finger_beam_pts(xp, pin_z, d), c_w / 2 - rec, rec + 1, [name])
    k = math.tan(math.radians(30))
    for f in fingers:
        c = service_cell(f)
        assert abs(c[0] - f[0]) - c_hex_cell / 2 > finger_w / 2 * math.sqrt(2) + 0.1, \
            "service hole would cut the finger"
        tw = math.copysign(1, f[0] - c[0])
        h = c_hex_cell / math.sqrt(3) / 2
        xf = c[0] + tw * c_hex_cell / 2
        dC = tw * (xf - (f[0] - tw * slot_half * math.sqrt(2)))
        tu = max(0, (c[1] + h - pin_z - dC) / (1 + k))
        tl = max(0, (pin_z - dC - c[1] + h) / (1 + k))
        pu = (xf + tw * tu, c[1] + h - tu * k)
        pl = (xf + tw * tl, c[1] - h + tl * k)
        g = 0.01   # grown so the pieces overlap the slot rather than coincide
        R = c_hex_cell / math.sqrt(3) + g / math.cos(math.radians(30))
        hexp = [(c[0] + R * math.cos(math.radians(30 + 60 * q)), c[1] + R * math.sin(math.radians(30 + 60 * q)))
                for q in range(6)]
        dz = service_flat / (1 / k + 1)
        tris = [[(xf, c[1] + h), pu, (xf, pin_z)], [(xf, c[1] - h), pl, (xf, pin_z)]]
        for sg, pp in ((1, pu), (-1, pl)):
            tris.append([pp, (pp[0] - tw * dz / k, pp[1] + sg * dz), (pp[0] + tw * dz, pp[1] + sg * dz)])
        pieces = [hexp]
        for t in tris:
            area = sum(t[q][0] * t[(q + 1) % 3][1] - t[(q + 1) % 3][0] * t[q][1] for q in range(3))
            if abs(area) < 1e-9:
                continue
            if area < 0:
                t = t[::-1]
            pieces.append(_offset_convex(t, g))
        for pc in pieces:
            _cut_xz(pc, y0 - 1, c_wall + 2, [name])
    return {"service_cells": None}


def _fillet_poly(pts, radii, seg_deg=4.0):
    """Round the corners of a closed polygon: radii[i] (or 0) at pts[i], arcs sampled."""
    out = []
    n = len(pts)
    for i in range(n):
        r = radii.get(i, 0)
        p, a, b = pts[i], pts[i - 1], pts[(i + 1) % n]
        if not r:
            out.append(p)
            continue
        v1 = (a[0] - p[0], a[1] - p[1]); v2 = (b[0] - p[0], b[1] - p[1])
        l1, l2 = math.hypot(*v1), math.hypot(*v2)
        u1 = (v1[0] / l1, v1[1] / l1); u2 = (v2[0] / l2, v2[1] / l2)
        ang = math.acos(max(-1, min(1, u1[0] * u2[0] + u1[1] * u2[1])))   # interior angle between edges
        t = r / math.tan(ang / 2)
        assert t <= min(l1, l2) + 1e-9, f"fillet {r} too big at corner {i}"
        bis = (u1[0] + u2[0], u1[1] + u2[1]); bl = math.hypot(*bis)
        bis = (bis[0] / bl, bis[1] / bl)
        cd = r / math.sin(ang / 2)
        ctr = (p[0] + bis[0] * cd, p[1] + bis[1] * cd)
        t1 = (p[0] + u1[0] * t, p[1] + u1[1] * t); t2 = (p[0] + u2[0] * t, p[1] + u2[1] * t)
        a1 = math.atan2(t1[1] - ctr[1], t1[0] - ctr[0]); a2 = math.atan2(t2[1] - ctr[1], t2[0] - ctr[0])
        da = (a2 - a1 + math.pi) % (2 * math.pi) - math.pi
        ns = max(2, math.ceil(abs(math.degrees(da)) / seg_deg))
        out += [(ctr[0] + r * math.cos(a1 + da * q / ns), ctr[1] + r * math.sin(a1 + da * q / ns))
                for q in range(ns + 1)]
    return out


def spring_profile_pts(defl=0.0):
    """spring_profile2d (hump + bump, rounded), from zr-1 up; the hump's deep
    body below the rim is omitted (it is wall anyway, and would re-plug vents)."""
    a, b = sp_x[0] - 3, sp_x[1] + 3
    run = sp_rise / math.tan(math.radians(sp_hump_ramp))
    zr = c_wall_top
    x0, x1 = sp_bump_x - sp_flat / 2, sp_bump_x + sp_flat / 2
    zb, zt = sp_top - defl - 0.01, sp_top + sp_bump_h - defl
    xl = x0 - (zt - zb) / math.tan(math.radians(sp_lead))      # bump foot (bottom) corners
    xr = x1 + (zt - zb) / math.tan(math.radians(sp_hold))
    # where each ramp leaves the hump's crest line z = sp_top
    yl = x0 - (zt - sp_top) / math.tan(math.radians(sp_lead))
    yr = x1 + (zt - sp_top) / math.tan(math.radians(sp_hold))
    pts = [(a - run - 4, zr - 1), (a - run - 4, zr), (a - run, zr), (a, sp_top), (yl, sp_top), (x0, zt),
           (x1, zt), (yr, sp_top), (b, sp_top), (b + run, zr), (b + run + 4, zr), (b + run + 4, zr - 1)]
    rad = {2: sp_hump_r, 3: sp_hump_r, 4: sp_fillet_r, 5: sp_crest_r, 6: sp_crest_r, 7: sp_fillet_r,
           8: sp_hump_r, 9: sp_hump_r}
    return _fillet_poly(pts, rad)


def emit_spring_lock(name="tray", defl=sp_preload):
    """Hump + bump joined on both wall tops, then the slits cut through."""
    # the oracle `tray` part is caddy_tray(spring_defl = sp_preload) (assembled.scad), so default to that
    pr = spring_profile_pts(defl)
    for s in (-1, 1):
        y = c_in_w / 2 if s > 0 else -c_in_w / 2 - c_wall
        _cut_xz(pr, y, c_wall, [name], op="join")
    r = sp_gap / 2
    for s in (-1, 1):
        y = c_in_w / 2 - 1 if s > 0 else -c_in_w / 2 - c_wall - 1
        add("sketch.create", {"plane": "XZ", "offset": round(y, 4)})
        add("sketch.slot.center_to_center", {"p0": [sp_x[0] + r, round(-(sp_slit_z + r), 4)],
                                             "p1": [sp_x[1] - r, round(-(sp_slit_z + r), 4)], "width": str(sp_gap)})
        add("sketch.finish", {})
        add("solid.extrude", {"distance": str(c_wall + 2), "operation": "cut", "targets": [name]})


# ---- reference 3.5" drive (scad/hdd.scad) ----------------------------------
hdd_r, hdd_lid, hdd_lid_in = 2.54, 0.75, 5.6
hdd_side_hole_z = 6.35
hdd_bot_hole_x = [41.28, 85.73, 117.48]
hdd_bot_hole_y = 95.25 / 2
hdd_hole_minor_d, hdd_hole_depth = 2.8, 3.56
sata_pitch, sata_sig_l, sata_key_l, sata_pwr_l = 1.27, 10.4, 2.4, 20.6
sata_tongue_t, sata_tongue_z, sata_tongue_depth = 1.6, 2.6, 6.0
sata_pocket_h, sata_pocket_d, sata_pocket_pad = 9.0, 6.5, 1.5
sata_y0 = hdd_w / 2 - 13.43
sata_l = sata_sig_l + sata_key_l + sata_pwr_l
sata_z0 = c_floor + sata_tongue_z


def emit_hdd():
    """Reference drive in the shared frame: base + raised inset lid (rounded
    rects via filleted rectangle sketches), side/bottom tapped holes, connector
    pocket, SATA tongue (blades + keying feet).  The goldenrod contact grooves
    (0.1 mm deep, colour-only) are omitted."""
    name = "hdd"
    add("component.create", {"name": "Hdd", "activate": True})

    def rrect(x0, l, w, z, h, op, first=False):
        add("sketch.create", {"plane": "XY", "offset": round(z, 4)})
        add("sketch.line", {"points": [[x0, -w / 2], [x0 + l, -w / 2], [x0 + l, w / 2], [x0, w / 2]], "closed": True})
        for a, b in (("l1", "l2"), ("l2", "l3"), ("l3", "l4"), ("l4", "l1")):
            add("sketch.fillet", {"a": a, "b": b, "radius": str(hdd_r)})
        add("sketch.finish", {})
        p = {"distance": str(round(h, 4)), "operation": op}
        if first:
            p.update({"name": name, "body_name": name})
        else:
            p["targets"] = [name]
        add("solid.extrude", p)
    rrect(0.0, hdd_l, hdd_w, c_floor, hdd_h - hdd_lid, "new", True)
    rrect(hdd_lid_in, hdd_l - 2 * hdd_lid_in, hdd_w - 2 * hdd_lid_in, c_floor, hdd_h, "join")
    # tapped holes
    zc = c_floor + hdd_side_hole_z
    for x in (28.5, 130.1):
        for s in (-1, 1):
            add("solid.cylinder", {"diameter": str(hdd_hole_minor_d), "height": str(round(hdd_hole_depth + 0.1, 4)),
                                   "base": [str(x), str(round(s * hdd_w / 2 + s * 0.1, 4)), str(zc)],
                                   "axis": [0, -s, 0], "operation": "cut", "targets": [name]})
    for x in hdd_bot_hole_x:
        for s in (-1, 1):
            add("solid.cylinder", {"diameter": str(hdd_hole_minor_d), "height": str(round(hdd_hole_depth + 0.1, 4)),
                                   "base": [str(x), str(round(s * hdd_bot_hole_y, 4)), str(c_floor - 0.1)],
                                   "axis": [0, 0, 1], "operation": "cut", "targets": [name]})

    def box(x0, x1, ya, yb, z0, z1, op):
        # connector frame: u = sata_y0 - y, so u in [ua, ub] -> y in [y0-ub, y0-ua]
        add("solid.box", {"length": str(round(x1 - x0, 4)), "width": str(round(yb - ya, 4)),
                          "height": str(round(z1 - z0, 4)),
                          "corner": [str(round(x0, 4)), str(round(ya, 4)), str(round(z0, 4))],
                          "operation": op, "targets": [name]})
    # connector pocket: u -pad .. sata_l+pad, x -0.1 .. pocket_d, z floor-0.1 .. floor+pocket_h
    box(-0.1, sata_pocket_d, sata_y0 - sata_l - sata_pocket_pad, sata_y0 + sata_pocket_pad,
        c_floor - 0.1, c_floor + sata_pocket_h, "cut")
    # SATA tongue: signal blade, power blade, two keying feet
    tx0, tx1 = 0.3, 0.3 + sata_tongue_depth
    zt1 = sata_z0 + sata_tongue_t
    box(tx0, tx1, sata_y0 - sata_sig_l, sata_y0, sata_z0, zt1, "join")
    up = sata_sig_l + sata_key_l
    box(tx0, tx1, sata_y0 - up - sata_pwr_l, sata_y0 - up, sata_z0, zt1, "join")
    for u in (0.0, up):
        box(tx0, tx1, sata_y0 - u - 0.8, sata_y0 - u, sata_z0 - 1.0, sata_z0, "join")


def emit_tray_full():
    info = emit_tray_base()
    emit_fingers()
    emit_spring_lock()
    return info


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
    if len(sys.argv) > 2 and sys.argv[1] == "tray":
        info = emit_tray_full() if "--base" not in sys.argv else emit_tray_base()
        dump(sys.argv[2])
        print(f"tray: {info}, commands {len(cmds)}")
        sys.exit(0)
    if len(sys.argv) > 2 and sys.argv[1] == "hdd":
        emit_hdd()
        dump(sys.argv[2])
        print(f"hdd: commands {len(cmds)}")
        sys.exit(0)
    if len(sys.argv) > 2 and sys.argv[1] == "plate":
        n, plugs = emit_plate(sys.argv[2])
        dump(sys.argv[3])
        print(f"plate_{sys.argv[2]}: open cells {n}, plugs {plugs}, commands {len(cmds)}")
        sys.exit(0)
    _demo(sys.argv[1] if len(sys.argv) > 1 else "hc_demo.json")
