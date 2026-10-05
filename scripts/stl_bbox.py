#!/usr/bin/env python3
"""Print the bounding box of each STL (ASCII or binary). Dependency-free."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from stl_components import read_stl
for p in sys.argv[1:]:
    tris = read_stl(p)
    if not tris:
        print(f"{p}: empty"); continue
    vs = [v for t in tris for v in t]
    lo = [min(v[i] for v in vs) for i in range(3)]
    hi = [max(v[i] for v in vs) for i in range(3)]
    print(f"{p}: x {lo[0]:.2f}..{hi[0]:.2f}  y {lo[1]:.2f}..{hi[1]:.2f}  z {lo[2]:.2f}..{hi[2]:.2f}  ({len(tris)} facets)")
