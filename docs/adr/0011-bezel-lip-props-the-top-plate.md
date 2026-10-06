# 0011 — A lip on the bezel props the top plate

## Context

The top plate is held along its side edges by the wall tabs. Its front
edge spans the 108 mm between the walls with nothing under it, and can be
pushed down there. The bezel already sits against that edge when the
caddy is seated.

## Decision

- A lip on the bezel's back face, at the top: 2 mm deep, 1.4 mm thick,
  3.5 lattice pitches (27.3 mm) long, from y −26.1 to 1.2. That is the
  middle, where the plate sags most; it sits on the fixed-pin side and
  clear of the finger notch. Seated, it sits under the top plate's solid
  front rim, its top 0.2 mm under the plate's underside. A first
  version ran 54.6 mm out to the −y wall; near the wall it did little, so
  it was halved to the middle.
- A 0.5 mm chamfer on its rear top edge, so a plate that has sagged rides
  up onto it as the caddy goes home.
- Kept minimal, and on the fixed-pin side. It reaches 1.5 mm over the
  drive's front edge with 0.3 mm above a 26.1 mm drive. The drive goes in
  fixed-pin edge first, already low under the lip, and the bezel flexes
  as the other edge is pressed down.
- Near the edges the caddy walls prop the plate. Over their last 8 mm at
  the bezel end they rise from 27 mm to 29.8 mm, 0.2 mm under the plate's
  underside, with a 45° ramp behind.
- Lip and posts stop 0.2 mm under the plate rather than flush. A plate
  sagging that far rests on them; a bay printed a little short does not
  make them bind before the lock bump reaches its slot.

## Consequences

- The bezel print stands 4 mm tall: the plate and the lip standing up
  from its back face. Still no support.
- The drive's way into a caddy with its bezel on is no longer free. It
  relies on the 0.5 mm front gap and on the bezel flexing. No check covers
  that path; it is a question for the next print.
- Between the lip and the +y wall post, by the finger notch, the plate's
  front edge is still unsupported for about 50 mm.
- The posts sit at the caddy's front end, so they only reach the bay over
  the last 11 mm of travel (ramp and flat), where they slide under the plate
  with 0.2 mm to spare.
- Checks: `bezel_lip_holds`, `posts_hold`, `path_bezel_lip`.
