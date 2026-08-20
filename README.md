# Gradient Lab

A generator for smooth mesh gradients with film grain — exports as image
and video. No build step, no dependencies, nothing to install.

Two pages, one codebase:

| File | What it is |
|---|---|
| `index.html` | The editor. Opens straight into the canvas, no landing page. |
| `slider.html` | The showcase — ready-made 1080 × 1350 posts you can page through and save. |

`Open editor` in the showcase hands the current palette to the editor
through `localStorage`; `showcase` in the editor footer goes back.

`slider.html` is generated from `index.html` — they differ only in one
flag and the title. After editing `index.html`, run `./build-slider.sh`
to regenerate it.

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

`slider.html` is a slider of ready-made **1080 × 1350** posts — the
gradient in each one is live, not a still. `Save post` writes the current
slide to PNG at full size.

Seven slides, starting with the two brand palettes: **flohack**
(chalk / acid / steel / ink) and **accilium** (mint / petrol / berry /
deep), followed by Ceramic, Signal, Tidal, Neon Dusk and Kiln. Both brand
palettes are also in the editor's palette list.

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
lowercase, neon only as an accent. Five sections, nothing more:

| Section | Holds |
|---|---|
| look | 6 look presets, 8 palettes |
| colours | ground colour and the individual points |
| form | mode, spread, focus, warp |
| finish | grain, motion, tone |
| export | format, files, code |

The **essentials / everything** switch decides how much is on screen:
8 sliders or 28. Everything stays reachable, it just is not all shown
at once.

## Looks

Six complete setups for backgrounds. A look sets colours, shape, grain
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

Eight **palettes** — flohack and accilium first, then horizon,
fog & almond, matcha roast, crimson sand, cobalt ink, paper. A palette
swaps colours only and leaves the points in place, so any look can be
run through every colour world.

## Every point on its own

The arrow in a colour row opens what sets that point apart:

| Control | Effect |
|---|---|
| Position X / Y | Also outside the canvas (−0.3 to 1.3) — that is where edge falloffs come from |
| Stretch | Ellipse: wide or tall, 1 is round. Area-preserving |
| Rotation | Direction of the stretch |
| Edge | Low = far-reaching haze, high = clearly bounded |
| Strength | How strongly this colour asserts itself against the others |

That is how one colour reaches far while its neighbour stays a tight
spot, without touching the global focus.

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

`Space` play/pause · `R` random · `E` PNG · `1`–`8` palette ·
`←` `→` slider · `Enter` open editor

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
- Hosting note: some sandboxed embeds block script-initiated downloads,
  which disables every export button. Serve the files from a normal
  origin — local file, or any static host — for the exports to work.

---

[flohack.com](https://flohack.com) · [github.com/Flow-Ryan-Hack](https://github.com/Flow-Ryan-Hack)
