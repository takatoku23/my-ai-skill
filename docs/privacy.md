# Privacy and Sharing Boundary

Agent Skills はプロンプトとして読み込まれ、repository を公開すれば誰でも読める。そのため、ここに入れる情報は公開されてもよい内容に限る。

## OK

- 作業手順、レビュー観点、文章規範
- public な repository、issue、PR、docs への参照
- secret を含まないサンプルコマンド
- license が再配布を許す公開物の取り込み（出典と license を明記する）

## NG

- token、secret、credential、API key
- 個人の絶対パス（`/Users/...`）
- 勤務先や他チームの非公開情報（社内 repository の skill 本文、内部 URL、Project ID など）
- license が不明な、または再配布を許さない文章やコードのコピー

## If Unsure

次のいずれかにする。

- skill の引数として利用者に入力させる
- `references/*.example.md` にダミー値だけを置く
- project scope の skill として、該当 repository 側で管理する
- 外部の公開物なら、コピーせずマニフェストから参照する
