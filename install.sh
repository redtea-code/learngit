#!/usr/bin/env bash
set -euo pipefail

force=0
destination="${CODEX_HOME:-$HOME/.codex}"
skills=()

usage() {
  printf '%s\n' 'Usage: ./install.sh [--destination PATH] [--force] [skill-name ...]'
}

while (($#)); do
  case "$1" in
    --destination)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      destination="$2"
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -* )
      usage
      exit 2
      ;;
    *)
      skills+=("$1")
      shift
      ;;
  esac
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_root="$repo_root/skills"
target_root="$destination/skills"
[[ -d "$skills_root" ]] || { printf 'Missing skills directory: %s\n' "$skills_root" >&2; exit 1; }
mkdir -p "$target_root"

if ((${#skills[@]} == 0)); then
  mapfile -t skills < <(find "$skills_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
fi

for skill in "${skills[@]}"; do
  source="$skills_root/$skill"
  target="$target_root/$skill"
  [[ -d "$source" ]] || { printf 'Unknown skill: %s\n' "$skill" >&2; exit 1; }
  if [[ -e "$target" && $force -eq 0 ]]; then
    printf 'Destination already exists: %s (use --force to replace it)\n' "$target" >&2
    exit 1
  fi
  rm -rf "$target"
  cp -a "$source" "$target"
  printf 'Installed %s -> %s\n' "$skill" "$target"
done

printf 'Installed %d skill(s) into %s\n' "${#skills[@]}" "$target_root"
