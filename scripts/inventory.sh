#!/usr/bin/env bash
# この PC の Codex / Claude Code に user scope で入っている skill・plugin・agent を一覧にし、
# マニフェストとのずれを示す。
#
# status:
#   managed   マニフェストにあり、gh skill の source metadata 付きで入っている
#   local     install:local で作業ツリーから入れたもの（publish 後に install:user で入れ直す）
#   untracked 入っているが gh skill の metadata がない（手動コピーなど。gh skill update で追えない）
#   unlisted  metadata はあるがマニフェストにない
#   missing   マニフェストにあるが入っていない
#   plugin    plugin 経由（マニフェストは claude-plugins.txt / Codex は参考表示のみ）
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

manifest_skills="$(sed 's/#.*//' "$root/manifests/user.txt" | awk 'NF >= 2 { n = split($2, p, "/"); print p[n] }' | sort -u)"
manifest_plugins="$(sed 's/#.*//' "$root/manifests/claude-plugins.txt" | awk '$1 == "plugin" { print $2 }' | sort -u)"

rows=()
add() { rows+=("$(printf '| %s | %s | %s | %s |' "$@")"); }

# skill ディレクトリを走査し、見つけた名前を seen_<agent> に足す。$1: agent 名, $2: ディレクトリ
seen_claude="" seen_codex=""
scan_skills() {
  local agent="$1" dir="$2" var="seen_${1%%-*}"
  [[ -d "$dir" ]] || return 0
  for skill_md in "$dir"/*/SKILL.md; do
    [[ -f "$skill_md" ]] || continue
    local name status
    name="$(basename "$(dirname "$skill_md")")"
    if grep -q 'github-repo' "$skill_md"; then
      if grep -qx "$name" <<<"$manifest_skills"; then status=managed; else status=unlisted; fi
    elif grep -q 'local-path:' "$skill_md"; then
      status=local
    else
      status=untracked
    fi
    add "$agent" skill "$name" "$status (${dir/#$HOME/\~})"
    printf -v "$var" '%s%s\n' "${!var}" "$name"
  done
}

scan_skills claude-code "$HOME/.claude/skills"
scan_skills codex "$HOME/.agents/skills"
scan_skills codex "$HOME/.codex/skills"

while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  grep -qx "$name" <<<"$seen_claude" || add claude-code skill "$name" missing
  grep -qx "$name" <<<"$seen_codex" || add codex skill "$name" missing
done <<<"$manifest_skills"

if command -v claude >/dev/null; then
  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    if grep -qx "$id" <<<"$manifest_plugins"; then status=plugin; else status="plugin, unlisted"; fi
    add claude-code plugin "$id" "$status"
  done < <(claude plugin list --json | jq -r '.[] | select(.scope == "user") | .id')
fi

for f in "$HOME"/.claude/agents/*.md "$HOME"/.claude/commands/*.md; do
  [[ -f "$f" ]] || continue
  kind="$(basename "$(dirname "$f")")"
  add claude-code "${kind%s}" "$(basename "$f" .md)" "untracked (Claude 専用)"
done

if [[ -f "$HOME/.codex/config.toml" ]]; then
  while IFS= read -r id; do
    add codex plugin "$id" "plugin (Codex 設定で管理)"
  done < <(sed -n 's/^\[plugins\."\(.*\)"\]$/\1/p' "$HOME/.codex/config.toml")
fi

echo "| agent | kind | name | status |"
echo "| --- | --- | --- | --- |"
printf '%s\n' "${rows[@]}"
