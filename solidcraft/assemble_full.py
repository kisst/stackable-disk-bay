#!/usr/bin/env python3
"""Assemble the full bay in ONE SolidCraft script.  Every part emitter in
gen_full.py already builds its part in the assembled (shared) frame, so
assembly is just emitting them into one design, each as its own component.

Usage: assemble_full.py <stage> <out.json>
  stage: shell | rear | caddy | full  (each stage includes the previous ones)"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_full as g

STAGES = ["shell", "rear", "caddy", "full"]


def assemble(stage):
    lvl = STAGES.index(stage)
    info = {}
    info["plate_top"] = g.emit_plate("top")
    info["plate_bottom"] = g.emit_plate("bottom")
    info["wall_l"] = g.emit_wall("l")
    info["wall_r"] = g.emit_wall("r")
    if lvl >= 1:
        info["rear"] = g.emit_rear()
    # every emitter re-declares the shared parameters; keep the first of each
    seen, out = set(), []
    for c in g.cmds:
        if c["command"] == "parameters.add":
            if c["params"]["name"] in seen:
                continue
            seen.add(c["params"]["name"])
        out.append(c)
    g.cmds[:] = out
    return info


if __name__ == "__main__":
    info = assemble(sys.argv[1])
    g.dump(sys.argv[2])
    print(info, len(g.cmds))
