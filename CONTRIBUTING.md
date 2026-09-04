<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Contributing / Build internals](#contributing--build-internals)
  - [setup](#setup)
    - [font-patcher](#font-patcher)
  - [pipeline](#pipeline)
  - [scripts/bolditalic.py — synthesize Bold Italic](#scriptsbolditalicpy--synthesize-bold-italic)
  - [scripts/dotzero.py — dot the `0`, enlarge the `•`](#scriptsdotzeropy--dot-the-0-enlarge-the-%E2%80%A2)
  - [build.sh — one-click rebuild](#buildsh--one-click-rebuild)
  - [scripts/preview.py — regenerate the README graphics](#scriptspreviewpy--regenerate-the-readme-graphics)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Contributing / Build internals

How the modified Lekton faces are produced. Everything is driven by [`build.sh`](./build.sh); the two FontForge scripts under [`scripts/`](./scripts) do the actual glyph work.

> [!IMPORTANT]
> - Both scripts need **FontForge's python** — run via `fontforge -script`, not plain `python3`. `brew install fontforge` ( macOS ) / `apt install fontforge` ( linux ).
> - Nerd Font patching additionally needs [`font-patcher`](https://github.com/ryanoasis/nerd-fonts/releases/latest) | [download latest `FontPatcher.zip`](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip)

## setup

| TOOL                            | NEEDED FOR                                   | INSTALL                                                                   |
| ------------------------------- | -------------------------------------------- | ------------------------------------------------------------------------- |
| **FontForge** ( with python )   | all scripts ( bolditalic, dotzero, preview ) | `brew install fontforge` · `sudo apt install fontforge python3-fontforge` |
| **font-patcher** ( Nerd Fonts ) | the `NerdFonts/` build only                  | see below                                                                 |

Always run the scripts through FontForge's python — `fontforge -script …`, never plain `python3`.

### font-patcher

`build.sh` looks for it at `/opt/FontPatcher/font-patcher`, then on `PATH` ( `type -P font-patcher` ), and honours a `$FONT_PATCHER` override. The self-contained `FontPatcher.zip` on any [Nerd Fonts release](https://github.com/ryanoasis/nerd-fonts/releases) bundles the patcher plus its glyph sources:

```bash
curl -fL -o /tmp/FontPatcher.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip
sudo mkdir -p /opt/FontPatcher
sudo unzip -o /tmp/FontPatcher.zip -d /opt/FontPatcher
fontforge -script /opt/FontPatcher/font-patcher --version   # smoke test
```

So a `font-patcher` already on your `PATH` works with no config; otherwise install to `/opt/FontPatcher` or run `FONT_PATCHER=/path/to/font-patcher bash build.sh`. FontForge is a runtime dependency of font-patcher too, so install it first.

## pipeline

```
original/  ──[ bolditalic.py ]──▶  + Lekton-BoldItalic   (synth 4th face)
   │                                        │
   └──────────────── 4 base faces ──────────┘
                          │
             ┌────────────┴─────────────┐
             ▼                          ▼
   [ dotzero.py --square ]     [ font-patcher ] ─▶ [ dotzero.py --square ]
             ▼                          ▼
        optimized/                  NerdFonts/
   (dot 0 + big •, no NF)      (dot 0 + big • + NF)
```

## scripts/bolditalic.py — synthesize Bold Italic

Lekton ships Regular / Bold / Italic but **no Bold Italic**. This borrows the italic letterforms + slant from `Lekton-Italic` and the weight from `Lekton-Bold`.

- **how** — emboldens the Italic by the auto-measured `Bold − Italic` stem delta, keeps the `-9.3°` slant and each glyph's advance width ( monospace-safe ), then stamps the RIBBI Bold+Italic name/style bits.
- **why not `changeWeight`** — FontForge's `changeWeight` does stem detection and silently collapses the italic's heavily-slanted stems ( `i ì í î ï` ). Instead the outline is thickened by an **8-way shift-union** ( overlay the glyph shifted in 8 directions, then merge ) — no stem detection, so nothing collapses. It runs in cubic then converts back to quadratic to avoid `Invalid 2nd order spline` errors; integer offsets keep `removeOverlap` quiet.
- **auto amount** — measures the `l` stem of both faces; delta ≈ `51` at em=1000 ( italic stem `52` → `~103`, matching Bold ). Override with `-a`.

```bash
fontforge -script  scripts/bolditalic.py \
          --italic original/Lekton-Italic.ttf \
          --bold   original/Lekton-Bold.ttf \
          -o       Lekton-BoldItalic.ttf
fontforge -script scripts/bolditalic.py -n         # dry-run ( prints the amount )
```

| OPTION           | DEFAULT                       | DESCRIPTION                      |
| ---------------- | ----------------------------- | -------------------------------- |
| `--italic FILE`  | `Lekton-Italic.ttf`           | source italic ( shapes + slant ) |
| `--bold FILE`    | `Lekton-Bold.ttf`             | weight reference ( stem target ) |
| `-o, --out FILE` | `Lekton-BoldItalic.ttf`       | output path                      |
| `-a, --amount N` | auto ( `bold − italic` stem ) | embolden units at em=1000        |
| `-n, --dry-run`  | —                             | print actions without writing    |

> [!NOTE]
> Synthetic ( faux ) bold, not an original designed weight — fine for a monospace coding font at editor sizes. The italic `o` counter stays a bit more open than the real Bold's.

## scripts/dotzero.py — dot the `0`, enlarge the `•`

Post-processes built faces in place; advance width is kept ( monospace-safe ).

- **dotted `0`** — adds a centered dot so `0` ≠ `o`.
- **bigger `•`** — Lekton's bullet is a tiny 58-unit square ( ≈5.8% of em ). Two mutually exclusive ways to grow it, both centered and monospace-safe, and both **create** the glyph on faces that lack it ( the Italic has no `•` ):
  - `--square [N]` — scale the original outline, keeping its square shape ( half-size N, default 100 → 200 wide ). **build.sh uses this.**
  - `--bullet [N]` — replace it with a round dot ( radius N, default 100 → ⌀200 ).

```bash
fontforge -script scripts/dotzero.py --square -o OUTDIR path/to/*.ttf   # square ( default build )
fontforge -script scripts/dotzero.py --bullet -o OUTDIR path/to/*.ttf   # round dot instead
```

| OPTION              | DEFAULT                   | DESCRIPTION                                                                                |
| ------------------- | ------------------------- | ------------------------------------------------------------------------------------------ |
| `-o, --out-dir DIR` | `<input-parent>-dotted`   | output dir                                                                                 |
| `-r, --radius N`    | `62`                      | dot radius at em=1000                                                                      |
| `--bold-radius N`   | `radius + 10`             | dot radius for bold faces ( auto-detected )                                                |
| `-g, --glyph NAME`  | `zero`                    | glyph to dot                                                                               |
| `--square [N]`      | off ( `100` when passed ) | enlarge `•` keeping its square shape ( half-size N → `100` = 200 wide )                    |
| `--bullet [N]`      | off ( `100` when passed ) | enlarge `•` as a round dot ( radius N → `100` = ⌀200 ); mutually exclusive with `--square` |
| `--rename SUFFIX`   | —                         | append SUFFIX to the family name                                                           |
| `-n, --dry-run`     | —                         | print actions without writing                                                              |

> [!WARNING]
> Re-running on an already-dotted face adds a **second** dot to `0` ( it warns and proceeds ). `build.sh` always dots freshly built faces, so this never happens in the normal flow.

## build.sh — one-click rebuild

```bash
bash build.sh              # rebuild optimized/ and NerdFonts/ ( NF step silent )
bash build.sh --all        # rebuild optimized/ and NerdFonts/ ( NF step silent ) + refresh assets/preview.svg + zero.svg as a last step
bash build.sh --verbose    # show the font-patcher output for the NF step
bash build.sh --dry-run    # print every command, touch nothing
```

Steps: synthesize Bold Italic → `optimized/` ( dot 0 + big • ) → `NerdFonts/` ( patch, then dot 0 + big • ) → `--all` also runs `preview.py`. Intermediates live in a `mktemp` dir and are removed on exit; `original/` is never modified.

| FLAG            | EFFECT                                                            |
| --------------- | ----------------------------------------------------------------- |
| `--all`         | also regenerate the README SVGs after the fonts                   |
| `-v, --verbose` | show the font-patcher output ( the NF step is silent by default ) |
| `-n, --dry-run` | print the commands, build nothing                                 |
| `-h, --help`    | show help and exit                                                |

## scripts/preview.py — regenerate the README graphics

Renders two SVGs straight from the repo's fonts:

- `assets/preview.svg` — the comparison matrix at the top of the README.
- `assets/zero.svg` — the small `0` vs `o` before/after in the features table.

The layout is picked by a **preset**, auto-detected from the directory: `font-lekton` ( 3 columns — original / optimized / NerdFonts ) or `fonts-lekton` ( 2 columns —original / nerd font ). The same script drops into `fonts/Lekton/` unchanged and selects the 2-column preset there; force one with `--preset NAME`.

Sample text is emitted as glyph **outlines**, not `<text>` in the font, because GitHub loads README SVG via `<img>` and never applies `@font-face`. It is **not** part of the default build ( to keep font rebuilds fast ); run it after rebuilding the fonts, or let `build.sh --all` run it for you:

```bash
fontforge -script scripts/preview.py                         # -> assets/preview.svg + assets/zero.svg ( auto preset )
fontforge -script scripts/preview.py --preset fonts-lekton   # force the 2-column layout
bash build.sh --all                                          # rebuild fonts, then regenerate both SVGs
```
