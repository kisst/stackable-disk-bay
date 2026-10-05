#!/usr/bin/env bash
# Measure ventilation through the caddy floor and the bay's bottom plate.
# Fails if the two honeycombs no longer line up (through-open < 85 % of the
# smaller layer's opening).
set -euo pipefail
cd "$(dirname "$0")/.."
IMG=openscad/openscad:2021.01
mkdir -p out/vent
run() { docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work "$IMG" "$@"; }
area() { python3 - "$1" <<'PY'
import sys, os; sys.path.insert(0, "scripts")
from stl_components import read_stl, volume
print(round(volume(read_stl(sys.argv[1])), 1))
PY
}
declare -A A
for w in footprint floor plate through; do
  rm -f "out/vent/$w.stl"
  run openscad -D "which=\"$w\"" -o "out/vent/$w.stl" scad/vent.scad >"out/vent/$w.log" 2>&1 || true
  # every region has area; no file means OpenSCAD failed
  [ -f "out/vent/$w.stl" ] || { echo "FAIL  vent $w: OpenSCAD produced nothing, see out/vent/$w.log"; exit 1; }
  A[$w]=$(area "out/vent/$w.stl")
done
python3 - "${A[footprint]}" "${A[floor]}" "${A[plate]}" "${A[through]}" <<'PY'
import sys
fp, fl, pl, th = map(float, sys.argv[1:])
print(f"drive footprint          {fp:8.0f} mm^2")
print(f"caddy floor open         {fl:8.0f} mm^2  {100*fl/fp:5.1f} %")
print(f"bay bottom plate open    {pl:8.0f} mm^2  {100*pl/fp:5.1f} %")
print(f"open straight through    {th:8.0f} mm^2  {100*th/fp:5.1f} %  of footprint")
r = 100*th/min(fl,pl)
print(f"                                  {r:5.1f} %  of the smaller layer's opening")
# the two lattices are meant to coincide; anything well under 90 % means they drifted apart
sys.exit(0 if r >= 85 else 1)
PY
