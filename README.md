# my-ai-skill

Codex と Claude Code で使う Agent Skills を、`gh skill` で配布・更新するための repository。

自作の skill の正本をここに置くほか、PC に入れる外部 skill と Claude Code plugin をマニフェストで宣言する。別の PC でもマニフェストから同じ構成を再現でき、`mise run inventory` で手元の状態とのずれを確認できる。

## Directory Structure

```text
skills/
  dev/          # Git / GitHub の作業手順、skill 管理
  writing/      # 日本語の文章規範

manifests/
  user.txt              # user scope に入れる skill（自作・外部）
  projects/<repo>.txt   # 特定 repository の project scope に入れる skill
  claude-plugins.txt    # Claude Code の marketplace と plugin

scripts/        # install、棚卸し、検証、取り込み
docs/
  install.md    # install / update の手順と scope の方針
  privacy.md    # repository に入れてよい情報の境界
```

## Skill Catalog

| Namespace | Skill | Purpose |
| --- | --- | --- |
| `dev` | `reviewable-commits` | 変更を目的と影響が追える小さなコミットへ分ける |
| `dev` | `register-skill` | 明示された skill をこの repository に登録する |
| `writing` | `japanese-tech-writing` | 日本語の技術文章を規範に沿って書く・推敲する |

マニフェストで入れる外部 skill:

| Repository | Skill | Purpose |
| --- | --- | --- |
| `mizchi/explainer` | `explainer` | 読み手に合わせた速習資料を作り、図と主張を検証する |

## Usage

```bash
mise run inventory        # PC の skill / plugin とマニフェストのずれを表示
mise run install:user     # user scope の skill を Codex と Claude Code へ入れる
mise run install:plugins  # Claude Code の plugin を入れる
mise run update -- --dry-run
mise run update
```

詳しくは [docs/install.md](docs/install.md) を参照。

## Development

`mise`、`gh skill` 対応の GitHub CLI、Node.js を使う。

```bash
mise run check          # publish validation、マニフェスト、スクリプトの構文、diff の空白
mise run install:local  # 作業ツリーの自作 skill を user scope へ入れて動作確認
mise run sync           # gist から取り込んだ references を更新
```

`mise run check` が通らない変更は merge しない。

## Publish

`main` に merge し、CI が通った後に tag を付けて publish する。

```bash
mise run publish -- v0.1.0
```

publish 後は `mise run install:user` で remote から入れ直し、`mise run inventory` で `managed` になっていることを確認する。

## Scope

この repository に置くもの:

- Codex と Claude Code のどちらでも意味が通る skill
- 外部 skill と plugin の参照（本体はコピーしない）
- gh skill で入れられない公開物（gist など）の取り込みと、その取得元

置かないもの:

- token、secret、credential
- 外部 repository で公開されている skill のコピー
- 特定 repository の中で完結する skill（その repository の `.claude/skills/` で管理する）
- Claude Code plugin 固有の commands、agents、hooks（`takatoku23/takuto-claude-plugin` 側で管理する）

詳しくは [docs/privacy.md](docs/privacy.md) を参照。
