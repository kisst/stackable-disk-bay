# Task 7 report: hdd (3.5" drive + SATA tongue)

Driver: `python3 -I solidcraft/gen_full.py hdd solidcraft/hdd.json`, then solidcraft-cli run --save hdd.sc --out hdd.got.stl.

- Oracle (`oracle.sh hdd 35`): vol 385632.363, bbox [0,-50.8,2.0]..[147,50.8,28.1].
- verify.py: MATCH vol delta -0.001% (385628.6 vs 385632.4), bbox delta 0.000 mm.
- probe.py z = 4, 5, 8.35, 20, 28 (1 mm grid, full extent): all PROBE-MATCH, differing 0.
- Tongue edge: y-edges measured at x=3, z=5.4 (0.01 mm scan): 37.365 (outer edge, sata_y0 = 37.37), 26.965 (signal inner), 24.565 (power start), 3.975..2.475 etc. Outer edge sits at sata_y0 (within 0.005 mm).
- Pocket depth: first solid at x=6.505 at z=8 (pocket depth 6.5 == sata_pocket_d). Tongue spans x 0.305..6.305.
- Grooves: OMITTED (goldenrod, 0.1 mm colour-only features); volume delta -0.001%.
- Construction: filleted-rectangle sketches (sketch.line + 4 sketch.fillet, r=2.54) extruded twice; holes as solid.cylinder cuts (side axis -s*y, bottom axis +z); pocket box cut; tongue blades + feet as box joins (tongue joins the body in one body; no issues). Params hand-copied.
- Deviations: none.
