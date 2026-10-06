#!/usr/bin/env bash
# Coloured 3MF assemblies for review and the release: one object per part,
# each in its own colour. Every part is exported from OpenSCAD in Docker and
# merged by color_mesh.py (dependency-free python3).
#   scripts/assemblies.sh    -> out/assemblies/*.3mf
#     assembled_hdd35  bay, caddy and 3.5" drive
#     assembled_hdd25  bay, caddy, 2.5" adapter and 2.5" drive
#     bay              the bay alone: plates, walls, rear panel
#     caddy_hdd35      tray, bezel and 3.5" drive
#     caddy_hdd25      tray, bezel, 2.5" adapter and 2.5" drive
set -euo pipefail
cd "$(dirname "$0")/.." || exit
IMG=openscad/openscad:2021.01
O=out/assemblies
mkdir -p "$O"
run() { docker run --rm --network none --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work "$IMG" openscad "$@" >/dev/null 2>&1; }
# seated, in the shared frame: the tray's springs preloaded under the top plate
for d in 35 25; do
  parts="tray bezel hdd"                     # the bay's parts are the same for both drives
  [ "$d" = 35 ] && parts="plate_bottom plate_top wall_l wall_r rear $parts"
  [ "$d" = 25 ] && parts="$parts adapter"
  for p in $parts; do
    echo "== hdd$d $p"
    run -D "drive=\"$d\"" -D "part=\"$p\"" -o "$O/hdd${d}_$p.stl" scad/assembled.scad
  done
done
# out of the bay: the tray's springs as printed
echo "== tray (free)";  run -D 'part="tray"'  -o "$O/tray_free.stl" scad/caddy.scad
echo "== bezel (free)"; run -D 'part="bezel"' -o "$O/bezel_free.stl" scad/caddy.scad
plate_b="$O/hdd35_plate_bottom.stl::#4a7fb5"; plate_t="$O/hdd35_plate_top.stl::#7fb0dd"
wall_l="$O/hdd35_wall_l.stl::#3f9a5c";        wall_r="$O/hdd35_wall_r.stl::#8cc63f"
rear="$O/hdd35_rear.stl::#8e6fd1"
tray_free="$O/tray_free.stl::#d9822b";        bezel_free="$O/bezel_free.stl::#8a4b1a"
python3 scripts/color_mesh.py "$O/assembled_hdd35" "$plate_b" "$plate_t" "$wall_l" "$wall_r" "$rear" \
  "$O/hdd35_tray.stl::#d9822b" "$O/hdd35_bezel.stl::#8a4b1a" "$O/hdd35_hdd.stl::#555c66"
python3 scripts/color_mesh.py "$O/assembled_hdd25" "$plate_b" "$plate_t" "$wall_l" "$wall_r" "$rear" \
  "$O/hdd25_tray.stl::#d9822b" "$O/hdd25_bezel.stl::#8a4b1a" "$O/hdd25_adapter.stl::#c9a227" "$O/hdd25_hdd.stl::#555c66"
python3 scripts/color_mesh.py "$O/bay" "$plate_b" "$plate_t" "$wall_l" "$wall_r" "$rear"
python3 scripts/color_mesh.py "$O/caddy_hdd35" "$tray_free" "$bezel_free" "$O/hdd35_hdd.stl::#555c66"
python3 scripts/color_mesh.py "$O/caddy_hdd25" "$tray_free" "$bezel_free" "$O/hdd25_adapter.stl::#c9a227" "$O/hdd25_hdd.stl::#555c66"
ls -la "$O"/*.3mf
