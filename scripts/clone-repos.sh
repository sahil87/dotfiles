#!/usr/bin/env bash
# Bulk-clone repos listed in repos.yaml
# Usage: ./clone-repos.sh [path/to/repos.yaml]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${1:-$SCRIPT_DIR/repos.yaml}"

if ! command -v yq &>/dev/null; then
  echo "Error: yq is required (https://github.com/mikefarah/yq)" >&2
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "Error: config not found: $CONFIG" >&2
  exit 1
fi

# Iterate over each directory key
yq -r 'keys[]' "$CONFIG" | while read -r dir; do
  expanded_dir="${dir/#\~/$HOME}"
  mkdir -p "$expanded_dir"

  # Iterate over repos under this directory
  yq -r ".\"$dir\"[]" "$CONFIG" | while read -r url; do
    [[ -z "$url" ]] && continue
    repo_name=$(basename "$url" .git)
    target="$expanded_dir/$repo_name"

    if [[ -d "$target" ]]; then
      echo "skip: $target (already exists)"
    else
      echo "clone: $url → $target"
      git clone "$url" "$target"
    fi
  done
done
