# AI

AI ツールの新機能と、開発での使い方を扱う。「何が出たか」「使えるのか」「どう使うか」の 3 層に分けて集め、出力もこの 3 層で分ける。

## 層 1: リリース・アナウンス

公式の一次情報で、何が出たかを押さえる。

- Anthropic: anthropic.com/news、Claude Code の CHANGELOG（github.com/anthropics/claude-code）と docs の What's new
- OpenAI: openai.com/news、Codex の changelog とリリース（github.com/openai/codex）
- Cursor の changelog、GitHub Copilot（github.blog の changelog）
- 各社の公式 X アカウント

読者プロフィールに使っている AI ツールが書いてあれば、そのツールの changelog は必ず確認する。

## 層 2: 評価・分析

使えるかを判断する材料を集める。

- simonwillison.net、Latent Space
- Hacker News の AI 関連スレッド（50 points 以上）
- 企業の AI 導入報告、ベンチマーク、比較レビュー

## 層 3: 活用・実践

どう使うかの具体例を集める。

- Zenn、Qiita、はてなブックマーク（30 users 以上）の Claude Code、Codex、Cursor、MCP、Agent Skills の記事
- X のエンジニアによる実践 tips
- GitHub Trending の AI エージェント、MCP サーバー、skill 集

## 採用

- 読者が使っている AI ツールの新機能、料金や上限の変更
- MCP、Agent Skills、エージェント、マルチエージェントのツールと実践例
- AI と React / TypeScript を組み合わせた事例
- 試した結果を書いた体験レポート、比較レビュー
- 開発ワークフローの具体的な改善例、プロンプトの実践 tips

## 除外

- 画像、音楽、動画の生成
- AI 倫理や政策の一般論、「AI とは何か」の概念記事
- データサイエンスや機械学習の研究者向けの内容

## 出力形式

該当がない層は省く。

```text
🤖 AI（MM/DD）

【リリース・アナウンス】
• タイトル
  要約
  URL

【評価・分析】
• タイトル
  要約
  URL

【活用・実践】
• タイトル
  要約
  URL
```

期間を指定された「最近何ができるようになったか」の質問では、この形式ではなく、時期ごとに新機能を並べ、それぞれ何ができるようになったかを 1 行で書く。最後に、読者の使い方で試す価値があるものを挙げる。
