# Stackable disk bay

[![checks](https://github.com/kisst/stackable-disk-bay/actions/workflows/checks.yml/badge.svg)](https://github.com/kisst/stackable-disk-bay/actions/workflows/checks.yml)

A 3D-printable bay and toolless caddy for 3.5" hard drives, and for 2.5"
drives through an adapter in the same caddy. Bays are identical
and sit on top of and beside each other, located by hex bumps that drop into
the neighbour's honeycomb, with no connector parts. The drive drops into the
caddy without screws; the caddy slides into the bay and clicks home. Every
part prints flat, no supports.

![One assembled unit from six directions, one colour per printed part](docs/img/assembled.png)

**Status: first test print done; its findings are in this revision, which
is verified by the geometry checks but not yet reprinted.** The drive-in-caddy
fit is still untested. See [docs/design.md](docs/design.md) for the spec and
the print results.

## Parts

| Part | File | Per bay | Print |
| --- | --- | --- | --- |
| Caddy tray | `scad/caddy_tray.scad` | 1 | flat on its floor |
| Caddy bezel | `scad/bezel.scad` | 1 | flat, front face down |
| Plate, top and bottom | `scad/plate.scad` | 1 + 1 | flat, bumps up; top has six slots, bottom two |
| Wall (left and right) | `scad/wall.scad` | 2 | flat, bumps up |
| Rear panel | `scad/rear.scad` | 1 | flat |
| Pin coupon | `scad/coupon.scad` | optional | flat |

Accessories:

| Part | File | Use | Print |
| --- | --- | --- | --- |
| 2.5" adapter | `scad/adapter25.scad` | one per 2.5" drive, in a normal caddy | flat on its base |
| Foot | `scad/foot.scad` | four under each bottom bay | flat, pins up |
| Width joiner, 1 and 0.5 | `scad/joiner.scad`, `kind="w1"` / `"w05"` | between stacked bays | flat |
| Height joiner, 3, 1 and 0.5 | `scad/joiner.scad`, `kind="h3"` / `"h1"` / `"h05"` | between bays side by side | flat |

Print the coupon first: a 34 mm slice of the caddy with one fixed pin and one
finger, to check pin diameter and finger stiffness on a real drive.

Views (not prints), all in `out/` after a render:

| Image | Shows |
| --- | --- |
| `assembled.png` | one assembled unit, every printed part plus the drive |
| `testfit.png`, `testfit_open.png` | one unit with the drive and SATA plugs, one colour per part; the second with the top plate lifted off |
| `assembly_steps.png` | assembly drawing: walls on the rear panel's side tabs, lifted above the bottom plate, top plate above |
| `join_stack.png`, `join_side.png`, `join_detail*.png` | how bays join, exploded and close up |
| `assembly_parts.png` | the 2 × 2 combo, one colour per part class |
| `assembly_units.png` | the 2 × 2 combo, one colour per bay |

![A 2 × 2 block of loaded bays, one colour per bay](docs/img/assembly_units.png)

The walls and rear panel carry a low groove that must line up round the
bay. The plates need no mark: the top has six slots, the bottom two, and
the rear-panel slots sit at the rear edge.
`scad/hdd.scad` is the reference drive and `scad/sata_plugs.scad` the mated
cable plugs used for the rear cutout check.

## Assembly

Step by step with pictures: [docs/assembly.md](docs/assembly.md).

## How it works

- **Drive in caddy.** Two fixed pins on one wall, two pins on 45° cantilever
  fingers on the other. Tilt the drive onto the fixed pins, press the other
  edge down, the fingers flex out and the pins snap into the drive's side
  holes. The fingers are diagonal so their slots print without support; the
  recessed tip gives a fingernail purchase to release.
- **Caddy assembly.** The bezel presses onto tabs on the tray's walls and
  floor, a friction fit; glue is optional.
- **Caddy in bay.** Slide it in until the bezel seats on the bay's front face.
  The top edge of each caddy wall is a leaf spring with a ramped bump. The
  bumps ride under the top plate's solid rim and drop into two slots when
  the caddy seats. The springs stay preloaded, holding the caddy down and the
  bezel tight against the bay. There is no honeycomb on the bump's track, so
  there are no false clicks. To remove, pull by the notch cut into the
  bezel's top edge; there is no handle, so the bezel prints flat. Or push it
  out from behind: the tray's rear corner reaches through the rear panel's
  open SATA corner as a push tab.
- **Bay assembly.** Walls slid onto the rear panel's side tabs; that U
  lowered into the bottom plate; top plate on. Every tab fits its slot
  exactly. The panel's open corner clears the SATA plugs. Glue is
  optional. A set of checks proves the insertion path.
- **Bay to bay.** No extra parts. Every bump stands on its part's honeycomb
  lattice, offset so that the same part turned for the opposite face presents
  an open cell where each bump arrives: plates turned over for stacking,
  walls turned end for end for side by side. Set a bay on top or beside,
  facing the same way, done. Bumps locate, they do not lock: glue them if a
  block must lift as one.
- **Airflow.** Honeycomb through plates, walls, caddy floor and bezel, inside
  solid rims that carry the load.

## Tooling

Needs Docker and a stock `python3` (standard library only). OpenSCAD
(`openscad/openscad:2021.01`) and the preview renderer run in containers.

```sh
scripts/render.sh          # STL + PNG for every part and view -> out/
scripts/assemblies.sh      # coloured 3MF assemblies -> out/assemblies/
scripts/check.sh           # all interference checks; all must PASS
scripts/check.sh quick     # single unit and neighbours only
scripts/check.sh array     # loaded 2x2 combo only (slow, CGAL)
scripts/check.sh acc       # accessories: 2.5" adapter, feet, joiners
scripts/check.sh only a b  # the named checks only
scripts/thin.sh            # no part has material under 0.8 mm (two perimeters)
AXES=z scripts/thin.sh wall  # one part along one axis
scripts/vent.sh            # caddy floor and bay plate honeycombs line up
```

`scripts/check.sh` intersects pairs of bodies and asserts the result is empty
(a face-to-face touch passes, a volume fails), or, for the hold checks, that a
displaced part hits material: tabs shifted in their slots, neighbours shifted
along the bay into the bumps. `scripts/thin.sh` slices every part in its print orientation,
opens each slice by 0.4 mm and fails on whatever the opening removed, unless
it is only the tail of a slice grazing a sharp corner.

GitHub Actions runs `check.sh`, `thin.sh` and `vent.sh` on every push and
pull request, and builds the printable STLs and the 3MF assemblies as
downloadable artifacts. Pushing a `v*` tag publishes both as a GitHub Release
once every check passes. The 3MFs carry one coloured object per part:

| 3MF | Contents |
| --- | --- |
| `assembled_hdd35.3mf` | bay, caddy and 3.5" drive, seated |
| `assembled_hdd25.3mf` | bay, caddy, 2.5" adapter and 2.5" drive, seated |
| `bay.3mf` | the bay alone: plates, walls, rear panel |
| `caddy_hdd35.3mf` | tray, bezel and 3.5" drive |
| `caddy_hdd25.3mf` | tray, bezel, 2.5" adapter and 2.5" drive |

## Layout

```text
scad/       params.scad lib.scad hdd.scad hdd25.scad sata_plugs.scad              shared model
            caddy.scad bay.scad accessories.scad
            caddy_tray.scad bezel.scad plate.scad wall.scad rear.scad coupon.scad  printable parts
            adapter25.scad foot.scad joiner.scad
            testfit.scad assembly.scad joining.scad steps.scad accessory_views.scad   views
            checks.scad thin.scad vent.scad                                        verification
scripts/    render.sh assemblies.sh check.sh thin.sh vent.sh
            preview.py color_mesh.py stl_components.py stl_bbox.py
docs/       design.md adr/ img/
out/        build output (ignored)
```

## License

[MIT](LICENSE)
