// Views of the accessories in use. `mode` picks the scene, `part` one class
// for a per-colour export.
include <params.scad>
use <hdd25.scad>
use <sata_plugs.scad>
use <caddy.scad>
use <bay.scad>
use <accessories.scad>

mode = "adapter";
part = "";
function on(p) = part == "" || part == p;
lift = 25;

// 2.5" drive in the adapter in the caddy, the drive lifted out
if (mode == "adapter") {
    if (on("trays"))    caddy_tray();
    if (on("adapters")) adapter25();
    if (on("hdds"))     translate([0, 0, lift]) hdd25();
}
// seated: drive in the adapter in the caddy in the bay, with the cable plugs
if (mode == "adapter_seated") {
    if (on("bays"))     bay(top = false);
    if (on("trays"))    caddy_tray(spring_defl = sp_preload);
    if (on("adapters")) adapter25();
    if (on("hdds"))     hdd25();
    if (on("plugs"))    sata_plugs(h25_dy);
}
// four feet under a bay, lowered away
if (mode == "feet") {
    if (on("bays"))  bay();
    if (on("feet"))  for (c = foot_cells) translate([0, 0, -lift]) foot_placed(c);
}
// two layers of two bays with a 0.5 + 1 + 0.5 width joiner between them,
// exploded upward
if (mode == "joiners_w") {
    for (i = [0, 1]) translate([0, i * pitch_y, 0]) {
        if (on("bays")) bay();
        if (on("bays2")) translate([0, 0, pitch_z + jn_t + 2 * lift]) bay();
    }
    translate([0, 0, lift]) {
        if (on("j05")) joiner_w_at(1, -b_w / 2, lock_lo = false);
        if (on("j1"))  joiner_w_at(2, 0);
        if (on("j05")) joiner_w_at(1, b_w, lock_lo = false, turned = true);
    }
}
