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
