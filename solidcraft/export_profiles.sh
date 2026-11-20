#!/usr/bin/env bash
# Export the tray's 2D profiles (push/pull plan + side + grip hole) from scad/caddy.scad
# via OpenSCAD's own offset()/fillet math to solidcraft/tray_profiles.json, as [x, y] point
# lists (y already un-flipped from SVG).  gen_full.py reads these: no 2D offset library needed.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
mkdir -p solidcraft/oracle
mods="pull_plan2d push_plan2d pull_side2d push_side2d pull_hole2d"
for m in $mods; do
  printf 'include <caddy.scad>\n%s();\n' "$m" > "scad/_tmp_$m.scad"
  docker run --rm -v "$root":/work -w /work openscad/openscad:2021.01 \
    openscad -D 'part="none"' -o "solidcraft/oracle/$m.svg" "scad/_tmp_$m.scad" >&2
  rm -f "scad/_tmp_$m.scad"
done
{
  echo "{"
  first=1
  for m in $mods; do
    [ $first = 1 ] || echo ","
    first=0
    printf '"%s": ' "$m"
    sed -n '/<path/,/stroke/p' "solidcraft/oracle/$m.svg" | tr '\n' ' ' \
      | grep -o '[ML] *[-0-9.e]*,[-0-9.e]*' | sed 's/^[ML] *//' \
      | awk -F, 'BEGIN{printf "["} {if(NR>1)printf ","; y=-$2; if(y==0)y=0; printf "[%s,%s]",$1,y} END{printf "]"}'
  done
  echo
  echo "}"
} | jq -c '.' > solidcraft/tray_profiles.json
jq 'map_values(length)' solidcraft/tray_profiles.json
