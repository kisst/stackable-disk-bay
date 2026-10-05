#!/usr/bin/env python3
"""Render an STL (or several, each with an offset and colour) to a PNG.
Runs inside a python Docker image; see scripts/render.sh.
usage: preview.py out.png file.stl[:dx,dy,dz[:colour]] ..."""
import re, struct, sys
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

def read_stl(path):
    data = open(path, "rb").read()
    if data[:5] == b"solid" and b"facet" in data[:400]:
        v = np.array(re.findall(rb"vertex\s+(\S+)\s+(\S+)\s+(\S+)", data), dtype=float)
        return v.reshape(-1, 3, 3)
    n = struct.unpack_from("<I", data, 80)[0]
    rec = np.frombuffer(data[84:84 + 50*n], dtype=np.dtype([("n", "<3f4"), ("v", "<9f4"), ("a", "<u2")]))
    return rec["v"].reshape(-1, 3, 3).astype(float)

def main(out, specs, views):
    meshes = []
    for spec in specs:
        parts = spec.split(":")
        tris = read_stl(parts[0])
        if len(parts) > 1 and parts[1]:
            tris = tris + np.array([float(x) for x in parts[1].split(",")])
        colour = parts[2] if len(parts) > 2 else "#d9822b"
        meshes.append((tris, colour))
    allv = np.concatenate([m[0].reshape(-1, 3) for m in meshes])
    lo, hi = allv.min(0), allv.max(0); c = (lo + hi) / 2; r = (hi - lo).max() / 2
    ncols = min(3, len(views)); nrows = (len(views) + ncols - 1) // ncols
    fig = plt.figure(figsize=(16 if ncols == 3 else 5.5 * ncols, 5.5 * nrows), dpi=110)
    light = np.array([0.4, -0.6, 0.7]); light /= np.linalg.norm(light)
    for i, (elev, azim) in enumerate(views):
        ax = fig.add_subplot(nrows, ncols, i + 1, projection="3d")
        for tris, colour in meshes:
            n = np.cross(tris[:, 1] - tris[:, 0], tris[:, 2] - tris[:, 0])
            n /= np.linalg.norm(n, axis=1)[:, None] + 1e-12
            shade = 0.45 + 0.55 * np.clip(n @ light, 0, 1)
            base = np.array(matplotlib.colors.to_rgb(colour))
            cols = np.clip(base[None, :] * shade[:, None], 0, 1)
            ax.add_collection3d(Poly3DCollection(tris, facecolors=cols, edgecolors="none"))
        ax.set_xlim(c[0]-r, c[0]+r); ax.set_ylim(c[1]-r, c[1]+r); ax.set_zlim(c[2]-r, c[2]+r)
        ax.view_init(elev=elev, azim=azim); ax.set_axis_off()
        ax.set_title(f"elev {elev}  azim {azim}", fontsize=9)
    fig.tight_layout(); fig.savefig(out); print("wrote", out)

if __name__ == "__main__":
    args = sys.argv[1:]
    views = [(30, -60), (30, 120), (90, -90), (0, -90), (0, 0), (-30, -120)]
    # --views=elev,azim+elev,azim  picks the camera angles (default: six standard views)
    if args and args[0].startswith("--views="):
        views = [tuple(float(x) for x in v.split(",")) for v in args[0][8:].split("+")]
        args = args[1:]
    out, *specs = args
    main(out, specs, views)
