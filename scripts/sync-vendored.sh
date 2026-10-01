#!/usr/bin/env bash
# 他所で公開されている文章を skill の references へ取り込み直す。
# gh skill install で直接入れられない取得元（gist など）だけをここで扱う。
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

# 取得元: k16shikano/japanese-tech-writing（Unlicense）
gist_id="fd287c3133457c4fd8f5601d34aa817d"
dest="$root/skills/writing/japanese-tech-writing/references/style-guide.md"

gh api "gists/$gist_id" --jq '.files["SKILL.md"].content' \
  | awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { fm = 0; skip = 1; next } fm { next } skip && $0 == "" { skip = 0; next } { skip = 0; print }' \
  > "$dest"

echo "updated: ${dest#"$root"/}"
git -C "$root" diff --stat -- "$dest"
