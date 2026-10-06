#!/usr/bin/env python3
"""Merge per-part STLs into one coloured model. Dependency-free.
STL has no standard colour, so two files are written:
  <out>.3mf  one object per part, each with its own colour (slicers, viewers)
  <out>.stl  one binary STL with per-facet colour in the attribute bytes
             (the VisCAM/SolidView convention: bit 15 set, 5-bit RGB)
  color_mesh.py out/name part.stl::#rrggbb [part.stl::#rrggbb ...]"""
import os, struct, sys, zipfile
sys.path.insert(0, os.path.dirname(__file__))
from stl_components import read_stl

def rgb(h):
    h = h.lstrip("#"); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def write_stl(path, parts):
    n = sum(len(t) for _, t, _ in parts)
    with open(path, "wb") as f:
        f.write(b"coloured assembly, VisCAM facet colours".ljust(80, b" "))
        f.write(struct.pack("<I", n))
        for _, tris, col in parts:
            r, g, b = (c >> 3 for c in rgb(col))
            attr = 0x8000 | (r << 10) | (g << 5) | b
            for a, b_, c in tris:
                u = [b_[i] - a[i] for i in range(3)]; v = [c[i] - a[i] for i in range(3)]
                nx, ny, nz = u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]
                l = (nx*nx + ny*ny + nz*nz) ** 0.5 or 1
                f.write(struct.pack("<12fH", nx/l, ny/l, nz/l, *a, *b_, *c, attr))

def write_3mf(path, parts):
    objs, items = [], []
    mats = "".join(f'<base name="{n}" displaycolor="{c.upper()}FF"/>' for n, _, c in parts)
    for i, (name, tris, _) in enumerate(parts):
        idx, verts = {}, []
        for t in tris:
            for p in t:
                if p not in idx: idx[p] = len(verts); verts.append(p)
        vs = "".join(f'<vertex x="{x}" y="{y}" z="{z}"/>' for x, y, z in verts)
        ts = "".join(f'<triangle v1="{idx[a]}" v2="{idx[b]}" v3="{idx[c]}"/>' for a, b, c in tris
                     if len({idx[a], idx[b], idx[c]}) == 3)
        objs.append(f'<object id="{i+2}" name="{name}" type="model" pid="1" pindex="{i}">'
                    f'<mesh><vertices>{vs}</vertices><triangles>{ts}</triangles></mesh></object>')
        items.append(f'<item objectid="{i+2}"/>')
    model = ('<?xml version="1.0" encoding="UTF-8"?>'
             '<model unit="millimeter" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">'
             f'<resources><basematerials id="1">{mats}</basematerials>{"".join(objs)}</resources>'
             f'<build>{"".join(items)}</build></model>')
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml",
            '<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/></Types>')
        z.writestr("_rels/.rels",
            '<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
        z.writestr("3D/3dmodel.model", model)

if __name__ == "__main__":
    out, specs = sys.argv[1], sys.argv[2:]
    parts = []
    for s in specs:
        p, col = s.split("::")
        parts.append((os.path.splitext(os.path.basename(p))[0], read_stl(p), col))
    write_stl(out + ".stl", parts); write_3mf(out + ".3mf", parts)
    print(out, sum(len(t) for _, t, _ in parts), "facets,", len(parts), "parts")
