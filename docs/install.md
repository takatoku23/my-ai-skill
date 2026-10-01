# Install and Update

## Prerequisites

- `gh skill` に対応した GitHub CLI
- `takatoku23/my-ai-skill` を読める GitHub 認証
- `mise`、`jq`、Claude Code CLI（plugin を入れる場合）

```bash
gh skill --help
gh auth status
```

## Scope Policy

install scope は、どの作業ディレクトリで skill を使えるようにするかを表す。user scope に入れる skill も、正本はこの repository に置く。

### User scope

repository に依存しない手順と、作業ディレクトリに関係なく使う規範を置く。`manifests/user.txt` に並べる。

| Skill | 理由 |
| --- | --- |
| `reviewable-commits` | repository 固有の規約は実行時に読み、分け方の方針だけを持つ |
| `register-skill` | 対象はこの repository に固定されている |
| `japanese-tech-writing` | 日本語で書く文章すべてに適用する |
| `explainer`（外部） | 説明対象を依頼ごとに受け取る |

### Project scope

特定 repository の構成、規約、外部サービスに依存する skill は `manifests/projects/<repository>.txt` に並べ、その repository にだけ入れる。

その repository の中だけで作って使う skill は、この repository に移さず、その repository の `.claude/skills/` や `.agents/skills/` で管理してよい。複数の repository で使い回したくなった時点で、ここへ移す。

## 置き場所

`gh skill install` は agent ごとに次の場所へ入れる。

| Agent | user scope | project scope |
| --- | --- | --- |
| Codex | `~/.agents/skills/` | `.agents/skills/` |
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |

`~/.codex/skills/` は Codex が読む旧来の置き場所で、gh skill の追跡対象にならない。ここに手で置いた skill は、この repository に移したうえで削除する。

## Install

```bash
mise run install:user     # manifests/user.txt を Codex と Claude Code の両方へ
mise run install:plugins  # manifests/claude-plugins.txt を Claude Code へ
```

project scope は、インストール先 repository の root で実行する。

```bash
cd /path/to/target-repo
mise run --cd /path/to/my-ai-skill install:project -- <repository名>
```

生成された `.agents/skills/` と `.claude/skills/` の差分を確認し、その repository に commit する。

### Pin a Release

再現性を優先する skill は、マニフェストの 3 列目に publish 済み tag か commit SHA を書く。

```text
takatoku23/my-ai-skill skills/dev/reviewable-commits v0.1.0
```

skill 名の変更や破壊的変更を含む release では、先に 1 つの skill を入れて内容と発火条件を確認してから全体に展開する。

## Verify

```bash
mise run inventory
gh skill list --json skillName,sourceURL,scope,version,pinned,path,agentHosts
```

確認項目:

- マニフェストの skill がすべて `managed` になっているか
- Codex と Claude Code の両方に入っているか
- `untracked` が残っていないか（手で置いた skill、改名前の旧版）
- Claude Code plugin の同名 skill と重複していないか

## Update

```bash
mise run update -- --dry-run
mise run update
```

`gh skill update` は、install 時に frontmatter へ書き込まれた source metadata を使って更新する。手でコピーした skill や metadata のない skill は追跡できないため、`mise run install:user` で入れ直す。

`mise run install:local`（`--from-local`）は publish 前の動作確認に限る。通常は publish 後に remote から入れる。
