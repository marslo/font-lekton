## [2.1.0](https://github.com/marslo/font-lekton/compare/v2.0.0...v2.1.0) (2026-11-04)

### Features

* **glyphfix**, **build**: draw the missing `⌥`, arrows and macOS key symbols from Lekton's own strokes, and alias U+F8FF to `nf-fa-apple` in the Nerd Font build ([b56069d](https://github.com/marslo/font-lekton/commit/b56069d6a5bc6d2541b293c5678d7f9c0361b499))
  - draw `⌥` in Menlo's proportions from the face's own `−` stroke and slant
  - compose `← ↑ → ↓` from the `−` stroke with a chevron head in the `›` proportion
  - stroke `⌘ ⇧ ⌃ ⎋ ⏎ ⌫ ⌦ ⇥ ⇤ ↵ ⇪ ⏏ ␣` with the `−` weight, capped so bold faces stay open
  - alias U+F8FF ( Apple logo ) to `nf-fa-apple` in `LektonLigNF/` via `scripts/nf-applelogo.py`
  - build the new glyphs in a cubic scratch font to avoid fontforge 2025.10.9 refcount / stroke crashes
  - document the new glyphs and the alias step

### Others

* **lekton**: rebuild `LektonLig` and `LektonLigNF` ([d917b04](https://github.com/marslo/font-lekton/commit/d917b04bdddaa12ba20c29931bdcd69b5932f397))
  - regenerate the 4 ligature faces with `⌥`, `← ↑ → ↓` and the macOS key symbols
  - regenerate the 8 Nerd Font faces ( `otf` + `ttf` ) from them
  - alias U+F8FF to `nf-fa-apple` in every Nerd Font face
* **ligaturize**: slim the /opt/Ligaturizer clone to a shallow, fira-only fetch over forced https ([a3c3212](https://github.com/marslo/font-lekton/commit/a3c3212510ec7d50723330e97294655374cb35ed))
  - clone --depth 1 --shallow-submodules with only fonts/fira ( skips codeface/plex/… — ~5G → tens of MB )
  - fetch/update shallowly on later runs ( depth 1, fira submodule only )
  - add a LIG_SUBMODULES array so more submodules can be listed later
  - force github https via git::@ + an insteadOf override so a user's ssh rewrite never fires

### Documentation

* update readme ([084c476](https://github.com/marslo/font-lekton/commit/084c47637954cdb7dd94238548813321a1fcf85f))

## [2.0.0](https://github.com/marslo/font-lekton/compare/v1.0.0...v2.0.0) (2026-09-04)

### ⚠ BREAKING CHANGE

* **lekton:** NerdFonts/ is replaced by LektonLigNF/ and the Nerd Font family is renamed LektonNerdFontMono → LektonLigNerdFontMono; release assets are renamed ( Lekton-NerdFont.zip → LektonLig-NerdFont.zip, + new LektonLig.zip ).

### Features

* **lekton**: integrate Fira Code ligatures via a per-stage build ( optimized → LektonLig → LektonLigNF ), add ^/grave glyphs, split dotzero ([c57e4b5](https://github.com/marslo/font-lekton/commit/c57e4b546966155cc82da03e22f92a9782fa6a53))
  - add scripts/ligaturize.sh wrapping Ligaturizer to copy Fira Code calt ligatures into every face ( LektonLig family )
  - add scripts/glyphfix.py: enlarge the bullet and synthesize the missing ^ and grave from each face's own â/à accents
  - split scripts/dotzero.py down to only dotting the zero
  - restructure build.sh into a per-stage pipeline: original → optimized → LektonLig → LektonLigNF
  - render assets/ligatures.svg in preview.py ( pre-commit-clean output ); refresh README + CONTRIBUTING
  - rewire release zips/assets, correct the OFL copyright to "Accademia", drop the svg pre-commit exclude
  BREAKING CHANGE: NerdFonts/ is replaced by LektonLigNF/ and the Nerd Font family is renamed LektonNerdFontMono → LektonLigNerdFontMono; release assets are renamed ( Lekton-NerdFont.zip → LektonLig-NerdFont.zip, + new LektonLig.zip ).

## 1.0.0 (2026-09-04)

### Features

* introduce font-lekton — optimized & Nerd Font Lekton with Bold Italic, dotted 0, squared-up bullet, plus build/CI/release ([9c1d74c](https://github.com/marslo/font-lekton/commit/9c1d74ce05db0e348985cd6102236197a97b070e))
  - synthesize the missing Bold Italic ( italic shapes + bold weight )
  - dot the 0 and enlarge the • to a square across all four faces
  - ship desktop ( optimized/ ) and Nerd Font ( NerdFonts/ ) builds from the vendor originals
  - add FontForge scripts ( bolditalic, dotzero, preview ) and a one-click build.sh
  - wire up semantic-release + pre-commit workflows, OFL license, README banner, and CONTRIBUTING


### Bug Fixes

* **preview**: skip absent font faces via per-preset omit set, rebuild fonts ([a049731](https://github.com/marslo/font-lekton/commit/a049731e1fdf4f70bc69fe340bd57971ae3d3cbe))
  - add per-preset `omit` set to skip listed (column, style) faces
  - omit vendor Lekton's missing Bold Italic in the fonts-lekton preset
  - rebuild optimized + Nerd Font binaries
