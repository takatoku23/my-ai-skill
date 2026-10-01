#!/usr/bin/env bash
# commit 済みの main を push し、次の version で publish して、この PC の user scope へ入れ直す。
#
# usage: scripts/release.sh [patch|minor|major|vX.Y.Z]   （既定は patch）
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

if [[ "$(git branch --show-current)" != main ]]; then
  echo "main で実行する" >&2
  exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
  echo "commit されていない変更がある。commit してから実行する" >&2
  git status --short >&2
  exit 1
fi

git pull --rebase --quiet origin main
mise run check

current="$(gh release view --json tagName --jq .tagName 2>/dev/null || echo v0.0.0)"
IFS=. read -r major minor patch <<<"${current#v}"
case "${1:-patch}" in
  patch) tag="v$major.$minor.$((patch + 1))" ;;
  minor) tag="v$major.$((minor + 1)).0" ;;
  major) tag="v$((major + 1)).0.0" ;;
  v*) tag="$1" ;;
  *) echo "patch|minor|major|vX.Y.Z のどれかを指定する: $1" >&2; exit 1 ;;
esac

git push --quiet origin main
echo "==> publish $tag (previous: $current)"
gh skill publish --tag "$tag"

scripts/install.sh manifests/user.txt user
scripts/inventory.sh
