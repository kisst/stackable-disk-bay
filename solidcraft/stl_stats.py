#!/usr/bin/env python3
"""Print {volume_mm3, bbox} for an ASCII or binary STL (stdlib only)."""
import json, struct, sys


def triangles(path):
    data = open(path, "rb").read()
    if len(data) >= 84:
        n = struct.unpack_from("<I", data, 80)[0]
        if 84 + 50 * n == len(data):
            for i in range(n):
                v = struct.unpack_from("<12f", data, 84 + 50 * i)
                yield v[3:6], v[6:9], v[9:12]
            return
    pts = []
    for line in data.decode("ascii", "replace").splitlines():
        t = line.split()
        if t and t[0] == "vertex":
            pts.append(tuple(map(float, t[1:4])))
            if len(pts) == 3:
                yield tuple(pts)
                pts = []


def stats(path):
    vol = 0.0
    lo = [float("inf")] * 3
    hi = [float("-inf")] * 3
    edges = {}
    for a, b, c in triangles(path):
        vol += (a[0] * (b[1] * c[2] - b[2] * c[1])
                - a[1] * (b[0] * c[2] - b[2] * c[0])
                + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6.0
        for p in (a, b, c):
            for k in range(3):
                lo[k] = min(lo[k], p[k]); hi[k] = max(hi[k], p[k])
        for p, q in ((a, b), (b, c), (c, a)):
            e = (p, q)
            edges[e] = edges.get(e, 0) + 1
    # watertight: every directed edge has exactly one opposite
    bad = sum(1 for (p, q), n in edges.items() if edges.get((q, p), 0) != n)
    return {"volume_mm3": round(vol, 3),
            "bbox": [round(x, 3) for x in lo + hi],
            "open_edges": bad}


if __name__ == "__main__":
    print(json.dumps(stats(sys.argv[1])))
