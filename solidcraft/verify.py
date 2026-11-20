#!/usr/bin/env python3
"""Compare a SolidCraft body to an oracle STL.

Usage: verify.py <design.sc | script.json | eval.json> <part_name> <oracle.stl>

The first argument is either a design/script (evaluated with solidcraft-cli
eval) or an already-saved eval JSON (an object with a "bodies" list).  The
body called <part_name> is compared with the STL: volume within 2 %, every
bbox coordinate within 0.2 mm.  Prints MATCH or MISMATCH; exit 0 / 1."""
import json, os, subprocess, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stl_stats import stats  # noqa: E402

VOL_TOL = 0.02
BBOX_TOL = 0.2


def load_eval(path):
    with open(path, "rb") as f:
        head = f.read(2)
    if head != b"PK":  # not a .sc zip: maybe a saved eval JSON
        try:
            with open(path) as f:
                doc = json.load(f)
            if isinstance(doc, dict) and "bodies" in doc:
                return doc
        except ValueError:
            pass
    d = os.path.dirname(os.path.abspath(path))
    out = subprocess.run(
        ["flatpak", "run", f"--filesystem={d}", "--command=solidcraft-cli",
         "io.tangencylabs.solidcraft", "eval", os.path.abspath(path)],
        capture_output=True, text=True)
    if out.returncode != 0:
        sys.exit(f"eval failed: {out.stderr.strip()[:500]}")
    return json.loads(out.stdout)


def main(argv):
    if len(argv) != 4:
        sys.exit(__doc__)
    doc, name, stl = load_eval(argv[1]), argv[2], argv[3]
    body = next((b for b in doc["bodies"] if b["name"] == name), None)
    if body is None:
        print(f"MISMATCH no body {name!r}; have {[b['name'] for b in doc['bodies']]}")
        return 1
    ref = stats(stl)
    vol, rvol = body["volume_mm3"], ref["volume_mm3"]
    dv = (vol - rvol) / rvol if rvol else float("inf")
    bb = body["bbox"]
    got = list(bb["min"]) + list(bb["max"])
    db = max(abs(a - b) for a, b in zip(got, ref["bbox"]))
    ok = abs(dv) <= VOL_TOL and db <= BBOX_TOL and ref["open_edges"] == 0
    print(f"{'MATCH' if ok else 'MISMATCH'} vol Δ={dv:+.3%} ({vol:.1f} vs {rvol:.1f}) "
          f"bbox Δ={db:.3f}mm" + ("" if ref["open_edges"] == 0 else
                                   f" (oracle STL has {ref['open_edges']} open edges)"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
