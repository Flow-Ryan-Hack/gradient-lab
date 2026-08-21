# Gradient Lab

A generator for smooth mesh gradients with film grain — exports as image
and video. No build step, no dependencies, nothing to install.

Two pages, one codebase:

| File | Route | What it is |
|---|---|---|
| `index.html` | `/` | The showcase and the entry point — ready-made 1080 × 1350 posts you can page through and save. |
| `editor.html` | `/editor` | The editor. Opens straight into the canvas, no landing page. |

Live at [flohack.com/gradientlab](https://flohack.com/gradientlab), the
editor at `/gradientlab/editor`.

`Open editor` in the showcase hands the current palette to the editor
through `localStorage`; `showcase` in the editor footer goes back. Both
links work out the other page from `location.pathname`, so they hold up on
the pretty routes, on the bare `.html` files and on a local disk copy alike.

**`editor.html` is the file you edit.** `index.html` is generated from it —
they differ only in one flag and the title. After changing `editor.html`,
run `./build-showcase.sh` to regenerate the showcase.

## Why the gradients look clean

- **Blended in OKLab**, not sRGB. Two colours mix along perceived
  lightness rather than raw numbers — no grey mud in the middle, no dead
  zones between complementary colours.
- **Gaussian weights** per colour point. No hard stop edges; the
  transition is continuous everywhere.
- **Dither before quantisation** (triangular, 1 LSB). This is why dark
  gradients show no banding.
- **Domain warp** through simplex noise for the organic distortion.

## Showcase

`index.html` — the public entry point — is a slider of ready-made
**1080 × 1350** posts — the
gradient in each one is live, not a still. `Save post` writes the current
slide to PNG at full size.

Seven slides, starting with the two brand palettes: **flohack**
(chalk / acid / steel / ink) and **accilium** (mint / petrol / berry /
deep), followed by Ceramic, Signal, Tidal, Neon Dusk and Kiln. Both brand
palettes are in the editor's palette list, and so are the Signal, Neon Dusk
and Kiln colour sets.

All seven share one form — the *sunrise* look, laid out as stacked bands —
so the palettes can be compared without the shape shifting underneath.
Colour comes from each card's own list; the ground carries no weight at all
(`baseW` 0), so the four palette colours make the whole picture and the
accent reads as an accent. The movement is kept slight on purpose, since
these are backgrounds, not animations.

The post layout stays deliberately colourless — no accent, no highlight —
so nothing competes with the gradient itself.

### Animated export

Each card can be exported as an animated clip of the whole post, not just
the gradient:

| Button | Output |
|---|---|
| `Save PNG` | Still, 1080 × 1350 |
| `Video` | WebM/MP4 of the current card, exactly one loop |
| `GIF` | Looping GIF, width selectable (360 / 540 / 720) |
| `Export all cards` | Both formats for every card in turn |

Length is 6, 10 or 15 seconds; the animation loop is set to match, so the
clip is seamless.

The GIF encoder is written from scratch here — median-cut palette, 8×8
ordered dither, LZW — so there is no dependency. One global colour table
serves every frame, otherwise the animation flickers. Grain is frozen for
GIF export: moving grain destroys frame-to-frame redundancy and multiplies
the file size. Reckon with roughly **2.5 MB and ~40 s of encoding** for
10 s at 540 px wide.

**Video capture needs the tab in the foreground.** A hidden tab starves
both `requestAnimationFrame` and canvas capture, and the clip comes out
unplayable. The export refuses to start on a hidden tab and warns if a
finished clip came out thin. GIF export is unaffected — it does not rely
on real-time capture.

## Interface

Built in the flohack CI: light gradient ground, monospace throughout,
lowercase, neon only as an accent. Seven sections, nothing more:

| Section | Holds |
|---|---|
| look | 13 look presets, 20 palettes |
| colours | ground colour and the individual points |
| form | mode, spread, stretch, focus, warp |
| finish | grain, motion, tone |
| image | a photo, its blend mode, the layer opacities, the tint |
| layer | the effect over the finished image |
| export | format, files, code |

All seven start collapsed — the canvas gets the screen, and the panel is
opened where it is needed. The **essentials / everything** switch decides
how much is inside: 15 sliders or 40. Everything stays reachable, it just
is not all shown at once.

## Looks

Thirteen complete setups for backgrounds. A look sets colours, shape, grain
and motion in one go — format, corners and aspect ratio stay untouched,
so the same look fits any canvas size.

| Look | For |
|---|---|
| horizon | Light edge below, deep black above — product key visuals |
| fog bank | Soft diagonal with warm haze, heavy grain |
| aurora | Flowing light bands over night blue |
| sunrise | Warm layers, soft transition |
| paper | Almost white, barely there — for light layouts |
| spotlight | A single cone in the dark |
| heat map | Thermal blobs — red core, green ring, cold edge |
| greydient | Japanese fade, crow black to dough, heavy grain |
| poster dusk | Violet field cut by a razor-thin hot horizon |
| riso jet | Jet colours, heavy warp, hard posterise steps |
| ridge light | Grainy ridges — alpine dusk |
| ember sweep | Wide turned ovals, ember over teal |
| ice fold | One cold fold with a lit glass edge |

The last seven come from reference sheets — thermal maps, the Nuevo Tokyo
greydients, a Takasaki poster, riso prints. They lean on the ellipse rather
than on more colours, and they are the ones to open when you want to see what
`stretch`, `rotation`, `pulse` and `oval turn` actually do.

Twenty **palettes** — flohack and accilium first, then horizon,
fog & almond, matcha roast, crimson sand, cobalt ink, paper, the three
that come straight out of the showcase (signal, neon dusk, kiln), and nine
from the same reference sheets: heat map, japanese, greydient, poster dusk,
iridescent, riso jet, alpine dusk, ember teal, ice fold. Keys `1`–`9`
reach the first nine, the rest are a click. A palette swaps colours only
and leaves the points in place, so any look can be run through every colour
world.

## Shape

A point is an ellipse, not a disc, and that is where most of the form comes
from:

| Control | Where | Effect |
|---|---|---|
| `stretch` | form | Global multiplier on every point's ellipse — one slider from round to band |
| `Stretch` | colour row | That point alone, 0.25 to 12. Above 1 wide, below 1 tall, area stays the same |
| `Rotation` | colour row | Which way the stretch points |
| `pulse` | finish | The ellipses breathe between round and stretched over the loop |
| `oval turn` | finish | The ellipses turn, in whole revolutions so the loop still closes |

A very wide, very tightly bounded point is a horizon line — that is the whole
trick behind *poster dusk*. Stacked points sharing one centre give rings, as
in *heat map*, but only if the inner colour carries clearly more `Strength`:
at the centre every disc is at full weight, so the ring order comes from
strength, not from reach.

The ellipse lives in Mesh mode. The 1D modes project onto their axis, where a
point has no width of its own — `stretch`, `pulse` and `oval turn` do nothing
there.

## Every point on its own

The arrow in a colour row opens what sets that point apart:

| Control | Effect |
|---|---|
| Position X / Y | Also outside the canvas (−0.3 to 1.3) — that is where edge falloffs come from |
| Stretch | Ellipse: wide or tall, 1 is round, up to 12. Area-preserving |
| Rotation | Direction of the stretch |
| Edge | Low = far-reaching haze, high = clearly bounded |
| Strength | How strongly this colour asserts itself against the others |

That is how one colour reaches far while its neighbour stays a tight
spot, without touching the global focus.

## All points, or just one

`form` and `finish` hold the global sliders; the switch above them decides
what those sliders aim at.

| Scope | The sliders write |
|---|---|
| `all points` | the global value, as before |
| `point n` | the selected point's own factor |

Click a point on the canvas or its colour row to select it — the handle
takes a neon ring, and the switch shows its number and colour.

Three buttons sit under the switch:

| Button | What it does |
|---|---|
| `shuffle all` | Rolls the whole set: colours, points, form, grain, tone, motion and every point's own factors. Format, corners and aspect ratio stay put — canvas size is not a matter of taste. Rotation is held to whole turns so the loop still closes. |
| `reset` | Back to the defaults, the four starting points included |
| `remove point` | Drops the selected point. `Backspace` does the same, and the `×` in the colour row still works. |

This is not a second set of parameters. `spread` and `focus` were always
multipliers on a point's own reach and edge, so in point scope the same
slider simply addresses the local value:

| Slider | Per point |
|---|---|
| `spread` | that point's reach |
| `focus` | that point's edge |
| `warp` | how much of the shared distortion the point takes along — 1 is all of it |
| `stretch` | that point's ellipse |
| `drift` · `breathing` · `rotation` | the point's share of the global motion |

`pulse` and `oval turn` stay global, but they are scaled per point by the
`breathing` and `rotation` shares — one point can pulse while its neighbour
holds still.

The rows without a per-point counterpart go grey instead of pretending.
`mode`, `angle`, the wave and warp-field settings and the loop duration
describe the field that every point shares; `grain`, `vignette`,
`contrast`, `brightness`, `saturation` and `posterise` run after the blend,
on the finished pixel, where single points no longer exist.

Point scope and the arrow in a colour row reach the same values from two
sides — reach and edge stay in step whichever one you move.

## Recipes

**Wide light edge**: put a point well below the bottom of the canvas
(Y ≈ 1.25) with a large reach and a low edge — that fills the lower half.
Above it a second point with a small reach and stretch ≈ 5 gives the
narrow bright seam. Keep the background weight low, or it pulls
everything grey.

**Soft diagonal with a glow**: one large bright point in a corner,
stretch ≈ 2.5 and rotation ≈ 35°, plus a smaller warm one in the opposite
corner. Keep distortion low — the edge should stay calm — and push the
grain. The grain makes this look, not the gradient.

**Bands**: several points at stretch 3+ with slightly different
rotations, stacked. For a swirl use the *Conic* mode instead — though it
carries a singularity at the centre.

## Modes

| Mode | What the point controls |
|---|---|
| Mesh | Free 2D position, blobs |
| Linear | Projection onto the angle axis |
| Radial | Distance from centre |
| Conic | Angle around the centre |
| Waves | Linear plus a cross wave |
| Spiral | Angle plus radius |

In every mode the point position places the colour within the gradient,
and the slider next to it sets its reach.

## Motion

All movement runs on integer multiples of the loop frequency, and the
warp field is sampled along a closed circular path. After the set loop
duration the image is back exactly where it started — a seamless loop
with no visible cut.

## Image, ground and tint

`image` turns the canvas into a small layer stack. From the bottom:

| Layer | Controls |
|---|---|
| ground | The `colours` ground colour, now also a real backdrop |
| gradient | `gradient` — its opacity over the ground |
| photo | file, `cover` / `contain` / `fill`, zoom, shift, blend mode, `photo` opacity |
| tint | a flat colour with its own blend mode and `tint amount` |

Then tone, then the effect layer, then the grain. Tone runs **after** the
stack on purpose: contrast, saturation, vignette and posterise grade the whole
picture, the photo included.

Drop an image anywhere on the canvas, or use `load photo`. Oversized files are
scaled down to the GPU's texture limit first, so a phone shot works. Seven
blend modes — normal, multiply, screen, overlay, soft light, difference,
luminosity — following the W3C compositing formulas, on straight sRGB.

Two things fall out of this that are worth knowing:

- **A flat colour**: pull `gradient` to 0 and the canvas is the ground colour,
  full stop. No separate mode needed — and it is still a full export target,
  grain and effect layer included.
- **The effect layer runs over the photo**, because the stack is built before
  the effect. That is the point: a dithered, rastered or ASCII-rendered
  photograph, in the photo's own colours.

The photo lives in the browser session. A preset, a `.json` or `localStorage`
keeps every setting — fit, blend, opacities, tint — but not the pixels; a
few megabytes of Base64 in a preset file would be the wrong trade. After a
reload the values are there and the image has to be dropped again.

## Effect layer

`layer` puts one effect over the finished image — after the blend and the
tone, under the grain. Six of them, plus `none`:

| Effect | What it does | Uses |
|---|---|---|
| dither | Ordered 8×8 Bayer matrix per channel | cell · steps · amount |
| ascii | One glyph per cell, picked by brightness, lit in the cell's own hue | cell · amount |
| halftone | Dot screen, the dot grows with brightness | cell · angle · amount |
| crosshatch | Line screen, one layer per darkness step | cell · angle · amount |
| pixelate | Cell colour, quantised to steps | cell · steps · amount |
| rgb split | The channels part along the angle — riso misregistration | cell · angle · amount |

Only the sliders an effect actually reads stay lit; the others go grey.
`amount` mixes back towards the untouched image, so every effect can be
dialled in rather than switched on.

Cell size is given in render pixels and scales with the export factor, the
same way the grain does — an effect looks the same in the preview and in a
4× PNG. The cell effects sample the gradient at the cell centre, not at the
pixel, so a cell carries one colour instead of a smear.

The layer is a shader stage. It comes out in every image and video export,
and it cannot come out in the CSS or SVG export — those write a note saying
so instead of quietly dropping it.

## Export

- **PNG / JPG / WebP** up to 4× the target resolution (the GPU limit is
  checked)
- **Video** as MP4 (H.264) or WebM, exactly one loop, frame rate and
  bitrate adjustable. Keep the tab in front while recording — in the
  background the browser throttles the frame rate and the clip drops
  frames.
- **CSS** and **SVG** as approximations without distortion, for web
  backgrounds that should not load an image
- **JSON** to save and share a complete setup

Custom presets live in the browser's `localStorage`, project files sit
next to it as `.json`.

## Keys

`Space` play/pause · `R` random · `E` PNG · `1`–`9` palette ·
`⌫` remove the selected point · `←` `→` slider · `Enter` open editor

## Limits

- Video export needs `MediaRecorder`. Safari does MP4, Chrome does WebM
  depending on version; the dropdown only lists what the browser
  actually supports.
- Clip duration follows the wall clock, not a fixed frame counter —
  `MediaRecorder` stamps every frame by real time. Under load individual
  frames drop, but length and loop point stay correct.
- Maximum 8 colour points (uniform limit in the shader).
- CSS cannot express rotated ellipses — the CSS export drops the
  rotation and says so in a comment. SVG can, via `gradientTransform`.
- *Conic* and *Spiral* carry a singularity at the centre by nature. For
  calm bands use Mesh with stretched points instead.
- The effect layer has no CSS or SVG equivalent — export as an image or a
  video if the effect has to travel. The same goes for the photo and the
  tint; both exports write a comment saying what is missing.
- No transparent PNG yet. The stack always composites over the ground
  colour, and the WebGL context runs without an alpha channel on purpose.
- `rotation` closes the loop only at whole turns — at 0.5 the points end up
  half a revolution on when the clip restarts. That already applied to the
  global slider; a point's own share multiplies it.
- Hosting note: some sandboxed embeds block script-initiated downloads,
  which disables every export button. Serve the files from a normal
  origin — local file, or any static host — for the exports to work.

---

[flohack.com](https://flohack.com) · [github.com/Flow-Ryan-Hack](https://github.com/Flow-Ryan-Hack)
