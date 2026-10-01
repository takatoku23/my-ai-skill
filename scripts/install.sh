#!/usr/bin/env bash
# マニフェストに並べた skill を Codex と Claude Code の両方へ gh skill install する。
#
# usage: scripts/install.sh <manifest> <user|project> [--local]
#
# マニフェストは 1 行 1 skill で `<OWNER/REPO> <skill path or name> [pin]`。
# `#` 以降と空行は無視する。
# --local を付けると、このリポジトリの skill だけ remote ではなく作業ツリーから入れる
# （publish 前の smoke test 用）。
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
self_repo="takatoku23/my-ai-skill"
agents=(codex claude-code)

manifest="${1:?manifest path is required}"
scope="${2:?scope (user|project) is required}"
local_mode="${3:-}"

case "$scope" in
  user | project) ;;
  *) echo "scope must be user or project: $scope" >&2; exit 1 ;;
esac

if [[ "$scope" == project ]] && ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "project scope はインストール先 repository の中で実行する" >&2
  exit 1
fi

while read -r repo skill pin _; do
  [[ -z "${repo:-}" || "$repo" == \#* ]] && continue

  args=()
  if [[ "$repo" == "$self_repo" && "$local_mode" == --local ]]; then
    # --from-local は skills/ を除いた namespace/name で指定する
    args=("$root" "${skill#skills/}" --from-local)
  else
    args=("$repo" "$skill")
    [[ -n "${pin:-}" && "$pin" != \#* ]] && args+=(--pin "$pin")
  fi

  for agent in "${agents[@]}"; do
    echo "==> $repo $skill ($agent, $scope)"
    gh skill install "${args[@]}" --agent "$agent" --scope "$scope" --force
  done
done < <(sed 's/#.*//' "$manifest")
