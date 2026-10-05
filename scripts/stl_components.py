#!/usr/bin/env python3
"""Count disconnected bodies in a binary STL. Dependency-free.
A single printable part must report exactly 1."""
import re, struct, sys
from collections import defaultdict

def read_stl(path):
    with open(path, "rb") as f:
        data = f.read()
    if data[:5] == b"solid" and b"facet" in data[:400]:
        return read_ascii(data.decode())
    n = struct.unpack_from("<I", data, 80)[0]
    tris = []
    off = 84
    for _ in range(n):
        vals = struct.unpack_from("<12fH", data, off); off += 50
        tris.append([tuple(round(v, 3) for v in vals[3+3*i:6+3*i]) for i in range(3)])
    return tris

def read_ascii(text):
    verts = [tuple(round(float(v), 3) for v in m.groups())
             for m in re.finditer(r"vertex\s+(\S+)\s+(\S+)\s+(\S+)", text)]
    return [verts[i:i+3] for i in range(0, len(verts), 3)]

def bodies(tris):
    """Group triangles into connected bodies; returns a list of triangle lists."""
    parent = {}
    def find(a):
        while parent.setdefault(a, a) != a:
            parent[a] = parent[parent[a]]; a = parent[a]
        return a
    for t in tris:
        for a, b in ((t[0], t[1]), (t[1], t[2])):
            ra, rb = find(a), find(b)
            if ra != rb: parent[ra] = rb
    groups = defaultdict(list)
    for t in tris:
        groups[find(t[0])].append(t)
    return list(groups.values())

def volume(tris):
    """Enclosed volume (divergence theorem). A face-contact patch that CGAL
    emits as two coincident, opposed faces sums to ~0."""
    v = 0.0
    for a, b, c in tris:
        v += (a[0]*(b[1]*c[2]-b[2]*c[1]) - a[1]*(b[0]*c[2]-b[2]*c[0]) + a[2]*(b[0]*c[1]-b[1]*c[0])) / 6.0
    return abs(v)

def max_body_volume(tris):
    """Largest enclosed volume among the bodies: 0 means every body is a flat
    contact patch, > 0 means a real overlap."""
    return max((volume(b) for b in bodies(tris)), default=0.0)

def components(tris):
    parent = {}
    def find(a):
        while parent.setdefault(a, a) != a:
            parent[a] = parent[parent[a]]; a = parent[a]
        return a
    def union(a, b):
        ra, rb = find(a), find(b)
        if ra != rb: parent[ra] = rb
    for t in tris:
        union(t[0], t[1]); union(t[1], t[2])
    roots = defaultdict(int)
    for t in tris:
        roots[find(t[0])] += 1
    return sorted(roots.values(), reverse=True)

if __name__ == "__main__":
    for p in sys.argv[1:]:
        c = components(read_stl(p))
        print(f"{p}: {len(c)} body(ies); facets per body: {c[:12]}{' ...' if len(c) > 12 else ''}")
