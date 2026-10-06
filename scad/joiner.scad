// Joiner plate (print flat). kind = "w1" / "w05": between stacked bays, one
// or half a bay wide; "h1" / "h05" / "h3": between bays side by side, one,
// half or three bays high. Half pieces lock on one edge only; turn one round for the other
// end of a run.
include <params.scad>
use <accessories.scad>
kind = "w1";
joiner_part(kind);
