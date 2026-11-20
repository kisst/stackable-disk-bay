# SolidCraft port: verification summary

Port tracks v0.4.0 (a6c2813).

Oracle: `scad/assembled.scad` rendered per part with OpenSCAD (`openscad/openscad:2021.01`, `oracle.sh`, drive 35).
Checks: `verify.py` (volume within 2%, bbox within 0.2 mm), `probe.py` (z-slice occupancy vs oracle), and `inspect.interference` on the assembly.
The per-part `*.results.json` and `.sc` are regenerable and gitignored; this file is the committed record.

## Per part

| Part | Oracle vol (mm3) | SolidCraft vol (mm3) | Vol delta | Bbox delta | Probe | Open honeycomb cells |
|---|---|---|---|---|---|---|
| plate_top | 24331.2 | 24343.5 | +0.051% | 0.000 mm | per-part task | 208 |
| plate_bottom | 24542.1 | 24554.4 | +0.050% | 0.000 mm | per-part task | 208 |
| wall_l | 9136.7 | 9148.1 | +0.125% | 0.000 mm | per-part task | 37 |
| wall_r | 9136.7 | 9148.1 | +0.125% | 0.000 mm | per-part task | 37 |
| rear | 4983.0 | 4983.0 | 0.000% | 0.000 mm | per-part task | 21 |
| bezel | 5129.5 | 5129.3 | -0.002% | 0.000 mm | per-part task | 37 (whole-face) |
| tray | 32206.7 | 32177.9 | -0.089% | 0.000 mm | per-part task | 214 floor, 30 / 18 walls |
| hdd | 385632.4 | 385628.6 | -0.001% | 0.000 mm | match, 0 differing (z=5, 15, 27) | n/a |

hdd.scad is unchanged v0.2.0 to v0.4.0, so `emit_hdd` needed no edit.
Known small deviations: bump taper not modelled (walls +0.125%); hdd goldenrod grooves omitted (colour-only, 0.1 mm).

## Whole assembly (v0.4.0)

- `inspect.interference` on all 8 bodies: checked 8, pairs_intersected 14, count 0, truncated false.
  The 4 plate/wall pairs (plate_top/bottom x wall_l/r, the dovetail joints) could not be evaluated by SMLib
  ("result is not a closed solid", touching dovetail faces) and are listed as `unchecked`.
  They were checked separately by point-sampling the exported STLs (0.2 x 0.1 x 0.1 mm grid over the bbox overlap):
  3 of 4 pairs 0 overlap samples; plate_top x wall_r 8 samples (about 0.016 mm3, a 0.01 mm sheet at z=30.01 on the
  press-fit face, tessellation hairline at the intended contact, not a real overlap).
- Whole-bay bbox equals oracle `part=""`: [-7, -57.7, -3.8] to [159.5, 57.7, 33.8], delta 0.0 mm.
- Joining-bump invariant (`check_bumps.py`): all distances 0.000.
- Sum of body volumes 495113 mm3 vs oracle 495098 mm3 (+0.003%).
- Artifacts: `bay_full.step`, `bay_full_{iso,top,front,section}.png`.
