# Arrow pin (45° up-right) — Icon Composer assets

White pin tilted 45° up-right with the bike wheel cut clean through. The red plate (set in Icon Composer) shows through the wheel cutout; the 4 spokes and hub are white "bridges" across the hole.

Source: `design-2/icon-30-arrow-pin-45-up-right.svg`. Canvas: 1024×1024, transparent. The pin is rotated -135° around (512, 395), then the whole composition is shifted down by 170px so the visual centroid sits near the canvas center.

## Files

| File | Use | Notes |
| --- | --- | --- |
| `pin-wheel.svg` | **Single-file import** | One SVG with three groups (`#pin`, `#spokes`, `#hub`). Rotation + shift baked into the pin's transform; spokes / hub coordinates are baked. |
| `layer-1-pin.svg` | Layer 1 — back | White pin (rotated, with wheel cutout) |
| `layer-2-spokes.svg` | Layer 2 | 4 white spokes (vertical, horizontal, two diagonals) |
| `layer-3-hub.svg` | Layer 3 — front | White centre hub at (512, 565) |
| `combined.svg` | Reference | Same as `pin-wheel.svg` with explicit `layer-N-…` ids |
| `preview-with-plate.svg` | **Visual reference only** | Renders on a red rounded plate so you can see the final look. Do not import. |

## Import

**Single SVG (recommended):** drop `pin-wheel.svg` onto the Icon Composer canvas, expand it in the Layers panel, then assign each `<g>` to depth groups 1–3 from back to front.

**Per layer:** drop `layer-1-pin.svg`, `layer-2-spokes.svg`, `layer-3-hub.svg` in order; each lands as its own item.

## Plate colour

Set the icon **Background** in Icon Composer to `#E11D2A` (BIXI red). Don't include a manual rounded plate in the SVG — Icon Composer applies its own shape mask.

## Liquid Glass tuning

- Pin (back): full opacity, optional subtle blur for "glass body" feel.
- Spokes / hub (front): keep crisp; small specular highlight reads nicely.
- Refraction: subtle. Strong refraction smudges the wheel detail.

Verify Default / Dark / Clear / Tinted modes in the IC preview.

## Geometry

- Wheel centre (after shift): (512, 565)
- Wheel cutout radius: 140
- Spoke stroke: 22 (rounded caps)
- Hub radius: 34
- Pin rotation: -135° around (512, 395) before vertical shift
- Vertical shift: +170px

## Colours

- Pin / spokes / hub: `#FFFFFF`
- Plate (set in Icon Composer): `#E11D2A`
