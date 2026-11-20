# SolidCraft port: verification summary

Oracle: `scad/assembled.scad` rendered per part with OpenSCAD (`openscad/openscad:2021.01`, `oracle.sh`).
Checks: `verify.py` (volume within 2%, bbox within 0.2 mm), `probe.py` (z-slice occupancy vs oracle), and `inspect.interference` on the assembly.
The per-part `*.results.json` are regenerable and gitignored; this file is the committed record.

## Per part

| Part | Oracle vol (mm3) | SolidCraft vol (mm3) | Vol delta | Bbox delta | Probe | Open honeycomb cells |
|---|---|---|---|---|---|---|
| plate_top | 24913.5 | 24925.8 | +0.049% | 0.000 mm | match, 0 differing (z=31.2) | 208 |
| plate_bottom | 25113.4 | 25125.7 | +0.049% | 0.000 mm | match, 0 differing (z=-1.2) | 208 |
| wall_l | 8594.3 | 8606.5 | +0.142% | 0.000 mm | match (z=2, 15, 32) | 37 |
| wall_r | 8594.3 | 8606.5 | +0.142% | 0.000 mm | match (z=2, 15, 32) | 37 |
| rear | 4983.0 | 4983.0 | 0.000% | 0.000 mm | match, 0 differing (8 z levels) | 21 |
| bezel | 5379.6 | 5379.5 | 0.000% | 0.000 mm | match (9 z levels) | 28 |
| tray | 32049.4 | 32020.5 | -0.090% | 0.000 mm | match (12 z levels) | 214 floor, 26 / 17 walls |
| hdd | 385632.4 | 385628.6 | -0.001% | 0.000 mm | match, 0 differing (5 z levels) | n/a |

Known small deviations: bump taper not modelled (walls +0.14%); hdd goldenrod grooves omitted (colour-only, 0.1 mm).

## Whole assembly

- `inspect.interference`: 8 bodies checked, 14 pairs, count 0, not truncated.
- Whole-bay bbox equals oracle `part=""`: [-10, -57.7, -3.8] to [149.5, 57.7, 33.8], delta 0.0 mm.
- Joining-bump invariant (`check_bumps.py`): all distances 0.000.
- Sum of body volumes 495276 mm3 vs oracle 495260 mm3 (0.003%).
