# App icon iterations — design-2

Fresh directions after the first batch in `design/` felt too busy (radar + bike combo) and too muted (cream/ink). These lean bolder, more reductive, and more colourful, plus a Liquid Glass-ready set for Apple Icon Composer (iOS 26).

Open `index.html` to browse everything.

## Iterations on favourites (01, 04, 14)

Riffs on the picks: recolours, density variations, hybrids that combine the pin shape with the V mark, and Liquid Glass-ready layered versions of the new hybrids.

17. `icon-17-pin-wheel-cobalt.svg` — pin+wheel from 01 in cobalt blue.
18. `icon-18-pin-wheel-detail-amber.svg` — denser wheel (rim + 4-spoke + larger hub) on amber over charcoal.
19. `icon-19-V-wheel-cobalt.svg` — V mark from 04 on cobalt.
20. `icon-20-V-wheel-amber-charcoal.svg` — amber V on charcoal, glowy mono palette.
21. `icon-21-V-double-wheel-bike.svg` — inverted V where each leg lands in a wheel — geometry reads as a stylised bike.
22. `icon-22-pin-chevron-red.svg` — pin (01) with a chevron + dot cutout instead of a wheel; navigation/direction read.
23. `icon-23-V-pin-apex.svg` — V (04) with a pin shape replacing the apex circle; doubles the location cue.
24. `icon-24-lg-pin-chevron.svg` — LG-layered version of 22 (pin / chevron / dot as separate `<g>`s).
25. `icon-25-lg-V-double-wheel.svg` — LG-layered version of 21 (frame / wheels / hubs as separate `<g>`s, three-colour layering for depth).

## Map pin cutouts

1. `icon-01-pin-wheel-red.svg` — vivid red pin, white wheel + spokes cutout.
2. `icon-02-pin-bike-blue.svg` — electric blue pin, white side-profile bike cutout.
3. `icon-03-pin-arrow-yellow.svg` — sunny yellow pin, dark navigation arrow cutout.

## Typographic marks

4. `icon-04-mark-V-velo.svg` — bold white V on red, wheel as the apex.
5. `icon-05-mark-B-cobalt.svg` — geometric B on cobalt blue.
6. `icon-06-mark-BX-mono.svg` — chunky BX on charcoal, off-white.

## Side-profile bike

7. `icon-07-bike-flat-red.svg` — clean white bike on BIXI red.
8. `icon-08-bike-flat-night.svg` — yellow bike on deep navy.
9. `icon-09-bike-gradient-sun.svg` — white bike on orange→pink gradient.

## Mixed bold

10. `icon-10-ping-pulse-azure.svg` — Apple-Maps-style concentric ping on azure.
11. `icon-11-bike-iso-shadow.svg` — flat bike with cast shadow on vivid teal.
12. `icon-12-mtl-tricolore.svg` — wheel on a half red / half blue split.

## Liquid Glass-ready (Icon Composer / iOS 26)

These follow Apple's Liquid Glass authoring guidance: transparent canvas, distinct layered groups (each color or depth lives in its own `<g id="…">`), rounded caps/joins on all strokes, and no manual rounded corner masks. Import the SVG into Icon Composer and assign each group to a depth group — the system applies the glass material, specular highlights, refraction, and Default / Dark / Clear / Tinted modes automatically.

13. `icon-13-lg-bike-stroke.svg` — bike on transparent bg, frame / wheels / hubs as 3 layered groups.
14. `icon-14-lg-pin-cutout.svg` — red pin (back layer) + white wheel ring / spokes / hub layered on top.
15. `icon-15-lg-pulse-rings.svg` — three concentric rings (varying depth/opacity) + center dot, ideal for refraction.
16. `icon-16-lg-V-wheel.svg` — V stroke (red) + wheel circle (blue) + hub (white) as three depth layers.

## Notes

- 1024×1024 canvas, no embedded text on the LG variants (typographic marks 04–06 use SVG path geometry already, no `<text>`).
- LG variants are designed for layer-by-layer assignment in Icon Composer; do not flatten them before import.
- Solid-background variants (01–12) are for evaluation as flat marks first; they can be re-cut into LG layers once a direction is chosen.
- No official BIXI wordmark or logo is used.
