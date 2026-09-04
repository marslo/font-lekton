#!/usr/bin/env bash
# =============================================================================
#      FileName : build.sh
#        Author : marslo
#       Created : 2026-09-03 21:43:00
#    LastChange : 2026-09-03 21:53:54
# =============================================================================
# one-click (re)build of the modified Lekton fonts:
#   1. synthesize the missing Bold Italic  ( italic shapes + bold weight )
#   2. dot the '0' + enlarge the '•'       ( scripts/dotzero.py --square )
#   3. Nerd Font patch                     ( font-patcher, mono )

set -euo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]:-$0}" )" && pwd )"
declare -r ROOT
declare -r ORIG="${ROOT}/original"
declare -r OPT="${ROOT}/optimized"
declare -r NF="${ROOT}/NerdFonts"
declare -r BOLDITALIC="${ROOT}/scripts/bolditalic.py"
declare -r DOTZERO="${ROOT}/scripts/dotzero.py"
declare -r PREVIEW="${ROOT}/scripts/preview.py"
# font-patcher: the vendored /opt copy, else whatever 'type -P' finds on PATH ( $FONT_PATCHER overrides )
declare FONT_PATCHER="${FONT_PATCHER:-/opt/FontPatcher/font-patcher}"
test -x "${FONT_PATCHER}" || FONT_PATCHER="$( type -P font-patcher || true )"
declare -r FONT_PATCHER
declare -ra EXTS=( otf ttf )
declare DRYRUN=false
declare VERBOSE=false
declare ALL=false

function die()  { printf 'error: %s\n' "${*}" >&2; exit 1; }
function step() { printf '\n\033[1;36m==>\033[0m \033[1m%s\033[0m\n' "${*}"; }
function usage() {
  cat <<'EOF'
  build.sh — rebuild the modified Lekton fonts ( Bold Italic, dotted 0, enlarged • )

USAGE
  bash build.sh [ options ]

OPTIONS
  --all              also refresh the README SVGs ( assets/preview.svg + zero.svg )
  -v, --verbose      show font-patcher output ( default: NF step is silent )
  -n, --dry-run      print the commands, build nothing
  -h, --help         show this help and exit

OUTPUTS
  optimized/         4 desktop faces  ( dotted 0 + enlarged • , no NF glyphs )
  NerdFonts/         4 Nerd Font Mono faces ( + NF glyph set, otf + ttf )
EOF
  exit 0
}
# run a build step ( DRYRUN prints the command instead of running it )
function run() {
  if "${DRYRUN}"; then printf '   $ %s\n' "${*}"; return 0; fi
  "${@}"
}
# run a Nerd Font ( font-patcher ) step: output hidden unless --verbose
function runNF() {
  if "${DRYRUN}"; then printf '   $ %s\n' "${*}"; return 0; fi
  if "${VERBOSE}"; then "${@}"; else "${@}" >/dev/null 2>&1; fi
}

for arg in "${@}"; do
  case "${arg}" in
    --all          ) ALL=true     ;;
    -v | --verbose ) VERBOSE=true ;;
    -n | --dry-run ) DRYRUN=true  ;;
    -h | --help    ) usage        ;;
    *              ) die "unknown option: ${arg}" ;;
  esac
done

# font-patcher opts: add its own --quiet / --no-progressbars unless --verbose
declare -a PATCH_OPTS=( --mono --complete --careful )
"${VERBOSE}" || PATCH_OPTS+=( --quiet --no-progressbars )
declare -r PATCH_OPTS

command -v fontforge >/dev/null 2>&1 || die 'fontforge required ( brew install fontforge )'
test -x "${FONT_PATCHER}"            || die 'font-patcher not found ( install to /opt/FontPatcher, put it on PATH, or set $FONT_PATCHER )'
test -d "${ORIG}"                    || die "missing sources: ${ORIG}"

# 1. synthesize Bold Italic, then assemble the 4 un-dotted base faces in a work dir
step 'synthesize Bold Italic ( italic shapes + bold weight )'
WORK="$( mktemp -d )"
trap 'rm -rf "${WORK}"' EXIT
run cp "${ORIG}/Lekton-Regular.ttf" "${ORIG}/Lekton-Bold.ttf" "${ORIG}/Lekton-Italic.ttf" "${WORK}/"
run fontforge -script  "${BOLDITALIC}" \
              --italic "${ORIG}/Lekton-Italic.ttf" \
              --bold   "${ORIG}/Lekton-Bold.ttf" \
              -o       "${WORK}/Lekton-BoldItalic.ttf"

# 2. optimized/ — dot the 0 + enlarge the • on the 4 base faces ( no NF )
step 'optimized/ : dot 0 + enlarge •'
run rm -f "${OPT}"/*.ttf
run fontforge -script "${DOTZERO}" --square -o "${OPT}" "${WORK}"/Lekton-*.ttf

# 3. NerdFonts/ — patch the 4 base faces, then dot 0 + enlarge • in place
step 'NerdFonts/ : Nerd Font patch, then dot 0 + enlarge •'
run rm -f "${NF}"/*NerdFont*.otf "${NF}"/*NerdFont*.ttf
for f in "${WORK}"/Lekton-*.ttf; do
  for e in "${EXTS[@]}"; do
    runNF "${FONT_PATCHER}" "${f}" "${PATCH_OPTS[@]}" -ext "${e}" -out "${NF}"
  done
done
shopt -s nullglob
declare -a nfOut=( "${NF}"/*NerdFont*.otf "${NF}"/*NerdFont*.ttf )
shopt -u nullglob
test "${#nfOut[@]}" -gt 0 && runNF fontforge -script "${DOTZERO}" --square -o "${NF}" "${nfOut[@]}"

# 4. ( --all only ) refresh the README graphics from the freshly built fonts
if "${ALL}"; then
  step 'update README graphics ( assets/preview.svg + zero.svg )'
  run fontforge -script "${PREVIEW}"
fi

step 'DONE'
printf 'optimized/ and NerdFonts/ rebuilt%s.\n' "$( "${ALL}" && printf '; SVGs updated' || true )"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
