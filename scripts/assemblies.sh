#!/usr/bin/env bash
# Coloured 3MF assemblies for review and the release: one object per part,
# each in its own colour. Each part is exported from OpenSCAD in Docker and
# merged by color_mesh.py (dependency-free python3).
#   scripts/assemblies.sh              all of them -> out/assemblies/*.3mf
#   scripts/assemblies.sh bay caddy_hdd35   the named ones only
#     assembled_hdd35  bay, caddy and 3.5" drive
#     assembled_hdd25  bay, caddy, 2.5" adapter and 2.5" drive
#     bay              the bay alone: plates, walls, rear panel
#     caddy_hdd35      tray, bezel and 3.5" drive
#     caddy_hdd25      tray, bezel, 2.5" adapter and 2.5" drive
# Only the parts the named assemblies need are rendered, once each, in
# parallel, into out/assemblies/parts/.
set -euo pipefail
cd "$(dirname "$0")/.." || exit
IMG=openscad/openscad:2021.01
O=out/assemblies
P=$O/parts
mkdir -p "$P"
run() { docker run --rm --network none --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work "$IMG" openscad "$@" >/dev/null 2>&1; }

# parts as part:colour. hdd<d>_<part> is seated in the shared frame, the
# tray's springs preloaded under the top plate; the bay's parts are the same
# for both drives, so they come from the 3.5" render. *_free is out of the
# bay, the tray's springs as printed.
bay="hdd35_plate_bottom:#4a7fb5 hdd35_plate_top:#7fb0dd hdd35_wall_l:#3f9a5c hdd35_wall_r:#8cc63f hdd35_rear:#8e6fd1"
declare -A asm=(
  [assembled_hdd35]="$bay hdd35_tray:#d9822b hdd35_bezel:#8a4b1a hdd35_hdd:#555c66"
  [assembled_hdd25]="$bay hdd25_tray:#d9822b hdd25_bezel:#8a4b1a hdd25_adapter:#c9a227 hdd25_hdd:#555c66"
  [bay]="$bay"
  [caddy_hdd35]="tray_free:#d9822b bezel_free:#8a4b1a hdd35_hdd:#555c66"
  [caddy_hdd25]="tray_free:#d9822b bezel_free:#8a4b1a hdd25_adapter:#c9a227 hdd25_hdd:#555c66"
)
order="assembled_hdd35 assembled_hdd25 bay caddy_hdd35 caddy_hdd25"
names=("$@"); [ ${#names[@]} -eq 0 ] && read -ra names <<< "$order"
for n in "${names[@]}"; do [ -n "${asm[$n]:-}" ] || { echo "no such assembly: $n (one of: $order)"; exit 1; }; done

render() {
  local k=$1 f="$P/$1.stl"
  case "$k" in
    tray_free)  run -D 'part="tray"'  -o "$f" scad/caddy.scad ;;
    bezel_free) run -D 'part="bezel"' -o "$f" scad/caddy.scad ;;
    hdd*_*)     local d=${k%%_*}; run -D "drive=\"${d#hdd}\"" -D "part=\"${k#*_}\"" -o "$f" scad/assembled.scad ;;
  esac || { echo "FAIL  $k"; return 1; }
  echo "== $k"
}
declare -A need=()
for n in "${names[@]}"; do for s in ${asm[$n]}; do need[${s%%:*}]=1; done; done
pids=()
for k in "${!need[@]}"; do render "$k" & pids+=($!); done
fail=0; for p in "${pids[@]}"; do wait "$p" || fail=1; done
[ $fail -eq 0 ] || exit 1

for n in "${names[@]}"; do
  specs=(); for s in ${asm[$n]}; do specs+=("$P/${s%%:*}.stl::${s#*:}"); done
  python3 scripts/color_mesh.py "$O/$n" "${specs[@]}"
done
for n in "${names[@]}"; do ls -la "$O/$n.3mf"; done
