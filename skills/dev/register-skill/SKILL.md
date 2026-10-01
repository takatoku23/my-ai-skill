---
name: register-skill
description: 明示された汎用的な skill を takatoku23/my-ai-skill に登録し、publish して、この PC の Codex と Claude Code の両方へすぐ入れ直す。どの作業ディレクトリのセッションからでも使える。いま書いた手順や project の `.claude/skills/` にある skill を新しい自作 skill として取り込む場合、既存の自作 skill を直す場合、GitHub で公開されている外部 skill をマニフェストに加える場合を扱う。「skill に登録して」「このスキルを my-ai-skill に入れて」「汎用スキルにして他でも使えるようにして」「この skill を直して反映して」と頼まれたときに使う。
license: MIT
---

# skill の登録と適用

利用者が明示した内容だけを takatoku23/my-ai-skill に登録し、publish して、この PC の user scope へ入れ直すところまで行う。会話から skill 化できそうな手順を見つけても、頼まれていなければ登録しない。

この skill を呼ばれたことを、my-ai-skill の main への commit と push、release の publish、この PC への install の了承として扱う。ほかの repository の変更（登録元 skill の削除など）は、別に確認を取る。

## 1. repository の場所を確かめる

```bash
dir="$(git config --global --get my-ai-skill.path)"
```

値が空か、そのディレクトリがなければ、clone する場所を利用者に確認して `gh repo clone takatoku23/my-ai-skill <場所>` し、そのディレクトリで `mise run setup` を実行する。

以降のコマンドはすべて `$dir` で実行する（`git -C "$dir"`、`mise run --cd "$dir"`）。現在の作業ディレクトリの repository には触らない。

作業前に `git -C "$dir" status --porcelain` が空で、branch が `main` であることを確かめ、`git -C "$dir" pull --rebase origin main` で最新にする。commit されていない変更があれば、自分の作業と混ぜずに利用者へ伝えて止める。

## 2. 登録の種類を決める

| 依頼 | 登録先 |
| --- | --- |
| 手順や規範を新しい skill にしたい | `skills/<namespace>/<name>/SKILL.md` を作り、`manifests/user.txt` に path を足す |
| 既存の自作 skill を直したい | 該当する `skills/**/SKILL.md` と `references/` を直す |
| GitHub で公開されている skill を使いたい | コピーせず `manifests/user.txt` に `<OWNER/REPO> <skill>` を足す |
| gist など gh skill で入れられない公開物を使いたい | `references/` に取り込み、`scripts/sync-vendored.sh` に取得元を足す |

外部 skill をコピーすると、upstream の更新を `gh skill update` で追えなくなる。upstream から入れられるものは必ずマニフェストで参照する。

## 3. 汎用にできるかを確かめる

my-ai-skill は public repository で、user scope に入れた skill はすべての作業ディレクトリで読み込まれる。登録元の内容（project の `.claude/skills/<name>/` など）を読み、次を確かめる。

- 特定 repository のパス、コマンド、規約、社内サービスに依存していないか。依存しているなら、その部分を「作業中の repository の規約を読んで従う」形に書き換えられるかを考える。書き換えると意味がなくなるなら、汎用 skill ではないと伝え、その repository の `.claude/skills/` か `manifests/projects/` での管理を提案して止める。
- `$dir/docs/privacy.md` の NG に当たる情報（token、個人の絶対パス、勤務先の非公開情報、個人の資産や連絡先）を含まないか。skill の動作に個人の情報が要るなら、`~/.<skill名>/` のような PC 上のファイルから読む形にし、repository には架空の値で書いた `references/*.example.md` だけを置く。
- Codex と Claude Code のどちらでも意味が通るか。片方にしかない tool 名、slash command、`allowed-tools` を前提にしない。

書き換えが必要な場合は、何を変えるかを利用者に短く示してから進める。

## 4. skill を書く

- namespace は `$dir/skills/` の既存のものから選ぶ。合うものがなければ用途を表す短い名前で新設し、報告に含める。
- `name` は小文字、数字、ハイフンだけにし、ディレクトリ名と一致させる。既存の skill や Claude Code plugin の skill と名前が重ならないことを `mise run --cd "$dir" inventory` で確かめる。
- `description` には、何をする skill かと、どういう依頼で使うかの両方を書く。発火条件は利用者が実際に使う言い回しで書く。
- frontmatter に `license: MIT` を付ける（取り込んだ公開物はその license にする）。
- 本文が長くなる場合は、手順を `SKILL.md` に残し、参照資料を `references/` に分ける。
- 日本語の文章は japanese-tech-writing の規範に従う。

## 5. 反映する

```bash
mise run --cd "$dir" check
git -C "$dir" add <変更したファイル>
git -C "$dir" commit -m "<変更対象と目的>"
mise run --cd "$dir" release
```

commit message は repository の既存の commit に合わせて日本語で書き、末尾に利用中の agent の co-author 行があれば付ける。

`release` は push、次の patch version での publish、user scope への install、棚卸しの表示までを行う。skill の削除や改名を含むときは `mise run --cd "$dir" release -- minor` にする。

Codex の sandbox で network や `$dir` への書き込みが拒否された場合は、権限の昇格を利用者に求める。回避のために別の場所へ書き出したりしない。

## 6. 報告する

- 登録した skill、publish した version、棚卸しの結果（Codex と Claude Code の両方で `managed` になったか）を伝える。
- 登録元が project の `.claude/skills/` などにあった場合、その元のファイルは消さずに残し、消すかどうかを利用者に確認する。user scope と project scope に同名の skill があると、両方が読み込まれる。
- 新しい skill は、次に起動したセッションから使える。いまのセッションで使えるかどうかは agent によって違う。
