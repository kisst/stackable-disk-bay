#!/usr/bin/env bash
# Render one OpenSCAD part to STL and print {volume_mm3, bbox}.
# Usage: solidcraft/oracle.sh <part> [drive=35]
set -euo pipefail
part="${1:?usage: oracle.sh <part> [drive]}"
drive="${2:-35}"
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
mkdir -p solidcraft/oracle
docker run --rm -v "$root":/work -w /work openscad/openscad:2021.01 \
  openscad -D "part=\"$part\"" -D "drive=\"$drive\"" \
  -o "solidcraft/oracle/$part.stl" scad/assembled.scad >&2
python3 -I solidcraft/stl_stats.py "solidcraft/oracle/$part.stl"
