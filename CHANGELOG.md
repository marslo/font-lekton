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
