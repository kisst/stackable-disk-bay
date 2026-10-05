# 0002 — Drive is held by pins on 45° cantilever fingers

## Context

The drive must drop into the caddy with no screws. Pins in the SFF-8301 side
holes are the natural toolless interface; something has to move about 2 mm
to let the second pair of pins in. The tray must print flat with no support.

## Options

1. Flex the whole +y wall outward (thin wall, anchored only at the floor).
2. Vertical tabs rooted at the floor carrying the pins.
3. Horizontal cantilever fingers cut into the wall, pin at the free end.
4. Cantilever fingers hanging at 45° from the wall's top rim.

## Decision

Option 4. Option 1 makes the wall too soft to guide the caddy, and a short
vertical tab (option 2) is strained past PLA's yield. A horizontal finger
(option 3) has two horizontal slot faces: printed flat, its first layer
floats over the lower slot, a 40 mm unsupported span inside a 1.2 mm gap
where support can be neither placed nor removed. Only a slot that climbs
along its length at 45° or more prints clean.

- Fingers hang from the wall's top rim at 45° down to the pin, 6 mm wide,
  1.6 mm thick (outer face recessed), 1.2 mm slots. Every slot face is a 45°
  overhang. The detent finger is the same shape.
- The wall is 25 mm above the floor to give the finger about 18 mm of
  length; pin engagement is 1.8 mm, so the deflection is about 2.3 mm and
  root strain about 1.5 %. Conical pin tips cam the fingers open as the
  drive is pressed down.
- The rim above a finger is measured from the slot ring's root corner, 3 mm
  above the beam's centreline, and the beam's lowest corner is cut flat
  1.6 mm wide, so no slice of the wall is thinner than two perimeters.
- The wall carries the bay wall's 6 mm honeycomb, phased to it, so the side
  vents stay open.

## Consequences

- No support anywhere in the caddy tray; the recessed outer face gives a
  fingernail purchase to release.
- The +y wall is weaker than the −y wall; the bezel and floor frame provide
  the tray's stiffness.
- The drive is retained by pin engagement, not clamping, as in metal
  caddies.
- 1.5 % strain is comfortable in PETG and acceptable in PLA, worth
  confirming with the coupon.
