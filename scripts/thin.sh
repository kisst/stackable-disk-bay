#!/usr/bin/env bash
# Thin-section check: no printed part may have material thinner than two
# perimeters (0.8 mm) in any slice. Slices along z (layers, 0.4 mm apart)
# and along x and y (2 mm apart, for material that is thin in z).
#   scripts/thin.sh                 all parts
#   scripts/thin.sh wall rear       selected parts
#   AXES="x y" scripts/thin.sh     selected slice axes (default z x y)
#   REPORT_ONLY=1 scripts/thin.sh   re-read the last exports, no OpenSCAD
set -uo pipefail
cd "$(dirname "$0")/.." || exit
IMG=openscad/openscad:2021.01
parts=("$@"); [ ${#parts[@]} -eq 0 ] && parts=(caddy_tray bezel plate wall rear adapter25 foot joiner_w1 joiner_w05 joiner_h1 joiner_h05 joiner_h3)
mkdir -p out/thin
run() { docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work "$IMG" "$@"; }
report() { python3 - "$1" "$2" <<'PY'
import sys, os; sys.path.insert(0, "scripts")
from stl_components import read_stl, bodies, volume
path, ax = sys.argv[1], "xyz".index(sys.argv[2])
OFF, MIN_LEN = 1000, 1.5
def bbox(b):
    vs = [v for t in b for v in t]
    return [min(v[i] for v in vs) for i in range(3)], [max(v[i] for v in vs) for i in range(3)]
thin, contact = [], []
for b in (bodies(read_stl(path)) if os.path.exists(path) else []):
    lo, hi = bbox(b)
    if lo[ax] > OFF / 2:                       # the contact group, shifted back
        lo[ax] -= OFF; hi[ax] -= OFF; contact.append((lo, hi))
    # the round dilation nibbles 0.4 mm off every convex corner: a right-angle
    # nib is 0.034 mm^2, two merged across a hair-thin slit about 0.07; a real
    # thin wedge (as over a finger root) is 0.3 or more
    elif volume(b) >= 0.02: thin.append((lo, hi, volume(b)))
def touches(a, c):                             # bboxes overlap, 0.1 mm slack
    return all(a[0][i] - 0.1 <= c[1][i] and c[0][i] <= a[1][i] + 0.1 for i in range(3))
found = []
for lo, hi, v in thin:
    n = sum(1 for c in contact if touches((lo, hi), c))
    ext = max(hi[i] - lo[i] for i in range(3) if i != ax)
    # one short contact is a slice grazing a sharp corner. An island is a
    # first layer in the air or a pillar in the z pass; in the x and y passes
    # it is the apex of a corner pointing along the slice normal, and anything
    # real there shows as a neck or a fin in another pass
    kind = ("island" if ax == 2 else None) if n == 0 else "neck or roof" if n >= 2 else "fin" if ext >= MIN_LEN else None
    if kind: found.append((lo, hi, v, kind))
found.sort(key=lambda f: -f[2])
for lo, hi, v, kind in found[:12]:
    print(f"        x {lo[0]:7.2f}..{hi[0]:7.2f}  y {lo[1]:7.2f}..{hi[1]:7.2f}  z {lo[2]:6.2f}..{hi[2]:6.2f}  {kind}")
if len(found) > 12: print(f"        ... {len(found) - 12} more")
sys.exit(1 if found else 0)
PY
}
fail=0
for p in "${parts[@]}"; do
  for ax in ${AXES:-z x y}; do
    case $ax in x|y|z) ;; *) echo "FAIL  no such axis: $ax"; fail=1; continue;; esac
    pitch=0.4; [ "$ax" = z ] || pitch=2
    f="out/thin/${p}_$ax.stl"
    [ -n "${REPORT_ONLY:-}" ] || { rm -f "$f"; run openscad -D "part=\"$p\"" -D "axis=\"$ax\"" -D "pitch=$pitch" -o "$f" scad/thin.scad >"$f.log" 2>&1; }
    # OpenSCAD writes no file for an empty result, which here is the good case
    if grep -q '^ERROR:' "$f.log" || { [ ! -f "$f" ] && ! grep -q "top level object is empty" "$f.log"; }; then
      echo "FAIL  $p along $ax: OpenSCAD produced nothing, see $f.log"; fail=1
    elif out=$(report "$f" "$ax"); then echo "PASS  $p along $ax: nothing under 0.8 mm"
    else echo "FAIL  $p along $ax: thin material (wafers 0.2 mm thick at the slices)"; echo "$out"; fail=1; fi
  done
done
exit $fail
