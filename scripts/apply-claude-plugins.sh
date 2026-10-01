#!/usr/bin/env bash
# manifests/claude-plugins.txt の marketplace と plugin を user scope へ揃える。
# 既に入っているものは飛ばすため、何度実行してもよい。
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
manifest="$root/manifests/claude-plugins.txt"

known_marketplaces="$(claude plugin marketplace list --json 2>/dev/null | jq -r '.[].name' || true)"
installed="$(claude plugin list --json | jq -r '.[] | select(.scope == "user") | .id')"

while read -r kind name source _; do
  [[ -z "${kind:-}" ]] && continue
  case "$kind" in
    marketplace)
      if grep -qx "$name" <<<"$known_marketplaces"; then
        echo "skip marketplace: $name"
      else
        claude plugin marketplace add "$source"
      fi
      ;;
    plugin)
      if grep -qx "$name" <<<"$installed"; then
        echo "skip plugin: $name"
      else
        claude plugin install "$name" --scope user
      fi
      ;;
    *) echo "unknown entry: $kind" >&2; exit 1 ;;
  esac
done < <(sed 's/#.*//' "$manifest")
