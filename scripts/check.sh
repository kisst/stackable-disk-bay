#!/usr/bin/env bash
# Run the interference checks in scad/checks.scad and assert the outcome.
#   scripts/check.sh          all checks (single-unit + loaded 2x2 array)
#   scripts/check.sh quick    single-unit checks only
#   scripts/check.sh array    loaded 2x2 array only
#   scripts/check.sh acc      accessories only (2.5" adapter, feet, joiners)
#   scripts/check.sh only a b  the named checks only
set -uo pipefail
cd "$(dirname "$0")/.." || exit
IMG=openscad/openscad:2021.01
[ "${1:-all}" = only ] || rm -rf out/checks; mkdir -p out/checks   # OpenSCAD writes no file for an empty result
run() { docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work "$IMG" "$@"; }
facets() { [ -f "$1" ] || { echo 0; return; }; grep -c 'facet normal' "$1" || true; }
# export one check; OpenSCAD writes no file for an empty result, so a missing
# file is only "empty" if the log says so, anything else is an error
export_check() {
  local f="out/checks/$1.stl"; rm -f "$f"
  run openscad -D "check=\"$1\"" -o "$f" scad/checks.scad >"$f.log" 2>&1
  # an undefined value (a variable used before it is set, say) can quietly
  # drop a feature, and a check without it may pass for the wrong reason
  ! grep -qE '^ERROR:|unknown variable|undefined operation|Unable to convert' "$f.log" &&
    { [ -f "$f" ] || grep -q "top level object is empty" "$f.log"; }
}
# largest enclosed volume of any contact body, mm^3: 0 means faces touch, nothing overlaps
thick() { [ -f "$1" ] || { echo 0; return; }; python3 - "$1" <<'PY'
import sys, os; sys.path.insert(0, "scripts")
from stl_components import read_stl, max_body_volume
v = max_body_volume(read_stl(sys.argv[1]))
print(0 if v < 0.01 else round(v, 2))
PY
}
fail=0
empty_checks="walls_in_plates rear_in_bay hdd_vs_rear plugs_vs_rear caddy_in_bay bezel_on_tray hdd_in_caddy path_caddy_slide lock_track path_bezel_lip plugs_vs_caddy path_caddy_past_panel stack side path_wall_onto_panel path_rear_drop path_top_drop path_wall_slide"
hold_checks="plugs_on_tongue bezel_engaged bezel_locked tabs_engaged rear_engaged rear_in_walls wall_lift_locked wall_out_locked bezel_seats bezel_tabs_locked caddy_locked bezel_lip_holds posts_hold stack_holds side_holds"
lock_checks="wall_lift_locked wall_out_locked bezel_tabs_locked"
array_checks="array_diag_a array_diag_b array_stack2 array_side2 array_caddy_vs_neighbours"
acc_empty="adapter_in_caddy hdd25_in_adapter plugs25_vs_rear feet_in_plate joiner_w_stack joiner_w_run joiner_h_side joiner_h_run joiner_h3_run"
acc_hold="adapter_held hdd25_held feet_hold joiner_w_holds joiner_w_locks joiner_h_holds joiner_h_locks joiner_h3_locks"
case "${1:-all}" in
  quick) ;;
  array) empty_checks="$array_checks"; hold_checks="" ;;
  acc)   empty_checks="$acc_empty"; hold_checks="$acc_hold" ;;
  all)   empty_checks="$empty_checks $array_checks $acc_empty"; hold_checks="$hold_checks $acc_hold" ;;
  only)  shift; sel=" $* "; e=""; h=""
         for c in $empty_checks $array_checks $acc_empty; do case "$sel" in *" $c "*) e="$e $c";; esac; done
         for c in $hold_checks $acc_hold;                do case "$sel" in *" $c "*) h="$h $c";; esac; done
         for c in $sel; do case " $empty_checks $array_checks $acc_empty $hold_checks $acc_hold " in *" $c "*) ;; *) echo "FAIL  $c: no such check"; fail=1;; esac; done
         empty_checks="$e"; hold_checks="$h" ;;
esac
for c in $empty_checks; do
  export_check "$c" || { echo "FAIL  $c: OpenSCAD error or undefined value, see out/checks/$c.stl.log"; fail=1; continue; }
  n=$(facets "out/checks/$c.stl"); t=0; [ "$n" -eq 0 ] || t=$(thick "out/checks/$c.stl")
  if [ "$n" -eq 0 ]; then echo "PASS  $c: no contact"
  elif [ "$t" = "0" ] || [ "$t" = "0.0" ]; then echo "PASS  $c: touching on faces only, no overlap"
  else echo "FAIL  $c: overlap, $n facets, largest overlapping body $t mm^3"; python3 scripts/stl_bbox.py "out/checks/$c.stl"; fail=1; fi
done
for c in $hold_checks; do
  export_check "$c" || { echo "FAIL  $c: OpenSCAD error or undefined value, see out/checks/$c.stl.log"; fail=1; continue; }
  n=$(facets "out/checks/$c.stl")
  # a lock check moves a part along the way it must not go: a face it
  # merely slides along is not a lock, the moved part has to cut into
  case " $lock_checks " in *" $c "*)
    t=0; [ "$n" -eq 0 ] || t=$(thick "out/checks/$c.stl")
    if [ "$t" != "0" ] && [ "$t" != "0.0" ]; then echo "PASS  $c: blocked ($t mm^3 in the way)"
    else echo "FAIL  $c: nothing blocks, faces only slide ($n facets)"; fail=1; fi
    continue;;
  esac
  if [ "$n" -gt 0 ]; then echo "PASS  $c: held ($n facets engaged)"; else echo "FAIL  $c: nothing holds"; fail=1; fi
done
exit $fail
