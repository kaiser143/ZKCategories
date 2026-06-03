#!/bin/bash
set -euo pipefail

PODSPEC="ZKCategories.podspec"
DRY_RUN=0
SKIP_CONFIRM=0

usage() {
  cat <<'EOF'
Usage: ./UpdateCocoaPod.sh [options]

Bump patch version in ZKCategories.podspec, commit, tag, push, and publish to CocoaPods trunk.

Options:
  -y, --yes       Skip confirmation prompt
  -n, --dry-run   Show planned actions without modifying anything
  -h, --help      Show this help message
EOF
}

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

increment_version() {
  local usage=" USAGE: $FUNCNAME [-l] [-t] <version> [<position>] [<leftmost>]
           -l : remove leading zeros
           -t : drop trailing zeros
    <version> : The version string.
   <position> : Optional. The position (starting with one) of the number
                within <version> to increment.  If the position does not
                exist, it will be created.  Defaults to last position.
   <leftmost> : The leftmost position that can be incremented.  If does not
                exist, position will be created.  This right-padding will
                occur even to right of <position>, unless passed the -t flag."

  local flag_remove_leading_zeros=0
  local flag_drop_trailing_zeros=0
  while [[ "${1:0:1}" == "-" ]]; do
    if [[ "$1" == "--" ]]; then
      shift
      break
    elif [[ "$1" == "-l" ]]; then
      flag_remove_leading_zeros=1
    elif [[ "$1" == "-t" ]]; then
      flag_drop_trailing_zeros=1
    else
      echo -e "Invalid flag: ${1}\n$usage"
      return 1
    fi
    shift
  done

  if [[ $# -lt 1 ]]; then
    echo "$usage"
    return 1
  fi

  local v="${1}"
  local targetPos=${2-last}
  local minPos=${3-${2-0}}

  local IFSbak
  IFSbak=$IFS
  IFS='.'
  read -ra v <<< "$v"

  if [[ "${targetPos}" == "last" ]]; then
    if [[ "${minPos}" == "last" ]]; then
      minPos=0
    fi
    targetPos=$((${#v[@]} > minPos ? ${#v[@]} : minPos))
  fi

  if [[ ! ${targetPos} -gt 0 ]]; then
    echo -e "Invalid position: '$targetPos'\n$usage"
    return 1
  fi

  ((targetPos--)) || true

  while [[ ${#v[@]} -lt ${minPos} ]]; do
    v+=("0")
  done

  v[$targetPos]=$(printf %0${#v[$targetPos]}d $((10#${v[$targetPos]} + 1)))

  if [[ $flag_remove_leading_zeros -eq 1 ]]; then
    for ((pos = 0; pos < ${#v[@]}; pos++)); do
      v[$pos]=$((${v[$pos]} * 1))
    done
  fi

  if [[ ${flag_drop_trailing_zeros} -eq 1 ]]; then
    for ((p = $((${#v[@]} - 1)); p > targetPos; p--)); do
      unset "v[$p]"
    done
  else
    for ((p = $((${#v[@]} - 1)); p > targetPos; p--)); do
      v[$p]=0
    done
  fi

  echo "${v[*]}"
  IFS=$IFSbak
  return 0
}

read_current_version() {
  local line
  line=$(grep -E '^\s*s\.version\s*=' "$PODSPEC" | head -n 1) || die "Could not find s.version in $PODSPEC"

  if [[ "$line" =~ s\.version[[:space:]]*=[[:space:]]*\"([^\"]+)\" ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    die "Could not parse version from: $line"
  fi
}

update_podspec_version() {
  local current_version="$1"
  local new_version="$2"
  local line_number

  line_number=$(grep -nE '^\s*s\.version\s*=' "$PODSPEC" | head -n 1 | cut -d: -f1) || \
    die "Could not locate s.version line in $PODSPEC"

  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "${line_number}s/${current_version}/${new_version}/" "$PODSPEC"
  else
    sed -i "${line_number}s/${current_version}/${new_version}/" "$PODSPEC"
  fi
}

resolve_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || true)
  [[ -n "$branch" ]] || die "Could not determine current git branch"
  echo "$branch"
}

confirm_release() {
  local current_version="$1"
  local new_version="$2"
  local branch="$3"

  cat <<EOF

Release plan:
  Podspec : $PODSPEC
  Version : $current_version -> $new_version
  Branch  : $branch
  Steps   : pod lib lint -> commit -> tag -> push -> pod trunk push

EOF

  if [[ "$SKIP_CONFIRM" -eq 1 ]]; then
    return 0
  fi

  read -r -p "Continue? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || die "Aborted"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -y | --yes)
        SKIP_CONFIRM=1
        ;;
      -n | --dry-run)
        DRY_RUN=1
        SKIP_CONFIRM=1
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  local script_dir
  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  cd "$script_dir"

  command -v pod >/dev/null 2>&1 || die "CocoaPods is not installed (pod command not found)"
  [[ -f "$PODSPEC" ]] || die "$PODSPEC not found in $script_dir"

  if [[ "$DRY_RUN" -eq 0 ]]; then
    git diff --quiet || die "Working tree has uncommitted changes. Commit or stash them first."
    git diff --cached --quiet || die "Index has staged changes. Commit or unstage them first."
  fi

  local current_version new_version git_branch
  current_version=$(read_current_version)
  new_version=$(increment_version "$current_version" 3)
  git_branch=$(resolve_git_branch)

  if git rev-parse "$new_version" >/dev/null 2>&1; then
    die "Tag $new_version already exists"
  fi

  confirm_release "$current_version" "$new_version" "$git_branch"

  log "Current version: $current_version"
  log "New version: $new_version"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    run update_podspec_version "$current_version" "$new_version"
    run pod lib lint "$PODSPEC" --allow-warnings
    run git add "$PODSPEC"
    run git commit -m "$new_version"
    run git tag "$new_version"
    run git push -u origin "$git_branch" --tags
    run pod trunk push "./$PODSPEC" --verbose --allow-warnings
    exit 0
  fi

  update_podspec_version "$current_version" "$new_version"

  log "Linting podspec..."
  pod lib lint "$PODSPEC" --allow-warnings

  log "Committing and tagging..."
  git add "$PODSPEC"
  git commit -m "$new_version"
  git tag "$new_version"

  log "Pushing to origin/$git_branch..."
  git push -u origin "$git_branch" --tags

  log "Publishing to CocoaPods trunk..."
  pod trunk push "./$PODSPEC" --verbose --allow-warnings

  log "Done. Published $new_version"
}

main "$@"
