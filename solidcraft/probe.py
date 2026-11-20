#!/usr/bin/env python3
"""Occupancy probe: compare a SolidCraft STL export to the oracle STL by
ray-casting along z through a grid of (x, y) points and testing whether the
point at height z is inside the solid.  Unlike volume/bbox it is sensitive to
WHERE features sit, so a symmetric swap (e.g. slots at +y instead of -y) fails.

Usage: probe.py <got.stl> <oracle.stl> <z> [step_mm=1.0] [max_diff_frac=0.002]
Prints PROBE-MATCH / PROBE-MISMATCH with the count and a few differing points;
exit 0 / 1."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stl_stats import triangles  # noqa: E402


class Solid:
    def __init__(self, path, cell=4.0):
        self.cell, self.buckets = cell, {}
        for a, b, c in triangles(path):
            xs, ys = (a[0], b[0], c[0]), (a[1], b[1], c[1])
            for i in range(int(min(xs) // cell), int(max(xs) // cell) + 1):
                for j in range(int(min(ys) // cell), int(max(ys) // cell) + 1):
                    self.buckets.setdefault((i, j), []).append((a, b, c))

    def inside(self, x, y, z):
        n = 0
        for a, b, c in self.buckets.get((int(x // self.cell), int(y // self.cell)), ()):
            d = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1])
            if abs(d) < 1e-12:
                continue
            l1 = ((b[1] - c[1]) * (x - c[0]) + (c[0] - b[0]) * (y - c[1])) / d
            l2 = ((c[1] - a[1]) * (x - c[0]) + (a[0] - c[0]) * (y - c[1])) / d
            if l1 < 0 or l2 < 0 or l1 + l2 > 1:
                continue
            if l1 * a[2] + l2 * b[2] + (1 - l1 - l2) * c[2] > z:
                n += 1
        return n % 2 == 1


def main(argv):
    if len(argv) < 4:
        sys.exit(__doc__)
    got, ref, z = Solid(argv[1]), Solid(argv[2]), float(argv[3])
    step = float(argv[4]) if len(argv) > 4 else 1.0
    tol = float(argv[5]) if len(argv) > 5 else 0.002
    # off-lattice offset keeps samples off exact face/edge coincidences
    xs = [-5 + 0.013 + i * step for i in range(int(153 / step))]
    ys = [-57 + 0.017 + j * step for j in range(int(114 / step))]
    diffs, solid = [], 0
    for x in xs:
        for y in ys:
            g, r = got.inside(x, y, z), ref.inside(x, y, z)
            solid += r
            if g != r:
                diffs.append((round(x, 1), round(y, 1), "got" if g else "ref"))
    frac = len(diffs) / (len(xs) * len(ys))
    ok = frac <= tol
    print(f"{'PROBE-MATCH' if ok else 'PROBE-MISMATCH'} z={z} samples={len(xs) * len(ys)} "
          f"oracle-solid={solid} differing={len(diffs)} ({frac:.3%}) first={diffs[:6]}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
