#!/usr/bin/env bash
# マニフェストが参照する自 repository の skill が実在するかを確かめる。
# 外部 repository の skill は network が要るため、ここでは書式だけを見る。
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
self_repo="takatoku23/my-ai-skill"
status=0

for manifest in "$root"/manifests/user.txt "$root"/manifests/projects/*.txt; do
  [[ -f "$manifest" ]] || continue
  lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    line="${line%%#*}"
    read -r repo skill _ <<<"$line" || true
    [[ -z "${repo:-}" ]] && continue

    where="${manifest#"$root"/}:$lineno"
    if [[ ! "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ || -z "${skill:-}" ]]; then
      echo "$where: '<OWNER/REPO> <skill>' の形式ではない" >&2
      status=1
    elif [[ "$repo" == "$self_repo" && ! -f "$root/$skill/SKILL.md" ]]; then
      echo "$where: $skill/SKILL.md が存在しない" >&2
      status=1
    fi
  done <"$manifest"
done

exit "$status"
