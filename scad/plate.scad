// Bay plate (flat, bumps up). Two prints per bay: one with kind = "top"
// and one with kind = "bottom". The top carries six slots (four for the rear
// panel, two for the caddy lock), the bottom two (the rear panel's, mirrored).
include <params.scad>
use <bay.scad>
kind = "top";
plate(kind);
