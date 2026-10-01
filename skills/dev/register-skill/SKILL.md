---
name: register-skill
description: 明示された skill を takatoku23/my-ai-skill に登録し、Codex と Claude Code の両方へ配布できる状態にする。自作の手順を新しい skill として追加する場合と、外部 repository の skill をマニフェストに加える場合の両方を扱う。「skill に登録して」「このスキルを管理に入れて」「my-ai-skill に追加して」と頼まれたときに使う。
license: MIT
---

# skill の登録

利用者が明示した内容だけを takatoku23/my-ai-skill に登録する。会話から skill 化できそうな手順を見つけても、頼まれていなければ登録しない。

## 作業場所

takatoku23/my-ai-skill の作業ツリーで作業する。手元に clone が見つからなければ、置き場所を利用者に確認してから `gh repo clone takatoku23/my-ai-skill` する。作業はデフォルトブランチから切った新しいブランチで行う。

## 登録の種類を決める

| 依頼 | 登録先 |
| --- | --- |
| 自分で書いた手順・規範を skill にしたい | `skills/<namespace>/<name>/SKILL.md` を作る |
| GitHub で公開されている skill を使いたい | コピーせず `manifests/user.txt` に `<OWNER/REPO> <skill>` を足す |
| gist など gh skill で入れられない公開物を使いたい | `references/` に取り込み、`scripts/sync-vendored.sh` に取得元を足す |
| 特定 repository でだけ使いたい | `manifests/projects/<repository>.txt` に足す |

外部 skill をコピーすると upstream の更新を `gh skill update` で追えなくなる。そのため、upstream から入れられるものは必ずマニフェストで参照する。

## 自作 skill を作るとき

- namespace は既存の `skills/` 配下から選ぶ。合うものがなければ新設を提案し、合意を得てから作る。
- `name` は小文字・数字・ハイフンだけにし、ディレクトリ名と一致させる。
- `description` には、何をする skill かと、どういう依頼で使うかの両方を書く。発火条件は利用者が実際に使う言い回しで書く。
- Codex と Claude Code のどちらでも意味が通る手順にする。片方にしかない tool 名や slash command を前提にしない。
- 本文が長くなる場合は、手順を `SKILL.md` に残し、参照資料を `references/` に分ける。

[docs/privacy.md](../../../docs/privacy.md) の境界を守る。token や個人の絶対パスを skill に書かない。

## 検証と公開

1. `mise run check` を通す。
2. `mise run install:local` で作業ツリーから入れ、Codex と Claude Code で発火することを確認する。
3. コミットし、push と PR 作成は利用者の了承を得てから行う。
4. マージ後の publish（`mise run publish -- <tag>`）と、remote からの入れ直し（`mise run install:user`）は利用者に確認してから実行する。
