#!/usr/bin/env bash
# Compile every part to STL (and a preview PNG) with OpenSCAD in Docker.
# Node-free, host-install-free: the only requirement is Docker.
#   scripts/render.sh            # all parts
#   scripts/render.sh caddy bay  # selected parts
set -euo pipefail
cd "$(dirname "$0")/.." || exit
IMG=openscad/openscad:2021.01
parts=("$@"); [ ${#parts[@]} -eq 0 ] && parts=(caddy_tray bezel plate wall rear coupon adapter25 foot joiner hdd sata_plugs testfit assembly)
mkdir -p out
run() { docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work "$IMG" "$@"; }
for p in "${parts[@]}"; do
  echo "== $p"
  case "$p" in
    assembly|testfit) ;;                      # views, not prints
    plate) run openscad -D 'kind="top"'    -o out/plate_top.stl    scad/plate.scad
           run openscad -D 'kind="bottom"' -o out/plate_bottom.stl scad/plate.scad ;;
    joiner) for k in w1 w05 h1 h05 h3; do run openscad -D "kind=\"$k\"" -o "out/joiner_$k.stl" scad/joiner.scad; done ;;
    *) run openscad -o "out/$p.stl" "scad/$p.scad" ;;
  esac
done
# Previews: the OpenSCAD image has no working offscreen GL, so shade the STLs
# ourselves in a throwaway python container.
PY=python:3.12-slim
pyrun() { docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -v "$PWD":/work -w /work "$PY" \
          sh -c "pip install -q --no-warn-script-location --root-user-action=ignore numpy matplotlib >/dev/null 2>&1; python scripts/preview.py $*"; }
for p in caddy_tray bezel plate_top plate_bottom wall rear coupon adapter25 foot joiner_w1 joiner_w05 joiner_h1 joiner_h05 joiner_h3 hdd sata_plugs; do [ -f out/$p.stl ] && pyrun out/$p.png out/$p.stl; done
# Coloured views. OpenSCAD's STL export drops colour, so each view is
# exported once per class (or per unit) and overlaid by the preview script.
CLASSES="plates:#4a7fb5 walls:#3f9a5c rears:#8e6fd1 caddies:#d9822b trays:#d9822b bezels:#8a4b1a hdds:#555c66 plugs:#a83232"
# 1. one unit with the drive, colour per part (also with the top plate lifted off)
for topflag in true false; do
  a=(); sfx=""; [ "$topflag" = false ] && sfx="_open"
  for pc in $CLASSES; do
    cls=${pc%%:*}; col=${pc##*:}; true
    run openscad -D "part=\"$cls\"" -D "show_top=$topflag" -o "out/unit${sfx}_$cls.stl" scad/testfit.scad >/dev/null 2>&1 && a+=("out/unit${sfx}_$cls.stl::$col")
  done
  [ ${#a[@]} -gt 0 ] && pyrun "out/testfit${sfx}.png" "${a[@]}"
done
# 1b. the fully assembled unit, every printed part plus the drive, no plugs
a=()
for pc in $CLASSES; do
  cls=${pc%%:*}; col=${pc##*:}; case "$cls" in plugs|caddies) continue;; esac
  [ -f "out/unit_$cls.stl" ] && a+=("out/unit_$cls.stl::$col")
done
[ ${#a[@]} -gt 0 ] && pyrun out/assembled.png "${a[@]}"
# 1c. how bays join: exploded stack, exploded side-by-side, one joint close up
for mode in stack side detail detail_side; do
  a=()
  for pc in lower:#4a7fb5 upper:#d9822b; do
    cls=${pc%%:*}; col=${pc##*:}
    run openscad -D "mode=\"$mode\"" -D "part=\"$cls\"" -o "out/join_${mode}_$cls.stl" scad/joining.scad >/dev/null 2>&1 && a+=("out/join_${mode}_$cls.stl::$col")
  done
  case $mode in
    stack)  v="--views=20,-55+0,-90+20,125" ;;
    side)   v="--views=20,-55+0,0+20,125" ;;
    detail) v="--views=25,-50+10,-100+40,-150" ;;
    detail_side) v="--views=25,-30+0,-10+30,40" ;;
  esac
  [ ${#a[@]} -gt 0 ] && pyrun "$v" "out/join_$mode.png" "${a[@]}"
done
# 1d. assembly drawing: panel in the bottom plate, walls at the sides, top plate above
a=()
for pc in plates:#4a7fb5 walls:#3f9a5c rears:#8e6fd1; do
  cls=${pc%%:*}; col=${pc##*:}
  run openscad -D 'mode="assembly"' -D "part=\"$cls\"" -o "out/asmdraw_$cls.stl" scad/joining.scad >/dev/null 2>&1 && a+=("out/asmdraw_$cls.stl::$col")
done
[ ${#a[@]} -gt 0 ] && pyrun --views=25,-50+0,-90+25,130 out/assembly_steps.png "${a[@]}"
# 1e. assembly steps for docs/assembly.md (copy out/step*.png to docs/img/)
STEPCOL="plates:#4a7fb5 walls:#3f9a5c rears:#8e6fd1 trays:#d9822b bezels:#8a4b1a hdds:#555c66"
stepview() {
  case $1 in
    1) echo "--views=25,-60 --titles=1._Walls_onto_the_rear_panel_side_tabs" ;;
    2) echo "--views=30,-130 --titles=2._Down_into_the_bottom_plate_together" ;;
    3) echo "--views=30,-60 --titles=3._Top_plate_on" ;;
    4) echo "--views=25,30 --titles=4._Bezel_onto_the_tray" ;;
    5) echo "--views=35,-60 --titles=5._Drive_into_the_caddy" ;;
    6) echo "--views=25,30 --titles=6._Slide_the_caddy_in" ;;
    7) echo "--views=15,20 --titles=7._Seated:_pull_by_the_notch" ;;
    8) echo "--views=20,145 --titles=Or_push_the_tab_from_behind --subdiv=4" ;;
  esac
}
for st in 1 2 3 4 5 6 7 8; do
  a=()
  for pc in $STEPCOL; do
    cls=${pc%%:*}; col=${pc##*:}
    run openscad -D "step=$st" -D "part=\"$cls\"" -o "out/step${st}_$cls.stl" scad/steps.scad >/dev/null 2>&1 && a+=("out/step${st}_$cls.stl::$col")
  done
  sub="--subdiv=8"; [ "$st" = 8 ] && sub=""
  # shellcheck disable=SC2046,SC2086
  [ ${#a[@]} -gt 0 ] && pyrun $(stepview "$st") $sub "out/step$st.png" "${a[@]}"
done
# 2. 2x2 combo, colour per part class
a=()
for pc in $CLASSES; do
  cls=${pc%%:*}; col=${pc##*:}
  run openscad -D "part=\"$cls\"" -o "out/asm_$cls.stl" scad/assembly.scad >/dev/null 2>&1 && a+=("out/asm_$cls.stl::$col")
done
[ ${#a[@]} -gt 0 ] && pyrun out/assembly_parts.png "${a[@]}"
# 3. 2x2 combo, colour per bay
a=()
for uc in 0:#d9822b 1:#4a7fb5 2:#3f9a5c 3:#8e6fd1; do
  un=${uc%%:*}; col=${uc##*:}
  run openscad -D "unit=$un" -o "out/asm_unit$un.stl" scad/assembly.scad >/dev/null 2>&1 && a+=("out/asm_unit$un.stl::$col")
done
[ ${#a[@]} -gt 0 ] && pyrun out/assembly_units.png "${a[@]}"
python3 scripts/stl_components.py out/*.stl
ls -la out
