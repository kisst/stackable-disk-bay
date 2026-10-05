// Bay plate (flat, bumps up). Two prints per bay: one with kind = "top"
// (arrow) and one with kind = "bottom" (arrow over a bar). Same geometry.
include <params.scad>
use <bay.scad>
kind = "top";
plate(kind);
