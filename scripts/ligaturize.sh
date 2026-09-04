#!/usr/bin/env bash
# =============================================================================
#      FileName : ligaturize.sh
#        Author : marslo
#       Created : 2026-09-04 01:30:00
#    LastChange : 2026-09-04 05:50:29
# =============================================================================
# add Fira Code ligatures to the optimized Lekton via Ligaturizer ( /opt/Ligaturizer ). copies FiraCode's ligature glyphs + calt rules into each face, scale-corrected, and renames the family to 'LektonLig' ( one word, like OperatorMonoLig ).
#
# the source faces must already carry '^' ( asciicircum ) — Ligaturizer aborts without it; scripts/glyphfix.py adds it, so run this after glyphfix.
#
# usage:
#   bash ligaturize.sh --from <src-dir> --to <dst-dir> [ -n | --dry-run ]
#   e.g. bash ligaturize.sh --from ./optimized --to ./LektonLig
#
# override the Ligaturizer location with $LIGATURIZER.

set -euo pipefail

declare -r LIGATURIZER="${LIGATURIZER:-/opt/Ligaturizer}"
declare -r LIG_URL='https://git::@github.com/ToxicFrog/Ligaturizer.git'   # git::@ dodges any insteadOf ssh rewrite
declare -r LIG_MATCH='ToxicFrog/Ligaturizer'     # remote must contain this
declare -r LIG_BRANCH='master'
declare -ra LIG_SUBMODULES=( 'fonts/fira' )      # only submodules ligaturize.py needs ( FiraCode otf ); extend as needed
# force plain github https so a user's 'insteadOf' ssh rewrite never fires ( main repo + submodules )
declare -ra GIT_FORCE_HTTPS=( -c 'url.https://git::@github.com/.insteadOf=https://github.com/' )
declare -r NAME='LektonLig'                      # output family name ( no spaces )
declare FROM=''
declare TO=''
declare DRYRUN=false

function die()   { printf 'error: %s\n' "${*}" >&2; exit 1; }
function usage() { printf 'usage: bash ligaturize.sh --from <src-dir> --to <dst-dir> [ -n | --dry-run ]\n'; exit 0; }

# clone Ligaturizer if missing / not a repo; update it if it's the right repo; die otherwise. shallow ( depth 1 ) + only the needed submodules
function ensureLigaturizer() {
  local url=''
  if test -d "${LIGATURIZER}" && git -C "${LIGATURIZER}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    url="$( git -C "${LIGATURIZER}" remote get-url origin 2>/dev/null || true )"
    case "${url}" in
      *"${LIG_MATCH}"* )
        printf '==> updating Ligaturizer in %s\n' "${LIGATURIZER}"
        git -C "${LIGATURIZER}" clean -dffx >/dev/null
        git -C "${LIGATURIZER}" "${GIT_FORCE_HTTPS[@]}" fetch --depth 1 --prune origin "${LIG_BRANCH}"
        git -C "${LIGATURIZER}" reset --hard "origin/${LIG_BRANCH}"
        git -C "${LIGATURIZER}" "${GIT_FORCE_HTTPS[@]}" submodule update --init --depth 1 "${LIG_SUBMODULES[@]}"
        printf '==> Ligaturizer at %s\n' "$( git -C "${LIGATURIZER}" rev-parse --short=9 HEAD )" ;;
      * ) die "not the Ligaturizer repo at ${LIGATURIZER} ( remote: ${url:-none} )" ;;
    esac
  else
    printf '==> cloning Ligaturizer into %s\n' "${LIGATURIZER}"
    local -a recurse=()
    local sm
    for sm in "${LIG_SUBMODULES[@]}"; do recurse+=( "--recurse-submodules=${sm}" ); done
    git "${GIT_FORCE_HTTPS[@]}" clone --depth 1 --shallow-submodules "${recurse[@]}" "${LIG_URL}" "${LIGATURIZER}" || die "failed to clone ${LIG_URL}"
  fi
  test -f "${LIGATURIZER}/ligaturize.py" || die "ligaturize.py missing in ${LIGATURIZER}"
}

while test "${#}" -gt 0; do
  case "${1}" in
    --from         ) FROM="${2}"; shift 2       ;;
    --to           ) TO="${2}";   shift 2       ;;
    -n | --dry-run ) DRYRUN=true; shift         ;;
    -h | --help    ) usage                      ;;
    *              ) die "unknown option: ${1}" ;;
  esac
done

test -n "${FROM}" && test -n "${TO}" || usage
command -v git       >/dev/null 2>&1 || die 'git required'
command -v fontforge >/dev/null 2>&1 || die 'fontforge required ( brew install fontforge )'
test -d "${FROM}"                    || die "missing source dir: ${FROM}"
ensureLigaturizer     # clone / update /opt/Ligaturizer as needed

# ligaturize.py resolves its bundled FiraCode via a relative path, so it must run from the Ligaturizer dir; pass absolute in/out paths
FROM="$( cd "${FROM}" && pwd )"
"${DRYRUN}" || mkdir -p "${TO}"
TO="$( cd "${TO}" 2>/dev/null && pwd || echo "${TO}" )"

shopt -s nullglob
declare -a srcs=( "${FROM}"/*.ttf "${FROM}"/*.otf )
shopt -u nullglob
test "${#srcs[@]}" -gt 0 || die "no .ttf/.otf found in ${FROM}"

for src in "${srcs[@]}"; do
  printf '  >> ligaturize %s\n' "$( basename "${src}" )"
  "${DRYRUN}" && continue
  ( cd "${LIGATURIZER}" && fontforge -lang=py -script ligaturize.py "${src}" --output-dir "${TO}" --output-name "${NAME}" --prefix '' ) 2>/dev/null
done

printf 'done: %d face(s) -> %s\n' "${#srcs[@]}" "${TO}"

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
