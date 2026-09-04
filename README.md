# Optimized Lekton + Nerd Font
---

![original vs optimized vs Nerd Font — Lekton gains a Bold Italic, a dotted 0, and a bigger bullet](./assets/preview.svg)

Modified [Lekton](https://fonts.google.com/specimen/Lekton) with three fixes, built for both desktop and terminal ( Nerd Font ) use.

## features

| # | FEATURE         | WHY                                                                                                                          | EXAMPLE                                                                                                 |
| - | --------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| 1 | **Bold Italic** | Lekton ships Regular / Bold / Italic but no Bold Italic — synthesized from the Italic ( shapes ) + Bold ( weight )           | –                                                                                                       |
| 2 | **dotted `0`**  | Lekton's `0` and `o` look nearly identical; a centered dot disambiguates them                                                | <img src="./assets/zero.svg" width="240" alt="original 0 looks like o; optimized 0 has a centered dot"> |
| 3 | **bigger `•`**  | Lekton's bullet is a tiny 58-unit square ( ≈5.8% of em ); scaled up to ~200 ( 20% of em ), keeping its original square shape | –                                                                                                       |

Every face carries **1 + 2 + 3**; the Nerd Font build adds the Nerd Font glyph set on top.

## layout

| DIR                       | CONTENTS                                                    | FEATURES       |
| ------------------------- | ----------------------------------------------------------- | -------------- |
| [`original/`](./original)   | vendor Lekton — Regular / Bold / Italic ( untouched )       | —              |
| [`optimized/`](./optimized) | 4 desktop faces — Regular / Bold / Italic / **Bold Italic** | 1 + 2 + 3      |
| [`NerdFonts/`](./NerdFonts) | 4 Nerd Font Mono faces ( `otf` + `ttf` )                    | 1 + 2 + 3 + NF |
| [`scripts/`](./scripts)     | `bolditalic.py`, `dotzero.py` ( FontForge )                 | —              |
| [`build.sh`](./build.sh)    | one-click rebuild of `optimized/` + `NerdFonts/`            | —              |

The family name is kept as **Lekton** ( Lekton declares no OFL Reserved Font Name ),
so installing `optimized/` overrides the stock Lekton; the Nerd Font faces install
as **LektonNerdFontMono** and coexist.

## install

- **editor / desktop** → install the four faces in [`optimized/`](./optimized).
- **terminal / prompt with glyphs** → install the four faces in [`NerdFonts/`](./NerdFonts)
  ( use the `ttf` unless your terminal prefers `otf` ).

macOS: double-click a font, or drop the files into `~/Library/Fonts`.
Linux: copy into `~/.local/share/fonts` then `fc-cache -f`.

## build

```bash
bash build.sh              # rebuild optimized/ and NerdFonts/ ( NF step is silent by default )
bash build.sh --all        # also refresh the README SVGs ( assets/preview.svg + zero.svg )
bash build.sh --verbose    # show the font-patcher output for the NF step
bash build.sh --dry-run    # print every command, change nothing
bash build.sh --help       # list all options
```

Requires FontForge ( `brew install fontforge` ) and, for the Nerd Font step,
`font-patcher` at `/opt/FontPatcher/font-patcher`. Script details and options:
[CONTRIBUTING.md](./CONTRIBUTING.md).

## license & credits

- **Lekton** © Academia di Belle Arti di Urbino — [SIL Open Font License 1.1](./LICENSE).
- Modifications ( Bold Italic, dotted `0`, bigger `•`, Nerd Font patching ) by marslo, released under the same OFL 1.1.
- Nerd Font glyphs via [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts).
