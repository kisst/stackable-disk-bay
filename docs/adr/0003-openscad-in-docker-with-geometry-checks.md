# 0003 — OpenSCAD in Docker, with boolean interference checks as the test suite

## Context

Nothing beyond Docker should be needed on the host to build or verify the
model. The design has several mating interfaces whose fit is easy to
get wrong by a tenth of a millimetre and hard to see in a render.

## Decision

- Model in OpenSCAD, all dimensions in one `params.scad`, one shared
  coordinate frame for every part.
- Run OpenSCAD from the official image via `scripts/render.sh`. The image
  has no working offscreen GL, so previews are shaded from the STL by a
  small matplotlib script in a throwaway python container.
- Treat fit as testable: `scad/checks.scad` exports the intersection of
  pairs of bodies and `scripts/check.sh` asserts empty (or held, for the
  capture checks). OpenSCAD writes no file for an empty result and exits 1,
  so the script clears old outputs first and reads "no file" as "no overlap"
  only when the log says the result was empty and holds no error.
- A zero-thickness intersection (two faces touching) is a pass; only a
  volume fails.

## Consequences

- Any change to a mating dimension is caught before a print.
- Renders take ~30 s per part in CGAL; the full check suite runs in CI on
  every push.
